--------------------------------------------------------
--  DDL for Package Body PER_IN_EXTRA_PER_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IN_EXTRA_PER_INFO_LEG_HOOK" AS
/* $Header: peinlhei.pkb 120.2 2006/05/27 18:47:39 statkar noship $ */

g_package CONSTANT VARCHAR2(100) := 'per_in_extra_per_info_leg_hook.';
g_debug BOOLEAN;

--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : VALIDATE_ISSUE_EXPIRY_DATE                          --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks for the validity of the format of the PAN    --
--                                                                      --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_pei_information5          VARCHAR2                --
--                : p_pei_information6          VARCHAR2                --
--                : p_pei_information_category  VARCHAR2                --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   22-May-04  abhjain	Created this procedure                  --
--------------------------------------------------------------------------

PROCEDURE validate_issue_expiry_date(
	 p_pei_information_category IN VARCHAR2
        ,p_pei_information4         IN VARCHAR2
        ,p_pei_information5         IN VARCHAR2
        ) IS
    l_procedure           VARCHAR2(80);
    l_message             VARCHAR2(250);
    E_INVALID_DATES_ERR   EXCEPTION;
BEGIN

  l_procedure := g_package||'validate_issue_expiry_date';
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: ' || l_procedure, 10);

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
    hr_utility.trace ('IN Legislation not installed. Not performing the validations');
    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
    RETURN;
  END IF;

   IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('p_pei_information_category',p_pei_information_category);
       pay_in_utils.trace('p_pei_information4        ',p_pei_information4        );
       pay_in_utils.trace('p_pei_information5        ',p_pei_information5        );
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  IF p_pei_information_category = 'IN_PASSPORT_DETAILS' THEN
    l_procedure :='PER_IN_EXTRA_PER_INFO_LEG_HOOK.VALIDATE_ISSUE_EXPIRY_DATE';
    pay_in_utils.set_location(g_debug,l_procedure,10);
    IF p_pei_information4 IS NOT NULL AND p_pei_information5 IS NOT NULL THEN
      IF fnd_date.canonical_to_date(p_pei_information4) > fnd_date.canonical_to_date(p_pei_information5) THEN
        RAISE E_INVALID_DATES_ERR;
      END IF;
    END IF;
    pay_in_utils.set_location(g_debug,l_procedure,20);
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);

  EXCEPTION
    WHEN E_INVALID_DATES_ERR THEN
     hr_utility.set_message(800,'PER_IN_INCORRECT_PASSPORT_DATE');
     pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 40);
     hr_utility.raise_error;

END validate_issue_expiry_date;


END  per_in_extra_per_info_leg_hook;

/
