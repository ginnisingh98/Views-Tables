--------------------------------------------------------
--  DDL for Package Body PAY_IN_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_REPORTS_PKG" AS
/* $Header: pyinprpt.pkb 120.35.12010000.16 2009/07/10 08:48:49 mdubasi ship $ */

  g_xml_data           CLOB;
  g_package           CONSTANT VARCHAR2(100) := 'pay_in_reports_pkg.';
  g_debug             BOOLEAN ;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_eit_remarks                                     --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : This function finds the remrks for pf and esi       --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id     NUMBER                          --
--                  p_report_type       VARCHAR2                        --
--                  p_year              VARCHAR2                        --
--                  p_mon               VARCHAR2                        --
--         RETURN : VARCHAR2                                            --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 03-May-2005    aaagarwa   Initial Version                      --
-- 115.1 18-Nov-2005    abhjain    Added to_char in the cursor          --
-- 115.1 06-Dec-2005    aaagarwa   Added to_number in the cursor        --
--                                 Resolved R12:D4 issues               --
-- 115.2 11-Apr-2008    rsaharay   Modified cursor c_remarks            --
--------------------------------------------------------------------------
FUNCTION get_eit_remarks(p_number            VARCHAR2
                        ,p_report_type       VARCHAR2
                        ,p_period            VARCHAR2
                        ,p_mon               NUMBER
                         )
RETURN VARCHAR2
IS

   CURSOR c_remarks
   IS
        SELECT aei_information3
        FROM   per_assignment_extra_info
        WHERE  aei_information2 = LPAD(p_mon,2,'0')
        AND    aei_information1 = p_period
        AND    information_type = DECODE(p_report_type,'PF','PER_IN_PF_REMARKS','ESI','PER_IN_ESI_REMARKS')
        AND    assignment_id IN(SELECT DISTINCT pea.assignment_id
                                FROM  per_people_f pep -- Reduced cost from 2294 to 69
                                     ,per_assignments_f pea-- Done this for bug 4774018
                                WHERE pep.person_id = pea.person_id
                                AND pep.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
                                AND p_number = DECODE(p_report_type,'PF'
                                                                   ,pep.per_information8
                                                                   ,pep.per_information9
                                                      )
                                );

   l_remarks  VARCHAR2(30);
   l_message   VARCHAR2(255);
   l_procedure VARCHAR2(100);


   BEGIN

      l_procedure := g_package ||'get_eit_remarks';
      pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

      IF g_debug THEN
        pay_in_utils.trace('PF/ESI Number   : ',p_number);
        pay_in_utils.trace('Report Type     : ',p_report_type);
        pay_in_utils.trace('Period          : ',p_period);
        pay_in_utils.trace('Month Number    : ',p_mon);
      END IF;

      OPEN  c_remarks;
      FETCH c_remarks INTO l_remarks;
      CLOSE c_remarks;

      IF g_debug THEN
        pay_in_utils.trace('Remarks at AEI level   : ',l_remarks);
      END IF;

      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

      RETURN l_remarks;
END get_eit_remarks;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : INSERT_RECORD                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure inserts a null record for PF Form 3A--
-- Parameters     :                                                     --
--             IN : p_row_num                                NUMBER     --
--                    p_xml_data                             CLOB       --
--                    p_epf_org                              NUMBER     --
--                    p_pension_org                          NUMBER     --
--                    p_dli_contr                            NUMBER     --
--                    p_admin_chrg                           NUMBER     --
--                    p_edli_adm                             NUMBER     --
--                    p_total                                NUMBER     --
--            OUT : p_xml_data                               CLOB       --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 01-Jan-2005    aaagarwa   Initial Version                      --
--------------------------------------------------------------------------
PROCEDURE insert_record(p_row_num     NUMBER
                       ,p_xml_data    IN OUT NOCOPY  CLOB
                       ,p_epf_org     NUMBER      DEFAULT null
                       ,p_pension_org NUMBER      DEFAULT null
                       ,p_dli_contr   NUMBER      DEFAULT null
                       ,p_admin_chrg  NUMBER      DEFAULT null
                       ,p_edli_adm    NUMBER      DEFAULT null
                       ,p_total       NUMBER      DEFAULT null
                       )
IS
  l_count NUMBER;
  l_bg_id NUMBER;
  l_message   VARCHAR2(255);
  l_procedure VARCHAR2(100);


BEGIN
 l_procedure := g_package ||'insert_record';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   l_bg_id:=fnd_profile.value('PER_BUSINESS_GROUP_ID');

--   pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(,0));

  pay_in_xml_utils.gXMLTable.delete;
  l_count:=1;
  pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_sl';
  pay_in_xml_utils.gXMLTable(l_count).Value := (p_row_num+1);
  l_count := l_count + 1;
  pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_month';
  pay_in_xml_utils.gXMLTable(l_count).Value :=
  (to_char(add_months(to_date('01-03-2004','DD-MM-YYYY'),p_row_num),'Mon'));
  IF pay_in_xml_utils.gXMLTable(l_count).Value='Mar' THEN
     pay_in_xml_utils.gXMLTable(l_count).Value:=pay_in_xml_utils.gXMLTable(l_count).Value||' Paid in April';
  END IF;
  l_count := l_count + 1;
  pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_epf_org';
  pay_in_xml_utils.gXMLTable(l_count).Value :=
  pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_epf_org,0));
  l_count := l_count + 1;
  pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pension_org';
  pay_in_xml_utils.gXMLTable(l_count).Value :=
  pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_pension_org,0));
  l_count := l_count + 1;
  pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_dli_pf_org';
  pay_in_xml_utils.gXMLTable(l_count).Value :=
  pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_dli_contr,0));
  l_count := l_count + 1;
  pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_admin_pf';
  pay_in_xml_utils.gXMLTable(l_count).Value :=
  pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_admin_chrg,0));
  l_count := l_count + 1;
  pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_edli_adm';
  pay_in_xml_utils.gXMLTable(l_count).Value :=
  pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_edli_adm,0));
  l_count := l_count + 1;
  pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_total';
  pay_in_xml_utils.gXMLTable(l_count).Value :=
  pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_total,0));
  l_count := l_count + 1;
  pay_in_xml_utils.multiColumnar('monthly',pay_in_xml_utils.gXMLTable,l_count,p_xml_data);
  pay_in_xml_utils.gXMLTable.delete;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

END insert_record;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : INSERT_NULL_RECORD                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure inserts a null record for PF Form 6A --
-- Parameters     :                                                     --
--             IN : p_month_name                        VARCHAR2        --
--                    p_xml_data                        CLOB            --
--                    p_pf_salary_ptd                   VARCHAR2        --
--                    p_epf                             VARCHAR2        --
--                    p_epf_diff                        VARCHAR2        --
--                    p_pension_fund                    VARCHAR2        --
--                    p_absence                         VARCHAR2        --
--                    p_remarks                         VARCHAR2        --
--            OUT : p_xml_data                          CLOB            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 01-Jan-2005    aaagarwa   Initial Version                      --
--------------------------------------------------------------------------
PROCEDURE insert_null_record(p_month_name     VARCHAR2
                             ,p_xml_data      IN OUT NOCOPY  CLOB
                             ,p_pf_salary_ptd VARCHAR2 DEFAULT NULL
                             ,p_epf              VARCHAR2 DEFAULT NULL
                             ,p_epf_diff      VARCHAR2 DEFAULT NULL
                             ,p_pension_fund  VARCHAR2 DEFAULT NULL
                             ,p_absence       VARCHAR2 DEFAULT NULL
                             ,p_remarks       VARCHAR2 DEFAULT NULL )
 IS
  l_count  NUMBER;
  l_bg_id  NUMBER;
  l_message   VARCHAR2(255);
  l_procedure VARCHAR2(100);

 BEGIN
  l_procedure := g_package ||'insert_null_record';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


 l_bg_id:=fnd_profile.value('PER_BUSINESS_GROUP_ID');
   l_count:=1;
    --PF Salary  _ASG_ORG_PTD
    pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pf_salary_ptd';
    pay_in_xml_utils.gXMLTable(l_count).Value :=
    pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_pf_salary_ptd,0));
    l_count := l_count + 1;
    --Total Employee Contr
    pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_epf';
    pay_in_xml_utils.gXMLTable(l_count).Value :=
    pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_epf,0));
    l_count := l_count + 1;
    --Employer Contr towards PF
    pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_epf_difference';
    pay_in_xml_utils.gXMLTable(l_count).Value :=
    pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_epf_diff,0));
    l_count := l_count + 1;
    --Employer Contr towards Pension
    pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pension_fund';
    pay_in_xml_utils.gXMLTable(l_count).Value :=
    pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_pension_fund,0));
    l_count := l_count + 1;
    --Absence
    pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_absence';
    pay_in_xml_utils.gXMLTable(l_count).Value :=
    pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_absence,0));
    l_count := l_count + 1;
    --Remarks
    pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_remarks';
    pay_in_xml_utils.gXMLTable(l_count).Value := (p_remarks);
    l_count := l_count + 1;
    --Payroll Month
    pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_month';
    IF p_month_name='Mar'then
        pay_in_xml_utils.gXMLTable(l_count).Value :=p_month_name||' Paid in Apr';
    ELSE
        pay_in_xml_utils.gXMLTable(l_count).Value :=p_month_name;
    END IF;
    l_count := l_count + 1;
    pay_in_xml_utils.multiColumnar('t_month',pay_in_xml_utils.gXMLTable,l_count,p_xml_data);
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

 END insert_null_record;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : INSERT_CH_RECORD                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure inserts challan data and null for    --
--                  Pension Form 8                                      --
-- Parameters     :                                                     --
--             IN : p_row_num                                NUMBER     --
--                    p_xml_data                             CLOB       --
--                    p_pension_org                          NUMBER     --
--                    p_total                                NUMBER     --
--            OUT : p_xml_data                               CLOB       --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 11-Feb-2005    vgsriniv   Initial Version                      --
--------------------------------------------------------------------------
PROCEDURE insert_ch_record(p_row_num     IN NUMBER
                          ,p_xml_data    IN OUT NOCOPY CLOB
                          ,p_pension_org IN NUMBER DEFAULT null
                          )
IS
  l_count NUMBER;
  l_bg_id NUMBER;
  l_message   VARCHAR2(255);
  l_procedure VARCHAR2(100);

BEGIN
  l_procedure := g_package ||'insert_ch_record';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  pay_in_xml_utils.gXMLTable.DELETE;
  l_bg_id:=fnd_profile.value('PER_BUSINESS_GROUP_ID');
  l_count:=1;

  pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pension_org'||p_row_num;
  pay_in_xml_utils.gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(l_bg_id,p_pension_org);
  l_count := l_count + 1;

  pay_in_xml_utils.multiColumnar('monthly',pay_in_xml_utils.gXMLTable,l_count,p_xml_data);
  pay_in_xml_utils.gXMLTable.DELETE;
  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

END insert_ch_record;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : INSERT_NULL_FORM7_RECORD                            --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure inserts a null record for PF Form 7  --
-- Parameters     :                                                     --
--             IN : p_month_name                        VARCHAR2        --
--                    p_xml_data                        CLOB            --
--                    p_pf_salary_ptd                   VARCHAR2        --
--                    p_pension_fund                    VARCHAR2        --
--                    p_absence                         VARCHAR2        --
--                    p_remarks                         VARCHAR2        --
--            OUT : p_xml_data                          CLOB            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 08-Mar-2005    lnagaraj   Initial Version                      --
--------------------------------------------------------------------------
PROCEDURE insert_null_form7_record(p_month_name    VARCHAR2
                                  ,p_xml_data      IN OUT NOCOPY CLOB
                                  ,p_pf_salary_ptd VARCHAR2 DEFAULT NULL
                                  ,p_pension_fund  VARCHAR2 DEFAULT NULL
                                  ,p_absence       VARCHAR2 DEFAULT NULL
                                  ,p_remarks       VARCHAR2 DEFAULT NULL )
 IS
  l_count  NUMBER;
  l_bg_id  NUMBER;
  l_message   VARCHAR2(255);
  l_procedure VARCHAR2(100);


 BEGIN

   l_procedure := g_package ||'insert_null_form7_record';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   l_bg_id:= fnd_profile.value('PER_BUSINESS_GROUP_ID');
   l_count:=1;
    --PF Salary  _ASG_ORG_PTD
    pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pf_salary_ptd';
    pay_in_xml_utils.gXMLTable(l_count).Value :=  pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_pf_salary_ptd,0));
    l_count := l_count + 1;

    --Employer Contr towards Pension
    pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pension_fund';
    pay_in_xml_utils.gXMLTable(l_count).Value :=  pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(p_pension_fund,0));
    l_count := l_count + 1;
    --Absence
    pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_absence';
    pay_in_xml_utils.gXMLTable(l_count).Value := nvl(p_absence,0);
    l_count := l_count + 1;
    --Remarks
    pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_remarks';
    pay_in_xml_utils.gXMLTable(l_count).Value := (p_remarks);
    l_count := l_count + 1;
    --Payroll Month
    pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_month';
    IF p_month_name='Mar'then
        pay_in_xml_utils.gXMLTable(l_count).Value :=p_month_name||' Paid in Apr';
    ELSE
        pay_in_xml_utils.gXMLTable(l_count).Value :=p_month_name;
    END IF;

    pay_in_xml_utils.multiColumnar('t_month',pay_in_xml_utils.gXMLTable,l_count,p_xml_data);
 END insert_null_form7_record;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_PT_FORM3_XML                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : This procedure creates XML data for PT Form III     --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pt_org_id                        VARCHAR2         --
--                  p_frequency                        VARCHAR2         --
--                  p_year                             VARCHAR2         --
--                  p_period                           VARCHAR2         --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 18-May-2005    abhjain   Initial Version                       --
--                                                                      --
--------------------------------------------------------------------------

PROCEDURE create_pt_form3_xml(p_pt_org_id  VARCHAR2
                             ,p_frequency  VARCHAR2
                             ,p_year       VARCHAR2
                             ,p_period     VARCHAR2)
IS
--DISTINCT Organization Id and Name
CURSOR c_distinct_org(p_period_start DATE
                     ,p_period_end   DATE)
IS
SELECT DISTINCT source_id           org_id
      ,action_information9          org_name
FROM   pay_action_information
      ,hr_organization_units hou
WHERE  action_information_category = 'IN_PT_ASG'
AND    action_context_type = 'AAP'
AND    source_id = NVL(p_pt_org_id, source_id)
AND    jurisdiction_code = 'MH'
AND    hou.organization_id = source_id
AND    TO_DATE(action_information8, 'DD-MM-YYYY') BETWEEN p_period_start AND p_period_end
AND    hou.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
ORDER BY action_information9 ASC;

--Select the highest payroll action id for an Org
CURSOR c_max_pa_action_id(p_pt_org_id    NUMBER
                         ,p_period_start DATE
                         ,p_period_end   DATE)
IS
  SELECT MAX(pai.action_context_id)
  FROM   pay_action_information pai
        ,pay_assignment_actions pac
  WHERE  pai.action_information_category = 'IN_PT_PAY'
  AND    pai.action_context_type = 'PA'
  AND    pai.source_id = p_pt_org_id
  AND    pac.payroll_action_id = pai.action_context_id
  AND    pac.assignment_action_id IN
         ( SELECT action_context_id
           FROM   pay_action_information
           WHERE  action_information_category = 'IN_PT_ASG'
           AND    action_context_type = 'AAP'
	   AND    action_information1 = p_year -- Bug 5231500
           AND    source_id = p_pt_org_id
           AND    TO_DATE(action_information8,'DD-MM-YY')=
           ( SELECT MAX(TO_DATE(action_information8,'DD-MM-YY'))
             FROM   pay_action_information
             WHERE  action_information_category = 'IN_PT_ASG'
             AND    action_context_type = 'AAP'
	     AND    action_information1 = p_year -- Bug 5231500
             AND    TO_DATE(action_information8, 'DD-MM-YYYY') BETWEEN p_period_start AND p_period_end
             AND    source_id = p_pt_org_id
           )
         );

--Organization Details based on payroll action id found in above CURSOR
CURSOR c_org_details(p_payroll_action_id NUMBER
                    ,p_pt_org_id         VARCHAR2)
IS
   SELECT action_information7   employer_code
         ,action_information4   registered_name
         ,action_information6   reg_address
         ,action_information5   rep_name
         ,action_information9   rep_desg
         ,action_information8   org_name
         ,action_information3   bsrtc
   FROM  pay_action_information
   WHERE action_information_category = 'IN_PT_PAY'
   AND   action_context_type = 'PA'
   AND   source_id = p_pt_org_id
   AND   action_context_id   = p_payroll_action_id;

--Challan Information
CURSOR  c_challan(p_pt_org_id    NUMBER
                 ,p_period_start DATE
                 ,p_period_end   DATE)
IS
   SELECT NVL(SUM(fnd_number.canonical_to_number(org_information5)),0) challan_amt
         ,NVL(SUM(fnd_number.canonical_to_number(org_information6)),0) interest_amt
         ,NVL(SUM(fnd_number.canonical_to_number(org_information8)),0) excess_amt
   FROM   hr_organization_information
   WHERE  organization_id = p_pt_org_id
   AND    org_information_context = 'PER_IN_PT_CHALLAN_INFO'
   AND    ADD_MONTHS(TO_DATE('01-'|| org_information1 || SUBSTR(org_information9, 1, 4), 'DD-MM-YYYY'), 3)
          BETWEEN p_period_start AND p_period_end;

cursor cur_get_records_number(p_source_id NUMBER
                             ,p_year      VARCHAR2
                             ,p_month     NUMBER
			     ,p_min_sal   NUMBER
                             ,p_max_sal   NUMBER)
IS
SELECT COUNT(*)                           count
      ,fnd_number.canonical_to_number(pai.action_information5) rate
  FROM pay_action_information pai
 WHERE pai.jurisdiction_code = 'MH'
   AND pai.source_id = p_source_id
   AND pai.action_information_category = 'IN_PT_ASG'
   AND pai.action_information1 = p_year
   AND TO_NUMBER(pai.action_information2) = p_month
   AND pai.action_context_type = 'AAP'
   AND pai.action_information6 <> 'Yes'
   AND pai.action_information_id = (SELECT MAX(action_information_id)
                                      FROM pay_action_information
                                     WHERE action_information1 = p_year
                                       AND TO_NUMBER(action_information2) = p_month
                                       AND assignment_id = pai.assignment_id
                                       AND action_context_type = 'AAP'
                                       AND action_information_category = 'IN_PT_ASG'
                                       AND jurisdiction_code = 'MH'
                                       AND source_id = p_source_id)
   AND fnd_number.canonical_to_number(pai.action_information4) BETWEEN p_min_sal and  p_max_sal
   GROUP BY  pai.action_information5
   ORDER BY pai.action_information5;

 CURSOR cur_sal_range(p_period_start date)
 IS
 SELECT  fnd_number.canonical_to_number(row_low_range_or_name) min_sal,
         fnd_number.canonical_to_number(row_high_range)  max_sal
 FROM pay_user_rows_f
 WHERE user_table_id IN (SELECT user_table_id
                           FROM pay_user_tables
			  WHERE user_table_name LIKE 'India Professional Tax Rate for MH'
			    AND legislation_code ='IN')
 AND p_period_start BETWEEN  effective_start_date and effective_end_date
 ORDER BY user_row_id;

  l_bg_id             NUMBER;
  l_payroll_act_id    NUMBER;
  l_period_month      NUMBER;
  l_count_0           NUMBER;
--  l_count_30          NUMBER;
  l_count_60          NUMBER;
  l_count_120         NUMBER;
  l_count_175         NUMBER;
  l_count_200         NUMBER;
  l_count_300         NUMBER;
  l_count_200_temp    NUMBER;
  l_count_300_temp    NUMBER;
  l_slab_month_count  NUMBER;
  l_slab              NUMBER;
  l_cnt_60            NUMBER;
  l_cnt_120           NUMBER;
--  l_tax_slab_2        NUMBER;
  l_tax_slab_3        NUMBER;
  l_tax_slab_4        NUMBER;
  l_tax_slab_5        NUMBER;
  l_tax_slab_6        NUMBER;
--  l_slab_2            NUMBER;
  l_slab_3            NUMBER;
  l_slab_4            NUMBER;
  l_slab_5            NUMBER;
  l_slab_6            NUMBER;
  l_slab_6_2          NUMBER; --For 300
  l_tax_amount        NUMBER;
  l_net_amount        NUMBER;
  l_excess_tax        NUMBER;
  l_interest_amount   NUMBER;
  l_period_year       VARCHAR2(40);
  l_sys_date_time     VARCHAR2(40);
  period_start_year   VARCHAR2(40);
  l_slab_month_tag    VARCHAR2(40);
  l_tag               VARCHAR2(1000);
  l_bsrtc_no          VARCHAR2(50);
  l_reg_address       VARCHAR2(240);
  period_start        DATE;
  period_end          DATE;
  l_date              DATE;
  l_registered_no     hr_organization_information.org_information1%TYPE;
  l_registered_name   hr_organization_units.name%TYPE;
  l_rep_name          per_all_people_f.full_name%TYPE;
  l_rep_desg          per_all_positions.name%TYPE;
  l_org_name          hr_organization_units.name%TYPE;
  l_message           VARCHAR2(255);
  l_procedure         VARCHAR2(100);

  l_slab_change09 DATE := to_date('01-07-2009','DD-MM-YYYY');
  /*This variable is used to make the slab rate zero for employees with salary upto 5000*/


  BEGIN
   l_procedure := g_package ||'create_pt_form3_xml';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

