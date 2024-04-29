--------------------------------------------------------
--  DDL for Package Body PAY_ARCHIVE_CHEQUEWRITER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ARCHIVE_CHEQUEWRITER" as
/* $Header: paychqarch.pkb 120.0.12010000.4 2009/03/19 09:51:27 sudedas ship $ */
/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : pay_us_chkw_depad
    Package File Name   : payuschkdp.pkb

    Description : Used for Archive Cheque Writer producing XML output.

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sausingh      24-May-2007 115.0   5635335 Created.
    sudedas
    sudedas       12-Feb-2008 115.1   6802173 Added Code for producing Dummy
                                              Check for Un-Archived Employee and
                                              marking Action Status as 'Skipped'
    sudedas       11-Jun-2008 115.2   6938195 Changed Cursor get_arch_asg_action
                                              _id for Separate Payment Run.
    sudedas       19-Mar-2009 115.3   8348725 Changed datatype for l_asg_num
    ========================================================================*/

--
-- Global Variables
--
    g_proc_name     varchar2(240);
    g_debug         boolean;
    g_document_type varchar2(50);

   /****************************************************************************
    Name        : PRINT_BLOB
    Description : This procedure prints contents of BLOB passed as parameter.
  *****************************************************************************/

    PROCEDURE PRINT_BLOB(p_blob BLOB) IS
    BEGIN
        IF g_debug THEN
            pay_ac_utility.print_lob(p_blob);
        END IF;
    END PRINT_BLOB;

  /****************************************************************************
    Name        : WRITE_TO_MAGTAPE_LOB
    Description : This procedure appends passed BLOB parameter to
                  pay_mag_tape.g_blob_value
  *****************************************************************************/

    PROCEDURE WRITE_TO_MAGTAPE_LOB(p_blob BLOB) IS
    BEGIN
        IF  dbms_lob.getLength (p_blob) IS NOT NULL THEN
            pay_core_files.write_to_magtape_lob (p_blob);
        END IF;
    END WRITE_TO_MAGTAPE_LOB;

  /****************************************************************************
    Name        : WRITE_TO_MAGTAPE_LOB
    Description : This procedure appends passed varchar2 parameter to
                  pay_mag_tape.g_blob_value
  *****************************************************************************/

    PROCEDURE WRITE_TO_MAGTAPE_LOB(p_data varchar2) IS
    BEGIN
            pay_core_files.write_to_magtape_lob (p_data);
    END WRITE_TO_MAGTAPE_LOB;

  /****************************************************************************
    Name        : LOAD_XML
    Description : This Function generates XML Tags and Pass
  *****************************************************************************/

        FUNCTION LOAD_XML (
            P_NODE_TYPE         varchar2,
            P_NODE              varchar2,
            P_DATA              varchar2
        ) RETURN VARCHAR2 AS

            l_proc_name     varchar2(100);
            l_tag_name      varchar2(500);
            l_struct_code   fnd_id_flex_structures.id_flex_structure_code%type;
            l_data          VARCHAR2(300);
            l_ret_xml       VARCHAR2(32000);

        BEGIN

            IF UPPER(p_node) NOT LIKE '?XML%' AND UPPER(p_node) NOT LIKE 'XAPI%' THEN
                l_tag_name := nvl(l_tag_name, TRANSLATE(p_node,' /', '__'));
                IF p_node_type IN ('CS', 'CE') THEN
                    l_tag_name := TRANSLATE(p_node, ' /', '__');
                END IF;
            ELSE
                l_tag_name := p_node;
            END IF;

            IF p_node_type = 'CS' THEN
                l_ret_xml := '<'||l_tag_name||'>' ;
            ELSIF p_node_type = 'CE' THEN
                l_ret_xml := '</'||l_tag_name||'>' ;
            ELSIF p_node_type = 'D' THEN
               /* Handle special charaters in data */
                l_data := REPLACE (p_data, '&', '&amp;');
                l_data := REPLACE (l_data, '>', '&gt;');
                l_data := REPLACE (l_data, '<', '&lt;');
                l_data := REPLACE (l_data, '''', '&apos;');
                l_data := REPLACE (l_data, '"', '&quot;');
                l_ret_xml := '<'||l_tag_name||'>'||l_data||'</'||l_tag_name||'>' ;
            END IF;
            RETURN l_ret_xml ;
        END LOAD_XML;

  /****************************************************************************
    Name        : LOAD_SEGMENT_XML
    Description : This Function generates XML Child Tags for Segments
                  under each Context of Action Info DF
  *****************************************************************************/

        FUNCTION load_segment_xml(cp_segment_name IN VARCHAR2
                                  ,cp_segment_val IN VARCHAR2 DEFAULT NULL)
        RETURN VARCHAR2 AS
            l_segment_name   VARCHAR2(500);
            l_ret_seg_xml        VARCHAR2(32000);
        BEGIN
            l_segment_name := UPPER(REPLACE(cp_segment_name,' ' ,'_'));
            l_ret_seg_xml := load_xml('D',l_segment_name, cp_segment_val);
            RETURN l_ret_seg_xml;
        END load_segment_xml;

  /****************************************************************************
    Name        : LOAD_CTX_XML_START_TAG
    Description : This Function generates XML Start Tags for each Context
                  of Action Info DF
  *****************************************************************************/

        FUNCTION load_ctx_xml_start_tag(cp_context_name IN VARCHAR2)
        RETURN VARCHAR2 AS
            l_ctx_name    VARCHAR2(500);
            l_ret_ctx_st_xml VARCHAR2(32000);
        BEGIN
            l_ctx_name := UPPER(REPLACE(cp_context_name,' ' ,'_'));
            l_ret_ctx_st_xml := load_xml('CS',l_ctx_name , NULL);
            RETURN l_ret_ctx_st_xml;
        END load_ctx_xml_start_tag;

  /****************************************************************************
    Name        : LOAD_CTX_XML_END_TAG
    Description : This Function generates XML End Tags for each Context
                  of Action Info DF
  *****************************************************************************/

        FUNCTION load_ctx_xml_end_tag(cp_context_name IN VARCHAR2)
        RETURN VARCHAR2 AS
            l_ctx_name    VARCHAR2(500);
            l_ret_ctx_end_xml VARCHAR2(32000);
        BEGIN
            l_ctx_name := UPPER(REPLACE(cp_context_name,' ' ,'_'));
            l_ret_ctx_end_xml := load_xml('CE',l_ctx_name, NULL);
            RETURN l_ret_ctx_end_xml;
        END load_ctx_xml_end_tag;

/****************************************************************************
    Name        : generate_xml_dummy
    Description : This procedure accept live data, converts it to XML
                  format and appends to pay_mag_tape.g_blob_value. This will
                  be used to generate XML for Check Writer (XML) when
                  Payroll Archive is NOT Run.
  *****************************************************************************/

PROCEDURE generate_xml_dummy(cp_check_no IN VARCHAR2
                            ,cp_account_name IN VARCHAR2
			    ,cp_account_no IN VARCHAR2
			    ,cp_account_typ IN VARCHAR2
			    ,cp_transit_no IN VARCHAR2
			    ,cp_bank_name IN VARCHAR2
			    ,cp_branch_name IN VARCHAR2
			    ,cp_employee_no IN VARCHAR2
			    ,cp_full_name IN VARCHAR2
			    ,cp_national_identifier IN VARCHAR2
			    ,p_xml_dummy_tab OUT NOCOPY pay_archive_chequewriter.ltr_char_tab_typ)
AS
	CURSOR get_flex_segment(cp_flex_ctx_code IN VARCHAR2)
	IS
	SELECT end_user_column_name
	  FROM fnd_descr_flex_col_usage_vl
	 WHERE descriptive_flexfield_name like 'Action Information DF'
	   and descriptive_flex_context_code = cp_flex_ctx_code
	   AND enabled_flag = 'Y';

	ltr_ctx_tag		pay_archive_chequewriter.ltr_char_tab_typ;
	ltr_xml_tab             pay_archive_chequewriter.ltr_char_tab_typ;

	i       NUMBER;
	cntr    NUMBER;
	xml_cntr NUMBER;
        l_segment_name   VARCHAR2(240);
        l_val            VARCHAR2(240);
BEGIN
    hr_utility.trace('Entering generate_xml_dummy');
    hr_utility.trace('cp_check_no := '|| cp_check_no);
    hr_utility.trace('cp_account_name := '|| cp_account_name);
    hr_utility.trace('cp_account_no := '|| cp_account_no);
    hr_utility.trace('cp_account_typ := '|| cp_account_typ);
    hr_utility.trace('cp_transit_no := '|| cp_transit_no);
    hr_utility.trace('cp_bank_name := '|| cp_bank_name);
    hr_utility.trace('cp_branch_name := '|| cp_branch_name);
    hr_utility.trace('cp_employee_no := '|| cp_employee_no);
    hr_utility.trace('cp_full_name := '|| cp_full_name);
    hr_utility.trace('cp_national_identifier := '|| cp_national_identifier);

    i := 1;
    ltr_ctx_tag(i) := 'EMPLOYEE DETAILS';
    i := i + 1;
    ltr_ctx_tag(i) := 'US FEDERAL';
    i := i + 1;
    ltr_ctx_tag(i) := 'AC DEDUCTIONS';
    i := i + 1;
    ltr_ctx_tag(i) := 'EMPLOYEE NET PAY DISTRIBUTION';
    i := i + 1;
    ltr_ctx_tag(i) := 'AC SUMMARY CURRENT';
    i := i + 1;
    ltr_ctx_tag(i) := 'AC EARNINGS';
    i := i + 1;
    ltr_ctx_tag(i) := 'EMPLOYEE HOURS BY RATE';
    i := i + 1;
    ltr_ctx_tag(i) := 'ADDRESS DETAILS';
    i := i + 1;
    ltr_ctx_tag(i) := 'US WITHHOLDINGS';
    i := i + 1;
    ltr_ctx_tag(i) := 'EMPLOYEE OTHER INFORMATION';
    i := i + 1;
    ltr_ctx_tag(i) := 'AC SUMMARY YTD';
    i := i + 1;
    ltr_ctx_tag(i) := 'US STATE';

    ltr_xml_tab(ltr_xml_tab.count() + 1) := load_ctx_xml_start_tag('CHEQUE');

    FOR cntr IN 1..i
    LOOP
       hr_utility.trace('ltr_ctx_tag(cntr) := '|| ltr_ctx_tag(cntr));

       ltr_xml_tab(ltr_xml_tab.count() + 1) := load_ctx_xml_start_tag(ltr_ctx_tag(cntr));

       IF ltr_ctx_tag(cntr) = 'EMPLOYEE DETAILS' THEN

        ltr_xml_tab(ltr_xml_tab.count() + 1) := load_segment_xml('CHECK_NUMBER',cp_check_no);
        ltr_xml_tab(ltr_xml_tab.count() + 1) := load_segment_xml('AMOUNT_IN_WORDS','XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
	ltr_xml_tab(ltr_xml_tab.count() + 1) := load_segment_xml('CHECK_AMOUNT','XXXXXXXXXXXX');
	ltr_xml_tab(ltr_xml_tab.count() + 1) := load_segment_xml('ACCOUNT_NAME',cp_account_name);
	ltr_xml_tab(ltr_xml_tab.count() + 1) := load_segment_xml('ACCOUNT_TYPE',cp_account_typ);
	ltr_xml_tab(ltr_xml_tab.count() + 1) := load_segment_xml('ACCOUNT_NUMBER',cp_account_no);
	ltr_xml_tab(ltr_xml_tab.count() + 1) := load_segment_xml('TRANSIT_CODE',cp_transit_no);
	ltr_xml_tab(ltr_xml_tab.count() + 1) := load_segment_xml('BANK_NAME',cp_bank_name);
	ltr_xml_tab(ltr_xml_tab.count() + 1) := load_segment_xml('BANK_BRANCH',cp_branch_name);
       END IF;

       OPEN get_flex_segment(ltr_ctx_tag(cntr));
       LOOP
           FETCH get_flex_segment INTO l_segment_name ;
	   hr_utility.trace('l_segment_name := ' || l_segment_name);
	   EXIT WHEN get_flex_segment%NOTFOUND;
	   l_val := NULL ;
	   IF ltr_ctx_tag(cntr) = 'EMPLOYEE DETAILS' THEN
	      IF UPPER(REPLACE(l_segment_name,' ' ,'_')) = 'EMPLOYEE_NUMBER' THEN
	         l_val := cp_employee_no;
	      ELSIF UPPER(REPLACE(l_segment_name,' ' ,'_')) = 'FULL_NAME' THEN
	         l_val := cp_full_name;
	      ELSIF UPPER(REPLACE(l_segment_name,' ' ,'_')) = 'NATIONAL_IDENTIFIER' THEN
	         l_val := cp_national_identifier;
              END IF;
	    END IF;
	    ltr_xml_tab(ltr_xml_tab.count() + 1) := load_segment_xml(l_segment_name, l_val);
       END LOOP;

       ltr_xml_tab(ltr_xml_tab.count() + 1) := load_ctx_xml_end_tag(ltr_ctx_tag(cntr));

       CLOSE get_flex_segment;
    END LOOP;
    ltr_xml_tab(ltr_xml_tab.count() + 1) := load_ctx_xml_end_tag('CHEQUE');
    p_xml_dummy_tab := ltr_xml_tab;

END generate_xml_dummy;

/****************************************************************************
    Name        : GENERATE_XML
    Description : This procedure fetches archived data, converts it to XML
                  format and appends to pay_mag_tape.g_blob_value. This will
                  be used to generate XML for Archive Cheque Writer Process
  *****************************************************************************/
PROCEDURE GENERATE_XML IS
    -- Fetching Legislation Code
    --
    CURSOR get_legislation_code(cp_chk_action_id in number) is
    SELECT pbg.legislation_code
    FROM   pay_payroll_actions ppa,
           pay_assignment_actions paa,
           per_business_groups pbg
    WHERE paa.assignment_action_id = cp_chk_action_id
    AND   paa.payroll_action_id = ppa.payroll_action_id
    AND   ppa.business_group_id = pbg.business_group_id;

    CURSOR get_action_status(cp_chk_action_id IN NUMBER) IS
    SELECT action_status
    FROM   pay_assignment_actions
    WHERE  assignment_action_id = cp_chk_action_id ;

    -- Fetching Assignment Action ID of the Payroll / Payslip Archive
    -- From the Assignment Action ID of Cheque Writer
    -- This cursor is to be used when Payroll / Payslip Archive
    -- Locks PrePayment. (Cheque Writer always locks PrePayment)

    CURSOR get_arch_asg_action_id(cp_chk_action_id in number,
                                  cp_legislation_code in varchar2) is
    SELECT pai_arch.locking_action_id
      FROM pay_action_interlocks pai_chk,
           pay_action_interlocks pai_arch,
           pay_assignment_actions paa_arch,
           pay_assignment_actions paa_chk,
           pay_pre_payments ppp,
           pay_payroll_actions ppa_arch,
           pay_payroll_actions ppa_chk,
           hr_lookups hrl
     WHERE pai_chk.locking_action_id = cp_chk_action_id

     --Pre-Payment Assignment Action ID is locked by both Check Writer
     --and Payroll Archive Process (It can be locked by NACHA as well)

       AND pai_arch.locked_action_id = pai_chk.locked_action_id
       AND paa_chk.assignment_action_id = pai_chk.locking_action_id
       AND paa_chk.payroll_action_id = ppa_chk.payroll_action_id
       AND ppa_chk.action_type = 'H'
       AND paa_chk.pre_payment_id = ppp.pre_payment_id
       AND (
        (ppp.source_action_id IS NOT NULL
        AND ppp.source_action_id = fnd_number.canonical_to_number(SUBSTR(paa_arch.serial_number, 3))
        AND (INSTR(paa_arch.serial_number, 'PY') <> 0
             or INSTR(paa_arch.serial_number, 'UY') <> 0)
        AND paa_arch.source_action_id IS NOT NULL)
        OR
        (ppp.source_action_id IS NULL
        AND ppp.assignment_action_id = fnd_number.canonical_to_number(SUBSTR(paa_arch.serial_number, 3))
        AND (INSTR(paa_arch.serial_number, 'PN') <> 0
             or INSTR(paa_arch.serial_number, 'UN') <> 0)
        AND paa_arch.source_action_id IS NULL)
          )
       AND paa_arch.assignment_action_id = pai_arch.locking_action_id
       AND ppa_arch.payroll_action_id = paa_arch.payroll_action_id
       AND ppa_arch.action_type = 'X'
       AND hrl.lookup_type = 'PAYSLIP_REPORT_TYPES'
       AND hrl.lookup_code = cp_legislation_code
       AND ppa_arch.report_type = hrl.meaning ;

    -- Fetching Assignment Action ID of the Payroll / Payslip Archive
    -- From the Assignment Action ID of Cheque Writer
    -- This cursor is to be used when Payroll / Payslip Archive
    -- Locks Payroll Run. (Cheque Writer always locks PrePayment)

    CURSOR get_arch_run_asg_action_id(cp_chk_action_id in number,
                                      cp_legislation_code in varchar2) is
    SELECT paa_arch.assignment_action_id
      FROM pay_action_interlocks pai_chk,
           pay_action_interlocks pai_prepay,
           pay_action_interlocks pai_arch,
           pay_assignment_actions paa_arch,
           pay_assignment_actions paa_prepay,
           pay_payroll_actions ppa_arch,
           pay_payroll_actions ppa_prepay,
           hr_lookups hrl
     WHERE pai_chk.locking_action_id = cp_chk_action_id
       AND pai_chk.locked_action_id = pai_prepay.locking_action_id
       AND pai_prepay.locking_action_id = paa_prepay.assignment_action_id
       AND paa_prepay.payroll_action_id = ppa_prepay.payroll_action_id
       AND ppa_prepay.action_type IN ('P','U')
       AND pai_prepay.locked_action_id = pai_arch.locked_action_id
       AND paa_arch.assignment_action_id = pai_arch.locking_action_id
       AND ppa_arch.payroll_action_id = paa_arch.payroll_action_id
       AND hrl.lookup_type = 'PAYSLIP_REPORT_TYPES'
       AND hrl.lookup_code = cp_legislation_code
       AND ppa_arch.report_type = hrl.meaning;

      --
      --
        CURSOR get_asssignment_id(cp_chk_asg_act_id IN NUMBER)
	IS
	SELECT DISTINCT assignment_id
	FROM   pay_assignment_actions
	WHERE  assignment_action_id = cp_chk_asg_act_id;

       --
       --
        CURSOR get_effective_date(cp_chk_asg_act_id IN NUMBER)
        IS
        SELECT ppa.effective_date
	      ,ppa.payroll_action_id
	FROM   pay_payroll_actions ppa
	      ,pay_assignment_actions paa
        WHERE  paa.assignment_action_id = cp_chk_asg_act_id
	AND    paa.payroll_action_id = ppa.payroll_action_id
	AND    ppa.action_type = 'H';

	CURSOR get_employee_details(p_assignment_id in number
				   ,p_effective_date in date)
	IS
	SELECT ppf.first_name
	,      ppf.last_name
	,      ppf.order_name
	,      ppf.full_name
	,      ppf.national_identifier
	,      ppf.employee_number
	,      pj.name
	,      hou.name
	,      paf.payroll_id
	,      prl.payroll_name
	,      ppf.middle_names
	,      ppf.title
	,      paf.assignment_number
	FROM   per_all_assignments_f paf
	,      per_all_people_f ppf
	,      per_periods_of_service pps
	,      per_jobs pj
	,      hr_organization_units hou
	,      pay_payrolls_f prl
	WHERE  paf.person_id = ppf.person_id
	and    paf.assignment_id = p_assignment_id
	AND    paf.job_id = pj.job_id(+)
	and    paf.organization_id = hou.organization_id
	and    prl.payroll_id=paf.payroll_id
	and    p_effective_date between paf.effective_start_date
				    and paf.effective_end_date
	and    p_effective_date between ppf.effective_start_date
				    and ppf.effective_end_date
	and    p_effective_date between prl.effective_start_date
				    and prl.effective_end_date
	and    pps.person_id = ppf.person_id
	and    pps.date_start = (select max(pps1.date_start)
				 from per_periods_of_service pps1
				 where pps1.person_id = paf.person_id
				 and   pps1.date_start <= p_effective_date);

        --
	--
	CURSOR get_action_details(cp_chk_asg_act_id IN NUMBER)
	IS
	SELECT nvl(paa.serial_number,'-9999')
	      ,substr(fnd_date.date_to_canonical(ppa.effective_date),1,10)
	      ,substr(nvl(fnd_date.date_to_canonical(ppa.overriding_dd_date),fnd_date.date_to_canonical(ppa.effective_date)),1,10)
	      ,ppa.payroll_action_id
	FROM  pay_assignment_actions paa,pay_payroll_actions ppa
	WHERE paa.assignment_action_id = cp_chk_asg_act_id
	AND   paa.payroll_action_id = ppa.payroll_action_id ;

        --
	--
	CURSOR get_org_bank_details(p_org_payment_method_id VARCHAR2,
				    p_effective_date date) IS
	SELECT pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_NAME', pea.territory_code),
               pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_BRANCH', pea.territory_code),
               pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_ACCOUNT_NAME', pea.territory_code),
               pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_ACCOUNT_NUMBER', pea.territory_code),
               pea.segment4,
	       pea.segment2
	FROM pay_org_payment_methods_f popm
	,    pay_external_accounts pea
	WHERE org_payment_method_id = p_org_payment_method_id
	AND   popm.external_account_id = pea.external_account_id
	AND   p_effective_date between popm.EFFECTIVE_START_DATE
				   and popm.EFFECTIVE_END_DATE;
        --
	CURSOR get_person_bank_details(p_per_pay_method   NUMBER
				      ,p_effective_date DATE)
	IS
	SELECT  pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_NAME', pea.territory_code),
	        pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_BRANCH', pea.territory_code),
	        pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_ACCOUNT_NAME', pea.territory_code),
	        pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_ACCOUNT_NUMBER', pea.territory_code),
                pea.segment4,
	        pea.segment2
	FROM pay_personal_payment_methods_f pppm
	,    pay_external_accounts pea
	WHERE pppm.personal_payment_method_id = p_per_pay_method
	AND   pppm.external_account_id = pea.external_account_id
	AND   p_effective_date between pppm.EFFECTIVE_START_DATE
				   and pppm.EFFECTIVE_END_DATE;
        --
        --
	CURSOR get_pay_meth(cp_chk_action_id IN NUMBER
	                   ,cp_chk_payroll_act_id IN NUMBER)
        IS
	SELECT ppp.payees_org_payment_method_id,
               ppp.personal_payment_method_id,
	       ppp.org_payment_method_id
	FROM   pay_pre_payments ppp
	,      pay_action_interlocks pai
	,      pay_assignment_actions paa
	,      pay_assignment_actions paa_chq
	,      pay_payroll_actions ppa
	,      pay_payroll_actions ppa_chq
	,      pay_org_payment_methods_f popm
	WHERE  paa_chq.assignment_action_id = cp_chk_action_id
	and paa_chq.assignment_action_id = pai.locking_action_id
	and pai.locked_action_id = paa.assignment_action_id
	and paa.payroll_action_id = ppa.payroll_action_id
	and ppp.assignment_action_id = paa.assignment_action_id
	and ppp.pre_payment_id = paa_chq.pre_payment_id
	and popm.org_payment_method_id = ppp.org_payment_method_id
	and ppa_chq.payment_type_id=popm.payment_type_id
	and (ppa_chq.org_payment_method_id is NULL
	     or
	     ppa_chq.org_payment_method_id = ppp.org_payment_method_id)
	and (ppa_chq.payroll_action_id = cp_chk_payroll_act_id)
	and ppa_chq.effective_date between popm.effective_start_date and popm.effective_end_date;


        ltr_xml_dummy_tab        pay_archive_chequewriter.ltr_char_tab_typ;
	l_first_name             per_all_people_f.first_name%TYPE;
	l_last_name              per_all_people_f.last_name%TYPE;
	l_order_name             per_all_people_f.order_name%TYPE;
	l_full_name              per_all_people_f.full_name%TYPE;
	l_national_identifier    per_all_people_f.national_identifier%TYPE;
	l_employee_number        per_all_people_f.employee_number%TYPE;
	l_middle_names           per_all_people_f.middle_names%TYPE;
	l_title                  per_all_people_f.title%TYPE;
	l_assignment_id          NUMBER;
	l_effective_date         DATE;
	l_payroll_name           pay_payrolls_f.payroll_name%TYPE;
	l_job                    per_jobs.name%TYPE;
	l_employer               hr_organization_units.name%TYPE;
	l_payroll_id             NUMBER;
	l_asg_num                per_all_assignments_f.assignment_number%TYPE;
        l_det_org_pay_method     NUMBER;
        l_per_pay_method         NUMBER;
        l_payee_meth_id          NUMBER;

	l_cheque_no              VARCHAR2(300);
	l_chq_effective_date     VARCHAR2(300);
	l_deposit_date           VARCHAR2(300);
	l_pactid                 NUMBER;

	l_bank_name              VARCHAR2(2000);
	l_branch_name            VARCHAR2(2000);
	l_account_name           VARCHAR2(2000);
	l_account_number         VARCHAR2(2000);
	l_transit_code           VARCHAR2(2000);
	l_account_typ            VARCHAR2(2000);
	lv_action_status         pay_assignment_actions.action_status%type;

        ln_chq_asg_action_id           NUMBER ;
        lv_legislation_code            per_business_groups.legislation_code%TYPE ;
        lv_full_name                   VARCHAR2(250);
        l_xml                          BLOB;
        ln_arch_assignment_action_id   NUMBER;
        l_proc_name                    varchar2(50) := 'pay_archive_chequewriter.generate_xml' ;
        l_xml_dummy                   BLOB;
        lr_xml_dummy                  RAW (32767);
        ln_amt_dummy                  NUMBER;
        dummy_xml                     BLOB;

BEGIN
    hr_utility.trace('Entering pay_archive_chequewriter.generate_xml');

    ln_chq_asg_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID');

    hr_utility.trace('ln_chq_asg_action_id := '||ln_chq_asg_action_id);

    OPEN get_action_status(ln_chq_asg_action_id);
    FETCH get_action_status INTO lv_action_status;
    CLOSE get_action_status;

    hr_utility.trace('Action Status before Generating XML := ' || lv_action_status);


    OPEN get_legislation_code(ln_chq_asg_action_id) ;
    FETCH get_legislation_code INTO lv_legislation_code ;
    CLOSE get_legislation_code ;

    hr_utility.trace('Legislation Code := '||lv_legislation_code) ;

    OPEN get_arch_asg_action_id(ln_chq_asg_action_id,
                                lv_legislation_code);

    FETCH get_arch_asg_action_id
    INTO  ln_arch_assignment_action_id;

    IF get_arch_asg_action_id%NOTFOUND THEN
       OPEN get_arch_run_asg_action_id(ln_chq_asg_action_id,
                                       lv_legislation_code);
       FETCH get_arch_run_asg_action_id
       INTO  ln_arch_assignment_action_id ;
       CLOSE get_arch_run_asg_action_id ;
    END IF ;

    CLOSE get_arch_asg_action_id ;

    hr_utility.trace('ln_arch_assignment_action_id := '||ln_arch_assignment_action_id);

    -- Setting Global Variable values
    pay_archive_chequewriter.g_chq_asg_action_id := ln_chq_asg_action_id;
    pay_archive_chequewriter.g_arch_asg_action_id := ln_arch_assignment_action_id;
    --
    --
    IF ln_arch_assignment_action_id IS NOT NULL THEN

	    pay_core_files.write_to_magtape_lob('<?xml version="1.0" encoding="'||hr_mx_utility.get_IANA_charset||'"?>');
	    pay_core_files.write_to_magtape_lob('<ARCHIVE_CHEQUE_WRITER>');

	    -- Printing Global Variable Values
	    --hr_utility.trace('g_chq_asg_action_id := '||pay_archive_chequewriter.g_chq_asg_action_id);
	    --hr_utility.trace('g_arch_asg_action_id := '||pay_archive_chequewriter.g_arch_asg_action_id);

	    pay_payroll_xml_extract_pkg.generate ( ln_arch_assignment_action_id , -- Action Context ID
						   null , -- Custom XML Procedure
						   'N' ,  -- Generate Header Flag (Y/N)
						   'CHEQUE', -- Root Tag : For Identifying Loc Specific Archived Data
						   'ARCHIVE_CHEQUE_WRITER', -- Document Type
						   l_xml );
	    write_to_magtape_lob(l_xml);

	    print_blob(pay_mag_tape.g_blob_value);

	    pay_core_files.write_to_magtape_lob('</ARCHIVE_CHEQUE_WRITER>');


    ELSE
         hr_utility.trace('ln_arch_assignment_action_id IS NULL.');

	 OPEN get_action_details(ln_chq_asg_action_id);
	 FETCH get_action_details INTO
	       l_cheque_no
	      ,l_chq_effective_date
	      ,l_deposit_date
	      ,l_pactid;
	 CLOSE get_action_details;

          hr_utility.trace('l_cheque_no := '|| l_cheque_no);

          OPEN get_asssignment_id(ln_chq_asg_action_id);
	  FETCH get_asssignment_id INTO l_assignment_id;
	  CLOSE get_asssignment_id;

	  OPEN get_effective_date(ln_chq_asg_action_id);
	  FETCH get_effective_date INTO l_effective_date
	                               ,l_pactid ;
	  CLOSE get_effective_date;

	  hr_utility.trace('l_effective_date := '|| TO_CHAR(l_effective_date,'DD-MON-YYYY'));

	  OPEN get_employee_details(l_assignment_id,l_effective_date);
	  FETCH get_employee_details INTO
	    l_first_name
	  , l_last_name
	  , l_order_name
	  , l_full_name
	  , l_national_identifier
	  , l_employee_number
	  , l_job
	  , l_employer
	  , l_payroll_id
	  , l_payroll_name
	  , l_middle_names
	  , l_title
	  , l_asg_num;
	  CLOSE get_employee_details;

	  hr_utility.trace('Before get_pay_meth');

	  OPEN get_pay_meth(ln_chq_asg_action_id,l_pactid);
	  FETCH get_pay_meth INTO l_payee_meth_id
                                 ,l_per_pay_method
	                         ,l_det_org_pay_method;
          CLOSE get_pay_meth;

         hr_utility.trace('Before Bank Details');

         if l_det_org_pay_method is not null then
	  OPEN get_org_bank_details(l_det_org_pay_method,l_effective_date);
	  FETCH get_org_bank_details INTO
	    l_bank_name
	   ,l_branch_name
	   ,l_account_name
	   ,l_account_number
	   ,l_transit_code
	   ,l_account_typ ;
	  CLOSE get_org_bank_details;
         elsif ( l_payee_meth_id IS NULL AND l_per_pay_method IS NOT NULL ) then
	  OPEN get_person_bank_details(l_per_pay_method,l_effective_date);
	  FETCH get_person_bank_details INTO
	    l_bank_name
	   ,l_branch_name
	   ,l_account_name
	   ,l_account_number
	   ,l_transit_code
	   ,l_account_typ ;
	  CLOSE get_person_bank_details;
         end if;

            hr_utility.trace('Before Archive Cheque');

	    pay_core_files.write_to_magtape_lob('<?xml version="1.0" encoding="'||hr_mx_utility.get_IANA_charset||'"?>');
	    pay_core_files.write_to_magtape_lob('<ARCHIVE_CHEQUE_WRITER>');

            hr_utility.trace('Calling generate_xml_dummy');

            generate_xml_dummy(l_cheque_no
                            ,l_account_name
			    ,l_account_number
			    ,l_account_typ
			    ,l_transit_code
			    ,l_bank_name
			    ,l_branch_name
			    ,l_employee_number
			    ,l_full_name
			    ,l_national_identifier
			    ,ltr_xml_dummy_tab) ;
            hr_utility.trace('After Calling generate_xml_dummy');

            dbms_lob.createTemporary(l_xml_dummy, true, dbms_lob.session);

            FOR cntr IN ltr_xml_dummy_tab.first()..ltr_xml_dummy_tab.last()
	    LOOP
                hr_utility.trace('Accessing..' || ltr_xml_dummy_tab(cntr));

		lr_xml_dummy := utl_raw.cast_to_raw(ltr_xml_dummy_tab(cntr));
		ln_amt_dummy := utl_raw.length(lr_xml_dummy);

		dbms_lob.writeAppend(l_xml_dummy,
				     ln_amt_dummy,
				     lr_xml_dummy);
            END LOOP;

            dummy_xml := l_xml_dummy;

            hr_utility.trace('Successful LOB Creation.');
            pay_core_files.write_to_magtape_lob(dummy_xml);

            pay_core_files.write_to_magtape_lob('</ARCHIVE_CHEQUE_WRITER>');

            BEGIN
		    UPDATE pay_assignment_actions
		    SET action_status = 'S'
		    WHERE assignment_action_id = ln_chq_asg_action_id;

            hr_utility.trace('Update Successful..');
	    EXCEPTION

	    WHEN OTHERS THEN
	      hr_utility.trace('Update Unsuccessful..');
	    END;
            print_blob(pay_mag_tape.g_blob_value);
            dbms_lob.freeTemporary(l_xml_dummy);

    END IF;

    hr_utility.trace('Leaving pay_archive_chequewriter.generate_xml');

EXCEPTION  WHEN OTHERS THEN
hr_utility.trace('SQLERRM := '||SQLERRM) ;
END GENERATE_XML ;

BEGIN
    g_proc_name := 'pay_archive_chequewriter';
    g_document_type := 'ARCHIVE_CHEQUE_WRITER';
    g_debug := hr_utility.debug_enabled;

END pay_archive_chequewriter;

/
