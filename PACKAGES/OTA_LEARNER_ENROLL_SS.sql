--------------------------------------------------------
--  DDL for Package OTA_LEARNER_ENROLL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LEARNER_ENROLL_SS" AUTHID CURRENT_USER as
/* $Header: otlnrenr.pkh 120.9.12010000.3 2008/08/22 06:32:17 pvelugul ship $ */

Type resp_id_tab is table of fnd_user_resp_groups.responsibility_id%type INDEX BY BINARY_INTEGER;
Type sec_id_tab is table of fnd_user_resp_groups.security_group_id%type INDEX BY BINARY_INTEGER;


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
    AND bst.ACTIVE_FLAG = 'Y'
    AND rownum=1
    AND bst.type = DECODE(p_web_booking_status_type, 'REQUESTED', 'R'
					       , 'WAITLISTED','W'
					       , 'CANCELLED', 'C'
					       , 'ATTENDED' , 'A'
					       , 'PLACED'   , 'P'
					       , 'PENDING EVALUATION', 'E')
        -- The name is like W: ( highest priority choice)
    AND (  (bstt.name like 'W:%' and bst.ACTIVE_FLAG = 'Y')
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
					       , 'PLACED'   , 'P'
					       , 'PENDING EVALUATION', 'E')
                          AND bstt1.name like 'W:%' AND bst1.active_flag = 'Y')
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
					       , 'PLACED'   , 'P'
					       , 'PENDING EVALUATION', 'E')
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
         --  ,pp.work_telephone
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
            ,pph.PHONE_NUMBER work_telephone
           ,pfax.PHONE_NUMBER work_fax
    FROM    per_all_people_f        pp
           ,per_all_assignments_f   asg
           ,per_all_people_f        p2
           ,per_all_assignments_f   asg2
	   ,per_person_types        ppt
	   ,per_person_type_usages_f  ptu
        --   ,per_addresses     ad
           ,hr_locations_all     loc
           ,hr_all_organization_units org
           , per_phones pph
           , per_phones pfax
    WHERE   pp.person_id         = p_person_id
    AND     trunc(sysdate) BETWEEN pp.effective_start_date AND pp.effective_end_date
    and     asg.person_id        = pp.person_id
    --Modified for bug#5579345
    --AND     (asg.primary_flag     = 'Y' Or ppt.system_person_type = 'APL') -- Added OR condition for 3885568
    AND    ( (asg.primary_flag     = 'Y' AND ppt.system_person_type in ('EMP', 'CWK'))
       Or (asg.assignment_type = 'A' and ppt.system_person_type ='APL'))
    AND     trunc(sysdate) BETWEEN asg.effective_start_date AND asg.effective_end_date
    AND     ptu.person_id = pp.person_id
    AND     trunc(sysdate) between ptu.effective_start_Date and ptu.effective_end_date
    and     ppt.business_group_id = pp.business_group_id
    and     ptu.person_type_id = ppt.person_type_id
    and     p2.person_id(+)      = asg.supervisor_id
    AND     trunc(sysdate) BETWEEN p2.effective_start_date(+) AND p2.effective_end_date(+)
    and     asg2.person_id(+)    = asg.supervisor_id
    AND     asg2.primary_flag(+) = 'Y'
    AND     trunc(sysdate) BETWEEN asg2.effective_start_date(+) AND asg2.effective_end_date(+)
 --   AND     ad.person_id       = pp.person_id
 --   AND     ad.primary_flag    = 'Y'
 --   AND     trunc(sysdate)BETWEEN ad.date_from AND nvl(ad.date_to, trunc(sysdate))
    and     asg.organization_id  = org.organization_id
    and     org.location_id      = loc.location_id (+)
    AND pph.PARENT_ID(+) = pp.PERSON_ID
        AND pph.PARENT_TABLE(+) = 'PER_ALL_PEOPLE_F'
        AND pph.PHONE_TYPE(+) = 'W1'
        AND trunc(sysdate) BETWEEN NVL(PPH.DATE_FROM(+), SYSDATE) AND NVL(PPH.DATE_TO(+), SYSDATE)
        AND pfax.PARENT_ID(+) = pp.PERSON_ID
        AND pfax.PARENT_TABLE(+) = 'PER_ALL_PEOPLE_F'
        AND pfax.PHONE_TYPE(+) = 'WF'
    AND trunc(sysdate) BETWEEN NVL(pfax.DATE_FROM(+), SYSDATE) AND NVL(pfax.DATE_TO(+), SYSDATE)
    order by asg.primary_flag desc; --Bug#6872547
