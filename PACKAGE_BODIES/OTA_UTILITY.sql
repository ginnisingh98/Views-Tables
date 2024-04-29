--------------------------------------------------------
--  DDL for Package Body OTA_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_UTILITY" as
/* $Header: ottomint.pkb 120.43.12010000.13 2009/08/31 13:50:06 smahanka ship $ */
g_package  varchar2(33) := '  ota_utility.';  -- Global package name

g_wait_list_booking     varchar2(1)     := 'W';
g_placed_booking        varchar2(1)     := 'P';
g_attended_booking      varchar2(1)     := 'A';
g_cancelled_booking     varchar2(1)     := 'C';
g_requested_booking     varchar2(1)     := 'R';
--
-- Event Statuses
--
g_full_event            varchar2(1)     := 'W';
g_normal_event          varchar2(1)     := 'N';
g_planned_event         varchar2(1)     := 'P';
g_closed_event          varchar2(1)     := 'C';


Function get_test_time(p_lo_time number)
return varchar2
is
l_lo_time number := nvl(p_lo_time,0);
l_Seconds number;
    l_Minutes number;
    l_Hours number;
    l_formatted_hour varchar(20) := '';
    l_formatted_min varchar(20) := '';
    l_formatted_sec varchar(20) := '';
    l_formatted_time varchar(50) := '';

begin

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

       return l_formatted_time;
end get_test_time;

function is_con_prog_periodic(p_name in varchar2)
return boolean
is

cursor get_con_prog_sch
is
select a.resubmit_interval,a.resubmit_end_date
 from fnd_concurrent_requests a, fnd_concurrent_programs b
 where a.concurrent_program_id =  b.concurrent_program_id
 and b.concurrent_program_name = p_name
 and b.application_id = 810
 and a.status_code ='I'
 and a.hold_flag ='N'
 and rownum=1
 order by a.request_id desc;

l_resubmit_interval varchar2(10);
l_resubmit_end_date date ;

begin

open get_con_prog_sch;
    fetch get_con_prog_sch into
    l_resubmit_interval,l_resubmit_end_date;
    close get_con_prog_sch;

    if l_resubmit_interval is not null and trunc(sysdate) <= nvl(l_resubmit_end_date,hr_api.g_eot) then

	return true;
    else
	return false;

    end if;

end is_con_prog_periodic;

-- ----------------------------------------------------------------
-- ------------------<get_resource_count >--------------------
-- ----------------------------------------------------------------
function get_resource_count(peventid number)
return varchar2
is
l_resource_count number := 0;
l_meaning varchar2(30);
l_return_value Varchar2(100);

cursor getcount
is select count(resource_booking_id)
from ota_resource_bookings
where event_id = peventid;
--and status ='C';

begin

     open getcount;
      fetch getcount into l_resource_count;
      close getcount;

      l_meaning := get_lookup_meaning('OTA_OBJECT_TYPE','R',810);

      l_return_value := l_resource_count||' ' ||l_meaning;

      return l_return_value;

end get_resource_count;



function get_default_comp_upd_level(p_obj_id in number,
                                    p_obj_type varchar2)
return varchar2
is

l_return_value varchar2(200) := null;
l_lookup_value varchar2(30) := null;

cursor default_run_value is
SELECT waav.text_value FROM WF_ACTIVITY_ATTR_VALUES WAAV
 WHERE WAAV.PROCESS_ACTIVITY_ID = (select max(instance_id) from
 wf_process_activities wpa where wpa.process_name =
'OTA_COMPETENCE_UPDATE_JSP_PRC'
 and  wpa.activity_name  = 'OTA_COMPETENCE_NOTIFY_APPROVAL'
 and  wpa.instance_label  = 'OTA_COMPETENCE_NOTIFY_APPROVAL'
and wpa.process_version =  wpa.process_version
and wpa.process_item_type = 'HRSSA' )
 AND  WAAV.NAME = 'HR_APPROVAL_REQ_FLAG' ;

-- if above returns null then take from below
cursor default_value is
 select text_default from wf_activity_attributes where NAME = 'HR_APPROVAL_REQ_FLAG'
 and activity_item_type = 'HRSSA'
 and activity_name  = 'OTA_COMPETENCE_NOTIFY_APPROVAL';

 cursor value_course_level is
 select oav.competency_update_level from
 ota_activity_versions oav
 --, ota_offerings off
 where oav.activity_version_id = p_obj_id;
 --and off.offering_id = p_obj_id;

begin



if p_obj_type = 'OFFERING' then
open value_course_level;
fetch value_course_level into l_lookup_value;
close value_course_level;


end if;

if l_lookup_value is null then

open default_run_value;
fetch default_run_value into l_lookup_value;
close default_run_value;
end if;

if l_lookup_value is null then

open default_value;
fetch default_value into l_lookup_value;
close default_value;

end if;

l_return_value := get_lookup_meaning('OTA_COMPETENCY_UPDATE_LEVEL',l_lookup_value,810);


return l_return_value;

end get_default_comp_upd_level;

-- ----------------------------------------------------------------
-- ------------------<get_session_count >--------------------
-- ----------------------------------------------------------------
function get_session_count(peventid number)
return varchar2
is
l_event_count number := 0;
l_meaning varchar2(30);
l_return_value Varchar2(2000);

cursor getcount
is select count(event_id) from
ota_events where
parent_event_id = peventid and
           parent_event_id is not null;

begin

      open getcount;
      fetch getcount into l_event_count;
      close getcount;

      fnd_message.set_name('OTA','OTA_443973_SSN_COUNT');
      fnd_message.set_token('COUNT', l_event_count);

      l_return_value := fnd_message.get();

      return l_return_value;

end get_session_count;

-- ----------------------------------------------------------------
-- ------------------<get_child_count >--------------------
-- ----------------------------------------------------------------
function get_child_count(p_object_id     NUMBER,
                         p_object_type  VARCHAR2)
return varchar2
is
l_child_count  NUMBER := 0;
l_message_name VARCHAR2(40);
l_return_value VARCHAR2(2000);

begin

    IF p_object_type = 'OFS' THEN
       l_message_name := 'OTA_443971_OFF_COUNT';
       l_child_count := ota_utility.get_course_offering_count(p_object_id);
 ELSIF p_object_type = 'CLS' THEN
       l_message_name := 'OTA_443972_EVT_COUNT';
       l_child_count := ota_utility.get_event_count(p_object_id);
   END IF;
  -- Modified for bug#5158213
  -- IF l_child_count <> 0 THEN
       fnd_message.set_name('OTA',l_message_name);
       fnd_message.set_token('COUNT', l_child_count);

       l_return_value := fnd_message.get();
  -- ELSE
  --    l_return_value := null;
  -- END IF;

 RETURN l_return_value;

end get_child_count;

-- ----------------------------------------------------------------------------
-- |-----------------------------< ignore_dff_validation >---------------------------|
-- ----------------------------------------------------------------------------
Procedure ignore_dff_validation(p_dff_name in varchar2)
is
l_proc   varchar2(72) := g_package||'ignore_dff_validation';

l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                           hr_dflex_utility.l_ignore_dfcode_varray();

begin
hr_utility.set_location('Entering:'||l_proc, 5);

l_add_struct_d.extend(1);
        l_add_struct_d(l_add_struct_d.count) := p_dff_name;

        hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);


        hr_utility.set_location('Leaving:'||l_proc, 5);

end ignore_dff_validation;


-- ----------------------------------------------------------------------------
-- |-----------------------------< GET_DESCIRPTION >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to retrieve enrollment and event information
--   for AR interface.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_line_id,
--   p_uom
--
-- Out Arguments:
--   p_description
--   p_course_end_date
--   e_return_status
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

Procedure GET_DESCRIPTION (p_line_id   in number,
               p_uom       in varchar2,
               x_description out nocopy varchar2,
               x_course_end_date out nocopy date,
               x_return_status out nocopy varchar2)
IS

l_event_title     ota_events_tl.title%type; --MLS Change added _tl
l_start_date   date;
l_end_date     date;
l_full_name    ota_customer_contacts_v.full_name%type;
l_contact_id   hz_cust_account_roles.cust_account_role_id%type;
l_version_name ota_activity_versions_tl.version_name%type; --MLS Change added _tl


l_max_attendee  number(3);
l_min_attendee number(3);


l_title_prompt varchar2(80) ;
l_start_prompt varchar2(80) ;
l_end_prompt   varchar2(80) ;

l_student_prompt  varchar2(80) ;

l_version_name_prompt   varchar2(80) ;

l_date_format varchar2(200);

l_max_prompt   varchar2(80) ;


Cursor c_enrollment
IS
select tav.version_name,
    evt.Title,
    evt.Course_Start_Date,
    evt.Course_End_Date,
       tdb.delegate_contact_id
From
   ota_Delegate_bookings tdb,
   ota_Events_vl evt, --MLS change _vl added
   ota_activity_versions_tl tav -- MLS change _tl added
Where
   evt.event_id = tdb.event_id and
   tdb.line_id = p_line_id and
      evt.activity_version_id = tav.activity_version_id;



Cursor c_student
IS
Select full_name
From
    ota_customer_contacts_v
Where
    contact_id = l_contact_id;

CURSOR C_Event
IS
Select
   tav.version_name,
   evt.title,
      evt.Course_Start_Date,
      evt.course_End_Date,
      evt.Maximum_Attendees
FROM ota_events_vl evt, -- MLS change _vl added
   ota_activity_versions_tl tav  --MLS change _tl added
WHERE evt.line_id = p_line_id and
      evt.activity_version_id = tav.activity_version_id;

cursor c_date_format is
select value
from v$parameter
where name ='nls_date_format';


  l_proc    varchar2(72) := g_package||'get_description';

BEGIN
 hr_utility.set_location('Entering:'||l_proc, 5);
 OPEN c_date_format;
 FETCH c_date_format into l_date_format;
 CLOSE c_date_format;

 IF p_uom= 'ENR' THEN
    hr_utility.set_location('Entering:'||l_proc, 10);
    l_title_prompt :=
      ota_utility.Get_lookup_meaning ('OTA_ENROLL_INVOICE' ,'EVENT',810);
    l_start_prompt :=
      ota_utility.Get_lookup_meaning ('OTA_ENROLL_INVOICE' ,'START',810);
    l_end_prompt  :=
      ota_utility.Get_lookup_meaning ('OTA_ENROLL_INVOICE' ,'END',810);

    l_student_prompt :=
      ota_utility.Get_lookup_meaning ('OTA_ENROLL_INVOICE' ,'STUDENT',810);

    l_version_name_prompt :=
      ota_utility.Get_lookup_meaning ('OTA_ENROLL_INVOICE' ,'ACTIVITY',810);


      OPEN  C_Enrollment;
   FETCH C_enrollment into l_version_name,
            l_event_title,
            l_start_date,
            l_end_date,
            l_contact_id;

   IF c_enrollment%found then


      OPEN c_student;

            FETCH c_student into l_full_name;
      CLOSE c_student;

            IF l_version_name_prompt is not null then
               x_description := l_version_name_prompt ||' '|| l_version_name;
      END IF;

            IF l_student_prompt is not null then
               x_description := x_description||','||l_student_prompt ||' '|| l_full_name;
      END IF;

            IF l_start_prompt is not null then
               x_description := x_description||','||l_start_prompt ||' '|| to_char(l_start_date,l_date_format);
      END IF;

            IF l_end_prompt is not null then
               x_description := x_description||','||l_end_prompt ||' '|| to_char(l_end_date,l_date_format);
      END IF;

            IF l_title_prompt is not null then
               x_description := x_description||','||l_title_prompt ||' '|| l_event_title;
      END IF;


   -- x_course_end_date := l_end_date;
         x_course_end_date := null;
   End if;
   CLOSE C_enrollment;

ELSIF p_uom = 'EVT' THEN
      hr_utility.set_location('Entering:'||l_proc, 15);
      l_title_prompt  :=
      ota_utility.Get_lookup_meaning ('OTA_EVENT_INVOICE' ,'EVENT',810);

      l_start_prompt :=
      ota_utility.Get_lookup_meaning ('OTA_EVENT_INVOICE' ,'START',810);

      l_end_prompt   :=
      ota_utility.Get_lookup_meaning ('OTA_EVENT_INVOICE' ,'END',810);

      l_max_prompt   :=
      ota_utility.Get_lookup_meaning ('OTA_EVENT_INVOICE' ,'MAX',810);

      l_version_name_prompt   :=
      ota_utility.Get_lookup_meaning ('OTA_EVENT_INVOICE' ,'ACTIVITY',810);

   OPEN  C_event;
    FETCH C_event into
           l_version_name,
           l_event_title,
           l_start_date,
           l_end_date,
              l_max_attendee;
   If c_event%found then


            IF l_version_name_prompt is not null then
               x_description := l_version_name_prompt ||' '|| l_version_name;
      END IF;
      IF l_max_prompt is not null then
               x_description := x_description||','||l_max_prompt ||' '||to_char(l_max_attendee);
      END IF;

            IF l_start_prompt is not null then
               x_description := x_description||','||l_start_prompt ||' '|| to_char(l_start_date,l_date_format);
      END IF;

            IF l_end_prompt is not null then
               x_description := x_description||','||l_end_prompt ||' '|| to_char(l_end_date,l_date_format);
      END IF;

            IF l_title_prompt is not null then
               x_description := x_description||','||l_title_prompt ||' '|| l_event_title;
      END IF;

      -- x_course_end_date := l_end_date;
         x_course_end_date := null;


   End if;

   CLOSE C_event;
