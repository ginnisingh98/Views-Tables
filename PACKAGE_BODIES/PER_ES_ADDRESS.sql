--------------------------------------------------------
--  DDL for Package Body PER_ES_ADDRESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ES_ADDRESS" AS
/* $Header: peespadp.pkb 120.1 2006/09/14 16:20:12 mgettins noship $ */
--
PROCEDURE check_es_address (p_postal_code IN VARCHAR2
                           ,p_region_2    IN VARCHAR2) IS
    --
    l_province_code     varchar2(2);
    --
BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
     --
    --
    l_province_code := substr(p_postal_code,1,2);

    IF  l_province_code <> p_region_2 THEN
         hr_utility.set_message(800,'HR_ES_INVALID_VALUE');
         hr_utility.set_message_token(800,'FIELD',hr_general.decode_lookup('ES_FORM_LABELS','POSTAL_CODE'));
         hr_utility.raise_error;
    END IF;
  END IF;
  --
END check_es_address;
--
PROCEDURE create_es_address (p_style        IN VARCHAR2
                            ,p_postal_code  IN VARCHAR2
                            ,p_region_2     IN VARCHAR2) IS
BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
     --
     --
     IF  p_style = 'ES' THEN
        IF  p_postal_code IS NOT NULL THEN
            per_es_address.check_es_address(p_postal_code => p_postal_code
                                           ,p_region_2    => p_region_2);
        END IF;
     END IF;
   END IF;
    --
END create_es_address;
--
PROCEDURE update_es_address (p_address_id   IN NUMBER
                            ,p_postal_code  IN VARCHAR2
                            ,p_region_2     IN VARCHAR2) IS
    --
    CURSOR csr_get_address_info(c_address_id number) is
    SELECT style,  postal_code, region_2
    FROM   per_addresses
    WHERE  address_id=c_address_id;
    --
    l_rec         csr_get_address_info%ROWTYPE;
    l_postal_code per_addresses.postal_code%TYPE;
    l_region_2    per_addresses.region_2%TYPE;


BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
     --
    --
    IF p_postal_code <> hr_api.g_varchar2
       OR p_region_2 <> hr_api.g_varchar2 THEN
        --
        OPEN csr_get_address_info(p_address_id);
        FETCH csr_get_address_info INTO l_rec;
        CLOSE csr_get_address_info;
        --
        IF  l_rec.style = 'ES' THEN
            --
            l_postal_code := p_postal_code;
            l_region_2 := p_region_2;
            --
            IF p_postal_code = hr_api.g_varchar2 THEN
                l_postal_code := l_rec.postal_code;
            ELSIF p_region_2 = hr_api.g_varchar2 THEN
                l_region_2 := l_rec.region_2;
            END IF;
            --
            per_es_address.check_es_address(p_postal_code => l_postal_code
                                           ,p_region_2    => l_region_2);
        END IF;

    END IF;
    --
  END IF;
END update_es_address;
--
PROCEDURE update_es_address_style(p_address_id   IN NUMBER
                                 ,p_postal_code  IN VARCHAR2
                                 ,p_region_2     IN VARCHAR2
                                 ,p_style        IN VARCHAR2) IS
    --
    CURSOR csr_get_address_info(c_address_id number) is
    SELECT postal_code, region_2
    FROM   per_addresses
    WHERE  address_id=c_address_id;
    --
    l_rec         csr_get_address_info%ROWTYPE;
    l_postal_code per_addresses.postal_code%TYPE;
    l_region_2    per_addresses.region_2%TYPE;
    --
BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
     --
    --
    IF  p_postal_code IS NOT NULL THEN
        IF  p_style = 'ES' THEN
        --
            IF  p_postal_code <> hr_api.g_varchar2
            OR p_region_2 <> hr_api.g_varchar2 THEN
                OPEN csr_get_address_info(p_address_id);
                FETCH csr_get_address_info INTO l_rec;
                CLOSE csr_get_address_info;
                --
                l_postal_code := p_postal_code;
                l_region_2 := p_region_2;
                --
                IF p_postal_code = hr_api.g_varchar2 THEN
                    l_postal_code := l_rec.postal_code;
                ELSIF p_region_2 = hr_api.g_varchar2 THEN
                    l_region_2 := l_rec.region_2;
                END IF;
                --
                per_es_address.check_es_address(p_postal_code => l_postal_code
                                               ,p_region_2    => l_region_2);
            END IF;
        END IF;

    END IF;
    --
   END IF;
END update_es_address_style;
--
END per_es_address;

/
