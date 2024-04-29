--------------------------------------------------------
--  DDL for Package Body JG_ZZ_SUMMARY_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_SUMMARY_ALL_PKG" 
-- $Header: jgzzsummaryallb.pls 120.31.12010000.22 2010/02/05 07:29:39 pakumare ship $
-- +======================================================================+
-- | Copyright (c) 1996 Oracle Corporation Redwood Shores, California, USA|
-- |                       All rights reserved.                           |
-- +======================================================================+
-- NAME:        JG_ZZ_SUMMARY_ALL_PKG
--
-- DESCRIPTION: This Package is the default Package containing the Procedures
--              used by SUMMARY-ALL Extract
--
-- NOTES:
--
-- Change Record:
-- ===============
-- Version   Date        Author                 Remarks
-- =======  ===========  ====================  ===========================+
-- DRAFT 1A 04-Feb-2006  Balachander Ganesh     Initial draft version
-- DRAFT 1B 21-Feb-2006  Balachander Ganesh     Updated with Review
--                                              comments from IDC
-- DRAFT 1C 22-Feb-2006  Suresh Pasupunuri      Included the code for RTP
-- DRAFT 1C 27-Feb-2006  Suresh Pasupunuri      sum_fixedformula,
--                                              sum_other_formula,
--                                              cf_total_vat_chargedformula
--                                              vat_total_chargedformula,
--                                              cf_vat_total_inputformula
--                                              functions are removed.
-- DRAFT 1D 23-Mar-2006  Suresh Pasupunuri      Added a function
--                                              JEITPSSR_AMOUNT_TO_PAY for
--                                              calculating the AMOUNT_TO_PAY
--                                              for Italy Payables
--                                              Summary VAT Report.
--                                              Added a CREDIT_BALANCE_AMT
--                                              column to Italy Payables Summary
--                                              VAT Report query.
-- DRAFT 1E 03-Apr-2006  Suresh Pasupunuri      JEITPSSR_AMOUNT_TO_PAY Function
--                                              has modified.
-- 120.6    26-Apr-2006  Ramananda Pokkula      In Proceudre jeptavat: Removed
--                                              dummy insert statements. Added
--                                              missing join condition:
--                                 AL.vat_transaction_id = JG.vat_transaction_id
--                                 In the call jg_zz_common_pkg.tax_registration
--                                 pn_period_year parameter is changed to
--                                 pv_period_name
-- 120.7    28-Apr-2006  Ramananda Pokkula      Dummy assignments are removed
-- 120.8    31-May-2006  Ramananda Pokkula      Refer bug#5258440 for UT changes
-- 120.9    06-July-2006 Suresh.Pasupunuri      Created a new cursor
--                                get_legal_auth_info to get the Tax Office Code
--		                  and Tax Office Location for Portuguese
--                                Periodic and Annual VAT report.
--			          c_pt_periodic_vat and c_pt_annual_vat cursors
--                                are modified.
-- 120.10   10-Jul-2006  Suresh.Pasupunuri      Implemented the SIGN_INDICATOR
--                                              logic in the follwoing cursors.
--					  c_pt_periodic_vat and c_pt_annual_vat.
-- 120.11   20-Jul-2006  Suresh.Pasupunuri      TRN and Tax Payer ID columns are
--                                       showing same data in the report output.
--				         Because while inserting the header
--                                       information in to  the GT table, we are
--                                       inserting the value
--				         l_registration_num as TRN instead of
--                                       l_tax_registration_num.
-- 120.12   20-Jul-2006  Rukmani Basker  Cursor c_belgian_vat is modified to
--                                       remove incorrect
--                                       tables/column references.
-- 120.13   25-Jul-2006  Rukmani Basker  Bug 5407549. Incorrect reference to _GT
--                                       table.
-- 120.15   26-Jul-2006  Bhavik Rathod   Bug:5408280.  Modified to remove usage
--                                       of sign_indicator column
--                                       as it has been dropped.
-- 120.17   18-AUG-2006  RJREDDY         Bug: 5406944. Modified "c_belgian_vat"
--                                       cursor in "jebeva06" procedure,
--                                       to select '99' when tax_box or
--                                       taxable_box is NULL.
-- 120.18   05-SEP-2006  KASBALAS        Implemented changes for Reprint i
--                                       functionality.
-- 120.19   22-SEP-2006  RBASKER         Bug 5553571. Modification done to debug
--                                       message printing done for jeptpvat
--                                       to avoid ORA 1403.
-- 120.20   25-AUG-2006  SPASUPUN	 Bug:5553811. Modified the cursor-c_pt_annual_vat
--					 select query for column tax_class.
--					 Added a separate call to API
--					 jg_zz_common_pkg.tax_registration for report
--					 JEPTAVAT. Included some debug messages.
-- 120.21   05-SEP-2006  RJREDDY         Bug: 5563317. Modified c_belgian_vat cursor
--                                       query, so that the Taxable_Amt should always be
--                                       multiplied by taxable_non_rec_sign_flag and Tax_Amt
--                                       by appropriate Tax sign flag.
-- 120.22   16-OCT-2006  SPASUPUN        Bug:5573113 - In procedure JEITPSSR , while inserting the
--					 data into temp table , there is a wrong column mapping i.e.
--                                       column jg_info_d1 from tmp table is mapping with gl_transfer_flag
--                                       coulmn from jg table. Due to this the report is erroring out when
--                                       gl_transfer_flag is not null. Commented this invalid mapping,
--                                       as column are not used in reporting.
-- 120.23  06-NOV-2006   RBASKER         Bug 5561879: PT Periodic VAT is not
--                                       picking AR and GL transactions. Fixed
--                                       by having proper check for recover-
--                                       ability. The cursor for LegalAuthority
--					 is modified to have proper joins. Made
--					 changes to PT Annual VAT report to
-- 					 report GL transactions.
--  120.24  12-DEC-2006   PMADDULA       Bug 5674047 - In Procedure JEITPSSR,
--					 added a new column assessable_value to
--                                       the cursor 'c_italian_vat' in JEITPSSR procedure.
--                                       Populated the column 'jg_ingo_n11' of table
--   					 jg_zz_vat_trx_gt with the value obtained.
--					 This is to display correct taxable amount
--                                       when the tax type code of the transaction
--                                       is eitther 'Custom Bill' or 'Self Invoice'.
--  120.26  20-DEC-2006   RJREDDY        Bug 5718147: Changed the c_belgian_vat cursor query in JEBEVA06 procedure,
--                                       so that the Tax and Taxable amounts for the transactions will be multiplied with
--                                       -1 or 1 when the allocated Box sign is -ve or +ve respectively.
--  120.27  24-JUL-2007   ASHDAS         Bug 6189243: Changed the query "c_belgian_vat" in the procedure "jebeva06".
--                                       In the query used the column "language" instead of "source_lang" for the table "fnd_lookup_values"
--  120.28  27-AUG-2008   ASHDAS         Bug 7344931 Changed the c_belgian_vat and instead of Transaction date now GL_date is fetched.
--  120.35  29-JAN-2009   RAHULKUM       Bug 7633948 Modified the JEITPSSR_AMOUNT_TO_PAY and added a new function JEITPSSR_AMOUNT_TO_PAY_UPDATE.
--  120.36  10-FEB-2009   RAHULKUM       BUG:8237932 Modified the JEITPSSR_AMOUNT_TO_PAY.Added NVL function to CARRY_OVER.Replicating the changes of bug 7380506.
--  120.37  16-FEB-2009   RAHULKUM       BUG:8237932 Modified the JEITPSSR_AMOUNT_TO_PAY.Revertback the changes done for replicating the changes of bug 7380506.
--  120.38  17-FEB-2009   RAHULKUM       BUG:8237932 Modified the JEITPSSR_AMOUNT_TO_PAY.Added three new cursorsc_get_last_process_date ,c_get_balance,c_get_flag to replace c_get_details.
--  120.39  18-FEB-2009   RAHULKUM       BUG:8237932 Modified the JEITPSSR_AMOUNT_TO_PAY.Added raise_application_error to terminate the program in case of exception.
--  120.40  20-FEB-2009   RAHULKUM       BUG:8237932 Added TRUNC function for date in c_get_balance cursor.
--  120.41  12-FEB-2009   RAHULKUM       BUG:8237932 Modified the JEITPSSR_AMOUNT_TO_PAY_UPDATE.
--  120.42  07-APR-2009   RAHULKUM       BUG:8347134 Modified the JEITPSSR.Added two new cursors c_get_last_process_date ,c_get_balance.Update the jg_zz_vat_trx_gt
--  120.43  12-JUN-2009   RAHULKUM       BUG:8587526 Modified the JEITPSSR.
--  120.31.12010000.15 23-Jun-2009 SPASUPUN   Bug 8501251 : Modified procedure jebeva06
--					      to exclude multiple occurance of taxable informaiton. This issue was
--                                            there for AP transactions due to REC and Non-Rec lines concept.
--  120.26.12000000.19 10-Aug-2009 VKEJRIWA   Bug 8779393 : Modified the function jeilr835_inv_nu
--                                            to replace p_str by l_str when calculating l_len for the
--                                            second time so that the last 6 characters can be taken
--  120.48   28-OCT-2009  PAKUMARE        BUG:8983828 Modified the cursor c_belgian_vat.
--  120.31.12010000.19 03-Jan-2009 PAKUMARE   Bug:9241039: Changes made for IL VAT 2010 ER.
--  120.31.12010000.20 05-Jan-2009 RAHULKUM   Bug:9186339: Modified the Procedure JEITPSSR and
--                                             function  JEITPSSR_AMOUNT_TO_PAY.
--  120.31.12010000.21 13-JAN-2010 MKANDULA   BUG:9275163: Modified the formula to calculate Amount_to_pay in
--                                            JEITPSSR_AMOUNT_TO_PAY function.
--  120.31.12010000.22 05-FEB-2010 PAKUMARE   BUG:9338006 Increased the size to 9 in JEILR835_INV_NUM fn.
-- +===========================================================================+
AS
  FUNCTION before_report RETURN BOOLEAN
  IS
    CURSOR get_legal_auth_info(p_le_id number)
    IS
    SELECT      xle_auth.city       tax_office_location
           	,xle_auth.address3   tax_office_code
    FROM  XLE_FIRSTPARTY_INFORMATION_V xfpiv
          , xle_registrations xle_reg
          , xle_legalauth_v   xle_auth
    WHERE xle_reg.source_id           = xfpiv.legal_entity_id
    AND   xle_reg.source_table        = 'XLE_ENTITY_PROFILES'
    AND   xle_auth.legalauth_id (+)   = xle_reg.issuing_authority_id
    AND   xle_reg.identifying_flag    = 'Y'
    AND   xfpiv.legislative_cat_code  = 'INCOME_TAX'
    AND   xfpiv.legal_entity_id       =  p_le_id;

    -- Israel VAT Reporting 2010 - ER
   	CURSOR il_get_rep_status_id
	IS
		SELECT
			JZVRS.REPORTING_STATUS_ID
		FROM
			JG_ZZ_VAT_REP_STATUS JZVRS
		WHERE
			JZVRS.SOURCE='AP'
			AND     JZVRS.VAT_REPORTING_ENTITY_ID = P_VAT_REP_ENTITY_ID
			AND     JZVRS.TAX_CALENDAR_PERIOD     = P_PERIOD;

   	CURSOR il_get_vat_aggregate_limit
	IS
		SELECT
			JLMT.VAT_AGGREGATE_LIMIT_AMT
		FROM
			JE_IL_VAT_LIMITS JLMT,
			JG_ZZ_VAT_REP_STATUS JZVRS
		WHERE
			JZVRS.VAT_REPORTING_ENTITY_ID = P_VAT_REP_ENTITY_ID
			AND     JZVRS.TAX_CALENDAR_PERIOD     = P_PERIOD
			AND		JZVRS.TAX_CALENDAR_NAME	= JLMT.PERIOD_SET_NAME
			AND		JLMT.PERIOD_NAME = P_PERIOD
			AND 	ROWNUM = 1;

    l_address_line_1                VARCHAR2 (240);
    l_address_line_2                VARCHAR2 (240);
    l_address_line_3                VARCHAR2 (240);
    l_address_line_4                VARCHAR2 (240);
    l_city                          VARCHAR2 (60);
    l_company_name                  VARCHAR2 (240);
    l_contact_name                  VARCHAR2 (360);
    l_country                       VARCHAR2 (60);
    l_func_curr                     VARCHAR2 (30);
    l_legal_entity_id               NUMBER;
    l_legal_entity_name             VARCHAR2 (240);
    l_period_end_date               DATE;
    l_period_start_date             DATE;
    l_phone_number                  VARCHAR2 (40);
    l_postal_code                   VARCHAR2 (60);
    l_registration_num              VARCHAR2 (30);
    l_reporting_status              VARCHAR2 (60);
    l_tax_payer_id                  VARCHAR2 (60);
    l_tax_registration_num          VARCHAR2 (240);
    l_tax_regime                    VARCHAR2(240);
    l_activity_code                 VARCHAR2(240);
    l_vat_register_name             VARCHAR2(500);
    l_tax_office_location	    xle_legalauth_v.city%TYPE;
    l_tax_office_code	            xle_legalauth_v.address3%TYPE;
    l_precision                     NUMBER;
