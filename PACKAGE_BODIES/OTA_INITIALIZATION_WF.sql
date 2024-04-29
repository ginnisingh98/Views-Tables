--------------------------------------------------------
--  DDL for Package Body OTA_INITIALIZATION_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_INITIALIZATION_WF" as
/* $Header: ottomint.pkb 120.43.12010000.13 2009/08/31 13:50:06 smahanka ship $ */

g_package  varchar2(33) := '  ota_initialization_wf.';  -- Global package name


-- ----------------------------------------------------------------------------
-- |-----------------< initialize_cancel_enrollment >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a used to start a workflow process for Enrollment
--   Cancellation.
--
--   This procedure will only be used for OTA and OM integration.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
-- p_booking_id
-- p_Line_id
-- p_org_id
-- p_Status
-- p_Event_id
-- p_Itemtype
-- p_process
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

PROCEDURE INITIALIZE_CANCEL_ENROLLMENT
(
p_booking_id   IN    NUMBER,
p_Line_id      IN NUMBER,
p_org_id    IN NUMBER,
p_Status       IN VARCHAR2,
p_Event_id     IN NUMBER,
p_Itemtype     IN VARCHAR2,
p_process      IN VARCHAR2)

IS

l_order_number          oe_order_headers.order_number%type;
l_header_id          oe_order_headers.header_id%type;
l_process               wf_activities.name%type := upper(p_process);
l_itemkey            wf_items.item_key%type := to_char(p_line_id);
l_owner_name      per_people_f.full_name%type;
l_event_title     ota_events_tl.title%type;  --MLS change _tl added
l_owner_id        ota_events.owner_id%type;
l_email_address      per_people_f.email_address%type;
l_full_name       per_people_f.full_name%type;


CURSOR C_ORDER
IS
SELECT ORDER_NUMBER ,
    HEADER_ID
FROM OE_ORDER_HEADERS_ALL
WHERE HEADER_ID IN(
SELECT HEADER_ID
FROM OE_ORDER_LINES_ALL
WHERE LINE_ID = p_line_id);


CURSOR c_event
IS
SELECT TITLE,
    owner_id
FROM   OTA_EVENTS_VL --MLS change _VL added
WHERE  event_id = p_event_id;


CURSOR C_person
IS
SELECT user_name
FROM
   fnd_user
WHERE
   employee_id = l_owner_id
   AND trunc(sysdate) between start_date and nvl(end_date,to_date('4712/12/31', 'YYYY/MM/DD'));      --Bug 5676892

l_proc   varchar2(72) := g_package||'initialize_cancel_enrollment';

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN C_ORDER;
  FETCH C_ORDER INTO l_order_number,l_header_id;
  CLOSE C_ORDER;
  hr_utility.set_location('Entering:'||l_proc, 10);
  OPEN c_event;
  FETCH c_event INTO l_event_title,l_owner_id;
  CLOSE c_event;
  hr_utility.set_location('Entering:'||l_proc, 15);

 /* OPEN c_person;
  FETCH c_person INTO l_full_name,l_email_address;
  CLOSE c_person;*/
  hr_utility.set_location('Entering:'||l_proc, 20);

  WF_ENGINE.CREATEPROCESS(p_itemtype, l_itemkey, 'OTA_ENR_CANCEL'  );
 -- WF_ENGINE.setitemattrnumber(p_itemtype, l_itemkey,'BOOKING_ID', p_booking_id);
  WF_ENGINE.setitemattrtext(p_itemtype, l_itemkey,'EVENT_TITLE', l_Event_title);
 -- WF_ENGINE.SetItemattrtext(p_itemtype,l_itemkey,'EVENT_OWNER',l_email_address);
  WF_ENGINE.SetItemattrnumber(p_itemtype,l_itemkey,'ORDER_NUMBER',l_order_number);
  WF_ENGINE.SetItemattrnumber(p_itemtype,l_itemkey,'HEADER_ID',l_header_id);
  WF_ENGINE.SetItemattrnumber(p_itemtype,l_itemkey,'ORG_ID',p_org_id);

 -- WF_ENGINE.SetItemattrtext(p_itemtype,l_itemkey,'FULL_NAME',l_full_name);
  WF_ENGINE.STARTPROCESS(p_itemtype,l_itemkey);
    hr_utility.set_location('Leaving:'||l_proc, 25);

  EXCEPTION
  WHEN OTHERS THEN
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  --RAISE;


END;
-- ----------------------------------------------------------------------------
-- |-----------------------< initialize_cancel_event >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  is used to start workflow process for event cancellation.
--
--   This procedure will only be used for OTA and OM integration.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_event_id
--   p_line_id
--   p_status
--   p_event_title
--   p_itemtype
--   p_owner_id
--   p_org_id
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


Procedure INITIALIZE_CANCEL_EVENT
(
p_event_id     IN NUMBER,
p_Line_id      IN NUMBER,
p_Status    IN VARCHAR2,
p_Event_title  IN VARCHAR2 ,
p_owner_id     IN NUMBER,
p_org_id       IN NUMBER,
p_itemtype     IN VARCHAR2)
IS

CURSOR C_ORDER IS
SELECT
   order_number ,
   header_id
FROM
  OE_ORDER_HEADERS_ALL
WHERE
   HEADER_ID IN(
      SELECT
         HEADER_ID
      FROM
         OE_ORDER_LINES_ALL
      WHERE
         LINE_ID = p_line_id);

CURSOR
c_people
IS
SELECT
   USER_NAME
FROM
     FND_USER
WHERE
   employee_id = p_owner_id
    AND trunc(sysdate) between start_date and nvl(end_date,to_date('4712/12/31', 'YYYY/MM/DD'));      --Bug 5676892


CURSOR C_ORDER_LINE IS
Select
    line_number
from
    oe_order_lines_all
where
    line_id = p_line_id;


l_user_name    varchar2(100);
l_full_name    per_all_people_f.full_name%TYPE;
l_order_number          oe_order_headers.order_number%type;
l_header_id          oe_order_headers.header_id%type;
l_proc   varchar2(72) := g_package||'initialize_cancel_event';
l_wf_date         VARCHAR2(30);
l_item_key     wf_items.item_key%TYPE;
l_line_number        oe_order_lines_all.line_number%type;

BEGIN
   hr_utility.set_location('Entering:'||l_proc, 5);

   OPEN C_ORDER;
   FETCH C_ORDER INTO l_order_number,l_header_id;
   CLOSE C_ORDER;
   hr_utility.set_location('Entering:'||l_proc, 15);
      OPEN C_PEOPLE;
   FETCH c_people INTO l_user_name;
      CLOSE c_people;
   hr_utility.set_location('Entering:'||l_proc, 17);
   SELECT to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS')
     INTO l_wf_date
     FROM dual;
--Bug#2587983 get line number
        OPEN C_ORDER_LINE;
        FETCH C_ORDER_LINE into l_line_number;
        CLOSE C_ORDER_LINE;

--Bug#2587983 get line number

    l_item_key := p_line_id||l_wf_date;
   WF_ENGINE.CREATEPROCESS(p_itemtype, l_item_key, 'OTA_EVT_CANCEL');
   WF_ENGINE.setitemattrtext(p_itemtype, l_item_key,'EVENT_TITLE', p_event_id); --Enh 5606090: Language support for Event Details.
   WF_ENGINE.SetItemattrnumber(p_itemtype,l_item_key,'ORDER_NUMBER',l_order_number);
   WF_ENGINE.SetItemattrtext(p_itemtype,l_item_key,'EVENT_OWNER',l_user_name);
   WF_ENGINE.SetItemattrtext(p_itemtype,l_item_key,'STATUS',p_status);
   WF_ENGINE.SetItemattrnumber(p_itemtype,l_item_key,'LINE_NUMBER',l_line_number);
   WF_ENGINE.STARTPROCESS(p_itemtype,l_item_key);

 EXCEPTION
  WHEN OTHERS THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   hr_utility.set_location('Leaving:'||l_proc, 20);

END;


-- ----------------------------------------------------------------------------
-- |-------------------< initialize_event_date_changed >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be to start workflow process for course end date changed.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
-- p_Line_id
-- p_org_id
-- p_Event_title
-- p_Itemtype
-- p_process
-- p_emailid
-- p_name
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

PROCEDURE  INITIALIZE_EVENT_DATE_CHANGED
(
p_Line_id      IN NUMBER,
p_org_id    IN NUMBER,
p_Event_title  IN VARCHAR2,
p_Itemtype     IN VARCHAR2,
p_process      IN VARCHAR2,
p_emailid      IN VARCHAR2,
p_name      IN VARCHAR2)
IS
BEGIN
null;
END;

-- ----------------------------------------------------------------------------
-- |----------------------< initialize_cancel_order  >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to start a workflow if order got cancel from OM.
--
--   This procedure will only be used for OTA and OM integration.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_itemtype
--  p_process
--  p_Event_title
--  p_event_id
--  p_email_address
--  p_line_id
--  p_status
--  p_full_name
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


PROCEDURE INITIALIZE_CANCEL_ORDER (
p_itemtype     IN VARCHAR2,
p_process      IN VARCHAR2,
p_Event_title  IN VARCHAR2,
p_event_id     IN    NUMBER,
p_user_name    IN VARCHAR2,
p_line_id      IN    NUMBER,
p_status    IN    VARCHAR2,
p_full_name    IN    VARCHAR2
) IS


