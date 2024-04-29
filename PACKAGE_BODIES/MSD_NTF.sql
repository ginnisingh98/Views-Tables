--------------------------------------------------------
--  DDL for Package Body MSD_NTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_NTF" AS
/* $Header: msdntwfb.pls 120.3 2006/02/14 09:43:30 faliu noship $ */

PROCEDURE SETUSER (AdHocRole in varchar2,
                    UserList in varchar2)
IS
BEGIN
   wf_directory.AddUsersToAdHocRole(role_name => AdHocRole,
                                    role_users => UserList);
end SETUSER;

PROCEDURE SETROLE (AdHocRole in varchar2, ExpDays in number)
IS
   roleDisplayName varchar2(340);
   roleName varchar2(320);
   addDays number;

BEGIN
   roleDisplayName := AdHocRole;
   roleName := AdHocRole;
   addDays := ExpDays;

   wf_directory.CreateAdHocRole(role_name => roleName,
			role_display_name => roleDisplayName,
                                language  => NULL,
                                territory => NULL,
                         role_description => NULL,
                 notification_preference  => 'MAILHTML',
                               role_users => NULL,
                           email_address  => NULL,
                                fax       => NULL,
                                status    => 'ACTIVE',
                         expiration_date  => sysdate+addDays);
end SETROLE;

PROCEDURE REMUSER (AdHocRole in varchar2,
                   UserList in varchar2)
IS
BEGIN
 wf_directory.RemoveUsersFromAdHocRole(AdHocRole, UserList);
end REMUSER;

--
-- REMALL cleans up wf_local_roles.  It is called from OES by ntf.purgerole
-- ntf.purgerole also calls wf_purge.notificatons and wf_purgeItem
-- along with this so all expired notifications are cleaned.
-- These are called by expiration_date.
--
PROCEDURE REMALL (AdHocRole in varchar2)
IS
BEGIN
  wf_directory.RemoveUsersFromAdHocRole(AdHocRole);

  delete wf_local_roles
  where name = AdHocRole;

  commit;

end REMALL;

--
-- Accepts arguements to set message for notifications.
-- Creates notifcation process, sets attributes and
-- starts [sends] the notification.  It relies on the
-- Ad Hoc directory service being set.

PROCEDURE DO_NTFY (WorkflowProcess in varchar2,
                      iteminput in varchar2,
                      inputkey in varchar2,
                      inowner in varchar2,
                      AdHocRole in varchar2,
                      URLfragment in varchar2,
		      Subject in varchar2,
                      msgBody in varchar2)
IS
   itemtype varchar2(30);
   itemkey varchar2(240);
   owner varchar2(320);
BEGIN
   itemtype := iteminput;
   itemkey := inputkey;
   owner := inowner;

   wf_engine.CreateProcess(ItemType => ItemType,
                           itemKey => ItemKey,
                           process => WorkflowProcess);
   wf_engine.SetItemOwner(ItemType => ItemType,
                         ItemKey => ItemKey,
                         owner => owner);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'ADHOCROLE',
				   avalue => AdHocRole);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'NTFSUBJECT',
				   avalue => Subject);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'NTFMSGBODY',
				   avalue => msgBody);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'URLVALUE',
				   avalue => URLfragment);

   wf_engine.StartProcess(ItemType => ItemType,
                         ItemKey => ItemKey);
   return;
   exception
     when others then
        WF_CORE.CONTEXT('MSD_NTF', 'DO_NTFY ',
         itemtype, itemkey);
   raise;
end DO_NTFY;


procedure SHOW_REPORT_CLOB(document_id in varchar2,
                           display_type in varchar2,
                           document in out nocopy clob,
                           document_type in out nocopy varchar2) IS
begin
  --check display_type
  if (display_type <> 'text/plain') then
    document_type := 'text/html';
    dbms_lob.append(document, msd_common_utilities.dbms_aw_interp(document_id));
  end if;

  -- handle case where the assignment or the alert has been deleted
  EXCEPTION
    when others then
      null;
end SHOW_REPORT_CLOB;

end MSD_NTF;

/
