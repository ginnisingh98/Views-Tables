--------------------------------------------------------
--  DDL for Package Body WF_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ITEM" as
/* $Header: wfengb.pls 120.25.12010000.17 2014/09/09 00:17:09 alsosa ship $ */

c_itemtype varchar2(8);
c_itemkey varchar2(240);

c_ondemand boolean;

c_root_activity varchar2(30);
c_root_activity_version pls_integer;
c_begin_date date;
c_userkey varchar2(240);

--
-- ClearCache
--   Clear runtime cache
--
procedure ClearCache
is
begin
  wf_item.c_itemtype := '';
  wf_item.c_itemkey := '';
  wf_item.c_root_activity := '';
  wf_item.c_root_activity_version := '';
  wf_item.c_begin_date := to_date(NULL);
  wf_item.c_userkey := '';

  --clear ondemand flag
  wf_item.c_ondemand := null;
  -- Clear the synch attribute cache too
  wf_engine.synch_attr_count := 0;

exception
  when others then
    Wf_Core.Context('Wf_Item', 'ClearCache');
    raise;
end ClearCache;

--
-- InitCache (PRIVATE)
--   Initialize package cache
-- IN
--   itemtype - Item type
--   itemkey - Item key
--
procedure InitCache(
  itemtype in varchar2,
  itemkey in varchar2,
  ignore_notfound in boolean default FALSE)

is
  rootid number;
  status varchar2(8);
  onDemandFlag wf_activity_attributes.text_default%type;
begin
  -- Check for refresh
  if ((itemtype = wf_item.c_itemtype) and
      (itemkey = wf_item.c_itemkey)) then
    return;
  end if;

  -- SYNCHMODE: If
  --   1. Asking for an item other than the cached one AND
  --   2. The cached item is a synch process AND
  --   3. The cached item has not yet completed
  -- then raise an error.  Other items cannot be accessed until synch
  -- item completes, because it can't be restarted from db
  if (wf_item.c_itemkey = wf_engine.eng_synch) then
    -- Get status of root process of cached item
    -- Note: If process completed successfully, the last thing in the
    -- WIAS runtime cache should be the root process, which is the
    -- only reason this will work.
    begin
      rootid := Wf_Process_Activity.RootInstanceId(c_itemtype, c_itemkey,
                                                  c_root_activity);
      Wf_Item_Activity_Status.Status(c_itemtype, c_itemkey, rootid, status);
    exception
      when others then
        status := 'x';  -- Treat errors like incomplete process
    end;
    if (nvl(status, 'x') <> wf_engine.eng_completed) then
      Wf_Core.Token('ITEMTYPE', itemtype);
      Wf_Core.Token('ITEMKEY', itemkey);
      Wf_Core.Raise('WFENG_SYNCH_ITEM');
    end if;
  end if;

  -- Query new values
  select WI.ROOT_ACTIVITY, WI.ROOT_ACTIVITY_VERSION, WI.BEGIN_DATE,
         WI.USER_KEY
  into wf_item.c_root_activity, wf_item.c_root_activity_version,
       wf_item.c_begin_date, wf_item.c_userkey
  from WF_ITEMS WI
  where WI.ITEM_TYPE = InitCache.itemtype
  and WI.ITEM_KEY = InitCache.itemkey;

  -- Save cache key values
  wf_item.c_itemtype := itemtype;
  wf_item.c_itemkey := itemkey;

  --cache ondemand flag
  -- this could potentially have some impact on the performance as this
  -- routine is called many times while we are dealing with design time data.
  -- ondemand is true if the name process #ONDEMANDATTR attribute exist,
  -- otherwise, it is false.
  --
  begin
    select text_default into onDemandFlag from wf_activity_attributes
      where activity_item_type = c_itemtype
      and   activity_name = c_root_activity
      and   activity_version=c_root_activity_version
      and   name = '#ONDEMANDATTR';

    wf_item.c_ondemand := true;
  exception
    when no_data_found then
      wf_item.c_ondemand := false;
  end;



