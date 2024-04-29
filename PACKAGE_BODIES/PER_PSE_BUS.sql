--------------------------------------------------------
--  DDL for Package Body PER_PSE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PSE_BUS" as
/* $Header: pepserhi.pkb 120.0.12010000.2 2008/08/06 09:29:57 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pse_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_pos_structure_element_id    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_pos_structure_element_id             in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_pos_structure_elements pse
     where pse.pos_structure_element_id = p_pos_structure_element_id
       and pbg.business_group_id = pse.business_group_id;
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
    ,p_argument           => 'pos_structure_element_id'
    ,p_argument_value     => p_pos_structure_element_id
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
  (p_pos_structure_element_id             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_pos_structure_elements pse
     where pse.pos_structure_element_id = p_pos_structure_element_id
       and pbg.business_group_id = pse.business_group_id;
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
    ,p_argument           => 'pos_structure_element_id'
    ,p_argument_value     => p_pos_structure_element_id
    );
  --
  if ( nvl(per_pse_bus.g_pos_structure_element_id, hr_api.g_number)
       = p_pos_structure_element_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pse_bus.g_legislation_code;
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
    per_pse_bus.g_pos_structure_element_id:= p_pos_structure_element_id;
    per_pse_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_pse_shd.g_rec_type
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
  IF NOT per_pse_shd.api_updating
      (p_pos_structure_element_id             => p_rec.pos_structure_element_id
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
     nvl(per_pse_shd.g_old_rec.business_group_id
        ,hr_api.g_number
        ) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.pos_structure_version_id, hr_api.g_number) <>
     nvl(per_pse_shd.g_old_rec.pos_structure_version_id
        ,hr_api.g_number
        ) then
     l_argument := 'pos_structure_version_id';
     raise l_error;
  end if;
  --
/* bug no 3888749 starts here

Removing following check on Position hierarchy so that updation of
Position nodes can be done in it. We don't need to put extra check
for ensuring not having cycle into position hierarcy because this
task is achieved by a constraint PER_POS_STRUCTURE_ELEMENTS_UK2 according
to which POS_STRUCTURE_VERSION_ID and SUBORDINATE_POSITION_ID is the unique
combination in table PER_POS_STRUCTURE_ELEMENTS.

  if nvl(p_rec.parent_position_id, hr_api.g_number) <>
     nvl(per_pse_shd.g_old_rec.parent_position_id
        ,hr_api.g_number
        ) then
     l_argument := 'parent_position_id';
     raise l_error;
  end if;

  bug no 3888749  ends here   */
  --
  if nvl(p_rec.subordinate_position_id, hr_api.g_number) <>
     nvl(per_pse_shd.g_old_rec.subordinate_position_id
        ,hr_api.g_number
        ) then
     l_argument := 'subordinate_position_id';
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
            (p_pos_structure_version_id in
                     per_pos_structure_elements.pos_structure_version_id%TYPE
            ,p_Subordinate_position_Id in
                     per_pos_structure_elements.Subordinate_position_Id%TYPE
            ) is
--
l_temp VARCHAR2(1);
--
begin
   --
   -- Pre-delete checks for subordinate
   -- positions in the hierarchy.
   --
                select null
                into l_temp
                from sys.dual
                where exists(select 1
                from per_pos_structure_elements pse
                where pse.parent_position_id = p_Subordinate_position_Id
                and   pse.pos_structure_version_id = p_Pos_Structure_version_Id);
                --
                hr_utility.set_message('801','HR_6915_POS_DEL_FIRST');
                hr_utility.raise_error;
                --
                exception
                        when no_data_found then
                                null;
end chk_children_exist;
--
-- -----------------------------------------------------------------------------
-- |---------------------------< chk_security_pos >----------------------------|
-- -----------------------------------------------------------------------------
PROCEDURE chk_security_pos(p_Subordinate_position_Id NUMBER
                           ,p_Business_Group_Id NUMBER
                           ,p_Pos_Structure_version_Id NUMBER) IS
