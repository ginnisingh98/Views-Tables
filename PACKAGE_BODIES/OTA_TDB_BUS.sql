--------------------------------------------------------
--  DDL for Package Body OTA_TDB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TDB_BUS" as
/* $Header: ottdb01t.pkb 120.26.12010000.3 2009/10/12 06:51:15 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_tdb_bus.';  -- Global package name
--
--***************************** STARTS HERE **********************************
--
g_event_rec             ota_evt_shd.g_rec_type;
--
--
-- Global package name
--
-- global constants
--
-- Booking Status Types
--
g_wait_list_booking     varchar2(1)     := 'W';
g_placed_booking        varchar2(1)     := 'P';
g_attended_booking      varchar2(1)     := 'A';
g_pending_evaluation_booking varchar2(1):= 'E';
g_cancelled_booking     varchar2(1)     := 'C';
g_requested_booking     varchar2(1)     := 'R';
--
-- Event Statuses
--
g_full_event            varchar2(1)     := 'W';
g_normal_event          varchar2(1)     := 'N';
g_planned_event         varchar2(1)     := 'P';
g_closed_event          varchar2(1)     := 'C';

g_legislation_code            varchar2(150)  default null;
g_booking_id         number         default null;

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
  (
   p_rec in ota_tdb_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_tdb_shd.api_updating
      (p_booking_id                           => p_rec.booking_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

  if nvl(p_rec.business_group_id,hr_api.g_number) <>
     nvl(ota_tdb_shd.g_old_rec.business_group_id,hr_api.g_number)
     then
        l_argument := 'business_group_id';
        raise l_error;
  end if;
/*  if nvl(p_rec.line_id,hr_api.g_number) <>
     nvl(ota_tdb_shd.g_old_rec.Line_id,hr_api.g_number)
     then
        l_argument := 'Line_id';
        raise l_error;
  end if;*/


  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;

--
--added for eBS by dhmulia
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--
--  Prerequisites:
--    The primary key identified by p_booking_id
--     already exists.
--
--  In Arguments:
--    p_booking_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure set_security_group_id
  (p_booking_id                             in number
  ,p_associated_column1                   in varchar2 default null
  )IS
