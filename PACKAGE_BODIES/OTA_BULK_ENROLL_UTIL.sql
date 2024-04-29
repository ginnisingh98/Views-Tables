--------------------------------------------------------
--  DDL for Package Body OTA_BULK_ENROLL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_BULK_ENROLL_UTIL" as
/* $Header: otblkenr.pkb 120.12.12010000.10 2009/09/10 11:20:55 pekasi ship $ */

g_package  varchar2(33) := 'ota_bulk_enroll_util.';  -- Global package name

Function get_enrollment_status( p_object_type IN VARCHAR2
                                 ,p_object_id IN NUMBER
								 ,p_learner_id IN NUMBER
                                 ,p_return_mode IN NUMBER
								 ) RETURN VARCHAR2
IS
CURSOR get_lp_enr_status IS
   SELECT lpe.path_status_code status_code,
          lkp.meaning Status_meaning,
          decode(lpe.path_status_code,'CANCELLED' , 0,  'ACTIVE',1, 'COMPLETED', 2) path_status_number
   FROM ota_lp_enrollments lpe,
	       hr_lookups lkp
   WHERE lpe.learning_path_id = p_object_id
     AND lpe.person_id = p_learner_id
	 AND lkp.lookup_code  = lpe.path_status_code
	 AND lkp.lookup_type = 'OTA_LEARNING_PATH_STATUS'
     order by path_status_number desc;

CURSOR get_class_enr_status IS
   SELECT bst.type status_code,
          btt.name Status,
          bst.booking_status_type_id  status_id,
          decode(bst.type, 'C', 0,'R',1, 'W',2, 'P',3, 'E',4, 'A',5) status_number
   FROM ota_delegate_bookings tdb,
               ota_booking_status_types bst,
			   ota_booking_status_types_tl btt
   WHERE  tdb.delegate_person_id = p_learner_id
        AND  tdb.event_id = p_object_id
		AND tdb.booking_status_type_id = bst.booking_status_type_id
		AND bst.booking_status_type_id = btt.booking_status_type_id
		-- Added for bug#5572552
		AND btt.LANGUAGE = USERENV('LANG')
        order by status_number desc;

CURSOR get_cert_enr_status IS
SELECT cre.certification_status_code status_code,
          lkp.meaning Status_meaning,
          decode(cre.certification_status_code, 'REJECTED', 0, 'EXPIRED', 1, 'AWAITING_APPROVAL',2,
                 'CERTIFIED' , 3, 'CONCLUDED', 4,'ENROLLED',5) cert_status_number
   FROM ota_cert_enrollments cre,
	       hr_lookups lkp
   WHERE cre.certification_id = p_object_id
     AND cre.person_id = p_learner_id
	 AND lkp.lookup_code  =cre.certification_status_code
	 AND lkp.lookup_type = 'OTA_CERT_ENROLL_STATUS'
     order by cert_status_number desc;

l_status varchar2(100) := null;
l_status_code varchar2(30);
l_status_id NUMBER := NULL;
l_status_number NUMBER;
BEGIN
  IF p_object_type = 'LP' THEN
    OPEN get_lp_enr_status;
    FETCH get_lp_enr_status INTO l_status_code, l_status, l_status_number;
    CLOSE get_lp_enr_status;
 ELSIF p_object_type in ('CL','LPCL') THEN
    OPEN get_class_enr_status;
    FETCH get_class_enr_status INTO l_status_code, l_status, l_status_id, l_status_number;
    CLOSE get_class_enr_status;
 ELSIF p_object_type = 'CRT' THEN
    OPEN get_cert_enr_status;
    FETCH get_cert_enr_status INTO l_status_code, l_status, l_status_number;
    CLOSE get_cert_enr_status;
  END IF;
 IF p_return_mode = 1 THEN
     return l_status;
 ELSIF p_return_mode = 2 THEN
    return l_status_code;
 ELSIF p_return_mode = 3 THEN
    return l_status_id;
  END IF;
end get_enrollment_status;

FUNCTION get_enr_status_from_request(
   p_object_type IN VARCHAR2
   ,p_enrollment_status IN VARCHAR2) RETURN VARCHAR2
IS
  CURSOR get_class_enrollment_status IS
    SELECT btt.name
    FROM ota_booking_status_types_tl btt
    WHERE btt.language = USERENV('LANG')
      AND btt.booking_status_type_id = p_enrollment_status;

   CURSOR get_subscription_status IS
   SELECT lkp.meaning
   FROM hr_lookups lkp
   WHERE lkp.lookup_code = p_enrollment_status
      AND lkp.lookup_type = decode(p_object_type,'LP','OTA_LEARNING_PATH_STATUS','CRT','OTA_CERT_ENROLL_STATUS');

   l_status VARCHAR2(100) := null;
BEGIN
  IF p_enrollment_status IS NULL THEN
     RETURN NULL;
  ELSIF p_object_type in ('CL','LPCL') THEN
    OPEN get_class_enrollment_status;
    FETCH get_class_enrollment_status INTO l_status;
    CLOSE get_class_enrollment_status;
  ELSE
    OPEN get_subscription_status;
    FETCH get_subscription_status INTO l_status;
    CLOSE get_subscription_status;
  END IF;

 RETURN l_status;

END get_enr_status_from_request;


PROCEDURE assign_enrollment_status(p_class_id IN NUMBER
                                    , p_booking_status_id OUT NOCOPY NUMBER
									   , p_status_message OUT NOCOPY VARCHAR2)
IS
CURSOR get_enrolled_places IS
SELECT sum(nvl(tdb.number_of_places,1)) enrolled_places
FROM ota_delegate_bookings tdb, ota_booking_status_types bst
WHERE tdb.event_id = p_class_id
  and tdb.internal_booking_flag = 'Y'
  and tdb.booking_status_type_id = bst.booking_status_type_id
  and bst.type IN ('P', 'A','E');

l_enrolled_places number;
l_max_enroll number;
l_booking_status_row		OTA_BOOKING_STATUS_TYPES%ROWTYPE;
l_max_internal number;
l_event_status ota_events.event_status%TYPE;
l_maximum_internal_allowed number;

BEGIN
  OPEN get_enrolled_places;
  FETCH get_enrolled_places INTO l_enrolled_places;
  CLOSE get_enrolled_places;

  select MAXIMUM_INTERNAL_ATTENDEES, MAXIMUM_ATTENDEES, event_status
  INTO l_max_internal, l_max_enroll, l_event_status
  FROM ota_events
  WHERE event_id = p_class_id;

  l_maximum_internal_allowed := nvl(l_max_internal,l_max_enroll) - nvl(l_enrolled_places,0);

  IF l_event_status = 'F' THEN
     l_booking_status_row := OTA_LEARNER_ENROLL_SS.Get_Booking_Status_For_Web
			(p_web_booking_status_type => 'WAITLISTED'
			,p_business_group_id       => 81);

     p_booking_status_id := l_booking_status_row.booking_status_type_id;
     IF p_booking_status_id IS NOT NULL THEN
	   p_status_message := 'FULL_WAITILISTED';
     ELSE
	   p_status_message := 'NOSTATUS';
     END IF;

   ELSIF l_event_status in ('P') THEN
     l_booking_status_row := OTA_LEARNER_ENROLL_SS.Get_Booking_Status_For_Web
			(p_web_booking_status_type => 'REQUESTED'
			,p_business_group_id       => 81);

     p_booking_status_id := l_booking_status_row.booking_status_type_id;
     IF p_booking_status_id IS NOT NULL THEN
	    p_status_message := 'PLANNED_REQUESTED';
     ELSE
	    p_status_message := 'NOSTATUS';
     END IF;

   ELSIF l_event_status = 'N' THEN
      IF l_maximum_internal_allowed > 0  THEN
           l_booking_status_row := OTA_LEARNER_ENROLL_SS.Get_Booking_Status_For_Web
			    (p_web_booking_status_type => 'PLACED'
			    ,p_business_group_id       => 81);
           p_booking_status_id := l_booking_status_row.booking_status_type_id;
           IF p_booking_status_id IS NOT NULL THEN
	           p_status_message := 'NORMAL_PLACED';
           ELSE
	           p_status_message := 'NOSTATUS';
           END IF;

      ELSE
        l_booking_status_row := OTA_LEARNER_ENROLL_SS.Get_Booking_Status_For_Web
        	(p_web_booking_status_type => 'WAITLISTED'
      		 ,p_business_group_id       => 81);
        p_booking_status_id := l_booking_status_row.booking_status_type_id;
        IF p_booking_status_id IS NOT NULL THEN
	      p_status_message := 'NORMAL_WAITLISTED';
        ELSE
	      p_status_message := 'NOSTATUS';
        END IF;
      END IF;
    END IF;

END assign_enrollment_status;

FUNCTION get_total_selected_learners(p_bulk_enr_request_id IN NUMBER)
RETURN NUMBER
IS
 CURSOR csr_get_number_of_learners IS
 SELECT count(bulk_enr_request_id)
 FROM ota_bulk_enr_req_members
 WHERE bulk_enr_request_id = p_bulk_enr_request_id;

 l_total_enr_requested NUMBER := 0;
BEGIN
    OPEN csr_get_number_of_learners;
    FETCH csr_get_number_of_learners INTO   l_total_enr_requested;
    CLOSE csr_get_number_of_learners;

    RETURN l_total_enr_requested;
END get_total_selected_learners;

PROCEDURE get_enr_request_prereq_info(
    p_bulk_enr_request_id IN NUMBER
   ,p_unfulfil_course_prereqs OUT NOCOPY NUMBER
   ,p_unfulfil_comp_prereqs OUT NOCOPY NUMBER)
IS
CURSOR get_unfulfil_crs_prereq IS
SELECT count(person_id)
FROM ota_bulk_enr_req_members brm,
     ota_bulk_enr_requests ber,
     ota_events evt
WHERE ber.bulk_enr_request_id = brm.bulk_enr_request_id
AND ber.bulk_enr_request_id = p_bulk_enr_request_id
AND evt.event_id = ber.object_id
AND ber.object_type = 'CL'
AND ota_cpr_utility.is_mand_crs_prereqs_completed(brm.person_id
    , NULL
    , brm.person_id
    , 'E'
    , evt.activity_version_id) = 'N';

CURSOR get_unfulfil_comp_prereqs IS
 SELECT count(person_id)
