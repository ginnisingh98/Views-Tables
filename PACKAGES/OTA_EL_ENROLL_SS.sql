--------------------------------------------------------
--  DDL for Package OTA_EL_ENROLL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EL_ENROLL_SS" AUTHID CURRENT_USER as
/* $Header: otelenss.pkh 120.1 2005/09/16 16:44:11 hdshah noship $ */

Type resp_id_tab is table of fnd_user_resp_groups.responsibility_id%type INDEX BY BINARY_INTEGER;
Type sec_id_tab is table of fnd_user_resp_groups.security_group_id%type INDEX BY BINARY_INTEGER;
 --
  --
  -- CSR_BOOKING_STATUS_ID retrieves a single booking_status_type_id for
  -- a particular BG of the reqired type.
  -- It selects using the following priority :-
  --   1) The name is like 'W:%' -- This indicates it is seeded for the web
  --   2) The default flag is set
  --   3) The first row retrieved that is of the type required.
   --
  CURSOR csr_booking_status_id (p_business_group_id       IN NUMBER
			                   ,p_web_booking_status_type IN VARCHAR2) IS
  SELECT bst.BOOKING_STATUS_TYPE_ID,bst.BUSINESS_GROUP_ID,bst.ACTIVE_FLAG,bst.DEFAULT_FLAG,bst.PLACE_USED_FLAG,
    bstt.NAME,bst.OBJECT_VERSION_NUMBER,bst.TYPE,bst.COMMENTS,bstt.DESCRIPTION,bst.LAST_UPDATE_DATE,
    bst.LAST_UPDATED_BY,bst.LAST_UPDATE_LOGIN,bst.CREATED_BY,bst.CREATION_DATE,
    bst.BST_INFORMATION_CATEGORY,bst.BST_INFORMATION1,bst.BST_INFORMATION2,
    bst.BST_INFORMATION3,bst.BST_INFORMATION4,bst.BST_INFORMATION5,
    bst.BST_INFORMATION6,bst.BST_INFORMATION7,bst.BST_INFORMATION8,
    bst.BST_INFORMATION9,bst.BST_INFORMATION10,bst.BST_INFORMATION11,
    bst.BST_INFORMATION12,bst.BST_INFORMATION13,bst.BST_INFORMATION14,
    bst.BST_INFORMATION15,bst.BST_INFORMATION16,bst.BST_INFORMATION17,
    bst.BST_INFORMATION18,bst.BST_INFORMATION19,bst.BST_INFORMATION20
  FROM ota_booking_status_types bst, ota_booking_status_types_tl bstt
  WHERE bst.business_group_id = p_business_group_id
    AND bst.booking_status_type_id = bstt.booking_status_type_id
    AND bstt.language=userenv('LANG')
    AND rownum=1
    AND bst.type = DECODE(p_web_booking_status_type, 'REQUESTED', 'R'
					       , 'WAITLISTED','W'
					       , 'CANCELLED', 'C'
					       , 'ATTENDED' , 'A'
					       , 'PLACED'   , 'P')
        -- The name is like W: ( highest priority choice)
    AND (  (bstt.name like 'W:%')
        -- There are no names like W:, so a defaulted required status is
        -- the second choice.
         OR ( NOT EXISTS (SELECT 1
                          FROM ota_booking_status_types bst1, ota_booking_status_types_tl bstt1
                          WHERE bst1.business_group_id = p_business_group_id
                           AND bst1.booking_status_type_id = bstt1.booking_status_type_id
                           AND bstt1.language=userenv('LANG')
			   AND bst1.type =
      	                        DECODE(p_web_booking_status_type, 'REQUESTED', 'R'
					       , 'WAITLISTED','W'
					       , 'CANCELLED', 'C'
					       , 'ATTENDED' , 'A'
					       , 'PLACED'   , 'P')
                          AND bstt1.name like 'W:%')
             AND (  (bst.default_flag = 'Y')
         -- If there are no names like 'W:%' and no defaulted status of type
         -- required, then select one that is of type required
                  OR NOT EXISTS (SELECT 1
                                 FROM ota_booking_status_types
                                 WHERE business_group_id = p_business_group_id
                                 AND type =
    	       DECODE(p_web_booking_status_type, 'REQUESTED', 'R'
					       , 'WAITLISTED','W'
					       , 'CANCELLED', 'C'
					       , 'ATTENDED' , 'A'
					       , 'PLACED'   , 'P')
                                 AND default_flag ='Y')
                  )
             )
         );

--
-- Cursor to retrieve necessary information in order to save the enrollment
-- NOTE : Removed the address section as it appears that a person doesn't
--        need to have a primary address (however, I've only commented it out
--        just incase)