--
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_delegate_bookings tdb
     where tdb.booking_id = p_booking_id
       and pbg.business_group_id = tdb.business_group_id;
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
    ,p_argument           => 'booking_id'
    ,p_argument_value     => p_booking_id
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
        => nvl(p_associated_column1,'BOOKING_ID')
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
END set_security_group_id;
--added for eBS by dhmulia
--
-- Added For Bug 4649610
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_booking_id
--     already exists.
--
--  In Arguments:
--    p_booking_id
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
  (p_booking_id                          in     number
  ) RETURN varchar2
Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
        , ota_delegate_bookings tdb
     where tdb.booking_id = p_booking_id
       and pbg.business_group_id = tdb.business_group_id;
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
    ,p_argument           => 'booking_id'
    ,p_argument_value     => p_booking_id
    );
  --
  if ( nvl(ota_tdb_bus.g_booking_id, hr_api.g_number)
       = p_booking_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_tdb_bus.g_legislation_code;
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
    ota_tdb_bus.g_booking_id                 := p_booking_id;
    ota_tdb_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
-- Added For Bug 4649610

--
-- ----------------------------------------------------------------------------
-- |-------------------------------< get_event>-------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Get Event
--
--              Retrieves the details associated with the event required for
--              subsequent checks in the package and stores the values in
--              the global record g_event_rec
--
Procedure get_event (p_event_id   in number,
                     p_record_use in varchar2 ) is
  --
  l_proc         varchar2(72) := g_package||'get_event';
  l_event_exists boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check that the details have not already been selected
  --
  if p_record_use = 'SAME EVENT' and
     g_event_rec.event_id is not null and
     g_event_rec.event_id = p_event_id then
  --
    Return;
  --
  end if;
  --
  ota_evt_shd.get_event_details (p_event_id,
                                 g_event_rec,
                                 l_event_exists);
  --
  if not l_event_exists then
    --
    fnd_message.set_name ('OTA', 'OTA_13202_GEN_INVALID_KEY');
    fnd_message.set_token ('TABLE_NAME', 'OTA_EVENTS');
    fnd_message.set_token ('COLUMN_NAME', 'EVENT_ID');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End get_event;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< reset_event >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Reset Event
--
--              Ensures that the event record is refreshed by resetting the
--              indicator on the global event record
--
Procedure reset_event is
--
  l_proc        varchar2(72) := g_package||'reset_event';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_event_rec.event_id := '';
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End reset_event;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< booking_status_type >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Booking Status Type
--
--              Retrieves the type of booking status type based on the ID
--
Function booking_status_type (p_booking_status_type_id  in number)
Return varchar2 is
  --
  -- Cursor to retrieve the type of booking status type
  --
  Cursor c_status_type is
    select type
    from ota_booking_status_types
    where booking_status_type_id = p_booking_status_type_id;
  --
--
  l_proc        varchar2(72) := g_package||'booking_status_type';
  l_result      varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_status_type;
  fetch c_status_type into l_result;
  close c_status_type;
  --
  Return (l_result);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End booking_status_type;
--
-- ---------------------------------------------------------------------
-- |-------------------< check_authorizer >-----------------------------
-- ---------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Person
--
--              Checks that a given person is active on a given date
--
procedure check_authorizer (p_person_id in number) is
begin
  if p_person_id is not null then
     if not ota_general.check_fnd_user(p_person_id) then
      fnd_message.set_name ('OTA', 'OTA_13281_TFH_AUTHORIZER');
      fnd_message.raise_error;
     end if;
  end if;
end;
-- ---------------------------------------------------------------------
-- |-------------------< check_person >---------------------------------
-- ---------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Person
--
--              Checks that a given person is active on a given date
--
function check_person (p_person_id            in number,
                       p_date                 in date,
                       p_person_type          in varchar2,
                       p_person_address_type  in varchar2) return boolean is
l_return boolean;
l_proc varchar2(72) := g_package||'check_person';
l_dummy number;
--
-- cursor to perform check for internal delegates
--
cursor c_internal is
select 1
from per_all_people_f
where person_id = p_person_id
and p_date between effective_start_date and effective_end_date;
--
--

-- arkashya: bug 2652833: Replaced the cursor query to be based directly on HZ_ Tables instead of ra_ views.

cursor c_external is
select 1

     from      HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
               HZ_RELATIONSHIPS REL,
               HZ_CUST_ACCOUNTS ROLE_ACCT

     where     ACCT_ROLE.PARTY_ID = REL.PARTY_ID
           AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'
           AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
           AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
           AND ACCT_ROLE.CUST_ACCOUNT_ID = ROLE_ACCT.CUST_ACCOUNT_ID
           AND ROLE_ACCT.PARTY_ID       = REL.OBJECT_ID
           AND ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_person_id;




 --
begin
hr_utility.set_location('Entering:'||l_proc,5);
hr_utility.set_location('Person Type '||p_person_address_type,10);
--
if p_person_type = 'Delegate' then
   if p_person_address_type = 'INTERNAL' then
     open c_internal;
       fetch c_internal into l_dummy;
       l_return := c_internal%found;
     close c_internal;
   elsif p_person_address_type = 'EXTERNAL' then
     open c_external;
       fetch c_external into l_dummy;
       l_return := c_external%found;
     close c_external;
   end if;
--
else
   l_return :=  ota_general.check_person (p_person_id ,p_date);
end if;
--
return l_return;
--
hr_utility.set_location(' Leaving'||l_proc,10);
--
end check_person;
--
--
-- business rules
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_full_name        >-------------------------|
-- ----------------------------------------------------------------------------
function get_full_name (p_last_name in varchar2
                       ,p_title     in varchar2
                       ,p_first_name in varchar2) return varchar2 is
l_full_name per_all_people_f.full_name%TYPE; --Bug  2256328
begin
  if p_last_name is not null then
    l_full_name := p_last_name||',';
    if p_title is not null then
       l_full_name := l_full_name || ' '||p_title;
    end if;
    if p_first_name is not null then
       l_full_name := l_full_name || ' '||p_first_name;
    end if;
  end if;
  return l_full_name;
end;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_full_name >----------------------------|
-- ----------------------------------------------------------------------------
--  version with legislative check
--
function get_full_name
  (p_last_name              in  varchar2
  ,p_title                  in  varchar2
  ,p_first_name             in  varchar2
  ,p_legislation_code       in  varchar2
  ,p_last_name_alt          in  varchar2
  ,p_first_name_alt         in  varchar2
  ) return varchar2
is
  l_full_name per_all_people_f.full_name%TYPE;
begin
  --
  if p_legislation_code = 'JP' then
    --
    -- Create JP specific full name
    --
    if p_last_name_alt is null then
      l_full_name := p_last_name || ' ' || p_first_name;
    else
      l_full_name := p_last_name_alt || ' ' || p_first_name_alt || ' / '
                  || p_last_name || ' ' || p_first_name;
    end if;
  else
    if p_last_name is not null then
      l_full_name := p_last_name||',';
      --
      if p_title is not null then
        l_full_name := l_full_name || ' '||p_title;
      end if;
      if p_first_name is not null then
        l_full_name := l_full_name || ' '||p_first_name;
      end if;
    end if;
  end if;
  return l_full_name;

end get_full_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_full_name >----------------------------|
-- ----------------------------------------------------------------------------
--  version with legislative check
--
function get_full_name
  (p_last_name              in  varchar2
  ,p_title                  in  varchar2
  ,p_first_name             in  varchar2
  ,p_business_group_id      in  number
  ,p_last_name_alt          in  varchar2
  ,p_first_name_alt         in  varchar2
  ) return varchar2
is
  l_full_name   per_all_people_f.full_name%TYPE;
  l_legislation varchar2(30);
  --
  cursor cur_leg is
    select legislation_code
    from   per_business_groups
    where  business_group_id=p_business_group_id;
  --
begin
  --
  -- Retrieve legislation code
  --
  open cur_leg;
  fetch cur_leg into l_legislation;
  close cur_leg;

  l_full_name := get_full_name
    (p_last_name         => p_last_name
    ,p_title             => p_title
    ,p_first_name        => p_first_name
    ,p_legislation_code  => l_legislation
    ,p_last_name_alt     => p_last_name_alt
    ,p_first_name_alt    => p_first_name_alt
    );
  return l_full_name;

end get_full_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< assignment_ok >----------------------------------|
-- ----------------------------------------------------------------------------
-- Returns true if an assignment is valid
--
function assignment_ok (p_person_type         in varchar2,
                        p_assignment_id       in number,
                        p_event_id            in number,
                        p_date_booking_placed in date) return rowid is
  --
  l_dummy varchar2(1);
  l_found boolean := true;
  l_rowid rowid := null;
  l_person_id  number := null;
  l_asg_rowid  rowid := null;
  l_per_rowid  rowid := null;

  --
  CURSOR c_student IS
  SELECT  paf.ROWID
  FROM    per_all_assignments_f paf, ota_events evt
  WHERE    paf.assignment_id = p_assignment_id
  AND      evt.event_id = p_event_id
  AND      (
                  evt.event_status = 'P'
              AND evt.enrolment_start_date BETWEEN paf.effective_start_date
                      AND paf.effective_end_date
            OR (
                    evt.event_type = 'PROGRAMME'
                AND p_date_booking_placed BETWEEN paf.effective_start_date
                        AND paf.effective_end_date)
            OR (
          -- Modified for Bug#3596070
                p_date_booking_placed --evt.course_start_date
          BETWEEN paf.effective_start_date AND paf.effective_end_date) );

/* For Bug 1706107 */
/* Changed the following query to support PTU. Added the table Per_Person_type_Usages_F. */
/* Added the person type 'CWK' and removed 'EMP_APL'  -- Enh No 2530860 */
CURSOR c_student_rehire IS
  SELECT  paf.ROWID
  FROM    per_all_assignments_f paf, ota_events evt ,
          per_all_people_f ppf,
          per_person_type_usages_f ptu,
          per_person_types ppt
  WHERE    paf.person_id = l_person_id
  AND      ppf.person_id = l_person_id
  AND      ptu.person_id = ppf.person_id
  AND      evt.event_id = p_event_id
  AND      (
                  evt.event_status = 'P'
              AND evt.enrolment_start_date BETWEEN paf.effective_start_date
                      AND paf.effective_end_date
            OR (
                    evt.event_type = 'PROGRAMME'
                AND p_date_booking_placed BETWEEN paf.effective_start_date
                        AND paf.effective_end_date)
            OR (
         -- Modified for Bug#3596070
                p_date_booking_placed --evt.course_start_date
      BETWEEN paf.effective_start_date AND paf.effective_end_date) )
  AND      (
                 ( evt.event_status = 'P'
              AND evt.enrolment_start_date BETWEEN ppf.effective_start_date
                      AND ppf.effective_end_date
              AND evt.enrolment_start_date BETWEEN ptu.effective_start_date
                        AND ptu.effective_end_date)
            OR (
                    evt.event_type = 'PROGRAMME'
                AND p_date_booking_placed BETWEEN ppf.effective_start_date
                        AND ppf.effective_end_date
                AND p_date_booking_placed BETWEEN ptu.effective_start_date
                        AND ptu.effective_end_date)
            OR (
        -- Modified for Bug#3596070
                p_date_booking_placed   --evt.course_start_date
           BETWEEN ppf.effective_start_date  AND ppf.effective_end_date
                 AND
          -- Modified for Bug#3596070
                p_date_booking_placed   --evt.course_start_date
              BETWEEN ptu.effective_start_date AND ptu.effective_end_date ) )
  AND   ppt.business_group_id = ppf.business_group_id
  AND ppf.business_group_id = paf.business_group_id
  AND   ptu.person_type_id = ppt.person_type_id
  AND   ppt.system_person_type in ('EMP','CWK','APL') ; -- Added 'APL' for 3885568
/* For Bug 1706107 */


 --
/* For Bug 1514278 */
 CURSOR c_contact IS
  SELECT  paf.ROWID
  FROM    per_all_assignments_f paf
  WHERE    paf.assignment_id = p_assignment_id
  AND      p_date_booking_placed BETWEEN paf.effective_start_date
              AND paf.effective_end_date;

/* For Bug 1706107 */
/* Changed the following query to support PTU. Added the table Per_Person_type_Usages_F. */
/* Added the person type 'CWK' and removed 'EMP_APL' */
CURSOR c_contact_rehire IS
  SELECT  paf.ROWID
  FROM    per_all_assignments_f paf ,
             per_all_people_f ppf,
          per_person_type_usages_f ptu,
          per_person_types ppt
  WHERE    paf.person_id = l_person_id
  AND      ppf.person_id = l_person_id
  AND      ptu.person_id = ppf.person_id
  AND      p_date_booking_placed BETWEEN paf.effective_start_date
              AND paf.effective_end_date
  AND      p_date_booking_placed BETWEEN ppf.effective_start_date
              AND ppf.effective_end_date
  AND   p_date_booking_placed BETWEEN ptu.effective_start_date
                AND ptu.effective_end_date
  AND   ppt.business_group_id = ppf.business_group_id
  AND ppf.business_group_id = paf.business_group_id
  AND   ptu.person_type_id = ppt.person_type_id
  AND   ppt.system_person_type in ('EMP','CWK','APL')    ;  -- Added 'APL' for 3885568



Cursor c_assignment is
select person_id ,rowid
from per_all_assignments_f
where assignment_id = p_assignment_id ;
/* For Bug 1706107 */



--
BEGIN
 --
 IF p_assignment_id IS NULL
    OR p_event_id IS NULL
    OR p_date_booking_placed IS NULL THEN
  RETURN (NULL);
 ELSE
  IF p_person_type = 'STUDENT' THEN
  OPEN c_student;
  FETCH c_student INTO l_rowid;
  CLOSE c_student;
   if l_rowid is null then
      OPEN c_assignment;
      FETCH c_assignment into l_person_id, l_asg_rowid;
      CLOSE c_assignment;
       if l_person_id is not null then
         OPEN c_student_rehire;
         FETCH c_student_rehire INTO l_per_rowid;
           CLOSE c_student_rehire;
      end if;
      if l_per_rowid is not null then
         l_rowid := l_asg_rowid;
      end if;
   end if;

  ELSIF p_person_type = 'CONTACT' THEN
  OPEN c_contact;
  FETCH c_contact INTO l_rowid;
  CLOSE c_contact;
    if l_rowid is null then
      OPEN c_assignment;
      FETCH c_assignment into l_person_id, l_asg_rowid;
      CLOSE c_assignment;
       if l_person_id is not null then
         OPEN c_contact_rehire;
         FETCH c_contact_rehire INTO l_per_rowid;
           CLOSE c_contact_rehire;
      end if;
      if l_per_rowid is not null then
         l_rowid := l_asg_rowid;
      end if;
   end if;


  ELSE
  RETURN (NULL);
  END IF;
  RETURN (l_rowid);
 END IF;
--
EXCEPTION
 WHEN OTHERS THEN
  RETURN (NULL);   --
end assignment_ok;
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_places >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Places
--
--              Checks that if a delegate is specified then the number of
--              places should be one
--
Procedure check_places (p_delegate_person_id  in number,
                        p_number_of_places    in number) is
--
  l_proc        varchar2(72) := g_package||'check_places';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check that if the delegate is specified then the number of places is one
  --
  if p_delegate_person_id is not null and p_number_of_places > 1 then
  --
    fnd_message.set_name ('OTA', 'OTA_13200_TDB_SINGLE_BOOKING');
    fnd_message.raise_error;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_places;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_unique_booking >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Unique Booking
--
--              Checks that the booking being made has not already been made
--
Procedure check_unique_booking (p_customer_id         in number,
                                p_organization_id     in number,
                                p_event_id            in number,
                                p_delegate_person_id  in number,
                                p_delegate_contact_id in number,
                                p_booking_id          in number) is
--
  l_proc        varchar2(72) := g_package||'check_unique_booking';
  l_booking     number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- only perform check if delegate person is specified i.e. the booking is
  -- for a particular delegate
  --
  if p_delegate_person_id is not null then
  --
    --
    -- check if the booking already exists
    --
    l_booking := booking_id_for (p_customer_id,
                                 p_organization_id,
                                 p_event_id,
                                 p_delegate_person_id);
    --
    if l_booking is not null then
    --
       if l_booking <> nvl(p_booking_id, hr_api.g_number) then
       --
         fnd_message.set_name ('OTA','OTA_13582_DOUBLE_BOOKING');
         fnd_message.raise_error;
       --
       end if;
    --
    end if;
  --
  end if;
  --
  if p_delegate_contact_id is not null then
  --
    --
    -- check if the booking already exists
    --
    l_booking := booking_id_for (p_customer_id,
                                 p_organization_id,
                                 p_event_id,
                                 p_delegate_contact_id);
    --
    if l_booking is not null then
    --
       if l_booking <> nvl(p_booking_id, hr_api.g_number) then
       --
         fnd_message.set_name ('OTA','OTA_13582_DOUBLE_BOOKING');
         fnd_message.raise_error;
       --
       end if;
    --
    end if;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_unique_booking;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_failure >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Failure
--
--              Checks that the reason for failure is not specified for a
--              successful delegate
--
Procedure check_failure (p_failure_reason             in varchar2,
                         p_successful_attendance_flag in varchar2) is
--
  l_proc        varchar2(72) := g_package||'check_failure';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_failure_reason is not null and p_successful_attendance_flag = 'Y' then
  --
    fnd_message.set_name ('OTA', 'OTA_13466_TDB_SUCC_FAIL_EXCL');
    fnd_message.raise_error;
    --
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_failure;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_internal_booking >--------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Internal Booking
--
--              Checks that if the internal booking flag is checked that the
--              max number of internal places is not exceeded.
--
Procedure check_internal_booking (p_event_id         in number,
                                  p_number_of_places in number,
                                  p_booking_id       in number) is
  --
  l_proc             varchar2(72) := g_package||'check_internal_booking';
  l_max_internal     number;
  l_number_taken     number;
  --
  -- Check if a maximum for internal students exists.
  --
  cursor   c_max_internal is
    select maximum_internal_attendees
    from   ota_events
    where  event_id = p_event_id;
  --
  -- Only placed or attended places take an internal place
  --
  cursor   c_places_taken is
    select sum(a.number_of_places)
    from   ota_delegate_bookings a,
           ota_booking_status_types b
    where  a.event_id = p_event_id
    and    a.booking_status_type_id = b.booking_status_type_id
    and    b.type in ('P','A','E') --6683076.Added new enrollment status.
    and    a.internal_booking_flag = 'Y'
    and    a.booking_id <> nvl(p_booking_id, hr_api.g_number);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_max_internal;
    --
    fetch c_max_internal into l_max_internal;
    --
  close c_max_internal;
  --
  -- If max internal is null then we can enroll freely without worrying
  -- about limits on the event.
  --
  if l_max_internal is not null then
    --
    -- Check how many places we want to allocate are available as
    -- internal places.
    --
    open c_places_taken;
    --
    fetch c_places_taken into l_number_taken;
    --
    close c_places_taken;

    if l_number_taken is null then
    --
      l_number_taken := 0;
    --
    end if;

    --
    -- Check if number of places available is exceeded by number required
    --
    if p_number_of_places > (l_max_internal - l_number_taken) then
      --
      fnd_message.set_name ('OTA','OTA_13580_MAX_INT_EXCEEDED');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_internal_booking;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_attendance >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Attendance
--
--              Checks that successful attendance is only valid for confirmed
--              bookings
--
Procedure check_attendance (p_successful_attendance_flag  in varchar2,
                            p_booking_status_type_id      in number) is
--
  l_proc        varchar2(72) := g_package||'check_attendance';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_successful_attendance_flag = 'Y' then
  --
    if booking_status_type (p_booking_status_type_id) not in
      (g_attended_booking,g_cancelled_booking)
    then
    --
      fnd_message.set_name ('OTA', 'OTA_13237_TDB_SUCCESS_CONFIRM');
      fnd_message.raise_error;
    --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_attendance;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_status_date_change >----------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Check Status Date Change
--
--              Checks that the status of the booking is not updated prior to
--              an existing status change
--
Procedure check_status_date_change (p_date_status_changed    in date,
                                    p_previous_status_change in date) is
--
  l_proc         varchar2(72) := g_package||'check_status_date_change';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- do not allow update if status has been changed after the session date
  --
  if p_date_status_changed < p_previous_status_change then
  --
    fnd_message.set_name ('OTA', 'OTA_13252_TDB_FUTURE_STATUS');
    fnd_message.raise_error;
    --
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_status_date_change;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< add_current_time >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Add Current Time
--
--              Adds the current time on to a date value if it does not
--              have a time component
--
Function add_current_time (p_date  in date) return date is
--
  l_proc        varchar2(72) := g_package||'add_current_time';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  if to_char(p_date,'HH24:MI:SS') = '00:00:00' then
  --
    return to_date(to_char(p_date,'DD-MON-YYYY')||' '||
                           to_char(sysdate, 'HH24:MI:SS'),
                   'DD-MON-YYYY HH24:MI:SS');
  --
  else
  --
    return p_date;
  --
  end if;
  --
End add_current_time;
--
-- ----------------------------------------------------------------------------
-- |---------------------< maintain_status_history >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
-- Description: Maintain Status History
--
--              Maintains a history of status changes for the booking when the
--              booking status type is updated
--
Procedure maintain_status_history (p_booking_status_type_id  in number,
                                   p_date_status_changed     in date,
                                   p_administrator           in number,
                                   p_status_change_comments  in varchar2,
                                   p_booking_id              in number,
                                   p_previous_status_change  in date,
                                   p_previous_status_type_id in number,
                                   p_created_by              in number,
                                   p_date_booking_placed     in date) is
--
  l_proc        varchar2(72) := g_package||'maintain_status_history';
  l_date_changed date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- add the time component on to the changed date
  --
  l_date_changed := add_current_time (p_date_status_changed);
  --
  -- check that the status has not already been updated in a future session
  --
  check_status_date_change (l_date_changed,
                            p_previous_status_change);
  --
  -- create an initial record in the status histories for the first booking
  -- if this is the first change in status
  --
  if p_previous_status_change is null then
  --
    insert into ota_booking_status_histories
                  (booking_id,
                   booking_status_type_id,
                   start_date,
                   changed_by,
                   comments,
                   object_version_number)
           values (p_booking_id,
                   p_previous_status_type_id,
                   p_date_booking_placed,
                   p_created_by,
                   'Enrolled',
                   1);
  --
  end if;
  --
  -- create a record in the status histories for this booking
  --
  insert into ota_booking_status_histories
                (booking_id,
                 booking_status_type_id,
                 start_date,
                 changed_by,
                 comments,
                 object_version_number)
         values
                (p_booking_id,
                 p_booking_status_type_id,
                 l_date_changed,
                 p_administrator,
                 p_status_change_comments,
                 1);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End maintain_status_history;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_resources >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check resources
--
--              Checks if any resources exists for the booking
--
Procedure check_resources (p_booking_id  in number) is
--
  -- cursor to check if resources exist for the booking
  --
  Cursor c_details is
    select 'X'
    from ota_resource_allocations
    where booking_id = p_booking_id;
  --
  l_proc        varchar2(72) := g_package||'check_resources';
  l_dummy       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_details;
  fetch c_details into l_dummy;
  if c_details%found then
  --
    close c_details;
  -- bug 4499950
    fnd_message.set_name ('OTA', 'OTA_443818_NO_DEL_HAS_CHILD');
    fnd_message.raise_error;
    --
  --
  end if;
  --
  close c_details;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_resources;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_finance_line >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check finance_line
--
--              Checks if any finance lines exists for the booking which
--
Procedure check_finance_lines (p_booking_id  in number) is
--
cursor  c_check_finance_line is
select  nvl(sum(booking_id),0)
from    ota_finance_lines tfl
where   tfl.booking_id = p_booking_id;
--
l_finance_line_exists number;
--
l_proc  varchar2(72) := g_package||'check_finance_lines';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check if finance line exists.
  --
  open c_check_finance_line;
  fetch c_check_finance_line into l_finance_line_exists;
  close c_check_finance_line;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
  if l_finance_line_exists <> 0 then
    --
    fnd_message.set_name ('OTA', 'OTA_13609_TDB_CHK_TFL');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End check_finance_lines;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------<  check_training_plan_costs>------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check training plan costs
--
--              Checks if booking id is referenced in ota_training_plan_costs
--
Procedure check_training_plan_costs(p_booking_id in number) is
  --
  l_proc        varchar2(72) := g_package||'check_training_plan_costs';
  v_exists      varchar2(5)  := 'N';
  --
  -- sql statment to check if the booking is referenced in training plan costs
  --
  Cursor Csr_chk_tpc_rows(p_booking_id Number) IS
    select 'Y'
    from OTA_TRAINING_PLAN_COSTS
    where booking_id = p_booking_id;
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check if booking is referenced in training plan costs
  open Csr_chk_tpc_rows(p_booking_id);
  fetch Csr_chk_tpc_rows into v_exists;
  close Csr_chk_tpc_rows;
     --
  if v_exists = 'Y' then
    fnd_message.set_name ('OTA', 'OTA_13822_TBD_NO_DEL_TPC_EXIST');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:' || l_proc, 10);
  --
End check_training_plan_costs;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_type_business_group >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Type Business Group
--
--              Checks that the business group of the booking is the same as
--              that of the booking status type being used
--
Procedure check_type_business_group (p_business_group_id      in number,
                                     p_booking_status_type_id in number) is
--
  --
  -- cursor to check that the event is in the same business group
  --
  Cursor c_same_business_group is
    select 'X'
    from ota_booking_status_types
    where booking_status_type_id = p_booking_status_type_id
      and business_group_id = p_business_group_id;
  --
  l_proc        varchar2(72) := g_package||'check_type_business_group';
  l_dummy       varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_same_business_group;
  fetch c_same_business_group into l_dummy;
  if c_same_business_group%notfound then
  --
    fnd_message.set_name ('OTA', 'OTA_13592_BUS_GROUP_DEL_BST');
    fnd_message.raise_error;
    --
  --
  end if;
  --
  close c_same_business_group;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_type_business_group;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< get_event_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Get Event Type
--
--              Returns the event_type of the booking
--
Function get_event_type (p_event_id in number) return varchar2 is
  --
  l_proc        varchar2(72) := g_package||'get_event_type';
  l_dummy       varchar2(30);
  --
  cursor c1 is
    select event_type
    from ota_events
    where event_id = p_event_id;
  --
Begin
  open c1;
    --
    fetch c1 into l_dummy;
    --
  close c1;
  return l_dummy;
End get_event_type;


-- ---------------------------------------------------------------------------
-- |----------------------< check_event_business_group >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Event Business Group
--
--              Checks that the business group of the booking is the same as
--              that of the event being booked
--
Procedure check_event_business_group
             (p_business_group_id  in number,
              p_event_id           in number,
              p_event_record_use   in varchar2 ) is
--
  l_proc        varchar2(72) := g_package||'check_event_business_group';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- retrieve event details if not already obtained
  --
  get_event (p_event_id, p_event_record_use);
  --
  if g_event_rec.business_group_id <> p_business_group_id then
  --
    fnd_message.set_name ('OTA', 'OTA_13591_BUS_GROUP_DEL_EVT');
    fnd_message.raise_error;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_event_business_group;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< booking_id_for >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Booking ID For
--
--              Returns the Booking Id for a given Organization-Event-Delegate
--              combination
--
Function booking_id_for (p_customer_id        in number,
                         p_organization_id    in number,
                         p_event_id           in number,
                         p_person_id          in number) Return number is

  l_proc        varchar2(72) := g_package||'booking_id';
  l_result      number := null;
  l_type    varchar2(4) := null;
  l_flag    varchar2(1) :='F';
--
  -- cursor to select the booking ID
  --
  Cursor c_booking_customer is
    select booking_id
    from   ota_delegate_bookings
    where  event_id = p_event_id
    and    delegate_contact_id = p_person_id;
  --
  Cursor c_booking_organization is
    select booking_id
    from   ota_delegate_bookings
    where  event_id = p_event_id
    and    delegate_person_id = p_person_id;

/** Created for Bug 1576558 **/
  cursor c_booking_customer_cancelled is
    select bst.type
    from   ota_delegate_bookings tdb,
           ota_booking_status_types bst
    where tdb.booking_id = l_result
    and   bst.booking_status_type_id = tdb.booking_status_type_id;
/** End Created for Bug 1576558 **/

/** Created for Bug 1823617 **/
  cursor c_booking_internal_cancelled is
    select bst.type
    from   ota_delegate_bookings tdb,
           ota_booking_status_types bst
    where tdb.booking_id = l_result
    and   bst.booking_status_type_id = tdb.booking_status_type_id;
/** End Created for Bug 1823617 **/


  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_customer_id is not null then
    --
    -- Check external enrollments
    --
    open c_booking_customer;
      --
    loop
      fetch c_booking_customer into l_result;
      exit when c_booking_customer%notfound;
    --  if l_result is not null then

 /** Created for Bug 1576558 **/

         open c_booking_customer_cancelled;
         fetch c_booking_customer_cancelled into l_type;
         if l_type = 'C' then
            null;
         else
            l_flag := 'T';
            exit;       -- bug no 3008523
         end if;
         close c_booking_customer_cancelled ;
    --  end if;
      --
/** Created for Bug 1576558 **/

    end loop;
    close c_booking_customer;
/** Created for Bug 1576558 **/

    if l_flag = 'F' then
       l_result := null;
    end if;
/** Created for Bug 1576558 **/

    --
  else
    --
    -- Check internal enrollments
    --
    --open c_booking_organization;
      --
    For r_student in c_booking_organization
    loop
       l_result := r_student.booking_id;
     -- fetch c_booking_organization into l_result;
     --  exit when c_booking_organization%notfound;
      --
         /** Created for Bug 1823617 **/

         open c_booking_internal_cancelled;
         fetch c_booking_internal_cancelled into l_type;
         if l_type = 'C' then
            null;
         else
            l_flag := 'T';
            exit;     -- bug no 3008523
         end if;
         close c_booking_internal_cancelled ;
    --  end if;
      --
/** Created for Bug 1823617 **/

    end loop;

  --  close c_booking_organization;

    /** Created for Bug 1823617 **/

    if l_flag = 'F' then
       l_result := null;
    end if;
/** Created for Bug 1823617 **/

    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  Return (l_result);
  --
End booking_id_for;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Finance Line Exists >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Checks whether a finance line exists for a particular booking_Id.
--
--
Function Finance_Line_Exists (p_booking_id in number
                             ,p_cancelled_flag in varchar2) return boolean is
--
cursor  c_check_finance_line is
select  nvl(sum(booking_id),0)
from    ota_finance_lines tfl
where   tfl.booking_id = p_booking_id
and     tfl.cancelled_flag = p_cancelled_flag;
l_finance_line_exists number;
--
  l_proc        varchar2(72) := g_package||'finance_line_exists';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Check if finance line exists.
  --
  open c_check_finance_line;
  fetch c_check_finance_line into l_finance_line_exists;
  close c_check_finance_line;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
  if l_finance_line_exists = 0 then
    return (false);
  else
    return (true);
  end if;
  --
end Finance_Line_Exists;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< internal_booking >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Internal Booking
--
--              Checks if the booking is internal then the person (Contact or
--              Delegate) is also internal
--
Function internal_booking (p_internal_booking_flag  in varchar2,
                           p_person_id              in number,
                           p_date_booking_placed    in date)
Return boolean is
--
  l_proc        varchar2(72) := g_package||'internal_booking';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- if the booking is internal
  --
  if p_person_id is not null and p_internal_booking_flag = 'Y' then
  --
    -- the person must be a current employee on the date the booking is made
    --
    Return (ota_general.check_current_employee (p_person_id,
                                               p_date_booking_placed));
  else
  --
    Return (True);
  --
  end if;
  --
End internal_booking;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_booking_status_type >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Booking Status Type
--
--              Chrecks that the booking status type is valid
--
Procedure check_booking_status_type (p_booking_status_type_id  in number,
                                     p_event_id number) is   -- bug 3677661
--
  l_proc        varchar2(72) := g_package||'check_booking_status_type';
  l_status      ota_booking_status_types.name%type;         -- bug 3677661
  l_validate_event NUMBER; -- bug 3677661
--
 CURSOR csr_course_not_in_future  -- bug 3677661
  IS
  SELECT 1
  FROM ota_events e
  WHERE
    -- Added for bug#5169098
    ota_timezone_util.convert_date(trunc(sysdate), to_char(sysdate,'HH24:MI'), ota_timezone_util.get_server_timezone_code, e.timezone)
      >= ota_timezone_util.convert_date(nvl(e.course_start_date,to_date('0001/01/01','YYYY/MM/DD')), course_start_time, e.timezone, e.timezone)
   --(sysdate >= nvl( e.course_start_date, sysdate))
    AND e.event_id = p_event_id;

--

 CURSOR csr_booking_sts             --- bug 3677661
   IS
  SELECT name
  FROM ota_booking_status_types bst
  WHERE bst.booking_status_type_id = p_booking_status_type_id
  AND bst.type in ('A','E');		--- bug 9009925

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if booking_status_type (p_booking_status_type_id) is null then
  --
    fnd_message.set_name ('OTA','OTA_13623_TDB_NO_STATUS');
    fnd_message.raise_error;
    --
  else
     /* bug 3677661 */

    open csr_course_not_in_future ;
    fetch csr_course_not_in_future  into l_validate_event;
    close csr_course_not_in_future ;
    --
    if l_validate_event is null then
   open csr_booking_sts;
   fetch csr_booking_sts into l_status;
   close csr_booking_sts;
     --
   if l_status is not null then
       fnd_message.set_name('OTA','OTA_443469_TDB_ATTENDED_STATUS');
            fnd_message.set_token('STATUS', l_status);
             fnd_message.raise_error;

   end if;
    end if;
   /* bug 3677661 */
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_booking_status_type;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_delegate_eligible >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Delegate Eligible
--
--              If the event is not public, only delegates from organizations
--              which have an association with the event are eligible
--
Procedure check_delegate_eligible (p_event_id               in number,
                                   p_customer_id            in number,
               p_delegate_contact_id    in number,
                                   p_organization_id        in number,
                                   p_delegate_person_id     in number,
                                   p_delegate_assignment_id in number) is
  --
  l_proc            varchar2(72) := g_package||'check_delegate_eligible';
  l_price_basis     ota_events.price_basis%type;
  l_start_date      ota_events.course_start_date%type;
  l_dummy           varchar2(1);
  l_organization_id number;
  l_job_id          number;
  l_position_id     number;
  l_count           number;
  l_found           boolean := false;
  /* bug 3463908 */
  l_party_id        number := null;
  l_public_event_flag	OTA_EVENTS.public_event_flag%TYPE;
  l_max_internal	OTA_EVENTS.maximum_internal_attendees%TYPE;
  l_event_start_date	OTA_EVENTS.course_start_date%TYPE;
  l_parent_offering_id	OTA_EVENTS.parent_offering_id%TYPE;
--  l_employee_can_enroll VArchar2(9);
  /* bug 3463908 */
  l_learner_can_enroll Varchar2(9); -- bug no 4201444
  --
  Cursor c_associations_exist is
    select count(event_association_id)
    from ota_event_associations
    where event_id = p_event_id;
  --
  /* bug 3463908 */
  /*Cursor c_event_start_date is
    select course_start_date
    from   ota_events
    where  event_id = p_event_id;
    */
  --
  Cursor c_not_public_course is
    select 'X'
    from ota_events b
    where b.event_id = p_event_id
    and public_event_flag = 'N';
  --
  Cursor c_event_association (l_party_id in number) is
    select 'X'
    from   ota_event_associations
    where  (event_id = p_event_id
    and    ((p_customer_id is not null and customer_id = p_customer_id)
            or (l_party_id is not null and party_id =l_party_id)));  /* bug 3463908 */

/*    bug 4887325
    or not exists (select null
                   from   ota_event_associations evt
                   where  evt.event_id = p_event_id);*/
  --
 /* bug 3463908 */
 /* cursor c_assignment_details is
    select organization_id, job_id, position_id
    from   per_assignments_f
    where  assignment_id = p_delegate_assignment_id
    and    NVL(l_start_date,TRUNC(sysdate))
           between effective_start_date
           and effective_end_date;
  --
  */ /* 3632386 */ /*
  cursor c_organization_association (l_organization_id number,
                                     l_job_id          number,
                                     l_position_id     number) is
    select 'Y'
    from   ota_event_associations
    where  (event_id = p_event_id
    and     nvl(organization_id,-1) = decode(organization_id,null,-1,nvl(l_organization_id,-1))
    and     nvl(position_id,-1) = decode(position_id,null,-1,nvl(l_position_id,-1))
    and     nvl(job_id,-1) = decode(job_id,null,-1,nvl(l_job_id,-1)))
    or not exists (select null
                   from   ota_event_associations evt
                   where  evt.event_id = p_event_id);
  --
  Cursor c_event_price_basis is
    select price_basis
    from ota_events
    where event_id = p_event_id;
    */
  --
  /* bug 3463908 */
  Cursor c_party is
  SELECT party.party_id
  FROM  HZ_CUST_ACCOUNT_ROLES acct_role,
        HZ_PARTIES party,
        HZ_RELATIONSHIPS rel,
        HZ_ORG_CONTACTS org_cont,
        HZ_PARTIES rel_party,
        HZ_CUST_ACCOUNTS role_acct
  WHERE acct_role.party_id = rel.party_id
        AND acct_role.role_type = 'CONTACT'
        AND org_cont.party_relationship_id = rel.relationship_id
        AND rel.subject_id = party.party_id
        AND rel.party_id = rel_party.party_id
        AND rel.subject_table_name = 'HZ_PARTIES'
        AND rel.object_table_name = 'HZ_PARTIES'
        AND acct_role.cust_account_id = role_acct.cust_account_id
        AND role_acct.party_id	= rel.object_id
        AND ACCT_ROLE.cust_account_role_id = p_delegate_contact_id;
	/* bug 3463908 */
--Bug No. 4201444
   Cursor event_details is
   Select public_event_flag, maximum_internal_attendees, course_start_date, parent_offering_id
   From ota_events
   Where event_id = p_event_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check if the course is not public
  --
  open c_not_public_course;
  fetch c_not_public_course into l_dummy;
  if c_not_public_course%found then
    l_found := true;
  end if;
  close c_not_public_course;

  --
  -- See if any restictions exist in the database.
  --
  open c_associations_exist;
  fetch c_associations_exist into l_count;
  close c_associations_exist;

  if nvl(l_count, 0) = 0 then
    l_found := false;
  end if;

  --/* bug 3463908 */
  if p_delegate_contact_id is not null then
   Open c_party;
   Fetch c_party into l_party_id;
   Close c_party;
  end if;
    /* bug 3463908 */
  --
  -- check that the organization or customer has an association with the event
  --
  if l_found then
    --
    if p_customer_id is not null or p_delegate_contact_id is not null then  /* bug 3463908 */
      --
      -- Check customer has an event association with this event
      --
   /* bug no 4201444 */
      if p_delegate_contact_id is not null then
        open event_details;
        fetch event_details into l_public_event_flag, l_max_internal, l_event_start_date, l_parent_offering_id;
        l_learner_can_enroll :=   ota_learner_access_util.learner_can_enroll
              (p_person_id => null,
                p_party_id => l_party_id,
                p_event_id => p_event_id,
                p_public_event_flag => l_public_event_flag ,
                p_max_internal => l_max_internal ,
                p_event_start_date => l_event_start_date ,
                p_parent_offering_id => l_parent_offering_id);
        close event_details;

        if l_learner_can_enroll = 'N' then
            fnd_message.set_name ('OTA','OTA_13239_TDB_NO_EVENT_ASSOC');
            fnd_message.raise_error;
        end if;
      else
   /* Bug No. 4201444 */
      open c_event_association(l_party_id);  /* bug 3463908 */
        --
        fetch c_event_association into l_dummy;
        if c_event_association%notfound then
        --
          close c_event_association;
          --
          fnd_message.set_name ('OTA','OTA_13239_TDB_NO_EVENT_ASSOC');
          fnd_message.raise_error;
          --
        end if;
        --
      close c_event_association;
      --
      /* bug no 3460968 */
      end if; --Bug no 4201444

      -- Bug#4354377
      -- learner access util need not be checked if enrollment is not created
      -- for a specific internal learner
    elsif p_delegate_person_id IS NOT NULL THEN
      open event_details;
      fetch event_details into l_public_event_flag, l_max_internal, l_event_start_date, l_parent_offering_id;

      /*
       Select public_event_flag,  maximum_internal_attendees, course_start_date, parent_offering_id
		into  l_public_event_flag, l_max_internal, l_event_start_date, l_parent_offering_id
       From ota_events
       Where event_id = p_event_id;
     */
	l_learner_can_enroll := ota_learner_access_util.employee_can_enroll(p_person_id => p_delegate_person_id,
            p_event_id => p_event_id,
            p_public_event_flag => l_public_event_flag ,
                 p_max_internal => l_max_internal ,
            p_event_start_date => l_event_start_date ,
            p_parent_offering_id => l_parent_offering_id);
	if l_learner_can_enroll = 'N' then
      fnd_message.set_name ('OTA','OTA_13524_DELEGATE_ASSOCIATION');
      fnd_message.raise_error;
   end if;
    end if;
          /* bug no 3460968 */
    --
    /* bug no 3460968
    if p_organization_id is not null then
      --
      -- Check that job, position, organizaton matches criteria for association
      -- of event
      --
      if p_delegate_person_id is not null then
        --
        open c_event_start_date;
          --
          fetch c_event_start_date into l_start_date;
          --
        close c_event_start_date;
        --
        --
        -- Check to see a valid organization association exists
        --
        --
        l_found := false;
        --
        open c_assignment_details;
          --
          loop
            --
            fetch c_assignment_details into l_organization_id, l_job_id, l_position_id;
            exit when c_assignment_details%notfound or l_found;
            --
            -- Pass values to cursor
            --
            open c_organization_association(l_organization_id,l_job_id,l_position_id);
              --
              fetch c_organization_association into l_dummy;
              --
              if c_organization_association%found then
                --
                l_found := true;
                --
              end if;
              --
            close c_organization_association;
            --
          end loop;
          --
        close c_assignment_details;
        --
        if not l_found then
          --
          -- Display error message
          --
          fnd_message.set_name ('OTA','OTA_13524_DELEGATE_ASSOCIATION');
          fnd_message.raise_error;
          --
        end if;
        --
      end if;
    end if;
   Bug no 3460968 */

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_delegate_eligible;
--
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< places_for_status >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Places for status
--
--              Returns the number of places on an event at either a given
--              status type or a given status type ID
--              for either ALL delegates or only INTERNAL delegates not
--              counting the given booking
--
Function places_for_status (p_event_id               in number,
                            p_all_or_internal        in varchar2,
                            p_booking_status_type_id in number,
                            p_status_type            in varchar2 ,
                            p_usage_type             in varchar2 ,
                            p_booking_id             in number)
Return number is
--
  --
  -- cursor to count the number of confirmed bookings for the event to date
  --
  Cursor c_number_of_bookings is
    select nvl(sum(db.number_of_places),0)
    from ota_delegate_bookings    db,
         ota_booking_status_types bst
    where bst.booking_status_type_id = nvl(p_booking_status_type_id,
                                          bst.booking_status_type_id)
      and bst.type = nvl(p_status_type, bst.type)
      and (p_usage_type is null or
           ota_tdb_bus.event_place_needed(bst.booking_status_type_id) = 1)
      and bst.booking_status_type_id = db.booking_status_type_id
      and (p_booking_id is null or
           p_booking_id is not null and db.booking_id <> p_booking_id)
      and db.internal_booking_flag = decode(p_all_or_internal,
                                            'INTERNAL','Y',
                                            db.internal_booking_flag)
      and db.event_id = p_event_id;
  --
  --
  l_max_bookings       number;
  l_number_of_bookings number;
--  l_proc             varchar2(72) := g_package||'places_for_status';
--
Begin
--  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- get the number of confirmed bookings for the event
  --
  open c_number_of_bookings;
  fetch c_number_of_bookings into l_number_of_bookings;
  close c_number_of_bookings;
  --
  Return (l_number_of_bookings);
  --
End places_for_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< places_allowed >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Places allowed
--
--              Returns the number of places allowed on an event for either
--              ALL delegates or only INTERNAL delegates
--
Function places_allowed (p_event_id        in number,
                         p_all_or_internal in varchar2) Return number is
--
  l_proc               varchar2(72) := g_package||'places_allowed';
--
Begin
  --
  -- retrieve event details if not already obtained
  --
  get_event (p_event_id, 'NEW EVENT');
  --
  -- get the maximum number allowed for the event
  --
  if p_all_or_internal = 'ALL' then
  --
    Return (g_event_rec.maximum_attendees);
  --
  else
  --
    Return g_event_rec.maximum_internal_attendees;
  --
  end if;
  --
End places_allowed;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_programme_member >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Programme Member
--
--              Checks that a booking made for a programme member has another
--              existing booking for the programme
--
Procedure check_programme_member
             (p_event_id            in number,
              p_customer_id         in number,
              p_organization_id     in number,
              p_delegate_person_id  in number,
              p_delegate_contact_id in number,
              p_event_record_use    in varchar2 ,
              p_booking_id          in number   ) is
  --
  -- cursor to check the existence of a booking to the parent event
  --
  cursor c_customer_parent_booking is
    select 'X'
    from   ota_delegate_bookings
    where  customer_id = p_customer_id
    and    event_id in (select a.program_event_id
                        from   ota_program_memberships a
                        where  a.event_id = p_event_id)
    and    (
            (p_booking_id is not null and booking_id <> p_booking_id
             )
            or
             p_booking_id is null
           )
    and    (delegate_contact_id = p_delegate_contact_id
            or
            (delegate_contact_id is null and p_delegate_contact_id is null
            )
           );
  --
  cursor c_organization_parent_booking is
    select 'X'
    from   ota_delegate_bookings
    where  event_id in (select a.program_event_id
                        from   ota_program_memberships a
                        where  a.event_id = p_event_id)
    and    (
            (p_booking_id is not null and booking_id <> p_booking_id
             )
            or
             p_booking_id is null
           )
    and    (delegate_person_id = p_delegate_person_id
            or
            (delegate_person_id is null and p_delegate_person_id is null
            )
           );
  --
  -- Check if event is part of a program
  --
  cursor c_part_of_program is
    select null
    from   ota_program_memberships a
    where  a.event_id = p_event_id;
  --
  l_proc        varchar2(72) := g_package||'check_programme_member';
  l_dummy       varchar2(1);
  l_found       boolean := false;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- retrieve event details if not already obtained
  --
  get_event (p_event_id, p_event_record_use);
  --
  -- check only required if the event is a Programme member
  --
  hr_utility.set_location(g_event_rec.parent_event_id,5);
  --
  open c_part_of_program;
    --
    fetch c_part_of_program into l_dummy;
    if c_part_of_program%found then
      --
      l_found := true;
      --
    end if;
    --
  close c_part_of_program;
  --
  -- Check delegate is enrolled on parent event
  --
  hr_utility.set_location('Customer ID '||p_customer_id,10);
  hr_utility.set_location('Event ID '||p_event_id,10);
  --
  if l_found then
    --
    if p_customer_id is not null then
      --
      open c_customer_parent_booking;
        --
        fetch c_customer_parent_booking into l_dummy;
        --
        if c_customer_parent_booking%notfound then
          --
          close c_customer_parent_booking;
          --
          fnd_message.set_name ('OTA','OTA_13581_TDB_NO_PROGRAMME');
          fnd_message.raise_error;
          --
        end if;
        --
      close c_customer_parent_booking;
      --
    else
      --
      open c_organization_parent_booking;
        --
        fetch c_organization_parent_booking into l_dummy;
        --
        if c_organization_parent_booking%notfound then
          --
          close c_organization_parent_booking;
          --
          fnd_message.set_name ('OTA','OTA_13581_TDB_NO_PROGRAMME');
          fnd_message.raise_error;
          --
        end if;
        --
      close c_organization_parent_booking;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End check_programme_member;
-- ----------------------------------------------------------------------------
-- |--------------------------< event_place_needed >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Event Place Needed
--
--              Checks whether a place on an event is needed, in other words
--              is it a placed or attended enrollment status
--
Function event_place_needed(p_booking_status_type_id in number) return number is
  --
  l_type     varchar2(30);
  l_proc     varchar2(72) := g_package||'check_max_allowance';
  --
  cursor c_event is
    select type
    from   ota_booking_status_types
    where  booking_status_type_id = p_booking_status_type_id;
  --
begin
  open c_event;
    --
    fetch c_event into l_type;
    --
  close c_event;
  --
  -- Return true if enrollment requires an enrollment place
  --
  if l_type in (g_attended_booking,g_placed_booking,g_pending_evaluation_booking) then
    --
    return 1;
    --
  else
    --
    return 0;
    --
  end if;
  --
end event_place_needed;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_max_allowance >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Maximum Allowance
--
--              Checks if after the booking, the number for the event exceeds
--              or has reached the maximum allowed for the event
--
Procedure check_max_allowance
             (p_event_id               in number,
              p_booking_status_type_id in number,
              p_number_of_places       in number,
              p_internal_booking_flag  in varchar2,
              p_max_reached            out nocopy boolean,
              p_max_exceeded           out nocopy boolean,
              p_all_or_internal        in varchar2  ,
              p_booking_id             in number    ) is
--
  l_proc             varchar2(72) := g_package||'check_max_allowance';
  l_places_used      number;
  l_places_allowed   number;
  l_extra_places     number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check that the booking being made is of confirmed status
  --
  if p_event_id is not null
    and ota_tdb_bus.event_place_needed(p_booking_status_type_id) = 1 then
    --
    -- retrieve the places confirmed and places allowed for the event
    --
    l_places_used      := places_for_status
                          (p_event_id => p_event_id,
                           p_all_or_internal => p_all_or_internal,
                           p_usage_type => 'PLACE_USED',
                           p_booking_id => p_booking_id);
    --
    l_places_allowed   := places_allowed (p_event_id, p_all_or_internal);
    --
    --
    -- obtain the number of extra places the current booking will generate to
    -- be included for the purposes of the check
    --
    if p_all_or_internal = 'ALL' then
    --
      -- all places being booked are included
      --
      l_extra_places := p_number_of_places;
      --
    else
    --
      -- check for internal bookings only
      --
      if p_internal_booking_flag = 'Y' then
      --
        -- internal bookings are included for the internal check
        --
        l_extra_places := p_number_of_places;
      --
      else
        -- not internal and are therefore not included in the check
        --
        l_extra_places := 0;
      --
      end if;
    --
    end if;
    --
    -- check if the number of bookings uses up all the remaining places
    --
    p_max_reached :=  (l_places_used + l_extra_places =
                       l_places_allowed);
    --
    -- check that the number of bookings does not exceed the maximum
    --
    p_max_exceeded := (l_places_used + l_extra_places >
                       l_places_allowed);
    --
  else
  --
    p_max_reached  := false;
    p_max_exceeded := false;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_max_allowance;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< enrolling >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:  Enrolling
--
--               Checks if the given event is enrolling
--
Function enrolling (p_event_id            in number,
                    p_event_record_use    in varchar2 )
return BOOLEAN is
--
  l_proc                 varchar2(72) := g_package||'enrolling';
  l_parent_enrollment_sd date;

  cursor c_get_parent is
  select enrolment_start_date
  from ota_events
  where event_id = nvl(g_event_rec.parent_event_id, -1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- retrieve event details if not already obtained
  --
  get_event (p_event_id, p_event_record_use);
  --
  hr_utility.trace(g_event_rec.event_type);
  hr_utility.trace(g_event_rec.course_start_date);
  hr_utility.trace(g_event_rec.enrolment_start_date);
  hr_utility.set_location('Leaving:'||l_proc,5);
  --
  if g_event_rec.event_type in ('AD HOC','DEVELOPMENT') then
    Return (g_event_rec.course_start_date is not null);
  elsif g_event_rec.event_type in ('SESSION') then
  --
    open c_get_parent;
    fetch c_get_parent into l_parent_enrollment_sd;
    close c_get_parent;
    return (l_parent_enrollment_sd is not null);
  --
  else
    Return (g_event_rec.enrolment_start_date is not null);
  end if;
--
End enrolling;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< enrolling_on_date >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:  Enrolling On Date
--
--               Checks if the given event is enrolling on the given date
--
Function enrolling_on_date
                   (p_event_id            in number,
                    p_date                in date,
                    p_event_record_use    in varchar2 )
return BOOLEAN is
--
  l_proc          varchar2(72) := g_package||'enrolling_on_date';
  l_enrollment_sd date;
  l_enrollment_ed date;
  l_timezone ota_events.timezone%TYPE;
  l_conv_booking_date date := p_date;

  cursor c_get_parent is
  select enrolment_start_date,
         enrolment_end_date,
	 timezone
  from ota_events
  where event_id = nvl(g_event_rec.parent_event_id, -1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- retrieve event details if not already obtained
  --
  get_event (p_event_id, p_event_record_use);
  --
  if g_event_rec.event_type = 'SESSION' then
  --
    open c_get_parent;
    fetch c_get_parent into l_enrollment_sd,
                            l_enrollment_ed,
			    l_timezone;
    close c_get_parent;
  --
  else
  --
    l_enrollment_sd := g_event_rec.enrolment_start_date;
    l_enrollment_ed := g_event_rec.enrolment_end_date;
    l_timezone      := g_event_rec.timezone;
  --
  end if;

  IF g_event_rec.event_type IN ('SCHEDULED', 'SELFPACED') THEN

     l_enrollment_sd := to_date( to_char(l_enrollment_sd,'YYYY/MM/DD')
                                || ' ' || '00:00', 'YYYY/MM/DD HH24:MI');
     l_enrollment_ed := to_date( nvl(to_char(l_enrollment_ed,'YYYY/MM/DD'),'4712/12/31')
                                || ' ' || '23:59', 'YYYY/MM/DD HH24:MI');

     l_conv_booking_date := ota_timezone_util.convert_date(trunc(p_date)
                                                         , to_char(p_date,'HH24:MI')
					                 , ota_timezone_util.get_server_timezone_code
					                 , l_timezone);
  END IF;

  Return (l_conv_booking_date between l_enrollment_sd
                 and nvl(l_enrollment_ed, to_date ('31/12/4712','DD/MM/YYYY')));
--
End enrolling_on_date;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_enrollment_dates >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:  Check whether learner can be enrolled on given date
--
--               Checks if the given event is enrolling on the given date
--
Function check_enrollment_dates
                   (p_event_id            in number,
                    p_date                in date,
		    p_throw_error IN VARCHAR2 DEFAULT 'Y')
return VARCHAR2 is
--
  l_proc          varchar2(72) := g_package||'check_enrollment_dates';
  l_enrollment_sd date;
  l_enrollment_ed date;
  l_timezone ota_events.timezone%TYPE;
  l_event_type ota_events.event_type%TYPE;
  l_conv_booking_date date := p_date;

  cursor c_get_parent is
  select enrolment_start_date,
         enrolment_end_date,
	 timezone,
	 event_type
  from ota_events
  where event_id = p_event_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  open c_get_parent;
  fetch c_get_parent into l_enrollment_sd,
                          l_enrollment_ed,
    	                  l_timezone,
			  l_event_type;
  close c_get_parent;

  IF l_event_type IN ('SCHEDULED', 'SELFPACED') THEN

     l_enrollment_sd := to_date( to_char(l_enrollment_sd,'YYYY/MM/DD')
                                || ' ' || '00:00', 'YYYY/MM/DD HH24:MI');
     l_enrollment_ed := to_date( nvl(to_char(l_enrollment_ed,'YYYY/MM/DD'),'4712/12/31')
                                || ' ' || '23:59', 'YYYY/MM/DD HH24:MI');

     l_conv_booking_date := ota_timezone_util.convert_date(trunc(p_date)
                                                         , to_char(p_date,'HH24:MI')
					                 , ota_timezone_util.get_server_timezone_code
					                 , l_timezone);
  ELSE
     RETURN 'N';
  END IF;

  IF (l_conv_booking_date between l_enrollment_sd
                 and nvl(l_enrollment_ed, to_date ('31/12/4712','DD/MM/YYYY'))) THEN
     RETURN 'N';
  ELSE
     IF p_throw_error = 'Y' THEN
       fnd_message.set_name ('OTA', 'OTA_13599_EVT_VALID_BOOKINGS');
       fnd_message.raise_error;
     ELSE
       RETURN 'Y';
     END IF;
  END IF;
--
End check_enrollment_dates;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< closed_event >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Closed Event
--
--              Checks if the given event is closed
--
Function closed_event (p_event_id         in number,
                       p_event_record_use in varchar2 )
return BOOLEAN is
--
  l_proc        varchar2(72) := g_package||'closed_event';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- retrieve event details if not already obtained
  --
  get_event (p_event_id, p_event_record_use);
  --
  Return (g_event_rec.event_status = g_closed_event);
  --
end closed_event;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_closed_event >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Closed Event
--
--              Checks that the event to which the booking is being made is
--              not closed
--
Procedure check_closed_event
             (p_event_id            in number,
              p_date_booking_placed in date,
              p_event_record_use    in varchar2 ) is
--
  l_proc        varchar2(72) := g_package||'check_closed_event';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- retrieve event details if not already obtained
  --
  get_event (p_event_id, p_event_record_use);
  --
  -- check if the event is closed
  --
  if closed_event (p_event_id, 'SAME EVENT') then
  --
    --
    fnd_message.set_name ('OTA', 'OTA_13249_TDB_CLOSED_EVENT');
    fnd_message.raise_error;
    --
  --
  --
  -- check if the enrolment dates of the event are given
  -- if not given then no bookings are allowed
  --
  elsif not enrolling (p_event_id, 'SAME EVENT') then
  --
    fnd_message.set_name ('OTA', 'OTA_13250_TDB_NO_ENROLMENT');
    fnd_message.raise_error;
    --
  --
  -- check if the booking date falls between the enrolment dates of the event
  --
  elsif not enrolling_on_date (p_event_id,p_date_booking_placed,'SAME EVENT')
  then
  --
    --
    fnd_message.set_name ('OTA', 'OTA_13583_TDB_NO_ENROLL_DATE');
    fnd_message.raise_error;
    --
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_closed_event;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_letter_request_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- A function to create a letter request for the specified letter type.
-- Enhancement 2764968.
FUNCTION get_letter_request_id (p_letter_type_id in number,
                                p_event_id       in number) return number IS
--
  Cursor c_next_id is
    select per_letter_requests_s.nextval
    from   dual;
--
  l_request_id        number(15);

--
BEGIN
--
    -- no curent request exists
    --
    open c_next_id;
    fetch c_next_id into l_request_id;
    close c_next_id;
    --
    insert into per_letter_requests
                   (letter_request_id
                   ,business_group_id
                   ,letter_type_id
                   ,date_from
                   ,request_status
                   ,auto_or_manual
                   ,event_id)
    select l_request_id
    ,      a.business_group_id
    ,      p_letter_type_id
    ,      sysdate
    ,      'PENDING'
    ,      'AUTO'
    ,      p_event_id
    from   per_letter_types a
    where  a.letter_type_id = p_letter_type_id;
    --
  --
  RETURN l_request_id;
  --
--
END get_letter_request_id;
--------------------------------------------------------------------------------
/***FUNCTION get_letter_request_id (p_letter_type_id in number) return number IS
--
  Cursor c_request is
    select letter_request_id
    from   per_letter_requests
    where  letter_type_id = p_letter_type_id
      and  request_status = 'PENDING';
--
  Cursor c_next_id is
    select per_letter_requests_s.nextval
    from   dual;
--
  l_request_id        number(15);
  l_proc              varchar2(72) := g_package||'get_letter_request_id';
--
BEGIN
--
  open c_request;
  fetch c_request into l_request_id;
  if c_request%notfound THEN
  --
    -- no curent request exists
    --
    open c_next_id;
    fetch c_next_id into l_request_id;
    close c_next_id;
    --
    insert into per_letter_requests
                   (letter_request_id
                   ,business_group_id
                   ,letter_type_id
                   ,date_from
                   ,request_status
                   ,auto_or_manual)
    select l_request_id
    ,      a.business_group_id
    ,      p_letter_type_id
    ,      sysdate
    ,      'PENDING'
    ,      'AUTO'
    from   per_letter_types a
    where  a.letter_type_id = p_letter_type_id;
    --
  end if;
  --
  close c_request;
  --
  RETURN l_request_id;
  --
--
END get_letter_request_id; ***/
-------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |---------------------------< ota_letter_lines >---------------------------|
-- ----------------------------------------------------------------------------
-- procedure new code. Enhancement 2764968.
--
procedure ota_letter_lines (p_booking_id             in number,
                            p_booking_status_type_id in number,
                            p_event_id               in number,
                            p_delegate_person_id in number default null) Is
                      --added person_id parameter.Bug#2791524
   --
   l_dummy             varchar2 (1);
   l_found             boolean := true;

   l_letter_request_id per_letter_requests.letter_request_id%TYPE;
   l_letter_req_id     per_letter_requests.letter_request_id%TYPE;
   l_letter_type_id    per_letter_types.letter_type_id%TYPE;
   l_business_group_id per_letter_types.business_group_id%TYPE;
   l_event_id          number;
   --


      Cursor c_letter_requests_evt(cp_status_id in number) is
      select b.letter_type_id,
             c.letter_request_id
       from  per_letter_gen_statuses a,
             per_letter_types b,
             per_letter_requests c
      where  a.assignment_status_type_id = p_booking_status_type_id
        and  b.letter_type_id = a.letter_type_id
        and  b.generation_status_type = 'OTA_BOOKING'
        and  c.letter_type_id = b.letter_type_id
        and  c.event_id= p_event_id
        and  c.request_status = 'PENDING'
        and  c.auto_or_manual = 'AUTO'
        and  a.enabled_flag='Y'; ---***added for bug#2791524;

      Cursor c_letter_requests(cp_status_id in number) is
      select b.letter_type_id,
             c.letter_request_id
       from  per_letter_gen_statuses a,
             per_letter_types b,
             per_letter_requests c
      where  a.assignment_status_type_id = p_booking_status_type_id
        and  b.letter_type_id = a.letter_type_id
        and  b.generation_status_type = 'OTA_BOOKING'
        and  c.letter_type_id = b.letter_type_id
        AND  c.event_id IS null
        and  c.request_status = 'PENDING'
        and  c.auto_or_manual = 'AUTO'
        and  a.enabled_flag='Y'; ---***added for bug#2791524;
   --
      CURSOR c_letters (cp_status_id in number) IS
      select a.letter_type_id
      from   per_letter_gen_statuses a,
             per_letter_types b
      where  a.assignment_status_type_id = cp_status_id
      and    b.letter_type_id = a.letter_type_id
      and    b.generation_status_type = 'OTA_BOOKING'
      and    a.enabled_flag='Y'; ---***added for bug#2791524;

   cursor c_request_exists is
      select null
      from   per_letter_request_lines
      where  ota_booking_id = p_booking_id
      and    ota_booking_status_type_id = p_booking_status_type_id
      and    letter_request_id = l_letter_request_id;

   -- Added for Bug#3007934
   cursor csr_get_business_group_id is
     select business_group_id
     from ota_events
     where event_id = p_event_id;
   --
BEGIN
   --Modified for Bug#3007934
   -- l_business_group_id := ota_general.get_business_group_id;
   OPEN csr_get_business_group_id;
   FETCH csr_get_business_group_id INTO l_business_group_id;
   CLOSE csr_get_business_group_id;

  IF  ( NVL(FND_PROFILE.VALUE('HR_LETTER_BY_VACANCY'), 'N') <> 'Y' ) THEN
  --
     OPEN c_letter_requests(p_booking_status_type_id);
     --
     FETCH c_letter_requests INTO l_letter_type_id,
                                     l_letter_request_id;
     IF c_letter_requests%NOTFOUND THEN
            l_event_id :=NULL;  --Hr_letter_by_vacancy is No. So no event association.
            OPEN c_letters(p_booking_status_type_id);
            FETCH c_letters INTO l_letter_type_id;
               IF c_letters%NOTFOUND THEN
                   l_found := FALSE;
               END IF;
            CLOSE c_letters;
     END IF;
     --
     CLOSE c_letter_requests;
  --
  ELSE
  --
     OPEN c_letter_requests_evt(p_booking_status_type_id);
     FETCH c_letter_requests_evt INTO l_letter_type_id,
                                      l_letter_request_id;

         IF c_letter_requests_evt%notfound THEN
             l_event_id := p_event_id; --Hr_letter_by_vacancy is Yes. So event association.
             OPEN c_letters(p_booking_status_type_id);
               FETCH c_letters INTO l_letter_type_id;
                    IF c_letters%NOTFOUND THEN
                        l_found := FALSE;
                    END IF;
               CLOSE c_letters;
         END IF;
     CLOSE C_LETTER_REQUESTS_EVT;
   --
   END IF;

   IF l_found THEN
             IF l_letter_request_id IS NULL then
                l_letter_req_id := get_letter_request_id(l_letter_type_id,l_event_id);
             ELSE l_letter_req_id := l_letter_request_id;
             END IF;

            -- Check if request exists that the request lines do not exist
            --
            open c_request_exists;
            --
            fetch c_request_exists into l_dummy;
         --
            if c_request_exists%notfound then
            --
               ----***added person_id in insert statement.Bug#2791524.
               insert into per_letter_request_lines
                (letter_request_line_id,
                 business_group_id,
                 letter_request_id,
                 person_id,
                 ota_booking_id,
                 ota_booking_status_type_id,
                 date_from
                )
               values
                (per_letter_request_lines_s.nextval,
                 l_business_group_id,
                 l_letter_req_id,
                 p_delegate_person_id,
                 p_booking_id,
                 p_booking_status_type_id,
                 trunc(sysdate)
                );
             --
             end if;
         --
             close c_request_exists;
    END IF;

END ota_letter_lines;
-------------------------------------------------------------------------------
/***procedure ota_letter_lines (p_booking_id             in number,
                            p_booking_status_type_id in number) Is
   --
   l_dummy             varchar2 (1);
   l_found             boolean := false;
   l_letter_request_id number   (15);
   l_proc              varchar2 (72) := g_package||'ota_letter_lines';
   --
   CURSOR c_letters (cp_status_id in number) IS
      select a.letter_type_id
      ,      a.business_group_id
      from   per_letter_gen_statuses a
      ,      per_letter_types b
      where  a.assignment_status_type_id = cp_status_id
      and    b.letter_type_id = a.letter_type_id
      and    b.generation_status_type = 'OTA_BOOKING';
   --
   cursor c_requests (p_letter_type_id in number) is
      select letter_request_id
      from   per_letter_requests
      where  letter_type_id = p_letter_type_id
      and    request_status = 'PENDING'
      and    auto_or_manual = 'AUTO';
   --
   cursor c_request_exists is
      select null
      from   per_letter_request_lines
      where  ota_booking_id = p_booking_id
      and    ota_booking_status_type_id = p_booking_status_type_id
      and    letter_request_id = l_letter_request_id;
   --
BEGIN
   --
   FOR r_letters in c_letters(p_booking_status_type_id) LOOP
      --
      -- Check whether there is an automatic letter required and request_status
      -- is pending.
      --
      open c_requests(r_letters.letter_type_id);
         --
         fetch c_requests into l_letter_request_id;
         --
         if c_requests%notfound then
            --
            l_letter_request_id := get_letter_request_id(r_letters.letter_type_id);
            --
         end if;
         --
      close c_requests;
      --
      -- Check if request exists that the request lines do not exist
      --
      open c_request_exists;
         --
         fetch c_request_exists into l_dummy;
         --
         if c_request_exists%notfound then
            --
            insert into per_letter_request_lines
                (letter_request_line_id,
                 business_group_id,
                 letter_request_id,
                 ota_booking_id,
                 ota_booking_status_type_id,
                 date_from
                )
            values
                (per_letter_request_lines_s.nextval,
                 r_letters.business_group_id,
                 l_letter_request_id,
                 p_booking_id,
                 p_booking_status_type_id,
                 trunc(sysdate)
                );
             --
         end if;
         --
      close c_request_exists;
      --
   END LOOP r_letters;
   --
END ota_letter_lines;  ***/
-------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_constraints >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure check_constraints
        (
        p_internal_booking_flag           in varchar2,
        p_successful_attendance_flag      in varchar2
        ) Is
--
  l_proc        varchar2(72) := g_package||'check_constraints';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If NOT (p_internal_booking_flag in ('N', 'Y')) then
    hr_utility.set_message(801,'HR_7166_OBJECT_CHK_CONSTRAINT');
    hr_utility.set_message_token('CONSTRAINT_NAME',
                                 'OTA_TDB_INTERNAL_BOOKING_F_CHK');
    hr_utility.set_message_token('TABLE_NAME', 'OTA_DELEGATE_BOOKINGS');
    hr_utility.raise_error;
  End If;
  If NOT (p_successful_attendance_flag in ('N', 'Y')) then
    hr_utility.set_message(801,'HR_7166_OBJECT_CHK_CONSTRAINT');
    hr_utility.set_message_token('CONSTRAINT_NAME',
                                 'OTA_TDB_SUCCESSFUL_ATTENDA_CHK');
    hr_utility.set_message_token('TABLE_NAME', 'OTA_DELEGATE_BOOKINGS');
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_constraints;
--
-- ----------------------------------------------------------------------------
-- |----------------< check_program_member_enrollments >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Determines whether a person is enrolled onto program
--              member events before their program enrollment can be
--              deleted.
--
Procedure check_pmm_enrollments is
--
  l_event_id            number := ota_tdb_shd.g_old_rec.event_id;
  l_customer_id         number := ota_tdb_shd.g_old_rec.customer_id;
  l_organization_id     number := ota_tdb_shd.g_old_rec.organization_id;
  l_delegate_person_id  number := ota_tdb_shd.g_old_rec.delegate_person_id;
  l_delegate_contact_id number := ota_tdb_shd.g_old_rec.delegate_contact_id;
  l_proc                varchar2(72) := g_package||'check_pmm_enrollments';
  l_result              number;

  cursor c_pmm_int_enrollments is
  select 1
  from  ota_delegate_bookings tdb,
        ota_program_memberships pmm
  where tdb.event_id = pmm.event_id
  and   pmm.program_event_id = l_event_id
  and   tdb.delegate_person_id = l_delegate_person_id;

  cursor c_pmm_ext_enrollments is
  select 1
  from  ota_delegate_bookings tdb,
        ota_program_memberships pmm
  where tdb.event_id = pmm.event_id
  and   pmm.program_event_id = l_event_id
  and   tdb.delegate_contact_id = l_delegate_contact_id;

--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);

  if get_event_type(l_event_id) = 'PROGRAMME' then
  --
    if l_customer_id is not null then
    --
      open c_pmm_ext_enrollments;
      fetch c_pmm_ext_enrollments into l_result;
      if c_pmm_ext_enrollments%found then
      --
        close c_pmm_ext_enrollments;
        fnd_message.set_name('OTA', 'OTA_13685_TDB_PMM_EXISTS');
        fnd_message.raise_error;
      --
      else
      --
       close c_pmm_ext_enrollments;
      --
      end if;
    --
    elsif l_organization_id is not null then
    --
      open c_pmm_int_enrollments;
      fetch c_pmm_int_enrollments into l_result;
      if c_pmm_int_enrollments%found then
      --
        close c_pmm_int_enrollments;
        fnd_message.set_name('OTA', 'OTA_13685_TDB_PMM_EXISTS');
        fnd_message.raise_error;
      --
      else
      --
       close c_pmm_int_enrollments;
      --
      end if;
    --
    end if;
  --
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End check_pmm_enrollments;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_line_id  >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_line_id
  (p_booking_id                in number
   ,p_line_id                   in number
   ,p_org_id                    in number) is

--
  l_proc  varchar2(72) := g_package||'chk_line_id';
  l_exists      varchar2(1);

--
--  cursor to check if line is exist in OE_ORDER_LINES .
--
   cursor csr_order_line is
     select null
     from oe_order_lines_all
     where line_id = p_line_id;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

if (((p_booking_id is not null) and
      nvl(ota_tdb_shd.g_old_rec.line_id,hr_api.g_number) <>
         nvl(p_line_id,hr_api.g_number))
   or (p_booking_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if p_line_id is not null then

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
hr_utility.set_location('Leaving:'||l_proc, 30);
end chk_line_id;

-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_Order_line_exist  >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_Order_line_exist
  (p_line_id                    in number
   ,p_org_id                    in number) is

--
  l_proc  varchar2(72) := g_package||'chk_order_line_exist';


Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

if p_line_id is not null then
   fnd_message.set_name('OTA','OTA_13885_TDB_ORDER_LINE_EXIST');
   fnd_message.raise_error;
   hr_utility.set_location('Entering:'||l_proc, 20);

end if;
hr_utility.set_location('Leaving:'||l_proc, 30);
end chk_order_line_exist;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_status_changed  >----------------------|
-- ----------------------------------------------------------------------------
-- This procedure will check whether the status is changed. this procedure is
-- called by post_update procedure and will be only used by OM integration.
-- The purpose of this procedure is to cancel an order line, Create RMA and
-- To notify the Workflow to continue.
Procedure chk_status_changed
  (p_line_id                    in number
   ,p_status_type_id            in number
   ,p_daemon_type                       in varchar2
   ,p_event_id                  in number
   ,p_booking_id                        in number
   ,p_org_id                    in number
           ) is

  l_proc  varchar2(72) := g_package||'chk_status_changed';

  l_booking_status_changed        boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.booking_status_type_id,
                                                  p_status_type_id);
  l_status_type         ota_booking_status_types.type%type;
  l_old_status_type     ota_booking_status_types.type%type;
  l_invoice_rule                varchar2(80);
  l_exist                       varchar2(1);
  l_return              boolean;
  l_err_num             VARCHAR2(30) := '';
  l_err_msg             VARCHAR2(1000) := '';
  l_dynamicSqlString            VARCHAR2(2000);
  l_ins_status                  VARCHAR2(1);
  l_industry                    VARCHAR2(1);
  l_msg_data            VARCHAR2(1000);
  l_event_exist         varchar2(1);
  l_line_id             number;

CURSOR C_RE IS
Select LINE_ID
FROM OTA_EVENTS
WHERE EVENT_ID = p_event_id
AND   LINE_ID IS NOT NULL ;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   IF p_line_id is not null THEN
        IF l_booking_status_changed THEN
                /*ota_utility.get_invoice_rule (
                                        p_line_id => p_line_id,
                                        p_invoice_rule => l_invoice_rule);*/

                ota_utility.get_booking_status_type(
                                        p_status_type_id => ota_tdb_shd.g_old_rec.booking_status_type_id,
                                        p_type => l_old_status_type) ;
           IF  p_status_type_id is not null THEN
                 ota_utility.get_booking_status_type(
                                        p_status_type_id => p_status_type_id,
                                        p_type => l_status_type);

             IF l_status_type = 'C' THEN
                IF p_daemon_type = 'W' THEN

                  BEGIN
                     hr_utility.set_location('Entering:'||l_proc, 10);

                           ota_utility.check_invoice(
                                                p_line_id => p_line_id,
                                                p_org_id => p_org_id,
                                                p_exist =>  l_exist);
                  IF fnd_installation.get(660, 660, l_ins_status, l_industry) THEN
                     IF l_exist = 'Y' THEN
                        BEGIN
                         hr_utility.set_location('Entering:'||l_proc, 15);
                         ota_om_upd_api.create_rma(p_line_id,p_org_id);
--
-- Start bug #1657510 Comment out exception handler
--
/*
                        exception when others then
                              hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                                hr_utility.set_message_token('PROCEDURE', l_proc);
                                hr_utility.set_message_token('STEP','15');
                                hr_utility.raise_error;
*/
--
-- End bug #1657510 Comment out exception handler
--
                         END;
                           ELSE
                       BEGIN
                       hr_utility.set_location('Entering:'||l_proc, 20);

                        ota_om_upd_api.cancel_order(p_line_id,p_org_id);
--
-- Start bug #1657510 Comment out exception handler
--
/*
                                exception when others then
                               hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                                hr_utility.set_message_token('PROCEDURE', l_proc);
                                hr_utility.set_message_token('STEP','20');
                                hr_utility.raise_error;
*/
--
-- End bug #1657510 Comment out exception handler
--
                        END;
                           END IF;
                  END IF;


                  END;

                END IF;
              /* Fix Bug 1549427 :Remove the checked for invoicing rule */
              ELSIF l_status_type = 'A' THEN
                         IF l_old_status_type in ('W','P','R') THEN
                            l_return := ota_utility.check_wf_status(p_line_id,'WAIT_FOR_ATTENDED');
                                IF l_return = TRUE THEN
                           wf_engine.Completeactivity('OEOL',
                                    to_char(p_line_id),
                                    'WAIT_FOR_ATTENDED',null);
                         END IF;
                         END IF;



                 /* ELSIF l_status_type = 'P' THEN
                         IF l_old_status_type = 'W' THEN
                                IF l_invoice_rule = 'ADVANCED' THEN
                                        l_return := ota_utility.check_wf_status(p_line_id,'WAIT_FOR_PLACED');
                                        IF l_return = TRUE THEN
                                   wf_engine.Completeactivity('OEOL',
                                            to_char(p_line_id),
                                            'WAIT_FOR_PLACED',null);
                              END IF;
                                END IF;
                     END IF;
                 ELSIF l_status_type = 'A' THEN
                         IF l_invoice_rule = 'ARREARS' THEN
                                l_return := ota_utility.check_wf_status(p_line_id,'WAIT_FOR_ATTENDED');
                                IF l_return = TRUE THEN
                           wf_engine.Completeactivity('OEOL',
                                        to_char(p_line_id),
                                        'WAIT_FOR_ATTENDED',null);
                        END IF;
                         END IF; */

             END IF;
           END IF;
      END IF;
 --  END IF;


  ELSIF p_line_id is null THEN
        IF l_booking_status_changed THEN

           ota_utility.get_booking_status_type(
                                        p_status_type_id => ota_tdb_shd.g_old_rec.booking_status_type_id,
                                        p_type => l_old_status_type) ;

           IF  p_status_type_id is not null THEN
                 ota_utility.get_booking_status_type(
                                        p_status_type_id => p_status_type_id,
                                        p_type => l_status_type);
             OPEN C_RE;
             FETCH C_RE INTO l_line_id;
             IF C_RE%FOUND THEN
                IF l_status_type = 'A' and l_old_status_type is not null then

                        l_return := ota_utility.check_wf_status(l_line_id,'WAIT_FOR_ENROLLMENT_ATTENDED');
                                IF l_return = TRUE THEN
                           wf_engine.Completeactivity('OEOL',
                                        to_char(l_line_id),
                                   'WAIT_FOR_ENROLLMENT_ATTENDED',null);

                        END IF;

                END IF;
             END IF;
             CLOSE C_RE;
         END IF;
      END IF;

END IF;

hr_utility.set_location('Leaving:'||l_proc, 30);
/*EXCEPTION WHEN OTHERS THEN
        l_err_num := SQLCODE;
      l_err_msg := SUBSTR(SQLERRM, 1, 100);

      raise_application_error(-20001,l_err_num||': '||l_err_msg);*/

end chk_status_changed;

-- ----------------------------------------------------------------------------
-- |------------------------------< check_secure_event >----------------------------------|
-- ----------------------------------------------------------------------------
-- Added for bug#4606760
PROCEDURE check_secure_event(p_event_id IN NUMBER
                            ,p_delegate_person_id IN NUMBER)
IS
  CURSOR csr_is_secure_event IS
   SELECT organization_id
   FROM ota_events
   WHERE event_id = p_event_id
     AND nvl(secure_event_flag,'N') = 'Y';

   l_organization_id OTA_EVENTS.organization_id%TYPE;
   l_is_match VARCHAR2(1);
BEGIN
   OPEN csr_is_secure_event;
   FETCH csr_is_secure_event INTO l_organization_id;
   IF csr_is_secure_event%FOUND THEN
      l_is_match := ota_utility.check_organization_match(p_delegate_person_id,l_organization_id);
      IF l_is_match = 'N' THEN
        fnd_message.set_name('OTA','OTA_443939_SECURE_EVT_LRN_ERR');
        fnd_message.raise_error;
      END IF;
   END IF;
   CLOSE csr_is_secure_event;
END check_secure_event;


-- ----------------------------------------------------------------------------
-- |------------------------------< check_online_enr_change >----------------------------------|
-- ----------------------------------------------------------------------------
--Added for bug#4650304
PROCEDURE check_online_enr_change(
       p_booking_id IN NUMBER
      ,p_event_id IN NUMBER
      ,p_booking_status_type_id IN NUMBER
      ,p_content_player_status IN VARCHAR2
      ,p_delegate_person_id IN NUMBER
      ,p_delegate_contact_id IN NUMBER) IS

 l_event_id OTA_DELEGATE_BOOKINGS.event_id%TYPE := p_event_id;

 CURSOR csr_get_class_type(p_class_id NUMBER) IS
   SELECT oft.learning_object_id
         ,ctu.online_flag
         ,evt.offering_id
   FROM  ota_offerings oft
       , ota_events evt
       , ota_category_usages ctu
   WHERE oft.offering_id = evt.parent_offering_id
       AND ctu.category_usage_id = oft.delivery_mode_id
       AND evt.event_id = p_class_id;

   l_online_flag VARCHAR2(9) := NULL;
   l_lo_id ota_offerings.learning_object_id%TYPE;
   l_imported_off_id ota_events.offering_id%TYPE;
   l_bkng_status_type VARCHAR2(30);
   l_old_bst VARCHAR2(30);

   l_player_status ota_delegate_bookings.content_player_status%TYPE;

   CURSOR csr_get_performance_data(p_user_id NUMBER
                                   ,p_user_type VARCHAR2
                                   ,p_lo_id NUMBER) IS
    SELECT lesson_status
    FROM ota_performances
    WHERE learning_object_id = p_lo_id
     AND user_id = p_user_id
     AND user_type = p_user_type
     AND lesson_status IN ('P', 'C');

     l_user_type ota_performances.user_type%TYPE;
     l_user_id ota_performances.user_id%TYPE;
     l_person_id ota_delegate_bookings.delegate_person_id%TYPE := p_delegate_person_id;
     l_contact_id ota_delegate_bookings.delegate_contact_id%TYPE := p_delegate_contact_id;

BEGIN
  IF p_booking_status_type_id <> hr_api.g_number THEN
     ota_utility.get_booking_status_type(p_booking_status_type_id,l_bkng_status_type);
     ota_utility.get_booking_status_type(ota_tdb_shd.g_old_rec.booking_status_type_id,l_old_bst);

     IF l_bkng_status_type = 'A'
       OR l_old_bst not in('A','E') THEN RETURN; END IF;--Added for 6989133.

     IF p_event_id = hr_api.g_number THEN
        l_event_id := ota_tdb_shd.g_old_rec.event_id;
      END IF;

    OPEN csr_get_class_type(l_event_id);
    FETCH csr_get_class_type INTO l_lo_id, l_online_flag, l_imported_off_id;
    CLOSE csr_get_class_type;


    IF nvl(l_online_flag, 'N') = 'Y' THEN
      -- Add logic to check performance status and throw error acc.
        IF l_imported_off_id IS NOT NULL THEN
          -- Imported class. Performance data to be fetched from TDB table
          IF l_player_status = hr_api.g_varchar2 THEN
            l_player_status := ota_tdb_shd.g_old_rec.content_player_status;
          ELSE
            l_player_status := p_content_player_status;
          END IF;
        ELSE
          -- Performance to be fetched from OTA_PERFORMANCES
          IF l_contact_id = hr_api.g_number THEN
             l_contact_id := ota_tdb_shd.g_old_rec.delegate_contact_id;
          END IF;
          IF l_person_id = hr_api.g_number THEN
             l_person_id := ota_tdb_shd.g_old_rec.delegate_person_id;
          END IF;

          IF l_person_id IS NOT NULL THEN
             OPEN csr_get_performance_data(l_person_id, 'E', l_lo_id);
          ELSIF l_contact_id IS NOT NULL THEN
             OPEN csr_get_performance_data(
                  ota_utility.get_ext_lrnr_party_id(l_contact_id)
                  ,'C'
                  ,l_lo_id);
          ELSE
              RETURN;
          END IF;
          FETCH csr_get_performance_data INTO l_player_status;
          CLOSE csr_get_performance_data;

          IF l_player_status = 'P' OR l_player_status = 'C' THEN
            fnd_message.set_name ('OTA','OTA_443964_TDB_STATUS_CHG_ERR');
            fnd_message.raise_error;
          END IF;


        END IF;
    END IF;
  END IF;
END check_online_enr_change;

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
PROCEDURE chk_df
  (p_rec IN ota_tdb_shd.g_rec_type
  ) IS
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  IF ((p_rec.booking_id IS NOT NULL)  AND (
    NVL(ota_tdb_shd.g_old_rec.tdb_information_category, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information_category, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information1, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information1, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information2, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information2, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information3, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information3, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information4, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information4, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information5, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information5, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information6, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information6, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information7, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information7, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information8, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information8, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information9, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information9, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information10, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information10, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information11, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information11, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information12, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information12, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information13, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information13, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information14, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information14, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information15, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information15, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information16, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information16, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information17, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information17, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information18, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information18, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information19, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information19, hr_api.g_varchar2)  OR
    NVL(ota_tdb_shd.g_old_rec.tdb_information20, hr_api.g_varchar2) <>
    NVL(p_rec.tdb_information20, hr_api.g_varchar2) ) )
    OR (p_rec.booking_id IS NULL)  THEN
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the tdb_information values have actually changed.
    -- b) During insert.
    --

    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_DELEGATE_BOOKINGS'
      ,p_attribute_category              => p_rec.tdb_information_category
      ,p_attribute1_name                 => 'TDB_INFORMATION1'
      ,p_attribute1_value                => p_rec.tdb_information1
      ,p_attribute2_name                 => 'TDB_INFORMATION2'
      ,p_attribute2_value                => p_rec.tdb_information2
      ,p_attribute3_name                 => 'TDB_INFORMATION3'
      ,p_attribute3_value                => p_rec.tdb_information3
      ,p_attribute4_name                 => 'TDB_INFORMATION4'
      ,p_attribute4_value                => p_rec.tdb_information4
      ,p_attribute5_name                 => 'TDB_INFORMATION5'
      ,p_attribute5_value                => p_rec.tdb_information5
      ,p_attribute6_name                 => 'TDB_INFORMATION6'
      ,p_attribute6_value                => p_rec.tdb_information6
      ,p_attribute7_name                 => 'TDB_INFORMATION7'
      ,p_attribute7_value                => p_rec.tdb_information7
      ,p_attribute8_name                 => 'TDB_INFORMATION8'
      ,p_attribute8_value                => p_rec.tdb_information8
      ,p_attribute9_name                 => 'TDB_INFORMATION9'
      ,p_attribute9_value                => p_rec.tdb_information9
      ,p_attribute10_name                => 'TDB_INFORMATION10'
      ,p_attribute10_value               => p_rec.tdb_information10
      ,p_attribute11_name                => 'TDB_INFORMATION11'
      ,p_attribute11_value               => p_rec.tdb_information11
      ,p_attribute12_name                => 'TDB_INFORMATION12'
      ,p_attribute12_value               => p_rec.tdb_information12
      ,p_attribute13_name                => 'TDB_INFORMATION13'
      ,p_attribute13_value               => p_rec.tdb_information13
      ,p_attribute14_name                => 'TDB_INFORMATION14'
      ,p_attribute14_value               => p_rec.tdb_information14
      ,p_attribute15_name                => 'TDB_INFORMATION15'
      ,p_attribute15_value               => p_rec.tdb_information15
      ,p_attribute16_name                => 'TDB_INFORMATION16'
      ,p_attribute16_value               => p_rec.tdb_information16
      ,p_attribute17_name                => 'TDB_INFORMATION17'
      ,p_attribute17_value               => p_rec.tdb_information17
      ,p_attribute18_name                => 'TDB_INFORMATION18'
      ,p_attribute18_value               => p_rec.tdb_information18
      ,p_attribute19_name                => 'TDB_INFORMATION19'
      ,p_attribute19_value               => p_rec.tdb_information19
      ,p_attribute20_name                => 'TDB_INFORMATION20'
      ,p_attribute20_value               => p_rec.tdb_information20
      );
  END IF;

  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
END chk_df;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Controls the validation execution on insert.
--
Procedure insert_validate(
                    p_rec in ota_tdb_shd.g_rec_type,
                          p_enrollment_type in varchar2
                          ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_event_record_use  varchar2(10);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  --
  -- Call all supporting business operations
  --
  --
  -- check whether an event is customer based in which case if enrollment
  -- type is 'C' (Customer enrollments) then delegate_person_id must be null
  -- otherwise delegate_person_id must not be null, in other words it is
  -- a student enrollment.

/****************************************************************************
   Comment out as fix for bug 640958. We do not want to prevent block customer
   bookings on the student enrollment form, even for a restricted
   event.
****************************************************************************/

/*
  if p_rec.customer_id is not null then

    ota_tdb_bus2.check_enrollment_type(p_rec.event_id,
                        p_rec.delegate_contact_id,
                        p_enrollment_type,
                        p_rec.booking_id);

  end if;
*/
  -- check that the delegate, contact and authorizer are visible when the
  -- booking is made
  --
  ota_tdb_bus2.check_person_visible (p_rec.delegate_person_id,
                        p_rec.date_booking_placed,
                        'Delegate',
                        p_rec.person_address_type);
  --
  --
  -- Check that sponsor and delegate are valid for enrollment
  --
  ota_tdb_bus2.check_spon_del_validity (p_rec.event_id,
                                        p_rec.organization_id,
                                        p_rec.delegate_person_id,
                                        p_rec.sponsor_person_id,
                                        p_rec.date_booking_placed);
  --
  check_authorizer     (p_rec.authorizer_person_id);
  --
  -- Check that the maximum number of internal delegates is not
  -- exceeded.
  if p_rec.internal_booking_flag = 'Y'                    and
     p_rec.number_of_places > 0                           and
     event_place_needed(p_rec.booking_status_type_id) = 1 then
     --
     check_internal_booking(p_rec.event_id,
                            p_rec.number_of_places,
                            p_rec.booking_id);
     --
  end if;
  --
  -- Check that the delegate contact and sponsor contact exist for
  -- the customer for an external enrollment
  --
  ota_tdb_bus2.check_customer_details(p_rec.customer_id,
                         p_rec.delegate_contact_id,
                         p_rec.contact_id);
  --
  -- Checks whether contact address id is not null and that :
  -- The address_id is valid for the customer
  --
  -- ota_tdb_bus2.check_contact_address (p_rec.contact_address_id,
  --                     p_rec.customer_id);
  --
  -- Check that when an internal booking is used that certain variables
  -- are populated while certain other variables are null
  --
  ota_tdb_bus2.check_organization_details       (p_rec.organization_id,
                                 p_rec.delegate_person_id,
                                 p_rec.delegate_assignment_id,
                                 p_rec.sponsor_person_id,
                                 p_rec.sponsor_assignment_id);
  --
  -- check that the booking status type is valid
  --
  check_booking_status_type (p_rec.booking_status_type_id
                            , p_rec.event_id);   -- bug 3677661
  --
  -- check that the priority is within the domain 'Priority Level'
  --
  if p_rec.booking_priority is not null then
  --
    ota_general.check_domain_value ('PRIORITY_LEVEL', p_rec.booking_priority);
  --
  end if;
  --
  --
  -- check that the source is within the domain 'Booking Source'
  --
  if p_rec.source_of_booking is not null then
  --
    ota_general.check_domain_value ('BOOKING_SOURCE', p_rec.source_of_booking);
  --
  end if;
  --
  -- check that the number of places is one for a delegate
  --
  check_places (p_rec.delegate_person_id, p_rec.number_of_places);
  check_places (p_rec.delegate_contact_id, p_rec.number_of_places);
  --
  --
  -- check that the booking has not already been made for the delegate
  --
  check_unique_booking (p_rec.customer_id,
                        p_rec.organization_id,
                        p_rec.event_id,
                        p_rec.delegate_person_id,
                        p_rec.delegate_contact_id,
                        p_rec.booking_id);
  --
  -- check that the event is still open for bookings
  --
  check_closed_event (p_rec.event_id,
                      p_rec.date_booking_placed,
                      'NEW EVENT');
  --
  -- Check that the person address is valid for the correspondent
  --
  if p_rec.person_address_id is not null then
    if p_rec.person_address_type <> 'E' then
      --
      -- Person address type should be external
      -- show error
      --
      fnd_message.set_name ('OTA','OTA_13506_ADDRESS_TYPE_NOT_I');
      fnd_message.raise_error;
      --
      -- Address must be a valid one for the correspondent
      --
    else
      if p_rec.corespondent = 'S' then
        --
        -- Check delegate has a valid address in per_addresses
        --
        ota_tdb_bus2.check_person_address(p_rec.delegate_person_id,
                                          p_rec.person_address_id,
                                          'Delegate');
        --
      elsif p_rec.corespondent = 'C' then
        --
        -- Check contact has a valid address in per_addresses
        --
        ota_tdb_bus2.check_person_address(p_rec.sponsor_person_id,
                                          p_rec.person_address_id,
                                          'Contact');
        --
      end if;
    end if;
  end if;

  --
  -- subsequent checks requiring event details may re-use the event record
  -- refreshed by the previous procedure
  --

  --
  -- check that if the booking is for a programme member then the parent has
  -- already been booked
  --
  check_programme_member (p_rec.event_id,
                          p_rec.customer_id,
                          p_rec.organization_id,
                          p_rec.delegate_person_id,
                          p_rec.delegate_contact_id,
                          'SAME EVENT');
  --
  -- check that the business group of the event being booked is the same
  --
  check_event_business_group (p_rec.business_group_id,
                              p_rec.event_id,
                              'SAME EVENT');
  --
  --
  -- check that the business group of the booking status type is the same
  --
  check_type_business_group (p_rec.business_group_id,
                             p_rec.booking_status_type_id);
  --
  --
  -- check that the successful attendance flag is only set for confirmed
  -- bookings
  --
  check_attendance (p_rec.successful_attendance_flag,
                    p_rec.booking_status_type_id);
  --
  --
  --
  -- check that the failure reason is within the domain 'Delegate Failure
  -- Reason'
  --
  if p_rec.failure_reason is not null then
  --
    ota_general.check_domain_value ('DELEGATE_FAILURE_REASON',
                                   p_rec.failure_reason);
  --
  end if;
  --
  -- check that the reason for failure is not entered for a successful
  -- delegate
  --
  check_failure (p_rec.failure_reason,
                 p_rec.successful_attendance_flag);
/*   This validation is moved to ota_tdb_api_ins2.create_enrollment for Bulk Enrollment.
  --
  -- check that the delegate is eligible to be booked on to the event
  --
  check_delegate_eligible (p_rec.event_id,
                           p_rec.customer_id,
                        p_rec.delegate_contact_id,
                           p_rec.organization_id,
                           p_rec.delegate_person_id,
                           p_rec.delegate_assignment_id);
*/
  --
  check_constraints
        (
        p_rec.internal_booking_flag,
        p_rec.successful_attendance_flag
        );
  --
  -- Check business group is the same for all persons and assignments
  --
  ota_tdb_bus2.check_org_business_group (p_rec.event_id,
                                         p_rec.business_group_id,
                                         p_rec.organization_id,
                                         p_rec.delegate_person_id,
                                         p_rec.sponsor_person_id,
                                         p_rec.delegate_assignment_id,
                                         p_rec.sponsor_assignment_id,
                                         p_rec.date_booking_placed);
  --
  chk_line_id(p_rec.booking_id
                                ,p_rec.line_id
                                ,p_rec.org_id);

/*Enhancement 1823602*/
IF p_rec.line_id IS NOT NULL THEN
        ota_tdb_bus2.check_commitment_date(p_rec.line_id,
                                           p_rec.event_id);
END IF;
/*Enhancement 1823602*/

  --Bug 3619960
  ota_tdb_bus.chk_df(p_rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Controls the validation execution on update.
--
Procedure update_validate(
                          p_rec in ota_tdb_shd.g_rec_type,
                          p_enrollment_type in varchar2
                          ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
  l_customer_id_changed               boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.customer_id,
                                                  p_rec.customer_id);
--
  l_status_type_id_changed            boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.booking_status_type_id,
                                                  p_rec.booking_status_type_id);
--
  l_event_id_changed                  boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.event_id,
                                                  p_rec.event_id);
--
  l_business_group_id_changed         boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.business_group_id,
                                                  p_rec.business_group_id);
