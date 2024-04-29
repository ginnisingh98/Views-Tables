--------------------------------------------------------
--  DDL for Package Body JAI_AP_TDS_ETDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_TDS_ETDS_PKG" AS
/* $Header: jai_ap_tds_etds.plb 120.15.12010000.21 2010/04/09 10:22:48 bgowrava ship $ */

/*---------------------------------------------------------------------------------------------------------
change history for jai_ap_tds_etds_pkg.sql

SlNo.  DD/MM/YYYY       Author and Details of Modifications
----------------------------------------------------------------------------------------------------------
1      22/03/2004       Vijay Shankar for Bug# 3463974, Version: 619.1
                          This Package is created for enhancement to capture all the eTDS format, data Requirements in different procedures

2      13/04/2004       Vijay Shankar for Bug# 3603545 (also fixed 3567864), Version: 619.2
                          TDS and Base Taxable amounts are not populated correctly in
                          JAI_AP_ETDS_T table for Vendor Prepayment Invoices
                          TDS Amount is wrongly populated as tds_tax_rate is used instead of
                          tds_tax_rate/100 to calculated tds amount of prepayment applied amount.
                          Base amount is not at all reduced to the extent of prepayment applied which is resolved with this bug.

                          Previous Bug# 3463974 is Obsoleted with this bug

3.     21/06/2004       Aparajita for bug#3708878. Version#115.1
                          Section was not getting printed properly for deductee details. Call to getSectionCode was missing  for deductee section.

4.     24/05/2005       Ramananda for bug# 4388958 File Version: 116.1
                          Changed AP Lookup code from 'TDS' to 'INDIA TDS'

5.     08-Jun-2005      File Version 116.3. Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
                          as required for CASE COMPLAINCE.

6.     14-Jun-2005      rchandan for bug#4428980, Version 116.4
                          Modified the object to remove literals from DML statements and CURSORS.
                          This activity is done as a part of R12 initiatives.

7.     14-Jun-2205      Brathod for Bug# 4428712, Version 116.5
                        Issue:
                          Impact of Bank Account Project on IL Objects
                        Solution:
                          In R12 Bank Account Project will eliminate the redudant information maintained
                          by each diffrent applications and improve the information sharing.
                          As per the documentation AP_BANK_ACCOUNTS and AP_BANK_BRANCHES tables will
                          hold information only for external bank accounts.  For internal bank accounts
                          as per the new model HZ_PARTIES and CE_BANK_ACCOUNT, CE_BANK_ACCT_USES_ALL
                          will be used.  The code in this procedure is modfied to refer to this new
                          model as part of R12 Initiative.

8.     29-Jun-2005      ssumaith - bug#4448789 - removal of hr_operating_units.legal_entity_id from this trigger.

9.     17-Aug-2005      Ramananda for bug#4555466 during R12 Sanity Testing. File Version 120.2
                        Instead of fnd_common_lookups table, ja_lookups table is being referred

10     07/12/2005   Hjujjuru for the bug 4866533 File version 120.3
                    added the who columns in the insert into tables JAI_AP_ETDS_REQUESTS and JAI_AP_ETDS_T.
                    Dependencies Due to this bug:-
                    None

11    23/12/2005   Hjujjuru for Bug 4889272, File Version 120.4
                   Removed the legal_entity_id parameter in the
                   procedures populate_details and generate_flat_file.
                   Removed the profile_org_id from the generate_flat_file procedure.
                   Modified the code to eliminate references to the
                   legal_entity_id and Operating Unit id.
                   Changed the position of the parameter p_organization_id in the
                   generate_flat_file procedure.

12   27/03/2006    Hjujjuru for Bug 5096787 , File Version 120.5
                   Spec changes have been made in this file as a part og Bug 5096787.
                   Now, the r12 Procedure/Function specs is in this file are in
                   sync with their corrsponding 11i counterparts



13   11/05/2007    sacsethi for bug 5647248  + 5658040

		The following changes are done to make use of the same package for 26Q and 27Q
                Modified the populate_details procedure:
                1.added two parameters p_include_list,p_exclude_list in the call to populate_details,quarterly_returns
                and generate_etds_returns.
                2.Declared lv_list which is of varray type
                3.added populate_include_exclude_list procedure in populate_details.
                4.declared cursor c_prg_name which will fetch the concurrent program name in quarterly_returns procedure.
                Based on this concurrent program name form_number is changed.

                Report has been modified to generate Form 27A along with eTDS Quarterly Returns.
                Added a call to the Concurrent JAINTDSA in the quarterly_returns procedure.


                Added the update clause to modify the taxabale_amount of ja_in_ap_etds_temp
                based on the taxable_amount of jai_ap_tds_thhold_trxs table.
                In case of threshold transition and rollback transactions, the
                taxable amount should be 0 for the differential invoice that has been created.
                Hence, implemented this change.

14.  28-jun-2007  CSahoo for bug#6158875
									modified the num of input parameters to yearly_returns procedure.
									added the call to the function Fnd_date.canoncical_to_date.

15.  02-Jul-2007  CSahoo for bug#6158875, file version 120.10
									modified the num of input parameters to querterly_returns procedure.
									added the call to the function Fnd_date.canoncical_to_date.


16.  03/07/2007   CSAHOO FOR BUG#6158875, File Version 120.11
									modified the following cursors c_tds_payment_check_id,c_base_payment_check_id,c_check_dtls.

17.  27/08/2007   CSahoo for bug#5975168, File Version 120.12
									Added a check for status_lookup_code in cursor c_check_dtls

18.  27/08/2007   Csahoo for bug#6070014, File version 120.13
									Changed the format mask from hardcoded value to
									assigned value. This is done in procedure
									create_quart_deductee_dtl

19.  13/02/2008   Lakshmi Gopalsami for bug# 6796765	File Version 120.5.12000000.4
		 1. Changed the function getSectionCode. Replaced the hardcoded value with p_string.
		 2. Changed in procedure create_challan_detail. Added upper for both p_challan_section and Sec.().
		 3. Changed in procedure create_deductee_detail. Added upper for both p_deductee_section and Sec.().
		 4. Changed in procedure create_quart_challan_dtl.
			a)  Added input parameter p_form_name to print the section code depending on the section.
			b)  Declared variables to select the section truncation depending on the form name.
			c)  Added logic to get the section code as 194C, 194D, 195 etc. from SEC. 194(C) and then check whether it can be converted to a
			    number. If so, the value will be printed in flat file else extract the value from 2nd character in flat file.
			    hardcoded the values of 194BB, 194EE, 194LA as per the details provided in NSDL as separate logic cannot be derived.
			d)  Changed the UTL_FILE.PUT_LINE parameter from getsectioncode to lv_output_string.

20.	15/02/2008	JMEENA for bug#6647362 File Version 120.5.12000000.4
				Added 5000 UTL_FILE buffer size for bug#6647362

21.	20/02/2008	JMEENA for bug#4600778 File Version 120.5.12000000.5
			       Removed the cursor c_bank_branch_code and added column bsr_code in the cursor c_tds_payment_check_id and fetched the value in v_bank_branch_code.

22     08-Oct-2008        Bgowrava for Bug#6195027, File Version 120.5.12000000.5
                                         Added sh_cess_rate in cursor c_tax_rates and defined related variables. Included ln_sh_cess_amt in ln_cess_amt.

23.     24-Oct-2008     Bgowrava for bug#7485031, File version 115.14.6017.12
                                     Added code to use the include_flag and exclude_flag while determining the sections which need to be considered to be
			     inserted into the table JAI_AP_ETDS_T for the current execution. Also included code changes for bug 6281440

24.     06-Aug-2007     Forward Port Bug 6329774
                        Changed the challan date to base_invoice_date while printing deductee details.

25.    18-Oct-2008       Bgowrava for bug#6030953, File version 120.15.12010000.7, 120.21
                                        Mandatory details to be printed in Form 27 A which is called from eTDS Quaterly.   Following parameters are included in respective procedures
		                   p_RespPers_flat_no
		                   p_RespPers_prem_bldg
		                   p_RespPers_rd_st_lane
		                    p_RespPers_area_loc
		                   p_RespPers_tn_cty_dt
		                   p_RespPers_tel_no
		                   p_RespPers_email
		            and parameter p_RespPersAddress is removed.
		       Affected procedures are :
		                 create_quarterly_fh
		                  validate_batch_header
		                  quarterly_returns
		                 generate_etds_returns
		        Also passed the parameters while submitting the request  for Form 27A. Included p_deductor_status

26.     28-May-2009     Bug 8505050 - Lines with amount as 0 for TDS is also displayed in the e-TDS flat file which causes issue during upload
                        Added the having clause to prevent entries in e-TDS file with 0 Tax amount

27.     15-Sep-2009     Changes for eTDS/eTCS File Validation Utility Changes - Bug 8880543

28. 09-OCT-2009  Added by Bgowrava for Bug#9005248
                 Replace the literal 'PANNOTREQD' to 'PANNOTAVBL' according to the latest notification.

29.  06-Jan-2010   Xiao Lv for Bug#7662155
			  Added New cursor c_get_tds_inv_det in the populate_details procedure to calculate the surcharge amount at threshold
			  transition when surcharge gets applicable.

30.  08-apr-2010    Bgowrava for Bug#9494515
                                 Modified the query of the cursor c_pan_number and included the view jai_rgm_org_regns_v instead of the three table names.
                                 This would fetch the correct PAN number for the organization.
---------------------------------------------------------------------------------------------------------*/

  /*Bug 8880543 - Changes for eTDS/eTCS FVU Changes - Start*/

  FUNCTION VALIDATE_ALPHA_NUMERIC(p_str VARCHAR2, p_length NUMBER) RETURN VARCHAR2 IS
  lv_resp     VARCHAR2(10);
  BEGIN
 	FOR i in
   	  (SELECT TRANSLATE(UPPER(substr(p_str, 1, 5)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','AAAAAAAAAAAAAAAAAAAAAAAAAA') src_str1,
                  TRANSLATE(substr(p_str, 6, 4),'0123456789','0000000000') src_str2,
                  TRANSLATE(UPPER(substr(p_str, 10, 1)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','AAAAAAAAAAAAAAAAAAAAAAAAAA') src_str3,
                  'AAAAA0000A' dest_str
 	   FROM 	 dual) LOOP

 		IF (i.src_str1 || i.src_str2 || i.src_str3) = i.dest_str or p_str = 'PANNOTAVBL' then
 		  lv_resp := 'VALID';
 		ELSE
 		  lv_resp := 'INVALID';
 		END IF;

 	  EXIT;
 	END LOOP;

    RETURN lv_resp;
  END;

  PROCEDURE chk_err (p_err IN VARCHAR2,
                       p_message IN VARCHAR2) IS
  BEGIN
    IF (p_err = 'E') THEN
        FND_FILE.put_line(FND_FILE.log, p_message);
        RAISE_APPLICATION_ERROR(-20099, p_message, true);
    ELSIF  (p_err in ('N', 'S')) THEN
        FND_FILE.put_line(FND_FILE.log, p_message);
    END IF;
  END chk_err;

  PROCEDURE get_attr_value (p_org_id IN NUMBER,
                            p_attr_code IN VARCHAR2,
                            p_attr_val OUT NOCOPY VARCHAR2,
                            p_err OUT NOCOPY VARCHAR2,
                            p_return_message OUT NOCOPY VARCHAR2
                            ) IS

  CURSOR c_org_exists (p_org_id NUMBER)
  IS
  select '1'
  from jai_rgm_definitions jrd,
       jai_rgm_parties jrp
  where jrd.regime_code = 'TDS'
  and   jrd.regime_id = jrp.regime_id
  and   jrp.organization_id = p_org_id;

  CURSOR c_party_setup (p_attr_code VARCHAR2, p_org_id NUMBER)
  IS
  select jrpr.attribute_value
  from jai_rgm_parties jrp,
       jai_rgm_definitions jrd,
       jai_rgm_party_regns jrpr,
       jai_rgm_registrations jrr
  where jrd.regime_code = 'TDS'
  and jrd.regime_id = jrp.regime_id
  and jrp.regime_org_id = jrpr.regime_org_id
  and jrr.attribute_code = p_attr_code
  and jrp.organization_id = p_org_id
  and jrr.registration_id = jrpr.registration_id;

  CURSOR c_regime_setup (p_attr_code VARCHAR2)
  IS
  select jrr.attribute_value
  from jai_rgm_definitions jrd,
       jai_rgm_registrations jrr
  where jrd.regime_code = 'TDS'
  and jrd.regime_id = jrr.regime_id
  and jrr.attribute_code = p_attr_code;

  l_org_exists NUMBER;
  l_attr_val   VARCHAR2(240);

  BEGIN

    l_org_exists := 0;
    l_attr_val := NULL;

    OPEN c_org_exists (p_org_id);
    FETCH c_org_exists INTO l_org_exists;
    CLOSE c_org_exists;

    IF (l_org_exists = 0) THEN
        p_return_message := 'Regime Registration Setup does not exist for the current Organization';
        p_err := 'E';
        p_attr_val := NULL;
        return;
    END IF;

    OPEN c_party_setup (p_attr_code, p_org_id);
    FETCH c_party_setup INTO l_attr_val;
    CLOSE c_party_setup;

    IF (l_attr_val IS NULL) THEN
        OPEN c_regime_setup (p_attr_code);
        FETCH c_regime_setup INTO l_attr_val;
        CLOSE c_regime_setup;
    END IF;

    IF (l_attr_val IS NULL) THEN
        p_return_message := 'Attribute ' || p_attr_code || ' is not defined';
        p_err := 'N';
        p_attr_val := NULL;
        return;
    ELSE
        p_attr_val := l_attr_val;
        p_return_message := 'Attribute ' || p_attr_code || ' = ' || p_attr_val;
        p_err := 'S';
    END IF;

  END get_attr_value;

  /*Bug 8880543 - Changes for eTDS/eTCS FVU Changes - End*/


  FUNCTION formatAmount( p_amount IN NUMBER) RETURN VARCHAR2 IS
  BEGIN

    -- return (replace(to_char(ROUND(nvl(p_amount,0), 2), '999999999999D99'),'.'));
    return ( to_char(ROUND(nvl(p_amount,0), 2)*100 ) );
  END formatAmount;

  FUNCTION getSectionCode( p_section IN VARCHAR2,  p_string IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 IS
  BEGIN

    IF p_section IS NOT NULL THEN
      -- Bug 6796765. Added by Lakshmi Gopalsami
      -- Changed to p_string instead of hardcoded value
      return replace(translate(p_section, p_string, ' '), ' ');
    ELSE
      return ' ';
    END IF;

  END getSectionCode;

  PROCEDURE openFile(
    p_directory IN VARCHAR2,
    p_filename IN VARCHAR2
  ) IS

  BEGIN

    v_filehandle := UTL_FILE.fopen(p_directory, p_filename, 'W', 5000); --Added 5000 buffer size for bug#6647362

    v_utl_file_dir  := p_directory;
    v_utl_file_name := p_filename;

  END openFile;

  PROCEDURE closeFile IS
  BEGIN
    UTL_FILE.fclose(v_filehandle);
  END closeFile;

  PROCEDURE populate_details(
    p_batch_id IN NUMBER,
   -- p_legal_entity_id IN NUMBER, -- Harshita for Bug 4889272
    p_org_tan_num IN VARCHAR2,
    p_tds_vendor_id IN NUMBER,
    p_tds_vendor_site_id IN NUMBER,
    p_tds_inv_from_date IN DATE,
    p_tds_inv_to_date IN DATE,
    p_etds_yearly_returns VARCHAR2,
    p_include_list  IN  VARCHAR2,      --Date 11-05-2007 by Sacsethi for bug 5647248
    p_exclude_list  IN  VARCHAR2
  )
  IS
    v_tds_check_id    NUMBER(15);
    v_prepay_inv_id_of_tds  NUMBER(15);
    v_bank_account_id NUMBER(15);
    v_bank_account_name VARCHAR2(50);  -- added by csahoo for BUG#6158875

    v_temp_challan_num  VARCHAR2(50);
    v_temp_challan_date DATE;
    v_temp_bank     NUMBER(15);
    v_temp_bank_acc_name VARCHAR2(50);  -- added by csahoo for BUG#6158875

    v_statement_id    VARCHAR2(3);
    v_debug_base_invid    NUMBER(15);
    v_debug_tds_invid   NUMBER(15);

    v_base_check_date DATE;
    v_tds_check_date  DATE;
    v_challan_num   VARCHAR2(50);
    v_challan_date    DATE;
    v_bank_branch_code  HZ_ORGANIZATION_PROFILES.BANK_OR_BRANCH_NUMBER%TYPE;

    v_challan_err   VARCHAR2(100);
    v_deductee_err    VARCHAR2(100);

    v_base_invoice_check_id NUMBER(15);
    v_prepay_inv_id_of_base NUMBER(15);

    v_payment_id NUMBER;
    v_prepay_invoice_id NUMBER;
    v_prepayment_amount_applied NUMBER;

    /* Bug 4353842. Added by Lakshmi Gopalsami */
    ln_check_number        ap_checks_all.check_number%TYPE;
    ln_tax_rate            JAI_CMN_TAXES_ALL.tax_rate%TYPE;
    ln_tds_rate            JAI_CMN_TAXES_ALL.tax_rate%TYPE;
    ln_surcharge_rate      JAI_CMN_TAXES_ALL.surcharge_rate%TYPE;
    ln_cess_rate           JAI_CMN_TAXES_ALL.cess_rate%TYPE;
    ln_inv_amt             ap_invoices_all.invoice_amount%TYPE;

    -- added, Harshita for Bug 4525089

    lv_cert_issue_date    DATE ;
    ln_tds_amt             JAI_AP_ETDS_T.amt_of_tds%TYPE;
    ln_surcharge_amt       JAI_AP_ETDS_T.amt_of_surcharge%TYPE;
    ln_cess_amt            JAI_AP_ETDS_T.amt_of_cess%TYPE;
                  -- ended, Harshita for Bug 4525089

--Date 11-05-2007 by Sacsethi for bug 5647248
-- start 5647248
    lv_include_flag VARCHAR2(1);
    lv_exclude_flag VARCHAR2(1);
    TYPE lv_list IS VARRAY(10) OF VARCHAR2(30);
    lv_include lv_list :=lv_list();
    lv_exclude lv_list :=lv_list();
-- end 5647248


    -- Harshita for Bug 4889272
    --v_tanAtLegalEntityFlag CHAR(1); -- := 'N';  File.Sql.35 by Brathod

    v_legalEntityTan VARCHAR2(50);
    lv_voided        CONSTANT VARCHAR2(30) := 'VOIDED';          --rchandan for bug#4428980
    lv_stop_init      CONSTANT VARCHAR2(30) := 'STOP INITIATED';--rchandan for bug#4428980
    lv_india_tds_source CONSTANT VARCHAR2(30) := 'INDIA TDS';--rchandan for bug#4428980
    lv_source_attribute VARCHAR2(30);--rchandan for bug#4428980

    -- to get TAN of an organization
    CURSOR c_tan_number(p_organization_id IN NUMBER) IS
      SELECT attribute1
      FROM hr_all_organization_units
      WHERE organization_id = p_organization_id;

    -- p_invoice_id contains tds_invoice_id incase if tds amount is directly paid to TDS Authorities using a c
    -- p_invoice_id contains PREPAYMENT invoice_id to TDS Auth., if  TDS invoice is applied to PREPAYMENT invo
    /*CURSOR c_tds_payment_check_id(p_invoice_id IN NUMBER) IS
      SELECT pay.check_id, apc.bank_account_id, apc.attribute3 challan_num, apc.attribute1 challan_date   -- p
      FROM ap_invoice_payments_all PAY, ap_checks_all APC
      WHERE PAY.invoice_id = p_invoice_id
      AND PAY.check_id = APC.check_id
        AND APC.status_lookup_code NOT IN (lv_voided,lv_stop_init);--rchandan for bug#4428980

    CURSOR c_base_payment_check_id(p_invoice_id IN NUMBER) IS
      SELECT pay.check_id, apc.bank_account_id, check_date
      FROM ap_invoice_payments_all PAY, ap_checks_all APC
      WHERE PAY.invoice_id = p_invoice_id
      AND PAY.check_id = APC.check_id
        AND APC.status_lookup_code NOT IN (lv_voided, lv_stop_init);--rchandan for bug#4428980*/



  -- Vijay Shankar for Bug#4448293
    /*CURSOR c_check_dtls(cpn_check_id IN NUMBER) IS
      SELECT apc.bank_account_id,
             apc.attribute3 challan_num,
             apc.attribute1 challan_date, */            -- pay.invoice_payment_id
             /* Bug 4353842. Added by Lakshmi Gopalsami */
        /*     apc.check_number
      FROM ap_checks_all APC
      WHERE check_id = cpn_check_id;*/

    /*CURSOR c_check_dtls(cp_check_id IN NUMBER) IS
     SELECT apc.bank_account_id,
            apc.attribute3 challan_num,
            apc.attribute1 challan_date,             -- pay.invoice_payment_id
            apc.check_number
     FROM ap_checks_all apc,
          JAI_AP_TDS_INV_PAYMENTS jatp
     WHERE
       apc.check_id = jatp.check_id AND
       jatp.check_id = cp_check_id;*/

    /*added by csahoo for bug # 6158875, START*/
    /*Modified the cursor c_tds_payment_check_id by JMEENA for bug#4600778 to select the bsr_code from JAI_AP_TDS_PAYMENTS table */
    CURSOR c_tds_payment_check_id(p_invoice_id IN NUMBER) IS
		SELECT pay.check_id, apc.current_bank_account_name, JATP.Challan_no challan_num,
			JATP.check_deposit_date challan_date, JATP.bsr_code   branch_code, apc.check_number check_number /*Bug 7688789 - Added Check Number*/
		FROM ap_invoice_payments_all PAY, ap_checks_v APC, JAI_AP_TDS_PAYMENTS JATP
		WHERE PAY.invoice_id = p_invoice_id
		AND PAY.check_id = APC.check_id
		AND APC.check_id = JATP.check_id
    AND APC.status_lookup_code NOT IN (lv_voided,lv_stop_init);

    CURSOR c_base_payment_check_id(p_invoice_id IN NUMBER) IS
		      SELECT pay.check_id, apc.current_bank_account_name, check_date
		      FROM ap_invoice_payments_all PAY, ap_checks_v APC
		      WHERE PAY.invoice_id = p_invoice_id
		      AND PAY.check_id = APC.check_id
        AND APC.status_lookup_code NOT IN (lv_voided, lv_stop_init);

    /*7688789 - data fetched in c_check_dtls is already fetched by c_tds_payment_check_id*/
	/*
    CURSOR c_check_dtls(cp_check_id IN NUMBER) IS
    SELECT ACV.CURRENT_BANK_ACCOUNT_NAME ,
    			 JATP.Challan_no challan_num,
		       JATP.check_deposit_date challan_date,
		       JATP.check_number
		FROM AP_CHECKS_V ACV, JAI_AP_TDS_PAYMENTS JATP
		WHERE ACV.check_id = JATP.check_id
		AND jatp.check_id = cp_check_id
		 -- Bug 5975168. Added by csahoo
		AND ACV.status_lookup_code NOT IN
		('VOIDED', 'STOP INITIATED');
	*/

    /*added by csahoo for bug # 6158875, END*/

    CURSOR c_prepay_invoice_id(p_tds_invoice_id IN NUMBER) IS
      SELECT b.invoice_id prepay_invoice_id
      FROM ap_invoice_distributions_all a, ap_invoice_distributions_all b
      WHERE a.invoice_id = p_tds_invoice_id
      AND a.prepay_distribution_id IS NOT NULL
      AND (a.reversal_flag IS NULL OR a.reversal_flag = 'N')  --rchandan for bug#4428980
      AND b.invoice_distribution_id = a.prepay_distribution_id;

    /* Following cursor is modified by Brathod for Bug# 4428712 (R12 Initiative)
    CURSOR c_bank_branch_code(p_bank_account_id IN NUMBER) IS
      SELECT HZOP.BANK_OR_BRANCH_NUMBER
      FROM  HZ_ORGANIZATION_PROFILES HZOP
          , CE_BANK_ACCOUNTS CEBA
      WHERE HZOP.PARTY_ID = CEBA.BANK_BRANCH_ID
      AND   CEBA.BANK_ACCOUNT_ID = p_bank_account_id;*/

    CURSOR c_cert_issue_date(p_tds_invoice_id IN NUMBER) IS
      SELECT a.issue_date
      FROM JAI_AP_TDS_F16_HDRS_ALL a, JAI_AP_TDS_INV_PAYMENTS b -- Bug#4517720 ja_in_ap_form16_dtl b
      WHERE a.certificate_num = b.certificate_num
      AND a.org_tan_num = b.org_tan_num
      AND a.fin_yr = b.fin_year
      AND b.invoice_id = p_tds_invoice_id;

    CURSOR c_check_date(p_check_id IN NUMBER) IS
      SELECT nvl(jatp.check_date, jatp.check_date) check_date
        /* decode (attribute1, NULL,check_date,to_date(attribute1)) */
      FROM JAI_AP_TDS_INV_PAYMENTS jatp
      WHERE
    check_id = p_check_id;
      lv_tds_check_date DATE ;

    --Added by Xiao Lv for bug#7662155 on 06-Jan-2010, begin
      CURSOR c_get_tds_inv_det(cp_invoice_id NUMBER)
        IS
        SELECT threshold_trx_id,
               tax_amount,
               taxable_amount,
               tds_event
          FROM jai_ap_tds_thhold_trxs jatt
         WHERE jatt.invoice_to_tds_authority_id = cp_invoice_id
           AND tds_event like 'SURCHARGE_CALCULATE';

	r_get_tds_inv c_get_tds_inv_det%rowtype;

    --Added by Xiao Lv for bug#7662155 on 06-Jan-2010, end

    CURSOR c_tax_rates(p_tax_id JAI_CMN_TAXES_ALL.tax_id%TYPE)
      IS
      SELECT
         NVL(tax_rate,0),
        (NVL(tax_rate,0) - (NVL(surcharge_rate,0) + NVL(cess_rate,0) + NVL(sh_cess_rate,0))) tds_rate,  -- added NVL, Harshita for Bug 4639067  --Added sh_cess_rate by Bgowrava for bug #6195027
         NVL(surcharge_rate,0) surcharge_rate,
         NVL(cess_rate,0),
		 NVL(sh_cess_rate,0)  --Added by Bgowrava for Bug#6195027
      FROM
        JAI_CMN_TAXES_ALL jtc
      WHERE
        tax_id = p_tax_id  ;
  -- ended, Harshita for Bug 4525089
  --Date 11-05-2007 by Sacsethi for bug 5647248
  -- start 5647248

  -- Bug 5975168. Added by csahoo, start
		ln_con_for_challan  NUMBER ;
		ln_con_for_deductee NUMBER ;
	-- Bug 5975168. end

	/*START, Bgowrava for Bug#6195027*/
	 ln_sh_cess_rate NUMBER ;
     ln_sh_cess_amt NUMBER ;
	/*END, Bgowrava for Bug#6195027*/

	PROCEDURE populate_include_exclude_list(
          p_include_exclude_list IN VARCHAR2,
          p_include_exclude_arr OUT NOCOPY lv_list)
        IS
          ln_pos          NUMBER;
          ln_initial_pos  NUMBER;
          ln_length       NUMBER;
          lv_char         VARCHAR2(1);
        BEGIN
          p_include_exclude_arr:=lv_list();
          lv_char := ',';
          ln_initial_pos := 1;
          p_include_exclude_arr.extend(10);
          FOR lv_count in 1..10
            LOOP
              p_include_exclude_arr(lv_count) := NULL;
            END LOOP;
          IF p_include_exclude_list IS NOT NULL THEN
            FOR lv_count in 1..10
            LOOP
              ln_pos := instr (p_include_exclude_list, lv_char, 1, lv_count);
              IF ln_pos <> 0 THEN
                ln_length   := ln_pos - ln_initial_pos ;
                p_include_exclude_arr(lv_count) := substr (p_include_exclude_list, ln_initial_pos , ln_length);
                ln_initial_pos := ln_pos + 1 ;
              ELSE
                p_include_exclude_arr(lv_count) := substr (p_include_exclude_list, ln_initial_pos);

                FOR i in lv_count+1..10
                LOOP
                  p_include_exclude_arr(i) :=   p_include_exclude_arr(lv_count) ;
                END LOOP ;
                EXIT;
              END IF;
            END LOOP;
          END IF;
  -- end 5647248

       END populate_include_exclude_list;






  BEGIN

    v_statement_id := '1';

   -- Harshita for Bug 4889272
   -- v_tanAtLegalEntityFlag := 'N';
   /*
    OPEN c_tan_number(p_legal_entity_id);
    FETCH c_tan_number INTO v_legalEntityTan;
    CLOSE c_tan_number;


    IF v_legalEntityTan IS NOT NULL THEN
      v_tanAtLegalEntityFlag := 'Y';
    END IF;
   */

    v_statement_id := '2';
    lv_source_attribute := 'ATTRIBUTE1';  --rchandan for bug#4428980

    lv_include.extend(10);
    lv_exclude.extend(10);

--Date 11-05-2007 by Sacsethi for bug 5647248
-- start 5647248

    IF p_include_list IS NOT NULL THEN
      lv_include_flag := 'Y';
      populate_include_exclude_list(p_include_list, lv_include);
    ElSE
      lv_include_flag := 'N';
    END IF;

    IF p_exclude_list IS NOT NULL THEN
      lv_exclude_flag := 'Y';
      populate_include_exclude_list(p_exclude_list, lv_exclude);
     ElSE
      lv_exclude_flag := 'N';
     END IF;
-- end 5647248

    INSERT INTO JAI_AP_ETDS_T (
      batch_id,
      -- line_number,
      base_invoice_id,
      --base_taxabale_amount, /*Commented for 5751783*/
      tds_invoice_id,
      tds_invoice_num,
      tds_invoice_date,
      tds_section,
      tds_tax_id,
      tds_tax_rate,
      tds_amount,
      consider_for_challan,
      consider_for_deductee,
      tds_check_id,   -- Vijay Shankar for Bug#4448293
      base_invoice_date ,
      -- added, Harshita for Bug 4866533
      created_by,
      creation_date,
      last_updated_by,
      last_update_date
    ) SELECT p_batch_id,
      -- rownum + 2,    -- 2 is added to all records to take care of file and batch header record line numbers
      base_invoices.invoice_id,   -- base_invoice_id
      --base_invoices.invoice_amount,       -- base taxable amount /*Commented for 5751783*/
      tds_invoices.invoice_id,   -- tds_invoice_id
      tds_invoices.invoice_num,      -- tds_invoice_num
      tds_invoices.invoice_date,         -- tds_invoice_date
      a.tds_section,
      a.tds_tax_id,
      a.tds_tax_rate,
      a.tax_amount,
      1,
      1,
      a.check_id,
      base_invoices.invoice_date,
      -- added, Harshita for Bug 4866533
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      sysdate
      from  JAI_AP_TDS_INV_PAYMENTS a, ap_invoices_all base_invoices, ap_invoices_all tds_invoices
                              where a.parent_invoice_id = base_invoices.invoice_id
                              and   a.invoice_id = tds_invoices.invoice_id
                              and   a.invoice_date between p_tds_inv_from_date and p_tds_inv_to_date
                              and   a.tax_authority_id = p_tds_vendor_id
                              and   (p_tds_vendor_site_id is null or a.tax_authority_site_id = p_tds_vendor_site_id)
                              and   a.payment_amount <> 0
                        and   a.org_tan_num = p_org_tan_num
						and
                       ( lv_include_flag = 'N' or ( lv_include_flag = 'Y'
						   and upper(a.tds_section) in ( lv_include(1),lv_include(2),lv_include(3),lv_include(4),lv_include(5),lv_include(6),lv_include(7),lv_include(8),lv_include(9),lv_include(10) )  ))
                        and
                         ( lv_exclude_flag = 'N' or ( lv_exclude_flag = 'Y'
						   and upper(a.tds_section) not in ( lv_exclude(1),lv_exclude(2),lv_exclude(3),lv_exclude(4),lv_exclude(5),lv_exclude(6),lv_exclude(7),lv_exclude(8),lv_exclude(9),lv_exclude(10)) ) )
                        ;   --Added above two conditions by  Bgowrava for bug#7485031


    v_statement_id := '3';
    /* -------- following fields of JAI_AP_ETDS_T needs to be populated now
      Invoice Distributions - prepayment_amount_applied
      Payment Details - tds_check_id, challan_num, challan_date, bank_branch_code
    --------------------------------- */
    FOR dtl IN (select a.rowid row_id, a.*,
            b.vendor_id vendor_id, b.vendor_site_id vendor_site_id, b.invoice_type_lookup_code inv_type
          from JAI_AP_ETDS_T a, ap_invoices_all b
          where a.batch_id = p_batch_id and a.base_invoice_id = b.invoice_id)
    LOOP

      --added by csahoo for bug#5975168, start
			ln_con_for_challan  := 1;
		  ln_con_for_deductee := 1;
		  --bug#5975168, end

      ln_tax_rate       :=  NULL;
      ln_tds_rate       :=  NULL;
      ln_surcharge_rate :=  NULL;
      ln_cess_rate      :=  NULL;
      ln_tds_amt        := 0 ;
      ln_surcharge_amt  := 0 ;
      ln_cess_amt       := 0 ;

	  /*START, Bgowrava for Bug#6195027*/
	  ln_sh_cess_rate := NULL;
	  ln_sh_cess_amt := 0;
	  /*END, Bgowrava for Bug#6195027*/

      OPEN c_cert_issue_date(dtl.tds_invoice_id);
      FETCH c_cert_issue_date INTO lv_cert_issue_date;
      CLOSE c_cert_issue_date;

      OPEN c_check_date(dtl.tds_check_id);
      FETCH c_check_date INTO lv_tds_check_date;
      CLOSE c_check_date;

      OPEN c_tax_rates(dtl.tds_tax_id) ;
      FETCH c_tax_rates INTO ln_tax_rate, ln_tds_rate, ln_surcharge_rate, ln_cess_rate, ln_sh_cess_rate ;  --Added ln_sh_cess_rate by Bgowrava for bug#6195027
      CLOSE c_tax_rates ;


      v_challan_err := null;
      v_deductee_err := null;
      v_tds_check_id := null;
      v_base_invoice_check_id := null;
      v_challan_num := null;
      v_challan_date := null;
      v_bank_account_id := null;
      v_bank_account_name  := null;  --added by csahoo for BUG#6158875
      v_bank_branch_code := null;
      v_prepay_inv_id_of_base := null;
      v_prepay_inv_id_of_tds := null;
      v_prepayment_amount_applied := null;
      v_tds_check_date := null;
      v_base_check_date := null;

      v_temp_bank := null;
      v_temp_bank_acc_name := null; --added by csahoo for BUG#6158875
      v_temp_challan_num := null;
      v_temp_challan_date := null;

      v_debug_tds_invid := dtl.tds_invoice_id;
      v_debug_base_invid := dtl.base_invoice_id;

      ln_check_number := null;

      v_statement_id := '3a';
     /* Modified by JMEENA for bug# 4600778 to fetch the bsr_code in v_bank_branch_code */
      OPEN c_tds_payment_check_id(dtl.tds_invoice_id);
      FETCH c_tds_payment_check_id INTO v_tds_check_id, v_bank_account_name, v_challan_num, v_challan_date, v_bank_branch_code, ln_check_number;
      /*Bug 7688789 - Fetched Check Number also*/
      CLOSE c_tds_payment_check_id;

	 /*Bug 7688789 - Removed the else clause. The details fetched by c_check_dtls is already fetched by c_tds_payment_check_id*/
     IF v_tds_check_id IS NULL THEN
       v_statement_id := '3b';
       OPEN c_prepay_invoice_id(dtl.tds_invoice_id);
       FETCH c_prepay_invoice_id INTO v_prepay_inv_id_of_tds;
       CLOSE c_prepay_invoice_id;

       v_statement_id := '3b';
       /* Modified by JMEENA for bug# 4600778 to fetch the bsr_code in v_bank_branch_code */
       OPEN c_tds_payment_check_id(v_prepay_inv_id_of_tds);
       FETCH c_tds_payment_check_id INTO v_tds_check_id, v_bank_account_name, v_challan_num, v_challan_date, v_bank_branch_code, ln_check_number;
       /*Bug 7688789 - Added check number to handle TDS Payment via Prepayment*/
       CLOSE c_tds_payment_check_id;
     END IF;

	 IF ln_check_number IS NULL  THEN
	    ln_con_for_challan := 0;
		fnd_file.put_line(FND_FILE.LOG, ' consider for challan '|| ln_con_for_challan);
		GOTO update_now;
	 END IF ;

     IF v_tds_check_id IS NULL THEN
       v_challan_err := 'Payment Information not available for TDS Inv';
       GOTO update_now;
     END IF;

     IF v_bank_branch_code IS NULL THEN
       v_challan_err := 'Bank Branch Code is not found for TDS Inv';
     ELSIF v_challan_num IS NULL THEN
       v_challan_err := 'Challan Number is not found for TDS Inv';
     ELSIF v_challan_date IS NULL THEN
       v_challan_err := 'Challan Date is not found for TDS Inv';
     END IF;

     v_statement_id := '3d';
     OPEN c_base_payment_check_id(dtl.base_invoice_id);
     FETCH c_base_payment_check_id INTO v_base_invoice_check_id, v_temp_bank_acc_name, v_base_check_date;
     CLOSE c_base_payment_check_id;

     IF v_base_invoice_check_id IS NULL THEN
       v_statement_id := '3e';
       OPEN c_prepay_invoice_id(dtl.base_invoice_id);
       FETCH c_prepay_invoice_id INTO v_prepay_inv_id_of_base;
       CLOSE c_prepay_invoice_id;

       v_statement_id := '3f';
       OPEN c_base_payment_check_id(v_prepay_inv_id_of_base);
       FETCH c_base_payment_check_id INTO v_base_invoice_check_id, v_temp_bank_acc_name, v_base_check_date;
       CLOSE c_base_payment_check_id;
     END IF;

     IF v_base_invoice_check_id IS NULL THEN
       v_deductee_err := 'Payment Information not available for Base Invoice';
     END IF;

     <<update_now>>

     IF dtl.inv_type = 'PREPAYMENT' THEN
       v_statement_id := '3g';
       select sum(amount) - sum( nvl(prepay_amount_remaining, amount)) INTO v_prepayment_amount_applied
       from   ap_invoice_distributions_all
       where  invoice_id = dtl.base_invoice_id
       and    attribute1 = dtl.tds_tax_id;
     END IF;

     v_prepayment_amount_applied := nvl(v_prepayment_amount_applied,0);

     IF v_generate_headers THEN
       IF NVL(lv_action,'X') <> 'V' THEN
        FND_FILE.put_line(FND_FILE.log, 'lengths - inv_type:'||length(dtl.inv_type)
          ||', ch_num:'||length(v_challan_num) ||', bank_brCode:'||length(v_bank_branch_code) ||', ch_err:'
          ||', ded_err:'||length(v_deductee_err)
        );
       END IF ;
     END IF;

     v_challan_num := substr(v_challan_num, 1,25);

     v_statement_id := '3h';
     /* following lines of UPDATE commented by Vijay Shankar for Bug# 3567864 and modified as below UPDATE st
     UPDATE JAI_AP_ETDS_T
     SET tds_amount = round(tds_amount - v_prepayment_amount_applied*dtl.tds_tax_rate/100, 2),
     */
	--Added by Xiao Lv for bug#7662155 on 06-Jan-2010, begin

		OPEN c_get_tds_inv_det(dtl.tds_invoice_id);
		FETCH c_get_tds_inv_det INTO r_get_tds_inv;
		CLOSE c_get_tds_inv_det;

		IF r_get_tds_inv.threshold_trx_id IS NOT NULL
		THEN
				ln_surcharge_amt := r_get_tds_inv.tax_amount;
				ln_cess_amt := 0;
				ln_tds_amt := 0;
		ELSE

	--Added by Xiao Lv for bug#7662155 on 06-Jan-2010, end

	     -- added, Harshita for Bug 4525089
	     ln_surcharge_amt   := round((dtl.tds_amount * ln_surcharge_rate /ln_tax_rate),2) ;
		   ln_sh_cess_amt     := round((dtl.tds_amount * ln_sh_cess_rate/ln_tax_rate),2); --Added by Bgowrava for Bug#
	     ln_cess_amt        := round((dtl.tds_amount * ln_cess_rate/ln_tax_rate),2) + ln_sh_cess_amt ; --Added ln_sh_cess_amt by bgowrava for bug#6195027
	     ln_tds_amt         := dtl.tds_amount - NVL(ln_surcharge_amt,0) - NVL(ln_cess_amt,0) ;  -- added NVL, Harshita
	     -- ended, Harshita for Bug 4525089
     END IF; --r_get_tds_inv.threshold_trx_id IS NOT NULL --add by Xiao Lv for bug#7662155

    UPDATE JAI_AP_ETDS_T
    SET tds_amount = round(tds_amount - v_prepayment_amount_applied*dtl.tds_tax_rate/100, 2),
      base_taxabale_amount = base_taxabale_amount - v_prepayment_amount_applied,
      base_vendor_id = dtl.vendor_id,
      base_vendor_site_id = dtl.vendor_site_id,
      base_invoice_type_lookup_code = dtl.inv_type,
      tds_check_id = v_tds_check_id,
      challan_num = v_challan_num,
      challan_date = v_challan_date,
      check_number = ln_check_number,
      bank_branch_code = v_bank_branch_code,
      base_invoice_check_id = v_base_invoice_check_id,
      prepayment_amount_applied = v_prepayment_amount_applied,
      challan_error =  v_challan_err,
      deductee_error =  v_deductee_err,
      amt_of_tds = ln_tds_amt,
      amt_of_surcharge = ln_surcharge_amt,
      amt_of_cess = ln_cess_amt,
      certificate_issue_date = lv_cert_issue_date,
      tds_check_date = lv_tds_check_date,
      -- Bug 5975168. Added by csahoo
			consider_for_challan = ln_con_for_challan,
			consider_for_deductee = decode(ln_con_for_challan,0,0,ln_con_for_deductee)
    WHERE rowid = dtl.row_id;

    END LOOP;

--Modified by Xiao Lv for bug#7662155, begin
/*
--Date 11-05-2007 by Sacsethi for bug 5647248
-- start 5647248
    update jai_ap_etds_t a
    set base_taxabale_amount =
       ( select nvl(taxable_amount,0)
         from JAI_AP_TDS_THHOLD_TRXS b
         where b.invoice_to_tds_authority_id = a.tds_invoice_id )
    where a.batch_id = p_batch_id
    and exists
         ( select 1
           from JAI_AP_TDS_THHOLD_TRXS c
           where c.invoice_to_tds_authority_id = a.tds_invoice_id
           and c.tds_event like '%THRESHOLD%'
         ) ;
 -- end 5647248
*/
	/* Bug 5721614. Code migration by Xiao Lv from ja_in_ap_etds_pkg.sql with version 115.26.6307.8
 	 * Commented the above and added the below.
	 * Updates records which are available in
	 * jai_ap_tds_thhold_trxs */

    UPDATE jai_ap_etds_t a
       SET base_taxabale_amount =
            ( SELECT decode(b.tds_event,
                           'SURCHARGE_CALCULATE',
                           0,
                           nvl(taxable_amount,0) * sign(invoice_to_tds_authority_amt)) --Added DECODE by Xiao Lv for Bug#7662155
                FROM jai_ap_tds_thhold_trxs b
               WHERE b.invoice_to_tds_authority_id = a.tds_invoice_id )
     WHERE a.batch_id = p_batch_id;

	/* This update is used to update invoices which
	 * are not available in jai_ap_tds_thhold_trxs
	 * but considered for calculating taxable_basis
	 * for threshold transition or rollback.
	 */

	UPDATE jai_ap_etds_t a
	SET base_taxabale_amount = 0
	WHERE a.batch_id = p_batch_id
	AND base_taxabale_amount IS NULL;

--Modified by Xiao Lv for bug#7662155, end


   EXCEPTION
     WHEN OTHERS THEN
       FND_FILE.put_line(FND_FILE.log, 'Err->'||SQLERRM);
       FND_FILE.put_line(FND_FILE.log, 'statement->'||v_statement_id
         ||', tds_invid->'||v_debug_tds_invid||', base_invid->'||v_debug_base_invid);
       RAISE;
   END populate_details;

  PROCEDURE create_file_header(
    p_line_number IN NUMBER,
    p_record_type IN VARCHAR2,
    p_file_type IN VARCHAR2,
    p_upload_type IN VARCHAR2,
    p_file_creation_date IN DATE,
    p_file_sequence_number IN NUMBER,
    p_deductor_tan IN VARCHAR2,
    p_number_of_batches IN NUMBER
  ) IS

  BEGIN

    UTL_FILE.PUT_LINE(v_filehandle,
        LPAD(p_line_number, s_line_number, v_pad_number)
     ||v_debug_pad_char||RPAD(p_record_type, s_record_type, v_pad_char)
     ||v_debug_pad_char||RPAD(p_file_type, s_file_type, v_pad_char)
     ||v_debug_pad_char||RPAD(p_upload_type, s_upload_type, v_pad_char)
     ||v_debug_pad_char||LPAD(to_char(p_file_creation_date, 'ddmmyyyy'), s_date, v_pad_date)
     ||v_debug_pad_char||LPAD(p_file_sequence_number, s_file_sequence_number, v_pad_number)
     ||v_debug_pad_char||RPAD(nvl(p_deductor_tan,' '), s_deductor_tan, v_pad_char)
     ||v_debug_pad_char||LPAD(nvl(p_number_of_batches,0), s_number_of_batches, v_pad_number)
    );

  END create_file_header;

  PROCEDURE create_batch_header(
    p_line_number IN NUMBER,  -- 6
    p_record_type IN VARCHAR2,  -- 2
    p_batch_number IN NUMBER, -- 4
    p_challan_count IN NUMBER,  -- 5
    p_deductee_count IN NUMBER, -- 5
    p_form_number IN CHAR,    -- 4
    p_rrr_number IN NUMBER,   -- 10
    p_rrr_date IN DATE,     -- 8
    p_deductor_tan IN VARCHAR2, -- 10
    p_pan_of_tan IN VARCHAR2, -- 10
    p_assessment_year IN NUMBER,-- 6
    p_financial_year IN NUMBER, -- 6
    p_deductor_name IN VARCHAR2,-- 75
    p_tan_address1 IN VARCHAR2, -- 25
    p_tan_address2 IN VARCHAR2, -- 25
    p_tan_address3 IN VARCHAR2, -- 25
    p_tan_address4 IN VARCHAR2, -- 25
    p_tan_address5 IN VARCHAR2, -- 25
    p_tan_state IN NUMBER,    -- 2
    p_tan_pin IN NUMBER,    -- 6
    p_chng_addr_since_last_return IN VARCHAR2,  -- 1    tells you whether address of deductor is changed since last return
    p_type_of_deductor IN VARCHAR2, -- 1        'C' for Central Govt/ 'O' for others /*Bug 8880543 - Modified Dedutory Status to Deductor Type*/
    p_quart_year_return IN VARCHAR, -- 2
    p_pers_resp_for_deduction IN VARCHAR2,  -- 75
    p_pers_designation IN VARCHAR2, -- 20
    p_tot_tax_dedected_challan IN NUMBER, -- 14, DECIMAL
    p_tot_tax_dedected_deductee IN NUMBER, -- 14, DECIMAL
    -- added. Harshita for Bug 5096787
    p_filler1    IN DATE DEFAULT NULL,
    p_filler2  IN NUMBER DEFAULT NULL,
    p_filler3  IN VARCHAR2 DEFAULT NULL,
    p_ack_num_tan_app IN NUMBER DEFAULT NULL,
    p_pro_rcpt_num_org_ret IN NUMBER  DEFAULT NULL
    -- ended. Harshita for Bug 5096787
  ) IS

  BEGIN

    UTL_FILE.PUT_LINE(v_filehandle,
       LPAD(p_line_number, s_line_number, v_pad_number)
     ||v_debug_pad_char||RPAD(p_record_type, s_record_type, v_pad_char)
     ||v_debug_pad_char||LPAD(p_batch_number, s_batch_number, v_pad_number)
     ||v_debug_pad_char||LPAD(p_challan_count, s_challan_count, v_pad_number)
     ||v_debug_pad_char||LPAD(p_deductee_count, s_deductee_count, v_pad_number)
     ||v_debug_pad_char||RPAD(p_form_number, s_form_number, v_pad_char)
     ||v_debug_pad_char||LPAD(nvl(p_rrr_number,0), s_rrr_number, v_pad_number)
     ||v_debug_pad_char||LPAD(nvl(to_char(p_rrr_date, 'ddmmyyyy'),' '), s_date, v_pad_date)
     ||v_debug_pad_char||RPAD(nvl(p_deductor_tan,' '), s_deductor_tan, v_pad_char)
     ||v_debug_pad_char||RPAD(nvl(p_pan_of_tan,' '), s_pan_of_tan, v_pad_char)
     ||v_debug_pad_char||LPAD(nvl(p_assessment_year,0), s_assessment_year, v_pad_number)
     ||v_debug_pad_char||LPAD(nvl(p_financial_year,0), s_financial_year, v_pad_number)
     ||v_debug_pad_char||RPAD(nvl(p_deductor_name,' '), s_deductor_name, v_pad_char)
     ||v_debug_pad_char||RPAD(nvl(p_tan_address1,' '), s_tan_address1, v_pad_char)
     ||v_debug_pad_char||RPAD(nvl(p_tan_address2,' '), s_tan_address2, v_pad_char)
     ||v_debug_pad_char||RPAD(nvl(p_tan_address3,' '), s_tan_address3, v_pad_char)
     ||v_debug_pad_char||RPAD(nvl(p_tan_address4,' '), s_tan_address4, v_pad_char)
     ||v_debug_pad_char||RPAD(nvl(p_tan_address5,' '), s_tan_address5, v_pad_char)
     ||v_debug_pad_char||LPAD(nvl(p_tan_state,0), s_tan_state, v_pad_number)
     ||v_debug_pad_char||LPAD(nvl(p_tan_pin,0), s_tan_pin, v_pad_number)
     ||v_debug_pad_char||RPAD(nvl(p_chng_addr_since_last_return,' '), s_chng_addr_since_last_return, v_pad_char)
     ||v_debug_pad_char||RPAD(nvl(p_type_of_deductor,' '), s_status_of_deductor, v_pad_char) /*Bug 8880543 - Modified Deductory Status to Deductor Type*/
     ||v_debug_pad_char||RPAD(nvl(p_quart_year_return,' '), s_quart_year_return, v_pad_char)
     ||v_debug_pad_char||RPAD(nvl(p_pers_resp_for_deduction,' '), s_pers_resp_for_deduction, v_pad_char)
     ||v_debug_pad_char||RPAD(nvl(p_pers_designation,' '), s_pers_designation, v_pad_char)
     ||v_debug_pad_char||LPAD(formatAmount(p_tot_tax_dedected_challan), s_tot_tax_dedected_challan, v_pad_number)
     ||v_debug_pad_char||LPAD(formatAmount(p_tot_tax_dedected_deductee), s_tot_tax_dedected_deductee, v_pad_number)
    );

  END create_batch_header;

  PROCEDURE create_challan_detail(
    p_line_number IN NUMBER,  -- 6
    p_record_type IN VARCHAR2,  -- 2
    p_batch_number IN NUMBER, -- 4
    p_challan_slno IN NUMBER, -- 5
    p_challan_section IN VARCHAR2,    -- 5
    p_amount_deducted IN NUMBER,  -- 14, DECIMAL
    p_challan_num IN VARCHAR2,    -- 9
    p_challan_date IN DATE,     -- 8
    p_bank_branch_code IN VARCHAR2,  -- 7,
    -- added. Harshita for Bug 5096787
    p_amount_of_tds       IN NUMBER DEFAULT NULL,
    p_amount_of_surcharge IN NUMBER DEFAULT NULL,
    p_amount_of_cess      IN NUMBER DEFAULT NULL,
    p_amount_of_int       IN NUMBER DEFAULT NULL,
    p_amount_of_oth       IN NUMBER DEFAULT NULL,
    p_check_number        IN NUMBER DEFAULT NULL,
    p_tds_dep_by_book     IN VARCHAR2 DEFAULT NULL,
    p_filler4             IN VARCHAR2 DEFAULT NULL
    -- added. Harshita for Bug 5096787
  ) IS

  BEGIN
     -- Bug 6796765. Added by Lakshmi Gopalsami
     -- Added upper for both p_challan_section and Sec.()
    UTL_FILE.PUT_LINE(v_filehandle,
        LPAD(p_line_number, s_line_number, v_pad_number)
      ||v_debug_pad_char||RPAD(p_record_type, s_record_type, v_pad_char)
      ||v_debug_pad_char||LPAD(p_batch_number, s_batch_number, v_pad_number)
      ||v_debug_pad_char||LPAD(nvl(p_challan_slno,0), s_challan_slno, v_pad_number)
      ||v_debug_pad_char||RPAD(getSectionCode(upper(p_challan_section), upper('Sec.()')), s_challan_section, v_pad_char)
      ||v_debug_pad_char||LPAD(formatAmount(p_amount_deducted), s_amount_deducted, v_pad_number)
      ||v_debug_pad_char||RPAD(nvl(p_challan_num,' '), s_challan_num, v_pad_char)
      ||v_debug_pad_char||LPAD(nvl(to_char(p_challan_date, 'ddmmyyyy'),' '), s_date, v_pad_date)
      ||v_debug_pad_char||RPAD(nvl(p_bank_branch_code,' '), s_bank_branch_code, v_pad_char)
    );

  END create_challan_detail;

 PROCEDURE create_deductee_detail(
     p_line_number IN NUMBER,        -- 9
     p_record_type IN VARCHAR2,      -- 2
     p_batch_number IN NUMBER,       -- 9
     p_deductee_slno IN NUMBER,      -- 5
     p_deductee_section IN VARCHAR2, -- 5
     p_deductee_code IN VARCHAR2,    -- 2            01 for Companies and 02 for other than companies
     p_deductee_pan IN VARCHAR2,     -- 10
     p_deductee_name IN VARCHAR2,    -- 75
     p_deductee_address1 IN VARCHAR2,        -- 25
     p_deductee_address2 IN VARCHAR2,        -- 25
     p_deductee_address3 IN VARCHAR2,        -- 25
     p_deductee_address4 IN VARCHAR2,        -- 25
     p_deductee_address5 IN VARCHAR2,        -- 25
     p_deductee_state IN VARCHAR2,   -- 2
     p_deductee_pin IN VARCHAR2,       -- 6 /*Changed to VARCHAR2 - Bug 7494473*/
     p_filler5 IN NUMBER,            -- 14 Added for bug#4353842
     p_payment_amount IN NUMBER,     -- 14 (12+2), DECIMAL
     p_payment_date IN DATE,         -- 8
     p_book_ent_oth IN VARCHAR2,     -- 1  Added for bug#4353842
     p_tax_rate IN NUMBER,           -- 4(2+2), DECIMAL
     p_filler6  IN VARCHAR2,         -- 1 Added for bug#4353842
     --p_grossing_up_factor IN VARCHAR2,     -- 1  -- Obsoleted via bug # 4353842
     p_tax_deducted IN NUMBER,       -- 14(12+2), DECIMAL
     p_tax_deducted_date IN DATE, -- 8
     p_tax_payment_date IN DATE,     -- 8
     p_bank_branch_code IN VARCHAR2, -- 7
     p_challan_no IN VARCHAR2,               -- 9
     p_tds_certificate_date IN DATE, -- 8
     p_reason_for_nDeduction IN VARCHAR2,    -- 1
     p_filler7 IN NUMBER                             -- 14, DECIMAL
         ) IS


  BEGIN

    -- Bug 6796765. Added by Lakshmi Gopalsami
    -- Added upper for both p_deductee_section and Sec.()

    UTL_FILE.PUT_LINE(v_filehandle,
          LPAD(p_line_number, s_line_number, v_pad_number)
        ||v_debug_pad_char||RPAD(p_record_type, s_record_type, v_pad_char)
        ||v_debug_pad_char||LPAD(p_batch_number, s_batch_number, v_pad_number)
        ||v_debug_pad_char||LPAD(nvl(p_deductee_slno,0), s_deductee_slno, v_pad_number)
	||v_debug_pad_char||RPAD(getSectionCode(upper(p_deductee_section),upper('Sec.()')), s_deductee_section, v_pad_char)-- bug#3708878
        ||v_debug_pad_char||RPAD(nvl(p_deductee_code,' '), s_deductee_code, v_pad_char)
        ||v_debug_pad_char||RPAD(nvl(p_deductee_pan,' '), s_deductee_pan, v_pad_char)
        ||v_debug_pad_char||RPAD(nvl(p_deductee_name,' '), s_deductee_name, v_pad_char)
        ||v_debug_pad_char||RPAD(nvl(p_deductee_address1,' '), s_deductee_address1, v_pad_char)
        ||v_debug_pad_char||RPAD(nvl(p_deductee_address2,' '), s_deductee_address2, v_pad_char)
        ||v_debug_pad_char||RPAD(nvl(p_deductee_address3,' '), s_deductee_address3, v_pad_char)
        ||v_debug_pad_char||RPAD(nvl(p_deductee_address4,' '), s_deductee_address4, v_pad_char)
        ||v_debug_pad_char||RPAD(nvl(p_deductee_address5,' '), s_deductee_address5, v_pad_char)
        ||v_debug_pad_char||LPAD(nvl(p_deductee_state,'0'), s_deductee_state, v_pad_number)
        ||v_debug_pad_char||LPAD(nvl(p_deductee_pin,0), s_deductee_pin, v_pad_number)
        ||v_debug_pad_char||LPAD(formatAmount(p_filler5), s_filler, v_pad_number)
        ||v_debug_pad_char||LPAD(formatAmount(p_payment_amount), s_payment_amount, v_pad_number)
        ||v_debug_pad_char||LPAD(nvl(to_char(p_payment_date, 'ddmmyyyy'),' '), s_date, v_pad_date)
        ||v_debug_pad_char||RPAD(p_book_ent_oth , s_book_ent_oth, v_pad_char)
        ||v_debug_pad_char||LPAD(formatAmount(p_tax_rate), s_tax_rate, v_pad_number)
        ||v_debug_pad_char||RPAD(nvl(p_filler6,' '), s_filler6, v_pad_char)
        ||v_debug_pad_char||LPAD(formatAmount(p_tax_deducted), s_tax_deducted, v_pad_number)
        ||v_debug_pad_char||LPAD(nvl(to_char(p_tax_deducted_date, 'ddmmyyyy'),' '), s_date, v_pad_date)
        ||v_debug_pad_char||RPAD(nvl(p_bank_branch_code,' '), s_bank_branch_code, v_pad_char)
        ||v_debug_pad_char||LPAD(nvl(to_char(p_tax_payment_date, 'ddmmyyyy'),' '), s_date, v_pad_date)
        ||v_debug_pad_char||RPAD(nvl(p_challan_no,' '), s_challan_no, v_pad_char)
        ||v_debug_pad_char||LPAD(nvl(to_char(p_tds_certificate_date, 'ddmmyyyy'),' '), s_date, v_pad_date)
        ||v_debug_pad_char||RPAD(nvl(p_reason_for_nDeduction,' '), s_reason_for_nDeduction, v_pad_char)
        ||v_debug_pad_char||LPAD(formatAmount(p_filler7), s_filler, v_pad_number) || v_chr13
      );
  END create_deductee_detail;

  PROCEDURE create_fh(p_batch_id IN NUMBER) IS
    v_req JAI_AP_ETDS_REQUESTS%rowtype;
  BEGIN

    -- File Header
    SELECT * INTO v_req FROM JAI_AP_ETDS_REQUESTS WHERE batch_id = p_batch_id;

    UTL_FILE.PUT_LINE(v_filehandle, 'Input Parameters to this Request:');
    UTL_FILE.PUT_LINE(v_filehandle, '-------------------------------------------------');
    UTL_FILE.PUT_LINE(v_filehandle,
        '  batch_id                   ->'||v_req.batch_id||fnd_global.local_chr(10)
      ||'  request_id                 ->'||v_req.request_id||fnd_global.local_chr(10)
      ||'  legal_entity_id            ->'||v_req.legal_entity_id||fnd_global.local_chr(10)
      ||'  operating_unit_id          ->'||v_req.operating_unit_id||fnd_global.local_chr(10)
      ||'  org_tan_number             ->'||v_req.org_tan_number||fnd_global.local_chr(10)
      ||'  financial_year             ->'||v_req.financial_year||fnd_global.local_chr(10)
      ||'  tax_authority_id           ->'||v_req.tax_authority_id||fnd_global.local_chr(10)
      ||'  tax_authority_site_id      ->'||v_req.tax_authority_site_id||fnd_global.local_chr(10)
      ||'  organization_id            ->'||v_req.organization_id||fnd_global.local_chr(10)
      ||'  deductor_name              ->'||v_req.deductor_name||fnd_global.local_chr(10)
      ||'  deductor_state             ->'||v_req.deductor_state||fnd_global.local_chr(10)
      ||'  addr_changed_since_last_ret->'||v_req.addr_changed_since_last_ret||fnd_global.local_chr(10)
      ||'  deductor_status            ->'||v_req.deductor_status||fnd_global.local_chr(10)
      ||'  person_resp_for_deduction  ->'||v_req.person_resp_for_deduction||fnd_global.local_chr(10)
      ||'  designation_of_pers_resp   ->'||v_req.designation_of_pers_resp||fnd_global.local_chr(10)
      ||'  challan_start_date         ->'||v_req.challan_start_date||fnd_global.local_chr(10)
      ||'  challan_end_date           ->'||v_req.challan_end_date||fnd_global.local_chr(10)
      ||'  file_path                  ->'||v_req.file_path||fnd_global.local_chr(10)
      ||'  filename                   ->'||v_req.filename||fnd_global.local_chr(10)
    );


    UTL_FILE.PUT_LINE(v_filehandle,
        LPAD('LineNo', s_line_number, v_pad_char)
      ||v_pad_char||RPAD('RT', s_record_type, v_pad_char)
      ||v_pad_char||RPAD('FT', s_file_type, v_pad_char)
      ||v_pad_char||RPAD('UT', s_upload_type, v_pad_char)
      ||v_pad_char||LPAD('FileDate', s_date, v_pad_char)
      ||v_pad_char||LPAD('FSeqNo', s_file_sequence_number, v_pad_char)
      ||v_pad_char||RPAD('Org Tan', s_deductor_tan, v_pad_char)
      ||v_pad_char||LPAD('NoOfBatches', s_number_of_batches, v_pad_char)
    );
    UTL_FILE.PUT_LINE(v_filehandle,
        LPAD(v_underline_char, s_line_number, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_record_type, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_file_type, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_upload_type, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_file_sequence_number, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_deductor_tan, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_number_of_batches, v_underline_char)
    );
  END create_fh;

  PROCEDURE create_quarterly_fh
            ( p_batch_id IN NUMBER,
              p_period   IN VARCHAR2,
              p_RespPers_flat_no IN VARCHAR2 , -- Bug 6030953
	          p_RespPers_prem_bldg IN VARCHAR2 , -- Bug 6030953
	          p_RespPers_rd_st_lane IN VARCHAR2 , -- Bug 6030953
	          p_RespPers_area_loc IN VARCHAR2 , -- Bug 6030953
	          p_RespPers_tn_cty_dt IN VARCHAR2 , -- Bug 6030953
              p_RespPersState IN VARCHAR2,
              p_RespPersPin IN NUMBER,
			  p_RespPers_tel_no IN VARCHAR2 , -- Bug 6030953
	          p_RespPers_email IN VARCHAR2 , -- Bug 6030953
              p_RespPersAddrChange IN VARCHAR2
            )
          IS
            v_req   JAI_AP_ETDS_REQUESTS%rowtype;
          BEGIN
             SELECT * INTO v_req FROM JAI_AP_ETDS_REQUESTS WHERE batch_id = p_batch_id;

             UTL_FILE.PUT_LINE(v_filehandle, 'Input Parameters to this Request:');
             UTL_FILE.PUT_LINE(v_filehandle, '-------------------------------------------------');
             UTL_FILE.PUT_LINE(v_filehandle,
                       '  batch_id                   ->'||v_req.batch_id||fnd_global.local_chr(10)
                     ||'  request_id                 ->'||v_req.request_id||fnd_global.local_chr(10)
                     ||'  legal_entity_id            ->'||v_req.legal_entity_id||fnd_global.local_chr(10)
                     ||'  operating_unit_id          ->'||v_req.operating_unit_id||fnd_global.local_chr(10)
                     ||'  org_tan_number             ->'||v_req.org_tan_number||fnd_global.local_chr(10)
                     ||'  financial_year             ->'||v_req.financial_year||fnd_global.local_chr(10)
                     ||'  tax_authority_id           ->'||v_req.tax_authority_id||fnd_global.local_chr(10)
                     ||'  tax_authority_site_id      ->'||v_req.tax_authority_site_id||fnd_global.local_chr(10)
                     ||'  organization_id            ->'||v_req.organization_id||fnd_global.local_chr(10)
                     ||'  deductor_name              ->'||v_req.deductor_name||fnd_global.local_chr(10)
                     ||'  deductor_state             ->'||v_req.deductor_state||fnd_global.local_chr(10)
                     ||'  addr_changed_since_last_ret->'||v_req.addr_changed_since_last_ret||fnd_global.local_chr(10)
                     ||'  deductor_status            ->'||v_req.deductor_status||fnd_global.local_chr(10)
                     ||'  person_resp_for_deduction  ->'||v_req.person_resp_for_deduction||fnd_global.local_chr(10)
                     ||'  designation_of_pers_resp   ->'||v_req.designation_of_pers_resp||fnd_global.local_chr(10)
                     ||'  challan_start_date         ->'||v_req.challan_start_date||fnd_global.local_chr(10)
                     ||'  challan_end_date           ->'||v_req.challan_end_date||fnd_global.local_chr(10)
                     ||'  file_path                  ->'||v_req.file_path||fnd_global.local_chr(10)
                     ||'  filename                   ->'||v_req.filename||fnd_global.local_chr(10)
                     ||'  Period                     ->'||p_period||fnd_global.local_chr(10)
                     ||'  RespPerson''s Flat No      ->'||p_RespPers_Flat_no||fnd_global.local_chr(10)
                     ||'  RespPerson''s Premises/Bldg  ->'||p_RespPers_prem_bldg||fnd_global.local_chr(10)
                     ||'  RespPerson''s Rd/St/Lane   ->'||p_RespPers_rd_st_lane||fnd_global.local_chr(10)
                     ||'  RespPerson''s Area/Loc     ->'||p_RespPers_area_loc||fnd_global.local_chr(10)
                     ||'  RespPerson''s Tn/Cty/Dt    ->'||p_RespPers_tn_cty_dt||fnd_global.local_chr(10)
                     ||'  RespPerson''s State        ->'||p_RespPersState||fnd_global.local_chr(10)
                     ||'  RespPerson''s Pin          ->'||p_RespPersPin||fnd_global.local_chr(10)
					 ||'  RespPerson''s Telephone no ->'||p_RespPers_tel_no||fnd_global.local_chr(10)
                     ||'  RespPerson''s Email        ->'||p_RespPers_email||fnd_global.local_chr(10)
                     ||'  RespPerson''s Addr Changed ->'||p_RespPersAddrChange||fnd_global.local_chr(10)
             );


             UTL_FILE.PUT_LINE(v_filehandle,
                 LPAD('Line No', sq_len_9, v_quart_pad) || v_pad_char ||
                 LPAD('RT', sq_len_2, v_quart_pad) || v_pad_char ||
                 LPAD('FT', sq_len_4, v_quart_pad) || v_pad_char ||
                 LPAD('UT', sq_len_2, v_quart_pad) || v_pad_char ||
                 LPAD('FileDate', sq_len_8, v_quart_pad) || v_pad_char ||
                 LPAD('SeqNo', sq_len_5, v_quart_pad) || v_pad_char ||
                 LPAD('U', sq_len_1, v_quart_pad) || v_pad_char ||
                 LPAD('TAN', sq_len_10, v_quart_pad) || v_pad_char ||
                 LPAD('Batch Cnt', sq_len_9, v_quart_pad) || v_pad_char ||
                 LPAD('Ret Prep util', sq_len_75, v_quart_pad) || v_pad_char ||  /*Bug 8880543 - Added Return Preperation Utility*/
                 LPAD('RH', sq_len_2, v_quart_pad) || v_pad_char ||
                 LPAD('FV', sq_len_2, v_quart_pad) || v_pad_char ||
                 LPAD('FH', sq_len_2, v_quart_pad) || v_pad_char ||
                 LPAD('SV', sq_len_2, v_quart_pad) || v_pad_char ||
                 LPAD('SH', sq_len_2, v_quart_pad) || v_pad_char ||
                 LPAD('SV', sq_len_2, v_quart_pad) || v_pad_char ||
                 LPAD('SH', sq_len_2, v_quart_pad) );

                  UTL_FILE.PUT_LINE(v_filehandle,
                  LPAD(v_underline_char, sq_len_9, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_4, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_8, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_5, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_1, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_10,v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_9, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_75,v_underline_char) || v_pad_char || /*Bug 8880543 - Added Return Preperation Utility*/
                  LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_2, v_underline_char) || v_pad_char ||
                  LPAD(v_underline_char, sq_len_2, v_underline_char) );

        END create_quarterly_fh;

  PROCEDURE create_bh IS
  BEGIN

    -- Batch Header
    UTL_FILE.PUT_LINE(v_filehandle, fnd_global.local_chr(10) );
    UTL_FILE.PUT_LINE(v_filehandle,
        LPAD('LineNo', s_line_number, v_pad_char)
      ||v_pad_char||RPAD('RT', s_record_type, v_pad_char)
      ||v_pad_char||LPAD('BNo', s_batch_number, v_pad_char)
      ||v_pad_char||LPAD('Ch.Cnt', s_challan_count, v_pad_char)
      ||v_pad_char||LPAD('Dd.Cnt', s_deductee_count, v_pad_char)
      ||v_pad_char||RPAD('FNo.', s_form_number, v_pad_char)
      ||v_pad_char||LPAD('RRR No', s_rrr_number, v_pad_char)
      ||v_pad_char||LPAD('RRR Date', s_date, v_pad_char)
      ||v_pad_char||RPAD('Org Tan', s_deductor_tan, v_pad_char)
      ||v_pad_char||RPAD('Org Pan', s_pan_of_tan, v_pad_char)
      ||v_pad_char||LPAD('Ass.Year', s_assessment_year, v_pad_char)
      ||v_pad_char||LPAD('FinYr.', s_financial_year, v_pad_char)
      ||v_pad_char||RPAD('Org Name', s_deductor_name, v_pad_char)
      ||v_pad_char||RPAD('Tan Addr1', s_tan_address1, v_pad_char)
      ||v_pad_char||RPAD('Tan Addr2', s_tan_address2, v_pad_char)
      ||v_pad_char||RPAD('Tan Addr3', s_tan_address3, v_pad_char)
      ||v_pad_char||RPAD('Tan Addr4', s_tan_address4, v_pad_char)
      ||v_pad_char||RPAD('Tan Addr5', s_tan_address5, v_pad_char)
      ||v_pad_char||LPAD('State', s_tan_state, v_pad_char)
      ||v_pad_char||LPAD('TanPin', s_tan_pin, v_pad_char)
      ||v_pad_char||RPAD('ChangeOfAddr', s_chng_addr_since_last_return, v_pad_char)
      ||v_pad_char||RPAD('DS', s_status_of_deductor, v_pad_char)
      ||v_pad_char||RPAD('QY', s_quart_year_return, v_pad_char)
      ||v_pad_char||RPAD('PersonResponsibleForDeduction', s_pers_resp_for_deduction, v_pad_char)
      ||v_pad_char||RPAD('PersonDesignation', s_pers_designation, v_pad_char)
      ||v_pad_char||LPAD('TotChallanTax', s_tot_tax_dedected_challan, v_pad_char)
      ||v_pad_char||LPAD('TotDeducteeTax', s_tot_tax_dedected_deductee, v_pad_char)
    );
    UTL_FILE.PUT_LINE(v_filehandle,
        LPAD(v_underline_char, s_line_number, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_record_type, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_batch_number, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_challan_count, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_deductee_count, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_form_number, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_rrr_number, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_deductor_tan, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_pan_of_tan, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_assessment_year, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_financial_year, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_deductor_name, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_tan_address1, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_tan_address2, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_tan_address3, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_tan_address4, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_tan_address5, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_tan_state, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_tan_pin, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_chng_addr_since_last_return, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_status_of_deductor, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_quart_year_return, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_pers_resp_for_deduction, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_pers_designation, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_tot_tax_dedected_challan, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_tot_tax_dedected_deductee, v_underline_char)
    );
  END create_bh;

  PROCEDURE create_quarterly_bh IS
          BEGIN
            UTL_FILE.PUT_LINE(v_filehandle, ' ' ) ;

            UTL_FILE.PUT_LINE(v_filehandle,
            LPAD('Line No', sq_len_9, v_quart_pad) || v_pad_char ||
            LPAD('RT', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('Batch No', sq_len_9, v_quart_pad) || v_pad_char ||
            LPAD('ChallCnt', sq_len_9, v_quart_pad) || v_pad_char ||
            LPAD('FN', sq_len_4, v_quart_pad) || v_pad_char ||
            LPAD('TT', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('BI', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('OR', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('PR', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('RN', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('RD', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('LT', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('Ded TAN', sq_len_10, v_quart_pad) || v_pad_char ||
            LPAD('F1', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('Ded PAN', sq_len_10, v_quart_pad) || v_pad_char ||
            LPAD('Ass.Yr', sq_len_6, v_quart_pad) || v_pad_char ||
            LPAD('Fin.Yr', sq_len_6, v_quart_pad) || v_pad_char ||
            LPAD('PD', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('Deductor Name', sq_len_75, v_quart_pad) || v_pad_char ||
            LPAD('Deductor Branch', sq_len_75, v_quart_pad) || v_pad_char ||
            LPAD('Deductor Addr1', sq_len_25, v_quart_pad) || v_pad_char ||
            LPAD('Deductor Addr2', sq_len_25, v_quart_pad) || v_pad_char ||
            LPAD('Deductor Addr3', sq_len_25, v_quart_pad) || v_pad_char ||
            LPAD('Deductor Addr4', sq_len_25, v_quart_pad) || v_pad_char ||
            LPAD('Deductor Addr5', sq_len_25, v_quart_pad) || v_pad_char ||
            LPAD('DS', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('DedPIN', sq_len_6, v_quart_pad) || v_pad_char ||
            LPAD('Deductor Email', sq_len_75, v_quart_pad) || v_pad_char ||
            LPAD('DedSTD', sq_len_5, v_quart_pad) || v_pad_char ||
            LPAD('Ded Phone', sq_len_10, v_quart_pad) || v_pad_char ||
            LPAD('C', sq_len_1, v_quart_pad) || v_pad_char ||
            LPAD('T', sq_len_1, v_quart_pad) || v_pad_char ||
            LPAD('RespPerson Name', sq_len_75, v_quart_pad) || v_pad_char ||
            LPAD('RespPerson Desg', sq_len_20, v_quart_pad) || v_pad_char ||
            LPAD('RespPerson Addr1', sq_len_25, v_quart_pad) || v_pad_char ||
            LPAD('RespPerson Addr2', sq_len_25, v_quart_pad) || v_pad_char ||
            LPAD('RespPerson Addr3', sq_len_25, v_quart_pad) || v_pad_char ||
            LPAD('RespPerson Addr4', sq_len_25, v_quart_pad) || v_pad_char ||
            LPAD('RespPerson Addr5', sq_len_25, v_quart_pad) || v_pad_char ||
            LPAD('RS', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('ResPIN', sq_len_6, v_quart_pad) || v_pad_char ||
            LPAD('RespPerson Email', sq_len_75, v_quart_pad) || v_pad_char ||
            LPAD('Remark', sq_len_75, v_quart_pad) || v_pad_char ||
            LPAD('ResSTD', sq_len_5, v_quart_pad) || v_pad_char ||
            LPAD('ResPhone', sq_len_10, v_quart_pad) || v_pad_char ||
            LPAD('C', sq_len_1, v_quart_pad) || v_pad_char ||
            LPAD('TotChallanTax', sq_len_15, v_quart_pad) || v_pad_char ||
            LPAD('TC', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('SC', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('GT', sq_len_2, v_quart_pad) || v_pad_char ||
            LPAD('A', sq_len_1, v_quart_pad) || v_pad_char ||
            LPAD('AO Approval No', sq_len_15, v_quart_pad) || v_pad_char ||
            /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
            LPAD('L', sq_len_1, v_quart_pad)  || v_pad_char ||
            LPAD('SN', sq_len_2, v_quart_pad)  || v_pad_char ||
            LPAD('PAO Code', sq_len_20, v_quart_pad)  || v_pad_char ||
            LPAD('DDO Code', sq_len_20, v_quart_pad)  || v_pad_char ||
            LPAD('MN', sq_len_3, v_quart_pad)  || v_pad_char ||
            LPAD('Ministry Name Other', sq_len_150, v_quart_pad)  || v_pad_char ||
            LPAD('F2', sq_len_12, v_quart_pad)  || v_pad_char ||
            LPAD('PAORgNo', sq_len_7, v_quart_pad)  || v_pad_char ||
            LPAD('DDORgNo', sq_len_10, v_quart_pad)  || v_pad_char ||
            /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
            LPAD('RH', sq_len_2, v_quart_pad)
            );

           UTL_FILE.PUT_LINE(v_filehandle,
           LPAD(v_underline_char, sq_len_9,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_9,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_9,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_4,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_10,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_10,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_6,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_6,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_75,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_75,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_6,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_75,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_5,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_10,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_1,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_1,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_75,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_20,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_25,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_6,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_75,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_75,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_5,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_10,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_1,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_15,  v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_1,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_15,  v_underline_char) || v_pad_char ||
           /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
           LPAD(v_underline_char, sq_len_1,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_2,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_20,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_20,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_3,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_150,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_12,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_7,   v_underline_char) || v_pad_char ||
           LPAD(v_underline_char, sq_len_10,   v_underline_char) || v_pad_char ||
           /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
           LPAD(v_underline_char, sq_len_2,   v_underline_char)
           );

        END create_quarterly_bh;

        PROCEDURE create_quarterly_cd IS
                BEGIN
                  UTL_FILE.PUT_LINE(v_filehandle, ' ' ) ;
                  UTL_FILE.PUT_LINE(v_filehandle,
                  LPAD('Line No', sq_len_9  , v_quart_pad) || v_pad_char ||
                  LPAD('RT', sq_len_2  , v_quart_pad) || v_pad_char ||
                  LPAD('Batch No', sq_len_9  , v_quart_pad) || v_pad_char ||
                  LPAD('Chall No', sq_len_9  , v_quart_pad) || v_pad_char ||
                  LPAD('DeductCnt', sq_len_9  , v_quart_pad) || v_pad_char ||
                  LPAD('I', sq_len_1  , v_quart_pad) || v_pad_char ||
                  LPAD('U', sq_len_2  , v_quart_pad) || v_pad_char ||
                  LPAD('F2', sq_len_2  , v_quart_pad) || v_pad_char ||
                  LPAD('F3', sq_len_2  , v_quart_pad) || v_pad_char ||
                  LPAD('F4', sq_len_2  , v_quart_pad) || v_pad_char ||
                  LPAD('LC', sq_len_2  , v_quart_pad) || v_pad_char ||
                  LPAD('Ch', sq_len_5  , v_quart_pad) || v_pad_char ||
                  LPAD('LV', sq_len_2  , v_quart_pad) || v_pad_char ||
                  LPAD('TrnsVouch', sq_len_9  , v_quart_pad) || v_pad_char ||
                  LPAD('LB', sq_len_2  , v_quart_pad) || v_pad_char ||
                  LPAD('Bank Br', sq_len_7  , v_quart_pad) || v_pad_char ||
                  LPAD('LD', sq_len_2  , v_quart_pad) || v_pad_char ||
                  LPAD('CH. Date', sq_len_8  , v_quart_pad) || v_pad_char ||
                  LPAD('F5', sq_len_2  , v_quart_pad) || v_pad_char ||
                  LPAD('F6', sq_len_2  , v_quart_pad) || v_pad_char ||
                  LPAD('Sec', sq_len_3  , v_quart_pad) || v_pad_char ||
                  LPAD('Oltas Tax', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('Oltas Sur', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('Oltas Cess', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('Oltas Interest', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('Oltas OtherAmt', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('Total Deposit', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('LD', sq_len_2  , v_quart_pad) || v_pad_char ||
                  LPAD('TotTax Deposit', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('TDS Income Tax', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('TDS Surcharge', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('TDS Cess', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('Total TDS ', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('TDS Interest', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('TDS OtherAmt', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('Cheque/DD', sq_len_15  , v_quart_pad) || v_pad_char ||
                  LPAD('B', sq_len_1  , v_quart_pad) || v_pad_char ||
                  LPAD('Remarks', sq_len_14  , v_quart_pad) || v_pad_char ||
                  LPAD('RH', sq_len_2  , v_quart_pad)
                  );

                 UTL_FILE.PUT_LINE(v_filehandle,
                 LPAD(v_underline_char , sq_len_9   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_9   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_9   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_9   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_1   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_5   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_9   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_7   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_8   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_3   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_15  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_1   , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_14  , v_underline_char) || v_pad_char ||
                 LPAD(v_underline_char , sq_len_2   , v_underline_char)
                 );

        END create_quarterly_cd;

        PROCEDURE create_quarterly_dd IS
                BEGIN
                   UTL_FILE.PUT_LINE(v_filehandle, ' ' ) ;
                   UTL_FILE.PUT_LINE(v_filehandle,
                   LPAD('Line No', sq_len_9, v_quart_pad)  || v_pad_char ||
                   LPAD('RT', sq_len_2, v_quart_pad)  || v_pad_char ||
                   LPAD('Batch No', sq_len_9, v_quart_pad)  || v_pad_char ||
                   LPAD('ChallNo', sq_len_9, v_quart_pad)  || v_pad_char ||
                   LPAD('DedRecNo', sq_len_9, v_quart_pad)  || v_pad_char ||
                   LPAD('M', sq_len_1, v_quart_pad)  || v_pad_char ||
                   LPAD('EN', sq_len_2, v_quart_pad)  || v_pad_char ||
                   LPAD('C', sq_len_1, v_quart_pad)  || v_pad_char ||
                   LPAD('LP', sq_len_2, v_quart_pad)  || v_pad_char ||
                   LPAD('Emp Pan', sq_len_10, v_quart_pad)  || v_pad_char ||
                   LPAD('LP', sq_len_2, v_quart_pad)  || v_pad_char ||
                   LPAD('PAN Ref No', sq_len_10, v_quart_pad)  || v_pad_char ||
                   LPAD('Employee Name', sq_len_75, v_quart_pad)  || v_pad_char ||
                   LPAD('TDS Income Tax ', sq_len_15, v_quart_pad)  || v_pad_char ||
                   LPAD('TDS Surcharge', sq_len_15, v_quart_pad)  || v_pad_char ||
                   LPAD('TDS Cess', sq_len_15, v_quart_pad)  || v_pad_char ||
                   LPAD('TDS Total', sq_len_15, v_quart_pad)  || v_pad_char ||
                   LPAD('LT', sq_len_2, v_quart_pad)  || v_pad_char ||
                   LPAD('TotTax Deposit', sq_len_15, v_quart_pad)  || v_pad_char ||
                   LPAD('LT', sq_len_2, v_quart_pad)  || v_pad_char ||
                   LPAD('TP', sq_len_2, v_quart_pad)  || v_pad_char ||
                   LPAD('Payment Amt', sq_len_15, v_quart_pad)  || v_pad_char ||
                   LPAD('Pay Dt', sq_len_8, v_quart_pad)  || v_pad_char ||
                   LPAD('TaxDedDt', sq_len_8, v_quart_pad)  || v_pad_char ||
                   LPAD('DD', sq_len_2, v_quart_pad)  || v_pad_char ||
                   LPAD('Tax Rt', sq_len_7, v_quart_pad)  || v_pad_char ||
                   LPAD('GI', sq_len_2, v_quart_pad)  || v_pad_char ||
                   LPAD('B', sq_len_1, v_quart_pad)  || v_pad_char ||
                   LPAD('TD', sq_len_2, v_quart_pad)  || v_pad_char ||
                   LPAD('R', sq_len_1, v_quart_pad)  || v_pad_char ||
                   LPAD('Remarks 2', sq_len_75, v_quart_pad)  || v_pad_char ||
                   LPAD('Remarks 3', sq_len_14, v_quart_pad)  || v_pad_char ||
                   LPAD('RH', sq_len_2, v_quart_pad)
                   );

                   UTL_FILE.PUT_LINE(v_filehandle,
                   LPAD(v_underline_char  , sq_len_9  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_9  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_9  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_9  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_1  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_1  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_10 , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_10 , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_75 , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_15 , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_15 , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_15 , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_15 , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_15 , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_15 , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_8  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_8  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_7  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_1  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_2  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_1  , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_75 , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_14 , v_underline_char)  || v_pad_char ||
                   LPAD(v_underline_char  , sq_len_2  , v_underline_char)
                   );

                END create_quarterly_dd;


  PROCEDURE create_cd IS
  BEGIN

    -- Challan Detail
    UTL_FILE.PUT_LINE(v_filehandle, fnd_global.local_chr(10) );
    UTL_FILE.PUT_LINE(v_filehandle,
        LPAD('LineNo', s_line_number, v_pad_char)
      ||v_pad_char||RPAD('RT', s_record_type, v_pad_char)
      ||v_pad_char||LPAD('B.No', s_batch_number, v_pad_char)
      ||v_pad_char||LPAD('CSlNo', s_challan_slno, v_pad_char)
      ||v_pad_char||RPAD('Secn.', s_challan_section, v_pad_char)
      ||v_pad_char||LPAD('AmtDeducted', s_amount_deducted, v_pad_char)
      ||v_pad_char||RPAD('Ch.Num.', s_challan_num, v_pad_char)
      ||v_pad_char||LPAD('Ch.Date', s_date, v_pad_char)
      ||v_pad_char||RPAD('BankBrCode', s_bank_branch_code, v_pad_char)
    );
    UTL_FILE.PUT_LINE(v_filehandle,
        LPAD(v_underline_char, s_line_number, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_record_type, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_batch_number, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_challan_slno, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_challan_section, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_amount_deducted, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_challan_num, v_underline_char)
      ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
      ||v_pad_char||RPAD(v_underline_char, s_bank_branch_code, v_underline_char)
    );
  END create_cd;

PROCEDURE create_dd IS
BEGIN

/* Bug 4353842. Added by Lakshmi Gopalsami
   p_grossing_up_factor Obsoleted via bug # 4353842
*/

-- Deductee Detail
UTL_FILE.PUT_LINE(v_filehandle, v_chr10 );
UTL_FILE.PUT_LINE(v_filehandle,
          LPAD('LineNo', s_line_number, v_pad_char)
        ||v_pad_char||RPAD('RT', s_record_type, v_pad_char)
        ||v_pad_char||LPAD('B.No.', s_batch_number, v_pad_char)
        ||v_pad_char||LPAD('DSlNo', s_deductee_slno, v_pad_char)
        ||v_pad_char||RPAD('Secn.', s_deductee_section, v_pad_char)
        ||v_pad_char||RPAD('DCode', s_deductee_code, v_pad_char)
        ||v_pad_char||RPAD('DteePan', s_deductee_pan, v_pad_char)
        ||v_pad_char||RPAD('Deductee Name', s_deductee_name, v_pad_char)
        ||v_pad_char||RPAD('Deductee Addr1', s_deductee_address1, v_pad_char)
        ||v_pad_char||RPAD('Deductee Addr2', s_deductee_address2, v_pad_char)
        ||v_pad_char||RPAD('Deductee Addr3', s_deductee_address3, v_pad_char)
        ||v_pad_char||RPAD('Deductee Addr4', s_deductee_address4, v_pad_char)
        ||v_pad_char||RPAD('Deductee Addr5', s_deductee_address5, v_pad_char)
        ||v_pad_char||LPAD('DState', s_deductee_state, v_pad_char)
        ||v_pad_char||LPAD('DtePin', s_deductee_pin, v_pad_char)
        ||v_pad_char||LPAD('Filler5', s_filler, v_pad_char)
        ||v_pad_char||LPAD('Pay. Amount', s_payment_amount, v_pad_char)
        ||v_pad_char||LPAD('Pay. Date', s_date, v_pad_char)
        ||v_pad_char||LPAD('PBE', s_book_ent_oth , v_pad_char)
        ||v_pad_char||LPAD('TxRt', s_tax_rate, v_pad_char)
        --||v_pad_char||RPAD('Gf', s_grossing_up_factor, v_pad_char)
        ||v_pad_char||LPAD('Filler6', s_filler6, v_pad_char)
        ||v_pad_char||LPAD('TxDeducted', s_tax_deducted, v_pad_char)
        ||v_pad_char||LPAD('TxDed.Dt', s_date, v_pad_date)
        ||v_pad_char||RPAD('BBRCode', s_bank_branch_code, v_pad_char)
        ||v_pad_char||LPAD('TxPay.Dt', s_date, v_pad_date)
        ||v_pad_char||RPAD('ChlnNo', s_challan_no, v_pad_char)
        ||v_pad_char||LPAD('TdsCrtDt', s_date, v_pad_char)
        ||v_pad_char||RPAD('R', s_reason_for_nDeduction, v_pad_char)
        ||v_pad_char||LPAD('Filler7', s_filler, v_pad_char)
);

/* Bug 4353842. Added by Lakshmi Gopalsami
   p_grossing_up_factor Obsoleted via bug # 4353842
*/

UTL_FILE.PUT_LINE(v_filehandle,
          LPAD(v_underline_char, s_line_number, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_record_type, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_batch_number, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_deductee_slno, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_deductee_section, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_deductee_code, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_deductee_pan, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_deductee_name, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_deductee_address1, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_deductee_address2, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_deductee_address3, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_deductee_address4, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_deductee_address5, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_deductee_state, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_deductee_pin, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_filler, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_payment_amount, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_book_ent_oth , v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_tax_rate, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_filler6, v_underline_char)
        --||v_pad_char||RPAD(v_underline_char, s_grossing_up_factor, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_tax_deducted, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_bank_branch_code, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_challan_no, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_date, v_underline_char)
        ||v_pad_char||RPAD(v_underline_char, s_reason_for_nDeduction, v_underline_char)
        ||v_pad_char||LPAD(v_underline_char, s_filler, v_underline_char)
);

END create_dd;


-- added, Harshita for Bug 5096787

      -- eTDS Quarterly Data Generation Procedues

PROCEDURE create_quarterly_file_header(
  p_line_number IN NUMBER,
  p_record_type IN VARCHAR2,
  p_file_type IN VARCHAR2,
  p_upload_type IN VARCHAR2,
  p_file_creation_date IN DATE,
  p_file_sequence_number IN NUMBER,
  p_uploader_type  IN VARCHAR2,
  p_deductor_tan IN VARCHAR2,
  p_number_of_batches IN NUMBER,
  p_return_prep_util IN VARCHAR2, /*Bug 8880543 - Added Return Preperation Utility*/
  p_fh_recordHash IN VARCHAR2,
  p_fh_fvuVersion IN VARCHAR2,
  p_fh_fileHash   IN VARCHAR2,
  p_fh_samVersion IN VARCHAR2,
  p_fh_samHash    IN VARCHAR2,
  p_fh_scmVersion IN VARCHAR2,
  p_fh_scmHash    IN VARCHAR2,
  p_generate_headers IN VARCHAR2
)
IS
BEGIN
 IF p_generate_headers = 'N' THEN

   UTL_FILE.PUT_LINE(v_filehandle,
   p_line_number             ||  v_delimeter||
   p_record_type             ||  v_delimeter||
   p_file_type               ||  v_delimeter||
   p_upload_type             ||  v_delimeter||
   to_char(p_file_creation_date,'ddmmyyyy') ||  v_delimeter||
   p_file_sequence_number    ||  v_delimeter||
   p_uploader_type           ||  v_delimeter||
   upper(p_deductor_tan)     ||  v_delimeter||
   p_number_of_batches       ||  v_delimeter||
   p_return_prep_util        ||  v_delimeter|| /*Bug 8880543 - Added Return Preperation Utility*/
   p_fh_recordHash           ||  v_delimeter||
   p_fh_fvuVersion           ||  v_delimeter||
   p_fh_fileHash             ||  v_delimeter||
   p_fh_samVersion           ||  v_delimeter||
   p_fh_samHash              ||  v_delimeter||
   p_fh_scmVersion           ||  v_delimeter||
   p_fh_scmHash);
 ELSE
   UTL_FILE.PUT_LINE(v_filehandle,
   LPAD(p_line_number , sq_len_9, v_quart_pad) || v_pad_char ||
   LPAD(p_record_type , sq_len_2, v_quart_pad) || v_pad_char ||
   LPAD(p_file_type , sq_len_4, v_quart_pad) || v_pad_char ||
   LPAD(p_upload_type , sq_len_2, v_quart_pad) || v_pad_char ||
   LPAD(p_file_creation_date , sq_len_8, v_quart_pad) || v_pad_char ||
   LPAD(p_file_sequence_number , sq_len_5, v_quart_pad) || v_pad_char ||
   LPAD(p_uploader_type , sq_len_1, v_quart_pad) || v_pad_char ||
   LPAD(upper(p_deductor_tan) , sq_len_10, v_quart_pad) || v_pad_char ||
   LPAD(p_number_of_batches , sq_len_9, v_quart_pad) || v_pad_char ||
   LPAD(p_return_prep_util , sq_len_75, v_quart_pad) || v_pad_char || /*Bug 8880543 - Added Return Preperation Utility*/
   LPAD(NVL(p_fh_recordHash,v_q_noval_filler) , sq_len_2, v_quart_pad) || v_pad_char ||
   LPAD(NVL(p_fh_fvuVersion, v_q_noval_filler) , sq_len_2, v_quart_pad) || v_pad_char ||
   LPAD(NVL(p_fh_fileHash, v_q_noval_filler) , sq_len_2, v_quart_pad) || v_pad_char ||
   LPAD(NVL(p_fh_samVersion, v_q_noval_filler) , sq_len_2, v_quart_pad) || v_pad_char ||
   LPAD(NVL(p_fh_samHash, v_q_noval_filler) , sq_len_2, v_quart_pad) || v_pad_char ||
   LPAD(NVL(p_fh_scmVersion, v_q_noval_filler) , sq_len_2, v_quart_pad) || v_pad_char ||
   LPAD(NVL(p_fh_scmHash, v_q_noval_filler) , sq_len_2, v_quart_pad)
   ) ;

 END IF ;

END create_quarterly_file_header;


PROCEDURE create_quarterly_batch_header(
  p_line_number IN NUMBER,
  p_record_type IN VARCHAR2,
  p_batch_number IN NUMBER,
  p_challan_count IN NUMBER,
  p_form_number IN CHAR,
  p_trn_type IN VARCHAR2,
  p_batchUpd IN VARCHAR2,
  p_org_RRRno IN VARCHAR2,
  p_prev_RRRno         IN VARCHAR2,
  p_RRRno              IN VARCHAR2 ,
  p_RRRdate            IN VARCHAR2 ,
  p_deductor_last_tan  IN VARCHAR2,
  p_deductor_tan       IN VARCHAR2,
  p_filler1            IN VARCHAR2,
  p_deductor_pan       IN VARCHAR2,
  p_assessment_year    IN NUMBER,
  p_financial_year     IN NUMBER,
  p_period             IN VARCHAR2,
  p_deductor_name      IN VARCHAR2,
  p_deductor_branch    IN VARCHAR2,
  p_tan_address1       IN VARCHAR2,
  p_tan_address2       IN VARCHAR2,
  p_tan_address3       IN VARCHAR2,
  p_tan_address4       IN VARCHAR2,
  p_tan_address5       IN VARCHAR2,
  p_tan_state_code     IN NUMBER,
  p_tan_pin            IN NUMBER,
  p_deductor_email     IN VARCHAR2,
  p_deductor_stdCode   IN NUMBER,
  p_deductor_phoneNo   IN NUMBER,
  p_addrChangedSinceLastReturn IN VARCHAR2,
  p_type_of_deductor   IN VARCHAR2, /*Bug 8880543 - Modified Deductor Status to Deductor Type*/
  p_pers_resp_for_deduction IN VARCHAR2,
  p_PespPerson_designation  IN VARCHAR2,
  p_RespPerson_address1     IN VARCHAR2,
  p_RespPerson_address2     IN VARCHAR2,
  p_RespPerson_address3     IN VARCHAR2,
  p_RespPerson_address4     IN VARCHAR2,
  p_RespPerson_address5     IN VARCHAR2,
  p_RespPerson_state        IN VARCHAR2,
  p_RespPerson_pin          IN NUMBER,
  p_RespPerson_email        IN VARCHAR2,
  p_RespPerson_remark       IN VARCHAR2,
  p_RespPerson_stdCode      IN NUMBER,
  p_RespPerson_phoneNo      IN NUMBER,
  p_RespPerson_addressChange IN VARCHAR2,
  p_totTaxDeductedAsPerChallan IN NUMBER,
  p_tds_circle              IN VARCHAR2,
  p_salaryRecords_count     IN VARCHAR2,
  p_gross_total             IN VARCHAR2,
  p_ao_approval             IN VARCHAR2,
  p_ao_approval_number      IN VARCHAR2,
  /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
  p_last_deductor_type      IN  VARCHAR2,
  p_state_name              IN  VARCHAR2,
  p_pao_code                IN  VARCHAR2,
  p_ddo_code                IN  VARCHAR2,
  p_ministry_name           IN  VARCHAR2,
  p_ministry_name_other     IN  VARCHAR2,
  p_filler2                 IN  VARCHAR2,
  p_pao_registration_no     IN  NUMBER,
  p_ddo_registration_no     IN  VARCHAR2,
  /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
  p_recHash                 IN VARCHAR2,
  p_generate_headers        IN VARCHAR2
)
IS
BEGIN
  IF p_generate_headers = 'N' THEN
    UTL_FILE.PUT_LINE( v_filehandle,  p_line_number          ||  v_delimeter||
    p_record_type            ||  v_delimeter||
    p_batch_number           ||  v_delimeter||
    p_challan_count          ||  v_delimeter||
    p_form_number            ||  v_delimeter||
    p_trn_type               ||  v_delimeter||
    p_batchUpd               ||  v_delimeter||
    p_org_RRRno              ||  v_delimeter||
    p_prev_RRRno             ||  v_delimeter||
    p_RRRno                  ||  v_delimeter||
    p_RRRdate                ||  v_delimeter||
    p_deductor_last_tan      ||  v_delimeter||
    upper(p_deductor_tan)    ||  v_delimeter||
    p_filler1                ||  v_delimeter||
    p_deductor_pan           ||  v_delimeter||
    p_assessment_year        ||  v_delimeter||
    p_financial_year         ||  v_delimeter||
    p_period                 ||  v_delimeter||
    p_deductor_name          ||  v_delimeter||
    p_deductor_branch        ||  v_delimeter||
    p_tan_address1           ||  v_delimeter||
    p_tan_address2           ||  v_delimeter||
    p_tan_address3           ||  v_delimeter||
    p_tan_address4           ||  v_delimeter||
    p_tan_address5           ||  v_delimeter||
    p_tan_state_code         ||  v_delimeter||
    p_tan_pin                ||  v_delimeter||
    p_deductor_email         ||  v_delimeter||
    p_deductor_stdCode       ||  v_delimeter||
    p_deductor_phoneNo       ||  v_delimeter||
    p_addrChangedSinceLastReturn ||  v_delimeter||
    p_type_of_deductor       ||  v_delimeter|| /*Bug 8880543 - Modified Status of Deductor to type of Deductor*/
    p_pers_resp_for_deduction   ||  v_delimeter||
    p_PespPerson_designation    ||  v_delimeter||
    p_RespPerson_address1       ||  v_delimeter||
    p_RespPerson_address2       ||  v_delimeter||
    p_RespPerson_address3       ||  v_delimeter||
    p_RespPerson_address4       ||  v_delimeter||
    p_RespPerson_address5       ||  v_delimeter||
    p_RespPerson_state          ||  v_delimeter||
    p_RespPerson_pin            ||  v_delimeter||
    p_RespPerson_email          ||  v_delimeter||
    p_RespPerson_remark         ||  v_delimeter||
    p_RespPerson_stdCode        ||  v_delimeter||
    p_RespPerson_phoneNo        ||  v_delimeter||
    p_RespPerson_addressChange  ||  v_delimeter||
    to_char(p_totTaxDeductedAsPerChallan,v_format_amount) ||  v_delimeter||
    p_tds_circle    ||  v_delimeter||
    p_salaryRecords_count       ||  v_delimeter||
    p_gross_total               ||  v_delimeter||
    p_ao_approval               ||  v_delimeter||
    p_ao_approval_number        ||  v_delimeter||
    /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
    p_last_deductor_type        ||  v_delimeter||
    p_state_name                ||  v_delimeter||
    p_pao_code                  ||  v_delimeter||
    p_ddo_code                  ||  v_delimeter||
    p_ministry_name             ||  v_delimeter||
    p_ministry_name_other       ||  v_delimeter||
    p_filler2                   ||  v_delimeter||
    to_char(p_pao_registration_no)       ||  v_delimeter||
    p_ddo_registration_no       ||  v_delimeter||
    /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
    p_recHash                             ) ;


  ELSE
    UTL_FILE.PUT_LINE( v_filehandle,
    LPAD(p_line_number, sq_len_9  , v_quart_pad) || v_pad_char ||
    LPAD(p_record_type , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(p_batch_number, sq_len_9  , v_quart_pad) || v_pad_char ||
    LPAD(p_challan_count, sq_len_9  , v_quart_pad) || v_pad_char ||
    LPAD(p_form_number, sq_len_4  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_trn_type,v_q_noval_filler ), sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_batchUpd,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_org_RRRno,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_prev_RRRno,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_RRRno,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_RRRdate,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_deductor_last_tan,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(upper(p_deductor_tan), sq_len_10  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_filler1,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_deductor_pan,v_q_null_filler ) , sq_len_10  , v_quart_pad) || v_pad_char ||
    LPAD(p_assessment_year , sq_len_6  , v_quart_pad) || v_pad_char ||
    LPAD(p_financial_year  , sq_len_6  , v_quart_pad) || v_pad_char ||
    LPAD(p_period , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(p_deductor_name, sq_len_75  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_deductor_branch ,v_q_null_filler ), sq_len_75  , v_quart_pad) || v_pad_char ||
    LPAD(p_tan_address1, sq_len_25  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_tan_address2,v_q_null_filler )   , sq_len_25  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_tan_address3,v_q_null_filler )     , sq_len_25  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_tan_address4,v_q_null_filler ) , sq_len_25  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_tan_address5,v_q_null_filler )   , sq_len_25  , v_quart_pad) || v_pad_char ||
    LPAD(p_tan_state_code, sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(p_tan_pin, sq_len_6  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_deductor_email,v_q_null_filler ) , sq_len_75  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_deductor_stdCode,v_quart_numfill ) , sq_len_5  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_deductor_phoneNo,v_quart_numfill )    , sq_len_10  , v_quart_pad) || v_pad_char ||
    LPAD(p_addrChangedSinceLastReturn, sq_len_1  , v_quart_pad) || v_pad_char ||
    LPAD(p_type_of_deductor, sq_len_1  , v_quart_pad) || v_pad_char ||
    LPAD(p_pers_resp_for_deduction, sq_len_75  , v_quart_pad) || v_pad_char ||
    LPAD(p_PespPerson_designation, sq_len_20  , v_quart_pad) || v_pad_char ||
    LPAD(p_RespPerson_address1, sq_len_25  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_RespPerson_address2,v_q_null_filler ) , sq_len_25  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_RespPerson_address3,v_q_null_filler ) , sq_len_25  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_RespPerson_address4,v_q_null_filler ) , sq_len_25  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_RespPerson_address5,v_q_null_filler ) , sq_len_25  , v_quart_pad) || v_pad_char ||
    LPAD(p_RespPerson_state, sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(p_RespPerson_pin, sq_len_6  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_RespPerson_email,v_q_null_filler ) , sq_len_75  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_RespPerson_remark,v_q_null_filler ) , sq_len_75  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_RespPerson_stdCode,v_quart_numfill ) , sq_len_5  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_RespPerson_phoneNo,v_quart_numfill )   , sq_len_10  , v_quart_pad) || v_pad_char ||
    LPAD(p_RespPerson_addressChange, sq_len_1  , v_quart_pad) || v_pad_char ||
    LPAD(to_char(p_totTaxDeductedAsPerChallan,v_format_amount), sq_len_15  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_tds_circle,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_salaryRecords_count,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_gross_total,v_q_noval_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(p_ao_approval, sq_len_1  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_ao_approval_number,v_q_noval_filler ) , sq_len_15  , v_quart_pad) || v_pad_char ||
    /*Bug 8880543 - Modified for eTDS/eTCS FVU changes - Start*/
    LPAD(NVL(p_last_deductor_type, v_q_null_filler ) , sq_len_1  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_state_name, v_q_null_filler ) , sq_len_2  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_pao_code, v_q_null_filler ) , sq_len_20  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_ddo_code, v_q_null_filler ) , sq_len_20  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_ministry_name, v_q_null_filler ) , sq_len_3  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_ministry_name_other, v_q_null_filler ) , sq_len_150  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_filler2, v_q_null_filler ) , sq_len_12  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(to_char(p_pao_registration_no), v_q_null_filler ) , sq_len_7  , v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_ddo_registration_no, v_q_null_filler ) , sq_len_10  , v_quart_pad) || v_pad_char ||
    /*Bug 8880543 - Modified for eTDS/eTCS FVU changes - End*/
    LPAD(NVL(p_recHash,v_q_noval_filler ) , sq_len_2  , v_quart_pad)
    );

  END IF ;
END create_quarterly_batch_header;


PROCEDURE create_quart_challan_dtl(
  p_line_number IN NUMBER ,
  p_record_type IN VARCHAR2 ,
  p_batch_number IN NUMBER ,
  p_challan_dtl_slno IN NUMBER ,
  p_deductee_cnt IN NUMBER ,
  p_nil_challan_indicator IN VARCHAR2 ,
  p_ch_updIndicator IN VARCHAR2 ,
  p_filler2 IN VARCHAR2 ,
  p_filler3 IN VARCHAR2 ,
  p_filler4 IN VARCHAR2 ,
  p_last_bank_challan_no IN VARCHAR2 ,
  p_bank_challan_no IN VARCHAR2 ,
  p_last_transfer_voucher_no IN VARCHAR2 ,
  p_transfer_voucher_no IN NUMBER ,
  p_last_bank_branch_code IN VARCHAR2 ,
  p_bank_branch_code IN VARCHAR2 ,
  p_challan_lastDate IN VARCHAR2 ,
  p_challan_Date IN DATE ,
  p_filler5 IN VARCHAR2 ,
  p_filler6 IN VARCHAR2 ,
  p_tds_section IN VARCHAR2 ,
  p_amt_of_tds IN NUMBER ,
  p_amt_of_surcharge IN NUMBER ,
  p_amt_of_cess IN NUMBER ,
  p_amt_of_int IN NUMBER ,
  p_amt_of_oth IN NUMBER ,
  p_tds_amount IN NUMBER ,
  p_last_total_depositAmt IN NUMBER ,
  p_total_deposit IN NUMBER ,
  p_tds_income_tax IN NUMBER ,
  p_tds_surcharge IN NUMBER ,
  p_tds_cess IN NUMBER ,
  p_total_income_tds IN NUMBER ,
  p_tds_interest_amt IN NUMBER ,
  p_tds_other_amt IN NUMBER ,
  p_check_number IN NUMBER ,
  p_book_entry IN VARCHAR2 ,
  p_remarks IN VARCHAR2 ,
  p_ch_recHash IN VARCHAR2,
  p_generate_headers IN VARCHAR2,
  /* Bug 6796765. Added by Lakshmi Gopalsami
   * Added p_form_name as this is required to print the
   * section code depending on the section
   */
  p_form_name IN VARCHAR2
  ) IS
  /* Bug 6796765. Added by Lakshmi Gopalsami
   * Declared variable to select the section truncation depending on
   * the form name
   */
  lv_sec_string  VARCHAR2(50);
  lv_output_string VARCHAR2 (100);
  ln_tds_section NUMBER;

BEGIN

  /* Bug 6796765. Added by Lakshmi Gopalsami
   * Hardcoding the value of tds_section to be printed in flat file
   * for following values 194BB, 194EE, 194LA
   * as per the details provided in NSDL as separate logic cannot be
   *  derived.
   * Logic here is to get the section code as 194C, 194D, 195 etc.
   * from SEC. 194(C) and then check whether it can be converted to a
   * number. If so, the value will be printed in flat file else
   * extract the value from 2nd character in flat file except for the
   * above hardcoded sections
   */


  lv_sec_string := 'SEC. ()';
  lv_output_string := getSectionCode(upper(p_tds_section), lv_sec_string);

  IF lv_output_string in ('194BB', '194EE') THEN
    lv_output_string := substr(lv_output_string,3,length(lv_output_string));
  ELSIF lv_output_string = '194LA' THEN
    lv_output_string := '94L';
  ELSE
     BEGIN
       ln_tds_section := to_number(lv_output_string);
     EXCEPTION
       WHEN OTHERS THEN
         IF SQLCODE = -6502 THEN
	   lv_output_string := substr(lv_output_string,2,length(lv_output_string));
         END IF;
     END;
  END IF;

  -- End for bug 6796765.

  -- fnd_file.put_line(FND_FILE.LOG,' tds section ' || p_tds_section);
  -- fnd_file.put_line(FND_FILE.LOG,'SEction code with header '||
  -- LPAD(getSectionCode(upper(p_tds_section),upper(lv_sec_string)), sq_len_3, v_quart_pad));
  -- fnd_file.put_line(FND_FILE.LOG,'SEction code with header '|| getSectionCode(upper(p_tds_section),
  -- upper(lv_sec_string)) );

  IF p_generate_headers = 'N' THEN

    -- Bug 6796765. Added by Lakshmi Gopalsami
    -- Changed from getsectioncode to lv_output_string

    UTL_FILE.PUT_LINE(
    v_filehandle,p_line_number                  ||  v_delimeter||
    p_record_type                               ||  v_delimeter||
    p_batch_number                              ||  v_delimeter||
    p_challan_dtl_slno                          ||  v_delimeter||
    p_deductee_cnt                              ||  v_delimeter||
    p_nil_challan_indicator                     ||  v_delimeter||
    p_ch_updIndicator                           ||  v_delimeter||
    p_filler2                                   ||  v_delimeter||
    p_filler3                                   ||  v_delimeter||
    p_filler4                                   ||  v_delimeter||
    p_last_bank_challan_no                      ||  v_delimeter||
    substr(p_bank_challan_no, 1,5)              ||  v_delimeter||
    p_last_transfer_voucher_no                  ||  v_delimeter||
    p_transfer_voucher_no                       ||  v_delimeter||
    p_last_bank_branch_code                     ||  v_delimeter||
    p_bank_branch_code                          ||  v_delimeter||
    p_challan_lastDate                          ||  v_delimeter||
    to_char(p_challan_Date,'ddmmyyyy')          ||  v_delimeter||
    p_filler5                                   ||  v_delimeter||
    p_filler6                                   ||  v_delimeter||
    -- Bug 6796765. Added by Lakshmi Gopalsami
    lv_output_string   ||  v_delimeter||
    to_char(p_amt_of_tds,v_format_amount)       ||  v_delimeter||
    to_char(p_amt_of_surcharge,v_format_amount) ||  v_delimeter||
    to_char(p_amt_of_cess,v_format_amount)      ||  v_delimeter||
    to_char(p_amt_of_int,v_format_amount)       ||  v_delimeter||
    to_char(p_amt_of_oth,v_format_amount)       ||  v_delimeter||
    to_char(p_tds_amount,v_format_amount)       ||  v_delimeter||
    p_last_total_depositAmt                     ||  v_delimeter||
    to_char(p_total_deposit,v_format_amount)    ||  v_delimeter||
    to_char(p_tds_income_tax,v_format_amount)   ||  v_delimeter||
    to_char(p_tds_surcharge,v_format_amount)    ||  v_delimeter||
    to_char(p_tds_cess,v_format_amount)         ||  v_delimeter||
    to_char(p_total_income_tds,v_format_amount) ||  v_delimeter||
    to_char(p_tds_interest_amt,v_format_amount) ||  v_delimeter||
    to_char(p_tds_other_amt, v_format_amount)   ||  v_delimeter||
    p_check_number                              ||  v_delimeter||
    p_book_entry                                ||  v_delimeter||
    p_remarks                                   ||  v_delimeter||
    p_ch_recHash ) ;
  ELSE
    -- Bug 6796765. Added by Lakshmi Gopalsami
    -- Changed from getsectioncode to lv_output_string

    UTL_FILE.PUT_LINE( v_filehandle,
    LPAD(p_line_number     , sq_len_9, v_quart_pad) || v_pad_char ||
    LPAD(p_record_type     , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(p_batch_number       , sq_len_9, v_quart_pad) || v_pad_char ||
    LPAD(p_challan_dtl_slno       , sq_len_9, v_quart_pad) || v_pad_char ||
    LPAD(p_deductee_cnt      , sq_len_9, v_quart_pad) || v_pad_char ||
    LPAD(p_nil_challan_indicator  , sq_len_1, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_ch_updIndicator,v_q_noval_filler),   sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_filler2,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_filler3,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_filler4,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_last_bank_challan_no,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_bank_challan_no,v_q_null_filler )       , sq_len_5, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_last_transfer_voucher_no,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_transfer_voucher_no,v_quart_numfill )       , sq_len_9, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_last_bank_branch_code,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_bank_branch_code,v_q_null_filler )       , sq_len_7, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_challan_lastDate,v_q_noval_filler ) , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(to_char(p_challan_Date,'ddmmyyyy') , sq_len_8, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_filler5,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_filler6,v_q_noval_filler )       , sq_len_2, v_quart_pad) || v_pad_char ||
    -- Bug 6796765. Added by Lakshmi Gopalsami
    LPAD(lv_output_string, sq_len_3, v_quart_pad) || v_pad_char ||
    LPAD(to_char(p_amt_of_tds , v_format_amount)   , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_amt_of_surcharge, v_format_amount)  , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_amt_of_cess, v_format_amount)  , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_amt_of_int, v_format_amount)   , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_amt_of_oth, v_format_amount)   , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_tds_amount, v_format_amount)   , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_last_total_depositAmt, v_quart_numfill) , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_total_deposit, v_format_amount)    , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_tds_income_tax, v_format_amount)   , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_tds_surcharge, v_format_amount)    , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_tds_cess, v_format_amount)         , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_total_income_tds, v_format_amount) , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_tds_interest_amt, v_format_amount) , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_tds_other_amt, v_format_amount)    , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_check_number,v_quart_numfill ) , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_book_entry,v_q_null_filler )   , sq_len_1, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_remarks,v_q_null_filler )     , sq_len_14, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_ch_recHash,v_q_noval_filler )  , sq_len_2, v_quart_pad)
    );
  END IF ;
