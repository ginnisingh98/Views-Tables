--------------------------------------------------------
--  DDL for Package Body PAY_CN_AUDIT_XMLGEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CN_AUDIT_XMLGEN" AS
/* $Header: pycnauxml.pkb 120.0.12010000.8 2010/05/26 17:27:03 dduvvuri noship $ */

/*
 ===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
 Name
                pay_cn_audit_xmlgen
 File
                pycnauxml.pkb
 Purpose

    The purpose of this package is to support the generation of XML for the process
    China Payroll Data Export.

 Date                 Author          Verion       Bug         Details
 ============================================================================
13-APR-2010           DDUVVURI         1.0        9469668      Initial file created
13-APR-2010           DDUVVURI         1.1        9469668      Resolved GSCC issues.
16-APR-2010           DDUVVURI         1.2        9469668      Modified cursor csr_assignments in procedure assact_xml to pick up
                                                               ptp.payroll_id instead of arch_ppa.payroll_id
26-APR-2010           DDUVVURI         1.3        9648944      Modified cursor csr_payroll_elements in procedure gen_xml_header_pay
                                                               and added 2 new cursors csr_arch_balances and csr_arch_stat_balances in
                                                               procedure assact_xml
27-APR-2010           DDUVVURI         1.4        9648944      Modified cursor csr_arch_balances to pick up balances which have
                                                               _ASG_PTD dimension only
12-May-2010           DDUVVURI         1.5        9696416      Modified issued found out post dev QA
                                                               1. modified header info for ministry
                                                               2. made formatting changes to Amount column in all cursors in PROCEDURE assact_xml
                                                               3. fixed issue of certain balances not being picked in CURSOR csr_arch_balances
                                                               4. fixed issues with exception report for SOE and Ministry
22-May-2010           DDUVVURI         1.6     9723217,9723261 Fixed all issues raised by QA
26-May-2010           DDUVVURI         1.7     9743013,9742923,9742617  Below are the issues fixed
                                                1. Formatting in amounts removed
                                                2. Exception Report for Ministry
                                                     - payroll name is also archived in action_information_5
                                                     - function get_message modified to add new parameter for payroll name
                                                3. Sorting in Group3 now on accounting period , payroll name , Employee number
                                                4. Sorting issues in Group4 corrected for multiple payrolls within
                                                   single period. Sorting in Group 4 is based on
                                                   Payroll Period number , Payroll Name , Employee number
                                                5. Issue of Balance not displayed if Display Value is entered at org level.

 ============================================================================
*/
--
-- Global Variables
--
    g_proc_name               VARCHAR2(240);
    g_debug                   BOOLEAN;
    g_document_type           VARCHAR2(50);
    EOL                       VARCHAR2(5) := fnd_global.local_chr(10);
    g_opt_soe_or_min          VARCHAR2(10);
    g_trfr_date_used          VARCHAR2(5);
    l_proc                    VARCHAR2(200);

/****************************************************************************
    Name        : get_message_text
    Description : This is called from inside the datatemplate query to
                  report missing data in audit report.
 *****************************************************************************/

FUNCTION get_message_text(p_act_info1 VARCHAR2,
                          p_act_info2 VARCHAR2,
			  p_act_info3 VARCHAR2,
			  p_act_info4 VARCHAR2,
			  p_act_info5 VARCHAR2) RETURN VARCHAR2
IS
l_text VARCHAR2(1000);
BEGIN
   l_proc :=  g_proc_name||'get_message_text';
   IF g_debug THEN
       hr_utility.trace( 'Entering '||l_proc);
   END IF;
   IF p_act_info3 = 'CN_EMP_CATEGORY' THEN
     fnd_message.set_name('PER', 'CN_EMP_CATEGORY');
     fnd_message.set_token('EMPNUM', p_act_info1);
     fnd_message.set_token('PERIOD', p_act_info2);
   ELSIF p_act_info3 ='CN_EXPENDITURE_CODE' THEN
     fnd_message.set_name('PER', 'CN_EXPENDITURE_CODE');
     fnd_message.set_token('ENAME', p_act_info4);
     fnd_message.set_token('PNAME', p_act_info5);

   END IF;

l_text :=  hr_utility.get_message();
   IF g_debug THEN
       hr_utility.trace( 'Leaving '||l_proc);
   END IF;
RETURN l_text;
END;

  /****************************************************************************
    Name        : RANGE_CURSOR
    Description : This procedure prepares range of persons to be processed for process
                  'China Payroll Data Extract'. This procedure defines a SQL statement
                  to fetch all the people to be included in the generic XML extract. This SQL
                  statement is  used to define the 'chunks' for multi-threaded operation
  Arguments
      p_pactid  payroll action id for the report
      p_sqlstr  the SQL statement to fetch the people
  *****************************************************************************/

PROCEDURE range_cursor ( p_pactid       IN      NUMBER,
                         p_sqlstr       OUT     nocopy VARCHAR2
                       )
IS

        p_year_start                    DATE;
        p_year_end                      DATE;
        p_business_group_id             NUMBER;
        l_file                          VARCHAR2(100);
BEGIN

l_proc :=  g_proc_name||'range_cursor';

   IF g_debug  THEN
     hr_utility.trace ('Entering '||l_proc);
   END IF ;

     p_sqlstr := 'SELECT DISTINCT person_id
                    FROM per_people_f ppf,
                         pay_payroll_actions ppa
                   WHERE ppa.payroll_action_id = :payroll_action_id
                     AND ppa.business_group_id +0 = ppf.business_group_id
                   ORDER BY ppf.person_id';

     initialization_code (p_pactid);

/* Commenting out below code as it is not required for some time now.
   We can use it in deinitialisation code later */
--     SELECT magnetic_file_name INTO l_file
--     FROM pay_payroll_actions
--     WHERE payroll_action_id = p_pactid;
--
--  IF l_file is NULL THEN
--     IF g_opt_soe_or_min IS NULL OR g_opt_soe_or_min = 'ENT' THEN
--        l_file := per_cn_shared_info.get_lookup_meaning('SOE_NAME','CN_AUDIT_DATA');
--     ELSE
--        l_file := per_cn_shared_info.get_lookup_meaning('PSM_NAME','CN_AUDIT_DATA');
--     END IF;
--
--          l_file := l_file || g_year || to_char(g_start_period) || to_char(g_end_period);
--
--         UPDATE pay_payroll_actions
--         SET magnetic_file_name = l_file
--         WHERE payroll_action_id = p_pactid;
--  END IF;

   IF g_debug  THEN
     hr_utility.trace ('Leaving '||l_proc);
   END IF ;

END range_cursor;
--

/****************************************************************************
    Name         : ACTION_CREATION
    Description  : This procedure creates assignment actions for the payroll action associated
                        process <China Payroll Data Extract>

                   The procedure processes assignments in 'chunks' to facilitate  multi-threaded
                   operation. The chunk is defined by the size and the starting and ending person id.

                   One assignment action is created for each payroll period for each assignment
		   Creates action for Group4 XML - Individual_Payroll_Detailed_Records
		   Best way is to do Group3 also in multithreaded level. But Sorting
		   requirements won't be met.

 *****************************************************************************/

PROCEDURE action_creation(
                        p_pactid        IN NUMBER,
                        p_stperson      IN NUMBER,
                        p_endperson     IN NUMBER,
                        p_chunk         IN NUMBER
                        )
IS
        -- Cursor to get the assignments Who were active for some period in the current year
        -- Auditing Interested only for employees paid in current year, so check that atleast it has one payroll run
	-- g_start_date AND  g_end_date are accounting period start and end
	-- Pick up payroll runs, use g_trfr_date_used to determine the accounting_date on which they will be posted
	-- Ensure those are within the accounting period range
        --
   CURSOR csr_assignments IS
   SELECT paf.assignment_id
     FROM per_people_f ppf,
          per_assignments_f paf,
          per_periods_of_service pos
    WHERE ppf.business_group_id = paf.business_group_id
      AND pos.period_of_service_id = paf.period_of_service_id
      AND paf.person_id =ppf.person_id
      AND paf.person_id BETWEEN p_stperson AND p_endperson
      AND  (
           g_end_date BETWEEN paf.effective_start_date AND paf.effective_end_date
           OR
           (
            pos.final_process_date  BETWEEN  g_start_date AND  g_end_date AND
            pos.final_process_date BETWEEN paf.effective_start_date AND paf.effective_end_date
           )
           )
      AND  (
           ( nvl(pos.final_process_date,g_end_date) >=  g_end_date
            AND g_end_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date)
           OR
           (
            pos.final_process_date  BETWEEN  g_start_date AND g_end_date AND
            pos.final_process_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
           )
           )
      AND ppf.business_group_id = g_bg_id
      AND paf.business_group_id =g_bg_id
      AND EXISTS (SELECT 1
                    FROM pay_payroll_actions ppa,
                         pay_assignment_actions paa
                   WHERE paa.assignment_id =paf.assignment_id
                     AND paa.payroll_action_id = ppa.payroll_action_id
                     AND ppa.action_type in('R','Q')
                     AND decode(g_trfr_date_used,'E',ppa.date_earned,ppa.effective_date) BETWEEN g_start_date AND  g_end_date
       );
        --
        --      LOCAL VARIABLES
        --
        l_actid NUMBER;


