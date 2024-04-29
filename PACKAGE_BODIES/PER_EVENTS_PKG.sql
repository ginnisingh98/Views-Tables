--------------------------------------------------------
--  DDL for Package Body PER_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EVENTS_PKG" as
/* $Header: peevt01t.pkb 120.1.12010000.2 2008/08/06 09:09:35 ubhat ship $ */
-- *****************************************************************
-- Table Handler for per_events
-- *****************************************************************

g_dummy number(1);      -- dummy variable for 'select 1...' statements

PROCEDURE CHECK_VALIDITY(X_INTERNAL_CONTACT_PERSON_ID NUMBER,
                          X_DATE_START                 DATE,
                          X_ORGANIZATION_RUN_BY_ID     NUMBER,
                          X_BUSINESS_GROUP_ID          NUMBER,
                          X_CTL_GLOBALS_END_OF_TIME    DATE,
                          X_LOCATION_ID                NUMBER,
                          X_EVENT_ID                   NUMBER) IS

L_TEMP1 NUMBER;
L_TEMP2 NUMBER;
L_TEMP3 NUMBER;
L_TEMP4 NUMBER;
L_TEMP5 NUMBER;


CURSOR CH1 IS
SELECT 1
FROM   per_people_f
where  person_id= X_INTERNAL_CONTACT_PERSON_ID
AND    X_DATE_START BETWEEN
       effective_Start_date and effective_end_Date;

CURSOR CH2 IS
SELECT 1
FROM   hr_organization_units H
WHERE  H.business_group_id + 0 = X_BUSINESS_GROUP_ID
AND    X_DATE_START BETWEEN H.date_from
            and NVL(H.date_to , X_CTL_GLOBALS_END_OF_TIME)
AND H.ORGANIZATION_ID = X_ORGANIZATION_RUN_BY_ID;

CURSOR CH3 IS
SELECT 1
FROM  hr_locations l
WHERE X_DATE_START <= nvl(l.inactive_date,X_CTL_GLOBALS_END_OF_TIME)
AND   LOCATION_ID = X_LOCATION_ID;
---
--- commented to allow update of organization run by of events.
---
/* CURSOR CH4 IS
SELECT 1
FROM   PER_PEOPLE_F P,
       PER_BOOKINGS B
WHERE  P.PERSON_ID = B.PERSON_ID
AND    B.EVENT_ID = X_EVENT_ID;

CURSOR CH5 IS
SELECT 1
FROM   PER_PEOPLE_F P,
       PER_BOOKINGS B
WHERE  P.PERSON_ID = B.PERSON_ID
AND    B.EVENT_ID = X_EVENT_ID
AND    X_DATE_START BETWEEN
       P.EFFECTIVE_START_DATE AND P.EFFECTIVE_END_DATE;  */

BEGIN

 IF X_ORGANIZATION_RUN_BY_ID IS NOT NULL THEN
  OPEN CH2;
  FETCH CH2 INTO L_TEMP2;
  IF CH2%NOTFOUND THEN
   CLOSE CH2;
   HR_UTILITY.SET_MESSAGE('801','HR_6627_EVENTS_ORG_NOT_VAL');
   HR_UTILITY.RAISE_ERROR;
  END IF;
  CLOSE CH2;
 END IF;
 IF X_LOCATION_ID IS NOT NULL THEN
  OPEN CH3;
  FETCH CH3 INTO L_TEMP3;
  IF CH3%NOTFOUND THEN
   CLOSE CH3;
   HR_UTILITY.SET_MESSAGE('801','HR_6628_EVENTS_LOC_NOT_VAL');
   HR_UTILITY.RAISE_ERROR;
  END IF;
  CLOSE CH3;
 END IF;
 IF X_INTERNAL_CONTACT_PERSON_ID IS NOT NULL THEN
  OPEN CH1;
  FETCH CH1 INTO L_TEMP1;
  IF CH1%NOTFOUND THEN
   CLOSE CH1;
   HR_UTILITY.SET_MESSAGE('801','HR_6660_EVENTS_INVAL_PERSON');
   HR_UTILITY.RAISE_ERROR;
  END IF;
  CLOSE CH1;
 END IF;

/*  OPEN CH4;
  FETCH CH4 INTO L_TEMP4;
  IF CH4%FOUND THEN
   CLOSE CH4;
   OPEN CH5;
   FETCH CH5 INTO L_TEMP5;
    IF CH5%NOTFOUND THEN
     CLOSE CH5;
     HR_UTILITY.SET_MESSAGE('801','HR_6656_EVENTS_PERSON_INVALID');
     HR_UTILITY.RAISE_ERROR;
    ELSE
     CLOSE CH5;
    END IF;
  ELSE
  CLOSE CH4;
  END IF;  */

