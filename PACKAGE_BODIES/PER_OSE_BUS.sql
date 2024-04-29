--------------------------------------------------------
--  DDL for Package Body PER_OSE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_OSE_BUS" as
/* $Header: peoserhi.pkb 120.2.12000000.1 2007/01/22 00:38:55 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ose_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_org_structure_element_id    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_org_structure_element_id             in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_org_structure_elements ose
     where ose.org_structure_element_id = p_org_structure_element_id
       and pbg.business_group_id = ose.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'org_structure_element_id'
    ,p_argument_value     => p_org_structure_element_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_org_structure_element_id             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_org_structure_elements ose
     where ose.org_structure_element_id = p_org_structure_element_id
       and pbg.business_group_id (+) = ose.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'org_structure_element_id'
    ,p_argument_value     => p_org_structure_element_id
    );
  --
  if ( nvl(per_ose_bus.g_org_structure_element_id, hr_api.g_number)
       = p_org_structure_element_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_ose_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    per_ose_bus.g_org_structure_element_id := p_org_structure_element_id;
    per_ose_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec in per_ose_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_ose_shd.api_updating
      (p_org_structure_element_id             => p_rec.org_structure_element_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_ose_shd.g_old_rec.business_group_id
        ,hr_api.g_number
        ) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.org_structure_version_id, hr_api.g_number) <>
     nvl(per_ose_shd.g_old_rec.org_structure_version_id
        ,hr_api.g_number
        ) then
     l_argument := 'org_structure_version_id';
     raise l_error;
  end if;
  --
/* bug no 2720039 starts here

Removing following check on oraganization hierarchy so that updation of
organization nodes can be done in it.We don't need to put extra check
for ensuring not having cycle into organization hierarcy because this
task is achieved by a constraint PER_ORG_STRUCTURE_ELEMENTS_UK2 according
to which ORG_STRUCTURE_VERSION_ID and ORGANIZATION_ID_CHILD is the unique
combination in table PER_ORG_STRUCTURE_ELEMENTS.

  if nvl(p_rec.organization_id_parent, hr_api.g_number) <>
     nvl(per_ose_shd.g_old_rec.organization_id_parent
        ,hr_api.g_number
        ) then
     l_argument := 'organization_id_parent';
     raise l_error;
  end if;
bug no 2720039 ends here
*/
  --
  if nvl(p_rec.organization_id_child, hr_api.g_number) <>
     nvl(per_ose_shd.g_old_rec.organization_id_child
        ,hr_api.g_number
        ) then
     l_argument := 'organization_id_child';
     raise l_error;
  end if;
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- -------------------------------------------------------------------------------
-- |---------------------------< chk_children_exist >----------------------------|
-- -------------------------------------------------------------------------------
PROCEDURE chk_children_exist
            (p_org_structure_version_id in
                     per_org_structure_elements.org_structure_version_id%TYPE
            ,p_organization_id_child in
                     per_org_structure_elements.organization_id_child%TYPE
            ) is
--
l_temp VARCHAR2(1);
--
begin
   --
   -- Pre-delete checks for subordinate
   -- organizations in the hierarchy.
   --
      select  null
      into l_temp
      from sys.dual
      where exists (select null
                     from per_org_structure_elements      ose
                     where   ose.org_structure_version_id    =
                                          p_org_structure_version_id
                     and     ose.organization_id_parent      =
                                          p_organization_id_child);
      --
      hr_utility.set_message('801','HR_6190_ORG_CHILDREN_EXIST');
      hr_utility.raise_error;
      --
exception
         when no_data_found then
            null;
         when others then
            raise;
end chk_children_exist;
--
-- ------------------------------------------------------------------------
-- |---------------------------< chk_top_org >----------------------------|
-- ------------------------------------------------------------------------
PROCEDURE chk_top_org
             (p_org_structure_version_id
                in per_org_structure_elements.org_structure_version_id%TYPE
                     ,p_org_structure_element_id
                in per_org_structure_elements.org_structure_element_id%TYPE
                     ,p_organization_id_child
                in per_org_structure_elements.organization_id_child%TYPE
                     ,p_organization_id_parent
                in per_org_structure_elements.organization_id_parent%TYPE
             ) is