--
  l_date_booking_placed_changed        boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.date_booking_placed,
                                                  p_rec.date_booking_placed);
--
  l_delegate_person_id_changed        boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.delegate_person_id,
                                                  p_rec.delegate_person_id);
--
  l_sponsor_person_id_changed         boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.sponsor_person_id,
                                                  p_rec.sponsor_person_id);
--
  l_organization_id_changed           boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.organization_id,
                                                  p_rec.organization_id);
--
  l_contact_id_changed                boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.contact_id,
                                                  p_rec.contact_id);
--
  l_contact_address_id_changed        boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.contact_address_id,
                                                  p_rec.contact_address_id);
--
  l_authorizer_person_id_changed      boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.authorizer_person_id,
                                                  p_rec.authorizer_person_id);
--
  l_number_of_places_changed          boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.number_of_places,
                                                  p_rec.number_of_places);
--
  l_delegate_ass_changed              boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.delegate_assignment_id,
                                                  p_rec.delegate_assignment_id);
--
  l_sponsor_ass_changed               boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.sponsor_assignment_id,
                                                  p_rec.sponsor_assignment_id);
--
  l_booking_priority_changed          boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.booking_priority,
                                                  p_rec.booking_priority);
--
  l_person_address_id_changed         boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.person_address_id,
                                                  p_rec.person_address_id);
