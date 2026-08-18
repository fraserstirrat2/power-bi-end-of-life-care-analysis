### 0: Script information ###

# Name of file: Update for SG open data file for End of Life publication
# Type of script: R Studio Workbench, script was most recently run on: v4.4.2 (2025-10-09)
#                         
# Approximate run time: 1 minute, CPU = 1 & GBs = 10
#
# Syntax for End of Life open data file produced for SG website.

#### 1: Setup environment ####

# Load packages
library(magrittr)
library(dplyr)
library(odbc)
library(janitor)
library(purrr)
library(readr)
library(phsmethods)
library(lubridate)
library(stringr)
library(glue)
library(haven)
library(fst)
library(tidyr)
library(slfhelper)
library(arrow)
library(readxl)
library(openxlsx)

HB <- read_csv("/conf/irf/18-End-of-Life/Publication/October 2025_publication/2025-10-07_last-six-months-of-life_health-board.csv")

HB <- select(HB, -FinancialYearQF, -HBRQF)
HB <- filter(HB, FinancialYear %in% c("2010/11", "2011/12", "2012/13", "2013/14", "2014/15", "2015/16", "2016/17", "2017/18", "2018/19", "2019/20", "2020/21", "2021/22", "2022/23", "2023/24", "2024/25"))

HB <- gather(HB, "Units", "Value", PercentageSpentInHomeCommunity, PercentageSpentInHospital, NumberOfDeaths,
             TotalLengthOfStay, AverageDaysInCommunity, AverageDaysInHospital)

HB <- rename(HB, DateCode = FinancialYear,
             FeatureCode = HBR)

HB <- mutate(HB, Units = case_when(
  Units == "PercentageSpentInHomeCommunity" ~ "Percentage spent at home or community setting",
  Units == "PercentageSpentInHospital" ~ "Percentage spent in hospital",
  Units == "NumberOfDeaths" ~ "Number of deaths",
  Units == "TotalLengthOfStay" ~ "Total length of stay",
  Units == "AverageDaysInCommunity" ~ "Average days in community",
  Units == "AverageDaysInHospital" ~ "Average days in hospital")
)

HB <- mutate(HB, Measurement = case_when(
  Units == "Percentage spent at home or community setting" ~ "Ratio",
  Units == "Percentage spent in hospital" ~ "Ratio",
  Units == "Number of deaths" ~ "Count",
  Units == "Total length of stay" ~ "Count",
  Units == "Average days in community" ~ "Mean",
  Units == "Average days in hospital" ~ "Mean")
)

HB <- mutate(HB, PEOLCIndicator = Units)

HSCP <- read_csv("/conf/irf/18-End-of-Life/Publication/October 2025_publication/2025-10-07_last-six-months-of-life_hscp.csv")

HSCP <- select(HSCP, -FinancialYearQF)
HSCP <- filter(HSCP, FinancialYear %in% c("2010/11", "2011/12", "2012/13", "2013/14", "2014/15", "2015/16", "2016/17", "2017/18", "2018/19", "2019/20", "2020/21", "2021/22", "2022/23", "2023/24", "2024/25"))

HSCP <- gather(HSCP, "Units", "Value", PercentageSpentInHomeCommunity, PercentageSpentInHospital, NumberOfDeaths,
             TotalLengthOfStay, AverageDaysInCommunity, AverageDaysInHospital)

HSCP <- rename(HSCP, DateCode = FinancialYear,
             FeatureCode = HSCP)

HSCP <- mutate(HSCP, Units = case_when(
  Units == "PercentageSpentInHomeCommunity" ~ "Percentage spent at home or community setting",
  Units == "PercentageSpentInHospital" ~ "Percentage spent in hospital",
  Units == "NumberOfDeaths" ~ "Number of deaths",
  Units == "TotalLengthOfStay" ~ "Total length of stay",
  Units == "AverageDaysInCommunity" ~ "Average days in community",
  Units == "AverageDaysInHospital" ~ "Average days in hospital")
)

