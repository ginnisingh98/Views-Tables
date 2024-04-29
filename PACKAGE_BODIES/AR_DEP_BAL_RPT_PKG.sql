--------------------------------------------------------
--  DDL for Package Body AR_DEP_BAL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_DEP_BAL_RPT_PKG" 
-- $Header: AR_DEPBALRPT_PB.pls 120.0.12010000.2 2008/10/24 12:16:57 tthangav ship $
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--   Source control header
--
-- PROGRAM NAME
--  AR_DEP_BAL_RPT_PKG
--
-- DESCRIPTION
--  This script creates the package Body  of AR_DEP_BAL_RPT_PKG
--  This package is used to report on Deposit Balance Detail .
--
-- USAGE
--   To install       sqlplus <apps_user>/<apps_pwd> @AR_DEPBALRPT_PB.pls
--   To execute       sqlplus <apps_user>/<apps_pwd> AR_DEP_BAL_RPT_PKG
--
-- PROGRAM LIST       DESCRIPTION
--
-- DEPENDENCIES
--   None
--
-- CALLED BY
--   Deposit Balance Report - Japan.
--
-- LAST UPDATE DATE   14-Aug-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- ------------------------------------
-- Draft1A 27-Jul-2007 Rakesh Pulla     Initial Creation
-- Draft1B 13-Aug-2007 Rakesh Pulla     Incorporated the SO Review comments as per Ref # 28859
-- Draft1C 17-Oct-2008 Rakesh Pulla     Made changes to the function beforeReport tofix the Bug # 7439767
--************************************************************************
AS
FUNCTION beforeReport RETURN BOOLEAN
IS
BEGIN -- Beginning of the Function beforeReport .
  /* Query to get the ledger Id */
  BEGIN
    SELECT GLL.ledger_id
    INTO   gn_ledger_id
    FROM   gl_ledgers GLL
          ,gl_access_set_norm_assign GASNA
    WHERE  GASNA.access_set_id	 = FND_PROFILE.VALUE('GL_ACCESS_SET_ID')
    AND GLL.ledger_id		 = GASNA.ledger_id
    AND GLL.ledger_category_code  = 'PRIMARY';
  END;
  /*Query to get the Start date for a given Period From parameter */
  BEGIN
    SELECT GLP.start_date
    INTO gc_per_start_date
    FROM gl_periods GLP
	     ,gl_ledgers GLL
    WHERE GLL.ledger_id = gn_ledger_id
    AND GLP.period_set_name = GLL.period_set_name
    AND GLP.period_name = P_PERIOD_FROM;
  END;
  /*Query to get the End date for a given Period To parameter */
  BEGIN
    SELECT GLP.end_date
    INTO gc_per_end_date
    FROM gl_periods GLP
	     ,gl_ledgers GLL
    WHERE GLL.ledger_id = gn_ledger_id
    AND GLP.period_set_name = GLL.period_set_name
    AND GLP.period_name = P_PERIOD_TO;
  END;

  	IF p_customer_name IS NOT NULL THEN
	  gc_customer := 'AND HCA.cust_account_id = :P_CUSTOMER_NAME ';
	ELSE
	  gc_customer := 'AND 1=1';
	END IF;

	IF p_currency IS NOT NULL THEN
	  gc_currency := 'AND RCT.invoice_currency_code = :P_CURRENCY ';
	ELSE
	  gc_currency := 'AND 1=1';
	END IF;
	  RETURN TRUE;
END beforeReport; --End of the Function beforeReport

FUNCTION description(p_value IN VARCHAR2, p_segment IN VARCHAR2)
RETURN VARCHAR2
IS
lc_value_desc VARCHAR2(100);
BEGIN
  /* Query to get the Descriptions of the Segment values. */
  BEGIN
    IF p_segment LIKE '%SEGMENT%' THEN
      SELECT DISTINCT FFV.description
      INTO   lc_value_desc
      FROM   gl_code_combinations GCC
            ,fnd_id_flex_structures FFS
            ,fnd_id_flex_segments FSEG
            ,fnd_flex_values_vl   FFV
     WHERE   GCC.chart_of_accounts_id = FFS.id_flex_num
     AND     FFS.id_flex_num = FSEG.id_flex_num
     AND     FFS.id_flex_code = FSEG.id_flex_code
     AND     FSEG.application_column_name = p_segment
     AND     FSEG.flex_value_set_id = FFV.flex_value_set_id
     AND     FFS.id_flex_code = 'GL#'
     AND     GCC.chart_of_accounts_id = (SELECT GAS.chart_of_accounts_id
                       	             FROM   gl_access_sets GAS
                                     WHERE  GAS.access_set_id = FND_PROFILE.value('GL_ACCESS_SET_ID'))
       AND FFV.flex_value = p_value;
    ELSE
	   /* Query to get the Descriptions of the Attribute values. */
      SELECT FFV.description
      INTO   lc_value_desc
      FROM   fnd_descr_flex_col_usage_vl FDFCU
            ,fnd_flex_values_vl          FFV
      WHERE  FDFCU.flex_value_set_id = FFV.flex_value_set_id
      AND    FDFCU.application_id = 222
      AND    FDFCU.descriptive_flexfield_name = 'RA_CUSTOMER_TRX'
      AND    FDFCU.descriptive_flex_context_code ='Global Data Elements'
      AND    FDFCU.application_column_name = p_segment
      AND    FFV.flex_value  = p_value;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      lc_value_desc := NULL;
  END;
  RETURN lc_value_desc;
