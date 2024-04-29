--------------------------------------------------------
--  DDL for Package Body WF_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_PURGE" as
/* $Header: wfprgb.pls 120.13.12010000.11 2013/04/04 02:40:02 alsosa ship $ */

--Private Variables
l_docommit boolean;
l_runtimeonly boolean;

-- procedure Move_To_History
--   Move wf_item_activity_status rows for particular itemtype/key from
--   main table to history table.
-- IN:
--   itemtype - Item type to move, or null for all itemtypes
--   itemkey - Item key to move, or null for all itemkeys
--
procedure Move_To_History(
  itemtype in varchar2,
  itemkey in varchar2)
is
begin
  Null;
end Move_To_History;

--
-- procedure Item_Activity_Statuses
--   Delete from wf_item_activity_statuses and wf_item_activity_statuses_h
--   where end_date before argument.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   enddate - Date to obsolete to
--
procedure Item_Activity_Statuses(
  itemtype in varchar2,
  itemkey in varchar2,
  enddate in date)
is
begin
   Null;
end Item_Activity_Statuses;

--
-- procedure Items
--   Delete items with end_time before argument.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   enddate - Date to obsolete to
--   docommit- Do not commit if set to false
--
procedure Items(
  itemtype in varchar2,
  itemkey in varchar2,
  enddate in date,
  docommit in boolean,
  force in boolean,
  purgesigs in pls_integer)
is
  dummy     varchar2(240);
  keep  number;                      -- Bug 1895332
  TYPE nidListTAB IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_nidListTAB nidListTAB;
  l_tempListTAB nidListTAB;
  l_keycount number;
  l_signature boolean := TRUE;
  xenddate date;
  l_ecx_sql  varchar2(2000);

 -- CTILLEY bug 2755885 include rowid in where clause to resolve
 -- infinite loop

 -- CTILLEY bug 3228475 - remove like item type and item key to
 -- performance violation.  Added item5purge to query records
 -- where itemtype is passed but no itemkey.  No longer supporting
 -- partial values for either item type or item key.

   cursor item2purge is
   SELECT WI.ITEM_TYPE, WI.ITEM_KEY
   FROM (SELECT PERSISTENCE_DAYS, NAME
      FROM WF_ITEM_TYPES
      WHERE PERSISTENCE_TYPE = Wf_Purge.persistence_type and NAME=itemtype) WIT, WF_ITEMS WI
   WHERE WI.ITEM_TYPE = WIT.NAME
     AND WI.END_DATE <= enddate-nvl(WIT.PERSISTENCE_DAYS,0)
     AND WI.END_DATE >  xenddate
     AND NOT EXISTS
     (SELECT NULL
      FROM WF_ITEMS WI2
      WHERE WI2.END_DATE IS NULL
      START WITH WI2.ITEM_TYPE = WI.ITEM_TYPE
        AND WI2.ITEM_KEY = WI.ITEM_KEY
      CONNECT BY PRIOR WI2.ITEM_TYPE = WI2.PARENT_ITEM_TYPE
        AND PRIOR  WI2.ITEM_KEY = WI2.PARENT_ITEM_KEY )
     AND NOT EXISTS
     (SELECT NULL
      FROM WF_ITEMS WI2
      WHERE WI2.END_DATE IS NULL
      START WITH WI2.ITEM_TYPE = WI.ITEM_TYPE
        AND WI2.ITEM_KEY = WI.ITEM_KEY
      CONNECT BY PRIOR WI2.PARENT_ITEM_TYPE = WI2.ITEM_TYPE
        AND PRIOR WI2.PARENT_ITEM_KEY = WI2.ITEM_KEY)
     ORDER BY WI.END_DATE;


   -- JWSMITH bug 2070056 - add new cursor for performance
   cursor item3purge is
     select WI.ITEM_TYPE, WI.ITEM_KEY
     from   WF_ITEMS WI
     where  WI.ITEM_TYPE = itemtype
      and   WI.ITEM_KEY = itemkey
      and   WI.end_date <= enddate
       and exists
          (select null
           from WF_ITEM_TYPES WIT
           where WI.END_DATE+nvl(WIT.PERSISTENCE_DAYS,0)<=enddate
           and WI.ITEM_TYPE = WIT.NAME
           and WIT.PERSISTENCE_TYPE = Wf_Purge.persistence_type)
       and not exists
          (select null
           from WF_ITEMS WI2
           WHERE WI2.END_DATE IS NULL
           START WITH WI2.ITEM_TYPE = WI.ITEM_TYPE
           AND WI2.ITEM_KEY = WI.ITEM_KEY
           CONNECT BY PRIOR WI2.ITEM_TYPE = WI2.PARENT_ITEM_TYPE
           AND PRIOR WI2.ITEM_KEY = WI2.PARENT_ITEM_KEY
           UNION ALL
           select null
           from WF_ITEMS WI2
           WHERE WI2.END_DATE IS NULL
           START WITH WI2.ITEM_TYPE = WI.ITEM_TYPE
           AND WI2.ITEM_KEY = WI.ITEM_KEY
           CONNECT BY PRIOR WI2.PARENT_ITEM_TYPE = WI2.ITEM_TYPE
           AND PRIOR WI2.PARENT_ITEM_KEY = WI2.ITEM_KEY);

    -- CTILLEY bug 2642057 - added new cursor for use when FORCE
    -- arg is TRUE.
    cursor item4purge is
      select WI.ITEM_TYPE, WI.ITEM_KEY
      from  WF_ITEMS WI
      where WI.ITEM_KEY = itemkey
      and   WI.ITEM_TYPE = itemtype
      and   WI.end_date <= enddate;

    -- CTILLEY bug 3228475 - Added new cursor to resolve performance violation
    -- of using like condition.  We will no longer support passing partial values
    -- for item type or item key.

   cursor item5purge is
     select /*+ first_rows index(WI,WF_ITEMS_N3) */
            WI.ITEM_TYPE, WI.ITEM_KEY
     from   WF_ITEMS WI
     where  WI.END_DATE <= enddate
     and    WI.END_DATE > xenddate
      and exists
         (select null
          from WF_ITEM_TYPES WIT
          where WI.END_DATE+nvl(WIT.PERSISTENCE_DAYS,0)<=enddate
          and WI.ITEM_TYPE = WIT.NAME
          and WIT.PERSISTENCE_TYPE = Wf_Purge.persistence_type)
      and not exists
         (select null
          from WF_ITEMS WI2
          WHERE WI2.END_DATE IS NULL
          START WITH WI2.ITEM_TYPE = WI.ITEM_TYPE
          AND WI2.ITEM_KEY = WI.ITEM_KEY
          CONNECT BY PRIOR WI2.ITEM_TYPE = WI2.PARENT_ITEM_TYPE
          AND PRIOR WI2.ITEM_KEY = WI2.PARENT_ITEM_KEY
          UNION ALL
          select null
          from WF_ITEMS WI2
          WHERE WI2.END_DATE IS NULL
          START WITH WI2.ITEM_TYPE = WI.ITEM_TYPE
          AND WI2.ITEM_KEY = WI.ITEM_KEY
          CONNECT BY PRIOR WI2.PARENT_ITEM_TYPE = WI2.ITEM_TYPE
          AND PRIOR WI2.PARENT_ITEM_KEY = WI2.ITEM_KEY);

  no_lock exception;
  pragma EXCEPTION_INIT(no_lock, -54);

  -- ora-2292 = integrity constraint (%s.%s) violated - child record found
  in_other_status_table exception;
  pragma EXCEPTION_INIT(in_other_status_table, -02292);

  -- CTILLEY 2755885
  -- ora-1436 CONNECT BY loop in user data - parent_item_type = item_type
  connect_by_loop exception;
  pragma EXCEPTION_INIT(connect_by_loop,-1436);

  -- <rwunderl:3751558>
  invalid_component exception;
  pragma EXCEPTION_INIT(invalid_component, -302);

  invalid_identifier exception;
  pragma EXCEPTION_INIT(invalid_identifier, -201);
  -- </rwunderl:3751558>
