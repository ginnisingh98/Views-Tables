--------------------------------------------------------
--  DDL for Package Body AME_ATY_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ATY_BUS" as
/* $Header: amatyrhi.pkb 120.4 2005/11/22 03:14 santosin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_aty_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_action_type_id              number         default null;
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
  (p_effective_date  in date
  ,p_rec             in ame_aty_shd.g_rec_type
  ) IS
--
  createdBy  ame_action_types.created_by%type;
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_aty_shd.api_updating
      (p_action_type_id =>  p_rec.action_type_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  -- not been updated.
  select ame_utility_pkg.is_seed_user(created_by)
    into createdBy
    from ame_action_types
    where
      action_type_id = p_rec.action_type_id and
      p_effective_date between start_date and
         nvl(end_date - ame_util.oneSecond, p_effective_date);
  IF createdBy = ame_util.seededDataCreatedById
     and ame_utility_pkg.check_seeddb = 'N' then
    IF
		  nvl(p_rec.name,
		      hr_api.g_number) <>
      nvl(ame_aty_shd.g_old_rec.name,
			    hr_api.g_number) then
      l_argument := 'name';
      RAISE l_error;
    ELSIF
		  nvl(p_rec.procedure_name,
          hr_api.g_number) <>
      nvl(ame_aty_shd.g_old_rec.procedure_name,
          hr_api.g_number) then
      l_argument := 'procedure_name';
      RAISE l_error;
    ELSIF
      nvl(p_rec.description,
          hr_api.g_number) <>
      nvl(ame_aty_shd.g_old_rec.description,
          hr_api.g_number) then
      l_argument := 'description';
      RAISE l_error;
    ELSIF
      nvl(p_rec.dynamic_description,
          hr_api.g_number) <>
      nvl(ame_aty_shd.g_old_rec.dynamic_description,
          hr_api.g_number) then
      l_argument := 'dynamic_description';
      RAISE l_error;
    END IF;
  END IF;
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
  --
End chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |----------------------<           chk_name    >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the action type name is not null and does not already exist.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_effective_date
--   p_name
--
-- Post Success:
--   Processing continues if action type name is unique.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_name
  (p_effective_date        in date,
   p_name in ame_action_types.name%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_name';
  cursor c_sel1 is
    select null
      from ame_action_types
      where
        name = p_name and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  l_exists varchar2(1);
begin
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'name'
    ,p_argument_value => p_name
    );
  open c_sel1;
  fetch c_sel1 into l_exists;
  if c_sel1%found then
     close c_sel1;
     -- AT MESSAGE
     -- The action type name specified is already exists
     fnd_message.set_name('PER','AME_400610_ACT_TYP_NAME_EXISTS');
     fnd_message.raise_error;
  end if;
  close c_sel1;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'NAME') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_name;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_description>--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates description to ensure non null values
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_description
--
-- Post Success:
--   Processing continues if description is valid.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
----
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_description
  (p_description in varchar2
    ) is
  l_proc  varchar2(72)  :=  g_package||'chk_description';
begin
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'description',
     p_argument_value => p_description);
 exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
          (p_associated_column1 => 'DESCRIPTION') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_description;
--
--  ---------------------------------------------------------------------------
--  |----------------------<    chk_procedure_name  >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the action type procedure name is not null and
--   does not already exist.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_effective_date
--   p_procedure_name
--
-- Post Success:
--   Processing continues if action type procedure name is unique.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_procedure_name
  (p_effective_date        in date,
   p_procedure_name in ame_action_types.procedure_name%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_procedure_name';
  cursor c_sel1 is
    select null
      from ame_action_types
      where
        procedure_name = p_procedure_name and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  l_exists varchar2(1);
begin
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'procedure_name'
    ,p_argument_value => p_procedure_name
    );
  --The following piece of code was commented out to fix bug 4402377
/*  open c_sel1;
  fetch c_sel1 into l_exists;
  if c_sel1%found then
    close c_sel1;
     -- AT MESSAGE
     -- The procedure name specified already exists
     fnd_message.set_name('PER','AME_400611_ACT_TYP_HAND_EXISTS');
     fnd_message.raise_error;
  end if;
  close c_sel1;
*/
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'PROCEDURE_NAME') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_procedure_name;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_dynamic_description>--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the dynamic description is one of the following:
--      ame_util.booleanTrue
--      ame_util.booleanFalse
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_dynamic_description
--
-- Post Success:
--   Processing continues if dynamic description is valid.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
----
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_dynamic_description
  (p_dynamic_description in ame_util.charType) is
  l_proc  varchar2(72)  :=  g_package||'chk_dynamic_description';
