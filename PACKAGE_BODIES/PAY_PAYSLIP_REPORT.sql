--------------------------------------------------------
--  DDL for Package Body PAY_PAYSLIP_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYSLIP_REPORT" AS
/* $Header: pygpsrep.pkb 120.0.12010000.2 2009/04/15 09:04:53 skameswa ship $ */
--
-- Globals
--
    --g_pa_token  VARCHAR2(50);
    --g_cs_token  VARCHAR2(50);
-------------------------------------------------------------------------------
-- GET_PARAMETER
-------------------------------------------------------------------------------
FUNCTION get_parameter(p_parameter_string IN VARCHAR2
                      ,p_token            IN VARCHAR2
                      ,p_segment_number   IN NUMBER DEFAULT NULL ) RETURN VARCHAR2
IS
    --
    l_parameter  pay_payroll_actions.legislative_parameters%TYPE := NULL;
    l_start_pos  NUMBER;
    l_delimiter  varchar2(1) := ' ';
    --
BEGIN
	--
	l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
	--
	IF l_start_pos = 0 THEN
		l_delimiter := '|';
		l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
	END IF;

	IF l_start_pos <> 0 THEN
		l_start_pos := l_start_pos + length(p_token||'=');
		l_parameter := substr(p_parameter_string,
							  l_start_pos,
							  instr(p_parameter_string||' ',
							  l_delimiter,l_start_pos)
							  - l_start_pos);
		IF p_segment_number IS NOT NULL THEN
			l_parameter := ':'||l_parameter||':';
			l_parameter := substr(l_parameter,
								  instr(l_parameter,':',1,p_segment_number)+1,
								  instr(l_parameter,':',1,p_segment_number+1) -1
								  - instr(l_parameter,':',1,p_segment_number));
		END IF;
	END IF;
	--
	RETURN l_parameter;
END get_parameter;
--
-------------------------------------------------------------------------------
-- GET_ALL_PARAMETERS   Gets data from Legislative Parameters in Pay_payroll_actions
-------------------------------------------------------------------------------
PROCEDURE get_all_parameters(p_payroll_action_id                 IN          NUMBER
                            ,p_payroll_id                        OUT  NOCOPY NUMBER
                            ,p_consolidation_set_id              OUT  NOCOPY NUMBER
                            ,p_start_date                        OUT  NOCOPY VARCHAR2
                            ,p_end_date                          OUT  NOCOPY VARCHAR2
                            ,p_rep_group                         OUT  NOCOPY VARCHAR2
                            ,p_rep_category                      OUT  NOCOPY VARCHAR2
                            ,p_assignment_set_id                 OUT  NOCOPY NUMBER
                            ,p_assignment_id                     OUT  NOCOPY NUMBER
                            ,p_effective_date                    OUT  NOCOPY DATE
                            ,p_business_group_id                 OUT  NOCOPY NUMBER
                            ,p_legislation_code                  OUT  NOCOPY VARCHAR2 ) IS
    --
    CURSOR csr_parameter_info(c_payroll_action_id NUMBER) IS
    SELECT get_parameter(ppa.legislative_parameters,'PAYROLL_ID')
          ,get_parameter(ppa.legislative_parameters,'CONSOLIDATION_SET_ID')
          ,get_parameter(ppa.legislative_parameters,'START_DATE')
          ,get_parameter(ppa.legislative_parameters,'END_DATE')
          ,get_parameter(ppa.legislative_parameters,'REP_GROUP')
          ,get_parameter(ppa.legislative_parameters,'REP_CAT')
          ,get_parameter(ppa.legislative_parameters,'ASSIGNMENT_SET_ID')
          ,get_parameter(ppa.legislative_parameters,'ASSIGNMENT_ID')
          ,ppa.effective_date
          ,ppa.business_group_id
          ,pbg.legislation_code
    FROM  pay_payroll_actions ppa
         ,per_business_groups pbg
    WHERE ppa.payroll_action_id = c_payroll_action_id
    AND   ppa.business_group_id = pbg.business_group_id;
    --
BEGIN
    --
    OPEN csr_parameter_info (p_payroll_action_id);
    FETCH csr_parameter_info INTO  p_payroll_id
                                  ,p_consolidation_set_id
                                  ,p_start_date
                                  ,p_end_date
                                  ,p_rep_group
                                  ,p_rep_category
                                  ,p_assignment_set_id
                                  ,p_assignment_id
                                  ,p_effective_date
                                  ,p_business_group_id
                                  ,p_legislation_code ;
    CLOSE csr_parameter_info;
    --