CURSOR C_ORDER IS
SELECT
   order_number ,
   header_id
FROM
  OE_ORDER_HEADERS_ALL
WHERE
   HEADER_ID IN(
      SELECT
         HEADER_ID
      FROM
         OE_ORDER_LINES_ALL
      WHERE
         LINE_ID = p_line_id);

CURSOR C_ORDER_LINE IS
Select
    line_number
from
    oe_order_lines_all
where
    line_id = p_line_id;

l_order_number          oe_order_headers.order_number%type;
l_header_id          oe_order_headers.header_id%type;
l_process               wf_activities.name%type := upper(p_process);
l_itemkey            wf_items.item_key%type;
l_line_number        oe_order_lines_all.line_number%type;

l_proc   varchar2(72) := g_package||'initialize_cancel_order';

BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);

OPEN C_ORDER;
FETCH C_ORDER INTO l_order_number,l_header_id;
CLOSE C_ORDER;
 hr_utility.set_location('Entering:'||l_proc, 10);

--Bug#2587983 get line number
        OPEN C_ORDER_LINE;
        FETCH C_ORDER_LINE into l_line_number;
        CLOSE C_ORDER_LINE;

--Bug#2587983 get line number

WF_ENGINE.CREATEPROCESS(p_itemtype, to_char(p_line_id), l_process);
WF_ENGINE.setitemattrtext(p_itemtype, to_char(p_line_id), 'EVENT_TITLE', p_event_id); --Enh 5606090: Language support for Event Details.
WF_ENGINE.SetItemattrtext(p_itemtype,to_char(p_line_id), 'EVENT_OWNER',p_user_name);
WF_ENGINE.SetItemattrnumber(p_itemtype,to_char(p_line_id), 'ORDER_NUMBER',l_order_number);
WF_ENGINE.SetItemattrtext(p_itemtype,to_char(p_line_id), 'STATUS',p_status);
WF_ENGINE.SetItemattrnumber(p_itemtype,to_char(p_line_id),'LINE_NUMBER',l_line_number);
WF_ENGINE.STARTPROCESS(p_itemtype,to_char(p_line_id));

EXCEPTION
WHEN OTHERS THEN
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   hr_utility.set_location('leaving:'||l_proc, 20);

END;


-- ----------------------------------------------------------------------------
-- |-----------------------------< Manual_waitlist  >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to start a workflow to notify event owner to
--   do manual waitlist enrollment .
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_itemtype
--  p_process
--  p_Event_title
--  p_event_id
--  p_user_name
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


PROCEDURE MANUAL_WAITLIST (
p_itemtype  IN VARCHAR2,
p_process   IN VARCHAR2,
p_Event_title  IN VARCHAR2,
p_event_id     IN    NUMBER,
p_item_key        IN    VARCHAR2,
p_user_name       IN VARCHAR2
) IS

l_proc   varchar2(72) := g_package||'manual_waitlist';
l_process               wf_activities.name%type := upper(p_process);

BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);


 hr_utility.set_location('Entering:'||l_proc, 10);

WF_ENGINE.CREATEPROCESS(p_itemtype, p_item_key, l_process);
WF_ENGINE.setitemattrtext(p_itemtype, p_item_key, 'EVENT_TITLE', p_event_id); --Enh 5606090: Language support for Event Details.
WF_ENGINE.SetItemattrtext(p_itemtype, p_item_key,'EVENT_OWNER',p_user_name);
WF_ENGINE.STARTPROCESS(p_itemtype,p_item_key);

EXCEPTION
WHEN OTHERS THEN
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   hr_utility.set_location('leaving:'||l_proc, 20);

END;

-- ----------------------------------------------------------------------------
-- |----------------------< Manual_enroll_waitlist  >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to start a workflow to notify event owner to
--   do manual waitlist enrollment .
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_itemtype
--  p_process
--  p_Event_title
--  p_event_id
--  p_user_name
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

PROCEDURE MANUAL_ENROLL_WAITLIST (
p_itemtype  IN VARCHAR2,
p_process   IN VARCHAR2,
p_Event_title  IN VARCHAR2,
p_item_key     IN    VARCHAR2,
p_owner_id        IN    NUMBER
) IS

l_proc   varchar2(72) := g_package||'manual_enroll_waitlist';
l_process               wf_activities.name%type := upper(p_process);

l_user_name  varchar2(80);

CURSOR C_USER IS
SELECT
 USER_NAME
FROM
 FND_USER
WHERE
Employee_id = p_owner_id
AND trunc(sysdate) between start_date and nvl(end_date,to_date('4712/12/31', 'YYYY/MM/DD'));      --Bug 5676892

BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);

OPEN C_USER;
FETCH C_USER INTO l_user_name;
CLOSE C_USER;

 hr_utility.set_location('Entering:'||l_proc, 10);

WF_ENGINE.CREATEPROCESS(p_itemtype, p_item_key, l_process);
WF_ENGINE.setitemattrtext(p_itemtype, p_item_key, 'EVENT_TITLE', p_event_title);
WF_ENGINE.SetItemattrtext(p_itemtype,p_item_key, 'EVENT_OWNER',l_user_name);
WF_ENGINE.STARTPROCESS(p_itemtype,p_item_key);

EXCEPTION
WHEN OTHERS THEN
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   hr_utility.set_location('leaving:'||l_proc, 20);

END;

Procedure set_addnl_attributes(p_item_type 	in wf_items.item_type%type,
                                p_item_key in wf_items.item_key%type,
                                p_eventid in ota_events.event_id%type,
				p_from in varchar2 default null
                                 )

is

l_proc 	varchar2(72) := g_package||'set_addnl_attributes';

l_actual_cost ota_events.actual_cost%type;
l_budget_currency_code ota_events.budget_currency_code%type;
l_act_ver_id ota_events.activity_version_id%type;
l_off_id ota_events.parent_offering_id%type;
l_event_id ota_events.event_id%type;
l_event_type ota_events.event_type%type;
l_object_type varchar2(240);

cursor get_event_type is
select parent_event_id,event_type from
ota_events where event_id =p_eventid;


cursor get_addnl_event_info
is
select
--added after show n tell
oev.activity_version_id,oev.actual_cost, oev.budget_currency_code,
oev.parent_offering_id,ota_timezone_util.get_timezone_name(oev.timezone) timezone
from ota_events_tl evt, ota_events oev
where evt.event_id =oev.event_id
and oev.event_id = l_event_id
and evt.language=USERENV('LANG');

cursor get_lang_det is
select ofe.language_id, ocu.category
from ota_offerings ofe, ota_category_usages_tl ocu
where ofe.delivery_mode_id = ocu.category_usage_id
and ocu.language=USERENV('LANG')
and ofe.offering_id = l_off_id;

l_course_name OTA_ACTIVITY_VERSIONS_TL.version_name%TYPE;
l_lang_description fnd_languages_vl.description%TYPE;
l_curr_name fnd_currencies_vl.name%TYPE;
l_lang_id ota_offerings.language_id%type;
l_delivery_method ota_category_usages.category%type;
l_timezone varchar2(300);

begin

-- first check whether event is class or session

open get_event_type;
fetch get_event_type into l_event_id,l_event_type;
close get_event_type;


if l_event_type <> 'SESSION' then
 l_event_id := p_eventid;
end if;

open get_addnl_event_info;
fetch get_addnl_event_info into l_act_ver_id,l_actual_cost,
l_budget_currency_code,l_off_id, l_timezone;
close get_addnl_event_info;

open get_lang_det;
fetch get_lang_det into l_lang_id,l_delivery_method;
close get_lang_det;

l_course_name := ota_general.get_course_name(l_act_ver_id);
l_curr_name := ota_general.fnd_currency_name(l_budget_currency_code);
l_curr_name := l_actual_cost || ' ' || l_curr_name;

l_lang_description := ota_general.fnd_lang_desc(l_lang_id);

--set wf item attributes

wf_engine.setItemAttrText(p_item_type,p_item_key,'COST',l_curr_name );
wf_engine.setItemAttrText(p_item_type,p_item_key,'COURSE_NAME',l_course_name );
wf_engine.setItemAttrText(p_item_type,p_item_key,'LANGUAGE',l_lang_description );
wf_engine.setItemAttrText(p_item_type,p_item_key,'DELIVERY_METHOD',l_delivery_method );


if p_from is null then
wf_engine.setItemAttrText(p_item_type,p_item_key,'TIMEZONE',l_timezone );
end if;

-- get object type

if l_event_type = 'SESSION' then

l_object_type := ota_utility.get_lookup_meaning('OTA_OBJECT_TYPE','S', 800);

else

l_object_type := ota_utility.get_lookup_meaning('OTA_OBJECT_TYPE','CL', 800);
end if;


WF_ENGINE.setitemattrText(p_item_type, p_item_key, 'SECTION_NAME', l_object_type);



end set_addnl_attributes;

Procedure Initialize_instructor_wf(
            p_item_type 		in wf_items.item_type%type,
            p_eventid 	in ota_events.event_id%type,
            p_sup_res_id       in ota_resource_bookings.supplied_resource_id%type,
            p_start_date in varchar2,
            p_end_date in varchar2,
            p_start_time in ota_events.course_start_time%type,
            p_end_time in ota_events.course_start_time%type,
            p_status in varchar2,
            p_res_book_id in ota_resource_bookings.resource_booking_id%type,
            p_person_id in number,
            p_event_fired in varchar2)

