--------------------------------------------------------
--  DDL for Package OTA_EVT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EVT_BUS" AUTHID CURRENT_USER as
/* $Header: otevt01t.pkh 120.0.12010000.2 2009/05/05 12:20:45 pekasi ship $ */
--
--added for eBS by asud
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
--    The primary key identified by p_event_id
--     already exists.
--
--  In Arguments:
--    p_event_id
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
  (p_event_id                             in number
  ,p_associated_column1                   in varchar2 default null
  );
--added for eBS by asud
--
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
  ) RETURN varchar2;
--
-- Added For Bug 4348949


-- ----------------------------------------------------------------------------
-- -------------------------< UNIQUE_EVENT_TITLE >-----------------------------
-- ----------------------------------------------------------------------------
--
--      Returns TRUE if the event has a title which is unique within its
--      business group. If the event id is not null, then the check avoids
--      comparing the title against itself. Titles are compared regardless
--      of case.
--
function UNIQUE_EVENT_TITLE (
        P_TITLE				     in varchar2,
        P_BUSINESS_GROUP_ID		     in number,
        P_PARENT_EVENT_ID		     in number,
        P_EVENT_ID			     in number  default null
        ) return boolean;
--
-- ----------------------------------------------------------------------------
-- -------------------------< RESOURCES_AFFECTED >-----------------------------
-- ----------------------------------------------------------------------------
--
--      Returns TRUE if the event time has changed so that resources are
--      outside the times of the event.
--
function RESOURCES_AFFECTED (
	P_EVENT_ID          in number,
        P_START_TIME        in varchar2,
        P_END_TIME          in varchar2,
        P_COURSE_START_DATE in date,
	P_COURSE_END_DATE   in date
	) return boolean;
--
-- ----------------------------------------------------------------------------
-- ----------------------------< STATUS_CHANGE_NORMAL >------------------------
-- ----------------------------------------------------------------------------
--
--      Returns true if a program member exists that is wait_listed
--
function status_change_normal (p_event_id in number) return boolean;
-- ----------------------------------------------------------------------------
-- -------------------------< ENROLLMENT_DATES_EVENT_VALID >-------------------
-- ----------------------------------------------------------------------------
--
--      Checks if enrollment dates are valid when matched against
--      the start and end dates of the event.
--
Procedure enrollment_dates_event_valid (p_enrollment_start_date in out nocopy date,
			                p_enrollment_end_date   in out nocopy date,
                                        p_course_start_date    in out nocopy date,
			                p_course_end_date      in out nocopy date);
-- ----------------------------------------------------------------------------
-- ----------------------------< CHECK_EVENT_STATUS >--------------------------
-- ----------------------------------------------------------------------------
--
--      Checks if event status is planned or event type is SELFPACED, in which
--      case you can have an event that has a null end date, otherwise an event
--      must have an end date.
--
Procedure check_event_status (p_event_status    in varchar2,
       			              p_course_end_date in date,
                              p_event_type in varchar2);
--
-- ----------------------------------------------------------------------------
-- -------------------------< ENROLLMENT_DATES_ARE_VALID >---------------------
-- ----------------------------------------------------------------------------
--
--      Checks if enrollment dates are valid against the activity start
--      and end dates.
--
/*--changes made for eBS by asud
Procedure enrollment_dates_are_valid( p_activity_version_id   in number,
			   	      p_enrollment_start_date in date,
				      p_enrollment_end_date   in date);
*/  --changes made for eBS by asud
Procedure enrollment_dates_are_valid( p_parent_offering_id   in number,
			   	      p_enrollment_start_date in date,
				      p_enrollment_end_date   in date);
--
-- ----------------------------------------------------------------------------
-- --------------------------< GET_PROG_TITLE >--------------------------------
-- ----------------------------------------------------------------------------
--
--	Returns Program Title if an event is part of a program
--
function GET_PROG_TITLE (
	P_EVENT_ID		     in	number
	) return varchar2;
--
pragma restrict_references (GET_PROG_TITLE, WNDS, WNPS);
-- ----------------------------------------------------------------------------
-- -------------------------< CHECK_ENROLLMENT_DATES >-----------------------------
-- ----------------------------------------------------------------------------
--
--      Used to call error messages if an error occurs.
--
Procedure check_enrollment_dates
  (
   p_par_start    in  date
  ,p_par_end      in  date
  ,p_child_start  in  date
  ,p_child_end    in  date
  );