-- Group4 is sorted by payroll_period
-- so add 1 assignment_action_id for each distinct payroll period
-- ptp.regular_payment_date,ptp.period_num gives payroll year and period
-- Use this and populate serial_number
-- do not use accounting period to define serial_number
-- use serial number in sort_code to ensure XML sequence in output
-- 2010 01 Should come after 2009 12. So use period_num and year combination

CURSOR c_get_periods(p_assignment_id IN NUMBER) IS
select distinct(to_CHAR(ppa.effective_date,'YYYY')||TO_CHAR(ppa.effective_date,'MM')||ppf.payroll_id) pnum
  from pay_payroll_Actions ppa,
       pay_assignment_actions paa,
       pay_payrolls_f ppf
where paa.payroll_action_id = ppa.payroll_Action_id
  and ppa.action_type in('R','Q')
  and ppa.payroll_id = ppf.payroll_id
  and paa.assignment_id = p_assignment_id
  and paa.source_action_id is null
  and decode(g_trfr_date_used,'E',ppa.date_earned,ppa.effective_date)  BETWEEN g_start_date AND  g_end_date
  and g_end_date between ppf.effective_start_date and ppf.effective_end_date
    ORDER BY pnum;

--
BEGIN

l_proc :=  g_proc_name||'action_creation';

   IF g_debug  THEN
     hr_utility.trace ('Entering '||l_proc);
   END IF ;

IF g_bg_id IS NULL THEN
  initialization_code (p_pactid);
END IF;


   FOR i IN  csr_assignments LOOP
     IF g_debug  THEN
       hr_utility.trace (' Picking Assignment ID  '||i.assignment_id);
     END IF;

     FOR q IN c_get_periods(i.assignment_id) LOOP
       IF g_debug  THEN
         hr_utility.trace (' Picking Period NUmber '||q.pnum);
       END IF;

      SELECT pay_assignment_actions_s.NEXTVAL
        INTO   l_actid
        FROM   dual;


       hr_nonrun_asact.insact(l_actid,i.assignment_id,p_pactid,p_chunk,NULL);

       UPDATE pay_assignment_actions
          SET serial_number = q.pnum
        WHERE assignment_action_id = l_actid
          AND assignment_id = i.assignment_id
          AND payroll_action_id = p_pactid;

    END LOOP;
END LOOP;

   IF g_debug  THEN
     hr_utility.trace ('Leaving '||l_proc);
   END IF ;

END action_creation;

/****************************************************************************
    Name        : get_parameters
    Description : This procedure gets the token value of a token from the
                  legislative parameters string for a given payroll action id.
*****************************************************************************/
PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                         p_token_name        IN  VARCHAR2,
                         p_token_value       OUT  NOCOPY VARCHAR2)
  IS

    CURSOR csr_parameter_info(p_pact_id NUMBER)
    IS
    SELECT  legislative_parameters
           ,business_group_id
      FROM  pay_payroll_actions
     WHERE  payroll_action_id = p_pact_id;

    l_token_value VARCHAR2(150);
    l_bg_id       NUMBER;
    l_proc        VARCHAR2(100);
    l_message     VARCHAR2(255);
    l_param_string VARCHAR2(1000);
    start_ptr   NUMBER;
    end_ptr     NUMBER;
    token_val   pay_payroll_actions.legislative_parameters%TYPE;

  BEGIN

    l_proc  := g_proc_name||'get_parameters';

   IF g_debug  THEN
     hr_utility.trace ('Entering '||l_proc);
   END IF ;

    OPEN csr_parameter_info(p_payroll_action_id);
    FETCH csr_parameter_info INTO l_param_string,l_bg_id;
    CLOSE csr_parameter_info;

     token_val := p_token_name||'=';

     start_ptr := INSTR(l_param_string, token_val) + LENGTH(token_val);
     end_ptr := INSTR(l_param_string, ' ',start_ptr);

     IF end_ptr = 0 THEN
        end_ptr := LENGTH(l_param_string)+1;
     END IF;

     IF INSTR(l_param_string, token_val) = 0 THEN
       l_token_value := NULL;
     ELSE
       l_token_value := SUBSTR(l_param_string, start_ptr, end_ptr - start_ptr);
     END IF;

     p_token_value := TRIM(l_token_value);

    IF (p_token_name = 'BG_ID') THEN
        p_token_value := l_bg_id;
    END IF;

    IF (p_token_value IS NULL) THEN
         p_token_value := '%';
    END IF;

   IF g_debug  THEN
     hr_utility.trace ('Leaving '||l_proc);
   END IF ;

  END get_parameters;

--

/****************************************************************************
    Name        : generate_xml
    Description : This procedure fetches archived data, converts it to XML
                  format and appends to pay_mag_tape.g_BLOB_value.
*****************************************************************************/
PROCEDURE generate_xml AS
    l_old_assact_id                NUMBER;
    l_final_xml_string             BLOB;
    xml_string1                     VARCHAR2(2000);
    l_pact_id                         NUMBER;
    l_cur_pact                       NUMBER;
    l_legislative_parameters   VARCHAR(2000);
    l_cur_assact                   NUMBER ;
    l_proc_name                   VARCHAR2(60) ;
    l_offset                           NUMBER;
    l_amount                        NUMBER;
    l_count                         NUMBER;
--
BEGIN
   IF g_debug  THEN
    l_proc_name := g_proc_name || 'GENERATE_XML';
     hr_utility.trace ('Entering '||l_proc_name);
   END IF ;

   l_cur_assact := pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID' );
   l_cur_pact := pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID' );

  assact_xml(l_cur_assact);

 EXCEPTION
   WHEN no_data_found THEN
   hr_utility.trace ('exiting from loop');
--
   IF g_debug  THEN
     hr_utility.trace ('Leaving '||l_proc_name);
   END IF ;
END generate_xml;

/****************************************************************************
    Name        : initialization_code
    Description : This procedure initialises global values
                  We call it at the beginning of the archive
*****************************************************************************/

PROCEDURE initialization_code (p_payroll_action_id  IN NUMBER)
  IS
  --
    l_proc  VARCHAR2(100) ;
    l_message     VARCHAR2(255);
    l_chardate_start  VARCHAR2(255);
    l_chardate_end    VARCHAR2(255);
    l_tag varchar2(10);

    l_token_name    pay_in_utils.char_tab_type;
    l_token_value   pay_in_utils.char_tab_type;


  BEGIN
  --
    l_proc  :=  g_proc_name || 'initialization_code';

    if g_debug then
       hr_utility.trace ('Entering '||l_proc);
    end if ;

    g_payroll_action_id := p_payroll_action_id;
    get_parameters(p_payroll_action_id,'YR',g_year);
    get_parameters(p_payroll_action_id,'START_DATE',l_chardate_start);
    g_start_date := fnd_date.canonical_to_date(l_chardate_start);
    get_parameters(p_payroll_action_id,'END_DATE',l_chardate_end);
    g_end_date := fnd_date.canonical_to_date(l_chardate_end);
    get_parameters(p_payroll_action_id,'BG_ID',g_bg_id);
    get_parameters(p_payroll_action_id,'XML_REPORT_TAG',l_tag);

    set_globals;
    g_start_period := to_char(g_start_date,'MM');
    g_end_period   := to_char(g_end_date,'MM');



    if g_debug then
       hr_utility.trace ('YR  '||g_year);
       hr_utility.trace ('g_bg_id  '||g_bg_id);
       hr_utility.trace ('g_start_period  '||g_start_period);
       hr_utility.trace ('g_end_period '||g_end_period);
       hr_utility.trace ('g_start_date '||g_start_date);
       hr_utility.trace ('g_end_date '||g_end_date);
       hr_utility.trace ('XML REPORT TAG '||l_tag);
       hr_utility.trace ('SOE/MINISTRY Flag '||g_opt_soe_or_min);
       hr_utility.trace ('TGL Date Used '||g_trfr_date_used);
       hr_utility.trace ('Leaving '||l_proc);
    end if ;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END initialization_code;

  /****************************************************************************
    Name        : gen_xml_header_pay
    Description : This procedure generates XML header information and appends to
                  magtape lob
  *****************************************************************************/