is
l_proc 	varchar2(72) := g_package||'Initialize_instructor_wf';

l_process             	wf_activities.name%type := 'OTA_INSTRUCTOR_NTF_JSP_PRC';
l_item_key     wf_items.item_key%type;

l_title ota_events_tl.title%type;
l_start_date date;
l_end_date date;
l_start_time ota_events.course_start_time%type;
l_end_time ota_events.course_start_time%type;

l_location_id ota_events.location_id %type;
l_event_type ota_events.event_type%type;

l_person_id per_people_f.person_id%type;

l_object_type varchar2(240);
l_location_name hr_locations_all_tl.location_code%type;
l_enrollment_status_name ota_booking_status_types_tl.name%TYPE;
l_timezone varchar2(300);




--l_booking_id ota_delegate_bookings.booking_id%type;
/*
cursor get_resource_info
is
select osr.trainer_id
from  ota_suppliable_resources osr
where
osr.supplied_resource_id=p_sup_res_id;
*/
cursor get_event_info
is
select evt.title,
oev.course_start_date,oev.course_end_date,oev.course_start_time, oev.course_end_time,
oev.location_id,oev.event_type,ota_timezone_util.get_timezone_name(oev.timezone)
from ota_events_tl evt, ota_events oev
where evt.event_id =oev.event_id
and oev.event_id = p_eventid
and evt.language= USERENV('LANG');

cursor get_all_resources_info
is
select distinct(osr.trainer_id) trainer_id ,orb.required_date_from,orb.required_date_to,
orb.required_start_time,orb.required_end_time,orb.status,ota_timezone_util.get_timezone_name(orb.timezone_code) timezone,
orb.resource_booking_id resource_booking_id
from ota_resource_bookings orb,ota_suppliable_resources osr
where orb.supplied_resource_id = osr.supplied_resource_id
and osr.resource_type ='T'
and orb.event_id = p_eventid
and (p_res_book_id is null or orb.resource_booking_id=p_res_book_id);

cursor get_resource_info
is
select osr.trainer_id trainer_id ,orb.required_date_from,orb.required_date_to,
orb.required_start_time,orb.required_end_time,orb.status,ota_timezone_util.get_timezone_name(orb.timezone_code) timezone,
orb.resource_booking_id resource_booking_id
from ota_resource_bookings orb,ota_suppliable_resources osr
where orb.supplied_resource_id = osr.supplied_resource_id
and osr.supplied_resource_id = p_sup_res_id
and osr.resource_type ='T'
and orb.event_id = p_eventid;

resource_rec get_resource_info%ROWTYPE;

begin
hr_utility.set_location('Entering:'||l_proc, 5);

open get_event_info;
fetch get_event_info into l_title,l_start_date,l_end_date,l_start_time,
l_end_time,l_location_id,l_event_type,l_timezone;
close get_event_info;

hr_utility.trace ('after get_event_info ' ||l_title);

-- get location
l_location_name := ota_general.get_Location_code(l_location_id);

if p_event_fired = 'INSTRUCTOR_CANCEL' then

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;


-- get item key for the process
WF_ENGINE.CREATEPROCESS(p_item_type, l_item_key, l_process);

hr_utility.trace ('after Createprocess ' ||l_item_key);


-- set creator,current and supervisor name
set_wf_item_attr(p_person_id => p_person_id,
                            p_item_type => p_item_type,
                            p_item_key => l_item_key);

 WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_NTF_EVENT_FIRED', p_event_fired);




WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'EVENT_TITLE', p_eventid);  --Enh 5606090: Language support for Event Details.
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'TARGET_DATE', p_start_date);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'COMPLETION_DATE', p_end_date);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_START_TIME', nvl(p_start_time,'00:00'));
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_END_TIME', nvl(p_end_time,'23:59'));






WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'LP_NAME', l_location_name);



-- get trainer enrollment status

--l_enrollment_status_name := ota_utility.get_lookup_meaning('RESOURCE_BOOKING_STATUS',p_status, 800);      Enh 5606090: Language support for Event Details.

  WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'LP_ENROLLEE', p_status);     --Enh 5606090: Language support for Event Details.

set_addnl_attributes(p_item_type => p_item_type,
                                p_item_key => l_item_key,
                                p_eventid => p_eventid
                                 );


WF_ENGINE.STARTPROCESS(p_item_type,l_item_key);

elsif p_event_fired = 'INSTRUCTOR_REMIND' then

    open get_resource_info;
    fetch get_resource_info into resource_rec;
    if get_resource_info%FOUND then
        -- Get the next item key from the sequence
     select hr_workflow_item_key_s.nextval
      into   l_item_key
      from   sys.dual;

    hr_utility.trace ('Before Createprocess  ' ||resource_rec.trainer_id );
-- get item key for the process
    WF_ENGINE.CREATEPROCESS(p_item_type, l_item_key, l_process);

    hr_utility.trace ('after Createprocess ' ||l_item_key);

    set_wf_item_attr(p_person_id => resource_rec.trainer_id,
                            p_item_type => p_item_type,
                            p_item_key => l_item_key);

    WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_NTF_EVENT_FIRED', p_event_fired);

    WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'EVENT_TITLE', p_eventid);  --Enh 5606090: Language support for Event Details.
    WF_ENGINE.setitemAttrText(p_item_type,l_item_key, 'BOOKING_ID', resource_rec.resource_booking_id); --Enh 5606090: Language support for Event Details.
    WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'TARGET_DATE', resource_rec.required_date_from);
    WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'COMPLETION_DATE', resource_rec.required_date_to);
    WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_START_TIME', nvl(resource_rec.required_start_time,'00:00'));
    WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_END_TIME', nvl(resource_rec.required_end_time,'23:59'));
    wf_engine.setItemAttrText(p_item_type,l_item_key,'TIMEZONE',resource_rec.timezone );

    WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'LP_NAME', l_location_name);

    -- get trainer enrollment status

    l_enrollment_status_name := ota_utility.get_lookup_meaning('RESOURCE_BOOKING_STATUS',resource_rec.status, 800);

    WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'LP_ENROLLEE', l_enrollment_status_name);

    set_addnl_attributes(p_item_type => p_item_type,
                                p_item_key => l_item_key,
                                p_eventid => p_eventid,
				p_from => 'I'
                                 );


    WF_ENGINE.STARTPROCESS(p_item_type,l_item_key);
    end if;
    close get_resource_info;
else

for rec in get_all_resources_info
Loop

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;

hr_utility.trace ('Before Createprocess ' ||rec.trainer_id);
-- get item key for the process
WF_ENGINE.CREATEPROCESS(p_item_type, l_item_key, l_process);

hr_utility.trace ('after Createprocess ' ||l_item_key);


/*
open get_resource_info;
fetch get_resource_info into l_person_id;
close get_resource_info;*/
-- set creator,current and supervisor name
set_wf_item_attr(p_person_id => rec.trainer_id,
                            p_item_type => p_item_type,
                            p_item_key => l_item_key);

 WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_NTF_EVENT_FIRED', p_event_fired);



WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'EVENT_TITLE', p_eventid);  --Enh 5606090: Language support for Event Details.
WF_ENGINE.setitemAttrText(p_item_type,l_item_key, 'BOOKING_ID', rec.resource_booking_id); --Enh 5606090: Language support for Event Details.
if p_event_fired = 'CLASS_CANCEL' or p_event_fired = 'CLASS_RESCHEDULE' then

WF_ENGINE.setitemattrdate(p_item_type, l_item_key, 'TARGET_DATE', l_start_date);
WF_ENGINE.setitemattrdate(p_item_type, l_item_key, 'COMPLETION_DATE', l_end_date);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_START_TIME', nvl(l_start_time,'00:00'));
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_END_TIME', nvl(l_end_time,'23:59'));
wf_engine.setItemAttrText(p_item_type,l_item_key,'TIMEZONE',l_timezone );

else
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'TARGET_DATE', rec.required_date_from);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'COMPLETION_DATE', rec.required_date_to);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_START_TIME', nvl(rec.required_start_time,'00:00'));
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_END_TIME', nvl(rec.required_end_time,'23:59'));
wf_engine.setItemAttrText(p_item_type,l_item_key,'TIMEZONE',rec.timezone );

end if;




WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'LP_NAME', l_location_name);



-- get trainer enrollment status

l_enrollment_status_name := ota_utility.get_lookup_meaning('RESOURCE_BOOKING_STATUS',rec.status, 800);

  WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'LP_ENROLLEE', l_enrollment_status_name);

set_addnl_attributes(p_item_type => p_item_type,
                                p_item_key => l_item_key,
                                p_eventid => p_eventid,
				p_from => 'I'
                                 );


WF_ENGINE.STARTPROCESS(p_item_type,l_item_key);
end loop;

end if;
hr_utility.set_location('Leaving:'||l_proc, 5);

end Initialize_instructor_wf;

Procedure Initialize_wf(p_process 	in wf_process_activities.process_name%type,
            p_item_type 		in wf_items.item_type%type,
            p_person_id 	in number ,
            p_eventid       in ota_Events.event_id%type,
            p_event_fired in varchar2)

