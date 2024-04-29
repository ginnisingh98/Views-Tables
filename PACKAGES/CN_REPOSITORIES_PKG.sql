--------------------------------------------------------
--  DDL for Package CN_REPOSITORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_REPOSITORIES_PKG" AUTHID CURRENT_USER AS
-- $Header: cnrepos.pls 120.1 2005/11/22 00:59 raramasa noship $

  --+
  -- Procedure Name
  --   LOAD_SEED_ROW
  -- Purpose
  --   Upload a new Record into the table
  -- History
  --+


PROCEDURE LOAD_SEED_ROW (
	x_UPLOAD_MODE in varchar2,
        x_REPOSITORY_ID in varchar2,
	x_VERSION in varchar2,
	x_SCHEMA in varchar2,
	x_STATUS in varchar2,
	x_APPLICATION_TYPE in varchar2,
	x_LAST_UPDATE_DATE in varchar2,
	x_LAST_UPDATED_BY in varchar2,
	x_CREATION_DATE in varchar2,
	x_CREATED_BY in varchar2,
	x_LAST_UPDATE_LOGIN in varchar2,
	x_DESCRIPTION in varchar2,
	x_DATABASE_LINK  in varchar2,
	x_USAGE_FLAG in varchar2,
	x_EMAIL_OWNER in varchar2,
	x_EMAIL_DBA in varchar2,
	x_CURRENT_PERIOD_ID in varchar2,
	x_SYSTEM_START_DATE in varchar2,
	x_SYSTEM_START_PERIOD_ID in varchar2,
	x_SYSTEM_END_DATE in varchar2,
	x_SYSTEM_END_PERIOD_ID in varchar2,
	x_REV_CLASS_HIERARCHY_ID in varchar2,
	x_SRP_ROLLUP_HIERARCHY_ID in varchar2,
	x_SYSTEM_BATCH_SIZE in varchar2,
	x_TRANSFER_BATCH_SIZE in varchar2,
	x_SRP_ROLLUP_FLAG in varchar2,
	x_SET_OF_BOOKS_ID in varchar2,
	x_CURRENT_PERIOD in varchar2,
	x_SYSTEM_START_PERIOD in varchar2,
	x_SYSTEM_END_PERIOD in varchar2,
	x_CLAWBACK_GRACE_DAYS in varchar2,
	x_TRX_ROLLUP_METHOD in varchar2,
	x_SRP_BATCH_SIZE in varchar2,
	x_NAME in varchar2,
	x_APPLICATION_ID in varchar2,
	x_REPOSITORY_TYPE in varchar2,
	x_ORG_ID in varchar2,
	x_CLS_PACKAGE_SIZE in varchar2,
	x_SALESREP_BATCH_SIZE in varchar2,
	x_LATEST_PROCESSED_DATE in varchar2,
	x_PERIOD_SET_ID in varchar2,
	x_PERIOD_TYPE_ID in varchar2,
	x_PAYABLES_FLAG in varchar2,
	x_PAYROLL_FLAG in varchar2,
	x_PAYABLES_CCID_LEVEL in varchar2,
	x_INCOME_PLANNER_DISCLAIMER in varchar2,
	x_OBJECT_VERSION_NUMBER in varchar2,
	x_SECURITY_GROUP_ID in varchar2,
	x_SCA_MAPPING_STATUS in varchar2,
	x_CN_ROLL_SUM_TRX in varchar2,
	x_CN_CUSTOM_AGGR_TRX in varchar2,
	x_CN_PRIOR_ADJUSTMENT in varchar2,
	x_CN_COMM_RATE_PRECISION in varchar2,
	x_CN_CONVERSION_TYPE in varchar2,
	x_CN_CUSTOM_FLAG in varchar2,
	x_CN_COLLECT_ON_ACCT_CREDITS in varchar2,
	x_CN_RAM_NEGATE in varchar2,
	x_CN_REPORTING_HIERARCHY in varchar2,
	x_CN_NON_REVENUE_SPLIT in varchar2,
	x_CN_RESET_ERROR_TRX in varchar2,
	x_CN_CUST_DISCLAIMER in varchar2,
	x_CN_DISPLAY_DRAW in varchar2,
        x_APPLICATION_SHORT_NAME in varchar2,
        x_OWNER in varchar2
    );


    --+
  -- Procedure Name
  --   LOAD_ROW
  -- Purpose
  --   Upload a new Record into the table
  -- History
  --+


