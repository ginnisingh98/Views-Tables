--------------------------------------------------------
--  DDL for Package Body OTA_OFF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OFF_BUS" as
/* $Header: otoffrhi.pkb 120.1.12000000.2 2007/02/06 15:25:23 vkkolla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_off_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_offering_id                 number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_offering_id                          in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_offerings off
     where off.offering_id = p_offering_id
       and pbg.business_group_id = off.business_group_id;
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
    ,p_argument           => 'offering_id'
    ,p_argument_value     => p_offering_id
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
        => nvl(p_associated_column1,'OFFERING_ID')
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
  (p_offering_id                          in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_offerings off
     where off.offering_id = p_offering_id
       and pbg.business_group_id = off.business_group_id;
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
    ,p_argument           => 'offering_id'
    ,p_argument_value     => p_offering_id
    );
  --
  if ( nvl(ota_off_bus.g_offering_id, hr_api.g_number)
       = p_offering_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_off_bus.g_legislation_code;
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
    ota_off_bus.g_offering_id                 := p_offering_id;
    ota_off_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< call_error_message >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Passes the error information to the procedure set_message of package
--   hr_utility.
--
Procedure call_error_message
  (
   p_error_appl             varchar2
  ,p_error_txt              varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'call_error_message';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- ** TEMP ** Add error message with the following text.
  --
  fnd_message.set_name      ( p_error_appl     ,p_error_txt);
  fnd_message.raise_error;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End call_error_message;
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
  (p_rec in ota_off_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.offering_id is not null)  and (
    nvl(ota_off_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(ota_off_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.offering_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_OFFERINGS'
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
  ,p_rec in ota_off_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_off_shd.api_updating
      (p_offering_id                       => p_rec.offering_id
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
-------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |----------------------< Chk_Dm_Start_End_Date >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Chk_Dm_Start_End_Date
  (p_delivery_mode_id             in            number
  ,p_start_date                   in            date
  ,p_end_date                     in            date
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_dm_start_end_date is
    select
      ctu.start_date_active,
      ctu.end_date_active
    from
      ota_category_usages ctu
    where
      ctu.category_usage_id = p_delivery_mode_id;
  --
  -- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'Chk_Dm_Start_End_Date';
  v_start_date        date;
  v_end_date          date;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

     OPEN cur_dm_start_end_date;
     FETCH cur_dm_start_end_date into v_start_date, v_end_date;

     -- Assignment if v_start_date or v_end_date is null
/*
    If p_end_date is null Then
       p_end_date := v_end_date;
    End if;
 */
    If ota_general.check_par_child_dates_fun(v_start_date,
                                             v_end_date,
                                             NVL(p_start_date, hr_api.g_sot),
                                             NVL(p_end_date, hr_api.g_eot) ) then
    --
       fnd_message.set_name      ( 'OTA','OTA_443459_OFF_OUT_OF_DM_DATES');
       fnd_message.raise_error;
    End If;

  --
    CLOSE cur_dm_start_end_date;

  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_OFFERINGS.START_DATE'
                 ,p_associated_column2   => 'OTA_OFFERINGS.END_DATE'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_Dm_Start_End_Date;
--
-- ----------------------------------------------------------------------------
-- -------------------------< CLASS_DATES_ARE_VALID >-------------------------
-- ----------------------------------------------------------------------------
--
--	Checks if classes are within the parent offering start date
--      and end date.
--      N.B. Planned classes may have NULL Dates
--
--

procedure CLASS_DATES_ARE_VALID (p_offering_id in number,
                                  p_start_date          in date,
                                  p_end_date            in date
                                  ) is
--
  l_proc       varchar2(30) := 'CLASS_DATES_ARE_VALID';
  l_start_date date;
  l_end_date   date;
  l_evt_start_date date;
  l_evt_end_date date;
  l_event_status varchar2(1);
--
  cursor events is
    select course_start_date, course_end_date ,event_status
    from ota_events
    where parent_offering_id = p_offering_id;
begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  hr_utility.trace('p_offering_id'||p_offering_id);
  hr_utility.trace('p_start_date'||p_start_date);
  hr_utility.trace('p_end_date'||p_end_date);

  --
  l_start_date := p_start_date;
  l_end_date   := p_end_date;
  --
  if l_start_date is null then
    l_start_date := hr_api.g_sot;
  end if;
  if l_end_date is null then
    l_end_date := hr_api.g_eot;
  end if;
  --
  for v_events in events
	  loop
	  --
	  l_evt_start_date := v_events.course_start_date;
	  l_evt_end_date:=  v_events.course_end_date;
	  l_event_status:= v_events.event_status;
	  --
	  if l_event_status = 'P' then
	     if l_evt_start_date is null then
		l_evt_start_date := l_start_date;
	     end if;
	     if l_evt_end_date is null then
		l_evt_end_date := l_end_date;
	     end if;
	  end if;
	  --
	  if l_evt_end_date is null then
	    l_evt_end_date := hr_api.g_eot;
	  end if;
          --
	  if l_evt_start_date < l_start_date or
	     l_evt_start_date > l_end_date or
	     l_evt_end_date > l_end_date or
	     l_evt_end_date < l_start_date then
	     fnd_message.set_name('OTA','OTA_443375_OFF_CLASS_DATES');
	     fnd_message.raise_error;
	  end if;
	  end loop;
  --
  hr_utility.set_location(' Exiting:'||l_proc,10);
Exception
WHEN app_exception.application_exception THEN

       IF hr_multi_message.exception_add(
	    p_associated_column1    => 'OTA_OFFERINGS.START_DATE',
	    p_associated_column2    => 'OTA_OFFERINGS.END_DATE')
				   THEN

	   --hr_utility.set_location(' Leaving:'||v_proc, 22);
	   RAISE;

       END IF;
end CLASS_DATES_ARE_VALID;
-------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- -------------------------< OFFERING_DATES_ARE_VALID >-------------------------
-- ----------------------------------------------------------------------------
--
--	Checks if offerings are within the parent course start date
--      and end date.
--
--
procedure OFFERING_DATES_ARE_VALID (p_activity_version_id in number,
                                  p_offering_start_date          in date,
                                  p_offering_end_date            in date ) is
--
  l_proc       varchar2(30) := 'course_dates_are_valid';
  l_start_date date;
  l_end_date   date;
  l_offering_start_date date;
  l_offering_end_date date;
--
  cursor check_dates is
    select start_date, end_date
    from ota_activity_versions
    where activity_version_id = p_activity_version_id;
begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  hr_utility.trace('p_activity_version_id'||p_activity_version_id);
  hr_utility.trace('p_offering_start_date'||p_offering_start_date);
  hr_utility.trace('p_offering_end_date'||p_offering_end_date);
  --
  open check_dates;
  fetch check_dates into l_start_date, l_end_date;
  close check_dates;
  --
  if p_offering_start_date is not null and p_offering_end_date is not null and p_offering_start_date > p_offering_end_date then
     fnd_message.set_name('OTA','OTA_13312_GEN_DATE_ORDER');
     fnd_message.raise_error;
  end if;

  if l_start_date is null then
    l_start_date := hr_api.g_sot;
  end if;

  if l_end_date is null then
    l_end_date := hr_api.g_eot;
  end if;
  --
  l_offering_start_date := p_offering_start_date;
  l_offering_end_date   := p_offering_end_date;
  --
  if l_offering_end_date is null then
    l_offering_end_date := hr_api.g_eot;
  end if;
  --
  --
  -- Added extra conditions to handle development events
  --
  if l_offering_start_date < l_start_date or
     l_offering_start_date > l_end_date or
     l_offering_end_date > l_end_date or
     l_offering_end_date < l_start_date then
     fnd_message.set_name('OTA','OTA_443316_OFF_INVALID_DATES');
     fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(' Exiting:'||l_proc,10);
Exception
WHEN app_exception.application_exception THEN

       IF hr_multi_message.exception_add(
	    p_associated_column1    => 'OTA_OFFERINGS.START_DATE',
	    p_associated_column2    => 'OTA_OFFERINGS.END_DATE')
				   THEN

	   --hr_utility.set_location(' Leaving:'||v_proc, 22);
	   RAISE;

       END IF;
end OFFERING_DATES_ARE_VALID;
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_competency_update_level  >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_competency_update_level (p_offering_id                     IN number
                                   ,p_object_version_number                IN NUMBER
                                   ,p_competency_update_level                 IN VARCHAR2
                                   ,p_effective_date                       IN date) IS

--
  l_proc  VARCHAR2(72) := g_package||'chk_competency_update_level';
  l_api_updating boolean;