END IF;
hr_utility.set_location('Leaving:'||l_proc, 15);

END;

-- ----------------------------------------------------------------------------
-- |------------------------< get_invoice_rule  >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  is used to retrieve invoicing rule for Order Line.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_line_id
--
-- Out Argument
--  p_invoice_rule
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

PROCEDURE GET_INVOICE_RULE
(
p_line_id      IN    NUMBER,
p_invoice_rule  OUT NOCOPY   VARCHAR2
)
IS

CURSOR c_invoice_rule
IS
SELECT
   invoicing_rule_id
FROM
   oe_order_lines_all
WHERE
   line_id = p_line_id;

  l_proc    varchar2(72) := g_package||'get_invoice_rule';
  l_rule_id    ra_rules.rule_id%type;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  OPEN c_invoice_rule;
  FETCH c_invoice_rule INTO l_rule_id;
  IF c_invoice_rule%found THEN
   IF l_rule_id = -2 THEN
         p_invoice_rule := 'ADVANCED';
      ELSIF l_rule_id  = -3 THEN
         p_invoice_rule := 'ARREARS';
   END IF;
  END IF;
  CLOSE c_invoice_rule;
  hr_utility.set_location(' Leaving:'||l_proc, 10);

END;

-- ----------------------------------------------------------------------------
-- |----------------------< get_booking_status_type  >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will retrieve enrollment Status Type.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_status_type_id,
--
-- Out Arguments:
--   p_type
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


PROCEDURE get_booking_status_type(
      p_status_type_id IN number,
      p_type OUT NOCOPY Varchar2)

IS

  l_proc    varchar2(72) := g_package||'get_booking_status_type';


CURSOR c_status_type IS
SELECT Type
FROM OTA_BOOKING_STATUS_TYPES
WHERE booking_status_type_id = p_status_type_id;

l_status_type     ota_booking_status_types.type%type ;


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  OPEN c_status_type;
  FETCH c_status_type INTO l_status_type;
  IF c_status_type%found THEN
      p_type := l_status_type;
  END IF;
  CLOSE c_status_type;
  hr_utility.set_location(' Leaving:'||l_proc, 10);

END;

--8855548
-- ----------------------------------------------------------------------------
-- |----------------------< get_booking_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will retrieve enrollment Status.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_status_type_id,
--
-- Out Arguments:
--   p_status
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


PROCEDURE get_booking_status(
      p_status_type_id IN number,
      p_status OUT NOCOPY Varchar2)

IS

  l_proc    varchar2(72) := g_package||'get_booking_status';


CURSOR c_status_type IS
SELECT name
FROM OTA_BOOKING_STATUS_TYPES_VL
WHERE booking_status_type_id = p_status_type_id;

l_status_name     ota_booking_status_types.name%type ;


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  OPEN c_status_type;
  FETCH c_status_type INTO l_status_name;
  IF c_status_type%found THEN
		p_status := l_status_name;
  END IF;
  CLOSE c_status_type;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

END;


-- ----------------------------------------------------------------------------
-- |-----------------------------< Check_enrollment>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check whether Enrollment exist or not.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_line_id,
--
-- In Arguments:
--   x_valid,
--   x_return_status

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
Procedure check_enrollment (p_line_id IN Number ,
            x_valid   OUT NOCOPY varchar2,
            x_return_status OUT NOCOPY varchar2 )

IS

CURSOR C_enrollment
IS
Select null
FROM
OTA_DELEGATE_BOOKINGS
WHERE
Line_id = p_line_id;


l_proc   varchar2(72) := g_package||'check_enrollment';
l_exists  varchar2(1) ;
l_valid  varchar2(1) := 'N';

BEGIN

hr_utility.set_location('Entering:'||l_proc, 15);
open c_enrollment;
fetch c_enrollment into l_exists;
if c_enrollment%found then
   l_valid := 'Y';
end If;
CLOSE C_enrollment;
x_valid := l_valid;
hr_utility.set_location('Leaving:'||l_proc, 15);

END;
--

-- ----------------------------------------------------------------------------
-- |-----------------------------------< Check_event>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This Procedure  will be used to check Whether Event exist.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_line_id,
--
-- In Arguments:
--   x_valid,
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
 Procedure check_event (p_line_id IN Number,
            x_valid   OUT NOCOPY varchar2,
            x_return_status OUT NOCOPY varchar2 )
IS

CURSOR C_event
IS
Select null
FROM
OTA_EVENTS
WHERE
Line_id = p_line_id;


l_proc   varchar2(72) := g_package||'check_event';
l_exists varchar2(1) ;
l_valid  varchar2(1) := 'N';

BEGIN

hr_utility.set_location('Entering:'||l_proc, 15);
open c_event;
fetch c_event into l_exists;
if c_event%found then
   l_valid := 'T';
end If;
CLOSE C_event;
x_valid := l_valid;
hr_utility.set_location('Leaving:'||l_proc, 15);

END;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_lookup_meaning>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function  will be used to get lookup meaning.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_lookup_type
--   p_lookup_code
--   p_application_id
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

Function Get_lookup_meaning (
--******************************************************************************
--* Returns the meaning for a lookup code of a specified type.
--******************************************************************************
--
        p_lookup_type       varchar2,
        p_lookup_code       varchar2,
     p_application_id    number) return varchar2 is
--
cursor csr_lookup is
        select meaning
        from    hr_lookups
        where   lookup_type     = p_lookup_type
        and     lookup_code     = p_lookup_code
        and     enabled_flag = 'Y';
--
l_meaning       varchar2(80) := null;
--
begin
--
-- Only open the cursor if the parameters are going to retrieve anything
--
if p_lookup_type is not null and p_lookup_code is not null then
  --
  open csr_lookup;
  fetch csr_lookup into l_meaning;
  close csr_lookup;
  --
end if;
--
return l_meaning;
--
end get_lookup_meaning;


-- ----------------------------------------------------------------------------
-- |--------------------------------< CHECK_INVOICE >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a used to check the invoice of Order Line.
--
-- IN
-- p_line_id
-- p_org_id
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

PROCEDURE  CHECK_INVOICE (
p_Line_id   IN    NUMBER,
p_Org_id IN NUMBER,
p_exist OUT NOCOPY    VARCHAR2)
IS

l_proc   varchar2(72) := g_package||'check_invoice';
l_invoice_quantity   oe_order_lines.invoiced_quantity%type;


CURSOR c_invoice IS
SELECT
   decode(invoiced_quantity,null,0,invoiced_quantity)
FROM
   oe_order_lines_all
WHERE
   line_id = p_line_id;


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

   OPEN c_invoice;
   FETCH c_invoice into l_invoice_quantity;
   IF c_invoice%found THEN
         IF l_invoice_quantity = 1 then
      p_exist := 'Y';
         ELSE
         p_exist := 'N';
         END IF;
      END IF;
   CLOSE c_invoice;


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
p_Line_id   NUMBER,
p_activity varchar2)

return boolean

IS

l_proc   varchar2(72) := g_package||'Check_wf_Status' ;
l_exist  varchar2(1);
l_return    boolean :=False;

CURSOR line_wf IS
        SELECT null
     FROM wf_item_activity_statuses_v wf
     WHERE activity_name = p_activity
           AND activity_status_code = 'NOTIFIED'
           AND item_type = 'OEOL'
                 AND item_key = to_char(p_line_id);

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


-- ----------------------------------------------------------------------------
-- |-------------------------< other_bookings_clash >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Other Bookings Clash
--
--              Checks if the booking being made clashes with any other
--              bookings for the delegate
--              Note - bookings only clash if they are confirmed
--
Procedure other_bookings_clash (p_delegate_person_id     in varchar2,
                               p_delegate_contact_id    in varchar2,
                      p_event_id               in number,
                               p_booking_status_type_id in varchar2,
                               p_return_status out nocopy boolean,
                p_warn   out nocopy boolean)
is
--
  --
  -- cursor to select any confirmed bookings for events which
  -- clash with the event being booked
  --
  cursor c_other_person_bookings is
    select bst.type
    from ota_delegate_bookings db,
         ota_booking_status_types bst,
         ota_events ev,
         ota_events evt
    where db.delegate_person_id = p_delegate_person_id
      and db.booking_status_type_id = bst.booking_status_type_id
      and bst.type <> g_cancelled_booking
      and db.event_id = ev.event_id
      and evt.event_id = p_event_id
      and ev.event_id <> p_event_id
      and ((
           ev.course_start_date = ev.course_end_date and
           evt.course_start_date = evt.course_end_date and
           ev.course_start_date = evt.course_start_date and
           nvl(evt.course_start_time, '-99:99') <= nvl(ev.course_end_time, '99:99') and
           nvl(evt.course_end_time, '99:99') >= nvl(ev.course_start_time, '-99:99')
          )
      or  (
           (ev.course_start_date <> ev.course_end_date or
           evt.course_start_date <> evt.course_end_date) and
           ev.course_start_date <= evt.course_end_date and
           ev.course_end_date >= evt.course_start_date
          ))
    order by bst.type;
  --
  cursor c_other_contact_bookings is
    select bst.type
    from ota_delegate_bookings db,
         ota_booking_status_types bst,
         ota_events ev,
         ota_events evt
    where db.delegate_contact_id = p_delegate_contact_id
      and db.booking_status_type_id = bst.booking_status_type_id
      and bst.type <> g_cancelled_booking
      and db.event_id = ev.event_id
      and evt.event_id = p_event_id
      and ev.event_id <> p_event_id
      and ev.course_start_date <= evt.course_end_date
      and ev.course_end_date >= evt.course_start_date
      order by bst.type;
  --
  l_proc           varchar2(72) := g_package||'other_bookings_clash';
  l_result         boolean;
  l_warn           boolean := false;
  l_booking_status varchar2(80);
  l_dummy          varchar2(80);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   p_warn := False;
   p_return_status := False;
  if p_delegate_person_id is not null then
  --
    open c_other_person_bookings;
      fetch c_other_person_bookings into l_dummy;
      l_result := c_other_person_bookings%found;
    close c_other_person_bookings;
  --
  elsif p_delegate_contact_id is not null then
  --
    open c_other_contact_bookings;
      fetch c_other_contact_bookings into l_dummy;
      l_result := c_other_contact_bookings%found;
    close c_other_contact_bookings;
  --
  end if;
  --

  if not l_result then
  --
    l_booking_status := ota_tdb_bus.booking_status_type(p_booking_status_type_id);

    if l_booking_status in (g_attended_booking, g_placed_booking) and
       l_dummy in (g_attended_booking, g_placed_booking) then
    --
      p_return_status := True;
    --
    else
    --
      if l_booking_status <> g_cancelled_booking then
      --
        p_warn := true;
      --
      end if;
    --
    end if;
  --
  end if;

  if p_delegate_contact_id is null and p_delegate_person_id is null then
     p_warn := true;
  end if;
  --

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End other_bookings_clash;
-- --------------------------------------------------------------------------
-- |--------------------------<GET_BG_NAME>-------------------------------|--
-- -----------------------------------------------------------------------
-- {Start of Comments}
-- Description:
-- This function will be used to get the Business Group Name for the Organization ID
-- that is passed into it.
-- IN
-- p_organization_id
--
-- OUT
-- p_return
-- Post Failure
-- None
--
-- Access Status:
-- PUBLIC
-- {End of Comments}
-----------------------------------------------------------------------------
FUNCTION get_bg_name(p_organization_id NUMBER) RETURN VARCHAR2
IS
l_proc      VARCHAR2(72) := g_package||'Get_Bg_Name';
l_return    hr_all_organization_units.name%TYPE;

CURSOR bg_cr IS
SELECT bg.name
  FROM hr_all_organization_units org,
     hr_all_organization_units bg
 WHERE org.business_group_id = bg.organization_id
   AND org.organization_id = p_organization_id;

BEGIN
   hr_utility.set_location('Entering :'||l_proc,5);
   OPEN bg_cr;
    FETCH bg_cr INTO l_return;
    CLOSE bg_cr;
  RETURN l_return;
    hr_utility.set_location('Leaving:'||l_proc,10);
EXCEPTION
WHEN others THEN
   l_return := NULL;
 RETURN l_return;
END get_bg_name;