begin

  xenddate := to_date(1, 'J');
  -- Disallow future date in enddate
  -- Avoid something being purged before its defined persistence period.
  if (enddate > sysdate) then
    Wf_Core.Token('SYSDATE', to_char(sysdate));
    Wf_Core.Raise('WF_FUTURE_END_DATE');
  end if;

  if ((itemkey is not null and (instr(itemkey,'%')>0 or itemtype is null))
      or (instr(itemtype,'%')>0)) then
        wf_core.raise('WFSQL_ARGS');
  end if;

  -- Build ECX Purge sql
  --<rwunderl:3751558>
  l_ecx_sql := 'begin ECX_PURGE.Purge_Items(:1, :2, :3, ';
  if (l_docommit) then
    l_ecx_sql := l_ecx_sql||'TRUE';
  else
    l_ecx_sql := l_ecx_sql||'FALSE';
  end if;

  if (nvl(l_runtimeonly, TRUE)) then
    l_ecx_sql := l_ecx_sql||', TRUE';
  else
    l_ecx_sql := l_ecx_sql||', FALSE';
  end if;

  l_ecx_sql := l_ecx_sql||'); end;';
  --</rwunderl:3751558>

  -- for all items that are valid to purge
  -- outer loop for purging items.

  <<outer_purge>>
  loop

    if (force) then   -- CTILLEY bug 2642057
      open item4purge;
    -- JWSMITH bug 2070056
    -- CTILLEY bug 3228475 - no longer supporting partial values for itemtype
    -- and itemkey.
    elsif (itemtype is not null and itemkey is null) then
        open item2purge;
    elsif (itemtype is not null) then
        open item3purge;
    else
        open item5purge;
    end if;

    <<item_purge_loop>>
    loop

       -- CTILLEY bug 2642057
       if (force) then
          -- Bug 4163328
          -- Use bulk operations to improve performance
          FETCH item4purge BULK COLLECT INTO l_itemtypeTAB,
                                             l_itemkeyTAB LIMIT wf_purge.commit_frequency;
      	  exit outer_purge when l_itemkeyTAB.COUNT = 0;

       -- JWSMITH bug 2070056
       elsif (itemtype is not null and itemkey is null) then
          FETCH item2purge BULK COLLECT INTO l_itemtypeTAB,
                                             l_itemkeyTAB LIMIT wf_purge.commit_frequency;
          exit outer_purge when l_itemkeyTAB.COUNT = 0;

       -- CTILLEY bug 3228475
       elsif (itemtype is not null) then
          FETCH item3purge BULK COLLECT INTO l_itemtypeTAB,
                                             l_itemkeyTAB LIMIT wf_purge.commit_frequency;
          exit outer_purge when l_itemkeyTAB.COUNT = 0;

       else
          FETCH item5purge BULK COLLECT INTO l_itemtypeTAB,
                                             l_itemkeyTAB LIMIT wf_purge.commit_frequency;
          exit outer_purge when l_itemkeyTAB.COUNT = 0;
       end if;

    l_keycount := l_itemkeyTAB.COUNT;

    -- set row lock on item
    <<outer_lock_loop>>
    FOR j IN l_itemkeyTAB.FIRST..l_itemkeyTAB.LAST loop

      if (j > l_itemkeyTAB.LAST) then
        exit;
      end if;

      -- If we cannot lock current item, try to lock the last item on the index table.
      -- If we cannot acquire lock on the last item, delete last item and get the
      -- next last item on the index table until we can acquire a lock.
      if ( not (wf_item.acquire_lock(l_itemtypeTAB(j), l_itemkeyTAB(j), FALSE))) then
        <<lock_loop>>
	    loop
	      if (l_itemkeyTAB.COUNT < j ) then
	        exit outer_lock_loop;

          elsif (wf_item.acquire_lock(l_itemtypeTAB(l_itemtypeTAB.LAST),
            l_itemkeyTAB(l_itemkeyTAB.LAST), FALSE)) then

            -- Once we acquired a lock on a last item, copy the last time to
            -- the current index so that we have a dense index table.
            l_itemkeyTAB(j) := l_itemkeyTAB(l_itemkeyTAB.LAST);
            l_itemtypeTAB(j) := l_itemtypeTAB(l_itemtypeTAB.LAST);
            l_itemkeyTAB.DELETE(l_itemkeyTAB.LAST);
            l_itemtypeTAB.DELETE(l_itemtypeTAB.LAST);
            exit lock_loop;
          else
            l_itemkeyTAB.DELETE(l_itemkeyTAB.LAST);
            l_itemtypeTAB.DELETE(l_itemtypeTAB.LAST);
          end if;
        end loop lock_loop;
      end if;
    end loop outer_lock_loop;

    if (l_itemkeyTAB.COUNT > 0) then

      FOR j IN l_itemkeyTAB.FIRST..l_itemkeyTAB.LAST loop
        begin
          select   WN.NOTIFICATION_ID
	  BULK COLLECT into l_tempListTAB
	    from   WF_ITEM_ACTIVITY_STATUSES WIAS,
	           WF_NOTIFICATIONS WN
	    where  WIAS.ITEM_TYPE = l_itemtypeTAB(j)
	    and    WIAS.ITEM_KEY  = l_itemkeyTAB(j)
	    and    WIAS.NOTIFICATION_ID = WN.GROUP_ID
            and    ((purgesigs = 1)
		    or not exists
	            (select null
                     from   WF_DIG_SIGS WDS
                     where  SIG_OBJ_TYPE = 'WF_NTF'
                     and    SIG_OBJ_ID = WN.NOTIFICATION_ID))
	   union all
	   select WN.NOTIFICATION_ID
	    from   WF_ITEM_ACTIVITY_STATUSES_H WIASH,
	           WF_NOTIFICATIONS WN
	    where  WIASH.ITEM_TYPE = l_itemtypeTAB(j)
	    and    WIASH.ITEM_KEY  = l_itemkeyTAB(j)
	    and    WIASH.NOTIFICATION_ID = WN.GROUP_ID
            and    ((purgesigs = 1)
		    or not exists
	            (select null
                     from   WF_DIG_SIGS WDS
                     where  SIG_OBJ_TYPE = 'WF_NTF'
                     and    SIG_OBJ_ID = WN.NOTIFICATION_ID));

	  if (l_tempListTAB.COUNT > 0) then
	    FOR i IN l_tempListTAB.FIRST..l_tempListTAB.LAST loop
                l_nidListTAB(l_nidListTAB.COUNT + 1) := l_tempListTAB(i);
	    end loop;
	  end if;
	end;
      end loop;

      if (l_nidListTAB.COUNT > 0) then
        begin
          FORALL i IN l_nidListTAB.FIRST..l_nidListTAB.LAST
            -- now delete each notification
            delete from WF_NOTIFICATION_ATTRIBUTES WNA
            where WNA.NOTIFICATION_ID = l_nidListTAB(i);

          --<rwunderl:3751558>
          -- Delete the signatures related to this notification
          -- Bug 4163328
          -- Check if Wf_Digital_Security_Private.Purge_Signature_By_Obj_I is
          -- accepting varray, if not don't run it again.
	  if purgesigs=1 then
          FOR i in l_nidListTAB.FIRST..l_nidListTAB.LAST loop
	    if (l_signature) then
              begin
                execute IMMEDIATE 'begin Wf_Digital_Security_Private.Purge_Signature_By_Obj_Id(''WF_NTF'', :1); end;'
                  using to_char(l_nidListTAB(i));

              exception
                when invalid_identifier then
                  l_signature := FALSE;

                when invalid_component then
                  l_signature := FALSE;
              end;
              --</rwunderl:3751558>
            end if;
          end loop;
	  end if;

            FORALL i in l_nidListTAB.FIRST..l_nidListTAB.LAST
            -- Delete notification comments
            DELETE FROM wf_comments wc
            WHERE wc.notification_id = l_nidListTAB(i);

            begin
              FORALL i in l_nidListTAB.FIRST..l_nidListTAB.LAST
              delete from WF_NOTIFICATIONS WN
              where WN.NOTIFICATION_ID = l_nidListTAB(i);
            exception when in_other_status_table then
              -- happens when nid is also in history table
              -- we will delete this later in the loop
              null;
            end;

         -- clear l_nidListTAB index table for next bulk processing
         FOR i IN l_nidListTAB.FIRST..l_nidListTAB.LAST loop
           l_nidListTAB.DELETE(i);
         end loop;
        exception
	  when others then
        rollback;
        end;
      end if;  --if (l_nidListTAB.COUNT > 0)

       begin
         --delete all status history.
         FORALL j IN l_itemkeyTAB.FIRST..l_itemkeyTAB.LAST
         delete from WF_ITEM_ACTIVITY_STATUSES_H
           where ITEM_TYPE = l_itemtypeTAB(j)
           and   ITEM_KEY  = l_itemkeyTAB(j);

         --delete all statuses.
         FORALL j IN l_itemkeyTAB.FIRST..l_itemkeyTAB.LAST
         delete from WF_ITEM_ACTIVITY_STATUSES
           where ITEM_TYPE = l_itemtypeTAB(j)
           and   ITEM_KEY  = l_itemkeyTAB(j);

         --delete item attributes
         FORALL j IN l_itemkeyTAB.FIRST..l_itemkeyTAB.LAST
         delete from  WF_ITEM_ATTRIBUTE_VALUES
           where ITEM_TYPE = l_itemtypeTAB(j)
           and   ITEM_KEY  = l_itemkeyTAB(j);

-- 3966635 Workflwo Provisioning Project
-- Following added so as not to loose the changes required.
--          --delete Provision Requests, if any
--          delete from WF_PROV_REQUESTS
--          where CONTEXT like c_item_type||':'||c_item_key||':'||'%'
--            and source = 'WORKFLOW';
--
         --finally delete the item itself.
         FORALL j IN l_itemkeyTAB.FIRST..l_itemkeyTAB.LAST
         delete from  WF_ITEMS
           where ITEM_TYPE = l_itemtypeTAB(j)
           and   ITEM_KEY  = l_itemkeyTAB(j);

      exception
        when others then
        rollback;
      end;

      --<rwunderl:3751558>
      begin
        execute immediate l_ecx_sql using  itemtype, itemkey, enddate;
      exception
        when invalid_identifier then
          null;

        when invalid_component then
          null;
       end;
      --</rwunderl:3751558>
    end if;

    if (l_keycount >= wf_purge.commit_frequency) then
      exit item_purge_loop;
    elsif (l_keycount < wf_purge.commit_frequency) then
      exit outer_purge;
    end if;

    end loop item_purge_loop; -- item2purge or item3purge loop

      if (item2purge%ISOPEN) then
        close item2purge;
      end if;

      if (item3purge%ISOPEN) then
        close item3purge;
      end if;

      if (item4purge%ISOPEN) then
        close item4purge;
      end if;

      -- CTILLEY bug 3228475
      if (item5purge%ISOPEN) then
        close item5purge;
      end if;

      if ( docommit ) then
        commit;
        fnd_concurrent.set_preferred_rbs;
      end if;

  end loop outer_purge;

  if ( docommit ) then
    commit;
    fnd_concurrent.set_preferred_rbs;
  end if;

  if (item2purge%ISOPEN) then
    close item2purge;
  end if;

  if (item3purge%ISOPEN) then
    close item3purge;
  end if;

  if (item4purge%ISOPEN) then
       close item4purge;
  end if;

  -- CTILLEY bug 3228475
  if (item5purge%ISOPEN) then
         close item5purge;
  end if;

  -- Clear engine runtime cache for convenience
  Wf_Item.ClearCache;