--    l_slab_2   := 30;
    l_slab_3   := 60;
    l_slab_4   := 120;
    l_slab_5   := 175;
    l_slab_6   := 200;
    l_slab_6_2 := 300;
    --
    l_bg_id:=fnd_profile.value('PER_BUSINESS_GROUP_ID');

    fnd_file.put_line(fnd_file.log,'Creating the XML...');

    dbms_lob.createtemporary(g_xml_data,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(g_xml_data,dbms_lob.lob_readwrite);
     --
    l_tag :='<?xml version="1.0"  encoding="UTF-8"?>';
    dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
    l_tag := '<PT_FORM3>';
    dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

    fnd_file.put_line(fnd_file.log,'Started...');
    fnd_file.put_line(fnd_file.log,'Creating XML for PT Form III.');

    --System Date:
    l_sys_date_time := to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');
    l_tag :=pay_in_xml_utils.getTag('c_sys_date_in_hh_mm_ss',l_sys_date_time);
    dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

    IF g_debug THEN
       pay_in_utils.trace('Business Group id           ',l_bg_id);
       pay_in_utils.trace('System Date and Time        ',l_sys_date_time);
     END IF;


    pay_in_utils.set_location(g_debug,l_procedure, 20);

    period_start_year := SUBSTR(p_year, 1, 4);
    IF p_frequency = 'A' THEN
       period_start := TO_DATE('01-03-'||period_start_year, 'DD-MM-YYYY');
       period_end := ADD_MONTHS(period_start, 12) -1;
    ELSIF p_frequency = 'Q' THEN
       period_start := ADD_MONTHS(TO_DATE('01-03-'||period_start_year, 'DD-MM-YYYY'), TO_NUMBER(SUBSTR(p_period, 2, 2)));
       IF TO_NUMBER(TO_CHAR(period_start, 'YYYY')) > TO_NUMBER(period_start_year) THEN
          period_start := ADD_MONTHS(period_start, -12);
       END IF;
       period_end := ADD_MONTHS(period_start, 3) -1;
    ELSIF p_frequency = 'M' THEN
       period_start := ADD_MONTHS(TO_DATE('01-03-'|| period_start_year, 'DD-MM-YYYY'), MOD(TO_NUMBER(p_period),12));
       period_end := ADD_MONTHS(period_start, 1) -1;
    END IF;

   pay_in_utils.set_location(g_debug,l_procedure, 30);

    IF g_debug THEN
       pay_in_utils.trace('period_start_year       ',period_start_year);
       pay_in_utils.trace('period_start            ',period_start);
       pay_in_utils.trace('period_end              ',period_end);
     END IF;


    FOR c_rec IN c_distinct_org (period_start
                                ,period_end)
    LOOP
        l_tag :='<organization>';
        pay_in_utils.set_location(g_debug,l_procedure, 40);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

         IF g_debug THEN
            pay_in_utils.trace('c_rec.org_id       ',c_rec.org_id);
         END IF;

        fnd_file.put_line(fnd_file.log,'c_rec.org_id            '|| c_rec.org_id);

        OPEN c_max_pa_action_id(c_rec.org_id
                               ,period_start
                               ,period_end);
        FETCH c_max_pa_action_id INTO l_payroll_act_id;
        CLOSE c_max_pa_action_id ;

         IF g_debug THEN
            pay_in_utils.trace('Payroll Action id       ',l_payroll_act_id);
         END IF;

        pay_in_utils.set_location(g_debug,l_procedure, 50);

        OPEN c_org_details(l_payroll_act_id
                          ,c_rec.org_id);
        FETCH c_org_details INTO l_registered_no
                                ,l_registered_name
                                ,l_reg_address
                                ,l_rep_name
                                ,l_rep_desg
                                ,l_org_name
                                ,l_bsrtc_no;
        CLOSE c_org_details;
        pay_in_utils.set_location(g_debug,l_procedure, 60);
        -- Registered No
        l_tag :=pay_in_xml_utils.getTag('c_registered_no', l_registered_no);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        --Organization Name and Address
        l_tag :=pay_in_xml_utils.getTag('c_registered_name', l_registered_name);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        l_tag :=pay_in_xml_utils.getTag('c_registered_address', l_reg_address);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        --Report Period
        l_tag :=pay_in_xml_utils.getTag('c_period_from', to_char(period_start));
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        l_tag :=pay_in_xml_utils.getTag('c_period_to', to_char(period_end));
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        --Organization Rep Name and Designation
        l_tag :=pay_in_xml_utils.getTag('c_rep_name', l_rep_name);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        l_tag :=pay_in_xml_utils.getTag('c_rep_desg', l_rep_desg);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        --BSRTC No
        l_tag :=pay_in_xml_utils.getTag('c_bsrtc_no', l_bsrtc_no);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        --Date
        l_tag :=pay_in_xml_utils.getTag('c_date', substr(l_sys_date_time, 1, 11));
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        pay_in_utils.set_location(g_debug,l_procedure, 70);

            IF g_debug THEN
               pay_in_utils.trace('Registered No           ',l_registered_no);
               pay_in_utils.trace('Registered Name         ',l_registered_name);
               pay_in_utils.trace('Registered Address      ',l_reg_address);
               pay_in_utils.trace('BSRTC no                ',l_bsrtc_no);
               pay_in_utils.trace('Period Start            ',period_start);
               pay_in_utils.trace('Period End              ',period_end);
             END IF;

        l_count_0           := 0;
--        l_count_30          := 0;
        l_count_60          := 0;
        l_count_120         := 0;
        l_count_175         := 0;
        l_count_200         := 0;
        l_count_300         := 0;
        l_cnt_60            := 0;
        l_cnt_120           := 0;
--        l_tax_slab_2        := 0;
        l_tax_slab_3        := 0;
        l_tax_slab_4        := 0;
        l_tax_slab_5        := 0;
        l_tax_slab_6        := 0;
        l_net_amount        := 0;
        l_tax_amount        := 0;
        l_excess_tax        := 0;
        l_interest_amount   := 0;

        l_date := period_start;

      /* From Jul 2009 Slab rate is zero for rang 0-5000 */
       IF  period_start >= l_slab_change09
       THEN
       l_slab_3 := 0;
       l_slab_4 := 0;
       END IF;

        pay_in_utils.set_location(g_debug,l_procedure, 80);

        -- Getting the records for each month in the report period
        WHILE l_date < period_end
        LOOP

            l_slab_month_count  := 0;
            l_count_200_temp    := 0;
            l_count_300_temp    := 0;

            fnd_file.put_line(fnd_file.log,'l_date:                  '|| l_date);

            l_period_month := TO_NUMBER(TO_CHAR(ADD_MONTHS(l_date, -3), 'MM'));

            IF l_period_month >= 10 THEN
               l_period_year := TO_CHAR(ADD_MONTHS(l_date, -12), 'YYYY')||'-'||TO_CHAR(l_date, 'YYYY');
            ELSE
              l_period_year := TO_CHAR(l_date, 'YYYY')||'-'||TO_CHAR(ADD_MONTHS(l_date, 12), 'YYYY');
            END IF;


            IF g_debug THEN
               pay_in_utils.trace('l_date                  ',l_date);
               pay_in_utils.trace('l_period_month           ',l_period_month);
             END IF;
        pay_in_utils.set_location(g_debug,l_procedure, 90);

         FOR rec_sal in cur_sal_range(period_start)
	 LOOP
            -- Getting the no. of employees in each slab
            FOR rec_count in cur_get_records_number(c_rec.org_id
                                                   ,l_period_year
                                                   ,l_period_month
                                                   ,rec_sal.min_sal
                                                   ,rec_sal.max_sal)
            LOOP
                IF  rec_sal.min_sal = 0 AND rec_sal.max_sal = 2500 THEN
                  l_count_0 := l_count_0 + rec_count.count;
                  l_slab_month_count := rec_count.count;
                  l_slab := 1;
/*                ELSIF rec_count.rate = l_slab_2 THEN
                  l_count_30 := l_count_30 + rec_count.count;
                  l_slab_month_count := rec_count.count;
                  l_slab := 2;*/
                ELSIF rec_sal.min_sal = 2500.01 AND rec_sal.max_sal = 3500 THEN
                  l_count_60 := l_count_60 + rec_count.count;
                  l_slab_month_count := rec_count.count;
                  IF rec_count.rate <> 0  THEN
                  l_cnt_60 := l_cnt_60 + rec_count.count;
                  END IF;
                  l_slab := 3;
                ELSIF rec_sal.min_sal = 3500.01 AND rec_sal.max_sal = 5000 THEN
                  l_count_120 := l_count_120 + rec_count.count;
                  l_slab_month_count := rec_count.count;
                  IF rec_count.rate <> 0  THEN
                  l_cnt_120 := l_cnt_120 + rec_count.count;
                  END IF;
                  l_slab := 4;
                ELSIF rec_count.rate = l_slab_5 THEN
                  l_count_175 := l_count_175 + rec_count.count;
                  l_slab_month_count := rec_count.count;
                  l_slab := 5;
                ELSIF rec_count.rate = l_slab_6 THEN
                  l_count_200 := l_count_200 + rec_count.count;
                  l_count_200_temp := rec_count.count;
                  l_slab := 6;
                ELSIF rec_count.rate = l_slab_6_2 THEN
                  l_count_300 := l_count_300 + rec_count.count;
                  l_count_300_temp := rec_count.count;
                  l_slab := 6;
                END IF;

               IF g_debug THEN
                 pay_in_utils.trace('PT slab rate            ',rec_count.rate);
                 pay_in_utils.trace('Count of Records        ',rec_count.count);
               END IF;

               pay_in_utils.set_location(g_debug,l_procedure, 100);

                IF l_slab <> 6 THEN
                   -- Writing to the report if the slab is not the highest slab
                   -- Highest slab is written to the report once the loop is over since a sum is to be taken for 200 and 300
                   l_slab_month_tag := 'c_month' || l_period_month || '_emp_slab'|| l_slab;
                   fnd_file.put_line(fnd_file.log,'l_slab_month_tag:        '|| l_slab_month_tag);
                   l_tag := pay_in_xml_utils.getTag(l_slab_month_tag, l_slab_month_count);
                   dbms_lob.writeAppend(g_xml_data, LENGTH(l_tag), l_tag);
                END IF;

            END LOOP;
	  END LOOP;

            IF g_debug THEN
               pay_in_utils.trace('l_slab_month_tag           ',l_slab_month_tag);
               pay_in_utils.trace('l_count_0                  ',l_count_0);
--               pay_in_utils.trace('l_count_30                 ',l_count_30);
               pay_in_utils.trace('l_count_60                 ',l_count_60);
               pay_in_utils.trace('l_count_120                ',l_count_120);
               pay_in_utils.trace('l_count_175                ',l_count_175);
               pay_in_utils.trace('l_count_200+l_count_300    ',(l_count_200 + l_count_300));

             END IF;


            pay_in_utils.set_location(g_debug,l_procedure, 110);

            l_slab_month_count := l_count_300_temp + l_count_200_temp;

            IF l_slab_month_count <> 0 THEN
               -- Writing to the file for the highest slab
               l_slab_month_tag := 'c_month' || l_period_month || '_emp_slab6';
               l_tag := pay_in_xml_utils.getTag(l_slab_month_tag, l_slab_month_count);
               dbms_lob.writeAppend(g_xml_data, LENGTH(l_tag), l_tag);
            END IF;

            l_date := ADD_MONTHS(l_date, 1);

        END LOOP;
        pay_in_utils.set_location(g_debug,l_procedure, 120);

        -- Writing the total employees in a slab
        l_tag := pay_in_xml_utils.getTag('c_emp_slab_1', l_count_0);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
--        l_tag := pay_in_xml_utils.getTag('c_emp_slab_2', l_count_30);
--        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        l_tag := pay_in_xml_utils.getTag('c_emp_slab_3', l_count_60);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        l_tag := pay_in_xml_utils.getTag('c_emp_slab_4', l_count_120);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        l_tag := pay_in_xml_utils.getTag('c_emp_slab_5', l_count_175);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        l_tag := pay_in_xml_utils.getTag('c_emp_slab_6', l_count_200 + l_count_300);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

        -- Calculating the PT paid in each slab
--        l_tax_slab_2 := l_slab_2 * l_count_30;
        l_tax_slab_3 := l_slab_3 * l_cnt_60;
        l_tax_slab_4 := l_slab_4 * l_cnt_120;
        l_tax_slab_5 := l_slab_5 * l_count_175;
        l_tax_slab_6 := l_slab_6 * l_count_200 + l_slab_6_2 * l_count_300;



      /*To maintain two formats of the report before to Jul09 and from Jul09*/
         IF l_slab_3 = 0  THEN
                 l_tag := pay_in_xml_utils.getTag('c_rate_1', 'Nil');
                 dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
         ELSE
                 l_tag := pay_in_xml_utils.getTag('c_rate_1', 'Rs. 60');
                 dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
         END IF;

         IF l_slab_4 = 0  THEN
                 l_tag := pay_in_xml_utils.getTag('c_rate_2', 'Nil');
                 dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
         ELSE
                 l_tag := pay_in_xml_utils.getTag('c_rate_2', 'Rs. 120');
                 dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
         END IF;

	IF l_cnt_60 = 0 THEN
           l_tag := pay_in_xml_utils.getTag('c_rs1', 'Nil');
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
           l_tag := pay_in_xml_utils.getTag('c_tax_slab_3', '');
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        ELSE
           l_tag := pay_in_xml_utils.getTag('c_rs1', 'Rs.');
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_tax_slab_3', pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_tax_slab_3,0)));
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        END IF;

        IF l_cnt_120 = 0  THEN
           l_tag := pay_in_xml_utils.getTag('c_rs2', 'Nil');
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
           l_tag := pay_in_xml_utils.getTag('c_tax_slab_4', '');
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        ELSE
           l_tag := pay_in_xml_utils.getTag('c_rs2', 'Rs.');
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_tax_slab_4', pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_tax_slab_4,0)));
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        END IF;


        -- Writing to file the calculated PT paid in each slab
--        l_tag := pay_in_xml_utils.getTag('c_tax_slab_2', pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_tax_slab_2,0)));
--        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        l_tag := pay_in_xml_utils.getTag('c_tax_slab_5', pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_tax_slab_5,0)));
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        l_tag := pay_in_xml_utils.getTag('c_tax_slab_6', pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_tax_slab_6,0)));
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

        pay_in_utils.set_location(g_debug,l_procedure, 130);

        -- Getting the actual PT paid from the challans data
        OPEN c_challan(c_rec.org_id
                      ,period_start
                      ,period_end);
        FETCH c_challan INTO l_tax_amount
                            ,l_interest_amount
                            ,l_excess_tax;
        CLOSE c_challan;

            IF g_debug THEN
               pay_in_utils.trace('Tax Amount               ',l_tax_amount);
               pay_in_utils.trace('Interest Amount          ',l_interest_amount);
               pay_in_utils.trace('Excess Tax               ',l_excess_tax);
             END IF;


        l_tag := pay_in_xml_utils.getTag('c_tax_amount', pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_tax_amount,0)));
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

        l_tag := pay_in_xml_utils.getTag('c_interest_amount', pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_interest_amount,0)));
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

        l_tag := pay_in_xml_utils.getTag('c_excess_tax', pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_excess_tax,0)));
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

        l_net_amount := l_tax_amount - l_excess_tax + l_interest_amount;

        l_tag := pay_in_xml_utils.getTag('c_net_amount', pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_net_amount,0)));
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

        l_tag := pay_in_xml_utils.getTag('c_total_amount_words', initcap(pay_in_utils.number_to_words(l_net_amount)));
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

        l_tag :=pay_in_xml_utils.getTag('c_year', period_start_year);
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        l_tag :=pay_in_xml_utils.getTag('c_year1', SUBSTR(p_year, 6, 4));
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

        l_tag :='</organization>';
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        pay_in_utils.set_location(g_debug,l_procedure, 140);
        fnd_file.put_line(fnd_file.log,'Org Over');
    END LOOP;
    l_tag :='</PT_FORM3>';
    dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
    fnd_file.put_line(fnd_file.log,'XML Created.');
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);

END create_pt_form3_xml;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : WRITE_TAG                                           --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : This procedure inserts tags into the clob variable  --
-- Parameters     :                                                     --
--             IN : p_tag_name       VARCHAR2                           --
--                  p_tag_value      VARCHAR2                           --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 27-Jul-2005    vgsriniv   Initial Version                      --
--------------------------------------------------------------------------

PROCEDURE write_tag ( p_tag_name  IN VARCHAR2
                    , p_tag_value IN VARCHAR2)
IS
    l_tag VARCHAR2(10000);
    l_procedure VARCHAR2(100);
BEGIN
   l_procedure := g_package ||'write_tag';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

     l_tag := pay_in_xml_utils.getTag( p_tag_name  => p_tag_name
                                     , p_tag_value => p_tag_value
                                     );

     dbms_lob.writeAppend(g_xml_data,length(l_tag),l_tag);
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
END write_tag;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_LOCATION_DETAILS                                --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : This function gets the gre location details        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_location_id         hr_locations.location_id      --
--                : p_concatenate         VARCHAR2                      --
--                  p_field               VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_location_details ( p_location_id  IN  VARCHAR2
                               ,p_field        IN   VARCHAR2     DEFAULT NULL)
RETURN VARCHAR2
IS

   CURSOR csr_add IS
      SELECT address_line_1,
             address_line_2,
             address_line_3,
             loc_information14,
             loc_information15,
             hr_general.decode_lookup('IN_STATES',loc_information16),
             postal_code,
	     telephone_number_1,
             telephone_number_2
        FROM hr_locations
       WHERE location_id = p_location_id;

   l_add_1    hr_locations.address_line_1%TYPE;
   l_add_2    hr_locations.address_line_2%TYPE;
   l_add_3    hr_locations.address_line_3%TYPE;
   l_add_4    hr_locations.loc_information14%TYPE;
   l_add_5    hr_locations.loc_information15%TYPE;
   l_state    hr_lookups.meaning%TYPE;
   l_pin      hr_locations.postal_code%TYPE;
   l_tel      hr_locations.telephone_number_1%TYPE;
   l_fax      hr_locations.telephone_number_2%TYPE;
   l_details  VARCHAR2(1000);
   l_message   VARCHAR2(255);
   l_procedure VARCHAR2(100);

  --
BEGIN

 g_debug := hr_utility.debug_enabled;
 l_procedure := g_package ||'get_location_details';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   OPEN csr_add;
   FETCH csr_add INTO l_add_1, l_add_2, l_add_3, l_add_4, l_add_5, l_state, l_pin,l_tel,l_fax;
   CLOSE csr_add;

  IF p_field = 'EMPLOYER_ADDRESS1' THEN
     l_details := l_add_1;
  ELSIF p_field = 'EMPLOYER_ADDRESS2' THEN
     l_details := l_add_2;
  ELSIF p_field = 'EMPLOYER_ADDRESS3' THEN
     l_details := l_add_3;
  ELSIF p_field = 'EMPLOYER_ADDRESS4' THEN
     l_details := l_add_4;
  ELSIF p_field = 'CITY' THEN
     l_details := l_add_5;
  ELSIF p_field = 'EMPLOYER_STATE' THEN
     l_details := l_state;
  ELSIF p_field = 'POSTAL_CODE' THEN
     l_details := l_pin;
  ELSIF p_field = 'TELEPHONE' THEN
     l_details := l_tel;
  ELSIF p_field = 'FAX' THEN
     l_details := l_fax;
  END IF;

IF g_debug THEN
       pay_in_utils.trace('Location id       ',p_location_id);
       pay_in_utils.trace('Field             ',p_field);
       pay_in_utils.trace('Address Details   ',l_details);
   END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

  RETURN l_details;

END get_location_details;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_FORM27A_XML                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure creates XML data for Form 27A        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_gre_org_id    VARCHAR2                            --
--                  p_assess_year   VARCHAR2                            --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 27-Jul-2005    vgsriniv   Initial Version                      --
--------------------------------------------------------------------------

PROCEDURE create_form27A_xml(p_gre_org_id  IN VARCHAR2
                            ,p_assess_year IN VARCHAR2)
IS

CURSOR csr_org_max_action_context_id
  IS
    SELECT MAX(pai.action_context_id)
      FROM pay_action_information                pai
     WHERE pai.action_information_category     = 'IN_EOY_ORG'
       AND pai.Action_information1             = p_gre_org_id
       AND pai.action_information3             = p_assess_year
       AND pai.action_context_type             = 'PA';


CURSOR csr_emplr_details(p_action_context_id IN NUMBER)
IS
 SELECT  pai.action_information4
       , pai.action_information2
       , pai.action_information8
       , pay_in_reports_pkg.get_location_details(pai.action_information7,'EMPLOYER_ADDRESS1')
       , pay_in_reports_pkg.get_location_details(pai.action_information7,'EMPLOYER_ADDRESS2')
       , pay_in_reports_pkg.get_location_details(pai.action_information7,'EMPLOYER_ADDRESS3')
       , pay_in_reports_pkg.get_location_details(pai.action_information7,'EMPLOYER_ADDRESS4')
       , pay_in_reports_pkg.get_location_details(pai.action_information7,'CITY')
       , pay_in_reports_pkg.get_location_details(pai.action_information7,'EMPLOYER_STATE')
       , pay_in_reports_pkg.get_location_details(pai.action_information7,'POSTAL_CODE')
       , pay_in_reports_pkg.get_location_details(pai.action_information7,'TELEPHONE')
       , pay_in_reports_pkg.get_location_details(pai.action_information7,'FAX')
       , pai.action_information11
       , pay_in_reports_pkg.get_location_details(pai.action_information16,'EMPLOYER_ADDRESS1')
       , pay_in_reports_pkg.get_location_details(pai.action_information16,'EMPLOYER_ADDRESS2')
       , pay_in_reports_pkg.get_location_details(pai.action_information16,'EMPLOYER_ADDRESS3')
       , pay_in_reports_pkg.get_location_details(pai.action_information16,'EMPLOYER_ADDRESS4')
       , pay_in_reports_pkg.get_location_details(pai.action_information16,'CITY')
       , pay_in_reports_pkg.get_location_details(pai.action_information16,'EMPLOYER_STATE')
       , pay_in_reports_pkg.get_location_details(pai.action_information16,'POSTAL_CODE')
       , pai.action_information17
       , pai.action_information18
       , pai.action_information13
  FROM   pay_action_information pai
       , pay_payroll_actions ppa
 WHERE   pai.action_information_category = 'IN_EOY_ORG'
   AND   pai.action_context_type = 'PA'
   AND   pai.action_information1 = p_gre_org_id
   AND   pai.action_information3 = p_assess_year
   AND   pai.action_context_id = p_action_context_id
   AND   ppa.action_type='X'
   AND   ppa.action_status = 'C'
   AND   ppa.report_type='IN_EOY_ARCHIVE'
   AND   ppa.report_qualifier = 'IN'
   AND   ppa.payroll_action_id = pai.action_context_id;

CURSOR csr_tot_emp_cnt
IS
 SELECT  COUNT(*)
   FROM  pay_action_information
  WHERE  action_information_category = 'IN_EOY_PERSON'
    AND  action_context_type = 'AAP'
    AND  action_information2 =  p_assess_year
    AND  action_information3 =  p_gre_org_id
    AND  action_context_id  IN ( SELECT  MAX(action_context_id)
                                 FROM  pay_action_information pai
                                      ,pay_assignment_actions paa
				      ,per_assignments_f asg
                                WHERE  pai.action_information_category = 'IN_EOY_PERSON'
                                  AND  pai.action_context_type = 'AAP'
                                  AND  pai.action_information2 = p_assess_year
                                  AND  pai.action_information3 = p_gre_org_id
				  AND  pai.assignment_id       = asg.assignment_id
				  AND  asg.business_group_id   = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
                                  AND  pai.source_id = paa.assignment_action_id
                             GROUP BY  pai.action_information1,pai.action_information17 );


CURSOR csr_tax_details(p_balance VARCHAR2,p_action_context_id NUMBER,p_source_id IN NUMBER)
IS
 SELECT NVL(SUM(fnd_number.canonical_to_number(action_information2)),0)
   FROM pay_action_information
  WHERE action_information_category = 'IN_EOY_ASG_SAL'
    AND action_context_type = 'AAP'
    AND action_information1 = p_balance
    AND action_context_id = p_action_context_id
    AND source_id = p_source_id;

CURSOR csr_get_max_cont_id IS
      SELECT MAX(pai.action_context_id) action_cont_id
            ,source_id sour_id
        FROM pay_action_information      pai
            ,pay_assignment_actions      paa
	    ,per_assignments_f       asg
       WHERE pai.action_information_category = 'IN_EOY_PERSON'
         AND pai.action_information3         = p_gre_org_id
         AND pai.action_information2         = p_assess_year
	 AND pai.assignment_id               = asg.assignment_id
         AND asg.business_group_id           = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
         AND pai.action_context_type         = 'AAP'
         AND pai.source_id                   = paa.assignment_action_id
    GROUP BY pai.action_information1,pai.action_information17,source_id;


l_tag               VARCHAR2(2000);
l_sys_date_time     VARCHAR2(30);
l_sys_date          VARCHAR2(30);
l_org_max_action_id NUMBER;
l_tan               VARCHAR2(20);
l_pan               VARCHAR2(20);
l_leg_name          VARCHAR2(80);
l_add1              VARCHAR2(100);
l_add2              VARCHAR2(100);
l_add3              VARCHAR2(100);
l_add4              VARCHAR2(100);
l_add5              VARCHAR2(100);
l_state             VARCHAR2(100);
l_pin               VARCHAR2(100);
l_tel               VARCHAR2(100);
l_fax               VARCHAR2(100);
l_rep_name          VARCHAR2(100);
l_rep_add1          VARCHAR2(100);
l_rep_add2          VARCHAR2(100);
l_rep_add3          VARCHAR2(100);
l_rep_add4          VARCHAR2(100);
l_rep_add5          VARCHAR2(100);
l_rep_state         VARCHAR2(100);
l_rep_pin           VARCHAR2(100);
l_rep_tel           VARCHAR2(100);
l_rep_fax           VARCHAR2(100);
l_rep_desg          VARCHAR2(100);
l_year              VARCHAR2(9);
l_tot_emp           NUMBER;
l_tot_income        NUMBER:=0;
l_it_td             NUMBER;
l_sc_td             NUMBER;
l_ec_td             NUMBER;
l_tds               NUMBER:=0;
l_bg_id             NUMBER;
l_itd               NUMBER:=0;
l_inc               NUMBER:=0;
l_message           VARCHAR2(255);
l_procedure        VARCHAR2(100);



BEGIN

 g_debug := hr_utility.debug_enabled;
 l_procedure := g_package ||'create_form27A_xml';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
       pay_in_utils.trace('GRE id            ',p_gre_org_id);
       pay_in_utils.trace('Assessment year    ',p_assess_year);
   END IF;


  pay_in_xml_utils.gXMLTable.DELETE;
--
  fnd_file.put_line(fnd_file.log,'Creating the XML...');
  dbms_lob.createtemporary(g_xml_data,FALSE,DBMS_LOB.CALL);
  dbms_lob.open(g_xml_data,dbms_lob.lob_readwrite);
--
  l_tag :='<?xml version="1.0"  encoding="UTF-8"?>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  l_tag := '<FORM27A>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
  fnd_file.put_line(fnd_file.log,'Started...');

  pay_in_utils.set_location(g_debug,l_procedure, 20);
--
  fnd_file.put_line(fnd_file.log,'Creating XML for Employer Details.');
  l_sys_date_time:=TO_CHAR(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');
  l_sys_date := TO_CHAR(SYSDATE,'DD-Mon-YYYY');
  l_bg_id:=fnd_profile.value('PER_BUSINESS_GROUP_ID');
--System Date
  l_tag :=pay_in_xml_utils.getTag('c_current_date_in_hh_mm_ss',l_sys_date_time);
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  pay_in_utils.set_location(g_debug,l_procedure, 30);

  OPEN csr_org_max_action_context_id;
  FETCH csr_org_max_action_context_id INTO l_org_max_action_id;
  CLOSE csr_org_max_action_context_id;

  OPEN csr_emplr_details(l_org_max_action_id);
  FETCH csr_emplr_details INTO l_tan,l_pan,l_leg_name,l_add1,l_add2,l_add3,l_add4,l_add5,
                              l_state,l_pin,l_tel,l_fax,l_rep_name,l_rep_add1,l_rep_add2,
                              l_rep_add3,l_rep_add4,l_rep_add5,l_rep_state,l_rep_pin,
                              l_rep_tel,l_rep_fax,l_rep_desg;
  CLOSE csr_emplr_details;


  OPEN csr_tot_emp_cnt;
  FETCH csr_tot_emp_cnt INTO l_tot_emp;
  CLOSE csr_tot_emp_cnt;

   pay_in_utils.set_location(g_debug,l_procedure, 40);

  FOR i IN  csr_get_max_cont_id
  LOOP
      pay_in_utils.set_location(g_debug,l_procedure, 50);
      OPEN csr_tax_details('Income Tax Deduction',i.action_cont_id,i.sour_id);
      FETCH csr_tax_details INTO l_itd;
      CLOSE csr_tax_details;

      l_tds := l_tds + l_itd;

      OPEN csr_tax_details('F16 Total Income',i.action_cont_id,i.sour_id);
      FETCH csr_tax_details INTO l_inc;
      CLOSE csr_tax_details;

      l_tot_income := l_tot_income + l_inc;

   END LOOP;

  l_year := (SUBSTR(p_assess_year,1,4)||'-'||SUBSTR(p_assess_year,8));

  WRITE_TAG('C_TAN',l_tan);
  WRITE_TAG('C_PAN',l_pan);
  WRITE_TAG('C_LEG_NAME',l_leg_name);
  WRITE_TAG('C_ADD1',l_add1);
  WRITE_TAG('C_ADD2',l_add2);
  WRITE_TAG('C_ADD3',l_add3);
  WRITE_TAG('C_ADD4',l_add4);
  WRITE_TAG('C_ADD5',l_add5);
  WRITE_TAG('C_STATE',l_state);
  WRITE_TAG('C_PIN',l_pin);
  WRITE_TAG('C_TEL',l_tel);
  WRITE_TAG('C_FAX',l_fax);

  WRITE_TAG('C_REP_TAN',l_tan);
  WRITE_TAG('C_REP_ADD1',l_rep_add1);
  WRITE_TAG('C_REP_ADD2',l_rep_add2);
  WRITE_TAG('C_REP_ADD3',l_rep_add3);
  WRITE_TAG('C_REP_ADD4',l_rep_add4);
  WRITE_TAG('C_REP_ADD5',l_rep_add5);
  WRITE_TAG('C_REP_STATE',l_rep_state);
  WRITE_TAG('C_REP_PIN',l_rep_pin);
  WRITE_TAG('C_REP_TEL',l_rep_teL);
  WRITE_TAG('C_REP_FAX',l_rep_fax);

  WRITE_TAG('C_TOT_AMT_PAID',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_tot_income));
  WRITE_TAG('C_TDS',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_tds));
  WRITE_TAG('C_TOT_EMP',l_tot_emp);

  WRITE_TAG('C_ASSESS_YEAR',l_year);
  WRITE_TAG('C_REP_NAME',l_rep_name);
  WRITE_TAG('C_CITY',l_rep_add5);
  WRITE_TAG('C_SYS_DATE',l_sys_date);
  WRITE_TAG('C_SYS_DATE_TIME',l_sys_date_time);
  WRITE_TAG('C_REP_DESG',l_rep_desg);


 l_tag := '</FORM27A>';
 dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  fnd_file.put_line(fnd_file.log,'XML Created.');
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 60);


