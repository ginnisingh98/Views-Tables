--------------------------------------------------------
--  DDL for Package Body OTA_EVT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EVT_BUS" as
/* $Header: otevt01t.pkb 120.13.12010000.5 2009/07/29 07:12:13 shwnayak ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_evt_bus.';  -- Global package name
--
--	A field to select 1 into ...
--
G_DUMMY					number (1);

--
--	Working record
--
G_FETCHED_REC				ota_evt_shd.g_rec_type;

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
  (p_rec in ota_evt_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.event_id is not null)  and (
    nvl(ota_evt_shd.g_old_rec.evt_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information_category, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information1, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information1, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information2, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information2, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information3, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information3, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information4, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information4, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information5, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information5, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information6, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information6, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information7, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information7, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information8, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information8, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information9, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information9, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information10, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information10, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information11, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information11, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information12, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information12, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information13, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information13, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information14, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information14, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information15, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information15, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information16, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information16, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information17, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information17, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information18, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information18, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information19, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information19, hr_api.g_varchar2)  or
    nvl(ota_evt_shd.g_old_rec.evt_information20, hr_api.g_varchar2) <>
    nvl(p_rec.evt_information20, hr_api.g_varchar2) ))
    or (p_rec.event_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_EVENTS'
      ,p_attribute_category              => p_rec.evt_information_category
      ,p_attribute1_name                 => 'EVT_INFORMATION1'
      ,p_attribute1_value                => p_rec.evt_information1
      ,p_attribute2_name                 => 'EVT_INFORMATION2'
      ,p_attribute2_value                => p_rec.evt_information2
      ,p_attribute3_name                 => 'EVT_INFORMATION3'
      ,p_attribute3_value                => p_rec.evt_information3
      ,p_attribute4_name                 => 'EVT_INFORMATION4'
      ,p_attribute4_value                => p_rec.evt_information4
      ,p_attribute5_name                 => 'EVT_INFORMATION5'
      ,p_attribute5_value                => p_rec.evt_information5
      ,p_attribute6_name                 => 'EVT_INFORMATION6'
      ,p_attribute6_value                => p_rec.evt_information6
      ,p_attribute7_name                 => 'EVT_INFORMATION7'
      ,p_attribute7_value                => p_rec.evt_information7
      ,p_attribute8_name                 => 'EVT_INFORMATION8'
      ,p_attribute8_value                => p_rec.evt_information8
      ,p_attribute9_name                 => 'EVT_INFORMATION9'
      ,p_attribute9_value                => p_rec.evt_information9
      ,p_attribute10_name                => 'EVT_INFORMATION10'
      ,p_attribute10_value               => p_rec.evt_information10
      ,p_attribute11_name                => 'EVT_INFORMATION11'
      ,p_attribute11_value               => p_rec.evt_information11
      ,p_attribute12_name                => 'EVT_INFORMATION12'
      ,p_attribute12_value               => p_rec.evt_information12
      ,p_attribute13_name                => 'EVT_INFORMATION13'
      ,p_attribute13_value               => p_rec.evt_information13
      ,p_attribute14_name                => 'EVT_INFORMATION14'
      ,p_attribute14_value               => p_rec.evt_information14
      ,p_attribute15_name                => 'EVT_INFORMATION15'
      ,p_attribute15_value               => p_rec.evt_information15
      ,p_attribute16_name                => 'EVT_INFORMATION16'
      ,p_attribute16_value               => p_rec.evt_information16
      ,p_attribute17_name                => 'EVT_INFORMATION17'
      ,p_attribute17_value               => p_rec.evt_information17
      ,p_attribute18_name                => 'EVT_INFORMATION18'
      ,p_attribute18_value               => p_rec.evt_information18
      ,p_attribute19_name                => 'EVT_INFORMATION19'
      ,p_attribute19_value               => p_rec.evt_information19
      ,p_attribute20_name                => 'EVT_INFORMATION20'
      ,p_attribute20_value               => p_rec.evt_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;

--
--
--added for eBS by asud
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
PROCEDURE set_security_group_id  (p_event_id              IN number,
                                  p_associated_column1    IN varchar2
  ) IS
  --
  -- Declare cursor
  --
  CURSOR csr_sec_grp IS
    SELECT inf.org_information14
    FROM   hr_organization_information inf
          ,ota_events evt
    WHERE  evt.event_id       = p_event_id
    AND    inf.organization_id               = evt.business_group_id
    AND    inf.org_information_context || '' = 'Business Group Information';



  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'event_id'
    ,p_argument_value     => p_event_id
    );
  --
  OPEN csr_sec_grp;
  FETCH csr_sec_grp INTO l_security_group_id;
  --
  IF csr_sec_grp%NOTFOUND THEN
     --
     CLOSE csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
   hr_multi_message.add
        (p_associated_column1   => NVL(p_associated_column1, 'EVENT_ID'));
     --
  ELSE

        CLOSE csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
    hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );

  END IF;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
END set_security_group_id;
--added for eBS by asud

-- Added For Bug 4348949
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_event_id
--     already exists.
--
--  In Arguments:
--    p_event_id
--
--
--  Post Success:
--    The business group's legislation code will be returned.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION return_legislation_code
  (p_event_id                          in     number
  ) RETURN varchar2
IS
--
-- Declare cursor
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups_perf pbg,
                 ota_events evt
          where  pbg.business_group_id    = evt.business_group_id
            and  evt.event_id = p_event_id;


   l_proc              varchar2(72) := g_package||'return_legislation_code';
   l_legislation_code  varchar2(150);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'event_id',
                              p_argument_value => p_event_id);
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
     close csr_leg_code;
     --
     -- The primary key is invalid therefore we must error out
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
  return l_legislation_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End return_legislation_code;
--
--
-- ----------------------------------------------------------------------------
-- -------------------------< INVALID_PARAMETER >------------------------------
-- ----------------------------------------------------------------------------
--
--	Handles 'Invalid parameter' events.
--
procedure INVALID_PARAMETER (
	P_PROCEDURE_NAME			     in	varchar2,
	P_OPTIONAL_MESSAGE			     in	varchar2
	) is
begin
	--
	FND_MESSAGE.SET_NAME (810, 'OTA_13205_GEN_PARAMETERS');
	FND_MESSAGE.SET_TOKEN ('PROCEDURE',        P_PROCEDURE_NAME);
	FND_MESSAGE.SET_TOKEN ('SPECIFIC_MESSAGE', P_OPTIONAL_MESSAGE);
	FND_MESSAGE.RAISE_ERROR;
	--
end INVALID_PARAMETER;
--
-- ----------------------------------------------------------------------------
-- -------------------------< CHANGE_TO_WAIT_STATUS >--------------------------
-- ----------------------------------------------------------------------------
--
--	Handles change of event to wait status if student associations
--      are anything less than wait status.
--
function CHANGE_TO_WAIT_STATUS (p_business_group_id     in number,
                                p_event_id 		in number)
                                return boolean is
  l_booking_status_type ota_booking_status_types.type%type;
  l_success boolean := true;
  cursor c1 is
    select BST.TYPE
    FROM  OTA_BOOKING_STATUS_TYPES BST ,
          PER_ALL_PEOPLE_F DEL ,
          OTA_EVENTS EVT ,
          OTA_DELEGATE_BOOKINGS TDB
   where  tdb.business_group_id = p_business_group_id
  and evt.event_id = p_event_id
  AND TDB.BOOKING_STATUS_TYPE_ID = BST.BOOKING_STATUS_TYPE_ID
  AND TDB.EVENT_ID = EVT.EVENT_ID
  AND TDB.DELEGATE_PERSON_ID = DEL.PERSON_ID (+)
  AND tdb.date_booking_placed between nvl(del.effective_start_date, tdb.date_booking_placed) and nvl(del.effective_end_date, tdb.date_booking_placed);
begin
  open c1;
    loop
      fetch c1 into l_booking_status_type;
      exit when c1%notfound;
      if l_booking_status_type <>  'W' then
	l_success := false;
      end if;
    end loop;
  close c1;
  if l_success then
    return true;
  else
    return false;
  end if;
end;
-- ----------------------------------------------------------------------------
-- |--------------------------------------------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Returns the program title if the event is partof a program
--
function get_prog_title (p_event_id in number) return varchar2 is
  --
  l_event_title ota_events.title%type := '';
  --
  cursor c1 is
    select a.title
    from   ota_events_tl a,
	   ota_program_memberships b
    where  a.event_id = b.program_event_id
    and    b.event_id = p_event_id
    and    a.language = USERENV('LANG');
  --
begin
  --
  open c1;
    --
    fetch c1 into l_event_title;
    --
  close c1;
  --
  return l_event_title;
  --
end get_prog_title;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_price_basis >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
-- Checks whether the amount field has been filled in when we are dealing
-- with a student priced event.
--
procedure check_price_basis(p_event_id                in ota_events.event_id%TYPE,
                            p_price_basis             in ota_events.price_basis%TYPE,
                            p_parent_offering_id      in ota_events.parent_offering_id%TYPE,
			                p_max_internal_attendees  in ota_events.maximum_internal_attendees%TYPE) is
  --
  l_proc                  varchar2(30) := 'check_price_basis';
  l_dummy                 VARCHAR2(30);

  CURSOR dm_cr is
  SELECT null
    FROM ota_offerings o,
	     ota_category_usages c
   WHERE o.offering_id = p_parent_offering_id
     AND o.delivery_mode_id = c.category_usage_id
     AND c.synchronous_flag = 'Y'
     AND c.online_flag = 'N';

  CURSOR evt_associations_cr(l_cust_associations VARCHAR2, l_non_cust_associations VARCHAR2) is
  SELECT null
    FROM ota_event_associations
   WHERE event_id = p_event_id
     AND (l_cust_associations = 'N' or customer_id is not null)
     AND (l_non_cust_associations = 'N' or customer_id is null);

  --

begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
        if ( p_price_basis is not null and p_price_basis ='N') then

           OPEN evt_associations_cr('Y','N');
          FETCH evt_associations_cr INTO l_dummy;
             IF evt_associations_cr%found then
          CLOSE evt_associations_cr;
                fnd_message.set_name('OTA','OTA_443486_NO_CHARGE_CUST_EVT');
                fnd_message.raise_error;
            END IF;
          CLOSE evt_associations_cr;

        end if;

        IF ( p_price_basis is not null AND
            (p_price_basis = 'C' or
             p_price_basis = 'O')
            )
      THEN
           OPEN dm_cr;
          FETCH dm_cr INTO l_dummy;
             IF dm_cr%notfound then
          CLOSE dm_cr;
                fnd_message.set_name('OTA','OTA_443489_PRICE_BASIS_DM');
                fnd_message.raise_error;
            END IF;
          CLOSE dm_cr;

             IF (p_max_internal_attendees IS NULL OR
                p_max_internal_attendees > 0 )
           THEN
                fnd_message.set_name('OTA','OTA_443487_PRICE_BASIS_C_O');
                fnd_message.raise_error;
            END IF;

           OPEN evt_associations_cr('N','Y');
          FETCH evt_associations_cr INTO l_dummy;
             IF evt_associations_cr%found then
          CLOSE evt_associations_cr;
                fnd_message.set_name('OTA','OTA_443488_PRICE_BASIS_INT');
                fnd_message.raise_error;
            END IF;
          CLOSE evt_associations_cr;

       END IF;

  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
     EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.PRICE_BASIS',
                                     p_associated_column2 => 'OTA_EVENTS.STANDARD_PRICE') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);

end check_price_basis;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_pricing >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
-- Checks whether the amount field has been filled in when we are dealing
-- with a student priced event.
--
procedure check_pricing(p_pricing_type in varchar2,
			p_amount       in number,p_currency_code in varchar2) is
  --
  l_proc       varchar2(30) := 'check_pricing';
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
        if ( p_pricing_type is not null and p_pricing_type ='S' and (p_amount is null or  p_currency_code is null)) then
		    fnd_message.set_name('OTA','OTA_13440_EVT_CURR_PB');
		    fnd_message.raise_error;
        end if;

        if ( p_pricing_type is not null and p_pricing_type ='C' and (p_amount is not null or  p_currency_code is null)) then
 	        fnd_message.set_name('OTA','OTA_13440_EVT_CURR_PB');
		    fnd_message.raise_error;
        end if;

  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
     EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.PRICE_BASIS',
                                     p_associated_column2 => 'OTA_EVENTS.STANDARD_PRICE') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);

end check_pricing;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< status_change_normal >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Checks whether any program members are wait-listed in which case the
--   program can not have a normal event status
--
Function status_change_normal (p_event_id in number) return boolean is
  --
  l_proc       varchar2(30) := 'status_change_normal';
  l_found boolean := false;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   ota_program_memberships mem,
	   ota_events evt
    where  mem.program_event_id = p_event_id
    and    mem.event_id = evt.event_id
    and    evt.event_status = 'P';
  --
begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  open c1;
    --
    fetch c1 into l_dummy;
    if c1%found then
      --
      -- Planned entries exist as program members
      --
      l_found := true;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
  return l_found;
  --
end status_change_normal;
-- ----------------------------------------------------------------------------
-- |--------------------< enrollment_dates_event_valid >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validate the enrollment startdate, enddate against the event
--   startdate, enddate. The enrollment start date must be before
--   the event startdate but must not be after the event startdate.
--   The enrollment enddate must be within the event enddate.
--
Procedure enrollment_dates_event_valid (p_enrollment_start_date in out nocopy date,
			                p_enrollment_end_date   in out nocopy date,
                                        p_course_start_date    in out nocopy date,
			                p_course_end_date      in out nocopy date) is
--
  l_proc       varchar2(30) := 'enrollment_dates_event_valid';
  l_course_start_date date;
  l_course_end_date   date;
begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  l_course_start_date := p_course_start_date;
  l_course_end_date := p_course_end_date;
  if l_course_start_date is null then
     l_course_start_date := p_enrollment_start_date;
  end if;
  if l_course_end_date is null then
     l_course_end_date := p_enrollment_end_date;
  end if;
  --
  -- Existing date for the parent startdate => Enrollment startdate
  --
  If l_course_start_date is not null  Then
     --
     -- Course startdate is earlier than enrollment startdate
     --
     If nvl(l_course_start_date, hr_api.g_sot) < p_enrollment_start_date  Then
        --
        --
        -- ** TEMP ** Add error message with the following text.
        fnd_message.set_name('OTA', 'OTA_13481_ENROL_START_AFTER');
        fnd_message.raise_error;
        --
     End if;
  End if;
  --
  -- Existing date for the parent enddate <= enrollment enddate
  --
  If l_course_end_date is not null  Then
     --
     -- Enrollment startdate is earlier than course enddate
     --
     If nvl(p_enrollment_start_date, hr_api.g_sot) > l_course_end_date Then
        --
        -- ** TEMP ** Add error message with the following text.
        fnd_message.set_name('OTA','OTA_13474_ENROLL_START_AFTER');
        fnd_message.raise_error;
        --
     End if;
     --
     -- Enrollment enddate is later than course enddate
     --
     /*If nvl(p_enrollment_end_date, l_course_end_date) > l_course_end_date Then
        --
        -- ** TEMP ** Add error message with the following text.
        fnd_message.set_name('OTA','OTA_13475_ENROLL_END_AFTER');
        fnd_message.raise_error;
        --
     End if;*/
     --
  End if;
  --
  hr_utility.set_location(' Exitting:'||l_proc,10);