exception
 when NO_DATA_FOUND then
  if (ignore_notfound) then
     WF_ITEM.ClearCache;

  else

    Wf_Core.Context('Wf_Item', 'InitCache', itemtype, itemkey);
    raise;

  end if;

  when others then
    Wf_Core.Context('Wf_Item', 'InitCache', itemtype, itemkey);
    raise;
end InitCache;

--
-- Attribute_On_Demand
--   Set parent ids of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
-- Initialize cache if not already done then return c_ondemand;
--

function Attribute_On_Demand(
  itemtype in varchar2,
  itemkey in varchar2
) return boolean
as
begin
  --
  --we need to call in case itemtype and itemkey are not in synch with
  --cached value.
  --
  Wf_Item.InitCache(itemtype, itemkey, ignore_notfound=>TRUE);
  return c_ondemand;
end Attribute_On_Demand;

--
-- Set_Item_Parent
--   Set parent ids of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   parent_itemtype - Itemtype of parent
--   parent_itemkey - Itemkey of parent
--   parent_context - Context info about parent
--
procedure Set_Item_Parent(itemtype in varchar2,
                          itemkey in varchar2,
                          parent_itemtype in varchar2,
                          parent_itemkey in varchar2,
                          parent_context in varchar2,
                          masterdetail   in boolean)
is
    ValTooLarge EXCEPTION;
    pragma exception_init(ValTooLarge, -01401);
    ValTooLargeNew EXCEPTION;
    pragma exception_init(ValTooLargeNew, -12899);
    connect_by_loop exception;
    pragma exception_init(connect_by_loop, -01436);
    l_count number;
begin
  begin
    savepoint wf_loop_savepoint;
	update WF_ITEMS set
      PARENT_ITEM_TYPE = Set_Item_Parent.parent_itemtype,
      PARENT_ITEM_KEY = Set_Item_Parent.parent_itemkey,
      PARENT_CONTEXT = Set_Item_Parent.parent_context
    where ITEM_TYPE = Set_Item_Parent.itemtype
    and ITEM_KEY = Set_Item_Parent.itemkey;

    if (sql%notfound) then
      raise no_data_found;
    end if;

    -- bug 12850046: preventing a loop condition from being created
    select count(1) into l_count
    from WF_ITEMS
    CONNECT BY PRIOR PARENT_ITEM_TYPE = ITEM_TYPE AND
    PRIOR PARENT_ITEM_KEY = ITEM_KEY
    start with ITEM_TYPE=Set_Item_Parent.itemtype AND
          ITEM_KEY=Set_Item_Parent.itemkey;
  exception
    when connect_by_loop then
      rollback to wf_loop_savepoint;
	  Wf_Core.Context('Wf_Item', 'Set_Item_Parent', itemtype, itemkey,
                       parent_itemtype, parent_itemkey, parent_context);
      Wf_Core.Token('PARENT_ITEM_TYPE', parent_itemtype);
      Wf_Core.Token('PARENT_ITEM_KEY', parent_itemkey);
      Wf_Core.Token('ITEM_TYPE', itemtype);
      Wf_Core.Token('ITEM_KEY', itemkey);
      Wf_Core.Raise('WFENG_ITEM_LOOP');
  end;
  if (masterdetail) then
    --Increment #WAITFORDETAIL master counter if it exists.
    if (WF_ENGINE.AddToItemAttrNumber(parent_itemType, parent_itemKey,
                                      '#WAITFORDETAIL', 1) is NOT NULL) then
      if (parent_context is NOT null) then
        --Increment/Create label counter.
        if (length(parent_context) > 30) then
          WF_CORE.Token('LABEL', parent_context);
          WF_CORE.Token('LENGTH', '30');
          WF_CORE.Raise('WFENG_LABEL_TOO_LARGE');

        elsif (WF_ENGINE.AddToItemAttrNumber(parent_itemType, parent_itemKey,
                                             '#CNT_'||parent_context, 1)
                                              is NULL) then
          WF_ENGINE.AddItemAttr(itemType=>parent_itemType,
                                itemKey=>parent_itemKey,
                                aname=>'#CNT_'||parent_context,
                                number_value=>1);
        end if; --Label Counter exists

        WF_ENGINE.AddItemAttr(itemType=>itemType, itemKey=>itemKey,
                              aname=>'#LBL_'||parent_context,
                              text_value=>parent_context);

      else
        -- Parent context is null
        -- increase all known #CNT counter by 1
        update WF_ITEM_ATTRIBUTE_VALUES
           set NUMBER_VALUE = NUMBER_VALUE + 1
         where NAME like '#CNT_%'
           and NUMBER_VALUE is not null
           and ITEM_TYPE = parent_itemType
           and ITEM_KEY = parent_itemKey;

      end if; --Parent context is not null
    end if; --#WAITFORDETAIL exists
  end if; --Caller is signalling that this "should" be a coordinated flow.

