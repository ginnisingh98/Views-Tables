--------------------------------------------------------
--  DDL for Package Body PER_ES_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ES_ORG_INFO" AS
/* $Header: peesorgp.pkb 120.1.12010000.2 2008/12/16 11:44:03 parusia ship $ */

-----------------------------------------------------------------------------------------
-- PROCEDURE create_es_org_info
-----------------------------------------------------------------------------------------

PROCEDURE create_es_org_info(p_org_info_type_code   VARCHAR2
                            ,p_org_information1     VARCHAR2
                            ,p_org_information2     VARCHAR2
                            ,p_org_information3     VARCHAR2
                            ,p_org_information4     VARCHAR2
                            ,p_org_information5     VARCHAR2
                            ,p_org_information6     VARCHAR2
                            ,p_org_information7     VARCHAR2
                            ,p_org_information8     VARCHAR2
                            ,p_organization_id      NUMBER
                            ,p_effective_date       DATE
                            ) is
    CURSOR get_business_group is
    SELECT  business_group_id
    FROM    hr_all_organization_units
    WHERE   organization_id=p_organization_id;
    --
    CURSOR csr_chk_province_code(c_prov_code VARCHAR2) IS
    SELECT 'Y' FROM dual
    WHERE  EXISTS (SELECT /*+ ORDERED */ NULL from hr_lookups
                   WHERE LOOKUP_TYPE = 'ES_PROVINCE_CODES'
                   AND   LOOKUP_CODE = c_prov_code);
    --
    CURSOR csr_chk_contribution_ac_type(c_business_group_id NUMBER
                                       ,c_org_info1         VARCHAR2
                                       ,c_org_info2         VARCHAR2
                                       ,c_effective_date    DATE) IS
    SELECT 'Y'
    FROM   hr_organization_information hoi,hr_all_organization_units hou
    WHERE  hoi.org_information_context = 'ES_WORK_CENTER_DETAILS'
    AND    hou.organization_id = hoi.organization_id
    AND    org_information4 = c_org_info2
    AND    org_information1 <> c_org_info1
    AND    hou.business_group_id = c_business_group_id
    AND    c_effective_date <= nvl(hou.date_to,to_Date('4712/12/31','YYYY/MM/DD'))
    AND    EXISTS (SELECT 1 FROM hr_organization_information hoi1
                   WHERE hoi1.org_information1 = 'ES_WORK_CENTER'
                   AND   hoi1.org_information_context = 'CLASS'
                   AND   hoi1.organization_id = hoi.organization_id
                   AND   hoi1.org_information2 = 'Y');
    --
    l_code VARCHAR2(2);
    l_chk  VARCHAR2(1);

