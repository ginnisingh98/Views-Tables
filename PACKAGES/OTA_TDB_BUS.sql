--------------------------------------------------------
--  DDL for Package OTA_TDB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TDB_BUS" AUTHID CURRENT_USER as
/* $Header: ottdb01t.pkh 120.5.12010000.2 2009/08/13 09:15:22 smahanka ship $ */
--
--
--
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
  (
  p_rec in ota_tdb_shd.g_rec_type);


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
  );
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
  ) RETURN varchar2;
--
-- Added For Bug 4649610

-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- PUBLIC
-- Function to return concatenated full_name
--
function get_full_name (p_last_name in varchar2
                       ,p_title     in varchar2
                       ,p_first_name in varchar2) return varchar2;
pragma restrict_references (get_full_name, WNPS,WNDS);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_full_name >----------------------------|
-- ----------------------------------------------------------------------------
-- PUBLIC
-- Function to return legislative concatenated full_name
--
function get_full_name
  (p_last_name              in  varchar2
  ,p_title                  in  varchar2
  ,p_first_name             in  varchar2
  ,p_legislation_code       in  varchar2
  ,p_last_name_alt          in  varchar2  DEFAULT null
  ,p_first_name_alt         in  varchar2  DEFAULT null
  ) return varchar2;

pragma restrict_references (get_full_name, WNDS, WNPS);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_full_name >----------------------------|
-- |----------------- version with legislative check  ------------------------|
-- ----------------------------------------------------------------------------
-- PUBLIC
-- Function to return legislative concatenated full_name
--
function get_full_name
  (p_last_name              in  varchar2
  ,p_title                  in  varchar2
  ,p_first_name             in  varchar2
  ,p_business_group_id      in  number
  ,p_last_name_alt          in  varchar2  DEFAULT null
  ,p_first_name_alt         in  varchar2  DEFAULT null
  ) return varchar2;

pragma restrict_references (get_full_name, WNDS, WNPS);
--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- PUBLIC
-- Function to check if an assignment is ok
--
function assignment_ok (p_person_type         in varchar2,
         p_assignment_id       in number,
         p_event_id            in number,
         p_date_booking_placed in date) return rowid;
pragma restrict_references (assignment_ok,WNPS,WNDS);
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
Function booking_status_type (p_booking_status_type_id in number)
               return varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< booking_status_type >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Booking Status Type
--
--              Returns the type of a booking status id
--
Procedure check_places (p_delegate_person_id  in number,
                        p_number_of_places    in number);
--
--
-- --------------------------------------------------------------------
-- |------------------------< get_event_type>-------------------------|
-- --------------------------------------------------------------------
--
-- PUBLIC
-- Description: get_event_type
--
--              Returns the event_type for a given event
--
Function get_event_type (p_event_id in number) return varchar2;
pragma restrict_references (get_event_type,WNPS,WNDS);
-- --------------------------------------------------------------------
-- |------------------------< check_person>---------------------------|
-- --------------------------------------------------------------------
--
-- PUBLIC
-- Description: check_person
--
--              Checks that a given person is active on a given date
--
function check_person(p_person_id in number,
            p_date in date,
                      p_person_type in varchar2,
                      p_person_address_type in varchar2) return boolean;
--
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
                                p_booking_id          in number);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_failure >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check Failure
--
--              Checks that the reason for failure is not specified for a
--              successful delegate
--
Procedure check_failure (p_failure_reason             in varchar2,
                         p_successful_attendance_flag in varchar2);
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_attendance >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check Attendance
--
--              Checks that successful attendance is only valid for confirmed
--              bookings
--
Procedure check_attendance (p_successful_attendance_flag  in varchar2,
                            p_booking_status_type_id      in number);
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_internal_booking >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check Internal Booking
--
--              Checks that when the internal booking flag is checked that it
--              doesn't exceed the event max internal limit.
--
Procedure check_internal_booking (p_event_id         in number,
                                  p_number_of_places in number,
              p_booking_id       in number);
--
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_type_business_group >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check Type Business Group
--
--              Checks that the business group of the booking is the same as
--              that of the booking status type being used
--
Procedure check_type_business_group (p_business_group_id      in number,
                                     p_booking_status_type_id in number);
