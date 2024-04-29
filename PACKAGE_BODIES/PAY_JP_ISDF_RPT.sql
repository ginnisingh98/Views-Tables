--------------------------------------------------------
--  DDL for Package Body PAY_JP_ISDF_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_ISDF_RPT" AS
/* $Header: pyjpisrp.pkb 120.28 2007/11/29 07:45:50 keyazawa noship $ */
--
--
-- Global Variables
--
  EOL                    VARCHAR2(5) := fnd_global.local_chr(10);
  vCtr                   NUMBER;
  c_proc                 VARCHAR2(100);
  l_xfdf_string          CLOB;
  c_package              CONSTANT VARCHAR2(31) := 'pay_jp_isdf_rpt.';
  g_proc_name            VARCHAR2(240);
  g_debug                BOOLEAN;
  g_bg_id                NUMBER;
  p_write_xml            CLOB;
  g_dummy                NUMBER := -99 ;
  g_all_exclusions_flag  NUMBER;
  l_emp_no_opt           VARCHAR2(15);
  l_prn_app_opt          VARCHAR2(15);
--
  c_st_upd_date_2007     constant date := to_date('2007/01/01','YYYY/MM/DD');
--
/****************************************************************************
  Name        : get_amendment_flag
  Description : This fucntion return the include_or_exclude flag for an
                assignment id.
 *****************************************************************************/
FUNCTION get_amendment_flag
(
  p_assignment_id     IN NUMBER,
  p_assignment_set_id IN NUMBER
)
RETURN VARCHAR2 IS
l_inc_or_exc  HR_ASSIGNMENT_SET_AMENDMENTS.INCLUDE_OR_EXCLUDE%TYPE;
--
BEGIN
  SELECT  INCLUDE_OR_EXCLUDE
  INTO  l_inc_or_exc
  FROM  HR_ASSIGNMENT_SET_AMENDMENTS
  WHERE ASSIGNMENT_ID = p_assignment_id
      AND ASSIGNMENT_SET_ID = p_assignment_set_id;
--
RETURN  l_inc_or_exc;
EXCEPTION
  WHEN  NO_DATA_FOUND  THEN
  RETURN 'ZZ';
END get_amendment_flag;
--
/****************************************************************************
  Name        : chk_ass_set
  Description : This fucntion checks if for the passed assignment_id an
                assignment action is to be created or not. It checks for
                assignment set by criteria also taking into account if any
                amendment is defined for that assignment id.
 *****************************************************************************/
FUNCTION chk_ass_set(
  p_assignment_id     IN  NUMBER,
  p_assignment_set_id IN  NUMBER,
  p_formula_id        IN  NUMBER,
  p_effective_date    IN  DATE,
  p_dummy             IN  NUMBER) RETURN BOOLEAN
IS
l_result                    BOOLEAN;
l_amendment_flag       HR_ASSIGNMENT_SET_AMENDMENTS.INCLUDE_OR_EXCLUDE%TYPE;
--
BEGIN
   IF (p_dummy = 1)THEN
    l_amendment_flag := get_amendment_flag(p_assignment_id,p_assignment_set_id);
      IF (l_amendment_flag = 'ZZ') THEN
    l_result := hr_jp_ast_utility_pkg.formula_validate(p_formula_id,p_assignment_id,p_effective_date);
    ELSIF l_amendment_flag = 'E' THEN
    l_result := false;
    ELSIF l_amendment_flag = 'I' THEN
    l_result := true;
    END IF;
   ELSE
      l_result := hr_jp_ast_utility_pkg.formula_validate(p_formula_id,p_assignment_id,p_effective_date);
   END IF;
--
  RETURN l_result;
--
EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_location('chk_ass_set'||substr(sqlerrm,1,200),99);
  RETURN FALSE;
END chk_ass_set;
--
/****************************************************************************
  Name        : chk_ass_set_mixed
  Description : This fucntion checks if the assignment set passed is based
                on both criteria and amendment or not.
 *****************************************************************************/
FUNCTION chk_ass_set_mixed(
           p_assignment_set_id  IN NUMBER) RETURN NUMBER
IS
l_dummy NUMBER;
--
BEGIN
  SELECT 1
  INTO  l_dummy
  FROM  HR_ASSIGNMENT_SET_AMENDMENTS
  WHERE  ASSIGNMENT_SET_ID = p_assignment_set_id
  AND  ROWNUM  = 1;
RETURN  l_dummy;
EXCEPTION
  WHEN  NO_DATA_FOUND  THEN
  l_dummy := 0;
RETURN  l_dummy;
END chk_ass_set_mixed;
--
/****************************************************************************
  Name        : chk_all_exclusions
  Description : This fucntion checks if the assignment set passed has only
                exclusions.
 *****************************************************************************/
FUNCTION chk_all_exclusions(
                    p_assignment_set_id    IN NUMBER) RETURN NUMBER
IS
l_dummy NUMBER;
BEGIN
  SELECT  0
  INTO  l_dummy
  FROM  HR_ASSIGNMENT_SET_AMENDMENTS
  WHERE ASSIGNMENT_SET_ID = p_assignment_set_id
  AND   INCLUDE_OR_EXCLUDE = 'I'
  AND   ROWNUM  = 1;
RETURN  l_dummy;
EXCEPTION
 WHEN  NO_DATA_FOUND  THEN
 l_dummy := 1;
RETURN  l_dummy;
END chk_all_exclusions;
--
function cnv_str(
  p_text in varchar2,
  p_start in number default null,
  p_end in number default null)
return varchar2
is
--
  l_text varchar2(4000);
--
begin
--
  l_text := ltrim(rtrim(replace(p_text,to_multi_byte(' '),' ')));
--
  if p_start is not null
  and p_end is not null then
  --
    l_text := substr(l_text,p_start,p_end);
  --
  end if;
--
return l_text;
--
end cnv_str;
--
function htmlspchar(
  p_text in varchar2)
return varchar2
is
--
  l_htmlspchar varchar2(1) := 'N';
--
begin
--
  if nvl(instr(p_text,'<'),0) > 0 then
    l_htmlspchar := 'Y';
  end if;
--
  if l_htmlspchar = 'N'
  and nvl(instr(p_text,'>'),0) > 0 then
    l_htmlspchar := 'Y';
  end if;
--
  if l_htmlspchar = 'N'
  and nvl(instr(p_text,'&'),0) > 0 then
    l_htmlspchar := 'Y';
  end if;