--
  l_attendance_flag_changed           boolean :=
   ota_general.value_changed (ota_tdb_shd.g_old_rec.successful_attendance_flag,
                                                  p_rec.successful_attendance_flag);
--
  l_source_of_booking_changed         boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.source_of_booking,
                                                  p_rec.source_of_booking);
--
  l_failure_reason_changed            boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.failure_reason,
                                                  p_rec.failure_reason);
--
  l_delegate_contact_id_changed       boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.delegate_contact_id,
                                                  p_rec.delegate_contact_id);

  l_old_event_id_changed                  boolean :=
           ota_general.value_changed (ota_tdb_shd.g_old_rec.old_event_id,
                                                  p_rec.old_event_id);
--
  l_event_record_use varchar2(10);
--
/* bug no 4509873 */
l_new_inv_id ota_activity_versions.inventory_item_id%type;
l_old_inv_id ota_activity_versions.inventory_item_id%type;

CURSOR get_inv_id (p_event_id in number) is
SELECT nvl(avt.inventory_item_id,1)
FROM ota_events evt, ota_activity_versions avt
WHERE  evt.activity_version_id = avt.activity_version_id
AND evt.event_id = p_event_id ;

/* bug no 4509873 */

l_status_type ota_booking_status_types.type%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
 -- Call check non updateable argument
   chk_non_updateable_args
    (
     p_rec              => p_rec
    );
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  --
  -- if the event has been updated then refresh the global event record
  -- and set an indicator to allow any subsequent event related checks to use
  -- the record
  --
  if l_event_id_changed then
  --
    get_event (p_rec.event_id, 'NEW EVENT');
    l_event_record_use := 'SAME EVENT';
    check_booking_status_type (p_rec.booking_status_type_id
                              , p_rec.event_id);   -- bug 3677661
  --
  else
  --
    l_event_record_use := 'NEW EVENT';
  --
  end if;
  --
  ota_tdb_bus2.check_person_visible (p_rec.delegate_person_id,
                        p_rec.date_booking_placed,
                        'Delegate',
                        p_rec.person_address_type);
  --
  -- Check that the maximum number of internal delegates is not
  -- exceeded.
  --
  if p_rec.internal_booking_flag = 'Y'                     and
     p_rec.number_of_places > 0                            and
     event_place_needed(p_rec.booking_status_type_id)  = 1 then
     --
     check_internal_booking(p_rec.event_id,
                            p_rec.number_of_places,
                            p_rec.booking_id);
     --
  end if;
  --
  -- check that the delegate and contact are visible when the booking is
  -- made
  --