--
End enrollment_dates_event_valid;
--
-- ----------------------------------------------------------------------------
-- |--------------------< enrollment_after_event_end >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validate the enrollment end_date against the course enddate
--   and check if the enrollment end date is after the course enddate.
--
Function enrollment_after_event_end (
			             p_enrollment_end_date   in out nocopy date,
			             p_course_end_date      in out nocopy date)
				     return boolean is
--
  l_proc       varchar2(30) := 'enrollment_after_event_end';
  l_course_end_date   date;
begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  l_course_end_date := p_course_end_date;
  if l_course_end_date is null then
     l_course_end_date := p_enrollment_end_date;
  end if;
  hr_utility.set_location('Course End Date '||to_char(l_course_end_date),10);
  hr_utility.set_location('Enrolment End Date '||to_char(p_enrollment_end_date),10);
  --
  -- Existing date for the parent enddate <= enrollment enddate
  --
  If l_course_end_date is not null  Then
     --
     -- Enrollment enddate is later than course enddate
     --
     If nvl(p_enrollment_end_date, l_course_end_date) > l_course_end_date Then
        hr_utility.set_location('Enrollment > Course ',10);
	return true;
     End if;
  End If;
  hr_utility.set_location(' Exitting:'||l_proc,10);
  return false;
--
End enrollment_after_event_end;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_event_status >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUPLIC
-- Description:
--   Check that the event status is not planned and the end_date is not null.
--
Procedure check_event_status (p_event_status    in varchar2,
                              p_course_end_date in date,
                              p_event_type in varchar2) is
--
  l_proc       varchar2(30) := 'check_event_status';
begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  if (p_event_status <> 'P' AND p_event_status <> 'A') OR p_event_type <> 'SELFPACED' then
     if p_course_end_date is null then
        fnd_message.set_name('OTA','OTA_13480_END_DATE_NULL');
        fnd_message.raise_error;
     end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,10);
       EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.EVENT_STATUS') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);

end check_event_status;
--
-- ----------------------------------------------------------------------------
-- -------------------------< RESOURCES_AFFECTED >-----------------------------
-- ----------------------------------------------------------------------------
--
--      Returns TRUE if the event itime has changed so that resources are
--      outside the times of the event.
--
function RESOURCES_AFFECTED (
	P_EVENT_ID          in number,
	P_START_TIME        in varchar2,
	P_END_TIME          in varchar2,
	P_COURSE_START_DATE in date,
	P_COURSE_END_DATE   in date
	) return boolean is
  --
  l_proc       varchar2(30) := 'resources_affected';
  l_dummy      varchar2(30);
  l_found      boolean := false;
  --
  cursor c1 is
    select null
    from   ota_resource_bookings
    where  event_id = p_event_id
    and    (required_date_from = p_course_start_date
	    and required_start_time <
	    p_start_time
	    or
	    required_date_to = p_course_end_date
	    and required_end_time >
	    p_end_time);
  --
begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  open c1;
    --
    fetch c1 into l_dummy;
    if c1%found then
      --
      l_found := true;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
  --
  return l_found;
  --
end resources_affected;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_public_event_flag >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUPLIC
-- Description:
--   Ensure that
--   a. if the Public_event_flag is changed to 'N' then ensure there are
--      no enrollments already existing
--
--   b. if the Public_event_flag is changed to 'Y' then ensure there are
--      no event associations already existing
--
procedure check_public_event_flag(p_public_event_flag in varchar2
                                 ,p_event_id          in number) is
--
l_proc       varchar2(30) := 'check_public_event_flag';
l_exists varchar2(1);
--
cursor get_enrollments is
select null
from   ota_delegate_bookings
where  event_id = p_event_id;
--
cursor get_tea is
select null
from   ota_event_associations
where  event_id = p_event_id;
begin
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  if p_public_event_flag = 'N' then
     open get_enrollments;
     fetch get_enrollments into l_exists;
     if get_enrollments%found then
        close get_enrollments;
        fnd_message.set_name('OTA','OTA_13526_RESTRICTED_FLAG');
        fnd_message.set_token('STEP','1');
        fnd_message.raise_error;
     end if;
     close get_enrollments;
  --
  elsif p_public_event_flag = 'Y' then
     open get_tea;
     fetch get_tea into l_exists;
     if get_tea%found then
        close get_tea;
        fnd_message.set_name('OTA','OTA_13526_RESTRICTED_FLAG');
        fnd_message.set_token('STEP','2');
        fnd_message.raise_error;
     end if;
     close get_tea;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
     EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.PUBLIC_EVENT_FLAG') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);

end check_public_event_flag;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< enrollment_dates_are_valid >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validate the parent startdate, enddate and the child enrollment
--   startdate, enddate. The child start must be within the parent
--   startdate but must be before or equal to the parent startdate.
--   The child end date must be before or equal to the parent enddate.
--
Procedure enrollment_dates_are_valid( p_parent_offering_id   in number,
			   	      p_enrollment_start_date in date,
				      p_enrollment_end_date   in date) Is
--
  l_proc       varchar2(30) := 'enrollment_dates_are_valid';
  l_start_date date;
  l_end_date   date;
  cursor check_dates is
    select start_date, end_date
    from ota_offerings
    where offering_id = p_parent_offering_id;
begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  open check_dates;
    loop
      fetch check_dates into l_start_date, l_end_date;
      exit when check_dates%notfound;
      if l_start_date is null then
        l_start_date := p_enrollment_start_date;
      end if;
      if l_end_date is null then
        l_end_date := p_enrollment_end_date;
      end if;
      check_enrollment_dates(l_start_date,
                             l_end_date,
			     p_enrollment_start_date,
                             p_enrollment_end_date);
    end loop;
  close check_dates;

  hr_utility.set_location(' Exitting:'||l_proc,10);
--
     EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.ENROLMENT_START_DATE',
                                     p_associated_column2 => 'OTA_EVENTS.ENROLMENT_END_DATE') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);

End enrollment_dates_are_valid;

/*--changes made for eBS by asud
Procedure enrollment_dates_are_valid( p_activity_version_id   in number,
			   	      p_enrollment_start_date in date,
				      p_enrollment_end_date   in date) Is
--
  l_proc       varchar2(30) := 'enrollment_dates_are_valid';
  l_start_date date;
  l_end_date   date;
  cursor check_dates is
    select start_date, end_date
    from ota_activity_versions_v
    where activity_version_id = p_activity_version_id;
begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  open check_dates;
    loop
      fetch check_dates into l_start_date, l_end_date;
      exit when check_dates%notfound;
      if l_start_date is null then
        l_start_date := p_enrollment_start_date;
      end if;
      if l_end_date is null then
        l_end_date := p_enrollment_end_date;
      end if;
      check_enrollment_dates(l_start_date,
                             l_end_date,
			     p_enrollment_start_date,
                             p_enrollment_end_date);
    end loop;
  close check_dates;

  hr_utility.set_location(' Exitting:'||l_proc,10);
--
End enrollment_dates_are_valid;
*/--changes made for eBS by asud
-------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |-----------------------< check_enrollment_dates >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validate the parent startdate, enddate and the enrollment startdate, enddate.
--   The child start and enddate have to be within the parent start and enddate.
--
Procedure check_enrollment_dates
  (
   p_par_start    in  date
  ,p_par_end      in  date
  ,p_child_start  in  date
  ,p_child_end    in  date
  ) Is
--
  v_proc 	varchar2(72) := g_package||'check_enrollment_dates';
--
Begin
   hr_utility.set_location('Entering:'||v_proc, 5);
   --
   -- Existing date for the parent startdate => Boundary parent startdate
   --
   --
   -- Child startdate is earlier than parent startdate
   -- This isn't a problem
   --
   -- Child enddate is earlier than parent startdate
   -- This isn't a problem as this can happen.
   --
   --
   -- Existing date for the parent enddate => Boundary parent enddate
   --
   If p_par_end is not null  Then
      --
      -- Child startdate is later than parent enddate
      --
      If nvl( p_child_start, hr_api.g_sot) > p_par_end Then
         --
         -- ** TEMP ** Add error message with the following text.
         fnd_message.set_name('OTA','OTA_13474_ENROLL_START_AFTER');
         fnd_message.raise_error;
         --
      End if;
      --
      -- Child enddate is later than parent enddate
      -- This isn't a problem
      --
   End if;
   --
   hr_utility.set_location(' Leaving:'||v_proc, 10);


End check_enrollment_dates;

-------------------------------------------------------------------
--
--
-- ----------------------------------------------------------------------------
-- -------------------------< chk_start_date >-----------------------
-- ----------------------------------------------------------------------------
--
--	Checks if start date is null when start time is not null
--
--
procedure chk_start_date(  p_course_start_date          IN ota_events.course_start_date%TYPE,
                           p_course_start_time          IN ota_events.course_start_time%TYPE)
is
  l_proc       varchar2(30) := 'chk_start_date';
begin
 hr_utility.set_location('Entering:'||l_proc,10);

    if p_course_start_time is not null and p_course_start_date is null
    then
         fnd_message.set_name('OTA','OTA_13065_CLASS_START_DATE');
         fnd_message.raise_error;
    end if;
 hr_utility.set_location('Leaving:'||l_proc,20);

  EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.COURSE_START_TIME') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);

end chk_start_date;
-------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- -------------------------< CHK_END_DATE >-------------------------
-- ----------------------------------------------------------------------------
--
--	Checks if end date is not null when end time is not null
--
--
procedure CHK_END_DATE(  p_course_end_date          IN ota_events.course_end_date%TYPE,
                         p_course_end_time          IN ota_events.course_end_time%TYPE)
is
  l_proc       varchar2(30) := 'chk_end_date';
begin
 hr_utility.set_location('Entering:'||l_proc,10);
    if p_course_end_time is not null and p_course_end_date is null
    then
         fnd_message.set_name('OTA','OTA_443613_CLASS_END_DATE');
         fnd_message.raise_error;
    end if;
 hr_utility.set_location('Leaving:'||l_proc,20);

  EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.COURSE_END_TIME') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);

end CHK_END_DATE;
-------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- -------------------------< COURSE_DATES_ARE_VALID >-------------------------
-- ----------------------------------------------------------------------------
--
--	Checks if scheduled events are within the parent activity start date
--      and end date.
--      N.B. Planned Events may have NULL Dates
--
--

procedure COURSE_DATES_ARE_VALID (p_parent_offering_id in number,
                                  p_course_start_date          in date,
                                  p_course_end_date            in date,
                                  p_event_status        in varchar2,
                                  p_event_type          in varchar2) is
--
  l_proc       varchar2(30) := 'course_dates_are_valid';
  l_start_date date;
  l_end_date   date;
  l_evt_start_date date;
  l_evt_end_date date;
--
  l_act_start_date ota_activity_versions.start_date%TYPE;
  l_act_end_date   ota_activity_versions.end_date%TYPE;
  l_act_vrsn_id    ota_activity_versions.activity_version_id%TYPE;

  cursor check_dates is
    select start_date, end_date, activity_version_id
    from ota_offerings
    where offering_id = p_parent_offering_id;

 cursor check_act_dates is
    select start_date, end_date
    from ota_activity_versions
    where activity_version_id = l_act_vrsn_id;

begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  hr_utility.trace('p_parent_offering_id'||p_parent_offering_id);
  hr_utility.trace('p_course_start_date'||p_course_start_date);
  hr_utility.trace('p_course_end_date'||p_course_end_date);
  hr_utility.trace('p_event_status'||p_event_status);
