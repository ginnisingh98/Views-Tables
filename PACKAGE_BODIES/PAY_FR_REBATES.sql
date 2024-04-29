--------------------------------------------------------
--  DDL for Package Body PAY_FR_REBATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_REBATES" as
/* $Header: pyfrebat.pkb 115.10 2003/11/11 07:58:33 autiwari noship $ */
--
-- Globals used by get_prev_asg_hours:
g_hours_worked_def_bal_id  ff_user_entities.creator_id%TYPE;
g_hours_absent_def_bal_id  ff_user_entities.creator_id%TYPE;
--
Procedure init_formula (p_formula_name in varchar2) is
--
l_effective_date        date;
l_start_date            date;
l_formula_id            number;
--
Begin
  --
  select effective_date
  into   l_effective_date
  from   fnd_sessions
  where  session_id = userenv('SESSIONID');
  --
  /* This function call returns -1 if the formula was not found */
  l_formula_id := pay_fr_general.get_formula_info
                  (p_formula_name   => p_formula_name
                  ,p_effective_date => l_effective_date
                  ,p_effective_start_date => l_start_date);
  --
  hr_utility.set_location('After cursor formula_id = '||to_char(l_formula_id),10);
  hr_utility.set_location('After cursor date = '||to_char(l_start_date),10);
  hr_utility.set_location('Formula name = '||p_formula_name, 10);
  --
  ff_exec.init_formula (l_formula_id,
                        l_start_date,
                        g_inputs,
                        g_outputs);
  --
  hr_utility.set_location('Leaving init',10);
End init_formula;

Function get_aubry_II_rebate (p_date_earned        in date
                             ,p_assignment_id      in number
                             ,p_process_type       in varchar2
                             ,p_tax_unit_id        in number
                             ,p_asg_action_id      in number
                             ,p_business_group_id  in number
                             ,p_aubry_I_used       in varchar2
                             ,p_robien_used        in varchar2
                             ,p_subject_to_ss_cont in number
                             ,p_hours_worked       in number
                             ,p_sick_pay           in number
                             ,p_absence_days       in number
                             ,p_aubry_II_rebate              out nocopy number
                             ,p_aubry_II_rebate_code         out nocopy varchar2
                             ,p_aubry_II_contribution_id     out nocopy number
                             ,p_aubry_II_zrr_rebate          out nocopy number
                             ,p_aubry_II_zrr_rebate_code     out nocopy varchar2
                             ,p_aubry_II_zrr_contribution_id out nocopy number
                             ,p_message                      out nocopy varchar2) return number is