END create_form27A_xml;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : INIT_CODE                                           --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure calls procedure for PF Form3A or PF  --
--                    Form6A depending on the report type parameter     --
-- Parameters     :                                                     --
--             IN : p_contribution_period                VARCHAR2       --
--                    p_report_type                      VARCHAR2       --
--                    p_pf_org_id                        VARCHAR2       --
--                    p_pf_number                        VARCHAR2       --
--                    p_template_appl                    VARCHAR2       --
--                    p_template_code                    VARCHAR2       --
--                    p_number_of_copies                 VARCHAR2       --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 01-Jan-2005    aaagarwa   Initial Version                      --
-- 115.1 08-Mar-2005    lnagaraj   Added for Form 7                     --
--------------------------------------------------------------------------
PROCEDURE init_code
          (p_pf_org_id            IN VARCHAR2  DEFAULT NULL
          ,p_pf_number            IN VARCHAR2  DEFAULT NULL
          ,p_pension_number       IN VARCHAR2  DEFAULT NULL
          ,p_contribution_period  IN VARCHAR2  DEFAULT NULL
          ,p_form_type            IN VARCHAR2
          ,p_employee_type        IN VARCHAR2  DEFAULT NULL
          ,p_esi_org_id           IN VARCHAR2  DEFAULT NULL
          ,p_esi_coverage         IN VARCHAR2  DEFAULT NULL
          ,p_sysdate              IN DATE      DEFAULT NULL
          ,p_template_name        IN VARCHAR2
          ,p_xml                  OUT NOCOPY CLOB
          ,p_pt_org_id            IN VARCHAR2  DEFAULT NULL
          ,p_frequency            IN VARCHAR2  DEFAULT NULL
          ,p_year                 IN VARCHAR2  DEFAULT NULL
          ,p_period               IN VARCHAR2  DEFAULT NULL
          ,p_gre_org_id           IN VARCHAR2  DEFAULT NULL
          ,p_assess_year          IN VARCHAR2  DEFAULT NULL)
IS
  l_effective_start_date        DATE;
  l_effective_end_date          DATE;
  l_contribution_period         VARCHAR2(40);
  l_message                     VARCHAR2(255);
  l_procedure                   VARCHAR2(100);

BEGIN
  --
 g_debug := hr_utility.debug_enabled;
 l_procedure := g_package ||'init_code';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF p_form_type <> 'ESI6' and p_form_type <> 'PT3' AND p_form_type <> 'FORM27A' THEN
      l_effective_start_date:=to_date(('01-03-'||substr(p_contribution_period,1,4)),'DD-MM-YYYY');
      l_effective_end_date:= to_date(('01-03-'||substr(p_contribution_period,6)),'DD-MM-YYYY')-1;
  ELSE
     l_contribution_period := hr_general.decode_lookup('IN_ESI_CONTRIB_PERIOD',p_contribution_period);
  END IF;

  IF g_debug THEN
       pay_in_utils.trace('PF Organization id  ',p_pf_org_id);
       pay_in_utils.trace('PF Number           ',p_pf_number);
       pay_in_utils.trace('Employee Type       ',p_employee_type);
       pay_in_utils.trace('Contribution Period ',p_contribution_period);
       pay_in_utils.trace('Effective Start Date',l_effective_start_date);
       pay_in_utils.trace('Effective End Date  ',l_effective_end_date);
       pay_in_utils.trace('Pension Number      ',p_pension_number);
       pay_in_utils.trace('ESI Org ID          ',p_esi_org_id);
       pay_in_utils.trace('ESI Coverage        ',p_esi_coverage);
       pay_in_utils.trace('Contribution Period ',l_contribution_period);
       pay_in_utils.trace('Session Date        ',p_sysdate);
       pay_in_utils.trace('PT Org ID           ',p_pt_org_id);
       pay_in_utils.trace('PT Frequency        ',p_frequency);
       pay_in_utils.trace('PT Year             ',p_year);
       pay_in_utils.trace('Period              ',p_period);
   END IF;




  IF p_form_type = 'FORM3A' THEN
     --
   pay_in_utils.set_location(g_debug,l_procedure, 20);
     create_form3a_xml(p_pf_org_id => p_pf_org_id
                      ,p_pf_number => p_pf_number
                      ,p_employee_type=> p_employee_type
                      ,p_contribution_period=> p_contribution_period
                      ,p_effective_start_date => l_effective_start_date
                      ,p_effective_end_date => l_effective_end_date
                      );
  ELSIF p_form_type = 'FORM6A' THEN
     --
   pay_in_utils.set_location(g_debug,l_procedure, 30);
     create_form6a_xml(p_pf_org_id => p_pf_org_id
                      ,p_effective_start_date => l_effective_start_date
                      ,p_effective_end_date => l_effective_end_date
                      ,p_contribution_period=>p_contribution_period
                      );
  ELSIF p_form_type = 'FORM8' THEN
     --
        pay_in_utils.set_location(g_debug,l_procedure, 40);
     create_form8_xml(p_pf_org_id            => p_pf_org_id
                     ,p_contribution_period  => p_contribution_period
                     ,p_effective_start_date => l_effective_start_date
                     ,p_effective_end_date   => l_effective_end_date
                     );
  ELSIF p_form_type ='FORM7' THEN
     --
     pay_in_utils.set_location(g_debug,l_procedure, 50);
     create_form7_xml(p_pf_org_id             => p_pf_org_id
                      ,p_pension_number       => p_pension_number
                      ,p_employee_type        => p_employee_type
                      ,p_contribution_period  => p_contribution_period
                      ,p_effective_start_date => l_effective_start_date
                      ,p_effective_end_date   => l_effective_end_date
                      );
  ELSIF p_form_type ='ESI6' THEN
     --
   pay_in_utils.set_location(g_debug,l_procedure, 60);
     create_esi_xml(p_esi_org_id           => p_esi_org_id
                   ,p_contribution_period  => l_contribution_period
                   ,p_esi_coverage         => p_esi_coverage
                   ,p_sysdate              => p_sysdate);

  ELSIF p_form_type ='PT3' THEN
     --
     pay_in_utils.set_location(g_debug,l_procedure, 70);
     create_pt_form3_xml(p_pt_org_id   => p_pt_org_id
                        ,p_frequency   => p_frequency
                        ,p_year        => p_year
                        ,p_period      => p_period);

  ELSIF p_form_type='FORM27A' THEN
     pay_in_utils.set_location(g_debug,l_procedure, 80);
     create_form27A_xml(P_GRE_ORG_ID  => P_GRE_ORG_ID
                       ,P_ASSESS_YEAR => P_ASSESS_YEAR);

  ELSE
     null;
  END IF;


  p_xml := g_xml_data;
   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 90);


END init_code;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_FORM8_XML                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure creates XML data for Pension Form 8  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pf_org_id                        VARCHAR2         --
--                  p_contribution_period       VARCHAR2                --
--                    p_effective_start_date      DATE                  --
--                    p_effective_end_date          DATE                --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 11-Feb-2005    vgsriniv   Initial Version                      --
-- 115.1 31-Mar-2005    aaagarwa   Added the join for BG id             --
-- 115.2 01-Apr-2005    lnagaraj   Removed c_pf_org_summation_details   --
--                                 Modified c_asg_summation_details     --
--                                 Changes for excluded employee        --
--------------------------------------------------------------------------
PROCEDURE create_form8_xml(p_pf_org_id                  IN VARCHAR2
                          ,p_contribution_period  IN VARCHAR2
                          ,p_effective_start_date IN DATE
                          ,p_effective_end_date   IN DATE)
IS

  CURSOR c_pf_org_id(p_pf_org_id             VARCHAR2
                    ,p_contribution_period   VARCHAR2
                    ,p_effective_start_date  DATE
                    ,p_effective_end_date    DATE
                    )
  IS
  SELECT DISTINCT paa_pay.action_information2   --PF Org Id
        ,paa_pay.action_information3            --PF Org Reg Name
        ,paa_pay.action_information5            --Address
        ,paa_pay.action_information6            --Code
        ,paa_pay.action_information8            --PF Org Name
    FROM pay_action_information paa_asg
        ,pay_action_information paa_pay
        ,pay_assignment_actions paa
        ,hr_organization_units  hou
   WHERE paa_asg.action_information_category = 'IN_PF_ASG'
     AND paa_pay.action_information_category = 'IN_PF_PAY'
     AND paa_asg.ACTION_CONTEXT_TYPE = 'AAP'
     AND paa_pay.ACTION_CONTEXT_TYPE = 'PA'
     AND paa.assignment_action_id = paa_asg.action_context_id
     AND paa.payroll_action_id = paa_pay.action_context_id
     AND paa_asg.action_information2 LIKE NVL(p_pf_org_id,'%')                  --PF Organization ID
     AND paa_pay.action_information7 LIKE DECODE(p_pf_org_id,NULL,'EXEM','%')   --PF Org Class
     AND paa_asg.action_information2 = paa_pay.action_information2
     AND paa_asg.action_information15 IS NOT NULL
     AND paa_asg.action_information1 = p_contribution_period
     AND paa_pay.action_information1 = p_contribution_period
     AND hou.organization_id=paa_pay.action_information2
     AND hou.organization_id=paa_asg.action_information2
     AND hou.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
     AND paa_asg.action_information13 BETWEEN p_effective_start_date AND p_effective_end_date
  ORDER BY paa_pay.action_information8 ASC;

  CURSOR c_assignment_id(p_pf_org_id             VARCHAR2
                        ,p_contribution_period   VARCHAR2
                        ,p_effective_start_date  DATE
                        ,p_effective_end_date    DATE)
  IS
  SELECT DISTINCT action_information15,assignment_id
    FROM pay_action_information
   WHERE action_information_category = 'IN_PF_ASG'
     AND action_information2 = p_pf_org_id                        --PF Organization ID
     AND action_information1 = p_contribution_period
     AND action_information13 BETWEEN p_effective_start_date AND p_effective_end_date
     AND assignment_id is not null
   ORDER BY action_information15 ASC;

  /* Bugfix 4253674 and 4270904 Start*/

/*Find the global value as on Financial year start  */
  CURSOR csr_global_value(p_name VARCHAR2) IS
  SELECT fnd_number.canonical_to_number(glb.global_value)
    FROM ff_globals_f glb
   WHERE glb.global_name = p_name
     AND glb.LEGISLATION_CODE ='IN'
     AND p_effective_end_date BETWEEN glb.effective_start_date and glb.effective_end_date;

  /* Check if an employee is excluded or not */
  CURSOR csr_not_excluded_employee(p_pf_org_id           VARCHAR2
                                  ,p_contribution_period VARCHAR2
                                  ,p_pension_number      VARCHAR2)
      IS
  SELECT '1' status
    FROM pay_action_information pai
   WHERE pai.action_information_category ='IN_PF_ASG'
     AND pai.action_information1=p_contribution_period
     AND pai.action_information2 = p_pf_org_id
     AND pai.action_information15 = p_pension_number
     AND NVL(pai.action_information18,'0') = '0'
     AND ROWNUM <2;


/*Modified for Bug 5647738 */
  CURSOR c_asg_summation_details(p_pf_org_id           VARCHAR2
                                ,p_contribution_period VARCHAR2
                                ,p_pension_number      VARCHAR2
                                ,p_pf_salary_ceiling   NUMBER)
      IS
  SELECT
    SUM(fnd_number.canonical_to_number(pai_mas.action_information10)) pension
    FROM pay_action_information pai_mas
   where pai_mas.action_information_category ='IN_PF_ASG'
     and pai_mas.action_information1 = p_contribution_period
     and pai_mas.action_information2 = p_pf_org_id
     and pai_mas.action_information15 = p_pension_number
     and pai_mas.action_information_id in (SELECT MAX(pai1.action_information_id)
                                            FROM pay_action_information pai1
                                           WHERE  pai1.action_information1 = p_contribution_period
                                             AND pai1.action_information2 = p_pf_org_id
                                             AND pai1.action_information15 = p_pension_number
                                            GROUP BY TRUNC(TO_DATE(pai1.action_information13,'DD-MM-YY'),'MM')
                                          );

Cursor c_asg_details(p_pf_org_id                VARCHAR2
                    ,p_pf_number                VARCHAR2
                    ,p_effective_start_date     DATE
                    ,p_effective_end_date       DATE
                    )
 IS
  SELECT DISTINCT TO_DATE(action_information13,'DD-MM-YYYY') mon
  FROM  pay_action_information
  WHERE action_information_category='IN_PF_ASG'
  AND   action_information3 =p_pf_number
  AND   action_information2 =p_pf_org_id                          --PF Organization ID
  AND   action_information1 = p_contribution_period  -- Bug 5231500
  AND   action_information13 BETWEEN p_effective_start_date       --Payroll Date
  AND   p_effective_end_date
  ORDER BY TO_DATE(action_information13,'DD-MM-YYYY') ASC;

  CURSOR c_pf_employer(p_pf_org_id                VARCHAR2
                      ,p_effective_start_date        DATE
                      ,p_effective_end_date        DATE)
  IS
  SELECT fnd_number.canonical_to_number(org_information2) mon             --Month Number
        ,SUM(fnd_number.canonical_to_number(org_information5)) pension  --Pension Fund Contributions A/c No.10
   FROM hr_organization_information
  WHERE organization_id = p_pf_org_id
    AND ORG_INFORMATION_CONTEXT = 'PER_IN_PF_CHALLAN_INFO'
    AND org_information1=TO_CHAR(p_effective_start_date,'YYYY')||'-'||TO_CHAR(p_effective_end_date,'YYYY')
  GROUP BY org_information2
  ORDER BY org_information2 ASC;

  CURSOR c_emp_name(p_pf_org_id            VARCHAR2
                   ,p_pension_number       VARCHAR2
                   ,p_effective_start_date DATE
                   ,p_effective_end_date   DATE
                   )
  IS
  SELECT action_information4             --Full Name
    FROM pay_action_information
   WHERE action_information_category='IN_PF_ASG'
     AND action_information1 = p_contribution_period -- Bug 5231500
     AND action_information2 = p_pf_org_id
     AND action_information15 = p_pension_number
     AND TO_DATE(action_information13,'DD-MM-YY') BETWEEN p_effective_start_date AND p_effective_end_date
  ORDER BY TO_DATE(action_information13,'DD-MM-YY') DESC;

   CURSOR c_rep_name(p_contribution_period VARCHAR2
                    ,p_pf_org_id           VARCHAR2
                    ,p_effective_start_date DATE
                    ,p_effective_end_date  DATE
                    )
   IS
   SELECT paa_pay.action_information4 rep_name
     FROM pay_action_information paa_asg
         ,pay_action_information paa_pay
         ,pay_assignment_actions paa
    WHERE paa_asg.action_information_category='IN_PF_ASG'
      AND paa_pay.action_information_category='IN_PF_PAY'
      AND paa_asg.ACTION_CONTEXT_TYPE='AAP'
      AND paa_pay.ACTION_CONTEXT_TYPE='PA'
      AND paa.assignment_action_id=paa_asg.action_context_id
      AND paa.payroll_action_id=paa_pay.action_context_id
      AND paa_pay.action_information7 = 'EXEM'
      AND paa_asg.action_information1=p_contribution_period
      AND paa_pay.action_information1=p_contribution_period
      AND paa_pay.action_information2=p_pf_org_id
      AND paa_asg.action_information2=p_pf_org_id
      AND paa_asg.action_information1=paa_pay.action_information1
      AND paa_asg.action_information2=paa_pay.action_information2
      AND paa_asg.action_information13 BETWEEN  p_effective_start_date  AND p_effective_end_date
  ORDER BY TO_DATE(paa_asg.action_information13,'DD-MM-YYYY') DESC;

/*Added for Bug 5647738*/
 cursor c_monthly_contributions( p_pf_org_id NUMBER
                                , p_pension_no varchar2)
 IS
 SELECT fnd_number.canonical_to_number(pai.action_information7)  pf_wages
         ,pai.action_information13 date_earned
     FROM pay_action_information pai
    WHERE pai.action_information_category ='IN_PF_ASG'
      AND pai.action_information1 = p_contribution_period
      AND pai.action_information2 = p_pf_org_id
      AND pai.action_information15 = p_pension_no
      AND pai.assignment_id  IS NOT NULL
 GROUP BY pai.action_information13
         ,pai.action_information7
         ,pai.action_information10
         ,pai.action_information11
         ,pai.action_information17
         ,pai.action_information18
         ,pai.action_information_id
	 ,pai.assignment_id
   HAVING pai.action_information_id = (SELECT MAX(pai1.action_information_id)
                                       FROM pay_Action_information pai1
                                      WHERE pai1.action_information_category ='IN_PF_ASG'
                                        AND pai1.action_information1 = p_contribution_period
                                        AND pai1.action_information2 = p_pf_org_id
                                        AND TRUNC(TO_DATE(pai.action_information13,'DD-MM-YY'),'MM') = TRUNC(TO_DATE(pai1.action_information13,'DD-MM-YY'),'MM')
                                        AND pai1.action_information15 = p_pension_no
                                      )
 ORDER BY TO_DATE(pai.action_information13,'DD-MM-YY'), pai.action_information_id desc;


  l_count          NUMBER;
  l_tag            VARCHAR2(2000);
  l_rate           NUMBER;
  l_employee_no    NUMBER;
  l_remarks        VARCHAR2(2000);
  l_remarks_dummy  VARCHAR2(2000);
  l_row_count      NUMBER;
  l_epf_total      NUMBER;
  l_pension_total  NUMBER;
  l_dli_total      NUMBER;
  l_admn_total     NUMBER;
  l_edli_adm_total NUMBER;
  l_summation      NUMBER;
  l_sys_date_time  VARCHAR2(30);
  l_bg_id          NUMBER;
  l_salary_ceiling NUMBER;
  l_org_pf_ytd     NUMBER;
  l_org_pension_ytd NUMBER;
  l_payroll_mon    NUMBER;
  l_mon            NUMBER;
  l_message   VARCHAR2(255);
  l_procedure VARCHAR2(100);
  l_cont_type VARCHAR2(15) := 'DEFAULT';
  l_contribution_type VARCHAR2(15):= 'DEFAULT';
  l_cont_type_date_earned VARCHAR(20):= 'DEFAULT';
  l_pf_ceiling_type varchar2(50);

  date_earned DATE;
  l_employee_name per_all_people_f.full_name%TYPE;
  asg_sum NUMBER := 0;


BEGIN
 g_debug := hr_utility.debug_enabled;
 l_procedure := g_package ||'create_form8_xml';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  pay_in_xml_utils.gXMLTable.DELETE;
--
  fnd_file.put_line(fnd_file.log,'Creating the XML...');
  dbms_lob.createtemporary(g_xml_data,FALSE,DBMS_LOB.CALL);
  dbms_lob.open(g_xml_data,dbms_lob.lob_readwrite);
--
  l_tag :='<?xml version="1.0"  encoding="UTF-8"?>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  l_tag := '<FORM8>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
  fnd_file.put_line(fnd_file.log,'Started...');
--
  fnd_file.put_line(fnd_file.log,'Creating XML for Employer Details.');
  l_sys_date_time:=TO_CHAR(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');
  l_bg_id:=fnd_profile.value('PER_BUSINESS_GROUP_ID');
--System Date
  l_tag :=pay_in_xml_utils.getTag('c_current_date_in_hh_mm_ss',l_sys_date_time);
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

   pay_in_utils.set_location(g_debug,l_procedure, 20);

  FOR c_rec IN c_pf_org_id(p_pf_org_id
                          ,p_contribution_period
                          ,p_effective_start_date
                          ,p_effective_end_date)
  LOOP
        pay_in_utils.set_location(g_debug,l_procedure, 30);
        l_tag := '<organization>';
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

        IF g_debug THEN
          pay_in_utils.trace('PF Organization id  ',p_pf_org_id);
          pay_in_utils.trace('Contribution Period     ',p_contribution_period);
        END IF;

        l_count:=1;
        --PF Org Reg Name
        --PF Org Reg Name Made in BLOCK
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pf_org_name';
        pay_in_xml_utils.gXMLTable(l_count).Value := upper(c_rec.action_information3);
        l_count := l_count + 1;
        --Address
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_address';
        pay_in_xml_utils.gXMLTable(l_count).Value := (c_rec.action_information5);
        l_count := l_count + 1;
        --Code
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_code';
        pay_in_xml_utils.gXMLTable(l_count).Value := (c_rec.action_information6);
        l_count := l_count + 1;
        --Starting Year
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_start_year';
        pay_in_xml_utils.gXMLTable(l_count).Value := (to_char(p_effective_start_date,'YYYY'));
        l_count := l_count + 1;
        --Ending Year
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_end_year';
        pay_in_xml_utils.gXMLTable(l_count).Value := (to_char(p_effective_end_date,'YYYY'));
        l_count := l_count + 1;

        pay_in_xml_utils.multiColumnar('org',pay_in_xml_utils.gXMLTable,l_count,g_xml_data);

        l_employee_no:=1;
        l_org_pf_ytd := 0;
        l_org_pension_ytd :=0;
        pay_in_utils.set_location(g_debug,l_procedure, 40);

        FOR assignment_rec IN c_assignment_id(c_rec.action_information2
                                             ,p_contribution_period
                                             ,p_effective_start_date
                                             ,p_effective_end_date)
        LOOP
           pay_in_utils.set_location(g_debug,l_procedure, 50);

           IF g_debug THEN
              pay_in_utils.trace('Pension Number    ',assignment_rec.action_information15);
              pay_in_utils.trace('PF Organization ID      ',c_rec.action_information2);
           END IF;

           FOR chk_excluded_employee IN csr_not_excluded_employee(c_rec.action_information2
                                                                 ,p_contribution_period
                                                                 ,assignment_rec.action_information15)
           LOOP
                pay_in_utils.set_location(g_debug,l_procedure, 60);
             -- Display only when employee status is not excluded
             IF chk_excluded_employee.status ='1' THEN
	       OPEN c_emp_name(c_rec.action_information2
                                ,assignment_rec.action_information15
                                ,p_effective_start_date
                                ,p_effective_end_date );

                 FETCH c_emp_name INTO l_employee_name;
                 CLOSE c_emp_name;

	       --Getting Contribution Type as of Date Earned (Bug 5647738)
		 asg_sum := 0;
                 l_cont_type_date_earned := 'DEFAULT';
               FOR c_mon_contr IN c_monthly_contributions(c_rec.action_information2
                                                              ,assignment_rec.action_information15)
               LOOP

                    l_cont_type_date_earned :=pay_in_utils.get_scl_segment_on_date(assignment_rec.assignment_id
                                                                 ,l_bg_id
                                                                 ,c_mon_contr.date_earned
                                                                 ,'segment12');
                                IF(l_cont_type_date_earned = '0')THEN
	                              l_cont_type_date_earned := 'DEFAULT';
                                END IF;
		/*To get the ceiling limit depending on Disability information #7225734*/
		l_pf_ceiling_type := get_disability_details(assignment_rec.assignment_id,c_mon_contr.date_earned);

                OPEN csr_global_value(l_pf_ceiling_type);
                FETCH csr_global_value INTO l_salary_ceiling ;
                CLOSE csr_global_value;

                  IF l_cont_type_date_earned = 'FULL_CAP' or l_cont_type_date_earned = 'DEFAULT' THEN
                     asg_sum := asg_sum + LEAST(l_salary_ceiling,c_mon_contr.pf_wages);
                   ELSE
                     asg_sum := asg_sum + c_mon_contr.pf_wages;
                  END IF;

               END LOOP;
               FOR child_asg_rec IN c_asg_summation_details(c_rec.action_information2
                                                           ,p_contribution_period
                                                           ,assignment_rec.action_information15
                                                           ,l_salary_ceiling)
               LOOP
                    pay_in_utils.set_location(g_debug,l_procedure, 70);
                 l_count:=1;
                 --Sl No.
                 pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_sl_no';
                 pay_in_xml_utils.gXMLTable(l_count).Value := (l_employee_no);
                 l_employee_no := l_employee_no + 1;
                 l_count := l_count + 1;
                 --Pension Number
                 pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_account_no';
                 pay_in_xml_utils.gXMLTable(l_count).Value := (assignment_rec.action_information15);
                 l_count := l_count + 1;
                 --Full Name
                 pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_name';
                 pay_in_xml_utils.gXMLTable(l_count).Value := l_employee_name ;

                 l_count := l_count + 1;
                 IF g_debug THEN
                   pay_in_utils.trace('Employee Name    ',pay_in_xml_utils.gXMLTable(l_count).Value);
                 END IF;


                 pay_in_utils.set_location(g_debug,l_procedure, 80);

                 l_org_pf_ytd := l_org_pf_ytd + asg_sum ;
                  l_org_pension_ytd := l_org_pension_ytd + child_asg_rec.pension;

                 --Annual Wages
                 pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pf';
                 pay_in_xml_utils.gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(l_bg_id,NVL(asg_sum,0));
                 l_count := l_count + 1;
                 --Pension YTD
                 pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pension';
                 pay_in_xml_utils.gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(child_asg_rec.pension,0));
                 l_count := l_count + 1;

                 IF g_debug THEN
                   pay_in_utils.trace('PF Wages          ',asg_sum);
                   pay_in_utils.trace('Pension Amt       ',child_asg_rec.pension);
                 END IF;

                 l_remarks := NULL;
                 l_remarks_dummy := NULL;

                FOR c_rec_child IN c_asg_details(c_rec.action_information2                --PF Org ID
                                               ,assignment_rec.action_information15
                                               ,p_effective_start_date
                                               ,p_effective_end_date)
                LOOP
                        pay_in_utils.set_location(g_debug,l_procedure, 90);
                        l_payroll_mon := TO_NUMBER(TO_CHAR(c_rec_child.mon,'MM'));
                        IF (l_payroll_mon <4 ) THEN
                                l_mon := l_payroll_mon + 9;
                        ELSE
                                l_mon := l_payroll_mon - 3;
                        END IF;
                        l_remarks_dummy := get_eit_remarks(assignment_rec.action_information15
                                                          ,'PF'
                                                          ,p_contribution_period
                                                          ,l_mon
                                                           );

                        IF l_remarks IS NOT NULL THEN
                            IF l_remarks_dummy IS NOT NULL THEN
                                l_remarks:=l_remarks||fnd_global.local_chr(10)||l_remarks_dummy;
                            END IF;
                        ELSE
                                l_remarks:=l_remarks_dummy;
                        END IF;
                END LOOP;


                 pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_remarks';
                 pay_in_xml_utils.gXMLTable(l_count).Value := (l_remarks);
                 l_count := l_count + 1;
                  pay_in_xml_utils.multiColumnar('details',pay_in_xml_utils.gXMLTable,l_count,g_xml_data);

               END LOOP;
             END IF;
           END LOOP;
        END LOOP;

        pay_in_utils.set_location(g_debug,l_procedure, 100);
        pay_in_xml_utils.gXMLTable.delete;

        l_count:=1;
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_wage_ytd';
        pay_in_xml_utils.gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(l_bg_id,NVL(l_org_pf_ytd,0));
        l_count := l_count + 1;
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pension_ytd';
        pay_in_xml_utils.gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(l_bg_id,NVL(l_org_pension_ytd,0));
        l_count := l_count + 1;
        pay_in_xml_utils.multiColumnar('sum',pay_in_xml_utils.gXMLTable,l_count,g_xml_data);

         IF g_debug THEN
              pay_in_utils.trace('Total PF Wages          ',l_org_pf_ytd);
              pay_in_utils.trace('Total Pension Amt       ',l_org_pension_ytd);
         END IF;


        pay_in_xml_utils.gXMLTable.delete;

        l_count:=1;
        l_epf_total:=0;
        l_pension_total:=0;
        l_dli_total:=0;
        l_admn_total:=0;
        l_edli_adm_total:=0;
        l_summation:=0;

        pay_in_utils.set_location(g_debug,l_procedure, 110);

        FOR c_pf_org_child_rec IN c_pf_employer(c_rec.action_information2      --PF Org ID
                                               ,p_effective_start_date
                                               ,p_effective_end_date)
        LOOP

        pay_in_utils.set_location(g_debug,l_procedure, 120);

         IF g_debug THEN
              pay_in_utils.trace('Month Number         ', c_pf_org_child_rec.mon);
              pay_in_utils.trace('Pension              ', c_pf_org_child_rec.pension);
         END IF;

                IF (c_pf_employer%ROWCOUNT=1) THEN
                        IF c_pf_org_child_rec.mon>1 THEN
                                FOR i IN 1..(c_pf_org_child_rec.mon-1)
                                LOOP
                                        insert_ch_record(i,g_xml_data);
                                        l_row_count:=l_row_count + 1;
                                END LOOP;
                        END IF;
                END IF;

                insert_ch_record(c_pf_org_child_rec.mon
                                ,g_xml_data
                                ,c_pf_org_child_rec.pension);

                l_row_count:=c_pf_org_child_rec.mon;
                l_pension_total:=l_pension_total+c_pf_org_child_rec.pension;

        END LOOP;

        l_row_count:=NVL(l_row_count,0);
        IF l_row_count<12 THEN
                FOR i IN l_row_count+1..12 LOOP
                        insert_ch_record(i,g_xml_data);
                END LOOP;
        END IF;

        pay_in_xml_utils.gXMLTable.delete;

        l_count:=1;
        --Pension Fund Total
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pension_org_total';
        pay_in_xml_utils.gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(l_bg_id,l_pension_total);
        l_count := l_count + 1;

        --No of employees in Form 8
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_emp_no';
        pay_in_xml_utils.gXMLTable(l_count).Value := l_employee_no - 1;
        l_count := l_count + 1;

       pay_in_utils.set_location(g_debug,l_procedure, 130);

        --Employer Representative Signature
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_employer';
        OPEN c_rep_name(p_contribution_period
                       ,c_rec.action_information2
                       ,p_effective_start_date
                       ,p_effective_end_date);
        FETCH c_rep_name INTO pay_in_xml_utils.gXMLTable(l_count).Value;
        CLOSE c_rep_name;
        l_count := l_count + 1;
        pay_in_xml_utils.multiColumnar('pf_org_sum',pay_in_xml_utils.gXMLTable,l_count,g_xml_data);
        /* Ending Starts here*/
        l_tag := '</organization>';
        dbms_lob.writeAppend(g_xml_data, LENGTH(l_tag), l_tag);
        pay_in_xml_utils.gXMLTable.DELETE;
        l_row_count:=NULL;
       pay_in_utils.set_location(g_debug,l_procedure, 140);
  END LOOP;

  pay_in_utils.set_location(g_debug,l_procedure, 150);

  l_tag := '</FORM8>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  fnd_file.put_line(fnd_file.log,'XML Created.');
