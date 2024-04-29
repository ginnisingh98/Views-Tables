--------------------------------------------------------
--  DDL for Package Body OTA_CMB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CMB_BUS" as
/* $Header: otcmbrhi.pkb 120.5 2005/08/19 17:58 gdhutton noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_cmb_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_certification_member_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_certification_member_id              in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_certification_members cmb
     where cmb.certification_member_id = p_certification_member_id
       and pbg.business_group_id = cmb.business_group_id;
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
    ,p_argument           => 'certification_member_id'
    ,p_argument_value     => p_certification_member_id
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
        => nvl(p_associated_column1,'CERTIFICATION_MEMBER_ID')
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
  (p_certification_member_id              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_certification_members cmb
     where cmb.certification_member_id = p_certification_member_id
       and pbg.business_group_id = cmb.business_group_id;
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
    ,p_argument           => 'certification_member_id'
    ,p_argument_value     => p_certification_member_id
    );
  --
  if ( nvl(ota_cmb_bus.g_certification_member_id, hr_api.g_number)
       = p_certification_member_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_cmb_bus.g_legislation_code;
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
    ota_cmb_bus.g_certification_member_id     := p_certification_member_id;
    ota_cmb_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in ota_cmb_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.certification_member_id is not null)  and (
    nvl(ota_cmb_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(ota_cmb_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.certification_member_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_CERTIFICATION_MEMBERS'
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
  ,p_rec in ota_cmb_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_cmb_shd.api_updating
      (p_certification_member_id           => p_rec.certification_member_id
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
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_act_version_dates >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_act_version_dates
  (
    p_activity_version_id           in number
   ,p_cmb_start_date       in date
   ,p_cmb_end_date          in date
   ) is
   --
   -- Declare cursors and local variables
   --
   --
   -- Cursor to get activity version start and end date

   CURSOR csr_av_start_end_date is
      SELECT
         start_date,
         nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY'))
      FROM ota_activity_versions
      WHERE activity_version_id = p_activity_version_id;

  --
  -- Variables
  l_proc        varchar2(72) := g_package||'check_act_version_dates';
  l_av_start_date         date;
  l_av_end_date           date;
  l_cmb_start_date        date;
  l_cmb_end_date          date;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  IF hr_multi_message.no_exclusive_error
             (p_check_column1   => 'OTA_CERTIFICATION_MEMBERS.START_DATE_ACTIVE'
             ,p_check_column2   => 'OTA_CERTIFICATION_MEMBERS.END_DATE_ACTIVE'
             ,p_associated_column1  => 'OTA_CERTIFICATION_MEMBERS.START_DATE_ACTIVE'
			 ,p_associated_column2  => 'OTA_CERTIFICATION_MEMBERS.END_DATE_ACTIVE'
			 ) THEN

		 --
		 OPEN csr_av_start_end_date;
		 FETCH csr_av_start_end_date into l_av_start_date, l_av_end_date;
		 CLOSE csr_av_start_end_date;

		 if p_cmb_start_date is not null and p_cmb_end_date is not null
		    and p_cmb_start_date > p_cmb_end_date then
                fnd_message.set_name('OTA','OTA_13312_GEN_DATE_ORDER');
                fnd_message.raise_error;
         end if;

		 if l_av_start_date is null then
           l_av_start_date := hr_api.g_sot;
  		 end if;

         if l_av_end_date is null then
            l_av_end_date := hr_api.g_eot;
         end if;

   		 --
  		 l_cmb_start_date := p_cmb_start_date;
  		 l_cmb_end_date   := p_cmb_end_date;
  		 --
  		 if l_cmb_end_date is null then
    		l_cmb_end_date := hr_api.g_eot;
  		 end if;

  		 if l_cmb_start_date < l_av_start_date or
            l_cmb_start_date > l_av_end_date or
            l_cmb_end_date > l_av_end_date or
            l_cmb_end_date < l_av_start_date then

	        fnd_message.set_name('OTA','OTA_443911_CMB_OUT_OF_AV_DATE');
            fnd_message.raise_error;
         end if;

	END IF;
	--
	hr_utility.set_location(' Leaving:' || l_proc,10);

 Exception
   when app_exception.application_exception then
      IF hr_multi_message.exception_add
            (p_associated_column1 => 'OTA_CERTIFICATION_MEMBERS.START_DATE_ACTIVE'
            ,p_associated_column2 => 'OTA_CERTIFICATION_MEMBERS.END_DATE_ACTIVE'
            ) THEN
          raise;
       END IF;

     --
End chk_act_version_dates;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_cert_dates >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_cert_dates
  (
    p_certification_id           in number
   ,p_cmb_start_date       in date
   ,p_cmb_end_date          in date
   ) is
   --
   -- Declare cursors and local variables
   --
   --
   -- Cursor to get certification start and end date

   CURSOR csr_cert_start_end_date is
      SELECT
         start_date_active,
         nvl(end_date_active, to_date('31-12-4712', 'DD-MM-YYYY'))
      FROM ota_certifications_b
      WHERE certification_id = p_certification_id;

  --
  -- Variables
  l_proc        varchar2(72) := g_package||'check_cert_dates';
  l_cert_start_date         date;
  l_cert_end_date           date;
  l_cmb_start_date        date;
  l_cmb_end_date          date;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  IF hr_multi_message.no_exclusive_error
             (p_check_column1   => 'OTA_CERTIFICATION_MEMBERS.START_DATE_ACTIVE'
             ,p_check_column2   => 'OTA_CERTIFICATION_MEMBERS.END_DATE_ACTIVE'
             ,p_associated_column1  => 'OTA_CERTIFICATION_MEMBERS.START_DATE_ACTIVE'
			 ,p_associated_column2  => 'OTA_CERTIFICATION_MEMBERS.END_DATE_ACTIVE'
			 ) THEN

		 --
		 OPEN csr_cert_start_end_date;
		 FETCH csr_cert_start_end_date into l_cert_start_date, l_cert_end_date;
		 CLOSE csr_cert_start_end_date;

		 if p_cmb_start_date is not null and p_cmb_end_date is not null
		    and p_cmb_start_date > p_cmb_end_date then
                fnd_message.set_name('OTA','OTA_13312_GEN_DATE_ORDER');
                fnd_message.raise_error;
         end if;

		 if l_cert_start_date is null then
           l_cert_start_date := hr_api.g_sot;
  		 end if;

         if l_cert_end_date is null then
            l_cert_end_date := hr_api.g_eot;
         end if;

   		 --
  		 l_cmb_start_date := p_cmb_start_date;
  		 l_cmb_end_date   := p_cmb_end_date;
  		 --
  		 if l_cmb_end_date is null then
    		l_cmb_end_date := hr_api.g_eot;
  		 end if;

  		 if l_cmb_start_date < l_cert_start_date or
            l_cmb_start_date > l_cert_end_date or
            l_cmb_end_date > l_cert_end_date or
            l_cmb_end_date < l_cert_start_date then

	        fnd_message.set_name('OTA','OTA_443918_CMB_OUT_OF_CRT_DATE');
            fnd_message.raise_error;
         end if;

	END IF;
	--
	hr_utility.set_location(' Leaving:' || l_proc,10);

 Exception
   when app_exception.application_exception then
      IF hr_multi_message.exception_add
            (p_associated_column1 => 'OTA_CERTIFICATION_MEMBERS.START_DATE_ACTIVE'
            ,p_associated_column2 => 'OTA_CERTIFICATION_MEMBERS.END_DATE_ACTIVE'
            ) THEN
          raise;
       END IF;

     --
End chk_cert_dates;

-- ----------------------------------------------------------------------------
-- |--------------------------< chk_dup_cmb_dates >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_dup_cmb_dates
  (
    p_activity_version_id           in number
   ,p_certification_id     in number
   ,p_cmb_start_date       in date
   ,p_cmb_end_date          in date
   ,p_cert_member_id       in number
   ) is
   --
   -- Declare cursors and local variables
   --
   --
   -- Cursor to get other certification components with the same activity_version

   CURSOR csr_dup_cmb(p_activity_version_id ota_certification_members.object_id%type,
                      p_certification_id ota_certification_members.certification_id%type,
                      p_certification_member_id ota_certification_members.certification_member_id%type)
    is
      SELECT
         start_date_active,
         end_date_active
      FROM ota_certification_members
      WHERE certification_id = p_certification_id
	  and object_id = p_activity_version_id
	  and object_type = 'H'
	  and (p_certification_member_id is null OR not certification_member_id = p_certification_member_id);

  --
  -- Variables
  l_proc        varchar2(72) := g_package||'chk_dup_cmb_dates';
  l_dup_cmb_start_date  date;
  l_dup_cmb_end_date    date;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  IF hr_multi_message.no_exclusive_error
             (p_check_column1   => 'OTA_CERTIFICATION_MEMBERS.START_DATE_ACTIVE'
             ,p_check_column2   => 'OTA_CERTIFICATION_MEMBERS.END_DATE_ACTIVE'
             ,p_associated_column1  => 'OTA_CERTIFICATION_MEMBERS.START_DATE_ACTIVE'
			 ,p_associated_column2  => 'OTA_CERTIFICATION_MEMBERS.END_DATE_ACTIVE'
			 ) THEN

	for a_dup_cmb in csr_dup_cmb(p_activity_version_id, p_certification_id, p_cert_member_id) loop

	  if (p_cmb_start_date >= a_dup_cmb.start_date_active
			and p_cmb_start_date <= nvl(a_dup_cmb.end_date_active, hr_api.g_eot))
	  OR (nvl(p_cmb_end_date, hr_api.g_eot) >= a_dup_cmb.start_date_active
			and nvl(p_cmb_end_date, hr_api.g_eot) <= nvl(a_dup_cmb.end_date_active, hr_api.g_eot))
	  OR (a_dup_cmb.start_date_active >= p_cmb_start_date
	        and a_dup_cmb.start_date_active <= nvl(p_cmb_end_date, hr_api.g_eot))
	  OR (nvl(a_dup_cmb.end_date_active, hr_api.g_eot) >= p_cmb_start_date
	        and nvl(a_dup_cmb.end_date_active, hr_api.g_eot) <= nvl(p_cmb_end_date, hr_api.g_eot))
	  then
	          fnd_message.set_name('OTA','OTA_443927_CMB_DUPLICATE');
              fnd_message.raise_error;
      end if;

   end loop;
  END IF;
	hr_utility.set_location(' Leaving:' || l_proc,10);

 Exception
   when app_exception.application_exception then
      IF hr_multi_message.exception_add
            (p_associated_column1 => 'OTA_CERTIFICATION_MEMBERS.START_DATE_ACTIVE'
            ,p_associated_column2 => 'OTA_CERTIFICATION_MEMBERS.END_DATE_ACTIVE'
            ) THEN
          raise;
       END IF;

     --
End chk_dup_cmb_dates;
--

-- ----------------------------------------------------------------------------
-- |--------------------------< chk_dup_cmb_dates >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_dup_cmb_dates
  (
    p_activity_version_id           in number
   ,p_certification_id     in number
   ,p_cmb_start_date       in date
   ,p_cmb_end_date          in date
   ,p_cert_member_id       in number
   ,p_return_status OUT  NOCOPY VARCHAR2
   ) is
   --
   -- Declare cursors and local variables
   --
   --
   -- Cursor to get other certification components with the same activity_version

   CURSOR csr_dup_cmb(p_activity_version_id ota_certification_members.object_id%type,
                      p_certification_id ota_certification_members.certification_id%type,
                      p_certification_member_id ota_certification_members.certification_member_id%type)
    is
      SELECT
         start_date_active,
         end_date_active
      FROM ota_certification_members
      WHERE certification_id = p_certification_id
	  and object_id = p_activity_version_id
	  and object_type = 'H'
	  and (p_certification_member_id is null OR not certification_member_id = p_certification_member_id);

  --
  -- Variables
  l_proc        varchar2(72) := g_package||'chk_dup_cmb_dates';
  l_dup_cmb_start_date  date;
  l_dup_cmb_end_date    date;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

  p_return_status := 'S';

  IF hr_multi_message.no_exclusive_error
             (p_check_column1   => 'OTA_CERTIFICATION_MEMBERS.START_DATE_ACTIVE'
             ,p_check_column2   => 'OTA_CERTIFICATION_MEMBERS.END_DATE_ACTIVE'
             ,p_associated_column1  => 'OTA_CERTIFICATION_MEMBERS.START_DATE_ACTIVE'
			 ,p_associated_column2  => 'OTA_CERTIFICATION_MEMBERS.END_DATE_ACTIVE'
			 ) THEN

	for a_dup_cmb in csr_dup_cmb(p_activity_version_id, p_certification_id, p_cert_member_id) loop

	  if (p_cmb_start_date >= a_dup_cmb.start_date_active
			and p_cmb_start_date <= nvl(a_dup_cmb.end_date_active, hr_api.g_eot))
	  OR (nvl(p_cmb_end_date, hr_api.g_eot) >= a_dup_cmb.start_date_active
			and nvl(p_cmb_end_date, hr_api.g_eot) <= nvl(a_dup_cmb.end_date_active, hr_api.g_eot))
	  OR (a_dup_cmb.start_date_active >= p_cmb_start_date
	        and a_dup_cmb.start_date_active <= nvl(p_cmb_end_date, hr_api.g_eot))
	  OR (nvl(a_dup_cmb.end_date_active, hr_api.g_eot) >= p_cmb_start_date
	        and nvl(a_dup_cmb.end_date_active, hr_api.g_eot) <= nvl(p_cmb_end_date, hr_api.g_eot))
	  then
	          p_return_status := 'E';
      end if;

   end loop;
  END IF;
	hr_utility.set_location(' Leaving:' || l_proc,10);

     --
End chk_dup_cmb_dates;
--
--
PROCEDURE chk_if_dup_cmb_exists
  (p_object_id    IN     ota_certification_members.object_id%TYPE
  ,p_certification_id  IN ota_certification_members.certification_id%TYPE
   , p_return_status OUT  NOCOPY VARCHAR2)
  IS
--
--
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'chk_if_dup_cmb_exists';
  --
  cursor sel_cmb_exists(p_object_id ota_certification_members.object_id%type,
                       p_certification_id ota_certification_members.certification_id%type) is
    select 'Y'
      from ota_certification_members cmb
     where cmb.object_id = p_object_id
	 and cmb.certification_id = p_certification_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --

  p_return_status := 'S';

  Open  sel_cmb_exists(p_object_id, p_certification_id);
  fetch sel_cmb_exists into v_exists;
  --
  if sel_cmb_exists%found then
    --
    close sel_cmb_exists;
    --
    p_return_status := 'E';
      --
  else
    close sel_cmb_exists;

  end if;
  --

  hr_utility.set_location(' Step:'|| v_proc, 30);

END chk_if_dup_cmb_exists;

PROCEDURE chk_should_warn_delete
  (p_cert_mbr_id    IN     ota_certification_members.certification_member_id%TYPE
   , p_return_status OUT  NOCOPY VARCHAR2)
  IS
--
  v_proc                  varchar2(72) := g_package||'chk_should_warn_delete';
  --
  cursor csr_cmb_info(p_cert_mbr_id ota_certification_members.certification_member_id%type) is
    select certification_id
    from   ota_certification_members
    where  certification_member_id = p_cert_mbr_id and
           (end_date_active is null or
            end_date_active > sysdate);

  cursor csr_cmb_exists(
    p_cert_mbr_id ota_certification_members.certification_member_id%type,
    p_certification_id ota_certifications_b.certification_id%type) is
    select 'Y'
      from ota_certification_members cmb
    where cmb.certification_id = p_certification_id
          and cmb.certification_member_id <> p_cert_mbr_id
          and (cmb.end_date_active is null or
               cmb.end_date_active > sysdate);
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --

  p_return_status := 'S';

  for a_cmb in csr_cmb_info(p_cert_mbr_id) loop

    for another_cmb in csr_cmb_exists(p_cert_mbr_id, a_cmb.certification_id) loop
      -- There is at least one more cert member, no need to warn, just return.
      hr_utility.set_location(' Step:'|| v_proc, 30);
      return;
    end loop;

    -- No other current cert members exist, so we need to warn about
    -- deleting this one.
    p_return_status := 'E';

  end loop;

  hr_utility.set_location(' Step:'|| v_proc, 30);

END chk_should_warn_delete;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_cmb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ota_cmb_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  hr_utility.set_location(' Step:'|| l_proc,10);
  --
  -- Validate Dependent Attributes
  --
  --

  ota_cmb_bus.chk_act_version_dates(p_activity_version_id  => p_rec.object_id
                              ,p_cmb_start_date => p_rec.start_date_active
							  ,p_cmb_end_date => p_rec.end_date_active);

  ota_cmb_bus.chk_cert_dates(p_certification_id  => p_rec.certification_id
                              ,p_cmb_start_date => p_rec.start_date_active
							  ,p_cmb_end_date => p_rec.end_date_active);

  ota_cmb_bus.chk_dup_cmb_dates(p_activity_version_id => p_rec.object_id
                               ,p_certification_id    => p_rec.certification_id
                               ,p_cmb_start_date      => p_rec.start_date_active
   							   ,p_cmb_end_date        => p_rec.end_date_active
							   ,p_cert_member_id      => p_rec.certification_member_id);

  ota_cmb_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_cmb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ota_cmb_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  ota_cmb_bus.chk_act_version_dates(p_activity_version_id  => p_rec.object_id
                              ,p_cmb_start_date => p_rec.start_date_active
							  ,p_cmb_end_date => p_rec.end_date_active);

  ota_cmb_bus.chk_cert_dates(p_certification_id  => p_rec.certification_id
                              ,p_cmb_start_date => p_rec.start_date_active
							  ,p_cmb_end_date => p_rec.end_date_active);


  ota_cmb_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_cmb_shd.g_rec_type
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
end ota_cmb_bus;

/
