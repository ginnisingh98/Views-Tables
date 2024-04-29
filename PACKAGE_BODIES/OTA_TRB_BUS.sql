--------------------------------------------------------
--  DDL for Package Body OTA_TRB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TRB_BUS" as
/* $Header: ottrbrhi.pkb 120.6.12000000.3 2007/07/05 09:22:53 aabalakr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_trb_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_resource_booking_id         number         default null;


--
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_resource_booking_id                  in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --

  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_resource_bookings trb
         , ota_suppliable_resources tsr
     where trb.resource_booking_id = p_resource_booking_id
     and   trb.supplied_resource_id = tsr.supplied_resource_id
     and   pbg.business_group_id = tsr.business_group_id;
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
    ,p_argument           => 'resource_booking_id'
    ,p_argument_value     => p_resource_booking_id
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
        => nvl(p_associated_column1,'RESOURCE_BOOKING_ID')
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
  (p_resource_booking_id                  in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , ota_resource_bookings trb
         , ota_suppliable_Resources tsr
     where trb.resource_booking_id = p_resource_booking_id
       and trb.supplied_resource_id = tsr.supplied_resource_id
       and pbg.business_group_id = tsr.business_group_id;
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
    ,p_argument           => 'resource_booking_id'
    ,p_argument_value     => p_resource_booking_id
    );
  --
  if ( nvl(ota_trb_bus.g_resource_booking_id, hr_api.g_number)
       = p_resource_booking_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_trb_bus.g_legislation_code;
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
    ota_trb_bus.g_resource_booking_id         := p_resource_booking_id;
    ota_trb_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in ota_trb_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.resource_booking_id is not null)  and (
    nvl(ota_trb_shd.g_old_rec.trb_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information_category, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information1, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information1, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information2, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information2, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information3, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information3, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information4, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information4, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information5, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information5, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information6, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information6, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information7, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information7, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information8, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information8, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information9, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information9, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information10, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information10, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information11, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information11, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information12, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information12, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information13, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information13, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information14, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information14, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information15, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information15, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information16, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information16, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information17, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information17, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information18, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information18, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information19, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information19, hr_api.g_varchar2)  or
    nvl(ota_trb_shd.g_old_rec.trb_information20, hr_api.g_varchar2) <>
    nvl(p_rec.trb_information20, hr_api.g_varchar2) ))
    or (p_rec.resource_booking_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_RESOURCE_BOOKINGS'
      ,p_attribute_category              => p_rec.trb_information_category
      ,p_attribute1_name                 => 'TRB_INFORMATION1'
      ,p_attribute1_value                => p_rec.trb_information1
      ,p_attribute2_name                 => 'TRB_INFORMATION2'
      ,p_attribute2_value                => p_rec.trb_information2
      ,p_attribute3_name                 => 'TRB_INFORMATION3'
      ,p_attribute3_value                => p_rec.trb_information3
      ,p_attribute4_name                 => 'TRB_INFORMATION4'
      ,p_attribute4_value                => p_rec.trb_information4
      ,p_attribute5_name                 => 'TRB_INFORMATION5'
      ,p_attribute5_value                => p_rec.trb_information5
      ,p_attribute6_name                 => 'TRB_INFORMATION6'
      ,p_attribute6_value                => p_rec.trb_information6
      ,p_attribute7_name                 => 'TRB_INFORMATION7'
      ,p_attribute7_value                => p_rec.trb_information7
      ,p_attribute8_name                 => 'TRB_INFORMATION8'
      ,p_attribute8_value                => p_rec.trb_information8
      ,p_attribute9_name                 => 'TRB_INFORMATION9'
      ,p_attribute9_value                => p_rec.trb_information9
      ,p_attribute10_name                => 'TRB_INFORMATION10'
      ,p_attribute10_value               => p_rec.trb_information10
      ,p_attribute11_name                => 'TRB_INFORMATION11'
      ,p_attribute11_value               => p_rec.trb_information11
      ,p_attribute12_name                => 'TRB_INFORMATION12'
      ,p_attribute12_value               => p_rec.trb_information12
      ,p_attribute13_name                => 'TRB_INFORMATION13'
      ,p_attribute13_value               => p_rec.trb_information13
      ,p_attribute14_name                => 'TRB_INFORMATION14'
      ,p_attribute14_value               => p_rec.trb_information14
      ,p_attribute15_name                => 'TRB_INFORMATION15'
      ,p_attribute15_value               => p_rec.trb_information15
      ,p_attribute16_name                => 'TRB_INFORMATION16'
      ,p_attribute16_value               => p_rec.trb_information16
      ,p_attribute17_name                => 'TRB_INFORMATION17'
      ,p_attribute17_value               => p_rec.trb_information17
      ,p_attribute18_name                => 'TRB_INFORMATION18'
      ,p_attribute18_value               => p_rec.trb_information18
      ,p_attribute19_name                => 'TRB_INFORMATION19'
      ,p_attribute19_value               => p_rec.trb_information19
      ,p_attribute20_name                => 'TRB_INFORMATION20'
      ,p_attribute20_value               => p_rec.trb_information20
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
  ,p_rec in ota_trb_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_trb_shd.api_updating
      (p_resource_booking_id               => p_rec.resource_booking_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
End chk_non_updateable_args;
-- ----------------------------------------------------------------------------
-- -------------------------< check_timezone >-----------------------------
-- ----------------------------------------------------------------------------
--
-- Procedure to check timezone of a chat
--
--
PROCEDURE check_timezone(p_timezone IN VARCHAR2)
IS
   l_timezone_id NUMBER := ota_timezone_util.get_timezone_id(p_timezone);
BEGIN
   IF l_timezone_id IS NULL THEN
      fnd_message.set_name('OTA','OTA_443982_TIMEZONE_ERROR');
      fnd_message.set_token('OBJECT_TYPE',ota_utility.get_lookup_meaning('OTA_OBJECT_TYPE','RBG',810));
      fnd_message.raise_error;
   END IF;
END check_timezone;
--
-- ----------------------------------------------------------------------------
-- -------------------------< check_res_bkng_time >-----------------------------
-- ----------------------------------------------------------------------------
--
-- Procedure to check start and end time for the book entire period flag as NO
--
--
--
procedure check_res_bkng_time(p_required_start_time IN VARCHAR2
                    ,p_required_end_time IN VARCHAR2
                    ,p_book_entire_period_flag IN VARCHAR2)is

begin
        if (nvl(p_book_entire_period_flag,'N')='N'
                and p_required_start_time > p_required_end_time) then
          fnd_message.set_name('OTA','OTA_467010_RES_BKNG_TIME_ERROR');
          fnd_message.raise_error;
       end if;


end check_res_bkng_time;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
 (p_effective_date               in date ,
  p_rec in ota_trb_shd.g_rec_type ) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
  l_resource_type varchar2(30);

  cursor get_resource_type is
  select resource_type
  from   ota_suppliable_resources
  where  supplied_resource_id = p_rec.supplied_resource_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  IF p_rec.event_id is not null then
    ota_evt_bus.set_security_group_id(p_rec.event_id);
  ELSE
    ota_tsr_bus.set_security_group_id(p_rec.supplied_resource_id);
  END IF;
  --
  -- Check the role_to_play field.
  --
  IF p_rec.role_to_play is not null THEN
    ota_trb_api_procedures.check_role_to_play(p_rec.role_to_play);
  END IF;
  --
  -- Check role_to_play is allowed to be populated.
  --
  ota_trb_api_procedures.check_role_res_type_excl(p_rec.supplied_resource_id,
		           p_rec.role_to_play);
  --
  -- Check quantity_entered is allowed to be populated.
  --
  IF p_rec.quantity is not null THEN
    ota_trb_api_procedures.check_quantity_entered(p_rec.supplied_resource_id,
                           p_rec.quantity);
  END IF;
  --
  -- Check delivery address is allowed to be populated.
  --
  IF p_rec.deliver_to is not null THEN
    ota_trb_api_procedures.check_delivery_address(p_rec.supplied_resource_id,
                           p_rec.deliver_to);
  END IF;
  --
  -- Check required dates validity.
  --
  ota_trb_api_procedures.check_from_to_dates(p_rec.required_date_from,
		      p_rec.required_date_to);
  --
  -- Check validity of required dates within suppliable resource
  -- availability.
  --
  ota_trb_api_procedures.check_dates_tsr(p_rec.supplied_resource_id,
                  p_rec.required_date_from,
	          p_rec.required_date_to,
	          p_rec.required_start_time,
	          p_rec.required_end_time,
		  p_rec.timezone_code);
/*
 ota_trb_api_procedures.check_obj_booking_dates(p_rec.supplied_resource_id,
                  p_rec.required_date_from,
	          p_rec.required_date_to,
              p_rec.event_id,
              p_rec.chat_id,
              p_rec.forum_id,
	      p_rec.timezone_code,
	      p_rec.required_start_time,
		  p_rec.required_end_time);
*/
  --
  -- Check the validity of the business_group_id.
  --
  if p_rec.event_id is not null then
     ota_trb_api_procedures.check_evt_tsr_bus_grp(p_rec.event_id,
			p_rec.supplied_resource_id);
  end if;
  --
  -- Check user status domain.
  --
  IF p_rec.status is not null THEN
    ota_trb_api_procedures.check_status(p_rec.status);
  END IF;
  --
  -- Check that only one resource marked as a primary venue.
  --
  IF p_rec.primary_venue_flag is not null THEN
    ota_trb_api_procedures.check_primary_venue(p_rec.event_id,
                        p_rec.resource_booking_id,
                        p_rec.primary_venue_flag,
                        p_rec.required_date_from,
                        p_rec.required_date_to);
  END IF;
  --
  if p_rec.status = 'C' then

   open get_resource_type;
   fetch get_resource_type into l_resource_type;
   close get_resource_type;