--  INSERT INTO temp_clob VALUES (g_xml_data);

   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 160);


 END create_form8_xml;

/*Added for 7225734 */
--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_disability_details                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This Function returns the PF wage ceiling limit     --
--		    depending on whether the disabled employee          --
--		    has met all the sucessfull criteria or not.         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id                   VARCHAR2          --
--                  p_earn_date                       DATE              --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 12-Aug-2008    mdubasi    Initial Version                      --
--------------------------------------------------------------------------
FUNCTION get_disability_details( p_assignment_id  IN  NUMBER
                                 ,p_earn_date     IN   DATE )
RETURN varchar2
IS

/*Cursor to get the disable proof details */
CURSOR c_disable_proof  is
SELECT pdf.dis_information1
FROM   per_disabilities_f pdf,
       per_assignments_f paf
WHERE  paf.assignment_id = p_assignment_id
AND    paf.person_id = pdf.person_id
AND    p_earn_date BETWEEN paf.effective_start_date AND paf.effective_end_date
AND    p_earn_date BETWEEN pdf.effective_start_date AND pdf.effective_end_date;


/*Cursor to get the employer classification details */
CURSOR c_emplr_class is
SELECT target.org_information3
FROM   per_assignments_f assign,
       hr_soft_coding_keyflex scl,
       hr_organization_information target
WHERE  assign.assignment_id   = p_assignment_id
AND    p_earn_date  BETWEEN ASSIGN.effective_start_date AND ASSIGN.effective_end_date
AND    assign.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
AND    scl.segment1  = target.organization_id
AND    target.org_information_context = 'PER_IN_INCOME_TAX_DF';

/*cursor to get the hire date details */
CURSOR c_hire_date is
SELECT service.date_start
FROM   per_assignments_f    assign,
       per_periods_of_service   service
WHERE  p_earn_date BETWEEN ASSIGN.effective_start_date AND assign.effective_end_date
AND    assign.assignment_id       =  p_assignment_id
AND    service.period_of_service_id (+)= assign.period_of_service_id;

l_disable_proof per_disabilities_f.dis_information1%TYPE;
l_emplr_class hr_organization_information.org_information3%TYPE;
l_hire_date date;
l_ceiling_type varchar2(50);

  --
BEGIN

   OPEN  c_disable_proof;
   FETCH c_disable_proof INTO l_disable_proof;
   CLOSE c_disable_proof;

   OPEN c_emplr_class;
   FETCH c_emplr_class INTO l_emplr_class;
   CLOSE c_emplr_class;

   OPEN c_hire_date;
   FETCH c_hire_date INTO l_hire_date;
   CLOSE c_hire_date;

   IF (l_disable_proof = 'Y' AND l_hire_date >= to_date('01/04/2008','dd/mm/yyyy')
       AND (l_emplr_class = 'NSCG' OR l_emplr_class = 'FIRM' OR l_emplr_class = 'OTHR')) THEN
      l_ceiling_type := 'IN_PF_DISABLED_SALARY_CEILING';
   ELSE
     l_ceiling_type := 'IN_PF_SALARY_CEILING';
   END IF;

   RETURN l_ceiling_type;
END get_disability_details;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : employee_type                                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function checks whether the employee type of   --
--                  current assignment is same as in the Concurrent     --
--                  Program Parameter or not.                           --
-- Parameters     :                                                     --
--             IN : p_assignment_id                     NUMBER          --
--                    p_employee_type                   VARCHAR2        --
--                    p_effective_start_date            DATE            --
--                    p_effective_end_date              DATE            --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 21-Feb-2005    aaagarwa   Initial Version                      --
-- 115.1 05-Mar-2005    aaagarwa   Changed Handling of termination      --
-- 115.2 06-Mar-2005    aaagarwa   Live data access removed             --
--------------------------------------------------------------------------
FUNCTION employee_type(p_pf_number            VARCHAR2
                      ,p_employee_type        VARCHAR2
                      ,p_effective_start_date DATE
                      ,p_effective_end_date   DATE
                      ,p_cp_pf_org_id         VARCHAR2 DEFAULT NULL
                      ,p_pf_org_id            VARCHAR2 DEFAULT NULL
                      ,p_status    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS


CURSOR c_transfer_check
IS
  SELECT  action_information2
  FROM    pay_action_information paa
  WHERE   paa.action_information_category='IN_PF_ASG'
  AND     paa.action_context_type='AAP'
  AND     paa.action_information1=to_char(p_effective_start_date,'YYYY')||'-'||to_char(p_effective_end_date,'YYYY')
  AND     paa.action_information3=p_pf_number
  GROUP BY action_information2;

CURSOR c_transfer_status(pf_org_id VARCHAR2)
IS
  SELECT  1
  FROM    pay_action_information paa
  WHERE   paa.action_information_category='IN_PF_ASG'
  AND     paa.action_context_type='AAP'
  AND     paa.action_information1=to_char(p_effective_start_date,'YYYY')||'-'||to_char(p_effective_end_date,'YYYY')
  AND     paa.action_information3=p_pf_number
  and     paa.action_information2=p_pf_org_id
  and     TO_DATE(paa.action_information13,'DD-MM-YY')=
        (
                SELECT  MAX(to_date(action_information13,'DD-MM-YY'))
                FROM    pay_action_information paa
                WHERE   paa.action_information_category='IN_PF_ASG'
                AND     paa.action_context_type='AAP'
                AND     paa.action_information1=to_char(p_effective_start_date,'YYYY')||'-'||to_char(p_effective_end_date,'YYYY')
                AND     paa.action_information3=p_pf_number
        );

CURSOR c_person_id
IS
  SELECT DISTINCT person_id
  FROM per_people_f
  WHERE per_information8 = p_pf_number
  AND business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');

CURSOR c_termination_check(p_person_id  NUMBER)
IS
  select '1'
  from   per_periods_of_service
  where  actual_termination_date between p_effective_start_date and p_effective_end_date
  and    date_start = (SELECT  max(to_date(date_start,'DD-MM-YY'))
                       FROM    per_periods_of_service
                       WHERE   person_id = p_person_id
                       AND     business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
                      )
  and    person_id = p_person_id;

CURSOR c_last_pay_count
IS
   SELECT COUNT(action_information2)
   FROM   pay_action_information
   WHERE  action_information_category ='IN_PF_ASG'
   AND    action_information3=p_pf_number
   AND    action_context_type='AAP'
   AND    action_information1=to_char(p_effective_start_date,'YYYY')||'-'||to_char(p_effective_end_date,'YYYY')
   AND    TO_DATE(action_information13,'DD-MM-YY')=
   (
      SELECT  MAX(TO_DATE(action_information13,'DD-MM-YY'))
      FROM    pay_action_information paa
      WHERE   paa.action_information_category='IN_PF_ASG'
      AND     paa.action_context_type='AAP'
      AND     paa.action_information1=to_char(p_effective_start_date,'YYYY')||'-'||to_char(p_effective_end_date,'YYYY')
      AND     paa.action_information3=p_pf_number
   );

CURSOR c_last_pay_date
IS
      SELECT  MAX(TO_DATE(action_information13,'DD-MM-YY'))
      FROM    pay_action_information paa
      WHERE   paa.action_information_category='IN_PF_ASG'
      AND     paa.action_context_type='AAP'
      AND     paa.action_information1=to_char(p_effective_start_date,'YYYY')||'-'||to_char(p_effective_end_date,'YYYY')
      AND     paa.action_information3=p_pf_number;

CURSOR c_final_check(p_pf_org_id    NUMBER
                    ,p_payroll_date DATE)
IS
   SELECT  1 -- Modified for bug 4774108
   FROM  per_assignments_f  pea
        ,hr_soft_coding_keyflex hrscf
        ,per_people_f       pep
   WHERE  pea.person_id = pep.person_id
   AND    pep.per_information8 = p_pf_number
   AND    pep.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
   AND    pea.soft_coding_keyflex_id=hrscf.soft_coding_keyflex_id
   AND    hrscf.segment2=p_pf_org_id
   AND    p_payroll_date BETWEEN TO_DATE(TO_CHAR(pea.effective_start_date,'DD-MM-YY'),'DD-MM-YY')
   AND    TO_DATE(TO_CHAR(pea.effective_end_date,'DD-MM-YY'),'DD-MM-YY')
   AND    p_payroll_date BETWEEN TO_DATE(TO_CHAR(pep.effective_start_date,'DD-MM-YY'),'DD-MM-YY')
   AND    TO_DATE(TO_CHAR(pep.effective_end_date,'DD-MM-YY'),'DD-MM-YY');

 l_org_count         NUMBER;
 l_reason            VARCHAR2(3);
 l_pay_date          DATE;
 l_person_id         NUMBER;
 l_message           VARCHAR2(255);
 l_procedure         VARCHAR2(100);

BEGIN

 g_debug := hr_utility.debug_enabled;
 l_procedure := g_package ||'employee_type';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('PF Number          ',p_pf_number);
       pay_in_utils.trace('Employee Type      ',p_employee_type);
       pay_in_utils.trace('Effective Start Date ',p_effective_start_date);
       pay_in_utils.trace('Effective End Date   ',p_effective_end_date);
       pay_in_utils.trace('CP PF Org id         ',p_cp_pf_org_id);
       pay_in_utils.trace('PF Org id            ',p_pf_org_id);
       pay_in_utils.trace('**************************************************','********************');
   END IF;

   l_org_count:=0;

   OPEN  c_person_id;
   FETCH c_person_id INTO l_person_id;
   CLOSE c_person_id;

   IF p_employee_type = 'TRANSFERRED' THEN
          pay_in_utils.set_location(g_debug,l_procedure, 20);
    /*This is for finding the Organization Change Count*/
        FOR c_rec IN c_transfer_check
        LOOP
           l_org_count:=l_org_count+1;
        END LOOP;
           pay_in_utils.set_location(g_debug,l_procedure, 20);


         IF l_org_count <2 THEN /*This means there were'nt any changes*/
           pay_in_utils.set_location(g_debug,l_procedure, 30);
           p_status:='CURRENT';
           RETURN FALSE;
         ELSIF p_cp_pf_org_id IS NOT NULL THEN /*There were some Organizational Changes*/
           pay_in_utils.set_location(g_debug,l_procedure, 40);
           OPEN c_transfer_status(p_cp_pf_org_id);
           FETCH c_transfer_status INTO l_reason;
           CLOSE c_transfer_status;


           IF l_reason IS NULL THEN --Thats when the last payroll archived didnt have the p_cp_pf_org_id
               pay_in_utils.set_location(g_debug,l_procedure, 50);
               p_status:='TRANSFERRED';
               RETURN TRUE;
            ELSE --This means that employee is still attached to that PF org. Now in the last archived data
                --there can be multiple records. So we have to check for records count
                pay_in_utils.set_location(g_debug,l_procedure, 60);
                OPEN c_last_pay_count;
                FETCH c_last_pay_count INTO l_org_count;
                CLOSE c_last_pay_count;
                IF l_org_count = 1 THEN --This org was present at last payroll action
                   pay_in_utils.set_location(g_debug,l_procedure, 70);
                    p_status:='CURRENT';
                   RETURN FALSE;
                ELSE
                 pay_in_utils.set_location(g_debug,l_procedure, 80);
                 l_reason:=NULL;
                 OPEN c_last_pay_date;
                 FETCH c_last_pay_date INTO l_pay_date;
                 CLOSE c_last_pay_date; --Find the last archived payroll date

                 OPEN c_final_check(p_cp_pf_org_id,l_pay_date);
                 FETCH c_final_check INTO l_reason;--Find the presence of c_pf_org_id in SCL
                 CLOSE c_final_check;
                 IF l_reason IS NULL THEN  --p_cp_pf_org_id is not in SCL
                       pay_in_utils.set_location(g_debug,l_procedure, 90);
                       p_status:='TRANSFERRED';
                       RETURN TRUE;
                 ELSE
                       pay_in_utils.set_location(g_debug,l_procedure, 100);
                          p_status:='CURRENT';--p_cp_pf_org_id is in SCl
                        RETURN FALSE;
                 END IF;
                END IF;--End for l_org_count
            END IF;--End for l_reason being null

        ELSE
           pay_in_utils.set_location(g_debug,l_procedure, 110);
           l_reason:=NULL;
           OPEN c_transfer_status(p_pf_org_id);
           FETCH c_transfer_status INTO l_reason;
           CLOSE c_transfer_status;

           IF l_reason IS NULL THEN --Thats when the last payroll archived had the p_pf_org_id
               pay_in_utils.set_location(g_debug,l_procedure, 120);
               p_status:='TRANSFERRED';
               RETURN TRUE;
           ELSE --This means that employee is still attached to that PF org. Now in the last archived data
                --there can be multiple records. So we have to check for records count
                pay_in_utils.set_location(g_debug,l_procedure, 130);
                OPEN c_last_pay_count;
                FETCH c_last_pay_count INTO l_org_count;
                CLOSE c_last_pay_count;
                IF l_org_count < 2 THEN --This org was present at last payroll action
                    pay_in_utils.set_location(g_debug,l_procedure, 140);
                    p_status:='CURRENT';
                   RETURN FALSE;
                 ELSE
                   pay_in_utils.set_location(g_debug,l_procedure, 150);
                   l_reason:=NULL;
                   OPEN c_last_pay_date;
                   FETCH c_last_pay_date INTO l_pay_date;
                   CLOSE c_last_pay_date; --Find the last archived payroll date

                   OPEN c_final_check(p_pf_org_id,l_pay_date);
                   FETCH c_final_check INTO l_reason;--Find the presence of c_pf_org_id in SCL
                   CLOSE c_final_check;

                   IF l_reason IS NULL THEN  --p_cp_pf_org_id is not in SCL
                       pay_in_utils.set_location(g_debug,l_procedure, 160);
                       p_status:='TRANSFERRED';
                       RETURN TRUE;
                   ELSE
                       pay_in_utils.set_location(g_debug,l_procedure, 170);
                          p_status:='CURRENT';--p_cp_pf_org_id is in SCl
                        RETURN FALSE;
                   END IF;
                END IF;

           END IF;
       END IF;
  ELSIF p_employee_type = 'TERMINATED' THEN
      pay_in_utils.set_location(g_debug,l_procedure, 180);
      OPEN  c_termination_check(l_person_id);
      FETCH c_termination_check INTO l_reason;
      CLOSE c_termination_check;


      IF l_reason IS NULL THEN
        pay_in_utils.set_location(g_debug,l_procedure, 190);
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;

  ELSIF p_employee_type = 'CURRENT' THEN
      pay_in_utils.set_location(g_debug,l_procedure, 200);
      OPEN  c_termination_check(l_person_id);
      FETCH c_termination_check INTO l_reason;
      CLOSE c_termination_check;


      IF l_reason IS NULL THEN
      --The employee is not terminated, So find whether he is in that org or not
          pay_in_utils.set_location(g_debug,l_procedure, 210);
          IF p_cp_pf_org_id IS NOT NULL THEN
               OPEN c_transfer_status(p_cp_pf_org_id);
               FETCH c_transfer_status INTO l_reason;
               CLOSE c_transfer_status;

                 pay_in_utils.set_location(g_debug,l_procedure, 220);

                 IF l_reason IS NULL THEN
                      pay_in_utils.set_location(g_debug,l_procedure, 230);
                      p_status:='TRANSFERRED'; --This is because on last day the pf org is not as parameter passed
                      RETURN FALSE; -- Bug 4033745
                  ELSE
                    --This means that assignment is still having p_cp_pf_org_id. But there may be multiple records
                    --So first checking for them.
                    pay_in_utils.set_location(g_debug,l_procedure, 240);
                    OPEN c_last_pay_count;
                    FETCH c_last_pay_count INTO l_org_count;
                    CLOSE c_last_pay_count;

                    IF l_org_count = 1 THEN --This org was present at last payroll action as there were only 1 rec
                       pay_in_utils.set_location(g_debug,l_procedure, 250);
                       p_status:='CURRENT';
                       RETURN TRUE;
                    ELSE
                       pay_in_utils.set_location(g_debug,l_procedure, 260);
                       l_reason:=NULL;
                       OPEN c_last_pay_date;
                       FETCH c_last_pay_date INTO l_pay_date;
                       CLOSE c_last_pay_date; --Find the last archived payroll date
                       OPEN c_final_check(p_cp_pf_org_id,l_pay_date);
                       FETCH c_final_check INTO l_reason;--Find the presence of c_pf_org_id in SCL
                       CLOSE c_final_check;
                       IF l_reason IS NULL THEN  --p_cp_pf_org_id is not in SCL
                            pay_in_utils.set_location(g_debug,l_procedure, 270);
                            p_status:='TRANSFERRED';
                            RETURN FALSE;
                       ELSE
                            pay_in_utils.set_location(g_debug,l_procedure, 280);
                            p_status:='CURRENT';--p_cp_pf_org_id is in SCl
                            RETURN TRUE;
                       END IF;
                     END IF;
                  END IF;
           ELSE
               pay_in_utils.set_location(g_debug,l_procedure, 290);
               OPEN c_transfer_status(p_pf_org_id);
               FETCH c_transfer_status INTO l_reason;
               CLOSE c_transfer_status;

                  IF l_reason IS NULL THEN
                     pay_in_utils.set_location(g_debug,l_procedure, 300);
                     p_status:='TRANSFERRED'; --This is because on last day the pf org is not as parameter passed
                     RETURN FALSE; -- Bug 4033745
                  ELSE
                     pay_in_utils.set_location(g_debug,l_procedure, 310);
                    --This means that assignment is still having p_cp_pf_org_id. But there may be multiple records
                    --So first checking for them.
                    OPEN c_last_pay_count;
                    FETCH c_last_pay_count INTO l_org_count;
                    CLOSE c_last_pay_count;
                    IF l_org_count = 1 THEN --This org was present at last payroll action as there were only 1 rec
                       pay_in_utils.set_location(g_debug,l_procedure, 320);
                       p_status:='CURRENT';
                       RETURN TRUE;
                    ELSE
                       pay_in_utils.set_location(g_debug,l_procedure, 330);
                       l_reason:=NULL;
                       OPEN c_last_pay_date;
                       FETCH c_last_pay_date INTO l_pay_date;
                       CLOSE c_last_pay_date; --Find the last archived payroll date

                       OPEN c_final_check(p_pf_org_id,l_pay_date);
                       FETCH c_final_check INTO l_reason;--Find the presence of c_pf_org_id in SCL
                       CLOSE c_final_check;
                       IF l_reason IS NULL THEN  --p_pf_org_id is not in SCL
                            pay_in_utils.set_location(g_debug,l_procedure, 330);
                            p_status:='TRANSFERRED';
                            RETURN FALSE;
                       ELSE
                            pay_in_utils.set_location(g_debug,l_procedure, 340);
                            p_status:='CURRENT';--p_pf_org_id is in SCl
                            RETURN TRUE;
                       END IF;
                     END IF;
                 END IF;
           END IF;
       ELSE
        pay_in_utils.set_location(g_debug,l_procedure, 350);
        RETURN FALSE;
     END IF;

 ELSE
     pay_in_utils.set_location(g_debug,l_procedure, 360);
     RETURN TRUE;
 END IF;

END;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_FORM6A_XML                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure creates XML data for PF Form 6A      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pf_org_id                 VARCHAR2                --
--                  p_effective_start_date      DATE                    --
--                  p_effective_end_date        DATE                    --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 01-Jan-2005    aaagarwa   Initial Version                      --
-- 115.1 21-Mar-2005    aaagarwa   Modified for handling process separate-
--                                 run.                                 --
-- 115.2 31-Mar-2005    aaagarwa   Added the join for BG id             --
--------------------------------------------------------------------------

PROCEDURE create_form6a_xml(p_pf_org_id               VARCHAR2
                       ,p_effective_start_date DATE
                       ,p_effective_end_date   DATE
                       ,p_contribution_period  VARCHAR2)
IS
CURSOR c_pf_org_id(p_pf_org_id             VARCHAR2
                  ,p_effective_start_date  DATE
                  ,p_effective_end_date    DATE
                  ,p_contribution_period   VARCHAR2
                  )
IS
  SELECT DISTINCT paa_pay.action_information2     --PF Org Id
          ,paa_pay.action_information3            --PF Org Reg Name
          ,paa_pay.action_information5            --Address
          ,paa_pay.action_information6            --Code
          ,paa_pay.action_information8            --PF Org Name
  FROM pay_action_information paa_asg
      ,pay_action_information paa_pay
      ,pay_assignment_actions paa
      ,hr_organization_units  hou
  WHERE paa_asg.action_information_category='IN_PF_ASG'
  AND   paa_pay.action_information_category='IN_PF_PAY'
  AND   paa_asg.ACTION_CONTEXT_TYPE='AAP'
  AND   paa_pay.ACTION_CONTEXT_TYPE='PA'
  AND   paa.assignment_action_id=paa_asg.action_context_id
  AND   paa.payroll_action_id=paa_pay.action_context_id
  AND   paa_asg.action_information2 LIKE NVL(p_pf_org_id,'%')                 --PF Organization ID
  AND   paa_pay.action_information7 LIKE DECODE(p_pf_org_id,null,'UEX','%')   --PF Org Class
  AND   paa_asg.action_information2 = paa_pay.action_information2
  AND   paa_pay.action_information7 NOT IN ('EXEM')
  AND   paa_asg.action_information3 IS NOT NULL
  AND   paa_asg.action_information1=p_contribution_period
  AND   paa_pay.action_information1=p_contribution_period
  AND   hou.organization_id=paa_pay.action_information2
  AND   hou.organization_id=paa_asg.action_information2
  AND   hou.business_group_id = fnd_profile.VALUE('PER_BUSINESS_GROUP_ID')
  AND   paa_asg.action_information13 BETWEEN p_effective_start_date AND p_effective_end_date
  ORDER BY paa_pay.action_information8 ASC;

CURSOR c_assignment_id(p_pf_org_id           VARCHAR2
                  ,p_effective_start_date  DATE
                  ,p_effective_end_date    DATE
                  ,p_contribution_period   VARCHAR2
                  )
IS
  SELECT DISTINCT action_information3
  FROM   pay_action_information
  WHERE  action_information_category='IN_PF_ASG'
  AND    action_information2 =p_pf_org_id                       --PF Organization ID
  AND    action_information1 =p_contribution_period
  AND    action_information13 BETWEEN p_effective_start_date    --Payroll Date
  AND    p_effective_end_date
  AND    action_information3 IS NOT NULL
  ORDER BY action_information3 ASC;

  CURSOR c_asg_summation_details(p_pf_org_id            VARCHAR2
                                ,p_pf_number                        VARCHAR2
                                ,p_effective_start_date             DATE
                                ,p_effective_end_date               DATE
                    )
  IS
  SELECT   SUM(fnd_number.canonical_to_number(action_information7))    pf_ytd     --PF Salary
          ,SUM(fnd_number.canonical_to_number(action_information8))    employee   --Total Employee Contr
          ,SUM(fnd_number.canonical_to_number(action_information9))    employer   --Employer Contr towards PF
          ,SUM(fnd_number.canonical_to_number(action_information10))   pension    --Employer Contr towards Pension
  FROM pay_action_information
  WHERE action_information2 = p_pf_org_id
  AND   action_information3 = p_pf_number
  AND   action_information1 = p_contribution_period
  AND action_information_id IN(
                        SELECT MAX(action_information_id)
                        FROM pay_action_information
                        WHERE action_information2 = p_pf_org_id
                        AND   action_information3 = p_pf_number
                        AND   action_information1 = p_contribution_period
                        GROUP BY TO_DATE('01'||substr(action_information13,3),'DD-MM-YYYY'))
  AND TO_DATE(action_information13,'DD-MM-YY') BETWEEN p_effective_start_date
  AND p_effective_end_date;

CURSOR c_asg_details(p_pf_org_id              VARCHAR2
                    ,p_pf_number              VARCHAR2
                    ,p_effective_start_date   DATE
                    ,p_effective_end_date     DATE
                    )
 IS
  SELECT DISTINCT TO_DATE(action_information13,'DD-MM-YYYY') mon
  FROM  pay_action_information
  WHERE action_information_category='IN_PF_ASG'
  AND   action_information3 =p_pf_number
  AND   action_information2 =p_pf_org_id                          --PF Organization ID
  AND   action_information1 = p_contribution_period -- Bug 5231500
  AND   action_information13 BETWEEN p_effective_start_date       --Payroll Date
  AND   p_effective_end_date
  ORDER BY TO_DATE(action_information13,'DD-MM-YYYY') ASC;

 CURSOR c_vol_rate(p_pf_org_id                VARCHAR2
                  ,p_pf_number                VARCHAR2
                  ,p_effective_start_date     DATE
                  ,p_effective_end_date       DATE
                  )
 IS
  SELECT action_information6      --Voluntary Contribution Rate
        ,TO_DATE(action_information13,'DD-MM-YYYY')
  FROM  pay_action_information
  WHERE action_information_category='IN_PF_ASG'
  AND   action_information3 = p_pf_number
  AND   action_information2 = p_pf_org_id                          --PF Organization ID
  AND   action_information1 = p_contribution_period -- Bug 5231500
  AND   action_information13 BETWEEN p_effective_start_date       --Payroll Date
  AND   p_effective_end_date
  ORDER BY TO_DATE(action_information13,'DD-MM-YYYY') DESC;

  CURSOR c_number_of_contr(p_pf_org_id                  VARCHAR2
                          ,p_effective_start_date       DATE
                          ,p_effective_end_date         DATE
                           )
  IS
  SELECT count(DISTINCT action_information3)--assignment_id)
  FROM   pay_action_information
  WHERE  action_information_category='IN_PF_ASG'
  AND    to_number(action_information6)>0
  AND    action_information13 BETWEEN p_effective_start_date
  AND    p_effective_end_date
  AND    action_information1 = p_contribution_period -- Bug 5231500
  AND    action_information2=p_pf_org_id;

  CURSOR c_pf_employer(p_pf_org_id              VARCHAR2
                      ,p_effective_start_date   DATE
                      ,p_effective_end_date     DATE
                      ,i                        NUMBER
                      )
  IS
  SELECT
   TO_NUMBER(org_information2) mon                                       --Month Number
  ,SUM(fnd_number.canonical_to_number(org_information3)+fnd_number.canonical_to_number(org_information4)) epf
  ,SUM(fnd_number.canonical_to_number(org_information5)) pension                              --Pension Fund Contributions A/c No.10
  ,SUM(fnd_number.canonical_to_number(org_information6)) dli                                  --DLI Contribution A/c No.21
  ,SUM(fnd_number.canonical_to_number(org_information7)) edli                                 --EDLI ADM. Charges  A/c No.22
  ,SUM(fnd_number.canonical_to_number(org_information8)) admin                                --Adm. Charges A/c No.2
  ,SUM(fnd_number.canonical_to_number(org_information6)+fnd_number.canonical_to_number(org_information7)+fnd_number.canonical_to_number(org_information8)) agg
  FROM hr_organization_information
  WHERE organization_id=p_pf_org_id
  AND ORG_INFORMATION_CONTEXT='PER_IN_PF_CHALLAN_INFO'
  AND org_information1=to_char(p_effective_start_date,'YYYY')||'-'||to_char(p_effective_end_date,'YYYY')
  AND org_information2=to_number(TO_CHAR(TO_DATE('01-03-2004','DD-MM-YYYY'),'MM'))+decode(i,0,9,-3+i)
  GROUP BY org_information2
  ORDER BY org_information2 ASC;


 CURSOR c_name(p_pf_org_id            VARCHAR2
              ,p_pf_number            VARCHAR2
              ,p_effective_start_date DATE
              ,p_effective_end_date   DATE
             )
 IS
  SELECT action_information4            --Full Name
        ,assignment_id
  FROM   pay_action_information
  WHERE  action_information_category='IN_PF_ASG'
  AND    action_information2 =p_pf_org_id   --PF Organization ID
  AND    action_information3  =p_pf_number   --PF Number
  AND    action_information1 = p_contribution_period -- Bug 5231500
  AND    to_date(action_information13,'DD-MM-YY') BETWEEN p_effective_start_date AND p_effective_end_date
  ORDER BY to_date(action_information13,'DD-MM-YY') DESC;