exception
  when no_data_found then
    Wf_Core.Context('Wf_Item', 'Set_Item_Parent', itemtype, itemkey,
                     parent_itemtype, parent_itemkey, parent_context);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');

  when ValTooLarge or ValTooLargeNew then
    Wf_Core.Context('Wf_Item', 'Set_Item_Parent', itemtype, itemkey,
                     parent_itemtype, parent_itemkey, parent_context, 'TRUE');
    WF_CORE.Token('LABEL', parent_context);
    WF_CORE.Token('LENGTH', 30);
    WF_CORE.Raise('WFENG_LABEL_TOO_LARGE');

  when others then
    Wf_Core.Context('Wf_Item', 'Set_Item_Parent', itemtype, itemkey,
                     parent_itemtype, parent_itemkey, parent_context);
    raise;
end Set_Item_Parent;

--
-- SetItemOwner
--   Set the owner of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   owner - Role designated as owner of the item
--
procedure SetItemOwner(
  itemtype in varchar2,
  itemkey in varchar2,
  owner in varchar2)
is
begin

  -- Update owner column
  update WF_ITEMS WI set
    OWNER_ROLE = SetItemOwner.owner
  where WI.ITEM_TYPE = SetItemOwner.itemtype
  and WI.ITEM_KEY = SetItemOwner.itemkey;

  if (sql%notfound) then
    raise no_data_found;
  end if;
exception
  when no_data_found then
    Wf_Core.Context('Wf_Item', 'SetItemOwner', itemtype, itemkey,
                    owner);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');
  when others then
    Wf_Core.Context('Wf_Item', 'SetItemOwner', itemtype, itemkey,
                    owner);
    raise;
end SetItemOwner;

--
-- SetItemUserKey
--   Set the user key of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   userkey - User key to be set
--
procedure SetItemUserKey(
  itemtype in varchar2,
  itemkey in varchar2,
  userkey in varchar2)
is
begin
  update WF_ITEMS WI set
    USER_KEY = SetItemUserKey.userkey
  where WI.ITEM_TYPE = SetItemUserKey.itemtype
  and WI.ITEM_KEY = SetItemUserKey.itemkey;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  -- Set value in the local cache the right item
  if ((itemtype = wf_item.c_itemtype) and
      (itemkey = wf_item.c_itemkey)) then
    wf_item.c_userkey := userkey;
  end if;
exception
  when no_data_found then
    Wf_Core.Context('Wf_Item', 'SetItemUserKey', itemtype, itemkey,
                    userkey);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');
  when others then
    Wf_Core.Context('Wf_Item', 'SetItemUserKey', itemtype, itemkey,
                    userkey);
    raise;
end SetItemUserKey;

--
-- GetItemUserKey
--   Get the user key of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
-- RETURNS
--   User key of the item
--
function GetItemUserKey(
  itemtype in varchar2,
  itemkey in varchar2)
return varchar2
is
  buf varchar2(240);
begin
  -- Check first for cached value
  if ((itemtype = wf_item.c_itemtype) and
      (itemkey = wf_item.c_itemkey)) then
    return(wf_item.c_userkey);
  end if;

  -- No cached value, go directly to the source
  select USER_KEY
  into buf
  from WF_ITEMS WI
  where WI.ITEM_TYPE = GetItemUserKey.itemtype
  and WI.ITEM_KEY = GetItemUserKey.itemkey;

  return(buf);