END create_quart_challan_dtl;


PROCEDURE create_quart_deductee_dtl(
  p_line_number IN NUMBER,
  p_record_type IN VARCHAR2,
  p_batch_number IN NUMBER,
  p_dh_challan_recNo IN NUMBER,
  p_deductee_slno IN NUMBER,
  p_dh_mode IN VARCHAR2,
  p_emp_serial_no IN VARCHAR2,
  p_deductee_code IN VARCHAR2,
  p_last_emp_pan IN VARCHAR2,
  p_deductee_pan IN VARCHAR2,
  p_last_emp_pan_refno IN VARCHAR2,
  p_deductee_pan_refno IN VARCHAR2,
  p_vendor_name IN VARCHAR2,
  p_deductee_tds_income_tax IN NUMBER,
  p_deductee_tds_surcharge IN NUMBER,
  p_deductee_tds_cess IN NUMBER,
  p_deductee_total_tax_deducted IN NUMBER,
  p_last_total_tax_deducted IN VARCHAR2,
  p_deductee_total_tax_deposit IN NUMBER,
  p_last_total_tax_deposit IN VARCHAR2,
  p_total_purchase IN VARCHAR2,
  p_base_taxabale_amount IN NUMBER,
  p_gl_date IN DATE,
  p_tds_invoice_date IN DATE,
  p_deposit_date IN VARCHAR2,
  p_tds_tax_rate IN NUMBER,
  p_grossingUp_ind IN VARCHAR2,
  p_book_ent_oth IN VARCHAR2,
  p_certificate_issue_date IN VARCHAR2,
  p_remarks1 IN VARCHAR2,
  p_remarks2 IN VARCHAR2,
  p_remarks3 IN VARCHAR2,
  p_dh_recHash  IN VARCHAR2,
  p_generate_headers IN VARCHAR2
)
IS
BEGIN
  IF p_generate_headers = 'N' THEN
    UTL_FILE.PUT_LINE( v_filehandle,
    p_line_number                                             || v_delimeter  ||
    p_record_type                                             || v_delimeter  ||
    p_batch_number                                            || v_delimeter  ||
    p_dh_challan_recNo                                        || v_delimeter  ||
    p_deductee_slno                                           || v_delimeter  ||
    p_dh_mode                                                 || v_delimeter  ||
    p_emp_serial_no                                           || v_delimeter  ||
    p_deductee_code                                           || v_delimeter  ||
    p_last_emp_pan                                            || v_delimeter  ||
    p_deductee_pan                                            || v_delimeter  ||
    p_last_emp_pan_refno                                      || v_delimeter  ||
    p_deductee_pan_refno                                      || v_delimeter  ||
    p_vendor_name                                             || v_delimeter  ||
    to_char( p_deductee_tds_income_tax, v_format_amount)      || v_delimeter  ||
    to_char( p_deductee_tds_surcharge, v_format_amount)       || v_delimeter  ||
    to_char( p_deductee_tds_cess, v_format_amount)            || v_delimeter  ||
    to_char( p_deductee_total_tax_deducted, v_format_amount)  || v_delimeter  ||
    p_last_total_tax_deducted                                 || v_delimeter  ||
    to_char( p_deductee_total_tax_deposit, v_format_amount)   || v_delimeter  ||
    p_last_total_tax_deposit                                  || v_delimeter  ||
    p_total_purchase                                          || v_delimeter  ||
    to_char( p_base_taxabale_amount, v_format_amount)         || v_delimeter  ||
    to_char(p_gl_date,'ddmmyyyy')                             || v_delimeter  ||
    to_char(p_tds_invoice_date,'ddmmyyyy')                    || v_delimeter  ||
    p_deposit_date                                            || v_delimeter  ||
    -- Bug 6070014. Added by csahoo.
		-- Changed the hardcoded value to assigned value.
    to_char(p_tds_tax_rate,v_format_rate)                       || v_delimeter  ||
    p_grossingUp_ind                                          || v_delimeter  ||
    p_book_ent_oth                                            || v_delimeter  ||
    p_certificate_issue_date                                  || v_delimeter  ||
    p_remarks1                                                || v_delimeter  ||
    p_remarks2                                                || v_delimeter  ||
    p_remarks3                                                || v_delimeter  ||
    p_dh_recHash
        );
  ELSE
    UTL_FILE.PUT_LINE( v_filehandle,
    LPAD(p_line_number  , sq_len_9, v_quart_pad) || v_pad_char ||
    LPAD(p_record_type  , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(p_batch_number  , sq_len_9, v_quart_pad) || v_pad_char ||
    LPAD(p_dh_challan_recNo  , sq_len_9, v_quart_pad) || v_pad_char ||
    LPAD(p_deductee_slno  , sq_len_9, v_quart_pad) || v_pad_char ||
    LPAD(p_dh_mode  , sq_len_1, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_emp_serial_no,v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(p_deductee_code  , sq_len_1, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_last_emp_pan, v_q_noval_filler), sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(p_deductee_pan  , sq_len_10, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_last_emp_pan_refno,v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_deductee_pan_refno,v_q_null_filler)  , sq_len_10, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_vendor_name, v_q_null_filler) , sq_len_75, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_deductee_tds_income_tax, v_format_amount)    , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_deductee_tds_surcharge, v_format_amount)  , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_deductee_tds_cess, v_format_amount)  , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_deductee_total_tax_deducted, v_format_amount)   , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_last_total_tax_deducted, v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_deductee_total_tax_deposit, v_format_amount) , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_last_total_tax_deposit, v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_total_purchase, v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(to_char( p_base_taxabale_amount, v_format_amount) , sq_len_15, v_quart_pad) || v_pad_char ||
    LPAD(to_char(p_gl_date,'ddmmyyyy')  , sq_len_8, v_quart_pad) || v_pad_char ||
    LPAD(NVL(to_char(p_tds_invoice_date,'ddmmyyyy'),G_DATE_DUMMY) , sq_len_8, v_quart_pad) || v_pad_char ||  -- change later
    LPAD(NVL(p_deposit_date, v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD( to_char(p_tds_tax_rate,v_format_rate), sq_len_7, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_grossingUp_ind, v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(p_book_ent_oth  , sq_len_1, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_certificate_issue_date,v_q_noval_filler)  , sq_len_2, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_remarks1,v_q_null_filler)  , sq_len_1, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_remarks2,v_q_noval_filler)  , sq_len_75, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_remarks3,v_q_noval_filler)  , sq_len_14, v_quart_pad) || v_pad_char ||
    LPAD(NVL(p_dh_recHash,v_q_noval_filler) , sq_len_2, v_quart_pad)
        );
  END IF ;