--Cursor for employer Representative Signature
  CURSOR c_rep_name(p_contribution_period  VARCHAR2
                   ,p_pf_org_id            VARCHAR2
                   ,p_effective_start_date DATE
                   ,p_effective_end_date   DATE
                   )
  IS
  SELECT paa_pay.action_information4 rep_name
  FROM pay_action_information paa_asg
      ,pay_action_information paa_pay
      ,pay_assignment_actions paa
  WHERE paa_asg.action_information_category ='IN_PF_ASG'
  AND   paa_pay.action_information_category ='IN_PF_PAY'
  AND   paa_asg.ACTION_CONTEXT_TYPE ='AAP'
  AND   paa_pay.ACTION_CONTEXT_TYPE ='PA'
  AND   paa.assignment_action_id = paa_asg.action_context_id
  AND   paa.payroll_action_id = paa_pay.action_context_id
  AND   paa_pay.action_information7 NOT IN ('EXEM')
  AND   paa_asg.action_information3 IS NOT NULL
  AND   paa_asg.action_information1 = p_contribution_period
  AND   paa_pay.action_information1 = p_contribution_period
  AND   paa_pay.action_information2 = p_pf_org_id
  AND   paa_asg.action_information2 = p_pf_org_id
  AND   paa_asg.action_information13 BETWEEN  p_effective_start_date  AND p_effective_end_date
  ORDER BY TO_DATE(paa_asg.action_information13,'DD-MM-YYYY') DESC;

  l_count          NUMBER;
  l_tag            VARCHAR2(2000);
  l_rate           NUMBER;
  l_employee_no    NUMBER;
  l_remarks        VARCHAR2(2000);
  l_remarks_dummy  VARCHAR2(2000);
  l_row_count      NUMBER;
  l_epf_total      NUMBER;
  l_pension_total  NUMBER;
  l_dli_total      NUMBER;
  l_admn_total     NUMBER;
  l_edli_adm_total NUMBER;
  l_summation      NUMBER;
  l_epf            NUMBER;
  l_pension        NUMBER;
  l_dli            NUMBER;
  l_admn           NUMBER;
  l_edli_adm       NUMBER;
  l_summ           NUMBER;
  l_sys_date_time  VARCHAR2(30);
  i                NUMBER;
  l_bg_id          NUMBER;
  l_org_pf_ytd     NUMBER;
  l_org_employer   NUMBER;
  l_org_employee   NUMBER;
  l_org_pension    NUMBER;
  l_payroll_mon    NUMBER;
  l_length         NUMBER;
  l_date           DATE;
  l_mon            NUMBER;
  l_asg_id         NUMBER;
  l_message   VARCHAR2(255);
  l_procedure VARCHAR2(100);


BEGIN
 pay_in_xml_utils.gXMLTable.DELETE;

  g_debug := hr_utility.debug_enabled;
  l_procedure := g_package ||'create_form6a_xml';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

--
  fnd_file.put_line(fnd_file.log,'Creating the XML...');
  dbms_lob.createtemporary(g_xml_data,FALSE,DBMS_LOB.CALL);
  dbms_lob.open(g_xml_data,dbms_lob.lob_readwrite);
--
  l_tag :='<?xml version="1.0"  encoding="UTF-8"?>';

  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
  l_tag := '<FORM6A>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
  fnd_file.put_line(fnd_file.log,'Started...');
--
  fnd_file.put_line(fnd_file.log,'Creating XML for Employee Personal Details.');
  l_sys_date_time:=to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');
  l_bg_id:=fnd_profile.value('PER_BUSINESS_GROUP_ID');
--System Date
  l_tag :=pay_in_xml_utils.getTag('c_current_date_in_hh_mm_ss',l_sys_date_time);
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  pay_in_utils.set_location(g_debug,l_procedure, 20);

  FOR c_rec IN c_pf_org_id(p_pf_org_id
                         ,p_effective_start_date
                         ,p_effective_end_date
                         ,p_contribution_period)
  LOOP
     pay_in_utils.set_location(g_debug,l_procedure, 30);
        l_org_pf_ytd   := 0 ;
        l_org_employer := 0 ;
        l_org_employee := 0 ;
        l_org_pension  := 0 ;

        l_tag := '<organization>';
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        l_count:=1;
        --PF Org Reg Name
--PF Org Name made in BLOCK
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pf_org_name';
        pay_in_xml_utils.gXMLTable(l_count).Value := upper(c_rec.action_information3);
        l_count := l_count + 1;
        --Address
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_address';
        pay_in_xml_utils.gXMLTable(l_count).Value := (c_rec.action_information5);
        l_count := l_count + 1;
        --Code
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_code';
        pay_in_xml_utils.gXMLTable(l_count).Value := (c_rec.action_information6);
        l_count := l_count + 1;

        IF g_debug THEN
          pay_in_utils.trace('PF Organization  ',c_rec.action_information3);
        END IF;

        --Statuory Rate of Contribution
        SELECT ROUND(fnd_number.canonical_to_number(GLOBAL_VALUE)*100,2) INTO l_rate
        FROM FF_GLOBALS_F
        WHERE GLOBAL_NAME ='IN_EMPLOYEE_PF_PERCENT'
        AND LEGISLATION_CODE='IN'
        AND p_effective_start_date BETWEEN effective_start_date AND p_effective_end_date;

        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_rate';
        pay_in_xml_utils.gXMLTable(l_count).Value := (l_rate);
        l_count := l_count + 1;
        --Starting Year
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_start_year';
        pay_in_xml_utils.gXMLTable(l_count).Value := (to_char(p_effective_start_date,'YYYY'));
        l_count := l_count + 1;
        --Ending Year
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_end_year';
        pay_in_xml_utils.gXMLTable(l_count).Value := (to_char(p_effective_end_date,'YYYY'));
        l_count := l_count + 1;

        pay_in_utils.set_location(g_debug,l_procedure, 30);

        --Number of people making Voluntary Contributions in that financial Year
        OPEN c_number_of_contr(c_rec.action_information2
                             ,p_effective_start_date
                             ,p_effective_end_date);
        FETCH c_number_of_contr INTO l_employee_no;
        CLOSE c_number_of_contr;
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_number';
        pay_in_xml_utils.gXMLTable(l_count).Value := (l_employee_no);
        l_count := l_count + 1;
        pay_in_xml_utils.multiColumnar('org',pay_in_xml_utils.gXMLTable,l_count,g_xml_data);
        l_employee_no:=1;

        pay_in_utils.set_location(g_debug,l_procedure, 40);

        FOR assignment_rec IN c_assignment_id(c_rec.action_information2
                                             ,p_effective_start_date
                                             ,p_effective_end_date
                                             ,p_contribution_period)
        LOOP
        pay_in_utils.set_location(g_debug,l_procedure, 50);

        IF g_debug THEN
           pay_in_utils.trace('PF Number  ',assignment_rec.action_information3);
        END IF;

        FOR child_asg_rec IN c_asg_summation_details(c_rec.action_information2
                                                   ,assignment_rec.action_information3
                                                   ,p_effective_start_date
                                                   ,p_effective_end_date)
        LOOP

                l_count:=1;
                --Sl No.
                pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_sl_no';
                pay_in_xml_utils.gXMLTable(l_count).Value := (l_employee_no);
                l_employee_no := l_employee_no + 1;
                l_count := l_count + 1;
                --PF Number
                pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_account_no';
                pay_in_xml_utils.gXMLTable(l_count).Value := (assignment_rec.action_information3);
                l_count := l_count + 1;
                --Full Name
                pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_name';
                OPEN c_name(c_rec.action_information2
                           ,assignment_rec.action_information3
                           ,p_effective_start_date
                           ,p_effective_end_date );

                FETCH c_name INTO pay_in_xml_utils.gXMLTable(l_count).Value,l_asg_id;
                CLOSE c_name;
                l_count := l_count + 1;
                --Annual Wages
                pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pf';
                pay_in_xml_utils.gXMLTable(l_count).Value :=
                pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(child_asg_rec.pf_ytd,0));
                l_count := l_count + 1;
                --Total Employee PF Contribution YTD
                pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_epf';
                pay_in_xml_utils.gXMLTable(l_count).Value :=
                pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(child_asg_rec.employee,0));
                l_count := l_count + 1;
                --Employer Contribution Towards PF YTD
                pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_epf_diff';
                pay_in_xml_utils.gXMLTable(l_count).Value :=
                pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(child_asg_rec.employer,0));
                l_count := l_count + 1;
                --Pension YTD
                pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pension';
                pay_in_xml_utils.gXMLTable(l_count).Value :=
                pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(child_asg_rec.pension,0));
                l_count := l_count + 1;

                l_org_pf_ytd   := l_org_pf_ytd   + child_asg_rec.pf_ytd;
                l_org_employer := l_org_employer + child_asg_rec.employer;
                l_org_employee := l_org_employee + child_asg_rec.employee;
                l_org_pension  := l_org_pension  + child_asg_rec.pension;

                l_remarks       := NULL;
                l_remarks_dummy := NULL;

                pay_in_utils.set_location(g_debug,l_procedure, 50);

                For c_rec_child IN c_asg_details(c_rec.action_information2                --PF Org ID
                                           ,assignment_rec.action_information3
                                           ,p_effective_start_date
                                           ,p_effective_end_date)
                LOOP
                        pay_in_utils.set_location(g_debug,l_procedure, 60);
                        l_payroll_mon := TO_NUMBER(TO_CHAR(c_rec_child.mon,'MM'));
                        IF (l_payroll_mon <4 ) THEN
                                l_mon := l_payroll_mon + 9;
                        ELSE
                                l_mon := l_payroll_mon - 3;
                        END IF;
                        l_remarks_dummy := get_eit_remarks(assignment_rec.action_information3--assignment_rec.assignment_id
                                                          ,'PF'
                                                          ,p_contribution_period
                                                          ,l_mon
                                                           );

                        IF l_remarks IS NOT NULL THEN
                            IF l_remarks_dummy IS NOT NULL THEN
                                l_remarks:=l_remarks||fnd_global.local_chr(10)||l_remarks_dummy;
                            END IF;
                        ELSE
                                l_remarks:=l_remarks_dummy;
                        END IF;
                END LOOP;

        pay_in_utils.set_location(g_debug,l_procedure, 70);

                OPEN  c_vol_rate(c_rec.action_information2                --PF Org ID
                                ,assignment_rec.action_information3
                                ,p_effective_start_date
                                ,p_effective_end_date
                                );
                FETCH c_vol_rate INTO l_rate,l_date;
                CLOSE c_vol_rate;

                l_rate:=to_number(l_rate,999.99);
                --VOLUNTARY RATE of Contribution
                pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_voluntary_rate';
                pay_in_xml_utils.gXMLTable(l_count).Value := (l_rate);
                l_count := l_count + 1;
                --Pension YTD
                pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_remarks';
                pay_in_xml_utils.gXMLTable(l_count).Value := (l_remarks);
                l_count := l_count + 1;
                pay_in_xml_utils.multiColumnar('details',pay_in_xml_utils.gXMLTable,l_count,g_xml_data);
                pay_in_utils.set_location(g_debug,l_procedure, 80);
        END LOOP;
      END LOOP;
        pay_in_utils.set_location(g_debug,l_procedure, 90);
        pay_in_xml_utils.gXMLTable.delete;
        l_count:=1;
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_wage_ytd';
        pay_in_xml_utils.gXMLTable(l_count).Value :=
        pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_org_pf_ytd,0));
        l_count := l_count + 1;
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_epf_ytd';
        pay_in_xml_utils.gXMLTable(l_count).Value :=
        pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_org_employee,0));
        l_count := l_count + 1;
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'diff_ytd';
        pay_in_xml_utils.gXMLTable(l_count).Value :=
        pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_org_employer,0));
        l_count := l_count + 1;
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pension_ytd';
        pay_in_xml_utils.gXMLTable(l_count).Value :=
        pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(l_org_pension,0));
        l_count := l_count + 1;
        pay_in_xml_utils.multiColumnar('sum',pay_in_xml_utils.gXMLTable,l_count,g_xml_data);

        pay_in_xml_utils.gXMLTable.delete;
        l_count:=1;
        l_epf_total:=0;
        l_pension_total:=0;
        l_dli_total:=0;
        l_admn_total:=0;
        l_edli_adm_total:=0;
        l_summation:=0;

   i := 0;
    pay_in_utils.set_location(g_debug,l_procedure, 200);
    WHILE i<12
    LOOP
       l_epf     :=0;
       l_pension :=0;
       l_dli     :=0;
       l_admn    :=0;
       l_edli_adm:=0;
       l_summ    :=0;
        FOR c_pf_org_child_rec IN c_pf_employer(c_rec.action_information2     --PF Org ID
                                               ,p_effective_start_date
                                               ,p_effective_end_date
                                               ,i)
        LOOP
           pay_in_utils.set_location(g_debug,l_procedure, 210);
          l_epf      :=c_pf_org_child_rec.epf;
          l_pension  :=c_pf_org_child_rec.pension;
          l_dli      :=c_pf_org_child_rec.dli;
          l_admn     :=c_pf_org_child_rec.admin;
          l_edli_adm :=c_pf_org_child_rec.edli;
          l_summ     :=c_pf_org_child_rec.agg;

          l_epf_total:=l_epf_total+l_epf;
          l_pension_total:=l_pension_total+l_pension;
          l_dli_total:=l_dli_total+l_dli;
          l_admn_total:=l_admn_total+l_admn;
          l_edli_adm_total:=l_edli_adm_total+l_edli_adm;
          l_summation:=l_summation+l_summ;

        END LOOP;
        insert_record(i
                    ,g_xml_data
                    ,l_epf
                    ,l_pension
                    ,l_dli
                    ,l_admn
                    ,l_edli_adm
                    ,l_summ);
        i:=i+1;
     END LOOP;
        pay_in_utils.set_location(g_debug,l_procedure, 220);
        pay_in_xml_utils.gXMLTable.delete;
        l_count:=1;
        --EPF Contributions Total
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_epf_org_total';
        pay_in_xml_utils.gXMLTable(l_count).Value :=
        pay_us_employee_payslip_web.get_format_value(l_bg_id,l_epf_total);
        l_count := l_count + 1;
        --Pension Fund Total
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pension_org_total';
        pay_in_xml_utils.gXMLTable(l_count).Value :=
        pay_us_employee_payslip_web.get_format_value(l_bg_id,l_pension_total);
        l_count := l_count + 1;
        --DLI Contribution Total
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_dli_pf_org_total';
        pay_in_xml_utils.gXMLTable(l_count).Value :=
        pay_us_employee_payslip_web.get_format_value(l_bg_id,l_dli_total);
        l_count := l_count + 1;
        --Adm.Charges Total
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_admin_pf_total';
        pay_in_xml_utils.gXMLTable(l_count).Value :=
        pay_us_employee_payslip_web.get_format_value(l_bg_id,l_admn_total);
        l_count := l_count + 1;
        --EDLI ADm.Charges Total
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_edli_org_total';
        pay_in_xml_utils.gXMLTable(l_count).Value :=
        pay_us_employee_payslip_web.get_format_value(l_bg_id,l_edli_adm_total);
        l_count := l_count + 1;
        --Col 5,6,7 Summation Aggregate
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_total_annual';
        pay_in_xml_utils.gXMLTable(l_count).Value :=
        pay_us_employee_payslip_web.get_format_value(l_bg_id,l_summation);
        l_count := l_count + 1;
        --No of employees in Form 6A
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_emp_no';

        pay_in_utils.set_location(g_debug,l_procedure, 230);

        SELECT COUNT(DISTINCT action_information3)
        INTO   pay_in_xml_utils.gXMLTable(l_count).Value
        FROM   pay_action_information
        WHERE  action_information_category='IN_PF_ASG'
	AND    action_information1 = p_contribution_period -- Bug 5231500
        AND    action_information2 =        c_rec.action_information2          --PF Organization ID
        AND    action_information3 IS NOT NULL
        AND    action_information13 BETWEEN p_effective_start_date        --Payroll Date
        AND    p_effective_end_date;

        l_count := l_count + 1;
        --Employer Representative Signature
        pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_employer';
        OPEN c_rep_name(p_contribution_period
                       ,c_rec.action_information2
                       ,p_effective_start_date
                       ,p_effective_end_date);
        FETCH c_rep_name INTO pay_in_xml_utils.gXMLTable(l_count).Value;
        CLOSE c_rep_name;
        pay_in_utils.set_location(g_debug,l_procedure, 240);
        l_count := l_count + 1;
        pay_in_xml_utils.multiColumnar('pf_org_sum',pay_in_xml_utils.gXMLTable,l_count,g_xml_data);
        /* Ending Starts here*/
        l_tag := '</organization>';
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        pay_in_xml_utils.gXMLTable.delete;
        l_row_count:=null;
  END LOOP;
  pay_in_utils.set_location(g_debug,l_procedure, 240);
  l_tag := '</FORM6A>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
  fnd_file.put_line(fnd_file.log,'XML Created.');

 END create_form6a_xml;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_FORM3A_XML                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure creates XML data for PF Form3A       --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pf_org_id                        VARCHAR2         --
--                  p_pf_number                        VARCHAR2         --
--                  p_effective_start_date             DATE             --
--                  p_effective_end_date               DATE             --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 01-Jan-2005    aaagarwa   Initial Version                      --
-- 115.1 21-Mar-2005    aaagarwa   Modified for handling process separate-
--                                 run.                                 --
-- 115.2 31-Mar-2005    aaagarwa   Added the join for BG id             --
--------------------------------------------------------------------------
PROCEDURE create_form3a_xml(p_pf_org_id              VARCHAR2
                    ,p_pf_number              VARCHAR2
                    ,p_contribution_period    VARCHAR2
                    ,p_employee_type          VARCHAR2
                    ,p_effective_start_date   DATE
                    ,p_effective_end_date     DATE)
IS

CURSOR c_distinct_org_id(p_pf_org_id                 VARCHAR2
                        ,p_pf_number                  VARCHAR2
                        ,p_contribution_period   VARCHAR2
                        ,p_employee_type         VARCHAR2
                        ,p_effective_start_date  DATE
                        ,p_effective_end_date    DATE
                        )
IS
  SELECT DISTINCT paa_asg.action_information14            --PF Org Name
                 ,paa_asg.action_information3  pf_num     --PF Number
                 ,paa_asg.action_information2  pf_org_id  --PF Org ID
  FROM pay_action_information paa_asg
      ,pay_action_information paa_pay
      ,pay_assignment_actions paa
      ,hr_organization_units  hou
  WHERE paa_asg.action_information_category='IN_PF_ASG'
  AND   paa_pay.action_information_category='IN_PF_PAY'
  AND   paa_asg.ACTION_CONTEXT_TYPE='AAP'
  AND   paa_pay.ACTION_CONTEXT_TYPE='PA'
  AND   paa.assignment_action_id=paa_asg.action_context_id
  AND   paa.payroll_action_id=paa_pay.action_context_id
  AND   paa_pay.action_information7 NOT IN ('EXEM')
  AND   paa_asg.action_information3 IS NOT NULL
  AND   paa_asg.action_information1=p_contribution_period
  AND   paa_pay.action_information1=p_contribution_period
  AND   paa_pay.action_information2 LIKE NVL(p_pf_org_id,'%')                                --PF Organization ID
  AND   paa_asg.action_information2 LIKE NVL(p_pf_org_id,'%')                                --PF Organization ID
  AND   paa_asg.action_information3 LIKE DECODE(p_employee_type,'SPECIFIC',p_pf_number,'%')  --PF Number
  AND   paa_pay.action_information7 LIKE DECODE(p_pf_org_id,NULL,'UEX','%')                  --PF Org Classification
  AND   paa_asg.action_information2 = paa_pay.action_information2
  AND   hou.organization_id=paa_pay.action_information2
  AND   hou.organization_id=paa_asg.action_information2
  AND   hou.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
  ORDER BY paa_asg.action_information14,paa_asg.action_information3 asc;

CURSOR c_asg_id(p_pf_org_id             VARCHAR2
               ,p_pf_number             VARCHAR2
               ,p_effective_start_date  DATE
               ,p_effective_end_date    DATE
               ,p_employee_type         VARCHAR2
               ,p_contribution_period   VARCHAR2
               ,p_cp_pf_org_id          VARCHAR2
               ,p_status                VARCHAR2
                )
IS
 SELECT DISTINCT paa_pay.action_information5      --Address
                ,paa_pay.action_information3  reg --Registered Name
  FROM pay_action_information paa_asg
      ,pay_action_information paa_pay
      ,pay_assignment_actions paa
  WHERE paa_asg.action_information_category='IN_PF_ASG'
  AND   paa_pay.action_information_category='IN_PF_PAY'
  AND   paa_asg.ACTION_CONTEXT_TYPE='AAP'
  AND   paa_pay.ACTION_CONTEXT_TYPE='PA'
  AND   paa.assignment_action_id=paa_asg.action_context_id
  AND   paa.payroll_action_id=paa_pay.action_context_id
  AND   paa_pay.action_information7 NOT IN ('EXEM')
  AND   paa_asg.action_information3 IS NOT NULL
  AND   paa_asg.action_information1 = p_contribution_period
  AND   paa_pay.action_information1 = p_contribution_period
  AND   paa_pay.action_information2 = p_pf_org_id              --PF Organization ID
  AND   paa_asg.action_information2 = p_pf_org_id              --PF Organization ID
  AND   paa_asg.action_information3 = p_pf_number         --PF Number
  AND   paa_asg.action_information2 LIKE DECODE(p_employee_type,'CURRENT',nvl(p_cp_pf_org_id,'%'),'%')
  AND   paa_pay.action_information2 LIKE DECODE(p_employee_type,'CURRENT',nvl(p_cp_pf_org_id,'%'),'%')
  AND   nvl(p_status,-1) LIKE DECODE(p_employee_type,'CURRENT','CURRENT','TRANSFERRED','TRANSFERRED',-1)
  AND   paa_asg.action_information13 BETWEEN  p_effective_start_date  AND p_effective_end_date;

CURSOR c_name_fath_hus_name(p_pf_org_id            VARCHAR2
                           ,p_pf_number            VARCHAR2
                           ,p_effective_start_date DATE
                           ,p_effective_end_date   DATE
                           ,p_contribution_period  VARCHAR2
                           )
