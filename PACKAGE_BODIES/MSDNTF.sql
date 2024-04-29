--------------------------------------------------------
--  DDL for Package Body MSDNTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSDNTF" AS
/* $Header: msdntwfb.pls 115.2 2002/05/08 13:08:28 pkm ship   $ */

PROCEDURE SETUSER (AdHocRole in varchar2,
                    UserList in varchar2)
IS
   -- May replace with AdHocRole
   roleName varchar2(30) :=AdHocRole;
BEGIN
   wf_directory.AddUsersToAdHocRole(role_name => AdHocRole,
                                    role_users => UserList);
end SETUSER;
PROCEDURE SETROLE (AdHocRole in varchar2, ExpDays in number)
IS
   -- May replace with AdHocRole
   roleDisplayName varchar2(30) := AdHocRole;
   roleName varchar2(30) :=AdHocRole;
   addDays number :=ExpDays;

BEGIN
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
   roleName varchar2(30) :=AdHocRole;
BEGIN
 wf_directory.RemoveUsersFromAdHocRole(roleName, UserList);
end REMUSER;
--
-- REMALL cleans up wf_local_roles.  It is called from OES by ntf.purgerole
-- ntf.purgerole also calls wf_purge.notificatons and wf_purgeItem
-- along with this so all expired notifications are cleaned.
-- These are called by expiration_date.
--
PROCEDURE REMALL (AdHocRole in varchar2)
IS
   roleName varchar2(30) :=AdHocRole;
BEGIN
  wf_directory.RemoveUsersFromAdHocRole(roleName);

  delete wf_local_roles
  where name = roleName;

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
   itemtype varchar2(30) := iteminput;
   itemkey varchar2(30) := inputkey;
   owner varchar2(30) := inowner;
   RptLoc varchar2(200) := URLfragment;
   roleName varchar2(30) :=AdHocRole;
   BEGIN
   wf_engine.CreateProcess(ItemType => ItemType,
                           itemKey => ItemKey,
                           process => WorkflowProcess);
   wf_engine.SetItemOwner(ItemType => ItemType,
                         ItemKey => ItemKey,
                         owner => owner);
   wf_engine.SetItemAttrText(Itemtype => ItemType,
				   Itemkey => ItemKey,
				   aname => 'ADHOCROLE',
				   avalue => roleName);
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
				   avalue => RptLoc);

   wf_engine.StartProcess(ItemType => ItemType,
                         ItemKey => ItemKey);
   return;
   exception
     when others then
        WF_CORE.CONTEXT('MSDNTF', 'DO_NTFY ',
         itemtype, itemkey);
   raise;
end DO_NTFY;
end MSDNTF;

/
