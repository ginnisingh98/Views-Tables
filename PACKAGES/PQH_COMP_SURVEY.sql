--------------------------------------------------------
--  DDL for Package PQH_COMP_SURVEY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_COMP_SURVEY" AUTHID CURRENT_USER as
/* $Header: pqhsuadi.pkh 120.0 2005/05/29 02:07:39 appldev noship $ */

procedure import_row
( P_survey_name                 VARCHAR2   default null
, P_identifier                  VARCHAR2   default null
, P_survey_company              VARCHAR2   default null
, P_survey_type                 VARCHAR2   default null
, P_base_region                 VARCHAR2   default null
, P_SALARY_SURVEY_ID            NUMBER     default null
, P_SALARY_SURVEY_LINE_ID       NUMBER     default null
, P_OBJECT_VERSION_NUMBER       NUMBER     default null
, P_SURVEY_JOB_NAME_CODE        VARCHAR2   default null
, P_SURVEY_REGION_CODE          VARCHAR2   default null
, P_SURVEY_SENIORITY_CODE       VARCHAR2   default null
, P_COMPANY_SIZE_CODE           VARCHAR2   default null
, P_INDUSTRY_CODE               VARCHAR2   default null
, P_SURVEY_AGE_CODE             VARCHAR2   default null
, P_CURRENCY_CODE               VARCHAR2   default null
, P_STOCK_DISPLAY_TYPE_CODE   VARCHAR2   default null
, P_SURVEY_JOB_NAME             VARCHAR2   default null
, P_SURVEY_REGION               VARCHAR2   default null
, P_SURVEY_SENIORITY            VARCHAR2   default null
, P_COMPANY_SIZE                VARCHAR2   default null
, P_INDUSTRY                    VARCHAR2   default null
, P_SURVEY_AGE                  VARCHAR2   default null
, P_CURRENCY                    VARCHAR2   default null
, P_START_DATE                  DATE       default null
, P_END_DATE                    DATE       default null
, P_DIFFERENTIAL                NUMBER     default null
, P_MINIMUM_PAY                 NUMBER     default null
, P_MEAN_PAY                    NUMBER     default null
, P_MAXIMUM_PAY                 NUMBER     default null
, P_GRADUATE_PAY                NUMBER     default null
, P_STARTING_PAY                NUMBER     default null
, P_PERCENTAGE_CHANGE           NUMBER     default null
, P_JOB_FIRST_QUARTILE          NUMBER     default null
, P_JOB_MEDIAN_QUARTILE         NUMBER     default null
, P_JOB_THIRD_QUARTILE          NUMBER     default null
, P_JOB_FOURTH_QUARTILE         NUMBER     default null
, P_MINIMUM_TOTAL_COMPENSATION  NUMBER     default null
, P_MEAN_TOTAL_COMPENSATION     NUMBER     default null
, P_MAXIMUM_TOTAL_COMPENSATION  NUMBER     default null
, P_COMPNSTN_FIRST_QUARTILE     NUMBER     default null
, P_COMPNSTN_MEDIAN_QUARTILE    NUMBER     default null
, P_COMPNSTN_THIRD_QUARTILE     NUMBER     default null
, P_COMPNSTN_FOURTH_QUARTILE    NUMBER     default null
, P_TENTH_PERCENTILE            NUMBER     default null
, P_TWENTY_FIFTH_PERCENTILE     NUMBER     default null
, P_FIFTIETH_PERCENTILE         NUMBER     default null
, P_SEVENTY_FIFTH_PERCENTILE    NUMBER     default null
, P_NINETIETH_PERCENTILE        NUMBER     default null
, P_MINIMUM_BONUS               NUMBER     default null
, P_MEAN_BONUS                  NUMBER     default null
, P_MAXIMUM_BONUS               NUMBER     default null
, P_MINIMUM_SALARY_INCREASE     NUMBER     default null
, P_MEAN_SALARY_INCREASE        NUMBER     default null
, P_MAXIMUM_SALARY_INCREASE     NUMBER     default null
, P_MIN_VARIABLE_COMPENSATION   NUMBER     default null
, P_MEAN_VARIABLE_COMPENSATION  NUMBER     default null
, P_MAX_VARIABLE_COMPENSATION   NUMBER     default null
, P_MINIMUM_STOCK               NUMBER     default null
, P_MEAN_STOCK                  NUMBER     default null
, P_MAXIMUM_STOCK               NUMBER     default null
, P_STOCK_DISPLAY_TYPE          VARCHAR2   default null
, P_ATTRIBUTE_CATEGORY          VARCHAR2   default null
, P_ATTRIBUTE1                  VARCHAR2   default null
, P_ATTRIBUTE2                  VARCHAR2   default null
, P_ATTRIBUTE3                  VARCHAR2   default null
, P_ATTRIBUTE4                  VARCHAR2   default null
, P_ATTRIBUTE5                  VARCHAR2   default null
, P_ATTRIBUTE6                  VARCHAR2   default null
, P_ATTRIBUTE7                  VARCHAR2   default null
, P_ATTRIBUTE8                  VARCHAR2   default null
, P_ATTRIBUTE9                  VARCHAR2   default null
, P_ATTRIBUTE10                 VARCHAR2   default null
, P_ATTRIBUTE11                 VARCHAR2   default null
, P_ATTRIBUTE12                 VARCHAR2   default null
, P_ATTRIBUTE13                 VARCHAR2   default null
, P_ATTRIBUTE14                 VARCHAR2   default null
, P_ATTRIBUTE15                 VARCHAR2   default null
, P_ATTRIBUTE16                 VARCHAR2   default null
, P_ATTRIBUTE17                 VARCHAR2   default null
, P_ATTRIBUTE18                 VARCHAR2   default null
, P_ATTRIBUTE19                 VARCHAR2   default null
, P_ATTRIBUTE20                 VARCHAR2   default null
, P_ATTRIBUTE21                 VARCHAR2   default null
, P_ATTRIBUTE22                 VARCHAR2   default null
, P_ATTRIBUTE23                 VARCHAR2   default null
, P_ATTRIBUTE24                 VARCHAR2   default null
, P_ATTRIBUTE25                 VARCHAR2   default null
, P_ATTRIBUTE26                 VARCHAR2   default null
, P_ATTRIBUTE27                 VARCHAR2   default null
, P_ATTRIBUTE28                 VARCHAR2   default null
, P_ATTRIBUTE29                 VARCHAR2   default null
, P_ATTRIBUTE30                 VARCHAR2   default null
, P_LAST_UPDATE_DATE            DATE       default null
, P_LAST_UPDATED_BY             NUMBER     default null
, P_LAST_UPDATE_LOGIN           NUMBER     default null
, P_CREATED_BY                  NUMBER     default null
, P_CREATION_DATE               DATE       default null
);

end PQH_COMP_SURVEY;

 

/
