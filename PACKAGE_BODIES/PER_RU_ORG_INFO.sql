--------------------------------------------------------
--  DDL for Package Body PER_RU_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RU_ORG_INFO" AS
/* $Header: peruorgp.pkb 120.1 2006/09/20 14:05:03 mgettins noship $ */
 PROCEDURE CREATE_RU_ORG_INFO(
         p_organization_id      NUMBER
        ,p_org_info_type_code   VARCHAR2
        ,p_org_information1     VARCHAR2
        ,p_org_information2     VARCHAR2
        ,p_org_information3     VARCHAR2
        ,p_org_information4     VARCHAR2
        ,p_org_information5     VARCHAR2
        ,p_org_information7     VARCHAR2
        ,p_org_information8     VARCHAR2
        ,p_org_information12    VARCHAR2
        ) is
     l_status NUMBER;
 BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
     --
	 IF p_org_info_type_code='RU_COMPANY_INFORMATION' THEN
	    l_status :=  hr_ru_utility.validate_tax_no(p_org_information2);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_ORG_INN');
	                 hr_utility.raise_error;
             END IF;
	    l_status :=  hr_ru_utility.validate_ogrn(p_org_information12);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_OGRN_NO');
	                 hr_utility.raise_error;
             END IF;
	    l_status :=  hr_ru_utility.validate_org_spifn(p_org_information4);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_PENSION_NO');
                         hr_utility.raise_error;
             END IF;
	    l_status :=  hr_ru_utility.validate_kpp(p_org_information3);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_KPP_NO');
	                 hr_utility.raise_error;
             END IF;
	    l_status :=  hr_ru_utility.validate_si(p_org_information5);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_SI_NO');
	                 hr_utility.raise_error;
             END IF;
	    l_status :=  hr_ru_utility.validate_okogu(p_org_information8);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_OKOGU_CODE');
	                 hr_utility.raise_error;
             END IF;
	    l_status :=  hr_ru_utility.validate_okpo(p_org_information7);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_OKPO_CODE');
	                 hr_utility.raise_error;
             END IF;
         ELSIF p_org_info_type_code = 'RU_COMPANY_ACTIVITY_TYPES' THEN
	    l_status :=  hr_ru_utility.validate_okved(p_org_information1);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_OKVED_CODE');
	                 hr_utility.raise_error;
             END IF;
	 END IF;
   END IF;
 END CREATE_RU_ORG_INFO;
 PROCEDURE UPDATE_RU_ORG_INFO(
                  p_org_information_id   NUMBER
                 ,p_org_info_type_code   VARCHAR2
                 ,p_org_information1     VARCHAR2
		         ,p_org_information2     VARCHAR2
			     ,p_org_information3     VARCHAR2
			     ,p_org_information4     VARCHAR2
			     ,p_org_information5     VARCHAR2
			     ,p_org_information7     VARCHAR2
			     ,p_org_information8     VARCHAR2
			     ,p_org_information12    VARCHAR2
                            ) is
  l_org_id number;
  l_status NUMBER;
  cursor csr_org_id is
	 select organization_id
	 from hr_organization_information
	 where org_information_id = p_org_information_id;
 BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'RU') THEN
     --
         OPEN csr_org_id;
         FETCH csr_org_id into l_org_id;
         CLOSE csr_org_id;
	 IF p_org_info_type_code='RU_COMPANY_INFORMATION' THEN
		 IF p_org_information2 <> hr_api.g_varchar2 THEN
	            l_status :=  hr_ru_utility.validate_tax_no(p_org_information2);
		    IF l_status = 0 THEN
				  hr_utility.set_message (800, 'HR_RU_INVALID_ORG_INN');
				  hr_utility.raise_error;
		     END IF;
       		 END IF;
		 IF p_org_information12 <> hr_api.g_varchar2
		     THEN
		    l_status :=  hr_ru_utility.validate_ogrn(p_org_information12);
		    IF l_status = 0 THEN
				  hr_utility.set_message (800, 'HR_RU_INVALID_OGRN_NO');
				  hr_utility.raise_error;
		     END IF;
		 END IF;
            IF p_org_information3 <> hr_api.g_varchar2 THEN
	    l_status :=  hr_ru_utility.validate_kpp(p_org_information3);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_KPP_NO');
	                 hr_utility.raise_error;
             END IF;
             END IF;
            IF p_org_information5 <> hr_api.g_varchar2 THEN
	    l_status :=  hr_ru_utility.validate_si(p_org_information5);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_SI_NO');
	                 hr_utility.raise_error;
             END IF;
             END IF;
            IF p_org_information8 <> hr_api.g_varchar2 THEN
	    l_status :=  hr_ru_utility.validate_okogu(p_org_information8);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_OKOGU_CODE');
	                 hr_utility.raise_error;
             END IF;
             END IF;
            IF p_org_information7 <> hr_api.g_varchar2 THEN
	    l_status :=  hr_ru_utility.validate_okpo(p_org_information7);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_OKPO_CODE');
	                 hr_utility.raise_error;
             END IF;
            END IF;
            IF p_org_information4 <> hr_api.g_varchar2 THEN
	    l_status :=  hr_ru_utility.validate_org_spifn(p_org_information4);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_PENSION_NO');
	                 hr_utility.raise_error;
             END IF;
             END IF;
         ELSIF p_org_info_type_code = 'RU_COMPANY_ACTIVITY_TYPES' THEN
            IF p_org_information1 <> hr_api.g_varchar2 THEN
	    l_status :=  hr_ru_utility.validate_okved(p_org_information1);
	    IF l_status = 0 THEN
	                 hr_utility.set_message (800, 'HR_RU_INVALID_OKVED_CODE');
	                 hr_utility.raise_error;
             END IF;
             END IF;
	 END IF;
   END IF;
 END UPDATE_RU_ORG_INFO;

END PER_RU_ORG_INFO;

/
