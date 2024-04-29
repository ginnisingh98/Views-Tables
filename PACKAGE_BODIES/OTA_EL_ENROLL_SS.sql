--------------------------------------------------------
--  DDL for Package Body OTA_EL_ENROLL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EL_ENROLL_SS" as
/* $Header: otelenss.pkb 120.2.12010000.3 2009/02/11 12:42:45 pekasi ship $ */

g_package  varchar2(33)	:= ' OTA_EL_ENROLL_SS.';  -- Global package name

--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------<ProcessSaveEnrollment>-----------------------|
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
PROCEDURE ProcessSaveEnrollment( p_event_id	 IN VARCHAR2
				,p_extra_information		 IN VARCHAR2
				,p_mode				         IN VARCHAR2
                		,p_cost_centers		         IN VARCHAR2
        			,p_assignment_id			 IN PER_ALL_ASSIGNMENTS_F.assignment_id%TYPE
        			,p_business_group_id_from	 IN PER_ALL_ASSIGNMENTS_F.business_group_id%TYPE
				,p_business_group_name		 IN PER_BUSINESS_GROUPS.name%TYPE
        			,p_organization_id           IN PER_ALL_ASSIGNMENTS_F.organization_id%TYPE
				,p_item_type 			     IN WF_ITEMS.ITEM_TYPE%TYPE
				,p_person_id                 IN PER_ALL_PEOPLE_F.person_id%type
                		,p_booking_id                out nocopy OTA_DELEGATE_BOOKINGS.Booking_id%type
                		,p_message_name out nocopy varchar2
				,p_item_key 			     IN WF_ITEMS.ITEM_TYPE%TYPE
                                ,p_tdb_information_category            in varchar2
                                ,p_tdb_information1                    in varchar2
                                ,p_tdb_information2                    in varchar2
                                ,p_tdb_information3                    in varchar2
                                ,p_tdb_information4                    in varchar2
                                ,p_tdb_information5                    in varchar2
                                ,p_tdb_information6                    in varchar2
                                ,p_tdb_information7                    in varchar2
                                ,p_tdb_information8                    in varchar2
                                ,p_tdb_information9                    in varchar2
                                ,p_tdb_information10                   in varchar2
                                ,p_tdb_information11                   in varchar2
                                ,p_tdb_information12                   in varchar2
                                ,p_tdb_information13                   in varchar2
                                ,p_tdb_information14                   in varchar2
                                ,p_tdb_information15                   in varchar2
                                ,p_tdb_information16                   in varchar2
                                ,p_tdb_information17                   in varchar2
                                ,p_tdb_information18                   in varchar2
                                ,p_tdb_information19                   in varchar2
                                ,p_tdb_information20                   in varchar2 )
IS

CURSOR bg_to (pp_event_id	ota_events.event_id%TYPE) IS
SELECT hao.business_group_id,
       evt.organization_id,
       evt.currency_code,
       evt.course_start_date,
       evt.course_end_date,
       evttl.Title,
       evt.owner_id,
       evt.activity_version_id,
       evt.offering_id
FROM   OTA_EVENTS   evt,
       OTA_EVENTS_TL  evttl,
       HR_ALL_ORGANIZATION_UNITS  hao
WHERE  evt.event_id = pp_event_id
	AND evt.event_id = evttl.event_id
	AND evt.organization_id = hao.organization_id (+)
	AND evttl.language(+) = userenv('LANG'); -- Bug 2213009


Cursor Get_Event_status is
Select event_status, maximum_internal_attendees
from   OTA_EVENTS
WHERE  EVENT_ID = TO_NUMBER(p_event_id);

CURSOR get_existing_internal IS
SELECT count(*)
FROM   OTA_DELEGATE_BOOKINGS dbt,
       OTA_BOOKING_STATUS_TYPES bst
WHERE  dbt.event_id = TO_NUMBER(p_event_id)
AND    dbt.internal_booking_flag = 'Y'
AND    dbt.booking_status_type_id = bst.booking_status_type_id
AND    bst.type in ('P','A','E');


CURSOR c_get_price_basis is
SELECT nvl(price_basis,NULL)
FROM ota_events
where event_id = p_event_id;

CURSOR csr_user(p_owner_id in number) IS
SELECT
 USER_NAME
FROM
 FND_USER
WHERE
Employee_id = p_owner_id ;

CURSOR csr_activity(p_activity_version_id number )
IS
SELECT  version_name
FROM  OTA_ACTIVITY_VERSIONS_TL
WHERE  activity_version_id = p_activity_version_id AND language(+) = userenv('LANG');


  l_price_basis     OTA_EVENTS.price_basis%TYPE;

  l_person_details		csr_person_to_enroll_details%ROWTYPE;
  --
  l_booking_status_row		OTA_BOOKING_STATUS_TYPES%ROWTYPE;
  l_booking_id			OTA_DELEGATE_BOOKINGS.booking_id%type := null;
  l_object_version_number	BINARY_INTEGER;
  l_tfl_ovn				BINARY_INTEGER;
  l_finance_line_id		OTA_FINANCE_LINES.finance_line_id%type:= null;
  l_booking_type			VARCHAR2(4000);
  l_error_crypt			VARCHAR2(4000);
  --
  l_mode				VARCHAR2(200);
  l_delegate_id		      PER_PEOPLE_F.person_id%TYPE;
  l_restricted_assignment_id  PER_ASSIGNMENTS_F.assignment_id%type;
  l_cancel_boolean            BOOLEAN;
  -- -------------------
  --  Finance API Vars
  -- -------------------
  l_auto_create_finance		VARCHAR2(40);
  fapi_finance_header_id	OTA_FINANCE_LINES.finance_header_id%TYPE;
  fapi_object_version_number	OTA_FINANCE_LINES.object_version_number%TYPE;
  fapi_result			VARCHAR2(40);
  fapi_from				VARCHAR2(5);
  fapi_to				VARCHAR2(5);

  result_finance_header_id	OTA_FINANCE_LINES.finance_header_id%TYPE;
  result_create_finance_line 	VARCHAR2(5) := 'Y';
  result_object_version_number	OTA_FINANCE_LINES.object_version_number%TYPE;

  l_logged_in_user		NUMBER;
  l_user				NUMBER;
  l_automatic_transfer_gl	VARCHAR2(40);
  l_notification_text		VARCHAR2(1000);
  l_cost_allocation_keyflex_id  VARCHAR2(1000);

  l_event_status  varchar2(30);

  l_maximum_internal_attendees  NUMBER;
  l_existing_internal           NUMBER;
  l_maximum_internal_allowed    NUMBER;

  l_item_key     wf_items.item_key%type;
  l_called_from  varchar2(80);
  l_business_group_id_to  hr_all_organization_units.organization_id%type;
  l_sponsor_organization_id  hr_all_organization_units.organization_id%type;
  l_event_currency_code      ota_events.currency_code%type;
  l_event_title   ota_events.title%type;
  l_course_start_date ota_events.course_start_date%type;
  l_course_end_date ota_events.course_end_date%type;
  l_owner_id  ota_events.owner_id%type;
  l_activity_version_id ota_activity_versions.activity_version_id%type;
  l_version_name ota_activity_versions.version_name%type;
  l_owner_username fnd_user.user_name%type;
--Bug#2197997 commenting out completeactivity call.
--  l_return  boolean;
  l_offering_id ota_events.offering_id%type;
  l_booking_status_used    varchar2(20);

--  l_approval_req_flag  Varchar2(20);

BEGIN
/*
fnd_global.APPS_INITIALIZE(
    user_id =>1549,
    resp_id =>50677,
    resp_appl_id => 810);
*/

  HR_UTIL_MISC_WEB.VALIDATE_SESSION(p_person_id => l_logged_in_user);

  -- ----------------------------------------------------------------------
  --  RETRIEVE THE DATA REQUIRED
  -- ----------------------------------------------------------------------

  BEGIN


    l_item_key := p_item_key;

    l_delegate_id :=  p_person_id;

    l_restricted_assignment_id := CHK_DELEGATE_OK_FOR_EVENT(p_delegate_id => l_delegate_id
			   			       ,p_event_id    => p_event_id);


    l_person_details := Get_Person_To_Enroll_Details(p_person_id => l_delegate_id);


    /* Set Workflow Attribute */

    IF l_person_details.full_name is not null then
       WF_ENGINE.setitemattrtext(p_item_type,
                              l_item_key,
                              'CURRENT_PERSON_DISPLAY_NAME',
                             l_person_details.full_name);
    END IF;

    IF l_restricted_assignment_id IS NULL OR
       l_restricted_assignment_id = '-1' THEN
      NULL;
    ELSE
      l_person_details.assignment_id := l_restricted_assignment_id;
    END IF;