exception
  when others then
    if (item2purge%ISOPEN) then
      close item2purge;
    end if;

    if (item3purge%ISOPEN) then
      close item3purge;
    end if;

    if (item4purge%ISOPEN) then
       close item4purge;
    end if;

    -- CTILLEY bug 3228475
    if (item5purge%ISOPEN) then
           close item5purge;
    end if;


    Wf_Core.Context('Wf_Purge', 'Items', itemtype, itemkey, to_char(enddate));
    raise;
end Items;

--
-- procedure Activities
--   Delete old activity versions with end_time before argument,
--   and that are not referenced by an existing item.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   name - Activity to delete, or null for all activities
--   enddate - Date to obsolete to
-- NOTE:
--   It is recommended to purge Items before purging Activities to avoid
--   obsolete item references preventing obsolete activities from being
--   deleted.
--
procedure Activities(
  itemtype in varchar2,
  name in varchar2,
  enddate in date)
is
  type typetab is table of varchar2(8) index by binary_integer;
  type nametab is table of varchar2(30) index by binary_integer;

  -- Select all activities of this itemtype


  cursor actcurs1 is
    select distinct WA.ITEM_TYPE, WA.NAME
    from WF_ACTIVITIES WA
    where WA.ITEM_TYPE = itemtype;

  cursor actcurs2 is
    select distinct WA.ITEM_TYPE, WA.NAME
    from WF_ACTIVITIES WA
    where WA.ITEM_TYPE = itemtype
    and WA.NAME = name;

  cursor actcurs3 is
    select distinct WA.ITEM_TYPE, WA.NAME
    from WF_ACTIVITIES WA;


  /* JWSMITH BUG 2208127 - took out decode statment as this was   */
  /* preventing stats from being used and causing performance */
  /* issues.  Instead have two cursors and if logic to decide     */
  /* between them.  See bug for more details.                     */
  cursor parentcurs1(acttype in varchar2, actname in varchar2) is
    select WPA.PROCESS_ITEM_TYPE, WPA.PROCESS_NAME
    from WF_PROCESS_ACTIVITIES WPA
    where WPA.ACTIVITY_ITEM_TYPE = acttype
    and WPA.ACTIVITY_NAME = actname
    union
    select WA.ITEM_TYPE PROCESS_ITEM_TYPE, WA.NAME PROCESS_NAME
    from WF_ACTIVITIES WA
    where WA.ERROR_ITEM_TYPE = acttype
    and WA.ERROR_PROCESS IS NOT NULL;

  -- Select processes using an activity in any version,
  -- or referencing this activity as an error process
  cursor parentcurs2(acttype in varchar2, actname in varchar2) is
    select WPA.PROCESS_ITEM_TYPE, WPA.PROCESS_NAME
    from WF_PROCESS_ACTIVITIES WPA
    where WPA.ACTIVITY_ITEM_TYPE = acttype
    and WPA.ACTIVITY_NAME = actname
    union
    select WA.ITEM_TYPE PROCESS_ITEM_TYPE, WA.NAME PROCESS_NAME
    from WF_ACTIVITIES WA
    where WA.ERROR_ITEM_TYPE = acttype
    and WA.ERROR_PROCESS = actname;

parent parentcurs1%rowtype;
parent1 parentcurs2%rowtype;

  -- Select all versions of an activity before given enddate
  cursor vercurs(acttype in varchar2, actname in varchar2) is
    select WA.BEGIN_DATE, WA.END_DATE, WA.VERSION
    from WF_ACTIVITIES WA
    where WA.ITEM_TYPE = acttype
    and WA.NAME = actname
    and exists
      (select null
      from WF_ITEM_TYPES WIT
      where WA.END_DATE+nvl(WIT.PERSISTENCE_DAYS,0)<=enddate
      and WA.ITEM_TYPE = WIT.NAME
      and WIT.PERSISTENCE_TYPE = Wf_Purge.persistence_type);

  --Use itemcurs1 if the rootname is 'ROOT'
  cursor itemcurs1(begdate in date, enddate in date,
                   roottype in varchar2, rootname in varchar2) is
    select WI.ITEM_TYPE, WI.ITEM_KEY, WI.ROOT_ACTIVITY, WI.BEGIN_DATE
    from WF_ITEMS WI
    where WI.BEGIN_DATE between begdate and  nvl(enddate, WI.BEGIN_DATE)
    and WI.ITEM_TYPE     = roottype;

  --Use itemcurs2 for other rootnames
  cursor itemcurs2(begdate in date, enddate in date,
                  roottype in varchar2, rootname in varchar2) is
    select WI.ITEM_TYPE, WI.ITEM_KEY, WI.ROOT_ACTIVITY, WI.BEGIN_DATE
    from WF_ITEMS WI
    where WI.BEGIN_DATE between begdate and  nvl(enddate, WI.BEGIN_DATE)
    and WI.ITEM_TYPE     = roottype
    and WI.ROOT_ACTIVITY = rootname ;

   item itemcurs1%rowtype;
   item1 itemcurs2%rowtype;

  -- List of processes/activities yet to be checked
  checkcur  pls_integer;
  checkmax  pls_integer;
  checktype typetab;
  checkname nametab;

  -- List of processes already checked
  foundmax  pls_integer;
  foundtype typetab;
  foundname nametab;

  -- List of possible root processes found
  rootmax  pls_integer;
  roottype typetab;
  rootname nametab;

  found boolean;

  rootid pls_integer;
  refflag boolean;

  numvers pls_integer;

  c_item_type varchar2(8);
  c_name varchar2(30);

begin


  -- Disallow future date in enddate
  -- Avoid something being purged before its defined persistence period.
  if (enddate > sysdate) then
    Wf_Core.Token('SYSDATE', to_char(sysdate));
    Wf_Core.Raise('WF_FUTURE_END_DATE');
  end if;

   -- Bug 3228475 Disallow partial values for itemtype and activity name
   if ((itemtype is not null and (instr(name,'%')>0 or itemtype is null))
       or (instr(itemtype,'%')>0)) then
      Wf_Core.Raise('WFSQL_ARGS');
   end if;
