--------------------------------------------------------
--  DDL for Package Body HR_RU_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RU_UTILITY" AS
/* $Header: peruutil.pkb 120.2.12010000.2 2009/07/07 11:31:31 parusia ship $ */
---
----------------------------------------------------------------------
-- CHECK_LOOKUP_VALUE : Check if a valid lookup value has been passed
----------------------------------------------------------------------
   PROCEDURE check_lookup_value (
      p_argument         IN   VARCHAR2,
      p_argument_value   IN   VARCHAR2,
      p_lookup_type      IN   VARCHAR2,
      p_effective_date   IN   DATE
   )
   IS
--
   BEGIN
      --
      IF (hr_api.not_exists_in_hr_lookups (p_effective_date,
                                           p_lookup_type,
                                           p_argument_value
                                          )
         )
      THEN
         hr_utility.set_message (800, 'HR_7209_API_LOOK_INVALID');
         hr_utility.set_message_token ('ARGUMENT', p_argument);
         hr_utility.raise_error;
      END IF;
--
   END check_lookup_value;


-----------------------------------------------------------------------------------------------
-- PER_RU_FULL_NAME : Full Name in the format Last Name First Name Middle Name
-----------------------------------------------------------------------------------------------

   FUNCTION per_ru_full_name (
      p_first_name          IN   VARCHAR2
     ,p_middle_names        IN   VARCHAR2
     ,p_last_name           IN   VARCHAR2
     ,p_known_as            IN   VARCHAR2
     ,p_title               IN   VARCHAR2
     ,p_suffix              IN   VARCHAR2
     ,p_pre_name_adjunct    IN   VARCHAR2
     ,p_per_information1    IN   VARCHAR2
     ,p_per_information2    IN   VARCHAR2
     ,p_per_information3    IN   VARCHAR2
     ,p_per_information4    IN   VARCHAR2
     ,p_per_information5    IN   VARCHAR2
     ,p_per_information6    IN   VARCHAR2
     ,p_per_information7    IN   VARCHAR2
     ,p_per_information8    IN   VARCHAR2
     ,p_per_information9    IN   VARCHAR2
     ,p_per_information10   IN   VARCHAR2
     ,p_per_information11   IN   VARCHAR2
     ,p_per_information12   IN   VARCHAR2
     ,p_per_information13   IN   VARCHAR2
     ,p_per_information14   IN   VARCHAR2
     ,p_per_information15   IN   VARCHAR2
     ,p_per_information16   IN   VARCHAR2
     ,p_per_information17   IN   VARCHAR2
     ,p_per_information18   IN   VARCHAR2
     ,p_per_information19   IN   VARCHAR2
     ,p_per_information20   IN   VARCHAR2
     ,p_per_information21   IN   VARCHAR2
     ,p_per_information22   IN   VARCHAR2
     ,p_per_information23   IN   VARCHAR2
     ,p_per_information24   IN   VARCHAR2
     ,p_per_information25   IN   VARCHAR2
     ,p_per_information26   IN   VARCHAR2
     ,p_per_information27   IN   VARCHAR2
     ,p_per_information28   IN   VARCHAR2
     ,p_per_information29   IN   VARCHAR2
     ,p_per_information30   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
--
      l_full_name   VARCHAR2 (240);
--
   BEGIN
--
      SELECT substr (LTRIM (RTRIM (   decode (p_last_name, NULL, '', ' ' || p_last_name)
                                   || decode (p_first_name, NULL, '', ' ' || p_first_name)
                                   || decode (p_middle_names, NULL, '', ' ' || p_middle_names)
                                  )
                           )
                    ,1
                    ,240
                    )
        INTO l_full_name
        FROM dual;

      RETURN l_full_name;
   --
   END per_ru_full_name;
--
-----------------------------------------------------------------------------------------------
-- PER_RU_FULL_NAME : Full Name with initials
-----------------------------------------------------------------------------------------------
   FUNCTION per_ru_full_name_initials (
      p_first_name           IN   VARCHAR2,
      p_middle_names         IN   VARCHAR2,
      p_last_name            IN   VARCHAR2,
      p_genitive_last_name   IN   VARCHAR2 DEFAULT NULL,
      p_known_as             IN   VARCHAR2 DEFAULT NULL,
      p_title                IN   VARCHAR2 DEFAULT NULL,
      p_suffix               IN   VARCHAR2 DEFAULT NULL,
      use_genitive           IN   BOOLEAN DEFAULT TRUE
   )
      RETURN VARCHAR2
   IS
      --
      l_full_name   VARCHAR2 (240);
      l_last_name   per_all_people_f.last_name%TYPE;
         --
   BEGIN
      --
      IF use_genitive
      THEN
         l_last_name := NVL (p_genitive_last_name, p_last_name);
      ELSE
         l_last_name := p_last_name;
      END IF;

      SELECT SUBSTR
                (LTRIM (RTRIM (   DECODE (l_last_name,
                                          NULL, '',
                                          ' ' || l_last_name
                                         )
                               || DECODE
                                        (p_first_name,
                                         NULL, '',
                                            ' '
                                         || SUBSTR
                                                  (RTRIM (LTRIM (p_first_name)),
                                                   1,
                                                   1
                                                  )
                                         || '.'
                                        )
                               || DECODE
                                      (p_middle_names,
                                       NULL, '',
                                          ' '
                                       || SUBSTR
                                                (RTRIM (LTRIM (p_middle_names)),
                                                 1,
                                                 1
                                                )
                                       || '.'
                                      )
                              )
                       ),
                 1,
                 240
                )
        INTO l_full_name
        FROM DUAL;

      RETURN l_full_name;
   --
   END per_ru_full_name_initials;

------------------------------------------------------------------------------------------------
-- CHECK_SPIF_NUMBER_UNIQUE : Uniqueness check for pension fund number across RU Business groups
------------------------------------------------------------------------------------------------

---
   PROCEDURE check_spif_number_unique (
      p_spifn               VARCHAR2
     ,p_person_id           NUMBER
     ,p_business_group_id   NUMBER
   )
   IS
--
      l_status             VARCHAR2 (1);
      l_legislation_code   VARCHAR2 (30);
      l_nat_lbl            VARCHAR2 (2000);
   BEGIN
      --
      BEGIN
         SELECT 'Y'
           INTO l_status
           FROM SYS.dual
          WHERE EXISTS (
                   SELECT '1'
                     FROM per_all_people_f pp
                    WHERE (p_person_id IS NULL OR p_person_id <> pp.person_id)
                      AND p_spifn = pp.per_information13
                      AND pp.business_group_id IN (
                             --Select all business groups having leg. code RU
                             SELECT o1.organization_id
                               FROM hr_organization_information o1, hr_organization_information o2
                              WHERE o1.org_information9 = 'RU'
                                AND o1.organization_id = o2.organization_id
                                AND o1.org_information_context = 'Business Group Information'
                                AND o2.org_information_context = 'CLASS'
                                AND o2.org_information1 = 'HR_BG'
                                AND o2.org_information2 = 'Y'));

         --
         IF l_status = 'Y'
         THEN
            hr_utility.set_message (801, 'HR_NI_UNIQUE_WARNING');
            hr_utility.set_message_token ('NI_NUMBER'
                                         ,hr_general.decode_lookup ('RU_FORM_LABELS', 'SPIFN')
                                         );
            hr_utility.set_warning;
         END IF;
      --
      EXCEPTION
         WHEN no_data_found
         THEN
            NULL;
      END;
   END check_spif_number_unique;

-----------------------------------------------------------------------------------------------
-- VALIDATE_SPIFN :Function to validate the Statutory Pension Insurance Fund Number
--          1 if validation fails
--          2 if Formula not present/compiled
-----------------------------------------------------------------------------------------------
   FUNCTION validate_spifn (spif_number VARCHAR2, p_session_date DATE)
      RETURN NUMBER
   IS
      l_formula_id       NUMBER;
      local_warning      EXCEPTION;

      CURSOR csr_formula
      IS
         SELECT formula_id
           FROM ff_compiled_info_f
          WHERE formula_id = l_formula_id
            AND p_session_date BETWEEN effective_start_date AND effective_end_date;

      l_inputs           ff_exec.inputs_t;
      l_outputs          ff_exec.outputs_t;
      l_effective_date   DATE;
      l_err              NUMBER;
   BEGIN
      SELECT formula_id, effective_start_date
        INTO l_formula_id, l_effective_date
        FROM ff_formulas_f fo, ff_formula_types ft
       WHERE ft.formula_type_name = 'Oracle Payroll'
         AND fo.formula_type_id = ft.formula_type_id
         AND fo.formula_name = 'RU_SPIFN_VALIDATION'
         AND p_session_date BETWEEN fo.effective_start_date AND fo.effective_end_date;

      OPEN csr_formula;

      FETCH csr_formula
       INTO l_formula_id;

      IF csr_formula%FOUND
      THEN
         l_err := 0;
         ff_exec.init_formula (l_formula_id, l_effective_date, l_inputs, l_outputs);

         FOR l_in_cnt IN l_inputs.FIRST .. l_inputs.LAST
         LOOP
            IF (l_inputs (l_in_cnt).NAME = 'SPIF_NUMBER')
            THEN
               l_inputs (l_in_cnt).VALUE := spif_number;
            END IF;
         END LOOP;

         ff_exec.run_formula (l_inputs, l_outputs);

         FOR l_out_cnt IN l_outputs.FIRST .. l_outputs.LAST
         LOOP
            IF     (l_outputs (l_out_cnt).NAME = 'RETURN_VALUE')
               AND (l_outputs (l_out_cnt).VALUE = 'INVALID_ID')
            THEN
               /*          hr_utility.set_message (800, 'HR_RU_INVALID_SPIF_NUMBER');
                         hr_utility.set_message_token
                                          ('NUMBER',
                                            hr_general.decode_lookup ('RU_FORM_LABELS',
                                                                      'SPIFN'
                                                                     )
                                          );
                        hr_utility.raise_error;*/
               l_err := 1;
            END IF;
         END LOOP;
      ELSE
         /*hr_utility.set_message (800, 'HR_RU_SPIFN_FORMULA_ERROR');
         hr_utility.raise_error;*/
         l_err := 2;
      END IF;

      CLOSE csr_formula;

      RETURN l_err;
   EXCEPTION
      WHEN no_data_found
      THEN
         /*hr_utility.set_message (800, 'HR_RU_SPIFN_FORMULA_ERROR');
         hr_utility.raise_error;*/
         l_err := 2;
         RETURN l_err;
   END validate_spifn;

  ---
-----------------------------------------------------------------------------------------------
 -- VALIDATE_MILITARY_REG_BOARD_CODE :Function to validate the Statutory Pension Insurance Fund Number
-----------------------------------------------------------------------------------------------
   PROCEDURE validate_mil_reg_board_code (p_military_reg_board_code VARCHAR2)
   IS
      l_tmp   VARCHAR2(7);
      l_len   NUMBER;
   BEGIN
      l_len := LENGTH (p_military_reg_board_code);
      IF (l_len <> 7) AND (l_len <> 6)
      THEN
         hr_utility.set_message (800, 'HR_RU_INVALID_MIL_REG_CODE');
         hr_utility.set_warning;
      ELSE
         SELECT translate (p_military_reg_board_code, '0123456789', ' ')
           INTO l_tmp
           FROM dual;
         IF (l_len =7 AND (l_tmp IS NULL OR hr_ni_chk_pkg.chk_nat_id_format(l_tmp,'A') = '0' )) OR (l_len=6 AND l_tmp IS NOT NULL)
         THEN
            hr_utility.set_message (800, 'HR_RU_INVALID_MIL_REG_CODE');
            hr_utility.set_warning;
         END IF;
      END IF;
   END validate_mil_reg_board_code;

--------------------------------------------------------------------------------------------
-- VALIDATE_TAX_NO : Function to Validate Individual Tax Number(INN)
--------------------------------------------------------------------------------------------
   FUNCTION validate_tax_no (p_org_info VARCHAR2)
      RETURN NUMBER
   IS
      l_tax_no   VARCHAR2 (10);
      d1         NUMBER;
      d2         NUMBER;
      d3         NUMBER;
      d4         NUMBER;
      d5         NUMBER;
      d6         NUMBER;
      d7         NUMBER;
      d8         NUMBER;
      d9         NUMBER;
      d10        NUMBER;
      l_cc       NUMBER;
      l_temp     NUMBER;
      l_chk_code NUMBER;
   BEGIN
      l_chk_code :=
         instr (p_org_info, '.', 1, 1) + instr (p_org_info, '-', 1, 1)
         + instr (p_org_info, '+', 1, 1);
      IF l_chk_code > 0
      THEN
         RETURN 0;
      END IF;
      IF LENGTH (p_org_info) <> 10
      THEN
         RETURN 0;
      END IF;
      IF p_org_info = '0000000000'
      THEN
         RETURN 0;
      END IF;

      d1 := substr (p_org_info, 1, 1);
      d2 := substr (p_org_info, 2, 1);
      d3 := substr (p_org_info, 3, 1);
      d4 := substr (p_org_info, 4, 1);
      d5 := substr (p_org_info, 5, 1);
      d6 := substr (p_org_info, 6, 1);
      d7 := substr (p_org_info, 7, 1);
      d8 := substr (p_org_info, 8, 1);
      d9 := substr (p_org_info, 9, 1);
      d10 := substr (p_org_info, 10, 1);

      l_temp :=
            (2 * d1)
          + (4 * d2)
          + (10 * d3)
          + (3 * d4)
          + (5 * d5)
          + (9 * d6)
          + (4 * d7)
          + (6 * d8)
          + (8 * d9);
      l_temp := MOD (l_temp, 11);
      l_cc := MOD (l_temp, 10);
      IF (d10 <> l_cc)
      THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   END validate_tax_no;

   --
--------------------------------------------------------------------------------------------
-- VALIDATE_OGRN : Function to validate Main Statutory Registration Number(OGRN)
--------------------------------------------------------------------------------------------
   FUNCTION validate_ogrn (p_org_info VARCHAR2)
      RETURN NUMBER
   IS
      l_ogrn_no    NUMBER;
      l_cc         NUMBER;
      l_temp       NUMBER;
      l_reg_date   DATE;
      l_chk_code   NUMBER;
   BEGIN
      IF LENGTH (p_org_info) <> 13
     THEN
         RETURN 0;
      END IF;
      IF p_org_info = '0000000000000'
      THEN
         RETURN 0;
      END IF;
      l_chk_code :=
         instr (p_org_info, '.', 1, 1) + instr (p_org_info, '-', 1, 1)
         + instr (p_org_info, '+', 1, 1);
      IF l_chk_code > 0
      THEN
         RETURN 0;
      END IF;
      IF substr (p_org_info, 1, 1) <> '1' AND substr (p_org_info, 1, 1) <> '2'
      THEN
         RETURN 0;
      END IF;
      /*l_ogrn_no := substr (p_org_info, 1, 3) || substr (p_org_info, 6, 8);
      l_cc := MOD (l_ogrn_no, 10);
      l_ogrn_no := substr(l_ogrn_no,1,10);
      l_temp := MOD (l_ogrn_no, 11);
      IF (l_cc <> l_temp)
      THEN
         RETURN 0;
      END IF;*/
	-- For bug 5191590
	l_ogrn_no := substr (p_org_info, 1,12);
	l_temp := substr(p_org_info,13,1);
	l_cc := MOD(l_ogrn_no,11);
	IF (l_cc = 10) THEN
		l_cc := 0;
	END IF;
	IF l_cc <> l_temp then
		RETURN 0;
	END IF;
	-- End bug 5191590
	RETURN 1;

   END validate_ogrn;

--
---------------------------------------------------------------------------------------------------
-- CHECK_TAX_NUMBER_UNIQUE :Function to check for the Uniqueness of the Individual Tax Number(INN)
---------------------------------------------------------------------------------------------------
   FUNCTION check_tax_number_unique (p_tax_no VARCHAR2, p_org_id NUMBER, p_org_info_code VARCHAR2)
      RETURN NUMBER
   IS
--
      l_status   VARCHAR2 (1);

      CURSOR c_unique_status
      IS
         SELECT 'Y'
           FROM SYS.dual
          WHERE EXISTS (
                   SELECT '1'
                     FROM hr_organization_units hou, hr_organization_information hoi
                    WHERE (p_org_id <> hoi.organization_id)
                      AND hou.organization_id = hoi.organization_id
                      AND hou.business_group_id  IN (
                             SELECT o3.organization_id
                               FROM hr_organization_information o3, hr_organization_information o4
                              WHERE o3.org_information9 = 'RU'
                                AND o3.organization_id = o4.organization_id
                                AND o3.org_information_context = 'Business Group Information'
                                AND o4.org_information_context = 'CLASS'
                                AND o4.org_information1 = 'HR_BG'
                                AND o4.org_information2 = 'Y')
                      AND p_tax_no = hoi.org_information2
                      AND p_org_info_code = hoi.org_information_context);
   BEGIN
      --
      BEGIN
         OPEN c_unique_status;

         FETCH c_unique_status
          INTO l_status;

         CLOSE c_unique_status;

         --
         IF l_status = 'Y'
         THEN
            hr_utility.set_message (800, 'HR_RU_INVALID_TAX_NO');
            RETURN 0;
         END IF;
         RETURN 1;
      END;
   END check_tax_number_unique;

  --
-----------------------------------------------------------------------------------------------
-- VALIDATE_KPP :Function to validate the Code of reason for Tax Control's Registration(KPP)
-----------------------------------------------------------------------------------------------
   FUNCTION validate_kpp (p_kpp VARCHAR2)
      RETURN NUMBER
   IS
      chk_code   NUMBER;
   BEGIN
      IF LENGTH (p_kpp) <> 9
      THEN
         RETURN 0;
      END IF;
      IF hr_ni_chk_pkg.chk_nat_id_format (p_kpp, 'DDDDDDDDD') = '0'
      THEN
         RETURN 0;
      END IF;
      IF p_kpp = '000000000'
      THEN
         RETURN 0;
      END IF;
      chk_code := instr (p_kpp, '.', 1, 1) + instr (p_kpp, '-', 1, 1) + instr (p_kpp, '+', 1, 1);
      IF chk_code > 0
      THEN
         RETURN 0;
      END IF;
      RETURN 1;
   END validate_kpp;

--
-----------------------------------------------------------------------------------------------
-- VALIDATE_SI :Function to validate the Registration Number in the Social Insurance Fund
-----------------------------------------------------------------------------------------------
   FUNCTION validate_si (p_si VARCHAR2)
      RETURN NUMBER
   IS
      chk_code   NUMBER;
   BEGIN
      IF p_si = '0000000000'
      THEN
         RETURN 0;
      END IF;
      chk_code := instr (p_si, '.', 1, 1) + instr (p_si, '-', 1, 1) + instr (p_si, '+', 1, 1);
      IF chk_code > 0
      THEN
         RETURN 0;
      END IF;
      IF hr_ni_chk_pkg.chk_nat_id_format (p_si, 'DDDDDDDDDD') = '0'
      THEN
         RETURN 0;
      END IF;
      RETURN 1;
   END validate_si;

--
-----------------------------------------------------------------------------------------------------------
-- VALIDATE_OKOGU :Function to validate the All-Russian Classificatory of Public Authorities and Management
------------------------------------------------------------------------------------------------------------
   FUNCTION validate_okogu (p_okogu VARCHAR2)
      RETURN NUMBER
   IS
      chk_code   NUMBER;
   BEGIN
      IF p_okogu = '00000'
      THEN
         RETURN 0;
      END IF;
      chk_code := instr (p_okogu, '.', 1, 1) + instr (p_okogu, '-', 1, 1)
                  + instr (p_okogu, '+', 1, 1);
      IF chk_code > 0
      THEN
         RETURN 0;
      END IF;
      IF hr_ni_chk_pkg.chk_nat_id_format (p_okogu, 'DDDDD') = '0'
      THEN
         RETURN 0;
      END IF;
      RETURN 1;
   END validate_okogu;

--
--------------------------------------------------------------------------------------------------------
-- VALIDATE_OKPO :Function to validate the All-Russian Classificatory of Enterprises and Organizations
--------------------------------------------------------------------------------------------------------
   FUNCTION validate_okpo (p_okpo VARCHAR2)
      RETURN NUMBER
   IS
      chk_code   NUMBER;
   BEGIN
      IF LENGTH (p_okpo) <> 8
      THEN
         RETURN 0;
      END IF;
      IF hr_ni_chk_pkg.chk_nat_id_format (p_okpo, 'DDDDDDDD') = '0'
      THEN
         RETURN 0;
      END IF;
      IF p_okpo = '00000000'
      THEN
         RETURN 0;
      END IF;
      chk_code := instr (p_okpo, '.', 1, 1) + instr (p_okpo, '-', 1, 1) + instr (p_okpo, '+', 1, 1);
      IF chk_code > 0
      THEN
         RETURN 0;
      END IF;
      RETURN 1;
   END validate_okpo;

------------------------------------------------------------------------------------------------------------
-- VALIDATE_ORG_SPIFN :Function to validate the Registration Number in the Obligatory Medical Insurance Fund
------------------------------------------------------------------------------------------------------------
   FUNCTION validate_org_spifn (p_spifn VARCHAR2)
      RETURN NUMBER
   IS
      chk_code   NUMBER;
   BEGIN
      IF p_spifn = '000-000-000000'
      THEN
         RETURN 0;
      END IF;
      chk_code := instr (p_spifn, '.', 1, 1) + instr (p_spifn, '+', 1, 1);
      IF chk_code > 0
      THEN
         RETURN 0;
      END IF;
      IF hr_ni_chk_pkg.chk_nat_id_format (p_spifn, 'DDD-DDD-DDDDDD') = '0'
      THEN
         RETURN 0;
      END IF;
      IF instr (p_spifn, '-', 1) <> 4 OR instr (p_spifn, '-', 5) <> 8
      THEN
         RETURN 0;
      END IF;
      RETURN 1;
   END validate_org_spifn;


--------------------------------------------------------------------------------------------------------
-- VALIDATE_OKVED :Function to validate the All-Russian Classificatory of Company's activities types
--------------------------------------------------------------------------------------------------------
   FUNCTION validate_okved (p_okved VARCHAR2)
      RETURN NUMBER
   IS
      chk_code   NUMBER;
   BEGIN
      IF     chk_id_format (p_okved, 'DD') = '0'
         AND chk_id_format (p_okved, 'DD.D') = '0'
         AND chk_id_format (p_okved, 'DD.DD') = '0'
         AND chk_id_format (p_okved, 'DD.DD.D') = '0'
         AND chk_id_format (p_okved, 'DD.DD.DD') = '0'
      THEN
         RETURN 0;
      END IF;
    chk_code := instr (p_okved, '-', 1, 1) + instr (p_okved, '+', 1, 1);
      IF chk_code > 0
      THEN
         RETURN 0;
      END IF;
      chk_code := LENGTH (p_okved);
      IF chk_code = 4 OR chk_code = 5
      THEN
         IF instr (p_okved, '.', 1) <> 3 OR instr (p_okved, '.', 4) <> 0
         THEN
            RETURN 0;
         END IF;
      ELSIF chk_code = 7 OR chk_code = 8
      THEN
         IF instr (p_okved, '.', 1) <> 3 OR instr (p_okved, '.', 4) <> 6 OR instr (p_okved, '.', 7) <> 0
         THEN
            RETURN 0;
         END IF;
      ELSIF chk_code <> 2
      THEN
         RETURN 0;
      END IF;
      IF    p_okved = '00'
         OR p_okved = '00.0'
         OR p_okved = '00.00'
         OR p_okved = '00.00.0'
         OR p_okved = '00.00.00'
      THEN
         RETURN 0;
      END IF;
      RETURN 1;
   END validate_okved;

-----------------------------------------------------------
   FUNCTION validate_bik (p_bank_bik VARCHAR2)
      RETURN NUMBER
   IS
      chk_code   NUMBER;
   BEGIN
      IF LENGTH (p_bank_bik) <> 9
      THEN
         RETURN 0;
      END IF;
      IF hr_ni_chk_pkg.chk_nat_id_format (p_bank_bik, 'DDDDDDDDD') = '0'
      THEN
         RETURN 0;
      END IF;
      IF p_bank_bik = '000000000'
      THEN
         RETURN 0;
      END IF;
      chk_code :=
         instr (p_bank_bik, '.', 1, 1) + instr (p_bank_bik, '-', 1, 1)
         + instr (p_bank_bik, '+', 1, 1);
      IF chk_code > 0
      THEN
         RETURN 0;
      END IF;
      RETURN 1;
   END validate_bik;

-----------------------------------------------------------
   FUNCTION validate_acc_no (p_bank_acc_no VARCHAR2)
      RETURN NUMBER
   IS
      chk_code   NUMBER;
   BEGIN
      IF LENGTH (p_bank_acc_no) <> 20
      THEN
         RETURN 0;
      END IF;
      IF hr_ni_chk_pkg.chk_nat_id_format (p_bank_acc_no, 'DDDDDDDDDDDDDDDDDDDD') = '0'
      THEN
         RETURN 0;
      END IF;
      IF p_bank_acc_no = '00000000000000000000'
      THEN
         RETURN 0;
      END IF;
      chk_code :=
           instr (p_bank_acc_no, '.', 1, 1)
         + instr (p_bank_acc_no, '-', 1, 1)
         + instr (p_bank_acc_no, '+', 1, 1);
      IF chk_code > 0
      THEN
         RETURN 0;
      END IF;
      RETURN 1;
   END validate_acc_no;

----------------------------------------------------------
 ------------------------------------------------
 -- Bank Code Validation Function
 ------------------------------------------------
   FUNCTION validate_bank_info (p_bank_inn VARCHAR2)
      RETURN NUMBER
   IS
      l_flag   NUMBER;
      chk_code  NUMBER;
   BEGIN
      chk_code :=
           instr (p_bank_inn, '.', 1, 1)
         + instr (p_bank_inn, '-', 1, 1)
         + instr (p_bank_inn, '+', 1, 1);
      IF chk_code > 0
      THEN
         RETURN 0;
      END IF;
      l_flag := validate_tax_no (p_bank_inn);
      RETURN l_flag;
   END validate_bank_info;

   FUNCTION chk_id_format (p_id IN VARCHAR2, p_format_string IN VARCHAR2)
      RETURN VARCHAR2
   AS
      l_nat_id                  VARCHAR2 (30);
      l_format_mask             VARCHAR2 (30);
      l_format_string           VARCHAR2 (30);
      l_valid                   NUMBER;
      l_len_format_mask         NUMBER;
      l_number_format_ch        NUMBER;
      l_no_format_nat_id        VARCHAR2 (30);
      l_no_format_string_opt    VARCHAR2 (30);
      l_no_format_string_nopt   VARCHAR2 (30);
      l_format_count            NUMBER;
      l_nat_id_count            NUMBER;
      l_lgth_string_nopt        NUMBER;
      l_lgth_string_opt         NUMBER;
      l_lgth_nat_id             NUMBER;
   --
   BEGIN
      --
      --
      l_nat_id := '0';
      l_valid := 1;
/* First Derive the format mask from the format string.
   This is defined as the remainder of the string, after
   the format characters, namely 'ABDEX' have been removed.
   Also generate the format mask without any kind of
   format characters for continued use in the processing */
      l_format_mask := translate (p_format_string, 'CABDEX', 'C');
      l_format_string := translate (p_format_string, 'A !."$%^&*()-_+=`[]{};''#:@~<>?', 'A');
/* Check validity of format string  */
      IF translate (l_format_string, 'CABDEX', 'C') IS NULL
      THEN
/* Check validity of format mask */
         IF translate (upper (l_format_mask), 'A !."$%^&*()-_+=`[]{};''#:@~<>?', 'A') IS NULL
         THEN
            /* Check that the format string and id number are the same length */
            /*  - that is minus any optional characters */
            l_no_format_string_opt := translate (upper (l_format_string), 'ABDEX', 'ABDEX');
            l_no_format_string_nopt := translate (upper (l_format_string), 'ADXBE', 'ADX');
            l_no_format_nat_id := translate (upper (p_id), 'A !."$%^&*()-_+=`[]{};''#:@~<>?', 'A');
            l_lgth_string_nopt := LENGTH (l_no_format_string_nopt);
            l_lgth_string_opt := LENGTH (l_no_format_string_opt);
            l_lgth_nat_id := LENGTH (l_no_format_nat_id);
            IF ((l_lgth_nat_id >= l_lgth_string_nopt) AND (l_lgth_nat_id <= l_lgth_string_opt))
            THEN
               /* If processing reaches this point, we have a valid format mask, a valid format string
                  and a format string that can be checked against the id
                  Main format validation can now preceed */
               FOR l_char_pos IN 1 .. l_lgth_string_opt
               LOOP
                  IF (substr (l_no_format_string_opt, l_char_pos, 1) = 'A')
                  THEN
                     IF (   substr (l_no_format_nat_id, l_char_pos, 1) < 'A'
                         OR substr (l_no_format_nat_id, l_char_pos, 1) > 'Z'
                        )
                     THEN
                        l_valid := 0;
                     END IF;
                  ELSIF (substr (l_no_format_string_opt, l_char_pos, 1) = 'B')
                  THEN
                     IF (l_lgth_nat_id >= l_char_pos)
                     THEN
                        IF (   substr (l_no_format_nat_id, l_char_pos, 1) < 'A'
                            OR substr (l_no_format_nat_id, l_char_pos, 1) > 'Z'
                           )
                        THEN
                           l_valid := 0;
                        END IF;
                     END IF;
                  ELSIF (substr (l_no_format_string_opt, l_char_pos, 1) = 'D')
                  THEN
                     IF (   substr (l_no_format_nat_id, l_char_pos, 1) < '0'
                         OR substr (l_no_format_nat_id, l_char_pos, 1) > '9'
                        )
                     THEN
                        l_valid := 0;
                     END IF;
                  ELSIF (substr (l_no_format_string_opt, l_char_pos, 1) = 'E')
                  THEN
                     IF (l_lgth_nat_id >= l_char_pos)
                     THEN
                        IF (   substr (l_no_format_nat_id, l_char_pos, 1) < '0'
                            OR substr (l_no_format_nat_id, l_char_pos, 1) > '9'
                           )
                        THEN
                           l_valid := 0;
                        END IF;
                     END IF;
                  ELSIF (substr (l_no_format_string_opt, l_char_pos, 1) = 'X')
                  THEN
                     IF     (   substr (l_no_format_nat_id, l_char_pos, 1) < '0'
                             OR substr (l_no_format_nat_id, l_char_pos, 1) > '9'
                            )
                        AND (   substr (l_no_format_nat_id, l_char_pos, 1) < 'A'
                             OR substr (l_no_format_nat_id, l_char_pos, 1) > 'Z'
                            )
                     THEN
                        l_valid := 0;
                     END IF;
                  END IF;
                  EXIT WHEN l_valid = 0;
               END LOOP;

               IF l_valid = 1
               THEN
                  /* We have a valid id - now to return it in the format mask required */
                  l_format_count := 1;
                  l_nat_id_count := 1;
                  /* Reset the id to null before adding the passed id */
                  l_nat_id := '';

                  FOR l_format_pos IN 1 .. LENGTH (p_format_string)
                  LOOP
--
--
                     IF (translate (substr (p_format_string, l_format_pos, 1), 'CABDEX', 'C') IS NOT NULL
                        )
                     THEN
                        /* We have a format character - add it on to the return id */
                        l_nat_id := l_nat_id || substr (p_format_string, l_format_pos, 1);
                     ELSE
                        /* We have a id character - add it on to the return variable */
                        l_nat_id := l_nat_id || substr (l_no_format_nat_id, l_nat_id_count, 1);
                        l_nat_id_count := l_nat_id_count + 1;
                     END IF;
                  END LOOP;
               ELSE
                  /* The id is not in the valid format */
                  -- dbms_output.put_line('The format of the id is not correct');
                  NULL;
               END IF;
            ELSE
               /* The format string and id are differing lengths */
               NULL;
            END IF;
         END IF;
      ELSE
/* The format string contains unexecpected characters - check to see if
   the format string and the id are identical, if so,
   then this corresponds to a special format inside the formula rather
   than here, now that the formulae are calling this function */
         NULL;
/* End format string check */
      END IF;
      --
      --
      RETURN l_nat_id;
   END chk_id_format;
   FUNCTION check_segment_number (entry_value IN VARCHAR2)
      RETURN VARCHAR2
	 AS
	 return_value VARCHAR2(2000);
   BEGIN
     return_value := '1';
     IF entry_value NOT IN ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20',
	 '21','22','23','24','25','26','27','28','29','30') THEN
           return_value := fnd_message.get_string('PER','HR_RU_INVALID_SEGMENT_NUMBER');
     END IF;
     RETURN return_value;
  END check_segment_number;

   FUNCTION check_contract_number_unique (
      p_contract_number     VARCHAR2
     ,p_assignment_id       NUMBER
     ,p_business_group_id   NUMBER
   ) RETURN VARCHAR2
   AS