BEGIN
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
     ,p_argument        => 'effective_date'
     ,p_argument_value  => p_effective_date);

  l_api_updating := ota_off_shd.api_updating
    (p_offering_id          => p_offering_id
    ,p_object_version_number     => p_object_version_number);


IF ((l_api_updating AND
       NVL(ota_off_shd.g_old_rec.competency_update_level,hr_api.g_varchar2) <>
         NVL(p_competency_update_level, hr_api.g_varchar2))
     OR NOT l_api_updating AND p_competency_update_level IS NOT NULL) THEN

       hr_utility.set_location(' Leaving:'||l_proc, 20);
       --

       IF p_competency_update_level IS NOT NULL THEN
          IF hr_api.not_exists_in_hr_lookups
             (p_effective_date => p_effective_date
              ,p_lookup_type => 'OTA_COMPETENCY_UPDATE_LEVEL'
              ,p_lookup_code => p_competency_update_level) THEN
              fnd_message.set_name('OTA','OTA_443411_COMP_UPD_LEV_INVLD');
               fnd_message.raise_error;
          END IF;
           hr_utility.set_location(' Leaving:'||l_proc, 30);

       END IF;

   END IF;
 hr_utility.set_location(' Leaving:'||l_proc, 40);

 EXCEPTION

    WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_OFFERINGS.COMPETENCY_UPDATE_LEVEL') THEN

                     hr_utility.set_location(' Leaving:'||l_proc, 42);
                        RAISE;
            END IF;

              hr_utility.set_location(' Leaving:'||l_proc, 44);

END chk_competency_update_level;

--
-- ----------------------------------------------------------------------------
-- -----------------------< CHECK_UNIQUE >----------------------------
-- ----------------------------------------------------------------------------
--
--	Validates the uniqueness of the event title (ignoring case).
--
procedure CHECK_UNIQUE (
	P_NAME					     in	varchar2,
	P_BUSINESS_GROUP_ID			     in	number,
	P_ACTIVITY_VERSION_ID			     in number,
	P_OFFERING_ID                    in number
	) is
	--
	W_PROC						varchar2 (72)
		:= G_PACKAGE || 'CHECK_UNIQUE';
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Do not perform the uniqueness check unless inserting, or updating
	--	with a value different from the current value (and not just changing
	--	case)
	--
		--
		if (not UNIQUE_OFFERING_TITLE (
				P_NAME 		         =>  P_NAME,
				P_BUSINESS_GROUP_ID      =>  P_BUSINESS_GROUP_ID,
				P_ACTIVITY_VERSION_ID    =>  P_ACTIVITY_VERSION_ID,
				P_OFFERING_ID            =>  P_OFFERING_ID)) then
                fnd_message.set_name('OTA','OTA_443317_OFF_UNIQUE');
			    fnd_message.raise_error;
		--
	end if;
	--
	HR_UTILITY.SET_LOCATION (' Leaving:' || W_PROC, 10);
	--
Exception
WHEN app_exception.application_exception THEN

       IF hr_multi_message.exception_add(
	    p_associated_column1    => 'OTA_OFFERINGS.BUSINESS_GROUP_ID',
	    p_associated_column2    => 'OTA_OFFERINGS.DELIVERY_MODE_ID')
				   THEN

	   --hr_utility.set_location(' Leaving:'||v_proc, 22);
	   RAISE;

       END IF;

end CHECK_UNIQUE;
--------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- -------------------------< UNIQUE_OFFERING_TITLE >-----------------------------
-- ----------------------------------------------------------------------------
--
--	Returns TRUE if the event has a title which is unique within its
--	business group. If the event id is not null, then the check avoids
--	comparing the title against itself. Titles are compared regardless
--	of case.
--
--
--
function UNIQUE_OFFERING_TITLE (
	P_NAME  					     in	varchar2,
	P_BUSINESS_GROUP_ID			     in	number,
	P_ACTIVITY_VERSION_ID			     in number,
	P_OFFERING_ID                    in number
	) return boolean is