--
Begin
  --
  hr_utility.set_location('Entering pay_fr_rebates.get_aubry_II_rebate ',7);
  --
  init_formula('FR_AUBRY_II_REBATE');
  --
  -- Set up parameter values for the formula
  for i in g_inputs.first..g_inputs.last loop
      --
      if g_inputs(i).name = 'DATE_EARNED' then
         g_inputs(i).value := fnd_date.date_to_canonical(p_date_earned);
      elsif g_inputs(i).name = 'ASSIGNMENT_ID' then
         g_inputs(i).value := p_assignment_id;
      elsif g_inputs(i).name = 'SOURCE_TEXT' then
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'PROCESS_TYPE' then
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'AUBRY_I_USED' then
         g_inputs(i).value := p_aubry_I_used;
      elsif g_inputs(i).name = 'ROBIEN_USED' then
         g_inputs(i).value := p_robien_used;
      elsif g_inputs(i).name = 'SUBJECT_TO_SS_CONTRIBUTIONS' then
         g_inputs(i).value := p_subject_to_ss_cont;
      elsif g_inputs(i).name = 'HOURS_WORKED' then
         g_inputs(i).value := p_hours_worked;
      elsif g_inputs(i).name = 'SICK_PAY' then
         g_inputs(i).value := p_sick_pay;
      elsif g_inputs(i).name = 'ABSENCE_DAYS' then
         g_inputs(i).value := p_absence_days;
      elsif g_inputs(i).name = 'TAX_UNIT_ID' then
         g_inputs(i).value := p_tax_unit_id;
      elsif g_inputs(i).name = 'ASSIGNMENT_ACTION_ID' then
         g_inputs(i).value := p_asg_action_id;
      elsif g_inputs(i).name = 'BUSINESS_GROUP_ID' then
         g_inputs(i).value := p_business_group_id;
      else
         hr_utility.set_location('ERROR value = '||g_inputs(i).name ,7);
      end if;
      --
  end loop;
  --
  -- Run the formula
  --
  hr_utility.set_location('Prior to execute the formula',8);
  ff_exec.run_formula (g_inputs ,
                       g_outputs
                      );
  --
  hr_utility.set_location('End run formula',9);
  --
  for l_out_cnt in g_outputs.first..g_outputs.last loop
      --
      if g_outputs(l_out_cnt).name = 'L_AUBRY_II_REBATE' then
         p_aubry_ii_rebate := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_AUBRY_II_REBATE_CODE' then
         p_aubry_II_rebate_code := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_AUBRY_II_CONTRIBUTION_ID' then
         p_aubry_II_contribution_id := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_AUBRY_II_ZRR_REBATE' then
         p_aubry_II_zrr_rebate := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_AUBRY_II_ZRR_REBATE_CODE' then
         p_aubry_II_zrr_rebate_code := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_AUBRY_II_ZRR_CONTRIBUTION_ID' then
         p_aubry_II_zrr_contribution_id := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'MESG' then
         p_message := g_outputs(l_out_cnt).value;
      end if;
      --
  end loop;
  --
  if (p_aubry_II_contribution_id = -1 or p_aubry_II_zrr_contribution_id = -1) then
     hr_utility.set_location('get_aubry_II_rebate: Returning -1',10);
     return -1;
  else
     hr_utility.set_location('get_aubry_II_rebate: Returning 0',10);
     return 0;
  end if;
  --
End get_aubry_II_rebate;

Function get_aubry_I_rebate (p_date_earned        in date
                            ,p_assignment_id      in number
                            ,p_process_type       in varchar2
                            ,p_tax_unit_id        in number
                            ,p_mesg                    out nocopy varchar2
                            ,p_aubry_I_rebate          out nocopy number
                            ,p_aubry_I_rebate_code     out nocopy varchar2
                            ,p_aubry_I_contribution_id out nocopy number) return number is
--
Begin
  --
  hr_utility.set_location('Entering pay_fr_rebates.get_aubry_I_rebate ',7);
  --
  init_formula('FR_AUBRY_I_REBATE');
  --
  -- Set up parameter values for the formula
  for i in g_inputs.first..g_inputs.last loop
      --
      if g_inputs(i).name = 'DATE_EARNED' then
         g_inputs(i).value := fnd_date.date_to_canonical(p_date_earned);
      elsif g_inputs(i).name = 'PROCESS_TYPE' then
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'SOURCE_TEXT' then
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'ASSIGNMENT_ID' then
         g_inputs(i).value := p_assignment_id;
      elsif g_inputs(i).name = 'TAX_UNIT_ID' then
         g_inputs(i).value := p_tax_unit_id;
      else
         hr_utility.set_location('ERROR value = '||g_inputs(i).name ,7);
      end if;
      --
  end loop;
  --
  -- Run the formula
  --
  hr_utility.set_location(' Prior to execute the formula',8);
  ff_exec.run_formula (g_inputs ,
                       g_outputs
                      );
  --
  hr_utility.set_location(' End run formula',9);
  --
  for l_out_cnt in g_outputs.first..g_outputs.last loop
      --
      if g_outputs(l_out_cnt).name = 'L_AUBRY_I_REBATE' then
         p_aubry_I_rebate := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_AUBRY_I_REBATE_CODE' then
         p_aubry_I_rebate_code := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_AUBRY_I_CONTRIBUTION_ID' then
         p_aubry_I_contribution_id := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'MESG' then
         p_mesg := g_outputs(l_out_cnt).value;
      end if;
      --
  end loop;
  --
  if p_aubry_I_contribution_id = -1 then
     hr_utility.set_location('get_aubry_I_rebate: Returning -1',10);
     return -1;
  else
     hr_utility.set_location('get_aubry_I_rebate: Returning 0',10);
     return 0;
  end if;
  --