PROCEDURE LOAD_ROW (
        x_REPOSITORY_ID in varchar2,
	x_VERSION in varchar2,
	x_SCHEMA in varchar2,
	x_STATUS in varchar2,
	x_APPLICATION_TYPE in varchar2,
	x_LAST_UPDATE_DATE in varchar2,
	x_LAST_UPDATED_BY in varchar2,
	x_CREATION_DATE in varchar2,
	x_CREATED_BY in varchar2,
	x_LAST_UPDATE_LOGIN in varchar2,
	x_DESCRIPTION in varchar2,
	x_DATABASE_LINK  in varchar2,
	x_USAGE_FLAG in varchar2,
	x_EMAIL_OWNER in varchar2,
	x_EMAIL_DBA in varchar2,
	x_CURRENT_PERIOD_ID in varchar2,
	x_SYSTEM_START_DATE in varchar2,
	x_SYSTEM_START_PERIOD_ID in varchar2,
	x_SYSTEM_END_DATE in varchar2,
	x_SYSTEM_END_PERIOD_ID in varchar2,
	x_REV_CLASS_HIERARCHY_ID in varchar2,
	x_SRP_ROLLUP_HIERARCHY_ID in varchar2,
	x_SYSTEM_BATCH_SIZE in varchar2,
	x_TRANSFER_BATCH_SIZE in varchar2,
	x_SRP_ROLLUP_FLAG in varchar2,
	x_SET_OF_BOOKS_ID in varchar2,
	x_CURRENT_PERIOD in varchar2,
	x_SYSTEM_START_PERIOD in varchar2,
	x_SYSTEM_END_PERIOD in varchar2,
	x_CLAWBACK_GRACE_DAYS in varchar2,
	x_TRX_ROLLUP_METHOD in varchar2,
	x_SRP_BATCH_SIZE in varchar2,
	x_NAME in varchar2,
	x_APPLICATION_ID in varchar2,
	x_REPOSITORY_TYPE in varchar2,
	x_ORG_ID in varchar2,
	x_CLS_PACKAGE_SIZE in varchar2,
	x_SALESREP_BATCH_SIZE in varchar2,
	x_LATEST_PROCESSED_DATE in varchar2,
	x_PERIOD_SET_ID in varchar2,
	x_PERIOD_TYPE_ID in varchar2,
	x_PAYABLES_FLAG in varchar2,
	x_PAYROLL_FLAG in varchar2,
	x_PAYABLES_CCID_LEVEL in varchar2,
	x_INCOME_PLANNER_DISCLAIMER in varchar2,
	x_OBJECT_VERSION_NUMBER in varchar2,
	x_SECURITY_GROUP_ID in varchar2,
	x_SCA_MAPPING_STATUS in varchar2,
	x_CN_ROLL_SUM_TRX in varchar2,
	x_CN_CUSTOM_AGGR_TRX in varchar2,
	x_CN_PRIOR_ADJUSTMENT in varchar2,
	x_CN_COMM_RATE_PRECISION in varchar2,
	x_CN_CONVERSION_TYPE in varchar2,
	x_CN_CUSTOM_FLAG in varchar2,
	x_CN_COLLECT_ON_ACCT_CREDITS in varchar2,
	x_CN_RAM_NEGATE in varchar2,
	x_CN_REPORTING_HIERARCHY in varchar2,
	x_CN_NON_REVENUE_SPLIT in varchar2,
	x_CN_RESET_ERROR_TRX in varchar2,
	x_CN_CUST_DISCLAIMER in varchar2,
	x_CN_DISPLAY_DRAW in varchar2,
        x_APPLICATION_SHORT_NAME in varchar2,
        x_OWNER in varchar2
    );



END cn_repositories_pkg;
 

/
