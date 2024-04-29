--------------------------------------------------------
--  DDL for Package Body FF_FFP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FFP_BUS" as
/* $Header: ffffprhi.pkb 120.1 2005/10/05 01:51 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ff_ffp_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_function_id                 number         default null;
g_sequence_number             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_function_id                          in number
  ,p_sequence_number                      in number
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- ff_function_parameters and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ff_function_parameters ffp
         , ff_functions fff
     where ffp.function_id = fff.function_id
       and ffp.function_id = p_function_id
       and ffp.sequence_number = p_sequence_number
       and pbg.business_group_id = fff.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'function_id'
    ,p_argument_value     => p_function_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'sequence_number'
    ,p_argument_value     => p_sequence_number
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'FUNCTION_ID')
      ,p_associated_column2
        => nvl(p_associated_column2,'SEQUENCE_NUMBER')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  end if;
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
  (p_function_id                          in     number
  ,p_sequence_number                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- ff_function_parameters and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , ff_function_parameters ffp
         , ff_functions fff
     where ffp.function_id = fff.function_id
       and ffp.function_id = p_function_id
       and ffp.sequence_number = p_sequence_number
       and pbg.business_group_id = fff.business_group_id;
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
    ,p_argument           => 'function_id'
    ,p_argument_value     => p_function_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'sequence_number'
    ,p_argument_value     => p_sequence_number
    );
  --
  if (( nvl(ff_ffp_bus.g_function_id, hr_api.g_number)
       = p_function_id)
  and ( nvl(ff_ffp_bus.g_sequence_number, hr_api.g_number)
       = p_sequence_number)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ff_ffp_bus.g_legislation_code;
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
    ff_ffp_bus.g_function_id                 := p_function_id;
    ff_ffp_bus.g_sequence_number             := p_sequence_number;
    ff_ffp_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date               in date
  ,p_rec in ff_ffp_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ff_ffp_shd.api_updating
      (p_function_id                       => p_rec.function_id
      ,p_sequence_number                   => p_rec.sequence_number
      ,p_object_version_number             => p_rec.object_version_number
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
End chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_function_id >-----------------------------|
-- ----------------------------------------------------------------------------
procedure chk_function_id
(p_function_id     in number
) is
--
cursor csr_function_id is
select NULL
from   FF_FUNCTIONS ffn
where  ffn.function_id = p_function_id;
--
l_proc   varchar2(100) := g_package || 'chk_function_id';
l_exists varchar2(1);

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- FUNCTION_ID is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'FUNCTION_ID'
  ,p_argument_value =>  p_function_id
  );
  --
  open csr_function_id;
  fetch csr_function_id into l_exists;
  if csr_function_id%notfound then
    close csr_function_id;
    ff_ffp_shd.constraint_error('FF_FUNCTION_PARAMETERS_FK1');
  end if;
  close csr_function_id;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTION_PARAMETERS.FUNCTION_ID'
       ) then
      raise;
    end if;
  when others then
    if csr_function_id%isopen then
      close csr_function_id;
    end if;
    raise;
end chk_function_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_class >-----------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_class
(p_effective_date               in date
,p_class                        in varchar2
) is
--
l_proc   varchar2(100) := g_package || 'chk_class';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- CLASS is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'CLASS'
  ,p_argument_value =>  p_class
  );

  if hr_api.not_exists_in_hrstanlookups
    (p_effective_date => p_effective_date
    ,p_lookup_type    => 'PARAMETER_CLASS'
    ,p_lookup_code    => p_class
       ) then
      ff_ffp_shd.constraint_error('FF_FP_CLASS_CHK');
  end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTION_PARAMETERS.CLASS'
       ) then
      raise;
    end if;
end chk_class;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_data_type >-------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_data_type
(p_effective_date               in date
,p_data_type                    in varchar2
) is
--
l_proc   varchar2(100) := g_package || 'chk_data_type';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- DATA_TYPE is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'DATA_TYPE'
  ,p_argument_value =>  p_data_type
  );

  if hr_api.not_exists_in_hrstanlookups
    (p_effective_date => p_effective_date
    ,p_lookup_type    => 'DATA_TYPE'
    ,p_lookup_code    => p_data_type
       ) then
      ff_ffp_shd.constraint_error('FF_FP_DATA_TYPE_CHK');
  end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTION_PARAMETERS.DATA_TYPE'
       ) then
      raise;
    end if;
end chk_data_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_name >------------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_name
(p_name                        in varchar2
) is
--
l_proc   varchar2(100) := g_package || 'chk_name';
dummy    varchar2(80);
l_name   varchar2(80);
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- NAME is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'NAME'
  ,p_argument_value =>  p_name
  );
  --
   if (p_name is not null) then
      l_name := p_name;
      hr_chkfmt.checkformat (l_name,
	                    'PAY_NAME',
		             dummy,
                             null,
                             null,
                             'N',
                             dummy,
                             null);
   end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTION_PARAMETERS.NAME'
       ) then
      raise;
    end if;
end chk_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_optional >--------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_optional
(p_effective_date               in date
,p_class                        in varchar2
,p_optional                     in varchar2
) is
--
l_proc   varchar2(100) := g_package || 'chk_optional';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- OPTIONAL is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'OPTIONAL'
  ,p_argument_value =>  p_optional
  );

  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'FF_FUNCTION_PARAMETERS.CLASS'
     ,p_associated_column1 => 'FF_FUNCTION_PARAMETERS.OPTIONAL'
     ) then

     if hr_api.not_exists_in_hrstanlookups
       (p_effective_date => p_effective_date
       ,p_lookup_type    => 'YES_NO'
       ,p_lookup_code    => p_optional
       ) then
      ff_ffp_shd.constraint_error('FF_FP_OPTIONAL_CHK');
     end if;
     -- if parameter class is 'OUT' or 'IN/OUT' type then optional must be 'N'
     if (p_class <> 'I' and p_optional <> 'N' ) then
         ff_ffp_shd.constraint_error('FF_FP_OPTIONAL_CHK');
     end if;

  end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTION_PARAMETERS.OPTIONAL'
       ) then
      raise;
    end if;
end chk_optional;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_continuing_parameter >--------------------|
-- ----------------------------------------------------------------------------
procedure chk_continuing_parameter
(p_effective_date               in date
,p_class                        in varchar2
,p_continuing_parameter         in varchar2
) is
--
l_proc   varchar2(100) := g_package || 'chk_continuing_parameter';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- CONTINUING_PARAMETER is mandatory.
  --
  hr_api.mandatory_arg_error
  (p_api_name       =>  l_proc
  ,p_argument       =>  'CONTINUING_PARAMETER'
  ,p_argument_value =>  p_continuing_parameter
  );

  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'FF_FUNCTION_PARAMETERS.CLASS'
     ,p_associated_column1 => 'FF_FUNCTION_PARAMETERS.CONTINUING_PARAMETER'
     ) then

     if hr_api.not_exists_in_hrstanlookups
       (p_effective_date => p_effective_date
       ,p_lookup_type    => 'YES_NO'
       ,p_lookup_code    => p_continuing_parameter
       ) then
      ff_ffp_shd.constraint_error('FF_FP_CONTINUING_PARAMETER_CHK');
     end if;
     -- if parameter class is 'OUT' or 'IN/OUT' type then continuing_parameter must be 'N'
     if (p_class <> 'I' and p_continuing_parameter <> 'N') then
        ff_ffp_shd.constraint_error('FF_FP_CONTINUING_PARAMETER_CHK');
     end if;

  end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'FF_FUNCTION_PARAMETERS.CONTINUING_PARAMETER'
       ) then
      raise;
    end if;
end chk_continuing_parameter;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_unique >----------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_unique
(p_function_id     in number
,p_name            in varchar2
,p_sequence_number in number
) is
--
cursor csr_unique_parameter
is
select NULL
from ff_function_parameters ffp
where ffp.function_id = p_function_id
and ffp.name like p_name
and sequence_number <> nvl(p_sequence_number,-1);
--
l_proc   varchar2(100) := g_package || 'chk_unique';
l_exists varchar2(1);

begin
  --
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'FF_FUNCTION_PARAMETERS.FUNCTION_ID'
     ,p_check_column2      => 'FF_FUNCTION_PARAMETERS.NAME'
     ,p_associated_column1 => 'FF_FUNCTION_PARAMETERS.FUNCTION_ID'
     ,p_associated_column2 => 'FF_FUNCTION_PARAMETERS.NAME'
     ) then

    open csr_unique_parameter;
    fetch csr_unique_parameter into l_exists;
    if csr_unique_parameter%found then
      close csr_unique_parameter;
      ff_ffp_shd.constraint_error('FF_FUNCTION_PARAMETERS_UK2');
    end if;
    close csr_unique_parameter;
  end if;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_same_associated_columns => 'Y'
       ) then
      raise;
    end if;
  when others then
    if csr_unique_parameter%isopen then
      close csr_unique_parameter;
    end if;
    raise;
end chk_unique;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode

  IF (p_insert) THEN

	if p_business_group_id is not null and p_legislation_code is not null then
        fnd_message.set_name('PAY', 'PAY_33179_BGLEG_INVALID');
        fnd_message.raise_error;
    end if;

    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ff_ffp_shd.g_rec_type
  ) is
--
  cursor csr_business_group is
  select  business_group_id
        , legislation_code
    from FF_FUNCTIONS ffn
   where ffn.function_id = p_rec.function_id;
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_business_group_id ff_functions.business_group_id%type;
  l_legislation_code  ff_functions.legislation_code%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   -- Call all supporting business operations
  --
  -----------------------------------------------------------------------------
  chk_function_id(p_rec.function_id);
  -----------------------------------------------------------------------------
  open csr_business_group;
  fetch csr_business_group into l_business_group_id,l_legislation_code;
  close csr_business_group;

  chk_startup_action(true
                    ,l_business_group_id
                    ,l_legislation_code
                    );

  -----------------------------------------------------------------------------
  chk_class(p_effective_date  => p_effective_date
           ,p_class           => p_rec.class
           );
  -----------------------------------------------------------------------------
  chk_data_type(p_effective_date => p_effective_date
               ,p_data_type      => p_rec.data_type
               );

  -----------------------------------------------------------------------------
  chk_name(p_name  => p_rec.name);

  -----------------------------------------------------------------------------
  chk_unique(p_function_id  => p_rec.function_id
            ,p_name         => p_rec.name
	    ,p_sequence_number => p_rec.sequence_number);

  -----------------------------------------------------------------------------
  chk_optional(p_effective_date => p_effective_date
              ,p_class          => p_rec.class
              ,p_optional       => p_rec.optional
              );
  -----------------------------------------------------------------------------
  chk_continuing_parameter(p_effective_date       => p_effective_date
                          ,p_class                => p_rec.class
                          ,p_continuing_parameter => p_rec.continuing_parameter
                          );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ff_ffp_shd.g_rec_type
  ) is
--
  cursor csr_business_group is
  select  business_group_id
        , legislation_code
    from FF_FUNCTIONS ffn
   where ffn.function_id = p_rec.function_id;
--
  l_business_group_id ff_functions.business_group_id%type;
  l_legislation_code  ff_functions.legislation_code%type;
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
   -----------------------------------------------------------------------------
  chk_function_id(p_rec.function_id);
  -----------------------------------------------------------------------------
  open csr_business_group;
  fetch csr_business_group into l_business_group_id,l_legislation_code;
  close csr_business_group;

  chk_startup_action(true
                    ,l_business_group_id
                    ,l_legislation_code
                    );

  -----------------------------------------------------------------------------
  chk_class(p_effective_date  => p_effective_date
           ,p_class           => p_rec.class
           );
  -----------------------------------------------------------------------------
  chk_data_type(p_effective_date => p_effective_date
               ,p_data_type      => p_rec.data_type
               );

  -----------------------------------------------------------------------------
  chk_name(p_name  => p_rec.name);

  -----------------------------------------------------------------------------
  chk_unique(p_function_id  => p_rec.function_id
            ,p_name         => p_rec.name
   	    ,p_sequence_number => p_rec.sequence_number);

  -----------------------------------------------------------------------------
  chk_optional(p_effective_date => p_effective_date
              ,p_class          => p_rec.class
              ,p_optional       => p_rec.optional
              );
  -----------------------------------------------------------------------------
  chk_continuing_parameter(p_effective_date       => p_effective_date
                          ,p_class                => p_rec.class
                          ,p_continuing_parameter => p_rec.continuing_parameter
                          );
 --
  chk_non_updateable_args
    (p_effective_date     => p_effective_date
      ,p_rec              => p_rec
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
  (p_rec                          in ff_ffp_shd.g_rec_type
  ) is
--
  cursor csr_business_group is
  select  business_group_id
        , legislation_code
    from FF_FUNCTIONS ffn
   where ffn.function_id = p_rec.function_id;
--
  l_business_group_id ff_functions.business_group_id%type;
  l_legislation_code  ff_functions.legislation_code%type;
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -----------------------------------------------------------------------------
  chk_function_id(p_function_id  => p_rec.function_id);
  -----------------------------------------------------------------------------
  open csr_business_group;
  fetch csr_business_group into l_business_group_id,l_legislation_code;
  close csr_business_group;

  chk_startup_action(true
                    ,l_business_group_id
                    ,l_legislation_code
                    );

  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ff_ffp_bus;

/
