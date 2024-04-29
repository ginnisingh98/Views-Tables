--------------------------------------------------------
--  DDL for Package Body OTA_LRNR_ENROLL_UNENROLL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LRNR_ENROLL_UNENROLL_WF" AS
/* $Header: otaenrwf.pkb 120.6 2007/01/04 17:36:15 sschauha noship $ */

g_package  VARCHAR2(33)	:= 'OTA_LRNR_ENROLL_UNENROLL_WF';

Procedure Cert_Enrollment(p_process 	in wf_process_activities.process_name%type,
            p_itemtype 		in wf_items.item_type%type,
            p_person_id 	in number ,
            p_certificationid       in ota_certifications_b.certification_id%type)

is
l_proc 	varchar2(72) := g_package||'Cert_Enrollment';
l_process             	wf_activities.name%type := upper(p_process);
l_item_type    wf_items.item_type%type := upper(p_itemtype);
l_item_key     wf_items.item_key%type;


l_cert_name   		ota_certifications_tl.name%type;
  l_cert_comp_date 		ota_certifications_b.initial_completion_date%type;
  l_cert_dur ota_certifications_b.initial_completion_duration%type;



l_process_display_name varchar2(240);

Cursor get_display_name is
SELECT wrpv.display_name displayName
FROM   wf_runnable_processes_v wrpv
WHERE wrpv.item_type = p_itemtype
AND wrpv.process_name = p_process;


Cursor get_cert_details is
select ctl.name, ctb.initial_completion_date,ctb.initial_completion_duration
from ota_Certifications_tl ctl , ota_Certifications_b ctb
where ctl.certification_id = ctb.certification_id
and ctl.Language= USERENV('LANG')
and ctl.certification_id= p_certificationid;

begin

hr_utility.set_location('Entering:'||l_proc, 10);

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;

WF_ENGINE.CREATEPROCESS(l_item_type, l_item_key, l_process);

OPEN get_display_name;
FETCH get_display_name INTO l_process_display_name;
CLOSE get_display_name;

OPEN  get_cert_details;
           FETCH get_cert_details INTO
                                l_cert_name,
				l_cert_comp_date,l_cert_dur;

           CLOSE get_cert_details;

--set wf attributes
OTA_INITIALIZATION_WF.set_wf_item_attr(p_person_id => p_person_id,
                                            p_item_type => l_item_type,
                                            p_item_key => l_item_key);


-- Set wf attributes



WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'PROCESS_DISPLAY_NAME', l_process_display_name);
WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'PROCESS_NAME',l_process );
--hard coded date format required by pqh
WF_ENGINE.setitemattrtext(l_item_type, l_item_key,'P_EFFECTIVE_DATE',to_char(trunc(sysdate),'RRRR-MM-DD'));

WF_ENGINE.setitemattrDate(l_item_type, l_item_key,'CURRENT_EFFECTIVE_DATE',trunc(sysdate));



WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_AME_TRAN_TYPE_ATTR','OTA');
WF_ENGINE.setitemattrNumber(l_item_type, l_item_key, 'HR_AME_APP_ID_ATTR', 810);

-- always set to NO for wf launched from pl/sql api
WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_RUNTIME_APPROVAL_REQ_FLAG', 'NO');


      WF_ENGINE.setitemattrnumber(l_item_type,
  			          l_item_key,
			          'BOOKING_ID',
				  p_certificationid);



 WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_ACTIVITY_VERSION_NAME',
                             l_cert_name);


if l_cert_comp_date is null then
l_cert_comp_date := trunc(sysdate)+l_cert_dur;
end if;

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_COURSE_START_DATE',
                            l_cert_comp_date);

                            WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_DELIVERY_MODE_NAME',
                            '');







WF_ENGINE.STARTPROCESS(l_item_type,l_item_key);

hr_utility.set_location('leaving:'||l_proc, 20);
EXCEPTION
WHEN OTHERS THEN

 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
-- Raise;



end Cert_Enrollment;


Procedure Learner_Enrollment(p_process 	in wf_process_activities.process_name%type,
            p_itemtype 		in wf_items.item_type%type,
            p_person_id 	in number ,
            p_eventid       in ota_Events.event_id%type,
            p_booking_id    in number)
is
l_proc 	varchar2(72) := g_package||'Learner_Enrollment';
l_process             	wf_activities.name%type := upper(p_process);
l_item_type    wf_items.item_type%type := upper(p_itemtype);
l_item_key     wf_items.item_key%type;

