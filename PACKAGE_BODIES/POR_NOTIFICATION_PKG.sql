--------------------------------------------------------
--  DDL for Package Body POR_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_NOTIFICATION_PKG" AS
/* $Header: PORNOTFB.pls 115.4 2002/11/19 00:46:01 jjessup ship $ */
/*
 * For SSP5 Home page
 */
procedure  getTodoNotifications(
 username in varchar2 default null,
 subject1 out nocopy varchar2,
 subject2 out nocopy varchar2,
 subject3 out nocopy varchar2,
 nid1 out nocopy varchar2,
 nid2 out nocopy varchar2,
 nid3 out nocopy varchar2,
 display_more out nocopy varchar2)
as
  subject_d varchar2(240):= '@#$%';
  dummy_nid pls_integer := -999;
  dummy_nid1 pls_integer := -999;
  dummy_subject varchar2(240);
  dummy_subject2 varchar2(240);
  origSystem varchar2(240);
  origSystemId number;

  cursor c_user(user in varchar2) is
    select orig_system_id, orig_system
    from wf_users
    where name = user
    and orig_system not in ('POS', 'ENG_LIST', 'CUST_CONT');

  cursor attrs(user in varchar2, origSys in varchar2, origId in number) is
  select WN.notification_id
  from WF_NOTIFICATIONS WN
  where WN.RECIPIENT_ROLE in
   ((select user from dual) union all
    (select role_name from wf_user_roles
     where user_name = user and
     user_orig_system = origSys and user_orig_system_id = origId ))
  and  wn.message_type in
   ( select distinct  WF_CREATEDOC_ITEMTYPE
     from PO_DOCUMENT_TYPES
     union
     select distinct  WF_APPROVAL_ITEMTYPE
     from PO_DOCUMENT_TYPES
     union
     select 'PORCPT' from dual)
  and wn.status = 'OPEN'
  and exists( select 1 from WF_NOTIFICATION_ATTRIBUTES NA,
    WF_MESSAGE_ATTRIBUTES_VL MA,
    WF_NOTIFICATIONS N
    where
     N.NOTIFICATION_ID=WN.NOTIFICATION_ID
     and NA.NOTIFICATION_ID = N.NOTIFICATION_ID
     and MA.MESSAGE_NAME = N.MESSAGE_NAME
     and MA.MESSAGE_TYPE = N.MESSAGE_TYPE
     and MA.NAME = NA.NAME
     and MA.SUBTYPE = 'RESPOND'
     and MA.TYPE <> 'FORM')
  and sysdate - wn.begin_date <=60
  order by WN.notification_id desc;


begin
  /* no need to authenticate in this routine because we're getting the notifications based on the username, so of course this user has access to these notifications */
    open c_user(username);
    fetch c_user into origSystemId, origSystem;
    close c_user;

    open attrs(username, origSystem, origSystemId);
    fetch attrs into dummy_nid;

    if (dummy_nid <>-999) then
     nid1 := to_char(dummy_nid);
      subject1 := wf_notification.Getsubject(dummy_nid);
    end if;
    dummy_nid := -999;
   fetch attrs into dummy_nid;

   if (dummy_nid <>-999) then
     nid2 := to_char(dummy_nid);
    subject2 := wf_notification.Getsubject(dummy_nid);
   end if;
   dummy_nid := -999;
fetch attrs into dummy_nid;

   if (dummy_nid <> -999) then
     nid3 := to_char(dummy_nid);
    subject3 := wf_notification.Getsubject(dummy_nid);
   end if;

   fetch attrs into dummy_nid1;
    if (dummy_nid1 <> -999) then
       display_more := '1';
    else
       display_more := '0';
    end if;
  close attrs;


exception
  when others then
--    Wf_Core.Context('wfa_html_jsp', 'getTruncatedSubjects');
  raise;
end getTodoNotifications;

procedure  getNotificationSubjects(
 nid1 in integer,
 nid2 in integer,
 nid3 in integer,
 subject1 out nocopy varchar2,
 subject2 out nocopy varchar2,
 subject3 out nocopy varchar2) as
begin

    if (nid1 <>-999) then
      subject1 := wf_notification.Getsubject(nid1);
    end if;
    if (nid2 <>-999) then
      subject2 := wf_notification.Getsubject(nid2);
    end if;
    if (nid3 <>-999) then
      subject3 := wf_notification.Getsubject(nid3);
    end if;


exception
  when others then
  raise;
end getNotificationSubjects;

end por_notification_pkg;

/