HSCP <- mutate(HSCP, Measurement = case_when(
  Units == "Percentage spent at home or community setting" ~ "Ratio",
  Units == "Percentage spent in hospital" ~ "Ratio",
  Units == "Number of deaths" ~ "Count",
  Units == "Total length of stay" ~ "Count",
  Units == "Average days in community" ~ "Mean",
  Units == "Average days in hospital" ~ "Mean")
)

HSCP <- mutate(HSCP, PEOLCIndicator = Units)

CA <- read_csv("/conf/irf/18-End-of-Life/Publication/October 2025_publication/2025-10-07_last-six-months-of-life_council-area.csv")

CA <- select(CA, -FinancialYearQF)
CA <- filter(CA, FinancialYear %in% c("2010/11", "2011/12", "2012/13", "2013/14", "2014/15", "2015/16", "2016/17", "2017/18", "2018/19", "2019/20", "2020/21", "2021/22", "2022/23", "2023/24", "2024/25"))

CA <- gather(CA, "Units", "Value", PercentageSpentInHomeCommunity, PercentageSpentInHospital, NumberOfDeaths,
               TotalLengthOfStay, AverageDaysInCommunity, AverageDaysInHospital)

CA <- rename(CA, DateCode = FinancialYear,
               FeatureCode = CA)

CA <- mutate(CA, Units = case_when(
  Units == "PercentageSpentInHomeCommunity" ~ "Percentage spent at home or community setting",
  Units == "PercentageSpentInHospital" ~ "Percentage spent in hospital",
  Units == "NumberOfDeaths" ~ "Number of deaths",
  Units == "TotalLengthOfStay" ~ "Total length of stay",
  Units == "AverageDaysInCommunity" ~ "Average days in community",
  Units == "AverageDaysInHospital" ~ "Average days in hospital")
)

CA <- mutate(CA, Measurement = case_when(
  Units == "Percentage spent at home or community setting" ~ "Ratio",
  Units == "Percentage spent in hospital" ~ "Ratio",
  Units == "Number of deaths" ~ "Count",
  Units == "Total length of stay" ~ "Count",
  Units == "Average days in community" ~ "Mean",
  Units == "Average days in hospital" ~ "Mean")
)

CA <- mutate(CA, PEOLCIndicator = Units)

Age_Sex_main <- read_csv("/conf/irf/18-End-of-Life/Publication/October 2025_publication/2025-10-07_last-six-months-of-life_age-sex.csv")

Age_Sex <- select(Age_Sex_main, -FinancialYearQF)
Age_Sex <- filter(Age_Sex, FinancialYear %in% c("2010/11", "2011/12", "2012/13", "2013/14", "2014/15", "2015/16", "2016/17", "2017/18", "2018/19", "2019/20", "2020/21", "2021/22", "2022/23", "2023/24", "2024/25"))

Age_Sex <- gather(Age_Sex, "Units", "Value", PercentageSpentInHomeCommunity, PercentageSpentInHospital, NumberOfDeaths,
             TotalLengthOfStay, AverageDaysInCommunity, AverageDaysInHospital)

Age_Sex <- rename(Age_Sex, DateCode = FinancialYear,
             FeatureCode = Country,
             Age = AgeGroup)

Age_Sex <- mutate(Age_Sex, Units = case_when(
  Units == "PercentageSpentInHomeCommunity" ~ "Percentage spent at home or community setting",
  Units == "PercentageSpentInHospital" ~ "Percentage spent in hospital",
  Units == "NumberOfDeaths" ~ "Number of deaths",
  Units == "TotalLengthOfStay" ~ "Total length of stay",
  Units == "AverageDaysInCommunity" ~ "Average days in community",
  Units == "AverageDaysInHospital" ~ "Average days in hospital")
)