END CHECK_VALIDITY;
--------------------------------------------------------------------------------
function EVENT_CAUSES_ASSIGNMENT_CHANGE (
--
--******************************************************************************
--* Returns TRUE if there is a change to the assignment on the event date. This
--* may indicate that the event causes the assignment change.
--******************************************************************************
--
        p_event_date    date,
        p_assignment_id number) return boolean is
--
v_change_exists boolean;
--
cursor csr_assignment is
        select  1
        from    per_assignments_f
        where   assignment_id   = p_assignment_id
        and     effective_start_date    = p_event_date;
--
begin
--
hr_utility.set_location ('per_events_pkg.event_causes_assignment_change',1);
--
open csr_assignment;
fetch csr_assignment into g_dummy;
v_change_exists := csr_assignment%found;
close csr_assignment;
--
return v_change_exists;
--
end event_causes_assignment_change;
--------------------------------------------------------------------------------
--
-- Fix for bug 3270091 starts here.
-- Modified the function to pass time start and time end parameters.
-- The check is carried out on interview time start and time end.
--
function INTERVIEW_DOUBLE_BOOKED (
--
--******************************************************************************
--* Returns TRUE if the applicant already has an interview at the time required*
--******************************************************************************
--
        p_person_id             number,
        p_interview_start_date  date,
        p_time_start            varchar2,
        p_time_end              varchar2,
        p_rowid                 varchar2 default null) return boolean is
--
v_interview_double_booked boolean;
l_time_start varchar2(5);
l_time_end varchar2(5);
l_same_time boolean;
--
cursor csr_double_booking is
        select event.time_start, nvl(event.time_end,'24:00')
        from    per_events event, per_assignments assignment
        where   (p_rowid is null or p_rowid <> event.rowid)
        and     assignment.person_id = p_person_id
        and     event.assignment_id = assignment.assignment_id
        and     event.event_or_interview = 'I'
        and     p_interview_start_date  between event.date_start
                                        and nvl(event.date_end,
                                                event.date_start);
--
begin
--
hr_utility.set_location ('per_events_pkg.interview_double_booked',1);
--
open csr_double_booking;
fetch csr_double_booking into l_time_start, l_time_end;
hr_utility.set_location ('per_events_pkg.interview_double_booked',2);
v_interview_double_booked := csr_double_booking%found;
close csr_double_booking;
--
hr_utility.set_location ('per_events_pkg.interview_double_booked',3);
l_same_time := v_interview_double_booked;
if v_interview_double_booked and p_time_start is not null and l_time_start is not null then
   hr_utility.set_location ('per_events_pkg.interview_double_booked',4);
   --
   -- If interview has start time entered then compare on basis ofstart and end time.
   -- The following code checks for the time overlap.
   --
   l_same_time :=
     ( ( ((substr(p_time_start,1,2) * 60) + substr(p_time_start,4,2)) >=
         ((substr(l_time_start,1,2) * 60) + substr(l_time_start,4,2))
        )  AND

       ( ((substr(p_time_start,1,2) * 60) + substr(p_time_start,4,2)) <=
         ( (substr(l_time_end,1,2) * 60) + substr(l_time_end,4,2))
        )
     )
     OR
     ( ( ((substr(l_time_start,1,2) * 60) + substr(l_time_start,4,2)) >=
         ((substr(p_time_start,1,2) * 60) + substr(p_time_start,4,2))
        )  AND

       ( ((substr(l_time_start,1,2) * 60) + substr(l_time_start,4,2)) <=
         ( (substr(p_time_end,1,2) * 60) + substr(p_time_end,4,2))
        )
     ) ;
    --
    hr_utility.set_location ('per_events_pkg.interview_double_booked',5);

end if;
hr_utility.set_location ('per_events_pkg.interview_double_booked',99);
--
return l_same_time;
--
end interview_double_booked;
--
-- Fix for bug 3270091 ends here.
--
--------------------------------------------------------------------------------
function INTERVIEWERS_ARE_BOOKED (
--
--******************************************************************************
--* Returns TRUE if there are interviewers booked for the interview passed in  *
--******************************************************************************
--
        p_event_id      number,
        p_error_if_true boolean default FALSE) return boolean is
--
cursor csr_booking is
        select  1
        from    per_bookings
        where   event_id        = p_event_id;
--
v_booking_exists        boolean := FALSE;
--
begin
--
hr_utility.set_location ('per_events_pkg.interviewers_are_booked',1);
--
open csr_booking;
fetch csr_booking into g_dummy;
v_booking_exists :=  csr_booking%found;
close csr_booking;
--
if v_booking_exists and p_error_if_true then
  hr_utility.set_message (801,'PER_7517_APP_INT_DELETE');
  hr_utility.raise_error;
