--------------------------------------------------------
--  DDL for Package PA_LABOR_SCH_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_LABOR_SCH_RULE_PKG" AUTHID CURRENT_USER as
-- $Header: PALABSRS.pls 115.2 2002/12/02 23:36:03 riyengar noship $

PROCEDURE insert_row (
	x_rowid                   IN OUT NOCOPY varchar2
 	,x_ORG_LABOR_SCH_RULE_ID    IN OUT NOCOPY number
 	,p_ORGANIZATION_ID          IN  number
 	,p_ORG_ID                   IN  number
 	,p_LABOR_COSTING_RULE       IN  varchar2
 	,p_COST_RATE_SCH_ID         IN  number
 	,p_OVERTIME_PROJECT_ID      IN  number
 	,p_OVERTIME_TASK_ID         IN  number
 	,p_ACCT_RATE_DATE_CODE      IN  varchar2
 	,p_ACCT_RATE_TYPE           IN  varchar2
 	,p_ACCT_EXCHANGE_RATE       IN  number
 	,p_START_DATE_ACTIVE        IN  DATE
 	,p_END_DATE_ACTIVE          IN  DATE
	,p_FORECAST_COST_RATE_SCH_ID IN  number
 	,p_CREATION_DATE            IN  DATE
 	,p_CREATED_BY               IN  number
 	,p_LAST_UPDATE_DATE         IN  DATE
 	,p_LAST_UPDATED_BY          IN  number
 	,p_LAST_UPDATE_LOGIN        IN  number
	,x_return_status            IN OUT NOCOPY varchar2
        ,x_error_msg_code           IN OUT NOCOPY varchar2
                      );
 PROCEDURE update_row
        (
         p_rowid                   IN  varchar2
        ,p_ORG_LABOR_SCH_RULE_ID    IN  number
        ,p_ORGANIZATION_ID          IN  number
        ,p_ORG_ID                   IN  number
        ,p_LABOR_COSTING_RULE       IN  varchar2
        ,p_COST_RATE_SCH_ID         IN  number
        ,p_OVERTIME_PROJECT_ID      IN  number
        ,p_OVERTIME_TASK_ID         IN  number
        ,p_ACCT_RATE_DATE_CODE      IN  varchar2
        ,p_ACCT_RATE_TYPE           IN  varchar2
        ,p_ACCT_EXCHANGE_RATE       IN  number
        ,p_START_DATE_ACTIVE        IN  DATE
        ,p_END_DATE_ACTIVE          IN  DATE
	,p_FORECAST_COST_RATE_SCH_ID IN  number
        ,p_CREATION_DATE            IN  DATE
        ,p_CREATED_BY               IN  number
        ,p_LAST_UPDATE_DATE         IN  DATE
        ,p_LAST_UPDATED_BY          IN  number
        ,p_LAST_UPDATE_LOGIN        IN  number
        ,x_return_status            IN OUT NOCOPY varchar2
        ,x_error_msg_code           IN OUT NOCOPY varchar2
                      );
 PROCEDURE  delete_row (p_ORG_LABOR_SCH_RULE_ID in NUMBER);

 PROCEDURE delete_row (x_rowid   in VARCHAR2);

 PROCEDURE lock_row (p_org_labor_sch_rule_id    in NUMBER);

END PA_LABOR_SCH_RULE_PKG;

 

/
