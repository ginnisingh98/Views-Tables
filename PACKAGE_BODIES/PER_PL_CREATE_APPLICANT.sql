--------------------------------------------------------
--  DDL for Package Body PER_PL_CREATE_APPLICANT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_CREATE_APPLICANT" as
/* $Header: peplappp.pkb 120.2 2006/09/13 10:44:06 mseshadr noship $ */

PROCEDURE CREATE_PL_APPLICANT(p_last_name VARCHAR2
                             ,p_first_name VARCHAR2
                             ,p_national_identifier VARCHAR2
                             ,p_business_group_id NUMBER
                             ,p_nationality  VARCHAR2
                             ,p_per_information1 VARCHAR2
                             ,p_per_information2 VARCHAR2
                             ,p_per_information3 VARCHAR2
                             ,p_per_information4 VARCHAR2
                             ,p_per_information5 VARCHAR2
                             ,p_per_information6 VARCHAR2
                             ,p_per_information7 VARCHAR2
                             ,p_per_information8 VARCHAR2

                              )  is
l_proc VARCHAR2(72);
BEGIN
       g_package := 'PER_PL_CREATE_APPLICANT.';
       l_proc := g_package||'CREATE_PL_APPLICANT';
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


    if p_national_identifier is not null then
       hr_pl_utility.per_pl_validate(p_national_identifier);
       if p_per_information7 is not null then
           hr_pl_utility.per_pl_check_ni_unique(p_national_identifier,0,p_business_group_id,
                                                p_per_information7);
       end if;
    end if;

    if p_per_information1 is not null then
       hr_pl_utility.per_pl_nip_validate(p_per_information1,0,p_business_group_id,          						 p_per_information7,p_nationality,p_per_information8
                                         );
    end if;

END create_pl_applicant;

END PER_PL_CREATE_APPLICANT;

/
