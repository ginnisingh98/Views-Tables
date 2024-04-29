--------------------------------------------------------
--  DDL for Package Body PQH_BDGT_ACTUAL_CMMTMNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BDGT_ACTUAL_CMMTMNT_PKG" as
/* $Header: pqbgtact.pkb 120.6 2007/01/05 16:08:47 krajarat noship $ */
--
-- Throughout this Package 0 is returned if in the validating functions
-- the validation is succesful. -1 means error;
--
--------------------------------------------------------------------------
--
g_package  varchar2(33) := 'pqh_bdgt_actual_cmmtmnt_pkg.';
--
--
function get_factor(     p_from_start_date   in    date,
                         p_from_end_date     in    date,
                         p_to_start_date     in    date,
                         p_to_end_date       in    date )
RETURN NUMBER
IS
begin
  If p_from_start_date = p_to_start_date AND p_from_end_date = p_to_end_date then
    RETURN 1;
  End if;

  Return ( (p_to_end_date   - p_to_start_date   + 1)  /
          (p_from_end_date - p_from_start_date + 1)  );
end;

FUNCTION get_last_payroll_dt (
         p_assignment_id  NUMBER,
         p_start_date     DATE,
         p_end_date       DATE ) RETURN Date IS

/*
Original Cursor, simply returns the last payroll run date
for the payroll id found associated with the assignment

cursor csr_last_dt is
Select NVL( max( tp.end_date), p_start_date )
From per_time_periods       tp,
     pay_payroll_actions    ppa,
     per_all_assignments_f  aaf
Where aaf.assignment_id = p_assignment_id
  and (aaf.effective_end_date >= p_start_date and aaf.effective_start_date <= p_end_date)
  and ppa.payroll_id    = aaf.payroll_id
  and (ppa.date_earned between tp.start_date and tp.end_date )
  AND tp.payroll_id     = aaf.payroll_id
  AND (tp.start_date   <= least(p_end_date,aaf.effective_end_date)
       and tp.end_date >= greatest(p_start_date,aaf.effective_start_date) )
  and tp.time_period_id = ppa.time_period_id;
*/

/*
   New Cursor uses the latest sequenced payroll action performed on the assignment
*/
   cursor csr_last_dt is
   Select NVL( tp.end_date, p_start_date )
     from pay_assignment_actions     paa,
          per_all_assignments_f      paf,
          pay_payroll_actions        ppa,
          pay_action_classifications pac,
          per_time_periods             tp
     where paf.assignment_id = p_assignment_id
     and (paf.effective_end_date >= p_start_date
           and paf.effective_start_date <= p_end_date)
     and paa.assignment_id = paf.assignment_id
     and ppa.payroll_action_id = paa.payroll_action_id
     and ppa.effective_date +0 between
                 greatest(p_start_date,paf.effective_start_date)
             and least(p_end_date,paf.effective_end_date)
     and pac.action_type = ppa.action_type
     and pac.classification_name = 'SEQUENCED'
     and ((nvl(paa.run_type_id, ppa.run_type_id) is null and
           paa.source_action_id is null)
       or (nvl(paa.run_type_id, ppa.run_type_id) is not null and
           paa.source_action_id is not null )
       or (ppa.action_type = 'V' and ppa.run_type_id is null and
           paa.run_type_id is not null and
           paa.source_action_id is null))
    and tp.time_period_id = ppa.time_period_id
    order by paa.action_sequence desc;

  l_last_date  date;

BEGIN
hr_utility.set_location('Payroll calculation, dates passed: '||p_start_date ||' - '||p_end_date||' > '||p_assignment_id, 71);
  OPEN  csr_last_dt;
  FETCH csr_last_dt INTO l_last_date;
  CLOSE csr_last_dt;

  return l_last_date;

END get_last_payroll_dt;

PROCEDURE Validate_budget(p_budget_version_id   in number,
                          p_budget_id          out nocopy number)
is
--
 Cursor csr_bdgt is
    Select bvr.budget_id
      From pqh_budget_versions  bvr
     Where bvr.budget_version_id = p_budget_version_id;
--
--
l_proc               varchar2(72) := g_package || 'Validate_budget';
--
Begin
 --
 hr_utility.set_location('Entering :'||l_proc,5);
 --
 -- VALIDATE IF THIS IS A VALID BUDGET IN PQH_BUDGETS
 --
 Open  csr_bdgt;
 Fetch  csr_bdgt into p_budget_id;
 If  csr_bdgt%notfound then
     --Raise exception
     --
     Close  csr_bdgt;
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_BUDGET_VERSION');
     APP_EXCEPTION.RAISE_EXCEPTION;
     --
 End if;
 --
 Close  csr_bdgt;
 --
 hr_utility.set_location('Leaving :'||l_proc,10);
EXCEPTION
   WHEN OTHERS THEN
      p_budget_id := null;
      hr_utility.set_location('Exception :'||l_proc,15);
      raise;
End;
------------------------------------------------------------------------------
PROCEDURE Validate_position(p_position_id       in number,
                            p_budget_version_id in number)
is
--
 Cursor csr_pos is
   Select null
     From hr_all_positions_f
    Where position_id = p_position_id;
--
--
-- The foll cursor checks if the passed position is present in the passed
-- budget version.
--
Cursor csr_positions_in_bdgt is
   Select null
     From pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bdt.position_id = p_position_id;
--
l_dummy         varchar2(1);
--
l_proc          varchar2(72) := g_package ||'Validate_position';
--
Begin
 --
 hr_utility.set_location('Entering :'||l_proc,5);
 --
 --
 -- validate if the position is in hr_all_positions_f
 --
 Open  csr_pos;
 Fetch  csr_pos into l_dummy;
 If  csr_pos%notfound then
     Close  csr_pos;
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_POSITION');
     APP_EXCEPTION.RAISE_EXCEPTION;
 End if;
 Close  csr_pos;
--
 -- Also check if the position belongs to the passed budget version
 -- and return the budget id of the budget version
 Open  csr_positions_in_bdgt;
 Fetch  csr_positions_in_bdgt into l_dummy;
 If  csr_positions_in_bdgt%notfound then
     Close  csr_positions_in_bdgt;
     FND_MESSAGE.SET_NAME('PQH','PQH_POSITION_NOT_IN_BDGT_VER');
     APP_EXCEPTION.RAISE_EXCEPTION;
 End if;
 --
 Close  csr_positions_in_bdgt;
 --
 hr_utility.set_location('Leaving :'||l_proc,10);
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('Exception :'||l_proc,15);
      raise;
End;
--------------------------------------------------------------------------
PROCEDURE Validate_job(p_job_id            in number,
                       p_budget_version_id in number)
is
--
 Cursor csr_job is
   Select null
     From per_jobs
    Where job_id = p_job_id;
--
-- The foll cursor checks if the passed job is present in the passed
-- budget version.
--
Cursor csr_jobs_in_bdgt is
   Select null
     From pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bdt.job_id = p_job_id;
--
l_dummy         varchar2(1);
--
l_proc          varchar2(72) := g_package ||'Validate_job';
--
Begin
 --
 hr_utility.set_location('Entering :'||l_proc,5);
 --
 --
 -- validate if the job is in per_jobs
 --
 Open  csr_job;
 Fetch  csr_job into l_dummy;
 If  csr_job%notfound then
     --Write into error log
     Close  csr_job;
     --
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_ENTITY_TYPE');
     FND_MESSAGE.SET_TOKEN('ENTITY',hr_general.decode_lookup('PQH_BUDGET_ENTITY','JOB'));
     APP_EXCEPTION.RAISE_EXCEPTION;
     --
 End if;
 --
 Close  csr_job;
 --
 -- Also check if the job belongs to the passed budget version
 -- and return the budget id of the budget version
 --
 Open  csr_jobs_in_bdgt;
 Fetch  csr_jobs_in_bdgt into l_dummy;
 If  csr_jobs_in_bdgt%notfound then
     Close  csr_jobs_in_bdgt;
     FND_MESSAGE.SET_NAME('PQH','PQH_ENT_TYPE_NOT_IN_BDGT_VER');
     FND_MESSAGE.SET_TOKEN('ENTITY',hr_general.decode_lookup('PQH_BUDGET_ENTITY','JOB'));
     APP_EXCEPTION.RAISE_EXCEPTION;
 End if;
 Close  csr_jobs_in_bdgt;
 hr_utility.set_location('Leaving :'||l_proc,10);
--
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('Exception :'||l_proc,15);
      raise;
End;
--------------------------------------------------------------------------
PROCEDURE Validate_grade(p_grade_id       in number,
                         p_budget_version_id in number)
is
--
 Cursor csr_grade is
   Select null
     From per_grades
    Where grade_id = p_grade_id;
--
-- The foll cursor checks if the passed grade is present in the passed
-- budget version.
--
Cursor csr_grades_in_bdgt is
   Select null
     From pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bdt.grade_id = p_grade_id;
--
l_dummy         varchar2(1);
--
l_proc          varchar2(72) := g_package ||'Validate_grade';
--
Begin
 --
 hr_utility.set_location('Entering :'||l_proc,5);
 --
 -- validate if the grade is in per_grades
 --
 Open  csr_grade;
 Fetch  csr_grade into l_dummy;
 If  csr_grade%notfound then
     --Write into error log
     Close  csr_grade;
     --
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_ENTITY_TYPE');
     FND_MESSAGE.SET_TOKEN('ENTITY',hr_general.decode_lookup('PQH_BUDGET_ENTITY','GRADE'));
     APP_EXCEPTION.RAISE_EXCEPTION;
     --
 End if;
 Close  csr_grade;
 -- Also check if the grade belongs to the passed budget version
 -- and return the budget id of the budget version
 --
 Open  csr_grades_in_bdgt;
 Fetch  csr_grades_in_bdgt into l_dummy;
 If  csr_grades_in_bdgt%notfound then
     Close  csr_grades_in_bdgt;
     FND_MESSAGE.SET_NAME('PQH','PQH_ENT_TYPE_NOT_IN_BDGT_VER');
     FND_MESSAGE.SET_TOKEN('ENTITY',hr_general.decode_lookup('PQH_BUDGET_ENTITY','GRADE'));
     APP_EXCEPTION.RAISE_EXCEPTION;
 End if;
 Close  csr_grades_in_bdgt;
 --
 hr_utility.set_location('Leaving :'||l_proc,10);
--
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('Exception :'||l_proc,15);
      raise;
End;
--------------------------------------------------------------------------
PROCEDURE Validate_organization(p_organization_id       in number,
                                p_budget_version_id in number)
is
--
 Cursor csr_organization is
   Select null
     From hr_organization_units
    Where organization_id = p_organization_id;
--
--
-- The foll cursor checks if the passed organization is present in the passed
-- budget version.
--
Cursor csr_orgs_in_bdgt is
   Select null
     From pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bdt.organization_id    = p_organization_id;
--
l_dummy         varchar2(1);
--
l_proc          varchar2(72) := g_package ||'Validate_organization';
--
Begin
 --
 hr_utility.set_location('Entering :'||l_proc,5);
 --
 -- validate if the organization is in hr_organization_units
 --
 Open  csr_organization;
 Fetch  csr_organization into l_dummy;
 If  csr_organization%notfound then
     --Write into error log
     Close  csr_organization;
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_ENTITY_TYPE');
     FND_MESSAGE.SET_TOKEN('ENTITY',hr_general.decode_lookup('PQH_BUDGET_ENTITY','ORGANIZATION'));
     APP_EXCEPTION.RAISE_EXCEPTION;
     --
 End if;
 Close  csr_organization;
 -- Also check if the organization belongs to the passed budget version
 -- and return the budget id of the budget version
 --
 Open  csr_orgs_in_bdgt;
 Fetch  csr_orgs_in_bdgt into l_dummy;
 If  csr_orgs_in_bdgt%notfound then
     Close  csr_orgs_in_bdgt;
     FND_MESSAGE.SET_NAME('PQH','PQH_ENT_TYPE_NOT_IN_BDGT_VER');
     FND_MESSAGE.SET_TOKEN('ENTITY',hr_general.decode_lookup('PQH_BUDGET_ENTITY','ORGANIZATION'));
     APP_EXCEPTION.RAISE_EXCEPTION;
 End if;
 Close  csr_orgs_in_bdgt;
 --
 hr_utility.set_location('Leaving :'||l_proc,10);
--
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('Exception :'||l_proc,15);
      raise;
End;
--------------------------------------------------------------------------
PROCEDURE Validate_assignment(p_assignment_id in number)
is
--
 Cursor csr_assg is
   Select null
     From per_all_assignments_f
    Where assignment_id = p_assignment_id;
--
l_dummy         varchar2(1);
l_proc                       varchar2(72) := g_package ||'Validate_assignment';
--
Begin
--
 hr_utility.set_location('Entering :'||l_proc,5);
 --
 Open  csr_assg;
 Fetch  csr_assg into l_dummy;
 If  csr_assg%notfound then
     --Raise error
     Close  csr_assg;
     FND_MESSAGE.SET_NAME('PQH','PQH_ACT_INVALID_ASSIGNMENT');
     APP_EXCEPTION.RAISE_EXCEPTION;
     --
 End if;
 hr_utility.set_location('Leaving :'||l_proc,10);
 Close  csr_assg;
--
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('Exception :'||l_proc,15);
      raise;
End;
--------------------------------------------------------------------------
PROCEDURE Validate_element_type(p_element_type_id in number)
is
--
 Cursor csr_elmnt_type is
   Select null From pay_element_types_f
    Where element_type_id = p_element_type_id;
--
l_dummy         varchar2(1);
l_proc                       varchar2(72) := g_package ||'Validate_element_type';
--
Begin
--
 hr_utility.set_location('Entering :'||l_proc,5);
 --
 if p_element_type_id is not null then
    Open  csr_elmnt_type;
    Fetch  csr_elmnt_type into l_dummy;
    If  csr_elmnt_type%notfound then
        Close  csr_elmnt_type;
        FND_MESSAGE.SET_NAME('PQH','PQH_ACT_INVALID_ELMNT_TYPE');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End if;
    Close  csr_elmnt_type;
 else
    FND_MESSAGE.SET_NAME('PQH','PQH_ACT_INVALID_ELMNT_TYPE');
    APP_EXCEPTION.RAISE_EXCEPTION;
 end if;
 --
 hr_utility.set_location('Leaving :'||l_proc,10);
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('Leaving :'||l_proc,15);
      raise;
End;
-------------------------------------------------------------------------------
Procedure Validate_unit_of_measure(p_unit_of_measure_id    in  number,
                                   p_unit_of_measure_desc  out nocopy varchar2)
is
--
 Cursor csr_uom is
   Select system_type_cd
     From per_shared_types
    Where shared_type_id = p_unit_of_measure_id
     AND  lookup_type = 'BUDGET_MEASUREMENT_TYPE';
--
l_proc        varchar2(72) := g_package||'Validate_unit_of_measure';
Begin
 hr_utility.set_location('Entering:'||l_proc, 5);
 -- Check if the unit of measure exists in per_shared_types
 Open csr_uom;
 Fetch csr_uom into p_unit_of_measure_desc;
 If csr_uom%notfound then
     Close csr_uom;
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_BUDGET_UOM');
     APP_EXCEPTION.RAISE_EXCEPTION;
 End if;
 Close csr_uom;
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
Exception
  When others then
     p_unit_of_measure_desc := null;
     hr_utility.set_location('Exception:'||l_proc, 15);
     raise;
End;
-----------------------------------------------------------------------
Procedure Validate_uom_in_budget(p_unit_of_measure_id    in  number,
                                 p_budget_id             in  number)
is
 --
 Cursor csr_uom_in_bdgt is
   Select null
    From pqh_budgets
    Where budget_id = p_budget_id
      AND (budget_unit1_id = p_unit_of_measure_id  OR
           budget_unit2_id = p_unit_of_measure_id  OR
           budget_unit3_id = p_unit_of_measure_id);
--
l_proc        varchar2(72) := g_package||'Validate_uom_in_budget';
l_dummy       varchar2(1);
--
Begin
 hr_utility.set_location('Entering:'||l_proc, 5);
 -- Check if the budget includes the unit of measure
 Open csr_uom_in_bdgt;
 Fetch csr_uom_in_bdgt into l_dummy;
 If csr_uom_in_bdgt%notfound then
    Close csr_uom_in_bdgt;
    FND_MESSAGE.SET_NAME('PQH','PQH_UOM_NOT_IN_BDGT');
    APP_EXCEPTION.RAISE_EXCEPTION;
 End if;
 Close csr_uom_in_bdgt;
 hr_utility.set_location('Leaving:'||l_proc, 10);
Exception When others then
  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;
End;
-------------------------------------------------------------------------------
PROCEDURE Validate_actuals_dates(p_actuals_start_dt         in date,
                                 p_actuals_end_dt           in date,
                                 p_budget_id                in number) is
--
l_budget_start_date     pqh_budgets.budget_start_date%type;
l_budget_end_date       pqh_budgets.budget_end_date%type;
--
l_proc        varchar2(72) := g_package||'Validate_actuals_dates';
--
Cursor csr_bdgt is
   Select budget_start_date,budget_end_date
     From pqh_budgets
    Where budget_id = p_budget_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
-- 1) Check if p_actuals_end_dt > p_actuals_start_dt.
  If p_actuals_end_dt < p_actuals_start_dt then
     FND_MESSAGE.SET_NAME('PQH','PQH_END_DT_LESS_THAN_START_DT');
     APP_EXCEPTION.RAISE_EXCEPTION;
  End if;
  Open csr_bdgt;
  Fetch csr_bdgt into l_budget_start_date,l_budget_end_date;
  Close csr_bdgt;
-- 2) Check if p_actuals_start_dt < l_budget_start_date
-- 3) Check if p_actual_start_dt > l_budget_end_date
  if p_actuals_start_dt < l_budget_start_date
     OR p_actuals_start_dt > l_budget_end_date then
     --
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_ACTUALS_START_DT');
     APP_EXCEPTION.RAISE_EXCEPTION;
  End if;
-- 4) Check if p_actuals_end_dt > l_budget_end_date
  if p_actuals_end_dt > l_budget_end_date then
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_ACTUALS_END_DT');
     APP_EXCEPTION.RAISE_EXCEPTION;
  End if;
 hr_utility.set_location('Leaving:'||l_proc, 10);
Exception When others then
  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;
End;
-------------------------------------------------------------------------
PROCEDURE Validate_commitment_dates(p_cmmtmnt_start_dt in date,
                                    p_cmmtmnt_end_dt   in date,
                                    p_budget_id        in number) is
--
l_budget_start_date     pqh_budgets.budget_start_date%type;
l_budget_end_date       pqh_budgets.budget_end_date%type;
--
l_proc        varchar2(72) := g_package||'Validate_commitment_dates';
--
Cursor csr_bdgt is
   Select budget_start_date,budget_end_date
     From pqh_budgets
    Where budget_id = p_budget_id;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If p_cmmtmnt_end_dt < p_cmmtmnt_start_dt then
     FND_MESSAGE.SET_NAME('PQH','PQH_END_DT_LESS_THAN_START_DT');
     APP_EXCEPTION.RAISE_EXCEPTION;
  End if;
  Open csr_bdgt;
  Fetch csr_bdgt into l_budget_start_date,l_budget_end_date;
  Close csr_bdgt;