-- Added for Glob-006 ER
    l_province                      VARCHAR2(120);
    l_comm_num                      VARCHAR2(30);
    l_vat_reg_num                   VARCHAR2(50);
    l_entity_type_code              VARCHAR2(30);
	l_ledger_category_code          VARCHAR2(30);

  BEGIN
    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'    *** Report Parameters ***    ');
      fnd_file.put_line(fnd_file.log,'P_VAT_REP_ENTITY_ID   : ' || P_VAT_REP_ENTITY_ID   ) ;
      fnd_file.put_line(fnd_file.log,'P_PERIOD              : ' || P_PERIOD              ) ;
      fnd_file.put_line(fnd_file.log,'P_VAT_BOX             : ' || P_VAT_BOX             ) ;
      fnd_file.put_line(fnd_file.log,'P_VAT_TRX_TYPE_LOW    : ' || P_VAT_TRX_TYPE_LOW    ) ;
      fnd_file.put_line(fnd_file.log,'P_VAT_TRX_TYPE_HIGH   : ' || P_VAT_TRX_TYPE_HIGH   ) ;
      fnd_file.put_line(fnd_file.log,'P_VAT_TRX_TYPE        : ' || P_VAT_TRX_TYPE        ) ;
      fnd_file.put_line(fnd_file.log,'P_REPORT_FORMAT       : ' || P_REPORT_FORMAT       ) ;
      fnd_file.put_line(fnd_file.log,'P_BOX_FROM            : ' || P_BOX_FROM            ) ;
      fnd_file.put_line(fnd_file.log,'P_BOX_TO              : ' || P_BOX_TO              ) ;
      fnd_file.put_line(fnd_file.log,'P_SOURCE              : ' || P_SOURCE              ) ;
      fnd_file.put_line(fnd_file.log,'P_DOC_NAME            : ' || P_DOC_NAME            ) ;
      fnd_file.put_line(fnd_file.log,'P_DOC_SEQ_VALUE       : ' || P_DOC_SEQ_VALUE       ) ;
      fnd_file.put_line(fnd_file.log,'P_REPORT_NAME         : ' || P_REPORT_NAME         ) ;
      fnd_file.put_line(fnd_file.log,'P_VAR_ON_PURCHASES    : ' || P_VAR_ON_PURCHASES    ) ;
      fnd_file.put_line(fnd_file.log,'P_VAR_ON_SALES        : ' || P_VAR_ON_SALES        ) ;
      fnd_file.put_line(fnd_file.log,'P_LOCATION            : ' || P_LOCATION            ) ;
      fnd_file.put_line(fnd_file.log,'P_LEGAL_ENTITY_NAME   : ' || P_LEGAL_ENTITY_NAME   ) ;
      fnd_file.put_line(fnd_file.log,'    ***************************   ');
    END IF;

    BEGIN
    IF p_report_name = 'JEPTAVAT' THEN --Only for annual report, period year is passed
      jg_zz_common_pkg.funct_curr_legal(x_func_curr_code      => l_func_curr
                                      ,x_rep_entity_name      => l_legal_entity_name
                                      ,x_legal_entity_id      => l_legal_entity_id
                                      ,x_taxpayer_id          => l_tax_payer_id
                                      ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                      ,pn_period_year         => to_number(p_period));

      p_legal_entity_id := l_legal_entity_id;
    ELSE
      jg_zz_common_pkg.funct_curr_legal(x_func_curr_code      => l_func_curr
                                      ,x_rep_entity_name      => l_legal_entity_name
                                      ,x_legal_entity_id      => l_legal_entity_id
                                      ,x_taxpayer_id          => l_tax_payer_id
                                      ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                      ,pv_period_name         => p_period);

      p_legal_entity_id := l_legal_entity_id;
    END IF ;
    EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'Executing jg_zz_common_pkg.funct_curr_legal: '||SUBSTR(SQLERRM,1,200));
    END;

    BEGIN
    IF p_report_name = 'JEPTAVAT' THEN
    jg_zz_common_pkg.tax_registration(x_tax_registration     => l_tax_registration_num
                                     ,x_period_start_date    => l_period_start_date
                                     ,x_period_end_date      => l_period_end_date
                                     ,x_status               => l_reporting_status
                                     ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                     ,pv_period_name         => NULL
                                     ,pn_period_year         => to_number(p_period)
				      ,pv_source              => 'ALL');
    ELSE
        jg_zz_common_pkg.tax_registration(x_tax_registration     => l_tax_registration_num
                                     ,x_period_start_date    => l_period_start_date
                                     ,x_period_end_date      => l_period_end_date
                                     ,x_status               => l_reporting_status
                                     ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                     ,pv_period_name         => p_period
                                     ,pn_period_year         => NULL
                                     ,pv_source              => 'ALL');
    END IF;
    EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'Executing jg_zz_common_pkg.tax_registration: '||SUBSTR(SQLERRM,1,200));
    END;

    BEGIN
     if(P_REPORT_NAME <> 'JEPTAVAT' )then
      l_reporting_status := jg_zz_vat_rep_utility.get_period_status
                          (
                           pn_vat_reporting_entity_id  =>  p_vat_rep_entity_id,
                           pv_tax_calendar_period      =>  p_period,
                           pv_tax_calendar_year        =>  NULL,
                           pv_source                   =>  NULL,
                           pv_report_name              =>  P_REPORT_NAME
                          );
     else
          l_reporting_status := jg_zz_vat_rep_utility.get_period_status
                          (
                           pn_vat_reporting_entity_id  =>  p_vat_rep_entity_id,
                           pv_tax_calendar_period      =>  NULL,
                           pv_tax_calendar_year        =>  p_period,
                           pv_source                   =>  NULL,
                           pv_report_name              =>  P_REPORT_NAME
                          );
     end if;

    EXCEPTION
     WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'Executing jg_zz_common_pkg.tax_registration: '||SUBSTR(SQLERRM,1,200));
    END;

    BEGIN
            jg_zz_common_pkg.company_detail(x_company_name     => l_company_name
                                     ,x_registration_number    => l_registration_num
                                     ,x_country                => l_country
                                     ,x_address1               => l_address_line_1
                                     ,x_address2               => l_address_line_2
                                     ,x_address3               => l_address_line_3
                                     ,x_address4               => l_address_line_4
                                     ,x_city                   => l_city
                                     ,x_postal_code            => l_postal_code
                                     ,x_contact                => l_contact_name
                                     ,x_phone_number           => l_phone_number
                                     ,x_province               => l_province
                                     ,x_comm_number            => l_comm_num
                                     ,x_vat_reg_num            => l_vat_reg_num
                                     ,pn_legal_entity_id       => l_legal_entity_id
                                     ,p_vat_reporting_entity_id => P_VAT_REP_ENTITY_ID);
    EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'Executing jg_zz_common_pkg.company_detail: '||SUBSTR(SQLERRM,1,200));
    END;
    BEGIN
      SELECT activity_code
      INTO   l_activity_code
      FROM   xle_entity_profiles
      WHERE  legal_entity_id = l_legal_entity_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(fnd_file.log,'Cannot find Activity Code (Standard Inductry Classification Code for Legal Entity:'||l_legal_entity_id);
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'Error While retriving Activity Code for Legal Entity:'||l_legal_entity_id);
      fnd_file.put_line(fnd_file.log,'Error Message :'||SUBSTR(SQLERRM,1,200));
    END;

    BEGIN

	OPEN get_legal_auth_info(p_legal_entity_id);
	FETCH get_legal_auth_info INTO
			l_tax_office_location,
			l_tax_office_code;
	CLOSE get_legal_auth_info;

	EXCEPTION
	WHEN OTHERS THEN
          fnd_file.put_line(fnd_file.log,'Error Message :'||SUBSTR(SQLERRM,1,200));
     END;