exception
  when no_data_found then
    Wf_Core.Context('Wf_Item', 'GetItemUserKey', itemtype, itemkey);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');
  when others then
    Wf_Core.Context('Wf_Item', 'GetItemUserKey', itemtype, itemkey);
    raise;
end GetItemUserKey;

--
-- Item_Exist (PRIVATE)
--   Returns TRUE if this is an existing item. Otherwise return FALSE.
-- IN
--   itemtype - item type
--   itemkey - item key
--
function Item_Exist(itemtype in varchar2,
                    itemkey  in varchar2)
return boolean
is
begin

  Wf_Item.InitCache(itemtype, itemkey, ignore_notfound=>TRUE);

  if (wf_item.c_itemtype is not null) then

     return(TRUE);

  else

     return(FALSE);

  end if;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Item', 'Item_Exist', itemtype, itemkey);
    raise;
end Item_Exist;

--
-- Root_Process (PRIVATE)
--   If the item exists, wflow out variable will contain the root process
--   name for this item key. Otherwise the wflow out variable will be null.
-- IN
--   itemtype - item type
--   itemkey - item key
-- OUT
--   wflow - root process
--   version - root process version
--
procedure Root_Process(itemtype in varchar2,
                       itemkey   in varchar2,
                       wflow out NOCOPY varchar2,
                       version out NOCOPY number)
is
begin

  Wf_Item.InitCache(itemtype, itemkey);
  wflow := wf_item.c_root_activity;
  version := wf_item.c_root_activity_version;

exception
  when NO_DATA_FOUND then
    wflow := '';
    version := -1;
  when OTHERS then
    Wf_Core.Context('Wf_Item', 'Root_Process', itemtype, itemkey);
    raise;
end Root_Process;

--
-- Create_Item (PRIVATE)
--   Create one row in the WF_ITEMS table with the given item type, item key
--   and the root process name.
-- IN
--   itemtype - item type
--   itemkey  - item key
--   wflow    - root process name for this item key.
--   actdate  - active date of item
--
procedure Create_Item(
  itemtype in varchar2,
  itemkey  in varchar2,
  wflow    in varchar2,
  actdate  in date,
  user_key in varchar2,
  owner_role in varchar2)
is

  rootversion number;
  rootid number;

  onDemandFlag wf_activity_attributes.text_default%type;
  --<rwunderl:2412940>
  status  PLS_INTEGER;
  wiaIND  NUMBER;
  wiavIND NUMBER;

  cursor attrcurs(itype in varchar2) is
    select WIA.ITEM_TYPE, WIA.NAME, WIA.TYPE, WIA.SUBTYPE, WIA.FORMAT,
           WIA.TEXT_DEFAULT, WIA.NUMBER_DEFAULT, WIA.DATE_DEFAULT
    from   WF_ITEM_ATTRIBUTES WIA
    where  WIA.ITEM_TYPE = itype;

