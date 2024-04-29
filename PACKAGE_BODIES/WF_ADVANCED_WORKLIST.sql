--------------------------------------------------------
--  DDL for Package Body WF_ADVANCED_WORKLIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ADVANCED_WORKLIST" as
/* $Header: wfadvwb.pls 120.2.12010000.3 2009/10/29 10:47:43 sudchakr ship $ */

-- Home page navigation is set false
Home_Page_Worklist boolean := false;
--
-- Authenticate (PUBLIC)
--   Verify user is allowed access to this notification
-- IN
--   nid - notification id
--   nkey - notification access key (if disconnected); currently unused
-- RETURNS
--   Current user name
--
function Authenticate(username in varchar2,
                      nid in number,
                      nkey in varchar2)
return varchar2
is
  recipient      varchar2(320);
  orig_recipient varchar2(320);
  from_role      varchar2(320);
  more_info_role varchar2(320);

  dummy pls_integer;
  admin_role varchar2(2000);
begin
  if (nkey is null) then
    admin_role := wf_core.translate('WF_ADMIN_ROLE');
    -- Get recipient and original recipient of this notification
    begin
      select RECIPIENT_ROLE, ORIGINAL_RECIPIENT, FROM_ROLE, MORE_INFO_ROLE
      into recipient, orig_recipient, from_role, more_info_role
      from WF_NOTIFICATIONS WN
      where WN.NOTIFICATION_ID = nid;
    exception
      when no_data_found then
        Wf_Core.Token('NID', nid);
        Wf_Core.Raise('WFNTF_NID');
    end;

      --first check whether the user is intended recipient or from role or more info role
      -- Check if current user has WF_ADMIN_ROLE privileges.
       if((Wf_Directory.IsPerformer(username, recipient)) OR
          (Wf_Directory.IsPerformer(username, orig_recipient)) OR
          (Wf_Directory.IsPerformer(username, more_info_role)) OR
	  (Wf_Directory.IsPerformer(username, from_role)) OR
          (Wf_Directory.IsPerformer(username, admin_role)) OR
	  (admin_role = '*')) then
  	     return(username);
       else
       -- Authenticate functionality to be in sync with "Notifications from me" view
        begin
         select 1
          into dummy
          from sys.dual
          where exists ( select null
            from wf_item_activity_statuses ias,
              wf_item_activity_statuses_h iash,
              wf_notifications ntf
            where ntf.status = 'OPEN'
               and ias.notification_id = ntf.notification_id
               and ias.item_type = iash.item_type
               and ias.item_key = iash.item_key
               and ias.process_activity = iash.process_activity
               and iash.notification_id in (select notification_id
                   from wf_notifications
                   where status in ('CLOSED','CANCELED','INVALID')
                         and from_role = username)
               and ntf.notification_id = nid
          );
        exception
          when no_data_found then
           Wf_Core.Token('USER', username);
           Wf_Core.Token('NID', to_char(nid));
           Wf_Core.Raise('WFNTF_ACCESS_USER');
       end;
     end if;
  end if;
   return(username);
exception
  when others then
    wf_core.context('Wf_Advanced_Worklist_Html', 'Authenticate', to_char(nid), nkey);
    raise;
end Authenticate;


procedure getInfoAfterDenorm( p_nid in number,
     p_langcode in varchar2,
     p_subject out nocopy varchar2,
     p_touser out nocopy varchar2,
     p_fromuser out nocopy varchar2)
is
begin
  wf_notification.Denormalize_Notification(nid => p_nid, langcode => p_langcode  );
  select DECODE(MORE_INFO_ROLE, NULL, SUBJECT, FND_MESSAGE.GET_STRING('FND','FND_MORE_INFO_REQUESTED')||' '||SUBJECT) AS subject, to_user, from_user
    into p_subject, p_touser, p_fromuser
    from wf_notifications
   where notification_id = p_nid;
exception
 when OTHERS then
   wf_core.context('Wf_Notification', 'getInfoAfterDenorm', p_nid);
   raise;
end getInfoAfterDenorm;

--
-- Authenticate2 (PUBLIC)
--   Verify if user allowed access to this notification. This API takes into
--   consideration if the user being authenticated is a proxy to the original
--   notification recipient
-- IN
--   nid - notification id
--   nkey - notification access key (if disconnected); currently unused
-- RETURNS
--   Current user name
--
function Authenticate2(username in varchar2,
                       nid      in number,
                       nkey     in varchar2)
return varchar2
is
  l_username varchar2(320);
  dummy      pls_integer;
begin

  begin
    return wf_advanced_worklist.Authenticate(username, nid, nkey);
  exception
    when others then
      if (wf_core.error_name <> 'WFNTF_ACCESS_USER') then
        raise;
      end if;
  end;

  -- Perform authentication for proxy, if Authenticate had failed.
  -- If Recipient Role or More Info Role is
  --  1. User - Proxy is grantee for the user.
  --  2. Role - Proxy is grantee of one of the users of the role.
  begin
    SELECT 1
    INTO   dummy
    FROM   dual
    WHERE username IN
    (
      SELECT fg.grantee_key
      FROM   wf_notifications wn,
             wf_user_roles wur,
             fnd_grants fg
      WHERE  ((wn.more_info_role IS NOT NULL AND wur.role_name = wn.more_info_role)
              OR wur.role_name = wn.recipient_role)
      AND    fg.parameter1 = wur.user_name
      AND    fg.menu_id IN
             (SELECT menu_id
              FROM   fnd_menus
              WHERE  menu_name = 'FND_WF_WORKLIST')
      AND    fg.object_id IN
             (SELECT object_id
              FROM   fnd_objects
              WHERE  obj_name = 'NOTIFICATIONS')
      AND    fg.instance_set_id IN
             (SELECT instance_set_id
              FROM   fnd_object_instance_sets
              WHERE  instance_set_name = 'WL_PROXY_ACCESS')
      AND    fg.instance_type = 'SET'
      AND    fg.start_date <= sysdate
      AND    (fg.end_date IS NULL OR fg.end_date > sysdate)
      AND    (fg.parameter2 IS NULL OR
               (fg.parameter2 IS NOT NULL AND
                INSTR(','||replace(trim(fg.parameter2), ' ')||',',
                      ','||replace(trim(wn.message_type), ' ')||',') > 0)
             )
      AND    wn.notification_id = nid
    );
  exception
    when no_data_found then
      Wf_Core.Token('USER', username);
      Wf_Core.Token('NID', to_char(nid));
      Wf_Core.Raise('WFNTF_ACCESS_USER');
  end;

  return (username);

exception
  when others then
    wf_core.context('Wf_Advanced_Worklist', 'Authenticate2', username, to_char(nid), nkey);
    raise;
end Authenticate2;

procedure SetNavFromHomePage(isebizhomepage in number)
is
begin
 if (isebizhomepage = 1) then
   Home_Page_Worklist := true;
 else
   Home_Page_Worklist := false;
 end if;
exception
  when others then
    raise;
end SetNavFromHomePage;


function GetNavFromHomePage return boolean is
begin
 return Home_Page_Worklist;
end GetNavFromHomePage;

end WF_ADVANCED_WORKLIST;

/