is
l_proc 	varchar2(72) := g_package||'Initialize_wf';

l_process             	wf_activities.name%type := upper(p_process);
l_item_key     wf_items.item_key%type;

l_title ota_events_tl.title%type;
l_start_date date;
l_end_date date;
l_start_time ota_events.course_start_time%type;
l_end_time ota_events.course_start_time%type;
l_location_id ota_events.location_id %type;
l_event_type ota_events.event_type%type;

--l_object_type varchar2(240);
l_location_name hr_locations_all_tl.location_code%type;
l_enrollment_status_name ota_booking_status_types_tl.name%TYPE;

l_booking_id ota_delegate_bookings.booking_id%type;
l_person_id number(15);

cursor get_event_info
is
select evt.title,oev.course_start_date,oev.course_end_date,
oev.course_start_time, oev.course_end_time,
oev.location_id
from ota_events_tl evt, ota_events oev
where evt.event_id =oev.event_id
and oev.event_id = p_eventid
and evt.language=USERENV('LANG');

-- get all the person's enrolled into the event
cursor get_booking_info
is
select odb.booking_id , odb.delegate_person_id
from ota_delegate_bookings odb, ota_booking_status_types bst
where (p_person_id is null or
odb.delegate_person_id = p_person_id)
and odb.event_id =p_eventid
and odb.booking_status_type_id = bst.booking_status_type_id
and bst.type in ('P','W','R');

--Enh 5606090: Language support for Event Details.
cursor get_booking_info_class_cancel
is
select odb.booking_id , odb.delegate_person_id
from ota_delegate_bookings odb, ota_booking_status_types bst
where (p_person_id is null or
odb.delegate_person_id = p_person_id)
and odb.event_id =p_eventid
and odb.booking_status_type_id = bst.booking_status_type_id;


begin
hr_utility.set_location('Entering:'||l_proc, 5);

open get_event_info;
fetch get_event_info into l_title,l_start_date,l_end_date,l_start_time,
l_end_time,l_location_id;
close get_event_info;

if p_event_fired = 'CLASS_CANCEL' then

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;
-- get item key for the process
WF_ENGINE.CREATEPROCESS(p_item_type, l_item_key, l_process);

-- set creator,current and supervisor name
set_wf_item_attr(p_person_id => p_person_id,
                            p_item_type => p_item_type,
                            p_item_key => l_item_key);

open get_booking_info_class_cancel;
fetch get_booking_info_class_cancel into l_booking_id,l_person_id;
close get_booking_info_class_cancel;

 WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_NTF_EVENT_FIRED', p_event_fired);



WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'EVENT_TITLE', p_eventid); --Enh 5606090: Language support for Event Details.
WF_ENGINE.setitemattrdate(p_item_type, l_item_key, 'TARGET_DATE', l_start_date);
WF_ENGINE.setitemattrdate(p_item_type, l_item_key, 'COMPLETION_DATE', l_end_date);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_START_TIME', nvl(l_start_time,'00:00'));
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_END_TIME', nvl(l_end_time,'23:59'));
WF_ENGINE.setitemattrNumber(p_item_type, l_item_key, 'BOOKING_ID', l_booking_id);

-- get location
l_location_name := ota_general.get_Location_code(l_location_id);

WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'LP_NAME', l_location_name);

set_addnl_attributes(p_item_type => p_item_type,
                                p_item_key => l_item_key,
                                p_eventid => p_eventid
                                 );


WF_ENGINE.STARTPROCESS(p_item_type,l_item_key);


else

for rec in get_booking_info
Loop

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;
-- get item key for the process
WF_ENGINE.CREATEPROCESS(p_item_type, l_item_key, l_process);

-- set creator,current and supervisor name
set_wf_item_attr(p_person_id => rec.delegate_person_id,
                            p_item_type => p_item_type,
                            p_item_key => l_item_key);



 WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_NTF_EVENT_FIRED', p_event_fired);



WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'EVENT_TITLE',  p_eventid); --Enh 5606090: Language support for Event Details.
WF_ENGINE.setitemattrdate(p_item_type, l_item_key, 'TARGET_DATE', l_start_date);
WF_ENGINE.setitemattrdate(p_item_type, l_item_key, 'COMPLETION_DATE', l_end_date);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_START_TIME', nvl(l_start_time,'00:00'));
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_END_TIME', nvl(l_end_time,'23:59'));

-- get location
l_location_name := ota_general.get_Location_code(l_location_id);

WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'LP_NAME', l_location_name);

 -- if l_process = 'OTA_ENROLL_STATUS_CHNG_JSP_PRC' then

          WF_ENGINE.setitemattrNumber(p_item_type, l_item_key, 'BOOKING_ID', rec.booking_id);
--  end if;

 set_addnl_attributes(p_item_type => p_item_type,
                                p_item_key => l_item_key,
                                p_eventid => p_eventid
                                 );
WF_ENGINE.STARTPROCESS(p_item_type,l_item_key);

end loop;

end if;
hr_utility.set_location('Leaving:'||l_proc, 5);

end initialize_wf;


Procedure Initialize_auto_wf(p_process 	in wf_process_activities.process_name%type,
            p_item_type 		in wf_items.item_type%type,
            p_event_fired in varchar2,
            p_event_id in ota_events.event_id%type default null)
is
l_proc 	varchar2(72) := g_package||'Initialize_auto_wf';

l_notify_days_before number(9) := fnd_profile.value('OTA_INST_REMIND_NTF_DAYS');

--get all classes begining today

cursor get_all_class_info
is
select event_id
from  ota_events
where (course_start_date = trunc(sysdate) )
and event_type in ('SCHEDULED' , 'SELFPACED')
and event_status <> 'A';

-- get all waitlisted learners in a class

cursor get_all_wait_Learners(crs_event_id number)
is
select odb.delegate_person_id
from ota_delegate_bookings odb,ota_booking_status_types bst
where odb.event_id = crs_event_id
and odb.booking_status_type_id = bst.booking_status_type_id
and bst.type = 'W';

--- get all class info for instructor

cursor get_supp_res_id is
select supplied_resource_id
from ota_suppliable_resources
where resource_type ='T';

cursor get_all_cls_info (l_supp_res_id number) is
select orb.event_id event_id
from  ota_resource_bookings orb
where orb.supplied_resource_id = l_supp_res_id
and orb.required_date_from = (trunc(sysdate)+l_notify_days_before)
and orb.status= 'C'
and orb.event_id is not null;

/*cursor get_all_cls_info
is
select distinct(orb.event_id) event_id, orb.supplied_resource_id
from  ota_resource_bookings orb,ota_suppliable_resources osr
where orb.supplied_resource_id = osr.supplied_resource_id
and osr.resource_type ='T'
and orb.required_date_from = (trunc(sysdate) + l_notify_days_before)
and orb.status= 'C'
and orb.event_id is not null;*/


begin
 hr_utility.set_location('Entering:'||l_proc, 5);
fnd_file.put_line(FND_FILE.LOG,'Event Fired ' ||p_event_fired);

 if p_event_fired ='CLASS_START' then
 --this code would be called when classbeginning notification has to be fired
 -- from API code on change of class dates
 if p_event_id is not null then

    for lrnr in get_all_wait_Learners(p_event_id)
    loop

        Initialize_wf(p_process 	=> 'OTA_ENROLL_STATUS_CHNG_JSP_PRC',
            p_item_type 	=> 'OTWF',
            p_person_id 	=> lrnr.delegate_person_id,
            p_eventid      => p_event_id,
            p_event_fired => p_event_fired);

    end loop;
 else

 for cls in get_all_class_info
 Loop
 fnd_file.put_line(FND_FILE.LOG,'Event Id ' ||cls.event_id);
    for lrnr in get_all_wait_Learners(cls.event_id)
    loop
fnd_file.put_line(FND_FILE.LOG,'Person Id ' ||lrnr.delegate_person_id);
        Initialize_wf(p_process 	=> 'OTA_ENROLL_STATUS_CHNG_JSP_PRC',
            p_item_type 	=> 'OTWF',
            p_person_id 	=> lrnr.delegate_person_id,
            p_eventid      => cls.event_id,
            p_event_fired => p_event_fired);

    end loop;

 end loop;
 end if; --for event_id
 elsif p_event_fired ='INSTRUCTOR_REMIND' then
 for trn in get_supp_res_id
 loop
   for cls in get_all_cls_info(trn.supplied_resource_id)
    Loop
 	fnd_file.put_line(FND_FILE.LOG,'Event Id ' ||cls.event_id);
        fnd_file.put_line(FND_FILE.LOG,'Supplied Resource Id ' ||trn.supplied_resource_id);
        OTA_INITIALIZATION_WF.initialize_instructor_wf(
            p_item_type 	=> 'OTWF',
            p_eventid 	=> cls.event_id,
            p_sup_res_id => trn.supplied_resource_id,
            p_event_fired => p_event_fired);

    end loop;
  end loop;
 end if;


  hr_utility.set_location('Leaving:'||l_proc, 5);
end Initialize_auto_wf;

Procedure Init_LP_wf(p_item_type 		in wf_items.item_type%type,
            p_lp_enrollment_id       in ota_lp_enrollments.lp_enrollment_id%type,
            p_event_fired in varchar2)
