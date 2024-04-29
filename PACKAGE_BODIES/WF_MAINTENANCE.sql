--------------------------------------------------------
--  DDL for Package Body WF_MAINTENANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_MAINTENANCE" as
 /* $Header: wfmtn9b.pls 120.12.12010000.13 2015/01/21 01:49:59 alsosa ship $ */

g_CommitCounter NUMBER := 0;
g_docommit BOOLEAN := FALSE;

-- Types for bulk operations
type itemTypeTbl is table of varchar2(8) index by binary_integer;
type itemKeyTbl is table of varchar2(240) index by binary_integer;
type procNameTbl is table of varchar2(30) index by binary_integer;
type instLabelTbl is table of varchar2(30) index by binary_integer;

type numTblType is table of number index by binary_integer;
type rowIdTblType is table of rowid index by binary_integer;

itemTbl itemTypeTbl; --For ITEM_TYPE
keyTbl  itemKeyTbl;  --For ITEM_KEY

procItemTbl itemTypeTbl; --For ITEM_TYPE
procKeyTbl itemKeyTbl;   --For ITEM_KEY
procActTbl numTblType;   --For PROCESS_ACTIVITY

procActItemTbl  itemTypeTbl; --For PROCESS_ITEM_TYPE
procActNameTbl  procNameTbl; --For PROCESS_NAME
procActVersTbl  numTblType;  --For PROCESS_VERSION
procActLabelTbl instLabelTbl;--For INSTANCE_LABEL
procActIdTbl    numTblType;  --For INSTANCE_ID

numTbl numTblType;
rowIdTbl rowIdTblType;

procedure PerformCommit;

-- procedure PropagateChangedName
--   Locates all occurrences of an old username and changes to
--   the new username.
--
-- IN:
--   OldName - Old Username we are changing from.
--   NewName - New Username we are changing to.
--   CommitFrequency - Number of updates we perform before commit.
--
procedure PropagateChangedName(
  OldName in varchar2,
  NewName in varchar2,
  docommit in BOOLEAN )

is

l_oldname VARCHAR2(320); -- Local Variable of OldName
l_newname VARCHAR2(320); -- Local Variable of NewName
l_pname VARCHAR2(50) := 'WF_MAINT_COMPLETED_ITEMS';
l_pvalue varchar2(10);
l_size number := 5000;

l_items number;
l_ias   number;
l_iash  number;
l_ntfs  number;
l_pas   number;
l_rr    number;
l_rra   number;
l_coms  number;
l_ra    number;
l_wa    number; --counter of WorlistAccess changes for the user


-- Setting up cursors for tables that would store a role name.
-- Some tables have columns named 'READ_ROLE' and 'WRITE_ROLE' that
-- are not currently used, so they are not included.

cursor cItems (l_oldname varchar2) is
select ITEM_TYPE, ITEM_KEY
from   WF_ITEMS
where  OWNER_ROLE = l_oldname;

cursor cItems2 (l_oldname varchar2) is
select ITEM_TYPE, ITEM_KEY
from   WF_ITEMS
where  OWNER_ROLE = l_oldname
and    END_DATE IS NULL;

cursor cItemActivityStatuses (l_oldname varchar2) is
select ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY
from   WF_ITEM_ACTIVITY_STATUSES
where  ASSIGNED_USER =  l_oldname;

cursor cItemActivityStatuses2 (l_oldname varchar2) is
select WIAS.ITEM_TYPE, WIAS.ITEM_KEY, WIAS.PROCESS_ACTIVITY
from   WF_ITEM_ACTIVITY_STATUSES WIAS, WF_ITEMS WI
where  WIAS.ITEM_TYPE = wi.item_type
and    WIAS.ITEM_KEY = wi.item_key
and    WI.END_DATE IS NULL
and    WIAS.ASSIGNED_USER = l_oldname;

cursor cItemActivityStatuses_H (l_oldname varchar2) is
select ITEM_TYPE, ITEM_KEY, PROCESS_ACTIVITY
from   WF_ITEM_ACTIVITY_STATUSES_H
where  ASSIGNED_USER =  l_oldname;

cursor cItemActivityStatuses_H2 (l_oldname varchar2) is
select WIASH.ITEM_TYPE, WIASH.ITEM_KEY, WIASH.PROCESS_ACTIVITY
from   WF_ITEM_ACTIVITY_STATUSES_H WIASH, WF_ITEMS WI
where  WIASH.ITEM_TYPE = wi.item_type
and    WIASH.ITEM_KEY = wi.item_key
and    WI.END_DATE IS NULL
and    WIASH.ASSIGNED_USER =  l_oldname;

cursor cNotifications (l_oldname varchar2) is
select NOTIFICATION_ID
from   WF_NOTIFICATIONS
where  RECIPIENT_ROLE     = l_oldname
or     ORIGINAL_RECIPIENT = l_oldname
or     more_info_role     = l_oldname
or     from_role          = l_oldname
or     responder          = l_oldname;

-- Only notifications belonging to active items
cursor cNotifications2 (l_oldname varchar2) is
select NOTIFICATION_ID
from   WF_NOTIFICATIONS WN
where  (WN.RECIPIENT_ROLE = l_oldname
or     WN.ORIGINAL_RECIPIENT = l_oldname
or     WN.MORE_INFO_ROLE = l_oldname
or     WN.FROM_ROLE = l_oldname
or     WN.RESPONDER = l_oldname)
and (exists (select '1'
            from   WF_ITEM_ACTIVITY_STATUSES WIAS, WF_ITEMS WI
            where  WIAS.NOTIFICATION_ID = WN.NOTIFICATION_ID
            and    WIAS.NOTIFICATION_ID is not null
            and    WIAS.ITEM_TYPE = WI.ITEM_TYPE
            and    WIAS.ITEM_KEY = WI.ITEM_KEY
            and    WI.END_DATE IS NULL)
  or exists (select '1'
            from   WF_ITEM_ACTIVITY_STATUSES_H WIASH, WF_ITEMS WI
            where  WIASH.NOTIFICATION_ID = WN.NOTIFICATION_ID
            and    WIASH.NOTIFICATION_ID is not null
            and    WIASH.ITEM_TYPE = WI.ITEM_TYPE
            and    WIASH.ITEM_KEY = WI.ITEM_KEY
            and    WI.END_DATE IS NULL));

cursor cProcessActivities (l_oldname varchar2) is
select PROCESS_ITEM_TYPE, PROCESS_NAME, PROCESS_VERSION,
       INSTANCE_LABEL, INSTANCE_ID
from   WF_PROCESS_ACTIVITIES
where  PERFORM_ROLE = l_oldname;

cursor cRoutingRules (l_oldname varchar2) is
select RULE_ID
from   WF_ROUTING_RULES
where  ROLE = l_oldname
or     ACTION_ARGUMENT = l_oldname;

cursor cRoutingRuleAttributes (l_oldname varchar2) is
select ra.ROWID
from   WF_ROUTING_RULE_ATTRIBUTES ra
where  ra.TEXT_VALUE = l_oldname
and    exists
       (select null
        from   wf_message_attributes ma
        where  ma.name=ra.name
        and    ma.type='ROLE');

cursor cWfComments (l_oldname varchar2) is
select rowid
from   wf_comments
where  from_role = l_oldname
or     to_role = l_oldname
or     proxy_role = l_oldname;

-- Only notifications belonging to active items
cursor cWfComments2 (l_oldname varchar2) is
select WC.ROWID
from   WF_COMMENTS WC
where (WC.FROM_ROLE = l_oldname
or     WC.TO_ROLE = l_oldname
or     WC.PROXY_ROLE = l_oldname)
and (exists (select '1'
            from   WF_ITEM_ACTIVITY_STATUSES WIAS, WF_ITEMS WI
            where  WIAS.NOTIFICATION_ID = WC.NOTIFICATION_ID
            and    WIAS.NOTIFICATION_ID is not null
            and    WIAS.ITEM_TYPE = WI.ITEM_TYPE
            and    WIAS.ITEM_KEY = WI.ITEM_KEY
            and    WI.END_DATE IS NULL)
  or exists (select '1'
            from   WF_ITEM_ACTIVITY_STATUSES_H WIASH, WF_ITEMS WI
            where  WIASH.NOTIFICATION_ID = WC.NOTIFICATION_ID
            and    WIASH.NOTIFICATION_ID is not null
            and    WIASH.ITEM_TYPE = WI.ITEM_TYPE
            and    WIASH.ITEM_KEY = WI.ITEM_KEY
            and    WI.END_DATE IS NULL));

cursor cRoleAttributes (l_oldname varchar2) is
select wiav.rowid
from   wf_item_attribute_values wiav, wf_item_attributes wia
where  wia.type = 'ROLE'
and    wia.item_type = wiav.item_type
and    wia.name = wiav.name
and    wiav.text_value = l_oldname;

cursor cRoleAttributes2 (l_oldname varchar2) is
select wiav.rowid
from   wf_item_attribute_values wiav, wf_item_attributes wia
where  wia.type = 'ROLE'
and    wia.item_type = wiav.item_type
and    wia.name = wiav.name
and    wiav.text_value = l_oldname
and exists (select '1'
            from  WF_ITEMS WI
            where WI.ITEM_TYPE = WIAV.ITEM_TYPE
            and   WI.ITEM_KEY = WIAV.ITEM_KEY
            and   WI.END_DATE IS NULL);

l_roleInfoTAB WF_DIRECTORY.wf_local_roles_tbl_type;

cursor cWorklistAccess is
select fg.rowid
from   FND_GRANTS fg
where  fg.GRANTEE_TYPE='USER'
and    fg.GRANTEE_ORIG_SYSTEM in ('FND_USR', 'PER')
and    fg.PROGRAM_NAME = 'WORKFLOW_UI'
and    fg.PARAMETER1=PropagateChangedName.OldName;

begin
l_newname := upper(substrb(NewName,1,320));
l_oldname := upper(substrb(OldName,1,320));

if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
  wf_log_pkg.string(wf_log_pkg.level_procedure, 'wf.plsql.wf_maintenance.propagateChangedName',
                    'Changing old user '||l_oldname||' to new '||l_newname);
end if;

g_docommit := docommit;


/* We check to be sure that old name no longer exists (IE: the name was
   changed).  If it is we can go ahead and effect the change.

   If the old name is still active and somewhere else in the directory services
   we can't change it, so we have to raise the error that the name still
   exists.

   We then check to be sure the new name is active and ready to receive
   the records from the old name.
*/

 WF_DIRECTORY.GetRoleInfo2(l_oldName, l_roleInfoTAB);

 if (l_roleInfoTAB(1).display_name is not NULL) then
  if not (WF_DIRECTORY.ChangeLocalUsername(l_oldname, l_newname, FALSE)) then
    WF_CORE.Token('ROLE', l_oldname);
    WF_CORE.Token('PROCEDURE', 'PropagateChangedName');
    WF_CORE.Token('PARAMETER', 'OldName');
    WF_CORE.Raise('WFMTN_ACTIVEROLE');
    return;
  end if;
 end if;

 WF_DIRECTORY.GetRoleInfo2(l_newname, l_roleInfoTAB);

 if  (l_roleInfoTAB(1).display_name is null) then
   WF_CORE.Token('ROLE', l_newname);
   WF_CORE.Raise('WFNTF_ROLE');
   return;
 end if;


