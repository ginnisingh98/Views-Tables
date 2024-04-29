--------------------------------------------------------
--  DDL for Package Body PER_FR_ORG_DDF_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_ORG_DDF_VALIDATION" AS
/* $Header: pefroriv.pkb 120.0.12000000.2 2007/02/28 10:40:22 spendhar ship $ */
--
g_package constant varchar2(30) := 'per_fr_org_ddf_validation';
--
PROCEDURE validate_fr_opm_mapping
  (p_org_information_id          IN NUMBER
  ,p_org_information_context     IN VARCHAR2
  ,p_organization_id             IN NUMBER
  ,p_org_information1            IN VARCHAR2
  ,p_org_information2            IN VARCHAR2)
IS
  l_proc varchar2(72) := g_package||'.validate_fr_opm_mapping';
  L_dummy number;
  Cursor csr_chk_specific_opm is
  select 1
  from hr_organization_information
  where ORG_INFORMATION_CONTEXT = 'FR_DYN_PAYMETH_MAPPING_INFO'
  and   ORG_INFORMATION1        = p_org_information1
  and   ORGANIZATION_ID        <> p_organization_id;
  --
  cursor csr_chk_generic_opm is
  select 1
  from hr_organization_information
  where ORG_INFORMATION_CONTEXT = 'FR_DYN_PAYMETH_MAPPING_INFO'
  and   ORG_INFORMATION2        = p_org_information2
  and   ORGANIZATION_ID         = p_organization_id
  and   org_information_id     <> p_org_information_id;
  --
BEGIN
  --
  /* Added for GSI Bug 5472781 */
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
     hr_utility.set_location('Leaving : '|| l_proc , 5);
     return;
  END IF;
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  if p_org_information_context = 'FR_DYN_PAYMETH_MAPPING_INFO' then
    hr_utility.set_location(l_proc,10);
    if hr_multi_message.no_exclusive_error
        (p_check_column1 => 'HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1')
    then
      -- No error for ORG_INFORMATION1 already exists so,
      -- prevent account-specific methods from being attached to more than
      -- one organization, but allow them to be registered more than once to
      -- the same organization.
      --
      Open csr_chk_specific_opm;
      Fetch csr_chk_specific_opm into L_dummy;
      If csr_chk_specific_opm%FOUND then
        Close csr_chk_specific_opm;
        fnd_message.set_name('PER', 'HR_75032_ORI_SPEC_OPM_EXISTS');
        hr_multi_message.add(p_associated_column1 =>
                             'HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1');
      else
        close csr_chk_specific_opm;
      end if;
    end if; -- check existing errors
    if hr_multi_message.no_exclusive_error
        (p_check_column1 => 'HR_ORGANIZATION_INFORMATION.ORG_INFORMATION2')
    then
      -- No error for ORG_INFORMATION2 already exists so,
      -- prevent account-independent methods from being attached to an
      -- organization more than once.
      --
      Open csr_chk_generic_opm;
      fetch csr_chk_generic_opm into l_dummy;
      if csr_chk_generic_opm%FOUND then
        close csr_chk_generic_opm;
        fnd_message.set_name('PER', 'HR_75033_ORI_GEN_OPM_EXISTS');
        hr_multi_message.add(p_associated_column1 =>
                             'HR_ORGANIZATION_INFORMATION.ORG_INFORMATION2');
      else
        close csr_chk_generic_opm;
      end if;
    end if; -- check existing errors
  end if; -- org_information_context = 'FR_DYN_PAYMETH_MAPPING_INFO'
  hr_utility.set_location(' Leaving: '||l_proc,99);
end validate_fr_opm_mapping;

PROCEDURE validate_fr_contrib_codes
  (p_org_information_id          IN NUMBER
  ,p_org_information_context     IN VARCHAR2
  ,p_organization_id             IN NUMBER
  ,p_org_information3            IN VARCHAR2
  ,p_org_information5            IN VARCHAR2)
IS
  l_proc 	varchar2(72) := g_package||'.validate_fr_contrib_codes';
  l_inv_code 	varchar2(1) := 'Y';
  l_type 	varchar2(10);
  Cursor c_ins_prov_type IS
   select nvl(ip.type, null)
   from hr_fr_insurance_providers_v ip
   where ip.organization_id = p_org_information3;
BEGIN
  --
  /* Added for GSI Bug 5472781 */
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
     hr_utility.set_location('Leaving : '|| l_proc , 01);
     return;
  END IF;
  --
  hr_utility.set_location(' Entering '||l_proc,01);
  if p_org_information_context = 'FR_COMP_CADRE_LIFE_INSURE' then
    hr_utility.set_location(' Validating contrib_codes '||p_org_information5,01);
    open c_ins_prov_type;
    fetch c_ins_prov_type into l_type;
    close c_ins_prov_type;

    if l_type = 'AGIRC' then
      if (substr(p_org_information5,1,1) = '3'
      and substr(p_org_information5,2,4) = 'XXXX'
      and substr(p_org_information5,6,1) between '0' and '9'
      and substr(p_org_information5,7,1) between '0' and '9'  ) then
        l_inv_code := 'N';
      end if;
    elsif l_type = 'ARRCO' then
      if (substr(p_org_information5,1,1) = '4'
      and substr(p_org_information5,2,4) = 'XXXX'
      and substr(p_org_information5,6,1) between '0' and '9'
      and substr(p_org_information5,7,1) between '0' and '9'  ) then
        l_inv_code := 'N';
      end if;
    else
      if not( substr(p_org_information5,1,1) between '1' and '4') then
        l_inv_code := 'N';
      end if;
    end if; -- org_information3 check
    if l_inv_code = 'Y' then
      fnd_message.set_name('PAY','PAY_74962_INVALID_CONTRIB_CODE');
      fnd_message.set_token('CONTRIB_CODE',p_org_information5);
      fnd_message.raise_error;
    end if; -- invalid code check
  end if;   -- org_information_context check
END validate_fr_contrib_codes;

end per_fr_org_ddf_validation;

/
