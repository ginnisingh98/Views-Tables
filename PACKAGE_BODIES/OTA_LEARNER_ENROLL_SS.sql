--------------------------------------------------------
--  DDL for Package Body OTA_LEARNER_ENROLL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LEARNER_ENROLL_SS" as
/* $Header: otlnrenr.pkb 120.12.12010000.5 2009/05/26 04:59:39 shwnayak ship $ */

g_package  varchar2(33)	:= ' ota_learner_enroll_ss.';  -- Global package name

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
				,p_person_id                 IN PER_ALL_PEOPLE_F.person_id%type
            -- Added for External LearnerSupport
                ,p_delegate_contact_id       IN NUMBER
                ,p_booking_id                out nocopy OTA_DELEGATE_BOOKINGS.Booking_id%type
                ,p_message_name out nocopy varchar2
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
                                ,p_tdb_information20                   in varchar2
				,p_booking_justification_id         in varchar2)
IS

CURSOR bg_to (pp_event_id	ota_events.event_id%TYPE) IS
SELECT hao.business_group_id,
       evt.organization_id,
       evt.currency_code,
       evt.course_start_date,
       evt.course_end_date,
       evt.Title,
       evt.owner_id,
       off.activity_version_id,
       evt.offering_id
FROM   OTA_EVENTS_VL 		 evt,
       OTA_OFFERINGS         off,
       HR_ALL_ORGANIZATION_UNITS hao
WHERE  evt.event_id = pp_event_id
AND    off.offering_id = evt.parent_offering_id
AND    evt.organization_id = hao.organization_id (+);


Cursor Get_Event_status is
Select event_status, maximum_internal_attendees, maximum_attendees
from   OTA_EVENTS
WHERE  EVENT_ID = TO_NUMBER(p_event_id);

CURSOR get_existing_internal IS
SELECT count(booking_id)
FROM   OTA_DELEGATE_BOOKINGS dbt,
       OTA_BOOKING_STATUS_TYPES bst
WHERE  dbt.event_id = TO_NUMBER(p_event_id)
AND    dbt.internal_booking_flag = 'Y'
AND    dbt.booking_status_type_id = bst.booking_status_type_id
AND    bst.type in ('P','A','E'); --Bug 4301617

CURSOR get_existing_bookings IS
SELECT sum(number_of_places)
FROM   OTA_DELEGATE_BOOKINGS dbt,
       OTA_BOOKING_STATUS_TYPES bst
WHERE  dbt.event_id = TO_NUMBER(p_event_id)
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
SELECT version_name
FROM OTA_ACTIVITY_VERSIONS_TL
WHERE activity_version_id = p_activity_version_id
AND language=userenv('LANG');

CURSOR csr_get_priority IS
SELECT bjs.priority_level
FROM ota_bkng_justifications_b BJS
WHERE bjs.booking_justification_id = p_booking_justification_id;


  l_price_basis     OTA_EVENTS.price_basis%TYPE;

  l_person_details		OTA_LEARNER_ENROLL_SS.csr_person_to_enroll_details%ROWTYPE;
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
  l_offering_id ota_events.offering_id%type;
  l_booking_status_used    varchar2(20);

 l_existing_bookings           NUMBER;
 l_maximum_external_allowed    NUMBER;
 l_maximum_attendees           NUMBER;
 l_internal_booking_flag       OTA_DELEGATE_BOOKINGS.internal_booking_flag%TYPE;
 l_work_telephone              OTA_DELEGATE_BOOKINGS.delegate_contact_phone%TYPE := NULL;
 l_work_fax                    OTA_DELEGATE_BOOKINGS.delegate_contact_fax%TYPE := NULL;
 l_organization_id             OTA_DELEGATE_BOOKINGS.organization_id%TYPE := NULL;
 l_assignment_id               OTA_DELEGATE_BOOKINGS.delegate_assignment_id%TYPE := NULL;
 l_email_address               OTA_DELEGATE_BOOKINGS.delegate_contact_email%TYPE := NULL;
 l_person_address_type         varchar2(1);
 l_ext_lrnr_details   	       csr_ext_lrnr_Details%ROWTYPE;
 l_customer_id                 HZ_CUST_ACCOUNT_ROLES.cust_account_id%type := NULL;
 l_corespondent                varchar2(1) := NULL;
 l_source_of_booking           varchar2(30) := NULL;        --Bug 5580960 : Incleased the SIZE.
 l_enrollment_type             varchar2(1) := 'S';
 l_priority_level varchar2(30) := null;
BEGIN

  HR_UTIL_MISC_WEB.VALIDATE_SESSION(p_person_id => l_logged_in_user);

  -- ----------------------------------------------------------------------
  --  RETRIEVE THE DATA REQUIRED
  -- ----------------------------------------------------------------------

  BEGIN

  IF p_booking_justification_id IS NOT NULL THEN
     OPEN csr_get_priority;
     FETCH csr_get_priority INTO l_priority_level;
     CLOSE csr_get_priority;
  END IF;

  IF p_person_id IS NOT NULL THEN
    l_delegate_id :=  p_person_id;
    l_person_address_type := 'I';
    l_corespondent := 'S';
    --l_source_of_booking := 'E';				   Bug 5580960: removed hardcoding. Now Source of Booking will be decided by profile value OTA_DEFAULT_ENROLLMENT_SOURCE
    l_source_of_booking := fnd_profile.value('OTA_DEFAULT_ENROLLMENT_SOURCE');

    l_restricted_assignment_id := CHK_DELEGATE_OK_FOR_EVENT(p_delegate_id => l_delegate_id
			   			       ,p_event_id    => p_event_id);


    l_person_details := Get_Person_To_Enroll_Details(p_person_id => l_delegate_id);
    l_internal_booking_flag       := 'Y';
    l_work_telephone              := l_person_details.work_telephone;
    l_work_fax                    := l_person_details.work_fax;
    l_organization_id             := l_person_details.organization_id;
    l_assignment_id               := l_person_details.assignment_id;
    l_email_address               := l_person_details.email_address;

    IF l_restricted_assignment_id IS NULL OR
       l_restricted_assignment_id = '-1' THEN
      NULL;
    ELSE
      l_person_details.assignment_id := l_restricted_assignment_id;
    END IF;
  ELSE
    l_internal_booking_flag       := 'N';
    l_person_address_type	  := null;
    l_ext_lrnr_details            := Get_ext_lrnr_Details(p_delegate_contact_id);
    l_customer_id                 := l_ext_lrnr_details.customer_id;
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


      -- The enrollment doesn't need mangerial approval so check the mode
      -- to find out whether they can only be waitlisted and then get the
      -- default booking status for either waitlisted or placed.

            OPEN  get_event_status;
            FETCH get_event_status into l_event_status, l_maximum_internal_attendees,l_maximum_attendees;
            CLOSE get_event_status;

     IF p_person_id IS NOT NULL THEN
            OPEN  get_existing_internal;
            FETCH get_existing_internal into l_existing_internal;
            CLOSE get_existing_internal;

            l_maximum_internal_allowed := nvl(l_maximum_internal_attendees,0) - nvl(l_existing_internal,0);
     ELSE
            OPEN  get_existing_bookings;
            FETCH get_existing_bookings into l_existing_bookings;
            CLOSE get_existing_bookings;

            l_maximum_external_allowed := nvl(l_maximum_attendees,0) - nvl(l_existing_bookings,0);
     END IF;

