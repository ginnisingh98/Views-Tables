--------------------------------------------------------
--  DDL for Package Body PAY_IN_ELE_EXTRA_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_ELE_EXTRA_INFO_LEG_HOOK" AS
/* $Header: pyinlhei.pkb 120.2 2006/05/27 18:28:46 statkar noship $ */

  g_package          CONSTANT VARCHAR2(100) := 'pay_in_ele_extra_info_leg_hook.';
  g_debug            BOOLEAN ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_TDS_FIELDS                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks that if the TDS type is not Fixed Percentage --
--                  then TDS Percentage field must be null and if the   --
--                  TDS type is Fixed Percentage, then TDS Percentage   --
--                  field must be populated                             --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_eei_information1          VARCHAR2                --
--                  p_eei_information2          VARCHAR2                --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   10-Sep-04  abhjain	Created this procedure                  --
--------------------------------------------------------------------------

PROCEDURE check_tds_fields(p_eei_information_category IN VARCHAR2
                          ,p_eei_information1         IN VARCHAR2
                          ,p_eei_information2         IN VARCHAR2
                          ) IS
  l_message   VARCHAR2(255);
  l_procedure VARCHAR2(100);

BEGIN

  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'IN') THEN
    hr_utility.trace ('IN Legislation not installed. Not performing the validations');
    RETURN;
  END IF;

  g_debug := hr_utility.debug_enabled;
  l_procedure := g_package ||'check_tds_fields';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  IF g_debug THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.trace('EEI Information Category  ',p_eei_information_category);
       pay_in_utils.trace('EEI Information1          ',p_eei_information1);
       pay_in_utils.trace('EEI Information2          ',p_eei_information2);
       pay_in_utils.trace('**************************************************','********************');
   END IF;

  IF p_eei_information_category = 'PAY_IN_BONUS_INFO_DFF' THEN

    IF p_eei_information1 <> 'P' AND p_eei_information2 IS NOT NULL THEN
      hr_utility.set_message(800, 'PER_IN_CANT_ENTER_PERCENTAGE');
      hr_utility.raise_error;
    END IF;

    IF p_eei_information1 = 'P' AND p_eei_information2 IS NULL THEN
      hr_utility.set_message(800, 'PER_IN_ENTER_PERCENTAGE');
      hr_utility.raise_error;
    END IF;
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_message(800,'PER_IN_ORACLE_GENERIC_ERROR');
      hr_utility.set_message_token('FUNCTION',l_procedure);
      hr_utility.set_message_token('SQLERRMC',SQLERRM);
      hr_utility.raise_error;
END check_tds_fields ;


END  pay_in_ele_extra_info_leg_hook ;

/
