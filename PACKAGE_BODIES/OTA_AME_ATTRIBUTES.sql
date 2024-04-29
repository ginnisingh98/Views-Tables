--------------------------------------------------------
--  DDL for Package Body OTA_AME_ATTRIBUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_AME_ATTRIBUTES" AS
/* $Header: otamewkf.pkb 120.1.12010000.2 2009/07/07 06:06:58 pekasi ship $ */

--
-- Package Variables
--
g_package  varchar2(33) := 'ota_ame_attributes.';
--

-------------------------------------------------------------------------------
---------   function get_item_type  --------------------------------------------

----------  private function to get item type for current transaction ---------
-------------------------------------------------------------------------------
function get_item_type
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
c_item_type    varchar2(50);

begin

SELECT DISTINCT ITEM_TYPE
INTO c_item_type
FROM HR_API_TRANSACTION_STEPS
WHERE TRANSACTION_ID=p_transaction_id;

return nvl(c_item_type, '-1');
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_item_key',p_transaction_id);
    RAISE;

end get_item_type;

-------------------------------------------------------------------------------
---------   function get_item_key  --------------------------------------------
----------  private function to get item key for current transaction ---------
-------------------------------------------------------------------------------
function get_item_key
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
c_item_key     varchar2(100);

begin

SELECT DISTINCT ITEM_KEY
INTO c_item_key
FROM HR_API_TRANSACTION_STEPS
WHERE TRANSACTION_ID=p_transaction_id;

return nvl(c_item_key, '-1');
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_item_key',p_transaction_id);
    RAISE;
end get_item_key;



-- ------------------------------------------------------------------------
-- |------------------------< get_class_standard_price >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the class standard price
--

function get_class_standard_price
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
c_class_standard_price ota_events.standard_price%type;
c_event_id     ota_events.event_id%type;
c_item_type    varchar2(50);
c_item_key     varchar2(100);

cursor c_get_standard_price is
select standard_price
from   ota_events
where event_id = c_event_id;

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_event_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                               aname => 'OTA_EVENT_ID'
					       , ignore_notfound => TRUE);

IF c_event_id is null then

c_class_standard_price := null;

else

open  c_get_standard_price;
fetch c_get_standard_price into c_class_standard_price;
close c_get_standard_price;
end if;
return c_class_standard_price;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_class_standard_price',c_item_type,c_item_key);
    RAISE;


end get_class_standard_price;

-- ------------------------------------------------------------------------
-- |------------------------< get_Learning_path_name >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the learning path name
--
function get_Learning_path_name
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_lp_name   ota_learning_paths_tl.name%type;
c_event_id      ota_events.event_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

l_lp_name ota_learning_paths_tl.name%type;

/*cursor c_get_lp_name is
 select olpt.name
from ota_events oev,ota_training_plans otp, ota_training_plan_members otpm,
ota_learning_paths_tl olpt
where oev.activity_version_id = otpm.activity_version_id
and otpm.member_status_type_id='OTA_COMPLETED'
and otpm.training_plan_id=otp.training_plan_id
and otp.plan_status_type_id='OTA_COMPLETED'
and otp.learning_path_id= olpt.learning_path_id
and olpt.Language=USERENV('LANG')
and oev.event_id=c_event_id;*/

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

/*c_event_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_EVENT_ID'
					       , ignore_notfound => TRUE);
 */
 l_lp_name := wf_engine.getitemattrText(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_ACTIVITY_VERSION_NAME'
					       , ignore_notfound => TRUE);
c_lp_name :=  l_lp_name;
/*
IF c_event_id is null then
	c_lp_name := null;
else
	for rec in c_get_lp_name
    Loop
        if rec.name = l_lp_name then
            c_lp_name := rec.name;
        exit;
        end if;

    end loop;
end if;*/
return c_lp_name;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_Learning_path_name',c_item_type,c_item_key);
    RAISE;
end get_Learning_path_name;

-- ------------------------------------------------------------------------
-- |------------------------< get_course_primary_category >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the course primary category
--
function get_course_primary_category
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_course_category ota_category_usages_tl.category%type;
c_event_id      ota_events.event_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor c_get_course_category is
 Select ocu.Category
 From ota_act_cat_inclusions oaci,
      ota_category_usages_vl ocu,
      ota_events oev,
      ota_offerings ofr
 Where oev.event_id = c_event_id
       AND oev.parent_offering_id = ofr.offering_id
       AND ofr.activity_version_id = oaci.activity_version_id
       AND ocu.category_usage_id = oaci.category_usage_id
       AND oaci.primary_flag = 'Y'
       AND ocu.type = 'C'
       AND (TRUNC(sysdate) BETWEEN NVL(TRUNC(oaci.start_date_active), TRUNC(sysdate)) AND nvl(TRUNC(oaci.end_date_active), TRUNC(sysdate)))
       AND (TRUNC(sysdate) BETWEEN NVL(TRUNC(ocu.start_date_active), TRUNC(sysdate)) AND nvl(TRUNC(ocu.end_date_active), TRUNC(sysdate)));

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_event_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_EVENT_ID'
					       , ignore_notfound => TRUE);