--Create enrollments in Waitlisted status for planned class
         IF l_event_status in ('F','P') THEN

            l_booking_status_row := Get_Booking_Status_for_web
			(p_web_booking_status_type => 'WAITLISTED'
			,p_business_group_id       => ota_general.get_business_group_id);

                l_booking_status_used := 'WAITLISTED';

         /* ELSIF l_event_status in ('P') THEN

            l_booking_status_row := Get_Booking_Status_for_web
			(p_web_booking_status_type => 'REQUESTED'
			,p_business_group_id       => ota_general.get_business_group_id);

                l_booking_status_used := 'REQUESTED';*/

         ELSIF l_event_status = 'N' THEN

            IF l_maximum_internal_attendees  is null then
               l_booking_status_row := Get_Booking_Status_for_web
			(p_web_booking_status_type => 'PLACED'
			,p_business_group_id       => ota_general.get_business_group_id);

                l_booking_status_used := 'PLACED';

            ELSE

              IF l_maximum_internal_allowed > 0 OR l_maximum_external_allowed > 0 THEN
                 l_booking_status_row := Get_Booking_Status_for_web
			(p_web_booking_status_type => 'PLACED'
			,p_business_group_id       => ota_general.get_business_group_id);

                l_booking_status_used := 'PLACED';

              ELSIF l_maximum_internal_allowed <= 0 OR l_maximum_external_allowed <= 0 THEN
                    l_booking_status_row := Get_Booking_Status_for_web
       			(p_web_booking_status_type => 'WAITLISTED'
      			 ,p_business_group_id       => ota_general.get_business_group_id);

                l_booking_status_used := 'WAITLISTED';

              END IF;
            END IF;
           IF l_booking_status_row.booking_Status_type_id is null then
              fnd_message.set_name ('OTA','OTA_13667_WEB_STATUS_NOT_SEEDE');
              RAISE g_mesg_on_stack_exception ;
           END IF ;
      END IF;

    EXCEPTION
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
     /*   ELSIF (hr_message.last_message_name = 'OTA_13658_WF_ERR_GETTING_TYPE')
          THEN
          --
          -- Seed the user friendly message
          --
          fnd_message.set_name ('OTA','OTA_WEB_WF_PROBLEM');
          -- Raise the error for the main procedure exception handler
	      -- to handle
          --
         p_message_name := fnd_message.get;
         p_message_name := SUBSTR(SQLERRM, 1,300);*/
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
                                ,p_delegate_contact_id => p_delegate_contact_id
       						    ,p_booking_id         => l_booking_id);

    l_auto_create_finance   := FND_PROFILE.value('OTA_AUTO_CREATE_FINANCE');
    l_automatic_transfer_gl := FND_PROFILE.value('OTA_SSHR_AUTO_GL_TRANSFER');
    l_user 		    := FND_PROFILE.value('USER_ID');

    IF (l_cancel_boolean) THEN
    --
    --  Delegate has a Cancelled status for this event, hence
    --  we must update the existing record by changing Cancelled
    --  to Requested status
    --

      l_object_version_number := OTA_LEARNER_ENROLL_SS.Get_Booking_OVN (p_booking_id => l_booking_id);

      /* Call Cancel procedure to cancel the Finance if person Re-enroll */
      cancel_finance(l_booking_id);


  -- ----------------------------------------------------------------
  --   Delegate has no record for this event, hence create a record
  --   with requested status
  -- ----------------------------------------------------------------
  --   Check if the Profile AutoCreate Finance is ON or OFF
  -- ----------------------------------------------------------------
     END IF;
      open c_get_price_basis;
      fetch c_get_price_basis into l_price_basis;
      close c_get_price_basis;


	IF  l_delegate_id IS NOT NULL
       AND l_auto_create_finance = 'Y'
       and l_price_basis <> 'N'
       and l_event_currency_code is not null THEN

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
				result_object_version_number := fapi_object_version_number;
				result_finance_header_id     := fapi_finance_header_id;

			ELSIF fapi_result = 'E' THEN
     			result_object_version_number := l_object_version_number;
				result_finance_header_id     := NULL;
				result_create_finance_line   := NULL;
			END IF;

	      ota_tdb_api_ins2.Create_Enrollment(p_booking_id    =>	l_booking_id
      						,p_booking_status_type_id   	=>	l_booking_status_row.booking_status_type_id
      						,p_delegate_person_id       	=>	l_delegate_id
			                        ,p_delegate_contact_id          =>	null
      						,p_contact_id               	=>	null
						,p_business_group_id        	=>	ota_general.get_business_group_id
      						,p_event_id                 	=>	p_event_id
      						--,p_date_booking_placed     	    =>	trunc(sysdate)
						,p_date_booking_placed     	    =>	sysdate
      						,p_corespondent          	    => 	l_corespondent
      						,p_internal_booking_flag    	=> 	l_internal_booking_flag
						,p_person_address_type          =>      l_person_address_type
      						,p_number_of_places         	=> 	1
      						,p_object_version_number    	=> 	result_object_version_number
      						,p_delegate_contact_phone	    => 	l_work_telephone
      						,p_delegate_contact_fax 	    => 	l_work_fax
     						,p_source_of_booking        	=> 	l_source_of_booking
      						,p_special_booking_instructions => 	p_extra_information
      						,p_successful_attendance_flag   => 	'N'
						,p_finance_header_id		    =>    result_finance_header_id
						,p_create_finance_line		    =>	result_create_finance_line
      						,p_finance_line_id          	=> 	l_finance_line_id
      						,p_enrollment_type          	=> 	l_enrollment_type
						,p_validate               	    => 	FALSE
						,p_currency_code			    =>  l_event_currency_code
      						,p_organization_id          	=> 	l_organization_id
      						,p_delegate_assignment_id   	=> 	l_assignment_id
 					        ,p_delegate_contact_email 		=> 	l_email_address
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
                                                ,p_tdb_information20            => p_tdb_information20
						,p_booking_justification_id  => p_booking_justification_id
						,p_booking_priority                => l_priority_level);


		IF l_automatic_transfer_gl = 'Y' AND l_finance_line_id IS NOT NULL AND l_offering_id is null THEN

			UPDATE ota_finance_lines SET transfer_status = 'AT'
			WHERE finance_line_id = l_finance_line_id;



		END IF;

	   ELSE

	      ota_tdb_api_ins2.Create_Enrollment(p_booking_id    =>	l_booking_id
      						,p_booking_status_type_id   	=>	l_booking_status_row.booking_status_type_id
      						,p_delegate_person_id       	=>	l_delegate_id
			                        ,p_delegate_contact_id          =>	p_delegate_contact_id
						,p_customer_id                  =>      l_customer_id
      						,p_contact_id               	=>	null
						,p_business_group_id        	=>	ota_general.get_business_group_id
      						,p_event_id                 	=>	p_event_id
      						--,p_date_booking_placed     	    =>	trunc(sysdate)
						,p_date_booking_placed     	    =>	sysdate
      						,p_corespondent        		    => 	l_corespondent
      						,p_internal_booking_flag    	=> 	l_internal_booking_flag
						,p_person_address_type          =>      l_person_address_type
      						,p_number_of_places         	=> 	1
      						,p_object_version_number    	=> 	l_object_version_number
      						,p_delegate_contact_phone	    => 	l_work_telephone
      						,p_delegate_contact_fax 	    => 	l_work_fax
     						,p_source_of_booking        	=> 	l_source_of_booking
      						,p_special_booking_instructions => 	p_extra_information
      						,p_successful_attendance_flag   => 	'N'
      						,p_finance_line_id          	=> 	l_finance_line_id
      						,p_enrollment_type          	=> 	l_enrollment_type
						,p_validate               	    => 	FALSE
                                ,p_organization_id          	=> 	l_organization_id
      						,p_delegate_assignment_id   	=> 	l_assignment_id
 						,p_delegate_contact_email 		=> 	l_email_address
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
                                                ,p_tdb_information20            => p_tdb_information20
						,p_booking_justification_id  => p_booking_justification_id
						,p_booking_priority                => l_priority_level);


	   END IF;
            p_booking_id :=  l_booking_id;

         IF l_booking_id is not null then

                        IF l_booking_status_used = 'PLACED' then
                                 p_message_name := 'OTA_443526_CONFIRMED_PLACED';
                        ELSIF l_booking_status_used = 'WAITLISTED' then
                                 p_message_name := 'OTA_443527_CONFIRMED_WAITLIST';
                        ELSIF l_booking_status_used = 'REQUESTED' then
                                p_message_name :=  'OTA_443528_CONFIRMED_REQUESTED';
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

    l_hours_until_class_starts 	NUMBER;
    l_minimum_advance_notice 	NUMBER;
    l_event_id                ota_events.event_id%TYPE;
    l_course_start_date       ota_events.course_start_date%TYPE;
    l_course_start_time       ota_events.course_start_time%TYPE;
    l_course_end_date         ota_events.course_start_date%TYPE;
    l_date_booking_placed     ota_delegate_bookings.date_booking_placed%TYPE;
    l_content_player_status   ota_delegate_bookings.content_player_status%TYPE;
    l_object_version_number   ota_delegate_bookings.object_version_number%TYPE;
    l_delegate_id             ota_delegate_bookings.delegate_person_id%TYPE;
    l_delegate_contact_id     ota_delegate_bookings.delegate_contact_id%TYPE;
    l_tmp_booking_id          ota_delegate_bookings.booking_id%TYPE;
    l_cancel_boolean            BOOLEAN;

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