-- --------------------------------------------------------------------------
-- |--------------------------<get_commitment_detail>-------------------------------|--
-- -----------------------------------------------------------------------
-- {Start of Comments}
-- Description:
-- This procedure will call the OM APi to return the commitment details when a line_id
-- is passed into it.
-- IN          Reqd Type
-- p_line_id         NUMBER
--
-- OUT
-- p_commitment_id      NUMBER
-- p_commitment_number     VARCHAR2
-- p_commitment_start_date DATE
-- p_commitment_end_date   DATE
--
-- Post Failure
-- None
--
-- Access Status:
-- PUBLIC
-- {End of Comments}
-----------------------------------------------------------------------------
PROCEDURE get_commitment_detail
(p_line_id     IN NUMBER,
 p_commitment_id OUT NOCOPY NUMBER,
 p_commitment_number OUT NOCOPY VARCHAR2,
 p_commitment_start_date OUT NOCOPY DATE,
 p_commitment_end_date OUT NOCOPY DATE)
IS
--
-- Declare cursors and local variables.
--
l_proc      VARCHAR2(72) := g_package||'get_commitment_detail';
l_check_om_installed VARCHAR2(1);

l_execute_proc    VARCHAR2(4000);

BEGIN
   hr_utility.set_location('Entering :'||l_proc,5);
        l_check_om_installed := check_product_installed(660);
      IF l_check_om_installed = 'Y' THEN
         l_execute_proc := '
         BEGIN
         oe_commitment_util.get_commitment_info(:p_line_id,
                          :x_commitment_id,
                          :x_commitment_number,
                          :x_commitment_start_date,
                          :x_commitment_end_date);
         END;';
      EXECUTE IMMEDIATE l_execute_proc
                  USING IN p_line_id,
              OUT p_commitment_id,
              OUT p_commitment_number,
                   OUT p_commitment_start_date,
              OUT p_commitment_end_date;
      END IF;
    hr_utility.set_location('Leaving:'||l_proc,80);
EXCEPTION
WHEN others THEN
    hr_utility.set_location('Leaving:'||l_proc,90);
END get_commitment_detail;
--

-- --------------------------------------------------------------------------
-- |--------------------------<check_product_installed>-------------------------------|--
-- -----------------------------------------------------------------------
-- {Start of Comments}
-- Description:
-- This function will return a VARCHAR indicating if the particular product code
-- passed in is installed or not.
-- IN          Reqd Type
-- p_application_id     NUMBER
--
-- OUT
-- l_return       VARCHAR2
--
-- Post Failure
-- None
--
-- Access Status:
-- PUBLIC
-- {End of Comments}
-----------------------------------------------------------------------------
FUNCTION check_product_installed
(p_application_id    IN NUMBER) RETURN VARCHAR2
IS
--
-- Declare cursors and local variables.
--
l_proc      VARCHAR2(72) := g_package||'check_product_installed';
l_status VARCHAR2(1);
l_industry  VARCHAR2(1);
l_return_val   VARCHAR2(1) := 'N';

BEGIN
    hr_utility.set_location('Entering :'||l_proc,5);
   IF (fnd_installation.get ( p_application_id,
               p_application_id,
               l_status,
               l_industry)) THEN
       IF l_status IN ('I', 'S') THEN
          l_return_val := 'Y';
     ELSE l_return_val := 'N';
      END IF;
       ELSE
       l_return_val := 'N';
        END IF;
RETURN l_return_val;
    hr_utility.set_location('Leaving:'||l_proc,80);
EXCEPTION
WHEN others THEN
    l_return_val := 'N';
    RETURN l_return_val;
    hr_utility.set_location('Leaving:'||l_proc,90);
END  check_product_installed;


-- ----------------------------------------------------------------
-- ------------------<get_delivery_method >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the delivery method name/category name of the particular
-- activity
-- IN
-- p_activity_id
-- p_return_value
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_Delivery_Method(p_activity_version_id    IN  NUMBER,
              p_return_value     IN     VARCHAR2)
RETURN VARCHAR2 IS

CURSOR get_primary_dm_cr IS
SELECT lookup.meaning   Dm_Name,
       catusg.category  Dm_Code
  FROM ota_act_cat_inclusions actcat,
       ota_category_usages catusg,
       hr_lookups lookup
 WHERE actcat.category_usage_id=  catusg.category_usage_id
   AND actcat.primary_flag='Y'
   AND catusg.category = lookup.lookup_code
   AND lookup.lookup_type ='ACTIVITY_CATEGORY'
   AND catusg.type='DM'
   AND actcat.activity_version_id = p_activity_version_id;

CURSOR get_first_dm_cr IS
SELECT lookup.meaning   dm_name,
       catusg.category  dm_code
  FROM ota_act_cat_inclusions actcat,
       ota_category_usages catusg,
       hr_lookups lookup
 WHERE actcat.category_usage_id=  catusg.category_usage_id
   AND catusg.category = lookup.lookup_code
   AND lookup.lookup_type ='ACTIVITY_CATEGORY'
   AND catusg.type='DM'
   AND actcat.activity_version_id = p_activity_version_id;

-- Added for Bug No.2941052
-- Get Delivery Method name corresponding to code 'INCLASS'
CURSOR get_dm_name IS
SELECT meaning
  FROM hr_lookups
 WHERE lookup_type ='ACTIVITY_CATEGORY'
   AND lookup_code = 'INCLASS';

l_proc         VARCHAR2(72) := g_package||'Get_Delivery_Method';

l_pr_dm_cat       hr_lookups.lookup_code%TYPE;
l_pr_dm_name      hr_lookups.meaning%TYPE;


l_return_dm_cat   hr_lookups.lookup_code%TYPE   := 'INCLASS';
l_return_dm_name  hr_lookups.meaning%TYPE;
l_return    VARCHAR2(100);
l_counter      NUMBER := 0;

BEGIN

    hr_utility.set_location('Entering :'||l_proc,5);

   FOR primary_dm_rec IN get_primary_dm_cr
       LOOP
       l_pr_dm_name := primary_dm_rec.dm_name;
       l_pr_dm_cat  := primary_dm_rec.dm_code;
        END LOOP;
   IF l_pr_dm_name IS NULL THEN
      FOR first_dm_rec IN get_first_dm_cr
          LOOP
           l_counter := l_counter + 1;
           IF l_counter = 1 THEN
              l_return_dm_name := first_dm_rec.dm_name;
              l_return_dm_cat  := first_dm_rec.dm_code;
                    END IF;
           END LOOP;
     ELSE
      IF p_return_value = 'ICON'
         THEN l_return_dm_cat := l_pr_dm_cat;
             ELSIF p_return_value = 'NAME'
         THEN l_return_dm_name := l_pr_dm_name;
          END IF;
      END IF;

   -- Added for Bug No.2941052
   --  Fetch default Delivery Method Name.
   IF l_return_dm_name IS NULL THEN
      OPEN get_dm_name;
      FETCH get_dm_name INTO l_return_dm_name;
      CLOSE get_dm_name;
   END IF;

   IF p_return_value = 'ICON'
 THEN l_return := l_return_dm_cat;
ELSIF p_return_value = 'NAME'
 THEN l_return := l_return_dm_name;
  END IF;

RETURN l_return;

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN l_return;
END get_delivery_method;

Function get_delivery_method (p_offering_id in number)
return varchar2
is


Cursor get_DM is
select ocu.category
from ota_category_usages_tl ocu , ota_offerings oaf
where oaf.delivery_mode_id = ocu.category_usage_id
and oaf.offering_id = p_offering_id
and ocu.Language = USERENV('LANG');

l_delivery_method varchar2(240);


begin

OPEN get_DM;
    FETCH get_DM INTO l_delivery_method;
    close get_DM;
 return(l_delivery_method);


end get_delivery_method;
-- ----------------------------------------------------------------
-- ------------------<students_on_waitlist >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the number of students waitlisted
-- in a particular event
-- IN
-- p_event_id
--
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION students_on_waitlist(p_event_id  IN  NUMBER)
RETURN NUMBER
IS
l_proc         VARCHAR2(72) := g_package||'Students_On_Waitlist';
   l_num_waitlisted NUMBER DEFAULT 0;
BEGIN
    hr_utility.set_location('Entering :'||l_proc,5);
   SELECT COUNT(booking_id)
   INTO l_num_waitlisted
   FROM ota_delegate_bookings tdb
   WHERE tdb.event_id = p_event_id
     AND tdb.booking_status_type_id IN (SELECT bst.booking_status_type_id
                                        FROM ota_booking_status_types bst
                                        WHERE bst.type = 'W');
    hr_utility.set_location('Leaving :'||l_proc,10);
   RETURN l_num_waitlisted;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('Leaving:'||l_proc,15);
      RETURN l_num_waitlisted;

END students_on_waitlist;

-- ----------------------------------------------------------------
-- ------------------<Place_on_waitlist >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to check the place on waitlist for a particular enrollment
-- in the particular event.
-- IN
-- p_event_id
-- p_booking_id
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION place_on_waitlist(p_event_id  IN  NUMBER,
            p_booking_id   IN  NUMBER)
RETURN NUMBER
IS
l_proc         VARCHAR2(72) := g_package||'Place_On_Waitlist';
  l_count number := 1;

 CURSOR c_date_waitlist is
 SELECT tdb.booking_id
   FROM ota_delegate_bookings tdb,
        ota_booking_status_types bst
  WHERE tdb.booking_status_type_id = bst.booking_status_type_id
    AND bst.type = 'W'
    AND tdb.event_id = p_event_id
  ORDER BY tdb.date_booking_placed;

 CURSOR c_priority_waitlist is
 SELECT tdb.booking_id
   FROM ota_delegate_bookings tdb,
        ota_booking_status_types bst
  WHERE tdb.booking_status_type_id = bst.booking_status_type_id
    AND bst.type = 'W'
    AND tdb.event_id = p_event_id
  ORDER BY tdb.booking_priority,
           tdb.booking_id;


BEGIN
    hr_utility.set_location('Entering :'||l_proc,5);

    IF fnd_profile.value('OTA_WAITLIST_SORT_CRITERIA') = 'BP' THEN
    --
       FOR l_waitlist_entry IN c_priority_waitlist
       LOOP
      --

       IF p_booking_id = l_waitlist_entry.booking_id THEN
          RETURN l_count;
     ELSE l_count := l_count+1;
      END IF;
      END LOOP;
      --
    ELSE
    --
      FOR l_waitlist_entry IN c_date_waitlist LOOP
      --
       IF p_booking_id = l_waitlist_entry.booking_id THEN
          RETURN l_count;
     ELSE l_count := l_count + 1;
      END IF;
      --
      END LOOP;
    --
    END IF;
    hr_utility.set_location('Leaving :'||l_proc,10);
EXCEPTION
WHEN others THEN
    hr_utility.set_location('Leaving :'||l_proc,15);
    RETURN l_count;
END place_on_waitlist;

-- ----------------------------------------------------------------
-- ------------------<get_event_location >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to return the location id for the event.
-- IN
-- p_event_id
--
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_event_location(p_event_id    IN  NUMBER)
RETURN NUMBER
    IS

CURSOR primary_venue_cr
    IS
SELECT s.location_id
  FROM ota_suppliable_resources s,
       ota_resource_bookings r
 WHERE r.supplied_resource_id = s.supplied_resource_id
   AND r.event_id = p_event_id
   AND primary_venue_flag = 'Y';

CURSOR evt_loc_cr
    IS
SELECT e.location_id,
       e.training_center_id
  FROM ota_events e
 WHERE e.event_id = p_event_id;

l_training_center_id       ota_events.training_center_id%TYPE;
l_location_id        hr_locations_all.location_id%TYPE;

CURSOR tc_loc_cr(p_training_center_id  ota_events.training_center_id%TYPE)
    IS
SELECT o.location_id
  FROM hr_all_organization_units o
 WHERE o.organization_id = p_training_center_id;

l_proc         VARCHAR2(72) := g_package||'Get_Event_Location';
BEGIN
    hr_utility.set_location('Entering :'||l_proc,5);
   FOR location1 IN primary_venue_cr
       LOOP
       l_location_id := location1.location_id;

   END LOOP;

    IF l_location_id IS NULL THEN
      FOR location2 IN evt_loc_cr
          LOOP
          l_location_id := location2.location_id;
          l_training_center_id := location2.training_center_id;
      END LOOP;

   END IF;

    IF l_location_id IS NULL THEN
      FOR location3 IN tc_loc_cr(l_training_center_id)
          LOOP
          l_location_id := location3.location_id;
      END LOOP;

   END IF;
    hr_utility.set_location('Leaving :'||l_proc,10);
RETURN l_location_id;

EXCEPTION
     WHEN others THEN
    hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN l_location_id;