IF c_event_id is null then

c_course_category := null;

else
open  c_get_course_category;
fetch c_get_course_category into c_course_category;
close c_get_course_category;
end if;
return c_course_category;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_course_primary_category',c_item_type,c_item_key);
    RAISE;

end get_course_primary_category;

-- ------------------------------------------------------------------------
-- |------------------------< get_enrollment_status >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the enrollment status
--
function get_enrollment_status
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_enrollment_status ota_booking_status_types.name%type;
c_booking_id      ota_delegate_bookings.booking_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor c_get_enrollment_status is
select
       bst.name
from
       ota_delegate_bookings tdb,
       ota_booking_status_types_tl bst
where  tdb.booking_id = c_booking_id and
       bst.language=userenv('LANG') and
       tdb.booking_status_type_id = bst.booking_status_type_id;

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_booking_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                               aname => 'BOOKING_ID'
					       , ignore_notfound => TRUE);

IF c_booking_id is null then

c_enrollment_status := null;

else
open  c_get_enrollment_status;
fetch c_get_enrollment_status into c_enrollment_status;
close c_get_enrollment_status;
end if;
return c_enrollment_status;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_enrollment_status',c_item_type,c_item_key);
    RAISE;

end get_enrollment_status;

-- ------------------------------------------------------------------------
-- |------------------------< get_ofr_delivery_mode >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the delivery mode for the offering
--
function get_ofr_delivery_mode
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_delivery_mode ota_category_usages_tl.category%type;
c_event_id      ota_events.event_id%type;
c_offering_id   ota_offerings.offering_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor c_get_ofr_dm is
 Select ocu.Category
 From ota_offerings ofr,
      ota_category_usages_vl ocu
 Where ofr.offering_id = c_offering_id
       AND ofr.delivery_mode_id = ocu.category_usage_id
       AND ocu.type = 'DM'
       AND (TRUNC(sysdate) BETWEEN NVL(TRUNC(ocu.start_date_active), TRUNC(sysdate))
       AND nvl(TRUNC(ocu.end_date_active), TRUNC(sysdate)));

cursor c_get_ofr_id is
 Select parent_offering_id
 From ota_events
 Where event_id = c_event_id;
begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_event_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_EVENT_ID'
					       , ignore_notfound => TRUE);

IF c_event_id is null then

c_delivery_mode := null;

else
open  c_get_ofr_id;
fetch c_get_ofr_id into c_offering_id;
close c_get_ofr_id;

open  c_get_ofr_dm;
fetch c_get_ofr_dm into c_delivery_mode;
close c_get_ofr_dm;
end if;
return c_delivery_mode;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_ofr_delivery_mode',c_item_type,c_item_key);
    RAISE;

end get_ofr_delivery_mode;

-- ------------------------------------------------------------------------
-- |------------------------< get_course_name >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the course name
--
function get_course_name
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_course_name   ota_activity_versions_tl.version_name%type;
c_event_id      ota_events.event_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor c_get_course_name is
 Select oav.version_name
 From ota_events oev,
      ota_activity_versions_tl oav
 Where oev.activity_version_id = oav.activity_version_id
       And oav.language = USERENV ('LANG')
       And oev.event_id = c_event_id;
begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_event_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_EVENT_ID'
					       , ignore_notfound => TRUE);

IF c_event_id is null then
	c_course_name := null;
else
	open  c_get_course_name;
	fetch c_get_course_name into c_course_name;
	close c_get_course_name;
end if;
return c_course_name;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_course_name',c_item_type,c_item_key);
    RAISE;

end get_course_name;

-- ------------------------------------------------------------------------
-- |------------------------< get_offering_name >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the offering name
--
function get_offering_name
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_offering_name ota_offerings_tl.name%type;
c_event_id      ota_events.event_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor c_get_offering_name is
 Select ofr.name
 From ota_events oev,
      ota_offerings_tl ofr
 Where oev.parent_offering_id = ofr.offering_id
       And ofr.language = USERENV ('LANG')
       And oev.event_id = c_event_id;
begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_event_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_EVENT_ID'
					       , ignore_notfound => TRUE);

IF c_event_id is null then
	c_offering_name := null;
else
	open  c_get_offering_name;
	fetch c_get_offering_name into c_offering_name;
	close c_get_offering_name;
end if;
return c_offering_name;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_offering_name',c_item_type,c_item_key);
    RAISE;

end get_offering_name;

-- ------------------------------------------------------------------------
-- |------------------------< get_class_name >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the class name
--
function get_class_name
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_class_name    ota_events_tl.title%type;
c_event_id      ota_events.event_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor c_get_class_name is
 Select oev.title
 From ota_events_tl oev
 Where oev.language = USERENV ('LANG')
       And oev.event_id = c_event_id;
begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_event_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_EVENT_ID'
					       , ignore_notfound => TRUE);

IF c_event_id is null then
	c_class_name := null;
else
	open  c_get_class_name;
	fetch c_get_class_name into c_class_name;
	close c_get_class_name;
end if;
return c_class_name;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_class_name',c_item_type,c_item_key);
    RAISE;

end get_class_name;

-- ------------------------------------------------------------------------
-- |------------------------< get_class_location >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the class location
--
function get_class_location
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_class_location hr_locations_all.location_code%type;
c_event_id      ota_events.event_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor c_get_class_location is
 Select ota_general.get_location_code(ota_utility.get_event_location(oev.event_id)) Location_Name
 From ota_events oev
 Where oev.event_id = c_event_id;

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_event_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_EVENT_ID'
					       , ignore_notfound => TRUE);

IF c_event_id is null then
	c_class_location := null;
else
	open  c_get_class_location;
	fetch c_get_class_location into c_class_location;
	close c_get_class_location;
end if;
return c_class_location;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_class_location',c_item_type,c_item_key);
    RAISE;

end get_class_location;

-- ------------------------------------------------------------------------
-- |------------------------< get_certification_name >----------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the certification name

function get_certification_name
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_certification_name    ota_certifications_tl.name%type;
--c_certification_id      ota_events.event_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);


begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_certification_name := wf_engine.GetItemAttrText(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_ACTIVITY_VERSION_NAME'
					       , ignore_notfound => TRUE);


return c_certification_name;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_certification_name',c_item_type,c_item_key);
    RAISE;

end get_certification_name;


-- ------------------------------------------------------------------------
-- |------------------------< get_certification_type >----------------|
-- ------------------------------------------------------------------------
--

function get_certification_type
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_certification_type    varchar2(100);
c_certification_id      ota_certifications_b.certification_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor get_certification_type
is
select renewable_flag from ota_certifications_b
where certification_id = c_certification_id;


begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_certification_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_CERTIFICATION_ID'
					       , ignore_notfound => TRUE);

if c_certification_id is not null then

open get_certification_type;
fetch get_certification_type into c_certification_type;
close get_certification_type;

end if;


return c_certification_type;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_certification_type',c_item_type,c_item_key);
    RAISE;

end get_certification_type;


-- ------------------------------------------------------------------------
-- |------------------------< get_init_cert_dur >----------------|
-- ------------------------------------------------------------------------

--
function get_init_cert_dur
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_cert_dur   varchar2(100);
c_certification_id      ota_certifications_b.certification_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor get_cert_dur
is
select initial_completion_duration from ota_certifications_b
where certification_id = c_certification_id;


begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_certification_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_CERTIFICATION_ID'
					       , ignore_notfound => TRUE);

if c_certification_id is not null then

open get_cert_dur;
fetch get_cert_dur into c_cert_dur;
close get_cert_dur;

end if;


return c_cert_dur;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_init_cert_dur',c_item_type,c_item_key);
    RAISE;

end get_init_cert_dur;


-- ------------------------------------------------------------------------
-- |------------------------< get_renewal_duration >----------------|
-- ------------------------------------------------------------------------

--
function get_renewal_duration
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_cert_dur   varchar2(100);
c_certification_id      ota_certifications_b.certification_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor get_cert_renewal_duration
is
select renewal_duration from ota_certifications_b
where certification_id = c_certification_id;


begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_certification_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_CERTIFICATION_ID'
					       , ignore_notfound => TRUE);

if c_certification_id is not null then

open get_cert_renewal_duration;
fetch get_cert_renewal_duration into c_cert_dur;
close get_cert_renewal_duration;

end if;