/****************************************************************************
   Comment out as fix for bug 640958. We do not want to prevent block customer
   bookings on the student enrollment form, even for a restricted
   event.
****************************************************************************/

/*
  if l_delegate_contact_id_changed or
     l_contact_id_changed          or
     l_date_booking_placed_changed and
     p_rec.customer_id is not null then

       ota_tdb_bus2.check_enrollment_type(p_rec.event_id,
                          p_rec.delegate_contact_id,
                          p_enrollment_type,
                          p_rec.booking_id);

  end if;
*/
  --
  --
  -- Checks whether contact address id is not null and that :
  -- The address_id is valid for the customer
  --
  if l_contact_address_id_changed or
     l_customer_id_changed then
     --  ota_tdb_bus2.check_contact_address (p_rec.contact_address_id,
     --                         p_rec.customer_id);
     null;
  end if;
  --
  if l_event_id_changed or
     l_business_group_id_changed or
     l_organization_id_changed or
     l_delegate_person_id_changed or
     l_sponsor_person_id_changed or
     l_delegate_ass_changed or
     l_sponsor_ass_changed then
     --
     ota_tdb_bus2.check_org_business_group (p_rec.event_id,
                                            p_rec.business_group_id,
                                            p_rec.organization_id,
                                            p_rec.delegate_person_id,
                                            p_rec.sponsor_person_id,
                                            p_rec.delegate_assignment_id,
                                            p_rec.sponsor_assignment_id,
                                            p_rec.date_booking_placed);
     --
  end if;
  --
  if l_event_id_changed or
     l_delegate_person_id_changed or
     l_sponsor_person_id_changed or
     l_organization_id_changed then
       ota_tdb_bus2.check_spon_del_validity (   p_rec.event_id,
                                                p_rec.organization_id,
                                                p_rec.delegate_person_id,
                                                p_rec.sponsor_person_id,
                                                p_rec.date_booking_placed);
  end if;
  --
  --
  if l_authorizer_person_id_changed or
     l_date_booking_placed_changed then
  --
    check_authorizer     (p_rec.authorizer_person_id);
  --
  end if;
  --
  --
  -- check that the booking status type is valid
  --
  if l_status_type_id_changed then
  --
    check_booking_status_type (p_rec.booking_status_type_id
                              , p_rec.event_id);   -- bug 3677661
  --
  end if;
  --
  --
  if l_business_group_id_changed then
  --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  end if;
  --
  --
  if l_person_address_id_changed then
    if p_rec.person_address_id is not null then
      if p_rec.person_address_type <> 'E' then
        --
        -- Person address type should be internal
        -- show error
        --
        fnd_message.set_name ('OTA','OTA_13506_ADDRESS_TYPE_NOT_I');
        fnd_message.raise_error;
        --
        -- Address must be a valid one for the correspondent
        --
        if p_rec.corespondent = 'S' then
          --
          -- Check delegate has a valid address in per_addresses
          --
          ota_tdb_bus2.check_person_address(p_rec.delegate_person_id,
                                            p_rec.person_address_id,
                                            'Delegate');
          --
        elsif p_rec.corespondent = 'C' then
          --
          -- Check contact has a valid address in per_addresses
          --
          ota_tdb_bus2.check_person_address(p_rec.sponsor_person_id,
                                            p_rec.person_address_id,
                                            'Contact');
          --
        end if;
      end if;
    end if;
  end if;
  --
  -- Check that the delegate contact and sponsor contact exist for
  -- the customer for an external enrollment
  --
  if l_customer_id_changed         or
     l_delegate_contact_id_changed or
     l_contact_id_changed          then
       ota_tdb_bus2.check_customer_details(p_rec.customer_id,
                              p_rec.delegate_contact_id,
                              p_rec.contact_id);
  end if;
  --
  -- Check if organization details need to be checked
  --
  if l_delegate_person_id_changed or
     l_sponsor_person_id_changed or
     l_organization_id_changed then
       ota_tdb_bus2.check_organization_details  (p_rec.organization_id,
                                         p_rec.delegate_person_id,
                                         p_rec.delegate_assignment_id,
                                         p_rec.sponsor_person_id,
                                         p_rec.sponsor_assignment_id);
  end if;
  --
  --
  -- check that the number of places is one for a delegate
  --
  if l_delegate_person_id_changed or
     l_delegate_contact_id_changed or
     l_number_of_places_changed then
  --
    check_places (p_rec.delegate_contact_id, p_rec.number_of_places);
    check_places (p_rec.delegate_person_id, p_rec.number_of_places);
  --
  end if;
  --
  --
  -- check that the booking has not already been made
  --
  if l_customer_id_changed         or
     l_organization_id_changed     or
     l_event_id_changed            or
     l_delegate_person_id_changed  or
     l_delegate_contact_id_changed or
     l_status_type_id_changed      then
  --
    check_unique_booking (p_rec.customer_id,
                          p_rec.organization_id,
                          p_rec.event_id,
                          p_rec.delegate_person_id,
                          p_rec.delegate_contact_id,
                          p_rec.booking_id);
  --
  end if;
  --
  --
  -- check that if the booking is for a programme member then the parent has
  -- already been booked
  --
  if l_customer_id_changed or
     l_organization_id_changed or
     l_event_id_changed or
     l_delegate_person_id_changed or
     l_delegate_contact_id_changed then
  --
    check_programme_member (p_rec.event_id,
                            p_rec.customer_id,
                            p_rec.organization_id,
                            p_rec.delegate_person_id,
                            p_rec.delegate_contact_id,
                            l_event_record_use,
                            p_rec.booking_id);
  --
  end if;
  --
  --
  -- check that the business group of the activity version being booked is
  -- the same
  --
  if l_business_group_id_changed or
     l_event_id_changed then
  --
    check_event_business_group (p_rec.business_group_id,
                                p_rec.event_id,
                                l_event_record_use);
  --
  end if;
  --
  --
  -- check that the successful attendance flag is only set for confirmed
  -- bookings
  --
  if l_attendance_flag_changed or
     l_status_type_id_changed then
  --
    check_attendance (p_rec.successful_attendance_flag,
                      p_rec.booking_status_type_id);
  --
  end if;
  --
  --
  -- check that the priority is within the domain 'Priority Level'
  --
  if l_booking_priority_changed and p_rec.booking_priority is not null then
  --
    ota_general.check_domain_value ('PRIORITY_LEVEL', p_rec.booking_priority);
  --
  end if;
  --
  --
  -- check that the source is within the domain 'Booking Source'
  --
  if l_source_of_booking_changed and p_rec.source_of_booking is not null then
  --
    ota_general.check_domain_value ('BOOKING_SOURCE', p_rec.source_of_booking);
  --
  end if;
  --
  --
  -- check that the business group of the booking status type is the same
  --
  if l_business_group_id_changed or
     l_status_type_id_changed then
  --
    check_type_business_group (p_rec.business_group_id,
                               p_rec.booking_status_type_id);
  --
  end if;
  --
  --
  -- check that the failure reason is within the domain 'Delegate Failure
  -- Reason'
  --
  if l_failure_reason_changed and p_rec.failure_reason is not null then
  --
    ota_general.check_domain_value ('DELEGATE_FAILURE_REASON',
                                   p_rec.failure_reason);
  --
  end if;
  --
  --
  -- check that the reason for failure is not entered for a successful
  -- delegate
  --
  if l_failure_reason_changed or
     l_attendance_flag_changed then
  --
    check_failure (p_rec.failure_reason,
                   p_rec.successful_attendance_flag);
  --
  end if;
  --

  --
  -- check that the event is still open for bookings
  --
  if l_event_id_changed or
     l_date_booking_placed_changed then
  --
    check_closed_event (p_rec.event_id,
                        p_rec.date_booking_placed,
                        l_event_record_use);
  --
  end if;
  --
  --
  -- check that the delegate is eligible to be booked on to the event
  --
  /*  Moved the validation to ota_tdb_api_upd2
  if l_event_id_changed or
     l_customer_id_changed or
     l_organization_id_changed or
     l_delegate_person_id_changed or
     l_delegate_ass_changed then
  --
    check_delegate_eligible (p_rec.event_id,
                             p_rec.customer_id,
              p_rec.delegate_contact_id,
                             p_rec.organization_id,
                             p_rec.delegate_person_id,
                             p_rec.delegate_assignment_id);
  --
  end if;
  */
  --
  --
  check_constraints
        (
        p_rec.internal_booking_flag,
        p_rec.successful_attendance_flag
        );
  --
  chk_line_id(p_rec.booking_id
                                ,p_rec.line_id
                                ,p_rec.org_id);

   if l_old_event_id_changed  then
      ota_tdb_bus2.chk_old_event_changed
                (p_rec.booking_id
            ,p_rec.old_event_id);
   end if;