IS
  SELECT action_information4            --Full Name
        ,action_information5            --Father/Husband Name
        ,action_information13           --Payroll Date
        ,action_information6            --Voluntary Contribution Rate
  FROM   pay_action_information
  WHERE  action_information_category='IN_PF_ASG'
  AND    action_information1 =p_contribution_period   --PF Contribution Period
  AND    action_information2 =p_pf_org_id             --PF Organization ID
  AND    action_information3 =p_pf_number             --PF Number
  AND    TO_DATE(action_information13,'DD-MM-YY') BETWEEN p_effective_start_date AND p_effective_end_date
  ORDER BY TO_DATE(action_information13,'DD-MM-YY') DESC;


CURSOR c_asg_details(p_pf_org_id                VARCHAR2
                    ,p_pf_number                VARCHAR2
                    ,p_effective_start_date     DATE
                    ,p_effective_end_date       DATE
                    ,p_contribution_period      VARCHAR2
                    ,p_mon_number               NUMBER
                    )
IS
  SELECT paa_asg.action_information7      --PF Salary
        ,paa_asg.action_information8      --Total Employee Contr
        ,paa_asg.action_information9      --Employer Contr towards PF
        ,paa_asg.action_information10     --Employer Contr towards Pension
        ,paa_asg.action_information11     --Absence
--        ,paa_asg.action_information12   --Remarks
        ,paa_pay.action_information4      --PF Rep Name
        ,paa_asg.action_information13     --Payroll Month
        ,paa_asg.assignment_id            --Assignment ID
  FROM pay_action_information paa_asg
      ,pay_action_information paa_pay
      ,pay_assignment_actions paa
  WHERE paa_asg.action_information_category='IN_PF_ASG'
  AND   paa_pay.action_information_category='IN_PF_PAY'
  AND   paa_asg.ACTION_CONTEXT_TYPE='AAP'
  AND   paa_pay.ACTION_CONTEXT_TYPE='PA'
  AND   paa.assignment_action_id=paa_asg.action_context_id
  AND   paa.payroll_action_id=paa_pay.action_context_id
  AND   paa_pay.action_information7 NOT IN ('EXEM')
  AND   paa_asg.action_information3 IS NOT NULL
  AND   paa_asg.action_information1=p_contribution_period
  AND   paa_pay.action_information1=p_contribution_period
  AND   paa_asg.action_information2=p_pf_org_id
  AND   paa_asg.action_information3=p_pf_number
  AND   paa_pay.action_information2=p_pf_org_id
  AND   to_number(to_char(to_date(paa_asg.action_information13,'DD-MM-YY'),'MM'))=p_mon_number
  AND   paa_asg.action_information13 BETWEEN  p_effective_start_date  AND p_effective_end_date
  ORDER BY to_date(paa_asg.action_information13,'DD-MM-YYYY'), fnd_number.canonical_to_number(paa_asg.action_information7) ASC;

  CURSOR c_asg_summation_details(p_pf_org_id     VARCHAR2
                    ,p_pf_number                 VARCHAR2
                    ,p_effective_start_date      DATE
                    ,p_effective_end_date        DATE
                    ,p_contribution_period       VARCHAR2
                    )
  IS
  SELECT SUM(fnd_number.canonical_to_number(action_information7))    pf_ytd                           --PF Salary
        ,SUM(fnd_number.canonical_to_number(action_information8))    employee                         --Total Employee Contr
        ,SUM(fnd_number.canonical_to_number(action_information9))    employer                         --Employer Contr towards PF
        ,SUM(fnd_number.canonical_to_number(action_information10))   pension                          --Employer Contr towards Pension
        ,SUM(fnd_number.canonical_to_number(action_information8) + fnd_number.canonical_to_number(action_information9))   total       --Total Employee Employer Contr
  FROM pay_action_information
  WHERE action_information2 = p_pf_org_id
  AND   action_information3 = p_pf_number
  AND   action_information1 = p_contribution_period
  AND   action_information_id IN(
                        SELECT MAX(action_information_id)
                        FROM pay_action_information
                        WHERE action_information2 = p_pf_org_id
                        AND   action_information3 = p_pf_number
                        AND   action_information1 = p_contribution_period
                        GROUP BY to_date('01'||substr(action_information13,3),'DD-MM-YYYY'))
  AND to_date(action_information13,'DD-MM-YY') BETWEEN p_effective_start_date
  AND p_effective_end_date;

  l_count                       NUMBER;
  l_tag                         VARCHAR2(240);
  l_voluntary_contribution_rate VARCHAR2(10);
  l_pf_rep_name                 VARCHAR2(240);
  l_month                       NUMBER;
  l_row_count                   NUMBER;
  l_month_name                  VARCHAR2(25);
  l_rate                        VARCHAR2(10);
  l_name                        VARCHAR2(240);
  l_fath_name                   VARCHAR2(240);
  l_date                        DATE;
  l_sys_date_time               VARCHAR2(30);
  l_bg_id                       NUMBER;
  l_pf_salary_ptd               VARCHAR2(200);
  l_epf                         VARCHAR2(200);
  l_epf_diff                    VARCHAR2(200);
  l_pension_fund                VARCHAR2(200);
  l_absence                     VARCHAR2(200);
  l_remarks                     VARCHAR2(200);
  l_cp_pf_org_id                VARCHAR2(20);
  l_status                      VARCHAR2(20);
  l_mon                         NUMBER;
  l_message                     VARCHAR2(255);
  l_procedure                   VARCHAR2(100);

BEGIN
 g_debug := hr_utility.debug_enabled;
 l_procedure := g_package ||'create_form3a_xml';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

 pay_in_xml_utils.gXMLTable.DELETE;
--
  fnd_file.put_line(fnd_file.log,'Creating the XML...');
  dbms_lob.createtemporary(g_xml_data,FALSE,DBMS_LOB.CALL);
  dbms_lob.open(g_xml_data,dbms_lob.lob_readwrite);
--
  l_tag :='<?xml version="1.0"  encoding="UTF-8"?>';

  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
  l_tag := '<FORM3A>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
  fnd_file.put_line(fnd_file.log,'Started...');
--
  fnd_file.put_line(fnd_file.log,'Creating XML for Employee Personal Details.');
  l_sys_date_time:=to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');
--System Date
  l_tag :=pay_in_xml_utils.getTag('c_current_date_in_hh_mm_ss',l_sys_date_time);
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
  l_cp_pf_org_id := p_pf_org_id;

  pay_in_utils.set_location(g_debug,l_procedure, 20);

  FOR c_org IN c_distinct_org_id (p_pf_org_id
                                 ,p_pf_number
                                 ,p_contribution_period
                                 ,p_employee_type
                                 ,p_effective_start_date
                                 ,p_effective_end_date
                                 )
  LOOP
     pay_in_utils.set_location(g_debug,l_procedure, 30);

      IF g_debug THEN
        pay_in_utils.trace('p_effective_start_date ',p_effective_start_date);
        pay_in_utils.trace('p_effective_end_date ',p_effective_end_date);
        pay_in_utils.trace('p_employee_type ',p_employee_type);
        pay_in_utils.trace('c_org.pf_org_id ',c_org.pf_org_id);
      END IF;


     l_bg_id:=fnd_profile.value('PER_BUSINESS_GROUP_ID');
     l_status:=NULL;
     IF employee_type(c_org.pf_num
                    ,p_employee_type
                    ,p_effective_start_date
                    ,p_effective_end_date
                    ,l_cp_pf_org_id
                    ,c_org.pf_org_id
                    ,l_status)
     THEN
      pay_in_utils.set_location(g_debug,l_procedure, 40);

     IF g_debug THEN
        pay_in_utils.trace('Status ',l_status);
        pay_in_utils.trace('Cp PF org id ',l_cp_pf_org_id);
        pay_in_utils.trace('PF org id ',c_org.pf_org_id);
        pay_in_utils.trace('PF Num ',c_org.pf_num );
        pay_in_utils.trace('p_employee_type  ',p_employee_type );
      END IF;

        FOR c_rec IN c_asg_id(c_org.pf_org_id                   --PF Org ID
                             ,c_org.pf_num                      --PF Number
                             ,p_effective_start_date
                             ,p_effective_end_date
                             ,p_employee_type
                             ,p_contribution_period
                             ,l_cp_pf_org_id
                             ,l_status)
        LOOP
            pay_in_utils.set_location(g_debug,l_procedure, 50);
            OPEN c_name_fath_hus_name(c_org.pf_org_id  --PF Org ID
                                     ,c_org.pf_num     --PF Number
                                     ,p_effective_start_date
                                     ,p_effective_end_date
                                     ,p_contribution_period);
            FETCH c_name_fath_hus_name INTO l_name,l_fath_name,l_date,l_voluntary_contribution_rate;
            CLOSE c_name_fath_hus_name;
            l_count:=1;
            --PF Number
            pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pf_number';
            pay_in_xml_utils.gXMLTable(l_count).Value := (c_org.pf_num);
            l_count := l_count + 1;
--Employee name made in BLOCK
            --Full Name
            pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_full_name';
            pay_in_xml_utils.gXMLTable(l_count).Value := upper(l_name);
            l_count := l_count + 1;
            --Father/Husband Name
--Father/Husband name made in BLOCK
            pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_fath_hus_name';
            pay_in_xml_utils.gXMLTable(l_count).Value := upper(l_fath_name);
            l_count := l_count + 1;
            --PF Org Reg Name
--PF Org Registered name made in BLOCK
            pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_registered_name';
            pay_in_xml_utils.gXMLTable(l_count).Value := upper(c_rec.reg);
            l_count := l_count + 1;
            --Address
            pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_address';
            pay_in_xml_utils.gXMLTable(l_count).Value := (c_rec.action_information5);
            l_count := l_count + 1;
            l_tag := '<employee>';
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
            pay_in_xml_utils.multiColumnar('Details',pay_in_xml_utils.gXMLTable,l_count,g_xml_data);
            l_count:=1;
            l_row_count:=0;
--Individual Month Record Determination
      FOR i IN 3..12
      LOOP
          pay_in_utils.set_location(g_debug,l_procedure, 60);
          l_pf_salary_ptd  :=0;
          l_epf                   :=0;
          l_epf_diff       :=0;
          l_pension_fund   :=0;
          l_absence        :=0;
          l_remarks        :=NULL;

         FOR c_rec_child IN c_asg_details( c_org.pf_org_id                 --PF Org ID
                                          ,c_org.pf_num                    --PF Number
                                          ,p_effective_start_date
                                          ,p_effective_end_date
                                          ,p_contribution_period
                                          ,i)
         LOOP
                pay_in_utils.set_location(g_debug,l_procedure, 70);
                l_pf_salary_ptd  :=c_rec_child.action_information7;
                l_epf            :=c_rec_child.action_information8;
                l_epf_diff       :=c_rec_child.action_information9;
                l_pension_fund   :=c_rec_child.action_information10;
                l_absence        :=c_rec_child.action_information11;
--                l_remarks        :=c_rec_child.action_information12;
                IF (i = 3) THEN
                       l_mon := 12;
                ELSE
                       l_mon := (i-3);
                END IF;
                l_remarks        := get_eit_remarks(c_org.pf_num
                                                  ,'PF'
                                                  ,p_contribution_period
                                                  ,l_mon
                                                  );

                IF c_rec_child.action_information4 IS NOT NULL THEN
                      l_pf_rep_name := c_rec_child.action_information4;
                END IF;

         END LOOP;
         insert_null_record(to_char(add_months(to_date('01-12-2003','DD-MM-YYYY'),i),'Mon')
                         ,g_xml_data
                         ,l_pf_salary_ptd
                         ,l_epf
                         ,l_epf_diff
                         ,l_pension_fund
                         ,l_absence
                         ,l_remarks);

      END LOOP;
      pay_in_utils.set_location(g_debug,l_procedure, 80);

      FOR i IN 1..2
      LOOP
          l_pf_salary_ptd  :=0;
          l_epf                   :=0;
          l_epf_diff       :=0;
          l_pension_fund   :=0;
          l_absence        :=0;
          l_remarks        :=NULL;
          pay_in_utils.set_location(g_debug,l_procedure, 90);

          FOR c_rec_child IN c_asg_details(c_org.pf_org_id                 --PF Org ID
                                          ,c_org.pf_num                    --PF Number
                                          ,p_effective_start_date
                                          ,p_effective_end_date
                                          ,p_contribution_period
                                          ,i) LOOP
                l_pf_salary_ptd  :=c_rec_child.action_information7;
                l_epf            :=c_rec_child.action_information8;
                l_epf_diff       :=c_rec_child.action_information9;
                l_pension_fund   :=c_rec_child.action_information10;
                l_absence        :=c_rec_child.action_information11;
--              l_remarks        :=c_rec_child.action_information12;
                l_remarks        :=get_eit_remarks(c_org.pf_num
                                                  ,'PF'
                                                  ,p_contribution_period
                                                  ,(i+9)
                                                  );


                IF c_rec_child.action_information4 IS NOT NULL THEN
                      l_pf_rep_name := c_rec_child.action_information4;
                END IF;

         END LOOP;
         insert_null_record(TO_CHAR(ADD_MONTHS(TO_DATE('01-12-2003','DD-MM-YYYY'),i),'Mon')
                         ,g_xml_data
                         ,l_pf_salary_ptd
                         ,l_epf
                         ,l_epf_diff
                         ,l_pension_fund
                         ,l_absence
                         ,l_remarks);

     END LOOP;

     pay_in_utils.set_location(g_debug,l_procedure, 100);
              --Voluntary Higher Contr Rate
             l_tag :=pay_in_xml_utils.getTag('c_voluntary_rate',to_number(l_voluntary_contribution_rate,999.99));
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                --Employer Representative name
             l_tag :=pay_in_xml_utils.getTag('c_rep_name',l_pf_rep_name);
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
             FOR c_sum IN  c_asg_summation_details(/*c_master.assignment_id   --Assignment ID
                                   ,*/c_org.pf_org_id                         --PF Org ID
                                   ,c_org.pf_num                            --PF Number
                                   ,p_effective_start_date
                                   ,p_effective_end_date
                                   ,p_contribution_period)
             LOOP
                --PF Salary Annual Value
                l_tag :=pay_in_xml_utils.getTag('c_pf_salary_ytd',pay_us_employee_payslip_web.get_format_value(l_bg_id,c_sum.pf_ytd));
                dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                -- Employee Total Contribution
                l_tag :=pay_in_xml_utils.getTag('c_epf_ytd',pay_us_employee_payslip_web.get_format_value(l_bg_id,c_sum.employee));
                dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                -- Employer Total Contribution
                l_tag :=pay_in_xml_utils.getTag('c_epf_difference_ytd',pay_us_employee_payslip_web.get_format_value(l_bg_id,c_sum.employer));
                dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                -- Pension
                l_tag :=pay_in_xml_utils.getTag('c_pension_fund_ytd',pay_us_employee_payslip_web.get_format_value(l_bg_id,c_sum.pension));
                dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                --Total Employee Employer Contr
                l_tag :=pay_in_xml_utils.getTag('c_employer_employee_ytd',pay_us_employee_payslip_web.get_format_value(l_bg_id,c_sum.total));
                dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
             END LOOP;
             pay_in_utils.set_location(g_debug,l_procedure, 110);
              --Current Date
                l_tag :=pay_in_xml_utils.getTag('c_current_date',to_char(SYSDATE,'DD-Mon-YYYY'));
                dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
            --Starting Year
                l_tag :=pay_in_xml_utils.getTag('c_start_year',to_char(p_effective_start_date,'YYYY'));
                dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
            --Ending Year
                l_tag :=pay_in_xml_utils.getTag('c_end_year',to_char(p_effective_end_date,'YYYY'));
                dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
             --Statuory Rate of Contribution
                SELECT ROUND(fnd_number.canonical_to_number(GLOBAL_VALUE)*100,2) INTO l_rate
                FROM FF_GLOBALS_F
                WHERE GLOBAL_NAME ='IN_EMPLOYEE_PF_PERCENT'
                AND LEGISLATION_CODE='IN'
                AND p_effective_start_date BETWEEN effective_start_date AND p_effective_end_date;

                l_tag :=pay_in_xml_utils.getTag('c_stat_rate',to_number(l_rate,99.99));
                dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                l_tag := '</employee>';
                dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                pay_in_utils.set_location(g_debug,l_procedure, 120);
        END LOOP;
    END IF;
END LOOP;
  --
        pay_in_utils.set_location(g_debug,l_procedure, 130);
        l_tag := '</FORM3A>';
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
        fnd_file.put_line(fnd_file.log,'XML Created.');
 END create_form3a_xml;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_FORM7_XML                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure creates XML data for Pension Form7   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pf_org_id                   VARCHAR2              --
--                  p_pension_number              VARCHAR2              --
--                  p_employee_type               VARCHAR2              --
--                  p_contribution_period         VARCHAR2              --
--                  p_effective_start_date        DATE                  --
--                  p_effective_end_date          DATE                  --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 08-Mar-2005    lnagaraj   Initial Version                      --
-- 115.1 09-Mar-2005    lnagaraj   Removed unwanted comments            --
--                                 Modified Cursor csr_pf_org_details   --
--                                 and csr_month_contributions          --
-- 115.2 01-Apr-2005    lnagaraj   Added csr_not_excluded_employee      --
--------------------------------------------------------------------------
PROCEDURE create_form7_xml(p_pf_org_id                    VARCHAR2
                          ,p_pension_number            VARCHAR2
                          ,p_employee_type          VARCHAR2
                          ,p_contribution_period    VARCHAR2
                          ,p_effective_start_date   DATE
                          ,p_effective_end_date     DATE)
IS

 /* Cursor to find out the list of Archived Exempted PF Organizations */
  CURSOR csr_exempted_pf_orglist
      IS
  SELECT hou.organization_id orgid
    FROM hr_all_organization_units hou
        ,hr_organization_information hoi
   WHERE hou.organization_id = hoi.organization_id
     AND hoi.org_information_context ='PER_IN_PF_DF'
     AND hou.organization_id like nvl(p_pf_org_id,'%')
     AND hou.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
     AND EXISTS (SELECT 1
                   FROM pay_action_information pai
                  WHERE pai.action_information_category ='IN_PF_PAY'
                    AND pai.action_information1 = p_contribution_period --Contribution period
                    AND pai.action_information2 = hou.organization_id -- Org ID
                    AND pai.action_information7 = 'EXEM' -- PF Org Classification
                    AND ROWNUM <2)
  ORDER BY hou.name;

  /* This finds the latest PF Organization data,in the contribution period from the archive table.All org level details will be found here .This will fire once foR EACH row returned by csr_exempted_pf_orglist*/
  CURSOR csr_pf_org_details (p_pf_org_id number)
      IS
  SELECT paa_pay.action_information3  Registered_Name
        ,paa_pay.action_information4  Rep_name
        ,paa_pay.action_information5  Address
        ,paa_pay.action_information6  Code
    FROM pay_action_information paa_asg
        ,pay_action_information paa_pay
        ,pay_assignment_actions paa
  WHERE paa_asg.action_information_category='IN_PF_ASG'
  AND   paa_pay.action_information_category='IN_PF_PAY'
  AND   paa_asg.action_context_type='AAP'
  AND   paa_pay.action_context_type='PA'
  AND   paa.assignment_action_id=paa_asg.action_context_id
  AND   paa.payroll_action_id=paa_pay.action_context_id
  AND   paa_pay.action_information7 = 'EXEM'
  AND   paa_asg.action_information1=p_contribution_period
  AND   paa_pay.action_information1=p_contribution_period
  AND   paa_pay.action_information2=p_pf_org_id
  AND   paa_asg.action_information2=p_pf_org_id
  AND   paa_asg.action_information1=paa_pay.action_information1
  AND   paa_asg.action_information2=paa_pay.action_information2
  AND   paa_asg.action_information13 BETWEEN  p_effective_start_date  AND p_effective_end_date
  ORDER BY TO_DATE(paa_asg.action_information13,'DD-MM-YYYY') DESC;



  /* Find the distinct pension number,assignment id combination for the given PF Org in the contribution period.Report will be generated for each record returned by the cursor. Rehire cases will not be handled */
  CURSOR csr_pension_number(l_pf_org_id NUMBER)
      IS
  SELECT DISTINCT pai.action_information15 pension_number
    FROM pay_action_information pai
   WHERE pai.action_information_category ='IN_PF_ASG'
     AND pai.action_information1 = p_contribution_period
     AND pai.action_information2 = l_pf_org_id
     AND pai.action_information15 IS NOT NULL
     AND pai.action_information15 LIKE NVL(p_pension_number,'%')
   ORDER BY pai.action_information15;

  /* Cursor to find excluded employee status*/
   CURSOR csr_not_excluded_employee(p_pf_org_id           VARCHAR2
--                                  ,p_assignment_id       NUMBER
                                  ,p_contribution_period VARCHAR2
                                  ,p_pension_number      VARCHAR2)
      IS
  SELECT 'X' status
    FROM pay_action_information pai
   WHERE pai.action_information_category ='IN_PF_ASG'
     AND pai.action_information1=p_contribution_period
     AND pai.action_information2 = p_pf_org_id
     AND pai.action_information15 = p_pension_number
     AND NVL(pai.action_information18,'0') = '0'
     AND ROWNUM <2;

  /*Find the Employee's name ,father's /husband's name and Hire Date of the employee.These
  data can change, though very rarely.Hire date is not static and may change in case of rehire
  or transfer.Latest data for the pension number in the given contribution period is retreived*/

  CURSOR csr_employee_details(l_pension_number varchar2
                             ,p_pf_org_id      VARCHAR2
                             )
      IS
  SELECT pai.action_information4  Emp_name
        ,pai.action_information5  Fath_husb_name
        ,pai.action_information16 Hire_date
    FROM pay_action_information pai
   WHERE pai.action_information_category ='IN_PF_ASG'
     AND pai.action_information1 = p_contribution_period
     AND pai.action_information2 = p_pf_org_id
     AND pai.action_information15 = l_pension_number
   ORDER BY TO_DATE(action_information13,'DD-MM-YY') DESC;


  /* This cursor gives the month-wise PF Wages,pension Contribution,Remarks,Absence,PF Contribution Salary*/

  CURSOR csr_month_contributions(p_pf_org_id NUMBER
                                ,p_pension_number VARCHAR2)
      IS
  SELECT pai.action_information7  pf_wages
         ,pai.action_information10 pension
         ,pai.action_information11 absence
         ,pai.action_information13 date_earned
         ,pai.action_information17 Contribution_sal
         ,pai.action_information18 Excluded_employee_status
         ,pai.action_information_id action_information_id
	 ,pai.assignment_id         assignment_id
     FROM pay_action_information pai
    WHERE pai.action_information_category ='IN_PF_ASG'
      AND pai.action_information1 = p_contribution_period
      AND pai.action_information2 = p_pf_org_id
      AND pai.action_information15 = p_pension_number
      AND pai.assignment_id              IS NOT NULL
 GROUP BY pai.action_information13
         ,pai.action_information7
         ,pai.action_information10
         ,pai.action_information11
         ,pai.action_information17
         ,pai.action_information18
         ,pai.action_information_id
	 ,pai.assignment_id
   HAVING pai.action_information_id = (SELECT MAX(pai1.action_information_id)
                                       FROM pay_Action_information pai1
                                      WHERE pai1.action_information_category ='IN_PF_ASG'
                                        AND pai1.action_information1 = p_contribution_period
                                        AND pai1.action_information2 = p_pf_org_id
                                        AND TRUNC(TO_DATE(pai.action_information13,'DD-MM-YY'),'MM') = TRUNC(TO_DATE(pai1.action_information13,'DD-MM-YY'),'MM')
                                        AND pai1.action_information15 = p_pension_number
                                      )
 ORDER BY TO_DATE(pai.action_information13,'DD-MM-YY'), pai.action_information_id desc;


 /* No need of a separate cursor to find annual values as this wont work when multiple records are present for an employee in a single month for a single Organization*/

/*Find the global value as on Financial year start  */
  CURSOR csr_global_value(p_name VARCHAR2) IS
  SELECT fnd_number.canonical_to_number(glb.global_value)
    FROM ff_globals_f glb
   WHERE glb.global_name = p_name
     AND glb.LEGISLATION_CODE ='IN'
     AND p_effective_end_date BETWEEN glb.effective_start_date and glb.effective_end_date;



  l_reg_name hr_organization_information.org_information1%TYPE;
  l_rep_name per_all_people_f.full_name%TYPE;
  l_org_address pay_action_information.action_information1%TYPE;
  --In the Rarest case of location adddress exceeding 240 characters nothing can be done
  l_est_code hr_organization_information.org_information1%TYPE;

  g_org_XMLTable pay_in_xml_utils.tXMLTable;

  l_employee_name  per_all_people_f.full_name%TYPE;
  l_fath_husb_name per_all_people_f.full_name%TYPE;
  l_hire_date      DATE;
  l_pension_number per_all_people_f.per_information13%TYPE;

  l_bg_id          NUMBER;
  p_cp_pf_org_id   NUMBER;
  p_status         VARCHAR2(30);

  l_salary_ceiling  NUMBER;
  l_eps_percent    NUMBER;
  l_month_pf_wages NUMBER;
  l_total_pf_wages NUMBER;
  l_total_pension  NUMBER;
  l_salary_exceed_ceiling VARCHAR2(5);
  l_excluded_employee_status varchar2(1);

  l_org_count           NUMBER;
  l_count               NUMBER;
  l_row_count           NUMBER;
  l_tag                 VARCHAR2(240);
  l_month               NUMBER;
  l_month_name          VARCHAR2(25);
  l_sys_date_time       VARCHAR2(30);
  l_mon                 NUMBER;
  l_message             VARCHAR2(255);
  l_procedure           VARCHAR2(100);
  l_contribution_type   VARCHAR2(20);
  l_cont_type           VARCHAR2(20);
  l_cont_type_date_earned VARCHAR(20);
  l_pf_ceiling_type VARCHAR2(50);

BEGIN
 g_debug := hr_utility.debug_enabled;
 l_procedure := g_package ||'create_form7_xml';
 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  pay_in_xml_utils.gXMLTable.DELETE;

--
  fnd_file.put_line(fnd_file.log,'Creating the XML...');
  dbms_lob.createtemporary(g_xml_data,FALSE,DBMS_LOB.CALL);
  dbms_lob.open(g_xml_data,dbms_lob.lob_readwrite);
--
  l_tag :='<?xml version="1.0"  encoding="UTF-8"?>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  l_tag := '<FORM7>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
  fnd_file.put_line(fnd_file.log,'Started...');