END create_quart_deductee_dtl;

-- Validation related Procedures.

PROCEDURE validate_file_header
( p_line_number         IN NUMBER ,
  p_record_type         IN VARCHAR2,
  p_quartfile_type      IN VARCHAR2,
  p_upload_type         IN VARCHAR2,
  p_file_creation_date  IN DATE,
  p_file_sequence_number IN NUMBER,
  p_uploader_type       IN VARCHAR2,
  p_deductor_tan        IN VARCHAR2,
  p_number_of_batches   IN NUMBER,
  p_ret_prep_util       IN VARCHAR2, /*Bug 8880543 - Added Return Preperation Utility*/
  p_period              IN VARCHAR2,
  p_challan_start_date  IN DATE,
  p_challan_end_date    IN DATE,
  p_fin_year            IN NUMBER,
  p_return_code         OUT NOCOPY VARCHAR2,
  p_return_message      OUT NOCOPY VARCHAR2
)
IS
   lv_q1_start_date   VARCHAR2(11) ;
   lv_q1_end_date     VARCHAR2(11) ;
   lv_q2_start_date   VARCHAR2(11) ;
   lv_q2_end_date     VARCHAR2(11) ;
   lv_q3_start_date   VARCHAR2(11) ;
   lv_q3_end_date     VARCHAR2(11) ;
   lv_q4_start_date   VARCHAR2(11) ;
   lv_q4_end_date     VARCHAR2(11) ;
   ln_fin_year        NUMBER ;
   lv_date_format     VARCHAR2(11);