/* We will now start looping through the cursors and updating OldName
   to NewName
*/
l_pvalue := FND_PROFILE.value(l_pname);
-- This profile is shipped only for 12.1.X and above at this point. If not
-- available, continue to update all records as always.
if (l_pvalue is null or l_pvalue = 'Y') then

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, 'wf.plsql.wf_maintenance.propagateChangedName',
                      'Updating all WF data');
  end if;

  open cItems(l_oldname);
  loop
    fetch cItems bulk collect into itemTbl, keyTbl limit l_size;
    if (itemTbl.count = 0) then
      exit;
    end if;

    forall i in itemTbl.first..itemTbl.last
      update wf_items
      set    owner_role = l_newname
      where  item_type = itemTbl(i)
      and    item_key  = keyTbl(i);

    commit;
    itemTbl.delete;
	keyTbl.delete;
  end loop;
  l_items := cItems%rowcount;
  close cItems;

  open cItemActivityStatuses(l_oldname);
  loop
    fetch cItemActivityStatuses bulk collect into procItemTbl, procKeyTbl, procActTbl limit l_size;
    if (procItemTbl.count = 0) then
      exit;
    end if;

    forall i in procItemTbl.first..procItemTbl.last
      update WF_ITEM_ACTIVITY_STATUSES
      set    ASSIGNED_USER = l_newname
      where  ITEM_TYPE = procItemTbl(i)
      and    ITEM_KEY = procKeyTbl(i)
      and    PROCESS_ACTIVITY = procActTbl(i);

    commit;
    procItemTbl.delete;
    procKeyTbl.delete;
    procActTbl.delete;
  end loop;
  l_ias := cItemActivityStatuses%rowcount;
  close cItemActivityStatuses;

  open cItemActivityStatuses_H(l_oldname);
  loop
    fetch cItemActivityStatuses_H bulk collect into procItemTbl, procKeyTbl, procActTbl limit l_size;
    if (procItemTbl.count = 0) then
      exit;
    end if;

    forall i in procItemTbl.first..procItemTbl.last
      update WF_ITEM_ACTIVITY_STATUSES_H
      set    ASSIGNED_USER = l_newname
      where  ITEM_TYPE = procItemTbl(i)
      and    ITEM_KEY = procKeyTbl(i)
      and    PROCESS_ACTIVITY = procActTbl(i);

    commit;
    procItemTbl.delete;
    procKeyTbl.delete;
    procActTbl.delete;
  end loop;
  l_iash := cItemActivityStatuses_H%rowcount;
  close cItemActivityStatuses_H;

  open cNotifications (l_oldname);
  loop
    fetch cNotifications bulk collect into numTbl limit l_size;
    if (numTbl.count = 0) then
      exit;
    end if;

    forall i in numTbl.first..numTbl.last
      update WF_NOTIFICATIONS
      set    RECIPIENT_ROLE = decode(RECIPIENT_ROLE, l_oldname, l_newname, RECIPIENT_ROLE),
             ORIGINAL_RECIPIENT = decode(ORIGINAL_RECIPIENT, l_oldname, l_newname, ORIGINAL_RECIPIENT),
             FROM_ROLE = decode(FROM_ROLE, l_oldname, l_newname, FROM_ROLE),
             RESPONDER = decode(RESPONDER, l_oldname, l_newname, RESPONDER),
             MORE_INFO_ROLE = decode(MORE_INFO_ROLE, l_oldname, l_newname, MORE_INFO_ROLE)
      where  NOTIFICATION_ID = numTbl(i);
    commit;

    numTbl.delete;
  end loop;
  l_ntfs := cNotifications%rowcount;
  close cNotifications;

  open cWfComments(l_oldname);
  loop
    fetch cWfComments bulk collect into rowIdTbl limit l_size;
    if (rowIdTbl.count = 0) then
      exit;
    end if;

    forall i in rowIdTbl.first..rowIdTbl.last
      update WF_COMMENTS
      set    FROM_ROLE = decode(FROM_ROLE, l_oldname, l_newname, FROM_ROLE),
             FROM_USER = decode(FROM_ROLE, l_oldname, l_roleInfoTAB(1).display_name, FROM_USER),
             TO_ROLE = decode(TO_ROLE, l_oldname, l_newname, TO_ROLE),
             TO_USER = decode(TO_ROLE, l_oldname, l_roleInfoTAB(1).display_name, TO_USER),
             PROXY_ROLE = decode(PROXY_ROLE, l_oldname, l_newname, PROXY_ROLE)
      where rowid = rowIdTbl(i);
    commit;

    rowIdTbl.delete;
  end loop;
  l_coms := cWfComments%rowcount;
  close cWfComments;

  open cRoleAttributes(l_oldname);
  loop
    fetch cRoleAttributes bulk collect into rowIdTbl limit l_size;
    if (rowIdTbl.count = 0) then
      exit;
    end if;

    forall i in rowIdTbl.first..rowIdTbl.last
      update WF_ITEM_ATTRIBUTE_VALUES
      set    TEXT_VALUE = l_newname
      where  rowid = rowIdTbl(i);
    commit;

    rowIdTbl.delete;
  end loop;
  l_ra := cRoleAttributes%rowcount;
  close cRoleAttributes;

else   -- End profile = 'Y'

  if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
    wf_log_pkg.string(wf_log_pkg.level_statement, 'wf.plsql.wf_maintenance.propagateChangedName',
                      'Updating only Active WF data');
  end if;

  open cItems2(l_oldname);
  loop
    fetch cItems2 bulk collect into itemTbl, keyTbl limit l_size;
    if (itemTbl.count = 0) then
      exit;
    end if;

    forall i in itemTbl.first..itemTbl.last
      update wf_items
      set    owner_role = l_newname
      where  item_type = itemTbl(i)
      and    item_key  = keyTbl(i);
    commit;
    itemTbl.delete;
    keyTbl.delete;
  end loop;
  l_items := cItems2%rowcount;
  close cItems2;

  open cItemActivityStatuses2(l_oldname);
  loop
    fetch cItemActivityStatuses2 bulk collect into procItemTbl, procKeyTbl, procActTbl limit l_size;
    if (procItemTbl.count = 0) then
      exit;
    end if;

    forall i in procItemTbl.first..procItemTbl.last
      update WF_ITEM_ACTIVITY_STATUSES
      set    ASSIGNED_USER = l_newname
      where  ITEM_TYPE = procItemTbl(i)
      and    ITEM_KEY = procKeyTbl(i)
      and    PROCESS_ACTIVITY = procActTbl(i);
    commit;
    procItemTbl.delete;
    procKeyTbl.delete;
    procActTbl.delete;
  end loop;
  l_ias := cItemActivityStatuses2%rowcount;
  close cItemActivityStatuses2;

  open cItemActivityStatuses_H2(l_oldname);
  loop
    fetch cItemActivityStatuses_H2 bulk collect into procItemTbl, procKeyTbl, procActTbl limit l_size;
    if (procItemTbl.count = 0) then
      exit;
    end if;

    forall i in procItemTbl.first..procItemTbl.last
      update WF_ITEM_ACTIVITY_STATUSES_H
      set    ASSIGNED_USER = l_newname
      where  ITEM_TYPE = procItemTbl(i)
      and    ITEM_KEY = procKeyTbl(i)
      and    PROCESS_ACTIVITY = procActTbl(i);
    commit;
    procItemTbl.delete;
    procKeyTbl.delete;
    procActTbl.delete;
  end loop;
  l_iash := cItemActivityStatuses_H2%rowcount;
  close cItemActivityStatuses_H2;

  open cNotifications2 (l_oldname);
  loop
    fetch cNotifications2 bulk collect into numTbl limit l_size;
    if (numTbl.count = 0) then
      exit;
    end if;

    forall i in numTbl.first..numTbl.last
      update WF_NOTIFICATIONS
      set    RECIPIENT_ROLE = decode(RECIPIENT_ROLE, l_oldname, l_newname, RECIPIENT_ROLE),
             ORIGINAL_RECIPIENT = decode(ORIGINAL_RECIPIENT, l_oldname, l_newname, ORIGINAL_RECIPIENT),
             FROM_ROLE = decode(FROM_ROLE, l_oldname, l_newname, FROM_ROLE),
             RESPONDER = decode(RESPONDER, l_oldname, l_newname, RESPONDER),
             MORE_INFO_ROLE = decode(MORE_INFO_ROLE, l_oldname, l_newname, MORE_INFO_ROLE)
      where  NOTIFICATION_ID = numTbl(i);
    commit;

    numTbl.delete;
  end loop;
  l_ntfs := cNotifications2%rowcount;
  close cNotifications2;

  open cWfComments2(l_oldname);
  loop
    fetch cWfComments2 bulk collect into rowIdTbl limit l_size;
    if (rowIdTbl.count = 0) then
      exit;
    end if;

    forall i in rowIdTbl.first..rowIdTbl.last
      update WF_COMMENTS
      set    FROM_ROLE = decode(FROM_ROLE, l_oldname, l_newname, FROM_ROLE),
             FROM_USER = decode(FROM_ROLE, l_oldname, l_roleInfoTAB(1).display_name, FROM_USER),
             TO_ROLE = decode(TO_ROLE, l_oldname, l_newname, TO_ROLE),
             TO_USER = decode(TO_ROLE, l_oldname, l_roleInfoTAB(1).display_name, TO_USER),
             PROXY_ROLE = decode(PROXY_ROLE, l_oldname, l_newname, PROXY_ROLE)
      where rowid = rowIdTbl(i);
    commit;

    rowIdTbl.delete;
  end loop;
  l_coms := cWfComments2%rowcount;
  close cWfComments2;

  open cRoleAttributes2(l_oldname);
  loop
    fetch cRoleAttributes2 bulk collect into rowIdTbl limit l_size;
    if (rowIdTbl.count = 0) then
      exit;
    end if;

    forall i in rowIdTbl.first..rowIdTbl.last
      update WF_ITEM_ATTRIBUTE_VALUES
      set    TEXT_VALUE = l_newname
      where  rowid = rowIdTbl(i);
    commit;

    rowIdTbl.delete;
  end loop;
  l_ra := cRoleAttributes2%rowcount;
  close cRoleAttributes2;

end if; -- End profile = 'N'

open cProcessActivities(l_oldname);
loop
  fetch cProcessActivities
  bulk collect into procActItemTbl, procActNameTbl, procActVersTbl, procActLabelTbl, procActIdTbl
  limit l_size;
  if (procActItemTbl.count = 0) then
    exit;
  end if;

  forall i in procActItemTbl.first..procActItemTbl.last
    update WF_PROCESS_ACTIVITIES
    set    PERFORM_ROLE = l_newname
    where  PROCESS_ITEM_TYPE = procActItemTbl(i)
    and    PROCESS_NAME = procActNameTbl(i)
    and    PROCESS_VERSION = procActVersTbl(i)
    and    INSTANCE_LABEL = procActLabelTbl(i)
    and    INSTANCE_ID = procActIdTbl(i);
  commit;
  procActItemTbl.delete;
  procActNameTbl.delete;
  procActVersTbl.delete;
  procActLabelTbl.delete;
  procActIdTbl.delete;
end loop;
l_pas := cProcessActivities%rowcount;
close cProcessActivities;

open cRoutingRules(l_oldname);
loop
  fetch cRoutingRules bulk collect into numTbl limit l_size;
  if (numTbl.count = 0) then
    exit;
  end if;

  forall i in numTbl.first..numTbl.last
    update WF_ROUTING_RULES
    set    ROLE = l_newname
    where  RULE_ID = numTbl(i)
    and    ROLE = l_oldname;
  commit;

  forall i in numTbl.first..numTbl.last
    update WF_ROUTING_RULES
    set    ACTION_ARGUMENT = l_newname
    where  RULE_ID = numTbl(i)
    and    ACTION_ARGUMENT = l_oldname;
  commit;

  numTbl.delete;
end loop;
l_rr := cRoutingRules%rowcount;
close cRoutingRules;

open cRoutingRuleAttributes(l_oldname);
loop
  fetch cRoutingRuleAttributes bulk collect into rowIdTbl limit l_size;
  if (rowIdTbl.count = 0) then
    exit;
  end if;

  forall i in rowIdTbl.first..rowIdTbl.last
    update wf_routing_rule_attributes
    set    text_value = l_newname
    where  rowid = rowIdTbl(i);
  commit;

  rowIdTbl.delete;
end loop;
l_rra := cRoutingRuleAttributes%rowcount;
close cRoutingRuleAttributes;

commit;

open cWorklistAccess;
LOOP
  FETCH cWorklistAccess BULK COLLECT INTO rowIdTbl LIMIT l_size;
  if (rowIdTbl.count = 0) then
    exit;
  end if;
  FORALL i IN rowIdTbl.FIRST..rowIdTbl.LAST
  UPDATE fnd_grants fg
  SET    fg.parameter1=PropagateChangedName.NewName
  WHERE  fg.ROWID=rowIdTbl(i);
  COMMIT;
  rowIdTbl.DELETE;
end LOOP;
l_wa := cWorklistAccess%ROWCOUNT;
CLOSE cWorklistAccess;

if (wf_log_pkg.level_statement >= fnd_log.g_current_runtime_level) then
  wf_log_pkg.string(wf_log_pkg.level_statement, 'wf.plsql.wf_maintenance.propagateChangedName',
                    'Updated Records: WF_ITEMS:'||l_items||', WF_IAS:'||l_ias||', WF_IASH:'
                     ||l_iash||', WF_NTFS:'||l_ntfs||', WF_COMMENTS:'||l_coms);
  wf_log_pkg.string(wf_log_pkg.level_statement, 'wf.plsql.wf_maintenance.propagateChangedName',
                    'Updated Records: WF_PROC_ACTS:'||l_pas||', WF_ROUTING_RULES:'||l_rr
                    ||', WF_ROUTING_RULE_ATTRS:' ||l_rra||', WF_ITEM_ATTR_VALUES:'||l_ra
                    ||', WORKLIST_ACCESS:'||l_wa);
end if;

exception
 when others then
   WF_CORE.Context('WF_MAINTENANCE', 'PropagateChangedName', OldName, NewName);
   raise;
end PropagateChangedName;

-- procedure PerformCommit (private)
--   Decides if commit should occur and commits.
--
-- IN:
--   No Parameters.
--
procedure PerformCommit

IS
BEGIN
if (g_docommit) then
 g_commitCounter := g_commitCounter +1;
 if (g_commitCounter >= WF_MAINTENANCE.g_CommitFrequency) then
    commit;
    g_commitCounter := 0;
 end if;
end if;

END PerformCommit;

-- Procedure FixWURAEffectiveDates (private)
-- As part of fix 9184359. Scan table WF_USER_ROLE_ASSIGNMENTS for rows with
-- null effective start/end dates and will set them according the the
-- values of the other date columns
-- IN: No p_maxRows. This parameter comes from main procedure ValidateUserRoles
--
procedure FixWURAEffectiveDates (p_maxRows IN NUMBER, p_username IN VARCHAR2,
                                 p_rolename IN VARCHAR2)