CURSOR event_csr (p_event_id ota_events.event_id%TYPE) IS
SELECT e.course_start_date,
       e.course_start_time,
       e.course_end_date
FROM   ota_events_vl e,
       ota_offerings o,
       ota_activity_versions_tl a
WHERE  e.parent_offering_id = o.offering_id
AND    o.activity_version_id = a.activity_version_id
AND    e.event_id = p_event_id
AND    language=userenv('LANG');

CURSOR booking_csr (p_booking_id ota_delegate_bookings.booking_id%TYPE) IS
SELECT b.event_id,
       b.delegate_person_id,
       b.delegate_contact_id,
       b.date_booking_placed,
       b.content_player_status,
       b.object_version_number
FROM   ota_delegate_bookings b
WHERE  b.booking_id = p_booking_id;

BEGIN

   OPEN booking_csr (p_booking_id);
   FETCH booking_csr INTO l_event_id,
                          l_delegate_id,
                          l_delegate_contact_id,
                          l_date_booking_placed,
                          l_content_player_status,
                          l_object_version_number;
   CLOSE booking_csr;

   OPEN event_csr (l_event_id);
   FETCH event_csr INTO l_course_start_date,
                        l_course_start_time,
                        l_course_end_date;
   CLOSE event_csr;

    OPEN  finance (p_booking_id);
    FETCH finance INTO l_finance_line_id,
		       	   l_finance_header_id,
			       l_transfer_status,
			       lf_booking_id,
			       lf_object_version_number,
			       l_sequence_number,
                   l_cancelled_flag ;

   l_minimum_advance_notice := NVL(TO_NUMBER(fnd_profile.value('OTA_CANCEL_HOURS_BEFORE_EVENT')), 0);
   l_hours_until_class_starts := 0;
   IF ( l_course_start_date IS NOT NULL ) THEN
       l_hours_until_class_starts := 24*(to_date(to_char(l_course_start_date, 'DD-MM-YYYY')||''||l_course_start_time, 'DD/MM/YYYYHH24:MI') - SYSDATE);
   END IF;

   l_cancel_boolean := Chk_Event_Cancelled_for_Person(p_event_id  => l_event_id
       						    ,p_delegate_person_id => l_delegate_id
                                ,p_delegate_contact_id => l_delegate_contact_id
       						    ,p_booking_id         => l_tmp_booking_id);

    IF (finance%found and l_cancel_boolean) THEN
       IF (l_transfer_status = 'ST' OR
           l_cancelled_flag = 'Y' OR
           l_content_player_status IS NOT NULL OR
           l_hours_until_class_starts < l_minimum_advance_notice) THEN
           NULL;
       ELSE
	      OPEN  header (p_booking_id);
	      FETCH header INTO  lh_finance_header_id,
			                 lh_cancelled_flag,
			                 lh_transfer_status,
	                         lh_object_version_number;
          CLOSE header;
	      IF lh_transfer_status <> 'ST' or lh_cancelled_flag <>'Y'  THEN
               l_raised_date := sysdate;
               ota_tfh_api_business_rules.cancel_header(p_finance_header_id   =>  lh_finance_header_id
    				                                    ,p_cancel_header_id    =>  l_cancel_header_id
     					                                ,p_date_raised         =>  l_raised_date
     					                                ,p_validate            =>  false
     					                                ,p_commit              =>  false);
          END IF;
       END IF;
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
FROM per_all_people_f per,
per_all_assignments_f assg,
pay_cost_allocations_f pcaf,
pay_cost_allocation_keyflex pcak
WHERE per.person_id = p_person_id
AND per.person_id = assg.person_id
AND assg.assignment_id = pcaf.assignment_id
AND assg.Primary_flag = 'Y'
AND pcaf.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id
AND pcak.enabled_flag = 'Y'
AND sysdate between nvl(pcaf.effective_start_date,sysdate)
and nvl(pcaf.effective_end_date,sysdate+1)
AND trunc(sysdate) between nvl(assg.effective_start_date,trunc(sysdate))
and nvl(assg.effective_end_date,trunc(sysdate+1))
AND trunc(sysdate) between nvl(per.effective_start_date,trunc(sysdate))
and nvl(per.effective_end_date,trunc(sysdate+1));


CURSOR get_assignment(p_delegate_id   per_all_people_f.person_id%TYPE) IS
SELECT   assg.assignment_id,
         assg.business_group_id,
         assg.organization_id
FROM     per_all_people_f                per,
         per_all_assignments_f           assg
WHERE    per.person_id                      = p_delegate_id
AND      per.person_id                   = assg.person_id
AND      trunc(sysdate) between nvl(assg.effective_start_date,trunc(sysdate))
         and nvl(assg.effective_end_date,trunc(sysdate+1))
AND      assg.primary_flag = 'Y'
AND      trunc(sysdate) between nvl(per.effective_start_date,trunc(sysdate))
         and nvl(per.effective_end_date,trunc(sysdate+1));


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
     for a in get_assignment(p_person_id) loop
     p_business_group_id :=a.business_group_id ;
     p_assignment_id  :=a.assignment_id  ;
     p_organization_id :=a.organization_id ;
     end loop;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

END check_cost_center;

Procedure supervisor_exists  ( itemtype		IN WF_ITEMS.ITEM_TYPE%TYPE,
		      itemkey		IN WF_ITEMS.ITEM_KEY%TYPE,
		      actid		IN NUMBER,
	   	      funcmode		IN VARCHAR2,
		      resultout		OUT nocopy VARCHAR2 )  IS

l_supervisor_username   fnd_user.user_name%TYPE;

BEGIN

	IF (funcmode='RUN') THEN
		l_supervisor_username := wf_engine.getItemAttrText ( itemtype
			 	  ,itemkey
			  	  , 'SUPERVISOR_USERNAME');
	 if l_supervisor_username is not null then
                   resultout:='COMPLETE:Y';
                 RETURN;
                 else
                    resultout:='COMPLETE:N';
                 RETURN;
                 end if;
	END IF;

	IF (funcmode='CANCEL') THEN
		resultout:='COMPLETE:Y';
		RETURN;
	END IF;