PROCEDURE gen_xml_header_pay AS
    l_proc_name varchar2(100);
    l_buf      varchar2(2000);
--
/* Group1 - Payroll Periods */
/* Fetch payroll periods whose date_earned/regular_payment_date is between accounting reporting periods*/
/* Accounting date depends on g_trfr_date_used, hence the join*/
CURSOR csr_payroll_periods IS
SELECT to_char(ptp.period_num) pno,
       to_CHAR(ptp.start_date,'YYYYMMDD') strt,
       to_CHAR(ptp.end_date,'YYYYMMDD') ende,
       to_CHAR(ptp.regular_payment_date,'YYYY') yr
 FROM per_time_periods ptp,
     pay_payrolls_f ppf
WHERE ptp.payroll_id = ppf.payroll_id
  AND decode(g_trfr_date_used,'E',ptp.end_date,ptp.regular_payment_date) BETWEEN g_start_date and g_end_date
  AND EXISTS(SELECT 1
               FROM per_assignments_f paf
              WHERE paf.payroll_id = ppf.payroll_id
                AND paf.business_group_id = g_bg_id)
order by ppf.payroll_name,yr,ptp.period_num;

/* Group2 - Payroll Elements */
/* Fetch payroll elements from Org level Setup*/
CURSOR csr_payroll_elements IS
SELECT  DISTINCT pap.payroll_name   payroll_name,
        fnd_number.canonical_to_number(hoi.org_information3)   element_id,
        nvl(petl.reporting_name,petl.element_name) element_name,
	get_cost_alloc_key_flex(pap.payroll_id,hoi.org_information3) exp_cat_code
   FROM    hr_organization_information hoi
          ,hr_organization_units       hou
          ,pay_payrolls_f pap
          ,pay_element_types_f_tl petl
          ,pay_element_types_f pet
 WHERE hoi.org_information_context = 'PER_CNAO_ORG_INFO'
   AND hou.organization_id = hoi.organization_id
   AND hou.business_group_id = g_bg_id
   AND pap.payroll_id = fnd_number.canonical_to_number(hoi.org_information2)
   AND EXISTS (SELECT 1
                 FROM per_assignments_f paf
                WHERE paf.payroll_id = pap.payroll_id
		and paf.effective_end_date >= g_start_date
		and paf.effective_start_date <= g_end_date)
  AND EXISTS (SELECT 1
                 FROM per_assignments_f paf,
                      hr_soft_coding_keyflex scl
                WHERE paf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
                  AND scl.segment1 = hou.organization_id
                  AND paf.business_group_id = g_bg_id
                 )
   AND petl.element_type_id = fnd_number.canonical_to_number(hoi.org_information3)
   AND pet.element_type_id = petl.element_type_id
   AND petl.language = userenv('LANG')
   AND hou.date_from <= g_end_date
   AND NVL(hou.date_to,TO_DATE('4712/12/31','YYYY/MM/DD')) >= g_start_date
   AND g_end_date >= fnd_date.canonical_to_date(hoi.org_information4)
   AND g_start_date <= NVL(fnd_date.canonical_to_date(hoi.org_information5),TO_DATE('4712/12/31','YYYY/MM/DD'))
   AND g_end_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND g_end_date BETWEEN pap.effective_start_date AND pap.effective_end_date
UNION
SELECT  DISTINCT pap.payroll_name   payroll_name,
        fnd_number.canonical_to_number(hoi.org_information2)   element_id,
        nvl(PBT_TL.REPORTING_NAME,PBT_TL.BALANCE_NAME) element_name,
        'X' exp_cat_code
   FROM    hr_organization_information hoi
          ,hr_organization_units       hou
          ,pay_payrolls_f pap
          ,PAY_BALANCE_TYPES PBT, PAY_BALANCE_TYPES_TL PBT_TL
 WHERE hoi.org_information_context = 'PER_CNAO_BAL_INFO'
   AND hou.organization_id = hoi.organization_id
   AND hou.business_group_id = g_bg_id
   AND pap.payroll_id = fnd_number.canonical_to_number(hoi.org_information4)
   AND EXISTS (SELECT 1
                 FROM per_assignments_f paf
                WHERE paf.payroll_id = pap.payroll_id
		and paf.effective_end_date >= g_start_date
		and paf.effective_start_date <= g_end_date)
  AND EXISTS (SELECT 1
                 FROM per_assignments_f paf,
                      hr_soft_coding_keyflex scl
                WHERE paf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
                  AND scl.segment1 = hou.organization_id
                  AND paf.business_group_id = g_bg_id
                 )
   AND PBT_TL.balance_type_id = fnd_number.canonical_to_number(hoi.org_information2)
   AND PBT.balance_type_id = PBT_TL.balance_type_id
   AND PBT_TL.language = userenv('LANG')
   AND g_end_date BETWEEN fnd_date.canonical_to_date(hoi.org_information5) AND NVL(fnd_date.canonical_to_date(hoi.org_information6),TO_DATE('4712/12/31','YYYY/MM/DD'));


/* Group 3 Individual Payroll Records */
-- Group each assignment by payroll
CURSOR csr_asg IS
select min(paf.effective_start_date) start_date,
       max(paf.effective_end_date) end_date,
       paf.assignment_id asg_id,
       ppf.payroll_name  payr_name
from per_assignments_f paf,
     pay_payrolls_f ppf
where paf.effective_end_date >= g_start_date
  and paf.effective_start_date <=  g_end_date
  and paf.business_group_id = g_bg_id
  and paf.payroll_id = ppf.payroll_id
  and g_end_date between ppf.effective_start_date and ppf.effective_end_date
  group by paf.assignment_id,paf.assignment_number,ppf.payroll_name
order by ppf.payroll_name,paf.assignment_number,min(paf.effective_start_date);

l_asg_bulk csr_asg%ROWTYPE;

/* cursor to get lookup values based on lookup_type and lookup_code */
CURSOR get_lookup_values(p_type IN VARCHAR2, p_code IN VARCHAR2)
IS
  SELECT lookup_code,meaning FROM fnd_lookup_values
  WHERE lookup_type = p_type
  AND enabled_flag = 'Y'
  AND lookup_code LIKE p_code
  AND language = USERENV('LANG')
  ORDER BY lookup_code;

CURSOR get_payroll_id(p_payroll_name IN VARCHAR2)
IS
select distinct payroll_id
from pay_payrolls_f
where payroll_name = p_payroll_name;

  v_pay_prd tab_pay_prd;
  l_ctr NUMBER;
  flag NUMBER;
  rec_count NUMBER;
  v_ptp_rec ptp_rec;
  payrec tab_pay_prd_dis;
  result tab_pay_prd_dis;
  l_soe_header VARCHAR2(1000);
  l_min_header VARCHAR2(1000);
  l_action_info_id pay_action_information.action_information_id%TYPE;
  l_ovn  NUMBER;
  j NUMBER;
  i NUMBER;
  asgrec tab_asg_rec;
  ref_cur t_new_type_cur ;
  ref_rec t_new_type_rec;
  l_payroll_id NUMBER;

  l_head_trans1 VARCHAR2(100);
  l_head_trans2 VARCHAR2(100);