l_business_group_id     hr_all_organization_units.business_group_id%TYPE;
--
BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
     --
    OPEN get_business_group;
        FETCH get_business_group into l_business_group_id;
    CLOSE get_business_group;
    --
    IF  p_org_info_type_code='ES_STATUTORY_INFO' THEN
        hr_es_utility.validate_cif(p_org_information5);
        hr_es_utility.unique_cif(null,p_org_information5,l_business_group_id,p_effective_date);
        hr_es_utility.validate_cac(p_org_information8);
        hr_es_utility.unique_cac(null,p_org_info_type_code,p_org_information8,l_business_group_id,p_effective_date);
    END IF;
    --
    -- Bug 7508536
    -- 1) Allow sharing of CAC numbers at the following levels -
    --    a) Amongst Work Centres
    --    b) Between Work Centre and Legal Employer.
    IF  p_org_info_type_code = 'ES_WORK_CENTER_DETAILS' THEN
        hr_es_utility.validate_cac(p_org_information1);
        -- hr_es_utility.unique_cac(null,p_org_info_type_code,p_org_information1,l_business_group_id,p_effective_date);
        --
        --
        -- Bug 7508536
        -- 2) Allow sharing of Contribution Account Types
        /* l_chk := 'N';
        OPEN  csr_chk_contribution_ac_type(l_business_group_id,p_org_information1,p_org_information4,p_effective_date);
        FETCH csr_chk_contribution_ac_type into l_chk;
        CLOSE csr_chk_contribution_ac_type;
        --
        IF l_chk = 'Y' THEN
            hr_utility.set_message(800, 'HR_ES_CAT_UNIQUE_ERROR');
            hr_utility.raise_error;
        END IF;
        */
        --
    END IF;
    --
    -- Validation for Natural Disater dates
    --
    IF  p_org_info_type_code = 'ES_WC_NATURAL_DISASTER' THEN
       IF  (p_org_information1 IS NOT NULL) AND (p_org_information2 IS NOT NULL) THEN
            IF  fnd_date.canonical_to_date(p_org_information1) > fnd_date.canonical_to_date(p_org_information2) THEN
                hr_utility.set_message(800, 'HR_ES_NAT_DIS_DATE_VALIDATION');
                hr_utility.raise_error;
            END IF;
        END IF;
    END IF;
    --
    -- Validation for Natural Disater dates
    --
    IF  p_org_info_type_code = 'ES_WC_SHUTDOWN' THEN
       IF  (p_org_information1 IS NOT NULL) AND (p_org_information2 IS NOT NULL) THEN
            IF  fnd_date.canonical_to_date(p_org_information1) > fnd_date.canonical_to_date(p_org_information2) THEN
                hr_utility.set_message(800, 'HR_ES_SD_DATE_VALIDATION');
                hr_utility.raise_error;
            END IF;
        END IF;
    END IF;
    --
    -- Validation for Partial Unemployment dates
    --
    IF  p_org_info_type_code = 'ES_WC_PARTIAL_UNEMPLOYMENT' THEN
         IF  (p_org_information1 IS NOT NULL) AND (p_org_information2 IS NOT NULL) THEN
            IF  fnd_date.canonical_to_date(p_org_information1) > fnd_date.canonical_to_date(p_org_information2) THEN
                hr_utility.set_message(800, 'HR_ES_PAR_UE_DATE_VALIDATION');
                hr_utility.raise_error;
            END IF;
        END IF;
        IF (p_org_information5 = 'GROSS_PAY' ) AND (p_org_information6 IS NULL) THEN
            hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
            hr_utility.raise_error;
        END IF;
    END IF;
   --
   -- Validation for Contribution Exempt Situation dates
   --
    IF  p_org_info_type_code='ES_CONTRIB_EXEMPT' THEN
        IF  (p_org_information2 IS NOT NULL) AND (p_org_information3 IS NOT NULL) THEN
            IF  fnd_date.canonical_to_date(p_org_information2) > fnd_date.canonical_to_date(p_org_information3) THEN
                hr_utility.set_message(800, 'HR_ES_CON_EXMT_DATE_VALIDATION');
                hr_utility.raise_error;
            END IF;
        END IF;
    END IF;
    --
    -- Validation for Temporary Disability Management Deduction dates
    --
    IF  p_org_info_type_code='ES_TEMP_DISABILITY_MGT' THEN
        IF (p_org_information2 IS NOT NULL) AND (p_org_information3 IS NOT NULL) THEN
            IF  fnd_date.canonical_to_date(p_org_information2) > fnd_date.canonical_to_date(p_org_information3) THEN
                hr_utility.set_message(800, 'HR_ES_TEMP_DIS_DATE_VALIDATION');
                hr_utility.raise_error;
            END IF;
        END IF;
    END IF;
    --
    IF  p_org_info_type_code in('ES_WORK_CENTER_REF','ES_SECTION_REF') THEN
        hr_es_utility.validate_wc_sec_ref(p_org_info_type_code,p_org_information1,l_business_group_id,p_effective_date);
    END IF;

    IF  p_org_info_type_code in('ES_SS_PROVINCE_DETAILS','ES_SS_OFFICE_DETAILS') then
        hr_es_utility.unique_ss(null,p_org_info_type_code,p_org_information1,l_business_group_id,p_effective_date);
    END IF;
    --
    -- Validation for Benefit Uplift Formulas -- Employer level.
    --
    IF p_org_info_type_code = 'ES_BENEFIT_UPLIFT' THEN
        IF (p_org_information2 = 'GROSS_PAY' ) AND (p_org_information3 IS NULL) THEN
            hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
            hr_utility.raise_error;
        END IF;
        IF  (p_org_information5 IS NOT NULL) AND (p_org_information6 IS NOT NULL) THEN
             IF  fnd_date.canonical_to_date(p_org_information5) > fnd_date.canonical_to_date(p_org_information6) THEN
                 hr_utility.set_message(800, 'HR_ES_BU_DATE_VALIDATION');
                 hr_utility.raise_error;
             END IF;
        END IF;
    END IF;
    --
    -- Validation for Tax Office Code and Tax Administration Code.
    --
    IF p_org_info_type_code = 'ES_TAX_OFFICE_DETAILS' OR
       p_org_info_type_code = 'ES_TAX_ADMIN_DETAILS' THEN
        l_code := substr(p_org_information1,1,2);
        l_chk := 'N';
        --
        OPEN  csr_chk_province_code(l_code);
        FETCH csr_chk_province_code into l_chk;
        CLOSE csr_chk_province_code;
        --
        IF l_chk <> 'Y' THEN
            hr_utility.set_message(800, 'HR_ES_INVALID_TAX_CODE');
            hr_utility.raise_error;
        END IF;
    END IF;
    --
  END IF;
  --
END create_es_org_info;
-----------------------------------------------------------------------------------------
-- PROCEDURE update_es_org_info
-----------------------------------------------------------------------------------------

