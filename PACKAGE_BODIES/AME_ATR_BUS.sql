--------------------------------------------------------
--  DDL for Package Body AME_ATR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ATR_BUS" as
/* $Header: amatrrhi.pkb 120.3 2005/11/22 03:14 santosin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_atr_bus.';  -- Global package name
--
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<chk_approver_type_id  >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the approver_type_id field can only be populated if attribute
--   type is ame_util.numberAttributeType
--   Validates that the approver_type_id if not null, is a foreign key to
--   ame_approver_types.approver_type_id.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_attribute_id
--   p_object_version_number
--   p_effective_date
--   p_approver_type_id
--   p_attribute_type
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
procedure chk_approver_type_id
  (p_attribute_id   in number,
   p_object_version_number in number,
   p_effective_date        in date,
   p_approver_type_id in ame_attributes.approver_type_id%type,
   p_attribute_type in ame_attributes.attribute_type%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_approver_type_id';
  tempCount integer;
  cursor c_sel1 is
    select null
      from ame_approver_types
      where
        approver_type_id = p_approver_type_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  l_exists varchar2(1);
begin
  if p_approver_type_id is not null then
    if p_attribute_type = ame_util.numberAttributeType then
      open c_sel1;
      fetch  c_sel1 into l_exists;
      if c_sel1%notfound then
        close c_sel1;
        fnd_message.set_name('PER','AME_400469_INV_APPROVER_TYPE');
        fnd_message.raise_error;
      end if;
      close c_sel1;
    else
      fnd_message.set_name('PER','AME_400470_NO_APPROVER_TYPE');
      fnd_message.raise_error;
    end if;
  end if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ATTRIBUTE_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_approver_type_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_attribute_type    >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the attribute type is one of the following:
--      ame_util.booleanAttributeType
--      ame_util.currencyAttributeType
--      ame_util.dateAttributeType
--      ame_util.numberAttributeType
--      ame_util.stringAttributeType
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_attribute_id
--   p_object_version_number
--   p_attribute_type
--
-- Post Success:
--   Processing continues if attribute type is valid.
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
procedure chk_attribute_type
  (p_attribute_id   in number,
   p_object_version_number in number,
   p_attribute_type in ame_attributes.attribute_type%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_attribute_type';
begin
  if not (p_attribute_type = ame_util.booleanAttributeType or
          p_attribute_type =  ame_util.currencyAttributeType or
          p_attribute_type =  ame_util.dateAttributeType or
          p_attribute_type =  ame_util.numberAttributeType or
          p_attribute_type =  ame_util.stringAttributeType) then
     fnd_message.set_name('PER','AME_400471_INV_ATTRIBUTE_TYPE');
     fnd_message.raise_error;
  end if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ATTRIBUTE_TYPE') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_attribute_type;
--  ---------------------------------------------------------------------------
--  |----------------------<chk_item_class_id      >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the item_class_id is a foreign key to
--   ame_item_classes.item_class_id.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_attribute_id
--   p_object_version_number
--   p_effective_date
--   p_item_class_id
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
procedure chk_item_class_id
  (p_attribute_id   in number,
   p_object_version_number in number,
   p_effective_date        in date,
   p_item_class_id in ame_attributes.item_class_id%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_item_class_id';
  tempCount integer;
  cursor c_sel1 is
    select null
      from ame_item_classes
      where
        item_class_id = p_item_class_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  l_exists varchar2(1);
begin
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%notfound then
    close c_sel1;
    fnd_message.set_name('PER','AME_400472_INV_ITEM_CLASS');
    fnd_message.raise_error;
  end if;
  close c_sel1;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ITEM_CLASS_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_item_class_id;
--  ---------------------------------------------------------------------------
--  |----------------------<           chk_name    >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the attribute name is does not already exist.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_attribute_id
--   p_object_version_number
--   p_effective_date
--   p_name
--
-- Post Success:
--   Processing continues if attribute name is unique.
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
  (p_attribute_id   in number,
   p_object_version_number in number,
   p_effective_date        in date,
   p_name in ame_attributes.name%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_name';
  tempCount integer;
  cursor c_sel1 is
    select count(*)
      from ame_attributes
      where
        trim(upper(name)) = trim(upper(p_name)) and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
begin
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'name'
    ,p_argument_value => p_name
    );
  open c_sel1;
  fetch c_sel1 into tempCount;
  if c_sel1%found and
     tempCount > 0 then
    close c_sel1;
    fnd_message.set_name('PER','AME_400667_ATT_NAME_EXIST');
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
--  |----------------------<     chk_delete        >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {sTARt Of Comments}
--
-- Description:
--   check that 1. No attribute Usages exist
--              2. Attribute is not an existing Mandatory or Required attribute
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_attribute_id
--   p_object_version_number
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
  (p_attribute_id   in number,
   p_object_version_number in number,
   p_effective_date        in date) is
  l_proc              varchar2(72)  :=  g_package||'chk_delete';
  tempCount integer;
  cursor c_sel1 is
    select null
      from ame_attribute_usages
      where
        attribute_id = p_attribute_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  cursor c_sel2 is
    select null
      from ame_mandatory_attributes
      where
        attribute_id = p_attribute_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  l_exists varchar2(1);
begin
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%found then
    close c_sel1;
    fnd_message.set_name('PER','AME_400171_ATT_IS_IN_USE');
    fnd_message.raise_error;
  end if;
  close c_sel1;
  open c_sel2;
  fetch  c_sel2 into l_exists;
  if c_sel2%found then
    close c_sel2;
    fnd_message.set_name('PER','AME_400170_ATT_MAND_CANT_DEL');
    fnd_message.raise_error;
  end if;
  close c_sel2;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ATTRIBUTE_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_delete;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_usages_exist >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_usages_exist
  (p_attribute_id  in  number
   ,p_start_date       in date
   ,p_end_date         in date
  ) is
--
    Cursor C_Sel1 is
      select count(*)
        from ame_attribute_usages
       where attribute_id = p_attribute_id and
       p_start_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_start_date) ;
--
    Cursor C_Sel2 is
      select count(*)
        from ame_mandatory_attributes
       where attribute_id = p_attribute_id
         and p_start_date between start_date and
               nvl(end_date - ame_util.oneSecond, p_start_date) ;
--
--
    Cursor C_Sel3 is
      select count(*)
        from ame_conditions
       where attribute_id = p_attribute_id
         and p_start_date between start_date and
               nvl(end_date - ame_util.oneSecond, p_start_date) ;
--
  l_child_count integer;
--
--
Begin
  --
  --
  -- ame_attribute_usages
  Open C_Sel1;
  Fetch C_Sel1 into l_child_count;
  Close C_Sel1;
  If l_child_count >0 then
    fnd_message.set_name('AME','AME_400523_ATT_ATTR_USG_EXIST');
    fnd_message.set_token('TABLE_NAME','ame_attribute_usages');
         hr_multi_message.add;
  End If;
  -- ame_mandatory_attributes
  Open C_Sel2;
  Fetch C_Sel2 into l_child_count;
  Close C_Sel2;
  If l_child_count >0 then
    fnd_message.set_name('AME','AME_400170_ATT_MAND_CANT_DEL');
    fnd_message.set_token('TABLE_NAME','ame_mandatory_attributes');
         hr_multi_message.add;
  End If;
  -- ame_conditions
  Open C_Sel3;
  Fetch C_Sel3 into l_child_count;
  Close C_Sel3;
  If l_child_count >0 then
    fnd_message.set_name('AME','AME_400524_ATT_COND_EXIST');
    fnd_message.set_token('TABLE_NAME','ame_conditions');
         hr_multi_message.add;
  End If;
--
End chk_usages_exist;
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
  ,p_rec             in ame_atr_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_atr_shd.api_updating
      (p_attribute_id =>  p_rec.attribute_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
if nvl(p_rec.name,hr_api.g_varchar2) <>
     nvl(ame_atr_shd.g_old_rec.name,hr_api.g_varchar2)
     then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'NAME'
         ,p_base_table => ame_atr_shd.g_tab_nam
         );
  end if;
  if nvl(p_rec.attribute_type,hr_api.g_varchar2) <>
     nvl(ame_atr_shd.g_old_rec.attribute_type,hr_api.g_varchar2)
     then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'ATTRIBUTE_TYPE'
         ,p_base_table => ame_atr_shd.g_tab_nam
         );
  end if;
  if nvl(p_rec.approver_type_id,hr_api.g_number) <>
     nvl(ame_atr_shd.g_old_rec.approver_type_id,hr_api.g_number)
     then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'APPROVER_TYPE_ID'
         ,p_base_table => ame_atr_shd.g_tab_nam
         );
  end if;
  if nvl(p_rec.item_class_id,hr_api.g_number) <>
     nvl(ame_atr_shd.g_old_rec.item_class_id,hr_api.g_number)
     then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'ITEM_CLASS_ID'
         ,p_base_table => ame_atr_shd.g_tab_nam
         );
  end if;
--Added an extra if condition so that no error is thrown when the description for a seeded attribute is modified
--using AME Developer responsibility.
  if ame_utility_pkg.check_seeddb() = 'N' then
    if nvl(ame_util.seededDataCreatedById,hr_api.g_number) =
       nvl(ame_utility_pkg.is_seed_user(ame_atr_shd.g_old_rec.created_by),hr_api.g_number) and
         nvl(p_rec.description,hr_api.g_varchar2) <>
           nvl(ame_atr_shd.g_old_rec.description,hr_api.g_varchar2)
       then
         hr_api.argument_changed_error
           (p_api_name => l_proc
           ,p_argument => 'DESCRIPTION'
           ,p_base_table => ame_atr_shd.g_tab_nam
           );
    end if;
  end if;
  --
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
  (p_attribute_id                     in number
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
      ,p_argument       => 'attribute_id'
      ,p_argument_value => p_attribute_id
      );
    --
  ame_atr_bus.chk_usages_exist
(p_attribute_id => p_attribute_id
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
  (p_rec                   in ame_atr_shd.g_rec_type
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
  -- Validate Independent Attributes
  --
  -- Name
  chk_name(p_attribute_id => p_rec.attribute_id,
            p_object_version_number => p_rec.object_version_number,
            p_effective_date => p_effective_date,
            p_name => p_rec.name);

  -- attribute_type
  chk_attribute_type(p_attribute_id => p_rec.attribute_id,
                     p_object_version_number => p_rec.object_version_number,
                     p_attribute_type => p_rec.attribute_type);

  -- Description
  hr_api.mandatory_arg_error(p_api_name => l_proc,
                             p_argument => 'description',
                             p_argument_value => p_rec.description);

  -- approver_type_id
  chk_approver_type_id(p_attribute_id => p_rec.attribute_id,
                       p_object_version_number => p_rec.object_version_number,
                       p_effective_date => p_effective_date,
                       p_approver_type_id => p_rec.approver_type_id,
                       p_attribute_type => p_rec.attribute_type);

  -- item_class_id
  chk_item_class_id(p_attribute_id => p_rec.attribute_id,
                    p_object_version_number => p_rec.object_version_number,
                    p_effective_date => p_effective_date,
                    p_item_class_id => p_rec.item_class_id);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_atr_shd.g_rec_type
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
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_atr_shd.g_rec_type
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
  --
  -- check if delete operation is allowed.
  chk_delete(p_attribute_id => p_rec.attribute_id,
             p_object_version_number => p_rec.object_version_number,
             p_effective_date => p_effective_date);
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_attribute_id =>  p_rec.attribute_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_atr_bus;

/