Age_Sex <- mutate(Age_Sex, Measurement = case_when(
  Units == "Percentage spent at home or community setting" ~ "Ratio",
  Units == "Percentage spent in hospital" ~ "Ratio",
  Units == "Number of deaths" ~ "Count",
  Units == "Total length of stay" ~ "Count",
  Units == "Average days in community" ~ "Mean",
  Units == "Average days in hospital" ~ "Mean")
)

Age_Sex <- mutate(Age_Sex, PEOLCIndicator = Units)


Age_All <- mutate(Age_Sex_main, AgeGroup = "All")
Age_All <- filter(Age_All, FinancialYear %in% c("2010/11", "2011/12", "2012/13", "2013/14", "2014/15", "2015/16", "2016/17", "2017/18", "2018/19", "2019/20", "2020/21", "2021/22","2022/23","2023/24", "2024/25"))


Age_All <- Age_All %>% group_by(FinancialYear, Country, AgeGroup, Sex) %>%
  summarise(PercentageSpentInHomeCommunity = sum(PercentageSpentInHomeCommunity),
            PercentageSpentInHospital = sum(PercentageSpentInHospital),
            NumberOfDeaths = sum(NumberOfDeaths),
            TotalLengthOfStay = sum(TotalLengthOfStay),
            AverageDaysInCommunity = sum(AverageDaysInCommunity),
            AverageDaysInHospital = sum(AverageDaysInHospital)) %>%
  ungroup()

Age_All <- Age_All %>% mutate(possiblebeddays = NumberOfDeaths*182.5) %>%
  mutate(PercentageSpentInHospital = (TotalLengthOfStay/possiblebeddays)*100) %>%
  mutate(PercentageSpentInHomeCommunity = 100 - PercentageSpentInHospital) %>%
  mutate(AverageDaysInCommunity = (PercentageSpentInHomeCommunity*182.5)/100) %>%
  mutate(AverageDaysInHospital = (PercentageSpentInHospital*182.5)/100)

Age_All <- gather(Age_All, "Units", "Value", PercentageSpentInHomeCommunity, PercentageSpentInHospital, NumberOfDeaths,
                  TotalLengthOfStay, AverageDaysInCommunity, AverageDaysInHospital)

Age_All <- rename(Age_All, DateCode = FinancialYear,
                  FeatureCode = Country,
                  Age = AgeGroup)

Age_All <- mutate(Age_All, Units = case_when(
  Units == "PercentageSpentInHomeCommunity" ~ "Percentage spent at home or community setting",
  Units == "PercentageSpentInHospital" ~ "Percentage spent in hospital",
  Units == "NumberOfDeaths" ~ "Number of deaths",
  Units == "TotalLengthOfStay" ~ "Total length of stay",
  Units == "AverageDaysInCommunity" ~ "Average days in community",
  Units == "AverageDaysInHospital" ~ "Average days in hospital")
)

Age_All <- mutate(Age_All, Measurement = case_when(
  Units == "Percentage spent at home or community setting" ~ "Ratio",
  Units == "Percentage spent in hospital" ~ "Ratio",
  Units == "Number of deaths" ~ "Count",
  Units == "Total length of stay" ~ "Count",
  Units == "Average days in community" ~ "Mean",
  Units == "Average days in hospital" ~ "Mean")
)

Age_All <- mutate(Age_All, PEOLCIndicator = Units)
Age_All <- select(Age_All, -possiblebeddays)

#All Gender group
Gender_All <- mutate(Age_Sex_main, Sex = "All")
Gender_All <- filter(Gender_All, FinancialYear %in% c("2010/11", "2011/12", "2012/13", "2013/14", "2014/15", "2015/16", "2016/17", "2017/18", "2018/19", "2019/20", "2020/21", "2021/22", "2022/23", "2023/24", "2024/25"))


Gender_All <- Gender_All %>% group_by(FinancialYear, Country, AgeGroup, Sex) %>%
  summarise(PercentageSpentInHomeCommunity = sum(PercentageSpentInHomeCommunity),
            PercentageSpentInHospital = sum(PercentageSpentInHospital),
            NumberOfDeaths = sum(NumberOfDeaths),
            TotalLengthOfStay = sum(TotalLengthOfStay),
            AverageDaysInCommunity = sum(AverageDaysInCommunity),
            AverageDaysInHospital = sum(AverageDaysInHospital)) %>%
  ungroup()