-- no double booking check for forum and chat Trainer(Moderator).
   if( (l_resource_type = 'T') and (p_rec.chat_id is not null or p_rec.forum_id is not null)) then
      null;
   else
     ota_trb_api_procedures.check_trainer_venue_book
             (p_rec.supplied_resource_id
             ,p_rec.required_date_from
             ,p_rec.required_start_time
             ,p_rec.required_date_to
             ,p_rec.required_end_time
             ,p_rec.resource_booking_id
	     ,p_rec.book_entire_period_flag
	     ,p_rec.timezone_code);
    end if;
  end if;
  --
  -- Check the event type
  --
  if p_rec.event_id is not null then
     ota_trb_api_procedures.check_event_type(p_rec.event_id);
  end if;
  --

  --
  -- Check start time is after end time.
  --
  -- Added date check condition for bug# 3183071
  If (trunc(p_rec.required_date_from) = trunc(p_rec.required_date_to)) then
    ota_trb_api_procedures.check_start_end_times(p_rec.required_start_time
                                              ,p_rec.required_end_time);
  End if;

  check_timezone(p_rec.timezone_code);

  --Added for bug#5572125

   check_res_bkng_time(p_rec.required_start_time
                    ,p_rec.required_end_time
                    ,p_rec.book_entire_period_flag);

  --
