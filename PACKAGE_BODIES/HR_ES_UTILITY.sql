--------------------------------------------------------
--  DDL for Package Body HR_ES_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ES_UTILITY" as
/* $Header: peesutil.pkb 120.2.12010000.4 2009/12/20 07:50:00 rpahune ship $ */
--------------------------------------------------------------------------------
-- FUNCTION check_DNI
--------------------------------------------------------------------------------
FUNCTION check_DNI(p_identifier_value VARCHAR2) RETURN VARCHAR2 AS
    --
    v_dni_return        VARCHAR2(30);
BEGIN
-- For Bug 3358291 did the SUBSTR of p_identifier_value
    v_dni_return := hr_ni_chk_pkg.chk_nat_id_format(substr(p_identifier_value,1,30)
                                                   ,'DDDDDDDD');
    IF  (v_dni_return='0') THEN
        RETURN 'N';
    ELSE
        RETURN 'Y';
    END IF;
    --
END check_DNI;
--
--------------------------------------------------------------------------------
-- FUNCTION check_NIF
--------------------------------------------------------------------------------
FUNCTION check_NIF(p_identifier_value VARCHAR2) RETURN VARCHAR2 AS
    --
    TYPE nif_tab IS TABLE OF CHAR INDEX BY BINARY_INTEGER;
    v_nif                   nif_tab;
    v_nif_num       VARCHAR2(8);
    v_nif_mod       NUMBER(2);
    v_nif_return        VARCHAR2(9);
    v_return        VARCHAR2(30);
    --
BEGIN
    --
    v_nif(1) := 'T';
    v_nif(2) := 'R';
    v_nif(3) := 'W';
    v_nif(4) := 'A';
    v_nif(5) := 'G';
    v_nif(6) := 'M';
    v_nif(7) := 'Y';
    v_nif(8) := 'F';
    v_nif(9) := 'P';
    v_nif(10) := 'D';
    v_nif(11) := 'X';
    v_nif(12) := 'B';
    v_nif(13) := 'N';
    v_nif(14) := 'J';
    v_nif(15) := 'Z';
    v_nif(16) := 'S';
    v_nif(17) := 'Q';
    v_nif(18) := 'V';
    v_nif(19) := 'H';
    v_nif(20) := 'L';
    v_nif(21) := 'C';
    v_nif(22) := 'K';
    v_nif(23) := 'E';
    --
    v_return := hr_ni_chk_pkg.chk_nat_id_format(substr(p_identifier_value,1,30)
                                                ,'DDDDDDDDA');
    IF  v_return = '0' THEN
        RETURN 'N';
    ELSE
        v_nif_num := substr(p_identifier_value,1,8);
        v_nif_mod := mod(to_number(v_nif_num),23) + 1;
        v_nif_return := v_nif_num||v_nif(v_nif_mod);
        IF  (v_nif_return=p_identifier_value) THEN
            RETURN 'Y';
        ELSE
            RETURN 'N';
        END IF;
    END IF;
    --
END check_NIF;
--
--------------------------------------------------------------------------------
-- FUNCTION check_NIE
--------------------------------------------------------------------------------
FUNCTION check_NIE(p_identifier_value VARCHAR2) RETURN VARCHAR2 AS
    --
    v_nie_return        VARCHAR2(30);
    --
BEGIN
    -- Bug 7214735
    -- Changing the valid format for NIE to ADDDDDDDDA ( like A12345678Z ),
    -- i.e, 8 digits inplace of 7
    -- v_nie_return := hr_ni_chk_pkg.chk_nat_id_format(substr(p_identifier_value,1,30)
    --                                                 ,'ADDDDDDDA');
    v_nie_return := hr_ni_chk_pkg.chk_nat_id_format(substr(p_identifier_value,1,30)
                                                       ,'ADDDDDDDDA');

    IF (v_nie_return='0') THEN
        RETURN 'N';
    ELSE
        RETURN 'Y';
    END IF;
END check_NIE;
--
--------------------------------------------------------------------------------
-- FUNCTION per_es_full_name
--------------------------------------------------------------------------------
FUNCTION per_es_full_name(
                p_first_name        IN VARCHAR2
               ,p_middle_names      IN VARCHAR2
               ,p_last_name         IN VARCHAR2
               ,p_known_as          IN VARCHAR2
               ,p_title             IN VARCHAR2
               ,p_suffix            IN VARCHAR2
               ,p_pre_name_adjunct  IN VARCHAR2
               ,p_per_information1  IN VARCHAR2
               ,p_per_information2  IN VARCHAR2
               ,p_per_information3  IN VARCHAR2
               ,p_per_information4  IN VARCHAR2
               ,p_per_information5  IN VARCHAR2
               ,p_per_information6  IN VARCHAR2
               ,p_per_information7  IN VARCHAR2
               ,p_per_information8  IN VARCHAR2
               ,p_per_information9  IN VARCHAR2
               ,p_per_information10 IN VARCHAR2
               ,p_per_information11 IN VARCHAR2
               ,p_per_information12 IN VARCHAR2
               ,p_per_information13 IN VARCHAR2
               ,p_per_information14 IN VARCHAR2
               ,p_per_information15 IN VARCHAR2
               ,p_per_information16 IN VARCHAR2
               ,p_per_information17 IN VARCHAR2
               ,p_per_information18 IN VARCHAR2
               ,p_per_information19 IN VARCHAR2
               ,p_per_information20 IN VARCHAR2
               ,p_per_information21 IN VARCHAR2
               ,p_per_information22 IN VARCHAR2
               ,p_per_information23 IN VARCHAR2
               ,p_per_information24 IN VARCHAR2
               ,p_per_information25 IN VARCHAR2
               ,p_per_information26 IN VARCHAR2
               ,p_per_information27 IN VARCHAR2
               ,p_per_information28 IN VARCHAR2
               ,p_per_information29 IN VARCHAR2
               ,p_per_information30 IN VARCHAR2)
    RETURN VARCHAR2 IS
        --
        l_full_name  VARCHAR2(240);
        --
    BEGIN
        --
        SELECT substr(LTRIM(RTRIM(
              DECODE(p_last_name, NULL, '', ' ' || p_last_name)
              ||DECODE(p_per_information1, NULL,'',' ' || p_per_information1)
              ||DECODE(p_first_name,NULL, '', ', ' || p_first_name)
              )), 1, 240)
        INTO   l_full_name
        FROM   dual;
