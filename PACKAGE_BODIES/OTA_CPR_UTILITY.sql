--------------------------------------------------------
--  DDL for Package Body OTA_CPR_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CPR_UTILITY" as
/* $Header: otcprutl.pkb 120.8 2005/12/27 01:20 rdola noship $ */

g_package  varchar2(33)	:= '  ota_cpr_utility.';  -- Global package name

FUNCTION is_competency_acheived
  (p_person_id in per_all_people_f.person_id%type,
   p_comp_id in per_competence_elements.competence_id%type,
   p_level_id in per_competence_elements.proficiency_level_id%type
) RETURN varchar2 is

Cursor CompRecordWithLevel is
 Select nvl(pce.proficiency_level_id, -100)
 from per_competence_elements pce, per_rating_levels prl
 where pce.competence_id = p_comp_id
 and pce.person_id = p_person_id
 and prl.rating_level_id(+) = pce.proficiency_level_id
 and prl.step_value >= (select step_value from per_rating_levels where rating_level_id = p_level_id)
 and (trunc(sysdate) between nvl(pce.effective_date_from, trunc(sysdate)) and nvl(pce.effective_date_to, trunc(sysdate)));

Cursor CompRecordWithNullLevel is
 Select nvl(pce.proficiency_level_id, -100)
 from per_competence_elements pce
 where pce.competence_id = p_comp_id
 and pce.person_id = p_person_id
 and (trunc(sysdate) between nvl(pce.effective_date_from, trunc(sysdate)) and nvl(pce.effective_date_to, trunc(sysdate)))
 and pce.proficiency_level_id is null;

Cursor CompRecordWithoutLevel is
 Select nvl(pce.proficiency_level_id, -100)
 from per_competence_elements pce
 where pce.competence_id = p_comp_id
 and pce.person_id = p_person_id
 and (trunc(sysdate) between nvl(pce.effective_date_from, trunc(sysdate)) and nvl(pce.effective_date_to, trunc(sysdate)));

 l_level_id per_competence_elements.proficiency_level_id%type;

Begin
	--Note: l_level_id = -100 means Data found but level is null

	If p_level_id is null Then -- Any record found will be considered as acheiving the competency
		OPEN CompRecordWithoutLevel;
		FETCH CompRecordWithoutLevel INTO l_level_id;

		If CompRecordWithoutLevel%NOTFOUND then --implies competence not found
		    l_level_id := -1;
		End If;
	        CLOSE CompRecordWithoutLevel;
	Else
		OPEN CompRecordWithNullLevel;
		FETCH CompRecordWithNullLevel INTO l_level_id;

		If CompRecordWithNullLevel%NOTFOUND then --implies competence with null level not found
		    l_level_id := -1;
		End If;
	        CLOSE CompRecordWithNullLevel;

		If (l_level_id = -1) Then
			OPEN CompRecordWithLevel;
			FETCH CompRecordWithLevel INTO l_level_id;

			If CompRecordWithLevel%NOTFOUND then --implies competence not found
			    l_level_id := -1;
			End If;
			CLOSE CompRecordWithLevel;
		End If;
	End If;

        If (l_level_id = -1) Then
		RETURN 'N';
	Else
		RETURN 'Y';
	End If;
End is_competency_acheived;


FUNCTION check_learner_comp_step_values
  (p_act_ver_id in ota_activity_versions.activity_version_id%type,
   p_comp_id in per_competence_elements.competence_id%type,
   p_level_id in per_competence_elements.proficiency_level_id%type
) RETURN varchar2 is

Cursor GetLrnCompMaxStepValue is
SELECT
  Decode(PRL.STEP_VALUE, null, -1, PRL.STEP_VALUE),
  PCE.COMPETENCE_ELEMENT_ID
FROM
  PER_RATING_LEVELS PRL,
  PER_COMPETENCE_ELEMENTS PCE
