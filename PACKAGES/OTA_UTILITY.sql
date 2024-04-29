--------------------------------------------------------
--  DDL for Package OTA_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_UTILITY" AUTHID CURRENT_USER as
/* $Header: ottomint.pkh 120.20.12010000.10 2009/08/31 13:49:06 smahanka ship $ */


function get_resource_count(peventid number)
return varchar2;

function is_con_prog_periodic(p_name in varchar2)
return boolean;

Function get_delivery_method (p_offering_id in number)
return varchar2;

Function get_test_time(p_lo_time number)
return varchar2;

function get_default_comp_upd_level(p_obj_id in number,
                                    p_obj_type varchar2)
return varchar2 ;

-- ----------------------------------------------------------------
-- ------------------<get_session_count >--------------------
-- ----------------------------------------------------------------
function get_session_count(peventid number)
return varchar2;

-- ----------------------------------------------------------------
-- ------------------<get_child_count >----------------------
-- ----------------------------------------------------------------
function get_child_count(p_object_id   IN NUMBER,
                         p_object_type IN VARCHAR2)
return varchar2;

-- ----------------------------------------------------------------------------
-- |-----------------------------< ignore_dff_validation >---------------------------|
-- ----------------------------------------------------------------------------
Procedure ignore_dff_validation(p_dff_name in varchar2);
-- ----------------------------------------------------------------------------
-- |-----------------------------< GET_DESCIRPTION >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to retrieve enrollment and event information
--   for AR interface.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_line_id,
--   p_uom
--
-- Out Arguments:
--   p_description
--   p_course_end_date
--   e_return_status
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

Procedure GET_DESCRIPTION (p_line_id   in number,
                  p_uom       in varchar2,
                  x_description out nocopy varchar2,
                  x_course_end_date out nocopy date,
                  x_return_status out nocopy varchar2);



-- ----------------------------------------------------------------------------
-- |------------------------< get_invoice_rule  >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  is used to retrieve invoicing rule for Order Line.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_line_id
--
-- Out Argument
--  p_invoice_rule
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE GET_INVOICE_RULE
(
p_line_id      IN    NUMBER,
p_invoice_rule  OUT NOCOPY   VARCHAR2
);

-- ----------------------------------------------------------------------------
-- |----------------------< get_booking_status_type  >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will retrieve enrollment Status Type.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_status_type_id,
--
-- Out Arguments:
--   p_type
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------


PROCEDURE get_booking_status_type(
      p_status_type_id IN number,
      p_type OUT NOCOPY Varchar2) ;

-- ----------------------------------------------------------------------------
-- |----------------------< get_booking_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will retrieve enrollment Status.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_status_type_id,
--
-- Out Arguments:
--   p_status
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------


PROCEDURE get_booking_status(
      p_status_type_id IN number,
      p_status OUT NOCOPY Varchar2) ;

-- ----------------------------------------------------------------------------
-- |-----------------------------< Check_enrollment>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check whether Enrollment exist or not.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_line_id,
--
-- In Arguments:
--   x_valid,
--   x_return_status

-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
Procedure check_enrollment (p_line_id IN Number ,
            x_valid   OUT NOCOPY varchar2,
            x_return_status OUT NOCOPY varchar2 );
--

-- ----------------------------------------------------------------------------
-- |-----------------------------------< Check_event>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This Procedure  will be used to check Whether Event exist.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_line_id,
--
-- In Arguments:
--   x_valid,
--   x_return_status
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
 Procedure check_event (p_line_id IN Number,
            x_valid   OUT NOCOPY varchar2,
            x_return_status OUT NOCOPY varchar2 );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_lookup_meaning>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function  will be used to get lookup meaning.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_lookup_type
--   p_lookup_code
--   p_application_id
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

Function Get_Lookup_meaning(p_lookup_type  varchar2,
                            p_lookup_code  varchar2,
                p_application_id  number) return varchar2;