BEGIN
   IF g_debug THEN
     l_proc_name := g_proc_name || 'gen_xml_header_pay';
     hr_utility.trace ('Entering '||l_proc_name);
   END IF ;

     IF g_opt_soe_or_min IS NULL OR g_opt_soe_or_min ='ENT' THEN
      l_head_trans1 := per_cn_shared_info.get_lookup_meaning('HEADER_1','CN_SOE_LABELS');
      l_head_trans2 := per_cn_shared_info.get_lookup_meaning('HEADER_2','CN_SOE_LABELS');
      l_soe_header := l_head_trans1||' xsi:schemaLocation="http://sxbw.audit.gov.cn/AccountingSoftwareDataInterfaceStandard/2010/SOE/XMLSchema '||
           l_head_trans1||'.xsd" xmlns:'||l_head_trans2||
           '="http://sxbw.audit.gov.cn/AccountingSoftwareDataInterfaceStandard/2010/SOE/XMLSchema" xmlns="http://sxbw.audit.gov.cn/AccountingSoftwareDataInterfaceStandard/2010/SOE/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';
      load_xml_internal('SG',l_soe_header,null);
     ELSE
      l_head_trans1 := per_cn_shared_info.get_lookup_meaning('HEADER_1','CN_MINISTRY_LABELS');
      l_head_trans2 := per_cn_shared_info.get_lookup_meaning('HEADER_2','CN_MINISTRY_LABELS');
      l_min_header := l_head_trans1||' xsi:schemaLocation="http://sxbw.audit.gov.cn/AccountingSoftwareDataInterfaceStandard/2010/PSGA/XMLSchema '||
         l_head_trans1||'.xsd" xmlns:'||l_head_trans2||
         '="http://sxbw.audit.gov.cn/AccountingSoftwareDataInterfaceStandard/2010/PSGA/XMLSchema" xmlns="http://sxbw.audit.gov.cn/AccountingSoftwareDataInterfaceStandard/2010/PSGA/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';
      load_xml_internal('SG',l_min_header,null);
     END IF;

   l_ctr := 0;

   OPEN csr_payroll_periods;
   FETCH csr_payroll_periods BULK COLLECT INTO payrec;
   CLOSE csr_payroll_periods;

   l_ctr := 0;
   flag := 0;
    FOR i in payrec.FIRST .. payrec.LAST LOOP
         flag := 0;
       FOR j in 0 .. l_ctr-1 LOOP
         if (payrec(i).p_num = result(j).p_num and payrec(i).p_start = result(j).p_start and
            payrec(i).p_end = result(j).p_end and payrec(i).p_year = result(j).p_year) then
              flag := 1;
              EXIT;
         END IF;
       END LOOP;
      if flag <> 1 then
      result(l_ctr).p_num := payrec(i).p_num;
      result(l_ctr).p_start := payrec(i).p_start;
      result(l_ctr).p_end := payrec(i).p_end;
      result(l_ctr).p_year := payrec(i).p_year;
      l_ctr := l_ctr + 1;
      end if;
    END LOOP;

   /* Below code to add Payroll information to the XML */
    FOR p IN result.FIRST .. result.LAST LOOP
         load_xml_internal('SG', g_pay_prd(0).p_meaning , NULL);
         load_xml_internal('CG', g_pay_prd(1).p_meaning , result(p).p_year);
         load_xml_internal('CG', g_pay_prd(2).p_meaning , result(p).p_num);
         load_xml_internal('CG', g_pay_prd(3).p_meaning , result(p).p_start);
         load_xml_internal('CG', g_pay_prd(4).p_meaning , result(p).p_end);
         load_xml_internal('EG', g_pay_prd(0).p_meaning , NULL);
    END LOOP;

   /* Below code to add Element information to the XML */

    result.DELETE;
    payrec.DELETE;
    l_ctr := 0;

   for j in csr_payroll_elements LOOP
        load_xml_internal('SG', g_pay_ele(0).p_meaning , NULL);
        load_xml_internal('CG', g_pay_ele(1).p_meaning , j.payroll_name);
        load_xml_internal('CG', g_pay_ele(2).p_meaning , j.element_id);
        load_xml_internal('CG', g_pay_ele(3).p_meaning , j.element_name);
        IF g_opt_soe_or_min = 'NPG' THEN
           IF j.exp_cat_code IS NULL THEN

                pay_action_information_api.create_action_information
                (p_action_context_id              =>     g_payroll_action_id
                ,p_action_context_type            =>     'PA'
                ,p_action_information_category    =>     'CN_AUDIT_MESSAGES'
                ,p_action_information3            =>     'CN_EXPENDITURE_CODE'
                ,p_action_information4            =>     j.element_name
		,p_action_information5            =>     j.payroll_name
                ,p_action_information_id          =>     l_action_info_id
                ,p_object_version_number          =>     l_ovn
                );

                load_xml_internal('CG', g_pay_ele(4).p_meaning , per_cn_shared_info.get_lookup_meaning('NODATA','CN_AUDIT_DATA'));
           ELSE
              IF j.exp_cat_code = 'X' THEN
                load_xml_internal('CG', g_pay_ele(4).p_meaning , NULL);
              ELSE
                load_xml_internal('CG', g_pay_ele(4).p_meaning , j.exp_cat_code);
              END IF;
           END IF;

        END IF;
        load_xml_internal('EG', g_pay_ele(0).p_meaning , null);
   END LOOP;

    v_pay_prd.DELETE;
    v_ptp_rec.DELETE;
    l_ctr := 0;

OPEN csr_asg;
FETCH csr_asg BULK COLLECT INTO asgrec;
CLOSE csr_asg;


FOR q in g_start_period..g_end_period LOOP
for i in asgrec.first..asgrec.last LOOP

  OPEN get_payroll_id(asgrec(i).payr_name);
  FETCH get_payroll_id INTO l_payroll_id;
  CLOSE get_payroll_id;

IF g_trfr_date_used = 'E' THEN
     OPEN_CSR_ASG_QUERY_DE(asgrec(i).start_date,asgrec(i).end_date,asgrec(i).asg_id,l_payroll_id,q,ref_cur);
ELSE
     OPEN_CSR_ASG_QUERY_DP(asgrec(i).start_date,asgrec(i).end_date,asgrec(i).asg_id,l_payroll_id,q,ref_cur);
END IF;

LOOP
   FETCH ref_cur INTO ref_rec;
   IF ref_cur%NOTFOUND THEN
      CLOSE ref_cur;
      EXIT;
   END IF;
         if ref_rec.asg_cat is null AND g_opt_soe_or_min ='ENT' then

     pay_action_information_api.create_action_information
                (p_action_context_id              =>     g_payroll_action_id
                ,p_action_context_type            =>     'PA'
                ,p_action_information_category    =>     'CN_AUDIT_MESSAGES'
                ,p_assignment_id                  =>     asgrec(i).asg_id
                ,p_action_information1            =>     ref_rec.eno
                ,p_action_information2            =>     ref_rec.pno
                ,p_action_information3            =>     'CN_EMP_CATEGORY'
                ,p_action_information_id          =>     l_action_info_id
                ,p_object_version_number          =>     l_ovn
                );
             hr_utility.trace('Emp Cat Code for '||ref_rec.eno||' for period '||ref_rec.accnt_prd);
          end if;
        load_xml_internal('SG', g_ind_asg(0).p_meaning , null);
        load_xml_internal('CG', g_ind_asg(1).p_meaning , ref_rec.eno);
        IF g_opt_soe_or_min IS NULL OR g_opt_soe_or_min ='ENT' THEN
            load_xml_internal('CG', g_ind_asg(2).p_meaning , nvl(ref_rec.asg_cat,per_cn_shared_info.get_lookup_meaning('NODATA','CN_AUDIT_DATA')));
        ELSE
            load_xml_internal('CG', g_ind_asg(2).p_meaning , ref_rec.emp_name);
        END IF;
        load_xml_internal('CG', g_ind_asg(3).p_meaning , ref_rec.asg_org_id);
        load_xml_internal('CG', g_ind_asg(4).p_meaning , ref_rec.pname);
        load_xml_internal('CG', g_ind_asg(5).p_meaning , ref_rec.yr);
        load_xml_internal('CG', g_ind_asg(6).p_meaning , ref_rec.pno);
        load_xml_internal('CG', g_ind_asg(7).p_meaning , ref_rec.acct_yr);
        load_xml_internal('CG', g_ind_asg(8).p_meaning , ref_rec.accnt_prd);
        load_xml_internal('CG', g_ind_asg(9).p_meaning , ref_rec.currency);
        load_xml_internal('EG', g_ind_asg(0).p_meaning , null);
END LOOP;
  END LOOP;
END LOOP;
   if g_debug then
     hr_utility.trace ('Leaving '||l_proc_name);
   end if ;

END gen_xml_header_pay;

  /****************************************************************************
    Name         : gen_xml_footer
    Desc         : Footer
  *****************************************************************************/
PROCEDURE gen_xml_footer AS
  l_buf  varchar2(2000) ;
  l_proc_name varchar2(100);
  l_head_trans1 VARCHAR2(1000);
BEGIN
    if g_debug  then
      l_proc_name := g_proc_name || 'gen_xml_footer';
      hr_utility.trace ('Entering '||l_proc_name);
    end if ;
--
     IF g_opt_soe_or_min IS NULL OR g_opt_soe_or_min ='ENT' THEN
       l_head_trans1 := per_cn_shared_info.get_lookup_meaning('HEADER_1','CN_SOE_LABELS');
       load_xml_internal('EG',l_head_trans1,null);
     ELSE
       l_head_trans1 := per_cn_shared_info.get_lookup_meaning('HEADER_1','CN_MINISTRY_LABELS');
       load_xml_internal('EG',l_head_trans1,null);
     END IF;
    if g_debug then
      hr_utility.trace ('Leaving '||l_proc_name);
   end if ;