begin

  rootversion := Wf_Activity.Version(itemtype, wflow, actdate);

  if (itemkey <> wf_engine.eng_synch) then
    -- NORMAL: Insert new item and attributes directly in the db
    insert into WF_ITEMS (
      ITEM_TYPE,
      ITEM_KEY,
      ROOT_ACTIVITY,
      ROOT_ACTIVITY_VERSION,
      OWNER_ROLE,
      PARENT_ITEM_TYPE,
      PARENT_ITEM_KEY,
      BEGIN_DATE,
      END_DATE,
      USER_KEY
    ) values (
      itemtype,
      itemkey,
      wflow,
      rootversion,
      Create_Item.owner_role,
      '',
      '',
      actdate,
      to_date(NULL),
      Create_item.user_key
    );
  end if;

  -- Initialize runtime cache (used in both NORMAL and SYNCHMODE).
  wf_item.c_itemtype := itemtype;
  wf_item.c_itemkey := itemkey;
  wf_item.c_root_activity := wflow;
  wf_item.c_root_activity_version := rootversion;
  wf_item.c_begin_date := actdate;
  wf_item.c_userkey := Create_item.user_key;

  --
  --ondemand flag
  --
  begin
    select text_default into onDemandFlag from wf_activity_attributes
      where activity_item_type = c_itemtype
      and   activity_name = c_root_activity
      and   activity_version=c_root_activity_version
      and   name = '#ONDEMANDATTR';
    wf_item.c_ondemand := true;
  exception
    when no_data_found then
    wf_item.c_ondemand := false;
  end;

  -- Initialize item attributes
  if (itemkey <> wf_engine.eng_synch) then
    -- NORMAL: store attributes in table
   if(not wf_item.c_ondemand) then
      -- only popluate when the flag is false
    insert into WF_ITEM_ATTRIBUTE_VALUES (
      ITEM_TYPE,
      ITEM_KEY,
      NAME,
      TEXT_VALUE,
      NUMBER_VALUE,
      DATE_VALUE
    ) select
      itemtype,
      itemkey,
      WIA.NAME,
      WIA.TEXT_DEFAULT,
      WIA.NUMBER_DEFAULT,
      WIA.DATE_DEFAULT
    from WF_ITEM_ATTRIBUTES WIA
    where WIA.ITEM_TYPE = itemtype;
    end if;
  else
    -- SYNCHMODE: store attributes in plsql only
    for curs in attrcurs(itemtype) loop
      --Getting the index for the item attribute.
      WF_CACHE.GetItemAttribute(itemtype, curs.name, status, wiaIND);

      --Getting the index for the item attribute value
      WF_CACHE.GetItemAttrValue(itemtype, itemkey, curs.name, status, wiavIND);

      --Loading the item attribute into cache for synch mode.
      WF_CACHE.ItemAttributes(wiaIND).ITEM_TYPE      := itemType;
      WF_CACHE.ItemAttributes(wiaIND).NAME           := curs.name;
      WF_CACHE.ItemAttributes(wiaIND).TYPE           := curs.type;
      WF_CACHE.ItemAttributes(wiaIND).SUBTYPE        := curs.subtype;
      WF_CACHE.ItemAttributes(wiaIND).FORMAT         := curs.format;
      WF_CACHE.ItemAttributes(wiaIND).TEXT_DEFAULT   := curs.text_default;
      WF_CACHE.ItemAttributes(wiaIND).NUMBER_DEFAULT := curs.number_default;
      WF_CACHE.ItemAttributes(wiaIND).DATE_DEFAULT   := curs.date_default;

      --Loading the item attribute value into cache for use by synch processes
      --only until we introduce the item locking feature.
      WF_CACHE.ItemAttrValues(wiavIND).ITEM_TYPE    := itemType;
      WF_CACHE.ItemAttrValues(wiavIND).ITEM_KEY     := itemKey;
      WF_CACHE.ItemAttrValues(wiavIND).NAME         := curs.name;
      WF_CACHE.ItemAttrValues(wiavIND).TEXT_VALUE   := curs.text_default;
      WF_CACHE.ItemAttrValues(wiavIND).NUMBER_VALUE := curs.number_default;
      WF_CACHE.ItemAttrValues(wiavIND).DATE_VALUE   := curs.date_default;

    end loop;
  end if;

exception
  when DUP_VAL_ON_INDEX then
    Wf_Core.Context('Wf_Item', 'Create_Item', itemtype, itemkey, wflow);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM_UNIQUE');
  when OTHERS then
    Wf_Core.Context('Wf_Item', 'Create_Item', itemtype, itemkey, wflow);
    raise;
end Create_Item;

--
-- Active_Date (PRIVATE)
--   Return the begin date of an item
-- IN
--   itemtype
--   itemkey
-- RETURN
--   Begin date of item
--
function Active_Date(itemtype in varchar2,
                     itemkey in varchar2)
return date
is
begin
  Wf_Item.InitCache(itemtype, itemkey);
  return(wf_item.c_begin_date);
exception
  when NO_DATA_FOUND then
    Wf_Core.Context('Wf_Item', 'Active_Date', itemtype, itemkey);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');
  when OTHERS then
    Wf_Core.Context('Wf_Item', 'Active_Date', itemtype, itemkey);