WHERE
  PCE.PROFICIENCY_LEVEL_ID = PRL.RATING_LEVEL_ID (+)
  and (trunc(sysdate) between nvl(pce.effective_date_from, trunc(sysdate)) and nvl(pce.effective_date_to, trunc(sysdate)))
  AND PCE.type = 'DELIVERY'
  AND PCE.ACTIVITY_VERSION_ID = p_act_ver_id
  AND PCE.COMPETENCE_ID = p_comp_id
ORDER BY PRL.STEP_VALUE DESC;

Cursor GetPrereqCompStepValue is
SELECT
  PRL.STEP_VALUE
FROM
  PER_RATING_LEVELS PRL
WHERE
  PRL.RATING_LEVEL_ID = p_level_id;

Cursor GetCompHighesteStepValue IS
/* Modified for bug#4905777
SELECT MAX(STEP_VALUE)
FROM per_competence_levels_v
WHERE COMPETENCE_ID = p_comp_id;
*/
 select MAX(step_value)
 from
   per_rating_levels prl
  ,per_competences pce
where (prl.rating_scale_id = pce.rating_scale_id
     OR pce.competence_id = prl.competence_id)
     AND pce.competence_id = p_comp_id;

Cursor GetCompLowestStepValue IS
/* Modified for bug#4905777
SELECT MIN(STEP_VALUE)
FROM per_competence_levels_v
WHERE COMPETENCE_ID = p_comp_id;
*/
 select MIN(step_value)
 from
   per_rating_levels prl
  ,per_competences pce
where (prl.rating_scale_id = pce.rating_scale_id
     OR pce.competence_id = prl.competence_id)
     AND pce.competence_id = p_comp_id;


l_lrn_comp_el_id per_competence_elements.competence_element_id%type;
l_lrn_step_value per_rating_levels.step_value%type;

l_prereq_step_value per_rating_levels.step_value%type;
l_comp_max_step_value per_rating_levels.step_value%type;
l_comp_min_step_value per_rating_levels.step_value%type;
l_return_status varchar2(1);

Begin
	l_return_status := 'S'; -- Prereq comp(PC) can be specified

	OPEN GetLrnCompMaxStepValue;
	FETCH GetLrnCompMaxStepValue INTO l_lrn_step_value, l_lrn_comp_el_id;

	If ( p_level_id is not null ) Then
		OPEN GetPrereqCompStepValue;
		FETCH GetPrereqCompStepValue INTO l_prereq_step_value;
		CLOSE GetPrereqCompStepValue;
	End If;

	If GetLrnCompMaxStepValue%NOTFOUND then --implies no learner competency(LC) at any level found
		CLOSE GetLrnCompMaxStepValue;
		l_return_status := 'S'; -- Success -> Prereq comp can be specified
		RETURN l_return_status;
	Else
		If ( ( l_lrn_step_value = -1 ) and ( p_level_id is null ) ) Then
			l_return_status := 'E'; -- Error -> Prereq comp cannot be specified since PC >= LC
			RETURN l_return_status;
		ElsIf ( ( l_lrn_step_value = -1 ) and ( p_level_id is not null ) ) Then
			OPEN GetCompHighesteStepValue;
			FETCH GetCompHighesteStepValue INTO l_comp_max_step_value;
			CLOSE GetCompHighesteStepValue;

			If ( l_prereq_step_value = l_comp_max_step_value ) Then
				l_return_status := 'E'; -- Error -> Prereq comp cannot be specified since PC >= LC
							-- Here null LC is assumed as HIGHEST level
			Else
				l_return_status := 'S'; -- Success -> Prereq comp can be specified
			End If;

			RETURN l_return_status;
		ElsIf ( ( l_lrn_step_value <> -1 ) and ( p_level_id is null ) ) Then
			OPEN GetCompLowestStepValue;
			FETCH GetCompLowestStepValue INTO l_comp_min_step_value;
			CLOSE GetCompLowestStepValue;

			If ( l_lrn_step_value = l_comp_min_step_value ) Then
				l_return_status := 'E'; -- Error -> Prereq comp cannot be specified since PC >= LC
							-- Here null prereq comp level is assumed as LOWEST level
			Else
				l_return_status := 'S'; -- Success -> Prereq comp can be specified
			End If;

			RETURN l_return_status;
		ElsIf ( ( l_lrn_step_value <> -1 ) and ( p_level_id is not null ) ) Then
			-- Prerequisite competency level cannot be same or greater than learner competency level
			If ( l_prereq_step_value >= l_lrn_step_value ) Then
				l_return_status := 'E'; -- Error -> Prereq comp cannot be specified since PC >= LC
			Else
				l_return_status := 'S'; -- Success -> Prereq comp can be specified
			End If;
		End If;
	End If;

	CLOSE GetLrnCompMaxStepValue;
	RETURN l_return_status;
