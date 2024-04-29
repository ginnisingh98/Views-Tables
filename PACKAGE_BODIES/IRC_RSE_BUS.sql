--------------------------------------------------------
--  DDL for Package Body IRC_RSE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_RSE_BUS" as
/* $Header: irrserhi.pkb 120.0.12010000.2 2010/01/18 14:37:22 mkjayara ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_rse_bus.';  -- Global package name
--
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
  (p_rec in irc_rse_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.recruiting_site_id is not null)  and (
    nvl(irc_rse_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(irc_rse_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.recruiting_site_id is null)  then
    --
    hr_utility.set_location('Inside the ff stuff',20);
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'IRC_ALL_RECRUITING_SITES'
      ,p_attribute_category              => p_rec.attribute_category
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
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
  ,p_rec in irc_rse_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_rse_shd.api_updating
      (p_recruiting_site_id                => p_rec.recruiting_site_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_internal >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that INTERNAL has a value of 'Y' or 'N'.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_internal
--  p_recruiting_site_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if INTERNAL is valid.
--
-- Post Failure:
--   An application error is raised external is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_internal
  (p_internal              in irc_all_recruiting_sites.internal%TYPE
  ,p_recruiting_site_id    in irc_all_recruiting_sites.recruiting_site_id%TYPE
  ,p_object_version_number in irc_all_recruiting_sites.object_version_number%TYPE
  ) IS
--
  l_proc         varchar2(72) := g_package || 'chk_internal';
  l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  l_api_updating  :=   irc_rse_shd.api_updating
                         (p_recruiting_site_id    => p_recruiting_site_id
                         ,p_object_version_number => p_object_version_number
                         );
  --
  hr_utility.set_location(l_proc,20);
  if (l_api_updating  and
        p_internal <>
        NVL(irc_rse_shd.g_old_rec.internal,hr_api.g_varchar2)
     ) or (NOT l_api_updating) then
    -- Check that internal has a valid value of either 'Y' or 'N'
    hr_utility.set_location(l_proc,30);
    if not p_internal in ('Y','N') then
        hr_utility.set_location(l_proc,40);
        fnd_message.set_name('PER','IRC_412093_BAD_INTERNAL');
        fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_ALL_RECRUITING_SITES.INTERNAL'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_internal;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_external >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that EXTERNAL has a value of 'Y' or 'N'.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_external
--  p_recruiting_site_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if EXTERNAL is valid.
--
-- Post Failure:
--   An application error is raised if EXTERNAL is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_external
  (p_external              in irc_all_recruiting_sites.external%TYPE
  ,p_recruiting_site_id    in irc_all_recruiting_sites.recruiting_site_id%TYPE
  ,p_object_version_number in irc_all_recruiting_sites.object_version_number%TYPE
  ) IS
--
  l_proc         varchar2(72) := g_package || 'chk_external';
  l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  l_api_updating  :=   irc_rse_shd.api_updating
                         (p_recruiting_site_id    => p_recruiting_site_id
                         ,p_object_version_number => p_object_version_number
                         );
  --
  hr_utility.set_location(l_proc,20);
  if (l_api_updating  and
        p_external <>
        NVL(irc_rse_shd.g_old_rec.external,hr_api.g_varchar2)
     ) or (NOT l_api_updating) then
    -- Check that external has a valid value of either 'Y' or 'N'
    hr_utility.set_location(l_proc,30);
    if not p_external in ('Y','N') then
        hr_utility.set_location(l_proc,40);
        fnd_message.set_name('PER','IRC_412094_BAD_EXTERNAL');
        fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_ALL_RECRUITING_SITES.EXTERNAL'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_external;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_third_party >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that THIRD_PARTY has a value of 'Y' or 'N'.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_third_party
--  p_recruiting_site_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if THIRD_PARTY is valid.
--
-- Post Failure:
--   An application error is raised third_party is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_third_party
  (p_third_party           in irc_all_recruiting_sites.third_party%TYPE
  ,p_internal              in irc_all_recruiting_sites.internal%TYPE
  ,p_external              in irc_all_recruiting_sites.external%TYPE
  ,p_recruiting_site_id    in irc_all_recruiting_sites.recruiting_site_id%TYPE
  ,p_object_version_number in irc_all_recruiting_sites.object_version_number%TYPE
  ) IS
--
  l_proc         varchar2(72) := g_package || 'chk_third_party';
  l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  l_api_updating  :=   irc_rse_shd.api_updating
                         (p_recruiting_site_id    => p_recruiting_site_id
                         ,p_object_version_number => p_object_version_number
                         );
  --
  hr_utility.set_location(l_proc,20);
  if (l_api_updating  and
        p_third_party <>
        NVL(irc_rse_shd.g_old_rec.third_party,hr_api.g_varchar2)
     ) or (NOT l_api_updating) then
    -- Check that third_party has a valid value of either 'Y' or 'N'
    hr_utility.set_location(l_proc,30);
    if not p_third_party in ('Y','N') then
        hr_utility.set_location(l_proc,40);
        fnd_message.set_name('PER','IRC_412095_BAD_THIRD_PARTY');
        fnd_message.raise_error;
    end if;
    if((p_internal = 'Y' or p_external = 'Y')
       AND
       (p_third_party = 'Y')
      ) then
      hr_utility.set_location(l_proc,45);
      fnd_message.set_name('PER','IRC_412095_BAD_THIRD_PARTY');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_ALL_RECRUITING_SITES.THIRD_PARTY'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_third_party;
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_posting_cost_period >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the value passed in for posting_cost_period is contained
--   as a lookup in IRC_POSTING_COST_FREQ
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_posting_cost_period
--  p_effective_date
--  p_recruiting_site_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if posting_cost_period is valid.
--
-- Post Failure:
--   An application error is raised if posting_cost_period is invalid.
--
-- {End Of Comments}
Procedure chk_posting_cost_period
 (
  p_posting_cost_period  in irc_all_recruiting_sites.posting_cost_period%TYPE
 ,p_effective_date      in date
 ,p_recruiting_site_id  in irc_all_recruiting_sites.recruiting_site_id%TYPE
 ,p_object_version_number in irc_all_recruiting_sites.object_version_number%TYPE
 )
is
--
  l_proc        varchar2(72):=g_package||'chk_posting_cost_period';
  l_api_updating        boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'effective_date'
    ,p_argument_value   => p_effective_date
    );
  --
  -- Only proceed with the validation if :
  --  a) The current g_old_rec is current
  --  b) The value has changed.
  --  c) A record is being inserted
  --
  l_api_updating  :=   irc_rse_shd.api_updating
                         (p_recruiting_site_id    => p_recruiting_site_id
                         ,p_object_version_number => p_object_version_number
                         );
  --
  if ((l_api_updating and nvl(irc_rse_shd.g_old_rec.posting_cost_period,
                                 hr_api.g_varchar2)
                <> nvl(p_posting_cost_period, hr_api.g_varchar2)
      or p_posting_cost_period is not null)
  or
    (NOT l_api_updating and
     p_posting_cost_period is not null)) then
    --
    hr_utility.set_location(l_proc, 2);
    --
    -- Check the value in p_posting_cost_period exists in hr_lookups
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date => p_effective_date
      ,p_lookup_type    => 'IRC_POSTING_COST_FREQ'
      ,p_lookup_code    => p_posting_cost_period
      ) then
      hr_utility.set_location(l_proc, 10);
      hr_utility.set_location(p_posting_cost_period, 10);
      hr_utility.set_location(to_char(p_effective_date,'DD/MM/YYYY'), 10);
      hr_utility.set_message(800,'IRC_412103_BAD_LOOKUP_PERIOD');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 15);
  end if;
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_ALL_RECRUITING_SITES.POSTING_COST_PERIOD'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,80);
      raise;
    end if;
    hr_utility.set_location(' Leaving exception handler:'||l_proc,90);
end chk_posting_cost_period;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_posting_cost >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Check that if any of the following fields are entered, all of them must be
--   present: Posting Cost; Posting Cost Period; Currency
--
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_posting_cost
--  p_posting_cost_period
--  p_posting_cost_currency
--  p_effective_date
--  p_recruiting_site_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if all are present or none are present
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
Procedure chk_posting_cost
 (
  p_posting_cost   in irc_all_recruiting_sites.posting_cost%TYPE
 ,p_posting_cost_period in irc_all_recruiting_sites.posting_cost_period%TYPE
 ,p_posting_cost_currency in irc_all_recruiting_sites.posting_cost_currency%TYPE
 ,p_effective_date      in date
 ,p_recruiting_site_id  in irc_all_recruiting_sites.recruiting_site_id%TYPE
 ,p_object_version_number in irc_all_recruiting_sites.object_version_number%TYPE
 )
is
--
  l_proc        varchar2(72):=g_package||'chk_posting_cost';
  l_api_updating        boolean;
--
  l_posting_cost           irc_all_recruiting_sites.posting_cost%TYPE;
  l_posting_cost_period    irc_all_recruiting_sites.posting_cost_period%TYPE;
  l_posting_cost_currency irc_all_recruiting_sites.posting_cost_currency%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'effective_date'
    ,p_argument_value   => p_effective_date
    );
  --
  hr_utility.set_location(l_proc, 2);
  -- Only proceed with the validation if :
  --  a) The current g_old_rec is current
  --  b) The value has changed.
  --  c) A record is being inserted
  --
  l_api_updating  :=   irc_rse_shd.api_updating
                         (p_recruiting_site_id    => p_recruiting_site_id
                         ,p_object_version_number => p_object_version_number
                         );
  --
  hr_utility.set_location(l_proc, 3);
  if ((l_api_updating and (nvl(irc_rse_shd.g_old_rec.posting_cost,
                                 hr_api.g_number)
                          <> nvl(p_posting_cost , hr_api.g_number)
                        or nvl(irc_rse_shd.g_old_rec.posting_cost_period,
                                 hr_api.g_varchar2)
                          <> nvl(p_posting_cost_period, hr_api.g_varchar2)
                        or nvl(irc_rse_shd.g_old_rec.posting_cost_currency,
                                 hr_api.g_varchar2)
                          <> nvl(p_posting_cost_currency, hr_api.g_varchar2)
                          )
     )
  or
    (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 4);
    --
    -- Now, we know we're either inserting or updating one of the three
    -- values has changed.
    --
    if ((l_api_updating and p_posting_cost <> hr_api.g_number)
         or p_posting_cost is null
         or not l_api_updating) then
      hr_utility.set_location(l_proc, 10);
      l_posting_cost := p_posting_cost;
    else
      hr_utility.set_location(l_proc, 20);
      l_posting_cost := irc_rse_shd.g_old_rec.posting_cost;
    end if;
    --
    if ((l_api_updating and p_posting_cost_period <> hr_api.g_varchar2)
         or p_posting_cost_period is null
         or not l_api_updating) then
      hr_utility.set_location(l_proc, 30);
      l_posting_cost_period  := p_posting_cost_period;
    else
      hr_utility.set_location(l_proc, 40);
      l_posting_cost_period := irc_rse_shd.g_old_rec.posting_cost_period;
    end if;
    --
    hr_utility.set_location('posting_cost_currency:'||p_posting_cost_currency, 10);
    hr_utility.set_location('hr_api.g_varchar2:'||hr_api.g_varchar2, 10);
    if ((l_api_updating and p_posting_cost_currency <> hr_api.g_varchar2)
         or p_posting_cost_currency is null
         or not l_api_updating) then
      hr_utility.set_location(l_proc, 50);
      l_posting_cost_currency  := p_posting_cost_currency;
    else
      hr_utility.set_location(l_proc, 60);
      l_posting_cost_currency := irc_rse_shd.g_old_rec.posting_cost_currency;
    end if;
    --
    if  ( l_posting_cost_currency
       || l_posting_cost
       || l_posting_cost_period is not null
       and (  l_posting_cost_currency is null
            or l_posting_cost is null
            or l_posting_cost_period is null)
        )  then
      --
      hr_utility.set_location(l_proc,70);
      fnd_message.set_name('PER','IRC_412104_BAD_CURRENCY_COMBO');
      fnd_message.raise_error;
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 80);
  exception
   when app_exception.application_exception then
    hr_utility.set_location('exception handler'||l_proc, 90);
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_ALL_RECRUITING_SITES.POSTING_COST'
       ,p_associated_column2 =>
       'IRC_ALL_RECRUITING_SITES.POSTING_COST_PERIOD'
       ,p_associated_column3 =>
       'IRC_ALL_RECRUITING_SITES.POSTING_COST_CURRENCY'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,90);
      raise;
    end if;
    hr_utility.set_location(' Leaving exception handler:'||l_proc,100);
end chk_posting_cost;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_date_from_to>-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--  Validate the date_from and date_to fields to make sure
--      1) The date_to in on or after the date_from date
--   The date_from and the date_to can both (or either) be null.
--
-- Pre-conditions
--   None
--
-- In Arguments:
--   p_date_from
--   p_date_to
--   p_recruiting_site_id
--   p_object_version_number
--
-- Post Success:
--   If all test pass, processing continues.
-- Post Failure:
--   If the date_from is after the date_to, processing halts.
-- Access Status:
--   Internal Table Handler Use Only.
--
Procedure chk_date_from_to
 (p_date_from             in    irc_all_recruiting_sites.date_from%TYPE
 ,p_date_to               in    irc_all_recruiting_sites.date_to%TYPE
 ,p_recruiting_site_id    in    irc_all_recruiting_sites.recruiting_site_id%TYPE
 ,p_object_version_number in    irc_all_recruiting_sites.object_version_number%TYPE
 )
is
--
  l_proc                varchar2(72):=g_package||'chk_date_from_to';
  l_api_updating        boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --
  -- Only proceed with the validation if :
  --  a) The current g_old_rec is current.
  --  b) The date_from has changed.
  --  c) The date_to has changed.
  --  d) a record is being inserted.
  --
  l_api_updating := irc_rse_shd.api_updating
    (p_recruiting_site_id       => p_recruiting_site_id
    ,p_object_version_number    => p_object_version_number
    );
  --
  if (((l_api_updating and nvl(irc_rse_shd.g_old_rec.date_from,
                                hr_api.g_date)
                        <> nvl(p_date_from, hr_api.g_date))
      or
        (l_api_updating and nvl(irc_rse_shd.g_old_rec.date_to,
                                 hr_api.g_date)
                        <> nvl(p_date_to, hr_api.g_date))
       )
  or
    (NOT l_api_updating)) then
    --
    -- If the date_from is greater then the date_to, raise an error
    --
    if ((p_date_from is not null) and (p_date_to is not null)
        and (p_date_from > p_date_to)) then
      --
      hr_utility.set_message(800,'IRC_412107_RSE_DATE_FR_DATE_T0');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 15);
  --
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_ALL_RECRUITING_SITES.DATE_FROM'
       ,p_associated_column2 =>
       'IRC_ALL_RECRUITING_SITES.DATE_TO'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,80);
      raise;
    end if;
    hr_utility.set_location(' Leaving exception handler:'||l_proc,90);
end chk_date_from_to;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in irc_rse_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  --
  -- Validate Dependent Attributes
  chk_internal
    ( p_internal              => p_rec.internal
    , p_recruiting_site_id    => p_rec.recruiting_site_id
    , p_object_version_number => p_rec.object_version_number
    );
  --
  chk_external
    ( p_external              => p_rec.external
    , p_recruiting_site_id    => p_rec.recruiting_site_id
    , p_object_version_number => p_rec.object_version_number
    );
  --
  chk_third_party
    (p_third_party            => p_rec.third_party
    ,p_internal               => p_rec.internal
    ,p_external               => p_rec.external
    ,p_recruiting_site_id    => p_rec.recruiting_site_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  chk_posting_cost_period
    ( p_posting_cost_period   => p_rec.posting_cost_period
    , p_effective_date        => p_effective_date
    , p_recruiting_site_id    => p_rec.recruiting_site_id
    , p_object_version_number => p_rec.object_version_number
    );
  --
  chk_posting_cost
    ( p_posting_cost          => p_rec.posting_cost
    , p_posting_cost_period   => p_rec.posting_cost_period
    , p_posting_cost_currency => p_rec.posting_cost_currency
    , p_effective_date        => p_effective_date
    , p_recruiting_site_id    => p_rec.recruiting_site_id
    , p_object_version_number => p_rec.object_version_number
    );
  --
  chk_date_from_to
   ( p_date_from             => p_rec.date_from
   , p_date_to               => p_rec.date_to
   , p_recruiting_site_id    => p_rec.recruiting_site_id
   , p_object_version_number => p_rec.object_version_number
   );
  --
  irc_rse_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_rse_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  chk_internal
    ( p_internal              => p_rec.internal
    , p_recruiting_site_id    => p_rec.recruiting_site_id
    , p_object_version_number => p_rec.object_version_number
    );
  --
  chk_external
    ( p_external              => p_rec.external
    , p_recruiting_site_id    => p_rec.recruiting_site_id
    , p_object_version_number => p_rec.object_version_number
    );
  --
  chk_third_party
    (p_third_party              => p_rec.third_party
    ,p_internal               => p_rec.internal
    ,p_external               => p_rec.external
    ,p_recruiting_site_id    => p_rec.recruiting_site_id
    ,p_object_version_number => p_rec.object_version_number
    );
  --
  chk_posting_cost_period
    ( p_posting_cost_period   => p_rec.posting_cost_period
    , p_effective_date        => p_effective_date
    , p_recruiting_site_id    => p_rec.recruiting_site_id
    , p_object_version_number => p_rec.object_version_number
    );
  --
  chk_posting_cost
    ( p_posting_cost          => p_rec.posting_cost
    , p_posting_cost_period   => p_rec.posting_cost_period
    , p_posting_cost_currency => p_rec.posting_cost_currency
    , p_effective_date        => p_effective_date
    , p_recruiting_site_id    => p_rec.recruiting_site_id
    , p_object_version_number => p_rec.object_version_number
    );
  --
  chk_date_from_to
   ( p_date_from             => p_rec.date_from
   , p_date_to               => p_rec.date_to
   , p_recruiting_site_id    => p_rec.recruiting_site_id
   , p_object_version_number => p_rec.object_version_number
   );
  --
  irc_rse_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_rse_shd.g_rec_type
  ) is
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
end irc_rse_bus;

/