is

cursor get_lp_info
is
select lpt.name, lpe.person_id, lp.start_date_active
from ota_learning_paths lp , ota_learning_paths_tl lpt, ota_lp_enrollments lpe
where lpt.learning_path_id = lp.learning_path_id
and lpt.Language= USERENV('LANG')
and lp.Learning_path_id = lpe.Learning_path_id
and lpe.lp_enrollment_id = p_lp_enrollment_id;

l_person_id per_people_f.person_id%type;
l_LP_name ota_learning_paths_tl.name%type;
l_start_date ota_learning_paths.start_date_active%type;
l_process             	wf_activities.name%type := 'OTA_LP_JSP_PRC';
l_item_key     wf_items.item_key%type;



begin

open get_lp_info;
fetch get_lp_info into l_LP_name,l_person_id,l_start_date;
close get_lp_info;

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;
-- get item key for the process
WF_ENGINE.CREATEPROCESS(p_item_type, l_item_key, l_process);

-- set creator,current and supervisor name
set_wf_item_attr(p_person_id => l_person_id,
                            p_item_type => p_item_type,
                            p_item_key => l_item_key);

 WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_NTF_EVENT_FIRED', p_event_fired);


 --Enh 5606090: Language support for LP Details.
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_ACTIVITY_VERSION_NAME', p_lp_enrollment_id);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_COURSE_START_DATE', l_start_date);

WF_ENGINE.STARTPROCESS(p_item_type,l_item_key);

end init_LP_wf;





Procedure get_event_fired(itemtype     in varchar2,
  itemkey      in varchar2,
  actid        in number,
  funcmode      in varchar2,
  resultout       out nocopy varchar2)
is
l_value varchar2(100);

begin
  hr_utility.set_location('ENTERING get_event_fired', 10);
	IF (funcmode='RUN') THEN

    l_value := wf_engine.getItemAttrText(itemtype => itemtype
			 	  ,itemkey  => itemkey
                  , aname => 'OTA_NTF_EVENT_FIRED');
      hr_utility.trace ('l_value ' ||l_value);
            if l_value is not null then

                   resultout:='COMPLETE:' || l_value;

              else
                    resultout:='COMPLETE';
             end if;
          hr_utility.trace ('resultout ' ||resultout);
    RETURN;
    end if;
    IF (funcmode='CANCEL') THEN
		resultout:='COMPLETE';
		RETURN;
	END IF;

end get_event_fired;


procedure set_wf_item_attr(p_person_id in number,
                            p_item_type in wf_items.item_type%type,
                            p_item_key in wf_items.item_key%type)
is

l_proc 	varchar2(72) := g_package||'set_wf_item_attr';

l_creator_username varchar2(80):= fnd_profile.value('USERNAME');
l_creator_user_Id  number := fnd_profile.value('USER_ID');
l_creator_full_name  per_all_people_f.full_name%TYPE;

l_current_username varchar2(80);

l_current_user_Id  number ;
l_current_full_name  per_all_people_f.full_name%TYPE;

l_creator_person_id   per_all_people_f.person_id%type;

l_supervisor_id         per_all_people_f.person_id%Type;
l_supervisor_username   fnd_user.user_name%TYPE;
l_supervisor_full_name  per_all_people_f.full_name%TYPE;

l_role_name wf_roles.name%type;
l_role_display_name wf_roles.display_name%type;


-- get current person's user name
cursor curr_per_info
is
Select user_id ,user_name
from
fnd_user
where employee_id=p_person_id
AND trunc(sysdate) between start_date and nvl(end_date,to_date('4712/12/31', 'YYYY/MM/DD'));      --Bug 5676892

-- get creator person's person id
CURSOR C_USER IS
SELECT
 EMPLOYEE_ID
FROM
 FND_USER
WHERE
 user_id = l_creator_user_id ;

-- get full name
CURSOR csr_person_name (crs_person_id number) IS
    SELECT
	       pp.full_name
    FROM    per_people_f        pp
    WHERE   pp.person_id         = crs_person_id
    AND     trunc(sysdate) BETWEEN pp.effective_start_date AND pp.effective_end_date;
-- get supervisor name
CURSOR csr_supervisor_id IS
  SELECT asg.supervisor_id, per.full_name
    FROM per_all_assignments_f asg,
         per_all_people_f per
   WHERE asg.person_id = p_person_id
     AND per.person_id = asg.supervisor_id
     AND asg.primary_flag = 'Y'
     AND trunc(sysdate)
 BETWEEN asg.effective_start_date AND asg.effective_end_date
     AND trunc(sysdate)
 BETWEEN per.effective_start_date AND per.effective_end_date
  AND asg.assignment_type in ('E', 'A', 'C');  --Bug#8614003

-- get supervisor full name
 CURSOR csr_supervisor_user IS
 SELECT user_name
   FROM fnd_user
  WHERE employee_id= l_supervisor_id
  AND trunc(sysdate) between start_date and nvl(end_date,to_date('4712/12/31', 'YYYY/MM/DD'));      --Bug 5676892



begin
hr_utility.set_location('Entering:'||l_proc, 5);

OPEN curr_per_info;
FETCH curr_per_info INTO l_current_user_id, l_current_username;
CLOSE curr_per_info;

OPEN C_USER;
FETCH C_USER INTO l_creator_person_id;
CLOSE C_USER;




WF_ENGINE.setitemattrtext(p_item_type, p_item_key, 'CURRENT_PERSON_USERNAME', l_current_username);
WF_ENGINE.setitemattrtext(p_item_type, p_item_key, 'CREATOR_PERSON_USERNAME', l_creator_username);

hr_utility.trace ('Current username ' ||l_current_username);

open csr_person_name(l_creator_person_id);
fetch csr_person_name into l_creator_full_name;
close csr_person_name;

open csr_person_name(p_person_id);
fetch csr_person_name into l_current_full_name;
close csr_person_name;


WF_ENGINE.setitemattrtext(p_item_type,
                             		     p_item_key,
                                             'CURRENT_PERSON_DISPLAY_NAME',
                                             l_current_full_name);

 --for forum notification Login person can be contact
 if p_item_type = 'OTWF' and l_creator_full_name is not null then


 WF_ENGINE.setitemattrtext(p_item_type,
                             		     p_item_key,
                                             'LP_CREATOR_NAME',
                                             l_creator_full_name);

  elsif p_item_type <> 'OTWF' then

  WF_ENGINE.setitemattrtext(p_item_type,
                             		     p_item_key,
                                             'CREATOR_PERSON_DISPLAY_NAME',
                                             l_creator_full_name);
WF_ENGINE.setitemattrtext(p_item_type,
                             		     p_item_key,
                                             'APPROVAL_CREATOR_DISPLAY_NAME',
                                             l_creator_full_name);
   WF_ENGINE.setitemattrtext(p_item_type, p_item_key, 'CURRENT_PERSON_ID', p_person_id);
   WF_ENGINE.setitemattrtext(p_item_type, p_item_key, 'CREATOR_PERSON_ID', l_creator_person_id);

  end if;



  FOR a IN csr_supervisor_id LOOP
          l_supervisor_id := a.supervisor_id;
          l_supervisor_full_name := a.full_name;
      END LOOP;


     FOR b IN csr_supervisor_user LOOP
         l_supervisor_username := b.user_name;
     END LOOP;

 hr_utility.set_location('after supervisor cursor'||l_proc, 20);


wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'SUPERVISOR_USERNAME',
             l_supervisor_username);
hr_utility.set_location('after supervisor username'||l_supervisor_username, 20);
   if p_item_type <> 'OTWF' then
       wf_engine.setitemattrtext
            (p_item_type,
             p_item_key,
             'SUPERVISOR_DISPLAY_NAME',
             l_supervisor_full_name);

        wf_engine.setitemattrnumber
            (p_item_type,
             p_item_key,
             'SUPERVISOR_ID',
             l_supervisor_id);
   end if;

   hr_utility.set_location('Before Getting Owner'||l_proc, 10);

        WF_DIRECTORY.GetRoleName(p_orig_system =>'PER',
                      p_orig_system_id => p_person_id,
                      p_name  =>l_role_name,
                      p_display_name  =>l_role_display_name);


        WF_ENGINE.SetItemOwner(
                               itemtype => p_item_type,
                               itemkey =>p_item_key,
                               owner =>l_role_name);

hr_utility.trace ('after setowner ' ||l_role_display_name);

hr_utility.set_location('Leaving:'||l_proc, 5);

end set_wf_item_attr;

procedure init_assessment_wf(p_person_id in number,
p_attempt_id 	in varchar2)

is

l_proc 	varchar2(72) := g_package||'init_assessment_wf';

cursor get_test_info is
 select olb.name,oa.raw_score,oa.time
-- ,oa.event_id
        from ota_learning_objects olb, ota_attempts oa
        where olb.learning_object_id = oa.learning_object_id
     --   and oa.attempt_id = op.attempt_id
        and oa.attempt_id =p_attempt_id;


l_item_key     wf_items.item_key%type;
l_item_type wf_items.item_type%type := 'OTWF';
l_process             	wf_activities.name%type := 'OTA_ASSESSMENT_NTF_JSP_PRC';

l_title ota_learning_objects.name%type;
l_score varchar2(100);