begin
  if p_dynamic_description not in (ame_util.booleanTrue,
                                   ame_util.booleanFalse) then
     -- AT MESSAGE
     -- The dynamic description specified is invalid
     fnd_message.set_name('PAY','HR_7777_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
  end if;
 exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
          (p_associated_column1 => 'DYNAMIC_DESCRIPTION') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_dynamic_description;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_description_query>--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the dynamic description query does not contain the
--   following:
--      ';', '--', '/*', '*/'
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_dynamic_description
--   p_description_query
--
-- Post Success:
--   Processing continues if description query is valid.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
----
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_description_query
  (p_dynamic_description in varchar2,
   p_description_query in ame_util.charType) is
  l_proc  varchar2(72)  :=  g_package||'chk_description_query';
  l_valid varchar2(1000);
begin
  IF(p_dynamic_description = ame_util.booleanTrue) then
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'description_query',
       p_argument_value => p_description_query);
    IF(instrb(p_description_query, ';', 1, 1) > 0) or
      (instrb(p_description_query, '--', 1, 1) > 0) or
      (instrb(p_description_query, '/*', 1, 1) > 0) or
      (instrb(p_description_query, '*/', 1, 1) > 0) then
       fnd_message.set_name('PER','AME_400372_ACT_DYNAMIC_DESC2');
       fnd_message.raise_error;
    END IF;
    /* Verify that the description query includes at least one of the bind variables */
    IF(instrb(p_description_query, ame_util.actionParameterOne, 1, 1) = 0) then
      IF(instrb(p_description_query, ame_util.actionParameterTwo, 1, 1) = 0) then
				fnd_message.set_name('PER', 'AME_400370_ACT_DYNAMIC_DESC');
        fnd_message.raise_error;
      END IF;
    END IF;
    IF(instrb(p_description_query, ':', 1, 1) > 0) then
      IF(instrb(p_description_query, ame_util.actionParameterOne, 1, 1) = 0) then
        IF(instrb(p_description_query, ame_util.actionParameterTwo, 1, 1) = 0) then
          fnd_message.set_name('PER', 'AME_400371_ACT_INV_BIND_VAR');
          fnd_message.raise_error;
        END IF;
      END IF;
    END IF;
    ame_util.checkForSqlInjection(queryStringIn => upper(p_description_query));
    l_valid := ame_utility_pkg.validate_query(p_query_string  => p_description_query
                                             ,p_columns       => 1
                                             ,p_object        => ame_util2.actionTypeObject
                                             );
    if l_valid <> 'Y' then
      fnd_message.raise_error;
    end if;
  ELSE
    if(p_description_query is not null) then
      fnd_message.set_name('PER', 'AME_400721_ACT_DYN_DESC_NULL');
      fnd_message.raise_error;
    end if;
  END IF;
 exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
          (p_associated_column1 => 'DESCRIPTION_QUERY') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_description_query;
--
--  ---------------------------------------------------------------------------
--  |----------------------<     chk_delete        >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   check that 1) Seeded action types cannot be deleted.
--              2) Action types cannot have usages.
--              3) Action types cannot have actions.
--              4) Action types cannot have approver type usages.
--              5) Action types cannot have configs.
--              6) Action types cannot have required attributes.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_action_type_id
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_delete
  (p_action_type_id   in number,
   p_effective_date        in date) is
  l_proc              varchar2(72)  :=  g_package||'chk_delete';
  tempCount integer;
  cursor c_sel1 is
    select null
      from ame_action_type_usages
      where
        action_type_id = p_action_type_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date);
  cursor c_sel2 is
    select null
      from ame_action_type_config
      where
        action_type_id = p_action_type_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date);
  cursor c_sel3 is
    select null
      from ame_approver_type_usages
      where
        action_type_id = p_action_type_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date);
  cursor c_sel4 is
    select null
      from ame_mandatory_attributes
      where
        action_type_id = p_action_type_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date);
	cursor c_sel5 Is
    select null
      from ame_action_types
      where
		    action_type_id = p_action_type_id and
        ame_utility_pkg.is_seed_user(created_by) = ame_util.seededDataCreatedById and
        ame_utility_pkg.check_seeddb = 'N';
  cursor c_sel6 Is
    select null
      from ame_actions
        where
          action_type_id = p_action_type_id and
          p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date);
	l_exists varchar2(1);
