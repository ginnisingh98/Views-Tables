--------------------------------------------------------
--  DDL for Package Body PAY_ZA_BANK_DDF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_BANK_DDF_UPD" AS
/* $Header: pyzabnku.pkb 120.0.12010000.2 2010/03/24 08:55:58 rbabla noship $ */

PROCEDURE qualify_bnk_update(
            p_assignment_id number
          , p_qualifier out nocopy varchar2) AS

--Check if the assignment is either active or terminated after tax year start of 2010 year
cursor csr_assignments
is
select 1
from   per_all_assignments_f paaf
where  paaf.effective_end_date >= to_date('01/03/2009','dd/mm/yyyy')
and    paaf.assignment_id     = p_assignment_id
and    paaf.business_group_id in (select business_group_id
                                  from per_business_groups
                                  where legislation_code='ZA');


l_exists number;

begin

      hr_utility.set_location('Entering qualify_bnk_update',10);
      p_qualifier :='N';
      open csr_assignments;
      fetch csr_assignments into l_exists;
      if csr_assignments%found then
             p_qualifier := 'Y';
      end if;
      close csr_assignments;
      hr_utility.set_location('Exiting qualify_bnk_update',10);

END qualify_bnk_update;

PROCEDURE update_bnk(p_assignment_id number) IS

-- Cursor to fetch all the eligible assignments for the bank DDF update
cursor csr_ppm_category
is
select ppt.payment_type_name, ppymf.personal_payment_method_id,
       ppymf.object_version_number, ppymf.effective_start_date
from   pay_personal_payment_methods_f ppymf
     , pay_org_payment_methods_f popmf
     , pay_payment_types ppt
where ppt.territory_code='ZA'
and   ppt.payment_type_name in ('Cheque','Credit Transfer','Manual Payment','ACB')
and   popmf.payment_type_id = ppt.payment_type_id
and   popmf.effective_end_date = (select max(effective_end_date)
                                  from pay_org_payment_methods_f popmf2
                                  where popmf.org_payment_method_id = popmf2.org_payment_method_id)
and   ppymf.org_payment_method_id = popmf.org_payment_method_id
and   ppymf.assignment_id = p_assignment_id
and   ppymf.ppm_information_category is null
for update of ppymf.personal_payment_method_id;

l_object_version_number number;
l_effective_start_date date;
l_effective_end_date   date;
l_comment_id                 number;
l_external_account_id        number;
l_assignment_id              number;
l_legislation_code           varchar2(3) :='ZA';

BEGIN

    -- call the procedure for each of the assignment_action_id's fetched
    hr_utility.set_location('Entering update_bnk',10);
    hr_utility.set_location('p_assignment_id = '  || p_assignment_id,30);

    l_assignment_id := p_assignment_id;
    hr_utility.set_location('Assignment_id = '||l_assignment_id,33);
    FOR rec_ppm_category in csr_ppm_category
    LOOP
        begin
            hr_utility.set_location('Updating PER_PAY_METH_ID:'||rec_ppm_category.personal_payment_method_id,34);
            l_object_version_number := rec_ppm_category.object_version_number;
/*
            hr_personal_pay_method_api.update_personal_pay_method
            (
                P_VALIDATE                  => false
               ,P_EFFECTIVE_DATE            => rec_ppm_category.effective_start_date
               ,P_DATETRACK_UPDATE_MODE     => 'CORRECTION'
               ,p_personal_payment_method_id=> rec_ppm_category.personal_payment_method_id
               ,p_ppm_information_category  => l_legislation_code||'_'||upper(rec_ppm_category.payment_type_name)
               ,P_OBJECT_VERSION_NUMBER     => l_object_version_number
               ,P_COMMENT_ID                => l_comment_id
               ,P_EXTERNAL_ACCOUNT_ID       => l_external_account_id
               ,P_EFFECTIVE_START_DATE      => l_effective_start_date
               ,P_EFFECTIVE_END_DATE        => l_effective_end_date
            );
*/
            update pay_personal_payment_methods_f
	    set    ppm_information_category   = l_legislation_code||'_'||upper(rec_ppm_category.payment_type_name)
	    where  personal_payment_method_id = rec_ppm_category.personal_payment_method_id;

            hr_utility.set_location('Updated PER_PAY_METH_ID:'||rec_ppm_category.personal_payment_method_id,34);

        exception
            WHEN others then
              hr_utility.set_location('Inside exception for PER_PAY_METH_ID :'||rec_ppm_category.personal_payment_method_id,34);

        end;

    END LOOP;

    hr_utility.set_location('Exiting update_bnk',50);
END update_bnk;

END PAY_ZA_BANK_DDF_UPD ;

/