END get_all_parameters;
--
--------------------------------------------------------------------------------
-- GET_SORT_ORDER
--------------------------------------------------------------------------------
FUNCTION get_sort_order( p_type              IN VARCHAR2
                        ,p_legislation_code  IN VARCHAR2   ) RETURN VARCHAR2 IS
    --
    l_sort_order        VARCHAR2(20);
BEGIN
    IF p_type = 'LE' THEN
    --
        EXECUTE IMMEDIATE 'SELECT pay_'||p_legislation_code||'_rules.get_payslip_sort_order1 FROM DUAL'
        INTO l_sort_order;
    ELSIF p_type = 'ORG' THEN
        --
        EXECUTE IMMEDIATE 'SELECT pay_'||p_legislation_code||'_rules.get_payslip_sort_order2 FROM DUAL'
        INTO l_sort_order;
    ELSIF p_type = 'NAME' THEN
        --
        EXECUTE IMMEDIATE 'SELECT pay_'||p_legislation_code||'_rules.get_payslip_sort_order3 FROM DUAL'
        INTO l_sort_order;
    END IF;
    --
    RETURN l_sort_order;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_sort_order;
--
--------------------------------------------------------------------------------
-- QUALIFYING_PROC
--------------------------------------------------------------------------------
PROCEDURE qualifying_proc(p_assignment_id    IN         NUMBER
                         ,p_qualifier        OUT NOCOPY VARCHAR2 ) IS
    --
    l_actid                 NUMBER;
    l_rep_group             pay_report_groups.report_group_name%TYPE;
    l_rep_category          pay_report_categories.category_name%TYPE;
    l_effective_date        DATE;
    l_business_group_id     NUMBER;
    l_assignment_set_id     NUMBER;
    l_assignment_id         NUMBER;
    l_inc_exc               VARCHAR2(1);
    l_asg_inc_exc           VARCHAR2(1);
    --
    l_payroll_id            NUMBER;
    l_consolidation_set_id  NUMBER;
    l_start_date            VARCHAR2(20);
    l_end_date              VARCHAR2(20);
    l_legislation_code      VARCHAR2(10);
    l_start_dt              DATE;
    l_end_dt                DATE;
    l_qualifier             VARCHAR2(1);
    --
    sql_cur                 NUMBER;
    l_rows                  NUMBER;
    statem                  VARCHAR2(256);
    --
    CURSOR csr_asg(c_assignment_id    NUMBER
                  ,c_payroll_id       NUMBER
                  ,c_consolidation_set_id NUMBER
                  ,c_start_date       DATE
                  ,c_end_date         DATE
                  ,c_pa_token         VARCHAR2
                  ,c_cs_token         VARCHAR2
                  ,c_legislation_code VARCHAR2) IS
    SELECT 'Y'
    FROM pay_assignment_actions paa
        ,pay_payroll_actions	ppa
        ,hr_lookups             hrl
        ,pay_action_information pai
        ,per_time_periods       ptp
    WHERE paa.assignment_id             = c_assignment_id
    AND  paa.payroll_action_id          = ppa.payroll_action_id
    AND  paa.source_action_id           IS NULL
    AND	 ppa.effective_Date   BETWEEN   c_start_date
                              AND       c_end_date
    AND  ppa.report_type                = hrl.meaning
    AND	 hrl.lookup_type                = 'PAYSLIP_REPORT_TYPES'
    AND	 hrl.lookup_code                = c_legislation_code
    AND	 NVL(c_payroll_id,NVL(get_parameter(ppa.legislative_parameters,c_pa_token),-1))
                                        = NVL(get_parameter(ppa.legislative_parameters,c_pa_token),-1)
    AND	 c_consolidation_set_id         = get_parameter(ppa.legislative_parameters,c_cs_token)
    AND	 pai.assignment_id              = paa.assignment_id
    AND  pai.action_context_type        = 'AAP'
    AND  pai.action_information_category    = 'EMPLOYEE DETAILS'
    AND	 pai.action_context_id          = paa.assignment_action_id
    AND  ptp.time_period_id             = pai.ACTION_INFORMATION16
    AND  pay_us_employee_payslip_web.check_emp_personal_payment
	( paa.assignment_id, ptp.payroll_id, pai.action_information16,
        pai.action_context_id, pai.effective_date) = 'Y'	;
    --
    CURSOR csr_inc_asg(c_assignment_id        NUMBER
                      ,c_payroll_id           NUMBER
                      ,c_consolidation_set_id NUMBER
                      ,c_start_date           DATE
                      ,c_end_date             DATE
                      ,c_pa_token             VARCHAR2
                      ,c_cs_token             VARCHAR2
                      ,c_legislation_code     VARCHAR2
                      ,c_assignment_set_id    NUMBER  ) IS
    SELECT 'Y'
    FROM pay_assignment_actions         paa
        ,pay_payroll_actions            ppa
        ,hr_lookups                     hrl
        ,hr_assignment_set_amendments   hasa
        ,pay_action_information         pai
        ,per_time_periods               ptp
    WHERE paa.assignment_id                 = c_assignment_id
    AND  paa.payroll_action_id	            = ppa.payroll_action_id
    AND  paa.source_action_id               IS NULL
    AND	 ppa.effective_Date   BETWEEN	    c_start_date
                              AND		    c_end_date
    AND  ppa.report_type 	   			    = hrl.meaning
    AND	 hrl.lookup_type                    = 'PAYSLIP_REPORT_TYPES'
    AND	 hrl.lookup_code                    = c_legislation_code
    AND	 NVL(c_payroll_id,NVL(get_parameter(ppa.legislative_parameters,c_pa_token),-1))
                                            = NVL(get_parameter(ppa.legislative_parameters,c_pa_token),-1)
    AND	 c_consolidation_set_id             = get_parameter(ppa.legislative_parameters,c_cs_token)
    AND	 paa.assignment_id                  = hasa.assignment_id
    AND	 hasa.assignment_set_id             = c_assignment_set_id
    AND	 hasa.include_or_exclude            = 'I'
    AND	 pai.assignment_id                  = paa.assignment_id
    AND  pai.action_context_type            = 'AAP'
    AND  pai.action_information_category    = 'EMPLOYEE DETAILS'
    AND	 pai.action_context_id              = paa.assignment_action_id
    AND  ptp.time_period_id                 = pai.ACTION_INFORMATION16
    AND  pay_us_employee_payslip_web.check_emp_personal_payment
	( paa.assignment_id, ptp.payroll_id, pai.action_information16,
      pai.action_context_id, pai.effective_date) = 'Y'	;
    --
    -- The Assignment Set Logic is handled only for either Include or Exclude
    -- and not for both. This doesn't handle the assignment_set_criteria.
    --
    CURSOR csr_inc_exc(c_assignment_set_id NUMBER
                      ,c_assignment_id     NUMBER) IS
    SELECT include_or_exclude
    FROM  hr_assignment_set_amendments
    WHERE assignment_set_id = c_assignment_set_id
    AND   assignment_id     = nvl(c_assignment_id,assignment_id);
    --