--
-- ----------------------------------------------------------------------------
-- -------------------------< ENROLLMENT_AFTER_EVENT_END >---------------------
-- ----------------------------------------------------------------------------
--
--      Checks if enrollment end date is after event end date.
--
Function enrollment_after_event_end(
			            p_enrollment_end_date   in out nocopy date,
			            p_course_end_date      in out nocopy date)
				    return boolean;
--
--
-- ----------------------------------------------------------------------------
-- -------------------------< COURSE_DATES_ARE_VALID >-------------------------
-- ----------------------------------------------------------------------------
--
--      Check course dates are valid when compared to the activity
--      start date.
--
/*--changes made for eBS by asud
procedure COURSE_DATES_ARE_VALID (p_activity_version_id        in number,
                                  p_course_start_date          in date,
                                  p_course_end_date            in date,
                                  p_event_status in varchar2);
*/--changes made for eBS by asud
procedure COURSE_DATES_ARE_VALID (p_parent_offering_id        in number,
                                  p_course_start_date          in date,
                                  p_course_end_date            in date,
                                  p_event_status in varchar2,
                                  p_event_type                 in varchar2);
-- ----------------------------------------------------------------------------
-- -------------------------< SESSION_VALID >----------------------------------
-- ----------------------------------------------------------------------------
--
--      Check session dates are still valid even if course start or end
--      dates have changed.
--
procedure SESSION_VALID (p_event_id        in number,
                         p_course_start_date          in date,
                         p_course_end_date            in date);


--
-- ----------------------------------------------------------------------------
-- -------------------------< CHANGE_TO_WAIT_STATUS >--------------------------
-- ----------------------------------------------------------------------------
--
--      Checks if an event can be changed to wait status, this depends if
--      any enrollments on the evnt have a status other than wait status.
--
function CHANGE_TO_WAIT_STATUS (p_business_group_id     in number,
                                p_event_id 		in number) return boolean;
--
-- ----------------------------------------------------------------------------
-- -----------------------< CHECK_TITLE_IS_UNIQUE >----------------------------
-- ----------------------------------------------------------------------------
--
--      Validates the uniqueness of the event title (ignoring case).
--
procedure CHECK_TITLE_IS_UNIQUE (
        P_TITLE				     in varchar2,
        P_BUSINESS_GROUP_ID		     in number,
        P_PARENT_EVENT_ID		     in number,
        P_EVENT_ID			     in number  default null,
        P_OBJECT_VERSION_NUMBER		     in number  default null
        );
--
-- ----------------------------------------------------------------------------
-- ---------------------< COURSE_DATES_SPAN_SESSIONS >-------------------------
-- ----------------------------------------------------------------------------
--
--      Returns TRUE if the course dates for an event still span the dates of
--      its sessions. This function is overloaded so that one can check either
--      a new session date is valid or that updates to the course dates will
--      not invalidate any sessions.
--
--      This version of the function checks that a new or updated session date
--
function COURSE_DATES_SPAN_SESSIONS (
        P_PARENT_EVENT_ID      	             in number,
        P_NEW_SESSION_DATE		     in date
        ) return boolean;
--
--      This version of the function checks that updated course dates do not
--      invalidate any of the event's sessions.
--
function COURSE_DATES_SPAN_SESSIONS (
        P_EVENT_ID			     in	number,
        P_COURSE_START_DATE		     in	date,
        P_COURSE_END_DATE		     in	date
	) return boolean;
--
-- ----------------------------------------------------------------------------
-- -----------------------< CHECK_UPDATED_COURSE_DATES >-----------------------
-- ----------------------------------------------------------------------------
--
procedure CHECK_UPDATED_COURSE_DATES (
        P_EVENT_ID                           in number,
        P_OBJECT_VERSION_NUMBER              in number,
        P_EVENT_TYPE                         in varchar2,
        P_COURSE_START_DATE                  in date,
        P_COURSE_END_DATE                    in date
	);
--
-- ----------------------------------------------------------------------------
-- ------------------------< CHECK_SESSION_WITHIN_COURSE >---------------------
-- ----------------------------------------------------------------------------
--
--      Checks that a session date lies between the course start and end dates
--      of its parent event.
--
procedure CHECK_SESSION_WITHIN_COURSE (
        P_EVENT_TYPE                         in varchar2,
        P_PARENT_EVENT_ID                    in number,
        P_COURSE_START_DATE                  in date,
        P_EVENT_ID                           in number default null,
        P_OBJECT_VERSION_NUMBER              in number default null
        );