--
  if l_htmlspchar = 'N'
  and nvl(instr(p_text,''''),0) > 0 then
    l_htmlspchar := 'Y';
  end if;
--
  if l_htmlspchar = 'N'
  and nvl(instr(p_text,'"'),0) > 0 then
    l_htmlspchar := 'Y';
  end if;
--
if l_htmlspchar = 'Y' then
  return '<![CDATA['||p_text||']]>';
else
  return p_text;
end if;
end htmlspchar;
--
/****************************************************************************
  Name        : PRINT_CLOB
  Description : This procedure prints contents of a CLOB object passed as
                parameter.
*****************************************************************************/
PROCEDURE PRINT_CLOB
(
  p_clob CLOB
) AS
ln_chars  number;
ln_offset number;
lv_buf    varchar2(255);
BEGIN
  ln_chars := 240;
  ln_offset := 1;
  LOOP
    lv_buf := null;
    dbms_lob.read(
      p_clob,
      ln_chars,
      ln_offset,
      lv_buf
    );
    hr_utility.trace(lv_buf);
    ln_offset := ln_offset + ln_chars;
  END LOOP;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  hr_utility.trace ('CLOB contents end.');
END PRINT_CLOB;
--
/****************************************************************************
  Name        : range_cursor
  Arguments   : p_payroll_action_id
                p_sqlstr to return the SQL Statement
  Description : This procedure defines a SQL statement
                to fetch all the people to be included in the report.
                This SQL statement is  used to define the 'chunks' for
                multi-threaded operation
*****************************************************************************/
PROCEDURE range_cursor
(
  P_PAYROLL_ACTION_ID number,
  P_SQLSTR            OUT NOCOPY varchar2
) AS
  l_proc_name             varchar2(100);
BEGIN
  l_proc_name := g_proc_name || 'RANGE_CURSOR';
  hr_utility.trace ('Entering '||l_proc_name);
  hr_utility.trace ('P_PAYROLL_ACTION_ID = '|| p_payroll_action_id);
  p_sqlstr := ' select distinct p.person_id'||
              ' from   per_people_f p,'||
              ' pay_payroll_actions pa'||
              ' where  pa.payroll_action_id = :payroll_action_id'||
              ' and    p.business_group_id = pa.business_group_id'||
              ' order by p.person_id ';
  hr_utility.trace ('Range cursor query : ' || p_sqlstr);
  hr_utility.trace ('Leaving '||l_proc_name);
END range_cursor;
--
/****************************************************************************
  Name        : action_creation
  Arguments   : p_payroll_action_id
                p_start_person_id
                p_end_person_id
                p_chunk_number
  Description :This procedure creates assignment actions for the
               payroll_action_id passed as parameter.
*****************************************************************************/
PROCEDURE action_creation
(
  P_PAYROLL_ACTION_ID number,
  P_START_PERSON_ID   number,
  P_END_PERSON_ID     number,
  P_CHUNK             number
) AS
  CURSOR c_assact(pay_act_id  pay_payroll_actions.payroll_action_id%TYPE,trans_stat varchar2)
  IS
  SELECT  distinct pjiav.assignment_id, pjiav.effective_date
  FROM  per_all_assignments_f paa,
        per_all_people_f pap,
        pay_assignment_actions pas,
        pay_jp_isdf_assact_v pjiav
  WHERE  paa.person_id between p_start_person_id and p_end_person_id
  AND  paa.person_id = pap.person_id
  AND  sysdate between pap.effective_start_date and pap.effective_end_date
  AND  sysdate between paa.effective_start_date and paa.effective_end_date
  AND  pas.assignment_id = paa.assignment_id
  AND  pas.payroll_action_id = pay_act_id
  AND  pjiav.assignment_action_id = pas.assignment_action_id
  AND  pjiav.assignment_id = pas.assignment_id
  AND  (pjiav.transaction_status = decode(trans_stat,'N','A')
       or pjiav.transaction_status = decode(trans_stat,'N','F')
       or pjiav.transaction_status = decode(trans_stat,'Y','A')
       or pjiav.transaction_status = decode(trans_stat,'Y','F')
       or pjiav.transaction_status = decode(trans_stat,'Y','N')
       or pjiav.transaction_status = decode(trans_stat,'Y','U'));  -- Last condition in where clause added for Bug Fix:5487428
--
  l_assact pay_assignment_actions.assignment_action_id%type ;
  l_proc_name     VARCHAR2(60);
  l_old_pact_id   NUMBER;
  l_cur_pact      NUMBER;
  l_legislative_parameters VARCHAR2(2000);
  l_ass_set_id   NUMBER;
  l_result1         VARCHAR2(30);
  l_result2         BOOLEAN;
  l_formula_id     NUMBER;
--
BEGIN
--
  SELECT  legislative_parameters
  INTO  l_legislative_parameters
  FROM  pay_payroll_actions
  WHERE payroll_action_id = P_PAYROLL_ACTION_ID;
--
  l_old_pact_id :=  fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAYROLL_ACTION_ID',l_legislative_parameters));
  l_ass_set_id := fnd_number.canonical_to_number(pay_core_utils.get_parameter('ASSIGNMENT_SET_ID',l_legislative_parameters));
  l_prn_app_opt:= pay_core_utils.get_parameter('PUBLISH_CRITERION',l_legislative_parameters); --Bug Fix:5487428
--
  IF g_debug  THEN
    l_proc_name := g_proc_name || 'ACTION_CREATION';
    hr_utility.trace ('Entering '||l_proc_name);
    hr_utility.trace ('Parameters ....');
    hr_utility.trace ('P_PAYROLL_ACTION_ID = '|| P_PAYROLL_ACTION_ID);
    hr_utility.trace ('P_START_PERSON_ID = '|| P_START_PERSON_ID);
    hr_utility.trace ('P_END_PERSON_ID = '|| P_END_PERSON_ID);
    hr_utility.trace ('P_CHUNK = '|| P_CHUNK);
    hr_utility.trace ('P_OLD_PAYROLL_ACTION-ID = '||l_old_pact_id);
    hr_utility.trace ('P_ASS_SET_ID = '||l_ass_set_id);
    hr_utility.trace ('PRN_EMP_NO = '||l_emp_no_opt);
    hr_utility.trace ('PUBLISH_CRITERION = '||l_prn_app_opt);
  END IF;
--
  if g_bg_id is null then
    Select p.business_group_id into g_bg_id
    from pay_payroll_actions p
    where p.payroll_action_id = p_payroll_action_id ;
  end if ;
--
  IF (g_dummy = -99) THEN
-- IF condition to ensure that functions are called only once.
    g_dummy := chk_ass_set_mixed(l_ass_set_id);
    g_all_exclusions_flag := chk_all_exclusions(l_ass_set_id);
  END IF ;
--
  FOR i IN c_assact(l_old_pact_id,l_prn_app_opt) LOOP
    -- Added NVL to overcome NULL issue.
    IF (NVL(l_ass_set_id,0) = 0) THEN
    -- NO assignment set passed as parameter
      SELECT pay_assignment_actions_s.nextval INTO l_assact FROM dual;
      hr_nonrun_asact.insact(l_assact,
                             i.assignment_id ,
                             p_payroll_action_id,
                             p_chunk,
                             null);
    ELSE
    -- assignment set is passed as parameter
      SELECT formula_id INTO l_formula_id
      FROM hr_assignment_sets
      WHERE assignment_set_id = l_ass_set_id;
    --
      IF l_formula_id IS NULL THEN
      -- assignment set by ammmendment passed
        IF (g_all_exclusions_flag = 0) THEN
        -- assignment set by ammmendment passed is not all exclusions.
          l_result1 := get_amendment_flag(i.assignment_id, l_ass_set_id);
          IF (l_result1 = 'I') THEN
            SELECT pay_assignment_actions_s.nextval INTO l_assact FROM dual;
            hr_nonrun_asact.insact(l_assact,
                                   i.assignment_id ,
                                   p_payroll_action_id,
                                   p_chunk,
                                   null);
          END IF;
        --
        ELSE
        -- assignment set by ammmendment passed is all exclusions.
          l_result1 := get_amendment_flag(i.assignment_id, l_ass_set_id);
          IF (l_result1 <> 'E') THEN
            SELECT pay_assignment_actions_s.nextval INTO l_assact FROM dual;
            hr_nonrun_asact.insact(l_assact,
                                   i.assignment_id ,
                                   p_payroll_action_id,
                                   p_chunk,
                                   null);
          END IF;
        --
        END IF;
      --
      ELSE
      -- assignment set by criteria passed
        l_result2 := chk_ass_set(i.assignment_id, l_ass_set_id, l_formula_id, i.effective_date, g_dummy);
        IF (l_result2 = TRUE) THEN
          SELECT pay_assignment_actions_s.nextval into l_assact from dual;
          hr_nonrun_asact.insact(l_assact,
                                 i.assignment_id ,
                                 p_payroll_action_id,
                                 p_chunk,
                                 null);
        END IF;
      --
      END IF;
    --
    END IF;
  --
  END LOOP;
--
END action_creation;
--
/****************************************************************************
  Name        : init_code
  Description : None
*****************************************************************************/
PROCEDURE INIT_CODE ( P_PAYROLL_ACTION_ID  IN NUMBER) IS
BEGIN
  hr_utility.trace ('inside INIT_CODE ');
  NULL;
END;
--
/****************************************************************************
  Name        : archive_code
  Description : None
*****************************************************************************/
PROCEDURE ARCHIVE_CODE ( P_ASSIGNMENT_ACTION_ID IN  NUMBER,
                         P_EFFECTIVE_DATE       IN  DATE  ) IS
BEGIN
  hr_utility.trace ('inside ARCHIVE_CODE ');
  NULL;
END ;
--
/****************************************************************************
  Name        : assact_xml
  Arguments   : p_assignment_action_id
  Description : This procedure creates xml for the assignment_action_id passed
                as parameter. It then writes the xml into vXMLTable.
*****************************************************************************/
PROCEDURE assact_xml(
  p_assignment_action_id  IN NUMBER)
IS
--
  CURSOR cur_isdf_employer(p_mag_asg_action_id NUMBER)
  IS
  SELECT to_char(pjip.effective_date, 'EEYY', 'NLS_CALENDAR=''Japanese Imperial''') year,
         pjip.effective_date,
         pjip.tax_office_name,
         pjip.salary_payer_name,
         pjip.salary_payer_address
  FROM   pay_jp_isdf_pact_v pjip,
         pay_assignment_actions paa
  WHERE  paa.assignment_action_id = p_mag_asg_action_id
  AND    paa.payroll_action_id = pjip.payroll_action_id;
  --
  isdf_employer_c cur_isdf_employer%ROWTYPE;
--
  CURSOR cur_isdf_emp(p_mag_asg_action_id NUMBER)
  IS
  SELECT pjie.last_name_kana,
         pjie.first_name_kana,
         pjie.last_name,
         pjie.first_name,
         pjie.address,
         pjie.employee_number /* Enh:5671124 : Employee_number addition */
  FROM   pay_jp_isdf_emp_v pjie
  WHERE  pjie.assignment_action_id = p_mag_asg_action_id;
  --
  isdf_emp_c cur_isdf_emp%ROWTYPE;
--
  cursor cur_isdf_calc(p_mag_asg_action_id NUMBER)
  is
  select decode(pjicd.life_gen_ins_prem,           0,null,pjicd.life_gen_ins_prem)            life_gen_ins_prem,
         decode(pjicd.life_pens_ins_prem,          0,null,pjicd.life_pens_ins_prem)           life_pens_ins_prem,
         decode(pjicd.life_gen_ins_calc_prem,      0,null,pjicd.life_gen_ins_calc_prem)       life_gen_ins_calc_prem,
         decode(pjicd.life_pens_ins_calc_prem,     0,null,pjicd.life_pens_ins_calc_prem)      life_pens_ins_calc_prem,
         decode(pjicd.life_ins_deduction,          0,null,pjicd.life_ins_deduction)           life_ins_deduction,
         decode(pjicd.earthquake_ins_prem,         0,null,pjicd.earthquake_ins_prem)          earthquake_ins_prem,
         decode(pjicd.nonlife_long_ins_prem,       0,null,pjicd.nonlife_long_ins_prem)        nonlife_long_ins_prem,
         decode(pjicd.nonlife_short_ins_prem,      0,null,pjicd.nonlife_short_ins_prem)       nonlife_short_ins_prem,
         decode(pjicd.earthquake_ins_calc_prem,    0,null,pjicd.earthquake_ins_calc_prem)     earthquake_ins_calc_prem,
         decode(pjicd.nonlife_long_ins_calc_prem,  0,null,pjicd.nonlife_long_ins_calc_prem)   nonlife_long_ins_calc_prem,
         decode(pjicd.nonlife_short_ins_calc_prem, 0,null,pjicd.nonlife_short_ins_calc_prem)  nonlife_short_ins_calc_prem,
         decode(pjicd.nonlife_ins_deduction,       0,null,pjicd.nonlife_ins_deduction)        nonlife_ins_deduction,
         decode(pjicd.social_ins_deduction,        0,null,pjicd.social_ins_deduction)         social_ins_deduction,
         decode(pjicd.mutual_aid_deduction,        0,null,pjicd.mutual_aid_deduction)         mutual_aid_deduction,
         decode(pjicd.sp_earned_income_calc,       0,null,pjicd.sp_earned_income_calc)        sp_earned_income_calc,
         decode(pjicd.sp_business_income_calc,     0,null,pjicd.sp_business_income_calc)      sp_business_income_calc,
         decode(pjicd.sp_miscellaneous_income_calc,0,null,pjicd.sp_miscellaneous_income_calc) sp_miscellaneous_income_calc,
         decode(pjicd.sp_dividend_income_calc,     0,null,pjicd.sp_dividend_income_calc)      sp_dividend_income_calc,
         decode(pjicd.sp_real_estate_income_calc,  0,null,pjicd.sp_real_estate_income_calc)   sp_real_estate_income_calc,
         decode(pjicd.sp_retirement_income_calc,   0,null,pjicd.sp_retirement_income_calc)    sp_retirement_income_calc,
         decode(pjicd.sp_other_income_calc,        0,null,pjicd.sp_other_income_calc)         sp_other_income_calc,
         decode(pjicd.sp_income_calc,              0,null,pjicd.sp_income_calc)               sp_income_calc,
         decode(pjicd.spouse_income,               0,null,pjicd.spouse_income)                spouse_income,
         decode(pjicd.spouse_deduction,            0,null,pjicd.spouse_deduction)             spouse_deduction
   from  pay_jp_isdf_calc_dct_v pjicd
   where pjicd.assignment_action_id=p_mag_asg_action_id
   and   pjicd.status <> 'D';
  --
  isdf_calc_c cur_isdf_calc%ROWTYPE;
--
  CURSOR cur_isdf_mutual(p_mag_asg_action_id NUMBER)
  IS
  SELECT pjima.enterprise_contract_prem,
         pjima.pension_prem,
         pjima.disable_sup_contract_prem
  FROM   pay_jp_isdf_mutual_aid_v pjima
  WHERE  pjima.assignment_action_id=p_mag_asg_action_id
  and    pjima.status <> 'D';
  --
  isdf_mutual_c cur_isdf_mutual%ROWTYPE;
--
  CURSOR cur_isdf_spouse(p_mag_asg_action_id NUMBER)
  IS
  SELECT pjis.full_name_kana,
         pjis.full_name,
         pjis.address,
         pjis.emp_income
  FROM   pay_jp_isdf_spouse_v pjis
  WHERE  pjis.assignment_action_id=p_mag_asg_action_id
  and    pjis.status <> 'D';
  --
  isdf_spouse_c cur_isdf_spouse%ROWTYPE;
--
  CURSOR cur_isdf_spouse_inc(p_mag_asg_action_id NUMBER)
  IS
  SELECT pjisi.sp_earned_income,
         pjisi.sp_business_income,
         pjisi.sp_business_income_exp,
         pjisi.sp_miscellaneous_income,
         pjisi.sp_miscellaneous_income_exp,
         pjisi.sp_dividend_income,
         pjisi.sp_dividend_income_exp,
         pjisi.sp_real_estate_income,
         pjisi.sp_real_estate_income_exp,
         pjisi.sp_retirement_income,
         pjisi.sp_retirement_income_exp,
         pjisi.sp_other_income,
         pjisi.sp_other_income_exp,
         pjisi.sp_other_income_exp_dct
   FROM  pay_jp_isdf_spouse_inc_v pjisi
   WHERE pjisi.assignment_action_id=p_mag_asg_action_id
   and   pjisi.status <> 'D';
  --
  isdf_spouse_inc_c cur_isdf_spouse_inc%ROWTYPE;
--
  -- LIFE GEN
  CURSOR cur_isdf_life_gen(p_mag_act_info_id NUMBER)
  IS
  SELECT pjilg.ins_company_name,
         pjilg.ins_type,
         pjilg.ins_period,
         pjilg.contractor_name,
         pjilg.beneficiary_name,
         pjilg.beneficiary_relship,
         pjilg.annual_prem
  FROM   pay_jp_isdf_life_gen_v pjilg
  WHERE  pjilg.assignment_action_id=p_mag_act_info_id
  and    pjilg.status <> 'D';
  --
  TYPE isdf_ins_company_name_lg IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_ins_type_lg IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_ins_period_lg IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_contractor_name_lg IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_beneficiary_name_lg IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_beneficiary_relship_lg IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_annual_prem_lg IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  --
  ins_company_name_lg isdf_ins_company_name_lg;
  ins_type_lg isdf_ins_type_lg;
  ins_period_lg isdf_ins_period_lg;
  contractor_name_lg isdf_contractor_name_lg;
  beneficiary_name_lg isdf_beneficiary_name_lg;
  beneficiary_relship_lg isdf_beneficiary_relship_lg;
  annual_prem_lg isdf_annual_prem_lg;
--
  -- LIFE PENS
  CURSOR cur_isdf_life_pens(p_mag_act_info_id NUMBER)
  IS
  SELECT pjilp.ins_company_name,
         pjilp.ins_type,
         pjilp.ins_period_start_date,
         pjilp.ins_period,
         pjilp.contractor_name,
         pjilp.beneficiary_name,
         pjilp.beneficiary_relship,
         pjilp.annual_prem
  FROM   pay_jp_isdf_life_pens_v pjilp
  WHERE  pjilp.assignment_action_id=p_mag_act_info_id
  and    pjilp.status <> 'D';
  --
  TYPE isdf_ins_company_name_lp IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_ins_type_lp IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_ins_period_start_date_lp IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE isdf_ins_period_lp IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_contractor_name_lp IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_beneficiary_name_lp IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_beneficiary_relship_lp IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_annual_prem_lp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  --
  ins_company_name_lp isdf_ins_company_name_lp;
  ins_type_lp isdf_ins_type_lp;
  ins_period_start_date_lp isdf_ins_period_start_date_lp;
  ins_period_lp isdf_ins_period_lp;
  contractor_name_lp isdf_contractor_name_lp;
  beneficiary_name_lp isdf_beneficiary_name_lp;
  beneficiary_relship_lp isdf_beneficiary_relship_lp;
  annual_prem_lp isdf_annual_prem_lp;
--
  --NONLIFE
  cursor cur_isdf_nonlife(p_mag_act_info_id number)
  is
  select pjin.nonlife_ins_term_type,
         pjin.ins_company_name,
         pjin.ins_type,
         pjin.ins_period,
         pjin.contractor_name,
         pjin.beneficiary_name,
         pjin.beneficiary_relship,
         pjin.maturity_repayment,
         pjin.annual_prem
  from   pay_jp_isdf_nonlife_v pjin
  where  pjin.assignment_action_id=p_mag_act_info_id
  and    pjin.status <> 'D';
  --
  type isdf_nonlife_ins_term_type_nl is table of varchar2(240) index by binary_integer;
  TYPE isdf_ins_company_name_nl IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_ins_type_nl IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_ins_period_nl IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_contractor_name_nl IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_beneficiary_name_nl IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_beneficiary_relship_nl IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_maturity_repayment_nl IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_annual_prem_nl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  --
  nonlife_ins_term_type_nl isdf_nonlife_ins_term_type_nl;
  ins_company_name_nl isdf_ins_company_name_nl;
  ins_type_nl isdf_ins_type_nl;
  ins_period_nl isdf_ins_period_nl;
  contractor_name_nl isdf_contractor_name_nl;
  beneficiary_name_nl isdf_beneficiary_name_nl;
  beneficiary_relship_nl isdf_beneficiary_relship_nl;
  maturity_repayment_nl isdf_maturity_repayment_nl;
  annual_prem_nl isdf_annual_prem_nl;
--
  --SOCIAL
  CURSOR cur_isdf_social(p_mag_act_info_id NUMBER)
  IS
  SELECT pjis.ins_type,
         pjis.ins_payee_name,
         pjis.debtor_name,
         pjis.beneficiary_relship,
         pjis.annual_prem
  FROM   pay_jp_isdf_social_v pjis
  WHERE  pjis.assignment_action_id=p_mag_act_info_id
  and    pjis.status <> 'D';
  --
  TYPE isdf_ins_type_s IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_ins_payee_name_s IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_debtor_name_s IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_beneficiary_relship_s IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE isdf_annual_prem_s IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  --
  ins_type_s isdf_ins_type_s;
  ins_payee_name_s isdf_ins_payee_name_s;
  debtor_name_s isdf_debtor_name_s;
  beneficiary_relship_s isdf_beneficiary_relship_s;
  annual_prem_s isdf_annual_prem_s;
--
  --Variables-----
  k                   NUMBER;
  a                   NUMBER;
  b                   NUMBER;
  c                   NUMBER;
  d                   NUMBER;
  e                   NUMBER;
  i                   NUMBER;
  l1                  NUMBER;
  l2                  NUMBER;
  no_of_pages         NUMBER;
  n_life_gen          NUMBER;
  n_life_pens         NUMBER;
  n_nonlife           NUMBER;
  n_social            NUMBER;
  count_life_gen      NUMBER;
  count_life_pens     NUMBER;
  count_nonlife       NUMBER;
  count_social        NUMBER;
  l_xml               VARCHAR2(4000);
  l_xml2              VARCHAR2(4000);
  l_common_xml_page1  VARCHAR2(4000);
  l_common_xml        VARCHAR2(4000);
  l_xml_begin         VARCHAR2(200);
  first_digit         VARCHAR2(1);
  second_digit        VARCHAR2(1);
  ps_date_length      NUMBER;
  ps_date             VARCHAR2(30);
  spded_value         NUMBER(6,2);
  l_mag_asg_action_id pay_assignment_actions.assignment_action_id%TYPE;
  l_emp_no            VARCHAR2(80);
  --
  l_c13  varchar2(60);
  l_c14  varchar2(60);
  l_c15  varchar2(60);
  l_c16  varchar2(60);
  l_t48  varchar2(60);
  l_t48a varchar2(60);
  l_t48b varchar2(60);
  l_t56  varchar2(60);
  l_t56a varchar2(60);
  l_t56b varchar2(60);
--
BEGIN
--
  if g_msg_circle is null then
  --
    fnd_message.set_name('PER','HR_JP_CIRCLE');
    g_msg_circle := fnd_message.get;
  --
    g_msg_circle := substr(g_msg_circle,0,1);
  --
  end if;
--
  vXMLTable.DELETE;
  vCtr := 0;
  --
  --hr_utility.set_location('Entering : ' || c_proc, 10);
  hr_utility.trace('isdf_xml');
  --
  l_xml_begin := '<isdf>'||EOL||'<isdf1>' || EOL;
  vXMLTable(vCtr).xmlstring :=  l_xml_begin;
  vCtr := vCtr + 1;
  l_mag_asg_action_id :=p_assignment_action_id;
--
  OPEN cur_isdf_employer(l_mag_asg_action_id);
  FETCH cur_isdf_employer INTO isdf_employer_c;
  CLOSE cur_isdf_employer;
  --
  OPEN cur_isdf_emp(l_mag_asg_action_id);
  FETCH cur_isdf_emp INTO isdf_emp_c;
  CLOSE cur_isdf_emp;
  --
  OPEN cur_isdf_calc(l_mag_asg_action_id);
  FETCH cur_isdf_calc INTO isdf_calc_c;
  CLOSE cur_isdf_calc;
  --
  OPEN cur_isdf_mutual(l_mag_asg_action_id);
  FETCH cur_isdf_mutual INTO isdf_mutual_c;
  CLOSE cur_isdf_mutual;
  --
  OPEN cur_isdf_spouse(l_mag_asg_action_id);
  FETCH cur_isdf_spouse INTO isdf_spouse_c;
  CLOSE cur_isdf_spouse;
  --
  OPEN cur_isdf_spouse_inc(l_mag_asg_action_id);
  FETCH cur_isdf_spouse_inc INTO isdf_spouse_inc_c;
  CLOSE cur_isdf_spouse_inc;
--
  -- Code to find the two digits for the spouse deduction field starts
  spded_value := isdf_calc_c.spouse_deduction/10000;
--
  -- assumption, spded_value should consist under 2 digits.
  -- (no business case of decimal or more than 3 digits)
  -- based on current design, 0 is treated as null, so no output.
  -- (not sure whether replacing null is desired or not..)
  first_digit  := substrb(lpad(to_char(trunc(spded_value)),2,'0'),1,1);
  --
  if first_digit = '0' then
    first_digit := null;
  end if;
  --
  -- Code to find the two digits for the spouse deduction field ends
  second_digit := substrb(lpad(to_char(trunc(spded_value)),2,'0'),2,1);
  --
--
  if isdf_employer_c.effective_date < c_st_upd_date_2007 then
    l_c13 := to_char(to_number(isdf_calc_c.nonlife_long_ins_prem),fnd_currency.get_format_mask('JPY',40));
    l_c14 := to_char(to_number(isdf_calc_c.nonlife_short_ins_prem),fnd_currency.get_format_mask('JPY',40));
    l_c15 := to_char(to_number(isdf_calc_c.nonlife_long_ins_calc_prem),fnd_currency.get_format_mask('JPY',40));
    l_c16 := to_char(to_number(isdf_calc_c.nonlife_short_ins_calc_prem),fnd_currency.get_format_mask('JPY',40));
  else
    l_c13 := to_char(to_number(isdf_calc_c.earthquake_ins_prem),fnd_currency.get_format_mask('JPY',40));
    l_c14 := to_char(to_number(isdf_calc_c.nonlife_long_ins_prem),fnd_currency.get_format_mask('JPY',40));
    l_c15 := to_char(to_number(isdf_calc_c.earthquake_ins_calc_prem),fnd_currency.get_format_mask('JPY',40));
    l_c16 := to_char(to_number(isdf_calc_c.nonlife_long_ins_calc_prem),fnd_currency.get_format_mask('JPY',40));
  end if;
--
  -- Creating xml string for pages after first page (repeating page for over lines of printing data records)
  l_common_xml :=
  '<c1>' ||isdf_employer_c.year                                                                                 ||'</c1>' ||EOL||  --year
  '<c2>' ||htmlspchar(cnv_str(isdf_employer_c.tax_office_name))                                                 ||'</c2>' ||EOL||  --tax_office_name
  '<c3>' ||htmlspchar(cnv_str(isdf_employer_c.salary_payer_name))                                               ||'</c3>' ||EOL||  --employer_full_name
  '<c4>' ||htmlspchar(cnv_str(isdf_employer_c.salary_payer_address))                                            ||'</c4>' ||EOL||  --employer_address
  '<c5>' ||htmlspchar(cnv_str(isdf_emp_c.last_name_kana)||''||cnv_str(isdf_emp_c.first_name_kana))              ||'</c5>' ||EOL||  --kana_name
  '<c6>' ||htmlspchar(cnv_str(isdf_emp_c.last_name)||''||cnv_str(isdf_emp_c.first_name))                        ||'</c6>' ||EOL||  --name
  '<c7>' ||htmlspchar(cnv_str(isdf_emp_c.address))                                                              ||'</c7>' ||EOL||  --address
  '<c8>' ||htmlspchar(to_char(to_number(isdf_calc_c.life_gen_ins_prem),fnd_currency.get_format_mask('JPY',40))) ||'</c8>' ||EOL||  --life_gen_ins_prem
  '<c9>' ||htmlspchar(to_char(to_number(isdf_calc_c.life_pens_ins_prem),fnd_currency.get_format_mask('JPY',40)))||'</c9>' ||EOL||  --life_pens_ins_prem
  '<c10>'||to_char(to_number(isdf_calc_c.life_gen_ins_calc_prem),fnd_currency.get_format_mask('JPY',40))        ||'</c10>'||EOL||  --life_gen_ins_calc_prem
  '<c11>'||to_char(to_number(isdf_calc_c.life_pens_ins_calc_prem),fnd_currency.get_format_mask('JPY',40))       ||'</c11>'||EOL||  --life_pens_ins_calc_prem
  '<c12>'||to_char(to_number(isdf_calc_c.life_ins_deduction),fnd_currency.get_format_mask('JPY',40))            ||'</c12>'||EOL||  --life_ins_deduction
  '<c13>'||l_c13                                                                                                ||'</c13>'||EOL||  --nonlife_long_ins_prem
  '<c14>'||l_c14                                                                                                ||'</c14>'||EOL||  --nonlife_short_ins_prem
  '<c15>'||l_c15                                                                                                ||'</c15>'||EOL||  --nonlife_long_ins_calc_prem
  '<c16>'||l_c16                                                                                                ||'</c16>'||EOL||  --nonlife_short_ins_calc_prem
  '<c17>'||to_char(to_number(isdf_calc_c.nonlife_ins_deduction),fnd_currency.get_format_mask('JPY',40))         ||'</c17>'||EOL||  --nonlife_ins_deduction
  '<c18>'||to_char(to_number(isdf_calc_c.social_ins_deduction),fnd_currency.get_format_mask('JPY',40))          ||'</c18>'||EOL||  --social_ins_deduction
  '<c19>'||to_char(to_number(isdf_calc_c.mutual_aid_deduction),fnd_currency.get_format_mask('JPY',40))          ||'</c19>'||EOL||  --mutual_aid_deduction
  '<c30>'||isdf_employer_c.year                                                                                 ||'</c30>';
  --
  --Parameter support for print Employee No option --
  --
  if l_emp_no_opt = 'N' then
  --
    l_emp_no := '';
  --
  -- l_emp_no_opt = Y (SRS) or null (SS)
  else
  --
    l_emp_no :=cnv_str(isdf_emp_c.employee_number);
  --
  end if;
--
  -- Creating common xml string for page1
  l_common_xml_page1 :=
  '<c1>' ||isdf_employer_c.year                                                                                    ||'</c1>' ||EOL|| --year
  '<c2>' ||htmlspchar(cnv_str(isdf_employer_c.tax_office_name))                                                    ||'</c2>' ||EOL|| --tax_office_name
  '<c3>' ||htmlspchar(cnv_str(isdf_employer_c.salary_payer_name))                                                  ||'</c3>' ||EOL|| --employer_full_name
  '<c4>' ||htmlspchar(cnv_str(isdf_employer_c.salary_payer_address))                                               ||'</c4>' ||EOL|| --employer_address
  '<c5>' ||htmlspchar(cnv_str(isdf_emp_c.last_name_kana)||''||cnv_str(isdf_emp_c.first_name_kana))                 ||'</c5>' ||EOL|| --kana_name
  '<c6>' ||htmlspchar(cnv_str(isdf_emp_c.last_name)||''||cnv_str(isdf_emp_c.first_name))                           ||'</c6>' ||EOL|| --name
  '<c7>' ||htmlspchar(cnv_str(isdf_emp_c.address))                                                                 ||'</c7>' ||EOL|| --address
  '<c7a>'||htmlspchar(l_emp_no)                                                                                    ||'</c7a>'||EOL|| -- employee number
  '<c8>' ||htmlspchar(to_char(to_number(isdf_calc_c.life_gen_ins_prem),fnd_currency.get_format_mask('JPY',40)))    ||'</c8>' ||EOL|| --life_gen_ins_prem
  '<c9>' ||htmlspchar(to_char(to_number(isdf_calc_c.life_pens_ins_prem),fnd_currency.get_format_mask('JPY',40)))   ||'</c9>' ||EOL|| --life_pens_ins_prem
  '<c10>'||to_char(to_number(isdf_calc_c.life_gen_ins_calc_prem),fnd_currency.get_format_mask('JPY',40))           ||'</c10>'||EOL|| --life_gen_ins_calc_prem
  '<c11>'||to_char(to_number(isdf_calc_c.life_pens_ins_calc_prem),fnd_currency.get_format_mask('JPY',40))          ||'</c11>'||EOL|| --life_pens_ins_calc_prem
  '<c12>'||to_char(to_number(isdf_calc_c.life_ins_deduction),fnd_currency.get_format_mask('JPY',40))               ||'</c12>'||EOL|| --life_ins_deduction
  '<c13>'||l_c13                                                                                                   ||'</c13>'||EOL|| --nonlife_long_ins_prem
  '<c14>'||l_c14                                                                                                   ||'</c14>'||EOL|| --nonlife_short_ins_prem
  '<c15>'||l_c15                                                                                                   ||'</c15>'||EOL|| --nonlife_long_ins_calc_prem
  '<c16>'||l_c16                                                                                                   ||'</c16>'||EOL|| --nonlife_short_ins_calc_prem
  '<c17>'||to_char(to_number(isdf_calc_c.nonlife_ins_deduction),fnd_currency.get_format_mask('JPY',40))            ||'</c17>'||EOL|| --nonlife_ins_deduction
  '<c18>'||to_char(to_number(isdf_calc_c.social_ins_deduction),fnd_currency.get_format_mask('JPY',40))             ||'</c18>'||EOL|| --social_ins_deduction
  '<c19>'||to_char(to_number(isdf_calc_c.mutual_aid_deduction),fnd_currency.get_format_mask('JPY',40))             ||'</c19>'||EOL|| --mutual_aid_deduction
  '<c20>'||to_char(to_number(isdf_calc_c.spouse_income),fnd_currency.get_format_mask('JPY',40))                    ||'</c20>'||EOL|| --spouse_income
  '<c21>'||first_digit                                                                                             ||'</c21>'||EOL|| --first_digit
  '<c22>'||second_digit                                                                                            ||'</c22>'||EOL|| --second_digit
  '<c23>'||to_char(to_number(isdf_mutual_c.enterprise_contract_prem),fnd_currency.get_format_mask('JPY',40))       ||'</c23>'||EOL|| --enterprise_contract_prem
  '<c24>'||to_char(to_number(isdf_mutual_c.pension_prem),fnd_currency.get_format_mask('JPY',40))                   ||'</c24>'||EOL|| --pension_prem
  '<c25>'||to_char(to_number(isdf_mutual_c.disable_sup_contract_prem),fnd_currency.get_format_mask('JPY',40))      ||'</c25>'||EOL|| --disable_sup_contract_prem
  '<c26>'||htmlspchar(cnv_str(isdf_spouse_c.full_name_kana))                                                       ||'</c26>'||EOL|| --sp_full_name_kana
  '<c27>'||htmlspchar(cnv_str(isdf_spouse_c.full_name))                                                            ||'</c27>'||EOL|| --sp_full_name
  '<c28>'||htmlspchar(cnv_str(isdf_spouse_c.address))                                                              ||'</c28>'||EOL|| --sp_address
  '<c29>'||to_char(to_number(isdf_spouse_c.emp_income),fnd_currency.get_format_mask('JPY',40))                     ||'</c29>'||EOL|| --sp_emp_income
  '<c30>'||isdf_employer_c.year                                                                                    ||'</c30>'||EOL|| --year
  '<p1>' ||to_char(to_number(isdf_calc_c.sp_earned_income_calc),fnd_currency.get_format_mask('JPY',40))            ||'</p1>' ||EOL|| --sp_earned_income_calc
  '<p2>' ||to_char(to_number(isdf_calc_c.sp_business_income_calc),fnd_currency.get_format_mask('JPY',40))          ||'</p2>' ||EOL|| --sp_business_income_calc
  '<p3>' ||to_char(to_number(isdf_calc_c.sp_miscellaneous_income_calc),fnd_currency.get_format_mask('JPY',40))     ||'</p3>' ||EOL|| --sp_miscellaneous_income_calc
  '<p4>' ||to_char(to_number(isdf_calc_c.sp_dividend_income_calc),fnd_currency.get_format_mask('JPY',40))          ||'</p4>' ||EOL|| --sp_dividend_income_calc
  '<p5>' ||to_char(to_number(isdf_calc_c.sp_real_estate_income_calc),fnd_currency.get_format_mask('JPY',40))       ||'</p5>' ||EOL|| --sp_real_estate_income_calc
  '<p6>' ||to_char(to_number(isdf_calc_c.sp_retirement_income_calc),fnd_currency.get_format_mask('JPY',40))        ||'</p6>' ||EOL|| --sp_retirement_income_calc
  '<p7>' ||to_char(to_number(isdf_calc_c.sp_other_income_calc),fnd_currency.get_format_mask('JPY',40))             ||'</p7>' ||EOL|| --sp_other_income_calc
  '<p8>' ||to_char(to_number(isdf_calc_c.sp_income_calc),fnd_currency.get_format_mask('JPY',40))                   ||'</p8>' ||EOL|| --sp_income_calc
  '<p9>' ||to_char(to_number(isdf_spouse_inc_c.sp_earned_income),fnd_currency.get_format_mask('JPY',40))           ||'</p9>' ||EOL|| --sp_earned_income
  '<p10>'||to_char(to_number(isdf_spouse_inc_c.sp_business_income),fnd_currency.get_format_mask('JPY',40))         ||'</p10>'||EOL|| --sp_business_income
  '<p11>'||to_char(to_number(isdf_spouse_inc_c.sp_business_income_exp),fnd_currency.get_format_mask('JPY',40))     ||'</p11>'||EOL|| --sp_business_income_exp
  '<p12>'||to_char(to_number(isdf_spouse_inc_c.sp_miscellaneous_income),fnd_currency.get_format_mask('JPY',40))    ||'</p12>'||EOL|| --sp_miscellaneous_income
  '<p13>'||to_char(to_number(isdf_spouse_inc_c.sp_miscellaneous_income_exp),fnd_currency.get_format_mask('JPY',40))||'</p13>'||EOL|| --sp_misc_income_exp
  '<p14>'||to_char(to_number(isdf_spouse_inc_c.sp_dividend_income),fnd_currency.get_format_mask('JPY',40))         ||'</p14>'||EOL|| --sp_dividend_income
  '<p15>'||to_char(to_number(isdf_spouse_inc_c.sp_dividend_income_exp),fnd_currency.get_format_mask('JPY',40))     ||'</p15>'||EOL|| --sp_dividend_income_exp
  '<p16>'||to_char(to_number(isdf_spouse_inc_c.sp_real_estate_income),fnd_currency.get_format_mask('JPY',40))      ||'</p16>'||EOL|| --sp_real_estate_income
  '<p17>'||to_char(to_number(isdf_spouse_inc_c.sp_real_estate_income_exp),fnd_currency.get_format_mask('JPY',40))  ||'</p17>'||EOL|| --sp_real_estate_income_exp
  '<p18>'||to_char(to_number(isdf_spouse_inc_c.sp_retirement_income),fnd_currency.get_format_mask('JPY',40))       ||'</p18>'||EOL|| --sp_retirement_income
  '<p19>'||to_char(to_number(isdf_spouse_inc_c.sp_retirement_income_exp),fnd_currency.get_format_mask('JPY',40))   ||'</p19>'||EOL|| --sp_retirement_income_exp
  '<p20>'||to_char(to_number(isdf_spouse_inc_c.sp_other_income),fnd_currency.get_format_mask('JPY',40))            ||'</p20>'||EOL|| --sp_other_income
  '<p21>'||to_char(to_number(isdf_spouse_inc_c.sp_other_income_exp),fnd_currency.get_format_mask('JPY',40))        ||'</p21>'||EOL|| --sp_other_income_exp
  '<p22>'||to_char(to_number(isdf_spouse_inc_c.sp_other_income_exp_dct),fnd_currency.get_format_mask('JPY',40))    ||'</p22>';       --sp_include_special_deduction
--
  -- Code to determine the number of pages start.
  --
  SELECT count(DISTINCT(action_information_id))
  INTO   count_life_gen
  FROM   pay_jp_isdf_life_gen_v pjilg
  WHERE  pjilg.assignment_action_id = l_mag_asg_action_id
  and    pjilg.status <> 'D';
  --
  IF (count_life_gen = 0) THEN
    n_life_gen := 1;
  ELSIF ( mod(count_life_gen,3) = 0) THEN
    n_life_gen := (count_life_gen/3);
  ELSE
    n_life_gen := ((count_life_gen - mod(count_life_gen,3))/3) + 1;
  END IF;
  --
  SELECT count(DISTINCT(action_information_id))
  INTO   count_life_pens
  FROM   pay_jp_isdf_life_pens_v pjilp
  WHERE  pjilp.assignment_action_id = l_mag_asg_action_id
  and    pjilp.status <> 'D';
  --
  IF (count_life_pens = 0) THEN
    n_life_pens := 1;
  ELSIF ( mod(count_life_pens, 2) = 0) THEN
    n_life_pens := (count_life_pens/2);
  ELSE
    n_life_pens := ((count_life_pens - mod(count_life_pens,2))/2) + 1;
  END IF;
  --
  SELECT count(DISTINCT(action_information_id))
  INTO   count_nonlife
  FROM   pay_jp_isdf_nonlife_v pjin
  WHERE  pjin.assignment_action_id = l_mag_asg_action_id
  and    pjin.status <> 'D';
  --
  IF (count_nonlife = 0) THEN
    n_nonlife := 1;
  ELSIF ( mod(count_nonlife, 2) = 0) THEN
    n_nonlife := (count_nonlife/2);
  ELSE
    n_nonlife := ((count_nonlife - mod(count_nonlife,2))/2) + 1;
  END IF;
--
  SELECT count(DISTINCT(action_information_id))
  INTO   count_social
  FROM   pay_jp_isdf_social_v pjis
  WHERE  pjis.assignment_action_id = l_mag_asg_action_id
  and    pjis.status <> 'D';
  --
  IF (count_social = 0) THEN
    n_social := 1;
  ELSIF ( mod(count_social, 3) = 0) THEN
    n_social := (count_social/3);
  ELSE
    n_social := ((count_social - mod(count_social,3))/3) + 1;
  END IF;
--
  IF (n_life_gen >= n_life_pens) THEN
    l1 := n_life_gen;
  ELSE
    l1 := n_life_pens;
  END IF;
  --
  IF (n_nonlife >= n_social) THEN
    l2 := n_nonlife;
  ELSE
    l2 := n_social;
  END IF;
--
  IF (l1 >= l2) THEN
    no_of_pages := l1;
  ELSE
    no_of_pages := l2;
  END IF;
--
  -- Code to determine the number of pages end.
  OPEN cur_isdf_life_gen (l_mag_asg_action_id);
  FETCH cur_isdf_life_gen BULK COLLECT INTO ins_company_name_lg, ins_type_lg, ins_period_lg, contractor_name_lg, beneficiary_name_lg, beneficiary_relship_lg, annual_prem_lg;
  CLOSE cur_isdf_life_gen;
  --
  OPEN cur_isdf_life_pens (l_mag_asg_action_id);
  FETCH cur_isdf_life_pens BULK COLLECT INTO ins_company_name_lp, ins_type_lp, ins_period_start_date_lp, ins_period_lp, contractor_name_lp, beneficiary_name_lp, beneficiary_relship_lp, annual_prem_lp;  CLOSE cur_isdf_life_pens;
  --
  OPEN cur_isdf_nonlife (l_mag_asg_action_id);
  FETCH cur_isdf_nonlife BULK COLLECT INTO nonlife_ins_term_type_nl, ins_company_name_nl, ins_type_nl, ins_period_nl, contractor_name_nl, beneficiary_name_nl, beneficiary_relship_nl, maturity_repayment_nl, annual_prem_nl;
  CLOSE cur_isdf_nonlife;
  --
  OPEN cur_isdf_social (l_mag_asg_action_id);
  FETCH cur_isdf_social BULK COLLECT INTO ins_type_s, ins_payee_name_s, debtor_name_s, beneficiary_relship_s, annual_prem_s;
  CLOSE cur_isdf_social;
  --
  i := 0;
  --
  hr_utility.set_location('NO. OF PAGES :', no_of_pages);
  --
  WHILE i < no_of_pages
  LOOP
  --
    a := 3 * i + 1;
    b := 3 * i + 2;
    c := 3 * i + 3;
    d := 2 * i + 1;
    e := 2 * i + 2;
  --
    hr_utility.set_location('value of VARIABLES IN ISDF COMP XML A:', a);
    hr_utility.set_location('value of VARIABLES IN ISDF COMP XML B:', b);
    hr_utility.set_location('value of VARIABLES IN ISDF COMP XML C:', c);
    hr_utility.set_location('value of VARIABLES IN ISDF COMP XML D:', d);
    hr_utility.set_location('value of VARIABLES IN ISDF COMP XML E:', e);
  --
    IF (i = 0) THEN
      l_xml := '<page>'||EOL||l_common_xml_page1||EOL;
    ELSE
      l_xml := '<page>'||EOL||l_common_xml||EOL;
    END IF;
  --
    -- writing first part of xml to vXMLtable
    vXMLTable(vCtr).xmlstring := l_xml;
    vCtr := vCtr + 1;
  --
    l_t48  := null;
    l_t56  := null;
    --
    l_t48a := null;
    l_t56a := null;
    l_t48b := null;
    l_t56b := null;
  --
    IF (ins_company_name_lg.count >= a) THEN
    --
      l_xml :=        '<t1>'||htmlspchar(cnv_str(ins_company_name_lg(a)))   ||'</t1>'||EOL; --ins_company_name_lg1
      l_xml := l_xml||'<t2>'||htmlspchar(cnv_str(ins_type_lg(a)))           ||'</t2>'||EOL; --ins_type_lg1
      l_xml := l_xml||'<t3>'||htmlspchar(cnv_str(ins_period_lg(a)))         ||'</t3>'||EOL; --ins_period_lg1
      l_xml := l_xml||'<t4>'||htmlspchar(cnv_str(contractor_name_lg(a)))    ||'</t4>'||EOL; --contractor_name_lg1
      l_xml := l_xml||'<t5>'||htmlspchar(cnv_str(beneficiary_name_lg(a)))   ||'</t5>'||EOL; --beneficiary_name_lg1
      l_xml := l_xml||'<t6>'||htmlspchar(cnv_str(beneficiary_relship_lg(a)))||'</t6>'||EOL; --beneficiary_relship_lg1
      l_xml := l_xml||'<t7>'||htmlspchar(to_char(to_number(annual_prem_lg(a)),fnd_currency.get_format_mask('JPY',40)))||'</t7>'  ||EOL;   --annual_prem_lg1
    --
    ELSE
    --
      l_xml :=        '<t1>'||' '||'</t1>'||EOL; --ins_company_name_lg1
      l_xml := l_xml||'<t2>'||' '||'</t2>'||EOL; --ins_type_lg1
      l_xml := l_xml||'<t3>'||' '||'</t3>'||EOL; --ins_period_lg1
      l_xml := l_xml||'<t4>'||' '||'</t4>'||EOL; --contractor_name_lg1
      l_xml := l_xml||'<t5>'||' '||'</t5>'||EOL; --beneficiary_name_lg1
      l_xml := l_xml||'<t6>'||' '||'</t6>'||EOL; --beneficiary_relship_lg1
      l_xml := l_xml||'<t7>'||' '||'</t7>'||EOL; --annual_prem_lg1
    --
    END IF;
  --
    IF (ins_company_name_lg.count >= b) THEN
    --
      l_xml := l_xml||'<t8>' ||htmlspchar(cnv_str(ins_company_name_lg(b)))   ||'</t8>' ||EOL; --ins_company_name_lg2
      l_xml := l_xml||'<t9>' ||htmlspchar(cnv_str(ins_type_lg(b)))           ||'</t9>' ||EOL; --ins_type_lg2
      l_xml := l_xml||'<t10>'||htmlspchar(cnv_str(ins_period_lg(b)))         ||'</t10>'||EOL; --ins_period_lg2
      l_xml := l_xml||'<t11>'||htmlspchar(cnv_str(contractor_name_lg(b)))    ||'</t11>'||EOL; --contractor_name_lg2
      l_xml := l_xml||'<t12>'||htmlspchar(cnv_str(beneficiary_name_lg(b)))   ||'</t12>'||EOL; --beneficiary_name_lg2
      l_xml := l_xml||'<t13>'||htmlspchar(cnv_str(beneficiary_relship_lg(b)))||'</t13>'||EOL; --beneficiary_relship_lg2
      l_xml := l_xml||'<t14>'||htmlspchar(to_char(to_number(annual_prem_lg(b)),fnd_currency.get_format_mask('JPY',40)))||'</t14>'||EOL; --annual_prem_lg2
    --
    ELSE
    --
      l_xml := l_xml||'<t8>' ||' '||'</t8>' ||EOL; --ins_company_name_lg2
      l_xml := l_xml||'<t9>' ||' '||'</t9>' ||EOL; --ins_type_lg2
      l_xml := l_xml||'<t10>'||' '||'</t10>'||EOL; --ins_period_lg2
      l_xml := l_xml||'<t11>'||' '||'</t11>'||EOL; --contractor_name_lg2
      l_xml := l_xml||'<t12>'||' '||'</t12>'||EOL; --beneficiary_name_lg2
      l_xml := l_xml||'<t13>'||' '||'</t13>'||EOL; --beneficiary_relship_lg2
      l_xml := l_xml||'<t14>'||' '||'</t14>'||EOL; --annual_prem_lg2
    --
    END IF;
  --
    IF (ins_company_name_lg.count >= c) THEN
    --
      l_xml := l_xml||'<t15>'||htmlspchar(cnv_str(ins_company_name_lg(c)))   ||'</t15>'||EOL; --ins_company_name_lg3
      l_xml := l_xml||'<t16>'||htmlspchar(cnv_str(ins_type_lg(c)))           ||'</t16>'||EOL; --ins_type_lg3
      l_xml := l_xml||'<t17>'||htmlspchar(cnv_str(ins_period_lg(c)))         ||'</t17>'||EOL; --ins_period_lg3
      l_xml := l_xml||'<t18>'||htmlspchar(cnv_str(contractor_name_lg(c)))    ||'</t18>'||EOL; --contractor_name_lg3
      l_xml := l_xml||'<t19>'||htmlspchar(cnv_str(beneficiary_name_lg(c)))   ||'</t19>'||EOL; --beneficiary_name_lg3
      l_xml := l_xml||'<t20>'||htmlspchar(cnv_str(beneficiary_relship_lg(c)))||'</t20>'||EOL; --beneficiary_relship_lg3
      l_xml := l_xml||'<t21>'||htmlspchar(to_char(to_number(annual_prem_lg(c)),fnd_currency.get_format_mask('JPY',40)))||'</t21>'||EOL; --annual_prem_lg3
    --
    ELSE
    --
      l_xml := l_xml||'<t15>'||' '||'</t15>'||EOL; --ins_company_name_lg3
      l_xml := l_xml||'<t16>'||' '||'</t16>'||EOL; --ins_type_lg3
      l_xml := l_xml||'<t17>'||' '||'</t17>'||EOL; --ins_period_lg3
      l_xml := l_xml||'<t18>'||' '||'</t18>'||EOL; --contractor_name_lg3
      l_xml := l_xml||'<t19>'||' '||'</t19>'||EOL; --beneficiary_name_lg3
      l_xml := l_xml||'<t20>'||' '||'</t20>'||EOL; --beneficiary_relship_lg3
      l_xml := l_xml||'<t21>'||' '||'</t21>'||EOL; --annual_prem_lg3
    --
    END IF;
  --
    IF (ins_company_name_lp.count >= d) THEN
    --
      select to_char(ins_period_start_date_lp(d),'EEYYMMDD"','NLS_CALENDAR=''Japanese Imperial''')
      into ps_date
      from dual;
    --
      -- ps_date_length := length(ins_period_start_date_lp(d));
      ps_date_length := length(ps_date);
    --
      l_xml := l_xml||'<t22>'||htmlspchar(cnv_str(ins_company_name_lp(d)))   ||'</t22>'||EOL; --ins_company_name_lp1
      l_xml := l_xml||'<t23>'||htmlspchar(cnv_str(ins_type_lp(d)))           ||'</t23>'||EOL; --ins_type_lp1
      l_xml := l_xml||'<t24>'||substr(ps_date,ps_date_length - 5,2)          ||'</t24>'||EOL; --ins_period_start_year_lp1
      l_xml := l_xml||'<t25>'||substr(ps_date,ps_date_length - 3,2)          ||'</t25>'||EOL; --ins_period_start_month_lp1
      l_xml := l_xml||'<t26>'||substr(ps_date,ps_date_length - 1,2)          ||'</t26>'||EOL; --ins_period_start_day_lp1
      l_xml := l_xml||'<t27>'||htmlspchar(cnv_str(ins_period_lp(d)))         ||'</t27>'||EOL; --ins_period_lp1
      l_xml := l_xml||'<t28>'||htmlspchar(cnv_str(contractor_name_lp(d)))    ||'</t28>'||EOL; --contractor_name_lp1
      l_xml := l_xml||'<t29>'||htmlspchar(cnv_str(beneficiary_name_lp(d)))   ||'</t29>'||EOL; --beneficiary_name_lp1
      l_xml := l_xml||'<t30>'||htmlspchar(cnv_str(beneficiary_relship_lp(d)))||'</t30>'||EOL; --beneficiary_relship_lp1
      l_xml := l_xml||'<t31>'||htmlspchar(to_char(to_number(annual_prem_lp(d)),fnd_currency.get_format_mask('JPY',40)))||'</t31>'||EOL; --annual_prem_lp1
    --
    ELSE
    --
      l_xml := l_xml||'<t22>'||' '||'</t22>'||EOL; --ins_company_name_lp1
      l_xml := l_xml||'<t23>'||' '||'</t23>'||EOL; --ins_type_lp1
      l_xml := l_xml||'<t24>'||' '||'</t24>'||EOL; --ins_period_start_year_lp1
      l_xml := l_xml||'<t25>'||' '||'</t25>'||EOL; --ins_period_start_month_lp1
      l_xml := l_xml||'<t26>'||' '||'</t26>'||EOL; --ins_period_start_day_lp1
      l_xml := l_xml||'<t27>'||' '||'</t27>'||EOL; --ins_period_lp1
      l_xml := l_xml||'<t28>'||' '||'</t28>'||EOL; --contractor_name_lp1
      l_xml := l_xml||'<t29>'||' '||'</t29>'||EOL; --beneficiary_name_lp1
      l_xml := l_xml||'<t30>'||' '||'</t30>'||EOL; --beneficiary_relship_ lp1
      l_xml := l_xml||'<t31>'||' '||'</t31>'||EOL; --annual_prem_lp1
    --
    END IF;
  --
    IF (ins_company_name_lp.count >= e) THEN
    --
      select to_char(ins_period_start_date_lp(e),'EEYYMMDD"','NLS_CALENDAR=''Japanese Imperial''')
      into ps_date
      from dual;
    --
      ps_date_length := length(ps_date);
    --
      l_xml := l_xml||'<t32>'||htmlspchar(cnv_str(ins_company_name_lp(e)))   ||'</t32>'||EOL; --ins_company_name_lp2
      l_xml := l_xml||'<t33>'||htmlspchar(cnv_str(ins_type_lp(e)))           ||'</t33>'||EOL; --ins_type_lp2
      l_xml := l_xml||'<t34>'||substr(ps_date,ps_date_length - 5,2)          ||'</t34>'||EOL; --ins_period_start_year_lp2
      l_xml := l_xml||'<t35>'||substr(ps_date, ps_date_length - 3,2)         ||'</t35>'||EOL; --ins_period_start_month_lp2
      l_xml := l_xml||'<t36>'||substr(ps_date, ps_date_length - 1,2)         ||'</t36>'||EOL; --ins_period_start_day_lp2
      l_xml := l_xml||'<t37>'||htmlspchar(cnv_str(ins_period_lp(e)))         ||'</t37>'||EOL; --ins_period_lp2
      l_xml := l_xml||'<t38>'||htmlspchar(cnv_str(contractor_name_lp(e)))    ||'</t38>'||EOL; --contractor_name_lp2
      l_xml := l_xml||'<t39>'||htmlspchar(cnv_str(beneficiary_name_lp(e)))   ||'</t39>'||EOL; --beneficiary_name_lp2
      l_xml := l_xml||'<t40>'||htmlspchar(cnv_str(beneficiary_relship_lp(e)))||'</t40>'||EOL; --beneficiary_relship_lp2
      l_xml := l_xml||'<t41>'||htmlspchar(to_char(to_number(annual_prem_lp(e)),fnd_currency.get_format_mask('JPY',40)))||'</t41>'||EOL; --annual_prem_lp2
    --
    ELSE
    --
      l_xml := l_xml||'<t32>'||' '||'</t32>'||EOL;  --ins_company_name_lp2
      l_xml := l_xml||'<t33>'||' '||'</t33>'||EOL;  --ins_type_lp2
      l_xml := l_xml||'<t34>'||' '||'</t34>'||EOL;  --ins_period_start_year_lp2
      l_xml := l_xml||'<t35>'||' '||'</t35>'||EOL;  --ins_period_start_month_lp2
      l_xml := l_xml||'<t36>'||' '||'</t36>'||EOL;  --ins_period_start_day_lp2
      l_xml := l_xml||'<t37>'||' '||'</t37>'||EOL;  --ins_period_lp2
      l_xml := l_xml||'<t38>'||' '||'</t38>'||EOL;  --contractor_name_lp2
      l_xml := l_xml||'<t39>'||' '||'</t39>'||EOL;  --beneficiary_name_lp2
      l_xml := l_xml||'<t40>'||' '||'</t40>'||EOL;  --beneficiary_relship_lp2
      l_xml := l_xml||'<t41>'||' '||'</t41>'||EOL;  --annual_prem_lp2
    --
    END IF;
  --
    -- Writing l_xml to vXMLTable.
    vXMLTable(vCtr).xmlstring := l_xml;
    vCtr := vCtr + 1;
  --
    IF (ins_company_name_nl.count >= d) THEN
    --
      if isdf_employer_c.effective_date < c_st_upd_date_2007 then
      --
        l_t48  := cnv_str(maturity_repayment_nl(d),1,3);
      --
      else
      --
        if nonlife_ins_term_type_nl(d) = 'EQ' then
        --
          l_t48a := g_msg_circle;
        --
        elsif nonlife_ins_term_type_nl(d) = 'L' then
        --
          l_t48b := g_msg_circle;
        --
        end if;
      --
      end if;
    --
      l_xml :=        '<t42>' ||htmlspchar(cnv_str(ins_company_name_nl(d)))   ||'</t42>' ||EOL;  --ins_company_name_nl1
      l_xml := l_xml||'<t43>' ||htmlspchar(cnv_str(ins_type_nl(d)))           ||'</t43>' ||EOL;  --ins_type_nl1
      l_xml := l_xml||'<t44>' ||htmlspchar(cnv_str(ins_period_nl(d)))         ||'</t44>' ||EOL;  --ins_period_nl1
      l_xml := l_xml||'<t45>' ||htmlspchar(cnv_str(contractor_name_nl(d)))    ||'</t45>' ||EOL;  --contractor_name_nl1
      l_xml := l_xml||'<t46>' ||htmlspchar(cnv_str(beneficiary_name_nl(d)))   ||'</t46>' ||EOL;  --beneficiary_name_nl1
      l_xml := l_xml||'<t47>' ||htmlspchar(cnv_str(beneficiary_relship_nl(d)))||'</t47>' ||EOL;  --beneficiary_relship_nl1
      l_xml := l_xml||'<t48>' ||htmlspchar(l_t48)                             ||'</t48>' ||EOL;  --maturity_repayment_nl1
      l_xml := l_xml||'<t48a>'||l_t48a                                        ||'</t48a>'||EOL;  --nonlife_ins_term_type_nl1
      l_xml := l_xml||'<t48b>'||l_t48b                                        ||'</t48b>'||EOL;  --nonlife_ins_term_type_nl1
      l_xml := l_xml||'<t49>' ||htmlspchar(to_char(to_number(annual_prem_nl(d)), fnd_currency.get_format_mask('JPY',40)))||'</t49>' ||EOL;  --annual_prem_nl1
    --
    ELSE
    --
      l_xml :=        '<t42>' ||' '||'</t42>' ||EOL;  --ins_company_name_nl1
      l_xml := l_xml||'<t43>' ||' '||'</t43>' ||EOL;  --ins_type_nl1
      l_xml := l_xml||'<t44>' ||' '||'</t44>' ||EOL;  --ins_period_nl1
      l_xml := l_xml||'<t45>' ||' '||'</t45>' ||EOL;  --contractor_name_nl1
      l_xml := l_xml||'<t46>' ||' '||'</t46>' ||EOL;  --beneficiary_name_nl1
      l_xml := l_xml||'<t47>' ||' '||'</t47>' ||EOL;  --beneficiary_relship_nl1
      l_xml := l_xml||'<t48>' ||' '||'</t48>' ||EOL;  --maturity_repayment_nl1
      l_xml := l_xml||'<t48a>'||' '||'</t48a>'||EOL;  --nonlife_ins_term_type_nl1
      l_xml := l_xml||'<t48b>'||' '||'</t48b>'||EOL;  --nonlife_ins_term_type_nl1
      l_xml := l_xml||'<t49>' ||' '||'</t49>' ||EOL;  --annual_prem_nl1
    --
    END IF;
  --
    IF (ins_company_name_nl.count >= e) THEN
    --
      if isdf_employer_c.effective_date < c_st_upd_date_2007 then
      --
        l_t56  := cnv_str(maturity_repayment_nl(e));
      --
      else
      --
        if nonlife_ins_term_type_nl(e) = 'EQ' then
        --
          l_t56a := g_msg_circle;
        --
        elsif nonlife_ins_term_type_nl(e) = 'L' then
        --
          l_t56b := g_msg_circle;
        --
        end if;
      --
      end if;
    --
      l_xml := l_xml||'<t50>' ||htmlspchar(cnv_str(ins_company_name_nl(e)))   ||'</t50>' ||EOL; --ins_company_name_nl2
      l_xml := l_xml||'<t51>' ||htmlspchar(cnv_str(ins_type_nl(e)))           ||'</t51>' ||EOL; --ins_type_nl2
      l_xml := l_xml||'<t52>' ||htmlspchar(cnv_str(ins_period_nl(e)))         ||'</t52>' ||EOL; --ins_period_nl2
      l_xml := l_xml||'<t53>' ||htmlspchar(cnv_str(contractor_name_nl(e)))    ||'</t53>' ||EOL; --contractor_name_nl2
      l_xml := l_xml||'<t54>' ||htmlspchar(cnv_str(beneficiary_name_nl(e)))   ||'</t54>' ||EOL; --beneficiary_name_nl2
      l_xml := l_xml||'<t55>' ||htmlspchar(cnv_str(beneficiary_relship_nl(e)))||'</t55>' ||EOL; --beneficiary_relship_nl2
      l_xml := l_xml||'<t56>' ||htmlspchar(l_t56)                             ||'</t56>' ||EOL; --maturity_repayment_nl2
      l_xml := l_xml||'<t56a>'||l_t56a                                        ||'</t56a>'||EOL; --nonlife_ins_term_type_nl2
      l_xml := l_xml||'<t56b>'||l_t56b                                        ||'</t56b>'||EOL; --nonlife_ins_term_type_nl2
      l_xml := l_xml||'<t57>' ||htmlspchar(to_char(to_number(annual_prem_nl(e)),fnd_currency.get_format_mask('JPY',40)))||'</t57>' ||EOL; --annual_prem_nl2
    --
    ELSE
    --
      l_xml := l_xml||'<t50>' ||' '||'</t50>' ||EOL; --ins_company_name_nl2
      l_xml := l_xml||'<t51>' ||' '||'</t51>' ||EOL; --ins_type_nl2
      l_xml := l_xml||'<t52>' ||' '||'</t52>' ||EOL; --ins_period_nl2
      l_xml := l_xml||'<t53>' ||' '||'</t53>' ||EOL; --contractor_name_nl2
      l_xml := l_xml||'<t54>' ||' '||'</t54>' ||EOL; --beneficiary_name_nl2
      l_xml := l_xml||'<t55>' ||' '||'</t55>' ||EOL; --beneficiary_relship_nl2
      l_xml := l_xml||'<t56>' ||' '||'</t56>' ||EOL; --maturity_repayment_nl2
      l_xml := l_xml||'<t56a>'||' '||'</t56a>'||EOL; --nonlife_ins_term_type_nl2
      l_xml := l_xml||'<t56b>'||' '||'</t56b>'||EOL; --nonlife_ins_term_type_nl2
      l_xml := l_xml||'<t57>' ||' '||'</t57>' ||EOL; --annual_prem_nl2
    --
    END IF;
  --
    IF (ins_type_s.count >= a) THEN
    --
      l_xml := l_xml||'<t58>'||htmlspchar(cnv_str(ins_type_s(a)))           ||'</t58>'||EOL; --ins_type_s1
      l_xml := l_xml||'<t59>'||htmlspchar(cnv_str(ins_payee_name_s(a)))     ||'</t59>'||EOL; --ins_payee_name_s1
      l_xml := l_xml||'<t60>'||htmlspchar(cnv_str(debtor_name_s(a)))        ||'</t60>'||EOL; --debtor_name_s1
      l_xml := l_xml||'<t61>'||htmlspchar(cnv_str(beneficiary_relship_s(a)))||'</t61>'||EOL; --beneficiary_relship_s1
      l_xml := l_xml||'<t62>'||to_char(to_number(annual_prem_s(a)),fnd_currency.get_format_mask('JPY',40))||'</t62>'||EOL; --annual_prem_s1
    --
    ELSE
    --
      l_xml := l_xml||'<t58>'||' '||'</t58>'||EOL; --ins_type_s1
      l_xml := l_xml||'<t59>'||' '||'</t59>'||EOL; --ins_payee_name_s1
      l_xml := l_xml||'<t60>'||' '||'</t60>'||EOL; --debtor_name_s1
      l_xml := l_xml||'<t61>'||' '||'</t61>'||EOL; --beneficiary_relship_s1
      l_xml := l_xml||'<t62>'||' '||'</t62>'||EOL; --annual_prem_s1
    --
    END IF;
  --
    IF (ins_type_s.count >= b) THEN
    --
      l_xml := l_xml||'<t63>'||htmlspchar(cnv_str(ins_type_s(b)))           ||'</t63>'||EOL; --ins_type_s2
      l_xml := l_xml||'<t64>'||htmlspchar(cnv_str(ins_payee_name_s(b)))     ||'</t64>'||EOL; --ins_payee_name_s2
      l_xml := l_xml||'<t65>'||htmlspchar(cnv_str(debtor_name_s(b)))        ||'</t65>'||EOL; --debtor_name_s2
      l_xml := l_xml||'<t66>'||htmlspchar(cnv_str(beneficiary_relship_s(b)))||'</t66>'||EOL; --beneficiary_relship_s2
      l_xml := l_xml||'<t67>'||to_char(to_number(annual_prem_s(b)),fnd_currency.get_format_mask('JPY',40))||'</t67>'||EOL; --annual_prem_s2
    --
    ELSE
    --
      l_xml := l_xml||'<t63>'||' '||'</t63>'||EOL; --ins_type_s2
      l_xml := l_xml||'<t64>'||' '||'</t64>'||EOL; --ins_payee_name_s2
      l_xml := l_xml||'<t65>'||' '||'</t65>'||EOL; --debtor_name_s2
      l_xml := l_xml||'<t66>'||' '||'</t66>'||EOL; --beneficiary_relship_s2
      l_xml := l_xml||'<t67>'||' '||'</t67>'||EOL; --annual_prem_s2
    --
    END IF;
  --
    IF (ins_type_s.count >= c) THEN
    --
      l_xml := l_xml||'<t68>'||htmlspchar(cnv_str(ins_type_s(c)))           ||'</t68>'||EOL; --ins_type_s3
      l_xml := l_xml||'<t69>'||htmlspchar(cnv_str(ins_payee_name_s(c)))     ||'</t69>'||EOL; --ins_payee_name_s3
      l_xml := l_xml||'<t70>'||htmlspchar(cnv_str(debtor_name_s(c)))        ||'</t70>'||EOL; --debtor_name_s3
      l_xml := l_xml||'<t71>'||htmlspchar(cnv_str(beneficiary_relship_s(c)))||'</t71>'||EOL; --beneficiary_relship_s3
      l_xml := l_xml||'<t72>'||to_char(to_number(annual_prem_s(c)),fnd_currency.get_format_mask('JPY',40))||'</t72>'||EOL; --annual_prem_s3
    --
    ELSE
    --
      l_xml := l_xml||'<t68>'||' '||'</t68>'||EOL; --ins_type_s3
      l_xml := l_xml||'<t69>'||' '||'</t69>'||EOL; --ins_payee_name_s3
      l_xml := l_xml||'<t70>'||' '||'</t70>'||EOL; --debtor_name_s3
      l_xml := l_xml||'<t71>'||' '||'</t71>'||EOL; --beneficiary_relship_s3
      l_xml := l_xml||'<t72>'||' '||'</t72>'||EOL; --annual_prem_s3
    --
    END IF;
  --
    l_xml := l_xml||'</page>'||EOL;
  --
    vXMLTable(vCtr).xmlstring := l_xml;
    vCtr := vCtr + 1;
  --
    i := i + 1;
  --
  END LOOP;
--
  -- Code to generate XML for second page of template starts
  -- dummy field is added to get as many prints of second page as
  -- the number of employees for whom the report is run.
  l_xml2 := '</isdf1>'||EOL||
            '<isdf2>' ||EOL||
            '<dummy></dummy>'||EOL||  -- This is dummy field
            '</isdf2>'||EOL||'</isdf>'||EOL ;
--
  vXMLTable(vCtr).xmlstring := l_xml2;
  vCtr := vCtr + 1;
--
END assact_xml;
--
/****************************************************************************
  Name        : WritetoCLOB
  Arguments   : returns XML
  Description : This procedure selects the xml from vXMLTable and writes it
                into a clob variable. This clob variable is then returned.
*****************************************************************************/
PROCEDURE WritetoCLOB (p_write_xml OUT NOCOPY CLOB)
IS
  l_xfdf_string       CLOB;
  ctr_table           NUMBER;
  tempclob            clob;
BEGIN
  dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
  dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
  FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST
  LOOP
    dbms_lob.writeAppend(l_xfdf_string,
                        length(vXMLTable(ctr_table).xmlstring),
                        vXMLTable(ctr_table).xmlstring );
  END LOOP;
  p_write_xml := l_xfdf_string;
  hr_utility.set_location('Out of loop ', 99);
  dbms_lob.close(l_xfdf_string);
EXCEPTION
WHEN OTHERS THEN
  HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
  HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;
--
/****************************************************************************
  Name        : get_cp_xml
  Arguments   : p_assignment_action_id
                p_xml
  Description : This procedure creates and returns the xml for the
                assignment_action_id passed as parameter.
*****************************************************************************/
PROCEDURE get_cp_xml(p_assignment_action_id    IN  NUMBER,
                     p_xml                     OUT NOCOPY CLOB) IS
BEGIN
  assact_xml(p_assignment_action_id);
  WritetoCLOB (p_xml);
END get_cp_xml;
--
/****************************************************************************
  Name        : get_ss_xml
  Arguments   : p_assignment_action_id
                p_xml
  Description : This procedure creates and returns the xml for the
                assignment_action_id passed as parameter. This is called
                for single report from Self-Service page.
*****************************************************************************/
PROCEDURE get_ss_xml(p_assignment_action_id    IN  NUMBER,
                     p_xml                     OUT NOCOPY CLOB) IS
 p_ss_xml  CLOB;
 l_header  CHAR(200);
 l_footer  VARCHAR2(50);
 l_xml     CLOB;
BEGIN
  l_header := '<?xml version="1.0" encoding="UTF-8"?>' || EOL ||'<ROOT>';
  l_footer := '</ROOT>';
  assact_xml(p_assignment_action_id);
  WritetoCLOB(p_ss_xml);
  dbms_lob.createtemporary(l_xml,TRUE) ;
  dbms_lob.writeAppend(l_xml,
                       length(l_header),
                       l_header);
  dbms_lob.append(l_xml, p_ss_xml);
  dbms_lob.writeAppend(l_xml,
                       length(l_footer),
                       l_footer);
  p_xml := l_xml ;
END get_ss_xml;
--
/****************************************************************************
  Name        : generate_xml
  Description : This procedure fetches archived data, converts it to XML
                format and appends to pay_mag_tape.g_clob_value.
*****************************************************************************/
PROCEDURE generate_xml AS
  l_old_assact_id            NUMBER;
  l_final_xml_string         CLOB;
  xml_string1                VARCHAR2(2000);
  l_pact_id                  NUMBER;
  l_cur_pact                 NUMBER;
  l_legislative_parameters   VARCHAR(2000);
  l_cur_assact               NUMBER ;
  l_proc_name                VARCHAR2(60) ;
  l_offset                   NUMBER;
  l_amount                   NUMBER;
--
BEGIN
--
  IF g_debug  THEN
    l_proc_name := g_proc_name || 'GENERATE_XML';
    hr_utility.trace ('Entering '||l_proc_name);
  END IF ;
--
  l_cur_assact := pay_magtape_generic.get_parameter_value  ('TRANSFER_ACT_ID' );
  l_cur_pact := pay_magtape_generic.get_parameter_value  ('TRANSFER_PAYROLL_ACTION_ID' );
--
  SELECT legislative_parameters
  INTO   l_legislative_parameters
  FROM   pay_payroll_actions
  WHERE  payroll_action_id = l_cur_pact;
--
  l_pact_id :=  fnd_number.canonical_to_number(pay_core_utils.get_parameter('PAYROLL_ACTION_ID',l_legislative_parameters));
  l_emp_no_opt := pay_core_utils.get_parameter('PRN_EMP_NO',l_legislative_parameters);
--
  SELECT paa1.assignment_action_id
  INTO   l_old_assact_id
  FROM   pay_assignment_actions paa,
         pay_assignment_actions paa1
  WHERE  paa.assignment_action_id = l_cur_assact
  AND    paa.assignment_id = paa1.assignment_id
  AND    paa1.payroll_action_id = l_pact_id;
--
  get_cp_xml(l_old_assact_id, l_final_xml_string);
--
  l_offset := 1 ;
  l_amount := 500;
--
 LOOP
   xml_string1 := null;
   dbms_lob.read(l_final_xml_string,l_amount,l_offset,xml_string1);
   pay_core_files.write_to_magtape_lob(xml_string1);
   l_offset := l_offset + l_amount ;
 END LOOP;
EXCEPTION
WHEN no_data_found THEN
  hr_utility.trace ('exiting from loop');
--
  IF g_debug  THEN
    hr_utility.trace ('Leaving '||l_proc_name);
  END IF ;
END generate_xml;
--
/****************************************************************************
  Name        : gen_xml_header
  Description : This procedure generates XML header information and appends to
                pay_mag_tape.g_clob_value.
*****************************************************************************/
PROCEDURE gen_xml_header AS
  l_proc_name varchar2(100);
  l_buf      varchar2(2000);
--
BEGIN
  if g_debug then
    l_proc_name := g_proc_name || 'GEN_XML_HEADER';
    hr_utility.trace ('Entering '||l_proc_name);
  end if ;
--
  vXMLTable.DELETE; -- delete the pl/sql table
--
--  l_buf := '<?xml version="1.0" encoding="UTF-8"?>'||EOL ;
  l_buf := EOL ||'<ROOT>'||EOL ;
--
  pay_core_files.write_to_magtape_lob(l_buf);
--
  if g_debug then
    hr_utility.trace ('CLOB contents after appending header information');
    hr_utility.trace ('Leaving '||l_proc_name);
  end if ;
END gen_xml_header;
--
/****************************************************************************
  Name         : gen_xml_footer
  Desc         : Footer
*****************************************************************************/
PROCEDURE gen_xml_footer AS
  l_buf  varchar2(2000) ;
  l_proc_name varchar2(100);
BEGIN
--
  if g_debug  then
    l_proc_name := g_proc_name || 'GEN_XML_FOOTER';
    hr_utility.trace ('Entering '||l_proc_name);
  end if ;
  l_buf := '</ROOT>' ;
--
   pay_core_files.write_to_magtape_lob(l_buf);
--
   if g_debug then
     hr_utility.trace ('CLOB contents after appending footer information');
     hr_utility.trace ('Leaving '||l_proc_name);
   end if ;
--
END gen_xml_footer;
--
/****************************************************************************
  Function Name : submit_report
    Arguments   :
    Description :
*****************************************************************************/
function submit_report(p_pact_id    IN  NUMBER,
                       p_assset_id  IN  NUMBER,
                       p_eff_date   IN  VARCHAR2) return number
is
    l_request_id          number;
    l_phase               VARCHAR2(100);
    l_status              VARCHAR2(100);
    l_dev_status          VARCHAR2(100);
    l_dev_phase           VARCHAR2(100);
    l_message             VARCHAR2(2000);
    l_action_completed    BOOLEAN;
    l_req_id              NUMBER;
--
begin
-- Submit the request
--
  l_request_id := fnd_request.submit_request( Application => 'PAY',
                                              Program     => 'PAYJPXML',
                                              Description => 'JP Life Insurance Notification Report',
                                              argument1   => 'ARCHIVE',
                                              argument2   => 'XML',
                                              argument3   => 'JP',
                                              argument4   => NULL,
                                              argument5   => p_eff_date,
                                              argument6   => 'XML',
                                              argument7   => fnd_profile.value('PER_BUSINESS_GROUP_ID'),
                                              argument8   => NULL,
                                              argument9   => NULL,
                                              argument10  => p_pact_id,
                                              argument11  => 'PAYROLL_ACTION_ID='||p_pact_id,
                                              argument12  => p_assset_id,
                                              argument13  => 'ASSIGNMENT_SET_ID='||p_assset_id);
--
  -- Check the status
  if l_request_id <> 0 then
    -- Save the request and wait for completion
    Commit;
    l_dev_phase := 'ZZZ';
    WHILE (l_dev_phase <> 'COMPLETE')
    LOOP
       l_action_completed := FND_CONCURRENT.WAIT_FOR_REQUEST(
                                         request_id  =>      l_request_id
                                        ,interval    =>      1
                                        ,max_wait    =>      10
                                        ,phase       =>      l_phase
                                        ,status      =>      l_status
                                        ,dev_phase   =>      l_dev_phase
                                        ,dev_status  =>      l_dev_status
                                        ,message     =>      l_message);
    END LOOP;
  end if;
return l_request_id;
end submit_report;
--
END pay_jp_isdf_rpt;

/