/* Get Currency Precision */

     BEGIN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Functional Currency Code :'||l_func_curr);

       SELECT  precision
       INTO  l_precision
       FROM    fnd_currencies
       WHERE   currency_code = l_func_curr;

       FND_FILE.PUT_LINE(FND_FILE.LOG,'Functional Currency Precision :'||l_precision);

       EXCEPTION
       WHEN OTHERS THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'error in getting currency precision');
     END;


    INSERT INTO jg_zz_vat_trx_gt
    (
      jg_info_n1
     ,jg_info_v1
     ,jg_info_v2
     ,jg_info_v3
     ,jg_info_v4
     ,jg_info_v5
     ,jg_info_v6
     ,jg_info_v7
     ,jg_info_v8
     ,jg_info_v9
     ,jg_info_v10
     ,jg_info_v11
     ,jg_info_v12
     ,jg_info_v13
     ,jg_info_v14
     ,jg_info_v15
     ,jg_info_v16
     ,jg_info_v17
     ,jg_info_d1
     ,jg_info_d2
     ,jg_info_v20
     ,jg_info_v21
     ,jg_info_n25
     ,jg_info_v30
     ,jg_info_v22
     ,jg_info_v23
     ,jg_info_v24
    )
    VALUES
    (
       l_legal_entity_id
      ,l_company_name ---l_legal_entity_name
      ,l_tax_registration_num
      ,l_registration_num --l_tax_payer_id
      ,l_contact_name
      ,l_address_line_1
      ,l_address_line_2
      ,l_address_line_3
      ,l_address_line_4
      ,l_city
      ,l_country
      ,l_phone_number
      ,l_postal_code
      ,l_func_curr
      ,l_reporting_status
      ,l_tax_regime
      ,l_activity_code
      ,l_tax_registration_num
      ,l_period_end_date
      ,l_period_start_date
      ,l_tax_office_location
      ,l_tax_office_code
      ,l_precision           -- currency precision
      ,'H'
      ,l_province
      ,l_comm_num
      ,l_vat_reg_num
    );
    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Legal Entity ID     =>  ' || l_legal_entity_id);
      fnd_file.put_line(fnd_file.log,'Company Name        =>  ' || l_company_name);
      fnd_file.put_line(fnd_file.log,'Legal Entity Name   =>  ' || l_company_name);
      fnd_file.put_line(fnd_file.log,'Regiatration Number =>  ' || l_registration_num);
      fnd_file.put_line(fnd_file.log,'Taxpayer ID         =>  ' || l_registration_num);
      fnd_file.put_line(fnd_file.log,'Contact Name        =>  ' || l_contact_name);
      fnd_file.put_line(fnd_file.log,'Address Line 1      =>  ' || l_address_line_1);
      fnd_file.put_line(fnd_file.log,'Address Line 2      =>  ' || l_address_line_2);
      fnd_file.put_line(fnd_file.log,'Address Line 3      =>  ' || l_address_line_3);
      fnd_file.put_line(fnd_file.log,'Address Line 4      =>  ' || l_address_line_4);
      fnd_file.put_line(fnd_file.log,'City                =>  ' || l_city);
      fnd_file.put_line(fnd_file.log,'Country             =>  ' || l_country);
      fnd_file.put_line(fnd_file.log,'Telephone Number    =>  ' || l_phone_number);
      fnd_file.put_line(fnd_file.log,'Postal Code         =>  ' || l_postal_code);
      fnd_file.put_line(fnd_file.log,'Currency Code       =>  ' || l_func_curr);
      fnd_file.put_line(fnd_file.log,'Reporting Status    =>  ' || l_reporting_status);
      fnd_file.put_line(fnd_file.log,'Period Start Date   =>  ' || l_period_start_date);
      fnd_file.put_line(fnd_file.log,'Period End Date     =>  ' || l_period_end_date);
      fnd_file.put_line(fnd_file.log,'l_tax_office_location     =>  ' || l_tax_office_location);
      fnd_file.put_line(fnd_file.log,'l_tax_office_code   =>  ' || l_tax_office_code);
    END IF;


    -- Israel VAT Reporting 2010 - ER
	IF p_report_name = 'JEILSVAT' OR p_report_name = 'JEILR835' THEN
		BEGIN
			-- Get the reporting status id
			FOR cur_get_rep_status_id IN il_get_rep_status_id
			LOOP
				l_vat_rep_status_id	:= cur_get_rep_status_id.reporting_status_id;
			END LOOP;

			-- Get the VAT Aggregate Limit Amount
			FOR cur_get_vat_aggregate_limit IN il_get_vat_aggregate_limit
			LOOP
				l_vat_aggregation_limit_amt	:= cur_get_vat_aggregate_limit.VAT_AGGREGATE_LIMIT_AMT;
			END LOOP;
		EXCEPTION
		WHEN OTHERS THEN
			  fnd_file.put_line(fnd_file.log,'Error Message :'||SUBSTR(SQLERRM,1,200));
		END;

		BEGIN
			select distinct nvl(jzvre.ledger_id,0)
						  , jzvre.entity_type_code
			into l_ledger_id,l_entity_type_code
			from jg_zz_vat_rep_entities jzvre
			where jzvre.vat_reporting_entity_id = P_VAT_REP_ENTITY_ID;
		EXCEPTION
		WHEN OTHERS THEN
			l_ledger_id := 0;
			l_entity_type_code := 'NO_ENTITY_TYPE_CODE';
		END;

		BEGIN
			select DISTINCT ledger_category_code
			into l_ledger_category_code
			from gl_ledgers
			where ledger_id = l_ledger_id;
		EXCEPTION
		WHEN OTHERS THEN
			l_ledger_category_code := 'NO_CATEGORY_CODE';
		END;

		IF ( l_entity_type_code = 'LEGAL' OR ( l_entity_type_code = 'ACCOUNTING' AND l_ledger_category_code = 'PRIMARY' ))
		THEN
			l_ledger_id := -1;
		END IF;

		IF l_vat_rep_status_id IS NULL THEN
			fnd_file.put_line(fnd_file.log,'Please run the EMEA VAT: Selection Process for Payables source for the tax period '||p_period||'.');
			raise_application_error(-20010,'Please run the EMEA VAT: Selection Process for Payables source for the tax period '||p_period||'.');
		ELSIF l_vat_aggregation_limit_amt IS NULL THEN
			fnd_file.put_line(fnd_file.log,'Please declare the VAT limits for the tax period '||p_period||' for calendar in the Israel VAT Limits Setup form.');
			raise_application_error(-20010,'Please declare the VAT limits for the tax period '||p_period||' for calendar in the Israel VAT Limits Setup form.');
		END IF;

		--Set the precision
		g_precision := l_precision;

		IF p_debug_flag = 'Y' THEN
			fnd_file.put_line(fnd_file.log,'VAT Aggregate Limit Amount '||to_char(l_vat_aggregation_limit_amt));
		END IF;
		IF p_debug_flag = 'Y' THEN
			fnd_file.put_line(fnd_file.log,'Get Reporting Status ID '||to_char(l_vat_rep_status_id));
		END IF;
    ELSIF p_report_name = 'JEBEVA06' THEN
      IF p_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'Calling Procedure jgbeva06');
      END IF;
      jebeva06(p_vat_rep_entity_id  => p_vat_rep_entity_id
              ,p_period             => p_period
              ,p_vat_box            => p_vat_box
              ,p_vat_trx_type_low   => p_vat_trx_type_low
              ,p_vat_trx_type_high  => p_vat_trx_type_high
              ,p_source             => p_source
              ,p_doc_name           => p_doc_name
              ,p_doc_seq_value      => p_doc_seq_value
              ,x_err_msg            => l_err_msg);
      IF p_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'Completed Call to Procedure jgbava06');
      END IF;
    ELSIF p_report_name = 'JEPTAVAT' THEN
      IF p_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'Calling Procedure JEPTAVAT');
      END IF;
      jeptavat(p_vat_rep_entity_id  => p_vat_rep_entity_id
              ,p_period             => p_period
              ,p_location           => p_location
              ,x_err_msg            => l_err_msg);
      IF p_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'Completed Call to Procedure JEPTAVAT');
      END IF;
    ELSIF p_report_name = 'JEPTPVAT' THEN
      IF p_debug_flag = 'Y' THEN
					fnd_file.put_line(fnd_file.log,'Calling Procedure JEPTPVAT');
      END IF;
      jeptpvat(p_vat_rep_entity_id  => p_vat_rep_entity_id
              ,p_period             => p_period
              ,p_location           => p_location
              ,x_err_msg            => l_err_msg);
      IF p_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'Completed Call to Procedure JEPTPVAT');
      END IF;
    ELSIF p_report_name = 'JEITPSSR' THEN
      IF p_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'Calling Procedure JEITPSSR');
      END IF;
      jeitpssr(p_vat_rep_entity_id  => p_vat_rep_entity_id
              ,p_period             => p_period
              ,p_var_on_purchases   => p_var_on_purchases
              ,p_var_on_sales       => p_var_on_sales
              ,x_err_msg            => l_err_msg);
      IF p_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'Completed Call to Procedure JEITPSSR');
      END IF;
   END IF;

      IF p_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'End of Before Report');
      END IF;

    RETURN (TRUE);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      RETURN (TRUE);
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error in Before Report Trigger' || SQLCODE || SUBSTR(SQLERRM,1,200));
    raise;
    RETURN (FALSE);
  END before_report;

  --
  -- +======================================================================+
  -- Name: JEBEVA06
  --
  -- Description: This procedure used by the Extract when the Concurrent
  --              Program 'Belgian VAT Monthly VAT Preparation Report' is run.
  --
  -- Parameters:  P_VAT_REP_ENTITY_ID   => VAT Reporting Entity ID
  --              P_PERIOD              => Tax Calendar Year
  --              P_VAT_BOX             => VAT Report Box
  --              P_VAT_TRX_TYPE_LOW    => VAT Transaction Type Low
  --              P_VAT_TRX_TYPE_HIGH   => VAT Transaction Type Low
  --              P_SOURCE              => Transaction Source
  --              P_DOC_NAME            => Document Sequence Name
  --              P_DOC_SEQ_VALUE       => Document Sequence Value
  -- +======================================================================+
  --
  PROCEDURE jebeva06(p_vat_rep_entity_id  IN    NUMBER
                    ,p_period             IN    VARCHAR2
                    ,p_vat_box            IN    VARCHAR2
                    ,p_vat_trx_type_low   IN    VARCHAR2
                    ,p_vat_trx_type_high  IN    VARCHAR2
                    ,p_source             IN    VARCHAR2
                    ,p_doc_name           IN    VARCHAR2
                    ,p_doc_seq_value      IN    VARCHAR2
                    ,x_err_msg            OUT NOCOPY  VARCHAR2)
  IS

    /* brathod, modified the cursor to remove usage of jg_zz_alloc_rules table. */
    CURSOR c_belgian_vat
    IS
    SELECT
               JZVRS.tax_calendar_year       PERIOD_YEAR
             , JZVRS.tax_calendar_period     PERIOD_NAME
             , NVL(AL.tax_box, '99')         TAX_BOX
             , NVL(AL.taxable_box, '99')     TAXABLE_BOX
             , TBLLOOKUP.description         TAXABLEBOX_DESCRIPTION
             , TLOOKUP.description           TAXBOX_DESCRIPTION
             , JG.extract_source_ledger      SOURCE
             , JG.doc_seq_name               DOCUMENT_SEQ_NAME
             , JG.doc_seq_value              DOCUMENT_SEQ_VALUE
             /**************************************************
             Commented the below code for Bug 7344931 and added GL_DATE
             , fnd_date.date_to_displaydate(JG.trx_date)  GL_DATE
             **************************************************/
             , JG.gl_date                    GL_DATE
             , JG.billing_tp_number          TRADING_PARTNER_NUMBER
             , JG.billing_tp_name            TRADING_PARTNER_NAME
             , JG.trx_number                 INVOICE
             , JG.trx_line_number            LINE_NUMBER
             , JG.tax_rate_Code              VAT_CODE
             , JG.tax_rate_vat_trx_type_code VAT_TRANSACTION_TYPE
             , nvl(JG.taxable_amt_funcl_curr,JG.taxable_amt) * to_number (alr.taxable_non_rec_sign_flag || '1') TAXABLE_AMOUNT
             , nvl(JG.tax_amt_funcl_curr,JG.tax_amt) * to_number(decode(JG.extract_source_ledger, 'AP',
                                                 decode(jg.tax_recoverable_flag, 'Y',
                                                     alr.tax_rec_sign_flag, alr.tax_non_rec_sign_flag) || '1',
                                                 alr.tax_rec_sign_flag || '1'))    TAX_AMOUNT
	      ,JG.tax_line_id
     	      ,AL.allocation_rule_id
      FROM
               jg_zz_vat_box_allocs  AL
             , jg_zz_vat_alloc_rules alr
             , jg_zz_vat_trx_details JG
             , fnd_lookup_values            TLOOKUP
             , fnd_lookup_values            TBLLOOKUP
             , jg_zz_vat_rep_status  JZVRS
      WHERE
               NVL(AL.taxable_box, '99')     = TBLLOOKUP.lookup_code
      AND      NVL(AL.tax_box, '99')         = TLOOKUP.lookup_code
      AND      TLOOKUP.lookup_type           = 'JGZZ_VAT_REPORT_BOXES'
      AND      TBLLOOKUP.lookup_type         = 'JGZZ_VAT_REPORT_BOXES'
      AND      TLOOKUP.language              = USERENV('LANG')
      AND      TBLLOOKUP.language            = USERENV('LANG')
      AND      AL.PERIOD_TYPE                = 'PERIODIC'
      AND      jg.tax_rate_vat_trx_type_code  BETWEEN NVL( P_VAT_TRX_TYPE_LOW,jg.tax_rate_vat_trx_type_code )
                                              AND     NVL( P_VAT_TRX_TYPE_HIGH,jg.tax_rate_vat_trx_type_code )
      AND      JZVRS.reporting_status_id      = JG.reporting_status_id
      AND      AL.vat_transaction_id          = JG.vat_transaction_id
      AND      alr.allocation_rule_id         = al.allocation_rule_id
      AND      (P_vat_box IS NULL   OR   AL.tax_box = P_vat_box   OR   AL.taxable_box = P_vat_box)
      AND      JG.extract_source_ledger       = NVL(P_source,JG.extract_source_ledger)
      AND      (JG.doc_seq_name               = P_doc_name OR P_doc_name IS NULL)
      AND      (JG.doc_seq_value              = P_doc_seq_value OR P_doc_seq_value IS NULL)
      AND      JZVRS.vat_reporting_entity_id  = P_vat_rep_entity_id
      AND      JZVRS.tax_calendar_period      = P_PERIOD
      ORDER BY
      	  JG.tax_line_id
     	, AL.allocation_rule_id
        ,  JG.trx_date
        , AL.tax_box
        , source
        , JG.doc_seq_name
        , JG.doc_seq_value
        , DECODE (jg.extract_source_ledger
                  ,'AR', JG.trx_line_number
                  ,'AP', JG.trx_line_number
                  ,'GL', JG.trx_line_number);
                  -- ,'CR', JG.trx_line_id); brathod, commented as 'CR' type of transactions are merged with AR

    l_be_vat  c_belgian_vat%ROWTYPE;

  /**
      Brathod, Modified record defination to use table refered data types instead of normal data types
    */

    TYPE r_box_amounts IS RECORD
    (
      period_year                 jg_zz_vat_rep_status.tax_calendar_year%type --NUMBER
     ,period_name                 jg_zz_vat_rep_status.tax_calendar_period%type --VARCHAR2(10)
     ,tax_box                     jg_zz_vat_box_allocs.tax_box%type
     ,taxable_box                 jg_zz_vat_box_allocs.taxable_box%type --VARCHAR2(10)
     ,taxablebox_description      fnd_lookup_values.description%type --VARCHAR2(250)
     ,taxbox_description          fnd_lookup_values.description%type --VARCHAR2(250)
     ,source                      jg_zz_vat_trx_details.extract_source_ledger%type -- VARCHAR2(10)
     ,document_seq_name           jg_zz_vat_trx_details.doc_seq_name%type -- VARCHAR2(60)
     ,document_seq_value          jg_zz_vat_trx_details.doc_seq_value%type --NUMBER
     ,gl_date                     jg_zz_vat_trx_details.trx_date%type
     ,trading_partner_number      jg_zz_vat_trx_details.billing_tp_number%type -- VARCHAR2(240)
     ,trading_partner_name        jg_zz_vat_trx_details.billing_tp_name%type --VARCHAR2(240)
     ,invoice                     jg_zz_vat_trx_details.trx_number%type --VARCHAR2(60)
     ,line_number                 jg_zz_vat_trx_details.trx_line_number%type --NUMBER
     ,vat_code                    jg_zz_vat_trx_details.tax_rate_Code%type --VARCHAR2(100)
     ,vat_transaction_type        jg_zz_vat_trx_details.tax_rate_vat_trx_type_code%type --VARCHAR2(100)
     ,taxable_amount              jg_zz_vat_trx_details.taxable_amt%type --NUMBER
     ,tax_amount                  jg_zz_vat_trx_details.tax_amt%type --NUMBER
     ,tax_line_id                 jg_zz_vat_trx_details.tax_line_id%type --NUMBER
     ,allocation_rule_id	  jg_zz_vat_box_allocs.allocation_rule_id%type -- NUMBER
      );

    TYPE r_vatbox_amounts IS RECORD
    (
      period_year                 jg_zz_vat_rep_status.tax_calendar_year%type --NUMBER
     ,period_name                 jg_zz_vat_rep_status.tax_calendar_period%type --VARCHAR2(10)
     ,vat_report_box              jg_zz_vat_box_allocs.tax_box%type --VARCHAR2(10)
     ,vat_box_description         fnd_lookup_values.description%type --VARCHAR2(250)
     ,source                      jg_zz_vat_trx_details.extract_source_ledger%type -- VARCHAR2(10)
     ,document_seq_name           jg_zz_vat_trx_details.doc_seq_name%type -- VARCHAR2(60)
     ,document_seq_value          jg_zz_vat_trx_details.doc_seq_value%type --NUMBER
     ,gl_date                     jg_zz_vat_trx_details.accounting_date%type
     ,trading_partner_number      jg_zz_vat_trx_details.billing_tp_number%type -- VARCHAR2(240)
     ,trading_partner_name        jg_zz_vat_trx_details.billing_tp_name%type --VARCHAR2(240)
     ,invoice                     jg_zz_vat_trx_details.trx_number%type --VARCHAR2(60)
     ,line_number                 jg_zz_vat_trx_details.trx_line_number%type --NUMBER
     ,vat_code                    jg_zz_vat_trx_details.tax%type --VARCHAR2(100)
     ,vat_transaction_type        jg_zz_vat_trx_details.tax_rate_vat_trx_type_code%type --VARCHAR2(100)
     ,taxable_amount              jg_zz_vat_trx_details.taxable_amt%type --NUMBER
     ,tax_amount                  jg_zz_vat_trx_details.tax_amt%type --NUMBER
      );


    TYPE t_box_amounts IS TABLE OF r_box_amounts
    INDEX BY BINARY_INTEGER;

    TYPE t_vatbox_amounts IS TABLE OF r_vatbox_amounts
    INDEX BY BINARY_INTEGER;

    v_box_amount          t_box_amounts;
    l_box_amount_grouped  t_vatbox_amounts;
    l_index NUMBER;
    l_count NUMBER := 0 ;

    t_tax_line_id NUMBER :=0;
    t_allocation_rule_id NUMBER :=0;

  BEGIN
    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Executing jg_zz_summary_all_pkg.jgbeva06');
      fnd_file.put_line(fnd_file.log,'Open Cursor C_BELGIAN_VAT');
    END IF;
    OPEN c_belgian_vat;
    FETCH c_belgian_vat BULK COLLECT INTO v_box_amount;
    CLOSE c_belgian_vat;
    l_index := 1;
    FOR i IN 1..v_box_amount.COUNT
    LOOP
      IF v_box_amount(i).tax_box = v_box_amount(i).taxable_box THEN
        -- The Tax Box is same as taxable box. Therefore no need for changes.
        l_box_amount_grouped(l_index).period_year             := v_box_amount(i).period_year;
        l_box_amount_grouped(l_index).period_name             := v_box_amount(i).period_name;
        l_box_amount_grouped(l_index).vat_report_box          := v_box_amount(i).tax_box;
        l_box_amount_grouped(l_index).vat_box_description     := v_box_amount(i).taxablebox_description;
        l_box_amount_grouped(l_index).source                  := v_box_amount(i).source;
        l_box_amount_grouped(l_index).document_seq_name       := v_box_amount(i).document_seq_name;
        l_box_amount_grouped(l_index).document_seq_value      := v_box_amount(i).document_seq_value;
        l_box_amount_grouped(l_index).gl_date                 := v_box_amount(i).gl_date;
        l_box_amount_grouped(l_index).trading_partner_number  := v_box_amount(i).trading_partner_number;
        l_box_amount_grouped(l_index).trading_partner_name    := v_box_amount(i).trading_partner_name;
        l_box_amount_grouped(l_index).invoice                 := v_box_amount(i).invoice;
        l_box_amount_grouped(l_index).line_number             := v_box_amount(i).line_number;
        l_box_amount_grouped(l_index).vat_code                := v_box_amount(i).vat_code;
        l_box_amount_grouped(l_index).vat_transaction_type    := v_box_amount(i).vat_transaction_type;
        l_box_amount_grouped(l_index).tax_amount              := v_box_amount(i).tax_amount;

        if v_box_amount(i).tax_line_id <> t_tax_line_id or
 	   v_box_amount(i).allocation_rule_id <> t_allocation_rule_id
	then
	   l_box_amount_grouped(l_index).taxable_amount := v_box_amount(i).taxable_amount;
	else
           l_box_amount_grouped(l_index).taxable_amount          := NULL;
	end if;

	t_tax_line_id := v_box_amount(i).tax_line_id;
	t_allocation_rule_id := v_box_amount(i).allocation_rule_id;


      ELSE
        -- Tax Box and Taxable Box Numbers are different. Therefore create two lines
        -- Create the Taxable Box Line
        l_box_amount_grouped(l_index).period_year             := v_box_amount(i).period_year;
        l_box_amount_grouped(l_index).period_name             := v_box_amount(i).period_name;
        l_box_amount_grouped(l_index).vat_report_box          := v_box_amount(i).taxable_box;
        l_box_amount_grouped(l_index).vat_box_description     := v_box_amount(i).taxablebox_description;
        l_box_amount_grouped(l_index).source                  := v_box_amount(i).source;
        l_box_amount_grouped(l_index).document_seq_name       := v_box_amount(i).document_seq_name;
        l_box_amount_grouped(l_index).document_seq_value      := v_box_amount(i).document_seq_value;
        l_box_amount_grouped(l_index).gl_date                 := v_box_amount(i).gl_date;
        l_box_amount_grouped(l_index).trading_partner_number  := v_box_amount(i).trading_partner_number;
        l_box_amount_grouped(l_index).trading_partner_name    := v_box_amount(i).trading_partner_name;
        l_box_amount_grouped(l_index).invoice                 := v_box_amount(i).invoice;
        l_box_amount_grouped(l_index).line_number             := v_box_amount(i).line_number;
        l_box_amount_grouped(l_index).vat_code                := v_box_amount(i).vat_code;
        l_box_amount_grouped(l_index).vat_transaction_type    := v_box_amount(i).vat_transaction_type;
        l_box_amount_grouped(l_index).tax_amount              := NULL;

	if v_box_amount(i).tax_line_id <> t_tax_line_id or
 	  v_box_amount(i).allocation_rule_id <> t_allocation_rule_id
	then
	   l_box_amount_grouped(l_index).taxable_amount    := v_box_amount(i).taxable_amount;
	else
           l_box_amount_grouped(l_index).taxable_amount    := NULL;
	end if;

	t_tax_line_id := v_box_amount(i).tax_line_id;
	t_allocation_rule_id := v_box_amount(i).allocation_rule_id;


        -- Create the Tax Line
        l_index := l_index + 1;
        l_box_amount_grouped(l_index).period_year             := v_box_amount(i).period_year;
        l_box_amount_grouped(l_index).period_name             := v_box_amount(i).period_name;
        l_box_amount_grouped(l_index).vat_report_box          := v_box_amount(i).tax_box;
        l_box_amount_grouped(l_index).vat_box_description     := v_box_amount(i).taxbox_description;
        l_box_amount_grouped(l_index).source                  := v_box_amount(i).source;
        l_box_amount_grouped(l_index).document_seq_name       := v_box_amount(i).document_seq_name;
        l_box_amount_grouped(l_index).document_seq_value      := v_box_amount(i).document_seq_value;
        l_box_amount_grouped(l_index).gl_date                 := v_box_amount(i).gl_date;
        l_box_amount_grouped(l_index).trading_partner_number  := v_box_amount(i).trading_partner_number;
        l_box_amount_grouped(l_index).trading_partner_name    := v_box_amount(i).trading_partner_name;
        l_box_amount_grouped(l_index).invoice                 := v_box_amount(i).invoice;
        l_box_amount_grouped(l_index).line_number             := v_box_amount(i).line_number;
        l_box_amount_grouped(l_index).vat_code                := v_box_amount(i).vat_code;
        l_box_amount_grouped(l_index).vat_transaction_type    := v_box_amount(i).vat_transaction_type;
        l_box_amount_grouped(l_index).taxable_amount          := NULL;
        l_box_amount_grouped(l_index).tax_amount              := v_box_amount(i).tax_amount;
      END IF;
      l_index := l_index + 1;
    END LOOP;

    FOR i IN 1..l_box_amount_grouped.COUNT
    LOOP
      IF p_debug_flag = 'Y' THEN
        fnd_file.put_line(fnd_file.log,'Period Year      => '  ||  l_box_amount_grouped(i).period_year);
        fnd_file.put_line(fnd_file.log,'Period Name      => '  ||  l_box_amount_grouped(i).period_name);
        fnd_file.put_line(fnd_file.log,'VAT Report Box   => '  ||  l_box_amount_grouped(i).vat_report_box);
        fnd_file.put_line(fnd_file.log,'Box Descriptionc => '  ||  l_box_amount_grouped(i).vat_box_description);
        fnd_file.put_line(fnd_file.log,'Source           => '  ||  l_box_amount_grouped(i).source);
        fnd_file.put_line(fnd_file.log,'Document Name    => '  ||  l_box_amount_grouped(i).document_seq_name);
        fnd_file.put_line(fnd_file.log,'Documemt Value   => '  ||  l_box_amount_grouped(i).document_seq_value);
        fnd_file.put_line(fnd_file.log,'GL Date          => '  ||  l_box_amount_grouped(i).gl_date);
        fnd_file.put_line(fnd_file.log,'Vendor Number    => '  ||  l_box_amount_grouped(i).trading_partner_number);
        fnd_file.put_line(fnd_file.log,'Vendor_Name      => '  ||  l_box_amount_grouped(i).trading_partner_name);
        fnd_file.put_line(fnd_file.log,'Invoice Number   => '  ||  l_box_amount_grouped(i).invoice);
        fnd_file.put_line(fnd_file.log,'Line Number      => '  ||  l_box_amount_grouped(i).line_number);
        fnd_file.put_line(fnd_file.log,'VAT Code         => '  ||  l_box_amount_grouped(i).vat_code);
        fnd_file.put_line(fnd_file.log,'VAT Trans Type   => '  ||  l_box_amount_grouped(i).vat_transaction_type);
        fnd_file.put_line(fnd_file.log,'Taxable Amount   => '  ||  l_box_amount_grouped(i).taxable_amount);
        fnd_file.put_line(fnd_file.log,'Tax Amount       => '  ||  l_box_amount_grouped(i).tax_amount);
      END IF;

      IF l_box_amount_grouped(i).taxable_amount IS NOT NULL OR
	 l_box_amount_grouped(i).tax_amount IS NOT NULL THEN

      INSERT INTO jg_zz_vat_trx_gt
            (
               jg_info_n1
             , jg_info_v1
             , jg_info_v2
             , jg_info_v3
             , jg_info_v4
             , jg_info_v5
             , jg_info_n2
             , jg_info_d1
             , jg_info_v6
             , jg_info_v7
             , jg_info_v8
             , jg_info_n3
             , jg_info_v9
             , jg_info_v10
             , jg_info_n4
             , jg_info_n5
            )
      VALUES(
               l_box_amount_grouped(i).period_year
             , l_box_amount_grouped(i).period_name
             , l_box_amount_grouped(i).vat_report_box
             , l_box_amount_grouped(i).vat_box_description
             , l_box_amount_grouped(i).source
             , l_box_amount_grouped(i).document_seq_name
             , l_box_amount_grouped(i).document_seq_value
             , l_box_amount_grouped(i).gl_date
             , l_box_amount_grouped(i).trading_partner_number
             , l_box_amount_grouped(i).trading_partner_name
             , l_box_amount_grouped(i).invoice
             , l_box_amount_grouped(i).line_number
             , l_box_amount_grouped(i).vat_code
             , l_box_amount_grouped(i).vat_transaction_type
             , l_box_amount_grouped(i).taxable_amount
             , l_box_amount_grouped(i).tax_amount
            );

	END IF;

    END LOOP;

    SELECT count(*) into l_count from jg_zz_vat_trx_gt ;
    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Number of records inserted into jg_zz_vat_trx_gt table: ' || l_count );
      fnd_file.put_line(fnd_file.log,'Completed procedure jg_zz_summary_all_pkg.jgbeva06');
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error in Procedure jg_zz_summary_all_pkg.jebeva06 ' || SUBSTR(SQLERRM,1,200));
    RAISE;
  END jebeva06;

  --
  -- +======================================================================+
  -- Name: JEPTAVAT
  --
  -- Description: This procedure used by the Extract when the Concurrent
  --              Program 'Portuguese Annual VAT Report' is run.
  --
  -- Parameters:  P_VAT_REP_ENTITY_ID   => VAT Reporting Entity ID
  --              P_PERIOD              => Tax Calendar Year
  --              P_LOCATION            => Location Code
  -- +======================================================================+
  --
  PROCEDURE jeptavat(p_vat_rep_entity_id  IN    NUMBER
                    ,p_period             IN    VARCHAR2
                    ,p_location           IN    VARCHAR2
                    ,x_err_msg            OUT  NOCOPY VARCHAR2)
  IS
    CURSOR c_pt_annual_vat
    IS
        SELECT
               NVL(
		    DECODE(ALLOCBOX.tax_recoverable_flag,
				   'Y',TO_NUMBER(ALLOCBOX.taxable_box)),1000) TXBL_REC_BOX
             , NVL(
		    DECODE(NVL(ALLOCBOX.tax_recoverable_flag,'N'),
				   'N',TO_NUMBER(ALLOCBOX.taxable_box)),1000) TXBL_NRC_BOX

             , DECODE(JG.extract_source_ledger
			,'AP', DECODE(JG.tax_recoverable_flag,'Y', NVL(JG.taxable_amt_funcl_curr ,0))
			,NVL(JG.taxable_amt_funcl_curr ,0))		TXBL_AMOUNT

              , DECODE(JG.extract_source_ledger
                        ,'AP', DECODE(JG.tax_recoverable_flag,'N', NVL(JG.taxable_amt_funcl_curr ,0))
                        ,NVL(JG.taxable_amt_funcl_curr ,0))             TXBL_NRC_AMOUNT