end Active_Date;

--Function Acquire_lock (PRIVATE)
--This function tries to lock the particular item (for the give
--itemtype/itemkey ) in the wf_items table. It returns true if the lock
--acquired else returns false.

--Here we will not do any error handling but return true/false
--for the case of lock_acquired or not . This leaves the caller
--the decision of what to do when a resource busy error occurs
--(ie FALSE) . For eg : Background engine will ignore it and move
--on , WF Engine will raise exception etc.

function acquire_lock(itemtype in varchar2,
                     itemkey in varchar2,
                     raise_exception in boolean)
return boolean
is
  --Bug 2607770
  --Cursor for acquiring lock
  cursor itemlock (itemtype varchar2, itemkey varchar2) is
  select '1'
  from   wf_items
  where  item_type = itemtype
  and    item_key  = itemkey
  for update nowait;

  --Define an exception to capture the resource_busy error
  resource_busy exception;
  pragma EXCEPTION_INIT(resource_busy,-00054);

begin
  --Acquire lock here by opening the cursor
  OPEN  itemlock (itemtype,itemkey);
  --Close the cursor once the lock has been acquired
  CLOSE itemlock;
  return TRUE;
exception
  --Capture the exception on resource-busy error
  when resource_busy then
    --Lets double check that the cursor is not open
    if (itemlock%ISOPEN) then
      CLOSE itemlock;
    end if;
    --check the if_raise flag . If its true then raise
    --the exception
    --else return false and let the caller decide what to do.
    if  raise_exception then
      raise;
      --If not able to acquire lock return FALSE
    else
      return FALSE;
    end if;
  when others then
    --Lets double check that the cursor is not open
    if (itemlock%ISOPEN) then
      CLOSE itemlock;
    end if;
    --In this case we do not want a TRUE/FALSE return
    --we just raise the error.
    Wf_Core.Context('Wf_Item', 'Acquire_lock', itemtype, itemkey);
    raise;
end;