/*
  if p_event_status <> 'P' then
     if p_course_start_date is null or
        p_course_end_date is null then
        fnd_message.set_name('OTA','OTA_13533_EVT_DATES_NULL');
        fnd_message.raise_error;
     end if;
  end if;
*/
  --
    if (p_event_status <> 'P' AND p_event_status <> 'A') then
     if p_event_type <> 'SELFPACED' then
        if p_course_end_date is null then
           fnd_message.set_name('OTA','OTA_13480_END_DATE_NULL');
           fnd_message.raise_error;
        end if;
     end if;
     if p_course_start_date is null then
        fnd_message.set_name('OTA','OTA_13533_EVT_DATES_NULL');
        fnd_message.raise_error;
     end if;

  end if;

  open check_dates;
  fetch check_dates into l_start_date, l_end_date, l_act_vrsn_id;
  close check_dates;
  --
  if l_start_date is null then
    l_start_date := hr_api.g_sot;
  end if;
  if l_end_date is null then
    l_end_date := hr_api.g_eot;
  end if;
  --
  l_evt_start_date := p_course_start_date;
  l_evt_end_date   := p_course_end_date;
  --
  if p_event_status = 'P' then
     if p_course_start_date is null then
        l_evt_start_date := l_start_date;
     end if;
     if p_course_end_date is null then
        l_evt_end_date := l_end_date;
     end if;
  end if;
  /*  commented out for bug#4069324
    if p_event_type = 'SELFPACED' then
     if p_course_start_date is null then
        l_evt_start_date := l_start_date;
     end if;
    end if;
    */
    --
  -- added for bug#4069324
  if l_evt_end_date is null then
    l_evt_end_date := hr_api.g_eot;
  end if;
  --
  -- Added extra conditions to handle development events
  --
  if l_evt_start_date < l_start_date or
     l_evt_start_date > l_end_date or
     l_evt_end_date > l_end_date or
     l_evt_end_date < l_start_date then
     fnd_message.set_name('OTA','OTA_13534_EVT_INVALID_DATES');
     fnd_message.raise_error;
  end if;

  -- added for bug 3619563
  open check_act_dates;
  fetch check_act_dates into l_act_start_date, l_act_end_date;
  close check_act_dates;
  --
  if l_act_start_date is null then
    l_act_start_date := hr_api.g_sot;
  end if;
  if l_act_end_date is null then
    l_act_end_date := hr_api.g_eot;
  end if;
  --
  l_evt_start_date := p_course_start_date;
  l_evt_end_date   := p_course_end_date;
  --
  if p_event_status = 'P' then
     if p_course_start_date is null then
        l_evt_start_date := l_act_start_date;
     end if;
     if p_course_end_date is null then
        l_evt_end_date := l_act_end_date;
     end if;
  end if;
    /*  commented out for bug#4069324
    if p_event_type = 'SELFPACED' then
     if p_course_start_date is null then
        l_evt_start_date := l_act_start_date;
     end if;
    end if;
    */
  -- added for bug#4069324
  if l_evt_end_date is null then
    l_evt_end_date := hr_api.g_eot;
  end if;
  --

  --
  -- Added extra conditions to handle development events
  --
  if l_evt_start_date < l_act_start_date or
     l_evt_start_date > l_act_end_date or
     l_evt_end_date > l_act_end_date or
     l_evt_end_date < l_act_start_date then
     fnd_message.set_name('OTA','OTA_13168_EVT_ACT_DATE_OVERLAP');
     fnd_message.raise_error;
  end if;
  --
  -- added for bug 3619563
  --
  hr_utility.set_location(' Exiting:'||l_proc,10);
end COURSE_DATES_ARE_VALID;
/*--changes made for eBS by asud
procedure COURSE_DATES_ARE_VALID (p_activity_version_id in number,
                                  p_course_start_date          in date,
                                  p_course_end_date            in date,
                                  p_event_status        in varchar2) is
--
  l_proc       varchar2(30) := 'course_dates_are_valid';
  l_start_date date;
  l_end_date   date;
  l_evt_start_date date;
  l_evt_end_date date;
--
  cursor check_dates is
    select start_date, end_date
    from ota_activity_versions
    where activity_version_id = p_activity_version_id;
begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  hr_utility.trace('p_activity_version_id'||p_activity_version_id);
  hr_utility.trace('p_course_start_date'||p_course_start_date);
  hr_utility.trace('p_course_end_date'||p_course_end_date);
  hr_utility.trace('p_event_status'||p_event_status);
  if p_event_status <> 'P' then
     if p_course_start_date is null or
        p_course_end_date is null then
        fnd_message.set_name('OTA','OTA_13533_EVT_DATES_NULL');
        fnd_message.raise_error;
     end if;
  end if;
  --
  open check_dates;
  fetch check_dates into l_start_date, l_end_date;
  close check_dates;
  --
  if l_start_date is null then
    l_start_date := hr_api.g_sot;
  end if;
  if l_end_date is null then
    l_end_date := hr_api.g_eot;
  end if;
  --
  l_evt_start_date := p_course_start_date;
  l_evt_end_date   := p_course_end_date;
  --
  if p_event_status = 'P' then
     if p_course_start_date is null then
        l_evt_start_date := l_start_date;
     end if;
     if p_course_end_date is null then
        l_evt_end_date := l_end_date;
     end if;
  end if;
  --
  -- Added extra conditions to handle development events
  --
  if l_evt_start_date < l_start_date or
     l_evt_start_date > l_end_date or
     l_evt_end_date > l_end_date or
     l_evt_end_date < l_start_date then
     fnd_message.set_name('OTA','OTA_13534_EVT_INVALID_DATES');
     fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(' Exiting:'||l_proc,10);
end COURSE_DATES_ARE_VALID;
--
*/--changes made for eBS by asud
-- -----------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- -------------------------< BOOKINGS VALID >----------------------------
-- ----------------------------------------------------------------------------
--
--	Checks if Delegate Bookings are within the Event Enrollment start date
--      and end date.
--      N.B. Planned Events may have NULL Dates
--
--
procedure BOOKINGS_VALID 	 (p_event_id            in number,
                                  p_enrolment_start_date          in date,
                                  p_enrolment_end_date            in date,
                                  p_event_type          in VARCHAR2 ,
				  p_timezone IN VARCHAR2) is
--
  l_proc       varchar2(30) := 'Bookings_valid';
  l_dummy	varchar2(30);
--
  cursor check_dates is
    select 'X'
    from   ota_delegate_bookings
    where  event_id = p_event_id
    -- Modified for bug#5107347
    and    ota_timezone_util.convert_date(trunc(date_booking_placed)
                                         , to_char(date_booking_placed, 'HH24:MI')
					 , ota_timezone_util.get_server_timezone_code
					 , p_timezone)
       not between nvl(p_enrolment_start_date,hr_api.g_sot) and nvl(p_enrolment_end_date +1,hr_api.g_eot);
begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
--
  if p_event_type <> 'SESSION' or p_event_type <> 'PROGRAMME' then
  --
  open check_dates;
  fetch check_dates into l_dummy;
     if check_dates%found then
        close check_dates;
        fnd_message.set_name('OTA','OTA_13599_EVT_VALID_BOOKINGS');
        fnd_message.raise_error;
     end if;
  close check_dates;
  --
  end if;
  --
  hr_utility.set_location(' Exiting:'||l_proc,10);
  --
end bookings_valid;
--
-- ----------------------------------------------------------------------------
-- -------------------------< BOOKING DEAL VALID >----------------------------
-- ----------------------------------------------------------------------------
--
--	Checks if Booking Deals are within the Event start date
--      and end date.
--      N.B. Planned Events may have NULL Dates
--
--
procedure BOOKING_DEAL_VALID 	 (p_event_id            in number,
                                  p_course_start_date          in date,
                                  p_course_end_date            in date,
				  p_event_status	in varchar2) is
--
  l_proc       varchar2(30) := 'Booking_deal_valid';
  l_start_date date;
  l_end_date   date;
  l_evt_start_date date;
  l_evt_end_date date;
--
  cursor c_check_dates is
    select start_date, end_date
    from   ota_booking_deals
    where  event_id = p_event_id;
--
begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
--
   open c_check_dates;
    loop
      fetch c_check_dates into l_start_date, l_end_date;
      exit when c_check_dates%notfound;
      --
      if l_start_date is null then
        l_start_date := hr_api.g_sot;
      end if;
      if l_end_date is null then
        l_end_date := hr_api.g_eot;
      end if;
  --
      l_evt_start_date := p_course_start_date;
      l_evt_end_date   := p_course_end_date;
  --
      if p_event_status = 'P' then
        if p_course_start_date is null then
           l_evt_start_date := l_start_date;
        end if;
        if p_course_end_date is null then
           l_evt_end_date := l_end_date;
        end if;
      end if;
  --
     if l_start_date < l_evt_start_date or
        l_end_date > l_evt_end_date then
        fnd_message.set_name('OTA','OTA_13600_EVT_VALID_BD');
        fnd_message.raise_error;
     end if;
  --
    end loop;
  --
    close c_check_dates;
  --
  hr_utility.set_location(' Exiting:'||l_proc,10);
  --
end booking_deal_valid;
--
-- ----------------------------------------------------------------------------
-- -------------------------< SESSION_VALID >----------------------------------
-- ----------------------------------------------------------------------------
--
--	Checks if scheduled events are within the parent activity start date
--      and end date.
--
--
--
procedure session_valid(P_EVENT_ID          in number,
	          	P_COURSE_START_DATE in date ,
			P_COURSE_END_DATE   in date) is
  l_proc       varchar2(30) := 'session_valid';
  l_dummy      varchar2(30);
  --
  cursor check_dates is
    select null
    from ota_events
    where parent_event_id = p_event_id
    and   event_type = 'SESSION'
    and   (course_start_date < nvl(p_course_start_date,hr_api.g_sot)
    or    course_start_date > nvl(p_course_end_date,hr_api.g_eot));
  --
/*
  cursor check_course_null_dates is
    select 'X'
    from ota_events
    where parent_event_id = p_event_id
    and   event_type = 'SESSION';
*/
begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
/*
open check_course_null_dates;
     fetch check_course_null_dates into l_dummy;
     if check_course_null_dates%found and
        (p_course_start_date is null or p_course_end_date is null) then
        --
	--
        fnd_message.set_name('OTA', 'OTA_13579_EVT_SESSION_DATES');
        fnd_message.raise_error;
     end if;
  close check_course_null_dates;
  --
*/
  open check_dates;
     fetch check_dates into l_dummy;
     if check_dates%found then
        --
	-- Warn of session date
	--
        fnd_message.set_name('OTA', 'OTA_13482_SESSION_CONFLICT');
        fnd_message.raise_error;
     end if;
  close check_dates;
  hr_utility.set_location(' Leaving:'||l_proc,10);
end session_valid;
--------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- -------------------------< UNIQUE_EVENT_TITLE >-----------------------------
-- ----------------------------------------------------------------------------
--
--	Returns TRUE if the event has a title which is unique within its
--	business group. If the event id is not null, then the check avoids
--	comparing the title against itself. Titles are compared regardless
--	of case.
--
--
--
function UNIQUE_EVENT_TITLE (
	P_TITLE					     in	varchar2,
	P_BUSINESS_GROUP_ID			     in	number,
	P_PARENT_EVENT_ID			     in	number,
	P_EVENT_ID				     in	number	default null
	) return boolean is
--
	W_PROC						 varchar2 (72)
		:= G_PACKAGE || 'UNIQUE_EVENT_TITLE';
	W_TITLE_IS_UNIQUE				boolean;
	--
	cursor C1 is
		select 1
		  from OTA_EVENTS_VL			EVT
		  where EVT.BUSINESS_GROUP_ID	      = P_BUSINESS_GROUP_ID
		    and (    (P_PARENT_EVENT_ID      is null             )
		         or  (EVT.PARENT_EVENT_ID     = P_PARENT_EVENT_ID))
		    and upper (EVT.TITLE)	      = upper (P_TITLE)
		    and (    (P_EVENT_ID	     is null      )
		         or  (EVT.EVENT_ID	     <> P_EVENT_ID));
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Check arguments
	--
	HR_API.MANDATORY_ARG_ERROR (
		G_PACKAGE,
	 	'P_TITLE',
		P_TITLE);
	HR_API.MANDATORY_ARG_ERROR (
		G_PACKAGE,
		'P_BUSINESS_GROUP_ID',
		P_BUSINESS_GROUP_ID);
	--
	--	Unique ?
	--
	open C1;
	fetch C1
	  into G_DUMMY;
	W_TITLE_IS_UNIQUE := C1%notfound;
	close C1;
	--
	HR_UTILITY.SET_LOCATION (W_PROC, 10);
	return W_TITLE_IS_UNIQUE;
	--
end UNIQUE_EVENT_TITLE;
--
-- ----------------------------------------------------------------------------
-- -----------------------< CHECK_TITLE_IS_UNIQUE >----------------------------
-- ----------------------------------------------------------------------------
--
--	Validates the uniqueness of the event title (ignoring case).
--
procedure CHECK_TITLE_IS_UNIQUE (
	P_TITLE					     in	varchar2,
	P_BUSINESS_GROUP_ID			     in	number,
	P_PARENT_EVENT_ID			     in number,
	P_EVENT_ID				     in	number	default null,
	P_OBJECT_VERSION_NUMBER			     in	number	default null
	) is
	--
	W_PROC						varchar2 (72)
		:= G_PACKAGE || 'CHECK_TITLE_IS_UNIQUE';
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Do not perform the uniqueness check unless inserting, or updating
	--	with a value different from the current value (and not just changing
	--	case)
	--
	if (not (    (OTA_EVT_SHD.API_UPDATING (P_EVENT_ID, P_OBJECT_VERSION_NUMBER))
	         and (upper (P_TITLE) = upper (OTA_EVT_SHD.G_OLD_REC.TITLE)         ))) then
		--
		if (not UNIQUE_EVENT_TITLE (
				P_TITLE		     => P_TITLE,
				P_BUSINESS_GROUP_ID  => P_BUSINESS_GROUP_ID,
				P_PARENT_EVENT_ID    =>	P_PARENT_EVENT_ID,
				P_EVENT_ID	     =>	P_EVENT_ID)) then
			OTA_EVT_SHD.CONSTRAINT_ERROR ('OTA_EVENTS_UK2');
		end if;
		--
	end if;
	--
	HR_UTILITY.SET_LOCATION (' Leaving:' || W_PROC, 10);
	--
  EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.TITLE') THEN
      hr_utility.set_location(' Leaving:'||W_PROC, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||W_PROC, 50);

end CHECK_TITLE_IS_UNIQUE;
--
-- ----------------------------------------------------------------------------
-- ---------------------< check_session_time >-------------------------
-- ----------------------------------------------------------------------------
--     Added for Bug 3403113
--	This procedure checks if the session time is between the parent start
--	and end time.
--
--------------------------------------------------------------------------------
PROCEDURE check_session_time ( p_parent_event_id IN NUMBER,
                               p_session_start_date IN DATE,
                               p_session_start_time IN VARCHAR2,
                               p_session_end_date IN DATE,
                               p_session_end_time IN VARCHAR2,
                               p_event_id IN NUMBER default null,
                               p_object_version_number IN NUMBER default null) is
--
  CURSOR get_event_dates_cr is
  SELECT course_start_date,
         course_start_time,
         course_end_date,
         course_end_time
    FROM ota_events
   WHERE event_id = p_parent_event_id;