IS
--  TYPE WURARecord is RECORD (l_rowid ROWID,
--       start_date date, end_date date, u_start_date date, u_end_date date,
--       r_start_date date, r_end_date date, ar_start_date date, ar_end_date date,
--       e_start_date date, e_end_date date);
--  TYPE WURATab is table of WURARecord index by BINARY_INTEGER;
  TYPE dateTab is table of date index by binary_integer;
  l_start_dateTab dateTab;
  l_end_dateTab dateTab;
  l_u_start_dateTab dateTab;
  l_u_end_dateTab dateTab;
  l_r_start_dateTab dateTab;
  l_r_end_dateTab dateTab;
  l_ar_start_dateTab dateTab;
  l_ar_end_dateTab dateTab;
  l_e_start_dateTab dateTab;
  l_e_end_dateTab dateTab;
  TYPE rowidTab is table of rowid index by binary_integer;
  l_rowidTab rowidTab;
  cursor c_nullEffectiveDates is
  select ROWID, start_date, end_date, user_start_date, user_end_date,
         role_start_date, role_end_date,
         assigning_role_start_date, assigning_role_end_date, null, null
  from   WF_USER_ROLE_ASSIGNMENTS WURA
  where  (WURA.USER_NAME = p_username or p_username is null)
  and    (WURA.ROLE_NAME = p_rolename or p_rolename is null)
  and    (WURA.EFFECTIVE_START_DATE is null
  or     WURA.EFFECTIVE_END_DATE is null);
BEGIN
  open c_nullEffectiveDates;
  <<NullEffectiveDates>>
  loop
    fetch c_nullEffectiveDates
    bulk collect
    into l_rowidTab, l_start_dateTab, l_end_dateTab, l_u_start_dateTab,
         l_u_end_dateTab, l_r_start_dateTab, l_r_end_dateTab, l_ar_start_dateTab,
         l_ar_end_dateTab, l_e_start_dateTab, l_e_end_dateTab
    limit p_maxRows;
    if l_rowidTab.COUNT > 0 then
        for i in l_rowidTab.FIRST..l_rowidTab.LAST loop
          WF_ROLE_HIERARCHY.Calculate_Effective_Dates(l_start_dateTab(i),
                                                      l_end_dateTab(i),
                                                      l_u_start_dateTab(i),
                                                      l_u_end_dateTab(i),
                                                      l_r_start_dateTab(i),
                                                      l_r_end_dateTab(i),
                                                      l_ar_start_dateTab(i),
                                                      l_ar_end_dateTab(i),
                                                      l_e_start_dateTab(i),
                                                      l_e_end_dateTab(i));
        end loop;
        begin
          forall j in l_rowidTab.FIRST.. l_rowidTab.LAST
            update WF_USER_ROLE_ASSIGNMENTS WURA
            set    WURA.EFFECTIVE_START_DATE=l_e_start_dateTab(j),
                   WURA.EFFECTIVE_END_DATE  =l_e_end_dateTab(j)
            where  WURA.ROWID=l_rowidTab(j);
        exception
          when others then
            if c_nullEffectiveDates%ISOPEN then
              close c_nullEffectiveDates;
            end if;
            raise;
        end;
    end if;
    if l_rowidTab.COUNT < p_maxRows then
      exit NullEffectiveDates;
    end if;
  end loop NullEffectiveDates;
  close c_nullEffectiveDates;
exception
  when others then
    if c_nullEffectiveDates%ISOPEN then
      close c_nullEffectiveDates;
    end if;
    raise;
END FixWURAEffectiveDates;

-- procedure FixLUREffectiveDates (private)
--   Fix incorrect Effective_End_Date in WF_LOCAL_USER_ROLES as pert of bug 8423138
--
-- IN:
--   No p_maxRows. This parameter comes from main procedure ValidateUserRoles
--
procedure FixLUREffectiveDates(p_maxRows IN NUMBER, p_username IN VARCHAR2,
                               p_rolename IN VARCHAR2)
is
  TYPE idTab   IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  TYPE dateTab IS TABLE OF DATE INDEX BY BINARY_INTEGER;

  type nameTab is table of varchar2(100) index by binary_integer;

  l_LURTab idTab;
  l_URAEffectiveStartDate dateTab;
  l_URAEffectiveEndDate dateTab;

  cursor c_invalidEffectiveDates is
  select lur.rowid,
         ura.effective_start_date,ura.effective_end_date
  from   wf_local_user_roles lur,
         (select user_name, role_name, min(effective_start_date) effective_start_date,
                 max (effective_end_date) effective_end_date
            from wf_user_role_assignments group by user_name, role_name) ura
  where  ura.user_name = lur.user_name
    and  ura.role_name = lur.role_name
    and  (URA.USER_NAME=p_username or p_username is null)
    and  (URA.ROLE_NAME=p_rolename or p_rolename is null)
    and  (ura.effective_start_date <> lur.effective_start_date or
          ura.effective_end_date <> lur.effective_end_date);

begin
  <<InvalidEffectiveDates>>
  loop
    open c_invalidEffectiveDates;
    fetch c_invalidEffectiveDates bulk collect
      into  l_LURTab,
            l_URAEffectiveStartDate,
            l_URAEffectiveEndDate
      limit p_maxRows;
    close c_invalidEffectiveDates;
    if (l_LURTab.COUNT > 0) then
      begin
        forall i in l_LURTab.FIRST..l_LURTab.LAST
          update WF_LOCAL_USER_ROLES
          set    EFFECTIVE_START_DATE=l_URAEffectiveStartDate(i),
                 EFFECTIVE_END_DATE=l_URAEffectiveEndDate(i)
          where  ROWID = l_LURTab(i);
      exception
        when others then
          if (c_invalidEffectiveDates%ISOPEN) then
            close c_invalidEffectiveDates;
          end if;
        raise;
      end;
    end if;
    if (l_LURTab.COUNT < p_maxRows) then
      exit InvalidEffectiveDates;
    end if;
  end loop InvalidEffectiveDates;
  exception
    when others then
      if c_invalidEffectiveDates%ISOPEN then
        close c_invalidEffectiveDates;
      end if;
      raise;
end FixLUREffectiveDates;

------------------------------------------------------------------------------
/*
** ValidateUserRoles - Validates and corrects denormalized user and role
**                     information in user/role relationships.
*/
PROCEDURE ValidateUserRoles(p_BatchSize in NUMBER,
                            p_username in varchar2,
                            p_rolename in varchar2,
                            p_check_dangling in BOOLEAN,
                            p_check_missing_ura in BOOLEAN,
                            p_UpdateWho in BOOLEAN,
                            p_parallel_processes in number) is

  ColumnsMissing      EXCEPTION;
  TooManyRows         EXCEPTION;

  pragma exception_init(ColumnsMissing, -904);
  pragma exception_init(TooManyRows, -1422);

  TYPE charTab IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  TYPE dateTab IS TABLE OF DATE 	  INDEX BY BINARY_INTEGER;
  TYPE numTab  IS TABLE OF NUMBER	  INDEX BY BINARY_INTEGER;
  TYPE idTab   IS TABLE OF ROWID 	  INDEX BY BINARY_INTEGER;
  TYPE origTab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE ownerTAGTAB  IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

  l_roleSrcTAB 	        WF_DIRECTORY.roleTable;
  l_userSrcTAB 	        WF_DIRECTORY.userTable;
  l_roleDestTAB 	WF_DIRECTORY.roleTable;
  l_userDestTAB         WF_DIRECTORY.userTable;
  l_rowIDTAB            idTab;
  l_rowIDSrcTAB         idTab;
  l_rowIDDestTAB        idTab;
  l_stgIDTAB            idTab;
  l_userStartSrcTAB     dateTab;
  l_roleStartSrcTAB     dateTab;
  l_userEndSrcTAB       dateTab;
  l_roleEndSrcTAB       dateTab;
  l_effStartSrcTAB      dateTab;
  l_effEndSrcTAB        dateTab;
  l_AssignTAB           charTab;
  l_userStartDestTAB    dateTab;
  l_roleStartDestTAB	dateTab;
  l_userEndDestTAB      dateTab;
  l_roleEndDestTAB 	dateTab;
  l_effStartDestTAB     dateTab;
  l_effEndDestTAB	dateTab;
  l_relIDTAB	        numTab;
  l_maxRows	        number;
  l_userOrigIDSrcTAB    numTab;
  l_roleOrigIDSrcTAB    numTab;
  l_userOrigIDDestTAB   numTab;
  l_roleOrigIDDEstTAB   numTab;
  l_userOrigSrcTAB	origTab;
  l_roleOrigSrcTAB      origTab;
  l_userOrigDestTAB	origTab;
  l_roleOrigDestTAB     origTab;
  l_assigningRoleSrcTAB WF_DIRECTORY.roleTable;
  l_asgStartSrcTAB	dateTab;
  l_asgEndSrcTAB        dateTab;
  l_startSrcTAB         dateTab;
  l_endSrcTAB           dateTab;

  l_startDestTAB        dateTab;
  l_endDestTAB          dateTab;
  l_partTAB             numTab;
  l_userID              number;
  l_empID               number;

  sumTabIndex           number;
  ur_index              number;
  l_eIndex              number;

  l_activeAssigned      boolean;
  l_updateDateTAB       dateTAB;
  l_createDateTAB       dateTAB;
  l_updatedByTAB        numTAB;
  l_updateLoginTAB      numTAB;
  l_createdByTAB        numTAB;
  l_parentOrigTAB       origTAB;
  l_parentOrigIDTAB     numTAB;
  l_ownerTAGS           ownerTAGTAB;
  -- <bug 6823723>
  l_sql                 varchar2(6000);
  l_defaultParProc      number;
  l_parallelProc        varchar2(5);

  result number;
  l_lockhandle varchar2(200);

  -- Bug 6752821. Each cursor will have three more variations depending
  -- on wheather a username and/or rolename is specified
  -- cursor named %1 used when both username and rolename are provided
  -- cursor named %2 used when only username is provided
  -- cursor named %3 used when only rolename is provided
  -- cursor named %4 used when none are provided

  -- Missing records in WF_USER_ROLE_ASSIGNMENTS
  -- Using same cursor parameter names as Procedures' param names.
  cursor c_missing_user_role_asg(p_username varchar2, p_rolename varchar2 ) is
    select user_name, role_name, -1, start_date, expiration_date,
           created_by, creation_date, last_updated_by, last_update_date,
           last_update_login, user_start_date, role_start_date,
           user_end_date, role_end_date, partition_id,
           effective_start_date, effective_end_date, user_orig_system,
           user_orig_system_id, role_orig_system, role_orig_system_id,
           parent_orig_system, parent_orig_system_id, owner_tag
    from wf_local_user_roles wur
    where (p_username IS NULL OR wur.user_name=p_username)
	   and   (p_rolename IS NULL OR wur.role_name=p_rolename)
	   and   not exists (select null
                      from wf_user_role_assignments wura
                      where wura.user_name = wur.user_name
                      and wura.role_name = wur.role_name
                      and (p_username is null OR wura.user_name = p_username)
                      and (p_rolename is null or wura.role_name = p_rolename)
                      );


  -- Invalid and Duplicated records in the (FND_USR) partition
  -- For bug 6752821: no need to consider role_name, it does not intervene,
  -- no (FND_RESP) partition is considered.
  cursor c_invalid_fnd_users (p_username varchar2) is
    select wu.rowid, wu.orig_system old_orig_system,
           wu.orig_system_id old_orig_system_id,
           decode(nvl(fu.employee_id, -1),-1,'FND_USR','PER') new_orig_system,
           nvl(fu.employee_id, fu.user_id)
    from   wf_local_roles partition (FND_USR) wu,
           fnd_user fu
    where  wu.name = fu.user_name
   	and    (p_username is null or wu.name = p_username)
    and    (wu.orig_system <> decode(nvl(fu.employee_id, -1),-1,'FND_USR','PER')
            or wu.orig_system_id <> nvl(fu.employee_id, fu.user_id)
           );


	  -- Records with invalid or duplicate FND_USR/PER references
  -- in WF_LOCAL_USER_ROLES
  -- For bug 6752821: no need for cursors %2 and %3 as role_name does not intervene,
  -- no (FND_RESP) partition is considered.

  cursor c_invalOrigSys (p_username varchar2) is
   select wu.orig_system, wu.orig_system_id,
          wur.role_orig_system, wur.role_orig_system_id,
          wur.partition_id, wur.rowid
   from   wf_local_user_roles wur,
          wf_local_roles partition (FND_USR) wu
   where  (p_username is null or wu.name = p_username )
   and    wu.name = wur.user_name
   and    wur.user_orig_system in ('FND_USR','PER')
   and    (wur.user_orig_system <> wu.orig_system
          or  wur.user_orig_system_id <> wu.orig_system_id
             --check for role_orig_system in case of self-reference
          or (wur.partition_id=1
              and (wur.role_orig_system <> wu.orig_system
                    or  wur.role_orig_system_id <> wu.orig_system_id)
              )
          );



  --We will correct the orig_system, orig_system_id information for any
  --incorrect fnd_usr/per user/role records.  This is processed after the
  --fnd_usr/per records in wf_local_roles are validated. The dates will be
  --resolved in when c_userRoleAssignments are resolved.
  -- For bug 6752821: no need to consider rolename as this check is for self-reference

  cursor c_userSelfReference (p_username varchar2) is
    select wura.rowid, wur.rowid, wu.start_date, wu.expiration_date,
           wu.orig_system, wu.orig_system_id
    from   wf_local_user_roles partition (FND_USR) wur,
           wf_local_roles partition (FND_USR) wu,
           wf_user_role_assignments partition (FND_USR)  wura
    --Equi-joins to select the proper relationships between the tables
    where  (p_username is null OR wura.user_name = p_username)
	   and    wura.partition_id = wu.partition_id
    and    wura.partition_id = wu.partition_id
    and    wur.user_name = wu.name
    and    wur.role_name = wu.name
    and    wura.assigning_role = wu.name
    and    wura.user_name = wu.name
    and    wura.role_name = wu.name
    --Criteria to select records that need to be corrected, beginning with
    --broad checks (if effective dates are null, no reason to check further)
    --and working down to more specific checks between the orig_system/id
    and    ((wur.effective_start_date is null or
             wur.effective_end_date is null or
             wura.effective_start_date is null or
             wura.effective_end_date is null)
      or    ((wur.user_orig_system <> wu.orig_system) or
             (wur.user_orig_system_id <> wu.orig_system_id) or
             (wur.role_orig_system <> wu.orig_system) or
             (wur.role_orig_system_id <> wu.orig_system_id))
      or    (wura.user_orig_system is null or wura.role_orig_system is null or
             wura.user_orig_system_id is null or
             wura.user_orig_system_id is null)
      or    (wura.user_orig_system <> wu.orig_system)
      or    (wura.user_orig_system_id <> wu.orig_system_id)
      or    (wura.role_orig_system <> wu.orig_system)
      or    (wura.role_orig_system_id <> wu.orig_system_id)
      or    (wu.start_date is null and
              (wur.start_date is not null or
               wur.user_start_date is not null or
               wur.role_start_date is not null or
               wur.effective_start_date <> to_date(1,'J')))
      or    (wu.start_date is not null and
              (wur.start_date is null or wur.user_start_date is null or
               wur.role_start_date is null or wur.start_date <> wu.start_date or
               wur.user_start_date <> wu.start_date or
               wur.role_start_date <> wu.start_date or
               wur.effective_start_date <> wu.start_date))
      or    (wu.expiration_date is null and
              (wur.expiration_date is not null or
               wur.user_end_date is not null or wur.role_end_date is not null or
               wur.effective_end_date <> to_date('9999/01/01','YYYY/MM/DD')))
      or    (wu.expiration_date is not null and
              (wur.expiration_date is null or wur.user_end_date is null or
               wur.role_end_date is null or
               wur.expiration_date <> wu.expiration_date or
               wur.user_end_date <> wu.expiration_date or
               wur.role_end_date <> wu.expiration_date or
               wur.effective_end_date <> wu.expiration_date)));

  --Now we will correct other user/role relationships, including the user
  --orig_system/id information of any record that an fnd_usr/per may be
  --participating in.
  cursor c_UserRoleAssignments (p_username varchar2, p_rolename varchar2) is
    select rowid, wura_id,wur_id,role_name,user_name,
      assigning_role, start_date, end_Date,role_start_date,
      role_end_date, user_start_date,user_end_date,
      role_orig_system,role_orig_system_id,
      user_orig_system, user_orig_system_id,
      assigning_role_start_date, assigning_role_end_date,
      effective_start_date, effective_end_date,
      relationship_id
   from wf_ur_validate_stg
	  where (p_username is null OR user_name = p_username)
	  and   (p_rolename is null OR role_name = p_rolename)
   order by  ROLE_NAME, USER_NAME;

  -- Dangling records
  CURSOR dangling_UR_refs (p_username varchar2 , p_rolename varchar2) is
    select rowid
    from   wf_local_user_roles
    where  (p_username IS NULL OR user_name= p_username )
    AND    (p_rolename IS NULL OR role_name = p_rolename)
    AND    ( not exists (select null from wf_local_roles
                         WHERE name= user_name
                         AND (p_username IS NULL OR name= p_username)
                        )
           or  not EXISTS (select null from wf_local_roles
                            WHERE NAME = role_name
                            AND (p_rolename IS NULL OR name= p_rolename)
                           )
           );


  -- Same from user_role_assignments
  CURSOR dangling_URA_refs (p_username varchar2, p_rolename varchar2) is
    select rowid
    from   wf_user_role_assignments
    where  (p_username IS NULL OR user_name = p_username )
	   and    (p_rolename IS NULL OR role_name = p_rolename )
    -- Either user name or role name NOT in wf_local_roles
    and    (user_name not in (select name from wf_local_roles
                              WHERE (p_username is null or name = p_username)
                              )
            -- Check RoleName
            or     role_name not in (select name from wf_local_roles
                                     WHERE (p_rolename IS NULL OR NAME = p_rolename)
                                     )
           );


  l_modulePkg varchar2(240) := 'WF_MAINTENANCE.ValidateUserRoles';

