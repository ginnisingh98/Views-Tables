--------------------------------------------------------
--  DDL for Package OTA_LO_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LO_UTILITY" AUTHID CURRENT_USER as
/* $Header: otloutil.pkh 120.21.12010000.7 2009/09/14 12:22:51 smahanka ship $ */


EVENT_REASON_NO_REASON           constant number := 0;
EVENT_REASON_NO_SUCH_EVENT       constant number := 1;
EVENT_REASON_EXPIRED             constant number := 2;
EVENT_REASON_NOT_STARTED         constant number := 3;
EVENT_REASON_NOT_ENROLLED        constant number := 4;
EVENT_REASON_NOT_PUBLISHED       constant number := 5;
EVENT_REASON_NOT_INSTRUCTOR      constant number := 6;

LO_REASON_NO_REASON              constant number := 0;
LO_REASON_NO_SUCH_LO             constant number := 1;
LO_REASON_NO_STARTING_URL        constant number := 2;
LO_REASON_PREREQS_NOT_MET        constant number := 3;
LO_REASON_ATTEMPTS_EXCEEDED      constant number := 4;
LO_REASON_NOT_IN_EVENT           constant number := 5;
LO_REASON_NOT_PUBLISHED          constant number := 6;
LO_REASON_UNKNOWN           	   constant number := 7;
LO_REASON_EXPIRED            	   constant number := 8;
LO_REASON_NOT_STARTED        	   constant number := 9;
LO_REASON_LO_NOT_IN_CERT         constant number := 10;
LO_REASON_DURATION_NOT_MET       constant number := 11;

CERT_REASON_NO_REASON          constant number := 0;
CERT_REASON_NOT_STARTED        constant number := 1;
CERT_REASON_EXPIRED            constant number := 2;
CERT_PRD_REASON_NOT_STARTED    constant number := 3;
CERT_PRD_REASON_EXPIRED        constant number := 4;
CERT_REASON_NO_SUCH_CERT       constant number := 5;
CERT_REASON_UNSUBSCRIBED       constant number := 6;
CERT_REASON_INVALID_USER       constant number := 7;


procedure set_performance_lesson_status(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_lesson_status ota_performances.lesson_status%type,
   p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type);


procedure set_performance_lesson_status(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_lesson_status ota_performances.lesson_status%type,
   p_date date,
   p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type);

procedure set_performance_time(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_time ota_performances.time%type,
   p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type);


procedure set_performance_time(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_time ota_performances.time%type,
   p_date date,
   p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type);