<<outer_actloop>>
loop
  if (itemtype is not null and name is null) then
        open actcurs1;
  elsif (itemtype is not null) then
        open actcurs2;
  else
        open actcurs3;
  end if;

   <<actloop>>
   loop

    if (itemtype is not null and name is null) then
       fetch actcurs1 into  c_item_type, c_name;
         if (actcurs1%notfound) then
             exit outer_actloop;
         end if;
    elsif (itemtype is not null) then
          fetch actcurs2 into  c_item_type, c_name;
  	  if (actcurs2%notfound) then
             exit outer_actloop;
          end if;
    else
          fetch actcurs3 into  c_item_type, c_name;
  	  if (actcurs3%notfound) then
             exit outer_actloop;
          end if;
    end if;


    -- Build table of all possible root processes referencing this activity.
    -- Start with only this activity on the check list,
    -- and the found and root lists empty.
    checkcur := 1;
    checkmax := 1;
    checktype(1) := c_item_type;
    checkname(1) := c_name;
    foundmax := 0;
    rootmax := 0;

    -- While processes left to check...
    <<checkloop>>
    while (checkcur <= checkmax) loop
      -- JWSMITH BUG 2208127, Determine which cursor to use.
      if (checkname(checkcur) = 'ROOT') then
         -- If this node is already a root, add it to the list immediately.
         rootmax := rootmax + 1;
         roottype(rootmax) := checktype(checkcur);
         rootname(rootmax) := checkname(checkcur);

         open parentcurs1(checktype(checkcur),checkname(checkcur));
      else
         open parentcurs2(checktype(checkcur),checkname(checkcur));
      end if;

      -- Get all processes referencing this activity
      <<parentloop>>

      -- JWSMITH BUG 2208127, Determine which cursor to use.
      loop

        if (checkname(checkcur) = 'ROOT') then
           fetch parentcurs1 into parent;
           EXIT WHEN parentcurs1%NOTFOUND;
        else
           fetch parentcurs2 into parent1;
           EXIT WHEN parentcurs2%NOTFOUND;
           parent := parent1;
        end if;
        if (parent.process_name = 'ROOT') then
           -- If we have reached a root node, add this to this list
           -- of root processes to check.
           rootmax := rootmax + 1;
           roottype(rootmax) := checktype(checkcur);
           rootname(rootmax) := checkname(checkcur);
        else
           -- Otherwise, check if we have already found this activity
           -- (Found means it has either already been checked or is
           -- currently in the check queue.)
           found := FALSE;
           <<foundloop>>
           for i in 1 .. foundmax loop
              if ((foundtype(i) = parent.process_item_type) and
                 (foundname(i) = parent.process_name)) then
                  found := TRUE;
                  exit foundloop;
              end if;
           end loop foundloop;
           -- This is the first time this process has been found.
           -- Add it to the found list and the list of further
           -- processes to check.
           if (not found) then
              -- Add to list of processes found
              foundmax := foundmax + 1;
              foundtype(foundmax) := parent.process_item_type;
              foundname(foundmax) := parent.process_name;

              -- Add parent process to list to check
              checkmax := checkmax + 1;
              checktype(checkmax) := parent.process_item_type;
              checkname(checkmax) := parent.process_name;
           end if;
        end if;  -- end not root child
      end loop parentloop;

      if (parentcurs1%ISOPEN) then
         CLOSE parentcurs1;
      elsif (parentcurs2%ISOPEN) then
         CLOSE parentcurs2;
      end if;

      checkcur := checkcur + 1;
    end loop checkloop;

    -- All versions of this activity ...
    <<verloop>>
    for ver in vercurs(c_item_type, c_name) loop
      refflag := FALSE;
      -- All root processes in reference table ...
      <<rootloop>>
      for i in 1 .. rootmax loop
        -- All items in this version using this root process
        if (rootname(i) = 'ROOT') then
         open itemcurs1(ver.begin_date, ver.end_date,roottype(i),rootname(i));
        else
         open itemcurs2(ver.begin_date, ver.end_date,roottype(i),rootname(i));
        end if;

        /**
         ** Use the itemcur1/itemcur2 depending on rootname
         ** ROOT or not
         for item in itemcurs(ver.begin_date, ver.end_date,
            roottype(i), rootname(i)) loop
         **/
         <<itemloop>>

         loop

         if (rootname(i)= 'ROOT') then
           fetch itemcurs1 into item;
           EXIT WHEN itemcurs1%NOTFOUND;
         else
           fetch itemcurs2 into item1;
           EXIT WHEN itemcurs2%NOTFOUND;
           item := item1;
         end if;

        begin
          -- Search tree for a reference
          rootid := Wf_Process_Activity.RootInstanceId(item.item_type,
                        item.item_key, item.root_activity);
          if (Wf_Process_Activity.IsChild(rootid, c_item_type,
                  c_name, item.begin_date)) then
            refflag := TRUE;
            exit rootloop;
          end if;
          exception
            when others then
              -- If any errors occur while searching the item, then the
              -- item process has been somehow corrupted.
              -- To be on the safe side, assume it might have a reference
              -- and do not purge this act/version.
              refflag := TRUE;
              exit rootloop;
          end;
        end loop itemloop;
        if (itemcurs1%ISOPEN) then
          CLOSE itemcurs1;
        elsif (itemcurs2%ISOPEN) then
          CLOSE itemcurs2;
        end if;
      end loop rootloop;

      if (itemcurs1%ISOPEN) then
        CLOSE itemcurs1;
      elsif (itemcurs2%ISOPEN) then
        CLOSE itemcurs2;
      end if;

      if (not refflag) then
        -- Purge the activity if no reference found

        -- Delete any process activities and
        -- their attribute values and transitions
        delete from WF_ACTIVITY_ATTR_VALUES WAAV
        where WAAV.PROCESS_ACTIVITY_ID in
          (select WPA.INSTANCE_ID
          from WF_PROCESS_ACTIVITIES WPA
          where WPA.PROCESS_NAME = c_name
          and WPA.PROCESS_ITEM_TYPE = c_item_type
          and WPA.PROCESS_VERSION = ver.version);

        delete from WF_ACTIVITY_TRANSITIONS WAT
        where WAT.TO_PROCESS_ACTIVITY in
          (select WPA.INSTANCE_ID
          from WF_PROCESS_ACTIVITIES WPA
          where WPA.PROCESS_NAME = c_name
          and WPA.PROCESS_ITEM_TYPE = c_item_type
          and WPA.PROCESS_VERSION = ver.version);

        delete from WF_ACTIVITY_TRANSITIONS WAT
        where WAT.FROM_PROCESS_ACTIVITY in
          (select WPA.INSTANCE_ID
          from WF_PROCESS_ACTIVITIES WPA
          where WPA.PROCESS_NAME = c_name
          and WPA.PROCESS_ITEM_TYPE = c_item_type
          and WPA.PROCESS_VERSION = ver.version);

        delete from WF_PROCESS_ACTIVITIES WPA
        where WPA.PROCESS_NAME = c_name
        and WPA.PROCESS_ITEM_TYPE = c_item_type
        and WPA.PROCESS_VERSION = ver.version;

        -- Delete activity attributes and _tl
        delete from WF_ACTIVITY_ATTRIBUTES_TL WAAT
        where WAAT.ACTIVITY_NAME = c_name
        and WAAT.ACTIVITY_ITEM_TYPE = c_item_type
        and WAAT.ACTIVITY_VERSION = ver.version;

        delete from WF_ACTIVITY_ATTRIBUTES WAA
        where WAA.ACTIVITY_NAME = c_name
        and WAA.ACTIVITY_ITEM_TYPE = c_item_type
        and WAA.ACTIVITY_VERSION = ver.version;

        -- Delete from activities table and _tl table.
        delete from WF_ACTIVITIES_TL WAT
        where WAT.NAME = c_name
        and WAT.ITEM_TYPE = c_item_type
        and WAT.VERSION = ver.version;

        delete from WF_ACTIVITIES WA
        where WA.NAME = c_name
        and WA.ITEM_TYPE = c_item_type
        and WA.VERSION = ver.version;
      end if;

    end loop verloop;

    -- If no versions of activity are left, clear any references to
    -- this activity in ROOT folders
    select count(1)
    into numvers
    from WF_ACTIVITIES WA
    where WA.NAME = c_name
    and WA.ITEM_TYPE = c_item_type;

    if (numvers = 0) then
      delete from WF_PROCESS_ACTIVITIES WPA
      where WPA.PROCESS_ITEM_TYPE = c_item_type
      and WPA.PROCESS_NAME = 'ROOT'
      and WPA.ACTIVITY_ITEM_TYPE = c_item_type
      and WPA.ACTIVITY_NAME = c_name;
    end if;

  end loop actloop;


  if (actcurs1%ISOPEN) then
      close actcurs1;
  end if;

  if (actcurs2%ISOPEN) then
      close actcurs2;
  end if;

  if (actcurs3%ISOPEN) then
      close actcurs3;
  end if;

  end loop outer_actloop;

  if (actcurs1%ISOPEN) then
      close actcurs1;
  end if;

  if (actcurs2%ISOPEN) then
      close actcurs2;
  end if;

  if (actcurs3%ISOPEN) then
      close actcurs3;
  end if;

  -- Clear engine runtime cache for convenience
  Wf_Activity.ClearCache;

exception
  when others then
  if (actcurs1%ISOPEN) then
      close actcurs1;
  end if;

  if (actcurs2%ISOPEN) then
      close actcurs2;
  end if;

  if (actcurs3%ISOPEN) then
      close actcurs3;
  end if;
    Wf_Core.Context('Wf_Purge', 'Activities', itemtype, to_char(enddate));
    raise;
end Activities;

-- procedure entity_changes
--   Purges data from table WF_ENTITY_CHANGES as per the AGE parameter passed
--   to concurrent program FNDWFPRG. Introduced as per bug 9394309
-- IN: enddate - anything before this date is to be removed
--
procedure entity_changes(p_enddate date)
is
begin
  delete
  from WF_ENTITY_CHANGES
  where CHANGE_DATE <= p_enddate;
exception
  when no_data_found then
    null;
  when others then
    wf_core.context('WF_PURGE', 'entity_changes', p_enddate);
    raise;
end;

--
-- procedure Notifications
--   Delete old notifications with end_time before argument,
--   and that are not referenced by an existing item.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   enddate - Date to obsolete to
--   docommit- Do not commit if set to false
-- NOTE:
--   It is recommended to purge Items before purging Notifications to avoid
--   obsolete item references preventing obsolete notifications from being
--   deleted.
--
procedure Notifications(
  itemtype in varchar2,
  enddate in date,
  docommit in boolean,
  purgesigs in pls_integer)
is
  TYPE nidListTAB IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_nidListTAB nidListTAB;

  -- Cursor to delete all enddated notifications. If the design info for the item
  -- is available check for the persistence, if not just delete
  cursor c1 is
    select WN.NOTIFICATION_ID
    from WF_NOTIFICATIONS WN
    where WN.MESSAGE_TYPE = itemtype
    and not exists
      (select NULL
      from WF_ITEM_ACTIVITY_STATUSES WIAS
      where WIAS.NOTIFICATION_ID = WN.GROUP_ID)
    and not exists
      (select NULL
      from WF_ITEM_ACTIVITY_STATUSES_H WIAS
      where WIAS.NOTIFICATION_ID = WN.GROUP_ID)
    and (
     exists(
      select null
      from WF_ITEM_TYPES WIT
      where WN.END_DATE+nvl(WIT.PERSISTENCE_DAYS,0) <= enddate
      and WN.MESSAGE_TYPE = WIT.NAME
      and WIT.PERSISTENCE_TYPE = Wf_Purge.persistence_type)
     or not exists(
      select null
      from   WF_ITEM_TYPES WIT
      where  WN.MESSAGE_TYPE = WIT.NAME))
    and(
     (purgesigs = 1)
      or not exists
      (select null
      from   WF_DIG_SIGS WDS
      where  SIG_OBJ_TYPE = 'WF_NTF'
      and    SIG_OBJ_ID = WN.NOTIFICATION_ID));

   cursor c2 is
    select WN.NOTIFICATION_ID
    from WF_NOTIFICATIONS WN
    where not exists
      (select NULL
      from WF_ITEM_ACTIVITY_STATUSES WIAS
      where WIAS.NOTIFICATION_ID = WN.GROUP_ID)
    and not exists
      (select NULL
      from WF_ITEM_ACTIVITY_STATUSES_H WIAS
      where WIAS.NOTIFICATION_ID = WN.GROUP_ID)
    and (
     exists(
      select null
      from WF_ITEM_TYPES WIT
      where WN.END_DATE+nvl(WIT.PERSISTENCE_DAYS,0) <= enddate
      and WN.MESSAGE_TYPE = WIT.NAME
      and WIT.PERSISTENCE_TYPE = Wf_Purge.persistence_type)
     or not exists(
      select null
      from   WF_ITEM_TYPES WIT
      where  WN.MESSAGE_TYPE = WIT.NAME))
    and(
      (purgesigs = 1)
      or not exists
      (select null
      from   WF_DIG_SIGS WDS
      where  SIG_OBJ_TYPE = 'WF_NTF'
      and    SIG_OBJ_ID = WN.NOTIFICATION_ID));

  -- <rwunderl:3751558>
  invalid_component exception;
  pragma EXCEPTION_INIT(invalid_component, -302);

  invalid_identifier exception;
  pragma EXCEPTION_INIT(invalid_identifier, -201);
  -- </rwunderl:3751558>