PROCEDURE update_es_org_info(p_org_info_type_code   VARCHAR2
                            ,p_org_information1     VARCHAR2
                            ,p_org_information2     VARCHAR2
                            ,p_org_information3     VARCHAR2
                            ,p_org_information4     VARCHAR2
                            ,p_org_information5     VARCHAR2
                            ,p_org_information6     VARCHAR2
                            ,p_org_information7     VARCHAR2
                            ,p_org_information8     VARCHAR2
                            ,p_org_information_id   NUMBER
                            ,p_effective_date       DATE
                            ) IS
    --
    CURSOR get_business_group is
    SELECT business_group_id
    FROM   hr_all_organization_units   hou
          ,hr_organization_information hoi
    WHERE  hoi.org_information_id      = p_org_information_id
    AND    hoi.organization_id         = hou.organization_id;
    --
    CURSOR csr_chk_province_code(c_prov_code VARCHAR2) IS
    SELECT 'Y' FROM dual
    WHERE  EXISTS (SELECT /*+ ORDERED */ NULL from hr_lookups
                   WHERE LOOKUP_TYPE = 'ES_PROVINCE_CODES'
                   AND   LOOKUP_CODE = c_prov_code);
    --
    CURSOR csr_chk_contribution_ac_type(c_business_group_id NUMBER
                                       ,c_org_info1         VARCHAR2
                                       ,c_org_info2         VARCHAR2
                                       ,c_effective_date    DATE) IS
    SELECT 'Y'
    FROM   hr_organization_information hoi,hr_all_organization_units hou
    WHERE  hoi.org_information_context = 'ES_WORK_CENTER_DETAILS'
    AND    hou.organization_id = hoi.organization_id
    AND    org_information4 = c_org_info2
    AND    org_information1 <> c_org_info1
    AND    hou.business_group_id = c_business_group_id
    AND    c_effective_date <= nvl(hou.date_to,to_Date('4712/12/31','YYYY/MM/DD'))
    AND    EXISTS (SELECT 1 FROM hr_organization_information hoi1
                   WHERE hoi1.org_information1 = 'ES_WORK_CENTER'
                   AND   hoi1.org_information_context = 'CLASS'
                   AND   hoi1.organization_id = hoi.organization_id
                   AND   hoi1.org_information2 = 'Y');
    --
    l_code VARCHAR2(2);
    l_chk  VARCHAR2(1);
    l_business_group_id     hr_all_organization_units.business_group_id%TYPE;
    --
BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
     --
    --
    OPEN get_business_group;
        FETCH get_business_group into l_business_group_id;
    CLOSE get_business_group;
    --
    IF  p_org_info_type_code = 'ES_STATUTORY_INFO' THEN
        IF  p_org_information5 IS NOT NULL THEN
            hr_es_utility.validate_cif(p_org_information5);
            hr_es_utility.unique_cif(p_org_information_id,p_org_information5,l_business_group_id,p_effective_date);
        END IF;
        IF  p_org_information8 IS NOT NULL THEN
            hr_es_utility.validate_cac(p_org_information8);
            hr_es_utility.unique_cac(p_org_information_id,p_org_info_type_code,p_org_information8,l_business_group_id,p_effective_date);
        END IF;
    END IF;
    IF  p_org_info_type_code = 'ES_WORK_CENTER_DETAILS' THEN
       -- Bug 7508536
       -- 1) Allow sharing of CAC numbers at the following levels -
       --    a) Amongst Work Centres
       --    b) Between Work Centre and Legal Employer.
        IF  p_org_information1 IS NOT NULL THEN
            hr_es_utility.validate_cac(p_org_information1);
            -- hr_es_utility.unique_cac(p_org_information_id,p_org_info_type_code,p_org_information1,l_business_group_id,p_effective_date);
        END IF;
        --
        -- Bug 7508536
        -- 2) Allow sharing of Contribution Account Types
        /*l_chk := 'N';
        OPEN  csr_chk_contribution_ac_type(l_business_group_id,p_org_information1,p_org_information4,p_effective_date);
        FETCH csr_chk_contribution_ac_type into l_chk;
        CLOSE csr_chk_contribution_ac_type;
        --
        IF l_chk = 'Y' THEN
            hr_utility.set_message(800, 'HR_ES_CAT_UNIQUE_ERROR');
            hr_utility.raise_error;
        END IF;
        */
        --
    END IF;
    --
    -- Validation for Natural Disater dates
    --
    IF  p_org_info_type_code = 'ES_WC_NATURAL_DISASTER' THEN
       IF  (p_org_information1 IS NOT NULL) AND (p_org_information2 IS NOT NULL) THEN
            IF  fnd_date.canonical_to_date(p_org_information1) > fnd_date.canonical_to_date(p_org_information2) THEN
                hr_utility.set_message(800, 'HR_ES_NAT_DIS_DATE_VALIDATION');
                hr_utility.raise_error;
            END IF;
        END IF;
    END IF;
    --
    -- Validation for Natural Disater dates
    --
    IF  p_org_info_type_code = 'ES_WC_SHUTDOWN' THEN
       IF  (p_org_information1 IS NOT NULL) AND (p_org_information2 IS NOT NULL) THEN
            IF  fnd_date.canonical_to_date(p_org_information1) > fnd_date.canonical_to_date(p_org_information2) THEN
                hr_utility.set_message(800, 'HR_ES_SD_DATE_VALIDATION');
                hr_utility.raise_error;
            END IF;
        END IF;
    END IF;
    --
    -- Validation for Partial Unemployment dates
    --
    IF  p_org_info_type_code = 'ES_WC_PARTIAL_UNEMPLOYMENT' THEN
         IF  (p_org_information1 IS NOT NULL) AND (p_org_information2 IS NOT NULL) THEN
            IF  fnd_date.canonical_to_date(p_org_information1) > fnd_date.canonical_to_date(p_org_information2) THEN
                hr_utility.set_message(800, 'HR_ES_PAR_UE_DATE_VALIDATION');
                hr_utility.raise_error;
            END IF;
        END IF;
        IF (p_org_information5 = 'GROSS_PAY' ) AND (p_org_information6 IS NULL) THEN
            hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
            hr_utility.raise_error;
        END IF;
    END IF;
    --
    -- Validation for Contribution Exempt Situation dates
    --
    IF  p_org_info_type_code = 'ES_CONTRIB_EXEMPT' THEN
        IF  (p_org_information2 IS NOT NULL) AND (p_org_information3 IS NOT NULL) THEN
            IF  fnd_date.canonical_to_date(p_org_information2) > fnd_date.canonical_to_date(p_org_information3) THEN
                hr_utility.set_message(800, 'HR_ES_CON_EXMT_DATE_VALIDATION');
                hr_utility.raise_error;
            END IF;
         END IF;
    END IF;
    --
    -- Validation for Temporary Disability Management Deduction dates
    --
    IF  p_org_info_type_code='ES_TEMP_DISABILITY_MGT' THEN
        IF  (p_org_information2 IS NOT NULL) AND (p_org_information3 IS NOT NULL) THEN
             IF  fnd_date.canonical_to_date(p_org_information2) > fnd_date.canonical_to_date(p_org_information3) THEN
                 hr_utility.set_message(800, 'HR_ES_TEMP_DIS_DATE_VALIDATION');
                 hr_utility.raise_error;
             END IF;
        END IF;
    END IF;
    --
    IF p_org_info_type_code in('ES_WORK_CENTER_REF','ES_SECTION_REF') THEN
        hr_es_utility.validate_wc_sec_ref(p_org_info_type_code,p_org_information1,l_business_group_id,p_effective_date);
    END IF;
    --
    IF p_org_info_type_code in('ES_SS_PROVINCE_DETAILS','ES_SS_OFFICE_DETAILS') then
        hr_es_utility.unique_ss(p_org_information_id,p_org_info_type_code,p_org_information1,l_business_group_id,p_effective_date);
    END IF;
    --
    -- Validation for Benefit Uplift Formulas -- Employer level.
    --
    IF p_org_info_type_code = 'ES_BENEFIT_UPLIFT' THEN
        IF (p_org_information2 = 'GROSS_PAY' ) AND (p_org_information3 IS NULL) THEN
            hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
            hr_utility.raise_error;
        END IF;
        IF  (p_org_information5 IS NOT NULL) AND (p_org_information6 IS NOT NULL) THEN
             IF  fnd_date.canonical_to_date(p_org_information5) > fnd_date.canonical_to_date(p_org_information6) THEN
                 hr_utility.set_message(800, 'HR_ES_BU_DATE_VALIDATION');
                 hr_utility.raise_error;
             END IF;
        END IF;
    END IF;
        --
    -- Validation for Tax Office Code and Tax Administration Code.
    --
    IF p_org_info_type_code = 'ES_TAX_OFFICE_DETAILS' OR
       p_org_info_type_code = 'ES_TAX_ADMIN_DETAILS' THEN
        l_code := substr(p_org_information1,1,2);
        l_chk := 'N';
        --
        OPEN  csr_chk_province_code(l_code);
        FETCH csr_chk_province_code into l_chk;
        CLOSE csr_chk_province_code;
        --
        IF l_chk <> 'Y' THEN
            hr_utility.set_message(800, 'HR_ES_INVALID_TAX_CODE');
            hr_utility.raise_error;
        END IF;
    END IF;
    --
  END IF;
  --
END update_es_org_info;

END per_es_org_info;

/