END supervisor_exists;

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
    RAISE g_mesg_on_stack_exception ;
  ELSE
    CLOSE csr_person_to_enroll_details;
    RETURN l_csr_person_to_enroll_details;
  END IF;

EXCEPTION
  WHEN g_mesg_on_stack_exception THEN
    --
      -- Handle the exception in the calling code.
    RAISE;

  WHEN OTHERS THEN
    fnd_message.set_name('PER','HR_51396_WEB_PERSON_NOT_FND');
    RAISE;

END Get_Person_To_Enroll_Details;


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
RETURN csr_ext_lrnr_Details%ROWTYPE

IS
  --
  l_csr_ext_lrnr_Details	csr_ext_lrnr_Details%ROWTYPE;


BEGIN
  --
  OPEN csr_ext_lrnr_Details (p_delegate_contact_id);
  --
  FETCH  csr_ext_lrnr_Details INTO l_csr_ext_lrnr_Details;
  --
  IF csr_ext_lrnr_Details%NOTFOUND THEN
    CLOSE csr_ext_lrnr_Details;
    fnd_message.set_name('PER','HR_51396_WEB_PERSON_NOT_FND');
    RAISE g_mesg_on_stack_exception ;
  ELSE
    CLOSE csr_ext_lrnr_Details;
    RETURN l_csr_ext_lrnr_Details;
  END IF;

EXCEPTION
  WHEN g_mesg_on_stack_exception THEN
    --
      -- Handle the exception in the calling code.
    RAISE;

  WHEN OTHERS THEN
    fnd_message.set_name('PER','HR_51396_WEB_PERSON_NOT_FND');
    RAISE;

END Get_ext_lrnr_Details;

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
                              p_delegate_contact_id IN NUMBER,
				     p_event_id	IN VARCHAR2,
				     p_double_book  out nocopy VARCHAR2 )

IS

l_person_details
	csr_person_to_enroll_details%ROWTYPE;

l_ext_lrnr_details
	csr_ext_lrnr_Details%ROWTYPE;
l_cancel_boolean  boolean;
l_dummy number;
Begin
p_double_book := 'N';

IF p_person_id IS NOT NULL THEN
    l_person_details := Get_Person_To_Enroll_Details(p_person_id => p_person_id);
ELSIF p_delegate_contact_id IS NOT NULL THEN
    l_ext_lrnr_details := Get_ext_lrnr_Details(p_delegate_contact_id);
END IF;

l_cancel_boolean :=
        Chk_Event_Cancelled_for_Person
         (p_event_id => p_event_id
         ,p_delegate_person_id => p_person_id
         ,p_delegate_contact_id => p_delegate_contact_id
         ,p_booking_id => l_dummy);
   IF (l_cancel_boolean) THEN
  -- Delegate has Cancelled status, so dont check for unique_booking
  --  as a row exists for  delegate, for this event
     null;
   ELSE
     IF p_person_id IS NOT NULL THEN
        ota_tdb_bus.check_unique_booking
	    (p_customer_id		=> ''
    	,p_organization_id	=> l_person_details.organization_id
    	,p_event_id		=> p_event_id
    	,p_delegate_person_id 	=> p_person_id
    	,p_delegate_contact_id	=> ''
    	,p_booking_id		=> '');
    ELSIF p_delegate_contact_id IS NOT NULL THEN
         ota_tdb_bus.check_unique_booking
	    (p_customer_id		=> l_ext_lrnr_details.customer_id
    	,p_organization_id	=> ''
    	,p_event_id		=> p_event_id
    	,p_delegate_person_id 	=> ''
    	,p_delegate_contact_id	=> p_delegate_contact_id
    	,p_booking_id		=> '');
    END IF;
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
                    ,p_delegate_contact_id IN NUMBER
					,p_booking_id 		OUT nocopy NUMBER)
RETURN BOOLEAN

IS

  CURSOR csr_chk_event
	(p_event_id IN NUMBER
        ,p_person_id IN NUMBER
        ,p_delegate_contact_id IN NUMBER) IS
  SELECT ov.booking_id
  FROM   ota_booking_status_types os,
         ota_delegate_bookings ov
  WHERE  ov.event_id = p_event_id
  AND    (p_person_id IS NOT NULL AND ov.delegate_person_id = p_person_id
            OR p_delegate_contact_id IS NOT NULL and ov.delegate_contact_id = p_delegate_contact_id)
  AND    os.booking_status_type_id = ov.booking_status_type_id
  AND    os.type = 'C';

CURSOR csr_chk_event_placed
	(p_event_id IN NUMBER
        ,p_person_id IN NUMBER
        ,p_delegate_contact_id IN NUMBER) IS
  SELECT ov.booking_id
  FROM   ota_booking_status_types os,
         ota_delegate_bookings ov
  WHERE  ov.event_id = p_event_id
   AND    (p_person_id IS NOT NULL AND ov.delegate_person_id = p_person_id
            OR p_delegate_contact_id IS NOT NULL and ov.delegate_contact_id = p_delegate_contact_id)
  AND    os.booking_status_type_id = ov.booking_status_type_id
  AND    os.type <> 'C';

  l_temp 	csr_chk_event%rowtype;
  l_enroll_exist  boolean := False;

BEGIN

  OPEN  csr_chk_event(p_event_id, p_delegate_person_id,p_delegate_contact_id);
  FETCH csr_chk_event INTO l_temp;

  p_booking_id := l_temp.booking_id;

  IF csr_chk_event%FOUND THEN


     For r_enroll in csr_chk_event_placed(p_event_id, p_delegate_person_id,p_delegate_contact_id)
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
               -- Added for External Learner support
                    ,p_delegate_contact_id IN NUMBER
					,p_booking_Clash 	OUT nocopy varchar2)
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
           -- Modified for External Learner Support
           --  ,p_delegate_contact_id=> ''
             ,p_delegate_contact_id=> p_delegate_contact_id
             ,p_event_id           => p_event_id
              ,p_booking_status_type_id     => l_booking_status_type_id    ) THEN

 p_booking_clash := 'Y';
ELSE
  p_booking_clash := 'N';

END IF;

EXCEPTION
    When OTHERS Then
         p_booking_Clash := fnd_message.get();
         If p_booking_Clash is NULL then
            p_booking_Clash := substr(SQLERRM,11,(length(SQLERRM)-10));
         End If;


end  Chk_booking_clash;

--|--------------------------------------------------------------------------|
--|--< CHK_FOR_SECURE_EVT >-------------------------------------------|
--|--------------------------------------------------------------------------|

