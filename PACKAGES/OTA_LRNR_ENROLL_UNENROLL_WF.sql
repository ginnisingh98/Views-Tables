--------------------------------------------------------
--  DDL for Package OTA_LRNR_ENROLL_UNENROLL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LRNR_ENROLL_UNENROLL_WF" AUTHID CURRENT_USER AS
 /* $Header: otaenrwf.pkh 120.1.12000000.1 2007/01/18 03:38:40 appldev noship $*/

 --called from ota_Cert_enrollments_api and ota_cpe_util

 Procedure Cert_Enrollment(p_process 	in wf_process_activities.process_name%type,
            p_itemtype 		in wf_items.item_type%type,
            p_person_id 	in number ,
            p_certificationid       in ota_certifications_b.certification_id%type);


Procedure Learner_Enrollment(p_process 	in wf_process_activities.process_name%type,
            p_itemtype 		in wf_items.item_type%type,
            p_person_id 	in number ,
            p_eventid       in ota_Events.event_id%type,
            p_booking_id    in number);

Procedure Learner_UnEnrollment(p_process 	in wf_process_activities.process_name%type,
            p_itemtype 		in wf_items.item_type%type,
            p_person_id 	in number ,
            p_eventid       in ota_Events.event_id%type);



end OTA_LRNR_ENROLL_UNENROLL_WF;


 

/