FROM ota_bulk_enr_req_members brm,
     ota_bulk_enr_requests ber,
     ota_events evt
WHERE ber.bulk_enr_request_id = brm.bulk_enr_request_id
AND ber.bulk_enr_request_id = p_bulk_enr_request_id
AND evt.event_id = ber.object_id
AND ber.object_type = 'CL'
AND ota_cpr_utility.is_mand_comp_prereqs_completed(brm.person_id, evt.activity_version_id) = 'N';

BEGIN
  p_unfulfil_course_prereqs := 0;
  p_unfulfil_comp_prereqs := 0;

  OPEN get_unfulfil_crs_prereq;
  FETCH get_unfulfil_crs_prereq INTO p_unfulfil_course_prereqs;
  CLOSE get_unfulfil_crs_prereq;

  OPEN get_unfulfil_comp_prereqs;
  FETCH get_unfulfil_comp_prereqs INTO p_unfulfil_comp_prereqs;
  CLOSE get_unfulfil_comp_prereqs;

END get_enr_request_prereq_info;


PROCEDURE get_enr_request_info(
    p_bulk_enr_request_id IN NUMBER
   ,p_selected_learners OUT NOCOPY NUMBER
   ,p_unfulfil_course_prereqs OUT NOCOPY NUMBER
   ,p_unfulfil_comp_prereqs OUT NOCOPY NUMBER)
IS
l_request_rec csr_get_request_info%ROWTYPE;

BEGIN
  OPEN csr_get_request_info(p_bulk_enr_request_id);
  FETCH csr_get_request_info INTO l_request_rec;
  IF csr_get_request_info%NOTFOUND THEN
    CLOSE csr_get_request_info;
    --ERRROR - this cond should not occur
       p_unfulfil_course_prereqs := 0;
       p_unfulfil_comp_prereqs := 0;
       p_selected_learners := 0;
       RETURN;
  ELSE
    CLOSE csr_get_request_info;
    p_selected_learners := get_total_selected_learners(p_bulk_enr_request_id);
    IF l_request_rec.object_type NOT IN ('CL','LPCL') THEN
       p_unfulfil_course_prereqs := 0;
       p_unfulfil_comp_prereqs := 0;
    ELSE
     get_enr_request_prereq_info(
            p_bulk_enr_request_id
           ,p_unfulfil_course_prereqs
           ,p_unfulfil_comp_prereqs);
    END IF;
  END IF;
END get_enr_request_info;

PROCEDURE get_enr_req_completion_status(
    p_bulk_enr_request_id IN NUMBER
   ,p_selected_learners OUT NOCOPY NUMBER
   ,p_success_enrollments OUT NOCOPY NUMBER
   ,p_errored_enrollments OUT NOCOPY NUMBER
   ,p_unfulfil_course_prereqs OUT NOCOPY NUMBER
   ,p_unfulfil_comp_prereqs OUT NOCOPY NUMBER)
IS

  CURSOR get_success_enrollments IS
  SELECT count(person_id)
  FROM ota_bulk_enr_req_members
  WHERE bulk_enr_request_id = p_bulk_enr_request_id
   AND enrollment_status IS NOT NULL;

  CURSOR get_errored_enrollments IS
  SELECT count(person_id)
  FROM ota_bulk_enr_req_members
  WHERE bulk_enr_request_id = p_bulk_enr_request_id
    AND error_message IS NOT NULL;
BEGIN
  get_enr_request_info(
    p_bulk_enr_request_id => p_bulk_enr_request_id
   ,p_selected_learners => p_selected_learners
   ,p_unfulfil_course_prereqs => p_unfulfil_course_prereqs
   ,p_unfulfil_comp_prereqs => p_unfulfil_comp_prereqs);

  OPEN get_success_enrollments;
  FETCH get_success_enrollments INTO p_success_enrollments;
  CLOSE get_success_enrollments;

  OPEN get_errored_enrollments;
  FETCH get_errored_enrollments INTO p_errored_enrollments;
  CLOSE get_errored_enrollments;

END get_enr_req_completion_status;


Function get_enrolled_learners(
    p_object_type IN VARCHAR2
   ,p_object_id IN VARCHAR2)
RETURN NUMBER IS

CURSOR cse_get_class_enrollments IS
SELECT sum(nvl(tdb.number_of_places,0))
FROM ota_delegate_bookings tdb
   , ota_booking_status_types bst
WHERE tdb.booking_status_type_id = bst.booking_status_type_id
  AND tdb.event_id = p_object_id
  --TBD: needs to be confirmed if Requested(R) and Waitlisted(W) should also be included here
  AND bst.type NOT IN ('C');

CURSOR csr_get_lp_enrollments IS
SELECT count(lp_enrollment_id)
FROM ota_lp_enrollments
WHERE learning_path_id = p_object_id
  AND path_status_code <> 'CANCELLED';

CURSOR csr_get_cert_enrollments IS
SELECT count(cert_enrollment_id)
FROM ota_cert_enrollments crt
WHERE certification_id = p_object_id
--TBD: Confirm if this is correct
 AND CERTIFICATION_STATUS_CODE <> 'CANCELLED';

l_enrolled_learners NUMBER := 0;

BEGIN
 IF p_object_type in ('CL','LPCL') THEN
   OPEN cse_get_class_enrollments;
   FETCH cse_get_class_enrollments INTO l_enrolled_learners;
   CLOSE cse_get_class_enrollments;

 ELSIF p_object_type = 'LP' THEN
   OPEN csr_get_lp_enrollments;
   FETCH csr_get_lp_enrollments INTO l_enrolled_learners;
   CLOSE csr_get_lp_enrollments;

 ELSIF p_object_type = 'CRT' THEN
   OPEN csr_get_cert_enrollments;
   FETCH csr_get_cert_enrollments INTO l_enrolled_learners;
   CLOSE csr_get_cert_enrollments;
 END IF;

 RETURN l_enrolled_learners;
END get_enrolled_learners;

PROCEDURE Create_Enrollment_And_Finance( p_event_id	           	 IN VARCHAR2
					,p_extra_information		 IN VARCHAR2
	 		                ,p_cost_centers		   	 IN VARCHAR2
	        			,p_assignment_id		 IN PER_ALL_ASSIGNMENTS_F.assignment_id%TYPE
	        			,p_business_group_id_from	 IN PER_ALL_ASSIGNMENTS_F.business_group_id%TYPE
	        			,p_organization_id               IN PER_ALL_ASSIGNMENTS_F.organization_id%TYPE
					,p_person_id                     IN PER_ALL_PEOPLE_F.person_id%type
			                ,p_delegate_contact_id           IN NUMBER
	                		,p_booking_id                    OUT NOCOPY OTA_DELEGATE_BOOKINGS.Booking_id%type
			                ,p_message_name 		 OUT NOCOPY varchar2
	                                ,p_tdb_information_category      IN VARCHAR2
	                                ,p_tdb_information1              IN VARCHAR2
	                                ,p_tdb_information2              IN VARCHAR2
	                                ,p_tdb_information3              IN VARCHAR2
	                                ,p_tdb_information4              IN VARCHAR2
	                                ,p_tdb_information5              IN VARCHAR2
	                                ,p_tdb_information6              IN VARCHAR2
	                                ,p_tdb_information7              IN VARCHAR2
	                                ,p_tdb_information8              IN VARCHAR2
	                                ,p_tdb_information9              IN VARCHAR2
	                                ,p_tdb_information10             IN VARCHAR2
	                                ,p_tdb_information11             IN VARCHAR2
	                                ,p_tdb_information12             IN VARCHAR2
	                                ,p_tdb_information13             IN VARCHAR2
	                                ,p_tdb_information14             IN VARCHAR2
	                                ,p_tdb_information15             IN VARCHAR2
	                                ,p_tdb_information16             IN VARCHAR2
	                                ,p_tdb_information17             IN VARCHAR2
	                                ,p_tdb_information18             IN VARCHAR2
	                                ,p_tdb_information19             IN VARCHAR2
	                                ,p_tdb_information20             IN VARCHAR2
					,p_booking_justification_id      IN VARCHAR2
                    ,p_override_prerequisites 	IN VARCHAR2
                    ,p_override_learner_access IN VARCHAR2
                    ,p_is_mandatory_enrollment IN VARCHAR2 default 'N')
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
SELECT sum(nvl(dbt.number_of_places, 0))
FROM   OTA_DELEGATE_BOOKINGS dbt,
       OTA_BOOKING_STATUS_TYPES bst
WHERE  dbt.event_id = TO_NUMBER(p_event_id)
AND    dbt.internal_booking_flag = 'Y'
AND    dbt.booking_status_type_id = bst.booking_status_type_id
AND    bst.type in ('P','A','E');

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