--
l_temp VARCHAR2(1);
--
begin
   --
   --
   -- If the child org in the element = top org in an
   -- security_profile and hierarchies are the same
   -- then cannot delete it.
   -- similarly if the parent_org in the element = top org in a
   --security_profile and hierarchies are the same
   -- then you cannot delete it if it is the parent of no other
   -- org_structure_element for this version.
   --
         select null
         into l_temp
         from sys.dual
         where exists( select null
                     from per_security_profiles psp
                     where   psp.include_top_organization_flag = 'Y'
                     and     psp.organization_structure_id     =
                           (select osv.organization_structure_id
                           from    per_org_structure_versions osv
                           where   osv.org_structure_version_id =
                                 p_org_structure_version_id)
                     and   ((psp.organization_id = p_organization_id_child)
                        or(psp.organization_id = p_organization_id_parent
                           and not exists (
                              select  null
                              from    per_org_structure_elements ose
                              where   ose.org_structure_version_id  =
                                       p_org_structure_version_id
                              and     ose.organization_id_child     =
                                       p_organization_id_parent
                              )
                           and     not exists (
                              select  null
                              from    per_org_structure_elements ose
                              where   ose.org_structure_version_id  =
                                       p_org_structure_version_id
                              and     ose.org_structure_element_id  <>
                                       p_org_structure_element_id
                              and     ose.organization_id_parent    =
                                       p_organization_id_parent
                              )
                           )
                        ) );
      --
      hr_utility.set_message('801','HR_6753_ORG_HIER_SP_DEL');
      hr_utility.raise_error;
      --
exception
         when no_data_found then
            null;
         when others then
            raise;
end chk_top_org;
-- ------------------------------------------------------------------------
-- |---------------------------< chk_pa_org >----------------------------|
-- ------------------------------------------------------------------------
PROCEDURE chk_pa_org
             (p_org_structure_element_id
                in per_org_structure_elements.org_structure_element_id%TYPE
             ) is
begin
   --
   -- Run the validation PROCEDURE writtrn by PA development group.
   --
      pa_org.pa_ose_predel_validation(p_org_structure_element_id);
end chk_pa_org;
--
-- ------------------------------------------------------------------------
-- |---------------------------< chk_position_control >-------------------|
-- ------------------------------------------------------------------------
PROCEDURE chk_position_control
             (p_org_structure_version_id in number
             ,p_pos_control_enabled_flag in varchar2
             ) is

cursor c1 is
select str.position_control_structure_flg
from per_organization_structures str,
     per_org_structure_versions osv
where osv.org_structure_version_id = p_org_structure_version_id
and osv.organization_structure_id = str.organization_structure_id;

l_result varchar2(10);

begin
--
  --
  -- If position control flag is set, ensure it is also
  -- set for the hierarchy.
  --

  if p_pos_control_enabled_flag = 'Y' then
  --
    open c1;
    fetch c1 into l_result;

    if c1%found then
    --
      if l_result <> 'Y' then
      --
        close c1;
        hr_utility.set_message('800','PER_50055_NON_POS_CTRL_STRUCT');
        hr_utility.raise_error;
      --
      end if;
    --
    end if;

    close c1;
  --
  end if;
--
end chk_position_control;

-- -----------------------------------------------------------------------------
-- |--------------------< chk_org_structure_version_id >------------------------|
-- -----------------------------------------------------------------------------
--  Description:
--    Validates that the mandatory structure version id is supplied and that it
--    exists in per_org_structure_versions for the business group on the
--    effective date (Insert Only).
--
--  Pre-conditions:
--   Business group is valid
--
--  In Arguments:
--    p_org_structure_element_id
--    p_business_group_id
--    p_org_structure_version_id
--    p_effective_date
--
--  Post Success:
--    If a row does exist in per_org_structure_versions for the given id and
--    business group then processing continues.
--
--  Post Failure:
--    Processing stops and an error is raised.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
PROCEDURE chk_org_structure_version_id(p_org_structure_element_id in NUMBER
                                      ,p_business_group_id in NUMBER
                                      ,p_org_structure_version_id in NUMBER
                                      ,p_effective_date in DATE) IS

CURSOR csr_org_structure_versions IS
  SELECT 'X'
  from per_org_structure_versions osv
  where osv.org_structure_version_id = p_org_structure_version_id
  and (osv.business_group_id = p_business_group_id or p_business_group_id is null)
  and p_effective_date between osv.DATE_FROM
                       and nvl(osv.DATE_TO,hr_general.end_of_time);

 l_dummy varchar2(1);
 l_proc  varchar2(100) := g_package||'chk_org_structure_version_id';

begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
 /*  --  Bug fix 3065432
    Removed the condition which raises an error if business_group_id is
   null value */

  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  --
  if p_org_structure_version_id is null then
     hr_utility.set_message(800,'HR_289731_ORG_VER_NULL');
     hr_utility.raise_error;
  else
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Only proceed with validation if :
    -- a) Inserting (org_structure_version_id is non updateable)
    --
    if (p_org_structure_element_id is null) then

      open csr_org_structure_versions;
      fetch csr_org_structure_versions into l_dummy;
      if csr_org_structure_versions%notfound then
        close csr_org_structure_versions;
        hr_utility.set_message(800,'HR_289732_ORG_VER_INV');
        hr_utility.raise_error;
      end if;
      close csr_org_structure_versions;

    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);

