--------------------------------------------------------
--  DDL for Package Body PER_HU_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HU_ORG_INFO" AS
/* $Header: pehuorgp.pkb 120.1 2006/09/21 08:51:52 mgettins noship $ */

PROCEDURE CREATE_HU_ORG_INFO(p_org_info_type_code   VARCHAR2
                            ,p_org_information3     VARCHAR2
                            ,p_org_information4     VARCHAR2
                            ,p_org_information5     VARCHAR2
                            ) is
l_check     NUMBER;
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'HU') THEN
    --
    IF p_org_info_type_code='HU_COMPANY_INFORMATION_DETAILS' THEN
      hr_hu_utility.validate_ss_no(p_org_information3);
      hr_hu_utility.validate_tax_no(p_org_information4);
      hr_hu_utility.validate_cs_no(p_org_information4,p_org_information5);
    END IF;
	--
  END IF;

END CREATE_HU_ORG_INFO;
-------------------------

PROCEDURE UPDATE_HU_ORG_INFO(p_org_information_id   NUMBER
                            ,p_org_info_type_code   VARCHAR2
                            ,p_org_information3     VARCHAR2
                            ,p_org_information4     VARCHAR2
                            ,p_org_information5     VARCHAR2
                            ) is

CURSOR get_information4 (p_org_information_id NUMBER) is
    SELECT org_information4 from hr_organization_information
    where ORG_INFORMATION_CONTEXT='HU_COMPANY_INFORMATION_DETAILS'
    and org_information_id= p_org_information_id;

CURSOR get_information5 (p_org_information_id NUMBER) is
    SELECT org_information5 from hr_organization_information
    where ORG_INFORMATION_CONTEXT='HU_COMPANY_INFORMATION_DETAILS'
    and org_information_id= p_org_information_id;

l_check         NUMBER;
l_information5  hr_organization_information.org_information5%TYPE;
l_information4  hr_organization_information.org_information4%TYPE;
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'HU') THEN
    --
    IF p_org_info_type_code = 'HU_COMPANY_INFORMATION_DETAILS' THEN

        IF p_org_information3 <> hr_api.g_varchar2 THEN
            hr_hu_utility.validate_ss_no(p_org_information3);
        END IF;

        IF p_org_information4 <> hr_api.g_varchar2 and p_org_information5 = hr_api.g_varchar2 THEN
            hr_hu_utility.validate_tax_no(p_org_information4);
            OPEN get_information5(p_org_information_id);
            FETCH get_information5 INTO l_information5;
            CLOSE get_information5;
            hr_hu_utility.validate_cs_no(p_org_information4,l_information5);

        END IF;

        IF p_org_information5 <> hr_api.g_varchar2 and p_org_information4 = hr_api.g_varchar2 THEN
            OPEN get_information4(p_org_information_id);
            FETCH get_information4 INTO l_information4;
            CLOSE get_information4;
            hr_hu_utility.validate_cs_no(l_information4,p_org_information5);
        END IF;

        IF p_org_information5 <> hr_api.g_varchar2 and p_org_information4 <> hr_api.g_varchar2 THEN
            hr_hu_utility.validate_tax_no(p_org_information4);
            hr_hu_utility.validate_cs_no(p_org_information4,p_org_information5);
        END IF;
    END IF;
	--
  END IF;
END UPDATE_HU_ORG_INFO;

-------------------------

END PER_HU_ORG_INFO;

/