-- 2) Check if p_cmmtmnt_start_dt < p_budget_start_date
  if p_cmmtmnt_start_dt < l_budget_start_date then
     FND_MESSAGE.SET_NAME('PQH','PQH_CMT_START_BEF_BDGT_START');
     APP_EXCEPTION.RAISE_EXCEPTION;
  End if;
-- 3) Check if p_cmmtmnt_start_dt > l_budget_end_date
  if p_cmmtmnt_start_dt > l_budget_end_date then
     FND_MESSAGE.SET_NAME('PQH','PQH_CMTMNT_START_AFT_BDGT_END');
     APP_EXCEPTION.RAISE_EXCEPTION;
  End if;
-- 4) Check if p_cmmtmnt_end_dt > l_budget_end_date
  if p_cmmtmnt_end_dt > l_budget_end_date then
     FND_MESSAGE.SET_NAME('PQH','PQH_CMTMNT_END_AFT_BDGT_END');
     APP_EXCEPTION.RAISE_EXCEPTION;
  End if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
Exception When others then
  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;
End;
--------------------------------------------------------------------------
FUNCTION get_bg_legislation_code (p_business_group_id    in      number)
RETURN varchar2 IS
--
Cursor csr_lc is
SELECT O3.ORG_INFORMATION9 legislation_code
FROM HR_ORGANIZATION_INFORMATION O3
WHERE  O3.ORGANIZATION_ID = p_business_group_id
 AND O3.ORG_INFORMATION_CONTEXT = 'Business Group Information';
--
l_legislation_code      HR_ORGANIZATION_INFORMATION.ORG_INFORMATION9%type;
--
BEGIN
 --
 Open csr_lc;
 Fetch csr_lc into l_legislation_code;
 Close csr_lc;
 --
 RETURN l_legislation_code;
 --
End;

----------------------------------------------------------------------------
Function Convert_actuals(p_figure            in    number,
                         p_from_start_date   in    date,
                         p_from_end_date     in    date,
                         p_to_start_date     in    date,
                         p_to_end_date       in    date )
RETURN NUMBER
IS
--
l_calc_start_date date;
l_calc_end_date   date;
--
l_days_in_from_period      number(10);
l_days_in_to_period        number(10);
l_converted_amt            number;
--
l_proc       varchar2(72) := g_package || 'Convert_actuals';
--
Begin
  --
  hr_utility.set_location('Entering :'||l_proc,5);
-- No conversion needed if the periods are the same.
  If p_from_start_date = p_to_start_date
     AND p_from_end_date = p_to_end_date then
    RETURN p_figure;
  End if;
-- Find the days between p_actuals_end_date,p_actuals_start_date
  l_days_in_from_period := (p_from_end_date - p_from_start_date) + 1;
-- Find the days between l_calc_end_date,l_calc_start_date
  l_days_in_to_period := (p_to_end_date - p_to_start_date) + 1;
  --
  hr_utility.set_location('Convert :'||to_char(p_figure) || ' For ' || to_char(l_days_in_from_period
) ||
' days ' || ' To ' || to_char(l_days_in_to_period),10);
  --
  l_converted_amt := p_figure * l_days_in_to_period/ l_days_in_from_period ;
  --
  hr_utility.set_location('Leaving :'||l_proc,10);
  RETURN l_converted_amt;
Exception When others then
  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;
End;
--------------------------------------------------------------------------
FUNCTION get_pos_budget_values(p_position_id       in  number,
                               p_period_start_dt  in  date,
                               p_period_end_dt    in  date,
                               p_unit_of_measure   in  varchar2)
RETURN number is
--
l_business_group_id         hr_all_positions_f.business_group_id%type;
l_pbv       number;
--
 Cursor csr_pos is
   Select psf.business_group_id
   from hr_all_positions_f psf
   Where psf.position_id = p_position_id
   and rownum < 2;
--
l_proc        varchar2(72) := g_package||'get_pos_budget_values';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
-- Obtain the business group of the position.
 Open csr_pos;
 Fetch csr_pos into l_business_group_id;
 Close csr_pos;
 --
 -- Call function that returns commitment.
 --
 l_pbv := hr_discoverer.get_actual_budget_values
 (p_unit             => p_unit_of_measure,
  p_bus_group_id     => l_business_group_id ,
  p_organization_id  => NULL ,
  p_job_id           => NULL ,
  p_position_id      => p_position_id ,
  p_grade_id         => NULL ,
  p_start_date       => p_period_start_dt ,
  p_end_date         => p_period_end_dt ,
  p_actual_val       => NULL
 );
 hr_utility.set_location('Leaving:'||l_proc, 10);
RETURN l_pbv;
Exception When others then
  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;
End;
---------------------------------------------------------------------
FUNCTION get_assignment_budget_values(p_assignment_id    in  number,
                                      p_period_start_dt  in  date,
                                      p_period_end_dt    in  date,
                                      p_unit_of_measure  in  varchar2)
RETURN number is
--
CURSOR CSR_ABV IS
    SELECT NVL(SUM(ABV.VALUE),0)
    FROM   per_assignment_budget_values_f abv
    WHERE  abv.assignment_id          = p_assignment_id
    AND    abv.unit                   = p_unit_of_measure
    AND    (p_period_end_dt BETWEEN abv.effective_start_date AND
                                     abv.effective_end_date)
    AND abv.assignment_id =
    (select assignment_id
     from per_all_assignments_f        asg,
          per_assignment_status_types ast
     where asg.assignment_id          = p_assignment_id
     AND   asg.assignment_type        = 'E'
     AND    (p_period_end_dt BETWEEN asg.effective_start_date AND
                                      asg.effective_end_date)
     AND    asg.assignment_status_type_id = ast.assignment_status_type_id
     AND    ast.per_system_status <> 'TERM_ASSIGN');
--
l_abv         number;
l_proc        varchar2(72) := g_package||'get_assignment_budget_values';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 OPEN CSR_ABV;
 FETCH CSR_ABV INTO l_abv;
 IF (CSR_ABV%NOTFOUND) THEN
    l_abv := 0;
 END IF;
 CLOSE CSR_ABV;
 hr_utility.set_location('Leaving:'||l_proc, 10);
RETURN l_abv;
Exception When others then
  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;
End;
--
-- get_sum_actuals
-- this method is same as get_actuals except that it does not fetch
-- values in a loop, instead sums the values
-- ********************

FUNCTION get_sum_actuals(p_assignment_id         in   number,
                     p_legislation_code      in   varchar2,
                     p_payroll_id            in   number,
                     p_element_type_id       in   number,
                     p_actuals_start_date    in   date,
                     p_actuals_end_date      in   date,
                     p_last_payroll_dt    out nocopy   date)
RETURN NUMBER IS

cursor curs is
   select classification_id
   from   pay_element_classifications
   where  classification_name in ('Employer Liabilities', 'Earnings','Supplemental Earnings')
   and    legislation_code = p_legislation_code;

cl_id number;

Cursor csr_assg_actuals1(p_element_type_id number) IS
SELECT max(aa.end_Date) last_payroll_dt, sum(RRV.RESULT_VALUE * get_factor(aa.start_date, aa.end_date,
                  greatest(p_actuals_start_date,aa.start_date), least(p_actuals_end_date,aa.end_date))) result_value
FROM
 PAY_INPUT_VALUES_F INV,PAY_RUN_RESULT_VALUES RRV,
 PAY_ELEMENT_TYPES_F PET,
 PAY_RUN_RESULTS RES,
 (
Select tp.start_date, tp.end_date,  aac.assignment_action_id
From per_time_periods tp,
     pay_payroll_actions ppa,
     PAY_ASSIGNMENT_ACTIONS AAC
Where tp.payroll_id=p_payroll_id
  AND (tp.start_date <= p_actuals_end_date and   tp.end_date >= p_actuals_start_date)
  and tp.payroll_id = ppa.payroll_id
  and ppa.payroll_id = p_payroll_id
  and tp.time_period_id = ppa.time_period_id
  and ppa.date_earned between tp.start_date and tp.end_date
  AND PPA.PAYROLL_ACTION_ID = AAC.PAYROLL_ACTION_ID
  AND AAC.ASSIGNMENT_ID = p_assignment_id) AA
WHERE RES.ASSIGNMENT_ACTION_ID = aa.assignment_action_id
  AND RES.STATUS IN ( 'P','PA'  )
  AND PET.CLASSIFICATION_ID in (
     select classification_id
   from pay_element_classifications
   where classification_name in ('Employer Liabilities', 'Earnings','Supplemental Earnings')
   and legislation_code = 'US'
   )
  AND PET.ELEMENT_TYPE_ID = p_element_type_id
  AND aa.start_date BETWEEN PET.EFFECTIVE_START_DATE AND PET.EFFECTIVE_END_DATE
  AND PET.ELEMENT_TYPE_ID = RES.ELEMENT_TYPE_ID
  AND PET.ELEMENT_TYPE_ID = INV.ELEMENT_TYPE_ID
  AND RES.ELEMENT_TYPE_ID = INV.ELEMENT_TYPE_ID
  AND INV.NAME = 'Pay Value'
  AND aa.start_date BETWEEN INV.EFFECTIVE_START_DATE AND INV.EFFECTIVE_END_DATE
  AND RRV.RUN_RESULT_ID = RES.RUN_RESULT_ID
  AND RRV.INPUT_VALUE_ID = INV.INPUT_VALUE_ID;

Cursor csr_assg_actuals2 IS
SELECT max(aa.end_Date) last_payroll_dt, sum(RRV.RESULT_VALUE *  get_factor(aa.start_date, aa.end_date,
                  greatest(p_actuals_start_date,aa.start_date), least(p_actuals_end_date,aa.end_date))) result_value
FROM
 PAY_INPUT_VALUES_F INV,PAY_RUN_RESULT_VALUES RRV,
 PAY_ELEMENT_TYPES_F PET,
 PAY_RUN_RESULTS RES,
 (
 Select tp.start_date, tp.end_date, aac.assignment_action_id
From per_time_periods tp,
     pay_payroll_actions ppa,
     PAY_ASSIGNMENT_ACTIONS AAC
Where tp.payroll_id=p_payroll_id
  AND (tp.start_date <= p_actuals_end_date and   tp.end_date >= p_actuals_start_date)
  and tp.payroll_id = ppa.payroll_id
  and ppa.payroll_id = p_payroll_id
  and tp.time_period_id = ppa.time_period_id
  and ppa.date_earned between tp.start_date and tp.end_date
  AND PPA.PAYROLL_ACTION_ID = AAC.PAYROLL_ACTION_ID
  AND AAC.ASSIGNMENT_ID = p_assignment_id) AA
WHERE RES.ASSIGNMENT_ACTION_ID = aa.assignment_action_id
  AND RES.STATUS IN ( 'P','PA'  )
  AND PET.CLASSIFICATION_ID in (
     select classification_id
   from pay_element_classifications
   where classification_name in ('Employer Liabilities', 'Earnings','Supplemental Earnings')
   and legislation_code = 'US'   )
  AND aa.start_date BETWEEN PET.EFFECTIVE_START_DATE AND PET.EFFECTIVE_END_DATE
  AND PET.ELEMENT_TYPE_ID = RES.ELEMENT_TYPE_ID
  AND PET.ELEMENT_TYPE_ID = INV.ELEMENT_TYPE_ID
  AND RES.ELEMENT_TYPE_ID = INV.ELEMENT_TYPE_ID
  AND INV.NAME = 'Pay Value'
  AND aa.start_date BETWEEN INV.EFFECTIVE_START_DATE AND INV.EFFECTIVE_END_DATE
  AND RRV.RUN_RESULT_ID = RES.RUN_RESULT_ID
  AND RRV.INPUT_VALUE_ID = INV.INPUT_VALUE_ID;

l_from_period_start_dt      date;
l_from_period_end_dt        date;
l_to_period_start_dt        date;
l_to_period_end_dt          date;
l_result_value              pay_run_result_values.result_value%type;
l_element_type_id           pay_run_results.element_type_id%type;

l_converted_amt             number;
l_assignment_actuals        number;
l_proc                      varchar2(72) := g_package ||'get_sum_actuals';
l_dummy number;
l_last_payroll_dt date;
cursor csr_asg_act_exists is
select 1
from dual
where exists
    (select null
     from pay_assignment_actions
     where assignment_id = p_assignment_id);

Begin
   hr_utility.set_location('Entering :'||l_proc,5);
   l_assignment_actuals := 0;

   open csr_asg_act_exists;
   fetch csr_asg_act_exists into l_dummy;
   if csr_asg_act_exists%found then
   hr_utility.set_location('** Exists, element_Type'||p_element_type_id,5);
      if (p_element_type_id is not null) then
         open  csr_assg_actuals1(p_element_type_id);
         fetch csr_assg_actuals1 into l_last_payroll_dt, l_result_value;
         close csr_assg_actuals1;
      else
         open  csr_assg_actuals2;
         fetch csr_assg_actuals2 into l_last_payroll_dt, l_result_value;
         close csr_assg_actuals2;
   hr_utility.set_location('** Opened cursor 2, date:'||l_last_payroll_dt||'  Result: '||l_result_value,5);
      end if;
      l_last_payroll_dt := get_last_payroll_dt(p_assignment_id,
                              p_actuals_start_date, p_actuals_end_date);
      p_last_payroll_dt := l_last_payroll_dt;
   End if;
   close csr_asg_act_exists;



   hr_utility.set_location('Leaving :'||l_proc,20);
   RETURN l_result_value;
Exception When others then
  if (csr_asg_act_exists%isopen) then
    close csr_asg_act_exists;
  end if;
  p_last_payroll_dt := null;
  hr_utility.set_location('Exception:'||l_proc, 25);
  raise;
End get_sum_actuals;
------------------------------------------------------------------------
--
-- get_element_actuals
-- This method is same as get_sum_actuals except that it does not restrict the
-- elements to be of classification 'Employee Liability' or 'Earnings.
------------------------------------------------------------------------

FUNCTION get_element_actuals(p_assignment_id in   number,
                     p_legislation_code      in   varchar2,
                     p_payroll_id            in   number,
                     p_element_type_id       in   number,
                     p_actuals_start_date    in   date,
                     p_actuals_end_date      in   date,
                     p_ele_input_value_id    in number default null,
                     p_last_payroll_dt       out nocopy date)
RETURN NUMBER IS

Cursor csr_assg_actuals(p_element_type_id number) IS
SELECT max(aa.end_Date) last_payroll_dt, sum(RRV.RESULT_VALUE * get_factor(aa.start_date, aa.end_date,
                  greatest(p_actuals_start_date,aa.start_date), least(p_actuals_end_date,aa.end_date))) result_value
FROM
 PAY_INPUT_VALUES_F INV,PAY_RUN_RESULT_VALUES RRV,
 PAY_ELEMENT_TYPES_F PET,
 PAY_RUN_RESULTS RES,
 (
Select tp.start_date, tp.end_date,  aac.assignment_action_id
From per_time_periods tp,
     pay_payroll_actions ppa,
     PAY_ASSIGNMENT_ACTIONS AAC
Where tp.payroll_id=p_payroll_id
  AND (tp.start_date <= p_actuals_end_date and   tp.end_date >= p_actuals_start_date)
  and tp.payroll_id = ppa.payroll_id
  and ppa.payroll_id = p_payroll_id
  and tp.time_period_id = ppa.time_period_id
  and ppa.date_earned between tp.start_date and tp.end_date
  AND PPA.PAYROLL_ACTION_ID = AAC.PAYROLL_ACTION_ID
  AND AAC.ASSIGNMENT_ID = p_assignment_id) AA
WHERE RES.ASSIGNMENT_ACTION_ID = aa.assignment_action_id
  AND RES.STATUS IN ( 'P','PA'  )
  AND PET.ELEMENT_TYPE_ID = p_element_type_id
  AND aa.start_date BETWEEN PET.EFFECTIVE_START_DATE AND PET.EFFECTIVE_END_DATE
  AND PET.ELEMENT_TYPE_ID = RES.ELEMENT_TYPE_ID
  AND PET.ELEMENT_TYPE_ID = INV.ELEMENT_TYPE_ID
  AND RES.ELEMENT_TYPE_ID = INV.ELEMENT_TYPE_ID
  -- AND INV.INPUT_VALUE_ID = p_ele_input_value_id --'Pay Value'
  AND INV.NAME = 'Pay Value'
  AND aa.start_date BETWEEN INV.EFFECTIVE_START_DATE AND INV.EFFECTIVE_END_DATE
  AND RRV.RUN_RESULT_ID = RES.RUN_RESULT_ID
  AND RRV.INPUT_VALUE_ID = INV.INPUT_VALUE_ID;

l_from_period_start_dt      date;
l_from_period_end_dt        date;
l_to_period_start_dt        date;
l_to_period_end_dt          date;
l_result_value              pay_run_result_values.result_value%type;
l_element_type_id           pay_run_results.element_type_id%type;

l_converted_amt             number;
l_assignment_actuals        number;
l_proc                      varchar2(72) := g_package ||'get_element_actuals';
l_dummy number;
l_last_payroll_dt date;
cursor csr_asg_act_exists is
select 1
from dual
where exists
    (select null
     from pay_assignment_actions
     where assignment_id = p_assignment_id);

Begin
   hr_utility.set_location('Entering :'||l_proc,5);
   l_assignment_actuals := 0;

   open csr_asg_act_exists;
   fetch csr_asg_act_exists into l_dummy;
   if csr_asg_act_exists%found then
   hr_utility.set_location('** Exists, element_Type'||p_element_type_id,5);
      if (p_element_type_id is not null) then
         open  csr_assg_actuals(p_element_type_id);
         fetch csr_assg_actuals into l_last_payroll_dt, l_result_value;
         close csr_assg_actuals;
      end if;
      l_last_payroll_dt := get_last_payroll_dt(p_assignment_id,
                              p_actuals_start_date, p_actuals_end_date);
      p_last_payroll_dt := l_last_payroll_dt;
   End if;
   close csr_asg_act_exists;
   hr_utility.set_location('Leaving :'||l_proc,20);
   RETURN l_result_value;
Exception When others then
  if (csr_asg_act_exists%isopen) then
    close csr_asg_act_exists;
  end if;
  p_last_payroll_dt := null;
  hr_utility.set_location('Exception:'||l_proc, 25);
  raise;
End get_element_actuals;
--
------------------------------------------------------------------------
-- get_payroll_run_date
-- This method gets the most recent payroll run date for the assignment.
------------------------------------------------------------------------
PROCEDURE get_payroll_run_date(p_assignment_id         in   number,
                     p_payroll_id            in   number,
                     p_actuals_start_date    in   date,
                     p_actuals_end_date      in   date,
                     p_last_payroll_dt       out nocopy date)
IS

Cursor csr_pay_date Is
Select max(tp.end_date)
From per_time_periods tp,
     pay_payroll_actions ppa,
     PAY_ASSIGNMENT_ACTIONS AAC
Where tp.payroll_id=p_payroll_id
  and (tp.start_date <= p_actuals_end_date and   tp.end_date >= p_actuals_start_date)
  and tp.payroll_id = ppa.payroll_id
  and ppa.payroll_id = p_payroll_id
  and tp.time_period_id = ppa.time_period_id
  and ppa.date_earned between tp.start_date and tp.end_date
  and ppa.payroll_action_id = aac.payroll_action_id
  and aac.assignment_id = p_assignment_id;