end if;
--
return v_booking_exists;
--
end interviewers_are_booked;
--------------------------------------------------------------------------------
procedure CHECK_CURRENT_INTERVIEWERS (
--
--******************************************************************************
--* Returns an error if an interviewer currently booked for an interview is    *
--* unavailable on the updated interview date.                                 *
--******************************************************************************
--
        p_event_id                      number,
        p_new_interview_start_date      date) is
--
cursor csr_interview is
        select  interview.person_id
        from    per_bookings            INTERVIEW
        where   interview.event_id      = p_event_id;
        --
/*cursor csr_person_start (p_person_id in number) is
        select  min (effective_start_date)
        from    per_all_people_f
        where   person_id = p_person_id;
        --
cursor csr_person_end (p_person_id in number) is
        select  max (effective_start_date)
        from    per_all_people_f
        where   person_id = p_person_id;
        --
--
interviewer_start       date;
interviewer_end         date;*/

-- bug fix 2708777
-- Cursor to check whether the interviewer is a valid
-- employee or contingent worker on new  interview date.

cursor csr_person_exists(p_person_id in number) is
        select 'Y'
        from per_all_workforce_v
        where person_id = p_person_id
        and p_new_interview_start_date between effective_start_date
                and effective_end_date;
l_dummy varchar2(1);
--
begin
--
hr_utility.set_location ('Entering per_events_pkg.check_current_interviewers',1);
--
for interview in csr_interview LOOP
  -- bug fix 2708777 starts here.
  open csr_person_exists(interview.person_id);
  fetch csr_person_exists into l_dummy;

  if csr_person_exists%notfound then

    close csr_person_exists;
    -- bug fix 2708777 ends here.
    hr_utility.set_message (801,'HR_6752_EVENTS_DATE_INVALID');
    hr_utility.raise_error;
    --
  end if;
  --
  close csr_person_exists;
  --
end loop;
--
hr_utility.set_location ('Leaving per_events_pkg.check_current_interviewers',2);
--
end check_current_interviewers;
--------------------------------------------------------------------------------
procedure REQUEST_LETTER (
--
--******************************************************************************
--* Inserts a row in per_letter_requests for an interview, as long as there    *
--* are no pending entries for the letter type and an automatic letter is      *
--* required.                                                                  *
--******************************************************************************
--
        p_business_group_id             number,
        p_session_date                  date,
        p_user                          number,
        p_login_id                      number,
        p_assignment_status_type_id     number,
        p_person_id                     number,
        p_assignment_id                 number) is
--
cursor csr_check_letter is
select null
from    per_letter_gen_statuses s
where   s.business_group_id + 0 = p_business_group_id
and     s.assignment_status_type_id = p_ASSIGNMENT_STATUS_TYPE_ID
and     s.enabled_flag = 'Y';

cursor csr_vacancy_id is
Select vacancy_id
From per_all_assignments_f
Where assignment_id = p_assignment_id
And p_session_date between effective_start_date and effective_end_date;

l_vacancy_id  number;
--
--fix for bug 7019343 starts here.
CURSOR csr_check_manual_or_auto IS
SELECT 1
FROM  PER_LETTER_REQUESTS PLR,
      PER_LETTER_GEN_STATUSES PLGS
WHERE PLGS.business_group_id + 0 = p_business_group_id
AND   PLR.business_group_id +0 = p_business_group_id
AND   PLGS.assignment_status_type_id = p_assignment_status_type_id
AND   PLR.letter_type_id = PLGS.letter_type_id
AND   PLR.auto_or_manual = 'MANUAL';
l_dummy_number number;
--fix for bug 7019343 ends here.

begin
--
hr_utility.set_location ('per_events_pkg.request_letter', 1);
--
open csr_check_letter;
fetch csr_check_letter into g_dummy;
if csr_check_letter%notfound then
   return ;
