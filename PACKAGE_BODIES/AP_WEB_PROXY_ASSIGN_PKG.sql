--------------------------------------------------------
--  DDL for Package Body AP_WEB_PROXY_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_PROXY_ASSIGN_PKG" AS
/* $Header: apwprasb.pls 120.1.12000000.2 2007/02/15 23:01:42 skoukunt ship $ */

-- api has two conditions, if responsibility id is null then effectively all the
-- responsbilities for the user gets updated else only the specified
-- responsibility id for the user gets updated.
PROCEDURE all_assignee_update(p_assignor_id IN NUMBER,
                   p_responsibility_id IN NUMBER,
                   p_resp_app_id IN NUMBER,
                   p_sec_id IN NUMBER,
                   p_app_short_name IN VARCHAR2,
                   p_end_date IN DATE,
                   p_notification IN VARCHAR2) AS

  l_assignee_name varchar2(100);
  l_responsibility_name varchar2(100);
  l_effective_start_date date;
  l_effective_end_date date;
  l_end_date date;
  l_resp_app_id number;
  l_resp_key varchar2(30);
  l_sec_key varchar2(30);

     cursor c1 is
          select c.user_name l_assignee_name,
             b.responsibility_name l_responsibility_name,
             pa.effective_start_date l_effecttive_start_date,
             pa.effective_end_date l_effective_end_date,
             b.application_id as resp_application_id,
             d.responsibility_key, e.security_group_key
          from AP_WEB_PROXY_ASSIGNMENTS pa, fnd_responsibility_tl b, fnd_user c,
             fnd_responsibility d, fnd_security_groups e, per_people_f ppf
          where   pa.ASSIGNEE_ID = c.user_id
          and pa.RESPONSIBILITY_ID = b.RESPONSIBILITY_ID
          and pa.ASSIGNOR_ID = p_assignor_id
          and b.language = userenv('LANG')
          and b.responsibility_id = d.responsibility_id
          and b.application_id = d.application_id
          and pa.security_group_id = e.security_group_id and  c.employee_id = ppf.person_id
          and pa.RESPONSIBILITY_ID = p_responsibility_id
          and pa.responsibility_app_id = p_resp_app_id
          and pa.responsibility_app_id = b.application_id
          and e.security_group_id = p_sec_id --
          for update of pa.effective_end_date;
    cursor c2 is
         select c.user_name l_assignee_name,
             b.responsibility_name l_responsibility_name,
             pa.effective_start_date l_effecttive_start_date,
             pa.effective_end_date l_effective_end_date,
             b.application_id as resp_application_id,
             d.responsibility_key, e.security_group_key
             from AP_WEB_PROXY_ASSIGNMENTS pa, fnd_responsibility_tl b, fnd_user c,
             fnd_responsibility d, fnd_security_groups e, per_people_f ppf
             where   pa.ASSIGNEE_ID = c.user_id
             and pa.RESPONSIBILITY_ID = b.RESPONSIBILITY_ID
             and pa.ASSIGNOR_ID = p_assignor_id
             and b.language = userenv('LANG')
             and b.responsibility_id = d.responsibility_id
             and b.application_id = d.application_id
             and pa.security_group_id = e.security_group_id
             and  c.employee_id = ppf.person_id
             and pa.responsibility_app_id = b.application_id
             for update of pa.effective_end_date;
BEGIN
 if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,'AP_WEB_PROXY_ASSIGN_PKG.all_assignee_update','Enter');
 end if;
 if (p_end_date is not null) then
    l_end_date := trunc(p_end_date);
 end if;
 if (p_responsibility_id is not null) then
        open c1;
        loop
            FETCH c1 into l_assignee_name, l_responsibility_name,l_effective_start_date,
                          l_effective_end_date,  l_resp_app_id, l_resp_key, l_sec_key;
            EXIT WHEN c1%NOTFOUND;
            if (p_notification = 'Y') then
                 send_notification(l_assignee_name,
                            l_responsibility_name,
                            'UPDATED',
                            l_effective_start_date,
                            l_end_date);
            end if;
            -- call fnd_user_pkg.addResp l_assignee_name,
            FND_USER_PKG.addresp(l_assignee_name, p_app_short_name, l_resp_key, l_sec_key, null, l_effective_start_date, l_end_date);
            update ap_web_proxy_assignments
            set effective_end_date = l_end_date
            where current of c1;
        end loop;
        close c1;
 else
        open c2;
        loop
            fetch c2 into l_assignee_name, l_responsibility_name,l_effective_start_date,
                 l_effective_end_date, l_resp_app_id, l_resp_key, l_sec_key ;
            exit when c2%NOTFOUND;
            if (p_notification = 'Y') then
                 send_notification(l_assignee_name,
                            l_responsibility_name,
                            'UPDATED',
                            l_effective_start_date,
                            l_end_date);
            end if;
            -- call fnd_user_pkg.addResp
            FND_USER_PKG.addresp(l_assignee_name, p_app_short_name, l_resp_key, l_sec_key, null, l_effective_start_date, l_end_date);
            update ap_web_proxy_assignments
            set effective_end_date = l_end_date
            where current of c2;
        end loop;
        close c2;
 end if;
 if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,'AP_WEB_PROXY_ASSIGN_PKG.all_assignee_update','Exit');
 end if;