END gen_xml_footer;

/****************************************************************************
    Name        : assact_xml
    Arguments   : p_assignment_action_id
    Description : This procedure creates xml for the assignment_action_id passed
                  as parameter. It then writes the xml into magtape lob
		  We know the accounting period and assignment.
		  Get payroll runs in this accounting period
		  Use payslip archive data to report the values
*****************************************************************************/
PROCEDURE assact_xml(p_assignment_action_id  IN NUMBER) IS

-- p_pprd_num is payroll period .So always use ptp.regular_payment_date in join
-- Get payslip archive id that locks payroll runs whose time_period_id maps to the chosen payroll period\
-- MULTIPLE PAYROLLS and single archive - issue may come
CURSOR csr_assignments(p_assignment_id IN NUMBER,
                       p_pprd_num IN varchar2,
		       p_pyear IN varchar2,
		       p_payroll_id IN NUMBER) IS
select arch_paa.assignment_action_id asg_action_id ,
       ppa.payroll_id payroll_id,
       ppa.date_earned earn_date,
       ppa.effective_date eff_date
  from pay_payroll_actions arch_ppa,
       pay_assignment_actions arch_paa,
       pay_action_interlocks intl,
       pay_payroll_Actions ppa,
       pay_assignment_actions paa
where arch_paa.assignment_action_id = intl.locking_action_id
  and arch_paa.payroll_Action_id = arch_ppa.payroll_action_id
  and arch_paa.source_action_id is not null
  and arch_ppa.action_type='X'
  and ARCH_ppa.report_type='CN_PAYSLIP_ARCHIVE'
  and arch_paa.assignment_id = p_assignment_id
  and intl.locked_action_id = paa.assignment_action_id
  and  paa.payroll_action_id = ppa.payroll_Action_id
  and ppa.action_type in('R','Q')
  and ppa.payroll_id = p_payroll_id
  and paa.assignment_id = p_assignment_id
  and paa.source_action_id is null
  and to_number(to_char(ppa.effective_date,'MM')) = p_pprd_num
  and to_number(to_char(ppa.effective_date,'YYYY')) = p_pyear
  order by payroll_id,asg_action_id;

-- Archive element details
CURSOR csr_arch_elements(p_assignment_id IN NUMBER,
			 p_payroll_id IN NUMBER,
			 p_action_context_id IN NUMBER,
			 p_date_earned IN DATE,
			 p_effective_date IN DATE) IS
select person.employee_number eno,
       pname.payroll_name pay_name,
       to_char(p_effective_date,'YYYY') pyear,
       to_number(to_char(p_effective_date,'MM')) pnum,
       pet.element_type_id eid,
       to_char(fnd_number.canonical_to_number(pai.action_information5),'999999999.99') current_amount
  from pay_action_information pai,
       (select pap.payroll_name
          from pay_all_payrolls_f pap
	 where pap.payroll_id = p_payroll_id
           AND g_end_date BETWEEN pap.effective_start_date AND pap.effective_end_date) pname,
       (SELECT ppf.employee_number
          FROM per_all_people_f ppf,
	       per_all_assignments_f paf
	 WHERE paf.person_id = ppf.person_id
	   AND paf.assignment_id = p_assignment_id
	   AND p_date_earned BETWEEN ppf.effective_start_date and ppf.effective_end_date
	   AND p_date_earned BETWEEN paf.effective_start_date and paf.effective_end_date) person,
       hr_organization_information hoi,
       hr_organization_units       hou,
       pay_element_types_f_tl petl,
       pay_element_types_f pet
 where action_context_id = p_action_context_id
   and pai.action_information_category = 'APAC ELEMENTS'
   and pai.action_information1 = nvl(petl.reporting_name,petl.element_name)
   and hoi.org_information_context = 'PER_CNAO_ORG_INFO'
   AND hou.organization_id = hoi.organization_id
   AND hou.business_group_id = g_bg_id
   AND hoi.org_information2 = p_payroll_id
   and petl.element_type_id = hoi.org_information3
   and pet.element_type_id = petl.element_type_id
   and petl.language = userenv('LANG')
   AND g_end_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('4712/12/31','YYYY/MM/DD'))
   AND g_end_date BETWEEN fnd_date.canonical_to_date(hoi.org_information4) AND NVL(fnd_date.canonical_to_date(hoi.org_information5),TO_DATE('4712/12/31','YYYY/MM/DD'))
   AND g_end_date BETWEEN pet.effective_start_date AND pet.effective_end_date;

-- Archive Other balance details
CURSOR csr_arch_balances(p_assignment_id IN NUMBER,
			 p_payroll_id IN NUMBER,
			 p_action_context_id IN NUMBER,
			 p_date_earned IN DATE,
			 p_effective_date IN DATE) IS
select person.employee_number eno,
       pname.payroll_name pay_name,
       to_char(p_effective_date,'YYYY') pyear,
       to_number(to_char(p_effective_date,'MM')) pnum,
       pbt.balance_type_id eid,
       to_char(fnd_number.canonical_to_number(pai.action_information6),'999999999.99') current_amount
  from pay_action_information pai,
       (select pap.payroll_name
          from pay_all_payrolls_f pap
	 where pap.payroll_id = p_payroll_id
           AND g_end_date BETWEEN pap.effective_start_date AND pap.effective_end_date) pname,
       (SELECT ppf.employee_number
          FROM per_all_people_f ppf,
	       per_all_assignments_f paf
	 WHERE paf.person_id = ppf.person_id
	   AND paf.assignment_id = p_assignment_id
	   AND p_date_earned BETWEEN ppf.effective_start_date and ppf.effective_end_date
	   AND p_date_earned BETWEEN paf.effective_start_date and paf.effective_end_date) person,
       hr_organization_information hoi,
       hr_organization_units       hou,
       PAY_BALANCE_TYPES PBT, PAY_BALANCE_TYPES_TL PBT_TL
 where action_context_id = p_action_context_id
   and pai.action_information_category = 'EMPLOYEE OTHER INFORMATION'
   and pai.action_information4 = (select nvl(h.ORG_INFORMATION7,PBT_TL.BALANCE_NAME)
			       from hr_organization_information h
			       where h.org_information_context = 'Business Group:Payslip Info'
		               and h.organization_id = g_bg_id
		               and h.ORG_INFORMATION1 = 'BALANCE'
	                       and h.ORG_INFORMATION4 = PBT_TL.BALANCE_TYPE_ID
                	       and h.ORG_INFORMATION5 = (select pbd.balance_dimension_id
			                                 from pay_balance_dimensions pbd
							 where legislation_code = 'CN'
							 and dimension_name = '_ASG_PTD')
                       	        )
   and pai.action_information5 = 'ASG_PTD'
   and hoi.org_information_context = 'PER_CNAO_BAL_INFO'
   AND hou.organization_id = hoi.organization_id
   AND hou.business_group_id = g_bg_id
   AND hoi.org_information4 = p_payroll_id
   and PBT_TL.balance_type_id = hoi.org_information2
   and PBT.balance_type_id = PBT_TL.balance_type_id
   and PBT_TL.language = userenv('LANG')
   AND g_end_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('4712/12/31','YYYY/MM/DD'))
   AND g_end_date BETWEEN fnd_date.canonical_to_date(hoi.org_information5) AND NVL(fnd_date.canonical_to_date(hoi.org_information6),TO_DATE('4712/12/31','YYYY/MM/DD'));

-- Archive Statutory balance details
CURSOR csr_arch_stat_balances(p_assignment_id IN NUMBER,
			 p_payroll_id IN NUMBER,
			 p_action_context_id IN NUMBER,
			 p_date_earned IN DATE,
			 p_effective_date IN DATE) IS
