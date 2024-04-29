--------------------------------------------------------
--  DDL for Package Body FII_BUDGET_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_BUDGET_INTERFACE_PKG" AS
/* $Header: FIIBUINB.pls 120.10 2005/06/02 19:25:48 ilavenil noship $ */

  -- Purpose
  --   	This is the routine called by Web ADI for uploading records
  --    into FII_BUDGET_INTERFACE
  -- History
  --   	07-22-02	 S Kung	        Created
  -- Arguments
  --    All columns in the FII_BUDGET_INTERFACE table
  -- Example
  --    FII_BUDGET_INTERFACE.Web_Adi_Upload;
  -- Notes
  --
 FUNCTION Web_Adi_Upload
		( X_RowID		    IN	VARCHAR2 DEFAULT NULL,
		  X_Plan_Type		IN	VARCHAR2,
		  X_Version_Date    IN VARCHAR2 DEFAULT NULL,
		  X_Time_Period		IN	VARCHAR2 DEFAULT NULL,
		  X_Date		    IN	DATE DEFAULT NULL,
		  X_Company         IN  VARCHAR2 DEFAULT NULL,
          X_Cost_Center     IN  VARCHAR2 DEFAULT NULL,
		  X_CCC		    	IN	NUMBER DEFAULT NULL,
		  X_LOB		    	IN	VARCHAR2 DEFAULT NULL,
		  X_Acct	    	IN	VARCHAR2 DEFAULT NULL,
		  X_Fin_Item		IN	VARCHAR2 DEFAULT NULL,
		  X_Product		    IN	NUMBER DEFAULT NULL,
		  X_User_Defined_Dim IN VARCHAR2 DEFAULT NULL,
		  X_Prim_Amt		IN	NUMBER,
 		  X_Rate	    	IN	NUMBER DEFAULT NULL,
		  X_Sec_Amt	    	IN	NUMBER DEFAULT NULL,
		  X_Ledger          IN  NUMBER DEFAULT NULL
          ) return VARCHAR2  IS

      invalid_company EXCEPTION;
      invalid_cost_center EXCEPTION;
      invalid_account     EXCEPTION;
      invalid_user_defined EXCEPTION;
      invalid_sys_profile   EXCEPTION;
      l_sec_amt NUMBER;
      l_company NUMBER;
      l_cost_center NUMBEr;
      l_account NUMBER;
      l_user_defined_dim NUMBER;
      l_err_msg VARCHAR2(150);
BEGIN

