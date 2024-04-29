--------------------------------------------------------
--  DDL for Package Body OTA_LO_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LO_UTILITY" as
/* $Header: otloutil.pkb 120.68.12010000.14 2009/09/14 12:24:34 smahanka ship $ */

g_package  varchar2(33)	:= '  ota_lo_utility.';  -- Global package name
cursor csr_active_cert_prd_person(p_event_id ota_events.event_id%type,
                                  p_person_id ota_cert_enrollments.contact_id%type) is
SELECT cpe.cert_prd_enrollment_id
FROM OTA_CERTIFICATIONS_B 		crt,
     OTA_CERT_ENROLLMENTS  		cre,
     OTA_CERT_PRD_ENROLLMENTS 	cpe,
     OTA_CERT_MBR_ENROLLMENTS 	cme,
     OTA_CERTIFICATION_MEMBERS   cmb,
     OTA_EVENTS evt
WHERE crt.CERTIFICATION_ID = cre.CERTIFICATION_ID
   AND crt.CERTIFICATION_ID = cmb.CERTIFICATION_ID
   AND cmb.OBJECT_TYPE = 'H'
   AND cmb.OBJECT_ID = evt.activity_version_id
   AND evt.event_id = p_event_id
   AND cme.cert_member_id = cmb.certification_member_id
   AND cme.cert_prd_enrollment_id = cpe.CERT_PRD_ENROLLMENT_ID
   AND cre.CERT_ENROLLMENT_ID = cpe.CERT_ENROLLMENT_ID
   AND cre.BUSINESS_GROUP_ID = OTA_GENERAL.GET_BUSINESS_GROUP_ID
   AND cre.person_id = p_person_id
   AND NVL(cre.IS_HISTORY_FLAG, 'N') = 'N'
   AND NVL(TRUNC(crt.END_DATE_ACTIVE), TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
   AND cre.CERTIFICATION_STATUS_CODE NOT IN ('CANCELLED', 'REJECTED', 'AWAITING_APPROVAL')
   AND trunc(sysdate) between trunc(cpe.CERT_PERIOD_START_DATE) and trunc(cpe.CERT_PERIOD_END_DATE)
   AND ((evt.event_type = 'SCHEDULED' AND
         evt.course_start_date >= cpe.cert_period_start_date AND
         evt.course_end_date <= cpe.cert_period_end_date )
        OR (evt.event_type = 'SELFPACED' AND
            cpe.cert_period_end_date >= evt.course_start_date AND
            NVL(evt.course_end_date,to_date('4712/12/31', 'YYYY/MM/DD')) >= cpe.cert_period_start_date)
        );

cursor csr_active_cert_prd_contact(p_event_id ota_events.event_id%type,
                                  p_contact_id ota_cert_enrollments.contact_id%type) is
SELECT cpe.cert_prd_enrollment_id
FROM OTA_CERTIFICATIONS_B 		crt,
     OTA_CERT_ENROLLMENTS  		cre,
     OTA_CERT_PRD_ENROLLMENTS 	cpe,
     OTA_CERT_MBR_ENROLLMENTS 	cme,
     OTA_CERTIFICATION_MEMBERS   cmb,
     OTA_EVENTS evt
WHERE crt.CERTIFICATION_ID = cre.CERTIFICATION_ID
   AND crt.CERTIFICATION_ID = cmb.CERTIFICATION_ID
   AND cmb.OBJECT_TYPE = 'H'
   AND cmb.OBJECT_ID = evt.activity_version_id
   AND evt.event_id = p_event_id
   AND cme.cert_member_id = cmb.certification_member_id
   AND cme.cert_prd_enrollment_id = cpe.CERT_PRD_ENROLLMENT_ID
   AND cre.CERT_ENROLLMENT_ID = cpe.CERT_ENROLLMENT_ID
   AND cre.BUSINESS_GROUP_ID = OTA_GENERAL.GET_BUSINESS_GROUP_ID
   AND cre.contact_id = p_contact_id
   AND NVL(cre.IS_HISTORY_FLAG, 'N') = 'N'
   AND NVL(TRUNC(crt.END_DATE_ACTIVE), TRUNC(SYSDATE)) >= TRUNC(SYSDATE)
   AND cre.CERTIFICATION_STATUS_CODE NOT IN ('CANCELLED', 'REJECTED', 'AWAITING_APPROVAL')
   AND trunc(sysdate) between trunc(cpe.CERT_PERIOD_START_DATE) and trunc(cpe.CERT_PERIOD_END_DATE)
   AND ((evt.event_type = 'SCHEDULED' AND
         evt.course_start_date >= cpe.cert_period_start_date AND
         evt.course_end_date <= cpe.cert_period_end_date )
        OR (evt.event_type = 'SELFPACED' AND
            cpe.cert_period_end_date >= evt.course_start_date AND
            NVL(evt.course_end_date,to_date('4712/12/31', 'YYYY/MM/DD')) >= cpe.cert_period_start_date)
        );


function compute_default_lesson_status(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_old_lesson_status ota_performances.lesson_status%type,
   p_starting_url ota_learning_objects.starting_url%type,
   p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type) return ota_performances.lesson_status%type is

   cursor child_los(
      p_lo_id ota_learning_objects.learning_object_id%type,
      p_user_id fnd_user.user_id%type,
      p_user_type ota_attempts.user_type%type) is
      select   lo.learning_object_id, nvl(p.lesson_status, 'N') as lesson_status
      from     ota_learning_objects lo, ota_performances p
      where    lo.parent_learning_object_id = p_lo_id and
               lo.published_flag = 'Y' and
               p.learning_object_id(+) = lo.source_learning_object_id and
               p.user_id(+) = p_user_id and
               p.user_type(+) = p_user_type and
			         nvl(p.cert_prd_enrollment_id(+), -1) = nvl(p_cert_prd_enroll_id, -1);

   v_completed boolean := false;
   v_not_attempted boolean := false;
   v_other boolean := false;
   v_has_children boolean := false;
begin
   if p_starting_url is not null then
      return p_old_lesson_status;
   end if;

   for a_child_lo in child_los(p_lo_id, p_user_id, p_user_type) loop
      v_has_children := true;

      if a_child_lo.lesson_status = 'P' or a_child_lo.lesson_status = 'C' then
         v_completed := true;
      elsif a_child_lo.lesson_status = 'N' then
         v_not_attempted := true;
      else
         v_other := true;
      end if;
   end loop;

   if not v_has_children then
      return p_old_lesson_status;
   else
      if v_other then
         return 'I';
      elsif v_completed then
         if v_not_attempted then
            return 'I';
         else
            return 'C';
         end if;
      else
         return 'N';
      end if;
   end if;
end compute_default_lesson_status;


function compute_lesson_status(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_old_lesson_status ota_performances.lesson_status%type,
   p_starting_url ota_learning_objects.starting_url%type,
   p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type) return ota_performances.lesson_status%type is

/* Completion reqs not yet implemented - GDHUTTON 12/24/03
   cursor completion_requirements(
      p_lo_id ota_learning_objects.learning_object_id%type,
      p_user_id fnd_user.user_id%type,
      p_user_type ota_attempts.user_type%type,
      p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type) is
      select   cr.parent_learning_object_id as learning_object_id, cr.assigned_lesson_status as assigned_lesson_status,
               null as match_lesson_status, nvl(p.lesson_status, 'N') as user_lesson_status
      from     ota_performances p, ota_completion_requirements cr
      where    cr.child_learning_object_id = p_lo_id and
               p.learning_object_id(+) = cr.parent_learning_object_id and
               p.user_id(+) = p_user_id and
               p.user_type(+) = p_user_type and
               nvl(p.cert_prd_enrollment_id(+), -1) = nvl(p_cert_prd_enroll_id, -1)
      order by cr.seq asc;
*/

begin
/* Completion reqs not yet implemented - GDHUTTON 12/24/03
   for a_cr in completion_requirements(p_lo_id, p_user_id, p_user_type, p_cert_prd_enroll_id) loop
      if (a_cr.match_lesson_status is null and (a_cr.user_lesson_status = 'P' or a_cr.user_lesson_status = 'C'))
         or a_cr.user_lesson_status = a_cr.match_lesson_status then
         return a_cr.assigned_lesson_status;
      end if;
   end loop;
*/

   -- Either there were no completion requirements or none were fulfilled.
   -- Return the default status.
   return compute_default_lesson_status(p_lo_id, p_user_id, p_user_type, p_old_lesson_status, p_starting_url, p_cert_prd_enroll_id);
end compute_lesson_status;


-- Returns true if a transition from v_old_status to v_new_status is
-- allowed and necessary
function lesson_status_transition_valid(
   p_old_lesson_status ota_performances.lesson_status%type,
   p_new_lesson_status ota_performances.lesson_status%type) return boolean is
begin
   return
      p_new_lesson_status <> p_old_lesson_status and
      p_old_lesson_status <> 'P' and
      (p_old_lesson_status <> 'C' or p_new_lesson_status = 'P');
end lesson_status_transition_valid;


function get_contact_id_for_party(
  p_party_id hz_parties.party_id%type) return number is

   cursor contact(
     p_party_id hz_parties.party_id%type) is
   select acct_role.cust_account_role_id
   from   hz_cust_account_roles acct_role,
          hz_relationships rel,
          hz_cust_accounts role_acct
   where  acct_role.party_id = rel.party_id and
          acct_role.role_type = 'CONTACT' and
          acct_role.cust_account_id = role_acct.cust_account_id and
          role_acct.party_id = rel.object_id and
          rel.subject_id = p_party_id and
          rel.subject_table_name = 'HZ_PARTIES' and
          rel.object_table_name = 'HZ_PARTIES';

    v_result hz_parties.party_id%type;
begin
   open contact(p_party_id);
   fetch contact into v_result;
   close contact;
   return v_result;
exception
   when others then
     if contact%isopen then
        close contact;
     end if;
   raise;
end get_contact_id_for_party;


procedure update_enrollment(
  p_booking_id ota_delegate_bookings.booking_id%type,
  p_event_id ota_events.event_id%type,
  p_business_group_id ota_delegate_bookings.business_group_id%type,
  p_date_booking_placed ota_delegate_bookings.date_booking_placed%type,
  p_object_version_number ota_delegate_bookings.object_version_number%type,
  p_sign_eval_status ota_delegate_bookings.sign_eval_status%type,
  p_date_status_changed ota_delegate_bookings.date_status_changed%type,
  p_new_status varchar2,
  p_failed varchar2,
  p_signed varchar2) is

  v_result_object_version_number ota_finance_lines.object_version_number%type;
  v_finance_line_id ota_finance_lines.finance_line_id%type;
  v_booking_status_row		ota_booking_status_types%rowtype;
  v_object_version_number ota_delegate_bookings.object_version_number%type;
  v_date_status_changed ota_delegate_bookings.date_status_changed%type:=p_date_status_changed;
  l_successful_attendance_flag varchar2(1):='N';
  l_failure_reason varchar2(20);
  l_new_sign_eval_status ota_delegate_bookings.sign_eval_status%type;
  l_status varchar2(20):=p_new_status;
  L_PROC varchar2 (72):= G_PACKAGE || 'UPDATE_ENROLLMENT';
begin
	HR_UTILITY.SET_LOCATION ('Entering:' || L_PROC, 5);
	--HR_UTILITY.TRACE ('SIGN_EVAL_STATUS: ' || p_sign_eval_status);
	--HR_UTILITY.TRACE ('ENR STATUS: ' || p_new_status);
	--HR_UTILITY.TRACE ('FAILURE: ' || p_failed);
   	--HR_UTILITY.TRACE ('DATE_BOOKING_PLACED: ' || p_date_booking_placed);
  v_finance_line_id := null;
  v_object_version_number := p_object_version_number;
  if p_sign_eval_status is not null then
      if p_signed='Y' then
        case p_sign_eval_status
		  when 'SE' then l_new_sign_eval_status:='ME';
			             l_status:='PENDING EVALUATION';
		  when 'VE' then l_new_sign_eval_status:='OE';
                         l_status:='ATTENDED';
		  when 'UE' then l_new_sign_eval_status:='DD';
			             l_status:='ATTENDED';
		  else l_new_sign_eval_status:=p_sign_eval_status;
	    end case;
      elsif p_signed is null then
 	      case p_sign_eval_status
		      when 'SD' then l_new_sign_eval_status:='SE';
			             l_status:='PENDING EVALUATION';
		      when 'VD' then l_new_sign_eval_status:='VE';
                         l_status:='PENDING EVALUATION';
		      when 'MD' then l_new_sign_eval_status:='ME';
			             l_status:='PENDING EVALUATION';
		      when 'UD' then l_new_sign_eval_status:='UE';
			             l_status:='PENDING EVALUATION';
		      when 'OD' then l_new_sign_eval_status:='OE';
			             l_status:='ATTENDED';
              when 'SE' then l_new_sign_eval_status:='ME';
                         l_status:='PENDING EVALUATION';
              when 'UE' then l_new_sign_eval_status:='DD';
                         l_status:='ATTENDED';
              when 'ME' then l_new_sign_eval_status:='DD';
                         l_status:='ATTENDED';
              when 'OE' then l_new_sign_eval_status:='DD';
                         l_status:='ATTENDED';
              when 'VE' then l_new_sign_eval_status:='OE';
                         l_status:='ATTENDED';
		      else l_new_sign_eval_status:=p_sign_eval_status;
		                 l_status:='ATTENDED';
	       end case;
        end if;
    end if;
  v_booking_status_row :=
    ota_enroll_in_training_ss.get_booking_status_for_web(
                                p_web_booking_status_type => l_status,
                                p_business_group_id => p_business_group_id);




    if p_failed = 'Y' then
        l_failure_reason:= 'OF';
    elsif l_status = 'ATTENDED' then
        l_successful_attendance_flag:='Y';
    end if;

    if v_date_status_changed is null then
        v_date_status_changed := sysdate;
    end if;


  ota_tdb_api_upd2.update_enrollment(
    p_booking_id => p_booking_id,
    p_event_id => p_event_id,
    p_failure_reason => l_failure_reason,
    p_object_version_number => v_object_version_number,
    p_booking_status_type_id => v_booking_status_row.booking_status_type_id,
    p_tfl_object_version_number => v_result_object_version_number,
    p_finance_line_id => v_finance_line_id,
    p_date_status_changed => p_date_status_changed,
    p_date_booking_placed => p_date_booking_placed,
    p_successful_attendance_flag => l_successful_attendance_flag,
    p_sign_eval_status => l_new_sign_eval_status);
HR_UTILITY.SET_LOCATION ('Leaving:' || L_PROC, 10);
end update_enrollment;


procedure update_enrollment(
  p_booking_id ota_delegate_bookings.booking_id%type,
  p_event_id ota_events.event_id%type,
  p_business_group_id ota_delegate_bookings.business_group_id%type,
  p_date_booking_placed ota_delegate_bookings.date_booking_placed%type,
  p_object_version_number ota_delegate_bookings.object_version_number%type,
  p_sign_eval_status ota_delegate_bookings.sign_eval_status%type,
  p_date_status_changed ota_delegate_bookings.date_status_changed%type,
  p_new_status varchar2,
  p_failed varchar2) is

begin
 update_enrollment(p_booking_id,p_event_id,p_business_group_id,p_date_booking_placed,p_object_version_number,p_sign_eval_status,p_date_status_changed,p_new_status,p_failed,null);
end update_enrollment;

procedure update_enrollment(
  p_booking_id ota_delegate_bookings.booking_id%type,
  p_event_id ota_events.event_id%type,
  p_business_group_id ota_delegate_bookings.business_group_id%type,
  p_date_booking_placed ota_delegate_bookings.date_booking_placed%type,
  p_object_version_number ota_delegate_bookings.object_version_number%type,
  p_date_status_changed ota_delegate_bookings.date_status_changed%type,
  p_new_status varchar2) is


begin
  update_enrollment(p_booking_id,p_event_id,p_business_group_id,p_date_booking_placed,p_object_version_number,null,p_date_status_changed,p_new_status,null);

end update_enrollment;


--Added for updating the enrollment status to 'Attended'
--for the learners who have completed the mandatory evaluation.
procedure update_enrollment_status(
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_event_id ota_events.event_id%type) is

   -- This cursor finds all events in all offerings which offer the LO and in
   -- which the person is enrolled with a status of 'PENDING EVALUATION'.


   cursor person_bookings(
     p_event_id ota_events.event_id%type,
     p_person_id ota_delegate_bookings.delegate_person_id%type) is
   select book.booking_id,
          book.sign_eval_status,
          ev.event_id,
          book.business_group_id,
          book.date_booking_placed,
          book.object_version_number
   from   ota_events ev,
          ota_delegate_bookings book,
          ota_booking_status_types stype
   where  nvl(ev.course_start_date, sysdate) <= sysdate and
          book.event_id = ev.event_id and
          book.delegate_person_id = p_person_id and
          ev.event_id = p_event_id and
          book.booking_status_type_id = stype.booking_status_type_id and
          stype.type = 'E';

--Added for 6826434.
   cursor party_bookings(
     p_event_id ota_events.event_id%type,
     p_party_id ota_delegate_bookings.delegate_contact_id%type) is
   select book.booking_id,
          book.sign_eval_status,
          ev.event_id,
          book.business_group_id,
          book.date_booking_placed,
          book.object_version_number
   from   ota_events ev,
          ota_delegate_bookings book,
          ota_booking_status_types stype,
          hz_cust_account_roles acct_role,
          hz_relationships rel,
          hz_cust_accounts role_acct
   where  nvl(ev.course_start_date, sysdate) <= sysdate and
          book.event_id = ev.event_id and
          book.booking_status_type_id = stype.booking_status_type_id and
          ev.event_id = p_event_id and
          stype.type = 'E' and
          book.delegate_contact_id = acct_role.cust_account_role_id and
          acct_role.party_id = rel.party_id and
          acct_role.role_type = 'CONTACT' and
          acct_role.cust_account_id = role_acct.cust_account_id and
          role_acct.party_id = rel.object_id and
          rel.subject_id = p_party_id and
          rel.subject_table_name = 'HZ_PARTIES' and
          rel.object_table_name = 'HZ_PARTIES';

   cursor perf_lesson_status is
   select per.lesson_status,
          offe.learning_object_id
   from   ota_performances per,
          ota_offerings offe,
          ota_events evt
   where  evt.parent_offering_id = offe.offering_id and
   offe.learning_object_id = per.learning_object_id(+) and
   evt.event_id = p_event_id and
   (per.user_type is null or per.user_type = p_user_type) and
   (per.user_id is null or per.user_id = p_user_id);


l_proc varchar2(72) := g_package||'update_enrollment_status';
l_status varchar2(80) :='ATTENDED';
l_perf_status varchar2(1);
l_learning_object_id ota_offerings.learning_object_id%type;
l_failed varchar2(1):= null;
l_new_sign_eval_status varchar2(2) := null;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  open perf_lesson_status;
  fetch perf_lesson_status into l_perf_status,l_learning_object_id;
  close perf_lesson_status;
  if(l_perf_status = 'F') then
    l_failed := 'Y';
  elsif ((l_perf_status is null) and (l_learning_object_id is null)) then
    l_failed := 'N';
  end if;
  If (p_user_type = 'E') Then
     for a_booking in person_bookings(p_event_id, p_user_id) loop
        update_enrollment(
           a_booking.booking_id,
           a_booking.event_id,
           a_booking.business_group_id,
           a_booking.date_booking_placed,
           a_booking.object_version_number,
           a_booking.sign_eval_status,
           sysdate,
           l_status,
           l_failed);
     end loop;
   else    --Added for 6826434.
     for a_booking in party_bookings(p_event_id, p_user_id) loop
        update_enrollment(
           a_booking.booking_id,
           a_booking.event_id,
           a_booking.business_group_id,
           a_booking.date_booking_placed,
           a_booking.object_version_number,
           a_booking.sign_eval_status,
           sysdate,
           l_status,
           l_failed);
     end loop;

  End If;
  hr_utility.set_location('Exiting:'|| l_proc, 20);
end update_enrollment_status;



procedure update_enroll_status_for_lo(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_date date) is





l_proc varchar2(72) := g_package||'update_enroll_status_for_lo';

begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
    update_enroll_status_for_lo(p_lo_id,p_user_id,p_user_type,p_date,null);

  hr_utility.set_location('Exiting:'|| l_proc, 15);
end update_enroll_status_for_lo;

procedure update_enroll_status_for_lo(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_date date,
   p_failed varchar2) is

   -- This cursor finds all events in all offerings which offer the LO and in
   -- which the person is enrolled with a status of 'PLACED'.  Note that we
   -- use source_learning_object_id here in case reuse by reference is ever
   -- implemented.
   cursor person_bookings(
     p_lo_id ota_learning_objects.learning_object_id%type,
     p_person_id ota_delegate_bookings.delegate_person_id%type) is
   select book.booking_id,
          book.sign_eval_status,
          ev.event_id,
          book.business_group_id,
          book.date_booking_placed,
          book.object_version_number,
          stype.type				--Added for 7110517.
   from   ota_events ev,
          ota_offerings offr,
          ota_learning_objects lo,
          ota_delegate_bookings book,
          ota_booking_status_types stype
   where  lo.source_learning_object_id = p_lo_id and
          lo.learning_object_id = offr.learning_object_id and
          offr.offering_id = ev.parent_offering_id and
          nvl(ev.course_start_date, sysdate) <= sysdate and
          book.event_id = ev.event_id and
          book.delegate_person_id = p_person_id and
          book.booking_status_type_id = stype.booking_status_type_id and
          (stype.type = 'P' or
	    (stype.type = 'A' and 				   --6777581.Added 'A' for
	    nvl(book.successful_attendance_flag,'N')='N'));--failed candidates.



   -- This cursor finds all events in all offerings which offer the LO and in
   -- which the party is enrolled.  Note that we use source_learning_object_id
   -- here in case reuse by reference is ever implemented.
   cursor party_bookings(
     p_lo_id ota_learning_objects.learning_object_id%type,
     p_party_id ota_delegate_bookings.delegate_contact_id%type) is
   select book.booking_id,
          book.sign_eval_status,
          ev.event_id,
          book.business_group_id,
          book.date_booking_placed,
          book.object_version_number,
          stype.type			--Added fro 7110517.
   from   ota_events ev,
          ota_offerings offr,
          ota_learning_objects lo,
          ota_delegate_bookings book,
          ota_booking_status_types stype,
          hz_cust_account_roles acct_role,
          hz_relationships rel,
          hz_cust_accounts role_acct
   where  lo.source_learning_object_id = p_lo_id and
          lo.learning_object_id = offr.learning_object_id and
          offr.offering_id = ev.parent_offering_id and
          nvl(ev.course_start_date, sysdate) <= sysdate and
          book.event_id = ev.event_id and
          book.booking_status_type_id = stype.booking_status_type_id and
          (stype.type = 'P' or
	    (stype.type = 'A' and 				       --6777581.Added 'A' for
	    nvl(book.successful_attendance_flag,'N')='N')) and --failed candidates.
          book.delegate_contact_id = acct_role.cust_account_role_id and
          acct_role.party_id = rel.party_id and
          acct_role.role_type = 'CONTACT' and
          acct_role.cust_account_id = role_acct.cust_account_id and
          role_acct.party_id = rel.object_id and
          rel.subject_id = p_party_id and
          rel.subject_table_name = 'HZ_PARTIES' and
          rel.object_table_name = 'HZ_PARTIES';

l_event_id OTA_EVENTS.EVENT_ID%TYPE:= null;
l_test_id OTA_TESTS.TEST_ID%type:=null;
   Cursor csr_attempt_info is
    select attempt_id from ota_attempts where
    event_id = l_event_id
    and test_id = l_test_id
    and user_id = p_user_id
    and user_type = p_user_type;



  Cursor csr_evt_evaluations is
   select evt_eval.evaluation_id evt_eval_id
      ,decode(nvl(evt_eval.eval_mandatory_flag,'N'), 'Y', 'Y',
       decode(act_eval.evaluation_id,null,'N',decode(nvl(act_eval.eval_mandatory_flag,'N'),'Y','Y','N'))) flag  --bug 7184369
      ,act_eval.evaluation_id act_eval_id
   from ota_evaluations evt_eval, ota_evaluations act_eval,ota_events evt
   where
   evt_eval.object_id(+) = evt.event_id and
   (evt_eval.object_type is null or evt_eval.object_type = 'E') and
   act_eval.object_id(+) = evt.activity_version_id and
   (act_eval.object_type is null or act_eval.object_type = 'A')
   and evt.event_id = l_event_id
   and (evt_eval.evaluation_id is not null or act_eval.evaluation_id is not null);  --7172501

l_proc varchar2(72) := g_package||'update_enroll_status_for_lo';
l_act_eval_id OTA_TESTS.TEST_ID%TYPE:=null;
l_evt_eval_id OTA_TESTS.TEST_ID%TYPE:=null;
l_eval_mand_flag varchar2(1);
l_dummy ota_attempts.attempt_id%type;
l_is_attempted boolean :=false;
l_status varchar2(80) :='ATTENDED';
l_user_type ota_attempts.user_type%type;
l_new_sign_eval_status varchar2(2):= null;
begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
  if p_user_type = 'E' then
     for a_booking in person_bookings(p_lo_id, p_user_id) loop
        update_enrollment(
           a_booking.booking_id,
           a_booking.event_id,
           a_booking.business_group_id,
           a_booking.date_booking_placed,
           a_booking.object_version_number,
           a_booking.sign_eval_status,
           p_date,
           l_status,
           p_failed);
     end loop;
  else
     for a_booking in party_bookings(p_lo_id, p_user_id) loop
        update_enrollment(
           a_booking.booking_id,
           a_booking.event_id,
           a_booking.business_group_id,
           a_booking.date_booking_placed,
           a_booking.object_version_number,
           a_booking.sign_eval_status,
           p_date,
           l_status,
           p_failed);
      end loop;
  end if;
  hr_utility.set_location('Exiting:'|| l_proc, 15);
end update_enroll_status_for_lo;


procedure update_cme_status_for_lo(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_date date,
   p_cert_prd_enroll_id ota_cert_mbr_enrollments.cert_prd_enrollment_id%type) is

   -- This cursor finds all certification member records in the certification
   -- period that area associated with this learning object.
   cursor cert_member_enrollments(
     p_learning_object_id ota_learning_objects.learning_object_id%type,
     p_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type) is
   select distinct(cme.cert_mbr_enrollment_id),
          cme.member_status_code,
          cme.object_version_number,
          cme.cert_member_id,
          cme.cert_prd_enrollment_id
   from ota_certification_members cm, ota_cert_mbr_enrollments cme,
        ota_offerings o, ota_cert_prd_enrollments cpe
   where
         cme.cert_prd_enrollment_id = p_cert_prd_enrollment_id
         and cme.cert_member_id = cm.certification_member_id
         and cm.object_id = o.activity_version_id
         and o.learning_object_id = p_learning_object_id
         -- filter ended offerings
         and trunc(sysdate) between trunc(o.start_date) and nvl(trunc(o.end_date), trunc(sysdate))
         and cme.cert_prd_enrollment_id = cpe.cert_prd_enrollment_id
         and cpe.period_status_code <> 'CANCELLED'
         and trunc(sysdate) between trunc(cpe.cert_period_start_date) and trunc(cpe.cert_period_end_date)
         and cme.member_status_code <> 'CANCELLED';

l_new_mbr_status_code         ota_cert_mbr_enrollments.member_status_code%TYPE;

begin
  l_new_mbr_status_code := 'COMPLETED';

  for a_cert_mbr_enrollment in cert_member_enrollments(p_lo_id, p_cert_prd_enroll_id) loop


            --call upd cme api
	        ota_cert_mbr_enrollment_api.update_cert_mbr_enrollment
                        (p_effective_date           => sysdate
                        ,p_object_version_number    => a_cert_mbr_enrollment.object_version_number
                        ,p_cert_member_id           => a_cert_mbr_enrollment.cert_member_id
                        ,p_cert_prd_enrollment_id   => p_cert_prd_enroll_id
                        ,p_cert_mbr_enrollment_id   => a_cert_mbr_enrollment.cert_mbr_enrollment_id
                        ,p_member_status_code       => l_new_mbr_status_code
                        ,p_completion_date          => p_date);

           -- cascade status to certification period
           ota_cme_util.update_cpe_status(a_cert_mbr_enrollment.cert_mbr_enrollment_id, a_cert_mbr_enrollment.cert_prd_enrollment_id);

  end loop;
end update_cme_status_for_lo;


procedure set_performance_lesson_status(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_lesson_status ota_performances.lesson_status%type,
   p_cascaded boolean,
   p_date date,
   p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type) is

   cursor affected_los(
      p_lo_id ota_learning_objects.learning_object_id%type,
      p_user_id fnd_user.user_id%type,
      p_user_type ota_attempts.user_type%type,
      p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type) is
      select   parent.learning_object_id as learning_object_id,
               nvl(perf.lesson_status, 'N') as lesson_status,
               parent.starting_url as starting_url
      from     ota_learning_objects child, ota_learning_objects parent, ota_performances perf
      where    child.source_learning_object_id = p_lo_id and
               child.parent_learning_object_id = parent.learning_object_id and
               parent.learning_object_id = parent.source_learning_object_id and
               parent.starting_url is null and
               perf.user_id(+) = p_user_id and
               perf.user_type(+) = p_user_type and
               perf.learning_object_id(+) = parent.learning_object_id and
			         nvl(perf.cert_prd_enrollment_id(+), -1) = nvl(p_cert_prd_enroll_id, -1);
/* Completion requirements not yet implemented - GDHUTTON 12/24/03
      union
      select   cr.child_learning_object_id as learning_object_id,
               nvl(perf.lesson_status, 'N') as lesson_status,
               lo.starting_url as starting_url
      from     ota_performances perf, ota_completion_requirements cr, ota_learning_objects lo
      where    cr.parent_learning_object_id = p_lo_id and
               cr.child_learning_object_id = lo.learning_object_id and
               perf.learning_object_id(+) = cr.child_learning_object_id and
               perf.user_id(+) = p_user_id and
               perf.user_type(+) = p_user_type and
			         nvl(perf.cert_prd_enrollment_id(+), -1) = nvl(p_cert_prd_enroll_id, -1);
*/
   v_completed_date ota_performances.completed_date%type;
   v_source_lo_id ota_learning_objects.learning_object_id%type;
   v_business_group_id ota_learning_objects.business_group_id%type;
   v_old_lesson_status ota_performances.lesson_status%type;
   v_new_lesson_status ota_performances.lesson_status%type;
   v_performance_source ota_performances.source%type;
begin
   -- The performance is actually stored on the source learning object, so get that ID.
   -- Also get the business group in case we have to create a new performance record.
   select   source_learning_object_id, business_group_id
   into     v_source_lo_id, v_business_group_id
   from     ota_learning_objects
   where    learning_object_id = p_lo_id;

   begin
      -- Find the old status and completed date.
      select   p.lesson_status, p.completed_date
      into     v_old_lesson_status, v_completed_date
      from     ota_performances p
      where    p.learning_object_id = v_source_lo_id and
               p.user_id = p_user_id and
               p.user_type = p_user_type and
			         nvl(p.cert_prd_enrollment_id, -1) = nvl(p_cert_prd_enroll_id, -1);

      -- Check if any work needs to be done
      if (not p_cascaded and p_lesson_status <> v_old_lesson_status) or
         lesson_status_transition_valid(v_old_lesson_status, p_lesson_status) then

         -- See if the completed_date should change.
         if v_old_lesson_status <> 'P' and v_old_lesson_status <> 'C' and
            (p_lesson_status = 'P' or p_lesson_status = 'C' or p_lesson_status = 'F') then
	                if(p_lesson_status <> 'F') then
	                    v_completed_date := p_date;
	                    update_enroll_status_for_lo(v_source_lo_id, p_user_id, p_user_type, p_date);
	                    if p_cert_prd_enroll_id is not null then
	                        update_cme_status_for_lo(p_lo_id, p_date, p_cert_prd_enroll_id);
	                    end if;
	                else
	                    update_enroll_status_for_lo(v_source_lo_id, p_user_id, p_user_type, p_date, 'Y');
            end if;
         elsif (v_old_lesson_status = 'P' or v_old_lesson_status = 'C') and
               p_lesson_status <> 'P' and p_lesson_status <> 'C' then
            -- With current rules, this should never happen.
            v_completed_date := null;
         end if;

         if p_cascaded then
            v_performance_source := 'CASCADE';
         else
            v_performance_source := 'ATTEMPT';
         end if;

         update   ota_performances
         set      lesson_status = p_lesson_status,
                  completed_date = v_completed_date,
                  last_updated_by = p_user_id,
                  last_update_date = p_date,
                  source = v_performance_source,
                  overridden_by = null,
                  overridden_date = null
         where    user_id = p_user_id and
                  user_type = p_user_type and
                  learning_object_id = v_source_lo_id and
                  nvl(cert_prd_enrollment_id, -1) = nvl(p_cert_prd_enroll_id, -1);
      --6777581.Added to update the enrollment status of learners who have already completed the learning object.
      elsif (p_lesson_status = 'P' or p_lesson_status = 'C')and (p_lesson_status = v_old_lesson_status) then
         update_enroll_status_for_lo(v_source_lo_id, p_user_id, p_user_type, p_date);
         -- Since we did not actually change anything, we just return
         -- so that we don't try to cascade the non-change.
         return;
      end if;

   exception
      when NO_DATA_FOUND then
         if p_lesson_status <> 'N' then

            -- See if the completed_date should be filled in.
            if p_lesson_status = 'P' or p_lesson_status = 'C' then
               v_completed_date := p_date;
               update_enroll_status_for_lo(v_source_lo_id, p_user_id, p_user_type, p_date);
               if p_cert_prd_enroll_id is not null then
                  update_cme_status_for_lo(v_source_lo_id, p_date, p_cert_prd_enroll_id);
               end if;
            else
               v_completed_date := null;
            end if;

            if p_cascaded then
               v_performance_source := 'CASCADE';
            else
               v_performance_source := 'ATTEMPT';
            end if;

            -- Insert a new ota_performances record.
            insert into ota_performances
               (performance_id, user_id, user_type, learning_object_id,
               lesson_status, score, time, completed_date,
               created_by, creation_date, last_updated_by, last_update_date,
               source, object_version_number, business_group_id, cert_prd_enrollment_id)
            values
               (ota_performances_s.nextval, p_user_id, p_user_type, v_source_lo_id,
               p_lesson_status, -1000, -1001, v_completed_date,
               p_user_id, p_date, p_user_id, p_date,
               v_performance_source, 0, v_business_group_id, p_cert_prd_enroll_id);
         else
            return;
         end if;
   end;

   -- Cascade the change to any affected RCOs.	These include parents of this
   -- ota_learning_objects, plus those that indicate this ota_learning_objects as a completion
   -- requirement.
   for a_lo in affected_los(v_source_lo_id, p_user_id, p_user_type, p_cert_prd_enroll_id) loop
      -- if the current status is Passed, nothing can override it, so we will
      -- save the effort of computing the new status
      if a_lo.lesson_status <> 'P' then
         v_new_lesson_status := compute_lesson_status(a_lo.learning_object_id, p_user_id, p_user_type, a_lo.lesson_status, a_lo.starting_url, p_cert_prd_enroll_id);
         if lesson_status_transition_valid(a_lo.lesson_status, v_new_lesson_status) then
            set_performance_lesson_status(a_lo.learning_object_id, p_user_id, p_user_type, v_new_lesson_status, true, p_date, p_cert_prd_enroll_id);
         end if;
      end if;
   end loop;
end set_performance_lesson_status;


procedure set_performance_lesson_status(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_lesson_status ota_performances.lesson_status%type,
   p_date date,
   p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type) is
begin
   set_performance_lesson_status(p_lo_id, p_user_id, p_user_type, p_lesson_status, false, p_date, p_cert_prd_enroll_id);
end set_performance_lesson_status;


procedure set_performance_lesson_status(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_lesson_status ota_performances.lesson_status%type,
   p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type) is
begin
   set_performance_lesson_status(p_lo_id, p_user_id, p_user_type, p_lesson_status, sysdate, p_cert_prd_enroll_id);
end set_performance_lesson_status;


procedure set_performance_time(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_time ota_performances.time%type,
   p_cascaded boolean,
   p_date date,
   p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type) is

   cursor parent_los(
      p_lo_id ota_learning_objects.learning_object_id%type,
      p_user_id fnd_user.user_id%type,
      p_user_type ota_attempts.user_type%type,
      p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type) is
      select   parent.learning_object_id, parent.starting_url, nvl(perf.time, 0) as time
      from     ota_learning_objects child, ota_learning_objects parent, ota_performances perf
      where    child.source_learning_object_id = p_lo_id and
	            child.parent_learning_object_id = parent.learning_object_id and
	            parent.learning_object_id = parent.source_learning_object_id and
	            parent.starting_url is null and
	            perf.user_id(+) = p_user_id and
	            perf.user_type(+) = p_user_type and
	            perf.learning_object_id(+) = parent.learning_object_id and
				      nvl(perf.cert_prd_enrollment_id(+), -1) = nvl(p_cert_prd_enroll_id, -1);

   cursor distinct_child_los(
      p_lo_id ota_learning_objects.learning_object_id%type,
      p_user_id fnd_user.user_id%type,
      p_user_type ota_attempts.user_type%type,
      p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type) is
      select   lo.source_learning_object_id as learning_object_id, nvl(p.time, 0) as time
      from     ota_performances p,
                  (select     distinct learning_object_id, source_learning_object_id, starting_url
                  from        ota_learning_objects
                  where       learning_object_id <> p_lo_id
                  start with  learning_object_id = p_lo_id
                  connect by  parent_learning_object_id = prior learning_object_id) lo
      where    lo.starting_url is not null and
               p.learning_object_id(+) = lo.source_learning_object_id and
               p.user_id(+) = p_user_id and
               p.user_type(+) = p_user_type and
			         nvl(p.cert_prd_enrollment_id(+), -1) = nvl(p_cert_prd_enroll_id, -1);

   v_source_lo_id ota_learning_objects.learning_object_id%type;
   v_business_group_id ota_learning_objects.business_group_id%type;
   v_old_time ota_performances.time%type;
   v_new_time ota_performances.time%type;
   v_performance_source ota_performances.source%type;
begin
   -- The performance is actually stored on the source learning object, so get that ID.
   -- Also get the business group in case we have to create a new performance record.
   select   source_learning_object_id, business_group_id
   into     v_source_lo_id, v_business_group_id
   from     ota_learning_objects
   where    learning_object_id = p_lo_id;

   begin
      select   p.time
      into     v_old_time
      from     ota_performances p
      where    p.learning_object_id = v_source_lo_id and
               p.user_id = p_user_id and
               p.user_type = p_user_type and
			         nvl(p.cert_prd_enrollment_id, -1) = nvl(p_cert_prd_enroll_id, -1);

      if p_time <> v_old_time then
         update   ota_performances
         set      time = p_time,
                  last_updated_by = p_user_id,
                  last_update_date = p_date
         where    user_id = p_user_id and
                  user_type = p_user_type and
                  learning_object_id = v_source_lo_id and
				          nvl(cert_prd_enrollment_id, -1) = nvl(p_cert_prd_enroll_id, -1);
      else
         return;
      end if;
   exception
      when NO_DATA_FOUND then
         if p_time <> 0 then

            if p_cascaded then
               v_performance_source := 'CASCADE';
            else
               v_performance_source := 'ATTEMPT';
            end if;

            insert into ota_performances
               (performance_id, user_id, user_type, learning_object_id,
               lesson_status, score, time,
               created_by, creation_date, last_updated_by, last_update_date,
               source, object_version_number, business_group_id, cert_prd_enrollment_id)
            values
               (ota_performances_s.nextval, p_user_id, p_user_type, v_source_lo_id,
               'N', -1000, p_time,
               p_user_id, p_date, p_user_id, p_date,
               v_performance_source, 0, v_business_group_id, p_cert_prd_enroll_id);
         else
            return;
         end if;
   end;

   -- Get all the source-parents of all the targets of the ota_learning_objects
   for a_parent_lo in parent_los(p_lo_id, p_user_id, p_user_type, p_cert_prd_enroll_id) loop
      v_new_time := 0;
      for a_child_lo in distinct_child_los(a_parent_lo.learning_object_id, p_user_id, p_user_type, p_cert_prd_enroll_id) loop
	      if a_child_lo.time > 0 then
	         v_new_time := v_new_time + a_child_lo.time;
	      end if;
      end loop;

      if v_new_time <> a_parent_lo.time then
         set_performance_time(a_parent_lo.learning_object_id, p_user_id, p_user_type, v_new_time, true, p_date, p_cert_prd_enroll_id);
      end if;
   end loop;
end set_performance_time;


procedure set_performance_time(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_time ota_performances.time%type,
   p_date date,
   p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type) is
begin
   set_performance_time(p_lo_id, p_user_id, p_user_type, p_time, false, p_date, p_cert_prd_enroll_id);
end set_performance_time;


procedure set_performance_time(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_time ota_performances.time%type,
   p_cert_prd_enroll_id ota_performances.cert_prd_enrollment_id%type) is
begin
   set_performance_time(p_lo_id, p_user_id, p_user_type, p_time, sysdate, p_cert_prd_enroll_id);
end set_performance_time;


function lo_is_attemptable(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_launch_type ota_attempts.launch_type%type,
   p_reason out nocopy number) return boolean is

   v_published_flag ota_learning_objects.published_flag%type;
   v_starting_url ota_learning_objects.starting_url%type;
   v_start_date_active    ota_learning_objects.start_date_active%type;
   v_end_date_active	  ota_learning_objects.end_date_active%type;

begin
   select   published_flag,
		starting_url,
		start_date_active,
		end_date_active
   into     v_published_flag,
		v_starting_url,
		v_start_date_active,
		v_end_date_active
   from     ota_learning_objects
   where    learning_object_id = p_lo_id;

   if v_published_flag = 'N' then
      p_reason := LO_REASON_NOT_PUBLISHED;
   elsif v_starting_url is null then
      p_reason := LO_REASON_NO_STARTING_URL;
   elsif v_start_date_active is not null and sysdate < v_start_date_active then
	p_reason := LO_REASON_NOT_STARTED;
   elsif v_end_date_active is not null and v_end_date_active < sysdate then
	p_reason := LO_REASON_EXPIRED;
   else
      p_reason := LO_REASON_NO_REASON;
   end if;

   return (p_reason = LO_REASON_NO_REASON);
exception
   when NO_DATA_FOUND then
      p_reason := LO_REASON_NO_SUCH_LO;
      return false;
end lo_is_attemptable;


function lo_is_in_event(
   p_event_id ota_events.event_id%type,
   p_lo_id ota_learning_objects.learning_object_id%type) return boolean is

   v_dummy char(1);
   v_root_lo_id ota_learning_objects.learning_object_id%type;
begin
   select   o.learning_object_id
   into     v_root_lo_id
   from     ota_events e, ota_offerings o
   where    e.event_id = p_event_id and
            e.parent_offering_id = o.offering_id;

   select      'X'
   into        v_dummy
   from        ota_learning_objects
   where       learning_object_id = p_lo_id
   start with  learning_object_id = v_root_lo_id
   connect by  parent_learning_object_id = prior learning_object_id;

   return true;
exception
   when NO_DATA_FOUND then
      return false;
end lo_is_in_event;


function user_meets_prerequisites(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type) return boolean is

--Commented for Bug#3582893
-- The cursor below is replaced with two cursor since the below query causes a Full Table Scan
/*
   cursor csr_chk_prereqs is
   select  1
   from    ota_prerequisites preq,
           ota_performances perf
   where   preq.parent_object_id = p_lo_id and
           preq.object_id = perf.learning_object_id(+) and
           perf.user_id(+) = p_user_id and
           perf.user_type(+) = p_user_type and
           nvl(perf.lesson_status, 'N') not in ('P', 'C');

   l_found number;
   l_return boolean;
begin
   open csr_chk_prereqs;
   fetch csr_chk_prereqs into l_found;
   l_return := csr_chk_prereqs%notfound;
   close csr_chk_prereqs;
   return l_return;
 */
CURSOR csr_get_prereqs IS
  SELECT object_id
  FROM ota_prerequisites
  where parent_object_id = p_lo_id
    and parent_type = 'LO';

CURSOR csr_get_performances(csr_lo_id NUMBER) IS
  SELECT 1
  FROM ota_performances
  WHERE learning_object_id = csr_lo_id
   AND user_id = p_user_id
   AND user_type = p_user_type
   AND lesson_status in ('P', 'C');

   l_found number;
   l_return boolean := TRUE;
begin
   FOR rec IN csr_get_prereqs
   LOOP
    IF csr_get_performances%ISOPEN THEN
        CLOSE csr_get_performances;
    END IF;
    OPEN csr_get_performances(rec.object_id);
     FETCH csr_get_performances INTO l_found;
     IF csr_get_performances%NOTFOUND THEN
        l_return := FALSE;
        CLOSE csr_get_performances;
       exit;
     END IF;
    END LOOP;
    IF csr_get_performances%ISOPEN THEN
        CLOSE csr_get_performances;
    END IF;
    return l_return;
end user_meets_prerequisites;


function user_exceeded_attempt_limit(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return boolean is

   v_max_attempts ota_tests.max_attempts%type;
   v_user_attempts number;
begin
   begin
      select   t.max_attempts
      into     v_max_attempts
      from     ota_tests t, ota_learning_objects lo
      where    lo.learning_object_id = p_lo_id and
               lo.test_id = t.test_id;
   exception
      when NO_DATA_FOUND then -- the LO is not a test, so no attempt limit exists
         return false;
   end;

   -- The LO is a test... if no max attempts return false immediately.
   if v_max_attempts is null then
      return false;
   else
      -- Count the user's attempts
      begin
         select   count(*)
         into     v_user_attempts
         from     ota_attempts a, ota_tests t
         where    a.user_id = p_user_id and
                  a.user_type = p_user_type and
                  a.learning_object_id = p_lo_id and
                  nvl(a.cert_prd_enrollment_id, -1) = nvl(p_cert_prd_enrollment_id, -1) and
                  a.test_id = t.test_id and
                  a.initialized_flag = 'Y' and
                  a.attempt_type <> 'I' and
                  ((a.suspend_data is null and
                    t.resume_flag  = 'Y' and
                    a.internal_state <> 'A' and
                    (a.suspend_data is null or a.suspend_data <> 'I')) or
                  (t.resume_flag = 'N' and (a.suspend_data is null or a.suspend_data <> 'I')));
      exception
         when NO_DATA_FOUND then
            -- No attempts, can't have exceeded the limit
            return false;
      end;

      return v_user_attempts >= v_max_attempts;
   end if;
end user_exceeded_attempt_limit;


function get_next_attempt_date_for_lo(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return date is

    v_earliest_attempt_date     date;
begin
   select nvl(max(a.timestamp), sysdate) + nvl(t.duration_between_attempt, 0)
   into   v_earliest_attempt_date
   from   ota_tests t,
		      ota_attempts a
   where t.test_id = a.test_id
     and a.initialized_flag = 'Y'
     and ((t.resume_flag  = 'Y'
           and a.internal_state <> 'A'
           and (a.suspend_data is null or a.suspend_data <> 'I'))
       OR (t.resume_flag = 'N'
           and (a.suspend_data is null or a.suspend_data <> 'I')))
     and a.learning_object_id = p_lo_id
     and a.user_id = p_user_id
     and a.user_type = p_user_type
     and nvl(p_cert_prd_enrollment_id, -1) = nvl(a.cert_prd_enrollment_id, -1)
   group by t.test_id,t.max_attempts, t.duration_between_attempt;

   return v_earliest_attempt_date;
exception
   /* this is NOT a test, or there are no attempts */
   when NO_DATA_FOUND then
   	return null;

   when others then
	 return null;
end get_next_attempt_date_for_lo;


function user_must_wait_to_attempt(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return boolean is

   v_earliest_attempt_date date;
begin
   v_earliest_attempt_date := get_next_attempt_date_for_lo(
      p_lo_id,
      p_user_id,
      p_user_type,
      p_cert_prd_enrollment_id);

   return (v_earliest_attempt_date is not null and sysdate < v_earliest_attempt_date);
end user_must_wait_to_attempt;


function user_can_attempt_lo(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null,
   p_reason out nocopy number) return boolean is
begin
   if not lo_is_attemptable(p_lo_id, p_launch_type, p_reason) then
      return false;
   end if;

   -- Instructors need not meet prerequisites because their performance is never
   -- recorded (therefore they CAN'T meet them).  Also, instructors are not subject
   -- to attempt limits or waits between attempts, although their attempts would
   -- never be counted anyway.
   if p_launch_type = 'INSTRUCTOR' then
      return true;
   else
      if not user_meets_prerequisites(p_lo_id, p_user_id, p_user_type) then
         p_reason := LO_REASON_PREREQS_NOT_MET;
         return false;
      end if;

      if user_exceeded_attempt_limit(p_lo_id, p_user_id, p_user_type, p_cert_prd_enrollment_id) then
         p_reason := LO_REASON_ATTEMPTS_EXCEEDED;
         return false;
      end if;

      if user_must_wait_to_attempt(p_lo_id, p_user_id, p_user_type, p_cert_prd_enrollment_id) then
         p_reason := LO_REASON_DURATION_NOT_MET;
         return false;
      end if;
   end if;

   return true;
end user_can_attempt_lo;


function user_can_attempt_lo(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type default '',
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return varchar2 is

   l_reason number;
begin
   if user_can_attempt_lo(p_lo_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enrollment_id, l_reason) then
      return 'Y';
   else
      return 'N';
   end if;
end user_can_attempt_lo;


function user_can_attempt_lo_3(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null,
   p_reason out nocopy number) return boolean is
begin
   if not lo_is_in_event(p_event_id, p_lo_id) then
      p_reason := LO_REASON_NOT_IN_EVENT;
      return false;
   end if;

   if not user_can_attempt_lo(p_lo_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enrollment_id, p_reason) then
      return false;
   end if;

   return true;
end user_can_attempt_lo_3;

function lo_is_in_cert(
   p_cert_prd_enroll_id ota_cert_mbr_enrollments.cert_prd_enrollment_id%type,
   p_lo_id ota_learning_objects.learning_object_id%type) return boolean is

 cursor root_los(p_cert_prd_enroll_id ota_cert_mbr_enrollments.cert_prd_enrollment_id%type) is
   select   o.learning_object_id
   from     ota_offerings o, ota_certification_members cm, ota_cert_mbr_enrollments cme
   where    o.activity_version_id = cm.object_id
            and cm.certification_member_id = cme.cert_member_id
            and cme.cert_prd_enrollment_id = p_cert_prd_enroll_id;

   cursor child_los(p_lo_id ota_learning_objects.learning_object_id%type,
                    p_root_lo_id ota_learning_objects.learning_object_id%type) is
     select      learning_object_id
     from        ota_learning_objects
     where       learning_object_id = p_lo_id
     start with  learning_object_id = p_root_lo_id
     connect by  parent_learning_object_id = prior learning_object_id;

begin

   for a_root_lo in root_los(p_cert_prd_enroll_id) loop
      for a_child_lo in child_los(p_lo_id, a_root_lo.learning_object_id) loop
        return true;
     end loop;
   end loop;

   return false;

end lo_is_in_cert;

function user_can_attempt_lo(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enroll_id ota_attempts.cert_prd_enrollment_id%type,
   p_reason out nocopy number) return boolean is
begin
   if p_cert_prd_enroll_id is not null and not lo_is_in_cert(p_cert_prd_enroll_id, p_lo_id) then
      p_reason := LO_REASON_LO_NOT_IN_CERT;
      return false;
   end if;

   if not user_can_attempt_lo_3(p_lo_id, p_event_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enroll_id, p_reason) then
      return false;
   end if;

   return true;
end user_can_attempt_lo;

function event_is_attemptable(
   p_event_id ota_events.event_id%type,
   p_date date,
   p_launch_type ota_attempts.launch_type%type,
   p_reason out nocopy number) return boolean is

   v_course_start_date ota_events.course_start_date%type;
   v_course_start_time ota_events.course_start_time%type;
   v_course_end_date ota_events.course_end_date%type;
   v_course_end_time ota_events.course_end_time%type;
   v_is_instructor boolean;
   v_course_started boolean;
   v_course_expired boolean;
begin
   p_reason := EVENT_REASON_NO_REASON;

   select   course_start_date, course_start_time, course_end_date, course_end_time
   into     v_course_start_date, v_course_start_time, v_course_end_date, v_course_end_time
   from     ota_events
   where    event_id = p_event_id;

   v_course_started := (v_course_start_date is null or p_date >= v_course_start_date);
   v_course_expired := (v_course_end_date is not null and p_date > v_course_end_date);
   v_is_instructor := (p_launch_type = 'INSTRUCTOR');

   -- Neither learners not instructors can play a course past its end date.
   if v_course_expired then
      p_reason := EVENT_REASON_EXPIRED;

   -- Only instructors can play a course before it starts.
   elsif not v_course_started and not v_is_instructor then
      p_reason := EVENT_REASON_NOT_STARTED;

   end if;

   return (p_reason = EVENT_REASON_NO_REASON);
exception
   when NO_DATA_FOUND then
      p_reason := EVENT_REASON_NO_SUCH_EVENT;
      return false;
end event_is_attemptable;


function user_is_enrolled(
  p_event_id ota_events.event_id%type,
  p_user_id fnd_user.user_id%type,
  p_user_type ota_attempts.user_type%type,
  p_date date,
  p_reason out nocopy number) return boolean is

  cursor person_bookings(
    p_event_id ota_events.event_id%type,
    p_person_id per_all_people.person_id%type) is
  select  1
  from    ota_delegate_bookings book,
          ota_booking_status_types stype
  where   book.delegate_person_id = p_person_id and
          book.event_id = p_event_id and
          book.booking_status_type_id = stype.booking_status_type_id and
          stype.type in ('P', 'A' ,'E');

  cursor contact_bookings(
    p_event_id ota_events.event_id%type,
    p_contact_id per_all_people.person_id%type) is
  select  1
  from    ota_delegate_bookings book,
          ota_booking_status_types stype
  where   book.delegate_contact_id = p_contact_id and
          book.event_id = p_event_id and
          book.booking_status_type_id = stype.booking_status_type_id and
          stype.type in ('P', 'A', 'E');

    cursor get_delegate_contact(
     p_party_id hz_parties.party_id%type) is
   select acct_role.cust_account_role_id
   from   hz_cust_account_roles acct_role,
          hz_relationships rel,
          hz_cust_accounts role_acct
   where  acct_role.party_id = rel.party_id and
          acct_role.role_type = 'CONTACT' and
          acct_role.cust_account_id = role_acct.cust_account_id and
          role_acct.party_id = rel.object_id and
          rel.subject_id = p_party_id and
          rel.subject_table_name = 'HZ_PARTIES' and
          rel.object_table_name = 'HZ_PARTIES';

 a_contact   get_delegate_contact%ROWTYPE;
begin
  p_reason := EVENT_REASON_NO_REASON;

  if p_user_type = 'E' then
    for a_booking in person_bookings(p_event_id, p_user_id) loop
      return true;
    end loop;
  else
   for a_contact in get_delegate_contact(p_user_id) loop
    for a_booking in contact_bookings(p_event_id,nvl(a_contact.cust_account_role_id, get_contact_id_for_party(p_user_id))) loop
      return true;
    end loop;
   end loop;
  end if;

  -- If we fall through, the user is not enrolled
  p_reason := EVENT_REASON_NOT_ENROLLED;
  return false;
end user_is_enrolled;


function user_is_instructor(
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_date date,
   p_reason out nocopy number) return boolean is
begin

  if p_user_type = 'E' then

    for an_instructor in (
      select 1 as dummy
      from
      ota_suppliable_resources tsr,
      ota_resource_bookings trb
      where
      trb.forum_id is null and
      trb.chat_id is null and
      tsr.trainer_id = p_user_id and
      trb.supplied_resource_id = tsr.supplied_resource_id and
      (trb.event_id = p_event_id or
       trb.event_id in ( select ses.event_id
			 from ota_events ses
			 where ses.parent_event_id = p_event_id
			 and ses.event_type = 'SESSION')
      ) and
      tsr.resource_type = 'T') loop

      p_reason := EVENT_REASON_NO_REASON;
      return true;
    end loop;

  end if;

  -- If we fall through, the user is not an instructor.
  p_reason := EVENT_REASON_NOT_INSTRUCTOR;
  return false;
end user_is_instructor;


function user_can_attempt_event(
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_reason out nocopy number) return varchar2 is

   v_now date := trunc(sysdate);--Bug 3554773
begin
   if not event_is_attemptable(p_event_id, v_now, p_launch_type, p_reason) then
      return 'N';
   end if;

   if p_launch_type = 'INSTRUCTOR' then
      if not user_is_instructor(p_event_id, p_user_id, p_user_type, v_now, p_reason) then
         return 'N';
      end if;
   else
      if not user_is_enrolled(p_event_id, p_user_id, p_user_type, v_now, p_reason) then
         return 'N';
      end if;
   end if;

   p_reason := EVENT_REASON_NO_REASON;
   return 'Y';
end user_can_attempt_event;


function cert_is_attemptable(
   p_cert_prd_enroll_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
   p_date date,
   p_reason out nocopy number) return boolean is

   v_cert_start_date ota_certifications_b.start_date_active%type;
   v_cert_end_date ota_certifications_b.end_date_active%type;
   v_cert_prd_enroll_start ota_cert_prd_enrollments.cert_period_start_date%type;
   v_cert_prd_enroll_end ota_cert_prd_enrollments.cert_period_end_date%type;
begin
   select   c.start_date_active, c.end_date_active, cpe.cert_period_start_date, cpe.cert_period_end_date
   into     v_cert_start_date, v_cert_end_date, v_cert_prd_enroll_start, v_cert_prd_enroll_end
   from     ota_certifications_b c, ota_cert_prd_enrollments cpe, ota_cert_enrollments ce
   where    cpe.cert_prd_enrollment_id = p_cert_prd_enroll_id and
            cpe.cert_enrollment_id = ce.cert_enrollment_id and
            ce.certification_id = c.certification_id;

   if v_cert_start_date is not null and p_date < v_cert_start_date then
      p_reason := CERT_REASON_NOT_STARTED;
   elsif v_cert_end_date is not null and p_date > v_cert_end_date then
      p_reason := CERT_REASON_EXPIRED;
   elsif v_cert_prd_enroll_start is not null and p_date < v_cert_prd_enroll_start then
      p_reason := CERT_PRD_REASON_NOT_STARTED;
   elsif v_cert_prd_enroll_end is not null and p_date > v_cert_prd_enroll_end then
      p_reason := CERT_PRD_REASON_EXPIRED;
   else
      p_reason := CERT_REASON_NO_REASON;
   end if;

   return (p_reason = CERT_REASON_NO_REASON);
exception
   when NO_DATA_FOUND then
      p_reason := CERT_REASON_NO_SUCH_CERT;
      return false;
end cert_is_attemptable;

function user_is_enrolled_in_cert(
   p_cert_prd_enroll_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_date date,
   p_reason out nocopy number) return boolean is

   v_cert_unsubscribe_date ota_cert_enrollments.unenrollment_date%type;
   --v_cert_enr_user_id ota_cert_enrollments.person_id%type;
   v_cert_enr_user_id number;
   l_user_id number;
begin
   select   ce.unenrollment_date, nvl(ce.person_id, ce.contact_id)
   into     v_cert_unsubscribe_date, v_cert_enr_user_id
   from     ota_cert_prd_enrollments cpe, ota_cert_enrollments ce
   where    cpe.cert_prd_enrollment_id = p_cert_prd_enroll_id and
            cpe.cert_enrollment_id = ce.cert_enrollment_id;

   --bug 4725513
   --for ext learner call get_contact_id_for_party(p_user_id)
   if p_user_type = 'E' then
      l_user_id := p_user_id;
   else
      l_user_id := get_contact_id_for_party(p_user_id);
   end if;

   if v_cert_unsubscribe_date is not null then
      p_reason := CERT_REASON_UNSUBSCRIBED;
   elsif (v_cert_enr_user_id is not null) and (not v_cert_enr_user_id = l_user_id) then
      p_reason := CERT_REASON_INVALID_USER;
   else
      p_reason := CERT_REASON_NO_REASON;
   end if;
   return (p_reason = CERT_REASON_NO_REASON);
exception
   when NO_DATA_FOUND then
      p_reason := CERT_REASON_NO_SUCH_CERT;
      return false;
end user_is_enrolled_in_cert;

function user_can_attempt_cert(
   p_cert_prd_enroll_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_reason out nocopy number) return varchar2 is

   v_now date := trunc(sysdate);--Bug 3554773
begin

   if not cert_is_attemptable(p_cert_prd_enroll_id, v_now, p_reason) then
      return 'N';
   end if;

   if not user_is_enrolled_in_cert(p_cert_prd_enroll_id, p_user_id, p_user_type, v_now, p_reason) then
       return 'N';
   end if;

   p_reason := CERT_REASON_NO_REASON;
   return 'Y';
end user_can_attempt_cert;


function find_previous_lo_id(
   p_start ota_learning_objects.learning_object_id%type,
   p_current ota_learning_objects.learning_object_id%type,
   p_current_starting_url ota_learning_objects.starting_url%type,
   p_previous in out nocopy ota_learning_objects.learning_object_id%type) return boolean is

   cursor children(p_lo_id ota_learning_objects.learning_object_id%type) is
      select   learning_object_id, starting_url
      from     ota_learning_objects
      where    parent_learning_object_id = p_lo_id and
               published_flag = 'Y'
      order by child_seq asc;
begin
   if p_current = p_start then
      return true;
   end if;

   if p_current_starting_url is not null then
      p_previous := p_current;
   end if;

   for a_child in children(p_current) loop
      if find_previous_lo_id(p_start, a_child.learning_object_id, a_child.starting_url, p_previous) then
	 return true;
      end if;
   end loop;

   return false;
end find_previous_lo_id;


function get_previous_lo_id(
   p_root_lo_id ota_learning_objects.learning_object_id%type,
   p_starting_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return ota_learning_objects.learning_object_id%type is

   v_starting_url ota_learning_objects.starting_url%type :=null;
   v_previous_lo_id ota_learning_objects.learning_object_id%type := null;
   v_reason number;
begin
   select   starting_url
   into     v_starting_url
   from     ota_learning_objects
   where    learning_object_id = p_root_lo_id;

   if find_previous_lo_id(p_starting_lo_id, p_root_lo_id, v_starting_url, v_previous_lo_id) then
      if user_can_attempt_lo(v_previous_lo_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enrollment_id, v_reason) then
         return v_previous_lo_id;
      else
         return get_previous_lo_id(p_root_lo_id, v_previous_lo_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enrollment_id);
      end if;
   else
      return null;
   end if;
end get_previous_lo_id;


function get_previous_event_lo_id(
   p_event_id ota_events.event_id%type,
   p_starting_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return ota_learning_objects.learning_object_id%type is

   v_root_lo_id ota_learning_objects.learning_object_id%type;
begin
   select   o.learning_object_id
   into     v_root_lo_id
   from     ota_events e, ota_offerings o
   where    e.event_id = p_event_id and
            e.parent_offering_id = o.offering_id;

   return get_previous_lo_id(v_root_lo_id, p_starting_lo_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enrollment_id);
end get_previous_event_lo_id;


function find_next_lo_id(
   p_start ota_learning_objects.learning_object_id%type,
   p_current ota_learning_objects.learning_object_id%type,
   p_current_starting_url ota_learning_objects.starting_url%type,
   p_found_start in out nocopy boolean) return ota_learning_objects.learning_object_id%type is

   cursor children(p_lo_id ota_learning_objects.learning_object_id%type) is
      select   learning_object_id, starting_url
      from     ota_learning_objects
      where    parent_learning_object_id = p_lo_id and
               published_flag = 'Y'
      order by child_seq asc;
   v_result ota_learning_objects.learning_object_id%type;
begin
   if (p_found_start or p_start is null) and p_current_starting_url is not null then
      return p_current;
   end if;

   if p_current = p_start then
      p_found_start := true;
   end if;

   for a_child in children(p_current) loop
      v_result := find_next_lo_id(p_start, a_child.learning_object_id, a_child.starting_url, p_found_start);
      if v_result is not null then
         return v_result;
      end if;
   end loop;

   return null;
end find_next_lo_id;


function get_next_lo_id(
   p_root_lo_id ota_learning_objects.learning_object_id%type,
   p_starting_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return ota_learning_objects.learning_object_id%type is


   v_starting_url ota_learning_objects.starting_url%type := null;
   v_next_lo_id ota_learning_objects.learning_object_id%type := null;
   v_false boolean := false;
   v_reason number;
begin
     return get_next_lo_id(p_root_lo_id,null, p_starting_lo_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enrollment_id);
end get_next_lo_id;



function get_next_lo_id(
   p_root_lo_id ota_learning_objects.learning_object_id%type,
   p_root_starting_url ota_learning_objects.starting_url%type,
   p_starting_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return ota_learning_objects.learning_object_id%type is

   v_starting_url ota_learning_objects.starting_url%type := null;
   v_next_lo_id ota_learning_objects.learning_object_id%type := null;
   v_false boolean := false;
   v_reason number;
begin

   if p_root_starting_url is not null then
        v_starting_url := p_root_starting_url;
   else
       select   starting_url
       into     v_starting_url
       from     ota_learning_objects
       where    learning_object_id = p_root_lo_id;
   end if;

  v_next_lo_id := find_next_lo_id(p_starting_lo_id, p_root_lo_id, v_starting_url, v_false);
   if v_next_lo_id is not null then
      if user_can_attempt_lo(v_next_lo_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enrollment_id, v_reason) then
         return v_next_lo_id;
      else
         return get_next_lo_id(p_root_lo_id, v_starting_url, v_next_lo_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enrollment_id);
      end if;
   else
      return null;
   end if;
end get_next_lo_id;


function get_next_event_lo_id(
   p_event_id ota_events.event_id%type,
   p_starting_lo_id ota_learning_objects.learning_object_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return ota_learning_objects.learning_object_id%type is

   v_root_lo_id ota_learning_objects.learning_object_id%type;
begin
   select   o.learning_object_id
   into     v_root_lo_id
   from     ota_events e, ota_offerings o
   where    e.event_id = p_event_id and
            e.parent_offering_id = o.offering_id;

   return get_next_lo_id(v_root_lo_id, p_starting_lo_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enrollment_id);
end get_next_event_lo_id;


function get_most_recent_lo_id(
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enroll_id ota_attempts.cert_prd_enrollment_id%type) return ota_learning_objects.learning_object_id%type is

   cursor ordered_los(
      p_root_lo_id ota_learning_objects.learning_object_id%type,
      p_user_id fnd_user.user_id%type,
      p_user_type ota_attempts.user_type%type,
      p_cert_prd_enroll_id ota_attempts.cert_prd_enrollment_id%type) is
      select   a.learning_object_id, max(a.attempt_id) max_attempt
      from     ota_attempts a,
               (select     learning_object_id, starting_url
               from        ota_learning_objects
               start with  learning_object_id = p_root_lo_id
               connect by  parent_learning_object_id = prior learning_object_id) lo
      where    a.user_id = p_user_id and
               a.user_type = p_user_type and
               a.learning_object_id = lo.learning_object_id and
               lo.starting_url is not null and
               ((p_cert_prd_enroll_id is null and a.cert_prd_enrollment_id is null)  OR
                (p_cert_prd_enroll_id is not null and a.cert_prd_enrollment_id = p_cert_prd_enroll_id)
               )
      group by a.learning_object_id
      order by max_attempt desc;

   v_root_lo_id ota_learning_objects.learning_object_id%type;
   v_reason number;
begin
   select   o.learning_object_id
   into     v_root_lo_id
   from     ota_events e, ota_offerings o
   where    e.event_id = p_event_id and
            e.parent_offering_id = o.offering_id;


   for a_lo in ordered_los(v_root_lo_id, p_user_id, p_user_type, p_cert_prd_enroll_id) loop
      if user_can_attempt_lo(a_lo.learning_object_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enroll_id, v_reason) then
         return a_lo.learning_object_id;
      end if;
   end loop;

   return get_first_lo_id(p_event_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enroll_id);
end get_most_recent_lo_id;


function get_first_lo_id(
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return ota_learning_objects.learning_object_id%type is

   v_root_lo_id ota_learning_objects.learning_object_id%type;
   v_first_lo_id ota_learning_objects.learning_object_id%type;
   v_reason number;
begin
   select   o.learning_object_id
   into     v_root_lo_id
   from     ota_events e, ota_offerings o
   where    e.event_id = p_event_id and
            e.parent_offering_id = o.offering_id;

   return get_next_lo_id(v_root_lo_id, null, p_user_id, p_user_type, p_launch_type, p_cert_prd_enrollment_id);
end get_first_lo_id;

function get_jump_lo_id(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_reason out nocopy number) return ota_learning_objects.learning_object_id%type is
begin
   return get_jump_lo_id(p_lo_id, p_event_id, p_user_id, p_user_type, p_launch_type, null, p_reason);
end get_jump_lo_id;

function get_jump_lo_id(
   p_lo_id ota_learning_objects.learning_object_id%type,
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type,
   p_cert_prd_enroll_id ota_attempts.cert_prd_enrollment_id%type,
   p_reason out nocopy number) return ota_learning_objects.learning_object_id%type is
begin
   if user_can_attempt_lo(p_lo_id, p_event_id, p_user_id, p_user_type, p_launch_type, p_cert_prd_enroll_id, p_reason) then
      return p_lo_id;
   else
      return null;
   end if;
end get_jump_lo_id;

--7574667
function get_lo_type(
    p_lo_id ota_learning_objects.learning_object_id%type) return varchar2 is

    --7622768
    cursor lo_type is
    select nvl(test_type_flag,'LO')
    from  ota_tests ot,
          ota_learning_objects lo
    where ot.test_id(+) = lo.test_id
    and   lo.learning_object_id = p_lo_id;

type_flag varchar2(10);
begin
    open lo_type;
    fetch lo_type into type_flag;
    close lo_type;
    if type_flag is null then
        return 'LO';
    end if;
    return type_flag;

end get_lo_type;


function user_can_attempt_event(
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type) return varchar2 is

   l_reason number;
begin
   return user_can_attempt_event(p_event_id, p_user_id, p_user_type, '', l_reason);
end user_can_attempt_event;


function user_can_attempt_event(
   p_event_id ota_events.event_id%type,
   p_user_id fnd_user.user_id%type,
   p_user_type ota_attempts.user_type%type,
   p_launch_type ota_attempts.launch_type%type) return varchar2 is

   l_reason number;
begin
   return user_can_attempt_event(p_event_id, p_user_id, p_user_type, p_launch_type, l_reason);
end user_can_attempt_event;


-- Author: sbhullar
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
-- p_active_cert_flag
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
RETURN varchar2
IS
    l_proc VARCHAR2(72) := g_package||'get_lo_title_for_tree';
    l_lo_name varchar(240);
    l_lo_status varchar(80);
    l_lo_time number;
    l_lo_score number;
    l_lo_status_icon varchar(30);
    l_Seconds number;
    l_Minutes number;
    l_Hours number;
    l_formatted_hour varchar(20) := '';
    l_formatted_min varchar(20) := '';
    l_formatted_sec varchar(20) := '';
    l_formatted_time varchar(20) := '';
    l_return_tree_title varchar(500) := '';
    l_max_performance_id  ota_performances.performance_id%type;
    l_tst_grade_flag ota_tests.grade_flag%TYPE;
    l_var_score      VARCHAR2(100);
    l_lo_completed_date VARCHAR2(100);
    l_lo_completed_time VARCHAR2(10);
    l_lo_completed_date_tz VARCHAR2(100);
    l_lo_lesson_status ota_performances.lesson_status%type;

CURSOR c_get_lo_tree_link(p_performance_id in number) is
Select
olo.name Name,
nvl(hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS',opf.lesson_status),
hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS','N')) Status,
nvl(opf.time,0) Time,
opf.score Score,
decode(opf.lesson_status
	  ,'C','player_status_c.gif'
	  ,'F','player_status_f.gif'
	  ,'I','player_status_i.gif'
	  ,'P','player_status_p.gif'
	  ,'N','player_status_n.gif'
	  ,null,DECODE(OTA_LO_UTILITY.user_can_attempt_lo(olo.learning_object_id,p_user_id,p_user_type),
           'N','player_status_no_prereq.gif',
           'Y','player_status_n.gif')
	  ,'player_status_n.gif') STATUS_ICON
          , tst.grade_flag
          , to_char(opf.completed_date)
          , to_char(opf.completed_date, 'HH24:MI:SS')
          , opf.lesson_status
          , ota_timezone_util.get_date_time(trunc(opf.completed_date), to_char(opf.completed_date, 'HH24:MI:SS'), 'Y', ota_timezone_util.get_server_timezone_code, 'HH24:MI:SS') Comp_Date_Tz
From OTA_LEARNING_OBJECTS olo, OTA_PERFORMANCES opf,
     OTA_TESTS tst
Where
     olo.learning_object_id = opf.learning_object_id(+)
     AND tst.test_id(+) = olo.test_id
     And olo.Learning_object_id = p_lo_id
     And opf.User_id(+) = p_user_id
     And opf.User_type(+) = p_user_type
     AND opf.performance_id(+) = p_performance_id
     AND cert_prd_enrollment_id(+) is null;

CURSOR c_max_performance_id is
Select max(per.performance_id)
From ota_performances per
Where per.learning_object_id(+) = p_lo_id
      And per.user_id(+) = p_user_id
      And per.user_type(+) = p_user_type
      AND per.cert_prd_enrollment_id(+) is null;

Begin
   hr_utility.set_location('Entering :'||l_proc,5);

   open c_max_performance_id;
   fetch c_max_performance_id into l_max_performance_id;
   close c_max_performance_id;

   if ( l_max_performance_id is null ) then
        l_max_performance_id := -1;
   end if;

   open c_get_lo_tree_link(l_max_performance_id);
   fetch c_get_lo_tree_link into l_lo_name,l_lo_status,l_lo_time,l_lo_score,l_lo_status_icon , l_tst_grade_flag, l_lo_completed_date, l_lo_completed_time, l_lo_lesson_status, l_lo_completed_date_tz;
   close c_get_lo_tree_link;

   If ( p_mode = 1) Then
       l_lo_time := round(l_lo_time);

       l_Seconds := l_lo_time mod 60;
       l_Minutes := floor(l_lo_time / 60);
       l_Hours := floor(l_Minutes/60);
       l_Minutes := l_Minutes - l_Hours * 60;

       If (l_Hours < 10) Then
           l_formatted_hour := '0' || l_Hours;
       Else
           l_formatted_hour := l_Hours;
       End If;

       If (l_Minutes < 10) Then
           l_formatted_min := '0' || l_Minutes;
       Else
           l_formatted_min := l_Minutes;
       End If;

       If (l_Seconds < 10) Then
           l_formatted_sec := '0' || l_Seconds;
       Else
           l_formatted_sec := l_Seconds;
       End If;

       fnd_message.set_name('OTA', 'OTA_443358_SRCH_LO_TIME');
       fnd_message.set_token ('HOUR', l_formatted_hour);
       fnd_message.set_token ('MIN', l_formatted_min);
       fnd_message.set_token ('SEC', l_formatted_sec);
       l_formatted_time := fnd_message.get();

       if p_active_cert_flag = 'Y' then
       	   fnd_message.set_name('OTA', 'OTA_443968_SRCH_TREE_TITLE3');
       elsif ((l_lo_score is null) or (l_lo_score < 0)) Then
           fnd_message.set_name('OTA', 'OTA_443453_SRCH_TREE_TITLE2');
       Else
           --Added for bug 3550407
           IF ( l_tst_grade_flag = 'P' ) THEN
              l_var_score := l_lo_score||'%';
          ELSE
              l_var_score := l_lo_score;
           END IF;

           fnd_message.set_name('OTA', 'OTA_443357_SRCH_TREE_TITLE');
           fnd_message.set_token ('SCORE', l_var_score);
       End If;

       If ( (l_lo_lesson_status = 'C' or l_lo_lesson_status = 'P')
             and l_lo_completed_date is not null ) Then
            l_lo_status := l_lo_status || ' ' || l_lo_completed_date_tz;
       End If;

       --if this is part of active cert prd, return status as "Not Applicable"
       if p_active_cert_flag = 'Y' then
       	  fnd_message.set_token ('LO_NAME', l_lo_name);
          fnd_message.set_token ('STATUS', hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS','D'));
       else
	  fnd_message.set_token ('LO_NAME', l_lo_name);
	  fnd_message.set_token ('STATUS', l_lo_status);
	  fnd_message.set_token ('TIME', l_formatted_time);
       end if;

       l_return_tree_title := fnd_message.get();
   Else
       --if this is part of active cert prd, return icon empty circle used for "Not Attempted"
       if p_active_cert_flag = 'Y' then
       	  l_return_tree_title := 'player_status_n.gif';
       else
       	  l_return_tree_title := l_lo_status_icon;
       end if;

   End If;

   hr_utility.set_location('Leaving :'||l_proc,10);
   RETURN l_return_tree_title;
   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

           RETURN l_return_tree_title;
End get_lo_title_for_tree;

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
   p_chk_active_cert_flag varchar2 default 'N') return varchar2 is


   v_number_of_los     		number(10);
   v_solo_lo_id 			ota_learning_objects.learning_object_id%type := null;
   v_published_flag		ota_learning_objects.published_flag%type := null;
   v_first_lo     		ota_learning_objects.learning_object_id%type := null;
   v_play_button_for_test 	varchar2(100) := null;
   v_rco_id 			ota_activity_versions.rco_id%type := null;
   v_offering_id 		ota_events.offering_id%type := null;

   l_reason 			number;
   l_sysdate                    date;
   l_course_start_time          ota_events.course_start_time%type;
   l_course_end_time            ota_events.course_end_time%type;
   l_course_start_date          ota_events.course_start_date%type;
   l_course_end_date            ota_events.course_end_date%type;
   l_timezone			ota_events.timezone%type;

   CURSOR c_event_time_info is
   Select course_start_time, course_end_time, timezone
   From ota_events
   Where event_id = p_event_id;

  l_cert_prd_enrollment_ids varchar2(4000) := null;
  l_person_id ota_cert_enrollments.person_id%type := null;
  l_cert_prd_enrollment_id OTA_CERT_PRD_ENROLLMENTS.cert_prd_enrollment_id%type;
begin

	/*===============================================
	 * check if this is an Online class
	 *===============================================*/
	if p_online_flag <> 'Y' then
		return 'ENABLE_DETAIL';
	end if;


	/*===============================================
	 * user is logged in as manager
	 *===============================================*/
	if (p_is_manager = 'IS_MANAGER') then
		return 'ENABLE_DETAIL';
	end if;

	/*===============================================
	 * bug 3401855. play icon should be disabled when
         * enrollment status is Cancelled.
         * bug 3661345. Enrollment Status Validation should
         * be done before Class Dates Validation.
	 *===============================================*/
	if (p_enrollment_status_type = 'C') then
		return 'DISABLE_ENR_CANCELLED';
	end if;

	/*===============================================
	 * event is scheduled but not within time window
	 *===============================================*/
	open c_event_time_info;
	fetch c_event_time_info into l_course_start_time, l_course_end_time, l_timezone;
	close c_event_time_info;

	l_sysdate := ota_timezone_util.convert_date(sysdate, to_char(sysdate,'HH24:MI'), ota_timezone_util.get_server_timezone_code, l_timezone);

	if (p_event_type = 'SCHEDULED') then

                --Bug 5107276
		l_course_start_date := to_date(nvl(to_char(p_course_start_date,'YYYY/MM/DD'),'4712/12/31')||' '||nvl(l_course_start_time, '00:00'),'YYYY/MM/DD HH24:MI');
                l_course_end_date := to_date(nvl(to_char(p_course_end_date,'YYYY/MM/DD'),'4712/12/31')||' '||nvl(l_course_end_time, '23:59'),'YYYY/MM/DD HH24:MI');

                --l_sysdate := to_date(to_char(trunc(sysdate),'YYYY/MM/DD')||' '|| to_char(sysdate,'HH24:MI'),'YYYY/MM/DD HH24:MI');

		if l_sysdate < l_course_start_date then --Bug 3559931
			return 'DISABLE_BEFORE_START';
                end if;
		if l_course_end_date < l_sysdate then --Bug 3559931
			return 'DISABLE_AFTER_END';
		end if;
        elsif ( p_event_type = 'SELFPACED') then --bug 3559931
              if p_course_start_date is not null then
                 if trunc(l_sysdate) < p_course_start_date then
                    return 'DISABLE_BEFORE_START';
                 end if;
              end if;
              if p_course_end_date is not null then
                 if p_course_end_date < trunc(l_sysdate) then
                    return 'DISABLE_AFTER_END';
                 end if;
              end if;
	end if;

	/*===============================================
	 * if the rco_id is not null, integrate with external player
         * This condition needs to be on top to avoid unnecessary
         * checks of Lo, prerequisites etc..
	 *===============================================*/
	select a.rco_id
		 ,e.offering_id
	into   v_rco_id
		 ,v_offering_id
	from ota_activity_versions a, ota_events e
	where a.activity_version_id = e.activity_version_id
	and   e.event_id = p_event_id;

	if v_rco_id is not null and v_offering_id is not null then
		return 'ENABLE_EXTERNAL_PLAY';
	end if;


	/*===============================================
	 * check that this event contains only one LO
	 * if so get the id
	 *===============================================*/
	select count(learning_object_id)
		,sum(learning_object_id)
		,nvl(max(published_flag),'N')
	into  v_number_of_los
		,v_solo_lo_id
		,v_published_flag
	from ota_learning_objects
	start with learning_object_id =
 		(select learning_object_id
 		from  ota_offerings o
  			,ota_events  e
 	where o.offering_id = e.parent_offering_id
   	  and event_id = p_event_id)
	connect by parent_learning_object_id = prior learning_object_id;


	/*===============================================
	 * if there is only a single LO in the class then
	 *===============================================*/
	if v_number_of_los = 1 then

		/*===============================================
	 	* check that the LO is published
	 	*===============================================*/
		if v_published_flag <> 'Y' then
			return 'DISABLE_LO_UNPUBLISHED';
		end if;

		/*===============================================
	 	* check if it is a disabled test (assessment)
	 	*===============================================*/
		v_play_button_for_test := get_play_button_for_test(p_user_id, p_user_type, p_event_id, p_cert_prd_enrollment_id);

		if v_play_button_for_test is not null then
			return v_play_button_for_test;
		end if;

		/*===============================================
	 	* check if it is a disabled from an unmet prerequisite
	 	*===============================================*/

  		if not user_meets_prerequisites(v_solo_lo_id , p_user_id, p_user_type) then
			return 'DISABLE_UNMET_PREREQ';
		end if;

	end if;


	/*===============================================
	 * checks end dates and enrollment
	 *===============================================*/
	if user_can_attempt_event(p_event_id,p_user_id,p_user_type) = 'N' then
		return 'DISABLE_UNKNOWN';
	end if;

	/*===============================================
	 * Disable if there are no playable LOs
	 *===============================================*/
	v_first_lo   := get_first_lo_id(p_event_id, p_user_id, p_user_type, '',p_cert_prd_enrollment_id);

	if v_first_lo is null then
		return 'DISABLE_UNKNOWN';
	end if;

	if p_chk_active_cert_flag = 'Y' then
	   /*===============================================
	    * Disable if its part of active cert periods
	    *===============================================*/
	    if p_user_type is not null and p_user_type = 'E' then
	       l_person_id := p_user_id;
	    end if;

	    if(l_person_id is not null) then
	       open csr_active_cert_prd_person(p_event_id, l_person_id);
	       fetch csr_active_cert_prd_person into l_cert_prd_enrollment_id;
	       close csr_active_cert_prd_person;
	    else
           open csr_active_cert_prd_contact(p_event_id, p_contact_id);
	       fetch csr_active_cert_prd_contact into l_cert_prd_enrollment_id;
	       close csr_active_cert_prd_contact;
	    end if;

	    /*
        get_active_cert_prds(p_event_id,
				 l_person_id,
				 p_contact_id,
				 l_cert_prd_enrollment_ids);
        */

	    if l_cert_prd_enrollment_id is not null then
	       return 'DISABLE_CERTIFICATION';
	    end if;
	end if;

	/*===============================================
	 * no reason found to disable
	 *===============================================*/
	return 'ENABLE_PLAY';


exception
   when others then
	return 'ENABLE_PLAY';

end get_play_button;


function get_play_button_for_test(
   	p_user_id fnd_user.user_id%type,
   	p_user_type ota_attempts.user_type%type,
   	p_event_id ota_events.event_id%type,
    p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return varchar2 is

   v_lo_id ota_learning_objects.learning_object_id%type;
begin
   select  offr.learning_object_id
   into    v_lo_id
   from    ota_offerings offr, ota_events evt
   where   evt.event_id = p_event_id and
           evt.parent_offering_id = offr.offering_id;

 	/*===============================================
	 * if this is a single lo that is a test with
	 * no attempts remaining, disable the play
	 *===============================================*/
    if user_exceeded_attempt_limit(v_lo_id, p_user_id, p_user_type, p_cert_prd_enrollment_id) then
		  return 'DISABLE_MAX_ATTEMPTS';
	/*===============================================
	 * if this is a single lo that is a test and
	 * it is within the wait duration, disable the play
	 *===============================================*/
   	elsif user_must_wait_to_attempt(v_lo_id, p_user_id, p_user_type, p_cert_prd_enrollment_id) then
		  return 'DISABLE_WAIT_DURATION';
   	else
	/*===============================================
	 * no reason found to disable
	 *===============================================*/
		return null;
   	end if;

exception
   when others then
	    return null;
end get_play_button_for_test;

--bug8785933.Added for getting the sign/play button
function get_sign_eval_button(
    p_sign_eval_status OTA_DELEGATE_BOOKINGS.SIGN_EVAL_STATUS%TYPE
    ) return varchar2 is


l_symbol varchar2(100):=null;


begin

    case p_sign_eval_status
        when 'SD' then l_symbol:='DISABLE_M_SIGN_EVAL';
        when 'UD' then l_symbol:='DISABLE_SIGN';
        when 'MD' then l_symbol:='DISABLE_M_EVAL';
        when 'OD' then l_symbol:='DISABLE_V_EVAL';
        when 'VD' then l_symbol:='DISABLE_V_SIGN_EVAL';
        when 'SE' then l_symbol:='ENABLE_SIGN';
        when 'ME' then l_symbol:='ENABLE_EVAL';
        when 'UE' then l_symbol:='ENABLE_SIGN';
        when 'OE' then l_symbol:='ENABLE_EVAL';
        when 'VE' then l_symbol:='ENABLE_SIGN';
        when 'DD' then l_symbol:='SIGN_EVAL_DONE';
        when 'MC' then l_symbol:='EVAL_CLOSED';
        else l_symbol:='NO_SIGN_EVAL';
    end case;
    return l_symbol;


	exception
   when others then
	    return null;
end get_sign_eval_button;

--bug6683076.Added for getting the play button

function get_play_eval_button(
    p_event_id OTA_EVENTS.EVENT_ID%TYPE,
	p_user_id fnd_user.user_id%type,
    p_booking_status_type_id OTA_DELEGATE_BOOKINGS.BOOKING_STATUS_TYPE_ID%TYPE,
	p_object_id OTA_EVALUATIONS.OBJECT_ID%TYPE,
    p_object_type OTA_EVALUATIONS.OBJECT_TYPE%TYPE,
    p_mand_flag OTA_EVALUATIONS.EVAL_MANDATORY_FLAG%TYPE,
	p_test_id OTA_TESTS.TEST_ID%TYPE) return varchar2 is

l_is_mandatory boolean:= true;
l_is_attempted boolean:= false;
l_act_mandatory OTA_EVALUATIONS.EVAL_MANDATORY_FLAG%TYPE;
l_booking_status_type OTA_BOOKING_STATUS_TYPES.TYPE%TYPE;
l_attempt_id number;
l_act_eval_id OTA_EVALUATIONS.evaluation_id%TYPE;

CURSOR c_attempts_info is
   Select attempt_id
   From ota_attempts
   Where event_id = p_event_id
   and user_id = p_user_id
   and (act_eval_id = l_act_eval_id
   or  test_id = p_test_id)
   and attempt_status = 'C'          --bug#7574667
   and internal_state = 'F';         --bug#7311115

CURSOR c_mandatory_info is
   select eval.eval_mandatory_flag,eval.evaluation_id
   from ota_evaluations eval,ota_events evt
   where evt.activity_version_id = eval.object_id(+)
   and evt.event_id = p_event_id
   and eval.evaluation_id is not null   --bug 7184369
   and (eval.object_type = 'A' or eval.object_type is null);
begin


	/*===============================================
	 * check if there is an evaluation
	 *===============================================*/
   	    open c_mandatory_info;
   	    fetch c_mandatory_info into l_act_mandatory, l_act_eval_id;
   	    close c_mandatory_info;

	    if p_mand_flag is not null then
            if p_mand_flag = 'N'  then
	           		if l_act_mandatory is null or  l_act_mandatory = 'N'  then
                           		l_is_mandatory:= false;
                    end if;
            end if;
	    elsif l_act_eval_id is null then
		  return 'NO_EVAL';
        elsif l_act_mandatory = 'N' then
          l_is_mandatory:= false;
	    end if;

    /*===============================================
	 * Evaluation exists, check whether to enable,
	 * disable the evaluation, or mark as 'Done' .
	 *===============================================*/

        select type into l_booking_status_type
	       from ota_booking_status_types
	       where booking_status_type_id in (p_booking_status_type_id);

        if l_is_mandatory then
            if l_booking_status_type = 'E' then
		      return 'ENABLE_EVAL' ;
            elsif l_booking_status_type = 'A' then
		      open c_attempts_info;
		      fetch c_attempts_info into l_attempt_id;
		      if c_attempts_info%found then
		          l_is_attempted := true;
                  end if;
		      close c_attempts_info;
		      if not l_is_attempted then
			     return 'EVAL_CLOSED';  		--7046809
		      else
			     return 'EVAL_DONE';
                  end if;
            else
              return 'DISABLE_EVAL' ;
            end if;
	    else
            if l_booking_status_type = 'A' then
		      open c_attempts_info;
		      fetch c_attempts_info into l_attempt_id;
		      if c_attempts_info%found then
		          l_is_attempted := true;
              end if;
		      close c_attempts_info;
		      if not l_is_attempted then
			     return 'ENABLE_EVAL';
		      else
			     return 'EVAL_DONE';
              end if;
            else
		      return 'DISABLE_EVAL';
            end if;
        end if;
exception
   when others then
	    return null;
end get_play_eval_button;

--Enhancement: 	7310093 SIP: A NEW  FIELD WHICH CAN GIVE THE STATUS OF THE COURSE / CLASS EVALUATION
--Modified for 8855548.

function get_admin_eval_status(
    p_event_id OTA_EVENTS.EVENT_ID%TYPE,
    p_sign_eval_status OTA_DELEGATE_BOOKINGS.SIGN_EVAL_STATUS%TYPE
    ) return varchar2 is

l_mand_flag OTA_EVALUATIONS.EVAL_MANDATORY_FLAG%TYPE;
l_symbol varchar2(100);

Cursor csr_evt_evaluations is
   select decode(nvl(evt_eval.eval_mandatory_flag,'N'), 'Y', 'Y',
       		decode(act_eval.evaluation_id,null,'N',decode(nvl(act_eval.eval_mandatory_flag,'N'),'Y','Y','N'))) flag
   from 	ota_evaluations evt_eval, ota_evaluations act_eval,ota_events evt
   where  evt_eval.object_id(+) = evt.event_id
	 and    (evt_eval.object_type is null or evt_eval.object_type = 'E')
	 and    act_eval.object_id(+) = evt.activity_version_id
   and    (act_eval.object_type is null or act_eval.object_type = 'A')
   and 	  (evt_eval.evaluation_id is not null or act_eval.evaluation_id is not null)
   and 	  evt.event_id = p_event_id;
begin


	open csr_evt_evaluations;
    fetch csr_evt_evaluations into l_mand_flag;
    if csr_evt_evaluations%NOTFOUND then
	close csr_evt_evaluations;
	return 'NO_EVAL';
    end if;
    close csr_evt_evaluations;


    case p_sign_eval_status
        when 'SD' then l_symbol:='DISABLE_MANDATORY_EVAL';
        when 'UD' then l_symbol:='NO_EVAL';
        when 'MD' then l_symbol:='DISABLE_MANDATORY_EVAL';
        when 'OD' then l_symbol:='DISABLE_VOLUNTARY_EVAL';
        when 'VD' then l_symbol:='DISABLE_VOLUNTARY_EVAL';
        when 'SE' then l_symbol:='DISABLE_MANDATORY_EVAL';
        when 'ME' then l_symbol:='ENABLE_MANDATORY_EVAL';
        when 'UE' then l_symbol:='NO_EVAL';
        when 'OE' then l_symbol:='ENABLE_VOLUNTARY_EVAL';
        when 'VE' then l_symbol:='DISABLE_VOLUNTARY_EVAL';
        when 'DD' then if (l_mand_flag = 'N') then l_symbol:='VOLUNTARY_EVAL_DONE';
		       elsif (l_mand_flag = 'Y') then l_symbol:='MANDATORY_EVAL_DONE';
		       end if;
        else l_symbol:='NO_EVAL';
    end case;
    return l_symbol;


exception
   when others then
	    return null;
end get_admin_eval_status;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_wait_duration_for_lo >----------------------
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
    p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return varchar2 is

    v_earliest_attempt_date     date;
begin
   v_earliest_attempt_date :=
      get_next_attempt_date_for_lo(
         p_lo_id,
         p_user_id,
         p_user_type,
         p_cert_prd_enrollment_id);

   if v_earliest_attempt_date is not null then
      return to_char(v_earliest_attempt_date) || to_char(v_earliest_attempt_date, ' HH24:MI:SS');
   else
      return null;
   end if;
end get_wait_duration_for_lo;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_wait_duration_for_test >--------------------
-- ----------------------------------------------------------------------------
-- Author: smanjuna
-- This function is used to get the timestamp until which the learner has to
-- wait before playing the test again. This is displayed as flyover text.
-- [End of Comments]
-- ---------------------------------------------------------------------------
function get_wait_duration_for_test(
   	p_user_id fnd_user.user_id%type,
   	p_user_type ota_attempts.user_type%type,
   	p_event_id ota_events.event_id%type,
    p_cert_prd_enrollment_id ota_attempts.cert_prd_enrollment_id%type default null) return varchar2 is

    v_lo_id ota_learning_objects.learning_object_id%type;
    v_wait_duration varchar2(80);
    --Bug 5166350
    wait_dur_date varchar2(20);
    wait_dur_time varchar2(20);

begin
   select  offr.learning_object_id
   into    v_lo_id
   from    ota_offerings offr, ota_events evt
   where   evt.event_id = p_event_id and
           evt.parent_offering_id = offr.offering_id;

   v_wait_duration := get_wait_duration_for_lo(p_user_id, p_user_type, v_lo_id, p_cert_prd_enrollment_id);

   --Bug 5166350
   wait_dur_date := substr(v_wait_duration, 1, length(v_wait_duration)-9);
   wait_dur_time := substr(v_wait_duration, length(v_wait_duration)-7);
   v_wait_duration := ota_timezone_util.get_date_time(wait_dur_date, wait_dur_time, 'Y', ota_timezone_util.get_server_timezone_code, 'HH24:MI:SS');

   if v_wait_duration is not null then
      fnd_message.set_name('OTA', 'OTA_443502_TEST_WAIT_DRTN_TEXT');
      fnd_message.set_token('DATETIME', v_wait_duration);
      return fnd_message.get();
   else
      return null;
   end if;
end get_wait_duration_for_test;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Root_Folder_Exists>----------------------------|
-- ----------------------------------------------------------------------------
--
function Root_Folder_Exists
(p_folder_id          in   number default hr_api.g_number
,p_business_group_id  in   number default ota_general.get_business_group_id
)
return varchar2 is
 --
 -- decalare cursor
 cursor root_folder is
  select
     distinct 'found'
  from
    ota_lo_folders
  where
    business_group_id = p_business_group_id
    and folder_id <> p_folder_id
    and parent_folder_id is null;
  --
  -- decalre variables
  l_folder_flag         varchar2(10);
  l_return              varchar2(2) := 'N';
  l_proc                varchar2(72) := g_package||'Root_Folder_Exists';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open root_folder;
  fetch root_folder into l_folder_flag;
  IF root_folder%found THEN
   --
   l_return := 'Y';
   hr_utility.set_location('returning Y:'|| l_proc, 10);
  End if;
  --
  close root_folder;
  --
  hr_utility.set_location('Exiting:'|| l_proc, 20);
  --
  return l_return;
--
End Root_Folder_Exists;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_player_status >--------------------------|
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
RETURN VARCHAR2 IS

CURSOR c_learning_object IS
SELECT ofr.learning_object_id
FROM ota_events oev, ota_offerings ofr
WHERE oev.parent_offering_id = ofr.offering_id
      AND oev.event_id = p_event_id;

CURSOR c_learning_object_status(l_lo_id in ota_offerings.learning_object_id%TYPE) IS
  SELECT lesson_status
  FROM ota_performances
  WHERE user_id = p_user_id
        AND user_type = p_user_type
        AND learning_object_id = l_lo_id
        AND cert_prd_enrollment_id is null;

CURSOR c_odb_lo_status IS
  SELECT content_player_status
  FROM ota_delegate_bookings
  WHERE booking_id = p_booking_id;

CURSOR c_imported_offering IS
  SELECT offering_id
  FROM ota_events
  WHERE event_id = p_event_id;

l_proc  VARCHAR2(72) :=      g_package|| 'get_player_status';

l_learning_object_id ota_offerings.learning_object_id%TYPE;

l_status  VARCHAR2(30) := null;

l_imported_offering ota_events.offering_id%TYPE := null;

BEGIN
    hr_utility.set_location(' Step:'|| l_proc, 10);

        open c_learning_object;
        fetch c_learning_object into l_learning_object_id;
        close c_learning_object;

        -- Check if the event is imported
        open c_imported_offering;
        fetch c_imported_offering into l_imported_offering;
        close c_imported_offering;

        If (l_imported_offering is not null) Then
            -- Imported Offering, Status code should be taken from
            -- OTA_DELEGATE_BOOKINGS
            open c_odb_lo_status;
            fetch c_odb_lo_status into l_status;
            close c_odb_lo_status;
        Else
            -- EBS created, Status code should be taken from
            -- OTA_PERFORMANCES
	    open c_learning_object_status(l_learning_object_id);
	    fetch c_learning_object_status into l_status;
	    close c_learning_object_status;

        End If;

    RETURN l_status;
    hr_utility.set_location(' Step:'|| l_proc, 20);
END get_player_status;

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
RETURN VARCHAR2 IS

CURSOR c_learning_object IS
SELECT ofr.learning_object_id
FROM ota_events oev, ota_offerings ofr
WHERE oev.parent_offering_id = ofr.offering_id
      AND oev.event_id = p_event_id;

CURSOR c_learning_object_time(l_lo_id in ota_offerings.learning_object_id%TYPE) IS
  SELECT TO_CHAR(TRUNC(SYSDATE)+(time)/86400, 'HH24:Mi:SS')
  FROM ota_performances
  WHERE user_id = p_user_id
        AND user_type = p_user_type
        AND learning_object_id = l_lo_id
        AND cert_prd_enrollment_id is null;

CURSOR c_odb_lo_time IS
  SELECT total_training_time
  FROM ota_delegate_bookings
  WHERE booking_id = p_booking_id;

CURSOR c_imported_offering IS
  SELECT offering_id
  FROM ota_events
  WHERE event_id = p_event_id;

l_proc  VARCHAR2(72) :=      g_package|| 'get_enroll_lo_time';

l_learning_object_id ota_offerings.learning_object_id%TYPE;

l_time  VARCHAR2(30) := null;

l_imported_offering ota_events.offering_id%TYPE := null;

BEGIN
    hr_utility.set_location(' Step:'|| l_proc, 10);

        open c_learning_object;
        fetch c_learning_object into l_learning_object_id;
        close c_learning_object;

        -- Check if the event is imported
        open c_imported_offering;
        fetch c_imported_offering into l_imported_offering;
        close c_imported_offering;

        If (l_imported_offering is not null) Then
            -- Imported Offering, Score should be taken from
            -- OTA_DELEGATE_BOOKINGS
            open c_odb_lo_time;
            fetch c_odb_lo_time into l_time;
            close c_odb_lo_time;
        Else
            -- EBS created, time should be taken from
            -- OTA_PERFORMANCES
	    open c_learning_object_time(l_learning_object_id);
	    fetch c_learning_object_time into l_time;
	    close c_learning_object_time;

        End If;

    RETURN l_time;
    hr_utility.set_location(' Step:'|| l_proc, 20);
END get_enroll_lo_time;

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
RETURN VARCHAR2 IS

CURSOR c_learning_object IS
SELECT ofr.learning_object_id
FROM ota_events oev, ota_offerings ofr
WHERE oev.parent_offering_id = ofr.offering_id
      AND oev.event_id = p_event_id;

CURSOR c_learning_object_score(l_lo_id in ota_offerings.learning_object_id%TYPE) IS
  SELECT score
  FROM ota_performances
  WHERE user_id = p_user_id
        AND user_type = p_user_type
        AND learning_object_id = l_lo_id
        AND cert_prd_enrollment_id is null;

CURSOR c_odb_lo_score IS
  SELECT score
  FROM ota_delegate_bookings
  WHERE booking_id = p_booking_id;

CURSOR c_imported_offering IS
  SELECT offering_id
  FROM ota_events
  WHERE event_id = p_event_id;

l_proc  VARCHAR2(72) :=      g_package|| 'get_enroll_lo_score';

l_learning_object_id ota_offerings.learning_object_id%TYPE;

l_score  VARCHAR2(30) := null;

l_imported_offering ota_events.offering_id%TYPE := null;

BEGIN
    hr_utility.set_location(' Step:'|| l_proc, 10);

        open c_learning_object;
        fetch c_learning_object into l_learning_object_id;
        close c_learning_object;

        -- Check if the event is imported
        open c_imported_offering;
        fetch c_imported_offering into l_imported_offering;
        close c_imported_offering;

        If (l_imported_offering is not null) Then
            -- Imported Offering, Score should be taken from
            -- OTA_DELEGATE_BOOKINGS
            open c_odb_lo_score;
            fetch c_odb_lo_score into l_score;
            close c_odb_lo_score;
        Else
            -- EBS created, Score should be taken from
            -- OTA_PERFORMANCES
	    open c_learning_object_score(l_learning_object_id);
	    fetch c_learning_object_score into l_score;
	    close c_learning_object_score;

        End If;

        If ( l_score = -1000) Then
	    l_score := null;
	End If;

    RETURN l_score;
    hr_utility.set_location(' Step:'|| l_proc, 20);
END get_enroll_lo_score;
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
--   p_chk_active_cert_flag
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
RETURN VARCHAR2 IS


--Bug 5222464
CURSOR c_delivery_mode IS
SELECT ocu.online_flag, ofr.learning_object_id,
       to_date(to_char(nvl(oev.course_end_date, to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' ' || nvl(oev.course_end_time, '23:59'), 'YYYY/MM/DD HH24:MI'),
       ota_timezone_util.convert_date(sysdate, to_char(sysdate,'HH24:MI'), ota_timezone_util.get_server_timezone_code, oev.timezone)
FROM ota_events oev, ota_offerings ofr, ota_category_usages ocu
WHERE oev.parent_offering_id = ofr.offering_id
      AND ofr.delivery_mode_id = ocu.category_usage_id
      AND oev.event_id = p_event_id;

CURSOR c_booking_status IS
  SELECT BST.type, BST.name
  FROM   ota_booking_status_types_vl BST
  WHERE  BST.booking_status_type_id = p_booking_status_type_id;

CURSOR c_learning_object_status(l_lo_id in ota_offerings.learning_object_id%TYPE) IS
  SELECT lesson_status,
         hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS',lesson_status)lesson_status_name
  FROM ota_performances
  WHERE user_id = p_user_id
        AND user_type = p_user_type
        AND learning_object_id = l_lo_id
        AND cert_prd_enrollment_id is null;

CURSOR c_odb_lo_status IS
  SELECT CONTENT_PLAYER_STATUS,
         hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS',CONTENT_PLAYER_STATUS)lesson_status_name
  FROM ota_delegate_bookings
  WHERE booking_id = p_booking_id;

CURSOR c_imported_offering IS
  SELECT offering_id
  FROM ota_events
  WHERE event_id = p_event_id;

-- Bug 4665032
CURSOR csr_best_prf (l_lo_id in ota_offerings.learning_object_id%TYPE) IS
      SELECT decode(prf.lesson_status, 'P', '1',
                   'C', '2',
                   'F', '3',
                   'I', '4',
                   'B', '5',
                   'N', '6') decode_lesson_status,
           prf.lesson_status lesson_status,
           hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS', prf.lesson_status) lesson_status_name
      FROM ota_performances prf
     WHERE
           prf.user_id  = p_user_id
       and prf.user_type  = p_user_type
       and prf.learning_object_id = l_lo_id
     order by decode_lesson_status;

cursor csr_contact_id is
select delegate_contact_id
  from ota_delegate_bookings
  where booking_id = p_booking_id;

cursor csr_enr_sign_info is
select odb.sign_eval_status from
ota_delegate_bookings odb
where odb.booking_id = p_booking_id;


l_proc  VARCHAR2(72) :=      g_package|| 'get_enroll_lo_status';

l_online_flag ota_category_usages.online_flag%TYPE;
l_learning_object_id ota_offerings.learning_object_id%TYPE;
l_course_end_date ota_events.course_end_date%TYPE;
l_sysdate ota_events.course_end_date%TYPE;

l_status  VARCHAR2(30) := null;
l_status_name ota_booking_status_types_tl.name%TYPE := null;

--Bug 4665032
l_enrollment_status_code ota_booking_status_types.type%TYPE;
l_enrollment_status_name ota_booking_status_types_tl.name%TYPE;
l_decode_lesson_status VARCHAR2(1);

-- Bug 3725560
l_imported_offering ota_events.offering_id%TYPE := null;

l_cert_prd_enrollment_ids varchar2(4000) := null;
l_person_id ota_cert_enrollments.person_id%type := null;
l_contact_id ota_cert_enrollments.contact_id%type := null;
l_cert_prd_enrollment_id OTA_CERT_PRD_ENROLLMENTS.cert_prd_enrollment_id%type;
l_sign_eval_status OTA_DELEGATE_BOOKINGS.sign_eval_status%type;

BEGIN
    hr_utility.set_location(' Step:'|| l_proc, 10);
    open c_delivery_mode;
    fetch c_delivery_mode into l_online_flag, l_learning_object_id, l_course_end_date, l_sysdate; --Bug 5222464
    close c_delivery_mode;

    --Fetch the enrollment status of the booking
    open c_booking_status;
    fetch c_booking_status into l_enrollment_status_code, l_enrollment_status_name;
    close c_booking_status;

    -- Check for LO status for online classes
    If ( l_online_flag = 'Y' ) Then

        -- Bug 3725560
        -- Check if the event is imported
        open c_imported_offering;
        fetch c_imported_offering into l_imported_offering;
        close c_imported_offering;

        If (l_imported_offering is not null) Then
            -- Imported Offering, Status should be taken from
            -- OTA_DELEGATE_BOOKINGS
            open c_odb_lo_status;
            fetch c_odb_lo_status into l_status, l_status_name;
            close c_odb_lo_status;
        Else
            -- EBS created, Status should be taken from
            -- OTA_PERFORMANCES

            If ( l_enrollment_status_code = 'A' and p_mode = 2 ) Then
                    -- p_mode = 2 means that coming from admin side
		    open csr_best_prf(l_learning_object_id);
		    fetch csr_best_prf into l_decode_lesson_status, l_status, l_status_name;
		    close csr_best_prf;
            Else
		    -- Coming from learner side
		    open c_learning_object_status(l_learning_object_id);
		    fetch c_learning_object_status into l_status, l_status_name;
		    close c_learning_object_status;
 	    End If;
        End If;

        If ( l_status is null ) Then
	    l_status := 'N';
    	    l_status_name := hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS','N');
	End If;

        If ( (l_status = 'N') or (l_status = 'I') ) Then
 	        If ( l_course_end_date < l_sysdate  --Class is expired --Bug 3554773 --Bug 5222464
                     AND p_mode is null               ) Then -- Bug 3594377
    			l_status := 'E';
	    		l_status_name := ota_utility.get_message('OTA','OTA_443001_OFFR_EXPIRED_STATUS');
		End If;
    	End If;

    	--check if the enrollment is part of active certs
    	if p_chk_active_cert_flag is not null and p_chk_active_cert_flag = 'Y' then
	   if p_user_type = 'E' then
	      l_person_id := p_user_id;
	       elsif p_user_type = 'C' then
	      open csr_contact_id;
	      fetch csr_contact_id into l_contact_id;
	      close csr_contact_id;
	   end if;

	    if(l_person_id is not null) then
	       open csr_active_cert_prd_person(p_event_id, l_person_id);
	       fetch csr_active_cert_prd_person into l_cert_prd_enrollment_id;
	       close csr_active_cert_prd_person;
	    else
           open csr_active_cert_prd_contact(p_event_id, l_contact_id);
	       fetch csr_active_cert_prd_contact into l_cert_prd_enrollment_id;
	       close csr_active_cert_prd_contact;
	    end if;

/*	   get_active_cert_prds(p_event_id,
				l_person_id,
				l_contact_id,
				l_cert_prd_enrollment_ids);
*/
	   if l_cert_prd_enrollment_id is not null then
	      --return status mng as 'Available under certification'
	      l_status := 'D';
	      l_status_name := hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS','D');
	   end if;
	end if;
	--bug 6683076.Added to show 'Pending Evaluation' as player status for
	--learners who have to take mandatory evaluation after
	--completing the online class.
	--bug 7175372.Added condition so that this player status is shown
	--only from learner side.
	If (l_status = 'C' or l_status = 'P' or l_status = 'F') Then
		If (l_enrollment_status_code = 'E' and (p_mode is null or p_mode <>2)) Then
			open csr_enr_sign_info;
              	fetch csr_enr_sign_info into l_sign_eval_status;
	            close csr_enr_sign_info;
      	      if(l_sign_eval_status in ('SE','UE','VE','ME')) then  --8855548
            	    l_status_name:= l_enrollment_status_name;
            	end if;
		End If;
	End If;

    Else
      If p_mode <> 2 Then -- Bug#4465495 If p_mode is  not 2
        --  for off-line class return enrollment status
	l_status := l_enrollment_status_code;
	l_status_name := l_enrollment_status_name;
      Else --Bug#4465495 If p_mode is 2 for off-line class return null;
        l_status_name := null;
      End If;
    End If;

    RETURN l_status_name;
    hr_utility.set_location(' Step:'|| l_proc, 20);
END get_enroll_lo_status;

-- ----------------------------------------------------------------------------
-- |-------------------------< get_history_button >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This function will return a value based on which the Move to History
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
                                   RETURN VARCHAR2 IS

   l_return 			VARCHAR2(100);
   l_enable_move_to_history     boolean;
   l_type               varchar2(1);
   l_proc               VARCHAR2(72) := g_package||'get_history_button';

   l_imported_offering  ota_events.offering_id%TYPE;
   l_booking_status_type ota_booking_status_types.type%TYPE;

CURSOR c_imported_offering IS
  SELECT offering_id
  FROM ota_events
  WHERE event_id = p_event_id;

CURSOR c_history_enabled IS
SELECT lesson_status
  FROM ota_performances
 WHERE learning_object_id = p_lo_id
   AND user_id = p_user_id
   AND lesson_status IN ('P', 'C');

CURSOR c_booking_status_type IS
  SELECT type
  FROM ota_delegate_bookings odb,
       ota_booking_status_types bst
  WHERE booking_id = p_booking_id
        and odb.booking_status_type_id = bst.booking_status_type_id;

CURSOR c_history_enabled_odb IS
  SELECT content_player_status
  FROM ota_delegate_bookings
  WHERE booking_id = p_booking_id
    AND content_player_status in ('P', 'C');

BEGIN

    hr_utility.set_location(' Step:'|| l_proc, 10);

    --Initialize local variables
    l_enable_move_to_history := false;
    l_return := 'MoveToHistoryDisabled';

    --First check the enrollment status
    OPEN c_booking_status_type;
    FETCH c_booking_status_type INTO l_booking_status_type;
    CLOSE c_booking_status_type;

    if (l_booking_status_type = 'A' ) Then --If status is A then move to history should be enabled
	l_enable_move_to_history := true;
    elsif (l_booking_status_type <> 'E') Then  -- Bug 6683076
	-- Bug 3725560
	-- Check if the event is imported
	OPEN c_imported_offering;
	FETCH c_imported_offering into l_imported_offering;
	CLOSE c_imported_offering;

	IF (l_imported_offering is not null) Then
		-- Imported Offering, Status should be taken from
		-- OTA_DELEGATE_BOOKINGS - Bug 3725560
		OPEN c_history_enabled_odb;
		FETCH c_history_enabled_odb INTO l_type;
		CLOSE c_history_enabled_odb;
	ELSE
		-- EBS created, Status should be taken from
		-- OTA_PERFORMANCES
		OPEN c_history_enabled;
		FETCH c_history_enabled INTO l_type;
		CLOSE c_history_enabled;
	END IF;
	if (l_type is not null) then
		l_enable_move_to_history := true;
	end if;

    end if;
  IF (l_enable_move_to_history) THEN
    l_return := 'MoveToHistoryImage';
  END IF;

  RETURN l_return;

  EXCEPTION
   WHEN others then

	RETURN l_return;

END get_history_button;

FUNCTION get_nls_language
RETURN varchar2
IS
   CURSOR csr_get_nls_lang IS
     SELECT NLS_LANGUAGE
     FROM fnd_languages
     WHERE language_code = userenv('LANG');
l_nls_language fnd_languages.NLS_LANGUAGE%TYPE;
BEGIN
   OPEN csr_get_nls_lang;
   FETCH csr_get_nls_lang INTO l_nls_language;
   CLOSE csr_get_nls_lang;

   RETURN l_nls_language;
END get_nls_language;

-- Author: sbhullar
-- ----------------------------------------------------------------
-- ------------------<get_lo_completion_date >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to show get lo completion date for
-- online asynchronous offering
-- IN
-- p_event_id
-- p_user_id
-- p_user_type
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
--Added method get_lo_completion_date_time,similar to get_lo_completion_date but returns a date allowing UI sort
FUNCTION get_lo_completion_date(p_event_id IN ota_events.event_id%type,
  			        p_user_id	IN	NUMBER,
                                p_user_type IN ota_attempts.user_type%type,
                                p_cert_prd_enroll_id IN ota_performances.cert_prd_enrollment_id%type default NULL,
				p_module_name IN VARCHAR2 default 'LEARNER')
RETURN varchar2
IS
    l_proc VARCHAR2(72) := g_package||'get_lo_completion_date';
    l_event_id ota_events.event_id%type;
    l_lo_id ota_learning_objects.learning_object_id%type;
 --   l_lo_completed_date VARCHAR2(100);
    l_lo_completed_date DATE;
    l_lo_completed_time VARCHAR2(10);
    l_lo_completed_date_tz VARCHAR2(100);
    l_lo_lesson_status ota_performances.lesson_status%type;
    l_sync_flag ota_category_usages.synchronous_flag%type;
    l_online_flag ota_category_usages.online_flag%type;
    l_return_completion_date varchar(50) := '';

CURSOR c_get_lo_completion_date is
Select
       oev.event_id,
       ofr.learning_object_id,
       opf.completed_date,
       to_char(opf.completed_date, 'HH24:MI:SS'),
       opf.lesson_status,
       ocu.Synchronous_Flag Sync_Flag,
       ocu.Online_Flag Online_Flag,
       ota_timezone_util.get_date_time(trunc(opf.completed_date), to_char(opf.completed_date, 'HH24:MI:SS'), 'Y', ota_timezone_util.get_server_timezone_code, 'HH24:MI:SS') Comp_Date_Tz
From OTA_EVENTS oev, OTA_OFFERINGS ofr, OTA_PERFORMANCES opf, ota_category_usages ocu
Where
     oev.parent_offering_id = ofr.offering_id
     And ofr.learning_object_id = opf.learning_object_id(+)
     And oev.event_id = p_event_id
     And opf.User_id(+) = p_user_id
     And opf.User_type(+) = p_user_type
     And ocu.Category_Usage_Id = ofr.Delivery_Mode_Id;

CURSOR c_get_lo_completion_date_cert is
Select
       oev.event_id,
       ofr.learning_object_id,
       opf.completed_date,
       to_char(opf.completed_date, 'HH24:MI:SS'),
       opf.lesson_status,
       ocu.Synchronous_Flag Sync_Flag,
       ocu.Online_Flag Online_Flag,
       ota_timezone_util.get_date_time(trunc(opf.completed_date), to_char(opf.completed_date, 'HH24:MI:SS'), 'Y', ota_timezone_util.get_server_timezone_code, 'HH24:MI:SS') Comp_Date_Tz
From OTA_EVENTS oev, OTA_OFFERINGS ofr, OTA_PERFORMANCES opf, ota_category_usages ocu
Where
     oev.parent_offering_id = ofr.offering_id
     And ofr.learning_object_id = opf.learning_object_id(+)
     And oev.event_id = p_event_id
     And opf.User_id(+) = p_user_id
     And opf.User_type(+) = p_user_type
     And opf.cert_prd_enrollment_id(+) = p_cert_prd_enroll_id
     And ocu.Category_Usage_Id = ofr.Delivery_Mode_Id;

Begin
   hr_utility.set_location('Entering :'||l_proc,5);
   if(p_cert_prd_enroll_id is not null) then
     open c_get_lo_completion_date_cert;
     fetch c_get_lo_completion_date_cert into l_event_id, l_lo_id, l_lo_completed_date, l_lo_completed_time, l_lo_lesson_status, l_sync_flag, l_online_flag, l_lo_completed_date_tz;
     close c_get_lo_completion_date_cert;
   else
     open c_get_lo_completion_date;
     fetch c_get_lo_completion_date into l_event_id, l_lo_id, l_lo_completed_date, l_lo_completed_time, l_lo_lesson_status, l_sync_flag, l_online_flag, l_lo_completed_date_tz;
     close c_get_lo_completion_date;
   end if;

   If ( l_online_flag = 'Y' and l_sync_flag = 'N'
        and l_lo_completed_date is not null and ( l_lo_lesson_status = 'C' or l_lo_lesson_status = 'P') ) Then
       If ( p_module_name = 'LEARNER' or   p_module_name = 'INSTRUCTOR' ) Then
		l_return_completion_date := l_lo_completed_date_tz;
       Else

		l_return_completion_date :=
          to_char(trunc(l_lo_completed_date)
           ,hr_util_misc_web.get_nls_parameter('NLS_DATE_FORMAT')
           , 'nls_date_language = ' || get_nls_language())
            || ' ' || l_lo_completed_time;
       End If;
   End If;


   RETURN l_return_completion_date;
   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);
           RETURN l_return_completion_date;
End get_lo_completion_date;

-- ----------------------------------------------------------------------------
-- |--------------------< GET_LO_COMPLETION_DATE_TIME>-------------------------|
-- ----------------------------------------------------------------------------

--Added for 6768606:COMPLETION DATE COLUMN SORT NUMERIC AND NOT BY ACTUAL DATE SORT
--Similar to get_lo_completion_date,but the return type is date.Called from admin side

FUNCTION get_lo_completion_date_time(p_event_id IN ota_events.event_id%type,
  			        p_user_id	IN	NUMBER,
                                p_user_type IN ota_attempts.user_type%type,
                                p_cert_prd_enroll_id IN ota_performances.cert_prd_enrollment_id%type default NULL,
				p_module_name IN VARCHAR2 default 'LEARNER')
RETURN date
IS
    l_proc VARCHAR2(72) := g_package||'get_lo_completion_date_time';
    l_event_id ota_events.event_id%type;
    l_lo_id ota_learning_objects.learning_object_id%type;
    l_lo_completed_date DATE;
    l_lo_comp_date DATE;
    l_lo_completed_time VARCHAR2(10);
    l_lo_completed_date_tz VARCHAR2(100);
    l_lo_lesson_status ota_performances.lesson_status%type;
    l_sync_flag ota_category_usages.synchronous_flag%type;
    l_online_flag ota_category_usages.online_flag%type;
    l_return_completion_date date:= null;

CURSOR c_get_lo_completion_date is
Select
       oev.event_id,
       ofr.learning_object_id,
       opf.completed_date,
       to_char(opf.completed_date, 'HH24:MI:SS'),
       opf.lesson_status,
       ocu.Synchronous_Flag Sync_Flag,
       ocu.Online_Flag Online_Flag,
       ota_timezone_util.get_date_time(trunc(opf.completed_date), to_char(opf.completed_date, 'HH24:MI:SS'), 'Y', ota_timezone_util.get_server_timezone_code, 'HH24:MI:SS') Comp_Date_Tz,
       ota_timezone_util.get_dateDT(trunc(opf.completed_date), to_char(opf.completed_date, 'HH24:MI:SS'), ocu.Online_Flag, ota_timezone_util.get_server_timezone_code) Comp_Date
From OTA_EVENTS oev, OTA_OFFERINGS ofr, OTA_PERFORMANCES opf, ota_category_usages ocu
Where
     oev.parent_offering_id = ofr.offering_id
     And ofr.learning_object_id = opf.learning_object_id(+)
     And oev.event_id = p_event_id
     And opf.User_id(+) = p_user_id
     And opf.User_type(+) = p_user_type
     And ocu.Category_Usage_Id = ofr.Delivery_Mode_Id;

CURSOR c_get_lo_completion_date_cert is
Select
       oev.event_id,
       ofr.learning_object_id,
       opf.completed_date,
       to_char(opf.completed_date, 'HH24:MI:SS'),
       opf.lesson_status,
       ocu.Synchronous_Flag Sync_Flag,
       ocu.Online_Flag Online_Flag,
       ota_timezone_util.get_date_time(trunc(opf.completed_date), to_char(opf.completed_date, 'HH24:MI:SS'), 'Y', ota_timezone_util.get_server_timezone_code, 'HH24:MI:SS') Comp_Date_Tz,
       ota_timezone_util.get_dateDT(trunc(opf.completed_date), to_char(opf.completed_date, 'HH24:MI:SS'), ocu.Online_Flag, ota_timezone_util.get_server_timezone_code) Comp_Date
From OTA_EVENTS oev, OTA_OFFERINGS ofr, OTA_PERFORMANCES opf, ota_category_usages ocu
Where
     oev.parent_offering_id = ofr.offering_id
     And ofr.learning_object_id = opf.learning_object_id(+)
     And oev.event_id = p_event_id
     And opf.User_id(+) = p_user_id
     And opf.User_type(+) = p_user_type
     And opf.cert_prd_enrollment_id(+) = p_cert_prd_enroll_id
     And ocu.Category_Usage_Id = ofr.Delivery_Mode_Id;

Begin
   hr_utility.set_location('Entering :'||l_proc,5);

   if(p_cert_prd_enroll_id is not null) then
    open c_get_lo_completion_date_cert;
    fetch c_get_lo_completion_date_cert into l_event_id, l_lo_id, l_lo_completed_date, l_lo_completed_time, l_lo_lesson_status, l_sync_flag, l_online_flag, l_lo_completed_date_tz,l_lo_comp_date;
    close c_get_lo_completion_date_cert;
   else
    open c_get_lo_completion_date;
    fetch c_get_lo_completion_date into l_event_id, l_lo_id, l_lo_completed_date, l_lo_completed_time, l_lo_lesson_status, l_sync_flag, l_online_flag, l_lo_completed_date_tz,l_lo_comp_date;
    close c_get_lo_completion_date;
   end if;

   If ( l_online_flag = 'Y' and l_sync_flag = 'N'
        and l_lo_completed_date is not null and ( l_lo_lesson_status = 'C' or l_lo_lesson_status = 'P') ) Then

          IF (p_module_name = 'ADMIN' or p_module_name = 'LEARNER' or p_module_name = 'INSTRUCTOR')then -- Bug#7441027
             l_return_completion_date := l_lo_comp_date;
          END IF;

   End If;


   RETURN l_return_completion_date;
   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);
           RETURN l_return_completion_date;
End get_lo_completion_date_time;

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
RETURN VARCHAR2 IS


CURSOR c_delivery_mode IS
SELECT ocu.online_flag, ofr.learning_object_id, nvl(oev.course_end_date, trunc(sysdate))
FROM ota_events oev, ota_offerings ofr, ota_category_usages ocu
WHERE oev.parent_offering_id = ofr.offering_id
      AND ofr.delivery_mode_id = ocu.category_usage_id
      AND oev.event_id = p_event_id;

CURSOR c_booking_status IS
  SELECT BST.type, BST.name
  FROM   ota_booking_status_types_vl BST
  WHERE  BST.booking_status_type_id = p_booking_status_type_id;

CURSOR c_prd_lo_status(l_lo_id in ota_offerings.learning_object_id%TYPE) IS
  SELECT lesson_status,
         hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS',lesson_status)lesson_status_name
  FROM ota_performances
  WHERE user_id = p_user_id
        AND user_type = p_user_type
        AND learning_object_id = l_lo_id
        AND cert_prd_enrollment_id = p_cert_prd_enrollment_id;

l_proc  VARCHAR2(72) :=      g_package|| 'get_cert_lo_status';

l_online_flag ota_category_usages.online_flag%TYPE;
l_learning_object_id ota_offerings.learning_object_id%TYPE;
l_course_end_date ota_events.course_end_date%TYPE;

l_status  VARCHAR2(30) := null;
l_status_name ota_booking_status_types_tl.name%TYPE := null;

BEGIN
    hr_utility.set_location(' Step:'|| l_proc, 10);
    open c_delivery_mode;
    fetch c_delivery_mode into l_online_flag, l_learning_object_id, l_course_end_date;
    close c_delivery_mode;

    -- Check for LO status for online classes
    If ( l_online_flag = 'Y' ) Then

        -- OTA_PERFORMANCES for CERT_PRD_ENROLLMENT_ID
        open c_prd_lo_status(l_learning_object_id);
	    fetch c_prd_lo_status into l_status, l_status_name;
  	    close c_prd_lo_status;

        If ( l_status is null ) Then
	        l_status := 'N';
    	    l_status_name := hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS','N');
	    End If;

        If ( (l_status = 'N') or (l_status = 'I') ) Then
 	        If ( l_course_end_date < trunc(sysdate)  --Class is expired --Bug 3554773
                     AND p_mode is null               ) Then -- Bug 3594377
    			l_status := 'E';
	    		l_status_name := ota_utility.get_message('OTA','OTA_443001_OFFR_EXPIRED_STATUS');
  		    End If;
    	End If;
    Else
    	open c_booking_status;
    	fetch c_booking_status into l_status, l_status_name;
    	close c_booking_status;
    End If;

    RETURN l_status_name;
    hr_utility.set_location(' Step:'|| l_proc, 20);

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,30);
     RETURN NULL;

END get_cert_lo_status;

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
RETURN varchar2
IS
    l_proc VARCHAR2(72) := g_package||'get_cert_lo_title_for_tree';
    l_lo_name varchar(240);
    l_lo_status varchar(80);
    l_lo_time number;
    l_lo_score number;
    l_lo_status_icon varchar(30);
    l_Seconds number;
    l_Minutes number;
    l_Hours number;
    l_formatted_hour varchar(20) := '';
    l_formatted_min varchar(20) := '';
    l_formatted_sec varchar(20) := '';
    l_formatted_time varchar(20) := '';
    l_return_tree_title varchar(500) := '';
    l_max_performance_id  ota_performances.performance_id%type;
    l_tst_grade_flag ota_tests.grade_flag%TYPE;
    l_var_score      VARCHAR2(100);
    l_lo_completed_date VARCHAR2(100);
    l_lo_completed_time VARCHAR2(10);
    l_lo_completed_date_tz VARCHAR2(100);
    l_lo_lesson_status ota_performances.lesson_status%type;

CURSOR c_get_cert_lo_tree_link(p_performance_id in number) is
Select
olo.name Name,
nvl(hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS',opf.lesson_status),
hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS','N')) Status,
nvl(opf.time,0) Time,
opf.score Score,
decode(opf.lesson_status
	  ,'C','player_status_c.gif'
	  ,'F','player_status_f.gif'
	  ,'I','player_status_i.gif'
	  ,'P','player_status_p.gif'
	  ,'N','player_status_n.gif'
	  ,null,DECODE(OTA_LO_UTILITY.user_can_attempt_lo(olo.learning_object_id,p_user_id,p_user_type,'', p_cert_prd_enrollment_id),
           'N','player_status_no_prereq.gif',
           'Y','player_status_n.gif')
	  ,'player_status_n.gif') STATUS_ICON
          , tst.grade_flag
          , to_char(opf.completed_date)
          , to_char(opf.completed_date, 'HH24:MI:SS')
          , opf.lesson_status
          , ota_timezone_util.get_date_time(trunc(opf.completed_date), to_char(opf.completed_date, 'HH24:MI:SS'), 'Y', ota_timezone_util.get_server_timezone_code, 'HH24:MI:SS') Comp_Date_Tz
From OTA_LEARNING_OBJECTS olo, OTA_PERFORMANCES opf,
     OTA_TESTS tst
Where
     olo.learning_object_id = opf.learning_object_id(+)
     AND tst.test_id(+) = olo.test_id
     And olo.Learning_object_id = p_lo_id
     And opf.User_id(+) = p_user_id
     And opf.User_type(+) = p_user_type
     AND opf.performance_id(+) = p_performance_id
     And opf.cert_prd_enrollment_id(+) = p_cert_prd_enrollment_id;

CURSOR c_max_performance_id is
Select max(per.performance_id)
From ota_performances per
Where per.learning_object_id(+) = p_lo_id
      And per.user_id(+) = p_user_id
      And per.user_type(+) = p_user_type
      And per.cert_prd_enrollment_id(+) = p_cert_prd_enrollment_id;

Begin
   hr_utility.set_location('Entering :'||l_proc,5);

   open c_max_performance_id;
   fetch c_max_performance_id into l_max_performance_id;
   close c_max_performance_id;

   if ( l_max_performance_id is null ) then
        l_max_performance_id := -1;
   end if;

   open c_get_cert_lo_tree_link(l_max_performance_id);
   fetch c_get_cert_lo_tree_link into l_lo_name,l_lo_status,l_lo_time,l_lo_score,l_lo_status_icon , l_tst_grade_flag, l_lo_completed_date, l_lo_completed_time, l_lo_lesson_status, l_lo_completed_date_tz;
   close c_get_cert_lo_tree_link;

   If ( p_mode = 1) Then
       l_lo_time := round(l_lo_time);

       l_Seconds := l_lo_time mod 60;
       l_Minutes := floor(l_lo_time / 60);
       l_Hours := floor(l_Minutes/60);
       l_Minutes := l_Minutes - l_Hours * 60;

       If (l_Hours < 10) Then
           l_formatted_hour := '0' || l_Hours;
       Else
           l_formatted_hour := l_Hours;
       End If;

       If (l_Minutes < 10) Then
           l_formatted_min := '0' || l_Minutes;
       Else
           l_formatted_min := l_Minutes;
       End If;

       If (l_Seconds < 10) Then
           l_formatted_sec := '0' || l_Seconds;
       Else
           l_formatted_sec := l_Seconds;
       End If;

       fnd_message.set_name('OTA', 'OTA_443358_SRCH_LO_TIME');
       fnd_message.set_token ('HOUR', l_formatted_hour);
       fnd_message.set_token ('MIN', l_formatted_min);
       fnd_message.set_token ('SEC', l_formatted_sec);
       l_formatted_time := fnd_message.get();

       If ((l_lo_score is null) or (l_lo_score < 0)) Then
           fnd_message.set_name('OTA', 'OTA_443453_SRCH_TREE_TITLE2');
       Else
           --Added for bug 3550407
           IF ( l_tst_grade_flag = 'P' ) THEN
              l_var_score := l_lo_score||'%';
          ELSE
              l_var_score := l_lo_score;
           END IF;

           fnd_message.set_name('OTA', 'OTA_443357_SRCH_TREE_TITLE');
           fnd_message.set_token ('SCORE', l_var_score);
       End If;

       If ( (l_lo_lesson_status = 'C' or l_lo_lesson_status = 'P')
             and l_lo_completed_date is not null ) Then
            l_lo_status := l_lo_status || ' ' || l_lo_completed_date_tz;
       End If;

       fnd_message.set_token ('LO_NAME', l_lo_name);
       fnd_message.set_token ('STATUS', l_lo_status);
       fnd_message.set_token ('TIME', l_formatted_time);

       l_return_tree_title := fnd_message.get();
   Else
       l_return_tree_title := l_lo_status_icon;
   End If;

   hr_utility.set_location('Leaving :'||l_proc,10);
   RETURN l_return_tree_title;
   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

           RETURN l_return_tree_title;
End get_cert_lo_title_for_tree;

function get_cme_online_event_id(p_user_id in fnd_user.user_id%type,
   			     p_user_type in ota_attempts.user_type%type,
   			     p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
return varchar2 is
CURSOR csr_cme_info IS
SELECT cme.cert_mbr_enrollment_id,
       cpe.cert_prd_enrollment_id,
       cme.object_version_number,
       cmb.object_id,
       cmb.certification_member_id,
       cme.member_status_code
  FROM ota_certification_members cmb,
       ota_cert_mbr_enrollments cme,
       ota_cert_prd_enrollments cpe
 WHERE cpe.cert_prd_enrollment_id = cme.cert_prd_enrollment_id
    AND cme.cert_member_id = cmb.certification_member_id
    AND cme.cert_mbr_enrollment_id = p_cert_mbr_enrollment_id;

CURSOR csr_cert_enrl(csr_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type) IS
SELECT cre.person_id, cre.contact_id, cpe.cert_period_start_date, cpe.cert_period_end_date
 FROM ota_cert_enrollments cre,
      ota_cert_prd_enrollments cpe
 where cpe.cert_prd_enrollment_id = csr_cert_prd_enrollment_id
   and cpe.cert_enrollment_id = cre.cert_enrollment_id;


CURSOR get_enrl_status_on_update(csr_activity_version_id ota_events.activity_version_id%type,
				 csr_cert_period_start_date in date,
				 csr_cert_period_end_date in date,
                                 csr_person_id in number,
                                 csr_contact_id in number) IS

SELECT bst.type status,
       tdb.DATE_STATUS_CHANGED,
       evt.event_id,
       evt.event_type,
       ocu.synchronous_flag,
       ocu.online_flag,
       bst.type
  FROM ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types bst,
       ota_offerings ofr,
       ota_category_usages ocu
 WHERE evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
/*   AND (
        evt.course_start_date >= csr_cert_period_start_date
        AND
            (
             evt.course_end_date IS NOT NULL
             AND evt.course_end_date <= csr_cert_period_end_date
            )
            OR
            (
               evt.event_type = 'SELFPACED'
             AND csr_cert_period_end_date >= evt.course_start_date
             )
         )
   */
   ---
   AND ( ( evt.course_start_date >= csr_cert_period_start_date   and
                    nvl(evt.course_end_date,to_date('4712/12/31', 'YYYY/MM/DD')) <= csr_cert_period_end_date )
   /* Bug 4515924
                  or  (evt.event_type ='SELFPACED'  and
                         evt.course_start_date< csr_cert_period_end_date  AND
                         nvl(evt.course_end_date,to_date('4712/12/31', 'YYYY/MM/DD')) >= csr_cert_period_end_date  ))*/
          or (evt.event_type = 'SELFPACED' AND
        ((csr_cert_period_end_date >= evt.course_start_date) AND
          ((evt.course_end_date is null) or
          (evt.course_end_date IS NOT NULL AND evt.course_end_date >= csr_cert_period_start_date))
          )))
   ---
   AND evt.activity_version_id = csr_activity_version_id
   --AND tdb.delegate_person_id = p_person_id
   AND ((csr_person_id IS NOT NULL AND tdb.delegate_person_id = csr_person_id)
                   OR (csr_contact_id IS NOT NULL AND tdb.delegate_contact_id = csr_contact_id)
                 )
   AND evt.parent_offering_id = ofr.offering_id
   AND OFR.DELIVERY_MODE_ID = ocu.CATEGORY_USAGE_ID
   AND tdb.booking_status_type_id = bst.booking_status_type_id
   AND bst.type <> 'C';

l_proc VARCHAR2(72) := g_package||'get_cme_online_event_id';
rec_cme_info csr_cme_info%rowtype;

l_person_id number;
l_contact_id number;
l_cert_period_start_date date;
l_cert_period_end_date date;

l_online_event_id ota_events.event_id%type;
l_online_evt_count number;

BEGIN
   	hr_utility.set_location('Entering :'||l_proc,5);

    --check for mult online evts and throw null if so
        l_online_evt_count := get_cme_onl_evt_count(p_user_id, p_user_type, p_cert_mbr_enrollment_id);

        if (l_online_evt_count > 1) then
           return null;
        end if;

        open csr_cme_info;
        fetch csr_cme_info into rec_cme_info;
        close csr_cme_info;

        OPEN csr_cert_enrl(rec_cme_info.cert_prd_enrollment_id);
        FETCH csr_cert_enrl into l_person_id, l_contact_id, l_cert_period_start_date, l_cert_period_end_date;
        CLOSE csr_cert_enrl;

     	hr_utility.set_location(' Step:'||l_proc,10);

        FOR rec IN get_enrl_status_on_update(rec_cme_info.object_id,
        				     l_cert_period_start_date,
        				     l_cert_period_end_date,
        				     l_person_id,
        				     l_contact_id)
	  LOOP

          if rec.online_flag = 'Y' then
	        l_online_event_id := rec.event_id;
	        exit;
	      end if;


        END LOOP;

   hr_utility.set_location('Leaving :'||l_proc,10);

   return l_online_event_id;

   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

       RETURN null;

End get_cme_online_event_id;

function get_cme_play_button(p_user_id in fnd_user.user_id%type,
   			     p_user_type in ota_attempts.user_type%type,
			     p_is_manager in varchar2,
   			     p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
return varchar2 is

CURSOR csr_event(csr_event_id ota_events.event_id%type) IS
SELECT
       evt.event_id,
       evt.event_type,
       ocu.synchronous_flag,
       ocu.online_flag,
       evt.course_start_date,
       evt.course_end_date
  FROM ota_events evt,
       ota_offerings ofr,
       ota_category_usages ocu
 WHERE evt.event_id = csr_event_id
   AND evt.parent_offering_id = ofr.offering_id
   AND OFR.DELIVERY_MODE_ID = ocu.CATEGORY_USAGE_ID;

CURSOR csr_cme is
select cert_prd_enrollment_id
  from ota_cert_mbr_enrollments
  where cert_mbr_enrollment_id = p_cert_mbr_enrollment_id;

l_proc VARCHAR2(72) := g_package||'get_cme_Player_Toolbar_Flag';
rec csr_event%rowtype;
rec_cme csr_cme%rowtype;
l_online_event_id ota_events.event_id%type;

l_return_play_btn VARCHAR2(30) := 'DISABLE_NOT_ENROLLED';
l_online_evt_count number;

BEGIN
   	hr_utility.set_location('Entering :'||l_proc,5);

    --check for mult online evts and throw null if so
    l_online_evt_count := get_cme_onl_evt_count(p_user_id, p_user_type, p_cert_mbr_enrollment_id);

    if (l_online_evt_count > 1) then
        return 'DISABLE_MULT_ENRL_EVENTS';
    end if;

    open csr_cme;
    fetch csr_cme into rec_cme;
    close csr_cme;

    l_online_event_id  := get_cme_online_event_id(p_user_id, p_user_type, p_cert_mbr_enrollment_id);

    open csr_event(l_online_event_id);
    fetch csr_event into rec;
    close csr_event;

    if (l_online_event_id is not null) then
        l_return_play_btn := OTA_LO_UTILITY.GET_PLAY_BUTTON(p_user_id,p_user_type, p_is_manager, rec.EVENT_ID, rec.EVENT_TYPE
							   ,rec.SYNCHRONOUS_FLAG, rec.ONLINE_FLAG
					   		   ,rec.COURSE_START_DATE ,rec.COURSE_END_DATE, null,rec_cme.cert_prd_enrollment_id);
    end if;
   hr_utility.set_location('Leaving :'||l_proc,10);

   return l_return_play_btn;

   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

       RETURN null;

End get_cme_play_button;


function get_cme_player_toolbar_flag(p_user_id in fnd_user.user_id%type,
   			     p_user_type in ota_attempts.user_type%type,
   			     p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
return varchar2 is

cursor csr_toolbar_flag(csr_event_id ota_events.event_id%type) is
select ofr.player_toolbar_flag
 from ota_events evt,
      ota_offerings ofr
 where evt.parent_offering_id = ofr.offering_id
   and evt.event_id = csr_event_id;

l_proc VARCHAR2(72) := g_package||'get_cme_Player_Toolbar_Flag';

l_player_toolbar_flag  ota_offerings.player_toolbar_flag%type;

l_online_event_id  ota_events.event_id%type;
l_online_evt_count number;

BEGIN
   	hr_utility.set_location('Entering :'||l_proc,5);

    --check for mult online evts and throw null if so
    l_online_evt_count := get_cme_onl_evt_count(p_user_id, p_user_type, p_cert_mbr_enrollment_id);

    if (l_online_evt_count > 1) then
        return null;
    end if;

    l_online_event_id  := get_cme_online_event_id(p_user_id, p_user_type, p_cert_mbr_enrollment_id);

        open csr_toolbar_flag(l_online_event_id);
        fetch csr_toolbar_flag into l_player_toolbar_flag;
        close csr_toolbar_flag;

   hr_utility.set_location('Leaving :'||l_proc,10);

   return l_player_toolbar_flag;

   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

       RETURN null;

End get_cme_player_toolbar_flag;

function get_cert_lo_status(p_user_id in fnd_user.user_id%type,
   			     p_user_type in ota_attempts.user_type%type,
   			     p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
return varchar2 is

CURSOR csr_event(csr_event_id ota_events.event_id%type) IS
SELECT
       evt.event_id,
       evt.event_type,
       ocu.synchronous_flag,
       ocu.online_flag,
       evt.course_start_date,
       evt.course_end_date,
       ofr.learning_object_id
  FROM ota_events evt,
       ota_offerings ofr,
       ota_category_usages ocu
 WHERE evt.event_id = csr_event_id
   AND evt.parent_offering_id = ofr.offering_id
   AND OFR.DELIVERY_MODE_ID = ocu.CATEGORY_USAGE_ID;

CURSOR csr_cme is
select cert_prd_enrollment_id
  from ota_cert_mbr_enrollments
 where cert_mbr_enrollment_id = p_cert_mbr_enrollment_id;


CURSOR c_prd_lo_status(l_lo_id in ota_offerings.learning_object_id%TYPE,
                       csr_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type) IS
  SELECT lesson_status,
         hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS',lesson_status)lesson_status_name
  FROM ota_performances
  WHERE user_id = p_user_id
        AND user_type = p_user_type
        AND learning_object_id = l_lo_id
        AND cert_prd_enrollment_id = csr_cert_prd_enrollment_id;

cursor csr_get_act is
 select cmb.object_id
 from ota_certification_members cmb,
      ota_cert_mbr_enrollments cme
 where cmb.certification_member_id = cme.cert_member_id
   and cme.cert_mbr_enrollment_id = p_cert_mbr_enrollment_id
   and cmb.object_type = 'H';

   CURSOR csr_prf_ord(p_activity_version_id in ota_activity_versions.activity_version_id%type,
                      p_user_id in number,
                      p_user_type in varchar2,
   	 	      csr_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type) IS
    SELECT prf.user_id,
           lo.learning_object_id,
           decode(prf.lesson_status, 'P', '1',
                   'C', '2',
                   'F', '3',
                   'I', '4',
                   'B', '5',
                   'N', '6') decode_lesson_status,
           prf.lesson_status lesson_status,
           prf.performance_id
      FROM ota_performances prf,
           ota_offerings ofr,
           ota_learning_objects lo
     WHERE
           prf.user_id  = p_user_id
       and prf.user_type  = p_user_type
       and lo.learning_object_id = prf.learning_object_id
       AND prf.cert_prd_enrollment_id = csr_cert_prd_enrollment_id
       and ofr.learning_object_id = lo.learning_object_id
       and ofr.activity_version_id = p_activity_version_id
     order by decode_lesson_status;

l_proc VARCHAR2(72) := g_package||'get_cert_lo_status';
rec csr_event%rowtype;
l_online_event_id ota_events.event_id%type;

l_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type;

l_status  VARCHAR2(30) := null;
l_status_name ota_booking_status_types_tl.name%TYPE := null;

l_return_lo_status VARCHAR2(30);
l_online_evt_count number;

rec_prf_ord csr_prf_ord%rowtype;
rec_get_act csr_get_act%rowtype;

BEGIN
   	hr_utility.set_location('Entering :'||l_proc,5);

 	open csr_cme;
        fetch csr_cme into l_cert_prd_enrollment_id;
        close csr_cme;

    --check for mult online evts and throw null if so
    l_online_evt_count := get_cme_onl_evt_count(p_user_id, p_user_type, p_cert_mbr_enrollment_id);

    if (l_online_evt_count > 1) then
        --Bug 4560354
        --return as Not Attempted
        --l_return_lo_status := hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS','N');
        --return l_return_lo_status;
	        open csr_get_act;
	        fetch csr_get_act into rec_get_act;
	        close csr_get_act;

	        if rec_get_act.object_id is not null then
	           open csr_prf_ord(rec_get_act.object_id, p_user_id, p_user_type, l_cert_prd_enrollment_id);
	           fetch csr_prf_ord into rec_prf_ord;
	           close csr_prf_ord;

	           if rec_prf_ord.lesson_status is not null then
	              l_return_lo_status := hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS',rec_prf_ord.lesson_status);
	           else
	              l_return_lo_status := hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS','N');
	           end if;
	        end if;

        return l_return_lo_status;
    end if;

    l_online_event_id  := get_cme_online_event_id(p_user_id, p_user_type, p_cert_mbr_enrollment_id);

    open csr_event(l_online_event_id);
    fetch csr_event into rec;
    close csr_event;

    open c_prd_lo_status(rec.learning_object_id, l_cert_prd_enrollment_id);
    fetch c_prd_lo_status into l_status, l_status_name;
    close c_prd_lo_status;

        If ( l_status is null ) Then
	        l_status := 'N';
    	    l_status_name := hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS','N');
	    End If;

        If ( (l_status = 'N') or (l_status = 'I') ) Then
 	        If ( rec.course_end_date < trunc(sysdate)  --Class is expired --Bug 3554773
--                     AND p_mode is null               ) Then -- Bug 3594377
                ) then
    			l_status := 'E';
	    		l_status_name := ota_utility.get_message('OTA','OTA_443001_OFFR_EXPIRED_STATUS');
  		    End If;
    	End If;

   hr_utility.set_location('Leaving :'||l_proc,10);

   return l_status_name;

   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

       RETURN null;

End get_cert_lo_status;

function get_cme_onl_evt_count(p_user_id in fnd_user.user_id%type,
   			     p_user_type in ota_attempts.user_type%type,
   			     p_cert_mbr_enrollment_id in ota_cert_mbr_enrollments.cert_mbr_enrollment_id%type)
return varchar2 is
CURSOR csr_cme_info IS
SELECT cme.cert_mbr_enrollment_id,
       cpe.cert_prd_enrollment_id,
       cme.object_version_number,
       cmb.object_id,
       cmb.certification_member_id,
       cme.member_status_code
  FROM ota_certification_members cmb,
       ota_cert_mbr_enrollments cme,
       ota_cert_prd_enrollments cpe
 WHERE cpe.cert_prd_enrollment_id = cme.cert_prd_enrollment_id
    AND cme.cert_member_id = cmb.certification_member_id
    AND cme.cert_mbr_enrollment_id = p_cert_mbr_enrollment_id;

CURSOR csr_cert_enrl(csr_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%type) IS
SELECT cre.person_id, cre.contact_id, cpe.cert_period_start_date, cpe.cert_period_end_date
 FROM ota_cert_enrollments cre,
      ota_cert_prd_enrollments cpe
 where cpe.cert_prd_enrollment_id = csr_cert_prd_enrollment_id
   and cpe.cert_enrollment_id = cre.cert_enrollment_id;


CURSOR get_enrl_status_on_update(csr_activity_version_id ota_events.activity_version_id%type,
				 csr_cert_period_start_date in date,
				 csr_cert_period_end_date in date,
                                 csr_person_id in number,
                                 csr_contact_id in number) IS

SELECT bst.type status,
       tdb.DATE_STATUS_CHANGED,
       evt.event_id,
       evt.event_type,
       ocu.synchronous_flag,
       ocu.online_flag,
       bst.type
  FROM ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types bst,
       ota_offerings ofr,
       ota_category_usages ocu
 WHERE evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
/*   AND (
        evt.course_start_date >= csr_cert_period_start_date
        AND
            (
             evt.course_end_date IS NOT NULL
             AND evt.course_end_date <= csr_cert_period_end_date
            )
            OR
            (
               evt.event_type = 'SELFPACED'
             AND csr_cert_period_end_date >= evt.course_start_date
             )
         )
   */
   ---
   AND ( ( evt.course_start_date >= csr_cert_period_start_date   and
                    nvl(evt.course_end_date,to_date('4712/12/31', 'YYYY/MM/DD')) <= csr_cert_period_end_date )
   /*  Bug 4515924         or  (evt.event_type ='SELFPACED'  and
                         evt.course_start_date< csr_cert_period_end_date  AND
                         nvl(evt.course_end_date,to_date('4712/12/31', 'YYYY/MM/DD')) >= csr_cert_period_end_date  ))*/
               or (evt.event_type = 'SELFPACED' AND
                    ((csr_cert_period_end_date >= evt.course_start_date) AND
                      ((evt.course_end_date is null) or
                       (evt.course_end_date IS NOT NULL AND evt.course_end_date >= csr_cert_period_start_date))
       )))
   ---
   AND evt.activity_version_id = csr_activity_version_id
   --AND tdb.delegate_person_id = p_person_id
   AND ((csr_person_id IS NOT NULL AND tdb.delegate_person_id = csr_person_id)
                   OR (csr_contact_id IS NOT NULL AND tdb.delegate_contact_id = csr_contact_id)
                 )
   AND evt.parent_offering_id = ofr.offering_id
   AND OFR.DELIVERY_MODE_ID = ocu.CATEGORY_USAGE_ID
   AND tdb.booking_status_type_id = bst.booking_status_type_id
   AND bst.type <> 'C';

l_proc VARCHAR2(72) := g_package||'get_cme_onl_evt_count';
rec_cme_info csr_cme_info%rowtype;

l_person_id number;
l_contact_id number;
l_cert_period_start_date date;
l_cert_period_end_date date;

l_online_event_id ota_events.event_id%type;
l_online_event_count number := 0;

BEGIN
   	hr_utility.set_location('Entering :'||l_proc,5);


        open csr_cme_info;
        fetch csr_cme_info into rec_cme_info;
        close csr_cme_info;

        OPEN csr_cert_enrl(rec_cme_info.cert_prd_enrollment_id);
        FETCH csr_cert_enrl into l_person_id, l_contact_id, l_cert_period_start_date, l_cert_period_end_date;
        CLOSE csr_cert_enrl;

     	hr_utility.set_location(' Step:'||l_proc,10);

        FOR rec IN get_enrl_status_on_update(rec_cme_info.object_id,
        				     l_cert_period_start_date,
        				     l_cert_period_end_date,
        				     l_person_id,
        				     l_contact_id)
	  LOOP

          if rec.online_flag = 'Y' then
	        l_online_event_id := rec.event_id;
            l_online_event_count := l_online_event_count + 1;
	        --exit;
	      end if;


        END LOOP;

   hr_utility.set_location('Leaving :'||l_proc,10);

   return '' || l_online_event_count;

   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

       RETURN null;

End get_cme_onl_evt_count;

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
return varchar2 IS

    l_proc VARCHAR2(72) := g_package||'format_lo_time';
    l_lo_time number;
    l_Seconds number;
    l_Minutes number;
    l_Hours number;
    l_formatted_hour varchar(20) := '';
    l_formatted_min varchar(20) := '';
    l_formatted_sec varchar(20) := '';
    l_formatted_time varchar(20) := '';

Begin
       If (pTime is null) Then
        l_lo_time := 0;
       Else
        l_lo_time := pTime;
       End If;

       l_lo_time := round(pTime);

       l_Seconds := l_lo_time mod 60;
       l_Minutes := floor(l_lo_time / 60);
       l_Hours := floor(l_Minutes/60);
       l_Minutes := l_Minutes - l_Hours * 60;

       If (l_Hours < 10) Then
           l_formatted_hour := '0' || l_Hours;
       Else
           l_formatted_hour := l_Hours;
       End If;

       If (l_Minutes < 10) Then
           l_formatted_min := '0' || l_Minutes;
       Else
           l_formatted_min := l_Minutes;
       End If;

       If (l_Seconds < 10) Then
           l_formatted_sec := '0' || l_Seconds;
       Else
           l_formatted_sec := l_Seconds;
       End If;

       fnd_message.set_name('OTA', 'OTA_443358_SRCH_LO_TIME');
       fnd_message.set_token ('HOUR', l_formatted_hour);
       fnd_message.set_token ('MIN', l_formatted_min);
       fnd_message.set_token ('SEC', l_formatted_sec);
       l_formatted_time := fnd_message.get();
       return l_formatted_time;
End format_lo_time;


function get_lme_online_event_id(p_lp_member_enrollment_id in ota_lp_member_enrollments.lp_member_enrollment_id%type)
return varchar2 is
CURSOR csr_lme_info IS
SELECT lme.lp_member_enrollment_id,
       lmb.ACTIVITY_VERSION_ID,
       lpe.lp_enrollment_id,
       lme.object_version_number,
       lmb.learning_path_member_id,
       lme.member_status_code,
       lpe.person_id,
       lpe.contact_id
  FROM ota_learning_path_members lmb,
       ota_lp_member_enrollments lme,
       ota_lp_enrollments lpe
 WHERE lpe.lp_enrollment_id = lme.lp_enrollment_id
    AND lme.LEARNING_PATH_MEMBER_ID = lmb.LEARNING_PATH_MEMBER_ID
    AND lme.lp_member_enrollment_id = p_lp_member_enrollment_id;


CURSOR get_enrl_status(csr_activity_version_id ota_events.activity_version_id%type,
                          csr_person_id in number,
                          csr_contact_id in number) IS
SELECT bst.type status,
       tdb.DATE_STATUS_CHANGED,
       evt.event_id,
       evt.event_type,
       ocu.synchronous_flag,
       ocu.online_flag,
       bst.type
  FROM ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types bst,
       ota_offerings ofr,
       ota_category_usages ocu
 WHERE evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
   AND evt.activity_version_id = csr_activity_version_id
   --AND tdb.delegate_person_id = p_person_id
   AND ((csr_person_id IS NOT NULL AND tdb.delegate_person_id = csr_person_id)
                   OR (csr_contact_id IS NOT NULL AND tdb.delegate_contact_id = csr_contact_id)
                 )
   AND evt.parent_offering_id = ofr.offering_id
   AND OFR.DELIVERY_MODE_ID = ocu.CATEGORY_USAGE_ID
   AND tdb.booking_status_type_id = bst.booking_status_type_id
   AND bst.type <> 'C';

l_proc VARCHAR2(72) := g_package||'get_lme_online_event_id';
rec_lme_info csr_lme_info%rowtype;

l_person_id number;
l_contact_id number;
l_cert_period_start_date date;
l_cert_period_end_date date;

l_online_event_id ota_events.event_id%type;
l_online_evt_count number;

BEGIN
   	hr_utility.set_location('Entering :'||l_proc,5);

        --check for mult online evts and throw null if so
        l_online_evt_count := get_lme_onl_evt_count(p_lp_member_enrollment_id);

        if (l_online_evt_count > 1) then
           return null;
        end if;

        open csr_lme_info;
        fetch csr_lme_info into rec_lme_info;
        close csr_lme_info;

     	hr_utility.set_location(' Step:'||l_proc,10);

        FOR rec IN get_enrl_status(rec_lme_info.activity_version_id,
        			   rec_lme_info.person_id,
        		           rec_lme_info.contact_id)
	  LOOP

          if rec.online_flag = 'Y' then
	        l_online_event_id := rec.event_id;
	        exit;
	      end if;


        END LOOP;

   hr_utility.set_location('Leaving :'||l_proc,10);

   return l_online_event_id;

   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

       RETURN null;

End get_lme_online_event_id;

function get_lme_play_button(p_user_id in fnd_user.user_id%type,
   			     p_user_type in ota_attempts.user_type%type,
			     p_is_manager in varchar2,
   			     p_lp_member_enrollment_id in ota_lp_member_enrollments.lp_member_enrollment_id%type)
return varchar2 is

CURSOR csr_event(csr_event_id ota_events.event_id%type) IS
SELECT
       evt.event_id,
       evt.event_type,
       ocu.synchronous_flag,
       ocu.online_flag,
       evt.course_start_date,
       evt.course_end_date
  FROM ota_events evt,
       ota_offerings ofr,
       ota_category_usages ocu
 WHERE evt.event_id = csr_event_id
   AND evt.parent_offering_id = ofr.offering_id
   AND OFR.DELIVERY_MODE_ID = ocu.CATEGORY_USAGE_ID;

l_proc VARCHAR2(72) := g_package||'get_lme_play_button';
rec csr_event%rowtype;
l_online_event_id ota_events.event_id%type;

l_return_play_btn VARCHAR2(30) := 'DISABLE_NOT_ENROLLED';
l_online_evt_count number;

BEGIN
   	hr_utility.set_location('Entering :'||l_proc,5);

    --check for mult online evts and throw null if so
    l_online_evt_count := get_lme_onl_evt_count(p_lp_member_enrollment_id);

    if (l_online_evt_count > 1) then
        return 'DISABLE_MULT_ENRL_EVENTS';
    end if;

    l_online_event_id  := get_lme_online_event_id(p_lp_member_enrollment_id);

    open csr_event(l_online_event_id);
    fetch csr_event into rec;
    close csr_event;

    if (l_online_event_id is not null) then
        l_return_play_btn := GET_PLAY_BUTTON(p_user_id,p_user_type, p_is_manager, rec.EVENT_ID, rec.EVENT_TYPE
							   ,rec.SYNCHRONOUS_FLAG, rec.ONLINE_FLAG
					   		   ,rec.COURSE_START_DATE ,rec.COURSE_END_DATE);
    end if;
   hr_utility.set_location('Leaving :'||l_proc,10);

   return l_return_play_btn;

   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

       RETURN null;

End get_lme_play_button;


function get_lme_player_toolbar_flag(p_lp_member_enrollment_id in ota_lp_member_enrollments.lp_member_enrollment_id%type)
return varchar2 is

cursor csr_toolbar_flag(csr_event_id ota_events.event_id%type) is
select ofr.player_toolbar_flag
 from ota_events evt,
      ota_offerings ofr
 where evt.parent_offering_id = ofr.offering_id
   and evt.event_id = csr_event_id;

l_proc VARCHAR2(72) := g_package||'get_lme_player_toolbar_flag';

l_player_toolbar_flag  ota_offerings.player_toolbar_flag%type;

l_online_event_id  ota_events.event_id%type;
l_online_evt_count number;

BEGIN
   	hr_utility.set_location('Entering :'||l_proc,5);

    --check for mult online evts and throw null if so
    l_online_evt_count := get_lme_onl_evt_count(p_lp_member_enrollment_id);

    if (l_online_evt_count > 1) then
        return null;
    end if;

    l_online_event_id  := get_lme_online_event_id(p_lp_member_enrollment_id);

        open csr_toolbar_flag(l_online_event_id);
        fetch csr_toolbar_flag into l_player_toolbar_flag;
        close csr_toolbar_flag;

   hr_utility.set_location('Leaving :'||l_proc,10);

   return l_player_toolbar_flag;

   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

       RETURN null;

End get_lme_player_toolbar_flag;

function get_lpe_lo_status(p_user_id in fnd_user.user_id%type,
   			     p_user_type in ota_attempts.user_type%type,
   			     p_lp_member_enrollment_id in ota_lp_member_enrollments.lp_member_enrollment_id%type)
return varchar2 is

CURSOR csr_event(csr_event_id ota_events.event_id%type) IS
SELECT
       evt.event_id,
       evt.event_type,
       ocu.synchronous_flag,
       ocu.online_flag,
       evt.course_start_date,
       evt.course_end_date,
       ofr.learning_object_id
  FROM ota_events evt,
       ota_offerings ofr,
       ota_category_usages ocu
 WHERE evt.event_id = csr_event_id
   AND evt.parent_offering_id = ofr.offering_id
   AND OFR.DELIVERY_MODE_ID = ocu.CATEGORY_USAGE_ID;

cursor csr_get_act is
 select lpm.activity_version_id
 from ota_learning_path_members lpm,
      ota_lp_member_enrollments lme
 where lpm.LEARNING_PATH_MEMBER_ID = lme.LEARNING_PATH_MEMBER_ID
   and lme.lp_member_enrollment_id = p_lp_member_enrollment_id;


   CURSOR csr_prf_ord(p_activity_version_id in ota_activity_versions.activity_version_id%type,
                      p_user_id in number,
                      p_user_type in varchar2) IS
    SELECT prf.user_id,
           lo.learning_object_id,
           decode(prf.lesson_status, 'P', '1',
                   'C', '2',
                   'F', '3',
                   'I', '4',
                   'B', '5',
                   'N', '6') decode_lesson_status,
           prf.lesson_status lesson_status,
           prf.performance_id
      FROM ota_performances prf,
           ota_offerings ofr,
           ota_learning_objects lo
     WHERE
           prf.user_id  = p_user_id
       and prf.user_type  = p_user_type
       and lo.learning_object_id = prf.learning_object_id
       and prf.cert_prd_enrollment_id is null
       and ofr.learning_object_id = lo.learning_object_id
       and ofr.activity_version_id = p_activity_version_id
     order by decode_lesson_status;

l_proc VARCHAR2(72) := g_package||'get_lpe_lo_status';
rec csr_event%rowtype;
rec_prf_ord csr_prf_ord%rowtype;
rec_get_act csr_get_act%rowtype;

l_online_event_id ota_events.event_id%type;

l_status  VARCHAR2(30) := null;
l_status_name ota_booking_status_types_tl.name%TYPE := null;

l_return_lo_status VARCHAR2(30);
l_online_evt_count number;
BEGIN
   	hr_utility.set_location('Entering :'||l_proc,5);

    --check for mult online evts and throw null if so
    l_online_evt_count := get_lme_onl_evt_count(p_lp_member_enrollment_id);

    if (l_online_evt_count > 1) then
        --return as Not Attempted
        --Bug 4560354
        --l_return_lo_status := hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS','N');
        open csr_get_act;
        fetch csr_get_act into rec_get_act;
        close csr_get_act;

        if rec_get_act.activity_version_id is not null then
           open csr_prf_ord(rec_get_act.activity_version_id, p_user_id, p_user_type);
           fetch csr_prf_ord into rec_prf_ord;
           close csr_prf_ord;

           if rec_prf_ord.lesson_status is not null then
              l_return_lo_status := hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS',rec_prf_ord.lesson_status);
           else
              l_return_lo_status := hr_general_utilities.get_lookup_meaning('OTA_CONTENT_PLAYER_STATUS','N');
           end if;
        end if;

        return l_return_lo_status;
    end if;

    l_online_event_id  := get_lme_online_event_id(p_lp_member_enrollment_id);

    open csr_event(l_online_event_id);
    fetch csr_event into rec;
    close csr_event;

    l_status_name := get_enroll_lo_status(p_user_id, p_user_type, rec.event_id, null, null, 1);

   hr_utility.set_location('Leaving :'||l_proc,10);

   return l_status_name;

   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

       RETURN null;

End get_lpe_lo_status;

function get_lme_onl_evt_count(p_lp_member_enrollment_id in ota_lp_member_enrollments.lp_member_enrollment_id%type)
return varchar2 is
CURSOR csr_lme_info IS
SELECT lme.lp_member_enrollment_id,
       lmb.ACTIVITY_VERSION_ID,
       lpe.lp_enrollment_id,
       lme.object_version_number,
       lmb.learning_path_member_id,
       lme.member_status_code,
       lpe.person_id,
       lpe.contact_id
  FROM ota_learning_path_members lmb,
       ota_lp_member_enrollments lme,
       ota_lp_enrollments lpe
 WHERE lpe.lp_enrollment_id = lme.lp_enrollment_id
    AND lme.LEARNING_PATH_MEMBER_ID = lmb.LEARNING_PATH_MEMBER_ID
    AND lme.lp_member_enrollment_id = p_lp_member_enrollment_id;


CURSOR get_enrl_status(csr_activity_version_id ota_events.activity_version_id%type,
                          csr_person_id in number,
                          csr_contact_id in number) IS
SELECT bst.type status,
       tdb.DATE_STATUS_CHANGED,
       evt.event_id,
       evt.event_type,
       ocu.synchronous_flag,
       ocu.online_flag,
       bst.type
  FROM ota_events evt,
       ota_delegate_bookings tdb,
       ota_booking_status_types bst,
       ota_offerings ofr,
       ota_category_usages ocu
 WHERE evt.event_id = tdb.event_id
   AND bst.booking_status_type_id = tdb.booking_status_type_id
   AND evt.activity_version_id = csr_activity_version_id
   --AND tdb.delegate_person_id = p_person_id
   AND ((csr_person_id IS NOT NULL AND tdb.delegate_person_id = csr_person_id)
                   OR (csr_contact_id IS NOT NULL AND tdb.delegate_contact_id = csr_contact_id)
                 )
   AND evt.parent_offering_id = ofr.offering_id
   AND OFR.DELIVERY_MODE_ID = ocu.CATEGORY_USAGE_ID
   AND tdb.booking_status_type_id = bst.booking_status_type_id
   AND bst.type <> 'C';

l_proc VARCHAR2(72) := g_package||'get_lme_onl_evt_count';
rec_lme_info csr_lme_info%rowtype;

l_person_id number;
l_contact_id number;
l_cert_period_start_date date;
l_cert_period_end_date date;

l_online_event_id ota_events.event_id%type;
l_online_event_count number := 0;
l_online_evt_count number;

BEGIN
   	hr_utility.set_location('Entering :'||l_proc,5);

        open csr_lme_info;
        fetch csr_lme_info into rec_lme_info;
        close csr_lme_info;

     	hr_utility.set_location(' Step:'||l_proc,10);

        FOR rec IN get_enrl_status(rec_lme_info.activity_version_id,
        			   rec_lme_info.person_id,
        		           rec_lme_info.contact_id)
	  LOOP

          if rec.online_flag = 'Y' then
      	        l_online_event_id := rec.event_id;
                  l_online_event_count := l_online_event_count + 1;
      	        --exit;
	  end if;

        END LOOP;

   hr_utility.set_location('Leaving :'||l_proc,10);

      return '' || l_online_event_count;

   EXCEPTION
       WHEN others THEN
           hr_utility.set_location('Leaving :'||l_proc,15);

       RETURN null;

End get_lme_onl_evt_count;

procedure get_active_cert_prds(
   p_event_id ota_events.event_id%type,
   p_person_id ota_cert_enrollments.contact_id%type,
   p_contact_id ota_cert_enrollments.contact_id%type,
   p_cert_prd_enrollment_ids  OUT NOCOPY varchar2) is

l_proc  VARCHAR2(72) :=      g_package|| 'get_active_cert_prds';

l_activity_version_id ota_events.activity_version_id%type;
l_cert_prd_enrollment_id ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE;
l_cert_prd_enrollment_ids varchar2(4000);


begin

    hr_utility.set_location(' Step:'||l_proc,10);

   if(p_person_id is not null) then
    for rec_active_cert_prd in csr_active_cert_prd_person(p_event_id, p_person_id)
    loop
        --populate OUT cert_prd_enrollment_ids params
		IF rec_active_cert_prd.cert_prd_enrollment_id IS NOT NULL THEN
	          if l_cert_prd_enrollment_ids is null then
	            l_cert_prd_enrollment_ids := rec_active_cert_prd.cert_prd_enrollment_id;
	          else
	            l_cert_prd_enrollment_ids := l_cert_prd_enrollment_ids || '^' || rec_active_cert_prd.cert_prd_enrollment_id;
  	          end if;
	    END IF;
	end loop;
    else
       for rec_active_cert_prd in csr_active_cert_prd_contact(p_event_id, p_contact_id)
       loop
        --populate OUT cert_prd_enrollment_ids params
		IF rec_active_cert_prd.cert_prd_enrollment_id IS NOT NULL THEN
	          if l_cert_prd_enrollment_ids is null then
	            l_cert_prd_enrollment_ids := rec_active_cert_prd.cert_prd_enrollment_id;
	          else
	            l_cert_prd_enrollment_ids := l_cert_prd_enrollment_ids || '^' || rec_active_cert_prd.cert_prd_enrollment_id;
  	          end if;
	    END IF;
	end loop;
    end if;

    p_cert_prd_enrollment_ids := l_cert_prd_enrollment_ids;
    hr_utility.set_location(' Step:'||l_proc,30);

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,40);
     p_cert_prd_enrollment_ids := null;
       --MULTI MESSAGE SUPPORT

end get_active_cert_prds;

-- ----------------------------------------------------------------------------
-- |--------------------< LO_has_cld_and_no_strt_url>-------------------------|
-- ----------------------------------------------------------------------------
--
 FUNCTION Lo_has_cld_and_no_strt_url
(p_learning_object_id          in   number default hr_api.g_number)
 RETURN varchar2 is
 --
 -- decalare cursor
  Cursor csr_par_with_cld_no_url is
  Select null
  From ota_learning_objects cld, ota_learning_objects par
  Where par.learning_object_id = cld.parent_learning_object_id
  And par.starting_url is null
  And par.learning_object_id = p_learning_object_id
  And rownum = 1;
  --
  -- decalre variables
  l_learning_object_flag         varchar2(10);
  l_return              varchar2(2) := 'N';
  l_proc                varchar2(72) := g_package||'LO_has_child_and_having_url';
  --
 BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  OPEN csr_par_with_cld_no_url;
  FETCH csr_par_with_cld_no_url INTO l_learning_object_flag;
  IF csr_par_with_cld_no_url%found THEN
   --
   l_return := 'Y';
   hr_utility.set_location('returning Y:'|| l_proc, 10);
  END IF;
  --
  CLOSE csr_par_with_cld_no_url;
  --
  hr_utility.set_location('Exiting:'|| l_proc, 20);
  --
  RETURN l_return;
 --
 End Lo_has_cld_and_no_strt_url;

end ota_lo_utility;

/