select person.employee_number eno,
       pname.payroll_name pay_name,
       to_char(p_effective_date,'YYYY') pyear,
       to_number(to_char(p_effective_date,'MM')) pnum,
       pbt.balance_type_id eid,
       to_char(fnd_number.canonical_to_number(pai.action_information5),'999999999.99') current_amount
  from pay_action_information pai,
       (select pap.payroll_name
          from pay_all_payrolls_f pap
	 where pap.payroll_id = p_payroll_id
           AND g_end_date BETWEEN pap.effective_start_date AND pap.effective_end_date) pname,
       (SELECT ppf.employee_number
          FROM per_all_people_f ppf,
	       per_all_assignments_f paf
	 WHERE paf.person_id = ppf.person_id
	   AND paf.assignment_id = p_assignment_id
	   AND p_date_earned BETWEEN ppf.effective_start_date and ppf.effective_end_date
	   AND p_date_earned BETWEEN paf.effective_start_date and paf.effective_end_date) person,
       hr_organization_information hoi,
       hr_organization_units       hou,
       PAY_BALANCE_TYPES PBT, PAY_BALANCE_TYPES_TL PBT_TL
 where action_context_id = p_action_context_id
   and pai.action_information_category = 'APAC BALANCES'
   and pai.action_information1 = nvl(PBT_TL.REPORTING_NAME,PBT_TL.BALANCE_NAME)
   and hoi.org_information_context = 'PER_CNAO_BAL_INFO'
   AND hou.organization_id = hoi.organization_id
   AND hou.business_group_id = g_bg_id
   AND hoi.org_information4 = p_payroll_id
   and PBT_TL.balance_type_id = hoi.org_information2
   and PBT.balance_type_id = PBT_TL.balance_type_id
   and PBT_TL.language = userenv('LANG')
   AND g_end_date BETWEEN hou.date_from AND NVL(hou.date_to,TO_DATE('4712/12/31','YYYY/MM/DD'))
   AND g_end_date BETWEEN fnd_date.canonical_to_date(hoi.org_information5) AND NVL(fnd_date.canonical_to_date(hoi.org_information6),TO_DATE('4712/12/31','YYYY/MM/DD'));

CURSOR get_lookup_values(p_type IN VARCHAR2, p_code IN VARCHAR2)
IS
  select lookup_code,meaning from fnd_lookup_values
  where lookup_type = p_type
  and enabled_flag = 'Y'
  and lookup_code like p_code
  and language = userenv('lang')
  order by lookup_code;

--Variables-----
 l_common_xml    VARCHAR2(4000);
 l_xml_begin     VARCHAR2(200);
 l_xml2          VARCHAR2(40);
 l_mag_asg_action_id   pay_assignment_actions.assignment_action_id%TYPE;
 l_assignment_id number;
 l_serial_number varchar2(500);
 l_pact number;
 l_ctr number;
 isdf_emp_c csr_assignments%ROWTYPE;
 v_pay_prd tab_pay_prd;
 l_year VARCHAR2(40);
 l_period number;
 l_assact_id number;
l_payr_id number;


BEGIN

  select assignment_id,payroll_action_id,serial_number
  into l_assignment_id,l_pact,l_serial_number
  from
  pay_assignment_Actions
  where assignment_Action_id = p_assignment_action_id;

  IF g_year IS NULL then
   initialization_code(l_pact);
  END IF;

-- l_serial_number is combination of payroll year + payroll period
 l_year :=  SUBSTR(l_serial_number,1,4);
 l_period := SUBSTR(l_serial_number,5,2);
 l_payr_id := to_number(substr(l_serial_number,7));


    FOR i IN csr_assignments(l_assignment_id,l_period,l_year,l_payr_id) LOOP

        hr_utility.trace('Payroll YearPeriod for assignment action'||l_serial_number);
        if(l_assact_id is  null or  l_assact_id <> i.asg_action_id) then

        FOR j in  csr_arch_elements(l_assignment_id,i.payroll_id, i.asg_action_id,i.earn_date,i.eff_date) LOOP
        hr_utility.trace('XML elements being created for assignment_id id '||l_assignment_id);
        hr_utility.trace('Period for assignment action'||l_period);

        load_xml_internal('SG',g_ind_detail(0).p_meaning,NULL);
        load_xml_internal('CG',g_ind_detail(1).p_meaning,j.eno);
        load_xml_internal('CG',g_ind_detail(2).p_meaning,j.pay_name);
        load_xml_internal('CG',g_ind_detail(3).p_meaning,j.pyear);
        load_xml_internal('CG',g_ind_detail(4).p_meaning,j.pnum);
        load_xml_internal('CG',g_ind_detail(5).p_meaning,j.eid);
        load_xml_internal('CG',g_ind_detail(6).p_meaning,j.current_amount);
        load_xml_internal('EG',g_ind_detail(0).p_meaning,NULL);
        l_assact_id := i.asg_action_id;

       END LOOP;
        FOR k in  csr_arch_balances(l_assignment_id,i.payroll_id, i.asg_action_id,i.earn_date,i.eff_date) LOOP
        hr_utility.trace('XML balances being created for assignment_id id '||l_assignment_id);
        hr_utility.trace('Period for assignment action'||l_period);

        load_xml_internal('SG',g_ind_detail(0).p_meaning,NULL);
        load_xml_internal('CG',g_ind_detail(1).p_meaning,k.eno);
        load_xml_internal('CG',g_ind_detail(2).p_meaning,k.pay_name);
        load_xml_internal('CG',g_ind_detail(3).p_meaning,k.pyear);
        load_xml_internal('CG',g_ind_detail(4).p_meaning,k.pnum);
        load_xml_internal('CG',g_ind_detail(5).p_meaning,k.eid);
        load_xml_internal('CG',g_ind_detail(6).p_meaning,k.current_amount);
        load_xml_internal('EG',g_ind_detail(0).p_meaning,NULL);
        l_assact_id := i.asg_action_id;

       END LOOP;

        FOR x in  csr_arch_stat_balances(l_assignment_id,i.payroll_id, i.asg_action_id,i.earn_date,i.eff_date) LOOP
        hr_utility.trace('XML stat balances being created for assignment_id id '||l_assignment_id);
        hr_utility.trace('Period for assignment action'||l_period);

        load_xml_internal('SG',g_ind_detail(0).p_meaning,NULL);
        load_xml_internal('CG',g_ind_detail(1).p_meaning,x.eno);
        load_xml_internal('CG',g_ind_detail(2).p_meaning,x.pay_name);
        load_xml_internal('CG',g_ind_detail(3).p_meaning,x.pyear);
        load_xml_internal('CG',g_ind_detail(4).p_meaning,x.pnum);
        load_xml_internal('CG',g_ind_detail(5).p_meaning,x.eid);
        load_xml_internal('CG',g_ind_detail(6).p_meaning,x.current_amount);
        load_xml_internal('EG',g_ind_detail(0).p_meaning,NULL);
        l_assact_id := i.asg_action_id;

       END LOOP;

       end if;
    END LOOP;

 END assact_xml;

/****************************************************************************
    Name        : load_xml_internal
    Arguments   : p_node_type ( starting tag / ending tag / centre data )
                  p_node ( Node name )
                  p_data ( Node Value = NULL for starting and ending tags)
    Description : This procedure writes the xml tag and its value to magtape lob
*****************************************************************************/