begin
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%found then
    close c_sel1;
    -- AT MESSAGE
    -- An action type usage(s) still exists.  You must first delete the action type usage(s)
    -- before deleting the action type
    fnd_message.set_name('PER','AME_400597_ACT_TYPE_USG_EXIST');
    fnd_message.raise_error;
  end if;
  close c_sel1;
  open c_sel2;
  fetch  c_sel2 into l_exists;
  if c_sel2%found then
    close c_sel2;
    -- AT MESSAGE
    -- An action type config(s) still exists.  You must first delete the action type config(s)
    -- before deleting the action type
    fnd_message.set_name('PER','AME_400608_ACT_TYP_CONF_EXISTS');
    fnd_message.raise_error;
  end if;
  close c_sel2;
  open c_sel3;
  fetch  c_sel3 into l_exists;
  if c_sel3%found then
    close c_sel3;
    -- AT MESSAGE
    -- An apporver type usage(s) still exists.  You must first delete the approver type usage(s)
    -- before deleting the action type
    fnd_message.set_name('PER','AME_400612_APPR_USG_EXISTS');
    fnd_message.raise_error;
  end if;
  close c_sel3;
  open c_sel4;
  fetch  c_sel4 into l_exists;
  if c_sel4%found then
    close c_sel4;
    -- AT MESSAGE
    -- Required attribute(s) still exists.  You must first delete the required attribute(s)
    -- before deleting the action type
    fnd_message.set_name('PER','AME_400613_REQ_ATTR_EXISTS');
    fnd_message.raise_error;
  end if;
  close c_sel4;
  -- Seeded action types cannot be deleted
  open c_sel5;
  fetch  c_sel5 into l_exists;
  if c_sel5%found then
    close c_sel5;
    -- AT MESSAGE
    -- Seeded action types cannot be deleted
    fnd_message.set_name('PER','AME_400601_SD_ACT_TYP_CN_DEL');
    fnd_message.set_token('TABLE_NAME','ame_action_types');
    fnd_message.raise_error;
  end if;
  close c_sel5;
  -- Action types with existing actions cannot be deleted.
  open c_sel6;
  fetch  c_sel6 into l_exists;
  if c_sel6%found then
    close c_sel6;
    -- AT MESSAGE
    -- Action types with existing actions cannot be deleted
    fnd_message.set_name('PER','AME_400602_ACT_EXT_ATYP_CN_DEL');
    fnd_message.set_token('TABLE_NAME','ame_action_types');
    fnd_message.raise_error;
  end if;
  close c_sel6;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ACTION_TYPE_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_delete;
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  /*hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );*/
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_action_type_id                   in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    /*hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );*/
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'action_type_id'
      ,p_argument_value => p_action_type_id
      );
    --
  ame_aty_shd.child_rows_exist
(p_action_type_id => p_action_type_id
,p_start_date => p_validation_start_date
,p_end_date   => p_validation_end_date);
--
    --
  End If;
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in ame_aty_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- Description Query
  if hr_multi_message.no_exclusive_error('DYNAMIC_DESCRIPTION') then
    chk_description_query(p_dynamic_description => p_rec.dynamic_description,
                          p_description_query => p_rec.description_query);
  end if;
  --
  -- Name
  chk_name(p_effective_date => p_effective_date,
           p_name => p_rec.name);
  --Description
  chk_description(p_description => p_rec.description);
  -- Procedure Name
  chk_procedure_name(p_effective_date => p_effective_date,
                     p_procedure_name => p_rec.procedure_name);
  -- Dynamic Description
  chk_dynamic_description(p_dynamic_description => p_rec.dynamic_description);
	--
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_aty_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --Added the following chk proc to fix bug 4402377
  chk_procedure_name(p_effective_date => p_effective_date,
                     p_procedure_name => p_rec.procedure_name);
  --
  --Description
  chk_description(p_description => p_rec.description);
  --Description_query
  chk_description_query(p_dynamic_description => p_rec.dynamic_description,
                        p_description_query => p_rec.description_query);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_aty_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- check if delete operation is allowed.
  chk_delete(p_action_type_id => p_rec.action_type_id,
             p_effective_date => p_effective_date);
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_action_type_id =>  p_rec.action_type_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_aty_bus;

/