End check_learner_comp_step_values;


FUNCTION is_course_completed
	(p_person_id in per_all_people_f.person_id%type,
	 p_delegate_contact_id in NUMBER,
	 p_user_id in NUMBER,
	 p_user_type in ota_attempts.user_type%type,
	 p_act_ver_id in ota_activity_versions.activity_version_id%type
) RETURN varchar2 is

Cursor c_get_classes is
SELECT
	oev.event_id,
	OCU.online_flag,
	OFR.learning_object_id
FROM
	ota_activity_versions OAV,
	ota_offerings OFR,
	ota_events OEV,
	ota_category_usages OCU
WHERE
	OFR.activity_version_id = OAV.activity_version_id
	And OEV.parent_offering_id = OFR.offering_id
	And OFR.delivery_mode_id = OCU.category_usage_id
	And OCU.type ='DM'
	And (OEV.event_type = 'SCHEDULED' or OEV.event_type = 'SELFPACED')
	And OEV.event_status <> 'A'
	And OAV.activity_version_id = p_act_ver_id;

CURSOR c_learning_object_status(p_lo_id in ota_offerings.learning_object_id%TYPE) is
SELECT lesson_status
FROM ota_performances
WHERE
	user_id = p_user_id
	AND user_type = p_user_type
	AND learning_object_id = p_lo_id;

l_enrollment_status varchar2(1);
l_completed_status varchar2(1);
l_lo_status ota_performances.lesson_status%type;

Begin
	l_completed_status := 'N';
	For a_event_rec In c_get_classes() Loop
		If a_event_rec.online_flag = 'Y' Then -- Online class
			Open c_learning_object_status(a_event_rec.learning_object_id);
			Fetch c_learning_object_status into l_lo_status;

			If c_learning_object_status%FOUND Then
				If ( l_lo_status = 'C' or l_lo_status = 'P' ) Then
					l_completed_status := 'Y';
					Close c_learning_object_status;
					RETURN l_completed_status;
				End If;
			End If;
			Close c_learning_object_status;
		Else -- Offline class
			l_enrollment_status := ota_utility.get_enrollment_status(p_person_id, p_delegate_contact_id, a_event_rec.event_id, 1);
			If ( l_enrollment_status = 'A' ) Then
				l_completed_status := 'Y';
				RETURN l_completed_status;
			End If;
		End If;
	End Loop;
	RETURN l_completed_status;
End is_course_completed;

FUNCTION is_mandatory_prereqs_completed
	(p_person_id in per_all_people_f.person_id%type,
	 p_delegate_contact_id in NUMBER,
	 p_user_id in NUMBER,
	 p_user_type in ota_attempts.user_type%type,
	 p_act_ver_id in ota_activity_versions.activity_version_id%type
) RETURN varchar2 is

Cursor c_get_mandatory_courses( p_enforcement_mode in ota_course_prerequisites.enforcement_mode%TYPE) is
SELECT cpr.prerequisite_course_id
FROM ota_course_prerequisites cpr
WHERE cpr.activity_version_id = p_act_ver_id
	and cpr.prerequisite_type = 'M'
	and cpr.enforcement_mode in ('B', p_enforcement_mode);

