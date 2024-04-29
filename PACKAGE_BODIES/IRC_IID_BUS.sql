--------------------------------------------------------
--  DDL for Package Body IRC_IID_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IID_BUS" as
/* $Header: iriidrhi.pkb 120.3.12010000.2 2008/11/06 13:49:47 mkjayara ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_iid_bus.';  -- Global package name
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
--   p_interview_details_id
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
  (p_interview_details_id   in number,
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
  (p_rec in irc_iid_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.interview_details_id is not null)  and (
    nvl(irc_iid_shd.g_old_rec.iid_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information_category, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information1, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information1, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information2, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information2, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information3, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information3, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information4, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information4, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information5, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information5, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information6, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information6, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information7, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information7, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information8, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information8, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information9, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information9, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information10, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information10, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information11, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information11, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information12, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information12, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information13, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information13, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information14, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information14, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information15, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information15, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information16, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information16, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information17, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information17, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information18, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information18, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information19, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information19, hr_api.g_varchar2)  or
    nvl(irc_iid_shd.g_old_rec.iid_information20, hr_api.g_varchar2) <>
    nvl(p_rec.iid_information20, hr_api.g_varchar2) ))
    or (p_rec.event_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the iid_information values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name           => 'PER'
      ,p_descflex_name             => 'PER_EVENTS'
      ,p_attribute_category        => p_rec.iid_information_category
      ,p_attribute1_name           => 'iid_information1'
      ,p_attribute1_value          => p_rec.iid_information1
      ,p_attribute2_name           => 'iid_information2'
      ,p_attribute2_value          => p_rec.iid_information2
      ,p_attribute3_name           => 'iid_information3'
      ,p_attribute3_value          => p_rec.iid_information3
      ,p_attribute4_name           => 'iid_information4'
      ,p_attribute4_value          => p_rec.iid_information4
      ,p_attribute5_name           => 'iid_information5'
      ,p_attribute5_value          => p_rec.iid_information5
      ,p_attribute6_name           => 'iid_information6'
      ,p_attribute6_value          => p_rec.iid_information6
      ,p_attribute7_name           => 'iid_information7'
      ,p_attribute7_value          => p_rec.iid_information7
      ,p_attribute8_name           => 'iid_information8'
      ,p_attribute8_value          => p_rec.iid_information8
      ,p_attribute9_name           => 'iid_information9'
      ,p_attribute9_value          => p_rec.iid_information9
      ,p_attribute10_name          => 'iid_information10'
      ,p_attribute10_value         => p_rec.iid_information10
      ,p_attribute11_name          => 'iid_information11'
      ,p_attribute11_value         => p_rec.iid_information11
      ,p_attribute12_name          => 'iid_information12'
      ,p_attribute12_value         => p_rec.iid_information12
      ,p_attribute13_name          => 'iid_information13'
      ,p_attribute13_value         => p_rec.iid_information13
      ,p_attribute14_name          => 'iid_information14'
      ,p_attribute14_value         => p_rec.iid_information14
      ,p_attribute15_name          => 'iid_information15'
      ,p_attribute15_value         => p_rec.iid_information15
      ,p_attribute16_name          => 'iid_information16'
      ,p_attribute16_value         => p_rec.iid_information16
      ,p_attribute17_name          => 'iid_information17'
      ,p_attribute17_value         => p_rec.iid_information17
      ,p_attribute18_name          => 'iid_information18'
      ,p_attribute18_value         => p_rec.iid_information18
      ,p_attribute19_name          => 'iid_information19'
      ,p_attribute19_value         => p_rec.iid_information19
      ,p_attribute20_name          => 'iid_information20'
      ,p_attribute20_value         => p_rec.iid_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
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
  ,p_rec in irc_iid_shd.g_rec_type
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
  IF NOT irc_iid_shd.api_updating
      (p_effective_date                    => p_effective_date
      ,p_interview_details_id                 => p_rec.interview_details_id
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
  if p_rec.event_id <> irc_iid_shd.g_old_rec.event_id
  then
    hr_api.argument_changed_error
    (p_api_name   => l_proc
    ,p_argument   => 'EVENT_ID'
    ,p_base_table => irc_iid_shd.g_tab_name
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
  (p_interview_details_id                     in number
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
      ,p_argument       => 'interview_details_id'
      ,p_argument_value => p_interview_details_id
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
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_status >---------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_status
  (p_rec                   in   irc_iid_shd.g_rec_type
  ,p_effective_date        in   date
  ) is
--
  l_proc        varchar2(72)  := g_package||'chk_status';
  l_not_exists  boolean;
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_not_exists := hr_api.not_exists_in_hr_lookups
                  (p_effective_date
                  ,'IRC_INTERVIEW_STATUS'
                  ,p_rec.status
                  );
  hr_utility.set_location(l_proc, 10);
    if (l_not_exists = true) then
      -- RAISE ERROR SAYING THAT THE STATUS IS INVALID
      fnd_message.set_name('PER','IRC_412471_INV_INT_STATUS');
      fnd_message.raise_error;
    end if;
  hr_utility.set_location('leaving:'||l_proc, 15);
end chk_status;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_result >---------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_result
  (p_rec                   in irc_iid_shd.g_rec_type
  ,p_effective_date        in   date
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_result';
  l_not_exists  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_not_exists := hr_api.not_exists_in_hr_lookups
                  (p_effective_date
                  ,'IRC_INTERVIEW_RESULTS'
                  ,p_rec.result
                  );
  hr_utility.set_location(l_proc, 10);
    if (l_not_exists = true) then
      -- RAISE ERROR SAYING INVALID RESULT
      fnd_message.set_name('PER','IRC_412472_INV_INT_RESULT');
      fnd_message.raise_error;
    end if;
  hr_utility.set_location('leaving:'||l_proc, 15);
end chk_result;
--
---- ----------------------------------------------------------------------------
-- |---------------------------< chk_completed >--------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_completed
  (p_rec                   in irc_iid_shd.g_rec_type
  ,p_effective_date        in date
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_completed';
  l_result_not_eists boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_rec.status = 'COMPLETED' then
      if p_rec.feedback is null then
        -- raise error saying feedback is mandatory when status is complete
        fnd_message.set_name('PER','IRC_412473_INT_FDBK_MANDATORY');
        fnd_message.raise_error;
      end if;
      if p_rec.result is null then
        -- raise error saying result is mandatory when status is complete
        fnd_message.set_name('PER','IRC_412474_INT_RSLT_MANDATORY');
        fnd_message.raise_error;
      else
        irc_iid_bus.chk_result(p_rec            => p_rec
                              ,p_effective_date => p_effective_date
                              );
      end if;
  else
     if p_rec.result is not null then
       --
       -- RESULT SHOULD BE NULL FOR INCOMPLET INTERVIEWS
       --
       fnd_message.set_name('PER','IRC_412475_RESULT_NOT_NULL');
       fnd_message.raise_error;
       --
     end if;
     if p_rec.feedback is not null then
       --
       -- FEEDBACK SHOULD BE NULL FOR INCOMPLET INTERVIEWS
       --
       fnd_message.set_name('PER','IRC_412476_FEEDBACK_NOT_NULL');
       fnd_message.raise_error;
     end if;
  end if;
  hr_utility.set_location('leaving:'||l_proc, 10);
end chk_completed;
---
----------------------------------------------------------------------------
-- |---------------------------< chk_updated_status >--------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_updated_status
  (p_old_status           in varchar2
  ,p_new_status           in varchar2
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_updated_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_old_status <> p_new_status) then
    if p_old_status = 'PLANNED' then
       if (p_new_status = 'RESCHEDULED' or p_new_status = 'COMPLETED') then
            -- raise error saying that status can not change to RESCHEDULED or COMPLETED
            fnd_message.set_name('PER','IRC_412477_PLND_ST_CANT_CHNG');
	     fnd_message.raise_error;
       end if;
    elsif p_old_status = 'CONFIRMED' then
       if (p_new_status = 'PLANNED') then
            -- raise error saying that status can not change to PLANNED.
            fnd_message.set_name('PER','IRC_412478_CNFRM_ST_CANT_CHNG');
	     fnd_message.raise_error;
       end if;
    elsif p_old_status = 'CANCELLED' then
            -- raise error saying that status can not change for CANCELLED interview
            fnd_message.set_name('PER','IRC_412479_CNCLD_ST_CANT_CHNG');
	     fnd_message.raise_error;
    elsif p_old_status = 'RESCHEDULED' then
       if (p_new_status = 'PLANNED') then
            -- raise error saying that status can not change to PLANNED or COMPLETED
            fnd_message.set_name('PER','IRC_412480_RSCHL_ST_CANT_CHNG');
	     fnd_message.raise_error;
       end if;
    elsif p_old_status = 'HOLD' then
       if (p_new_status = 'PLANNED') then
            -- raise error saying that status can not change to PLANNED or HOLD
            fnd_message.set_name('PER','IRC_412481_HOLD_ST_CANT_CHNG');
	     fnd_message.raise_error;
       end if;
    elsif p_old_status = 'COMPLETED' then
       if (p_new_status <> 'COMPLETED') then
            -- raise error saying that status can not change for COMPLETED interview
            fnd_message.set_name('PER','IRC_412482_CMPLT_ST_CANT_CHNG');
	     fnd_message.raise_error;
       end if;
    end if;
  end if;
  --
  hr_utility.set_location('leaving:'||l_proc, 10);
end chk_updated_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_event_id >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_event_id
  (p_rec                   in irc_iid_shd.g_rec_type
  ) is
  l_rec_exists number;
  cursor csr_event_exists is
    select 1
      from per_events
     where event_id = p_rec.event_id;
Begin
  open csr_event_exists;
  fetch csr_event_exists into l_rec_exists;
  if (csr_event_exists%notfound) then
     -- raise an error saying the event does not exist
     fnd_message.set_name('PER','IRC_412483_INV_EVENT_ID');
     fnd_message.raise_error;
  end if;
  close csr_event_exists;

end chk_event_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in irc_iid_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc                  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
--  irc_iid_bus.chk_event_id (p_rec  => p_rec);  -- commented for fixing the issue
  irc_iid_bus.chk_status(p_rec            => p_rec
                        ,p_effective_date => p_effective_date);
  irc_iid_bus.chk_completed(p_rec             => p_rec
                           ,p_effective_date  => p_effective_date
                           );
  irc_iid_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in irc_iid_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
  l_old_status   varchar2(30);
  cursor csr_old_status is
    select status
      from irc_interview_details
     where interview_details_id = p_rec.interview_details_id
       and sysdate between start_date and nvl(end_date,hr_general.end_of_time);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  irc_iid_bus.chk_event_id (p_rec  => p_rec);
  irc_iid_bus.chk_status(p_rec            => p_rec
                        ,p_effective_date => p_effective_date);
  --
  --
  open csr_old_status;
  fetch csr_old_status into l_old_status;
  --
  if csr_old_status%found then
    if (l_old_status <> p_rec.status) then
       irc_iid_bus.chk_updated_status(p_old_status  => l_old_status
                      ,p_new_status  => p_rec.status);
    end if;
  else
    -- raise error saying that record does not exist
    fnd_message.set_name('PER','IRC_412484_INV_INT_DETAILS_ID');
    fnd_message.raise_error;
  end if;
  close csr_old_status;
  irc_iid_bus.chk_completed(p_rec             => p_rec
                           ,p_effective_date  => p_effective_date
                           );
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
  irc_iid_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
end irc_iid_bus;

/
