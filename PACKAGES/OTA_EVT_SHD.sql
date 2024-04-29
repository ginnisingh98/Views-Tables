--------------------------------------------------------
--  DDL for Package OTA_EVT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EVT_SHD" AUTHID CURRENT_USER as
/* $Header: otevt01t.pkh 120.0.12010000.2 2009/05/05 12:20:45 pekasi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
  (
  event_id                          number(9),
  vendor_id                         number(15),
  activity_version_id               number(9),
  business_group_id                 number(9),
  organization_id                   number(9),
  event_type                        varchar2(30),
  object_version_number             number(9),        -- Increased length
  title                             varchar2(80),
  budget_cost                       number,
  actual_cost                       number,
  budget_currency_code              varchar2(30),
  centre                            varchar2(30),
  comments                          varchar2(2000),
  course_end_date                   date,
  course_end_time                   varchar2(9),      -- Increased length
  course_start_date                 date,
  course_start_time                 varchar2(9),      -- Increased length
  duration                          number,
  duration_units                    varchar2(30),
  enrolment_end_date                date,
  enrolment_start_date              date,
  language_id                       number(9),
  user_status                       varchar2(80),
  development_event_type            varchar2(30),
  event_status                      varchar2(30),
  price_basis                       varchar2(30),
  currency_code                     varchar2(30),
  maximum_attendees                 number(9),
  maximum_internal_attendees        number(9),
  minimum_attendees                 number(9),
  standard_price                    number,
  category_code                     varchar2(30),
  parent_event_id                   number(9),
  book_independent_flag             varchar2(30),
  public_event_flag                 varchar2(30),
  secure_event_flag                 varchar2(30),
  evt_information_category          varchar2(30),
  evt_information1                  varchar2(150),
  evt_information2                  varchar2(150),
  evt_information3                  varchar2(150),
  evt_information4                  varchar2(150),
  evt_information5                  varchar2(150),
  evt_information6                  varchar2(150),
  evt_information7                  varchar2(150),
  evt_information8                  varchar2(150),
  evt_information9                  varchar2(150),
  evt_information10                 varchar2(150),
  evt_information11                 varchar2(150),
  evt_information12                 varchar2(150),
  evt_information13                 varchar2(150),
  evt_information14                 varchar2(150),
  evt_information15                 varchar2(150),
  evt_information16                 varchar2(150),
  evt_information17                 varchar2(150),
  evt_information18                 varchar2(150),
  evt_information19                 varchar2(150),
  evt_information20                 varchar2(150),
  project_id			            number(15),
  owner_id					        number(10),
  line_id				            number(15),
  org_id					        number(15),
  training_center_id                number(15),
  location_id                       number(15),
  offering_id				        number,
  timezone					        varchar2(30),
  parent_offering_id                number,
  data_source                       varchar2(30),
  event_availability                varchar2(30)
  );
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_old_rec  g_rec_type;                            -- Global record definition
g_api_dml  boolean;                               -- Global api dml status
g_tab_nam constant varchar2(30) := 'OTA_EVENTS' ;
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return the current g_api_dml private global
--   boolean status.
--   The g_api_dml status determines if at the time of the function
--   being executed if a dml statement (i.e. INSERT, UPDATE or DELETE)
--   is being issued from within an api.
--   If the status is TRUE then a dml statement is being issued from
--   within this entity api.
--   This function is primarily to support database triggers which
--   need to maintain the object_version_number for non-supported
--   dml statements (i.e. dml statement issued outside of the api layer).
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   None.
--
-- Post Success:
--   Processing continues.
--   If the function returns a TRUE value then, dml is being executed from
--   within this api.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Pre Conditions:
--   1) Either hr_api.check_integrity_violated,
--      hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--      hr_api.unique_integrity_violated has been raised with the subsequent
--      stripping of the constraint name from the generated error message
--      text.
--   2) Standalone validation test which correspond with a constraint error.
--
-- In Arguments:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the
--   current row from the database for the specified primary key
--   provided that the primary key exists and is valid and does not
--   already match the current g_old_rec. The function will always return
--   a TRUE value if the g_old_rec is populated with the current row.
--   A FALSE value will be returned if all of the primary key arguments
--   are null.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec
--   is current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_event_id                           in number,
  p_object_version_number              in number
  )      Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Lck process has two main functions to perform. Firstly, the row to be
--   updated or deleted must be locked. The locking of the row will only be
--   successful if the row is not currently locked by another user.
--   Secondly, during the locking of the row, the row is selected into
--   the g_old_rec data structure which enables the current row values from the
--   server to be available to the api.
--
-- Pre Conditions:
--   When attempting to call the lock the object version number (if defined)
--   is mandatory.
--
-- In Arguments:
--   The arguments to the Lck process are the primary key(s) which uniquely
--   identify the row and the object version number of row.
--
-- Post Success:
--   On successful completion of the Lck process the row to be updated or
--   deleted will be locked and selected into the global data structure
--   g_old_rec.
--
-- Post Failure:
--   The Lck process can fail for three reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_Api.Object_Locked exception.
--   2) The row which is required to be locked doesn't exist in the HR Schema.
--      This error is trapped and reported using the message name
--      'HR_7220_INVALID_PRIMARY_KEY'.
--   3) The row although existing in the HR Schema has a different object
--      version number than the object version number specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--
-- Developer Implementation Notes:
--   For each primary key and the object version number arguments add a
--   call to hr_api.mandatory_arg_error procedure to ensure that these
--   argument values are not null.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_event_id                           in number,
  p_object_version_number              in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute arguments into the record
--   structure g_rec_type.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Arguments:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_event_id                      in number,
	p_vendor_id                     in number,
	p_activity_version_id           in number,
	p_business_group_id             in number,
	p_organization_id               in number,
	p_event_type                    in varchar2,
	p_object_version_number         in number,
	p_title                         in varchar2,
    p_budget_cost                   in number,
    p_actual_cost                   in number,
    p_budget_currency_code          in varchar2,
	p_centre                        in varchar2,
	p_comments                      in varchar2,
	p_course_end_date               in date,
	p_course_end_time               in varchar2,
	p_course_start_date             in date,
	p_course_start_time             in varchar2,
	p_duration                      in number,
	p_duration_units                in varchar2,
	p_enrolment_end_date            in date,
	p_enrolment_start_date          in date,
	p_language_id                   in number,
	p_user_status                   in varchar2,
	p_development_event_type        in varchar2,
	p_event_status                  in varchar2,
	p_price_basis                   in varchar2,
	p_currency_code                 in varchar2,
	p_maximum_attendees             in number,
	p_maximum_internal_attendees    in number,
	p_minimum_attendees             in number,
	p_standard_price                in number,
	p_category_code                 in varchar2,
	p_parent_event_id               in number,
    p_book_independent_flag         in varchar2,
    p_public_event_flag             in varchar2,
    p_secure_event_flag             in varchar2,
	p_evt_information_category      in varchar2,
	p_evt_information1              in varchar2,
	p_evt_information2              in varchar2,
	p_evt_information3              in varchar2,
	p_evt_information4              in varchar2,
	p_evt_information5              in varchar2,
	p_evt_information6              in varchar2,
	p_evt_information7              in varchar2,
	p_evt_information8              in varchar2,
	p_evt_information9              in varchar2,
	p_evt_information10             in varchar2,
	p_evt_information11             in varchar2,
	p_evt_information12             in varchar2,
	p_evt_information13             in varchar2,
	p_evt_information14             in varchar2,
	p_evt_information15             in varchar2,
	p_evt_information16             in varchar2,
	p_evt_information17             in varchar2,
	p_evt_information18             in varchar2,
	p_evt_information19             in varchar2,
	p_evt_information20             in varchar2,
    p_project_id 	                in number,
	p_owner_id				        in number,
    p_line_id				        in number,
	p_org_id				        in number,
    p_training_center_id            in number,
    p_location_id 			        in number,
    p_offering_id			        in number,
	p_timezone				        in varchar2,
    p_parent_offering_id            in number,
	p_data_source   		        in varchar2,
	p_event_availability            in varchar2
    	)
	Return g_rec_type;
--
-- ----------------------------------------------------------------------------
-- -------------------------< FETCH_EVENT_DETAILS >----------------------------
-- ----------------------------------------------------------------------------
--
--      Populates the g_fetched_rec record with the specified event's details.
--      These details are then used throughout the package in checks etc.
--
procedure FETCH_EVENT_DETAILS (
        P_EVENT_ID                      number,
        P_EVENT_EXISTS              out nocopy boolean
        );
--
-- ----------------------------------------------------------------------------
-- -------------------------< CHECK_PROGRAMME_MEMBERS >------------------------
-- ----------------------------------------------------------------------------
--
--      Checks whether all programme members are normal status
--
function CHECK_PROGRAMME_MEMBERS (P_EVENT_ID in number) return boolean;
--
-- ----------------------------------------------------------------------------
-- ---------------------------< GET_EVENT_DETAILS >----------------------------
-- ----------------------------------------------------------------------------
--
--      A public procedure for other objects to use to return a single,
--      complete event row.
--
procedure GET_EVENT_DETAILS (
        P_EVENT_ID                      number,
        P_EVENT_REC                 out nocopy OTA_EVT_SHD.g_rec_type,
        P_EVENT_EXISTS              out nocopy boolean
        );
--
-- ----------------------------------------------------------------------------
-- ---------------------------< GET_COURSE_DATES >-----------------------------
-- ----------------------------------------------------------------------------
--
--      Returns the course dates of a specified event.
--
procedure GET_COURSE_DATES (
        P_EVENT_ID                                   in number,
        P_COURSE_START_DATE                      in out nocopy date,
        P_COURSE_END_DATE                        in out nocopy date
        );
--
-- ----------------------------------------------------------------------------
-- -----------------------< CHECK_EVENT_IS_VALID >-----------------------------
-- ----------------------------------------------------------------------------
--
--      Raises an error if the event ID used does not exist on OTA_EVENTS.
--
procedure CHECK_EVENT_IS_VALID (
        P_EVENT_ID                   in number
        );
--
-- ----------------------------------------------------------------------------
-- ---------------------< RESOURCE_BOOKING_FLAG >------------------------------
-- ----------------------------------------------------------------------------
--
--	Returns 'Y' if event has any resources booked to it.
--
function RESOURCE_BOOKING_FLAG (
	P_EVENT_ID		     in	number
	) return varchar2;
--
pragma restrict_references (RESOURCE_BOOKING_FLAG, WNDS, WNPS);
--
-- ----------------------------------------------------------------------------
-- -----------------------< PUBLIC_EVENT_FLAG >--------------------------------
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- -----------------------< PUBLIC_EVENT_FLAG >--------------------------------
-- ----------------------------------------------------------------------------
--
--      Returns OTA_EVT_API.EVENT_IS_PUBLIC as a Y/N varchar2 for use in
--      views.
--
function PUBLIC_EVENT_FLAG (
        P_EVENT_ID                   in number
	) return varchar2;
--
pragma restrict_references (PUBLIC_EVENT_FLAG, WNDS, WNPS);
--
-- ----------------------------------------------------------------------------
-- -----------------------< INVOICED_AMOUNT_TOTAL >----------------------------
-- ----------------------------------------------------------------------------
--
--      Returns the total invoiced amount for an event.
--
function INVOICED_AMOUNT_TOTAL (
        P_EVENT_ID                                   in number
	) return number;
--
pragma restrict_references (INVOICED_AMOUNT_TOTAL, WNDS, WNPS);
--
end ota_evt_shd;

/