BEGIN
    --hr_utility.trace('###### IN Qualifying Proc');
    --
    l_actid    := pay_proc_environment_pkg.get_pactid;
    --
    get_all_parameters(l_actid
                      ,l_payroll_id
                      ,l_consolidation_set_id
                      ,l_start_date
                      ,l_end_date
                      ,l_rep_group
                      ,l_rep_category
                      ,l_assignment_set_id
                      ,l_assignment_id
                      ,l_effective_date
                      ,l_business_group_id
                      ,l_legislation_code);
    --
    l_start_dt := TO_DATE(l_start_date,'YYYY/MM/DD');
    l_end_dt   := TO_DATE(l_end_date,'YYYY/MM/DD');
    --EXECUTE IMMEDIATE 'SELECT pay_'||l_legislation_code||'_rules.get_payroll_token FROM DUAL' into l_token;
    --
    IF pay_payslip_report.g_pa_token IS NULL THEN
        DECLARE
        BEGIN
            statem := 'BEGIN pay_'||l_legislation_code||'_rules.get_token_names(:p_pa_token, :p_cs_token); END;';
            --hr_utility.trace(statem);
            sql_cur := dbms_sql.open_cursor;
            dbms_sql.parse(sql_cur
                          ,statem
                          ,dbms_sql.v7);
            dbms_sql.bind_variable(sql_cur, 'p_pa_token', pay_payslip_report.g_pa_token, 50);
            dbms_sql.bind_variable(sql_cur, 'p_cs_token', pay_payslip_report.g_cs_token, 50);
            l_rows := dbms_sql.execute(sql_cur);
            dbms_sql.variable_value(sql_cur, 'p_pa_token', pay_payslip_report.g_pa_token);
            dbms_sql.variable_value(sql_cur, 'p_cs_token', pay_payslip_report.g_cs_token);
            dbms_sql.close_cursor(sql_cur);
        Exception
            WHEN OTHERS THEN
                pay_payslip_report.g_pa_token := NVL(pay_payslip_report.g_pa_token,'PAYROLL_ID');
                pay_payslip_report.g_cs_token := NVL(pay_payslip_report.g_cs_token,'CONSOLIDATION_SET_ID');
                --
                IF dbms_sql.IS_OPEN(sql_cur) THEN
                   dbms_sql.close_cursor(sql_cur);
                END IF;
        END;
    END IF;
    --
    IF l_assignment_id IS NOT NULL THEN
        IF l_assignment_id = p_assignment_id THEN
            --
            p_qualifier := 'Y' ;
            --
        END IF;
    ELSE
        --
        --hr_utility.trace('###### 1.p_assignment_id '||p_assignment_id);
        --
        IF l_assignment_set_id IS NOT NULL THEN
            OPEN  csr_inc_exc(l_assignment_set_id
                              ,NULL);
            FETCH csr_inc_exc INTO l_inc_exc;
            CLOSE csr_inc_exc;
        END IF;
        --
        IF l_assignment_set_id IS NULL OR nvl(l_inc_exc,'E') = 'E' THEN
            OPEN csr_asg(p_assignment_id
                        ,l_payroll_id
                        ,l_consolidation_set_id
                        ,l_start_dt
                        ,l_end_dt
                        ,pay_payslip_report.g_pa_token
                        ,pay_payslip_report.g_cs_token
                        ,l_legislation_code );
            FETCH csr_asg INTO l_qualifier;
            CLOSE csr_asg;
            --
            IF l_assignment_set_id IS NOT NULL THEN
                OPEN  csr_inc_exc(l_assignment_set_id
                                 ,p_assignment_id);
                FETCH csr_inc_exc INTO l_asg_inc_exc;
                CLOSE csr_inc_exc;
            END IF;
            --
            --hr_utility.trace('###### 2.l_asg_inc_exc '||l_asg_inc_exc);
            --hr_utility.trace('###### 2.l_qualifier '||l_qualifier);
            --
            IF NVL(l_asg_inc_exc,'X') <> 'E' AND l_qualifier = 'Y' THEN
                --
                p_qualifier := 'Y' ;
                --
            END IF;
        ELSIF l_inc_exc = 'I' THEN
            OPEN csr_inc_asg(p_assignment_id
                            ,l_payroll_id
                            ,l_consolidation_set_id
                            ,l_start_dt
                            ,l_end_dt
                            ,pay_payslip_report.g_pa_token
                            ,pay_payslip_report.g_cs_token
                            ,l_legislation_code
                            ,l_assignment_set_id );
            FETCH csr_inc_asg INTO l_qualifier;
            CLOSE csr_inc_asg;
            --
            IF l_qualifier = 'Y' THEN
                p_qualifier := 'Y' ;
            END IF;
            --
        END IF;
        --
    END IF;
  --
  END qualifying_proc;
  --------------------------------------------------------------------------------
  -- XML_ASG
  --------------------------------------------------------------------------------
  PROCEDURE xml_asg IS
    l_xml                   BLOB;
    --
    l_actid                 pay_payroll_actions.payroll_action_id%TYPE;
    l_payroll_id            NUMBER;
    l_consolidation_set_id  NUMBER;
    l_start_date            VARCHAR2(20);
    l_end_date              VARCHAR2(20);
    l_legislation_code      VARCHAR2(10);
    l_rep_group             pay_report_groups.report_group_name%TYPE;
    l_rep_category          pay_report_categories.category_name%TYPE;
    l_effective_date        DATE;
    l_business_group_id     NUMBER;
    l_assignment_set_id     NUMBER;
    l_assignment_id         NUMBER;
    l_start_dt              DATE;
    l_end_dt                DATE;
    sql_cur                 NUMBER;
    l_rows                  NUMBER;
    statem                  VARCHAR2(256);
    --
    -- There can be multiple payslips for each assignment.
    -- The number of payslips is based on the number of "EMPLOYEE DETAILS" records
    -- for that assignment(The same logic is used while generating online payslips)
    --
    CURSOR csr_archive_act(c_payroll_id         NUMBER
                          ,c_consolidation_set_id NUMBER
                          ,c_start_date         DATE
                          ,c_end_Date           DATE
                          ,c_pa_token           VARCHAR2
                          ,c_cs_token           VARCHAR2
                          ,c_legislation_code   VARCHAR2) IS
    SELECT pai.action_context_id
    FROM  pay_temp_object_actions   ptoa
         ,pay_action_information    pai
         ,pay_assignment_Actions    paa
         ,pay_payroll_actions       ppa
         ,hr_lookups                hrl
    WHERE ptoa.object_Action_id             = pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
    AND   ptoa.object_id                    = paa.assignment_id
    AND   paa.payroll_action_id             = ppa.payroll_action_id
    AND	  ppa.effective_Date        BETWEEN c_start_date
                                    AND     c_end_date
    AND   ppa.report_type                   = hrl.meaning--'ES_PS_ARCHIVE'
    AND	  hrl.lookup_type                   = 'PAYSLIP_REPORT_TYPES'
    AND	  hrl.lookup_code                   = c_legislation_code
    AND	  NVL(c_payroll_id,NVL(get_parameter(ppa.legislative_parameters,c_pa_token),-1))
                                            = NVL(get_parameter(ppa.legislative_parameters,c_pa_token),-1)
    AND	  c_consolidation_set_id            = get_parameter(ppa.legislative_parameters,c_cs_token)
    AND   pai.assignment_id                 = paa.assignment_id
    AND   pai.action_context_type           = 'AAP'
    AND   pai.action_information_category   = 'EMPLOYEE DETAILS'
    AND	  pai.action_context_id             = paa.assignment_action_id;
    --
  BEGIN
    --hr_utility.trace('###### IN XML_ASG');
    --
    l_actid    := pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
    --
    get_all_parameters(l_actid
                      ,l_payroll_id
                      ,l_consolidation_set_id
                      ,l_start_date
                      ,l_end_date
                      ,l_rep_group
                      ,l_rep_category
                      ,l_assignment_set_id
                      ,l_assignment_id
                      ,l_effective_date
                      ,l_business_group_id
                      ,l_legislation_code);