end if ;
--
open csr_vacancy_id;
fetch csr_vacancy_id into l_vacancy_id;
if csr_vacancy_id%NOTFOUND then null;
end if;
close csr_vacancy_id;
--
--fix for bug 7019343 starts here.
  open csr_check_manual_or_auto;
  fetch csr_check_manual_or_auto into l_dummy_number;
  if csr_check_manual_or_auto%found then
     close csr_check_manual_or_auto;
     return;
  end if;
  close csr_check_manual_or_auto;

  if (nvl(fnd_profile.value('HR_LETTER_BY_VACANCY'),'N')='Y') then

   hr_utility.set_location('HR_LETTER_BY_VACANCY = Y',10);
  insert into per_letter_requests
  (       letter_request_id
  ,       business_group_id
  ,       letter_type_id
  ,       request_status
  ,       auto_or_manual
  ,       date_from
  ,       last_update_date
  ,       last_updated_by
  ,       last_update_login
  ,       created_by
  ,       creation_date
  ,       vacancy_id)
  select  per_letter_requests_s.nextval
  ,       p_business_group_id
  ,       s.letter_type_id
  ,       'PENDING'
  ,       'AUTO'
  ,       p_session_date
  ,       sysdate
  ,       p_user
  ,       p_login_id
  ,       p_user
  ,       sysdate
  ,       l_vacancy_id
  from    per_letter_gen_statuses s
  where   s.business_group_id + 0 = p_business_group_id
  and     s.assignment_status_type_id = p_assignment_status_type_id
  and     s.enabled_flag = 'Y'
  and     not exists
          (select null
           from   per_letter_requests r
           where  r.letter_type_id = s.letter_type_id
           and    r.business_group_id + 0 = p_business_group_id
           and    r.business_group_id + 0 = s.business_group_id
           and    r.request_status = 'PENDING'
           and    r.auto_or_manual = 'AUTO'
	   and    r.vacancy_id 	= l_vacancy_id);
  --
  close csr_check_letter;
  --

  -- bug fix 3648618.
  -- '+0' removed from where clause to improve performance.

  insert into per_letter_request_lines
  (       letter_request_line_id
  ,       business_group_id
  ,       letter_request_id
  ,       person_id
  ,       assignment_id
  ,       assignment_status_type_id
  ,       date_from
  ,       last_update_date
  ,       last_updated_by
  ,       last_update_login
  ,       created_by
  ,       creation_date)
  select  per_letter_request_lines_s.nextval
  ,       p_business_group_id
  ,       r.letter_request_id
  ,       p_person_id
  ,       p_ASSIGNMENT_ID
  ,       p_ASSIGNMENT_STATUS_TYPE_ID
  ,       p_session_date
  ,       sysdate
  ,       p_user
  ,       p_login_id
  ,       p_user
  ,       sysdate
  from    per_letter_requests r
  where   exists
                  (select null
                  from    per_letter_gen_statuses s
                  where   s.letter_type_id = r.letter_type_id
                  and     s.business_group_id + 0 = p_business_group_id
                  and     s.business_group_id + 0 = r.business_group_id + 0
                  and     s.assignment_status_type_id =
                          p_ASSIGNMENT_STATUS_TYPE_ID
                  and     s.enabled_flag = 'Y')
  and     not exists
                  (select l.assignment_id
                  from    per_letter_request_lines l
                  where   l.letter_request_id = r.letter_request_id
                  and     l.business_group_id + 0 = p_business_group_id
                  and     l.assignment_id = p_ASSIGNMENT_ID
                  and     l.business_group_id +0 = r.business_group_id + 0)
  and    r.request_status = 'PENDING'
  and    r.business_group_id  = p_business_group_id   -- bug fix 3648618
  and    r.vacancy_id 	= l_vacancy_id;
  else

   -- Profile HR: Letter by Vacancy has not been set to Yes
   insert into per_letter_requests
  (       letter_request_id
  ,       business_group_id
  ,       letter_type_id
  ,       request_status
  ,       auto_or_manual
  ,       date_from
  ,       last_update_date
  ,       last_updated_by
  ,       last_update_login
  ,       created_by
  ,       creation_date
  ,       vacancy_id)
  select  per_letter_requests_s.nextval
  ,       p_business_group_id
  ,       s.letter_type_id
  ,       'PENDING'
  ,       'AUTO'
  ,       p_session_date
  ,       sysdate
  ,       p_user
  ,       p_login_id
  ,       p_user
  ,       sysdate
  ,       l_vacancy_id
  from    per_letter_gen_statuses s
  where   s.business_group_id + 0 = p_business_group_id
  and     s.assignment_status_type_id = p_assignment_status_type_id
  and     s.enabled_flag = 'Y'
  and     not exists
          (select null
           from   per_letter_requests r
           where  r.letter_type_id = s.letter_type_id
           and    r.business_group_id + 0 = p_business_group_id
           and    r.business_group_id + 0 = s.business_group_id
           and    r.request_status = 'PENDING'
           and    r.auto_or_manual = 'AUTO'
);
  --
  close csr_check_letter;
  --

  -- bug fix 3648618.
  -- '+0' removed from where clause to improve performance.

  insert into per_letter_request_lines
  (       letter_request_line_id
  ,       business_group_id
  ,       letter_request_id
  ,       person_id
  ,       assignment_id
  ,       assignment_status_type_id
  ,       date_from
  ,       last_update_date
  ,       last_updated_by
  ,       last_update_login
  ,       created_by
  ,       creation_date)
  select  per_letter_request_lines_s.nextval
  ,       p_business_group_id
  ,       r.letter_request_id
  ,       p_person_id
  ,       p_ASSIGNMENT_ID
  ,       p_ASSIGNMENT_STATUS_TYPE_ID
  ,       p_session_date
  ,       sysdate
  ,       p_user
  ,       p_login_id
  ,       p_user
  ,       sysdate
  from    per_letter_requests r
  where   exists
                  (select null
                  from    per_letter_gen_statuses s
                  where   s.letter_type_id = r.letter_type_id
                  and     s.business_group_id + 0 = p_business_group_id
                  and     s.business_group_id + 0 = r.business_group_id + 0
                  and     s.assignment_status_type_id =
                          p_ASSIGNMENT_STATUS_TYPE_ID
                  and     s.enabled_flag = 'Y')
  and     not exists
                  (select l.assignment_id
                  from    per_letter_request_lines l
                  where   l.letter_request_id = r.letter_request_id
                  and     l.business_group_id + 0 = p_business_group_id
                  and     l.assignment_id = p_ASSIGNMENT_ID
                  and     l.business_group_id +0 = r.business_group_id + 0)
  and    r.request_status = 'PENDING'
  and    r.business_group_id  = p_business_group_id   -- bug fix 3648618
 ;