CURSOR csr_person_to_enroll_details (p_person_id  number) IS
    SELECT  pp.last_name
           ,pp.first_name
	       ,pp.full_name
           ,pp.business_group_id
           ,pp.email_address
           ,pp.work_telephone
       --  ,p2.email_address        super_email
       --  ,p2.work_telephone       super_phone
           ,p2.person_id            super_id
           ,asg2.assignment_id      super_asg_id
       --    ,ad.address_id
       --    ,ad.address_line1
           ,pp.object_version_number per_object_version_number
           ,asg.assignment_id
           ,asg.internal_address_line work_line
           ,asg.organization_id
           ,loc.address_line_1 work_line1
           ,loc.town_or_city work_city
    FROM    per_all_people_f        pp
           ,per_all_assignments_f   asg
           ,per_all_people_f        p2
           ,per_all_assignments_f   asg2
        --   ,per_addresses     ad
           ,hr_locations        loc
           ,hr_all_organization_units org
    WHERE   pp.person_id         = p_person_id
    AND     trunc(sysdate) BETWEEN pp.effective_start_date AND pp.effective_end_date
    and     asg.person_id        = pp.person_id
    AND     asg.primary_flag     = 'Y'
    AND     trunc(sysdate) BETWEEN asg.effective_start_date AND asg.effective_end_date
    and     p2.person_id(+)      = asg.supervisor_id
    AND     trunc(sysdate) BETWEEN p2.effective_start_date(+) AND p2.effective_end_date(+)
    and     asg2.person_id(+)    = asg.supervisor_id
    AND     asg2.primary_flag(+) = 'Y'
    AND     trunc(sysdate) BETWEEN asg2.effective_start_date(+) AND asg2.effective_end_date(+)
 --   AND     ad.person_id       = pp.person_id
 --   AND     ad.primary_flag    = 'Y'
 --   AND     trunc(sysdate)BETWEEN ad.date_from AND nvl(ad.date_to, trunc(sysdate))
    and     asg.organization_id  = org.organization_id
    and     org.location_id      = loc.location_id (+);


g_mesg_on_stack_exception      	EXCEPTION;
PRAGMA EXCEPTION_INIT(g_mesg_on_stack_exception, -20002);

--
-- ----------------------------------------------------------------------------
-- |-----------------------------<ProcessSaveEnrollment>----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used for self service application to create enrollment
--   data when user enroll in the class.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Enrollment data will be created.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE ProcessSaveEnrollment( p_event_id	IN VARCHAR2
				,p_extra_information		IN VARCHAR2 DEFAULT NULL
				,p_mode				        IN VARCHAR2
                		,p_cost_centers		        IN VARCHAR2 DEFAULT NULL
        			,p_assignment_id			IN PER_ALL_ASSIGNMENTS_F.assignment_id%TYPE
        			,p_business_group_id_from	IN PER_ALL_ASSIGNMENTS_F.business_group_id%TYPE
				,p_business_group_name		IN PER_BUSINESS_GROUPS.name%TYPE
        			,p_organization_id          IN PER_ALL_ASSIGNMENTS_F.organization_id%TYPE
				,p_item_type 			    IN WF_ITEMS.ITEM_TYPE%TYPE
				,p_person_id                 IN PER_ALL_PEOPLE_F.person_id%type
                		,p_booking_id                out nocopy OTA_DELEGATE_BOOKINGS.Booking_id%type
                		, p_message_name out nocopy varchar2
				,p_item_key 			    IN WF_ITEMS.ITEM_TYPE%TYPE
                                ,p_tdb_information_category            in varchar2     default null
                                ,p_tdb_information1                    in varchar2     default null
                                ,p_tdb_information2                    in varchar2     default null
                                ,p_tdb_information3                    in varchar2     default null
                                ,p_tdb_information4                    in varchar2     default null
                                ,p_tdb_information5                    in varchar2     default null
                                ,p_tdb_information6                    in varchar2     default null
                                ,p_tdb_information7                    in varchar2     default null
                                ,p_tdb_information8                    in varchar2     default null
                                ,p_tdb_information9                    in varchar2     default null
                                ,p_tdb_information10                   in varchar2     default null
                                ,p_tdb_information11                   in varchar2     default null
                                ,p_tdb_information12                   in varchar2     default null
                                ,p_tdb_information13                   in varchar2     default null
                                ,p_tdb_information14                   in varchar2     default null
                                ,p_tdb_information15                   in varchar2     default null
                                ,p_tdb_information16                   in varchar2     default null
                                ,p_tdb_information17                   in varchar2     default null
                                ,p_tdb_information18                   in varchar2     default null
                                ,p_tdb_information19                   in varchar2     default null
                                ,p_tdb_information20                   in varchar2     default null);

--
-- ----------------------------------------------------------------------------
-- |-----------------------------<Cancel_finance>-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used for self service application to cancel finance if
--   user re-enroll in the class.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--  Finance will be canceled.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