l_proc                      varchar2(72) := g_package ||'get_payroll_run_date';
l_dummy number;
l_last_payroll_dt date;
cursor csr_asg_act_exists is
select 1
from dual
where exists
    (select null
     from pay_assignment_actions
     where assignment_id = p_assignment_id);

Begin
   hr_utility.set_location('Entering :'||l_proc,5);

   open csr_asg_act_exists;
   fetch csr_asg_act_exists into l_dummy;
   if csr_asg_act_exists%found then
         open  csr_pay_date;
         fetch csr_pay_date  into l_last_payroll_dt;
         close csr_pay_date;
      p_last_payroll_dt := l_last_payroll_dt;
   End if;
   close csr_asg_act_exists;
   hr_utility.set_location('Leaving :'||l_proc,20);
Exception When others then
  if (csr_asg_act_exists%isopen) then
    close csr_asg_act_exists;
  end if;
  p_last_payroll_dt := null;
  hr_utility.set_location('Exception:'||l_proc, 25);
  raise;
End get_payroll_run_date;
--
------------------------------------------------------------------------

--    get actuals

-- This function is an overloaded function. It checks if an element is defined
-- for actuals. If an elemnt is defined and it has a balance type also defined
-- then it calculates the actual expenditure for an assignment from
-- pay_run_balances. If no balance is defined, then it calls the
-- get_element_actuals procedure to get the actual values. If not it uses
-- the default get_sum_actuals procedure to get the actual value
-- for a given period and  for a given element type id . If the
-- element type id is not input , then all element types are taken into
-- consideration while computing the actual expenditure of the assignment
-- in the get_sum_actual procedure.
-------------------------------------------------------------------------


FUNCTION get_actuals(p_budget_id             in   number default null,
                     p_assignment_id         in   number,
                     p_legislation_code      in   varchar2,
                     p_payroll_id            in   number,
                     p_element_type_id       in   number,
                     p_actuals_start_date    in   date,
                     p_actuals_end_date      in   date,
                     p_last_payroll_dt       out nocopy date)
RETURN NUMBER
IS
cursor csr_actual_exists is
   select 1
   from pqh_bdgt_cmmtmnt_elmnts
   where actual_commitment_type in ('ACTUAL','BOTH')
   and budget_id = p_budget_id;

cursor curs is
   select element_type_id,element_input_value_id, balance_type_id
   from pqh_bdgt_cmmtmnt_elmnts
   where actual_commitment_type in ('ACTUAL','BOTH') and
   element_type_id = nvl(p_element_type_id,element_type_id)
   and budget_id = p_budget_id;

cursor csr_bal(p_balance_type_id number, p_dim_suf VARCHAR2) is
   select defined_balance_id
   from pay_defined_balances def, pay_balance_dimensions dim
   where def.balance_type_id = p_balance_type_id
   and def.balance_dimension_id = dim.balance_dimension_id
   and dim.database_item_suffix = p_dim_suf
   and save_run_balance = 'Y';
   -- and RUN_BALANCE_STATUS = 'V';

cursor csr_asg_action(c_assignment_id number, c_effective_date date) is
   select paa.assignment_action_id
   from pay_assignment_actions paa, pay_payroll_actions ppa
   where paa.payroll_action_id = ppa.payroll_action_id
   and paa.source_action_id is null
   and paa.assignment_id = c_assignment_id
   and ppa.effective_date = (select max(effective_date) from pay_payroll_actions ppa1
                             where ppa1.payroll_action_id = paa.payroll_action_id
                             and paa.assignment_id = c_assignment_id
                             and ppa.effective_date <= c_effective_date);

cursor csr_act_value(c_assignment_id number,c_defined_balance_id number,c_effective_date date) is
  select prb.balance_value
  from pay_run_balances prb, pay_assignment_actions paa
  where prb.assignment_id = c_assignment_id
  and prb.defined_balance_id = c_defined_balance_id
  and prb.assignment_action_id = paa.assignment_action_id
  and paa.source_action_id is not null
  and prb.effective_date =
  (select max(effective_date)
   from pay_run_balances prb1
   where prb1.effective_date <= c_effective_date
    and prb1.assignment_id = c_assignment_id and prb1.defined_balance_id = c_defined_balance_id);

p_ele_id number;
p_ele_inv_id number;
p_balance_type_id number;
l_dummy number;
l_temp number;
l_assignment_start_actuals number;
l_assignment_end_actuals number;
l_assignment_actuals number;
l_assign_action_id number;

l_proc  varchar2(72) := g_package || 'get_actuals';
 l_last_payroll_dt date;
Begin

hr_utility.set_location('Entering :'||l_proc,5);

/* If ((p_budget_id is not null) AND (p_element_type_id is not null)) then */
--Bug Fix 3717620
If (p_budget_id is not null) then
     open csr_actual_exists;
     fetch csr_actual_exists into l_dummy;
     if csr_actual_exists%found then
        open curs;
        fetch curs into p_ele_id,p_ele_inv_id,p_balance_type_id;
           if p_balance_type_id is not null then
              open csr_bal(p_balance_type_id, '_ASG_LTD');
              fetch csr_bal  into l_temp;
              if csr_bal%found then
                 /* Commenting this part of the code for now. May be reused once
                    use of pay_balance_pkg issue is resolved */
               /*  open csr_asg_action(p_assignment_id,p_actuals_start_date);
                 fetch csr_asg_action into l_assign_action_id;
                 l_assignment_start_actuals :=  pay_balance_pkg.get_value(
                                         l_temp, l_assign_action_id);
                 close csr_asg_action;
                 open csr_asg_action(p_assignment_id,p_actuals_end_date);
                 fetch csr_asg_action into l_assign_action_id;
                 l_assignment_end_actuals := pay_balance_pkg.get_value(
                                         l_temp, l_assign_action_id);
                 close csr_asg_action; */
                 open csr_act_value(p_assignment_id,l_temp,p_actuals_start_date);
                 fetch csr_act_value into l_assignment_start_actuals;
                 close csr_act_value;

                 open csr_act_value(p_assignment_id,l_temp,p_actuals_end_date);
                 fetch csr_act_value into l_assignment_end_actuals;
                 close csr_act_value;

                 l_assignment_actuals := nvl(l_assignment_end_actuals,0) - nvl(l_assignment_start_actuals,0);
                 l_last_payroll_dt := get_last_payroll_dt(p_assignment_id,
                              p_actuals_start_date, p_actuals_end_date);
               /*  get_payroll_run_date(p_assignment_id  => p_assignment_id,
                              p_payroll_id             => p_payroll_id,
                              p_actuals_start_date     => p_actuals_start_date,
                              p_actuals_end_date       => p_actuals_end_date,
                              p_last_payroll_dt        => p_last_payroll_dt);
                 p_last_payroll_dt := p_last_payroll_dt; */
              end if;
              close csr_bal;
           elsif (p_ele_id is not null) then
                 l_assignment_actuals :=   get_element_actuals(p_assignment_id   => p_assignment_id,
                             p_legislation_code      => p_legislation_code,
                             p_payroll_id            => p_payroll_id,
                             p_element_type_id       => p_ele_id,
                             p_actuals_start_date    => p_actuals_start_date,
                             p_actuals_end_date      => p_actuals_end_date,
                             p_ele_input_value_id    => p_ele_inv_id,
                             p_last_payroll_dt       => l_last_payroll_dt);

--                 p_last_payroll_dt := p_last_payroll_dt;
           end if;
    close curs;
    else
         /* open curs;
         fetch curs into p_ele_id,p_ele_inv_id,p_balance_type_id; */
                l_assignment_actuals :=   get_sum_actuals(p_assignment_id   => p_assignment_id,
                             p_legislation_code      => p_legislation_code,
                             p_payroll_id            => p_payroll_id,
                             p_element_type_id       => p_element_type_id,
                             p_actuals_start_date    => p_actuals_start_date,
                             p_actuals_end_date      => p_actuals_end_date,
                             p_last_payroll_dt       => l_last_payroll_dt);

--                 p_last_payroll_dt := p_last_payroll_dt;
    end if;
    close csr_actual_exists;
 else
    l_assignment_actuals := get_sum_actuals(p_assignment_id  => p_assignment_id,
                p_legislation_code       => p_legislation_code,
                p_payroll_id             => p_payroll_id,
                p_element_type_id        => p_element_type_id,
                p_actuals_start_date     => p_actuals_start_date,
                p_actuals_end_date       => p_actuals_end_date,
                p_last_payroll_dt        => l_last_payroll_dt);

--     p_last_payroll_dt := p_last_payroll_dt;
 end if;

   p_last_payroll_dt := l_last_payroll_dt;
   hr_utility.set_location('Leaving :'||l_proc,20);
   RETURN l_assignment_actuals;
   --
Exception When others then
  if (csr_actual_exists%isopen) then
    close csr_actual_exists;
  end if;
  p_last_payroll_dt := null;
  hr_utility.set_location('Exception:'||l_proc, 25);
  raise;
End get_actuals;
--
-- ********************
------------------------------------------------------------------------
--              get actuals
-- This function calculates the actual expenditure for an assignment
-- for a given period and  for a given element type id . If the

-- element type id is not input , then all element types are taken into
-- consideration while computing the actual expenditure of the assignment.

FUNCTION get_actuals(p_assignment_id         in   number,
                     p_legislation_code      in   varchar2,
                     p_payroll_id            in   number,
                     p_element_type_id       in   number,
                     p_actuals_start_date    in   date,
                     p_actuals_end_date      in   date,
                     p_last_payroll_dt    out nocopy   date)
RETURN NUMBER
IS
--
-- This cursor will find the classification ids.
--
cursor curs is
   select classification_id
   from pay_element_classifications
   where classification_name in ('Employer Liabilities', 'Earnings','Supplemental Earnings')
   and legislation_code = p_legislation_code;
cl_id number;

--
-- This cursor returns the actual expenditure for
-- each element type that belongs to each assignment action .
--
Cursor csr_assg_actuals1(p_start_date DATE ,p_assignment_action_id NUMBER,
                        p_element_type_id number) IS
SELECT sum(RRV.RESULT_VALUE) result_value
FROM
 PAY_INPUT_VALUES_F INV,PAY_RUN_RESULT_VALUES RRV,
 PAY_ELEMENT_TYPES_F PET,
 PAY_RUN_RESULTS RES
WHERE RES.ASSIGNMENT_ACTION_ID = p_assignment_action_id
  AND RES.STATUS IN ( 'P','PA'  )
  AND PET.CLASSIFICATION_ID = cl_id
  AND PET.ELEMENT_TYPE_ID = p_element_type_id
  AND p_start_date BETWEEN PET.EFFECTIVE_START_DATE AND PET.EFFECTIVE_END_DATE
  AND PET.ELEMENT_TYPE_ID = RES.ELEMENT_TYPE_ID
  AND PET.ELEMENT_TYPE_ID = INV.ELEMENT_TYPE_ID
  AND RES.ELEMENT_TYPE_ID = INV.ELEMENT_TYPE_ID
  AND INV.NAME = 'Pay Value'
  AND p_start_date BETWEEN INV.EFFECTIVE_START_DATE AND INV.EFFECTIVE_END_DATE
  AND RRV.RUN_RESULT_ID = RES.RUN_RESULT_ID
  AND RRV.INPUT_VALUE_ID = INV.INPUT_VALUE_ID;
--
Cursor csr_assg_actuals2(p_start_date DATE ,p_assignment_action_id NUMBER) IS
SELECT sum(RRV.RESULT_VALUE) result_value
FROM
 PAY_INPUT_VALUES_F INV,PAY_RUN_RESULT_VALUES RRV,
 PAY_ELEMENT_TYPES_F PET,
 PAY_RUN_RESULTS RES
WHERE RES.ASSIGNMENT_ACTION_ID = p_assignment_action_id
  AND RES.STATUS IN ( 'P','PA'  )
  AND PET.CLASSIFICATION_ID = cl_id
  AND p_start_date BETWEEN PET.EFFECTIVE_START_DATE AND PET.EFFECTIVE_END_DATE
  AND PET.ELEMENT_TYPE_ID = RES.ELEMENT_TYPE_ID
  AND PET.ELEMENT_TYPE_ID = INV.ELEMENT_TYPE_ID
  AND RES.ELEMENT_TYPE_ID = INV.ELEMENT_TYPE_ID
  AND INV.NAME = 'Pay Value'
  AND p_start_date BETWEEN INV.EFFECTIVE_START_DATE AND INV.EFFECTIVE_END_DATE
  AND RRV.RUN_RESULT_ID = RES.RUN_RESULT_ID
  AND RRV.INPUT_VALUE_ID = INV.INPUT_VALUE_ID;
--
--
--Cursor to find Assignment Action Id and Time period of Payroll
--
Cursor csr_asg_time_periods is
Select /*+ ORDERED */
tp.start_date,tp.end_date, aac.assignment_action_id
From per_time_periods tp,
     pay_payroll_actions ppa,
     PAY_ASSIGNMENT_ACTIONS AAC
Where tp.payroll_id=p_payroll_id
  AND (tp.start_date <= p_actuals_end_date
       and
      tp.end_date >= p_actuals_start_date)
  and tp.payroll_id = ppa.payroll_id
  and ppa.payroll_id = p_payroll_id
  and tp.time_period_id = ppa.time_period_id
  and ppa.date_earned between tp.start_date and tp.end_date
  AND PPA.PAYROLL_ACTION_ID = AAC.PAYROLL_ACTION_ID
  AND AAC.ASSIGNMENT_ID = p_assignment_id
order by tp.end_date;

l_from_period_start_dt      date;
l_from_period_end_dt        date;
l_to_period_start_dt        date;
l_to_period_end_dt          date;
--
l_result_value              pay_run_result_values.result_value%type;
l_element_type_id           pay_run_results.element_type_id%type;
--

l_converted_amt             number;
l_assignment_actuals        number;
--
l_proc                      varchar2(72) := g_package ||'get_actuals';
--
l_dummy number;
--
cursor csr_asg_act_exists is
select 1
from dual
where exists
    (select null
     from pay_assignment_actions
     where assignment_id = p_assignment_id);
Begin
   --
   hr_utility.set_location('Entering :'||l_proc,5);
   --
   l_assignment_actuals := 0;
   --
   open csr_asg_act_exists;
   fetch csr_asg_act_exists into l_dummy;
   if csr_asg_act_exists%found then
         -- This function returns the actual expenditure of one assignment record
         -- for a given period.
         For ctp in  csr_asg_time_periods loop
            --
            l_from_period_start_dt := ctp.start_date;
            l_from_period_end_dt := ctp.end_date;
            --
            --
            p_last_payroll_dt := l_from_period_end_dt;
            --
            -- Sum up the actual expenditure for all the elements to arrive
            -- at the actual expenditure of the assignment.
            --
            -- Actuals start date lies between start and end date of a time period.
            -- Hence we need to compute the value from the actuals start date
            -- to the end date of the time period.
            --
            l_to_period_start_dt := greatest(p_actuals_start_date,l_from_period_start_dt);
            l_to_period_end_dt   := least(p_actuals_end_date,l_from_period_end_dt);
            --
            for classif in curs loop
              cl_id := classif.classification_id;
              --
              if (p_element_type_id is not null) then
                open csr_assg_actuals1(l_from_period_start_dt,
                                          ctp.Assignment_action_id,
                                          p_element_type_id);
                fetch csr_assg_actuals1 into l_result_value;
                close csr_assg_actuals1;
              else
                open csr_assg_actuals2(l_from_period_start_dt,
                                          ctp.Assignment_action_id);
                fetch csr_assg_actuals2 into l_result_value;
                close csr_assg_actuals2;
              end if;
              l_converted_amt := Convert_actuals(
                     p_figure          => fnd_number.canonical_to_number(l_result_value),
                     p_from_start_date => l_from_period_start_dt,
                     p_from_end_date   => l_from_period_end_dt,
                     p_to_start_date   => l_to_period_start_dt,
                     p_to_end_date     => l_to_period_end_dt);
              l_assignment_actuals := l_assignment_actuals + nvl(l_converted_amt,0);
             End loop; /** Clasifications */
         End loop; /** csr_asg_time_periods */
   End if;
   close csr_asg_act_exists;
   hr_utility.set_location('Leaving :'||l_proc,20);
   --
   RETURN l_assignment_actuals;
Exception When others then
  if (csr_asg_act_exists%isopen) then
    close csr_asg_act_exists;
  end if;
  p_last_payroll_dt := null;
  hr_utility.set_location('Exception:'||l_proc, 25);
  raise;
End get_actuals;
--

--------------------------------------------------------------------------
FUNCTION get_assign_money_actuals(p_budget_id            in      number,
                                  p_assignment_id        in      number,
                                  p_element_type_id      in      number,
                                  p_actuals_start_date   in        date,
                                  p_actuals_end_date     in        date,
                                  p_last_payroll_dt     out nocopy        date)
RETURN number is
--
-- Per_all_assignments_f is a date-tracked table. There may be more than
-- one record that is effective in the actuals calculation period
-- with different payrolls.
--
Cursor csr_assg is
Select ASSG.assignment_id,
       ASSG.payroll_id,
       ASSG.business_group_id,
       ASSG.effective_start_date,
       ASSG.effective_end_date
  From per_all_assignments_f ASSG
 Where ASSG.assignment_id = p_assignment_id
   AND ASSG.effective_end_date   >= p_actuals_start_date
   AND ASSG.effective_start_date <= p_actuals_end_date ;
--
l_assignment_id              per_all_assignments_f.assignment_id%type;
l_effective_start_date       per_all_assignments_f.effective_start_date%type;
l_effective_end_date         per_all_assignments_f.effective_end_date%type;
l_payroll_id                 per_all_assignments_f.payroll_id%type;
l_business_group_id number;
l_legislation_code           per_business_groups.legislation_code%type;
--
l_assignment_actuals         number;
l_actuals                    number;
--
l_actuals_sub_start_dt       date;
l_actuals_sub_end_dt         date;
--
l_proc                       varchar2(72) := g_package||'get_assign_money_actuals';
--
Begin
--
 hr_utility.set_location('Entering :'||l_proc,5);
 --
 l_assignment_actuals := 0;
 --
 Open csr_assg;
 --
 Loop
     -- Fetch next record for assignment
     Fetch csr_assg into l_assignment_id,l_payroll_id,l_business_group_id,
                        l_effective_start_date,l_effective_end_date;
     --
     If csr_assg%notfound then
        exit;
     End if;
     if l_legislation_code is null then
        l_legislation_code := get_bg_legislation_code(l_business_group_id);
     end if;
     --
     hr_utility.set_location('Assignment :'||to_char(l_assignment_id),10);
     hr_utility.set_location('Payroll :'||to_char(l_payroll_id),15);
     --
     l_actuals := 0;
     --
     If l_payroll_id IS NOT NULL then
        --
        -- Check if the effective start date of this assignment is
        -- lesser than the actuals start date . If so , we are interested
        -- in calculating actuals only from the actuals start date .
        -- Else we will try to calculate actuals from the effective
        -- start date .
        --
        l_actuals_sub_start_dt := greatest(p_actuals_start_date,l_effective_start_date);
        --
        -- Check if the effective end date of this assignment record is
        -- lesser than the actuals end date . If so , we are interested
        -- in calculating actuals only upto the effective end date of the
        -- assignment . Else we will try to calculate actuals upto from the
        -- actuals end date .
        --
        l_actuals_sub_end_dt := least(p_actuals_end_date,l_effective_end_date);
        --
        hr_utility.set_location('Calculating for :'||to_char(l_actuals_sub_start_dt,'DD/MM/RRRR') || ' to ' || to_char(l_actuals_sub_end_dt,'DD/MM/RRRR'),20);
        /* l_actuals := get_sum_actuals(p_assignment_id          => l_assignment_id,
                                 p_legislation_code       => l_legislation_code,
                                 p_payroll_id             => l_payroll_id,
                                 p_element_type_id        => p_element_type_id,
                                 p_actuals_start_date     => l_actuals_sub_start_dt,
                                 p_actuals_end_date       => l_actuals_sub_end_dt,
                                 p_last_payroll_dt        => p_last_payroll_dt);   */
       /*2716884*/
          l_actuals := get_actuals(p_budget_id            => p_budget_id,
                                 p_assignment_id          => l_assignment_id,
                                 p_legislation_code       => l_legislation_code,
                                 p_payroll_id             => l_payroll_id,
                                 p_element_type_id        => p_element_type_id,
                                 p_actuals_start_date     => l_actuals_sub_start_dt,
                                 p_actuals_end_date       => l_actuals_sub_end_dt,
                                 p_last_payroll_dt        => p_last_payroll_dt);
      End if;
      --
      l_assignment_actuals := nvl(l_actuals,0) + l_assignment_actuals;
      --
 End loop;
 --
 Close csr_assg;
 --
 -- At this point , we will have an assignments actuals for a  given period.
 --
 hr_utility.set_location('Leaving :'||l_proc,25);
 --