--check for system profile FII_BUDGET_SOURCE = WEBADI
IF (fnd_profile.value('FII_BUDGET_SOURCE') = 'WEBADI') THEN
  -- If RowID is null, THEN new record to be inserted, else update.
  IF (X_RowID is NULL) THEN
    --if rate is a non zero value, THEN we compute secondary currency amount and overwrite the user
    --entered secondary currency amount.
    IF nvl(X_Rate,0) <> 0 THEN
       l_sec_amt := X_Prim_Amt * X_Rate;
    ELSE
       l_sec_amt := X_Sec_Amt;
    END IF;

       BEGIN
         SELECT  c.flex_value_id
         INTO l_company
         FROM FND_ID_FLEX_SEGMENTS a, FND_SEGMENT_ATTRIBUTE_VALUES b, fnd_flex_values c,
         fnd_flex_values_tl d
         WHERE a.ID_FLEX_CODE = 'GL#'
         AND   a.APPLICATION_ID = 101
         AND   a.ID_FLEX_NUM in (select chart_of_accounts_id from
                                  gl_ledgers_public_v where
                                  ledger_id = X_Ledger)
         AND   a.application_id = b.application_id
         AND   a.id_flex_code   = b.id_flex_code
         AND   a.id_flex_num    = b.id_flex_num
         AND   a.application_column_name = b.application_column_name
         AND   b.attribute_value = 'Y'
         AND   b.segment_attribute_type = ('GL_BALANCING')
         AND   a.flex_value_set_id = c.flex_value_set_id
         AND   c.flex_value_id  = d.flex_value_id
         AND   d.language = userenv('LANG')
         AND   c.summary_flag = 'N'
         AND   c.flex_value = X_Company;
       EXCEPTION
         WHEN others THEN
         RAISE invalid_company;
       END;

       BEGIN
         SELECT  c.flex_value_id
         INTO l_cost_center
         FROM FND_ID_FLEX_SEGMENTS a, FND_SEGMENT_ATTRIBUTE_VALUES b, fnd_flex_values c,
         fnd_flex_values_tl d
         WHERE a.ID_FLEX_CODE = 'GL#'
         AND   a.APPLICATION_ID = 101
         AND   a.ID_FLEX_NUM in (select chart_of_accounts_id from
                                 gl_ledgers_public_v  where
                                 ledger_id = X_Ledger)
         AND   a.application_id = b.application_id
         AND   a.id_flex_code   = b.id_flex_code
         AND   a.id_flex_num    = b.id_flex_num
         AND   a.application_column_name = b.application_column_name
         AND   b.attribute_value = 'Y'
         AND   b.segment_attribute_type = ('FA_COST_CTR')
         AND   a.flex_value_set_id = c.flex_value_set_id
         AND   c.flex_value_id  = d.flex_value_id
         AND   d.language = userenv('LANG')
         AND   c.summary_flag = 'N'
         AND   c.flex_value = X_Cost_Center;
       EXCEPTION
         WHEN others THEN
         RAISE invalid_cost_center;
       END;

       BEGIN
         SELECT  c.flex_value_id
         INTO l_account
         FROM FND_ID_FLEX_SEGMENTS a, FND_SEGMENT_ATTRIBUTE_VALUES b, fnd_flex_values c,
         fnd_flex_values_tl d
         WHERE a.ID_FLEX_CODE = 'GL#'
         AND   a.APPLICATION_ID = 101
         AND   a.ID_FLEX_NUM in (select chart_of_accounts_id from
                                 gl_ledgers_public_v where
                                 ledger_id = X_Ledger)
         AND   a.application_id = b.application_id
         AND   a.id_flex_code   = b.id_flex_code
         AND   a.id_flex_num    = b.id_flex_num
         AND   a.application_column_name = b.application_column_name
         AND   b.attribute_value = 'Y'
         AND   b.segment_attribute_type = ('GL_ACCOUNT')
         AND   a.flex_value_set_id = c.flex_value_set_id
         AND   c.flex_value_id  = d.flex_value_id
         AND   d.language = userenv('LANG')
         AND   c.flex_value = X_Fin_Item;
       EXCEPTION
         WHEN others THEN
         RAISE invalid_account;
       END;

       IF X_User_Defined_Dim is not null THEN
         BEGIN
            SELECT  f.flex_value_id
            INTO l_user_defined_dim
            FROM fnd_flex_values f, fnd_flex_values_tl t, fii_financial_dimensions ffd
            WHERE flex_value_set_id in
               (SELECT MASTER_VALUE_SET_ID id FROM fii_financial_dimensions
                 WHERE dimension_short_name = 'FII_USER_DEFINED_1'
                 UNION
                 SELECT map.flex_value_set_id1 id
                 FROM fii_dim_mapping_rules  map, fii_slg_assignments   sts, fii_source_ledger_groups slg,
                gl_ledgers_public_v sob
                 WHERE map.dimension_short_name   = 'FII_USER_DEFINED_1'
                 AND map.chart_of_accounts_id   = sts.chart_of_accounts_id
                 AND sts.source_ledger_group_id = slg.source_ledger_group_id
                 AND slg.usage_code = 'DBI'
                 AND sts.ledger_id = sob.ledger_id
                 AND sob.ledger_id = X_Ledger)
            AND f.flex_value_id = t.flex_value_id
            AND t.language = userenv('LANG')
            AND ffd.dimension_short_name = 'FII_USER_DEFINED_1'
            AND ffd.dbi_enabled_flag = 'Y'
            AND f.flex_value = X_User_Defined_Dim;
         EXCEPTION
           WHEN others THEN
           RAISE invalid_user_defined;
         END;
       END IF;

       INSERT INTO FII_BUDGET_INTERFACE
       (plan_type_code, prim_amount_g, report_time_period, report_date, version_date, sec_amount_g, conversion_rate,
       fin_item, fin_category_id, prod_category_id,  company, company_id,
       cost_center, cost_center_id, user_dim1, user_dim1_id, ledger_id)
       VALUES
       (X_Plan_Type, X_Prim_Amt, X_Time_Period, X_Date, to_date(X_Version_Date, 'DD-MM-YYYY'), l_sec_amt, X_Rate,
        X_Fin_Item, l_account, X_Product, X_Company, l_Company,
        X_Cost_Center, l_Cost_Center, X_User_Defined_Dim, l_User_Defined_Dim, X_Ledger);
  ELSE
        UPDATE FII_BUDGET_INTERFACE
        SET
	    plan_type_code		= X_Plan_Type,
    	prim_amount_g		= X_Prim_Amt,
	    report_time_period	= X_Time_Period,
    	report_date		= X_Date,
        fin_item            = X_Fin_Item,
    	fin_category_id		= l_account,
	    prod_category_id	= X_Product,
    	conversion_rate		= X_Rate,
	    sec_amount_g		= l_sec_amt,
	    company             = X_Company,
    	company_id          = l_Company,
    	cost_center         = X_Cost_Center,
	    cost_center_id      = l_Cost_Center,
    	version_date        = to_date(X_Version_Date, 'DD-MM-YYYY'),
    	User_Dim1           = X_User_Defined_Dim,
	    user_dim1_id = l_User_Defined_Dim,
    	ledger_id    = X_Ledger,
        status_code = null
        WHERE
	    rowid = chartorowid(X_RowID);

	--once user fixes the errored record and re-uploads, THEN it is essential that
	--all other residing VALIDATED records are to be set as status_code = null.
	--thus upload into base table program will process all of the records existing in
	--interface table and not just the error-fixed record.
	    UPDATE FII_BUDGET_INTERFACE
	    SET status_code = NULL;

  END IF;
ELSE
  RAISE invalid_sys_profile;
END IF;
return null;

EXCEPTION
  WHEN invalid_company THEN
  l_err_msg := fnd_message.get_string('FII','FII_EA_INVALID_COMPANY');
  return l_err_msg;

  WHEN invalid_cost_center THEN
  l_err_msg := fnd_message.get_string('FII','FII_EA_INVALID_COST_CENTER');
  return l_err_msg;

  WHEN invalid_account THEN
  l_err_msg := fnd_message.get_string('FII','FII_EA_INVALID_ACCOUNT');
  return l_err_msg;

  WHEN invalid_user_defined THEN
  l_err_msg := fnd_message.get_string('FII','FII_EA_INVALID_USR_DEFINED_DIM');
  return l_err_msg;

  WHEN invalid_sys_profile THEN
  l_err_msg := fnd_message.get_string('FII','FII_EA_INVALID_SYS_PROFILE');
  return l_err_msg;

  WHEN OTHERS THEN
  l_err_msg := fnd_message.get_string('FII', 'FII_EA_VALIDATOR_ERR');
  return l_err_msg;
END Web_Adi_Upload;

END FII_BUDGET_INTERFACE_PKG;


/