l_course_start_date     ota_events.course_start_date%type;
l_course_start_time     ota_events.course_start_time%type;
l_course_end_date       ota_events.course_start_date%type;
l_course_end_time       ota_events.course_start_time%type;

w_proc                  constant varchar2(72) := G_PACKAGE||'check_session_time';

BEGIN

	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Check parameters
	--
	HR_API.MANDATORY_ARG_ERROR (
		P_API_NAME		     =>	G_PACKAGE,
		P_ARGUMENT		     =>	'P_PARENT_EVENT_ID',
		P_ARGUMENT_VALUE	     =>	P_PARENT_EVENT_ID);
	--
	--
		--
		HR_UTILITY.TRACE ('Parent: ' || to_char (P_PARENT_EVENT_ID));
--bug 3451221
   IF (p_session_start_date IS NOT NULL AND
       p_session_start_time IS NOT NULL AND
       p_session_end_time IS NOT NULL) THEN

      IF ( substr(p_session_start_time,1,2) > substr(p_session_end_time,1,2) ) then
         fnd_message.set_name('OTA', 'OTA_13064_EVT_SSN_TIME');
         fnd_message.raise_error;
      ELSIF (( substr(p_session_start_time,1,2) = substr(p_session_end_time,1,2) ) AND
              ( substr(p_session_start_time,4,2) > substr(p_session_end_time,4,2) )) then
         fnd_message.set_name('OTA', 'OTA_13064_EVT_SSN_TIME');
         fnd_message.raise_error;
      END IF;

   END IF;
--Bug 3451221
   OPEN get_event_dates_cr;
    LOOP
      FETCH get_event_dates_cr INTO l_course_start_date,
                                    l_course_start_time,
                                    l_course_end_date,
                                    l_course_end_time;
       EXIT WHEN get_event_dates_cr%NOTFOUND;
    END LOOP;
   CLOSE get_event_dates_cr;

       -- If the Course , Session Start date are the same and
       -- the two start times are not null then check for correct time entries.
       --
       IF l_course_start_date = p_session_start_date THEN
          IF (l_course_start_time IS NOT NULL) AND
                   (p_session_start_time IS NOT NULL) THEN
             IF substr(l_course_start_time ,1,2) =
                        substr(p_session_start_time ,1,2) THEN
                IF substr(l_course_start_time ,4,2) >
                        substr(p_session_start_time ,4,2) THEN
                   fnd_message.set_name('OTA','OTA_13563_EVT_SESSION_TIME');
        		   fnd_message.raise_error;
                END IF;
             ELSIF substr(l_course_start_time ,1,2) >
                        substr(p_session_start_time ,1,2) THEN
                   fnd_message.set_name('OTA','OTA_13563_EVT_SESSION_TIME');
        		   fnd_message.raise_error;
             END IF;
        END IF;
        IF (l_course_start_time IS NOT NULL) AND (p_session_start_time IS NULL) THEN
           fnd_message.set_name('OTA','OTA_13563_EVT_SESSION_TIME');
		   fnd_message.raise_error;
       END IF;
      END IF;

       IF l_course_end_date = p_session_start_date THEN
          IF (l_course_end_time IS NOT NULL) AND
                   (p_session_end_time IS NOT NULL) THEN
             IF substr(l_course_end_time ,1,2) =
                        substr(p_session_end_time ,1,2) THEN
                IF substr(l_course_end_time ,4,2) <
                        substr(p_session_end_time ,4,2) THEN
                   fnd_message.set_name('OTA','OTA_13563_EVT_SESSION_TIME');
        		   fnd_message.raise_error;
                END IF;
             ELSIF substr(l_course_end_time ,1,2) <
                        substr(p_session_end_time ,1,2) THEN
                   fnd_message.set_name('OTA','OTA_13563_EVT_SESSION_TIME');
        		   fnd_message.raise_error;
             END IF;
        END IF;
        IF (l_course_end_time IS NOT NULL) AND (p_session_start_time IS NOT NULL) THEN
         IF substr(l_course_end_time ,1,2) =  substr(p_session_start_time ,1,2) THEN
                IF substr(l_course_end_time ,4,2) < substr(p_session_start_time ,4,2) THEN
                   fnd_message.set_name('OTA','OTA_13563_EVT_SESSION_TIME');
        		   fnd_message.raise_error;
                END IF;
          ELSIF substr(l_course_end_time ,1,2) <  substr(p_session_start_time ,1,2) THEN
                   fnd_message.set_name('OTA','OTA_13563_EVT_SESSION_TIME');
        		   fnd_message.raise_error;
          END IF;
        END IF;
       IF (l_course_end_time IS NOT NULL) AND (p_session_end_time IS NULL) THEN
           fnd_message.set_name('OTA','OTA_13563_EVT_SESSION_TIME');
		   fnd_message.raise_error;
       END IF;
      END IF;
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 10);

EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.COURSE_START_TIME') THEN
      hr_utility.set_location(' Leaving:'||w_proc, 60);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||w_proc, 70);
END check_session_time;

--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- ---------------------< COURSE_DATES_SPAN_SESSIONS >-------------------------
-- ----------------------------------------------------------------------------
--
--	Returns TRUE if the course dates for an event still span the dates of
--	its sessions. This function is overloaded so that one can check either
--	a new session date is valid or that updates to the course dates will
--	not invalidate any sessions.
--
--	This version of the function checks that a new or updated session date
--	lies within the course dates of its parent event.
--
function COURSE_DATES_SPAN_SESSIONS (
	P_PARENT_EVENT_ID		     in	number,
	P_NEW_SESSION_DATE		     in	date
	) return boolean is
--
W_PROC						varchar2 (72)
	:= G_PACKAGE || 'COURSE_DATES_SPAN_SESSIONS';
--
L_COURSE_START_DATE				date;
L_COURSE_END_DATE				date;
L_COURSE_SPANS_SESSIONS				boolean;
--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Check parameters
	--
	HR_API.MANDATORY_ARG_ERROR (
		P_API_NAME		     =>	G_PACKAGE,
		P_ARGUMENT		     =>	'P_PARENT_EVENT_ID',
		P_ARGUMENT_VALUE	     =>	P_PARENT_EVENT_ID);
	--
	if (P_NEW_SESSION_DATE is not null) then
		OTA_EVT_SHD.GET_COURSE_DATES (
						P_PARENT_EVENT_ID,
						L_COURSE_START_DATE,
						L_COURSE_END_DATE);
		--
		HR_UTILITY.TRACE ('Start date: ' || to_char (L_COURSE_START_DATE));
		HR_UTILITY.TRACE ('  End date: ' || to_char (L_COURSE_END_DATE));
		--
	        -- check if course start and end date are null
		-- if null then set them to start and end of time
		--
		if l_course_start_date is null or l_course_end_date is null then
		   fnd_message.set_name('OTA','OTA_13579_EVT_SESSION_DATES');
      		   fnd_message.raise_error;
                end if;
		/* if l_course_start_date is null then
                   l_course_start_date := hr_api.g_sot;
		end if;
		if l_course_end_date is null then
		   l_course_end_date := hr_api.g_eot;
                end if; */
		L_COURSE_SPANS_SESSIONS :=
			(    (L_COURSE_START_DATE is not null)
			 and (L_COURSE_END_DATE   is not null)
		         and (P_NEW_SESSION_DATE between L_COURSE_START_DATE
				                     and L_COURSE_END_DATE));
	else
		L_COURSE_SPANS_SESSIONS := true;
	end if;
	--
	return L_COURSE_SPANS_SESSIONS;
	--
end COURSE_DATES_SPAN_SESSIONS;
--
--	This version of the function checks that updated course dates do not
--	invalidate any of the event's sessions.
--
function COURSE_DATES_SPAN_SESSIONS (
	p_event_id		number,
	p_course_start_date	date,
	p_course_end_date	date) return boolean is
--
	W_PROC                  constant varchar2(72) := G_PACKAGE||'course_dates_span_sessions';
	--
	l_sessions_invalidated	boolean;
	--
	cursor csr_invalid_sessions is
		select 1
		  from ota_events
		  where	parent_event_id	      =	p_event_id
		    and	event_type	      = 'SESSION'
		    and	course_start_date
		    not between p_course_start_date
		        and p_course_end_date;
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Check parameters
	--
	HR_API.MANDATORY_ARG_ERROR (
		G_PACKAGE,
		'p_event_id',
		p_event_id);
	--
	if p_course_start_date is null or p_course_end_date is null then
		l_sessions_invalidated := TRUE;
	else
		open csr_invalid_sessions;
		fetch csr_invalid_sessions into g_dummy;
		l_sessions_invalidated := csr_invalid_sessions%found;
		close csr_invalid_sessions;
	end if;
	--
	HR_UTILITY.SET_LOCATION (W_PROC,10);
	--
	return NOT l_sessions_invalidated;
	--
end course_dates_span_sessions;
--
-- ----------------------------------------------------------------------------
-- ---------------------< check_class_session_times >--------------------------
-- ----------------------------------------------------------------------------
--     Added for Bug 3622035
--	This procedure checks if the session time is between the parent start
--	and end time.
--
--------------------------------------------------------------------------------
PROCEDURE check_class_session_times ( p_event_id IN ota_events.event_id%TYPE,
                                      p_course_start_date IN ota_events.course_start_date%TYPE,
                                      p_course_start_time IN ota_events.course_start_time%TYPE,
                                      p_course_end_date   IN ota_events.course_end_date%TYPE,
                                      p_course_end_time   IN ota_events.course_end_time%TYPE) is
--
  CURSOR get_ssn_times_cr is
  SELECT course_start_date,
         course_start_time,
         course_end_date,
         course_end_time
    FROM ota_events
   WHERE parent_event_id = p_event_id
     AND event_type = 'SESSION';

l_ssn_start_date     ota_events.course_start_date%type;
l_ssn_start_time     ota_events.course_start_time%type;
l_ssn_end_date       ota_events.course_start_date%type;
l_ssn_end_time       ota_events.course_start_time%type;

w_proc                  constant varchar2(72) := G_PACKAGE||'check_class_session_times';

BEGIN

	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--	--
	--
		--
		HR_UTILITY.TRACE ('Parent: ' || to_char (P_EVENT_ID));

   OPEN get_ssn_times_cr;
    LOOP
      FETCH get_ssn_times_cr INTO l_ssn_start_date,
                                  l_ssn_start_time,
                                  l_ssn_end_date,
                                  l_ssn_end_time;
       EXIT WHEN get_ssn_times_cr%NOTFOUND;

       -- If the Course , Session Start date are the same and
       -- the two start times are not null then check for correct time entries.
       --
       IF p_course_start_date = l_ssn_start_date THEN
          IF (p_course_start_time IS NOT NULL) AND
                   (l_ssn_start_time IS NOT NULL) THEN
             IF substr(p_course_start_time ,1,2) =
                        substr(l_ssn_start_time ,1,2) THEN
                IF substr(p_course_start_time ,4,2) >
                        substr(l_ssn_start_time ,4,2) THEN
                   fnd_message.set_name('OTA','OTA_13563_EVT_SESSION_TIME');
        		   fnd_message.raise_error;
                END IF;
             ELSIF substr(p_course_start_time ,1,2) >
                        substr(l_ssn_start_time ,1,2) THEN
                   fnd_message.set_name('OTA','OTA_13563_EVT_SESSION_TIME');
        		   fnd_message.raise_error;
             END IF;
        END IF;
      END IF;

       IF p_course_end_date = l_ssn_start_date THEN
          IF (p_course_end_time IS NOT NULL) AND
                   (l_ssn_end_time IS NOT NULL) THEN
             IF substr(p_course_end_time ,1,2) =
                        substr(l_ssn_end_time ,1,2) THEN
                IF substr(p_course_end_time ,4,2) <
                        substr(l_ssn_end_time ,4,2) THEN
                   fnd_message.set_name('OTA','OTA_13563_EVT_SESSION_TIME');
        		   fnd_message.raise_error;
                END IF;
             ELSIF substr(p_course_end_time ,1,2) <
                        substr(l_ssn_end_time ,1,2) THEN
                   fnd_message.set_name('OTA','OTA_13563_EVT_SESSION_TIME');
        		   fnd_message.raise_error;
             END IF;
        END IF;
      END IF;

    END LOOP;
   CLOSE get_ssn_times_cr;

	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 10);

EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.COURSE_START_TIME') THEN
      hr_utility.set_location(' Leaving:'||w_proc, 60);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||w_proc, 70);
END check_class_session_times;

-- ----------------------------------------------------------------------------
-- -----------------------< CHECK_UPDATED_COURSE_DATES >-----------------------
-- ----------------------------------------------------------------------------
--
procedure CHECK_UPDATED_COURSE_DATES (
	P_EVENT_ID			     in	number,
	P_OBJECT_VERSION_NUMBER		     in	number,
	P_EVENT_TYPE			     in	varchar2,
	P_COURSE_START_DATE		     in	date,
	P_COURSE_END_DATE		     in	date
	) is
--
W_PROC	constant varchar2(72) := G_PACKAGE||'check_updated_course_dates';
--
procedure check_parameters is
	--
	begin
	HR_API.MANDATORY_ARG_ERROR (	G_PACKAGE,
					'p_event_id',
					p_event_id);
					--
	HR_API.MANDATORY_ARG_ERROR (	G_PACKAGE,
					'p_event_type',
					p_event_type);
	end check_parameters;
	--
function course_dates_have_changed return boolean is
	--
	l_dates_updated	boolean := FALSE;
	--
	begin
	--
	if (OTA_EVT_SHD.api_updating (p_event_id, p_object_version_number)) then
	  --
	  l_dates_updated :=
	  (nvl (p_course_start_date, hr_general.start_of_time) <>
	  	nvl (OTA_EVT_SHD.g_old_rec.course_start_date, hr_general.start_of_time)
	  or nvl (p_course_end_date, hr_general.end_of_time) <>
	  	nvl (OTA_EVT_SHD.g_old_rec.course_end_date, hr_general.end_of_time)
	  		);
	  --
	end if;
	--
	return l_dates_updated;
	--
	end course_dates_have_changed;
	--
