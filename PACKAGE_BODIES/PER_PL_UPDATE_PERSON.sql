--------------------------------------------------------
--  DDL for Package Body PER_PL_UPDATE_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_UPDATE_PERSON" AS
/* $Header: peplperp.pkb 120.9.12010000.1 2008/07/28 05:21:29 appldev ship $ */

PROCEDURE update_pl_person (p_person_type_id  number
                           ,p_last_name   VARCHAR2
                           ,p_first_name  VARCHAR2
                           ,p_date_of_birth DATE
                           ,p_marital_status VARCHAR2
                           ,p_nationality  VARCHAR2
                           ,p_national_identifier VARCHAR2
                           ,p_per_information1 VARCHAR2
                           ,p_person_id number
                           ,p_effective_date date
                           ,p_per_information2 VARCHAR2
                           ,p_per_information3 VARCHAR2
                           ,p_per_information4 VARCHAR2
                           ,p_per_information5 VARCHAR2
                           ,p_per_information6 VARCHAR2
                           ,p_per_information7 VARCHAR2
                           ,p_per_information8 VARCHAR2) is

l_contact_type_key per_person_types.seeded_person_type_key%TYPE;
l_emp_type_key per_person_types.seeded_person_type_key%TYPE;
l_app_type_key per_person_types.seeded_person_type_key%TYPE;
l_cwk_type_key per_person_types.seeded_person_type_key%TYPE;
l_chk varchar2(1);
l_con varchar2(1);
l_app varchar2(1);
l_cwk varchar2(1);
l_proc varchar2(72);
per_business_group_id per_all_people_f.business_group_id%TYPE;
identifier_chk varchar2(1);
assg_payroll_id per_all_assignments_f.payroll_id%TYPE;

cursor csr_per_value is
   select papf.business_group_id, papf.nationality, papf.national_identifier, papf.per_information1,
          papf.per_information2,papf.per_information3,papf.per_information8
   from per_all_people_f papf
  where  papf.person_id = p_person_id and
   p_effective_date between papf.effective_start_date and papf.effective_end_date;

l_csr_per_value  csr_per_value%rowtype;
cursor csr_person_type(p_person_type_key char) is
   select 'Y' from per_person_types ppt, per_person_type_usages_f pptu
    where ppt.person_type_id = pptu.person_type_id and
          pptu.person_id = p_person_id and
          ppt.business_group_id = per_business_group_id and
          ppt.seeded_person_type_key = p_person_type_key and
          p_effective_date between pptu.effective_start_date and pptu.effective_end_date;

cursor csr_payroll_id is
   select payroll_id from per_all_assignments_f paaf where paaf.person_id = p_person_id and
   p_effective_date between paaf.effective_start_date and paaf.effective_end_date;


BEGIN

l_emp_type_key := 'EMPLOYEE'; -- This is the System Person Type Key for an Employee
l_contact_type_key := 'CONTACT'; -- This is the System Person Type Key for a Contact
l_app_type_key  := 'APPLICANT';  -- This is the Seeded Person type for an Applicant
l_cwk_type_key  := 'CWK';        -- This is the Seeded Person type for a Contingent
l_chk := NULL;
l_con := NULL;
l_app := NULL;
l_cwk := NULL;
per_business_group_id := NULL;
l_proc := 'PER_PL_UPDATE_PERSON.UPDATE_PL_PERSON';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;

identifier_chk := NULL;
assg_payroll_id := NULL;

    open csr_per_value;
    fetch csr_per_value into l_csr_per_value;
    close csr_per_value;

per_business_group_id:=l_csr_per_value.business_group_id;

    OPEN csr_person_type(l_emp_type_key);  /** Person Type 'Employee' ***/
    FETCH csr_person_type into l_chk;
    CLOSE csr_person_type;

    OPEN csr_person_type(l_contact_type_key);  /** Person Type 'Contact' ***/
    FETCH csr_person_type into l_con;
    CLOSE csr_person_type;


    OPEN csr_person_type(l_app_type_key);  /** Person Type 'Applicant ***/
    FETCH csr_person_type into l_app;
    CLOSE csr_person_type;


    OPEN csr_person_type(l_cwk_type_key);  /** Person Type 'Contingent' ***/
    FETCH csr_person_type into l_cwk;
    CLOSE csr_person_type;


       hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','LAST'),
              p_argument_value   => p_last_name
             );

