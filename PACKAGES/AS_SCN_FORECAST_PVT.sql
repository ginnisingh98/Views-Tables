--------------------------------------------------------
--  DDL for Package AS_SCN_FORECAST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SCN_FORECAST_PVT" AUTHID CURRENT_USER as
/* $Header: asxvpems.pls 115.6 2002/11/15 20:43:40 clwang ship $ */

-- Start of Comments
-- API name:   Get_Forecast_Amounts
-- Type: Private
-- Description:
--
-- Pre-reqs:
--
-- IN PARAMETERS:
--	p_api_version_number            IN  NUMBER (Standard)
--	p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE (Standard)
--      p_check_access_flag             IN  VARCHAR2 (Standard - "Y"  by default) to verify the access.
--      p_resource_id                   IN  NUMBER (resource_id for which forecast needs to be collected
--      p_quota_id                      IN  NUMBER  (Plan Element ID )
--      p_period_name                   IN  VARCHAR2 ( period name as in OSO)
--      p_to_currency_code              IN  VARCHAR2 ( currency code in which you want to see the amounts)

-- OUT  PARAMETERS
-- 	x_return_status: (API standard)
-- 	x_msg_count: (API standard)
--	x_msg_data:  (API standard)
--	x_forecast_amount_tbl   - forecast out put for every sales category
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
	x_forecast_amount_tbl           OUT NOCOPY AS_SCN_FORECAST_PUB.FORECAST_TBL_TYPE);


END AS_SCN_FORECAST_PVT;


 

/
