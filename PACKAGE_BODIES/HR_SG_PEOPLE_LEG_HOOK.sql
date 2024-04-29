--------------------------------------------------------
--  DDL for Package Body HR_SG_PEOPLE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SG_PEOPLE_LEG_HOOK" AS
/* $Header: hrsglhpp.pkb 120.0 2005/05/31 02:41:44 appldev noship $ */
--
  g_package  VARCHAR2(33) := 'hr_sg_people_leg_hook.';
--
  procedure check_sg_legal_name( p_person_type_id  NUMBER
                                ,p_per_information1 VARCHAR2) IS
    l_proc         VARCHAR2(72) := g_package||'check_sg_legal_name';
    l_person_type  VARCHAR2(150);

  begin
    --
    -- It will raise an error if the Legal Name has not been entered
    -- when the person is EMPLOYEE
    --
    hr_utility.set_location('Entering:'|| l_proc, 10);

    if hr_multi_message.no_exclusive_error
         (p_check_column1 => 'PER_ALL_PEOPLE_F.PER_INFORMATION1'
         ) then
      if p_per_information1 is NULL then
        open  csr_val_person_type(p_person_type_id);
        fetch csr_val_person_type into l_person_type;
        close csr_val_person_type;
        if l_person_type like 'EMP%' then
          fnd_message.set_name('PAY', 'HR_SG_LEGAL_NAME_NULL');
          hr_multi_message.add
            (p_associated_column1 => 'PER_ALL_PEOPLE_F.PER_INFORMATION1'
            );
        end if;
      end if;
    end if;
    hr_utility.set_location('Leaving:'|| l_proc, 20);
  end check_sg_legal_name;

  procedure check_sg_income_tax( p_person_type_id      NUMBER
                                ,p_national_identifier VARCHAR2
                                ,p_per_information12   VARCHAR2) IS
    l_proc               VARCHAR2(72) := g_package||'check_sg_income_tax';
    l_system_person_type per_person_types.system_person_type%type;

  begin
    --
    -- It will raise an error if the income tax number has not been
    -- entered when the NRIC number is blank
    --
    hr_utility.set_location('Entering:'|| l_proc,10);

    OPEN  csr_val_person_type(p_person_type_id);
    FETCH csr_val_person_type INTO
          l_system_person_type;
    CLOSE csr_val_person_type;

    IF l_system_person_type like 'EMP%' THEN
       if hr_multi_message.no_exclusive_error
         (p_check_column1 => 'PER_ALL_PEOPLE_F.PER_INFORMATION12'
          ) then
          if p_national_identifier is NULL then
             if p_per_information12 is NULL then
                fnd_message.set_name('PAY','HR_SG_INCOME_TAX_NUMBER_NULL');
                hr_multi_message.add
                (p_associated_column1 => 'PER_ALL_PEOPLE_F.PER_INFORMATION12');
             end if;
          end if;
          hr_utility.set_location(' Leaving:'|| l_proc, 20);
       end if;
    END IF;
  end check_sg_income_tax;
end hr_sg_people_leg_hook;

/