--

  fnd_file.put_line(fnd_file.log,'Creating XML for Form7.');

   --System Date
  l_sys_date_time := to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');
  l_tag :=pay_in_xml_utils.getTag('c_current_date_in_hh_mm_ss',l_sys_date_time);
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);


  OPEN csr_global_value('IN_EPS_PERCENT');
  FETCH csr_global_value INTO l_eps_percent ;
  CLOSE csr_global_value;

  l_eps_percent := ROUND((l_eps_percent*100),2);

  --
  -- Get the list of all exempted archived PF Organizations
  --
  p_cp_pf_org_id :=  p_pf_org_id;
  l_bg_id:= fnd_profile.value('PER_BUSINESS_GROUP_ID');


  fnd_file.put_line(fnd_file.log,'Start of Exempted Org list.');
   pay_in_utils.set_location(g_debug,l_procedure, 20);

  FOR c_pf_orglist IN csr_exempted_pf_orglist LOOP
    --
    -- Get details in sequence for each of the above organization and store it in a PLSQL table . This will  be
    -- used by each record returned by the inner query .i.e for each pension number
    -- that is attached to this PF org
      g_org_XMLTable.delete;
      pay_in_utils.set_location(g_debug,l_procedure, 30);
      OPEN  csr_pf_org_details(c_pf_orglist.orgid);
      FETCH csr_pf_org_details INTO l_reg_name,l_rep_name,l_org_address,l_est_code;
      CLOSE  csr_pf_org_details;

         l_org_count :=1;

       --PF Org Reg Name
       --PF Org Reg Name made in BLOCK
         g_org_XMLTable(l_org_count).Name  := 'c_registered_name';
         g_org_XMLTable(l_org_count).Value := upper(l_reg_name);
         l_org_count := l_org_count + 1;
       --Employer Representative Name
         g_org_XMLTable(l_org_count).Name  := 'c_employer';
         g_org_XMLTable(l_org_count).Value := l_rep_name;
         l_org_count := l_org_count + 1;
       --PF Establishment Code
         g_org_XMLTable(l_org_count).Name  := 'c_code';
         g_org_XMLTable(l_org_count).Value := l_est_code;
         l_org_count := l_org_count + 1;
       --Address
         g_org_XMLTable(l_org_count).Name  := 'c_address';
         g_org_XMLTable(l_org_count).Value := l_org_address;
         l_org_count := l_org_count +1;
      --
      -- Org Level Details End
      --
      fnd_file.put_line(fnd_file.log,'Start of all Pension number list.');
      FOR c_master_rec IN csr_pension_number(c_pf_orglist.orgid) LOOP
       -- Repeat this for all distinct (pension number,assignment id combinations . Rehire cases will not be
       -- considered.
--        fnd_file.put_line(fnd_file.log,'Get details for the assignment id.'||c_master_rec.asg_id);
        pay_in_utils.set_location(g_debug,l_procedure, 40);
        IF (employee_type(c_master_rec.pension_number
                          ,p_employee_type
                          ,p_effective_start_date
                          ,p_effective_end_date
                          ,p_cp_pf_org_id -- Conc Program parameter
                          ,c_pf_orglist.orgid
                          ,p_status))
        THEN
          pay_in_utils.set_location(g_debug,l_procedure, 50);
          fnd_file.put_line(fnd_file.log,'Inside the Employee Type Check');
          OPEN csr_not_excluded_employee(c_pf_orglist.orgid
                                        ,p_contribution_period
                                        ,c_master_rec.pension_number);
          FETCH csr_not_excluded_employee INTO l_excluded_employee_status;
          CLOSE csr_not_excluded_employee;

          IF (l_excluded_employee_status = 'X') THEN
            pay_in_utils.set_location(g_debug,l_procedure, 60);
            OPEN csr_employee_details(c_master_rec.pension_number,c_pf_orglist.orgid);
            FETCH csr_employee_details INTO l_employee_name,l_fath_husb_name,l_hire_date;
            CLOSE csr_employee_details;

            l_tag := '<employee>';
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);


            -- Reset these variables for each pension number
            l_count :=1;
            l_row_count:=0;
            l_salary_exceed_ceiling :='No';
            l_total_pf_wages :=0;
            l_total_pension  :=0;
            l_month_pf_wages :=0;
            l_excluded_employee_status :='';
	    l_contribution_type := 'DEFAULT';
            l_cont_type := 'DEFAULT';
            l_cont_type_date_earned := 'DEFAULT';


            FOR c_rec_child IN csr_month_contributions(c_pf_orglist.orgid
                                                      ,c_master_rec.pension_number
                                                         )
            LOOP
              pay_in_utils.set_location(g_debug,l_procedure, 70);
              l_month := MONTHS_BETWEEN(TRUNC(to_date(c_rec_child.date_earned,'DD-MM-YY'),'MM')
                                       ,p_effective_start_date);
              --
              -- Add null records in case no records exists
              --
	      l_cont_type_date_earned := 'DEFAULT';
	      IF l_cont_type = 'DEFAULT' THEN
                    l_cont_type :=pay_in_utils.get_scl_segment_on_date(c_rec_child.assignment_id
                                                                      ,l_bg_id
                                                                      ,GREATEST(l_hire_date,TO_DATE ('1-Apr-'||SUBSTR(p_contribution_period,1,4),'DD-MM-YY'))
                                                                     ,'segment12');
                       IF(l_cont_type = '0')THEN
	                     l_cont_type := 'DEFAULT';
			END IF;
              END IF;

	     IF l_cont_type_date_earned = 'DEFAULT' THEN
                    l_cont_type_date_earned :=pay_in_utils.get_scl_segment_on_date(c_rec_child.assignment_id
                                                                 ,l_bg_id
                                                                 ,c_rec_child.date_earned
                                                                 ,'segment12');
                                IF(l_cont_type_date_earned = '0')THEN
	                              l_cont_type_date_earned := 'DEFAULT';
                                END IF;
             END IF ;

          IF (l_contribution_type ='DEFAULT') THEN
               IF (l_cont_type = 'DEFAULT') THEN
		      l_contribution_type :=l_cont_type_date_earned;
		      IF(l_contribution_type ='CAP_CAP' OR l_contribution_type ='FULL_CAP' OR l_contribution_type ='DEFAULT')THEN
		            l_salary_exceed_ceiling := 'No';
                      ELSE
                            l_salary_exceed_ceiling := 'Yes';
                      END IF;
               ELSE
		      l_contribution_type :=l_cont_type;
		      IF(l_cont_type = 'CAP_CAP' OR l_cont_type = 'FULL_CAP') THEN
                              l_salary_exceed_ceiling := 'No';
                      ELSE
		              l_salary_exceed_ceiling := 'Yes';
                      END IF;
                END IF;
          END IF;

              IF (l_row_count < l_month) THEN
                --
                FOR i IN l_row_count+1..l_month LOOP
                  l_row_count:=l_row_count+1;
                  insert_null_form7_record(to_char(add_months(to_date('01-02-2004','DD-MM-YYYY'),i),'Mon'),g_xml_data);
                END LOOP;
                --
              END IF;
              IF l_row_count = l_month THEN
                  --
                  pay_in_utils.set_location(g_debug,l_procedure, 80);
                  l_month_name:=c_rec_child.date_earned;

                  l_row_count:=l_row_count+1;
                  l_month_pf_wages :=   TO_NUMBER(c_rec_child.pf_wages);

		/*To get the Wage ceiling depending on disability details #7225734*/
		l_pf_ceiling_type := get_disability_details(c_rec_child.assignment_id,c_rec_child.date_earned);

		OPEN csr_global_value(l_pf_ceiling_type);
                FETCH csr_global_value INTO l_salary_ceiling ;
                CLOSE csr_global_value;

		  --Added condition for Bug 5647738
		  IF l_cont_type_date_earned = 'FULL_CAP' or l_cont_type_date_earned = 'DEFAULT' THEN
                    l_month_pf_wages := LEAST(l_month_pf_wages,l_salary_ceiling);
                  END IF;

                  l_mon := to_number(to_char(to_date(c_rec_child.date_earned,'DD-MM-YY'),'MM'));

                  IF (l_mon <4) THEN
                        l_mon := l_mon + 9;
                  ELSE
                        l_mon := l_mon -3;
                  END IF;

                 insert_null_form7_record(to_char(to_date(l_month_name,'DD-MM-YYYY'),'Mon')
                                        ,g_xml_data
                                        ,l_month_pf_wages
                                        ,c_rec_child.pension
                                        ,c_rec_child.absence
                                        ,get_eit_remarks(c_master_rec.pension_number,'PF',p_contribution_period,l_mon)
                                        );


                   l_total_pf_wages := l_total_pf_wages + l_month_pf_wages;
                   l_total_pension  := l_total_pension + c_rec_child.pension;





                --
              END IF;
            --
            END LOOP;
            fnd_file.put_line(fnd_file.log,'Monthwise details found for the pension number');


            IF l_row_count < 12 THEN
              FOR i IN 1..(12-l_row_count) LOOP
               insert_null_form7_record(to_char(add_months(to_date(l_month_name,'DD-MM-YYYY'),i),'Mon')
                                       ,g_xml_data);
              END LOOP;
            END IF;

   -- Pension Number
            l_count:=1;
            pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pension_number';
            pay_in_xml_utils.gXMLTable(l_count).Value := (c_master_rec.pension_number);
            l_count := l_count + 1;

   --Employee Name made in BLOCK
            pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_full_name';
            pay_in_xml_utils.gXMLTable(l_count).Value := upper(l_employee_name);
            l_count := l_count + 1;


   -- Father/Husband Name
   -- Father/Husband Name made in BLOCK
            pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_fath_hus_name';
            pay_in_xml_utils.gXMLTable(l_count).Value := upper(l_fath_husb_name);
            l_count := l_count + 1;

   -- Yes_or_no
            pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_yes_no';
            pay_in_xml_utils.gXMLTable(l_count).Value := l_salary_exceed_ceiling;
            l_count := l_count + 1;

   -- Pension Rate
            pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_rate';
            pay_in_xml_utils.gXMLTable(l_count).Value := to_char(l_eps_percent);
            l_count := l_count + 1;

   -- Salary Ceiling
             pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pf_ceiling';
             pay_in_xml_utils.gXMLTable(l_count).Value := to_char(l_salary_ceiling);
             l_count := l_count + 1;

   -- Annual PF Wages
             pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pf_salary_ytd';
                  pay_in_xml_utils.gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(to_char(l_total_pf_wages),0));
             l_count := l_count + 1;
   -- Annual Pension Contr
             pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_pension_fund_ytd';
             pay_in_xml_utils.gXMLTable(l_count).Value :=
             pay_us_employee_payslip_web.get_format_value(l_bg_id,nvl(to_char(l_total_pension),0));
             l_count := l_count + 1;

    -- Hire Date
            pay_in_xml_utils.gXMLTable(l_count).Name  := 'c_hire_date';
            pay_in_xml_utils.gXMLTable(l_count).Value :=  to_char(l_hire_date,'DD-Mon-YYYY');

            pay_in_xml_utils.multiColumnar('Details',pay_in_xml_utils.gXMLTable,l_count,g_xml_data);
            pay_in_xml_utils.multiColumnar('Organization',g_org_XMLTable,l_org_count,g_xml_data);

   --Current Date
            l_tag :=pay_in_xml_utils.getTag('c_current_date',to_char(sysdate,'DD-Mon-YYYY'));
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

    --Starting Year
            l_tag :=pay_in_xml_utils.getTag('c_start_year',to_char(p_effective_start_date,'YYYY'));
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
    --Ending Year
            l_tag :=pay_in_xml_utils.getTag('c_end_year',to_char(p_effective_end_date,'YYYY'));
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

            l_tag := '</employee>';
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
          END IF;-- Excluded employee status end
        END IF; -- Employee Type Check End

      END LOOP; -- End each pension number
        pay_in_utils.set_location(g_debug,l_procedure, 90);
      fnd_file.put_line(fnd_file.log,'XML Created for a PF Org.Moving onto next');
  END LOOP;    -- End Each Organization

      l_tag := '</FORM7>';
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
          fnd_file.put_line(fnd_file.log,'XML Created.');
END create_form7_xml;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : ESI_EMPLOYEE_TYPE                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : This procedure determines whether an assignment has --
--                  to be processed or not                              --
-- Parameters     :                                                     --
--             IN : p_assignment_id             NUMBER                  --
--                  p_org_id                    VARCHAR2                --
--                  p_contribution_period       VARCHAR2                --
--                  p_sysdate                   DATE                    --
--                  p_esi_coverage              VARCHAR2                --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 10-Mar-2005    aaagarwa   Initial Version                      --
-- 115.1 24-Mar-2005    aaagarwa   Report will be generated for all the --
--                                 employees, if launched after a contri--
--                                 -bution period end.                  --
--------------------------------------------------------------------------
FUNCTION esi_employee_type(--p_assignment_id        NUMBER
                           p_insurance_no         VARCHAR2
                          ,p_org_id               VARCHAR2
                          ,p_contribution_period  VARCHAR2
                          ,p_sysdate              DATE
                          ,p_esi_coverage         VARCHAR2
                           )
RETURN BOOLEAN
IS
CURSOR c_transfer_check
IS
  SELECT  action_information2
  FROM    pay_action_information paa
  WHERE   paa.action_information_category='IN_ESI_ASG'
  AND     paa.action_context_type='AAP'
  AND     paa.action_information1=p_contribution_period
  AND     paa.action_information3=p_insurance_no
  GROUP BY action_information2;

CURSOR c_transfer_status(p_esi_org_id VARCHAR2)
IS
  SELECT  1
  FROM    pay_action_information paa
  WHERE   paa.action_information_category='IN_ESI_ASG'
  AND     paa.action_context_type='AAP'
  AND     paa.action_information1=p_contribution_period
  AND     paa.action_information3=p_insurance_no
  and     paa.action_information2=p_esi_org_id
  and     to_date(paa.action_information11,'DD-MM-YY')=
        (
                SELECT  MAX(to_date(action_information11,'DD-MM-YY'))
                FROM    pay_action_information paa
                WHERE   paa.action_information_category='IN_ESI_ASG'
                AND     paa.action_context_type='AAP'
                AND     paa.action_information1=p_contribution_period
                AND     paa.action_information3=p_insurance_no
        );

CURSOR c_last_pay_count
IS
   SELECT count(action_information2)
   FROM   pay_action_information
   WHERE  action_information_category ='IN_ESI_ASG'
   AND    action_information3=p_insurance_no
   AND    action_context_type='AAP'
   AND    action_information1=p_contribution_period
   AND    to_date(action_information11,'DD-MM-YY')=
   (
      SELECT  MAX(to_date(action_information11,'DD-MM-YY'))
      FROM    pay_action_information paa
      WHERE   paa.action_information_category='IN_ESI_ASG'
      AND     paa.action_context_type='AAP'
      AND     paa.action_information1=p_contribution_period
      AND     paa.action_information3=p_insurance_no
   );

CURSOR c_last_pay_date
IS
      SELECT  MAX(to_date(action_information11,'DD-MM-YY'))
      FROM    pay_action_information paa
      WHERE   paa.action_information_category='IN_ESI_ASG'
      AND     paa.action_context_type='AAP'
      AND     paa.action_information1=p_contribution_period
      AND     paa.action_information3=p_insurance_no;

CURSOR c_final_check(p_esi_org_id    NUMBER
                    ,p_payroll_date DATE)
IS
   SELECT  1
   FROM   per_assignments_f  pea--Modified for bug 4774108
         ,per_people_f   pep
         ,hr_soft_coding_keyflex hrscf
   WHERE  pea.person_id = pep.person_id
   AND    pep.per_information9 = p_insurance_no
   AND    pep.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
   AND    pea.soft_coding_keyflex_id=hrscf.soft_coding_keyflex_id
   AND    hrscf.segment4=p_esi_org_id
   AND    p_payroll_date BETWEEN to_date(to_char(pea.effective_start_date,'DD-MM-YY'),'DD-MM-YY')
   AND    to_date(to_char(pea.effective_end_date,'DD-MM-YY'),'DD-MM-YY');


CURSOR c_person_id
IS
  SELECT DISTINCT person_id
  FROM per_people_f
  WHERE per_information8 = p_insurance_no
  AND business_group_id  = fnd_profile.value('PER_BUSINESS_GROUP_ID');

CURSOR c_termination_check(p_person_id            NUMBER
                          ,p_effective_start_date DATE
                          ,p_effective_end_date   DATE)
IS
  select  nvl(actual_termination_date,to_date('31-12-4712','DD-MM-YYYY'))
  from   per_periods_of_service
  where  actual_termination_date between p_effective_start_date and p_effective_end_date
  and    date_start = (SELECT  max(to_date(date_start,'DD-MM-YY'))
                       FROM    per_periods_of_service
                       WHERE   person_id = p_person_id
                       AND     business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
                      )
  and    person_id = p_person_id;

--Cursor to find date of death
  CURSOR c_death_date(p_start_date     DATE
                     ,p_end_date       DATE)
  IS
  SELECT  '1'
  FROM    per_people_f
  WHERE   person_id = (select distinct person_id
                      from per_people_f
                      where per_information9 = p_insurance_no
                      and  business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID'))
  AND date_of_death BETWEEN p_start_date AND p_end_date;

  --Find Exemption status
  CURSOR c_esi_exemption(p_payroll_date DATE)
  IS
  SELECT SUBSTR(action_information9,1,1)
  FROM   pay_action_information
  WHERE  action_information_category='IN_ESI_ASG'
  AND    action_information3=p_insurance_no
  AND    action_information2=p_org_id
  AND    action_information1=p_contribution_period -- Bug 5231500
  AND    to_date(action_information11,'DD-MM-YY')=p_payroll_date;

 l_org_count         NUMBER;
 l_reason            VARCHAR2(3);
 l_term_date         DATE;
 l_pay_date          DATE;
 l_start_date        DATE;
 l_end_date          DATE;
 l_exem_status       VARCHAR2(2);
 l_person_id         NUMBER;
 l_message           VARCHAR2(255);
 l_procedure        VARCHAR2(100);

BEGIN

     g_debug := hr_utility.debug_enabled;
     l_procedure := g_package ||'esi_employee_type';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

     OPEN  c_person_id;
     FETCH c_person_id INTO l_person_id;
     CLOSE c_person_id;

    --Checking for organization count
    l_org_count:= 0;
    l_reason   := NULL;
    l_start_date :=to_date('01-'||SUBSTR(p_contribution_period,1,8),'DD-MM-YYYY');
    l_end_date   :=add_months(to_date('01-'||SUBSTR(p_contribution_period,11),'DD-MM-YYYY'),1)-1;

    pay_in_utils.set_location(g_debug,l_procedure, 20);

    IF g_debug THEN
       pay_in_utils.trace('l_start_date ',l_start_date);
       pay_in_utils.trace('l_end_date ',l_end_date);
    END IF;

   --Find the last payroll date
    OPEN  c_last_pay_date;
    FETCH c_last_pay_date INTO l_pay_date;
    CLOSE c_last_pay_date;

    --Find the Exemption Status from ESI at last payroll date
    OPEN  c_esi_exemption(l_pay_date);
    FETCH c_esi_exemption INTO l_exem_status;
    CLOSE c_esi_exemption;

    IF g_debug THEN
       pay_in_utils.trace('Exemption status  ',l_exem_status);
    END IF;


    --Find date of death.
    OPEN  c_death_date(l_start_date,l_end_date);
    FETCH c_death_date INTO l_reason;
    CLOSE c_death_date;
    IF l_reason IS NOT NULL THEN
       IF l_exem_status <> 'Y' THEN
           l_exem_status := 'Y';
       END IF;
    END IF;
    l_reason := NULL;
    --Termination check

    pay_in_utils.set_location(g_debug,l_procedure, 30);

    OPEN  c_termination_check(l_person_id,l_start_date,l_end_date);
    FETCH c_termination_check INTO l_term_date;
    CLOSE c_termination_check;
    IF l_term_date BETWEEN l_start_date AND l_end_date THEN
       IF l_exem_status <> 'Y' THEN
           l_exem_status := 'Y';
       END IF;
    END IF;


     IF g_debug THEN
       pay_in_utils.trace('Reason  ',l_reason);
       pay_in_utils.trace('Termination   ',l_term_date);
       pay_in_utils.trace('Sysdate   ',p_sysdate);
       pay_in_utils.trace('p_esi_coverage   ',p_esi_coverage);
    END IF;

    --If sysdate is greater than end date of contribution period then data for all active, terminated
    --and transferred employee should be there.(Provided 3rd Pmt is left blank).
    IF p_sysdate > l_end_date THEN
      IF p_esi_coverage = '-1' THEN
          --This means its left blank. So we have to display the data for all employees
              RETURN TRUE;
       ELSIF p_esi_coverage = 'Y' THEN
          IF l_exem_status = 'Y' THEN
              RETURN TRUE;
          ELSE
              RETURN FALSE;
          END IF;
       ELSIF p_esi_coverage = 'N' THEN
          IF l_exem_status = 'Y' THEN
              RETURN FALSE;
          ELSIF l_exem_status = 'N' THEN
              RETURN TRUE;
          END IF;
       END IF;
     END IF;
     /*For the case when p_syadate is between start and end dates, we need to check further*/

    IF p_esi_coverage = '-1' THEN
        l_exem_status:='-1';
    END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 40);

    --Checking for termination
    OPEN  c_termination_check(l_person_id,l_start_date,l_end_date);
    FETCH c_termination_check INTO l_term_date;
    CLOSE c_termination_check;

    IF (l_term_date BETWEEN l_start_date AND l_end_date) THEN
          IF p_esi_coverage = l_exem_status THEN /*True will be returned based on the 3rd parameter*/
           RETURN TRUE;-- Since the employee has a termination in the contribution period
         ELSE
           RETURN FALSE;
         END IF;
    END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 50);
    --Checking for death
    OPEN  c_death_date(l_start_date,l_end_date);
    FETCH c_death_date INTO l_reason;
    CLOSE c_death_date;

    IF l_reason IS NOT NULL THEN
          IF p_esi_coverage = l_exem_status THEN /*True will be returned based on the 3rd parameter*/
           RETURN TRUE;-- Since the employee has expired in the contribution period
         ELSE
           RETURN FALSE;
         END IF;
    END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 60);

    FOR c_rec IN c_transfer_check
    LOOP
          l_org_count:=l_org_count+1;
    END LOOP;
    IF l_org_count <2 THEN /*This means there were'nt any changes, i.e the employee was there in the org thru out*/
         RETURN FALSE;
    END IF;
   pay_in_utils.set_location(g_debug,l_procedure, 70);

     IF g_debug THEN
       pay_in_utils.trace('l_org_count  ',l_org_count);
       pay_in_utils.trace('Org ID    ',p_org_id);
    END IF;


    IF p_org_id IS NOT NULL THEN
       pay_in_utils.set_location(g_debug,l_procedure, 80);
          --Now checking for transfer cases.
          --The following cursor checks for the presence of p_org_id in the archived data
          OPEN c_transfer_status(p_org_id);
          FETCH c_transfer_status INTO l_reason;
          CLOSE c_transfer_status;
--          hr_utility.set_location('Checking asg '||p_assignment_id||' for termination',7);
          IF l_reason IS NULL THEN -- This means that employee is no longer attached to that p_org_id
              pay_in_utils.set_location(g_debug,l_procedure, 90);
              IF l_exem_status=p_esi_coverage THEN
                   RETURN TRUE; -- Hence we can safely return true and process that assignment.
              ELSE
                   RETURN FALSE;
              END IF;
          ELSE
             pay_in_utils.set_location(g_debug,l_procedure, 100);
             l_reason    := NULL;
             l_org_count := 0;
--             hr_utility.set_location('Asg '||p_assignment_id||' not terminated. Checking for org counts',7);
             --Here we know that in last archived record employee was attached to p_org_id.
             --But there may be multiple records for last archival process.
             --So checking for no of records of last payroll.
             OPEN c_last_pay_count;
             FETCH c_last_pay_count INTO l_org_count;
             CLOSE c_last_pay_count ;
--             hr_utility.set_location('Asg '||p_assignment_id||' has an org count of '||l_org_count,7);
             IF l_org_count < 2 THEN
                  --This means there is only one record and employee is attached to it only.
                  --Hence he is not a separted employee. So returning false
--                  hr_utility.set_location('Asg '||p_assignment_id||' has an org count of '||l_org_count||' and is thus active emp',7);
                  pay_in_utils.set_location(g_debug,l_procedure, 110);
                  RETURN FALSE;
             ELSE
--                  hr_utility.set_location('Asg '||p_assignment_id||' has an org count of '||l_org_count||' and might be transferred',7);
                  --Employee has multiple records for the last run.
                  --Now we have to make sure that for which one he is transferred.
                  --For this we are using the last payroll date and then we shall find the SCL Information.
                  --Find the last payroll date
                  pay_in_utils.set_location(g_debug,l_procedure, 120);
                  OPEN  c_last_pay_date;
                  FETCH c_last_pay_date INTO l_pay_date;
                  CLOSE c_last_pay_date;

                  hr_utility.set_location('Last Payroll Date'||l_pay_date,12);

                  OPEN  c_final_check(p_org_id,l_pay_date);
                  FETCH c_final_check INTO l_reason;
                  CLOSE c_final_check ;

                  IF l_reason IS NULL AND l_exem_status=p_esi_coverage THEN
                        pay_in_utils.set_location(g_debug,l_procedure, 130);
                        --This means that SCL Information no longer has p_org_id.
                        --Thus the employee has a transfer and we'll return true.
                        RETURN TRUE ;
                  ELSIF l_reason IS NOT NULL AND l_exem_status=p_esi_coverage THEN
                         pay_in_utils.set_location(g_debug,l_procedure, 140);
                        OPEN  c_esi_exemption(l_pay_date);
                        FETCH c_esi_exemption INTO l_exem_status;
                        CLOSE c_esi_exemption;
                        IF l_exem_status = 'Y' THEN
                              RETURN TRUE;
                        ELSE RETURN FALSE;
                        END IF;
                  ELSE
                        pay_in_utils.set_location(g_debug,l_procedure, 150);
                        RETURN FALSE;
                  END IF;
             END IF;
          END IF;
    END IF;
END esi_employee_type;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_ESI_XML                                       -
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure creates XML filef ro ESI Form 6      --
-- Parameters     :                                                     --
--             IN : p_esi_org_id                    VARCHAR2            --
--                  p_contribution_period           VARCHAR2            --
--                  p_sysdate                       DATE                --
--                  p_esi_coverage                  VARCHAR2            --
--            OUT : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 10-Mar-2005    aaagarwa   Initial Version                      --
-- 115.1 24-Mar-2005    aaagarwa   Modified for remarks handling        --
-- 115.2 31-Mar-2005    aaagarwa   Added the join for BG id             --
-- 115.3 16-Oct-2006    rpalli     Bug 5599977: Added conversion factor --
--                                 fnd_date.canonical_to_number in      --
--                                 cursors c_challan,c_asg_details      --
-- 115.4 05-Nov-2007    rsaharay   Modified Cursor c_org_contr_days     --
--                                 to calculate No of Days for ESI Wage --
--                                 correctly in case of Rehire before   --
--                                 FPD                                  --
-- 115.5 04-Sep-2008    rsaharay   Modified for Form 5                  --
--------------------------------------------------------------------------
PROCEDURE create_esi_xml(p_esi_org_id       IN  VARCHAR2 DEFAULT NULL
                    ,p_contribution_period  IN  VARCHAR2
                    ,p_esi_coverage         IN  VARCHAR2 DEFAULT NULL
                    ,p_sysdate              IN  DATE     DEFAULT NULL
                    )