BEGIN

     IF p_line_number IS NULL THEN
       p_return_message := p_return_message ||  ' Line Number should not be null. '   ;
       IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
       END IF ;
     END IF;
     IF p_record_type IS NULL THEN
       p_return_message := p_return_message ||  ' Record Type is null. '     ;
       IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
       END IF ;
     END IF;
     IF p_quartfile_type IS NULL THEN
       p_return_message := p_return_message ||  ' File Type is null. '   ;
       IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
       END IF ;
     END IF;
     IF p_upload_type IS NULL THEN
       p_return_message := p_return_message ||  ' Upload Type is null. '    ;
       IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
       END IF ;
     END IF;
     IF p_file_creation_date IS NULL THEN
       p_return_message := p_return_message ||  ' File Creation Date is null. '    ;
       IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
       END IF ;
     END IF;
     IF p_file_sequence_number IS NULL THEN
       p_return_message := p_return_message ||  ' File Sequence No is null. '  ;
       IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
       END IF ;
     END IF;
     IF p_uploader_type IS NULL THEN
       p_return_message := p_return_message ||  ' Upload Type is null. '   ;
       IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
       END IF ;
     END IF;
     IF p_deductor_tan IS NULL THEN
       p_return_message := p_return_message ||  ' Deductor TAN is null. '   ;
       IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
       END IF ;
     END IF;
     IF p_number_of_batches IS NULL THEN
       p_return_message := p_return_message ||  ' Batch Count is null. '   ;
       IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
       END IF ;
     END IF;
     /*Bug 8880543 - Added Return Preperation Utility*/
     IF p_ret_prep_util IS NULL THEN
       p_return_message := p_return_message ||  ' Return Preperation Utility is null. '   ;
       IF lv_action <> 'V' THEN
          goto  end_of_procedure  ;
       END IF ;
     END IF;


   IF p_period = 'Q1' THEN
      lv_q1_start_date := '01-APR-' || p_fin_year ;
      lv_q1_end_date   := '30-JUN-' || p_fin_year ;
      lv_date_format := 'DD-MON-YYYY' ;

      IF not ( p_challan_start_date >=  to_date(lv_q1_start_date,lv_date_format) and p_challan_end_date <=  to_date(lv_q1_end_date,lv_date_format) ) THEN
       p_return_message := ' The given Challan Start and end dates do not fall under the specified Quarter and Year. ' ;
       goto  end_of_procedure  ;
      END IF ;
    ELSIF p_period = 'Q2' THEN
      lv_q2_start_date := '01-JUL-' || p_fin_year;
      lv_q2_end_date   := '30-SEP-' || p_fin_year;

      IF not ( p_challan_start_date >=  to_date(lv_q2_start_date,lv_date_format)  and p_challan_end_date <=  to_date(lv_q2_end_date,lv_date_format) ) THEN
         p_return_message := ' The given Challan Start and end dates do not fall under the specified Quarter and Year. '  ;
         goto  end_of_procedure  ;
      END IF ;
    ELSIF p_period = 'Q3' THEN
      lv_q3_start_date := '01-OCT-' || p_fin_year;
      lv_q3_end_date   := '31-DEC-' || p_fin_year;

      IF not ( p_challan_start_date >=  to_date(lv_q3_start_date,lv_date_format) and p_challan_end_date  <=  to_date(lv_q3_end_date,lv_date_format) ) THEN
         p_return_message := ' The given Challan Start and end dates do not fall under the specified Quarter and Year. '  ;
         goto  end_of_procedure  ;
      END IF ;
    ELSIF p_period = 'Q4' THEN
      ln_fin_year := p_fin_year + 1 ;
      lv_q4_start_date := '01-JAN-' || ln_fin_year;
      lv_q4_end_date   := '31-MAR-' || ln_fin_year;

      IF not ( p_challan_start_date >=  to_date(lv_q4_start_date,lv_date_format) and p_challan_end_date <= to_date(lv_q4_end_date,lv_date_format)  ) THEN
         p_return_message := ' The given Challan Start and end dates do not fall under the specified Quarter and Year. '  ;
         goto  end_of_procedure  ;
    END IF ;
  END IF ;

    IF lv_action = 'V' THEN
      goto  end_of_procedure  ;
         END IF ;

   <<end_of_procedure>>
   if p_return_message is not null then
     p_return_code := 'E';
     p_return_message := 'File Header Error - ' || 'Line No : ' || p_line_number || '. ' ||  p_return_message ;
        end if;