RETURN l_assignment_actuals;
--
Exception When others then
  p_last_payroll_dt := null;
  hr_utility.set_location('Exception:'||l_proc, 30);
  raise;
End get_assign_money_actuals;
--
------------------------------------------------------------------------
--
--
FUNCTION get_assign_money_cmmtmnt(p_assignment_id      in  number,
                                 p_budget_version_id  in  number,
                                 p_element_type_id    in number default null,
                                 p_period_start_date  in  date,
                                 p_period_end_date    in  date)
RETURN NUMBER
IS
--
 Cursor csr_assg_commitment is
        Select nvl(commitment_amount,0),
               commitment_start_date,commitment_end_date
          From pqh_element_commitments
         Where budget_version_id   = p_budget_version_id
           AND assignment_id = p_assignment_id
           AND element_type_id  = nvl(p_element_type_id,element_type_id)
           AND commitment_start_date <= p_period_end_date
           AND commitment_end_date >= p_period_start_date;
--
l_prorate_start_dt   date;
l_prorate_end_dt     date;
--
l_commitment_start_date  pqh_element_commitments.commitment_start_date%type;
l_commitment_end_date    pqh_element_commitments.commitment_end_date%type;
--
l_prorate_amt        number ;
l_assign_cmmtmnt     number ;
l_amount             number;
--
l_proc        varchar2(72) := g_package||'get_assign_money_cmmtmnt';
--
Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
--
l_assign_cmmtmnt := 0;
--
Open csr_assg_commitment;
--

Loop
--
   Fetch csr_assg_commitment into l_amount,l_commitment_start_date,
                                  l_commitment_end_date;
   --
   If csr_assg_commitment%notfound then
      exit;
   End if;
   --
   l_prorate_start_dt := greatest(p_period_start_date,l_commitment_start_date);
   l_prorate_end_dt := least(p_period_end_date,l_commitment_end_date);
   --
hr_utility.set_location('Dates used for evaluating prorated amount: '||l_prorate_start_dt||' - '||l_prorate_end_dt, 66);
   l_prorate_amt := l_amount *
                     (
                       (l_prorate_end_dt - l_prorate_start_dt +1)/
                       (l_commitment_end_date - l_commitment_start_date + 1)
                     );
   --
hr_utility.set_location('Amount Found: '||l_amount||' Prorated amount: '||l_prorate_amt, 67);
   l_assign_cmmtmnt := l_assign_cmmtmnt + l_prorate_amt;
   --
End loop;
--
Close csr_assg_commitment;
hr_utility.set_location('Assignment Commitment returned '||l_assign_cmmtmnt, 68);
--
hr_utility.set_location('Leaving:'||l_proc, 10);
--
RETURN l_assign_cmmtmnt;
--
Exception When others then
  --
  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;
  --
End get_assign_money_cmmtmnt;
--
------------------------------------------------------------------------
--
FUNCTION  get_assignment_actuals
                     (p_assignment_id              in number,
                      p_element_type_id            in number  default NULL,
                      p_actuals_start_date         in date,
                      p_actuals_end_date           in date,
                      p_unit_of_measure_id         in number,
                      p_last_payroll_dt           out nocopy date)
RETURN NUMBER
is

--
 l_unit_of_measure            per_shared_types.system_type_cd%type;
 l_actuals                    number := 0;
--
 l_proc              varchar2(72) := g_package ||'get_assignment_actuals';
--
Begin
   --
   hr_utility.set_location('Entering :'||l_proc,5);
   --
   -- Check if input unit of measure is valid in per_shared_types.
   --
   Validate_unit_of_measure(p_unit_of_measure_id    => p_unit_of_measure_id,
                            p_unit_of_measure_desc  => l_unit_of_measure);
   --
   -- 1) Check if p_actuals_end_dt > p_actuals_start_dt.
   --
   If p_actuals_end_date < p_actuals_start_date then
     --
     FND_MESSAGE.SET_NAME('PQH','PQH_END_DT_LESS_THAN_START_DT');
     APP_EXCEPTION.RAISE_EXCEPTION;
     --
   End if;

   --
   --
   -- Check if this is a valid assignment
   --
if p_assignment_id is not null then
   Validate_assignment(p_assignment_id => p_assignment_id);
end if;
   --
   --
   -- Check if this is a valid element type, if the element_type is input.
   --
   Validate_element_type(p_element_type_id => p_element_type_id);
   --
   -- We have finished doing a basic validation of all the inputs .We can
   -- Now,Call the respective function that returns the actuals for a
   -- assignment and for the unit of measure.
   --
   If l_unit_of_measure = 'MONEY' then
      --
      l_actuals := get_assign_money_actuals
                        (p_budget_id              =>  null,     /*2716884*/
                         p_assignment_id          =>  p_assignment_id,
                         p_element_type_id        =>  p_element_type_id,
                         p_actuals_start_date     =>  p_actuals_start_date,
                         p_actuals_end_date       =>  p_actuals_end_date,
                         p_last_payroll_dt        =>  p_last_payroll_dt);

      --
   Else
      --
      -- Call get_assignment_budget_values
      --
      l_actuals := get_assignment_budget_values
                            (p_assignment_id    => p_assignment_id,
                             p_period_start_dt  => p_actuals_start_date,
                             p_period_end_dt    => p_actuals_end_date,
                             p_unit_of_measure  => l_unit_of_measure);
      p_last_payroll_dt := NULL;
      --
   End if;
   --
   --
   hr_utility.set_location('Leaving :'||l_proc,10);
   --
   RETURN l_actuals;
   --
Exception When others then
p_last_payroll_dt := null;
  --
  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;

  --
End get_assignment_actuals;
--
--------------------------------------------------------------------------
PROCEDURE  get_version_from_cmmtmnt_table
                     (p_assignment_id              in number,
                      p_start_date                 in date,
                      p_end_date                   in date,
                      p_budget_version_id         out nocopy number)
is
--
-- We want to pick up only the budget versions that lie between the passed
-- dates
--
Cursor csr_version is
       Select budget_version_id
         From pqh_element_commitments
        Where assignment_id = p_assignment_id
          AND (p_start_date <= commitment_end_date AND
               commitment_start_date <= p_end_date);

--
l_proc        varchar2(72) := g_package ||'get_version_from_cmmtmnt_table';

--
Begin
   --
   hr_utility.set_location('Entering :'||l_proc,5);
   --
   Open csr_version;
   --
   -- Selecting the first budget version
   --
   Fetch csr_version into p_budget_version_id;
   --
   If  csr_version%notfound then
   --
       p_budget_version_id := NULL;
   --
   End if;
   --
   Close  csr_version;
   --
   hr_utility.set_location('Leaving :'||l_proc,10);
   --
Exception When others then
p_budget_version_id := null;
  --

  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;
  --
End get_version_from_cmmtmnt_table;
--
--------------------------------------------------------------------------
--
FUNCTION get_assignment_commitment(p_assignment_id      in  number,
                                   p_budget_version_id  in  number default null,
                                   p_element_type_id    in  number default null,
                                   p_period_start_date  in  date,
                                   p_period_end_date    in  date,
                                   p_unit_of_measure_id in  number)
RETURN NUMBER
IS
--
l_assign_commitment  number := 0;
l_assign_actuals     number := 0;
l_last_payroll_dt    per_time_periods.end_date%type := NULL;
--
l_budget_id                 pqh_budgets.budget_id%type := NULL;
l_budget_version_id         pqh_budget_versions.budget_version_id%type;
--

l_unit_of_measure           per_shared_types.system_type_cd%type;
--
--
l_proc        varchar2(72) := g_package||'get_assignment_commitment';
--
Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
--
--
-- Check if this is a valid assignment
--
if p_assignment_id is not null then
   Validate_assignment(p_assignment_id => p_assignment_id);
end if;
--
--
-- Validate if the budget_version_id is a valid one
--
If p_budget_version_id IS NOT NULL then
   --
   Validate_budget(p_budget_version_id  =>  p_budget_version_id,
                   p_budget_id          =>  l_budget_id);
   --
   l_budget_version_id := p_budget_version_id;

   --
Else
   --
   get_version_from_cmmtmnt_table(p_assignment_id     => p_assignment_id,
                                  p_start_date        => p_period_start_date,
                                  p_end_date          => p_period_end_date,
                                  p_budget_version_id => l_budget_version_id);
   --
   -- If we are unable to get the budget versions for the given dates , we
   -- will just return 0 commitment for assignment.
   --
   If l_budget_version_id IS NULL then
      --
      Return 0;
      --
   End if;
   --
End if;
--
-- Validate if the unit of measure is valid in per_shared_types
-- Also , check if the unit has been budgeted for in the budget.
--
Validate_unit_of_measure(p_unit_of_measure_id   => p_unit_of_measure_id,
                         p_unit_of_measure_desc => l_unit_of_measure);
--
Validate_uom_in_budget(p_unit_of_measure_id   => p_unit_of_measure_id,
                       p_budget_id            => l_budget_id);
--
Validate_commitment_dates(p_cmmtmnt_start_dt => p_period_start_date,
                          p_cmmtmnt_end_dt   => p_period_end_date,
                          p_budget_id        => l_budget_id);
--
l_assign_commitment := 0;
--
-- If the UOM is money, obtain commitment from pqh_elements_commitment
-- table . Else get commitment from assignment_budget_values.
--
If l_unit_of_measure = 'MONEY' then
   --
   -- We need to determine the last payroll date of the assignment before
   -- we start calculating the commitment.We must calculate commitment
   -- from the next day of last payroll run
   --
   l_assign_actuals := get_assign_money_actuals
     (p_budget_id         => l_budget_id,  /*2716884*/
      p_assignment_id     => p_assignment_id,
      p_element_type_id   => p_element_type_id,
      p_actuals_start_date=> p_period_start_date,
      p_actuals_end_date  => p_period_end_date,
      p_last_payroll_dt   => l_last_payroll_dt);
   --
   --
   If l_last_payroll_dt IS NULL OR
      l_last_payroll_dt <= p_period_start_date then
   --
      l_assign_commitment := get_assign_money_cmmtmnt
        (p_budget_version_id  => l_budget_version_id,
         p_assignment_id      => p_assignment_id,
         p_element_type_id   => p_element_type_id,
         p_period_start_date  => p_period_start_date,
         p_period_end_date    => p_period_end_date);
   --
   Elsif l_last_payroll_dt > p_period_end_date then
      l_assign_commitment := 0;
   Else
      l_assign_commitment := get_assign_money_cmmtmnt
        (p_budget_version_id  => l_budget_version_id,
         p_assignment_id      => p_assignment_id,
         p_element_type_id   => p_element_type_id,
         p_period_start_date  => l_last_payroll_dt + 1,
         p_period_end_date    => p_period_end_date);
   --
   End if;
   --
Else
   --
   l_assign_commitment := get_assignment_budget_values
                            (p_assignment_id    => p_assignment_id,
                             p_period_start_dt  => p_period_start_date,
                             p_period_end_dt    => p_period_end_date,
                             p_unit_of_measure  => l_unit_of_measure);
End if;
--
hr_utility.set_location('Leaving:'||l_proc, 10);
--
RETURN l_assign_commitment;
--
Exception When others then
  --
  hr_utility.set_location('Exception:'||l_proc, 15);

  raise;
  --
End get_assignment_commitment;
--
-----------------------------------------------------------------------
--
-- This function calculates only money actuals for a position
-- It is called from get budget commitment and get budget actuals
--
PROCEDURE get_pos_money_amounts
(
 p_budget_version_id         IN    pqh_budget_versions.budget_version_id%TYPE,
 p_position_id               IN    per_positions.position_id%TYPE,
 p_start_date                IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date                  IN    pqh_budgets.budget_end_date%TYPE,
 p_actual_amount            OUT NOCOPY    number,
 p_commitment_amount        OUT NOCOPY    number,
 p_total_amount             OUT NOCOPY    number
) IS
--
--
CURSOR csr_pos_assg is
Select distinct ASSG.assignment_id
  From per_all_assignments_f ASSG
 Where ASSG.position_id           = p_position_id
   AND ASSG.effective_end_date   >= p_start_date
   AND ASSG.effective_start_date <= p_end_date;
--
l_position_id               pqh_budget_details.position_id%type;
l_position_name             hr_all_positions_f.name%type := NULL;
l_assignment_id             per_all_assignments_f.assignment_id%type;
l_last_actuals_date         per_time_periods.end_date%type;
--
l_budget_id                 pqh_budgets.budget_id%type := NULL;
--
l_unit_of_measure           per_shared_types.system_type_cd%type;
--
l_assignment_actuals        number := 0;
l_assignment_commitment     number := 0;
l_assignment_total          number := 0;
--
l_position_actuals          number := 0;
l_position_commitment       number := 0;
l_position_total            number := 0;
--

l_proc        varchar2(72) := g_package||'get_pos_money_amounts';
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
/*2716884*/
If p_budget_version_id IS NOT NULL then
   --
   Validate_budget(p_budget_version_id  =>  p_budget_version_id,
                   p_budget_id          =>  l_budget_id);
End if;

      --
      -- Use get_pos_money_total for Total
      --
          --
          l_position_actuals :=
           pqh_bdgt_actual_cmmtmnt_pkg.get_pos_money_total9
           (
            p_budget_version_id      =>p_budget_version_id,
            p_position_id            =>p_position_id,
            p_actuals_start_date     =>p_start_date,
            p_actuals_end_date       =>p_end_date
           -- p_ex_assignment_id       =>p_ex_assignment_id
           );
          --


  for i in csr_pos_assg loop
     l_assignment_id := i.assignment_id;
     --
     l_assignment_total := 0;
     -- l_assignment_actuals := 0;
     l_assignment_commitment := 0;
     l_last_actuals_date := NULL;
     --
     -- get actuals for the assignment and the last payroll run date

     -- for the assignment.
     --
      --
      -- Use get_pos_money_total for Total
      --
     --
     /* l_assignment_actuals := get_assign_money_actuals
                   ( p_budget_id          => l_budget_id, -- 2716884
                     p_assignment_id      => l_assignment_id,
                     p_element_type_id    => NULL,
                     p_actuals_start_date => p_start_date,
                     p_actuals_end_date   => p_end_date,
                     p_last_payroll_dt    => l_last_actuals_date
                    );                                                                              */
     --
     l_last_actuals_date := get_last_payroll_dt(l_assignment_id,
                              p_start_date, p_end_date);

     hr_utility.set_location('Assignment Actual:'||l_assignment_actuals,10);
     hr_utility.set_location('Last Actual Date :'||l_last_actuals_date, 20);
     --
     IF  l_last_actuals_date IS NULL  OR
         l_last_actuals_date <= p_start_date THEN
         --
         -- payroll has never been run for the assignemnr. So actual is zero
         --
         l_assignment_actuals := 0;
         --
         l_assignment_commitment := get_assign_money_cmmtmnt
                            (p_assignment_id      => l_assignment_id ,
                             p_budget_version_id  => p_budget_version_id,
                             p_element_type_id    => NULL,
                             p_period_start_date  => p_start_date,
                             p_period_end_date    => p_end_date
                            );
          --
          hr_utility.set_location('Assignment Commitment : '||l_assignment_commitment, 30);
          --
      ELSIF l_last_actuals_date >= p_end_date then
          --
          -- Actuals is available beyond the required period end date .
          -- So commitment is 0.
          --
          l_assignment_commitment := 0;
          --
       ELSE
          --
          -- payroll has been run for the position. calculate commitment
          -- from the next day of the last payroll run.
          --
          l_assignment_commitment := get_assign_money_cmmtmnt
                          (p_assignment_id      => l_assignment_id ,
                           p_budget_version_id  => p_budget_version_id,
                           p_element_type_id    => NULL,
                           p_period_start_date  => l_last_actuals_date + 1,
                           p_period_end_date    => p_end_date
                          );
           --
           hr_utility.set_location('Assignment Commitment : '||l_assignment_commitment, 40);
           --
       END IF;
       --
       -- Total up assignment commitment and actual information.
       --
       -- l_assignment_total := NVL(l_assignment_actuals,0) + NVL(l_assignment_commitment,0);
       --
       -- Total up position commitment and actuals info
       --
       l_position_commitment := l_position_commitment + NVL(l_assignment_commitment,0);
       --
       --l_position_actuals := l_position_actuals + NVL(l_assignment_actuals,0);
       --
       --l_position_total := l_position_total + l_assignment_total;
       --
   End Loop;
       l_position_total := l_position_actuals + l_position_commitment;
   --
   hr_utility.set_location('All assignments processed',50);
   -- Return the  actuals , commitment  and total
   --
   p_total_amount :=  l_position_total;
   --
   p_commitment_amount := l_position_commitment;
   --
   p_actual_amount :=  l_position_actuals;
   --
EXCEPTION
      WHEN OTHERS THEN
        p_actual_amount            := null;
        p_commitment_amount        := null;
        p_total_amount             := null;
        hr_utility.set_location('Exception :'||l_proc,60);
        hr_utility.raise_error;
--
End;
--
-----------------------------------------------------------------------
function get_actual_hours(p_assignment_id  in number
			 ,p_asg_start_date in date default sysdate
			 ,p_start_date     in date default sysdate
			 ,p_end_date       in date default sysdate
			 ,p_effective_date in date default sysdate
			  ) RETURN NUMBER IS
---
l_total_weeks 		number := 0;
l_hours_per_day		number := 0;
l_total_hours		number := 0;
l_remaining_days        number(1) := 0;
l_position_id           number;
l_organization_id       number;
l_bg_id                 number;
l_proc 			varchar2(60) := g_package||'get_actual_hours';

Cursor c_pos_freq(p_position_id number) Is
Select frequency , working_hours
  From hr_all_positions_f
 Where p_effective_date between effective_start_date and effective_end_date
  And  position_id    = p_position_id;