RETURN(l_full_name);
        --
END per_es_full_name;
--------------------------------------------------------------------------------
-- FUNCTION validate_identifier
--------------------------------------------------------------------------------
FUNCTION validate_identifier(p_identifier_type  VARCHAR2
                            ,p_identifier_value VARCHAR2) RETURN VARCHAR2 IS
    --
    l_value   VARCHAR2(3);
    --
BEGIN
    IF  (p_identifier_type='DNI') THEN
        l_value := check_DNI(p_identifier_value);
        IF  l_value <> 'Y' THEN
            hr_utility.set_message(800, 'HR_ES_INVALID_DNI');
            hr_utility.raise_error;
        END IF;
    ELSIF(p_identifier_type='NIE') THEN
        l_value := check_NIE(p_identifier_value);
        IF  l_value <> 'Y' THEN
            hr_utility.set_message(800, 'HR_ES_INVALID_NIE');
            hr_utility.raise_error;
        END IF;
    ELSIF(p_identifier_type NOT IN('DNI','NIE')
        AND p_identifier_value IS NOT NULL) THEN
        l_value := 'Y';
    END IF;
    --
    RETURN l_value;
    --
END validate_identifier;

--------------------------------------------------------------------------------
-- FUNCTION validate Account account_no
--------------------------------------------------------------------------------
FUNCTION validate_account_no (p_bank_code        VARCHAR2 default null
                            ,p_branch_code      VARCHAR2 default null
                            ,p_account_number   VARCHAR2 default null
                            ,p_validation_code  VARCHAR2 default null
                            ,p_acc_type         varchar2
                            ,p_iban_acc         varchar2 default null) return number IS

   l_ret number;
   begin
   l_ret := 0;
--------------------------------------------------------------------------------
-- If account type is normal (N) call the validate_non_IBAN_acc_no
--------------------------------------------------------------------------------
   if p_acc_type = 'N' then
     if p_account_number is null then
        l_ret := 2;
        return l_ret;
     end if;
     if ( p_bank_code is not null and p_branch_code is not null and
         p_account_number is not null and p_validation_code is not null) then

        l_ret := validate_non_IBAN_acc_no (
                   p_bank_code       => p_bank_code
                  ,p_branch_code     => p_branch_code
                  ,p_account_number  => p_account_number
                  ,p_validation_code => p_validation_code
                   );
--   l_ret will have 1 if validation paased.
     end if;
   return l_ret;
   end if;
--------------------------------------------------------------------------------
-- If account type is IBAN (Y) call the validate_iban_acc
--------------------------------------------------------------------------------
   if p_acc_type = 'Y' then
      if p_iban_acc is null then
         l_ret :=2;
      else
         l_ret := validate_iban_acc
                 ( p_account_no  => p_iban_acc
                 );
      end if;
      return l_ret;
   end if;
--------------------------------------------------------------------------------
-- If account type is Combine (C) check if at least one account is not null
--------------------------------------------------------------------------------

   IF p_acc_type = 'C' and (p_account_number is not null
                        or p_iban_acc is not null) then
      hr_utility.set_location(' inside first if',1);
      return  l_ret;
   end if;
   l_ret := 3;
   return l_ret;
   end validate_account_no;

--------------------------------------------------------------------------------
-- FUNCTION validate_account_no
--------------------------------------------------------------------------------
FUNCTION validate_non_IBAN_acc_no(p_bank_code        VARCHAR2
                            ,p_branch_code      VARCHAR2
                            ,p_account_number   VARCHAR2
                            ,p_validation_code  VARCHAR2) RETURN NUMBER IS
    --
    X1                  NUMBER;
    X2                  NUMBER;
    X3                  NUMBER;
    X4                  NUMBER;
    X5                  NUMBER;
    X6                  NUMBER;
    X7                  NUMBER;
    X8                  NUMBER;
    X9                  NUMBER;
    X10                 NUMBER;
    first_check_digit   NUMBER;
    second_check_digit  NUMBER;
    check_digit         NUMBER;
    --
    chk_code     number;
