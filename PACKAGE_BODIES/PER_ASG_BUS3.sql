--------------------------------------------------------
--  DDL for Package Body PER_ASG_BUS3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASG_BUS3" as
/* $Header: peasgrhi.pkb 120.19.12010000.7 2009/11/20 09:42:17 sidsaxen ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  per_asg_bus3.';  -- Global package name
g_debug    boolean := hr_utility.debug_enabled;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_cagr_grade_def_id  >---------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_cagr_grade_def_id
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date          in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  ,p_cagr_grade_def_id       in per_all_assignments_f.cagr_grade_def_id%TYPE
  ,p_collective_agreement_id in per_all_assignments_f.collective_agreement_id%TYPE
  ,p_cagr_id_flex_num        in per_all_assignments_f.cagr_id_flex_num%TYPE
  )
is
--
  l_proc                    varchar2(72) := g_package||'chk_cagr_grade_def_id';
  l_api_updating            boolean;
  l_exists                  varchar2(1);
  l_dynamic_insert_allowed  varchar2(1);
  l_cagr_grade_structure_id number;
  --
  cursor csr_in_per_cagr_grades_def is
     select   null
     from     per_cagr_grades_def pcg
     where    pcg.id_flex_num = p_cagr_id_flex_num
     and      pcg.cagr_grade_def_id = p_cagr_grade_def_id;
  --
  cursor csr_in_cagr_grade_structs is
     select   dynamic_insert_allowed, cagr_grade_structure_id
     from     per_cagr_grade_structures cgs
     where    cgs.id_flex_num = p_cagr_id_flex_num
     and      cgs.collective_agreement_id = p_collective_agreement_id;
  --
  cursor csr_in_cagr_grades is
     select   null
     from     per_cagr_grades pcg
     where    pcg.cagr_grade_def_id = p_cagr_grade_def_id
     and      pcg.cagr_grade_structure_id = l_cagr_grade_structure_id;
  --
begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 --
 if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.CAGR_ID_FLEX_NUM'
       ,p_check_column2      => 'PER_ALL_ASSIGNMENTS_F.COLLECTIVE_AGREEMENT_ID'
       ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  If p_cagr_id_flex_num is null and p_cagr_grade_def_id is not null THEN
    -- Error, must have id_flex_num
     -- msg There must be a collective_agreement grade structure specified with a collective agreement grade definition
      hr_utility.set_location(l_proc, 50);
      hr_utility.set_message(800, 'PER_52806_CAGR_STRUCT_GRADE');
      hr_utility.raise_error;
  End if;
  --
  -- Only proceed with validation if :
  -- a) The cagr_id_flex_num is changing
  -- b) The grade_def_id is changing or new
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating
     and (p_cagr_grade_def_id is not null)
     and  nvl(per_asg_shd.g_old_rec.cagr_id_flex_num, hr_api.g_number)
       <> nvl(p_cagr_id_flex_num, hr_api.g_number))
    or
      (NOT l_api_updating and p_cagr_grade_def_id is not null)
    or
      (l_api_updating and (p_cagr_grade_def_id is not null) and
       nvl(per_asg_shd.g_old_rec.cagr_grade_def_id, hr_api.g_number)
       <> nvl(p_cagr_grade_def_id, hr_api.g_number)))     THEN
    --
    hr_utility.set_location(l_proc, 40);
    --
    --
    --It must be in per_cagr_grades_def
    --
    Open csr_in_per_cagr_grades_def;
    Fetch csr_in_per_cagr_grades_def into l_exists;
    if csr_in_per_cagr_grades_def%notfound then
      close csr_in_per_cagr_grades_def;
      -- msg The given grade definition does not exist for the grade structure
      hr_utility.set_location(l_proc, 50);
      hr_utility.set_message(800, 'PER_52807_GRADE_NOT_STRUCT');
      hr_utility.raise_error;
    Else
      close csr_in_per_cagr_grades_def;
    End If;
    -- It must exist in per_cagr_grade_structures
    Open csr_in_cagr_grade_structs;
    Fetch csr_in_cagr_grade_structs Into l_dynamic_insert_allowed,
                                         l_cagr_grade_structure_id;
    If csr_in_cagr_grade_structs%notfound then
      --
      -- The combination is invalid
      Close csr_in_cagr_grade_structs;
      hr_utility.set_location(l_proc, 60);
      -- msg This grade structure / collective agreement comb does not exist
      hr_utility.set_message(800, 'PER_52808_INVALID_CAGR_GRADE');
      hr_utility.raise_error;
    Else
      Close csr_in_cagr_grade_structs;
      --
      If l_dynamic_insert_allowed = 'N' THEN
        -- Check that the grade id is a reference grade.
        Open csr_in_cagr_grades;
        Fetch csr_in_cagr_grades into l_exists;
        If csr_in_cagr_grades%notfound THEN
          -- msg This grade structure only allows selection of reference grades, you cannot create grades.
          hr_utility.set_message(800, 'PER_52809_CAGR_ONLY_SELECT');
          hr_utility.raise_error;
        Else
          Close csr_in_cagr_grades;
   End If;
      End If;
    End if;
  End if;
  End If;
hr_utility.set_location(' Leaving:'|| l_proc, 90);
end chk_cagr_grade_def_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_cagr_id_flex_num  >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_cagr_id_flex_num
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date          in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  ,p_cagr_id_flex_num        in per_all_assignments_f.cagr_id_flex_num%TYPE
  ,p_collective_agreement_id in per_all_assignments_f.collective_agreement_id%TYPE
  ) is
--
  l_proc                   varchar2(72)  :=  g_package||'chk_cagr_id_flex_num';
  l_api_updating           boolean;
  l_exists                 varchar2(1);
  l_business_group_id      number;
  l_collective_agreement_id number;
  --
  cursor csr_in_fnd_id_flex is
     select   null
     from     fnd_id_flex_structures fnd
     where    fnd.id_flex_code = 'CAGR';
  --
  cursor csr_in_cagr_grade_structs is
     select   null
     from     per_cagr_grade_structures cgs
     where    cgs.id_flex_num = p_cagr_id_flex_num
     and      cgs.collective_agreement_id = p_collective_agreement_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.COLLECTIVE_AGREEMENT_ID'
       ) then
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The id_flex_num is changing or new
  -- b) The value for collective_agreement_id is changing and id_flex_num is present
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and (p_cagr_id_flex_num is not null) and
       nvl(per_asg_shd.g_old_rec.cagr_id_flex_num, hr_api.g_number)
       <> nvl(p_cagr_id_flex_num, hr_api.g_number))
    or
      (NOT l_api_updating and p_cagr_id_flex_num is not null)
    or
      (l_api_updating and (p_cagr_id_flex_num is not null) and
       nvl(per_asg_shd.g_old_rec.collective_agreement_id, hr_api.g_number)
       <> nvl(p_collective_agreement_id, hr_api.g_number)))     THEN
    --
    hr_utility.set_location(l_proc, 40);
    --
    --
    If p_cagr_id_flex_num is not null and p_collective_agreement_id is null THEN
      -- msg There must be a collective agreement specified if a grade structure is specified
      hr_utility.set_location(l_proc, 50);
      hr_utility.set_message(800, 'PER_52806_CAGR_STRUCT_GRADE');
      hr_utility.raise_error;
    Else
      -- It must exist on fnd_id_flex_structures (It cannot be null here)
      Open csr_in_fnd_id_flex;
      Fetch csr_in_fnd_id_flex Into l_exists;
      If csr_in_fnd_id_flex%notfound then
      --
      -- The id_flex_num must exist, so error
      --
        Close csr_in_fnd_id_flex;
        hr_utility.set_location(l_proc, 60);
        -- msg This grade structure does not exist
        hr_utility.set_message(800, 'PER_52810_INVALID_STRUCTURE');
        hr_multi_message.add;
      Else
        Close csr_in_fnd_id_flex;
        --
        -- If there is a collective_agreement_id it must be on per_cagr_grade_structures
        If p_collective_agreement_id is not null THEN
          Open csr_in_cagr_grade_structs;
          fetch csr_in_cagr_grade_structs into l_exists;
          If csr_in_cagr_grade_structs%notfound then
            --
            -- The id_flex_num must exist here, so error
            --
            Close csr_in_cagr_grade_structs;
            hr_utility.set_location(l_proc, 70);
            -- msg This grade structure / id flex num combination is invalid
            hr_utility.set_message(800, 'PER_52808_INVALID_CAGR_GRADE');
            hr_utility.raise_error;
          Else
            Close csr_in_cagr_grade_structs;
          End if;
        End if;
      End if;
    End if;
  End if;
  End if;
hr_utility.set_location(' Leaving:'|| l_proc, 90);
end chk_cagr_id_flex_num;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_contract_id >----------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_contract_id
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date          in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  ,p_contract_id             in per_all_assignments_f.contract_id%TYPE
  ,p_person_id               in per_all_assignments_f.person_id%TYPE
  ,p_validation_start_date   in date
  ,p_business_group_id       in per_all_assignments_f.business_group_id%TYPE
  ) is
--
  l_proc                   varchar2(72)  :=  g_package||'chk_contract_id';
  l_api_updating           boolean;
  l_business_group_id      number;
  l_effective_start_date   date;
  l_person_id              number;
  --
  cursor csr_in_per_contracts is
     select   pc.effective_start_date, pc.business_group_id, pc.person_id
     from     per_contracts_f pc
     where    pc.contract_id = p_contract_id
     and      pc.effective_start_date =
                       (select min(pc1.effective_start_date)
                        from per_contracts_f pc1
                        where pc1.contract_id = p_contract_id
                        and   pc1.contract_id = pc.contract_id);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The contract_id is changing or new
  -- b) The value for contract_id is changing and not null
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.contract_id, hr_api.g_number)
       <> nvl(p_contract_id, hr_api.g_number) AND (p_contract_id is not null))
    or
      (NOT l_api_updating and p_contract_id is not null)) THEN
    hr_utility.set_location(l_proc, 40);
    --
    -- It must exist on per_contracts
    --
    Open csr_in_per_contracts;
      Fetch csr_in_per_contracts Into l_effective_start_date, l_business_group_id, l_person_id;
      If csr_in_per_contracts%notfound then
        --
        -- The contract_id must exist, so error
        --
        Close csr_in_per_contracts;
        -- msg This contract does not exist
        hr_utility.set_message(800, 'PER_52812_INVALID_CONTRACT');
        hr_utility.raise_error;
      Else
        Close csr_in_per_contracts;
        --
        -- It has been found but is it for the same person ?
        --
   if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.PERSON_ID'
        ) then
   If l_person_id <> p_person_id THEN
          -- msg This contract does not belong to this person
          hr_utility.set_message(800, 'PER_52813_CONTRACT_PERSON');
          hr_utility.raise_error;
        --
        elsif l_business_group_id <> p_business_group_id THEN
        -- It has been found but is it in the same business group ?
          -- msg This contract is not in the same business group as the assignment
          hr_utility.set_message(800, 'PER_52814_CONTRACT_IN_BG');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.CONTRACT_ID'
     );
        --
        elsif l_effective_start_date > p_validation_start_date THEN
        -- It has been found, but does it exist from the beginning of the asg row ?
         -- msg This contract does not exist for the lifetime of this assignment row
          hr_utility.set_message(800, 'PER_52815_CONTRACT_AFTER_ASG');
          hr_utility.raise_error;
        --
        End If;
   End If; -- no exclusive error
      End if;
    --
    hr_utility.set_location(l_proc, 80);
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 90);
--
end chk_contract_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_collective_agreement_id >----------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_collective_agreement_id
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date          in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  ,p_collective_agreement_id in per_all_assignments_f.collective_agreement_id%TYPE
  ,p_business_group_id       in per_all_assignments_f.business_group_id%TYPE
  ,p_establishment_id        in per_all_assignments_f.establishment_id%TYPE
  ) is
--
  l_proc            varchar2(72)  :=  g_package||'chk_collective_agreement_id';
  l_api_updating      boolean;
  l_exists            varchar2(1);
  l_business_group_id number;
  l_legislation_code  varchar2(150);
  --
  cursor csr_in_per_coll_agrs is
     select   business_group_id
     from     per_collective_agreements pca
     where    pca.collective_agreement_id = p_collective_agreement_id;
  --
  cursor csr_in_establishment_ca_v is
     select   business_group_id
     from     hr_estab_coll_agrs_v eca
     where    eca.establishment_organization_id  = p_establishment_id
     and      eca.collective_agreement_id  = p_collective_agreement_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_utility.set_location(l_proc, 20);
  --
   l_legislation_code := hr_api.return_legislation_code(p_business_group_id);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and / or
  -- b) The value for collective_agreement_id has changed or is new
  --    or
  -- c) if French, if either establishment_id or collective_id has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.collective_agreement_id, hr_api.g_number)
       <> nvl(p_collective_agreement_id, hr_api.g_number))
    or
      (NOT l_api_updating)
    or
      (l_api_updating and
       nvl(per_asg_shd.g_old_rec.establishment_id, hr_api.g_number)
       <> nvl(p_establishment_id, hr_api.g_number) AND (l_legislation_code = 'FR')))
    THEN
    hr_utility.set_location(l_proc, 40);
    --
    -- If NOT French, it is not mandatory but must be valid if it exists
    --
    if l_legislation_code <> 'FR' and p_collective_agreement_id is not null THEN
      hr_utility.set_location(l_proc, 50);
      Open csr_in_per_coll_agrs;
      Fetch csr_in_per_coll_agrs Into l_business_group_id;
      If csr_in_per_coll_agrs%notfound then
        --
        -- The collective_agreement_id must be there, so error
        --
        Close csr_in_per_coll_agrs;
        -- msg This collective agreement does not exist
        hr_utility.set_message(800, 'PER_52816_COLLECTIVE_AGREEMENT');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.COLLECTIVE_AGREEMENT_ID'
   );
      Else
        Close csr_in_per_coll_agrs;
        --
        -- It must also be in the same business group
        If l_business_group_id <> p_business_group_id THEN
          -- msg This collective agreement is not in your business group
          hr_utility.set_message(800, 'PER_52817_COLLECTIVE_NOT_IN_BG');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.COLLECTIVE_AGREEMENT_ID'
     );
        End If;
      End if;
    --
    elsif l_legislation_code = 'FR' and p_establishment_id is null and
          p_collective_agreement_id is not null THEN
      hr_utility.set_location(l_proc, 60);
      --
      -- msg You must supply a establishment with a collective agreement if french.
      hr_utility.set_message(800, 'PER_52827_NEED_ESTAB');
      hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.COLLECTIVE_AGREEMENT_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.ESTABLISHMENT_ID'
   );
      --
    elsif l_legislation_code = 'FR' and p_collective_agreement_id is not null THEN
      -- If French, the given collective_agreement_id must be valid
      hr_utility.set_location(l_proc, 70);
      --
      if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.ESTABLISHMENT_ID'
       ) then
      --
      Open csr_in_establishment_ca_v;
      Fetch csr_in_establishment_ca_v Into l_business_group_id;
      If csr_in_establishment_ca_v%notfound then
        --
        -- The collective_agreement_id must be there, so error
        --
        Close csr_in_establishment_ca_v;
        -- msg French legislations must supply a collective agreement in your establishment
        hr_utility.set_message(800, 'PER_52828_CAGR_NOT_IN_ESTAB');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.COLLECTIVE_AGREEMENT_ID'
   ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.ESTABLISHMENT_ID'
   );
      Elsif l_business_group_id <> p_business_group_id THEN
        Close csr_in_establishment_ca_v;
        -- msg This collective agreement is not in your business group
        hr_utility.set_message(800, 'PER_52829_CAGR_NOT_IN_BG');
        hr_multi_message.add
        (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.COLLECTIVE_AGREEMENT_ID'
   );
      End If;
      End If; -- no exclusive error
    End if;
    hr_utility.set_location(l_proc, 80);
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 90);
--
end chk_collective_agreement_id;
--  ---------------------------------------------------------------------------
--  |--------------------< chk_establishment_id >-----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_establishment_id
  (p_assignment_id           in per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date          in date
  ,p_object_version_number   in per_all_assignments_f.object_version_number%TYPE
  ,p_establishment_id        in per_all_assignments_f.establishment_id%TYPE
  ,p_assignment_type         in per_all_assignments_f.assignment_type%TYPE
  ,p_business_group_id       in per_all_assignments_f.business_group_id%TYPE
   ) is
--
  l_proc              varchar2(72)  :=  g_package||'chk_establishment_id';
  l_api_updating      boolean;
  l_exists            varchar2(1);
  l_legislation_code  varchar2(150);
  --

  cursor csr_estab_in_org_units is
     select   null
     from     hr_all_organization_units hou
     where    hou.organization_id       = p_establishment_id
     and      hou.business_group_id   = p_business_group_id
     and p_effective_date between date_from and nvl(date_to, p_effective_date);
  --
  cursor csr_estab_in_fr_estab_v is
     select   null
     from hr_fr_establishments_v frv
     where    frv.organization_id       = p_establishment_id
     and      frv.business_group_id   = p_business_group_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_type'
    ,p_argument_value => p_assignment_type
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --

    l_legislation_code := hr_api.return_legislation_code(p_business_group_id);

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for establishment_id has changed
  --    or
  -- c) if French, if the assignment has changed to Employee
  -- d) if French, the employee's establishment is changing to null
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  hr_utility.set_location(l_proc, 30);
  --
  if ((l_api_updating and
       nvl(per_asg_shd.g_old_rec.establishment_id, hr_api.g_number)
       <> nvl(p_establishment_id, hr_api.g_number)
       AND (p_establishment_id is not null))
    or
      ((l_api_updating) AND (l_legislation_code = 'FR') AND (p_assignment_type = 'E')
       AND (p_establishment_id is null) AND ( nvl(per_asg_shd.g_old_rec.establishment_id,
       hr_api.g_number) <> nvl(p_establishment_id, hr_api.g_number)) )
    or
      (NOT l_api_updating )
    or
      (l_api_updating and
       nvl(per_asg_shd.g_old_rec.assignment_type, hr_api.g_varchar2)
       <> nvl(p_assignment_type, hr_api.g_varchar2) AND (l_legislation_code = 'FR')
       and (p_assignment_type = 'E')))
    THEN
    hr_utility.set_location(l_proc, 40);
    --
    -- If NOT French, it is not mandatory but must be valid if it exists
    --
    if l_legislation_code <> 'FR' and p_establishment_id is not null THEN
      hr_utility.set_location(l_proc, 50);
      Open csr_estab_in_org_units;
      Fetch csr_estab_in_org_units Into l_exists;
      If csr_estab_in_org_units%notfound then
        --
        -- The establishment_id must be there, so error
        --
        Close csr_estab_in_org_units;
        hr_utility.set_message(800, 'PER_52818_INVALID_ESTAB');
        hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ESTABLISHMENT_ID'
     ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
     );
      Else
        Close csr_estab_in_org_units;
      End If;
    --
-- Commented out due to relaxation of business rules
--    elsif l_legislation_code = 'FR' and p_establishment_id is null
--      and p_assignment_type = 'E' THEN
--      -- Error, French Employees must have an Establishment_id
--      hr_utility.set_location(l_proc, 60);
--      --
--      hr_utility.set_message(800, 'PER_52830_EE_MUST_HAVE_ESTAB');
--      hr_utility.raise_error;
--      --
    elsif l_legislation_code = 'FR' and p_establishment_id is not null THEN
      -- If French, the given establishment_id must be valid
      hr_utility.set_location(l_proc, 70);
      --
      Open csr_estab_in_fr_estab_v;
      Fetch csr_estab_in_fr_estab_v Into l_exists;
      If csr_estab_in_fr_estab_v%notfound then
        --
        -- The establishment_id must be there, so error
        --
        Close csr_estab_in_fr_estab_v;
        hr_utility.set_message(800, 'PER_52818_INVALID_ESTAB');
        hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.ESTABLISHMENT_ID'
     );
      Else
        Close csr_estab_in_fr_estab_v;
      End If;
      --
    end if;
    hr_utility.set_location(l_proc, 80);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 90);
end chk_establishment_id ;

--  ---------------------------------------------------------------------------
--  |--------------------< chk_notice_period >-----------------------------|
--  ---------------------------------------------------------------------------
--

procedure chk_notice_period
 (
   p_assignment_id  IN  per_all_assignments_f.assignment_id%TYPE,
   p_notice_period   IN  per_all_assignments_f.notice_period%TYPE

 )

  is
--
   l_proc varchar2(72)  :=  g_package||'chk_notice_period';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for notice_period has changed
  --
  IF ( (p_assignment_id IS NULL) OR
       ((p_assignment_id IS NOT NULL) AND
        (per_asg_shd.g_old_rec.notice_period <> p_notice_period))) THEN

   hr_utility.set_location('Entering:'|| l_proc, 20);

     --
     -- Check that notice_period is not null and changed is valid
     --

   IF (p_notice_period IS NOT NULL and p_notice_period < 0) THEN

                    hr_utility.set_location(l_proc, 30);
          hr_utility.set_message(800,'HR_289363_NOTICE_PERIOD_INV');
          hr_utility.raise_error;
   END IF;

    --
  END IF;
    --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.NOTICE_PERIOD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);

end chk_notice_period;

--  ---------------------------------------------------------------------------
--  |--------------------< chk_notice_period_uom >---------------------------|
--  ---------------------------------------------------------------------------
--


procedure chk_notice_period_uom
  ( p_assignment_id          IN  per_all_assignments_f.assignment_id%TYPE
   ,p_notice_period             IN  per_all_assignments_f.notice_period%TYPE
   ,p_notice_period_uom         IN  per_all_assignments_f.notice_period_uom%TYPE
   ,p_effective_date            IN  DATE
   ,p_validation_start_date   IN DATE
   ,P_VALIDATION_END_DATE     IN DATE
  ) IS

  --   Local declarations
  l_proc  VARCHAR2(72) := g_package||'chk_notice_period_uom';
  l_uom_lookup  fnd_lookups.lookup_type%TYPE;

BEGIN

  hr_utility.set_location('Entering: '||l_proc,10);
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'PER_ALL_ASSIGNMENTS_F.NOTICE_PERIOD'
       ) then
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for notice_period_uom has changed
  --
  IF ( (p_assignment_id IS NULL) OR
       ((p_assignment_id IS NOT NULL) AND
        (per_asg_shd.g_old_rec.notice_period_uom <> p_notice_period_uom))) THEN

   hr_utility.set_location('Entering:'|| l_proc, 20);

   IF (p_notice_period IS NOT NULL  AND  p_notice_period_uom  IS NULL ) then

      hr_utility.set_location(l_proc, 30);
      hr_utility.set_message(800, 'HR_289365_NOTICE_UOM_INV');
         hr_multi_message.add
                (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.NOTICE_PERIOD'
           ,p_associated_column2 => 'PER_ALL_ASSIGNMENTS_F.NOTICE_PERIOD_UOM'
           );
   END IF;

   hr_utility.set_location(l_proc, 40);

   IF P_NOTICE_PERIOD_UOM IS NOT NULL THEN

      l_uom_lookup := 'QUALIFYING_UNITS';
      -- Check that the uom exists in HR_LOOKUPS

      IF hr_api.not_exists_in_dt_hr_lookups
         (p_effective_date        => p_effective_date
               ,p_lookup_type           => l_uom_lookup
         ,p_lookup_code           => p_notice_period_uom
                   ,p_validation_start_date => p_validation_start_date
                   ,p_validation_end_date => p_validation_end_date) THEN

         hr_utility.set_location(l_proc, 50);
         hr_utility.set_message(800, 'HR_289365_NOTICE_UOM_INV');
         hr_multi_message.add
                       (p_associated_column1 =>
             'PER_ALL_ASSIGNMENTS_F.NOTICE_PERIOD_UOM'
                  );
      END IF;
   END IF;

  END IF;
  END IF;

  hr_utility.set_location('Leaving: '||l_proc,100);
END chk_notice_period_uom;


--  ---------------------------------------------------------------------------
--  |--------------------< chk_employee_category >---------------------------|
--  ---------------------------------------------------------------------------
--


procedure chk_employee_category
( p_assignment_id        IN  per_all_assignments_f.assignment_id%TYPE
 ,p_employee_category            IN per_all_assignments_f.employee_category%TYPE
 ,p_effective_date           IN DATE
 ,p_validation_start_date  IN DATE
,P_VALIDATION_END_DATE     IN DATE
) IS

--   Local declarations
   l_proc  VARCHAR2(72) := g_package||'chk_notice_period_uom';
   l_catg_lookup fnd_lookups.lookup_type%TYPE;
BEGIN

 hr_utility.set_location('Entering:'|| l_proc, 20);

 IF p_employee_category is NOT NULL THEN
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for employee category has changed
  --
  IF ( (p_assignment_id IS NULL) OR
       ((p_assignment_id IS NOT NULL) AND
        (nvl(per_asg_shd.g_old_rec.employee_category,hr_api.g_varchar2) <> p_employee_category))) THEN

         hr_utility.set_location(l_proc, 40);

         l_catg_lookup := 'EMPLOYEE_CATG';

         -- Check that the uom exists in HR_LOOKUPS

         IF hr_api.not_exists_in_dt_hr_lookups
                   (p_effective_date        => p_effective_date
                 ,p_lookup_type           => l_catg_lookup
                 ,p_lookup_code           => p_employee_category
                          ,p_validation_start_date => p_validation_start_date
                          ,p_validation_end_date => p_validation_end_date) THEN

            hr_utility.set_location(l_proc, 30);
            hr_utility.set_message(800, 'HR_289366_EMPLOYEE_CATG_INV');
            hr_utility.raise_error;
         END IF;

  END IF;
 END IF;
 hr_utility.set_location('Leaving: '||l_proc,100);
 --
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.EMPLOYEE_CATEGORY'
         ,p_associated_column2      =>
    'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE'
         ,p_associated_column3      =>
    'PER_ALL_ASSIGNMENTS_F.EFFECTIVE_END_DATE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 110);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 120);

END chk_employee_category;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_pop_date_start >------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_pop_date_start
  (p_assignment_id          IN per_all_assignments_f.assignment_id%TYPE
  ,p_business_group_id      IN per_all_assignments_f.business_group_id%TYPE
  ,p_person_id              IN per_all_assignments_f.person_id%TYPE
  ,p_assignment_type        IN per_all_assignments_f.assignment_type%TYPE
  ,p_pop_date_start         IN per_periods_of_placement.date_start%TYPE
  ,p_validation_start_date  IN DATE
  ,p_validation_end_date    IN DATE
  ,p_effective_date         IN DATE
  ,p_object_version_number  IN per_all_assignments_f.object_version_number%TYPE
  ) IS
  --
  l_api_updating             BOOLEAN;
  l_exists                   VARCHAR2(1);
  l_proc                     VARCHAR2(72):= g_package||'chk_pop_date_start';
  l_actual_termination_date  per_periods_of_placement.actual_termination_date%TYPE;
  l_business_group_id        per_all_assignments_f.business_group_id%TYPE;
  --
  CURSOR csr_valid_placement is
    SELECT   pop.business_group_id,
            pop.actual_termination_date
    FROM     per_periods_of_placement pop
    WHERE    pop.person_id  = p_person_id
   AND      pop.date_start = p_pop_date_start
   AND      p_validation_start_date BETWEEN pop.date_start AND
                                     NVL(actual_termination_date, hr_api.g_eot);
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  --  Check if the assignment is being updated.
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number
         );
  --
  hr_utility.set_location(l_proc, 30);
  --
  IF NOT l_api_updating THEN
    --
    hr_utility.set_location(l_proc, 40);
    --
    -- Check that the assignment is an employee assignment.
    --
    IF p_assignment_type <> 'C' THEN
      --
      -- Check that period of service is not set
      --
      IF p_pop_date_start IS NOT NULL THEN
        --
      hr_utility.set_message(801, 'HR_289649_DATE_START_NOT_N');
        hr_utility.raise_error;
        --
      END IF;
     --
      hr_utility.set_location(l_proc, 50);
      --
    ELSE
      --
      -- Check the mandatory parameter period of service for
      -- an employee.
      --
      hr_api.mandatory_arg_error
        (p_api_name       => l_proc
        ,p_argument       => 'period_of_placement_date_start'
        ,p_argument_value => p_pop_date_start);
      --
      hr_utility.set_location(l_proc, 60);
      --
      -- Check if the period_of_placement_date_start exists between
      -- the period of placement date start and actual termination date.
      --
      OPEN csr_valid_placement;
      FETCH csr_valid_placement INTO l_business_group_id, l_actual_termination_date;
     --
      IF csr_valid_placement%NOTFOUND THEN
       --
        CLOSE csr_valid_placement;
      --
      hr_utility.set_message(801, 'HR_289650_CWK_INV_PERIOD_OF_PL');
        hr_utility.raise_error;
        --
      END IF;
     --
      CLOSE csr_valid_placement;
     --
      hr_utility.set_location(l_proc, 70);
      --
      -- Check that the period of placement is in the same business group
      -- as the business group of the assignment.
      --
      IF p_business_group_id <> l_business_group_id THEN
        --
      hr_utility.set_message(801, 'HR_289651_CWK_INV_POS_BG');
        hr_utility.raise_error;
        --
      END IF;
     --
      hr_utility.set_location(l_proc, 80);
      --
      -- Check if the period of placement has been closed before the
      -- validation end date.
      --
      IF p_validation_end_date > NVL(l_actual_termination_date, hr_api.g_eot) THEN
        --
        hr_utility.set_message(801, 'HR_6434_EMP_ASS_PER_CLOSED');
        hr_utility.raise_error;
        --
      END IF;
     --
      hr_utility.set_location(l_proc, 90);
      --
    END IF;
  --
  END IF;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 999);
  --
END chk_pop_date_start;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_vendor_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_vendor_id
  (p_assignment_id          IN NUMBER
  ,p_assignment_type        IN VARCHAR2
  ,p_vendor_id              IN NUMBER
  ,p_business_group_id      IN NUMBER
  ,p_object_version_number  IN NUMBER
  ,p_effective_date         IN DATE) IS
  --
  l_proc              VARCHAR2(72)  :=  g_package||'chk_vendor_id';
  l_vendor_id         NUMBER;
  l_api_updating      BOOLEAN;

  CURSOR csr_chk_vendor_id IS
  SELECT pov.vendor_id
  FROM   po_vendors pov
  WHERE  pov.vendor_id = p_vendor_id
  AND    p_effective_date BETWEEN
         NVL(pov.start_date_active, p_effective_date) AND
         NVL(pov.end_date_active, p_effective_date)
  AND    pov.enabled_flag = 'Y';

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  --
  -- Check that mandatory parameters have been set.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_type'
    ,p_argument_value => p_assignment_type
    );

  IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
  END IF;

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value being validated has changed.
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);

  IF g_debug THEN
    hr_utility.set_location(l_proc, 30);
  END IF;

  IF ((l_api_updating AND
       NVL(per_asg_shd.g_old_rec.vendor_id, hr_api.g_number) <>
       NVL(p_vendor_id, hr_api.g_number)) OR
      (NOT l_api_updating)) THEN

    IF g_debug THEN
      hr_utility.set_location(l_proc, 40);
    END IF;

    IF p_vendor_id IS NOT NULL THEN
      --
      -- If the assignment is not a CWK assignment then
      -- raise an error.
      --
      IF p_assignment_type <> 'C' THEN

        hr_utility.set_message(800, 'HR_289652_VENDOR_ID_NOT_NULL');
        hr_utility.raise_error;

      END IF;

      IF g_debug THEN
        hr_utility.set_location(l_proc, 50);
      END IF;

      --
      -- Check that the vendor is valid.
      --
      OPEN  csr_chk_vendor_id;
      FETCH csr_chk_vendor_id INTO l_vendor_id;

      IF csr_chk_vendor_id%NOTFOUND THEN

        CLOSE csr_chk_vendor_id;

        hr_utility.set_message(800, 'HR_289653_INVALID_VENDOR_ID');
        hr_utility.raise_error;

      END IF;

      CLOSE csr_chk_vendor_id;

      IF g_debug THEN
        hr_utility.set_location(l_proc, 60);
      END IF;

    END IF;

    IF g_debug THEN
      hr_utility.set_location(l_proc, 996);
    END IF;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: ' || l_proc, 997);
  END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN

    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.VENDOR_ID') THEN

      IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_proc, 998);
      END IF;

      RAISE;

    END IF;

    IF g_debug THEN
      hr_utility.set_location('Leaving: ' || l_proc, 999);
    END IF;

END chk_vendor_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_vendor_site_id >---------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_vendor_site_id
  (p_assignment_id          IN NUMBER
  ,p_assignment_type        IN VARCHAR2
  ,p_vendor_site_id         IN NUMBER
  ,p_object_version_number  IN NUMBER
  ,p_effective_date         IN DATE) IS

  l_proc              VARCHAR2(72)  :=  g_package||'chk_vendor_site_id';
  l_vendor_site_id    NUMBER;
  l_api_updating      BOOLEAN;

  CURSOR csr_chk_vendor_site_id IS
  SELECT povs.vendor_site_id
  FROM   po_vendor_sites_all povs
  WHERE  povs.vendor_site_id = p_vendor_site_id;

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  --
  -- Check that mandatory parameters have been set.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_type'
    ,p_argument_value => p_assignment_type
    );

  IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
  END IF;

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value being validated has changed.
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);

  IF g_debug THEN
    hr_utility.set_location(l_proc, 30);
  END IF;

  IF ((l_api_updating AND
       NVL(per_asg_shd.g_old_rec.vendor_site_id, hr_api.g_number) <>
       NVL(p_vendor_site_id, hr_api.g_number)) OR
      (NOT l_api_updating)) THEN

    IF g_debug THEN
      hr_utility.set_location(l_proc, 40);
    END IF;

    IF p_vendor_site_id IS NOT NULL THEN
      --
      -- If the assignment is not a CWK assignment then
      -- raise an error.
      --
      IF p_assignment_type <> 'C' THEN

        hr_utility.set_message(800, 'HR_289652_VENDOR_ID_NOT_NULL');
        hr_utility.raise_error;

      END IF;

      IF g_debug THEN
        hr_utility.set_location(l_proc, 50);
      END IF;

      --
      -- Check that the vendor site is valid.
      --
      OPEN  csr_chk_vendor_site_id;
      FETCH csr_chk_vendor_site_id INTO l_vendor_site_id;

      IF csr_chk_vendor_site_id%NOTFOUND THEN

        CLOSE csr_chk_vendor_site_id;

        hr_utility.set_message(800, 'HR_449038_INVALID_VENDOR_SITE');
        hr_utility.raise_error;

      END IF;

      CLOSE csr_chk_vendor_site_id;

      IF g_debug THEN
        hr_utility.set_location(l_proc, 60);
      END IF;

    END IF;

    IF g_debug THEN
      hr_utility.set_location(l_proc, 996);
    END IF;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: ' || l_proc, 997);
  END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN

    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.VENDOR_SITE_ID') THEN

      IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_proc, 998);
      END IF;

      RAISE;

    END IF;

    IF g_debug THEN
      hr_utility.set_location('Leaving: ' || l_proc, 999);
    END IF;

END chk_vendor_site_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_po_header_id >-----------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_po_header_id
  (p_assignment_id          IN NUMBER
  ,p_assignment_type        IN VARCHAR2
  ,p_po_header_id           IN NUMBER
  ,p_business_group_id      IN NUMBER
  ,p_object_version_number  IN NUMBER
  ,p_effective_date         IN DATE) IS

  l_proc              VARCHAR2(72)  :=  g_package||'chk_po_header_id';
  l_po_header_id      NUMBER;
  l_api_updating      BOOLEAN;

  --
  -- Validate that the PO exists within this business group and that
  -- there is at least one line available within this PO that can be
  -- selected.
  --
  CURSOR csr_chk_po_header_id IS
  SELECT poh.po_header_id
  FROM   po_temp_labor_headers_v poh
  WHERE  poh.po_header_id = p_po_header_id
  AND    poh.business_group_id = p_business_group_id
  AND EXISTS
        (SELECT NULL
         FROM   po_temp_labor_lines_v pol
         WHERE  pol.po_header_id = p_po_header_id
         AND NOT EXISTS
               (SELECT NULL
                FROM   per_all_assignments_f paaf
                WHERE (p_assignment_id IS NULL
                   OR (p_assignment_id IS NOT NULL AND
                       p_assignment_id <> paaf.assignment_id))
                AND    paaf.assignment_type = 'C'
                AND    paaf.po_line_id IS NOT NULL
                AND    paaf.po_line_id = pol.po_line_id));

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  --
  -- Check that mandatory parameters have been set.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_type'
    ,p_argument_value => p_assignment_type
    );

  IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
  END IF;

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value being validated has changed.
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);

  IF g_debug THEN
    hr_utility.set_location(l_proc, 30);
  END IF;

  IF ((l_api_updating AND
       NVL(per_asg_shd.g_old_rec.po_header_id, hr_api.g_number) <>
       NVL(p_po_header_id, hr_api.g_number)) OR
      (NOT l_api_updating)) THEN

    IF g_debug THEN
      hr_utility.set_location(l_proc, 40);
    END IF;

    IF p_po_header_id IS NOT NULL THEN
      --
      -- If the assignment is not a CWK assignment then
      -- raise an error.
      --
      IF p_assignment_type <> 'C' THEN

        hr_utility.set_message(800, 'HR_449039_PO_DETAILS_NOT_NULL');
        hr_utility.raise_error;

      END IF;

      IF g_debug THEN
        hr_utility.set_location(l_proc, 50);
      END IF;

      --
      -- Validate that PO services procurement is installed and
      -- that PO details can be set against the assignment.
      --
      IF NOT (hr_po_info.full_cwk_enabled) THEN

        IF g_debug THEN
          hr_utility.set_location(l_proc, 60);
        END IF;

        hr_utility.set_message(800, 'HR_449040_FULL_CWK_NOT_INSTALL');
        hr_utility.raise_error;

      END IF;
      --
      -- Check that the purchase order is valid.
      --
      OPEN  csr_chk_po_header_id;
      FETCH csr_chk_po_header_id INTO l_po_header_id;

      IF csr_chk_po_header_id%NOTFOUND THEN

        CLOSE csr_chk_po_header_id;

        hr_utility.set_message(800, 'HR_449041_PO_HEADER_NOT_NULL');
        hr_utility.raise_error;

      END IF;

      CLOSE csr_chk_po_header_id;

      IF g_debug THEN
        hr_utility.set_location(l_proc, 70);
      END IF;

    END IF;

    IF g_debug THEN
      hr_utility.set_location(l_proc, 996);
    END IF;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: ' || l_proc, 997);
  END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN

    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PO_HEADER_ID') THEN

      IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_proc, 998);
      END IF;

      RAISE;

    END IF;

    IF g_debug THEN
      hr_utility.set_location('Leaving: '|| l_proc, 999);
    END IF;

END chk_po_header_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_po_line_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_po_line_id
  (p_assignment_id          IN NUMBER
  ,p_assignment_type        IN VARCHAR2
  ,p_po_line_id             IN NUMBER
  ,p_object_version_number  IN NUMBER
  ,p_effective_date         IN DATE) IS

  l_proc              VARCHAR2(72)  :=  g_package||'chk_po_line_id';
  l_po_line_id        NUMBER;
  l_api_updating      BOOLEAN;

  --
  -- Validate that the PO line is valid and that is it unassigned.
  -- Additional validation, for example, verifying that the line
  -- matches the job, is performed in cross validation chk routines.
  --
  CURSOR csr_chk_po_line_id IS
  SELECT pol.po_line_id
  FROM   po_temp_labor_lines_v pol
  WHERE  pol.po_line_id = p_po_line_id
  AND NOT EXISTS
        (SELECT NULL
         FROM   per_all_assignments_f paaf
         WHERE (p_assignment_id IS NULL
            OR (p_assignment_id IS NOT NULL AND
                p_assignment_id <> paaf.assignment_id))
         AND    paaf.assignment_type = 'C'
         AND    paaf.po_line_id IS NOT NULL
         AND    paaf.po_line_id = p_po_line_id);

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  --
  -- Check that mandatory parameters have been set.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_type'
    ,p_argument_value => p_assignment_type
    );

  IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
  END IF;

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value being validated has changed.
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);

  IF g_debug THEN
    hr_utility.set_location(l_proc, 30);
  END IF;

  IF ((l_api_updating AND
       NVL(per_asg_shd.g_old_rec.po_line_id, hr_api.g_number) <>
       NVL(p_po_line_id, hr_api.g_number)) OR
      (NOT l_api_updating)) THEN

    IF g_debug THEN
      hr_utility.set_location(l_proc, 40);
    END IF;

    IF p_po_line_id IS NOT NULL THEN
      --
      -- If the assignment is not a CWK assignment then
      -- raise an error.
      --
      IF p_assignment_type <> 'C' THEN

        hr_utility.set_message(800, 'HR_449039_PO_DETAILS_NOT_NULL');
        hr_utility.raise_error;

      END IF;

      IF g_debug THEN
        hr_utility.set_location(l_proc, 50);
      END IF;

      --
      -- Validate that PO services procurement is installed and
      -- that PO details can be set against the assignment.
      --
      IF NOT (hr_po_info.full_cwk_enabled) THEN

        IF g_debug THEN
          hr_utility.set_location(l_proc, 60);
        END IF;

        hr_utility.set_message(800, 'HR_449040_FULL_CWK_NOT_INSTALL');
        hr_utility.raise_error;

      END IF;
      --
      -- Check that the purchase order line is valid.
      --
      OPEN  csr_chk_po_line_id;
      FETCH csr_chk_po_line_id INTO l_po_line_id;

      IF csr_chk_po_line_id%NOTFOUND THEN

        CLOSE csr_chk_po_line_id;

        hr_utility.set_message(800, 'HR_449042_PO_LINE_NOT_NULL');
        hr_utility.raise_error;

      END IF;

      CLOSE csr_chk_po_line_id;

      IF g_debug THEN
        hr_utility.set_location(l_proc, 70);
      END IF;

    END IF;

    IF g_debug THEN
      hr_utility.set_location(l_proc, 996);
    END IF;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: ' || l_proc, 997);
  END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN

    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PO_LINE_ID') THEN

      IF g_debug THEN
        hr_utility.set_location('Leaving: '|| l_proc, 998);
      END IF;

      RAISE;

    END IF;

    IF g_debug THEN
      hr_utility.set_location('Leaving: ' || l_proc, 999);
    END IF;

END chk_po_line_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_projected_assignment_end >-----------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_projected_assignment_end
  (p_assignment_id            IN NUMBER
  ,p_assignment_type          IN VARCHAR2
  ,p_effective_start_date     IN DATE
  ,p_projected_assignment_end IN DATE
  ,p_object_version_number    IN NUMBER
  ,p_effective_date           IN DATE) IS

  l_proc              VARCHAR2(72)  :=  g_package||
                                        'chk_projected_assignment_end';
  l_api_updating      BOOLEAN;

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  --
  -- Check that mandatory parameters have been set.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_type'
    ,p_argument_value => p_assignment_type
    );

  IF g_debug THEN
    hr_utility.set_location(l_proc, 20);
  END IF;

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value being validated has changed.
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);

  IF g_debug THEN
    hr_utility.set_location(l_proc, 30);
  END IF;

  IF ((l_api_updating AND
       NVL(per_asg_shd.g_old_rec.projected_assignment_end, hr_api.g_date) <>
       NVL(p_projected_assignment_end, hr_api.g_date)) OR
      (NOT l_api_updating)) THEN

    IF g_debug THEN
      hr_utility.set_location(l_proc, 40);
    END IF;

    IF p_projected_assignment_end IS NOT NULL THEN
      --
      -- If the assignment is not a CWK assignment or the projected end is
      -- earlier than the start date raise an error.
      --
      -- R12, for global deployments, allow EMP asgs to have projected end date
      --
      IF p_assignment_type not in ('C','E')
       OR p_projected_assignment_end <
          NVL(p_effective_start_date, p_effective_date) THEN

        hr_utility.set_message(800, 'HR_449043_PROJ_ASG_END');
        hr_utility.raise_error;

      END IF;

      IF g_debug THEN
        hr_utility.set_location(l_proc, 50);
      END IF;

    END IF;

    IF g_debug THEN
      hr_utility.set_location(l_proc, 996);
    END IF;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: ' || l_proc, 997);
  END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN

    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.PROJECTED_ASSIGNMENT_END') THEN

      IF g_debug THEN
        hr_utility.set_location('Leaving: ' || l_proc, 998);
      END IF;

      RAISE;

    END IF;

    IF g_debug THEN
      hr_utility.set_location('Leaving: ' || l_proc, 999);
    END IF;

END chk_projected_assignment_end;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_vendor_id_site_id >------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_vendor_id_site_id
  (p_assignment_id            IN NUMBER
  ,p_vendor_id                IN NUMBER
  ,p_vendor_site_id           IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_effective_date           IN DATE) IS

  l_proc              VARCHAR2(72)  :=  g_package||'chk_vendor_id_site_id';
  l_vendor_id         NUMBER;
  l_api_updating      BOOLEAN;

  --
  -- Validate that the supplier site exists for the given
  -- supplier.
  --
  CURSOR csr_chk_vendor_for_site IS
  SELECT povs.vendor_id
  FROM   po_vendor_sites_all povs
  WHERE  povs.vendor_site_id = p_vendor_site_id;

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  IF hr_multi_message.no_exclusive_error
      (p_check_column1 => 'PER_ALL_ASSIGNMENTS_F.VENDOR_ID'
      ,p_check_column2 => 'PER_ALL_ASSIGNMENTS_F.VENDOR_SITE_ID'
       )
  THEN

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The value being validated has changed.
    --
    l_api_updating := per_asg_shd.api_updating
           (p_assignment_id          => p_assignment_id
           ,p_effective_date         => p_effective_date
           ,p_object_version_number  => p_object_version_number);

    IF g_debug THEN
      hr_utility.set_location(l_proc, 20);
    END IF;

    IF (l_api_updating
      AND
        ((NVL(per_asg_shd.g_old_rec.vendor_id, hr_api.g_number)
        <> NVL(p_vendor_id, hr_api.g_number))
        OR
        (NVL(per_asg_shd.g_old_rec.vendor_site_id, hr_api.g_number)
        <> NVL(p_vendor_site_id, hr_api.g_number))))
      OR
        NOT l_api_updating THEN

      IF g_debug THEN
        hr_utility.set_location(l_proc, 30);
      END IF;

      IF p_vendor_site_id IS NOT NULL AND p_vendor_id IS NULL THEN
        --
        -- Error. The vendor_id must always be set when the vendor_site_id
        -- is set.
        --
        IF g_debug THEN
          hr_utility.set_location(l_proc, 40);
        END IF;

        hr_utility.set_message(800, 'HR_449044_ENTER_VENDOR_ID');
        hr_utility.raise_error;

      END IF;

      IF g_debug THEN
        hr_utility.set_location(l_proc, 50);
      END IF;

      IF p_vendor_site_id IS NOT NULL AND p_vendor_id IS NOT NULL THEN
        --
        -- Validate the site exists for the given supplier.
        --
        OPEN  csr_chk_vendor_for_site;
        FETCH csr_chk_vendor_for_site INTO l_vendor_id;
        CLOSE csr_chk_vendor_for_site;

        IF l_vendor_id IS NULL OR
           l_vendor_id <> p_vendor_id THEN

          IF g_debug THEN
            hr_utility.set_location(l_proc, 60);
          END IF;

          hr_utility.set_message(800, 'HR_449045_NO_SITE_FOR_VENDOR');
          hr_utility.raise_error;

        END IF;

        IF g_debug THEN
          hr_utility.set_location(l_proc, 996);
        END IF;

      END IF;

    END IF;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: ' || l_proc, 997);
  END IF;

END chk_vendor_id_site_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_po_header_id_line_id >---------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_po_header_id_line_id
  (p_assignment_id            IN NUMBER
  ,p_po_header_id             IN NUMBER
  ,p_po_line_id               IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_effective_date           IN DATE) IS

  l_proc              VARCHAR2(72)  :=  g_package||'chk_po_header_id_line_id';
  l_po_header_id      NUMBER;
  l_api_updating      BOOLEAN;

  --
  -- Validate that the PO line exists for the given
  -- PO.
  --
  CURSOR csr_chk_po_for_line IS
  SELECT pol.po_header_id
  FROM   po_temp_labor_lines_v pol
  WHERE  pol.po_header_id = p_po_header_id;

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  IF hr_multi_message.no_exclusive_error
      (p_check_column1 => 'PER_ALL_ASSIGNMENTS_F.PO_HEADER_ID'
      ,p_check_column2 => 'PER_ALL_ASSIGNMENTS_F.PO_LINE_ID'
       )
  THEN

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The value being validated has changed.
    --
    l_api_updating := per_asg_shd.api_updating
           (p_assignment_id          => p_assignment_id
           ,p_effective_date         => p_effective_date
           ,p_object_version_number  => p_object_version_number);

    IF g_debug THEN
      hr_utility.set_location(l_proc, 20);
    END IF;

    IF (l_api_updating
      AND
        ((NVL(per_asg_shd.g_old_rec.po_header_id, hr_api.g_number)
        <> NVL(p_po_header_id, hr_api.g_number))
        OR
        (NVL(per_asg_shd.g_old_rec.po_line_id, hr_api.g_number)
        <> NVL(p_po_line_id, hr_api.g_number))))
      OR
        NOT l_api_updating THEN

      IF g_debug THEN
        hr_utility.set_location(l_proc, 30);
      END IF;

      IF p_po_line_id IS NOT NULL AND p_po_header_id IS NULL THEN
        --
        -- Error. The po_line_id must always be set when the po_header_id
        -- is set.
        --
        IF g_debug THEN
          hr_utility.set_location(l_proc, 40);
        END IF;

        hr_utility.set_message(800, 'HR_449046_ENTER_PO_HEADER_ID');
        hr_utility.raise_error;

      END IF;

      IF g_debug THEN
        hr_utility.set_location(l_proc, 50);
      END IF;

      IF p_po_header_id IS NOT NULL AND p_po_line_id IS NOT NULL THEN
        --
        -- Validate the line exists for the given PO.
        --
        OPEN  csr_chk_po_for_line;
        FETCH csr_chk_po_for_line INTO l_po_header_id;
        CLOSE csr_chk_po_for_line;

        IF l_po_header_id IS NULL OR
           l_po_header_id <> p_po_header_id THEN

          IF g_debug THEN
            hr_utility.set_location(l_proc, 60);
          END IF;

          hr_utility.set_message(800, 'HR_449047_NO_LINE_FOR_PO');
          hr_utility.raise_error;

        END IF;

        IF g_debug THEN
          hr_utility.set_location(l_proc, 996);
        END IF;

      END IF;

    END IF;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: ' || l_proc, 997);
  END IF;

END chk_po_header_id_line_id;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_vendor_po_match >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_vendor_po_match
  (p_assignment_id            IN NUMBER
  ,p_vendor_id                IN NUMBER
  ,p_vendor_site_id           IN NUMBER
  ,p_po_header_id             IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_effective_date           IN DATE) IS

  l_proc              VARCHAR2(72)  :=  g_package||'chk_vendor_po_match';
  l_vendor_id         NUMBER;
  l_vendor_site_id    NUMBER;
  l_api_updating      BOOLEAN;

  --
  -- Fetch the vendor and site for this PO.
  --
  CURSOR csr_chk_vendor_po_match IS
  SELECT NVL(poh.vendor_id, p_vendor_id) vendor_id
        ,NVL(poh.vendor_site_id, p_vendor_site_id) vendor_site_id
  FROM   po_temp_labor_headers_v poh
  WHERE  poh.po_header_id = p_po_header_id;

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  IF hr_multi_message.no_exclusive_error
      (p_check_column1 => 'PER_ALL_ASSIGNMENTS_F.VENDOR_ID'
      ,p_check_column2 => 'PER_ALL_ASSIGNMENTS_F.VENDOR_SITE_ID'
      ,p_check_column3 => 'PER_ALL_ASSIGNMENTS_F.PO_HEADER_ID'
       )
  THEN

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The value being validated has changed.
    --
    l_api_updating := per_asg_shd.api_updating
           (p_assignment_id          => p_assignment_id
           ,p_effective_date         => p_effective_date
           ,p_object_version_number  => p_object_version_number);

    IF g_debug THEN
      hr_utility.set_location(l_proc, 20);
    END IF;

    IF (l_api_updating
      AND
        ((NVL(per_asg_shd.g_old_rec.vendor_id, hr_api.g_number)
        <> NVL(p_vendor_id, hr_api.g_number))
        OR
        (NVL(per_asg_shd.g_old_rec.vendor_site_id, hr_api.g_number)
        <> NVL(p_vendor_site_id, hr_api.g_number))
        OR
        (NVL(per_asg_shd.g_old_rec.po_header_id, hr_api.g_number)
        <> NVL(p_po_header_id, hr_api.g_number))))
      OR
        NOT l_api_updating THEN

      IF g_debug THEN
        hr_utility.set_location(l_proc, 30);
      END IF;

      IF p_po_header_id IS NOT NULL
      AND (p_vendor_id IS NOT NULL OR p_vendor_site_id IS NOT NULL) THEN

        IF g_debug THEN
          hr_utility.set_location(l_proc, 40);
        END IF;

        --
        -- Verify that the Supplier on the PO matches the Supplier passed
        -- into the row handler.
        --
        OPEN  csr_chk_vendor_po_match;
        FETCH csr_chk_vendor_po_match INTO l_vendor_id
                                          ,l_vendor_site_id;
        CLOSE csr_chk_vendor_po_match;

        IF (p_vendor_id IS NOT NULL AND p_vendor_id <> l_vendor_id)
        OR (p_vendor_site_id IS NOT NULL AND
            p_vendor_site_id <> l_vendor_site_id) THEN

          IF g_debug THEN
            hr_utility.set_location(l_proc, 50);
          END IF;

          hr_utility.set_message(800, 'HR_449048_VENDOR_NOT_MATCH_PO');
          hr_utility.raise_error;

        END IF;

      END IF;

    END IF;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| l_proc, 997);
  END IF;

END chk_vendor_po_match;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_po_job_match >-----------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_po_job_match
  (p_assignment_id            IN NUMBER
  ,p_job_id                   IN NUMBER
  ,p_po_line_id               IN NUMBER
  ,p_object_version_number    IN NUMBER
  ,p_effective_date           IN DATE) IS

  l_proc              VARCHAR2(72)  :=  g_package||'chk_po_job_match';
  l_job_id            NUMBER;
  l_api_updating      BOOLEAN;

  --
  -- Fetch the job for this PO line.
  --
  CURSOR csr_chk_po_job_match IS
  SELECT NVL(pol.job_id, hr_api.g_number) job_id
  FROM   po_temp_labor_lines_v pol
  WHERE  pol.po_line_id = p_po_line_id;

BEGIN

  IF g_debug THEN
    hr_utility.set_location('Entering: ' || l_proc, 10);
  END IF;

  IF hr_multi_message.no_exclusive_error
      (p_check_column1 => 'PER_ALL_ASSIGNMENTS_F.JOB_ID'
      ,p_check_column2 => 'PER_ALL_ASSIGNMENTS_F.PO_LINE_ID'
       )
  THEN

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The value being validated has changed.
    --
    l_api_updating := per_asg_shd.api_updating
           (p_assignment_id          => p_assignment_id
           ,p_effective_date         => p_effective_date
           ,p_object_version_number  => p_object_version_number);

    IF g_debug THEN
      hr_utility.set_location(l_proc, 20);
    END IF;

    IF (l_api_updating
      AND
        ((NVL(per_asg_shd.g_old_rec.job_id, hr_api.g_number)
        <> NVL(p_job_id, hr_api.g_number))
        OR
        (NVL(per_asg_shd.g_old_rec.po_line_id, hr_api.g_number)
        <> NVL(p_po_line_id, hr_api.g_number))))
      OR
        NOT l_api_updating THEN

      IF g_debug THEN
        hr_utility.set_location(l_proc, 30);
      END IF;

      IF p_po_line_id IS NOT NULL AND p_job_id IS NOT NULL THEN

        IF g_debug THEN
          hr_utility.set_location(l_proc, 40);
        END IF;

        --
        -- Verify that the Job on the PO matches the Job on the assignment.
        --
        OPEN  csr_chk_po_job_match;
        FETCH csr_chk_po_job_match INTO l_job_id;
        CLOSE csr_chk_po_job_match;

        IF p_job_id <> l_job_id THEN

          IF g_debug THEN
            hr_utility.set_location(l_proc, 50);
          END IF;

          hr_utility.set_message(800, 'HR_449049_JOB_NOT_MATCH_PO');
          hr_utility.raise_error;

        END IF;

      END IF;

    END IF;

  END IF;

  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| l_proc, 997);
  END IF;

END chk_po_job_match;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_vendor_assignment_number >-------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_vendor_assignment_number
  (p_assignment_id            IN per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type          IN per_all_assignments_f.assignment_type%TYPE
  ,p_vendor_assignment_number IN per_all_assignments_f.vendor_assignment_number%TYPE
  ,p_business_group_id        IN per_assignments_f.business_group_id%TYPE
  ,p_object_version_number    IN per_all_assignments_f.object_version_number%TYPE
  ,p_effective_date           IN DATE) IS
  --
  l_proc         VARCHAR2(72):=  g_package||'chk_vendor_assignment_number';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_type'
    ,p_argument_value => p_assignment_type
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for vacancy has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  IF ((l_api_updating AND
       NVL(per_asg_shd.g_old_rec.vendor_assignment_number, hr_api.g_varchar2) <>
       NVL(p_vendor_assignment_number, hr_api.g_varchar2)) OR
      (NOT l_api_updating)) THEN
    --
    hr_utility.set_location(l_proc, 40);
    --
    -- If the vendor assignment number has been populated for an
   -- assignment that is not a CWK assignment then
   -- raise an error.
    --
    IF p_vendor_assignment_number IS NOT NULL AND
      p_assignment_type <> 'C' THEN
      --
     hr_utility.set_message(801, 'HR_289654_VEN_ASG_NO_NOT_NULL');
      hr_utility.raise_error;
      --
    END IF;
   --
  END IF;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 997);
  --
EXCEPTION
  --
  WHEN app_exception.application_exception THEN
    --
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.VENDOR_ASSIGNMENT_NUMBER') THEN
      --
      hr_utility.set_location(' Leaving:'|| l_proc, 998);
      --
      RAISE;
      --
    END IF;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 999);
    --
END chk_vendor_assignment_number;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_vendor_employee_number >-------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE chk_vendor_employee_number
  (p_assignment_id          IN per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_type        IN per_all_assignments_f.assignment_type%TYPE
  ,p_vendor_employee_number IN per_all_assignments_f.vendor_employee_number%TYPE
  ,p_business_group_id      IN per_assignments_f.business_group_id%TYPE
  ,p_object_version_number  IN per_all_assignments_f.object_version_number%TYPE
  ,p_effective_date         IN DATE) IS
  --
  l_proc         VARCHAR2(72) := g_package||'chk_vendor_employee_number';
  l_api_updating BOOLEAN;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_type'
    ,p_argument_value => p_assignment_type
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for vacancy has changed
  --
  l_api_updating := per_asg_shd.api_updating
         (p_assignment_id          => p_assignment_id
         ,p_effective_date         => p_effective_date
         ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  IF ((l_api_updating AND
       NVL(per_asg_shd.g_old_rec.vendor_employee_number, hr_api.g_varchar2) <>
       NVL(p_vendor_employee_number, hr_api.g_varchar2)) OR
      (NOT l_api_updating)) THEN
    --
    hr_utility.set_location(l_proc, 40);
    --
    -- If the employee number has been populated for an
   -- assignment that is not a CWK assignment then
   -- raise an error.
    --
    IF p_vendor_employee_number IS NOT NULL AND
      p_assignment_type <> 'C' THEN
      --
     hr_utility.set_message(801, 'HR_289655_VEN_EMP_NO_NOT_NULL');
      hr_utility.raise_error;
      --
    END IF;
   --
  END IF;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 997);
  --
EXCEPTION
  --
  WHEN app_exception.application_exception THEN
    --
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_ALL_ASSIGNMENTS_F.VENDOR_EMPLOYEE_NUMBER') THEN
      --
      hr_utility.set_location(' Leaving:'|| l_proc, 998);
      --
      RAISE;
      --
    END IF;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 999);
    --
END chk_vendor_employee_number;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_work_at_home >-------------------------------|
--  ---------------------------------------------------------------------------
--


 procedure chk_work_at_home
 ( p_assignment_id       IN  per_all_assignments_f.assignment_id%TYPE
  ,p_work_at_home        IN per_all_assignments_f.work_at_home%TYPE
  ,p_effective_date         IN DATE
  ,p_validation_start_date IN DATE
  ,P_VALIDATION_END_DATE      IN DATE
 ) IS

--   Local declarations

   l_proc  VARCHAR2(72) := g_package||'chk_work_at_home';
   l_wah_lookup fnd_lookups.lookup_type%TYPE;
BEGIN
  --
 hr_utility.set_location('Entering:'|| l_proc, 20);
 IF p_work_at_home is not null then
  --
  -- Only proceed with validation if :
  -- a) Inserting or
  -- b) The value for notice_period_uom has changed
  --
  IF ( (p_assignment_id IS NULL) OR
       ((p_assignment_id IS NOT NULL) AND
        (nvl(per_asg_shd.g_old_rec.work_at_home,hr_api.g_varchar2) <> p_work_at_home))) THEN

          hr_utility.set_location(l_proc, 40);

          l_wah_lookup := 'YES_NO';
     -- Check that the uom exists in HR_LOOKUPS

            IF hr_api.not_exists_in_dt_hr_lookups
                    (p_effective_date        => p_effective_date
                     ,p_lookup_type           => l_wah_lookup
                     ,p_lookup_code           => p_work_at_home
                     ,p_validation_start_date => p_validation_start_date
                     ,p_validation_end_date => p_validation_end_date) THEN

            hr_utility.set_location(l_proc, 40);
            hr_utility.set_message(800, 'HR_289364_WORK_AT_HOME_INV');
                      hr_utility.raise_error;
      END IF;
   END IF;
  END IF;

  hr_utility.set_location('Leaving: '||l_proc,100);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.WORK_AT_HOME'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 110);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 120);
END chk_work_at_home;
--
--  ---------------------------------------------------------------------------
--  |--------------------< chk_grade_ladder_pgm_id >---------------------------|
--  ---------------------------------------------------------------------------
--
 procedure chk_grade_ladder_pgm_id
 ( p_grade_id           in  per_all_assignments_f.grade_id%TYPE
  ,p_grade_ladder_pgm_id in  per_all_assignments_f.grade_ladder_pgm_id%TYPE
  ,p_business_group_id   in  per_all_assignments_f.business_group_id%TYPE
  ,p_effective_date      in  date
 ) IS

--
-- cursor declare
--
 cursor  csr_pgm is
    select null
    from  ben_pgm_f
    where business_group_id = p_business_group_id
    and   pgm_typ_cd = 'GSP'
    and   pgm_id = p_grade_ladder_pgm_id
    and   p_effective_date
          between effective_start_date
          and   effective_end_date;

--
 cursor csr_plip is
     select null
     from  ben_plip_f plip
          ,ben_pl_f   plan
          ,ben_pgm_f  pgm
     where plan.mapping_table_name = 'PER_GRADES'
     and   plan.mapping_table_pk_id = p_grade_id
     and   plan.business_group_id = p_business_group_id
     and   plan.pl_stat_cd = 'A'
     and   p_effective_date
           between plan.effective_start_date and
           plan.effective_end_date
     and   plan.pl_id = plip.pl_id
     and   plip.business_group_id = p_business_group_id
     and   plip.plip_stat_cd = 'A'
     and   p_effective_date
           between plip.effective_start_date and
           plip.effective_end_date
     and   pgm.pgm_id = p_grade_ladder_pgm_id
     and   pgm.pgm_id = plip.pgm_id
     and   pgm.pgm_typ_cd = 'GSP'
     and   pgm.business_group_id = p_business_group_id
     and   p_effective_date
           between pgm.effective_start_date and
           pgm.effective_end_date;

  --
    l_proc   VARCHAR2(72) := g_package||'chk_grade_ladder_pgm_id';
    l_exists varchar2(1);
  --
BEGIN
  --
 hr_utility.set_location('Entering:'|| l_proc, 20);
 IF p_grade_ladder_pgm_id is not null and p_grade_id is null then
  --
  -- Only proceed with validation if :
  -- grade_ladder_pgm_id is valid
  --
    open csr_pgm;
    fetch csr_pgm into l_exists;
    if csr_pgm%notfound then
      close csr_pgm;
      hr_utility.set_location(l_proc, 30);
      --
      -- grade_ladder_pgm_id is no in ben_pgm_f table
      --
      -- Bug 2661569
      -- Changed the calls to hr_utility.set_message and hr_utility.raise_error
      hr_utility.set_message(801, 'HR_289561_GRADE_LADDER_INVALID');
      hr_utility.raise_error;
    else
      hr_utility.set_location(l_proc, 40);
      close csr_pgm;
    end if;
  ELSIF p_grade_ladder_pgm_id is not null and p_grade_id is not null then
    --
    -- Only proceed with validation if :
    -- grade_ladder_pgm_id and grade_id is valid
    --
    open csr_pgm;
    fetch csr_pgm into l_exists;
    if csr_pgm%notfound then
      close csr_pgm;
      hr_utility.set_location(l_proc, 50);
      --
      -- grade_ladder_pgm_id is no in ben_pgm_f table
      --
      -- Bug 2661569
      -- Changed the calls to hr_utility.set_message and hr_utility.raise_error
      hr_utility.set_message(801, 'HR_289561_GRADE_LADDER_INVALID');
      hr_utility.raise_error;

    end if;
    close csr_pgm;

    hr_utility.set_location(l_proc, 60);

    open csr_plip;
    fetch csr_plip into l_exists;
    if csr_plip%notfound then
      hr_utility.set_location(l_proc, 70);
      close csr_plip;
      --
      -- The combination of grade_id and grade_ladder_pgm_id isn't in ben_plip_f
      --
      -- Bug 2661569
      -- Changed the calls to hr_utility.set_message and hr_utility.raise_error
      hr_utility.set_message(800, 'HR_289562_GRADE_NOT_IN_LADDER');
      hr_utility.raise_error;
    else
      close csr_plip;
      hr_utility.set_location(l_proc, 80);
    end if;
  END IF;
  hr_utility.set_location('Leaving: '||l_proc,100);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_ASSIGNMENTS_F.GRADE_LADDER_PGM_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 110);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 120);
END chk_grade_ladder_pgm_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------< access_to_primary_asg >----------------------------|
--  ---------------------------------------------------------------------------
--
FUNCTION access_to_primary_asg
 (p_person_id       IN NUMBER
 ,p_effective_date  IN DATE
 ,p_assignment_type IN VARCHAR2)
RETURN BOOLEAN IS

  l_assignment_id NUMBER;

BEGIN

  IF p_person_id       IS NOT NULL AND
     p_effective_date  IS NOT NULL AND
     p_assignment_type IS NOT NULL THEN
    --
    -- Retrieve the primary assignment from the assignment-level secure
    -- view.
    --
    SELECT paf.assignment_id
    INTO   l_assignment_id
    FROM   per_assignments_f2 paf
    WHERE  paf.person_id = p_person_id
    AND    p_effective_date BETWEEN
           paf.effective_start_date AND paf.effective_end_date
    AND    paf.assignment_type = p_assignment_type
    AND    paf.primary_flag = 'Y'
    AND    rownum = 1;

  ELSE

    RAISE no_data_found;

  END IF;

  RETURN TRUE;

EXCEPTION

  WHEN no_data_found THEN

    RETURN FALSE;

END access_to_primary_asg;
--
end per_asg_bus3;

/
