--------------------------------------------------------
--  DDL for Package Body WF_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ENGINE" as
/* $Header: wfengb.pls 120.25.12010000.17 2014/09/09 00:17:09 alsosa ship $ */

type InstanceArrayTyp is table of pls_integer
index by binary_integer;

type RowidArrayTyp is table of rowid
index by binary_integer;

--
-- Exception
--
no_savepoint exception;
bad_format   exception; --<rwunderl:2307104/>

pragma EXCEPTION_INIT(no_savepoint, -1086);
pragma EXCEPTION_INIT(bad_format, -6502); --<rwunderl:2307104/>

-- Bug 2607770
resource_busy exception;
pragma exception_init(resource_busy, -00054);

-- private variable
schema varchar2(30);

-- Bug 3824367
-- Optimizing the code using a single cursor with binds
cursor curs_activityattr (c_actid NUMBER, c_aname VARCHAR2) is
select WAAV.PROCESS_ACTIVITY_ID, WAAV.NAME, WAAV.VALUE_TYPE,
       WAAV.TEXT_VALUE, WAAV.NUMBER_VALUE, WAAV.DATE_VALUE
from   WF_ACTIVITY_ATTR_VALUES WAAV
where  WAAV.PROCESS_ACTIVITY_ID = c_actid
and    WAAV.NAME = c_aname;

--
-- Current_Schema (PRIVATE)
--   Return the current schema
--
function Current_Schema
return varchar2
is
begin
  if (wf_engine.schema is null) then
    select sys_context('USERENV','CURRENT_SCHEMA')
      into wf_engine.schema
      from sys.dual;
  end if;
  return wf_engine.schema;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Engine', 'Current_Schema');
    raise;
end Current_Schema;

--
-- AddItemAttr (PUBLIC)
--   Add a new unvalidated run-time item attribute.
-- IN:
--   itemtype - item type
--   itemkey - item key
--   aname - attribute name
--   text_value   - add text value to it if provided.
--   number_value - add number value to it if provided.
--   date_value   - add date value to it if provided.
-- NOTE:
--   The new attribute has no type associated.  Get/set usages of the
--   attribute must insure type consistency.
--
procedure AddItemAttr(itemtype in varchar2,
                      itemkey in varchar2,
                      aname in varchar2,
                      text_value   in varchar2,
                      number_value in number,
                      date_value   in date)
is

  wiavIND    NUMBER;
  iStatus    PLS_INTEGER;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  -- Insure this is a valid item
  elsif (not Wf_Item.Item_Exist(itemtype, itemkey)) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');

  end if;

  if (itemkey = wf_engine.eng_synch) then
    --ItemAttrValues are indexed on the hash value of the name.
    --ItemKey is not used here because we are in #SYNCH mode.
    WF_CACHE.GetItemAttrValue(itemtype, itemKey, aname, iStatus, wiavIND);

      WF_CACHE.ItemAttrValues(wiavIND).ITEM_TYPE := itemtype;
      WF_CACHE.ItemAttrValues(wiavIND).ITEM_KEY := itemKey;
      WF_CACHE.ItemAttrValues(wiavIND).NAME := aname;
      WF_CACHE.ItemAttrValues(wiavIND).TEXT_VALUE := text_value;
      WF_CACHE.ItemAttrValues(wiavIND).NUMBER_VALUE := number_value;
      WF_CACHE.ItemAttrValues(wiavIND).DATE_VALUE := date_value;

  else
    insert into WF_ITEM_ATTRIBUTE_VALUES (
      ITEM_TYPE,
      ITEM_KEY,
      NAME,
      TEXT_VALUE,
      NUMBER_VALUE,
      DATE_VALUE
    ) values (
      itemtype,
      itemkey,
      aname,
      AddItemAttr.text_value,
      AddItemAttr.number_value,
      AddItemAttr.date_value
    );
  end if;

exception
  when dup_val_on_index then
    Wf_Core.Context('Wf_Engine', 'AddItemAttr', itemtype, itemkey, aname);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ATTRIBUTE', aname);
    Wf_Core.Raise('WFENG_ITEM_ATTR_UNIQUE');
  when others then
    Wf_Core.Context('Wf_Engine', 'AddItemAttr', itemtype, itemkey, aname);
    raise;
end AddItemAttr;

--
-- AddItemAttrTextArray (PUBLIC)
--   Add an array of new unvalidated run-time item attributes of type text.
-- IN:
--   itemtype - item type
--   itemkey - item key
--   aname - Array of Names
--   avalue - Array of New values for attribute
-- NOTE:
--   The new attributes have no type associated.  Get/set usages of these
--   attributes must insure type consistency.
--
procedure AddItemAttrTextArray(
  itemtype in varchar2,
  itemkey  in varchar2,
  aname    in Wf_Engine.NameTabTyp,
  avalue   in Wf_Engine.TextTabTyp)
is
  iStatus    pls_integer;
  wiavIND    pls_integer;
  arrayIndex pls_integer;

  success_cnt pls_integer;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  -- Insure this is a valid item and validate that the text array
  -- tables passed in are in proper order.

  elsif (not Wf_Item.Item_Exist(itemtype, itemkey)) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');

  elsif (aname.COUNT = 0 or avalue.COUNT = 0) then
      -- Do not do anything if index table is empty.
      return;

  elsif (aname.LAST <> avalue.LAST or aname.COUNT <> avalue.COUNT) then
      -- Raise an error if the two index tables do not end at the same index
      -- or do not have the same number of elements.
      Wf_Core.Raise('WFENG_ITEM_ATTR_ARRAY_MISMATCH');

  end if;

  -- Check to see if we are in synch mode and use WF_CACHE.

  success_cnt := 0;
  if (itemkey = wf_engine.eng_synch) then
    -- Use WF_CACHE.ItemAttrValues for #SYNCH mode.
    for arrayIndex in aname.FIRST..aname.LAST loop
      -- first check duplicate attribute name
      WF_CACHE.GetItemAttrValue( itemType, itemKey, aname(arrayIndex), iStatus,
                                 wiavIND);

      if (iStatus = WF_CACHE.task_SUCCESS) then
        null;  --There is already an attribute in cache, so we will try to
               --load the rest, then raise a dup_val_on_index after we
               --complete.
      else
        WF_CACHE.ItemAttrValues(wiavIND).ITEM_TYPE  := itemtype;
        WF_CACHE.ItemAttrValues(wiavIND).ITEM_KEY   := itemKey;
        WF_CACHE.ItemAttrValues(wiavIND).NAME       := aname(arrayIndex);
        WF_CACHE.ItemAttrValues(wiavIND).TEXT_VALUE := avalue(arrayIndex);

        success_cnt := success_cnt + 1;

      end if;

    end loop;
  else
    forall arrayIndex in aname.FIRST..aname.LAST
      insert into WF_ITEM_ATTRIBUTE_VALUES (
        ITEM_TYPE,
        ITEM_KEY,
        NAME,
        TEXT_VALUE
      ) values (
        itemtype,
        itemkey,
        aname(arrayIndex),
        avalue(arrayIndex)
      );

    success_cnt := SQL%ROWCOUNT;
    if (success_cnt <> aname.COUNT) then
      raise dup_val_on_index;
    end if;
  end if;

exception
  when dup_val_on_index then
    Wf_Core.Context('Wf_Engine', 'AddItemAttrTextArray', itemtype, itemkey);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('TOTAL', to_char(aname.COUNT));
    Wf_Core.Token('SUCCESS', to_char(success_cnt));
    Wf_Core.Raise('WFENG_ITEM_ATTR_ARRAY');
  when others then
    Wf_Core.Context('Wf_Engine', 'AddItemAttrTextArray', itemtype, itemkey);
    raise;
end AddItemAttrTextArray;

--
-- AddItemAttrNumberArray (PUBLIC)
--   Add an array of new unvalidated run-time item attributes of type number.
-- IN:
--   itemtype - item type
--   itemkey - item key
--   aname - Array of Names
--   avalue - Array of New values for attribute
-- NOTE:
--   The new attributes have no type associated.  Get/set usages of these
--   attributes must insure type consistency.
--
procedure AddItemAttrNumberArray(
  itemtype in varchar2,
  itemkey  in varchar2,
  aname    in Wf_Engine.NameTabTyp,
  avalue   in Wf_Engine.NumTabTyp)
is
  arrayIndex  pls_integer;
  iStatus     pls_integer;
  wiavIND     NUMBER;
  success_cnt number;
begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  -- Insure this is a valid item, and that the attribute arrays are
  -- matching and in the proper form.
  elsif (not Wf_Item.Item_Exist(itemtype, itemkey)) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');

  elsif (aname.COUNT = 0 or avalue.COUNT = 0) then
    -- Do not do anything if index table is empty.
    return;

  elsif (aname.LAST <> avalue.LAST or aname.COUNT <> avalue.COUNT) then
    -- Raise an error if the two index tables do not end at the same index
    -- or do not have the same number of elements.
    Wf_Core.Raise('WFENG_ITEM_ATTR_ARRAY_MISMATCH');

  end if;

  success_cnt := 0;
  --If we are in #SYNCH mode, we will go ahead and use WF_CACHE to
  --Store the attributes.
  if (itemkey = wf_engine.eng_synch) then
    for arrayIndex in aname.FIRST..aname.LAST loop
      -- first check duplicate attribute name
      WF_CACHE.GetItemAttrValue(itemtype, itemKey, aname(arrayIndex), iStatus,
                                wiavIND);

      if (iStatus = WF_CACHE.task_SUCCESS) then
        null; --Proceed and attempt to add the rest before raising
              --dup_val_on_index.
      else
        WF_CACHE.ItemAttrValues(wiavIND).ITEM_TYPE    := itemtype;
        WF_CACHE.ItemAttrValues(wiavIND).ITEM_KEY     := itemKey;
        WF_CACHE.ItemAttrValues(wiavIND).NAME         := aname(arrayIndex);
        WF_CACHE.ItemAttrValues(wiavIND).NUMBER_VALUE := avalue(arrayIndex);
        success_cnt := success_cnt + 1;
      end if;
    end loop;
  else
    forall arrayIndex in aname.FIRST..aname.LAST
      insert into WF_ITEM_ATTRIBUTE_VALUES (
        ITEM_TYPE,
        ITEM_KEY,
        NAME,
        NUMBER_VALUE
      ) values (
        itemtype,
        itemkey,
        aname(arrayIndex),
        avalue(arrayIndex)
      );

    success_cnt := SQL%ROWCOUNT;
    if (success_cnt <> aname.COUNT) then
      raise dup_val_on_index;
    end if;
  end if;

exception
  when dup_val_on_index then
    Wf_Core.Context('Wf_Engine', 'AddItemAttrNumberArray', itemtype, itemkey);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('TOTAL', to_char(aname.COUNT));
    Wf_Core.Token('SUCCESS', to_char(success_cnt));
    Wf_Core.Raise('WFENG_ITEM_ATTR_ARRAY');
  when others then
    Wf_Core.Context('Wf_Engine', 'AddItemAttrNumberArray', itemtype, itemkey);
    raise;
end AddItemAttrNumberArray;

--
-- AddItemAttrDateArray (PUBLIC)
--   Add an array of new unvalidated run-time item attributes of type date.
-- IN:
--   itemtype - item type
--   itemkey - item key
--   aname - Array of Names
--   avalue - Array of New values for attribute
-- NOTE:
--   The new attributes have no type associated.  Get/set usages of these
--   attributes must insure type consistency.
--
procedure AddItemAttrDateArray(
  itemtype in varchar2,
  itemkey  in varchar2,
  aname    in Wf_Engine.NameTabTyp,
  avalue   in Wf_Engine.DateTabTyp)
is
  iStatus     pls_integer;
  wiavIND     number;
  success_cnt number;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- Insure this is a valid item, and the array tables match and are
  -- in proper form.

  if (not Wf_Item.Item_Exist(itemtype, itemkey)) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');

  elsif (aname.COUNT = 0 or avalue.COUNT = 0) then
    -- Do not do anything if index table is empty.
    return;

  elsif (aname.LAST <> avalue.LAST or aname.COUNT <> avalue.COUNT) then
    -- Raise an error if the two index tables do not end at the same index
    -- or do not have the same number of elements.
    Wf_Core.Raise('WFENG_ITEM_ATTR_ARRAY_MISMATCH');
  end if;

  success_cnt := 0;
  -- If in #SYNCH mode, we will use WF_CACHE to store the attributes.
  if (itemkey = wf_engine.eng_synch) then
    for arrayIndex in aname.FIRST..aname.LAST loop
      WF_CACHE.GetItemAttrValue(itemtype, itemKey, aname(arrayIndex), iStatus,
                                wiavIND);

      if (iStatus = WF_CACHE.task_SUCCESS) then
        null; --Attempt to add the rest before raising the dup_val_on_index
      else
        WF_CACHE.ItemAttrValues(wiavIND).ITEM_TYPE  := itemtype;
        WF_CACHE.ItemAttrValues(wiavIND).ITEM_KEY   := itemKey;
        WF_CACHE.ItemAttrValues(wiavIND).NAME       := aname(arrayIndex);
        WF_CACHE.ItemAttrValues(wiavIND).DATE_VALUE := avalue(arrayIndex);
        success_cnt := success_cnt + 1;
      end if;
    end loop;
  else
    forall arrayIndex in aname.FIRST..aname.LAST
      insert into WF_ITEM_ATTRIBUTE_VALUES (
        ITEM_TYPE,
        ITEM_KEY,
        NAME,
        DATE_VALUE
      ) values (
        itemtype,
        itemkey,
        aname(arrayIndex),
        avalue(arrayIndex)
      );

    success_cnt := SQL%ROWCOUNT;
    if (success_cnt <> aname.COUNT) then
      raise dup_val_on_index;
    end if;
  end if;

exception
  when dup_val_on_index then
    Wf_Core.Context('Wf_Engine', 'AddItemAttrDateArray', itemtype, itemkey);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('TOTAL', to_char(aname.COUNT));
    Wf_Core.Token('SUCCESS', to_char(success_cnt));
    Wf_Core.Raise('WFENG_ITEM_ATTR_ARRAY');
  when others then
    Wf_Core.Context('Wf_Engine', 'AddItemAttrDateArray', itemtype, itemkey);
    raise;
end AddItemAttrDateArray;

--
-- SetItemAttrText (PUBLIC)
--   Set the value of a text item attribute.
--   If the attribute is a NUMBER or DATE type, then translate the
--   text-string value to a number/date using attribute format.
--   For all other types, store the value directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetItemAttrText(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in varchar2)
is

  tvalue varchar2(4000);
  nvalue number;
  dvalue date;
  i pls_integer;

  status   PLS_INTEGER;
  wiaIND    NUMBER;
  wiavIND   NUMBER;

  role_info_tbl wf_directory.wf_local_roles_tbl_type;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- Get type and format of attr.
  -- This is used for translating number/date strings.

  WF_CACHE.GetItemAttribute(itemtype, aname, status, wiaIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    begin
      select WIA.ITEM_TYPE, WIA.NAME, WIA.TYPE, WIA.SUBTYPE, WIA.FORMAT,
             WIA.TEXT_DEFAULT, WIA.NUMBER_DEFAULT, WIA.DATE_DEFAULT
      into   WF_CACHE.ItemAttributes(wiaIND)
      from   WF_ITEM_ATTRIBUTES WIA
      where  WIA.ITEM_TYPE = itemtype
      and    WIA.NAME = aname;

    exception
      when no_data_found then
        -- This is an unvalidated runtime attr.
        -- Treat it as a varchar2.
        WF_CACHE.ItemAttributes(wiaIND).ITEM_TYPE := itemtype;
        WF_CACHE.ItemAttributes(wiaIND).NAME      := aname;
        WF_CACHE.ItemAttributes(wiaIND).TYPE      := 'VARCHAR2';
        WF_CACHE.ItemAttributes(wiaIND).SUBTYPE   := '';
        WF_CACHE.ItemAttributes(wiaIND).FORMAT    := '';

    end;
  end if;

  -- Update attribute value in appropriate type column.
  if (WF_CACHE.ItemAttributes(wiaIND).TYPE = 'NUMBER') then

    if (WF_CACHE.ItemAttributes(wiaIND).FORMAT is null) then
      nvalue := to_number(avalue);
    else
      nvalue := to_number(avalue, WF_CACHE.ItemAttributes(wiaIND).FORMAT);
    end if;
    Wf_Engine.SetItemAttrNumber(itemtype, itemkey, aname, nvalue);

  elsif (WF_CACHE.ItemAttributes(wiaIND).TYPE = 'DATE') then

    if (WF_CACHE.ItemAttributes(wiaIND).FORMAT is null) then
      dvalue := to_date(avalue,SYS_CONTEXT('USERENV','NLS_DATE_FORMAT'));
    else
      dvalue := to_date(avalue, WF_CACHE.ItemAttributes(wiaIND).FORMAT);
    end if;
    Wf_Engine.SetItemAttrDate(itemtype, itemkey, aname, dvalue);

  else  -- One of the text values

    if (WF_CACHE.ItemAttributes(wiaIND).TYPE = 'VARCHAR2') then
      -- VARCHAR2 type.  Truncate value as necessary
      if (WF_CACHE.ItemAttributes(wiaIND).FORMAT is null) then
        tvalue := avalue;
      else
        tvalue := substr(avalue, 1,
                         to_number(WF_CACHE.ItemAttributes(wiaIND).FORMAT));
      end if;
    elsif (WF_CACHE.ItemAttributes(wiaIND).TYPE = 'ROLE') then
      -- ROLE type.  Decode to internal name.
      if (avalue is null) then
        -- Null role values are ok
        tvalue := '';
      else
        -- First check if value is internal name
        Wf_Directory.GetRoleInfo2(avalue,role_info_tbl);
        tvalue := role_info_tbl(1).name;
        -- If not internal name, check for display_name
        if (tvalue is null) then
          begin
             SELECT name
             INTO   tvalue
             FROM   wf_role_lov_vl
             WHERE  upper(display_name) = upper(avalue)
             AND    rownum = 1;
          exception
            when no_data_found then
              -- Not displayed or internal role name, error
              wf_core.token('ROLE', avalue);
              wf_core.raise('WFNTF_ROLE');
          end;
        end if;
      end if;
    else

      -- LOOKUP, FORM, URL, DOCUMENT, misc type.
      -- Use value directly.
      tvalue := avalue;
    end if;

    -- Set the text value.
    if (itemkey = wf_engine.eng_synch) then
      -- Use WF_CACHE in synch mode
      WF_CACHE.GetItemAttrValue(itemtype, itemKey, aname, status, wiavIND);

      if (status <> WF_CACHE.task_SUCCESS) then
        raise no_data_found;

      else
        WF_CACHE.ItemAttrValues(wiavIND).TEXT_VALUE := tvalue;

      end if;

    else
      update WF_ITEM_ATTRIBUTE_VALUES set
        TEXT_VALUE = tvalue
      where ITEM_TYPE = itemtype
      and ITEM_KEY = itemkey
      and NAME = aname;

      if (SQL%NOTFOUND) then
        -- ondemand logic.
        if wf_item.Attribute_ON_Demand(itemtype, itemkey) then
        --we need to check if the item attribute is defined or not
        --if attribute value is not defined at design time, we raise an exception
          insert into WF_ITEM_ATTRIBUTE_VALUES (ITEM_TYPE, ITEM_KEY, NAME, TEXT_VALUE)
            select
              SetItemAttrText.itemtype,
              SetItemAttrText.itemkey,
              SetItemAttrText.aname,
              SetItemAttrText.avalue
            from WF_ITEM_ATTRIBUTES WIA
            where WIA.ITEM_TYPE = SetItemAttrText.itemtype
              and WIA.NAME = SetItemAttrText.aname;

           if SQL%NOTFOUND then
            raise no_data_found;
           end if;
        else
          raise no_data_found;
        end if;
      end if;
    end if;
  end if;

exception
  when no_data_found then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrText', itemtype, itemkey,
                    aname, avalue);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ATTRIBUTE', aname);
    Wf_Core.Raise('WFENG_ITEM_ATTR');

  when bad_format then --<rwunderl:2307104/>
    Wf_Core.Context('Wf_Engine', 'SetItemAttrText', itemtype, itemkey,
                    aname, avalue);
    Wf_Core.Token('VALUE', avalue);
    Wf_Core.Token('TYPE', WF_CACHE.ItemAttributes(wiaIND).TYPE);

    if (WF_CACHE.ItemAttributes(wiaIND).FORMAT is not null) then
      WF_CORE.Token('FORMAT', '('||WF_CACHE.ItemAttributes(wiaIND).FORMAT||')');

    else
      WF_CORE.Token('FORMAT', '');

    end if;

    Wf_Core.Raise('WFENG_BAD_FORMAT');

  when others then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrText', itemtype, itemkey,
                    aname, avalue);
    raise;
end SetItemAttrText;

 --
 -- SetItemAttrText2 (PRIVATE)
 --   Set the value of a text item attribute.
 --   USE ONLY WITH VARCHAR2 VALUES.
 --
 -- IN:
 --   p_itemtype - Item type
 --   p_itemkey - Item key
 --   p_aname - Attribute Name
 --   p_avalue - New value for attribute
 -- RETURNS:
 --   boolean
 --
 function SetItemAttrText2(p_itemtype in varchar2,
                           p_itemkey in varchar2,
                           p_aname in varchar2,
                           p_avalue in varchar2) return boolean
 is
   status   PLS_INTEGER;
   wiavIND  NUMBER;
   nvalue NUMBER;
 begin
   -- Check Arguments
   if ((p_itemtype is null) or
       (p_itemkey is null) or
       (p_aname is null)) then
     Wf_Core.Token('p_itemtype', nvl(p_itemtype, 'NULL'));
     Wf_Core.Token('p_itemkey', nvl(p_itemkey, 'NULL'));
     Wf_Core.Token('p_aname', nvl(p_aname, 'NULL'));
     Wf_Core.Raise('WFSQL_ARGS');
   end if;

   -- Set the text value.
   if (p_itemkey = wf_engine.eng_synch) then
     -- Use WF_CACHE in synch mode
     WF_CACHE.GetItemAttrValue(p_itemtype, p_itemkey, p_aname, status, wiavIND);

     if (status <> WF_CACHE.task_SUCCESS) then
       return FALSE;

     else
       WF_CACHE.ItemAttrValues(wiavIND).TEXT_VALUE := p_avalue;
       return TRUE;
     end if;

   else
     update WF_ITEM_ATTRIBUTE_VALUES set
       TEXT_VALUE = p_avalue
     where ITEM_TYPE = p_itemtype
     and ITEM_KEY = p_itemkey
     and NAME = p_aname;

     if (SQL%NOTFOUND) then
        -- ondemand logic
        if wf_item.Attribute_ON_Demand(p_itemtype, p_itemkey) then
        --
        --we need to check if the item attribute is defined or not
        --if attribute value is not defined at design time, we raise an exception
        --
          insert into WF_ITEM_ATTRIBUTE_VALUES (ITEM_TYPE, ITEM_KEY, NAME, TEXT_VALUE)
            select
              SetItemAttrText2.p_itemtype,
              SetItemAttrText2.p_itemkey,
              SetItemAttrText2.p_aname,
              SetItemAttrText2.p_avalue
            from WF_ITEM_ATTRIBUTES WIA
            where WIA.ITEM_TYPE = SetItemAttrText2.p_itemtype
              and WIA.NAME = SetItemAttrText2.p_aname;

          if SQL%NOTFOUND then
            raise no_data_found;
          end if;
           return TRUE;
        else
           return FALSE;
        end if;
     else
       return TRUE;
     end if;
   end if;

 exception
   when no_data_found then
     return FALSE;

   when others then
     Wf_Core.Context('Wf_Engine', 'SetItemAttrText2', p_itemtype, p_itemkey,
                     p_aname, p_avalue);
     raise;
 end SetItemAttrText2;

--
-- SetEventItemAttr (PRIVATE)
--   Set the value of an event item attribute.
--   If the attribute is a NUMBER or DATE type, then translate the
--   text-string value to a number/date using attribute format.
--   For all other types, store the value directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetEventItemAttr(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in varchar2)
is

  nvalue number;
  dvalue date;

  wiaIND NUMBER;
  status PLS_INTEGER;

begin
  -- Get type and format of attr.
  -- This is used for translating number/date strings.
  WF_CACHE.GetItemAttribute(itemtype, aname, status, wiaIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    begin
      select WIA.ITEM_TYPE, WIA.NAME, WIA.TYPE, WIA.SUBTYPE, WIA.FORMAT,
             WIA.TEXT_DEFAULT, WIA.NUMBER_DEFAULT, WIA.DATE_DEFAULT
      into   WF_CACHE.ItemAttributes(wiaIND)
      from   WF_ITEM_ATTRIBUTES WIA
      where  WIA.ITEM_TYPE = itemtype
      and    WIA.NAME = aname;

    exception
      when no_data_found then
        -- This is an unvalidated runtime attr.
        -- Treat it as a varchar2.
        WF_CACHE.ItemAttributes(wiaIND).ITEM_TYPE := itemtype;
        WF_CACHE.ItemAttributes(wiaIND).NAME      := aname;
        WF_CACHE.ItemAttributes(wiaIND).TYPE      := 'VARCHAR2';
        WF_CACHE.ItemAttributes(wiaIND).SUBTYPE   := '';
        WF_CACHE.ItemAttributes(wiaIND).FORMAT    := '';

    end;
  end if;

  -- Update attribute value in appropriate type column.
  if (WF_CACHE.ItemAttributes(wiaIND).TYPE = 'NUMBER') then

    if (WF_CACHE.ItemAttributes(wiaIND).FORMAT is null) then
      nvalue := to_number(avalue, wf_core.canonical_number_mask);
    else
      nvalue := to_number(avalue, WF_CACHE.ItemAttributes(wiaIND).FORMAT);
    end if;
    Wf_Engine.SetItemAttrNumber(itemtype, itemkey, aname, nvalue);

  elsif (WF_CACHE.ItemAttributes(wiaIND).TYPE = 'DATE') then

    if (WF_CACHE.ItemAttributes(wiaIND).FORMAT is null) then
      dvalue := to_date(avalue, wf_core.canonical_date_mask);
    else
      dvalue := to_date(avalue, WF_CACHE.ItemAttributes(wiaIND).FORMAT);
    end if;
    Wf_Engine.SetItemAttrDate(itemtype, itemkey, aname, dvalue);

  else  -- One of the text values

    Wf_Engine.SetItemAttrText(itemtype, itemkey, aname, avalue);

  end if;

exception
  when no_data_found then
    Wf_Core.Context('Wf_Engine', 'SetEventItemAttr', itemtype, itemkey,
                    aname, avalue);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ATTRIBUTE', aname);
    Wf_Core.Raise('WFENG_ITEM_ATTR');

  when others then
    Wf_Core.Context('Wf_Engine', 'SetEventItemAttr', itemtype, itemkey,
                    aname, avalue);
    raise;
end SetEventItemAttr;

--
-- SetItemAttrNumber (PUBLIC)
--   Set the value of a number item attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetItemAttrNumber(itemtype in varchar2,
                            itemkey in varchar2,
                            aname in varchar2,
                            avalue in number)
is
  iStatus  PLS_INTEGER;
  wiavIND  NUMBER;
  nvalue NUMBER;
begin
 -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (aname is null))  then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  if (itemkey = wf_engine.eng_synch) then
    WF_CACHE.GetItemAttrValue(itemtype, itemKey, aname, iStatus, wiavIND);

    if (iStatus <> WF_CACHE.task_SUCCESS) then
      raise no_data_found;

    else
      WF_CACHE.ItemAttrValues(wiavIND).NUMBER_VALUE := avalue;

    end if;

  else
    update WF_ITEM_ATTRIBUTE_VALUES set
      NUMBER_VALUE = avalue
    where ITEM_TYPE = itemtype
    and ITEM_KEY = itemkey
    and NAME = aname;

    if (SQL%NOTFOUND) then
      --ondemand logic.
      if wf_item.Attribute_ON_Demand(itemtype, itemkey) then
      --we need to check if the item attribute is defined or not
      --if attribute value is not defined, we raise an exception
         insert into WF_ITEM_ATTRIBUTE_VALUES (ITEM_TYPE, ITEM_KEY, NAME, NUMBER_VALUE)
            select
              SetItemAttrNumber.itemtype,
              SetItemAttrNumber.itemkey,
              SetItemAttrNumber.aname,
              SetItemAttrNumber.avalue
            from WF_ITEM_ATTRIBUTES WIA
            where WIA.ITEM_TYPE = SetItemAttrNumber.itemtype
              and WIA.NAME = SetItemAttrNumber.aname;

         if SQL%NOTFOUND then
          raise no_data_found;
         end if;
      else
        raise no_data_found;
      end if;
    end if;
  end if;

exception
  when no_data_found then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrNumber', itemtype, itemkey,
                    aname, to_char(avalue));
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ATTRIBUTE', aname);
    Wf_Core.Raise('WFENG_ITEM_ATTR');

  when others then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrNumber', itemtype, itemkey,
                    aname, to_char(avalue));
    raise;
end SetItemAttrNumber;

--
-- SetItemAttrDate (PUBLIC)
--   Set the value of a date item attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetItemAttrDate(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in date)
is
  iStatus    PLS_INTEGER;
  wiavIND    NUMBER;
  nvalue NUMBER;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  if (itemkey = wf_engine.eng_synch) then
    WF_CACHE.GetItemAttrValue(itemtype, itemKey, aname, iStatus, wiavIND);

    if (iStatus <> WF_CACHE.task_SUCCESS) then
      raise no_data_found;

    else
      WF_CACHE.ItemAttrValues(wiavIND).DATE_VALUE := avalue;

    end if;

  else
    update WF_ITEM_ATTRIBUTE_VALUES set
      DATE_VALUE = avalue
    where ITEM_TYPE = itemtype
    and ITEM_KEY = itemkey
    and NAME = aname;

    if (SQL%NOTFOUND) then
      --ondemand logic.
      if wf_item.Attribute_ON_Demand(itemtype, itemkey) then
      --we need to check if the item attribute is defined or not
      --if attribute value is not defined at design time, we raise an exception
         insert into WF_ITEM_ATTRIBUTE_VALUES (ITEM_TYPE, ITEM_KEY, NAME, DATE_VALUE)
            select
              SetItemAttrDate.itemtype,
              SetItemAttrDate.itemkey,
              SetItemAttrDate.aname,
              SetItemAttrDate.avalue
            from WF_ITEM_ATTRIBUTES WIA
            where WIA.ITEM_TYPE = SetItemAttrDate.itemtype
              and WIA.NAME = SetItemAttrDate.aname;

         if SQL%NOTFOUND then
          raise no_data_found;
         end if;
      else
        raise no_data_found;
      end if;
    end if;
  end if;