End get_aubry_I_rebate;

Function get_robien_rebate (p_date_earned         in date
                           ,p_assignment_id       in number
                           ,p_process_type        in varchar2
                           ,p_tax_unit_id         in number
                           ,p_contributions_base  in number
                           ,p_mesg                    out nocopy varchar2
                           ,p_robien_rebate           out nocopy number
                           ,p_robien_rebate_code      out nocopy varchar2
                           ,p_robien_rebate_rate      out nocopy number
                           ,p_robien_contribution_id  out nocopy number) return number is
--
Begin
  --
  hr_utility.set_location('Entering pay_fr_rebates.get_robien_rebate ',7);
  --
  init_formula('FR_ROBIEN_REBATE');
  --
  -- Set up parameter values for the formula
  for i in g_inputs.first..g_inputs.last loop
  --
      if g_inputs(i).name = 'DATE_EARNED' then
         g_inputs(i).value := fnd_date.date_to_canonical(p_date_earned);
      elsif g_inputs(i).name = 'SOURCE_TEXT' then
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'PROCESS_TYPE' then
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'ASSIGNMENT_ID' then
         g_inputs(i).value := p_assignment_id;
      elsif g_inputs(i).name = 'CONTRIBUTIONS_BASE' then
         g_inputs(i).value := p_contributions_base;
      elsif g_inputs(i).name = 'TAX_UNIT_ID' then
         g_inputs(i).value := p_tax_unit_id;
      else
         hr_utility.set_location('ERROR value = '||g_inputs(i).name ,7);
      end if;
  --
  end loop;
  --
  -- Run the formula
  --
  hr_utility.set_location(' Prior to execute the formula',8);
  ff_exec.run_formula (g_inputs ,
                       g_outputs
                      );
  --
  hr_utility.set_location(' End run formula',9);
  --
  for l_out_cnt in g_outputs.first..g_outputs.last loop
      --
      if g_outputs(l_out_cnt).name = 'L_ROBIEN_REBATE' then
         p_robien_rebate := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_ROBIEN_REBATE_CODE' then
         p_robien_rebate_code := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_ROBIEN_REBATE_RATE' then
         p_robien_rebate_rate := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_ROBIEN_CONTRIBUTION_ID' then
         p_robien_contribution_id := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'MESG' then
         p_mesg := g_outputs(l_out_cnt).value;
      end if;
      --
  end loop;
  --
  if p_robien_contribution_id = -1 then
     hr_utility.set_location('get_robien_rebate: Returning -1',10);
     return -1;
  else
     hr_utility.set_location('get_robien_rebate: Returning 0',10);
     return 0;
  end if;
  --
End get_robien_rebate;

Function get_part_time_rebate (p_date_earned        in date
                              ,p_assignment_id      in number
                              ,p_process_type       in varchar2
                              ,p_tax_unit_id        in number
                              ,p_contributions_base in number
                              ,p_mesg                       out nocopy varchar2
                              ,p_part_time_rebate           out nocopy number
                              ,p_part_time_rebate_code      out nocopy varchar2
                              ,p_part_time_contribution_id  out nocopy number) return number is