-- -----------------------------------------------
  --   Open BG Cursor to get the Business Group TO
  -- -----------------------------------------------
  OPEN  bg_to(p_event_id);
  FETCH bg_to INTO l_business_group_id_to,
                   l_sponsor_organization_id,
                   l_event_currency_code,
                   l_course_start_date,
                   l_course_end_date,
                   l_event_title,
                   l_owner_id,
                   l_activity_version_id,
                   l_offering_id;
  CLOSE bg_to;


  For act in csr_activity(l_activity_version_id)
  Loop
    l_version_name := act.version_name;
  End Loop;

  if l_owner_id is not null then
     For owner in csr_user(l_owner_id)
    Loop
      l_owner_username := owner.user_name;
    End Loop;
  end if;


  WF_ENGINE.setitemattrtext(p_item_type,
                            l_item_key,
                            'OTA_ACTIVITY_VERSION_NAME',
                             l_version_name);


  WF_ENGINE.setitemattrtext(p_item_type,
                            l_item_key,
                            'EVENT_OWNER_EMAIL',
                             l_owner_username);


  WF_ENGINE.setitemattrtext(p_item_type,
                            l_item_key,
                            'OTA_EVENT_TITLE',
                             l_event_title);

  WF_ENGINE.setitemattrtext(p_item_type,
                            l_item_key,
                            'OTA_COURSE_START_DATE',
                            l_course_start_date);

  WF_ENGINE.setitemattrtext(p_item_type,
                            l_item_key,
                            'OTA_COURSE_END_DATE',
                            l_course_end_date);

   WF_ENGINE.setitemattrnumber(p_item_type,
                            l_item_key,
                            'TRANSACTION_ID',
-- Bug#4617150
--                            hr_transaction_web.get_transaction_id
                            hr_transaction_ss.get_transaction_id
                                   (p_item_type => p_item_type
                                   ,p_item_key  => l_item_key));

    WF_ENGINE.setitemattrnumber(p_item_type,
                            l_item_key,
                            'FORWARD_FROM_PERSON_ID',
                            p_person_id);


  wf_engine.setItemAttrNumber(itemtype => p_item_type
                                   ,itemkey  => l_item_key
                                   ,aname    => 'EVENT_ID'
                                   ,avalue   => p_event_id);



    BEGIN  /* Check Booking Type */

    -- ---------------------------------
    -- Find Which booking status to use
    -- ---------------------------------
    -- Find out whether the person should be enrolled on the event directly
    -- or if they can just request to be enrolled.
    --
    -- The booking_type returned will be one of four possible values :
    --      Name			Enrollment Status
    --    MGR_APR_NO_ADMIN	         = Requested
    --    MGR_APR_WITH_ADMIN	         = Requested
    --    SELF_BOOKING	               = Attempt to enroll them
    --    TRAINING_ADMIN		   = Requested
    --
/*    l_booking_type  :=  wf_engine.GetItemAttrText(itemtype => p_item_type
			                                 ,itemkey  => l_item_key
			                                 ,aname    => 'ENROLL_IN_CLASS_APPROVAL_MODE');  */

/*    l_approval_req_flag  :=  wf_engine.GetItemAttrText(itemtype => p_item_type
			                                 ,itemkey  => l_item_key
			                                 ,aname    => 'HR_APPROVAL_REQ_FLAG');   */

null;
    EXCEPTION
      WHEN OTHERS THEN

        fnd_message.set_name ('OTA','OTA_13658_WF_ERR_GETTING_TYPE');
--Bug#4617150
--        RAISE OTA_ENROLL_CLASS_UTILITY_WEB.g_mesg_on_stack_exception ;
        RAISE g_mesg_on_stack_exception ;
          p_message_name :=  SUBSTR(SQLERRM, 1,300);
    END;  /* End Check booking Type */


--    IF (l_booking_type <> 'SELF_BOOKING') THEN
--    IF (l_approval_req_flag <> 'NO') THEN
      --
      -- The enrollment will have to be saved with a status of Requested,
      -- so get the ID for the seeded status.
      --
--      l_booking_status_row := Get_Booking_Status_for_web(
--	 p_web_booking_status_type => 'REQUESTED'
--        ,p_business_group_id 	   => ota_general.get_business_group_id);

--    ELSE

      -- The enrollment doesn't need mangerial approval so check the mode
      -- to find out whether they can only be waitlisted and then get the
      -- default booking status for either waitlisted or placed.

            OPEN  get_event_status;
            FETCH get_event_status into l_event_status, l_maximum_internal_attendees;
            CLOSE get_event_status;

            OPEN  get_existing_internal;
            FETCH get_existing_internal into l_existing_internal;
            CLOSE get_existing_internal;

            l_maximum_internal_allowed := nvl(l_maximum_internal_attendees,0) - l_existing_internal;

         IF l_event_status in ('F') THEN

            l_booking_status_row := Get_Booking_Status_for_web
			(p_web_booking_status_type => 'WAITLISTED'
			,p_business_group_id       => ota_general.get_business_group_id);

                l_booking_status_used := 'WAITLISTED';

          ELSIF l_event_status in ('P') THEN

            l_booking_status_row := Get_Booking_Status_for_web
			(p_web_booking_status_type => 'REQUESTED'
			,p_business_group_id       => ota_general.get_business_group_id);

                l_booking_status_used := 'REQUESTED';

         ELSIF l_event_status = 'N' THEN

            IF l_maximum_internal_attendees  is null then
               l_booking_status_row := Get_Booking_Status_for_web
			(p_web_booking_status_type => 'PLACED'
			,p_business_group_id       => ota_general.get_business_group_id);

                l_booking_status_used := 'PLACED';

            ELSE

              IF l_maximum_internal_allowed > 0 THEN
                 l_booking_status_row := Get_Booking_Status_for_web
			(p_web_booking_status_type => 'PLACED'
			,p_business_group_id       => ota_general.get_business_group_id);

                l_booking_status_used := 'PLACED';

              ELSIF l_maximum_internal_allowed <= 0  THEN
                    l_booking_status_row := Get_Booking_Status_for_web
       			(p_web_booking_status_type => 'WAITLISTED'
      			 ,p_business_group_id       => ota_general.get_business_group_id);

                l_booking_status_used := 'WAITLISTED';

              END IF;
            END IF;
--         END IF;
           IF l_booking_status_row.booking_Status_type_id is null then
              fnd_message.set_name ('OTA','OTA_13667_WEB_STATUS_NOT_SEEDE');
--Bug#4617150
--              RAISE OTA_ENROLL_CLASS_UTILITY_WEB.g_mesg_on_stack_exception ;
              RAISE g_mesg_on_stack_exception ;
           ELSE
               WF_ENGINE.setitemattrtext(p_item_type,
                            l_item_key,
                            'ENROLL_IN_A_CLASS_STATUS',
                             l_booking_status_row.name);


           END IF ;
      END IF;
        WF_ENGINE.setitemattrtext(p_item_type,
                            l_item_key,
                            'ENROLL_IN_A_CLASS_STATUS',
                             l_booking_status_row.name);

 --   END IF;

    EXCEPTION
