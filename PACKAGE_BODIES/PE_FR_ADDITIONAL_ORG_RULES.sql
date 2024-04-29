--------------------------------------------------------
--  DDL for Package Body PE_FR_ADDITIONAL_ORG_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_FR_ADDITIONAL_ORG_RULES" AS
/* $Header: pefrorgh.pkb 120.3.12000000.2 2007/02/28 10:38:42 spendhar ship $ */
g_package  varchar2(80) := 'pe_fr_additional_org_rules';

PROCEDURE fr_validate_org_info_ins
  (p_effective_date                 IN  DATE
  ,p_organization_id                IN  NUMBER
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2
  ,p_org_information2               IN  VARCHAR2
  ,p_org_information3               IN  VARCHAR2
  ,p_org_information4               IN  VARCHAR2
  ,p_org_information5               IN  VARCHAR2
  ,p_org_information6               IN  VARCHAR2
  ,p_org_information7               IN  VARCHAR2
  ,p_org_information8               IN  VARCHAR2
  ,p_org_information9               IN  VARCHAR2
  ,p_org_information10              IN  VARCHAR2
  ,p_org_information11              IN  VARCHAR2
  ,p_org_information12              IN  VARCHAR2
  ,p_org_information13              IN  VARCHAR2
  ,p_org_information14              IN  VARCHAR2
  ,p_org_information15              IN  VARCHAR2
  ,p_org_information16              IN  VARCHAR2
  ,p_org_information17              IN  VARCHAR2
  ,p_org_information18              IN  VARCHAR2
  ,p_org_information19              IN  VARCHAR2
  ,p_org_information20              IN  VARCHAR2
  ) IS
  l_proc varchar2(72) := g_package || '.fr_validate_org_info_ins';
  Begin
  --
  /* Added for GSI Bug 5472781 */
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
     hr_utility.set_location('Leaving : '||l_proc , 10);
     return;
  END IF;
  --
  hr_utility.set_location('Entering  '|| l_proc , 10);
  pe_fr_additional_org_rules.fr_validate_org_info(
   p_effective_date                 => p_effective_date
  ,p_org_info_type_code             => p_org_info_type_code
  ,p_organization_id                => p_organization_id
  ,p_org_information1               => p_org_information1
  ,p_org_information2               => p_org_information2
  ,p_org_information3               => p_org_information3
  ,p_org_information4               => p_org_information4
  ,p_org_information5               => p_org_information5);
   --
  hr_utility.set_location('Leaving '||l_proc,800);
  --
END fr_validate_org_info_ins;

 PROCEDURE fr_validate_org_info_upd
  (p_effective_date                 IN  DATE
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2
  ,p_org_information2               IN  VARCHAR2
  ,p_org_information3               IN  VARCHAR2
  ,p_org_information4               IN  VARCHAR2
  ,p_org_information5               IN  VARCHAR2
  ,p_org_information6               IN  VARCHAR2
  ,p_org_information7               IN  VARCHAR2
  ,p_org_information8               IN  VARCHAR2
  ,p_org_information9               IN  VARCHAR2
  ,p_org_information10              IN  VARCHAR2
  ,p_org_information11              IN  VARCHAR2
  ,p_org_information12              IN  VARCHAR2
  ,p_org_information13              IN  VARCHAR2
  ,p_org_information14              IN  VARCHAR2
  ,p_org_information15              IN  VARCHAR2
  ,p_org_information16              IN  VARCHAR2
  ,p_org_information17              IN  VARCHAR2
  ,p_org_information18              IN  VARCHAR2
  ,p_org_information19              IN  VARCHAR2
  ,p_org_information20              IN  VARCHAR2
  ,p_org_information_id             IN  NUMBER
  ,p_object_version_number          IN  NUMBER
  ) IS
  l_proc varchar2(72) := g_package || '.fr_validate_org_info_upd';
BEGIN
  --
  /* Added for GSI Bug 5472781 */
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
     hr_utility.set_location('Leaving : '||l_proc , 10);
     return;
  END IF;
  --
  hr_utility.set_location('Entering  '||l_proc , 10);

  pe_fr_additional_org_rules.fr_validate_org_info(
   p_effective_date                 => p_effective_date
  ,p_org_info_type_code             => p_org_info_type_code
  ,p_org_information1               => p_org_information1
  ,p_org_information2               => p_org_information2
  ,p_org_information3               => p_org_information3
  ,p_org_information4               => p_org_information4
  ,p_org_information5               => p_org_information5
  ,p_org_information_id             => p_org_information_id
  ,p_object_version_number          => p_object_version_number);

  hr_utility.set_location('Leaving '||l_proc,800);
  --
END fr_validate_org_info_upd;

PROCEDURE fr_validate_org_info
  (p_effective_date                 IN  DATE
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2
  ,p_org_information2               IN  VARCHAR2
  ,p_org_information3               IN  VARCHAR2
  ,p_org_information4               IN  VARCHAR2
  ,p_org_information5               IN  VARCHAR2
  ,p_organization_id                IN  NUMBER default null   /* ins only */
  ,p_org_information_id             IN  NUMBER default null   /* upd only */
  ,p_object_version_number          IN  NUMBER default null   /* upd only */
  )