ota_trb_bus.chk_ddf(p_rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For update, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_trb_shd.g_rec_type
  ) is
--
  l_supplied_resource_id_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.supplied_resource_id,
                           p_rec.supplied_resource_id);
--
  l_event_id_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.event_id,
                           p_rec.event_id);
--
  l_role_to_play_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.role_to_play,
                           p_rec.role_to_play);
--
  l_quantity_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.quantity,
                           p_rec.quantity);
--
  l_deliver_to_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.deliver_to,
                           p_rec.deliver_to);
--
  l_number_del_per_unit_changed boolean :=
   ota_general.value_changed(ota_trb_shd.g_old_rec.delegates_per_unit,
                            p_rec.delegates_per_unit);
--
  l_required_date_from_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.required_date_from,
			   p_rec.required_date_from);
--
  l_required_start_time_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.required_start_time,
			   p_rec.required_start_time);
--
  l_required_date_to_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.required_date_to,
                           p_rec.required_date_to);
--
  l_required_end_time_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.required_end_time,
                           p_rec.required_end_time);
--
  l_status_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.status,
                           p_rec.status);
--
  l_primary_venue_flag_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.primary_venue_flag,
                           p_rec.primary_venue_flag);

l_book_entire_period_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.book_entire_period_flag,
                           p_rec.book_entire_period_flag);
l_timezone_changed boolean :=
  ota_general.value_changed(ota_trb_shd.g_old_rec.timezone_code,
                           p_rec.timezone_code);