--Added FOR bug#5579345
/*CURSOR csr_get_assignment_details IS
SELECT ppf.work_telephone,
       paf.organization_id,
       ppf.email_address
FROM
  per_all_people_f ppf,
  per_all_assignments_f paf
WHERE
      ppf.person_id = paf.person_id
  AND trunc(sysdate) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
  AND trunc(sysdate) BETWEEN paf.effective_start_date AND paf.effective_end_date
  AND ppf.person_id = p_person_id
  AND paf.assignment_id = p_assignment_id;*/

  --Bug6723416 :Modified the cursor to fetch phone number from per_phones

  /*CURSOR csr_get_assignment_details IS
  SELECT PPH.PHONE_NUMBER work_telephone,
         paf.organization_id,
         ppf.email_address
  FROM
    per_all_people_f ppf,
    per_all_assignments_f paf ,
    per_phones pph
  WHERE
        ppf.person_id = paf.person_id
    AND trunc(sysdate) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
    AND trunc(sysdate) BETWEEN paf.effective_start_date AND paf.effective_end_date
    AND ppf.person_id = p_person_id
    AND paf.assignment_id = p_assignment_id
    AND pph.PARENT_ID(+) = ppf.PERSON_ID
    AND pph.PARENT_TABLE(+) = 'PER_ALL_PEOPLE_F'
    AND pph.PHONE_TYPE(+) = 'W1'
  --AND trunc(sysdate) BETWEEN NVL(PPH.DATE_FROM, SYSDATE) AND NVL(PPH.DATE_TO, SYSDATE);For bug6770085
    AND trunc(sysdate) BETWEEN NVL(PPH.DATE_FROM(+), SYSDATE) AND NVL(PPH.DATE_TO(+), SYSDATE);*/

    CURSOR csr_get_assignment_details IS
      SELECT PPH.PHONE_NUMBER work_telephone,
             paf.organization_id,
             ppf.email_address,
             pfax.PHONE_NUMBER fax_number
      FROM
        per_all_people_f ppf,
        per_all_assignments_f paf ,
        per_phones pph,
        per_phones pfax
      WHERE
            ppf.person_id = paf.person_id
        AND trunc(sysdate) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
        AND trunc(sysdate) BETWEEN paf.effective_start_date AND paf.effective_end_date
        AND ppf.person_id = p_person_id
        AND paf.assignment_id = p_assignment_id
        AND pph.PARENT_ID(+) = ppf.PERSON_ID
        AND pph.PARENT_TABLE(+) = 'PER_ALL_PEOPLE_F'
        AND pph.PHONE_TYPE(+) = 'W1'
      --AND trunc(sysdate) BETWEEN NVL(PPH.DATE_FROM, SYSDATE) AND NVL(PPH.DATE_TO, SYSDATE);For bug6770085
        AND trunc(sysdate) BETWEEN NVL(PPH.DATE_FROM(+), SYSDATE) AND NVL(PPH.DATE_TO(+), SYSDATE)
        AND pfax.PARENT_ID(+) = ppf.PERSON_ID
        AND pfax.PARENT_TABLE(+) = 'PER_ALL_PEOPLE_F'
        AND pfax.PHONE_TYPE(+) = 'WF'
        AND trunc(sysdate) BETWEEN NVL(pfax.DATE_FROM(+), SYSDATE) AND NVL(pfax.DATE_TO(+), SYSDATE);


  l_price_basis     		OTA_EVENTS.price_basis%TYPE;

  l_person_details		csr_get_assignment_details%ROWTYPE;
  --
  l_booking_status_row		OTA_BOOKING_STATUS_TYPES%ROWTYPE;
  l_booking_id			OTA_DELEGATE_BOOKINGS.booking_id%type := null;
  l_object_version_number	BINARY_INTEGER;
  l_tfl_ovn			BINARY_INTEGER;
  l_finance_line_id		OTA_FINANCE_LINES.finance_line_id%type:= null;
  l_booking_type		VARCHAR2(4000);
  l_error_crypt			VARCHAR2(4000);
  --
  l_mode			VARCHAR2(200);
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
  fapi_from			VARCHAR2(5);
  fapi_to			VARCHAR2(5);

  result_finance_header_id	OTA_FINANCE_LINES.finance_header_id%TYPE;
  result_create_finance_line 	VARCHAR2(5) := 'Y';
  result_object_version_number	OTA_FINANCE_LINES.object_version_number%TYPE;

  l_logged_in_user		NUMBER;
  l_user			NUMBER;
  l_automatic_transfer_gl	VARCHAR2(40);
  l_notification_text		VARCHAR2(1000);
  l_cost_allocation_keyflex_id  VARCHAR2(1000);

  l_event_status  		VARCHAR2(30);

  l_maximum_internal_attendees  NUMBER;
  l_existing_internal           NUMBER;
  l_maximum_internal_allowed    NUMBER;

  l_called_from  		VARCHAR2(80);
  l_business_group_id_to  	hr_all_organization_units.organization_id%type;
  l_sponsor_organization_id  	hr_all_organization_units.organization_id%type;
  l_event_currency_code      	ota_events.currency_code%type;
  l_event_title   		ota_events.title%type;
  l_course_start_date 		ota_events.course_start_date%type;
  l_course_end_date 		ota_events.course_end_date%type;
  l_owner_id  			ota_events.owner_id%type;
  l_activity_version_id 	ota_activity_versions.activity_version_id%type;
  l_version_name 		ota_activity_versions.version_name%type;
  l_owner_username 		fnd_user.user_name%type;
  l_offering_id 		ota_events.offering_id%type;
  l_booking_status_used    	VARCHAR2(20);

 l_existing_bookings           NUMBER;
 l_maximum_external_allowed    NUMBER;
 l_maximum_attendees           NUMBER;
 l_internal_booking_flag       OTA_DELEGATE_BOOKINGS.internal_booking_flag%TYPE;
 l_work_telephone              OTA_DELEGATE_BOOKINGS.delegate_contact_phone%TYPE := NULL;
 l_work_fax		       OTA_DELEGATE_BOOKINGS.delegate_contact_fax%TYPE := NULL;
 l_organization_id             OTA_DELEGATE_BOOKINGS.organization_id%TYPE := NULL;
 l_assignment_id               OTA_DELEGATE_BOOKINGS.delegate_assignment_id%TYPE := NULL;
 l_email_address               OTA_DELEGATE_BOOKINGS.delegate_contact_email%TYPE := NULL;
 l_person_address_type         VARCHAR2(1);
 l_ext_lrnr_details   	       ota_learner_enroll_ss.csr_ext_lrnr_Details%ROWTYPE;
 l_customer_id                 HZ_CUST_ACCOUNT_ROLES.cust_account_id%type := NULL;
 l_corespondent                VARCHAR2(1) := NULL;
 l_source_of_booking           VARCHAR2(30) := NULL;                 --Bug 5580960 : Incleased the SIZE.
 l_enrollment_type             VARCHAR2(1) := 'S';
 l_priority_level	       VARCHAR2(30) := null;

 -- Added for DFF defaulting bug#5478206
 l_attribute_category VARCHAR2(30) := p_tdb_information_category;
 l_attribute1 VARCHAR2(150)  := p_tdb_information1 ;
 l_attribute2 VARCHAR2(150)  := p_tdb_information2 ;
 l_attribute3 VARCHAR2(150)  := p_tdb_information3 ;
 l_attribute4 VARCHAR2(150)  := p_tdb_information4 ;
 l_attribute5 VARCHAR2(150)  := p_tdb_information5 ;
 l_attribute6 VARCHAR2(150)  := p_tdb_information6 ;
 l_attribute7 VARCHAR2(150)  := p_tdb_information7 ;
 l_attribute8 VARCHAR2(150)  := p_tdb_information8 ;
 l_attribute9 VARCHAR2(150)  := p_tdb_information9 ;
 l_attribute10 VARCHAR2(150) := p_tdb_information10 ;
 l_attribute11 VARCHAR2(150) := p_tdb_information11 ;
 l_attribute12 VARCHAR2(150) := p_tdb_information12 ;
 l_attribute13 VARCHAR2(150) := p_tdb_information13 ;
 l_attribute14 VARCHAR2(150) := p_tdb_information14 ;
 l_attribute15 VARCHAR2(150) := p_tdb_information15 ;
 l_attribute16 VARCHAR2(150) := p_tdb_information16 ;
 l_attribute17 VARCHAR2(150) := p_tdb_information17 ;
 l_attribute18 VARCHAR2(150) := p_tdb_information18 ;
 l_attribute19 VARCHAR2(150) := p_tdb_information19 ;
 l_attribute20 VARCHAR2(150) := p_tdb_information20 ;
 -- end of code added for bug#5478206
