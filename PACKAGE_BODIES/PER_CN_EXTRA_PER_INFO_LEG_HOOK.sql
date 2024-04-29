--------------------------------------------------------
--  DDL for Package Body PER_CN_EXTRA_PER_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CN_EXTRA_PER_INFO_LEG_HOOK" AS
/* $Header: pecnlhep.pkb 120.0 2005/05/31 06:52 appldev noship $ */
--
--
   g_debug     BOOLEAN ;
   g_package   VARCHAR2(32) ;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_EXTRA_INFORMATION_EXISTS                      --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure is the driver procedure for the validation--
--                  of the Extra Person Information.                    --
--                  This procedure is the hook procedure for the        --
--                  Checking Extra person Information.                  --
-- Parameters     :                                                     --
--             IN :   p_person_extra_info_id     NUMBER                 --
--                    p_object_version_number    NUMBER                 --
--            OUT :   N/A                                               --
--         RETURN :   N/A                                               --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date          Userid    Description                            --
--------------------------------------------------------------------------
-- 1.0   13-Jul-2004   snekkala  Created this procedure                 --
--------------------------------------------------------------------------
PROCEDURE check_extra_information_exists
   (p_person_extra_info_id           IN NUMBER
   ,p_object_version_number          IN NUMBER
   )
IS
    l_person_extra_info_id per_people_extra_info.person_extra_info_id%TYPE;
    l_procedure            VARCHAR2(80);
    l_org_information_type per_people_extra_info.information_type%TYPE;
    l_departure_date       VARCHAR2(20);
    l_visa_number          VARCHAR2(80);

  CURSOR csr_get_org_information_type IS
     SELECT information_type
     FROM   per_people_extra_info
     WHERE  person_extra_info_id = p_person_extra_info_id;

 CURSOR csr_check_detail_info_exists IS
     SELECT detail.person_extra_info_id
     FROM   per_people_extra_info detail
     WHERE  detail.information_type = 'PER_ABROAD_DETAIL_INFO_CN'
     AND    p_person_extra_info_id=detail.pei_information1;

 CURSOR csr_check_visa_info_used IS
     SELECT detail.person_extra_info_id
     FROM   per_people_extra_info detail,per_people_extra_info visa
     WHERE  detail.information_type = 'PER_ABROAD_DETAIL_INFO_CN'
     AND    detail.pei_information5 = visa.pei_information1
     AND    visa.person_extra_info_id = p_person_extra_info_id;

 CURSOR csr_get_departure_date IS
     SELECT pei_information1
     FROM   per_people_extra_info
     WHERE  information_type = 'PER_ABROAD_MASTER_INFO_CN'
     AND    person_extra_info_id =  p_person_extra_info_id;

 CURSOR csr_get_visa_number IS
     SELECT pei_information1
     FROM   per_people_extra_info
     WHERE  information_type = 'PER_VISA_INFO_CN'
     AND    person_extra_info_id =  p_person_extra_info_id;

BEGIN
     l_procedure := g_package || 'check_extra_information_exists';
     g_debug := hr_utility.debug_enabled;

     OPEN csr_get_org_information_type;
     FETCH csr_get_org_information_type INTO l_org_information_type;
     CLOSE csr_get_org_information_type;

     IF l_org_information_type='PER_ABROAD_MASTER_INFO_CN' THEN
          hr_cn_api.set_location(g_debug,l_procedure,10);

	  OPEN csr_check_detail_info_exists;
          FETCH csr_check_detail_info_exists INTO l_person_extra_info_id;

	  IF csr_check_detail_info_exists%FOUND THEN

	     OPEN csr_get_departure_date;
	     FETCH csr_get_departure_date INTO l_departure_date;
	     CLOSE csr_get_departure_date;

	     CLOSE csr_check_detail_info_exists;

             l_departure_date:=fnd_date.date_to_displaydate(fnd_date.string_to_date(SUBSTR(l_departure_date,1,10),'YYYY/MM/DD'));

	     hr_cn_api.set_location(g_debug,l_procedure,20);
             hr_utility.set_message(800, 'HR_374619_FT_MASTER_EXISTS');
             hr_utility.set_message_token('FIELD1',l_departure_date);
             hr_utility.raise_error;
          END IF;
          CLOSE csr_check_detail_info_exists;

    ELSIF l_org_information_type='PER_VISA_INFO_CN' THEN
          hr_cn_api.set_location(g_debug,l_procedure,10);

	  OPEN csr_check_visa_info_used;
          FETCH csr_check_visa_info_used INTO l_person_extra_info_id;

	  IF csr_check_visa_info_used%FOUND THEN

	     OPEN csr_get_visa_number;
	     FETCH csr_get_visa_number INTO l_visa_number;
	     CLOSE csr_get_visa_number;

             CLOSE csr_check_visa_info_used;

	     hr_cn_api.set_location(g_debug,l_procedure,20);
             hr_utility.set_message(800, 'HR_374620_FT_VISA_EXISTS');
	     hr_utility.set_message_token('VISA_NUMBER',l_visa_number);
	     hr_utility.raise_error;
          END IF;
          CLOSE csr_check_visa_info_used;
    END IF;

EXCEPTION
     WHEN OTHERS THEN
        RAISE;

END check_extra_information_exists;

BEGIN

   g_package := 'per_cn_extra_per_info_leg_hook.';
   g_debug   := hr_utility.debug_enabled;

END per_cn_extra_per_info_leg_hook;

/