IS
  cursor csr_get_org_id (p_org_information_id number) is
  select organization_id
  from   hr_organization_information
  where  org_information_id = p_org_information_id;

  cursor csr_wa_check(
     p_context     varchar2
    ,p_org_id      hr_organization_information.organization_id%TYPE
    ,p_org_info_id hr_organization_information.org_information_id%TYPE
    ,p_wa_type     hr_organization_information.org_information4%TYPE
    ,p_wa_order    hr_organization_information.org_information5%TYPE) is
  select null
  from   hr_organization_information
  where  org_information_context =  p_context
  and    organization_id = p_org_id
  and    org_information_id <> nvl(p_org_info_id, -1)
  and    org_information3 = p_wa_type
  and    org_information5 <> p_wa_order;

  cursor csr_chk_overlaps(
      p_context     varchar2
     ,p_org_id      hr_organization_information.organization_id%TYPE
     ,p_org_info_id hr_organization_information.org_information_id%TYPE
     ,p_org_info1   hr_organization_information.org_information1%TYPE
     ,p_org_info2   hr_organization_information.org_information2%TYPE
     ,p_org_info3   hr_organization_information.org_information3%TYPE
     ,p_sot         varchar2
     ,p_eot         varchar2) is
  select 'Y'
  from   hr_organization_information
  where  org_information_context = p_context
  and    organization_id         = p_org_id
  and    org_information_id     <> nvl(p_org_info_id, -1)
  and    p_org_info2            >= nvl(org_information1,p_sot)
  and    p_org_info1            <= nvl(org_information2,p_eot)
  and   (p_org_info3            is null or
         p_org_info3             = nvl(org_information3,'NULL_CONTEXTUAL_SEG'))
  and    rownum                  < 2;

  l_proc           varchar2(72) := g_package || '.fr_validate_org_info';
  l_sot            varchar2(30);
  l_eot            varchar2(30);
  l_org_id         hr_organization_information.organization_id%TYPE;
  l_org_info3      hr_organization_information.org_information3%TYPE;
  l_overlap        varchar2(1);

BEGIN
  --
  hr_utility.set_location('Entering  '||l_proc , 10);
  --
  if p_org_info_type_code in ('FR_COMP_ACCRUAL_RATE'
     ,'FR_COMP_CADRE_LIFE_INSURE'
     ,'FR_COMP_COMP_PENSION_T2'
     ,'FR_COMP_TRAINING_CONTRIB'
     ,'FR_ESTAB_ACCRUAL_RATE'
     ,'FR_ESTAB_APPRENT_TAX_LIABILITY'
     ,'FR_ESTAB_OVERRIDE_FIXED_TERM'
     ,'FR_ESTAB_PART_TIME_REBATE'
     ,'FR_ESTAB_ROBIEN'
     ,'FR_ESTAB_SALARY_TAX_LIABILITY'
     ,'FR_ESTAB_SS_REBATE'
     ,'FR_ESTAB_TRANSPORT_TAX'
     ,'FR_ESTAB_WELFARE_TAX_LIABILITY'
     ,'FR_ESTAB_WORK_ACCIDENT'
     ,'FR_HISTORICAL_MONTHLY_REF_HRS'
     ,'FR_ESTAB_AUBRY_II'
     ,'FR_ESTAB_CONSTR_TAX_LIABILITY') THEN
     --
     -- derive values of variables
     --
     l_sot := fnd_date.date_to_canonical(hr_general.START_OF_TIME);
     l_eot := fnd_date.date_to_canonical(hr_general.END_OF_TIME);
     --
     -- check date_from > date_to
     --
     IF    p_org_information1 > p_org_information2
     THEN
           fnd_message.set_name('PER','PER_289697_START_BEFORE_END');
           fnd_message.raise_error;
     END IF;
     --
     -- Get the organization_id if update
     --
     IF   p_org_information_id is not null
     THEN
          open csr_get_org_id (p_org_information_id);
          fetch csr_get_org_id into l_org_id;
          close csr_get_org_id;
     ELSE
          l_org_id := p_organization_id;
     END IF;
     --
     -- check for overlaps
     --
     IF   p_org_info_type_code = 'FR_ESTAB_TRANSPORT_TAX'
     THEN
          l_org_info3 := p_org_information3;
     ELSIF p_org_info_type_code = 'FR_ESTAB_WORK_ACCIDENT'
     THEN
          l_org_info3 := nvl(p_org_information3,'NULL_CONTEXTUAL_SEG');
     END IF;
     open csr_chk_overlaps(p_org_info_type_code,l_org_id,
                           p_org_information_id,
                           nvl(p_org_information1,l_sot),
                           nvl(p_org_information2,l_eot),
                           l_org_info3, l_sot, l_eot);
     fetch csr_chk_overlaps into l_overlap;
     if csr_chk_overlaps%FOUND then
        IF    p_org_info_type_code = 'FR_ESTAB_TRANSPORT_TAX'
        THEN  fnd_message.set_name('PAY','PER_75066_TSPORT_TAX_OVERLAP');
        ELSIF p_org_info_type_code = 'FR_ESTAB_WORK_ACCIDENT'
        THEN  fnd_message.set_name('PAY','PER_75067_WORK_ACCI_OVERLAP');
        ELSE  fnd_message.set_name('PAY','PER_75068_START_END_OVERLAP');
        END IF;
        close csr_chk_overlaps;
        fnd_message.raise_error;
     END IF; -- if csr_chk_overlaps%FOUND
     close csr_chk_overlaps;
  END IF; -- p_org_info_type_code in ...
  hr_utility.set_location('Leaving '||l_proc,800);
  --
END fr_validate_org_info;
END pe_fr_additional_org_rules;

/