end if;
--fix for bug 7019343 ends here.
end request_letter;
--------------------------------------------------------------------------------
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Event_Id                     IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Internal_Contact_Person_Id          NUMBER,
                     X_Organization_Run_By_Id              NUMBER,
                     X_Assignment_Id                       NUMBER,
                     X_Date_Start                          DATE,
                     X_Type                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Contact_Telephone_Number            VARCHAR2,
                     X_Date_End                            DATE,
                     X_Emp_Or_Apl                          VARCHAR2,
                     X_Event_Or_Interview                  VARCHAR2,
                     X_External_Contact                    VARCHAR2,
                     X_Time_End                            VARCHAR2,
                     X_Time_Start                          VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
                     X_ctl_globals_end_of_time             DATE
 ) IS

 L_DUMMY  NUMBER;
 l_party_id number;

 CURSOR C IS
 SELECT rowid FROM PER_EVENTS
 WHERE event_id = X_Event_Id;

 CURSOR C2 IS
 SELECT PER_EVENTS_S.NEXTVAL
 FROM SYS.DUAL;

 CURSOR LOCATION_CHECK IS
 select 1
 from   hr_locations l
 where  l.location_id = X_Location_Id
 and    nvl(l.inactive_date,X_ctl_globals_end_of_time) >= X_date_start;

 cursor csr_get_party_id is
 select max(party_id) from per_all_people_f
 where person_id = (select asg.person_id
                    from per_all_assignments_f asg
                    where asg.assignment_id = X_Assignment_Id
                    and X_Date_Start between asg.effective_start_date
                                         and asg.effective_end_date);

BEGIN
  -- As this package is used by PERWSERW and PERWSGEB, in case of
  -- PERWSERW the X_Event_Or_Interview will always be 'I' ie.Interview
  -- but in case of PERWSGEB, the X_Event_Or_Interview will always be 'E'
  -- Therefore if it equals 'E' then it must be called from the PERWSGEB
  -- form, hence call the procedure below

  IF X_Event_Or_Interview = 'E' THEN
   CHECK_VALIDITY(X_Internal_Contact_person_Id,
                  X_Date_Start,
                  X_Organization_Run_By_Id,
                  X_Business_group_Id,
                  X_ctl_globals_end_of_time,
                  X_Location_Id,
                  X_Event_Id);
  END IF;


IF X_Event_Or_Interview <> 'E' THEN
 IF X_Location_Id IS NOT NULL THEN
  OPEN LOCATION_CHECK;
  FETCH LOCATION_CHECK INTO L_DUMMY;
   IF LOCATION_CHECK%NOTFOUND THEN
    CLOSE LOCATION_CHECK;
    HR_UTILITY.SET_MESSAGE('801','HR_6747_EVENTS_LOC_INACTIVE');
    HR_UTILITY.RAISE_ERROR;
   ELSE
    CLOSE LOCATION_CHECK;
   END IF;
 END IF;
