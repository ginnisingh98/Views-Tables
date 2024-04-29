--------------------------------------------------------
--  DDL for Package Body IRC_IRF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IRF_BUS" as
/* $Header: irirfrhi.pkb 120.1 2008/04/16 07:34:32 vmummidi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_irf_bus.';  -- Global package name
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
--   p_referral_info_id
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
  (p_referral_info_id      in number,
   p_object_version_number in number,
   p_effective_date        in date) is
  l_proc              varchar2(72)  :=  g_package||'chk_delete';
begin
   null;
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
-- |------------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in irc_irf_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.referral_info_id is not null)  and (
    nvl(irc_irf_shd.g_old_rec.irf_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.irf_information_category, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_information1, hr_api.g_varchar2) <>
    nvl(p_rec.irf_information1, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_information2, hr_api.g_varchar2) <>
    nvl(p_rec.irf_information2, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_information3, hr_api.g_varchar2) <>
    nvl(p_rec.irf_information3, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_information4, hr_api.g_varchar2) <>
    nvl(p_rec.irf_information4, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_information5, hr_api.g_varchar2) <>
    nvl(p_rec.irf_information5, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_information6, hr_api.g_varchar2) <>
    nvl(p_rec.irf_information6, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_information7, hr_api.g_varchar2) <>
    nvl(p_rec.irf_information7, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_information8, hr_api.g_varchar2) <>
    nvl(p_rec.irf_information8, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_information9, hr_api.g_varchar2) <>
    nvl(p_rec.irf_information9, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_information10, hr_api.g_varchar2) <>
    nvl(p_rec.irf_information10, hr_api.g_varchar2) ))
    or (p_rec.referral_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the irf_information values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name           => 'PER'
      ,p_descflex_name             => 'PER_EVENTS'
      ,p_attribute_category        => p_rec.irf_information_category
      ,p_attribute1_name           => 'IRF_INFORMATION1'
      ,p_attribute1_value          => p_rec.irf_information1
      ,p_attribute2_name           => 'IRF_INFORMATION2'
      ,p_attribute2_value          => p_rec.irf_information2
      ,p_attribute3_name           => 'IRF_INFORMATION3'
      ,p_attribute3_value          => p_rec.irf_information3
      ,p_attribute4_name           => 'IRF_INFORMATION4'
      ,p_attribute4_value          => p_rec.irf_information4
      ,p_attribute5_name           => 'IRF_INFORMATION5'
      ,p_attribute5_value          => p_rec.irf_information5
      ,p_attribute6_name           => 'IRF_INFORMATION6'
      ,p_attribute6_value          => p_rec.irf_information6
      ,p_attribute7_name           => 'IRF_INFORMATION7'
      ,p_attribute7_value          => p_rec.irf_information7
      ,p_attribute8_name           => 'IRF_INFORMATION8'
      ,p_attribute8_value          => p_rec.irf_information8
      ,p_attribute9_name           => 'IRF_INFORMATION9'
      ,p_attribute9_value          => p_rec.irf_information9
      ,p_attribute10_name          => 'IRF_INFORMATION10'
      ,p_attribute10_value         => p_rec.irf_information10
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in irc_irf_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.referral_info_id is not null)  and (
    nvl(irc_irf_shd.g_old_rec.irf_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.irf_attribute_category, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.irf_attribute1, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.irf_attribute2, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.irf_attribute3, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.irf_attribute4, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.irf_attribute5, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.irf_attribute6, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.irf_attribute7, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.irf_attribute8, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.irf_attribute9, hr_api.g_varchar2)  or
    nvl(irc_irf_shd.g_old_rec.irf_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.irf_attribute10, hr_api.g_varchar2) ))
    or (p_rec.referral_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the irf_attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_EVENTS'
      ,p_attribute_category              => p_rec.irf_attribute_category
      ,p_attribute1_name                 => 'IRF_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.irf_attribute1
      ,p_attribute2_name                 => 'IRF_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.irf_attribute2
      ,p_attribute3_name                 => 'IRF_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.irf_attribute3
      ,p_attribute4_name                 => 'IRF_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.irf_attribute4
      ,p_attribute5_name                 => 'IRF_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.irf_attribute5
      ,p_attribute6_name                 => 'IRF_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.irf_attribute6
      ,p_attribute7_name                 => 'IRF_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.irf_attribute7
      ,p_attribute8_name                 => 'IRF_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.irf_attribute8
      ,p_attribute9_name                 => 'IRF_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.irf_attribute9
      ,p_attribute10_name                => 'IRF_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.irf_attribute10
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
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
  ,p_rec in irc_irf_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_irf_shd.api_updating
      (p_effective_date                    => p_effective_date
      ,p_referral_info_id                  => p_rec.referral_info_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --   Add checks to ensure non-updateable args have
  --   not been updated.
  --
  if p_rec.object_id <> irc_irf_shd.g_old_rec.object_id  then
      hr_api.argument_changed_error
      ( p_api_name     => l_proc
       ,p_argument     => 'OBJECT_ID'
       ,p_base_table   => irc_irf_shd.g_tab_name
      );
  end if;
  --
  if p_rec.object_type <> irc_irf_shd.g_old_rec.object_type  then
	 hr_api.argument_changed_error
      ( p_api_name     => l_proc
       ,p_argument     => 'OBJECT_TYPE'
       ,p_base_table   => irc_irf_shd.g_tab_name
      );
  end if;
  --
  if p_rec.object_created_by <> irc_irf_shd.g_old_rec.object_created_by  then
	 hr_api.argument_changed_error
      ( p_api_name     => l_proc
       ,p_argument     => 'OBJECT_CREATED_BY'
       ,p_base_table   => irc_irf_shd.g_tab_name
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
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
  (p_referral_info_id                     in number
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
      ,p_argument       => 'referral_info_id'
      ,p_argument_value => p_referral_info_id
      );
    --
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
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_source_criteria >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_source_criteria
  (p_source_criteria       in   irc_referral_info.source_criteria1%TYPE
  ,p_source_criteria_index in   number
  ,p_effective_date        in   date
  ) is
--
  l_proc        varchar2(72)  := g_package||'chk_source_criteria';
  l_not_exists  boolean;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_source_criteria is not null then
    l_not_exists := hr_api.not_exists_in_hr_lookups
                    (p_effective_date
                    ,'IRC_REFERRAL_CRITERIA'
                    ,p_source_criteria
                    );
    hr_utility.set_location(l_proc, 10);
      if (l_not_exists = true) then
        -- RAISE ERROR SAYING THAT THE SOURCE CRITERIA IS INVALID
        fnd_message.set_name('PER','IRC_412529_INV_SRC_CRITERIA');
        fnd_message.set_token('CRIT_NUM',p_source_criteria_index);
        fnd_message.raise_error;
      end if;
  end if;
  hr_utility.set_location('leaving:'||l_proc, 15);
end chk_source_criteria;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_source_type >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_source_type
  (p_source_type       in   irc_referral_info.source_type%TYPE
  ,p_effective_date        in   date
  ) is
--
  l_proc        varchar2(72)  := g_package||'chk_source_type';
  l_not_exists  boolean;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_source_type is not null then
    l_not_exists := hr_api.not_exists_in_hr_lookups
                    (p_effective_date
                    ,'REC_TYPE'
                    ,p_source_type
                    );
    hr_utility.set_location(l_proc, 10);
      if (l_not_exists = true) then
        -- RAISE ERROR SAYING THAT THE SOURCE CRITERIA IS INVALID
        fnd_message.set_name('PER','HR_51162_ASG_INV_SOURCE_TYPE');
        fnd_message.raise_error;
      end if;
  end if;
  hr_utility.set_location('leaving:'||l_proc, 15);
end chk_source_type;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_object >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_object
  (p_rec                   in   irc_irf_shd.g_rec_type
  ,p_effective_date        in   date
  ) is
--
  l_proc        varchar2(72)  := g_package||'chk_object';
  l_not_exists  boolean;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Check for the Object Type first.
    if (p_rec.object_type<>'PERSON' and  p_rec.object_type<>'APPLICATION') then
      -- RAISE ERROR SAYING THAT THE OBJECT TYPE IS INVALID
      fnd_message.set_name('PER','IRC_412527_INV_OBJ_TYPE');
      fnd_message.raise_error;
    end if;
	--
	hr_utility.set_location(l_proc, 10);
	--
	-- Check for the Object Id
	if p_rec.object_type='PERSON' then
		chk_party_id(p_party_id => p_rec.object_id,
					 p_effective_date => p_effective_date);
	else
		chk_assignment_id(p_assignment_id => p_rec.object_id,
					 p_effective_date => p_effective_date);
	end if;
  hr_utility.set_location('leaving:'||l_proc, 15);
end chk_object;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_object_created_by >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_object_created_by
  (p_rec                   in   irc_irf_shd.g_rec_type
  ,p_effective_date        in   date
  ) is
--
  l_proc        varchar2(72)  := g_package||'chk_object_created_by';
  l_not_exists  boolean;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    if (p_rec.object_created_by<>'EMP'
	    and p_rec.object_created_by<>'CAND'
	    and p_rec.object_created_by<>'MGR'
		and p_rec.object_created_by<>'AGENCY') then
      -- RAISE ERROR SAYING THAT THE OBJECT CRATED BY IS INVALID
      fnd_message.set_name('PER','IRC_412528_INV_OBJ_CREATED_BY');
      fnd_message.raise_error;
    end if;
  hr_utility.set_location('leaving:'||l_proc, 10);
end chk_object_created_by;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_person_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that object_id exists in PER_ALL_PEOPLE_F
--   as 'PERSON' type when the object_type is 'PERSON'
--
-- Pre Conditions:
--
-- In Arguments:
--  p_person_id
--
-- Post Success:
--  Processing continues if object_id is valid.
--
-- Post Failure:
--   An application error is raised if object_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_person_id
  (p_person_id in irc_referral_info.object_id%TYPE
  ,p_effective_date in Date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_person_id';
  l_person_id varchar2(1);
--
  cursor csr_person_id is
    select null
    from per_all_people_f ppf
    where ppf.person_id = p_person_id
    and trunc(p_effective_date) between ppf.effective_start_date
    and ppf.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
-- Check that Person_ID(Object_id) exists in per_all_people_f
  open csr_person_id;
  fetch csr_person_id into l_person_id;
  hr_utility.set_location(l_proc,20);
  if csr_person_id%NOTFOUND then
    close csr_person_id;
    fnd_message.set_name('PER','IRC_412008_BAD_PARTY_PERSON_ID');
    fnd_message.raise_error;
  end if;
  close csr_person_id;
  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_REFERRAL_INFO.OBJECT_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,40);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
end chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_party_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that object_id exists in PER_ALL_PEOPLE_F
--   as 'PERSON' type when the object_type is 'PERSON'
--
-- Pre Conditions:
--
-- In Arguments:
--  p_person_id
--
-- Post Success:
--  Processing continues if object_id is valid.
--
-- Post Failure:
--   An application error is raised if object_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_party_id
  (p_party_id in irc_referral_info.object_id%TYPE
  ,p_effective_date in Date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_party_id';
  l_party_id varchar2(1);
--
  cursor csr_party_id is
    select null
    from per_all_people_f ppf
    where ppf.party_id = p_party_id
    and trunc(p_effective_date) between ppf.effective_start_date
    and ppf.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
-- Check that Party_ID(Object_id) exists in per_all_people_f
  open csr_party_id;
  fetch csr_party_id into l_party_id;
  hr_utility.set_location(l_proc,20);
  if csr_party_id%NOTFOUND then
    close csr_party_id;
    fnd_message.set_name('PER','IRC_412008_BAD_PARTY_PERSON_ID');
    fnd_message.raise_error;
  end if;
  close csr_party_id;
  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_REFERRAL_INFO.OBJECT_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,40);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
end chk_party_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_assignment_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that assignment Id exists in table
--   per_all_assignments_f.
--
-- Pre Conditions:
--   assignment Id should exist in the table.
--
-- In Arguments:
--   p_assignment_id is passed by the user.
--
-- Post Success:
--   Processing continues if assignment Id exists.
--
-- Post Failure:
--   An error is raised if assignment Id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_assignment_id
  (p_assignment_id    in  irc_referral_info.object_id%type
  ,p_effective_date in Date
  ) is
--
  l_proc     varchar2(72) := g_package || 'chk_assignment_id';
  --
  l_assignment_id irc_referral_info.object_id%type ;
  --
  cursor csr_applicant_assignment is
  select 1
  from per_all_assignments_f
  where assignment_id = p_assignment_id
  and assignment_type = 'A'
  and trunc(p_effective_date) between effective_start_date
  and effective_end_date;
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open csr_applicant_assignment;
  fetch csr_applicant_assignment Into l_assignment_id;
  --
  hr_utility.set_location(l_proc,20);
  --
  if csr_applicant_assignment%notfound then
    close csr_applicant_assignment;
    fnd_message.set_name ('PER', 'IRC_412006_ASG_NOT_APPL');
    fnd_message.raise_error;
  end if;
  --
  close csr_applicant_assignment;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1  => 'IRC_ASSIGNMENT_STATUSES.ASSIGNMENT_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
  --
end chk_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in irc_irf_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc                  varchar2(72) := g_package||'insert_validate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  irc_irf_bus.chk_object(p_rec             => p_rec
                              ,p_effective_date  => p_effective_date
                              );
  --
  hr_utility.set_location(l_proc, 15);
  --
  irc_irf_bus.chk_source_criteria(p_source_criteria  => p_rec.source_criteria1
						,p_source_criteria_index => 1
                        ,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  irc_irf_bus.chk_source_criteria(p_source_criteria  => p_rec.source_criteria2
                        ,p_source_criteria_index => 2
						,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 25);
  --
  irc_irf_bus.chk_source_criteria(p_source_criteria  => p_rec.source_criteria3
                        ,p_source_criteria_index => 3
						,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 30);
  --
  irc_irf_bus.chk_source_criteria(p_source_criteria  => p_rec.source_criteria4
                        ,p_source_criteria_index => 4
						,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 35);
  --
  irc_irf_bus.chk_source_criteria(p_source_criteria  => p_rec.source_criteria5
                        ,p_source_criteria_index => 5
						,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 40);
  --
  irc_irf_bus.chk_source_type(p_source_type  => p_rec.source_type
                        ,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 45);
  --
  irc_irf_bus.chk_object_created_by(p_rec             => p_rec
                        ,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 50);
  --
  if p_rec.source_person_id is not null then
  irc_irf_bus.chk_person_id(p_person_id  => p_rec.source_person_id
                        ,p_effective_date => p_effective_date);
  end if;
  --
  hr_utility.set_location(l_proc, 55);
  --
  --irc_irf_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc, 60);
  --
  --irc_irf_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 65);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in irc_irf_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  --
  hr_utility.set_location(l_proc, 10);
  --
  irc_irf_bus.chk_source_criteria(p_source_criteria  => p_rec.source_criteria1
                        ,p_source_criteria_index => 1
						,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  irc_irf_bus.chk_source_criteria(p_source_criteria  => p_rec.source_criteria2
                        ,p_source_criteria_index => 2
						,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 25);
  --
  irc_irf_bus.chk_source_criteria(p_source_criteria  => p_rec.source_criteria3
                        ,p_source_criteria_index => 3
						,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 30);
  --
  irc_irf_bus.chk_source_criteria(p_source_criteria  => p_rec.source_criteria4
                        ,p_source_criteria_index => 4
						,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 35);
  --
  irc_irf_bus.chk_source_criteria(p_source_criteria  => p_rec.source_criteria5
                        ,p_source_criteria_index => 5
						,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 40);
  --
  irc_irf_bus.chk_source_type(p_source_type  => p_rec.source_type
                        ,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 45);
  --
  irc_irf_bus.chk_object_created_by(p_rec             => p_rec
                        ,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 50);
  --
  if p_rec.source_person_id is not null then
  irc_irf_bus.chk_person_id(p_person_id  => p_rec.source_person_id
                        ,p_effective_date => p_effective_date);
  end if;
  --
  hr_utility.set_location(l_proc, 55);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  hr_utility.set_location(l_proc, 60);
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  hr_utility.set_location(l_proc, 65);
  --
  --irc_irf_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc, 70);
  --
  --irc_irf_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 75);
End update_validate;
--
end irc_irf_bus;

/
