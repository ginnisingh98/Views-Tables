--------------------------------------------------------
--  DDL for Package Body WF_ENGINE_BULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ENGINE_BULK" as
/* $Header: wfengblkb.pls 120.5 2006/02/10 01:13:02 anachatt noship $ */


--
-- Exception
--
no_savepoint exception;
bad_format   exception;

pragma EXCEPTION_INIT(no_savepoint, -1086);
pragma EXCEPTION_INIT(bad_format, -6502);

resource_busy exception;
pragma exception_init(resource_busy, -00054);

-- private variable
schema varchar2(30);
g_execCount number:=0;


--
--  ConsolidateKeys (PRIVATE)
--Condense the sparse itemkey list into a dense one
--   IN OUT
-- itemkeys
-- userkeys
-- ownerroles

procedure ConsolidateKeys(itemkeys in out NOCOPY WF_ENGINE_BULK.Itemkeytabtype,
               user_keys  in out NOCOPY WF_ENGINE_BULK.UserKeyTabType ,
               owner_roles in out NOCOPY WF_ENGINE_BULK.OwnerRoleTabType )
is

begin

 if itemkeys is not null and itemkeys.count>0 then
   for arrIndex in itemkeys.first..itemkeys.last loop
        if not itemkeys.exists(arrIndex)  then
          --fill in the gap with the last list element
          itemkeys(arrIndex):=itemkeys(itemkeys.last);

          --consolidate user_keys if it is not null
          if user_keys is not null and user_keys.count>0 then
            user_keys(arrIndex):=user_keys(user_keys.last);
           user_keys.delete(user_keys.last);
          end if;
          --consolidate owner_roles if it is not null
          if owner_roles is not null and owner_roles.count > 0 then
           owner_roles(arrIndex):=owner_roles(owner_roles.last);
           owner_roles.delete(owner_roles.last);
          end if;
            itemkeys.delete(itemkeys.last);
        end if;
   end loop;
 end if;

exception
 when others then
        raise;
end ConsolidateKeys;


--
-- Current_Schema (PRIVATE)
--   Return the current schema
--
function Current_Schema
return varchar2
is
begin
  if (wf_engine_bulk.schema is null) then
    select sys_context('USERENV','CURRENT_SCHEMA')
      into wf_engine_bulk.schema
      from sys.dual;
  end if;
  return wf_engine_bulk.schema;
exception
  when OTHERS then
    Wf_Core.Context('Wf_Engine_Bulk', 'Current_Schema');
    raise;
end Current_Schema;

--
-- BulkCreateItems (PRIVATE)
--   Create rows in bulk in the WF_ITEMS table with the given item type
--   , item key list
--   and the root process name.
-- IN
--   itemtype - item type
--   wflow    - root process name for this item.
--   actdate  - active date of item
--   user
--
procedure BulkCreateItems(
  itemtype in varchar2,
  wflow    in varchar2,
  actdate  in date,
  user_keys in out NOCOPY wf_engine_bulk.userkeytabtype,
  owner_roles in out NOCOPY wf_engine_bulk.ownerroletabtype,
  parent_itemtype in varchar2,
  parent_itemkey in varchar2,
  parent_context in varchar2)
is

  rootversion number;
  itemkeys  wf_engine_bulk.itemkeytabtype;

begin

  rootversion := Wf_Activity.Version(itemtype, wflow, actdate);
  --initialize the table of itemkeys from the list of successful items.
  if g_SuccessItems.COUNT=0 then
    return;
  else
  itemkeys:=g_SuccessItems;
  end if;


  begin
  --insert depending on whether user_keys and owner_roles are null or not
  if  user_keys.count > 0 and owner_roles.count > 0 then
  forall arrInd in itemkeys.FIRST..itemkeys.LAST  SAVE EXCEPTIONS
    -- NORMAL: Insert new item and attributes directly in the db
    insert into WF_ITEMS (
      ITEM_TYPE,
      ITEM_KEY,
      ROOT_ACTIVITY,
      ROOT_ACTIVITY_VERSION,
      OWNER_ROLE,
      PARENT_ITEM_TYPE,
      PARENT_ITEM_KEY,
      PARENT_CONTEXT,
      BEGIN_DATE,
      END_DATE,
      USER_KEY
    ) values (
      itemtype,
      itemkeys(arrInd),
      wflow,
      rootversion,
      owner_roles(arrInd),
      parent_itemtype,
      parent_itemkey,
      parent_context,
      actdate,
      to_date(NULL),
      user_keys(arrInd)
    );
  elsif user_keys.count>0 and owner_roles.count=0 then
  forall arrInd in itemkeys.FIRST..itemkeys.LAST  SAVE EXCEPTIONS
     insert into WF_ITEMS (
      ITEM_TYPE,
      ITEM_KEY,
      ROOT_ACTIVITY,
      ROOT_ACTIVITY_VERSION,
      PARENT_ITEM_TYPE,
      PARENT_ITEM_KEY,
      PARENT_CONTEXT,
      BEGIN_DATE,
      END_DATE,
      USER_KEY
    ) values (
      itemtype,
      itemkeys(arrInd),
      wflow,
      rootversion,
      parent_itemtype,
      parent_itemkey,
      parent_context,
      actdate,
      to_date(NULL),
      user_keys(arrInd)
    );
  elsif owner_roles.count>0 and user_keys.count=0 then
  forall arrInd in itemkeys.FIRST..itemkeys.LAST  SAVE EXCEPTIONS
     insert into WF_ITEMS (
      ITEM_TYPE,
      ITEM_KEY,
      ROOT_ACTIVITY,
      ROOT_ACTIVITY_VERSION,
      OWNER_ROLE,
      PARENT_ITEM_TYPE,
      PARENT_ITEM_KEY,
      PARENT_CONTEXT,
      BEGIN_DATE,
      END_DATE
    ) values (
      itemtype,
      itemkeys(arrInd),
      wflow,
      rootversion,
      owner_roles(arrInd),
      parent_itemtype,
      parent_itemkey,
      parent_context,
      actdate,
      to_date(NULL)
    );
  elsif owner_roles.count=0 and user_keys.count=0 then
  forall arrInd in itemkeys.FIRST..itemkeys.LAST  SAVE EXCEPTIONS
     insert into WF_ITEMS (
      ITEM_TYPE,
      ITEM_KEY,
      ROOT_ACTIVITY,
      ROOT_ACTIVITY_VERSION,
      PARENT_ITEM_TYPE,
      PARENT_ITEM_KEY,
      PARENT_CONTEXT,
      BEGIN_DATE,
      END_DATE
    ) values (
      itemtype,
      itemkeys(arrInd),
      wflow,
      rootversion,
      parent_itemtype,
      parent_itemkey,
      parent_context,
      actdate,
      to_date(NULL)
    );
  end if;
  exception
     when others then

       if SQL%BULK_EXCEPTIONS.COUNT>0 then
        for ExceptionInd in 1..SQL%BULK_EXCEPTIONS.COUNT loop

           g_failedItems(g_failedItems.COUNT+1):=
              itemKeys(SQL%BULK_EXCEPTIONS(ExceptionInd).ERROR_INDEX);
           itemkeys.DELETE(SQL%BULK_EXCEPTIONS(ExceptionInd).ERROR_INDEX);
           if user_keys is not null and user_keys.count>0 then
            user_keys.DELETE(SQL%BULK_EXCEPTIONS(ExceptionInd).ERROR_INDEX);
           end if;
           if owner_roles is not null and owner_roles.count>0 then
            owner_roles.DELETE(SQL%BULK_EXCEPTIONS(ExceptionInd).ERROR_INDEX);
           end if;
        end loop;
        -- condense the PL/SQL tables to eliminate sparse indices
        ConsolidateKeys(ItemKeys,User_Keys,Owner_Roles);
       end if;
   end;

  if itemkeys.count > 0 AND (not wf_item.Attribute_On_Demand(itemtype, itemkeys(itemkeys.FIRST))) then
  begin
  -- Initialize item attributes in bulk

  --if its on demand, we are not going to do this
  forall arrInd in itemkeys.FIRST..itemkeys.LAST save exceptions

    -- NORMAL: store attributes in table
    insert into WF_ITEM_ATTRIBUTE_VALUES (
      ITEM_TYPE,
      ITEM_KEY,
      NAME,
      TEXT_VALUE,
      NUMBER_VALUE,
      DATE_VALUE
    ) select
      itemtype,
      itemkeys(arrInd),
      WIA.NAME,
      WIA.TEXT_DEFAULT,
      WIA.NUMBER_DEFAULT,
      WIA.DATE_DEFAULT
    from WF_ITEM_ATTRIBUTES WIA
    where WIA.ITEM_TYPE = itemtype;

    exception
     when others then
       if SQL%BULK_EXCEPTIONS.COUNT>0 then
        for ExceptionInd in 1..SQL%BULK_EXCEPTIONS.COUNT loop
           g_failedItems(g_failedItems.COUNT+1):=
                  itemKeys(SQL%BULK_EXCEPTIONS(ExceptionInd).ERROR_INDEX);
           itemkeys.DELETE(SQL%BULK_EXCEPTIONS(ExceptionInd).ERROR_INDEX);
           user_keys.DELETE(SQL%BULK_EXCEPTIONS(ExceptionInd).ERROR_INDEX);
           owner_roles.DELETE(SQL%BULK_EXCEPTIONS(ExceptionInd).ERROR_INDEX);
        end loop;
        ConsolidateKeys(ItemKeys,User_Keys,Owner_Roles);
      end if;
   end;
  end if;
   -- reset the SuccessItems table to reflect the successfully created items.
   g_SuccessItems:=itemkeys;