/*	     , DECODE(ALLOCBOX.tax_recoverable_flag,
						'Y',taxable_amt, 0)  TXBL_AMOUNT

             , DECODE(ALLOCBOX.tax_recoverable_flag,'Y',0,taxable_amt ) TXBL_NRC_AMOUNT */

             , NVL(TO_NUMBER(ALLOCRUL.TOTAL_BOX),1000) TOTAL_BOX

             , NVL(TO_NUMBER(ALLOCBOX.tax_box),1000) TAX_BOX --Here we have to identify, whether this tax box is recoverable or non-rec box.

             , NVL(DECODE(JG.extract_source_ledger,'GL',
                   	 DECODE(JG.prl_no,
               		   'I',(NVL(JG.taxable_amt_funcl_curr ,0)*(NVL(JG.tax_rate,0)/100))*(NVL(JG.tax_recovery_rate,0)/ 100),
               		   'O',((NVL(JG.taxable_amt_funcl_curr,0)*(NVL(JG.tax_rate,0)/100))*(NVL(JG.tax_recovery_rate,0)/ 100)*-1 ))
                     ,DECODE(JG.extract_source_ledger,'AP',NVL(JG.tax_amt_funcl_curr , 0)
                       ,DECODE(JG.extract_source_ledger,'AR',NVL(JG.tax_amt_funcl_curr , 0)*-1)))
                    ,0) TAX_AMOUNT

	     , DECODE(JG.application_id,
			200,'I',
			222,'0',
			101,JG.prl_no)    TAX_CLASS
             , JG.tax_rate_code           TAX_CODE_RATE
             , JG.tax_rate                TAX_RATE
             , JG.trx_id                  TRANSACTION_ID
	     , JG.trx_number		  TRX_NUMBER
             , JG.extract_source_ledger   SOURCE_LEDGER
             , JG.tax_recovery_rate       TAX_RECV_RATE
	     , ALLOCBOX.tax_recoverable_flag TAX_RECOVERABLE_FLAG
	     , JG.extract_source_ledger  EXTRACT_SOURCE_LEDGER
	     , AllOCBOX.allocation_rule_id ALLOCATION_RULE_ID
        FROM    jg_zz_vat_trx_details JG
              , jg_zz_vat_rep_status  JZVRS
              , jg_zz_vat_box_allocs  AllOCBOX
	      , jg_zz_vat_alloc_rules ALLOCRUL
        WHERE   JZVRS.reporting_status_id      = JG.reporting_status_id
	AND     JZVRS.vat_reporting_entity_id  = p_vat_rep_entity_id
        AND     JZVRS.tax_calendar_year        = p_period
        AND     JG.pt_location                 = p_location
        AND     AllOCBOX.vat_transaction_id      = JG.vat_transaction_id
	AND     AllOCBOX.allocation_rule_id   =  ALLOCRUL.allocation_rule_id
	AND	AllOCBOX.period_type = 'ANNUAL'
	ORDER  BY JG.trx_id,
               AllOCBOX.allocation_rule_id;

    -- Record Type to hold amounts
    TYPE r_Box_Amounts IS RECORD(
      taxable_amount   NUMBER,
      tax_amount       NUMBER,
      box_type         VARCHAR2(10),
      tot_box_num      NUMBER,
      tax_rate         NUMBER);

    -- Table Type of record
    TYPE t_Box_Amounts IS TABLE OF r_Box_Amounts
    INDEX BY BINARY_INTEGER;

    -- Variable of above table type
    v_Box_Amounts t_Box_Amounts;
    l_data_found   VARCHAR2(1) := 'N';
    l_tax_box      NUMBER;
    l_count        NUMBER := 0 ;
    ln_stat_no     NUMBER ;
  BEGIN
    ln_stat_no := 1;
    FOR l_pt_avat in c_pt_annual_vat LOOP
    ln_stat_no := 2;
      IF v_box_amounts.EXISTS(l_pt_avat.txbl_rec_box) THEN
         v_box_amounts(l_pt_avat.txbl_rec_box).taxable_amount := NVL(v_box_amounts(l_pt_avat.txbl_rec_box).taxable_amount, 0) + nvl(l_pt_avat.txbl_amount,0);
      ELSE
        v_box_amounts(l_pt_avat.txbl_rec_box).taxable_amount := nvl(l_pt_avat.txbl_amount,0);
        v_box_amounts(l_pt_avat.txbl_rec_box).tot_box_num    := l_pt_avat.total_box;
        v_box_amounts(l_pt_avat.txbl_rec_box).box_type       := 'RECTXBL';
      END IF;
      ln_stat_no := 3;
      IF v_box_amounts.EXISTS(l_pt_avat.txbl_nrc_box) THEN
         v_box_amounts(l_pt_avat.txbl_nrc_box).taxable_amount := NVL(v_box_amounts(l_pt_avat.txbl_nrc_box).taxable_amount, 0) + l_pt_avat.txbl_amount;
      ELSE
        v_box_amounts(l_pt_avat.txbl_nrc_box).taxable_amount := nvl(l_pt_avat.txbl_amount,0);
        v_box_amounts(l_pt_avat.txbl_nrc_box).tot_box_num    := l_pt_avat.total_box;
        v_box_amounts(l_pt_avat.txbl_nrc_box).box_type       := 'NRCTXBL';
      END IF;
      ln_stat_no := 4;
      -- SUM together Tax Amounts for this box
      IF l_pt_avat.tax_class <> 'OFFSET' THEN
        l_tax_box := l_pt_avat.tax_box * 10000 + nvl(l_pt_avat.tax_rate,0) * 100;
        IF v_box_amounts.EXISTS(l_tax_box) THEN
          v_box_amounts(l_tax_box).tax_amount := NVL(v_box_amounts(l_tax_box).tax_amount ,0) + l_pt_avat.tax_amount;
        ELSE
          v_box_amounts(l_tax_box).tax_amount := l_pt_avat.tax_amount;
          v_box_amounts(l_tax_box).tax_rate   := nvl(l_pt_avat.tax_rate,0);
          v_box_amounts(l_tax_box).box_type   := 'TAX';
         END IF;
         ln_stat_no := 5;
       END IF;
       ln_stat_no := 6;
      -- Set data flag to yes
      l_data_found := 'Y';

      IF p_debug_flag = 'Y' then
       fnd_file.put_line(fnd_file.log,'---- Trans Id ------ '||l_pt_avat.transaction_id||'-----');
       fnd_file.put_line(fnd_file.log,'---- Trans Number--- '||l_pt_avat.trx_number||'-----');
       fnd_file.put_line(fnd_file.log,'Tax class information: ' || l_pt_avat.tax_class);
       fnd_file.put_line(fnd_file.log,'Tax Recovery Rate: ' ||l_pt_avat.tax_recv_rate);
       fnd_file.put_line(fnd_file.log,'Tax Recoverable Flag : '||l_pt_avat.tax_recoverable_flag);
       fnd_file.put_line(fnd_file.log,'Taxable box: ' ||l_pt_avat.txbl_nrc_box);
       fnd_file.put_line(fnd_file.log,'Taxable amount: ' ||l_pt_avat.txbl_nrc_amount);
       fnd_file.put_line(fnd_file.log,'Tax box: ' || l_pt_avat.tax_box);
       fnd_file.put_line(fnd_file.log,'Tax Amount: '||l_pt_avat.tax_amount);
       fnd_file.put_line(fnd_file.log,'Total box: '|| l_pt_avat.total_box);
       fnd_file.put_line(fnd_file.log,'Tax rate: ' || l_pt_avat.tax_rate);
       fnd_file.put_line(fnd_file.log,'Tax code: ' || l_pt_avat.tax_code_rate);
       fnd_file.put_line(fnd_file.log,'Extract Source Ledger: ' || l_pt_avat.extract_source_ledger);
       fnd_file.put_line(fnd_file.log,'Allocation Rule ID: ' || l_pt_avat.allocation_rule_id);

    END IF;

    END LOOP;

    IF l_data_found = 'Y' THEN
      FOR i in v_box_amounts.FIRST .. v_box_amounts.LAST LOOP

	IF p_debug_flag = 'Y' and v_box_amounts.EXISTS(i) and i <> 1000 THEN
          fnd_file.put_line(fnd_file.log,'-----------------------------------');
	  IF i > 1000 THEN
            fnd_file.put_line(fnd_file.log,' Box Num      =>'||floor(i/10000));
	  ELSE
	    fnd_file.put_line(fnd_file.log,' Box Num      =>'||i);
	  END IF;
          fnd_file.put_line(fnd_file.log,' Taxable Amount   =>'|| v_box_amounts(i).taxable_amount);
          fnd_file.put_line(fnd_file.log,' Tax Amount       =>'|| v_box_amounts(i).tax_amount);
          fnd_file.put_line(fnd_file.log,' Total Box Number =>'|| v_box_amounts(i).tot_box_num);
          fnd_file.put_line(fnd_file.log,' Tax Rate         =>'|| v_box_amounts(i).tax_rate);
          fnd_file.put_line(fnd_file.log,'-----------------------------------');
        END IF;

        IF v_box_amounts.EXISTS(i) and i <= 1000 THEN
           INSERT INTO jg_zz_vat_trx_gt (  jg_info_n1
                                          ,jg_info_n2
                                          ,jg_info_n3
                                          ,jg_info_n4
                                          ,jg_info_v1
                                        )
                                 VALUES(
                                         i,
                                         v_box_amounts(i).taxable_amount,
                                         v_box_amounts(i).tax_amount,
                                         v_box_amounts(i).tot_box_num,
                                         v_box_amounts(i).box_type
                                        );
        ELSIF v_box_amounts.EXISTS(i) and i > 1000 THEN   --This must be a tax box
          INSERT INTO jg_zz_vat_trx_gt (  jg_info_n1
                                         ,jg_info_n2
                                         ,jg_info_n3
                                         ,jg_info_n5
                                         ,jg_info_v1
                                       )
                                 VALUES(
                                         floor(i/10000) + decode(sign(v_box_amounts(i).tax_rate), -1, 1, 0)
                                         ,v_box_amounts(i).taxable_amount
                                         ,v_box_amounts(i).tax_amount
                                         ,v_box_amounts(i).tax_rate
                                         ,v_box_amounts(i).box_type
                                       );
        END IF;
      END LOOP;
    END IF;

    select count(*) into l_count from jg_zz_vat_trx_gt ;
   IF p_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Number of records inserted into jg_zz_vat_trx_gt table :' || l_count );
   END IF ;
  EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error in Procedure jg_zz_summary_all_pkg.jeptavat: ' || SUBSTR(SQLERRM,1,200));
    fnd_file.put_line(fnd_file.log,'Error at statement:  ' || ln_stat_no);
    RAISE;
  END jeptavat;

  --
  -- +======================================================================+
  -- Name: JGPTPVAT
  --
  -- Description: This procedure used by the Extract when the Concurrent
  --              Program 'Portuguese Periodic VAT Report' is run.
  --
  -- Parameters:  P_VAT_REP_ENTITY_ID   => VAT Reporting Entity ID
  --              P_PERIOD              => Tax Calendar Period
  --              P_LOCATION            => Location Code
  -- +======================================================================+
  --
  PROCEDURE jeptpvat(p_vat_rep_entity_id      IN    NUMBER
                    ,p_period             IN    VARCHAR2
                    ,p_location           IN    VARCHAR2
                    ,x_err_msg            OUT NOCOPY  VARCHAR2)
  IS
    l_data_found     VARCHAR2(1) := 'N';

    -- Record Type to hold amounts
    TYPE r_Box_Amounts IS RECORD(
        taxable_amount NUMBER,
        deduct_tax     NUMBER,
        clear_tax      NUMBER,
        box_type       VARCHAR2(10));

    -- Table Type of record
    TYPE t_Box_Amounts IS TABLE OF r_Box_Amounts
    INDEX BY BINARY_INTEGER;

    -- Variable of above table type
    v_Box_Amounts t_Box_Amounts;

    -- Cursor for holding amounts from JG table
    CURSOR c_pt_periodic_vat
    IS
      SELECT  NVL(TO_NUMBER(al.taxable_box), 1000) 			TAXABLE_BOX

            , NVL(taxable_amt_funcl_curr , 0) 				TAXABLE_AMOUNT

            , NVL(TO_NUMBER(al.tax_box), 1000)          		TAX_BOX

            , NVL(DECODE(DECODE(JG.extract_source_ledger
                                    ,'GL',DECODE(JG.PRL_NO,'I','AP','O','AR')
                                    ,JG.extract_source_ledger)
                    , 'AP', DECODE(SIGN(tax_amt_funcl_curr )
                           , 1 , DECODE(trx_line_class,'AP_CREDIT_MEMO',0,
                                                       'AP_DEBIT_MEMO',0,tax_amt_funcl_curr )
                           , DECODE(reporting_code
                             , 'OFFSET' , 0
                             , DECODE(trx_line_class
                               , 'AP_CREDIT_MEMO' , 0
                               , 'AP_DEBIT_MEMO' , 0
                               ,tax_amt_funcl_curr )))
                    , 'AR', DECODE(reporting_code
                           , 'OFFSET',DECODE(SIGN(tax_amt_funcl_curr ), 1,tax_amt_funcl_curr )
                           , DECODE(SIGN(tax_amt_funcl_curr ), -1, tax_amt_funcl_curr * -1 , 0))), 0) 	DEDUCT_TAX

              , NVL(DECODE(DECODE(JG.extract_source_ledger
                                        ,'GL',DECODE(JG.PRL_NO,'I','AP','O','AR')
                                        ,JG.extract_source_ledger)
                   , 'AP', DECODE(SIGN(tax_amt_funcl_curr )
                          , -1, DECODE(reporting_code
                                , 'OFFSET', tax_amt_funcl_curr * -1
                                , DECODE(trx_line_class
                                  , 'AP_CREDIT_MEMO',tax_amt_funcl_curr *-1
                                  , 'AP_DEBIT_MEMO',tax_amt_funcl_curr * -1,0))
                          , DECODE(trx_line_class
                                , 'AP_CREDIT_MEMO' ,tax_amt_funcl_curr
                                , 'AP_DEBIT_MEMO',tax_amt_funcl_curr,0))
                   , 'AR', DECODE(reporting_code
                          , 'OFFSET',DECODE(SIGN(tax_amt_funcl_curr ), -1,tax_amt* -1 )
                          , DECODE(SIGN(tax_amt_funcl_curr ), 1, tax_amt_funcl_curr , 0))), 0) 		CLEAR_TAX

              , JG.trx_line_class                                       TRX_LINE_CLASS
              , JG.tax_rate_code                                        TAX_RATE_CODE
              , JG.trx_id					        TRX_ID
              , JG.tax_recoverable_flag				        TAX_RECOVERABLE_FLAG
	      , JG.trx_number						TRX_NUMBER
              , DECODE(JG.application_id, 200,'I', 222,'O',
				 	   101,JG.prl_no) 		TAX_CLASS
              ,JG.extract_source_ledger 				EXTRACT_SOURCE_LEDGER
              ,JG.reporting_code 					REPORTING_CODE
      FROM      jg_zz_vat_trx_details JG
              , jg_zz_vat_rep_status  JZVRS
              , jg_zz_vat_box_allocs  AL
      WHERE     decode(JG.extract_source_ledger,'AP',NVL(JG.tax_recoverable_flag,'N'),'Y') ='Y' -- Bug 5561879
      AND       JZVRS.reporting_status_id       = JG.reporting_status_id
      AND       AL.vat_transaction_id           = JG.vat_transaction_id
      AND       AL.period_type                  = 'PERIODIC'
      AND       JZVRS.tax_calendar_period       = p_period
      AND       JZVRS.vat_reporting_entity_id   = p_vat_rep_entity_id
      AND       JG.pt_location                  = p_location ;

    l_count        NUMBER := 0 ;

  BEGIN
    FOR l_pt_periodic_vat IN c_pt_periodic_vat LOOP
      -- SUM together Taxable Amounts for this box
      IF v_box_amounts.EXISTS(l_pt_periodic_vat.taxable_box) THEN
        v_box_amounts(l_pt_periodic_vat.taxable_box).taxable_amount := NVL(v_box_amounts(l_pt_periodic_vat.taxable_box).taxable_amount, 0)
                                                                          + l_pt_periodic_vat.taxable_amount;
      ELSE
        v_box_amounts(l_pt_periodic_vat.taxable_box).taxable_amount := l_pt_periodic_vat.taxable_amount;
        v_box_amounts(l_pt_periodic_vat.taxable_box).box_type := 'TAXABLE';
      END IF;
      -- SUM together Tax Amounts for this box
      IF v_box_amounts.EXISTS(l_pt_periodic_vat.tax_box) THEN
        v_box_amounts(l_pt_periodic_vat.tax_box).deduct_tax := NVL(v_box_amounts(l_pt_periodic_vat.tax_box).deduct_tax ,0) + l_pt_periodic_vat.deduct_tax;
         v_box_amounts(l_pt_periodic_vat.tax_box).clear_tax := NVL(v_box_amounts(l_pt_periodic_vat.tax_box).clear_tax, 0) + l_pt_periodic_vat.clear_tax;
      ELSE
        v_box_amounts(l_pt_periodic_vat.tax_box).deduct_tax := l_pt_periodic_vat.deduct_tax;
        v_box_amounts(l_pt_periodic_vat.tax_box).clear_tax  := l_pt_periodic_vat.clear_tax;
        v_box_amounts(l_pt_periodic_vat.tax_box).box_type := 'TAX';
      END IF;
      l_data_found := 'Y';

        IF p_debug_flag = 'Y' THEN
          fnd_file.put_line(fnd_file.log,'-----------------------------------');
          fnd_file.put_line(fnd_file.log,'---- Trans Id ' || l_pt_periodic_vat.trx_id || '-----');
          fnd_file.put_line(fnd_file.log,'---- Trans Number '||l_pt_periodic_vat.trx_number||'-----');
          fnd_file.put_line(fnd_file.log,' Tax class information => ' || l_pt_periodic_vat.tax_class);
          fnd_file.put_line(fnd_file.log,' Extract Source Ledger => ' ||l_pt_periodic_vat.extract_source_ledger);
          fnd_file.put_line(fnd_file.log,' trx_line_class => ' ||l_pt_periodic_vat.trx_line_class);
          fnd_file.put_line(fnd_file.log,' Reporting Code => ' ||l_pt_periodic_vat.reporting_code);
          fnd_file.put_line(fnd_file.log,' Trx Taxable Amount   =>'|| l_pt_periodic_vat.taxable_amount);
          fnd_file.put_line(fnd_file.log,' Trx Deduct Tax Amount=>'|| l_pt_periodic_vat.deduct_tax);
          fnd_file.put_line(fnd_file.log,' Trx Clear Tax Amount =>'|| l_pt_periodic_vat.clear_tax);
          fnd_file.put_line(fnd_file.log,' Taxable Box   =>  '|| l_pt_periodic_vat.taxable_box);
          fnd_file.put_line(fnd_file.log,' Taxable Amt    => ' ||v_box_amounts(l_pt_periodic_vat.taxable_box).taxable_amount);
          fnd_file.put_line(fnd_file.log,' Tax Box       =>  ' ||l_pt_periodic_vat.tax_box);
          fnd_file.put_line(fnd_file.log,' Deduct Amt    =>  ' ||v_box_amounts(l_pt_periodic_vat.tax_box).deduct_tax);
          fnd_file.put_line(fnd_file.log,' Clear Amt     =>  ' ||v_box_amounts(l_pt_periodic_vat.tax_box).clear_tax);
          fnd_file.put_line(fnd_file.log,' Tax Recoverable Flag => ' || l_pt_periodic_vat.tax_recoverable_flag);
          fnd_file.put_line(fnd_file.log,'-----------------------------------');
        END IF;
    END LOOP;

    IF l_data_found = 'Y' THEN
      FOR i in v_box_amounts.FIRST .. v_box_amounts.LAST LOOP

        IF v_box_amounts.EXISTS(i) THEN
          INSERT INTO jg_zz_vat_trx_gt(
                                      jg_info_n1,
                                      jg_info_n2,
                                      jg_info_n3,
                                      jg_info_n4,
                                      jg_info_v1
                                    )
                              VALUES(
                                     i,
                                     v_box_amounts(i).taxable_amount,
                                     v_box_amounts(i).deduct_tax,
                                     v_box_amounts(i).clear_tax,
                                     v_box_amounts(i).box_type
                                     );
        END IF;
      END LOOP;
    END IF;

   SELECT count(*) into l_count from jg_zz_vat_trx_gt ;
   IF p_debug_flag = 'Y' THEN
     fnd_file.put_line(fnd_file.log,'Number of records inserted into jg_zz_vat_trx_gt table: ' || l_count );
   END IF ;

  EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error in Procedure jg_zz_summary_all_pkg.jeptpvat ' || SUBSTR(SQLERRM,1,200));
    RAISE;
  END jeptpvat;

  --
  -- +======================================================================+
  -- Name: JEITPSSR
  --
  -- Description: This procedure used by the Extract when the Concurrent
  --              Program 'Italian Payables Summary VAT Report' is run.
  --
  -- Parameters:  P_VAT_REP_ENTITY_ID   => VAT Reporting Entity ID
  --              P_PERIOD              => Tax Calendar Period
  --              P_VAR_ON_PURCHASES    => Variation  on Purchases
  --              P_VAR_ON_SALES        => Variationt on Sales
  -- +======================================================================+
  --
 PROCEDURE jeitpssr(p_vat_rep_entity_id   IN    NUMBER
                    ,p_period             IN    VARCHAR2
                    ,p_var_on_purchases   IN    NUMBER
                    ,p_var_on_sales       IN    NUMBER
                    ,x_err_msg            OUT NOCOPY  VARCHAR2)
  IS
    CURSOR c_italian_vat IS
      SELECT
            tax_rate_code                TAX_RATE_CODE
          , tax_rate_code_description    VAT_CODE_DESC
          , trx_id                       TRX_ID
          , DECODE(extract_source_ledger,'AP',taxable_amt*(tax_recovery_rate/100),taxable_amt) TAXABLE_AMT
          , tax_amt                      TAX_AMT