l_dummy VARCHAR2(1);
begin
   select null
   into l_dummy
   from sys.dual
   where exists(select 1
   from per_security_profiles psp
   where  psp.business_group_id + 0     = p_Business_Group_Id
   and    psp.position_id = p_Subordinate_position_Id
   and    psp.position_structure_id = (select psv.position_structure_id
                                      from per_pos_structure_versions psv
                                      where psv.Pos_Structure_version_Id
                                            = p_Pos_Structure_version_Id)
   );
   --
   hr_utility.set_message(801,'PAY_7694_PER_NO_DEL_STRUCTURE');
   hr_utility.raise_error;
   --
exception
   when no_data_found then
      null;
end chk_security_pos;


--
-- -----------------------------------------------------------------------------
-- |--------------------< chk_pos_structure_version_id >------------------------|
-- -----------------------------------------------------------------------------
--  Description:
--    Validates that the mandatory structure version id is supplied and that it
--    exists in per_pos_structure_versions for the business group on the
--    effective date (Insert Only).
--
--  Pre-conditions:
--   Business group is valid
--
--  In Arguments:
--    p_pos_structure_element_id
--    p_business_group_id
--    p_pos_structure_version_id
--    p_effective_date
--
--  Post Success:
--    If a row does exist in per_pos_structure_versions for the given id and
--    business group then processing continues.
--
--  Post Failure:
--    Processing stops and an error is raised.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
PROCEDURE chk_pos_structure_version_id(p_pos_structure_element_id in NUMBER
                                      ,p_business_group_id in NUMBER
                                      ,p_pos_structure_version_id in NUMBER
                                      ,p_effective_date in DATE) IS

CURSOR csr_pos_structure_versions IS
  SELECT 'X'
  from per_pos_structure_versions psv
  where psv.pos_structure_version_id = p_pos_structure_version_id
  and psv.business_group_id = p_business_group_id
  and p_effective_date between psv.DATE_FROM
                       and nvl(psv.DATE_TO,hr_general.end_of_time);

 l_dummy varchar2(10);
 l_proc  varchar2(100) := g_package||'chk_pos_structure_version_id';

begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  --
  if p_pos_structure_version_id is null then
     hr_utility.set_message(800,'HR_289723_POS_VER_NULL');
     hr_utility.raise_error;
  else
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Only proceed with validation if :
    -- a) Inserting (pos_structure_version_id is non updateable)
    --
    if (p_pos_structure_element_id is null) then

      open csr_pos_structure_versions;
      fetch csr_pos_structure_versions into l_dummy;
      if csr_pos_structure_versions%notfound then
        close csr_pos_structure_versions;
        hr_utility.set_message(800,'HR_289724_POS_VER_INV');
        hr_utility.raise_error;
      end if;
      close csr_pos_structure_versions;

    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);

end chk_pos_structure_version_id;

--
-- -----------------------------------------------------------------------------
-- |-------------------< chk_parent_child_position_id >------------------------|
-- -----------------------------------------------------------------------------
--  Description:
--    Validates that both the parent and subordinate positions are supplied and
--    exist in hr_all_positions_f for the business group on the effective_date.
--    Also checks that the subordinate position is unique within the structure
--    version, to prevent circular hierarchies. (Insert Only).
--
--  Pre-conditions:
--   Business group is valid
--   Structure version is valid.
--
--  In Arguments:
--    p_pos_structure_element_id
--    p_business_group_id
--    p_effective_date
--    p_pos_structure_version_id
--    p_parent_position_id
--    p_subordinate_position_id
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
PROCEDURE chk_parent_child_position_id(p_pos_structure_element_id in NUMBER
                                      ,p_business_group_id in NUMBER
                                      ,p_effective_date in DATE
                                      ,p_pos_structure_version_id in NUMBER
                                      ,p_parent_position_id in NUMBER
                                      ,p_subordinate_position_id in NUMBER) IS

  CURSOR csr_pos (p_pos_id in NUMBER) IS
  SELECT 'X'
  from hr_all_positions_f pos
  where pos.POSITION_ID = p_pos_id
  and pos.business_group_id = p_business_group_id
  and p_effective_date between pos.EFFECTIVE_START_DATE
                       and pos.EFFECTIVE_END_DATE;

  CURSOR csr_ele IS
  SELECT 'X'
  from per_pos_structure_elements ele
  where ele.pos_structure_version_id = p_pos_structure_version_id
  and ele.subordinate_position_id = p_subordinate_position_id;

 l_dummy varchar2(1);
 l_proc  varchar2(100) := g_package||'chk_parent_child_position_id';