begin
--
HR_UTILITY.SET_LOCATION ('Entering:'||W_PROC,5);
--
check_parameters;
--
if course_dates_have_changed
and p_event_type in ('PROGRAMME MEMBER','SCHEDULED')
then
  --
  if NOT course_dates_span_sessions (
				p_event_id		=> p_event_id,
				p_course_start_date	=> p_course_start_date,
				p_course_end_date	=> p_course_end_date)
  then
    OTA_EVT_SHD.CONSTRAINT_ERROR ('OTA_EVT_EVENT_SESSION_SPAN');
  end if;
  --
end if;
--
  EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.COURSE_START_DATE',
                                     p_associated_column2 => 'OTA_EVENTS.COURSE_END_DATE') THEN
      hr_utility.set_location(' Leaving:'||w_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||w_proc, 50);

end check_updated_course_dates;
--
-- ----------------------------------------------------------------------------
-- ------------------------< check_cost_vals >---------------------------------
-- ----------------------------------------------------------------------------
--
procedure check_cost_vals
              (p_budget_currency_code in varchar2
              ,p_budget_cost in number
              ,p_actual_cost in number) is
  --
  v_proc      varchar2(72) := g_package||'check_cost_vals';
begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if (p_budget_cost is not null or p_actual_cost is not null) and
      p_budget_currency_code is null then
      --
      fnd_message.set_name('OTA','OTA_13394_TAV_COST_ATTR');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.BUDGET_COST',
                                     p_associated_column2 => 'OTA_EVENTS.BUDGET_CURRENCY_CODE',
                                     p_associated_column3 => 'OTA_EVENTS.ACTUAL_COST') THEN
      hr_utility.set_location(' Leaving:'||v_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||v_proc, 50);
end check_cost_vals;
--
-- ----------------------------------------------------------------------------
-- ------------------------< CHECK_SESSION_WITHIN_COURSE >---------------------
-- ----------------------------------------------------------------------------
--
--	Checks that a session date lies between the course start and end dates
--	of its parent event.
--
procedure CHECK_SESSION_WITHIN_COURSE (
	P_EVENT_TYPE			     in	varchar2,
	P_PARENT_EVENT_ID		     in	number,
	P_COURSE_START_DATE		     in	date,
	P_EVENT_ID			     in	number default null,
	P_OBJECT_VERSION_NUMBER		     in	number default null
	) is
--
W_PROC						varchar2 (72)
	:= G_PACKAGE || 'CHECK_SESSION_WITHIN_COURSE';
--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Check parameters
	--
	HR_API.MANDATORY_ARG_ERROR (
		P_API_NAME		     =>	G_PACKAGE,
		P_ARGUMENT		     =>	'P_EVENT_TYPE',
		P_ARGUMENT_VALUE	     =>	P_EVENT_TYPE);
	HR_API.MANDATORY_ARG_ERROR (
		P_API_NAME		     =>	G_PACKAGE,
		P_ARGUMENT		     =>	'P_PARENT_EVENT_ID',
		P_ARGUMENT_VALUE	     =>	P_PARENT_EVENT_ID);
	--
	--	OK ?
	--
	if not (    (OTA_EVT_SHD.API_UPDATING (P_EVENT_ID, P_OBJECT_VERSION_NUMBER))
	        and (OTA_EVT_SHD.G_OLD_REC.COURSE_START_DATE = P_COURSE_START_DATE)) then
		--
		HR_UTILITY.TRACE ('Parent: ' || to_char (P_PARENT_EVENT_ID));
		--
		if (    (P_EVENT_TYPE = 'SESSION')
		    and (not COURSE_DATES_SPAN_SESSIONS (
				P_PARENT_EVENT_ID	=> P_PARENT_EVENT_ID,
				P_NEW_SESSION_DATE	=> P_COURSE_START_DATE))) then
			OTA_EVT_SHD.CONSTRAINT_ERROR ('OTA_EVT_SESSION_TIMING');
		end if;
		--
	end if;
	--
	HR_UTILITY.SET_LOCATION (' Leaving:' || W_PROC, 10);
	--
EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.COURSE_START_DATE') THEN
      hr_utility.set_location(' Leaving:'||w_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||w_proc, 50);
end CHECK_SESSION_WITHIN_COURSE;
--
-- ----------------------------------------------------------------------------
-- -----------------------< VALID_PARENT_EVENT >-------------------------------
-- ----------------------------------------------------------------------------
--
--	Returns TRUE if the parent event ID specified exists in the events
--	table, has the same business group as the child row and is a valid
--	parent for the event type specified.
--
function VALID_PARENT_EVENT (
	P_PARENT_EVENT_ID		     in	number,
	P_BUSINESS_GROUP_ID		     in	number,
	P_EVENT_TYPE			     in	varchar2
	) return boolean is
--
	W_PARENT_ID_EXISTS			boolean;
	W_VALID_PARENT				boolean;
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || G_PACKAGE || 'VALID_PARENT_EVENT', 5);
	--
	--	Check parameters
	--
	HR_API.MANDATORY_ARG_ERROR (
		G_PACKAGE,
		'P_BUSINESS_GROUP_ID',
		P_BUSINESS_GROUP_ID);
	--
	HR_API.MANDATORY_ARG_ERROR (
		G_PACKAGE,
		'P_EVENT_TYPE',
		P_EVENT_TYPE);
	--
	--	Is there a parent ?
	--
	if (P_PARENT_EVENT_ID is not null) then
		--
		OTA_EVT_SHD.FETCH_EVENT_DETAILS (
			P_EVENT_ID	     =>	P_PARENT_EVENT_ID,
			P_EVENT_EXISTS	     =>	W_PARENT_ID_EXISTS);
		--
		if (W_PARENT_ID_EXISTS) then
			HR_UTILITY.TRACE ('Parent exists: True');
		else
			HR_UTILITY.TRACE ('Parent exists: Fales');
		end if;
		HR_UTILITY.TRACE ('Business grps: ' || to_char (P_BUSINESS_GROUP_ID)
		                             || '/' || to_char (G_FETCHED_REC.BUSINESS_GROUP_ID));
		HR_UTILITY.TRACE ('Types:         ' || P_EVENT_TYPE
					     || '/' || G_FETCHED_REC.EVENT_TYPE);
		W_VALID_PARENT :=
			     (W_PARENT_ID_EXISTS)
			and  (P_BUSINESS_GROUP_ID
					      =	G_FETCHED_REC.BUSINESS_GROUP_ID)
			and  (    (    (P_EVENT_TYPE
					      =	'SESSION')
			           and (G_FETCHED_REC.EVENT_TYPE
					     in	('SCHEDULED',
						 'PROGRAMME MEMBER')))
		              or  (    (P_EVENT_TYPE
					      =	'PROGRAMME MEMBER')
				   and (G_FETCHED_REC.EVENT_TYPE
					      =	'PROGRAMME')));
	--
	end if;
	--
	HR_UTILITY.SET_LOCATION ( ' Leaving:' || G_PACKAGE || 'VALID_PARENT_EVENT', 10);
	return W_VALID_PARENT;
	--
end VALID_PARENT_EVENT;
--
-- ----------------------------------------------------------------------------
-- -----------------------< CHECK_PARENT_EVENT_IS_VALID >----------------------
-- ----------------------------------------------------------------------------
--
procedure CHECK_PARENT_EVENT_IS_VALID (
	P_PARENT_EVENT_ID		     in	number,
	P_BUSINESS_GROUP_ID		     in	number,
	P_EVENT_TYPE			     in	varchar2,
	P_EVENT_ID			     in	number	default null,
	P_OBJECT_VERSION_NUMBER		     in	number	default null
	) is
begin
	--
	HR_UTILITY.SET_LOCATION (
		'Entering:' || G_PACKAGE || 'CHECK_PARENT_EVENT_IS_VALID',
		5);
	--
	if (    (P_PARENT_EVENT_ID                   is not null             )
	    and (not (    (OTA_EVT_SHD.API_UPDATING (P_EVENT_ID, P_OBJECT_VERSION_NUMBER))
	              and (OTA_EVT_SHD.G_OLD_REC.PARENT_EVENT_ID  = P_PARENT_EVENT_ID    )))) then
		--
		if (not VALID_PARENT_EVENT (
				P_PARENT_EVENT_ID,
				P_BUSINESS_GROUP_ID,
				P_EVENT_TYPE)) then
			OTA_EVT_SHD.CONSTRAINT_ERROR ('OTA_EVT_INVALID_PARENT');
		end if;
		--
	end if;
	--
	HR_UTILITY.SET_LOCATION (
		' Leaving:' || G_PACKAGE || 'CHECK_PARENT_EVENT_IS_VALID',
		10);
	--
end CHECK_PARENT_EVENT_IS_VALID;
--
-- ---------------------------------------------------------------------------
procedure CHECK_PROGRAM_ENROLMENT_SPAN (
--*****************************************************************************
--* Error if the programme's enrolment dates do not span the enrolment dates
--* of all its members.
--*****************************************************************************
--
p_event_id		number,
p_event_type		varchar2,
p_enrolment_start_date	date,
p_enrolment_end_date	date,
p_parent_event_id	number default null,
p_object_version_number	number default null) is
--
function enrolment_dates_valid return boolean is
	--
	l_valid_enrol_dates	boolean := TRUE;
	--
	cursor csr_programme_dates is
		--
		select	1
		from	ota_events
		where	event_id = p_parent_event_id
		and	(p_enrolment_start_date not between enrolment_start_date
							and enrolment_end_date
		or	p_enrolment_end_date not between enrolment_start_date
							and enrolment_end_date);
		--
	cursor csr_member_dates is
		--
		select	1
		from	ota_events
		where	parent_event_id = p_event_id
		and ((p_enrolment_start_date not between enrolment_start_date
							and enrolment_end_date)
			or(p_enrolment_end_date not between enrolment_start_date
							and enrolment_end_date));
		--
	begin
	--
	if p_event_type = 'PROGRAMME' then
	  --
	  -- Check that the parent dates still
	  -- span all the child dates
	  --
	  open csr_member_dates;
	  fetch csr_member_dates into g_dummy;
	  l_valid_enrol_dates := csr_member_dates%notfound;
	  close csr_member_dates;
	  --
	elsif p_event_type = 'PROGRAMME MEMBER' then
	  --
	  -- Check that the new member dates are within the parent
	  -- enrolment dates
	  --
	  open csr_programme_dates;
	  fetch csr_programme_dates into g_dummy;
	  l_valid_enrol_dates := csr_member_dates%notfound;
	  close csr_member_dates;
	  --
	end if;
	--
	return l_valid_enrol_dates;
	--
	end enrolment_dates_valid;
	--
procedure check_parameters is
	--
	begin
	--
	HR_API.MANDATORY_ARG_ERROR (	G_PACKAGE,
					'p_event_type',
					p_event_type);
					--
	HR_API.MANDATORY_ARG_ERROR (	G_PACKAGE,
					'p_event_id',
					p_event_id);
					--
	HR_API.MANDATORY_ARG_ERROR (	G_PACKAGE,
					'p_enrolment_start_date',
					p_enrolment_start_date);
					--
	HR_API.MANDATORY_ARG_ERROR (	G_PACKAGE,
					'p_enrolment_end_date',
					p_enrolment_end_date);
					--
	if (p_event_type = 'PROGRAMME' and p_parent_event_id is not null)
	or (p_event_type = 'PROGRAMME MEMBER' and p_parent_event_id is null) then
	  invalid_parameter(
			p_procedure_name=>'ota_evt_api.check_program_enrolment_span',
			p_optional_message=>'Test');
	end if;
	--
	end check_parameters;
	--
begin
  --
  --	 This check only applies to existing PROGRAMMEs and PROGRAMME_MEMBERs
  --
  if (    (P_EVENT_TYPE not in ('PROGRAMME', 'PROGRAMME MEMBER'))
      or  (not OTA_EVT_SHD.api_updating (p_event_id, p_object_version_number))) then
    return;
  end if;
  --
  --	With changing enrolment dates
  --
  if (    (OTA_EVT_SHD.g_old_rec.enrolment_start_date <> p_enrolment_start_date)
      or  (OTA_EVT_SHD.g_old_rec.enrolment_end_date   <> p_enrolment_end_date  )) then
    --
    check_parameters;
    --
    if NOT enrolment_dates_valid then
      OTA_EVT_SHD.CONSTRAINT_ERROR ('OTA_EVT_ENROLMENT_DATE_SPAN');
    end if;
    --
  end if;
  --

end check_program_enrolment_span;
--
-- ----------------------------------------------------------------------------
-- -------------------------< Price_Basis_Change >-----------------------------
-- ----------------------------------------------------------------------------
--
-- Price Basis Changes are not allowed if Enrollments or Event Associations
-- exist for the Event
--
procedure price_basis_change(p_event_id    number
                            ,p_price_basis varchar2) is
--
l_proc varchar2(72) := 'price_basis_change';
l_exists varchar2(1);
--
l_price_basis_changed boolean :=
      ota_general.value_changed(ota_evt_shd.g_old_rec.price_basis
                               ,p_price_basis);
--
cursor get_enrollments is
select null
from   ota_delegate_bookings
where  event_id = p_event_id;
--
cursor get_event_associations is
select null
from ota_event_associations
where  event_id = p_event_id;
--
begin
   hr_utility.set_location ('Entering:'||l_proc,5);
   --
   if p_event_id is not null and
      l_price_basis_changed then
   --
      open get_enrollments;
      fetch get_enrollments into l_exists;
      if get_enrollments%found then
         close get_enrollments;
         fnd_message.set_name('OTA','OTA_13527_PRICE_BASIS_CHANGE');
         fnd_message.raise_error;
      end if;
      close get_enrollments;
   --
      open get_event_associations;
      fetch get_event_associations into l_exists;
      if get_event_associations%found then
         close get_event_associations;
         fnd_message.set_name('OTA','OTA_13527_PRICE_BASIS_CHANGE');
         fnd_message.raise_error;
      end if;
      close get_event_associations;
   --
   end if;
   --
   hr_utility.set_location ('Leaving:'||l_proc,10);
EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.PRICE_BASIS') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);
end price_basis_change;
--
-- ----------------------------------------------------------------------------
-- -------------------------< check_timezone >-----------------------------
-- ----------------------------------------------------------------------------
--
-- Procedure to check timezone of a class
--
--
PROCEDURE check_timezone(p_timezone IN VARCHAR2)
IS
   l_timezone_id NUMBER := ota_timezone_util.get_timezone_id(p_timezone);
BEGIN
   IF l_timezone_id IS NULL THEN
      fnd_message.set_name('OTA','OTA_443982_TIMEZONE_ERROR');
      fnd_message.set_token('OBJECT_TYPE',ota_utility.get_lookup_meaning('OTA_OBJECT_TYPE','CL',810));
      fnd_message.raise_error;
   END IF;
END check_timezone;
--
-- ----------------------------------------------------------------------------
-- -------------------------< check_time_format >-----------------------------
-- ----------------------------------------------------------------------------
--
-- Procedure to check time format (HH24:MI) of a course_start_time and course_end_time bug#4895398
--
--
PROCEDURE check_time_format(p_time IN VARCHAR2)
IS
BEGIN
  IF p_time IS NOT NULL THEN
     IF (NOT (LENGTH(p_time) = 5
                  and substr (p_time, 3,1) = ':'
                  and (substr(p_time,1,1) >= '0' and substr(p_time,1,1)<= '2')
                  and (substr(p_time,2,1) >= '0' and substr(p_time,2,1)<= '9')
                  and (substr(p_time,4,1) >= '0' and substr(p_time,4,1)<= '5')
                  and (substr(p_time,5,1) >= '0' and substr(p_time,5,1)<= '9')
                  and (to_number (substr (p_time, 1,2)) between 0 and 23
		  and  to_number (substr (p_time,4)) between 0 and 59))) then
                      fnd_message.set_name('OTA','OTA_13444_EVT_TIME_FORMAT');
                      fnd_message.raise_error;
           END IF;
    END IF;
END;

-- ----------------------------------------------------------------------------
-- -------------------------< VALIDITY_CHECKS >--------------------------------
-- ----------------------------------------------------------------------------
--
--	Performs the validation routines common to both insert and update.
--
-- VT 05/06/97 #488173
procedure VALIDITY_CHECKS (
	P_REC				     in out nocopy OTA_EVT_SHD.G_REC_TYPE
	) is
--
W_PROC						varchar2 (72)
	:= G_PACKAGE || 'VALIDITY_CHECKS';
  l_course_start_date_changed boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.course_start_date,
			       p_rec.course_start_date);
  l_course_end_date_changed   boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.course_end_date,
           		       p_rec.course_end_date);
  l_enrolment_start_date_changed boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.enrolment_start_date,
			       p_rec.enrolment_start_date);
  l_enrolment_end_date_changed   boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.enrolment_end_date,
           		       p_rec.enrolment_end_date);
  l_public_event_flag_changed boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.public_event_flag,
                               p_rec.public_event_flag);
  l_title_changed boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.title,
                               p_rec.title);
  l_maximum_attendees_changed 	      boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.maximum_attendees,
                               p_rec.maximum_attendees);
  l_maximum_int_att_changed 	      boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.maximum_internal_attendees,
                               p_rec.maximum_internal_attendees);
  l_owner_id_changed			boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.owner_id,
					p_rec.owner_id);
  l_line_id_changed			boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.line_id,
					p_rec.line_id);
  l_training_center_id_changed			boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.training_center_id,
					p_rec.training_center_id);
  l_location_id_changed			boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.location_id,
					p_rec.location_id);
  l_offering_id_changed			boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.offering_id,
					p_rec.offering_id);
  l_timezone_changed			boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.timezone,
					p_rec.timezone);
--bug#4895398
  l_course_start_time_changed boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.course_start_time,p_rec.course_start_time);

  l_course_end_time_changed boolean
  := ota_general.value_changed(ota_evt_shd.g_old_rec.course_end_time,p_rec.course_end_time);
--bug#4895398

--Enhancement 1823602.
l_commitment_id			ra_customer_trx_all.customer_trx_id%TYPE;
l_commitment_number		ra_customer_trx_all.trx_number%TYPE;
l_commitment_start_date		ra_customer_trx_all.start_date_commitment%TYPE;
l_commitment_end_date		ra_customer_trx_all.end_date_commitment%TYPE;


--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	--	Check only non-static domains (constraints trap the static ones)
	--
	OTA_GENERAL.CHECK_DOMAIN_VALUE (
		P_DOMAIN_TYPE		     => 'DEV_EVENT_TYPE',
		P_DOMAIN_VALUE		     => P_REC.DEVELOPMENT_EVENT_TYPE);
	--
	OTA_GENERAL.CHECK_DOMAIN_VALUE (
		P_DOMAIN_TYPE		     => 'TRAINING_CENTRE',
		P_DOMAIN_VALUE		     => P_REC.CENTRE);
	--
	OTA_GENERAL.CHECK_DOMAIN_VALUE (
		P_DOMAIN_TYPE		     => 'OTA_DURATION_UNITS',
		P_DOMAIN_VALUE		     => P_REC.DURATION_UNITS);
	--
	OTA_GENERAL.CHECK_DOMAIN_VALUE (
		P_DOMAIN_TYPE		     => 'EVENT_USER_STATUS',
		P_DOMAIN_VALUE		     => P_REC.USER_STATUS);
	--
	OTA_GENERAL.CHECK_DOMAIN_VALUE (
		P_DOMAIN_TYPE		     => 'SCHEDULED_EVENT_STATUS',
		P_DOMAIN_VALUE		     => P_REC.EVENT_STATUS);
	--
	OTA_GENERAL.CHECK_VENDOR_IS_VALID (
						P_REC.VENDOR_ID,P_REC.COURSE_START_DATE);
	--
	OTA_GENERAL.CHECK_CURRENCY_IS_VALID (
						P_REC.CURRENCY_CODE);
	--
	OTA_GENERAL.CHECK_LANGUAGE_IS_VALID (
						P_REC.LANGUAGE_ID);
	--
        if p_rec.event_id is null or l_title_changed then
           check_title_is_unique(
                 P_TITLE             => p_rec.title,
                 P_BUSINESS_GROUP_ID => p_rec.business_group_id,
                 P_PARENT_EVENT_ID   => p_rec.parent_event_id,
                 P_EVENT_ID          => p_rec.event_id,
                 P_OBJECT_VERSION_NUMBER => p_rec.object_version_number);
        end if;
        --
        if P_REC.EVENT_TYPE in ('SCHEDULED','PROGRAMME', 'SELFPACED') and
           p_rec.event_id is not null then
              price_basis_change(p_rec.event_id
                                ,p_rec.price_basis);

        end if;
	--bug#4895398
	--
        --Course start time and end time format check
        --
         IF(p_rec.course_start_time IS NOT NULL and l_course_start_time_changed) THEN
           check_time_format(p_rec.course_start_time);
          END IF;

          IF(p_rec.course_end_time IS NOT NULL and l_course_end_time_changed) THEN
             check_time_format(p_rec.course_end_time);
          END IF;
	  --end bug#4895398
        --
	-- Development event checks
	--
	if P_REC.EVENT_TYPE in ('DEVELOPMENT','SCHEDULED','SELFPACED') then
          --
	  -- Check course dates are valid
	  --
/* --changes made for eBS by asud
	  COURSE_DATES_ARE_VALID (P_REC.ACTIVITY_VERSION_ID,
				  P_REC.COURSE_START_DATE,
				  P_REC.COURSE_END_DATE,
                                  P_REC.EVENT_STATUS);
*/--changes made for eBS by asud
	  COURSE_DATES_ARE_VALID (P_REC.PARENT_OFFERING_ID,
				              P_REC.COURSE_START_DATE,
				              P_REC.COURSE_END_DATE,
                              P_REC.EVENT_STATUS,
                              P_REC.EVENT_TYPE);

	   CHK_END_DATE(  P_REC.COURSE_END_DATE ,P_REC.COURSE_END_TIME) ;
           --bug 3192072
	   chk_start_date(p_rec.course_start_date, p_rec.course_start_time);
          --
	end if;
/*
        --Bug 2431755
	-- Self-Paced event specific checks
	 if P_REC.EVENT_TYPE = 'SELFPACED' then
            --
	    CHECK_PRICING (P_REC.price_basis,
			 P_REC.standard_price);
            --
        end if;
	--Bug 2431755
*/
	-- Scheduled event specific checks
	--
	if P_REC.EVENT_TYPE in ('SCHEDULED','SELFPACED') then
--	if P_REC.EVENT_TYPE = 'SCHEDULED' then
          --
       check_price_basis(p_rec.event_id ,
                         p_rec.price_basis,
                         p_rec.parent_offering_id,
                         p_rec.maximum_internal_attendees);


       chk_activity_version_id(p_rec.activity_version_id,
                                  p_rec.parent_offering_id);

	  CHECK_PRICING (P_REC.price_basis,
			 P_REC.standard_price,p_rec.currency_code);
          --
/*--changes made for eBS by asud
	  ENROLLMENT_DATES_ARE_VALID  (
						P_REC.ACTIVITY_VERSION_ID,
						P_REC.ENROLMENT_START_DATE,
						P_REC.ENROLMENT_END_DATE);
*/--changes made for eBS by asud
	  ENROLLMENT_DATES_ARE_VALID  (P_REC.PARENT_OFFERING_ID,
						           P_REC.ENROLMENT_START_DATE,
						           P_REC.ENROLMENT_END_DATE);

          ENROLLMENT_DATES_EVENT_VALID  (
   	  				   P_REC.ENROLMENT_START_DATE,
	  			           P_REC.ENROLMENT_END_DATE,
                                           P_REC.COURSE_START_DATE,
	  		                   P_REC.COURSE_END_DATE);
    /* bug 3795299
     if l_course_start_date_changed or l_course_end_date_changed then

          --ADDED by dbatra for training plan bug 3007101
	    ota_trng_plan_comp_ss.update_tpc_evt_change(p_rec.event_id,
                                                        p_rec.course_start_date,
                                                        p_rec.course_end_date);
	  end if;
     bug 3795299
     */
	end if;
	--
	if (P_REC.EVENT_TYPE = 'SCHEDULED') then
         if l_course_start_date_changed or l_course_end_date_changed then

	     session_valid(P_REC.EVENT_ID,
			   P_REC.COURSE_START_DATE,
			   P_REC.COURSE_END_DATE);

	     booking_deal_valid(P_REC.EVENT_ID,
			   P_REC.COURSE_START_DATE,
			   P_REC.COURSE_END_DATE,
			   P_REC.EVENT_STATUS);
	  end if;
      -- added for bug 3622035
      check_class_session_times(p_event_id          => p_rec.event_id,
                                p_course_start_date => p_rec.course_start_date,
                                p_course_start_time => p_rec.course_start_time,
                                p_course_end_date   => p_rec.course_end_date,
                                p_course_end_time   => p_rec.course_end_time);

      -- added for bug 3622035
    end if;

	if (P_REC.EVENT_TYPE = 'SESSION') then
		CHECK_SESSION_WITHIN_COURSE (
			P_EVENT_TYPE	     =>	P_REC.EVENT_TYPE,
			P_PARENT_EVENT_ID    =>	P_REC.PARENT_EVENT_ID,
			P_COURSE_START_DATE  =>	P_REC.COURSE_START_DATE,
			P_EVENT_ID	     =>	P_REC.EVENT_ID,
			P_OBJECT_VERSION_NUMBER
					     =>	P_REC.OBJECT_VERSION_NUMBER);
               --Added for Bug 3403113
                check_session_time(
                        p_parent_event_id    => p_rec.parent_event_id,
                        p_session_start_date => p_rec.course_start_date,
                        p_session_start_time => p_rec.course_start_time,
                        p_session_end_date   => p_rec.course_end_date,
                        p_session_end_time   => p_rec.course_end_time,
                        p_event_id           => p_rec.event_id,
                        p_object_version_number => p_rec.object_version_number);

	end if;
	--
	CHECK_PROGRAM_ENROLMENT_SPAN (
						P_REC.EVENT_ID,
						P_REC.EVENT_TYPE,
						P_REC.ENROLMENT_START_DATE,
						P_REC.ENROLMENT_END_DATE,
						P_REC.PARENT_EVENT_ID,
						P_REC.OBJECT_VERSION_NUMBER);
	--
        check_cost_vals
              (p_budget_currency_code => p_rec.budget_currency_code
              ,p_budget_cost          => p_rec.budget_cost
              ,p_actual_cost          => p_rec.actual_cost);
	--
          if l_enrolment_start_date_changed or l_enrolment_end_date_changed OR l_timezone_changed then
	     bookings_valid(P_REC.EVENT_ID,
			   P_REC.ENROLMENT_START_DATE,
			   P_REC.ENROLMENT_END_DATE,
			   P_REC.EVENT_TYPE,
			   P_REC.TIMEZONE);
	  end if;
	--
        if l_maximum_attendees_changed or l_maximum_int_att_changed then
           ota_evt_bus2.check_places(p_rec.event_id
                                  ,p_rec.maximum_attendees
				  ,p_rec.maximum_internal_attendees);

	--Added for mandatory enrollments
           ota_evt_bus2.check_mandatory_associations(p_rec.event_id
	                                     ,p_rec.maximum_attendees
				  ,p_rec.maximum_internal_attendees);
        end if;
	--
        if l_public_event_flag_changed then
           check_public_event_flag(p_rec.public_event_flag
                                  ,p_rec.event_id);
        end if;
	--
	  if l_owner_id_changed then
           check_owner_id (p_rec.event_id,
				   p_rec.owner_id,
				   p_rec.business_group_id,
				   p_rec.course_start_date);
	  end if;
        if l_line_id_changed then
           check_line_id (p_rec.event_id,
				   p_rec.line_id,
				   p_rec.org_id);
	  end if;
     /* Globalization */
        if l_training_center_id_changed then
           chk_training_center (p_rec.event_id,
                                p_rec.training_center_id);
        end if;

        if l_location_id_changed then
           chk_location        (p_rec.event_id,
                                p_rec.location_id,
                                p_rec.training_center_id,
                                p_rec.course_end_date);
        end if;
	/*Enhancement 1823602*/
	IF p_rec.line_id IS NOT NULL THEN
          /* For Bug 4492519 */
         IF p_rec.event_id is null or l_course_end_date_changed then
	    ota_utility.get_commitment_detail(p_rec.line_id,
					    l_commitment_number,
					    l_commitment_id,
					    l_commitment_start_date,
					    l_commitment_end_date);
		IF l_commitment_end_date IS NOT NULL
	            AND p_rec.course_end_date > l_commitment_end_date THEN
			FND_MESSAGE.SET_NAME ('OTA', 'OTA_OM_COMMITMENT');
			FND_MESSAGE.SET_TOKEN ('COMMITMENT_NUMBER', l_commitment_number);
			FND_MESSAGE.SET_TOKEN ('COMMITMENT_END_DATE', fnd_date.date_to_chardate(l_commitment_end_date));
		     FND_MESSAGE.RAISE_ERROR;
	       END IF;
          END IF;
	END IF;

	/*Enhancement 1823602*/

       /* Ilearing */
       /*
        if l_offering_id_changed then
           check_unique_offering_id(p_rec.event_id,
                                p_rec.offering_id);
        end if;
        */

	IF p_rec.event_type IN ('SCHEDULED', 'SESSION', 'SELFPACED') THEN
	   check_timezone(p_rec.timezone);
	END IF;


  	HR_UTILITY.SET_LOCATION (' Leaving:' || W_PROC, 10);
	--
