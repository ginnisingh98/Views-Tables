--------------------------------------------------------
--  DDL for Package Body PAY_IE_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_SOE" AS
/* $Header: pyiesoer.pkb 120.1 2005/12/27 02:25:12 sgajula noship $ */
g_package  CONSTANT varchar2(33) := ' PAY_IE_SOE.';
l_sql long;
g_debug  CONSTANT boolean := hr_utility.debug_enabled;
function setParameters(p_person_id in number, p_assignment_id in number, p_effective_date date) return varchar2 is
p_payroll_exists            varchar2(10);
a_assignment_id             number;
p_assignment_action_id      number;
p_run_assignment_action_id  number;
p_paye_prsi_action_id       number;
p_payroll_action_id         number;
p_date_earned               varchar2(20);
CURSOR c_assignment IS
SELECT asg.assignment_id
FROM   per_all_assignments_f asg
WHERE  asg.person_id=p_person_id
AND    p_effective_date between asg.effective_start_date and asg.effective_end_date;

CURSOR c_action_id(a_asg_id number) IS
select to_number(substr(max(to_char(pa.effective_date,'J')||lpad(aa.assignment_action_id,15,'0')),8))
            from  pay_payroll_actions pa,
                  pay_assignment_actions aa
            where pa.action_type in ('U','P','Q','R')
            and   aa.action_status = 'C'
            and   pa.payroll_action_id = aa.payroll_action_id
            and   aa.assignment_id = a_asg_id
            and   pa.effective_date <= p_effective_date;



begin
  --
  if g_debug then
     hr_utility.set_location('Entering pay_soe_glb.setParameters', 10);
  end if;
  --
  -- NOTE:
  -- This overridden version of setParameters is not yet fully implemented
  -- at GLB level.
  --
  a_assignment_id := p_assignment_id;
  if p_assignment_id is null then
    open c_assignment;
    fetch c_assignment into a_assignment_id;
    close c_assignment;
  end if;

  open c_action_id(a_assignment_id);
  fetch c_action_id into p_assignment_action_id;
  close c_action_id;


  if g_debug then
     hr_utility.set_location('Leaving pay_soe_glb.setParameters', 20);
  end if;
  return setParameters(p_assignment_action_id);
end;
--
function setParameters(p_assignment_action_id number) return varchar2 is
begin
   return  PAY_SOE_GLB.setParameters(p_assignment_action_id) ;  -- l_parameters;
end;
function Employee(p_assignment_action_id number) return long is
begin
l_sql:=
'Select org.name COL01
        ,job.name COL02
        ,loc.location_code COL03
        ,grd.name COL04
        ,pay.payroll_name COL05
        ,pos.name COL06
        ,peo.national_identifier COL07
        ,pg.group_name COL08
        ,asg.assignment_number COL09
        ,peo.full_name    COL10 --Removed Title for 4303921
  from   per_all_people_f             peo
        ,per_all_assignments_f        asg
        ,hr_all_organization_units_vl org
        ,per_jobs_vl                  job
        ,per_all_positions            pos
        ,hr_locations                 loc
        ,per_grades_vl                grd
        ,pay_payrolls_f               pay
        ,pay_people_groups            pg
  where  asg.assignment_id   = :assignment_id
    and  :effective_date between asg.effective_start_date and asg.effective_end_date
    and  asg.person_id       = peo.person_id
    and  :effective_date between peo.effective_start_date and peo.effective_end_date
    and  asg.position_id     = pos.position_id(+)
    and  asg.job_id          = job.job_id(+)
    and  asg.location_id     = loc.location_id(+)
    and  asg.grade_id        = grd.grade_id(+)
    and  asg.people_group_id = pg.people_group_id(+)
    and  asg.payroll_id      = pay.payroll_id(+)
    and  :effective_date between pay.effective_start_date(+) and pay.effective_end_date(+)
    and  asg.organization_id = org.organization_id
    and  :effective_date between org.date_from and nvl(org.date_to, :effective_date)';