function get_previous_event_lo_id(
   p_event_id ota_events.event_id%type,
   p_starting_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return ota_learning_objects.learning_object_id%type;


function get_next_event_lo_id(
   p_event_id ota_events.event_id%type,
   p_starting_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return ota_learning_objects.learning_object_id%type;


function get_previous_lo_id(
   p_root_lo_id ota_learning_objects.learning_object_id%type,
   p_starting_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return ota_learning_objects.learning_object_id%type;


function get_next_lo_id(
   p_root_lo_id ota_learning_objects.learning_object_id%type,
   p_starting_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return ota_learning_objects.learning_object_id%type;


function get_next_lo_id(
   p_root_lo_id ota_learning_objects.learning_object_id%type,
   p_root_starting_url ota_learning_objects.starting_url%type,
   p_starting_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return ota_learning_objects.learning_object_id%type;


function get_first_lo_id(
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return ota_learning_objects.learning_object_id%type;


function get_most_recent_lo_id(
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enroll_id ota_attempts.cert_prd_enrollment_id%type) return ota_learning_objects.learning_object_id%type;


function get_jump_lo_id(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enroll_id ota_attempts.cert_prd_enrollment_id%type,
   p_reason out nocopy number) return ota_learning_objects.learning_object_id%type;

function get_lo_type(
   p_lo_id ota_learning_objects.learning_object_id%type) return varchar2;

function user_can_attempt_event(
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_reason out nocopy number) return varchar2;


function user_can_attempt_event(
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type) return varchar2;


function user_can_attempt_event(
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type) return varchar2;


function user_can_attempt_lo(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type default '',
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return varchar2;


function user_can_attempt_cert(
   p_cert_prd_enroll_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_reason out nocopy number) return varchar2;

-- Author: sbhullar
-- ----------------------------------------------------------------
-- ------------------<get_lo_title_for_tree >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to show get lo name, status and time
-- in the format lo_name [Status: status, Time: hh:mm:ss] if p_mode
-- is 1 else it gives the lo status icon
-- IN
-- p_lo_id
-- p_user_id
-- p_user_type
-- p_mode
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_lo_title_for_tree(p_lo_id 	IN	 NUMBER,
  			   p_user_id	IN	 NUMBER,
		           p_user_type IN ota_attempts.user_type%type,
		           p_mode IN NUMBER default 1,
		           p_active_cert_flag varchar2 default 'N')
RETURN varchar2;



function get_play_button(
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_is_manager varchar2,
   p_event_id ota_events.event_id%type,
   p_event_type ota_events.event_type%type,
   p_synchronous_flag ota_category_usages.synchronous_flag%type,
   p_online_flag ota_category_usages.online_flag%type,
   p_course_start_date ota_events.course_start_date%type,
   p_course_end_date ota_events.course_end_date%type,
   p_enrollment_status_type ota_booking_status_types.type%TYPE DEFAULT NULL,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null,
   p_contact_id ota_cert_enrollments.contact_id%type default null,
   p_chk_active_cert_flag varchar2 default 'N') return varchar2;


function get_play_button_for_test(
   	p_user_id fnd_user.user_id%type,
   	p_user_type ota_attempts.user_type%type,
   	p_event_id ota_events.event_id%type,
    p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return varchar2;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_wait_duration_for_test >--------------------
-- ----------------------------------------------------------------------------
-- Author: smanjuna
-- This function is used to get the timestamp until which the learner has to
-- wait before playing the test again. This is displayed as flyover text.
-- [End of Comments]
-- ----------------------------------------------------------------------------
function get_wait_duration_for_test(
   	p_user_id fnd_user.user_id%type,
   	p_user_type ota_attempts.user_type%type,
   	p_event_id ota_events.event_id%type,
    p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return varchar2;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_wait_duration_for_lo >------------------
-- ----------------------------------------------------------------------------
-- Author: gdhutton
-- This function is used to get the date until which the learner has to
-- wait before playing the LO again.
-- [End of Comments]
-- ---------------------------------------------------------------------------
function get_wait_duration_for_lo(
   	p_user_id fnd_user.user_id%type,
   	p_user_type ota_attempts.user_type%type,
   	p_lo_id ota_learning_objects.learning_object_id%type,
    p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return varchar2;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< root_folder_exists>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will check if root folder is existing for a business group.
--
--
-- Pre Conditions:
--   None.
--
-- Out Arguments:
--   p_folder_id
--   p_business_group_id
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
--
function root_folder_exists
(p_folder_id          in   number default hr_api.g_number
,p_business_group_id  in   number default ota_general.get_business_group_id
)
return varchar2;
--

-- ----------------------------------------------------------------------------
-- |-------------------------< get_enroll_lo_status >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will fetch the player status for online classes and enrollment
--   status for offline classes.
--
-- Pre Conditions:
--   None.
--
-- Out Arguments:
--   p_user_id
--   p_user_type
--   p_event_id
--   p_booking_status_type_id
--   p_booking_id
--   p_mode
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
--

FUNCTION get_enroll_lo_status(p_user_id	IN	 NUMBER,
                       p_user_type IN ota_attempts.user_type%type,
                       p_event_id IN ota_events.event_id%TYPE,
		       p_booking_status_type_id IN ota_booking_status_types.booking_status_type_id%TYPE,
                       p_booking_id IN ota_delegate_bookings.booking_id%TYPE,
                       p_mode IN number default null,
                       p_chk_active_cert_flag varchar2 default 'N')
RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_history_button >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will return a value based on which the Move to History
-- Button will be enabled. it will be enabled for online classes with a
-- performance status of Completed, Passed or Failed.
--
-- Pre Conditions:
--   None.
--
-- Out Arguments:
--   p_user_id
--   p_lo_id
--   p_event_id
--   p_booking_id
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

FUNCTION get_history_button(p_user_id    fnd_user.user_id%TYPE,
                            p_lo_id      ota_learning_objects.learning_object_id%TYPE,
                            p_event_id   ota_events.event_id%TYPE,
                            p_booking_id ota_delegate_bookings.booking_id%TYPE)
RETURN VARCHAR2;

FUNCTION get_lo_completion_date(p_event_id IN ota_events.event_id%type,
  			        p_user_id	IN	 NUMBER,
                                p_user_type IN ota_attempts.user_type%type,
                                p_cert_prd_enroll_id IN ota_performances.cert_prd_enrollment_id%type default NULL,
				p_module_name IN VARCHAR2 default 'LEARNER')
RETURN varchar2;

-- ----------------------------------------------------------------------------
-- |-------------------------< get_cert_lo_status >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will fetch the player status for online classes and enrollment
--   status for offline classes within the certification details.
--
-- Pre Conditions:
--   None.
--
-- Out Arguments:
--   p_user_id
--   p_user_type
--   p_event_id
--   p_booking_status_type_id
--   p_booking_id
--   p_cert_prd_enrollment_id
--   p_mode
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

FUNCTION get_cert_lo_status(p_user_id	IN	 NUMBER,
                            p_user_type IN ota_attempts.user_type%type,
                            p_event_id IN ota_events.event_id%TYPE,
                            p_booking_status_type_id IN ota_booking_status_types.booking_status_type_id%TYPE,
                            p_booking_id IN ota_delegate_bookings.booking_id%TYPE,
                            p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
                            p_mode IN number default null)
RETURN varchar2;

-- ----------------------------------------------------------------
-- ------------------<get_cert_lo_title_for_tree >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used within the certifications to show get
--   lo name, status and time in the format
--   lo_name [Status: status, Time: hh:mm:ss]
--   if p_mode is 1 else it gives the lo status icon
-- IN
-- p_lo_id
-- p_user_id
-- p_user_type
-- p_cert_prd_enrollment_id
-- p_mode
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------

FUNCTION get_cert_lo_title_for_tree(p_lo_id 	IN	 NUMBER,
    		                    p_user_id	IN	 NUMBER,
                                    p_user_type IN ota_attempts.user_type%type,
                                    p_cert_prd_enrollment_id IN ota_performances.cert_prd_enrollment_id%type,
                                    p_mode IN NUMBER default 1)
RETURN varchar2;

-- ----------------------------------------------------------------
-- ------------------<get_cme_online_event_id >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used within the certifications enrollment
--   details page to enable the player launch btn

-- IN
-- p_user_id
-- p_user_type
-- p_cert_mbr_enrollment_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
function get_cme_online_event_id(p_user_id in fnd_user.user_id%type,
   			     p_user_type in ota_attempts.user_type%type,
   			     p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
return varchar2;

-- ----------------------------------------------------------------
-- ------------------<get_cme_play_button >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used within the certifications enrollment
--   details page to enable the player launch btn

-- IN
-- p_user_id
-- p_user_type
-- p_is_manager
-- p_cert_mbr_enrollment_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
function get_cme_play_button(p_user_id in fnd_user.user_id%type,
   			                 p_user_type in ota_attempts.user_type%type,
			                 p_is_manager in varchar2,
   			                 p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
return varchar2;

-- ----------------------------------------------------------------
-- ------------------<get_cme_player_toolbar_flag >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used within the certifications enrollment
--   details page to enable the player launch btn

-- IN
-- p_user_id
-- p_user_type
-- p_cert_mbr_enrollment_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
function get_cme_player_toolbar_flag(p_user_id in fnd_user.user_id%type,
   			     p_user_type in ota_attempts.user_type%type,
   			     p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
return varchar2;

-- ----------------------------------------------------------------
-- ------------------<get_cert_lo_status >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used within the certifications enrollment
--   details page to enable the player launch btn and show the perf status

-- IN
-- p_user_id
-- p_user_type
-- p_cert_mbr_enrollment_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
function get_cert_lo_status(p_user_id in fnd_user.user_id%type,
   			     p_user_type in ota_attempts.user_type%type,
   			     p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
return varchar2;


-- ----------------------------------------------------------------
-- ------------------<get_cme_onl_evt_count >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used within the certifications enrollment
--   details page to enable the player launch btn and show the perf status

-- IN
-- p_user_id
-- p_user_type
-- p_cert_mbr_enrollment_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
function get_cme_onl_evt_count(p_user_id in fnd_user.user_id%type,
   			     p_user_type in ota_attempts.user_type%type,
   			     p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
return varchar2;

-- ----------------------------------------------------------------
-- -----------------------< format_lo_time >-----------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function formats time in HH:MM:SS format
--
-- IN
-- pTime
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
Function format_lo_time(pTime ota_performances.time%type)
return varchar2;

-- ----------------------------------------------------------------
-- ------------------<get_lme_online_event_id >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used within the lp member enrollment
--   details page to enable the player launch btn

-- IN
-- p_user_id
-- p_user_type
-- p_lp_member_enrollment_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
function get_lme_online_event_id(p_lp_member_enrollment_id in ota_lp_member_enrollments.lp_member_enrollment_id%type)
return varchar2;

-- ----------------------------------------------------------------
-- ------------------<get_lme_play_button >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used within the learning path enrollment
--   details page to enable the player launch btn

-- IN
-- p_user_id
-- p_user_type
-- p_is_manager
-- p_lp_member_enrollment_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
function get_lme_play_button(p_user_id in fnd_user.user_id%type,
   			                 p_user_type in ota_attempts.user_type%type,
			                 p_is_manager in varchar2,
   			                 p_lp_member_enrollment_id in ota_lp_member_enrollments.lp_member_enrollment_id%type)
return varchar2;

-- ----------------------------------------------------------------
-- ------------------<get_lme_player_toolbar_flag >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used within the learning path enrollment
--   details page to enable the player launch btn

-- IN
-- p_lp_member_enrollment_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
function get_lme_player_toolbar_flag(p_lp_member_enrollment_id in ota_lp_member_enrollments.lp_member_enrollment_id%type)
return varchar2;

-- ----------------------------------------------------------------
-- ------------------<get_lp_lo_status >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used within the learning path enrollment
--   details page to enable the player launch btn and show the perf status

-- IN
-- p_user_id
-- p_user_type
-- p_lp_member_enrollment_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
function get_lpe_lo_status(p_user_id in fnd_user.user_id%type,
   			     p_user_type in ota_attempts.user_type%type,
   			     p_lp_member_enrollment_id in ota_lp_member_enrollments.lp_member_enrollment_id%type)
return varchar2;


-- ----------------------------------------------------------------
-- ------------------<get_lme_onl_evt_count >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used within the learning path enrollment
--   details page to enable the player launch btn and show the perf status

-- IN
-- p_user_id
-- p_user_type
-- p_lp_member_enrollment_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
function get_lme_onl_evt_count(p_lp_member_enrollment_id in ota_lp_member_enrollments.lp_member_enrollment_id%type)
return varchar2;

procedure get_active_cert_prds(
   p_event_id ota_events.event_id%type,
   p_person_id ota_cert_enrollments.contact_id%type,
   p_contact_id ota_cert_enrollments.contact_id%type,
   p_cert_prd_enrollment_ids  OUT NOCOPY varchar2);

-- ----------------------------------------------------------------------------
-- |--------------------< LO_has_cld_and_no_strt_url>-------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION Lo_has_cld_and_no_strt_url
(p_learning_object_id          in   number default hr_api.g_number)
RETURN varchar2;

-- ----------------------------------------------------------------------------
-- |--------------------< GET_LO_COMPLETION_DATE_TIME>-------------------------|
-- ----------------------------------------------------------------------------

--Added for 6768606:COMPLETION DATE COLUMN SORT NUMERIC AND NOT BY ACTUAL DATE SORT

FUNCTION get_lo_completion_date_time(p_event_id IN ota_events.event_id%type,
  			        p_user_id	IN	NUMBER,
                                p_user_type IN ota_attempts.user_type%type,
                                p_cert_prd_enroll_id IN ota_performances.cert_prd_enrollment_id%type default NULL,
				p_module_name IN VARCHAR2 default 'LEARNER')
RETURN date;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_enroll_lo_score >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will fetch the player score for online classes and enrollment
--   score for offline classes.
--
-- Pre Conditions:
--   None.
--
-- Out Arguments:
--   p_user_id
--   p_user_type
--   p_event_id
--   p_booking_id
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
--
FUNCTION get_enroll_lo_score(p_user_id	IN	 NUMBER,
                       p_user_type IN ota_attempts.user_type%type,
                       p_event_id IN ota_events.event_id%TYPE,
                       p_booking_id IN ota_delegate_bookings.booking_id%TYPE)
RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_enroll_lo_time >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will fetch the player time for online classes and enrollment
--   training time for offline classes.
--
-- Pre Conditions:
--   None.
--
-- Out Arguments:
--   p_user_id
--   p_user_type
--   p_event_id
--   p_booking_id
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
--
FUNCTION get_enroll_lo_time(p_user_id	IN	 NUMBER,
                       p_user_type IN ota_attempts.user_type%type,
                       p_event_id IN ota_events.event_id%TYPE,
                       p_booking_id IN ota_delegate_bookings.booking_id%TYPE)
RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |-------------------------< get_player_status >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will fetch the player staus code for online classes and enrollment
--   content player status for offline classes.
--
-- Pre Conditions:
--   None.
--
-- Out Arguments:
--   p_user_id
--   p_user_type
--   p_event_id
--   p_booking_id
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
--
FUNCTION get_player_status(p_user_id	IN	 NUMBER,
                       p_user_type IN ota_attempts.user_type%type,
                       p_event_id IN ota_events.event_id%TYPE,
                       p_booking_id IN ota_delegate_bookings.booking_id%TYPE)
RETURN VARCHAR2;

function get_play_eval_button(
    p_event_id OTA_EVENTS.EVENT_ID%TYPE,
    p_user_id fnd_user.user_id%type,
    p_booking_status_type_id OTA_DELEGATE_BOOKINGS.BOOKING_STATUS_TYPE_ID%TYPE,
    p_object_id OTA_EVALUATIONS.OBJECT_ID%TYPE,
    p_object_type OTA_EVALUATIONS.OBJECT_TYPE%TYPE,
    p_mand_flag OTA_EVALUATIONS.EVAL_MANDATORY_FLAG%TYPE,
    p_test_id OTA_TESTS.TEST_ID%TYPE)
return varchar2;

procedure update_enrollment_status(
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_event_id ota_events.event_id%type);

procedure update_enroll_status_for_lo(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_date date,
   p_failed varchar2);

procedure update_enrollment(
  p_booking_id ota_delegate_bookings.booking_id%type,
  p_event_id ota_events.event_id%type,
  p_business_group_id ota_delegate_bookings.business_group_id%type,
  p_date_booking_placed ota_delegate_bookings.date_booking_placed%type,
  p_object_version_number ota_delegate_bookings.object_version_number%type,
  p_sign_eval_status ota_delegate_bookings.sign_eval_status%type,   --8785933
  p_date_status_changed ota_delegate_bookings.date_status_changed%type,
  p_new_status varchar2,
  p_failed varchar2,
  p_signed varchar2);

--Enhancement: 	7310093 SIP: A NEW  FIELD WHICH CAN GIVE THE STATUS OF THE COURSE / CLASS EVALUATION
--Modified for 8855548.
function get_admin_eval_status(
       p_event_id OTA_EVENTS.EVENT_ID%TYPE,
       p_sign_eval_status OTA_DELEGATE_BOOKINGS.SIGN_EVAL_STATUS%TYPE)
return varchar2;

--Enhancement: 8785933 Added to show sign or evaluation buttons whichever present.
function get_sign_eval_button(
    p_sign_eval_status OTA_DELEGATE_BOOKINGS.SIGN_EVAL_STATUS%TYPE)
return varchar2;

end ota_lo_utility;

/
