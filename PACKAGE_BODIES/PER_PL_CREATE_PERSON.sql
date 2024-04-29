--------------------------------------------------------
--  DDL for Package Body PER_PL_CREATE_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_CREATE_PERSON" as
/* $Header: peplconp.pkb 120.6.12010000.1 2008/07/28 05:19:39 appldev ship $ */
g_package   VARCHAR2(30);

/*** Flexfield Segments Used ****/
/*  p_per_information1 : NIP
    p_per_information2 : Insured by Employee
    p_per_information3 : Inheritor
    p_per_information4 : Oldage Pension Rights
    p_per_information5 : National Fund of Health
    p_per_information6 : Tax office
    p_per_information7 : Legal Employer
    p_per_information8 : Citizenship.

*/

PROCEDURE create_pl_person(p_last_name   VARCHAR2
                          ,p_first_name  VARCHAR2
                          ,p_date_of_birth DATE
                          ,p_marital_status VARCHAR2
                          ,p_nationality  VARCHAR2
                          ,p_national_identifier VARCHAR2
                          ,p_business_group_id NUMBER
                          ,p_sex VARCHAR2
                          ,p_person_type_id   NUMBER
                          ,p_per_information1 VARCHAR2
                          ,p_per_information2 VARCHAR2
                          ,p_per_information3 VARCHAR2
                          ,p_per_information4 VARCHAR2
                          ,p_per_information5 VARCHAR2
                          ,p_per_information6 VARCHAR2
                          ,p_per_information7 VARCHAR2
                          ,p_per_information8 VARCHAR2) IS

l_proc          VARCHAR2(72);
l_package       VARCHAR2(30);
l_person_type_key per_person_types.seeded_person_type_key%TYPE;
l_system_type     per_person_types.system_person_type%TYPE;
l_var             varchar2(1);
cursor csr_contact_per is
select 'Y' from per_person_types ppt
    where ppt.seeded_person_type_key = l_person_type_key and ppt.system_person_type = l_system_type
      and ppt.business_group_id = p_business_group_id
      and ppt.person_type_id = p_person_type_id;


BEGIN
g_package := 'PER_PL_CREATE_PERSON.';
l_proc    := g_package||'CREATE_PL_PERSON';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;
l_person_type_key := 'CONTACT';
l_system_type     := 'OTHER';
l_var := NULL;


       hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','LAST'),
              p_argument_value   => p_last_name
             );



open csr_contact_per;
fetch csr_contact_per into l_var;
close csr_contact_per;

  if l_var = 'Y' then

 /********************Person is of type contact **************************/

    if p_per_information3 = 'Y' or p_per_information2 = 'Y' then

--Insured by is yes or Inheritor is yes.Citizenship and First Name are required.
-- Bug 4567534 : Replaced hr_api.mandatory_arg_error with an error message.
       if p_first_name is NULL then
          hr_utility.set_message(800,'HR_375873_FIRST_NAME_REQD');
          hr_utility.raise_error;
       end if;

        hr_api.mandatory_arg_error
               (p_api_name         => l_proc,
                p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','CITIZENSHIP'),
                p_argument_value   => p_per_information8
               );


  /* After NIP/PESEL enhancement ,If Inheritor is Yes ,
     Nationality and Citizenship are both Polish then NIP is mandatory */
 /* Commented by nprasath for Bug 6272487
   If p_per_information3='Y' and p_per_information8='PL' and p_nationality='PQH_PL' then

      -- Bug 4567534 : Replaced hr_api.mandatory_arg_error with an error message
       if p_per_information1 is NULL then
          hr_utility.set_message(800,'HR_375874_NIP_REQD');
          hr_utility.raise_error;
       end if;

    End if; -- End if of Inherited by employee in 'Yes' and nationality and citizenship are Polish
 */

    IF p_per_information2 = 'Y' then
          hr_api.mandatory_arg_error
                (p_api_name         => l_proc,
                 p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','BIRTH'),
                 p_argument_value   => p_date_of_birth
                 );
         --If Insured by is yes and nationality and citizenship are both polish ,
         --either of NIP or PESEL needs to be entered.

        IF p_nationality = 'PQH_PL' and  p_per_information8='PL' and p_per_information1||p_national_identifier is null   then
             hr_utility.set_message(800,'HR_375878_NIP_OR_PESEL');
             hr_utility.raise_error;
        END IF;  -- End if of Nationality in Polish,Insured by is Yes,nationality and citizenship are POLISH

     END IF; -- End if of Insured by Employee in 'Yes'
  END IF;--per_information2 or per_information3 is yes?
END IF; --l_var = 'Y'
/********************************** End if of Person Type in Contact***********************/

     if p_national_identifier is not NULL then
        hr_pl_utility.per_pl_validate(p_national_identifier);
        if p_per_information7 is not null then
           hr_pl_utility.per_pl_check_ni_unique(p_national_identifier,0,p_business_group_id,p_per_information7);
        end if;
     end if;

      if p_per_information1 is not null then
          hr_pl_utility.per_pl_nip_validate(p_per_information1,0,p_business_group_id,p_per_information7,p_nationality,p_per_information8
                                            );
      end if;


END create_pl_person;

END PER_PL_CREATE_PERSON;

/
