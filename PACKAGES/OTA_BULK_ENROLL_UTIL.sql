--------------------------------------------------------
--  DDL for Package OTA_BULK_ENROLL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_BULK_ENROLL_UTIL" AUTHID CURRENT_USER as
/* $Header: otblkenr.pkh 120.3.12010000.2 2009/05/26 12:41:51 shwnayak ship $ */

CURSOR csr_get_person_name(p_person_id NUMBER) IS
SELECT full_name
FROM per_all_people_f
WHERE trunc(sysdate) between effective_start_date and effective_end_date
  AND person_id = p_person_id;

CURSOR csr_get_request_info(p_enr_request_id NUMBER) IS
 SELECT ber.object_type
      , ber.object_id
      , ber.conc_program_request_id
      , ber.requestor_id
      , ber.business_group_id
      ,ber.parent_object_id
 FROM ota_bulk_enr_requests ber
 WHERE ber.bulk_enr_request_id = p_enr_request_id;

 CURSOR csr_get_all_requests(p_enr_request_id NUMBER,p_enr_request_id_end NUMBER) IS
 SELECT ber.object_type
      , ber.object_id
      , ber.conc_program_request_id
      , ber.requestor_id
      , ber.business_group_id
      ,ber.bulk_enr_request_id
      ,ber.parent_object_id
      FROM ota_bulk_enr_requests ber
 WHERE ber.bulk_enr_request_id between p_enr_request_id and p_enr_request_id_end;
 CURSOR csr_get_request_members(p_enr_request_id NUMBER) IS
 SELECT person_id, assignment_id, enrollment_status, error_message
 FROM ota_bulk_enr_req_members
 WHERE bulk_enr_request_id = p_enr_request_id;

Function get_enrollment_status( p_object_type IN VARCHAR2
                                 ,p_object_id IN NUMBER
								 ,p_learner_id IN NUMBER
                                 ,p_return_mode IN NUMBER
								 ) RETURN VARCHAR2;

PROCEDURE assign_enrollment_status(p_class_id IN NUMBER
                                    , p_booking_status_id OUT NOCOPY NUMBER
									, p_status_message OUT NOCOPY VARCHAR2);

FUNCTION get_object_name(p_object_type IN VARCHAR2, p_object_id IN NUMBER)
RETURN VARCHAR2;

PROCEDURE get_enr_request_info(
    p_bulk_enr_request_id IN NUMBER
   ,p_selected_learners OUT NOCOPY NUMBER
   ,p_unfulfil_course_prereqs OUT NOCOPY NUMBER
   ,p_unfulfil_comp_prereqs OUT NOCOPY NUMBER);

PROCEDURE get_enr_req_completion_status(
    p_bulk_enr_request_id IN NUMBER
   ,p_selected_learners OUT NOCOPY NUMBER
   ,p_success_enrollments OUT NOCOPY NUMBER
   ,p_errored_enrollments OUT NOCOPY NUMBER
   ,p_unfulfil_course_prereqs OUT NOCOPY NUMBER
   ,p_unfulfil_comp_prereqs OUT NOCOPY NUMBER);

FUNCTION get_enr_status_from_request(
   p_object_type IN VARCHAR2
   ,p_enrollment_status IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE delete_bulk_enr_request
		(itemtype   IN WF_ITEMS.ITEM_TYPE%TYPE
		,itemkey    IN WF_ITEMS.ITEM_KEY%TYPE
  		,actid	    IN NUMBER
        ,funcmode   IN VARCHAR2
        ,resultout  OUT nocopy VARCHAR2 );

PROCEDURE Create_Enrollment_And_Finance( p_event_id			IN VARCHAR2
					,p_extra_information		IN VARCHAR2 DEFAULT NULL
			                ,p_cost_centers		        IN VARCHAR2 DEFAULT NULL
	        			,p_assignment_id		IN PER_ALL_ASSIGNMENTS_F.assignment_id%TYPE
	        			,p_business_group_id_from	IN PER_ALL_ASSIGNMENTS_F.business_group_id%TYPE
					,p_organization_id          	IN PER_ALL_ASSIGNMENTS_F.organization_id%TYPE
					,p_person_id                 	IN PER_ALL_PEOPLE_F.person_id%type
			                ,p_delegate_contact_id       	IN NUMBER
	                		,p_booking_id                	OUT NOCOPY OTA_DELEGATE_BOOKINGS.Booking_id%type
			                ,p_message_name 		OUT NOCOPY VARCHAR2
	                                ,p_tdb_information_category     IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information1             IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information2             IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information3             IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information4             IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information5             IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information6             IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information7             IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information8             IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information9             IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information10            IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information11            IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information12            IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information13            IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information14            IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information15            IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information16            IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information17            IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information18            IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information19            IN VARCHAR2     DEFAULT NULL
	                                ,p_tdb_information20            IN VARCHAR2     DEFAULT NULL
					                ,p_booking_justification_id     IN VARCHAR2     DEFAULT NULL
	                		        ,p_override_prerequisites 	IN VARCHAR2     DEFAULT 'N'
                                    ,p_override_learner_access IN VARCHAR2 DEFAULT 'N'
                                    ,p_is_mandatory_enrollment IN VARCHAR2 default 'N');

Procedure process_bulk_enrollments
(ERRBUF OUT NOCOPY  VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2
 ,p_enr_request_id IN NUMBER
 ,p_enr_request_id_end IN NUMBER DEFAULT NULL);


PROCEDURE submit_bulk_enrollments(
         p_enr_request_id IN NUMBER
        ,p_enr_request_id_end IN NUMBER DEFAULT NULL
        ,p_conc_request_id OUT NOCOPY NUMBER
        ,p_object_type OUT NOCOPY VARCHAR2
        ,p_object_name OUT NOCOPY VARCHAR2);

end ota_bulk_enroll_util;


/