--
Begin
  --
  hr_utility.set_location('Entering pay_fr_rebates.get_part_time_rebate ',7);
  --
  init_formula('FR_PART_TIME_REBATE');
  --
  -- Set up parameter values for the formula
  for i in g_inputs.first..g_inputs.last loop
  --
      if g_inputs(i).name = 'DATE_EARNED' then
         g_inputs(i).value := fnd_date.date_to_canonical(p_date_earned);
      elsif g_inputs(i).name = 'PROCESS_TYPE' then
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'SOURCE_TEXT' then
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'CONTRIBUTIONS_BASE' then
         g_inputs(i).value := p_contributions_base;
      elsif g_inputs(i).name = 'ASSIGNMENT_ID' then
         g_inputs(i).value := p_assignment_id;
      elsif g_inputs(i).name = 'TAX_UNIT_ID' then
         g_inputs(i).value := p_tax_unit_id;
      else
         hr_utility.set_location('ERROR value = '||g_inputs(i).name ,7);
      end if;
  --
  end loop;
  --
  -- Run the formula
  --
  hr_utility.set_location(' Prior to execute the formula',8);
  ff_exec.run_formula (g_inputs,
                       g_outputs
  );
  --
  hr_utility.set_location(' End run formula',9);
  --
  for l_out_cnt in g_outputs.first..g_outputs.last loop
      --
      if g_outputs(l_out_cnt).name = 'L_PART_TIME_REBATE' then
         p_part_time_rebate := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_PART_TIME_REBATE_CODE' then
         p_part_time_rebate_code := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_PART_TIME_CONTRIBUTION_ID' then
         p_part_time_contribution_id := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'MESG' then
         p_mesg := g_outputs(l_out_cnt).value;
      end if;
      --
  end loop;
  --
  if p_part_time_contribution_id = -1 then
     hr_utility.set_location('get_part_time_rebate: Returning -1',10);
     return -1;
  else
     hr_utility.set_location('get_part_time_rebate: Returning 0',10);
     return 0;
  end if;
  --
End get_part_time_rebate;

Function get_ss_lower_rebate (p_date_earned        in date
                             ,p_assignment_id      in number
                             ,p_process_type       in varchar2
                             ,p_tax_unit_id        in number
                             ,p_business_group_id  in number
                             ,p_salary             in number
                             ,p_salary_excluding_absence in number
                             ,p_hours_worked       in number
                             ,p_absence_days       in number
                             ,p_mesg                     out nocopy varchar2
                             ,p_ss_lower_rebate          out nocopy number
                             ,p_ss_lower_rebate_code     out nocopy varchar2
                             ,p_ss_lower_contribution_id out nocopy number) return number is
--
Begin
  --
  hr_utility.set_location('Entering pay_fr_rebates.get_ss_lower_rebate ',7);
  --
  init_formula('FR_SS_LOWER_REBATE');
  --
  -- Set up parameter values for the formula
  for i in g_inputs.first..g_inputs.last loop
  --
      if g_inputs(i).name = 'DATE_EARNED' then
         g_inputs(i).value := fnd_date.date_to_canonical(p_date_earned);
      elsif g_inputs(i).name = 'PROCESS_TYPE' then
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'SOURCE_TEXT' then
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'SALARY' then
         g_inputs(i).value := p_salary;
      elsif g_inputs(i).name = 'SALARY_EXCLUDING_ABSENCE' then
         g_inputs(i).value := p_salary_excluding_absence;
      elsif g_inputs(i).name = 'HOURS_WORKED' then
         g_inputs(i).value := p_hours_worked;
      elsif g_inputs(i).name = 'ABSENCE_DAYS' then
         g_inputs(i).value := p_absence_days;
      elsif g_inputs(i).name = 'ASSIGNMENT_ID' then
         g_inputs(i).value := p_assignment_id;
      elsif g_inputs(i).name = 'TAX_UNIT_ID' then
         g_inputs(i).value := p_tax_unit_id;
      elsif g_inputs(i).name = 'BUSINESS_GROUP_ID' then
         g_inputs(i).value := p_business_group_id;
      else
         hr_utility.set_location('ERROR value = '||g_inputs(i).name ,7);
      end if;
  --
  end loop;
  --
  -- Run the formula
  --
  hr_utility.set_location(' Prior to execute the formula',8);
  --
  ff_exec.run_formula (g_inputs,
                       g_outputs
                      );
  --
  hr_utility.set_location(' End run formula',9);
  --
  for l_out_cnt in g_outputs.first..g_outputs.last loop
      --
      if g_outputs(l_out_cnt).name = 'L_SS_LOWER_REBATE' then
         p_ss_lower_rebate := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_SS_LOWER_REBATE_CODE' then
         p_ss_lower_rebate_code := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_SS_LOWER_CONTRIBUTION_ID' then
         p_ss_lower_contribution_id := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'MESG' then
         p_mesg := g_outputs(l_out_cnt).value;
      end if;
      --
  end loop;
  --
  if p_ss_lower_contribution_id = -1 then
     hr_utility.set_location('get_ss_lower_rebate: Returning -1',10);
     return -1;
  else
     hr_utility.set_location('get_ss_lower_rebate: Returning 0',10);
     return 0;
  end if;
  --