-- Bug#4617150
--      WHEN OTA_ENROLL_CLASS_UTILITY_WEB.g_mesg_on_stack_exception THEN
      WHEN g_mesg_on_stack_exception THEN
        --
        -- Store the technical message which will have been seeded
        -- if this exception has been raised. This will be used to provide
        -- the code.
        --
        hr_message.provide_error;
        --
        -- Now distinguish which error was raised.
        --
      IF (hr_message.last_message_name = 'OTA_13667_WEB_STATUS_NOT_SEEDE') THEN
          --
          -- Seed the user friendly message
          --
          fnd_message.set_name ('OTA','OTA_WEB_INCORRECT_CONF');
          --
          -- Raise the error for the main procedure exception handler
	      -- to handle
          --
           p_message_name := hr_message.last_message_name;
          p_message_name :=   SUBSTR(SQLERRM, 1,300);
	  --
        ELSIF (hr_message.last_message_name = 'HR_51396_WEB_PERSON_NOT_FND')
          THEN
          --
          -- Seed the user friendly message
          --
          fnd_message.set_name ('OTA','OTA_NO_DELEGATE_INFORMATION');
          --
          -- Raise the error for the main procedure exception handler
	      -- to handle
           p_message_name := 'OTA_NO_DELEGATE_INFORMATION';
           p_message_name := SUBSTR(SQLERRM, 1,300);
          --
        ELSIF (hr_message.last_message_name = 'OTA_13658_WF_ERR_GETTING_TYPE')
          THEN
          --
          -- Seed the user friendly message
          --
          fnd_message.set_name ('OTA','OTA_WEB_WF_PROBLEM');
          -- Raise the error for the main procedure exception handler
	      -- to handle
          --
         p_message_name := fnd_message.get;
         p_message_name := SUBSTR(SQLERRM, 1,300);
	  --
        ELSE
         -- Raise the error for the main procedure exception handler
	  -- to handle
          p_message_name := hr_message.get_message_text;

          --
        END IF;
        --
      WHEN OTHERS THEN
        --
        -- Can't store a technical message, as we don't know what it is
        -- and a message may not have been put on the stack
        --
        hr_message.provide_error;
        --
        -- Seed the user friendly message
        --
        fnd_message.set_name ('OTA','OTA_WEB_ERR_GETTING_INFO');
        --
        --
        -- Raise the error for the main procedure exception handler
	-- to handle
      -- p_message_name := 'OTA_WEB_ERR_GETTING_INFO';

         p_message_name :=  SUBSTR(SQLERRM, 1,300);

    END ;
  --
  -- ----------------------------------------------------------------------
  -- Save
  -- ----------------------------------------------------------------------
  -- If there are no errors, save to the database
  -- (there shouldn't be as the main exception handler will be used
  --
--  IF NOT hr_errors_api.errorExists  THEN
IF p_message_name is null then


 BEGIN
  --
  -- Check to see if delegate has a booking status of CANCELLED for
  --  this event, if cancelled l_cancel_boolean is set to true
  --  FIX for bug 900679
  --
    l_cancel_boolean := Chk_Event_Cancelled_for_Person(p_event_id           => p_event_id
       						    ,p_delegate_person_id => l_delegate_id
       						    ,p_booking_id         => l_booking_id);

    l_auto_create_finance   := FND_PROFILE.value('OTA_AUTO_CREATE_FINANCE');
    l_automatic_transfer_gl := FND_PROFILE.value('OTA_SSHR_AUTO_GL_TRANSFER');
    l_user 		    := FND_PROFILE.value('USER_ID');

-- --------------------------------------------
--   Dynamic Notification Text for Workflow
-- --------------------------------------------
--    l_notification_text     := 'The Cross Charge details have been successfully obtained for the Enrollment record. ';

--      l_notification_text     := '  The appropriate cost center has been charged.';
      l_notification_text     := '  The cost center will be charged if appropriate.';

    IF (l_cancel_boolean) THEN
    --
    --  Delegate has a Cancelled status for this event, hence
    --  we must update the existing record by changing Cancelled
    --  to Requested status
    --
   /*   wf_engine.setItemAttrText (itemtype => p_item_type
					  ,itemkey  => l_item_key
					  ,aname    => 'BOOKING_STATUS_TYPE_ID'
					  ,avalue   => l_booking_status_row.booking_status_type_id); */

--Bug#4617150
--      l_object_version_number := OTA_ENROLL_CLASS_RETRIEVE_WEB.Get_Booking_OVN (p_booking_id => l_booking_id);
      l_object_version_number := Get_Booking_OVN (p_booking_id => l_booking_id);

      /* Call Cancel procedure to cancel the Finance if person Re-enroll */
      cancel_finance(l_booking_id);


  -- ----------------------------------------------------------------
  --   Delegate has no record for this event, hence create a record
  --   with requested status
  -- ----------------------------------------------------------------
  --   Check if the Profile AutoCreate Finance is ON or OFF
  -- ----------------------------------------------------------------
     END IF;
 --   ELSE
      open c_get_price_basis;
      fetch c_get_price_basis into l_price_basis;
      close c_get_price_basis;


--   l_approval_req_flag = 'NO' and included (Create finance only if self-approval is yes)

	IF l_auto_create_finance = 'Y' and
           l_price_basis <> 'N' and
--           l_approval_req_flag = 'NO' and
           l_event_currency_code is not null THEN

              l_cost_allocation_keyflex_id      := TO_NUMBER(p_cost_centers);
	      result_finance_header_id		:= fapi_finance_header_id;
  	      result_object_version_number	:= l_object_version_number;

              ota_crt_finance_segment.Create_Segment(
                         	p_assignment_id		     	=>	p_assignment_id,
							p_business_group_id_from    =>	p_business_group_id_from,
							p_business_group_id_to	    =>	l_business_group_id_to,
							p_organization_id	     	=>	p_organization_id,
							p_sponsor_organization_id   =>	l_sponsor_organization_id,
							p_event_id		     	    =>	p_event_id,
							p_person_id		     	    => 	l_delegate_id,
							p_currency_code		     	=>	l_event_currency_code,
							p_cost_allocation_keyflex_id=> 	l_cost_allocation_keyflex_id,
							p_user_id			        => 	l_user,
 							p_finance_header_id	     	=> 	fapi_finance_header_id,
							p_object_version_number	    => 	fapi_object_version_number,
							p_result		     	    => 	fapi_result,
							p_from_result		     	=> 	fapi_from,
							p_to_result		     	    => 	fapi_to );

			IF fapi_result = 'S' THEN

				wf_engine.setItemAttrText (itemtype => p_item_type
						 	  ,itemkey  => l_item_key
						  	  ,aname    => 'API_RESULT'
						  	  ,avalue   => fapi_result);

				wf_engine.setItemAttrText (itemtype => p_item_type
						  	  ,itemkey  => l_item_key
						  	  ,aname    => 'API_FROM'
						  	  ,avalue   => fapi_from);

				wf_engine.setItemAttrText (itemtype => p_item_type
						  	  ,itemkey  => l_item_key
						  	  ,aname    => 'API_TO'
						  	  ,avalue   => fapi_to);

				wf_engine.setItemAttrNumber(itemtype => p_item_type
						  	   ,itemkey  => l_item_key
						  	   ,aname    => 'EVENT_ID'
						  	   ,avalue   => p_event_id);

				wf_engine.setItemAttrText (itemtype => p_item_type
						  	   ,itemkey  => l_item_key
						  	   ,aname    => 'BUSINESS_GROUP_NAME'
						  	   ,avalue   => p_business_group_name);

				wf_engine.setItemAttrText (itemtype => p_item_type
						  	  ,itemkey  => l_item_key
						  	  ,aname    => 'NOTIFICATION_TEXT'
						  	  ,avalue   => l_notification_text);

				result_object_version_number := fapi_object_version_number;
				result_finance_header_id     := fapi_finance_header_id;

			ELSIF fapi_result = 'E' THEN

				l_notification_text := NULL;

				wf_engine.setItemAttrText (itemtype => p_item_type
						 	  ,itemkey  => l_item_key
						  	  ,aname    => 'API_RESULT'
						  	  ,avalue   => fapi_result);

				wf_engine.setItemAttrText (itemtype => p_item_type
						  	  ,itemkey  => l_item_key
						  	  ,aname    => 'API_FROM'
						  	  ,avalue   => fapi_from);

				wf_engine.setItemAttrText (itemtype => p_item_type
						  	  ,itemkey  => l_item_key
						  	  ,aname    => 'API_TO'
						  	  ,avalue   => fapi_to);

				wf_engine.setItemAttrNumber(itemtype => p_item_type
						  	   ,itemkey  => l_item_key
						  	   ,aname    => 'EVENT_ID'
						  	   ,avalue   => p_event_id);

				wf_engine.setItemAttrText (itemtype => p_item_type
						  	   ,itemkey  => l_item_key
						  	   ,aname    => 'BUSINESS_GROUP_NAME'
						  	   ,avalue   => p_business_group_name);

				wf_engine.setItemAttrText (itemtype => p_item_type
						  	  ,itemkey  => l_item_key
						  	  ,aname    => 'NOTIFICATION_TEXT'
						  	  ,avalue   => l_notification_text);

				result_object_version_number := l_object_version_number;
				result_finance_header_id     := NULL;
				result_create_finance_line   := NULL;
			END IF;

	      ota_tdb_api_ins2.Create_Enrollment(p_booking_id    =>	l_booking_id
      						,p_booking_status_type_id   	=>	l_booking_status_row.booking_status_type_id
      						,p_delegate_person_id       	=>	l_delegate_id
      						,p_contact_id               	=>	null
						,p_business_group_id        	=>	ota_general.get_business_group_id
      						,p_event_id                 	=>	p_event_id
      						,p_date_booking_placed     	    =>	trunc(sysdate)
      						,p_corespondent          	    => 	'S' --l_corespondent
      						,p_internal_booking_flag    	=> 	'Y'
      						,p_number_of_places         	=> 	1
      						,p_object_version_number    	=> 	result_object_version_number
      						,p_delegate_contact_phone	    => 	l_person_details.work_telephone
     						,p_source_of_booking        	=> 	'E'
      						,p_special_booking_instructions => 	p_extra_information
      						,p_successful_attendance_flag   => 	'N'
						,p_finance_header_id		    =>    result_finance_header_id
						,p_create_finance_line		    =>	result_create_finance_line
      						,p_finance_line_id          	=> 	l_finance_line_id
      						,p_enrollment_type          	=> 	'S'
						,p_validate               	    => 	FALSE
						,p_currency_code			    =>  l_event_currency_code
      						,p_organization_id          	=> 	l_person_details.organization_id
      						,p_delegate_assignment_id   	=> 	l_person_details.assignment_id
 					        ,p_delegate_contact_email 		=> 	l_person_details.email_address
                                                ,p_tdb_information_category     => p_tdb_information_category
                                                ,p_tdb_information1             => p_tdb_information1
                                                ,p_tdb_information2             => p_tdb_information2
                                                ,p_tdb_information3             => p_tdb_information3
                                                ,p_tdb_information4             => p_tdb_information4
                                                ,p_tdb_information5             => p_tdb_information5
                                                ,p_tdb_information6             => p_tdb_information6
                                                ,p_tdb_information7             => p_tdb_information7
                                                ,p_tdb_information8             => p_tdb_information8
                                                ,p_tdb_information9             => p_tdb_information9
                                                ,p_tdb_information10            => p_tdb_information10
                                                ,p_tdb_information11            => p_tdb_information11
                                                ,p_tdb_information12            => p_tdb_information12
                                                ,p_tdb_information13            => p_tdb_information13
                                                ,p_tdb_information14            => p_tdb_information14
                                                ,p_tdb_information15            => p_tdb_information15
                                                ,p_tdb_information16            => p_tdb_information16
                                                ,p_tdb_information17            => p_tdb_information17
                                                ,p_tdb_information18            => p_tdb_information18
                                                ,p_tdb_information19            => p_tdb_information19
                                                ,p_tdb_information20            => p_tdb_information20);


		IF l_automatic_transfer_gl = 'Y' AND l_finance_line_id IS NOT NULL AND l_offering_id is null THEN

			UPDATE ota_finance_lines SET transfer_status = 'AT'
			WHERE finance_line_id = l_finance_line_id;


		END IF;

		wf_engine.setItemAttrText (itemtype => p_item_type
					 	  ,itemkey  => l_item_key
		  			 	  ,aname    => 'BOOKING_STATUS_TYPE_ID'
	  			  	  	  ,avalue   => l_booking_status_row.booking_status_type_id);

	   ELSE

	      ota_tdb_api_ins2.Create_Enrollment(p_booking_id    =>	l_booking_id
      						,p_booking_status_type_id   	=>	l_booking_status_row.booking_status_type_id
      						,p_delegate_person_id       	=>	l_delegate_id
      						,p_contact_id               	=>	null
						,p_business_group_id        	=>	ota_general.get_business_group_id
      						,p_event_id                 	=>	p_event_id
      						,p_date_booking_placed     	    =>	trunc(sysdate)
      						,p_corespondent        		    => 	'S' --l_corespondent
      						,p_internal_booking_flag    	=> 	'Y'
      						,p_number_of_places         	=> 	1
      						,p_object_version_number    	=> 	l_object_version_number
      						,p_delegate_contact_phone	    => 	l_person_details.work_telephone
     						,p_source_of_booking        	=> 	'E'
      						,p_special_booking_instructions => 	p_extra_information
      						,p_successful_attendance_flag   => 	'N'
      						,p_finance_line_id          	=> 	l_finance_line_id
      						,p_enrollment_type          	=> 	'S'
						,p_validate               	    => 	FALSE
                                ,p_organization_id          	=> 	l_person_details.organization_id
      						,p_delegate_assignment_id   	=> 	l_person_details.assignment_id
 						,p_delegate_contact_email 		=> 	l_person_details.email_address
                                                ,p_tdb_information_category     => p_tdb_information_category
                                                ,p_tdb_information1             => p_tdb_information1
                                                ,p_tdb_information2             => p_tdb_information2
                                                ,p_tdb_information3             => p_tdb_information3
                                                ,p_tdb_information4             => p_tdb_information4
                                                ,p_tdb_information5             => p_tdb_information5
                                                ,p_tdb_information6             => p_tdb_information6
                                                ,p_tdb_information7             => p_tdb_information7
                                                ,p_tdb_information8             => p_tdb_information8
                                                ,p_tdb_information9             => p_tdb_information9
                                                ,p_tdb_information10            => p_tdb_information10
                                                ,p_tdb_information11            => p_tdb_information11
                                                ,p_tdb_information12            => p_tdb_information12
                                                ,p_tdb_information13            => p_tdb_information13
                                                ,p_tdb_information14            => p_tdb_information14
                                                ,p_tdb_information15            => p_tdb_information15
                                                ,p_tdb_information16            => p_tdb_information16
                                                ,p_tdb_information17            => p_tdb_information17
                                                ,p_tdb_information18            => p_tdb_information18
                                                ,p_tdb_information19            => p_tdb_information19
                                                ,p_tdb_information20            => p_tdb_information20);


		wf_engine.setItemAttrText (itemtype => p_item_type
					 	  ,itemkey  => l_item_key
		  			 	  ,aname    => 'BOOKING_STATUS_TYPE_ID'
		  			  	  ,avalue   => l_booking_status_row.booking_status_type_id);

	   END IF;


            p_booking_id :=  l_booking_id;

            WF_ENGINE.setitemattrtext(p_item_type,
                              l_item_key,
                              'BOOKING_ID',
                              l_booking_id);

             IF l_booking_id is not null then

/* Bug#2197997 Commenting out Completeactivity call.
                    l_return := check_wf_status(l_item_key,'BLOCK',p_item_type);
                       IF l_return = TRUE THEN
                          wf_engine.Completeactivity(p_item_type,l_item_key,'BLOCK',null);
                       END IF;
*/

                        IF l_booking_status_used = 'PLACED' then
                                 p_message_name := 'OTA_SS_CONFIRMED_PLACED';
                        ELSIF l_booking_status_used = 'WAITLISTED' then
                                 p_message_name := 'OTA_SS_CONFIRMED_WAITLISTED';
                        ELSIF l_booking_status_used = 'REQUESTED' then
                                p_message_name :=  'OTA_SS_CONFIRMED_REQUESTED';
                        END IF;



             END IF;

    EXCEPTION
      WHEN OTHERS THEN
      -- Both the Confirm Procedure and the API return APP-20002 or -20001
      -- so provide error can be used, as if the confirm procedure errors
      -- a different tool bar will be used.
      -- If the API has errored, the WF won't have been activated
      -- whereas if the confirm procedure errored, then it probably will have
      -- been.
      -- p_mode will be changed to indicate an error and,if it's a WF error
      -- the mode will also indicate this.
      -- Then the "Confirmation" page will be called from the main handler.
      --
      -- It is OK to use hr_message.provide_error as an application
      -- error will have been raised which will have put an error onto
      -- the stack
      --
  /*    IF (hr_message.last_message_name = 'OTA_13668_WEB_NO_TRANMISSION')
	  THEN
          --
          -- The WF may have already be transissioned, so change the mode.
          l_mode := l_mode || 'BADWF';
          --

      END IF; */
       p_message_name := fnd_message.get;
     --   p_message_name :=  SUBSTR(SQLERRM, 1,300);
        --
 END;       -- End of if p_message is not null

END IF;
EXCEPTION
  WHEN OTHERS THEN
     p_message_name :=  SUBSTR(SQLERRM, 1,300);
END ProcessSaveEnrollment;

-- -----------------------------------------------------
-- Procedure cancel_finance
-- -----------------------------------------------------
PROCEDURE cancel_finance(p_booking_id in number)
IS

-- ------------------------
--  Finance_cur Variables
-- ------------------------
    l_finance_line_id		 ota_finance_lines.finance_line_id%TYPE;
    l_finance_header_id	     ota_finance_lines.finance_header_id%TYPE;
    l_transfer_status  	     ota_finance_lines.transfer_status%TYPE;
    lf_booking_id            ota_finance_lines.booking_id%TYPE;
    lf_object_version_number ota_finance_lines.object_version_number%TYPE;
    l_sequence_number        ota_finance_lines.sequence_number%TYPE;
    l_raised_date		     date;
    l_finance_count          number(10);
    l_cancelled_flag         ota_finance_lines.cancelled_flag%type;
    l_cancel_header_id       ota_finance_headers.finance_header_id%TYPE;
-- ------------------------
--  header_cur Variables
-- ------------------------
    lh_finance_header_id	 ota_finance_headers.finance_header_id%TYPE;
    lh_cancelled_flag        ota_finance_headers.cancelled_flag%TYPE;
    lh_transfer_status  	 ota_finance_headers.transfer_status%TYPE;
    lh_object_version_number ota_finance_headers.object_version_number%TYPE;

CURSOR finance (p_booking_id ota_finance_lines.booking_id%TYPE) IS
SELECT FLN.finance_line_id	       finance_line_id,
	   FLN.finance_header_id       finance_header_id,
	   FLN.transfer_status	       transfer_status,
	   FLN.booking_id		       booking_id,
       FLN.object_version_number   object_version_number,
	   FLN.sequence_number         sequence_number,
       FLN.Cancelled_flag          cancelled_flag
  FROM OTA_FINANCE_LINES FLN
 WHERE FLN.booking_id = p_booking_id;

CURSOR  finance_count (p_finance_header_id   ota_finance_lines.finance_header_id%TYPE) IS
SELECT 	count(*)
  FROM	OTA_FINANCE_LINES	FLN
 WHERE	FLN.finance_header_id = p_finance_header_id;

CURSOR header (p_booking_id   ota_finance_lines.booking_id%TYPE) IS
SELECT FLH.finance_header_id	   finance_header_id,
	   FLH.cancelled_flag	       cancelled_flag,
	   FLH.transfer_status	       transfer_status,
	   FLH.object_version_number   object_version_number
  FROM OTA_FINANCE_HEADERS	FLH,
	   OTA_FINANCE_LINES    FLN
 WHERE FLH.finance_header_id  =   FLN.finance_header_id
   AND FLN.booking_id         =   p_booking_id;

BEGIN

OPEN  finance (p_booking_id);
       FETCH finance INTO l_finance_line_id,
		       	  l_finance_header_id,
			        l_transfer_status,
			        lf_booking_id,
			        lf_object_version_number,
			        l_sequence_number,
                          l_cancelled_flag ;

        IF finance%found  THEN
        -- IF l_finance_line_id is not null THEN


          IF l_transfer_status = 'ST' or l_cancelled_flag = 'Y' THEN
	 	 NULL;
	    ELSE

		-- ----------------------------------------------
		-- Call Finance Lines API (Cancel Finance Line)
		-- ----------------------------------------------

        --   select sysdate into l_raised_date from dual;	-- Select Date from the System for p_date_raised
	    -- END IF;

	     OPEN  finance_count (l_finance_header_id);
	     FETCH finance_count INTO l_finance_count;
	     CLOSE finance_count;

	     IF l_finance_count = 1 THEN

		-- ---------------------------
		--  If only one Finance Line
		-- ---------------------------

		  OPEN  header (p_booking_id);
		  FETCH header INTO  lh_finance_header_id,
				             lh_cancelled_flag,
				             lh_transfer_status,
		                     lh_object_version_number;

		  IF lh_transfer_status <> 'ST' or lh_cancelled_flag <>'Y'  THEN
			-- -------------------------------------------------
			--  Call Finance Header API (Cancel Finance Header)
			-- -------------------------------------------------
                 l_raised_date := sysdate;
                 ota_tfh_api_business_rules.cancel_header(p_finance_header_id   =>  lh_finance_header_id
      				                                     ,p_cancel_header_id    =>  l_cancel_header_id
     					                                 ,p_date_raised         =>  l_raised_date
     					                                 ,p_validate            =>  false
     					                                 ,p_commit              =>  false);
	   	  END IF;

          ELSE
               l_raised_date := sysdate;
               ota_tfl_api_upd.upd(p_finance_line_id       =>  l_finance_line_id
                                  ,p_date_raised           =>  l_raised_date
                                  ,p_cancelled_flag        => 'Y'
                                  ,p_object_version_number =>  lf_object_version_number
                                  ,p_sequence_number       =>  l_sequence_number
                                  ,p_validate              =>  false
                                  ,p_transaction_type      => 'CANCEL_HEADER_LINE');

	     END IF;
           CLOSE header;
         END IF; -- For Lines;

    -- else
	-- ---------------------------------------
	--  Call the API to Cancel the Enrollment
	-- ---------------------------------------

      END IF;
      CLOSE finance;

END cancel_finance;

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
RETURN OTA_BOOKING_STATUS_TYPES%ROWTYPE

IS

  l_booking_status_row OTA_BOOKING_STATUS_TYPES%ROWTYPE DEFAULT NULL;


BEGIN

  OPEN csr_booking_status_id (p_business_group_id       => p_business_group_id
	        	     ,p_web_booking_status_type => p_web_booking_status_type);
  FETCH csr_booking_status_id INTO l_booking_status_row;

  IF ( csr_booking_status_id%NOTFOUND ) THEN
     --
     CLOSE csr_booking_status_id;
     --
     -- Seed a technical message so that if the calling procedure decides
     -- that it is an error having nothing returned, it can use it.
     --
     fnd_message.set_name ('OTA','OTA_13667_WEB_STATUS_NOT_SEEDE');
     Fnd_message.raise_error;
     --
     RETURN l_booking_status_row;
     --
  ELSE
     --
     CLOSE csr_booking_status_id;
     --
     RETURN l_booking_status_row;
     --
  END IF;
  RETURN l_booking_status_row;
END Get_Booking_Status_For_Web;
--

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
 p_cost_center    out nocopy varchar2
)
IS

