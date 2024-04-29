--------------------------------------------------------
--  DDL for Package Body PER_HU_PERSON_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HU_PERSON_EXTRA_INFO" AS
/* $Header: pehupeip.pkb 120.1 2006/09/21 09:13:51 mgettins noship $ */


PROCEDURE chk_dl_date(p_pei_information3   VARCHAR2
                  ,p_pei_information4   VARCHAR2
                   ) IS
BEGIN
    IF p_pei_information3 IS NOT NULL AND p_pei_information4 IS NOT NULL THEN
        IF fnd_date.canonical_to_date(p_pei_information3) > fnd_date.canonical_to_date(p_pei_information4) THEN
            hr_utility.set_message(800,'HR_HU_START_END_DATES');
            hr_utility.set_message_token(800,'VALUE2',hr_general.decode_lookup('HU_FORM_LABELS','DL_EXPIRY_DATE'));
            hr_utility.set_message_token(800,'VALUE1',hr_general.decode_lookup('HU_FORM_LABELS','START_DATE'));
            hr_utility.raise_error;
        END IF;
    END IF;
END chk_dl_date;
--
PROCEDURE chk_passport_date(p_pei_information3   VARCHAR2
                  ,p_pei_information4   VARCHAR2
                   ) IS
BEGIN
    IF p_pei_information3 IS NOT NULL AND p_pei_information4 IS NOT NULL THEN
        IF fnd_date.canonical_to_date(p_pei_information3) > fnd_date.canonical_to_date(p_pei_information4) THEN
            hr_utility.set_message(800,'HR_HU_START_END_DATES');
            hr_utility.set_message_token(800,'VALUE2',hr_general.decode_lookup('HU_FORM_LABELS','PASSPORT_EXPIRY_DATE'));
            hr_utility.set_message_token(800,'VALUE1',hr_general.decode_lookup('HU_FORM_LABELS','ISSUE_DATE'));
            hr_utility.raise_error;
        END IF;
    END IF;
END chk_passport_date;
--
PROCEDURE chk_residency_date(p_pei_information3   VARCHAR2
                  ,p_pei_information4   VARCHAR2
                   ) IS
BEGIN
    IF p_pei_information3 IS NOT NULL AND p_pei_information4 IS NOT NULL THEN
        IF fnd_date.canonical_to_date(p_pei_information3) > fnd_date.canonical_to_date(p_pei_information4) THEN
            hr_utility.set_message(800,'HR_HU_START_END_DATES');
            hr_utility.set_message_token(800,'VALUE2',hr_general.decode_lookup('HU_FORM_LABELS','RESIDENCY_EXPIRY_DATE'));
            hr_utility.set_message_token(800,'VALUE1',hr_general.decode_lookup('HU_FORM_LABELS','ISSUE_DATE'));
            hr_utility.raise_error;
        END IF;
    END IF;
END chk_residency_date;
--
PROCEDURE chk_permit_date(p_pei_information3   VARCHAR2
                  ,p_pei_information4   VARCHAR2
                   ) IS
BEGIN
    IF p_pei_information3 IS NOT NULL AND p_pei_information4 IS NOT NULL THEN
        IF fnd_date.canonical_to_date(p_pei_information3) > fnd_date.canonical_to_date(p_pei_information4) THEN
            hr_utility.set_message(800,'HR_HU_START_END_DATES');
            hr_utility.set_message_token(800,'VALUE2',hr_general.decode_lookup('HU_FORM_LABELS','PERMIT_EXPIRY_DATE'));
            hr_utility.set_message_token(800,'VALUE1',hr_general.decode_lookup('HU_FORM_LABELS','ISSUE_DATE'));
            hr_utility.raise_error;
        END IF;
    END IF;
END chk_permit_date;

--

PROCEDURE CREATE_HU_PERSON_EXTRA_INFO
  (p_person_id                     IN     NUMBER
  ,p_information_type              IN     VARCHAR2
  ,p_pei_information_category      IN     VARCHAR2
  ,p_pei_information3              IN     VARCHAR2
  ,p_pei_information4              IN     VARCHAR2
  ) IS
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'HU') THEN
    --
    IF  p_information_type='HU_DRIVING_LICENSE' THEN
        per_hu_person_extra_info.chk_dl_date(p_pei_information3 => p_pei_information3
                                         ,p_pei_information4 => p_pei_information4);
    END IF;
    IF p_information_type='HU_PASSPORT' THEN
        per_hu_person_extra_info.chk_passport_date(p_pei_information3 => p_pei_information3
                                         ,p_pei_information4 => p_pei_information4);
    END IF;
    IF p_information_type='HU_PERMIT_INFO' THEN
        per_hu_person_extra_info.chk_permit_date(p_pei_information3 => p_pei_information3
                                         ,p_pei_information4 => p_pei_information4);
    END IF;
    IF p_information_type='HU_RESIDENCY' THEN
        per_hu_person_extra_info.chk_residency_date(p_pei_information3 => p_pei_information3
                                         ,p_pei_information4 => p_pei_information4);
    END IF;
  END IF;
END create_hu_person_extra_info;

  --
 PROCEDURE UPDATE_HU_PERSON_EXTRA_INFO
  (p_person_extra_info_id          IN     NUMBER
  ,p_pei_information_category      IN     VARCHAR2
  ,p_pei_information3              IN     VARCHAR2
  ,p_pei_information4              IN     VARCHAR2
  ) IS
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'HU') THEN
    --
    IF p_pei_information_category='HU_DRIVING_LICENSE' THEN
        per_hu_person_extra_info.chk_dl_date(p_pei_information3 => p_pei_information3
                                         ,p_pei_information4 => p_pei_information4);
    END IF;
    IF p_pei_information_category='HU_PASSPORT' THEN
        per_hu_person_extra_info.chk_passport_date(p_pei_information3 => p_pei_information3
                                         ,p_pei_information4 => p_pei_information4);
    END IF;
    IF p_pei_information_category='HU_PERMIT_INFO' THEN
        per_hu_person_extra_info.chk_permit_date(p_pei_information3 => p_pei_information3
                                         ,p_pei_information4 => p_pei_information4);
    END IF;
    IF p_pei_information_category='HU_RESIDENCY' THEN
        per_hu_person_extra_info.chk_residency_date(p_pei_information3 => p_pei_information3
                                         ,p_pei_information4 => p_pei_information4);
    END IF;
  END IF;
END update_hu_person_extra_info;
  --
END per_hu_person_extra_info;

/
