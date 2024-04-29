--------------------------------------------------------
--  DDL for Package Body HR_FR_ASG_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FR_ASG_RULES" AS
/* $Header: pefrasgr.pkb 120.0.12000000.2 2007/02/28 10:15:04 spendhar ship $ */
--
procedure mandatory_checks(
        p_assignment_id     in number,
        p_payroll_id        in number,
        p_establishment_id  in number,
        p_contract_id       in number,
        p_assignment_type   in varchar2 ) is

begin
     --
     /* Added for GSI Bug 5472781 */
     IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
        hr_utility.set_location('Leaving : hr_fr_asg_rules.mandatory_checks' , 10);
        return;
     END IF;
     --
     hr_utility.set_location('HR_FR_ASG_RULES',10);
     hr_utility.trace('p_assignment_id:      '||to_char(p_assignment_id));
     hr_utility.trace('p_payroll_id:         '||to_char(p_payroll_id));
     hr_utility.trace('p_establishment_id:   '||to_char(p_establishment_id));
     hr_utility.trace('p_contract_id:        '||to_char(p_contract_id));
     hr_utility.trace('p_assignment_type:    '||p_assignment_type);

	IF nvl(fnd_profile.value('PAY_FR_CHECK_MANDATORY_ASG_ATTRIBUTES'),'Y') <> 'N' then -- [

          IF p_assignment_type = 'E' and (Not pqh_utility.is_pqh_installed(hr_general.get_business_group_id)) THEN -- [
/* ============================================================================= */
/*===================   Commented by DN to test Emp Stat Situation ==============

                IF p_establishment_id is null then -- [
                hr_utility.trace('HR_FR_ASG_RULES: error PER_74964_MANDATORY_ESTAB. ASSIGNMENT_ID:'||
                                   to_char(p_assignment_id));
                        hr_utility.set_message (800,'PER_74964_MANDATORY_ESTAB') ;
                        hr_utility.raise_error;
                        	END IF; -- ]
===========================       End of comment by DN       ===================*/
               NULL; --added by DN
-- contract is no longer mandatory - library code will show a warning if profile is set and
-- assignment is on a payroll. Same logic should apply to api but commenting out while
-- investigating whether this can be done withing user hook
--              IF p_contract_id is null and p_payroll_id is not null then -- [
--              hr_utility.trace('HR_FR_ASG_RULES: error PER_74965_MANDATORY_CONTRACT. ASSIGNMENT_ID:'||
--                                 to_char(p_assignment_id));
--                      hr_utility.set_message (800,'PER_74965_MANDATORY_CONTRACT');
--                      	END IF; -- ]
        		END IF; -- ] end assignment_type E
          	END IF; -- ] end check profile not N

     hr_utility.set_location('HR_FR_ASG_RULES',20);

end mandatory_checks;

procedure mandatory_checks_ins(
        p_assignment_id     in number,
        p_effective_start_date in date,
        p_effective_end_date in date,
        p_payroll_id        in number,
        p_establishment_id  in number,
        p_contract_id       in number,
        p_period_of_service_id in Number,
        p_assignment_type   in varchar2 ) is

  cursor csr_existing_assignment is
  select count(*)
  from   per_all_assignments_f asg
  where  asg.period_of_service_id = p_period_of_service_id
  and    asg.assignment_type = 'E'
  and    asg.assignment_id <> p_assignment_id
  and    asg.effective_start_date <> p_effective_start_date
  and    asg.effective_end_date <> p_effective_end_date;

l_assignment_exists number;

begin
     --
     /* Added for GSI Bug 5472781 */
     IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
        hr_utility.set_location('Leaving : hr_fr_asg_rules.mandatory_checks_ins' , 30);
        return;
     END IF;
     --
-- the employee api first inserts a default assignment with minimal attribution
-- detect this situation and bypass validation for the default assignment

     hr_utility.set_location('HR_FR_ASG_RULES.mandatory_checks_ins enter',30);
     hr_utility.trace('p_assignment_id:       '||to_char(p_assignment_id));
     hr_utility.trace('p_payroll_id:          '||to_char(p_payroll_id));
     hr_utility.trace('p_establishment_id:    '||to_char(p_establishment_id));
     hr_utility.trace('p_contract_id:         '||to_char(p_contract_id));
     hr_utility.trace('p_period_of_service_id:'||to_char(p_period_of_service_id));
     hr_utility.trace('p_assignment_type:     '||p_assignment_type);

	IF nvl(fnd_profile.value('PAY_FR_CHECK_MANDATORY_ASG_ATTRIBUTES'),'Y') <> 'N' then -- [

          IF p_assignment_type = 'E' THEN -- [
                IF p_establishment_id is null then -- [
                   open csr_existing_assignment;
                   fetch csr_existing_assignment
                         into l_assignment_exists;
                hr_utility.set_location('HR_FR_ASG_RULES.mandatory_checks_ins ',40);
                if l_assignment_exists > 0 then -- [ not default assignment
                hr_utility.trace('HR_FR_ASG_RULES: error PER_74964_MANDATORY_ESTAB. ASSIGNMENT_ID:'||
                                   to_char(p_assignment_id));
                        hr_utility.set_message (800,'PER_74964_MANDATORY_ESTAB') ;
                        hr_utility.raise_error;
                                END iF; -- ] end not default asg
                       	END IF; -- ] end establishment null

-- contract is no longer mandatory - library code will show a warning if profile is set and
-- assignment is on a payroll. Same logic should apply to api but commenting out while
-- investigating whether this can be done withing user hook
--              IF p_contract_id is null and p_payroll_id is not null then -- [
--              hr_utility.trace('HR_FR_ASG_RULES: error PER_74965_MANDATORY_CONTRACT. ASSIGNMENT_ID:'||
--                                 to_char(p_assignment_id));
--                      hr_utility.set_message (800,'PER_74965_MANDATORY_CONTRACT');
--                      	END IF; -- ]
        		END IF; -- ] end assignment_type E
          	END IF; -- ] end check profile not N

     hr_utility.set_location('HR_FR_ASG_RULES.mandatory_checks_ins exit',50);

end mandatory_checks_ins;

--
END HR_FR_ASG_RULES;

/