end VALIDITY_CHECKS;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_child_entities >-----------------------|
-- ----------------------------------------------------------------------------
Procedure check_child_entities (p_event_id  in number) is
  --
  -- cursor to check if sessions exist for the event
  --
  Cursor c_session_details is
    select 'X'
    from ota_events
    where parent_event_id = p_event_id;
  --
  -- cursor to check if resources exist for the event
  --
  Cursor c_resource_details is
    select 'X'
    from ota_resource_bookings
    where event_id = p_event_id;
  --
  -- cursor to check if program membership exist for the event
  --
  Cursor c_program_membership_details is
    select 'X'
    from ota_program_memberships
    where program_event_id = p_event_id;
  --
  -- cursor to check if event association exist for the event
  --
  Cursor c_event_associations_details is
    select 'X'
    from ota_event_associations
    where event_id = p_event_id;
  --
  -- cursor to check if delegate bookings exist for the event
  --
  Cursor c_delegate_bookings_details is
    select 'X'
    from ota_delegate_bookings
    where event_id = p_event_id;
  -- 6683076
  -- cursor to check if evaluation exists for the event
  --
  Cursor c_evaluation_details is
    select 'X'
    from ota_evaluations
    where object_id = p_event_id
    and object_type = 'E';
  --
  -- cursor to check if booking deals exist for the event
  --
  Cursor c_booking_deals_details is
    select 'X'
    from ota_booking_deals
    where event_id = p_event_id;
  --
  -- cursor to check if cat inclusions exist for the event
  --
  Cursor c_act_cat_inclusions_details is
    select 'X'
    from ota_act_cat_inclusions
    where event_id = p_event_id;
  --
  --
  -- cursor to check if attempts exist for the event
  --
  Cursor c_attempts_details is
    select 'X'
    from ota_attempts
    where event_id = p_event_id;
  --
  -- cursor to check if the event is referenced in training plan costs
  --
  Cursor c_get_tpc_rows is
    select 'Y'
    from OTA_TRAINING_PLAN_COSTS
    where event_id = p_event_id;
  --
  -- cursor to check if the event is referenced in  per budget elements
  --
  Cursor c_get_pbe_rows is
    select 'Y'
    from per_budget_elements
    where event_id = p_event_id;

 /*For bug 4407518 */

  Cursor c_conference_details is
    select 'X'
    from OTA_CONFERENCES
    where event_id = p_event_id;
 /* for bug 4407518 */
  --
  l_dyn_curs   integer;
  l_dyn_rows   integer;
  --
  --
  l_proc	varchar2(72) := g_package||'check_child_entities';
  l_dummy       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the event has training_plan_cost records
  open  c_get_tpc_rows;
  fetch c_get_tpc_rows into l_dummy;
  if c_get_tpc_rows%found then
    close c_get_tpc_rows;
    fnd_message.set_name ('OTA', 'OTA_13823_EVT_NO_DEL_TPC_EXIST');
    fnd_message.raise_error;
  else
    close c_get_tpc_rows;
     -- Determine if the event has per_budget_element records
     open c_get_pbe_rows;
     fetch c_get_pbe_rows into l_dummy;
     if c_get_pbe_rows%found then
       close c_get_pbe_rows;
       fnd_message.set_name ('OTA', 'OTA_13824_EVT_NO_DEL_BGE_EXIST');
       fnd_message.raise_error;
     else
       close c_get_pbe_rows;
     end if;
  end if;
  --
  -- Raise error if sessions exists.
  --
  open c_session_details;
  fetch c_session_details into l_dummy;
  if c_session_details%found then
  --
    close c_session_details;
  --
    fnd_message.set_name ('OTA', 'OTA_13677_EVT_SESSION_EXISTS');
    fnd_message.raise_error;
  --
  end if;
  --
  close c_session_details;
  --
  -- Raise error if resoure bookings exists.
  --
  open c_resource_details;
  fetch c_resource_details into l_dummy;
  if c_resource_details%found then
  --
    close c_resource_details;
  --
    fnd_message.set_name ('OTA', 'OTA_13678_EVT_RES_EXISTS');
    fnd_message.raise_error;
  --
  end if;
  --
  close c_resource_details;
  --
  -- Raise error if program membership exists.
  --
  open c_program_membership_details;
  fetch c_program_membership_details into l_dummy;
  if c_program_membership_details%found then
  --
    close c_program_membership_details;
  --
    fnd_message.set_name ('OTA', 'OTA_13681_EVT_PMM_EXISTS');
    fnd_message.raise_error;
  --
  end if;
  --
  close c_program_membership_details;
  --
  -- Raise error if event associations exists.
  --
  open c_event_associations_details;
  fetch c_event_associations_details into l_dummy;
  if c_event_associations_details%found then
  --
    close c_event_associations_details;
  --
    fnd_message.set_name ('OTA', 'OTA_13683_EVT_TEA_EXISTS');
    fnd_message.raise_error;
  --
  end if;
  --
  close c_event_associations_details;
  --
  -- Raise error if delegate bookings exists.
  --
  open c_delegate_bookings_details;
  fetch c_delegate_bookings_details into l_dummy;
  if c_delegate_bookings_details%found then
  --
    close c_delegate_bookings_details;
  --
    fnd_message.set_name ('OTA', 'OTA_13679_EVT_TDB_EXISTS');
    fnd_message.raise_error;
  --
  end if;
  --
  close c_delegate_bookings_details;
  -- 6683076
  -- Raise error if evaluation exists.
  --
  open c_evaluation_details;
  fetch c_evaluation_details into l_dummy;
  if c_evaluation_details%found then
  --
    close c_evaluation_details;
  --
    fnd_message.set_name ('OTA', 'OTA_467095_EVT_EVAL_EXISTS');
    fnd_message.raise_error;
  --
  end if;
  --
  close c_evaluation_details;
  --
  -- Raise error if booking deals exists.
  --
  open c_booking_deals_details;
  fetch c_booking_deals_details into l_dummy;
  if c_booking_deals_details%found then
  --
    close c_booking_deals_details;
  --
    fnd_message.set_name ('OTA', 'OTA_13680_EVT_TBD_EXISTS');
    fnd_message.raise_error;
  --
  end if;
  --
  close c_booking_deals_details;
  --
  -- Raise error if activity category inclusions exists.
  --
  open c_act_cat_inclusions_details;
  fetch c_act_cat_inclusions_details into l_dummy;
  if c_act_cat_inclusions_details%found then
  --
    close c_act_cat_inclusions_details;
  --
    fnd_message.set_name ('OTA', 'OTA_13682_EVT_CAT_EXISTS');
    fnd_message.raise_error;
  --
  end if;
  --
  close c_act_cat_inclusions_details;
  --
  -- Raise error if activity category inclusions exists.
  --
  open c_attempts_details;
  fetch c_attempts_details into l_dummy;
  if c_attempts_details%found then
  --
    close c_attempts_details;
  --
    fnd_message.set_name ('OTA', 'OTA_443538_EVT_ATT_EXISTS');
    fnd_message.raise_error;
  --
  end if;
  --
  close c_attempts_details;

/*for bug 4407518 */
  open c_conference_details;
  fetch c_conference_details into l_dummy;
  if c_conference_details%found then
     close c_conference_details;
     fnd_message.set_name('OTA', 'OTA_443916_EVT_CFR_EXISTS');
     fnd_message.raise_error;
  end if;
  close c_conference_details;


  hr_utility.set_location(' Leaving:'||l_proc, 10);
EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.EVENT_ID') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 70);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
End check_child_entities;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_for_st_finance_lines >-----------------|
-- ----------------------------------------------------------------------------
--
--	This function checks to see if any 'ST' succesful Transferred finance Lines
--	which have not been cancelled exists for any booking within the Event.
--
function check_for_st_finance_lines (
	p_event_id		number) return boolean is
--
	W_PROC                  constant varchar2(72) := G_PACKAGE||'check_for_st_finance_lines';
	--
	l_st_finance_lines	boolean;
	--
	cursor csr_st_finance_lines is
		select 1
		  from ota_finance_lines tfl,
		       ota_delegate_bookings tdb
		  where	tdb.event_id = p_event_id
		    and	tdb.booking_id = tfl.booking_id
		    and	tfl.transfer_status = 'ST'
		    and tfl.cancelled_flag = 'N';
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
		open csr_st_finance_lines;
		fetch csr_st_finance_lines into g_dummy;
		l_st_finance_lines := csr_st_finance_lines%found;
		close csr_st_finance_lines;
	--
	HR_UTILITY.SET_LOCATION (W_PROC,10);
	--
	return l_st_finance_lines;
	--
end check_for_st_finance_lines;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_owner_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
--	This function checks to see if any the owner_id exists in
--	per_people_f table
--
--
Procedure check_owner_id (p_event_id in number,
				p_owner_id in number,
				p_business_group_id in number,
				p_course_start_date in date)
Is
	l_proc  varchar2(72) := g_package||'check_owner_id';

CURSOR c_people
IS
SELECT null
FROM Per_all_people_f per
WHERE per.person_id = p_owner_id and
      per.business_group_id = p_business_group_id and
      NVL(p_course_start_date,TRUNC(SYSDATE)) between
	effective_start_date and effective_end_date;

CURSOR c_people_cross
IS
SELECT null
FROM Per_all_people_f per
WHERE per.person_id = p_owner_id and
      NVL(p_course_start_date,TRUNC(SYSDATE)) between
	effective_start_date and effective_end_date;


l_exist varchar2(1);
--l_cross_business_group varchar2(1):= FND_PROFILE.VALUE('HR_CROSS_BUSINESS_GROUP');
l_single_business_group_id number := FND_PROFILE.VALUE('OTA_HR_GLOBAL_BUSINESS_GROUP_ID');


Begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --

 if (((p_event_id is not null) and
      nvl(ota_evt_shd.g_old_rec.owner_id,hr_api.g_number) <>
         nvl(p_owner_id,hr_api.g_number))
   or (p_event_id is null)) then

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
EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.OWNER_ID') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);
end check_owner_id;

-- ----------------------------------------------------------------------------
-- |---------------------------<  check_line_id  >---------------------------|
-- ----------------------------------------------------------------------------
Procedure check_line_id
  (p_event_id                in number
   ,p_line_id 			in number
   ,p_org_id			in number) is

--
  l_proc  varchar2(72) := g_package||'chk_line_id';
  l_exists	varchar2(1);

--
--  cursor to check if line is exist in OE_ORDER_LINES .
--
   cursor csr_order_line is
     select null
     from oe_order_lines_all
     where line_id = p_line_id;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