Cursor csr_cost IS
SELECT assg.assignment_id,
assg.business_group_id,
assg.organization_id,
pcak.cost_allocation_keyflex_id,
pcak.concatenated_segments,
pcaf.proportion
FROM per_all_people_f ppf,
per_all_assignments_f assg,
pay_cost_allocations_f pcaf,
pay_cost_allocation_keyflex pcak
WHERE ppf.person_id = p_person_id
AND ppf.person_id = assg.person_id
AND assg.assignment_id = pcaf.assignment_id
AND assg.Primary_flag = 'Y'
AND pcaf.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id
AND pcak.enabled_flag = 'Y'
AND sysdate between nvl(pcaf.effective_start_date,sysdate)
and nvl(pcaf.effective_end_date,sysdate+1)
AND sysdate between nvl(assg.effective_start_date,sysdate)
and nvl(assg.effective_end_date,sysdate+1)
AND sysdate between nvl(ppf.effective_start_date,sysdate)
and nvl(ppf.effective_end_date,sysdate+1);


CURSOR get_assignment(p_delegate_id   per_all_people_f.person_id%TYPE) IS
SELECT   assg.assignment_id,
         assg.business_group_id,
         assg.organization_id
FROM     per_all_people_f                ppf,
         per_all_assignments_f           assg