end BulkCreateItems;


--
-- BulkAddItemAttr (PRIVATE)
--   Add a new unvalidated run-time item attribute for a list of itemkeys.
-- IN:
--   itemtype - item type

--   aname - attribute name
--   text_value   - add text value to it if provided.
--   number_value - add number value to it if provided.
--   date_value   - add date value to it if provided.
-- NOTE:
--   The new attribute has no type associated.  Get/set usages of the
--   attribute must insure type consistency.
--
procedure BulkAddItemAttr(itemtype in varchar2,
                      aname in varchar2,
                      text_values in wf_engine.textTabTyp)
is
  bulkException boolean := FALSE;
  l_itemkeys WF_ENGINE_BULK.itemkeytabtype;
  l_ukeys WF_ENGINE_BULK.UserKeyTabType;
  l_rkeys  WF_ENGINE_BULK.OwnerRoleTabType;
begin
  -- Check Arguments
  if ((itemtype is null) or
      (aname is null)) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Token('ANAME', nvl(aname, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  end if;
  If g_SuccessItems.count=0 then
    return;
  end if;
  l_itemkeys:=g_SuccessItems;

  --bulk insert the new attribute for all the itemkeys in the list
  begin

  forall arrInd in l_itemkeys.FIRST..l_itemkeys.LAST SAVE EXCEPTIONS
    insert into WF_ITEM_ATTRIBUTE_VALUES (
      ITEM_TYPE,
      ITEM_KEY,
      NAME,
      TEXT_VALUE
    ) values (
      itemtype,
      l_itemkeys(arrInd),
      aname,
      BulkAddItemAttr.text_values(arrInd)
    );

  exception
   when others then
      if SQL%BULK_EXCEPTIONS.COUNT>0 then
       bulkException:= true;
       -- load the failedItems table with the list of errored itemkeys,
       -- and remove them from the itemkeys table
       for failIndex in 1..SQL%BULK_EXCEPTIONS.COUNT loop
         g_FailedItems(g_FailedItems.COUNT+1):=
                l_itemkeys(SQL%BULK_EXCEPTIONS(failIndex).ERROR_INDEX);
         l_itemkeys.DELETE(SQL%BULK_EXCEPTIONS(failIndex).ERROR_INDEX);
       end loop;
      end if;
  end;
  -- load successfully added itemkeys to the SuccessItems Table.
  if  ( bulkException) then
   ConsolidateKeys(l_itemkeys,l_ukeys,l_rkeys);
  end if;
  g_SuccessItems:=l_itemkeys;
exception
  when others then
       raise;
end BulkAddItemAttr;




--
-- SetItemAttrText (PUBLIC)
--   Set the values of an array of text item attribute.
--   Unlike SetItemAttrText(), it stores the values directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Array of Names
--   avalue - Array of New values for attribute
--
procedure SetItemAttrText (
  itemtype in varchar2,
  itemkeys  in Wf_Engine_Bulk.ItemKeyTabType,
  anames   in Wf_Engine.NameTabTyp,
  avalues  in Wf_Engine.TextTabTyp)
is
  status      pls_integer;
  arrayIndex  pls_integer;
  j           pls_integer;
  wiavIND     number;
  success_cnt number;
  match       boolean;
  succAttrUpdates Wf_Engine.NameTabTyp;
  succItemUpdates Wf_Engine_Bulk.ItemKeyTabType;

begin
  -- Check Arguments
  if (itemtype is null) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');
  end if;

  if (anames.COUNT = 0 or avalues.COUNT = 0) then
    -- Do not do anything if index table is empty.
    return;

  elsif ((anames.LAST <> avalues.LAST or anames.COUNT <> avalues.COUNT)
      or (anames.LAST<> itemkeys.LAST or anames.COUNT<> itemkeys.COUNT)) then
    -- Raise an error if the two index tables do not end at the same index
    -- or do not have the same number of elements.
    g_failedItems:=itemkeys;
    g_failedAttributes:=anames;
    Wf_Core.Raise('WFENG_BLK_ITM_ATTRARR_MISMATCH');
  end if;

  --If itemtype is on demand, we will insert default values if not exists already
  if wf_item.Attribute_On_Demand(itemtype, itemkeys(itemkeys.FIRST)) then
    begin
      forall arrayIndex in itemkeys.FIRST..itemkeys.LAST save exceptions
      insert into WF_ITEM_ATTRIBUTE_VALUES
        (ITEM_TYPE, ITEM_KEY, NAME, TEXT_VALUE)
      select itemtype, itemkeys(arrayIndex), anames(arrayIndex), text_default
        from WF_ITEM_ATTRIBUTES WIA
        where
          WIA.ITEM_TYPE = itemtype
        and
          WIA.NAME = anames(arrayIndex)
        and not exists (select 1 from WF_ITEM_ATTRIBUTE_VALUES WIAV
          where WIAV.item_type=itemtype
          and  WIAV.item_key=itemkeys(arrayIndex)
          and  WIAV.NAME=anames(arrayIndex));
    exception
        when others then
          null; -- ignore failures here
    end;
  end if;

  -- Reset the table of Failed Items and Failed Attributes
  g_FailedItems.DELETE;
  g_FailedAttributes.DELETE;
  -- Set the text value.
  begin
   forall arrInd in itemkeys.FIRST..itemkeys.LAST save exceptions
      update WF_ITEM_ATTRIBUTE_VALUES set
        TEXT_VALUE = avalues(arrInd)
      where ITEM_TYPE = itemtype
      and ITEM_KEY = itemkeys(arrInd)
      and NAME = anames(arrInd)
     returning item_key,name bulk collect into succItemUpdates, succAttrUpdates;

  exception
      when others then
        if sql%bulk_exceptions.count>0 then
         for ErrorIndex in 1..sql%bulk_exceptions.count loop
          g_failedItems(g_FailedItems.COUNT+1):=
            itemkeys(sql%bulk_exceptions(ErrorIndex).error_index);
          g_failedAttributes(g_FailedAttributes.COUNT+1):=
            anames(sql%bulk_exceptions(ErrorIndex).error_index);
         end loop;
        end if;
   end;

   if (succItemUpdates.count <> itemkeys.COUNT) then
   -- determine the failed item/atrributes
      if succItemUpdates.count=0 then
          g_failedItems:=itemkeys;
          g_failedAttributes:=anames;
      else

       for i in itemkeys.first..itemkeys.last loop

         if ((itemkeys.count - i + 1) = succItemUpdates.count) then
          -- we are done, the rest are all successful
          exit;
         end if;
         match := false;
         j:=succItemUpdates.first;
         while j <= succItemUpdates.last loop
          if anames(i) = succAttrUpdates(j)
             and itemkeys(i) = succItemUpdates(j) then

           -- remove the item/attr from the success table
           succItemUpdates.delete(j);
           succAttrUpdates.delete(j);
           match := true;
           exit;
          end if;

          j:=succItemUpdates.next(j);

         end loop;

         if not(match) then
         -- item has failed.Insert into list of failed items
          g_failedItems(g_FailedItems.COUNT+1):=itemkeys(i);
          g_failedAttributes(g_FailedAttributes.COUNT+1):=anames(i);

         end if;
       end loop;
      end if; --successUpdates count=0
   end if; --sucessUpdates doesnot match item count


  if g_failedItems.COUNT >0 then
    WF_CORE.TOKEN('ITEMTYPE',itemtype);
    WF_CORE.TOKEN('TOTAL',to_char(itemkeys.count));
    WF_CORE.TOKEN('FAILED',to_char(g_FailedItems.COUNT));
    WF_CORE.Raise('WFENG_BULK_SETATTR');
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Engine_Bulk', 'SetItemAttrText', itemtype);
    raise;
end SetItemAttrText;


--
-- SetItemAttrNumber (PUBLIC)
--   Set the value of an array of number item attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Array of Names
--   avalue - Array of new value for attribute
--
procedure SetItemAttrNumber(
  itemtype in varchar2,
  itemkeys  in Wf_Engine_Bulk.ItemKeyTabType,
  anames    in Wf_Engine.NameTabTyp,
  avalues   in Wf_Engine.NumTabTyp)
is
  arrayIndex  pls_integer;
  status      pls_integer;
  wiavIND     number;
  success_cnt number;
  j           pls_integer;
  match       boolean;
  succAttrUpdates Wf_Engine.NameTabTyp;
  succItemUpdates Wf_Engine_Bulk.ItemKeyTabType;

begin
  -- Check Arguments
  if (itemtype is null) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  elsif (anames.COUNT = 0 or avalues.COUNT = 0) then
    -- Do not do anything if index table is empty.
    return;

  elsif ((anames.LAST <> avalues.LAST or anames.COUNT <> avalues.COUNT)
      or (anames.LAST<> itemkeys.LAST or anames.COUNT<> itemkeys.COUNT)) then
    -- Raise an error if the two index tables do not end at the same index
    -- or do not have the same number of elements.
    g_failedItems:=itemkeys;
    g_failedAttributes:=anames;
    Wf_Core.Raise('WFENG_BLK_ITM_ATTRARR_MISMATCH');
  end if;
  --If itemtype is on demand, we will insert default values if not exists already
  if wf_item.Attribute_On_Demand(itemtype, itemkeys(itemkeys.FIRST)) then
    begin
      forall arrayIndex in itemkeys.FIRST..itemkeys.LAST save exceptions
      insert into WF_ITEM_ATTRIBUTE_VALUES
        (ITEM_TYPE, ITEM_KEY, NAME, NUMBER_VALUE)
      select itemtype, itemkeys(arrayIndex), anames(arrayIndex), number_default
        from WF_ITEM_ATTRIBUTES WIA
        where
          WIA.ITEM_TYPE = itemtype
        and
          WIA.NAME = anames(arrayIndex)
        and not exists (select 1 from WF_ITEM_ATTRIBUTE_VALUES WIAV
          where WIAV.item_type=itemtype
          and  WIAV.item_key=itemkeys(arrayIndex)
          and  WIAV.NAME=anames(arrayIndex));
    exception
        when others then
          null; -- ignore failures here and let update to handle the logic
    end;
  end if;

  -- Reset the table of Failed Items and Failed Attributes
  g_FailedItems.DELETE;
  g_failedAttributes.DELETE;

  -- Set the number value.
 begin
  forall arrInd in itemkeys.FIRST..itemkeys.LAST save exceptions
      update WF_ITEM_ATTRIBUTE_VALUES set
      NUMBER_VALUE = avalues(arrInd)
      where ITEM_TYPE = itemtype
      and ITEM_KEY = itemkeys(arrInd)
      and NAME = anames(arrInd)
     returning item_key,name bulk collect into succItemUpdates, succAttrUpdates;

 exception
      when others then
        if sql%bulk_exceptions.count>0 then
         for ErrorIndex in 1..sql%bulk_exceptions.count loop
          g_failedItems(g_FailedItems.COUNT+1):=
            itemkeys(sql%bulk_exceptions(ErrorIndex).error_index);
          g_failedAttributes(g_FailedAttributes.COUNT+1):=
            anames(sql%bulk_exceptions(ErrorIndex).error_index);
         end loop;
        end if;
 end;

   if (succItemUpdates.count <> itemkeys.COUNT) then
   -- determine the failed item/atrributes
      if succItemUpdates.count=0 then
          g_failedItems:=itemkeys;
          g_failedAttributes:=anames;
      else

       for i in itemkeys.first..itemkeys.last loop

         if ((itemkeys.count - i + 1) = succItemUpdates.count) then
          -- we are done, the rest are all successful
          exit;
         end if;
         match := false;
         j:=succItemUpdates.first;
         while j <= succItemUpdates.last loop
          if anames(i) = succAttrUpdates(j)
             and itemkeys(i) = succItemUpdates(j) then

           -- remove the item/attr from the success table
           succItemUpdates.delete(j);
           succAttrUpdates.delete(j);
           match := true;
           exit;
          end if;

          j:=succItemUpdates.next(j);

         end loop;

         if not(match) then
         -- item has failed.Insert into list of failed items
          g_failedItems(g_FailedItems.COUNT+1):=itemkeys(i);
          g_failedAttributes(g_FailedAttributes.COUNT+1):=anames(i);
         end if;
       end loop;
      end if; --successUpdates count=0
   end if; --sucessUpdates doesnot match item count

  if g_failedItems.COUNT >0 then

    WF_CORE.TOKEN('ITEMTYPE',itemtype);
    WF_CORE.TOKEN('TOTAL',to_char(itemkeys.COUNT));
    WF_CORE.TOKEN('FAILED',to_char(g_FailedItems.COUNT));
    WF_CORE.Raise('WFENG_BULK_SETATTR');
  end if;

exception
  when others then
    Wf_Core.Context('Wf_Engine_Bulk', 'SetItemAttrNumber', itemtype);
    raise;
end SetItemAttrNumber;

--
-- SetItemAttrDate (PUBLIC)
--   Set the value of an array of date item attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key List
--   aname - Array of Name
--   avalue - Array of new value for attribute
--
procedure SetItemAttrDate(
  itemtype in varchar2,
  itemkeys  in Wf_Engine_Bulk.ItemKeyTabType,
  anames    in Wf_Engine.NameTabTyp,
  avalues   in Wf_Engine.DateTabTyp)
is
  status      pls_integer;

  wiavIND     number;
  success_cnt number;

  j           pls_integer;
  match       boolean;
  succAttrUpdates Wf_Engine.NameTabTyp;
  succItemUpdates Wf_Engine_Bulk.ItemKeyTabType;

begin

  -- Check Arguments
  if (itemtype is null) then
    Wf_Core.Token('ITEMTYPE', nvl(itemtype, 'NULL'));
    Wf_Core.Raise('WFSQL_ARGS');

  elsif (anames.COUNT = 0 or avalues.COUNT = 0) then
    -- Do not do anything if index table is empty.
    return;

  elsif ((anames.LAST <> avalues.LAST or anames.COUNT <> avalues.COUNT)
      or (anames.LAST<> itemkeys.LAST or anames.COUNT<> itemkeys.COUNT)) then
    -- Raise an error if the two index tables do not end at the same index
    -- or do not have the same number of elements.
    g_FailedItems:=itemkeys;
    g_FailedAttributes:=anames;
    Wf_Core.Raise('WFENG_BLK_ITM_ATTRARR_MISMATCH');
  end if;
  -- Reset the table of Failed Items and Failed Attributes
  g_FailedItems.DELETE;
  g_FailedAttributes.DELETE;

 --If itemtype is on demand, we will insert default values if not exists already
  if wf_item.Attribute_On_Demand(itemtype, itemkeys(itemkeys.FIRST)) then
    begin
      forall arrayIndex in itemkeys.FIRST..itemkeys.LAST save exceptions
      insert into WF_ITEM_ATTRIBUTE_VALUES
        (ITEM_TYPE, ITEM_KEY, NAME, DATE_VALUE)
      select itemtype, itemkeys(arrayIndex), anames(arrayIndex), Date_default
        from WF_ITEM_ATTRIBUTES WIA
        where
          WIA.ITEM_TYPE = itemtype
        and
          WIA.NAME = anames(arrayIndex)
        and not exists (select 1 from WF_ITEM_ATTRIBUTE_VALUES WIAV
          where WIAV.item_type=itemtype
          and  WIAV.item_key=itemkeys(arrayIndex)
          and  WIAV.NAME=anames(arrayIndex));
    exception
        when others then
          null; -- ignore failures here
    end;
  end if;
  -- Set the date value.
  begin
  forall arrInd in itemkeys.FIRST..itemkeys.LAST save exceptions
      update WF_ITEM_ATTRIBUTE_VALUES set
      DATE_VALUE = avalues(arrInd)
      where ITEM_TYPE = itemtype
      and ITEM_KEY = itemkeys(arrInd)
      and NAME = anames(arrInd)
     returning item_key,name bulk collect into succItemUpdates, succAttrUpdates;

   exception
      when others then
       if sql%bulk_exceptions.count>0 then
         for ErrorIndex in 1..sql%bulk_exceptions.count loop
          g_failedItems(g_FailedItems.COUNT+1):=
            itemkeys(sql%bulk_exceptions(ErrorIndex).error_index);
          g_failedAttributes(g_FailedAttributes.COUNT+1):=
            anames(sql%bulk_exceptions(ErrorIndex).error_index);
         end loop;
        end if;
   end;

   if (succItemUpdates.count <> itemkeys.COUNT) then
   -- determine the failed item/atrributes
      if succItemUpdates.count=0 then
          g_failedItems:=itemkeys;
          g_failedAttributes:=anames;
      else

       for i in itemkeys.first..itemkeys.last loop

         if ((itemkeys.count - i + 1) = succItemUpdates.count) then
          -- we are done, the rest are all successful
          exit;
         end if;
         match := false;
         j:=succItemUpdates.first;
         while j <= succItemUpdates.last loop
          if anames(i) = succAttrUpdates(j)
             and itemkeys(i) = succItemUpdates(j) then

           -- remove the item/attr from the success table
           succItemUpdates.delete(j);
           succAttrUpdates.delete(j);
           match := true;
           exit;
          end if;

          j:=succItemUpdates.next(j);

         end loop;

         if not(match) then
         -- item has failed.Insert into list of failed items
          g_failedItems(g_FailedItems.COUNT+1):=itemkeys(i);
          g_failedAttributes(g_FailedAttributes.COUNT+1):=anames(i);
         end if;
       end loop;
      end if; --successUpdates count=0
   end if; --sucessUpdates doesnot match item count

   if g_failedItems.COUNT >0 then
    WF_CORE.TOKEN('ITEMTYPE',itemtype);
    WF_CORE.TOKEN('TOTAL',to_char(itemkeys.COUNT));
    WF_CORE.TOKEN('FAILED',to_char(g_FailedItems.COUNT));
    WF_CORE.Raise('WFENG_BULK_SETATTR');
  end if;
exception
   when others then
    Wf_Core.Context('Wf_Engine_Bulk', 'SetItemAttrDate', itemtype);
    raise;
end SetItemAttrDate;

-- BulkCreateProcess (PUBLIC)
--   Create a new runtime process for a given list of itemkeys
--  (for an application itemtype).
-- IN
--   itemtype - A valid item type
--   itemkeys  - A list of itemkeys  generated from the application
--               object's primary key.
--   process  - A valid root process for this item type
--              (or null to use the item's selector function)
--  user_keys - A list of userkeys bearing one to one
--              correspondence with the item ley list
-- owner_roles - A list of ownerroles bearing one-to-one
--               correspondence with the item key list
procedure CreateProcess(itemtype in varchar2,
                        itemkeys  in wf_engine_bulk.itemkeytabtype,
                        process  in varchar2,
                        user_keys in wf_engine_bulk.userkeytabtype,
                        owner_roles in wf_engine_bulk.ownerroletabtype,
                        parent_itemtype in varchar2,
                        parent_itemkey in varchar2,
                        parent_context in varchar2,
                        masterdetail   in boolean )
is
  root varchar2(30);
  version number;
  actdate date;
  typ varchar2(8);
  rootid pls_integer;
  status varchar2(8);

  foundDuplicate boolean :=FALSE;


  l_itemkeys  wf_engine_bulk.itemkeytabtype;
  l_user_keys wf_engine_bulk.userkeytabtype;
  l_owner_roles wf_engine_bulk.ownerroletabtype;
  mon_random wf_engine.textTabTyp;
  acc_random wf_engine.textTabTyp;
  schemaAttribute varchar2(30);
  l_rkeys wf_engine_bulk.ownerroleTabType;
  l_ukeys wf_engine_bulk.userkeyTabType;
  l_count number;

begin
  -- Argument validation
  if (itemtype is null)  then
    Wf_Core.Token('ITEMTYPE', itemtype);
    Wf_Core.Token('PROCESS', process);
    Wf_Core.Raise('WFSQL_ARGS');
  end if;
  l_itemkeys:=    itemkeys;
  l_user_keys:=   user_keys;
  l_owner_roles:= owner_roles;

  -- check whether the user_keys and owner_roles arrays have been passed
  -- or not. If not , we would need to intialize them to match the itemkey list
  -- this needs to be done so that Bulk Inserts later donot fail.



  --<rwunderl:4198524>
  if (WF_CACHE.MetaRefreshed) then
    null;
  end if;
  -- Reset the table of failed items and successful items
  g_FailedItems.DELETE;
  g_SuccessItems.DELETE;

  if (process is null) then
    -- Call the selector function to get the process. The process
    -- retrieved for the first itemkey in the list, is assumed to
    -- hold for all the itemkeys in the list.

    root := Wf_Engine_Util.Get_Root_Process(itemtype, l_itemkeys(l_itemkeys.FIRST));
    if (root is null) then

      g_FailedItems:=l_itemkeys;

      Wf_Core.Token('TYPE', itemtype);
      Wf_Core.Token('KEY', l_itemkeys.FIRST);
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

    g_FailedItems:=l_itemkeys;

    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('NAME', root);
    Wf_Core.Raise('WFENG_PROCESS_NAME');
  end if;

  -- Validate the root argument is runnable

  begin
  select INSTANCE_ID
  into rootid
  from WF_PROCESS_ACTIVITIES PA, WF_ACTIVITIES A
  where A.ITEM_TYPE = itemtype
  and A.NAME = 'ROOT'
  and actdate >= A.BEGIN_DATE
  and actdate < NVL(A.END_DATE, actdate+1)
  and PA.PROCESS_NAME = 'ROOT'
  and PA.PROCESS_ITEM_TYPE = itemtype
  and PA.PROCESS_VERSION = A.VERSION
  and PA.INSTANCE_LABEL = root;

  exception
  when no_data_found  then
    g_failedItems:=l_itemkeys;

    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('NAME', root);
    Wf_Core.Raise('WFENG_PROCESS_RUNNABLE');
  end ;
  -- Check for the length of the parent_context if it is provided
     if (parent_context is NOT null and (length(parent_context) > 25)) then
          g_failedItems:=l_itemkeys;
          WF_CORE.Token('LABEL', parent_context);
          WF_CORE.Token('LENGTH', '25');
          WF_CORE.Raise('WFENG_LABEL_TOO_LARGE');
     end if;
  -- Check for duplicate item. Not needed as BulkCreateItems would validate this

    --  Clear plsql cache first, just in case previous
    -- item was purged/rolled back, then check for duplicate.
/*    Wf_Item.ClearCache;
    -- loop through all  itemkeys in the list to check for duplicate
    for arrInd in itemkeys.FIRST..itemkeys.LAST loop
     if (Wf_Item.Item_Exist(itemtype, itemkeys(arrInd))) then
         foundDuplicate:=TRUE;
         g_FailedItems(g_FailedItems.COUNT+1):=itemkeys(arrInd);
         itemkeys.delete(arrInd);
         user_keys.delete(arrInd);
         owner_roles.delete(arrInd);
     end if;
    end loop;
    if foundDuplicate then -- we need to condense the itemkeys and the userkeys,ownerroles etc
       ConsolidateKeys(ItemKeys,User_Keys,Owner_Roles);
    end if;*/

    g_SuccessItems:=l_ItemKeys;
    -- Bulk Insert rows in items table
    Wf_Engine_Bulk.BulkCreateItems(itemtype, root, actdate,l_user_keys,
                      l_owner_roles, parent_itemtype, parent_itemkey,parent_context);


    -- Build the array of random numbers for monitor and access key attributes
    schemaAttribute:=Wf_Engine_Bulk.Current_Schema;
    if g_successItems.count>0 then
    for arrInd in g_SuccessItems.first..g_SuccessItems.last loop
       mon_random(arrInd)   := Wf_Core.Random;
       acc_random(arrInd)   := Wf_Core.Random;

    end loop;
    end if;
    -- Create monitor access key attributes
    Wf_Engine_Bulk.BulkAddItemAttr(itemtype, wf_engine.wfmon_mon_key,
        mon_random);
    Wf_Engine_Bulk.BulkAddItemAttr(itemtype, wf_engine.wfmon_acc_key,
        acc_random);

    l_itemkeys:=g_SuccessItems;
    -- Create a schema attribute across the itemkeys
   if l_itemkeys.count>0 then
   begin
    forall arrInd in l_itemkeys.FIRST..l_itemkeys.LAST SAVE EXCEPTIONS
    insert into WF_ITEM_ATTRIBUTE_VALUES (
      ITEM_TYPE,
      ITEM_KEY,
      NAME,
      TEXT_VALUE
    ) values (
      itemtype,
      l_itemkeys(arrInd),
      wf_engine.eng_schema,
      schemaAttribute
    );

  exception
   when others then
      if SQL%BULK_EXCEPTIONS.COUNT>0 then

       -- load the failedItems table with the list of errored itemkeys,
       -- and remove them from the itemkeys table
       for failIndex in 1..SQL%BULK_EXCEPTIONS.COUNT loop
         g_FailedItems(g_FailedItems.COUNT+1):=
                l_itemkeys(SQL%BULK_EXCEPTIONS(failIndex).ERROR_INDEX);
         l_itemkeys.DELETE(SQL%BULK_EXCEPTIONS(failIndex).ERROR_INDEX);
       end loop;
       ConsolidateKeys(l_itemkeys,l_ukeys,l_rkeys);
      end if;
  end;
  end if;
  g_SuccessItems:=l_itemkeys;

  if (l_itemkeys.count > 0 )
  and (parent_itemtype is not null )
  and (parent_itemkey is not null) then
  --Setting the parent information
  if (masterdetail) then
    --Increment #WAITFORDETAIL master counter if it exists.
    if (WF_ENGINE.AddToItemAttrNumber(parent_itemtype, parent_itemkey,
                                      '#WAITFORDETAIL', l_itemkeys.count) is NOT NULL) then
      if (parent_context is NOT null) then
        --Increment/Create label counter.
        if (WF_ENGINE.AddToItemAttrNumber(parent_itemType, parent_itemKey,
                                             '#CNT_'||parent_context, l_itemkeys.count)
                                              is NULL) then
          WF_ENGINE.AddItemAttr(itemType=>parent_itemType,
                                itemKey=>parent_itemKey,
                                aname=>'#CNT_'||parent_context,
                                number_value=>l_itemkeys.count);
        end if; --Label Counter exists
        begin
        forall arrInd in l_itemkeys.FIRST..l_itemkeys.LAST SAVE EXCEPTIONS
        insert into WF_ITEM_ATTRIBUTE_VALUES (
        ITEM_TYPE,
        ITEM_KEY,
        NAME,
        TEXT_VALUE
        ) values (
        itemtype,
        l_itemkeys(arrInd),
        '#LBL_'||parent_context,
        parent_context
        );

        exception
        when others then
         if SQL%BULK_EXCEPTIONS.COUNT>0 then

         -- load the failedItems table with the list of errored itemkeys,
         -- and remove them from the itemkeys table
            for failIndex in 1..SQL%BULK_EXCEPTIONS.COUNT loop
                g_FailedItems(g_FailedItems.COUNT+1):=
                   l_itemkeys(SQL%BULK_EXCEPTIONS(failIndex).ERROR_INDEX);
                l_itemkeys.DELETE(SQL%BULK_EXCEPTIONS(failIndex).ERROR_INDEX);
            end loop;
            ConsolidateKeys(l_itemkeys,l_ukeys,l_rkeys);
         end if;
       end;
      else
        -- Parent context is null
        -- increase all known #CNT counter by the number of itemkeys
        l_count:= l_itemkeys.count;
        update WF_ITEM_ATTRIBUTE_VALUES
        set NUMBER_VALUE = NUMBER_VALUE + l_count
        where NAME like '#CNT_%'
        and NUMBER_VALUE is not null
        and ITEM_TYPE = parent_itemType
        and ITEM_KEY = parent_itemKey;
      end if; --Parent context is not null
    end if; --#WAITFORDETAIL exists
  end if; --Caller is signalling that this "should" be a coordinated flow.
  end if;

  g_successItems:=l_itemKeys;
   --finally raise exception if the FailedItems table is non-empty
  if g_FailedItems.COUNT>0 then
   WF_CORE.Token('TYPE',itemtype);
   WF_CORE.Token('FAILED',to_char(g_FailedItems.count));
   WF_CORE.TOKEN('TOTAL', to_char(itemkeys.COUNT));
   WF_CORE.RAISE('WFENG_BULK_OPER');
  end if;

exception
 when others then
  Wf_Core.Context('Wf_Engine_Bulk', 'CreateProcess', itemtype, process);
  raise;
end CreateProcess;

----------------------------------------------------------------

--
-- BulkStartProcess (PUBLIC)
--   Begins execution of the process.It identifies the start activities
--   for the run-time process and launches them in bulk for all the item keys
--   in the list, under the given itemtype.
-- IN
--   itemtype - A valid item type
--   itemkeys  - A list of itemkeys generated from the application object's
--               primary key.
--
procedure StartProcess(itemtype in varchar2,
                       itemkeys  in wf_engine_bulk.itemkeytabtype)
is


  -- Select all the start activities in this parent process with
  -- no in-transitions.
  cursor starter_children (itemtype in varchar2,
                           process in varchar2,
                           version in number) is
    SELECT PROCESS_ITEM_TYPE, PROCESS_NAME, PROCESS_VERSION,
           ACTIVITY_ITEM_TYPE, ACTIVITY_NAME, INSTANCE_ID,
           INSTANCE_LABEL, PERFORM_ROLE, PERFORM_ROLE_TYPE,
           START_END, DEFAULT_RESULT
    FROM   WF_PROCESS_ACTIVITIES WPA
    WHERE  WPA.PROCESS_ITEM_TYPE = itemtype
    AND    WPA.PROCESS_NAME = process
    AND    WPA.PROCESS_VERSION = version
    AND    WPA.START_END = wf_engine.eng_start
    AND NOT EXISTS (
      SELECT NULL
      FROM WF_ACTIVITY_TRANSITIONS WAT
      WHERE WAT.TO_PROCESS_ACTIVITY = WPA.INSTANCE_ID);

  TYPE DateTabType is table of DATE index by binary_integer;
  TYPE NumTabType  is table of NUMBER index by binary_integer;
  TYPE RawTabType is table of RAW(16) index by binary_integer;
  type InstanceArrayTyp is table of pls_integer index by binary_integer;

  childarr InstanceArrayTyp;  -- Place holder for all the instance id
                              -- selected from starter_children cursor
  i pls_integer := 0;         -- Counter for the for loop
  process varchar2(30) := ''; -- root process activity name
  version pls_integer;        -- root process activity version
  processid pls_integer;
  actdate date;
  rerun varchar2(8);         -- Activity rerun flag
  acttype  varchar2(8);      -- Activity type
  cost  number;              -- Activity cost
  ftype varchar2(30);        -- Activity function type
  defer_mode boolean := FALSE;

  TransitionCount pls_integer := 0;
  l_baseLnk       NUMBER;
  l_prevLnk       NUMBER;
  psaIND          NUMBER;
  l_linkCollision BOOLEAN;
  status          PLS_INTEGER;

 root varchar2(30);          -- Root process of activity

  rootid  pls_integer;        -- Id of root process
  act_fname varchar2(240);
  act_ftype varchar2(30);
  delay  number; -- dont use pls_integer or numeric overflow can occur.
  msg_id  raw(16):=null;
  l_result number;

  -- Timeout processing stuff
  duedate date;
  timeout number;
  msg varchar2(30);
  msgtype varchar2(8);
  expand_role varchar2(8);

  duedateTab DateTabType;
  execCountTab numTabType;
  msgIdTab  RawTabType;
  l_itemkeys wf_engine_bulk.itemkeytabtype;
  l_rkeys wf_engine_bulk.ownerroleTabType;
  l_ukeys wf_engine_bulk.userkeyTabType;
begin
  -- Check if the item exists and also get back the root process name
  -- and version. We assume that the process and version are identical
  -- across the itemkeys in the list so that they need to be retieved
  -- only for the first itemkey in the list.

  l_itemkeys:=itemkeys;

  --reset the tables of successful and failed items
  g_failedItems.DELETE;
  g_successItems.DELETE;
  begin
  select WI.ROOT_ACTIVITY, WI.ROOT_ACTIVITY_VERSION
  into   process,version
  from WF_ITEMS WI
  where WI.ITEM_TYPE = itemtype
  and WI.ITEM_KEY = l_itemkeys(1);
 exception
   when no_Data_found then
    g_FailedItems:=l_itemkeys;
    Wf_Core.Token('TYPE', itemtype);
    Wf_Core.Token('KEY', l_itemkeys.FIRST);
    Wf_Core.Raise('WFENG_ITEM');

  end;

  -- Get the id of the process root.
    processid := Wf_Process_Activity.RootInstanceId(itemtype, l_itemkeys(l_itemkeys.FIRST),
                                                  process);
    if (processid is null) then

     g_FailedItems:=itemkeys;

     Wf_Core.Token('TYPE', itemtype);
     Wf_Core.Token('NAME', process);
     Wf_Core.Raise('WFENG_PROCESS_RUNNABLE');
    end if;


     --increment the execution time counter value
    g_execCount:=g_execCount+1;

    -- bulk insert into WF_ITEM_ACTIVITY_STATUSES
     begin
     forall arrInd in l_itemkeys.FIRST..l_itemkeys.LAST save exceptions
      insert
        into WF_ITEM_ACTIVITY_STATUSES (
        ITEM_TYPE,
        ITEM_KEY,
        PROCESS_ACTIVITY,
        ACTIVITY_STATUS,
        ACTIVITY_RESULT_CODE,
        ASSIGNED_USER,
        NOTIFICATION_ID,
        BEGIN_DATE,
        END_DATE,
        DUE_DATE,
        EXECUTION_TIME,
        OUTBOUND_QUEUE_ID
      ) values (
        itemtype,
        l_itemkeys(arrInd),
        processid,
        wf_engine.eng_active,
        wf_engine.eng_null,
        null,
        null,
        SYSDATE,
        null,
        null,
        g_execCount,
       null
      );
   exception
    when others then
     if sql%bulk_exceptions.count > 0 then
      for arrIndex in 1.. sql%bulk_exceptions.count loop

        g_failedItems(g_failedItems.COUNT+1) := l_itemkeys(sql%bulk_exceptions
                                             (arrIndex).ERROR_INDEX);
        l_itemkeys.DELETE(sql%bulk_exceptions(arrIndex).ERROR_INDEX);
      end loop;
     end if;
  end;

  if g_failedItems.COUNT>0 then
   ConsolidateKeys(l_itemkeys,l_ukeys,l_rkeys);
  end if;


  -- Retrieve the starting activities from cache.
  WF_CACHE.GetProcessStartActivities(itemType=>itemtype,
                                     name=>process,
                                     version=>version,
                                     status=>status,
                                     psaIND=>psaIND);

  if (status <> WF_CACHE.task_SUCCESS) then
    -- Starting activities are not in cache, so we will store them using a for
    -- loop to get all the next transition activities.
    -- Then we will access the list from cache to avoid maximum open cursor
    -- problem.  First we need to retain the base index to be used later.
    l_baseLnk := psaIND;
    l_linkCollision := FALSE;
    for child in starter_children(itemtype, process, version) loop
      if (TransitionCount > 0) then --Second and succeeding iterations
        --We will locally store the record index from the last loop iteration.
        l_prevLnk := psaIND;
        --We will now generate an index for the start activity from the
        --itemType, name, version, and the current INSTANCE_ID
        psaIND := WF_CACHE.HashKey(itemType||':'||process||':'||version||
                      ':'||WF_CACHE.ProcessStartActivities(psaIND).INSTANCE_ID);

        --Check to make sure a record is not already here.
        if (WF_CACHE.ProcessStartActivities.EXISTS(psaIND)) then
          l_linkCollision := TRUE;  --There should be no record here, so this
                                    --is a hash collision.  We will continue
                                    --populating this linked list, but after
                                    --we use it, we will clear the pl/sql table
        end if;

        --Now the PL/SQL table index has moved to the next link, so we will
        --populate the prev_lnk with our locally stored index.  This feature,
        --not yet used, allows us to traverse backwards through the link list
        --if needed.  Since it is not yet used, it is commented out.
        --WF_CACHE.ProcessStartActivities(psaIND).PREV_LNK := l_prevLnk;

        --l_prevLnk represents the index of the previous record, and we need
        --to update its NEXT_LNK field with the current index.
        WF_CACHE.ProcessStartActivities(l_prevLnk).NEXT_LNK := psaIND;
      --else
      --  WF_CACHE.ProcessStartActivities(psaIND).PREV_LNK := -1;

      end if;

      WF_CACHE.ProcessStartActivities(psaIND).PROCESS_ITEM_TYPE :=
                                                  child.PROCESS_ITEM_TYPE;

      WF_CACHE.ProcessStartActivities(psaIND).PROCESS_NAME :=
                                                  child.PROCESS_NAME;

      WF_CACHE.ProcessStartActivities(psaIND).PROCESS_VERSION :=
                                                      child.PROCESS_VERSION;

      WF_CACHE.ProcessStartActivities(psaIND).INSTANCE_ID := child.INSTANCE_ID;

      --While we are here, we can populate the ProcessActivities cache hoping
      --that a later request of any of these process activities will save us
      --another trip to the DB.
      WF_CACHE.ProcessActivities(child.INSTANCE_ID).PROCESS_ITEM_TYPE :=
                                                    child.PROCESS_ITEM_TYPE;
      WF_CACHE.ProcessActivities(child.INSTANCE_ID).PROCESS_NAME :=
                                                    child.PROCESS_NAME;
      WF_CACHE.ProcessActivities(child.INSTANCE_ID).PROCESS_VERSION :=
                                                    child.PROCESS_VERSION;
      WF_CACHE.ProcessActivities(child.INSTANCE_ID).ACTIVITY_ITEM_TYPE :=
                                                    child.ACTIVITY_ITEM_TYPE;
      WF_CACHE.ProcessActivities(child.INSTANCE_ID).ACTIVITY_NAME :=
                                                    child.ACTIVITY_NAME;
      WF_CACHE.ProcessActivities(child.INSTANCE_ID).INSTANCE_ID :=
                                                    child.INSTANCE_ID;
      WF_CACHE.ProcessActivities(child.INSTANCE_ID).INSTANCE_LABEL :=
                                                    child.INSTANCE_LABEL;
      WF_CACHE.ProcessActivities(child.INSTANCE_ID).PERFORM_ROLE :=
                                                    child.PERFORM_ROLE;
      WF_CACHE.ProcessActivities(child.INSTANCE_ID).PERFORM_ROLE_TYPE :=
                                                    child.PERFORM_ROLE_TYPE;
      WF_CACHE.ProcessActivities(child.INSTANCE_ID).START_END :=
                                                    child.START_END;
      WF_CACHE.ProcessActivities(child.INSTANCE_ID).DEFAULT_RESULT :=
                                                    child.DEFAULT_RESULT;

      TransitionCount := TransitionCount+1;
    end loop;
    WF_CACHE.ProcessStartActivities(psaIND).NEXT_LNK := -1;
    psaIND := l_baseLnk; --Reset the index back to the beginning.
    status := WF_CACHE.task_SUCCESS;  --We now have the records successfully
                                      --in cache.

  end if;

  -- Load a local InstanceArrayTyp, we do this because of the recursion that
  -- occurs.  Since the ProcessStartActivities Cache is global, any
  -- hashCollision would clear the cache and could cause problems as we
  -- process activities in recursive calls.
  while (psaIND <> -1) loop
    childarr(i) := WF_CACHE.ProcessStartActivities(psaIND).INSTANCE_ID;
    i := i+1;
    psaIND := WF_CACHE.ProcessStartActivities(psaIND).NEXT_LNK;
  end loop;
  childarr(i) := '';

  if (l_linkCollision) then
    --When populating the linked list, we discovered that a hash collision
    --caused us to overwrite a link belonging to another list.  This would
    --cause the other list to be incorrect.  We will clear the table so the
    --lists will be rebuilt after this transaction.
    WF_CACHE.ProcessStartActivities.DELETE;

  end if;


  i:=0;

  -- for each child activity, do a bulk defer of all the itemkeys in the list

  while (childarr(i) is not null) loop

    begin


     -- calculate the activity function name and type
      act_fname:= Wf_Activity.activity_function(itemtype,l_itemkeys(l_itemkeys.FIRST),childarr(i));
      act_ftype:= Wf_Activity.activity_function_type(itemtype,l_itemkeys(l_itemkeys.FIRST),childarr(i));


      --depending on the activity function, enqueue on the proper queue.

         if l_itemkeys.COUNT <=0 then
           WF_CORE.Token('TYPE',itemtype);
           WF_CORE.Token('FAILED',to_char(g_FailedItems.count));
           WF_CORE.TOKEN('TOTAL',to_char(itemkeys.COUNT));
           WF_CORE.RAISE('WFENG_BULK_OPER');
           exit;
         end if;

         --reset the duedate, msgid tables

         dueDateTab.delete;

         msgIdTab.delete;
         -- increment the execution time counter
         g_execCount:=g_execCount+1;

         for arrInd in l_itemkeys.FIRST..l_itemkeys.LAST loop
         begin
           -- 1. Look first for a '#TIMEOUT' NUMBER attribute
          timeout := Wf_Engine.GetActivityAttrNumber(itemtype, l_itemkeys(arrInd),childarr(i),
                     wf_engine.eng_timeout_attr,
                     ignore_notfound=>TRUE);

          if (nvl(timeout, 0) <> 0) then
             -- Figure duedate as offset from begin time.
             -- NOTE: Default timeout is in units of minutes, not days like
             -- all other 'date as number' values, thus the 1440 fudge factor.
             duedate:= SYSDATE + (timeout / 1440);
          else
             -- 2. Look for a '#TIMEOUT' DATE attribute
             duedate := Wf_Engine.GetActivityAttrDate(itemtype, l_itemkeys(arrInd),
                         childarr(i), wf_engine.eng_timeout_attr,
                         ignore_notfound=>TRUE);
          end if;
         exception
          when others then
            if (wf_core.error_name = 'WFENG_ACTIVITY_ATTR') then
              -- No #TIMEOUT attr means no timeout
              wf_core.clear;
              duedate:= null;
            end if;
         end;

        -- depending on the activity function type enqueue on the appropriate queue

         begin

           delay:=0;

           if act_ftype = 'PL/SQL'  then

            wf_queue.enqueue_event
            (queuename=>wf_queue.DeferredQueue,
             itemtype=> itemtype,
             itemkey=>l_itemkeys(arrInd),
             actid=>childarr(i),
             delay=>delay,
             message_handle=>msg_id);
            -- even when internal, keep message for cross reference.
            -- msg_id :=null;



           elsif act_ftype = 'EXTERNAL' then
           -- this is a callout so write to OUTBOUND queue
           -- do not set the correlation here for compatibility reason


            wf_queue.enqueue_event
            (queuename=>wf_queue.OutboundQueue,
             itemtype=>itemtype,
             itemkey=>l_itemkeys(arrInd),
             actid=>childarr(i),
             funcname=>act_fname,
             paramlist=>wf_queue.get_param_list
                       (itemtype,l_itemkeys(arrInd),childarr(i)),
             message_handle=>msg_id);

           else
           -- this is a callout so write to OUTBOUND queue for other type

            wf_queue.enqueue_event
            (queuename=>wf_queue.OutboundQueue,
             itemtype=>itemtype,
             itemkey=>l_itemkeys(arrInd),
             actid=>childarr(i),
             correlation=>act_ftype,
             funcname=>act_fname,
             paramlist=>wf_queue.get_param_list
                        (itemtype,l_itemkeys(arrInd),childarr(i)),
             message_handle=>msg_id);

           end if;
           duedateTab(duedateTab.count+1):=duedate;
           msgIdTab(msgidtab.count+1):=msg_id;
         exception
            when others then

             g_faileditems(g_faileditems.count+1):=l_itemkeys(arrInd);
             l_itemkeys.DELETE(arrInd);
         end;
         end loop;
         if g_failedItems.COUNT>0 then
            for arrInd in l_itemkeys.first..l_itemkeys.last loop
               if not l_itemkeys.exists(arrInd)  then

               --fill in the gap with the last list element
                    l_itemkeys(arrInd):=l_itemkeys(l_itemkeys.last);

                    -- accordingly re-arrange the duedate,and msgid arrays
                    -- so as not to lose one-to-one correspondence
                    duedateTab(arrInd):=duedateTab(duedateTab.last);
                    msgIdTab(arrInd):=msgIdTab(msgIdTab.last);
                    l_itemkeys.delete(l_itemkeys.last);
                    msgIdTab.delete(msgIdTab.last);
                    duedateTab.delete(duedateTab.last);
               end if;
             end loop;
         end if;


        -- finally bulk insert the activity, with status as 'DEFERRED'
        -- for all the itemkeys.
      if l_itemkeys.count>0 then
      begin
      forall arrInd in l_itemkeys.FIRST..l_itemkeys.LAST save exceptions
        insert
        into WF_ITEM_ACTIVITY_STATUSES (
        ITEM_TYPE,
        ITEM_KEY,
        PROCESS_ACTIVITY,
        ACTIVITY_STATUS,
        ACTIVITY_RESULT_CODE,
        ASSIGNED_USER,
        NOTIFICATION_ID,
        BEGIN_DATE,
        END_DATE,
        DUE_DATE,
        EXECUTION_TIME,
        OUTBOUND_QUEUE_ID
      ) values (
        itemtype,
        l_itemkeys(arrInd),
        childarr(i),
        'DEFERRED',
        null,
        null,
        null,
        SYSDATE,
        null,
        duedateTab(arrInd),
        g_execCount,
        msgIdTab(arrInd)
      );
      exception
      when others then
           if sql%bulk_exceptions.count>0 then
             for failindex in 1.. sql%bulk_exceptions.count loop

              g_failedItems(g_faileditems.count+1):=
                   l_itemkeys( sql%bulk_exceptions(failindex).error_index);
              l_itemkeys.DELETE(sql%bulk_exceptions(failindex).error_index);
             end loop;
             ConsolidateKeys(l_itemkeys,l_ukeys,l_rkeys);
           end if;
      end;
      end if;
   end;
   i:= i+1;
  end loop;--child activities


   -- Report an error if no start activities can be found.
   if (i = 0) then

     g_FailedItems:=itemkeys;
     Wf_Core.Token('PROCESS', process);
     Wf_Core.Raise('WFENG_NO_START');
  end if;
  g_successItems:=l_ItemKeys;
  -- Report Error if Failure has occured for some item keys
  if g_failedItems.COUNT>0 then
   WF_CORE.Token('TYPE',itemtype);
   WF_CORE.Token('FAILED',to_char(g_FailedItems.count));
   WF_CORE.TOKEN('TOTAL',to_char(g_successItems.COUNT));
   WF_CORE.RAISE('WFENG_BULK_OPER');
  end if;
exception
    when others then
     Wf_Core.Context('Wf_Engine_Bulk','StartProcess',
        itemtype);
       raise;
end StartProcess;

-- FastForward (PUBLIC)
--
--This API starts a specific activity for a list of items. This activity
--must be marked as start, but does not need to be an activity without
--any in transition.This API would fast forward the launch process by
--bulk-creating the items, bulk initializing item attributes and bulk
--starting a specified startactivity within the process across all the
--itemkeys.The activity must be a direct child of the root process specified.

-- IN
--   itemtype      - A valid item type
--   itemkeys      - A list of itemkeys generated from the application object's
--                   primary key.
--   process       - The process to be started
--   activity      - The label of the specific activity within the process to be started.
--   activityStatus - The status of the activity.This should be restricted to 'NOTIFIED'
--                     and 'DEFERRED' only.

procedure FastForward(itemtype in varchar2,
                      itemkeys  in wf_engine_bulk.itemkeytabtype,
                      process in varchar2,
                      activity in varchar2,
                      activityStatus in varchar2,
                      parent_itemtype in varchar2,
                      parent_itemkey in varchar2,
                      parent_context in varchar2,
                      masterdetail   in boolean)
is



  TYPE DateTabType is table of DATE index by binary_integer;
  TYPE NumTabType  is table of NUMBER index by binary_integer;
  TYPE RawTabType is table of RAW(16) index by binary_integer;

  i pls_integer := 0;         -- Counter for the for loop
  version pls_integer;        -- root process activity version
  processid pls_integer;
  actdate date;
  rerun varchar2(8);         -- Activity rerun flag
  acttype  varchar2(8);      -- Activity type
  cost  number;              -- Activity cost
  ftype varchar2(30);        -- Activity function type
  defer_mode boolean := FALSE;
  activity_date date;


 root varchar2(30);          -- Root process of activity
  rootid  pls_integer;        -- Id of root process
  actid   pls_integer;        --Id of the activity to be fast-forwarded
  act_fname varchar2(240);
  act_ftype varchar2(30);
  delay  number; -- dont use pls_integer or numeric overflow can occur.
  msg_id  raw(16):=null;
  l_result number;

  -- Timeout processing stuff
  duedate date;
  timeout number;
  msg varchar2(30);
  msgtype varchar2(8);
  expand_role varchar2(8);

  duedateTab DateTabType;
  execCountTab numTabType;
  msgIdTab  RawTabType;
  l_itemkeys wf_engine_bulk.itemKeyTabType;
  l_ukeys wf_engine_bulk.userkeyTabType;
  l_rkeys wf_engine_bulk.ownerroleTabType;

begin

  -- Validate that the activityStatus is not other than 'DEFERRED' or 'NOTIFIED'
     if activityStatus is not null then
        if activityStatus <> 'DEFERRED' and activityStatus <> 'NOTIFIED' then
           --raise error
           g_failedItems:=itemkeys;
           WF_CORE.RAISE('WFENG_INVALID_ACT_STATUS');
        end if;
     end if;

  -- initialize the itemkeys list
     l_itemkeys:=itemkeys;
  -- Call CreateProcess to Create the Process across all itemkeys
  begin
     WF_ENGINE_BULK.CreateProcess(itemtype,l_itemkeys,process,l_ukeys,l_rkeys,
     parent_itemtype,parent_itemkey,parent_context,masterdetail);
  exception
   when others then

      if g_failedItems.COUNT>0 then

         wf_core.clear;
         l_itemkeys:=g_SuccessItems;
      end if;
  end;
  if l_itemkeys.count<=0 then
   WF_CORE.Token('TYPE',itemtype);
   WF_CORE.Token('FAILED',to_char(itemkeys.count));
   WF_CORE.TOKEN('TOTAL', to_char(itemkeys.count));
   WF_CORE.RAISE('WFENG_BULK_OPER');
  end if;
  --clear the successful items table
     g_SuccessItems.DELETE;

  -- Check if the item exists and also get back the root
  -- version. We assume that the process and version are identical
  -- across the itemkeys in the list so that they need to be retrieved
  -- only for the first itemkey in the list.
   begin
     select WI.ROOT_ACTIVITY_VERSION
     into   version
     from WF_ITEMS WI
     where WI.ITEM_TYPE = itemtype
     and WI.ITEM_KEY = l_itemkeys(1)
     and WI.ROOT_ACTIVITY=process;
   exception
    when no_Data_found then

     g_FailedItems:=l_itemkeys;

     Wf_Core.Token('TYPE', itemtype);
     Wf_Core.Token('KEY', l_itemkeys.FIRST);
     Wf_Core.Raise('WFENG_ITEM');
    end;


    -- Get the id of the process root.
    processid := Wf_Process_Activity.RootInstanceId(itemtype, l_itemkeys(l_itemkeys.FIRST),
                                                  process);

    if (processid is null) then

     g_FailedItems:=itemkeys;

     Wf_Core.Token('TYPE', itemtype);
     Wf_Core.Token('NAME', process);
     Wf_Core.Raise('WFENG_PROCESS_RUNNABLE');
    end if;



    -- determine the instance_id of the activity
    -- raise error if the activity is not found.
   begin

    SELECT WPA.INSTANCE_ID
    into actid
    FROM   WF_PROCESS_ACTIVITIES WPA
    WHERE  WPA.PROCESS_ITEM_TYPE = itemtype
    AND    WPA.PROCESS_NAME = process
    AND    WPA.PROCESS_VERSION = version
    AND    WPA.START_END = wf_engine.eng_start
    AND    WPA.INSTANCE_LABEL=activity;
    Exception
     When no_data_found then

       g_FailedItems:=itemkeys;

       WF_CORE.Token('ACTIVITY',activity);
       WF_CORE.Token('ITEMTYPE',itemtype);
       WF_CORE.Token('PROCESS',process);
       WF_CORE.Raise('ACTIVITY_NOT_FOUND');
    End;

   -- insert the process into the item activity statuses table

   -- increment the execution time counter by 1.
     g_execCount:=g_execCount+1;
    -- bulk insert into WF_ITEM_ACTIVITY_STATUSES
     begin
     forall arrInd in l_itemkeys.FIRST..l_itemkeys.LAST save exceptions
      insert
        into WF_ITEM_ACTIVITY_STATUSES (
        ITEM_TYPE,
        ITEM_KEY,
        PROCESS_ACTIVITY,
        ACTIVITY_STATUS,
        ACTIVITY_RESULT_CODE,
        ASSIGNED_USER,
        NOTIFICATION_ID,
        BEGIN_DATE,
        END_DATE,
        DUE_DATE,
        EXECUTION_TIME,
        OUTBOUND_QUEUE_ID
      ) values (
        itemtype,
        l_itemkeys(arrInd),
        processid,
        wf_engine.eng_active,
        wf_engine.eng_null,
        null,
        null,
        SYSDATE,
        null,
        null,
        g_execCount,
       null
      );
     exception
     when others then
      if sql%bulk_exceptions.count > 0 then
       for arrIndex in 1.. sql%bulk_exceptions.count loop

        g_failedItems(g_failedItems.COUNT+1) :=
              l_itemkeys(sql%bulk_exceptions(arrIndex).ERROR_INDEX);
        l_itemkeys.DELETE(sql%bulk_exceptions(arrIndex).ERROR_INDEX);
       end loop;
      end if;
     end;
     -- in case failed itemkeys have been removed
     -- condense the sparsely populated itemkey list
     if g_failedItems.COUNT>0 then
      ConsolidateKeys(l_itemkeys,l_ukeys,l_rkeys);
     end if;

     -- defer and enqueue the given activity across all itemkeys
     begin

       -- calculate the activity function name and type
       act_fname:= Wf_Activity.activity_function(itemtype,l_itemkeys(l_itemkeys.first),actid);
       act_ftype:= Wf_Activity.activity_function_type(itemtype,l_itemkeys(l_itemkeys.first),actid);



       if l_itemkeys.COUNT <=0 then

                 g_FailedItems:=itemkeys;

                 WF_CORE.Token('TYPE',itemtype);
                 WF_CORE.Token('FAILED', to_char(g_FailedItems.count));
                 WF_CORE.TOKEN('TOTAL', to_char(itemkeys.count));
                 WF_CORE.RAISE('WFENG_BULK_OPER');
                 return;
       end if;

       --reset the duedate, msgid tables

       dueDateTab.delete;

       msgIdTab.delete;
       -- increment the execution time counter
       g_execCount:=g_execCount +1;

       for arrInd in l_itemkeys.FIRST..l_itemkeys.LAST loop
       begin
         -- 1. Look first for a '#TIMEOUT' NUMBER attribute
          timeout := Wf_Engine.GetActivityAttrNumber(itemtype,
                      l_itemkeys(arrInd),actid,
                     wf_engine.eng_timeout_attr,
                       ignore_notfound=>TRUE);

          if (nvl(timeout, 0) <> 0) then
             -- Figure duedate as offset from begin time.
             -- NOTE: Default timeout is in units of minutes, not days like
             -- all other 'date as number' values, thus the 1440 fudge factor.
             duedate:= SYSDATE + (timeout / 1440);
          else
             -- 2. Look for a '#TIMEOUT' DATE attribute
             duedate := Wf_Engine.GetActivityAttrDate
                        (itemtype, l_itemkeys(arrInd),actid,
                        wf_engine.eng_timeout_attr,
                        ignore_notfound=>TRUE);
          end if;
       exception
          when others then
            if (wf_core.error_name = 'WFENG_ACTIVITY_ATTR') then
              -- No #TIMEOUT attr means no timeout
              wf_core.clear;
              duedate:= null;
            end if;
       end;

       -- we enqueue only if the activityStatus is 'DEFERRED' or null

       delay:=0;
       msg_id :=null;
       begin
       if activityStatus is null or activityStatus='DEFERRED' then
           if act_ftype = 'PL/SQL' then
            wf_queue.enqueue_event
            (queuename=>wf_queue.DeferredQueue,
             itemtype=> itemtype,
             itemkey=>l_itemkeys(arrInd),
             actid=>actid,
             delay=>delay,
             message_handle=>msg_id);
            -- even when internal, keep message for cross reference.
            -- msg_id :=null;



           elsif act_ftype = 'EXTERNAL' then
           -- this is a callout so write to OUTBOUND queue
           -- do not set the correlation here for compatibility reason


            wf_queue.enqueue_event
            (queuename=>wf_queue.OutboundQueue,
             itemtype=>itemtype,
             itemkey=>l_itemkeys(arrInd),
             actid=>actid,
             funcname=>act_fname,
             paramlist=>wf_queue.get_param_list
                        (itemtype,l_itemkeys(arrInd),actid),
             message_handle=>msg_id);

           else
           -- this is a callout so write to OUTBOUND queue for other type

            wf_queue.enqueue_event
            (queuename=>wf_queue.OutboundQueue,
             itemtype=>itemtype,
             itemkey=>l_itemkeys(arrInd),
             actid=>actid,
             correlation=>act_ftype,
             funcname=>act_fname,
             paramlist=>wf_queue.get_param_list
                        (itemtype,l_itemkeys(arrInd),actid),
             message_handle=>msg_id);

           end if;
        end if;
           duedateTab(duedateTab.count+1):=duedate;

           msgIdTab(msgidtab.count+1):=msg_id;
       exception
              when others then

                 g_faileditems(g_faileditems.count+1):=l_itemkeys(arrInd);
                 l_itemkeys.DELETE(arrInd);
       end;

       end loop;

       if g_failedItems.COUNT>0 then
             for arrInd in l_itemkeys.first..l_itemkeys.last loop
               if not l_itemkeys.exists(arrInd)  then

               --fill in the gap with the last list element
                    l_itemkeys(arrInd):=l_itemkeys(l_itemkeys.last);

                    -- accordingly re-arrange the duedate,and msgid arrays
                    -- so as not to lose one-to-one correspondence
                    duedateTab(arrInd):=duedateTab(duedateTab.last);
                    msgIdTab(arrInd):=msgIdTab(msgIdTab.last);
                    l_itemkeys.delete(l_itemkeys.last);
                    msgIdTab.delete(msgIdTab.last);
                    duedateTab.delete(duedateTab.last);
               end if;
             end loop;
       end if;


       -- finally bulk insert the activity, with status as 'DEFERRED'
       -- for all the itemkeys.
      begin
      forall arrInd in l_itemkeys.FIRST..l_itemkeys.LAST save exceptions
        insert
        into WF_ITEM_ACTIVITY_STATUSES (
        ITEM_TYPE,
        ITEM_KEY,
        PROCESS_ACTIVITY,
        ACTIVITY_STATUS,
        ACTIVITY_RESULT_CODE,
        ASSIGNED_USER,
        NOTIFICATION_ID,
        BEGIN_DATE,
        END_DATE,
        DUE_DATE,
        EXECUTION_TIME,
        OUTBOUND_QUEUE_ID
      ) values (
        itemtype,
        l_itemkeys(arrInd),
	actid,
        nvl(activityStatus,'DEFERRED'),
        null,
        null,
        null,
        SYSDATE,
        null,
        duedateTab(arrInd),
        g_execCount,
        msgIdTab(arrInd)
      );
      exception
      when others then
           if sql%bulk_exceptions.count>0 then
             for failindex in 1.. sql%bulk_exceptions.count loop
              g_failedItems(g_faileditems.count+1):=
              l_itemkeys( sql%bulk_exceptions(failindex).error_index);
              l_itemkeys.DELETE(sql%bulk_exceptions(failindex).error_index);
             end loop;
             ConsolidateKeys(l_itemkeys,l_ukeys,l_rkeys);
           end if;
      end;
   end;
   g_SuccessItems:=l_itemkeys;

  -- Report Error if Failure has occured for some item key
  if g_failedItems.COUNT>0 then
   WF_CORE.Token('TYPE',itemtype);
   WF_CORE.Token('FAILED',to_char(g_FailedItems.count));
   WF_CORE.TOKEN('TOTAL', to_char(itemkeys.COUNT));
   WF_CORE.RAISE('WFENG_BULK_OPER');
  end if;
exception
  when others then
   Wf_Core.Context('Wf_Engine_Bulk','FastForward',
    Itemtype,process,activity);
    raise;


end FastForward;


END WF_ENGINE_BULK;

/