l_time ota_events.course_start_time%type;
l_format_time varchar2(50);



begin
hr_utility.set_location('Entering:'||l_proc, 5);

open get_test_info;
fetch get_test_info into l_title,l_score,l_time;
--l_end_time,l_location_id;
close get_test_info;

if l_score = '-1000' then
l_score := null;
end if;

l_format_time := ota_utility.get_test_time(l_time);

hr_utility.trace ('title ' ||l_title);

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;
-- get item key for the process
WF_ENGINE.CREATEPROCESS(l_item_type, l_item_key, l_process);
hr_utility.trace ('item key ' ||l_item_key);
-- set creator,current and supervisor name
set_wf_item_attr(p_person_id => p_person_id,
                            p_item_type => l_item_type,
                            p_item_key => l_item_key);



 --WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_NTF_EVENT_FIRED', p_event_fired);


--Enh 5606090: Language support for Assessment Notification.
WF_ENGINE.setitemattrText(l_item_type, l_item_key, 'EVENT_TITLE', p_attempt_id);

WF_ENGINE.setitemattrText(l_item_type, l_item_key, 'LINE_NUMBER', l_score);
WF_ENGINE.setitemattrText(l_item_type, l_item_key, 'OTA_START_TIME', l_format_time);


WF_ENGINE.STARTPROCESS(l_item_type,l_item_key);


hr_utility.set_location('Leaving:'||l_proc, 5);

exception
when others then

raise;


end init_assessment_wf;

-- ----------------------------------------------------------------------------
-- |----------------------< initialize_cert_ntf_wf  >-------------------------|
-- ----------------------------------------------------------------------------

-- This wf would be used for OTA_CERTIFICATION_NTF_JSP_PRC
-- Called from alert

Procedure initialize_cert_ntf_wf(p_item_type in wf_items.item_type%type,
                                  p_person_id in number default null,
                                  p_certification_id in ota_certifications_b.certification_id%type,
				  p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
                                  p_cert_ntf_type in varchar2) is


cursor get_certification_info is
Select cet.name
      ,cet.end_date_comments
      ,ceb.end_date_active
From ota_certifications_b ceb
    ,ota_certifications_tl cet
Where
    ceb.certification_id = cet.certification_id
    and cet.language = userenv('LANG')
    and ceb.certification_id = p_certification_id;

l_certification_name ota_certifications_tl.name%type;
l_end_date_comments  ota_certifications_tl.end_date_comments%type;
l_end_date_active    ota_certifications_b.end_date_active%type;

l_process  wf_activities.name%type := 'OTA_CERTIFICATION_NTF_JSP_PRC';
l_item_key wf_items.item_key%type;

begin

open get_certification_info;
fetch get_certification_info into l_certification_name, l_end_date_comments, l_end_date_active;
close get_certification_info;

if ( l_end_date_comments is null ) then
	l_end_date_comments := '';
end if;

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;

-- get item key for the process
WF_ENGINE.CREATEPROCESS(p_item_type, l_item_key, l_process);

-- set creator,current and supervisor name
set_wf_item_attr(p_person_id => p_person_id,
		 p_item_type => p_item_type,
		 p_item_key  => l_item_key);

WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_NTF_EVENT_FIRED', p_cert_ntf_type);
--Enh 5606090: Language support for Certification Notification.
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_CERTIFICATION_NAME', p_certification_id);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_END_TIME', l_end_date_active);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_CERTIFICATION_ID', p_certification_id);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_CERT_PRD_ENROLLMENT_ID', p_cert_prd_enrollment_id);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'PERSON_ID', p_person_id);
WF_ENGINE.setitemattrText(p_item_type, l_item_key, 'OTA_NTF_COMMENTS', l_end_date_comments);

WF_ENGINE.STARTPROCESS(p_item_type, l_item_key);

end initialize_cert_ntf_wf;

--
Procedure process_cert_alert(
      ERRBUF OUT NOCOPY  VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2,
	  p_cert_ntf_type in varchar2) is

l_proc 	varchar2(72) := g_package || ' process_cert_alert';

l_certification_id   ota_certifications_b.certification_id%type;
l_cert_prd_enrollment_id  ota_cert_prd_enrollments.cert_prd_enrollment_id%type;
l_person_id ota_cert_enrollments.person_id%type;

l_item_type VARCHAR2(5) := 'OTWF';

--get all enrollment records in current period for reminder ntf
cursor get_data_for_reminder_ntf is
Select ceb.certification_id
       ,prd.cert_prd_enrollment_id
       ,enr.person_id
From ota_certifications_b ceb
    ,ota_cert_enrollments enr
    ,ota_cert_prd_enrollments prd
Where
    ceb.certification_id = enr.certification_id
    and enr.cert_enrollment_id = prd.cert_enrollment_id
    and trunc(sysdate) between nvl(trunc(ceb.start_date_active), trunc(sysdate)) and
        nvl(trunc(ceb.end_date_active), trunc(sysdate))
    and trunc(sysdate) between nvl(trunc(prd.cert_period_start_date), trunc(sysdate)) and
        nvl(trunc(prd.cert_period_end_date), trunc(sysdate))
    and prd.period_status_code not in('COMPLETED', 'CANCELLED')
    and enr.person_id is not null
    and ceb.notify_days_before_expire is not null
    and (trunc(sysdate) + ceb.notify_days_before_expire) = trunc(prd.cert_period_end_date);

--get all enrollment records in last period for expiration ntf
cursor get_data_for_expiration_ntf is
Select ceb.certification_id
       ,prd.cert_prd_enrollment_id
       ,enr.person_id
From ota_certifications_b ceb
    ,ota_cert_enrollments enr
    ,ota_cert_prd_enrollments prd
Where
    ceb.certification_id = enr.certification_id
    and enr.cert_enrollment_id = prd.cert_enrollment_id
    and trunc(sysdate) between nvl(trunc(ceb.start_date_active), trunc(sysdate)) and
        nvl(trunc(ceb.end_date_active), trunc(sysdate))
    and prd.period_status_code not in('COMPLETED', 'CANCELLED')
    and trunc(prd.cert_period_end_date) + 1 <= trunc(sysdate)
    and enr.person_id is not null;

--get all enrollment records in current period for completion ntf
cursor get_data_for_completion_ntf is
Select ceb.certification_id
       ,prd.cert_prd_enrollment_id
       ,enr.person_id
From ota_certifications_b ceb
    ,ota_cert_enrollments enr
    ,ota_cert_prd_enrollments prd
Where
    ceb.certification_id = enr.certification_id
    and enr.cert_enrollment_id = prd.cert_enrollment_id
    and trunc(sysdate) between nvl(trunc(ceb.start_date_active), trunc(sysdate)) and
        nvl(trunc(ceb.end_date_active), trunc(sysdate))
    and trunc(sysdate) between nvl(trunc(prd.cert_period_start_date), trunc(sysdate)) and
        nvl(trunc(prd.cert_period_end_date), trunc(sysdate))
    and prd.period_status_code = 'COMPLETED'
    and trunc(prd.completion_date) = trunc(sysdate)
    and enr.person_id is not null;

--get all enrollment records for renewal ntf
cursor get_data_for_renewal_ntf is
Select ceb.certification_id
       ,prd.cert_prd_enrollment_id
       ,enr.person_id
From ota_certifications_b ceb
    ,ota_cert_enrollments enr
    ,ota_cert_prd_enrollments prd
Where
    ceb.certification_id = enr.certification_id
    and enr.cert_enrollment_id = prd.cert_enrollment_id
    and trunc(sysdate) between nvl(trunc(ceb.start_date_active), trunc(sysdate)) and
        nvl(trunc(ceb.end_date_active), trunc(sysdate))
    and trunc(enr.earliest_enroll_date) = trunc(sysdate)
    and enr.person_id is not null;

--get all enrollment records for cancellation ntf
cursor get_data_for_cancellation_ntf is
Select ceb.certification_id
       ,enr.person_id
From ota_certifications_b ceb
    ,ota_cert_enrollments enr
Where
    ceb.certification_id = enr.certification_id
    and enr.person_id is not null
    and (trunc(sysdate) + nvl(ceb.notify_days_before_expire, 0)) = trunc(ceb.end_date_active);