if l_chk = 'Y' then -- Person Type is an Employee

       hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','FIRST'),
              p_argument_value   => p_first_name
             );

       hr_api.mandatory_arg_error
              (p_api_name         => l_proc,
               p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','STATUS'),
               p_argument_value   => p_marital_status
              );

       hr_api.mandatory_arg_error
              (p_api_name         => l_proc,
               p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','NAT'),
               p_argument_value   => p_nationality
              );

          hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','BIRTH'),
              p_argument_value   => p_date_of_birth
             );
/*legal employer mandatory for employee*/
          hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','LEGAL_EMPLOYER'),
              p_argument_value   => p_per_information7
             );
--Citizenship Mandatory for Employee.
       hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','CITIZENSHIP'),
              p_argument_value   => p_per_information8
             );

--National Fund of Health Mandatory for Employee.
       hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','NATIONAL_FUND_OF_HEALTH'),
              p_argument_value   => p_per_information5
             );
--Modified the condition to check for PESEL and NIP.
--NIP and PESEL are mandatory if both Nationality and Citizenship are Polish.
       --if p_nationality = 'PQH_PL' or (p_nationality = hr_api.g_varchar2 and l_csr_per_value.nationality = 'PQH_PL') then

       if ((p_nationality = 'PQH_PL' or (p_nationality = hr_api.g_varchar2 and l_csr_per_value.nationality = 'PQH_PL'))
           and
           (p_per_information8 = 'PL' or (p_per_information8= hr_api.g_varchar2 and l_csr_per_value.per_information8 = 'PL'))
          )then
         if p_national_identifier is NULL or (p_national_identifier = hr_api.g_varchar2 and l_csr_per_value.national_identifier is null) then
	/* Bug fix 4627784 add check fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') in ('ERROR','WARN') */
	       if fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') in ('ERROR','WARN') then
			hr_api.mandatory_arg_error
	                (p_api_name         => l_proc,
 	                 p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','PESEL'),
	                 p_argument_value   => identifier_chk
 	               );
	      end if;
         end if;
        /* Commented by nprasath for Bug 6272487
	  if p_per_information1 is NULL or (p_per_information1 = hr_api.g_varchar2 and l_csr_per_value.per_information1 is null) then
              hr_api.mandatory_arg_error
                (p_api_name         => l_proc,
                 p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','NIP'),
                 p_argument_value   => identifier_chk  --passing this value as it is bound to fail
                );
         end if; */
      end if;--NIP/PESEL check

   open csr_payroll_id;
   fetch csr_payroll_id into assg_payroll_id;
   close csr_payroll_id;

     /*  if assg_payroll_id is not NULL and p_per_information1 is NULL then
          hr_utility.set_message(800,'HR_NIP_REQUIRED_PL');
          hr_utility.raise_error;
       end if;
       Removing this check because according to latest requirement,
       NIP is needed for an Payroll only if nationality and citizenship are both Polish.
       If nationality and citizenship are Polish,we need to enter NIP by default.Hence no need for
       this redundant check.

   */

       /*Phase2 4340576 Oldage pension rights is required to attach payroll to any assignment  */
       if assg_payroll_id is not NULL  and p_per_information4 is null then
         hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
         hr_utility.set_message_token ('TOKEN',hr_general.decode_lookup('PL_FORM_LABELS','OLDAGE_PENSION_RIGHTS'));  --default translate false
         hr_utility.raise_error;
     end if;
       /* Tax office is required to attach payroll to any assignment*/
       if assg_payroll_id is not NULL  and p_per_information6 is null then
         hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
         hr_utility.set_message_token ('TOKEN',hr_general.decode_lookup('PL_FORM_LABELS','TAX_OFFICE'));  --default translate false
         hr_utility.raise_error;
      end if;