PROCEDURE load_xml_internal ( p_node_type     IN    VARCHAR2
                               ,p_node         IN     VARCHAR2
                               ,p_data         IN     VARCHAR2) IS
    l_proc_name VARCHAR2(100);
    l_data      VARCHAR2(240);
    l_xml       VARCHAR2(1000);
    l_node varchar2(2000);

  BEGIN
    l_proc_name := g_proc_name || 'LOAD_XML_INTERNAL';

    IF g_debug THEN
         hr_utility.trace ('Entering '||l_proc_name);
    END IF;

    IF p_node_type = 'ROOT' THEN

        l_xml := '<![CDATA['||p_node||']]>'||EOL;

    ELSIF p_node_type = 'SG' THEN

        l_xml := '<'||p_node||'>'||EOL;

    ELSIF p_node_type = 'EG' THEN

        l_xml := '</'||p_node||'>'||EOL;

    ELSIF p_node_type = 'CG' THEN

        /* Handle special charaters in node value */
        l_data := REPLACE (p_data, '&', '&amp;');
        l_data := REPLACE (l_data, '>', '&gt;');
        l_data := REPLACE (l_data, '<', '&lt;');
        l_data := REPLACE (l_data, '''', '&apos;');
        l_data := REPLACE (l_data, '"', '&quot;');
        l_xml  := '<'||p_node||'>'||l_data||'</'||p_node||'>'||EOL;

    END IF;

    pay_core_files.write_to_magtape_lob(l_xml);

    IF g_debug THEN
         hr_utility.trace ('Leaving '||l_proc_name);
         hr_utility.trace ('XML Data being written is '||l_xml);
    END IF;

  END load_xml_internal;

/****************************************************************************
    Name        : set_globals
    Description : This procedure sets the values of certain globals which will
                  be used during the archive process multiple times. Following
                  are the globals  which will be set:
                1. Global to check if Date Earned/Date Paid is used for Ledger Transfer
                2. Global to check if Auditing is for SOE / MINISTRY
                3. Global table to store SOE/MINISTRY XML Tags for all the 4 groups
*****************************************************************************/

PROCEDURE set_globals IS

CURSOR csr_transfer_to_gl_date IS
SELECT parameter_value
  FROM pay_action_parameters
 WHERE parameter_name ='TGL_DATE_USED';

CURSOR gen_xml_opt_soe_min
IS
   SELECT  hoi.org_information16
   FROM    hr_organization_information hoi
          ,hr_organization_units       hou
   WHERE    hoi.org_information_context = 'PER_CORPORATE_INFO_CN'
   AND hou.organization_id = hoi.organization_id
   AND hou.business_group_id = g_bg_id
   AND EXISTS (SELECT 1
                 FROM per_assignments_f paf,
                      hr_soft_coding_keyflex scl
                 WHERE paf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
                 AND scl.segment1 = hou.organization_id
                 AND paf.business_group_id = g_bg_id
                 )
   ORDER BY org_information16;

l_lookup_type hr_lookups.lookup_type%TYPE;


BEGIN

     IF g_debug THEN
         hr_utility.trace('Entering set_globals procedure');
     END IF;

-- capture the value of g_opt_soe_or_min
OPEN gen_xml_opt_soe_min;
FETCH gen_xml_opt_soe_min INTO g_opt_soe_or_min;
  IF gen_xml_opt_soe_min%NOTFOUND THEN
     g_opt_soe_or_min := NULL;
  END IF;
CLOSE gen_xml_opt_soe_min;

-- capture the value of g_trfr_date_used
OPEN csr_transfer_to_gl_date;
 FETCH csr_transfer_to_gl_date into g_trfr_date_used;
   IF csr_transfer_to_gl_date%NOTFOUND THEN
    g_trfr_date_used :='E';
   END IF;
CLOSE csr_transfer_to_gl_date;

IF g_opt_soe_or_min ='ENT' THEN
  l_lookup_type := 'CN_SOE_LABELS';
ELSIF g_opt_soe_or_min ='NPG' THEN
  l_lookup_type := 'CN_MINISTRY_LABELS';
ELSE
  l_lookup_type := 'CN_SOE_LABELS';
END IF;


IF l_lookup_type IS NOT NULL THEN
    g_pay_prd(0).p_meaning := per_cn_shared_info.get_lookup_meaning('PERIOD',l_lookup_type);
    g_pay_prd(1).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_13',l_lookup_type);
    g_pay_prd(2).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_14',l_lookup_type);
    g_pay_prd(3).p_meaning := per_cn_shared_info.get_lookup_meaning('PERIOD_13',l_lookup_type);
    g_pay_prd(4).p_meaning := per_cn_shared_info.get_lookup_meaning('PERIOD_14',l_lookup_type);

    g_pay_ele(0).p_meaning := per_cn_shared_info.get_lookup_meaning('ELEMENT',l_lookup_type);
    g_pay_ele(1).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_12',l_lookup_type);
    g_pay_ele(2).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_15',l_lookup_type);
    g_pay_ele(3).p_meaning := per_cn_shared_info.get_lookup_meaning('ELEMENT_13',l_lookup_type);
    g_pay_ele(4).p_meaning := per_cn_shared_info.get_lookup_meaning('ELEMENT_14','CN_MINISTRY_LABELS');

    g_ind_asg(0).p_meaning := per_cn_shared_info.get_lookup_meaning('RECORD',l_lookup_type);
    g_ind_asg(1).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_11',l_lookup_type);
    g_ind_asg(2).p_meaning := per_cn_shared_info.get_lookup_meaning('RECORD_12',l_lookup_type);
    g_ind_asg(3).p_meaning := per_cn_shared_info.get_lookup_meaning('RECORD_13',l_lookup_type);
    g_ind_asg(4).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_12',l_lookup_type);
    g_ind_asg(5).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_13',l_lookup_type);
    g_ind_asg(6).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_14',l_lookup_type);
    g_ind_asg(7).p_meaning := per_cn_shared_info.get_lookup_meaning('RECORD_17',l_lookup_type);
    g_ind_asg(8).p_meaning := per_cn_shared_info.get_lookup_meaning('RECORD_18',l_lookup_type);
    g_ind_asg(9).p_meaning := per_cn_shared_info.get_lookup_meaning('RECORD_19',l_lookup_type);


    g_ind_detail(0).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL',l_lookup_type);
    g_ind_detail(1).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_11',l_lookup_type);
    g_ind_detail(2).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_12',l_lookup_type);
    g_ind_detail(3).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_13',l_lookup_type);
    g_ind_detail(4).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_14',l_lookup_type);
    g_ind_detail(5).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_15',l_lookup_type);
    g_ind_detail(6).p_meaning := per_cn_shared_info.get_lookup_meaning('DETAIL_16',l_lookup_type);


 END IF;

     IF g_debug THEN
         hr_utility.trace('Leaving set_globals procedure');
     END IF;

END set_globals;

/****************************************************************************
    Name        : get_employee_number
    Arguments   : 1. Person ID
                  2. Effective Date
    Description : This function fetches the employee number based on a given
                  person id and effective date and is used in some cursors above.
*****************************************************************************/
FUNCTION get_employee_number (p_person_id     in number,
                              p_effective_date    in date)
RETURN VARCHAR2 IS

  CURSOR c_employee_number
      IS
   SELECT employee_number
    FROM per_all_people_f
   WHERE person_id = p_person_id
     AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

  l_emp_num       per_all_people_f.employee_number%TYPE;

BEGIN

     IF g_debug THEN
         hr_utility.trace('Entering get_employee_number function');
     END IF;

  OPEN c_employee_number;
  FETCH c_employee_number INTO l_emp_num;
  CLOSE c_employee_number;

     IF g_debug THEN
         hr_utility.trace('Leaving get_employee_number function');
     END IF;

  RETURN l_emp_num ;

END get_employee_number;

/****************************************************************************
    Name        : get_employee_name
    Arguments   : 1. Person ID
                  2. Effective Date
    Description : This function fetches the employee name based on a given
                  person id and effective date and is used in some cursors above.
*****************************************************************************/
FUNCTION get_employee_name(p_person_id     in number,
                           p_effective_date    in date)
RETURN VARCHAR2 IS

  CURSOR c_employee_name
      IS
   SELECT full_name
    FROM per_all_people_f
   WHERE person_id = p_person_id
     AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

l_emp_name VARCHAR2(1000);
BEGIN

  OPEN c_employee_name;
  FETCH c_employee_name INTO l_emp_name;
  CLOSE c_employee_name;

  RETURN l_emp_name ;

END get_employee_name;

/****************************************************************************
    Name        : get_cost_alloc_key_flex
    Arguments   : 1. Payroll ID
                  2. Element Type ID
    Description : This function fetches the expenditure category code
                  from the element links window based on the payroll
                  costing segment
*****************************************************************************/
FUNCTION get_cost_alloc_key_flex(p_payroll_id IN NUMBER,
                                 p_element_type_id IN NUMBER)
RETURN VARCHAR2 IS

/* cursor to get cost allocation segment number */
CURSOR c_get_cost_seg(p_payr_id IN NUMBER) IS
select PAYROLL_COST_SEGMENT
from
PAY_PAYROLL_GL_FLEX_MAPS
where payroll_id = p_payr_id
and GL_ACCOUNT_SEGMENT =
	(SELECT APPLICATION_COLUMN_NAME FROM
	FND_SEGMENT_ATTRIBUTE_VALUES
	WHERE  ID_FLEX_NUM=
		(select CHART_OF_ACCOUNTS_ID
		 from GL_SETS_OF_BOOKS
		 where SET_OF_BOOKS_ID =
		     (select distinct GL_SET_OF_BOOKS_ID
		      from PAY_PAYROLL_GL_FLEX_MAPS
		      where payroll_id = p_payr_id
		      )
		)
	and  ID_FLEX_CODE='GL#'
	and  attribute_value = 'Y'
	and segment_attribute_type = 'GL_ACCOUNT'
	);

/* cursor to fetch the expense category code segment*/
CURSOR c_exp_cat_code(p_element_id IN NUMBER) IS
	select COST_ALLOCATION_KEYFLEX_ID
	from pay_element_links_f
	where business_group_id = g_bg_id
	and element_type_id = p_element_id
	and effective_start_date =
        (select min(effective_start_date) from pay_element_links_f where  business_group_id = g_bg_id
        and element_type_id = p_element_id);

l_cost_seg VARCHAR2(100);
l_cost_id NUMBER;
l_segment VARCHAR2(100);
statem     varchar2(256);
y varchar2(100);

BEGIN

OPEN c_get_cost_seg(p_payroll_id);
FETCH c_get_cost_seg INTO l_cost_seg;
CLOSE c_get_cost_seg;

OPEN c_exp_cat_code(p_element_type_id);
FETCH c_exp_cat_code INTO l_cost_id;
CLOSE c_exp_cat_code;

IF l_cost_seg IS NOT NULL AND l_cost_id IS NOT NULL THEN
statem := 'select '||l_cost_seg||' FROM PAY_COST_ALLOCATION_KEYFLEX '||' where COST_ALLOCATION_KEYFLEX_ID = :l_cost ';

EXECUTE immediate statem INTO y USING l_cost_id;
END IF;

RETURN y;

END get_cost_alloc_key_flex;
/****************************************************************************
    Name        : deinitialization_code
    Arguments   : 1. payroll_action_id
    Description : This procedure is called in last phase of archive process
                  where we spawn the CNAO Exception Listing report and
                  print the PDF listing all the employees who have NULL assignment
                  category
*****************************************************************************/

 PROCEDURE deinitialization_code (p_pactid IN NUMBER)
  IS

/* cursor to check if there are any assignments with null assignment category
   for a given payroll action id */
  CURSOR get_error is
  SELECT 1
    FROM pay_action_information
  WHERE action_context_id = p_pactid;

  l_count NUMBER;
  i NUMBER;
  l_set_layout BOOLEAN;

  BEGIN

     IF g_debug THEN
         hr_utility.trace('Entering deinitialization_code procedure');
     END IF;

   OPEN get_error;
   FETCH get_error INTO l_count;
   CLOSE get_error;

    IF nvl(l_count,0) >0 THEN
      l_set_layout := fnd_request.add_layout('PAY','PYCNAOT','en','US','PDF');

      i := FND_REQUEST.SUBMIT_REQUEST ( APPLICATION          => 'PAY',
                                        PROGRAM              => 'PYCNAOESP',
                                        ARGUMENT1            =>  p_pactid);
    END IF;

     IF g_debug THEN
         hr_utility.trace('Leaving deinitialization_code procedure');
     END IF;

END;


/****************************************************************************
    Name        : sort_action
    Arguments   : 1. payroll_action_id
                  2. sql_string for deciding the sort order of data.
                  3. length of the sql_string
    Description : This procedure sorts the individual xml's generated by
                  assact_xml procedure based on SERIAL_NUMBER column which
                  is populated with payroll period number.
*****************************************************************************/

PROCEDURE sort_action
(
    payactid IN VARCHAR2,       /* payroll action id */
    sqlstr IN OUT NOCOPY VARCHAR2,     /* string holding the sql statement */
    len OUT NOCOPY NUMBER              /* length of the sql string */
) IS
l_chardate_start  VARCHAR2(255);
 l_chardate_end    VARCHAR2(255);
BEGIN

 IF g_debug THEN
   hr_utility.trace('Entering sort action procedure');
 END IF;

 initialization_code(payactid);


sqlstr := ' select paa.rowid
            from  pay_assignment_actions paa,
                 pay_payroll_actions ppa ,
                 per_people_f ppf,
                 pay_payrolls_f p
            where ppa.payroll_action_id = :pactid
            and paa.payroll_action_id = ppa.payroll_action_id
            AND '''||g_end_date||''' between p.effective_start_date and p.effective_end_date
            and '''||g_end_date||''' BETWEEN ppf.effective_start_date AND ppf.effective_end_date
            AND substr(paa.serial_number,7) = p.payroll_id
            and ppf.person_id = (select paf.person_id
                                  from per_assignments_f paf
                                  where paf.assignment_id = paa.assignment_id
                                 and rownum =1)
           order by to_number(substr(paa.serial_number,1,6)),p.payroll_name,ppf.employee_number
           for update of paa.assignment_id';

len := length(sqlstr); -- return the length of the string.

 IF g_debug THEN
   hr_utility.trace('Leaving sort action procedure');
 END IF;

END sort_action;


/****************************************************************************
    Name        : OPEN_CSR_ASG_QUERY_DP
    Description : This procedure opens the cursor for fecthing the assignment
                  records based on date paid criteria.
		  p_prd_num is accounting period number
		  Use ref_curs to find payroll periods which cause accounting to
		  happen in the given accounting period
*****************************************************************************/
PROCEDURE OPEN_CSR_ASG_QUERY_DP(p_start IN DATE
                    ,p_end IN DATE
                    ,p_asg_id IN NUMBER
                    ,p_payr_id IN NUMBER
                    ,p_prd_num IN NUMBER
		    ,ref_curs IN OUT NOCOPY t_new_type_cur) IS
BEGIN

OPEN ref_curs FOR
SELECT TO_CHAR(get_employee_number(paf.person_id,paf.effective_end_date)) eno,
       per_cn_shared_info.get_lookup_meaning(paf.employee_category,'EMPLOYEE_CATG') asg_cat ,
       get_employee_name(paf.person_id,paf.effective_end_date) emp_name,
       to_char(paf.organization_id)  asg_org_id,
 (select distinct p.payroll_name from pay_payrolls_f p where p.payroll_id = paf.payroll_id) pname,
to_char(ptp.regular_payment_date,'YYYY') yr,
to_char(ptp.period_num) pno,
to_char(ptp.regular_payment_date,'YYYY') acct_yr,
to_number(to_char(ptp.regular_payment_date,'MM')) accnt_prd,
'CNY' currency
 from per_time_periods ptp,
      per_all_assignments_f paf
where ptp.start_date <=  g_end_date
and   ptp.regular_payment_date >= g_start_date
and   ptp.start_date <= p_end
and   ptp.regular_payment_date >= p_start
and   ptp.payroll_id = p_payr_id
and   paf.payroll_id = p_payr_id
and   assignment_id = p_asg_id
and   to_number(to_char(ptp.regular_payment_date,'MM')) = p_prd_num
and   least(ptp.end_date,p_end)
      between paf.effective_start_date and paf.effective_end_date;

END OPEN_CSR_ASG_QUERY_DP;

/****************************************************************************
    Name        : OPEN_CSR_ASG_QUERY_DE
    Description : This procedure opens the cursor for fecthing the assignment
                  records based on date earned criteria.
		  p_prd_num is accounting period number
		  Use ref_curs to find payroll periods which cause accounting to
		  happen in the given accounting period
*****************************************************************************/
PROCEDURE OPEN_CSR_ASG_QUERY_DE(p_start IN DATE
                    ,p_end IN DATE
                    ,p_asg_id IN NUMBER
                    ,p_payr_id IN NUMBER
                    ,p_prd_num IN NUMBER
		    ,ref_curs IN OUT NOCOPY t_new_type_cur) IS
BEGIN

OPEN ref_curs FOR
SELECT TO_CHAR(get_employee_number(paf.person_id,paf.effective_end_date)) eno,
       per_cn_shared_info.get_lookup_meaning(paf.employee_category,'EMPLOYEE_CATG') asg_cat ,
       get_employee_name(paf.person_id,paf.effective_end_date) emp_name,
       to_char(paf.organization_id)  asg_org_id,
 (select distinct p.payroll_name from pay_payrolls_f p where p.payroll_id = paf.payroll_id) pname,
to_char(ptp.regular_payment_date,'YYYY') yr,
to_char(ptp.period_num) pno,
to_char(ptp.end_date,'YYYY') acct_yr,
to_number(to_char(ptp.end_date,'MM')) accnt_prd,
'CNY' currency
 from per_time_periods ptp,
      per_all_assignments_f paf
where ptp.start_date <=  g_end_date
and   ptp.end_date >= g_start_date
and   ptp.start_date <= p_end
and   ptp.end_date >= p_start
and   ptp.payroll_id = p_payr_id
and   paf.payroll_id = p_payr_id
and   assignment_id = p_asg_id
and   to_number(to_char(ptp.end_date,'MM')) = p_prd_num
and   least(ptp.end_date,p_end)
      between paf.effective_start_date and paf.effective_end_date;

END OPEN_CSR_ASG_QUERY_DE;

BEGIN
--    hr_utility.trace_on(NULL,'LNAGARAJ');
    g_proc_name := 'pay_cn_audit_xmlgen.';
    g_debug := hr_utility.debug_enabled;
    g_document_type := 'CNAO_XML_FOR_SOE_AND_MINISTRY';

END pay_cn_audit_xmlgen;

/