--
	W_PROC						 varchar2 (72)
		:= G_PACKAGE || 'UNIQUE_OFFERING_TITLE';
	W_TITLE_IS_UNIQUE				boolean;
	--
	cursor C1 is
		SELECT 1 FROM OTA_OFFERINGS_VL OFF
		WHERE OFF.NAME  = P_NAME
		AND   OFF.ACTIVITY_VERSION_ID = P_ACTIVITY_VERSION_ID
		AND   OFF.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
                AND (  OFF.OFFERING_ID <> P_OFFERING_ID or P_OFFERING_ID IS NULL ) ;
    l_num number(10);
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Check arguments
	--
	HR_API.MANDATORY_ARG_ERROR (
		G_PACKAGE,
	 	'P_NAME',
		P_NAME);
	HR_API.MANDATORY_ARG_ERROR (
		G_PACKAGE,
		'P_BUSINESS_GROUP_ID',
		P_BUSINESS_GROUP_ID);
	--
	--	Unique ?
	--
	open C1;
	fetch C1
	  into l_num;
	W_TITLE_IS_UNIQUE := C1%notfound;
	close C1;
	--
	HR_UTILITY.SET_LOCATION (W_PROC, 10);
	return W_TITLE_IS_UNIQUE;
	--
end UNIQUE_OFFERING_TITLE;
--
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_is_test_selected >-------------------------|
-- ----------------------------------------------------------------------------
-- Added for Bug 3486188. This procedure throws an error if the show toolbar flag
-- or the Exit button for a test learning object is set to No.
--
--
Procedure check_is_test_selected (p_offering_id           IN ota_offerings.offering_id%TYPE,
		                  p_learning_object_id    IN ota_offerings.learning_object_id%TYPE,
                                  p_player_toolbar_flag   IN ota_offerings.player_toolbar_flag%TYPE,
                                  p_player_toolbar_bitset IN ota_offerings.player_toolbar_bitset%TYPE)
Is
	l_proc  varchar2(72) := g_package||'check_is_test_selected';

CURSOR c_is_test
    IS
SELECT test_id
  FROM ota_learning_objects
 WHERE learning_object_id = p_learning_object_id;

l_test_id  ota_learning_objects.test_id%TYPE;

Begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
          OPEN c_is_test;
    	 FETCH c_is_test into l_test_id;
         CLOSE c_is_test;

 IF l_test_id IS NOT NULL THEN
          IF p_player_toolbar_flag = 'N' THEN
             fnd_message.set_name('OTA','OTA_13068_OFF_TEST_LO_ERR');
             fnd_message.raise_error;
          END IF;

          IF mod(floor(p_player_toolbar_bitset/1),2) <> 1 THEN
             fnd_message.set_name('OTA','OTA_13068_OFF_TEST_LO_ERR');
             fnd_message.raise_error;
          END IF;

    END IF;
         hr_utility.set_location('Leaving:'||l_proc, 40);


Exception
WHEN app_exception.application_exception THEN

       IF hr_multi_message.exception_add(
	    p_associated_column1    => 'OTA_OFFERINGS.PLAYER_TOOLBAR_FLAG',
   	    p_associated_column2    => 'OTA_OFFERINGS.PLAYER_TOOLBAR_BITSET')
				   THEN

	   hr_utility.set_location(' Leaving:'||l_proc, 22);
	   RAISE;

       END IF;
end check_is_test_selected;

-- ----------------------------------------------------------------------------
-- |---------------------------< check_owner_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
--	This function checks to see if any the owner_id exists in
--	per_people_f table
--
--
Procedure check_owner_id (p_offering_id in number,
				p_owner_id in number,
				p_business_group_id in number,
				start_date in date)
Is
	l_proc  varchar2(72) := g_package||'check_owner_id';
CURSOR c_people
IS
SELECT null
FROM Per_all_people_f per
WHERE per.person_id = p_owner_id and
      per.business_group_id = p_business_group_id and
      NVL(start_date,TRUNC(SYSDATE)) between
	effective_start_date and effective_end_date;
CURSOR c_people_cross
IS
SELECT null
FROM Per_all_people_f per
WHERE per.person_id = p_owner_id and
      NVL(start_date,TRUNC(SYSDATE)) between
	effective_start_date and effective_end_date;