exception
  when no_data_found then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrDate', itemtype, itemkey,
                    aname, to_char(avalue));
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ATTRIBUTE', aname);
    Wf_Core.Raise('WFENG_ITEM_ATTR');

  when bad_format then --<rwunderl:2307104/>
    Wf_Core.Context('Wf_Engine', 'SetItemAttr', itemtype, itemkey,
                    aname, avalue);
    Wf_Core.Token('VALUE', avalue);
    Wf_Core.Token('FORMAT', 'DATE');
    Wf_Core.Raise('WFENG_BAD_FORMAT');

  when others then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrDate', itemtype, itemkey,
                    aname, to_char(avalue));
    raise;
end SetItemAttrDate;

--
-- SetItemAttrDocument (PUBLIC)
--   Set the value of a document item attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
--   documentid - Document Identifier - full concatenated document attribute
--                strings:
--                nodeid:libraryid:documentid:version:document_name
--
--
procedure SetItemAttrDocument(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          documentid in varchar2)
is
begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  Wf_Engine.SetItemAttrText(itemtype, itemkey, aname, documentid);
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrDocument', itemtype, itemkey,
                    aname);
    raise;
end SetItemAttrDocument;

-- SetItemAttrEvent
--   Set event-type item attribute
-- IN
--   itemtype - process item type
--   itemkey - process item key
--   name - attribute name
--   event - attribute value
--
procedure SetItemAttrEvent(
  itemtype in varchar2,
  itemkey in varchar2,
  name in varchar2,
  event in wf_event_t)
is
  nvalue Number;
begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (name is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('NAME', nvl(name, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.SetItemAttrEvent');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  update WF_ITEM_ATTRIBUTE_VALUES set
    EVENT_VALUE = SetItemAttrEvent.event
  where ITEM_TYPE = SetItemAttrEvent.itemtype
  and ITEM_KEY = SetItemAttrEvent.itemkey
  and NAME = SetItemAttrEvent.name;

  if (SQL%NOTFOUND) then
      --ondemand logic.
      if wf_item.Attribute_ON_Demand(SetItemAttrEvent.itemtype, SetItemAttrEvent.itemkey) then
      --we need to check if the item attribute is defined or not
      --if attribute value is not defined at design time, we raise an exception

         insert into WF_ITEM_ATTRIBUTE_VALUES (ITEM_TYPE, ITEM_KEY, NAME, EVENT_VALUE)
            select
              SetItemAttrEvent.itemtype,
              SetItemAttrEvent.itemkey,
              SetItemAttrEvent.name,
              SetItemAttrEvent.event
            from WF_ITEM_ATTRIBUTES WIA
            where WIA.ITEM_TYPE = SetItemAttrEvent.itemtype
              and WIA.NAME = SetItemAttrEvent.name;

         if SQL%NOTFOUND then
          raise no_data_found;
         end if;
      else
        raise no_data_found;
      end if;
  end if;
exception
  when no_data_found then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrEvent', itemtype, itemkey,
                    name);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ATTRIBUTE', name);
    Wf_Core.Raise('WFENG_ITEM_ATTR');
  when others then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrEvent', itemtype, itemkey,
                    name);
    raise;
end SetItemAttrEvent;

--
-- SetItemAttrTextArray (PUBLIC)
--   Set the values of an array of text item attribute.
--   Unlike SetItemAttrText(), it stores the values directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Array of Names
--   avalue - Array of New values for attribute
--
procedure SetItemAttrTextArray(
  itemtype in varchar2,
  itemkey  in varchar2,
  aname    in Wf_Engine.NameTabTyp,
  avalue   in Wf_Engine.TextTabTyp)
is
  status      pls_integer;
  arrayIndex  pls_integer;
  wiavIND     number;
  success_cnt number;
  success_ins_cnt number;
begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  if (aname.COUNT = 0 or avalue.COUNT = 0) then
    -- Do not do anything if index table is empty.
    return;

  elsif (aname.LAST <> avalue.LAST or aname.COUNT <> avalue.COUNT) then
    -- Raise an error if the two index tables do not end at the same index
    -- or do not have the same number of elements.
    Wf_Core.Raise('WFENG_ITEM_ATTR_ARRAY_MISMATCH');
  end if;

  -- Set the text value.
  if (itemkey = wf_engine.eng_synch) then
    -- Use WF_CACHE in synch mode
    success_cnt := 0;

    for arrayIndex in aname.FIRST..aname.LAST loop
      WF_CACHE.GetItemAttrValue(itemtype, itemKey, aname(arrayIndex), status,
                                wiavIND);

      if (status <> WF_CACHE.task_SUCCESS) then
        null; --The attribute is not in cache to be set.  We will proceed to
              --try to set the remainder and then raise a no_data_found after
              --we complete

      else
        WF_CACHE.ItemAttrValues(wiavIND).TEXT_VALUE := avalue(arrayIndex);
        success_cnt := success_cnt + 1;

      end if;
    end loop;

  else
    forall arrayIndex in aname.FIRST..aname.LAST
      update WF_ITEM_ATTRIBUTE_VALUES set
        TEXT_VALUE = avalue(arrayIndex)
      where ITEM_TYPE = itemtype
      and ITEM_KEY = itemkey
      and NAME = aname(arrayIndex);

    success_cnt := SQL%ROWCOUNT;
    if (success_cnt <> aname.COUNT) then
      --ondemand logic
      if wf_item.Attribute_ON_Demand(itemtype, itemkey) then
        forall arrayIndex in aname.FIRST..aname.LAST
          insert into WF_ITEM_ATTRIBUTE_VALUES
            (ITEM_TYPE, ITEM_KEY, NAME, TEXT_VALUE)
          select itemtype, itemkey, aname(arrayIndex), avalue(arrayIndex)
            from WF_ITEM_ATTRIBUTES WIA
            where
              WIA.ITEM_TYPE = itemtype
            and
              WIA.NAME = aname(arrayIndex)
            and not exists (select 1 from WF_ITEM_ATTRIBUTE_VALUES WIAV
              where WIAV.item_type=itemtype
              and  WIAV.item_key=itemkey
              and  WIAV.NAME=aname(arrayIndex));

          success_cnt := success_cnt + SQL%ROWCOUNT;
          if success_cnt <> aname.COUNT then
            raise no_data_found;
          end if;
      else
        raise no_data_found;
      end if;
    end if;
  end if;

exception
  when no_data_found then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrTextArray', itemtype, itemkey);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('TOTAL', to_char(aname.COUNT));
    Wf_Core.Token('SUCCESS', to_char(success_cnt));
    Wf_Core.Raise('WFENG_ITEM_ATTR_ARRAY');

  when others then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrTextArray', itemtype, itemkey);
    raise;
end SetItemAttrTextArray;


--
-- SetItemAttrNumberArray (PUBLIC)
--   Set the value of an array of number item attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Array of Names
--   avalue - Array of new value for attribute
--
procedure SetItemAttrNumberArray(
  itemtype in varchar2,
  itemkey  in varchar2,
  aname    in Wf_Engine.NameTabTyp,
  avalue   in Wf_Engine.NumTabTyp)
is
  arrayIndex  pls_integer;
  status      pls_integer;
  wiavIND     number;
  success_cnt number;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  elsif (aname.COUNT = 0 or avalue.COUNT = 0) then
    -- Do not do anything if index table is empty.
    return;

  elsif (aname.LAST <> avalue.LAST or aname.COUNT <> avalue.COUNT) then
    -- Raise an error if the two index tables do not end at the same index
    -- or do not have the same number of elements.
    Wf_Core.Raise('WFENG_ITEM_ATTR_ARRAY_MISMATCH');

  end if;

  -- Set the number value.
  if (itemkey = wf_engine.eng_synch) then
    -- Use WF_CACHE in synch mode
    success_cnt := 0;

    for arrayIndex in aname.FIRST..aname.LAST loop
      WF_CACHE.GetItemAttrValue(itemtype, itemKey, aname(arrayIndex), status,
                                wiavIND);

        if (status <> WF_CACHE.task_SUCCESS) then
       null; --The attribute is not in cache to be set.  We will proceed to
              --try to set the remainder and then raise a no_data_found after
              --we complete.

        else
          WF_CACHE.ItemAttrValues(wiavIND).NUMBER_VALUE := avalue(arrayIndex);
          success_cnt := success_cnt + 1;

        end if;

    end loop;

  else
    forall arrayIndex in aname.FIRST..aname.LAST
      update WF_ITEM_ATTRIBUTE_VALUES set
        NUMBER_VALUE = avalue(arrayIndex)
      where ITEM_TYPE = itemtype
      and ITEM_KEY = itemkey
      and NAME = aname(arrayIndex);

    success_cnt := SQL%ROWCOUNT;
    if (success_cnt <> aname.COUNT) then
      --ondemand logic
      if wf_item.Attribute_ON_Demand(itemtype, itemkey) then
        forall arrayIndex in aname.FIRST..aname.LAST
          insert into WF_ITEM_ATTRIBUTE_VALUES
            (ITEM_TYPE, ITEM_KEY, NAME, NUMBER_VALUE)
          select itemtype, itemkey, aname(arrayIndex), avalue(arrayIndex)
            from WF_ITEM_ATTRIBUTES WIA
            where
              WIA.ITEM_TYPE = itemtype
            and
              WIA.NAME = aname(arrayIndex)
            and not exists (select 1 from WF_ITEM_ATTRIBUTE_VALUES WIAV
              where WIAV.item_type=itemtype
              and  WIAV.item_key=itemkey
              and  WIAV.NAME=aname(arrayIndex));

          success_cnt := success_cnt + SQL%ROWCOUNT;
          if success_cnt <> aname.COUNT then
            raise no_data_found;
          end if;
      else
        raise no_data_found;
      end if;
    end if;
  end if;

exception
  when no_data_found then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrNumberArray', itemtype, itemkey);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('TOTAL', to_char(aname.COUNT));
    Wf_Core.Token('SUCCESS', to_char(success_cnt));
    Wf_Core.Raise('WFENG_ITEM_ATTR_ARRAY');

  when others then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrNumberArray', itemtype, itemkey);
    raise;
end SetItemAttrNumberArray;

--
-- SetItemAttrDateArray (PUBLIC)
--   Set the value of an array of date item attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Array of Name
--   avalue - Array of new value for attribute
--
procedure SetItemAttrDateArray(
  itemtype in varchar2,
  itemkey  in varchar2,
  aname    in Wf_Engine.NameTabTyp,
  avalue   in Wf_Engine.DateTabTyp)
is
  status      pls_integer;
  arrayIndex  pls_integer;
  wiavIND     number;
  success_cnt number;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  elsif (aname.COUNT = 0 or avalue.COUNT = 0) then
    -- Do not do anything if index table is empty.
    return;

  elsif (aname.LAST <> avalue.LAST or aname.COUNT <> avalue.COUNT) then
    -- Raise an error if the two index tables do not end at the same index
    -- or do not have the same number of elements.
    Wf_Core.Raise('WFENG_ITEM_ATTR_ARRAY_MISMATCH');

  end if;

  success_cnt := 0;
  -- Set the date value.
  if (itemkey = wf_engine.eng_synch) then
    -- Use WF_CACHE in synch mode
    for arrayIndex in aname.FIRST..aname.LAST loop
      WF_CACHE.GetItemAttrValue(itemtype, itemKey, aname(arrayIndex), status,
                                wiavIND);

      if (status <> WF_CACHE.task_SUCCESS) then
       null; --The attribute is not in cache to be set.  We will proceed to
              --try to set the remainder and then raise a no_data_found after
              --we complete.

      else
        WF_CACHE.ItemAttrValues(wiavIND).DATE_VALUE := avalue(arrayIndex);
        success_cnt := success_cnt + 1;

      end if;

    end loop;

  else
    forall arrayIndex in aname.FIRST..aname.LAST
      update WF_ITEM_ATTRIBUTE_VALUES set
        DATE_VALUE = avalue(arrayIndex)
      where ITEM_TYPE = itemtype
      and ITEM_KEY = itemkey
      and NAME = aname(arrayIndex);

    success_cnt := SQL%ROWCOUNT;
    if (success_cnt <> aname.COUNT) then
      --ondemand logic
      if wf_item.Attribute_ON_Demand(itemtype, itemkey) then
        forall arrayIndex in aname.FIRST..aname.LAST
          insert into WF_ITEM_ATTRIBUTE_VALUES
            (ITEM_TYPE, ITEM_KEY, NAME, DATE_VALUE)
          select itemtype, itemkey, aname(arrayIndex), avalue(arrayIndex)
            from WF_ITEM_ATTRIBUTES WIA
            where
              WIA.ITEM_TYPE = itemtype
            and
              WIA.NAME = aname(arrayIndex)
            and not exists (select 1 from WF_ITEM_ATTRIBUTE_VALUES WIAV
              where WIAV.item_type=itemtype
              and  WIAV.item_key=itemkey
              and  WIAV.NAME=aname(arrayIndex));

          success_cnt := success_cnt + SQL%ROWCOUNT;
          if success_cnt <> aname.COUNT then
            raise no_data_found;
          end if;
      else
        raise no_data_found;
      end if;
    end if;
  end if;

exception
  when no_data_found then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrDateArray', itemtype, itemkey);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('TOTAL', to_char(aname.COUNT));
    Wf_Core.Token('SUCCESS', to_char(success_cnt));
    Wf_Core.Raise('WFENG_ITEM_ATTR_ARRAY');

  when others then
    Wf_Core.Context('Wf_Engine', 'SetItemAttrDateArray', itemtype, itemkey);
    raise;
end SetItemAttrDateArray;

--
-- GetItemAttrInfo (PUBLIC)
--   Get type information about a item attribute.
-- IN:
--   itemtype - Item type
--   aname - Attribute name
-- OUT:
--   atype  - Attribute type
--   subtype - 'SEND' or 'RESPOND'
--   format - Attribute format
--
procedure GetItemAttrInfo(itemtype in varchar2,
                          aname in varchar2,
                          atype out NOCOPY varchar2,
                          subtype out NOCOPY varchar2,
                          format out NOCOPY varchar2)
is

  wiaIND  NUMBER;
  status  PLS_INTEGER;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  WF_CACHE.GetItemAttribute(itemtype, aname, status, wiaIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    select WIA.ITEM_TYPE, WIA.NAME, WIA.TYPE, WIA.SUBTYPE, WIA.FORMAT,
           WIA.TEXT_DEFAULT, WIA.NUMBER_DEFAULT, WIA.DATE_DEFAULT
    into   WF_CACHE.ItemAttributes(wiaIND)
    from   WF_ITEM_ATTRIBUTES WIA
    where  WIA.ITEM_TYPE = itemtype
    and    WIA.NAME = aname;

  end if;

  atype   := WF_CACHE.ItemAttributes(wiaIND).TYPE;
  subtype := WF_CACHE.ItemAttributes(wiaIND).SUBTYPE;
  format  := WF_CACHE.ItemAttributes(wiaIND).FORMAT;

exception
  when no_data_found then
    Wf_Core.Context('Wf_Engine', 'GetItemAttrInfo', itemtype, aname);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', NULL);
    Wf_Core.Token('ATTRIBUTE', aname);
    Wf_Core.Raise('WFENG_ITEM_ATTR');

  when others then
    Wf_Core.Context('Wf_Engine', 'GetItemAttrInfo', itemtype, aname);
    raise;
end GetItemAttrInfo;

--
-- GetItemAttrText (PUBLIC)
--   Get the value of a text item attribute.
--   If the attribute is a NUMBER or DATE type, then translate the
--   number/date value to a text-string representation using attrbute format.
--   For all other types, get the value directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetItemAttrText(itemtype in varchar2,
                         itemkey in varchar2,
                         aname in varchar2,
                         ignore_notfound in boolean)
return varchar2 is
  lvalue varchar2(4000);
  nvalue number;
  dvalue date;
  i pls_integer;

  wiaIND  NUMBER;
  wiavIND NUMBER;
  status  PLS_INTEGER;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- Get type and format of attr.
  -- This is used for translating number/date strings.
  WF_CACHE.GetItemAttribute(itemtype, aname, status, wiaIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    begin
      select WIA.ITEM_TYPE, WIA.NAME, WIA.TYPE, WIA.SUBTYPE, WIA.FORMAT,
             WIA.TEXT_DEFAULT, WIA.NUMBER_DEFAULT, WIA.DATE_DEFAULT
      into   WF_CACHE.ItemAttributes(wiaIND)
      from   WF_ITEM_ATTRIBUTES WIA
      where  WIA.ITEM_TYPE = itemtype
      and    WIA.NAME = aname;

    exception
      when no_data_found then
        -- This is an unvalidated runtime attr.
        -- Treat it as a varchar2.
        WF_CACHE.ItemAttributes(wiaIND).ITEM_TYPE := itemtype;
        WF_CACHE.ItemAttributes(wiaIND).NAME      := aname;
        WF_CACHE.ItemAttributes(wiaIND).TYPE      := 'VARCHAR2';
        WF_CACHE.ItemAttributes(wiaIND).SUBTYPE   := '';
        WF_CACHE.ItemAttributes(wiaIND).FORMAT    := '';

    end;
  end if;

  -- Select value from appropriate type column.
  if (WF_CACHE.ItemAttributes(wiaIND).TYPE = 'NUMBER') then
    nvalue := Wf_Engine.GetItemAttrNumber(itemtype, itemkey, aname);
    if (WF_CACHE.ItemAttributes(wiaIND).FORMAT is null) then
      lvalue := to_char(nvalue);
    else
      lvalue := to_char(nvalue, WF_CACHE.ItemAttributes(wiaIND).FORMAT);
    end if;
  elsif (WF_CACHE.ItemAttributes(wiaIND).TYPE = 'DATE') then
    dvalue := Wf_Engine.GetItemAttrDate(itemtype, itemkey, aname);
    if (WF_CACHE.ItemAttributes(wiaIND).FORMAT is null) then
      lvalue := to_char(dvalue);
    else
      lvalue := to_char(dvalue, WF_CACHE.ItemAttributes(wiaIND).FORMAT);
    end if;
  else
    -- VARCHAR2, LOOKUP, FORM, URL, DOCUMENT.
    -- Get the text value directly with no translation.
    if (itemkey = wf_engine.eng_synch) then
      -- Use WF_CACHE in synch mode
      WF_CACHE.GetItemAttrValue(itemtype, itemKey, aname, status, wiavIND);

      if (status <> WF_CACHE.task_SUCCESS) then
        raise no_data_found;

      else
        return(WF_CACHE.ItemAttrValues(wiavIND).TEXT_VALUE);

      end if;

    else
--we are going to wrap this into a scope, when value not found, we will
--check ondemand flag is true, we will look at cache for design time
--data else will propagate the exception
      begin
        select TEXT_VALUE
        into   lvalue
        from   WF_ITEM_ATTRIBUTE_VALUES
        where  ITEM_TYPE = itemtype
        and    ITEM_KEY = itemkey
        and    NAME = aname;
      exception
        when no_data_found then
        -- ondemand logic
          if wf_item.Attribute_On_Demand(itemtype, itemkey) then
            select TEXT_DEFAULT
            into   lvalue
            from   WF_ITEM_ATTRIBUTES
            where  ITEM_TYPE = itemtype
            and    NAME = aname;
          else
            raise no_data_found;
        end if;
      end;
    end if;
  end if;

  return(lvalue);

exception
  when no_data_found then
    if (ignore_notfound) then

      return(null);

    else

      Wf_Core.Context('Wf_Engine', 'GetItemAttrText', itemtype, itemkey,
                    aname);
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Token('ATTRIBUTE', aname);
      Wf_Core.Raise('WFENG_ITEM_ATTR');

    end if;

  when others then
    Wf_Core.Context('Wf_Engine', 'GetItemAttrText', itemtype, itemkey,
                    aname);
    raise;

end GetItemAttrText;

--
-- GetItemAttrNumber (PUBLIC)
--   Get the value of a number item attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetItemAttrNumber(itemtype in varchar2,
                           itemkey in varchar2,
                           aname in varchar2,
                           ignore_notfound in boolean)

return number is
  wiavIND number;
  status  pls_integer;
  lvalue number;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  if (itemkey = wf_engine.eng_synch) then
    -- Use WF_CACHE in synch mode
    WF_CACHE.GetItemAttrValue(itemtype, itemKey, aname, status, wiavIND);

    if (status <> WF_CACHE.task_SUCCESS) then
      raise no_data_found;

    else
      return(WF_CACHE.ItemAttrValues(wiavIND).NUMBER_VALUE);

    end if;

  else
    begin
      select NUMBER_VALUE
      into   lvalue
      from   WF_ITEM_ATTRIBUTE_VALUES
      where  ITEM_TYPE = itemtype
      and    ITEM_KEY = itemkey
      and    NAME = aname;
    exception
      when no_data_found then
        -- ondemand logic
        if wf_item.Attribute_On_Demand(itemtype, itemkey) then
          select NUMBER_DEFAULT
          into   lvalue
          from   WF_ITEM_ATTRIBUTES
          where  ITEM_TYPE = itemtype
          and    NAME = aname;
        else
          raise no_data_found;
        end if;
    end;
  end if;

  return(lvalue);

exception
  when no_data_found then
   if (ignore_notfound) then

    return(null);

   else

    Wf_Core.Context('Wf_Engine', 'GetItemAttrNumber', itemtype, itemkey,
                    aname);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ATTRIBUTE', aname);
    Wf_Core.Raise('WFENG_ITEM_ATTR');

   end if;

  when others then
    Wf_Core.Context('Wf_Engine', 'GetItemAttrNumber', itemtype, itemkey,
                    aname);
    raise;
end GetItemAttrNumber;

--
-- GetItemAttrDate (PUBLIC)
--   Get the value of a date item attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetItemAttrDate (itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          ignore_notfound in boolean)
return date is
  lvalue date;
  wiavIND number;
  status  pls_integer;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  if (itemkey = wf_engine.eng_synch) then
    -- Use WF_CACHE in synch mode
    WF_CACHE.GetItemAttrValue(itemtype, itemKey, aname, status, wiavIND);

    if (status <> WF_CACHE.task_SUCCESS) then
      raise no_data_found;

    else
      return(WF_CACHE.ItemAttrValues(wiavIND).DATE_VALUE);

    end if;

  else
    begin
      select DATE_VALUE
      into   lvalue
      from   WF_ITEM_ATTRIBUTE_VALUES
      where  ITEM_TYPE = itemtype
      and    ITEM_KEY = itemkey
      and    NAME = aname;
    exception
      when no_data_found then
        if wf_item.Attribute_On_Demand(itemtype, itemkey) then
          select DATE_DEFAULT
          into   lvalue
          from   WF_ITEM_ATTRIBUTES
          where  ITEM_TYPE = itemtype
          and    NAME = aname;
        else
          raise no_data_found;
        end if;
    end;

  end if;

  return(lvalue);

exception
  when no_data_found then
   if (ignore_notfound) then

    return(null);

   else

    Wf_Core.Context('Wf_Engine', 'GetItemAttrDate', itemtype, itemkey,
                    aname);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ATTRIBUTE', aname);
    Wf_Core.Raise('WFENG_ITEM_ATTR');

   end if;
  when others then
    Wf_Core.Context('Wf_Engine', 'GetItemAttrDate', itemtype, itemkey,
                    aname);
    raise;
end GetItemAttrDate;

--
-- GetItemAttrDocument (PUBLIC)
--   Get the value of a document item attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
-- RETURNS:
--   documentid - Document Identifier - full concatenated document attribute
--                strings:
--                nodeid:libraryid:documentid:version:document_name
--
function GetItemAttrDocument(itemtype in varchar2,
                              itemkey in varchar2,
                              aname in varchar2,
                              ignore_notfound in boolean)

return varchar2
is
begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  return(Wf_Engine.GetItemAttrText(itemtype, itemkey, aname, ignore_notfound));
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'GetItemAttrDocument', itemtype, itemkey,
                    aname);
    raise;
end GetItemAttrDocument;

--
-- GetItemAttrClob (PUBLIC)
--   Get display contents of item attribute as a clob
-- NOTE
--   Returns expanded content of attribute.
--   For DOCUMENT-type attributes, this will be the actual document
--   generated.  For all other types, this will be the displayed
--   value of the attribute.
--   Use GetItemAttrText to retrieve internal key.
-- IN
--   itemtype - item type
--   itemkey - item key
--   aname - item attribute name
-- RETURNS
--   Expanded content of item attribute as a clob
--
function GetItemAttrClob(
  itemtype in varchar2,
  itemkey in varchar2,
  aname in varchar2)
return clob
is
  tempclob clob;
  value varchar2(32000);

  wiaIND NUMBER;
  status PLS_INTEGER;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

-- ### Needs to be integrated with document support in wf_notifications!

  -- Get attribute type info
  WF_CACHE.GetItemAttribute(itemtype, aname, status, wiaIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    begin
      select WIA.ITEM_TYPE, WIA.NAME, WIA.TYPE, WIA.SUBTYPE, WIA.FORMAT,
             WIA.TEXT_DEFAULT, WIA.NUMBER_DEFAULT, WIA.DATE_DEFAULT
      into   WF_CACHE.ItemAttributes(wiaIND)
      from   WF_ITEM_ATTRIBUTES WIA
      where  WIA.ITEM_TYPE = GetItemAttrClob.itemtype
      and    WIA.NAME = GetItemAttrClob.aname;

    exception
      when no_data_found then
        -- This is an unvalidated runtime attr.
        -- Treat it as a varchar2.
        WF_CACHE.ItemAttributes(wiaIND).ITEM_TYPE := itemtype;
        WF_CACHE.ItemAttributes(wiaIND).NAME      := aname;
        WF_CACHE.ItemAttributes(wiaIND).TYPE      := 'VARCHAR2';
        WF_CACHE.ItemAttributes(wiaIND).SUBTYPE   := '';
        WF_CACHE.ItemAttributes(wiaIND).FORMAT    := '';

    end;
  end if;

  -- Build clob with contents based on attr type
  if (WF_CACHE.ItemAttributes(wiaIND).TYPE = '###NOTDONE') then
    -- Parse out document subtypes
    null;
  else
    -- All others just use text value
    value := WF_Engine.GetItemAttrText(itemtype, itemkey, aname);
  end if;

  -- Write value to fake clob and return
  if (value is null) then
    -- Dbms_lob raises error if value is null...
    return(null);
  else
    dbms_lob.createtemporary(tempclob, TRUE, dbms_lob.session);
    dbms_lob.write(tempclob, lengthb(value), 1, value);
    return(tempclob);
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Engine', 'GetItemAttrClob', itemtype,
        itemkey, aname);
    raise;
end GetItemAttrClob;

--
-- GetItemAttrEvent
--   Get event-type item attribute
-- IN
--   itemtype - process item type
--   itemkey - process item key
--   name - attribute name
-- RETURNS
--   Attribute value
--
function GetItemAttrEvent(
  itemtype in varchar2,
  itemkey in varchar2,
  name in varchar2)
return wf_event_t
is
  lvalue wf_event_t;
  l_value number;
begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (name is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('NAME', nvl(name, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.GetItemAttrEvent');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  begin
    select EVENT_VALUE
    into lvalue
    from WF_ITEM_ATTRIBUTE_VALUES
    where ITEM_TYPE = GetItemAttrEvent.itemtype
    and ITEM_KEY = GetItemAttrEvent.itemkey
    and NAME = GetItemAttrEvent.name;

   --Initialization done only if event_value is null
    if lvalue is null then
       Wf_Event_T.Initialize(lvalue);
    end if;
    return(lvalue);

  exception
    when no_data_found then
      --
      --For ondemand item attribute, if not found in wiav, we need to check
      -- if it is defined in wia table. If yes, we simply return a empty event
      -- to be backward compatible, otherwise no_data_found is thrown.
      --
      --Note: we do not insert value in wiav at this point. Event value
      -- will only be inserted into the table when setItemAttrEvent is called.
      --
      if wf_item.Attribute_On_Demand(itemtype, itemkey) then
        select null into l_value
          from WF_ITEM_ATTRIBUTES WIA
          where WIA.ITEM_TYPE = GetItemAttrEvent.itemtype
            and WIA.NAME = GetItemAttrEvent.name;

          Wf_Event_T.Initialize(lvalue);

          return(lvalue);
      else
        raise no_data_found;
      end if;
  end;
exception
  when no_data_found then
    Wf_Core.Context('Wf_Engine', 'GetItemAttrEvent', itemtype, itemkey,
                    name);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ATTRIBUTE', name);
    Wf_Core.Raise('WFENG_ITEM_ATTR');
  when others then
    Wf_Core.Context('Wf_Engine', 'GetItemAttrEvent', itemtype,
        itemkey, name);
    raise;
end GetItemAttrEvent;

--
-- GetActivityAttrInfo (PUBLIC)
--   Get type information about an activity attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity id
--   aname - Attribute name
-- OUT:
--   atype  - Attribute type
--   subtype - 'SEND' or 'RESPOND'
--   format - Attribute format
--
procedure GetActivityAttrInfo(itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              aname in varchar2,
                              atype out NOCOPY varchar2,
                              subtype out NOCOPY varchar2,
                              format out NOCOPY varchar2)
is
  actdate date;

  waIND   NUMBER;
  waaIND  NUMBER;
  status  PLS_INTEGER;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (actid is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ACTID', nvl(actid, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  end if;

  actdate := Wf_Item.Active_Date(itemtype, itemkey);

  WF_CACHE.GetActivityAttr( itemtype, aname, actid, actdate, status, waIND,
                            waaIND );

  if (status <> WF_CACHE.task_SUCCESS) then

    waIND  := 0; --If the Get failed, we presume we did not get proper
    waaIND := 0; --hash values for the indexes.  So we default to 0.

    select WA.ITEM_TYPE, WA.NAME, WA.VERSION, WA.TYPE, WA.RERUN,
           WA.EXPAND_ROLE, WA.COST, WA.ERROR_ITEM_TYPE, WA.ERROR_PROCESS,
           WA.FUNCTION, WA.FUNCTION_TYPE,
           WA.EVENT_NAME, WA.MESSAGE, WA.BEGIN_DATE,
           WA.END_DATE, WA.DIRECTION, WAA.ACTIVITY_ITEM_TYPE,
           WAA.ACTIVITY_NAME, WAA.ACTIVITY_VERSION, WAA.NAME, WAA.TYPE,
           WAA.SUBTYPE, WAA.FORMAT, WPA.PROCESS_ITEM_TYPE, WPA.PROCESS_NAME,
           WPA.PROCESS_VERSION, WPA.ACTIVITY_ITEM_TYPE, WPA.ACTIVITY_NAME,
           WPA.INSTANCE_ID, WPA.INSTANCE_LABEL, WPA.PERFORM_ROLE,
           WPA.PERFORM_ROLE_TYPE, WPA.START_END, WPA.DEFAULT_RESULT

    into   WF_CACHE.Activities(waIND).ITEM_TYPE,
           WF_CACHE.Activities(waIND).NAME,
           WF_CACHE.Activities(waIND).VERSION,
           WF_CACHE.Activities(waIND).TYPE,
           WF_CACHE.Activities(waIND).RERUN,
           WF_CACHE.Activities(waIND).EXPAND_ROLE,
           WF_CACHE.Activities(waIND).COST,
           WF_CACHE.Activities(waIND).ERROR_ITEM_TYPE,
           WF_CACHE.Activities(waIND).ERROR_PROCESS,
           WF_CACHE.Activities(waIND).FUNCTION,
           WF_CACHE.Activities(waIND).FUNCTION_TYPE,
           WF_CACHE.Activities(waIND).EVENT_NAME,
           WF_CACHE.Activities(waIND).MESSAGE,
           WF_CACHE.Activities(waIND).BEGIN_DATE,
           WF_CACHE.Activities(waIND).END_DATE,
           WF_CACHE.Activities(waIND).DIRECTION,
           WF_CACHE.ActivityAttributes(waaIND).ACTIVITY_ITEM_TYPE,
           WF_CACHE.ActivityAttributes(waaIND).ACTIVITY_NAME,
           WF_CACHE.ActivityAttributes(waaIND).ACTIVITY_VERSION,
           WF_CACHE.ActivityAttributes(waaIND).NAME,
           WF_CACHE.ActivityAttributes(waaIND).TYPE,
           WF_CACHE.ActivityAttributes(waaIND).SUBTYPE,
           WF_CACHE.ActivityAttributes(waaIND).FORMAT,
           WF_CACHE.ProcessActivities(actid).PROCESS_ITEM_TYPE,
           WF_CACHE.ProcessActivities(actid).PROCESS_NAME,
           WF_CACHE.ProcessActivities(actid).PROCESS_VERSION,
           WF_CACHE.ProcessActivities(actid).ACTIVITY_ITEM_TYPE,
           WF_CACHE.ProcessActivities(actid).ACTIVITY_NAME,
           WF_CACHE.ProcessActivities(actid).INSTANCE_ID,
           WF_CACHE.ProcessActivities(actid).INSTANCE_LABEL,
           WF_CACHE.ProcessActivities(actid).PERFORM_ROLE,
           WF_CACHE.ProcessActivities(actid).PERFORM_ROLE_TYPE,
           WF_CACHE.ProcessActivities(actid).START_END,
           WF_CACHE.ProcessActivities(actid).DEFAULT_RESULT

    from   WF_ACTIVITY_ATTRIBUTES WAA, WF_PROCESS_ACTIVITIES WPA,
           WF_ACTIVITIES WA

    where  WPA.INSTANCE_ID = actid
    and    WA.ITEM_TYPE = WPA.ACTIVITY_ITEM_TYPE
    and    WA.NAME = WPA.ACTIVITY_NAME
    and    actdate >= WA.BEGIN_DATE
    and    actdate < NVL(WA.END_DATE, actdate+1)
    and    WAA.ACTIVITY_ITEM_TYPE = WA.ITEM_TYPE
    and    WAA.ACTIVITY_NAME = WA.NAME
    and    WAA.ACTIVITY_VERSION = WA.VERSION
    and    WAA.NAME = aname;

    --Get the proper hash key and copy the temporary records into the
    --proper locations.
    waIND := WF_CACHE.HashKey(itemType ||
                             WF_CACHE.ProcessActivities(actid).ACTIVITY_NAME);

    WF_CACHE.Activities(waIND) := WF_CACHE.Activities(0);

    waaIND := WF_CACHE.HashKey(itemType || aname ||
                             WF_CACHE.ProcessActivities(actid).ACTIVITY_NAME);

    WF_CACHE.ActivityAttributes(waaIND) :=
                                        WF_CACHE.ActivityAttributes(0);

  end if;

  atype   := WF_CACHE.ActivityAttributes(waaIND).TYPE;
  subtype := WF_CACHE.ActivityAttributes(waaIND).SUBTYPE;
  format  := WF_CACHE.ActivityAttributes(waaIND).FORMAT;

exception
  when no_data_found then
    Wf_Core.Context('Wf_Engine', 'GetActivityAttrInfo', itemtype, itemkey,
                    to_char(actid), aname);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ACTIVITY', to_char(actid));
    Wf_Core.Token('ATTRIBUTE', aname);
    Wf_Core.Raise('WFENG_ACTIVITY_ATTR');
  when others then
    Wf_Core.Context('Wf_Engine', 'GetActivityAttrInfo', itemtype, itemkey,
                    to_char(actid), aname);
    raise;
end GetActivityAttrInfo;


--
-- GetActivityAttrText (PUBLIC)
--   Get the value of a text item attribute.
--   If the attribute is a NUMBER or DATE type, then translate the
--   number/date value to a text-string representation using attrbute format.
--   For all other types, get the value directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetActivityAttrText(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2,
                             ignore_notfound in boolean)
return varchar2 is

  actdate date;

  status  PLS_INTEGER;
  waavIND NUMBER;
  waaIND  NUMBER;
  waIND   NUMBER;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (actid is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ACTID', nvl(actid, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- First check value_type flag for possible item_attribute ref.
  -- Checking to see if the Attribute Value is in cache.
  WF_CACHE.GetActivityAttrValue(actid, aname, status, waavIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    open curs_activityattr (actid, aname);
    fetch curs_activityattr into WF_CACHE.ActivityAttrValues(waavIND);
    close curs_activityattr;
  end if;

  -- If it is a reference, return value of item_attr instead of
  -- contents of WAAV.
  if (WF_CACHE.ActivityAttrValues(waavIND).VALUE_TYPE = 'ITEMATTR') then
    if (WF_CACHE.ActivityAttrValues(waavIND).TEXT_VALUE is null) then
      return(null);  -- Null itemattr means null value, not an error
    end if;

    return(GetItemAttrText(itemtype, itemkey,
              substrb(WF_CACHE.ActivityAttrValues(waavIND).TEXT_VALUE, 1, 30)));

  end if;

  -- This is NOT an itemattr reference, get value directly from WAAV.
  -- Get type and format of attr for translating number/date strings.
  begin
    actdate := Wf_Item.Active_Date(itemtype, itemkey);

    WF_CACHE.GetActivityAttr( itemtype, aname, actid, actdate, status, waIND,
                              waaIND );

    if (status <> WF_CACHE.task_SUCCESS) then
      waIND  := 0;
      waaIND := 0;

      select WA.ITEM_TYPE, WA.NAME, WA.VERSION, WA.TYPE, WA.RERUN,
             WA.EXPAND_ROLE, WA.COST, WA.ERROR_ITEM_TYPE, WA.ERROR_PROCESS,
             WA.FUNCTION, WA.FUNCTION_TYPE,
             WA.EVENT_NAME, WA.MESSAGE, WA.BEGIN_DATE,
             WA.END_DATE, WA.DIRECTION, WAA.ACTIVITY_ITEM_TYPE,
             WAA.ACTIVITY_NAME, WAA.ACTIVITY_VERSION, WAA.NAME, WAA.TYPE,
             WAA.SUBTYPE, WAA.FORMAT, WPA.PROCESS_ITEM_TYPE, WPA.PROCESS_NAME,
             WPA.PROCESS_VERSION, WPA.ACTIVITY_ITEM_TYPE, WPA.ACTIVITY_NAME,
             WPA.INSTANCE_ID, WPA.INSTANCE_LABEL, WPA.PERFORM_ROLE,
             WPA.PERFORM_ROLE_TYPE, WPA.START_END, WPA.DEFAULT_RESULT

      into   WF_CACHE.Activities(waIND).ITEM_TYPE,
             WF_CACHE.Activities(waIND).NAME,
             WF_CACHE.Activities(waIND).VERSION,
             WF_CACHE.Activities(waIND).TYPE,
             WF_CACHE.Activities(waIND).RERUN,
             WF_CACHE.Activities(waIND).EXPAND_ROLE,
             WF_CACHE.Activities(waIND).COST,
             WF_CACHE.Activities(waIND).ERROR_ITEM_TYPE,
             WF_CACHE.Activities(waIND).ERROR_PROCESS,
             WF_CACHE.Activities(waIND).FUNCTION,
             WF_CACHE.Activities(waIND).FUNCTION_TYPE,
             WF_CACHE.Activities(waIND).EVENT_NAME,
             WF_CACHE.Activities(waIND).MESSAGE,
             WF_CACHE.Activities(waIND).BEGIN_DATE,
             WF_CACHE.Activities(waIND).END_DATE,
             WF_CACHE.Activities(waIND).DIRECTION,
             WF_CACHE.ActivityAttributes(waaIND).ACTIVITY_ITEM_TYPE,
             WF_CACHE.ActivityAttributes(waaIND).ACTIVITY_NAME,
             WF_CACHE.ActivityAttributes(waaIND).ACTIVITY_VERSION,
             WF_CACHE.ActivityAttributes(waaIND).NAME,
             WF_CACHE.ActivityAttributes(waaIND).TYPE,
             WF_CACHE.ActivityAttributes(waaIND).SUBTYPE,
             WF_CACHE.ActivityAttributes(waaIND).FORMAT,
             WF_CACHE.ProcessActivities(actid).PROCESS_ITEM_TYPE,
             WF_CACHE.ProcessActivities(actid).PROCESS_NAME,
             WF_CACHE.ProcessActivities(actid).PROCESS_VERSION,
             WF_CACHE.ProcessActivities(actid).ACTIVITY_ITEM_TYPE,
             WF_CACHE.ProcessActivities(actid).ACTIVITY_NAME,
             WF_CACHE.ProcessActivities(actid).INSTANCE_ID,
             WF_CACHE.ProcessActivities(actid).INSTANCE_LABEL,
             WF_CACHE.ProcessActivities(actid).PERFORM_ROLE,
             WF_CACHE.ProcessActivities(actid).PERFORM_ROLE_TYPE,
             WF_CACHE.ProcessActivities(actid).START_END,
             WF_CACHE.ProcessActivities(actid).DEFAULT_RESULT

      from   WF_ACTIVITY_ATTRIBUTES WAA, WF_PROCESS_ACTIVITIES WPA,
             WF_ACTIVITIES WA

      where  WPA.INSTANCE_ID = actid
      and    WA.ITEM_TYPE = WPA.ACTIVITY_ITEM_TYPE
      and    WA.NAME = WPA.ACTIVITY_NAME
      and    actdate >= WA.BEGIN_DATE
      and    actdate < NVL(WA.END_DATE, actdate+1)
      and    WAA.ACTIVITY_ITEM_TYPE = WA.ITEM_TYPE
      and    WAA.ACTIVITY_NAME = WA.NAME
      and    WAA.ACTIVITY_VERSION = WA.VERSION
      and    WAA.NAME = aname;

    --Get the proper hash key and copy the temporary records into the
    --proper locations.
    waIND := WF_CACHE.HashKey(itemType ||
                             WF_CACHE.ProcessActivities(actid).ACTIVITY_NAME);

    WF_CACHE.Activities(waIND) := WF_CACHE.Activities(0);

    waaIND := WF_CACHE.HashKey(itemType || aname ||
                            WF_CACHE.ProcessActivities(actid).ACTIVITY_NAME);

    WF_CACHE.ActivityAttributes(waaIND) :=
                                        WF_CACHE.ActivityAttributes(0);

    end if;

  exception
    when no_data_found then
      -- This is an unvalidated runtime attr.
      -- Treat it as a varchar2.
      -- We know that the activity and process activity should be retrievable.
      -- We will build a unvalidated runtime attr in cache.  First we need to
      -- validate that we have the correct activity and process activity cached

      WF_CACHE.GetProcessActivityInfo(actid, actdate, status, waIND);

      if (status <> WF_CACHE.task_SUCCESS)  then
        waIND := 0;

        select WA.ITEM_TYPE, WA.NAME, WA.VERSION, WA.TYPE, WA.RERUN,
               WA.EXPAND_ROLE, WA.COST, WA.ERROR_ITEM_TYPE, WA.ERROR_PROCESS,
               WA.FUNCTION, WA.FUNCTION_TYPE,  WA.MESSAGE, WA.BEGIN_DATE,
               WA.END_DATE, WA.DIRECTION, WPA.PROCESS_ITEM_TYPE,
               WPA.PROCESS_NAME, WPA.PROCESS_VERSION, WPA.ACTIVITY_ITEM_TYPE,
               WPA.ACTIVITY_NAME, WPA.INSTANCE_ID, WPA.INSTANCE_LABEL,
               WPA.PERFORM_ROLE, WPA.PERFORM_ROLE_TYPE, WPA.START_END,
               WPA.DEFAULT_RESULT

        into   WF_CACHE.Activities(waIND).ITEM_TYPE,
               WF_CACHE.Activities(waIND).NAME,
               WF_CACHE.Activities(waIND).VERSION,
               WF_CACHE.Activities(waIND).TYPE,
               WF_CACHE.Activities(waIND).RERUN,
               WF_CACHE.Activities(waIND).EXPAND_ROLE,
               WF_CACHE.Activities(waIND).COST,
               WF_CACHE.Activities(waIND).ERROR_ITEM_TYPE,
               WF_CACHE.Activities(waIND).ERROR_PROCESS,
               WF_CACHE.Activities(waIND).FUNCTION,
               WF_CACHE.Activities(waIND).FUNCTION_TYPE,
               WF_CACHE.Activities(waIND).MESSAGE,
               WF_CACHE.Activities(waIND).BEGIN_DATE,
               WF_CACHE.Activities(waIND).END_DATE,
               WF_CACHE.Activities(waIND).DIRECTION,
               WF_CACHE.ProcessActivities(actid).PROCESS_ITEM_TYPE,
               WF_CACHE.ProcessActivities(actid).PROCESS_NAME,
               WF_CACHE.ProcessActivities(actid).PROCESS_VERSION,
               WF_CACHE.ProcessActivities(actid).ACTIVITY_ITEM_TYPE,
               WF_CACHE.ProcessActivities(actid).ACTIVITY_NAME,
               WF_CACHE.ProcessActivities(actid).INSTANCE_ID,
               WF_CACHE.ProcessActivities(actid).INSTANCE_LABEL,
               WF_CACHE.ProcessActivities(actid).PERFORM_ROLE,
               WF_CACHE.ProcessActivities(actid).PERFORM_ROLE_TYPE,
               WF_CACHE.ProcessActivities(actid).START_END,
               WF_CACHE.ProcessActivities(actid).DEFAULT_RESULT

        from   WF_PROCESS_ACTIVITIES WPA, WF_ACTIVITIES WA

        where  WPA.INSTANCE_ID = actid
        and    WA.ITEM_TYPE = WPA.ACTIVITY_ITEM_TYPE
        and    WA.NAME = WPA.ACTIVITY_NAME
        and    actdate >= WA.BEGIN_DATE
        and    actdate < NVL(WA.END_DATE, actdate+1);

      end if;

        waIND := WF_CACHE.HashKey(itemType ||
                        WF_CACHE.ProcessActivities(actid).ACTIVITY_NAME);

        waaIND := WF_CACHE.HashKey(itemType || aname ||
                              WF_CACHE.ProcessActivities(actid).ACTIVITY_NAME);

        WF_CACHE.Activities(waIND) := WF_CACHE.Activities(0);

        WF_CACHE.ActivityAttributes(waaIND).ACTIVITY_ITEM_TYPE :=
                WF_CACHE.Activities(waIND).ITEM_TYPE;
        WF_CACHE.ActivityAttributes(waaIND).ACTIVITY_NAME :=
                WF_CACHE.Activities(waIND).NAME;
        WF_CACHE.ActivityAttributes(waaIND).ACTIVITY_VERSION :=
                WF_CACHE.Activities(waIND).VERSION;
        WF_CACHE.ActivityAttributes(waaIND).NAME := aname;
        WF_CACHE.ActivityAttributes(waaIND).TYPE := 'VARCHAR2';
        WF_CACHE.ActivityAttributes(waaIND).SUBTYPE := '';
        WF_CACHE.ActivityAttributes(waaIND).FORMAT := '';

  end;

  -- Format return value as needed for text/number/date type.
  if (WF_CACHE.ActivityAttributes(waaIND).TYPE = 'NUMBER') then
    if (WF_CACHE.ActivityAttributes(waaIND).FORMAT <> '') then
      return(to_char(WF_CACHE.ActivityAttrValues(waavIND).NUMBER_VALUE,
                     WF_CACHE.ActivityAttributes(waaIND).FORMAT));

    else
      return(to_char(WF_CACHE.ActivityAttrValues(waavIND).NUMBER_VALUE));

    end if;

  elsif (WF_CACHE.ActivityAttributes(waaIND).TYPE = 'DATE') then
    if (WF_CACHE.ActivityAttributes(waaIND).FORMAT <> '') then
      return(to_char(WF_CACHE.ActivityAttrValues(waavIND).DATE_VALUE,
                     WF_CACHE.ActivityAttributes(waaIND).FORMAT));

    else
      return(to_char(WF_CACHE.ActivityAttrValues(waavIND).DATE_VALUE));

    end if;

  else
    -- VARCHAR2, LOOKUP, FORM, URL, DOCUMENT.
    -- Set the text value directly with no translation.
    return(WF_CACHE.ActivityAttrValues(waavIND).TEXT_VALUE);

  end if;

exception
  when no_data_found then
    --Check to ensure that cursor is not open
    if (curs_activityattr%ISOPEN) then
      CLOSE curs_activityattr;
    end if;

    if (ignore_notfound) then

      return(null);

    else

     Wf_Core.Context('Wf_Engine', 'GetActivityAttrText', itemtype, itemkey,
                     to_char(actid), aname);
     Wf_Core.Token('TYPE', itemtype);
     Wf_Core.Token('KEY', itemkey);
     Wf_Core.Token('ACTIVITY', to_char(actid));
     Wf_Core.Token('ATTRIBUTE', aname);
     Wf_Core.Raise('WFENG_ACTIVITY_ATTR');

    end if;

  when others then
    --Check to ensure that cursor is not open
    if (curs_activityattr%ISOPEN) then
      CLOSE curs_activityattr;
    end if;

    Wf_Core.Context('Wf_Engine', 'GetActivityAttrText', itemtype, itemkey,
                    to_char(actid), aname);
    raise;
end GetActivityAttrText;

--
-- GetActivityAttrNumber (PUBLIC)
--   Get the value of a number item attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetActivityAttrNumber(itemtype in varchar2,
                               itemkey in varchar2,
                               actid in number,
                               aname in varchar2,
                               ignore_notfound in boolean)

return number is

waavIND     NUMBER;
status      PLS_INTEGER;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (actid is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ACTID', nvl(actid, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  WF_CACHE.GetActivityAttrValue(actid, aname, status, waavIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    open curs_activityattr (actid, aname);
    fetch curs_activityattr into WF_CACHE.ActivityAttrValues(waavIND);
    close curs_activityattr;
  end if;

  -- If it is a reference, replace lvalue with value of itemattr.
  if (WF_CACHE.ActivityAttrValues(waavIND).VALUE_TYPE = 'ITEMATTR') then
    return(GetItemAttrNumber(itemtype, itemkey,
            substrb(WF_CACHE.ActivityAttrValues(waavIND).TEXT_VALUE, 1, 30)));

  else
    return(WF_CACHE.ActivityAttrValues(waavIND).NUMBER_VALUE);

  end if;

exception
  when no_data_found then
   --Check to ensure that cursor is not open
   if (curs_activityattr%ISOPEN) then
     CLOSE curs_activityattr;
   end if;

   if (ignore_notfound) then
    WF_CACHE.ActivityAttrValues(waavIND).PROCESS_ACTIVITY_ID := actid;
    WF_CACHE.ActivityAttrValues(waavIND).NAME := aname;
    WF_CACHE.ActivityAttrValues(waavIND).VALUE_TYPE := 'CONSTANT';
    WF_CACHE.ActivityAttrValues(waavIND).TEXT_VALUE := '';
    WF_CACHE.ActivityAttrValues(waavIND).NUMBER_VALUE := '';
    WF_CACHE.ActivityAttrValues(waavIND).DATE_VALUE := to_date(NULL);

    return null;

   else

    Wf_Core.Context('Wf_Engine', 'GetActivityAttrNumber', itemtype, itemkey,
                    to_char(actid), aname);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ACTIVITY', to_char(actid));
    Wf_Core.Token('ATTRIBUTE', aname);
    Wf_Core.Raise('WFENG_ACTIVITY_ATTR');

   end if;

  when others then
    --Check to ensure that cursor is not open
    if (curs_activityattr%ISOPEN) then
      CLOSE curs_activityattr;
    end if;

    Wf_Core.Context('Wf_Engine', 'GetActivityAttrNumber', itemtype, itemkey,
                    to_char(actid), aname);
    raise;
end GetActivityAttrNumber;

--
-- GetActivityAttrDate (PUBLIC)
--   Get the value of a date item attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetActivityAttrDate(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2,
                             ignore_notfound in boolean)
return date is

  waavIND  NUMBER;
  status   PLS_INTEGER;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (actid is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ACTID', nvl(actid, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- First check value_type flag for possible item_attribute ref.
  WF_CACHE.GetActivityAttrValue(actid, aname, status, waavIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    open curs_activityattr (actid, aname);
    fetch curs_activityattr into WF_CACHE.ActivityAttrValues(waavIND);
    close curs_activityattr;
  end if;

  -- If it is a reference, get the item attribute and return it.
  if (WF_CACHE.ActivityAttrValues(waavIND).VALUE_TYPE = 'ITEMATTR') then
    return(GetItemAttrDate(itemtype, itemkey,
           substrb(WF_CACHE.ActivityAttrValues(waavIND).TEXT_VALUE, 1, 30)));

  else
    return(WF_CACHE.ActivityAttrValues(waavIND).DATE_VALUE);

  end if;

exception
  when no_data_found then
   --Check to ensure that cursor is not open
   if (curs_activityattr%ISOPEN) then
     CLOSE curs_activityattr;
   end if;

   if (ignore_notfound) then
    WF_CACHE.ActivityAttrValues(waavIND).PROCESS_ACTIVITY_ID := actid;
    WF_CACHE.ActivityAttrValues(waavIND).NAME := aname;
    WF_CACHE.ActivityAttrValues(waavIND).VALUE_TYPE := 'CONSTANT';
    WF_CACHE.ActivityAttrValues(waavIND).TEXT_VALUE := '';
    WF_CACHE.ActivityAttrValues(waavIND).NUMBER_VALUE := '';
    WF_CACHE.ActivityAttrValues(waavIND).DATE_VALUE := to_date(NULL);
    return(null);

   else

    Wf_Core.Context('Wf_Engine', 'GetActivityAttrDate', itemtype, itemkey,
                    to_char(actid), aname);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ACTIVITY', to_char(actid));
    Wf_Core.Token('ATTRIBUTE', aname);
    Wf_Core.Raise('WFENG_ACTIVITY_ATTR');

   end if;

  when others then
    --Check to ensure that cursor is not open
    if (curs_activityattr%ISOPEN) then
      CLOSE curs_activityattr;
    end if;

    Wf_Core.Context('Wf_Engine', 'GetActivityAttrDate', itemtype, itemkey,
                    to_char(actid), aname);
    raise;
end GetActivityAttrDate;

--
-- GetActivityAttrClob (PUBLIC)
--   Get display contents of activity attribute as a clob
-- NOTE
--   Returns expanded content of attribute.
--   For DOCUMENT-type attributes, this will be the actual document
--   generated.  For all other types, this will be the displayed
--   value of the attribute.
--   Use GetActivityAttrText to retrieve internal key.
-- IN
--   itemtype - item type
--   itemkey - item key
--   aname - activity attribute name
-- RETURNS
--   Expanded content of activity attribute as a clob
--
function GetActivityAttrClob(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number,
  aname in varchar2)
return clob
is
  atype varchar2(8);
  format varchar2(240);
  value varchar2(32000);
  actdate date;
  tempclob clob;

  waavIND   NUMBER;
  status    PLS_INTEGER;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (actid is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ACTID', nvl(actid, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- First check value_type flag for possible item_attribute ref.
  WF_CACHE.GetActivityAttrValue(actid, aname, status, waavIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    open curs_activityattr (actid, aname);
    fetch curs_activityattr into WF_CACHE.ActivityAttrValues(waavIND);
    close curs_activityattr;
  end if;

  -- If it is a reference, return value of item_attr instead of
  -- contents of WAAV.
  if (WF_CACHE.ActivityAttrValues(waavIND).VALUE_TYPE = 'ITEMATTR') then
    if (WF_CACHE.ActivityAttrValues(waavIND).TEXT_VALUE is null) then
      return(null);  -- Null itemattr means null value, not an error

    else
    return(GetItemAttrClob(itemtype, itemkey,
           substrb(WF_CACHE.ActivityAttrValues(waavIND).TEXT_VALUE, 1, 30)));

    end if;
  end if;

  -- Make fake clob to hold result
  dbms_lob.createtemporary(tempclob, TRUE, dbms_lob.session);

  -- Build clob with contents based on attr type
  if (atype = '###NOTDONE') then
    -- Parse out document subtypes
    null;
  else
    -- All others just use text value
    value := WF_Engine.GetActivityAttrText(itemtype, itemkey, actid, aname);
  end if;

  -- Write value to fake clob and return
  dbms_lob.write(tempclob, lengthb(value), 1, value);
  return(tempclob);

exception
  when others then
    --Check to ensure that cursor is not open
    if (curs_activityattr%ISOPEN) then
      CLOSE curs_activityattr;
    end if;

    Wf_Core.Context('Wf_Engine', 'GetActivityAttrClob', itemtype,
        itemkey, to_char(actid), aname);
    raise;
end GetActivityAttrClob;

--
-- GetActivityAttrEvent
--   Get event-type activity attribute
-- IN
--   itemtype - process item type
--   itemkey - process item key
--   actid - current activity id
--   name - attribute name
-- RETURNS
--   Attribute value
--
function GetActivityAttrEvent(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number,
  name in varchar2)
return wf_event_t
is
  waavIND  NUMBER;
  status   PLS_INTEGER;

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (actid is null) or
      (name is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('ACTID', nvl(actid, 'NULL'));
    Wf_Core.Token('NAME', nvl(name, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- First check value_type flag for possible item_attribute ref.

  -- First check value_type flag for possible item_attribute ref.
  WF_CACHE.GetActivityAttrValue(actid, name, status, waavIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    open curs_activityattr (actid, GetActivityAttrEvent.name);
    fetch curs_activityattr into WF_CACHE.ActivityAttrValues(waavIND);
    close curs_activityattr;
  end if;

  -- If it is a reference, replace lvalue with value of itemattr.
  if (WF_CACHE.ActivityAttrValues(waavIND).VALUE_TYPE = 'ITEMATTR') then
    return(GetItemAttrEvent(itemtype, itemkey,
           substrb(WF_CACHE.ActivityAttrValues(waavIND).TEXT_VALUE, 1, 30)));

  else
    -- Only itemattr-type activity event attrs are supported
    return NULL;

  end if;

exception
  when no_data_found then
    --Check to ensure that cursor is not open
    if (curs_activityattr%ISOPEN) then
      CLOSE curs_activityattr;
    end if;

    Wf_Core.Context('Wf_Engine', 'GetActivityAttrEvent', itemtype, itemkey,
                    to_char(actid), name);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('ACTIVITY', to_char(actid));
    Wf_Core.Token('ATTRIBUTE', name);
    Wf_Core.Raise('WFENG_ACTIVITY_ATTR');

  when others then
    --Check to ensure that cursor is not open
    if (curs_activityattr%ISOPEN) then
      CLOSE curs_activityattr;
    end if;

    Wf_Core.Context('Wf_Engine', 'GetActivityAttrEvent', itemtype,
        itemkey, to_char(actid), name);
    raise;
end GetActivityAttrEvent;

--
-- Set_Item_Parent (PUBLIC)
-- *** OBSOLETE - Use SetItemParent instead ***
--
procedure Set_Item_Parent(itemtype in varchar2,
  itemkey in varchar2,
  parent_itemtype in varchar2,
  parent_itemkey in varchar2,
  parent_context in varchar2)
is
begin
  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.Set_Item_Parent');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  Wf_Item.Set_Item_Parent(itemtype, itemkey, parent_itemtype, parent_itemkey,
                        parent_context);
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'Set_Item_Parent', itemtype, itemkey,
                     parent_itemtype, parent_itemkey, parent_context);
    raise;
end Set_Item_Parent;

--
-- SetItemParent (PUBLIC)
--   Set the parent info of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   parent_itemtype - Itemtype of parent
--   parent_itemkey - Itemkey of parent
--   parent_context - Context info about parent
--   masterdetail - Signal if the two flows are coordinated.
--
procedure SetItemParent(itemtype in varchar2,
  itemkey in varchar2,
  parent_itemtype in varchar2,
  parent_itemkey in varchar2,
  parent_context in varchar2,
  masterdetail   in boolean)
is
begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null) or
      (parent_itemtype is null) or
      (parent_itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Token('PARENT_ITEMTYPE', nvl(parent_itemtype, 'NULL'));
    Wf_Core.Token('PARENT_ITEMKEY', nvl(parent_itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  end if;

  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.SetItemParent');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  Wf_Item.Set_Item_Parent(itemtype, itemkey, parent_itemtype,
      parent_itemkey, parent_context, masterdetail);
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'SetItemParent', itemtype, itemkey,
        parent_itemtype, parent_itemkey, parent_context);
    raise;
end SetItemParent;

--
-- SetItemOwner (PUBLIC)
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
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  end if;

  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.SetItemOwner');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  Wf_Item.SetItemOwner(itemtype, itemkey, owner);
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'SetItemOwner', itemtype, itemkey,
                    owner);
    raise;
end SetItemOwner;

--
-- GetItemUserKey (PUBLIC)
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
begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  return(Wf_Item.GetItemUserKey(itemtype, itemkey));
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'GetItemUserKey', itemtype, itemkey);
    raise;
end GetItemUserKey;

--
-- SetItemUserKey (PUBLIC)
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
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  end if;

  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.SetItemUserKey');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  Wf_Item.SetItemUserKey(itemtype, itemkey, userkey);
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'SetItemUserKey', itemtype, itemkey,
                    userkey);
    raise;
end SetItemUserKey;

--
-- GetActivityLabel (PUBLIC)
--  Get activity instance label given id, in a format
--  suitable for passing to other wf_engine apis.
-- IN
--   actid - activity instance id
-- RETURNS
--   <process_name>||':'||<instance_label>
--
function GetActivityLabel(
  actid in number)
return varchar2
is

  status PLS_INTEGER;

begin
  -- Check Arguments
  if (actid is null) then
    Wf_Core.Token('ACTID', nvl(actid, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  WF_CACHE.GetProcessActivity(actid, status);

  if (status <> WF_CACHE.task_SUCCESS) then

    select WPA.PROCESS_ITEM_TYPE, WPA.PROCESS_NAME, WPA.PROCESS_VERSION,
           WPA.ACTIVITY_ITEM_TYPE, WPA.ACTIVITY_NAME, WPA.INSTANCE_ID,
           WPA.INSTANCE_LABEL, WPA.PERFORM_ROLE, WPA.PERFORM_ROLE_TYPE,
           WPA.START_END, WPA.DEFAULT_RESULT
    into   WF_CACHE.ProcessActivities(actid)
    from   WF_PROCESS_ACTIVITIES WPA
    where  WPA.INSTANCE_ID = GetActivityLabel.actid;

  end if;

  return(WF_CACHE.ProcessActivities(actid).PROCESS_NAME || ':' ||
         WF_CACHE.ProcessActivities(actid).INSTANCE_LABEL);

exception
  when no_data_found then
    Wf_Core.Context('Wf_Engine', 'GetActivityLabel', to_char(actid));
    Wf_Core.Token('ACTID', to_char(actid));
    Wf_Core.Raise('WFENG_ACTID');
  when others then
    Wf_Core.Context('Wf_Engine', 'GetActivityLabel', to_char(actid));
    raise;
end GetActivityLabel;

-- Bug 2376033
--   Overloads the previous API with an additional event type parmeter
--
-- CB (PUBLIC)
--   This is the callback function used by the notification system to
--   get and set process attributes, and mark a process complete.
--
--   The command may be one of:
--     GET - Get the value of an attribute
--     SET - Set the value of an attribute
--     COMPLETE - Mark the activity as complete
--     ERROR - Mark the activity as error status
--     TESTCTX - Test current context via selector function
--     FORWARD - Execute notification function for FORWARD
--     TRANSFER - Execute notification function for TRANSFER
--     RESPOND - Execute notification function for RESPOND
--
--   The context is in the format <itemtype>:<itemkey>:<activityid>.
--
--   The text_value/number_value/date_value fields are mutually exclusive.
--   It is assumed that only one will be used, depending on the value of
--   the attr_type argument ('VARCHAR2', 'NUMBER', or 'DATE').
--
-- IN:
--   command - Action requested.  Must be one of 'GET', 'SET', or 'COMPLETE'.
--   context - Context data in the form '<item_type>:<item_key>:<activity>'
--   attr_name - Attribute name to set/get for 'GET' or 'SET'
--   attr_type - Attribute type for 'SET'
--   text_value - Text Attribute value for 'SET'
--   number_value - Number Attribute value for 'SET'
--   date_value - Date Attribute value for 'SET'
-- OUT:
--   text_value - Text Attribute value for 'GET'
--   number_value - Number Attribute value for 'GET'
--   date_value - Date Attribute value for 'GET'
--   event_value - Event Attribute value for 'GET'
--
--No locking logic right now
--Locking at the item level is implemented in all cases
--where there is chances that status o fthe activity is being
--changed and there may be simultaneous access.

procedure CB(command in varchar2,
             context in varchar2,
             attr_name in varchar2,
             attr_type in varchar2,
             text_value in out NOCOPY varchar2,
             number_value in out NOCOPY number,
             date_value in out NOCOPY date,
             event_value in out nocopy wf_event_t)
is
  firstcolon pls_integer;
  secondcolon pls_integer;

  itemtype varchar2(8);
  itemkey varchar2(240);
  actid pls_integer;
  status varchar2(8);
  result varchar2(2000);

  message varchar2(30);
  msgtype varchar2(8);
  expand_role varchar2(1);

  wf_invalid_command exception;
  wf_invalid_argument exception;

  trig_savepoint exception;
  pragma exception_init(trig_savepoint, -04092);
  dist_savepoint exception;
  pragma exception_init(dist_savepoint, -02074);

begin
  --
  -- Argument validation
  --
  if (command is null) then
    raise wf_invalid_command;
  end if;
  if (context is null) then
    raise wf_invalid_argument;
  end if;

  --
  -- Take the context apart and extract item_type and
  -- item_key from it.
  --
  firstcolon := instr(context, ':', 1,1);
  secondcolon := instr(context, ':', -1,1);

  if (firstcolon = 0  or secondcolon = 0) then
    raise wf_invalid_argument;
  end if;

  itemtype := substr(context, 1, firstcolon - 1);
  itemkey := substr(context, firstcolon + 1, secondcolon - firstcolon - 1);
  actid := to_number(substr(context, secondcolon+1,
                            length(context) - secondcolon));

  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.CB');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  --
  -- Handle the command now ... Get value and type Return Null
  -- If the specified item not found ...
  -- Bug 2376033 Get event attribute value for Event attribute type
  --
  if (upper(command) = 'GET') then
    if (attr_type = 'NUMBER') then
      number_value := GetItemAttrNumber(itemtype, itemkey, attr_name);
    elsif (attr_type = 'DATE') then
      date_value := GetItemAttrDate(itemtype, itemkey, attr_name);
    elsif (attr_type = 'EVENT') then
      event_value := GetItemAttrEvent(itemtype, itemkey, attr_name);
    else
      text_value := GetItemAttrText(itemtype, itemkey, attr_name);
    end if;
  elsif (upper(command) = 'SET') then
    begin
      if (attr_type = 'NUMBER') then
        SetItemAttrNumber(itemtype, itemkey, attr_name, number_value);
      elsif (attr_type = 'DATE') then
        SetItemAttrDate(itemtype, itemkey, attr_name, date_value);
      elsif (attr_type = 'EVENT') then
        SetItemAttrEvent(itemtype, itemkey, attr_name, event_value);
      else
        SetItemAttrText(itemtype, itemkey, attr_name, text_value);
      end if;
    exception
      when OTHERS then
        -- If attr is not already defined, add a runtime attribute
        -- with this name, then try the set again.
        if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
          if (attr_type = 'EVENT') then
            raise;
          end if;
          wf_core.clear;
          if (attr_type = 'NUMBER') then
            AddItemAttr(itemtype=>itemtype,
                        itemkey=>itemkey,
                        aname=>attr_name,
                        number_value=>number_value);
          elsif (attr_type = 'DATE') then
            AddItemAttr(itemtype=>itemtype,
                        itemkey=>itemkey,
                        aname=>attr_name,
                        date_value=>date_value);
          else
            AddItemAttr(itemtype=>itemtype,
                        itemkey=>itemkey,
                        aname=>attr_name,
                        text_value=>text_value);
          end if;
        else
          raise;
        end if;
     end;
   elsif (upper(command) = wf_engine.eng_completed) then
      -- CB is signalling that a notification has completed.
      -- If the activity originating this notification still has ACTIVE
      -- status, then a routing rule (or some other kind of automatic
      -- processing) has completed the notification before the activity
      -- itself has finished.  In this case, do NOT actually complete
      -- the activity and continue processing.  Exit silently and let
      -- execute_activity() pick up the execution when the activity
      -- owning this notification is actually completed.
      Wf_Item_Activity_Status.Status(itemtype, itemkey,
          actid, status);
      if (status = wf_engine.eng_active) then
        -- Do nothing!!!
        return;
      end if;

      -- ### DL: Trap rollback error for savepoint
      -- ### We do not trap the cases where we have trigger or distributed
      -- ### savepoint at this time, but we can.  More testing is needed.
      -- ### Mainly we do not want to initiate error processing when those
      -- ### exceptions are caught.

      -- Use the text_value passed in as the result code for the activity.
      result := text_value;
      begin
        savepoint wf_savepoint;
        if (WF_CACHE.MetaRefreshed) then
          NULL;

        end if;

        Wf_Engine_Util.Complete_Activity(itemtype, itemkey, actid, result);
      exception
        when trig_savepoint or dist_savepoint then
          -- Savepoint violation.
          -- Try without fancy error processing.
          Wf_Engine_Util.Complete_Activity(itemtype, itemkey, actid, result);
        when others then
          -- If anything in this process raises an exception:
          -- 1. rollback any work in this process thread
          -- 2. set this activity to error status
          -- 3. execute the error process (if any)
          -- 4. clear the error to continue with next activity
          rollback to wf_savepoint;
	  --The rollback will be done in the when others block
          Wf_Core.Context('Wf_Engine', 'CB', command, context, attr_name,
              attr_type, ':'||text_value||':'||to_char(number_value)||':'||
              to_char(date_value)||':');
          Wf_Item_Activity_Status.Set_Error(itemtype,
              itemkey, actid, wf_engine.eng_exception, FALSE);
          Wf_Engine_Util.Execute_Error_Process(itemtype,
              itemkey, actid, wf_engine.eng_exception);
          Wf_Core.Clear;
      end;
   elsif (upper(command) = wf_engine.eng_error) then

      -- Set the error status
      Wf_Item_Activity_Status.Set_Error(itemtype, itemkey, actid,
          wf_engine.eng_mail, FALSE);
      -- Run any error process for the activity
      Wf_Engine_Util.Execute_Error_Process(itemtype, itemkey, actid,
          wf_engine.eng_mail);
   elsif (upper(command) = 'TESTCTX') then
     -- Call selector function in test mode
     -- Return true if result is either true or null (means context
     -- test not implemented)
     result := Wf_Engine_Util.Execute_Selector_Function(itemtype,
                   itemkey, wf_engine.eng_testctx);
     text_value := nvl(result, 'TRUE');
   elsif (upper(command) = 'SETCTX') then
     -- Call selector function in set mode
     result := Wf_Engine_Util.Execute_Selector_Function(itemtype,
                   itemkey, wf_engine.eng_setctx);
   elsif (upper(command) in ('FORWARD', 'TRANSFER', 'RESPOND',
                             'ANSWER', 'QUESTION', 'VALIDATE')) then
     -- FORWARD/TRANSFER/RESPOND/ANSWER/QUESTION/VALIDATE
     -- Look for a notification callback function to execute.
     -- NOTES:
     -- 1. For these modes, the value buffers must pass in the expected
     --    expected values:
     --      text_value = recipient_role (null for RESPOND)
     --      number_value = notification_id
     -- 2. The callback function will raise an exception if the
     --    operation isn't allowed.  If so, allow the exception to raise
     --    up to the calling function.

     Wf_Engine_Util.Execute_Notification_Callback(command, itemtype,
         itemkey, actid, number_value, text_value);

     -- For TRANSFER, FORWARD and RESPOND modes only, reset the assigned user, but only
     -- if not a voting activity
     if command in ('TRANSFER','FORWARD','RESPOND') then
       Wf_Activity.Notification_Info(itemtype, itemkey, actid,
           message, msgtype, expand_role);
       if (expand_role = 'N') then
         Wf_Item_Activity_Status.Update_Notification(itemtype, itemkey, actid,
             number_value, text_value);
       end if;
     end if;
   else
     raise wf_invalid_command;
   end if;

exception
  when wf_invalid_command then
    Wf_Core.Context('Wf_Engine', 'CB', command, context, attr_name, attr_type,
                    ':'||text_value||':'||to_char(number_value)||':'||
                    to_char(date_value)||':');
    Wf_Core.Token('COMMAND', command);
    Wf_Core.Raise('WFSQL_COMMAND');

  when wf_invalid_argument then
    Wf_Core.Context('Wf_Engine', 'CB', command, context, attr_name, attr_type,
                    ':'||text_value||':'||to_char(number_value)||':'||
                    to_char(date_value)||':');
    Wf_Core.Token('CONTEXT', context);
    Wf_Core.Raise('WFSQL_ARGS');

  when OTHERS then
    Wf_Core.Context('Wf_Engine', 'CB', command, context, attr_name, attr_type,
                    ':'||text_value||':'||to_char(number_value)||':'||
                    to_char(date_value)||':');
    raise;
end CB;

-- Bug 2376033
--   Transferred the logic to the overloaded CB with additional event attribute
--   parameter. This calls the new CB with event paramter as null.
-- CB (PUBLIC)
--   This is the callback function used by the notification system to
--   get and set process attributes, and mark a process complete.
--
--   The command may be one of:
--     GET - Get the value of an attribute
--     SET - Set the value of an attribute
--     COMPLETE - Mark the activity as complete
--     ERROR - Mark the activity as error status
--     TESTCTX - Test current context via selector function
--     FORWARD - Execute notification function for FORWARD
--     TRANSFER - Execute notification function for TRANSFER
--     RESPOND - Execute notification function for RESPOND
--
--   The context is in the format <itemtype>:<itemkey>:<activityid>.
--
--   The text_value/number_value/date_value fields are mutually exclusive.
--   It is assumed that only one will be used, depending on the value of
--   the attr_type argument ('VARCHAR2', 'NUMBER', or 'DATE').
--
-- IN:
--   command - Action requested.  Must be one of 'GET', 'SET', or 'COMPLETE'.
--   context - Context data in the form '<item_type>:<item_key>:<activity>'
--   attr_name - Attribute name to set/get for 'GET' or 'SET'
--   attr_type - Attribute type for 'SET'
--   text_value - Text Attribute value for 'SET'
--   number_value - Number Attribute value for 'SET'
--   date_value - Date Attribute value for 'SET'
-- OUT:
--   text_value - Text Attribute value for 'GET'
--   number_value - Number Attribute value for 'GET'
--   date_value - Date Attribute value for 'GET'
--

procedure CB(command in varchar2,
             context in varchar2,
             attr_name in varchar2,
             attr_type in varchar2,
             text_value in out NOCOPY varchar2,
             number_value in out NOCOPY number,
             date_value in out NOCOPY date)
is
  event_value wf_event_t;
begin

  Wf_Engine.CB(command, context, attr_name, attr_type, text_value, number_value, date_value, event_value);

exception
  when OTHERS then
     Wf_Core.Context('Wf_Engine', 'oldCB', command, context, attr_name, attr_type,
                    ':'||text_value||':'||to_char(number_value)||':'||
                    to_char(date_value)||':');
    raise;

end CB;

--
-- ProcessDeferred (PUBLIC)
--   Process all deferred activities
-- IN
--   itemtype - Item type to process.  If null process all item types.
--   minthreshold - Minimum cost activity to process. No minimum if null.
--   maxthreshold - Maximum cost activity to process. No maximum if null.
--
procedure ProcessDeferred(itemtype in varchar2,
                          minthreshold in number,
                          maxthreshold in number) is


begin
  wf_queue.ProcessDeferredQueue(itemtype, minthreshold, maxthreshold);
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'ProcessDeferred',itemtype,
                    to_char(minthreshold), to_char(maxthreshold));
    raise;
end ProcessDeferred;

--
-- ProcessTimeout (PUBLIC)
--  Pick up one timed out activity and execute timeout transition.
-- IN
--  itemtype - Item type to process.  If null process all item types.
--
procedure ProcessTimeOut(itemtype in varchar2)
is
  resource_busy exception;
  pragma exception_init(resource_busy, -00054);

  l_itemtype      varchar2(8);
  l_itemkey       varchar2(240);
  l_actid         pls_integer;
  pntfstatus      varchar2(8);
  pntfresult      varchar2(30);

  -- Select one timeout activity that matches itemtype
  -- NOTE: Two separate cursors are used for itemtype and no-itemtype
  -- cases to get better execution plans.


  -- select everything but completed and error.
  -- avoid "not in" which disables index in RBO
  cursor curs_itype is
    select
         S.ROWID ROW_ID
    from WF_ITEM_ACTIVITY_STATUSES S
    where S.DUE_DATE < SYSDATE
    and S.ACTIVITY_STATUS in ('ACTIVE','WAITING','NOTIFIED',
                              'SUSPEND','DEFERRED')
    and S.ITEM_TYPE = itemtype;

  cursor curs_noitype is
    select
         S.ROWID ROW_ID
    from WF_ITEM_ACTIVITY_STATUSES S
    where S.DUE_DATE < SYSDATE
    and S.ACTIVITY_STATUS in ('ACTIVE','WAITING','NOTIFIED',
                              'SUSPEND','DEFERRED');

  idarr RowidArrayTyp;
  arrsize pls_integer;
  eligible boolean;
  schema   varchar2(100);

begin
  -- Fetch eligible rows into array
  arrsize := 0;
  if (itemtype is not null) then
    -- Fetch by itemtype
    for id in curs_itype loop
      arrsize := arrsize + 1;
      idarr(arrsize) := id.row_id;
    end loop;
  else
    -- Fetch all itemtypes
    for id in curs_noitype loop
      arrsize := arrsize + 1;
      idarr(arrsize) := id.row_id;
    end loop;
  end if;

  -- Process all eligible rows found
  for i in 1 .. arrsize loop
    -- Lock row, and check if still eligible for execution
    -- To check eligibility, do original select only add rowid condition.
    -- Note ok to use no-itemtype variant since itemtype can't change
    -- and was already filtered for in original select.
    -- select everything but completed and error. avoid "not in" which
    -- disables index in RBO.
    begin
      select
        S.ITEM_TYPE, S.ITEM_KEY, S.PROCESS_ACTIVITY
      into l_itemtype, l_itemkey, l_actid
      from WF_ITEM_ACTIVITY_STATUSES S , WF_ITEMS WI
      where S.DUE_DATE < SYSDATE
      and S.ACTIVITY_STATUS in ('WAITING','NOTIFIED','SUSPEND',
                                'DEFERRED','ACTIVE')
      and S.ROWID = idarr(i)
      and WI.item_type   = S.ITEM_TYPE
      and WI.item_key    = S.ITEM_KEY
      for update of S.ACTIVITY_STATUS, WI.item_type , wi.item_key NOWAIT;

      -- check if schema matched
        schema := Wf_Engine.GetItemAttrText(l_itemtype,l_itemkey,
                    wf_engine.eng_schema, ignore_notfound=>TRUE);

      if (schema is null or
          schema = Wf_Engine.Current_Schema) then
        eligible := TRUE;
      else
        eligible := FALSE;
      end if;
    exception
      when resource_busy or no_data_found then
        -- If row already locked, or no longer eligible to run,
        -- continue on to next item in list.
        eligible := FALSE;
    end;

    if (eligible) then
      -- Set the status to COMPLETE:#TIMEOUT.
      Wf_Item_Activity_Status.Create_Status(l_itemtype, l_itemkey, l_actid,
          wf_engine.eng_completed, wf_engine.eng_timedout);

      begin
       begin
        begin
          savepoint wf_savepoint;
          -- If there is a function attached, call it in timeout mode to
          -- give the function one last chance to complete and override
          -- the timeout.
          Wf_Engine_Util.Execute_Post_NTF_Function(l_itemtype, l_itemkey,
              l_actid, wf_engine.eng_timeout, pntfstatus, pntfresult);
          if (pntfstatus = wf_engine.eng_completed) then
            -- Post-notification function found and returned a completed
            -- status.
            -- Complete activity with result of post-notification function.
            Wf_Engine_Util.Complete_Activity(l_itemtype, l_itemkey, l_actid,
                pntfresult, FALSE);
          else
            -- Either had no post-notification function, or result was still
            -- not complete.
            -- In either case, complete activity with #TIMEOUT.
            Wf_Engine_Util.Complete_Activity(l_itemtype, l_itemkey, l_actid,
                wf_engine.eng_timedout);
          end if;
        exception
          when others then
            -- If anything in this process raises an exception:
            -- 1. rollback any work in this process thread
            -- Raise an exception for the next exception handler to finish
            -- remaining steps.
            rollback to wf_savepoint;
            raise;
        end;
       exception
         when NO_SAVEPOINT then
           -- Catch any savepoint error in case of a commit happened.
           Wf_Core.Token('ACTIVITY', Wf_Engine.GetActivityLabel(l_actid));
           Wf_Core.Raise('WFENG_COMMIT_IN_COMPLETE');
       end;
      exception
        when OTHERS then
          -- Remaining steps for completing activity raises an exception:
          -- 2. set this activity to error status
          -- 3. execute the error process (if any)
          -- 4. clear the error to continue with next activity
          Wf_Core.Context('Wf_Engine', 'ProcessTimeout', l_itemkey, l_itemtype,
              to_char(l_actid));
          Wf_Item_Activity_Status.Set_Error(l_itemtype, l_itemkey, l_actid,
              wf_engine.eng_exception, FALSE);
          Wf_Engine_Util.Execute_Error_Process(l_itemtype, l_itemkey,
              l_actid, wf_engine.eng_exception);
          Wf_Core.Clear;
      end;
    end if;

    -- bug 7828862 - Resynch apps context from cached values if it changed
    wfa_sec.Restore_Ctx();

    -- For eligible row: Commit work to insure this activity
    --   thread doesn't interfere with others.
    -- For non-eligible row: Commit to release the lock.
    commit;
    Fnd_Concurrent.Set_Preferred_RBS;

  end loop;

exception
  when others then
    Wf_Core.Context('Wf_Engine', 'ProcessTimeout', l_itemkey, l_itemtype,
                    to_char(l_actid));
    raise;
end ProcessTimeOut;

--
-- ProcessStuckProcess (PUBLIC)
--   Pick up one stuck process, mark error status, and execute error process.
-- IN
--   itemtype - Item type to process.  If null process all item types.
--
procedure ProcessStuckProcess(itemtype in varchar2)
is
  resource_busy exception;
  pragma exception_init(resource_busy, -00054);

  l_itemtype varchar2(8);
  l_itemkey varchar2(240);
  l_actid pls_integer;

  -- Select all activities from WIAS where:
  -- 1. Activity is a PROCESS activity
  -- 2. Activity has ACTIVE status
  -- 3. Activity has no direct child activities which have a status of:
  --    (ACTIVE, NOTIFIED, DEFERRED, SUSPENDED, ERROR)
  -- 4. Item has requested itemtype (first curs only)
  -- NOTE: Two separate cursors are used for itemtype and no-itemtype
  -- cases to get better execution plans.

   cursor curs_itype is
     select /*+ ORDERED USE_NL (WIASP WI WPAP WAP)
            INDEX (WIASP WF_ITEM_ACTIVITY_STATUSES_N1) */
          WIASP.ROWID ROW_ID
     from WF_ITEM_ACTIVITY_STATUSES WIASP,
          WF_ITEMS WI,
          WF_PROCESS_ACTIVITIES WPAP,
          WF_ACTIVITIES WAP
     where WIASP.ITEM_TYPE = itemtype
     and WIASP.PROCESS_ACTIVITY = WPAP.INSTANCE_ID
     and WPAP.ACTIVITY_ITEM_TYPE = WAP.ITEM_TYPE
     and WPAP.ACTIVITY_NAME = WAP.NAME
     and WIASP.ITEM_TYPE = WI.ITEM_TYPE
     and WIASP.ITEM_KEY = WI.ITEM_KEY
     and WI.BEGIN_DATE >= WAP.BEGIN_DATE
     and WI.BEGIN_DATE < nvl(WAP.END_DATE, WI.BEGIN_DATE+1)
     and WAP.TYPE = wf_engine.eng_process
     and WIASP.ACTIVITY_STATUS = 'ACTIVE' --use literal to force index
     and not exists
       (select null
       from WF_ITEM_ACTIVITY_STATUSES WIASC,
            WF_PROCESS_ACTIVITIES WPAC
       where WAP.ITEM_TYPE = WPAC.PROCESS_ITEM_TYPE
       and WAP.NAME = WPAC.PROCESS_NAME
       and WAP.VERSION = WPAC.PROCESS_VERSION
       and WPAC.INSTANCE_ID = WIASC.PROCESS_ACTIVITY
       and WIASC.ITEM_TYPE = WI.ITEM_TYPE
       and WIASC.ITEM_KEY = WI.ITEM_KEY
       and WIASC.ACTIVITY_STATUS in ('ACTIVE','NOTIFIED','SUSPEND',
                                     'DEFERRED','ERROR'));

   cursor curs_noitype is
     select /*+ ORDERED USE_NL (WIASP WI WPAP WAP)
                INDEX (WIASP WF_ITEM_ACTIVITY_STATUSES_N1) */
            WIASP.ROWID ROW_ID
     from   WF_ITEM_ACTIVITY_STATUSES WIASP,
            WF_ITEMS WI,
            WF_PROCESS_ACTIVITIES WPAP,
            WF_ACTIVITIES WAP
      where WIASP.PROCESS_ACTIVITY = WPAP.INSTANCE_ID
      and   WPAP.ACTIVITY_ITEM_TYPE = WAP.ITEM_TYPE
      and   WPAP.ACTIVITY_NAME = WAP.NAME
      and   WIASP.ITEM_TYPE = WI.ITEM_TYPE
      and   WIASP.ITEM_KEY = WI.ITEM_KEY
      and   WI.BEGIN_DATE >= WAP.BEGIN_DATE
      and   WI.BEGIN_DATE < nvl(WAP.END_DATE, WI.BEGIN_DATE+1)
      and   WAP.TYPE = 'PROCESS'
      and   WIASP.ACTIVITY_STATUS = 'ACTIVE' --use literal to force index
      and not exists
        (select null
          from  WF_ITEM_ACTIVITY_STATUSES WIASC,
                WF_PROCESS_ACTIVITIES WPAC
          where WAP.ITEM_TYPE = WPAC.PROCESS_ITEM_TYPE
          and   WAP.NAME = WPAC.PROCESS_NAME
          and   WAP.VERSION = WPAC.PROCESS_VERSION
          and   WPAC.INSTANCE_ID = WIASC.PROCESS_ACTIVITY
          and   WIASC.ITEM_TYPE = decode(wap.direction,
                                         wap.direction, WI.ITEM_TYPE,
                                         wi.item_type)
          and   WIASC.ITEM_KEY = WI.ITEM_KEY
          and   WIASC.ACTIVITY_STATUS in ('ACTIVE', 'NOTIFIED', 'SUSPEND',
                                          'DEFERRED', 'ERROR'));


  idarr RowidArrayTyp;
  arrsize pls_integer;
  eligible boolean;

begin

  -- Fetch eligible rows into array
  arrsize := 0;
  if (itemtype is not null) then
    -- Fetch by itemtype
    for id in curs_itype loop
      arrsize := arrsize + 1;
      idarr(arrsize) := id.row_id;
    end loop;
  else
    -- Fetch all itemtypes
    for id in curs_noitype loop
      arrsize := arrsize + 1;
      idarr(arrsize) := id.row_id;
    end loop;
  end if;

  -- Process all eligible rows found
  for i in 1 .. arrsize loop
    -- Lock row, and check if still eligible for execution
    -- To check for eligibility, check that:
    -- 1. Activity is a PROCESS activity
    -- 2. Activity has ACTIVE status
    -- 3. Activity has no direct child activities which have a status of:
    --    (ACTIVE, NOTIFIED, DEFERRED, SUSPENDED, ERROR)
    -- 4. Item has requested itemtype (first curs only)
    begin
      select
           WIASP.ITEM_TYPE, WIASP.ITEM_KEY, WIASP.PROCESS_ACTIVITY
      into l_itemtype, l_itemkey, l_actid
      from WF_ITEM_ACTIVITY_STATUSES WIASP,
           WF_PROCESS_ACTIVITIES WPAP,
           WF_ACTIVITIES WAP,
           WF_ITEMS WI
      where WIASP.PROCESS_ACTIVITY = WPAP.INSTANCE_ID
      and WPAP.ACTIVITY_ITEM_TYPE = WAP.ITEM_TYPE
      and WPAP.ACTIVITY_NAME = WAP.NAME
      and WIASP.ITEM_TYPE = WI.ITEM_TYPE
      and WIASP.ITEM_KEY = WI.ITEM_KEY
      and WI.BEGIN_DATE >= WAP.BEGIN_DATE
      and WI.BEGIN_DATE < nvl(WAP.END_DATE, WI.BEGIN_DATE+1)
      and WAP.TYPE = wf_engine.eng_process
      and WIASP.ACTIVITY_STATUS = 'ACTIVE' --use literal to force index
      and not exists
        (select null
        from WF_ITEM_ACTIVITY_STATUSES WIASC,
             WF_PROCESS_ACTIVITIES WPAC
        where WAP.ITEM_TYPE = WPAC.PROCESS_ITEM_TYPE
        and WAP.NAME = WPAC.PROCESS_NAME
        and WAP.VERSION = WPAC.PROCESS_VERSION
        and WPAC.INSTANCE_ID = WIASC.PROCESS_ACTIVITY
        and WIASC.ITEM_TYPE = WI.ITEM_TYPE
        and WIASC.ITEM_KEY = WI.ITEM_KEY
        and WIASC.ACTIVITY_STATUS in ('ACTIVE','NOTIFIED','SUSPEND',
                                      'DEFERRED','ERROR'))
      and WIASP.ROWID = idarr(i)
      for update of WIASP.ACTIVITY_STATUS, WI.ITEM_TYPE ,WI.ITEM_KEY NOWAIT;

      eligible := TRUE;
    exception
      when resource_busy or no_data_found then
        -- If row already locked, or no longer eligible to run,
        -- continue on to next item in list.
        eligible := FALSE;
    end;

    if (eligible) then
      -- Set the status to ERROR:#STUCK
      Wf_Item_Activity_Status.Create_Status(l_itemtype, l_itemkey, l_actid,
          wf_engine.eng_error, wf_engine.eng_stuck);

      -- Execute the error process for stuck process
      begin
       begin
        begin
          savepoint wf_savepoint;
          Wf_Engine_Util.Execute_Error_Process(l_itemtype, l_itemkey, l_actid,
              wf_engine.eng_stuck);
        exception
          when others then
          -- If anything in this process raises an exception:
          -- 1. rollback any work in this process thread
          -- Raise an exception for the next exception handler to finish
          -- remaining steps.
          rollback to wf_savepoint;
          raise;
        end;
       exception
         when NO_SAVEPOINT then
           -- Catch any savepoint error in case of a commit happened.
           Wf_Core.Token('ACTIVITY', Wf_Engine.GetActivityLabel(l_actid));
           Wf_Core.Raise('WFENG_COMMIT_IN_ERRPROC');
       end;
      exception
        when OTHERS then
          -- Remaining steps for completing activity raises an exception:
          -- 2. set this activity to error status
          -- 3. execute the error process (if any)
          -- 4. clear the error to continue with next activity
          Wf_Core.Context('Wf_Engine', 'ProcessStuckProcess', l_itemkey,
              l_itemtype, to_char(l_actid));
          Wf_Item_Activity_Status.Set_Error(l_itemtype, l_itemkey, l_actid,
              wf_engine.eng_exception, FALSE);
          Wf_Engine_Util.Execute_Error_Process(l_itemtype, l_itemkey,
              l_actid, wf_engine.eng_exception);
          Wf_Core.Clear;
      end;

      -- Commit work to insure this activity thread doesn't interfere
      -- with others.
      commit;

      Fnd_Concurrent.Set_Preferred_RBS;

    end if;
  end loop;

exception
  when others then
     Wf_Core.Context('Wf_Engine', 'ProcessStuckProcess', l_itemkey, l_itemtype,
                    to_char(l_actid));
    raise;
end ProcessStuckProcess;

--
-- Background (PUBLIC)
--  Process all current deferred and/or timeout activities within
--  threshold limits.
-- IN
--   itemtype - Item type to process.  If null process all item types.
--   minthreshold - Minimum cost activity to process. No minimum if null.
--   maxthreshold - Maximum cost activity to process. No maximum if null.
--   process_deferred - Run deferred or waiting processes
--   process_timeout - Handle timeout errors
--   process_stuck - Handle stuck process errors
--
procedure Background (itemtype         in varchar2,
                      minthreshold     in number,
                      maxthreshold     in number,
                      process_deferred in boolean,
                      process_timeout  in boolean,
                      process_stuck    in boolean)
is
l_aq_tm_processes       varchar2(512);
begin
  WF_CORE.TAG_DB_SESSION(WF_CORE.CONN_TAG_WF, Background.itemtype);
  if (WF_CACHE.MetaRefreshed) then
    null;

  end if;

  --Bug 3945469: Add check on db major version and cache value for aq_tm_processes
  if wf_core.g_oracle_major_version is null then
      wf_core.InitCache;
  end if;

  --Check the value of aq_tm_processes if oracle version is not 10g
  if (wf_core.g_oracle_major_version < 10 ) then
     if (wf_core.g_aq_tm_processes ='0') then
        --If the value aq_tm_processes is 0 then raise error
        wf_core.raise('WFENG_AQ_TM_PROCESSES_ERROR');
     end if;
  end if;

  --Bug 2307428
  --Enable the deferred and inbound queues.
  wf_queue.Enablebackgroundqueues;

  -- Do not need to preserve context
  wf_engine.preserved_context := FALSE;

  -- bug 7828862 Cache Apps context before starting to process any type
  wfa_sec.Cache_Ctx();

  -- Process deferred activities
  if (process_deferred) then
    -- process the inbound queue first - it may place events on the deferred Q
    wf_queue.ProcessInboundQueue(itemtype);
    wf_engine.ProcessDeferred(itemtype, minthreshold, maxthreshold);
  end if;

  -- Process timeout activities
  if (process_timeout) then
    wf_engine.ProcessTimeout(itemtype);
  end if;

  -- Process stuck activities
  if (process_stuck) then
    wf_engine.ProcessStuckProcess(itemtype);
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Engine', 'Background', itemtype,
                    to_char(minthreshold), to_char(maxthreshold));
    -- Restore Apps Context
    wfa_sec.Restore_Ctx();
    raise;
end Background;

--
-- BackgroundConcurrent (PUBLIC)
--  Run background process for deferred and/or timeout activities
--  from Concurrent Manager.
--  This is a cover of Background() with different argument types to
--  be used by the Concurrent Manager.
-- IN
--   errbuf - CPM error message
--   retcode - CPM return code (0 = success, 1 = warning, 2 = error)
--   itemtype - Item type to process.  If null process all item types.
--   minthreshold - Minimum cost activity to process. No minimum if null.
--   maxthreshold - Maximum cost activity to process. No maximum if null.
--   process_deferred - Run deferred or waiting processes
--   process_timeout - Handle timeout errors
--   process_stuck - Handle stuck process errors
--
procedure BackgroundConcurrent (
    errbuf out NOCOPY varchar2,
    retcode out NOCOPY varchar2,
    itemtype in varchar2,
    minthreshold in varchar2,
    maxthreshold in varchar2,
    process_deferred in varchar2,
    process_timeout in varchar2,
    process_stuck in varchar2)
is
  minthreshold_num number;
  maxthreshold_num number;
  process_deferred_bool boolean;
  process_timeout_bool boolean;
  process_stuck_bool boolean;

  errname varchar2(30);
  errmsg varchar2(2000);
  errstack varchar2(4000);
begin
  -- Convert arguments from varchar2 to real type.
  minthreshold_num := to_number(minthreshold);
  maxthreshold_num := to_number(maxthreshold);

  if (upper(substr(process_deferred, 1, 1)) = 'Y') then
    process_deferred_bool := TRUE;
  else
    process_deferred_bool := FALSE;
  end if;

  if (upper(substr(process_timeout, 1, 1)) = 'Y') then
    process_timeout_bool := TRUE;
  else
    process_timeout_bool := FALSE;
  end if;

  if (upper(substr(process_stuck, 1, 1)) = 'Y') then
    process_stuck_bool := TRUE;
  else
    process_stuck_bool := FALSE;
  end if;

  -- Call background engine with new args
  Wf_Engine.Background(
    itemtype,
    minthreshold_num,
    maxthreshold_num,
    process_deferred_bool,
    process_timeout_bool,
    process_stuck_bool);

  -- Return 0 for successful completion.
  errbuf := '';
  retcode := '0';

exception
  when others then
    -- Retrieve error message into errbuf
    wf_core.get_error(errname, errmsg, errstack);
    if (errmsg is not null) then
      errbuf := errmsg;
    else
      errbuf := sqlerrm;
    end if;

    -- Return 2 for error.
    retcode := '2';
end BackgroundConcurrent;

--
-- CreateProcess (PUBLIC)
--   Create a new runtime process (for an application item).
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--   process  - A valid root process for this item type
--              (or null to use the item's selector function)
--
procedure CreateProcess(itemtype in varchar2,
                        itemkey  in varchar2,
                        process  in varchar2,
                        user_key in varchar2,
                        owner_role in varchar2)
is
  root varchar2(30);
  version number;
  actdate date;
  typ varchar2(8);
  rootid pls_integer;
  status varchar2(8);
  l_event wf_event_t;  -- Buffer for initing event itemattrs

  -- All event item attrs to be initialized
  -- Initialization is now deferred until GetItemAttrEvent
/*  cursor evtcurs is
    select WIA.NAME
    from WF_ITEM_ATTRIBUTES WIA
    where WIA.ITEM_TYPE = CreateProcess.itemtype
    and WIA.TYPE = 'EVENT';*/

begin
  -- Argument validation
  if ((itemtype is null) or (itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', itemtype);
    Wf_Core.Token('ITEMKEY', itemkey);
    Wf_Core.Token('PROCESS', process);
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  --<rwunderl:4198524>
  if (WF_CACHE.MetaRefreshed) then
    null;
  end if;

  -- Check for duplicate item
  if (itemkey = wf_engine.eng_synch) then
    if (Wf_Item.Item_Exist(itemtype, itemkey)) then
      -- SYNCHMODE:  If duplicate is a synch process, check the status
      -- of the root process of the existing item.
      -- If the cached item is already complete, then it is ok to
      -- toss out the old item and create a new one.
      begin
        Wf_Item.Root_Process(itemtype, itemkey, root, version);
        rootid := Wf_Process_Activity.RootInstanceId(itemtype,
                         itemkey, root);
        Wf_Item_Activity_Status.Status(itemtype, itemkey, rootid, status);
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
  else
    -- Not synchmode.  Clear plsql cache first, just in case previous
    -- item was purged/rolled back, then check for duplicate.
    Wf_Item.ClearCache;
    if (Wf_Item.Item_Exist(itemtype, itemkey)) then
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Raise('WFENG_ITEM_UNIQUE');
    end if;
  end if;

  if (process is null) then
    -- Call the selector function to get the process
    root := Wf_Engine_Util.Get_Root_Process(itemtype, itemkey);
    if (root is null) then
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Raise('WFENG_ITEM_ROOT_SELECTOR');
    end if;
  else
    root := process;
  end if;

  -- Check that the root argument is a valid process.
  -- NOTE: The check that the process exists must be done BEFORE
  -- calling create_item to avoid foreign key problems during the insert.
  -- The check that the process is runnable can't be done until AFTER
  -- create_item so the date has been established.
  actdate := sysdate;
  typ := Wf_Activity.Type(itemtype, root, actdate);
  if ((typ is null) or (typ <> wf_engine.eng_process)) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('NAME', root);
    Wf_Core.Raise('WFENG_PROCESS_NAME');
  end if;

  -- Insert row in items table
  Wf_Item.Create_Item(itemtype, itemkey, root, actdate, createprocess.user_key,
                      createprocess.owner_role);

  -- Validate the root argument is runnable
  rootid := Wf_Process_Activity.RootInstanceId(itemtype, itemkey,
                                                  root);
  if (rootid is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('NAME', root);
    Wf_Core.Raise('WFENG_PROCESS_RUNNABLE');
  end if;

  if (itemkey <> WF_ENGINE.eng_synch) then
    -- Create monitor access key attributes
    Wf_Engine.AddItemAttr(itemtype, itemkey, wf_engine.wfmon_mon_key,
        Wf_Core.Random);
    Wf_Engine.AddItemAttr(itemtype, itemkey, wf_engine.wfmon_acc_key,
        Wf_Core.Random);
  end if;

  -- Create a schema attribute
  Wf_Engine.AddItemAttr(itemtype, itemkey, wf_engine.eng_schema,
      Wf_Engine.Current_Schema);

  -- Initialize all EVENT-type item attributes
  -- Not done here, it is deferred until GetItemAttrEvent
 /* for evtattr in evtcurs loop
    Wf_Event_T.Initialize(l_event);
    Wf_Engine.SetItemAttrEvent(
      itemtype => itemtype,
      itemkey => itemkey,
      name => evtattr.name,
      event => l_event);
  end loop;*/

exception
  when others then
    -- Bug 4117740
    -- Call clearcache() when #SYNCH flow is in error
    if ((itemkey = WF_ENGINE.eng_synch) and
        (wf_core.error_name is null or wf_core.error_name <> 'WFENG_SYNCH_ITEM') and
        (not WF_ENGINE.debug)) then
      Wf_Item.ClearCache;
    end if;

      Wf_Core.Context('Wf_Engine', 'CreateProcess', itemtype, itemkey, process);
    raise;
end CreateProcess;

--
-- StartProcess (PUBLIC)
--   Begins execution of the process. The process will be identified by the
--   itemtype and itemkey.  The engine locates the starting activities
--   of the root process and executes them.
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--
procedure StartProcess(itemtype in varchar2,
                       itemkey  in varchar2)
is
begin
  WF_CORE.TAG_DB_SESSION(WF_CORE.CONN_TAG_WF, StartProcess.itemtype);

  if (WF_CACHE.MetaRefreshed) then
    null;
  end if;
  --Bug 2259039
  Wf_Engine_Util.Start_Process_Internal(
    itemtype=> itemtype,
    itemkey => itemkey,
    runmode => 'START');
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'StartProcess', itemtype, itemkey);
    raise;
end StartProcess;

--
-- LaunchProcess (PUBLIC)
--   Launch a process both creates and starts it.
--   This is a wrapper for friendlier UI
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--   process  - A valid root process for this item type
--              (or null to use the item's selector function)
--   userkey - User key to be set
--   owner - Role designated as owner of the item
--
procedure LaunchProcess(itemtype in varchar2,
                        itemkey  in varchar2,
                        process  in varchar2,
                        userkey  in varchar2,
                        owner    in varchar2) is

begin
  -- Check Arguments
  if ((itemtype is null) or
      (itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  end if;

  wf_engine.CreateProcess (itemtype,itemkey,process);

  if userkey is not null then
    wf_engine.SetItemUserKey(itemtype,itemkey,userkey);
  end if;

  if owner is not null then
    wf_engine.SetItemOwner(itemtype,itemkey,owner);
  end if;

  wf_engine.StartProcess (itemtype,itemkey);
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'LaunchProcess', itemtype, itemkey,
        process, userkey, owner);
    raise;
end LaunchProcess;

--
-- SuspendProcess (PUBLIC)
--   Suspends process execution, meaning no new transitions will occur.
--   Outstanding notifications will be allowed to complete, but they will not
--   cause activity transitions. If the process argument is null, the root
--   process for the item is suspended, otherwise the named process is
--   suspended.
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--   process  - Process to suspend, specified in the form
--              [<parent process_name>:]<process instance_label>
--              If null suspend the root process.
--
procedure SuspendProcess(itemtype in varchar2,
                         itemkey  in varchar2,
                         process  in varchar2) is

  root varchar2(30);   -- The root process for this item key
  version pls_integer; -- Root process version
  rootid pls_integer;  -- Instance id of root process
  actdate date;        -- Active date of item
  proc varchar2(61);   -- The process name that is going to be suspended
  procid pls_integer;  -- The process id that is going to be suspended
  status varchar2(8);  -- The status of the process

  -- Cursor to select deferred activities to remove from background queue
  cursor defact is
    select PROCESS_ACTIVITY, BEGIN_DATE
    from  WF_ITEM_ACTIVITY_STATUSES
    where ITEM_TYPE = itemtype
    and   ITEM_KEY = itemkey
    and   ACTIVITY_STATUS = wf_engine.eng_deferred;

begin
  -- Check Arguments
  if (itemtype is null) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  -- Not allowed in synch mode
  elsif (itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.SuspendProcess');
    wf_core.raise('WFENG_SYNCH_DISABLED');

  elsif (itemkey is null) then
    WF_ENGINE.SuspendAll(itemtype, process); --</rwunderl:1833759>
    return;

  end if;

  -- Get the root process for this key and also validate the item
  Wf_Item.Root_Process(itemtype, itemkey, root, version);
  if (root is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');
  end if;

  -- Get the process instance id.
  -- Search the process beginnning at the root process of the item for the
  -- activity matching process.
  actdate := Wf_Item.Active_Date(itemtype, itemkey);
  rootid := Wf_Process_Activity.RootInstanceId(itemtype, itemkey, root);
  if (rootid is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('NAME', root);
    Wf_Core.Raise('WFENG_ITEM_ROOT');
  end if;

  if (process is null) then
    -- Suspend the root process
    proc := root;
    procid := rootid;
  else
    -- Suspend the given process
    proc := process;
    procid := Wf_Process_Activity.FindActivity(rootid, proc, actdate);
    if (procid is null) then
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Token('NAME', proc);
      Wf_Core.Token('VERSION', to_char(version));
      Wf_Core.Raise('WFENG_ITEM_PROCESS');
    end if;

    -- Check that activity is a PROCESS-type.
    -- Only PROCESS activities may be suspended.
    if (Wf_Activity.Instance_Type(procid, actdate) <>
        wf_engine.eng_process) then
      Wf_Core.Token('NAME', proc);
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Raise('WFENG_PROCESS_NAME');
    end if;
  end if;

  -- Always clear the cache first
  -- AbortProcess, SuspendProcess and ResumeProcess should be rarely called
  -- from the background engine, so it should be safe to force reading from
  -- the database.
  Wf_Item_Activity_Status.ClearCache;

  -- Check if the process is active
  Wf_Item_Activity_Status.Status(itemtype, itemkey, procid, status);

  if (status is null) then
    -- This process has not been run yet. Create a pre-suspended
    -- status row so engine does not run process later
    Wf_Item_Activity_Status.Create_Status(itemtype, itemkey, procid,
        wf_engine.eng_suspended, wf_engine.eng_null, null, null,
        newStatus=>TRUE);
  elsif (status = wf_engine.eng_deferred) then
    -- Change status from 'deferred' to 'suspended'
    -- Doing this prevents the background processor from picking it up.
    Wf_Item_Activity_Status.Create_Status(itemtype, itemkey, procid,
                                          wf_engine.eng_suspended, null,
                                          null, null);
  elsif (status = wf_engine.eng_active) then
    -- Mark process as 'suspended', 'null' in WIAS table
    -- Doing this stops the engine from going through the rest of the flow
    Wf_Item_Activity_Status.Create_Status(itemtype, itemkey, procid,
                                          wf_engine.eng_suspended, null,
                                          null, null);

    -- Suspend all the children processes
    Wf_Engine_Util.Suspend_Child_Processes(itemtype, itemkey, procid);
  else
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('NAME', proc);
    Wf_Core.Raise('WFENG_ITEM_PROCESS_ACTIVE');
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Engine', 'SuspendProcess', itemtype, itemkey, process);
    raise;
end SuspendProcess;

--
-- AbortProcess (PUBLIC)
--   Abort process execution. Outstanding notifications are canceled. The
--   process is then considered complete, with a status specified by the
--   result argument.
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--   process  - Process to abort, specified in the form
--              [<parent process_name>:]<process instance_label>
--              If null abort the root process.
--   result   - Result to complete process with
--   verify_lock - This boolean param determines whether we should lock
--                 the item before processing or not . This would control
--                 concurrent execution contention.
--   cascade  - This boolean param determines if the process should be
--              aborted in cascade or not, ie kill all child processes
--              to this process.
--
procedure AbortProcess(itemtype in varchar2,
                       itemkey  in varchar2,
                       process  in varchar2,
                       result   in varchar2,
		       verify_lock in boolean,
		       cascade  in boolean) is

  root varchar2(30);   -- The root process for this item key
  version pls_integer; -- Root process version
  rootid pls_integer;  -- Instance id of root process
  actdate date;        -- Active date of item
  proc varchar2(61);   -- Process name
  procid pls_integer;  -- The process id that is going to be suspended
  status varchar2(8);  -- The status of the process
  dummy  pls_integer;  -- Added for bug 1893606 - JWSMITH

  --Bug 1166527
  l_parameterlist        wf_parameter_list_t := wf_parameter_list_t();

  l_lock    boolean;
  cursor openNotifications is  -- <7513983>
     SELECT wn.notification_id
     FROM   wf_notifications wn, WF_ITEM_ACTIVITY_STATUSES ias
     WHERE  ias.item_type = itemtype
     AND    ias.item_key = itemkey
     AND    ias.notification_id is not null
     AND    ias.notification_id = wn.group_id
     AND    wn.status = 'OPEN'
     UNION
     SELECT wn.notification_id
     FROM   wf_notifications wn, WF_ITEM_ACTIVITY_STATUSES_H iash
     WHERE  iash.item_type = itemtype
     AND    iash.item_key = itemkey
     AND    iash.notification_id is not null
     AND    iash.notification_id = wn.notification_id
     AND    wn.status = 'OPEN';     -- </7513983>

begin
  -- Check Arguments
  if (itemtype is null) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  elsif (itemkey = wf_engine.eng_synch) then -- Not allowed in synch mode
    wf_core.token('OPERATION', 'Wf_Engine.AbortProcess');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  --Do the check for lock ONLY if there is an explicit
  --request for the same.
  if verify_lock then
    --Check if we can acquire lock for the
    --the item type/key here
    l_lock := wf_item.acquire_lock(itemtype,itemkey,true) ;
  end if;

  -- Get the root process for this key and also validate the item
  Wf_Item.Root_Process(itemtype, itemkey, root, version);
  if (root is null) then
    Wf_Core.Context('Wf_Engine', 'AbortProcess', itemtype, itemkey, process);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');
  end if;

  -- Get the process instance id.
  -- Search the process beginnning at the root process of the item for the
  -- activity matching process.
  actdate := Wf_Item.Active_Date(itemtype, itemkey);
  rootid := Wf_Process_Activity.RootInstanceId(itemtype, itemkey, root);
  if (rootid is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('NAME', root);
    Wf_Core.Raise('WFENG_ITEM_ROOT');
  end if;

  if (process is null) then
    -- Abort the root process
    proc := root;
    procid := rootid;
  else
    -- Abort the given process
    proc := process;
    procid := Wf_Process_Activity.FindActivity(rootid, process, actdate);
    if (procid is null) then
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Token('NAME', process);
      Wf_Core.Token('VERSION', to_char(version));
      Wf_Core.Raise('WFENG_ITEM_PROCESS');
    end if;

    -- Check that activity is a PROCESS-type.
    -- Only PROCESS activities may be aborted.
    if (Wf_Activity.Instance_Type(procid, actdate) <>
        wf_engine.eng_process) then
      Wf_Core.Token('NAME', proc);
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Raise('WFENG_PROCESS_NAME');
    end if;
  end if;

  -- Always clear the cache first
  Wf_Item_Activity_Status.ClearCache;

  -- Check the process is not already complete
  Wf_Item_Activity_Status.Status(itemtype, itemkey, procid, status);

  if (status is null) then
    if (WF_ITEM.SetEndDate(itemtype, itemkey) = 1) then
      Wf_Core.Token('TYPE', itemtype);
      Wf_core.Token('KEY', itemkey);
      Wf_core.Token('NAME', proc);
      Wf_Core.Raise('WFENG_ITEM_PROCESS_RUNNING');
    end if;

  elsif (status = wf_engine.eng_completed) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('NAME', proc);
    Wf_Core.Raise('WFENG_ITEM_PROCESS_ACTIVE');
  else
    -- Mark process as 'COMPLETE', 'result' in WIAS table
    -- Doing this stops the engine from going through the rest of the flow
    Wf_Item_Activity_Status.Create_Status(itemtype, itemkey, procid,
                                          wf_engine.eng_completed, result,
                                          null, SYSDATE);

    -- Kill child activities recursively
    Wf_Engine_Util.Process_Kill_Children(itemtype, itemkey, procid);
    --If cascade option is set to true abort all child
    --processes aswell
    if cascade then
       Wf_Engine_Util.Process_Kill_ChildProcess(itemtype, itemkey);
    end if;
  end if;

  --Cancel any OPEN FYI notifications
  for nid in openNotifications
  loop
     wf_notification.cancel(nid.notification_id,' ');
  end loop;

  --Include the information of the aborted process in the events
  --parameter list.
  wf_event.AddParameterToList('ITMETYPE', itemtype, l_parameterlist);
  wf_event.AddParameterToList('ITEMKEY', itemkey, l_parameterlist);
  wf_event.AddParameterToList('PROCESS', process, l_parameterlist);
  wf_event.AddParameterToList('RESULT', result, l_parameterlist);

  -- Raise the event
  wf_event.Raise(p_event_name => 'oracle.apps.wf.engine.abort',
                 p_event_key  => itemkey,
                 p_parameters => l_parameterlist);

exception
  when resource_busy then
    wf_core.token('TYPE',itemtype);
    wf_core.token('KEY',itemkey);
    wf_core.raise('WFENG_RESOURCE_BUSY');

  when others then
    Wf_Core.Context('Wf_Engine', 'AbortProcess', itemtype, itemkey,
                    process, result);
    raise;
end AbortProcess;

--
-- ResumeProcess (PUBLIC)
--   Returns a process to normal execution status. Any transitions which
--   were deferred by SuspendProcess() will now be processed.
-- IN
--   itemtype   - A valid item type
--   itemkey    - A string generated from the application object's primary key.
--   process  - Process to resume, specified in the form
--              [<parent process_name>:]<process instance_label>
--              If null resume the root process.
--
procedure ResumeProcess(itemtype in varchar2,
                        itemkey  in varchar2,
                        process  in varchar2)
is
  root varchar2(30);   -- The root process for this item key
  version pls_integer; -- Root process version
  rootid pls_integer;  -- Instance id of root process
  actdate date;        -- Active date of item
  proc varchar2(61);   -- The process name that is going to be suspended
  procid pls_integer;  -- The process id that is going to be suspended
  status varchar2(8);  -- The status of the process

  -- Cursor to select deferred activities to restart.
  cursor defact is
    select
    PROCESS_ACTIVITY, BEGIN_DATE
    from WF_ITEM_ACTIVITY_STATUSES
    where ITEM_TYPE = itemtype
    and ITEM_KEY = itemkey
    and ACTIVITY_STATUS = wf_engine.eng_deferred;

  actidarr InstanceArrayTyp;  -- Deferred activities array
  i pls_integer := 0;         -- Counter for the for loop

  trig_savepoint exception;
  pragma exception_init(trig_savepoint, -04092);
  dist_savepoint exception;
  pragma exception_init(dist_savepoint, -02074);
  --Bug 2484201
  --Array to select the begin_date for the deferred activities
  type InstanceDateArray is table of date index by binary_integer;
  act_begin_date  InstanceDateArray;
begin
  WF_CORE.TAG_DB_SESSION(WF_CORE.CONN_TAG_WF, ResumeProcess.itemtype);

  -- Check Arguments
  if (itemtype is null) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  elsif (itemkey = wf_engine.eng_synch) then -- Not allowed in synch mode
    wf_core.token('OPERATION', 'Wf_Engine.ResumeProcess');
    wf_core.raise('WFENG_SYNCH_DISABLED');

  elsif (itemkey is NULL) then
    WF_ENGINE.ResumeAll(itemtype, process); --</rwunderl:1833759>
    return;

  end if;

  -- Get the root process for this key
  Wf_Item.Root_Process(itemtype, itemkey, root, version);
  if (root is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');
  end if;

  -- Get the process instance id.
  -- Search the process beginnning at the root process of the item for the
  -- activity matching process.
  actdate := Wf_Item.Active_Date(itemtype, itemkey);
  rootid := Wf_Process_Activity.RootInstanceId(itemtype, itemkey, root);
  if (rootid is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('NAME', root);
    Wf_Core.Raise('WFENG_ITEM_ROOT');
  end if;

  if (process is null) then
    -- Resume the root process
    proc := root;
    procid := rootid;
  else
    -- Resume the given process
    proc := process;
    procid := Wf_Process_Activity.FindActivity(rootid, process, actdate);
    if (procid is null) then
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Token('NAME', process);
      Wf_Core.Token('VERSION', to_char(version));
      Wf_Core.Raise('WFENG_ITEM_PROCESS');
    end if;

    -- Check that activity is a PROCESS-type.
    -- Only PROCESS activities may be resumed.
    if (Wf_Activity.Instance_Type(procid, actdate) <>
        wf_engine.eng_process) then
      Wf_Core.Token('NAME', proc);
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Raise('WFENG_PROCESS_NAME');
    end if;
  end if;

  -- Always clear the cache first
  Wf_Item_Activity_Status.ClearCache;

  -- Check if the process is suspended
  Wf_Item_Activity_Status.Status(itemtype, itemkey, procid, status);
  if (status is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('NAME', proc);
    Wf_Core.Raise('WFENG_ITEM_PROCESS_RUNNING');
  elsif (status <> wf_engine.eng_suspended) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('NAME', proc);
    Wf_Core.Raise('WFENG_ITEM_PROCESS_SUSPENDED');
  else
    -- If we came here, that means the process is currently suspended.
    -- Mark process as eng_active 'active', 'null' in WIAS table
    Wf_Item_Activity_Status.Create_Status(itemtype, itemkey, procid,
        wf_engine.eng_active, null, null, null);

    -- Mark any sub-processes as active again
    Wf_Engine_Util.Resume_Child_Processes(itemtype, itemkey, procid);

    -- Restart any activities that were deferred because completion
    -- came in while process was suspended.
    --
    -- Note that cursor will select all deferred activities, even if they
    -- were deferred for other reasons than suspended process, but this is
    -- OK because:
    -- 1. Activities deferred because cost is higher than threshold will
    --    be immediately re-deferred by process_activity()
    -- 2. Deferred activities that are not in the sub-process just resumed
    --    will still have a suspended parent, and will also be immediately
    --    re-deferred by process_activity().
    -- This causes a little extra processing in rare cases, but is easier
    -- than figuring out the cause for each deferral here.
    for actid in defact loop
      actidarr(i) := actid.process_activity;
      act_begin_date(i) := actid.begin_date;
      i := i + 1;
    end loop;
    actidarr(i) := '';

    i := 0;
    while (actidarr(i) is not null) loop
      --Bug 2484201
      --Set the begin date in call to Create_status as the begin_date
      --of the activity or to sysdate if begin_date is null
      --Also set the status to active only if begin_date <= sysdate

      if (nvl(act_begin_date(i),sysdate) <= sysdate) then
        Wf_Item_Activity_Status.Create_Status(itemtype, itemkey, actidarr(i),
                                      wf_engine.eng_active, null, sysdate, null);
        begin
          savepoint wf_savepoint;
          Wf_Engine_Util.Process_Activity(itemtype, itemkey, actidarr(i),
              Wf_Engine.Threshold, TRUE);
        exception
          when trig_savepoint or dist_savepoint then
            -- Can't restart process here, re-defer for the
            -- background process to pick up.
            Wf_Item_Activity_Status.Create_Status(itemtype, itemkey,
                 actidarr(i),wf_engine.eng_deferred, null, sysdate, null);
          when others then
            -- If anything in this process raises an exception:
            -- 1. rollback any work in this process thread
            -- 2. set this activity to error status
            -- 3. execute the error process (if any)
            -- 4. clear the error to continue with next activity
            rollback to wf_savepoint;
            Wf_Core.Context('Wf_Engine', 'ResumeProcess', itemtype, itemkey,
                process);
            Wf_Item_Activity_Status.Set_Error(itemtype, itemkey, actidarr(i),
                wf_engine.eng_exception, FALSE);
            Wf_Engine_Util.Execute_Error_Process(itemtype, itemkey, actidarr(i),
                wf_engine.eng_exception);

            Wf_Core.Clear;
        end;
         --else case status is same as right now that is deferred.
      end if;

      i := i + 1;
    end loop;
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Engine', 'ResumeProcess', itemtype, itemkey, process);
    raise;
end ResumeProcess;


--
-- SuspendAll (PUBLIC)) --</rwunderl:1833759>
--   Suspends all processes for a given itemType.
-- IN
--   itemtype - A valid itemType
--

Procedure SuspendAll (p_itemType in varchar2,
                      p_process  in varchar2) is

  cursor Open_Items(p_itemType in varchar2) is
  SELECT item_key
  FROM   wf_items
  WHERE  item_type = p_itemType
  AND    end_date is NULL;

  cursor All_Open_Items is
  SELECT item_type, item_key
  FROM   wf_items
  WHERE  end_date is NULL;

  begin

    if (p_itemType is NULL) then
      for c in All_Open_items loop
        begin
          WF_ENGINE.SuspendProcess(c.item_type, c.item_key, p_process);

        exception
          when others then
            if ( wf_core.error_name = 'WFENG_ITEM_PROCESS_ACTIVE' ) then
              wf_core.clear;

            else
              raise;

            end if;

        end;

      end loop;

    else
      for c in Open_Items(p_itemType) loop
        begin
          WF_ENGINE.SuspendProcess(p_itemType, c.item_key, p_process);

        exception
          when others then
            if ( wf_core.error_name = 'WFENG_ITEM_PROCESS_ACTIVE' ) then
              wf_core.clear;

            else
              raise;

            end if;

        end;
      end loop;

    end if;

    exception
      when others then
        Wf_Core.Context('Wf_Engine', 'SuspendAll', p_itemType, p_process);
        raise;

end SuspendAll;

--
-- ResumeAll (PUBLIC) --</rwunderl:1833759>
--   Resumes all processes for a given itemType.
-- IN
--   itemtype - A valid itemType
--
Procedure ResumeAll (p_itemType in varchar2,
                     p_process  in varchar2) is

  cursor suspended_items(p_itemType in varchar2) is
  SELECT distinct wias.item_key
  FROM   wf_item_activity_statuses wias
  WHERE  wias.item_type = p_itemType
  AND    wias.activity_status = wf_engine.eng_suspended;

  cursor all_suspended_items is
  SELECT distinct wias.item_type, wias.item_key
  FROM   wf_item_activity_statuses wias
  WHERE  wias.activity_status = wf_engine.eng_suspended;

begin

  if (p_itemType is NULL) then
   for c in all_suspended_items loop
     begin
       WF_ENGINE.ResumeProcess(c.item_type, c.item_key, p_process);

     exception
       when others then
         null;

     end;

   end loop;

  else
    for c in suspended_items(p_itemType) loop
      begin
        WF_ENGINE.ResumeProcess(p_itemType, c.item_key, p_process);

      exception
        when others then
          null;

      end;

    end loop;

  end if;

end ResumeAll;



Procedure CreateForkProcess (
     copy_itemtype  in varchar2,
     copy_itemkey   in varchar2,
     new_itemkey    in varchar2,
     same_version   in boolean,
     masterdetail   in boolean) is

root_process varchar2(30);
root_process_version number;
dummy  varchar2(30);
dummyNum number;
status varchar2(50);
result varchar2(50);
l_parent_itemType varchar2(8);
l_parent_itemKey  varchar2(240);
l_parent_context  varchar2(2000);

  ValTooLarge EXCEPTION;
  pragma exception_init(ValTooLarge, -01401);
  ValTooLargeNew EXCEPTION;
  pragma exception_init(ValTooLargeNew, -12899);

begin

  -- Argument validation
  if (copy_itemtype is null)
  or (copy_itemkey is null)
  or (new_itemkey is null) then
    Wf_Core.Token('COPY_ITEMTYPE', copy_itemtype);
    Wf_Core.Token('COPY_ITEMKEY', copy_itemkey);
    Wf_Core.Token('NEW_ITEMKEY', new_itemkey);
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- Not allowed in synch mode
  if (new_itemkey = wf_engine.eng_synch)
  or (copy_itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.SuspendProcess');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Check status
  Wf_engine.ItemStatus(copy_itemtype, copy_itemkey, status, result);
  if (status = wf_engine.eng_error) then
      Wf_Core.Raise('WFENG_NOFORK_ONERROR');
  end if;

  -- Check for duplicate item
  if (Wf_Item.Item_Exist(copy_itemtype, new_itemkey)) then
      Wf_Core.Token('TYPE', copy_itemtype);
      Wf_Core.Token('KEY', new_itemkey);
      Wf_Core.Raise('WFENG_ITEM_UNIQUE');
  end if;

  --Place row-lock on this item and retrieve parent process info:
  select parent_item_type, parent_item_key, parent_context
  into  l_parent_itemType, l_parent_itemKey, l_parent_context
  from  wf_items
  where item_type = copy_itemtype
  and   item_key = copy_itemkey
  for   update of item_type;

  --Create the process
  if same_version then
     insert into wf_items(
            ITEM_TYPE, ITEM_KEY,
            ROOT_ACTIVITY, ROOT_ACTIVITY_VERSION,
            OWNER_ROLE, USER_KEY,
            PARENT_ITEM_TYPE, PARENT_ITEM_KEY, PARENT_CONTEXT,
            BEGIN_DATE, END_DATE)
      select
            ITEM_TYPE, NEW_ITEMKEY,
            ROOT_ACTIVITY, ROOT_ACTIVITY_VERSION,
            OWNER_ROLE, USER_KEY,
            PARENT_ITEM_TYPE, PARENT_ITEM_KEY, PARENT_CONTEXT,
            BEGIN_DATE, null
     from wf_items
     where item_type = copy_itemtype
     and   item_key = copy_itemkey;
  else

     --lookup the root process
     wf_item.Root_Process(itemtype => copy_itemtype,
                          itemkey => copy_itemkey,
                          wflow => root_process,
                          version =>root_process_version);

     wf_engine.CreateProcess(copy_itemtype,new_itemkey,root_process);

     --delete any defaulted attributes because we will copy the existing ones.
     delete from wf_item_attribute_values
      where item_type = copy_itemtype
      and   item_key = new_itemkey;


   end if;

   -- copy all item attributes including runtime attributes. Also, copy
   -- those item attributes that were added after the item was forked
   insert into wf_item_attribute_values
              (ITEM_TYPE, ITEM_KEY, NAME,
               TEXT_VALUE, NUMBER_VALUE, DATE_VALUE)
   select      ITEM_TYPE, NEW_ITEMKEY, NAME,
               TEXT_VALUE, NUMBER_VALUE, DATE_VALUE
   from wf_item_attribute_values
   where item_type = copy_itemtype
   and   item_key = copy_itemkey
   and   name not like '#LBL_'
   and   name not like '#CNT_'
   union all
   select ITEM_TYPE, new_itemkey, NAME,
           TEXT_DEFAULT, NUMBER_DEFAULT, DATE_DEFAULT
   from   WF_ITEM_ATTRIBUTES
   where  ITEM_TYPE = copy_itemtype
   and    NAME not in
         (select name
          from   wf_item_attribute_values
          where  item_type = copy_itemtype
          and    item_key = copy_itemkey
          and    name not like '#LBL_'
          and    name not like '#CNT_');


  -- reset the access_keys to make them unique
  Wf_Engine.SetItemAttrText(copy_itemtype, new_itemkey,
      wf_engine.wfmon_mon_key, Wf_Core.Random);
  Wf_Engine.SetItemAttrText(copy_itemtype, new_itemkey,
      wf_engine.wfmon_acc_key, Wf_Core.Random);


  -- reset the schema, just in case, if the #SCHEMA attribute does not exist
  -- it will be added.  The CreateProcess api now adds the #SCHEMA.
  -- Only items created before WF_ENGINE was upgraded will encounter the
  -- exception to be handled, so this is for backward compatibility.

  begin
    Wf_Engine.SetItemAttrText(copy_itemtype, new_itemkey,
      wf_engine.eng_schema, Wf_Engine.Current_Schema);

  exception
    when others then
        if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
            wf_core.clear;
            WF_ENGINE.AddItemAttr(copy_itemtype, new_itemkey,
                                  wf_engine.eng_schema,
                                  Wf_Engine.Current_Schema);

        else

          raise;

        end if;

  end;

  -- Finally set an itemkey to record what this originated from
  begin
     Wf_Engine.AddItemAttr(copy_itemtype, new_itemkey, '#FORKED_FROM',
                           copy_itemkey);
     exception
        when others then
        --
        -- If item attribute already exists then ignore the error
        --
        if ( wf_core.error_name = 'WFENG_ITEM_ATTR_UNIQUE' ) then
            wf_core.clear;
            Wf_Engine.SetItemAttrText(copy_itemtype, new_itemkey,
                                      '#FORKED_FROM', copy_itemkey);
        else
            raise;
        end if;
  end;

  if (masterdetail) then
    --The caller has signaled that this is a master/detail process
    --We first will attempt to zero out any #WAITFORDETAIL attribute that may be
    --on this forked process (it is a master itself).
    dummyNum := WF_ENGINE.AddToItemAttrNumber(copy_itemType, new_itemKey,
                                              '#WAITFORDETAIL',
                                              to_number(NULL));

    if ((l_parent_itemType is NOT null) and (l_parent_itemKey is NOT null)) then
      --There is a parent item to this forked item, so we will validate and
      --increment the parent's #WAITFORDETAIL counter.
      if (WF_ENGINE.AddToItemAttrNumber(l_parent_itemType, l_parent_itemKey,
                                        '#WAITFORDETAIL', 1) is NOT null) then
        --The parent has a #WAITFORDETAIL, so we can proceed on to check for
        --parent context.
        if (l_parent_context is NOT null) then
          --There is a parent context, so we will add the #LBL_ attribute to
          --the child flow, and will increment the corresponding #CNT_ attribute
          --in the parent flow.
          begin
            WF_ENGINE.AddItemAttr(itemtype=>copy_itemType, itemkey=>new_itemkey,
                                  aname=>'#LBL_'||l_parent_context,
                                  text_value=>l_parent_context);

            --Since there was a parent context in the forked_from flow, we know
            --The parent has a counter for this label, so we can just increment.
            dummyNum := WF_ENGINE.AddToItemAttrNumber(l_parent_itemType,
                                                      l_parent_itemKey,
                                                      '#CNT_'||l_parent_context,
                                                      1);
          exception
            when ValTooLarge OR ValTooLargeNew then
              Wf_Core.Context('WF_ENGINE', 'CreateForkProcess', copy_itemtype,
                              copy_itemkey, new_itemkey, l_parent_itemtype,
                              l_parent_itemkey, l_parent_context, 'TRUE');
              WF_CORE.Token('LABEL', l_parent_context);
              WF_CORE.Token('LENGTH', 30);
              WF_CORE.Raise('WFENG_LABEL_TOO_LARGE');
          end;
        else
          -- PARENT_CONTEXT is null
          -- increase all known #CNT counter by 1
          update WF_ITEM_ATTRIBUTE_VALUES
             set NUMBER_VALUE = NUMBER_VALUE + 1
           where NAME like '#CNT_%'
             and NUMBER_VALUE is not null
             and ITEM_TYPE = l_parent_itemType
             and ITEM_KEY = l_parent_itemKey;
        end if; --PARENT_CONTEXT is not null
      end if; --#WAITFORDETAIL exists in the parent item.
    end if; --There is a parent item to this forked process.
  end if; --The caller signalled that this is a master/detail process.
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'CreateForkProcess');
    raise;
end CreateForkProcess;



--
-- StartForkProcess (PUBLIC)
--   Start a process that has been forked. Depending on the way this was
--   forked, this will execute startprocess if its to start with the latest
--   version or it copies the forked process activty by activity.
-- IN
--   itemtype  - Item type
--   itemkey   - item key to start
--
procedure StartForkProcess(
     itemtype        in  varchar2,
     itemkey         in  varchar2) as

copy_itemkey varchar2(30);

cursor all_activities is
   select  ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY,
           ACTIVITY_STATUS, ACTIVITY_RESULT_CODE,
           ASSIGNED_USER, NOTIFICATION_ID,
           BEGIN_DATE, END_DATE, EXECUTION_TIME,
           ERROR_NAME, ERROR_MESSAGE, ERROR_STACK,
           OUTBOUND_QUEUE_ID, DUE_DATE
   from wf_item_activity_statuses
   where item_type = itemtype
   and   item_key  = copy_itemkey;

cursor all_activities_hist is
   select  ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY,
           ACTIVITY_STATUS, ACTIVITY_RESULT_CODE,
           ASSIGNED_USER, NOTIFICATION_ID,
           BEGIN_DATE, END_DATE, EXECUTION_TIME,
           ERROR_NAME, ERROR_MESSAGE, ERROR_STACK,
           OUTBOUND_QUEUE_ID, DUE_DATE
   from wf_item_activity_statuses_h
   where item_type = itemtype
   and   item_key  = copy_itemkey;


-- order by nid so that we re-execute in chronological order
cursor ntf_open  is
   select  ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY,
           ACTIVITY_STATUS, ACTIVITY_RESULT_CODE,
           ASSIGNED_USER, NOTIFICATION_ID,
           BEGIN_DATE, END_DATE, EXECUTION_TIME,
           ERROR_NAME, ERROR_MESSAGE, ERROR_STACK,
           OUTBOUND_QUEUE_ID, DUE_DATE
   from wf_item_activity_statuses
   where item_type = itemtype
   and   item_key  = copy_itemkey
   and   notification_id is not null
   and   activity_status = 'NOTIFIED'
   order by notification_id;


   nid number;

   act_fname varchar2(240);
   act_ftype varchar2(30);
   delay     number; -- dont use pls_integer or numeric overflow can occur.
   msg_id    raw(16):=null;

   copy_root_process    varchar2(30);
   copy_process_version pls_integer;
   copy_active_date     date;

   new_root_process     varchar2(30);
   new_process_version  pls_integer;
   new_active_date      date;



begin
  WF_CORE.TAG_DB_SESSION(WF_CORE.CONN_TAG_WF, StartForkProcess.itemtype);
  -- Argument validation
  if (itemtype is null)
  or (itemkey is null) then
    Wf_Core.Token('COPY_ITEMTYPE', itemtype);
    Wf_Core.Token('COPY_ITEMKEY', copy_itemkey);
    Wf_Core.Token('NEW_ITEMKEY', itemkey);
    Wf_Core.Raise('WFSQL_ARGS');
  end if;


  -- get the forked_from attribute: if it doesnt exist then this cannot be
  -- a forked item
  begin
  copy_itemkey :=   Wf_Engine.GetItemAttrText(itemtype, itemkey,'#FORKED_FROM');
  exception when others then
      Wf_Core.Raise('WF_NOFORK');
  end;


  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch)
  or (copy_itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.SuspendProcess');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;


  -- Check item exists and store attributes while cached
  if not (Wf_Item.Item_Exist(itemtype, copy_itemkey)) then
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', copy_itemkey);
      Wf_Core.Raise('WFENG_ITEM');
  end if;

  wf_item.Root_Process(itemtype => itemtype,
                       itemkey  => copy_itemkey,
                       wflow => copy_root_process,
                       version =>copy_process_version);

  copy_active_date:= wf_item.Active_Date(itemtype => itemtype,
                                         itemkey  => copy_itemkey);


  --check status of item to copy is active or complete
  --


  -- Check item exists
  if not (Wf_Item.Item_Exist(itemtype, itemkey)) then
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Raise('WFENG_ITEM');
  end if;

  wf_item.Root_Process(itemtype => itemtype,
                       itemkey  => itemkey,
                       wflow => new_root_process,
                       version =>new_process_version);

  new_active_date:= wf_item.Active_Date(itemtype => itemtype,
                                        itemkey  => itemkey);




  -- validate both copy and new items have same process and start dates.
  -- if not, this isnt a true fork: we are simply starting a process that
  -- uses the latest version so use startprocess
  if copy_root_process <> new_root_process
  or copy_process_version <> new_process_version
  or copy_active_date <> new_active_date then
     begin
       wf_engine.startprocess(itemtype,itemkey);
     exception when others then
       Wf_Core.raise('WF_CANNOT_FORK');
     end;
     return;
  end if;

  -- copy all activities except open notifications
  -- leave these to last because routing rule may complete the thread
  for act in all_activities loop

    msg_id :=null;
    nid := null;

    if act.notification_id is not null then

      --if complete then copy else ignore (we re-execute later)
      if act.activity_status = wf_engine.eng_completed then
          wf_engine_util.notification_copy (act.notification_id,
              act.item_key, itemkey, nid);
      end if;

    elsif act.activity_status = wf_engine.eng_deferred then

      --process defered activity
      act_fname:= Wf_Activity.activity_function
                 (act.item_type,act.item_key,act.process_activity);
      act_ftype:= Wf_Activity.activity_function_type
                 (act.item_type,act.item_key,act.process_activity);

      if act_ftype = 'PL/SQL' then

           if act.begin_date <= sysdate   then
              delay :=0;
           else
              delay := round((act.begin_date - sysdate)*24*60*60 + 0.5);
           end if;
           wf_queue.enqueue_event
            (queuename=>wf_queue.DeferredQueue,
             itemtype=> act.item_type,
             itemkey=>itemkey,
             actid=>act.process_activity,
             delay=>delay,
             message_handle=>msg_id);

           --even if internal, keep message handle for easy access.
           --msg_id :=null;
      elsif act_ftype = 'EXTERNAL' then
         -- this is a callout so write to OUTBOUND queue
         -- do not set the correlation here for compatibility reason
           wf_queue.enqueue_event
            (queuename=>wf_queue.OutboundQueue,
             itemtype=> act.item_type,
             itemkey=>itemkey,
             actid=>act.process_activity,
             funcname=>act_fname,
             paramlist=>wf_queue.get_param_list(act.item_type,itemkey,
                 act.process_activity),
             message_handle=>msg_id);
      else
         -- this is a callout so write to OUTBOUND queue for other type
           wf_queue.enqueue_event
            (queuename=>wf_queue.OutboundQueue,
             itemtype=> act.item_type,
             itemkey=>itemkey,
             actid=>act.process_activity,
             correlation=>act_ftype,
             funcname=>act_fname,
             paramlist=>wf_queue.get_param_list(act.item_type,itemkey,
                 act.process_activity),
             message_handle=>msg_id);
      end if;

      --else
      --must be a function activity
      --in this case we dont have to set any values, but just copy

    end if;

    -- now insert the status
    insert into  wf_item_activity_statuses
        (ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY,
        ACTIVITY_STATUS, ACTIVITY_RESULT_CODE,
        ASSIGNED_USER, NOTIFICATION_ID,
        BEGIN_DATE, END_DATE, EXECUTION_TIME,
        ERROR_NAME, ERROR_MESSAGE, ERROR_STACK,
        OUTBOUND_QUEUE_ID, DUE_DATE)
    values(act.item_type, itemkey, act.process_activity,
        act.activity_status, act.activity_result_code,
        act.assigned_user, nid,
        act.begin_date, act.end_date, act.execution_time,
        act.error_name, act.error_message, act.error_stack,
        msg_id, act.due_date);


  end loop; --end defered status

  -- repeat for all history
  for hist in all_activities_hist loop

     nid := null;
     if hist.notification_id is not null then
        wf_engine_util.notification_copy (hist.notification_id,
            hist.item_key, itemkey, nid);
     end if;

     -- now insert the status
     insert into  wf_item_activity_statuses_h
        (ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY,
          ACTIVITY_STATUS, ACTIVITY_RESULT_CODE,
          ASSIGNED_USER, NOTIFICATION_ID,
          BEGIN_DATE, END_DATE, EXECUTION_TIME,
          ERROR_NAME, ERROR_MESSAGE, ERROR_STACK,
          OUTBOUND_QUEUE_ID, DUE_DATE)
     values(hist.item_type, itemkey, hist.process_activity,
          hist.activity_status, hist.activity_result_code,
          hist.assigned_user, nid,
          hist.begin_date, hist.end_date, hist.execution_time,
          hist.error_name, hist.error_message, hist.error_stack,
          null, hist.due_date);

  end loop;

   -- update any active functions to notified state
  begin
     update wf_item_activity_statuses ias
     set   activity_status = wf_engine.eng_notified
     where item_type = itemtype
     and   item_key =  itemkey
     and   activity_status = 'ACTIVE'
     and   activity_status = wf_engine.eng_active
     and   exists (select 'its a function, not subprocess'
                   from  wf_process_activities pa,
                         wf_activities ac
                   where pa.activity_name        = ac.name
                   and   pa.activity_item_type   = ac.item_type
                   and   pa.activity_item_type = ias.item_type
                   and   pa.instance_id = ias.process_activity
                   and   type='FUNCTION');
   end;


   -- update item attributes on all copied notifications
   wf_engine_util.notification_refresh(itemtype,itemkey);


   -- as last step, launch all notifications still open
   -- keep this as last step because routing rules may allow
   -- continuation of thread.

   for ntf in ntf_open loop
       Wf_Engine_Util.Process_Activity(itemtype, itemkey,
           ntf.process_activity,wf_engine.threshold);
   end loop;


exception
  when others then
    Wf_Core.Context('Wf_Engine', 'StartForkProcess');
    raise;
end StartForkProcess;


--
--
-- BeginActivity (PUBLIC)
--   Determines if the specified activity may currently be performed on the
--   work item. This is a test that the performer may proactively determine
--   that their intent to perform an activity on an item is, in fact, allowed.
-- IN
--   itemtype  - A valid item type
--   itemkey   - A string generated from the application object's primary key.
--   activity  - Completed activity, specified in the form
--               [<parent process_name>:]<process instance_label>
--
procedure BeginActivity(itemtype in varchar2,
                        itemkey  in varchar2,
                        activity in varchar2)
is
  root varchar2(30);       -- The name of the root process for this key
  version pls_integer;     -- Root process version
  actdate date;            -- Active date of item
  actid pls_integer;       -- activity instance id
begin
  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.BeginActivity');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Argument validation
  if ((itemtype is null) or (itemkey is null) or (activity is null)) then
    Wf_Core.Token('ITEMTYPE', itemtype);
    Wf_Core.Token('ITEMKEY', itemkey);
    Wf_Core.Token('ACTIVITY', activity);
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- Validate the activity and get the actid.
  -- One of these conditions must hold:
  -- 1. The item does not exist
  --    --> The process is being implicitly started for the first time
  --        by completing a START activity.
  -- 2. The item and root process exist, and activity is NOTIFIED
  --    --> Activity just completed in a running process.

  -- Check if item exists and get root process
  Wf_Item.Root_Process(itemtype, itemkey, root, version);
  if (root is null) then
    -- Item does not exist. Must be case (1).

    -- Use selector to get the root process
    -- Note must do this here, instead of relying on CreateProcess
    -- to call the selector, because CreateProcess can't take the
    -- start activity as an argument to implicitly choose a root
    -- process when no selector function is defined.
    root := Wf_Engine_Util.Get_Root_Process(itemtype, itemkey, activity);
    if (root is null) then
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Raise('WFENG_ITEM_ROOT_SELECTOR');
    end if;

  else
    -- Item exists. Must be case (2).
    -- Check that the activity is currently notified.
    actid := Wf_Process_Activity.ActiveInstanceId(itemtype, itemkey,
                 activity, wf_engine.eng_notified);

    -- Any other status, or no status at all, is an error.
    if (actid is null) then
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Token('NAME', activity);
      Wf_Core.Raise('WFENG_NOT_NOTIFIED');
    end if;

  end if;
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'BeginActivity', itemtype, itemkey, activity);
    raise;
end BeginActivity;

--
-- CompleteActivity (PUBLIC)
--   Notifies the workflow engine that an activity has been completed for a
--   particular process(item). This procedure can have one or more of the
--   following effects:
--   o Creates a new item. If the completed activity is the start of a process,
--     then a new item can be created by this call. If the completed activity
--     is not the start of a process, it would be an invalid activity error.
--   o Complete an activity with an optional result. This signals the
--     workflow engine that an asynchronous activity has been completed.
--     An optional activity completion result can also be passed.
-- IN
--   itemtype  - A valid item type
--   itemkey   - A string generated from the application object's primary key.
--   activity  - Completed activity, specified in the form
--               [<parent process_name>:]<process instance_label>
--   <result>  - An optional result.
--
procedure CompleteActivity(itemtype in varchar2,
                           itemkey  in varchar2,
                           activity in varchar2,
                           result   in varchar2,
                           raise_engine_exception in boolean default FALSE)
is
  root varchar2(30);       -- The name of the root process for this key
  version pls_integer;     -- Root process version
  rootid pls_integer;      -- Root process actid
  actid pls_integer;       -- activity instance id
  notid pls_integer;       -- Notification group id
  user varchar2(320);      -- Notification assigned user

  trig_savepoint exception;
  pragma exception_init(trig_savepoint, -04092);
  dist_savepoint exception;
  pragma exception_init(dist_savepoint, -02074);

  --Bug 2607770
  l_lock boolean;
begin
  WF_CORE.TAG_DB_SESSION(WF_CORE.CONN_TAG_WF, CompleteActivity.itemtype);
  -- Argument validation
  if ((itemtype is null) or (itemkey is null) or (activity is null)) then
    Wf_Core.Token('ITEMTYPE', itemtype);
    Wf_Core.Token('ITEMKEY', itemkey);
    Wf_Core.Token('ACTIVITY', activity);
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  if (WF_CACHE.MetaRefreshed) then
    null;

  end if;

  -- Validate the activity and get the actid.
  -- One of these conditions must hold:
  -- 1. The item does not exist
  --    --> The process is being implicitly started for the first time
  --        by completing a START activity.
  -- 2. The item and root process exist, and activity is NOTIFIED
  --    --> Activity just completed in a running process.

  -- Check if item exists and get root process
  Wf_Item.Root_Process(itemtype, itemkey, root, version);
  if (root is null) then
    -- Item does not exist. Must be case (1).

    -- Use selector to get the root process
    -- Note must do this here, instead of relying on CreateProcess
    -- to call the selector, because CreateProcess can't take the
    -- start activity as an argument to implicitly choose a root
    -- process when no selector function is defined.
    root := Wf_Engine_Util.Get_Root_Process(itemtype, itemkey, activity);
    if (root is null) then
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Raise('WFENG_ITEM_ROOT_SELECTOR');
    end if;

    -- Create new process
    Wf_Engine.CreateProcess(itemtype, itemkey, root);

        --Bug 2259039
    -- Start the process for this activity.
    -- The activity to be completed will be left in NOTIFIED status
    -- as a side-effect of this call.
    Wf_Engine_Util.Start_Process_Internal(
      itemtype => itemtype,
      itemkey => itemkey,
      runmode => 'ACTIVITY');

    -- Get root process for the item
    Wf_Item.Root_Process(itemtype, itemkey, root, version);

    -- Look for the starting activity in the root process.
    actid := Wf_Process_Activity.StartInstanceId(itemtype, root, version,
                 activity);

    -- Create a status row for new activity
    Wf_Item_Activity_Status.Create_Status(itemtype, itemkey, actid,
        wf_engine.eng_active, wf_engine.eng_null, sysdate, null, newStatus=>TRUE);
  else

    --Bug 2607770
    --Its only in the else condition that you need to get
    --a lock over the existing item to make sure noone else is
    --processing it.

    -- Item exists. Must be case (2).
    -- Check that the activity is currently notified.
    actid := Wf_Process_Activity.ActiveInstanceId(itemtype, itemkey,
                 activity, wf_engine.eng_notified);

    -- Any other status, or no status at all, is an error.
    if (actid is null) then
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Token('NAME', activity);
      Wf_Core.Raise('WFENG_NOT_NOTIFIED');
    end if;

    --If acquire lock returns true we will continue
    --If it returns false we raise exception to the user
    --Any other exception we let the caller decide what to do
    if (itemkey <> wf_engine.eng_synch) then
       --If its an async process and you cannot acquire a lock
       --raise the exception to the user
       l_lock := wf_item.acquire_lock(itemtype,itemkey,true);
    end if;

    -- Get notification id
    Wf_Item_Activity_Status.Notification_Status(itemtype, itemkey, actid,
        notid, user);

    -- Close any open notifications associated with this activity.
    -- Note: if notifications are not closed here, they will be cancelled
    -- anyway by complete_activity.  They are only closed here so that the
    -- status is closed and not cancelled when going through the external
    -- CompleteActivity interface.
    -- Bug2811737 CTILLEY - added update to end_date
    if (notid is not null) then
      update WF_NOTIFICATIONS WN set
        status = 'CLOSED',
        end_date = sysdate
      where WN.GROUP_ID = CompleteActivity.notid
      and WN.STATUS = 'OPEN';
    end if;
  end if;

  -- Finally, complete our lovely new activity.
  if (itemkey = wf_engine.eng_synch) then
    -- SYNCHMODE: No error trapping in synchmode.
    Wf_Engine_Util.Complete_Activity(itemtype, itemkey, actid, result);
  else
    begin
      savepoint wf_savepoint;
      Wf_Engine_Util.Complete_Activity(itemtype, itemkey, actid, result);
    exception
      when trig_savepoint or dist_savepoint then
        -- You must be in a restricted environment,
        -- no fancy error processing for you!
        -- NOTE:  Must go ahead and complete the activity instead of
        -- deferring directly, because the activity must be marked as
        -- complete.  Any following activities started by completing
        -- this activity will be caught and deferred in another
        -- savepoint trap in process_activity.
        Wf_Engine_Util.Complete_Activity(itemtype, itemkey, actid, result);
      when others then
        -- If anything in this process raises an exception:
        -- 1. rollback any work in this process thread
        -- 2. set this activity to error status
        -- 3. execute the error process (if any)
        -- 4. clear the error to continue with next activity
        rollback to wf_savepoint;
        --Bug 14602624: parameter raise_engine_exception tells whether the
        -- callign application wants the engine to trap any unhandled
        -- errors. If FALSE default behavior goes on
        if raise_engine_exception then
          raise;
        else
          Wf_Core.Context('Wf_Engine', 'CompleteActivity', itemtype, itemkey,
              activity, result);
          Wf_Item_Activity_Status.Set_Error(itemtype, itemkey, actid,
              wf_engine.eng_exception, FALSE);
          Wf_Engine_Util.Execute_Error_Process(itemtype, itemkey, actid,
              wf_engine.eng_exception);
          Wf_Core.Clear;
        end if;
    end;
  end if;

exception
 when resource_busy then
    wf_core.token('TYPE',itemtype);
    wf_core.token('KEY',itemkey);
    wf_core.raise('WFENG_RESOURCE_BUSY');
  when others then
    Wf_Core.Context('Wf_Engine', 'CompleteActivity', itemtype, itemkey,
                    activity, result);
    raise;
end CompleteActivity;

--
-- CompleteActivityInternalName (PUBLIC)
--   Identical to CompleteActivity, except that the internal name of
--   completed activity is passed instead of the activity instance label.
-- NOTES:
-- 1. There must be exactly ONE instance of this activity with NOTIFIED
--    status.
-- 2. Using this api to start a new process is not supported.
-- 3. Synchronous processes are not supported in this api.
-- 4. This should only be used if for some reason the instance label is
--    not known.  CompleteActivity should be used if the instance
--    label is known.
-- IN
--   itemtype  - A valid item type
--   itemkey   - A string generated from the application object's primary key.
--   activity  - Internal name of completed activity, in the format
--               [<parent process_name>:]<process activity_name>
--   <result>  - An optional result.
--
procedure CompleteActivityInternalName(
  itemtype in varchar2,
  itemkey  in varchar2,
  activity in varchar2,
  result   in varchar2,
  raise_engine_exception in boolean default FALSE)
is
  colon pls_integer;
  process varchar2(30);
  actname varchar2(30);
  label varchar2(30);
begin
  WF_CORE.TAG_DB_SESSION(WF_CORE.CONN_TAG_WF, CompleteActivityInternalName.itemtype);
  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.CompleteActivityInternalName');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Argument validation
  if ((itemtype is null) or (itemkey is null) or (activity is null)) then
    Wf_Core.Token('ITEMTYPE', itemtype);
    Wf_Core.Token('ITEMKEY', itemkey);
    Wf_Core.Token('ACTIVITY', activity);
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- Parse activity arg into <process_name> and <activity_name> components.
  colon := instr(activity, ':');
  if (colon <> 0) then
    -- Activity arg is <process name>:<activity name>
    process := substr(activity, 1, colon-1);
    actname := substr(activity, colon+1);
  else
    -- Activity arg is just activity name
    process := '';
    actname := activity;
  end if;

  -- Look up activity instance label
  begin
    select WPA.PROCESS_NAME, WPA.INSTANCE_LABEL
    into process, label
    from WF_ITEM_ACTIVITY_STATUSES WIAS, WF_PROCESS_ACTIVITIES WPA
    where WIAS.ITEM_TYPE = itemtype
    and WIAS.ITEM_KEY = itemkey
    and WIAS.ACTIVITY_STATUS = wf_engine.eng_notified
    and WIAS.PROCESS_ACTIVITY = WPA.INSTANCE_ID
    and WPA.ACTIVITY_NAME = actname
    and WPA.PROCESS_NAME = nvl(process, WPA.PROCESS_NAME);
  exception
    when no_data_found then
      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', itemkey);
      Wf_Core.Token('NAME', activity);
      Wf_Core.Raise('WFENG_NOT_NOTIFIED');
  end;

  -- Complete activity with the correct arguments
  Wf_Engine.CompleteActivity(itemtype, itemkey, process||':'||label,
      result, CompleteActivityInternalName.raise_engine_exception);

exception
  when others then
    Wf_Core.Context('Wf_Engine', 'CompleteActivityInternalName',
      itemtype, itemkey, activity, result);
    raise;
end CompleteActivityInternalName;

--
-- AssignActivity (PUBLIC)
--   Assigns or re-assigns the user who will perform an activity. It may be
--   called before the activity has been enabled(transitioned to). If a user
--   is assigned to an activity that already has an outstanding notification,
--   that notification will be forwarded to the new user.
-- IN
--   itemtype  - A valid item type
--   itemkey   - A string generated from the application object's primary key.
--   activity  - Activity to assign, specified in the form
--               [<parent process_name>:]<process instance_label>
--   performer - User who will perform this activity.
--   reassignType - DELEGATE, TRANSFER or null
--   ntfComments - Comments while reassigning
--   16-DEC-03 shanjgik bug 2722369 new parameters added
procedure AssignActivity(itemtype in varchar2,
                         itemkey  in varchar2,
                         activity in varchar2,
                         performer in varchar2,
                         reassignType in varchar2,
                         ntfComments in varchar2) is
  root varchar2(30);
  version pls_integer;
  rootid pls_integer;
  actid pls_integer;
  status varchar2(8);
  notid pls_integer;
  user varchar2(320);
  acttype varchar2(8);
  actdate date;
  msg varchar2(30);
  msgtype varchar2(8);
  expand_role varchar2(1);
begin
  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.AssignActivity');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Argument validation
  if ((itemtype is null) or (itemkey is null) or (activity is null) or
      (performer is null)) then
    Wf_Core.Token('ITEMTYPE', itemtype);
    Wf_Core.Token('ITEMKEY', itemkey);
    Wf_Core.Token('ACTIVITY', activity);
    Wf_Core.Token('PERFORMER', performer);
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- Get the root process for this key, and check that the item
  -- has been created.
  Wf_Item.Root_Process(itemtype, itemkey, root, version);
  if (root is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');
  end if;

  -- Get the root process actid.
  rootid := Wf_Process_Activity.RootInstanceId(itemtype, itemkey, root);
  if (rootid is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('NAME', root);
    Wf_Core.Raise('WFENG_ITEM_ROOT');
  end if;

  -- Get the actid and check that this is a valid activity in the
  -- root process
  actdate := Wf_Item.Active_Date(itemtype, itemkey);
  actid := Wf_Process_Activity.FindActivity(rootid, activity, actdate);
  if (actid is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('NAME', activity);
    Wf_Core.Raise('WFENG_ITEM_ACTIVITY');
  end if;

  -- Check if this activity is a notification type of activity
  acttype := Wf_Activity.Type(itemtype, activity, actdate);
  if (acttype <> wf_engine.eng_notification) then
    Wf_Core.Token('NAME', activity);
    Wf_Core.Raise('WFENG_NOTIFICATION_NAME');
  end if;

  -- Check if the activity is active
  Wf_Item_Activity_Status.Status(itemtype, itemkey, actid, status);

  if (status is null) then
    -- Insert one row with the performer
    Wf_Item_Activity_Status.Create_Status(itemtype, itemkey, actid,
        wf_engine.eng_waiting, '', null, null, newStatus=>TRUE);
    Wf_Item_Activity_Status.Update_Notification(itemtype, itemkey, actid,
        '', performer);
  elsif (status = wf_engine.eng_waiting) then
    Wf_Item_Activity_Status.Update_Notification(itemtype, itemkey, actid,
        '', performer);
  elsif (status in (wf_engine.eng_notified, wf_engine.eng_error)) then
    -- Check this is not a voting activity.
    -- Voting activities cannot be re-assigned.
    Wf_Activity.Notification_Info(itemtype, itemkey, actid, msg, msgtype,
        expand_role);
    if (expand_role = 'Y') then
      Wf_Core.Token('NAME', activity);
      Wf_Core.Raise('WFENG_VOTE_REASSIGN');
    end if;

    -- Get notification id
    Wf_Item_Activity_Status.Notification_Status(itemtype, itemkey, actid,
        notid, user);
    -- Update the assigned user column in WIAS
    Wf_Item_Activity_Status.Update_Notification(itemtype, itemkey, actid,
        notid, performer);

    if (notid is not null) then
      -- 16-DEC-03 shanjgik bug fix 2722369 check for reassignType added
      if (reassignType = Wf_Engine.eng_delegate) then
        -- delegate the notification
        Wf_Notification.Forward(notid, performer, ntfComments);
      else -- case reassignType is TRANSFER or null
        -- Call Wf_Notification.Transfer(notid, performer) to transfer
        -- ownership of the notification to the new performer.
        Wf_Notification.Transfer(notid, performer, ntfComments);
      end if;
    end if;
  else
    -- Activity must be complete (all other statuses are not valid
    -- for a notification).
    Wf_Core.Token('ACTIVITY', activity);
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM_ACTIVITY_COMPLETE');
  end if;

EXCEPTION
  when OTHERS then
    Wf_Core.Context('Wf_Engine', 'AssignActivity', itemtype, itemkey,
                        activity, performer);
    raise;
end AssignActivity;

--
-- HandleErrorInternal (PRIVATE)
--   Reset the process thread to the given activity and begin execution
-- again from that point.  If command is:
--     SKIP - mark the activity complete with given result and continue
--     RETRY - re-execute the activity before continuing
-- IN
--   itemtype  - A valid item type.
--   itemkey   - The item key of the process.
--   root      - Root acitivity label
--   rootid    - Root acitivty id
--   activity  - Activity label
--   actid     - Activity id to reset
--   actdate   - Active Date
--   command   - SKIP or RETRY.
--   <result>  - Activity result for the 'SKIP' command.
--
procedure HandleErrorInternal(itemtype in varchar2,
                      itemkey  in varchar2,
                      root     in varchar2,
                      rootid   in number,
                      activity in varchar2,
                      actid    in number,
                      actdate  in date,
                      command  in varchar2,
                      result   in varchar2 default '')
is
  version pls_integer;
  funcname  varchar2(240);
  resultout varchar2(240);

  trig_savepoint exception;
  pragma exception_init(trig_savepoint, -04092);
  dist_savepoint exception;
  pragma exception_init(dist_savepoint, -02074);

  --Bug 1166527
  event_name           VARCHAR2(240);
  l_parameterlist      wf_parameter_list_t := wf_parameter_list_t();
begin
  WF_CORE.TAG_DB_SESSION(WF_CORE.CONN_TAG_WF, HandleErrorInternal.itemtype);
  -- Not allowed in synch mode
  -- Validate this before calling this function

  -- No Argument validation
  -- Validate this before calling this function

  -- Make sure item is valid
  -- Validate this before calling this function

  -- Reset the process starting from the goal activity.
  -- This reset behaves similar to loop reset, cancelling activities,
  -- moving rows to history, etc.  It then resets the activity status
  -- to active, AND resets or creates status rows for any parent process
  -- to active if necessary.
  if (not Wf_Engine_Util.Reset_Tree(itemtype, itemkey, rootid,
              actid, actdate)) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('NAME', activity);
    Wf_Core.Raise('WFENG_ITEM_ACTIVITY');
  end if;

  if (command = wf_engine.eng_skip) then
    -- *** SKIP ***
    -- Mark activity complete with given result
    begin
      savepoint wf_savepoint;

      -- execute the activity function with SKIP command (bug 2425229)
      funcname := Wf_Activity.Activity_Function(itemtype, itemkey, actid);

      if (funcname is not null) then -- <6636968>

        Wf_Engine_Util.Function_Call(funcname, itemtype, itemkey, actid, wf_engine.eng_skip,
                                   resultout);

        -- Check if skip is allowed on this activity
        if (resultout = wf_engine.eng_noskip) then
          Wf_Core.Token('LABEL', Wf_Engine.GetActivityLabel(actid));
          Wf_Core.Raise('WFENG_NOSKIP');
        end if;
      end if;-- </6636968>

      Wf_Engine_Util.Complete_Activity(itemtype, itemkey, actid, result, FALSE);

    exception
      when trig_savepoint or dist_savepoint then
        -- You must be in a restricted environment,
        -- no fancy error processing for you!  Try running directly.
        Wf_Engine_Util.Complete_Activity(itemtype, itemkey, actid,
            result, FALSE);
      when others then
        if (Wf_Core.Error_Name = 'WFENG_NOSKIP') then
          -- No processing. Raise to the caller that the activity cannot be skipped.
          raise;
        else
          -- If anything in this process raises an exception:
          -- 1. rollback any work in this process thread
          -- 2. set this activity to error status
          -- 3. execute the error process (if any)
          -- 4. clear the error to continue with next activity
          rollback to wf_savepoint;
          Wf_Core.Context('Wf_Engine', 'HandleErrorInternal', itemtype, itemkey,
              activity, command, result);
          Wf_Item_Activity_Status.Set_Error(itemtype, itemkey, actid,
              wf_engine.eng_exception, FALSE);
          Wf_Engine_Util.Execute_Error_Process(itemtype, itemkey, actid,
              wf_engine.eng_exception);
          Wf_Core.Clear;
        end if;
    end;
    --We will raise the skip event here .
    event_name := 'oracle.apps.wf.engine.skip';
  else
    -- *** RETRY ***
    if (actid = rootid) then
      -- Restart root process from beginnning
      Wf_Engine.StartProcess(itemtype, itemkey);
    else
      -- Start at given activity
      begin
        savepoint wf_savepoint;
        Wf_Engine_Util.Process_Activity(itemtype, itemkey, actid,
            Wf_Engine.Threshold, TRUE);
      exception
        when trig_savepoint or dist_savepoint then
          -- You must be in a restricted environment,
          -- no fancy error processing for you!
          -- Immediately defer activity to background engine.
          Wf_Item_Activity_Status.Create_Status(itemtype, itemkey,
                 actid, wf_engine.eng_deferred, wf_engine.eng_null,
                 SYSDATE, null);
        when others then
          -- If anything in this process raises an exception:
          -- 1. rollback any work in this process thread
          -- 2. set this activity to error status
          -- 3. execute the error process (if any)
          -- 4. clear the error to continue with next activity
          rollback to wf_savepoint;
          Wf_Core.Context('Wf_Engine', 'HandleErrorInternal',itemtype,itemkey,
              activity, command, result);
          Wf_Item_Activity_Status.Set_Error(itemtype, itemkey, actid,
              wf_engine.eng_exception, FALSE);
          Wf_Engine_Util.Execute_Error_Process(itemtype, itemkey, actid,
          wf_engine.eng_exception);
          Wf_Core.Clear;
      end;
    end if;
    event_name := 'oracle.apps.wf.engine.retry';
  end if;

  -- Store the info for Audit (Bug 5903106 - moved from HandleError to here)
  Wf_Item_Activity_Status.Audit(itemtype, itemkey, actid, upper(command), null);

  --Pass the signature of the handle error API in the
  --parameter list
  wf_event.AddParameterToList('ITMETYPE', itemtype, l_parameterlist);
  wf_event.AddParameterToList('ITEMKEY', itemkey, l_parameterlist);
  wf_event.AddParameterToList('ACTIVITY', activity, l_parameterlist);
  if (result is NOT NULL) then
    wf_event.AddParameterToList('RESULT', result, l_parameterlist);
  end if;

  -- Raise the event
  wf_event.Raise(p_event_name =>  event_name,
                 p_event_key  =>  itemkey,
                 p_parameters =>  l_parameterlist);

exception
  when others then
    Wf_Core.Context('Wf_Engine', 'HandleErrorInternal', itemtype, itemkey,
                    activity, command, result);
    raise;
end HandleErrorInternal;

--
-- HandleError (PUBLIC)
--   Reset the process thread to the given activity and begin execution
-- again from that point.  If command is:
--     SKIP - mark the activity complete with given result and continue
--     RETRY - re-execute the activity before continuing
-- IN
--   itemtype  - A valid item type.
--   itemkey   - The item key of the process.
--   activity  - Activity to reset, specified in the form
--               [<parent process_name>:]<process instance_label>
--   command   - SKIP or RETRY.
--   <result>  - Activity result for the 'SKIP' command.
--
procedure HandleError(itemtype in varchar2,
                      itemkey  in varchar2,
                      activity in varchar2,
                      command  in varchar2,
                      result   in varchar2)
is
  root varchar2(30);
  version pls_integer;
  rootid pls_integer;
  actid pls_integer;
  actdate date;

  trig_savepoint exception;
  pragma exception_init(trig_savepoint, -04092);
  dist_savepoint exception;
  pragma exception_init(dist_savepoint, -02074);
begin
  WF_CORE.TAG_DB_SESSION(WF_CORE.CONN_TAG_WF, HandleError.itemtype);
  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch) then
    wf_core.token('OPERATION', 'Wf_Engine.HandleError');
    wf_core.raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Argument validation
  if ((itemtype is null) or (itemkey is null) or (activity is null) or
      (upper(command) not in (wf_engine.eng_skip, wf_engine.eng_retry))) then
    Wf_Core.Token('ITEMTYPE', itemtype);
    Wf_Core.Token('ITEMKEY', itemkey);
    Wf_Core.Token('ACTIVITY', activity);
    Wf_Core.Token('COMMAND', command);
    Wf_Core.Raise('WFSQL_ARGS');
  end if;


  -- If we are in a different Fwk session, need to clear Workflow PLSQL state
  if (not Wfa_Sec.CheckSession) then
    Wf_Global.Init;
  end if;

  -- Make sure item is valid
  Wf_Item.Root_Process(itemtype, itemkey, root, version);
  if (root is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Raise('WFENG_ITEM');
  end if;
  rootid := Wf_Process_Activity.RootInstanceId(itemtype, itemkey, root);
  if (rootid is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('NAME', root);
    Wf_Core.Raise('WFENG_ITEM_ROOT');
  end if;

  -- Look for the activity instance for this item
  actdate := Wf_Item.Active_Date(itemtype, itemkey);
  actid := Wf_Process_Activity.FindActivity(rootid, activity, actdate);

  if (actid is null) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('PROCESS', root);
    Wf_Core.Token('NAME', activity);
    Wf_Core.Raise('WFENG_ACTIVITY_EXIST');
  end if;

  if (WF_CACHE.MetaRefreshed) then
    null;

  end if;

  -- Call the internal function to do the real job
  HandleErrorInternal(itemtype, itemkey, root, rootid, activity, actid,
                      actdate, upper(command), result);

exception
  when others then
    Wf_Core.Context('Wf_Engine', 'HandleError', itemtype, itemkey, activity,
                    command, result);
    raise;
end HandleError;

--
-- HandleErrorAll (PUBLIC)
--   Reset the process thread to the given item type and/or item key and/or
-- activity.
-- IN
--   itemtype  - A valid item type.
--   itemkey   - The item key of the process.
--   activity  - Activity to reset, specified in the form
--               [<parent process_name>:]<process instance_label>
--   command   - SKIP or RETRY.
--   <result>  - Activity result for the "SKIP" command.
--   docommit  - True if you want a commit for every n iterations.
--               n is defined as wf_engine.commit_frequency
--
procedure HandleErrorAll(itemtype in varchar2,
                         itemkey  in varchar2,
                         activity in varchar2,
                         command  in varchar2,
                         result   in varchar2,
                         docommit in boolean)
is
  root varchar2(30);
  version number;
  rootid number;
  actdate date;

  c_item_key varchar2(240);
  c_activity varchar2(30);
  c_actid    number;

  cursor actc(x_itemtype varchar2, x_itemkey varchar2, x_activity varchar2) is
    select  ias.ITEM_KEY,
            pa.INSTANCE_LABEL activity,
            pa.INSTANCE_ID actid
    from    WF_ITEM_ACTIVITY_STATUSES ias,
            WF_PROCESS_ACTIVITIES pa
    where   ias.ITEM_TYPE = x_itemtype
    and     (x_itemkey is null or ias.ITEM_KEY  = x_itemkey)
    and     (x_activity is null or pa.INSTANCE_LABEL = x_activity)
    and     ias.PROCESS_ACTIVITY = pa.INSTANCE_ID
    and     ias.ACTIVITY_STATUS = 'ERROR';

begin
  --Check arguments.
  if (itemtype is null) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  if (WF_CACHE.MetaRefreshed) then
    null;

  end if;

  -- outer loop
  <<outer_handle>>
  loop

    open actc(itemtype, itemkey, activity);

    -- inner loop
    <<handle_loop>>
    loop

      fetch actc into c_item_key, c_activity, c_actid;
      if (actc%notfound) then
        exit outer_handle;
      end if;

      -- Not allowed in synch mode
      if (c_item_key = wf_engine.eng_synch) then
        wf_core.token('OPERATION', 'Wf_Engine.HandleErrorAll');
        wf_core.raise('WFENG_SYNCH_DISABLED');
      end if;

      -- Argument validation
      if ((itemtype is null) or (c_item_key is null) or (c_activity is null) or
          (upper(command) not in (wf_engine.eng_skip, wf_engine.eng_retry)))
      then
        Wf_Core.Token('ITEMTYPE', itemtype);
        Wf_Core.Token('ITEMKEY', c_item_key);
        Wf_Core.Token('ACTIVITY', c_activity);
        Wf_Core.Token('COMMAND', command);
        Wf_Core.Raise('WFSQL_ARGS');
      end if;

      -- Make sure item is valid
      Wf_Item.Root_Process(itemtype, c_item_key, root, version);
      if (root is null) then
        Wf_Core.Token('TYPE', itemtype);
        Wf_Core.Token('KEY', c_item_key);
        Wf_Core.Raise('WFENG_ITEM');
      end if;
      rootid := Wf_Process_Activity.RootInstanceId(itemtype, c_item_key, root);
      if (rootid is null) then
        Wf_Core.Token('TYPE', itemtype);
        Wf_Core.Token('KEY', c_item_key);
        Wf_Core.Token('NAME', root);
        Wf_Core.Raise('WFENG_ITEM_ROOT');
      end if;

      -- Look for the activity instance for this item
      actdate := Wf_Item.Active_Date(itemtype, c_item_key);

      -- Call the internal function to do the real job
      HandleErrorInternal(itemtype, c_item_key, root, rootid, c_activity,
                          c_actid, actdate, upper(command), result);

      exit handle_loop when
          (docommit and (actc%rowcount = wf_engine.commit_frequency));

    end loop handle_loop;

    if (actc%ISOPEN) then
      close actc;
    end if;

    if (docommit) then
      commit;
      Fnd_Concurrent.Set_Preferred_RBS;
    end if;
  end loop outer_handle;

  if (docommit) then
    commit;
    Fnd_Concurrent.Set_Preferred_RBS;
  end if;

  if (actc%ISOPEN) then
    close actc;
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Engine', 'HandleErrorAll', itemtype, itemkey);
    raise;
end HandleErrorAll;

--
-- ItemStatus (Public)
--   This is a public cover for WF_ITEM_ACTIVITY_STATUS.ROOT_STATUS
--   Returns the status and result for the root process of this item.
--   If the item does not exist an exception will be raised.
-- IN
--   itemtype - Activity item type.
--   itemkey  - The item key.
-- OUT
--   status   - Activity status for root process of this item
--   result   - Result code for root process of this item
--
procedure ItemStatus(itemtype in varchar2,
                     itemkey  in varchar2,
                     status   out NOCOPY varchar2,
                     result   out NOCOPY varchar2) is
begin
  --Check arguments.
  if ((itemtype is null) or
      (itemkey is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ITEMKEY', nvl(itemkey, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

        wf_item_activity_status.root_status(itemtype,itemkey,status,result);
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'ItemStatus', itemtype, itemkey);
    raise;
end ItemStatus;

-- API to reterive more granular information from the
-- item
-- If the item is active and
-- If there is an errored activity then status is set to ERROR
-- the errname , errmsg and errstack info is given
-- activity , error stack etc are provided
-- If the first activity is deferred then the actid of the same
-- is provided and the item status is given as 'DEFERRED'
-- If an activity is in notified status then we get the
-- actid of the same.
procedure ItemInfo(itemtype      in  varchar2,
                   itemkey       in  varchar2,
                   status        out NOCOPY varchar2,
                   result        out NOCOPY varchar2,
                   actid         out NOCOPY number,
		   errname       out NOCOPY varchar2,
                   errmsg        out NOCOPY varchar2,
                   errstack      out NOCOPY varchar2)
is
l_status    varchar2(8);
l_result    varchar2(30);
l_instance_id      number;

--Order all activities for this itemtype ,key
--giving priority to ERROR , NOTIFIED , DEFERRED (--> in that order)
--and execution time
/*
Lets do a single select for rownum < 1 this
should suffice

cursor  act_curs (p_itemtype varchar2, p_itemkey varchar2) is
select  pa.instance_label,pa.instance_id
        ias.activity_status,
        ias.activity_result_code ,
        ias.assigned_user,
	ias.notification_id NID,
	ntf.status,
        ias.performed_by
from    wf_item_activity_statuses ias,
        wf_process_activities pa,
        wf_activities ac,
        wf_activities ap,
        wf_items i,
	wf_notifications ntf
where   ias.item_type = p_itemtype
and     ias.item_key  = p_itemkey
and     ias.activity_status     = wf_engine.eng_completed
and     ias.process_activity    = pa.instance_id
and     pa.activity_name        = ac.name
and     pa.activity_item_type   = ac.item_type
and     pa.process_name         = ap.name
and     pa.process_item_type    = ap.item_type
and     pa.process_version      = ap.version
and     i.item_type             = '&item_type'
and     i.item_key              = ias.item_key
and     i.begin_date            >= ac.begin_date
and     i.begin_date            < nvl(ac.end_date, i.begin_date+1)
and     ntf.notification_id(+)  = ias.notification_id
order by decode(ias.activity_status,'ERROR',1,'NOTIFIED',2,'DEFERRED',3,'SUSPEND',4,'WAITING',5,'ACTIVE',6,'COMPLETE',7) asc , ias.execution_time desc
*/

begin
  --Get the item status
  --Use the API above for the same
  wf_engine.ItemStatus(itemtype ,itemkey ,l_status,l_result);

  --Now check the status if root has completed
  --we do not want to go further lower
  --Else if the root is still active , lets find
  --where the execution is stuck at.

  if l_status= 'ACTIVE' then
    --Get last executed activities result and status
    select       process_activity,
                 activity_status,
                 activity_result_code
    into         l_instance_id,
                 l_status,
		 l_result
    from
        (
        select      process_activity,
                    activity_status,
                    activity_result_code
        from        wf_item_activity_statuses
        where       item_type = itemtype
        and         item_key  = itemkey
        and         activity_status <> wf_engine.eng_completed
        order by decode(activity_status, 'ERROR',1, 'NOTIFIED',2, 'DEFERRED',3,
                       'SUSPEND',4, 'WAITING',5, 'ACTIVE',6, 7) asc,
        begin_date desc, execution_time desc
        )
     where rownum < 2;

    --Now lets start getting all details out of the last activity
    if l_status = 'ERROR' then
      --Populate the error stack
      wf_item_activity_status.Error_Info(itemtype,itemkey,l_instance_id,errname,errmsg,errstack);
    end if;

    status  :=  l_status;
    result  :=  l_result;
    actid   :=  l_instance_id;
    --U can get it using the actid using Notification_Status API
    --nid     :=  l_notification_id;


  else
    --If the root is not active return whatever is its status
    --and result
    status := l_status ;
    result := l_result ;
  end if;
exception
  when others then
    Wf_Core.Context('Wf_Engine', 'ItemInfo', itemtype, itemkey);
    raise;
end ItemInfo;




--
-- Activity_Exist_In_Process (Public)
--   Check if an activity exist in a process
--   ### OBSOLETE - Use FindActivity instead ###
--   ### DO NOT REMOVE, refer to bug 1869241 ###
-- IN
--   p_item_type
--   p_item_key
--   p_activity_item_type
--   p_activity_name
-- RET
--   TRUE if activity exist, FALSE otherwise
--
function Activity_Exist_In_Process (
  p_item_type          in  varchar2,
  p_item_key           in  varchar2,
  p_activity_item_type in  varchar2,
  p_activity_name      in  varchar2)
return boolean
is
  rootactivity varchar2(30);
  active_date  date;
begin
  begin
    select ROOT_ACTIVITY, BEGIN_DATE
    into   rootactivity, active_date
    from   WF_ITEMS
    where  ITEM_TYPE = p_item_type
    and    ITEM_KEY  = p_item_key;
  exception
    -- if itemtype/itemkey combination not exists, treats it as not exists
    when NO_DATA_FOUND then
      return FALSE;

    when OTHERS then
      raise;
  end;

  return(Wf_Engine.Activity_Exist(
         p_process_item_type=>p_item_type,
         p_process_name=>rootactivity,
         p_activity_item_type=>p_activity_item_type,
         p_activity_name=>p_activity_name,
         active_date=>active_date));

exception
  when others then
    Wf_Core.Context('Wf_Engine', 'Activity_Exist_In_Process',
                    p_item_type, p_item_key,
                    nvl(p_activity_item_type, p_item_type),
                    p_activity_name);
    raise;
end Activity_Exist_In_Process;

--
-- Activity_Exist
--   Check if an activity exist in a process
--   ### OBSOLETE - Use FindActivity instead. ###
--   ### DO NOT REMOVE, refer to bug 1869241 ###
-- IN
--   p_process_item_type
--   p_process_name
--   p_activity_item_type
--   p_anctivity_name
--   active_date
--   iteration  - maximum 8 level deep (0-7)
-- RET
--   TRUE if activity exist, FALSE otherwise
--
function Activity_Exist (
  p_process_item_type  in  varchar2,
  p_process_name       in  varchar2,
  p_activity_item_type in  varchar2 default null,
  p_activity_name      in  varchar2,
  active_date          in  date default sysdate,
  iteration            in  number default 0)
return boolean
is
  m_version  number;
  n          number;

  cursor actcur(ver number) is
  select WPA.ACTIVITY_ITEM_TYPE, WPA.ACTIVITY_NAME
  from   WF_PROCESS_ACTIVITIES WPA,
         WF_ACTIVITIES WA
  where  WPA.PROCESS_ITEM_TYPE = p_process_item_type
  and    WPA.PROCESS_NAME = p_process_name
  and    WPA.PROCESS_VERSION = ver
  and    WPA.ACTIVITY_ITEM_TYPE = WA.ITEM_TYPE
  and    WPA.ACTIVITY_NAME = WA.NAME
  and    WA.TYPE = 'PROCESS'
  and    active_date >= WA.BEGIN_DATE
  and    active_date < nvl(WA.END_DATE, active_date+1);

begin
  -- first check the iteration to avoid infinite loop
  if (iteration > 7) then
    return FALSE;
  end if;

  -- then get the active version
  begin
    select VERSION into m_version
    from   WF_ACTIVITIES
    where  ITEM_TYPE = p_process_item_type
    and    NAME = p_process_name
    and    active_date >= BEGIN_DATE
    and    active_date <  nvl(END_DATE, active_date + 1);
  exception
    -- no active version exist
    when NO_DATA_FOUND then
      return FALSE;

    when OTHERS then
      raise;
  end;

  -- then check to see if such activity exist
  select count(1) into n
  from   WF_PROCESS_ACTIVITIES
  where  PROCESS_ITEM_TYPE = p_process_item_type
  and    PROCESS_NAME = p_process_name
  and    PROCESS_VERSION = m_version
  and    ACTIVITY_ITEM_TYPE = nvl(p_activity_item_type, p_process_item_type)
  and    ACTIVITY_NAME = p_activity_name;

  if (n = 0) then
    -- recursively check subprocesses
    for actr in actcur(m_version) loop
      if (Wf_Engine.Activity_Exist(
          actr.activity_item_type,
          actr.activity_name,
          nvl(p_activity_item_type, p_process_item_type),
          p_activity_name,
          active_date,
          iteration+1)
         ) then
        return TRUE;
      end if;
    end loop;

    return FALSE;
  else
    return TRUE;
  end if;

exception
  when OTHERS then
    Wf_Core.Context('Wf_Engine', 'Activity_Exist',
                    p_process_item_type, p_process_name,
                    nvl(p_activity_item_type, p_process_item_type),
                    p_activity_name);
    raise;
end Activity_Exist;

--
-- Event
--   Signal event to workflow process
-- IN
--   itemtype - Item type of process
--   itemkey - Item key of process
--   process_name - Process to start (only if process not already running)
--   event_message - Event message payload
--
procedure Event(
  itemtype in varchar2,
  itemkey in varchar2,
  process_name in varchar2,
  event_message in wf_event_t)
is
  event_name varchar2(240);
  actdate date;         -- Active date of item
  root varchar2(30);    -- Root process name
  version pls_integer;  -- Root process version
  rootid pls_integer;   -- Root process instance id
  aname  varchar2(30);  -- Item attr name
  avalue varchar2(2000); -- Item attr value
  plist wf_parameter_list_t; -- Event message parameter list

  -- Bug 2255002
  parent_itemtype varchar2(8);  -- parent item type
  parent_itemkey varchar2(240); -- parent item key

  -- Blocked activities waiting for event (if existing process)
  cursor evtacts is
    SELECT WIAS.PROCESS_ACTIVITY actid
    FROM WF_ITEM_ACTIVITY_STATUSES WIAS, WF_PROCESS_ACTIVITIES WPA,
         WF_ACTIVITIES WA
    WHERE WIAS.ITEM_TYPE = event.itemtype
    AND WIAS.ITEM_KEY = event.itemkey
    AND WIAS.ACTIVITY_STATUS = 'NOTIFIED'
    AND WIAS.PROCESS_ACTIVITY = WPA.INSTANCE_ID
    AND WPA.ACTIVITY_ITEM_TYPE = WA.ITEM_TYPE
    AND WPA.ACTIVITY_NAME = WA.NAME
    AND actdate >= WA.BEGIN_DATE
    AND actdate < NVL(WA.END_DATE, actdate+1)
    AND WA.TYPE = 'EVENT'
    AND WA.DIRECTION = 'RECEIVE'
    AND (WA.EVENT_NAME is null
      OR WA.EVENT_NAME in
        (SELECT WE.NAME -- Single events
         FROM WF_EVENTS WE
         WHERE WE.TYPE = 'EVENT'
         AND WE.NAME = event.event_name
         UNION ALL
         SELECT GRP.NAME -- Groups containing event
         FROM WF_EVENTS GRP, WF_EVENT_GROUPS WEG, WF_EVENTS MBR
         WHERE GRP.TYPE = 'GROUP'
         AND GRP.GUID = WEG.GROUP_GUID
         AND WEG.MEMBER_GUID = MBR.GUID
         AND MBR.NAME = event.event_name));

  actarr InstanceArrayTyp;  -- Event activities to execute
  i pls_integer := 0;       -- Loop counter

  l_lock   boolean;

begin
  WF_CORE.TAG_DB_SESSION(WF_CORE.CONN_TAG_WF, Event.itemtype);
  -- Check args
  if ((itemtype is null) or
      (itemkey is null) or
      (event_message is null)) then
    Wf_Core.Token('ITEMTYPE', itemtype);
    Wf_Core.Token('ITEMKEY', itemkey);
    Wf_Core.Token('EVENT_MESSAGE', '');
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- Not allowed in synch mode
  if (itemkey = wf_engine.eng_synch) then
    Wf_Core.Token('OPERATION', 'Wf_Engine.Set_Item_Parent');
    Wf_Core.Raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Retrieve event name from message
  event_name := event_message.GetEventName;
  if (event_name is null) then
    Wf_Core.Token('EVENT_MESSAGE.EVENT_NAME', '');
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  if (WF_CACHE.MetaRefreshed) then
    null;

  end if;

  -- Check if item exists
  if (Wf_Item.Item_Exist(itemtype, itemkey)) then

    -- Process is already running.
    --Acquire lock here so that no other session
    --will work on it.
    --Acquire lock here by opening the cursor
    l_lock :=  wf_item.acquire_lock(itemtype, itemkey,true);

    -- Find all activities waiting for this event.
    actdate := WF_Item.Active_Date(itemtype, itemkey);
    for act in evtacts loop
      actarr(i) := act.actid;
      i := i + 1;
    end loop;
    actarr(i) := '';

  else
    -- Process not running yet, create it.
    -- If process_name is null then will use selector function.
    Wf_Engine.CreateProcess(itemtype, itemkey, process_name);
    actdate := WF_Item.Active_Date(itemtype, itemkey);

    -- Bug 2259039
    -- Start the new process
    Wf_Engine_Util.Start_Process_Internal(
      itemtype => itemtype,
      itemkey =>  itemkey,
      runmode =>  'EVENT');

    --Select the activities waiting to receive this event
    actdate := WF_Item.Active_Date(itemtype, itemkey);
    for act in evtacts loop
      actarr(i) := act.actid;
      Wf_Item_Activity_Status.Create_Status(itemtype, itemkey, act.actid,
          wf_engine.eng_notified, wf_engine.eng_null, sysdate, null);
      i := i + 1;
    end loop;
    actarr(i) := '';
  end if;

  -- Check at least one matching event activity found
  if (i = 0) then
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', itemkey);
    Wf_Core.Token('EVENT', event_name);
    Wf_Core.Raise('WFENG_EVENT_NOTFOUND');
  end if;

  -- Set item attributes for all parameters contained in the event
  -- message body.
  -- NOTE: Must be done here AFTER the process has been created
  -- and BEFORE any activities are executed.
  plist := event_message.GetParameterList;
  if (plist is not null) then
    for i in plist.first .. plist.last loop
      aname := plist(i).GetName;
      avalue := plist(i).GetValue;
      begin
        if aname = '#CONTEXT' then
           -- Bug 2255002 - if the parent item type and parent item key
           -- already exist do nothing
           SELECT parent_item_type, parent_item_key
           INTO   parent_itemtype, parent_itemkey
           FROM   wf_items
           WHERE  item_type = itemtype
           AND    item_key = itemkey;

           if (parent_itemtype is null and parent_itemkey is null ) then
               Wf_Engine.SetItemParent(itemtype => itemtype,
                                       itemkey => itemkey,
                                       parent_itemtype =>
                                              substr(avalue,1,
                                                     instr(avalue,':')-1),
                                       parent_itemkey =>
                                              substr(avalue,
                                                     instr(avalue,':')+1),
                                       parent_context => null);
             --Bug 19322157
             WF_ENGINE.AddItemAttr(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => '#DETAIL_PROCESS',
                                   text_value => 'NO');
           end if;
       elsif aname = '#OWNER_ROLE' then
          --Bug 2388634
          --This is for the applications to set their item owner
          --by including a #OWNER_ROLE parameter for the event
          wf_engine.SetItemowner(itemtype,itemkey,avalue);

        else
           -- event item attributes may use canonical masks.
           Wf_Engine.SetEventItemAttr(itemtype, itemkey, aname, avalue);
        end if;
      exception
        when others then
          if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
            -- If attr doesn't exist create runtime itemattr
            Wf_Core.Clear;
            Wf_Engine.AddItemAttr(itemtype, itemkey, aname, avalue);
          else
            raise;  -- All other errors are raised up.
          end if;
      end;
    end loop;
  end if;

  -- Complete matching event activities
  i := 0;
  while (actarr(i) is not null) loop
    begin
      savepoint wf_savepoint;
      -- Save event data to itemattrs requested by this activity.
      -- #EVENTNAME
      aname := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actarr(i),
                                   wf_engine.eng_eventname);
      if (aname is not null) then
        Wf_Engine.SetItemAttrText(itemtype, itemkey, aname, event_name);
      end if;
      -- #EVENTKEY
      aname := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actarr(i),
                                   wf_engine.eng_eventkey);
      if (aname is not null) then
        Wf_Engine.SetItemAttrText(itemtype, itemkey, aname,
            event_message.GetEventKey);
      end if;
      -- #EVENTMESSAGE
      aname := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actarr(i),
                                   wf_engine.eng_eventmessage);
      if (aname is not null) then
        Wf_Engine.SetItemAttrEvent(itemtype, itemkey, aname, event_message);
      end if;

      -- Execute our lovely event activity (result is always null).
      Wf_Engine_Util.Complete_Activity(itemtype, itemkey, actarr(i),
          wf_engine.eng_null);
    exception
      when others then
        -- If anything in this process raises an exception:
        -- 1. rollback any work in this process thread
        -- 2. set this activity to error status
        -- 3. execute the error process (if any)
        -- 4. clear the error to continue with next activity
        rollback to wf_savepoint;
        Wf_Core.Context('Wf_Engine', 'Event', itemtype, itemkey,
            process_name, event_name);
        Wf_Item_Activity_Status.Set_Error(itemtype, itemkey, actarr(i),
            wf_engine.eng_exception, FALSE);
        Wf_Engine_Util.Execute_Error_Process(itemtype, itemkey, actarr(i),
            wf_engine.eng_exception);
        Wf_Core.Clear;
    end;
    i := i + 1;
  end loop;

exception
  when others then
    Wf_Core.Context('Wf_Engine', 'Event', itemtype, itemkey,
        process_name, event_name);
    raise;
end Event;

--
-- Event2
--   Signal event to workflow process
-- IN
--   event_message - Event message payload
--
procedure Event2(
 event_message in wf_event_t)
is
 event_name varchar2(240);
 root varchar2(30);    -- Root process name
 version pls_integer;  -- Root process version
 rootid pls_integer;   -- Root process instance id
 aname  varchar2(30);  -- Item attr name
 avalue varchar2(2000); -- Item attr value
 plist wf_parameter_list_t; -- Event message parameter list
 businesskey varchar2(240);

 -- Blocked activities waiting for event (if existing process)
 cursor evtacts is
   SELECT /*+ LEADING(WA)  */ WIAS.ITEM_TYPE, WIAS.ITEM_KEY, WIAS.PROCESS_ACTIVITY ACTID
   FROM WF_ITEM_ACTIVITY_STATUSES WIAS,
        WF_PROCESS_ACTIVITIES WPA,
        (
	   SELECT /*+ NO_MERGE */ WA.*
	   FROM WF_ACTIVITIES WA
	   where WA.TYPE = 'EVENT'
	   AND WA.DIRECTION = 'RECEIVE'
           AND WA.END_DATE is null
	   AND ( WA.EVENT_NAME IS NULL OR
	         WA.EVENT_NAME = event2.event_name OR
	         EXISTS
                 (
		    SELECT null  -- Groups containing event
		    FROM WF_EVENTS GRP, WF_EVENT_GROUPS WEG, WF_EVENTS MBR
		    WHERE GRP.TYPE = 'GROUP'
		    AND GRP.GUID = WEG.GROUP_GUID
		    AND WEG.MEMBER_GUID = MBR.GUID
		    AND MBR.NAME = event2.event_name
		    AND GRP.NAME = WA.EVENT_NAME
		  )
		)
        ) WA,
        WF_ITEMS WI
   WHERE WIAS.ACTIVITY_STATUS = 'NOTIFIED'
   AND WIAS.PROCESS_ACTIVITY = WPA.INSTANCE_ID
   AND WIAS.ITEM_TYPE  = WPA.PROCESS_ITEM_TYPE
   AND WPA.ACTIVITY_ITEM_TYPE = WA.ITEM_TYPE
   AND WPA.ACTIVITY_NAME = WA.NAME
   AND EXISTS
      ( SELECT 1 FROM WF_ACTIVITY_ATTR_VALUES WAAV,
                      WF_ITEM_ATTRIBUTE_VALUES WIAV
        WHERE  WAAV.PROCESS_ACTIVITY_ID = WIAS.PROCESS_ACTIVITY
        AND    WAAV.NAME = '#BUSINESS_KEY'
        AND    WAAV.VALUE_TYPE = 'ITEMATTR'
        AND    WIAV.ITEM_TYPE = WIAS.ITEM_TYPE
        AND    WIAV.ITEM_KEY = WIAS.ITEM_KEY
        AND    WAAV.TEXT_VALUE = WIAV.NAME
        AND    WIAV.TEXT_VALUE = event2.businesskey)
   AND WI.ITEM_TYPE = WIAS.ITEM_TYPE
   AND WI.ITEM_KEY  = WIAS.ITEM_KEY
   FOR UPDATE OF WI.ITEM_TYPE,WI.item_key  NOWAIT;

 ectacts_rec evtacts%ROWTYPE;

 litemtype varchar2(8);
 litemkey varchar2(240);
 lactid number;

 i pls_integer := 0;       -- Loop counter

begin

 -- Check args
 if ((event_message is null)) then
   Wf_Core.Token('EVENT_MESSAGE', '');
   Wf_Core.Raise('WFSQL_ARGS');
 end if;

 -- Retrieve event name from message
 event_name := event_message.GetEventName;
 businesskey := event_message.GetEventKey;

 if (event_name is null) then
     Wf_Core.Token('EVENT_MESSAGE.EVENT_NAME', '');
     Wf_Core.Raise('WFSQL_ARGS');
 end if;

 --Here before opening the cursor we will set the savepoint
 --This is so that we do not have to depend on the cursor behaviour itself
 --but once the cursor fails to acquire lock we expliciltly rollback
 --But having the for update statement in the cursor eliminates the need
 --for explicitly locking the workitems .

 savepoint wf_savepoint_event2;
 -- Find all activities waiting for this event.
 for evtacts_rec in evtacts loop

     -- Set item attributes for all parameters contained in the event
     -- message body.
     -- NOTE: Must be done here AFTER the process has been created
     -- and BEFORE any activities are executed.
     plist := event_message.GetParameterList;

     if ((plist is not null) and (plist.count > 0)) then
       for i in plist.first .. plist.last loop
         aname := plist(i).GetName;
         avalue := plist(i).GetValue;
         begin
           if aname = '#CONTEXT' then
             Wf_Engine.SetItemParent(itemtype => evtacts_rec.item_type,
                       itemkey => evtacts_rec.item_key,
                       parent_itemtype =>substr(avalue,1,instr(avalue,':')-1),
                       parent_itemkey =>substr(avalue,instr(avalue,':')+1),
                       parent_context => null);
          else
            -- event item attributes may use canonical masks.
            Wf_Engine.SetEventItemAttr(evtacts_rec.item_type,
                                       evtacts_rec.item_key, aname, avalue);
          end if;
          exception
            when others then
              if (wf_core.error_name = 'WFENG_ITEM_ATTR') then
               -- If attr doesn't exist create runtime itemattr
                 Wf_Core.Clear;

                 Wf_Engine.AddItemAttr(evtacts_rec.item_type,
                                       evtacts_rec.item_key,
                                       aname, avalue);
             else
                 raise;  -- All other errors are raised up.
             end if;
           end;
     end loop;
   end if;

   begin
     savepoint wf_savepoint;
     -- Save event data to itemattrs requested by this activity.
     -- #EVENTNAME
     aname := Wf_Engine.GetActivityAttrText(evtacts_rec.item_type,
                                            evtacts_rec.item_key,
                                            evtacts_rec.actid,
                                            wf_engine.eng_eventname);
     if (aname is not null) then
        Wf_Engine.SetItemAttrText(evtacts_rec.item_type,
                                  evtacts_rec.item_key,
                                  aname,
                                  event_name);
     end if;
     -- #EVENTKEY
     aname := Wf_Engine.GetActivityAttrText(evtacts_rec.item_type,
                                            evtacts_rec.item_key,
                                            evtacts_rec.actid,
                                            wf_engine.eng_eventkey);
     if (aname is not null) then
        Wf_Engine.SetItemAttrText(evtacts_rec.item_type,
                                  evtacts_rec.item_key, aname,
                                  event_message.GetEventKey);
     end if;
     -- #EVENTMESSAGE
     aname := Wf_Engine.GetActivityAttrText(evtacts_rec.item_type,
                                            evtacts_rec.item_key,
                                            evtacts_rec.actid,
                                            wf_engine.eng_eventmessage);
     if (aname is not null) then
         Wf_Engine.SetItemAttrEvent(evtacts_rec.item_type,
                                    evtacts_rec.item_key,
                                    aname,
                                    event_message);
     end if;

     -- Execute our lovely event activity (result is always null).
     Wf_Engine_Util.Complete_Activity(evtacts_rec.item_type,
                                      evtacts_rec.item_key, evtacts_rec.actid,
                                      wf_engine.eng_null);
   exception
     when others then
       -- If anything in this process raises an exception:
       -- 1. rollback any work in this process thread
       -- 2. set this activity to error status
       -- 3. execute the error process (if any)
       -- 4. clear the error to continue with next activity
       rollback to wf_savepoint;
       Wf_Core.Context('Wf_Engine', 'Event2', evtacts_rec.item_type,
                        evtacts_rec.item_key, event_name);
       Wf_Item_Activity_Status.Set_Error(evtacts_rec.item_type,
                                         evtacts_rec.item_key,
                                         evtacts_rec.actid,
                                         wf_engine.eng_exception, FALSE);
       Wf_Engine_Util.Execute_Error_Process(evtacts_rec.item_type,
                                            evtacts_rec.item_key,
                                            evtacts_rec.actid,
                                            wf_engine.eng_exception);
       Wf_Core.Clear;
   end;

   i := i + 1;
 end loop;

 -- Check at least one matching event activity found
 if (i = 0) then
   Wf_Core.Token('EVENT2', event_name);
   Wf_Core.Raise('WFENG_EVENT_NOTFOUND');
 end if;

exception
 when resource_busy then
   --Rollback to ensure that we aren't locking anything here
   rollback to wf_savepoint_event2;
   raise;
 when others then
   Wf_Core.Context('Wf_Engine', 'Event2', businesskey, event_name);
   raise;
end Event2;

--
-- AddToItemAttrNumber
--   Increments (or decrements) an numeric item attribute and returns the
--   new value.  If the item attribute does not exist, it returns null.
-- IN
--   p_itemtype - process item type
--   p_itemkey - process item key
--   p_aname - Item Attribute Name
--   p_name - attribute name
--   p_addend - Numeric value to be added to the item attribute.  If p_addend
--              is set to null, it will set the ItemAttrNumber to 0.
--
-- RETURNS
--   Attribute value (NUMBER) or NULL if attribute does not exist.
--
function AddToItemAttrNumber(
  p_itemtype in varchar2,
  p_itemkey in varchar2,
  p_aname in varchar2,
  p_addend in number)
return number is
   iStatus  PLS_INTEGER;
   wiavIND  NUMBER;
   l_avalue NUMBER;
 begin
  -- Check Arguments
   if ((p_itemtype is null) or
       (p_itemkey is null) or
       (p_aname is null))  then
     Wf_Core.Token('P_ITEMTYPE', nvl(p_itemtype, 'NULL'));
     Wf_Core.Token('P_ITEMKEY', nvl(p_itemkey, 'NULL'));
     Wf_Core.Token('P_ANAME', nvl(p_aname, 'NULL'));
     Wf_Core.Raise('WFSQL_ARGS');
   end if;

   if (p_itemkey = wf_engine.eng_synch) then
     WF_CACHE.GetItemAttrValue(p_itemtype, p_itemKey, p_aname, iStatus,
                               wiavIND);

     if (iStatus <> WF_CACHE.task_SUCCESS) then
       return null;

     else
       if (p_addend is NOT null) then
         WF_CACHE.ItemAttrValues(wiavIND).NUMBER_VALUE :=
                     (WF_CACHE.ItemAttrValues(wiavIND).NUMBER_VALUE + p_addend);
       else
         WF_CACHE.ItemAttrValues(wiavIND).NUMBER_VALUE := 0;
       end if;

       return WF_CACHE.ItemAttrValues(wiavIND).NUMBER_VALUE;

     end if;

   else
     if (p_addend is NOT null) then
       update WF_ITEM_ATTRIBUTE_VALUES wiav
       set    wiav.NUMBER_VALUE = (wiav.NUMBER_VALUE+p_addend)
       where  wiav.ITEM_TYPE = p_itemtype
       and    wiav.ITEM_KEY = p_itemkey
       and    wiav.NAME = p_aname
       returning wiav.NUMBER_VALUE into l_avalue;
     else
       update WF_ITEM_ATTRIBUTE_VALUES wiav
       set    wiav.NUMBER_VALUE = 0
       where  wiav.ITEM_TYPE = p_itemtype
       and    wiav.ITEM_KEY = p_itemkey
       and    wiav.NAME = p_aname
       returning wiav.NUMBER_VALUE into l_avalue;
     end if;

     if (SQL%NOTFOUND) then
       return null;
     end if;
     return l_avalue;

   end if;

 exception
   when no_data_found then
     return NULL;

   when others then
     Wf_Core.Context('Wf_Engine', 'AddToItemAttrNumber', p_itemtype, p_itemkey,
                     p_aname, to_char(p_addend));
     raise;
 end AddToItemAttrNumber;

-- Bug 5903106
-- HandleErrorConcurrent
--   Concurrent Program API to handle any process activity that has
--   encountered an error. This Concurrent Program API is a wrapper
--   to HandleError and HandleErrorAll based on the parameter values
--   supplied.
-- IN
--   p_errbuf
--   p_retcode
--   p_itemtype   - Workflow Itemtype
--   p_itemkey    - Itemkey of the process
--   p_activity   - Workflow process activity label
--   p_start_date - Errored On or After date
--   p_end_date   - Errored On or Before date
--   p_max_retry  - Maximum retries allowed on an activity
--   p_docommit   - Y (Yes) if you want a commit for every n iterations.
--                  n is defined as wf_engine.commit_frequency
--
procedure HandleErrorConcurrent(p_errbuf    out nocopy varchar2,
                                p_retcode   out nocopy varchar2,
                                p_itemtype  in  varchar2,
                                p_itemkey   in  varchar2,
                                p_process   in  varchar2,
                                p_activity  in  varchar2,
                                p_start_date in varchar2,
                                p_end_date  in  varchar2,
                                p_max_retry in  varchar2,
                                p_docommit  in  varchar2)
is

  l_start_date date;
  l_end_date   date;
  l_max_retry number;
  l_docommit  boolean;
  l_count     number;

  l_errname   varchar2(30);
  l_errmsg    varchar2(2000);
  l_stack     varchar2(32000);

  CURSOR c_err_acts (x_item_type varchar2,
                     x_item_key  varchar2,
                     x_process   varchar2,
                     x_activity  varchar2,
                     x_start_date date,
                     x_end_date  date,
                     x_max_retry number)
  IS
  SELECT  wias.item_key,
          wpa.process_name,
          wpa.instance_label activity
  FROM    wf_item_activity_statuses wias,
          wf_process_activities wpa
  WHERE   wias.item_type = x_item_type
  AND     (x_item_key IS NULL OR wias.item_key = x_item_key)
  AND     (x_process  IS NULL OR wpa.process_name = x_process)
  AND     (x_activity IS NULL OR wpa.instance_label = x_activity)
  AND     (x_start_date IS NULL OR wias.begin_date >= x_start_date)
  AND     (x_end_date IS NULL OR wias.begin_date <= x_end_date)
  AND     wias.process_activity = wpa.instance_id
  AND     wias.activity_status = 'ERROR'
  AND     x_max_retry >=
          (SELECT count(1)
           FROM   wf_item_activity_statuses_h wiash
           WHERE  wiash.item_type = wias.item_type
           AND    wiash.item_key  = wias.item_key
           AND    wiash.process_activity = wias.process_activity
           AND    wiash.action = 'RETRY');

begin

  l_start_date := to_date(null);
  l_end_date   := to_date(null);

  -- Date value from CP is in fnd_flex_val_util.g_date_format_19 - 'RRRR/MM/DD HH24:MI:SS'
  -- This is same as wf_core.canonical_date_mask.
  if (p_start_date is not null) then
    l_start_date := to_date(p_start_date, wf_core.canonical_date_mask);
  end if;

  if (p_end_date is not null) then
    l_end_date := to_date(p_end_date, wf_core.canonical_date_mask);
  end if;

  if (nvl(p_docommit, 'Y') = 'Y') then
    l_docommit := TRUE;
  else
    l_docommit := FALSE;
  end if;

  l_max_retry := to_number(nvl(p_max_retry, '5'));

  -- Write parameters to log file
  Fnd_File.Put_Line(Fnd_File.Log, 'Wf_Engine.HandleErrorConcurrent');
  Fnd_File.Put_Line(Fnd_File.Log, 'p_itemtype  - '||p_itemtype);
  Fnd_File.Put_Line(Fnd_File.Log, 'p_itemkey   - '||p_itemkey);
  Fnd_File.Put_Line(Fnd_File.Log, 'p_process   - '||p_process);
  Fnd_File.Put_Line(Fnd_File.Log, 'p_activity  - '||p_activity);
  Fnd_File.Put_Line(Fnd_File.Log, 'l_start_date - '||to_char(l_start_date));
  Fnd_File.Put_Line(Fnd_File.Log, 'l_end_date - '||to_char(l_end_date));
  Fnd_File.Put_Line(Fnd_File.Log, 'l_max_retry - '||to_char(l_max_retry));
  Fnd_File.Put_Line(Fnd_File.Log, 'p_docommit  - '||p_docommit);

  -- Check Arguments
  if (p_itemtype is null) then
    Wf_Core.Token('ITEMTYPE', nvl(p_itemtype, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  if (WF_CACHE.MetaRefreshed) then
    null;
  end if;

  -- Retry all activities in ERROR for given parameters
  for l_rec in c_err_acts(p_itemtype,
                          p_itemkey,
                          p_process,
                          p_activity,
                          l_start_date,
                          l_end_date,
                          l_max_retry)
  loop

    Wf_Engine.HandleError(itemtype => p_itemtype,
                          itemkey  => l_rec.item_key,
                          activity => l_rec.process_name||':'||l_rec.activity,
                          command  => wf_engine.eng_retry,
                          result   => '');

    if (l_docommit and c_err_acts%rowcount = wf_engine.commit_frequency) then
      commit;
      Fnd_Concurrent.Set_Preferred_RBS;
    end if;
    l_count := c_err_acts%rowcount;
  end loop;

  Fnd_File.Put_Line(Fnd_File.Log, 'Items Processed - '||l_count);

  if (l_docommit) then
    commit;
    Fnd_Concurrent.Set_Preferred_RBS;
  end if;

  -- Successful completion
  p_errbuf := '';
  p_retcode := 0;

exception
  when others then
    Wf_Core.Get_error(l_errname, l_errmsg, l_stack);

    -- Completed with Error
    p_errbuf := nvl(l_errmsg, sqlerrm);
    p_retcode := '2';

end HandleErrorConcurrent;
-- bug 6161171
procedure AbortProcess2(itemtype    in varchar2,
                        itemkey     in varchar2,
                        process     in varchar2       default '',
                        result      in varchar2       default wf_engine.eng_force,
                        verify_lock in binary_integer default 0,
                        cascade     in binary_integer default 0)
is
  l_verify_lock boolean;
  l_cascade     boolean;
begin
  l_verify_lock := false;
  l_cascade := false;

  if (verify_lock <> 0) then
    l_verify_lock := true;
  end if;
  if (cascade <> 0) then
    l_cascade := true;
  end if;

  wf_engine.AbortProcess(itemtype, itemkey, process, result, l_verify_lock, l_cascade);

end AbortProcess2;

end Wf_Engine;

/