END get_event_location;
-- ----------------------------------------------------------------
-- ------------------<get_play_button >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to return a varchar to indicate if
--   Play button will be displayed or not.
-- IN
-- p_person_id
-- p_offering_id
-- p_enrollment_status
-- p_course_start_date
-- p_course_end_date
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_play_button(p_person_id   IN     NUMBER,
          p_offering_id IN  NUMBER,
          p_enrollment_status IN  VARCHAR2,
          p_course_start_date IN  DATE,
          p_course_end_date  IN   DATE)
RETURN VARCHAR2
    IS
CURSOR get_emp_id_cr
    IS
SELECT employee_id
  FROM fnd_user
 WHERE user_id = fnd_profile.value('USER_ID');

l_proc            VARCHAR2(72) := g_package||'Get_Play_Button';
l_fnd_user        NUMBER;
l_play            VARCHAR2(10) := 'N';

BEGIN
    hr_utility.set_location('Entering :'||l_proc,5);
   FOR get_emp IN get_emp_id_cr
       LOOP
       l_fnd_user := get_emp.employee_id;
        END LOOP;

   IF p_person_id = l_fnd_user
       AND p_offering_id IS NOT NULL
       AND p_enrollment_status = 'P'
       AND sysdate >= p_course_start_date
       AND p_course_end_date >= sysdate
      THEN l_play := 'P';
     ELSIF p_person_id = l_fnd_user
       AND p_offering_id IS NOT NULL
       AND p_enrollment_status ='A'
       AND sysdate >= p_course_start_date
       AND p_course_end_date >= sysdate
      THEN l_play := 'R';
      ELSE l_play := 'N';
       END IF;
    hr_utility.set_location('Leaving :'||l_proc,10);
RETURN l_play;

EXCEPTION
     WHEN others THEN
    hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN l_play;
END get_play_button;
-- ----------------------------------------------------------------
-- --------------------< get_authorizer_name >---------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the name of the person who
--   authorized enrollment in an event.
-- IN
--   p_authorizer_id
--   p_course_start_date
--   p_course_end_date
--
-- Post Failure:
--   None.
-- Access Status
--   Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_authorizer_name(p_authorizer_id       IN    NUMBER,
                             p_course_start_date   IN    DATE,
                             p_course_end_date     IN    DATE)
                            RETURN VARCHAR2
IS
--
CURSOR get_name_csr (p_authorizer_id IN NUMBER, p_course_start_date IN DATE, p_course_end_date IN DATE)
IS

/* Modified for Bug#3552493
   SELECT DECODE(per.last_name, NULL, NULL, per.last_name)||
          DECODE(per.title, NULL, DECODE(per.first_name, NULL, NULL, ', '), ', '||per.title)||
     --Modified for Bug#2997820
          --DECODE(per.first_name,NULL,NULL, per.last_name) full_name
          DECODE(per.first_name,NULL,NULL, per.first_name) full_name
   FROM   per_all_people_f per, fnd_user u
   WHERE  per.person_id = u.employee_id
     AND  (per.effective_end_date >= DECODE(p_course_end_date, NULL, TRUNC(SYSDATE), p_course_end_date) AND
           per.effective_start_date <= DECODE(p_course_start_date, NULL, TRUNC(SYSDATE), p_course_start_date))
     AND  u.user_id = p_authorizer_id;
  */
  SELECT  decode(fnd_profile.value('BEN_DISPLAY_EMPLOYEE_NAME'),'FN',per.full_name,
                  per.first_name||' '|| per.last_name||' '||per.suffix) FULL_NAME
   FROM per_all_people_f per, fnd_user u
   WHERE per.person_id = u.employee_id
   AND u.user_id = p_authorizer_id
   AND trunc(SYSDATE) between per.effective_start_date and per.effective_end_date;

--
   l_full_name       per_all_people_f.full_name%TYPE DEFAULT NULL;
   l_authorizer_not_found  EXCEPTION;
   l_proc         VARCHAR2(72) := g_package||'Get_Authorizer_Name';
--
BEGIN
--
   hr_utility.set_location('Entering :'||l_proc,5);
--
   OPEN get_name_csr (p_authorizer_id, p_course_start_date, p_course_end_date);
   FETCH get_name_csr INTO l_full_name;
   IF get_name_csr%NOTFOUND THEN
      RAISE l_authorizer_not_found;
   END IF;
   CLOSE get_name_csr;
--
--
   RETURN l_full_name;
--
EXCEPTION
--
   WHEN l_authorizer_not_found THEN
--
      hr_utility.set_location('Leaving :'||l_proc,25);
      l_full_name := NULL;
      RETURN l_full_name;
--
   WHEN others THEN
--
      hr_utility.set_location('Leaving :'||l_proc,15);
      RETURN l_full_name;

END get_authorizer_name;

-- ----------------------------------------------------------------
-- --------------------< get_message >---------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the message text for the
--   message code passed in.
-- IN
--   p_application_code
--   p_message_code
--
-- Post Failure:
--   None.
-- Access Status
--   Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_message(p_application_code       IN    VARCHAR2,
                     p_message_code          IN    VARCHAR2)
                            RETURN VARCHAR2
IS
--
   l_msg_not_found      EXCEPTION;
   l_proc         VARCHAR2(72) := g_package||'Get_Message';
   l_msg_text        VARCHAR2(2000);
--
BEGIN
--
   hr_utility.set_location('Entering :'||l_proc,5);
--
   fnd_message.set_name(p_application_code, p_message_code);
   l_msg_text := fnd_message.get();
--
   IF l_msg_text IS NULL THEN
      RAISE l_msg_not_found;
  END IF;
--
   RETURN l_msg_text ;
--
EXCEPTION
--
   WHEN l_msg_not_found THEN
--
      hr_utility.set_location('Leaving :'||l_proc,25);
      RETURN l_msg_text;
--
   WHEN others THEN
--
      hr_utility.set_location('Leaving :'||l_proc,15);
      RETURN l_msg_text;

END get_message;
-- ----------------------------------------------------------------
-- --------------------< get_date_time >---------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to return date and time.
-- IN
-- p_date
-- p_time
-- p_time_of_day
-- OUT
-- p_date_time
--
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
 FUNCTION get_date_time(p_date       IN    DATE,
                        p_time       IN    VARCHAR2,
                        p_time_of_day IN    VARCHAR2)
RETURN DATE
IS
--
   l_proc         VARCHAR2(72) := g_package||'Get_Date_Time';
   l_date_time                  DATE;
--
BEGIN
--
   hr_utility.set_location('Entering :'||l_proc,5);
--
  IF p_time IS NULL THEN
     IF p_time_of_day = 'END'
   THEN
        l_date_time :=  to_date(to_char(p_date,'DD-MON-YYYY')||'23:59','DD/MM/YYYYHH24:MI');
       ELSIF p_time_of_day = 'START'
   THEN l_date_time :=  to_date(to_char(p_date,'DD-MON-YYYY')||'00:00','DD/MM/YYYYHH24:MI');
    END IF;
ELSE
     l_date_time :=  to_date(to_char(p_date,'DD-MON-YYYY')||p_time,'DD/MM/YYYYHH24:MI');
 END IF;
--
   RETURN l_date_time ;
--
EXCEPTION
--
   WHEN others THEN
--
      hr_utility.set_location('Leaving :'||l_proc,15);
      RETURN l_date_time;
END get_date_time;



-- ----------------------------------------------------------------
-- ------------------<get_category_name >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the category name of the particular
-- activity
-- IN
-- p_activity_id
--
-- OUT
-- category name
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------



FUNCTION get_category_name(p_activity_version_id   IN  NUMBER)
RETURN VARCHAR2 IS

CURSOR get_primary_dm_cr IS
SELECT lookup.meaning   Dm_Name,
       catusg.category  Dm_Code
  FROM ota_act_cat_inclusions actcat,
       ota_category_usages catusg,
       hr_lookups lookup
 WHERE actcat.category_usage_id=  catusg.category_usage_id
   AND actcat.primary_flag='Y'
   AND catusg.category = lookup.lookup_code
   AND lookup.lookup_type ='ACTIVITY_CATEGORY'
   AND catusg.type='C'
   AND actcat.activity_version_id = p_activity_version_id;

CURSOR get_first_dm_cr IS
SELECT lookup.meaning   dm_name,
       catusg.category  dm_code
  FROM ota_act_cat_inclusions actcat,
       ota_category_usages catusg,
       hr_lookups lookup
 WHERE actcat.category_usage_id=  catusg.category_usage_id
   AND catusg.category = lookup.lookup_code
   AND lookup.lookup_type ='ACTIVITY_CATEGORY'
   AND catusg.type='C'
   AND actcat.activity_version_id = p_activity_version_id;

l_proc         VARCHAR2(72) := g_package||'Get_category_name';

l_pr_dm_name      hr_lookups.meaning%TYPE;

l_return_dm_name  hr_lookups.meaning%TYPE    := 'Classroom (physical)';
l_return    VARCHAR2(100);
l_counter      NUMBER := 0;

BEGIN

    hr_utility.set_location('Entering :'||l_proc,5);

   FOR primary_dm_rec IN get_primary_dm_cr
       LOOP
            -- bug#2652899
             l_pr_dm_name := primary_dm_rec.dm_name;
       -- bug # 2652899
       l_return_dm_name := primary_dm_rec.dm_name;
        END LOOP;
   IF l_pr_dm_name IS NULL THEN
      FOR first_dm_rec IN get_first_dm_cr
          LOOP
           l_counter := l_counter + 1;
           IF l_counter = 1 THEN
              l_return_dm_name := first_dm_rec.dm_name;
                    END IF;
           END LOOP;
    END IF;

RETURN l_return_dm_name;

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN l_return;
END get_category_name;

-- ----------------------------------------------------------------
-- ------------------<get_lo_offering_count >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the number of offerings for the particular
-- learning object
-- IN
-- p_learning_object_id
--
-- OUT
-- offering count
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
 function get_lo_offering_count (p_learning_object_id in number) return varchar2
 IS
    l_offering_count number;

CURSOR c_get_offering_count IS
    SELECT count(*)
    FROM   ota_offerings
    WHERE  learning_object_id = p_learning_object_id;

BEGIN
    open c_get_offering_count;
    fetch c_get_offering_count into l_offering_count;
    close c_get_offering_count;

 return(l_offering_count);

end get_lo_offering_count ;


-- ----------------------------------------------------------------
-- ------------------<get_course_offering_count >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the number of offerings for the particular
-- course
-- IN
-- p_activity_version_id
--
-- OUT
-- offering count
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
 function get_course_offering_count (p_activity_version_id in number) return varchar2
 IS
    l_offering_count number;

CURSOR c_get_course_offering_count IS
    SELECT count(*)
    FROM   ota_offerings
    WHERE  activity_version_id = p_activity_version_id;

BEGIN
    open c_get_course_offering_count;
    fetch c_get_course_offering_count into l_offering_count;
    close c_get_course_offering_count;

 return(l_offering_count);

end get_course_offering_count ;


-- ----------------------------------------------------------------
-- ------------------<get_iln_rco_id >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find rco_id for course
-- IN
-- p_activity_version_id
--
-- OUT
-- l_rco_id
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
 function get_iln_rco_id (p_activity_version_id in number
                          ) return varchar2
 IS
    l_rco_id number;

CURSOR get_iln_rco_id IS
    SELECT rco_id
    FROM   ota_activity_versions
    WHERE  activity_version_id = p_activity_version_id;


BEGIN
      open get_iln_rco_id;
      fetch get_iln_rco_id into l_rco_id;
      close get_iln_rco_id;

 return(l_rco_id);

end get_iln_rco_id ;



-- ----------------------------------------------------------------
-- ------------------<get_event_count >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the number of of events the particular
-- offering
-- IN
-- p_offering_id
-- p_event_type
--
-- OUT
-- event count
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
 function get_event_count (p_offering_id in number,
                           p_event_type  in varchar2 default 'ALL') return varchar2
 IS
    l_event_count number;

CURSOR c_get_iln_event_count IS
    SELECT count(event_id)
    FROM   ota_events
    WHERE  parent_offering_id = p_offering_id and
           offering_id is not null;

CURSOR c_get_event_count IS
    SELECT count(event_id)
    FROM   ota_events
    WHERE  parent_offering_id = p_offering_id and
           event_type in ('SELFPACED','SCHEDULED') and
           book_independent_flag = 'N';

BEGIN
   IF p_event_type = 'ILN' THEN
      open c_get_iln_event_count;
      fetch c_get_iln_event_count into l_event_count;
      close c_get_iln_event_count;
 ELSE
      open c_get_event_count;
      fetch c_get_event_count into l_event_count;
      close c_get_event_count;
 END IF;

 return(l_event_count);

end get_event_count ;



-- ----------------------------------------------------------------
-- ------------------<get_question_bank_count >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the number of question banks related to particular
-- folder
-- IN
-- p_folder_id
--
-- OUT
-- question bank count
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
 function get_question_bank_count (p_folder_id in number) return varchar2
 IS
    l_question_bank_count number;