--
      l_status             VARCHAR2(1);
   BEGIN
      --
      l_status := 'N';
      BEGIN

    -- bug 8660688
    -- criteria updated to exclude the current assignment during checking
	SELECT 'Y'
	INTO l_status
	FROM SYS.dual
	WHERE EXISTS (
			SELECT '1'
			FROM per_assignments_f paaf,
			hr_soft_coding_keyflex scl
			WHERE (paaf.assignment_id <> p_assignment_id
                   or
                   p_assignment_id is null)
            and   p_contract_number = scl.segment3
			AND   paaf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
			AND   paaf.business_group_id IN (
					--Select all business groups having leg. code RU
					SELECT o1.organization_id
					FROM hr_organization_information o1, hr_organization_information o2
					WHERE o1.org_information9 = 'RU'
					AND o1.organization_id = o2.organization_id
					AND o1.org_information_context = 'Business Group Information'
					AND o2.org_information_context = 'CLASS'
					AND o2.org_information1 = 'HR_BG'
					AND o2.org_information2 = 'Y'
					                 )
		       );


         --
return l_status;
      --
      EXCEPTION
         WHEN no_data_found
         THEN
            return('N');
      END;
   END check_contract_number_unique;

   FUNCTION check_assign_category (
      p_eff_start_date DATE
     ,p_eff_end_date   DATE
     ,p_assignment_id  NUMBER
     ,p_person_id NUMBER
     ,p_business_group_id NUMBER
   )  RETURN VARCHAR2
   AS