FUNCTION CHK_FOR_SECURE_EVT (
         p_delegate_id        IN PER_PEOPLE_F.PERSON_ID%TYPE
       ,p_delegate_contact_id IN NUMBER
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

  IF p_delegate_id IS NOT NULL THEN
     OPEN C_GET_ORG_ID;
     FETCH C_GET_ORG_ID into l_per_organization_id;
     IF C_GET_ORG_ID%NOTFOUND then
        CLOSE C_GET_ORG_ID;
        l_return_value := NULL;
        return l_return_value;
     ELSE
        CLOSE C_GET_ORG_ID;
     END IF;
  ELSE
    l_per_organization_id := ota_general.get_business_group_id;
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
  SELECT a.assignment_id
  FROM per_all_assignments_f a
  WHERE a.person_id            = p_delegate_id
   --Modified for bug#5032859
  AND( nvl(fnd_profile.value('OTA_ALLOW_FUTURE_ENDDATED_EMP_ENROLLMENTS'),'N') = 'Y'
      OR
      NVL(p_course_start_date,trunc(sysdate)) BETWEEN
        a.effective_start_date AND a.effective_end_date
     )
  AND NVL(p_organization_id, -1) = DECODE(p_organization_id, null, -1,
NVL(a.organization_id,-1))
  AND NVL(p_job_id, -1)          = DECODE(p_job_id, null, -1,
NVL(a.job_id, -1))
  AND NVL(p_position_id,-1)      = DECODE(p_position_id, null, -1,
NVL(a.position_id, -1))
  AND a.assignment_type        = 'E';
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

--|--------------------------------------------------------------------------|
--|--< CHK_FOR_RESTRICTED_EVT >-------------------------------------------|
--|--------------------------------------------------------------------------|

FUNCTION CHK_FOR_RESTRICTED_EVT (
        p_event_id           IN OTA_EVENTS.EVENT_ID%TYPE,
        p_delegate_contact_id IN NUMBER)
RETURN VARCHAR2
IS
CURSOR C_GET_EVT_DETAILS is
 SELECT EVT.public_event_flag,EVT.maximum_internal_attendees
 from ota_events EVT
 where EVT.event_id = p_event_id;

 CURSOR C_GET_EVT_ACCESS_DETAILS(l_customer_id NUMBER) is
 SELECT EVT.public_event_flag,EVT.maximum_internal_attendees
 from ota_events EVT, ota_event_associations EVA
 where EVT.event_id = p_event_id and
       EVT.event_id = EVA.event_id and
       EVA.customer_id = l_customer_id;

  l_public_event_flag  OTA_EVENTS.PUBLIC_EVENT_FLAG%TYPE;
  l_maximum_internal_attendees  OTA_EVENTS.MAXIMUM_INTERNAL_ATTENDEES%TYPE;
  l_return_value  varchar2(10);

  l_ext_lrnr_details csr_ext_lrnr_Details%ROWTYPE;
  l_customer_id NUMBER := null;
BEGIN

  IF p_delegate_contact_id IS NOT NULL THEN
      l_ext_lrnr_details := Get_ext_lrnr_Details(p_delegate_contact_id);
      l_customer_id := l_ext_lrnr_details.customer_id;
  END IF;


  OPEN C_GET_EVT_DETAILS;
  FETCH C_GET_EVT_DETAILS into l_public_event_flag,l_maximum_internal_attendees;
  IF C_GET_EVT_DETAILS%NOTFOUND then
     l_return_value := NULL;
  ELSE
     IF l_public_event_flag = 'Y' THEN
         CLOSE C_GET_EVT_DETAILS;
         l_return_value := -1;
         return l_return_value;
     ELSIF l_customer_id IS NULL THEN
     -- Person Case
       IF l_maximum_internal_attendees = 0 THEN
          l_return_value := NULL;
       END IF;
     ELSE
     -- Customer Case
        OPEN C_GET_EVT_ACCESS_DETAILS(l_customer_id);
        IF C_GET_EVT_ACCESS_DETAILS%NOTFOUND THEN
           l_return_value := NULL;
        ELSE
           l_return_value := -1;
        END IF;
     END IF;

  END IF;

   CLOSE C_GET_EVT_DETAILS;
   RETURN l_return_value;

END CHK_FOR_RESTRICTED_EVT;

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
RETURN NUMBER

IS

  CURSOR csr_get_ovn IS
  SELECT object_version_number
  FROM   ota_delegate_bookings
  WHERE  booking_id  = p_booking_id;
  --
  l_ovn		BINARY_INTEGER  DEFAULT '';

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
-- ----------------------------------------------------------------------------
-- |-----------------------------< cancel_enrollment>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the entry point to this package and will be called from the
--   View Enrollment Details Screen on pressing 'Submit'.
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
                         p_comments                     in varchar2  DEFAULT NULL        )
IS
-- ------------------------
--  event_csr variables
-- ------------------------
    l_event_title             ota_events.title%TYPE;
    l_event_status            ota_events.event_status%TYPE;
    l_course_start_date       ota_events.course_start_date%TYPE;
    l_course_start_time       ota_events.course_start_time%TYPE;
    l_course_end_date         ota_events.course_start_date%TYPE;
    l_owner_id                ota_events.owner_id%TYPE;

-- ------------------------
--  booking_csr variables
-- ------------------------
    l_date_booking_placed     ota_delegate_bookings.date_booking_placed%TYPE;
    l_content_player_status   ota_delegate_bookings.content_player_status%TYPE;
    l_object_version_number   ota_delegate_bookings.object_version_number%TYPE;

-- ------------------------
--  Finance_csr Variables
-- ------------------------
    l_finance_line_id	     ota_finance_lines.finance_line_id%TYPE;
    l_finance_header_id	     ota_finance_lines.finance_header_id%TYPE;
    l_transfer_status  	     ota_finance_lines.transfer_status%TYPE;
    lf_booking_id            ota_finance_lines.booking_id%TYPE;
    lf_object_version_number ota_finance_lines.object_version_number%TYPE;
    l_sequence_number        ota_finance_lines.sequence_number%TYPE;
    l_finance_count          number(10);
    l_cancelled_flag         ota_finance_lines.cancelled_flag%type;
    l_cancel_header_id       ota_finance_headers.finance_header_id%TYPE;

-- ------------------------
--  header_csr Variables
-- ------------------------
    lh_finance_header_id     ota_finance_headers.finance_header_id%TYPE;
    lh_cancelled_flag        ota_finance_headers.cancelled_flag%TYPE;
    lh_transfer_status       ota_finance_headers.transfer_status%TYPE;
    lh_object_version_number ota_finance_headers.object_version_number%TYPE;
-- ------------------------
--  other local Variables
-- ------------------------
    l_hours_until_class_starts 	NUMBER;
    l_minimum_advance_notice 	NUMBER;
    l_auto_waitlist_days 	NUMBER;
    l_sysdate 			DATE := SYSDATE;
    l_daemon_flag 		ota_delegate_bookings.daemon_flag%TYPE;
    l_daemon_type 		ota_delegate_bookings.daemon_type%TYPE;
    lb_object_version_number 	ota_delegate_bookings.object_version_number%TYPE;
    l_proc                  	VARCHAR2(72) := 'ota_learner_enroll_ss.cancel_enrollment';
    l_activity_version_name   ota_activity_versions.version_name%TYPE;

CURSOR event_csr (p_event_id ota_events.event_id%TYPE)
IS
SELECT a.version_name,
       e.title,
       e.event_status,
       e.course_start_date,
       e.course_start_time,
       e.course_end_date,
       e.owner_id
FROM   ota_events_vl e,
       ota_offerings o,
       ota_activity_versions_tl a
WHERE  e.parent_offering_id = o.offering_id
AND    o.activity_version_id = a.activity_version_id
AND    e.event_id = p_event_id
AND    language=userenv('LANG');

CURSOR booking_csr (p_booking_id ota_delegate_bookings.booking_id%TYPE)
IS
SELECT b.date_booking_placed, b.content_player_status, b.object_version_number
FROM   ota_delegate_bookings b
WHERE  b.booking_id = p_booking_id;

CURSOR finance_csr (p_booking_id ota_finance_lines.booking_id%TYPE)
IS
SELECT fln.finance_line_id finance_line_id,
	 fln.finance_header_id finance_header_id,
	 fln.transfer_status transfer_status,
	 fln.booking_id booking_id,
	 fln.object_version_number object_version_number,
	 fln.sequence_number sequence_number,
	 fln.Cancelled_flag cancelled_flag