CURSOR c_get_question_bank_count IS
    SELECT count(*)
    FROM   ota_question_banks
    WHERE  folder_id = p_folder_id;

BEGIN
    open c_get_question_bank_count;
    fetch c_get_question_bank_count into l_question_bank_count;
    close c_get_question_bank_count;

 return(l_question_bank_count);

end get_question_bank_count ;

-- Author: sbhullar
FUNCTION get_enrollment_status(p_delegate_person_id IN ota_delegate_bookings.delegate_person_id%TYPE,
                               p_delegate_contact_id IN NUMBER,
                               p_event_id IN ota_events.event_id%TYPE,
                               p_code IN number)
RETURN VARCHAR2 IS

CURSOR enroll_status IS
  SELECT DECODE(BST.type,'C','Y',BST.type) status, BST.name
  FROM   ota_booking_status_types_vl BST,
         ota_delegate_bookings ODB
  WHERE  ODB.event_id = p_event_id
  AND    (p_delegate_person_id IS NOT NULL AND ODB.delegate_person_id = p_delegate_person_id
            OR p_delegate_contact_id IS NOT NULL and ODB.delegate_contact_id = p_delegate_contact_id)
  AND    ODB.booking_status_type_id = BST.booking_status_type_id
  ORDER BY status;


l_proc  VARCHAR2(72) :=      g_package|| 'get_enrollment_status';

l_enrollment_status  VARCHAR2(30) := 'Z'; --Default is Not Enrolled(Status Z)
l_enrollment_status_name ota_booking_status_types_tl.name%TYPE;

BEGIN
    hr_utility.set_location(' Step:'|| l_proc, 10);

    --Default is Not Enrolled
    l_enrollment_status_name := get_message('OTA','OTA_443407_NOT_ENROLLED');

    FOR rec IN enroll_status
    LOOP
        l_enrollment_status := rec.status ;
        l_enrollment_status_name := rec.name;
        EXIT;
    END LOOP;

    If (p_code = 1) Then
        RETURN l_enrollment_status;
    Else
        RETURN l_enrollment_status_name;
    End If;

    hr_utility.set_location(' Step:'|| l_proc, 20);

END get_enrollment_status;


FUNCTION get_user_fullname(p_user_id IN ota_attempts.user_id%TYPE,
                           p_user_type IN ota_attempts.user_type%TYPE)

RETURN VARCHAR2 IS

CURSOR c_person_fullname IS
select
p.full_name person_name
from per_people_f p
where
p.person_id = p_user_id
and sysdate between p.effective_start_date and p.effective_end_date;

CURSOR c_customer_fullname IS
select
p.party_name person_name
from  hz_parties p
where
p.party_id  = p_user_id;

   l_proc  VARCHAR2(72) :=      g_package|| 'get_user_fullname';
   l_return             per_all_people_f.full_name%TYPE;
BEGIN
    hr_utility.set_location(' Step:'|| l_proc, 10);
        IF p_user_type = 'E' THEN
            OPEN c_person_fullname;
            FETCH c_person_fullname INTO l_return;
            CLOSE c_person_fullname;
         ELSIF p_user_type = 'C' THEN
            OPEN c_customer_fullname;
            FETCH c_customer_fullname INTO l_return;
            CLOSE c_customer_fullname;
         END IF;


  RETURN l_return;

       hr_utility.set_location(' Step:'|| l_proc, 20);

END get_user_fullname;

FUNCTION get_person_fullname(p_user_id IN ota_attempts.user_id%TYPE
                           )RETURN VARCHAR2 IS

CURSOR c_person_fullname IS
select
p.full_name person_name
from per_people_f p , fnd_user fus
where p.person_id = fus.employee_id
and
fus.user_id = p_user_id;


   l_proc  VARCHAR2(72) :=      g_package|| 'get_person_fullname';
   l_return             per_all_people_f.full_name%TYPE;
BEGIN
    hr_utility.set_location(' Step:'|| l_proc, 10);

            OPEN c_person_fullname;
            FETCH c_person_fullname INTO l_return;
            CLOSE c_person_fullname;


  RETURN l_return;

       hr_utility.set_location(' Step:'|| l_proc, 20);

END get_person_fullname;

FUNCTION get_learner_name(p_person_id IN per_all_people_f.person_id%TYPE,
                          p_customer_id IN ota_delegate_bookings.customer_id%TYPE,
                          p_contact_id IN ota_delegate_bookings.delegate_contact_id%TYPE)
RETURN VARCHAR2 IS

CURSOR c_person_name IS
select pap.full_name from per_all_people_f pap
where  pap.person_id = p_person_id
       and trunc(sysdate) between nvl(pap.effective_start_date, trunc(sysdate))
       and nvl(pap.effective_end_date, trunc(sysdate));

CURSOR c_contact_name(l_customer_id IN ota_delegate_bookings.customer_id%TYPE) IS
SELECT
    SUBSTRB( PARTY.PERSON_LAST_NAME,1,50) || ' ' ||
    SUBSTRB( PARTY.PERSON_FIRST_NAME,1,40) || ' ' ||
    HR_GENERAL.DECODE_AR_LOOKUP('CONTACT_TITLE',nvl(PARTY.PERSON_PRE_NAME_ADJUNCT,PARTY.PERSON_TITLE)) LEARNER_NAME
FROM
    HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
    HZ_PARTIES PARTY,
    HZ_RELATIONSHIPS REL,
    HZ_CUST_ACCOUNTS ROLE_ACCT
WHERE
    ACCT_ROLE.PARTY_ID = REL.PARTY_ID
AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'
AND REL.SUBJECT_ID = PARTY.PARTY_ID
AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
AND ROLE_ACCT.PARTY_ID = REL.OBJECT_ID
AND ACCT_ROLE.CUST_ACCOUNT_ID = ROLE_ACCT.CUST_ACCOUNT_ID
AND ACCT_ROLE.CUST_ACCOUNT_ID = l_customer_id
AND ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_contact_id;

   l_proc  VARCHAR2(72) :=      g_package|| 'get_learner_name';
   l_return VARCHAR2(500);
BEGIN
    hr_utility.set_location(' Step:'|| l_proc, 10);

    IF (p_person_id is not null) THEN
       -- Internal Enrollment, Get Learner Name from per_all_people_f
       OPEN c_person_name;
       FETCH c_person_name INTO l_return;
       CLOSE c_person_name;
    ELSE
       -- External Enrollment. Get Learner Name from
       -- HZ Tables if contact_id is not null
       IF (p_contact_id is not null) THEN
          IF (p_customer_id is not null) THEN
              OPEN c_contact_name(p_customer_id);
          ELSE
              OPEN c_contact_name(get_customer_id(p_contact_id));
          END IF;
          FETCH c_contact_name INTO l_return;
          CLOSE c_contact_name;
       ELSE
          l_return := NULL;
       END IF;
    END IF;

    return l_return;

    hr_utility.set_location(' Step:'|| l_proc, 20);

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN NULL;
END get_learner_name;

FUNCTION get_customer_id(p_contact_id IN ota_lp_enrollments.contact_id%TYPE)
RETURN number IS

CURSOR c_customer_id IS
select ACCT_ROLE.cust_account_id CUSTOMER_ID
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
   and ACCT_ROLE.cust_account_role_id = p_contact_id;

   l_proc  VARCHAR2(72) :=      g_package|| 'get_customer_id';
   l_return ota_delegate_bookings.customer_id%TYPE;

Begin
    hr_utility.set_location(' Step:'|| l_proc, 10);

    OPEN c_customer_id;
    FETCH c_customer_id INTO l_return;
    CLOSE c_customer_id;

    return l_return;
    hr_utility.set_location(' Step:'|| l_proc, 20);
End get_customer_id;

FUNCTION get_cust_org_name(p_organization_id IN ota_delegate_bookings.organization_id%TYPE,
                           p_customer_id IN ota_delegate_bookings.customer_id%TYPE,
                           p_contact_id IN ota_lp_enrollments.contact_id%TYPE default null)
RETURN VARCHAR2 IS

CURSOR c_organization_name IS
select name from hr_all_organization_units_tl
where  language = userenv('LANG') and organization_id = p_organization_id;

CURSOR c_customer_name(l_customer_id IN ota_delegate_bookings.customer_id%TYPE) IS
select substrb(party.party_name,1,50)
from   hz_parties party
      ,hz_cust_accounts cust_acct
where
      cust_acct.party_id = party.party_id
and   cust_acct.cust_account_id = l_customer_id;

   l_proc  VARCHAR2(72) :=      g_package|| 'get_cust_org_name';
   l_return VARCHAR2(500);
BEGIN
    hr_utility.set_location(' Step:'|| l_proc, 10);

    IF (p_organization_id is not null) THEN
       -- Internal Enrollment, Get org_name from hr_all_organization_units
       OPEN c_organization_name;
       FETCH c_organization_name INTO l_return;
       CLOSE c_organization_name;
    ELSIF (p_customer_id is not null) THEN
       -- External Enrollment. Get Customer Name from HZ Tables
       -- p_customer_id is already known
       OPEN c_customer_name(p_customer_id);
       FETCH c_customer_name INTO l_return;
       CLOSE c_customer_name;
    ELSE
       -- External Enrollment. Get Customer Name from HZ Tables
       -- Get p_customer_id from p_contact_id
       OPEN c_customer_name(get_customer_id(p_contact_id));
       FETCH c_customer_name INTO l_return;
       CLOSE c_customer_name;
    END IF;

    return l_return;

    hr_utility.set_location(' Step:'|| l_proc, 20);

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     RETURN NULL;
END get_cust_org_name;


-- ----------------------------------------------------------------
-- ------------------<get_catalog_object_path >--------------------
-- ----------------------------------------------------------------
Procedure get_catalog_object_path (p_cat_id varchar2, p_path OUT NOCOPY varchar2)
IS
parent_id ota_category_usages.parent_cat_usage_id%TYPE;
full_path varchar2(1000) :=null;
current_cat_usage_id ota_category_usages.category_usage_id%TYPE := p_cat_id;
l_proc         VARCHAR2(72) := g_package||'get_catalog_object_path';

Cursor c_parent_cat_id(current_cat_usage_id IN VARCHAR2)
IS
select nvl(parent_cat_usage_id,-1)
        from ota_category_usages
        where category_usage_id = current_cat_usage_id;

Begin
     loop
            OPEN c_parent_cat_id(current_cat_usage_id);
            FETCH c_parent_cat_id INTO parent_id;
            CLOSE c_parent_cat_id;

            full_path := 'CAT' || parent_id || '.' ||full_path;
            current_cat_usage_id := parent_id;

      exit when parent_id = -1;
      end loop;

    p_path := full_path;

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     p_path := null;
End get_catalog_object_path ;


-- ----------------------------------------------------------------
-- ------------------<get_content_object_path >--------------------
-- ----------------------------------------------------------------
Procedure get_content_object_path (p_obj_id varchar2,p_obj_type varchar2, p_path OUT NOCOPY varchar2)
IS
parent_obj_id       ota_lo_folders.folder_id%TYPE;
full_path           varchar2(1000) :=null;
current_obj_id      ota_lo_folders.folder_id%TYPE := p_obj_id;
l_proc              VARCHAR2(72) := g_package||'get_content_object_path';

Cursor c_parent_lo_id(current_lo_id IN VARCHAR2)
IS
select nvl(parent_learning_object_id,-1)
        from ota_learning_objects
        where learning_object_id  = current_lo_id;

Cursor c_lo_folder_id(current_lo_id IN VARCHAR2)
IS
select folder_id
        from ota_learning_objects
        where learning_object_id = current_lo_id;

Cursor c_parent_folder_id(current_folder_id IN VARCHAR2)
IS
select nvl(parent_folder_id,-1)
        from ota_lo_folders
        where folder_id = current_folder_id;

Begin
     if (p_obj_type = 'L') then
     loop
            OPEN c_parent_lo_id(current_obj_id);
            FETCH c_parent_lo_id INTO parent_obj_id;
            CLOSE c_parent_lo_id;

        if (parent_obj_id <> -1) then
            full_path := 'L' || parent_obj_id || '.' ||full_path;
            current_obj_id := parent_obj_id;
        end if;

        if (parent_obj_id = -1) then
            OPEN c_lo_folder_id(current_obj_id);
            FETCH c_lo_folder_id INTO current_obj_id;
            CLOSE c_lo_folder_id;
            full_path := 'F' || current_obj_id || '.' ||full_path;
        end if;

      exit when parent_obj_id  = -1;
      end loop;

     end if;


     loop
            OPEN c_parent_folder_id(current_obj_id);
            FETCH c_parent_folder_id INTO parent_obj_id;
            CLOSE c_parent_folder_id;

            full_path := 'F' || parent_obj_id || '.' ||full_path;
            current_obj_id := parent_obj_id;

      exit when parent_obj_id = -1;
      end loop;

    p_path := full_path;

