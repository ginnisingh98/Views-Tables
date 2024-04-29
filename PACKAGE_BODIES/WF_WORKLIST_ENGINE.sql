--------------------------------------------------------
--  DDL for Package Body WF_WORKLIST_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_WORKLIST_ENGINE" as
/* $Header: wfwrkb.pls 115.25 2004/01/18 01:19:56 dlam ship $ */

/*
 Modeled the following views and selects

create or replace force view WF_WORKLIST_V
(
ROW_ID,
NID,
PRIORITY,
MESSAGE_TYPE,
RECIPIENT_ROLE,
LOCKED_BY,
SUBJECT,
BEGIN_DATE,
DUE_DATE,
END_DATE,
DISPLAY_STATUS,
STATUS,
ORIGINAL_RECIPIENT,
ITEM_TYPE,
MESSAGE_NAME
) as select
  WN.ROWID,
  WN.NOTIFICATION_ID,
  WN.PRIORITY,
  WIT.DISPLAY_NAME,
  WN.RECIPIENT_ROLE,
  WN.LOCKED_BY,
  Wf_Notification.GetSubject(notification_id),
  WN.BEGIN_DATE,
  WN.DUE_DATE,
  WN.END_DATE,
  WL.MEANING,
  WN.STATUS,
  WN.ORIGINAL_RECIPIENT,
  WN.MESSAGE_TYPE,
  WN.MESSAGE_NAME
 from WF_NOTIFICATIONS WN, WF_ITEM_TYPES_VL WIT, WF_LOOKUPS WL
 where WN.MESSAGE_TYPE = WIT.NAME
  and WL.LOOKUP_TYPE = 'WF_NOTIFICATION_STATUS'
  and WN.STATUS = WL.LOOKUP_CODE;

--
-- Must use outer joins in the following two situations in order
-- to get everything from the listed item type.
-- Even if an attribute did not have any value or does not exist,
-- users still want to see the row.
--
-- for RESPOND Lookup
select MA1.FORMAT
 from  WF_NOTIFICATIONS WN, WF_MESSAGE_ATTRIBUTES MA1
 where WN.MESSAGE_TYPE in ('WFDEMO')
 and   WN.MESSAGE_TYPE = MA1.MESSAGE_TYPE (+)
 and   WN.MESSAGE_NAME = MA1.MESSAGE_NAME (+)
 and   MA1.NAME (+) = 'RESULT';

-- for others attribute
select NA1.TEXT_VALUE
 from  WF_NOTIFICATIONS WN, WF_NOTIFICATION_ATTRIBUTES NA1
 where WN.MESSAGE_TYPE in ('WFDEMO')
 and   WN.NOTIFICATION_ID = NA1.NOTIFICATION_ID (+)
 and   NA1.NAME (+) = 'DOC_OWNER_ROLE';
*/

--
-- abandoned the intelligent join of tables and views
-- just use the wf_worklist_v instead
--

--
-- GetRoleClause3 (Internal Public)
--   For use only by "Advanced Worklist" in Self Service Framework.
--   Based on GetRoleClause and GetRoleClause2
--   Returns the expanded roles list separated by commas.
--
function GetRoleClause3(
name   in varchar2
) return varchar2
as
  uorig_system varchar2(30);   -- User orig_system for indexes
  uorig_system_id pls_integer; -- User orig_system_id for indexes
  tmproles   varchar2(6000);   -- temp variables to stored the expanded role

  cursor rolecur(osys varchar2, osysid number, uname varchar2) is
    select ROLE_NAME
    from   WF_USER_ROLES
    where  USER_ORIG_SYSTEM    = osys
    and    USER_ORIG_SYSTEM_ID = osysid
    and    USER_NAME           = uname;
begin
  -- Copy from WFA_HTML.Worklist
  -- Fetch user orig_system_ids for indexes
  Wf_Directory.GetRoleOrigSysInfo(name, uorig_system, uorig_system_id);

  if (uorig_system is null) then
      wf_core.token('ROLE', name);
      wf_core.raise('WFNTF_ROLE');
  end if;

  begin
    for rolr in rolecur(uorig_system, uorig_system_id, name) loop
      if (tmproles is null) then
        tmproles := rolr.ROLE_NAME;
      else
        tmproles := tmproles || ',' || rolr.ROLE_NAME;
      end if;
    end loop;
  exception
    when VALUE_ERROR then
      tmproles := null;
  end;
  return tmproles;

exception
  when OTHERS then
    Wf_Core.Context('Wf_WorkList_Engine', 'GetRoleClause3', name);

    raise;
end GetRoleClause3;

--
-- List
--   Populate a plsql table with query values.
-- IN
--   startrow   - the Nth row that you want to start your query.
--   numrow     - the number of rows that you want to get back.
--   colin      - column definition including query criteria.
-- OUT
--   totalrow   - total number of rows returned by such query.
--   colout     - plsql table contains the query values.
-- NOTE
--   Return all rows when numrow is less than 0.
--   Return no row, but verify all statements when numrow is 0.
--
procedure List(
  startrow   in  number,
  numrow     in  number,
  colin      in  colTabType,
  totalrow   out nocopy number,
  colout     out nocopy wrkTabType)
as
begin
  null;
end;

--
-- Debug_On
--   Turn on debug info.  You must set serveroutput on in sqlplus session.
--
procedure debug_on
is
begin
  wf_worklist_engine.debug := TRUE;
end debug_on;

--
-- Debug_Off
--   Turn off debug info.
--
procedure debug_off
is
begin
  wf_worklist_engine.debug := FALSE;
end debug_off;

end WF_WORKLIST_ENGINE;

/