Cursor c_get_mandatory_competencies is
SELECT cpe.competence_id,
      cpe.proficiency_level_id
FROM per_competence_elements cpe
WHERE cpe.object_id = p_act_ver_id
	and cpe.mandatory = 'Y'
	and cpe.type = 'OTA_COMP_PREREQ';

l_completed_status varchar2(1);
l_enforcement_mode ota_course_prerequisites.enforcement_mode%TYPE;
Begin
	l_completed_status := 'Y';
	If ( p_user_type = 'C') Then  --Customer
		l_enforcement_mode := 'E'; --External
	Else -- Employee
		l_enforcement_mode := 'I'; --Internal
	End If;

	--Check the completion of mandatory courses
	For a_prereq_crs_rec In c_get_mandatory_courses(l_enforcement_mode) Loop
		l_completed_status := is_course_completed(p_person_id, p_delegate_contact_id,
					p_user_id, p_user_type, a_prereq_crs_rec.prerequisite_course_id);
		If ( l_completed_status = 'N' ) Then
			l_completed_status := 'N';
			RETURN l_completed_status;
		End If;
	End Loop;

	If ( p_user_type = 'E') Then --Employee
		--Check the completion of mandatory competencies
		For a_prereq_comp_rec In c_get_mandatory_competencies Loop
			l_completed_status := is_competency_acheived(p_person_id, a_prereq_comp_rec.competence_id,
						a_prereq_comp_rec.proficiency_level_id);
			If ( l_completed_status = 'N' ) Then
				l_completed_status := 'N';
				RETURN l_completed_status;
			End If;
		End Loop;
	End If;
	RETURN l_completed_status;
End is_mandatory_prereqs_completed;

FUNCTION is_advisory_prereqs_completed
	(p_person_id in per_all_people_f.person_id%type,
	 p_delegate_contact_id in NUMBER,
	 p_user_id in NUMBER,
	 p_user_type in ota_attempts.user_type%type,
	 p_act_ver_id in ota_activity_versions.activity_version_id%type
) RETURN varchar2 is

Cursor c_get_advisory_courses( p_enforcement_mode in ota_course_prerequisites.enforcement_mode%TYPE) is
SELECT cpr.prerequisite_course_id
FROM ota_course_prerequisites cpr
WHERE cpr.activity_version_id = p_act_ver_id
	and cpr.prerequisite_type = 'A'
	and cpr.enforcement_mode in ('B', p_enforcement_mode);

Cursor c_get_advisory_competencies is
SELECT cpe.competence_id,
      cpe.proficiency_level_id
FROM per_competence_elements cpe
WHERE cpe.object_id = p_act_ver_id
	and ( cpe.mandatory = 'N' or cpe.mandatory is null )
	and cpe.type = 'OTA_COMP_PREREQ';

l_completed_status varchar2(1);
l_enforcement_mode ota_course_prerequisites.enforcement_mode%TYPE;
Begin
	l_completed_status := 'Y';
	If ( p_user_type = 'C') Then  --Customer
		l_enforcement_mode := 'E'; --External
	Else -- Employee
		l_enforcement_mode := 'I'; --Internal
	End If;

	--Check the completion of advisory courses
	For a_prereq_crs_rec In c_get_advisory_courses(l_enforcement_mode) Loop
		l_completed_status := is_course_completed(p_person_id, p_delegate_contact_id,
					p_user_id, p_user_type, a_prereq_crs_rec.prerequisite_course_id);
		If ( l_completed_status = 'N' ) Then
			l_completed_status := 'N';
			RETURN l_completed_status;
		End If;
	End Loop;

	If ( p_user_type = 'E') Then --Employee
		--Check the completion of advisory competencies
		For a_prereq_comp_rec In c_get_advisory_competencies Loop
			l_completed_status := is_competency_acheived(p_person_id, a_prereq_comp_rec.competence_id,
						a_prereq_comp_rec.proficiency_level_id);
			If ( l_completed_status = 'N' ) Then
				l_completed_status := 'N';
				RETURN l_completed_status;
			End If;
		End Loop;
	End If;
	RETURN l_completed_status;