WHERE    ppf.person_id                      = p_delegate_id
AND      ppf.person_id                   = assg.person_id
AND      sysdate between nvl(assg.effective_start_date,sysdate)
         and nvl(assg.effective_end_date,sysdate+1)
AND      assg.primary_flag = 'Y'
AND      sysdate between nvl(ppf.effective_start_date,sysdate)
         and nvl(ppf.effective_end_date,sysdate+1);


l_proc 	varchar2(72) := g_package||'return_api_dml_status';
l_no  number := 0;
BEGIN

--
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  For a in csr_cost loop
  l_no := l_no+1;
  p_cost_alloc_keyflex_id  :=a.cost_allocation_keyflex_id;
  p_business_group_id :=a.business_group_id ;
  p_assignment_id  :=a.assignment_id  ;
  p_organization_id :=a.organization_id ;
--Bug#2228669 hdshah proportion and Percentage sign included.
  p_cost_center    := a.concatenated_segments ||' ----- '|| a.proportion*100 ||' %';
  end loop;
  p_no_cost_center := l_no;

  if l_no = 0 then
     for asg_rec in get_assignment(p_person_id) loop
     p_business_group_id :=asg_rec.business_group_id ;
     p_assignment_id  :=asg_rec.assignment_id  ;
     p_organization_id :=asg_rec.organization_id ;
     end loop;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

END check_cost_center;

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
(p_process 		in wf_process_activities.process_name%type,
p_itemtype 		in wf_items.item_type%type,
p_person_id 	in number ,
p_called_from     in varchar2 ,
p_itemkey         out nocopy wf_items.item_key%type
 )
IS

l_proc 	varchar2(72) := g_package||'create_enroll_wf_process';
l_process             	wf_activities.name%type := upper(p_process);
l_item_type    wf_items.item_type%type := upper(p_itemtype);
  l_item_key     wf_items.item_key%type;


l_user_name  varchar2(80);
l_current_username varchar2(80):= fnd_profile.value('USERNAME');
l_current_user_Id  number := fnd_profile.value('USER_ID');
l_creator_person_id   per_all_people_f.person_id%type;

CURSOR C_USER IS
SELECT
 EMPLOYEE_ID
FROM
 FND_USER
WHERE
 user_id = l_current_user_id ;

BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);

OPEN C_USER;
FETCH C_USER INTO l_creator_person_id;
CLOSE C_USER;

 hr_utility.set_location('Entering:'||l_proc, 10);
 -- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;


WF_ENGINE.CREATEPROCESS(l_item_type, l_item_key, l_process);
WF_ENGINE.setitemattrtext(p_itemtype, l_item_key, 'CURRENT_PERSON_ID', p_person_id);
WF_ENGINE.setitemattrtext(p_itemtype, l_item_key, 'CREATOR_PERSON_USERNAME', l_current_username);
WF_ENGINE.setitemattrtext(p_itemtype, l_item_key, 'CREATOR_PERSON_ID', l_creator_person_id);
WF_ENGINE.setitemattrtext(p_itemtype, l_item_key, 'PROCESS_DISPLAY_NAME', 'Enroll in a Training Event');


--WF_ENGINE.SetItemattrtext(p_itemtype,p_item_key, 'EVENT_OWNER',l_user_name);
WF_ENGINE.STARTPROCESS(p_itemtype,l_item_key);

p_itemkey:=l_item_key;

EXCEPTION
WHEN OTHERS THEN
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	hr_utility.set_location('leaving:'||l_proc, 20);


End create_enroll_wf_process;


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
RETURN csr_person_to_enroll_details%ROWTYPE

IS
  --
  l_csr_person_to_enroll_details	csr_person_to_enroll_details%ROWTYPE;
  --
  l_person_id 	BINARY_INTEGER;

BEGIN
  --
  OPEN csr_person_to_enroll_details (p_person_id);
  --
  FETCH  csr_person_to_enroll_details INTO l_csr_person_to_enroll_details;
  --
  IF csr_person_to_enroll_details%NOTFOUND THEN
    CLOSE csr_person_to_enroll_details;
    fnd_message.set_name('PER','HR_51396_WEB_PERSON_NOT_FND');
-- Bug#4617150
--    RAISE OTA_ENROLL_CLASS_UTILITY_WEB.g_mesg_on_stack_exception ;
    RAISE g_mesg_on_stack_exception ;
  ELSE
    CLOSE csr_person_to_enroll_details;
    RETURN l_csr_person_to_enroll_details;
  END IF;

EXCEPTION
-- Bug#4617150
--  WHEN OTA_ENROLL_CLASS_UTILITY_WEB.g_mesg_on_stack_exception THEN
  WHEN g_mesg_on_stack_exception THEN
    --
      -- Handle the exception in the calling code.
    RAISE; --OTA_ENROLL_CLASS_UTILITY_WEB.g_mesg_on_stack_exception ;

  WHEN OTHERS THEN
    fnd_message.set_name('PER','HR_51396_WEB_PERSON_NOT_FND');
    RAISE;

END Get_Person_To_Enroll_Details;


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

PROCEDURE Validate_enrollment(p_person_id  per_all_people_f.PERSON_ID%TYPE,
				     p_event_id	IN VARCHAR2,
				     p_double_book  out nocopy VARCHAR2 )

IS

l_person_details
	csr_person_to_enroll_details%ROWTYPE;
l_cancel_boolean  boolean;
l_dummy number;
Begin
p_double_book := 'N';
l_person_details := Get_Person_To_Enroll_Details(p_person_id => p_person_id);

l_cancel_boolean :=
        Chk_Event_Cancelled_for_Person
         (p_event_id => p_event_id
         ,p_delegate_person_id => p_person_id
         ,p_booking_id => l_dummy);
   IF (l_cancel_boolean) THEN
  -- Delegate has Cancelled status, so dont check for unique_booking
  --  as a row exists for  delegate, for this event
     null;
   ELSE
     ota_tdb_bus.check_unique_booking
	(p_customer_id		=> ''
	,p_organization_id	=> l_person_details.organization_id
	,p_event_id		=> p_event_id
	,p_delegate_person_id 	=> p_person_id
	,p_delegate_contact_id	=> ''
	,p_booking_id		=> '');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
     p_double_book := 'Y';


end Validate_Enrollment;


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
RETURN BOOLEAN