--
  --
  l_proc	varchar2(72) := g_package||'update_validate';
  l_resource_type varchar2(30);

  cursor get_resource_type is
  select resource_type
  from   ota_suppliable_resources
  where  supplied_resource_id = p_rec.supplied_resource_id;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  IF ota_trb_shd.g_old_rec.event_id is not null then
    ota_evt_bus.set_security_group_id(ota_trb_shd.g_old_rec.event_id);
  ELSIF (ota_trb_shd.g_old_rec.supplied_resource_id = p_rec.supplied_resource_id) THEN
    ota_tsr_bus.set_security_group_id(ota_trb_shd.g_old_rec.supplied_resource_id);
  ELSE
    ota_tsr_bus.set_security_group_id(p_rec.supplied_resource_id);
  END IF;
  --
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  IF l_event_id_changed THEN
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',l_proc);
    hr_utility.set_message_token('STEP','2');
    hr_utility.raise_error;
  END IF;
  --
  -- Check the role_to_play field.
  --
  IF l_role_to_play_changed and p_rec.role_to_play is not null THEN
    ota_trb_api_procedures.check_role_to_play(p_rec.role_to_play);
  END IF;
  --
  -- Check quantity_entered is allowed to be populated.
  --
  IF l_quantity_changed THEN
    ota_trb_api_procedures.check_quantity_entered(p_rec.supplied_resource_id,
                           p_rec.quantity);
  END IF;
  --
  -- Check delivery address is allowed to be populated.
  --
  IF l_deliver_to_changed THEN
    ota_trb_api_procedures.check_delivery_address(p_rec.supplied_resource_id,
                           p_rec.deliver_to);
  END IF;
  --
  -- check required dates validity and default if necessary.
  --
  /*Adding the start_time change or end_time change or timezone change to this if,for bug6078493*/

  IF (l_required_date_from_changed OR l_required_date_to_changed
       OR  l_required_start_time_changed OR l_required_end_time_changed OR l_timezone_changed) THEN
          ota_trb_api_procedures.check_from_to_dates(p_rec.required_date_from,
			p_rec.required_date_to);
    ota_trb_api_procedures.check_dates_tsr(p_rec.supplied_resource_id,
                    p_rec.required_date_from,
                    p_rec.required_date_to,
                    p_rec.required_start_time,
	            p_rec.required_end_time,
		    p_rec.timezone_code);
/*
	ota_trb_api_procedures.check_obj_booking_dates(p_rec.supplied_resource_id,
                  p_rec.required_date_from,
	          p_rec.required_date_to,
              p_rec.event_id,
              p_rec.chat_id,
              p_rec.forum_id,
	      p_rec.timezone_code,
	      p_rec.required_start_time,
		  p_rec.required_end_time);
*/

  END IF;
  --
  -- Check status validity.
  --
  IF l_status_changed THEN
    ota_trb_api_procedures.check_status(p_rec.status);
  END IF;
  --
  -- Check primary venue marked only once.
  --
  IF (l_primary_venue_flag_changed or
      l_required_date_from_changed or
      l_required_date_to_changed)
     AND p_rec.primary_venue_flag = 'Y' THEN
  --
    ota_trb_api_procedures.check_primary_venue(p_rec.event_id,
                        p_rec.resource_booking_id,
                        p_rec.primary_venue_flag,
                        p_rec.required_date_from,
			p_rec.required_date_to);
  --
  END IF;
  --
  if (l_supplied_resource_id_changed or
      l_required_date_from_changed   or
      l_required_date_to_changed     or
      l_required_start_time_changed  or
      l_required_end_time_changed    or
      l_book_entire_period_changed OR
      l_timezone_changed OR
      l_status_changed)
   and p_rec.status = 'C' then
      --
   open get_resource_type;
   fetch get_resource_type into l_resource_type;
   close get_resource_type;

-- no double booking check for forum and chat Trainer(Moderator).
   if( (l_resource_type = 'T') and (p_rec.chat_id is not null or p_rec.forum_id is not null)) then
      null;
   else
      ota_trb_api_procedures.check_trainer_venue_book
             (p_rec.supplied_resource_id
             ,p_rec.required_date_from
             ,p_rec.required_start_time
             ,p_rec.required_date_to
             ,p_rec.required_end_time
             ,p_rec.resource_booking_id
	     ,p_rec.book_entire_period_flag
	     ,p_rec.timezone_code);
    end if;
  end if;
  --

  --
  -- Check start time is after end time.
  --
  -- added date check condition for bug# 3183071
  if (l_required_start_time_changed  or l_required_end_time_changed)
     and  (trunc(p_rec.required_date_from) = trunc(p_rec.required_date_to)) then
  --
    ota_trb_api_procedures.check_start_end_times(p_rec.required_start_time
                                                ,p_rec.required_end_time);

  --
  end if;

  --Added for bug#5572125
   check_res_bkng_time(p_rec.required_start_time
                    ,p_rec.required_end_time
                    ,p_rec.book_entire_period_flag);

  IF p_rec.timezone_code <> hr_api.g_varchar2 THEN
     check_timezone(p_rec.timezone_code);
  END IF;

  --
ota_trb_bus.chk_ddf(p_rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10); End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from del procedure.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec in ota_trb_shd.g_rec_type
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
end ota_trb_bus;

/