End get_ss_lower_rebate;

Function valid_aubry_robien_dates (p_org_id             in number,
                                   p_information_type   in varchar2,
                                   p_date_from          in date,
                                   p_date_to            in date default null) return varchar2 is
--
l_end_date date;
l_dummy    varchar2(1);
--
cursor c1 is
     select 'X'
     from hr_organization_information hoi
     where (
            (
             p_date_from between fnd_date.canonical_to_date(hoi.org_information1)
                             and decode(p_information_type,'FR_ESTAB_ROBIEN',add_months(fnd_date.canonical_to_date(hoi.org_information1),60)
                                                          ,fnd_date.canonical_to_date(hoi.org_information2))
            )
            or
            (
             l_end_date between fnd_date.canonical_to_date(hoi.org_information1)
                            and decode(p_information_type,'FR_ESTAB_ROBIEN',add_months(fnd_date.canonical_to_date(hoi.org_information1),60)
                                                          ,fnd_date.canonical_to_date(hoi.org_information2))
            )
            or
            (
             l_end_date >= decode(p_information_type,'FR_ESTAB_ROBIEN',add_months(fnd_date.canonical_to_date(hoi.org_information1),60)
                                                            ,fnd_date.canonical_to_date(hoi.org_information2))
             and p_date_from <= fnd_date.canonical_to_date(hoi.org_information1)
            )
           )
     and hoi.org_information_context = decode(p_information_type,'FR_ESTAB_ROBIEN',
                                              'FR_ESTAB_AUBRY_I','FR_ESTAB_ROBIEN')
     and hoi.organization_id = p_org_id;
--
Begin
  --
  if p_information_type = 'FR_ESTAB_ROBIEN' then
     l_end_date := NVL(p_date_to,to_date('4712/12/31','YYYY/MM/DD'));
  else
     l_end_date := add_months(p_date_from,60);
  end if;
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
     close c1;
     return 'N';
  else
     close c1;
     return 'Y';
  end if;
  --
End valid_aubry_robien_dates;

Function contribution_info (p_date_earned    in date
                           ,p_process_type   in varchar2
                           ,p_element_name   in varchar2
                           ,p_usage_type     in varchar2
                           ,p_contribution_id   out nocopy number
                           ,p_contribution_code out nocopy varchar2
                           ,mesg                out nocopy varchar2) return number is
--
l_contribution_usage pay_fr_contribution_usages%rowtype;
l_contribution_code  pay_fr_contribution_usages.contribution_code%type;
--
Begin
--
  hr_utility.set_location('Entering pay_fr_rebates.contribution info ', 10);
  --
  l_contribution_usage := pay_fr_general.get_contribution_usage
                          (p_process_type => p_process_type
                          ,p_element_name => p_element_name
                          ,p_usage_type   => p_usage_type
                          ,p_effective_date => p_date_earned);
  --
  /* Call function to substitute base code into contribution code */
  l_contribution_code := pay_fr_general.sub_contrib_code(p_contribution_type => l_contribution_usage.contribution_type
                                                        ,p_contribution_code => l_contribution_usage.contribution_code);
  --
  p_contribution_code := l_contribution_code;
  p_contribution_id   := l_contribution_usage.contribution_usage_id;
  --
  hr_utility.set_location('Contribution code = '||l_contribution_usage.contribution_code, 10);
  hr_utility.set_location('Contribution id = '||to_char(l_contribution_usage.contribution_usage_id), 10);
  --
  mesg := ' ';
  --
  hr_utility.set_location('Entering pay_fr_rebates.contribution info = 0', 10);
  return 0;
--
Exception when others then
  fnd_message.set_name('PAY','PAY_74918_SD_NO_CNU_DATA');
  fnd_message.set_token('ET',p_element_name);
  fnd_message.set_token('PT',p_process_type);
  fnd_message.set_token('UT',p_usage_type);
  mesg := fnd_message.get;
  p_contribution_id := -1;
  p_contribution_code := ' ';
  hr_utility.set_location('Leaving pay_fr_rebates.contribution info = -1', 10);
  return -1;