-- ----------------------------------------------------------------------------
-- |--------------------------------< CHECK_INVOICE >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a used to check the invoice of Order Line.
--
-- IN
-- p_line_id
-- p_org_id
--
-- OUT
-- p_exist
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE  CHECK_INVOICE (
p_Line_id   IN    NUMBER,
p_Org_id IN NUMBER,
p_exist OUT NOCOPY    VARCHAR2);


-- ----------------------------------------------------------------------------
-- |--------------------------------< CHECK_WF_STATUS>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function   will be a used to check the workflow status of Order Line.
--
-- IN
-- p_line_id
-- p_activity
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

FUNCTION  Check_wf_Status (
p_Line_id   IN    NUMBER,
p_activity varchar2)

return boolean;

-- ----------------------------------------------------------------------------
-- |-------------------------< other_bookings_clash >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Other Bookings Clash
--
--              Checks if the booking being made clashes with any other
--              bookings for the delegate
--              Note - bookings only clash if they are confirmed
--
Procedure other_bookings_clash (p_delegate_person_id     in varchar2,
                               p_delegate_contact_id    in varchar2,
                      p_event_id               in number,
                               p_booking_status_type_id in varchar2,
                               p_return_status out nocopy boolean,
                p_warn   out nocopy boolean) ;

-- ----------------------------------------------------------------
-- -------------------------<GET_BG_NAME >-------------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to get the Business Group Name for the
-- Organization_ID passed in.
-- IN
-- p_organization_id
--
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_bg_name (
p_organization_id IN NUMBER)
RETURN VARCHAR2;

-- ----------------------------------------------------------------
-- ---------------------<get_commitment_detail >-------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  This procedure calls the OM procedure which returns the commitment
-- details when a line_id and UOM is passed as a parameter.
-- IN          Reqd Type
-- p_line_id            NUMBER
-- OUT
-- x_commitment_id      NUMBER
-- x_commitment_number     VARCHAR2
-- x_commitment_start_date DATE
-- x_commitment_end_date   DATE
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
PROCEDURE get_commitment_detail
(p_line_id     IN NUMBER,
p_commitment_id    OUT NOCOPY NUMBER,
p_commitment_number OUT NOCOPY VARCHAR2,
p_commitment_start_date OUT NOCOPY DATE,
p_commitment_end_date OUT NOCOPY DATE
);

-- ----------------------------------------------------------------
-- ------------------<check_product_installed >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to check if a particular product is installed
-- or not.
-- IN
-- p_application_id
--
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION check_product_installed(p_application_id  IN  NUMBER)
RETURN VARCHAR2;
-- ----------------------------------------------------------------
-- ------------------<get_delivery_method >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the delivery method name
-- for the particular activity
-- IN
-- p_Activity_version_id
-- p_return_value
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_delivery_method(p_activity_version_id    IN  NUMBER,
              p_return_value     IN  VARCHAR2)
RETURN VARCHAR2;


-- ----------------------------------------------------------------
-- ------------------<students_on_waitlist >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the number of students waitlisted
-- in a particular event
-- IN
-- p_event_id
--
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION students_on_waitlist(p_event_id  IN  NUMBER)
RETURN NUMBER;

-- ----------------------------------------------------------------
-- ------------------<Place_on_waitlist >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to check the place on waitlist for a particular enrollment
-- in the particular event.
-- IN
-- p_event_id
-- p_booking_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION place_on_waitlist(p_event_id  IN  NUMBER,
            p_booking_id   IN  NUMBER)
RETURN NUMBER;

-- ----------------------------------------------------------------
-- ------------------<get_event_location >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to return the location id for the event.
-- IN
-- p_event_id
--
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_event_location(p_event_id    IN  NUMBER)
RETURN NUMBER;


-- ----------------------------------------------------------------
-- ------------------<get_play_button >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to return a varchar to indicate if
--   Play button will be displayed or not.
-- IN
-- p_person_id
-- p_offering_id
-- p_enrollment_status
-- p_course_start_date
-- p_course_end_date
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_play_button(p_person_id   IN  NUMBER,
          p_offering_id IN  NUMBER,
          p_enrollment_status IN  VARCHAR2,
          p_course_start_date IN  DATE,
          p_course_end_date IN    DATE)
