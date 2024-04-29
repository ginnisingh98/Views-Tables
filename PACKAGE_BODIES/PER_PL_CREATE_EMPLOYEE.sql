--------------------------------------------------------
--  DDL for Package Body PER_PL_CREATE_EMPLOYEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_CREATE_EMPLOYEE" as
/* $Header: peplempp.pkb 120.6.12010000.1 2008/07/28 05:20:42 appldev ship $ */

PROCEDURE CREATE_PL_EMPLOYEE(p_last_name   VARCHAR2
                            ,p_first_name  VARCHAR2
                            ,p_date_of_birth DATE
                            ,p_marital_status VARCHAR2
                            ,p_nationality  VARCHAR2
                            ,p_national_identifier VARCHAR2
                            ,p_business_group_id NUMBER
                            ,p_sex VARCHAR2
                            ,p_per_information1 VARCHAR2
                            ,p_per_information2 VARCHAR2
                            ,p_per_information3 VARCHAR2
                            ,p_per_information4 VARCHAR2
                            ,p_per_information5 VARCHAR2
                            ,p_per_information6 VARCHAR2
                            ,p_per_information7 VARCHAR2
                            ,p_per_information8 VARCHAR2) is
l_proc VARCHAR2(72);

BEGIN
       l_proc := 'PER_PL_CREATE_EMPLOYEE.CREATE_PL_EMPLOYEE';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;
       hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','LAST'),
              p_argument_value   => p_last_name
             );

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

--Mandatory argument Sex is checked for in per_per_bus.chk_sex_title.

--Legal employer Mandatory for Employee.
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
  /*  Modifying after NIP /PESEL enhancement.
      PESEL and NIP mandatory if both Nationality and Citizenship are Polish */

       if  p_nationality = 'PQH_PL' and p_per_information8='PL' then
	/* Bug fix 4627784 add check fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') in ('ERROR','WARN') */
	      if fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') in ('ERROR','WARN') then
	          hr_api.mandatory_arg_error
 	            (p_api_name         => l_proc,
	             p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','PESEL'),
	             p_argument_value   => p_national_identifier
 	            );
  	      end if;
       /* Commented by nprasath for Bug 6272487
         hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','NIP'),
              p_argument_value   => p_per_information1
             ); */

         if p_national_identifier is not null and p_national_identifier <> hr_api.g_varchar2 then
            hr_pl_utility.per_pl_validate(p_national_identifier);
           if p_per_information7 is not null then
              hr_pl_utility.per_pl_check_ni_unique(p_national_identifier,0,p_business_group_id,p_per_information7);
           end if;
         end if;

          hr_pl_utility.per_pl_nip_validate(p_per_information1,0,p_business_group_id,p_per_information7,p_nationality,p_per_information8
                                           );

      elsif p_per_information1 is not null then
          hr_pl_utility.per_pl_nip_validate(p_per_information1,0,p_business_group_id,p_per_information7,p_nationality,p_per_information8
                                            );
      end if;

END create_pl_employee;

END PER_PL_CREATE_EMPLOYEE;

/