IS

  CURSOR csr_chk_event
	(p_event_id IN NUMBER
        ,p_person_id IN NUMBER) IS
  SELECT ov.booking_id
  FROM   ota_booking_status_types os,
         ota_delegate_bookings ov
  WHERE  ov.event_id = p_event_id
  AND    ov.delegate_person_id = p_person_id
  AND    os.booking_status_type_id = ov.booking_status_type_id
  AND    os.type = 'C';

CURSOR csr_chk_event_placed
	(p_event_id IN NUMBER
        ,p_person_id IN NUMBER) IS
  SELECT ov.booking_id
  FROM   ota_booking_status_types os,
         ota_delegate_bookings ov
  WHERE  ov.event_id = p_event_id
  AND    ov.delegate_person_id = p_person_id
  AND    os.booking_status_type_id = ov.booking_status_type_id
  AND    os.type <> 'C';

  l_temp 	csr_chk_event%rowtype;
  l_enroll_exist  boolean := False;

BEGIN

  OPEN  csr_chk_event(p_event_id, p_delegate_person_id);
  FETCH csr_chk_event INTO l_temp;

  p_booking_id := l_temp.booking_id;

  IF csr_chk_event%FOUND THEN


     For r_enroll in csr_chk_event_placed(p_event_id, p_delegate_person_id)
     LOOP
       if r_enroll.booking_id is not null then
          l_enroll_exist := True;
       end if;
     END LOOP;
      if l_enroll_exist then
     	   RETURN FALSE;
      else
         	RETURN TRUE;
      end if;


  ELSE
  -- PERSON DOES NOT HAVE A BOOKING STATUS OF CANCELLED FOR THIS EVENT
  --
  	RETURN FALSE;
  --
  END IF;

  --  p_booking_id := l_temp.booking_id;
  CLOSE csr_chk_event;
END Chk_Event_Cancelled_for_Person;

-- |--------------------------------------------------------------------------|
-- |---------------< Chk_booking_clash >--------------------------------------|
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
procedure Chk_booking_clash (p_event_id 		IN NUMBER
					,p_person_id	IN NUMBER
					,p_booking_Clash 	OUT NOCOPY varchar2)
IS
  l_booking_status_row		OTA_BOOKING_STATUS_TYPES%ROWTYPE;
  l_booking_status_type_id    ota_booking_status_types.booking_status_type_id%type;


Begin

l_booking_status_row := Get_Booking_Status_for_web
			(p_web_booking_status_type => 'PLACED'
			,p_business_group_id       => ota_general.get_business_group_id);

l_booking_status_type_id    := l_booking_status_row.booking_status_type_id;

IF ota_tdb_bus2.other_bookings_clash(
              p_delegate_person_id => p_person_id
             ,p_delegate_contact_id=> ''
             ,p_event_id           => p_event_id
              ,p_booking_status_type_id     => l_booking_status_type_id    ) THEN

 p_booking_clash := 'Y';
ELSE
  p_booking_clash := 'N';

END IF;

end  Chk_booking_clash;

--|--------------------------------------------------------------------------|
--|--< CHK_FOR_SECURE_EVT >-------------------------------------------|
--|--------------------------------------------------------------------------|

FUNCTION CHK_FOR_SECURE_EVT (
         p_delegate_id        IN PER_PEOPLE_F.PERSON_ID%TYPE
       , p_event_id           IN OTA_EVENTS.EVENT_ID%TYPE)
RETURN VARCHAR2
IS

 CURSOR C_GET_SECURE_FLAG is
 SELECT secure_event_flag,organization_id
 from ota_events
 where event_id = p_event_id;

 CURSOR C_GET_ORG_ID is
 SELECT organization_id
 from per_all_assignments_f
 where person_id = p_delegate_id and
       trunc(sysdate) between effective_start_date and
effective_end_date;


  l_secure_flag varchar2(1);
  l_evt_organization_id  OTA_EVENTS.ORGANIZATION_ID%TYPE;
  l_per_organization_id  PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID%TYPE;
  l_return_value  varchar2(2000);

BEGIN

  OPEN C_GET_SECURE_FLAG;
  FETCH C_GET_SECURE_FLAG into l_secure_flag,l_evt_organization_id;
  IF C_GET_SECURE_FLAG%NOTFOUND then
     CLOSE C_GET_SECURE_FLAG;
     l_return_value := NULL;
     return l_return_value;
  ELSE
     CLOSE C_GET_SECURE_FLAG;
  END IF;
IF l_secure_flag = 'Y' then

   OPEN C_GET_ORG_ID;
   FETCH C_GET_ORG_ID into l_per_organization_id;
   IF C_GET_ORG_ID%NOTFOUND then
      CLOSE C_GET_ORG_ID;
      l_return_value := NULL;
      return l_return_value;
   ELSE
      CLOSE C_GET_ORG_ID;
   END IF;
       if l_per_organization_id = l_evt_organization_id then
          l_return_value := '-1';
      else
          l_return_value := NULL;
      end if;
ELSE
     l_return_value := '-1';

END IF;

   RETURN l_return_value;

END CHK_FOR_SECURE_EVT;


--|--------------------------------------------------------------------------|
--|--< CHK_DELEGATE_OK_FOR_EVENT>-------------------------------------------|
--|--------------------------------------------------------------------------|

FUNCTION CHK_DELEGATE_OK_FOR_EVENT (
         p_delegate_id        IN PER_PEOPLE_F.PERSON_ID%TYPE
       , p_event_id           IN OTA_EVENTS.EVENT_ID%TYPE
       , p_event_start_date   IN OTA_EVENTS.COURSE_START_DATE%TYPE
)
RETURN VARCHAR2

IS
  CURSOR csr_event_associations  IS
  SELECT ea.organization_id, ea.job_id, ea.position_id
  FROM   ota_event_associations ea
  WHERE  ea.event_id = p_event_id;
  --

  CURSOR csr_event_start_date IS
  SELECT course_start_date
  --  FROM otv_scheduled_events
      FROM ota_events
   WHERE event_id = p_event_id and
  --Bug#2201434  SELFPACED event_type included.
  --     event_type='SCHEDULED' and
         event_type in ('SCHEDULED','SELFPACED') and
         event_status in('P','N','F')and
         TRUNC(SYSDATE) BETWEEN NVL( ENROLMENT_START_DATE, TRUNC(
SYSDATE)) AND
         NVL( ENROLMENT_END_DATE, TRUNC( SYSDATE)) AND
         TRUNC(SYSDATE) <= NVL( COURSE_END_DATE, TRUNC(SYSDATE));
  --
  CURSOR csr_asg_details
         (p_organization_id OTA_EVENT_ASSOCIATIONS.organization_id%TYPE
         ,p_job_id          OTA_EVENT_ASSOCIATIONS.job_id%TYPE
         ,p_position_id     OTA_EVENT_ASSOCIATIONS.position_id%TYPE
         ,p_course_start_date
otv_scheduled_events.course_start_date%type) IS
  SELECT paf.assignment_id
  FROM per_all_assignments_f paf
  WHERE paf.person_id            = p_delegate_id
  AND NVL(p_course_start_date,trunc(sysdate)) BETWEEN
paf.effective_start_date AND paf.effective_end_date
  AND NVL(p_organization_id, -1) = DECODE(p_organization_id, null, -1,
NVL(paf.organization_id,-1))
  AND NVL(p_job_id, -1)          = DECODE(p_job_id, null, -1,
NVL(paf.job_id, -1))
  AND NVL(p_position_id,-1)      = DECODE(p_position_id, null, -1,
NVL(paf.position_id, -1))
  AND paf.assignment_type        = 'E';
  --
  l_return_value  varchar2(4000);
  l_event_start_date   otv_scheduled_events.course_start_date%type;

BEGIN
--Bug#2201434 default value of l_return_value modified to '-1' from null.
--  l_return_value := null;
  l_return_value := '-1';
  IF p_event_start_date IS null THEN
    OPEN csr_event_start_date;
    FETCH csr_event_start_date INTO l_event_start_date;
    CLOSE csr_event_start_date;
  ELSE
    l_event_start_date := p_event_start_date;
  END IF;

  FOR assoc IN csr_event_associations LOOP
    -- For each of the event restrictions, loop
    OPEN csr_asg_details
         (p_organization_id    => assoc.organization_id
         ,p_job_id             => assoc.job_id
         ,p_position_id        => assoc.position_id
         ,p_course_start_date  => l_event_start_date);
    FETCH csr_asg_details INTO l_return_value;
    IF (csr_asg_details%FOUND) THEN
         l_return_value := '-1';
       CLOSE csr_asg_details;
       EXIT;
    ELSE
      -- The delegate hasn't got an assignment which satified the needs
      -- of all the event associations, so set the return value to 'N'
      CLOSE csr_asg_details;
      l_return_value := NULL;
    END IF;
  END LOOP;

RETURN l_return_value;
END CHK_DELEGATE_OK_FOR_EVENT;


FUNCTION Get_Current_Person_ID
		(p_item_type 	IN WF_ITEMS.ITEM_TYPE%TYPE
		,p_item_key	IN WF_ITEMS.ITEM_KEY%TYPE)
RETURN NUMBER

IS
  l_current_person_id NUMBER;

BEGIN
  --

  l_current_person_id := wf_engine.getItemAttrNumber
	(itemtype  => p_item_type
	,itemkey   => p_item_key
	,aname	   => 'CURRENT_PERSON_ID');
  --


  RETURN l_current_person_id;
END Get_Current_Person_ID;

