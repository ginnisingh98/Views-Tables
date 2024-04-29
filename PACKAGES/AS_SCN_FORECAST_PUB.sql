--------------------------------------------------------
--  DDL for Package AS_SCN_FORECAST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SCN_FORECAST_PUB" AUTHID CURRENT_USER as
/* $Header: asxppems.pls 115.6 2004/07/13 09:34:24 gbatra ship $ */
G_SUBMITTED    VARCHAR2(30) := 'SUBMITTED';
G_SAVED        VARCHAR2(30) := 'SAVED';

-- Note: The meaning of some of the fields in this record type has changed in 11.5.10.
-- Here are the differences:
-- Pre-11.5.10
-- ===========
-- Pre 11.5.10, the fields Interest_Type_Id, Pri_Interest_Code_Id and Sec_Interest_Code_Id
-- store the interest type id, primary interest code id and secondary interest code id
-- respectively. The field Interest_Type stores the mapping type that is a lookup with
-- 3 values: TYPE, PCODE and SCODE. The mapping type indicates whether the plan element
-- is defined for an interest type or primary interest code or secondary interest code
-- respectively.
-- 11.5.10
-- =======
-- In 11.5.10, the fields Interest_Type_Id and Pri_Interest_Code_Id will store product
-- category id and product category set id respectively. The fields Sec_Interest_Code_Id
-- and Interest_Type will not be used any more and will be passed as null. The reason for
-- not passing a value to Interest_Type field is that mapping type has been obsoleted in
-- 11.5.10. The descriptions associated with the product category id can be obtained from
-- the concat_cat_parentage column in view ENI_PROD_DEN_HRCHY_PARENTS_V.
-- For more details, please refer the design doc.
TYPE forecast_Rec_Type IS RECORD (
    INTEREST_TYPE_ID        NUMBER        ,
    PRI_INTEREST_CODE_ID        NUMBER        ,
    SEC_INTEREST_CODE_ID        NUMBER        ,
    INTEREST_TYPE           VARCHAR2(80)  ,
    WORST_FORECAST_AMOUNT_FLAG  VARCHAR2(1)   ,
    WORST_FORECAST_AMOUNT       NUMBER        ,
    FORECAST_AMOUNT_FLAG        VARCHAR2(1)   ,
    FORECAST_AMOUNT         NUMBER        ,
    BEST_FORECAST_AMOUNT_FLAG   VARCHAR2(1)   ,
    BEST_FORECAST_AMOUNT        NUMBER        );

G_MISS_FORECAST_REC      Forecast_Rec_Type;

TYPE Forecast_Tbl_Type   IS TABLE OF    Forecast_Rec_Type   INDEX BY BINARY_INTEGER;

G_MISS_FORECAST_TBL      Forecast_Tbl_Type;


-- Start of Comments
-- API name:   Get_Forecast_Amounts
-- Type: Public
-- Description:
--
-- Pre-reqs:
--
-- IN PARAMETERS:
--  p_api_version_number            IN  NUMBER (Standard)
--  p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE (Standard)
--      p_check_access_flag             IN  VARCHAR2 (Standard - "Y"  by default) to verify the access.
--      p_resource_id                   IN  NUMBER (resource_id for which forecast needs to be collected
--      p_quota_id                      IN  NUMBER  (Plan Element ID )
--      p_period_name                   IN  VARCHAR2 ( period name as in OSO)
--      p_to_currency_code              IN  VARCHAR2 ( currency code in which you want to see the amounts)

-- OUT  PARAMETERS
--  x_return_status: (API standard)
--  x_msg_count: (API standard)
--  x_msg_data:  (API standard)
--  x_forecast_amount_tbl   - forecast out put for every sales category
--
-- Version: Current version 2.0
--
-- Note:
--   This API is supposed to be used by Sales Comp for Income planner for individual
--   when calling this api, user needs to pass in p_resource_id ,p_quota_id ,
--    p_period_name and p_to_currency_code
--
-- End of Comments

PROCEDURE Get_Forecast_Amounts (
    p_api_version_number            IN  NUMBER,
    p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE,
        p_check_access_flag             IN  VARCHAR2,
        p_resource_id                   IN  NUMBER,
        p_quota_id                      IN  NUMBER,
        p_period_name                   IN  VARCHAR2,
        p_to_currency_code              IN  VARCHAR2,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    x_forecast_amount_tbl           OUT NOCOPY FORECAST_TBL_TYPE);


END AS_SCN_FORECAST_PUB;


 

/
