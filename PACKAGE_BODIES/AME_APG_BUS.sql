--------------------------------------------------------
--  DDL for Package Body AME_APG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APG_BUS" as
/* $Header: amapgrhi.pkb 120.6 2006/10/05 16:02:47 pvelugul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_apg_bus.';  -- Global package name
--


-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_NAME >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates the uniqueness of approval group's name.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_name
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid name has been entered.
--
-- Post Failure:
--   An application error is raised if the name is not unique.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_name(p_name                in   varchar2
                  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_NAME';
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'NAME'
                              ,p_argument_value     => p_name
                              );
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUPS.NAME'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_name;

procedure chk_delete(p_approval_group_id in number
                    ,p_effective_date in date) is
  l_proc     varchar2(72) := g_package || 'CHK_DELETE';
  l_count    number;
  cursor c_sel1 is
    select null
      from ame_approval_groups
      where ame_utility_pkg.check_seeddb = 'N'
        and ame_utility_pkg.is_seed_user(created_by) = ame_util.seededDataCreatedById
        and approval_group_id = p_approval_group_id
        and p_effective_date between start_date and
             nvl(end_date -(1/86400), p_effective_date);
begin
    hr_utility.set_location('Entering:'||l_proc,10);
    --+
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUPS.DELETE'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
end chk_delete;
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_UNIQUE >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates the uniqueness of approval group's name.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_name
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid name has been entered.
--
-- Post Failure:
--   An application error is raised if the name is not unique.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_unique(p_name                in   varchar2
                    ,p_effective_date      in   date
                  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_UNIQUE';
  l_count    number;
--
-- Cursor to find number of groups with name=p_name
--
  Cursor C_Sel1 Is
    select count(name)
    from   ame_approval_groups t
    where t.name = p_name
    and p_effective_date between t.start_date and t.end_date;

  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    -- Check if the name is already in use by another approval group
    open C_Sel1;
    fetch C_Sel1 into l_count;
    close C_Sel1;
    if l_count <> 0 then
      fnd_message.set_name('PER','AME_400561_APG_NAME_NOT_UNQ');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUPS.NAME'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_unique;

-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_IS_STATIC >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates is_static which should be in ('Y','N')
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_is_static
--
-- Post Success:
--   Processing continues if is_static is in ('Y','N').
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_is_static(p_is_static           in   varchar2
                       ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_IS_STATIC';
--

  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'IS_STATIC'
                              ,p_argument_value     => p_is_static
                              );
    if p_is_static not in('Y','N') then
      fnd_message.set_name('PER','AME_400562_APG_INVALID_USG_TYP');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUPS.IS_STATIC'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_is_static;


-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_QUERY_STRING >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure checks if query string is not null when is_static ='Y'.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_is_static
--   p_query_string
--
-- Post Success:
--   Processing continues if query_string is not null when is_static = 'Y'.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_query_string(p_is_static           in   varchar2
                          ,p_query_string        in   varchar2
                          ) IS
--
  l_proc      varchar2(72) := g_package || 'CHK_QUERY_STRING';
  l_validated varchar2(1);
  tempInt integer;
  transIdPlaceholderPosition integer;
  transIdPlaceholderPosition2 integer;
  upperTransIdPlaceholder      varchar2(100);
  querystring ame_approval_groups.query_string%type;
  l_valid  varchar2(1000);
--

  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    if (p_is_static = 'Y' and p_query_string is not null) then
      fnd_message.set_name('PER','AME_400563_APG_INV_USG_QRY_CMB');
      fnd_message.raise_error;
    end if;
    if (p_is_static = 'N' and p_query_string is null) then
      fnd_message.set_name('PER','AME_400556_APG_EMPTY_QUERY');
      fnd_message.raise_error;
    end if;
    if(p_is_static = 'N') then
      if(instrb(p_query_string, ';', 1, 1) > 0) or
         (instrb(p_query_string, '--', 1, 1) > 0) or
         (instrb(p_query_string, '/*', 1, 1) > 0) or
         (instrb(p_query_string, '*/', 1, 1) > 0) then
          fnd_message.set_name('PER','AME_400165_ATT_DYN_USG_COMM');
          fnd_message.raise_error;
      end if;
      tempInt := 1;
      queryString := upper(p_query_string);
      upperTransIdPlaceholder := upper(ame_util.transactionIdPlaceholder);
      loop
        transIdPlaceholderPosition :=
            instrb(queryString, upperTransIdPlaceholder, 1, tempInt);
        if(transIdPlaceholderPosition = 0) then
          exit;
        end if;
        transIdPlaceholderPosition2 :=
            instrb(p_query_string, ame_util.transactionIdPlaceholder, 1, tempInt);
        if(transIdPlaceholderPosition <> transIdPlaceholderPosition2) then
          fnd_message.set_name('PER','AME_400635_APG_QRY_STR_BND_VAR');
          fnd_message.raise_error;
        end if;
        tempInt := tempInt + 1;
      end loop;
      /*if(ame_util.isArgumentTooLong(tableNameIn => 'ame_approval_groups',
                                    columnNameIn => 'query_string',
                                    argumentIn => p_query_string)) then
          fnd_message.set_name('PER','AME_400163_ATT_USAGE_LONG');
          fnd_message.raise_error;
      end if;*/
      /* The following utility handles the error. So nothing needs to be done here */
      ame_util.checkForSqlInjection(queryStringIn => queryString);
      l_valid := ame_utility_pkg.validate_query(p_query_string  => p_query_string
                                             ,p_columns       => 1
                                             ,p_object        => ame_util2.approverGroupObject
                                             );
      if l_valid <> 'Y' then
      fnd_message.raise_error;
      end if;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUPS.QUERY_STRING'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_query_string;


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
  ,p_rec             in ame_apg_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_created_by          ame_approval_groups.created_by%TYPE;