--
-- ----------------------------------------------------------------------------
-- -----------------------< VALID_PARENT_EVENT >-------------------------------
-- ----------------------------------------------------------------------------
--
--      Returns TRUE if the parent event ID specified exists in the events
--      table, has the same business group as the child row and is a valid
--      parent for the event type specified.
--
function VALID_PARENT_EVENT (
        P_PARENT_EVENT_ID                    in number,
        P_BUSINESS_GROUP_ID                  in number,
        P_EVENT_TYPE                         in varchar2
        ) return boolean;
--
-- ----------------------------------------------------------------------------
-- -----------------------< CHECK_PARENT_EVENT_IS_VALID >----------------------
-- ----------------------------------------------------------------------------
--
procedure CHECK_PARENT_EVENT_IS_VALID (
        P_PARENT_EVENT_ID                    in number,
        P_BUSINESS_GROUP_ID                  in number,
        P_EVENT_TYPE                         in varchar2,
        P_EVENT_ID                           in number  default null,
        P_OBJECT_VERSION_NUMBER              in number  default null
        );
--
-- ----------------------------------------------------------------------------
-- -----------------------< CHECK_CHILD_ENTITIES >-----------------------------
-- ----------------------------------------------------------------------------
--
procedure CHECK_CHILD_ENTITIES (
        P_EVENT_ID	                     in number
        );
--
-- ----------------------------------------------------------------------------
-- -----------------------< CHECK_FOR_ST_FINANCE_LINES >-------------------------------
-- ----------------------------------------------------------------------------
--
--	This function checks to see if any 'ST' succesful Transferred finance Lines
--	which have not been cancelled exists for any booking within the Event.
--	Returns TRUE if FL exists.
--
function CHECK_FOR_ST_FINANCE_LINES (
        P_EVENT_ID                    in number
        ) return boolean;

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
				p_course_start_date in date);

-- ----------------------------------------------------------------------------
-- |---------------------------<  check_line_id  >---------------------------|
-- ----------------------------------------------------------------------------
--
--	This function checks to see if any the Line_id exists in
--	oe_order_lines table
--
--

Procedure check_line_id
  (p_event_id                in number
   ,p_line_id 			in number
   ,p_org_id			in number) ;


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
);
--
-- ----------------------------------------------------------------------------
-- |---------------------------<  chk_order_line_exist  >---------------------|
-- ----------------------------------------------------------------------------
-- Description : This procedure will be called by Delete_validate procedure. This
--               procedure will check whether order line exist or not.
Procedure chk_Order_line_exist
  (p_line_id 			in number
   ,p_org_id			in number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------<  chk_Training_center  >---------------------------|
-- ----------------------------------------------------------------------------
-- Description : This procedure will be called by Insert_validate procedure and
--               Update_validaate procedure. This
--               procedure will check whether Training center exist or not.
--
--
Procedure chk_Training_center
  (p_event_id		    in number,
   p_training_center_id     in number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------<  chk_location  >---------------------------|
-- ----------------------------------------------------------------------------
-- Description : This procedure will be called by Insert_validate procedure and
--               Update_validaate procedure. This
--               procedure will check whether Location exist or not.
--
Procedure Chk_location
  (p_event_id		in number,
   p_location_id 	      in number,
   p_training_center_id in number,
   p_course_end_date in date);

--
-- ----------------------------------------------------------------------------
-- |------------------------< check_unique_offering_id>------------------------|
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
p_offering_id  		    in number);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------< check_valid_activity_version_id>------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--Checks if the parent_offering_id belongs to the activity_version_id
--
--
Procedure chk_activity_version_id
(p_activity_version_id          in number,
 p_parent_offering_id  		    in number);

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
-- VT 05/06/97 #488173
Procedure insert_validate(p_rec in out nocopy ota_evt_shd.g_rec_type);
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
-- VT 05/06/97 #488173
Procedure update_validate(p_rec in out nocopy ota_evt_shd.g_rec_type);
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
Procedure delete_validate(p_rec in ota_evt_shd.g_rec_type);

end ota_evt_bus;

/
