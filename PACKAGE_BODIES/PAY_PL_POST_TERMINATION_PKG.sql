--------------------------------------------------------
--  DDL for Package Body PAY_PL_POST_TERMINATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PL_POST_TERMINATION_PKG" as
/* $Header: pyplterm.pkb 120.0 2006/03/01 22:24:40 mseshadr noship $ */

PROCEDURE Actual_Term_sii_tax_records(p_debug            boolean default false
                                      ,p_period_of_service_id    number
                                      ,p_actual_termination_date Date
                                      ,p_business_group_id       NUMBER
                                      ) is


cursor csr_term_normal_assignments is
select min(paaf.effective_start_date),
       paaf.assignment_id,
       paaf.person_id
from   per_all_assignments_f         paaf,
       per_assignment_status_types   past,
       hr_soft_coding_keyflex        kflex
where  period_of_service_id=p_period_of_service_id
and    past.ASSIGNMENT_STATUS_TYPE_ID=paaf.ASSIGNMENT_STATUS_TYPE_ID
and    PER_SYSTEM_STATUS='TERM_ASSIGN'
and    kflex.soft_coding_keyflex_id=paaf.soft_coding_keyflex_id
and    kflex.segment3='NORMAL'
group by  paaf.assignment_id,paaf.person_id;


cursor csr_paye_details(r_per_or_asg_id         number,
                        r_contract_category     varchar2,
                        r_effective_date        date  ) is
 select effective_start_date,
        paye_details_id,
        tax_reduction,
        tax_calc_with_spouse_child,
        income_reduction,
        income_reduction_amount,
        rate_of_tax,
        object_version_number
 from   pay_pl_paye_details_f
 where  contract_category=r_contract_category
 and    per_or_asg_id    =r_per_or_asg_id
 and   ( r_effective_date  is null or
         r_effective_date between effective_start_date and effective_end_date
        )
 and rownum=1;
--r_effective_date to be passed as null to fetch terminated record


 cursor csr_sii_details(r_per_or_asg_id         number,
                        r_contract_category     varchar2,
                        r_effective_date        date  ) is
  select  effective_start_date,sii_details_id,
          emp_social_security_info,object_version_number,
          old_age_contribution,pension_contribution,
          sickness_contribution,work_injury_contribution,
          labor_contribution,health_contribution,
          unemployment_contribution,old_age_cont_end_reason,
          pension_cont_end_reason,sickness_cont_end_reason,
          work_injury_cont_end_reason,labor_fund_cont_end_reason,
          health_cont_end_reason,unemployment_cont_end_reason
   from   pay_pl_sii_details_f
   where  per_or_asg_id=r_per_or_asg_id
     and  contract_category=r_contract_category
     and ( r_effective_date  is null or
           r_effective_date between effective_start_date and effective_end_date
          )
     and rownum=1;
--r_effective_date to be passed as null to fetch terminated record
--terminated records cannot be updated,so it wont fetch more than one row
--anyways


  l_csr_sii_details                   csr_sii_details%rowtype;
  l_csr_paye_details                  csr_paye_details%rowtype;

  l_temp_ovn                           number;
  l_temp_details_id                    number;
  l_temp_effective_date_warning        boolean;
  l_temp_effective_start_date          pay_pl_paye_details_f.effective_start_date%type;
  l_temp_effective_end_date            pay_pl_paye_details_f.effective_end_date%type;

  l_proc                               varchar2(55);
BEGIN
--
--   we need to create sii/tax records on Employee termination also
--   bug:4644778
--   1)Get list of all terminated Normal Assignments for this period_of_service_id
--   2)Check if there exists Terminated SII and Terminated Tax Records.(no date join)
--     Since these Terminated Tax records can be only corrected,there should be
--     only record for every sii_details_id or paye_details_id
--     a)If exists,check if the actual_termination_date+1 is after the effective_start_date of record
--                if yes,no record needs to be created
--              if no,(actual_termination_date is before the record's effective_start_date)
--                       copy the record,delete the record,create a new record with same details
--                       as of actual_termination_date+1
--     b)if not exists
--                 check if there exists Normal record as on Actual_termination_date
--                       if yes,copy the record,create terminated sii/tax record
--                       if no,null
--

if p_debug then
l_proc:='PAY_PL_POST_TERMINATION_PKG.Actual_Term_sii_tax_records';
hr_utility.set_location('Entering: '||l_proc, 10);
end if;