/****************************************************
           Re ordered the query to keep it in sync with the Insert query used
           below
           Bug 7355610 START
****************************************************
          , DECODE(extract_source_ledger,'AP',taxable_amt_funcl_curr*(tax_recovery_rate/100),taxable_amt_funcl_curr) TAXABLE_AMT_FUNCL_CURR
          , tax_amt_funcl_curr           TAX_AMT_FUNCL_CURR
***************************************************/
          , tax_amt_funcl_curr           TAX_AMT_FUNCL_CURR
          , DECODE(extract_source_ledger,'AP',taxable_amt_funcl_curr*(tax_recovery_rate/100),taxable_amt_funcl_curr) TAXABLE_AMT_FUNCL_CURR
/**************************************************
          Bug 7355610 END
**************************************************/
          , doc_seq_id                   DOC_SEQ_ID
          , extract_source_ledger        EXTRACT_SOURCE_LEDGER
          , trx_line_type                TRX_LINE_TYPE
          , accounting_date              ACCOUNTING_DATE
          -- Bug 6238170 Start
          --, tax_type_code                TAX_TYPE_CODE
          , reporting_code               REPORTING_CODE
          -- Bug 6238170 End
          , gl_transfer_flag             GL_TRANSFER_FLAG
          , tax_rate_register_type_code  TAX_RATE_REGISTER_TYPE_CODE
          , trx_currency_code            TRX_CURRENCY_CODE
          , tax_recovery_rate            TAX_RECOVERY_RATE
          , tax_recoverable_flag         TAX_RECOVERABLE_FLAG
          , tax_rate_id                  TAX_RATE_ID
          , trx_number                   TRX_NUMBER
          , DECODE(credit_balance_amt,NULL,0,credit_balance_amt) CREDIT_BALANCE_AMT
          , assessable_value             ASSESSABLE_VALUE
      FROM
            jg_zz_vat_trx_details   JG
          , jg_zz_vat_rep_status    JZVRS
      WHERE JZVRS.reporting_status_id      = JG.reporting_status_id
      AND   JZVRS.vat_reporting_entity_id  = p_vat_rep_entity_id
      AND   JZVRS.tax_calendar_period      = p_period ;

               --Bug:8347134 Start
              CURSOR c_get_last_process_date  IS
                     SELECT
                      max(JZVRS.period_end_date)
                     FROM
                       jg_zz_vat_rep_status JZVRS
                     WHERE
                          JZVRS.vat_reporting_entity_id = p_vat_rep_entity_id
                          AND JZVRS.period_end_date <
                               			(SELECT max(JZVRS1.period_end_date)
                               			FROM jg_zz_vat_rep_status JZVRS1
                              			 WHERE JZVRS1.tax_calendar_period = p_period
                               			AND JZVRS1.vat_reporting_entity_id = p_vat_rep_entity_id
                               			--AND JZVRS1.final_reporting_status_flag = 'S'
                                     )
                           AND  (JZVRS.final_reporting_status_flag = 'S')
                          ;

                CURSOR c_get_balance ( pn_last_process_date DATE) IS
                      SELECT
                         JZVRS.CREDIT_BALANCE_AMT
                   FROM  jg_zz_vat_rep_status    JZVRS
                   WHERE JZVRS.vat_reporting_entity_id  = p_vat_rep_entity_id
                   AND   JZVRS.tax_calendar_period      =( SELECT  JZVRS1.tax_calendar_period
                                                           FROM jg_zz_vat_rep_status JZVRS1
                                                           WHERE
                                                            JZVRS1.vat_reporting_entity_id  = p_vat_rep_entity_id
                                                            AND  TRUNC(JZVRS1.period_end_date) = pn_last_process_date
                                                           AND ROWNUM =1)
                   AND   ROWNUM = 1;
       LAST_PROCESS_DATE DATE;
       CARRY_OVER NUMBER;
       --BUG8347134 End

      l_count  NUMBER := 0 ;
  BEGIN

    FOR l_it_vat IN c_italian_vat LOOP
      INSERT INTO jg_zz_vat_trx_gt
       (
         jg_info_v1
        ,jg_info_v2
        ,jg_info_n1
        ,jg_info_n2 --TAXABLE_AMT_FUNCL_CURR
        ,jg_info_n3
        ,jg_info_n4
        ,jg_info_n5 --TAXABLE_AMT
        ,jg_info_n6
        ,jg_info_v3 --extract_source_ledger
        ,jg_info_v4 --trx_line_type
        ,jg_info_v5
        ,jg_info_v6 --reporting_code
       -- ,jg_info_d1 --bug5573113
        ,jg_info_v7 --tax_rate_register_type_code
        ,jg_info_v8
        ,jg_info_n7
        ,jg_info_v9 --tax_recoverable_flag
        ,jg_info_n9
        ,jg_info_v10
        ,jg_info_n10
        ,jg_info_n11
       )
       VALUES
        (l_it_vat.tax_rate_code
        ,l_it_vat.vat_code_desc
        ,l_it_vat.trx_id
        ,l_it_vat.taxable_amt_funcl_curr --l_it_vat.taxable_amt  bug8587526
/******************************************
Reordered the way of inserting into the temp table as it was not
in sync with the Query used to fetch the values in data definition
jgzzsummaryall.xml
Bug 7355610 START
        ,l_it_vat.taxable_amt_funcl_curr
        ,l_it_vat.tax_amt
        ,l_it_vat.tax_amt_funcl_curr
*****************************************/
        ,l_it_vat.tax_amt
        ,l_it_vat.tax_amt_funcl_curr
       ,l_it_vat.taxable_amt  --l_it_vat.taxable_amt_funcl_curr  bug8587526
/***************************************
Bug 7355610 END
****************************************/
        ,l_it_vat.doc_seq_id
        ,l_it_vat.extract_source_ledger
        ,l_it_vat.trx_line_type
        ,l_it_vat.accounting_date
        -- Bug 6238170 Start
        --,l_it_vat.tax_type_code
        ,l_it_vat.reporting_code
        -- Bug 6238170 End
        --,l_it_vat.gl_transfer_flag --bug5573113
        ,l_it_vat.tax_rate_register_type_code
        ,l_it_vat.trx_currency_code
        ,l_it_vat.tax_recovery_rate
        ,l_it_vat.tax_recoverable_flag
        ,l_it_vat.tax_rate_id
        ,l_it_vat.trx_number
        ,l_it_vat.credit_balance_amt
        ,l_it_vat.assessable_value
       );
   END LOOP;

    --BUG8347134 Start
     --OPEN CURSOR
           OPEN c_get_last_process_date;
           FETCH c_get_last_process_date INTO LAST_PROCESS_DATE;
           CLOSE c_get_last_process_date;

           OPEN c_get_balance(LAST_PROCESS_DATE);
           FETCH c_get_balance INTO CARRY_OVER;
           CLOSE c_get_balance;

           UPDATE jg_zz_vat_trx_gt
           SET jg_info_n10 = CARRY_OVER;
   --BUG8347134 end

     SELECT count(*) into l_count from jg_zz_vat_trx_gt ;
   IF p_debug_flag = 'Y' THEN
    fnd_file.put_line(fnd_file.log,'Number of records inserted into jg_zz_vat_trx_gt table: ' || l_count );
   END IF ;

  EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error in Procedure jg_zz_summary_all_pkg.jeitpssr ' || SUBSTR(SQLERRM,1,200));
    RAISE;
  END jeitpssr;

  FUNCTION a_real_tax_amount(p_payment_amt IN NUMBER
                           , p_tax_amount  IN NUMBER
                           , p_cust_trx_id IN NUMBER)
  RETURN NUMBER IS
    tax_amount  NUMBER;
    l_total_invoice NUMBER;
  BEGIN
    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,' p_payment_amt =>'||p_payment_amt);
    END IF;
    IF p_payment_amt = 0 THEN
