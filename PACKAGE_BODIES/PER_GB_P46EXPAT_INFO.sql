--------------------------------------------------------
--  DDL for Package Body PER_GB_P46EXPAT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GB_P46EXPAT_INFO" AS
/* $Header: pergbeit.pkb 120.0.12010000.2 2009/03/31 15:29:32 krreddy noship $ */

g_package  varchar2(33) := '  PER_GB_P46EXPAT_INFO.';

PROCEDURE CREATE_GB_P46EXPAT_INFO(P_ASSIGNMENT_ID  NUMBER
					,P_INFORMATION_TYPE		VARCHAR2
					,P_AEI_ATTRIBUTE_CATEGORY	VARCHAR2
					,P_AEI_INFORMATION_CATEGORY   VARCHAR2
					,P_AEI_INFORMATION1      VARCHAR2
					,P_AEI_INFORMATION2      VARCHAR2
					,P_AEI_INFORMATION3      VARCHAR2
					,P_AEI_INFORMATION4      VARCHAR2
					,P_AEI_INFORMATION5      VARCHAR2
					,P_AEI_INFORMATION6      VARCHAR2
					,P_AEI_INFORMATION7      VARCHAR2
					)
IS

  -- Declare local variables
  l_proc                varchar2(72) := g_package||'CREATE_GB_P46EXPAT_INFO';
  --

BEGIN

 hr_utility.set_location('Entering:'|| l_proc, 10);

  hr_utility.set_location(l_proc, 6);

  if p_aei_information_category = 'GB_P46EXP' then
    if (p_aei_information1 = 'Y') then --if send_edi is checked
      if (p_aei_information2 <> 'A' and p_aei_information2 <> 'B' and p_aei_information2 <> 'C') then
            hr_utility.set_message(801, 'PAY_GB_78146_INV_EXPAT_STMT');
            hr_utility.set_message_token('TYPE','P46EXPAT');
            hr_utility.raise_error;
      end if;

      if (p_aei_information4 is not null and p_aei_information4 <> 'D') then
            hr_utility.set_message(801, 'PAY_GB_78147_INV_STU_LOAN');
            hr_utility.set_message_token('TYPE','P46EXPAT');
            hr_utility.raise_error;
      end if;

      if (p_aei_information5 is not null) then
            hr_utility.set_message(801, 'PAY_GB_78143_WARN_EEA_CITIZEN');
            hr_utility.set_message_token('TYPE','P46EXPAT');
      end if;

      if (p_aei_information7 is null) then
            hr_utility.set_message(801, 'PAY_GB_78148_INV_UK_EMPL_DATE');
            hr_utility.set_message_token('TYPE','P46EXPAT');
            hr_utility.raise_error;
      end if;

    end if;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 40);

END CREATE_GB_P46EXPAT_INFO;

PROCEDURE UPDATE_GB_P46EXPAT_INFO(P_ASSIGNMENT_EXTRA_INFO_ID  NUMBER
					,P_AEI_ATTRIBUTE_CATEGORY	VARCHAR2
					,P_AEI_INFORMATION_CATEGORY   VARCHAR2
					,P_AEI_INFORMATION1      VARCHAR2
					,P_AEI_INFORMATION2      VARCHAR2
					,P_AEI_INFORMATION3      VARCHAR2
					,P_AEI_INFORMATION4      VARCHAR2
					,P_AEI_INFORMATION5      VARCHAR2
					,P_AEI_INFORMATION6      VARCHAR2
					,P_AEI_INFORMATION7      VARCHAR2
					)
IS

l_proc                varchar2(72) := g_package||'UPDATE_GB_P46EXPAT_INFO';
BEGIN
 hr_utility.set_location('Entering:'|| l_proc, 10);
--Commented out for time being in order to address rollback issue
/*  if (p_aei_information1 = 'Y') then

  if (p_aei_information2 <> 'A' and p_aei_information2 <> 'B' and p_aei_information2 <> 'C') then
    hr_utility.set_message(801, 'PAY_GB_78146_INV_EXPAT_STMT');
    hr_utility.set_message_token('TYPE','P46EXPAT');
    hr_utility.raise_error;
  end if;

  if (p_aei_information4 is not null and p_aei_information4 <> 'D') then
    hr_utility.set_message(801, 'PAY_GB_78147_INV_STU_LOAN');
    hr_utility.set_message_token('TYPE','P46EXPAT');
    hr_utility.raise_error;
  end if;

  if (p_aei_information5 is not null) then
    hr_utility.set_message(801, 'PAY_GB_78143_WARN_EEA_CITIZEN');
    hr_utility.set_message_token('TYPE','P46EXPAT');
    hr_utility.raise_error;
  end if;

  if (p_aei_information7 is null) then
    hr_utility.set_message(801, 'PAY_GB_78148_INV_UK_EMPL_DATE');
    hr_utility.set_message_token('TYPE','P46EXPAT');
    hr_utility.raise_error;
  end if;

end if;
*/
  hr_utility.set_location(' Leaving:'||l_proc, 40);

END UPDATE_GB_P46EXPAT_INFO;
END PER_GB_P46EXPAT_INFO;

/