--
-- SetEndDate (Private)
--   Sets end_date and completes any coordinated counter processing.
-- IN
--   p_itemtype - process item type
--   p_itemkey - process item key
-- RETURNS
--  number
-- NOTE:
--   This function will return a status of one of the following:
--     0 - Item was found, active, and the end_date was set.
--     1 - The item was not found. (ERROR)
function SetEndDate(p_itemtype in varchar2,
                    p_itemkey in varchar2) return number
  is
    l_parent_itemType VARCHAR2(8);
    l_parent_itemKey  VARCHAR2(240);
    l_parent_context  VARCHAR2(2000);

    TYPE nameTAB is TABLE of VARCHAR2(30) index by binary_integer;
    attrNames nameTAB;

    l_result NUMBER;
    i        NUMBER;
    --Bug 14784055. Need to validate the activity LABEL is not too large
    ValTooLarge EXCEPTION;
    pragma exception_init(ValTooLarge, -01401);
    ValTooLargeNew EXCEPTION;
    pragma exception_init(ValTooLargeNew, -12899);
    l_module varchar2(20) := 'SetEndDate';
    l_context_label varchar2(40);
    l_is_detail varchar2(10);
  begin
    UPDATE    wf_items
    SET       end_date = sysdate
    WHERE     item_type = p_itemType
    AND       item_key = p_itemKey
    AND       end_date is NULL
    RETURNING parent_item_type, parent_item_key, parent_context
    INTO      l_parent_itemtype, l_parent_itemkey, l_parent_context;

    if (sql%notfound) then
      return 1;
    end if;

    --We need to perform some counter processing if they exist.
    if ((l_parent_itemType is NOT null) and
        (l_parent_itemKey is NOT null)) then
      --No counter Processing to be done for error process

      if l_parent_itemType=Wf_Engine.GetItemAttrText(p_itemtype, p_itemkey,
                 'ERROR_ITEM_TYPE',TRUE) and l_parent_itemkey=
                Wf_Engine.GetItemAttrText(p_itemtype, p_itemkey,
                 'ERROR_ITEM_KEY',TRUE) then
        return 0;
      end if;

      --Bug 19322157. Also, do not do counter processing if this child workflow
      --does not participate in a MASTER/DETAIL relationship
      l_is_detail := Wf_Engine.GetItemAttrText(p_itemtype, p_itemkey, '#DETAIL_PROCESS',TRUE);
      if l_is_detail is null or l_is_detail <> 'NO' then
        if (WF_ENGINE.AddToItemAttrNumber(l_parent_itemType, l_parent_itemKey,
                                          '#WAITFORDETAIL', -1) is NOT null) then
          if ((l_parent_context is NOT null) and
            (WF_ENGINE.GetItemAttrText(p_itemType, p_itemKey,
                            '#LBL_'||l_parent_context, TRUE) is NOT NULL)) then
            l_context_label := '#LBL_'||l_parent_context;
            if (WF_ENGINE.SetItemAttrText2(p_itemType, p_itemKey,
                                           l_context_label, NULL)) then
              l_context_label := '#CNT_'||l_parent_context;
              l_result := WF_ENGINE.AddToItemAttrNumber(l_parent_itemType,
                                                      l_parent_itemKey,
                                                      l_context_label,
                                                      -1);
            end if;
          else
            SELECT TEXT_VALUE
            bulk collect into attrNames
            FROM WF_ITEM_ATTRIBUTE_VALUES
            WHERE ITEM_TYPE = p_itemType
            AND   ITEM_KEY = p_itemKey
            AND   NAME like ('#LBL_%')
            AND   TEXT_VALUE is NOT null;

            if (attrNames.COUNT > 0) then
              for i in attrNames.FIRST..attrNames.LAST loop
                l_context_label := '#LBL_'||attrNames(i);
                if (WF_ENGINE.SetItemAttrText2(p_itemType, p_itemKey,
                                               l_context_label, NULL)) then
                  l_context_label := '#CNT_'||attrNames(i);
                  l_result := WF_ENGINE.AddToItemAttrNumber(l_parent_itemtype,
                                                            l_parent_itemkey,
                                                            l_context_label,
                                                            -1);
                end if; --#LBL_ exists as expected.
              end loop;
            end if; --There are non-null #LBL_ attributes.
            --<rwunderl:4271715> We need to decrement any #CNT_ attributes
            --in the parent which the child may not have created the corresponding
            --#LBL_ (did not arrive) such as in the case of an AbortProcess()
            SELECT wiav.NAME
            bulk collect into attrNames
            FROM WF_ITEM_ATTRIBUTE_VALUES wiav
            WHERE wiav.ITEM_TYPE = l_parent_itemType
            AND   wiav.ITEM_KEY = l_parent_itemKey
            and   wiav.NAME like ('#CNT_%')
            AND NOT EXISTS (select null
                            from   wf_item_attribute_values wiav2
                            where  wiav2.item_type = p_itemType
                            and    wiav2.item_key = p_itemKey
                            and    wiav2.name = REPLACE(wiav.name,'#CNT_','#LBL_'));
             if (attrNames.COUNT > 0) then
              for i in attrNames.FIRST..attrNames.LAST loop
                l_result := WF_ENGINE.AddToItemAttrNumber(l_parent_itemtype,
                                                          l_parent_itemkey,
                                                          attrNames(i), -1);
              end loop;
            end if; --There were unvisited ContinueFlow() activites in the child.
          end if; --Parent Context
        end if; --We were able to decrement the #WAITFORDETAIL
      end if; --Bug 19322157
    end if; --This item has a parent.
    return 0;
  exception
    when ValTooLarge OR ValTooLargeNew then
      Wf_Core.Context('WF_ENGINE', l_module, p_itemtype, p_itemkey,
                      l_parent_itemType, l_parent_itemKey);
      WF_CORE.Token('LABEL', l_context_label);
      WF_CORE.Token('LENGTH', 30);
      WF_CORE.Raise('WFENG_LABEL_TOO_LARGE');
    when OTHERS then
      WF_CORE.Context('WF_ITEM', 'SetEndDate', p_itemType, p_itemKey);
      raise;

  end SetEndDate;

end WF_ITEM;

/