begin

  -- Disallow future date in enddate
  -- Avoid something being purged before its defined persistence period.
  if (enddate > sysdate) then
    Wf_Core.Token('SYSDATE', to_char(sysdate));
    Wf_Core.Raise('WF_FUTURE_END_DATE');
  end if;

  -- Bug 3228475 Disallow partial values being passed for itemtype
  if (instr(itemtype,'%')>0) then
      Wf_Core.Raise('WFSQL_ARGS');
  end if;

  -- End date all the orphan notifications. This end dates all the notifications
  -- generated before the enddate parameter value.
  loop
    UPDATE wf_notifications wn
    SET end_date = nvl(begin_date, to_date('2002/08/01','YYYY/MM/DD')) + 1
    WHERE NOT EXISTS
      (SELECT NULL
       FROM  wf_item_activity_statuses wias
       WHERE  wias.notification_id = wn.group_id)
    AND NOT EXISTS
      (SELECT NULL
       FROM  wf_item_activity_statuses_h wiash
       WHERE  wiash.notification_id = wn.group_id)
    AND wn.end_date is null
    AND wn.begin_date <= enddate
    AND rownum < Wf_Purge.Commit_Frequency;

    --Bug 14392753: moved the exit point to here before the potential commit
    --happens as it will result in SQL%NOTFOUND set to TRUE.
    exit when (sql%NOTFOUND);

    --Bug 6759163 : if statement added to avoid commit when
    --'docommit' parameter is false
    if (docommit) then
      commit;
    end if;
  end loop;

  <<outer_ntf_loop>>
  loop

    if (itemtype is not null) then
      open c1;
    else
      open c2;
    end if;

    <<inner_ntf_loop>>
    loop

     if (itemtype is not null) then
     -- Bug 4163328
     -- Use bulk operations to improve performance
        FETCH c1 BULK COLLECT INTO l_nidListTAB LIMIT wf_purge.commit_frequency;
          exit outer_ntf_loop when l_nidListTAB.COUNT = 0;
      else
        FETCH c2 BULK COLLECT INTO l_nidListTAB LIMIT wf_purge.commit_frequency;
          exit outer_ntf_loop when l_nidListTAB.COUNT = 0;
       end if;

     -- Delete notification attributes
     FORALL j in l_nidListTAB.FIRST..l_nidListTAB.LAST
       delete from WF_NOTIFICATION_ATTRIBUTES WNA
       where WNA.NOTIFICATION_ID = l_nidListTAB(j);

     --<rwunderl:3751558>
     -- Delete the signatures related to this notification
     if (purgesigs = 1) then
     FOR j in l_nidListTAB.FIRST..l_nidListTAB.LAST loop
       begin
           execute IMMEDIATE 'begin Wf_Digital_Security_Private.Purge_Signature_By_Obj_Id(''WF_NTF'', :1); end;'
                   using to_char(l_nidListTAB(j));
       exception
         when invalid_identifier then
           null;

         when invalid_component then
           null;
       end;
     --</rwunderl:3751558>
     end loop;
     end if;

     -- Delete Notification comments
     FORALL j in l_nidListTAB.FIRST..l_nidListTAB.LAST
       DELETE FROM wf_comments wc
       WHERE wc.notification_id = l_nidListTAB(j);

     -- Delete notifications
     FORALL j in l_nidListTAB.FIRST..l_nidListTAB.LAST
       delete from WF_NOTIFICATIONS WN
       where WN.NOTIFICATION_ID = l_nidListTAB(j);

     if (l_nidListTAB.COUNT >= wf_purge.commit_frequency) then
       exit inner_ntf_loop;
     elsif (l_nidListTAB.COUNT < wf_purge.commit_frequency) then
       exit outer_ntf_loop;
     end if;

    end loop inner_ntf_loop;

    if (c1%ISOPEN) then
       close c1;
    elsif (c2%ISOPEN) then
       close c2;
    end if;

    -- Commit Decision
    if (docommit) then
      commit;
      Fnd_Concurrent.Set_Preferred_RBS;
    end if;

  end loop outer_ntf_loop;

  if (c1%ISOPEN) then
     close c1;
  elsif (c2%ISOPEN) then
     close c2;
  end if;

  -- Commit Decision
  if (docommit) then
    commit;
    Fnd_Concurrent.Set_Preferred_RBS;
  end if;

  -- Purge AdHoc Users/Roles/User_Roles
  Wf_Purge.AdHocDirectory(enddate);

exception
  when others then
    if (c1%ISOPEN) then
       close c1;
    elsif (c2%ISOPEN) then
       close c2;
    end if;

    Wf_Core.Context('Wf_Purge', 'Notifications', itemtype, to_char(enddate));
    raise;
end Notifications;

--
-- procedure Item_Notifications
--   Delete notifications sent by a particular item with end_time
--   before argument.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   enddate - Date to obsolete to
--   docommit- Do not commit if set to false
--
procedure Item_Notifications(
  itemtype in varchar2,
  itemkey in varchar2,
  enddate in date,
  docommit in boolean)
is
begin
   Null;
end Item_Notifications;

--
-- Total
--   Delete all obsolete runtime data with end_time before argument.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   enddate - Date to obsolete to
--   docommit- Commit or no commit after each purge of entitiy
--   runtimeonly - If true only runtime /transaction data purged
--             if false both runtime and design data purged.
--
procedure Total(
  itemtype in varchar2,
  itemkey in varchar2,
  enddate in date,
  docommit in boolean,
  runtimeonly  in boolean,
  purgesigs in pls_integer,
  purgeCacheData in boolean
)
is

begin

  -- Disallow future date in enddate
  -- Avoid something being purged before its defined persistence period.
  if (enddate > sysdate) then
    Wf_Core.Token('SYSDATE', to_char(sysdate));
    Wf_Core.Raise('WF_FUTURE_END_DATE');
  end if;

  -- Bug 3228475  Disallow partial values from being passed
  if ((itemkey is not null and (instr(itemkey,'%')>0 or itemtype is null))
       or (instr(itemtype,'%')>0)) then
      Wf_Core.Raise('WFSQL_ARGS');
  end if;

 -- Bug 1636510
 -- Before attempting to purge items we will abort any error process
 -- if the activity that launched it is now complete.
  wf_purge.abortErrorProcess(itemtype, itemkey);

  l_docommit := docommit;
  l_runtimeonly := runtimeonly;
  wf_purge.items(itemtype=>itemtype, itemkey=>itemkey, enddate=>enddate, docommit=>docommit,purgesigs=>purgesigs);

  if (docommit) then
    commit;
    Fnd_Concurrent.Set_Preferred_RBS;
  end if;

  --Purge design data only if runtime is
  --set to false
  if (not nvl(runtimeonly,TRUE)) then
    --also purge design data from activities
    wf_purge.activities(itemtype=>itemtype, enddate=>enddate);
    if (docommit) then
      commit;
      Fnd_Concurrent.Set_Preferred_RBS;
    end if;

    --Directory Information
    Wf_Purge.Directory(end_date=>enddate, autocommit=>docommit);
    if (docommit) then
      commit;
      Fnd_Concurrent.Set_Preferred_RBS;
    end if;
  end if;

  -- Clear engine runtime cache for convenience
  Wf_Item.ClearCache;

  -- Purge orphan notifications only if runtimeonly is false
  if (not nvl(runtimeonly, TRUE)) then
    --Bug 6759163 : 'docommit' parameter passed to Notifications() as well
    Notifications(itemtype=>itemtype, enddate=>enddate,docommit=>docommit,purgesigs=>purgesigs);
  end if;
  -- As per bug 5576885, purge WF entity tables using WF_ENTITY_MGR
  if (purgeCacheData) then
    WF_ENTITY_MGR.purge_cache_attributes(enddate);
    entity_changes(enddate);
  end if;
exception
  when others then
    Wf_Core.Context('Wf_Purge', 'Total', itemtype, itemkey, to_char(enddate));
    raise;
end Total;

--
-- TotalPERM
--   Delete all obsolete runtime data that is of persistence type 'PERM'
--   and with end_time before argument.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   enddate - Date to obsolete to
--   docommit- Commit or no commit after each purge of entitiy
--   runtimeonly - Delete runtime data alone if set to true
--             else delete both design and runtime data
--
procedure TotalPERM(
  itemtype in varchar2,
  itemkey in varchar2,
  enddate in date,
  docommit in boolean,
  runtimeonly in boolean,
  purgesigs in pls_integer)
is
begin
  wf_purge.persistence_type := 'PERM';

  -- Call Total with new args
  Wf_Purge.Total(
    itemtype,
    itemkey,
    enddate,
    docommit,
    nvl(runtimeonly, TRUE),
    purgesigs);

  -- Reset persistence type to the default value
  wf_purge.persistence_type := 'TEMP';

exception
  when others then
    -- Reset persistence type to the default value
    wf_purge.persistence_type := 'TEMP';
    Wf_Core.Context('Wf_Purge', 'TotalPERM', itemtype, itemkey,
                    to_char(enddate));
    raise;
end TotalPERM;


--
-- TotalConcurrent
--   Concurrent Program version of Total
-- IN:
--   errbuf - CPM error message
--   retcode - CPM return code (0 = success, 1 = warning, 2 = error)
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   age - Minimum age of data to purge (in days)
--   x_persistence_type - Persistence Type to be purged: 'TEMP' or 'PERM'
--   runtimeonly - If 'Y' then purge runtime data alone
--
procedure TotalConcurrent(
  errbuf out NOCOPY varchar2,
  retcode out NOCOPY varchar2,
  itemtype in varchar2,
  itemkey in varchar2,
  age in varchar2,
  x_persistence_type in varchar2,
  runtimeonly  in varchar2,
  x_commit_frequency in number,
  purgesigs in varchar2,
  purgeCacheData in varchar2)