begin
 hr_utility.set_location('Entering:'||l_proc, 5);

 if p_cert_ntf_type = 'Completion'  OR p_cert_ntf_type = 'All' THEN
	for prd_enr_rem in get_data_for_reminder_ntf
	Loop
		initialize_cert_ntf_wf(p_item_type 	         => l_item_type,
					p_person_id 	         => prd_enr_rem.person_id,
					p_certification_id       => prd_enr_rem.certification_id,
					p_cert_prd_enrollment_id => prd_enr_rem.cert_prd_enrollment_id,
					p_cert_ntf_type          => 'CERT_REMINDER');
	End Loop;
 end if;

 /* Might need to call API to set Certification Enrollment Status to EXPIRED before sending the notification */
 if p_cert_ntf_type ='Expiry'  OR p_cert_ntf_type = 'All' THEN
	for prd_enr_exp in get_data_for_expiration_ntf
	Loop
		initialize_cert_ntf_wf(p_item_type 	         => l_item_type,
					p_person_id 	         => prd_enr_exp.person_id,
					p_certification_id       => prd_enr_exp.certification_id,
					p_cert_prd_enrollment_id => prd_enr_exp.cert_prd_enrollment_id,
					p_cert_ntf_type          => 'CERT_EXPIRATION');
	End Loop;
  end if;

 /*  Needs to be moved to API call
 if p_cert_ntf_type ='' OR p_cert_ntf_type = 'ALL' THEN
	for prd_enr_cmp in get_data_for_completion_ntf
	Loop
		initialize_cert_ntf_wf(p_item_type 	         => l_item_type,
					p_person_id 	         => prd_enr_cmp.person_id,
					p_certification_id       => prd_enr_cmp.certification_id,
					p_cert_prd_enrollment_id => prd_enr_cmp.cert_prd_enrollment_id,
					p_cert_ntf_type          => 'CERT_COMPLETION');
	End Loop;
  end if;
 */

 if  p_cert_ntf_type ='Renewal' OR p_cert_ntf_type = 'All' THEN
	for prd_enr_rnw in get_data_for_renewal_ntf
	Loop
		initialize_cert_ntf_wf(p_item_type 	         => l_item_type,
					p_person_id 	         => prd_enr_rnw.person_id,
					p_certification_id       => prd_enr_rnw.certification_id,
					p_cert_prd_enrollment_id => prd_enr_rnw.cert_prd_enrollment_id,
					p_cert_ntf_type          => 'CERT_RENEWAL');
	End Loop;
  end if;

 if  p_cert_ntf_type ='Cancellation' OR p_cert_ntf_type = 'All' THEN
	for prd_enr_can in get_data_for_cancellation_ntf
	Loop
		initialize_cert_ntf_wf(p_item_type 	         => l_item_type,
					p_person_id 	         => prd_enr_can.person_id,
					p_certification_id       => prd_enr_can.certification_id,
					p_cert_prd_enrollment_id => null,
					p_cert_ntf_type          => 'CERT_CANCELLATION' );
	End Loop;
 end if;
 hr_utility.set_location('Leaving:'||l_proc, 5);
    EXCEPTION
	  when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc
		||','||SUBSTR(SQLERRM, 1, 500));
end process_cert_alert;
--
Procedure init_forum_notif(p_Forum_id in ota_forum_messages.forum_id%type,
                           p_Forum_message_id in ota_forum_messages.forum_message_id%type)
is

l_proc 	varchar2(72) := g_package||'init_forum_notif';

l_item_key     wf_items.item_key%type;
l_item_type 		 wf_items.item_type%type := 'OTWF';
l_process             	wf_activities.name%type := 'OTA_FORUM_NTF_JSP_PRC';

cursor get_message_details
is
select oft.name,fth.subject,ofm.person_id,ofm.contact_id,
ofm.creation_date,ofm.message_body
from ota_forum_messages ofm ,ota_forum_threads fth ,ota_forums_tl oft
where oft.forum_id = ofm.forum_id
and ofm.forum_thread_id = fth.forum_thread_id
and ofm.forum_message_id = p_Forum_message_id
and oft.language= USERENV('LANG');

cursor get_frm_subscriber
is
select person_id
from ota_frm_notif_subscribers
where forum_id = p_forum_id
and person_id is not null;


l_forum_name ota_forums_tl.name%type;
l_subject ota_forum_threads.subject%type;
l_person_id ota_forum_messages.person_id%type;
l_contact_id ota_forum_messages.contact_id%type;
l_creation_date varchar2(50);
l_message_body ota_forum_messages.message_body%type;
l_author_name varchar2(300);




begin
hr_utility.set_location('Entering:'||l_proc, 5);

open get_message_details;
fetch get_message_details into l_forum_name,l_subject, l_person_id,l_contact_id,
l_creation_date, l_message_body;
close get_message_details;

-- get author name from person_id or contact_id
l_author_name := ota_utility.get_learner_name(p_person_id => l_person_id,
                          p_customer_id => null,
                          p_contact_id => l_contact_id);

for rec in get_frm_subscriber

Loop

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;
-- get item key for the process
WF_ENGINE.CREATEPROCESS(l_item_type, l_item_key, l_process);

-- set creator,current and supervisor name
set_wf_item_attr(p_person_id => rec.person_id,
                            p_item_type => l_item_type,
                            p_item_key => l_item_key);
 --Enh 5606090: Language support for Forum Notification.
wf_engine.setitemattrtext(l_item_type,l_item_key, 'COURSE_NAME' ,p_Forum_message_id);
wf_engine.setitemattrtext(l_item_type,l_item_key, 'EVENT_TITLE' ,l_subject);
wf_engine.setitemattrtext(l_item_type,l_item_key, 'SECTION_NAME' ,l_message_body);

wf_engine.setitemattrtext(l_item_type,l_item_key, 'LP_CREATOR_NAME' ,l_author_name);
wf_engine.setitemattrtext(l_item_type,l_item_key, 'SECTION_NAME' ,l_message_body);

WF_ENGINE.STARTPROCESS(l_item_type,l_item_key);

end loop;

hr_utility.set_location('Leaving:'||l_proc, 10);

end init_forum_notif;




Procedure send_event_beginning_ntf(
     ERRBUF OUT NOCOPY  VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2) IS

l_proc 		varchar2(72) := g_package||' send_event_beginning_ntf';
BEGIN
     ota_initialization_wf.Initialize_auto_wf(
            p_process   => 'OTA_ENROLL_STATUS_CHNG_JSP_PRC'
	   ,p_item_type => 'OTWF'
	   ,p_event_fired => 'CLASS_START');
   EXCEPTION
	  when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc
		||','||SUBSTR(SQLERRM, 1, 500));
END send_event_beginning_ntf;


Procedure send_instructor_reminder_ntf(
      ERRBUF OUT NOCOPY  VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2) IS

l_proc 		varchar2(72) := g_package||' send_instructor_reminder_ntf';
BEGIN
     ota_initialization_wf.Initialize_auto_wf(
            p_process   => 'OTA_INSTRUCTOR_NTF_JSP_PRC'
	   ,p_item_type => 'OTWF'
	   ,p_event_fired => 'INSTRUCTOR_REMIND');
   EXCEPTION
	  when others then
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured in ' || l_proc
		||','||SUBSTR(SQLERRM, 1, 500));
END send_instructor_reminder_ntf;

procedure init_course_eval_notif(p_booking_id OTA_DELEGATE_BOOKINGS.booking_id%type) is

l_proc 	varchar2(72) := g_package||'init_course_eval_notif';

l_item_key   wf_items.item_key%type;
l_item_type  wf_items.item_type%type := 'OTWF';
l_process    wf_activities.name%type := 'OTA_COURSE_EVAL_PRC';

l_person_id ota_forum_messages.person_id%type;
l_contact_id ota_forum_messages.contact_id%type;
l_event_id ota_events.event_id%type;
l_status_type ota_booking_status_types.type%type;

cursor csr_booking_status is
SELECT bst.Type, tdb.delegate_person_id, tdb.contact_id, tdb.event_id
FROM   OTA_DELEGATE_BOOKINGS tdb,
       OTA_BOOKING_STATUS_TYPES bst
WHERE  tdb.booking_id = p_booking_id
AND    bst.booking_status_type_id = tdb.booking_status_type_id;

begin
hr_utility.set_location('Entering:'||l_proc, 5);

open csr_booking_status;
fetch csr_booking_status into l_status_type,l_person_id, l_contact_id,l_event_id;
close csr_booking_status;

select hr_workflow_item_key_s.nextval into l_item_key from sys.dual;

WF_ENGINE.CREATEPROCESS(l_item_type, l_item_key, l_process);
set_wf_item_attr(p_person_id => l_person_id, p_item_type => l_item_type, p_item_key => l_item_key);
wf_engine.setitemattrtext(l_item_type,l_item_key, 'EVENT_ID' ,l_event_id);
wf_engine.setitemattrtext(l_item_type,l_item_key, 'STATUS' ,l_status_type);
WF_ENGINE.STARTPROCESS(l_item_type,l_item_key);

hr_utility.set_location('Leaving:'||l_proc, 10);

end init_course_eval_notif;

procedure get_course_eval_status ( itemtype	IN WF_ITEMS.ITEM_TYPE%TYPE,
					                         itemkey	IN WF_ITEMS.ITEM_KEY%TYPE,
					                         actid		IN NUMBER,
					                         funcmode	IN VARCHAR2,
					                         resultout	OUT nocopy VARCHAR2 ) is

l_status_type ota_booking_status_types.type%type;
begin
  if(funcmode = 'RUN') then
      l_status_type   := wf_engine.getItemAttrtext(itemtype => itemtype ,itemkey  => itemkey ,aname  => 'STATUS');

      If (l_status_type is not null and upper(l_status_type) = 'E') then
        resultout := 'COMPLETE:PENDING_EVAL';
      else
        resultout := 'COMPLETE:ATTENDED_EVAL';
     end if;
  else
    if(funcmode='CANCEL') then
		  resultout := 'COMPLETE';
    end if;
  end if;

end get_course_eval_status;

procedure get_course_eval_del_mode ( itemtype	IN WF_ITEMS.ITEM_TYPE%TYPE,
					                         itemkey	IN WF_ITEMS.ITEM_KEY%TYPE,
					                         actid		IN NUMBER,
					                         funcmode	IN VARCHAR2,
					                         resultout	OUT nocopy VARCHAR2 ) is