elsif l_con = 'Y' then     -- Person Type is Contact


    if (   ( p_per_information2 = 'Y' or (p_per_information2 = hr_api.g_varchar2 and l_csr_per_value.per_information2 = 'Y'))
        or ( p_per_information3 = 'Y' or (p_per_information3 = hr_api.g_varchar2 and l_csr_per_value.per_information3 = 'Y'))
       )  then

      -- Bug 4567534 : Replaced hr_api.mandatory_arg_error with an error message
     if p_first_name is null then
        hr_utility.set_message(800,'HR_375873_FIRST_NAME_REQD');
        hr_utility.raise_error;
     end if;

      --Citizenship Mandatory for contact if either insured by or inheritor is yes.
       hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','CITIZENSHIP'),
              p_argument_value   => p_per_information8
             );

           /*********************Validations surrounding Inheritor is Yes******************/
      /*  Commented by nprasath for Bug 6272487
        if (     (p_per_information3 = 'Y' or (p_per_information3 = hr_api.g_varchar2 and l_csr_per_value.per_information3 = 'Y'))
           and  (p_nationality = 'PQH_PL' or (p_nationality = hr_api.g_varchar2 and l_csr_per_value.nationality= 'PQH_PL'))
           and  (p_per_information8 = 'PL' or (p_per_information8= hr_api.g_varchar2 and l_csr_per_value.per_information8 = 'PL'))
          )   then

             -- Bug 4567534 : Replaced hr_api.mandatory_arg_error with an error message
               if p_per_information1 is null then
                  hr_utility.set_message(800,'HR_375874_NIP_REQD');
                  hr_utility.raise_error;
               end if;

        end if; */

       /**********Validations surrounding Insured by employee is Yes******************/
     if ( p_per_information2 = 'Y'   or (p_per_information2 = hr_api.g_varchar2 and l_csr_per_value.per_information2 = 'Y'))  then

          hr_api.mandatory_arg_error
          (p_api_name         => l_proc,
           p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','BIRTH'),
           p_argument_value   => p_date_of_birth
           );

       if ((p_nationality = 'PQH_PL'  or (p_nationality = hr_api.g_varchar2     and l_csr_per_value.nationality = 'PQH_PL'))
            and  (p_per_information8 = 'PL' or (p_per_information8= hr_api.g_varchar2 and l_csr_per_value.per_information8 = 'PL'))
           )then
          /* NIP/PESEL enhancement.If Insured by employee is yes and
             nationality and citizenship are polish,NIP or PESEL needs to be entered.*/


	   if(   ( p_per_information1 is null   and p_national_identifier is null )
	      or ((p_per_information1    = hr_api.g_varchar2 and l_csr_per_value.per_information1 is null)     --NIP is null
		   and (p_national_identifier = hr_api.g_varchar2 and l_csr_per_value.national_identifier is null)  --PESEL is null
		   )
              )then
              hr_utility.set_message(800,'HR_375878_NIP_OR_PESEL');
              hr_utility.raise_error;

            end if;  -- End if of Nationality and Citizenship is Polish
       end if;--p_per_information8='PL' or p_nationality='PQH_PL'
     end if;--Insured by Employee is yes

  end if; --one of Insured by or Inheritor is yes.


   /**End for Person type contact**/

elsif (l_cwk = 'Y' or l_app = 'Y') then

  -- This is neither a Contact nor an Employee (like Contingent/Applicant)

  hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','FIRST'),
              p_argument_value   => p_first_name
             );


end if;  -- End if of Person Type in 'Employee/Contact'



      if p_national_identifier is not null and p_national_identifier <> hr_api.g_varchar2 then
          hr_pl_utility.per_pl_validate(p_national_identifier);
           if p_per_information7 is not null then
              hr_pl_utility.per_pl_check_ni_unique(p_national_identifier,p_person_id,per_business_group_id,p_per_information7);
           end if;
      end if;

      if p_per_information1 is not null and p_per_information1 <> hr_api.g_varchar2 then
          hr_pl_utility.per_pl_nip_validate(p_per_information1,p_person_id,per_business_group_id,p_per_information7,p_nationality,
                                            p_per_information8);
      end if;


END update_pl_person;

END PER_PL_UPDATE_PERSON;

/