--
-- Cursor to retrieve necessary information in order to save the enrollment

CURSOR csr_ext_lrnr_details (p_delegate_contact_id  number) IS
select substrb( PARTY.person_last_name,1,50)  LAST_NAME,
          substrb( PARTY.person_first_name,1,40)  FIRST_NAME,
	    party.person_pre_name_adjunct title,
         ACCT_ROLE.cust_account_role_id CONTACT_ID,
         ACCT_ROLE.cust_account_id CUSTOMER_ID

from    HZ_CUST_ACCOUNT_ROLES acct_role,
    	HZ_PARTIES party,
      HZ_RELATIONSHIPS rel,
      HZ_ORG_CONTACTS org_cont,
      HZ_PARTIES rel_party,
      HZ_CUST_ACCOUNTS role_acct

where acct_role.party_id = rel.party_id
   and acct_role.role_type = 'CONTACT'
   and org_cont.party_relationship_id = rel.relationship_id
   and rel.subject_id = party.party_id
   and rel.party_id = rel_party.party_id
   and rel.subject_table_name = 'HZ_PARTIES'
   and rel.object_table_name = 'HZ_PARTIES'
   and acct_role.cust_account_id = role_acct.cust_account_id
   and role_acct.party_id	= rel.object_id
   and ACCT_ROLE.cust_account_role_id = p_delegate_contact_id;

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
				,p_person_id                 IN PER_ALL_PEOPLE_F.person_id%type
                ,p_delegate_contact_id       IN NUMBER
                ,p_booking_id                out nocopy OTA_DELEGATE_BOOKINGS.Booking_id%type
                , p_message_name out nocopy varchar2
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
                                ,p_tdb_information20                   in varchar2     default null
				,p_booking_justification_id       in varchar2     default null);

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

Procedure supervisor_exists  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 );

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
-- |----------------------<Get_ext_lrnr_Details >----------------------|
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

FUNCTION Get_ext_lrnr_Details (p_delegate_contact_id IN NUMBER)
RETURN csr_ext_lrnr_Details%ROWTYPE;
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
                              p_delegate_contact_id IN NUMBER,
				     p_event_id	IN VARCHAR2,
				     p_double_book  OUT nocopy VARCHAR2);

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
                    ,p_delegate_contact_id IN NUMBER
					,p_booking_id 		OUT nocopy NUMBER)
RETURN BOOLEAN;

procedure Chk_booking_clash (p_event_id 		IN NUMBER
					,p_person_id	IN NUMBER
                    ,p_delegate_contact_id IN NUMBER
					,p_booking_Clash 	OUT nocopy varchar2)
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
        ,p_delegate_contact_id IN NUMBER
       , p_event_id           IN OTA_EVENTS.EVENT_ID%TYPE)
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(CHK_FOR_SECURE_EVT, WNDS, WNPS);


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
 --Modified for bug#5032859
--PRAGMA RESTRICT_REFERENCES(CHK_DELEGATE_OK_FOR_EVENT, WNDS, WNPS);


--
-- ----------------------------------------------------------------------------
-- |--------------------------------< Get_Booking_OVN >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function will be used to return object version number of an enrollment.
--
-- IN
-- p_booking_id
--
-- OUT
-- p_ovn
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

FUNCTION Get_Booking_OVN (p_booking_id IN NUMBER)
RETURN NUMBER;


--
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
        p_event_id           IN OTA_EVENTS.EVENT_ID%TYPE,
        p_delegate_contact_id        IN NUMBER)
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(CHK_FOR_RESTRICTED_EVT, WNDS, WNPS);



