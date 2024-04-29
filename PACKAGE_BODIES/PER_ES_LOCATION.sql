--------------------------------------------------------
--  DDL for Package Body PER_ES_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ES_LOCATION" AS
/* $Header: peesladp.pkb 120.1 2006/09/14 14:36:40 mgettins noship $ */
  g_package  VARCHAR2(33) := 'per_es_location.';
--
PROCEDURE check_es_location (p_style              IN VARCHAR2
                            ,p_postal_code        IN VARCHAR2
                            ,p_region_2           IN VARCHAR2) IS
    --
    l_province_code     varchar2(2);
    --
BEGIN
    --
    IF  p_style='ES' THEN
        IF  p_postal_code IS NOT NULL THEN
            l_province_code := substr(p_postal_code,1,2);
            IF  l_province_code <> p_region_2 THEN
                hr_utility.set_message(800,'HR_ES_INVALID_VALUE');
                hr_utility.set_message_token(800,'FIELD',hr_general.decode_lookup('ES_FORM_LABELS','POSTAL_CODE'));
                hr_utility.raise_error;
            END IF;
        END IF;
    END IF;
    --
END check_es_location;
--
PROCEDURE create_es_location (p_style        IN VARCHAR2
                             ,p_postal_code  IN VARCHAR2
                             ,p_region_2     IN VARCHAR2) IS
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
    --
    per_es_location.check_es_location(p_style         => p_style
                                     ,p_postal_code   => p_postal_code
                                     ,p_region_2      => p_region_2);
    --
  END IF;
  --
END create_es_location;
--
PROCEDURE update_es_location (p_style        IN VARCHAR2
                             ,p_postal_code  IN VARCHAR2
                             ,p_region_2     IN VARCHAR2) is
--
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
    --
    per_es_location.check_es_location(p_style         => p_style
                                     ,p_postal_code   => p_postal_code
                                     ,p_region_2      => p_region_2);
    --
  END IF;
  --
END update_es_location;
--
END per_es_location;

/