BEGIN

  HR_UTIL_MISC_WEB.VALIDATE_SESSION(p_person_id => l_logged_in_user);

  -- ----------------------------------------------------------------------
  --  RETRIEVE THE DATA REQUIRED
  -- ----------------------------------------------------------------------
 ota_utility.Get_Default_Value_Dff( appl_short_name => 'OTA'
                                   ,flex_field_name => 'OTA_DELEGATE_BOOKINGS'
                                   ,p_attribute_category           => l_attribute_category
                                   ,p_attribute1                   => l_attribute1
		     	           ,p_attribute2                   => l_attribute2
				   ,p_attribute3                   => l_attribute3
				   ,p_attribute4                   => l_attribute4
				   ,p_attribute5                   => l_attribute5
				   ,p_attribute6                   => l_attribute6
				   ,p_attribute7                   => l_attribute7
				   ,p_attribute8                   => l_attribute8
				   ,p_attribute9                   => l_attribute9
				   ,p_attribute10                  => l_attribute10
				   ,p_attribute11                  => l_attribute11
				   ,p_attribute12                  => l_attribute12
				   ,p_attribute13                  => l_attribute13
				   ,p_attribute14                  => l_attribute14
				   ,p_attribute15                  => l_attribute15
				   ,p_attribute16                  => l_attribute16
				   ,p_attribute17                  => l_attribute17
				   ,p_attribute18                  => l_attribute18
				   ,p_attribute19                  => l_attribute19
				   ,p_attribute20                  => l_attribute20);


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
   -- l_source_of_booking := 'E';                   Bug 5580960: removed hardcoding. Now Source of Booking will be decided by profile value OTA_DEFAULT_ENROLLMENT_SOURCE
   l_source_of_booking := fnd_profile.value('OTA_DEFAULT_ENROLLMENT_SOURCE');

     l_restricted_assignment_id := p_assignment_id;

    --Modified for bug#5579345
    --  l_person_details := ota_learner_enroll_ss.Get_Person_To_Enroll_Details(p_person_id => l_delegate_id);
    OPEN csr_get_assignment_details;
    FETCH csr_get_assignment_details INTO l_person_details;
    IF csr_get_assignment_details%NOTFOUND THEN
      CLOSE csr_get_assignment_details;
      fnd_message.set_name ('OTA','OTA_NO_DELEGATE_INFORMATION');
      --
      -- Raise the error for the main procedure exception handler
      -- to handle
      p_message_name := SUBSTR(SQLERRM, 1,300);
      RETURN;
    ELSE
      l_internal_booking_flag       := 'Y';
      l_work_telephone              := l_person_details.work_telephone;
      l_organization_id             := l_person_details.organization_id;
      l_assignment_id               := p_assignment_id;
      l_email_address               := l_person_details.email_address;
      l_work_fax	            := l_person_details.fax_number;
      CLOSE csr_get_assignment_details;
    END IF;

  ELSE
    l_internal_booking_flag       := 'N';
    l_person_address_type	  := null;
    l_ext_lrnr_details            := ota_learner_enroll_ss.Get_ext_lrnr_Details(p_delegate_contact_id);
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

            l_booking_status_row := ota_learner_enroll_ss.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'WAITLISTED'
			,p_business_group_id       => ota_general.get_business_group_id);

            l_booking_status_used := 'WAITLISTED';

     /*ELSIF l_event_status in ('P') THEN

            l_booking_status_row := ota_learner_enroll_ss.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'REQUESTED'
			,p_business_group_id       => ota_general.get_business_group_id);

            l_booking_status_used := 'REQUESTED';*/

     ELSIF l_event_status = 'N' THEN

            IF l_maximum_internal_attendees  is null then
               l_booking_status_row := ota_learner_enroll_ss.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'PLACED'
			,p_business_group_id       => ota_general.get_business_group_id);

                l_booking_status_used := 'PLACED';

            ELSE

              IF l_maximum_internal_allowed > 0 OR l_maximum_external_allowed > 0 THEN
                 l_booking_status_row := ota_learner_enroll_ss.Get_Booking_Status_for_web
			(p_web_booking_status_type => 'PLACED'
			,p_business_group_id       => ota_general.get_business_group_id);

                l_booking_status_used := 'PLACED';

             ELSIF l_maximum_internal_allowed <= 0 OR l_maximum_external_allowed <= 0 THEN
               l_booking_status_row := ota_learner_enroll_ss.Get_Booking_Status_for_web
       			(p_web_booking_status_type => 'WAITLISTED'
      			 ,p_business_group_id       => ota_general.get_business_group_id);

               l_booking_status_used := 'WAITLISTED';

            END IF;
          END IF;
         IF l_booking_status_row.booking_Status_type_id is null then
              fnd_message.set_name ('OTA','OTA_13667_WEB_STATUS_NOT_SEEDE');
              RAISE ota_learner_enroll_ss.g_mesg_on_stack_exception ;
         END IF ;
      END IF;

    EXCEPTION
      WHEN ota_learner_enroll_ss.g_mesg_on_stack_exception THEN
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
      ELSIF (hr_message.last_message_name = 'HR_51396_WEB_PERSON_NOT_FND') THEN
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
        --
         p_message_name :=  SUBSTR(SQLERRM, 1,300);

    END ;
  --
  -- ----------------------------------------------------------------------
  -- Save
  -- ----------------------------------------------------------------------
  -- If there are no errors, save to the database
  -- (there shouldn't be as the main exception handler will be used
  --
IF p_message_name is null then


 BEGIN
  --
  -- Check to see if delegate has a booking status of CANCELLED for
  --  this event, if cancelled l_cancel_boolean is set to true
  --  FIX for bug 900679
  --
    l_cancel_boolean := ota_learner_enroll_ss.Chk_Event_Cancelled_for_Person(
               p_event_id            => p_event_id
       	      ,p_delegate_person_id  => l_delegate_id
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
      ota_learner_enroll_ss.cancel_finance(l_booking_id);


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
                         	p_assignment_id		    =>	p_assignment_id,
				p_business_group_id_from    =>	p_business_group_id_from,
				p_business_group_id_to	    =>	l_business_group_id_to,
				p_organization_id	    =>	p_organization_id,
				p_sponsor_organization_id   =>	l_sponsor_organization_id,
				p_event_id		    =>	p_event_id,
				p_person_id		    => 	l_delegate_id,
				p_currency_code		    =>	l_event_currency_code,
				p_cost_allocation_keyflex_id=> 	l_cost_allocation_keyflex_id,
				p_user_id		    => 	l_user,
 				p_finance_header_id	    => 	fapi_finance_header_id,
				p_object_version_number	    => 	fapi_object_version_number,
				p_result		    => 	fapi_result,
				p_from_result		    => 	fapi_from,
				p_to_result		    => 	fapi_to );

	     IF fapi_result = 'S' THEN
		result_object_version_number := fapi_object_version_number;
		result_finance_header_id     := fapi_finance_header_id;

	     ELSIF fapi_result = 'E' THEN
     		result_object_version_number := l_object_version_number;
		result_finance_header_id     := NULL;
		result_create_finance_line   := NULL;
	     END IF;

	      ota_tdb_api_ins2.Create_Enrollment(
                               p_booking_id                   => l_booking_id
      			      ,p_booking_status_type_id       => l_booking_status_row.booking_status_type_id
      			      ,p_delegate_person_id           => l_delegate_id
			      ,p_delegate_contact_id          => null
      			      ,p_contact_id                   => null
			      ,p_business_group_id            => ota_general.get_business_group_id
      			      ,p_event_id                     => p_event_id
      			     -- ,p_date_booking_placed        => trunc(sysdate)
			      ,p_date_booking_placed          => sysdate
      			      ,p_corespondent          	      => l_corespondent
      			      ,p_internal_booking_flag        => l_internal_booking_flag
			      ,p_person_address_type          => l_person_address_type
      			      ,p_number_of_places             => 1
      			      ,p_object_version_number        => result_object_version_number
      			      ,p_delegate_contact_phone	      => l_work_telephone
      			      ,p_delegate_contact_fax	      => l_work_fax
     			      ,p_source_of_booking            => l_source_of_booking
      			      ,p_special_booking_instructions => p_extra_information
      			      ,p_successful_attendance_flag   => 'N'
			      ,p_finance_header_id	      => result_finance_header_id
			      ,p_create_finance_line	      => result_create_finance_line
      			      ,p_finance_line_id              => l_finance_line_id
      			      ,p_enrollment_type              => l_enrollment_type
			      ,p_validate                     => FALSE
			      ,p_currency_code		      => l_event_currency_code
      			      ,p_organization_id              => l_organization_id
      			      ,p_delegate_assignment_id       => l_assignment_id
 			      ,p_delegate_contact_email       => l_email_address
			      -- Modified for bug#5478206
                              ,p_tdb_information_category     => l_attribute_category
                              ,p_tdb_information1             => l_attribute1
                              ,p_tdb_information2             => l_attribute2
                              ,p_tdb_information3             => l_attribute3
                              ,p_tdb_information4             => l_attribute4
                              ,p_tdb_information5             => l_attribute5
                              ,p_tdb_information6             => l_attribute6
                              ,p_tdb_information7             => l_attribute7
                              ,p_tdb_information8             => l_attribute8
                              ,p_tdb_information9             => l_attribute9
                              ,p_tdb_information10            => l_attribute10
                              ,p_tdb_information11            => l_attribute11
                              ,p_tdb_information12            => l_attribute12
                              ,p_tdb_information13            => l_attribute13
                              ,p_tdb_information14            => l_attribute14
                              ,p_tdb_information15            => l_attribute15
                              ,p_tdb_information16            => l_attribute16
                              ,p_tdb_information17            => l_attribute17
                              ,p_tdb_information18            => l_attribute18
                              ,p_tdb_information19            => l_attribute19
                              ,p_tdb_information20            => l_attribute20
			      ,p_booking_justification_id     => p_booking_justification_id
			      ,p_booking_priority             => l_priority_level
                              ,p_override_prerequisites       => p_override_prerequisites
                              ,p_override_learner_access      => 'Y'
                              ,p_is_mandatory_enrollment   => p_is_mandatory_enrollment
			      );


		IF l_automatic_transfer_gl = 'Y' AND l_finance_line_id IS NOT NULL AND l_offering_id is null THEN

			UPDATE ota_finance_lines SET transfer_status = 'AT'
			WHERE finance_line_id = l_finance_line_id;



		END IF;

	   ELSE

	      ota_tdb_api_ins2.Create_Enrollment(p_booking_id                   => l_booking_id
      						,p_booking_status_type_id   	=> l_booking_status_row.booking_status_type_id
      						,p_delegate_person_id       	=> l_delegate_id
			                        ,p_delegate_contact_id          => p_delegate_contact_id
						,p_customer_id                  => l_customer_id
      						,p_contact_id               	=> null
						,p_business_group_id        	=> ota_general.get_business_group_id
      						,p_event_id                 	=> p_event_id
      					     -- ,p_date_booking_placed     	=> trunc(sysdate)
			                        ,p_date_booking_placed     	=> sysdate
      						,p_corespondent        		=> l_corespondent
      						,p_internal_booking_flag    	=> l_internal_booking_flag
						,p_person_address_type          => l_person_address_type
      						,p_number_of_places         	=> 1
      						,p_object_version_number    	=> l_object_version_number
      						,p_delegate_contact_phone	=> l_work_telephone
      						,p_delegate_contact_fax	      => l_work_fax
     						,p_source_of_booking        	=> l_source_of_booking
      						,p_special_booking_instructions => p_extra_information
      						,p_successful_attendance_flag   => 'N'
      						,p_finance_line_id          	=> l_finance_line_id
      						,p_enrollment_type          	=> l_enrollment_type
						,p_validate               	=> FALSE
                                                ,p_organization_id          	=> l_organization_id
      					        ,p_delegate_assignment_id   	=> l_assignment_id
 						,p_delegate_contact_email 	=> l_email_address
						-- Modified for bug#5478206
					        ,p_tdb_information_category     => l_attribute_category
  					        ,p_tdb_information1             => l_attribute1
					        ,p_tdb_information2             => l_attribute2
					        ,p_tdb_information3             => l_attribute3
					        ,p_tdb_information4             => l_attribute4
					        ,p_tdb_information5             => l_attribute5
					        ,p_tdb_information6             => l_attribute6
					        ,p_tdb_information7             => l_attribute7
					        ,p_tdb_information8             => l_attribute8
					        ,p_tdb_information9             => l_attribute9
					        ,p_tdb_information10            => l_attribute10
					        ,p_tdb_information11            => l_attribute11
					        ,p_tdb_information12            => l_attribute12
					        ,p_tdb_information13            => l_attribute13
					        ,p_tdb_information14            => l_attribute14
					        ,p_tdb_information15            => l_attribute15
					        ,p_tdb_information16            => l_attribute16
					        ,p_tdb_information17            => l_attribute17
					        ,p_tdb_information18            => l_attribute18
					        ,p_tdb_information19            => l_attribute19
					        ,p_tdb_information20            => l_attribute20
						,p_booking_justification_id     => p_booking_justification_id
						,p_booking_priority             => l_priority_level
                                                ,p_override_prerequisites       => p_override_prerequisites
                                                ,p_override_learner_access      => 'Y'
                                                ,p_is_mandatory_enrollment   => p_is_mandatory_enrollment
						);


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
       p_message_name := fnd_message.get;
      --
 END;       -- End of if p_message is not null

END IF;
EXCEPTION
  WHEN OTHERS THEN
     p_message_name :=  SUBSTR(SQLERRM, 1,300);
END Create_Enrollment_And_Finance;


FUNCTION get_object_name(p_object_type IN VARCHAR2, p_object_id IN NUMBER)
RETURN VARCHAR2 IS
  CURSOR csr_get_lp_name IS
  SELECT name
  FROM ota_learning_paths_tl
  WHERE learning_path_id = p_object_id
    AND language = USERENV('LANG');

  CURSOR csr_get_cert_name IS
  SELECT name
  FROM ota_certifications_tl
  WHERE certification_id = p_object_id
    AND language = USERENV('LANG');

  CURSOR csr_get_class_name IS
  SELECT title
  FROM ota_events_tl
  WHERE event_id = p_object_id
    AND language = USERENV('LANG');

  l_class_name OTA_EVENTS_TL.TITLE%TYPE := NULL;
  l_lp_name OTA_LEARNING_PATHS_TL.NAME%TYPE := NULL;
  l_cert_name OTA_CERTIFICATIONS_TL.NAME%TYPE := NULL;
BEGIN
 IF p_object_type in ('CL','LPCL') THEN
   OPEN csr_get_class_name;
   FETCH csr_get_class_name INTO l_class_name;
   CLOSE csr_get_class_name;
   RETURN l_class_name;

 ELSIF p_object_type = 'LP' THEN
   OPEN csr_get_lp_name;
   FETCH csr_get_lp_name INTO l_lp_name;
   CLOSE csr_get_lp_name;
   RETURN l_lp_name;

 ELSIF p_object_type = 'CRT' THEN
   OPEN csr_get_cert_name;
   FETCH csr_get_cert_name INTO l_cert_name;
   CLOSE csr_get_cert_name;
   RETURN l_cert_name;
 END IF;
 RETURN NULL;
END get_object_name;

PROCEDURE delete_bulk_enr_request
		(itemtype   IN WF_ITEMS.ITEM_TYPE%TYPE
		,itemkey    IN WF_ITEMS.ITEM_KEY%TYPE
  		,actid	    IN NUMBER
   	        ,funcmode   IN VARCHAR2
	        ,resultout  OUT nocopy VARCHAR2 ) AS

l_blk_enr_request_id OTA_BULK_ENR_REQUESTS.BULK_ENR_REQUEST_ID%TYPE;
BEGIN
  IF (funcmode='RUN') THEN
    l_blk_enr_request_id := WF_ENGINE.getitemattrtext(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname     =>'BLK_ENR_REQUEST_ID',
                                      ignore_notfound => true);

    DELETE FROM OTA_BULK_ENR_REQ_MEMBERS
    WHERE BULK_ENR_REQUEST_ID = l_blk_enr_request_id;

    DELETE FROM OTA_BULK_ENR_REQUESTS
    WHERE BULK_ENR_REQUEST_ID = l_blk_enr_request_id;

    COMMIT;

    resultout := 'COMPLETE';
  ELSE IF (funcmode='CANCEL')  THEN
    resultout := 'COMPLETE';
  END IF;
 END IF;
END delete_bulk_enr_request;



PROCEDURE notify_requestor(p_enr_request_id IN NUMBER)
IS
    l_proc 	varchar2(72) := g_package||'create_wf_process';
    l_process             	wf_activities.name%type :='OTA_BLK_ENR_NTF_PRC';
    l_item_type    wf_items.item_type%type := 'OTWF';
    l_item_key     wf_items.item_key%type;

    l_user_name  varchar2(80);
    l_person_id   per_all_people_f.person_id%type;

    l_process_display_name varchar2(240);
    l_request_rec csr_get_request_info%ROWTYPE;


Cursor get_display_name is
SELECT wrpv.display_name displayName
FROM   wf_runnable_processes_v wrpv
WHERE wrpv.item_type = l_item_type
AND wrpv.process_name = l_process;


CURSOR csr_get_user_name(p_person_id IN VARCHAR2) IS
SELECT user_name
FROM fnd_user
WHERE employee_id=p_person_id;


CURSOR csr_get_person_name(p_person_id IN number) IS
SELECT ppf.full_name
FROM per_all_people_f ppf
WHERE person_id = p_person_id;

CURSOR csr_get_error_learners IS
SELECT COUNT(person_id)
FROM ota_bulk_enr_req_members
WHERE bulk_enr_request_id = p_enr_request_id
  and error_message IS NOT NULL;

CURSOR csr_get_selected_learners IS
SELECT COUNT(person_id)
FROM ota_bulk_enr_req_members
WHERE bulk_enr_request_id = p_enr_request_id;

CURSOR csr_get_successful_learners IS
SELECT COUNT(person_id)
FROM ota_bulk_enr_req_members
WHERE bulk_enr_request_id = p_enr_request_id
 and enrollment_status IS NOT NULL;

l_object_name VARCHAR2(240);
l_person_full_name per_all_people_f.FULL_NAME%TYPE;
l_error_learners NUMBER := 0;
l_success_learners NUMBER := 0;
l_selected_learners NUMBER := 0;

    l_role_name wf_roles.name%type;
    l_role_display_name wf_roles.display_name%type;

BEGIN
	hr_utility.set_location('Entering:'||l_proc, 5);


	OPEN get_display_name;
	FETCH get_display_name INTO l_process_display_name;
	CLOSE get_display_name;

	OPEN csr_get_request_info(p_enr_request_id);
	FETCH csr_get_request_info INTO l_request_rec;
    CLOSE csr_get_request_info;

	l_object_name := OTA_BULK_ENROLL_UTIL.get_object_name(l_request_rec.object_type, l_request_rec.object_id);

	-- Get the next item key from the sequence
	select hr_workflow_item_key_s.nextval
	into   l_item_key
	from   sys.dual;

    WF_ENGINE.CREATEPROCESS(l_item_type, l_item_key, l_process);

	l_person_id := l_request_rec.requestor_id;

    wf_engine.additemattr
        (itemtype => l_item_type
        ,itemkey  => l_item_key
        ,aname    => 'BLK_ENR_REQUEST_ID');

    WF_ENGINE.setitemattrnumber(l_item_type,l_item_key,'BLK_ENR_REQUEST_ID',p_enr_request_id);
    WF_ENGINE.setitemattrnumber(l_item_type,l_item_key,'CONC_REQUEST_ID',l_request_rec.conc_program_request_id);
    --Enh 5606090: Language support for Bulk enrollment.
    WF_ENGINE.setitemattrtext(l_item_type,l_item_key,'OBJECT_NAME',l_request_rec.object_id);
    WF_ENGINE.setitemattrtext(
                l_item_type
               ,l_item_key
               ,'OBJECT_TYPE'
               ,l_request_rec.object_type);
     OPEN csr_get_error_learners;
    FETCH csr_get_error_learners INTO l_error_learners;
    CLOSE csr_get_error_learners;

    OPEN csr_get_selected_learners;
    FETCH csr_get_selected_learners INTO l_selected_learners;
    CLOSE csr_get_selected_learners;

    OPEN csr_get_successful_learners;
    FETCH csr_get_successful_learners INTO l_success_learners;
    CLOSE csr_get_successful_learners;

    WF_ENGINE.setitemattrnumber(l_item_type,l_item_key,'TOTAL_NUMBER',l_selected_learners);
    WF_ENGINE.setitemattrnumber(l_item_type,l_item_key,'ERROR_NUMBER',l_error_learners);
    WF_ENGINE.setitemattrnumber(l_item_type,l_item_key,'SUCCESS_NUMBER',l_success_learners);

	IF l_person_id IS NOT NULL THEN
       OPEN csr_get_person_name(l_person_id);
       FETCH csr_get_person_name INTO l_person_full_name;
       CLOSE csr_get_person_name;

	    SELECT user_name INTO l_user_name
	    FROM fnd_user
	    WHERE employee_id=l_person_id
	    AND trunc(sysdate) between start_date and nvl(end_date,to_date('4712/12/31', 'YYYY/MM/DD'))       --Bug 5676892
	    AND ROWNUM =1 ;
	    if l_request_rec.object_type <> 'LPCL' then
	    fnd_file.put_line(FND_FILE.LOG,'Requestor Name ' ||l_person_full_name);
	    end if;
	    IF l_person_full_name IS NOT NULL then
	       WF_ENGINE.setitemattrtext(l_item_type,l_item_key,'EVENT_OWNER',l_user_name);
	    END IF;
	END IF;

-- Get and set owner role

    hr_utility.set_location('Before Getting Owner'||l_proc, 10);

    WF_DIRECTORY.GetRoleName(p_orig_system =>'PER',
                      p_orig_system_id => l_person_id,
                      p_name  =>l_role_name,
                      p_display_name  =>l_role_display_name);


    WF_ENGINE.SetItemOwner(itemtype => l_item_type,
                       itemkey =>l_item_key,
                       owner =>l_role_name);

	hr_utility.set_location('After Setting Owner'||l_proc, 10);


	WF_ENGINE.STARTPROCESS(l_item_type,l_item_key);

	hr_utility.set_location('leaving:'||l_proc, 20);

EXCEPTION
WHEN OTHERS THEN
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END notify_requestor;

PROCEDURE mass_subscribe_to_lp(
                 p_enr_request_id IN NUMBER
                ,p_from_conc_program IN boolean default false)
IS

l_request_rec csr_get_request_info%ROWTYPE;
l_req_member_rec csr_get_request_members%ROWTYPE;
l_error_message ota_bulk_enr_req_members.error_message%TYPE;
l_person_name per_all_people_f.full_name%TYPE;
l_lp_enrollment_id ota_lp_enrollments.lp_enrollment_id%TYPE;
l_path_status_code ota_lp_enrollments.path_status_code%TYPE;
l_return_status varchar2(30);


BEGIN
 OPEN csr_get_request_info(p_enr_request_id);
 FETCH csr_get_request_info INTO l_request_rec;
 IF csr_get_request_info%NOTFOUND THEN
   CLOSE csr_get_request_info;
   -- Raise error that no request found
 ELSE
   CLOSE csr_get_request_info;
   FOR l_req_member_rec IN csr_get_request_members(p_enr_request_id) LOOP

     IF l_req_member_rec.enrollment_status IS NULL THEN
     l_lp_enrollment_id := null;
     l_path_status_code := null;
     l_error_message := null;

     begin
     OPEN csr_get_person_name(l_req_member_rec.person_id);
     FETCH csr_get_person_name INTO l_person_name;
     CLOSE csr_get_person_name;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Learner Name - ' || l_person_name);

     -- call subscribe for each learning path
     ota_lp_enrollment_api.subscribe_to_learning_path(
        p_learning_path_id => l_request_rec.object_id
       ,p_person_id        => l_req_member_rec.person_id
       ,p_enrollment_source_code => 'ADMIN'
       ,p_business_group_id => l_request_rec.business_group_id
       ,p_creator_person_id => l_request_rec.requestor_id
       ,p_lp_enrollment_id => l_lp_enrollment_id
       ,p_path_status_code => l_path_status_code);
     EXCEPTION
     when others then

       l_error_message := fnd_message.get;
         fnd_message.clear;
        l_error_message  := nvl(l_error_message,'Error When creating Learning Path subscription ');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR - ' || l_error_message);
        UPDATE ota_bulk_enr_req_members
       SET error_message = l_error_message, enrollment_status = NULL
       WHERE person_id = l_req_member_rec.person_id
       AND bulk_enr_request_id = p_enr_request_id;
     END;

     IF l_lp_enrollment_id IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Subscription Status - '
               || ota_utility.get_lookup_meaning('OTA_LEARNING_PATH_STATUS',l_path_status_code, 810));
       -- update lpe status to bulk_enr_req_members table
       UPDATE ota_bulk_enr_req_members
       SET enrollment_status = l_path_status_code, error_message = NULL
       WHERE person_id = l_req_member_rec.person_id
       AND bulk_enr_request_id = p_enr_request_id;
     END IF;
     END IF;
   END LOOP;
   IF p_from_conc_program THEN
     -- Start workflow and send a notification to the requestor
     notify_requestor(p_enr_request_id => p_enr_request_id);
   END IF;

 END IF;

