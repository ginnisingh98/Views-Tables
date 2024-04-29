--------------------------------------------------------
--  DDL for Package Body PER_FR_CONTRACTS_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_CONTRACTS_VAL" AS
/* $Header: perfrctc.pkb 120.0.12000000.2 2007/02/28 11:06:27 spendhar noship $  */
--
  g_package  varchar2(80) := 'per_fr_contracts_val.';
--

  PROCEDURE PERSON_CONTRACT_CREATE
        (p_ctr_information_category IN VARCHAR2
        ,p_ctr_information10  IN VARCHAR2
        ,p_ctr_information11  IN VARCHAR2) IS
   l_proc               VARCHAR2(200) := g_package||'person_contract_create';
  --
  BEGIN

   /* Added for GSI Bug 5472781 */
   IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
      hr_utility.set_location('Leaving : '||l_proc , 10);
      return;
   END IF;

   --
   IF p_ctr_information_category = 'FR' THEN
      --
      IF p_ctr_information10 = 'Y' THEN
         IF p_ctr_information11 is null
           OR p_ctr_information11 = '0'
           OR p_ctr_information11 = '' THEN
           -- raise error, do not save
           -- Modified application id for 3944415
           hr_utility.set_message(800,'PER_75091_CTR_HRS');
           hr_utility.raise_error;
           --
         END IF;
      END IF;
      --
   END IF;
   --
  END PERSON_CONTRACT_CREATE;
  --
  PROCEDURE PERSON_CONTRACT_UPDATE
         (p_ctr_information_category IN VARCHAR2
         ,p_ctr_information10  IN VARCHAR2
         ,p_ctr_information11  IN VARCHAR2 ) IS
   l_proc               VARCHAR2(200) := g_package||'person_contract_update';
  --
  BEGIN

   /* Added for GSI Bug 5472781 */
   IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
      hr_utility.set_location('Leaving : '||l_proc , 10);
      return;
   END IF;

   --
   IF p_ctr_information_category = 'FR' THEN
      --
      IF p_ctr_information10 = 'Y' THEN
         IF p_ctr_information11 is null
           OR p_ctr_information11 = '0'
           OR p_ctr_information11 = '' THEN
           -- raise error, do not save
           -- Modified application id for 3944415
           hr_utility.set_message(800,'PER_75091_CTR_HRS');
           hr_utility.raise_error;
           --
          END IF;
      END IF;
      --
   END IF;
   --
  END PERSON_CONTRACT_UPDATE;
--
END PER_FR_CONTRACTS_VAL;

/