PROCEDURE cancel_finance(p_booking_id in number);


--
--
-- ----------------------------------------------------------------------------
-- |----------------------<Get_Booking_Status_For_Web >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used for self service application to create enrollment
--   data when user enroll in the class.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Enrollment data will be created.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------


FUNCTION Get_Booking_Status_For_Web (p_web_booking_status_type 	VARCHAR2
				    ,p_business_group_id	NUMBER)
RETURN OTA_BOOKING_STATUS_TYPES%ROWTYPE;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------<Check_Cost_Center>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used for self service application to create enrollment
--   data when user enroll in the class.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Enrollment data will be created.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure check_cost_center
(p_person_id in number,
 p_no_cost_center out nocopy number,
 p_cost_alloc_keyflex_id out nocopy number,
 p_business_group_id out nocopy number,
 p_assignment_id  out nocopy number,
 p_organization_id out nocopy number,
 p_cost_center out nocopy varchar2 );
--
-- ----------------------------------------------------------------------------
-- |----------------------<Create_enroll_wf_process>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used for self service application to create enrollment
--   data when user enroll in the class.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Enrollment data will be created.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure create_enroll_wf_process
(p_process in wf_process_activities.process_name%type,
p_itemtype in wf_items.item_type%type,
p_person_id in number default null,
p_called_from             in varchar2 default null,
p_itemkey out nocopy wf_items.item_key%type
 );


--
-- ----------------------------------------------------------------------------
-- |----------------------<Get_Person_To_Enroll_Details >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used for self service application to create enrollment
--   data when user enroll in the class.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Enrollment data will be created.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

FUNCTION Get_Person_To_Enroll_Details (p_person_id  per_all_people_f.PERSON_ID%TYPE)
RETURN csr_person_to_enroll_details%ROWTYPE;


--
-- ----------------------------------------------------------------------------
-- |-------------------------------<Validate_Enrollment>----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used for self service application to create enrollment
--   data when user enroll in the class.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Enrollment data will be created.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

PROCEDURE Validate_enrollment(p_person_id  IN per_all_people_f.PERSON_ID%TYPE,
				     p_event_id	IN VARCHAR2,
				     p_double_book  OUT NOCOPY VARCHAR2);

-- |--------------------------------------------------------------------------|
-- |--< Chk_Event_Cancelled_for_Person >--------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- {Start Of Comments}
--
-- Description:
--   This package is used for self service application to create enrollment
--   data when user enroll in the class.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Enrollment data will be created.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Chk_Event_Cancelled_for_Person (p_event_id 		IN NUMBER
					,p_delegate_person_id	IN NUMBER
					,p_booking_id 		OUT NOCOPY NUMBER)
RETURN BOOLEAN;

procedure Chk_booking_clash (p_event_id 		IN NUMBER
					,p_person_id	IN NUMBER
					,p_booking_Clash 	OUT NOCOPY varchar2)
;
--|--------------------------------------------------------------------------|
--|--< CHK_FOR_SECURE_EVT >-------------------------------------------|
--|--------------------------------------------------------------------------|

-- {Start Of Comments}
--
-- Description:
--   Called by dynamic sql to determine whether event is secure and it is OK to show the delegate
--   the event in question. Only the events that they can enroll onto are
--   shown.
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- an exception is raised
--
-- Access Status:
-- Public
--
-- {End Of Comments}
--
----------------------------------------------------------------------------