END mass_subscribe_to_lp;

PROCEDURE mass_subscribe_to_cert(
                 p_enr_request_id IN NUMBER
                ,p_from_conc_program IN boolean default false)
IS

l_request_rec csr_get_request_info%ROWTYPE;
l_req_member_rec csr_get_request_members%ROWTYPE;
l_cert_enrollment_id ota_cert_enrollments.cert_enrollment_id%TYPE;
l_error_message ota_bulk_enr_req_members.error_message%TYPE;
l_person_name per_all_people_f.full_name%TYPE;
l_certification_status_code ota_cert_enrollments.CERTIFICATION_STATUS_CODE%TYPE;


BEGIN
 OPEN csr_get_request_info(p_enr_request_id);
 FETCH csr_get_request_info INTO l_request_rec;
 IF csr_get_request_info%NOTFOUND THEN
   -- Raise error that no request found
   CLOSE csr_get_request_info;
 ELSE
   CLOSE csr_get_request_info;
   FOR l_req_member_rec IN csr_get_request_members(p_enr_request_id) LOOP
IF l_req_member_rec.enrollment_status IS NULL THEN
     l_cert_enrollment_id := null;
     l_certification_status_code := null;
     l_error_message := null;

     begin
     OPEN csr_get_person_name(l_req_member_rec.person_id);
     FETCH csr_get_person_name INTO l_person_name;
     CLOSE csr_get_person_name;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Learner Name - ' || l_person_name);

     -- call subscribe for each learning path
     OTA_CERT_ENROLLMENT_API.subscribe_to_certification(
        p_certification_id => l_request_rec.object_id
       ,p_person_id        => l_req_member_rec.person_id
       ,p_business_group_id => l_request_rec.business_group_id
       ,p_approval_flag => 'N'
       ,p_is_history_flag => 'N'
       ,p_cert_enrollment_id => l_cert_enrollment_id
       ,p_certification_status_code => l_certification_status_code);

     EXCEPTION
     when others then
         l_error_message := fnd_message.get;
         fnd_message.clear;
        l_error_message  := nvl(l_error_message,'Error When creating Certification subscription ');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR - ' || l_error_message);
        UPDATE ota_bulk_enr_req_members
       SET error_message = l_error_message, enrollment_status = NULL
       WHERE person_id = l_req_member_rec.person_id
       AND bulk_enr_request_id = p_enr_request_id;
     END;

     IF l_cert_enrollment_id IS NOT NULL THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Subscription Status - '
               || ota_utility.get_lookup_meaning('OTA_CERT_ENROLL_STATUS',l_certification_status_code, 810));
       -- update lpe status to bulk_enr_req_members table
       UPDATE ota_bulk_enr_req_members
       SET enrollment_status = l_certification_status_code, error_message = NULL
       WHERE person_id = l_req_member_rec.person_id
       AND bulk_enr_request_id = p_enr_request_id;
     END IF;
     END IF;
   END LOOP;
   IF p_from_conc_program THEN
     -- Start workflow and send a notification to the requestor
     notify_requestor(p_enr_request_id => p_enr_request_id);
   END IF;

 END IF;