return c_cert_dur;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_renewal_duration',c_item_type,c_item_key);
    RAISE;

end get_renewal_duration;

-- ------------------------------------------------------------------------
-- |------------------------< get_validity_duration >----------------|
-- ------------------------------------------------------------------------

--
function get_validity_duration
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_cert_dur   varchar2(100);
c_certification_id      ota_certifications_b.certification_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor get_cert_validity_duration
is
select validity_duration from ota_certifications_b
where certification_id = c_certification_id;


begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_certification_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_CERTIFICATION_ID'
					       , ignore_notfound => TRUE);

if c_certification_id is not null then

open get_cert_validity_duration;
fetch get_cert_validity_duration into c_cert_dur;
close get_cert_validity_duration;

--ame_util
--versionDateToString

end if;


return c_cert_dur;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_validity_duration',c_item_type,c_item_key);
    RAISE;

end get_validity_duration;


-- ------------------------------------------------------------------------
-- |------------------------< get_cert_period_start_date >----------------|
-- ------------------------------------------------------------------------

--
function get_cert_period_start_date
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_cert_date   Date;
l_return_value varchar2(100);
c_certification_id      ota_certifications_b.certification_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);
c_person_id number(15);

cursor get_cert_period_date
is
select cpe.cert_period_start_date
from ota_cert_prd_enrollments cpe , ota_cert_enrollments ce
where
ce.cert_enrollment_id = cpe.cert_enrollment_id
and ce.certification_id = c_certification_id
and ce.person_id = c_person_id
and cpe.period_status_code = 'CANCELLED'
and rownum =1
order by cert_period_start_date desc;


begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_certification_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_CERTIFICATION_ID'
					       , ignore_notfound => TRUE);

c_person_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'CURRENT_PERSON_ID'
					       , ignore_notfound => TRUE);

if c_certification_id is not null and c_person_id is not null then

open get_cert_period_date;
fetch get_cert_period_date into c_cert_date;
close get_cert_period_date;

if c_Cert_date is not null then

l_return_value := ame_util.versiondateToString(c_cert_date);
end if;
end if;


return l_return_value;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_cert_period_start_date',c_item_type,c_item_key);
    RAISE;

end get_cert_period_start_date;

-- ------------------------------------------------------------------------
-- |------------------------< get_cert_period_end_date >----------------|
-- ------------------------------------------------------------------------

--
function get_cert_period_end_date
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_cert_date   Date;
l_return_value varchar2(100);
c_certification_id      ota_certifications_b.certification_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);
c_person_id number(15);

cursor get_cert_period_date
is
select cpe.cert_period_end_date
from ota_cert_prd_enrollments cpe , ota_cert_enrollments ce
where
ce.cert_enrollment_id = cpe.cert_enrollment_id
and ce.certification_id = c_certification_id
and ce.person_id = c_person_id
and cpe.period_status_code = 'CANCELLED'
and rownum =1
order by cert_period_start_date desc;


begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_certification_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_CERTIFICATION_ID'
					       , ignore_notfound => TRUE);

c_person_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'CURRENT_PERSON_ID'
					       , ignore_notfound => TRUE);

if c_certification_id is not null and c_person_id is not null then

open get_cert_period_date;
fetch get_cert_period_date into c_cert_date;
close get_cert_period_date;

if c_Cert_date is not null then

l_return_value := ame_util.versiondateToString(c_cert_date);
end if;
end if;


return l_return_value;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_cert_period_end_date',c_item_type,c_item_key);
    RAISE;

end get_cert_period_end_date;

-- ------------------------------------------------------------------------
-- |------------------------< get_init_cert_comp_date >----------------|
-- ------------------------------------------------------------------------

--
function get_init_cert_comp_date
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_cert_date   Date;
l_return_value varchar2(100);
c_certification_id      ota_certifications_b.certification_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);
c_person_id number(15);

cursor get_cert_comp_date
is
select INITIAL_COMPLETION_DATE
from ota_certifications_b
where
certification_id = c_certification_id;



begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_certification_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                                aname => 'OTA_CERTIFICATION_ID'
					       , ignore_notfound => TRUE);



if c_certification_id is not null and c_person_id is not null then

open get_cert_comp_date;
fetch get_cert_comp_date into c_cert_date;
close get_cert_comp_date;

if c_Cert_date is not null then

l_return_value := ame_util.versiondateToString(c_cert_date);
end if;
end if;


return l_return_value;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_init_cert_comp_date',c_item_type,c_item_key);
    RAISE;

end get_init_cert_comp_date;

END ota_ame_attributes;

/