begin
-- Log only
-- BINDVAR_SCAN_IGNORE[2]
  WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                     'Begin ValidateUserRoles('||p_batchSize||')');
  --First validate the inbound parameter(s)
  if (p_BatchSize is NULL or (p_BatchSize < 1)) then
    l_MaxRows := 10000;
  else
    l_MaxRows := p_BatchSize;
  end if;

  -- Acquire a session lock to ensure that only one instance of the program is
  -- running at a time.
  dbms_lock.allocate_unique('WF_MAINTENANCE.ValidateUserRoles',l_lockhandle);

  if (dbms_lock.request(lockhandle=>l_lockhandle,
                        lockmode=>dbms_lock.x_mode,
                        timeout=>0) <> 0) then
   wf_core.raise('WF_LOCK_FAIL');
  end if;

  if (p_check_dangling is not null and p_check_dangling) then
  --Validate that the users and roles who participate in user/role
  --relationships actually exist.
  begin
    <<Dangling_UR_Reference>>
    loop
      open dangling_UR_refs (p_username, p_rolename) ;
      fetch dangling_UR_refs bulk collect into l_rowIDTAB limit l_maxRows;
      close dangling_UR_refs;

      if (l_rowIDTAB.COUNT > 0) then
        forall i in l_rowIDTAB.FIRST..l_rowIDTAB.LAST
          DELETE from WF_LOCAL_USER_ROLES
          WHERE  rowid = l_rowIDTAB(i);
          commit;
      end if;

      if (l_rowIDTAB.COUNT < l_maxRows) then
        exit Dangling_UR_Reference;
      end if;
    end loop Dangling_UR_Reference;
  exception
    when others then
      if dangling_UR_refs%ISOPEN then
        close dangling_UR_refs;
      end if;

      raise;
  end;
  --Truncate the rowid tab.
  l_rowIDTAB.DELETE;
  begin
    <<Dangling_URA_Reference>>
    loop
      open dangling_URA_refs (p_username, p_rolename) ;
      fetch dangling_URA_refs bulk collect into l_rowIDTAB limit l_maxRows;
      close dangling_URA_refs;

      if (l_rowIDTAB.COUNT > 0) then
        forall i in l_rowIDTAB.FIRST..l_rowIDTAB.LAST
          DELETE from WF_USER_ROLE_ASSIGNMENTS
          WHERE  rowid = l_rowIDTAB(i);
          commit;
      end if;

      if (l_rowIDTAB.COUNT < l_maxRows) then
        exit Dangling_URA_Reference;
      end if;
    end loop Dangling_URA_Reference;
  exception
    when others then
      if dangling_URA_refs%ISOPEN then
        close dangling_URA_refs;
      end if;

      raise;
  end;
  --Truncate the rowid tab.
  l_rowIDTAB.DELETE;
 end if;

   if (p_check_missing_ura is not null and p_check_missing_ura) then
    --Validate that the users and roles who participate in user/role
    --relationships actually exist.
    begin
      <<Missing_URA_Reference>>
      loop
        l_userSrcTAB.DELETE;
        open c_missing_user_role_asg (p_username, p_rolename);
        fetch c_missing_user_role_asg bulk collect into l_userSrcTAB,
              l_roleSrcTAB, l_relIDTAB, l_startSrcTAB, l_endSrcTAB,
              l_createdByTAB, l_createDateTAB, l_updatedByTAB, l_updateDateTAB,
              l_updateLoginTAB, l_userStartSrcTAB, l_roleStartSrcTAB,
              l_userEndSrcTAB, l_roleEndSrcTAB, l_partTAB, l_effStartSrcTAB,
              l_effEndSrcTAB, l_userOrigSrcTAB, l_userOrigIDSrcTAB,
              l_roleOrigSrcTAB, l_roleOrigIDSrcTAB, l_parentOrigTAB,
              l_parentOrigIDTAB, l_ownerTAGS
              limit l_maxRows;
        close c_missing_user_role_asg;


        if (l_userSrcTAB.COUNT > 0) then
          begin
            forall i in l_userSrcTAB.FIRST..l_userSrcTAB.LAST save exceptions

              insert into WF_USER_ROLE_ASSIGNMENTS (USER_NAME,
                ROLE_NAME, RELATIONSHIP_ID, ASSIGNING_ROLE, START_DATE,
                END_DATE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
                LAST_UPDATE_DATE, LAST_UPDATE_LOGIN, USER_START_DATE,
                ROLE_START_DATE, ASSIGNING_ROLE_START_DATE, USER_END_DATE,
                ROLE_END_DATE, ASSIGNING_ROLE_END_DATE, PARTITION_ID,
                EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, USER_ORIG_SYSTEM,
                USER_ORIG_SYSTEM_ID, ROLE_ORIG_SYSTEM, ROLE_ORIG_SYSTEM_ID,
                PARENT_ORIG_SYSTEM, PARENT_ORIG_SYSTEM_ID, OWNER_TAG)
                values (l_userSrcTAB(i), l_roleSrcTAB(i), l_relIDTAB(i),
                 l_roleSrcTAB(i), l_startSrcTAB(i), l_endSrcTAB(i),
                 l_createdByTAB(i), l_createDateTAB(i), l_updatedByTAB(i),
                 l_updateDateTAB(i), l_updateLoginTAB(i), l_userStartSrcTAB(i),
                 l_roleStartSrcTAB(i), l_roleStartSrcTAB(i), l_userEndSrcTAB(i),
                 l_roleEndSrcTAB(i), l_roleEndSrcTAB(i), l_partTAB(i),
                 l_effStartSrcTAB(i), l_effEndSrcTAB(i), l_userOrigSrcTAB(i),
                 l_userOrigIDSrcTAB(i), l_roleOrigSrcTAB(i),
                 l_roleOrigIDSrcTAB(i), l_parentOrigTAB(i),
                 l_parentOrigIDTAB(i), l_ownerTAGS(i));
              commit;
          exception
            when others then
              for j in 1..sql%bulk_exceptions.count loop
                if (sql%bulk_exceptions(j).ERROR_CODE = 1) then
                  --Ignore a dup_val_on_index.  That just means that the
                  --user/role name combination was already assigned during this
                  --job.
                  null;
                else
                  raise;
                end if;
              end loop;
          end;
        end if;

        if (l_userSrcTAB.COUNT < l_maxRows) then
          exit Missing_URA_Reference;
        end if;
      end loop Missing_URA_Reference;
    exception
      when others then
        if c_missing_user_role_asg%ISOPEN then
          close c_missing_user_role_asg;
        end if;

        raise;
    end;
  end if;

  --Now we will correct any invalid fnd_usr records in WF_LOCAL_ROLES.  This
  --orig_system can have errors because we routinely have to change the
  --orig_system, orig_system_id whenever a user is associated or dis-associated
  --with an employee.
  begin
    <<fnd_usr_loop>>
    loop
      --Clear the l_rowIDTAB before the next iteration
      l_rowIDTAB.DELETE;
      open  c_invalid_fnd_users (p_username);
      fetch c_invalid_fnd_users bulk collect into l_rowIDTAB, l_userOrigSrcTAB,
            l_userOrigIDSrcTAB, l_userOrigDestTAB, l_userOrigIDDestTAB
            limit l_maxRows;
      close c_invalid_fnd_users;

      if (l_rowIDTAB.count > 0) then
        begin
          forall i in l_rowIDTAB.FIRST..l_rowIDTAB.LAST save exceptions
            UPDATE WF_LOCAL_ROLES
            SET    orig_system = l_userOrigDestTAB(i),
                   orig_system_id = l_userOrigIDDestTAB(i)
            WHERE  rowid = l_rowIDTAB(i);
        exception
          when others then
            for j in 1..sql%bulk_exceptions.count loop
              l_eIndex := sql%bulk_exceptions(j).ERROR_INDEX;
              delete from wf_local_roles
              where  rowid = l_rowIDTAB(l_eIndex);
            end loop;
        end;
        commit;
      end if;
      if (l_rowIDTab.count < l_maxRows) then
        commit;
        exit fnd_usr_loop;
      end if;
    end loop fnd_usr_loop;
  exception
    when others then
      if c_invalid_fnd_users%ISOPEN then
        close c_invalid_fnd_users;
      end if;

      raise;
  end; --End of duplicate/invalid FND_USR/PER user correction.

  -- Now we correct the FND_USR/PER orig_system values on the user side
  -- of user/role assignments as well as user-self-references in
  -- WF_LOCAL_USER_ROLES

  begin
  <<inval_orig_sys_loop>>
    loop
      --Clear the l_rowIDTAB before the next iteration
      l_rowIDTAB.DELETE;

      open  c_invalOrigSys (p_username) ;
      fetch c_invalOrigSys bulk collect into l_userOrigSrcTAB,
        l_userOrigIDSrcTAB, l_roleOrigSrcTAB, l_roleOrigIDSrcTAB,
        l_partTAB,l_rowIDTAB
        limit l_maxRows;
      close c_invalOrigSys;


      if (l_rowIDTAB.count > 0) then
          for i in  l_rowIDTAB.FIRST..l_rowIDTAB.LAST loop
            -- check whether this is a case of user=role
           if l_partTAB(i) = 1 then
              -- set the role_orig_system values as well.
              l_roleOrigSrcTAB(i) := l_userOrigSrcTAB(i);
              l_roleOrigIDSrcTAB(i) := l_userOrigIDSrcTAB(i);
           end if;
          end loop;
          --perform the bulk update.. delete duplicates in case of
          -- dup_val_on_index Exception.
          begin
          forall i in l_rowIDTAB.FIRST..l_rowIDTAB.LAST save exceptions
            UPDATE WF_LOCAL_USER_ROLES
            SET    user_orig_system = l_userOrigSrcTAB(i),
                   user_orig_system_id = l_userOrigIDSrcTAB(i),
                   role_orig_system = l_roleOrigSrcTAB(i),
                   role_orig_system_id = l_roleOrigIDSrcTAB(i)
            WHERE  rowid = l_rowIDTAB(i);
           exception
            when others then
             for j in 1..sql%bulk_exceptions.count loop
              if (sql%bulk_exceptions(j).ERROR_CODE = 1) then
               l_eIndex := sql%bulk_exceptions(j).ERROR_INDEX;
               delete from wf_local_user_roles
               where  rowid = l_rowIDTAB(l_eIndex);
              end if;
             end loop;
           end;
           commit;
      end if;
      if (l_rowIDTab.count < l_maxRows) then
        commit;
        exit inval_orig_sys_loop;
      end if;
    end loop inval_orig_sys_loop;
  exception
    when others then
      if c_invalOrigSys%ISOPEN then
        close c_invalOrigSys;
      end if;

      raise;
  end; --End of duplicate/invalid FND_USR/PER correction in WF_LOCAL_USER_ROLES.

  --Next, we correct the corrupt self-reference records in
  --wf_user_role_Assignments and wf_local_user_Roles.
  begin
  <<self_refer_loop>>
  loop
    --We will commit on each loop cycle to prevent fetch across commits, we will
    --close and reopen the cursor on each fetch.  This would mean that we are
    --pulling more than 10000 if we loop more than once and would rather have
    --a performance impact here than encounter rollback segment problems.
    --The where criteria of the cursor will not re-select the updated rows so
    --we do not have to worry about retaining a position.

    open c_userSelfReference (p_username);
    fetch c_userSelfReference
    bulk collect into l_rowIDTAB, l_rowIDSrcTAB, l_startSrcTAB,
                    l_endSrcTAB, l_userOrigSrcTAB, l_userOrigIDSrcTAB
    limit l_maxRows;
    close c_userSelfReference;

    --We now have pl/sql tables in memory that we can update with the new
    --values. So we loop through them and begin the processing.
    if (l_rowIDTAB.COUNT < 1) then
      exit self_refer_loop;
    end if;

    --We now have a complete series of pl/sql tables with
    --all of the start/end dates and calculated effective start/end dates
    --We can then issue the bulk  update.
    begin
     if (p_UpdateWho is not null and p_UpdateWho) then
      forall tabIndex in l_rowIDTAB.FIRST..l_rowIDTAB.LAST save exceptions
        update  WF_USER_ROLE_ASSIGNMENTS
        set     ROLE_START_DATE = l_StartSrcTAB(tabIndex),
                ROLE_END_DATE = l_EndSrcTAB(tabIndex),
                USER_START_DATE = l_StartSrcTAB(tabIndex),
                USER_END_DATE = l_EndSrcTAB(tabIndex),
                START_DATE    = l_StartSrcTAB(tabIndex),
                END_DATE      = l_EndSrcTAB(tabIndex),
                EFFECTIVE_START_DATE = nvl(l_StartSrcTAB(tabIndex),
                                           to_date(1,'J')),
                EFFECTIVE_END_DATE = nvl(l_EndSrcTAB(tabIndex),
                                         to_date('9999/01/01', 'YYYY/MM/DD')),
                ASSIGNING_ROLE_START_DATE = l_StartSrcTAB(tabIndex),
                ASSIGNING_ROLE_END_DATE = l_EndSrcTAB(tabIndex),
                USER_ORIG_SYSTEM=l_userOrigSrcTAB(tabIndex),
                ROLE_ORIG_SYSTEM=l_userOrigSrcTAB(tabIndex),
                USER_ORIG_SYSTEM_ID=l_userOrigIDSrcTAB(tabIndex),
                ROLE_ORIG_SYSTEM_ID=l_userOrigIDSrcTAB(tabIndex),
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID
        where   rowid = l_rowIDTAB(tabIndex);
     else --donot touch the WHO columns. This is default behavior
      forall tabIndex in l_rowIDTAB.FIRST..l_rowIDTAB.LAST save exceptions
        update  WF_USER_ROLE_ASSIGNMENTS
        set     ROLE_START_DATE = l_StartSrcTAB(tabIndex),
                ROLE_END_DATE = l_EndSrcTAB(tabIndex),
                USER_START_DATE = l_StartSrcTAB(tabIndex),
                USER_END_DATE = l_EndSrcTAB(tabIndex),
                START_DATE    = l_StartSrcTAB(tabIndex),
                END_DATE      = l_EndSrcTAB(tabIndex),
                EFFECTIVE_START_DATE = nvl(l_StartSrcTAB(tabIndex),
                                           to_date(1,'J')),
                EFFECTIVE_END_DATE = nvl(l_EndSrcTAB(tabIndex),
                                         to_date('9999/01/01', 'YYYY/MM/DD')),
                ASSIGNING_ROLE_START_DATE = l_StartSrcTAB(tabIndex),
                ASSIGNING_ROLE_END_DATE = l_EndSrcTAB(tabIndex),
                USER_ORIG_SYSTEM=l_userOrigSrcTAB(tabIndex),
                ROLE_ORIG_SYSTEM=l_userOrigSrcTAB(tabIndex),
                USER_ORIG_SYSTEM_ID=l_userOrigIDSrcTAB(tabIndex),
                ROLE_ORIG_SYSTEM_ID=l_userOrigIDSrcTAB(tabIndex)
        where   rowid = l_rowIDTAB(tabIndex);
     end if;
    exception
       when others then
         for j in 1..sql%bulk_exceptions.count loop
           if (sql%bulk_exceptions(j).ERROR_CODE = 1) then
             --If update violates dup_val_on_index, we can simply delete.
             l_eIndex := sql%bulk_exceptions(j).ERROR_INDEX;
             delete from wf_user_role_assignments
             where rowid = l_rowIDTAB(l_eIndex);
           else
             raise;
           end if;
         end loop;
     end;

     --Commit work to save rollback
     commit;

     -- update WF_LOCAL_USER_ROLES
     begin
      if (p_UpdateWho is not null and p_UpdateWho) then
       forall tabIndex in l_rowIDSrcTAB.FIRST..l_rowIDSrcTAB.LAST save exceptions
        update wf_local_user_roles partition (FND_USR)
        set     ROLE_START_DATE = l_StartSrcTAB(tabIndex),
                ROLE_END_DATE = l_EndSrcTAB(tabIndex),
                USER_START_DATE = l_StartSrcTAB(tabIndex),
                USER_END_DATE = l_EndSrcTAB(tabIndex),
                START_DATE    = l_StartSrcTAB(tabIndex),
                EXPIRATION_DATE  = l_EndSrcTAB(tabIndex),
                EFFECTIVE_START_DATE = nvl(l_StartSrcTAB(tabIndex),
                                           to_date(1,'J')),
                EFFECTIVE_END_DATE = nvl(l_EndSrcTAB(tabIndex),
                                         to_date('9999/01/01', 'YYYY/MM/DD')),
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID
         where  rowid = l_rowIDSrcTAB(tabIndex);
      else  --donot touch the WHO columns. This is default behavior
       forall tabIndex in l_rowIDSrcTAB.FIRST..l_rowIDSrcTAB.LAST save exceptions
        update wf_local_user_roles partition (FND_USR)
        set     ROLE_START_DATE = l_StartSrcTAB(tabIndex),
                ROLE_END_DATE = l_EndSrcTAB(tabIndex),
                USER_START_DATE = l_StartSrcTAB(tabIndex),
                USER_END_DATE = l_EndSrcTAB(tabIndex),
                START_DATE    = l_StartSrcTAB(tabIndex),
                EXPIRATION_DATE  = l_EndSrcTAB(tabIndex),
                EFFECTIVE_START_DATE = nvl(l_StartSrcTAB(tabIndex),
                                           to_date(1,'J')),
                EFFECTIVE_END_DATE = nvl(l_EndSrcTAB(tabIndex),
                                         to_date('9999/01/01', 'YYYY/MM/DD'))
         where  rowid = l_rowIDSrcTAB(tabIndex);
       end if;
      end;

    if (l_rowIDTAB.COUNT < l_maxRows) then --Last batch, no need to refetch
      commit;
      exit self_refer_loop;
    else
      -- reset the ROWID Table before the next set of fetch
      l_rowIDTAB.DELETE;
      commit;
    end if;
  end loop self_refer_loop;
  exception
   when others then
     if (c_userSelfReference%isOpen) then
       close c_userSelfReference;
     end if;

     raise;
  end; --end of self-reference fix

  commit;--commit the self reference records

  -- reset the PL/SQL tables before we fetch the user-role cursor
  l_rowIDTAB.delete;
  l_rowIDSrcTAB.delete;
  l_startSrcTAB.delete;
  l_endSrcTAB.delete;
  l_userOrigSrcTAB.delete;
  l_userOrigIDSrcTAB.delete;

  --Initialize the sumTabIndex counter.
  sumTabIndex := 0;

  --Enable parallel DML
  execute IMMEDIATE 'alter session enable parallel dml';

  --truncate the stage table now
  WF_DDL.TruncateTable('WF_UR_VALIDATE_STG',WF_CORE.Translate('WF_SCHEMA'),
                       FALSE);

  -- <bug 6823723>
  select min(to_number(value))
  into   l_defaultParProc
  from   v$parameter
  where  name in ('parallel_max_servers','cpu_count');

  if ((p_parallel_processes is NULL) or (p_parallel_processes < 1) or
      (mod(p_parallel_processes, 1) <> 0) or (p_parallel_processes > l_defaultParProc)
      ) then
    l_parallelProc := to_char(l_defaultParProc) ;
  else
    l_parallelProc := to_char(p_parallel_processes);
  end if;
  -- </bug 6823723>

  -- populate the stage table
  -- bug 6823723. Now inserting as a dynamic DML to include the number of parallel processes
  l_sql :=
  'INSERT /*+ append parallel(WF_UR_VALIDATE_STG,'|| l_parallelProc ||') */
  INTO WF_UR_VALIDATE_STG (WURA_ID, WUR_ID , ROLE_NAME , USER_NAME ,
  ASSIGNING_ROLE , START_DATE , END_DATE , ROLE_START_DATE, ROLE_END_DATE
  , USER_START_DATE , USER_END_DATE , ROLE_ORIG_SYSTEM ,
  ROLE_ORIG_SYSTEM_ID , USER_ORIG_SYSTEM , USER_ORIG_SYSTEM_ID ,
  ASSIGNING_ROLE_START_DATE , ASSIGNING_ROLE_END_DATE ,
  EFFECTIVE_START_DATE , EFFECTIVE_END_DATE , RELATIONSHIP_ID )
  SELECT /*+ ordered parallel(WURA,'|| l_parallelProc ||') parallel(WR,'|| l_parallelProc ||
          ') parallel (wu,'|| l_parallelProc ||')
             parallel (WAR,'|| l_parallelProc ||') parallel(WUR,'|| l_parallelProc ||') */
         WURA.ROWID, WUR.ROWID, WURA.ROLE_NAME, WURA.USER_NAME,
         WURA.ASSIGNING_ROLE,
         DECODE(WURA.USER_NAME, WURA.ROLE_NAME, WU.START_DATE,
                WURA.START_DATE) START_DATE,
         DECODE(WURA.USER_NAME, WURA.ROLE_NAME, WU.EXPIRATION_DATE,
                WURA.END_DATE) END_DATE,
         WR.START_DATE, WR.EXPIRATION_DATE, WU.START_DATE,
         WU.EXPIRATION_DATE, WR.ORIG_SYSTEM, WR.ORIG_SYSTEM_ID,
         WU.ORIG_SYSTEM, WU.ORIG_SYSTEM_ID, WAR.START_DATE,
         WAR.EXPIRATION_DATE,
         GREATEST(NVL(WURA.START_DATE, TO_DATE(1,''J'')),
                  NVL(WURA.USER_START_DATE, TO_DATE(1,''J'')),
                  NVL(WURA.ROLE_START_DATE, TO_DATE(1,''J'')),
                  NVL(WURA.ASSIGNING_ROLE_START_DATE,
                      TO_DATE(1,''J''))) EFFECTIVE_START_DATE,
         LEAST(NVL(WURA.END_DATE, TO_DATE(''9999/01/01'', ''YYYY/MM/DD'')),
               NVL(WURA.USER_END_DATE, TO_DATE(''9999/01/01'', ''YYYY/MM/DD'')),
               NVL(WURA.ROLE_END_DATE, TO_DATE(''9999/01/01'', ''YYYY/MM/DD'')),
               NVL(WURA.ASSIGNING_ROLE_END_DATE,
                   TO_DATE(''9999/01/01'', ''YYYY/MM/DD''))) EFFECTIVE_END_DATE,
         WURA.RELATIONSHIP_ID
    FROM
         WF_USER_ROLE_ASSIGNMENTS WURA,
         WF_LOCAL_USER_ROLES WUR ,
         WF_LOCAL_ROLES WAR,
         WF_LOCAL_ROLES WU,
         WF_LOCAL_ROLES WR
   WHERE WURA.PARTITION_ID = WAR.PARTITION_ID
     AND WURA.ASSIGNING_ROLE=WAR.NAME
     AND WURA.USER_NAME= WUR.USER_NAME
     AND WURA.ROLE_NAME=WUR.ROLE_NAME
     AND WUR.USER_NAME = WU.NAME
     AND WUR.USER_ORIG_SYSTEM=WU.ORIG_SYSTEM
     AND WUR.USER_ORIG_SYSTEM_ID= WU.ORIG_SYSTEM_ID
     AND WUR.ROLE_NAME = WR.NAME
     AND WUR.ROLE_ORIG_SYSTEM= WR.ORIG_SYSTEM
     AND WUR.ROLE_ORIG_SYSTEM_ID= WR.ORIG_SYSTEM_ID
     AND WUR.PARTITION_ID = WR.PARTITION_ID
     AND WUR.PARTITION_ID <> 1
     AND WAR.PARTITION_ID <> 1
     AND ( ( WUR.EFFECTIVE_START_DATE IS NULL or
             WUR.EFFECTIVE_END_DATE IS NULL or
             WURA.EFFECTIVE_START_DATE IS NULL or
             WURA.EFFECTIVE_END_DATE IS NULL )
      OR ( WURA.EFFECTIVE_START_DATE <> GREATEST(NVL(WURA.START_DATE,
         TO_DATE(1,''J'')), NVL(WURA.USER_START_DATE, TO_DATE(1,''J'')), NVL(
         WURA.ROLE_START_DATE, TO_DATE(1,''J'')), NVL(
         WURA.ASSIGNING_ROLE_START_DATE, TO_DATE(1,''J''))) )
      OR ( WURA.EFFECTIVE_END_DATE <> LEAST(NVL(WURA.END_DATE, TO_DATE(
         ''9999/01/01'', ''YYYY/MM/DD'')), NVL(WURA.USER_END_DATE, TO_DATE(
         ''9999/01/01'', ''YYYY/MM/DD'')) , NVL(WURA.ROLE_END_DATE, TO_DATE(
         ''9999/01/01'', ''YYYY/MM/DD'')), NVL(WURA.ASSIGNING_ROLE_END_DATE,
         TO_DATE(''9999/01/01'', ''YYYY/MM/DD''))))
      OR (WURA.USER_NAME = WURA.ROLE_NAME and
          (nvl(wura.start_date, to_date(1,''J'')) <>
           nvl(wu.start_date, to_date(1,''J'')) or
           nvl(wura.end_date, to_date(''9999/01/01'', ''YYYY/MM/DD'')) <>
           nvl(wu.expiration_date, to_date(''9999/01/01'', ''YYYY/MM/DD''))))
      OR ( ( WUR.ASSIGNMENT_TYPE IS NULL )
      OR WUR.ASSIGNMENT_TYPE NOT IN (''D'', ''I'', ''B'') )
      OR ( WURA.USER_ORIG_SYSTEM IS NULL
      OR WURA.ROLE_ORIG_SYSTEM IS NULL
      OR WURA.USER_ORIG_SYSTEM_ID IS NULL
      OR WURA.ROLE_ORIG_SYSTEM_ID IS NULL )
      OR ( WURA.USER_ORIG_SYSTEM <> WU.ORIG_SYSTEM
      OR WURA.USER_ORIG_SYSTEM_ID <> WU.ORIG_SYSTEM_ID
      OR WURA.ROLE_ORIG_SYSTEM <> WR.ORIG_SYSTEM
      OR WURA.ROLE_ORIG_SYSTEM_ID <> WR.ORIG_SYSTEM_ID )
      OR ( ( WU.START_DATE IS NULL
     AND ( WUR.USER_START_DATE IS NOT NULL
      OR WURA.USER_START_DATE IS NOT NULL ) )
      OR ( WU.START_DATE IS NOT NULL
     AND ( WUR.USER_START_DATE IS NULL
      OR WUR.USER_START_DATE <> WU.START_DATE
      OR WURA.USER_START_DATE IS NULL
      OR WURA.USER_START_DATE <> WU.START_DATE ) )
      OR ( WU.EXPIRATION_DATE IS NULL
     AND ( WUR.USER_END_DATE IS NOT NULL
      OR WURA.USER_END_DATE IS NOT NULL ) )
      OR ( WU.EXPIRATION_DATE IS NOT NULL
     AND ( WUR.USER_END_DATE IS NULL
      OR WUR.USER_END_DATE <> WU.EXPIRATION_DATE
      OR WURA.USER_END_DATE IS NULL
      OR WURA.USER_END_DATE <> WU.EXPIRATION_DATE ) ) )
      OR ( ( WR.START_DATE IS NULL
     AND ( WUR.ROLE_START_DATE IS NOT NULL
      OR WURA.ROLE_START_DATE IS NOT NULL ) )
      OR ( WR.START_DATE IS NOT NULL
     AND ( WUR.ROLE_START_DATE IS NULL
      OR WUR.ROLE_START_DATE <> WR.START_DATE
      OR WURA.ROLE_START_DATE IS NULL
      OR WURA.ROLE_START_DATE <> WR.START_DATE ) )
      OR ( WR.EXPIRATION_DATE IS NULL
     AND ( WUR.ROLE_END_DATE IS NOT NULL
      OR WURA.ROLE_END_DATE IS NOT NULL ) )
      OR ( WR.EXPIRATION_DATE IS NOT NULL
     AND ( WUR.ROLE_END_DATE IS NULL
      OR WUR.ROLE_END_DATE <> WR.EXPIRATION_DATE
      OR WURA.ROLE_END_DATE IS NULL
      OR WURA.ROLE_END_DATE <> WR.EXPIRATION_DATE ) ) )
      OR ( ( WAR.START_DATE IS NULL
     AND WURA.ASSIGNING_ROLE_START_DATE IS NOT NULL )
      OR ( WAR.START_DATE IS NOT NULL
     AND ( WURA.ASSIGNING_ROLE_START_DATE IS NULL
      OR WURA.ASSIGNING_ROLE_START_DATE <> WAR.START_DATE ) )
      OR ( WAR.EXPIRATION_DATE IS NULL
     AND WURA.ASSIGNING_ROLE_END_DATE IS NOT NULL )
      OR ( WAR.EXPIRATION_DATE IS NOT NULL
     AND ( WURA.ASSIGNING_ROLE_END_DATE IS NULL
      OR WURA.ASSIGNING_ROLE_END_DATE <> WAR.EXPIRATION_DATE ) ) ) )' ;

    execute IMMEDIATE l_sql;
    commit;
    execute IMMEDIATE 'alter session disable parallel dml';

  -- ALSOSA. Current progress
  OPEN c_UserRoleAssignments(p_username, p_rolename);

  <<outer_loop>>
  loop
    fetch c_UserRoleAssignments
    bulk collect into l_stgIDTAB, l_rowIDTAB, l_rowIDSrcTAB, l_roleSrcTAB,
                        l_userSrcTAB, l_assigningRoleSrcTAB, l_startSrcTAB,
                        l_endSrcTAB, l_roleStartSrcTAB, l_roleEndSrcTAB,
                        l_userStartSrcTAB, l_userEndSrcTAB, l_roleOrigSrcTAB,
                        l_roleOrigIDSrcTAB,l_userOrigSrcTAB, l_userOrigIDSrcTAB,
                        l_asgStartSrcTAB, l_asgEndSrcTAB, l_effStartSrcTAB,
                        l_effEndSrcTAB, l_relIDTAB
                        limit l_maxRows;


    --We now have pl/sql tables in memory that we can update with the new
    --values. So we loop through them and begin the processing.
    if (l_rowIDTAB.COUNT < 1) then
      exit outer_loop;
    end if;

    --We now have a complete series of pl/sql tables with
    --all of the start/end dates and calculated effective start/end dates
    --We can then issue the bulk  update..
    if (p_UpdateWho is not null and p_UpdateWho) then
     forall tabIndex in l_rowIDTAB.FIRST..l_rowIDTAB.LAST
      update  WF_USER_ROLE_ASSIGNMENTS
      set     ROLE_START_DATE = l_roleStartSrcTAB(tabIndex),
              ROLE_END_DATE = l_roleEndSrcTAB(tabIndex),
              USER_START_DATE = l_userStartSrcTAB(tabIndex),
              USER_END_DATE = l_userEndSrcTAB(tabIndex),
              START_DATE = l_startSrcTAB(tabIndex),
              END_DATE = l_endSRcTAB(tabIndex),
              EFFECTIVE_START_DATE = l_effStartSrcTAB(tabIndex),
              EFFECTIVE_END_DATE = l_effEndSrcTAB(tabIndex),
              ASSIGNING_ROLE_START_DATE = l_asgStartSrcTAB(tabIndex),
              ASSIGNING_ROLE_END_DATE = l_asgEndSrcTAB(tabIndex),
              USER_ORIG_SYSTEM=l_userOrigSrcTAB(tabIndex),
              ROLE_ORIG_SYSTEM=l_roleOrigSrcTAB(tabIndex),
              USER_ORIG_SYSTEM_ID=l_userOrigIDSrcTAB(tabIndex),
              ROLE_ORIG_SYSTEM_ID=l_roleOrigIDSrcTAB(tabIndex),
              LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
              LAST_UPDATE_DATE = SYSDATE,
              LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID
      where   rowid = l_rowIDTAB(tabIndex);
   else --Donot touch WHO columns. This is default behavior
    forall tabIndex in l_rowIDTAB.FIRST..l_rowIDTAB.LAST
      update  WF_USER_ROLE_ASSIGNMENTS
      set     ROLE_START_DATE = l_roleStartSrcTAB(tabIndex),
              ROLE_END_DATE = l_roleEndSrcTAB(tabIndex),
              USER_START_DATE = l_userStartSrcTAB(tabIndex),
              USER_END_DATE = l_userEndSrcTAB(tabIndex),
              START_DATE = l_startSrcTAB(tabIndex),
              END_DATE = l_endSRcTAB(tabIndex),
              EFFECTIVE_START_DATE = l_effStartSrcTAB(tabIndex),
              EFFECTIVE_END_DATE = l_effEndSrcTAB(tabIndex),
              ASSIGNING_ROLE_START_DATE = l_asgStartSrcTAB(tabIndex),
              ASSIGNING_ROLE_END_DATE = l_asgEndSrcTAB(tabIndex),
              USER_ORIG_SYSTEM=l_userOrigSrcTAB(tabIndex),
              ROLE_ORIG_SYSTEM=l_roleOrigSrcTAB(tabIndex),
              USER_ORIG_SYSTEM_ID=l_userOrigIDSrcTAB(tabIndex),
              ROLE_ORIG_SYSTEM_ID=l_roleOrigIDSrcTAB(tabIndex)
      where   rowid = l_rowIDTAB(tabIndex);
   end if;

    --We will reloop through the assignment pl/sql tables and populate the
    --summary pl/sql tables.
    <<summarize_assignments>>
    for tabIndex in l_rowIDTAB.FIRST..l_rowIDTAB.LAST loop
      --we need to insert into summary table if this is the first
      --record to be inserted or, we have a new user/role combination
      --in the assignment table, which hasnt yet been inserted into the
      --summary table
      if ((l_roleDestTab.COUNT < 1) or
          (l_rowIDSrcTAB(tabIndex) <> l_rowIDDestTAB(sumTabIndex))) then
        -- before inserting, check whether the summarytable has
        -- grown too large
        if sumTabIndex >= l_maxRows then
          --limit reached for summary table, so perform
          --the bulk update and clear off the table.
          --We need to perform the bulk update here in addition to
          --bulk update after exit from the loop, so that clearing
          --the summary table will not lose user/role effective date
          --information when duplicate user/role
          --combinations are spread across multiple groups
          if (p_UpdateWho is not null and p_UpdateWho) then
            forall destTabIndex in l_roleDestTab.FIRST..l_roleDestTab.LAST
              UPDATE WF_LOCAL_USER_ROLES wur
              SET    ROLE_START_DATE = l_roleStartDestTAB(destTabIndex),
                   ROLE_END_DATE   = l_roleEndDestTAB(destTabIndex),
                   USER_START_DATE = l_userStartDestTAB(destTabIndex),
                   USER_END_DATE = l_userEndDestTAB(destTabIndex),
                   START_DATE = l_startDestTAB(destTabIndex),
                   EXPIRATION_DATE = l_endDestTAB(destTabIndex),
                   EFFECTIVE_START_DATE = l_effStartDestTAB(destTabIndex),
                   EFFECTIVE_END_DATE = l_effEndDestTAB(destTabIndex),
                   ASSIGNMENT_TYPE = l_assignTAB(destTabIndex),
                   LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                   LAST_UPDATE_LOGIN = FND_GLOBAL.Login_Id,
                   LAST_UPDATE_DATE  = SYSDATE
              WHERE rowid = l_rowIDDestTAB(destTabIndex);
          else --Do not touch WHO columns. This is default behavior
           forall destTabIndex in l_roleDestTab.FIRST..l_roleDestTab.LAST
            UPDATE WF_LOCAL_USER_ROLES wur
            SET    ROLE_START_DATE = l_roleStartDestTAB(destTabIndex),
                   ROLE_END_DATE   = l_roleEndDestTAB(destTabIndex),
                   USER_START_DATE = l_userStartDestTAB(destTabIndex),
                   USER_END_DATE = l_userEndDestTAB(destTabIndex),
                   START_DATE = l_startDestTAB(destTabIndex),
                   EXPIRATION_DATE = l_endDestTAB(destTabIndex),
                   EFFECTIVE_START_DATE = l_effStartDestTAB(destTabIndex),
                   EFFECTIVE_END_DATE = l_effEndDestTAB(destTabIndex),
                   ASSIGNMENT_TYPE = l_assignTAB(destTabIndex)
             WHERE rowid = l_rowIDDestTAB(destTabIndex);
          end if;
          l_roleStartDestTAB.DELETE;
          l_roleEndDestTAB.DELETE;
          l_userStartDestTAB.DELETE;
          l_userEndDestTAB.DELETE;
          l_effStartDestTAB.DELETE;
          l_effEndDestTAB.DELETE;
          l_assignTAB.DELETE;
          l_startDestTAB.DELETE;
          l_endDestTAB.DELETE;
          l_roleDestTAB.DELETE;
          l_userDestTAB.DELETE;
          l_userOrigDestTAB.DELETE;
          l_userOrigIDDestTAB.DELETE;
          l_roleOrigDestTAB.DELETE;
          l_roleOrigIDDestTAB.DELETE;
          l_rowIDDestTAB.DELETE;

          sumTabIndex := 0;
        end if;	--sumTabIndex >= l_maxRows

        --now perform the insert
        sumTabIndex := sumTabIndex + 1;
        l_RoleDestTAB(sumTabIndex)       := l_roleSrcTAB(tabIndex);
        l_UserDestTAB(sumTabIndex)       := l_userSRcTAB(tabIndex);
        l_userOrigDestTAB(sumTabIndex)   := l_userOrigSrcTAB(tabIndex);
        l_userOrigIDDestTAB(sumTabIndex) := l_userOrigIDSrcTAB(tabIndex);
        l_roleOrigDestTAB(sumTabIndex)   := l_roleOrigSrcTAB(tabIndex);
        l_roleOrigIDDestTAB(sumTabIndex) := l_roleOrigIDSrcTAB(tabIndex);
        l_roleStartDestTAB(sumTabIndex)  := l_roleStartSrcTAB(tabIndex);
        l_roleEndDestTAB(sumTabIndex)    := l_roleEndSrcTAB(tabIndex);
        l_userStartDestTAB(sumTabIndex)  := l_userStartSrcTAB(tabIndex);
        l_userEndDestTAB(sumTabIndex)    := l_userEndSrcTAB(tabIndex);
        l_effStartDestTAB(sumTabIndex)   := l_effStartSrcTAB(tabIndex);
        l_effEndDestTAB(sumTabIndex)     := l_effEndSrcTAB(tabIndex);
        l_rowIDDestTAB(sumTabIndex)      := l_rowIDSrcTAB(TabIndex);

        --Check to see if the assignment is active.
        if (l_effEndSrcTAB(tabIndex) > trunc(SYSDATE) and
            l_effStartSrcTab(tabIndex) <= trunc(SYSDATE)) then
          l_activeAssigned := TRUE;
        else
          l_activeAssigned := FALSE;
        end if;

        --Determine the initial assignment_type.
        if  l_relIDTAB(tabIndex) = -1 then
          l_AssignTAB(sumTabIndex):='D';
          l_startDestTAB(sumTabIndex)    :=l_startSrcTAB(tabIndex);
          l_endDestTAB(sumTabIndex)      :=l_endSrcTAB(tabIndex);
        else
          l_AssignTAB(sumTabIndex):='I';
          l_startDestTAB(sumTabIndex)    :=null;
          l_endDestTAB(sumTabIndex)      :=null;
        end if;
      else  --Record is already in the summary table so update effective dates
      if l_effStartSrcTAB(tabIndex) < l_effStartDestTAB(sumTabIndex) then
        l_effStartDestTAB(sumTabIndex) := l_effStartSrcTAB(tabIndex);
      end if;

      if l_effEndSrcTAB(tabIndex) > l_effEndDestTAB(sumTabIndex) then
        l_effEndDestTAB(sumTabIndex) := l_effEndSrcTAB(tabIndex);
      end if;

      -- if this is a direct assignment then we need to set the start
      -- and end dates
      if l_relIDTAB(tabIndex) = -1 then
         l_startDestTAB(sumTabIndex)    :=l_startSrcTAB(tabIndex);
         l_endDestTAB(sumTabIndex)      :=l_endSrcTAB(tabIndex);
      end if;

      --if the assignment type in summary table is Direct and
      --we encountered an inherited assignment in the Assignment table
      --or if the assignment type in summary table is inherited and we
      --encountered a direct assignment in the Assignment table
      --update the assignment_Type to Both

      if (l_effEndSrcTAB(tabIndex) > trunc(SYSDATE) and
          l_effStartSrcTAB(tabIndex) <= trunc(SYSDATE)) then
        --This is an active assignment so we need to determine if an
        --active assignment was already used in calculating assignment_type
        if (l_activeAssigned) then
          --An active assignment was already used in the calculation so this
          --assignment will be used to determine if and existing 'D' or 'I'
          --should be changed into a 'B'
          if (((l_AssignTAB(sumTabIndex) = 'D') and
               (l_relIDTAB(tabIndex) <> -1)) or
               ((l_AssignTAB(sumTabIndex) = 'I') and
               (l_relIDTAB(tabIndex) = -1))) then

            l_AssignTAB(sumTabIndex) := 'B';
          end if;
        else
          --This is the first active assignment, so set the initial value
          --Determine the initial assignment_type.
          if  l_relIDTAB(tabIndex) = -1 then
            l_AssignTAB(sumTabIndex):='D';
            l_startDestTAB(sumTabIndex)    :=l_startSrcTAB(tabIndex);
            l_endDestTAB(sumTabIndex)      :=l_endSrcTAB(tabIndex);
          else
            l_AssignTAB(sumTabIndex):='I';
            l_startDestTAB(sumTabIndex)    :=null;
            l_endDestTAB(sumTabIndex)      :=null;
          end if;

          --Now set l_activeAssigned to TRUE.
          l_activeAssigned := TRUE;
        end if;
      else
        --This is an expired assignment, so we will set the assignment_type
        --only if we have not already initialized/modified with an
        --active assignment.
        if NOT (l_activeAssigned) then
          if  l_relIDTAB(tabIndex) = -1 then
            l_AssignTAB(sumTabIndex):='D';
            l_startDestTAB(sumTabIndex)    :=l_startSrcTAB(tabIndex);
            l_endDestTAB(sumTabIndex)      :=l_endSrcTAB(tabIndex);
          else
            l_AssignTAB(sumTabIndex):='I';
            l_startDestTAB(sumTabIndex)    :=null;
            l_endDestTAB(sumTabIndex)      :=null;
          end if;
        end if;
      end if;
    end if;
  end loop summarize_assignments;

    --Check to see if we have the last batch and do not need to re-fetch
    if (l_rowIDTAB.COUNT < l_maxRows) then
      commit;
      exit outer_loop;
    else
      -- reset the ROWID Table before the next set of fetch
      l_rowIDTAB.DELETE;
      commit;
    end if;
  end loop outer_loop;

  --when we reach here, we need to bulk update the leftover records,
  --if any, in the summary table.

  if (l_roleDestTAB.COUNT) > 0 then
   if (p_UpdateWho is not null and p_UpdateWho) then
    forall destTabIndex in l_roleDestTab.FIRST..l_roleDestTab.LAST
      UPDATE WF_LOCAL_USER_ROLES wur
      SET    ROLE_START_DATE = l_roleStartDestTAB(destTabIndex),
             ROLE_END_DATE   = l_roleEndDestTAB(destTabIndex),
             USER_START_DATE = l_userStartDestTAB(destTabIndex),
             USER_END_DATE = l_userEndDestTAB(destTabIndex),
             EFFECTIVE_START_DATE = l_effStartDestTAB(destTabIndex),
             EFFECTIVE_END_DATE = l_effEndDestTAB(destTabIndex),
             START_DATE = l_startDestTAB(destTabIndex),
             EXPIRATION_DATE = l_endDestTAB(destTabIndex),
             ASSIGNMENT_TYPE = l_assignTAB(destTabIndex),
             LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
             LAST_UPDATE_LOGIN = FND_GLOBAL.Login_Id,
             LAST_UPDATE_DATE  = SYSDATE
       WHERE rowid = l_rowIDDestTAB(destTabIndex);
   else --Do not touch WHO columns. This is default behavior.
    forall destTabIndex in l_roleDestTab.FIRST..l_roleDestTab.LAST
      UPDATE WF_LOCAL_USER_ROLES wur
      SET    ROLE_START_DATE = l_roleStartDestTAB(destTabIndex),
             ROLE_END_DATE   = l_roleEndDestTAB(destTabIndex),
             USER_START_DATE = l_userStartDestTAB(destTabIndex),
             USER_END_DATE = l_userEndDestTAB(destTabIndex),
             EFFECTIVE_START_DATE = l_effStartDestTAB(destTabIndex),
             EFFECTIVE_END_DATE = l_effEndDestTAB(destTabIndex),
             START_DATE = l_startDestTAB(destTabIndex),
             EXPIRATION_DATE = l_endDestTAB(destTabIndex),
             ASSIGNMENT_TYPE = l_assignTAB(destTabIndex)
       WHERE rowid = l_rowIDDestTAB(destTabIndex);
   end if;
  end if;

  commit; --Commit final work.

  --close the cursor now
   if (c_userRoleAssignments%ISOPEN) then
     close c_userRoleAssignments;
   end if;

  -- Bug 9184359
  FixWURAEffectiveDates(l_maxRows , p_username, p_rolename);

  -- Bug 8423138
  FixLUREffectiveDates(l_maxRows, p_username, p_rolename);

  --release lock
  if (dbms_lock.release(l_lockhandle) <> 0) then
   wf_core.raise('WF_LOCK_FAIL');
  end if;