l_event_id varchar2(80);
l_synchronous_flag   ota_category_usages.synchronous_flag%type;
l_online_flag   ota_category_usages.online_flag%type;

CURSOR delivery_mode(p_event_id	varchar2) IS
Select OCU.synchronous_flag, OCU.online_flag
From ota_events OEV,
     ota_offerings OFR,
     ota_category_usages OCU
Where OFR.offering_id = OEV.parent_offering_id
  And OCU.category_usage_id = OFR.delivery_mode_id
  And OEV.event_id = p_event_id;

begin
  if(funcmode = 'RUN') then
      l_event_id   := wf_engine.getItemAttrtext(itemtype => itemtype ,itemkey  => itemkey ,aname  => 'EVENT_ID');

      OPEN  delivery_mode(l_event_id);
      FETCH delivery_mode INTO l_synchronous_flag, l_online_flag;
      CLOSE delivery_mode;

      if upper(l_online_flag) = 'Y' then
        resultout := 'COMPLETE:ONLINE';
      else
        resultout := 'COMPLETE:OFFLINE';
      end if;
  else
    if(funcmode='CANCEL') then
        resultout := 'COMPLETE';
    end if;
  end if;

end get_course_eval_del_mode;

procedure get_class_name(document_id in varchar2,
                         display_type in varchar2,
                         document in out nocopy varchar2,
                         document_type in out nocopy varchar2) is
  CURSOR csr_get_class_name IS
  SELECT title FROM ota_events_tl
  WHERE to_char(event_id) = document_id AND language = USERENV('LANG');

  l_class_name varchar2(80);
begin
   OPEN csr_get_class_name;
   FETCH csr_get_class_name INTO l_class_name;
   CLOSE csr_get_class_name;

   document := l_class_name;

end get_class_name;

procedure RAISE_BUSINESS_EVENT(
            	p_eventid       in ota_Events.event_id%type,
            	p_event_fired in varchar2,
                p_type in varchar2 default null
)
is
l_proc 	varchar2(72) := g_package||'RAISE_BUSINESS_EVENT';

l_item_key     wf_items.item_key%type;

l_title ota_events_tl.title%type;
l_start_date varchar2(100);
l_end_date varchar2(100);
l_start_time ota_events.course_start_time%type;
l_end_time ota_events.course_start_time%type;
l_location_id ota_events.location_id %type;
l_training_center_id ota_events.training_center_id %type;
l_event_type ota_events.event_type%type;

l_location_name hr_locations_all_tl.location_code%type;
l_training_center hr_all_organization_units.name%TYPE;
l_enrollment_status_name ota_booking_status_types_tl.name%TYPE;

l_booking_id ota_delegate_bookings.booking_id%type;
l_person_id number(15);

l_event_data clob;
l_text varchar2(2000);


cursor get_event_info
is
select oev.title,oev.course_start_date,oev.course_end_date,
oev.course_start_time, oev.course_end_time,
oev.location_id,oev.training_center_id
from ota_events_tl evt, ota_events oev
where evt.event_id =oev.event_id
and oev.event_id = p_eventid
and evt.language=USERENV('LANG');

-- get all the person's enrolled into the event
cursor get_booking_info
is
select odb.booking_id , odb.delegate_person_id, odb.delegate_contact_id
from ota_delegate_bookings odb, ota_booking_status_types bst
where odb.event_id =p_eventid
and odb.booking_status_type_id = bst.booking_status_type_id
and bst.type in ('P','W','R');


begin

open get_event_info;
fetch get_event_info into l_title,l_start_date,l_end_date,l_start_time,
l_end_time,l_location_id,l_training_center_id;
close get_event_info;

if (p_event_fired = 'oracle.apps.ota.api.event_api.update_location' or
    p_event_fired = 'oracle.apps.ota.api.event_api.update_training_center' or
    p_event_fired = 'oracle.apps.ota.api.event_api.update_trng_cntr_and_location')then



for rec in get_booking_info
Loop

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;

-- get location
l_location_name := ota_general.get_Location_code(l_location_id);

-- get Traininig center
l_training_center := ota_general.get_training_center(l_training_center_id);


-- raise the event with the event data
-- start BE

    -- build the xml data for the event
    --
    dbms_lob.createTemporary(l_event_data,false,dbms_lob.call);
    l_text:='<?xml version =''1.0'' encoding =''ASCII''?>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<class_change>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<delegate_person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(rec.delegate_person_id);
    l_text:=l_text||'</delegate_person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<delegate_contact_id>';
    l_text:=l_text||fnd_number.number_to_canonical(rec.delegate_contact_id);
    l_text:=l_text||'</delegate_contact_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<booking_id>';
    l_text:=l_text||fnd_number.number_to_canonical(rec.booking_id);
    l_text:=l_text||'</booking_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<location_id>';
    l_text:=l_text||fnd_number.number_to_canonical(l_location_id);
    l_text:=l_text||'</location_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<location_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(l_location_name);
    l_text:=l_text||'</location_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<training_center_id>';
    l_text:=l_text||fnd_number.number_to_canonical(l_training_center_id);
    l_text:=l_text||'</training_center_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<training_center_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(l_training_center);
    l_text:=l_text||'</training_center_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<event_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_eventid);
    l_text:=l_text||'</event_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<ota_ntf_event_fired>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_event_fired);
    l_text:=l_text||'</ota_ntf_event_fired>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<target_date>';
    l_text:=l_text||fnd_date.date_to_canonical(l_start_date);
    l_text:=l_text||'</target_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<completion_date>';
    l_text:=l_text||fnd_date.date_to_canonical(l_end_date);
    l_text:=l_text||'</completion_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<ota_start_time>';
    l_text:=l_text||irc_utilities_pkg.removeTags(nvl(l_start_time,'00:00'));
    l_text:=l_text||'</ota_start_time>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<ota_end_time>';
    l_text:=l_text||irc_utilities_pkg.removeTags(nvl(l_end_time,'23:59'));
    l_text:=l_text||'</ota_end_time>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='</class_change>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);


   wf_event.raise(p_event_name=>p_event_fired
                  ,p_event_key=>l_item_key
                  ,p_event_data=>l_event_data);

-- end BE


end loop;

elsif p_event_fired = 'oracle.apps.ota.api.event_api.update_class_schedule' then

for rec in get_booking_info
Loop

-- Get the next item key from the sequence
  select hr_workflow_item_key_s.nextval
  into   l_item_key
  from   sys.dual;

    -- get location
    l_location_name := ota_general.get_Location_code(l_location_id);

    -- build the xml data for the event
    --
    dbms_lob.createTemporary(l_event_data,false,dbms_lob.call);
    l_text:='<?xml version =''1.0'' encoding =''ASCII''?>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<class_change>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<delegate_person_id>';
    l_text:=l_text||fnd_number.number_to_canonical(rec.delegate_person_id);
    l_text:=l_text||'</delegate_person_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<delegate_contact_id>';
    l_text:=l_text||fnd_number.number_to_canonical(rec.delegate_contact_id);
    l_text:=l_text||'</delegate_contact_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<booking_id>';
    l_text:=l_text||fnd_number.number_to_canonical(rec.booking_id);
    l_text:=l_text||'</booking_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<location_id>';
    l_text:=l_text||fnd_number.number_to_canonical(l_location_id);
    l_text:=l_text||'</location_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<location_name>';
    l_text:=l_text||irc_utilities_pkg.removeTags(l_location_name);
    l_text:=l_text||'</location_name>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<event_id>';
    l_text:=l_text||fnd_number.number_to_canonical(p_eventid);
    l_text:=l_text||'</event_id>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

     l_text:='<title>';
    l_text:=l_text||irc_utilities_pkg.removeTags(l_title);
    l_text:=l_text||'</title>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<ota_ntf_event_fired>';
    l_text:=l_text||irc_utilities_pkg.removeTags(p_event_fired);
    l_text:=l_text||'</ota_ntf_event_fired>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    if p_type is not null then
	    l_text:='<event_sub_type>';
      l_text:=l_text||irc_utilities_pkg.removeTags(p_type);
		  l_text:=l_text||'</event_sub_type>';
	    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);
     end if;

    l_text:='<target_date>';
    l_text:=l_text||fnd_date.date_to_canonical(l_start_date);
    l_text:=l_text||'</target_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<completion_date>';
    l_text:=l_text||fnd_date.date_to_canonical(l_end_date);
    l_text:=l_text||'</completion_date>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<ota_start_time>';
    l_text:=l_text||irc_utilities_pkg.removeTags(nvl(l_start_time,'00:00'));
    l_text:=l_text||'</ota_start_time>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='<ota_end_time>';
    l_text:=l_text||irc_utilities_pkg.removeTags(nvl(l_end_time,'23:59'));
    l_text:=l_text||'</ota_end_time>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);

    l_text:='</class_change>';
    dbms_lob.writeAppend(l_event_data,length(l_text),l_text);


   wf_event.raise(p_event_name=>p_event_fired
                  ,p_event_key=>l_item_key
                  ,p_event_data=>l_event_data);

end loop;

end if;

end RAISE_BUSINESS_EVENT;

end ota_initialization_wf;

/