return l_sql;
end  Employee;
function PAYE_Info(p_assignment_action_id NUMBER) return long is
begin
l_sql:=
'select  PSPD.D_INFO_SOURCE COL01
        ,fnd_date.canonical_to_date(PSPD.CERTIFICATE_ISSUE_DATE) COL02
        ,PSPD.D_TAX_BASIS COL03
        ,PSPD.D_TAX_ASSESS_BASIS COL04
        ,PTM.PERIOD_NUM COL16
        ,Decode(PTPR.BASIC_PERIOD_TYPE,''CM'',PSPD.MONTHLY_STD_RATE_CUT_OFF*PTPR.NUMBER_PER_FISCAL_YEAR/12,''W'',PSPD.WEEKLY_STD_RATE_CUT_OFF*PTPR.NUMBER_PER_FISCAL_YEAR/52) COL17
        ,Decode(PTPR.BASIC_PERIOD_TYPE,''CM'',PSPD.MONTHLY_TAX_CREDIT*PTPR.NUMBER_PER_FISCAL_YEAR/12,''W'',PSPD.WEEKLY_TAX_CREDIT*PTPR.NUMBER_PER_FISCAL_YEAR/52) COL18
 from  PAY_IE_SOE_PAYE_DETAILS_V  PSPD
     ,PAY_PAYROLL_ACTIONS        PPA
     ,PAY_ASSIGNMENT_ACTIONS     PAAS
     ,PER_TIME_PERIODS           PTM
     ,PER_TIME_PERIOD_TYPES      PTPT
     ,PAY_ALL_PAYROLLS_F         pap
     ,per_time_period_rules       PTPR
where PSPD.assignment_action_id :action_clause
  and PSPD.assignment_action_id=PAAS.ASSIGNMENT_ACTION_ID
  and PAAS.PAYROLL_ACTION_ID=PPA.PAYROLL_ACTION_ID
  and PAP.PAYROLL_ID = PTM.PAYROLL_ID
  and PPA.DATE_EARNED BETWEEN PTM.START_DATE AND PTM.END_DATE -- 4906850
  and PPA.PAYROLL_ID=PAP.PAYROLL_ID
  AND PAP.PERIOD_TYPE=PTPT.PERIOD_TYPE
  AND PTPT.NUMBER_PER_FISCAL_YEAR=PTPR.NUMBER_PER_FISCAL_YEAR';
return l_sql;
end PAYE_Info;
function PRSI_Info(p_assignment_action_id NUMBER) return long is
begin
l_sql:=
'select   PSPD.CONTRIBUTION_CLASS COL01
        , OVERRIDDEN_SUBCLASS COL02
        from PAY_IE_SOE_PRSI_DETAILS_V PSPD
        where PSPD.assignment_action_id :action_clause';
return l_sql;
end PRSI_Info;
--
function Elements1(p_assignment_action_id number, P_ELEMENT_SET_NAME varchar2) return long is
begin
l_sql:=
'SELECT
        NVL(PET.REPORTING_NAME, PET.ELEMENT_TYPE_ID) COL01
       , NVL(PET.REPORTING_NAME, PET.ELEMENT_NAME) COL02
       ,to_char(decode(NVL(PET.REPORTING_NAME,PET.ELEMENT_NAME),''BIK Arrearage'',
                                                 SUM(FND_NUMBER.CANONICAL_TO_NUMBER(PRV.RESULT_VALUE*(-1))) ,
						 SUM(FND_NUMBER.CANONICAL_TO_NUMBER(PRV.RESULT_VALUE))),fnd_currency.get_format_mask(:G_CURRENCY_CODE,40)) COL16
       , decode(count(*),1,''1'',''2'') COL17 -- destination indicator
       , decode(count(*),1,max(prr.run_result_id),max(pet.element_type_id)) COL18
FROM PAY_ELEMENT_TYPES_F PET
    ,PAY_ELEMENT_TYPES_F_TL PETTL
    ,PAY_ELEMENT_CLASSIFICATIONS PEC
    ,PAY_ELEMENT_CLASSIFICATIONS_TL PECTL
    ,PAY_INPUT_VALUES_F PIV
    ,PAY_RUN_RESULT_VALUES PRV
    ,PAY_RUN_RESULTS PRR
    ,PAY_ASSIGNMENT_ACTIONS PAA
    ,PAY_ELEMENT_SET_MEMBERS PESM
    ,PAY_ELEMENT_SETS PES
