--------------------------------------------------------
--  DDL for Package Body HR_AMD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AMD_BUS" as
/* $Header: hramdrhi.pkb 115.6 2002/12/03 16:08:21 apholt ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_amd_bus.';  -- Global package name
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_non_updateable_args >--------------|
--  -----------------------------------------------------------------
--
Procedure chk_non_updateable_args
  (p_rec            in hr_amd_shd.g_rec_type
  ) is
--
  l_proc     varchar2(72) := g_package||'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not hr_amd_shd.api_updating
      (p_api_module_id          => p_rec.api_module_id
      ) then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.api_module_type, hr_api.g_varchar2) <>
     nvl(hr_amd_shd.g_old_rec.api_module_type
        ,hr_api.g_varchar2
        ) then
     l_argument := 'api_module_type';
     raise l_error;
  end if;
  --
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(hr_amd_shd.g_old_rec.legislation_code
        ,hr_api.g_varchar2
        ) then
     l_argument := 'legislation_code';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 40);
exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         );
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
end chk_non_updateable_args;
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_api_module_type >-------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Checks that the module type is not null and takes a valid value.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_module_id
--    p_api_module_type
--
--  Post Success:
--    Processing continues if the module_type is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the module_type is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_api_module_type
       (p_api_module_id		in	number,
        p_api_module_type       in      varchar2,
        p_effective_date        in      date
       ) is
--
--  Local declarations
  l_proc			varchar2(72) := g_package||' chk_api_module_type';
  l_api_updating                boolean;
--
begin
	hr_utility.set_location('Entering: '||l_proc,5);
        --
        --------------------------------
        -- Check module type not null --
        --------------------------------
        hr_api.mandatory_arg_error
           (p_api_name => l_proc,
            p_argument =>  'p_api_module_type',
            p_argument_value => p_api_module_type);
        --------------------------------
        -- Check module type is valid --
        --------------------------------
        if hr_api.not_exists_in_hr_lookups
               (p_effective_date => p_effective_date,
                p_lookup_type    => 'API_MODULE_TYPE',
                p_lookup_code    => p_api_module_type) then
           hr_amd_shd.constraint_error('HR_API_MODULES_CK1');
        end if;

	hr_utility.set_location('Leaving: '||l_proc,10);
end chk_api_module_type;
--
--
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_module_name >-------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Validates that the module_name is not null, entered in upper case and
--    that the combination of name and package is unique on the table.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_module_id
--    p_api_module_type
--    p_module_name
--
--  Post Success:
--    Processing continues if the module_name is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the is module_name invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_module_name
       (p_api_module_id		in	number,
        p_api_module_type       in      varchar2,
	p_module_name		in	varchar2
       ) is
--
-- Local declarations
     l_proc                 varchar2(72) := g_package||'chk_module_name';
     l_module_name          varchar2(30) := p_module_name;
     l_module_type          varchar2(30);
     l_module_id            number := 0;
     l_api_updating         boolean;
--
-- Declare a cursor that will check whether the passed
-- in module type and module name form a unique combination
   cursor csr_valid_combo is
   select api_module_id from hr_api_modules ham
   where ham.module_name = p_module_name
   and   ham.api_module_type = p_api_module_type;

begin
    hr_utility.set_location('Entering: '||l_proc,5);

    -- check if the module is being updated or inserted.
    l_api_updating := hr_amd_shd.api_updating
                      (p_api_module_id => p_api_module_id);
    --
    -- Proceed with validation based on outcome of api_updating call.

    if ((l_api_updating and
        hr_amd_shd.g_old_rec.module_name <> nvl(p_module_name,hr_api.g_varchar2)) or
        (not l_api_updating)) then
       --------------------------------
       -- Check module name not null --
       --------------------------------
       hr_api.mandatory_arg_error
           (p_api_name => l_proc,
            p_argument =>  'p_module_name',
            p_argument_value => p_module_name);

       ---------------------------------------------------------------
       -- Check that the module name has been entered in upper case --
       ---------------------------------------------------------------

       if( p_module_name <> upper(l_module_name) ) then
          hr_utility.set_message(800, 'PER_52118_AMD_MOD_NAME_NOT_UPP');
          hr_utility.raise_error;
       end if;

       --------------------------------------------------------
       -- Check for unique Module name and module type combo --
       --------------------------------------------------------
       open csr_valid_combo;
       fetch csr_valid_combo into l_module_id;

       if csr_valid_combo%found then
           close csr_valid_combo;
           hr_amd_shd.constraint_error('HR_API_MODULES_UK1');
       end if;

       close csr_valid_combo;
    end if;
    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_module_name;
--
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_data_within_business_group >------|
--  -----------------------------------------------------------------
--
--  Description:
--    Checks that data_within_business_group is valid and non null.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_module_id
--    p_data_within_business_group
--    p_effective_date
--
--  Post Success:
--    Processing continues if the data_within_business_group is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the data_within_business_group is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_data_within_business_group
       (p_api_module_id              in	number,
        p_data_within_business_group in varchar2,
        p_effective_date             in date
       ) is
--
--  Local declarations
  l_proc      varchar2(72) := g_package||'chk_data_within_business_group';
  l_application_id      hr_lookups.application_id%TYPE;
--
-- Cursor and local variable to control changing data_within business_group
-- from Yes to No
--
  l_exists  varchar2(1);
--
 Cursor csr_legislation_data is
    select null
        from hr_api_hooks hk
        where hk.api_module_id = p_api_module_id
        and (legislation_package is not null
              or legislation_function is not null) ;
--
begin
     hr_utility.set_location('Entering: '||l_proc,5);

     ----------------------------------------
     -- Check data within bus grp not null --
     ----------------------------------------
     hr_api.mandatory_arg_error
         (p_api_name => l_proc,
          p_argument =>  'p_data_within_business_group',
          p_argument_value => p_data_within_business_group);
     --------------------------------
     -- Check module type is valid --
     --------------------------------
  if (p_api_module_id is not null) and
      (hr_amd_shd.g_old_rec.data_within_business_group
         <> p_data_within_business_group)  or
       (p_api_module_id is null) then
        --
        -- do look up validation
        --
       if hr_api.not_exists_in_hr_lookups
          (p_effective_date         => p_effective_date,
           p_lookup_type            => 'YES_NO',
           p_lookup_code            => p_data_within_business_group) then
           -- Error, invalid value.
           hr_amd_shd.constraint_error('HR_API_MODULES_CK2');
       end if;
     --
     if ((p_api_module_id is not null)
        and hr_amd_shd.g_old_rec.data_within_business_group ='Y'
        and p_data_within_business_group = 'N') then
       open  csr_legislation_data;
       fetch csr_legislation_data into l_exists;
          if csr_legislation_data%found then
          close csr_legislation_data;
               hr_utility.set_message(800, 'PER_74019_LEG_CODE');
               hr_utility.raise_error;
          end if;
    hr_utility.set_location('Entering: '||l_proc,7);
    close csr_legislation_data;
    end if;
 --
 end if;
 --
  hr_utility.set_location('Leaving: '||l_proc,10);
end chk_data_within_business_group;
--
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_legislation_code >----------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the legislation_code is valid within FND_TERRITORIES
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_module_id
--    p_legislation_code
--
--  Post Success:
--    Processing continues if legislation_code the is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the is legislation_code invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_legislation_code
       (p_api_module_id		in	number,
        p_legislation_code      in      varchar2
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_legislation_code';
  l_territory_code     fnd_territories.territory_code%TYPE;
--
-- Setup cursor for valid legislation code check
  cursor csr_valid_legislation_code is
    select territory_code
    from fnd_territories ft
    where ft.territory_code = p_legislation_code;

--
--
begin
     hr_utility.set_location('Entering: '||l_proc,5);

     --------------------------------
     -- Check legislation code is valid --
     --------------------------------
     if p_legislation_code is not null then
        open csr_valid_legislation_code;
        fetch csr_valid_legislation_code into l_territory_code;

        if csr_valid_legislation_code%notfound then
            close csr_valid_legislation_code;
            hr_utility.set_message(800,'PER_52123_AMD_LEG_CODE_INV');
            hr_utility.raise_error;
        end if; -- End cursor if

        close csr_valid_legislation_code;
     end if; -- end check

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_legislation_code;
--
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_module_package >------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Checks that the module_package is entered in upper case and that the
--    combination of module_package and module_type is valid.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_module_id
--    p_api_module_type
--    p_module_package
--
--  Post Success:
--    Processing continues if the module_package is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the is module_package invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_module_package
       (p_api_module_id		in	number,
        p_api_module_type       in      varchar2,
        p_module_package        in      varchar2
       ) is
--
--  Local declarations
  l_proc			varchar2(72) := g_package||'chk_module_package';
  l_module_package              varchar2(30) := p_module_package;
  l_api_updating                boolean;
--
begin
     hr_utility.set_location('Entering: '||l_proc,5);
    -- Check if module is being updated
        l_api_updating := hr_amd_shd.api_updating
                      (p_api_module_id => p_api_module_id);

    -- Proceed with validation based on outcome of api_updating call.
    -- Have to convert null values of module_package (a null value is
    -- valid for this parm) otherwise the comparison will always
    -- return false.
    if ((l_api_updating and
        nvl(hr_amd_shd.g_old_rec.module_package,'X') <> nvl(p_module_package,'X')) or
        (not l_api_updating)) then
       -------------------------------------------------------------
       -- Check the Module Package and Module Type Combo is valid --
       -------------------------------------------------------------

       if p_api_module_type = 'BP' and p_module_package is null then
           hr_utility.set_message(800, 'PER_52124_AMD_MOD_PACK_INV1');
           hr_utility.raise_error;
       elsif p_api_module_type = 'RH' and p_module_package is not null then
           hr_utility.set_message(800, 'PER_52125_AMD_MOD_PACK_INV2');
           hr_utility.raise_error;
       end if;

       ---------------------------------------------------------------
       -- Check that the module name has been entered in upper case --
       ---------------------------------------------------------------

       if( p_module_package <> upper(l_module_package) ) then
          hr_utility.set_message(800, 'PER_52120_AMD_MOD_PACK_NOT_UPP');
          hr_utility.raise_error;
       end if;
    end if;

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_module_package;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_delete >-------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Prevents deletion of a row if it has children
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_module_id
--
--  Post Success:
--    Processing continues if the row has no children
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the row has children.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_delete
       (p_api_module_id		in	number
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_delete';
  l_api_module_id      number;
--
-- Setup cursor to check for children
  cursor csr_check_for_child is
    select api_module_id
    from hr_api_hooks hah
    where hah.api_module_id = p_api_module_id;
--
--
begin
     hr_utility.set_location('Entering: '||l_proc,5);

     -- We don't have to check for valid module id as this is done by the lck proc
     --------------------------------------
     -- Check if module has any children --
     --------------------------------------

     open csr_check_for_child;
     fetch csr_check_for_child into l_api_module_id;

     if csr_check_for_child%found then
         close csr_check_for_child;
         hr_utility.set_message(800,'PER_52155_AMD_CANNOT_DEL_ROW');
         hr_utility.raise_error;
     end if;

     close csr_check_for_child;

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_delete;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_amd_shd.g_rec_type,
                          p_effective_date in date    ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
  hr_api.set_security_group_id(p_security_group_id => 0);
  --
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Call all supporting business operations
  --
  -- Validate Module Type
     chk_api_module_type
       (p_api_module_id		=> p_rec.api_module_id,
        p_api_module_type       => p_rec.api_module_type,
        p_effective_date        => p_effective_date
       );
  --
  -- Validate Module Name
     chk_module_name
     (p_api_module_id		=> p_rec.api_module_id,
      p_api_module_type 	=> p_rec.api_module_type,
      p_module_name		=> p_rec.module_name
     );
  --
  -- Validate Data within Business Group
     chk_data_within_business_group
       (p_api_module_id              => p_rec.api_module_id,
        p_data_within_business_group => p_rec.data_within_business_group,
        p_effective_date             => p_effective_date
       );
  --
  -- Validate Legislation Code
     chk_legislation_code
       (p_api_module_id	             => p_rec.api_module_id,
        p_legislation_code           => p_rec.legislation_code
       );
  --
  -- Validate Module Package
     chk_module_package
       (p_api_module_id		=> p_rec.api_module_id,
        p_api_module_type       => p_rec.api_module_type,
        p_module_package        => p_rec.module_package
       );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- -----------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_amd_shd.g_rec_type,
                          p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
  hr_api.set_security_group_id(p_security_group_id => 0);
  --
  -- Check that all non-updateable args have in fact not been modified.
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  hr_amd_bus.chk_non_updateable_args(p_rec => p_rec);
  --
  -- Call all supporting business operations
  --
  -- Validate Module Name
     chk_module_name
     (p_api_module_id		=> p_rec.api_module_id,
      p_api_module_type 	=> p_rec.api_module_type,
      p_module_name		=> p_rec.module_name
     );
  --
  -- Validate Data within Business Group
     chk_data_within_business_group
       (p_api_module_id              => p_rec.api_module_id,
        p_data_within_business_group => p_rec.data_within_business_group,
        p_effective_date             => p_effective_date
       );
 --
  -- Validate Module Package
     chk_module_package
       (p_api_module_id		=> p_rec.api_module_id,
        p_api_module_type       => p_rec.api_module_type,
        p_module_package        => p_rec.module_package
       );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_amd_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
    chk_delete(p_api_module_id   =>   p_rec.api_module_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_amd_bus;

/
