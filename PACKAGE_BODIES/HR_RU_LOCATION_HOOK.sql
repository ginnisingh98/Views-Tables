--------------------------------------------------------
--  DDL for Package Body HR_RU_LOCATION_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RU_LOCATION_HOOK" AS
/* $Header: perulocp.pkb 120.1 2006/09/20 14:09:34 mgettins noship $ */

   g_package   CONSTANT VARCHAR2 (30) := 'HR_RU_LOCATION_HOOK .';

   PROCEDURE create_ru_location (
      p_style               IN   VARCHAR2,
      p_loc_information13   IN   VARCHAR2,
      p_postal_code         IN   VARCHAR2
   )
   AS
      l_proc   CONSTANT VARCHAR2 (72) := g_package || 'CREATE_RU_LOCATION';
   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
      --
      IF p_style = 'RU'
      THEN
         IF (p_loc_information13 = 'RES')
         THEN
            IF (p_postal_code IS NULL)
            THEN
               hr_utility.set_message (800, 'HR_RU_ZIPCODE_REQUIRED');
               hr_utility.raise_error;
            END IF;
         END IF;
      END IF;
	 END IF;
   END create_ru_location;

   PROCEDURE update_ru_location (
      p_location_id         IN   NUMBER,
      p_style               IN   VARCHAR2,
      p_loc_information13   IN   VARCHAR2,
      p_postal_code         IN   VARCHAR2
   )
   AS
      l_proc       CONSTANT VARCHAR2 (72)
                                         := g_package || 'UPDATE_RU_LOCATION';
      l_loc_information13   hr_locations_all.loc_information13%TYPE;
      l_postal_code         hr_locations_all.postal_code%TYPE;
      l_style               hr_locations_all.style%TYPE;

      CURSOR csr_get_location_details (p_id NUMBER)
      IS
         SELECT style, loc_information13, postal_code
           FROM hr_locations_all
          WHERE location_id = p_id;

      l_location_record     csr_get_location_details%ROWTYPE;
   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
      --
      OPEN csr_get_location_details (p_location_id);

      FETCH csr_get_location_details
       INTO l_location_record;

      CLOSE csr_get_location_details;

      IF (p_style <> hr_api.g_varchar2) OR (p_style IS NULL)
      THEN
         l_style := p_style;
      ELSE
         l_style := l_location_record.style;
      END IF;

      IF (l_style = 'RU')
      THEN
         IF    (p_loc_information13 <> hr_api.g_varchar2)
            OR (p_loc_information13 IS NULL)
         THEN
            l_loc_information13 := p_loc_information13;
         ELSE
            l_loc_information13 := l_location_record.loc_information13;
         END IF;

         IF (p_postal_code <> hr_api.g_varchar2) OR (p_postal_code IS NULL)
         THEN
            l_postal_code := p_postal_code;
         ELSE
            l_postal_code := l_location_record.postal_code;
         END IF;

         IF (l_loc_information13 = 'RES')
         THEN
            IF (l_postal_code IS NULL)
            THEN
               hr_utility.set_message (800, 'HR_RU_ZIPCODE_REQUIRED');
               hr_utility.raise_error;
            END IF;
         END IF;
      END IF;
	 END IF;
   END update_ru_location;
END hr_ru_location_hook;

/