END description;


FUNCTION commitment_balance( p_customer_trx_id IN NUMBER) RETURN NUMBER
IS
    ln_commitment_bal       NUMBER;
    ln_carrying_bal         NUMBER;
	ln_invoice_bal          NUMBER;
	ln_deposit_cancel       NUMBER;
BEGIN
   BEGIN  /*Query to find the Balances for the given Customer Trx Id */
	 SELECT NVL(RCTL.extended_amount,0)
	 INTO   ln_commitment_bal
	 FROM   hz_cust_accounts          HCA
	        ,ra_customer_trx_lines    RCTL
			,ra_customer_trx          RCT
			,ra_cust_trx_types        RCTT
	 WHERE  RCT.customer_trx_id      = p_customer_trx_id
	 AND    RCT.cust_trx_type_id     = RCTT.cust_trx_type_id
	 AND    RCT.org_id               = RCTT.org_id
	 AND    RCT.customer_trx_id      = RCTL.customer_trx_id
	 AND    RCT.bill_to_customer_id  = HCA.cust_account_id
	 AND    RCTT.type                = 'DEP'
	 ORDER BY RCT.trx_number;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	    RETURN( NULL );
     WHEN TOO_MANY_ROWS THEN
	    RETURN(NULL);
   END;

  BEGIN
    SELECT NVL( ln_commitment_bal, 0) - (NVL(SUM( ARA.AMOUNT),0) * -1)
    INTO   ln_invoice_bal
    FROM   ra_customer_trx              RCT
          ,ra_cust_trx_line_gl_dist_all RCTD
          ,ra_cust_trx_types_all        RCTT
          ,hz_cust_accounts             HCA
          ,hz_parties                   HZP
          ,gl_code_combinations         GCC
          ,ar_adjustments_all           ARA
          ,ar_distributions_all         ARD
    WHERE RCT.initial_customer_trx_id  = p_customer_trx_id
    AND   RCTD.customer_trx_id         = RCT.customer_trx_id
    AND   RCT.customer_trx_id          = DECODE(RCTT.type, 'INV', ARA.customer_trx_id,
                                        'CM', ARA.subsequent_trx_id)
    AND   RCT.cust_trx_type_id         = RCTT.cust_trx_type_id
    AND   RCT.org_id                   = RCTT.org_id
    AND   RCT.bill_to_customer_id      = HCA.cust_account_id
    AND   HCA.party_id                 = HZP.party_id
    AND   ARD.code_combination_id      = GCC.code_combination_id
    AND   ARA.gl_date                  < gc_per_start_date
    AND   ARA.adjustment_id             = ARD.source_id
    AND   ARD.source_table              = 'ADJ'
    AND   ARD.source_type               = 'REC'
    AND   RCTT.type                     IN ('INV','CM')
    AND   RCT.complete_flag             = 'Y'
    AND NVL( ARA.subsequent_trx_id, -111) = DECODE(RCTT.type, 'INV', -111,
                                        'CM', RCT.customer_trx_id)
    AND   RCTT.post_to_gl               = 'Y'
    AND   RCTD.account_class            = 'REC'
    AND   RCTD.latest_rec_flag          = 'Y';
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	    RETURN( NULL );
     WHEN TOO_MANY_ROWS THEN
	    RETURN(NULL);
  END;

  BEGIN
    SELECT NVL(SUM(APSA.amount_due_original),0)
	INTO ln_deposit_cancel
    FROM ar_payment_schedules_all  APSA
         ,ra_customer_trx_all      RCT
    WHERE RCT.previous_customer_trx_id=p_customer_trx_id
	AND APSA.gl_date < gc_per_start_date
    AND RCT.customer_trx_id=APSA.customer_trx_id
    AND APSA.class = 'CM';
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	    RETURN( NULL );
     WHEN TOO_MANY_ROWS THEN
	    RETURN(NULL);
  END;
    ln_carrying_bal:= ln_invoice_bal + ln_deposit_cancel;
    RETURN(ln_carrying_bal);

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END commitment_balance;

END AR_DEP_BAL_RPT_PKG;

/