--
End contribution_info;

Function get_eligibility (p_date_earned    in date
                         ,p_assignment_id  in number
                         ,p_process_type   in varchar2
                         ,p_tax_unit_id    in number
                         ,p_asg_action_id  in number
                         ,p_pay_action_id  in number
                         ,p_aubry_II_used  out nocopy varchar2
                         ,p_aubry_I_used   out nocopy varchar2
                         ,p_robien_used    out nocopy varchar2
                         ,p_part_time_used out nocopy varchar2
                         ,p_ss_lower_used  out nocopy varchar2
                         ,p_mesg           out nocopy varchar2
                         ,p_fillon_used    out nocopy varchar2
                         ,p_fillon_mesg    out nocopy varchar2
                         ,p_director_mesg  out nocopy varchar2
                         ,p_fillon_part_time_mesg
                                     out nocopy varchar2
) return number is
--
  l_warn  varchar2(150);
  l_err   varchar2(150);
  l_warn_flag  varchar2(150);
--
Begin
  --
  init_formula('FR_GET_REBATE_ELIGIBILITY');
  hr_utility.set_location('FORMULA Initialised ' ,10);
  --
  -- Set up parameter values for the formula
  for i in g_inputs.first..g_inputs.last loop
  --
      if g_inputs(i).name = 'PROCESS_TYPE' then
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'SOURCE_TEXT' then
            g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'DATE_EARNED' then
            g_inputs(i).value := fnd_date.date_to_canonical(p_date_earned);
      elsif g_inputs(i).name = 'ASSIGNMENT_ID' then
            g_inputs(i).value := p_assignment_id;
      elsif g_inputs(i).name = 'TAX_UNIT_ID' then
            g_inputs(i).value := p_tax_unit_id;
      elsif g_inputs(i).name = 'ASSIGNMENT_ACTION_ID' then
            g_inputs(i).value := p_asg_action_id;
      elsif g_inputs(i).name = 'PAYROLL_ACTION_ID' then
            g_inputs(i).value := p_pay_action_id;
      else
         hr_utility.set_location('ERROR value = '||g_inputs(i).name ,7);
      end if;
  --
  end loop;
  --
  -- Run the formula
  --
  hr_utility.set_location(' Prior to execute the formula',8);
  --
  ff_exec.run_formula (g_inputs,
                       g_outputs
                      );
  --
  hr_utility.set_location(' End run formula',9);
  --
  for l_out_cnt in g_outputs.first..g_outputs.last loop
      --
      if g_outputs(l_out_cnt).name = 'AUBRY_II_USED' then
         p_aubry_II_used := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'AUBRY_I_USED' then
         p_aubry_I_used := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'ROBIEN_USED' then
         p_robien_used := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'PART_TIME_USED' then
         p_part_time_used := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'SS_LOWER_USED' then
         p_ss_lower_used := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'MESG' then
         p_mesg := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_ERROR' then
         l_err := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_WARNING' then
         l_warn := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'FILLON_USED' then
         p_fillon_used := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_FILLON_MESG' then
         p_fillon_mesg := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_DIRECTOR_MESG' then
         p_director_mesg := g_outputs(l_out_cnt).value;
      elsif g_outputs(l_out_cnt).name = 'L_FILLON_PART_TIME_MESG' then
         p_fillon_part_time_mesg := g_outputs(l_out_cnt).value;
      else
         hr_utility.set_location('Output = '||g_outputs(l_out_cnt).name, 10);
      end if;
      --
  end loop;
  --

  if l_err like 'PAY_7%' then
     -- Returns either PAY_74972_PART_TIME_ELIG_ERROR
     --             or PAY_79999_NO_AUBRY_II
     fnd_message.set_name('PAY', l_err);
     p_mesg := fnd_message.get;
     hr_utility.set_location(' Returning -1',10);
     return -1;
  else

   if l_warn = 'PAY_74972_PART_TIME_ELIG_WARN' then
     fnd_message.set_name('PAY',l_warn);
     p_mesg := fnd_message.get;
     l_warn_flag := 'Y';
   end if;

   if p_director_mesg = 'PAY_75081_REBATE_DIRECTOR_ELIG' then
     fnd_message.set_name('PAY', p_director_mesg);
     p_director_mesg := fnd_message.get;
     l_warn_flag := 'Y';
   end if;

   if p_fillon_mesg = 'PAY_75082_FILLON_ESTAB_ELIG' then
     fnd_message.set_name('PAY', p_fillon_mesg);
     p_fillon_mesg := fnd_message.get;
     l_warn_flag := 'Y';
   end if;

   if p_fillon_part_time_mesg = 'PAY_75083_FILLON_PART_TIME' then
     fnd_message.set_name('PAY', p_fillon_part_time_mesg);
     p_fillon_part_time_mesg := fnd_message.get;
     l_warn_flag := 'Y';
   end if;

   if l_warn_flag = 'Y' then
     hr_utility.set_location(' Returning -2',10);
     return -2;
   end if;

  end if;

  --
  hr_utility.set_location(' Returning 0',10);
  return 0;
  --