-- ----------------------------------------------------------------------------
-- |------------------------< CHECK_ENROLLMENT_CREATION>----------------------|
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
)

IS

l_booking_id ota_delegate_bookings.booking_id%type;
l_proc 	varchar2(72) := g_package||'check_enrollment_creation';


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
 IF (funcmode = 'RUN') THEN
     l_booking_id  :=  wf_engine.GetItemAttrNUMBER(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'BOOKING_ID');

      IF l_booking_id is not null then
    	     resultout := wf_engine.eng_completed || ':' || 'Y';
	  ELSE
	     resultout := wf_engine.eng_completed || ':' || 'N';
	  END IF;



 END IF;
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  IF (funcmode = 'CANCEL') THEN

    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'Check_Creation',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
END;


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
p_item_type VARCHAR2)

return boolean

IS

l_proc 	varchar2(72) := g_package||'Check_wf_Status' ;
l_exist 	varchar2(1);
l_return    boolean :=False;

CURSOR line_wf IS
        SELECT null
     FROM wf_item_activity_statuses_v wf
     WHERE activity_name = p_activity
           AND activity_status_code = 'NOTIFIED'
           AND item_type = p_item_type
                 AND item_key = p_item_key;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  	OPEN line_wf;
      fetch line_wf into l_exist;
	if line_wf%found then
         l_return := True;
 	end if;
      CLOSE line_wf;
      Return(l_return);

hr_utility.set_location('Leaving:'||l_proc, 10);
END check_wf_status;

--
-- -----------------------------------------------------------
--   Cross Charges Notifications (Workflow Notifications)
-- -----------------------------------------------------------
--
PROCEDURE Cross_Charges_Notifications ( itemtype	IN WF_ITEMS.ITEM_TYPE%TYPE,
					itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
					actid		IN NUMBER,
					funcmode	IN VARCHAR2,
					resultout	OUT NOCOPY VARCHAR2 )
IS

CURSOR user_name(p_event_id	OTA_EVENTS.event_id%TYPE) IS
SELECT usr.user_name,
       evt.offering_id
FROM   OTA_EVENTS 	evt,
       FND_USER        USR
WHERE  evt.event_id = p_event_id and
       usr.employee_id = evt.owner_id;


CURSOR csr_booking_status(p_booking_id ota_delegate_bookings.booking_id%type) IS
SELECT bst.Type
FROM   OTA_DELEGATE_BOOKINGS tdb,
       OTA_BOOKING_STATUS_TYPES bst
WHERE  tdb.booking_id = p_booking_id
AND    bst.booking_status_type_id = tdb.booking_status_type_id;


l_api_result		VARCHAR2(4000);
l_api_from		VARCHAR2(4000);
l_api_to		VARCHAR2(4000);
l_event_id		NUMBER;
l_user_name		FND_USER.USER_NAME%TYPE;
l_offering_id   ota_events.offering_id%type;
l_booking_id    ota_delegate_bookings.booking_id%type;
l_version_name  ota_activity_versions.version_name%type;
l_notification_text  varchar2(2000);
l_status_type   ota_booking_status_types.type%type;
BEGIN

l_event_id   := wf_engine.GetItemAttrNumber(itemtype => itemtype
					   ,itemkey  => itemkey
					   ,aname    => 'EVENT_ID');

OPEN  user_name(l_event_id);
FETCH user_name INTO l_user_name, l_offering_id;
CLOSE user_name;


     l_booking_id := wf_engine.GetItemAttrNumber(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'BOOKING_ID');

    l_notification_text := wf_engine.GetItemAttrText(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'NOTIFICATION_TEXT');

    l_version_name := wf_engine.GetItemAttrText(itemtype => itemtype
			                                 ,itemkey  => itemkey
			                                 ,aname    => 'OTA_ACTIVITY_VERSION_NAME');

    IF l_booking_id is not null then

       For sts in csr_booking_status(l_booking_id)
       LOOP
          l_status_type := sts.type;
       END LOOP;
/*
      if l_status_type = 'P' and l_offering_id is not null  then
         l_notification_text := l_notification_text
       || '   Your enrollment has now been approved. Please go to My Current and Planned Training to play the content '
       || l_version_name ||'.';

         wf_engine.setItemAttrText (itemtype => itemtype
			 	  ,itemkey  => itemkey
			  	  ,aname    => 'NOTIFICATION_TEXT'
			  	  ,avalue   => l_notification_text);
       end if;
*/
		if l_status_type = 'P' then
		         if l_offering_id is not null  then
        		    l_notification_text := l_notification_text
                                          || '  The student can now play the content '
                                          || l_version_name ||'.';
	        	    wf_engine.setItemAttrText (itemtype => itemtype
					       ,itemkey  => itemkey
					       ,aname    => 'NOTIFICATION_TEXT'
					       ,avalue   => l_notification_text);

		          end if;
	       elsif  l_status_type = 'W' then

	        l_notification_text := l_notification_text || '  The student has been placed on a waiting list. ';

		             wf_engine.setItemAttrText (itemtype => itemtype
						       ,itemkey  => itemkey
						       ,aname    => 'NOTIFICATION_TEXT'
						       ,avalue   => l_notification_text);
	      end if;

    END IF;

	wf_engine.setItemAttrText (itemtype => itemtype
			 	  ,itemkey  => itemkey
			  	  ,aname    => 'EVENT_OWNER_EMAIL'
			  	  ,avalue   => l_user_name);

	l_api_result := wf_engine.GetItemAttrText(itemtype => itemtype
					 	 ,itemkey  => itemkey
					 	 ,aname    => 'API_RESULT');

	l_api_from   := wf_engine.GetItemAttrText(itemtype => itemtype
					 	 ,itemkey  => itemkey
					 	 ,aname    => 'API_FROM');

	l_api_to     := wf_engine.GetItemAttrText(itemtype => itemtype
					 	 ,itemkey  => itemkey
					 	 ,aname    => 'API_TO');

	IF (funcmode='RUN') THEN

		IF l_api_result = 'S' THEN
			resultout:='COMPLETE:SUCCESS';
			RETURN;
		ELSE
	     		IF l_api_from IS NOT NULL THEN
				resultout:='COMPLETE:FROM_ERROR';

	     		ELSIF l_api_to IS NOT NULL THEN
				resultout:='COMPLETE:ERROR_TO';
                ELSE
                  resultout:='COMPLETE:SUCCESS';
		   	    RETURN;
	     		END IF;
		END IF;

	END IF;

	IF (funcmode='CANCEL') THEN
		resultout:='COMPLETE';
		RETURN;
	END IF;

END Cross_Charges_Notifications;

/* Added By Dharma */
--
-- ------------------------------------------------------------------
--  PROCEDURE Approved
-- ------------------------------------------------------------------
--
PROCEDURE Approved  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT NOCOPY VARCHAR2 )  IS

BEGIN

	IF (funcmode='RUN') THEN
		wf_engine.setItemAttrText (itemtype => itemtype
			 	  ,itemkey  => itemkey
			  	  ,aname    => 'APPROVAL_RESULT'
			  	  ,avalue   => 'ACCEPTED');
                   resultout:='COMPLETE';
                 RETURN;
	END IF;

	IF (funcmode='CANCEL') THEN
		resultout:='COMPLETE';
		RETURN;
	END IF;

END Approved;

--|--------------------------------------------------------------------------|
--|--< CHK_FOR_RESTRICTED_EVT >-------------------------------------------|
--|--------------------------------------------------------------------------|

FUNCTION CHK_FOR_RESTRICTED_EVT (
        p_event_id           IN OTA_EVENTS.EVENT_ID%TYPE)
RETURN VARCHAR2
IS

 CURSOR C_GET_EVT_DETAILS is
 SELECT EVT.public_event_flag,EVT.maximum_internal_attendees
 from ota_events EVT, ota_event_associations EVA
 where EVT.event_id = p_event_id and
       EVT.event_id = EVA.event_id and
       EVA.customer_id is not null;

  l_public_event_flag  OTA_EVENTS.PUBLIC_EVENT_FLAG%TYPE;
  l_maximum_internal_attendees  OTA_EVENTS.MAXIMUM_INTERNAL_ATTENDEES%TYPE;
  l_return_value  varchar2(10);

BEGIN

  OPEN C_GET_EVT_DETAILS;
  FETCH C_GET_EVT_DETAILS into l_public_event_flag,l_maximum_internal_attendees;
  IF C_GET_EVT_DETAILS%NOTFOUND then
     CLOSE C_GET_EVT_DETAILS;
     l_return_value := '-1';
     return l_return_value;
  ELSE
     CLOSE C_GET_EVT_DETAILS;
  END IF;

IF l_public_event_flag = 'N' then

   IF l_maximum_internal_attendees = 0 then
     l_return_value := NULL;
   ELSE
     l_return_value := '-1';
   END IF;

ELSE
     l_return_value := '-1';

END IF;

   RETURN l_return_value;

END CHK_FOR_RESTRICTED_EVT;

--|--------------------------------------------------------------------------|
--|--< CHK_VALID_ACTIVITY >-------------------------------------------|
--|--------------------------------------------------------------------------|

FUNCTION CHK_VALID_ACTIVITY(
      --  p_event_id           IN OTA_EVENTS.EVENT_ID%TYPE,
        p_activity_id        IN OTA_ACTIVITY_VERSIONS.Activity_Version_Id%type
        )