for i in csr_term_normal_assignments loop


    --Check for Paye details
    --Check for Sii details
   if p_debug then
    hr_utility.trace('Term Normal Assignment Found '||i.assignment_id);
   end if;
   open  csr_paye_details(r_per_or_asg_id      =>  i.assignment_id,
                          r_contract_category  =>  'TERM_NORMAL' ,
                          r_effective_date     =>   null );

   fetch csr_paye_details into l_csr_paye_details;
      if csr_paye_details%found then
          close csr_paye_details;
             if  ((p_actual_termination_date+1)< l_csr_paye_details.effective_start_date) then
                   --                             18th
                   --                            Assgn terminated.paye record created
                   --then 15th
                   --Employee terminated here
                   --copy the record in loc var,zap the record,create rec from 15th
               pay_pl_paye_api.delete_pl_paye_details
                            ( p_validate                      =>false
                             ,p_effective_date                =>l_csr_paye_details.effective_start_date
                             ,p_datetrack_delete_mode         =>'ZAP'
                             ,p_paye_details_id               =>l_csr_paye_details.paye_details_id
                             ,p_object_version_number         =>l_csr_paye_details.object_version_number
                             ,p_effective_start_date          =>l_temp_effective_start_date
                             ,p_effective_end_date            =>l_temp_effective_end_date
                             );
               pay_pl_paye_api.create_pl_paye_details
                           (  p_validate                      =>false
                             ,p_effective_date                =>(p_actual_termination_date+1)
                             ,p_contract_category             => 'TERM_NORMAL'
                             ,p_per_or_asg_id                 => i.assignment_id
                             ,p_business_group_id             => p_business_group_id
                             ,p_tax_reduction                 => l_csr_paye_details.tax_reduction
                             ,p_tax_calc_with_spouse_child    => l_csr_paye_details.tax_calc_with_spouse_child
                             ,p_income_reduction              => l_csr_paye_details.income_reduction
                             ,p_income_reduction_amount       => l_csr_paye_details.income_reduction_amount
                             ,p_rate_of_tax                   => l_csr_paye_details.rate_of_tax
                             ,p_paye_details_id               => l_temp_details_id              --out var
                             ,p_object_version_number         => l_temp_ovn                     --out var
                             ,p_effective_start_date          => l_temp_effective_start_date    --out var
                             ,p_effective_end_date            => l_temp_effective_end_date      --out var
                             ,p_effective_date_warning        => l_temp_effective_date_warning  --out var
                            );
               --else
               --null;


           end if;

     else --csr_paye_details%found  terminated record
        hr_utility.set_location(l_proc,25);
        close csr_paye_details;

        open csr_paye_details(r_per_or_asg_id      =>  i.person_id  ,
                              r_contract_category    =>  'NORMAL',
                              r_effective_date       =>   p_actual_termination_date+1);
        fetch csr_paye_details into l_csr_paye_details;
          if csr_paye_details%FOUND then
            close csr_paye_details;
             pay_pl_paye_api.create_pl_paye_details
                (p_validate                      => false
                ,p_effective_date                => p_actual_termination_date+1
                ,p_contract_category             => 'TERM_NORMAL'
                ,p_per_or_asg_id                 => i.assignment_id
                ,p_business_group_id             => p_business_group_id
                ,p_tax_reduction                 => l_csr_paye_details.tax_reduction
                ,p_tax_calc_with_spouse_child    => l_csr_paye_details.tax_calc_with_spouse_child
                ,p_income_reduction              => l_csr_paye_details.income_reduction
                ,p_income_reduction_amount       => l_csr_paye_details.income_reduction_amount
                ,p_rate_of_tax                   => l_csr_paye_details.rate_of_tax
                ,p_paye_details_id               => l_temp_details_id              --out var
                ,p_object_version_number         => l_temp_ovn                     --out var
                ,p_effective_start_date          => l_temp_effective_start_date    --out var
                ,p_effective_end_date            => l_temp_effective_end_date      --out var
                ,p_effective_date_warning        => l_temp_effective_date_warning  --out var
                );
           else
               close csr_paye_details;
           end if;--csr_paye_details found  non-terminated record

     end if;--csr_paye_details%found  terminated record
    /*******************Paye record done******************/


   if p_debug then
    hr_utility.set_location(l_proc,30);
   end if;
    /***************Sii record********************/
    open  csr_sii_details(r_per_or_asg_id      =>  i.assignment_id,
                          r_contract_category  =>  'TERM_NORMAL' ,
                          r_effective_date     =>   null );

   fetch csr_sii_details into l_csr_sii_details;
      if csr_sii_details%found then
         hr_utility.set_location(l_proc,40);
          close csr_sii_details;
             if  ((p_actual_termination_date+1)< l_csr_sii_details.effective_start_date) then
                   --                             18th
                   --                            Assgn terminated.Sii record created
                   --then 15th
                   --Employee terminated here
                   --copy the record in loc var,zap the record,create rec from 15th
               pay_pl_sii_api.delete_pl_sii_details
                            ( p_validate                      =>false
                             ,p_effective_date                =>l_csr_sii_details.effective_start_date
                             ,p_datetrack_delete_mode         =>'ZAP'
                             ,p_sii_details_id                =>l_csr_sii_details.sii_details_id
                             ,p_object_version_number         =>l_csr_sii_details.object_version_number
                             ,p_effective_start_date          =>l_temp_effective_start_date
                             ,p_effective_end_date            =>l_temp_effective_end_date
                             );
               pay_pl_sii_api.create_pl_sii_details
                           (  p_validate                      => false
                             ,p_effective_date                => (p_actual_termination_date+1)
                             ,p_contract_category             => 'TERM_NORMAL'
                             ,p_per_or_asg_id                 => i.assignment_id
                             ,p_business_group_id             => p_business_group_id
                             ,p_emp_social_security_info      => l_csr_sii_details.emp_social_security_info
                             ,p_old_age_contribution          => l_csr_sii_details.old_age_contribution
                             ,p_pension_contribution          => l_csr_sii_details.pension_contribution
                             ,p_sickness_contribution         => l_csr_sii_details.sickness_contribution
                             ,p_work_injury_contribution      => l_csr_sii_details.work_injury_contribution
                             ,p_labor_contribution            => l_csr_sii_details.labor_contribution
                             ,p_health_contribution           => l_csr_sii_details.health_contribution
                             ,p_unemployment_contribution     => l_csr_sii_details.unemployment_contribution
                             ,p_old_age_cont_end_reason       => l_csr_sii_details.old_age_cont_end_reason
                             ,p_pension_cont_end_reason       => l_csr_sii_details.pension_cont_end_reason
                             ,p_sickness_cont_end_reason      => l_csr_sii_details.sickness_cont_end_reason
                             ,p_work_injury_cont_end_reason   => l_csr_sii_details.work_injury_cont_end_reason
                             ,p_labor_fund_cont_end_reason    => l_csr_sii_details.labor_fund_cont_end_reason
                             ,p_health_cont_end_reason        => l_csr_sii_details.health_cont_end_reason
                             ,p_unemployment_cont_end_reason  => l_csr_sii_details.unemployment_cont_end_reason
                             ,p_sii_details_id                => l_temp_details_id              --out var
                             ,p_object_version_number         => l_temp_ovn                     --out var
                             ,p_effective_start_date          => l_temp_effective_start_date    --out var
                             ,p_effective_end_date            => l_temp_effective_end_date      --out var
                             ,p_effective_date_warning        => l_temp_effective_date_warning  --out var
                             );
               --else
               --null;


           end if;

     else --csr_sii_details%found 1 terminated record
        hr_utility.set_location(l_proc,45);
        close csr_sii_details;--terminated one is closed

        open csr_sii_details(r_per_or_asg_id         =>  i.person_id  ,
                              r_contract_category    =>  'NORMAL',
                              r_effective_date       =>   p_actual_termination_date+1);
        fetch csr_sii_details into l_csr_sii_details;
          if csr_sii_details%FOUND then
            close csr_sii_details;

             pay_pl_sii_api.create_pl_sii_details
                         (  p_validate                      => false
                            ,p_effective_date                => (p_actual_termination_date+1)
                            ,p_contract_category             => 'TERM_NORMAL'
                            ,p_per_or_asg_id                 => i.assignment_id
                            ,p_business_group_id             => p_business_group_id
                            ,p_emp_social_security_info      => l_csr_sii_details.emp_social_security_info
                            ,p_old_age_contribution          => l_csr_sii_details.old_age_contribution
                            ,p_pension_contribution          => l_csr_sii_details.pension_contribution
                            ,p_sickness_contribution         => l_csr_sii_details.sickness_contribution
                            ,p_work_injury_contribution      => l_csr_sii_details.work_injury_contribution
                            ,p_labor_contribution            => l_csr_sii_details.labor_contribution
                            ,p_health_contribution           => l_csr_sii_details.health_contribution
                            ,p_unemployment_contribution     => l_csr_sii_details.unemployment_contribution
                            ,p_old_age_cont_end_reason       => l_csr_sii_details.old_age_cont_end_reason
                            ,p_pension_cont_end_reason       => l_csr_sii_details.pension_cont_end_reason
                            ,p_sickness_cont_end_reason      => l_csr_sii_details.sickness_cont_end_reason
                            ,p_work_injury_cont_end_reason   => l_csr_sii_details.work_injury_cont_end_reason
                            ,p_labor_fund_cont_end_reason    => l_csr_sii_details.labor_fund_cont_end_reason
                            ,p_health_cont_end_reason        => l_csr_sii_details.health_cont_end_reason
                            ,p_unemployment_cont_end_reason  => l_csr_sii_details.unemployment_cont_end_reason
                            ,p_sii_details_id                => l_temp_details_id              --out var
                            ,p_object_version_number         => l_temp_ovn                     --out var
                            ,p_effective_start_date          => l_temp_effective_start_date    --out var
                            ,p_effective_end_date            => l_temp_effective_end_date      --out var
                            ,p_effective_date_warning        => l_temp_effective_date_warning  --out var
                            );
           else
               close csr_sii_details;--non terminated one closed
           end if;--csr_sii_details found--  non-terminated record

     end if;--csr_sii_details%found  terminated record
if p_debug then
hr_utility.set_location(l_proc,60);
end if;
end loop;

if p_debug then
hr_utility.set_location('Leaving: '||l_proc, 100);
end if;

End Actual_term_sii_tax_records;--End of procedure


end PAY_PL_POST_TERMINATION_PKG;


/