BEGIN
    --
    -- Bug no 3516026
    chk_code := instr(p_branch_code,'.',1,1) + instr(p_branch_code,'-',1,1) + instr(p_branch_code,'+',1,1) +
                instr(p_account_number,'.',1,1) + instr(p_account_number,'-',1,1) + instr(p_account_number,'+',1,1) +
                instr(p_validation_code,'.',1,1) + instr(p_validation_code,'-',1,1) + instr(p_validation_code,'+',1,1);
    IF chk_code > 0 THEN
       return 0;
    END IF;
-- End Bug no 3516026

    X1 := 0;
    X2 := 0;
    X3 := substr(p_bank_code,1,1);
    X4 := substr(p_bank_code,2,1);
    X5 := substr(p_bank_code,3,1);
    X6 := substr(p_bank_code,4,1);
    --
    X7 := substr(p_branch_code,1,1);
    X8 := substr(p_branch_code,2,1);
    X9 := substr(p_branch_code,3,1);
    X10 := substr(p_branch_code,4,1);
    --
    first_check_digit  := substr(p_validation_code,1,1);
    second_check_digit := substr(p_validation_code,2,1);
    --
    check_digit := (X1*1) + (X2*2)  + (X3*4) + (X4*8)
                 + (X5*5) + (X6*10) + (X7*9) + (X8*7)
                 + (X9*3) + (X10*6);
    --
    check_digit := 11 - mod(check_digit,11);
    --
    -- for bug 3390728
    IF check_digit = 10 THEN
        check_digit := 1;
    ELSIF check_digit = 11 THEN
        check_digit := 0;
    END IF;

    IF  check_digit <> first_check_digit THEN
        RETURN 0;
    END IF;
    --
    X1  := substr(p_account_number,1,1);
    X2  := substr(p_account_number,2,1);
    X3  := substr(p_account_number,3,1);
    X4  := substr(p_account_number,4,1);
    X5  := substr(p_account_number,5,1);
    X6  := substr(p_account_number,6,1);
    X7  := substr(p_account_number,7,1);
    X8  := substr(p_account_number,8,1);
    X9  := substr(p_account_number,9,1);
    X10 := substr(p_account_number,10,1);

    check_digit := (X1*1) + (X2*2)  + (X3*4) + (X4*8)
                 + (X5*5) + (X6*10) + (X7*9) + (X8*7)
                 + (X9*3) + (X10*6);
    --
    check_digit := 11 - mod(check_digit,11);
    --
    -- for bug 3390728
    IF check_digit = 10 THEN
        check_digit := 1;
    ELSIF check_digit = 11 THEN
        check_digit := 0;
    END IF;

    IF  check_digit <> second_check_digit THEN
        RETURN 0;
    END IF;
    --
    RETURN 1;
    --
END validate_non_IBAN_acc_no;
--
PROCEDURE check_identifier_unique
( p_identifier_type         VARCHAR2,
  p_identifier_value        VARCHAR2,
  p_person_id               NUMBER,
  p_business_group_id       NUMBER)
  is
--
  l_status            VARCHAR2(1);
  l_legislation_code  VARCHAR2(30);
  l_nat_lbl           VARCHAR2(2000);
  local_warning       EXCEPTION;

BEGIN
   --
  BEGIN
     SELECT 'Y'
     INTO   l_status
     FROM   sys.dual
     WHERE  exists(SELECT '1'
                   FROM   per_people_f pp
                   WHERE (p_person_id IS NULL OR p_person_id <> pp.person_id)
                   AND    p_identifier_value = pp.per_information3
                   AND    p_identifier_type = pp.per_information2
                   AND    pp.business_group_id  = p_business_group_id);
     --
        hr_utility.set_message(801,'HR_ES_NI_UNIQUE_WARNING');
        hr_utility.set_message_token('NI_NUMBER',hr_general.decode_lookup('ES_FORM_LABELS','IDENTIFIER_VALUE'));
        RAISE local_warning;
 --
  EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
  WHEN local_warning THEN
     hr_utility.set_warning;
  END;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','CHECK_IDENTIFIER_UNIQUE');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   WHEN local_warning THEN
     hr_utility.set_warning;
END check_identifier_unique;

--------------------------------------------------------------------------------
-- PROCEDURE validate_cif
--------------------------------------------------------------------------------
PROCEDURE validate_cif(p_org_info   VARCHAR2) is

l_inputs     ff_exec.inputs_t;
l_outputs     ff_exec.outputs_t;
l_formula_id   ff_formulas_f.formula_id%type;
l_formula_mesg   varchar2(50);
l_effective_start_date   ff_formulas_f.effective_start_date%type;

CURSOR get_formula_id is
SELECT formula_id, effective_start_date
FROM   ff_formulas_f
WHERE  formula_name = 'ES_CIF_VALIDATION'
AND    business_group_id is null
AND    legislation_code = 'ES'
AND    sysdate BETWEEN effective_start_date AND  effective_end_date;