--frequency, workinig_hours of organization
Cursor c_org_freq(p_organization_id number) Is
SELECT O2.ORG_INFORMATION4 , O2.ORG_INFORMATION3
FROM HR_ORGANIZATION_INFORMATION O2
WHERE O2.ORG_INFORMATION_CONTEXT = 'Work Day Information'
AND O2.organization_id = p_organization_id;

Cursor c_bg_freq(p_bg_id number) Is
SELECT O2.ORG_INFORMATION4 , O2.ORG_INFORMATION3
FROM HR_ORGANIZATION_INFORMATION O2
WHERE O2.ORG_INFORMATION_CONTEXT = 'Work Day Information'
AND O2.organization_id = p_bg_id;

cursor c_assg is
select effective_start_date, effective_end_date,frequency, normal_hours, time_normal_start, time_normal_finish,
       position_id,organization_id,business_group_id
  from per_all_assignments_f
 where p_assignment_id = assignment_id
   and effective_start_date = p_asg_start_date;

l_frequency     	per_all_assignments_f.frequency%Type;
l_normal_hours  	per_all_assignments_f.normal_hours%Type;
l_assignment_id 	per_all_assignments_f.assignment_id%Type;
l_bg_normal_day_hours	per_all_assignments_f.normal_hours%Type;
l_normal_day_hours	per_all_assignments_f.normal_hours%Type;
l_actual_start_date    	date;
l_actual_end_date      	date;
l_start_date		date;
l_end_date		date;
l_assg_start_time  	varchar2(5);
l_assg_end_time    	varchar2(5);
l_day_of_date		varchar2(1);
l_days_removed		number(1) := 0;

Begin
   hr_utility.set_location('Entering:'||l_proc, 5);
   Open c_assg;
   Fetch c_assg Into l_start_date, l_end_date, l_frequency,
                     l_normal_hours, l_assg_start_time, l_assg_end_time,
                     l_position_id, l_organization_id, l_bg_id;
   if c_assg%notfound then
      close c_assg;
      return null;
   end if;
   close c_assg;
   hr_utility.set_location('l_assignment_id:'||l_assignment_id, 6);

   l_actual_start_date := greatest(l_start_date, p_start_date);
   l_actual_end_date   := least(l_end_date, p_end_date);

   hr_utility.set_location('l_normal_day_hours:'||l_normal_day_hours, 7);
   -- Get the total number of weeks in the date range
   l_total_weeks := trunc(((l_actual_end_date - l_actual_start_date) + 1)/7);
   -- Get the remaining days
   l_remaining_days := mod((l_actual_end_date - l_actual_start_date) + 1, 7);
   -- Get the total weekend days in the remaining days

   For i in 1..l_remaining_days Loop
       l_day_of_date := to_char(l_actual_end_date - (i - 1),'D');
       -- Sundays and Saturdays are not considered in the remaining days
       If l_day_of_date in ('1','7') Then
          l_days_removed := nvl(l_days_removed,0) + 1;
       End if;
   End Loop;

   l_remaining_days := (l_remaining_days - l_days_removed);

   If l_frequency is null and l_normal_hours is null Then
      if l_position_id is not null then
         Open c_pos_freq(l_position_id);
         Fetch c_pos_freq Into l_frequency, l_normal_hours;
         Close c_pos_freq;
      end if;
      If l_frequency is null and l_normal_hours is null Then
         Open c_org_freq(l_organization_id);
         Fetch c_org_freq Into l_frequency, l_normal_hours;
         Close c_org_freq;
      end if;
      If l_frequency is null and l_normal_hours is null Then
         Open c_bg_freq(l_bg_id);
         Fetch c_bg_freq Into l_frequency, l_normal_hours;
         Close c_bg_freq;
      end if;
   end If;
   hr_utility.set_location('l_frequency:'||l_frequency ||' l_normal_hours:'||l_normal_hours, 8);
   If (l_frequency is not null and l_normal_hours is not null) Then
      If l_frequency in ('HO','H') Then
         l_hours_per_day := (l_normal_hours * 8); -- taking 8 hrs/day
      Elsif l_frequency = 'D' Then
         l_hours_per_day := l_normal_hours;
      Elsif l_frequency = 'W' Then
         l_hours_per_day := (l_normal_hours/5); -- taking 5 days per week
      Elsif l_frequency = 'M' Then
         l_hours_per_day := (l_normal_hours/160); -- taking 160 hours per month
      Else
         l_hours_per_day := 0;
      End If;
        -- Again convert days into weeks to take care of weekends.
      l_total_hours := (l_hours_per_day * 5) * l_total_weeks + (l_hours_per_day * l_remaining_days);
   Else
      l_total_hours := (8 * 5 * l_total_weeks) + (8 * l_remaining_days);
      -- taking 8 hours per day as default.
   End If;
   hr_utility.set_location('l_total_hours:'||l_total_hours, 8);
   RETURN (l_total_hours);
Exception
    when others then
        hr_utility.set_location('Exception :'||l_proc,70);
        hr_utility.raise_error;
End;
--- Function to get the actual hours for an entity
---
FUNCTION get_actual_hours(p_business_grp_id  in number
			 ,p_position_id      in number default null
			 ,p_job_id           in number default null
			 ,p_grade_id         in number default null
			 ,p_organization_id  in number default null
			 ,p_start_date       in date default sysdate
			 ,p_end_date         in date default sysdate
			 ,p_effective_date   in date default sysdate
			  ) RETURN NUMBER IS

l_total_hours		number := 0;
l_asg_hours		number := 0;
l_proc 			varchar2(60) := g_package||'get_actual_hours';
--
-- if organization_id is passed, index will be used
--
cursor c_org_assg is
select assignment_id, effective_start_date
  from per_all_assignments_f
 where organization_id = p_organization_id
   and business_group_id = p_business_grp_id
   and effective_end_date   >= p_start_date
   and effective_start_date <= p_end_date ;

cursor c_position_assg is
select assignment_id, effective_start_date
  from per_all_assignments_f
 where p_position_id = position_id
   and effective_end_date   >= p_start_date
   and effective_start_date <= p_end_date ;

cursor c_job_assg is
select assignment_id, effective_start_date
  from per_all_assignments_f
 where p_job_id = job_id
   and effective_end_date   >= p_start_date
   and effective_start_date <= p_end_date ;

cursor c_grade_assg is
select assignment_id, effective_start_date
  from per_all_assignments_f
 where p_grade_id = grade_id
   and effective_end_date   >= p_start_date
   and effective_start_date <= p_end_date ;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_organization_id is not null then
     for i in c_org_assg loop
         l_asg_hours := get_actual_hours (p_assignment_id  => i.assignment_id,
                                          p_asg_start_date => i.effective_start_date,
                                          p_start_date     => p_start_date,
                                          p_end_date       => p_end_date,
                                          p_effective_date => p_effective_date);
         l_total_hours := nvl(l_total_hours,0) + nvl(l_asg_hours,0);
     end loop;
  elsif p_job_id is not null then
     for i in c_job_assg loop
         l_asg_hours := get_actual_hours (p_assignment_id  => i.assignment_id,
                                          p_asg_start_date => i.effective_start_date,
                                          p_start_date     => p_start_date,
                                          p_end_date       => p_end_date,
                                          p_effective_date => p_effective_date);
         l_total_hours := nvl(l_total_hours,0) + nvl(l_asg_hours,0);
     end loop;
  elsif p_position_id is not null then
     for i in c_position_assg loop
         l_asg_hours := get_actual_hours (p_assignment_id  => i.assignment_id,
                                          p_asg_start_date => i.effective_start_date,
                                          p_start_date     => p_start_date,
                                          p_end_date       => p_end_date,
                                          p_effective_date => p_effective_date);
         l_total_hours := nvl(l_total_hours,0) + nvl(l_asg_hours,0);
     end loop;
  elsif p_grade_id is not null then
     for i in c_grade_assg loop
         l_asg_hours := get_actual_hours (p_assignment_id  => i.assignment_id,
                                          p_asg_start_date => i.effective_start_date,
                                          p_start_date     => p_start_date,
                                          p_end_date       => p_end_date,
                                          p_effective_date => p_effective_date);
         l_total_hours := nvl(l_total_hours,0) + nvl(l_asg_hours,0);
     end loop;
  end if;
  RETURN (l_total_hours);
Exception
    when others then
        hr_utility.set_location('Exception :'||l_proc,70);
        hr_utility.raise_error;
End;
----------------------------------------------------------------
--
-- This function calculates commitment / actuals / total for a position.
-- It is called from get budget commitment and get budget actuals
--
Function get_pos_actual_and_cmmtmnt
(
 p_budget_version_id         IN    pqh_budget_versions.budget_version_id%TYPE,
 p_position_id               IN    per_positions.position_id%TYPE,
 p_element_type_id           IN    number  default NULL,
 p_start_date                IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date                  IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id        IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type                IN    varchar2,
 p_ex_assignment_id          IN    number default -1,
 p_validate                  IN    varchar2 default 'Y'
)
RETURN  NUMBER IS
--
--
CURSOR csr_pos_assg is
Select distinct ASSG.assignment_id
  From per_all_assignments_f ASSG
 Where ASSG.position_id           = p_position_id
   AND ASSG.effective_end_date   >= p_start_date
   AND ASSG.effective_start_date <= p_end_date
   AND ASSG.assignment_id <> p_ex_assignment_id;
--
l_position_id               pqh_budget_details.position_id%type;
l_position_name             hr_all_positions_f.name%type := NULL;
l_assignment_id             per_all_assignments_f.assignment_id%type;
l_last_actuals_date         per_time_periods.end_date%type;
--
l_budget_id                 pqh_budgets.budget_id%type := NULL;
--
l_unit_of_measure           per_shared_types.system_type_cd%type;
--
l_assignment_actuals        number := 0;
l_assignment_commitment     number := 0;
l_assignment_total          number := 0;
--
l_position_actuals          number := 0;
l_position_commitment       number := 0;
l_position_total            number := 0;

-- Following two Variable Declerations done by vevenkat for bug 2628563
l_business_group_id         hr_all_organization_units.Business_group_id%TYPE := hr_general.get_business_group_id;
l_effective_date            Date       := hr_general.effective_date;
--

l_proc        varchar2(72) := g_package||'get_pos_actual_and_cmmtmnt';
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  IF ( p_validate = 'Y') THEN
  --
  --
  -- CHECK IF THIS IS A VALID BUDGET .
  --
  Validate_budget(p_budget_version_id => p_budget_version_id,
                  p_budget_id         => l_budget_id);
  --
  -- CHECK IF THIS IS A VALID POSITION . ALSO DOES THIS POSITION
  -- BELONG IN THE PASSED BUDGET.
  --
  Validate_position(p_budget_version_id      => p_budget_version_id,
                   p_position_id             => p_position_id);
  --
  Validate_uom_in_budget(p_unit_of_measure_id    => p_unit_of_measure_id,
                          p_budget_id             => l_budget_id);
  --
  -- Validate if valid dates have been passed.
  --
  If p_value_type = 'A' OR p_value_type = 'T' then
  --
     Validate_actuals_dates(p_actuals_start_dt => p_start_date,
                            p_actuals_end_dt   => p_end_date,
                            p_budget_id        => l_budget_id);
  --
  ElsIf p_value_type = 'C' OR p_value_type = 'T' then
  --
   hr_utility.set_location('Dates for Commitment Calc: '||p_start_date||' - '||p_end_date, 61);
     Validate_commitment_dates(p_cmmtmnt_start_dt => p_start_date,
                               p_cmmtmnt_end_dt   => p_end_date,
                               p_budget_id        => l_budget_id);
  --
  Else
  --
     Return 0;
  --

  End if;
  END IF;
  --
  --
  -- Validate unit of measure.
  --
  Validate_unit_of_measure(p_unit_of_measure_id    => p_unit_of_measure_id,
                           p_unit_of_measure_desc  => l_unit_of_measure);
  --
  --
  If l_unit_of_measure = 'MONEY' then
      --
      -- calculate actuals and commitment for each assignment.
      --
      for i in csr_pos_assg Loop
         l_assignment_id := i.assignment_id;
         --