is
  enddate date;
  errname varchar2(30);
  errmsg varchar2(2000);
  errstack varchar2(2000);

  l_runtimeonly boolean := FALSE;
  l_purgesigs pls_integer;
  l_purgeCacheData boolean := FALSE;
begin
  -- Convert arguments from varchar2 to real type.
  enddate := sysdate - to_number(age);

  wf_purge.persistence_type := x_persistence_type;
  wf_purge.commit_frequency := x_commit_frequency;

  --If runtimeonly 'N' then purge both runtime
  --and design data
  if (upper(runtimeonly) = 'Y') then
     l_runtimeonly := TRUE;
  end if;

  if (upper(purgesigs) = 'Y') then
     l_purgesigs := 1;
  end if;

  if upper(purgeCacheData) = 'Y' then
    l_purgeCacheData := TRUE;
  end if;

   -- Call Total with new args
   Wf_Purge.Total(
    itemtype,
    itemkey,
    enddate,
    true,
    l_runtimeonly,
    l_purgesigs,
    l_purgeCacheData);


  -- Return 0 for successful completion.
  errbuf := '';
  retcode := '0';
  wf_purge.persistence_type := 'TEMP';  -- reset to the default value
  wf_purge.commit_frequency := 1000; -- reset to the default value

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

    -- Reset persistence type to the default value
    wf_purge.persistence_type := 'TEMP';
end TotalConcurrent;

--
-- Directory
--   Purge all WF_LOCAL_* tables based on expiration date
-- IN:
--   end_date - Date to purge to
--
procedure Directory(
  end_date in date default sysdate,
  orig_system in varchar2 default null,
  autocommit in boolean default false)
is
  --
  -- All roles that past the end_date and with no outstanding notification
  --
  -- Need to check ORIGINAL_RECIPIENT as well as the RECIPIENT_ROLE just
  -- in case a 'Delegate' happened, we won't purge the orginal owner.
  --
  --Bug 16054955. This cursor is to purge ad-hoc USERS and related data
  cursor user_cursor is
    select local.NAME, local.ORIG_SYSTEM, local.ORIG_SYSTEM_ID
     from  WF_LOCAL_ROLES PARTITION(WF_LOCAL_ROLES) local
     where ORIG_SYSTEM = 'WF_LOCAL_USERS'
     and   EXPIRATION_DATE <= end_date
     and   local.USER_FLAG='Y'
     and not exists
           (select NULL
              from WF_NOTIFICATIONS wn
             where wn.RECIPIENT_ROLE = local.NAME
                or wn.ORIGINAL_RECIPIENT = local.NAME);

  --Bug 16054955. This cursor is to purge ad-hoc ROLES and related data
  cursor role_cursor is
    select local.NAME, local.ORIG_SYSTEM, local.ORIG_SYSTEM_ID
     from  WF_LOCAL_ROLES PARTITION(WF_LOCAL_ROLES) local
     where ORIG_SYSTEM = 'WF_LOCAL_ROLES'
     and   EXPIRATION_DATE <= end_date
     and   local.USER_FLAG='N'
     and not exists
           (select NULL
            from   WF_ROLE_HIERARCHIES
            where  SUPER_NAME = local.NAME
            or     SUB_NAME   = local.NAME)
     and not exists
           (select NULL
              from WF_NOTIFICATIONS wn
             where wn.RECIPIENT_ROLE = local.NAME
                or wn.ORIGINAL_RECIPIENT = local.NAME);

  -- Similar to role_cursor for orig systems different from WF_LOCAL_ROLES
  cursor role_orig_system_cursor (p_OrigSystem varchar2,
                                  p_endDate date) is
    select local.NAME, local.ORIG_SYSTEM, local.ORIG_SYSTEM_ID
     from  WF_LOCAL_ROLES local
     where ORIG_SYSTEM = p_origSystem
     and   (p_endDate is NULL or EXPIRATION_DATE <= p_endDate)
     and   local.USER_FLAG='N'
     and not exists
           (select NULL
            from   WF_ROLE_HIERARCHIES
            where  SUPER_NAME = local.NAME
            or     SUB_NAME   = local.NAME)
     and not exists
           (select NULL
              from WF_NOTIFICATIONS wn
             where wn.RECIPIENT_ROLE = local.NAME
                or wn.ORIGINAL_RECIPIENT = local.NAME);

  -- Similar to user_cursor for orig systems different from WF_LOCAL_USERS
  cursor user_orig_system_cursor (p_OrigSystem varchar2,
                                  p_endDate date) is
    select local.NAME, local.ORIG_SYSTEM, local.ORIG_SYSTEM_ID
     from  WF_LOCAL_ROLES local
     where ORIG_SYSTEM = p_origSystem
     and   (p_endDate is NULL or EXPIRATION_DATE <= p_endDate)
     and   local.USER_FLAG='Y'
     and not exists
           (select NULL
            from   WF_USER_ROLE_ASSIGNMENTS
            where  USER_NAME = local.NAME
            and    RELATIONSHIP_ID <> -1)
     and not exists
           (select NULL
              from WF_NOTIFICATIONS wn
             where wn.RECIPIENT_ROLE = local.NAME
                or wn.ORIGINAL_RECIPIENT = local.NAME)
     and not exists
           (select NULL
              from WF_ITEMS wi
             where wi.OWNER_ROLE = local.NAME);

  -- Bug 8204723. These two cursors are used to remove expired associations regardles
  -- of whether the role is expired or not.
  cursor expired_rel_cursor is
    select wlur.user_name, wlur.user_orig_system, wlur.user_orig_system_id,
           wlur.role_name, wlur.role_orig_system, wlur.role_orig_system_id
     from  WF_LOCAL_USER_ROLES PARTITION (WF_LOCAL_ROLES) WLUR
     where (WLUR.ROLE_ORIG_SYSTEM='WF_LOCAL_ROLES' or WLUR.USER_ORIG_SYSTEM='WF_LOCAL_USERS')
     and   WLUR.EFFECTIVE_END_DATE <= directory.end_date;

  cursor expired_rel_orig_system_cursor (p_origSystem varchar2,
                                         p_endDate date) is
    select wlur.user_name, wlur.user_orig_system, wlur.user_orig_system_id,
           wlur.role_name, wlur.role_orig_system, wlur.role_orig_system_id
     from  WF_LOCAL_USER_ROLES WLUR, WF_LOCAL_ROLES WLR
     where WLR.ORIG_SYSTEM=p_origSystem
       and ((WLR.NAME=WLUR.USER_NAME and WLR.ORIG_SYSTEM=WLUR.USER_ORIG_SYSTEM)
           or
           (WLR.NAME=WLUR.ROLE_NAME and WLR.ORIG_SYSTEM=WLUR.ROLE_ORIG_SYSTEM))
       and WLUR.PARTITION_ID = 0
       and WLUR.EFFECTIVE_END_DATE <= p_endDate;

  type roleRec is record (NAME           WF_LOCAL_ROLES.NAME%type,
                          ORIG_SYSTEM    WF_LOCAL_ROLES.ORIG_SYSTEM%type,
                          ORIG_SYSTEM_ID WF_LOCAL_ROLES.ORIG_SYSTEM_ID%type);
  type roleTabType is table of roleRec index by binary_integer;
  roleTab roleTabType;
  type expRoleRec is record (USER_NAME           WF_LOCAL_ROLES.NAME%type,
                             USER_ORIG_SYSTEM    WF_LOCAL_ROLES.ORIG_SYSTEM%type,
                             USER_ORIG_SYSTEM_ID WF_LOCAL_ROLES.ORIG_SYSTEM_ID%type,
                             ROLE_NAME           WF_LOCAL_ROLES.NAME%type,
                             ROLE_ORIG_SYSTEM    WF_LOCAL_ROLES.ORIG_SYSTEM%type,
                             ROLE_ORIG_SYSTEM_ID WF_LOCAL_ROLES.ORIG_SYSTEM_ID%type);
  type expRoleTabType is table of expRoleRec index by binary_integer;
  expRoleTab expRoleTabType;
  l_commit boolean := false;