BEGIN
    OPEN get_formula_id;
    FETCH get_formula_id INTO l_formula_id, l_effective_start_date;
    CLOSE get_formula_id;

    ff_exec.init_formula(l_formula_id, l_effective_start_date, l_inputs, l_outputs);
    FOR l_in_cnt IN l_inputs.first..l_inputs.LAST LOOP
        IF  l_inputs(l_in_cnt).name = 'CIF_NUMBER' THEN
            l_inputs(l_in_cnt).value := p_org_info;
        END IF;
    END LOOP;

    ff_exec.run_formula(l_inputs,l_outputs);

    FOR l_out_cnt IN l_outputs.first..l_outputs.LAST LOOP
        IF  l_outputs(l_out_cnt).name = 'RETURN_VALUE' THEN
            l_formula_mesg := l_outputs(l_out_cnt).value;
        END IF;
    END LOOP;

    IF  l_formula_mesg = 'INVALID_ID'  THEN
        hr_utility.set_message(800,'HR_ES_INVALID_CIF');
        hr_utility.raise_error;
    END IF;
END validate_cif;
--------------------------------------------------------------------------------
-- FUNCTION validate_cac_lookup
--------------------------------------------------------------------------------
FUNCTION validate_cac_lookup (p_province_code VARCHAR2) RETURN NUMBER is

CURSOR get_province_code(p_province_code VARCHAR2) is
    select 1 from hr_lookups
    where lookup_type='ES_PROVINCE_CODES'
    and lookup_code=p_province_code;

l_check             NUMBER;

BEGIN

    OPEN get_province_code(p_province_code);
    FETCH get_province_code into l_check;
    IF get_province_code%NOTFOUND THEN
        RETURN 0;
    END IF;
    CLOSE get_province_code;
RETURN 1;
END validate_cac_lookup;
--------------------------------------------------------------------------------
-- PROCEDURE validate_cac
--------------------------------------------------------------------------------
PROCEDURE validate_cac(p_org_info   VARCHAR2) is

l_inputs     ff_exec.inputs_t;
l_outputs     ff_exec.outputs_t;
l_formula_id   ff_formulas_f.formula_id%type;
l_formula_mesg   varchar2(50);
l_effective_start_date   ff_formulas_f.effective_start_date%type;

CURSOR get_formula_id is
SELECT formula_id, effective_start_date
FROM   ff_formulas_f
WHERE  formula_name = 'ES_CAC_VALIDATION'
AND    business_group_id is null
AND    legislation_code = 'ES'
AND    sysdate BETWEEN effective_start_date AND  effective_end_date;

BEGIN
    OPEN get_formula_id;
    FETCH get_formula_id INTO l_formula_id, l_effective_start_date;
    CLOSE get_formula_id;

    ff_exec.init_formula(l_formula_id, l_effective_start_date, l_inputs, l_outputs);
    FOR l_in_cnt IN l_inputs.first..l_inputs.LAST LOOP
        IF  l_inputs(l_in_cnt).name = 'CAC_NUMBER' THEN
            l_inputs(l_in_cnt).value := p_org_info;
        END IF;
    END LOOP;

    ff_exec.run_formula(l_inputs,l_outputs);

    FOR l_out_cnt IN l_outputs.first..l_outputs.LAST LOOP
        IF  l_outputs(l_out_cnt).name = 'RETURN_VALUE' THEN
            l_formula_mesg := l_outputs(l_out_cnt).value;
        END IF;
    END LOOP;

    IF  l_formula_mesg = 'INVALID_ID'  THEN
        hr_utility.set_message(800,'HR_ES_INVALID_CAC');
        hr_utility.raise_error;
    END IF;
END validate_cac;
--------------------------------------------------------------------------------
-- PROCEDURE unique_cac
--------------------------------------------------------------------------------
PROCEDURE unique_cac(p_org_info_id         NUMBER
                    ,p_context             VARCHAR2
                    ,p_org_info            VARCHAR2
                    ,p_business_group_id   NUMBER
                    ,p_effective_date      DATE) IS
CURSOR get_cac_wc IS
    SELECT 'x'
    FROM   hr_organization_information hoi,hr_all_organization_units hou
    WHERE  hoi.org_information_context = 'ES_WORK_CENTER_DETAILS'
    AND    hou.organization_id = hoi.organization_id
    AND    org_information1 = p_org_info
    AND    hou.business_group_id = p_business_group_id
    AND    (p_org_info_id IS NULL OR hoi.org_information_id <> p_org_info_id)
    AND    p_effective_date <= nvl(hou.date_to,to_Date('4712/12/31','YYYY/MM/DD'))
    AND exists (select 1 from hr_organization_information hoi1
                where hoi1.org_information1 = 'ES_WORK_CENTER'
                and   hoi1.org_information_context = 'CLASS'
                and   hoi1.organization_id = hoi.organization_id
                and   hoi1.org_information2 = 'Y');

CURSOR get_cac_statutory IS
    SELECT 'x'
    FROM   hr_organization_information hoi,hr_all_organization_units hou
    WHERE  hoi.org_information_context = 'ES_STATUTORY_INFO'
    AND    hou.organization_id = hoi.organization_id
    AND    org_information8 = p_org_info
    AND    hou.business_group_id = p_business_group_id
    AND    (p_org_info_id IS NULL OR hoi.org_information_id <> p_org_info_id)
    AND    p_effective_date <= nvl(hou.date_to,to_Date('4712/12/31','YYYY/MM/DD'))
    AND exists (select 1 from hr_organization_information hoi1
                where hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
                and   hoi1.org_information_context = 'CLASS'
                and   hoi1.organization_id = hoi.organization_id
                and   hoi1.org_information2 = 'Y');