hr_utility.set_location('Assignments found: '||l_assignment_id, 62);
         l_assignment_total := 0;
         l_assignment_actuals := 0;
         l_assignment_commitment := 0;
         l_last_actuals_date := NULL;
         --
         -- get actuals for the assignment and the last payroll run date

         -- for the assignment.
         --
         If p_value_type = 'A' OR p_value_type = 'T' then
            l_assignment_actuals := get_assign_money_actuals
                   ( p_budget_id          => l_budget_id, /*2716884*/
                     p_assignment_id      => l_assignment_id,
                     p_element_type_id    => p_element_type_id,
                     p_actuals_start_date => p_start_date,
                     p_actuals_end_date   => p_end_date,
                     p_last_payroll_dt    => l_last_actuals_date
                    );
         --
         hr_utility.set_location('Assignment Actual:'||l_assignment_actuals,10);
         hr_utility.set_location('Last Actual Date :'||l_last_actuals_date, 20);
         --
         l_position_actuals    := l_position_actuals    + NVL(l_assignment_actuals,0);
         End If;

         If p_value_type in ('C','T') then
         -- Get last_actuals_date only if 'C' (in case of T, it is already evaluated
          if ( p_value_type = 'C') then
               l_last_actuals_date := get_last_payroll_dt (l_assignment_id, p_start_date, p_end_date);
          end if;
         hr_utility.set_location('Last Actual Date: '||to_char(l_last_actuals_date)||' - '||to_char(p_start_date), 63);
         IF  (l_last_actuals_date IS NULL  OR
              l_last_actuals_date <= p_start_date ) THEN
             --
             -- payroll has never been run for the position. So actual is zero
             --
             l_assignment_actuals := 0;
             --
             l_assignment_commitment := get_assign_money_cmmtmnt
                            (p_assignment_id      => l_assignment_id ,
                             p_budget_version_id  => p_budget_version_id,
                             p_element_type_id    => p_element_type_id,
                             p_period_start_date  => p_start_date,
                             p_period_end_date    => p_end_date
                            );
             --
             hr_utility.set_location('Assignment Commitment : '||l_assignment_commitment, 30);
             --
         ELSIF l_last_actuals_date >= p_end_date then
             --
             -- Actuals is available beyond the required period end date .
             -- So commitment is 0.
             --
             l_assignment_commitment := 0;
            --
         ELSE
           hr_utility.set_location('Payroll has run..: '||to_char(l_last_actuals_date+1)||' - '||to_char(p_end_date), 64);
             --
             -- payroll has been run for the position. calculate commitment
             -- from the next day of the last payroll run.
             --
             l_assignment_commitment := get_assign_money_cmmtmnt
                          (p_assignment_id      => l_assignment_id ,
                           p_budget_version_id  => p_budget_version_id,
                           p_element_type_id    => p_element_type_id,
                           p_period_start_date  => l_last_actuals_date + 1,
                           p_period_end_date    => p_end_date
                          );
             --
             hr_utility.set_location('Assignment Commitment : '||l_assignment_commitment, 40);
             --
         END IF;
         l_position_commitment := l_position_commitment + NVL(l_assignment_commitment,0);
         End If;

         If p_value_type = 'T' then
         --
         l_position_total      := l_position_total + NVL(l_assignment_actuals,0) + NVL(l_assignment_commitment,0);
         --
         End If;
       End Loop;
       --
       hr_utility.set_location('All assignments processed',50);

       --
       --
       -- Return the  actuals or commitment  or total
       -- depending on what value type was passed.
       --
       If p_value_type = 'T' then
          --
          RETURN l_position_total;
          --
       Elsif p_value_type = 'C' then
          --
          hr_utility.set_location('Returning Commitment amount: '||l_position_commitment,65);
          RETURN l_position_commitment;
          --
       Elsif p_value_type = 'A' then
          --
          RETURN l_position_actuals;
          --
       Else
          --
          RETURN 0;
          --
       End if;

       --
       -- Added the If conditions for HOURS for bug 2628563
   Elsif l_unit_of_measure = 'HOURS' then

         l_position_total := get_actual_hours( p_business_grp_id  => l_business_group_id
					    ,p_position_id      => p_position_id
					    ,p_job_id           => to_number(NULL)
					    ,p_grade_id         => to_number(NULL)
					    ,p_organization_id  => to_number(NULL)
					    ,p_start_date       => p_start_date
					    ,p_end_date         => p_end_date
					    ,p_effective_date   => l_effective_date);

   Else
       --
       l_position_total := get_pos_budget_values
                            (p_position_id      => p_position_id,
                             p_period_start_dt  => p_start_date,
                             p_period_end_dt    => p_end_date,
                             p_unit_of_measure  => l_unit_of_measure);
       --
   End if;
   --
   RETURN l_position_total;
   --

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_location('Exception :'||l_proc,60);
        hr_utility.set_location(sqlerrm,99);
        hr_utility.raise_error;

End;

--
--
-- This function calculates commitment / actuals / total for an entity.
-- It is called from get budget commitment and get budget actuals
--
Function get_ent_actual_and_cmmtmnt
(
 p_budget_version_id         IN    pqh_budget_versions.budget_version_id%TYPE,
 p_budgeted_entity_cd	     IN    pqh_budgets.budgeted_entity_cd%TYPE,
 p_entity_id                 IN    pqh_budget_details.position_id%TYPE,
 p_element_type_id           IN    number  default NULL,
 p_start_date                IN    pqh_budgets.budget_start_date%TYPE,
 p_end_date                  IN    pqh_budgets.budget_end_date%TYPE,
 p_unit_of_measure_id        IN    pqh_budgets.budget_unit1_id%TYPE,
 p_value_type                IN    varchar2
)
RETURN  NUMBER IS
--
--
CURSOR csr_pos_assg (p_business_group_id number) is
Select distinct ASSG.assignment_id
  From per_all_assignments_f ASSG
 Where ASSG.position_id           = p_entity_id
   and business_group_id          = p_business_group_id
   AND ASSG.effective_end_date   >= p_start_date
   AND ASSG.effective_start_date <= p_end_date;
--
CURSOR csr_job_assg(p_business_group_id number)  is
Select distinct ASSG.assignment_id
  From per_all_assignments_f ASSG
 Where ASSG.job_id                = p_entity_id
   and business_group_id          = p_business_group_id
   AND ASSG.effective_end_date   >= p_start_date
   AND ASSG.effective_start_date <= p_end_date;
--
CURSOR csr_grade_assg(p_business_group_id number) is
Select distinct ASSG.assignment_id
  From per_all_assignments_f ASSG
 Where ASSG.grade_id              = p_entity_id
   and business_group_id          = p_business_group_id
   AND ASSG.effective_end_date   >= p_start_date
   AND ASSG.effective_start_date <= p_end_date ;
--
CURSOR csr_org_assg(p_business_group_id number) is
Select distinct ASSG.assignment_id
  From per_all_assignments_f ASSG
 Where ASSG.organization_id       = p_entity_id
   and business_group_id          = p_business_group_id
   AND ASSG.effective_end_date   >= p_start_date
   AND ASSG.effective_start_date <= p_end_date;
--

l_assignment_id             per_all_assignments_f.assignment_id%type;
l_business_group_id         per_all_assignments_f.business_group_id%type;
l_last_actuals_date         per_time_periods.end_date%type;
--
l_budget_id                 pqh_budgets.budget_id%type := NULL;
--
l_unit_of_measure           per_shared_types.system_type_cd%type;
--
l_assignment_actuals        number := 0;
l_assignment_commitment     number := 0;
l_assignment_total          number := 0;
--
l_entity_actuals          number := 0;
l_entity_commitment       number := 0;
l_entity_total            number := 0;
l_effective_date	  date;

CURSOR csr_bg_id is
Select business_group_id
  From pqh_budgets
 Where budget_id = l_budget_id;

--
l_proc        varchar2(72) := g_package||'get_ent_actual_and_cmmtmnt';
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- CHECK IF THIS IS A VALID BUDGET .
  --
  Validate_budget(p_budget_version_id => p_budget_version_id,
                  p_budget_id         => l_budget_id);

  If p_budgeted_entity_cd = 'POSITION' Then
  --
  -- CHECK IF THIS IS A VALID POSITION AND ALSO DOES THIS POSITION
  -- BELONG IN THE PASSED BUDGET.
  --
     Validate_position(p_budget_version_id      => p_budget_version_id,
                       p_position_id            => p_entity_id);


  Elsif p_budgeted_entity_cd = 'JOB' Then
  --
  -- CHECK IF THIS IS A VALID JOB AND ALSO DOES THIS JOB
  -- BELONG IN THE PASSED BUDGET.
  --
     Validate_job(p_budget_version_id      => p_budget_version_id,
                  p_job_id                 => p_entity_id);

  Elsif p_budgeted_entity_cd = 'GRADE' Then
  --
  -- CHECK IF THIS IS A VALID GRADE AND ALSO DOES THIS GRADE
  -- BELONG IN THE PASSED BUDGET.
  --
     Validate_grade(p_budget_version_id      => p_budget_version_id,
                    p_grade_id               => p_entity_id);

  Elsif p_budgeted_entity_cd = 'ORGANIZATION' Then
  --
  -- CHECK IF THIS IS A VALID ORGANIZATION AND ALSO DOES THIS ORGANIZATION
  -- BELONG IN THE PASSED BUDGET.
  --
     Validate_organization(p_budget_version_id      => p_budget_version_id,
                           p_organization_id        => p_entity_id);

  End if;
  --
  --
  -- Validate unit of measure.
  --
  Validate_unit_of_measure(p_unit_of_measure_id    => p_unit_of_measure_id,

                           p_unit_of_measure_desc  => l_unit_of_measure);
  --
  Validate_uom_in_budget(p_unit_of_measure_id    => p_unit_of_measure_id,
                         p_budget_id             => l_budget_id);
  --
  -- Validate if valid dates have been passed.
  --
  If p_value_type = 'A' OR p_value_type = 'T' then
  --
     Validate_actuals_dates(p_actuals_start_dt => p_start_date,
                            p_actuals_end_dt   => p_end_date,
                            p_budget_id        => l_budget_id);
  --
  ElsIf p_value_type = 'C' OR p_value_type = 'T' then
  --
     Validate_commitment_dates(p_cmmtmnt_start_dt => p_start_date,
                               p_cmmtmnt_end_dt   => p_end_date,
                               p_budget_id        => l_budget_id);
  --
  Else
  --
     Return 0;
  --
  End if;
  l_effective_date := hr_general.effective_date;
  l_business_group_id := hr_general.get_business_group_id;
  If l_business_group_id is null Then
    Open csr_bg_id;
    Fetch csr_bg_id into l_business_group_id;
    Close csr_bg_id;
  End if;
  --
  --
  If l_unit_of_measure = 'MONEY' then
      --
      -- calculate actuals and commitment for each assignment.
      --
      If p_budgeted_entity_cd = 'POSITION' Then
	  for i in csr_pos_assg(l_business_group_id) loop
	     l_assignment_id := i.assignment_id;
	     --
	     l_assignment_total := 0;
	     l_assignment_actuals := 0;
	     l_assignment_commitment := 0;
	     l_last_actuals_date := NULL;
	     --
	     -- get actuals for the assignment and the last payroll run date

	     -- for the assignment.
	     --
	     l_assignment_actuals := get_assign_money_actuals
		       ( p_budget_id          => l_budget_id,   /*2716884*/
                         p_assignment_id      => l_assignment_id,
			 p_element_type_id    => p_element_type_id,
			 p_actuals_start_date => p_start_date,
			 p_actuals_end_date   => p_end_date,
			 p_last_payroll_dt    => l_last_actuals_date
			);
	     --
	     hr_utility.set_location('Assignment Actual:'||l_assignment_actuals,10);
	     hr_utility.set_location('Last Actual Date :'||l_last_actuals_date, 20);
	     --
	     IF  l_last_actuals_date IS NULL  OR
		 l_last_actuals_date <= p_start_date THEN
		 --
		 -- payroll has never been run for the position. So actual is zero
		 --
		 l_assignment_actuals := 0;
		 --
		 l_assignment_commitment := get_assign_money_cmmtmnt
				(p_assignment_id      => l_assignment_id ,
				 p_budget_version_id  => p_budget_version_id,
				 p_element_type_id    => p_element_type_id,
				 p_period_start_date  => p_start_date,
				 p_period_end_date    => p_end_date
				);
		 --
		 hr_utility.set_location('Assignment Commitment : '||l_assignment_commitment, 30);
		 --
	     ELSIF l_last_actuals_date >= p_end_date then
		 --
		 -- Actuals is available beyond the required period end date .
		 -- So commitment is 0.
		 --
		 l_assignment_commitment := 0;
		--
	     ELSE
		 --
		 -- payroll has been run for the position. calculate commitment
		 -- from the next day of the last payroll run.
		 --
		 l_assignment_commitment := get_assign_money_cmmtmnt
			      (p_assignment_id      => l_assignment_id ,
			       p_budget_version_id  => p_budget_version_id,
			       p_element_type_id    => p_element_type_id,
			       p_period_start_date  => l_last_actuals_date + 1,
			       p_period_end_date    => p_end_date
			      );
		 --
		 hr_utility.set_location('Assignment Commitment : '||l_assignment_commitment, 40);
		 --
	     END IF;
	     --
	     -- Total up assignment commitment and actual information.
	     --
	     l_assignment_total := NVL(l_assignment_actuals,0) + NVL(l_assignment_commitment,0);
	     --
	     -- Total up position commitment and actuals info
	     --
	     l_entity_commitment := l_entity_commitment + NVL(l_assignment_commitment,0);
	     --
	     l_entity_actuals := l_entity_actuals + NVL(l_assignment_actuals,0);
	     --
	     l_entity_total := l_entity_total + l_assignment_total;
	     --
	   End Loop;
	   --
	   hr_utility.set_location('All assignments processed',50);
       Elsif p_budgeted_entity_cd = 'JOB' Then
	  for i in csr_job_assg(l_business_group_id) loop
	     l_assignment_id := i.assignment_id;
	     --
	     l_assignment_total := 0;
	     l_assignment_actuals := 0;
	     l_assignment_commitment := 0;
	     l_last_actuals_date := NULL;
	     --
	     -- get actuals for the assignment and the last payroll run date

	     -- for the assignment.
	     --
	     l_assignment_actuals := get_assign_money_actuals
		       ( p_budget_id          => l_budget_id,  /*2716884*/
                         p_assignment_id      => l_assignment_id,
			 p_element_type_id    => p_element_type_id,
			 p_actuals_start_date => p_start_date,
			 p_actuals_end_date   => p_end_date,
			 p_last_payroll_dt    => l_last_actuals_date
			);
	     --
	     hr_utility.set_location('Assignment Actual:'||l_assignment_actuals,10);
	     hr_utility.set_location('Last Actual Date :'||l_last_actuals_date, 20);
	     --
	     IF  l_last_actuals_date IS NULL  OR
		 l_last_actuals_date <= p_start_date THEN
		 --
		 -- payroll has never been run for the job. So actual is zero
		 --
		 l_assignment_actuals := 0;
		 --
		 l_assignment_commitment := get_assign_money_cmmtmnt
				(p_assignment_id      => l_assignment_id ,
				 p_budget_version_id  => p_budget_version_id,
				 p_element_type_id    => p_element_type_id,
				 p_period_start_date  => p_start_date,
				 p_period_end_date    => p_end_date
				);
		 --
		 hr_utility.set_location('Assignment Commitment : '||l_assignment_commitment, 30);
		 --
	     ELSIF l_last_actuals_date >= p_end_date then
		 --
		 -- Actuals is available beyond the required period end date .
		 -- So commitment is 0.
		 --
		 l_assignment_commitment := 0;
		--
	     ELSE
		 --
		 -- payroll has been run for the job. calculate commitment
		 -- from the next day of the last payroll run.
		 --
		 l_assignment_commitment := get_assign_money_cmmtmnt
			      (p_assignment_id      => l_assignment_id ,
			       p_budget_version_id  => p_budget_version_id,
			       p_element_type_id    => p_element_type_id,
			       p_period_start_date  => l_last_actuals_date + 1,
			       p_period_end_date    => p_end_date
			      );
		 --
		 hr_utility.set_location('Assignment Commitment : '||l_assignment_commitment, 40);
		 --
	     END IF;
	     --
	     -- Total up assignment commitment and actual information.
	     --
	     l_assignment_total := NVL(l_assignment_actuals,0) + NVL(l_assignment_commitment,0);
	     --
	     -- Total up job commitment and actuals info
	     --
	     l_entity_commitment := l_entity_commitment + NVL(l_assignment_commitment,0);
	     --
	     l_entity_actuals := l_entity_actuals + NVL(l_assignment_actuals,0);
	     --
	     l_entity_total := l_entity_total + l_assignment_total;
	     --
	   End Loop;
	   --
	   hr_utility.set_location('All assignments processed',50);
       Elsif p_budgeted_entity_cd = 'GRADE' Then
	  for i in csr_grade_assg(l_business_group_id) loop
	     l_assignment_id := i.assignment_id;
	     --
	     l_assignment_total := 0;
	     l_assignment_actuals := 0;
	     l_assignment_commitment := 0;
	     l_last_actuals_date := NULL;
	     --
	     -- get actuals for the assignment and the last payroll run date

	     -- for the assignment.
	     --
	     l_assignment_actuals := get_assign_money_actuals
		       ( p_budget_id          => l_budget_id, /*2716884*/
                         p_assignment_id      => l_assignment_id,
			 p_element_type_id    => p_element_type_id,
			 p_actuals_start_date => p_start_date,
			 p_actuals_end_date   => p_end_date,
			 p_last_payroll_dt    => l_last_actuals_date
			);
	     --
	     hr_utility.set_location('Assignment Actual:'||l_assignment_actuals,10);
	     hr_utility.set_location('Last Actual Date :'||l_last_actuals_date, 20);
	     --
	     IF  l_last_actuals_date IS NULL  OR
		 l_last_actuals_date <= p_start_date THEN
		 --
		 -- payroll has never been run for the grade. So actual is zero
		 --
		 l_assignment_actuals := 0;
		 --
		 l_assignment_commitment := get_assign_money_cmmtmnt
				(p_assignment_id      => l_assignment_id ,
				 p_budget_version_id  => p_budget_version_id,
				 p_element_type_id    => p_element_type_id,
				 p_period_start_date  => p_start_date,
				 p_period_end_date    => p_end_date
				);
		 --
		 hr_utility.set_location('Assignment Commitment : '||l_assignment_commitment, 30);
		 --
	     ELSIF l_last_actuals_date >= p_end_date then
		 --
		 -- Actuals is available beyond the required period end date .
		 -- So commitment is 0.
		 --
		 l_assignment_commitment := 0;
		--
	     ELSE
		 --
		 -- payroll has been run for the grade. calculate commitment
		 -- from the next day of the last payroll run.
		 --
		 l_assignment_commitment := get_assign_money_cmmtmnt
			      (p_assignment_id      => l_assignment_id ,
			       p_budget_version_id  => p_budget_version_id,
			       p_element_type_id    => p_element_type_id,
			       p_period_start_date  => l_last_actuals_date + 1,
			       p_period_end_date    => p_end_date
			      );
		 --
		 hr_utility.set_location('Assignment Commitment : '||l_assignment_commitment, 40);
		 --
	     END IF;
	     --
	     -- Total up assignment commitment and actual information.
	     --
	     l_assignment_total := NVL(l_assignment_actuals,0) + NVL(l_assignment_commitment,0);
	     --
	     -- Total up grade commitment and actuals info
	     --
	     l_entity_commitment := l_entity_commitment + NVL(l_assignment_commitment,0);
	     --
	     l_entity_actuals := l_entity_actuals + NVL(l_assignment_actuals,0);
	     --
	     l_entity_total := l_entity_total + l_assignment_total;
	     --
	   End Loop;
	   --
	   hr_utility.set_location('All assignments processed',50);
       Elsif p_budgeted_entity_cd = 'ORGANIZATION' Then
	  for i in csr_org_assg(l_business_group_id) loop
	     l_assignment_id := i.assignment_id;

	     --
	     l_assignment_total := 0;
	     l_assignment_actuals := 0;
	     l_assignment_commitment := 0;
	     l_last_actuals_date := NULL;
	     --
	     -- get actuals for the assignment and the last payroll run date

	     -- for the assignment.
	     --
	     l_assignment_actuals := get_assign_money_actuals
		       ( p_budget_id          => l_budget_id, /*2716884*/
                         p_assignment_id      => l_assignment_id,
			 p_element_type_id    => p_element_type_id,
			 p_actuals_start_date => p_start_date,
			 p_actuals_end_date   => p_end_date,
			 p_last_payroll_dt    => l_last_actuals_date
			);
	     --
	     hr_utility.set_location('Assignment Actual:'||l_assignment_actuals,10);
	     hr_utility.set_location('Last Actual Date :'||l_last_actuals_date, 20);
	     --
	     IF  l_last_actuals_date IS NULL  OR
		 l_last_actuals_date <= p_start_date THEN
		 --
		 -- payroll has never been run for the organization. So actual is zero
		 --
		 l_assignment_actuals := 0;
		 --
		 l_assignment_commitment := get_assign_money_cmmtmnt
				(p_assignment_id      => l_assignment_id ,
				 p_budget_version_id  => p_budget_version_id,
				 p_element_type_id    => p_element_type_id,
				 p_period_start_date  => p_start_date,
				 p_period_end_date    => p_end_date
				);
		 --
		 hr_utility.set_location('Assignment Commitment : '||l_assignment_commitment, 30);
		 --
	     ELSIF l_last_actuals_date >= p_end_date then
		 --
		 -- Actuals is available beyond the required period end date .
		 -- So commitment is 0.
		 --
		 l_assignment_commitment := 0;
		--
	     ELSE
		 --
		 -- payroll has been run for the organization. calculate commitment
		 -- from the next day of the last payroll run.
		 --
		 l_assignment_commitment := get_assign_money_cmmtmnt
			      (p_assignment_id      => l_assignment_id ,
			       p_budget_version_id  => p_budget_version_id,
			       p_element_type_id    => p_element_type_id,
			       p_period_start_date  => l_last_actuals_date + 1,
			       p_period_end_date    => p_end_date
			      );
		 --
		 hr_utility.set_location('Assignment Commitment : '||l_assignment_commitment, 40);
		 --
	     END IF;
	     --
	     -- Total up assignment commitment and actual information.
	     --
	     l_assignment_total := NVL(l_assignment_actuals,0) + NVL(l_assignment_commitment,0);
	     --
	     -- Total up organization commitment and actuals info
	     --
	     l_entity_commitment := l_entity_commitment + NVL(l_assignment_commitment,0);
	     --
	     l_entity_actuals := l_entity_actuals + NVL(l_assignment_actuals,0);
	     --
	     l_entity_total := l_entity_total + l_assignment_total;
	     --
	   End Loop;
	   --
	   hr_utility.set_location('All assignments processed',50);
       End if;
       --
       -- Return the  actuals or commitment  or total
       -- depending on what value type was passed.
       --
       If p_value_type = 'T' then
          --
          RETURN l_entity_total;
          --
       Elsif p_value_type = 'C' then
          --
          RETURN l_entity_commitment;
          --
       Elsif p_value_type = 'A' then
          --
          RETURN l_entity_actuals;
          --
       Else
          --
          RETURN 0;
          --
       End if;
       --
   Elsif l_unit_of_measure = 'HOURS' then
      If p_budgeted_entity_cd = 'POSITION' Then
         l_entity_total := get_actual_hours( p_business_grp_id  => l_business_group_id
					    ,p_position_id      => p_entity_id
					    ,p_job_id           => to_number(NULL)
					    ,p_grade_id         => to_number(NULL)
					    ,p_organization_id  => to_number(NULL)
					    ,p_start_date       => p_start_date
					    ,p_end_date         => p_end_date
					    ,p_effective_date   => l_effective_date);
      Elsif p_budgeted_entity_cd = 'JOB' Then
         l_entity_total := get_actual_hours( p_business_grp_id  => l_business_group_id
					    ,p_job_id           => p_entity_id
					    ,p_grade_id         => to_number(NULL)
					    ,p_organization_id  => to_number(NULL)
					    ,p_position_id	=> to_number(NULL)
					    ,p_start_date       => p_start_date
					    ,p_end_date         => p_end_date
					    ,p_effective_date   => l_effective_date);
      Elsif p_budgeted_entity_cd = 'GRADE' Then
         l_entity_total := get_actual_hours( p_business_grp_id  => l_business_group_id
					    ,p_grade_id         => p_entity_id
					    ,p_position_id      => to_number(NULL)
					    ,p_organization_id  => to_number(NULL)
					    ,p_job_id		=> to_number(NULL)
					    ,p_start_date       => p_start_date
					    ,p_end_date         => p_end_date
					    ,p_effective_date   => l_effective_date);
      Elsif p_budgeted_entity_cd = 'ORGANIZATION' Then
         l_entity_total := get_actual_hours( p_business_grp_id  => l_business_group_id
					    ,p_organization_id  => p_entity_id
					    ,p_grade_id         => to_number(NULL)
					    ,p_position_id      => to_number(NULL)
					    ,p_job_id		=> to_number(NULL)
					    ,p_start_date       => p_start_date
					    ,p_end_date         => p_end_date
					    ,p_effective_date   => l_effective_date);
      End if;
   Else
      If p_budgeted_entity_cd = 'POSITION' Then
         l_entity_total := hr_discoverer.get_actual_budget_values
                             (p_bus_group_id     => l_business_group_id,
                              p_position_id      => p_entity_id,
                              p_job_id           => NULL,
                              p_grade_id         => NULL,
                              p_organization_id  => NULL,
                              p_start_date       => p_start_date,
                              p_end_date         => p_end_date,
                              p_unit             => l_unit_of_measure,
                              p_actual_val       => NULL);
      Elsif p_budgeted_entity_cd = 'JOB' Then
         l_entity_total := hr_discoverer.get_actual_budget_values
                             (p_bus_group_id     => l_business_group_id,
                              p_job_id           => p_entity_id,
                              p_grade_id         => NULL,
                              p_organization_id  => NULL,
                              p_position_id	 => NULL,
                              p_start_date       => p_start_date,
                              p_end_date         => p_end_date,
                              p_unit             => l_unit_of_measure,
                              p_actual_val       => NULL);
      Elsif p_budgeted_entity_cd = 'GRADE' Then
         l_entity_total := hr_discoverer.get_actual_budget_values
                             (p_bus_group_id     => l_business_group_id,
                              p_grade_id         => p_entity_id,
                              p_position_id      => NULL,
                              p_organization_id  => NULL,
                              p_job_id		 => NULL,
                              p_start_date       => p_start_date,
                              p_end_date         => p_end_date,
                              p_unit             => l_unit_of_measure,
                              p_actual_val       => NULL);
      Elsif p_budgeted_entity_cd = 'ORGANIZATION' Then
         l_entity_total := hr_discoverer.get_actual_budget_values
                             (p_bus_group_id     => l_business_group_id,
                              p_organization_id  => p_entity_id,
                              p_grade_id         => NULL,
                              p_position_id      => NULL,
                              p_job_id		 => NULL,
                              p_start_date       => p_start_date,
                              p_end_date         => p_end_date,
                              p_unit             => l_unit_of_measure,
                              p_actual_val       => NULL);
      End if;
       --
       --
   End if;
   --
   RETURN l_entity_total;
   --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_location('Exception :'||l_proc,60);
        hr_utility.raise_error;
End;
--
------------------------------------------------------------------------
-- The foll two functions return actuals and commitment for a budget
-- version respectively.
------------------------------------------------------------------------
--
-- This function returns the actuals of a budget version.
--
FUNCTION get_budget_actuals(p_budget_version_id  in  number,
                            p_period_start_date  in  date,
                            p_period_end_date    in  date,
                            p_unit_of_measure_id in  number)
RETURN NUMBER IS
--
l_position_actuals  number;
l_budget_actuals    number;
l_position_id          pqh_budget_details.position_id%type;
--
l_budget_id            pqh_budgets.budget_id%type := NULL;
l_unit_of_measure      per_shared_types.system_type_cd%type;
--
Cursor csr_positions_in_bdgt is
   Select Position_id
     From pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bdt.position_id IS NOT NULL;
--
l_proc        varchar2(72) := g_package||'get_budget_actuals';
--
Begin
--
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 -- Validate if the budget version is valid .
 --
 Validate_budget(p_budget_version_id  =>  p_budget_version_id,
                 p_budget_id          =>  l_budget_id);
 --
 -- Check if the input unit of measure is valid in per_shared_types.
 -- Also , check if the uom has been budgeted for in the budget.
 --
 Validate_unit_of_measure(p_unit_of_measure_id    => p_unit_of_measure_id,
                          p_unit_of_measure_desc  => l_unit_of_measure);


 Validate_uom_in_budget(p_unit_of_measure_id    => p_unit_of_measure_id,
                        p_budget_id             => l_budget_id);
 --
 Validate_actuals_dates(p_actuals_start_dt => p_period_start_date,
                            p_actuals_end_dt   => p_period_end_date,
                            p_budget_id        => l_budget_id);
  --
 l_budget_actuals := 0;
 --
 -- Break budget version into its comprising positions .Calculate the
 -- actuals for each position and sum it up to obtain budget actuals.
 --
 for i in csr_positions_in_bdgt loop
      l_position_actuals := get_pos_actual_and_cmmtmnt
           (p_budget_version_id  => p_budget_version_id,
            p_position_id        => i.position_id,
            p_start_date         => p_period_start_date,
            p_end_date           => p_period_end_date,
            p_unit_of_measure_id => p_unit_of_measure_id,
            p_value_type         => 'A');
      l_budget_actuals := nvl(l_budget_actuals,0) + nvl(l_position_actuals,0);
 End Loop;
 --
hr_utility.set_location('Leaving:'||l_proc, 10);
--
RETURN l_budget_actuals;
--
Exception When others then
  hr_utility.set_location('Exception:'||l_proc, 15);
  raise ;
  --
End;
--
--------------------------------------------------------------------
--
-- This function returns the commitment of a budget version.
--
FUNCTION get_budget_commitment(p_budget_version_id  in  number,
                               p_period_start_date  in  date,
                               p_period_end_date    in  date,
                               p_unit_of_measure_id in  number)
RETURN NUMBER
IS
--
l_position_commitment  number;
l_budget_commitment    number;
l_position_id          pqh_budget_details.position_id%type;
--
l_budget_id            pqh_budgets.budget_id%type := NULL;
l_unit_of_measure      per_shared_types.system_type_cd%type;
--

Cursor csr_positions_in_bdgt is
   Select Position_id
     From pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bdt.position_id IS NOT NULL;
--
l_proc        varchar2(72) := g_package||'get_budget_commitment';
--
Begin
--
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 -- Validate if the budget version is valid .
 --
 Validate_budget(p_budget_version_id  =>  p_budget_version_id,
                 p_budget_id          =>  l_budget_id);
 --
 -- Check if the input unit of measure is valid in per_shared_types.
 -- Also , check if the uom has been budgeted for in the budget.
 --
 Validate_unit_of_measure(p_unit_of_measure_id    => p_unit_of_measure_id,
                          p_unit_of_measure_desc  => l_unit_of_measure);


 Validate_uom_in_budget(p_unit_of_measure_id    => p_unit_of_measure_id,
                        p_budget_id             => l_budget_id);
 --
 Validate_commitment_dates(p_cmmtmnt_start_dt => p_period_start_date,
                               p_cmmtmnt_end_dt   => p_period_end_date,
                               p_budget_id        => l_budget_id);
 --
 l_budget_commitment := 0;
 --
 -- Break budget version into its comprising positions .Calculate the
 -- commitment for each position and sum it up to obtain budget commitment.
 --
 for i in csr_positions_in_bdgt loop
      l_position_commitment := get_pos_actual_and_cmmtmnt
           (p_budget_version_id  => p_budget_version_id,
            p_position_id        => i.position_id,
            p_start_date         => p_period_start_date,
            p_end_date           => p_period_end_date,
            p_unit_of_measure_id => p_unit_of_measure_id,
            p_value_type         => 'C');
      --
      l_budget_commitment := nvl(l_budget_commitment,0) + nvl(l_position_commitment,0);
      --
 End Loop;
hr_utility.set_location('Leaving:'||l_proc, 10);
--
RETURN l_budget_commitment;
--
Exception When others then
  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;
End;

-----------------------------------------------------------------------------

------------------------------------------------------------------------
-- The foll two overloaded functions return actuals and commitment for
-- a budget version respectively and for all entity types.
------------------------------------------------------------------------
--
-- This function returns the actuals of a budget version.
--
FUNCTION get_budget_actuals(p_budget_version_id  in  number,
			    p_budgeted_entity_cd in  varchar2,
                            p_period_start_date  in  date,
                            p_period_end_date    in  date,
                            p_unit_of_measure_id in  number)
RETURN NUMBER
IS
--
l_entity_actuals    number;
l_budget_actuals    number;
l_position_id       pqh_budget_details.position_id%type;
l_job_id       	    pqh_budget_details.position_id%type;
l_grade_id     	    pqh_budget_details.position_id%type;
l_organization_id   pqh_budget_details.position_id%type;
--
l_budget_id         pqh_budgets.budget_id%type := NULL;
l_unit_of_measure   per_shared_types.system_type_cd%type;
--

Cursor csr_positions_in_bdgt is
   Select Position_id
     From pqh_budgets bgt,pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_id		 = bgt.budget_id
      AND bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bgt.budgeted_entity_cd = 'POSITION';
--
Cursor csr_jobs_in_bdgt is
   Select job_id
     From pqh_budgets bgt,pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_id		 = bgt.budget_id
      AND bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bgt.budgeted_entity_cd = 'JOB';
--
Cursor csr_grades_in_bdgt is
   Select grade_id
     From pqh_budgets bgt,pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_id		 = bgt.budget_id
      AND bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bgt.budgeted_entity_cd = 'GRADE';
--
Cursor csr_orgs_in_bdgt is
   Select organization_id
     From pqh_budgets bgt,pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_id		 = bgt.budget_id
      AND bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bgt.budgeted_entity_cd = 'ORGANIZATION';

--
l_proc        varchar2(72) := g_package||'get_budget_actuals';
--
Begin
--
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 -- Validate if the budget version is valid .
 --
 Validate_budget(p_budget_version_id  =>  p_budget_version_id,
                 p_budget_id          =>  l_budget_id);
 --
 -- Check if the input unit of measure is valid in per_shared_types.
 -- Also , check if the uom has been budgeted for in the budget.
 --
 Validate_unit_of_measure(p_unit_of_measure_id    => p_unit_of_measure_id,
                          p_unit_of_measure_desc  => l_unit_of_measure);


 Validate_uom_in_budget(p_unit_of_measure_id    => p_unit_of_measure_id,
                        p_budget_id             => l_budget_id);
 --
 Validate_actuals_dates(p_actuals_start_dt => p_period_start_date,
                            p_actuals_end_dt   => p_period_end_date,
                            p_budget_id        => l_budget_id);
  --
 l_budget_actuals := 0;
 --
 -- Break budget version into its comprising positions .Calculate the
 -- actuals for each position and sum it up to obtain budget actuals.
 If p_budgeted_entity_cd = 'POSITION' Then
 --
     Open csr_positions_in_bdgt;
     --
     Loop
	  --
	  Fetch csr_positions_in_bdgt into l_position_id;
	  --
	  If csr_positions_in_bdgt%notfound then
	     Exit;
	  End if;
	  --

	  l_entity_actuals := 0;

	  --
	  l_entity_actuals := get_ent_actual_and_cmmtmnt
	       (p_budget_version_id  => p_budget_version_id,
	        p_budgeted_entity_cd => p_budgeted_entity_cd,
		p_entity_id          => l_position_id,
		p_start_date         => p_period_start_date,
		p_end_date           => p_period_end_date,
		p_unit_of_measure_id => p_unit_of_measure_id,
		p_value_type         => 'A');
	  --
	  l_budget_actuals := l_budget_actuals + l_entity_actuals;
	  --
     End Loop;
     --
     Close csr_positions_in_bdgt;

 Elsif p_budgeted_entity_cd = 'JOB' Then
 --
     Open csr_jobs_in_bdgt;
     --
     Loop
	  --
	  Fetch csr_jobs_in_bdgt into l_job_id;
	  --
	  If csr_jobs_in_bdgt%notfound then
	     Exit;
	  End if;
	  --

	  l_entity_actuals := 0;

	  --
	  l_entity_actuals := get_ent_actual_and_cmmtmnt
	       (p_budget_version_id  => p_budget_version_id,
	        p_budgeted_entity_cd => p_budgeted_entity_cd,
		p_entity_id          => l_job_id,
		p_start_date         => p_period_start_date,
		p_end_date           => p_period_end_date,
		p_unit_of_measure_id => p_unit_of_measure_id,
		p_value_type         => 'A');
	  --
	  l_budget_actuals := l_budget_actuals + l_entity_actuals;
          --
     End Loop;
     --
     Close csr_jobs_in_bdgt;
 --
 Elsif p_budgeted_entity_cd = 'GRADE' Then
 --
     Open csr_grades_in_bdgt;
     --
     Loop
	  --
	  Fetch csr_grades_in_bdgt into l_grade_id;
	  --
	  If csr_grades_in_bdgt%notfound then
	     Exit;
	  End if;
	  --

	  l_entity_actuals := 0;

	  --
	  l_entity_actuals := get_ent_actual_and_cmmtmnt
	       (p_budget_version_id  => p_budget_version_id,
	        p_budgeted_entity_cd => p_budgeted_entity_cd,
		p_entity_id          => l_grade_id,
		p_start_date         => p_period_start_date,
		p_end_date           => p_period_end_date,
		p_unit_of_measure_id => p_unit_of_measure_id,
		p_value_type         => 'A');
	  --
	  l_budget_actuals := l_budget_actuals + l_entity_actuals;
          --
     End Loop;
     --
     Close csr_grades_in_bdgt;
 --
 Elsif p_budgeted_entity_cd = 'ORGANIZATION' Then
 --
     Open csr_orgs_in_bdgt;
     --
     Loop
	  --
	  Fetch csr_orgs_in_bdgt into l_organization_id;
	  --
	  If csr_orgs_in_bdgt%notfound then
	     Exit;
	  End if;
	  --

	  l_entity_actuals := 0;

	  --
	  l_entity_actuals := get_ent_actual_and_cmmtmnt
	       (p_budget_version_id  => p_budget_version_id,
	        p_budgeted_entity_cd => p_budgeted_entity_cd,
		p_entity_id          => l_organization_id,
		p_start_date         => p_period_start_date,
		p_end_date           => p_period_end_date,
		p_unit_of_measure_id => p_unit_of_measure_id,
		p_value_type         => 'A');
	  --
	  l_budget_actuals := l_budget_actuals + l_entity_actuals;
          --
     End Loop;
     --
     Close csr_orgs_in_bdgt;
 --
End If;
--
hr_utility.set_location('Leaving:'||l_proc, 10);
--
RETURN l_budget_actuals;
--
Exception When others then
  --

  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;
  --
End;
--
--------------------------------------------------------------------
--
-- This function returns the commitment of a budget version.
--
FUNCTION get_budget_commitment(p_budget_version_id  in  number,
			       p_budgeted_entity_cd in  varchar2,
                               p_period_start_date  in  date,
                               p_period_end_date    in  date,
                               p_unit_of_measure_id in  number)
RETURN NUMBER
IS
--
l_entity_commitment    number;
l_budget_commitment    number;
l_position_id          pqh_budget_details.position_id%type;
l_job_id       	       pqh_budget_details.position_id%type;
l_grade_id     	       pqh_budget_details.position_id%type;
l_organization_id      pqh_budget_details.position_id%type;
--
l_budget_id            pqh_budgets.budget_id%type := NULL;
l_unit_of_measure      per_shared_types.system_type_cd%type;
--

Cursor csr_positions_in_bdgt is
   Select Position_id
     From pqh_budgets bgt,pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_id		 = bgt.budget_id
      AND bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bgt.budgeted_entity_cd = 'POSITION';
--
Cursor csr_jobs_in_bdgt is
   Select job_id
     From pqh_budgets bgt,pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_id		 = bgt.budget_id
      AND bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bgt.budgeted_entity_cd = 'JOB';
--
Cursor csr_grades_in_bdgt is
   Select grade_id
     From pqh_budgets bgt,pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_id		 = bgt.budget_id
      AND bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bgt.budgeted_entity_cd = 'GRADE';
--
Cursor csr_orgs_in_bdgt is
   Select organization_id
     From pqh_budgets bgt,pqh_budget_details bdt,pqh_budget_versions bvr
    Where bvr.budget_id		 = bgt.budget_id
      AND bvr.budget_version_id  = p_budget_version_id
      AND bvr.budget_version_id  = bdt.budget_version_id
      AND bgt.budgeted_entity_cd = 'ORGANIZATION';

--
l_proc        varchar2(72) := g_package||'get_budget_commitment';
--
Begin
--
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 -- Validate if the budget version is valid .
 --
 Validate_budget(p_budget_version_id  =>  p_budget_version_id,
                 p_budget_id          =>  l_budget_id);
 --
 -- Check if the input unit of measure is valid in per_shared_types.
 -- Also , check if the uom has been budgeted for in the budget.
 --
 Validate_unit_of_measure(p_unit_of_measure_id    => p_unit_of_measure_id,
                          p_unit_of_measure_desc  => l_unit_of_measure);


 Validate_uom_in_budget(p_unit_of_measure_id    => p_unit_of_measure_id,
                        p_budget_id             => l_budget_id);
 --
 Validate_commitment_dates(p_cmmtmnt_start_dt => p_period_start_date,
                           p_cmmtmnt_end_dt   => p_period_end_date,
                           p_budget_id        => l_budget_id);
 --
 l_budget_commitment := 0;
 --
 -- Break budget version into its comprising positions .Calculate the
 -- commitment for each position and sum it up to obtain budget commitment.
 --
 If p_budgeted_entity_cd = 'POSITION' Then
     for i in csr_positions_in_bdgt loop
	 l_entity_commitment := get_ent_actual_and_cmmtmnt
		   (p_budget_version_id  => p_budget_version_id,
		    p_budgeted_entity_cd => p_budgeted_entity_cd,
		    p_entity_id          => i.position_id,
		    p_start_date         => p_period_start_date,
		    p_end_date           => p_period_end_date,
		    p_unit_of_measure_id => p_unit_of_measure_id,
		    p_value_type         => 'C');
	 l_budget_commitment := nvl(l_budget_commitment,0) + nvl(l_entity_commitment,0);
     End Loop;
  Elsif p_budgeted_entity_cd = 'JOB' Then
      for i in csr_jobs_in_bdgt loop
 	  l_entity_commitment := get_ent_actual_and_cmmtmnt
 	       (p_budget_version_id  => p_budget_version_id,
 	        p_budgeted_entity_cd => p_budgeted_entity_cd,
 		p_entity_id          => i.job_id,
 		p_start_date         => p_period_start_date,
 		p_end_date           => p_period_end_date,
 		p_unit_of_measure_id => p_unit_of_measure_id,
 		p_value_type         => 'C');
 	  l_budget_commitment := nvl(l_budget_commitment,0) + nvl(l_entity_commitment,0);
      End Loop;
  Elsif p_budgeted_entity_cd = 'GRADE' Then
      for i in csr_grades_in_bdgt loop
 	  l_entity_commitment := get_ent_actual_and_cmmtmnt
 	       (p_budget_version_id  => p_budget_version_id,
 	        p_budgeted_entity_cd => p_budgeted_entity_cd,
 		p_entity_id          => i.grade_id,
 		p_start_date         => p_period_start_date,
 		p_end_date           => p_period_end_date,
 		p_unit_of_measure_id => p_unit_of_measure_id,
 		p_value_type         => 'C');
 	  l_budget_commitment := nvl(l_budget_commitment,0) + nvl(l_entity_commitment,0);
      End Loop;
  Elsif p_budgeted_entity_cd = 'ORGANIZATION' Then
      for i in csr_orgs_in_bdgt loop
 	  l_entity_commitment := get_ent_actual_and_cmmtmnt
 	       (p_budget_version_id  => p_budget_version_id,
 	        p_budgeted_entity_cd => p_budgeted_entity_cd,
 		p_entity_id          => i.organization_id,
 		p_start_date         => p_period_start_date,
 		p_end_date           => p_period_end_date,
 		p_unit_of_measure_id => p_unit_of_measure_id,
 		p_value_type         => 'C');
 	  l_budget_commitment := nvl(l_budget_commitment,0) + nvl(l_entity_commitment,0);
      End Loop;
 End If;
--
hr_utility.set_location('Leaving:'||l_proc, 10);
--
RETURN l_budget_commitment;
--
Exception When others then
  hr_utility.set_location('Exception:'||l_proc, 15);
  raise;
End;
--
procedure get_asg_actual_cmmt(p_assignment_id         number
                             ,p_budget_version_id     number
				             ,p_element_type_id	      number
				             ,p_start_date            date
				             ,p_end_date              date
                             ,p_assignment_actuals    out nocopy number
                             ,p_assignment_commitment out nocopy number
                             ,p_assignment_total      out nocopy number
) is
l_last_actuals_date         per_time_periods.end_date%type;
l_budget_id                 pqh_budgets.budget_id%type := NULL;
--
begin
         --
         p_assignment_total := 0;
         p_assignment_actuals := 0;
         p_assignment_commitment := 0;
         l_last_actuals_date := NULL;
         --

         /*2716884*/
         If p_budget_version_id IS NOT NULL then
         --
         Validate_budget(p_budget_version_id  =>  p_budget_version_id,
                   p_budget_id          =>  l_budget_id);
         End if;

         --
         -- get actuals for the assignment and the last payroll run date

         -- for the assignment.
         --
         p_assignment_actuals := get_assign_money_actuals
                   ( p_budget_id          => l_budget_id, /*2716884*/
                     p_assignment_id      => p_assignment_id,
                     p_element_type_id    => p_element_type_id,--Later
                     p_actuals_start_date => p_start_date,
                     p_actuals_end_date   => p_end_date,
                     p_last_payroll_dt    => l_last_actuals_date
                    );
         --
         hr_utility.set_location('Assignment Actual:'||p_assignment_actuals,10);
         hr_utility.set_location('Last Actual Date :'||l_last_actuals_date, 20);
         --
         IF  l_last_actuals_date IS NULL  OR
             l_last_actuals_date <= p_start_date THEN
             --
             -- payroll has never been run for the position. So actual is zero
             --
             p_assignment_actuals := 0;
             --
             p_assignment_commitment := get_assign_money_cmmtmnt
                            (p_assignment_id      => p_assignment_id,
                             p_budget_version_id  => p_budget_version_id,
                             p_element_type_id    => p_element_type_id,
                             p_period_start_date  => p_start_date,
                             p_period_end_date    => p_end_date
                            );
             --
             hr_utility.set_location('Assignment Commitment : '||p_assignment_commitment, 30);
             --
         ELSIF l_last_actuals_date >= p_end_date then
             --
             -- Actuals is available beyond the required period end date .
             -- So commitment is 0.
             --
             p_assignment_commitment := 0;
            --
         ELSE
             --
             -- payroll has been run for the position. calculate commitment
             -- from the next day of the last payroll run.
             --
             p_assignment_commitment := get_assign_money_cmmtmnt
                          (p_assignment_id      => p_assignment_id ,
                           p_budget_version_id  => p_budget_version_id,
                           p_element_type_id    => p_element_type_id,
                           p_period_start_date  => l_last_actuals_date + 1,
                           p_period_end_date    => p_end_date
                          );
             --
             hr_utility.set_location('Assignment Commitment : '||p_assignment_commitment, 40);
             --
         END IF;
         --
         -- Total up assignment commitment and actual information.
         --
         p_assignment_total := NVL(p_assignment_actuals,0) + NVL(p_assignment_commitment,0);
         --
end;
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--
-- Sreevijay - This is used to calculate actual and commitment totals for a budget entity
-- and unit of measurement.
--
Procedure get_actual_and_cmmtmnt( p_position_id 	in number default null
				 ,p_job_id      	in number default null
				 ,p_grade_id    	in number default null
				 ,p_organization_id 	in number default null
				 ,p_budget_entity       in varchar2
				 ,p_element_type_id	in number default null
				 ,p_start_date          in date default sysdate
				 ,p_end_date            in date default sysdate
				 ,p_effective_date      in date default sysdate
				 ,p_unit_of_measure	in varchar2
				 ,p_business_group_id	in number
				 ,p_actual_value out nocopy number
				 ,p_commt_value	        out nocopy number
				 ) is

--
-- Cursor to fetch budgets and budget versions
-- Single or multiple controlled budgets
--
cursor c_budgets is
select bgt.budget_id, budget_version_id, budget_start_date, budget_end_date
  from pqh_budgets bgt, pqh_budget_versions ver
 where bgt.budget_id = ver.budget_id
   and (p_effective_date between date_from and date_to)
   and position_control_flag = 'Y'
   and budgeted_entity_cd = p_budget_entity
   and business_group_id = p_business_group_id -- Line added Bug Fix : 2432715
   and	(p_start_date <= budget_end_date
          and p_end_date >= budget_start_date)
     and ( hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit1_id) = p_unit_of_measure
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit2_id) = p_unit_of_measure
          or hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(budget_unit3_id) = p_unit_of_measure);