--
--
-- Cursor to find created_by value for the row
--
--  Cursor C_Sel1 Is
--    select t.created_by
--    from   ame_approval_groups t
--    where t.approval_group_id = p_rec.approval_group_id
--    and p_effective_date between t.start_date and t.end_date;
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_apg_shd.api_updating
      (p_approval_group_id =>  p_rec.approval_group_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
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
  --
  -- If the group is seeded, do not allow updation of the group values
  --
  --open C_Sel1;
  --fetch C_Sel1 into l_created_by;
  --close C_Sel1;
  --
  -- NAME is non-updateable if the group is seeded

  --if l_created_by = ame_util.seededDataCreatedById and
    if nvl(p_rec.name, hr_api.g_varchar2) <>
       nvl(ame_apg_shd.g_old_rec.name,hr_api.g_varchar2)then
     hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'NAME'
          ,p_base_table => ame_con_shd.g_tab_nam
          );
  end if;
  --
  -- DESCRIPTION is non-updateable if the group is seeded

  -- if l_created_by = ame_util.seededDataCreatedById and
  --     nvl(p_rec.description, hr_api.g_varchar2) <>
  --     nvl(ame_apg_shd.g_old_rec.description,hr_api.g_varchar2)then
  --   hr_api.argument_changed_error
  --        (p_api_name   => l_proc
  --        ,p_argument   => 'DESCRIPTION'
  --        ,p_base_table => ame_con_shd.g_tab_nam
  --        );
  --end if;
  --
  -- IS_STATIC is non-updateable if the group is seeded

  --if l_created_by = ame_util.seededDataCreatedById and
  --     nvl(p_rec.is_static, hr_api.g_varchar2) <>
  --     nvl(ame_apg_shd.g_old_rec.is_static,hr_api.g_varchar2)then
  --   hr_api.argument_changed_error
  --        (p_api_name   => l_proc
  --        ,p_argument   => 'IS_STATIC'
  --        ,p_base_table => ame_con_shd.g_tab_nam
  --        );
  --end if;
  --
  -- QUERY_STRING is non-updateable if the group is seeded

  -- if l_created_by = ame_util.seededDataCreatedById and
  --     nvl(p_rec.query_string, hr_api.g_varchar2) <>
  --     nvl(ame_apg_shd.g_old_rec.query_string,hr_api.g_varchar2)then
  --   hr_api.argument_changed_error
  --        (p_api_name   => l_proc
  --        ,p_argument   => 'QUERY_STRING'
  --        ,p_base_table => ame_con_shd.g_tab_nam
  --        );
  --end if;
End chk_non_updateable_args;
--
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
  (p_approval_group_id                in number
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
      ,p_argument       => 'approval_group_id'
      ,p_argument_value => p_approval_group_id
      );
    --
  ame_apg_shd.child_rows_exist
(p_ => p_approval_group_id
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
  (p_rec                   in ame_apg_shd.g_rec_type
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
  -- Validate Dependent Attributes
  --
  --
  -- User Entered calls to validate procedures
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'description'
                            ,p_argument_value => p_rec.description
                            );
  chk_name (
            p_name            => p_rec.name
           );
  chk_unique (
            p_name            => p_rec.name
           ,p_effective_date  => p_effective_date
           );
  chk_is_static(
                p_is_static => p_rec.is_static
               );
  chk_query_string(
                   p_is_static    => p_rec.is_static
                  ,p_query_string => p_rec.query_string
                  );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_apg_shd.g_rec_type
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
  --
  --

  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'description'
                            ,p_argument_value => p_rec.description
                            );
      -- User Entered calls to validate procedures
  chk_name (
            p_name            => p_rec.name
           );
 --name is non updateable, so following code is commented
 /*if (p_rec.name <> ame_apg_shd.g_old_rec.name) then
    chk_unique (
            p_name            => p_rec.name
           ,p_effective_date  => p_effective_date
           );
 end if;*/

  chk_is_static(
                p_is_static => p_rec.is_static
               );
  chk_query_string(
                   p_is_static    => p_rec.is_static
                  ,p_query_string => p_rec.query_string
                  );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_apg_shd.g_rec_type
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
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_approval_group_id =>  p_rec.approval_group_id
    );
  chk_delete(p_approval_group_id => p_rec.approval_group_id
            ,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_apg_bus;

/