exception
  when others then
    result := dbms_lock.release(l_lockhandle);
    if (c_userRoleAssignments%ISOPEN) then
      close c_userRoleAssignments;
    end if;

    raise;
end;

  /*
  ** GetUsernameChangeCounts
  **   Described in package specification.
  */
  function GetUsernameChangeCounts(p_name VARCHAR2) RETURN wfcount_tab pipelined is
    l_wfcount_tab wfcount_type;
    l_roleInfoTAB WF_DIRECTORY.wf_local_roles_tbl_type;
    l_partitionID WF_DIRECTORY_PARTITIONS.PARTITION_ID%TYPE;
    l_partitionName WF_DIRECTORY_PARTITIONS.ORIG_SYSTEM%TYPE;
    l_pvalue varchar2(10) := FND_PROFILE.value('WF_MAINT_COMPLETED_ITEMS');
  begin
    -- First etermine if the username actually exists
    WF_DIRECTORY.GetRoleInfo2(p_name, l_roleInfoTAB);
    if l_roleInfoTAB(1).DISPLAY_NAME is null OR
       l_roleInfoTAB(1).ORIG_SYSTEM NOT in ('PER','FND_USR') then
      l_wfcount_tab := null;
      return;
    end if;
    l_wfcount_tab.USER_NAME:=p_name;

    -- Determine the entries in FND_GRANTS associated to this role.
    if (l_pvalue is null or l_pvalue = 'Y') then
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   FND_GRANTS fg
      where  fg.GRANTEE_TYPE='USER'
      and    fg.GRANTEE_ORIG_SYSTEM in ('FND_USR', 'PER')
      and    fg.PROGRAM_NAME = 'WORKFLOW_UI'
      and    fg.PARAMETER1=p_name;
    else
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   FND_GRANTS fg
      where  fg.GRANTEE_TYPE='USER'
      and    fg.GRANTEE_ORIG_SYSTEM in ('FND_USR', 'PER')
      and    fg.PROGRAM_NAME = 'WORKFLOW_UI'
      and    fg.PARAMETER1=p_name
      and    fg.START_DATE<=SYSDATE
      and    (fg.END_DATE is null or fg.END_DATE>=SYSDATE);
    end if;
    l_wfcount_tab.TABLE_NAME :='FND_GRANTS';
    pipe ROW (l_wfcount_tab);

    -- Determine the workflow processes owned by this role. Can be any role.
    if (l_pvalue is null or l_pvalue = 'Y') then
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_ITEMS
      where  OWNER_ROLE = p_name;
    else
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_ITEMS
      where  OWNER_ROLE = p_name
      and    END_DATE is null;
    end if;
    l_wfcount_tab.TABLE_NAME :='WF_ITEMS';
    pipe ROW (l_wfcount_tab);

    -- Determine rows to change in WF_ITEM_ACTIVITY_STATUSES
    if (l_pvalue is null or l_pvalue = 'Y') then
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_ITEM_ACTIVITY_STATUSES WIAS
      where  ASSIGNED_USER =  p_name;
    else
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_ITEM_ACTIVITY_STATUSES WIAS
      where  exists (select '1'
                     from WF_ITEMS WI
                     where  WI.ITEM_TYPE=WIAS.ITEM_TYPE and
                            WI.ITEM_KEY=WIAS.ITEM_KEY and
                            WI.END_DATE is null) and
             ASSIGNED_USER =  p_name;
    end if;
    l_wfcount_tab.TABLE_NAME :='WF_ITEM_ACTIVITY_STATUSES';
    pipe ROW (l_wfcount_tab);

    -- Determine rows to change in WF_ITEM_ACTIVITY_STATUSES_H
    if (l_pvalue is null or l_pvalue = 'Y') then
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_ITEM_ACTIVITY_STATUSES_H WIASH
      where  ASSIGNED_USER =  p_name;
    else
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_ITEM_ACTIVITY_STATUSES_H WIASH
      where  exists (select '1'
                     from WF_ITEMS WI
                     where  WI.ITEM_TYPE=WIASH.ITEM_TYPE and
                            WI.ITEM_KEY=WIASH.ITEM_KEY and
                            WI.END_DATE is null) and
             ASSIGNED_USER =  p_name;
    end if;
    l_wfcount_tab.TABLE_NAME :='WF_ITEM_ACTIVITY_STATUSES_H';
    pipe ROW (l_wfcount_tab);

    -- Determine rows to change in WF_NOTIFICATIONS
    if (l_pvalue is null or l_pvalue = 'Y') then
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_NOTIFICATIONS WN
      where  RECIPIENT_ROLE        = p_name
              or ORIGINAL_RECIPIENT = p_name
              or more_info_role     = p_name
              or from_role          = p_name
              or responder          = p_name;
    else
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_NOTIFICATIONS WN
      where  (exists (select '1'
              from   WF_ITEM_ACTIVITY_STATUSES WIAS, WF_ITEMS WI
              where  WIAS.NOTIFICATION_ID = WN.NOTIFICATION_ID
              and    WIAS.ITEM_TYPE = WI.ITEM_TYPE
              and    WIAS.ITEM_KEY = WI.ITEM_KEY
              and    WI.END_DATE IS NULL)
        or exists (select '1'
              from   WF_ITEM_ACTIVITY_STATUSES_H WIASH, WF_ITEMS WI
              where  WIASH.NOTIFICATION_ID = WN.NOTIFICATION_ID
              and    WIASH.ITEM_TYPE = WI.ITEM_TYPE
              and    WIASH.ITEM_KEY = WI.ITEM_KEY
              and    WI.END_DATE IS NULL))
      and    (RECIPIENT_ROLE        = p_name
              or ORIGINAL_RECIPIENT = p_name
              or more_info_role     = p_name
              or from_role          = p_name
              or responder          = p_name);
    end if;
    l_wfcount_tab.TABLE_NAME := 'WF_NOTIFICATIONS';
    pipe ROW (l_wfcount_tab);

    -- Determine rows to change in WF_PROCESS_ACTIVITIES
    select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
    from   WF_PROCESS_ACTIVITIES
    where  PERFORM_ROLE = p_name;
    l_wfcount_tab.TABLE_NAME := 'WF_PROCESS_ACTIVITIES';
    pipe ROW (l_wfcount_tab);

    -- Determine rows to change in WF_ROUTING_RULES. Applies to users only
    if (l_pvalue is null or l_pvalue = 'Y') then
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_ROUTING_RULES
      where  ROLE = p_name or ACTION_ARGUMENT = p_name;
    else
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_ROUTING_RULES
      where  (ROLE = p_name or ACTION_ARGUMENT = p_name)
        and  BEGIN_DATE<=SYSDATE
        and  (END_DATE is null or END_DATE>=SYSDATE);
    end if;
    l_wfcount_tab.TABLE_NAME := 'WF_ROUTING_RULES';
    pipe ROW (l_wfcount_tab);

    -- Determine rows to change in WF_ROUTING_RULE_ATTRIBUTES. Applies to users only
    if (l_pvalue is null or l_pvalue = 'Y') then
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_ROUTING_RULE_ATTRIBUTES ra, WF_ROUTING_RULES wrr
      where  wrr.RULE_ID=ra.RULE_ID
      and    ra.TEXT_VALUE = p_name
      and    exists
       (select '1'
        from   WF_MESSAGE_ATTRIBUTES ma
        where  ma.NAME=ra.NAME
        and    ma.TYPE='ROLE');
    else
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_ROUTING_RULE_ATTRIBUTES ra, WF_ROUTING_RULES wrr
      where  wrr.BEGIN_DATE<=SYSDATE
      and    (wrr.END_DATE is null or wrr.END_DATE>=SYSDATE)
      and    wrr.RULE_ID=ra.RULE_ID
      and    ra.TEXT_VALUE = p_name
      and    exists
       (select '1'
        from   WF_MESSAGE_ATTRIBUTES ma
        where  ma.NAME=ra.NAME
        and    ma.TYPE='ROLE');
    end if;
    l_wfcount_tab.TABLE_NAME := 'WF_ROUTING_RULE_ATTRIBUTES';
    pipe ROW (l_wfcount_tab);

    -- Determine rows to change in WF_COMMENTS Applies to users only
    if (l_pvalue is null or l_pvalue = 'Y') then
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_COMMENTS WC
      where  WC.FROM_ROLE = p_name
      or     WC.TO_ROLE = p_name
      or     WC.PROXY_ROLE = p_name;
    else
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_COMMENTS WC
      where (WC.FROM_ROLE = p_name
      or     WC.TO_ROLE = p_name
      or     WC.PROXY_ROLE = p_name)
      and (exists (select '1'
            from   WF_ITEM_ACTIVITY_STATUSES WIAS, WF_ITEMS WI
            where  WIAS.NOTIFICATION_ID = WC.NOTIFICATION_ID
            and    WIAS.ITEM_TYPE = WI.ITEM_TYPE
            and    WIAS.ITEM_KEY = WI.ITEM_KEY
            and    WI.END_DATE IS NULL)
      or exists (select '1'
            from   WF_ITEM_ACTIVITY_STATUSES_H WIASH, WF_ITEMS WI
            where  WIASH.NOTIFICATION_ID = WC.NOTIFICATION_ID
            and    WIASH.ITEM_TYPE = WI.ITEM_TYPE
            and    WIASH.ITEM_KEY = WI.ITEM_KEY
            and    WI.END_DATE IS NULL));
    end if;
    l_wfcount_tab.TABLE_NAME := 'WF_COMMENTS';
    pipe ROW (l_wfcount_tab);

    -- Determine rows to change in WF_ITEM_ATTRIBUTE_VALUES. Can be any role.
    if (l_pvalue is null or l_pvalue = 'Y') then
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_ITEM_ATTRIBUTE_VALUES WIAV, WF_ITEM_ATTRIBUTES WIA
      where  WIA.type = 'ROLE'
      and    WIA.ITEM_TYPE = WIAV.ITEM_TYPE
      and    WIA.NAME = WIAV.NAME
      and    WIAV.TEXT_VALUE = p_name;
    else
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_ITEM_ATTRIBUTE_VALUES WIAV, WF_ITEM_ATTRIBUTES WIA
      where  WIA.type = 'ROLE'
      and    WIA.ITEM_TYPE = WIAV.ITEM_TYPE
      and    WIA.NAME = WIAV.NAME
      and    WIAV.TEXT_VALUE = p_name
      and    exists (select '1'
                     from   WF_ITEMS WI
                     where  WI.ITEM_TYPE=WIAV.ITEM_TYPE
                       and  WI.ITEM_KEY=WIAV.ITEM_KEY
                       and  WI.END_DATE is null);
    end if;
    l_wfcount_tab.TABLE_NAME := 'WF_ITEM_ATTRIBUTE_VALUES';
    pipe ROW (l_wfcount_tab);

    -- Now check what happens with the WFDS tables:
    WF_DIRECTORY.assignPartition(l_roleInfoTAB(1).ORIG_SYSTEM, l_partitionID, l_partitionName);
    -- Determine rows to change in WF_LOCAL_ROLES. Can be any role
    if (l_pvalue is null or l_pvalue = 'Y') then
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from    WF_LOCAL_ROLES PARTITION(FND_USR)
      WHERE   NAME = p_name
      AND     PARTITION_ID = l_partitionID
      AND     ORIG_SYSTEM = l_roleInfoTAB(1).ORIG_SYSTEM
      AND     ORIG_SYSTEM_ID = l_roleInfoTAB(1).ORIG_SYSTEM_ID;
    else
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from    WF_LOCAL_ROLES PARTITION(FND_USR)
      WHERE   NAME = p_name
      AND     PARTITION_ID = l_partitionID
      AND     ORIG_SYSTEM = l_roleInfoTAB(1).ORIG_SYSTEM
      AND     ORIG_SYSTEM_ID = l_roleInfoTAB(1).ORIG_SYSTEM_ID
      AND     START_DATE<=SYSDATE
      AND     (EXPIRATION_DATE is null or EXPIRATION_DATE>=SYSDATE);
    end if;
    l_wfcount_tab.TABLE_NAME := 'WF_LOCAL_ROLES';
    pipe ROW (l_wfcount_tab);

    -- Determine rows to change in WF_LOCAL_USER_ROLES. Can be any role
    if (l_pvalue is null or l_pvalue = 'Y') then
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_LOCAL_USER_ROLES
      WHERE  USER_NAME = p_name
      AND    USER_ORIG_SYSTEM = l_roleInfoTAB(1).ORIG_SYSTEM
      AND    USER_ORIG_SYSTEM_ID = l_roleInfoTAB(1).ORIG_SYSTEM_ID;
    else
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_LOCAL_USER_ROLES
      WHERE  USER_NAME = p_name
      AND    USER_ORIG_SYSTEM = l_roleInfoTAB(1).ORIG_SYSTEM
      AND    USER_ORIG_SYSTEM_ID = l_roleInfoTAB(1).ORIG_SYSTEM_ID
      AND    EFFECTIVE_START_DATE<=SYSDATE
      AND    (EFFECTIVE_END_DATE is null or EFFECTIVE_END_DATE>=SYSDATE);
    end if;
    l_wfcount_tab.TABLE_NAME := 'WF_LOCAL_USER_ROLES';
    pipe ROW (l_wfcount_tab);

    -- Determine rows to change in WF_USER_ROLE_ASSIGNMENTS. Can be any role
    if (l_pvalue is null or l_pvalue = 'Y') then
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_USER_ROLE_ASSIGNMENTS
      WHERE  USER_NAME = p_name
      AND    USER_ORIG_SYSTEM = l_roleInfoTAB(1).ORIG_SYSTEM
      AND    USER_ORIG_SYSTEM_ID = l_roleInfoTAB(1).ORIG_SYSTEM_ID;
    else
      select nvl(count(1), 0) into l_wfcount_tab.REC_CNT
      from   WF_USER_ROLE_ASSIGNMENTS
      WHERE  USER_NAME = p_name
      AND    USER_ORIG_SYSTEM = l_roleInfoTAB(1).ORIG_SYSTEM
      AND    USER_ORIG_SYSTEM_ID = l_roleInfoTAB(1).ORIG_SYSTEM_ID
      AND    EFFECTIVE_START_DATE<=SYSDATE
      AND    (EFFECTIVE_END_DATE is null or EFFECTIVE_END_DATE>=SYSDATE);
    end if;
    l_wfcount_tab.TABLE_NAME := 'WF_USER_ROLE_ASSIGNMENTS';
    pipe ROW (l_wfcount_tab);
  exception
    when others then
      return;
  end GetUsernameChangeCounts;

end WF_MAINTENANCE;

/