l_exist varchar2(1);
--l_cross_business_group varchar2(1):= FND_PROFILE.VALUE('HR_CROSS_BUSINESS_GROUP');
l_single_business_group_id number := FND_PROFILE.VALUE('OTA_HR_GLOBAL_BUSINESS_GROUP_ID');
Begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
 if (((p_offering_id is not null) and
      nvl(ota_off_shd.g_old_rec.owner_id,hr_api.g_number) <>
         nvl(p_owner_id,hr_api.g_number))
   or (p_offering_id is null)) then
  	IF p_owner_id is not null then
       If l_single_business_group_id is not null then
          hr_utility.set_location('Entering:'||l_proc, 10);
          OPEN c_people_cross;
     	    FETCH c_people_cross into l_exist;
     	    if c_people_cross%notfound then
            close c_people_cross;
            fnd_message.set_name('OTA','OTA_13887_EVT_OWNER_INVALID');
            fnd_message.raise_error;
          end if;
          close c_people_cross;
      else
         hr_utility.set_location('Entering:'||l_proc, 20);
    	   OPEN c_people;
     	   FETCH c_people into l_exist;
     	   if c_people%notfound then
            close c_people;
            fnd_message.set_name('OTA','OTA_13887_EVT_OWNER_INVALID');
            fnd_message.raise_error;
         end if;
         close c_people;
       end if;
         hr_utility.set_location('Leaving:'||l_proc, 40);
     END IF;
End if;
Exception
WHEN app_exception.application_exception THEN

       IF hr_multi_message.exception_add(
	    p_associated_column1    => 'OTA_OFFERINGS.OWNER_ID')
				   THEN

	   --hr_utility.set_location(' Leaving:'||v_proc, 22);
	   RAISE;

       END IF;
end check_owner_id;

