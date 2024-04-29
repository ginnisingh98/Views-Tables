--------------------------------------------------------
--  DDL for Package Body XLA_TP_SUMMARY_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TP_SUMMARY_RPT_PKG" 
-- $Header: XLA_TPSUMRPT_PB.pls 120.4.12000000.1 2007/10/23 12:57:20 sgudupat noship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|     XLA_TPSUMRPT_PB.pls                                                    |
|                                                                            |
| PACKAGE NAME                                                               |
|     XLA_TP_SUMMARY_RPT_PKG                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     Package Body. This provides XML extract for Trading Partner            |
|     Summary Report                                                         |
|                                                                            |
| HISTORY                                                                    |
|     05/06/2007  Rakesh Pulla        Created                                |
|     18/09/2007  Rakesh Pulla        Modified the code as it has an impact  |
|                                     on the new parameter added             |
|                                     (Third Party type)                     |
|     09/10/2007  Rakesh Pulla        Changes incorporated according to the  |
|                                     Bug # 6401736 and 6460402              |
|     12/10/2007  Rakesh Pulla        Added the functions min_period         |
|                                                       & max_period         |
|                                                                            |
+===========================================================================*/
AS
FUNCTION beforeReport RETURN BOOLEAN
IS
	C_NULL_PARTY_COLS CONSTANT   VARCHAR2(1000):= ',NULL  PARTY_ID
                                                  ,NULL  PARTY_NUMBER
                                                  ,NULL  PARTY_NAME
                                                  ,NULL  PARTY_SITE_ID
                                                  ,NULL  PARTY_SITE_NUMBER
                                                  ,NULL  PARTY_SITE_TAX_REGS_NUMBER';
	C_NULL_PARTY_GROUP CONSTANT VARCHAR2(1000):= ',NULL
                                                  ,NULL
                                                  ,NULL
                                                  ,NULL
                                                  ,NULL
                                                  ,NULL';

BEGIN -- Begining of the Function  beforereport