FUNCTION CHK_FOR_SECURE_EVT (
         p_delegate_id        IN PER_PEOPLE_F.PERSON_ID%TYPE
       , p_event_id           IN OTA_EVENTS.EVENT_ID%TYPE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(CHK_FOR_SECURE_EVT, WNDS, WNPS);
--|--------------------------------------------------------------------------|
--|--< CHK_DELEGATE_OK_FOR_EVENT>-----------------------------------------|
--|--------------------------------------------------------------------------|

-- {Start Of Comments}
--
-- Description:
--   Called by dynamic sql to determine whether it is OK to show the delegate
--   the event in question. Only the events that they can enroll onto are
--   shown.
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- an exception is raised
--
-- Access Status:
-- Public
--
-- {End Of Comments}
--
----------------------------------------------------------------------------

FUNCTION CHK_DELEGATE_OK_FOR_EVENT (
         p_delegate_id        IN PER_PEOPLE_F.PERSON_ID%TYPE
       , p_event_id           IN OTA_EVENTS.EVENT_ID%TYPE
       , p_event_start_date   IN OTA_EVENTS.COURSE_START_DATE%TYPE
default null)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(CHK_DELEGATE_OK_FOR_EVENT, WNDS, WNPS);

--|--------------------------------------------------------------------------|
--|--< GET_CURRENT_PERSON_ID>-----------------------------------------|
--|--------------------------------------------------------------------------|

-- {Start Of Comments}
--
-- Description:
--   Called by dynamic sql to determine whether it is OK to show the delegate
--   the event in question. Only the events that they can enroll onto are
--   shown.
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- an exception is raised
--
-- Access Status:
-- Public
--
-- {End Of Comments}
--
----------------------------------------------------------------------------

FUNCTION Get_Current_Person_ID
		(p_item_type 	IN WF_ITEMS.ITEM_TYPE%TYPE
		,p_item_key	IN WF_ITEMS.ITEM_KEY%TYPE)
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |---------------------< CHECK_ENROLLMENT_CREATION>----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a concurrent process which run in the background.
--
--   This procedure will only be used for OTA and OM integration. Basically this
--   procedure will select all delegate booking data that has daemon_flag='Y' and
--   Daemon_type  is not nul. If the enrollment got canceled and there is a
--   waitlisted student then the automatic waitlist processing will be called.
--
-- Pre Conditions:
--   None.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
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
PROCEDURE CHECK_ENROLLMENT_CREATION(
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       IN    NUMBER
,funcmode    IN    VARCHAR2
,resultout		OUT NOCOPY	VARCHAR2
);

--
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

FUNCTION  Check_wf_Status (
p_item_key 	NUMBER,
p_activity varchar2,
p_item_type VARCHAR2
) RETURN Boolean;

--
-- ----------------------------------------
--   Workflow Cross Charges Notifications
-- ----------------------------------------
--
PROCEDURE Cross_Charges_Notifications ( itemtype	IN WF_ITEMS.ITEM_TYPE%TYPE,
					itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
					actid		IN NUMBER,
					funcmode	IN VARCHAR2,
					resultout	OUT NOCOPY VARCHAR2 );


PROCEDURE APPROVED ( itemtype	IN WF_ITEMS.ITEM_TYPE%TYPE,
					itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
					actid		IN NUMBER,
					funcmode	IN VARCHAR2,
					resultout	OUT NOCOPY VARCHAR2 );

--|--------------------------------------------------------------------------|
--|--< CHK_FOR_RESTRICTED_EVT >-------------------------------------------|
--|--------------------------------------------------------------------------|

-- {Start Of Comments}
--
-- Description:
--   Called by dynamic sql to determine whether event is restricted and it is OK to show the delegate
--   the event in question. Only the events that they can enroll onto are
--   shown.
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- an exception is raised
--
-- Access Status:
-- Public
--
-- {End Of Comments}
--
----------------------------------------------------------------------------

FUNCTION CHK_FOR_RESTRICTED_EVT (
        p_event_id           IN OTA_EVENTS.EVENT_ID%TYPE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(CHK_FOR_RESTRICTED_EVT, WNDS, WNPS);

--|--------------------------------------------------------------------------|
--|--< CHK_VALID_ACTIVITY >-------------------------------------------|
--|--------------------------------------------------------------------------|

-- {Start Of Comments}
--
-- Description:
--   Called before displaying the Activity details page to find out whether
--     a) Activity is valid else return 'I' (Invalid)
--     b) Activity is open else return 'E' (Expired)
--     c) Activity has events attached to it else return 'NE' (No Events)
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- an exception is raised
--
-- Access Status:
-- Public
--
-- {End Of Comments}
--
----------------------------------------------------------------------------



FUNCTION CHK_VALID_ACTIVITY(
        p_activity_id        IN OTA_ACTIVITY_VERSIONS.Activity_Version_Id%type
        )
RETURN VARCHAR2;


--|--------------------------------------------------------------------------|
--|--< CHK_VALID_EVENT >-------------------------------------------|
--|--------------------------------------------------------------------------|

-- {Start Of Comments}
--
-- Description:
--   Called before displaying the Event details page to find out whether
--     a) Event is valid else return 'I' (Invalid)
--     b) Event is open else return 'E' (Expired) or 'C' (closed)
--     c) Enrollment for the event is still open else return 'EC' (enrollment Closed) or
--        'ENS' (enrolmetn not yet started)
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- an exception is raised
--
-- Access Status:
-- Public
--
-- {End Of Comments}
--
----------------------------------------------------------------------------


FUNCTION CHK_VALID_EVENT(
        p_event_id           IN OTA_EVENTS.EVENT_ID%TYPE
        )
RETURN VARCHAR2;



Procedure CHK_UNIQUE_FUNC(p_function_name in varchar2,
                          p_user_id in number,
                          result out nocopy varchar2);

-- |--------------------------------------------------------------------------|
-- |--< Get_Booking_OVN >---------------------------------------------------|
-- |--------------------------------------------------------------------------|
-- {Start Of Comments}
--
FUNCTION Get_Booking_OVN (p_booking_id IN NUMBER)
RETURN NUMBER;
--

end OTA_EL_ENROLL_SS;


 

/