Gender_All <- Gender_All %>% mutate(possiblebeddays = NumberOfDeaths*182.5) %>%
  mutate(PercentageSpentInHospital = (TotalLengthOfStay/possiblebeddays)*100) %>%
  mutate(PercentageSpentInHomeCommunity = 100 - PercentageSpentInHospital) %>%
  mutate(AverageDaysInCommunity = (PercentageSpentInHomeCommunity*182.5)/100) %>%
  mutate(AverageDaysInHospital = (PercentageSpentInHospital*182.5)/100)

Gender_All <- gather(Gender_All, "Units", "Value", PercentageSpentInHomeCommunity, PercentageSpentInHospital, NumberOfDeaths,
                  TotalLengthOfStay, AverageDaysInCommunity, AverageDaysInHospital)

Gender_All <- rename(Gender_All, DateCode = FinancialYear,
                  FeatureCode = Country,
                  Age = AgeGroup)

Gender_All <- mutate(Gender_All, Units = case_when(
  Units == "PercentageSpentInHomeCommunity" ~ "Percentage spent at home or community setting",
  Units == "PercentageSpentInHospital" ~ "Percentage spent in hospital",
  Units == "NumberOfDeaths" ~ "Number of deaths",
  Units == "TotalLengthOfStay" ~ "Total length of stay",
  Units == "AverageDaysInCommunity" ~ "Average days in community",
  Units == "AverageDaysInHospital" ~ "Average days in hospital")
)

Gender_All <- mutate(Gender_All, Measurement = case_when(
  Units == "Percentage spent at home or community setting" ~ "Ratio",
  Units == "Percentage spent in hospital" ~ "Ratio",
  Units == "Number of deaths" ~ "Count",
  Units == "Total length of stay" ~ "Count",
  Units == "Average days in community" ~ "Mean",
  Units == "Average days in hospital" ~ "Mean")
)

Gender_All <- mutate(Gender_All, PEOLCIndicator = Units)
Gender_All <- select(Gender_All, -possiblebeddays)

SIMD <- read_csv("/conf/irf/18-End-of-Life/Publication/October 2025_publication/2025-10-07_last-six-months-of-life_deprivation.csv")

SIMD <- select(SIMD, -FinancialYearQF)
SIMD <- filter(SIMD, FinancialYear %in% c("2010/11", "2011/12", "2012/13", "2013/14", "2014/15", "2015/16", "2016/17", "2017/18", "2018/19", "2019/20", "2020/21", "2021/22", "2022/23", "2023/24", "2024/25"))

SIMD <- gather(SIMD, "Units", "Value", PercentageSpentInHomeCommunity, PercentageSpentInHospital, NumberOfDeaths,
                  TotalLengthOfStay, AverageDaysInCommunity, AverageDaysInHospital)

SIMD <- rename(SIMD, DateCode = FinancialYear,
                  FeatureCode = Country)

SIMD <- mutate(SIMD, SIMD = as.character(SIMD))
SIMD <- mutate(SIMD, SIMD = case_when(
  SIMD == "1" ~ "1 - most deprived",
  SIMD == "5" ~ "5 - least deprived",
  TRUE ~ SIMD)
)

SIMD <- mutate(SIMD, Units = case_when(
  Units == "PercentageSpentInHomeCommunity" ~ "Percentage spent at home or community setting",
  Units == "PercentageSpentInHospital" ~ "Percentage spent in hospital",
  Units == "NumberOfDeaths" ~ "Number of deaths",
  Units == "TotalLengthOfStay" ~ "Total length of stay",
  Units == "AverageDaysInCommunity" ~ "Average days in community",
  Units == "AverageDaysInHospital" ~ "Average days in hospital")
)