--
-- Cursors to fetch assignments
--
cursor csr_position_assg is
select distinct assg.assignment_id
  from per_all_assignments_f assg
 where business_group_id = p_business_group_id
   and p_position_id = assg.position_id
   and assg.effective_end_date   >= p_start_date
   and assg.effective_start_date <= p_end_date;
--
cursor csr_job_assg is
select distinct assg.assignment_id
  from per_all_assignments_f assg
 where business_group_id = p_business_group_id
   and p_job_id = assg.job_id
   and assg.effective_end_date   >= p_start_date
   and assg.effective_start_date <= p_end_date;
--
cursor csr_org_assg is
select distinct assg.assignment_id
  from per_all_assignments_f assg
 where p_organization_id = assg.organization_id
   and business_group_id = p_business_group_id
   and assg.effective_end_date   >= p_start_date
   and assg.effective_start_date <= p_end_date;
--
cursor csr_grade_assg is
select distinct assg.assignment_id
  from per_all_assignments_f assg
 where business_group_id = p_business_group_id
   and p_grade_id = assg.grade_id
   and assg.effective_end_date   >= p_start_date
   and assg.effective_start_date <= p_end_date;
--
l_position_id               pqh_budget_details.position_id%type;
l_position_name             hr_all_positions_f.name%type := NULL;
l_assignment_id             per_all_assignments_f.assignment_id%type;
l_last_actuals_date         per_time_periods.end_date%type;
--
l_budget_id                 pqh_budgets.budget_id%type := NULL;
--
l_unit_of_measure           per_shared_types.system_type_cd%type;
--
l_assignment_actuals        number := 0;
l_assignment_commitment     number := 0;
l_assignment_total          number := 0;
--
l_entity_actuals            number := 0;
l_entity_commitment         number := 0;
l_total_actuals             number := 0;
l_total_commitment	    number := 0;
l_assignment_value          number := 0;