EXCEPTION
WHEN others THEN
     hr_utility.set_location('Leaving :'||l_proc,15);
     p_path := null;
End get_content_object_path ;

-- ----------------------------------------------------------------
-- ------------------<check_function_access   >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find out if the user logged in has access to the function
-- IN
-- p_function_name
--
-- OUT
-- T for True
-- F for False
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
 function check_function_access (p_function_name   in VARCHAR2)
RETURN varchar2
 IS
    l_return VARCHAR2(1):= 'F';
    l_proc   VARCHAR2(72) := g_package||'check_function_access';

BEGIN
hr_utility.set_location('Entering :'||l_proc,5);

IF fnd_function.test_instance(function_name => p_function_name) THEN
   l_return := 'T';
ELSE
   l_return := 'F';
END IF;
 RETURN l_return;

hr_utility.set_location('Leaving :'||l_proc,10);
 EXCEPTION
WHEN others THEN
l_return := 'F';
RETURN l_return;

END check_function_access;

-- ----------------------------------------------------------------
-- ------------------< get_event_status_code >---------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find the event status code for
--   an event
-- IN
-- p_event_id
--
-- OUT
-- returns event status code
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
Function get_event_status_code (p_event_id in ota_events.event_id%TYPE)
return varchar2
IS
l_event_status_code ota_events.event_status%TYPE;

CURSOR c_get_event_status_code
IS
SELECT event_status from ota_events
where
event_id = p_event_id;

Begin
 OPEN c_get_event_status_code;
 FETCH c_get_event_status_code INTO l_event_status_code;
 CLOSE c_get_event_status_code;
 RETURN(l_event_status_code);

End get_event_status_code ;

-- ----------------------------------------------------------------
-- ----------------------< is_applicant >--------------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to find whether person is
--   applicant or not
-- IN
-- p_person_id
--
-- OUT
-- returns Y or N
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
Function is_applicant (p_person_id IN per_all_people_f.person_id%TYPE)
return varchar2 is

cursor get_person_type is
SELECT  ppt.system_person_type
  FROM    per_all_people_f per,
          per_person_type_usages_f ptu,
          per_person_types ppt
  WHERE
         per.person_id = p_person_id
  AND    ptu.person_id = per.person_id
  AND    ppt.business_group_id = per.business_group_id
  AND    ptu.person_type_id = ppt.person_type_id
  AND    trunc(sysdate) between per.effective_start_date AND per.effective_end_date
  AND    trunc(sysdate) between ptu.effective_start_date AND ptu.effective_end_date
  AND ppt.system_person_type <> 'APL'
  AND ppt.system_person_type in ('EMP','CWK');

l_system_person_type per_person_types.system_person_type%TYPE;

Begin
	Open get_person_type;
	Fetch get_person_type into l_system_person_type;
	/*
    Close get_person_type;

	if ( l_system_person_type = 'APL' ) then
		return 'Y';
	else
		return 'N';
   */
    IF get_person_type%FOUND THEN
        CLOSE get_person_type;
        return 'N';
    ELSE
        CLOSE get_person_type;
        RETURN 'Y';
	end if;
End is_applicant;

-- ----------------------------------------------------------------
-- -------------------< get_ext_lrnr_party_id >--------------------
-- ----------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   This function will be used to fetch the party id for external learner
-- IN
-- p_delegate_contact_id
--
-- OUT
-- returns party id
-- Post Failure:
-- None.
-- Access Status
--  Public
-- {End of Comments}
------------------------------------------------------------------
FUNCTION get_ext_lrnr_party_id
         (p_delegate_contact_id IN ota_delegate_bookings.delegate_contact_id%TYPE)
RETURN number IS

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

   l_proc  VARCHAR2(72) :=      g_package|| 'get_ext_lrnr_party_id';
   l_return number;

Begin
    hr_utility.set_location(' Step:'|| l_proc, 10);

    OPEN get_ext_lrn_party_id;
    FETCH get_ext_lrn_party_id INTO l_return;
    CLOSE get_ext_lrn_party_id;

    return l_return;
    hr_utility.set_location(' Step:'|| l_proc, 20);
End get_ext_lrnr_party_id;

FUNCTION is_class_enrollable(
     p_class_id ota_events.event_id%TYPE)