SIMD <- mutate(SIMD, Measurement = case_when(
  Units == "Percentage spent at home or community setting" ~ "Ratio",
  Units == "Percentage spent in hospital" ~ "Ratio",
  Units == "Number of deaths" ~ "Count",
  Units == "Total length of stay" ~ "Count",
  Units == "Average days in community" ~ "Mean",
  Units == "Average days in hospital" ~ "Mean")
)

SIMD <- mutate(SIMD, PEOLCIndicator = Units)

Urban_Rural <- read_csv("/conf/irf/18-End-of-Life/Publication/October 2025_publication/2025-10-07_last-six-months-of-life_rurality.csv")

Urban_Rural <- select(Urban_Rural, -FinancialYearQF)
Urban_Rural <- filter(Urban_Rural, FinancialYear %in% c("2010/11", "2011/12", "2012/13", "2013/14", "2014/15", "2015/16", "2016/17", "2017/18", "2018/19", "2019/20", "2020/21", "2021/22", "2022/23", "2023/24", "2024/25"))

Urban_Rural <- gather(Urban_Rural, "Units", "Value", PercentageSpentInHomeCommunity, PercentageSpentInHospital, NumberOfDeaths,
               TotalLengthOfStay, AverageDaysInCommunity, AverageDaysInHospital)

Urban_Rural <- rename(Urban_Rural, DateCode = FinancialYear,
               FeatureCode = Country)

Urban_Rural <- mutate(Urban_Rural, Units = case_when(
  Units == "PercentageSpentInHomeCommunity" ~ "Percentage spent at home or community setting",
  Units == "PercentageSpentInHospital" ~ "Percentage spent in hospital",
  Units == "NumberOfDeaths" ~ "Number of deaths",
  Units == "TotalLengthOfStay" ~ "Total length of stay",
  Units == "AverageDaysInCommunity" ~ "Average days in community",
  Units == "AverageDaysInHospital" ~ "Average days in hospital")
)

Urban_Rural <- mutate(Urban_Rural, Measurement = case_when(
  Units == "Percentage spent at home or community setting" ~ "Ratio",
  Units == "Percentage spent in hospital" ~ "Ratio",
  Units == "Number of deaths" ~ "Count",
  Units == "Total length of stay" ~ "Count",
  Units == "Average days in community" ~ "Mean",
  Units == "Average days in hospital" ~ "Mean")
)

Urban_Rural <- mutate(Urban_Rural, UrbanRural6Fold = case_when(
  UrbanRural6Fold == "1 Large Urban Areas" ~ "Large urban areas",
  UrbanRural6Fold == "2 Other Urban Areas" ~ "Other urban areas",
  UrbanRural6Fold == "3 Accessible Small Towns" ~ "Accessible small towns",
  UrbanRural6Fold == "4 Remote Small Towns" ~ "Remote small towns",
  UrbanRural6Fold == "5 Accessible Rural" ~ "Accessible rural",
  UrbanRural6Fold == "6 Remote Rural" ~ "Remote rural")
)

Urban_Rural <- mutate(Urban_Rural, PEOLCIndicator = Units)

Final_output <- bind_rows(HB, HSCP, CA, Age_Sex, Age_All, Gender_All, SIMD, Urban_Rural)

Final_output <- Final_output %>% mutate(Age = if_else(is.na(Age) == TRUE, "All", Age)) %>%
  mutate(Sex = if_else(is.na(Sex) == TRUE, "All", Sex)) %>%
  mutate(SIMD = if_else(is.na(SIMD) == TRUE, "All", SIMD)) %>%
  mutate(UrbanRural6Fold = if_else(is.na(UrbanRural6Fold) == TRUE, "All", UrbanRural6Fold)) %>% 
  relocate(DateCode,.after = FeatureCode) %>% 
  relocate(Measurement,.before = Units)

#SP 09/10/2024 Remember to manually rename some of the variables when in Excel.
# and then create a csv file.