END mass_subscribe_to_cert;

/*PROCEDURE mass_subscribe_to_class(
                p_enr_request_id IN NUMBER
               ,p_from_conc_program IN boolean default false)
IS

CURSOR csr_get_booking_status_id(l_booking_id NUMBER) IS
SELECT btt.booking_status_type_id , btt.name booking_status
FROM ota_delegate_bookings tdb, ota_booking_status_types_tl btt
WHERE booking_id = l_booking_id
 and tdb.booking_status_type_id = btt.booking_status_type_id
 and btt.language = USERENV('LANG');

CURSOR csr_get_assignment_info(l_assignment_id NUMBER) IS
SELECT paf.organization_id
FROM per_all_assignments_f paf
WHERE paf.assignment_id = l_assignment_id
and trunc(sysdate) between paf.effective_start_date and paf.effective_end_date -- Bug#8357553
and paf.assignment_type in ('E', 'A', 'C');

CURSOR csr_get_cost_center_info(l_assignment_id NUMBER) IS
SELECT pcak.cost_allocation_keyflex_id
FROM per_all_assignments_f assg,
pay_cost_allocations_f pcaf,
pay_cost_allocation_keyflex pcak
WHERE assg.assignment_id = pcaf.assignment_id
AND assg.assignment_id = l_assignment_id
AND assg.Primary_flag = 'Y'
AND pcaf.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id
AND pcak.enabled_flag = 'Y'
AND sysdate between nvl(pcaf.effective_start_date,sysdate)
and nvl(pcaf.effective_end_date,sysdate+1)
AND trunc(sysdate) between nvl(assg.effective_start_date,trunc(sysdate))
and nvl(assg.effective_end_date,trunc(sysdate+1));

l_error_message ota_bulk_enr_req_members.error_message%TYPE;
l_booking_status_type_id ota_booking_status_types.booking_status_type_id%TYPE;
l_booking_status ota_booking_status_types_tl.name%TYPE;

l_request_rec csr_get_request_info%ROWTYPE;
l_req_member_rec csr_get_request_members%ROWTYPE;
l_booking_id ota_delegate_bookings.booking_id%TYPE;

l_assignment_info csr_get_assignment_info%ROWTYPE;
l_cost_center_info csr_get_cost_center_info%ROWTYPE;

l_person_name per_all_people_f.full_name%TYPE;

BEGIN
 OPEN csr_get_request_info(p_enr_request_id);
 FETCH csr_get_request_info INTO l_request_rec;
 IF csr_get_request_info%NOTFOUND THEN
   -- Raise error that no request found
   CLOSE csr_get_request_info;
 ELSE
   CLOSE csr_get_request_info;
   FOR l_req_member_rec IN csr_get_request_members(p_enr_request_id) LOOP
IF l_req_member_rec.enrollment_status IS NULL THEN
      l_booking_id    := null;
      l_error_message := null;

      OPEN csr_get_person_name(l_req_member_rec.person_id);
      FETCH csr_get_person_name INTO l_person_name;
      CLOSE csr_get_person_name;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Learner Name - ' || l_person_name);

      OPEN csr_get_assignment_info(l_req_member_rec.assignment_id);
      FETCH csr_get_assignment_info INTO l_assignment_info;
      CLOSE csr_get_assignment_info;

      OPEN csr_get_cost_center_info(l_req_member_rec.assignment_id);
      FETCH csr_get_cost_center_info INTO l_cost_center_info;
      CLOSE csr_get_cost_center_info;

     BEGIN
 -- Call Process save enrollment
       Create_Enrollment_And_Finance(
             p_event_id => l_request_rec.object_id
            ,p_cost_centers		=> l_cost_center_info.cost_allocation_keyflex_id
            ,p_assignment_id => l_req_member_rec.assignment_id
            ,p_delegate_contact_id => null
            ,p_business_group_id_from => l_request_rec.business_group_id
            ,p_organization_id     => l_assignment_info.organization_id
            ,p_person_id  => l_req_member_rec.person_id
            ,p_booking_id => l_booking_id
            ,p_message_name => l_error_message
            ,p_override_prerequisites => 'Y');
     EXCEPTION
     WHEN OTHERS THEN
        l_error_message  := nvl(substr(SQLERRM,1,2000),'Error When creating Enrollment ');
        UPDATE ota_bulk_enr_req_members
       SET error_message = l_error_message, enrollment_status = NULL
       WHERE person_id = l_req_member_rec.person_id
       AND bulk_enr_request_id = p_enr_request_id;
     END;

     IF l_booking_id IS NOT NULL THEN
       -- update booking status type id to bulk_enr_req_members table
       OPEN csr_get_booking_status_id(l_booking_id);
       FETCH csr_get_booking_status_id INTO l_booking_status_type_id, l_booking_status;
       CLOSE csr_get_booking_status_id;

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Enrollment Status - ' || l_booking_status);

       UPDATE ota_bulk_enr_req_members
       SET enrollment_status = l_booking_status_type_id, error_message = NULL
       WHERE person_id = l_req_member_rec.person_id
	   AND assignment_id = l_req_member_rec.assignment_id
       AND bulk_enr_request_id = p_enr_request_id;
    ELSE
      l_error_message  := nvl(substr(l_error_message,1,2000),'Error When creating Enrollment ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR - ' || l_error_message);
        UPDATE ota_bulk_enr_req_members
       SET error_message = l_error_message, enrollment_status = NULL
       WHERE person_id = l_req_member_rec.person_id
       AND bulk_enr_request_id = p_enr_request_id;
    END IF;
    END IF;
   END LOOP;
   IF p_from_conc_program THEN
     -- Start workflow and send a notification to the requestor
     notify_requestor(p_enr_request_id => p_enr_request_id);
   END IF;
 END IF;
END mass_subscribe_to_class;
*/

