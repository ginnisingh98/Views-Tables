--------------------------------------------------------
--  DDL for Package Body PER_RU_CON_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RU_CON_INFO" AS
/* $Header: perucrlp.pkb 120.1 2006/09/20 13:52:47 mgettins noship $ */
PROCEDURE CREATE_RU_CON_REL(P_CONTACT_PERSON_ID NUMBER,
                            P_PERSON_ID         NUMBER,
                            P_CONTACT_TYPE      VARCHAR2,
			    P_CONT_INFORMATION1 VARCHAR2) IS
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
    --
    IF P_CONTACT_TYPE <> 'C' AND P_CONT_INFORMATION1 IS NOT NULL THEN
      hr_utility.set_message(800,'HR_RU_INVALID_CONTACT_REL');
      hr_utility.set_message_token('CONTACT_TYPE',hr_general.decode_lookup('CONTACT',P_CONTACT_TYPE));
      hr_utility.raise_error;
    END IF;
	--
  END IF;
  --
END CREATE_RU_CON_REL;
---------------------------------------------------------------------------------------------------

PROCEDURE UPDATE_RU_CON_REL(P_CONTACT_RELATIONSHIP_ID  NUMBER,
                            P_CONTACT_TYPE             VARCHAR2,
			    p_cont_information1	       VARCHAR2) IS

  CURSOR cur_crl IS
  SELECT contact_type,cont_information1 FROM per_contact_relationships
  WHERE contact_person_id IN
  (SELECT contact_person_id FROM per_contact_relationships WHERE contact_relationship_id = p_contact_relationship_id)
   AND  person_id IN (SELECT person_id FROM per_contact_relationships WHERE contact_relationship_id = p_contact_relationship_id)
   AND  contact_relationship_id = p_contact_relationship_id;


l_contact_type	per_contact_relationships.contact_type%TYPE;
l_info		per_contact_relationships.cont_information1%TYPE;

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
    --
    IF P_CONTACT_TYPE = hr_api.g_varchar2 AND p_cont_information1 <> hr_api.g_varchar2 THEN
      OPEN cur_crl;
      FETCH cur_crl INTO l_contact_type,l_info;
	  CLOSE cur_crl;
	  IF l_contact_type <> 'C' AND p_cont_information1 IS NOT NULL THEN
		hr_utility.set_message(800,'HR_RU_INVALID_CONTACT_REL');
		hr_utility.set_message_token('CONTACT_TYPE',hr_general.decode_lookup('CONTACT',P_CONTACT_TYPE));
		hr_utility.raise_error;
  	  END IF;
    END IF;

    IF P_CONTACT_TYPE <> hr_api.g_varchar2 and p_cont_information1 = hr_api.g_varchar2 THEN
	  OPEN cur_crl;
	  FETCH cur_crl INTO l_contact_type,l_info;
	  CLOSE cur_crl;
	  IF P_CONTACT_TYPE <> 'C' AND l_info IS NOT NULL THEN
		hr_utility.set_message(800,'HR_RU_INVALID_CONTACT_REL');
		hr_utility.set_message_token('CONTACT_TYPE',hr_general.decode_lookup('CONTACT',P_CONTACT_TYPE));
		hr_utility.raise_error;
	  END IF;
    END IF;

    IF P_CONTACT_TYPE <> hr_api.g_varchar2 AND p_cont_information1 <> hr_api.g_varchar2 THEN
	  if P_CONTACT_TYPE <> 'C' AND p_cont_information1 IS NOT NULL THEN
		hr_utility.set_message(800,'HR_RU_INVALID_CONTACT_REL');
		hr_utility.set_message_token('CONTACT_TYPE',hr_general.decode_lookup('CONTACT',P_CONTACT_TYPE));
		hr_utility.raise_error;
	  END IF;
   END IF;
  END IF;
END UPDATE_RU_CON_REL;

END PER_RU_CON_INFO;

/