End is_advisory_prereqs_completed;

FUNCTION get_enroll_image
	(p_person_id in per_all_people_f.person_id%type,
	 p_delegate_contact_id in NUMBER,
	 p_user_id in NUMBER,
	 p_user_type in ota_attempts.user_type%type,
	 p_event_id in ota_events.event_id%type
) RETURN varchar2 is

Cursor c_get_act_ver_id is
SELECT  activity_version_id
FROM 	ota_events
WHERE	event_id = p_event_id;

l_enroll_image varchar2(20);
l_enrollment_status varchar2(1);
l_prereq_completed_status varchar2(1);
l_act_ver_id ota_activity_versions.activity_version_id%type;
Begin
	l_enrollment_status := ota_utility.get_enrollment_status(p_person_id, p_delegate_contact_id, p_event_id, 1);
	If ( l_enrollment_status = 'P' or l_enrollment_status = 'W' or l_enrollment_status = 'R' or l_enrollment_status = 'A') Then --Bug 4518920
		l_enroll_image := 'AE'; -- Already enrolled
		RETURN l_enroll_image;
	End If;

	Open c_get_act_ver_id;
	Fetch c_get_act_ver_id into l_act_ver_id;
	Close c_get_act_ver_id;

	l_prereq_completed_status := is_mandatory_prereqs_completed(p_person_id, p_delegate_contact_id,
					p_user_id, p_user_type, l_act_ver_id);

	If ( l_prereq_completed_status = 'Y' ) Then
		l_enroll_image := 'EA'; --Enrollment allowed
	Else
		l_enroll_image := 'MPNC'; --Mandatory prerequisites not completed
	End If;
	RETURN l_enroll_image;
End get_enroll_image;


Procedure chk_mandatory_prereqs
         (p_person_id ota_delegate_bookings.delegate_person_id%TYPE,
	  p_delegate_contact_id ota_delegate_bookings.delegate_contact_id%TYPE,
	  p_event_id ota_events.event_id%TYPE
  ) IS

Cursor c_get_act_ver_id is
SELECT  ofr.activity_version_id
FROM 	ota_events evt, ota_offerings ofr
WHERE	evt.event_id = p_event_id
	and evt.parent_offering_id = ofr.offering_id;

Cursor get_ext_lrn_party_id is
select party.party_id
from  HZ_CUST_ACCOUNT_ROLES acct_role,
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

  l_ext_lrn_party_id HZ_PARTIES.Party_Id%TYPE;
  l_user_id number;
  l_user_type ota_attempts.user_type%type;
  l_act_ver_id ota_activity_versions.activity_version_id%type;
  l_prereq_completed_status varchar2(1);

Begin
	If ( p_delegate_contact_id is not null ) Then
		Open get_ext_lrn_party_id;
		Fetch get_ext_lrn_party_id into l_ext_lrn_party_id;
		Close get_ext_lrn_party_id;

		l_user_id := l_ext_lrn_party_id;
		l_user_type := 'C'; --Customer
	Else
		l_user_id := p_person_id;
		l_user_type := 'E'; --Employee
	End If;

	Open c_get_act_ver_id;
	Fetch c_get_act_ver_id into l_act_ver_id;
	Close c_get_act_ver_id;

	l_prereq_completed_status := is_mandatory_prereqs_completed(p_person_id, p_delegate_contact_id, l_user_id, l_user_type, l_act_ver_id);
	If ( l_prereq_completed_status = 'N' ) Then
		fnd_message.set_name ('OTA', 'OTA_443729_PREREQ_NOT_COMPLETE');
		fnd_message.raise_error;
	End If;