END validate_file_header;

PROCEDURE validate_batch_header
 ( p_line_number                  IN  NUMBER,
   p_record_type                  IN  VARCHAR2,
   p_batch_number                 IN  NUMBER,
   p_challan_cnt                  IN  NUMBER,
   p_quart_form_number            IN  VARCHAR2,
   p_deductor_tan                 IN  VARCHAR2,
   p_assessment_year              IN  NUMBER,
   p_financial_year               IN  NUMBER,
   p_deductor_name                IN  VARCHAR2,
   p_deductor_pan                 IN  VARCHAR2, /*Bug 8880543 - Added for Validating PAN Number*/
   p_tan_address1                 IN  VARCHAR2,
   p_tan_state_code               IN  NUMBER,
   p_tan_pin                      IN  NUMBER,
   p_deductor_type                IN  VARCHAR2, /*Bug 8880543 - Modified Deductor Status to Deductor Type*/
   p_addrChangedSinceLastReturn   IN  VARCHAR2,
   p_personNameRespForDedection   IN  VARCHAR2,
   p_personDesgnRespForDedection  IN  VARCHAR2,
   p_RespPers_flat_no IN VARCHAR2 , -- Bug 6030953
   p_RespPers_prem_bldg IN VARCHAR2 , -- Bug 6030953
   p_RespPers_rd_st_lane IN VARCHAR2 , -- Bug 6030953
   p_RespPers_area_loc IN VARCHAR2 , -- Bug 6030953
   p_RespPers_tn_cty_dt IN VARCHAR2 , -- Bug 6030953
   p_RespPersState                IN  NUMBER,
   p_RespPersPin                  IN  NUMBER,
   p_RespPers_tel_no IN VARCHAR2 , -- Bug 6030953
   p_RespPers_email IN VARCHAR2 , -- Bug 6030953
   p_RespPersAddrChange           IN  VARCHAR2,
   p_totTaxDeductedAsPerDeductee  IN  NUMBER,
   p_ao_approval                  IN  VARCHAR2,
   /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
   p_state_name                   IN  VARCHAR2,
   p_pao_code                     IN  VARCHAR2,
   p_ddo_code                     IN  VARCHAR2,
   p_ministry_name                IN  VARCHAR2,
   p_pao_registration_no          IN  NUMBER,
   p_ddo_registration_no          IN  VARCHAR2,
   /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
   p_return_code                  OUT NOCOPY VARCHAR2,
   p_return_message               OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN

    IF p_line_number   IS NULL THEN
     p_return_message := p_return_message ||  ' Line Number should not be null. ' ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_record_type   IS NULL THEN
     p_return_message := p_return_message ||  ' Record Type is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_batch_number  IS NULL THEN
     p_return_message := p_return_message ||  ' Batch Number is null. ' ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_challan_cnt IS NULL THEN
     p_return_message := p_return_message ||  ' Record Count is null. ' ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_quart_form_number  IS NULL THEN
     p_return_message := p_return_message ||  ' Form Number is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_deductor_tan   IS NULL THEN
     p_return_message := p_return_message ||  ' Deductor TAN is null. ' ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_assessment_year IS NULL THEN
     p_return_message := p_return_message ||  ' Assessment Year is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_financial_year IS NULL THEN
     p_return_message := p_return_message ||  ' Financial Year is null. ' ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_deductor_name IS NULL THEN
     p_return_message := p_return_message ||  ' Deductor Name is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    /*Bug 8880543 - PAN Number Validation - Start*/
    IF p_deductor_pan IS NULL THEN
     p_return_message := p_return_message ||  ' Deductor PAN is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    ELSE
     IF (validate_alpha_numeric(p_deductor_pan, length(p_deductor_pan)) = 'INVALID') THEN
         p_return_message := p_return_message ||  ' PAN format incorrect. The first five must be alphabets, followed by four numbers, and then followed by an alphabet.'  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
     END IF;
    END IF ;
    /*Bug 8880543 - PAN Number Validation - End*/
    IF p_tan_address1  IS NULL THEN
     p_return_message := p_return_message ||  ' Deductor Address is null. ' ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_tan_state_code   IS NULL THEN
     p_return_message := p_return_message ||  ' Deductor State is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_tan_pin    IS NULL THEN
     p_return_message := p_return_message ||  ' Deductor Pin is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_deductor_type IS NULL THEN
     p_return_message := p_return_message ||  ' Deductor Type is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_addrChangedSinceLastReturn IS NULL THEN
     p_return_message := p_return_message ||  ' Field Deductor Addredd Changed Since last year is null. ' ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_personNameRespForDedection IS NULL THEN
     p_return_message := p_return_message ||  ' Person Responsible For Deduction is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_personDesgnRespForDedection IS NULL THEN
     p_return_message := p_return_message ||  ' Designation of Responsible Person  is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
      -- Bug 6030953. Added by Lakshmi Gopalsami
       IF p_RespPers_flat_no   IS NULL THEN
         p_return_message := p_return_message ||  ' Flat No. of Responsible Person is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;

       IF p_RespPers_prem_bldg   IS NULL THEN
         p_return_message := p_return_message ||  ' Name of the premises/bldg of Responsible Person is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;

       IF p_RespPers_rd_st_lane   IS NULL THEN
         p_return_message := p_return_message ||  ' Road/Street/Lane of Responsible Person is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;

       IF p_RespPers_area_loc   IS NULL THEN
         p_return_message := p_return_message ||  ' Area/Location of Responsible Person is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;

       IF p_RespPers_tn_cty_dt   IS NULL THEN
         p_return_message := p_return_message ||  ' Town/City/District of Responsible Person is null. '  ;
         IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
       END IF ;
	   -- End for bug 6030953

    IF p_RespPersState    IS NULL THEN
     p_return_message := p_return_message ||  ' State of Responsible Person is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_RespPersPin   IS NULL THEN
     p_return_message := p_return_message ||  ' Pin  of Responsible Person is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_RespPersAddrChange IS NULL THEN
     p_return_message := p_return_message ||  ' Field ''Address of Responsible Person has Changed'' is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_totTaxDeductedAsPerDeductee IS NULL THEN
     p_return_message := p_return_message ||  ' Total Deposit Amount as per Challan is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;
    IF p_ao_approval  IS NULL THEN
     p_return_message := p_return_message ||  ' AO Approval is null. '  ;
     IF lv_action <> 'V' THEN
       goto  end_of_procedure  ;
     END IF ;
    END IF ;

    /*Bug 8880543 - Validation for eTDs/eTCS FVU changes - Start*/

    IF p_deductor_type in ('S', 'E', 'H', 'N') THEN
        IF p_state_name IS NULL THEN
            p_return_message := p_return_message ||  ' State is required when Deductor Type is S/E/H/N. '  ;
            IF lv_action <> 'V' THEN
                goto  end_of_procedure  ;
            END IF ;
        END IF ;
    END IF;

    IF p_deductor_type in ('A') THEN
        IF p_pao_code IS NULL THEN
            p_return_message := p_return_message ||  ' PAO Code is required when Deductor Type is A. '  ;
            IF lv_action <> 'V' THEN
                goto  end_of_procedure  ;
            END IF ;
        END IF ;
        IF p_ddo_code IS NULL THEN
            p_return_message := p_return_message ||  ' DDO Code is required when Deductor Type is A. '  ;
            IF lv_action <> 'V' THEN
                goto  end_of_procedure  ;
            END IF ;
        END IF ;
    END IF;

    IF p_deductor_type in ('A', 'D', 'G') THEN
        IF p_ministry_name IS NULL THEN
            p_return_message := p_return_message ||  ' Ministry Name is required when Deductor Type is A/D/G. '  ;
            IF lv_action <> 'V' THEN
                goto  end_of_procedure  ;
            END IF ;
        END IF ;
    END IF;


    IF lv_action = 'V' THEN
     goto  end_of_procedure  ;
    END IF ;

    <<end_of_procedure>>
    IF p_return_message IS NOT NULL THEN
      p_return_code := 'E';
      p_return_message := 'Batch Header Error - ' || 'Line No : ' || p_line_number || '. ' || p_return_message ;
    END IF;

 END validate_batch_header;

PROCEDURE validate_challan_detail
(p_line_number           IN  NUMBER ,
p_record_type           IN  VARCHAR2,
p_batch_number          IN  NUMBER,
p_challan_dtl_slno      IN  NUMBER,
p_deductee_cnt          IN  NUMBER,
p_nil_challan_indicat   IN  VARCHAR2,
p_tds_section           IN  VARCHAR2,
p_amt_of_tds            IN  NUMBER,
p_amt_of_surcharge      IN  NUMBER,
p_amt_of_cess           IN  NUMBER,
p_amt_of_oth            IN  NUMBER,
p_tds_amount            IN  NUMBER,
p_total_income_tds      IN  NUMBER,
p_challan_num           IN  VARCHAR2,
p_bank_branch_code      IN  VARCHAR2,
p_challan_no            IN  VARCHAR2,
p_challan_Date          IN  DATE,
p_check_number          IN  NUMBER,
p_return_code           OUT NOCOPY VARCHAR2,
p_return_message        OUT NOCOPY VARCHAR2
)
IS
BEGIN
 IF p_line_number               IS NULL THEN
        p_return_message := p_return_message ||     ' Line number should not be null. '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_record_type               IS NULL THEN
        p_return_message := p_return_message ||     ' Record Type is null. '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_batch_number              IS NULL THEN
        p_return_message := p_return_message ||     ' Batch Number is null. '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_challan_dtl_slno          IS NULL THEN
        p_return_message := p_return_message ||     ' Challan Record Number is null. '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_deductee_cnt              IS NULL THEN
        p_return_message := p_return_message ||     ' Deductee Count is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_nil_challan_indicat       IS NULL THEN
        p_return_message := p_return_message ||     ' NIL Challan Indicator is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_tds_section               IS NULL THEN
        p_return_message := p_return_message ||     ' TDS Section is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_amt_of_tds                IS NULL THEN
        p_return_message := p_return_message ||     ' TDS Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_amt_of_surcharge          IS NULL THEN
        p_return_message := p_return_message ||     ' TDS Surcharge Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_amt_of_cess IS NULL THEN
        p_return_message := p_return_message ||     ' TDS Cess Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_amt_of_oth                IS NULL THEN
        p_return_message := p_return_message ||     ' TDS Other Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_tds_amount                IS NULL THEN
        p_return_message := p_return_message ||     ' Total TDS Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_challan_no                IS NULL THEN
        p_return_message := p_return_message ||   ' CHallan No is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;
      IF p_challan_Date                IS NULL THEN
        p_return_message := p_return_message ||   ' CHallan Date is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
         END IF ;
      END IF ;

      IF p_total_income_tds          IS NULL THEN
        p_return_message := p_return_message ||   ' Total Tax Deposit Amount is null  . '   ;
        IF lv_action <> 'V' THEN
           goto  end_of_procedure  ;
        END IF ;
      END IF ;

      -- Harshita for Bug 4640996
      check_numeric(p_challan_num, 'Check Number : ' || p_check_number  || ' Challan Number is not a Numeric Value', lv_action);
      check_numeric(p_bank_branch_code, 'Check Number : ' || p_check_number  || ' Bank Branch Code is not a Numeric Value ', lv_action);

      IF lv_action = 'V' THEN
        goto  end_of_procedure  ;
      END IF ;

      <<end_of_procedure>>
      IF p_return_message IS NOT NULL THEN
        p_return_code := 'E';
        p_return_message := 'Challan Detail Error - ' || 'Check Number : ' || p_check_number || '. ' || p_return_message ;
      END IF;
END validate_challan_detail;

PROCEDURE validate_deductee_detail
( p_line_number                  IN  NUMBER ,
 p_record_type                  IN  VARCHAR2,
 p_batch_number                 IN  NUMBER,
 p_challan_line_num             IN  NUMBER,
 p_deductee_slno                IN  NUMBER,
 p_dh_mode                      IN  VARCHAR2,
 p_quart_deductee_code          IN  VARCHAR2,
 p_deductee_pan                 IN  VARCHAR2,
 p_vendor_name                  IN  VARCHAR2,
 p_amt_of_tds                   IN  NUMBER,
 p_amt_of_surcharge             IN  NUMBER ,
 p_amt_of_cess                  IN  NUMBER  ,
 p_deductee_total_tax_deducted  IN  NUMBER,
 p_base_taxabale_amount         IN  NUMBER,
 p_gl_date                      IN  DATE ,
 p_book_ent_oth                 IN  VARCHAR2,
 p_return_code                  OUT NOCOPY VARCHAR2,
 p_return_message               OUT NOCOPY VARCHAR2
)
IS
BEGIN
 IF p_line_number  IS NULL THEN
       p_return_message := p_return_message ||     '  Line Number should not be null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_record_type  IS NULL THEN
       p_return_message := p_return_message ||     '  Record Type is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_batch_number IS NULL THEN
       p_return_message := p_return_message ||   ' Batch Number is null. '   ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_challan_line_num   IS NULL THEN
       p_return_message := p_return_message ||     '  Challan Record Number is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_deductee_slno  IS NULL THEN
       p_return_message := p_return_message ||     '  Party Detail Record Number is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_dh_mode  IS NULL THEN
       p_return_message := p_return_message ||     '  Mode is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_quart_deductee_code  IS NULL THEN
       p_return_message := p_return_message ||     '  Deductee Party Code is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_deductee_pan IS NULL THEN
       p_return_message := p_return_message ||     '  Deductee PAN is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      /*Bug 8880543 - Added validation for PAN - Start*/
      ELSE
       IF (validate_alpha_numeric(p_deductee_pan, length(p_deductee_pan)) = 'INVALID') THEN
          p_return_message := p_return_message ||  ' PAN format incorrect. The first five must be alphabets, followed by four numbers, and then followed by an alphabet.'  ;
          IF lv_action <> 'V' THEN
             goto  end_of_procedure  ;
          END IF ;
       END IF;
      /*Bug 8880543 - Added validation for PAN - End*/
      END IF ;
      IF p_vendor_name  IS NULL THEN
       p_return_message := p_return_message ||     '  Party Name is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_amt_of_tds  IS NULL THEN
       p_return_message := p_return_message ||     '  TDS Income Tax for the Period is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_amt_of_surcharge   IS NULL THEN
       p_return_message := p_return_message ||     '  TDS Surcharge is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_amt_of_cess   IS NULL THEN
       p_return_message := p_return_message ||     '  TDS Cess is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_deductee_total_tax_deducted IS NULL THEN
       p_return_message := p_return_message ||     '  Total TDS  is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_base_taxabale_amount IS NULL THEN
       p_return_message := p_return_message ||     '  Payment Amount is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_gl_date IS NULL THEN
       p_return_message := p_return_message ||     '  Date on which Amount Credited is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;
      IF p_book_ent_oth  IS NULL THEN
       p_return_message := p_return_message ||     '  Book/Cash Entry is null. '  ;
       IF lv_action <> 'V' THEN
         goto  end_of_procedure  ;
       END IF ;
      END IF ;

       IF lv_action = 'V' THEN
         goto  end_of_procedure  ;
       END IF ;

      <<end_of_procedure>>
      if p_return_message is not null then
        p_return_code := 'E';
        p_return_message := 'Deductee Detail Error - ' ||  p_return_message ;
      end if;
END validate_deductee_detail;

PROCEDURE check_numeric
(p_variable IN VARCHAR2 ,
p_err      IN VARCHAR2 ,
p_action   IN VARCHAR2
)
IS
ln_check_number NUMBER ;
BEGIN
   ln_check_number := to_number( p_variable ) ;
    EXCEPTION
     WHEN OTHERS THEN
      FND_FILE.put_line(FND_FILE.log, 'sql code : ' || SQLCODE );
      FND_FILE.put_line(FND_FILE.log, 'Challan Detail Error - ' || '.  ERROR : ' || p_err );

      -- Harshita for Bug 4640996
      IF p_action <> 'V' THEN
        raise_application_error(-20023, 'Challan Detail Error - ' || '.  ERROR : ' || p_err );
      END IF ;
END check_numeric;

/* Functional Related Procedures */

PROCEDURE quarterly_returns(
  p_err_buf OUT NOCOPY VARCHAR2,
  p_ret_code OUT NOCOPY NUMBER,
  --p_legal_entity_id   IN NUMBER,		--commented by csahoo for bug#6158875
  --p_profile_org_id    IN NUMBER,		--commented by csahoo for bug#6158875
  p_tan_number      IN VARCHAR2,
  p_fin_year        IN NUMBER,
  p_period          IN VARCHAR2,
  p_tax_authority_id    IN NUMBER,
  p_tax_authority_site_id IN NUMBER,
  p_organization_id   IN NUMBER,
  p_deductor_name     IN VARCHAR2,
  p_deductor_state    IN VARCHAR2,
  p_addrChangedSinceLastRet IN VARCHAR2,
  --p_deductor_status   IN VARCHAR2,  /*Bug 8880543 - Commented for eTDS/eTCS FVU Changes*/
  p_persRespForDeduction  IN VARCHAR2,
  p_desgOfPersResponsible IN VARCHAR2,
  p_RespPers_flat_no IN VARCHAR2 , -- Bug 6030953
  p_RespPers_prem_bldg IN VARCHAR2 , -- Bug 6030953
  p_RespPers_rd_st_lane IN VARCHAR2 , -- Bug 6030953
  p_RespPers_area_loc IN VARCHAR2 , -- Bug 6030953
  p_RespPers_tn_cty_dt IN VARCHAR2 , -- Bug 6030953
  p_RespPersState IN VARCHAR2 ,
  p_RespPersPin IN NUMBER ,
  p_RespPers_tel_no IN VARCHAR2 , -- Bug 6030953
  p_RespPers_email IN VARCHAR2 , -- Bug 6030953
  p_RespPersAddrChange IN VARCHAR2,
  p_challan_Start_Date  IN VARCHAR2,
  p_challan_End_Date    IN VARCHAR2,
  p_pro_rcpt_num_org_ret IN NUMBER,
  p_file_path       IN VARCHAR2,
  p_filename        IN VARCHAR2,
  p_action          IN VARCHAR2 DEFAULT NULL,
  p_include_list    IN VARCHAR2,
  p_exclude_list    IN VARCHAR2 --Date 11-05-2007 by Sacsethi for bug 5647248
)
IS


--Date 11-05-2007 by Sacsethi for bug 5647248
-- start 5647248


  cursor c_prg_name(cp_conc_prg in number)
  is
  select concurrent_program_name
  from fnd_concurrent_programs_vl
  where concurrent_program_id= cp_conc_prg;

  l_prg_name varchar2(50);
  l_prg_id   number(15);
  l_form_number varchar2(5);

  lv_req_id   NUMBER;
  lv_result   BOOLEAN;
  lv_request_desc   VARCHAR2(200);

  v_deductor_type VARCHAR2(1);
  v_err           VARCHAR2(1);
  v_return_message VARCHAR2(240);


  Cursor c_get_state_desc
  is
  select
    description
  from FND_FLEX_VALUES_VL a
  where flex_value_set_id =
         ( select flex_value_set_id
           from fnd_flex_value_sets
           where flex_value_set_name ='JA_IN_INDIAN_STATES'
         )
  and flex_value = to_number(p_RespPersState) ;

  lv_state_desc fnd_flex_values_vl.description%TYPE ;
  ld_challan_start_date  DATE;  --added by csahoo for bug#6158875
  ld_challan_end_date		 DATE;  --added by csahoo for bug#6158875
  BEGIN

     l_prg_id:=FND_GLOBAL.CONC_PROGRAM_ID;
     ld_challan_start_date  := fnd_date.canonical_to_date(p_challan_Start_Date);  --added by csahoo for bug#6158875
		 ld_challan_end_date		 := fnd_date.canonical_to_date(p_challan_End_Date);		--added by csahoo for bug#6158875

     open c_prg_name(l_prg_id);
     fetch c_prg_name into l_prg_name;
     close c_prg_name;

     if l_prg_name='JAINETDSQ' then
        l_form_number:='26Q';
     elsif l_prg_name='JAINE27Q' then
        l_form_number:='27Q';
    end if;


    generate_etds_returns
      (p_err_buf                 =>   p_err_buf                 ,
       p_ret_code                 =>   p_ret_code                ,
       p_tan_number               =>   p_tan_number              ,
       p_fin_year                 =>   p_fin_year                ,
       p_period                   =>   p_period                  ,
       p_tax_authority_id         =>   p_tax_authority_id        ,
       p_tax_authority_site_id    =>   p_tax_authority_site_id   ,
       p_organization_id          =>   p_organization_id         ,
       p_deductor_name            =>   p_deductor_name           ,
       p_deductor_state           =>   p_deductor_state          ,
       p_addrChangedSinceLastRet  =>   p_addrChangedSinceLastRet ,
       --p_deductor_status          =>   p_deductor_status       , /*Bug 8880543 - Commented for eTDS/eTCS FVU Changes*/
       p_persRespForDeduction     =>   p_persRespForDeduction    ,
       p_desgOfPersResponsible    =>   p_desgOfPersResponsible   ,
       -- bug 6030953. Added by Lakshmi Gopalsami
       p_RespPers_flat_no         =>   p_RespPers_flat_no        ,
       p_RespPers_prem_bldg       =>   p_RespPers_prem_bldg      ,
       p_RespPers_rd_st_lane      =>   p_RespPers_rd_st_lane     ,
       p_RespPers_area_loc        =>   p_RespPers_area_loc       ,
       p_RespPers_tn_cty_dt       =>   p_RespPers_tn_cty_dt      ,
	   -- end for bug 6030953
       p_RespPersState            =>   p_RespPersState           ,
       p_RespPersPin              =>   p_RespPersPin             ,
	   -- bug 6030953. Added by Lakshmi Gopalsami
	   p_RespPers_tel_no          =>   p_RespPers_tel_no         ,
       p_RespPers_email           =>   p_RespPers_email          ,
      -- end for bug 6030953
       p_RespPersAddrChange       =>   p_RespPersAddrChange      ,
       pv_challan_Start_Date       =>   p_challan_Start_Date      ,
       pv_challan_End_Date         =>   p_challan_End_Date        ,
       p_pro_rcpt_num_org_ret     =>   p_pro_rcpt_num_org_ret    ,
       p_file_path                =>   p_file_path               ,
       p_filename                 =>   p_filename                ,
       p_action                   =>   p_action                  ,
       p_form_number              =>   l_form_number             ,
       p_include_list             =>   p_include_list            ,
       p_exclude_list             =>   p_exclude_list
      ) ;


      open c_get_state_desc ;
      fetch c_get_state_desc into lv_state_desc ;
      close c_get_state_desc ;
      /*Bug 8880543 - Start*/
      get_attr_value (p_organization_id, 'DEDUCTOR_TYPE', v_deductor_type, v_err, v_return_message);
      chk_err(v_err, v_return_message);
      /*Bug 8880543 - End*/
      lv_request_desc := 'India - TDS Form 27A for Batch Id '|| ln_batch_id; /*ln_batch_id*/

      lv_result := FND_REQUEST.set_mode(true);
      lv_req_id := FND_REQUEST.submit_request(
                      'JA', 'JAINTDSA', lv_request_desc, '', FALSE,
                      --p_legal_entity_id,         --Legal Entity Id  --commented by csahoo for bug#6158875
                      --p_profile_org_id,          --Operating Unit  --commented by csahoo for bug#6158875
                      p_tan_number,              --Org Tan Num
                      p_organization_id,         --Organization Id
                      p_fin_year,                --Fin Year
                      p_period,                  --Quarter
                      p_tax_authority_id,        --Tax Authority
                      p_tax_authority_site_id,   --Tax Authority Site
                      l_form_number,             --Form Number
                      p_pro_rcpt_num_org_ret,    --Previous Receipt Number
					  -- Bug 6030953. Added by Lakshmi Gopalsami
		              v_deductor_type  ,         -- Type of deductor. /*Bug 8880543 - Fetch deductor and pass the same as it is not a parameter*/
                      p_persRespForDeduction,    --Person Responsible
                      p_desgOfPersResponsible,   --Responsible person Designation
                       -- bug 6030953. Added by Lakshmi Gopalsami
                      p_RespPers_flat_no,         -- Responsible person Flat No.
		              p_RespPers_prem_bldg,       -- Name of premises/Bldg
		              p_RespPers_rd_st_lane,      -- Road/Street/Lane
		              p_RespPers_area_loc,        -- Area/Location
		              p_RespPers_tn_cty_dt,       -- Town/city/District
                      lv_state_desc,              -- Responsible person State
                      p_RespPersPin,              -- Responsible Person Pin
		              p_RespPers_tel_no,          -- Telephone number
		              p_RespPers_email,           -- Email
		             -- end for bug 6030953
                     p_challan_Start_Date,		--MODIFIED BY CSAHOO FOR BUG#6158875
                     p_challan_End_Date,			--MODIFIED BY CSAHOO FOR BUG#6158875
                      CHR(0), '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', ''
                  );




END quarterly_returns;

PROCEDURE yearly_returns(
  p_err_buf OUT NOCOPY VARCHAR2,
  p_ret_code OUT NOCOPY NUMBER,
  --p_legal_entity_id   IN NUMBER,   --commented by csahoo for bug#6158875
  --p_profile_org_id    IN NUMBER,   --commented by csahoo for bug#6158875
  p_tan_number      IN VARCHAR2,
  p_fin_year        IN NUMBER,
  p_organization_id   IN NUMBER,
  p_tax_authority_id    IN NUMBER,
  p_tax_authority_site_id IN NUMBER,
  p_deductor_name     IN VARCHAR2,
  p_deductor_state    IN VARCHAR2,
  p_addrChangedSinceLastRet IN VARCHAR2,
  p_deductor_status   IN VARCHAR2,
  p_persRespForDeduction  IN VARCHAR2,
  p_desgOfPersResponsible IN VARCHAR2,
  p_challan_Start_Date  IN VARCHAR2,
  p_challan_End_Date    IN VARCHAR2,
  --p_pro_rcpt_num_org_ret IN NUMBER, --commented by csahoo for bug#6158875
  p_file_path       IN VARCHAR2,
  p_filename        IN VARCHAR2,
  p_generate_headers    IN VARCHAR2 DEFAULT NULL
)
IS
ld_challan_start_date   DATE;
ld_challan_end_date     DATE;
BEGIN

ld_challan_start_date  := fnd_date.canonical_to_date(p_challan_Start_Date);  --added by csahoo for bug#6158875
ld_challan_end_date		 := fnd_date.canonical_to_date(p_challan_End_Date);		--added by csahoo for bug#6158875
 generate_etds_returns
     (
       p_err_buf                  =>   p_err_buf                 ,
       p_ret_code                 =>   p_ret_code                ,
       p_tan_number               =>   p_tan_number              ,
       p_fin_year                 =>   p_fin_year                ,
       p_tax_authority_id         =>   p_tax_authority_id        ,
       p_tax_authority_site_id    =>   p_tax_authority_site_id   ,
       p_organization_id          =>   p_organization_id         ,
       p_deductor_name            =>   p_deductor_name           ,
       p_deductor_state           =>   p_deductor_state          ,
       p_addrChangedSinceLastRet  =>   p_addrChangedSinceLastRet ,
       --p_deductor_status          =>   p_deductor_status       , /*Bug 8880543 - Commented for eTDS/eTCS FVU Changes*/
       p_persRespForDeduction     =>   p_persRespForDeduction    ,
       p_desgOfPersResponsible    =>   p_desgOfPersResponsible   ,
       pv_challan_Start_Date       =>   p_challan_Start_Date      ,
       pv_challan_End_Date         =>   p_challan_End_Date        ,
       p_pro_rcpt_num_org_ret     =>   NULL    ,   --modified by csahoo for bug#6158875
       p_file_path                =>   p_file_path               ,
       p_filename                 =>   p_filename                ,
       p_generate_headers         =>   p_generate_headers
    ) ;


END yearly_returns;
-- ended, Harshita for Bug 4525089




PROCEDURE generate_etds_returns
(
    p_err_buf OUT NOCOPY VARCHAR2,
    p_ret_code OUT NOCOPY NUMBER,
    p_tan_number      IN VARCHAR2,
    p_fin_year        IN NUMBER,
    p_organization_id   IN NUMBER, -- Harshita for Bug 4889272
    p_tax_authority_id    IN NUMBER,
    p_tax_authority_site_id IN NUMBER,
    p_deductor_name     IN VARCHAR2,
    p_deductor_state    IN VARCHAR2,
    p_addrChangedSinceLastRet IN VARCHAR2,
    --p_deductor_status   IN VARCHAR2, /*Bug 8880543 - Commented for eTDS/eTCS FVU Changes*/
    p_persRespForDeduction  IN VARCHAR2,
    p_desgOfPersResponsible IN VARCHAR2,
    pv_challan_Start_Date  IN VARCHAR2, /* rallamse for bu# 4334682 changed to varchar2 from date */
    pv_challan_End_Date    IN VARCHAR2, /* rallamse for bu# 4334682 changed to varchar2 from date */
    p_pro_rcpt_num_org_ret IN NUMBER,
    p_file_path       IN VARCHAR2,
    p_filename        IN VARCHAR2,
    p_generate_headers    IN VARCHAR2 DEFAULT NULL,
    p_period               IN VARCHAR2 DEFAULT NULL,
    p_RespPers_flat_no IN VARCHAR2 DEFAULT NULL, -- Bug 6030953
    p_RespPers_prem_bldg IN VARCHAR2 DEFAULT NULL, -- Bug 6030953
    p_RespPers_rd_st_lane IN VARCHAR2 DEFAULT NULL, -- Bug 6030953
    p_RespPers_area_loc IN VARCHAR2 DEFAULT NULL, -- Bug 6030953
    p_RespPers_tn_cty_dt IN VARCHAR2 DEFAULT NULL, -- Bug 6030953
    p_RespPersState        IN VARCHAR2 DEFAULT NULL,
    p_RespPersPin          IN NUMBER   DEFAULT NULL,
    p_RespPers_tel_no IN VARCHAR2 DEFAULT NULL, -- Bug 6030953
    p_RespPers_email IN VARCHAR2 DEFAULT NULL, -- Bug 6030953
    p_RespPersAddrChange   IN VARCHAR2 DEFAULT NULL,
    p_action               IN VARCHAR2 DEFAULT NULL,
    p_form_number          IN VARCHAR2 DEFAULT NULL,     --Date 11-05-2007 by Sacsethi for bug 5647248
    p_include_list         IN VARCHAR2 DEFAULT NULL,
    p_exclude_list         IN VARCHAR2 DEFAULT NULL

)IS

    lv_object_name  VARCHAR2(61); -- := '<Package_name>.<procedure_name>'; /* Added by Ramananda for bug#4407165 */
    lv_oth_reg_type  CONSTANT VARCHAR2(30) := 'OTHERS';
    lv_prim_att_type CONSTANT VARCHAR2(30) := 'OTHERS' ; -- 'PRIMARY'; -- Harshita for Bug 4889272
    lv_pan_att_code  CONSTANT VARCHAR2(30) := 'PAN NO';

    /* rallamse for bug# 4336482 */
    p_challan_Start_Date  DATE; --File.Sql.35 Cbabu  DEFAULT fnd_date.canonical_to_date(pv_challan_Start_Date);
    p_challan_End_Date    DATE; --File.Sql.35 Cbabu  DEFAULT fnd_date.canonical_to_date(pv_challan_End_Date);

    -- to get financial and assessment years
    CURSOR c_fin_year(p_tan_number /*p_legal_entity_id*/ IN VARCHAR2, p_fin_year IN NUMBER, p_organization_id IN NUMBER ) IS
      SELECT start_date, end_date
      FROM JAI_AP_TDS_YEARS
      -- added, Harshita for Bug 4889272
      where TAN_NO = p_tan_number
      AND fin_year = p_fin_year
      and legal_entity_id = p_organization_id;

      -- commented, Harshita for Bug 4889272
      /*
      WHERE legal_entity_id = p_legal_entity_id
      AND fin_year = p_fin_year;
      */

    -- to get Organization related to TAN
    CURSOR c_organization_id(p_tan_number IN VARCHAR2) IS
      SELECT organization_id
      FROM jai_ap_tds_org_tan_v        ---  JAI_AP_TDS_ORG_TANS is changed to view jai_ap_tds_org_tan_v  4323338
      WHERE org_tan_num = p_tan_number;

    -- to get PAN related to TAN
    /*Modified the below cursor by Bgowrava for Bug#9494515*/
    CURSOR c_pan_number(p_organization_id IN NUMBER) IS  --Harshita for bug#4889272
    SELECT attribute_value ORG_TAN_NUM
    FROM jai_rgm_org_regns_v
    WHERE
      regime_code = 'TDS'
      AND organization_id     = p_organization_id
      AND registration_type   = lv_oth_reg_type
      AND attribute_type_code = lv_prim_att_type
      AND attribute_code      = lv_pan_att_code;


    -- Cursor to check whether the organization is an Operating Unit
    -- commented by ssumaith - bug# 4448789
    /*
      CURSOR c_ou_check(p_organization_id IN NUMBER) IS
      SELECT organization_id, to_number(legal_entity_id)
      FROM hr_operating_units
      WHERE organization_id = p_organization_id;
    */
    -- Cursor to check whether the organization is Legal Entity
    CURSOR c_le_check(p_organization_id IN NUMBER) IS
      SELECT 1
      FROM hr_legal_entities
      WHERE organization_id = p_organization_id;

    -- gives Location_id linked to Organization
    CURSOR c_location_linked_to_org(p_organization_id IN NUMBER) IS
      SELECT location_id
      FROM hr_all_organization_units
      WHERE organization_id = p_organization_id;

    -- to get address details of location linked to given organization
    CURSOR c_address_details(p_location_id IN NUMBER) IS
    SELECT location_code, address_line_1, address_line_2, address_line_3, null, null,
           REPLACE(postal_code, ' ') postal_code
      FROM hr_locations_all
     WHERE location_id = p_location_id;

    -- gives the Deductee code based on Vendor Classification
    CURSOR c_deductee_dtls(p_vendor_id IN NUMBER) IS
    SELECT vendor_name,
           decode( UPPER(organization_type_lookup_code), 'COMPANY', '01', '02')
      FROM po_vendors
     WHERE vendor_id = p_vendor_id;

    -- gives the Deductee code based on Vendor Classification
    CURSOR c_deductee_site_dtls(p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER) IS
    SELECT address_line1 addr1, address_line2 addr2, address_line3 addr3, address_line4 addr4, city,
           UPPER(state) state, REPLACE(zip,' ') zip   --Removed to_number for Bug 6281440
      FROM po_vendor_sites_all
     WHERE vendor_id = p_vendor_id
       AND vendor_site_id = p_vendor_site_id;

    v_deductee_state_code NUMBER;
    CURSOR c_state_code(p_state_name IN VARCHAR2,p_state_type IN VARCHAR2) IS
    SELECT meaning
      FROM ja_lookups --fnd_common_lookups  /* Ramananda for bug#4555466 */
     WHERE lookup_type = p_state_type
       AND lookup_code = p_state_name;

    CURSOR c_deductee_pan(p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER) IS
    SELECT pan_no
      FROM JAI_AP_TDS_VENDOR_HDRS
     WHERE vendor_id = p_vendor_id
       AND vendor_site_id = p_vendor_site_id;

    CURSOR c_check_dtls(p_check_id IN NUMBER) IS
    SELECT check_date
      FROM ap_checks_all
     WHERE check_id = p_check_id;

   CURSOR c_cert_issue_date(p_tds_invoice_id IN NUMBER) IS
    SELECT a.issue_date
    FROM JAI_AP_TDS_F16_HDRS_ALL a, JAI_AP_TDS_F16_DTLS_ALL b
    WHERE a.CERTIFICATE_NUM = b.CERTIFICATE_NUM
    AND a.org_tan_num = b.org_tan_num
    AND a.fin_yr = b.fin_yr
    AND b.tds_invoice_id = p_tds_invoice_id;


    /* CURSOR c_challan_records(p_batch_id IN NUMBER) IS
      select *
      from JAI_AP_ETDS_T a
      where a.batch_id = p_batch_id
      and a.consider_for_challan=1
      FOR UPDATE OF challan_line_num;

      bug#3708878 above cursor definition replaced by the definition below
    */

    lv_dummy_date                DATE;

   /* CURSOR c_challan_records(p_batch_id IN NUMBER) IS
      SELECT tds_section, bank_branch_code, challan_num, challan_date, sum(tds_amount) tds_amount
      FROM   JAI_AP_ETDS_T a
      WHERE  a.batch_id = p_batch_id
      AND    a.consider_for_challan=1
      GROUP BY tds_section, bank_branch_code, challan_num, challan_date;*/

      CURSOR c_challan_records(p_batch_id IN NUMBER) IS
            select NVL(tds_section,'No Section') tds_section,
                   NVL(bank_branch_code,'No Bank Branch') bank_branch_code,
                   NVL(challan_num,'No Challan Number') challan_num,
                   NVL(challan_date,lv_dummy_date) challan_date,
                   check_number check_number,
                   sum(tds_amount) tds_amount,
                   sum(amt_of_tds) amt_of_tds,
                   sum(amt_of_surcharge) amt_of_surcharge,
                   sum(amt_of_cess) amt_of_cess
            from   JAI_AP_ETDS_T a
            where a.batch_id = p_batch_id
            and a.consider_for_challan=1
            group by NVL(tds_section,'No Section'), NVL(bank_branch_code,'No Bank Branch'),
                     NVL(challan_num,'No Challan Number'), NVL(challan_date,lv_dummy_date),
                     check_number;
    cd c_challan_records%ROWTYPE ;


    /*CURSOR c_deductee_records(p_batch_id IN NUMBER) IS
      SELECT *
      FROM JAI_AP_ETDS_T a
      WHERE a.batch_id = p_batch_id
      AND a.consider_for_challan=1
      FOR UPDATE OF deductee_line_num;*/

    CURSOR c_deductee_records(p_batch_id IN NUMBER, p_challan_line_num IN NUMBER) IS
      select
          base_vendor_id,challan_line_num, base_vendor_site_id,tds_tax_id,
          NVL(tds_section,'No Section') tds_section,
          NVL(bank_branch_code,'No Bank Branch') bank_branch_code,
          NVL(challan_num,'No Challan Number') challan_num,
          NVL(challan_date,lv_dummy_date) challan_date,
          check_number,
          tds_tax_rate,
          max(certificate_issue_date) certificate_issue_date,
          max( base_invoice_date) base_invoice_date ,
          max(tds_check_date) tds_check_date,
          max(tds_invoice_date) tds_invoice_date,
          sum(amt_of_tds) amt_of_tds,
          sum(amt_of_surcharge) amt_of_surcharge,
          sum(amt_of_cess) amt_of_cess,
          sum(base_taxabale_amount) base_taxabale_amount,
          sum(tds_amount) tds_amount
      from JAI_AP_ETDS_T a
      where a.batch_id = p_batch_id
          and a.consider_for_challan=1
          and challan_line_num = NVL(p_challan_line_num, challan_line_num)
      group by challan_line_num, base_vendor_id, base_vendor_site_id,tds_tax_id,
          NVL(tds_section,'No Section'), NVL(bank_branch_code,'No Bank Branch'),
          NVL(challan_num,'No Challan Number'), NVL(challan_date,lv_dummy_date),
          check_number,tds_tax_rate
      having sum(amt_of_tds) > 0;
      /*Bug 8505050 - Added the having clause to prevent entries in e-TDS file with 0 Tax amount*/

      dd c_deductee_records%ROWTYPE ;

    CURSOR c_base_inv_gl_date(p_invoice_id IN NUMBER, p_tax_id IN NUMBER,p_line_type ap_invoice_distributions_all.line_type_lookup_code%type) IS
      SELECT accounting_date
      FROM ap_invoice_distributions_all
      WHERE invoice_id = p_invoice_id
      AND line_type_lookup_code = p_line_type
      AND global_attribute1 = to_char(p_tax_id);--rchandan for bug#4333488

    CURSOR c_stform_type(p_tax_id IN NUMBER) IS
      SELECT stform_type
      FROM JAI_CMN_TAXES_ALL
      WHERE tax_id = p_tax_id;
   /*
    CURSOR c_deductee_cnt(p_batch_id IN NUMBER , p_check_number IN NUMBER ) IS
            select sum ( count(  base_vendor_id ) )  -- distinct removed the distinct
            from JAI_AP_ETDS_T
            WHERE  batch_id = p_batch_id
            and    nvl(tds_section, 'No Section') = nvl(cd.tds_section, 'No Section')
            and    nvl(challan_num,'No Challan Number') = nvl(cd.challan_num, 'No Challan Number')
            and    nvl(challan_date, lv_dummy_date) = nvl(cd.challan_date, lv_dummy_date )
            and    nvl(bank_branch_code, 'No Bank Branch') = nvl(cd.bank_branch_code, 'No Bank Branch')
            and    consider_for_challan=1
            and    check_number = p_check_number
        group  by  base_vendor_id, base_vendor_site_id,tds_tax_id ;
   */

   /*ADDED BY CSAHOO FOR BUG#6158875*/
   CURSOR c_deductee_cnt(p_batch_id IN NUMBER ,
   											 p_check_number IN NUMBER,
        								 p_tds_section IN VARCHAR2 ,
        								 p_challan_num IN varchar2,
        								 p_challan_date IN DATE,
        								 p_bank_branch_code IN VARCHAR2) IS
   select sum ( count(  distinct base_vendor_id ) )
   from JAI_AP_ETDS_T
	            WHERE  batch_id = p_batch_id
	             and    nvl(tds_section, 'No Section') = nvl(p_tds_section, 'No Section')
	            and    nvl(challan_num,'No Challan Number') = nvl(p_challan_num, 'No Challan Number')
	             and    nvl(challan_date, lv_dummy_date) = nvl(p_challan_date, lv_dummy_date )
	            and    nvl(bank_branch_code, 'No Bank Branch') = nvl(p_bank_branch_code, 'No Bank Branch')
	             and    consider_for_challan=1
	             and    check_number = p_check_number
        group  by  base_vendor_id, base_vendor_site_id,tds_tax_id ;


    CURSOR c_get_errors(cp_batch_id JAI_AP_ETDS_T.batch_id%TYPE ) IS
           Select Error_Message from jai_ap_etds_errors_t
   where batch_id = cp_batch_id ;

    -- File Header Variables
    v_line_number NUMBER(6); --File.Sql.35 Cbabu  := 0;
    v_record_type VARCHAR2(2);
    v_file_type   VARCHAR2(3) ; --:= 'TDS'      File.Sql.35 by Brathod
    v_quartfile_type   CHAR(3);
    v_upload_type VARCHAR2(1) ; --:= 'R'        File.Sql.35 by Brathod
    v_file_creation_date  Date; -- := SYSDATE   File.Sql.35 by Brathod
    v_file_sequence_number  NUMBER(8);
    v_deductor_tan      VARCHAR2(20);
    v_number_of_batches   NUMBER(4);    --File.Sql.35 Cbabu  := 1;
    v_return_prep_util  VARCHAR2(75);   /*Bug 8880543*/
    v_check_number      NUMBER; /*Bug 8880543*/

    -- Batch Header Variables
    v_batch_number  NUMBER(4);
    v_challan_cnt NUMBER(5);    --File.Sql.35 Cbabu  := 0;
    v_deductee_cnt  NUMBER(5); --File.Sql.35 Cbabu  := 0;
    v_form_number CHAR(4);
    v_rrr_number  NUMBER(10);
    v_rrr_date    CHAR(8);
    v_deductor_pan  VARCHAR2(200);

    v_quart_form_number VARCHAR2(3) ;
    v_deductor_branch VARCHAR2(75);
    v_deductor_email    VARCHAR2(75);
    v_deductor_stdCode      NUMBER(5);
    v_deductor_phoneNo NUMBER(10);
    v_RespPerson_address2  VARCHAR2(25);
    v_RespPerson_address3  VARCHAR2(25);
    v_RespPerson_address4  VARCHAR2(25);
    v_RespPerson_address5  VARCHAR2(25);
    v_RespPerson_email     VARCHAR2(75);
    v_RespPerson_remark    VARCHAR2(75);
    v_RespPerson_stdCode   INTEGER(5)  ;
    v_RespPerson_phoneNo   INTEGER(10) ;
    v_RespPerson_addressChange   VARCHAR2(1);
    v_bh_trnType  VARCHAR2(1) ;
    v_bh_batchUpd  VARCHAR2(1)  ;
    v_bh_org_RRRno  VARCHAR2(1)  ;
    v_bh_prev_RRRno  VARCHAR2(1) ;
    v_bh_RRRno  VARCHAR2(1) ;
    v_bh_RRRdate                       VARCHAR2(1)  ;
    v_bh_deductor_last_tan             VARCHAR2(1)  ;
    v_bh_tds_circle                    VARCHAR2(1)  ;
    v_bh_salaryRecords_count           VARCHAR2(1)  ;
    v_bh_gross_total                   VARCHAR2(1)  ;
    v_ao_approval                      VARCHAR2(1)  ;
    v_ao_approval_number               VARCHAR2(15);
    /*Bug 8880543 - Start*/
    v_last_deductor_type               VARCHAR2(1)  ;
    v_state_name                       VARCHAR2(2)  ;
    v_pao_code                         VARCHAR2(20) ;
    v_ddo_code                         VARCHAR2(20) ;
    v_ministry_name                    VARCHAR2(3)  ;
    v_ministry_name_other              VARCHAR2(150);
    v_pao_registration_no              NUMBER(10)   ;
    v_ddo_registration_no              VARCHAR2(10) ;
    v_challan_number                   VARCHAR2(10) ;
    v_return_message                   VARCHAR2(240);
    v_err                              VARCHAR2(1)  ;
    /*Bug 8880543 - End*/
    v_bh_recHash                       VARCHAR2(1)  ;


    -- Input Variables
    v_tds_vendor_id NUMBER;

    v_fin_year VARCHAR2(4);
    v_address_organization_id NUMBER;
    v_deductor_name VARCHAR2(75);
    v_tan_state_code NUMBER(2);
    v_addrChangedSinceLastReturn VARCHAR2(1);
    v_deductor_type VARCHAR2(1);      /*Bug 8880543 - Modified Deductor Status to Deductor Type*/
    v_personNameRespForDedection VARCHAR2(75);
    v_personDesgnRespForDedection VARCHAR2(20);
    v_challan_start_date DATE;
    v_challan_end_date DATE;

    -- Derived variables
    -- v_tan_org_id NUMBER;
    v_org_id  NUMBER;
    v_financial_year VARCHAR2(6);
    v_assessment_year VARCHAR2(6);
    --v_legal_entity_id NUMBER;  -- Harshita for Bug 4889272
    v_location_id NUMBER;
    v_tan_pin     NUMBER(6);
    v_quarterlyOrYearly VARCHAR2(2); -- := 'Y';   -- as given by Vikram File.Sql.35 by Brathod

    -- added location_code and modified the types of address variables to refer table column types by Vijay Shankar for Bug#4057192
    v_location_code   HR_LOCATIONS_ALL.location_code%TYPE;
    v_tan_address1    HR_LOCATIONS_ALL.address_line_1%TYPE;
    v_tan_address2    HR_LOCATIONS_ALL.address_line_2%TYPE;
    v_tan_address3    HR_LOCATIONS_ALL.address_line_3%TYPE;
    v_tan_address4    VARCHAR2(75);
    v_tan_address5    VARCHAR2(75);
    v_postal_code     HR_LOCATIONS_ALL.postal_code%TYPE;
    v_totTaxDeductedAsPerChallan NUMBER;
    v_totTaxDeductedAsPerDeductee NUMBER;

    v_challan_dtl_slno NUMBER;  --File.Sql.35 Cbabu  := 0;
    v_bank_branch_code VARCHAR2(7) ;

    v_deductee_slno NUMBER; --File.Sql.35 Cbabu  := 0;
    v_deductee_code VARCHAR2(2);
    v_deductee_pan  VARCHAR2(20);
    v_stform_name VARCHAR2(25);
    v_vendor_name PO_VENDORS.vendor_name%TYPE;
    v_site_dtls   c_deductee_site_dtls%ROWTYPE;
    v_base_inv_check_dtls c_check_dtls%ROWTYPE;
    v_tds_inv_check_dtls  c_check_dtls%ROWTYPE;
    v_cert_issue_date   DATE;
    v_grossing_up_factor  VARCHAR2(1);
    v_reason_for_nDeduction VARCHAR2(1);
    v_filler        NUMBER(14);

    v_gl_date DATE;
    v_batch_id  NUMBER;

    v_ch_updIndicator         VARCHAR2(1)   ;
    v_filler1                 VARCHAR2(1)   ;
    v_filler2                 VARCHAR2(1)   ;
    v_filler3                 VARCHAR2(1)   ;
    v_filler4                 VARCHAR2(1)   ;
    v_last_bank_challan_no    VARCHAR2(1)   ;
    v_bank_challan_no         NUMBER(5) ;
    v_last_transfer_voucher_no VARCHAR2(1)   ;
    v_transfer_voucher_no     NUMBER(9) ;
    v_last_bank_branch_code   VARCHAR2(1)   ;
    v_challan_lastDate        VARCHAR2(1)   ;
    v_challan_Date        DATE ;
    v_filler5                 VARCHAR2(1)   ;
    v_filler6                 VARCHAR2(1)   ;
    v_last_total_depositAmt   VARCHAR2(1)   ;

    v_total_deposit           NUMBER(15,2) ;
    v_book_entry              VARCHAR2(1) ;
    v_ch_recHash              VARCHAR2(1)   ;
    v_nil_challan_indicator   VARCHAR2(1)   ;
    v_remarks                 VARCHAR2(14) ;
    v_remarks2               VARCHAR2(75);
    v_remarks3               VARCHAR2(14);


    v_quart_deductee_code        VARCHAR2(1) ;
    v_deductee_pan_refno         NUMBER(10);
    v_dh_mode                    VARCHAR2(1) ;
    v_emp_serial_no              VARCHAR2(1)   ;
    v_last_emp_pan               VARCHAR2(1)   ;
    v_last_emp_pan_refno         VARCHAR2(1)   ;
    v_deductee_total_tax_deducted NUMBER(15,2) ;
    v_last_total_tax_deducted    VARCHAR2(1)   ;
    v_deductee_total_tax_deposit NUMBER(15);
    v_last_total_tax_deposit     VARCHAR2(1)   ;
    v_total_purchase             VARCHAR2(1)   ;
    v_deposit_date               VARCHAR2(1)   ;
    v_grossingUp_ind             VARCHAR2(1)   ;
    v_certificate_issue_date     VARCHAR2(1)   ;  -- another declaration exists.
    v_dh_recHash                 VARCHAR2(1)   ;
    lv_etds_yearly_returns       VARCHAR2(1) ;
    v_challan_line_num           NUMBER ;
    ln_amt_of_tds                NUMBER(15,2) ;
        --v_tds_tax_rate               NUMBER(7);
    -- ended, Harshita for Bug 4525089

    v_ack_num_tan_app NUMBER(14);
    v_pro_rcpt_num_org_ret NUMBER(14);
    v_book_ent_oth VARCHAR2(1);
    v_quart_book_ent_oth VARCHAR2(1); -- Harshita for Bug 4525089,
    ln_amt_of_oth number(14);

    -- used variables
    --v_vendor_name PO_VENDORS.vendor_name%TYPE;
    v_vendor_site_code  PO_VENDOR_SITES_ALL.vendor_site_code%TYPE;
    v_error_message VARCHAR2(100);
    v_conc_request_id NUMBER(15); -- := FND_PROFILE.value('CONC_REQUEST_ID'); File.Sql.35 by Brathod
    v_statement_id VARCHAR2(3) ; --:= '0';  File.Sql.35 by Brathod

    v_start_date DATE;
    v_end_date DATE;

    v_uploader_type CHAR(1)      ;
    p_return_code    VARCHAR2(1) ;
    p_return_message VARCHAR2(2000) ;
    lv_generate_headers VARCHAR2(1) ;
    ln_errors_exist    NUMBER  ;
    DUMMY            VARCHAR2(1) ;
    v_fh_recordHash  VARCHAR2(1) ;
    v_fh_fvuVersion  VARCHAR2(1) ;
    v_fh_fileHash    VARCHAR2(1) ;
    v_fh_samVersion  VARCHAR2(1) ;
    v_fh_samHash     VARCHAR2(1) ;
    v_fh_scmVersion  VARCHAR2(1) ;
    v_fh_scmHash     VARCHAR2(1) ;
    v_q_deductee_cnt NUMBER(9) ;


    PROCEDURE process_deductee_records
    IS
    BEGIN
      /*START, Bgowrava for Bug#7662155*/
      IF c_deductee_records%ISOPEN THEN
       CLOSE c_deductee_records ;
      END IF;
      /*END, Bgowrava for Bug#7662155*/
      OPEN c_deductee_records(v_batch_id, v_challan_line_num) ;
      LOOP
      FETCH c_deductee_records INTO dd ;
      EXIT WHEN
      c_deductee_records%NOTFOUND ;

      v_vendor_name := null;
      v_deductee_code := null;
      v_deductee_pan := null;
      v_site_dtls := null;
      --v_tds_inv_check_dtls := null;
      --v_base_inv_check_dtls := null;
      v_reason_for_nDeduction := null;
      v_filler := null;
      v_deductee_state_code := null;
      --v_gl_date := null;
      v_reason_for_nDeduction := null;
      v_stform_name :=null;
      --v_tds_tax_rate := null;

      v_line_number := v_line_number + 1;
      v_deductee_slno := v_deductee_slno + 1;

      OPEN c_deductee_dtls(dd.base_vendor_id);
      FETCH c_deductee_dtls INTO v_vendor_name, v_deductee_code;
      CLOSE c_deductee_dtls;

      OPEN c_deductee_pan(dd.base_vendor_id, dd.base_vendor_site_id);
      FETCH c_deductee_pan INTO v_deductee_pan;
      CLOSE c_deductee_pan;

      -- START code added for Bug#3841751 as PAN # was not printed, if it setup only at null site
      IF v_deductee_pan IS NULL THEN
       OPEN c_deductee_pan(dd.base_vendor_id, 0);
       FETCH c_deductee_pan INTO v_deductee_pan;
       CLOSE c_deductee_pan;
      END IF;
      -- END code added for Bug#3841751

      OPEN c_deductee_site_dtls(dd.base_vendor_id, dd.base_vendor_site_id);
      FETCH c_deductee_site_dtls INTO v_site_dtls;
      CLOSE c_deductee_site_dtls;

      OPEN c_state_code(v_site_dtls.state,'IN_STATE');
      FETCH c_state_code INTO v_deductee_state_code;
      CLOSE c_state_code;

      IF v_deductee_state_code IS NULL THEN
        v_deductee_state_code := 99;
      END IF;

      -- v_reason_for_nDeduction := 'A';
      OPEN c_stform_type(dd.tds_tax_id);
      FETCH c_stform_type INTO v_stform_name; --, v_tds_tax_rate;
      CLOSE c_stform_type;

      IF v_stform_name = '197' THEN
       v_reason_for_nDeduction := 'A';
      ELSIF v_stform_name = '197A' THEN
       v_reason_for_nDeduction := 'B';
      ELSE
       v_reason_for_nDeduction := null;
      END IF;

      v_book_ent_oth := 'C';

      IF lv_etds_yearly_returns = 'Y' THEN -- Harshita for Bug 4525089
       jai_ap_tds_etds_pkg.create_deductee_detail
       (
          p_line_number         =>   v_line_number,
          p_record_type         =>   v_record_type,
          p_batch_number        =>   v_batch_number,
          p_deductee_slno       =>   v_deductee_slno,
          p_deductee_section    =>   dd.tds_section,
          p_deductee_code       =>   v_deductee_code,
          p_deductee_pan        =>   v_deductee_pan,
          p_deductee_name       =>   v_vendor_name,
          p_deductee_address1   =>   v_site_dtls.addr1,
          p_deductee_address2   =>   v_site_dtls.addr2,
          p_deductee_address3   =>   v_site_dtls.addr3,
          p_deductee_address4   =>   v_site_dtls.addr4,
          p_deductee_address5   =>   v_site_dtls.city,
          p_deductee_state      =>   v_deductee_state_code,
          p_deductee_pin        =>   v_site_dtls.zip,
          p_filler5             =>   v_filler,
          p_payment_amount      =>   dd.base_taxabale_amount,
          p_payment_date        =>   dd.base_invoice_date, /*Changed challan_date to base_invoice_date - Forward Port Bug 6329774*/
          p_book_ent_oth        =>   v_book_ent_oth,
          p_tax_rate            =>   dd.tds_tax_rate,
          p_filler6             =>   v_filler6,
          p_tax_deducted        =>   dd.tds_amount,
          p_tax_deducted_date   =>   dd.tds_invoice_date,
          p_tax_payment_date    =>   dd.tds_check_date,
          p_bank_branch_code    =>   dd.bank_branch_code,
          p_challan_no            =>   dd.challan_num,
          p_tds_certificate_date  =>   dd.certificate_issue_date,
          p_reason_for_nDeduction =>   v_reason_for_nDeduction,
          p_filler7               =>   v_filler

       );
      ELSE
       IF v_deductee_code = '01' THEN
         v_quart_deductee_code := '1' ;
       ELSIF v_deductee_code = '02' THEN
         v_quart_deductee_code := '2' ;
       END IF ;

       v_deductee_total_tax_deducted := dd.amt_of_tds + dd.amt_of_surcharge + dd.amt_of_cess ;
       v_quart_book_ent_oth := 'N' ;

      p_return_code    := null ;
      p_return_message := null ;

      jai_ap_tds_etds_pkg.validate_deductee_detail
       ( p_line_number                   => v_line_number  ,
         p_record_type                   => v_record_type  ,
         p_batch_number                  => v_batch_number ,
         p_challan_line_num              => dd.challan_line_num   ,
         p_deductee_slno                 => v_deductee_slno  ,
         p_dh_mode                       => v_dh_mode  ,
         p_quart_deductee_code           => v_quart_deductee_code  ,
         p_deductee_pan                  => v_deductee_pan ,
         p_vendor_name                   => v_vendor_name  ,
         p_amt_of_tds                    => dd.amt_of_tds  ,
         p_amt_of_surcharge              => dd.amt_of_surcharge   ,
         p_amt_of_cess                   => dd.amt_of_cess   ,
         p_deductee_total_tax_deducted   => v_deductee_total_tax_deducted,
         p_base_taxabale_amount          => dd.base_taxabale_amount ,
         p_gl_date                       => dd.base_invoice_date  ,  /*Changed challan_date to base_invoice_date - Forward Port Bug 6329774*/
         p_book_ent_oth                  => v_book_ent_oth,
         p_return_code                   => p_return_code,
         p_return_message                => p_return_message
       );
      IF p_return_code = 'E' THEN
       IF lv_action = 'V' THEN
        insert into jai_ap_etds_errors_t
         (batch_id, record_type,  reference_id, error_message) values
        ( v_batch_id,'DD', v_line_number, p_return_message ) ; /*Bug 8880543 - Modified ln_batch_id to v_batch_id*/
       ELSE
        p_ret_code := jai_constants.request_error ;
        p_err_buf := p_return_message ;
        RETURN ;
       END IF ;
      END IF ;
    lv_generate_headers := null ;
      IF p_action <> 'V' THEN
       IF p_action = 'F' THEN
         lv_generate_headers := 'N' ;
       ELSIF p_action = 'H' THEN
         lv_generate_headers := 'Y' ;
       END IF ;

       jai_ap_tds_etds_pkg.create_quart_deductee_dtl
       (
         p_line_number                   => v_line_number,
         p_record_type                   => v_record_type,
         p_batch_number                  => v_batch_number,
         p_dh_challan_recNo              => v_challan_dtl_slno,
         p_deductee_slno                 => v_deductee_slno,
         p_dh_mode                       => v_dh_mode,
         p_emp_serial_no                 => v_emp_serial_no,
         p_deductee_code                 => v_quart_deductee_code,
         p_last_emp_pan                  => v_last_emp_pan,
         p_deductee_pan                  => v_deductee_pan,
         p_last_emp_pan_refno            => v_last_emp_pan_refno,
         p_deductee_pan_refno            => v_deductee_pan_refno,
         p_vendor_name                   => v_vendor_name,
         p_deductee_tds_income_tax       => dd.amt_of_tds ,
         p_deductee_tds_surcharge        => dd.amt_of_surcharge,
         p_deductee_tds_cess             => dd.amt_of_cess,
         p_deductee_total_tax_deducted   => v_deductee_total_tax_deducted,
         p_last_total_tax_deducted       => v_last_total_tax_deducted,
         p_deductee_total_tax_deposit    => v_deductee_total_tax_deducted,
         p_last_total_tax_deposit        => v_last_total_tax_deposit,
         p_total_purchase                => v_total_purchase,
         p_base_taxabale_amount          => dd.base_taxabale_amount,
         p_gl_date                       => dd.base_invoice_date,   /*Changed challan_date to base_invoice_date - Forward Port Bug 6329774*/
         p_tds_invoice_date              => dd.tds_invoice_date,
         p_deposit_date                  => v_deposit_date,
         p_tds_tax_rate                  => dd.tds_tax_rate, --v_tds_tax_rate,
         p_grossingUp_ind                => v_grossingUp_ind,
         p_book_ent_oth                  => v_quart_book_ent_oth,
         p_certificate_issue_date        => v_certificate_issue_date,
         p_remarks1                      => v_reason_for_nDeduction, -- VIJAY REVIEW v_remarks1,
         p_remarks2                      => v_remarks2,
         p_remarks3                      => v_remarks3,
         p_dh_recHash                    => v_dh_recHash,
         p_generate_headers              => lv_generate_headers
        );

        END IF ;

      END IF ;

      UPDATE JAI_AP_ETDS_T
      SET deductee_line_num = v_line_number
      WHERE batch_id = v_batch_id
       and consider_for_challan=1
       and challan_line_num                          = dd.challan_line_num
       and base_vendor_id                            = dd.base_vendor_id
       and base_vendor_site_id                       = dd.base_vendor_site_id
       and tds_tax_id                                = dd.tds_tax_id
       and NVL(tds_section,'No Section')             = NVL(dd.tds_section,'No Section')
       and NVL(bank_branch_code,'No Bank Branch')    = NVL(dd.bank_branch_code,'No Bank Branch')
       and NVL(challan_num,'No Challan Number')      = NVL(dd.challan_num,'No Challan Number')
       and NVL(challan_date,lv_dummy_date)           = NVL(dd.challan_date,lv_dummy_date)
       and check_number                              = dd.check_number
       and tds_tax_rate                              = dd.tds_tax_rate ;

        END LOOP;

        CLOSE c_deductee_records ;
      END process_deductee_records;


  BEGIN

  /*---------------------------------------------------------------------------------------------------------------------------------
  change history for ja_in_ap_generate_etds_p.sql

  SlNo.  DD/MM/YYYY       Author and Details of Modifications
  ---------------------------------------------------------------------------------------------------------------------------------
  1      22/03/2004  Vijay Shankar for Bug# 3463974, Version: 619.1
                      This procedure is created for enhancement to generate eTDS Flat file by making calls to jai_ap_tds_etds_pkg package

  2      13/04/2004  Vijay Shankar for Bug# 3603545 (also fixed 3567864), Version: 619.2
                      Fixed the issues
                        deductee state code - Using lookup codes in FND_COMMON_LOOKUPS with lookup_type = 'IN_STATE'
                        Deductee payment date - old date among GL_DATE of invoice and check_date
                        reason for non deduction - populating A if stform_type of tds tax is 197 and B if 197A and null if others
                      Also incorporated few error checks and raising errors with relevant message

  3      21/06/2004  Aparajita for bug#3708878. Version 115.1.
                      If more than one TDS invoice has been paid by the same challan, then the challan
                      details were getting repeated as many times as the number of invoices that has been
                      grouped for payment. Changed the code to group by challan number and date.

  4      02/09/2004  Sanjikum for bug#3841751. Version 115.2.
                      Issue:-
                        ETDS CONCURRENT DOES NOT SHOW PAN # IF THE SAME IS SETUP ONLY AT NULL SITE.

                      Reason:-
                        TDS Transactions can take place even if setup is maintained only at null
                        site level without setup at Site level. So for such transactions, no pan# is displayed
                      Fix:-
                        In the cursor - c_deductee_pan added the check that if there is no row returned,
                        then open the same cursor again for vendor_site_id = 0

  5      12/12/2004  Vijay Shankar for Bug#4057192. Version 115.3
                      When postal Code is not a number or number with more that 6 digits, then the application is erroring. which is
                      rectified with this fix by showing proper message on Postal Code attached to Address Location


  6.     2/05/2005   rchandan for bug#4323338. Version 116.1
                     India Org Info DFF is eliminated as a part of JA migration. A table by name ja_in_ap_tds_org_tan is dropped
                     and a view jai_ap_tds_org_tan_v is created to capture the PAN No,TAN NO and WARD NO. The code changes are done
                     to refer to the new view instead of the dropped table.

  7.    8/05/2005    rchandan for bug#4333488. Version 116.1
                     The Invoice Distribution DFF is eliminated and a new global DFF is used to
                     maintain the functionality. From now the TDS tax, WCT tax and ESSI will not
                     be populated in the attribute columns of ap_invoice_distributions_all table
                     instead these will be populated in the global attribute columns. So the code changes are
                     made accordingly.Both Payment and India distributions DFF elimintion is taken care of in
                     the same version.

 8.  19/05/2005     rallamse for Bug#4336482, Version 116.2
                    For SEED there is a change in concurrent to use FND_STANDARD_DATE with STANDARD_DATE format
                    Procedure  signature modified by converting DATE datatype
                    to varchar2 datatype. The varchar2 values are converted to DATE fromat
                    using fnd_date.canonical_to_date function.

 9.  13/07/2007     CSahoo for bug#6158875, File Version 120.12
 									  replaced the AND with OR in the update statement.





  Future Dependencies For the release Of this Object:-
  (Please add a row in the section below only if your bug introduces a dependency due to spec change/ A new call to a object/
  A datamodel change )

  ----------------------------------------------------------------------------------------------------------------------------------------------------
  Current Version       Current Bug    Dependent           Files              Version   Author   Date         Remarks
  Of File                              On Bug/Patchset    Dependent On
  jai_ap_rpt_apcr_pkg.compute_credit_balance.sql
  ----------------------------------------------------------------------------------------------------------------------------------------------------
  115.1                 3708878        IN60105D2+3603545  jai_ap_tds_etds_pkg.sql         Apdas    25/06/2004

  ---------------------------------------------------------------------------------------------------------------------------------------------------

  ---------------------------------------------------------------------------------------------------------------------------------*/
       DUMMY := null ;
       v_fh_recordHash := DUMMY ;
       v_fh_fvuVersion := DUMMY ;
       v_fh_fileHash   := DUMMY ;
       v_fh_samVersion := DUMMY ;
       v_fh_samHash    := DUMMY ;
       v_fh_scmVersion := DUMMY ;
       v_fh_scmHash    := DUMMY ;
       v_bh_trnType  := DUMMY ;
       v_bh_batchUpd   := DUMMY ;
       v_bh_org_RRRno   := DUMMY ;
       v_bh_prev_RRRno  := DUMMY ;
       v_bh_RRRno  := DUMMY ;
       v_bh_RRRdate                      := DUMMY ;
       v_bh_deductor_last_tan            := DUMMY ;
       v_bh_tds_circle                   := DUMMY ;
       v_bh_salaryRecords_count          := DUMMY ;
       v_bh_gross_total                  := DUMMY ;
       v_bh_recHash                      := DUMMY ;
       v_ch_updIndicator           := DUMMY ;
       v_filler1                   := DUMMY ;
       v_filler2                   := DUMMY ;
       v_filler3                   := DUMMY ;
       v_filler4                   := DUMMY ;
       v_last_bank_challan_no      := DUMMY ;
       v_last_transfer_voucher_no   := DUMMY ;
       v_last_bank_branch_code     := DUMMY ;
       v_challan_lastDate          := DUMMY ;
       v_filler5                   := DUMMY ;
       v_filler6                   := DUMMY ;
       v_last_total_depositAmt     := DUMMY ;
       v_ch_recHash                := DUMMY ;
       v_emp_serial_no                := DUMMY ;
       v_last_emp_pan                 := DUMMY ;
       v_last_emp_pan_refno           := DUMMY ;
       v_last_total_tax_deducted      := DUMMY ;
       v_last_total_tax_deposit       := DUMMY ;
       v_total_purchase               := DUMMY ;
       v_deposit_date                 := DUMMY ;
       v_grossingUp_ind               := DUMMY ;
       v_certificate_issue_date       := DUMMY ;
       v_dh_recHash                   := DUMMY ;
       lv_action                      := p_action   ;

    lv_object_name     := 'jai_ap_tds_etds_pkg.generate_flat_file'; /* Added by Ramananda for bug#4407165 */


    v_upload_type           := 'R'    ;
    v_file_creation_date    := SYSDATE  ;
    v_quarterlyOrYearly     :='Y';
    v_conc_request_id       := FND_PROFILE.value('CONC_REQUEST_ID') ;-- File.Sql.35 by Brathod
    p_challan_Start_Date    := fnd_date.canonical_to_date(pv_challan_Start_Date);
    p_challan_End_Date      := fnd_date.canonical_to_date(pv_challan_End_Date);
    v_line_number           := 0;
    v_number_of_batches     := 1;
    v_challan_cnt           := 0;
    v_deductee_cnt          := 0;
    v_challan_dtl_slno      := 0;
    v_deductee_slno         := 0;

    lv_dummy_date    := SYSDATE-1000;
    v_file_type    := 'NS3' ;
    v_quartfile_type   := 'NS1';
    v_upload_type  := 'R';
    v_uploader_type  := 'D';

    v_ao_approval     := 'N';
    v_nil_challan_indicator    := 'N' ;
    v_dh_mode                     := 'O' ;
    v_statement_id := '0';


    -- v_quart_form_number  := '26Q';
     v_quart_form_number  := p_form_number; --Date 11-05-2007 by Sacsethi for bug 5647248

    SELECT JAI_AP_ETDS_T_S.nextval INTO v_batch_id FROM DUAL;

    IF NVL(p_action,'X') <> 'V' THEN
      IF NVL(p_generate_headers,'X') = 'Y' or NVL(p_action,'X') = 'H' THEN
        jai_ap_tds_etds_pkg.v_debug_pad_char := ' ';
        jai_ap_tds_etds_pkg.v_generate_headers := TRUE;
      ELSE
        jai_ap_tds_etds_pkg.v_debug_pad_char := '';
        jai_ap_tds_etds_pkg.v_generate_headers := FALSE;
      END IF;
    END IF;


   IF NVL(p_period,'XX') = 'XX' THEN
     lv_etds_yearly_returns := 'Y' ;
     FND_FILE.put_line(FND_FILE.log, '~~~~Ver:619.1~~~~ Start of eTDS File Creation for Yearly Returns Batch_id->'||v_batch_id
     ||', Creation Date->'||to_char(SYSDATE,'dd-mon-yyyy hh24:mi:ss')||' ~~~~~~~~~~~~~~~~~~');
   ELSE
     lv_etds_yearly_returns := 'N' ;
     FND_FILE.put_line(FND_FILE.log, '~~~~Ver:115.6~~~~ Start of eTDS File Creation for Quarterly returns
     Batch_id->'||v_batch_id || 'Period : ' || p_period
     ||', Creation Date->'||to_char(SYSDATE,'dd-mon-yyyy hh24:mi:ss')||' ~~~~~~~~~~~~~~~~~~');
   END IF ;

    IF length(p_tan_number) > 10 THEN
      FND_FILE.put_line(FND_FILE.log, 'Tan Number length is greater than 10 characters');
      RAISE_APPLICATION_ERROR(-20014, 'Tan Number length is greater than 10 characters', true);
    END IF;

    INSERT INTO JAI_AP_ETDS_REQUESTS(
      batch_id, request_id,/* legal_entity_id, operating_unit_id,*/ org_tan_number, financial_year,
      tax_authority_id, tax_authority_site_id, organization_id,
      deductor_name,
      deductor_state,
      addr_changed_since_last_ret,
      --deductor_status,  /*Bug 8880543 - Commented for eTDS/eTCS FVU Changes*/
      person_resp_for_deduction, designation_of_pers_resp,
      challan_start_date, challan_end_date, file_path, filename,
      program_application_id, program_id, program_login_id,
      -- added, Harshita for Bug 4866533
      created_by, creation_date, last_updated_by, last_update_date
    ) VALUES (
      v_batch_id, v_conc_request_id,/*p_legal_entity_id, p_profile_org_id,*/ p_tan_number, p_fin_year, -- Harshita for Bug 4889272
      p_tax_authority_id, p_tax_authority_site_id, p_organization_id,
      p_deductor_name,
      p_deductor_state,
      p_addrChangedSinceLastRet,
      --p_deductor_status,   /*Bug 8880543 - Commented for eTDS/eTCS FVU Changes*/
      p_persRespForDeduction, p_desgOfPersResponsible,
      p_challan_Start_Date, p_challan_End_Date, p_file_path, p_filename,
      fnd_profile.value('PROG_APPL_ID'), fnd_profile.value('CONC_PROGRAM_ID'), fnd_profile.value('CONC_LOGIN_ID'),
      -- added, Harshita for Bug 4866533
      fnd_global.user_id, sysdate, fnd_global.user_id, sysdate
    );

    FOR k IN c_organization_id(p_tan_number) LOOP

      -- Fetching the Pan Number based on TAN
      OPEN c_pan_number(k.organization_id);
      FETCH c_pan_number INTO v_deductor_pan;
      CLOSE c_pan_number;

      EXIT WHEN v_deductor_pan IS NOT NULL;

    END LOOP;

    IF v_deductor_pan IS NULL THEN
      FND_FILE.put_line(FND_FILE.log, 'Pan Number cannot be retreived based on given TAN Number');
      RAISE_APPLICATION_ERROR(-20015, 'Pan Number cannot be retreived based on given TAN Number', true);
    END IF;


    --v_legal_entity_id       := p_legal_entity_id; -- Harshita for Bug 4889272
    v_financial_year        := p_fin_year;
    v_deductor_tan          := p_tan_number;

    v_tan_state_code        := to_number(p_deductor_state);
    v_deductor_name         := p_deductor_name;
    --v_deductor_type         := p_deductor_status; /*Commented for Bug 8880543 - Deductor Type is derived from Regime Setup*/
    v_addrChangedSinceLastReturn  := p_addrChangedSinceLastRet;
    v_personNameRespForDedection  := p_persRespForDeduction;
    v_personDesgnRespForDedection := p_desgOfPersResponsible;

    -- Fetching Start Date and End date of given Financial Year
    OPEN  c_fin_year(v_deductor_tan, /* v_legal_entity_id*/ v_financial_year, p_organization_id); -- Harshita for Bug 4889272
    FETCH c_fin_year INTO v_start_date, v_end_date;
    CLOSE c_fin_year;

    IF v_start_date IS NULL OR v_end_date IS NULL THEN
      FND_FILE.put_line(FND_FILE.log, 'Cannot get values for Financial Year and Assessment Year');
      RAISE_APPLICATION_ERROR( -20016, 'Cannot get values for Financial Year and Assessment Year');
    END IF;

    -- Fetching Location linked to Input Organization from where address details are captured
    OPEN c_location_linked_to_org(p_organization_id);
    FETCH c_location_linked_to_org INTO v_location_id;
    CLOSE c_location_linked_to_org;


    jai_ap_tds_etds_pkg.populate_details(
      v_batch_id,
      --p_legal_entity_id, -- Harshita for Bug 4889272
      p_tan_number,
      p_tax_authority_id,
      p_tax_authority_site_id,
      p_challan_Start_Date,
      p_challan_end_Date,
      lv_etds_yearly_returns,
      p_include_list, --Date 11-05-2007 by Sacsethi for bug 5647248
      p_exclude_list
    );

    -- Shall Populate the Address Details of Batch Header
    OPEN c_address_details(v_location_id);
    FETCH c_address_details INTO v_location_code, v_tan_address1, v_tan_address2, v_tan_address3, v_tan_address4,
      v_tan_address5, v_postal_code;
    CLOSE c_address_details;

    -- Start, Vijay Shankar for Bug#4057192
    -- checks for Pincode related to Address location
    IF length(v_postal_code) > 6 THEN
      RAISE_APPLICATION_ERROR(-20010, 'Postal Code of Location should not have more than 6 digit numbered value. Location Code (id):'||v_location_code||' ('||v_location_id||')');
    END IF;

    BEGIN
      v_tan_pin := to_number(v_postal_code);
    EXCEPTION
      WHEN VALUE_ERROR THEN     -- SQLCODE = '-6502', PL/SQL: numeric or value error: character to number conversion error
        RAISE_APPLICATION_ERROR(-20010, 'Postal Code of Location should be a 6 digit number. Location Code (id):'||v_location_code||' ('||v_location_id||')');
    END;
    -- End, Vijay Shankar for Bug#4057192

    BEGIN
      jai_ap_tds_etds_pkg.openFile(p_file_path, p_filename);
    EXCEPTION
      WHEN OTHERS THEN
        FND_FILE.put_line(FND_FILE.log, 'Error Occured during opening of file(1):'||SQLERRM);
        RAISE_APPLICATION_ERROR(-20016, 'Error Occured(1):'||SQLERRM, true);
    END;

    IF p_action <> 'V' THEN
    FND_FILE.put_line(FND_FILE.log, 'Start File Header');
    END IF ;

    -- File Header (42 Chars)
    v_line_number := v_line_number + 1;
    v_record_type := 'FH';
    v_file_sequence_number := 1;

    get_attr_value (p_organization_id, 'RETURN_PREP_UTILITY', v_return_prep_util, v_err, v_return_message);
    chk_err(v_err, v_return_message);

    IF lv_etds_yearly_returns = 'Y' THEN
     IF p_generate_headers = 'Y' THEN
      jai_ap_tds_etds_pkg.create_fh(v_batch_id);
     END IF;

    jai_ap_tds_etds_pkg.create_file_header(v_line_number, v_record_type, v_file_type, v_upload_type,
      v_file_creation_date, v_file_sequence_number, v_deductor_tan, v_number_of_batches);
    ELSE
     IF p_action = 'H' THEN
         jai_ap_tds_etds_pkg.create_quarterly_fh
		 (v_batch_id,
		 p_period,
		 p_RespPers_flat_no, p_RespPers_prem_bldg,  -- Bug 6030953
	     p_RespPers_rd_st_lane, p_RespPers_area_loc, -- Bug 6030953
	     p_RespPers_tn_cty_dt, -- Bug 6030953
		 p_RespPersState, p_RespPersPin,
		 p_RespPers_tel_no, p_RespPers_email, -- Bug 6030953
		 p_RespPersAddrChange );
     END IF;

      p_return_code    := null ;
      p_return_message := null ;

      jai_ap_tds_etds_pkg.validate_file_header
      ( p_line_number          => v_line_number ,
        p_record_type          => v_record_type ,
        p_quartfile_type       => v_quartfile_type,
        p_upload_type          => v_upload_type,
        p_file_creation_date   => v_file_creation_date,
        p_file_sequence_number => v_file_sequence_number,
        p_uploader_type        => v_uploader_type ,
        p_deductor_tan         => v_deductor_tan ,
        p_number_of_batches    => v_number_of_batches,
        p_ret_prep_util        => v_return_prep_util,         /*Bug 8880543 - Added Return Preperation Utility*/
        p_period               => p_period,
        p_challan_start_date   => p_challan_Start_Date,
        p_challan_end_date     => p_challan_End_Date,
        p_fin_year             => to_char(v_start_date,'YYYY'),/*(p_fin_year has been replaced with to_char(v_start_date,'YYYY')
                                                                by rchandan for bug#4640996*/
        p_return_code          => p_return_code,
        p_return_message       => p_return_message
      );

         IF p_return_code = 'E' THEN
           IF lv_action = 'V' THEN
            insert into jai_ap_etds_errors_t
              (batch_id, record_type,  error_message) values
            ( v_batch_id, 'FH',  p_return_message ) ; /*Bug 8880543 - Modified ln_batch_id to v_batch_id*/
           ELSE
            p_ret_code := jai_constants.request_error ;
            p_err_buf := p_return_message ;
            RETURN ;
           END IF ;
         END IF ;

      lv_generate_headers := null ;
      IF p_action <> 'V' THEN
       IF p_action = 'F' THEN
         lv_generate_headers := 'N' ;
       ELSIF p_action = 'H' THEN
         lv_generate_headers := 'Y' ;
       END IF ;

       jai_ap_tds_etds_pkg.create_quarterly_file_header
         (
           p_line_number              =>  v_line_number,
           p_record_type              =>  v_record_type,
           p_file_type                =>  v_quartfile_type,
           p_upload_type              =>  v_upload_type,
           p_file_creation_date       =>  v_file_creation_date,
           p_file_sequence_number     =>  v_file_sequence_number,
           p_uploader_type            =>  v_uploader_type,
           p_deductor_tan             =>  v_deductor_tan,
           p_number_of_batches        =>  v_number_of_batches,
           p_return_prep_util         =>  v_return_prep_util,
           p_fh_recordHash            =>  v_fh_recordHash,
           p_fh_fvuVersion            =>  v_fh_fvuVersion,
           p_fh_fileHash              =>  v_fh_fileHash,
           p_fh_samVersion            =>  v_fh_samVersion,
           p_fh_samHash               =>  v_fh_samHash,
           p_fh_scmVersion            =>  v_fh_scmVersion,
           p_fh_scmHash               =>  v_fh_scmHash,
           p_generate_headers         =>  lv_generate_headers
         ) ;
      END IF ;
    END IF ;

    -- Batch Header (411 Chars)
    v_line_number := v_line_number + 1;
    v_record_type := 'BH';
    v_batch_number := 1;
    v_form_number := 26;    -- as per Vikrams update
    v_financial_year := to_char(v_start_date, 'YYYY')||to_char(v_end_date, 'YY');
    v_assessment_year := to_char(add_months(v_start_date,12), 'YYYY')||to_char(add_months(v_end_date,12), 'YY');

    /*SELECT count(1), sum(tds_amount)
    FROM JAI_AP_ETDS_T
    WHERE batch_id = v_batch_id AND consider_for_challan=1;*/

    -- bug#3708878. Above select was changed to the select below.
    select count(1), sum(tds_amt)
    INTO v_challan_cnt, v_totTaxDeductedAsPerChallan
    from
    (
    select tds_section, bank_branch_code, challan_num, challan_date, sum(tds_amount) tds_amt
    from   JAI_AP_ETDS_T
    WHERE  batch_id = v_batch_id AND consider_for_challan=1
    group by tds_section, bank_branch_code, challan_num, challan_date
    );

    SELECT count(1), sum(tds_amount) INTO v_deductee_cnt, v_totTaxDeductedAsPerDeductee
    FROM JAI_AP_ETDS_T
    WHERE batch_id = v_batch_id AND consider_for_deductee=1;


    IF p_action <> 'V' THEN
    FND_FILE.put_line(FND_FILE.log, 'Batch Header');
    END IF ;

    v_ack_num_tan_app := NULL;
    v_pro_rcpt_num_org_ret := nvl(p_pro_rcpt_num_org_ret,0);

    /*Bug 8880543 - Fetch Attribute values for eTDS/eTCS FVU Changes - Start*/
    get_attr_value (p_organization_id, 'DEDUCTOR_TYPE', v_deductor_type, v_err, v_return_message);
    chk_err(v_err, v_return_message);
    get_attr_value (p_organization_id, 'STATE', v_state_name, v_err, v_return_message);
    chk_err(v_err, v_return_message);
    get_attr_value (p_organization_id, 'MINISTRY_NAME', v_ministry_name, v_err, v_return_message);
    chk_err(v_err, v_return_message);
    get_attr_value (p_organization_id, 'PAO_CODE', v_pao_code, v_err, v_return_message);
    chk_err(v_err, v_return_message);
    get_attr_value (p_organization_id, 'DDO_CODE', v_ddo_code, v_err, v_return_message);
    chk_err(v_err, v_return_message);
    get_attr_value (p_organization_id, 'PAO_REGISTRATION_NO', v_pao_registration_no, v_err, v_return_message);
    chk_err(v_err, v_return_message);
    get_attr_value (p_organization_id, 'DDO_REGISTRATION_NO', v_ddo_registration_no, v_err, v_return_message);
    chk_err(v_err, v_return_message);

    IF v_ministry_name = '99' THEN
       select meaning into v_ministry_name_other
       from ja_lookups lkup
       where lkup.lookup_type = 'JAI_MIN_NAME_VALUES'
       and lkup.lookup_code = '99';
    else
       v_ministry_name_other := NULL;
    END IF;

    IF lv_etds_yearly_returns = 'Y' THEN

      IF p_generate_headers = 'Y' THEN
        jai_ap_tds_etds_pkg.create_bh;
      END IF;

    jai_ap_tds_etds_pkg.create_batch_header(v_line_number, v_record_type, v_batch_number,
      v_challan_cnt, v_deductee_cnt, v_form_number, v_rrr_number, v_rrr_date,
      v_deductor_tan, v_deductor_pan, v_assessment_year, v_financial_year, v_deductor_name,
      v_tan_address1, v_tan_address2, v_tan_address3, v_tan_address4, v_tan_address5,
      v_tan_state_code, v_tan_pin, v_addrChangedSinceLastReturn, v_deductor_type, /*Bug 8880543 - Modified Deductor Status to Deductor Type*/
      v_quarterlyOrYearly, v_personNameRespForDedection, v_personDesgnRespForDedection,
      v_totTaxDeductedAsPerChallan, v_totTaxDeductedAsPerDeductee
    );

    ELSE
      IF p_action = 'H' THEN
            jai_ap_tds_etds_pkg.create_quarterly_bh;
      END IF;

    p_return_code    := null ;
    p_return_message := null ;


    jai_ap_tds_etds_pkg.validate_batch_header
    ( p_line_number                  => v_line_number   ,
      p_record_type                  => v_record_type   ,
      p_batch_number                 => v_batch_number  ,
      p_challan_cnt                  => v_challan_cnt ,
      p_quart_form_number            => v_quart_form_number  ,
      p_deductor_tan                 => v_deductor_tan   ,
      p_assessment_year              => v_assessment_year,
      p_financial_year               => v_financial_year ,
      p_deductor_name                => v_deductor_name ,
      p_deductor_pan                 => v_deductor_pan ,
      p_tan_address1                 => v_tan_address1  ,
      p_tan_state_code               => v_tan_state_code   ,
      p_tan_pin                      => v_tan_pin    ,
      p_deductor_type                => v_deductor_type , /*Bug 8880543 - Modified Deductor Status to Deductor Type*/
      p_addrChangedSinceLastReturn   => v_addrChangedSinceLastReturn,
      p_personNameRespForDedection   => v_personNameRespForDedection,
      p_personDesgnRespForDedection  => v_personDesgnRespForDedection,
      -- bug 6030953. Added by Lakshmi Gopalsami
	  p_RespPers_flat_no         =>   p_RespPers_flat_no        ,
	  p_RespPers_prem_bldg       =>   p_RespPers_prem_bldg      ,
	  p_RespPers_rd_st_lane      =>   p_RespPers_rd_st_lane     ,
	  p_RespPers_area_loc        =>   p_RespPers_area_loc       ,
	  p_RespPers_tn_cty_dt       =>   p_RespPers_tn_cty_dt      ,
	  -- end for bug 6030953
      p_RespPersState                => p_RespPersState    ,
      p_RespPersPin                  => p_RespPersPin   ,
	  -- bug 6030953. Added by Lakshmi Gopalsami
	  p_RespPers_tel_no          =>   p_RespPers_tel_no         ,
	  p_RespPers_email           =>   p_RespPers_email          ,
	  -- end for bug 6030953
      p_RespPersAddrChange           => p_RespPersAddrChange ,
      p_totTaxDeductedAsPerDeductee  => v_totTaxDeductedAsPerDeductee,
      p_ao_approval                  => v_ao_approval,
      /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
      p_state_name                   => v_state_name,
      p_pao_code                     => v_pao_code,
      p_ddo_code                     => v_ddo_code,
      p_ministry_name                => v_ministry_name,
      p_pao_registration_no          => v_pao_registration_no,
      p_ddo_registration_no          => v_ddo_registration_no,
      /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
      p_return_code                  => p_return_code,
      p_return_message               => p_return_message
    );

      IF p_return_code = 'E' THEN
        IF lv_action = 'V' THEN
         insert into jai_ap_etds_errors_t(batch_id, record_type, error_message) values
         ( v_batch_id, 'BH', p_return_message ) ; /*Bug 8880543 - Modified ln_batch_id to v_batch_id*/
        ELSE
         p_ret_code := jai_constants.request_error ;
         p_err_buf := p_return_message ;

         RETURN ;
        END IF ;
      END IF ;


    lv_generate_headers := null ;
    IF p_action <> 'V' THEN
     IF p_action = 'F' THEN
       lv_generate_headers := 'N' ;
     ELSIF p_action = 'H' THEN
       lv_generate_headers := 'Y' ;
    END IF ;

     jai_ap_tds_etds_pkg.create_quarterly_batch_header
     (
       p_line_number                => v_line_number,
       p_record_type                => v_record_type,
       p_batch_number               => v_batch_number,
       p_challan_count              => v_challan_cnt,
       p_form_number                => v_quart_form_number,
       p_trn_type                   => v_bh_trnType,
       p_batchUpd                   => v_bh_batchUpd,
       p_org_RRRno                  => v_bh_org_RRRno,
       p_prev_RRRno                 => v_bh_prev_RRRno,
       p_RRRno                      => v_bh_RRRno,
       p_RRRdate                    => v_bh_RRRdate,
       p_deductor_last_tan          => v_bh_deductor_last_tan,
       p_deductor_tan               => v_deductor_tan,
       p_filler1                    => v_filler1,
       p_deductor_pan               => v_deductor_pan,
       p_assessment_year            => v_assessment_year,
       p_financial_year             => v_financial_year,
       p_period                     => p_period,
       p_deductor_name              => v_deductor_name,
       p_deductor_branch            => v_deductor_branch,
       p_tan_address1               => v_tan_address1,
       p_tan_address2               => v_tan_address2,
       p_tan_address3               => v_tan_address3,
       p_tan_address4               => v_tan_address4,
       p_tan_address5               => v_tan_address5,
       p_tan_state_code             => v_tan_state_code,
       p_tan_pin                    => v_tan_pin,
       p_deductor_email             => v_deductor_email,
       p_deductor_stdCode           => v_deductor_stdCode,
       p_deductor_phoneNo           => v_deductor_phoneNo,
       p_addrChangedSinceLastReturn => v_addrChangedSinceLastReturn,
       p_type_of_deductor           => v_deductor_type, /*Bug 8880543 - Modified Deductor Status to Deductor Type*/
       p_pers_resp_for_deduction    => v_personNameRespForDedection,
       p_PespPerson_designation     => v_personDesgnRespForDedection,
       p_RespPerson_address1        => p_RespPers_flat_no,  -- bug 6030953
       p_RespPerson_address2        => p_RespPers_prem_bldg,  -- bug 6030953
       p_RespPerson_address3        => p_RespPers_rd_st_lane,  -- bug 6030953
       p_RespPerson_address4        => p_RespPers_area_loc,  -- bug 6030953
       p_RespPerson_address5        => p_RespPers_tn_cty_dt,  -- bug 6030953
       p_RespPerson_state           => p_RespPersState,
       p_RespPerson_pin             => p_RespPersPin,
       p_RespPerson_email           => p_RespPers_email,   -- bug 6030953
       p_RespPerson_remark          => v_RespPerson_remark,
       p_RespPerson_stdCode         => v_RespPerson_stdCode,
       p_RespPerson_phoneNo         => p_RespPers_tel_no,   -- bug 6030953
       p_RespPerson_addressChange   => p_RespPersAddrChange,
       p_totTaxDeductedAsPerChallan => round(v_totTaxDeductedAsPerDeductee),  -- decimal should be .00
       p_tds_circle                 => v_bh_tds_circle,
       p_salaryRecords_count        => v_bh_salaryRecords_count,
       p_gross_total                => v_bh_gross_total,
       p_ao_approval                => v_ao_approval     ,
       p_ao_approval_number         => v_ao_approval_number,
       /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - Start*/
       p_last_deductor_type         => v_last_deductor_type,
       p_state_name                 => v_state_name,
       p_pao_code                   => v_pao_code,
       p_ddo_code                   => v_ddo_code,
       p_ministry_name              => v_ministry_name,
       p_ministry_name_other        => v_ministry_name_other,
       p_filler2                    => v_filler2,
       p_pao_registration_no        => v_pao_registration_no,
       p_ddo_registration_no        => v_ddo_registration_no,
       /*Bug 8880543 - Added for eTDS/eTCS FVU Changes - End*/
       p_recHash                    => v_bh_recHash,
       p_generate_headers           => lv_generate_headers
       ) ;
      END IF ;
    END IF ;

    IF p_action <> 'V' THEN
    FND_FILE.put_line(FND_FILE.log, 'Challan Detail');
    END IF ;

    -- Challan Details (60 Chars)
    v_record_type := 'CD';
    IF lv_etds_yearly_returns = 'Y' THEN
      IF p_generate_headers = 'Y' THEN
        jai_ap_tds_etds_pkg.create_cd;
      END IF;
    END IF;

    v_challan_dtl_slno := 0;
    FOR cd IN c_challan_records(v_batch_id)
    LOOP
          v_line_number := v_line_number + 1;
      v_challan_dtl_slno := v_challan_dtl_slno + 1;
      ln_amt_of_oth := 0;
      v_record_type := 'CD';
      v_check_number := cd.check_number;

      IF cd.challan_date = lv_dummy_date THEN
        cd.challan_date := to_date(null) ;
      END IF ;

      IF lv_etds_yearly_returns = 'Y' THEN -- Harshita for Bug 4525089
        jai_ap_tds_etds_pkg.create_challan_detail(v_line_number, v_record_type, v_batch_number, v_challan_dtl_slno,
        cd.tds_section, cd.tds_amount, cd.challan_num, cd.challan_date, cd.bank_branch_code
        );
      ELSE
        IF cd.challan_num = 'No Challan Number' THEN
           cd.challan_num := null ;
        END IF ;

    	FND_FILE.put_line(FND_FILE.log, 'cd.tds_section: '||cd.tds_section||' cd.challan_num: '||cd.challan_num|| ' cd.challan_date :' || cd.challan_date || 'cd.bank_branch_code' || cd.bank_branch_code || 'cd.check_number' || cd.check_number);


      --MODIFIED BY CSAHOO FOR BUG#6158875
      OPEN c_deductee_cnt(v_batch_id, cd.check_number, cd.tds_section,
      										cd.challan_num, cd.challan_date,cd.bank_branch_code);
      FETCH c_deductee_cnt INTO v_q_deductee_cnt ;
      CLOSE c_deductee_cnt ;

      FND_FILE.put_line(FND_FILE.log, 'v_batch_id: '||v_batch_id||' v_q_deductee_cnt: '||v_q_deductee_cnt);

        IF p_action = 'H'  THEN
        jai_ap_tds_etds_pkg.create_quarterly_cd;
      END IF ;

      v_total_deposit    := cd.amt_of_tds + cd.amt_of_surcharge + cd.amt_of_cess;

      IF cd.challan_num IS NULL THEN
       v_bank_branch_code := null ;
      ELSE
       v_bank_branch_code := substr(cd.bank_branch_code,1,7);
      END IF ;

      p_return_code    := null ;
      p_return_message := null ;


      jai_ap_tds_etds_pkg.validate_challan_detail
      (
        p_line_number               => v_line_number  ,
        p_record_type               => v_record_type  ,
        p_batch_number              => v_batch_number ,
        p_challan_dtl_slno          => v_challan_dtl_slno   ,
        p_deductee_cnt              => v_q_deductee_cnt ,
        p_nil_challan_indicat       => v_nil_challan_indicator,
        p_tds_section               => cd.tds_section   ,
        p_amt_of_tds                => cd.amt_of_tds    ,
        p_amt_of_surcharge          => cd.amt_of_surcharge  ,
        p_amt_of_cess               => cd.amt_of_cess  ,
        p_amt_of_oth                => ln_amt_of_oth   ,
        p_tds_amount                => cd.tds_amount   ,
        p_total_income_tds          => v_total_deposit ,
        p_challan_num               => cd.challan_num,
        p_bank_branch_code          => cd.bank_branch_code,
        p_challan_no                => cd.challan_num,
        p_challan_Date              => cd.challan_date,
        p_check_number              => cd.check_number,
        p_return_code               => p_return_code,
        p_return_message            => p_return_message
      );
      IF p_return_code = 'E' THEN
        IF lv_action = 'V' THEN
         insert into jai_ap_etds_errors_t
           (batch_id, record_type, reference_id, error_message) values
           ( v_batch_id, 'CD', v_line_number, p_return_message ) ; /*Bug 8880543 - Modified ln_batch_id to v_batch_id*/
        ELSE
         p_ret_code := jai_constants.request_error ;
         p_err_buf := p_return_message ;

         RETURN ;
        END IF ;
      END IF ;


      lv_generate_headers := null ;
      IF p_action <> 'V' THEN
       IF p_action = 'F' THEN
         lv_generate_headers := 'N' ;
       ELSIF p_action = 'H' THEN
         lv_generate_headers := 'Y' ;
       END IF ;

      ln_amt_of_tds :=  cd.tds_amount - round(cd.amt_of_surcharge) - round(cd.amt_of_cess) - round(ln_amt_of_oth) - round(ln_amt_of_oth) ;

      /*Bug 8880543 - Challan Number to be used only if deductor type is not A or S - Start*/
      IF (v_deductor_type in ('A', 'S')) THEN
         v_transfer_voucher_no := to_number(cd.challan_num);
         v_challan_number := NULL;
         v_bank_branch_code := NULL;
         v_check_number := NULL;
         v_book_entry := 'Y';
      else
         v_challan_number := to_number(cd.challan_num);
         v_transfer_voucher_no := NULL;
         v_book_entry := 'N';
      END IF;
      /*Bug 8880543 - Challan Number to be used only if deductor type is not A or S - End*/


      jai_ap_tds_etds_pkg.create_quart_challan_dtl
      (
        p_line_number              => v_line_number,
        p_record_type              => v_record_type,
        p_batch_number             => v_batch_number,
        p_challan_dtl_slno         => v_challan_dtl_slno,
        p_deductee_cnt             => v_q_deductee_cnt,
        p_nil_challan_indicator    => v_nil_challan_indicator,
        p_ch_updIndicator          => v_ch_updIndicator,
        p_filler2                  => v_filler2,
        p_filler3                  => v_filler3,
        p_filler4                  => v_filler4,
        p_last_bank_challan_no     => v_last_bank_challan_no,
        p_bank_challan_no          => v_challan_number,
        /*Bug 8880543 - Challan Number to be used only if deductory type is not A or S*/
        p_last_transfer_voucher_no => v_last_transfer_voucher_no,
        p_transfer_voucher_no      => v_transfer_voucher_no,
        /*Bug 8880543 - Replaced v_transfer_voucher_no with Challan Number if Deductor Type is A or S*/
        p_last_bank_branch_code    => v_last_bank_branch_code,
        p_bank_branch_code         => v_bank_branch_code ,
        p_challan_lastDate         => v_challan_lastDate,
        p_challan_Date             => cd.challan_date,
        p_filler5                  => v_filler5,
        p_filler6                  => v_filler6,
        p_tds_section              => cd.tds_section,
        p_amt_of_tds               => ln_amt_of_tds,
        p_amt_of_surcharge         => round(cd.amt_of_surcharge),
        p_amt_of_cess              => round(cd.amt_of_cess),
        p_amt_of_int               => round(ln_amt_of_oth),
        p_amt_of_oth               => round(ln_amt_of_oth),
        p_tds_amount               => cd.tds_amount,
        p_last_total_depositAmt    => v_last_total_depositAmt,
        p_total_deposit            => v_total_deposit,
        p_tds_income_tax           => cd.amt_of_tds,
        p_tds_surcharge            => cd.amt_of_surcharge,
        p_tds_cess                 => cd.amt_of_cess,
        p_total_income_tds         => v_total_deposit,
        p_tds_interest_amt         => 0,
        p_tds_other_amt            => 0,
        p_check_number             => v_check_number, /*Bug 8880543 - Validation required based on Deductor Type*/
        p_book_entry               => v_book_entry,
        p_remarks                  => v_remarks,
        p_ch_recHash               => v_ch_recHash,
        p_generate_headers         => lv_generate_headers,
	/* Bug 6796765. Added by Lakshmi Gopalsami
	 * Added p_form_name as this is required to print the
	 * section code depending on the section
	 */
	p_form_name    =>    v_quart_form_number
      ) ;
       END IF ;
      END IF ;



      -- UPDATE JAI_AP_ETDS_T SET challan_line_num = v_line_number WHERE CURRENT OF c_challan_records;
      -- bug#3708878. update needed to be changed as for update of cannot be used with group by
      UPDATE JAI_AP_ETDS_T
      SET    challan_line_num = v_line_number
      WHERE  batch_id = v_batch_id
      and    ( ( tds_section IS NULL AND cd.tds_section IS NULL ) OR ( tds_section = cd.tds_section ) )--nvl(tds_section, 'No Section') = nvl(cd.tds_section, 'No Section')
      and    ( (challan_num IS NULL AND cd.challan_num IS NULL ) OR ( challan_num = cd.challan_num ) ) --nvl(challan_num, 'No Challan Number') = nvl(cd.challan_num, 'No Challan Number')
      and    nvl(challan_date, trunc(sysdate) ) = nvl(cd.challan_date, trunc(sysdate) )
      -- csahoo for bug 6158875, replaced the AND by OR below
      and    (( bank_branch_code IS NULL AND cd.bank_branch_code IS NULL ) OR ( bank_branch_code = cd.bank_branch_code )) --nvl(bank_branch_code, 'No Bank Branch') = nvl(cd.bank_branch_code, 'No Bank Branch')
      and    consider_for_challan=1;

      IF p_action <> 'V' THEN
        FND_FILE.put_line(FND_FILE.log, 'Challan Line:'||v_line_number
          ||', tdsSec:' || cd.tds_section || ', ChlNum:' || cd.challan_num
          ||', ChlDate:'||cd.challan_date||', bankBr:'||cd.bank_branch_code
        );
      END IF ;

      IF lv_etds_yearly_returns = 'N' THEN -- Harshita for Bug 4525089

        v_record_type := 'DD';
        v_challan_line_num := v_line_number ;

        IF p_action = 'H' THEN
          jai_ap_tds_etds_pkg.create_quarterly_dd;
        END IF;

        v_deductee_slno := 0 ;
        process_deductee_records ;  -- internal procedure call
        v_challan_line_num := null ;

      END IF ;

    END LOOP;

    IF lv_etds_yearly_returns= 'Y' THEN
      v_record_type := 'DD';
      IF p_action <> 'V' THEN
        FND_FILE.put_line(FND_FILE.log, 'Deductee Detail');
        -- Dedectee Details (338 Chars)
        v_record_type := 'DD';
        v_deductee_slno := 0;
      END IF;

      IF p_generate_headers = 'Y' THEN
        jai_ap_tds_etds_pkg.create_dd;
      END IF;

       v_challan_line_num := null ;
       process_deductee_records ;
   END IF ;

    IF p_action = 'V' THEN

      FND_FILE.put_line(FND_FILE.log,' LISTING THE ERRORS IN THIS BATCH ' );
      FND_FILE.put_line(FND_FILE.log,'-------------------------------------------------------------------- ' );

      ln_errors_exist := 0;

      FOR rec_get_errors IN c_get_errors(v_batch_id) /*Bug 8880543 - Modified ln_batch_id to v_batch_id*/
      LOOP
        ln_errors_exist := 1 ;
        FND_FILE.put_line(FND_FILE.log, rec_get_errors.Error_Message );
      END LOOP ;

      IF ln_errors_exist = 0 THEN
        FND_FILE.put_line(FND_FILE.log,' File Validation Successful. No Errors Found !! ' );
      END IF ;

      FND_FILE.put_line(FND_FILE.log,'-------------------------------------------------------------------- ' );
      FND_FILE.put_line(FND_FILE.log,' END OF ERRORS IN THIS BATCH ' );

    END IF ;

    jai_ap_tds_etds_pkg.closeFile;

    IF p_action <> 'V' THEN
      FND_FILE.put_line(FND_FILE.log, '~~~~~~~~~~~~~~~ End of eTDS File Creation ~~~~~~~~~~~~~~~~~~');
    END IF ;

/* Added by Ramananda for bug#4407165 */
 EXCEPTION
  WHEN OTHERS THEN
    p_err_buf  := null;
    p_ret_code := null;
    FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
    app_exception.raise_exception;

END generate_etds_returns;

-- ended, Harshita for 5096787


END jai_ap_tds_etds_pkg;

/