/*l_supervisor_id         per_all_people_f.person_id%Type;
l_supervisor_username   fnd_user.user_name%TYPE;
l_supervisor_full_name  per_all_people_f.full_name%TYPE;

l_current_username fnd_user.user_name%TYPE;
l_creator_username fnd_user.user_name%TYPE;
l_current_displayname per_all_people_f.full_name%TYPE;
l_creator_displayname per_all_people_f.full_name%TYPE;
*/
l_event_title   		ota_events.title%type;
  l_course_start_date 		ota_events.course_start_date%type;
  l_course_start_time 		ota_events.course_start_time%type;
  l_course_end_date 		ota_events.course_end_date%type;
  l_delivery_mode 		    ota_category_usages_tl.category%type;
  l_event_location          hr_locations_all.location_code%TYPE;
  l_version_name 		ota_activity_versions.version_name%type;

l_enrollment_status_name ota_booking_status_types_tl.name%TYPE;

l_return_status varchar2(1000);


l_process_display_name varchar2(240);
l_timezone  fnd_timezones_tl.name%TYPE;
 l_course_end_time 		ota_events.course_start_time%type;

Cursor get_display_name is
SELECT wrpv.display_name displayName
FROM   wf_runnable_processes_v wrpv
WHERE wrpv.item_type = p_itemtype
AND wrpv.process_name = p_process;


Cursor csr_name is
select evt.title,oev.course_start_date,
       oev.course_end_date, oev.course_start_time,
       ctl.category,
       ota_general.get_location_code(oev.location_id) Location_Name,
       oav.version_name,ota_timezone_util.get_timezone_name(oev.timezone),oev.course_end_time
from ota_Events oev , ota_events_tl evt,ota_activity_versions_tl oav,
OTA_CATEGORY_USAGES_TL ctl,ota_offerings off
where oev.event_id = evt.event_id
and oev.parent_offering_id=off.offering_id
	and off.activity_version_id= oav.activity_version_id
	and ctl.Category_usage_id = off.delivery_mode_id
AND    ctl.language = userenv('LANG')
	and oev.event_id= p_eventid;

begin

hr_utility.set_location('Entering:'||l_proc, 10);

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;

WF_ENGINE.CREATEPROCESS(l_item_type, l_item_key, l_process);

OPEN get_display_name;
FETCH get_display_name INTO l_process_display_name;
CLOSE get_display_name;

OPEN  csr_name;
           FETCH csr_name INTO
                                l_event_title,
				l_course_start_date,
				l_course_end_date,
                l_course_start_time,
                l_delivery_mode,
                l_event_location,l_version_name,l_timezone,l_course_end_time;

           CLOSE csr_name;

--set wf attributes
OTA_INITIALIZATION_WF.set_wf_item_attr(p_person_id => p_person_id,
                                            p_item_type => l_item_type,
                                            p_item_key => l_item_key);
/*ota_learner_enroll_ss.get_wf_attr_for_cancel_ntf
          (p_event_id     => p_eventid,
           p_person_id    => p_delegate_person_id,
    	   p_supervisor_username => l_supervisor_username,
    	   p_supervisor_full_name => l_supervisor_full_name,
    	   p_supervisor_id  => l_supervisor_id,
    	   p_current_person_name => l_current_username, --delegate person username
           p_current_username => l_creator_username,-- creator username
    	   p_person_displayname => l_current_displayname,
    	   p_creator_displayname => l_creator_displayname,
    	   x_return_status  => l_return_status);
*/

-- Set wf attributes



WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'PROCESS_DISPLAY_NAME', l_process_display_name);
WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'PROCESS_NAME',l_process );
--hard coded date format required by pqh
WF_ENGINE.setitemattrtext(l_item_type, l_item_key,'P_EFFECTIVE_DATE',to_char(trunc(sysdate),'RRRR-MM-DD'));

WF_ENGINE.setitemattrDate(l_item_type, l_item_key,'CURRENT_EFFECTIVE_DATE',trunc(sysdate));



WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_AME_TRAN_TYPE_ATTR','OTA');
WF_ENGINE.setitemattrNumber(l_item_type, l_item_key, 'HR_AME_APP_ID_ATTR', 810);

-- always set to NO for wf launched from pl/sql api
WF_ENGINE.setitemattrtext(l_item_type, l_item_key, 'HR_RUNTIME_APPROVAL_REQ_FLAG', 'NO');