RETURN VARCHAR2
IS
-- checking for expired AND INVALID activity
 CURSOR C_GET_ACT_DET(l_activity_id OTA_ACTIVITY_VERSIONS.Activity_Version_Id%type)
 is
 /* Modified for Bug#3585535
 SELECT activity_version_id,end_date from ota_activity_versions
 where Activity_version_id = l_activity_id
 and developer_organization_id=ota_general.get_business_group_id;
 */
 SELECT activity_version_id, end_date
 FROM ota_activity_versions tav, ota_activity_definitions tad
 WHERE tav.activity_id = tad.activity_id
 AND tad.business_group_id = ota_general.get_business_group_id
 AND tav.activity_version_id = l_activity_id;


 CURSOR C_GET_EVT_ATTACHED(l_activity_id OTA_ACTIVITY_VERSIONS.Activity_Version_Id%type)
 is
 SELECT 1 from ota_events
 where Activity_version_id=l_activity_id
 and business_group_id=ota_general.get_business_group_id;



  l_return_value  varchar2(10):='V';
  l_date Date;
  l_activity number(10);
  l_event number(2);

BEGIN

  OPEN C_GET_ACT_DET(p_activity_id);
  FETCH C_GET_ACT_DET into l_activity,l_date;
  IF C_GET_ACT_DET%NOTFOUND then --implies invalid activityid
     CLOSE C_GET_ACT_DET;
     l_return_value := 'I';
     return l_return_value;
  ELSif(l_date<sysdate) then --implies Expired Activity
     CLOSE C_GET_ACT_DET;
     l_return_value := 'E';
        RETURN l_return_value;
  ELSE
      OPEN C_GET_EVT_ATTACHED(p_activity_id);
      FETCH C_GET_EVT_ATTACHED into l_event;
      IF C_GET_EVT_ATTACHED%NOTFOUND then --implies no event attached with activityid
         CLOSE C_GET_EVT_ATTACHED;
         CLOSE C_GET_ACT_DET;
         l_return_value := 'NE';
         return l_return_value;

      END IF;
      CLOSE C_GET_EVT_ATTACHED;
  END IF;

      CLOSE C_GET_ACT_DET;

      Return l_return_value;


END CHK_VALID_ACTIVITY;



--|--------------------------------------------------------------------------|
--|--< CHK_VALID_EVENT >-------------------------------------------|
--|--------------------------------------------------------------------------|

FUNCTION CHK_VALID_EVENT(
        p_event_id           IN OTA_EVENTS.EVENT_ID%TYPE
        )
RETURN VARCHAR2
IS
-- checking for  INVALID Events
 CURSOR C_GET_EVT(l_event_id OTA_EVENTS.EVENT_ID%TYPE)
 is
 SELECT event_id from ota_events
 where event_id = l_event_id;

/*checking for valid evetns
-- CURSOR C_GET_EVT_DET(l_event_id OTA_EVENTS.EVENT_ID%TYPE)
 is
 SELECT event_id from ota_events
 where event_id = l_event_id
 And     trunc(sysdate) between nvl(trunc(tav.start_date),trunc(sysdate)) and
              nvl(trunc(tav.end_date),trunc(sysdate))
      And     evt.event_type IN ('SCHEDULED','SELFPACED')
      And     evt.book_independent_flag = 'N'
      And     evt.Event_status in('N','P','F')
      And     trunc(sysdate) between nvl(trunc(evt.enrolment_start_date),trunc(sysdate)) and
              nvl(trunc(evt.enrolment_end_date),trunc(sysdate)) ;
 */

 CURSOR C_GET_EVT_DET(l_event_id OTA_EVENTS.EVENT_ID%TYPE)
 is
 SELECT event_id,event_status,course_start_date,course_end_date,enrolment_start_date,
 enrolment_end_date
 from ota_events
 where event_id = l_event_id
 and event_type in ('SCHEDULED','SELFPACED')
 and business_group_id=ota_general.get_business_group_id ;


  l_return_value  varchar2(10):='V';
  l_stDate Date;
  l_endDate Date;
  l_evtStatus varchar2(10);
  l_enrlStDate Date;
  l_enrlEndDate Date;
  l_event Number(10);

BEGIN

  l_return_value := ota_learner_enroll_ss.chk_valid_event(p_event_id);
 /*
  OPEN C_GET_EVT(p_event_id);
  FETCH C_GET_EVT into l_event;
  IF C_GET_EVT%NOTFOUND then --implies invalid eventid
     CLOSE C_GET_EVT;
     l_return_value := 'I';
     return l_return_value;

  END IF;

  CLOSE C_GET_EVT;

  OPEN C_GET_EVT_DET(p_event_id);
  FETCH C_GET_EVT_DET into l_event,l_evtStatus,l_stDate,l_endDate,l_enrlStDate,l_enrlEndDate;
  IF C_GET_EVT_DET%NOTFOUND then
     CLOSE C_GET_EVT_DET;
     l_return_value:= 'DFBG';  --implies different BG for event
     Return l_return_value;
  ElSIF (l_evtStatus<>'N' and l_evtStatus<>'P' and l_evtStatus<>'F') then
    -- dbms_output.put_line('in c');
     CLOSE C_GET_EVT_DET;
     l_return_value:= 'C';  --implies canceled event
     Return l_return_value;

  ELSIF (sysdate> l_endDate) then
        CLOSE C_GET_EVT_DET;
     l_return_value:= 'E';--Expired
     Return l_return_value;

  ELSIF (sysdate > l_enrlEndDate) then
        CLOSE C_GET_EVT_DET;
     l_return_value:= 'EC'; --Enrollment closed
     Return l_return_value;

  ELSIF (sysdate < l_enrlStDate) then
        CLOSE C_GET_EVT_DET;
     l_return_value:= 'ENS'; --enrollment not started
     Return l_return_value;

  END IF;

      CLOSE C_GET_EVT_DET;

     -- dbms_output.put_line(l_return_value);
  */
      Return l_return_value;


END CHK_VALID_EVENT;


Procedure CHK_UNIQUE_FUNC(p_function_name in varchar2,
                          p_user_id in number,
                          result out nocopy varchar2)
IS

responsibility_id_tab resp_id_tab;
security_group_id_tab sec_id_tab;

cursor getFunctionId(l_function_name in varchar2) is
      select function_id
      from   fnd_form_functions
      where  function_name = l_function_name;

cursor getResp(l_user_id in varchar2) is
      select  fr.menu_id, furg.responsibility_id,
              furg.security_group_id, furg.responsibility_application_id
      from    fnd_responsibility fr,
              fnd_user_resp_groups furg,
              fnd_user fu
      where   fu.USER_ID = l_user_id
      and     fu.START_DATE <= sysdate
      and     (fu.END_DATE is null or fu.END_DATE > sysdate)
      and     furg.USER_ID = fu.USER_ID
      and     furg.START_DATE <= sysdate
      and     (furg.END_DATE is null or furg.END_DATE > sysdate)
      and     furg.RESPONSIBILITY_APPLICATION_ID = fr.APPLICATION_ID
      and     furg.RESPONSIBILITY_ID = fr.RESPONSIBILITY_ID
      and     fr.VERSION = 'W'
      and     fr.START_DATE <= sysdate
      and     (fr.END_DATE is null or fr.END_DATE > sysdate);

      l_function_id number(10);
      l_responsibility_id number(10);
      l_security_group_id number(10);
      i number(5):=0;
      j number(5):=0;
      tot_cnt number(5);
    --  result varchar2(2):='S';

Begin

result :='S';
-- Get function id of current function
      open getFunctionId(p_function_name);
      fetch getFunctionId into l_function_id;
      close getFunctionId;
-- Get user ID of current user (If not available)
 --  select USER_ID
  --  into   l_user_id
 --   from   FND_USER
   -- where  USER_NAME = l_username;

-- Get responsibility ID

      for ri in getResp(p_user_id) loop

        if fnd_function.is_function_on_menu(ri.menu_id, l_function_id)
        then


             i:=i+1;


          responsibility_id_tab(i) := ri.responsibility_id;


          security_group_id_tab(i) := ri.security_group_id;
        end if;
      end loop;

      tot_cnt:=i;

      if (tot_cnt=0) then

         result :='NR'; --(no Responsibility)

      Elsif (tot_cnt>1) then

         result:='ME';


      End if;

 end CHK_UNIQUE_FUNC;

--
-- |--------------------------------------------------------------------------|
-- |--< Get_Booking_OVN >-----------------------------------------------------|
-- |--------------------------------------------------------------------------|
FUNCTION Get_Booking_OVN (p_booking_id IN NUMBER)
RETURN NUMBER

IS

  CURSOR csr_get_ovn IS
  SELECT object_version_number
  FROM   ota_delegate_bookings
  WHERE  booking_id  = p_booking_id;
  --
  l_ovn         BINARY_INTEGER  DEFAULT '';

BEGIN
  -- Get the Object Version No. of the Enrollment.
  --
  OPEN  csr_get_ovn;
  FETCH csr_get_ovn INTO l_ovn;

  IF csr_get_ovn%NOTFOUND THEN
    --
    -- Major Problem as the record can't be located.
    --
    CLOSE csr_get_ovn;
    --
    -- Set a technical message, then the calling proc can decide
    -- what to do.
    --
    fnd_message.set_name('OTA','OTA_13661_PROB_GETTING_DATA');
    --
    --
  ELSE
    --
    CLOSE csr_get_ovn;
    --
  END IF;
  --
  RETURN l_ovn;
  --
END Get_Booking_OVN;
--
end OTA_EL_ENROLL_SS;


/