begin
  -- Disallow future date in enddate
  -- Avoid something being purged before its expiration date.
  if (end_date > sysdate) then
    Wf_Core.Token('SYSDATE', to_char(sysdate));
    Wf_Core.Raise('WF_FUTURE_END_DATE');
  end if;
  -- autocommit is particular to this API and can be set from sql*plus whereas
  -- l_docommit is private to WF_PURGE. We will commit if either is true
  if (autocommit or l_docommit) then
    l_commit := true;
  end if;

  if (orig_system is NOT NULL) then
    --We are using the new feature allowing a specific orig_system to be
    --removed from the local partition either by end_date, or remove all with
    --a null end-date (providing there are no active notifications or items).
    --
    -- Purge Roles
    -- Delete rows in wf_local_user_roles by role_name and wf_local_roles
    -- by name as determined
    open role_orig_system_cursor(orig_system, end_date);
    loop
      fetch role_orig_system_cursor bulk collect into roleTab LIMIT wf_purge.commit_frequency;
      exit when roleTab.COUNT=0;
      for idx in roleTab.FIRST..roleTab.LAST loop
        delete from WF_LOCAL_USER_ROLES local
         where local.ROLE_NAME = roleTab(idx).name
           and local.ROLE_ORIG_SYSTEM_ID = roleTab(idx).orig_system_id
           and local.ROLE_ORIG_SYSTEM = roleTab(idx).orig_system;

        delete from WF_USER_ROLE_ASSIGNMENTS local
         where local.ROLE_NAME = roleTab(idx).name
           and local.ROLE_ORIG_SYSTEM = roleTab(idx).orig_system
           and local.ROLE_ORIG_SYSTEM_ID = roleTab(idx).orig_system_id;
        --Remove the role
        delete from WF_LOCAL_ROLES local
        where local.NAME = roleTab(idx).name
          and local.ORIG_SYSTEM = roleTab(idx).orig_system
          and local.ORIG_SYSTEM_ID = roleTab(idx).orig_system_id;
      end loop;
      if l_commit then
        commit;
      end if;
    end loop;
    close role_orig_system_cursor;
    open user_orig_system_cursor (orig_system, end_date);
    loop
      fetch user_orig_system_cursor bulk collect into roleTab LIMIT wf_purge.commit_frequency;
      exit when roleTab.COUNT=0;
      for idx in roleTab.FIRST..roleTab.LAST loop
        delete from WF_LOCAL_USER_ROLES local
         where local.USER_NAME = roleTab(idx).name
           and local.USER_ORIG_SYSTEM_ID = roleTab(idx).orig_system_id
           and local.USER_ORIG_SYSTEM = roleTab(idx).orig_system;

        delete from WF_USER_ROLE_ASSIGNMENTS local
         where local.USER_NAME = roleTab(idx).name
           and local.USER_ORIG_SYSTEM_ID = roleTab(idx).orig_system_id
           and local.USER_ORIG_SYSTEM = roleTab(idx).orig_system;

        --Remove the role
        delete from WF_LOCAL_ROLES local
        where local.NAME = roleTab(idx).name
          and local.ORIG_SYSTEM = roleTab(idx).orig_system
          and local.ORIG_SYSTEM_ID = roleTab(idx).orig_system_id;
      end loop;
      if l_commit then
        commit;
      end if;
    end loop;
    close user_orig_system_cursor;

    open expired_rel_orig_system_cursor (orig_system, end_date);
    loop
      fetch expired_rel_orig_system_cursor bulk collect into expRoleTab
      limit wf_purge.commit_frequency;
      exit when expRoleTab.COUNT=0;
      for idx in expRoleTab.FIRST..expRoleTab.LAST loop
        delete from WF_LOCAL_USER_ROLES local
         where local.USER_NAME = expRoleTab(idx).USER_NAME
           and local.ROLE_NAME = expRoleTab(idx).ROLE_NAME
           and local.USER_ORIG_SYSTEM = expRoleTab(idx).USER_ORIG_SYSTEM
           and local.USER_ORIG_SYSTEM_ID = expRoleTab(idx).USER_ORIG_SYSTEM_ID
           and local.ROLE_ORIG_SYSTEM = expRoleTab(idx).ROLE_ORIG_SYSTEM
           and local.ROLE_ORIG_SYSTEM_ID = expRoleTab(idx).ROLE_ORIG_SYSTEM_ID;

        delete from WF_USER_ROLE_ASSIGNMENTS local
         where local.USER_NAME = expRoleTab(idx).USER_NAME
           and local.ROLE_NAME = expRoleTab(idx).ROLE_NAME
           and local.USER_ORIG_SYSTEM = expRoleTab(idx).USER_ORIG_SYSTEM
           and local.USER_ORIG_SYSTEM_ID = expRoleTab(idx).USER_ORIG_SYSTEM_ID
           and local.ROLE_ORIG_SYSTEM = expRoleTab(idx).ROLE_ORIG_SYSTEM
           and local.ROLE_ORIG_SYSTEM_ID = expRoleTab(idx).ROLE_ORIG_SYSTEM_ID;
      end loop;
      if l_commit then
        commit;
      end if;
    end loop;
    close expired_rel_orig_system_cursor;
  elsif (end_date is not null) then
    --
    -- Purge Roles
    -- Delete rows in wf_local_user_roles by role_name and wf_local_roles
    -- by name as determined
    open role_cursor;
    loop
      fetch role_cursor bulk collect into roleTab limit WF_PURGE.COMMIT_FREQUENCY;
      exit when roleTab.COUNT = 0;
      for idx in roleTab.FIRST..roleTab.LAST loop
        --Bug 16383560: can delete directly from partition WF_LOCAL_ROLES because any
        --assignment is stored in the partition the ROLE belongs to so no need to search
        --all partitions
        delete from WF_LOCAL_USER_ROLES partition (WF_LOCAL_ROLES) local
         where local.ROLE_NAME = roleTab(idx).name
           and local.ROLE_ORIG_SYSTEM_ID = roleTab(idx).orig_system_id
           and local.ROLE_ORIG_SYSTEM = roleTab(idx).orig_system;

        delete from WF_USER_ROLE_ASSIGNMENTS partition (WF_LOCAL_ROLES) local
         where local.ROLE_NAME = roleTab(idx).name
           and local.ROLE_ORIG_SYSTEM_ID = roleTab(idx).orig_system_id
           and local.ROLE_ORIG_SYSTEM = roleTab(idx).orig_system;

        delete from WF_LOCAL_ROLES partition (WF_LOCAL_ROLES) local
         where local.NAME = roleTab(idx).name
           and local.ORIG_SYSTEM = roleTab(idx).orig_system
           and local.ORIG_SYSTEM_ID = roleTab(idx).orig_system_id;
      end loop;
      if l_commit then
        commit;
      end if;
    end loop;
    close role_cursor;
    open user_cursor;
    loop
      fetch user_cursor bulk collect into roleTab limit WF_PURGE.COMMIT_FREQUENCY;
      exit when roleTab.COUNT=0;
      for idx in roleTab.FIRST..roleTab.LAST loop
        delete from WF_LOCAL_USER_ROLES partition (WF_LOCAL_ROLES) local
         where local.USER_NAME = roleTab(idx).name
           and local.USER_ORIG_SYSTEM_ID = roleTab(idx).orig_system_id
           and local.USER_ORIG_SYSTEM = roleTab(idx).orig_system;

        delete from WF_USER_ROLE_ASSIGNMENTS partition (WF_LOCAL_ROLES) local
         where local.USER_NAME = roleTab(idx).name
           and local.USER_ORIG_SYSTEM_ID = roleTab(idx).orig_system_id
           and local.USER_ORIG_SYSTEM = roleTab(idx).orig_system;

        delete from WF_LOCAL_ROLES partition (WF_LOCAL_ROLES) local
         where local.NAME = roleTab(idx).name
           and local.ORIG_SYSTEM = roleTab(idx).orig_system
           and local.ORIG_SYSTEM_ID = roleTab(idx).orig_system_id;
      end loop;
      if l_commit then
        commit;
      end if;
    end loop;
    close user_cursor;
    open expired_rel_cursor;
    loop
      fetch expired_rel_cursor bulk collect into expRoleTab limit
      WF_PURGE.COMMIT_FREQUENCY;
      exit when expRoleTab.COUNT=0;
      for idx in expRoleTab.FIRST..expRoleTab.LAST loop
        delete from WF_LOCAL_USER_ROLES partition (WF_LOCAL_ROLES) local
        where local.USER_NAME = expRoleTab(idx).USER_NAME
          and local.ROLE_NAME = expRoleTab(idx).ROLE_NAME
          and local.USER_ORIG_SYSTEM = expRoleTab(idx).USER_ORIG_SYSTEM
          and local.USER_ORIG_SYSTEM_ID = expRoleTab(idx).USER_ORIG_SYSTEM_ID
          and local.ROLE_ORIG_SYSTEM = expRoleTab(idx).ROLE_ORIG_SYSTEM
          and local.ROLE_ORIG_SYSTEM_ID = expRoleTab(idx).ROLE_ORIG_SYSTEM_ID;

        delete from WF_USER_ROLE_ASSIGNMENTS partition (WF_LOCAL_ROLES) local
        where local.USER_NAME = expRoleTab(idx).USER_NAME
          and local.ROLE_NAME = expRoleTab(idx).ROLE_NAME
          and local.USER_ORIG_SYSTEM = expRoleTab(idx).USER_ORIG_SYSTEM
          and local.USER_ORIG_SYSTEM_ID = expRoleTab(idx).USER_ORIG_SYSTEM_ID
          and local.ROLE_ORIG_SYSTEM = expRoleTab(idx).ROLE_ORIG_SYSTEM
          and local.ROLE_ORIG_SYSTEM_ID = expRoleTab(idx).ROLE_ORIG_SYSTEM_ID;
      end loop;
      if l_commit then
        commit;
      end if;
    end loop;
    close expired_rel_cursor;
  end if;
exception
  when others then
    if (role_cursor%isopen) then
      close role_cursor;
    end if;
    if (user_cursor%isopen) then
      close user_cursor;
    end if;
    if (role_orig_system_cursor%isopen) then
      close role_orig_system_cursor;
    end if;
    if (user_orig_system_cursor%isopen) then
      close user_orig_system_cursor;
    end if;
    if (expired_rel_orig_system_cursor%isopen) then
      close expired_rel_orig_system_cursor;
    end if;
    if (expired_rel_cursor%isopen) then
      close expired_rel_cursor;
    end if;
    wf_core.context('WF_PURGE', 'Directory', end_date);
    raise;
end Directory;

--
-- AdHocDirectory
--   Purge all WF_LOCAL_* tables based on expiration date
-- IN:
--   end_date - Date to purge to
--
procedure AdHocDirectory(
  end_date in date)
is
begin
  Wf_Purge.Directory(end_date);
exception
  when OTHERS then
    wf_core.context('WF_PURGE', 'AdHocDirectory', end_date);
    raise;