write.xlsx(Final_output, "/conf/irf/18-End-of-Life/Publication/SG open data/2025 Data/End of Life Open Data 2025.xlsx")

########################## End of the script ##################################################
#
#
#SP 06/10/2024 We are not sure why we need the following part added in 2024!

# Age All and Gender All separate outputs

Age_Sex_main <- read_csv("/conf/irf/18-End-of-Life/Publication/October 2025_publication/2025-10-07_last-six-months-of-life_age-sex.csv")

Age_All <- mutate(Age_Sex_main, AgeGroup = "All")
Age_All <- bind_rows(Age_Sex_main, Age_All)
#Age_All <- filter(Age_All, FinancialYear %in% c("2010/11", "2011/12", "2012/13", "2013/14", "2014/15", "2015/16", "2016/17", "2017/18", "2018/19", "2019/20", "2020/21", "2021/22", "2022/23", "2023/24", "2024/25"))

Age_All <- Age_All %>% group_by(FinancialYear, Country, AgeGroup) %>%
  summarise(PercentageSpentInHomeCommunity = sum(PercentageSpentInHomeCommunity),
            PercentageSpentInHospital = sum(PercentageSpentInHospital),
            NumberOfDeaths = sum(NumberOfDeaths),
            TotalLengthOfStay = sum(TotalLengthOfStay),
            AverageDaysInCommunity = sum(AverageDaysInCommunity),
            AverageDaysInHospital = sum(AverageDaysInHospital)) %>%
  ungroup()

Age_All <- Age_All %>% mutate(possiblebeddays = NumberOfDeaths*182.5) %>%
  mutate(PercentageSpentInHospital = (TotalLengthOfStay/possiblebeddays)*100) %>%
  mutate(PercentageSpentInHomeCommunity = 100 - PercentageSpentInHospital) %>%
  mutate(AverageDaysInCommunity = (PercentageSpentInHomeCommunity*182.5)/100) %>%
  mutate(AverageDaysInHospital = (PercentageSpentInHospital*182.5)/100)

Age_All <- select(Age_All, -possiblebeddays)
write.xlsx(Age_All, "/conf/irf/18-End-of-Life/Publication/SG open data/2024 Data/Age_All_2024.xlsx")


#All Gender group
Gender_All <- mutate(Age_Sex_main, Sex = "All")
Gender_All <- bind_rows(Age_Sex_main, Gender_All)
#Gender_All <- filter(Gender_All, FinancialYear %in% c("2010/11", "2011/12", "2012/13", "2013/14", "2014/15", "2015/16", "2016/17", "2017/18", "2018/19", "2019/20", "2020/21", "2021/22","2022/23","2023/24", "2024/25"))


Gender_All <- Gender_All %>% group_by(FinancialYear, Country, Sex) %>%
  summarise(PercentageSpentInHomeCommunity = sum(PercentageSpentInHomeCommunity),
            PercentageSpentInHospital = sum(PercentageSpentInHospital),
            NumberOfDeaths = sum(NumberOfDeaths),
            TotalLengthOfStay = sum(TotalLengthOfStay),
            AverageDaysInCommunity = sum(AverageDaysInCommunity),
            AverageDaysInHospital = sum(AverageDaysInHospital)) %>%
  ungroup()

Gender_All <- Gender_All %>% mutate(possiblebeddays = NumberOfDeaths*182.5) %>%
  mutate(PercentageSpentInHospital = (TotalLengthOfStay/possiblebeddays)*100) %>%
  mutate(PercentageSpentInHomeCommunity = 100 - PercentageSpentInHospital) %>%
  mutate(AverageDaysInCommunity = (PercentageSpentInHomeCommunity*182.5)/100) %>%
  mutate(AverageDaysInHospital = (PercentageSpentInHospital*182.5)/100)

Gender_All <- select(Gender_All, -possiblebeddays)
write.xlsx(Gender_All, "/conf/irf/18-End-of-Life/Publication/SG open data/2024 Data/Gender_All_2024.xlsx")
