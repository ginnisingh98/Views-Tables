--------------------------------------------------------
--  DDL for Package Body PER_PL_TERMINATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_TERMINATION" as
/* $Header: peplterp.pkb 120.0 2006/03/01 22:41:38 mseshadr noship $ */

PROCEDURE REVERSE(p_period_of_service_id      per_periods_of_service.period_of_service_id%TYPE
                  ,p_actual_termination_date  per_periods_of_service.actual_termination_date%TYPE
                  ,p_leaving_reason           per_periods_of_service.leaving_reason%TYPE) is

cursor csr_normal_assignments is
    select  distinct(paaf.assignment_id)
      from  per_all_assignments_f       paaf
           ,per_assignment_status_types past
           ,hr_soft_coding_keyflex      kyflex
      where paaf.period_of_service_id=p_period_of_service_id
       and  (p_actual_termination_date+1) between paaf.effective_start_date
                                          and    paaf.effective_end_date
       and   paaf.assignment_status_type_id=past.assignment_status_type_id
       and   past.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
       and   kyflex.soft_coding_keyflex_id=paaf.soft_coding_keyflex_id
       and   kyflex.segment3='NORMAL';

cursor csr_term_paye_records(r_per_or_asg_id  number)is
   select   paye_details_id
           ,object_version_number ovn
           ,effective_start_date
     from   pay_pl_paye_details_f
     where  per_or_asg_id=r_per_or_asg_id
     and    contract_category='TERM_NORMAL';

cursor csr_term_sii_records(r_per_or_asg_id  number)is
   select   sii_details_id
           ,object_version_number ovn
           ,effective_start_date
     from   pay_pl_sii_details_f
     where  per_or_asg_id=r_per_or_asg_id
     and    contract_category='TERM_NORMAL';


l_csr_term_sii_records  csr_term_sii_records%rowtype;
l_csr_term_paye_records csr_term_paye_records%rowtype;
l_temp_effective_start_date  date;
l_temp_effective_end_date    date;
l_debug                      boolean;
l_proc                       varchar2(26);
Begin

--Find all non terminated normal contracts
--that are not terminated as on actual_termination_date+1
--if exists,check if they have sii/tax record.If they do,zap the sii/tax record

l_debug:=hr_utility.debug_enabled;

--If performing any HR related validation
--after post termination,call chk_product_install for
--Oracle Human Resources also.


 IF NOT hr_utility.chk_product_install( p_product        =>'Oracle Payroll'
                                        ,p_legislation    =>'PL'
                                        ,p_language       =>'US'
                                       ) then
     if l_debug then
         hr_utility.trace('PL PAY not installed.Not performing validations');
     end if;
     return; -- Polish HR not installed
 End if;

if l_debug then
   l_proc:='PER_PL_TERMINATION.REVERSE';
   hr_utility.set_location('Entering: '||l_proc,10);
end if;

for i in csr_normal_assignments loop

if l_debug then
   hr_utility.set_location(l_proc ,i.assignment_id);
end if;
   open  csr_term_paye_records(r_per_or_asg_id=>i.assignment_id);
   fetch csr_term_paye_records into l_csr_term_paye_records;
      if csr_term_paye_records%found then
             close csr_term_paye_records;
             --zap the unwanted record
             if l_debug then
                 hr_utility.trace('Calling Paye Zap');
             end if;
             pay_pl_paye_api.delete_pl_paye_details
                 (p_validate                =>false
                 ,p_effective_date          =>l_csr_term_paye_records.effective_start_date
                 ,p_datetrack_delete_mode   =>'ZAP'
                 ,p_paye_details_id          =>l_csr_term_paye_records.paye_details_id
                 ,p_object_version_number   =>l_csr_term_paye_records.ovn
                 ,p_effective_start_date    =>l_temp_effective_start_date
                 ,p_effective_end_date      =>l_temp_effective_start_date
                 );
      else
           close csr_term_paye_records;
      end if;

 if l_debug then
    hr_utility.set_location(l_proc ,15);
 end if;
    --Paye records processed.SII record next

   open  csr_term_sii_records(r_per_or_asg_id=>i.assignment_id);
   fetch csr_term_sii_records into l_csr_term_sii_records;
      if csr_term_sii_records%found then
             close csr_term_sii_records;
             --zap the unwanted record
             if l_debug then
                 hr_utility.trace('Calling SII Zap');
             end if;
             pay_pl_sii_api.delete_pl_sii_details
                 (p_validate                =>false
                 ,p_effective_date          =>l_csr_term_sii_records.effective_start_date
                 ,p_datetrack_delete_mode   =>'ZAP'
                 ,p_sii_details_id          =>l_csr_term_sii_records.sii_details_id
                 ,p_object_version_number   =>l_csr_term_sii_records.ovn
                 ,p_effective_start_date    =>l_temp_effective_start_date
                 ,p_effective_end_date      =>l_temp_effective_start_date
                 );
      else
           close csr_term_sii_records;
      end if;

if l_debug then
    hr_utility.set_location(l_proc ,20);
 end if;

end loop;

if l_debug then
   hr_utility.set_location('Leaving: '||l_proc,30);
end if;

End REVERSE;
PROCEDURE ACTUAL_TERMINATION_EMP(p_period_of_service_id    per_periods_of_service.period_of_service_id%TYPE
                                ,p_actual_termination_date per_periods_of_service.actual_termination_date%TYPE
                                ,p_business_group_id       NUMBER) is
-------------------------------------------------------------------------+
--                                                                      -+
-- Name           : ACTUAL_TERMINATION_EMP                              -+
-- Type           : Procedure                                           -+
-- Access         : Public                                              -+
-- Description    : Polish leg hook to be called when person type       -+
--                  employee is Terminated.                             -+
--                                                                      -+
--                 1)Check if Polish HR is installed before performing  -+
--                   any validation                                     -+
--                 2)Check if Payroll is installed.If yes,call package  -+
--                   procedure to create/modify  SII and Tax records    -+
--                                                                      -+
-------------------------------------------------------------------------+


l_debug boolean;
l_proc varchar2(41);
Begin
l_debug:=hr_utility.debug_enabled;

 if l_debug then
    l_proc:='PER_PL_TERMINATION.ACTUAL_TERMINATION_EMP';
    hr_utility.set_location(l_proc,10);
 end if;


  IF NOT hr_utility.chk_product_install( p_product        =>'Oracle Human Resources'
                                         ,p_legislation    =>'PL'
                                         ,p_language       =>'US'
                                        ) then
     if l_debug then
         hr_utility.set_location(l_proc,20);
         hr_utility.trace('PL PER not installed.Not performing validations');
     end if;

     return; -- Polish HR not installed


  End if;

--Place anymore hr related logic here.
--calls to Payroll related pkg to be done after
--checking Polish Payroll Installation.


  IF hr_utility.chk_product_install( p_product      =>'Oracle Payroll'         --should use PAY :)
                                     ,p_legislation =>'PL'
                                     ,p_language    =>'US'
                                    ) then
     if l_debug then
         hr_utility.set_location(l_proc,30);
     end if;

Pay_PL_POST_TERMINATION_PKG.Actual_term_sii_tax_records( p_debug                    => l_debug
                                                        ,p_period_of_service_id     => p_period_of_service_id
                                                        ,p_actual_termination_date  => p_actual_termination_date
                                                        ,p_business_group_id        => p_business_group_id
                                                       );
  End if;

 if l_debug then
         hr_utility.set_location(l_proc,40);
 end if;
END Actual_Termination_Emp;
End PER_PL_TERMINATION;


/