end AdHocDirectory;

 --
 -- GetPurgeableCount
 --   Returns the count of purgeable items for a specific itemType.
 -- IN:
 --   p_itemType  in VARCHAR2
 --
 FUNCTION GetPurgeableCount (p_itemType in varchar2) return number is
 l_purgeable number ;
 BEGIN
    --Get all records for the itemtype
     select Count(*) into l_purgeable
     from  WF_ITEMS WI
     where WI.ITEM_TYPE = p_itemType
     and   WI.END_DATE <= sysdate
     and  exists
         (select null
          from WF_ITEM_TYPES WIT
          where WI.END_DATE+nvl(WIT.PERSISTENCE_DAYS,0)<=sysdate
          and WI.ITEM_TYPE = WIT.NAME
          )
      and not exists
         (select null
          from WF_ITEMS WI2
          WHERE WI2.END_DATE IS NULL
          START WITH WI2.ITEM_TYPE = WI.ITEM_TYPE
          AND WI2.ITEM_KEY = WI.ITEM_KEY
          CONNECT BY PRIOR WI2.ITEM_TYPE = WI2.PARENT_ITEM_TYPE
          AND PRIOR WI2.ITEM_KEY = WI2.PARENT_ITEM_KEY
          UNION ALL
          select null
          from WF_ITEMS WI2
          WHERE WI2.END_DATE IS NULL
          START WITH WI2.ITEM_TYPE = WI.ITEM_TYPE
          AND WI2.ITEM_KEY = WI.ITEM_KEY
          CONNECT BY PRIOR WI2.PARENT_ITEM_TYPE = WI2.ITEM_TYPE
          AND PRIOR WI2.PARENT_ITEM_KEY = WI2.ITEM_KEY);
   return l_purgeable;
exception
  when OTHERS then
    wf_core.context('WF_PURGE', 'GetPurgeableCount', p_itemType);
    raise;
end;


 --
 -- AbortErrorProcess
 --   Aborts the Error process for an errored activity if the activity is
 --   now COMPLETE.
 -- IN:
 --   itemtype  in VARCHAR2
 --   itemkey   in VARCHAR2
 --
 procedure AbortErrorProcess (itemtype varchar2,
                              itemkey varchar2)
 is

  c_item_key varchar2(240);

  -- Bug 11728665, added null statement to improve performance of c_errorX cursors.
  cursor c_error1 is
    select wi.item_key
    from wf_item_activity_statuses wias, wf_items wi
    where wi.item_type = 'WFERROR'
    and parent_item_type = itemtype
    and wi.parent_item_type = wias.item_type
    and wi.parent_item_key = wias.item_key
    and wi.parent_context = wias.process_activity
    and wi.end_date is null
    and wias.activity_status = 'COMPLETE';

 cursor c_error2 is
    select wi.item_key
    from wf_item_activity_statuses wias, wf_items wi
    where wi.item_type = 'WFERROR'
    and parent_item_type = itemtype
    and parent_item_key = itemkey
    and wi.parent_item_type = wias.item_type
    and wi.parent_item_key = wias.item_key
    and wi.parent_context = wias.process_activity
    and wi.end_date is null
    and wias.activity_status = 'COMPLETE';

 cursor c_error3 is
    select wi.item_key
    from wf_item_activity_statuses wias, wf_items wi
    where wi.item_type = 'WFERROR'
    and wi.parent_item_type = wias.item_type
    and wi.parent_item_key = wias.item_key
    and wi.parent_context = wias.process_activity
    and wi.end_date is null
    and wias.activity_status = 'COMPLETE';


 begin

   if ((itemkey is not null and (instr(itemkey,'%')>0 or itemtype is null))
      or (instr(itemtype,'%')>0)) then
          Wf_Core.Raise('WFSQL_ARGS');
   end if;

   -- Outer loop
   <<outer_abort>>
   loop

      if (itemtype is not null and itemkey is null) then
         open c_error1;
      elsif (itemtype is not null) then
         open c_error2;
      else
         open c_error3;
      end if;

     -- Inner loop
     <<abort_loop>>
     loop

        if (itemtype is not null and itemkey is null) then
           fetch c_error1 into  c_item_key;
           if (c_error1%notfound) then
              exit outer_abort;
           end if;
        elsif (itemtype is not null) then
           fetch c_error2 into c_item_key;
           if (c_error2%notfound) then
              exit outer_abort;
           end if;
        else
           fetch c_error3 into c_item_key;
           if (c_error3%notfound) then
              exit outer_abort;
           end if;
        end if;

        -- Abort the error process since the activity is now COMPLETE
        begin

           wf_engine.abortprocess('WFERROR', c_item_key);

        exception when others then
           null;
        end;

     end loop abort_loop;

      if (c_error1%ISOPEN) then
         close c_error1;
      end if;

      if (c_error2%ISOPEN) then
         close c_error2;
      end if;

      if (c_error3%ISOPEN) then
         close c_error3;
      end if;

   end loop outer_abort;

      if (c_error1%ISOPEN) then
         close c_error1;
      end if;

      if (c_error2%ISOPEN) then
         close c_error2;
      end if;

      if (c_error3%ISOPEN) then
         close c_error3;
      end if;

  EXCEPTION WHEN OTHERS THEN
      if (c_error1%ISOPEN) then
         close c_error1;
      end if;

      if (c_error2%ISOPEN) then
         close c_error2;
      end if;

      if (c_error3%ISOPEN) then
         close c_error3;
      end if;

      Wf_Core.Context('Wf_Purge', 'AbortErrorProcess', itemtype, itemkey);
      raise;

 end AbortErrorProcess;

-- 3966635 Workflow Provisioning Project
-- Following procedures are added in order not to loose the changes
-- required.
--  --
--  -- procedure ProvisionRequests
--  --   Delete old provisiong requests with end_time before argument.
--  --   These provisioning requests are not tied explicity to a item.
--  --   Those requests will be removed with the WF_PURGE.Item API.
--  --
--  -- IN:
--  --   context - The context to match for the requests to remove.
--  --   enddate - Date to obsolete to
--  --   docommit- Do not commit if set to false
--  -- NOTE:
--  --
--  procedure ProvisionRequests(
--    context in varchar2,
--    enddate in date,
--    docommit in boolean)
--  is
--    l_context varchar2(320);
--    l_prov_request_id number;
--
--    cursor c1(c_context in varchar2,
--              c_end_date in date)
--    is
--    select prov_request_id
--    from wf_prov_requests
--    where source = 'EXTERNAL'
--      and context like c_context
--      and (end_date is not null and end_date < c_end_date);
--
--  begin
--
--    if (enddate > sysdate) then
--      wf_core.context('WF_PURGE', 'ProvisionRequests');
--      Wf_Core.Token('SYSDATE', to_char(sysdate));
--      Wf_Core.Raise('WF_FUTURE_END_DATE');
--    end if;
--
--    if context is null or length(context) = 0 then
--      l_context := '%';
--    else
--      l_context := context;
--    end if;
--
--    <<outer_prv_loop>>
--    loop
--
--       open c1(l_context, enddate);
--
--       <<inner_prv_loop>>
--       loop
--          fetch c1 into l_prov_request_id;
--          if c1%notfound then
--             exit outer_prv_loop;
--          end if;
--
--          delete from WF_PROV_REQUESTS
--          where prov_request_id = l_prov_request_id;
--
--          exit inner_prv_loop when
--          ( docommit and (c1%rowcount = wf_purge.commit_frequency));
--
--       end loop inner_prv_loop;
--
--       if c1%isopen then
--          close c1;
--       end if;
--
--       if (docommit) then
--         commit;
--         Fnd_Concurrent.Set_Preferred_RBS;
--       end if;
--
--    end loop outer_prv_loop;
--
--
--    if c1%isopen then
--       close c1;
--    end if;
--
--    if (docommit) then
--      commit;
--      Fnd_Concurrent.Set_Preferred_RBS;
--    end if;
--
--  exception
--    when others then
--      if c1%isopen then
--         close c1;
--      end if;
--      wf_core.context('WF_PURGE','ProvisionRequests', context, enddate);
--  end  ProvisionRequests;
--
-- --
-- -- ProvisionRequestsConcurrent
-- --   Concurrent Program version of Total
-- -- IN:
-- --   errbuf - CPM error message
-- --   retcode - CPM return code (0 = success, 1 = warning, 2 = error)
-- --   itemtype - Item type to delete, or null for all itemtypes
-- --   itemkey - Item key to delete, or null for all itemkeys
-- --   age - Minimum age of data to purge (in days)
-- --   x_persistence_type - Persistence Type to be purged: 'TEMP' or 'PERM'
-- --   runtimeonly - If 'Y' then purge runtime data alone
-- --
-- procedure ProvisionRequestsConcurrent(
--   errbuf out NOCOPY varchar2,
--   retcode out NOCOPY varchar2,
--   context in varchar2,
--   age in varchar2 default 0,
--   x_commit_frequency in number default 500
--   )
-- is
--   enddate date;
--   errname varchar2(30);
--   errmsg varchar2(2000);
--   errstack varchar2(2000);
--
--   l_runtimeonly boolean := FALSE;
-- begin
--   -- Convert arguments from varchar2 to real type.
--   if age is not null and age > 0 then
--     enddate := sysdate - to_number(age);
--   else
--     enddate := sysdate;
--   end if;
--
--
--   if x_commit_frequency is not null or x_commit_frequency > 0 then
--     wf_purge.commit_frequency := x_commit_frequency;
--   end if;
--
--   -- Call provisionrequest with new args
--   Wf_Purge.ProvisionRequests(context,
--                              enddate,
--                              true);
--
--
--   -- Return 0 for successful completion.
--   errbuf := '';
--   retcode := '0';
--   wf_purge.commit_frequency := 500; -- reset to the default value
--
-- exception
--   when others then
--     -- Retrieve error message into errbuf
--     wf_core.get_error(errname, errmsg, errstack);
--     if (errmsg is not null) then
--       errbuf := errmsg;
--     else
--       errbuf := sqlerrm;
--     end if;
--
--     -- Return 2 for error.
--     retcode := '2';

--     -- Reset commit frequency to the default value
--     wf_purge.commit_frequency := 500;
-- end ProvisionRequestsConcurrent;



end WF_PURGE;

/