END IF;

  OPEN C2;
  FETCH C2 INTO X_Event_Id;
  CLOSE C2;
  --
  -- Get party_id from per_all_people_f using assignment_id
  --
  open csr_get_party_id;
  fetch csr_get_party_id into l_party_id;
  close csr_get_party_id;
  --
  INSERT INTO PER_EVENTS(
          event_id,
          business_group_id,
          location_id,
          internal_contact_person_id,
          organization_run_by_id,
          assignment_id,
          date_start,
          type,
          comments,
          contact_telephone_number,
          date_end,
          emp_or_apl,
          event_or_interview,
          external_contact,
          time_end,
          time_start,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          party_id
         ) VALUES (
          X_Event_Id,
          X_Business_Group_Id,
          X_Location_Id,
          X_Internal_Contact_Person_Id,
          X_Organization_Run_By_Id,
          X_Assignment_Id,
          X_Date_Start,
          X_Type,
          X_Comments,
          X_Contact_Telephone_Number,
          X_Date_End,
          X_Emp_Or_Apl,
          X_Event_Or_Interview,
          X_External_Contact,
          X_Time_End,
          X_Time_Start,
          X_Attribute_Category,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15,
          X_Attribute16,
          X_Attribute17,
          X_Attribute18,
          X_Attribute19,
          X_Attribute20,
          l_party_id
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
   CLOSE C;
   HR_UTILITY.SET_MESSAGE(801,'HR_6153_ALL_PROCEDURE_FAIL');
   HR_UTILITY.SET_MESSAGE_TOKEN('PROCEDURE','INSERT_ROW');
   HR_UTILITY.SET_MESSAGE_TOKEN('STEP','1');
   HR_UTILITY.RAISE_ERROR;
  end if;
  CLOSE C;
END Insert_Row;
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Event_Id                              NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Location_Id                           NUMBER,
                   X_Internal_Contact_Person_Id            NUMBER,
                   X_Organization_Run_By_Id                NUMBER,
                   X_Assignment_Id                         NUMBER,
                   X_Date_Start                            DATE,
                   X_Type                                  VARCHAR2,
                   X_Comments                              VARCHAR2,
                   X_Contact_Telephone_Number              VARCHAR2,
                   X_Date_End                              DATE,
                   X_Emp_Or_Apl                            VARCHAR2,
                   X_Event_Or_Interview                    VARCHAR2,
                   X_External_Contact                      VARCHAR2,
                   X_Time_End                              VARCHAR2,
                   X_Time_Start                            VARCHAR2,
                   X_Attribute_Category                    VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2,
                   X_Attribute16                           VARCHAR2,
                   X_Attribute17                           VARCHAR2,
                   X_Attribute18                           VARCHAR2,
                   X_Attribute19                           VARCHAR2,
                   X_Attribute20                           VARCHAR2
) IS

  CURSOR C IS
      SELECT *
      FROM   PER_EVENTS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Event_Id   NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    HR_UTILITY.SET_MESSAGE(801,'HR_6153_ALL_PROCEDURE_FAIL');
    HR_UTILITY.SET_MESSAGE_TOKEN('PROCEDURE','LOCK_ROW');
    HR_UTILITY.SET_MESSAGE_TOKEN('STEP','1');
    HR_UTILITY.RAISE_ERROR;
  end if;
  CLOSE C;
