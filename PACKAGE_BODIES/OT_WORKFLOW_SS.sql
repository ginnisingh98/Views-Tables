--------------------------------------------------------
--  DDL for Package Body OT_WORKFLOW_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OT_WORKFLOW_SS" AS
/* $Header: otwkflss.pkb 120.0.12010000.2 2009/07/07 06:11:52 pekasi ship $ */
/*
   This package contails new (v4.0+)workflow related business logic
*/
--
-- Package Variables
--
g_package  varchar2(33) := 'ot_workflow_ss.';
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
-- |------------------------< Get_event_standard_price >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the event standard price
--

function get_event_standard_price
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
c_event_standard_price ota_events.standard_price%type;
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
                                               aname => 'OTA_EVENT_ID',
                                               ignore_notfound => TRUE);
if c_event_id is null then
    c_event_standard_price := null;
else
    open  c_get_standard_price;
    fetch c_get_standard_price into c_event_standard_price;
    close c_get_standard_price;
end if;

return c_event_standard_price;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_event_standard_price',c_item_type,c_item_key);
    RAISE;


end get_event_standard_price;


-- ------------------------------------------------------------------------
-- |------------------------< Get_activity_type >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the activity type
--
function get_activity_type
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
         return varchar2 is

c_activity_name ota_activity_definitions.name%type;
c_event_id      ota_events.event_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor c_get_activity_name is
select oad.name
from   ota_events evt,
       ota_activity_versions oav,
       ota_activity_definitions_tl oad
where  evt.event_id = c_event_id and
       oad.language=userenv('LANG') and
       evt.activity_version_id = oav.activity_version_id and
       oav.activity_id = oad.activity_id;


begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_event_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                               aname => 'OTA_EVENT_ID',
						ignore_notfound => TRUE);
if c_event_id is null then
     c_activity_name :=  null;
else
     open  c_get_activity_name;
     fetch c_get_activity_name into c_activity_name;
     close c_get_activity_name;
end if;

return c_activity_name;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_activity_type',c_item_type,c_item_key);
    RAISE;

end get_activity_type;
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_act_pm_category >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the activity category
--
function get_act_pm_category
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_activity_category ota_act_cat_inclusions.activity_category%type;
c_event_id      ota_events.event_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor c_get_activity_category is
select
        hl.meaning
from
       ota_events evt,
       ota_act_cat_inclusions oac,
       ota_category_usages ocu,
       hr_lookups hl
where  evt.event_id = c_event_id and
       evt.activity_version_id = oac.activity_version_id and
       oac.category_usage_id = ocu.category_usage_id and
       ocu.type = 'C' and
       oac.primary_flag = 'Y' and
       hl.lookup_type = 'ACTIVITY_CATEGORY' and
       oac.activity_category = hl.lookup_code;

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_event_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                               aname => 'OTA_EVENT_ID',
					       ignore_notfound => TRUE);

if c_event_id is null then
     c_activity_category := null;
else
     open  c_get_activity_category;
     fetch c_get_activity_category into c_activity_category;
     close c_get_activity_category;
end if;

return c_activity_category;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_act_pm_category',c_item_type,c_item_key);
    RAISE;

end get_act_pm_category;
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_act_pm_delivery_method >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the activity primary delivery method
--
function get_act_pm_delivery_method
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_delivery_method ota_act_cat_inclusions.activity_category%type;
c_event_id      ota_events.event_id%type;
c_item_type     varchar2(50);
c_item_key      varchar2(100);

cursor c_get_activity_dm is
select
        hl.meaning
from
       ota_events evt,
       ota_act_cat_inclusions oac,
       ota_category_usages ocu,
       hr_lookups hl
where  evt.event_id = c_event_id and
       evt.activity_version_id = oac.activity_version_id and
       oac.category_usage_id = ocu.category_usage_id and
       ocu.type = 'DM' and
       oac.primary_flag = 'Y' and
       hl.lookup_type = 'ACTIVITY_CATEGORY' and
       oac.activity_category = hl.lookup_code;


begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

c_event_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                               aname => 'OTA_EVENT_ID',
					       ignore_notfound => TRUE);

if c_event_id is null then
      c_delivery_method := null;
else
      open  c_get_activity_dm;
      fetch c_get_activity_dm into c_delivery_method;
      close c_get_activity_dm;
end if;

return c_delivery_method;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'get_act_pm_delivery_method',c_item_type,c_item_key);
    RAISE;

end get_act_pm_delivery_method;
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_enrollment_status >-------------------------|
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
                                               aname => 'BOOKING_ID',
					       ignore_notfound => TRUE);

if c_booking_id is null then
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
--


END ot_workflow_ss;

/
