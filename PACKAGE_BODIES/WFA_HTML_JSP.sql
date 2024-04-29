--------------------------------------------------------
--  DDL for Package Body WFA_HTML_JSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WFA_HTML_JSP" as
/* $Header: wfjspb.pls 120.6 2006/04/27 23:47:46 hgandiko noship $ */

/* get notification id given item type, item key, username.
 ** Created for integration with SSP Orders to Approve
 **/
function getSSPNid (
username IN VARCHAR2,
itemtype  IN VARCHAR2,
itemkey       IN VARCHAR2
)
return number
IS
nid number;
  colon pls_integer;        -- Magic orig_system decoder
  uorig_system varchar2(8); -- User orig_system for indexes
  uorig_system_id pls_integer; -- User orig_system_id for indexes
  ctx varchar2(2000);
BEGIN

  -- Fetch user orig_system_ids for indexes in main cursor
  begin
    -- cannot rewrite using wf_directory package because of pragma WNPS
    colon := instr(username, ':');
    if (colon = 0) then
      select WR.ORIG_SYSTEM, WR.ORIG_SYSTEM_ID
      into uorig_system, uorig_system_id
      from WF_ROLES WR
      where WR.NAME = username
      and   WR.ORIG_SYSTEM NOT IN ('HZ_PARTY','POS','ENG_LIST','AMV_CHN',
                                  'HZ_GROUP','CUST_CONT');

    else
      select WR.ORIG_SYSTEM, WR.ORIG_SYSTEM_ID
      into uorig_system, uorig_system_id
      from WF_ROLES WR
      where WR.ORIG_SYSTEM = substr(username, 1, colon-1)
      and WR.ORIG_SYSTEM_ID = substr(username,  colon+1)
      and WR.NAME = username;
    end if;
  exception
    when no_data_found then
--      wf_core.token('ROLE', username);
--      wf_core.raise('WFNTF_ROLE');
    raise;
  end;

  ctx := itemtype||':'||itemkey||':'||'%';
  select MAX(notification_id) into nid
  from   (
         select notification_id, context
         from   WF_NOTIFICATIONS
         where  more_info_role = username
         union all
         select notification_id, context
         from   WF_NOTIFICATIONS
         where  more_info_role is null
         and    RECIPIENT_ROLE in
                (select WUR.ROLE_NAME
                 from   WF_USER_ROLES WUR
                 where  WUR.USER_ORIG_SYSTEM = getSSPNid.uorig_system
                 and    WUR.USER_ORIG_SYSTEM_ID = getSSPNid.uorig_system_id
                 and    WUR.USER_NAME = username)
         ) v
  where v.context like ctx;
  return nid;

exception
  when others then
--    wf_core.context('Wfa_Html_Jsp', 'getSSPNid', username, itemtype, itemkey);
    raise;
end getSSPNid;


/* get notification id given item type, item key, username.
 ** Created for integration with SSP Orders to Approve
 ** returns open notifications only
 **/
function getSSPOpenNid (
username IN VARCHAR2,
itemtype  IN VARCHAR2,
itemkey       IN VARCHAR2
)
return number
IS
nid number;
  colon pls_integer;        -- Magic orig_system decoder
  uorig_system varchar2(8); -- User orig_system for indexes
  uorig_system_id pls_integer; -- User orig_system_id for indexes
  ctx varchar2(2000);
BEGIN

  -- Fetch user orig_system_ids for indexes in main cursor
  begin
    -- cannot rewrite using wf_directory package because of pragma WNPS
    colon := instr(username, ':');
    if (colon = 0) then
      select WR.ORIG_SYSTEM, WR.ORIG_SYSTEM_ID
      into uorig_system, uorig_system_id
      from WF_ROLES WR
      where WR.NAME = username
      and   WR.ORIG_SYSTEM NOT IN ('HZ_PARTY','POS','ENG_LIST','AMV_CHN',
                                  'HZ_GROUP','CUST_CONT');

    else
      select WR.ORIG_SYSTEM, WR.ORIG_SYSTEM_ID
      into uorig_system, uorig_system_id
      from WF_ROLES WR
      where WR.ORIG_SYSTEM = substr(username, 1, colon-1)
      and WR.ORIG_SYSTEM_ID = substr(username,  colon+1)
      and WR.NAME = username;
    end if;
  exception
    when no_data_found then
--      wf_core.token('ROLE', username);
--      wf_core.raise('WFNTF_ROLE');
    raise;
  end;

  ctx := itemtype||':'||itemkey||':'||'%';
  select MAX(notification_id) into nid
  from   (
         select notification_id, context
         from   WF_NOTIFICATIONS
         where  more_info_role = username
         and    status = 'OPEN'
         union all
         select notification_id, context
         from   WF_NOTIFICATIONS
         where  more_info_role is null
         and    RECIPIENT_ROLE in
                (select WUR.ROLE_NAME
                 from   WF_USER_ROLES WUR
                 where  WUR.USER_ORIG_SYSTEM = getSSPOpenNid.uorig_system
                 and    WUR.USER_ORIG_SYSTEM_ID = getSSPOpenNid.uorig_system_id
                 and    WUR.USER_NAME = username)
         and    status = 'OPEN'
         ) v
  where v.context like ctx;

  return nid;

exception
  when others then
--    wf_core.context('Wfa_Html_Jsp', 'getSSPOpenNid', username, itemtype, itemkey);
    raise;
end getSSPOpenNid;

end WFA_HTML_JSP;

/