/*
Modified mass_subscribe_to class for enhanced lp functionality
We can enroll into classes once lrnr is successfully enrolled into corresponding lp
*/
PROCEDURE mass_subscribe_to_class(
                p_enr_request_id IN NUMBER
               ,p_from_conc_program IN boolean default false)
IS

CURSOR csr_get_booking_status_id(l_booking_id NUMBER) IS
SELECT btt.booking_status_type_id , btt.name booking_status
FROM ota_delegate_bookings tdb, ota_booking_status_types_tl btt
WHERE booking_id = l_booking_id
 and tdb.booking_status_type_id = btt.booking_status_type_id
 and btt.language = USERENV('LANG');

CURSOR csr_get_assignment_info(l_assignment_id NUMBER) IS
SELECT paf.organization_id
FROM per_all_assignments_f paf
WHERE paf.assignment_id = l_assignment_id;

CURSOR csr_get_cost_center_info(l_assignment_id NUMBER) IS
SELECT pcak.cost_allocation_keyflex_id
FROM per_all_assignments_f assg,
pay_cost_allocations_f pcaf,
pay_cost_allocation_keyflex pcak
WHERE assg.assignment_id = pcaf.assignment_id
AND assg.assignment_id = l_assignment_id
AND assg.Primary_flag = 'Y'
AND pcaf.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id
AND pcak.enabled_flag = 'Y'
AND sysdate between nvl(pcaf.effective_start_date,sysdate)
and nvl(pcaf.effective_end_date,sysdate+1)
AND trunc(sysdate) between nvl(assg.effective_start_date,trunc(sysdate))
and nvl(assg.effective_end_date,trunc(sysdate+1));


CURSOR csr_check_lp_enr_exists(l_person_id in NUMBER,l_lp_id in NUMBER) IS
SELECT
lpe.lp_enrollment_id
from
ota_lp_enrollments lpe
where lpe.learning_path_id= l_lp_id
AND lpe.person_id = l_person_id
AND lpe.path_status_code <> 'CANCELLED';

CURSOR csr_lp_created_now(l_person_id in NUMBER,l_lp_id in NUMBER,l_conc_req_id in NUMBER) IS
SELECT
berm.bulk_enr_request_id
from
ota_bulk_enr_requests ber,
ota_bulk_enr_req_members berm
where berm.bulk_enr_request_id = ber.bulk_enr_request_id
AND ber.conc_program_request_id = l_conc_req_id
AND ber.object_id = l_lp_id
AND berm.person_id = l_person_id
AND berm.error_message is NULL;


CURSOR csr_get_lp_member_to_upd(l_person_id in NUMBER,l_lp_id in NUMBER,l_event_id in NUMBER) IS
SELECT
lme.lp_member_enrollment_id
from
ota_lp_enrollments lpe,
ota_lp_member_enrollments lme,
OTA_LEARNING_PATH_MEMBERS lpm,
ota_events evt
where lpe.learning_path_id= l_lp_id
AND lpe.person_id = l_person_id
AND lpe.path_status_code <> 'CANCELLED'
AND lme.lp_enrollment_id= lpe.lp_enrollment_id
AND evt.event_id= l_event_id
and evt.activity_version_id=lpm.activity_version_id
AND lme.learning_path_member_id=lpm.learning_path_member_id
AND lpe.learning_path_id= lpm.learning_path_id;

l_error_message ota_bulk_enr_req_members.error_message%TYPE;
l_booking_status_type_id ota_booking_status_types.booking_status_type_id%TYPE;
l_booking_status ota_booking_status_types_tl.name%TYPE;

l_request_rec csr_get_request_info%ROWTYPE;
l_req_member_rec csr_get_request_members%ROWTYPE;
l_booking_id ota_delegate_bookings.booking_id%TYPE;

l_assignment_info csr_get_assignment_info%ROWTYPE;
l_cost_center_info csr_get_cost_center_info%ROWTYPE;

l_person_name per_all_people_f.full_name%TYPE;

l_subscribed_to_lp boolean;
lp_enr_exists_rec csr_check_lp_enr_exists%ROWTYPE;
l_subscribed_now boolean;
lp_created_in_this_concreq_rec csr_lp_created_now%ROWTYPE;
lp_mem_enr_to_upd_rec   csr_get_lp_member_to_upd%ROWTYPE;

l_parent_object_type  ota_bulk_enr_requests.object_type%TYPE;

l_existing_booking_id ota_delegate_bookings.booking_id%TYPE;
l_lp_name varchar2(80);
l_class_name varchar2(80);
l_override_prerequisites varchar2(1) := 'Y';