IS

--DISTINCT Organization Id and Name
CURSOR c_distinct_org
IS
SELECT DISTINCT action_information2 org_id
      ,action_information8          org_name
FROM   pay_action_information
      ,hr_organization_units hou
WHERE  action_information_category='IN_ESI_PAY'
AND    action_context_type='PA'
AND    action_information1=p_contribution_period
AND    action_information2 LIKE nvl(p_esi_org_id,'%')
AND    hou.organization_id=action_information2
AND    hou.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
ORDER BY action_information8 asc;

--Select the highest payroll action id for an Org
CURSOR c_max_pa_action_id(p_esi_org_id VARCHAR2)
IS
  SELECT max(pai.action_context_id)
  FROM   pay_action_information pai
        ,pay_assignment_actions pac
  WHERE  pai.action_information_category='IN_ESI_PAY'
  AND    pai.action_context_type='PA'
  AND    pai.action_information1=p_contribution_period
  AND    pai.action_information2=p_esi_org_id
  AND    pac.payroll_action_id=pai.action_context_id
  AND    pac.assignment_action_id in
         ( SELECT action_context_id
           FROM   pay_action_information
           WHERE  action_information_category='IN_ESI_ASG'
           AND    action_context_type='AAP'
           AND    action_information1=p_contribution_period
           AND    action_information2=p_esi_org_id
           AND    action_information11=
           ( SELECT max(to_date(action_information11,'DD-MM-YY'))
             FROM   pay_action_information
             WHERE  action_information_category='IN_ESI_ASG'
             AND    action_context_type='AAP'
             AND    action_information1=p_contribution_period
             AND    action_information2=p_esi_org_id
           )
          );

--Organization Details based on payroll action id found in above CURSOR
CURSOR c_org_details(p_payroll_action_id number
                    ,p_esi_org_id        VARCHAR2)
IS
   SELECT action_information6   employer_code
         ,action_information3   registered_name
         ,action_information5   reg_address
         ,action_information4   rep_name
         ,action_information9   rep_desg
         ,action_information7   rep_addr
         ,action_information8   org_name
   FROM  pay_action_information
   WHERE action_information_category='IN_ESI_PAY'
   AND   action_context_type = 'PA'
   AND   action_information1 = p_contribution_period
   AND   action_information2 = p_esi_org_id
   AND   action_context_id   = p_payroll_action_id;

--DISTINCT Assignment Ids --Later to be changed
CURSOR c_asg_id(p_esi_org_id VARCHAR2)
IS
  SELECT DISTINCT action_information3   insurance_no
  FROM   pay_action_information
  WHERE  action_information_category='IN_ESI_ASG'
  AND    action_context_type='AAP'
  AND    action_information1=p_contribution_period
  AND    action_information2=p_esi_org_id
  ORDER BY TO_NUMBER(action_information3) ASC;

CURSOR c_max_date(/*p_assignment_id NUMBER
                 ,*/p_org_id        NUMBER
                 ,p_insurance_no    VARCHAR2
                  )
IS
   SELECT max(to_date(action_information11,'DD-MM-YY')) maxdate
   FROM   pay_action_information
   WHERE  action_information_category='IN_ESI_ASG'
   AND    action_context_type='AAP'
   AND    action_information1=p_contribution_period
   AND    action_information2=p_org_id
   AND    action_information3=p_insurance_no
   GROUP BY assignment_id
   ORDER BY 1;

--Employee Details at the last archived payroll
CURSOR c_asg_details(p_insurance_no VARCHAR2
                    ,p_esi_org_id   VARCHAR2
                    ,p_payroll_date DATE)
IS
  SELECT action_information4    full_name
        ,fnd_number.canonical_to_number(action_information6)    actual_salary
        ,fnd_number.canonical_to_number(action_information7)    employee_contr
        ,fnd_number.canonical_to_number(action_information8)    employer_contr
        ,action_information9    esi_coverage
        ,action_information11   payroll_date
  FROM   pay_action_information
  WHERE  action_information_category='IN_ESI_ASG'
  AND    action_context_type='AAP'
  AND    action_information1=p_contribution_period
  AND    action_information2=p_esi_org_id
  AND    action_information3=p_insurance_no
  AND    to_date(action_information11,'DD-MM-YY')=p_payroll_date
  ORDER BY to_date(action_information11,'DD-MM-YYYY') DESC ,fnd_number.canonical_to_number(action_information6)DESC;

--Cursor to find the absence details
CURSOR c_absence(p_insurance_no VARCHAR2
                ,p_esi_org_id   VARCHAR2)
IS
 SELECT sum(nvl(action_information5,0))    absence
  FROM   pay_action_information
  WHERE  action_information_category='IN_ESI_ASG'
  AND    action_context_type='AAP'
  AND    action_information1=p_contribution_period
  AND    action_information2=p_esi_org_id
  AND    action_information3=p_insurance_no;

CURSOR c_person_id(p_insurance_no VARCHAR2)
IS
   SELECT DISTINCT person_id
   FROM per_people_f
   WHERE per_information9 = p_insurance_no
   AND business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID');
/*Bug 4282074*/
CURSOR c_org_contr_days(p_esi_org_id    VARCHAR2
                       ,p_person_id     NUMBER
                       ,p_contr_start   VARCHAR2
                       ,p_contr_end     VARCHAR2)
IS
 SELECT TO_NUMBER
        (
           LEAST
           (NVL(pps.actual_termination_date,TO_DATE('31-12-4712','DD-MM-YYYY')),(ADD_MONTHS(TO_DATE('01-'||p_contr_end,'DD-MM-YYYY'),1)-1)
           )
           -
           GREATEST
           ( pps.date_start,TO_DATE('01-'||p_contr_start,'DD-MM-YYYY'))
        ) + 1  days
   FROM per_periods_of_service pps
  WHERE pps.period_of_service_id IN
(SELECT asg.period_of_service_id
   FROM hr_organization_units  hoi
       ,hr_soft_coding_keyflex scf
       ,per_all_assignments_f  asg
  WHERE asg.person_id = p_person_id
    AND asg.soft_coding_keyflex_id = scf.soft_coding_keyflex_id
    AND hoi.organization_id        = scf.segment4
    AND hoi.organization_id        = p_esi_org_id
    AND asg.primary_flag = 'Y' );

/*Bug 4282074*/
CURSOR c_remarks(p_insurance_no  VARCHAR2
                ,p_esi_org_id    VARCHAR2)
IS
  SELECT DISTINCT TO_DATE(action_information11,'DD-MM-YYYY') mon
  FROM   pay_action_information
  WHERE  action_information_category='IN_ESI_ASG'
  AND    action_context_type='AAP'
  AND    action_information1=p_contribution_period
  AND    action_information2=p_esi_org_id
  AND    action_information3=p_insurance_no
  ORDER BY TO_DATE(action_information11,'DD-MM-YYYY') ASC;

--Challan Information
CURSOR  c_challan(p_esi_org_id VARCHAR2)
IS
  SELECT fnd_date.CANONICAL_TO_DATE(org_information2) challan_date
        ,fnd_number.canonical_to_number(org_information3) challan_amt
        ,org_information5 challan_bank_code
        ,org_information6 challan_branch_code
	,hr_general.decode_lookup('IN_ESI_BANKS',org_information5) challan_bank
	,hr_general.decode_lookup('IN_CALENDAR_MONTH',org_information7) month
  FROM   hr_organization_information
  WHERE  organization_id=p_esi_org_id
  AND    ORG_INFORMATION_CONTEXT='PER_IN_ESI_CHALLAN_INFO'
  AND    hr_general.decode_lookup('IN_ESI_CONTRIB_PERIOD',ORG_INFORMATION1)=p_contribution_period
  ORDER BY fnd_date.CANONICAL_TO_DATE(org_information2) ASC;

--Declaration Information
CURSOR c_declaration(p_esi_org_id VARCHAR2)
IS
  SELECT
         TO_NUMBER(org_information1)     declaration_forms
        ,TO_NUMBER(org_information2)     tic
        ,TO_NUMBER(org_information3)     pic_received
        ,TO_NUMBER(org_information4)     pic_distributed
        ,TO_NUMBER(org_information5)     accidents_reported
        ,TO_NUMBER(org_information6)     direct_covered_employees
        ,org_information14               direct_covered_wages
	,TO_NUMBER(org_information7)     direct_not_covered_employees
        ,org_information8                direct_not_covered_wages
        ,TO_NUMBER(org_information9)     immediate_employer_covered
        ,org_information10               wages_immediate_emplr_covered
        ,TO_NUMBER(org_information11)    immediate_emplr_not_covered
        ,org_information12               wages_immd_emplr_not_covered
  FROM   hr_organization_information
  WHERE  organization_id = p_esi_org_id
  AND    org_information_context = 'PER_IN_ESI_FORM5'
  AND    hr_general.decode_lookup('IN_ESI_CONTRIB_PERIOD',org_information13) = p_contribution_period;


--Elements computing the ESI Base Salary
CURSOR c_elements
IS
  SELECT
  NVL(pet.reporting_name, pet.element_name) element_name
  FROM
  pay_element_types_f pet,
  pay_input_values_f  piv,
  pay_balance_feeds_f pbf,
  pay_balance_types   pbt
  WHERE
  pbf.input_value_id = piv.input_value_id
  AND piv.element_type_id = pet.element_type_id
  AND pbt.balance_type_id = pbf.balance_type_id
  AND pbt.balance_name ='ESI Computation Salary'
  AND pet.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
  AND p_sysdate BETWEEN pet.effective_start_date AND pet.effective_end_date
  AND p_sysdate BETWEEN piv.effective_start_date AND piv.effective_end_date
  AND p_sysdate BETWEEN pbf.effective_start_date AND pbf.effective_end_date;

--Cursor to get the Bank Branch Details
 CURSOR c_branch_dtls(p_bank_code   VARCHAR2
                       ,p_branch_code VARCHAR2 )
 IS
 SELECT  hoi.org_information3      branch_name
        ,hoi.org_information4      branch_add
 FROM    hr_organization_units        hou
        ,hr_organization_information  hoi
 WHERE   hoi.organization_id = hou.organization_id
 AND     hoi.org_information_context = 'PER_IN_ESI_BANK_BRANCH_DTLS'
 AND     hou.business_group_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
 AND     hoi.org_information1 = p_bank_code
 AND     hoi.org_information2 = p_branch_code ;



  l_absence           VARCHAR2(20);
  l_actual_salary     VARCHAR2(20);
  l_employee_contr    VARCHAR2(20);
  l_employer_contr    VARCHAR2(20);
  l_esi_coverage      VARCHAR2(10);
  l_remarks           VARCHAR2(1000);
  l_remarks_dummy     VARCHAR2(1000);
  l_payroll_date      VARCHAR2(30);
  l_sys_date_time     VARCHAR2(40);
  l_contr_start       VARCHAR2(25);
  l_contr_end         VARCHAR2(25);
  l_count             NUMBER;
  l_days              NUMBER;--VARCHAR2(50);
  l_avg_daily_wage    NUMBER;
  l_employer_total    NUMBER;
  l_employee_total    NUMBER;
  l_challan_tot       NUMBER;
  l_days_tot          NUMBER;
  l_wages_tot         NUMBER;
  l_con_tot           NUMBER;
  l_xml_data          CLOB;
  flag                BOOLEAN;
  l_bg_id             NUMBER;
  l_payroll           DATE;
  l_tag               VARCHAR2(1000);
  l_payroll_act_id    NUMBER;
  l_employer_code     hr_organization_information.org_information1%TYPE;
  l_registered_name   hr_organization_units.name%TYPE;
  l_reg_address       VARCHAR2(240);
  l_rep_name          per_all_people_f.full_name%TYPE;
  l_rep_desg          per_all_positions.name%TYPE;
  l_rep_addr          VARCHAR2(240);
  l_org_name          hr_organization_units.name%TYPE;
  l_person_id         NUMBER;
  l_insurance_no      per_all_people_f.per_information9%TYPE;
  l_full_name         per_all_people_f.full_name%TYPE;
  l_payroll_mon       NUMBER;
  l_length            NUMBER;
  l_mon               NUMBER;
  l_message           VARCHAR2(255);
  l_procedure         VARCHAR2(100);
  l_bank_branch_name  VARCHAR2(200);
  l_bank_branch_address            VARCHAR2(200);
  l_declaration_forms              NUMBER;
  l_tic                            NUMBER;
  l_pic_received                   NUMBER;
  l_pic_distributed                NUMBER;
  l_accidents_reported             NUMBER;
  l_direct_covered_employees       NUMBER;
  l_direct_not_covered_employees   NUMBER;
  l_direct_not_covered_wages       VARCHAR2(15);
  l_direct_covered_wages           VARCHAR2(15);
  l_immediate_employer_covered     NUMBER;
  l_wages_immediate_emplr_cover    VARCHAR2(15);
  l_immediate_emplr_not_covered    NUMBER;
  l_wages_immd_emplr_not_covered   VARCHAR2(15);



  BEGIN
         --
         g_debug := hr_utility.debug_enabled;
         l_procedure := g_package ||'create_esi_xml';
         pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

	 pay_in_utils.trace('p_esi_org_id',p_esi_org_id);
	 pay_in_utils.trace('p_contribution_period',p_contribution_period);
	 pay_in_utils.trace('p_esi_coverage',p_esi_coverage);
	 pay_in_utils.trace('p_sysdate',p_sysdate);

         l_bg_id:=fnd_profile.value('PER_BUSINESS_GROUP_ID');
         fnd_file.put_line(fnd_file.log,'Creating the XML...');
         dbms_lob.createtemporary(g_xml_data,FALSE,DBMS_LOB.CALL);
         dbms_lob.open(g_xml_data,dbms_lob.lob_readwrite);
          --
         l_tag :='<?xml version="1.0"  encoding="UTF-8"?>';
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
         l_tag := '<ESI6>';
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
         fnd_file.put_line(fnd_file.log,'Started...');
         --
         fnd_file.put_line(fnd_file.log,'Creating XML for ESI Form 6.');
         l_sys_date_time:=to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');
         --System Date:
         l_tag :=pay_in_xml_utils.getTag('c_sys_date_in_hh_mm_ss',l_sys_date_time);
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
         pay_in_utils.set_location(g_debug,l_procedure, 20);

         FOR c_rec IN c_distinct_org
         LOOP

            flag := TRUE;
            OPEN c_max_pa_action_id(c_rec.org_id);
            FETCH c_max_pa_action_id INTO l_payroll_act_id;
            CLOSE c_max_pa_action_id;

            OPEN c_org_details(l_payroll_act_id,c_rec.org_id);
            FETCH c_org_details INTO l_employer_code
                                ,l_registered_name
                                ,l_reg_address
                                ,l_rep_name
                                ,l_rep_desg
                                ,l_rep_addr
                                ,l_org_name;
            CLOSE c_org_details;
            --Starting Writing the data for this org on to the local clob varaible
            dbms_lob.createtemporary(l_xml_data,FALSE,DBMS_LOB.CALL);
            dbms_lob.open(l_xml_data,dbms_lob.lob_readwrite);
            l_tag :='<organization>';
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
            l_tag :=pay_in_xml_utils.getTag('c_employer_code',l_employer_code);
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
--Organization Name made in BLOCK
            l_tag :=pay_in_xml_utils.getTag('c_registered_name',upper(l_registered_name));
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
            l_tag :=pay_in_xml_utils.getTag('c_address',l_reg_address);
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
--Organization Rep Name made in BLOCK
            l_tag :=pay_in_xml_utils.getTag('c_rep_name',upper(l_rep_name));
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
            l_tag :=pay_in_xml_utils.getTag('c_rep_desg',l_rep_desg);
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
            l_tag :=pay_in_xml_utils.getTag('c_rep_address',l_rep_addr);
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
            l_tag :=pay_in_xml_utils.getTag('c_local_office',l_org_name);
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);

            --Organization Specific Data written on the CLOB. Finding Contribution Periods
            l_contr_start := substr(p_contribution_period,1,8);
            l_contr_end   := substr(p_contribution_period,11);
            l_tag :=pay_in_xml_utils.getTag('c_contr_start',l_contr_start);
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
            l_tag :=pay_in_xml_utils.getTag('c_contr_end',l_contr_end);
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
            --Details of Contribution Period written to the CLOB.Finding Employee Details
            l_count := 1;
            l_employer_total := 0;
            l_employee_total := 0;
	    l_days_tot  := 0;
	    l_wages_tot := 0;
	    l_con_tot   := 0;


            pay_in_utils.set_location(g_debug,l_procedure, 30);

            FOR c_chd_asg IN c_asg_id(c_rec.org_id)
            LOOP
--                  l_asg_id       := c_chd_asg.assignment_id;
                  l_insurance_no := c_chd_asg.insurance_no;

--          check the assignment
            pay_in_utils.set_location(g_debug,l_procedure, 40);
            l_esi_coverage := NVL(p_esi_coverage,'-1');
            IF esi_employee_type(l_insurance_no,c_rec.org_id,p_contribution_period,p_sysdate,l_esi_coverage)
            THEN
                   pay_in_utils.set_location(g_debug,l_procedure, 50);

                   IF g_debug THEN
                     pay_in_utils.trace('ESI Insurance Number',l_insurance_no);
                   END IF;

                   l_esi_coverage := NULL;
                  --Assignment Details
                  --Find the max payroll date for each assignment for given insurance number
                   l_actual_salary    := 0;
                   l_employee_contr   := 0;
                   l_employer_contr   := 0;

                   FOR c_date IN c_max_date(c_rec.org_id,l_insurance_no)
                   LOOP
                     IF g_debug THEN
                       pay_in_utils.trace('ESI Form payroll max date',c_date.maxdate);
                       pay_in_utils.trace('ESI Exemption',p_esi_coverage);
                     END IF;

                        pay_in_utils.set_location(g_debug,l_procedure, 60);
                        FOR child_asg IN c_asg_details(l_insurance_no,c_rec.org_id,c_date.maxdate)
                        LOOP
                                pay_in_utils.set_location(g_debug,l_procedure, 70);
                                l_full_name        := child_asg.full_name;
                                l_actual_salary    := l_actual_salary  + child_asg.actual_salary;
                                l_employee_contr   := l_employee_contr + child_asg.employee_contr;
                                l_employer_contr   := l_employer_contr + child_asg.employer_contr;
                                SELECT decode(child_asg.esi_coverage,'Yes','No','No','Yes')
                                INTO   l_esi_coverage
                                FROM   dual;
                                EXIT;
                       END LOOP;
                  END LOOP;
                  pay_in_utils.set_location(g_debug,l_procedure, 80);
                  OPEN  c_absence(l_insurance_no,c_rec.org_id);
                  FETCH c_absence INTO l_absence;
                  CLOSE c_absence;

                  l_actual_salary := nvl(l_actual_salary,0);
                  l_employee_contr:= nvl(l_employee_contr,0);
                  l_employer_contr:= nvl(l_employer_contr,0);

                  --Computation of the days and average salary.
                  /*Bug 4282074*/
                  l_days := 0;
                  OPEN  c_person_id(l_insurance_no);
                  FETCH c_person_id INTO l_person_id;
                  CLOSE c_person_id;

                  FOR c_record IN c_org_contr_days(c_rec.org_id,l_person_id,l_contr_start,l_contr_end)
                  LOOP
                        IF c_record.days > 0 THEN
                            l_days := l_days + c_record.days ;
                        END IF;
                  END LOOP;

                  l_days    := l_days - to_number(l_absence);
                  /*Bug 4282074*/
                  l_remarks := NULL;
                  IF l_days <> 0 THEN
                     l_avg_daily_wage := round((l_actual_salary/to_number(l_days)),2);
                  ELSE
                     l_avg_daily_wage := 0;
                  END IF;

                  l_remarks_dummy := NULL;

                  pay_in_utils.set_location(g_debug,l_procedure, 90);

                  FOR c_rem IN  c_remarks(l_insurance_no,c_rec.org_id)
                  LOOP
                      l_payroll_mon := TO_NUMBER(TO_CHAR(c_rem.mon,'MM'));
                      IF (l_payroll_mon <4 )THEN
                                l_mon := l_payroll_mon + 9;
                      ELSE
                                l_mon := l_payroll_mon - 3;
                      END IF;
                      l_remarks_dummy :=
                      get_eit_remarks
                      (
                        l_insurance_no
                        ,'ESI'
                        ,substr(l_contr_start,5,4)||'-'||to_char(to_number(substr(l_contr_start,5,4))+1)
                        ,l_mon
                      );
                      IF l_remarks IS NOT NULL THEN
                            IF l_remarks_dummy IS NOT NULL THEN
                                l_remarks:=l_remarks||fnd_global.local_chr(10)||l_remarks_dummy;
                            END IF;
                      ELSE
                                l_remarks:=l_remarks_dummy;
                      END IF;

                 END LOOP;

                  l_employer_total := l_employer_total + nvl(l_employer_contr,0);
                  l_employee_total := l_employee_total + nvl(l_employee_contr,0);

                  IF flag THEN
                       dbms_lob.Append(g_xml_data,l_xml_data);
                       flag := FALSE;
                  END IF;
                  l_tag :='<emp>';
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_sl_no',l_count);
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_insurance_number',l_insurance_no);
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_full_name',l_full_name);
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_wages',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_actual_salary));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_employee_contr',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_employee_contr));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_esi_coverage',l_esi_coverage);
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_remarks',l_remarks);
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_days',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_days));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_avg_daily_wages',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_avg_daily_wage));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                  l_tag :='</emp>';
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
                  l_count := l_count + 1;
		  l_con_tot := l_con_tot + nvl(l_employee_contr,0);
		  l_wages_tot := l_wages_tot + nvl(l_actual_salary,0);
		  l_days_tot := l_days_tot + nvl(l_days,0);
             END IF;
            END LOOP;

	    l_tag :=pay_in_xml_utils.getTag('c_total_con',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_con_tot));
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
            l_tag :=pay_in_xml_utils.getTag('c_total_wages',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_wages_tot));
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
            l_tag :=pay_in_xml_utils.getTag('c_total_days',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_days_tot));
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

            dbms_lob.close(l_xml_data);
            dbms_lob.createtemporary(l_xml_data,FALSE,DBMS_LOB.CALL);
            dbms_lob.open(l_xml_data,dbms_lob.lob_readwrite);
            --Employer Share, Employee Share and Total Contribution
            l_tag :=pay_in_xml_utils.getTag('c_employer_share',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_employer_total));
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
            l_tag :=pay_in_xml_utils.getTag('c_employee_share',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_employee_total));
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
            l_tag :=pay_in_xml_utils.getTag('c_total',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_employee_total + l_employer_total));
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
            --Challan Details
            l_count := 1;
            l_challan_tot := 0;
            pay_in_utils.set_location(g_debug,l_procedure, 100);
            FOR c_challan_rec IN c_challan(c_rec.org_id)
            LOOP

                  OPEN c_branch_dtls(c_challan_rec.challan_bank_code, c_challan_rec.challan_branch_code) ;
		  FETCH c_branch_dtls INTO l_bank_branch_name, l_bank_branch_address;
		  CLOSE c_branch_dtls;


                  l_tag :='<challan>';
                  dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_sl',l_count);
                  dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
		  l_tag :=pay_in_xml_utils.getTag('c_month',c_challan_rec.month);
                  dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_challan_date',c_challan_rec.challan_date);
                  dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_challan_paid',pay_us_employee_payslip_web.get_format_value(l_bg_id,c_challan_rec.challan_amt));
                  dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_challan_bank',c_challan_rec.challan_bank);
                  dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
                  l_tag :=pay_in_xml_utils.getTag('c_challan_branch',l_bank_branch_name);
                  dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
                  l_challan_tot := l_challan_tot + nvl(c_challan_rec.challan_amt,0);
                  l_count := l_count + 1;
                  l_tag :='</challan>';
                  dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
            END LOOP;
            l_tag :=pay_in_xml_utils.getTag('c_challan_total',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_challan_tot));
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);


	   --Declaration Details
	   OPEN c_declaration(c_rec.org_id);
	   FETCH c_declaration INTO  l_declaration_forms
				    ,l_tic
				    ,l_pic_received
				    ,l_pic_distributed
				    ,l_accidents_reported
	   			    ,l_direct_covered_employees
	   			    ,l_direct_covered_wages
	   			    ,l_direct_not_covered_employees
	   			    ,l_direct_not_covered_wages
	   			    ,l_immediate_employer_covered
	   			    ,l_wages_immediate_emplr_cover
	   			    ,l_immediate_emplr_not_covered
	   			    ,l_wages_immd_emplr_not_covered ;
	   CLOSE c_declaration ;

           l_tag := '<declaration>';
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag :=pay_in_xml_utils.getTag('c_declaration_forms',l_declaration_forms);
           dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_tic',l_tic);
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_pic_received',l_pic_received);
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_pic_distributed',l_pic_distributed);
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_accidents_reported',l_accidents_reported);
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_direct_covered_employees',l_direct_covered_employees);
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_direct_covered_wages',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_direct_covered_wages));
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_direct_not_covered_employees',l_direct_not_covered_employees);
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_direct_not_covered_wages',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_direct_not_covered_wages));
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_immediate_employer_covered',l_immediate_employer_covered);
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_wages_immediate_emplr_cover',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_wages_immediate_emplr_cover));
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_immediate_emplr_not_covered',l_immediate_emplr_not_covered);
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := pay_in_xml_utils.getTag('c_wages_immd_emplr_not_covered',pay_us_employee_payslip_web.get_format_value(l_bg_id,l_wages_immd_emplr_not_covered));
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	   l_tag := '</declaration>';
	   dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);



            --Element Details computing the Base Salary for ESI Calculation.
	    l_count := 1;
	    FOR rec_elements IN c_elements
	    LOOP
	        l_tag := '<elements>';
		dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
		l_tag :=pay_in_xml_utils.getTag('c_sl_no',l_count);
                dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
		l_count := l_count + 1;
                l_tag := pay_in_xml_utils.getTag('c_elements',rec_elements.element_name);
		dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
		l_tag := '</elements>';
		dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
	    END LOOP ;


            l_tag :='</organization>';
            dbms_lob.writeAppend(l_xml_data, length(l_tag), l_tag);
            IF flag = FALSE THEN
                    dbms_lob.Append(g_xml_data,l_xml_data);
            END IF;
            dbms_lob.close(l_xml_data);
        pay_in_utils.set_location(g_debug,l_procedure, 110);
        END LOOP;
        l_tag :='</ESI6>';
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

        fnd_file.put_line(fnd_file.log,'XML Created.');
END create_esi_xml;

END pay_in_reports_pkg;

/