/****************************************
      tax_amount := tax_amount;
Commented the above code added the below for Bug 7355610 Start
****************************************/
      tax_amount := p_tax_amount;
/***************************************
Bug 7355610 changes End
***************************************/
    ELSE
      l_total_invoice := a_total_invoices(p_cust_trx_id);
      IF p_func_curr = 'ITL' THEN
        tax_amount := p_payment_amt*(p_tax_amount/nvl(l_total_invoice, 1))+.49;
      ELSE
        tax_amount := p_payment_amt*(p_tax_amount/nvl(l_total_invoice, 1));
      END IF;
    END IF;
    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,' tax_amount =>'||tax_amount);
    END IF;
    RETURN(tax_amount);
  EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error in Procedure jg_zz_summary_all_pkg.a_real_tax_amount ' || SUBSTR(SQLERRM,1,200));
    RAISE;
  END a_real_tax_amount;

  FUNCTION a_real_invoice_amount(p_payment_amt      IN NUMBER
                               , p_invoice_amount   IN NUMBER
                               , p_cust_trx_id      IN NUMBER)
  RETURN NUMBER IS
    invoice_amount NUMBER;
    l_total_invoice NUMBER;
  BEGIN

    IF p_payment_amt = 0 THEN
      invoice_amount := p_invoice_amount;
    ELSE
      l_total_invoice := a_total_invoices(p_cust_trx_id);
      IF p_func_curr = 'ITL' THEN
        invoice_amount := p_payment_amt*(p_invoice_amount/NVL(l_total_invoice, 1))+.49;
      ELSE
        invoice_amount := p_payment_amt*(p_invoice_amount/NVL(l_total_invoice, 1));
      END IF;
    END IF;
    RETURN(invoice_amount);
  EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error in Procedure jg_zz_summary_all_pkg.a_real_invoice_amount ' || SUBSTR(SQLERRM,1,200));
    RAISE;
  END a_real_invoice_amount;

  FUNCTION a_total_invoices(p_cust_trx_id IN NUMBER)
  RETURN NUMBER IS
    invoice_values NUMBER;
  BEGIN
    IF p_func_curr = 'ITL' THEN
      SELECT  SUM(tax_amt_funcl_curr)
      INTO    invoice_values
      FROM    jg_zz_vat_trx_details
      WHERE   trx_id = p_cust_trx_id
      AND     application_id   = 200
      AND     event_class_code = 'PURCHASE_TRANSACTION'
      AND     entity_code      = 'AP_INVOICES';
    ELSE
      SELECT  SUM(tax_amt)
      INTO    invoice_values
      FROM    jg_zz_vat_trx_details
      WHERE   trx_id           = p_cust_trx_id
      AND     application_id   = 200
      AND     event_class_code = 'PURCHASE_TRANSACTION'
      AND     entity_code      = 'AP_INVOICES';
    END IF;
    RETURN(invoice_values);
  EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error in Procedure jg_zz_summary_all_pkg.a_total_invoices ' || SUBSTR(SQLERRM,1,200));
    RAISE;
  END a_total_invoices;

  FUNCTION get_report_format
  RETURN VARCHAR2 IS
    l_detail_summary VARCHAR2(30);
  BEGIN
    IF p_report_name = 'JEBEVA06' THEN
      SELECT meaning
      INTO   l_detail_summary
      FROM   fnd_lookups
      WHERE  lookup_type = 'JEBE_REPORT_FORMAT'
      AND    lookup_code = P_REPORT_FORMAT
      AND    p_report_name = 'JEBEVA06';
      RETURN l_detail_summary;
    ELSE
      RETURN NULL;
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND then
    fnd_file.put_line(fnd_file.log,'Error while fetching Meaning for Lookup Type JEBE_REPORT_FORMAT' || SUBSTR(SQLERRM,1,200));
    l_detail_summary := P_REPORT_FORMAT;
    RETURN l_detail_summary;
  WHEN OTHERS then
    fnd_file.put_line(fnd_file.log,'Error while fetching Meaning for Lookup Type JEBE_REPORT_FORMAT' || SUBSTR(SQLERRM,1,200));
    l_detail_summary := P_REPORT_FORMAT;
    RETURN l_detail_summary;
  END get_report_format;

  FUNCTION get_location_name
  RETURN VARCHAR2 IS
    l_location_name VARCHAR2(100);
  BEGIN
    IF p_report_name = 'JEPTAVAT' OR p_report_name = 'JEPTPVAT' THEN
      SELECT  FFV.description
      INTO    l_location_name
      FROM    fnd_flex_values_vl  FFV
            , fnd_flex_value_sets FFVS
      WHERE   FFV.flex_value_set_id    = FFVS.flex_value_set_id
      AND     FFVS.flex_value_set_name = 'JEPT_TAX_LOCATION'
      AND     FFV.flex_value           = P_LOCATION;
    ELSE
      l_location_name := NULL;
    END IF;
    RETURN l_location_name;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line(fnd_file.log,'Location Name for Location Code ' || P_LOCATION || ' is not found');
    l_location_name := P_LOCATION;
    RETURN l_location_name;
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error while fetching Location Name' || SUBSTR(SQLERRM,1,200));
    l_location_name := P_LOCATION;
    RETURN l_location_name;
  END;

  FUNCTION get_start_exempt_limit
  RETURN NUMBER
  IS
    l_starting_limit NUMBER;
	l_period_date date;
  BEGIN
    -- Get the date for the period
	SELECT DISTINCT RPS.period_start_date
	INTO l_period_date
	FROM JG_ZZ_VAT_REP_STATUS RPS
    WHERE RPS.TAX_CALENDAR_PERIOD = P_PERIOD
    AND RPS.VAT_REPORTING_ENTITY_ID  = P_VAT_REP_ENTITY_ID;

    l_starting_limit := 0;
    SELECT  NVL(jiy.adjusted_limit_amount, 0)
    INTO     l_starting_limit
    FROM     je_it_year_ex_limit JIY,
             fnd_lookups fl
    WHERE    fl.lookup_type = 'JEIT_MONTH'
    AND      JIY.month = fl.lookup_code
    AND      JIY.year  = to_char(l_period_date,'RRRR')
    AND      JIY.month = to_char(l_period_date,'MM')
    AND      JIY.legal_entity_id = P_LEGAL_ENTITY_ID ;
    fnd_file.put_line(fnd_file.log,'Starting Exemption Limit for Period => : '||l_starting_limit);
    RETURN l_starting_limit;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line(fnd_file.log,'Exeption Amount for beginning of Period not found' || SUBSTR(SQLERRM,1,200));
    RETURN 0;
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error while fetching Available Exemption at Beginning of Period ' || SUBSTR(SQLERRM,1,200));
    RETURN 0;
  END get_start_exempt_limit;

  FUNCTION get_adjustment_exempt_limit
  RETURN NUMBER
  IS
    l_adjustment_limit NUMBER;
	l_period_date date;
  BEGIN
    -- Get the date for the period
	SELECT DISTINCT RPS.period_start_date
	INTO l_period_date
	FROM JG_ZZ_VAT_REP_STATUS RPS
    WHERE RPS.TAX_CALENDAR_PERIOD = P_PERIOD
    AND RPS.VAT_REPORTING_ENTITY_ID  = P_VAT_REP_ENTITY_ID;

    l_adjustment_limit := 0;
    SELECT  NVL(JIY.adjusted_limit_amount, 0)
    INTO     l_adjustment_limit
    FROM     je_it_year_ex_limit JIY
    WHERE    JIY.year  = to_char(l_period_date,'RRRR')
    AND      JIY.month = to_char(l_period_date,'MM')
    AND      JIY.legal_entity_id = P_LEGAL_ENTITY_ID ;
    fnd_file.put_line(fnd_file.log,'Adjustment Amount =>: '||l_adjustment_limit);
    RETURN l_adjustment_limit;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line(fnd_file.log,'Adjustments Yearly Exemption Limit not found' || SUBSTR(SQLERRM,1,200));
    RETURN 0;
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error while getting Adjustment to Yearly Exemption Limit ' || SUBSTR(SQLERRM,1,200));
    RETURN 0;
  END get_adjustment_exempt_limit;

  FUNCTION get_old_debit_vat
  RETURN NUMBER
  IS
  BEGIN
    -- This Code will return the Previous Period VAT Credit Amount
    -- This is used by the XML Element OLD_DEBIT_VAT
    RETURN 0;
  EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,'Error while getting Previous Period VAT Credit ' || SUBSTR(SQLERRM,1,200));
    RETURN 0;
  END get_old_debit_vat;