WHERE PAA.ASSIGNMENT_ACTION_ID :action_clause
  AND PEC.LEGISLATION_CODE = ''IE''
  AND PEC.BUSINESS_GROUP_ID IS NULL
  AND PEC.Classification_id = PECTL.classification_id
  AND PECTL.LANGUAGE = userenv(''LANG'')
  AND PET.element_type_id = PETTL.element_type_id
  AND PETTL.LANGUAGE = userenv(''LANG'')
  AND PRR.ELEMENT_TYPE_ID = PET.ELEMENT_TYPE_ID
  AND PAA.ASSIGNMENT_ACTION_ID = PRR.ASSIGNMENT_ACTION_ID
  AND PRR.STATUS IN (''P'',''PA'')
  AND PET.CLASSIFICATION_ID = PEC.CLASSIFICATION_ID
  AND PIV.ELEMENT_TYPE_ID = PET.ELEMENT_TYPE_ID
  AND PRV.INPUT_VALUE_ID = PIV.INPUT_VALUE_ID
  AND PRV.RUN_RESULT_ID = PRR.RUN_RESULT_ID
  AND ((PIV.NAME =''Pay Value'' AND PIV.UOM = ''M'')
    OR (PET.ELEMENT_NAME IN (''IE BIK Arrearage Details'',''IE BIK Arrearage Recovery Details'')
        AND PET.LEGISLATION_CODE= ''IE'' AND PET.BUSINESS_GROUP_ID is NULL
        AND PIV.NAME in (''BIK Arrearage'',''BIK Arrearage Recovered''))
    OR (PET.ELEMENT_NAME IN (''IE PAYE at higher rate'',''IE PAYE at standard rate'')
        AND PET.LEGISLATION_CODE= ''IE'' AND PET.BUSINESS_GROUP_ID is NULL AND PIV.NAME =''Value'' ))
  AND PET.ELEMENT_NAME NOT IN (''IE PRSI'',''IE Net tax'')
  AND EXISTS (SELECT 1 FROM DUAL WHERE
((fnd_number.canonical_to_number(PRV.RESULT_VALUE) >0
   AND PET.ELEMENT_NAME IN (''IE PRSI K Employee Lump Sum'',''IE PRSI M Employee Lump Sum'' ))
   OR (PET.ELEMENT_NAME NOT IN (''IE PRSI K Employee Lump Sum'',''IE PRSI M Employee Lump Sum''))))
  AND :effective_date BETWEEN PIV.EFFECTIVE_START_DATE AND PIV.EFFECTIVE_END_DATE
  AND :effective_date BETWEEN PET.EFFECTIVE_START_DATE AND PET.EFFECTIVE_END_DATE
  AND PET.ELEMENT_TYPE_ID = PESM.ELEMENT_TYPE_ID
  AND PESM.ELEMENT_SET_ID = PES.ELEMENT_SET_ID
  AND ( PES.BUSINESS_GROUP_ID IS NULL
     OR PES.BUSINESS_GROUP_ID = :business_group_id )
  AND ( PES.LEGISLATION_CODE IS NULL
     OR PES.LEGISLATION_CODE = '':legislation_code'')
  AND PES.ELEMENT_SET_NAME = '''|| P_ELEMENT_SET_NAME || '''
  GROUP BY
        PRR.ASSIGNMENT_ACTION_ID
	  , NVL(PET.REPORTING_NAME, PET.ELEMENT_NAME)
	  , NVL(PET.REPORTING_NAME, PET.ELEMENT_TYPE_ID)';
return l_sql;
end Elements1;
function Elements4(p_assignment_action_id number) return long is
begin
 return  Elements1(p_assignment_action_id,pay_soe_util.getConfig('ELEMENTS2'));
end Elements4;
--
function set_cutoff_prompt(p_assignment_action_id NUMBER) return Varchar2 is
l_cutoff_prompt varchar2(50);
cursor get_cutoff is
select  Decode(PTPR.BASIC_PERIOD_TYPE,'CM','Monthly Cutoff','W','Weekly Cutoff')
from  PAY_PAYROLL_ACTIONS        PPA
     ,PAY_ASSIGNMENT_ACTIONS     PAAS
     ,PER_TIME_PERIODS           PTM
     ,PER_TIME_PERIOD_TYPES      PTPT
     ,PAY_ALL_PAYROLLS_F         pap
     ,per_time_period_rules       PTPR
where PAAS.ASSIGNMENT_ACTION_ID = p_assignment_action_id
  and PAAS.PAYROLL_ACTION_ID=PPA.PAYROLL_ACTION_ID
  and PAP.PAYROLL_ID = PTM.PAYROLL_ID
  and PPA.DATE_EARNED BETWEEN PTM.START_DATE AND PTM.END_DATE  -- 4906850
  and PPA.PAYROLL_ID=PAP.PAYROLL_ID
  AND PAP.PERIOD_TYPE=PTPT.PERIOD_TYPE
  AND PTPT.NUMBER_PER_FISCAL_YEAR=PTPR.NUMBER_PER_FISCAL_YEAR;
begin
open get_cutoff;
fetch get_cutoff into l_cutoff_prompt;
close get_cutoff;
return l_cutoff_prompt;
end set_cutoff_prompt;
function set_credit_prompt(p_assignment_action_id NUMBER) return Varchar2 is
l_credit_prompt varchar2(50);
cursor get_credit is
select  Decode(PTPR.BASIC_PERIOD_TYPE,'CM','Monthly Credit','W','Weekly Credit')
from  PAY_PAYROLL_ACTIONS        PPA
     ,PAY_ASSIGNMENT_ACTIONS     PAAS
     ,PER_TIME_PERIODS           PTM
     ,PER_TIME_PERIOD_TYPES      PTPT
     ,PAY_ALL_PAYROLLS_F         pap
     ,per_time_period_rules       PTPR