End chk_mandatory_prereqs;

FUNCTION is_mand_crs_prereqs_completed
	(p_person_id in per_all_people_f.person_id%type,
	 p_delegate_contact_id in NUMBER,
	 p_user_id in NUMBER,
	 p_user_type in ota_attempts.user_type%type,
	 p_act_ver_id in ota_activity_versions.activity_version_id%type
) RETURN varchar2
IS

Cursor c_get_mandatory_courses( p_enforcement_mode in ota_course_prerequisites.enforcement_mode%TYPE) is
SELECT cpr.prerequisite_course_id
FROM ota_course_prerequisites cpr
WHERE cpr.activity_version_id = p_act_ver_id
	and cpr.prerequisite_type = 'M'
	and cpr.enforcement_mode in ('B', p_enforcement_mode);

l_completed_status varchar2(1):= 'Y';
l_enforcement_mode ota_course_prerequisites.enforcement_mode%TYPE;
BEGIN
	If ( p_user_type = 'C') Then  --Customer
		l_enforcement_mode := 'E'; --External
	Else -- Employee
		l_enforcement_mode := 'I'; --Internal
	End If;

	--Check the completion of mandatory courses
	For a_prereq_crs_rec In c_get_mandatory_courses(l_enforcement_mode) Loop
		l_completed_status := is_course_completed(p_person_id, p_delegate_contact_id,
					p_user_id, p_user_type, a_prereq_crs_rec.prerequisite_course_id);
		If ( l_completed_status = 'N' ) Then
			l_completed_status := 'N';
			RETURN l_completed_status;
		End If;
	End Loop;
    RETURN l_completed_status;
END is_mand_crs_prereqs_completed;

FUNCTION is_mand_comp_prereqs_completed
	(p_person_id in per_all_people_f.person_id%type,
	 p_act_ver_id in ota_activity_versions.activity_version_id%type
) RETURN varchar2
IS
Cursor c_get_mandatory_competencies is
SELECT cpe.competence_id,
      cpe.proficiency_level_id
FROM per_competence_elements cpe
WHERE cpe.object_id = p_act_ver_id
	and cpe.mandatory = 'Y'
	and cpe.type = 'OTA_COMP_PREREQ';

l_completed_status varchar2(1):= 'Y';
BEGIN
    --Check the completion of mandatory competencies
	For a_prereq_comp_rec In c_get_mandatory_competencies Loop
		l_completed_status := is_competency_acheived(p_person_id, a_prereq_comp_rec.competence_id,
					a_prereq_comp_rec.proficiency_level_id);
		If ( l_completed_status = 'N' ) Then
			l_completed_status := 'N';
		    RETURN l_completed_status;
		End If;
	End Loop;
	RETURN l_completed_status;
END is_mand_comp_prereqs_completed;

Function Get_course_prereq_count
 (p_prereq_met varchar2
 ,p_event_id in ota_events.event_id%type
 ,p_prerequisite_course_id ota_activity_versions.activity_version_id%type
) Return varchar2 is
--
--
Cursor c_course_prereq_status is
select
  ota_cpr_utility.is_course_completed
    (odb.delegate_person_id
    ,odb.delegate_contact_id
    ,nvl(odb.delegate_person_id,odb.delegate_contact_id)
    ,decode(odb.delegate_person_id,null,'C', 'E')
    ,p_prerequisite_course_id
  ) prereq_met
from
  ota_delegate_bookings odb,
  ota_booking_status_types bst,
  ota_events evb
where
  odb.booking_status_type_id = bst.booking_status_type_id
  and evb.event_id = odb.event_id
  and evb.event_id = p_event_id;
--
l_prereq_count Number := 0;
--
Begin
  --
  For prereq_status in c_course_prereq_status Loop
    --
    If prereq_status.prereq_met = p_prereq_met Then
      --
        l_prereq_count := l_prereq_count + 1;
      --
    End If;
  End Loop;
  --
  return to_char(l_prereq_count);
  --