l_check_cac      VARCHAR(1);
l_check_cac1     VARCHAR(1);
BEGIN
    --
    l_check_cac   := null;
    l_check_cac1  := null;
    --
    -- Bug 7508536
    -- Allow sharing of CAC numbers at the following levels -
    -- 1) Amongst Work Centres
    -- 2) Between Work Centre and Legal Employer.

    /*
    IF p_context in('ES_WORK_CENTER_DETAILS','ES_STATUTORY_INFO') THEN
        OPEN get_cac_wc;
        FETCH get_cac_wc INTO l_check_cac;
        CLOSE get_cac_wc;

        OPEN get_cac_statutory;
        FETCH get_cac_statutory INTO l_check_cac1;
        CLOSE get_cac_statutory;
    END IF;

    IF  l_check_cac = 'x' or l_check_cac1 = 'x' THEN
        hr_utility.set_message(800,'HR_ES_CAC_UNIQUE_ERROR');
        hr_utility.raise_error;
    END IF;
    */

    IF p_context in('ES_STATUTORY_INFO') THEN
        OPEN get_cac_statutory;
        FETCH get_cac_statutory INTO l_check_cac1;
        CLOSE get_cac_statutory;
    END IF;

    IF  l_check_cac1 = 'x' THEN
        hr_utility.set_message(800,'HR_ES_CAC_UNIQUE_ERROR');
        hr_utility.raise_error;
    END IF;

    --
END unique_cac;

--------------------------------------------------------------------------------
-- PROCEDURE unique_ss
--------------------------------------------------------------------------------
PROCEDURE unique_ss(p_org_info_id         NUMBER
                    ,p_context             VARCHAR2
                    ,p_org_info            VARCHAR2
                    ,p_business_group_id   NUMBER
                    ,p_effective_date      DATE) IS
CURSOR get_ss_code IS
    SELECT 'x'
    FROM   hr_organization_information hoi,hr_all_organization_units hou
    WHERE  hoi.org_information_context in('ES_SS_PROVINCE_DETAILS','ES_SS_OFFICE_DETAILS')
    AND    hou.organization_id = hoi.organization_id
    AND    org_information1 = p_org_info
    AND    hou.business_group_id = p_business_group_id
    AND    (p_org_info_id IS NULL OR hoi.org_information_id <> p_org_info_id)
    AND    p_effective_date <= nvl(hou.date_to,to_Date('4712/12/31','YYYY/MM/DD'))
    AND exists (select 1 from hr_organization_information hoi1
                where hoi1.org_information1 in( 'ES_SS_OFFICE_INFO','ES_SS_PROVINCE_INFO')
                and   hoi1.org_information_context = 'CLASS'
                and   hoi1.organization_id = hoi.organization_id
                and   hoi1.org_information2 = 'Y');

l_check_ss     VARCHAR(1);
BEGIN
    --
    l_check_ss := NULL;
    --
    IF p_context in('ES_SS_PROVINCE_DETAILS','ES_SS_OFFICE_DETAILS') THEN
        OPEN get_ss_code;
        FETCH get_ss_code INTO l_check_ss;
        CLOSE get_ss_code;
    END IF;

    IF l_check_ss = 'x' THEN
        hr_utility.set_message(800,'HR_ES_SS_UNIQUE_ERROR');
        hr_utility.raise_error;
    END IF;

END unique_ss;
--------------------------------------------------------------------------------
-- PROCEDURE unique_cif
--------------------------------------------------------------------------------
PROCEDURE unique_cif(p_org_info_id         NUMBER
                    ,p_org_info             VARCHAR2
                    ,p_business_group_id    NUMBER
                    ,p_effective_date       DATE) IS
CURSOR get_cif IS
    SELECT 'x'
    FROM   hr_organization_information hoi,hr_all_organization_units hou
    WHERE  hoi.org_information_context = 'ES_STATUTORY_INFO'
    AND    hou.organization_id = hoi.organization_id
    AND    org_information5 = p_org_info
    AND    hou.business_group_id = p_business_group_id
    AND    (p_org_info_id IS NULL OR hoi.org_information_id <> p_org_info_id)
    AND    p_effective_date <= nvl(hou.date_to,to_Date('4712/12/31','YYYY/MM/DD'))
    AND exists (select 1 from hr_organization_information hoi1
                where hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
                and   hoi1.org_information_context = 'CLASS'
                and   hoi1.organization_id = hoi.organization_id
                and   hoi1.org_information2 = 'Y');

l_check_cif     varchar(1):= NULL;
BEGIN
    OPEN get_cif;
    FETCH get_cif INTO l_check_cif;
    CLOSE get_cif;
    IF l_check_cif = 'x' THEN
        hr_utility.set_message(800,'HR_ES_CIF_UNIQUE_ERROR');
        hr_utility.raise_error;
    END IF;
END unique_cif;
--------------------------------------------------------------------------------
-- PROCEDURE validate_wc_sec_ref
--------------------------------------------------------------------------------
PROCEDURE validate_wc_sec_ref(p_context             VARCHAR2
                             ,p_org_information1    VARCHAR2
                             ,p_business_group_id   NUMBER
                             ,p_effective_date      DATE) IS