-- ----------------------------------------------------------------------------
-- |-----------------------------< cancel_enrollment>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be called from the View Enrollment Details Screen on pressing 'Submit'.
--
--   This procedure will be used to call the cancel the enrollment Id passed in and
--   update the Enrollment with the Cancellation details.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_booking_id
--   p_event_id
--   p_booking_status_type_id
--   p_cancel_reason
--   p_waitlist_size
--
-- Out Arguments:
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
PROCEDURE cancel_enrollment
                        (x_return_status OUT NOCOPY VARCHAR2,
                         p_booking_id IN NUMBER,
                         p_event_id IN NUMBER,
                         p_booking_status_type_id IN NUMBER,
                         p_cancel_reason IN VARCHAR2,
                         p_waitlist_size IN NUMBER,
            			 p_tdb_information_category IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information1 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information2 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information3 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information4 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information5 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information6 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information7 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information8 IN VARCHAR2 DEFAULT NULL,
			             p_tdb_information9 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information10 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information11 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information12 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information13 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information14 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information15 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information16 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information17 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information18 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information19 IN VARCHAR2 DEFAULT NULL,
            			 p_tdb_information20 IN VARCHAR2 DEFAULT NULL,
            			 p_failure_reason IN varchar2 DEFAULT NULL,
            			 p_attendance_result IN varchar2 DEFAULT NULL,
            			 p_successful_attendance_flag  IN varchar2  DEFAULT NULL,
                         p_comments                     in varchar2  DEFAULT NULL        );

Procedure CHK_UNIQUE_FUNC(p_function_name in varchar2,
                          p_user_id in number,
                          result out nocopy varchar2);

--|--------------------------------------------------------------------------|
--|--< CHK_VALID_ACTIVITY >-------------------------------------------|
--|--------------------------------------------------------------------------|

-- {Start Of Comments}
--
-- Description:
--   Called before displaying the Course details page to find out whether
--     a) Activity is valid else return 'I' (Invalid)
--     b) Activity is open else return 'E' (Expired)
--     c) Activity has offerings attached to it else return 'NO'(No Offerings)
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
--|--< CHK_VALID_OFFERING >-------------------------------------------|
--|--------------------------------------------------------------------------|

-- {Start Of Comments}
--
-- Description:
--   Called before displaying the Offering details page to find out whether
--     a) Offering is valid else return 'I' (Invalid)
--     b) Offering is open else return 'E' (Expired)
--     c) Offering has events attached to it else return 'NE'(No Events)
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



FUNCTION CHK_VALID_OFFERING(
        p_offering_id        IN OTA_OFFERINGS.offering_id%type
        )
RETURN VARCHAR2;


--|--------------------------------------------------------------------------|
--|--< CHK_VALID_EVENT >-------------------------------------------|
--|--------------------------------------------------------------------------|

-- {Start Of Comments}
--
-- Description:
--   Called before displaying the Class details page to find out whether
--     a) Event is valid else return 'I' (Invalid)
--     b) Event is open else return 'E' (Expired) or 'C' (closed)
--     c) Enrollment for the event is still open else return 'EC' (enrollment Closed) or
--        'ENS' (enrollment not yet started)
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

PROCEDURE get_wf_attr_for_cancel_ntf
          (p_event_id           IN ota_events.event_id%TYPE,
           p_person_id          IN number,
    	   p_supervisor_username OUT NOCOPY fnd_user.user_name%TYPE,
    	   p_supervisor_full_name  OUT NOCOPY per_all_people_f.full_name%TYPE,
    	   p_supervisor_id  OUT NOCOPY per_all_people_f.person_id%Type,
    	   p_current_person_name OUT NOCOPY VARCHAR2,
           p_current_username OUT NOCOPY VARCHAR2,
    	   p_person_displayname OUT NOCOPY per_all_people_f.full_name%TYPE,
    	   p_creator_displayname OUT NOCOPY per_all_people_f.full_name%TYPE,
    	   x_return_status      OUT NOCOPY VARCHAR2);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_booking_status_comments >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: get the comments from the booking history table for the
-- booking_id and booking_status_type_id passed in as parameters.
--
--
FUNCTION get_booking_status_comments(p_booking_id IN NUMBER,
                                     p_booking_status_type_id IN NUMBER) RETURN VARCHAR2;
--
-- ---------------------------------------------------------------------------------|
-- |-------------------------< getCancellationStatusId >----------------------------|
-- ---------------------------------------------------------------------------------|
--
-- Description: Retrieves the default cancellation enrollment status id
--
--
Function getCancellationStatusId
RETURN ota_booking_status_types.booking_status_type_id%type;

end ota_learner_enroll_ss ;

/