BEGIN
 OPEN csr_get_request_info(p_enr_request_id);
 FETCH csr_get_request_info INTO l_request_rec;
 IF csr_get_request_info%NOTFOUND THEN
   -- Raise error that no request found
   CLOSE csr_get_request_info;
 ELSE
   CLOSE csr_get_request_info;
   FOR l_req_member_rec IN csr_get_request_members(p_enr_request_id) LOOP
   l_subscribed_to_lp :=false;
   l_subscribed_now := false;
 IF l_req_member_rec.enrollment_status IS NULL THEN
      l_booking_id    := null;
      l_error_message := null;

      OPEN csr_get_person_name(l_req_member_rec.person_id);
      FETCH csr_get_person_name INTO l_person_name;
      CLOSE csr_get_person_name;
 --     FND_FILE.PUT_LINE(FND_FILE.LOG,'Learner Name - ' || l_person_name);

      OPEN csr_get_assignment_info(l_req_member_rec.assignment_id);
      FETCH csr_get_assignment_info INTO l_assignment_info;
      CLOSE csr_get_assignment_info;

      OPEN csr_get_cost_center_info(l_req_member_rec.assignment_id);
      FETCH csr_get_cost_center_info INTO l_cost_center_info;
      CLOSE csr_get_cost_center_info;

      if(l_request_rec.object_type = 'LPCL') then
       OPEN csr_check_lp_enr_exists(l_req_member_rec.person_id,l_request_rec.parent_object_id);
      FETCH csr_check_lp_enr_exists into lp_enr_exists_rec;
       if  csr_check_lp_enr_exists%FOUND THEN
         --update error message in req members
        l_subscribed_to_lp:=true;
       end if;

        close  csr_check_lp_enr_exists ;

        OPEN csr_lp_created_now(l_req_member_rec.person_id,l_request_rec.parent_object_id,l_request_rec.conc_program_request_id);
      FETCH csr_lp_created_now into lp_created_in_this_concreq_rec;
       if  csr_lp_created_now%FOUND THEN
            l_subscribed_now:=true;
       end if;

       close  csr_lp_created_now ;
      end if;


    if ((l_request_rec.object_type = 'CL') OR (l_request_rec.object_type = 'LPCL' AND l_subscribed_to_lp AND l_subscribed_now)) then
     BEGIN

         if l_request_rec.object_type = 'LPCL' then
         l_parent_object_type:= 'LP';
	 l_override_prerequisites := 'N';
         else
         l_parent_object_type := NULL;
	 l_override_prerequisites := 'Y';
         end if;

          l_existing_booking_id  := ota_tdb_bus.booking_id_for (NULL,
                                 l_assignment_info.organization_id,
                                 l_request_rec.object_id,
                                 l_req_member_rec.person_id);

        if  l_request_rec.object_type = 'LPCL' and l_existing_booking_id  is NOT NULL then
     --check if a booking already exists,if so we need to show a different message

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Learner Name - ' || l_person_name);
     l_class_name := OTA_BULK_ENROLL_UTIL.get_object_name('CL', l_request_rec.object_id);
      l_lp_name := OTA_BULK_ENROLL_UTIL.get_object_name('LP', l_request_rec.parent_object_id);

      fnd_message.set_name ('OTA','OTA_467145_LP_CLASS_ENROLLED');
         fnd_message.set_token('LEARNER_NAME',l_person_name);
          fnd_message.set_token('CLASS_NAME',l_class_name);
          fnd_message.set_token('LP_NAME',l_lp_name);
       l_error_message  :=  fnd_message.get();


     --  l_error_message  := nvl(substr(SQLERRM,1,2000),'Error When creating Enrollment ');
        UPDATE ota_bulk_enr_req_members
       SET error_message = l_error_message, enrollment_status = NULL
       WHERE person_id = l_req_member_rec.person_id
       AND bulk_enr_request_id = p_enr_request_id;

        FOR lp_mem_enr_to_upd_rec IN  csr_get_lp_member_to_upd(l_req_member_rec.person_id, l_request_rec.parent_object_id,l_request_rec.object_id) loop

           UPDATE ota_lp_member_enrollments
           SET event_id= l_request_rec.object_id
           where lp_member_enrollment_id = lp_mem_enr_to_upd_rec.lp_member_enrollment_id;

        end loop;


       else
 -- Call Process save enrollment
 --Need to modify this process to update event_id in lp_member_enrollments for an lp_member_enrollment based on personid,activity_version_id and lp_id
 --Write another program which perumal will call for lp and class is called
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Learner Name - ' || l_person_name);
       Create_Enrollment_And_Finance(
             p_event_id => l_request_rec.object_id
            ,p_cost_centers		=> l_cost_center_info.cost_allocation_keyflex_id
            ,p_assignment_id => l_req_member_rec.assignment_id
            ,p_delegate_contact_id => null
            ,p_business_group_id_from => l_request_rec.business_group_id
            ,p_organization_id     => l_assignment_info.organization_id
            ,p_person_id  => l_req_member_rec.person_id
            ,p_booking_id => l_booking_id
            ,p_message_name => l_error_message
            ,p_override_prerequisites => l_override_prerequisites);
          --  ,p_parent_object_type => l_parent_object_type
          --  ,p_parent_object_id => l_request_rec.parent_object_id);

          end if;--l_request_rec.object_type = 'LPCL' and l_existing_booking_id  is NOT NULL then
     EXCEPTION
     WHEN OTHERS THEN
        l_error_message  := nvl(substr(SQLERRM,1,2000),'Error When creating Enrollment ');
        UPDATE ota_bulk_enr_req_members
       SET error_message = l_error_message, enrollment_status = NULL
       WHERE person_id = l_req_member_rec.person_id
       AND bulk_enr_request_id = p_enr_request_id;
     END;

     IF l_booking_id IS NOT NULL THEN
       -- update booking status type id to bulk_enr_req_members table
       OPEN csr_get_booking_status_id(l_booking_id);
       FETCH csr_get_booking_status_id INTO l_booking_status_type_id, l_booking_status;
       CLOSE csr_get_booking_status_id;

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Enrollment Status - ' || l_booking_status);

       UPDATE ota_bulk_enr_req_members
       SET enrollment_status = l_booking_status_type_id, error_message = NULL
       WHERE person_id = l_req_member_rec.person_id
	   AND assignment_id = l_req_member_rec.assignment_id
       AND bulk_enr_request_id = p_enr_request_id;


        FOR lp_mem_enr_to_upd_rec IN  csr_get_lp_member_to_upd(l_req_member_rec.person_id, l_request_rec.parent_object_id,l_request_rec.object_id) loop
              UPDATE ota_lp_member_enrollments
           SET event_id= l_request_rec.object_id
           where lp_member_enrollment_id = lp_mem_enr_to_upd_rec.lp_member_enrollment_id;

        end loop;

    ELSE
      l_error_message  := nvl(substr(l_error_message,1,2000),'Error When creating Enrollment ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR - ' || l_error_message);
        UPDATE ota_bulk_enr_req_members
       SET error_message = l_error_message, enrollment_status = NULL
       WHERE person_id = l_req_member_rec.person_id
       AND bulk_enr_request_id = p_enr_request_id;
    END IF;

    END IF;--l_request_rec.object_type = 'CL') OR (l_request_rec.object_type = 'LPCL' AND l_subscribed_to_lp

    END IF;--l_req_member_rec.enrollment_status

   END LOOP;

   IF p_from_conc_program THEN
     -- Start workflow and send a notification to the requestor
     notify_requestor(p_enr_request_id => p_enr_request_id);
   END IF;
 END IF;
END mass_subscribe_to_class;

/*
Modified  submit_bulk_enrollmentsfor enhanced lp functionality
Request tables will be populated with 1 record for LP(object_type=LP) and 'n' records for classes(object_type=LPCL)
*/

PROCEDURE submit_bulk_enrollments(
         p_enr_request_id IN NUMBER
         ,p_enr_request_id_end IN NUMBER DEFAULT NULL
        ,p_conc_request_id OUT NOCOPY NUMBER
        ,p_object_type OUT NOCOPY VARCHAR2
        ,p_object_name OUT NOCOPY VARCHAR2)
IS
l_threshold number;
l_learners_selected NUMBER := 0;
l_request_rec csr_get_request_info%ROWTYPE;

BEGIN

  OPEN csr_get_request_info(p_enr_request_id);
  FETCH csr_get_request_info INTO l_request_rec;
  CLOSE csr_get_request_info;

--This is bulk enroll to class/lp/cert
 if(p_enr_request_id_end IS NULL and p_enr_request_id IS NOT NULL) then

  l_threshold := FND_PROFILE.VALUE('OTA_MAX_ENR_PRC_ONLINE');

  IF l_threshold IS NULL THEN l_threshold := 0; END IF;
  SELECT count(person_id)
  INTO l_learners_selected
  FROM ota_bulk_enr_req_members
  WHERE bulk_enr_request_id = p_enr_request_id;

  IF l_threshold >= l_learners_selected THEN
     -- No concurrent processing required
     p_conc_request_id := -1;

     IF l_request_rec.object_type = 'CL' THEN
       mass_subscribe_to_class(
          p_enr_request_id => p_enr_request_id
         ,p_from_conc_program => false);
     ELSIF l_request_rec.object_type = 'LP' THEN
       mass_subscribe_to_lp(
          p_enr_request_id => p_enr_request_id
         ,p_from_conc_program => false);
     ELSIF l_request_rec.object_type = 'CRT' THEN
       mass_subscribe_to_cert(
          p_enr_request_id => p_enr_request_id
         ,p_from_conc_program => false);
     END IF;

  ELSE
   -- Concurrent processing needs to be done
    p_conc_request_id := FND_REQUEST.SUBMIT_REQUEST(
                            application => 'OTA'
                          , program     => 'OTBLKENR'
                          , argument1   => p_enr_request_id
                          , argument2   => NULL);
    IF p_conc_request_id = 0 THEN
      -- Raise error submitting concurrent program
      null;
    END IF;
  END IF;
  UPDATE ota_bulk_enr_requests ber
  SET CONC_PROGRAM_REQUEST_ID = p_conc_request_id
  WHERE bulk_enr_request_id = p_enr_request_id;

  p_object_type := ota_utility.get_lookup_meaning(
               'OTA_OBJECT_TYPE'
              ,l_request_rec.object_type
              ,810);
  p_object_name := get_object_name(l_request_rec.object_type, l_request_rec.object_id );

elsif (p_enr_request_id_end IS NOT NULL) then
--This is mass subscribe to lp and class
--launch a single conc program which iterates through request ids and perform
--mass subscribe to lp and class

 p_conc_request_id := FND_REQUEST.SUBMIT_REQUEST(
                            application => 'OTA'
                          , program     => 'OTBLKENR'
                          , argument1   => p_enr_request_id
                          , argument2   => p_enr_request_id_end);

  UPDATE ota_bulk_enr_requests ber
  SET CONC_PROGRAM_REQUEST_ID = p_conc_request_id
  WHERE bulk_enr_request_id between p_enr_request_id and p_enr_request_id_end;

  p_object_type := ota_utility.get_lookup_meaning(
               'OTA_OBJECT_TYPE'
              ,l_request_rec.object_type
              ,810);
  p_object_name := get_object_name(l_request_rec.object_type, l_request_rec.object_id );





end if;

END submit_bulk_enrollments;


/*
Modified  submit_bulk_enrollmentsfor enhanced lp functionality
Request tables will be populated with 1 record for LP(object_type=LP) and 'n' records for classes(object_type=LPCL)
*/


Procedure process_bulk_enrollments
(ERRBUF OUT NOCOPY  VARCHAR2,
 RETCODE OUT NOCOPY VARCHAR2
,p_enr_request_id IN NUMBER
,p_enr_request_id_end IN NUMBER DEFAULT NULL) as

l_completed    boolean;
l_enr_request_id number;

failure     exception;
l_proc      varchar2(72) := g_package||' bulk_enroll';

l_object_name varchar2(80);

l_request_rec csr_get_request_info%ROWTYPE;
a_request_rec csr_get_all_requests%ROWTYPE;

current_request_id NUMBER;




BEGIN

--This is bulk enroll to class/lp/cert
if(p_enr_request_id_end IS NULL and p_enr_request_id IS NOT NULL) then

  OPEN csr_get_request_info(p_enr_request_id);
  FETCH csr_get_request_info INTO l_request_rec;
  l_object_name := OTA_BULK_ENROLL_UTIL.get_object_name(l_request_rec.object_type, l_request_rec.object_id);

  IF csr_get_request_info%NOTFOUND THEN
    CLOSE csr_get_request_info;
    --fnd_concurrent.set_completion_status('ERROR');
  ELSIF l_request_rec.object_type = 'LP' THEN
    CLOSE csr_get_request_info;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Executing Bulk Enrollment for the Learning Path - ' || l_object_name);

    mass_subscribe_to_lp(
         p_enr_request_id => p_enr_request_id
        ,p_from_conc_program => true);

  ELSIF l_request_rec.object_type = 'CL' THEN
    CLOSE csr_get_request_info;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Executing Bulk Enrollment for the Class - ' || l_object_name);
    mass_subscribe_to_class(
          p_enr_request_id => p_enr_request_id
         ,p_from_conc_program => true);

  ELSIF l_request_rec.object_type = 'CRT' THEN
    CLOSE csr_get_request_info;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Executing Bulk Enrollment for the Certification - ' || l_object_name);
    mass_subscribe_to_cert(
          p_enr_request_id => p_enr_request_id
         ,p_from_conc_program => true);
  ELSE
    CLOSE csr_get_request_info;
    --fnd_concurrent.set_completion_status('ERROR');
    -- Raise error for unknown object type
  END IF;

  commit;

/*moved for lp enh changes
   EXCEPTION
     when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc
      ||','||SUBSTR(SQLERRM, 1, 500));*/


elsif (p_enr_request_id_end IS NOT NULL) then
--This is mass subscribe to lp and class
--iterate through the request and call mass subscribe to lp and mass_subscribe_to_class(n times)

 FOR a_request_rec in csr_get_all_requests(p_enr_request_id ,p_enr_request_id_end) loop
 current_request_id := a_request_rec.bulk_enr_request_id;
 OPEN csr_get_request_info(current_request_id);
  FETCH csr_get_request_info INTO l_request_rec;


  IF csr_get_request_info%NOTFOUND THEN
    CLOSE csr_get_request_info;
    --fnd_concurrent.set_completion_status('ERROR');
  ELSIF l_request_rec.object_type = 'LP' THEN
    CLOSE csr_get_request_info;
    l_object_name := OTA_BULK_ENROLL_UTIL.get_object_name(l_request_rec.object_type, l_request_rec.object_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Enrollments for the Learning Path - ' || l_object_name);

    mass_subscribe_to_lp(
         p_enr_request_id => current_request_id
        ,p_from_conc_program => true);

    COMMIT;

  ELSIF l_request_rec.object_type = 'LPCL' THEN
    CLOSE csr_get_request_info;
  l_object_name := OTA_BULK_ENROLL_UTIL.get_object_name(l_request_rec.object_type, l_request_rec.object_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Enrollments for the Class - ' || l_object_name);
    mass_subscribe_to_class(
          p_enr_request_id => current_request_id
         ,p_from_conc_program => true);


   COMMIT;

  END IF;

  end loop;





end if;

EXCEPTION
     when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc
      ||','||SUBSTR(SQLERRM, 1, 500));

END process_bulk_enrollments;



end ota_bulk_enroll_util;

/
