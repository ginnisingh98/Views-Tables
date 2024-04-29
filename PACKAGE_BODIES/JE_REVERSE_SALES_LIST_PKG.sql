--------------------------------------------------------
--  DDL for Package Body JE_REVERSE_SALES_LIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_REVERSE_SALES_LIST_PKG" AS
/*$Header: jeukrslrb.pls 120.6 2008/04/15 13:54:07 ashdas noship $*/
--------------------------------------------------------------------------------
--Global Variables
--------------------------------------------------------------------------------
g_current_runtime_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
g_level_statement     	CONSTANT NUMBER := fnd_log.level_statement;
g_level_procedure    	CONSTANT NUMBER := fnd_log.level_procedure;
g_level_event        	CONSTANT NUMBER := fnd_log.level_event;
g_level_exception     	CONSTANT NUMBER := fnd_log.level_exception;
g_level_error         	CONSTANT NUMBER := fnd_log.level_error;
g_level_unexpected    	CONSTANT NUMBER := fnd_log.level_unexpected;
--------------------------------------------------------------------------------
--Private Methods Declaration
--------------------------------------------------------------------------------
--PUBLIC Methods
--------------------------------------------------------------------------------
/*===========================================================================+
 | FUNCTION                                                                  |
 |   beforeReport()                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function 	 						     |
 |     (1) Is called from the Before Report Trigger of CP Reverse Charge     |
 |         Sales Listing Report                                              |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date          Author          Description                                |
 |  ============  ==============  =================================          |
 |  18-DEC-2007   Ashanka Das     Initial  Version.                          |
 |  10-APR-2008   Ashanka Das     Modified the code in c_period_range        |
 |  15-APR-2008   Ashanka Das     Modified the code in query fetching the    |
 |                                sales amount.
 +===========================================================================*/
FUNCTION beforeReport RETURN BOOLEAN
AS
ln_sales_amount NUMBER;
ln_total_sales  NUMBER;
lv_dynamic_sales VARCHAR2(4000);
ld_from_date DATE;
ld_to_date DATE;
lv_cust_vat_reg_num VARCHAR2(30);
CURSOR c_period_range IS
  SELECT ADD_MONTHS(TO_DATE(P_FROM_DATE,'YYYY/MM/DD HH24:MI:SS'),ROWNUM-1) PERIOD
  FROM  fnd_application
  WHERE ROWNUM <=DECODE( ROUND(MONTHS_BETWEEN(TRUNC(TO_DATE(P_TO_DATE,'YYYY/MM/DD HH24:MI:SS')),
	                               TRUNC(TO_DATE(P_FROM_DATE,'YYYY/MM/DD HH24:MI:SS')))),0,1, ROUND(MONTHS_BETWEEN(TRUNC(TO_DATE(P_TO_DATE,'YYYY/MM/DD HH24:MI:SS')),
	                               TRUNC(TO_DATE(P_FROM_DATE,'YYYY/MM/DD HH24:MI:SS')))));
CURSOR c_customers IS
  SELECT
    DISTINCT ctrx.bill_to_customer_id CUSTOMER_ID,
    hca.account_number CUSTOMER_NUMBER,
    hp.party_name CUSTOMER_NAME,
    zl.tax_registration_number CUST_VAT_REG_NUM
      FROM
      hz_cust_accounts hca,
      hz_parties hp,
      ra_customer_trx_all ctrx,
      zx_lines zl
       WHERE ctrx.legal_entity_id = P_LEGAL_ENTITY
          AND ctrx.complete_flag = 'Y'
	  AND TRUNC(ctrx.trx_date) BETWEEN TRUNC(TO_DATE(P_FROM_DATE,'YYYY/MM/DD HH24:MI:SS'))
          AND TRUNC(TO_DATE(P_TO_DATE,'YYYY/MM/DD HH24:MI:SS'))
	  AND ctrx.bill_to_customer_id = hca.cust_account_id
	  AND hca.party_id = hp.party_id
	  AND zl.trx_id = ctrx.customer_trx_id
          AND zl.hq_estb_reg_number = P_TAX_REG_NUM
          AND zl.legal_entity_id = P_LEGAL_ENTITY
          AND zl.application_id = 222
	    ORDER BY CUSTOMER_NAME;