--
l_proc        varchar2(72) := g_package||'get_actual_and_cmmtmnt';


Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('l_unit_of_measure:'||p_unit_of_measure, 5);
  --
  --
  If p_unit_of_measure = 'MONEY' then
      --
      -- calculate actuals and commitment for each assignment.
      --
    hr_utility.set_location('~~NS:Before Loop Position: '||p_position_id, 8);
    hr_utility.set_location('~~NS:p_effective_date: '||p_effective_date, 8);
    hr_utility.set_location('~~NS:p_business_group_id: '||p_business_group_id, 8);
    hr_utility.set_location('~~NS:p_budget_entity: '||p_budget_entity, 8);
    hr_utility.set_location('~~NS:p_start_date: '||p_start_date, 8);
    hr_utility.set_location('~~NS:p_end_date: '||p_end_date, 8);


    For l_budget in c_budgets
    Loop
    hr_utility.set_location('~~NS:Budget Version: '||l_budget.budget_version_id, 8);
     -- modified by svorugan Bug Fix : 2432715
      l_assignment_total :=0;
      l_entity_commitment :=0;
      l_entity_actuals :=0;
     -- upto here
      if p_position_id is not null then
        for i in csr_position_assg loop
          l_assignment_id := i.assignment_id;
    hr_utility.set_location('~~NS:Before Calling get asg actual cmmt: '||p_position_id, 8);
          get_asg_actual_cmmt(l_assignment_id
                             ,l_budget.budget_version_id
                             ,p_element_type_id
                             ,p_start_date
                             ,p_end_date
                             ,l_assignment_actuals
                             ,l_assignment_commitment
                             ,l_assignment_total);
          -- Total up entity commitment and actuals info
          l_entity_commitment := nvl(l_entity_commitment,0) + NVL(l_assignment_commitment,0);
          --
          l_entity_actuals := nvl(l_entity_actuals,0) + NVL(l_assignment_actuals,0);
          --
          hr_utility.set_location('svorugan..2'||l_entity_actuals,50);
          --
        End Loop; -- csr_assg
      elsif p_organization_id is not null then
        for i in csr_org_assg loop
          l_assignment_id := i.assignment_id;
          get_asg_actual_cmmt(l_assignment_id
                             ,l_budget.budget_version_id
                             ,p_element_type_id
                             ,p_start_date
                             ,p_end_date
                             ,l_assignment_actuals
                             ,l_assignment_commitment
                             ,l_assignment_total);
          -- Total up entity commitment and actuals info
          l_entity_commitment := nvl(l_entity_commitment,0) + NVL(l_assignment_commitment,0);
          --
          l_entity_actuals := nvl(l_entity_actuals,0) + NVL(l_assignment_actuals,0);
          --
          hr_utility.set_location('svorugan..2'||l_entity_actuals,50);
          --
        End Loop; -- csr_assg
      elsif p_job_id is not null then
        for i in csr_job_assg loop
          l_assignment_id := i.assignment_id;
          get_asg_actual_cmmt(l_assignment_id
                             ,l_budget.budget_version_id
                             ,p_element_type_id
                             ,p_start_date
                             ,p_end_date
                             ,l_assignment_actuals
                             ,l_assignment_commitment
                             ,l_assignment_total);
          -- Total up entity commitment and actuals info
          l_entity_commitment := nvl(l_entity_commitment,0) + NVL(l_assignment_commitment,0);
          --
          l_entity_actuals := nvl(l_entity_actuals,0) + NVL(l_assignment_actuals,0);
          --
          hr_utility.set_location('svorugan..2'||l_entity_actuals,50);
          --
        End Loop; -- csr_assg
      elsif p_grade_id is not null then
        for i in csr_grade_assg loop
          l_assignment_id := i.assignment_id;
          get_asg_actual_cmmt(l_assignment_id
                             ,l_budget.budget_version_id
                             ,p_element_type_id
                             ,p_start_date
                             ,p_end_date
                             ,l_assignment_actuals
                             ,l_assignment_commitment
                             ,l_assignment_total);
          -- Total up entity commitment and actuals info
          l_entity_commitment := nvl(l_entity_commitment,0) + NVL(l_assignment_commitment,0);
          --
          l_entity_actuals := nvl(l_entity_actuals,0) + NVL(l_assignment_actuals,0);
          --
          hr_utility.set_location('svorugan..2'||l_entity_actuals,50);
          --
        End Loop; -- csr_assg
      end if;
      --
      hr_utility.set_location('All assignments processed',50);
      l_total_actuals    := nvl(l_total_actuals,0) +  nvl(l_entity_actuals,0);
      l_total_commitment := nvl(l_total_commitment,0) + nvl(l_entity_commitment,0);

      hr_utility.set_location('Totals: Commitment | Actuals'||l_total_commitment||' | '||l_total_actuals,50);

    End Loop; -- csr_budgets

    p_actual_value := l_total_actuals;
    p_commt_value  := l_total_commitment;

  Elsif p_unit_of_measure = 'HOURS' then
      -- calculate actual value for an entity if the unit is HOURS
      p_actual_value := get_actual_hours(p_business_grp_id  => p_business_group_id
      					,p_position_id      => p_position_id
                       			,p_job_id           => p_job_id
		                        ,p_grade_id         => p_grade_id
                       			,p_organization_id  => p_organization_id
                       			,p_start_date       => p_start_date
                       			,p_end_date         => p_end_date
                       			,p_effective_date   => p_effective_date);
    p_commt_value := 0;
    hr_utility.set_location('Actual Hours:'||p_actual_value, 10);
  Else
     -- Calculate the actual value for an entity if the unit is FTE/HEADCOUNT etc.
     p_actual_value := hr_discoverer.get_actual_budget_values
                      (p_bus_group_id     => p_business_group_id,
                       p_position_id      => p_position_id,
                       p_job_id           => p_job_id,
                       p_grade_id         => p_grade_id,
                       p_organization_id  => p_organization_id,
                       p_start_date       => p_start_date,
                       p_end_date         => p_end_date,
                       p_unit             => p_unit_of_measure,
                       p_actual_val       => NULL);
     p_commt_value := 0;
       --
  End if;
Exception
    when others then
       p_actual_value       := null;
       p_commt_value	       := null;
       hr_utility.set_location('Exception :'||l_proc,60);
       hr_utility.raise_error;
End get_actual_and_cmmtmnt;
--
--
FUNCTION get_pos_money_total9(
                     p_position_id           number,
                     p_budget_version_id     number,
                     p_actuals_start_date    date,
                     p_actuals_end_date      date)
RETURN NUMBER
IS

cursor csr_actual_exists(p_budget_id number) is
   select 1
   from pqh_bdgt_cmmtmnt_elmnts
   where actual_commitment_type in ('ACTUAL','BOTH')
   and budget_id = p_budget_id;

--
Cursor csr_pos_cost(
                     p_position_id           number,
                     p_actuals_start_date    date,
                     p_actuals_end_date      date,
                     p_budget_id             number
                     ) is

Select sum(pc.costed_value)
 From
 (select distinct assignment_id, payroll_id from per_all_assignments_f assg
  where ASSG.effective_end_date   >= p_actuals_start_date
   and ASSG.effective_start_date <= p_actuals_end_date
   AND assg.position_id = p_position_id
   -- and assg.assignment_id <> p_ex_assignment_id
 ) a,
 pay_payroll_actions ppa,
 PAY_ASSIGNMENT_ACTIONS AAC,
 PAY_COSTS pc,
 PAY_ELEMENT_TYPES_F PET,
 PAY_INPUT_VALUES_F INV,
 pqh_bdgt_cmmtmnt_elmnts pbce
 Where PPA.PAYROLL_ACTION_ID = AAC.PAYROLL_ACTION_ID
   AND PPA.PAYROLL_ID = A.PAYROLL_ID
   AND ppa.action_type IN ('Q','R','V','B')
   AND ppa.date_earned BETWEEN p_actuals_start_date AND p_actuals_end_date
   AND aac.run_type_id IS not NULL
   and AAC.ASSIGNMENT_ID = a.assignment_id
   and aac.assignment_action_id = pc.assignment_action_id
   and pbce.actual_commitment_type in ('ACTUAL','BOTH')
   and pbce.budget_id = p_budget_id
   and pc.input_value_id = inv.input_value_id
   AND PET.ELEMENT_TYPE_ID = INV.ELEMENT_TYPE_ID
   and pbce.element_type_id = INV.element_type_id
   --AND INV.NAME = 'Pay Value'
  AND INV.INPUT_VALUE_ID = pbce.element_input_value_id--'Pay Value'
  --AND (PET.CLASSIFICATION_ID = p_cl_id_1 or PET.CLASSIFICATION_ID = p_cl_id_2)
   AND BALANCE_OR_COST = 'C';
--
--
cursor curs1(p_position_id number, p_actuals_start_date date) is
   select classification_id
   from pay_element_classifications,
        hr_all_positions_f pos,
        HR_ORGANIZATION_INFORMATION O3
   where classification_name in ('Earnings', 'Employer Liabilities')
   and legislation_code = O3.ORG_INFORMATION9
   and pos.position_id = p_position_id
   and p_actuals_start_date between pos.effective_start_date and pos.effective_end_date
   and pos.business_group_id = O3.ORGANIZATION_ID
   and O3.ORG_INFORMATION_CONTEXT = 'Business Group Information';
--
cl_id_1 number;
cl_id_2 number;
--
--
--Cursor to find position costed value
--
Cursor csr_pos_cost1(
                     p_position_id           number,
                     p_actuals_start_date    date,
                     p_actuals_end_date      date,
                     p_cl_id_1 number,
                     p_cl_id_2 number) is
Select sum(pc.costed_value)
 From
 (select distinct assignment_id, payroll_id from per_all_assignments_f assg
  where ASSG.effective_end_date   >= p_actuals_start_date
   and ASSG.effective_start_date <= p_actuals_end_date
   AND assg.position_id = p_position_id
--   and assg.assignment_id <> p_ex_assignment_id
 ) a,
 pay_payroll_actions ppa,
 PAY_ASSIGNMENT_ACTIONS AAC,
 PAY_COSTS pc,
 PAY_ELEMENT_TYPES_F PET,
 PAY_INPUT_VALUES_F INV
 Where PPA.PAYROLL_ACTION_ID = AAC.PAYROLL_ACTION_ID
   AND PPA.PAYROLL_ID = A.PAYROLL_ID
   AND ppa.action_type IN ('Q','R','V','B')
   AND ppa.date_earned BETWEEN p_actuals_start_date AND p_actuals_end_date
   AND aac.run_type_id IS not NULL
   and AAC.ASSIGNMENT_ID = a.assignment_id
   and aac.assignment_action_id = pc.assignment_action_id
   and pc.input_value_id = inv.input_value_id
   AND PET.ELEMENT_TYPE_ID = INV.ELEMENT_TYPE_ID
   AND INV.NAME = 'Pay Value'
   AND (PET.CLASSIFICATION_ID = p_cl_id_1 or PET.CLASSIFICATION_ID = p_cl_id_2)
   AND BALANCE_OR_COST = 'C';
--
--
l_from_period_start_dt      date;
l_from_period_end_dt        date;
l_to_period_start_dt        date;
l_to_period_end_dt          date;
--
l_result_value              pay_run_result_values.result_value%type;
l_element_type_id           pay_run_results.element_type_id%type;
--

l_converted_amt             number;
l_position_actuals          number;
l_assignment_cmmt           number;
--
l_proc                      varchar2(72) := g_package ||'get_pos_money_total9';
--
l_dummy number;
l_last_payroll_dt date;
l_budget_id                 pqh_budgets.budget_id%type := NULL;
--
Begin

hr_utility.set_location('Entering :'||l_proc,5);

l_position_actuals := 0;

If p_budget_version_id IS NOT NULL then
   --
   Validate_budget(p_budget_version_id  =>  p_budget_version_id,
                   p_budget_id          =>  l_budget_id);
End if;
   If (l_budget_id is not null) then
     open csr_actual_exists(l_budget_id);
     fetch csr_actual_exists into l_dummy;
     if csr_actual_exists%found then
      -- This function returns the actual expenditure of one assignment record
      -- for a given period.
        open csr_pos_cost(p_position_id,
                     p_actuals_start_date,
                     p_actuals_end_date,
                     l_budget_id);
        fetch csr_pos_cost into l_position_actuals;
        close csr_pos_cost;
      --
        l_position_actuals := nvl(l_position_actuals,0);
      --
     else

        open curs1(p_position_id , p_actuals_start_date);
        fetch curs1 into cl_id_1;
        fetch curs1 into cl_id_2;
        close curs1;
        --
        if (cl_id_1 is not null or cl_id_2 is not null) then
        -- This function returns the actual expenditure of one assignment record
        -- for a given period.
           open csr_pos_cost1(p_position_id,
                     p_actuals_start_date,
                     p_actuals_end_date,
                     cl_id_1, cl_id_2);
           fetch csr_pos_cost1 into l_position_actuals;
           close csr_pos_cost1;
        --
            l_position_actuals := nvl(l_position_actuals,0);
        --
        end if;
    end if;
   else
        open curs1(p_position_id , p_actuals_start_date);
        fetch curs1 into cl_id_1;
        fetch curs1 into cl_id_2;
        close curs1;
        --
        if (cl_id_1 is not null or cl_id_2 is not null) then
        -- This function returns the actual expenditure of one assignment record        -- for a given period.
           open csr_pos_cost1(p_position_id,
                     p_actuals_start_date,
                     p_actuals_end_date,
                     cl_id_1, cl_id_2);
           fetch csr_pos_cost1 into l_position_actuals;
           close csr_pos_cost1;
        --
            l_position_actuals := nvl(l_position_actuals,0);
        --
        end if;
   end if;
   --
   hr_utility.set_location('Leaving :'||l_proc,20);
   --
   RETURN nvl(l_position_actuals,0);
Exception When others then
  hr_utility.set_location('Exception:'||l_proc, 25);
  RAISE;
End get_pos_money_total9;
--

End pqh_bdgt_actual_cmmtmnt_pkg;

/