begin
 hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  --
  if p_parent_position_id is null or p_subordinate_position_id is null then
     hr_utility.set_message(800,'HR_289725_POS_NULL');
     hr_utility.raise_error;
  else
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Only proceed with validation if :
    -- a) Inserting (parent or child position_id are non-updateable)
    --
    if (p_pos_structure_element_id is null) then
      -- check parent position_id exists
      open csr_pos(p_pos_id => p_parent_position_id);
      fetch csr_pos into l_dummy;
      if csr_pos%notfound then
        close csr_pos;
        hr_utility.set_message(800,'HR_289726_PARENT_POS_INV');
        hr_utility.raise_error;
      end if;
      close csr_pos;

      hr_utility.set_location(l_proc, 20);
      -- check child position_id exists
      open csr_pos(p_subordinate_position_id);
      fetch csr_pos into l_dummy;
      if csr_pos%notfound then
        close csr_pos;
        hr_utility.set_message(800,'HR_289727_CHILD_POS_INV');
        hr_utility.raise_error;
      end if;
      close csr_pos;

      hr_utility.set_location(l_proc, 30);
      -- check if child is the same as parent
      if p_subordinate_position_id=p_parent_position_id then
               hr_utility.set_message(800,'HR_289481_PARENT_CHILD_EQUAL');
               hr_utility.raise_error;
      end if;
      -- check child is unique within the structure
      open csr_ele;
      fetch csr_ele into l_dummy;
      if csr_ele%found then
        close csr_ele;
        hr_utility.set_message(800,'HR_289728_CHILD_POS_EXISTS');
        hr_utility.raise_error;
      end if;
      close csr_ele;

    end if;
  end if;

  hr_utility.set_location('Leaving:'||l_proc, 50);
--
end chk_parent_child_position_id;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_pse_shd.g_rec_type
  ,p_effective_date               in date
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp

  --
  -- validate structure_version_id
  --
  per_pse_bus.chk_pos_structure_version_id(p_pos_structure_element_id => p_rec.pos_structure_version_id
                                          ,p_business_group_id        => p_rec.business_group_id
                                          ,p_pos_structure_version_id => p_rec.pos_structure_version_id
                                          ,p_effective_date           => p_effective_date);

  --
  -- validate parent and subordinate position_id
  --
  per_pse_bus.chk_parent_child_position_id(p_pos_structure_element_id =>  p_rec.pos_structure_element_id
                                          ,p_business_group_id        =>  p_rec.business_group_id
                                          ,p_effective_date           =>  p_effective_date
                                          ,p_pos_structure_version_id =>  p_rec.pos_structure_version_id
                                          ,p_parent_position_id       =>  p_rec.parent_position_id
                                          ,p_subordinate_position_id  =>  p_rec.subordinate_position_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_pse_shd.g_rec_type
  ,p_effective_date               in date
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pse_shd.g_rec_type
  ,p_hr_installed                 in VARCHAR2
  ,p_chk_children                 in VARCHAR2
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if p_chk_children = 'Y' then
      per_pse_bus.chk_children_exist
              (p_pos_structure_version_id => p_rec.pos_structure_version_id
              ,p_subordinate_position_id => p_rec.subordinate_position_id
              );
  end if;
  --
  if p_hr_installed = 'I' then
      per_pse_bus.chk_security_pos
              (p_Subordinate_position_Id    => p_rec.Subordinate_position_Id
              ,p_Business_Group_Id          => p_rec.Business_Group_Id
              ,p_Pos_Structure_version_Id   => p_rec.Pos_Structure_version_Id
              );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_pse_bus;

/
