--------------------------------------------------------
--  DDL for Package Body HR_RU_PEOPLE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RU_PEOPLE_LEG_HOOK" AS
/* $Header: peruvald.pkb 120.2.12010000.2 2009/07/07 08:43:40 parusia ship $ */
   g_package   CONSTANT VARCHAR2 (30) := 'HR_RU_PEOPLE_LEG_HOOK .';

   FUNCTION param_or_db (param VARCHAR2, db_item VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      IF (param <> hr_api.g_varchar2) OR (param IS NULL)
      THEN
         RETURN param;
      ELSE
         RETURN db_item;
      END IF;
   END param_or_db;

   PROCEDURE validate_person_upd (
      p_first_name          VARCHAR2,
      p_person_id           NUMBER,
      p_effective_date      DATE,
      p_per_information4    VARCHAR2,
      p_per_information5    VARCHAR2,
      p_per_information6    VARCHAR2,
      p_per_information7    VARCHAR2,
      p_per_information8    VARCHAR2,
      p_per_information9    VARCHAR2,
      p_per_information10   VARCHAR2,
      p_per_information11   VARCHAR2,
      p_per_information12   VARCHAR2,
      p_per_information13   VARCHAR2,
      p_per_information14   VARCHAR2,
      p_per_information15   VARCHAR2,
      p_per_information18   VARCHAR2
   )
   IS
      l_proc       CONSTANT VARCHAR2 (72)
                                        := g_package || 'VALIDATE_PERSON_UPD';
      l_effective_date      DATE;
      l_err                 NUMBER;
      l_age                 NUMBER;
      l_per_information5    per_all_people_f.per_information5%TYPE;
      l_per_information6    per_all_people_f.per_information6%TYPE;
      l_per_information7    per_all_people_f.per_information7%TYPE;
      l_per_information8    per_all_people_f.per_information8%TYPE;
      l_per_information9    per_all_people_f.per_information9%TYPE;
      l_per_information10   per_all_people_f.per_information10%TYPE;
      l_per_information11   per_all_people_f.per_information11%TYPE;
      l_per_information12   per_all_people_f.per_information12%TYPE;
      l_per_information14   per_all_people_f.per_information14%TYPE;
      l_per_information15   per_all_people_f.per_information15%TYPE;
      l_per_information18   per_all_people_f.per_information18%TYPE;

      CURSOR csr_get_mil_info (p_id NUMBER)
      IS
         SELECT per_information5, per_information6, per_information7,
                per_information8, per_information9, per_information10,
                per_information11, per_information12, per_information13,
                per_information14,per_information15,per_information18
           FROM per_all_people_f papf
          WHERE papf.person_id = p_id
            AND p_effective_date BETWEEN papf.effective_start_date
                                     AND papf.effective_end_date;

      db_person_rec         csr_get_mil_info%ROWTYPE;
   BEGIN


      l_effective_date := TRUNC (p_effective_date);

      --Validate Pension fund number
      IF     p_per_information13 <> hr_api.g_varchar2
         AND p_per_information13 IS NOT NULL
      THEN
         l_err :=
            hr_ru_utility.validate_spifn (p_per_information13,
                                          l_effective_date
                                         );

         IF (l_err = 1)
         THEN
            hr_utility.set_message (800, 'HR_RU_INVALID_SPIF_NUMBER');
            hr_utility.set_message_token
                                 ('NUMBER',
                                  hr_general.decode_lookup ('RU_FORM_LABELS',
                                                            'SPIFN'
                                                           )
                                 );
            hr_utility.raise_error;
         ELSIF l_err = 2
         THEN
            hr_utility.set_message (800, 'HR_RU_SPIFN_FORMULA_ERROR');
            hr_utility.raise_error;
         END IF;
      END IF;

      --Check for Invalid Combination of military document and other military details
      IF    (p_per_information5 <> hr_api.g_varchar2)
         OR (p_per_information5 IS NULL)
         OR (p_per_information6 <> hr_api.g_varchar2)
         OR (p_per_information6 IS NULL)
         OR (p_per_information7 <> hr_api.g_varchar2)
         OR (p_per_information7 IS NULL)
         OR (p_per_information8 <> hr_api.g_varchar2)
         OR (p_per_information8 IS NULL)
         OR (p_per_information9 <> hr_api.g_varchar2)
         OR (p_per_information9 IS NULL)
         OR (p_per_information10 <> hr_api.g_varchar2)
         OR (p_per_information10 IS NULL)
         OR (p_per_information11 <> hr_api.g_varchar2)
         OR (p_per_information11 IS NULL)
         OR (p_per_information12 <> hr_api.g_varchar2)
         OR (p_per_information12 IS NULL)
         OR (p_per_information14 <> hr_api.g_varchar2)
         OR (p_per_information14 IS NULL)
         OR (p_per_information15 <> hr_api.g_varchar2)
         OR (p_per_information15 IS NULL)
         OR (p_per_information18 <> hr_api.g_varchar2)
         OR (p_per_information18 IS NULL)
      THEN
         OPEN csr_get_mil_info (p_person_id);

         FETCH csr_get_mil_info
          INTO db_person_rec;

         CLOSE csr_get_mil_info;

         l_per_information5 :=
             param_or_db (p_per_information5, db_person_rec.per_information5);
         l_per_information6 :=
             param_or_db (p_per_information6, db_person_rec.per_information6);
         l_per_information7 :=
             param_or_db (p_per_information7, db_person_rec.per_information7);
         l_per_information8 :=
             param_or_db (p_per_information8, db_person_rec.per_information8);
         l_per_information9 :=
             param_or_db (p_per_information9, db_person_rec.per_information9);
         l_per_information10 :=
            param_or_db (p_per_information10,
                         db_person_rec.per_information10);
         l_per_information11 :=
            param_or_db (p_per_information11,
                         db_person_rec.per_information11);
         l_per_information12 :=
            param_or_db (p_per_information12,
                         db_person_rec.per_information12);
         l_per_information14 :=
            param_or_db (p_per_information14,
                         db_person_rec.per_information14);
         l_per_information15 :=
            param_or_db (p_per_information15,
                         db_person_rec.per_information15);
         l_per_information18 :=
            param_or_db (p_per_information18,
                         db_person_rec.per_information18);

         IF l_per_information5 IS NOT NULL
         THEN
            hr_ru_utility.check_lookup_value
                (p_argument            => hr_general.decode_lookup
                                                          ('RU_FORM_LABELS',
                                                           'MILITARY_DOCUMENT'
                                                          ),
                 p_argument_value      => l_per_information5,
                 p_lookup_type         => 'RU_MILITARY_DOC_TYPE',
                 p_effective_date      => p_effective_date
                );
            hr_api.mandatory_arg_error
               (p_api_name            => l_proc,
                p_argument            => hr_general.decode_lookup
                                                      ('RU_FORM_LABELS',
                                                       'MIL_SERVICE_READINESS'
                                                      ),
                p_argument_value      => l_per_information10
               );

            IF l_per_information12 IS NOT NULL
            THEN
               hr_ru_utility.check_lookup_value
                  (p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'QUITTING_MARK'
                                                            ),
                   p_argument_value      => l_per_information12,
                   p_lookup_type         => 'RU_QUITTING_MARK',
                   p_effective_date      => p_effective_date
                  );
            END IF;

            IF     l_per_information5 = '2'
               AND (   l_per_information6 IS NOT NULL
                    OR (l_per_information7 IS NOT NULL  AND l_per_information7<>'2')
                    OR l_per_information8 IS NOT NULL
                    OR l_per_information9 IS NOT NULL
                    OR l_per_information14 IS NOT NULL
                    OR l_per_information15 IS NOT NULL
                    OR l_per_information18 IS NOT NULL
                   )
            THEN
               hr_utility.set_message (800, 'HR_RU_MIL_INVALID_COMBINATION');
               hr_utility.raise_error;
            ELSIF l_per_information5 = '1'
            THEN
               IF (l_per_information6 IS NOT NULL)
               THEN
                  hr_ru_utility.check_lookup_value
                     (p_argument            => hr_general.decode_lookup
                                                           ('RU_FORM_LABELS',
                                                            'RESERVE_CATEGORY'
                                                           ),
                      p_argument_value      => l_per_information6,
                      p_lookup_type         => 'RU_RESERVE_CATEGORY',
                      p_effective_date      => p_effective_date
                     );
               END IF;

               IF (l_per_information7 IS NOT NULL)
               THEN
                  hr_ru_utility.check_lookup_value
                     (p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'MILITARY_RANK'
                                                            ),
                      p_argument_value      => l_per_information7,
                      p_lookup_type         => 'RU_MILITARY_RANK',
                      p_effective_date      => p_effective_date
                     );
               END IF;

               IF (l_per_information8 IS NOT NULL)
               THEN
                  hr_ru_utility.check_lookup_value
                     (p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'PROFILE'
                                                            ),
                      p_argument_value      => l_per_information8,
                      p_lookup_type         => 'RU_MILITARY_PROFILE',
                      p_effective_date      => p_effective_date
                     );
               END IF;

               IF (l_per_information18 IS NOT NULL)
               THEN
                  hr_ru_utility.check_lookup_value
                     (p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'MILITARY_REG_TYPE'
                                                            ),
                      p_argument_value      => l_per_information18,
                      p_lookup_type         => 'RU_MILITARY_REGISTRATION',
                      p_effective_date      => p_effective_date
                     );
               END IF;

               IF l_per_information10 = 'E'
               THEN
                  hr_utility.set_message (800, 'HR_7209_API_LOOK_INVALID');
                  hr_utility.set_message_token ('API_NAME', l_proc);
                  hr_utility.set_message_token
                           ('ARGUMENT',
                            hr_general.decode_lookup ('RU_FORM_LABELS',
                                                      'MIL_SERVICE_READINESS'
                                                     )
                           );
                  hr_utility.raise_error;
               END IF;
            END IF;
         ELSIF     l_per_information5 IS NULL
               AND (   l_per_information6 IS NOT NULL
                    OR l_per_information7 IS NOT NULL
                    OR l_per_information8 IS NOT NULL
                    OR l_per_information9 IS NOT NULL
                    OR l_per_information10 IS NOT NULL
                    OR l_per_information11 IS NOT NULL
                    OR l_per_information12 IS NOT NULL
                    OR l_per_information14 IS NOT NULL
		    OR l_per_information15 IS NOT NULL
		    OR l_per_information18 IS NOT NULL
                   )
         THEN
            hr_utility.set_message (800, 'HR_RU_MIL_INVALID_COMBINATION');
            hr_utility.raise_error;
         END IF;
      END IF;
   END validate_person_upd;

   PROCEDURE validate_person (
      p_first_name          VARCHAR2,
      p_effective_date      DATE,
      p_per_information1    VARCHAR2,
      p_per_information4    VARCHAR2,
      p_per_information5    VARCHAR2,
      p_per_information6    VARCHAR2,
      p_per_information7    VARCHAR2,
      p_per_information8    VARCHAR2,
      p_per_information9    VARCHAR2,
      p_per_information10   VARCHAR2,
      p_per_information11   VARCHAR2,
      p_per_information12   VARCHAR2,
      p_per_information13   VARCHAR2,
      p_per_information14   VARCHAR2,
      p_per_information15   VARCHAR2,
      p_per_information18   VARCHAR2
   )
   IS
      l_proc    CONSTANT VARCHAR2 (72) := g_package || 'VALIDATE_PERSON';
      l_effective_date   DATE;
      l_err              NUMBER;
      l_age              NUMBER;
   BEGIN

      l_effective_date := TRUNC (p_effective_date);
      --
      -- Check Place of Birth takes valid OKATO lookup value
      IF (p_per_information1 IS NOT NULL)
      THEN
	    hr_ru_utility.check_lookup_value
		  (p_argument            => hr_general.decode_lookup
							    ('RU_FORM_LABELS',
							     'PLACE_OF_BIRTH'
							    ),
		   p_argument_value      => p_per_information1,
		   p_lookup_type         => 'RU_OKATO',
		   p_effective_date      => p_effective_date
		  );
      END IF;


      --Validate Pension fund number
      IF p_per_information13 IS NOT NULL
      THEN
         l_err :=
            hr_ru_utility.validate_spifn (p_per_information13,
                                          l_effective_date
                                         );

         IF (l_err = 1)
         THEN
            hr_utility.set_message (800, 'HR_RU_INVALID_SPIF_NUMBER');
            hr_utility.set_message_token
                                 ('NUMBER',
                                  hr_general.decode_lookup ('RU_FORM_LABELS',
                                                            'SPIFN'
                                                           )
                                 );
            hr_utility.raise_error;
         ELSIF l_err = 2
         THEN
            hr_utility.set_message (800, 'HR_RU_SPIFN_FORMULA_ERROR');
            hr_utility.raise_error;
         END IF;
      END IF;

      --Check for Invalid Combination of military document and other military details
      IF p_per_information5 IS NOT NULL
      THEN
         hr_ru_utility.check_lookup_value
                (p_argument            => hr_general.decode_lookup
                                                          ('RU_FORM_LABELS',
                                                           'MILITARY_DOCUMENT'
                                                          ),
                 p_argument_value      => p_per_information5,
                 p_lookup_type         => 'RU_MILITARY_DOC_TYPE',
                 p_effective_date      => p_effective_date
                );
         hr_api.mandatory_arg_error
             (p_api_name            => l_proc,
              p_argument            => hr_general.decode_lookup
                                                      ('RU_FORM_LABELS',
                                                       'MIL_SERVICE_READINESS'
                                                      ),
              p_argument_value      => p_per_information10
             );
         hr_ru_utility.check_lookup_value
             (p_argument            => hr_general.decode_lookup
                                                      ('RU_FORM_LABELS',
                                                       'MIL_SERVICE_READINESS'
                                                      ),
              p_argument_value      => p_per_information10,
              p_lookup_type         => 'RU_MILITARY_SERVICE_READINESS',
              p_effective_date      => p_effective_date
             );

         IF p_per_information12 IS NOT NULL
         THEN
            hr_ru_utility.check_lookup_value
                  (p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'QUITTING_MARK'
                                                            ),
                   p_argument_value      => p_per_information12,
                   p_lookup_type         => 'RU_QUITTING_MARK',
                   p_effective_date      => p_effective_date
                  );
         END IF;

         IF     p_per_information5 = '2'
            AND (   p_per_information6 IS NOT NULL
                 OR (p_per_information7 IS NOT NULL AND p_per_information7 <>'2')
                 OR p_per_information8 IS NOT NULL
                 OR p_per_information9 IS NOT NULL
                 OR p_per_information14 IS NOT NULL
                 OR p_per_information15 IS NOT NULL
                 OR p_per_information18 IS NOT NULL
                )
         THEN
            hr_utility.set_message (800, 'HR_RU_MIL_INVALID_COMBINATION');
            hr_utility.raise_error;
         ELSIF p_per_information5 = '1'
         THEN
            IF (p_per_information6 IS NOT NULL)
            THEN
               hr_ru_utility.check_lookup_value
                  (p_argument            => hr_general.decode_lookup
                                                           ('RU_FORM_LABELS',
                                                            'RESERVE_CATEGORY'
                                                           ),
                   p_argument_value      => p_per_information6,
                   p_lookup_type         => 'RU_RESERVE_CATEGORY',
                   p_effective_date      => p_effective_date
                  );
            END IF;

            IF (p_per_information7 IS NOT NULL)
            THEN
               hr_ru_utility.check_lookup_value
                  (p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'MILITARY_RANK'
                                                            ),
                   p_argument_value      => p_per_information7,
                   p_lookup_type         => 'RU_MILITARY_RANK',
                   p_effective_date      => p_effective_date
                  );
            END IF;

            IF (p_per_information8 IS NOT NULL)
            THEN
               hr_ru_utility.check_lookup_value
                  (p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'PROFILE'
                                                            ),
                   p_argument_value      => p_per_information8,
                   p_lookup_type         => 'RU_MILITARY_PROFILE',
                   p_effective_date      => p_effective_date
                  );
            END IF;

            IF (p_per_information18 IS NOT NULL)
            THEN
               hr_ru_utility.check_lookup_value
                  (p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'MILITARY_REG_TYPE'
                                                            ),
                   p_argument_value      => p_per_information18,
                   p_lookup_type         => 'RU_MILITARY_REGISTRATION',
                   p_effective_date      => p_effective_date
                  );
            END IF;

            IF p_per_information10 = 'E'
            THEN
               hr_utility.set_message (800, 'HR_7209_API_LOOK_INVALID');
               hr_utility.set_message_token ('API_NAME', l_proc);
               hr_utility.set_message_token
                           ('ARGUMENT',
                            hr_general.decode_lookup ('RU_FORM_LABELS',
                                                      'MIL_SERVICE_READINESS'
                                                     )
                           );
               hr_utility.raise_error;
            END IF;
         END IF;
      ELSIF     p_per_information5 IS NULL
            AND (   p_per_information6 IS NOT NULL
                 OR p_per_information7 IS NOT NULL
                 OR p_per_information8 IS NOT NULL
                 OR p_per_information9 IS NOT NULL
                 OR p_per_information10 IS NOT NULL
                 OR p_per_information11 IS NOT NULL
                 OR p_per_information12 IS NOT NULL
                 OR p_per_information14 IS NOT NULL
                 OR p_per_information15 IS NOT NULL
                 OR p_per_information18 IS NOT NULL
                )
      THEN
         hr_utility.set_message (800, 'HR_RU_MIL_INVALID_COMBINATION');
         hr_utility.raise_error;
      END IF;
   END validate_person;

   PROCEDURE create_ru_employee (
      p_first_name          VARCHAR2,
      p_hire_date           DATE,
      p_date_of_birth       DATE,
      p_sex                 VARCHAR2,
      p_per_information1    VARCHAR2,
      p_per_information4    VARCHAR2,
      p_per_information5    VARCHAR2,
      p_per_information6    VARCHAR2,
      p_per_information7    VARCHAR2,
      p_per_information8    VARCHAR2,
      p_per_information9    VARCHAR2,
      p_per_information10   VARCHAR2,
      p_per_information11   VARCHAR2,
      p_per_information12   VARCHAR2,
      p_per_information13   VARCHAR2,
      p_per_information14   VARCHAR2,
      p_per_information15   VARCHAR2,
      p_per_information18   VARCHAR2
   )
   IS
      l_proc    CONSTANT VARCHAR2 (72) := g_package || 'CREATE_RU_EMPLOYEE';
      -- l_age              NUMBER;
      -- l_effective_date   DATE;
   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
      --
      -- Check for Citizenship
      hr_api.mandatory_arg_error
                  (p_api_name            => l_proc,
                   p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'CITIZENSHIP'
                                                            ),
                   p_argument_value      => p_per_information4
                  );
      hr_ru_utility.check_lookup_value
	   (p_argument            => hr_general.decode_lookup
						    ('RU_FORM_LABELS',
						     'CITIZENSHIP'
						    ),
	    p_argument_value      => p_per_information4,
	    p_lookup_type         => 'RU_CITIZENSHIP',
	    p_effective_date      => p_hire_date
	   );
	      -- Check for first name
      hr_api.mandatory_arg_error
                  (p_api_name            => l_proc,
                   p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'FIRST_NAME'
                                                            ),
                   p_argument_value      => p_first_name
                  );

      validate_person (p_first_name             => p_first_name,
                       p_effective_date         => p_hire_date,
		           p_per_information1       => p_per_information1,
                       p_per_information4       => p_per_information4,
                       p_per_information5       => p_per_information5,
                       p_per_information6       => p_per_information6,
                       p_per_information7       => p_per_information7,
                       p_per_information8       => p_per_information8,
                       p_per_information9       => p_per_information9,
                       p_per_information10      => p_per_information10,
                       p_per_information11      => p_per_information11,
                       p_per_information12      => p_per_information12,
                       p_per_information13      => p_per_information13,
                       p_per_information14      => p_per_information14,
                       p_per_information15      => p_per_information15,
                       p_per_information18      => p_per_information18
                      );

      /* Suppressing the error of military documents being mandatory
         as per bug 8663065 */

      -- Check if Military Document is provided for males between 17 and 65
      -- l_effective_date := TRUNC (p_hire_date);

      --IF (p_date_of_birth IS NOT NULL)
      --THEN
      --   l_age :=
      --         TRUNC (MONTHS_BETWEEN (l_effective_date, p_date_of_birth) / 12);

      --   IF     p_sex = 'M'
      --      AND (l_age BETWEEN 17 AND 65)
      --      AND p_per_information5 IS NULL
      --   THEN
      --       hr_utility.set_message (800, 'HR_RU_MIL_DOC_REQUIRED');
      --     hr_utility.raise_error;
      --   END IF;
      --END IF;
	 END IF;
   END create_ru_employee;

   PROCEDURE create_ru_applicant (
      p_first_name          VARCHAR2,
      p_date_received       DATE,
      p_per_information1    VARCHAR2,
      p_per_information4    VARCHAR2,
      p_per_information5    VARCHAR2,
      p_per_information6    VARCHAR2,
      p_per_information7    VARCHAR2,
      p_per_information8    VARCHAR2,
      p_per_information9    VARCHAR2,
      p_per_information10   VARCHAR2,
      p_per_information11   VARCHAR2,
      p_per_information12   VARCHAR2,
      p_per_information13   VARCHAR2,
      p_per_information14   VARCHAR2,
      p_per_information15   VARCHAR2,
      p_per_information18   VARCHAR2
   )
   IS
      l_proc   CONSTANT VARCHAR2 (72) := g_package || 'CREATE_RU_APPLICANT';
   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
      --
      -- Check for Citizenship
      hr_api.mandatory_arg_error
                  (p_api_name            => l_proc,
                   p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'CITIZENSHIP'
                                                            ),
                   p_argument_value      => p_per_information4
                  );
      hr_ru_utility.check_lookup_value
                   (p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'CITIZENSHIP'
                                                            ),
                    p_argument_value      => p_per_information4,
                    p_lookup_type         => 'RU_CITIZENSHIP',
                    p_effective_date      => p_date_received
                   );
      validate_person (p_first_name             => p_first_name,
                       p_effective_date         => p_date_received,
       		       p_per_information1       => p_per_information1,
                       p_per_information4       => p_per_information4,
                       p_per_information5       => p_per_information5,
                       p_per_information6       => p_per_information6,
                       p_per_information7       => p_per_information7,
                       p_per_information8       => p_per_information8,
                       p_per_information9       => p_per_information9,
                       p_per_information10      => p_per_information10,
                       p_per_information11      => p_per_information11,
                       p_per_information12      => p_per_information12,
                       p_per_information13      => p_per_information13,
                       p_per_information14      => p_per_information14,
                       p_per_information15      => p_per_information15,
                       p_per_information18      => p_per_information18
                      );
     END IF;
   END create_ru_applicant;

   PROCEDURE create_ru_contact (
      p_first_name          VARCHAR2,
      p_start_date          DATE,
      p_per_information1    VARCHAR2,
      p_per_information4    VARCHAR2,
      p_per_information5    VARCHAR2,
      p_per_information6    VARCHAR2,
      p_per_information7    VARCHAR2,
      p_per_information8    VARCHAR2,
      p_per_information9    VARCHAR2,
      p_per_information10   VARCHAR2,
      p_per_information11   VARCHAR2,
      p_per_information12   VARCHAR2,
      p_per_information13   VARCHAR2,
      p_per_information14   VARCHAR2,
      p_per_information15   VARCHAR2,
      p_per_information18   VARCHAR2

   )
   IS
   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
      --
      validate_person (p_first_name             => p_first_name,
                       p_effective_date         => p_start_date,
		       p_per_information1       => p_per_information1,
                       p_per_information4       => p_per_information4,
                       p_per_information5       => p_per_information5,
                       p_per_information6       => p_per_information6,
                       p_per_information7       => p_per_information7,
                       p_per_information8       => p_per_information8,
                       p_per_information9       => p_per_information9,
                       p_per_information10      => p_per_information10,
                       p_per_information11      => p_per_information11,
                       p_per_information12      => p_per_information12,
                       p_per_information13      => p_per_information13,
                       p_per_information14      => p_per_information14,
                       p_per_information15      => p_per_information15,
                       p_per_information18      => p_per_information18
                      );
     END IF;
   END create_ru_contact;

   PROCEDURE create_ru_cwk (
      p_first_name          VARCHAR2,
      p_start_date          DATE,
      p_per_information1    VARCHAR2,
      p_per_information4    VARCHAR2,
      p_per_information5    VARCHAR2,
      p_per_information6    VARCHAR2,
      p_per_information7    VARCHAR2,
      p_per_information8    VARCHAR2,
      p_per_information9    VARCHAR2,
      p_per_information10   VARCHAR2,
      p_per_information11   VARCHAR2,
      p_per_information12   VARCHAR2,
      p_per_information13   VARCHAR2,
      p_per_information14   VARCHAR2,
      p_per_information15   VARCHAR2,
      p_per_information18   VARCHAR2
   )
   IS
      l_proc   CONSTANT VARCHAR2 (72) := g_package || 'CREATE_RU_CWK';
   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
      --
      -- Check for Citizenship
      hr_api.mandatory_arg_error
                  (p_api_name            => l_proc,
                   p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'CITIZENSHIP'
                                                            ),
                   p_argument_value      => p_per_information4
                  );
      hr_ru_utility.check_lookup_value
                   (p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'CITIZENSHIP'
                                                            ),
                    p_argument_value      => p_per_information4,
                    p_lookup_type         => 'RU_CITIZENSHIP',
                    p_effective_date      => p_start_date
                   );
      validate_person (p_first_name             => p_first_name,
                       p_effective_date         => p_start_date,
		       p_per_information1       => p_per_information1,
                       p_per_information4       => p_per_information4,
                       p_per_information5       => p_per_information5,
                       p_per_information6       => p_per_information6,
                       p_per_information7       => p_per_information7,
                       p_per_information8       => p_per_information8,
                       p_per_information9       => p_per_information9,
                       p_per_information10      => p_per_information10,
                       p_per_information11      => p_per_information11,
                       p_per_information12      => p_per_information12,
                       p_per_information13      => p_per_information13,
                       p_per_information14      => p_per_information14,
                       p_per_information15      => p_per_information15,
                       p_per_information18      => p_per_information18
                      );
     END IF;
   END create_ru_cwk;

   PROCEDURE update_ru_person (
      p_person_id           NUMBER,
      p_first_name          VARCHAR2,
      p_person_type_id      NUMBER,
      p_effective_date      DATE,
      p_date_of_birth       DATE,
      p_sex                 VARCHAR2,
      p_per_information1    VARCHAR2,
      p_per_information4    VARCHAR2,
      p_per_information5    VARCHAR2,
      p_per_information6    VARCHAR2,
      p_per_information7    VARCHAR2,
      p_per_information8    VARCHAR2,
      p_per_information9    VARCHAR2,
      p_per_information10   VARCHAR2,
      p_per_information11   VARCHAR2,
      p_per_information12   VARCHAR2,
      p_per_information13   VARCHAR2,
      p_per_information14   VARCHAR2,
      p_per_information15   VARCHAR2,
      p_per_information18   VARCHAR2
   )
   IS
      l_proc            CONSTANT VARCHAR2 (72)
                                           := g_package || 'UPDATE_RU_PERSON';
      -- l_age                      NUMBER;
      l_date_of_birth            per_all_people_f.date_of_birth%TYPE;
      l_sex                      per_all_people_f.sex%TYPE;
      l_per_information5         per_all_people_f.per_information5%TYPE;
      l_system_person_type       per_person_types.system_person_type%TYPE;
      l_seeded_person_type_key   per_person_types.seeded_person_type_key%TYPE;
      l_effective_date           DATE;

      CURSOR csr_get_person_info (p_id NUMBER)
      IS
         SELECT date_of_birth, sex, per_information5
           FROM per_all_people_f papf
          WHERE papf.person_id = p_id
            AND p_effective_date BETWEEN papf.effective_start_date
                                     AND papf.effective_end_date;

      l_person_info_rec          csr_get_person_info%ROWTYPE;

      CURSOR csr_ptu_type (c_person_id NUMBER, c_session_date DATE)
      IS
         SELECT ppt.system_person_type, ppt.seeded_person_type_key
           FROM per_person_types ppt, per_person_type_usages_f ptu
          WHERE ppt.person_type_id = ptu.person_type_id
            AND c_session_date BETWEEN ptu.effective_start_date
                                   AND ptu.effective_end_date
            AND ptu.person_id = c_person_id;
   BEGIN
     --
     -- Added for GSI Bug 5472781
     --
     IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
      --
      l_effective_date := TRUNC (p_effective_date);

      IF (p_person_type_id <> hr_api.g_number
         )                        -- If person type has changed , get new type
      THEN
         OPEN csr_val_person_type (p_person_type_id);

         FETCH csr_val_person_type
          INTO l_system_person_type, l_seeded_person_type_key;

         CLOSE csr_val_person_type;
      ELSE                            --else get from per_person_type_usages_f
         OPEN csr_ptu_type (p_person_id, l_effective_date);

         FETCH csr_ptu_type
          INTO l_system_person_type, l_seeded_person_type_key;

         CLOSE csr_ptu_type;
      END IF;
      -- Check Place of Birth takes valid OKATO lookup value
      IF (p_per_information1 <> hr_api.g_varchar2)
      THEN
	    hr_ru_utility.check_lookup_value
		  (p_argument            => hr_general.decode_lookup
							    ('RU_FORM_LABELS',
							     'PLACE_OF_BIRTH'
							    ),
		   p_argument_value      => p_per_information1,
		   p_lookup_type         => 'RU_OKATO',
		   p_effective_date      => p_effective_date
		  );
      END IF;
      --
      IF l_seeded_person_type_key <> 'CONTACT'
      THEN
         -- Check for Citizenship
         hr_api.mandatory_arg_error
                  (p_api_name            => l_proc,
                   p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'CITIZENSHIP'
                                                            ),
                   p_argument_value      => p_per_information4
                  );

         IF (p_per_information4 <> hr_api.g_varchar2)
         THEN
            hr_ru_utility.check_lookup_value
                  (p_argument            => hr_general.decode_lookup
                                                            ('RU_FORM_LABELS',
                                                             'CITIZENSHIP'
                                                            ),
                   p_argument_value      => p_per_information4,
                   p_lookup_type         => 'RU_CITIZENSHIP',
                   p_effective_date      => p_effective_date
                  );
         END IF;
      END IF;

      -- Check if Military Document is provided for male employees between 17 and 65
      IF l_system_person_type LIKE 'EMP%'
      THEN
		-- Check for first name
		IF (p_first_name <> hr_api.g_varchar2) OR (p_first_name IS NULL)
		THEN
		   hr_api.mandatory_arg_error
				(p_api_name            => l_proc,
				 p_argument            => hr_general.decode_lookup
											('RU_FORM_LABELS',
											 'FIRST_NAME'
											),
				 p_argument_value      => p_first_name
				);
		END IF;

         IF    (p_date_of_birth <> hr_api.g_date)
            OR (p_sex <> hr_api.g_varchar2)
            OR (   p_per_information5 <> hr_api.g_varchar2
                OR p_per_information5 IS NULL
               )
         THEN
            OPEN csr_get_person_info (p_person_id);

            FETCH csr_get_person_info
             INTO l_person_info_rec;

            CLOSE csr_get_person_info;

            l_sex := param_or_db (p_sex, l_person_info_rec.sex);
            l_date_of_birth :=
               param_or_db (p_date_of_birth, l_person_info_rec.date_of_birth);
            l_per_information5 :=
               param_or_db (p_per_information5,
                            l_person_info_rec.per_information5
                           );
            /* Suppressing the error of military documents being mandatory
            as per bug 8663065  */
            --l_age :=
            --    TRUNC (MONTHS_BETWEEN (l_effective_date, l_date_of_birth) / 12);

            --IF     l_sex = 'M'
            --   AND (l_age BETWEEN 17 AND 65)
            --  AND l_per_information5 IS NULL
            --THEN
            --   hr_utility.set_message (800, 'HR_RU_MIL_DOC_REQUIRED');
            --   hr_utility.raise_error;
            --END IF;
         END IF;
      END IF;

      validate_person_upd (p_first_name             => p_first_name,
                           p_person_id              => p_person_id,
                           p_effective_date         => p_effective_date,
                           p_per_information4       => p_per_information4,
                           p_per_information5       => p_per_information5,
                           p_per_information6       => p_per_information6,
                           p_per_information7       => p_per_information7,
                           p_per_information8       => p_per_information8,
                           p_per_information9       => p_per_information9,
                           p_per_information10      => p_per_information10,
                           p_per_information11      => p_per_information11,
                           p_per_information12      => p_per_information12,
                           p_per_information13      => p_per_information13,
                           p_per_information14      => p_per_information14,
		           p_per_information15      => p_per_information15,
                           p_per_information18      => p_per_information18
                          );
     END IF;
   END update_ru_person;
END hr_ru_people_leg_hook;

/