End get_eligibility;


Function get_prev_asg_hours (p_assignment_id        in number
                            ,p_payroll_action_id    in number
                            ,p_process_type        in varchar2
                            ,p_tax_unit_id         in number) return number is
  --
  cursor csr_get_assignment_action is
    select fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                                          paa.assignment_action_id),16))
    from   pay_assignment_actions paa,
           pay_payroll_actions    ppa
    where  paa.assignment_id = p_assignment_id
    and    ppa.payroll_action_id = paa.payroll_action_id
    and    ppa.effective_date between
                                  pay_fr_general.g_prev_start_date and
                                  pay_fr_general.g_prev_end_date
    and    ppa.action_type in ('R', 'Q', 'I', 'V', 'B');
  --
  cursor csr_get_defined_bal_id (p_balance_name in varchar2) is
    select creator_id
    from   ff_user_entities
    where  user_entity_name = p_balance_name;
  --
  l_err                  number;
  l_result               number;
  l_assignment_action_id number := -1;
  --
Begin
--
hr_utility.set_location('In function ', 10);
l_err := pay_fr_general.get_prev_start_end(p_payroll_action_id,
                                           pay_fr_general.g_prev_start_date,
                                           pay_fr_general.g_prev_end_date);
hr_utility.set_location('PREV MONTH value '||to_char(l_err),10);
hr_utility.set_location('Start date = '||to_char(pay_fr_general.g_prev_start_date),10);
hr_utility.set_location('End date = '||to_char(pay_fr_general.g_prev_end_date),10);
--
if l_err = 0 then
   --
   open csr_get_assignment_action;
   fetch csr_get_assignment_action into l_assignment_action_id;
   close csr_get_assignment_action;
   hr_utility.set_location('Action id = '||to_char(l_assignment_action_id),10);
   if l_assignment_action_id > -1 then
      --
      /* now call bue for the asg hours balance using this assignment action id
         - this should get balance for previous period (at the end) */
      --
      if g_hours_worked_def_bal_id is null then
        open csr_get_defined_bal_id ('FR_ACTUAL_HOURS_BASE_ASG_ET_PR_PTD');
        fetch csr_get_defined_bal_id into g_hours_worked_def_bal_id;
        close csr_get_defined_bal_id;
      end if;
      if g_hours_absent_def_bal_id is null then
        open csr_get_defined_bal_id ('FR_ABSENCE_HOURS_BASE_ASG_ET_PR_PTD');
        fetch csr_get_defined_bal_id into g_hours_absent_def_bal_id;
        close csr_get_defined_bal_id;
      end if;
      --
      pay_balance_pkg.set_context ('SOURCE_TEXT',p_process_type);
      pay_balance_pkg.set_context ('TAX_UNIT_ID',p_tax_unit_id);
      l_result := nvl(pay_balance_pkg.get_value(g_hours_worked_def_bal_id,
                                                l_assignment_action_id),0) +
                  nvl(pay_balance_pkg.get_value(g_hours_absent_def_bal_id,
                                                l_assignment_action_id),0);
      return l_result;
      --
   else
      return 0;
   end if;
   --
else
   return -1;
end if;
--
End get_prev_asg_hours;

end pay_fr_rebates;

/
