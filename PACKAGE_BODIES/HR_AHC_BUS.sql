--------------------------------------------------------
--  DDL for Package Body HR_AHC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AHC_BUS" as
/* $Header: hrahcrhi.pkb 115.7 2002/12/02 14:52:05 apholt ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_ahc_bus.';  -- Global package name
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_non_updateable_args >--------------|
--  -----------------------------------------------------------------
--
Procedure chk_non_updateable_args
  (p_rec            in hr_ahc_shd.g_rec_type
  ,p_effective_date in date
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
  if not hr_ahc_shd.api_updating
      (p_api_hook_call_id          => p_rec.api_hook_call_id,
       p_object_version_number     => p_rec.object_version_number
      ) then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.api_hook_id, hr_api.g_number) <>
     nvl(hr_ahc_shd.g_old_rec.api_hook_id
        ,hr_api.g_number
        ) then
     l_argument := 'api_hook_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.api_hook_call_type, hr_api.g_varchar2) <>
     nvl(hr_ahc_shd.g_old_rec.api_hook_call_type
        ,hr_api.g_varchar2
        ) then
     l_argument := 'api_hook_call_type';
     raise l_error;
  end if;
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(hr_ahc_shd.g_old_rec.legislation_code
        ,hr_api.g_varchar2
        ) then
     l_argument := 'legislation_code';
     raise l_error;
  end if;
  --
  if nvl(p_rec.application_id, hr_api.g_number) <>
     nvl(hr_ahc_shd.g_old_rec.application_id
        ,hr_api.g_number
        ) then
     l_argument := 'application_id';
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
--  |-----------------------< chk_api_hook_id >-------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the p_api_hook_id is not null and refers to a valid parent row.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_call_id
--    p_api_hook_id
--
--  Post Success:
--    Processing continues if the api_hook_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the api_hook_id is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_api_hook_id
       (p_api_hook_call_id           in      number,
        p_api_hook_id                in      number
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_api_hook_id';
  l_api_hook_id               number;

  -- Setup cursor for valid hook id check
  cursor csr_valid_hook_id is
    select api_hook_id
    from hr_api_hooks
    where api_hook_id = p_api_hook_id;

--
begin
    hr_utility.set_location('Entering: '||l_proc,5);
        --
        --------------------------------
        -- Check hook id not null --
        --------------------------------
        hr_api.mandatory_arg_error
           (p_api_name => l_proc,
            p_argument =>  'p_api_hook_id',
            p_argument_value => p_api_hook_id);

        --------------------------------
        -- Check hook id is valid --
        --------------------------------
        open csr_valid_hook_id;
        fetch csr_valid_hook_id into l_api_hook_id;
        if csr_valid_hook_id%notfound then
           close csr_valid_hook_id;
           hr_ahc_shd.constraint_error('HR_API_HOOK_CALLS_FK1');
        end if;
        close csr_valid_hook_id;

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_api_hook_id;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_api_hook_call_type >--------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the api_hook_call_type is not null and validate it against the
--    HR_LOOKUPS table.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_call_id
--    p_api_hook_call_type
--    p_effective_date
--
--  Post Success:
--    Processing continues if the api_hook_call_type is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the api_hook_call_type is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_api_hook_call_type
       (p_api_hook_call_id           in      number,
        p_api_hook_call_type         in      varchar2,
        p_effective_date             in      date
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_api_hook_call_type';
 l_lookup_code        hr_lookups.lookup_code%TYPE;
--
--
begin
    hr_utility.set_location('Entering: '||l_proc,5);
        --
        --------------------------------
        -- Check hook call type not null --
        --------------------------------
        hr_api.mandatory_arg_error
           (p_api_name => l_proc,
            p_argument =>  'p_api_hook_call_type',
            p_argument_value => p_api_hook_call_type);

       --------------------------------
       -- Check hook call type is valid --
       --------------------------------
       if hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_effective_date,
            p_lookup_type    => 'API_HOOK_CALL_TYPE',
            p_lookup_code    => p_api_hook_call_type) then
           hr_ahc_shd.constraint_error('HR_API_HOOK_CALLS_CK1');
       end if;

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_api_hook_call_type;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_legislation_code >----------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Validate the legislation_code against the FND_TERRITORIES table.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_call_id
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
       (p_api_hook_call_id           in      number,
        p_legislation_code           in      varchar2
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
--  |-----------------------< chk_sequence >-------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that the sequence is within the correct range, dependent on
--    LEGISLATION_CODE and APPLICATION_ID.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_call_id
--    p_sequence
--    p_legislation_code
--    p_application_id
--    p_object_version_number
--
--  Post Success:
--    Processing continues if the sequence is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the sequence is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_sequence
       (p_api_hook_call_id           in      number,
        p_sequence                   in      number,
        p_legislation_code           in      varchar2,
        p_application_id             in      number,
        p_object_version_number      in      number
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_sequence';
  l_api_updating       boolean;

--
begin
    hr_utility.set_location('Entering: '||l_proc,5);

    -- Check if hook is being updated
    l_api_updating := hr_ahc_shd.api_updating
                      (p_api_hook_call_id => p_api_hook_call_id,
                       p_object_version_number => p_object_version_number);

    -- Proceed with validation based on outcome of api_updating call.
    if ((l_api_updating and
        hr_ahc_shd.g_old_rec.sequence <> nvl(p_sequence, hr_api.g_number) ) or
        (not l_api_updating)) then


       if ( p_legislation_code is not null  and
            (p_sequence < 1500 or p_sequence > 1999) ) then
           hr_utility.set_message(800,'PER_52145_AHC_INVALID_SEQ1');
           hr_utility.raise_error;
       elsif( p_legislation_code is null) then
          if (p_application_id is null    and
             (p_sequence >= 1000 and p_sequence <= 1999) )then
             hr_utility.set_message(800,'PER_52146_AHC_INVALID_SEQ2');
             hr_utility.raise_error;
          elsif (p_application_id is not null and
                (p_sequence < 1000 or p_sequence > 1499)) then
             hr_utility.set_message(800,'PER_289089_AHC_INVALID_SEQ3');
             hr_utility.raise_error;
          end if;
       end if;
    end if;

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_sequence;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_enabled_flag >-------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that enabled flag is not null and validate it against HR_LOOKUPS.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_call_id
--    p_enabled_flag
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Processing continues if the enabled_flag is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the enabled_flag is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_enabled_flag
       (p_api_hook_call_id           in      number,
        p_enabled_flag               in      varchar2,
        p_object_version_number      in      number,
        p_effective_date             in      date
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_enabled_flag';
  l_application_id     hr_lookups.application_id%TYPE;
  l_api_updating       boolean;
--
--
begin
    hr_utility.set_location('Entering: '||l_proc,5);

    --------------------------------
    -- Check enabled flag type not null --
    --------------------------------
    hr_api.mandatory_arg_error
        (p_api_name => l_proc,
         p_argument =>  'p_enabled_flag',
         p_argument_value => p_enabled_flag);

    -- Check if hook is being updated
    l_api_updating := hr_ahc_shd.api_updating
                      (p_api_hook_call_id => p_api_hook_call_id,
                       p_object_version_number => p_object_version_number);

    -- Proceed with validation based on outcome of api_updating call.
    if ((l_api_updating and
        hr_ahc_shd.g_old_rec.enabled_flag <> nvl(p_enabled_flag, hr_api.g_varchar2) ) or
        (not l_api_updating)) then

        --------------------------------
        -- Check enabled is valid --
        --------------------------------
        if hr_api.not_exists_in_hr_lookups
           (p_effective_date        => p_effective_date,
            p_lookup_type           => 'YES_NO',
            p_lookup_code           => p_enabled_flag) then
            hr_utility.set_message(800,'PER_52136_AHC_ENAB_FLAG_INV');
            hr_utility.raise_error;
        end if;

    end if;
    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_enabled_flag;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_call_package >---------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Validate the call_package against the hook call type.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_call_id
--    p_call_package
--    p_api_hook_call_type
--    p_object_version_number
--
--  Post Success:
--    Processing continues if the call_package is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the call_package is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_call_package
       (p_api_hook_call_id           in      number,
        p_call_package               in      varchar2,
        p_api_hook_call_type         in      varchar2,
        p_object_version_number      in      number
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_call_package';
  l_api_updating       boolean;
--
begin
    hr_utility.set_location('Entering: '||l_proc,5);

    -- Check if hook is being updated
    l_api_updating := hr_ahc_shd.api_updating
                      (p_api_hook_call_id => p_api_hook_call_id,
                       p_object_version_number => p_object_version_number);

    -- Proceed with validation based on outcome of api_updating call.
    if ((l_api_updating and
         nvl(hr_ahc_shd.g_old_rec.call_package, hr_api.g_varchar2) <>
         nvl(p_call_package, hr_api.g_varchar2) )             or
        (not l_api_updating)) then

      if (p_api_hook_call_type = 'PP' and p_call_package is null) OR
         (p_api_hook_call_type = 'FF' and p_call_package is not null)
      then
         hr_utility.set_message(800,'PER_52137_AHC_CALL_PACK_INV');
         hr_utility.raise_error;
      end if;
    end if;

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_call_package;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_call_procedure >------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Validate the call_procedure against the hook call type.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_call_id
--    p_call_procedure
--    p_api_hook_call_type
--    p_object_version_number
--
--  Post Success:
--    Processing continues if the call_procedure is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the call_procedure is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_call_procedure
       (p_api_hook_call_id           in      number,
        p_call_procedure             in      varchar2,
        p_api_hook_call_type         in      varchar2,
        p_object_version_number      in      number
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_call_procedure';
  l_api_updating       boolean;
--
begin
    hr_utility.set_location('Entering: '||l_proc,5);

    -- Check if hook is being updated
    l_api_updating := hr_ahc_shd.api_updating
                      (p_api_hook_call_id => p_api_hook_call_id,
                       p_object_version_number => p_object_version_number);

    -- Proceed with validation based on outcome of api_updating call.
    if ((l_api_updating and
         nvl(hr_ahc_shd.g_old_rec.call_procedure, hr_api.g_varchar2) <>
         nvl(p_call_procedure, hr_api.g_varchar2) )             or
        (not l_api_updating)) then

       if (p_api_hook_call_type = 'PP' and p_call_procedure is null) OR
          (p_api_hook_call_type = 'FF' and p_call_procedure is not null)
       then
          hr_utility.set_message(800,'PER_52138_AHC_CALL_PROC_INV');
          hr_utility.raise_error;
       end if;

    end if;

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_call_procedure;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_call_pp_combination >-------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Validate that call_package, call_procedure, legislation_code,
--    application_id and api_hook_id form a unique combination on the table
--    when hook_call_type = 'PP'
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_call_id
--    p_api_hook_call_type
--    p_legislation_code
--    p_application_id
--    p_call_package
--    p_call_procedure
--    p_api_hook_id
--    p_object_version_number
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
Procedure chk_call_pp_combination
       (p_api_hook_call_id           in      number,
        p_api_hook_call_type         in      varchar2,
        p_legislation_code           in      varchar2,
        p_application_id             in      number,
        p_call_package               in      varchar2,
        p_call_procedure             in      varchar2,
        p_api_hook_id                in      number,
        p_object_version_number      in      number
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_call_pp_combination';
  l_api_hook_call_id           number;
  l_api_updating               boolean;
--
-- Declare a cursor that will check whether the passed
-- in hook package and hook procedure form a unique combination

   cursor csr_valid_combo is
   select api_hook_call_id from hr_api_hook_calls
   where api_hook_id = p_api_hook_id
   and   nvl(legislation_code,'X')
       = nvl(p_legislation_code,'X')
   and   nvl(application_id, -987123654)
       = nvl(p_application_id,-987123654)
   and   nvl(call_package, 'X')
       = nvl(p_call_package, 'X')
   and   nvl(call_procedure, 'X')
       = nvl(p_call_procedure, 'X');

--
begin
    hr_utility.set_location('Entering: '||l_proc,5);
    -- Check if hook call is being updated
    l_api_updating := hr_ahc_shd.api_updating
                      (p_api_hook_call_id => p_api_hook_call_id,
                       p_object_version_number => p_object_version_number);

    -- Proceed with validation based on outcome of api_updating call.
    if (  (l_api_updating and
           (hr_ahc_shd.g_old_rec.call_package <> p_call_package or
            hr_ahc_shd.g_old_rec.call_procedure <> p_call_procedure)
          )
           or
          (not l_api_updating) ) then
       hr_utility.set_location('**'||hr_ahc_shd.g_old_rec.call_package,99);
       hr_utility.set_location('**'||hr_ahc_shd.g_old_rec.call_procedure,99);

       if p_api_hook_call_type = 'PP' then
         ----------------------------------------------------------------------------
         -- Check for combination of hook call id, leg code, call pack, call proc --
         ----------------------------------------------------------------------------
         hr_utility.set_location('App_id:'||to_char(p_application_id),1);
         hr_utility.set_location('Leg:'||p_legislation_code,2);
         hr_utility.set_location('Pkg:'||p_call_package,3);
         hr_utility.set_location('prc:'||p_call_procedure,4);
         open csr_valid_combo;
         fetch csr_valid_combo into l_api_hook_call_id;

         if csr_valid_combo%found then
             close csr_valid_combo;
             hr_ahc_shd.constraint_error('HR_API_HOOK_CALLS_UK1');
         end if;

         close csr_valid_combo;
       end if;

    end if;
    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_call_pp_combination;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_formula_id >-----------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Not yet implemented
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--
--  Post Success:
--    Processing continues if the formula_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the formula_id is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_formula_id
       (p_api_hook_call_id           in      number
        ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_formula_id';

--
begin
    hr_utility.set_location('Entering: '||l_proc,5);

--  There is no formula id in the table for the first version.
--  It will be added when FORMULA calls are possible.


    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_formula_id;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_call_ff_combination >-----------|
--  -----------------------------------------------------------------
--
--  Description:
--    Not yet implemented.
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
Procedure chk_call_ff_combination
       (p_api_hook_call_id           in      number
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_call_ff_combination';

--
begin
    hr_utility.set_location('Entering: '||l_proc,5);

--  There is no formula id in the table for the first version.
--  It will be added when FORMULA calls are possible.

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_call_ff_combination;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_pre_processor_date >--------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that pre_processor_date is null on insert.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_call_id
--    p_pre_processor_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if the pre_processor_date is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the pre_processor_date is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_pre_processor_date
       (p_api_hook_call_id           in      number,
        p_pre_processor_date         in      date,
        p_object_version_number      in      number
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_pre_processor_date';
  l_api_updating       boolean;
--
begin
    hr_utility.set_location('Entering: '||l_proc,5);

    -- Check if hook is being updated
    l_api_updating := hr_ahc_shd.api_updating
                      (p_api_hook_call_id => p_api_hook_call_id,
                       p_object_version_number => p_object_version_number);

    if (not l_api_updating and p_pre_processor_date is not null) then
        hr_utility.set_message(800,'PER_52144_AHC_PP_DATE_NOT_NULL');
        hr_utility.raise_error;
    end if;

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_pre_processor_date;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_encoded_error >-------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that encoded error is null on insert and then validate against
--    status for further update calls.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_call_id
--    p_encoded_error
--    p_status
--    p_object_version_number
--
--  Post Success:
--    Processing continues if the encoded_error is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the encoded_error is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_encoded_error
       (p_api_hook_call_id           in      number,
        p_encoded_error              in      varchar2,
        p_status                     in      varchar2,
        p_object_version_number      in      number
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_encoded_error';
  l_api_updating       boolean;
--
begin
    hr_utility.set_location('Entering: '||l_proc,5);

    -- Check if hook is being updated
    l_api_updating := hr_ahc_shd.api_updating
                      (p_api_hook_call_id => p_api_hook_call_id,
                       p_object_version_number => p_object_version_number);

   -- Proceed with validation based on outcome of api_updating call.
    if (not l_api_updating and p_encoded_error is not null)
      then
        hr_utility.set_message(800,'PER_52142_AHC_ENC_ERR_NOT_NULL');
        hr_utility.raise_error;
    elsif
       (l_api_updating and
        (p_status = 'N' or p_status = 'V') and
        p_encoded_error is not null)
      then
        hr_utility.set_message(800,'PER_52143_AHC_E_ERR_NOT_NULL2');
        hr_utility.raise_error;
    end if;

    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_encoded_error;
--
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_status >-------------------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Check that status is not null, N on insert and then validate against
--    HR_LOOKUPS for subsequent update calls.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_api_hook_call_id
--    p_status
--    p_object_version_number
--    p_effective_date
--
--  Post Success:
--    Processing continues if the Status is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the Status is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_status
       (p_api_hook_call_id           in      number,
        p_status                     in      varchar2,
        p_object_version_number      in      number,
        p_effective_date             in      date
       ) is
--
--   Local declarations
  l_proc               varchar2(72) := g_package||'chk_status';
  l_lookup_code        hr_lookups.lookup_code%TYPE;
  l_api_updating       boolean;
--
--
begin
    hr_utility.set_location('Entering: '||l_proc,5);

    --------------------------------
    -- Check status not null --
    --------------------------------
    hr_api.mandatory_arg_error
        (p_api_name => l_proc,
         p_argument =>  'p_status',
         p_argument_value => p_status);

    -- Check if hook is being updated
    l_api_updating := hr_ahc_shd.api_updating
                      (p_api_hook_call_id => p_api_hook_call_id,
                       p_object_version_number => p_object_version_number);

   -- Proceed with validation based on outcome of api_updating call.
    if ((l_api_updating and
         hr_ahc_shd.g_old_rec.status <> nvl(p_status, hr_api.g_varchar2)) or
         (not l_api_updating)) then

       --------------------------------
       -- Check status is valid --
       --------------------------------
       if hr_api.not_exists_in_hr_lookups
             (p_effective_date      => p_effective_date,
              p_lookup_type         => 'API_HOOK_CALL_STATUS',
              p_lookup_code         => p_status) then
           hr_utility.set_message(800,'PER_52140_AHC_STATUS_INV');
           hr_utility.raise_error;
       end if;

       --------------------------------------
       -- Status must be 'N' during insert --
       --------------------------------------
       if (not l_api_updating and p_status <> 'N') then
          hr_utility.set_message(800,'PER_52141_AHC_INV_STA_ON_INS');
          hr_utility.raise_error;
       end if;

    end if;
    hr_utility.set_location('Leaving: '||l_proc,10);
end chk_status;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_application_id >-----------------------------|
-- ----------------------------------------------------------------------------
--  Description:
--    Indicates if the extra logic should be called on behalf of another
--    Oracle Application.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--   p_application_id
--
--  Post Success:
--    Processing continues if the application_id is valid.
--
--  Post Failure:
--    An application_error is raised, and processing is terminated if the
--    application_id is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
-- ----------------------------------------------------------------------------
PROCEDURE chk_application_id (p_application_id IN number) IS
--
-- Cursor to determine if the application_id is valid
CURSOR csr_check_app_id IS
  SELECT 'Y'
    FROM fnd_application app
   WHERE app.application_id = p_application_id;
--
l_exists varchar2(1);
--
BEGIN
  --
  IF p_application_id IS NOT NULL THEN
     --
     -- Check if application_id is valid
     OPEN csr_check_app_id;
     FETCH csr_check_app_id INTO l_exists;
     --
     IF csr_check_app_id%NOTFOUND THEN
        -- Application does not exist
        CLOSE csr_check_app_id;
        hr_utility.set_message(800,'PER_289085_AHC_INVALID_APPL');
        hr_utility.raise_error;
     END IF;
     CLOSE csr_check_app_id;
     --
  END IF;
  --
END chk_application_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_app_install_status >-------------------------|
-- ----------------------------------------------------------------------------
--  Description:
--    Indicates when the application hook calls should be executed, based
--    on the application's install status.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--   p_app_install_status
--   p_application_id
--   p_effective_date
--
--  Post Success:
--    Processing continues if the app_install_status is valid.
--
--  Post Failure:
--    An application_error is raised, and processing is terminated if the
--    app_install_status is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
-- ----------------------------------------------------------------------------
PROCEDURE chk_app_install_status
  (p_app_install_status in varchar2
  ,p_application_id     in number
  ,p_effective_date     in date) IS
--
BEGIN
  --
  IF ((p_application_id IS NULL) and (p_app_install_status IS NOT NULL)) THEN
     --
     -- Error - app_install_status must be null when app_id is null
     hr_utility.set_message(800,'PER_289086_AHC_INST_STAT_NULL');
     hr_utility.raise_error;
     --
  ELSIF ((p_application_id IS NOT NULL) and (p_app_install_status IS NULL)) THEN
     --
     -- Error - app_install_status is mandatory when app_id is not null
     hr_utility.set_message(800,'PER_289087_AHC_MAND_INSTALL_ST');
     hr_utility.raise_error;
  ELSE
     -- combination of application_id and app_install_status is ok
     IF p_app_install_status IS NOT NULL THEN
        -- validate against HR_LOOKUPS
        if hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_effective_date,
            p_lookup_type    => 'APP_INSTALL_STATUS',
            p_lookup_code    => p_app_install_status) then
           hr_utility.set_message(800,'PER_289088_AHC_INST_STATUS_ERR');
           hr_utility.raise_error;
        end if;
     END IF;
  END IF;
  --
END chk_app_install_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in hr_ahc_shd.g_rec_type,
                          p_effective_date in date) is
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
  hr_utility.set_location('Entering:'||l_proc, 6);
  --
  -- Call all supporting business operations
  --
  -- Validate the api_hook_id
       chk_api_hook_id
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_api_hook_id              => p_rec.api_hook_id);

  -- Validate the hook call type
       chk_api_hook_call_type
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_api_hook_call_type              => p_rec.api_hook_call_type,
        p_effective_date             => p_effective_date);

  -- Validate the legislation_code
       chk_legislation_code
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_legislation_code              => p_rec.legislation_code);

  -- validate the application_id
       chk_application_id
       (p_application_id            => p_rec.application_id);

  -- validate the application_install_status
       chk_app_install_status
       (p_app_install_status => p_rec.app_install_status
       ,p_application_id     => p_rec.application_id
       ,p_effective_date     => p_effective_date);

  -- Validate the sequence
       chk_sequence
       (p_api_hook_call_id          => p_rec.api_hook_call_id,
        p_sequence                  => p_rec.sequence,
        p_legislation_code          => p_rec.legislation_code,
        p_application_id            => p_rec.application_id,
        p_object_version_number     => p_rec.object_version_number);

  -- Validate the enabled_flag
       chk_enabled_flag
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_enabled_flag              => p_rec.enabled_flag,
        p_object_version_number     => p_rec.object_version_number,
        p_effective_date            => p_effective_date);

  -- Validate the call_package
       chk_call_package
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_call_package              => p_rec.call_package,
        p_api_hook_call_type        => p_rec.api_hook_call_type,
        p_object_version_number     => p_rec.object_version_number);

  -- Validate the call_procedure
       chk_call_procedure
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_call_procedure              => p_rec.call_procedure,
        p_api_hook_call_type        => p_rec.api_hook_call_type,
        p_object_version_number     => p_rec.object_version_number);

  -- Validate the call_pp_combination
       chk_call_pp_combination
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_api_hook_call_type         => p_rec.api_hook_call_type,
        p_legislation_code           => p_rec.legislation_code,
        p_application_id             => p_rec.application_id,
        p_call_package               => p_rec.call_package,
        p_call_procedure             => p_rec.call_procedure,
        p_api_hook_id                => p_rec.api_hook_id,
        p_object_version_number      => p_rec.object_version_number);

/*******************************************************************************
* These two calls will be commented out for the first version. They will be
* added back in when FORMULA calls are possible.
********************************************************************************
*
* -- Validate the formula_id
*      chk_formula_id
*      (p_api_hook_call_id           => p_rec.api_hook_call_id,
*       p_formula_id                 => p_rec.formula_id);
*
* -- Validate the call_ff_combination
*      chk_call_ff_combination
*      (p_api_hook_call_id           => p_rec.api_hook_call_id);
*
*
*******************************************************************************/

  -- Validate the pre_processor_date
       chk_pre_processor_date
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_pre_processor_date              => p_rec.pre_processor_date,
        p_object_version_number      => p_rec.object_version_number);

  -- Validate the status
       chk_status
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_status                     => p_rec.status,
        p_object_version_number      => p_rec.object_version_number,
        p_effective_date             => p_effective_date);

  -- Validate the encoded_error
       chk_encoded_error
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_encoded_error              => p_rec.encoded_error,
        p_status                     => p_rec.status,
        p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in hr_ahc_shd.g_rec_type,
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
  hr_utility.set_location('Entering:'||l_proc, 6);
  --
  -- Check that non-updateable columns have not been updated
  chk_non_updateable_args
   (p_effective_date  => p_effective_date
   ,p_rec             => p_rec);
  --
  -- Call all supporting business operations
  --
  -- validate the application_install_status
     chk_app_install_status
     (p_app_install_status => p_rec.app_install_status
     ,p_application_id     => p_rec.application_id
     ,p_effective_date     => p_effective_date);

  -- Validate the sequence
       chk_sequence
       (p_api_hook_call_id          => p_rec.api_hook_call_id,
        p_sequence                  => p_rec.sequence,
        p_legislation_code          => p_rec.legislation_code,
        p_application_id            => p_rec.application_id,
        p_object_version_number     => p_rec.object_version_number);

  -- Validate the enabled_flag
       chk_enabled_flag
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_enabled_flag              => p_rec.enabled_flag,
        p_object_version_number     => p_rec.object_version_number,
        p_effective_date            => p_effective_date);

  -- Validate the call_package
       chk_call_package
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_call_package              => p_rec.call_package,
        p_api_hook_call_type        => p_rec.api_hook_call_type,
        p_object_version_number     => p_rec.object_version_number);

  -- Validate the call_procedure
       chk_call_procedure
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_call_procedure              => p_rec.call_procedure,
        p_api_hook_call_type        => p_rec.api_hook_call_type,
        p_object_version_number     => p_rec.object_version_number);

  -- Validate the call_pp_combination
       chk_call_pp_combination
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_api_hook_call_type         => p_rec.api_hook_call_type,
        p_legislation_code           => p_rec.legislation_code,
        p_application_id             => p_rec.application_id,
        p_call_package               => p_rec.call_package,
        p_call_procedure             => p_rec.call_procedure,
        p_api_hook_id                => p_rec.api_hook_id,
        p_object_version_number     => p_rec.object_version_number);
--
/*******************************************************************************
* These two calls will be commented out for the first version. They will be
* added back in when FORMULA calls are possible.
********************************************************************************
*
* -- Validate the formula_id
*      chk_formula_id
*      (p_api_hook_call_id           => p_rec.api_hook_call_id,
*       p_formula_id                 => p_rec.formula_id);
*
* -- Validate the call_ff_combination
*      chk_call_ff_combination
*      (p_api_hook_call_id           => p_rec.api_hook_call_id);
*
*
*******************************************************************************/
--
  -- Validate the pre_processor_date
       chk_pre_processor_date
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_pre_processor_date              => p_rec.pre_processor_date,
        p_object_version_number      => p_rec.object_version_number);

  -- Validate the status
       chk_status
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_status                     => p_rec.status,
        p_object_version_number      => p_rec.object_version_number,
        p_effective_date             => p_effective_date);
  --
  -- Validate the encoded_error
       chk_encoded_error
       (p_api_hook_call_id           => p_rec.api_hook_call_id,
        p_encoded_error              => p_rec.encoded_error,
        p_status                     => p_rec.status,
        p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in hr_ahc_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_ahc_bus;

/