end chk_org_structure_version_id;

-- -----------------------------------------------------------------------------
-- |-------------------< chk_parent_child_org_id >------------------------|
-- -----------------------------------------------------------------------------
--  Description:
--    Validates that both the parent and subordinate orgs are supplied and
--    exist in hr_all_organization_units for the business group (if not global)
--    on the effective_date.
--    Also checks that the subordinate org is unique within the structure
--    version, to prevent circular hierarchies. (Insert Only).
--
--  Pre-conditions:
--   Business group is valid
--   Structure version is valid.
--
--  In Arguments:
--    p_org_structure_element_id
--    p_business_group_id
--    p_effective_date
--    p_org_structure_version_id
--    p_organization_id_parent
--    p_organization_id_child
--
--  Post Success:
--    Processing continues
--
--  Post Failure:
--    Processing stops and an error is raised.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
PROCEDURE chk_parent_child_org_id(p_org_structure_element_id in NUMBER
                                 ,p_business_group_id in NUMBER
                                 ,p_effective_date in DATE
                                 ,p_org_structure_version_id in NUMBER
                                 ,p_organization_id_parent in NUMBER
                                 ,p_organization_id_child in NUMBER) IS

 CURSOR csr_org (p_org_id in NUMBER) IS
  SELECT 'X'
  from hr_all_organization_units org
  where org.organization_id = p_org_id
  and (org.business_group_id = p_business_group_id
       or p_business_group_id is null)
  and p_effective_date between org.DATE_FROM
                       and nvl(org.DATE_TO,hr_general.end_of_time);

  CURSOR csr_ele IS
  SELECT 'X'
  from per_org_structure_elements ele
  where ele.org_structure_version_id = p_org_structure_version_id
  and ele.organization_id_child = p_organization_id_child;

  --- bug fix 3820767 starts here
  CURSOR csr_chk_circular IS
  SELECT organization_id_parent
    from per_org_structure_elements
    where org_structure_version_id=p_org_structure_version_id
    START WITH organization_id_child=p_organization_id_parent
      and  org_structure_version_id=p_org_structure_version_id
    CONNECT BY organization_id_child= prior organization_id_parent
      and org_structure_version_id=p_org_structure_version_id ;
----  bug fix 3820767 ends here
 l_dummy varchar2(1);
 l_proc  varchar2(100) := g_package||'chk_parent_child_organization_id';

begin
 hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
/*  --  Bug fix 3065432
   Removed the condition which raises an error if business_group_id is
   null value */
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  --
  if p_organization_id_parent is null or p_organization_id_child IS null then
     hr_utility.set_message(800,'HR_289733_ORG_NULL');
     hr_utility.raise_error;
  else
    --
--
    hr_utility.set_location(l_proc, 5);
    --
    -- Only proceed with validation if :
    -- a) Inserting (parent or child org id are non-updateable)
    --
    if (p_org_structure_element_id is null) then
      -- check parent org exists
      open csr_org(p_org_id => p_organization_id_parent);
      fetch csr_org into l_dummy;
      if csr_org%notfound then
        close csr_org;
        hr_utility.set_message(800,'HR_289734_PARENT_ORG_INV');
        hr_utility.raise_error;
      end if;
      close csr_org;

      hr_utility.set_location(l_proc, 20);
      -- check child org exists
      open csr_org(p_organization_id_child);
      fetch csr_org into l_dummy;
      if csr_org%notfound then
        close csr_org;
        hr_utility.set_message(800,'HR_289735_CHILD_ORG_INV');
        hr_utility.raise_error;
      end if;
      close csr_org;
   ---
   --- bug fix 3820767 starts here
   ---
   -- check if child is the same as parent
      if p_organization_id_child =p_organization_id_parent then
               hr_utility.set_message(800,'HR_449550_ORG_PAR_CHILD_EQUAL');
               hr_utility.raise_error;
      end if;
   ---
    hr_utility.set_location(l_proc, 25);
     -- check for circular hierarchies
     for c_rec in csr_chk_circular
     loop
       if c_rec.organization_id_parent = p_organization_id_child
       then
         -- This will cause circular hierarchies
        hr_utility.set_message(800,'HR_449549_CIRCULAR_HIER');
        hr_utility.raise_error;
     end if;
    end loop;
   --
   -- bug fix 3820767 ends here
   --
      hr_utility.set_location(l_proc, 30);
      -- check child is unique within the structure
      open csr_ele;
      fetch csr_ele into l_dummy;
      if csr_ele%found then
        close csr_ele;
        hr_utility.set_message(800,'HR_289736_CHILD_ORG_EXISTS');
        hr_utility.raise_error;
      end if;
      close csr_ele;

    end if;
  end if;

  hr_utility.set_location('Leaving:'||l_proc, 50);
