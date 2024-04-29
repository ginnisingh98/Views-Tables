--------------------------------------------------------
--  DDL for Package Body HR_NL_EXTRA_PERSON_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NL_EXTRA_PERSON_RULES" AS
  /* $Header: penlexpr.pkb 120.1.12000000.2 2007/02/28 10:57:58 spendhar ship $ */
  --
  -- First Name, SOFI Number and Initials must be not null.
  -- Lookup code for Academic Title must be valid.
  --
  -- Note: Supports both real and API system values (these are passed when the value has not
  --       been changed.
  --
  PROCEDURE extra_person_checks
  (p_first_name          IN varchar2,
   p_national_identifier IN varchar2,
   p_honors              IN varchar2,
   p_per_information1    IN varchar2,
   p_per_information4    IN varchar2) IS

  l_lookup_meaning varchar2(50);

  BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'NL') THEN
    --
    if p_first_name is null then
      hr_utility.set_message(800, 'HR_NL_REQUIRED_FIELD');
      hr_utility.set_message_token('FIELD','First Name');
          hr_utility.set_message_token('LEG_CODE','NL');
     hr_utility.raise_error;
    end if;

    if (p_national_identifier is null OR p_national_identifier = hr_api.g_varchar2) AND NVL(fnd_profile.value('HR_NL_NI_OPTIONAL'),'N') = 'N'
      AND fnd_profile.VALUE('PER_NATIONAL_IDENTIFIER_VALIDATION') in ('ERROR','WARN')   /* bug 4570899*/ then
      hr_utility.set_message(800, 'HR_NL_REQUIRED_FIELD');
      hr_utility.set_message_token('FIELD','SOFI Number');
      hr_utility.set_message_token('LEG_CODE','NL');
      hr_utility.raise_error;
   end if;

    if p_per_information1 is null then
      hr_utility.set_message(800, 'HR_NL_REQUIRED_FIELD');
      hr_utility.set_message_token('FIELD','Initials');
          hr_utility.set_message_token('LEG_CODE','NL');
      hr_utility.raise_error;
    end if;

    if p_per_information4 is null then
      hr_utility.set_message(800, 'HR_NL_REQUIRED_FIELD');
      hr_utility.set_message_token('FIELD','Full Name Format');
          hr_utility.set_message_token('LEG_CODE','NL');
      hr_utility.raise_error;
    end if;
   END IF;
  END extra_person_checks;

  /* Procedure checks if parameters reported in
   the Dutch First Day Report have been changed
   after report has been generated. If the
   parameters are changed, then RESEND flag in
   First Day Report Information EIT is set to
   YES.
*/
PROCEDURE fdr_update_check
 ( P_PERSON_ID per_all_people_f.person_id%TYPE
 , P_DATE_OF_BIRTH date
 , P_PER_INFORMATION1 varchar2
 , P_PRE_NAME_ADJUNCT per_all_people_f.PRE_NAME_ADJUNCT%TYPE default ' '
 , P_LAST_NAME per_all_people_f.LAST_NAME%TYPE
 , P_EFFECTIVE_DATE date default to_date('01/01/4712','DD/MM/YYYY')
 , P_NATIONAL_IDENTIFIER per_all_people_f.NATIONAL_IDENTIFIER%TYPE
 , P_EMPLOYEE_NUMBER per_all_people_f.EMPLOYEE_NUMBER%TYPE) IS

   l_hiredate date;
   l_initial varchar2(20);
   l_sofi per_all_people_f.national_identifier%TYPE;
   l_dob per_all_people_f.DATE_OF_BIRTH%TYPE;
   l_prefix per_all_people_f.PRE_NAME_ADJUNCT%TYPE;
   l_last_name per_all_people_f.LAST_NAME%TYPE;
   l_employee_num per_all_people_f.EMPLOYEE_NUMBER%TYPE;

   l_resend_enabled number := 0;
   l_ext_info_id per_people_extra_info.PERSON_EXTRA_INFO_ID%type;
   l_ovn per_people_extra_info.OBJECT_VERSION_NUMBER%TYPE;

   CURSOR resend_enabled(p_csr_person_id PER_PEOPLE_EXTRA_INFO.person_id%TYPE) IS
    SELECT count(*)
     FROM PER_PEOPLE_EXTRA_INFO
     WHERE PERSON_ID = p_csr_person_id
     AND INFORMATION_TYPE = 'NL_FIRST_DAY_REPORT'
     AND PEI_INFORMATION_CATEGORY = 'NL_FIRST_DAY_REPORT'
     AND upper(pei_information2) = 'Y';


    CURSOR person_previous_information(p_csr_person_id PER_PEOPLE_EXTRA_INFO.person_id%TYPE) IS
    SELECT DATE_OF_BIRTH
          ,PER_INFORMATION1
          ,PRE_NAME_ADJUNCT
          ,LAST_NAME
          ,NATIONAL_IDENTIFIER
          ,EMPLOYEE_NUMBER
     FROM per_all_people_f
     WHERE person_id = p_csr_person_id
     AND  P_EFFECTIVE_DATE BETWEEN EFFECTIVE_START_DATE
                               AND EFFECTIVE_END_DATE
     AND business_group_id in (SELECT business_group_id
                               FROM per_business_groups
                               WHERE legislation_code = 'NL');

    BEGIN
    /* Fetching information prior to changes made */

    OPEN person_previous_information(p_person_id);
    FETCH person_previous_information into
          l_dob,
          l_initial,
          l_prefix,
          l_last_name,
          l_sofi,
          l_employee_num;
     CLOSE person_previous_information;

     /*If parameters are not supplied */

      IF P_EMPLOYEE_NUMBER = NULL THEN
        l_employee_num := P_EMPLOYEE_NUMBER;
      END IF;

      IF P_LAST_NAME = hr_api.g_varchar2 THEN
       l_last_name := P_LAST_NAME;
      END IF;

      IF P_PER_INFORMATION1 = hr_api.g_varchar2 THEN
       l_initial := P_PER_INFORMATION1;
      END IF;

      IF P_NATIONAL_IDENTIFIER = hr_api.g_varchar2 THEN
       l_sofi := P_NATIONAL_IDENTIFIER;
      END IF;

     /* If resend flag is already set to YES
       , then need not to set it to yes again .*/

     OPEN resend_enabled(p_person_id);
     FETCH resend_enabled into l_resend_enabled;
     CLOSE resend_enabled;

    /* If parameter's values have been changed,
       set resend_flag to YES .*/

     IF  (nvl(l_dob,to_date('01/01/4712','DD/MM/YYYY'))
                <> nvl(P_DATE_OF_BIRTH,to_date('01/01/4712','DD/MM/YYYY')) OR
          nvl(l_prefix,' ')    <> nvl(P_PRE_NAME_ADJUNCT,' ') OR
          l_last_name          <> p_last_name OR
          l_initial            <> P_PER_INFORMATION1 OR
          --l_sofi               <> P_NATIONAL_IDENTIFIER OR
          (l_sofi is not NULL and P_NATIONAL_IDENTIFIER is not NULL and l_sofi <> P_NATIONAL_IDENTIFIER) OR
          (l_sofi is not NULL and P_NATIONAL_IDENTIFIER is NULL) OR
          (l_sofi is NULL and P_NATIONAL_IDENTIFIER is not NULL) OR
          l_employee_num       <> P_EMPLOYEE_NUMBER)
          AND l_resend_enabled = 0 THEN

         IF p_person_id IS NOT NULL THEN
           HR_PERSON_EXTRA_INFO_API. create_person_extra_info
                      (p_person_id => p_PERSON_ID,
                       p_information_type => 'NL_FIRST_DAY_REPORT',
                       p_pei_information2 => 'Y',
                       p_person_extra_info_id => l_ext_info_id,
                       p_object_version_number => l_ovn,
                       p_pei_information_category => 'NL_FIRST_DAY_REPORT');
          END IF;
      END IF;

   END fdr_update_check;

 procedure fdr_rehire_check
 ( P_PERSON_ID per_all_people_f.person_id%TYPE) IS

  l_resend_enabled number := 0;
  l_ext_info_id per_people_extra_info.PERSON_EXTRA_INFO_ID%type;
  l_ovn per_people_extra_info.OBJECT_VERSION_NUMBER%TYPE;

  CURSOR resend_enabled(p_csr_person_id PER_PEOPLE_EXTRA_INFO.person_id%TYPE) IS
    SELECT count(*)
     FROM PER_PEOPLE_EXTRA_INFO
     WHERE PERSON_ID = p_csr_person_id
     AND INFORMATION_TYPE = 'NL_FIRST_DAY_REPORT'
     AND PEI_INFORMATION_CATEGORY = 'NL_FIRST_DAY_REPORT'
     AND upper(pei_information2) = 'Y';

  BEGIN

      /* If resend flag is already set to YES
       , then need not to set it to yes again .*/

     OPEN resend_enabled(p_person_id);
     FETCH resend_enabled into l_resend_enabled;
     CLOSE resend_enabled;

    /* If parameter's values have been changed,
       set resend_flag to YES .*/

     IF  l_resend_enabled = 0 THEN

         IF p_person_id IS NOT NULL THEN
           HR_PERSON_EXTRA_INFO_API. create_person_extra_info
                      (p_person_id => p_PERSON_ID,
                       p_information_type => 'NL_FIRST_DAY_REPORT',
                       p_pei_information2 => 'Y',
                       p_person_extra_info_id => l_ext_info_id,
                       p_object_version_number => l_ovn,
                       p_pei_information_category => 'NL_FIRST_DAY_REPORT');
          END IF;
      END IF;
  END fdr_rehire_check;

END hr_nl_extra_person_rules;

/