/* Enhancement 1823602*/
IF p_rec.line_id IS NOT NULL THEN
   ota_tdb_bus2.check_commitment_date(p_rec.line_id,
                                      p_rec.event_id);
END IF;
/*Enhancement 1823602*/
/* Bug 4401588 */
  IF p_rec.line_id IS NOT NULL AND l_number_of_places_changed THEN
    fnd_message.set_name ('OTA','OTA_443887_TDB_OM_CHK_UPD');
    fnd_message.raise_error;
  END IF;

/* Bug 4401588*/
/* bug no 4509873 */
-- Commented for bug#4874734
 -- IF p_rec.line_id is not null then
     OPEN get_inv_id (ota_tdb_shd.g_old_rec.event_id);
     FETCH get_inv_id INTO l_old_inv_id;
     CLOSE get_inv_id ;
     OPEN get_inv_id (p_rec.event_id);
     FETCH get_inv_id INTO l_new_inv_id;
     CLOSE get_inv_id ;
     IF l_new_inv_id <> l_old_inv_id then
       fnd_message.set_name ('OTA','OTA_443905_TDB_TRN_ENR_DIF_INV');
       fnd_message.raise_error;
     END IF;
  --END IF;

  --Added for bug#4650304
  IF l_status_type_id_changed THEN
    check_online_enr_change(
         p_booking_id => p_rec.booking_id
        ,p_event_id => p_rec.event_id
        ,p_booking_status_type_id => p_rec.booking_status_type_id
        ,p_content_player_status => p_rec.content_player_status
        ,p_delegate_person_id => p_rec.delegate_person_id
        ,p_delegate_contact_id => p_rec.delegate_contact_id);
  END IF;

  -- Added for bug#4606760
  IF ((l_delegate_person_id_changed OR l_event_id_changed)
       AND p_rec.delegate_person_id IS NOT NULL) THEN
       ota_tdb_bus.check_secure_event(p_rec.event_id, p_rec.delegate_person_id);

  END IF;

  -- Bug#5614187 - Enrollments can not be moved from cancelled status after enrollment
  -- period is over.
 IF l_status_type_id_changed THEN
      ota_utility.get_booking_status_type( p_status_type_id => ota_tdb_shd.g_old_rec.booking_status_type_id,
                                           p_type => l_status_type) ;
      IF l_status_type = 'C' THEN
	     ota_utility.get_booking_status_type( p_status_type_id => p_rec.booking_status_type_id,
                                                  p_type => l_status_type) ;
             IF l_status_type <> 'C' THEN
	       l_status_type := ota_tdb_bus.check_enrollment_dates(p_rec.event_id, sysdate);
	     END IF;
      END IF;
 END IF;

/* bug no 4509873 */
  --Bug 3619960
  ota_tdb_bus.chk_df(p_rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Controls the validation execution on delete.
--
Procedure delete_validate(p_rec in ota_tdb_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Check that booking id is not referenced in ota_training_plan_costs
  --
  check_training_plan_costs(p_rec.booking_id);
  --
  -- Check if Line id is not null
  chk_Order_line_exist(ota_tdb_shd.g_old_rec.line_id
                                ,ota_tdb_shd.g_old_rec.org_id) ;
  --
  -- check that no resources exist for the booking
  --
  check_resources (p_rec.booking_id);
  --
  -- check that no finance line exist for the booking
  --
  check_finance_lines (p_rec.booking_id);
  --
  -- Check if we are deleting a program enrollment,
  -- there are no existing program member
  -- enrollments
  --
  check_pmm_enrollments;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ota_tdb_bus;

/