FROM   ota_finance_lines fln
WHERE  fln.booking_id = p_booking_id;

CURSOR finance_count_csr (p_finance_header_id ota_finance_lines.finance_header_id%TYPE)
IS
SELECT count(finance_line_id)
FROM	 ota_finance_lines fln
WHERE	 fln.finance_header_id = p_finance_header_id;

CURSOR header_csr (p_booking_id ota_finance_lines.booking_id%TYPE)
IS
SELECT flh.finance_header_id finance_header_id,
	 flh.cancelled_flag cancelled_flag,
	 flh.transfer_status transfer_status,
	 flh.object_version_number object_version_number
FROM   ota_finance_headers flh,
       ota_finance_lines fln
WHERE  flh.finance_header_id =  fln.finance_header_id
   AND fln.booking_id = p_booking_id;

CURSOR  C_USER(p_owner_id  NUMBER) IS
SELECT  USER_NAME
  FROM  FND_USER
 WHERE  Employee_id = p_owner_id
 AND trunc(sysdate) between start_date and nvl(end_date,to_date('4712/12/31', 'YYYY/MM/DD'));      --Bug 5676892

l_username 	fnd_user.user_name%TYPE;

BEGIN
   hr_utility.set_location('Entering:'||l_proc, 10);

   savepoint cancel_enrollment;

   --Enable multi messaging
   hr_multi_message.enable_message_list;

   OPEN event_csr (p_event_id);
   FETCH event_csr INTO l_activity_version_name,
                        l_event_title,
                        l_event_status,
                        l_course_start_date,
                        l_course_start_time,
                        l_course_end_date,
            			l_owner_id;
   CLOSE event_csr;

   IF l_owner_id IS NULL THEN
      l_owner_id := fnd_profile.value('OTA_DEFAULT_EVENT_OWNER');
   END IF;

   OPEN c_user(l_owner_id);
   FETCH c_user INTO l_username;
   CLOSE c_user;

   OPEN booking_csr (p_booking_id);
   FETCH booking_csr INTO l_date_booking_placed,
                          l_content_player_status,
                          l_object_version_number;
   CLOSE booking_csr;

   OPEN  finance_csr (p_booking_id);
   FETCH finance_csr INTO l_finance_line_id,
                      l_finance_header_id,
                      l_transfer_status,
                      lf_booking_id,
                      lf_object_version_number,
                      l_sequence_number,
                      l_cancelled_flag ;

/*
   --Bug 3445831
   l_hours_until_class_starts := 0;
   If ( l_course_start_date is not null ) Then
      -- Modified date format for Bug#4450940
       --l_hours_until_class_starts := 24*(to_date(to_char(l_course_start_date, 'DD-MON-YYYY')||''||l_course_start_time, 'DD/MM/YYYYHH24:MI') - SYSDATE);
       l_hours_until_class_starts := 24*(to_date(to_char(l_course_start_date, 'DD-MM-YYYY')||''||l_course_start_time, 'DD/MM/YYYYHH24:MI') - SYSDATE);
   End If;

   IF finance_csr%found  THEN
      l_minimum_advance_notice := NVL(TO_NUMBER(fnd_profile.value('OTA_CANCEL_HOURS_BEFORE_EVENT')), 0);

      IF l_transfer_status = 'ST' OR
         l_cancelled_flag = 'Y' OR
         l_content_player_status IS NOT NULL OR
         l_hours_until_class_starts < l_minimum_advance_notice THEN
         NULL;
      ELSE
         --  Call Finance Lines API (Cancel Finance Line)
         OPEN  finance_count_csr (l_finance_header_id);
         FETCH finance_count_csr INTO l_finance_count;
         CLOSE finance_count_csr;

         IF l_finance_count = 1 THEN  --  If only one Finance Line
            OPEN  header_csr (p_booking_id);
            FETCH header_csr INTO lh_finance_header_id,
                              lh_cancelled_flag,
                              lh_transfer_status,
                              lh_object_version_number;
            CLOSE header_csr;

            IF lh_transfer_status <> 'ST' or lh_cancelled_flag <>'Y'  THEN  -- Call Finance Header API
--                                                                             to Cancel Finance Header
               ota_tfh_api_business_rules.cancel_header
                     (p_finance_header_id => lh_finance_header_id,
                      p_cancel_header_id  => l_cancel_header_id,
                      p_date_raised       => l_sysdate,
                      p_validate          => false,
                      p_commit            => false);
            END IF;
         ELSE
             ota_tfl_api_upd.upd(p_finance_line_id       =>  l_finance_line_id,
                                p_date_raised           =>  l_sysdate,
                                p_cancelled_flag        => 'Y',
                                p_object_version_number =>  lf_object_version_number,
                                p_sequence_number       =>  l_sequence_number,
                                p_validate              =>  false,
                                p_transaction_type      => 'CANCEL_HEADER_LINE');
         END IF;
      END IF; -- For Lines;
   END IF;
   CLOSE finance_csr;
*/
--
--  Initialize workflow setings
--
   l_auto_waitlist_days := TO_NUMBER(fnd_profile.value('OTA_AUTO_WAITLIST_DAYS'));
--
   IF (p_waitlist_size > 0) THEN
      IF (l_hours_until_class_starts >= l_auto_waitlist_days) THEN
         l_daemon_flag := 'Y';
         l_daemon_type := 'W';
   /* Bug#6063768 Since this notification is sent from ota_delegate_booking_api.update_delegate_booking_api
    commenting this notification
      ELSE
        IF l_username IS NOT NULL THEN
           ota_initialization_wf.manual_waitlist
                  (p_itemtype    => 'OTWF',
                   p_process     => 'OTA_MANUAL_WAITLIST',
                   p_event_title => l_event_title,
                   p_event_id    => p_event_id,
                   p_item_key    => p_booking_id||':'||to_char(l_sysdate,'DD-MON-YYYY:HH24:MI:SS'),
                   p_user_name   => l_username);
        END IF;
    */
      END IF;
   ELSE
      l_daemon_flag := NULL;
      l_daemon_type := NULL;
   END IF;

--
--  Call update enrollment API to cancel Enrollment
--
   ota_tdb_api_upd2.update_enrollment
            (p_booking_id                 => p_booking_id,
             p_booking_status_type_id     => p_booking_status_type_id,
             p_object_version_number      => l_object_version_number,
             p_event_id 		          => p_event_id,
             p_status_change_comments     => p_cancel_reason,
             p_tfl_object_version_number  => lf_object_version_number,
             p_finance_line_id            => l_finance_line_id,
             p_daemon_flag                => l_daemon_flag,
             p_daemon_type                => l_daemon_type,
             p_date_status_changed        => l_sysdate,
             p_date_booking_placed        => l_date_booking_placed,
  	         p_tdb_information_category   => p_tdb_information_category,
             p_tdb_information1     	  => p_tdb_information1,
             p_tdb_information2     	  => p_tdb_information2,
             p_tdb_information3     	  => p_tdb_information3,
             p_tdb_information4     	  => p_tdb_information4,
             p_tdb_information5     	  => p_tdb_information5,
             p_tdb_information6     	  => p_tdb_information6,
             p_tdb_information7     	  => p_tdb_information7,
             p_tdb_information8     	  => p_tdb_information8,
             p_tdb_information9     	  => p_tdb_information9,
             p_tdb_information10     	  => p_tdb_information10,
             p_tdb_information11     	  => p_tdb_information11,
             p_tdb_information12     	  => p_tdb_information12,
             p_tdb_information13     	  => p_tdb_information13,
             p_tdb_information14     	  => p_tdb_information14,
             p_tdb_information15     	  => p_tdb_information15,
             p_tdb_information16     	  => p_tdb_information16,
             p_tdb_information17     	  => p_tdb_information17,
             p_tdb_information18     	  => p_tdb_information18,
             p_tdb_information19     	  => p_tdb_information19,
             p_tdb_information20     	  => p_tdb_information20,
             p_failure_reason => p_failure_reason,
             p_attendance_result => p_attendance_result,
             p_successful_attendance_flag => p_successful_attendance_flag,
             p_comments => p_comments
	     );

  x_return_status := hr_multi_message.get_return_status_disable;

   cancel_finance(p_booking_id);

  hr_utility.set_location('Leaving:'||l_proc, 20);