End Get_course_prereq_count;

Function Get_comp_prereq_count
 (p_prereq_met varchar2
 ,p_event_id in ota_events.event_id%type
 ,p_comp_id in per_competence_elements.competence_id%type
 ,p_level_id in per_competence_elements.proficiency_level_id%type
) Return varchar2 is
--
--
Cursor c_comp_prereq_status is
select
  ota_cpr_utility.is_competency_acheived
    (odb.delegate_person_id
    ,p_comp_id
    ,p_level_id
  ) prereq_met
from
  ota_delegate_bookings odb,
  ota_events evb
where
  evb.event_id = odb.event_id
  and evb.event_id = p_event_id;
--
l_prereq_count Number := 0;
--
Begin
  --
  For prereq_status in c_comp_prereq_status Loop
    --
    If prereq_status.prereq_met = p_prereq_met Then
      --
        l_prereq_count := l_prereq_count + 1;
      --
    End If;
  End Loop;
  --
  return to_char(l_prereq_count);
  --
End Get_comp_prereq_count;

FUNCTION get_prereq_met_count
	(p_event_id in ota_events.event_id%type,
	 p_prerequisite_course_id ota_activity_versions.activity_version_id%type,
     p_comp_id in per_competence_elements.competence_id%type,
     p_level_id in per_competence_elements.proficiency_level_id%type
) RETURN varchar2 is
--
l_met_count Varchar2(15) := '0';
--
Begin
  --
  If p_prerequisite_course_id is not null then
    --
    l_met_count := Get_course_prereq_count
                     (p_prereq_met              =>  'Y'
                     ,p_event_id                =>   p_event_id
                     ,p_prerequisite_course_id  =>   p_prerequisite_course_id
                     );
    --
  Else
    --
    l_met_count := Get_comp_prereq_count
                     (p_prereq_met           =>     'Y'
                     ,p_event_id             =>     p_event_id
                     ,p_comp_id              =>     p_comp_id
                     ,p_level_id             =>     p_level_id
                     );

    --
  End If;
  --
  Return l_met_count;
  --
End get_prereq_met_count;


FUNCTION get_prereq_not_met_count
	(p_event_id in ota_events.event_id%type,
	 p_prerequisite_course_id ota_activity_versions.activity_version_id%type,
     p_comp_id in per_competence_elements.competence_id%type,
     p_level_id in per_competence_elements.proficiency_level_id%type
) RETURN varchar2 is

l_not_met_cnt Number := 0;
--
Begin
  --
  If p_prerequisite_course_id is not null then
    --
    l_not_met_cnt := Get_course_prereq_count
                     (p_prereq_met              =>  'N'
                     ,p_event_id                =>   p_event_id
                     ,p_prerequisite_course_id  =>   p_prerequisite_course_id
                     );
    --
  Else
    --
    l_not_met_cnt := Get_comp_prereq_count
                     (p_prereq_met           =>     'N'
                     ,p_event_id             =>     p_event_id
                     ,p_comp_id              =>     p_comp_id
                     ,p_level_id             =>     p_level_id
                     );
    --
  End If;
  --
  Return l_not_met_cnt;
  --
end get_prereq_not_met_count;


-- Added for Bug#4485646
FUNCTION is_mand_comp_prereqs_comp_evt
	(p_person_id in per_all_people_f.person_id%type,
	 p_event_id in ota_events.event_id%type
) RETURN varchar2
IS
  CURSOR csr_get_course_id IS
  SELECT activity_version_id
  FROM ota_events
  WHERE event_id = p_event_id;

  l_activity_version_id ota_activity_versions.activity_version_id%TYPE;

BEGIN
 OPEN csr_get_course_id;
 FETCH csr_get_course_id INTO l_activity_version_id;
 CLOSE csr_get_course_id;
 RETURN  is_mand_comp_prereqs_completed(
        p_person_id   => p_person_id
       ,p_act_ver_id  => l_activity_version_id);