--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_dm_online_flag >-------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_dm_online_flag
  (p_delivery_mode_id             in            ota_category_usages.category_usage_id%TYPE
  ,p_learning_object_id           in            ota_learning_objects.learning_object_id%TYPE
  ,p_activity_version_id          in            ota_offerings.activity_version_id%TYPE
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get the online flag of the delivery mode id

  CURSOR cur_dm_online_flag is
    select
      ctu.online_flag
    from
      ota_category_usages ctu
    where
      ctu.category_usage_id = p_delivery_mode_id;
  --
  -- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'chk_dm_online_flag';
  v_online_flag          ota_category_usages.online_flag%TYPE;
  l_iln_rco_id           varchar2(50);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

     OPEN cur_dm_online_flag;
     FETCH cur_dm_online_flag into v_online_flag;

    If v_online_flag = 'Y' AND
       p_learning_object_id IS NULL then
    --
       l_iln_rco_id := ota_utility.get_iln_rco_id(p_activity_version_id);
       If l_iln_rco_id IS NULL THEN
       fnd_message.set_name      ( 'OTA','OTA_13072_OFF_LO_NULL');
       fnd_message.raise_error;
       END IF;
    End If;

  --
    CLOSE cur_dm_online_flag;

  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_OFFERINGS.LEARNING_OBJECT_ID'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End chk_dm_online_flag;

---------------------------------------------------------------------
----------------------------------------------------------------------
function checkDecimal( p_num number,p_length number) return boolean is

begin

	return length(to_char( p_num - trunc(p_num) )) > p_length;

end checkDecimal;


procedure check_attendees(
p_maximum_attendees               number
,p_maximum_internal_attendees      number
,p_minimum_attendees               number ) is

begin

	  if(p_minimum_attendees < 0 or p_maximum_attendees < 0 or p_maximum_internal_attendees < 0)
	  then
            fnd_message.set_name('OTA','OTA_13449_EVT_ATTENDEES_POS');
            fnd_message.raise_error;
	  end if;

	  if(  checkDecimal(p_minimum_attendees,1) or  checkDecimal(p_maximum_attendees,1) or  checkDecimal(p_maximum_internal_attendees,1))
	  then
            fnd_message.set_name('OTA','OTA_13449_EVT_ATTENDEES_POS');
            fnd_message.raise_error;
	  end if;

	  if (( p_minimum_attendees is not null and p_maximum_attendees is not null and    p_minimum_attendees > p_maximum_attendees
	  ) or
	  ( p_maximum_internal_attendees is not null and p_maximum_attendees is not null and p_maximum_internal_attendees > p_maximum_attendees))
	  then
            fnd_message.set_name('OTA','OTA_13449_EVT_ATTENDEES_POS');
            fnd_message.raise_error;
	  end if;
Exception
WHEN app_exception.application_exception THEN

       IF hr_multi_message.exception_add(
	    p_associated_column1    => 'OTA_OFFERINGS.MAXIMUM_ATTENDEES'
	    ,p_associated_column2    => 'OTA_OFFERINGS.MAXIMUM_INTERNAL_ATTENDEES'
	    ,p_associated_column3    => 'OTA_OFFERINGS.MINIMUM_ATTENDEES')
				   THEN

	   --hr_utility.set_location(' Leaving:'||v_proc, 22);
	   RAISE;

       END IF;

end check_attendees;

procedure check_duration( p_duration number,p_duration_units varchar2) is

begin
	if( p_duration < 0  )
	then
            fnd_message.set_name('OTA','OTA_443368_POSITIVE_NUMBER');
            fnd_message.raise_error;
	end if;

	if( (p_duration is null and p_duration_units is not null) or (p_duration is not null and p_duration_units is null)  )
	then
            fnd_message.set_name('OTA','OTA_13881_NHS_COMB_INVALID');
            fnd_message.raise_error;
	end if;
Exception
WHEN app_exception.application_exception THEN

       IF hr_multi_message.exception_add(
	    p_associated_column1    => 'OTA_OFFERINGS.DURATION'
	    ,p_associated_column2    => 'OTA_OFFERINGS.DURATION_UNITS')
				   THEN

	   --hr_utility.set_location(' Leaving:'||v_proc, 22);
	   RAISE;

       END IF;
end check_duration;

procedure check_amount(p_actual_cost number,p_budget_cost number,p_standard_price number,
                       p_budget_currency_code varchar2 ,p_price_basis varchar2,p_currency_code varchar2)
is
begin
	    if( p_actual_cost < 0 or p_budget_cost < 0 or p_standard_price < 0 or  checkDecimal(p_actual_cost,3)
	    or  checkDecimal(p_budget_cost,3) or  checkDecimal(p_standard_price,3) )
	    then
		    fnd_message.set_name('OTA','OTA_443354_OFF_AMT_NEGATIVE');
		    fnd_message.raise_error;
	    end if;

        if( ( p_actual_cost is not null  or p_budget_cost is not null ) and p_budget_currency_code is  null ) then
		    fnd_message.set_name('OTA','OTA_13394_TAV_COST_ATTR');
		    fnd_message.raise_error;
        end if;

        if ( p_price_basis is not null and p_price_basis ='S' and (p_standard_price is null or  p_currency_code is null)) then
		    fnd_message.set_name('OTA','OTA_443348_SE_AMOUNT_FIELD_NUL');
		    fnd_message.raise_error;
        end if;

        if ( p_price_basis is not null and p_price_basis ='C' and (p_standard_price is not null or  p_currency_code is null)) then
 	        fnd_message.set_name('OTA','OTA_443348_SE_AMOUNT_FIELD_NUL');
		    fnd_message.raise_error;
        end if;


Exception
WHEN app_exception.application_exception THEN

       IF hr_multi_message.exception_add(
	    p_associated_column1    => 'OTA_OFFERINGS.ACTUAL_COST'
	    ,p_associated_column2    => 'OTA_OFFERINGS.BUDGET_COST'
	    ,p_associated_column3    => 'OTA_OFFERINGS.STANDARD_PRICE')
				   THEN

	   --hr_utility.set_location(' Leaving:'||v_proc, 22);
	   RAISE;

       END IF;
end check_amount;

--
-- ----------------------------------------------------------------------------
-- |---------------------< check_vendor    >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_vendor (p_vendor_id in number,p_date date) is
  --
  v_proc      varchar2(72) := g_package||'check_vendor';
begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_general.check_vendor_is_valid(p_vendor_id,p_date);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_OFFERINGS.VENDOR_ID'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
end check_vendor;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< Chk_Inventory_Course >---------------------------|
-- ----------------------------------------------------------------------------
Procedure Chk_Inventory_Course
  (p_delivery_mode_id      in   ota_offerings.delivery_mode_id%TYPE
  ,p_activity_version_id   in   ota_offerings.activity_version_id%TYPE
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if offering DM is not Offline Synchronous and the
  -- course is linked with inventory.

  CURSOR Cur_Inventory_Course is
    select
      'found'
    From
      ota_category_usages dm
    where
      dm.category_usage_id = p_delivery_mode_id
      and (dm.online_flag <> 'N' or dm.synchronous_flag <> 'Y')
      and exists
        (select '1'
         from ota_activity_versions tav
         where tav.activity_version_id = p_activity_version_id
         and inventory_item_id is not null);

  -- Variables for API Boolean parameters
  l_proc               varchar2(72) := g_package ||'Chk_Inventory_Course';
  l_inv_org_flag      varchar2(10);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  OPEN Cur_Inventory_Course;
  FETCH Cur_Inventory_Course into l_inv_org_flag;
  --
  If Cur_Inventory_Course%FOUND Then
    --
    CLOSE Cur_Inventory_Course;
    --
    fnd_message.set_name      ( 'OTA', 'OTA_443961_OFF_INV_CRS_ERR');
    fnd_message.raise_error;
  Else
    --
    CLOSE Cur_Inventory_Course;
  End If;
  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  When app_exception.application_exception Then
    --
    If hr_multi_message.exception_add
         (p_associated_column1   => 'OTA_OFFERINGS.DELIVERY_MODE_ID'
         ) Then
      --
      hr_utility.set_location(' Leaving:'|| l_proc,20);
      raise;
      --
    End If;
    --
    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End Chk_Inventory_Course;
--


procedure VALIDITY_CHECKS (
	P_REC				     in out nocopy OTA_OFF_SHD.G_REC_TYPE
    ,p_name                  in varchar
	) is
--
  l_owner_id_changed			boolean
  := ota_general.value_changed(ota_off_shd.g_old_rec.owner_id,
					p_rec.owner_id);
  l_start_date_changed  boolean := ota_general.value_changed(ota_off_shd.g_old_rec.start_date,
                            p_rec.start_date);
  l_end_date_changed  boolean := ota_general.value_changed(ota_off_shd.g_old_rec.end_date,
                            p_rec.end_date);

  l_maximum_attendees_changed  boolean    := ota_general.value_changed(ota_off_shd.g_old_rec.maximum_attendees,
                            p_rec.maximum_attendees);
  l_maximum_int_att_changed boolean := ota_general.value_changed(ota_off_shd.g_old_rec.maximum_internal_attendees,
                            p_rec.maximum_internal_attendees);
  l_minimum_attendees_changed   boolean   := ota_general.value_changed(ota_off_shd.g_old_rec.minimum_attendees,
                            p_rec.minimum_attendees);
  l_actual_cost_changed    boolean  := ota_general.value_changed(ota_off_shd.g_old_rec.actual_cost,
                            p_rec.actual_cost);
  l_budget_cost_changed  boolean    := ota_general.value_changed(ota_off_shd.g_old_rec.budget_cost,
                            p_rec.budget_cost);
  l_standard_price_changed  boolean    := ota_general.value_changed(ota_off_shd.g_old_rec.standard_price,
                            p_rec.standard_price);
  l_duration_changed  boolean    := ota_general.value_changed(ota_off_shd.g_old_rec.duration,
                            p_rec.duration);
  l_duration_units_changed boolean  := ota_general.value_changed(ota_off_shd.g_old_rec.duration_units,
                            p_rec.duration_units);

  l_vendor_id_changed   boolean := ota_general.value_changed( ota_off_shd.g_old_rec.vendor_id, p_rec.vendor_id);

  l_budget_currency_code_changed   boolean := ota_general.value_changed( ota_off_shd.g_old_rec.budget_currency_code, p_rec.budget_currency_code);

  l_price_basis_changed   boolean := ota_general.value_changed( ota_off_shd.g_old_rec.price_basis, p_rec.price_basis);

  l_currency_code_changed   boolean := ota_general.value_changed( ota_off_shd.g_old_rec.currency_code, p_rec.currency_code);

begin
        CHECK_UNIQUE (
    	p_name,
	    p_rec.business_group_id,
	    p_rec.ACTIVITY_VERSION_ID,
            p_rec.OFFERING_ID
	    );

	    ota_off_bus.chk_competency_update_level (p_offering_id        => p_rec.offering_id
              ,p_object_version_number   => p_rec.object_version_number
              ,p_competency_update_level        => p_rec.competency_update_level
              ,p_effective_date          => trunc(sysdate));

      if  l_duration_changed or l_duration_units_changed
      then
	     check_duration(p_rec.duration,p_rec.duration_units);
      end if;

      if   l_maximum_attendees_changed or l_maximum_int_att_changed or l_minimum_attendees_changed
      then
	     check_attendees( p_rec.maximum_attendees,p_rec.maximum_internal_attendees,p_rec.minimum_attendees);
      end if;

      if   l_start_date_changed or l_end_date_changed
      then
          OFFERING_DATES_ARE_VALID(p_rec.activity_version_id,p_rec.start_date,p_rec.end_date);
          CLASS_DATES_ARE_VALID   (p_rec.OFFERING_ID, p_rec.start_date,p_rec.end_date );
          --
          Chk_Dm_Start_End_Date
	  (p_delivery_mode_id        =>   p_rec.delivery_mode_id
	  ,p_start_date              =>   p_rec.start_date
	  ,p_end_date                =>   p_rec.end_date
          );
          --
     end if;

      if l_owner_id_changed then
           check_owner_id (p_rec.offering_id,
				   p_rec.owner_id,
				   p_rec.business_group_id,
				   p_rec.start_date);


      end if;


      if l_actual_cost_changed or l_budget_cost_changed or l_standard_price_changed or l_budget_currency_code_changed or l_price_basis_changed or l_currency_code_changed
      then
		check_amount(p_rec.actual_cost,p_rec.budget_cost,p_rec.standard_price,p_rec.budget_currency_code,p_rec.price_basis,p_rec.currency_code);
      end if;

       if l_vendor_id_changed
       then
		check_vendor(p_rec.vendor_id,p_rec.start_date);
       end if;

       --bug 3607018
       chk_dm_online_flag(p_rec.delivery_mode_id,
                          p_rec.learning_object_id,
                          p_rec.activity_version_id);

       --Bug 3486188
       IF p_rec.learning_object_id IS NOT NULL THEN

          check_is_test_selected(p_offering_id           => p_rec.offering_id,
        	                 p_learning_object_id    => p_rec.learning_object_id,
                                 p_player_toolbar_flag   => p_rec.player_toolbar_flag,
                                 p_player_toolbar_bitset => p_rec.player_toolbar_bitset);
        END IF;
        --Bug 3486188

  --Bug#4612340
  --
  Chk_Inventory_Course
  (p_delivery_mode_id     =>    p_rec.delivery_mode_id
  ,p_activity_version_id  =>    p_rec.activity_version_id
  );
  --
  --Bug#4612340

End VALIDITY_CHECKS;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                            in out nocopy   ota_off_shd.g_rec_type
  ,p_name                in varchar
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
    ,p_associated_column1 => ota_off_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
		VALIDITY_CHECKS (		P_REC		     =>	P_REC,p_name => p_name );
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --

  -- 2733966
  If p_rec.language_code IS NULL THEN
       fnd_message.set_name      ( 'OTA','OTA_467063_MAND_LANGUAGE_CODE');
       fnd_message.raise_error;
  END IF;


  ota_off_bus.chk_df(p_rec);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in out nocopy ota_off_shd.g_rec_type
  ,p_name                         in varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_owner_id_changed			boolean
  := ota_general.value_changed(ota_off_shd.g_old_rec.owner_id,
					p_rec.owner_id);

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ota_off_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  VALIDITY_CHECKS (		p_rec		     =>	P_REC,p_name => p_name );



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


  -- 2733966
  If p_rec.language_code IS NULL THEN
       fnd_message.set_name      ( 'OTA','OTA_467063_MAND_LANGUAGE_CODE');
       fnd_message.raise_error;
  END IF;


  ota_off_bus.chk_df(p_rec);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_off_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
    check_if_evt_exists( p_offering_id => p_rec.offering_id );
    check_if_comp_exists( p_offering_id => p_rec.offering_id );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_evt_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_events exist.
--
Procedure check_if_evt_exists
  (
   p_offering_id  in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_evt_exists';
  --
  cursor sel_evt_exists is
    select 'Y'
      from ota_events              evt
     where evt.parent_offering_id = p_offering_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_evt_exists;
  fetch sel_evt_exists into v_exists;
  --
  if sel_evt_exists%found then
    --
    close sel_evt_exists;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt            =>  'OTA_443238_OFF_DEL_EVT_EXISTS'
                      );
    --
  end if;
  --
  close sel_evt_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_evt_exists;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_comp_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_events exist.
--
Procedure check_if_comp_exists
  (
   p_offering_id  in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_comp_exists';
  --
  cursor sel_comp_exists is
    select 'Y'
      from per_competence_elements              comp
     where comp.object_id = p_offering_id
       and comp.type = 'OTA_OFFERING';  --bug 3691224
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_comp_exists;
  fetch sel_comp_exists into v_exists;
  --
  if sel_comp_exists%found then
    --
    close sel_comp_exists;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt            =>  'OTA_443328_OFF_DEL_COMP_EXSITS'
                      );
    --
  end if;
  --
  close sel_comp_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_comp_exists;
--
end ota_off_bus;

/