RETURN VARCHAR2;

-- ----------------------------------------------------------------
-- --------------------< get_authorizer_name >---------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the name of the person who
-- authorized enrollment in an eventy
-- IN
-- p_authorizer_id
-- p_course_start_date
-- p_course_end_date
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
 FUNCTION get_authorizer_name(p_authorizer_id       IN    NUMBER,
                             p_course_start_date   IN    DATE,
                             p_course_end_date     IN    DATE)
RETURN VARCHAR2;

-- ----------------------------------------------------------------
-- --------------------< get_message >---------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to get the message for the code passed in.
-- IN
-- p_application_code
-- p_message_code
-- OUT
-- p_message_text
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
 FUNCTION get_message(p_application_code       IN    VARCHAR2,
                      p_message_code          IN    VARCHAR2)
RETURN VARCHAR2;

-- ----------------------------------------------------------------
-- --------------------< get_date_time >---------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to return date and time.
-- IN
-- p_date
-- p_time
-- p_time_of_day (Added for Bug 2201420)
-- OUT
-- p_date_time
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
 FUNCTION get_date_time(p_date       IN    DATE,
                        p_time       IN    VARCHAR2,
         p_time_of_day IN   VARCHAR2)
RETURN DATE;


-- ----------------------------------------------------------------
-- ------------------<get_category_name >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the category name
-- for the particular activity
-- IN
-- p_Activity_version_id
--
-- OUT
-- category name
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------

FUNCTION get_category_name(p_activity_version_id   IN  NUMBER)
RETURN VARCHAR2;

-- ----------------------------------------------------------------
-- ------------------<get_lo_offering_count >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the number of offerings for the particular
-- learning object
-- IN
-- p_learning_object_id
--
-- OUT
-- offering count
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_lo_offering_count (p_learning_object_id in number)
RETURN varchar2;

-- ----------------------------------------------------------------
-- ------------------<get_course_offering_count >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the number of offerings for the particular
-- course
-- IN
-- p_activity_version_id
--
-- OUT
-- offering count
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_course_offering_count (p_activity_version_id in number)
RETURN varchar2;


-- ----------------------------------------------------------------
-- ------------------<get_iln_rco_id >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find rco_id for course
-- IN
-- p_activity_version_id
--
-- OUT
-- l_rco_id
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
 function get_iln_rco_id (p_activity_version_id in number
                          ) return varchar2;


-- ----------------------------------------------------------------
-- ------------------<get_event_count >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the number of of events the particular
-- offering
-- IN
-- p_offering_id
-- p_event_type
--
-- OUT
-- event count
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_event_count (p_offering_id in number,
                          p_event_type  in varchar2 default 'ALL')
RETURN varchar2;

-- ----------------------------------------------------------------
-- ------------------<get_question_bank_count >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the number of question banks for particular
-- folder
-- IN
-- p_folder_id
--
-- OUT
-- question bank count
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_question_bank_count (p_folder_id in number)
RETURN varchar2;

-- Author: sbhullar
FUNCTION get_enrollment_status(p_delegate_person_id IN ota_delegate_bookings.delegate_person_id%TYPE,
                               p_delegate_contact_id IN NUMBER,
                               p_event_id IN ota_events.event_id%TYPE,
                               p_code number)
RETURN VARCHAR2;

FUNCTION get_user_fullname(p_user_id IN ota_attempts.user_id%TYPE,
                           p_user_type IN ota_attempts.user_type%TYPE)

RETURN VARCHAR2;

FUNCTION get_person_fullname(p_user_id IN ota_attempts.user_id%TYPE
                           )RETURN VARCHAR2;