CURSOR csr_chk_wc_sec_ref IS
SELECT 'x'
FROM   hr_organization_information hoi
      ,hr_all_organization_units   hou
WHERE  hoi.org_information_context = p_context
AND    hoi.org_information1    = p_org_information1
AND    hoi.organization_id     = hou.organization_id
AND    hou.business_group_id   = p_business_group_id
AND    p_effective_date  <= NVL(hou.date_to,to_Date('4712/12/31','YYYY/MM/DD'));

l_check_ref     VARCHAR2(1);
BEGIN
    --
    l_check_ref  := null;
    --
    OPEN csr_chk_wc_sec_ref;
    FETCH csr_chk_wc_sec_ref into l_check_ref;
    CLOSE csr_chk_wc_sec_ref;

    IF l_check_ref = 'x' THEN
        IF p_context = 'ES_WORK_CENTER_REF' THEN
            hr_utility.set_message(800,'HR_ES_INVALID_REFERENCE');
            hr_utility.set_message_token(800,'VALUE'
                     ,hr_general.decode_lookup('ES_FORM_LABELS','WORK_CENTER'));
            hr_utility.raise_error;
        ELSIF p_context = 'ES_SECTION_REF' THEN
            hr_utility.set_message(800,'HR_ES_INVALID_REFERENCE');
            hr_utility.set_message_token(800,'VALUE'
                         ,hr_general.decode_lookup('ES_FORM_LABELS','SECTION'));
            hr_utility.raise_error;
        END IF;
    END IF;

END validate_wc_sec_ref;
--------------------------------------------------------------------------------
-- PROCEDURE check_leaving_reason
--------------------------------------------------------------------------------
PROCEDURE check_leaving_reason( p_leaving_reason         VARCHAR2
                               ,p_business_group_id      NUMBER ) IS
    --
    l_status varchar2(1);
BEGIN
    BEGIN
        SELECT 'Y'
        INTO   l_status
        FROM   sys.dual
        WHERE  exists(SELECT '1'
                      FROM   per_shared_types pp
                      WHERE  lookup_type = 'LEAV_REAS'
                      AND    system_type_cd = p_leaving_reason
                      AND    nvl(business_group_id,p_business_group_id)
                              = p_business_group_id
                      AND    information1 IS NOT NULL);
    --
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        hr_utility.set_message(800,'HR_ES_STAT_TERM_REASON_MISSING');
        hr_utility.set_warning;
    END;
END check_leaving_reason;
--------------------------------------------------------------------------------
-- FUNCTION check_SSI
--------------------------------------------------------------------------------
FUNCTION check_SSI(p_identifier_value VARCHAR2) RETURN VARCHAR2 AS

     v_province_code VARCHAR2(2);
         v_random_number VARCHAR2(8);
         v_check_digit VARCHAR2(2);
         n_check NUMBER(1);
BEGIN
    --
      IF (length(p_identifier_value) <> 12) THEN
        RETURN 'N';
      ELSIF (hr_ni_chk_pkg.chk_nat_id_format(p_identifier_value,'DDDDDDDDDDDD') <> p_identifier_value) THEN
        RETURN 'N';
      ELSE
            v_province_code := substr(p_identifier_value,1,2);
                --v_random_number := substr(p_identifier_value,3,8);
        --
                IF substr(p_identifier_value,3,1) <> '0' THEN
                    v_random_number := substr(p_identifier_value,3,8);
                ELSE
                    v_random_number := substr(p_identifier_value,4,7);
                END IF;
                --
                v_check_digit := substr(p_identifier_value,11,2);
                n_check := 0;
                --
                n_check := hr_es_utility.validate_cac_lookup(v_province_code);
                IF (n_check = 0) THEN
            RETURN 'N';
                ELSE
                    IF (mod(to_number(v_province_code || v_random_number),97) <> to_number(v_check_digit)) THEN
                        RETURN 'N';
                        END IF;
                END IF;
      END IF;
          RETURN 'Y';
END check_SSI;
--------------------------------------------------------------------------------
-- FUNCTION get_disability_degree
--------------------------------------------------------------------------------
FUNCTION get_disability_degree(p_person_id NUMBER, p_session_date DATE)
RETURN NUMBER IS
--

CURSOR c_disability(p_person_id NUMBER, p_session_date DATE) IS
SELECT degree
FROM   per_disabilities_f d
WHERE  d.person_id = p_person_id
AND    p_session_date BETWEEN d.effective_start_date
                      AND     d.effective_end_date;

n_disability_degree NUMBER;
--
BEGIN
--
  OPEN c_disability(p_person_id,p_session_date);
  FETCH c_disability INTO n_disability_degree;
  CLOSE c_disability;
  --
  RETURN n_disability_degree;
  --
END get_disability_degree;
--------------------------------------------------------------------------------
-- FUNCTION get_ssno
--------------------------------------------------------------------------------
FUNCTION get_ssno(p_assignment_id number
                 ,p_element_type_id number
                 ,p_input_value_id number
                 ,p_effective_date date) RETURN VARCHAR2 is