exception when OTHERS then
    app_exception.raise_exception;
END all_assignee_update;

/*----------------------------------------------------------------------------*
 | Procedure
 |      proxy_assignments
 |
 | DESCRIPTION
 |    --  for OIE development only
 |    function that gets called by the workflow
 |    this function is subscribed to following events:
 |          oracle.apps.fnd.wf.ds.userRole.updated
 |          oracle.apps.fnd.wf.ds.user.updated
 | Based on event key and its paramters, function would call other private procedure within
 | this package to update the ap_web_proxy_assignments table, update fnd responsibilities
 | by calling fnd_user_pkg.addresp api and sending notificaiton to assignee.
 |
 | PARAMETERS
 |     	p_subscription_guid
 |      p_event
 |
 | RETURNS
 |     	SUCCESS/ ERROR
 *----------------------------------------------------------------------------*/
FUNCTION proxy_assignments  (p_subscription_guid  IN RAW,
   p_event              IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2
AS
   l_event_key VARCHAR2(1000);
   l_user_id VARCHAR2(30);
   l_resp_id VARCHAR2(30);
   l_resp_app_id VARCHAR2(30);
   l_event_name VARCHAR2(100);
   l_end_date date;
   l_expiration_date date;
   l_user_name varchar2(100);
   l_ignore_str varchar2(30);
   l_resp_key varchar2(30);
   l_sec_key varchar2(30);
   l_start_date varchar2(100);
   l_app_short_name varchar2(30);
   l_sec_group_id  number;

BEGIN
   if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,'AP_WEB_PROXY_ASSIGN_PKG.proxy_assignments','Start');
   end if;
   l_event_name := p_event.getEventName();
   l_event_key := p_event.GetEventKey;

   if (l_event_name = 'oracle.apps.fnd.user.role.update') then

      l_user_id := p_event.GetValueForParameter('FND_USER_ID');
      l_resp_id := p_event.GetValueForParameter('FND_RESPONSIBILITY_ID');
      l_app_short_name := p_event.GetValueForParameter('FND_APPS_SHORT_NAME');
      l_resp_app_id := p_event.GetValueForParameter('FND_RESPONSIBILITY_APPS_ID');

      select end_date, security_group_id
      into l_end_date, l_sec_group_id
      from fnd_user_resp_groups_direct
      where responsibility_id = l_resp_id
      and user_id = l_user_id
      and rownum = 1;

      all_assignee_update(l_user_id, l_resp_id, l_resp_app_id, l_sec_group_id, l_app_short_name, l_end_date, 'N');

   elsif (l_event_name = 'oracle.apps.fnd.wf.ds.user.updated') then
         if (p_event.GetValueForParameter('PARENT_ORIG_SYSTEM') = 'PER') then
             if ( (p_event.GetValueForParameter('STATUS') = 'INACTIVE')
                  or ((p_event.GetValueForParameter('EXPIRATION_DATE')) <
                      (p_event.GetValueForParameter('OLD_END_DATE')) ) ) then
             l_user_name := p_event.GetValueForParameter('USER_NAME');
             select user_id, nvl(end_date, sysdate)
             into l_user_id, l_end_date from fnd_user
             where user_name = l_event_key;
           end if;
         end if;
         -- this event to capture when an employee is terminated
         -- all assigned responsibilities get updated.
         all_assignee_update(l_user_id, null, null, null, 'SQLAP', l_end_date, 'N');
   end if;
   if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,'AP_WEB_PROXY_ASSIGN_PKG.proxy_assignments','End');
   end if;
   return 'SUCCESS';
 exception when others then
        if p_subscription_guid IS NOT NULL THEN
          WF_CORE.context('AP_WEB_PROXY_ASSIGN_PKG', 'proxy_assignments', p_event.getEventName(), p_subscription_guid);
          WF_EVENT.setErrorInfo(p_event, 'ERROR');
        end if;
        raise;
        return 'ERROR';