-- following will set the right transaction security.
     XLA_SECURITY_PKG.set_security_context(P_RESP_APPLICATION_ID);
	/* Query to select the Period Start Date  and Period End Date */
	BEGIN
	    SELECT
	      MAX(CASE GP.period_name WHEN P_PERIOD_FROM THEN
	      TO_DATE(TO_CHAR(GP.start_date,'DD-MON-YYYY')
	      ||' 00:00:00','DD-MM-YYYY HH24:MI:SS')  END)
	      ,MAX(CASE GP.period_name WHEN P_PERIOD_TO THEN
	      TO_DATE(TO_CHAR(GP.end_date,'DD-MON-YYYY')
	      ||' 23:59:59','DD-MM-YYYY HH24:MI:SS') END)
	    INTO P_PERIOD_START_DATE,P_PERIOD_END_DATE
	    FROM gl_periods  GP
	         ,gl_ledgers  GLL
	    WHERE GLL.ledger_id=P_LEDGER_ID
	    AND GP.period_set_name =GLL.period_set_name
	    AND GP.period_name IN (P_PERIOD_FROM,P_PERIOD_TO);
	END;
	/* Query to select the ledger name and the ledger currency.*/
	BEGIN
	    SELECT currency_code
	    INTO P_LEDGER_CURRENCY
        FROM gl_ledgers_public_v
	    WHERE ledger_id=P_LEDGER_ID;
    END;
	/* Query to fetch the Effective period number from */
	BEGIN
	    SELECT effective_period_num
	    INTO P_PERIOD_NUM_FROM
        FROM gl_period_statuses GPS
        WHERE GPS.period_name=P_PERIOD_FROM
        AND  GPS.application_id=101
        AND  GPS.ledger_id=P_LEDGER_ID;
	END;
	/* Query to fetch the Effective period number to */
	BEGIN
	    SELECT effective_period_num
	    INTO P_PERIOD_NUM_TO
        FROM gl_period_statuses GPS
        WHERE GPS.period_name=P_PERIOD_TO
        AND  GPS.application_id=101
        AND  GPS.ledger_id=P_LEDGER_ID;
	END;

  /* Removed in order to fix the issues in Bug # 6401736  */
	/* Query to fetch the Period From which exist in the Control Balances Table.
	BEGIN
	    SELECT period_name
        INTO P_AC_PERIOD_FROM
        FROM gl_period_statuses
	    WHERE effective_period_num=(
                SELECT MIN(GPS.effective_period_num)
                FROM gl_period_statuses GPS, xla_control_balances XCB
                WHERE GPS.effective_period_num BETWEEN P_PERIOD_NUM_FROM
                AND P_PERIOD_NUM_TO
                AND  XCB.period_name=GPS.period_name
                AND  XCB.ledger_id=GPS.ledger_id
                AND  XCB.application_id=GPS.application_id
                AND  GPS.application_id=P_RESP_APPLICATION_ID
                AND  GPS.ledger_id=P_LEDGER_ID)
        AND  ledger_id=P_LEDGER_ID
        AND  application_id=P_RESP_APPLICATION_ID;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	      fnd_file.put_line (fnd_file.LOG, 'The given Period From does not exist in the xla_control_balances table');
	END;   */

	/* Query to fetch the Period To which exist in the Control Balances Table.
	BEGIN
	    SELECT period_name
        INTO P_AC_PERIOD_TO
        FROM gl_period_statuses
	    WHERE effective_period_num=(
                SELECT MAX(GPS.effective_period_num)
                FROM gl_period_statuses GPS, xla_control_balances XCB
                WHERE GPS.effective_period_num
	            BETWEEN P_PERIOD_NUM_FROM
                AND P_PERIOD_NUM_TO
                AND  XCB.period_name=GPS.period_name
                AND  XCB.ledger_id=GPS.ledger_id
                AND  XCB.application_id=GPS.application_id
                AND  GPS.application_id=P_RESP_APPLICATION_ID
                AND  GPS.ledger_id=P_LEDGER_ID)
        AND  ledger_id=P_LEDGER_ID
        AND  application_id=P_RESP_APPLICATION_ID;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	     fnd_file.put_line (fnd_file.LOG, 'The given Period To does not exist in the xla_control_balances table');
	END;	*/
	/* Third party information based on application_id */
	    IF P_PARTY_TYPE = 'SUPPLIER' THEN
                p_party_col := ',APS.vendor_id PARTY_ID
				                ,APS.segment1 PARTY_NUMBER
                                ,APS.vendor_name PARTY_NAME
                                ,NVL(APSSA.vendor_site_id,-999) PARTY_SITE_ID
                                ,HPS.party_site_number PARTY_SITE_NUMBER';

				p_party_group := ',APS.vendor_id
				                   ,APS.segment1
                                   ,APS.vendor_name
                                   ,NVL(APSSA.vendor_site_id,-999)
                                   ,HPS.party_site_number';

                p_party_tab := ',ap_suppliers APS
                                 ,ap_supplier_sites_all APSSA';


                p_party_join := ' AND  APS.vendor_id = XCB.party_id
				                  AND HZP.party_id = APS.party_id
								  AND  APSSA.vendor_site_id(+) = XCB.party_site_id
								  AND  HPS.party_site_id(+) = APSSA.party_site_id
                                  AND XCB.party_type_code = ''S''';


                IF (P_THIRD_PARTY_FROM IS NOT NULL) AND (P_THIRD_PARTY_TO IS NOT NULL) THEN
							p_party_name_join:= ' AND UPPER(APS.vendor_name) BETWEEN UPPER(:P_THIRD_PARTY_FROM)
							                                  AND UPPER(:P_THIRD_PARTY_TO) ';
					ELSIF (P_THIRD_PARTY_FROM IS NULL) AND (P_THIRD_PARTY_TO IS NOT NULL) THEN
					        p_party_name_join:= ' AND UPPER(APS.vendor_name) <= UPPER(:P_THIRD_PARTY_TO) ';
					ELSIF (P_THIRD_PARTY_FROM IS NOT NULL) AND (P_THIRD_PARTY_TO IS NULL) THEN
					        p_party_name_join:= ' AND UPPER(APS.vendor_name) >= UPPER(:P_THIRD_PARTY_FROM) ';
					ELSIF (P_THIRD_PARTY_FROM IS NULL) AND (P_THIRD_PARTY_TO IS NULL) THEN
					        p_party_name_join:= ' AND 1=1 ';
				END IF;

                IF P_THIRD_PARTY_TYPE IS NOT NULL THEN
					        p_party_join:= p_party_join || ' AND APS.vendor_type_lookup_code = :P_THIRD_PARTY_TYPE';
				END IF;

        ELSIF P_PARTY_TYPE = 'CUSTOMER' THEN
	            p_party_col :=     ',HCA.cust_account_id PARTY_ID
						            ,HCA.account_number PARTY_NUMBER
                                    ,HZP.party_name PARTY_NAME
                                    ,NVL(HZCU.site_use_id, -999) PARTY_SITE_ID
                                    ,HPS.party_site_number PARTY_SITE_NUMBER';

				p_party_group :=    ',HCA.cust_account_id
						             ,HCA.account_number
                                     ,HZP.party_name
                                     ,NVL(HZCU.site_use_id, -999)
                                     ,HPS.party_site_number';

	            p_party_tab :=      ',hz_cust_accounts HCA
                                     ,hz_cust_acct_sites_all HCAS
									 ,hz_cust_site_uses_all  HZCU';

	            p_party_join :=     ' AND HZP.party_id = HCA.party_id
						              AND HCA.cust_account_id = XCB.party_id
									  AND HZCU.site_use_id(+) = XCB.party_site_id
									  AND HCAS.cust_acct_site_id(+) = HZCU.cust_acct_site_id
                                      AND XCB.party_type_code = ''C''
                                      AND  HPS.party_site_id(+) = HCAS.party_site_id';


					IF (P_THIRD_PARTY_FROM IS NOT NULL) AND (P_THIRD_PARTY_TO IS NOT NULL) THEN
							p_party_name_join:= ' AND UPPER(HZP.party_name) BETWEEN UPPER(:P_THIRD_PARTY_FROM)
							                                  AND UPPER(:P_THIRD_PARTY_TO) ';
					    ELSIF (P_THIRD_PARTY_FROM IS NULL) AND (P_THIRD_PARTY_TO IS NOT NULL) THEN
					        p_party_name_join:= ' AND UPPER(HZP.party_name) <= UPPER(:P_THIRD_PARTY_TO) ';
					    ELSIF (P_THIRD_PARTY_FROM IS NOT NULL) AND (P_THIRD_PARTY_TO IS NULL) THEN
					        p_party_name_join:= ' AND UPPER(HZP.party_name) >= UPPER(:P_THIRD_PARTY_FROM) ';
						ELSIF (P_THIRD_PARTY_FROM IS NULL) AND (P_THIRD_PARTY_TO IS NULL) THEN
					        p_party_name_join:= ' AND 1=1 ';
					END IF;

                    IF P_THIRD_PARTY_TYPE IS NOT NULL THEN
					        p_party_join:= p_party_join || ' AND HCA.customer_class_code = :P_THIRD_PARTY_TYPE';
					END IF;

	    ELSE
                p_party_col   := C_NULL_PARTY_COLS;
				p_party_group := C_NULL_PARTY_GROUP;
     END IF;

	IF P_PERIOD_START_DATE = P_ACCOUNT_DATE_FROM THEN
	    P_BEG_DATE_RANGE:= 'SELECT  0  beg_date_range_act_dr
		                             ,0  beg_date_range_act_cr
                            FROM SYS.DUAL ';
	ELSE
	    P_BEG_DATE_RANGE:= 'SELECT   NVL(SUM(XAL.accounted_dr),0) beg_date_range_act_dr
		                             ,NVL(SUM(XAL.accounted_cr),0) beg_date_range_act_cr
                            FROM xla_ae_lines  XAL
                            WHERE  XAL.party_id= :party_id
		                    AND XAL.party_site_id= :party_site_id
		                    AND XAL.application_id= :P_RESP_APPLICATION_ID
	                        AND XAL.ledger_id= :P_LEDGER_ID
	                        AND XAL.code_combination_id= :code_combination_id
		                    AND XAL.control_balance_flag=''Y''
		                    AND XAL.accounting_date >= :P_PERIOD_START_DATE
		                    AND XAL.accounting_date < :P_ACCOUNT_DATE_FROM  ';
	END IF;
	IF P_PERIOD_END_DATE = P_ACCOUNT_DATE_TO THEN
	    P_PER_DATE_RANGE:= 'SELECT  0  per_date_range_act_dr
		                             ,0  per_date_range_act_cr
                             FROM SYS.DUAL ';
	ELSE
	    P_PER_DATE_RANGE:= 'SELECT  NVL(SUM(XAL.accounted_dr),0)  per_date_range_act_dr
		                             ,NVL(SUM(XAL.accounted_cr),0) per_date_range_act_cr
                             FROM xla_ae_lines   XAL
                             WHERE XAL.party_id= :party_id
                             AND XAL.party_site_id= :party_site_id
                             AND XAL.application_id= :P_RESP_APPLICATION_ID
                             AND XAL.ledger_id= :P_LEDGER_ID
                             AND XAL.code_combination_id= :code_combination_id
                             AND XAL.control_balance_flag=''Y''
                             AND XAL.accounting_date > :P_ACCOUNT_DATE_TO
                             AND XAL.accounting_date <= :P_PERIOD_END_DATE ';
	END IF;
	    RETURN (TRUE);
END beforeReport; -- End of the beforereport

FUNCTION min_period( p_period_num IN NUMBER) RETURN NUMBER
IS
    ln_actual_per_num  NUMBER;
BEGIN
 /*Query to find the minimum period existing in the control balances table */
	            SELECT MIN(p_period_num)
	            INTO ln_actual_per_num
                FROM gl_period_statuses GPS
                WHERE GPS.effective_period_num
	            BETWEEN P_PERIOD_NUM_FROM
                AND P_PERIOD_NUM_TO
				AND  GPS.application_id=P_RESP_APPLICATION_ID
                AND  GPS.ledger_id=P_LEDGER_ID;

				RETURN(ln_actual_per_num);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	    RETURN(NULL);
     WHEN TOO_MANY_ROWS THEN
	    RETURN(NULL);
     WHEN OTHERS THEN
        RAISE;
END min_period;

FUNCTION max_period( p_period_num IN NUMBER) RETURN NUMBER
IS
    ln_actual_per_num  NUMBER;
BEGIN
  /*Query to find the maximum period existing in the control balances table */
	            SELECT MAX(p_period_num)
	            INTO ln_actual_per_num
                FROM gl_period_statuses GPS
                WHERE GPS.effective_period_num
	            BETWEEN P_PERIOD_NUM_FROM
                AND P_PERIOD_NUM_TO
				AND  GPS.application_id=P_RESP_APPLICATION_ID
                AND  GPS.ledger_id=P_LEDGER_ID;

				RETURN(ln_actual_per_num);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	    RETURN(NULL);
     WHEN TOO_MANY_ROWS THEN
	    RETURN(NULL);
     WHEN OTHERS THEN
        RAISE;
END max_period;
END XLA_TP_SUMMARY_RPT_PKG ;

/