if (((p_event_id is not null) and
      nvl(ota_evt_shd.g_old_rec.line_id,hr_api.g_number) <>
         nvl(p_line_id,hr_api.g_number))
   or (p_event_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_line_id is not null) then
          hr_utility.set_location('Entering:'||l_proc, 15);
            open csr_order_line;
            fetch csr_order_line into l_exists;
            if csr_order_line%notfound then
               close csr_order_line;
               fnd_message.set_name('OTA','OTA_13888_TDB_LINE_INVALID');
               fnd_message.raise_error;
            end if;
            close csr_order_line;
            hr_utility.set_location('Entering:'||l_proc, 20);
      end if;
end if;
hr_utility.set_location('Entering:'||l_proc, 30);
EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.LINE_ID') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);
end check_line_id;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_status_changed  >----------------------|
-- ----------------------------------------------------------------------------
-- This procedure will check whether the status is changed. this procedure is
-- called by post_update procedure and will be only used by OM integration.
-- The purpose of this procedure is to cancel an order line, Create RMA and
-- To notify the Workflow to continue.

Procedure chk_status_changed
  (p_line_id 			in number
   ,p_event_status		in varchar2
   ,p_event_id			in number
   ,p_org_id 			in number
   ,p_owner_id                in number
   ,p_event_title			in varchar2
	   ) is

  l_proc  varchar2(72) := g_package||'chk_status_changed';

  l_event_status_changed        boolean :=
  ota_general.value_changed (ota_evt_shd.g_old_rec.event_status,
                                                  p_event_status);
  l_status_type    	ota_booking_status_types.type%type;
  l_old_status_type 	ota_booking_status_types.type%type;
  l_invoice_rule		varchar2(80);
  l_exist			varchar2(1);
  l_dynamicSqlString    VARCHAR2(2000);
  l_ins_status          VARCHAR2(1);
  l_industry            VARCHAR2(1);
  l_err_num             VARCHAR2(30) := '';
  l_err_msg             VARCHAR2(1000) := '';

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   IF p_line_id is not null THEN
   	IF l_event_status_changed THEN
	   IF  p_event_status = 'A' THEN

                hr_utility.set_location('Entering:'||l_proc, 10);

		 	ota_utility.check_invoice(
					 	p_line_id => p_line_id,
					 	p_org_id => p_org_id,
						p_exist =>  l_exist);
               IF fnd_installation.get(660, 660, l_ins_status, l_industry) THEN
                 BEGIN
			IF l_exist = 'Y' THEN
			   Begin
			    hr_utility.set_location('Entering:'||l_proc, 15);

			 /*  l_dynamicSqlString := '
                     		ota_om_upd_api.create_rma(
					:p_Line_id,
                              :p_org_id);';
                     EXECUTE IMMEDIATE l_dynamicSqlString
                          USING IN p_line_id,
					  IN p_org_id;*/
                        ota_om_upd_api.create_rma(p_line_id,p_org_id);
				exception when others then
    			       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    				hr_utility.set_message_token('PROCEDURE', l_proc);
    				hr_utility.set_message_token('STEP','15');
    				hr_utility.raise_error;

                      End;
			ELSE
			    Begin
			      hr_utility.set_location('Entering:'||l_proc, 20);
			      /*l_dynamicSqlString := '
                         	ota_om_upd_api.cancel_order(
					p_Line_id,
					p_org_id);' ;
                        EXECUTE IMMEDIATE l_dynamicSqlString
                          USING IN p_line_id,
					  IN p_org_id;*/
                        ota_om_upd_api.cancel_order(p_line_id,p_org_id);
                     	exception when others then
    			       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    				hr_utility.set_message_token('PROCEDURE', l_proc);
    				hr_utility.set_message_token('STEP','20');
    				hr_utility.raise_error;

                     End;

               	END IF;

                  END;


			ota_initialization_wf.INITIALIZE_CANCEL_EVENT(
					p_Line_id	 	=> p_Line_id,
					p_org_id		=> p_org_id,
					p_Status 		=> null,
					p_Event_id 		=> p_event_id,
					p_owner_id		=> p_owner_id,
					p_itemtype		=> 'OTWF',
					p_event_title	=> p_event_title);
               END IF;


           END IF;

	   END IF;
      END IF;


hr_utility.set_location('Leaving:'||l_proc, 10);
/*EXCEPTION WHEN OTHERS
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;*/

end chk_status_changed;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_Order_line_exist  >----------------------|
-- ----------------------------------------------------------------------------
-- Description : This procedure will be called by Delete_validate procedure. This
--               procedure will check whether order line exist or not.

--
Procedure chk_Order_line_exist
  (p_line_id 			in number
   ,p_org_id			in number) is

--
  l_proc  varchar2(72) := g_package||'chk_order_line_exist';


Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

if p_line_id is not null then
   fnd_message.set_name('OTA','OTA_13896_EVT_ORDER_LINE_EXIST');
   fnd_message.raise_error;
   hr_utility.set_location('Entering:'||l_proc, 20);

end if;
hr_utility.set_location('Leaving:'||l_proc, 30);
EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.LINE_ID') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);
end chk_order_line_exist;


-- ----------------------------------------------------------------------------
-- |-----------------------<  chk_Training_center  >---------------------------|
-- ----------------------------------------------------------------------------
-- Description : This procedure will be called by Insert_validate procedure and
--               Update_validaate procedure. This
--               procedure will check whether Training center exist or not.

--
Procedure chk_Training_center
  (p_event_id                in number,
   p_training_center_id      in number)
IS


--
  l_proc  varchar2(72) := g_package||'chk_training_center';
  l_exists	varchar2(1);

  Cursor c_training_center
  IS
  Select null
  From HR_ALL_ORGANIZATION_UNITS
  Where organization_id = p_training_center_id;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if (((p_event_id is not null) and
      nvl(ota_evt_shd.g_old_rec.training_center_id,hr_api.g_number) <>
         nvl(p_training_center_id,hr_api.g_number))
   or (p_event_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_training_center_id is not null) then
	  hr_utility.set_location('Entering:'||l_proc, 15);
            open c_training_center;
            fetch c_training_center into l_exists;
            if c_training_center%notfound then
               close c_training_center;
               fnd_message.set_name('OTA','OTA_13907_TSR_TRNCTR_NOT_EXIST');
               fnd_message.raise_error;
            end if;
            close c_training_center;
            hr_utility.set_location('Entering:'||l_proc, 20);
      end if;
end if;
hr_utility.set_location('Entering:'||l_proc, 30);
EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.TRAINING_CENTER_ID') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);
end;

-- ----------------------------------------------------------------------------
-- |-----------------------------<  chk_location  >---------------------------|
-- ----------------------------------------------------------------------------
-- Description : This procedure will be called by Insert_validate procedure and
--               Update_validaate procedure. This
--               procedure will check whether Location exist or not.

--
Procedure Chk_location
  (p_event_id 		in number,
   p_location_id 	      in number,
   p_training_center_id in number,
   p_course_end_date in date)
IS


--
  l_proc  varchar2(72) := g_package||'chk_location';
  l_exists	varchar2(1);
 Cursor c_location
  IS
  Select null
  From HR_LOCATIONS_ALL loc
  Where loc.location_id = p_location_id
  and nvl(loc.inactive_date,to_date('31-12-4712','DD-MM-YYYY')) >= nvl(p_course_end_date,sysdate);

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  if (((p_event_id is not null) and
      nvl(ota_evt_shd.g_old_rec.location_id,hr_api.g_number) <>
         nvl(p_location_id,hr_api.g_number))
   or (p_event_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_location_id is not null) then
	  hr_utility.set_location('Entering:'||l_proc, 15);
            open c_location;
            fetch c_location into l_exists;
            if c_location%notfound then
               close c_location;
               fnd_message.set_name('OTA','OTA_13908_TSR_LOC_NOT_EXIST');
               fnd_message.raise_error;
            end if;
            close c_location;
            hr_utility.set_location('Entering:'||l_proc, 20);
      end if;
end if;
hr_utility.set_location('Entering:'||l_proc, 30);
EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.LOCATION_ID') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 40);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 50);
end;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_unique_offering_id>------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check uniqueness of offering_id
--
--
--
--
Procedure check_unique_offering_id
(
p_event_id in number,
p_offering_id  		    in number)

IS

l_proc  varchar2(72) := g_package||'check_unique_offering_id';
l_exists	varchar2(1);

cursor csr_offering is
     select null
     from ota_events
     where offering_id = p_offering_id;

Begin

 hr_utility.set_location('Entering:'||l_proc, 5);

if (((p_event_id is not null) and
      nvl(ota_evt_shd.g_old_rec.offering_id,hr_api.g_number) <>
         nvl(p_offering_id,hr_api.g_number))
   or (p_event_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_offering_id is not null) then
          hr_utility.set_location('Entering:'||l_proc, 15);
           open csr_offering;
            fetch csr_offering into l_exists;
            if csr_offering%found then
               ota_evt_shd.constraint_error(p_constraint_name =>'OTA_EVENTS_UK4');
            end if;
            close csr_offering;
            hr_utility.set_location('Leaving:'||l_proc, 20);
      end if;
end if;
hr_utility.set_location('Leaving:'||l_proc, 30);
EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.OFFERING_ID') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 70);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
End;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_activity_version_id>--------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check if parent_offering_id belongs to the activity_version_id
--
--
--
--
Procedure chk_activity_version_id
(p_activity_version_id          in number,
 p_parent_offering_id  		    in number)

IS

l_proc      varchar2(72) := g_package||'chk_activity_version_id';
l_exists	varchar2(1);

CURSOR csr_offering IS
     SELECT null
      FROM ota_offerings off,
           ota_activity_versions act
     WHERE off.offering_id = p_parent_offering_id
       AND off.activity_version_id = act.activity_version_id
       AND act.activity_version_id = p_activity_version_id;

Begin

 hr_utility.set_location('Entering:'||l_proc, 5);
         open csr_offering;
            fetch csr_offering into l_exists;
            if csr_offering%notfound then
               close csr_offering;
               fnd_message.set_name('OTA','OTA_443321_EVT_OFF_INVALID_ACT');
               fnd_message.raise_error;
            end if;
            close csr_offering;
            hr_utility.set_location('Leaving:'||l_proc, 20);
EXCEPTION
WHEN app_exception.application_exception THEN
   IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.ACTIVITY_VERSION_ID') THEN
      hr_utility.set_location(' Leaving:'||l_proc, 70);
   RAISE;
  END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
End chk_activity_version_id;

--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_secure_event_flag >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
-- Check if the secure class is being modified by the user who belongs to
-- the sponsor org. if not, throw an error.
--
--
--
Procedure chk_secure_event_flag (p_organization_id in number)
IS

l_proc		varchar2(72) := g_package||'chk_secure_event_flag';
l_username	fnd_user.user_name%TYPE;
l_user          fnd_user.user_name%TYPE;
l_condition	boolean;

CURSOR csr_org IS
SELECT user_name
  FROM fnd_user f,
       per_all_assignments_f p
 WHERE p.organization_id = p_organization_id
   AND f.employee_id = p.person_id
   AND trunc(sysdate) BETWEEN p.effective_start_date AND p.effective_end_date
   AND f.user_id = to_number(fnd_profile.value('USER_ID'));

BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);

OPEN csr_org;
   FETCH csr_org INTO l_username;
if csr_org%notfound then
     fnd_message.set_name('OTA', 'OTA_EVT_SECURE');
     fnd_message.raise_error;
end if;
close csr_org;



 /*   OPEN csr_org;
   FETCH csr_org INTO l_username;
         l_user := fnd_profile.value('USERNAME');
         l_condition := nvl(l_user, 'UNSET1') = nvl(l_username, 'UNSET2');
         IF NOT l_condition THEN
            fnd_message.set_name('OTA', 'OTA_EVT_SECURE');
            fnd_message.raise_error;
        END IF;
  CLOSE csr_org;*/
 hr_utility.set_location('Leaving:'||l_proc, 20);

EXCEPTION
   WHEN app_exception.application_exception THEN
        IF hr_multi_message.exception_add(p_associated_column1 => 'OTA_EVENTS.SECURE_EVENT_FLAG') THEN
           hr_utility.set_location('Leaving:'||l_proc, 40);
           RAISE;
       END IF;
           hr_utility.set_location('Leaving:'||l_proc, 50);
END chk_secure_event_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- VT 05/06/97 #488173
Procedure insert_validate(p_rec in out nocopy ota_evt_shd.g_rec_type) is
--
	l_proc  varchar2(72) := g_package||'insert_validate';
	--
Begin
	--
	hr_utility.set_location('Entering:'||l_proc, 5);
	--modified for eBS by asud
    /*
	-- Call all supporting business operations
	--
	hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
	--
	VALIDITY_CHECKS (
		P_REC		     =>	P_REC);
	--
	hr_utility.set_location(' Leaving:'||l_proc, 10);
	--*/
	--modified for eBS by asud
	-- Call all supporting business operations
	-- Validate Important Attributes
	hr_api.validate_bus_grp_id(p_business_group_id  => p_rec.business_group_id,
                               p_associated_column1 => ota_evt_shd.g_tab_nam||'.BUSINESS_GROUP_ID');  -- Validate Bus Grp
	--
    hr_multi_message.end_validation_set;

	VALIDITY_CHECKS (
		P_REC		     =>	P_REC);

       -- bug 4348022
       IF p_rec.secure_event_flag = 'Y' THEN
          chk_secure_event_flag(p_organization_id => p_rec.organization_id);
      END IF;
      -- bug 4348022

ota_evt_bus.chk_ddf(p_rec);
	--
	hr_utility.set_location(' Leaving:'||l_proc, 10);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- VT 05/06/97 #488173
Procedure update_validate(p_rec in out nocopy ota_evt_shd.g_rec_type) is
--
	l_proc  varchar2(72) := g_package||'update_validate';
        l_secure_event_flag_changed boolean
            := ota_general.value_changed(ota_evt_shd.g_old_rec.secure_event_flag, p_rec.secure_event_flag);
        l_organization_id_changed boolean
            := ota_general.value_changed(ota_evt_shd.g_old_rec.organization_id, p_rec.organization_id);
	--
Begin
	--
	hr_utility.set_location('Entering:'||l_proc, 5);
	--
	-- Call all supporting business operations
	--
    /*
	hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
	--
        VALIDITY_CHECKS (
                P_REC                => P_REC);
        --
	hr_utility.set_location(' Leaving:'||l_proc, 10);
	--
    */
	-- Validate Important Attributes
	hr_api.validate_bus_grp_id(p_business_group_id  => p_rec.business_group_id,
                               p_associated_column1 => ota_evt_shd.g_tab_nam||'.BUSINESS_GROUP_ID');  -- Validate Bus Grp
	--
    hr_multi_message.end_validation_set;

	VALIDITY_CHECKS (
		P_REC		     =>	P_REC);
       --
       -- bug 4348022
          IF p_rec.secure_event_flag = 'Y' THEN
                    IF l_secure_event_flag_changed THEN
                       chk_secure_event_flag(p_organization_id => p_rec.organization_id);
                 ELSE -- secure event flag not changed
                      IF l_organization_id_changed THEN
                         chk_secure_event_flag(p_organization_id => ota_evt_shd.g_old_rec.organization_id);
                         chk_secure_event_flag(p_organization_id => p_rec.organization_id);
                    ELSE
                         chk_secure_event_flag(p_organization_id => p_rec.organization_id);
                     END IF;
                 END IF;
        ELSE
             IF l_secure_event_flag_changed THEN
                chk_secure_event_flag(p_organization_id => ota_evt_shd.g_old_rec.organization_id);
           END IF;
        END IF;
        -- bug 4348022

ota_evt_bus.chk_ddf(p_rec);
	--
	hr_utility.set_location(' Leaving:'||l_proc, 10);
	--

End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_evt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
    check_child_entities (p_event_id => p_rec.event_id);
    chk_Order_line_exist(ota_evt_shd.g_old_rec.line_id
   				,ota_evt_shd.g_old_rec.org_id) ;
  --
    IF ota_evt_shd.g_old_rec.secure_event_flag = 'Y' THEN
       chk_secure_event_flag(p_organization_id => ota_evt_shd.g_old_rec.organization_id);
   END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ota_evt_bus;

/