hr_approval_wf.create_item_attrib_if_notexist
		      (p_item_type  => l_item_type
		      ,p_item_key   => l_item_key
		      ,p_name       => 'OTA_EVENT_ID');

      WF_ENGINE.setitemattrnumber(l_item_type,
  			          l_item_key,
			          'OTA_EVENT_ID',
				  p_eventid);



 WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_ACTIVITY_VERSION_NAME',
                             l_version_name);



           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_EVENT_TITLE',
                             p_eventid);       --Enh 5606090: Language support for Event Details.

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_COURSE_START_DATE',
                            l_course_start_date);


           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_COURSE_END_DATE',
                            l_course_end_date);

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_CLASS_START_TIME',
                            nvl(l_course_start_time,'00:00'));

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_DELIVERY_MODE_NAME',
                            l_delivery_mode);

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_LOCATION_ADDRESS',
                            l_event_location);

    -- get enrollment status

l_enrollment_status_name := ota_utility.get_enrollment_status(p_delegate_person_id => p_person_id,
                               p_delegate_contact_id => null,
                               p_event_id => p_eventid,
                               p_code =>0);

  WF_ENGINE.setitemattrText(l_item_type, l_item_key, 'ENROLL_IN_A_CLASS_STATUS', l_enrollment_status_name);

  wf_engine.setItemAttrNumber(itemtype => l_item_type
						  	   ,itemkey  => l_item_key
						  	   ,aname    => 'BOOKING_ID'
						  	   ,avalue   => p_booking_id);
wf_engine.setItemAttrText(l_item_type,l_item_key,'STATE_LIST',l_timezone );
/*  hr_approval_wf.create_item_attrib_if_notexist
		      (p_item_type  => l_item_type
		      ,p_item_key   => l_item_key
		      ,p_name       => 'OTA_CLASS_END_TIME');*/
     wf_engine.setItemAttrText(l_item_type,l_item_key,'PQH_EVENT_NAME',nvl(l_course_end_time,'23:59'));

--p_itemkey := l_item_key;

WF_ENGINE.STARTPROCESS(l_item_type,l_item_key);

hr_utility.set_location('leaving:'||l_proc, 20);
EXCEPTION
WHEN OTHERS THEN

 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
-- Raise;



end Learner_Enrollment;



Procedure Learner_UnEnrollment(p_process 	in wf_process_activities.process_name%type,
            p_itemtype 		in wf_items.item_type%type,
            p_person_id 	in number ,
            p_eventid       in ota_Events.event_id%type)

is
l_proc 	varchar2(72) := g_package||'Learner_UnEnrollment';
l_process             	wf_activities.name%type := upper(p_process);
l_item_type    wf_items.item_type%type := upper(p_itemtype);
l_item_key     wf_items.item_key%type;


l_event_title   		ota_events.title%type;
  l_course_start_date 		ota_events.course_start_date%type;

  l_version_name 		ota_activity_versions.version_name%type;

--l_enrollment_status_name ota_booking_status_types_tl.name%TYPE;




Cursor csr_name is
select evt.title,oev.course_start_date,
       oav.version_name
from ota_Events oev , ota_events_tl evt,ota_activity_versions_tl oav
where oev.event_id = evt.event_id
	and oev.activity_version_id= oav.activity_version_id
AND    evt.language = userenv('LANG')
	and oev.event_id= p_eventid;

begin

hr_utility.set_location('Entering:'||l_proc, 10);

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;

WF_ENGINE.CREATEPROCESS(l_item_type, l_item_key, l_process);

/*OPEN get_display_name;
FETCH get_display_name INTO l_process_display_name;
CLOSE get_display_name;
*/
OPEN  csr_name;
           FETCH csr_name INTO
                                l_event_title,
				l_course_start_date,
                l_version_name;

           CLOSE csr_name;

--set wf attributes
OTA_INITIALIZATION_WF.set_wf_item_attr(p_person_id => p_person_id,
                                            p_item_type => l_item_type,
                                            p_item_key => l_item_key);


-- Set wf attributes



 WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_ACTIVITY_VERSION_NAME',
                             l_version_name);



           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_EVENT_TITLE',
                             p_eventid);     --Enh 5606090: Language support for Event Details.

           WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'OTA_COURSE_START_DATE',
                            l_course_start_date);

              WF_ENGINE.setitemattrtext(l_item_type,
                            l_item_key,
                            'HR_OAF_NAVIGATION_ATTR',
                            'N');


WF_ENGINE.STARTPROCESS(l_item_type,l_item_key);

hr_utility.set_location('leaving:'||l_proc, 20);
EXCEPTION
WHEN OTHERS THEN

 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
-- Raise;



end Learner_UnEnrollment;





end OTA_LRNR_ENROLL_UNENROLL_WF;



/