EXCEPTION
  When hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to cancel_enrollment;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    x_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  When others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to cancel_enrollment;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --

    x_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
END cancel_enrollment;

Procedure CHK_UNIQUE_FUNC(p_function_name in varchar2,
                          p_user_id in number,
                          result out nocopy varchar2)
IS
/*
--Bug 4905774
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
*/
Begin

result :='S';
/*
--Bug 4905774
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
*/
 end CHK_UNIQUE_FUNC;

--|--------------------------------------------------------------------------|
--|--< CHK_VALID_ACTIVITY >-------------------------------------------|
--|--------------------------------------------------------------------------|

FUNCTION CHK_VALID_ACTIVITY(
        p_activity_id        IN OTA_ACTIVITY_VERSIONS.Activity_Version_Id%type
        )
RETURN VARCHAR2
IS
-- check for presence of activity
 CURSOR C_GET_ACT(l_activity_id OTA_ACTIVITY_VERSIONS.Activity_Version_Id%type)
 is
 SELECT activity_version_id from ota_activity_versions
 where Activity_version_id = l_activity_id;

-- checking for expired AND BG validation
 CURSOR C_GET_ACT_DET(l_activity_id OTA_ACTIVITY_VERSIONS.Activity_Version_Id%type)
 is
 SELECT activity_version_id,end_date from ota_activity_versions
 where Activity_version_id = l_activity_id
 and business_group_id = ota_general.get_business_group_id;


 CURSOR C_GET_OFR_ATTACHED(l_activity_id OTA_ACTIVITY_VERSIONS.Activity_Version_Id%type)
 is
 SELECT 1 from ota_offerings
 where Activity_version_id = l_activity_id
 and business_group_id = ota_general.get_business_group_id;


  l_return_value  varchar2(10):='V';
  l_date Date;
  l_activity number(10);
  l_offering number(2);

BEGIN

  OPEN C_GET_ACT(p_activity_id);
  FETCH C_GET_ACT into l_activity;
  IF C_GET_ACT%NOTFOUND then --implies invalid activityid
     CLOSE C_GET_ACT;
     l_return_value := 'I';
     return l_return_value;
  END IF;
  CLOSE C_GET_ACT;

  OPEN C_GET_ACT_DET(p_activity_id);
  FETCH C_GET_ACT_DET into l_activity,l_date;
  IF C_GET_ACT_DET%NOTFOUND then --implies different BG
     CLOSE C_GET_ACT_DET;
     l_return_value := 'DFBG';
     return l_return_value;
  ElsIf(l_date < trunc(sysdate)) then --implies Expired Activity
     CLOSE C_GET_ACT_DET;
     l_return_value := 'E';
     return l_return_value;
  ELSE
      OPEN C_GET_OFR_ATTACHED(p_activity_id);
      FETCH C_GET_OFR_ATTACHED into l_offering;
      IF C_GET_OFR_ATTACHED%NOTFOUND then --implies no offering attached with activityid
         CLOSE C_GET_OFR_ATTACHED;
         CLOSE C_GET_ACT_DET;
         l_return_value := 'NO';
         return l_return_value;

      END IF;
      CLOSE C_GET_OFR_ATTACHED;
  END IF;

  CLOSE C_GET_ACT_DET;
  Return l_return_value;
END CHK_VALID_ACTIVITY;


--|--------------------------------------------------------------------------|
--|--< CHK_VALID_OFFERING >-------------------------------------------|
--|--------------------------------------------------------------------------|

FUNCTION CHK_VALID_OFFERING(
        p_offering_id        IN OTA_OFFERINGS.offering_id%type
        )
RETURN VARCHAR2
IS
-- check for presence of offering
 CURSOR C_GET_OFR(l_offering_id OTA_OFFERINGS.offering_id%type)
 is
 SELECT offering_id from ota_offerings
 where offering_id = l_offering_id;

-- checking for expired AND BG validation
 CURSOR C_GET_OFR_DET(l_offering_id OTA_OFFERINGS.offering_id%type)
 is
 SELECT offering_id,end_date from ota_offerings
 where offering_id = l_offering_id
 and business_group_id = ota_general.get_business_group_id;


 CURSOR C_GET_EVT_ATTACHED(l_offering_id OTA_OFFERINGS.offering_id%type)
 is
 SELECT 1 from ota_events
 where parent_offering_id = l_offering_id
 and business_group_id = ota_general.get_business_group_id;


  l_return_value  varchar2(10):='V';
  l_date Date;
  l_offering number(10);
  l_event number(2);

BEGIN

  OPEN C_GET_OFR(p_offering_id);
  FETCH C_GET_OFR into l_offering;
  IF C_GET_OFR%NOTFOUND then -- implies invalid offering id
     CLOSE C_GET_OFR;
     l_return_value := 'I';
     return l_return_value;
  END IF;
  CLOSE C_GET_OFR;

  OPEN C_GET_OFR_DET(p_offering_id);
  FETCH C_GET_OFR_DET into l_offering,l_date;
  IF C_GET_OFR_DET%NOTFOUND then --implies different BG
     CLOSE C_GET_OFR_DET;
     l_return_value := 'DFBG';
     return l_return_value;
  ElsIf(l_date < trunc(sysdate)) then --implies Expired Offering
     CLOSE C_GET_OFR_DET;
     l_return_value := 'E';
     return l_return_value;
  ELSE
      OPEN C_GET_EVT_ATTACHED(p_offering_id);
      FETCH C_GET_EVT_ATTACHED into l_event;
      IF C_GET_EVT_ATTACHED%NOTFOUND then --implies no event attached with offeringid
         CLOSE C_GET_EVT_ATTACHED;
         CLOSE C_GET_OFR_DET;
         l_return_value := 'NE';
         return l_return_value;
      END IF;
      CLOSE C_GET_EVT_ATTACHED;
  END IF;

  CLOSE C_GET_OFR_DET;
  Return l_return_value;
END CHK_VALID_OFFERING;




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

 CURSOR C_GET_EVT_DET(l_event_id OTA_EVENTS.EVENT_ID%TYPE)
 is