CURSOR get_screen_entry_value is
    select peevf.screen_entry_value
    from pay_element_entries_f peef
        ,pay_element_entry_values_f peevf
    where peef.assignment_id=p_assignment_id
    and   peef.element_type_id=p_element_type_id
    and   peevf.input_Value_id=p_input_value_id
    and   peevf.ELEMENT_ENTRY_ID=peef.element_entry_id
    and   p_effective_date between peef.effective_start_date and peef.effective_end_date
    and   p_effective_date between peevf.effective_start_date and peevf.effective_end_date;

l_entry_value   pay_element_entry_values.screen_entry_value%type;
BEGIN
OPEN get_screen_entry_value;
FETCH get_screen_entry_value INTO l_entry_value;
IF get_screen_entry_value%FOUND THEN
    RETURN l_entry_value;
ELSE
    RETURN NULL;
END IF;
END get_ssno;
--------------------------------------------------------------------------------
-- FUNCTION chk_entry_in_lookup
--------------------------------------------------------------------------------
FUNCTION chk_entry_in_lookup
                      (p_lookup_type    IN  hr_lookups.lookup_type%TYPE
                      ,p_entry_val      IN  hr_lookups.meaning%TYPE
                      ,p_effective_date IN  hr_lookups.start_date_active%TYPE
                      ,p_message        OUT NOCOPY VARCHAR2) RETURN VARCHAR2 AS
    --
    CURSOR c_entry_in_lookup IS
    SELECT 'X'
    FROM   hr_lookups hll
    WHERE  hll.lookup_type  = p_lookup_type
    AND    hll.lookup_code  = p_entry_val
    AND    hll.enabled_flag = 'Y'
    AND    p_effective_date BETWEEN NVL(hll.start_date_active, p_effective_date)
                             AND     NVL(hll.end_date_active, p_effective_date);

    l_found_value_in_lookup VARCHAR2(1);
    -- There is 255 character limit on the error screen
    l_msg                   VARCHAR2(255);
    --
BEGIN
    --
    l_msg := ' ';
    -- Check if the value exists in the lookup
    OPEN c_entry_in_lookup;
    FETCH c_entry_in_lookup INTO l_found_value_in_lookup;
        IF  c_entry_in_lookup%FOUND THEN
            l_found_value_in_lookup := 'Y';
        ELSE
            l_found_value_in_lookup := 'N';
        END IF;
    CLOSE c_entry_in_lookup;
    --
    IF  p_lookup_type = 'ES_CONTRACT_TYPE' THEN
        l_msg := fnd_message.get_string('PER','HR_ES_INVALID_CONTRACT_TYPE');
    ELSIF p_lookup_type = 'ES_CONTRACT_SUB_TYPE_UDT' THEN
        l_msg := fnd_message.get_string('PER','HR_ES_INVALID_CONTRACT_SUBTYPE');
    ELSIF p_lookup_type = 'ES_CONTRACT_STATUS' THEN
        l_msg := fnd_message.get_string('PER','HR_ES_INVALID_CONTRACT_STATUS');
    ELSIF p_lookup_type = 'ES_CONTRACT_START_REASON_UDT' THEN
        l_msg := fnd_message.get_string('PER','HR_ES_INVALID_CONTRACT_REASON');
    ELSE
        l_msg := 'You entered an invalid value. Please enter a valid value.';
    END IF;
    --
    -- Setup Out variables and Return statements
    p_message := l_msg;
    RETURN l_found_value_in_lookup;
    --
EXCEPTION
    WHEN OTHERS THEN
         IF  c_entry_in_lookup%ISOPEN THEN
             CLOSE c_entry_in_lookup;
         END IF;