FUNCTION get_learner_name(p_person_id IN per_all_people_f.person_id%TYPE,
                          p_customer_id IN ota_delegate_bookings.customer_id%TYPE,
                          p_contact_id IN ota_delegate_bookings.delegate_contact_id%TYPE)
RETURN VARCHAR2;

FUNCTION get_customer_id(p_contact_id IN ota_lp_enrollments.contact_id%TYPE)
RETURN number;

FUNCTION get_cust_org_name(p_organization_id IN ota_delegate_bookings.organization_id%TYPE,
                           p_customer_id IN ota_delegate_bookings.customer_id%TYPE,
                           p_contact_id IN ota_lp_enrollments.contact_id%TYPE default null)
RETURN VARCHAR2;

-- ----------------------------------------------------------------
-- ------------------<get_catalog_object_path >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the path for particular
-- category
-- IN
-- p_cat_id
--
-- OUT
-- p_path
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
Procedure get_catalog_object_path(p_cat_id varchar2,
            p_path OUT NOCOPY varchar2 );

-- ----------------------------------------------------------------
-- ------------------<get_content_object_path >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the path for particular
-- content object
-- IN
-- p_obj_id
-- p_obj_type
--
-- OUT
-- p_path
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
Procedure get_content_object_path(p_obj_id varchar2, p_obj_type varchar2,
            p_path OUT NOCOPY varchar2 );

-- ----------------------------------------------------------------
-- ------------------<check_function_access >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find if the user logged in has
-- access to the function or not.
-- IN
-- p_function_name
--
-- OUT
-- returns T for True or F for False
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION check_function_access(p_function_name in VARCHAR2)
RETURN varchar2;

-- ----------------------------------------------------------------
-- ------------------< get_event_status_code >---------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the event status code for
--   an event
-- IN
-- p_event_id
--
-- OUT
-- returns event status code
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
Function get_event_status_code (p_event_id in ota_events.event_id%TYPE)
return varchar2;

-- ----------------------------------------------------------------
-- ----------------------< is_applicant >--------------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find whether person is
--   applicant or not
-- IN
-- p_person_id
--
-- OUT
-- returns Y or N
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
Function is_applicant (p_person_id IN per_all_people_f.person_id%TYPE)
return varchar2;

-- ----------------------------------------------------------------
-- -------------------< get_ext_lrnr_party_id >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to fetch the party id for external learner
-- IN
-- p_delegate_contact_id
--
-- OUT
-- returns party id
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_ext_lrnr_party_id
         (p_delegate_contact_id IN ota_delegate_bookings.delegate_contact_id%TYPE)
RETURN number;

FUNCTION is_enrollable
     ( p_object_type in varchar2
      ,p_object_id in number
      )
RETURN varchar2;

PROCEDURE Get_Default_Value_Dff(
                           appl_short_name IN VARCHAR2,
                           flex_field_name IN VARCHAR2,
                           p_attribute_category IN OUT NOCOPY VARCHAR2,
                           p_attribute1 IN OUT NOCOPY VARCHAR2,
                           p_attribute2 IN OUT NOCOPY VARCHAR2,
                           p_attribute3 IN OUT NOCOPY VARCHAR2,
                           p_attribute4 IN OUT NOCOPY VARCHAR2,
                           p_attribute5 IN OUT NOCOPY VARCHAR2,
                           p_attribute6 IN OUT NOCOPY VARCHAR2,
                           p_attribute7 IN OUT NOCOPY VARCHAR2,
                           p_attribute8 IN OUT NOCOPY VARCHAR2,
                           p_attribute9 IN OUT NOCOPY VARCHAR2,
                           p_attribute10 IN OUT NOCOPY VARCHAR2,
                           p_attribute11 IN OUT NOCOPY VARCHAR2,
                           p_attribute12 IN OUT NOCOPY VARCHAR2,
                           p_attribute13 IN OUT NOCOPY VARCHAR2,
                           p_attribute14 IN OUT NOCOPY VARCHAR2,
                           p_attribute15 IN OUT NOCOPY VARCHAR2,
   			 p_attribute16 IN OUT NOCOPY VARCHAR2,
			p_attribute17 IN OUT NOCOPY VARCHAR2,
			p_attribute18 IN OUT NOCOPY VARCHAR2,
			p_attribute19 IN OUT NOCOPY VARCHAR2,
			p_attribute20 IN OUT NOCOPY VARCHAR2);