Recinfo.attribute19 := rtrim(Recinfo.attribute19);
Recinfo.attribute20 := rtrim(Recinfo.attribute20);
Recinfo.type := rtrim(Recinfo.type);
Recinfo.comments := rtrim(Recinfo.comments);
Recinfo.contact_telephone_number := rtrim(Recinfo.contact_telephone_number);
Recinfo.emp_or_apl := rtrim(Recinfo.emp_or_apl);
Recinfo.event_or_interview := rtrim(Recinfo.event_or_interview);
Recinfo.external_contact := rtrim(Recinfo.external_contact);
Recinfo.time_end := rtrim(Recinfo.time_end);
Recinfo.time_start := rtrim(Recinfo.time_start);
Recinfo.attribute_category := rtrim(Recinfo.attribute_category);
Recinfo.attribute1 := rtrim(Recinfo.attribute1);
Recinfo.attribute2 := rtrim(Recinfo.attribute2);
Recinfo.attribute3 := rtrim(Recinfo.attribute3);
Recinfo.attribute4 := rtrim(Recinfo.attribute4);
Recinfo.attribute5 := rtrim(Recinfo.attribute5);
Recinfo.attribute6 := rtrim(Recinfo.attribute6);
Recinfo.attribute7 := rtrim(Recinfo.attribute7);
Recinfo.attribute8 := rtrim(Recinfo.attribute8);
Recinfo.attribute9 := rtrim(Recinfo.attribute9);
Recinfo.attribute10 := rtrim(Recinfo.attribute10);
Recinfo.attribute11 := rtrim(Recinfo.attribute11);
Recinfo.attribute12 := rtrim(Recinfo.attribute12);
Recinfo.attribute13 := rtrim(Recinfo.attribute13);
Recinfo.attribute14 := rtrim(Recinfo.attribute14);
Recinfo.attribute15 := rtrim(Recinfo.attribute15);
Recinfo.attribute16 := rtrim(Recinfo.attribute16);
Recinfo.attribute17 := rtrim(Recinfo.attribute17);
Recinfo.attribute18 := rtrim(Recinfo.attribute18);
  if (
          (   (Recinfo.event_id = X_Event_Id)
           OR (    (Recinfo.event_id IS NULL)
               AND (X_Event_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.location_id = X_Location_Id)
           OR (    (Recinfo.location_id IS NULL)
               AND (X_Location_Id IS NULL)))
    AND (   (Recinfo.internal_contact_person_id = X_Internal_Contact_Person_Id)
           OR (    (Recinfo.internal_contact_person_id IS NULL)
               AND (X_Internal_Contact_Person_Id IS NULL)))
      AND (   (Recinfo.organization_run_by_id = X_Organization_Run_By_Id)
           OR (    (Recinfo.organization_run_by_id IS NULL)
               AND (X_Organization_Run_By_Id IS NULL)))
      AND (   (Recinfo.assignment_id = X_Assignment_Id)
           OR (    (Recinfo.assignment_id IS NULL)
               AND (X_Assignment_Id IS NULL)))
      AND (   (Recinfo.date_start = X_Date_Start)
           OR (    (Recinfo.date_start IS NULL)
               AND (X_Date_Start IS NULL)))
      AND (   (Recinfo.type = X_Type)
           OR (    (Recinfo.type IS NULL)
               AND (X_Type IS NULL)))
      AND (   (Recinfo.comments = X_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.contact_telephone_number = X_Contact_Telephone_Number)
           OR (    (Recinfo.contact_telephone_number IS NULL)
               AND (X_Contact_Telephone_Number IS NULL)))
      AND (   (Recinfo.date_end = X_Date_End)
           OR (    (Recinfo.date_end IS NULL)
               AND (X_Date_End IS NULL)))
      AND (   (Recinfo.emp_or_apl = X_Emp_Or_Apl)
           OR (    (Recinfo.emp_or_apl IS NULL)
               AND (X_Emp_Or_Apl IS NULL)))
      AND (   (Recinfo.event_or_interview = X_Event_Or_Interview)
           OR (    (Recinfo.event_or_interview IS NULL)
               AND (X_Event_Or_Interview IS NULL)))
      AND (   (Recinfo.external_contact = X_External_Contact)
           OR (    (Recinfo.external_contact IS NULL)
               AND (X_External_Contact IS NULL)))
      AND (   (Recinfo.time_end = X_Time_End)
           OR (    (Recinfo.time_end IS NULL)
               AND (X_Time_End IS NULL)))
      AND (   (Recinfo.time_start = X_Time_Start)
           OR (    (Recinfo.time_start IS NULL)
               AND (X_Time_Start IS NULL)))
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND  (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.attribute16 = X_Attribute16)
           OR (    (Recinfo.attribute16 IS NULL)
               AND (X_Attribute16 IS NULL)))
      AND (   (Recinfo.attribute17 = X_Attribute17)
           OR (    (Recinfo.attribute17 IS NULL)
               AND (X_Attribute17 IS NULL)))
      AND (   (Recinfo.attribute18 = X_Attribute18)
           OR (    (Recinfo.attribute18 IS NULL)
               AND (X_Attribute18 IS NULL)))
      AND (   (Recinfo.attribute19 = X_Attribute19)
           OR (    (Recinfo.attribute19 IS NULL)
               AND (X_Attribute19 IS NULL)))
      AND (   (Recinfo.attribute20 = X_Attribute20)
           OR (    (Recinfo.attribute20 IS NULL)
               AND (X_Attribute20 IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Event_Id                            NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Internal_Contact_Person_Id          NUMBER,
                     X_Organization_Run_By_Id              NUMBER,
                     X_Assignment_Id                       NUMBER,
                     X_Date_Start                          DATE,
                     X_Type                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Contact_Telephone_Number            VARCHAR2,
                     X_Date_End                            DATE,
                     X_Emp_Or_Apl                          VARCHAR2,
                     X_Event_Or_Interview                  VARCHAR2,
                     X_External_Contact                    VARCHAR2,
                     X_Time_End                            VARCHAR2,
                     X_Time_Start                          VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
                     X_ctl_globals_end_of_time             DATE
) IS

 L_DUMMY NUMBER;

 CURSOR LOCATION_CHECK IS
 select 1
 from   hr_locations l
 where  l.location_id = X_Location_Id
 and    nvl(l.inactive_date,X_ctl_globals_end_of_time) >= X_Date_Start;

BEGIN
 -- As this package is used by PERWSERW and PERWSGEB, in case of
 -- PERWSERW the X_Event_Or_Interview will always be 'I' ie.Interview
 -- but in case of PERWSGEB, the X_Event_Or_Interview will always be 'E'
 -- Therefore if it equals 'E' then it must be called from the PERWSGEB
 -- form, hence call the procedure below

  IF X_Event_Or_Interview = 'E' THEN
   CHECK_VALIDITY(X_Internal_Contact_person_Id,
                  X_Date_Start,
                  X_Organization_Run_By_Id,
                  X_Business_group_Id,
                  X_ctl_globals_end_of_time,
                  X_Location_Id,
                  X_Event_Id);
  END IF;


IF X_Event_Or_Interview <> 'E' THEN
 IF X_Location_Id IS NOT NULL THEN
  OPEN LOCATION_CHECK;
  FETCH LOCATION_CHECK INTO L_DUMMY;
   IF LOCATION_CHECK%NOTFOUND THEN
    CLOSE LOCATION_CHECK;
    HR_UTILITY.SET_MESSAGE('801','HR_6747_EVENTS_LOC_INACTIVE');
    HR_UTILITY.RAISE_ERROR;
   ELSE
    CLOSE LOCATION_CHECK;
   END IF;
 END IF;
END IF;

  UPDATE PER_EVENTS
  SET

    event_id                                  =    X_Event_Id,
    business_group_id                         =    X_Business_Group_Id,
    location_id                               =    X_Location_Id,
   internal_contact_person_id                =    X_Internal_Contact_Person_Id,
    organization_run_by_id                    =    X_Organization_Run_By_Id,
    assignment_id                             =    X_Assignment_Id,
    date_start                                =    X_Date_Start,
    type                                      =    X_Type,
    comments                                  =    X_Comments,
    contact_telephone_number                  =    X_Contact_Telephone_Number,
    date_end                                  =    X_Date_End,
    emp_or_apl                                =    X_Emp_Or_Apl,
    event_or_interview                        =    X_Event_Or_Interview,
    external_contact                          =    X_External_Contact,
    time_end                                  =    X_Time_End,
    time_start                                =    X_Time_Start,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    attribute16                               =    X_Attribute16,
    attribute17                               =    X_Attribute17,
    attribute18                               =    X_Attribute18,
    attribute19                               =    X_Attribute19,
    attribute20                               =    X_Attribute20
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    HR_UTILITY.SET_MESSAGE(801,'HR_6153_ALL_PROCEDURE_FAIL');
    HR_UTILITY.SET_MESSAGE_TOKEN('PROCEDURE','UPDATE_ROW');
    HR_UTILITY.SET_MESSAGE_TOKEN('STEP','1');
    HR_UTILITY.RAISE_ERROR;
  end if;

END Update_Row;

-- X_Message is passed from PERWSERW and PERWSGEB
-- and the procedure will display the right message
--
-- P1 refers to PERWSERW
-- P2 refers to PERWSGEB
PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                     X_Event_Id NUMBER,
                     X_Business_Group_Id NUMBER,
                     X_Message  VARCHAR2,
                     X_Form     VARCHAR2
                ) IS
L_DUMMY  NUMBER;
L_DUMMY2 NUMBER;

 CURSOR CHILD_CHECK IS
 SELECT 1
 FROM  PER_BOOKINGS
 WHERE BUSINESS_GROUP_ID + 0 = X_Business_Group_Id
 AND   EVENT_ID = X_Event_Id;

 CURSOR PAY_CHANGE_CHECK IS
 SELECT 1
 FROM   PER_PAY_PROPOSALS PP
 WHERE  PP.EVENT_ID = X_Event_Id;

 BEGIN

 OPEN CHILD_CHECK;
 FETCH CHILD_CHECK INTO L_DUMMY;
 IF CHILD_CHECK%FOUND THEN
  CLOSE CHILD_CHECK;
  HR_UTILITY.SET_MESSAGE('801',X_Message);
  HR_UTILITY.RAISE_ERROR;
 ELSE
  CLOSE CHILD_CHECK;
 END IF;

 -- If the procedure is called from PERWSGEB then skip this check
 -- as this check relates to PERWSERW
 IF X_Form = 'P1' then
  OPEN PAY_CHANGE_CHECK;
  FETCH PAY_CHANGE_CHECK INTO L_DUMMY2;
   IF PAY_CHANGE_CHECK%FOUND THEN
    CLOSE PAY_CHANGE_CHECK;
    HR_UTILITY.SET_MESSAGE('801','HR_7100_EVENTS_CHANGE_EXIST');
    HR_UTILITY.RAISE_ERROR;
   ELSE
    CLOSE PAY_CHANGE_CHECK;
   END IF;
 END IF;

  DELETE FROM PER_EVENTS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    HR_UTILITY.SET_MESSAGE(801,'HR_6153_ALL_PROCEDURE_FAIL');
    HR_UTILITY.SET_MESSAGE_TOKEN('PROCEDURE','DELETE_ROW');
    HR_UTILITY.SET_MESSAGE_TOKEN('STEP','1');
    HR_UTILITY.RAISE_ERROR;
  end if;
END Delete_Row;

END PER_EVENTS_PKG;

/