END chk_entry_in_lookup;
--------------------------------------------------------------------------------
-- FUNCTION GET_MESSAGE
--------------------------------------------------------------------------------
FUNCTION get_message(p_product           IN VARCHAR2
                                      ,p_message_name      IN VARCHAR2
                                      ,p_token1            IN VARCHAR2 DEFAULT NULL
                    ,p_token2            IN VARCHAR2 DEFAULT NULL
                    ,p_token3            IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
   l_message varchar2(2000);
   l_token_name varchar2(20);
   l_token_value varchar2(80);
   l_colon_position number;
   --
BEGIN
   --
   fnd_message.set_name(p_product, p_message_name);

   IF p_token1 IS NOT NULL THEN
      /* Obtain token 1 name and value */
      l_colon_position := INSTR(p_token1,':');
      l_token_name  := SUBSTR(p_token1,1,l_colon_position-1);
      l_token_value := SUBSTR(p_token1,l_colon_position+1,LENGTH(p_token1));
      fnd_message.set_token(l_token_name, l_token_value);
      hr_utility.set_location('.  Token1: '||l_token_name||'. Value: '||l_token_value,50);
   END IF;

   IF p_token2 is not null  then
      /* Obtain token 2 name and value */
      l_colon_position := INSTR(p_token2,':');
      l_token_name  := SUBSTR(p_token2,1,l_colon_position-1);
      l_token_value := SUBSTR(p_token2,l_colon_position+1,LENGTH(p_token2));
      fnd_message.set_token(l_token_name, l_token_value);
      hr_utility.set_location('.  Token2: '||l_token_name||'. Value: '||l_token_value,60);
   END IF;

   IF p_token3 is not null then
      /* Obtain token 3 name and value */
      l_colon_position := INSTR(p_token3,':');
      l_token_name  := SUBSTR(p_token3,1,l_colon_position-1);
      l_token_value := SUBSTR(p_token3,l_colon_position+1,LENGTH(p_token3));
      fnd_message.set_token(l_token_name, l_token_value);
      hr_utility.set_location('.  Token3: '||l_token_name||'. Value: '||l_token_value,70);
   END IF;

   l_message := SUBSTRb(fnd_message.get,1,254);

   RETURN l_message;
END get_message;
--
--------------------------------------------------------------------------------
-- GET_TABLE_VALUE
--------------------------------------------------------------------------------
FUNCTION get_table_value(bus_group_id    IN NUMBER
                        ,peffective_date IN DATE
                        ,ptab_name       IN VARCHAR2
                        ,pcol_name       IN VARCHAR2
                        ,prow_value      IN VARCHAR2)RETURN NUMBER IS
    --
    l_ret pay_user_column_instances_f.value%type;
    --
BEGIN
    --
          BEGIN
        --
        hr_utility.trace('Inside get_table_value'||bus_group_id||' '||ptab_name||' '||pcol_name||' '||prow_value||' '||peffective_date);
        l_ret:= hruserdt.get_table_value(bus_group_id
                                        ,ptab_name
                                        ,pcol_name
                                        ,prow_value
                                        ,peffective_date);
        --
          EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    l_ret:='0';
          END;
        --
        hr_utility.trace('l_ret '||l_ret);
    RETURN to_number(l_ret);
    --
END get_table_value;
--
--------------------------------------------------------------------------------
-- GET_TABLE_VALUE_DATE
--------------------------------------------------------------------------------
FUNCTION get_table_value_date(bus_group_id    IN NUMBER
                            ,ptab_name       IN VARCHAR2
                            ,pcol_name       IN VARCHAR2
                            ,prow_value      IN VARCHAR2
                            ,peffective_date IN DATE)RETURN NUMBER IS
    --
    l_ret pay_user_column_instances_f.value%type;
    --
BEGIN
    --
          BEGIN
        --
        hr_utility.trace('Inside get_table_value'||bus_group_id||' '||ptab_name||' '||pcol_name||' '||prow_value||' '||peffective_date);
        l_ret:= hruserdt.get_table_value(bus_group_id
                                        ,ptab_name
                                        ,pcol_name
                                        ,prow_value
                                        ,peffective_date);
        --
          EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    l_ret:='0';
          END;
        --
        hr_utility.trace('l_ret '||l_ret);
    RETURN to_number(l_ret);
    --
END get_table_value_date;
--
--------------------------------------------------------------------------------
-- GET_TABLE_VALUE_CHAR
--------------------------------------------------------------------------------
FUNCTION get_table_value_char(bus_group_id    IN NUMBER
                             ,peffective_date IN DATE
                                             ,ptab_name       IN VARCHAR2
                                             ,pcol_name       IN VARCHAR2
                                               ,prow_value      IN VARCHAR2)RETURN VARCHAR2 IS
    --
    l_ret pay_user_column_instances_f.value%type;
    --
BEGIN
    --
          BEGIN
        --
        hr_utility.trace('Inside get_table_value_char'||bus_group_id||' '||ptab_name||' '||pcol_name||' '||prow_value||' '||peffective_date);
                    l_ret:= hruserdt.get_table_value(bus_group_id
                                                                        ,ptab_name
                                                                            ,pcol_name
                                                                            ,prow_value
                                        ,peffective_date);
        --
        hr_utility.trace('l_ret '||l_ret);
          EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    l_ret:='-1';
          END;
    --
    RETURN l_ret;
    --
END get_table_value_char;
-------------------------------------------------------------------------------
 -- Returns the description for a lookup code of a specified type.
 -------------------------------------------------------------------------------
 FUNCTION decode_lookup_desc (p_lookup_type   VARCHAR2
                             ,p_lookup_code   VARCHAR2) RETURN VARCHAR2 IS
 --
     CURSOR csr_lookup IS
     SELECT description
     FROM   hr_lookups
     WHERE  lookup_type     = p_lookup_type
     AND    lookup_code     = p_lookup_code;
     --
     v_desc       VARCHAR2(250);
     --
 BEGIN
 --
 -- Only open the cursor if the parameters are going to retrieve anything
 --
     IF  p_lookup_type IS NOT NULL AND p_lookup_code IS NOT NULL THEN
       --
       OPEN  csr_lookup;
       FETCH csr_lookup INTO v_desc;
       CLOSE csr_lookup;
       --
     END IF;
     --
     RETURN v_desc;
     --
 END decode_lookup_desc;
--

--------------------------------------------------------------------------------
-- Function added for IBAN Validation
--------------------------------------------------------------------------------


FUNCTION validate_iban_acc(p_account_no VARCHAR2)RETURN NUMBER IS

 l_iban_ret_val NUMBER;
BEGIN
     l_iban_ret_val := IBAN_VALIDATION_PKG.validate_iban_acc(p_account_no);
     hr_utility.set_location('IBAN_VALIDATION_PKG.validate_iban_acc(p_account_no) ' || l_iban_ret_val,99);
     return l_iban_ret_val;
END validate_iban_acc;

END hr_es_utility;

/