RETURN VARCHAR2
IS
--6762989 Added nvl check on enrolment_start_date to avoid java.sql.SQLException: ORA-01843: not a valid month on some dbs.
  CURSOR csr_get_class_details IS
  SELECT null
  FROM ota_events
  WHERE event_id = p_class_id
    --AND trunc(sysdate) between enrolment_start_date and nvl(enrolment_end_date, trunc(sysdate))
    AND ota_timezone_util.convert_date(sysdate, to_char(sysdate,'HH24:MI'), ota_timezone_util.get_server_timezone_code, timezone)
       BETWEEN to_date(to_char(nvl(enrolment_start_date,trunc(sysdate)),'YYYY/MM/DD') || ' ' || '00:00' , 'YYYY/MM/DD HH24:MI')
       AND to_date(to_char(nvl(enrolment_end_date,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' ' || '23:59', 'YYYY/MM/DD HH24:MI')
    AND event_type IN ('SCHEDULED', 'SELFPACED')
    AND event_status IN ('N', 'P', 'F');

  l_exists VARCHAR2(1);
BEGIN
OPEN csr_get_class_details;
   FETCH csr_get_class_details INTO l_exists;
   IF csr_get_class_details%NOTFOUND THEN
      CLOSE csr_get_class_details;
      RETURN 'N';
   ELSE
      CLOSE csr_get_class_details;
      RETURN 'Y';
   END IF;
END is_class_enrollable;

FUNCTION is_lp_enrollable(
     p_learning_path_id ota_learning_paths.learning_path_id%TYPE)
RETURN VARCHAR2
IS
  CURSOR csr_get_lp_details IS
   SELECT null
   FROM ota_learning_paths
   WHERE learning_path_id = p_learning_path_id
    AND trunc(sysdate) between start_date_active and nvl(end_date_active, trunc(sysdate));

  CURSOR csr_sections_exist IS
  SELECT null
  from ota_lp_sections lpc,
     ota_learning_path_members lpm
  where lpc.learning_path_id = p_learning_path_id
  and lpc.learning_path_section_id = lpm.learning_path_section_id
  and lpc.completion_type_code in ('M','S');

  l_exists VARCHAR2(1);
BEGIN

   OPEN csr_get_lp_details;
   FETCH csr_get_lp_details INTO l_exists;
   IF csr_get_lp_details%NOTFOUND THEN
      CLOSE csr_get_lp_details;
      RETURN 'N';
   ELSE
      CLOSE csr_get_lp_details;

      OPEN csr_sections_exist;
      FETCH csr_sections_exist INTO l_exists;
      IF csr_sections_exist%NOTFOUND THEN
        CLOSE csr_sections_exist;
        RETURN 'N';
      ELSE
        CLOSE csr_sections_exist;
        RETURN 'Y';
      END IF;
   END IF;
END is_lp_enrollable;

FUNCTION is_cert_enrollable(
     p_certification_id ota_certifications_b.certification_id%TYPE)
RETURN VARCHAR2
IS
CURSOR csr_get_cert_details IS
   SELECT null
   FROM ota_certifications_b crb
     , ota_certification_members crm
   WHERE crb.certification_id = crm.certification_id
     AND crb.certification_id = p_certification_id
     AND trunc(sysdate) between crb.start_date_active and nvl(crb.end_date_active, trunc(sysdate))
     -- Added for bug#4617609, modified for 4940007
     and ((crb.renewable_flag = 'N' and trunc(sysdate) <= nvl( crb.INITIAL_COMPLETION_DATE ,trunc(sysdate)))
          or crb.renewable_flag = 'Y');


  l_exists VARCHAR2(1);
BEGIN
OPEN csr_get_cert_details;
   FETCH csr_get_cert_details INTO l_exists;
   IF csr_get_cert_details%NOTFOUND THEN
      CLOSE csr_get_cert_details;
      RETURN 'N';
   ELSE
      CLOSE csr_get_cert_details;
      RETURN 'Y';
   END IF;
END is_cert_enrollable;

FUNCTION is_enrollable
     ( p_object_type in varchar2
      ,p_object_id in number
      )
RETURN varchar2
IS
BEGIN
   IF p_object_type = 'CL' THEN
      RETURN is_class_enrollable(p_object_id);
   ELSIF p_object_type = 'LP' THEN
      RETURN is_lp_enrollable(p_object_id);
   ELSIF p_object_type = 'CRT' THEN
      RETURN is_cert_enrollable(p_object_id);
   ELSE
      RETURN 'N';
   END IF;
END is_enrollable;


PROCEDURE Get_Default_Value_Dff(
                           appl_short_name IN VARCHAR2,
                           flex_field_name IN VARCHAR2,
                           p_attribute_category IN OUT NOCOPY VARCHAR2,
                           p_attribute1 IN OUT NOCOPY VARCHAR2,
                           p_attribute2 IN OUT NOCOPY VARCHAR2,
                           p_attribute3 IN OUT NOCOPY VARCHAR2,
                           p_attribute4 IN OUT NOCOPY VARCHAR2,
                           p_attribute5 IN OUT NOCOPY VARCHAR2,
                           p_attribute6 IN OUT NOCOPY VARCHAR2,
                           p_attribute7 IN OUT NOCOPY VARCHAR2,
                           p_attribute8 IN OUT NOCOPY VARCHAR2,
                           p_attribute9 IN OUT NOCOPY VARCHAR2,
                           p_attribute10 IN OUT NOCOPY VARCHAR2,
                           p_attribute11 IN OUT NOCOPY VARCHAR2,
                           p_attribute12 IN OUT NOCOPY VARCHAR2,
                           p_attribute13 IN OUT NOCOPY VARCHAR2,
                           p_attribute14 IN OUT NOCOPY VARCHAR2,
                           p_attribute15 IN OUT NOCOPY VARCHAR2,
   			               p_attribute16 IN OUT NOCOPY VARCHAR2,
       			           p_attribute17 IN OUT NOCOPY VARCHAR2,
			               p_attribute18 IN OUT NOCOPY VARCHAR2,
			               p_attribute19 IN OUT NOCOPY VARCHAR2,
			               p_attribute20 IN OUT NOCOPY VARCHAR2)
IS
 p_flexfield       fnd_dflex.dflex_r;
  p_flexinfo        fnd_dflex.dflex_dr;
  p_contexts        fnd_dflex.contexts_dr;
  p_segments        fnd_dflex.segments_dr;
  j                BINARY_INTEGER;
  i                BINARY_INTEGER;
  k                BINARY_INTEGER;


  l_appl_col_name varchar2(50);
  firstchar number;
  tempstr varchar2(2);

  PROCEDURE Get_Flexfield
  IS
  BEGIN
      fnd_dflex.get_flexfield( appl_short_name, flex_field_name, p_flexfield, p_flexinfo );
  END Get_Flexfield;

  PROCEDURE Get_Contexts
  IS
  BEGIN
       fnd_dflex.get_contexts( p_flexfield, p_contexts );
  END Get_Contexts;


BEGIN
   IF p_attribute_category IS NOT NULL
     OR p_attribute1 IS NOT NULL
     OR p_attribute2 IS NOT NULL
     OR p_attribute3 IS NOT NULL
     OR p_attribute4 IS NOT NULL
     OR p_attribute5 IS NOT NULL
     OR p_attribute6 IS NOT NULL
     OR p_attribute7 IS NOT NULL
     OR p_attribute8 IS NOT NULL
     OR p_attribute9 IS NOT NULL
     OR p_attribute10 IS NOT NULL
     OR p_attribute11 IS NOT NULL
     OR p_attribute12 IS NOT NULL
     OR p_attribute13 IS NOT NULL
     OR p_attribute14 IS NOT NULL
     OR p_attribute15 IS NOT NULL
     OR p_attribute16 IS NOT NULL
     OR p_attribute17 IS NOT NULL
     OR p_attribute18 IS NOT NULL
     OR p_attribute19 IS NOT NULL
     OR p_attribute20 IS NOT NULL THEN RETURN;

  END IF;

   Get_Flexfield;
   GET_CONTEXTS;

   p_attribute_category := p_flexinfo.default_context_value;

    FOR k in 1 .. p_contexts.ncontexts LOOP

      IF p_contexts.is_global(k)
             OR p_contexts.context_code(k) = p_flexinfo.default_context_value THEN

         fnd_dflex.Get_Segments( fnd_dflex.make_context(p_flexfield,p_contexts.context_code(k))
                                ,p_segments
                                ,TRUE);

         FOR j IN 1 .. p_segments.nsegments LOOP

            l_appl_col_name := p_segments.application_column_name(j);
            tempstr := substr(l_appl_col_name, length(l_appl_col_name) -1);
            firstchar := ascii(substr(tempstr,1,2));

            IF firstchar < 49 OR firstchar > 57 THEN
               i := to_number(substr(tempstr,2,1));
            ELSE
              i := to_number(tempstr);
            END IF;

            IF i = 1 THEN
               p_attribute1 := p_segments.default_value(j);
            ELSIF i = 2 THEN
               p_attribute2 := p_segments.default_value(j);
            ELSIF i = 3 THEN
               p_attribute3 := p_segments.default_value(j);
            ELSIF i = 4 THEN
               p_attribute4 := p_segments.default_value(j);
            ELSIF i = 5 THEN
               p_attribute5 := p_segments.default_value(j);
            ELSIF i = 6 THEN
               p_attribute6 := p_segments.default_value(j);
            ELSIF i = 7 THEN
               p_attribute7 := p_segments.default_value(j);
            ELSIF i = 8 THEN
               p_attribute8 := p_segments.default_value(j);
            ELSIF i = 9 THEN
               p_attribute9 := p_segments.default_value(j);
            ELSIF i = 10 THEN
               p_attribute10 := p_segments.default_value(j);
            ELSIF i = 11 THEN
               p_attribute11 := p_segments.default_value(j);
            ELSIF i = 12 THEN
               p_attribute12 := p_segments.default_value(j);
            ELSIF i = 13 THEN
               p_attribute13 := p_segments.default_value(j);
            ELSIF i = 14 THEN
               p_attribute14 := p_segments.default_value(j);
            ELSIF i = 15 THEN
               p_attribute15 := p_segments.default_value(j);
            ELSIF i = 16 THEN
               p_attribute16 := p_segments.default_value(j);
            ELSIF i = 17 THEN
               p_attribute17 := p_segments.default_value(j);
            ELSIF i = 18 THEN
               p_attribute18 := p_segments.default_value(j);
            ELSIF i = 19 THEN
               p_attribute19 := p_segments.default_value(j);
            ELSIF i = 20 THEN
               p_attribute20 := p_segments.default_value(j);
           END IF;
       END LOOP;
      END IF;

    END LOOP;
/*
dbms_output.put_line('Attribute cate  '||p_attribute_category);

dbms_output.put_line('Attribute 1  '||p_attribute1);
dbms_output.put_line('Attribute 2  '||p_attribute2);
dbms_output.put_line('Attribute 3  '||p_attribute3);
dbms_output.put_line('Attribute 4  '||p_attribute4);
dbms_output.put_line('Attribute 5  '||p_attribute5);
dbms_output.put_line('Attribute 6  '||p_attribute6);
dbms_output.put_line('Attribute 7  '||p_attribute7);
dbms_output.put_line('Attribute 8  '||p_attribute8);
dbms_output.put_line('Attribute 9  '||p_attribute9);
dbms_output.put_line('Attribute 10  '||p_attribute10);
dbms_output.put_line('Attribute 11  '||p_attribute11);
dbms_output.put_line('Attribute 12  '||p_attribute12);
dbms_output.put_line('Attribute 13 '||p_attribute13);
dbms_output.put_line('Attribute 14  '||p_attribute14);
dbms_output.put_line('Attribute 15  '||p_attribute15);
dbms_output.put_line('Attribute 16  '||p_attribute16);
dbms_output.put_line('Attribute 17  '||p_attribute17);
dbms_output.put_line('Attribute 18  '||p_attribute18);
dbms_output.put_line('Attribute 19  '||p_attribute19);
dbms_output.put_line('Attribute 20  '||p_attribute20);
*/
END Get_Default_Value_Dff;

PROCEDURE Get_Default_Value_Dff(
                           appl_short_name IN VARCHAR2,
                           flex_field_name IN VARCHAR2,
                           p_attribute_category IN OUT NOCOPY VARCHAR2,
                           p_attribute1 IN OUT NOCOPY VARCHAR2,
                           p_attribute2 IN OUT NOCOPY VARCHAR2,
                           p_attribute3 IN OUT NOCOPY VARCHAR2,
                           p_attribute4 IN OUT NOCOPY VARCHAR2,
                           p_attribute5 IN OUT NOCOPY VARCHAR2,
                           p_attribute6 IN OUT NOCOPY VARCHAR2,
                           p_attribute7 IN OUT NOCOPY VARCHAR2,
                           p_attribute8 IN OUT NOCOPY VARCHAR2,
                           p_attribute9 IN OUT NOCOPY VARCHAR2,
                           p_attribute10 IN OUT NOCOPY VARCHAR2,
                           p_attribute11 IN OUT NOCOPY VARCHAR2,
                           p_attribute12 IN OUT NOCOPY VARCHAR2,
                           p_attribute13 IN OUT NOCOPY VARCHAR2,
                           p_attribute14 IN OUT NOCOPY VARCHAR2,
                           p_attribute15 IN OUT NOCOPY VARCHAR2,
   			               p_attribute16 IN OUT NOCOPY VARCHAR2,
       			           p_attribute17 IN OUT NOCOPY VARCHAR2,
			               p_attribute18 IN OUT NOCOPY VARCHAR2,
			               p_attribute19 IN OUT NOCOPY VARCHAR2,
			               p_attribute20 IN OUT NOCOPY VARCHAR2,
                           p_attribute21 IN OUT NOCOPY VARCHAR2,
                           p_attribute22 IN OUT NOCOPY VARCHAR2,
                           p_attribute23 IN OUT NOCOPY VARCHAR2,
                           p_attribute24 IN OUT NOCOPY VARCHAR2,
                           p_attribute25 IN OUT NOCOPY VARCHAR2,
   			               p_attribute26 IN OUT NOCOPY VARCHAR2,
			               p_attribute27 IN OUT NOCOPY VARCHAR2,
			               p_attribute28 IN OUT NOCOPY VARCHAR2,
			               p_attribute29 IN OUT NOCOPY VARCHAR2,
			               p_attribute30 IN OUT NOCOPY VARCHAR2)

 IS
 p_flexfield       fnd_dflex.dflex_r;
  p_flexinfo        fnd_dflex.dflex_dr;
  p_contexts        fnd_dflex.contexts_dr;
  p_segments        fnd_dflex.segments_dr;
  j                BINARY_INTEGER;
  i                BINARY_INTEGER;
  k                BINARY_INTEGER;


  l_appl_col_name varchar2(50);
  firstchar number;
  tempstr varchar2(2);

  PROCEDURE Get_Flexfield
  IS
  BEGIN
      fnd_dflex.get_flexfield( appl_short_name, flex_field_name, p_flexfield, p_flexinfo );
  END Get_Flexfield;

  PROCEDURE Get_Contexts
  IS
  BEGIN
       fnd_dflex.get_contexts( p_flexfield, p_contexts );
  END Get_Contexts;


BEGIN
   IF p_attribute_category IS NOT NULL
     OR p_attribute1 IS NOT NULL
     OR p_attribute2 IS NOT NULL
     OR p_attribute3 IS NOT NULL
     OR p_attribute4 IS NOT NULL
     OR p_attribute5 IS NOT NULL
     OR p_attribute6 IS NOT NULL
     OR p_attribute7 IS NOT NULL
     OR p_attribute8 IS NOT NULL
     OR p_attribute9 IS NOT NULL
     OR p_attribute10 IS NOT NULL
     OR p_attribute11 IS NOT NULL
     OR p_attribute12 IS NOT NULL
     OR p_attribute13 IS NOT NULL
     OR p_attribute14 IS NOT NULL
     OR p_attribute15 IS NOT NULL
     OR p_attribute16 IS NOT NULL
     OR p_attribute17 IS NOT NULL
     OR p_attribute18 IS NOT NULL
     OR p_attribute19 IS NOT NULL
     OR p_attribute20 IS NOT NULL
     OR p_attribute21 IS NOT NULL
     OR p_attribute22 IS NOT NULL
     OR p_attribute23 IS NOT NULL
     OR p_attribute24 IS NOT NULL
     OR p_attribute25 IS NOT NULL
     OR p_attribute26 IS NOT NULL
     OR p_attribute27 IS NOT NULL
     OR p_attribute28 IS NOT NULL
     OR p_attribute29 IS NOT NULL
     OR p_attribute30 IS NOT NULL THEN RETURN;

  END IF;


   Get_Flexfield;
   GET_CONTEXTS;

   p_attribute_category := p_flexinfo.default_context_value;

    FOR k in 1 .. p_contexts.ncontexts LOOP

      IF p_contexts.is_global(k)
             OR p_contexts.context_code(k) = p_flexinfo.default_context_value THEN

         fnd_dflex.Get_Segments( fnd_dflex.make_context(p_flexfield,p_contexts.context_code(k))
                                ,p_segments
                                ,TRUE);

         FOR j IN 1 .. p_segments.nsegments LOOP

            l_appl_col_name := p_segments.application_column_name(j);
            tempstr := substr(l_appl_col_name, length(l_appl_col_name) -1);
            firstchar := ascii(substr(tempstr,1,2));

            IF firstchar < 49 OR firstchar > 57 THEN
               i := to_number(substr(tempstr,2,1));
            ELSE
              i := to_number(tempstr);
            END IF;

            IF i = 1 THEN
               p_attribute1 := p_segments.default_value(j);
            ELSIF i = 2 THEN
               p_attribute2 := p_segments.default_value(j);
            ELSIF i = 3 THEN
               p_attribute3 := p_segments.default_value(j);
            ELSIF i = 4 THEN
               p_attribute4 := p_segments.default_value(j);
            ELSIF i = 5 THEN
               p_attribute5 := p_segments.default_value(j);
            ELSIF i = 6 THEN
               p_attribute6 := p_segments.default_value(j);
            ELSIF i = 7 THEN
               p_attribute7 := p_segments.default_value(j);
            ELSIF i = 8 THEN
               p_attribute8 := p_segments.default_value(j);
            ELSIF i = 9 THEN
               p_attribute9 := p_segments.default_value(j);
            ELSIF i = 10 THEN
               p_attribute10 := p_segments.default_value(j);
            ELSIF i = 11 THEN
               p_attribute11 := p_segments.default_value(j);
            ELSIF i = 12 THEN
               p_attribute12 := p_segments.default_value(j);
            ELSIF i = 13 THEN
               p_attribute13 := p_segments.default_value(j);
            ELSIF i = 14 THEN
               p_attribute14 := p_segments.default_value(j);
            ELSIF i = 15 THEN
               p_attribute15 := p_segments.default_value(j);
            ELSIF i = 16 THEN
               p_attribute16 := p_segments.default_value(j);
            ELSIF i = 17 THEN
               p_attribute17 := p_segments.default_value(j);
            ELSIF i = 18 THEN
               p_attribute18 := p_segments.default_value(j);
            ELSIF i = 19 THEN
               p_attribute19 := p_segments.default_value(j);
            ELSIF i = 20 THEN
               p_attribute20 := p_segments.default_value(j);
            ELSIF i = 21 THEN
               p_attribute21 := p_segments.default_value(j);
            ELSIF i = 22 THEN
               p_attribute22 := p_segments.default_value(j);
            ELSIF i = 23 THEN
               p_attribute23 := p_segments.default_value(j);
            ELSIF i = 24 THEN
               p_attribute24 := p_segments.default_value(j);
            ELSIF i = 25 THEN
               p_attribute25 := p_segments.default_value(j);
            ELSIF i = 26 THEN
               p_attribute26 := p_segments.default_value(j);
            ELSIF i = 27 THEN
               p_attribute27 := p_segments.default_value(j);
            ELSIF i = 28 THEN
               p_attribute28 := p_segments.default_value(j);
            ELSIF i = 29 THEN
               p_attribute29 := p_segments.default_value(j);
            ELSIF i = 30 THEN
               p_attribute30 := p_segments.default_value(j);
           END IF;
       END LOOP;
      END IF;

    END LOOP;
/*
dbms_output.put_line('Attribute cate  '||p_attribute_category);

dbms_output.put_line('Attribute 1  '||p_attribute1);
dbms_output.put_line('Attribute 2  '||p_attribute2);
dbms_output.put_line('Attribute 3  '||p_attribute3);
dbms_output.put_line('Attribute 4  '||p_attribute4);
dbms_output.put_line('Attribute 5  '||p_attribute5);
dbms_output.put_line('Attribute 6  '||p_attribute6);
dbms_output.put_line('Attribute 7  '||p_attribute7);
dbms_output.put_line('Attribute 8  '||p_attribute8);
dbms_output.put_line('Attribute 9  '||p_attribute9);
dbms_output.put_line('Attribute 10  '||p_attribute10);
dbms_output.put_line('Attribute 11  '||p_attribute11);
dbms_output.put_line('Attribute 12  '||p_attribute12);
dbms_output.put_line('Attribute 13 '||p_attribute13);
dbms_output.put_line('Attribute 14  '||p_attribute14);
dbms_output.put_line('Attribute 15  '||p_attribute15);
dbms_output.put_line('Attribute 16  '||p_attribute16);
dbms_output.put_line('Attribute 17  '||p_attribute17);
dbms_output.put_line('Attribute 18  '||p_attribute18);
dbms_output.put_line('Attribute 19  '||p_attribute19);
dbms_output.put_line('Attribute 20  '||p_attribute20);
dbms_output.put_line('Attribute 21  '||p_attribute21);
dbms_output.put_line('Attribute 22  '||p_attribute22);
dbms_output.put_line('Attribute 23  '||p_attribute23);
dbms_output.put_line('Attribute 24  '||p_attribute24);
dbms_output.put_line('Attribute 25  '||p_attribute25);
dbms_output.put_line('Attribute 26  '||p_attribute26);
dbms_output.put_line('Attribute 27  '||p_attribute27);
dbms_output.put_line('Attribute 28  '||p_attribute28);
dbms_output.put_line('Attribute 29  '||p_attribute29);
dbms_output.put_line('Attribute 30  '||p_attribute30);

*/
END Get_Default_Value_Dff;


-- Added for bug#4606760
FUNCTION is_customer_associated(p_event_id IN NUMBER) RETURN VARCHAR2
IS

 CURSOR csr_cust_associations IS
 SELECT null
 FROM ota_event_associations
 WHERE event_id = p_event_id
  AND customer_id IS NOT NULL;

 l_found varchar2(1) ;

BEGIN

 OPEN csr_cust_associations;
 FETCH csr_cust_associations INTO l_found;
 IF csr_cust_associations%FOUND THEN
  CLOSE csr_cust_associations;
  RETURN 'Y';
 ELSE
  CLOSE csr_cust_associations;
  RETURN 'N';
 END IF;

END is_customer_associated;

-- Added for bug#4606760
FUNCTION check_organization_match(
    p_person_id IN NUMBER
   ,p_sponsor_org_id IN NUMBER) return VARCHAR2
IS

  CURSOR csr_person_orgs IS
  SELECT NULL
  FROM per_all_assignments_f
  WHERE person_id = p_person_id
    AND trunc(sysdate) between effective_start_date and effective_end_date
    AND organization_id = p_sponsor_org_id
    AND assignment_type in ('E', 'C', 'A');

  l_found VARCHAR2(1);

BEGIN
  OPEN csr_person_orgs;
  FETCH csr_person_orgs INTO l_found;
  IF csr_person_orgs%NOTFOUND THEN
     CLOSE csr_person_orgs;
     RETURN 'N';
  ELSE
     CLOSE csr_person_orgs;
     RETURN 'Y';
  END IF;
END check_organization_match;

FUNCTION getEnrollmentChangeReason(
    p_booking_id IN NUMBER) return VARCHAR2 is

CURSOR crs_enr_change_reason_lookup(p_meaning in varchar2)
IS
  SELECT l.lookup_code
    FROM fnd_lookup_values l
  WHERE l.lookup_type = 'ENROLMENT_STATUS_REASON'
   AND l.meaning = p_meaning
   AND l.enabled_flag = 'Y'
   and rownum=1;


  cursor crs_enrollment_change_reason
  is
   SELECT bsh.comments
    FROM ota_booking_status_histories bsh
  WHERE bsh.booking_id = p_booking_id
   AND bsh.start_date =
    (SELECT MAX(start_date)
     FROM ota_booking_status_histories
     WHERE booking_id = p_booking_id);

  CURSOR crs_enr_change_reason_lang(p_lookup_code in varchar2) IS
  SELECT meaning
  FROM hr_lookups
  WHERE lookup_type = 'ENROLMENT_STATUS_REASON'
   AND enabled_flag = 'Y'
   AND lookup_code = p_lookup_code;

  l_comments VARCHAR2(2000) := NULL;
  l_comments_lang VARCHAR2(2000) := NULL;
  l_change_reason VARCHAR2(2000) := NULL;
  l_lookup_code VARCHAR2(30);
  BEGIN

  open crs_enrollment_change_reason;
  fetch crs_enrollment_change_reason into l_comments;
  close crs_enrollment_change_reason;

  if l_comments is not null then
    open crs_enr_change_reason_lookup(l_comments);
    fetch crs_enr_change_reason_lookup into l_lookup_code;
    close crs_enr_change_reason_lookup;
  end if;

if l_lookup_code is not null then

    OPEN crs_enr_change_reason_lang(l_lookup_code);
    FETCH crs_enr_change_reason_lang
    INTO l_comments_lang;
    CLOSE crs_enr_change_reason_lang;

    IF l_comments_lang is not null then
     l_change_reason:=l_comments_lang;
    end if;

else
     l_change_reason:=l_comments;

end if;
     RETURN l_change_reason;

  EXCEPTION
  WHEN others THEN
    RETURN l_change_reason;
  END getenrollmentchangereason;

function get_lang_name
      (
      p_language_code in varchar2
      ) return varchar2 is
--
cursor csr_lookup is
  select name
   from ota_natural_languages_v
   where language_code  = p_language_code;

--
v_name ota_natural_languages_v.name%TYPE := null;
begin
if p_language_code  is not null  then
   --
    open csr_lookup;
    fetch csr_lookup into v_name;
    close csr_lookup;
end if;
--
return v_name;
--
end get_lang_name;

function get_class_available_seats(p_event_id ota_events.event_id%type) return varchar2 is
l_vacancies varchar2(30);
begin
  l_vacancies  := ota_evt_bus2.get_vacancies(p_event_id);
  if(l_vacancies  is null) then
	fnd_message.set_name('OTA', 'OTA_467151_LP_CLS_UNLIMITED');
	l_vacancies   := fnd_message.get;
  end if;
  return l_vacancies  ;
end get_class_available_seats;

function get_cls_enroll_image(p_manager_flag in varchar2,
                          p_person_id in number,
                          p_contact_id in number,
                          p_event_id in ota_events.event_id%TYPE,
                          p_mandatory_flag in ota_delegate_bookings.is_mandatory_enrollment%TYPE,
                          p_booking_status_type in ota_booking_status_types.type%TYPE) return varchar2 is

CURSOR lp_cls_enroll_p IS
SELECT lpe.lp_enrollment_id
FROM ota_lp_enrollments lpe,
     ota_lp_member_enrollments lpme
WHERE lpe.lp_enrollment_id = lpme.lp_enrollment_id AND
      lpe.enrollment_source_code = 'ADMIN' AND
      lpe.person_id = p_person_id AND
      lpme.event_id = p_event_id;

CURSOR lp_cls_enroll_c IS
SELECT lpe.lp_enrollment_id
FROM ota_lp_enrollments lpe,
     ota_lp_member_enrollments lpme
WHERE lpe.lp_enrollment_id = lpme.lp_enrollment_id AND
      lpe.enrollment_source_code = 'ADMIN' AND
      lpe.contact_id = p_contact_id AND
      lpme.event_id = p_event_id;

CURSOR cls_enroll_image IS
SELECT decode(p_manager_flag,'NOT_MANAGER',decode(nvl(p_mandatory_flag,'N'),'Y','UD','N',decode(p_booking_status_type, 'A','UD', 'UE')),
                         'IS_MANAGER',decode(p_booking_status_type, 'A','UD', 'UE')) enroll_image
FROM DUAL;

l_enroll_image varchar2(30);
l_lp_enrollment_id ota_lp_enrollments.lp_enrollment_id%type;

begin

 OPEN cls_enroll_image;
 FETCH cls_enroll_image into l_enroll_image;
 CLOSE cls_enroll_image;

 if( l_enroll_image = 'UE') then
    if(p_person_id is not null) then
        OPEN lp_cls_enroll_p;
        FETCH lp_cls_enroll_p into l_lp_enrollment_id;
        if(lp_cls_enroll_p%FOUND) then
            l_enroll_image := 'UD';
        end if;
        CLOSE lp_cls_enroll_p;
    else
        OPEN lp_cls_enroll_c;
        FETCH lp_cls_enroll_c into l_lp_enrollment_id;
        if(lp_cls_enroll_c%FOUND) then
            l_enroll_image := 'UD';
        end if;
        CLOSE lp_cls_enroll_c;
    end if;
 end if;
 return l_enroll_image;
end get_cls_enroll_image;


function get_learners_email_addresses(p_event_id ota_events.event_id%type) return varchar2 is
cursor get_internal_email_addresses is
select paf.email_address
from ota_delegate_bookings odb,
      ota_booking_status_types obst,
      per_all_people_f paf
where odb.event_id = p_event_id and
odb.booking_status_type_id = obst.booking_status_type_id and
obst.type in ('A', 'P', 'E') and
odb.delegate_person_id = paf.person_id and
trunc(sysdate) between paf.effective_start_date and paf.effective_end_date and
paf.email_address is not null;

cursor get_external_email_addresses is
SELECT PARTY.EMAIL_ADDRESS
FROM HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
    HZ_PARTIES PARTY,
    HZ_RELATIONSHIPS REL,
    HZ_CUST_ACCOUNTS ROLE_ACCT,
    HZ_ROLE_RESPONSIBILITY ROL ,
    HZ_ORG_CONTACTS ORG_CONT,
    HZ_LOCATIONS LOC,
    HZ_PARTY_SITES PARTY_SITE,
    HZ_CUST_ACCT_SITES_ALL ACCT_SITE,
    ota_delegate_bookings odb,
    ota_booking_status_types obst
WHERE
    ACCT_ROLE.PARTY_ID = REL.PARTY_ID
AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'
AND REL.SUBJECT_ID = PARTY.PARTY_ID
AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
AND ROLE_ACCT.PARTY_ID = REL.OBJECT_ID
AND ACCT_ROLE.CUST_ACCOUNT_ID = ROLE_ACCT.CUST_ACCOUNT_ID
AND ROL.PRIMARY_FLAG (+) = 'Y'
AND ROL.CUST_ACCOUNT_ROLE_ID (+) = ACCT_ROLE.CUST_ACCOUNT_ROLE_ID
AND ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
AND PARTY_SITE.LOCATION_ID = LOC.LOCATION_ID(+)
AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID(+)
AND ACCT_SITE.CUST_ACCT_SITE_ID (+) = ACCT_ROLE.CUST_ACCT_SITE_ID
AND ACCT_ROLE.STATUS = 'A'
AND ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = odb.delegate_contact_id
AND odb.event_id = p_event_id
AND odb.booking_status_type_id = obst.booking_status_type_id
AND obst.type in ('A', 'P', 'E')
AND PARTY.EMAIL_ADDRESS is not null;

email_addresses varchar2(4000) := '';
email_count number := 0;

begin
  for intemailids in get_internal_email_addresses loop
    if(email_count = 0) then
        email_addresses := intemailids.email_address;
    else
        email_addresses := email_addresses || ',' || intemailids.email_address;
    end if;
    email_count := email_count+1;
  end loop;

    for extemailids in get_external_email_addresses loop
    if(email_count = 0) then
        email_addresses := extemailids.email_address;
    else
        email_addresses := email_addresses || ',' || extemailids.email_address;
    end if;
    email_count := email_count+1;
  end loop;

  return email_addresses;

end get_learners_email_addresses;


--function to determine switcher action for bulk and single on list of classes page
--p_enr_type is 'B' for bulk enroll switcher and 'S' for Single enroll switcher
FUNCTION is_class_enrollable(
     p_enr_type varchar2,
     p_class_id ota_events.event_id%TYPE)
RETURN VARCHAR2
IS

  CURSOR csr_get_class_details IS
  SELECT null
  FROM ota_events
  WHERE event_id = p_class_id

    AND ota_timezone_util.convert_date(sysdate, to_char(sysdate,'HH24:MI'), ota_timezone_util.get_server_timezone_code, timezone)
       BETWEEN to_date(to_char(nvl(enrolment_start_date,trunc(sysdate)),'YYYY/MM/DD') || ' ' || '00:00' , 'YYYY/MM/DD HH24:MI')
       AND to_date(to_char(nvl(enrolment_end_date,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') || ' ' || '23:59', 'YYYY/MM/DD HH24:MI')
    AND event_type IN ('SCHEDULED', 'SELFPACED')
    AND event_status IN ('N', 'P', 'F');

  l_exists VARCHAR2(1);
BEGIN
OPEN csr_get_class_details;
   FETCH csr_get_class_details INTO l_exists;
   IF csr_get_class_details%NOTFOUND THEN
      CLOSE csr_get_class_details;
      if p_enr_type = 'B' then
        RETURN 'BULK_ENR_DISABLE';
       else
        RETURN 'SINGLE_ENR_DISABLE';
      end if;
   ELSE
      CLOSE csr_get_class_details;
      if p_enr_type = 'B' then
        RETURN 'BULK_ENR_ENABLE';
       else
        RETURN 'SINGLE_ENR_ENABLE';
       end if;
   END IF;
END is_class_enrollable;

end  ota_utility;

/