END is_mand_comp_prereqs_comp_evt;

FUNCTION is_mand_crs_prereqs_comp_evt
	(p_person_id in per_all_people_f.person_id%type
    ,p_delegate_contact_id in ota_delegate_bookings.delegate_contact_id%TYPE
    ,p_user_id in number
    ,p_user_type in varchar2
	,p_event_id in ota_events.event_id%type
) RETURN varchar2
IS
  CURSOR csr_get_course_id IS
  SELECT activity_version_id
  FROM ota_events
  WHERE event_id = p_event_id;

  l_activity_version_id ota_activity_versions.activity_version_id%TYPE;

BEGIN
 OPEN csr_get_course_id;
 FETCH csr_get_course_id INTO l_activity_version_id;
 CLOSE csr_get_course_id;
 RETURN  is_mand_crs_prereqs_completed(
        p_person_id           => p_person_id
       ,p_delegate_contact_id => p_delegate_contact_id
       ,p_user_id             => p_user_id
       ,p_user_type           => p_user_type
       ,p_act_ver_id          => l_activity_version_id);
END is_mand_crs_prereqs_comp_evt;

FUNCTION is_mandatory_prereqs_comp_evt
	(p_person_id in per_all_people_f.person_id%type
    ,p_delegate_contact_id in ota_delegate_bookings.delegate_contact_id%TYPE default NULL
    ,p_user_id in number default NULL
    ,p_user_type in varchar2 default 'E'
   , p_event_id in ota_events.event_id%type
) RETURN varchar2
IS
l_user_type varchar2(10):= p_user_type;
l_user_id number(15):=p_user_id;
BEGIN

  If p_delegate_contact_id is not null then
    l_user_type := 'C';
    l_user_id := ota_utility.get_ext_lrnr_party_id(p_delegate_contact_id);

  end if;
  IF is_mand_crs_prereqs_comp_evt(p_person_id           => p_person_id
                                 ,p_delegate_contact_id => p_delegate_contact_id
                                 ,p_user_id             => l_user_id
                                 ,p_user_type           => l_user_type
                                 ,p_event_id            => p_event_id) = 'N' THEN
     RETURN 'N';
  ELSIF p_person_id IS NOT NULL THEN
     RETURN is_mand_comp_prereqs_comp_evt(p_person_id => p_person_id
                                         ,p_event_id  => p_event_id);
  END IF;

  RETURN 'Y';
END is_mandatory_prereqs_comp_evt;

-- ----------------------------------------------------------------------------
-- |-------------------------< is_valid_classes_available >--------------------|
-- ----------------------------------------------------------------------------
--  PUBLIC
-- Description:
--   Validates whether prerequisite course contains valid classes or not.
--   Course should have associated offering and valid classes. Valid classes
--   include classes  whose class type is SCHEDULED or SELFPACED and whose
--   class status is not Cancelled and which are not expired
--
FUNCTION is_valid_classes_available
  (p_prerequisite_course_id in number
  ) RETURN varchar2 is
  --
  cursor get_valid_classes is
    select 'Y'
      from OTA_EVENTS oev
     where oev.ACTIVITY_VERSION_ID = p_prerequisite_course_id
           and (oev.EVENT_TYPE = 'SCHEDULED' or oev.EVENT_TYPE = 'SELFPACED')
	   and oev.EVENT_STATUS <> 'A'
	   and nvl(trunc(oev.course_end_date), trunc(sysdate)) >= trunc(sysdate);

  l_proc                  varchar2(72) := g_package||'is_valid_classes_available';
  l_flag varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  Open get_valid_classes;
  fetch get_valid_classes into l_flag;

  If ( get_valid_classes%notfound ) Then
    l_flag := 'N';
  else
    l_flag := 'Y';
  End If;

  close get_valid_classes;
  return l_flag;
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
End is_valid_classes_available;
--
end ota_cpr_utility;

/
