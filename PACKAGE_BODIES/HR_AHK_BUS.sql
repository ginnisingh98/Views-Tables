--------------------------------------------------------
--  DDL for Package Body HR_AHK_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AHK_BUS" as
/* $Header: hrahkrhi.pkb 115.8 2002/12/03 16:34:49 apholt ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_ahk_bus.';  -- Global package name
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_non_updateable_args >--------------|
--  -----------------------------------------------------------------
--
Procedure chk_non_updateable_args
  (p_rec            in hr_ahk_shd.g_rec_type
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
  if not hr_ahk_shd.api_updating
      (p_api_hook_id          => p_rec.api_hook_id
      ) then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.api_module_id, hr_api.g_varchar2) <>
     nvl(hr_ahk_shd.g_old_rec.api_module_id
        ,hr_api.g_varchar2
        ) then
     l_argument := 'api_module_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(hr_ahk_shd.g_old_rec.legislation_code
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
--  |-----------------------< chk_api_module_id >-------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the api_module_id is not null and that it refers to a row on
--    the parent HR_API_MODULES table. Prohibit insert into table HR_API_HOOKS
--    should the api-module-type equal 'AI' (Alternative Interface).
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_id
--    p_api_module_id
--
--  Post Success:
--    Processing continues if the api_module_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the api_module_id is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_api_module_id
       (p_api_hook_id           in      number,
        p_api_module_id		in	number
       ) is
--
--  Local declarations
  l_proc			varchar2(72) := g_package||' chk_api_module_id';
  l_api_module_type             hr_api_modules.api_module_type%TYPE;

  -- Setup cursor for valid module type check
  cursor csr_valid_module_type is
    select api_module_type
    from hr_api_modules
    where api_module_id = p_api_module_id;
--
begin
	hr_utility.set_location('Entering: '||l_proc,5);
        --
        --------------------------------
        -- Check module id not null --
        --------------------------------
        hr_api.mandatory_arg_error
           (p_api_name => l_proc,
            p_argument =>  'p_api_module_id',
            p_argument_value => p_api_module_id);

        --------------------------------
        -- Check module id is valid --
        --------------------------------
        open csr_valid_module_type;
        fetch csr_valid_module_type into l_api_module_type;
        if csr_valid_module_type%notfound then
           close csr_valid_module_type;
           hr_ahk_shd.constraint_error('HR_API_HOOKS_FK1');
        end if;
--      #661588:-
        if l_api_module_type = 'AI' then
          close csr_valid_module_type;
          hr_utility.set_message(800,
                'PER_50041_TYPE_AI_NOT_ALLOWED');
          hr_utility.raise_error;
        end if;
--
        close csr_valid_module_type;

	hr_utility.set_location('Leaving: '||l_proc,10);
end chk_api_module_id;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_api_hook_type >-------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that api_hook_type is not null and exists on the HR_LOOKUPS table.
--    The combination of parent module id and api_hook_type must be unique within
--    the table. Also, api_hook_type must be validated against the parent module
--    attribute of api_module_type.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_id
--    p_api_module_id
--    p_api_hook_type
--    p_effective_date
--
--  Post Success:
--    Processing continues if the api_hook_type is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the api_hook_type is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_api_hook_type
       (p_api_hook_id           in      number,
        p_api_module_id         in number,
        p_api_hook_type         in varchar2,
        p_effective_date        in date
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_api_hook_type';
  l_api_module_id       number;
  l_api_module_type     varchar2(30);
  l_api_updating         boolean;
--
-- Declare a cursor that will check whether the passed
-- in hook type and module id form a unique combination
   cursor csr_valid_combo is
   select api_module_id from hr_api_hooks hah
   where hah.api_module_id = p_api_module_id
   and   hah.api_hook_type = p_api_hook_type;

-- Declare a cursor to retrieve the module type from
-- the HR_API_MODULES table, using the api_module_id as a key.
   cursor csr_get_module_type is
   select api_module_type from hr_api_modules
   where api_module_id = p_api_module_id;

--
--
begin
    hr_utility.set_location('Entering: '||l_proc,5);

    ----------------------------------
    -- Check api hook type not null --
    ----------------------------------
    hr_api.mandatory_arg_error
          (p_api_name => l_proc,
           p_argument =>  'p_api_hook_type',
           p_argument_value => p_api_hook_type);
    --
    -- Check if hook is being updated
    --
    l_api_updating := hr_ahk_shd.api_updating
                        (p_api_hook_id => p_api_hook_id);


    --
    -- Proceed with validation based on outcome of api_updating call.
    if ((l_api_updating and
        hr_ahk_shd.g_old_rec.api_hook_type <> p_api_hook_type) or
        (not l_api_updating)) then


       --------------------------------
       -- Check hook type is valid --
       --------------------------------

       if hr_api.not_exists_in_hr_lookups
           (p_effective_date       => p_effective_date,
            p_lookup_type          => 'API_HOOK_TYPE',
            p_lookup_code          => p_api_hook_type) then
           hr_ahk_shd.constraint_error('HR_API_HOOKS_CK1');
       end if;

       --------------------------------------------------------
       -- Check for unique Module id and hook type combo --
       --------------------------------------------------------
       open csr_valid_combo;
       fetch csr_valid_combo into l_api_module_id;

       if csr_valid_combo%found then
           close csr_valid_combo;
           hr_ahk_shd.constraint_error('HR_API_HOOKS_UK1');
       end if;

       close csr_valid_combo;

       -----------------------------------------------------------------
       -- Check that the module type and hook type form a valid combo --
       -----------------------------------------------------------------

       open csr_get_module_type;
       fetch csr_get_module_type into l_api_module_type;
       if ((p_api_hook_type in ('AI', 'AU', 'AD') and l_api_module_type <> 'RH')
            OR
           (p_api_hook_type in ('BP', 'AP')       and l_api_module_type <> 'BP'))

          THEN
          close csr_get_module_type;
          hr_utility.set_message(800,'PER_52129_AHK_WRONG_HOOK_TYPE');
          hr_utility.raise_error;
       end if;

       close csr_get_module_type;

    end if; -- end of api_updating? if
    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_api_hook_type;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_legislation_code >----------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Checks that the legislation_code is valid against the FND_TERRITORIES table.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_id
--    p_legislation_code
--
--  Post Success:
--    Processing continues if the legislation_code is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the legislation_code is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_legislation_code
       (p_api_hook_id           in      number,
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
--  -----------------------------------------------------------------
--  |-----------------------< chk_hook_package >-------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check the hook package is not null.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_id
--    p_hook_package
--
--  Post Success:
--    Processing continues if the hook_package is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the hook_package is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_hook_package
       (p_api_hook_id           in      number,
        p_hook_package      in      varchar2
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_hook_package';
  l_api_updating         boolean;
--
--
begin
     hr_utility.set_location('Entering: '||l_proc,5);

       --------------------------------
       -- Check hook package not null --
       --------------------------------
       hr_api.mandatory_arg_error
          (p_api_name => l_proc,
           p_argument =>  'p_hook_package',
           p_argument_value => p_hook_package);

    hr_utility.set_location('Leaving: '||l_proc,10);

end chk_hook_package;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_hook_procedure >------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the hook procedure is not null.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_id
--    p_hook_procedure
--
--  Post Success:
--    Processing continues if the hook_procedure is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the hook_procedure is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_hook_procedure
       (p_api_hook_id           in      number,
        p_hook_procedure      in      varchar2
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_hook_procedure';
  l_api_updating       boolean;
--

--
begin
     hr_utility.set_location('Entering: '||l_proc,5);

       --------------------------------
       -- Check hook procedure not null --
       --------------------------------
       hr_api.mandatory_arg_error
          (p_api_name => l_proc,
           p_argument =>  'p_hook_procedure',
           p_argument_value => p_hook_procedure);

     hr_utility.set_location('Leaving: '||l_proc,10);
end chk_hook_procedure;
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_hook_package_procedure >----------|
--  -----------------------------------------------------------------
--
--  Description:
--    Checks that the hook package and hook procedure form a unique combination
--    on the table.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--
--  Post Success:
--    Processing continues if the combination is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the combination is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_hook_package_procedure
       (p_api_hook_id           in      number,
        p_hook_package        in      varchar2,
        p_hook_procedure      in      varchar2
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_hook_procedure';
  l_api_module_id      number;
  l_api_updating         boolean;
--
-- Declare a cursor that will check whether the passed
-- in hook package and hook procedure form a unique combination
   cursor csr_valid_combo is
   select api_module_id from hr_api_hooks hah
   where hah.hook_package = p_hook_package
   and   hah.hook_procedure = p_hook_procedure;

--
begin
     hr_utility.set_location('Entering: '||l_proc,5);

    -- Check if hook is being updated
    l_api_updating := hr_ahk_shd.api_updating
                      (p_api_hook_id => p_api_hook_id);


    -- Proceed with validation based on outcome of api_updating call.
    if ((l_api_updating and
        hr_ahk_shd.g_old_rec.hook_procedure <> nvl(p_hook_procedure, hr_api.g_varchar2) and
        hr_ahk_shd.g_old_rec.hook_package <>   nvl(p_hook_package,   hr_api.g_varchar2) ) or
        (not l_api_updating)) then

       --------------------------------------------------------
       -- Check for unique hook package and hook procedure combo --
       --------------------------------------------------------
       open csr_valid_combo;
       fetch csr_valid_combo into l_api_module_id;

       if csr_valid_combo%found then
           close csr_valid_combo;
           hr_ahk_shd.constraint_error('HR_API_HOOKS_UK2');
       end if;

       close csr_valid_combo;

     end if;

     hr_utility.set_location('Leaving: '||l_proc,10);
end chk_hook_package_procedure;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_legislation_package >--------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check the package is valid by referencing it against the parent attribute
--    Data_within_business_group.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_id
--    p_api_module_id
--    p_legislation_package
--
--  Post Success:
--    Processing continues if the legislation_package is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the legislation_package is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_legislation_package
       (p_api_hook_id           in      number,
        p_api_module_id            in number,
        p_legislation_package      in      varchar2
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_legislation_package';
  l_data_within_business_group     hr_api_modules.data_within_business_group%TYPE;
  l_api_updating         boolean;
--
-- Setup cursor for to retrieve data within business group from parent
    cursor csr_get_data_within_bus_group is
      select data_within_business_group
      from hr_api_modules
      where api_module_id = p_api_module_id;
--
--
begin
    hr_utility.set_location('Entering: '||l_proc,5);

    -- Check if hook is being updated
    l_api_updating := hr_ahk_shd.api_updating
                      (p_api_hook_id => p_api_hook_id);

    -- Proceed with validation based on outcome of api_updating call.
    if ((l_api_updating and
        nvl(hr_ahk_shd.g_old_rec.legislation_package, hr_api.g_varchar2) <>
                                           nvl(p_legislation_package, hr_api.g_varchar2) ) or
        (not l_api_updating)) then

     ----------------------------------------
     -- Check legislation package is valid --
     ----------------------------------------
     if p_legislation_package is not null then
        open csr_get_data_within_bus_group;
        fetch csr_get_data_within_bus_group into l_data_within_business_group;

        if l_data_within_business_group = 'N' THEN
           close csr_get_data_within_bus_group;
           hr_utility.set_message(800,'PER_52131_AHK_LEG_PACK_INV');
           hr_utility.raise_error;
        end if;

        close csr_get_data_within_bus_group;
     end if;

    end if;
    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_legislation_package;
--
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_legislation_function >------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Checks that legislation_function is valid by referencing the parent
--    attribute data_within_business_group.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_id
--    p_api_module_id
--    p_legislation_function
--
--  Post Success:
--    Processing continues if the legislation_function is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the legislation_function is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_legislation_function
       (p_api_hook_id           in      number,
        p_api_module_id            in number,
        p_legislation_function     in      varchar2
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_legislation_function';
  l_data_within_business_group     hr_api_modules.data_within_business_group%TYPE;
  l_api_updating         boolean;
--
-- Setup cursor for to retrieve data within business group from parent
    cursor csr_get_data_within_bus_group is
      select data_within_business_group
      from hr_api_modules
      where api_module_id = p_api_module_id;
--
--
begin
     hr_utility.set_location('Entering: '||l_proc,5);

    -- Check if hook is being updated
    l_api_updating := hr_ahk_shd.api_updating
                      (p_api_hook_id => p_api_hook_id);

    -- Proceed with validation based on outcome of api_updating call.
    if ((l_api_updating and
        nvl(hr_ahk_shd.g_old_rec.legislation_function, hr_api.g_varchar2) <>
                                  nvl(p_legislation_function, hr_api.g_varchar2) ) or
        (not l_api_updating)) then

     ----------------------------------------
     -- Check legislation function is valid --
     ----------------------------------------
     if p_legislation_function is not null then
        open csr_get_data_within_bus_group;
        fetch csr_get_data_within_bus_group into l_data_within_business_group;

        if (l_data_within_business_group = 'N' AND
           p_legislation_function is not null)  THEN
           close csr_get_data_within_bus_group;
           hr_utility.set_message(800,'PER_52132_AHK_LEG_FUNC_INV');
           hr_utility.raise_error;
        end if;

        close csr_get_data_within_bus_group;
     end if;

    end if;
    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_legislation_function;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_leg_package_function >-------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the combination of leg_package and leg_function form a unique
--    combination on the table.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_id
--    p_api_module_id
--    p_legislation_package
--    p_legislation_function
--
--  Post Success:
--    Processing continues if the combination is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the combination is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_leg_package_function
       (p_api_hook_id           in      number,
        p_api_module_id            in number,
        p_legislation_package      in      varchar2,
        p_legislation_function     in      varchar2
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_legislation_function';
--
--
begin
     hr_utility.set_location('Entering: '||l_proc,5);

     --------------------------------------------------
     -- Check Legislation Function and Package Combo --
     --------------------------------------------------

     if (p_legislation_function is not null and p_legislation_package is null) OR
        (p_legislation_function is     null and p_legislation_package is not null)
        then
           hr_ahk_shd.constraint_error('HR_API_HOOKS_CK2');
     end if;

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_leg_package_function;
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_delete >-------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Checks if the hook has any children.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_id
--
--  Post Success:
--    Processing continues if the hook has no children.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the hook has children.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_delete
       (p_api_hook_id		in	number
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_delete';
  l_api_hook_id        number;
--
-- Setup cursor to check for children
  cursor csr_check_for_child is
    select api_hook_id
    from hr_api_hook_calls hahc
    where hahc.api_hook_id = p_api_hook_id;
--
--
begin
     hr_utility.set_location('Entering: '||l_proc,5);

     -- We don't have to check for valid hook id as this is done by the lck proc
     --------------------------------------
     -- Check if hook has any children --
     --------------------------------------

     open csr_check_for_child;
     fetch csr_check_for_child into l_api_hook_id;

     if csr_check_for_child%found then
         close csr_check_for_child;
         hr_utility.set_message(800,'PER_52148_AHK_CANNOT_DEL_ROW');
         hr_utility.raise_error;
     end if;

     close csr_check_for_child;

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_delete;
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_ahk_shd.g_rec_type,
                          p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
  hr_api.set_security_group_id(p_security_group_id => 0);
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Call all supporting business operations
  --
  -- Validate the Module Id
       chk_api_module_id
       (p_api_hook_id           => p_rec.api_hook_id,
        p_api_module_id              => p_rec.api_module_id);

  -- Validate the API Hook Type
       chk_api_hook_type
       (p_api_hook_id           => p_rec.api_hook_id,
        p_api_module_id              => p_rec.api_module_id,
        p_api_hook_type              => p_rec.api_hook_type,
        p_effective_date             => p_effective_date);
  --
  -- Validate the hook package
       chk_hook_package
       (p_api_hook_id           => p_rec.api_hook_id,
        p_hook_package               => p_rec.hook_package);

  -- Validate the hook procedure
       chk_hook_procedure
       (p_api_hook_id           => p_rec.api_hook_id,
        p_hook_procedure             => p_rec.hook_procedure);

  -- Validate the hook proc and pack combo.
       chk_hook_package_procedure
       (p_api_hook_id           => p_rec.api_hook_id,
        p_hook_package        => p_rec.hook_package,
        p_hook_procedure      => p_rec.hook_procedure);

  -- Validate Legislation Code
     chk_legislation_code
       (p_api_hook_id           => p_rec.api_hook_id,
        p_legislation_code           => p_rec.legislation_code);
  --
  -- Validate Legislation Package
     chk_legislation_package
       (p_api_hook_id           => p_rec.api_hook_id,
        p_api_module_id            => p_rec.api_module_id,
        p_legislation_package      => p_rec.legislation_package
       );
  --
  -- Validate Legislation Function
     chk_legislation_function
       (p_api_hook_id           => p_rec.api_hook_id,
        p_api_module_id            => p_rec.api_module_id,
        p_legislation_function     => p_rec.legislation_function
       );

  --
  -- Validate Legislation Package and Function combination
     chk_leg_package_function
       (p_api_hook_id           => p_rec.api_hook_id,
        p_api_module_id            => p_rec.api_module_id,
        p_legislation_package      => p_rec.legislation_package,
        p_legislation_function     => p_rec.legislation_function
       );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_ahk_shd.g_rec_type,
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
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Call all supporting business operations
  --
  -- Validate the API Hook Type
       chk_api_hook_type
       (p_api_hook_id           => p_rec.api_hook_id,
        p_api_module_id              => p_rec.api_module_id,
        p_api_hook_type              => p_rec.api_hook_type,
        p_effective_date             => p_effective_date);
  --
  -- Validate the hook package
       chk_hook_package
       (p_api_hook_id           => p_rec.api_hook_id,
        p_hook_package               => p_rec.hook_package);

  -- Validate the hook procedure
       chk_hook_procedure
       (p_api_hook_id           => p_rec.api_hook_id,
        p_hook_procedure             => p_rec.hook_procedure);

  -- Validate the hook proc and pack combo.
       chk_hook_package_procedure
       (p_api_hook_id           => p_rec.api_hook_id,
        p_hook_package        => p_rec.hook_package,
        p_hook_procedure      => p_rec.hook_procedure);
  --
  -- Validate Legislation Package
     chk_legislation_package
       (p_api_hook_id           => p_rec.api_hook_id,
        p_api_module_id            => p_rec.api_module_id,
        p_legislation_package      => p_rec.legislation_package
       );
  --
  -- Validate Legislation Function
     chk_legislation_function
       (p_api_hook_id           => p_rec.api_hook_id,
        p_api_module_id            => p_rec.api_module_id,
        p_legislation_function     => p_rec.legislation_function
       );
  --
  -- Validate Legislation Package and Function combination
     chk_leg_package_function
       (p_api_hook_id           => p_rec.api_hook_id,
        p_api_module_id            => p_rec.api_module_id,
        p_legislation_package      => p_rec.legislation_package,
        p_legislation_function     => p_rec.legislation_function
       );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_ahk_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
    chk_delete(p_api_hook_id   =>   p_rec.api_hook_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_ahk_bus;

/