BEGIN
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','Start FUNCTION beforeReport');
	FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','Parameters are :');
	FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','	P_LEGAL_ENTITY ='||P_LEGAL_ENTITY);
	FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','	P_TAX_REG_NUM  ='||P_TAX_REG_NUM);
	FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','	P_FROM_DATE    ='||P_FROM_DATE);
	FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','	P_TO_DATE      ='||P_TO_DATE);
  END IF;
  FOR rec_customers IN c_customers LOOP
    lv_dynamic_sales := 'EMPTY';
    ln_total_sales := 0;
    lv_cust_vat_reg_num :=  NVL(SUBSTR(rec_customers.CUST_VAT_REG_NUM,3,LENGTH(rec_customers.CUST_VAT_REG_NUM)),-99);
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','In Cursor c_customers');
      FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','CUSTOMER_ID'||rec_customers.CUSTOMER_ID);
      FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','CUSTOMER_NUMBER'||rec_customers.CUSTOMER_NUMBER);
      FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','CUSTOMER_NAME'||rec_customers.CUSTOMER_NAME);
      FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','CUST_VAT_REG_NUM'||rec_customers.CUST_VAT_REG_NUM);
    END IF;
    FOR rec_period_range IN c_period_range LOOP
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','Period Range:'||rec_period_range.PERIOD);
      END IF;
      ln_sales_amount := 0;
      IF TO_CHAR(TO_DATE(P_FROM_DATE,'YYYY/MM/DD HH24:MI:SS'),'Mon-YYYY')= TO_CHAR(rec_period_range.PERIOD,'Mon-YYYY') THEN
        ld_from_date := TO_DATE(P_FROM_DATE,'YYYY/MM/DD HH24:MI:SS');
      ELSE
        ld_from_date :=rec_period_range.PERIOD;
      END IF;
      IF TO_CHAR(TO_DATE(P_TO_DATE,'YYYY/MM/DD HH24:MI:SS'),'Mon-YYYY')= TO_CHAR(rec_period_range.PERIOD,'Mon-YYYY') THEN
        ld_to_date := TO_DATE(P_TO_DATE,'YYYY/MM/DD HH24:MI:SS');
      ELSE
        ld_to_date := LAST_DAY(rec_period_range.PERIOD);
      END IF;
      IF(G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','From Date:'||ld_from_date);
        FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','To Date:'||ld_to_date);
      END IF;
      BEGIN
        SELECT ROUND(NVL(SUM(trx_lines.extended_amount),0))
          INTO ln_sales_amount
        FROM ra_customer_trx_all trx,
             ra_customer_trx_lines_all trx_lines,
             zx_lines lines,
	     ra_customer_trx_lines_all trx_tax_lines,
             zx_report_codes_assoc zrc,
	     zx_reporting_types_vl zrt
        WHERE trx_lines.line_type ='LINE'
	  AND trx_lines.customer_trx_id = trx.customer_trx_id
	  AND trx_tax_lines.line_type ='TAX'
          AND trx_lines.customer_trx_line_id = trx_tax_lines.link_to_cust_trx_line_id
          AND trx_tax_lines.customer_trx_id = trx.customer_trx_id
          AND trx.bill_to_customer_id = rec_customers.CUSTOMER_ID
          AND TRUNC(trx.trx_date) BETWEEN TRUNC(ld_from_date) AND TRUNC(ld_to_date)
          AND trx.legal_entity_id =P_LEGAL_ENTITY
          AND trx.complete_flag ='Y'
	  AND lines.trx_line_id = trx_lines.customer_trx_line_id
          AND lines.trx_id      = trx.customer_trx_id
          AND lines.hq_estb_reg_number =P_TAX_REG_NUM
          AND NVL(lines.tax_registration_number,-99) = NVL(rec_customers.CUST_VAT_REG_NUM,-99)
          AND lines.legal_entity_id =P_LEGAL_ENTITY
          AND lines.application_id =222
          AND trx_tax_lines.vat_tax_id = zrc.entity_id
	  AND zrc.reporting_type_id = zrt.reporting_type_id
	  AND DECODE(zrt.reporting_type_datatype_code,'TEXT',SUBSTR(UPPER(zrc.reporting_code_char_value),1,1),'YES_NO',zrc.reporting_code_char_value,'N') = 'Y' -- Not sure what kind of set up user will do
	  AND TRUNC(trx.trx_date) BETWEEN TRUNC(zrc.effective_from) AND TRUNC(NVL(zrc.effective_to,trx.trx_date))
          AND zrt.reporting_type_code ='REVERSE_CHARGE_VAT';
      EXCEPTION
      WHEN others THEN
      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
	FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','Exception in getting Sales Amount');
      END IF;
      ln_sales_amount := 0;
      END;
      IF lv_dynamic_sales = 'EMPTY' THEN
        lv_dynamic_sales := lv_cust_vat_reg_num||','||ln_sales_amount;
      ELSE
        lv_dynamic_sales := lv_dynamic_sales||','||ln_sales_amount;
      END IF;
      ln_total_sales := ln_total_sales + ln_sales_amount;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','Sales Amount'||TO_CHAR(ln_sales_amount));
      END IF;
      BEGIN
        INSERT INTO je_uk_sales_trx_gt
	(
        je_info_v1,--Identifier
	je_info_n1,--CustId
	je_info_v2,--CustNum
	je_info_v3,--CustName
	je_info_v4,--CustVATRegNum
	je_info_v5,--Mon-YYYY
	je_info_n2,--SalesAmt
	je_info_d1 --Date
	)
	VALUES
	(
	'CL',
	rec_customers.CUSTOMER_ID,
	rec_customers.CUSTOMER_NUMBER,
	rec_customers.CUSTOMER_NAME,
	lv_cust_vat_reg_num,
	TO_CHAR(rec_period_range.PERIOD,'Mon-YYYY'),
	ln_sales_amount,
	ld_from_date
	);
      EXCEPTION
      WHEN others THEN
      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','Exception in Inserting in GT for CL');
      END IF;
      END;
    END LOOP; -- End Loop rec_period_range
    IF ln_total_sales = 0 THEN
      DELETE je_uk_sales_trx_gt
        WHERE je_info_v1 = 'CL'
          AND je_info_n1 = rec_customers.CUSTOMER_ID
          AND je_info_v2 = rec_customers.CUSTOMER_NUMBER
	  AND je_info_v4 = lv_cust_vat_reg_num;
      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','In DELETE je_uk_sales_trx_gt');
      END IF;
    ELSE
      BEGIN
        INSERT INTO je_uk_sales_trx_gt
        (
        je_info_v1,
        je_info_v2
        )
        VALUES
        (
        'CS',
        lv_dynamic_sales
        );
        lv_dynamic_sales := 'EMPTY';
      EXCEPTION
      WHEN others THEN
        IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_EXCEPTION,'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','In INSERT je_uk_sales_trx_gt for type CS');
        END IF;
        NULL;
      END;
    END IF;
  END LOOP; --End Loop rec_customers
  IF(G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,'JE.plsql.JE_REVERSE_SALES_LIST_PKG.beforeReport','Exiting before Report');
  END IF;
  RETURN TRUE;
END beforeReport;
END JE_REVERSE_SALES_LIST_PKG;

/