SELECT event_id,
       event_status,
       ota_timezone_util.convert_date(trunc(nvl(course_start_date,sysdate)), nvl(course_start_time,'00:00'), timezone, fnd_timezones.get_client_timezone_code) course_start_date,
       ota_timezone_util.convert_date(trunc(nvl(course_end_date,sysdate)), nvl(course_end_time,'23:59'), timezone, fnd_timezones.get_client_timezone_code) course_end_date,
       ota_timezone_util.convert_date(trunc(nvl(enrolment_start_date,sysdate)), '00:00', timezone, fnd_timezones.get_client_timezone_code) enrolment_start_date,
       ota_timezone_util.convert_date(trunc(nvl(enrolment_end_date,sysdate)), '23:59', timezone, fnd_timezones.get_client_timezone_code) enrolment_end_date,
       course_end_time,
       ota_timezone_util.convert_date(sysdate, to_char(sysdate,'HH24:MI'), ota_timezone_util.get_server_timezone_code, timezone) sys_date
 from ota_events
 where event_id = l_event_id
 and event_type in ('SCHEDULED','SELFPACED')
 and business_group_id=ota_general.get_business_group_id;

  l_return_value  varchar2(10):='V';
  l_stDate Date;
  l_endDate Date;
  l_endTime varchar2(5);
  l_evtStatus varchar2(10);
  l_enrlStDate Date;
  l_enrlEndDate Date;
  l_event Number(10);
  l_sysdate date;

BEGIN

  OPEN C_GET_EVT(p_event_id);
  FETCH C_GET_EVT into l_event;
  IF C_GET_EVT%NOTFOUND then --implies invalid eventid
     CLOSE C_GET_EVT;
     l_return_value := 'I';
     return l_return_value;
  END IF;

  CLOSE C_GET_EVT;

  OPEN C_GET_EVT_DET(p_event_id);
  FETCH C_GET_EVT_DET into l_event,l_evtStatus,l_stDate,l_endDate,l_enrlStDate,l_enrlEndDate,l_endTime, l_sysdate;
  IF C_GET_EVT_DET%NOTFOUND then
     CLOSE C_GET_EVT_DET;
     l_return_value:= 'DFBG';  --implies different BG for event
     Return l_return_value;
  ElSIF (l_evtStatus <> 'N' and l_evtStatus <> 'P' and l_evtStatus <> 'F') then
     CLOSE C_GET_EVT_DET;
     l_return_value:= 'C';  --implies canceled event
     Return l_return_value;
  ELSIF (l_endDate is not null) then
     IF (l_endTime is null and trunc(l_sysdate) > l_endDate) then
        CLOSE C_GET_EVT_DET;
	l_return_value:= 'E';--Expired
        Return l_return_value;
     ELSIF (l_endTime is not null and l_sysdate > to_date(to_char(l_endDate,'YYYY/MM/DD') ||' '|| l_endTime, 'YYYY/MM/DD HH24:MI') ) then
        CLOSE C_GET_EVT_DET;
	l_return_value:= 'E';--Expired
        Return l_return_value;
     END IF;
  ELSIF (trunc(l_sysdate) > l_enrlEndDate) then
     CLOSE C_GET_EVT_DET;
     l_return_value:= 'EC'; --Enrollment closed
     Return l_return_value;
  ELSIF (trunc(l_sysdate) < l_enrlStDate) then
     CLOSE C_GET_EVT_DET;
     l_return_value:= 'ENS'; --enrollment not started
     Return l_return_value;
  END IF;

  CLOSE C_GET_EVT_DET;
  Return l_return_value;

END CHK_VALID_EVENT;

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
    	   x_return_status      OUT NOCOPY VARCHAR2)
IS

l_proc                  VARCHAR2(72) := g_package || 'get_wf_attr_for_cancel_ntf';

l_current_userid        NUMBER := fnd_profile.value('USER_ID');
l_display_person_id     fnd_user.employee_id%TYPE;

CURSOR person_username_csr (p_person_id IN NUMBER) IS
SELECT user_name
FROM   fnd_user
WHERE  employee_id = p_person_id;
--
CURSOR display_person_id_csr (l_current_user_id IN NUMBER) IS
SELECT employee_id
FROM   fnd_user
WHERE  user_id = l_current_userid;
--
--Bug 3841658
CURSOR display_name_csr (l_display_person_id IN NUMBER) IS
SELECT full_name
FROM   per_all_people_f p
WHERE  person_id = l_display_person_id
       and trunc(SYSDATE) between effective_start_date and effective_end_date;
--

CURSOR csr_supervisor_id IS
SELECT a.supervisor_id, per.full_name
FROM per_all_assignments_f a,
     per_all_people_f per
WHERE a.person_id = p_person_id
  AND per.person_id = a.supervisor_id
  AND a.primary_flag = 'Y'
  AND trunc(sysdate)
  BETWEEN a.effective_start_date AND a.effective_end_date
  AND trunc(sysdate)
  BETWEEN per.effective_start_date AND per.effective_end_date;

CURSOR csr_supervisor_user IS
SELECT user_name
FROM fnd_user
WHERE employee_id = p_supervisor_id;

BEGIN

   hr_utility.set_location('Entering:'||l_proc, 10);
   --Enable multi messaging
   hr_multi_message.enable_message_list;

   p_current_username := fnd_profile.value('USERNAME');

   -- Get the current user name
   OPEN  person_username_csr (p_person_id);
   FETCH person_username_csr INTO p_current_person_name;
   CLOSE person_username_csr;

   -- Get the current display person id
   OPEN  display_person_id_csr (l_current_userid);
   FETCH display_person_id_csr INTO l_display_person_id;
   CLOSE display_person_id_csr;

   -- Get the person display name
   OPEN  display_name_csr (p_person_id);
   FETCH display_name_csr INTO p_person_displayname;
   CLOSE display_name_csr;

   -- Get value for creator display name attribute if current user is
   -- different than person whose class will be canceled
   IF l_display_person_id <> p_person_id THEN
      OPEN  display_name_csr (l_display_person_id);
      FETCH display_name_csr INTO p_creator_displayname;
      CLOSE display_name_csr;
   ELSE
      p_creator_displayname := p_person_displayname;
   END IF;

   FOR a IN csr_supervisor_id LOOP
      p_supervisor_id := a.supervisor_id;
      p_supervisor_full_name := a.full_name;
   END LOOP;

   FOR b IN csr_supervisor_user LOOP
      p_supervisor_username := b.user_name;
   END LOOP;

   x_return_status := hr_multi_message.get_return_status_disable;
   hr_utility.set_location('Leaving:'||l_proc, 20);
EXCEPTION
  When hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --

    --
    -- Reset IN OUT parameters and set OUT parameters
    --

    x_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  When others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --

    x_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
END get_wf_attr_for_cancel_ntf;
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
                                     p_booking_status_type_id IN NUMBER) RETURN VARCHAR2
IS

--
  --
  l_comments    ota_booking_status_histories.comments%TYPE := null;
  l_proc        varchar2(72) :=  'ota_learner_enroll_ss.get_booking_status_comments';
  --
begin
  --
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
l_comments:=ota_utility.getEnrollmentChangeReason(p_booking_id);

RETURN l_comments;
    --
  --
EXCEPTION
     WHEN others then
   RETURN l_comments;
END get_booking_status_comments;

--
-- ---------------------------------------------------------------------------------|
-- |-------------------------< getCancellationStatusId >----------------------------|
-- ---------------------------------------------------------------------------------|
--
-- Description: Retrieves the default cancellation enrollment status id
--
Function getCancellationStatusId
RETURN ota_booking_status_types.booking_status_type_id%type
IS
  l_booking_status_row		OTA_BOOKING_STATUS_TYPES%ROWTYPE;
  l_booking_status_type_id    ota_booking_status_types.booking_status_type_id%type;
  l_proc VARCHAR2(72) := g_package || 'getCancellationStatusId';
Begin

  l_booking_status_row := Get_Booking_Status_for_web
			(p_web_booking_status_type => 'CANCELLED'
			,p_business_group_id       => ota_general.get_business_group_id);

  l_booking_status_type_id := l_booking_status_row.booking_status_type_id;
  RETURN l_booking_status_type_id;
End getCancellationStatusId;

end ota_learner_enroll_ss;

/