FUNCTION JEITPSSR_AMOUNT_TO_PAY(A_TOT_TOT_TAX_AMT_SUM IN  NUMBER,
        B_TOT_TAX_AMT_SUM IN  NUMBER,
        D_TOT_TAX_AMT_SUM IN  NUMBER,
        D_VAT_REC_SUM IN  NUMBER,
        C_VAT_REC_SUM IN  NUMBER,
        C_VAT_NON_RECC_SUM IN  NUMBER)
RETURN NUMBER IS

    AMOUNT_TO_PAY NUMBER;
    CARRY_OVER NUMBER;
    FINAL_FLAG VARCHAR2(1);
    LAST_PROCESS_DATE DATE;
    INVALID_CARRY_OVER EXCEPTION;
    l_period_start_date  DATE;
    LOG_MESSAGE VARCHAR2(1000);

    /* Bug:8237932 This cursor is no longer needed to get the
    credit_balance_amount,flag_status and last_processed_date.
    CURSOR c_get_details IS
    SELECT
          JZVRS.CREDIT_BALANCE_AMT,
          JZVRS.FINAL_REPORTING_STATUS_FLAG,
          jg_zz_vat_rep_utility.get_last_processed_date(p_vat_rep_entity_id,'ALL','FINAL REPORTING') LAST_PROCESS_DATE
    FROM  jg_zz_vat_rep_status    JZVRS
    WHERE JZVRS.vat_reporting_entity_id  = p_vat_rep_entity_id
    AND   JZVRS.tax_calendar_period      = p_period
    AND   ROWNUM = 1;
    Bug:8237932*/

    CURSOR c_get_period_start_date IS
       SELECT jg_info_d2 FROM jg_zz_vat_trx_gt WHERE jg_info_v30 = 'H';

       /*Added three new cursors:
       c_get_last_process_date ,c_get_balance,c_get_flag*/
      --Bug:8237932
          CURSOR c_get_last_process_date  IS
                 SELECT
                  max(JZVRS.period_end_date)

                 FROM
                   jg_zz_vat_rep_status JZVRS
                 WHERE
                      JZVRS.vat_reporting_entity_id = p_vat_rep_entity_id
                      AND JZVRS.period_end_date <
                           			(SELECT max(JZVRS1.period_end_date)
                           			FROM jg_zz_vat_rep_status JZVRS1
                          			 WHERE JZVRS1.tax_calendar_period = p_period
                           			AND JZVRS1.vat_reporting_entity_id = p_vat_rep_entity_id
                           			--AND JZVRS1.final_reporting_status_flag = 'S'
                                 )
                       AND JZVRS.final_reporting_status_flag = 'S'
                       AND JZVRS.tax_calendar_period <> p_period;

            CURSOR c_get_balance ( pn_last_process_date DATE) IS
                  SELECT
                     JZVRS.CREDIT_BALANCE_AMT
               FROM  jg_zz_vat_rep_status    JZVRS
               WHERE JZVRS.vat_reporting_entity_id  = p_vat_rep_entity_id
               AND   JZVRS.tax_calendar_period      =( SELECT  JZVRS1.tax_calendar_period
                                                       FROM jg_zz_vat_rep_status JZVRS1
                                                       WHERE
                                                        JZVRS1.vat_reporting_entity_id  = p_vat_rep_entity_id
                                                        AND  TRUNC(JZVRS1.period_end_date) = pn_last_process_date
                                                       AND ROWNUM =1)
               AND   ROWNUM = 1;

             CURSOR c_get_flag IS
                     SELECT
                     JZVRS.FINAL_REPORTING_STATUS_FLAG
                     FROM  jg_zz_vat_rep_status    JZVRS
                    WHERE JZVRS.vat_reporting_entity_id  = p_vat_rep_entity_id
                     AND   JZVRS.tax_calendar_period      = p_period
                 AND   ROWNUM = 1;

      --Bug:8237932
 BEGIN

      /*Bug:8237932
      OPEN  c_get_details;
      FETCH c_get_details INTO CARRY_OVER,FINAL_FLAG,LAST_PROCESS_DATE;
      CLOSE c_get_details;
      */
      LAST_PROCESS_DATE := NULL;
        --OPEN CURSOR
       OPEN c_get_last_process_date;
       FETCH c_get_last_process_date INTO LAST_PROCESS_DATE;
       CLOSE c_get_last_process_date;

       OPEN c_get_balance(LAST_PROCESS_DATE);
       FETCH c_get_balance INTO CARRY_OVER;
       CLOSE c_get_balance;

       OPEN c_get_flag;
       FETCH c_get_flag INTO FINAL_FLAG;
       CLOSE c_get_flag;
    --Bug:8237932

      OPEN c_get_period_start_date;
      FETCH c_get_period_start_date INTO l_period_start_date;
      CLOSE c_get_period_start_date;

     fnd_file.put_line(fnd_file.log,'In jg_zz_summary_all_pkg.JEITPSSR_AMOUNT_TO_PAY ..FINAL_FLAG:'||FINAL_FLAG);
	 fnd_file.put_line(fnd_file.log,'In jg_zz_summary_all_pkg.JEITPSSR_AMOUNT_TO_PAY ..CARRY_OVER :'||TO_CHAR(CARRY_OVER));
	 fnd_file.put_line(fnd_file.log,'In jg_zz_summary_all_pkg.JEITPSSR_AMOUNT_TO_PAY ..LAST_PROCESS_DATE :'||TO_CHAR(LAST_PROCESS_DATE));

      IF  FINAL_FLAG = 'S' THEN
        IF CARRY_OVER IS NULL THEN
          IF LAST_PROCESS_DATE IS NULL THEN
            CARRY_OVER := 0;
          ELSE
            AMOUNT_TO_PAY := 0;

            fnd_message.set_name('JE', 'JE_IT_VAT_AP_SUM_CR_BALANCE');
            fnd_message.set_token('DATE', LAST_PROCESS_DATE);
            LOG_MESSAGE := fnd_message.get;

            RAISE  INVALID_CARRY_OVER;
          END IF;
        ELSIF (LAST_PROCESS_DATE+1) <> l_period_start_date THEN

          fnd_message.set_name('JE', 'JE_IT_VAT_GAP_IN_FINAL_PROCESS');
          fnd_message.set_token('DATE', LAST_PROCESS_DATE);
          LOG_MESSAGE := fnd_message.get;

         	RAISE  INVALID_CARRY_OVER;
       END IF;
     END IF;

    AMOUNT_TO_PAY := (A_TOT_TOT_TAX_AMT_SUM + B_TOT_TAX_AMT_SUM ) - D_TOT_TAX_AMT_SUM + D_VAT_REC_SUM
             + P_VAR_ON_SALES - C_VAT_REC_SUM - P_VAR_ON_PURCHASES + NVL(CARRY_OVER,0);


 /*Commented this part of code for bug 7633948.This functionaliy is implemented in
     JEITPSSR_AMOUNT_TO_PAY_UPDATE function
IF  FINAL_FLAG = 'S' THEN

  IF AMOUNT_TO_PAY >= 0 THEN
    CARRY_OVER := 0;
  ELSE
    CARRY_OVER := AMOUNT_TO_PAY;
  END IF;

  IF TEMP_FLAG = 0 THEN

    UPDATE jg_zz_vat_rep_status SET CREDIT_BALANCE_AMT=CARRY_OVER
    WHERE vat_reporting_entity_id  = p_vat_rep_entity_id
    AND   tax_calendar_period = p_period;

    TEMP_FLAG := 1;

  END IF;

    END IF;for bug 7633948*/
  fnd_file.put_line(fnd_file.log,'In jg_zz_summary_all_pkg.JEITPSSR_AMOUNT_TO_PAY ' || to_char(AMOUNT_TO_PAY));
    RETURN(AMOUNT_TO_PAY);

  EXCEPTION
    WHEN INVALID_CARRY_OVER THEN
      fnd_file.put_line(fnd_file.log,LOG_MESSAGE);
      raise_application_error(-20010,LOG_MESSAGE);
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'Error in Procedure jg_zz_summary_all_pkg.JEITPSSR_AMOUNT_TO_PAY ' || SUBSTR(SQLERRM,1,200));
      raise_application_error(-20011,'Error in Procedure jg_zz_summary_all_pkg.JEITPSSR_AMOUNT_TO_PAY ' || SUBSTR(SQLERRM,1,200));
  END JEITPSSR_AMOUNT_TO_PAY;

  /****Added below function JEITPSSR_AMOUNT_TO_PAY_UPDATE for bug 7633948***/
  FUNCTION JEITPSSR_AMOUNT_TO_PAY_UPDATE(AMOUNT_TO_PAY IN NUMBER)
  RETURN BOOLEAN IS

      FINAL_FLAG VARCHAR2(1);
      CARRY_OVER NUMBER;
      --INVALID_CARRY_OVER EXCEPTION;
      --LOG_MESSAGE VARCHAR2(240);
      CURSOR c_get_details IS
      SELECT
            JZVRS.FINAL_REPORTING_STATUS_FLAG
       FROM  jg_zz_vat_rep_status    JZVRS
      WHERE JZVRS.vat_reporting_entity_id  = p_vat_rep_entity_id
      AND   JZVRS.tax_calendar_period      = p_period
      AND   ROWNUM = 1;
  BEGIN
  IF p_report_name = 'JEITPSSR' THEN
  fnd_file.put_line(fnd_file.log,'Called JEITPSSR_AMOUNT_TO_PAY_UPDATE function');
  	OPEN  c_get_details;
        FETCH c_get_details INTO FINAL_FLAG;
        CLOSE c_get_details;
          fnd_file.put_line(fnd_file.log,'In JEITPSSR_AMOUNT_TO_PAY_UPDATE FINAL_FLAG:'||FINAL_FLAG);
        IF FINAL_FLAG='S' THEN

                IF AMOUNT_TO_PAY >= 0 THEN
                  CARRY_OVER := 0;
                ELSE
                  CARRY_OVER := AMOUNT_TO_PAY;
                END IF;
                fnd_file.put_line(fnd_file.log,'In JEITPSSR_AMOUNT_TO_PAY_UPDATE TEMP_FLAG:'||TO_CHAR(TEMP_FLAG));
                fnd_file.put_line(fnd_file.log,'In JEITPSSR_AMOUNT_TO_PAY_UPDATE AMOUNT_TO_PAY:'||TO_CHAR(AMOUNT_TO_PAY));
				fnd_file.put_line(fnd_file.log,'In JEITPSSR_AMOUNT_TO_PAY_UPDATE CARRY_OVER:'||TO_CHAR(CARRY_OVER));

                IF TEMP_FLAG = 0 THEN

                  UPDATE jg_zz_vat_rep_status SET CREDIT_BALANCE_AMT=CARRY_OVER
                  WHERE vat_reporting_entity_id  = p_vat_rep_entity_id
                  AND   tax_calendar_period = p_period;

                  TEMP_FLAG := 1;
                END IF;
          END IF;
   END IF;
              RETURN (TRUE);
  EXCEPTION
     -- WHEN INVALID_CARRY_OVER THEN
     --  fnd_file.put_line(fnd_file.log,LOG_MESSAGE);
      WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,'Error in Procedure jg_zz_summary_all_pkg.JEITPSSR_AMOUNT_TO_PAY_UPDATE ' || SUBSTR(SQLERRM,1,200));
     RETURN (FALSE);
  END JEITPSSR_AMOUNT_TO_PAY_UPDATE;

  /******Added the below function JEILR835 INV_NUM for Bug 7427956*********/
  FUNCTION JEILR835_INV_NUM ( p_str  VARCHAR2) RETURN VARCHAR2 IS
    l_str VARCHAR2(100);
    l_char VARCHAR2(2);
    l_len NUMBER;
    l_start NUMBER :=1;
    BEGIN
      l_len:=NVL(LENGTH(p_str), 0);
      l_str :='';
      FOR l_start IN 1..l_len LOOP
        l_char:= SUBSTRB(p_str,l_start,1);
        IF (l_char IN ('1','2','3','4','5','6','7','8','9','0')) THEN
          l_str:=l_str||l_char;
        END IF;
      END LOOP;
    l_len:=NVL(LENGTH(l_str), 0);
    IF (l_len > 9) THEN
      l_start:=l_len-8;
      l_str:=substrb(l_str,l_start,9);
    END IF;
    RETURN (l_str);
  END JEILR835_INV_NUM;

END JG_ZZ_SUMMARY_ALL_PKG;

/