--
      l_status             VARCHAR2(1);
   BEGIN
      --
      l_status := 'N';

      BEGIN
SELECT 'Y'
INTO l_status
FROM SYS.dual
WHERE EXISTS (
		SELECT '1'
		FROM per_all_assignments_f paaf,
		     hr_soft_coding_keyflex scl
		WHERE (p_assignment_id IS NULL OR p_assignment_id <> paaf.assignment_id)
		AND    (nvl(scl.segment2,'N') = 'N' OR
		        paaf.soft_coding_keyflex_id IS NULL)
		and    paaf.person_id = p_person_id
		and    paaf.assignment_status_type_id = 1
		and    paaf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id(+)
		and    paaf.business_group_id = p_business_group_id
		and (
			(paaf.effective_start_date
			between p_eff_start_date and p_eff_end_date)
		    or
			(paaf.effective_end_date
			between p_eff_start_date and p_eff_end_date)
		    or
			(p_eff_start_date
			between paaf.effective_start_date and paaf.effective_end_date)
		    or
			(p_eff_end_date
			between paaf.effective_start_date and paaf.effective_end_date)
			)
	     );


         --
   return l_status;
      --
      EXCEPTION
         WHEN no_data_found
         THEN
            return('N');
      END;
   END check_assign_category;

END hr_ru_utility;

/
