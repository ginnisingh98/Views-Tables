--------------------------------------------------------
--  DDL for Package Body HR_RU_ADDRESS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RU_ADDRESS_HOOK" AS
/* $Header: peruaddp.pkb 120.1 2006/09/20 14:19:56 mgettins noship $ */

   g_package   CONSTANT VARCHAR2 (30) := 'HR_RU_ADDRESS_HOOK .';

   PROCEDURE create_ru_address (
      p_style               IN   VARCHAR2,
      p_add_information13   IN   VARCHAR2,
      p_postal_code         IN   VARCHAR2
   )
   AS
      l_proc   CONSTANT VARCHAR2 (72) := g_package || 'CREATE_RU_ADDRESS';
   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
      --
      IF p_style = 'RU'
      THEN
         IF (p_add_information13 = 'RES')
         THEN
            IF (p_postal_code IS NULL)
            THEN
               hr_utility.set_message (800, 'HR_RU_ZIPCODE_REQUIRED');
               hr_utility.raise_error;
            END IF;
         END IF;
      END IF;
	 END IF;
   END create_ru_address;

   PROCEDURE update_ru_address (
      p_address_id          IN   NUMBER,
      p_add_information13   IN   VARCHAR2,
      p_postal_code         IN   VARCHAR2
   )
   AS
      l_proc       CONSTANT VARCHAR2 (72) := g_package || 'UPDATE_RU_ADDRESS';
      l_add_information13   per_addresses.add_information13%TYPE;
      l_postal_code         per_addresses.postal_code%TYPE;

      CURSOR csr_get_address_details (p_id NUMBER)
      IS
         SELECT style, add_information13, postal_code
           FROM per_addresses
          WHERE address_id = p_id;

      l_address_record      csr_get_address_details%ROWTYPE;
   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
      --
      OPEN csr_get_address_details (p_address_id);

      FETCH csr_get_address_details
       INTO l_address_record;

      CLOSE csr_get_address_details;

      IF (l_address_record.style = 'RU')
      THEN
         IF    (p_add_information13 <> hr_api.g_varchar2)
            OR (p_add_information13 IS NULL)
         THEN
            l_add_information13 := p_add_information13;
         ELSE
            l_add_information13 := l_address_record.add_information13;
         END IF;

         IF (p_postal_code <> hr_api.g_varchar2) OR (p_postal_code IS NULL)
         THEN
            l_postal_code := p_postal_code;
         ELSE
            l_postal_code := l_address_record.postal_code;
         END IF;

         IF (l_add_information13 = 'RES')
         THEN
            IF (l_postal_code IS NULL)
            THEN
               hr_utility.set_message (800, 'HR_RU_ZIPCODE_REQUIRED');
               hr_utility.raise_error;
            END IF;
         END IF;
      END IF;
	 END IF;
   END update_ru_address;

   PROCEDURE update_ru_address_with_style (
      p_style               IN   VARCHAR2,
      p_address_id          IN   NUMBER,
      p_add_information13   IN   VARCHAR2,
      p_postal_code         IN   VARCHAR2
   )
   AS
      l_proc       CONSTANT VARCHAR2 (72) := g_package || 'UPDATE_RU_ADDRESS_WITH_STYLE';
      l_add_information13   per_addresses.add_information13%TYPE;
      l_postal_code         per_addresses.postal_code%TYPE;

      CURSOR csr_get_address_details (p_id NUMBER)
      IS
         SELECT add_information13, postal_code
           FROM per_addresses
          WHERE address_id = p_id;

      l_address_record      csr_get_address_details%ROWTYPE;
   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
      --
      OPEN csr_get_address_details (p_address_id);

      FETCH csr_get_address_details
       INTO l_address_record;

      CLOSE csr_get_address_details;

      IF (p_style = 'RU')
      THEN
         IF    (p_add_information13 <> hr_api.g_varchar2)
            OR (p_add_information13 IS NULL)
         THEN
            l_add_information13 := p_add_information13;
         ELSE
            l_add_information13 := l_address_record.add_information13;
         END IF;

         IF (p_postal_code <> hr_api.g_varchar2) OR (p_postal_code IS NULL)
         THEN
            l_postal_code := p_postal_code;
         ELSE
            l_postal_code := l_address_record.postal_code;
         END IF;

         IF (l_add_information13 = 'RES')
         THEN
            IF (l_postal_code IS NULL)
            THEN
               hr_utility.set_message (800, 'HR_RU_ZIPCODE_REQUIRED');
               hr_utility.raise_error;
            END IF;
         END IF;
      END IF;
	 END IF;
   END update_ru_address_with_style ;
END hr_ru_address_hook;

/