/*Begin Bug 7363608 */
    IF pay_payslip_report.g_pa_token IS NULL THEN
        DECLARE
        BEGIN
            statem := 'BEGIN pay_'||l_legislation_code||'_rules.get_token_names(:p_pa_token, :p_cs_token); END;';
            --hr_utility.trace(statem);
            sql_cur := dbms_sql.open_cursor;
            dbms_sql.parse(sql_cur
                          ,statem
                          ,dbms_sql.v7);
            dbms_sql.bind_variable(sql_cur, 'p_pa_token', pay_payslip_report.g_pa_token, 50);
            dbms_sql.bind_variable(sql_cur, 'p_cs_token', pay_payslip_report.g_cs_token, 50);
            l_rows := dbms_sql.execute(sql_cur);
            dbms_sql.variable_value(sql_cur, 'p_pa_token', pay_payslip_report.g_pa_token);
            dbms_sql.variable_value(sql_cur, 'p_cs_token', pay_payslip_report.g_cs_token);
            dbms_sql.close_cursor(sql_cur);
        Exception
            WHEN OTHERS THEN
                pay_payslip_report.g_pa_token := NVL(pay_payslip_report.g_pa_token,'PAYROLL_ID');
                pay_payslip_report.g_cs_token := NVL(pay_payslip_report.g_cs_token,'CONSOLIDATION_SET_ID');
                --
                IF dbms_sql.IS_OPEN(sql_cur) THEN
                   dbms_sql.close_cursor(sql_cur);
                END IF;
        END;
    END IF;