PROCEDURE Get_Default_Value_Dff(
                           appl_short_name IN VARCHAR2,
                           flex_field_name IN VARCHAR2,
                           p_attribute_category IN OUT NOCOPY VARCHAR2,
                           p_attribute1 IN OUT NOCOPY VARCHAR2,
                           p_attribute2 IN OUT NOCOPY VARCHAR2,
                           p_attribute3 IN OUT NOCOPY VARCHAR2,
                           p_attribute4 IN OUT NOCOPY VARCHAR2,
                           p_attribute5 IN OUT NOCOPY VARCHAR2,
                           p_attribute6 IN OUT NOCOPY VARCHAR2,
                           p_attribute7 IN OUT NOCOPY VARCHAR2,
                           p_attribute8 IN OUT NOCOPY VARCHAR2,
                           p_attribute9 IN OUT NOCOPY VARCHAR2,
                           p_attribute10 IN OUT NOCOPY VARCHAR2,
                           p_attribute11 IN OUT NOCOPY VARCHAR2,
                           p_attribute12 IN OUT NOCOPY VARCHAR2,
                           p_attribute13 IN OUT NOCOPY VARCHAR2,
                           p_attribute14 IN OUT NOCOPY VARCHAR2,
                           p_attribute15 IN OUT NOCOPY VARCHAR2,
   			   p_attribute16 IN OUT NOCOPY VARCHAR2,
			   p_attribute17 IN OUT NOCOPY VARCHAR2,
			   p_attribute18 IN OUT NOCOPY VARCHAR2,
			   p_attribute19 IN OUT NOCOPY VARCHAR2,
			   p_attribute20 IN OUT NOCOPY VARCHAR2,
                           p_attribute21 IN OUT NOCOPY VARCHAR2,
                           p_attribute22 IN OUT NOCOPY VARCHAR2,
                           p_attribute23 IN OUT NOCOPY VARCHAR2,
                           p_attribute24 IN OUT NOCOPY VARCHAR2,
                           p_attribute25 IN OUT NOCOPY VARCHAR2,
   			   p_attribute26 IN OUT NOCOPY VARCHAR2,
			   p_attribute27 IN OUT NOCOPY VARCHAR2,
			   p_attribute28 IN OUT NOCOPY VARCHAR2,
			   p_attribute29 IN OUT NOCOPY VARCHAR2,
			   p_attribute30 IN OUT NOCOPY VARCHAR2);


-- Added for bug#4606760
function is_customer_associated(p_event_id in NUMBER) return varchar2;

FUNCTION check_organization_match(
    p_person_id IN NUMBER
   ,p_sponsor_org_id IN NUMBER) return VARCHAR2;

FUNCTION getEnrollmentChangeReason(
    p_booking_id IN NUMBER) return VARCHAR2;

function get_lang_name  (
                        p_language_code in varchar2
                        ) return varchar2;

function get_class_available_seats(p_event_id ota_events.event_id%type) return varchar2;

function get_cls_enroll_image(p_manager_flag in varchar2,
                          p_person_id in number,
                          p_contact_id in number,
                          p_event_id in ota_events.event_id%TYPE,
                          p_mandatory_flag in ota_delegate_bookings.is_mandatory_enrollment%TYPE,
                          p_booking_status_type in ota_booking_status_types.type%TYPE) return varchar2;

FUNCTION is_class_enrollable(
     p_enr_type varchar2,
     p_class_id ota_events.event_id%TYPE)
RETURN VARCHAR2;

function get_learners_email_addresses(p_event_id ota_events.event_id%type) return varchar2;


end  ota_utility;



/