--
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
Function event_place_needed(p_booking_status_type_id in number) return number;
pragma restrict_references (event_place_needed,WNPS,WNDS);
--
-- ----------------------------------------------------------------------------
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
              p_event_record_use   in varchar2 default 'NEW EVENT');
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_resources >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check resources
--
--              Checks if any resources exists for the booking
--
Procedure check_resources (p_booking_id  in number);
--
-- ---------------------------------------------------------------------------
-- |-----------------------< check_training_plan_costs >----------------------|
-- ---------------------------------------------------------------------------
--
-- Description: Check Training Plan Cost records
--
--              Checks if any training plan cost records exist for the booking
--
Procedure check_training_plan_costs(p_booking_id in number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_finance_lines >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check finance lines
--
--              Checks if any finance lines exists for the booking
--
Procedure check_finance_lines (p_booking_id  in number);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< booking_id_for >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Booking ID For
--
--              Returns the Booking Id for a given Organization-Event-Delegate
--              combination
--
Function booking_id_for (p_customer_id        in number,
          p_organization_id    in number,
                         p_event_id           in number,
                         p_person_id          in number) Return number;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Finance Line Exists >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Checks whether a finance line exists for a particular booking_Id.
--
--
Function Finance_Line_Exists (p_booking_id in number
              ,p_cancelled_flag in varchar2)
Return boolean;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< internal_booking >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Internal Booking
--
--              Checks if the booking is internal then the person (Contact or
--              Delegate) is also internal
--
Function internal_booking (p_internal_booking_flag  in varchar2,
                           p_person_id              in number,
                           p_date_booking_placed    in date)
Return boolean;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_delegate_eligible >-----------------------|
-- ----------------------------------------------------------------------------
--
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
               p_delegate_assignment_id in number);
--
--
--
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
                            p_booking_status_type_id in number   default null,
                            p_status_type            in varchar2 default null,
                            p_usage_type             in varchar2 default null,
                            p_booking_id             in number   default null)
Return number;
--
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
Function places_allowed (p_event_id in number,
                         p_all_or_internal in varchar2) Return number;
--
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
              p_all_or_internal        in varchar2 default 'ALL',
              p_booking_id             in number   default NULL);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< ota_letter_lines >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure ota_letter_lines (p_booking_id             in number,
                            p_booking_status_type_id in number,
                            p_event_id               in number,
                            p_delegate_person_id in number default null);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< Check_programme_member >-------------------------|
-- ----------------------------------------------------------------------------
--
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
              p_event_record_use    in varchar2 default 'NEW EVENT',
              p_booking_id          in number   default null);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< enrolling >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:  Enrolling
--
--               Checks if the given event is enrolling
--
Function enrolling (p_event_id            in number,
                    p_event_record_use    in varchar2 default 'NEW EVENT')
return BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< enrolling_on_date >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:  Enrolling On Date
--
--               Checks if the given event is enrolling on the given date
--
Function enrolling_on_date
                   (p_event_id            in number,
                    p_date                in date,
                    p_event_record_use    in varchar2 default 'NEW EVENT')
return BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< closed_event >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Closed Event
--
--              Checks if the given event is closed
--
Function closed_event (p_event_id         in number,
                       p_event_record_use in varchar2 default 'NEW EVENT')
return BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_closed_event >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Check Closed Event
--
--              Checks that the event to which the booking is being made is
--              not closed
--
Procedure check_closed_event
             (p_event_id            in number,
              p_date_booking_placed in date,
              p_event_record_use    in varchar2 default 'NEW EVENT');
--
-- ----------------------------------------------------------------------------
-- |---------------------< maintain_status_history >--------------------------|
-- ----------------------------------------------------------------------------
--
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
                                   p_date_booking_placed     in date);
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< get_event>-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Get Event
--
--              Retrieves the details associated with the event required for
--              subsequent checks in the package and stores the values in
--              the global record g_event_rec
--
Procedure get_event (p_event_id   in number,
                     p_record_use in varchar2 default 'NEW EVENT');
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_constraints >---------------------------|
-- ----------------------------------------------------------------------------
Procedure check_constraints
   (
   p_internal_booking_flag           in varchar2,
   p_successful_attendance_flag      in varchar2
   );
--
--
-- ----------------------------------------------------------------------------
-- |----------------< check_program_member_enrollments >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Determines whether a person is enrolled onto program
--              member events before their program enrollment can be
--              deleted.
--
Procedure check_pmm_enrollments;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_line_id  >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_line_id
  (
   p_booking_id                in number
   ,p_line_id        in number
   ,p_org_id         in number
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_order_line_exist  >---------------------|
-- ----------------------------------------------------------------------------
Procedure chk_Order_line_exist
  (p_line_id         in number
   ,p_org_id         in number);
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_status_changed  >----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_status_changed
  (p_line_id         in number
   ,p_status_type_id    in number
   ,p_daemon_type       in varchar2
   ,p_event_id       in number
   ,p_booking_id        in number
   ,p_org_id         in number
      );

--
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  check_enrollment_dates  >----------------------|
-- ----------------------------------------------------------------------------
Function check_enrollment_dates
                   (p_event_id            in number,
                    p_date                in date,
		    p_throw_error IN VARCHAR2 DEFAULT 'Y')
return VARCHAR2;
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
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate(
                    p_rec in ota_tdb_shd.g_rec_type,
           p_enrollment_type in varchar2
                          );
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
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(
                    p_rec in ota_tdb_shd.g_rec_type,
           p_enrollment_type in varchar2
                          );
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
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ota_tdb_shd.g_rec_type);
--
-- Added for bug#4606760
PROCEDURE check_secure_event(p_event_id IN NUMBER
                            ,p_delegate_person_id IN NUMBER);
end ota_tdb_bus;

/