--
end chk_parent_child_org_id;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_ose_shd.g_rec_type
  ,p_effective_date               in date
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_exists_in_hierarchy varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- EDIT_HERE: The following call to hr_api.validate_bus_grp_id
  -- will only be valid when the business_group_id is not null.
  -- As this column is defined as optional on the table then
  -- different logic will be required to handle the null case.
  -- If this is a start-up data entity then:
  --    a) add code to stop null values being processed by this
  --       row handler
  -- If this is not a start-up data entity then either:
  --    b) ignore the security_group_id value held in
  --       client_info.  This includes performing lookup
  --       validation against the HR_STANDARD_LOOKUPS view.
  -- or c) (less likely) ensure the correct security_group_id
  --       value is set in client_info.
  -- Remove this comment when the edit has been completed.
  if p_rec.business_group_id is not null then
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_org_structure_version_id(p_org_structure_element_id => p_rec.org_structure_element_id
                              ,p_business_group_id        => p_rec.business_group_id
                              ,p_org_structure_version_id => p_rec.org_structure_version_id
                              ,p_effective_date           => p_effective_date);


  chk_parent_child_org_id(p_org_structure_element_id => p_rec.org_structure_element_id
                         ,p_business_group_id        => p_rec.business_group_id
                         ,p_effective_date           => p_effective_date
                         ,p_org_structure_version_id => p_rec.org_structure_version_id
                         ,p_organization_id_parent   => p_rec.organization_id_parent
                         ,p_organization_id_child    => p_rec.organization_id_child);

  chk_position_control
             (p_org_structure_version_id => p_rec.org_structure_version_id
             ,p_pos_control_enabled_flag => p_rec.position_control_enabled_flag
             );
  per_ose_del.chk_org_in_hierarchy
             (p_org_structure_version_id => p_rec.org_structure_version_id
             ,p_organization_id          => p_rec.organization_id_child
             ,p_exists_in_hierarchy      => l_exists_in_hierarchy
             );
if l_exists_in_hierarchy = 'Y' then
fnd_message.set_name('PER', 'HR_289572_EXISTS_IN_HIERARCHY');
fnd_message.raise_error;
end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_ose_shd.g_rec_type
  ,p_effective_date               in date
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_exists_in_hierarchy varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- EDIT_HERE: The following call to hr_api.validate_bus_grp_id
  -- will only be valid when the business_group_id is not null.
  -- As this column is defined as optional on the table then
  -- different logic will be required to handle the null case.
  -- If this is a start-up data entity then:
  --    a) add code to stop null values being processed by this
  --       row handler
  -- If this is not a start-up data entity then either:
  --    b) ignore the security_group_id value held in
  --       client_info.  This includes performing lookup
  --       validation against the HR_STANDARD_LOOKUPS view.
  -- or c) (less likely) ensure the correct security_group_id
  --       value is set in client_info.
  -- Remove this comment when the edit has been completed.
  -- commented out pzwalker
  -- hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --

  chk_position_control
             (p_org_structure_version_id => p_rec.org_structure_version_id
             ,p_pos_control_enabled_flag => p_rec.position_control_enabled_flag
             );
  --
/*
  -- we should not be updating parent or child ids for the element  - PERWSDPH.fmb does not allow it
  -- and the form and api behaviour should be consistent.

  per_ose_del.chk_org_in_hierarchy
             (p_org_structure_version_id => p_rec.org_structure_version_id
             ,p_organization_id          => p_rec.organization_id_child
             ,p_exists_in_hierarchy      => l_exists_in_hierarchy
             );

if l_exists_in_hierarchy = 'Y' then
fnd_message.set_name('PER', 'HR_289572_EXISTS_IN_HIERARCHY');
fnd_message.raise_error;
end if;
*/

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_ose_shd.g_rec_type
  ,p_hr_installed                 in VARCHAR2
  ,p_pa_installed                 in VARCHAR2
  ,p_chk_children_exist           in VARCHAR2
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if p_chk_children_exist = 'Y' then
      per_ose_bus.chk_children_exist
              (p_org_structure_version_id => p_rec.org_structure_version_id
              ,p_organization_id_child => p_rec.organization_id_child
              );
  end if;
  --
  if p_hr_installed = 'I' then
      per_ose_bus.chk_top_org
              (p_org_structure_version_id => p_rec.org_structure_version_id
              ,p_org_structure_element_id => p_rec.org_structure_element_id
              ,p_organization_id_child    => p_rec.organization_id_child
              ,p_organization_id_parent   => p_rec.organization_id_parent
              );
  end if;
  --
  if p_pa_installed = 'I' then
      per_ose_bus.chk_pa_org
              (p_org_structure_element_id => p_rec.org_structure_element_id
              );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_ose_bus;

/