where Paas.assignment_action_id = p_assignment_action_id
  and PAAS.PAYROLL_ACTION_ID=PPA.PAYROLL_ACTION_ID
 and PAP.PAYROLL_ID = PTM.PAYROLL_ID
  and PPA.DATE_EARNED BETWEEN PTM.START_DATE AND PTM.END_DATE  -- 4906850
  and PPA.PAYROLL_ID=PAP.PAYROLL_ID
  AND PAP.PERIOD_TYPE=PTPT.PERIOD_TYPE
  AND PTPT.NUMBER_PER_FISCAL_YEAR=PTPR.NUMBER_PER_FISCAL_YEAR;
begin
open get_credit;
fetch get_credit into l_credit_prompt;
close get_credit;
return l_credit_prompt;
end set_credit_prompt;

function Tax_PRSI_Info(p_assignment_action_id NUMBER) return long is

Cursor c_pay_run(a_asg_action_id number) is
select aa.assignment_action_id from pay_assignment_actions aa,pay_action_interlocks pai
where locking_action_id=a_asg_action_id
and aa.assignment_action_id=locked_action_id
and aa.source_action_id is not null
and   aa.action_status = 'C';

Cursor c_PRSI(a_asg_action_id number) is
select   PSPD.CONTRIBUTION_CLASS con
        , OVERRIDDEN_SUBCLASS ovr
        from PAY_IE_SOE_PRSI_DETAILS_V PSPD
        where PSPD.assignment_action_id=a_asg_action_id;

/* Added for bug 4287903 */
/* Added number_per_fiscal_year for 4354386*/
      CURSOR c_period_num_and_type (a_asg_action_id NUMBER)
      IS
         SELECT ptm.period_num, ptpr.basic_period_type, ptpr.number_per_fiscal_year
           FROM pay_payroll_actions ppa,
                pay_assignment_actions paas,
                per_time_periods ptm,
                per_time_period_types ptpt,
                pay_all_payrolls_f pap,
                per_time_period_rules ptpr
          WHERE paas.assignment_action_id = a_asg_action_id
            AND paas.payroll_action_id = ppa.payroll_action_id
            AND pap.payroll_id = ptm.payroll_id
            AND ppa.date_earned BETWEEN ptm.start_date AND ptm.end_date  -- 4906850
            AND ppa.payroll_id = pap.payroll_id
            AND pap.period_type = ptpt.period_type
            AND ptpt.number_per_fiscal_year = ptpr.number_per_fiscal_year;


v_contribution_class varchar2(60);
v_overridden_class varchar2(60);
v_period_num             per_time_periods.period_num%TYPE;
v_basic_period_type      per_time_period_rules.basic_period_type%TYPE;
v_number_per_fiscal_year per_time_period_rules.number_per_fiscal_year%TYPE;

a_assignment_action_id number;

begin
a_assignment_action_id:=p_assignment_action_id;
Open c_pay_run(a_assignment_action_id);
fetch c_pay_run into a_assignment_action_id;
close c_pay_run;

Open c_PRSI(a_assignment_action_id);
fetch c_PRSI into v_contribution_class,v_overridden_class;
close c_PRSI;

OPEN c_period_num_and_type (a_assignment_action_id);
FETCH c_period_num_and_type INTO v_period_num, v_basic_period_type, v_number_per_fiscal_year;
CLOSE c_period_num_and_type ;

/*Changed for Bug 4287903 */
l_sql:=
'select  PSPD.D_INFO_SOURCE COL01
        ,fnd_date.canonical_to_date(PSPD.CERTIFICATE_ISSUE_DATE) COL02
        ,PSPD.D_TAX_BASIS COL03
        ,PSPD.D_TAX_ASSESS_BASIS COL04
        ,'|| v_period_num|| ' COL07
        ,Decode('''|| v_basic_period_type|| ''',''CM'',PSPD.MONTHLY_STD_RATE_CUT_OFF*' || v_number_per_fiscal_year || '/12,''W'',PSPD.WEEKLY_STD_RATE_CUT_OFF*' || v_number_per_fiscal_year || '/52) COL05
        ,Decode('''|| v_basic_period_type|| ''',''CM'',PSPD.MONTHLY_TAX_CREDIT*' || v_number_per_fiscal_year || '/12,''W'',PSPD.WEEKLY_TAX_CREDIT*' || v_number_per_fiscal_year || '/52) COL06
        ,''' ||v_contribution_class || ''' COL08
        ,''' ||v_overridden_class   || ''' COL09
 from  PAY_IE_SOE_PAYE_DETAILS_V  PSPD
where PSPD.assignment_action_id :action_clause';

return l_sql;
end Tax_PRSI_Info;

END PAY_IE_SOE;

/