END proxy_assignments;


/*----------------------------------------------------------------------------*
 | Procedure
 |      send_notification
 |
 | DESCRIPTION
 |       -- for OIE development only
 |      Procedure to send notification to assignee when a responsibility is
 |      assigned/ udpated Message indicates the responsibility name,
 |      start date and end date.
 |
 | PARAMETERS
 |       p_user_name    fnd user name
 |       p_resp_name    fnd responsibility name
 |       p_assignor_name fnd user_name of assignor
 |       p_start_date   start date for the repsonsibility
 |       p_end_date     end date for the responsibility.
 |
 *----------------------------------------------------------------------------*/

PROCEDURE send_notification(p_user_name     IN VARCHAR2,
                            p_resp_name     IN VARCHAR2,
                            p_assignor_name IN VARCHAR2,
                            p_start_date IN VARCHAR2,
                            p_end_date      IN VARCHAR2) IS

 l_role_name         varchar2(30);
 l_role_display_name varchar2(80);
 l_subject           varchar2(2000);
 l_body              varchar2(2000);
 l_request_id        varchar2(120) ;
 l_notification_id   number;
 l_textNameArr       Wf_Engine.NameTabTyp;
 l_textValArr        Wf_Engine.TextTabTyp;
 iText               number ;
 l_full_name         varchar2(255);

BEGIN

  if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,'AP_WEB_PROXY_ASSIGN_PKG.send_notification','Enter');
  end if;

  select p_user_name || to_char(sysdate, 'DDMONYYYYHH24MISS') into l_request_id from dual;

  -- get Assignor full name from db
  select full_name
  into l_full_name
  from fnd_user fu, hr_employees hre
  where fu.employee_id = hre.employee_id
  and user_name = p_assignor_name;

  -- Fetch the message used as the confirmation message subject
  FND_MESSAGE.SET_NAME ('SQLAP', 'OIE_PROXY_NOTIF_SUB');
  FND_MESSAGE.SET_TOKEN ('ASSIGNOR_NAME', l_full_name);
  l_subject := FND_MESSAGE.get;

  -- Fetch the message used as the confirmation message body
  -- if end date is null which  means forever get a different message.
  if (p_end_date is not null) then
     FND_MESSAGE.SET_NAME ('SQLAP', 'OIE_PROXY_NOTIF_BODY');
     FND_MESSAGE.SET_TOKEN ('END_DATE', p_end_Date);
  else
     FND_MESSAGE.SET_NAME ('SQLAP', 'OIE_PROXY_NOEND_DATE');
  end if;
  FND_MESSAGE.SET_TOKEN ('RESP_NAME', p_resp_name);
  FND_MESSAGE.SET_TOKEN ('START_DATE', p_start_date);
  l_body := FND_MESSAGE.get;

  -- Create a process using the WF definition for sending AP emails(APWPROXY)
  iText := 0;
  WF_ENGINE.CREATEPROCESS('APWPROXY', l_request_id, 'AP_WEB_PROXY_PROCESS');
  l_textNameArr(iText) := 'AP_WEB_PROXY_SUBJECT';
  l_textValArr(iText)  := l_subject;
  iText := iText + 1;
  l_textNameArr(iText) := 'AP_WEB_PROXY_BODY';
  l_textValArr(iText)  := l_body;
  iText := iText + 1;
  l_textNameArr(iText) := 'AP_WEB_RECIPIENT';
  l_textValArr(iText)  := p_user_name;
  WF_ENGINE.SetItemAttrTextArray('APWPROXY', l_request_id, l_textNameArr, l_textValArr);
  -- Start the notification process
  WF_ENGINE.STARTPROCESS('APWPROXY', l_request_id);

  if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,'AP_WEB_PROXY_ASSIGN_PKG.send_notification','Exit');
  end if;

exception when others then
    Wf_Core.Context('AP_WEB_PROXY_ASSIGN_PKG', 'send_notification',
                     p_user_name, p_resp_name, to_char(sysdate));
    raise;
END send_notification;

END AP_WEB_PROXY_ASSIGN_PKG;

/