/*End Bug 7363608 */
    --
    l_start_dt := TO_DATE(l_start_date,'YYYY/MM/DD');
    l_end_dt   := TO_DATE(l_end_date,'YYYY/MM/DD');
    --
    pay_core_files.write_to_magtape_lob('<?xml version="1.0" encoding="'||hr_mx_utility.get_IANA_charset||'"?>');
    pay_core_files.write_to_magtape_lob('<PAYSLIP_REPORT>');
    --
    FOR csr_archive_act_rec in csr_archive_act(l_payroll_id
                                              ,l_consolidation_set_id
                                              ,l_start_dt
                                              ,l_end_dt
                                              ,pay_payslip_report.g_pa_token
                                              ,pay_payslip_report.g_cs_token
                                              ,l_legislation_code) LOOP
        --
        pay_payroll_xml_extract_pkg.generate(
                 P_ACTION_CONTEXT_ID    =>   csr_archive_act_rec.action_context_id
                ,P_CUSTOM_XML_PROCEDURE =>   NULL
                ,P_GENERATE_HEADER_FLAG =>   'N'
                ,P_ROOT_TAG             =>   'PAYSLIP'
                ,P_DOCUMENT_TYPE        =>   'PAYSLIP'
                ,P_XML                  =>   l_xml);
        --
        --hr_utility.trace('#### act_id '||csr_archive_act_rec.action_context_id);
        pay_core_files.write_to_magtape_lob(l_xml);
    --
    END LOOP;
    pay_core_files.write_to_magtape_lob('</PAYSLIP_REPORT>');
    --
  END xml_asg;
  --
END pay_payslip_report;

/