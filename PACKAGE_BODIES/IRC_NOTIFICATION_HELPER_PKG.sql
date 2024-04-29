--------------------------------------------------------
--  DDL for Package Body IRC_NOTIFICATION_HELPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_NOTIFICATION_HELPER_PKG" AS
/* $Header: irnothlp.pkb 120.7.12010000.7 2009/12/08 10:14:42 uuddavol ship $ */
-- -- --------------------------------------------------------------------- *
-- Name    : get_job_seekers_role
-- Purpose : function to obtain the wf role based on a person_id.
-- --------------------------------------------------------------------- *
FUNCTION get_job_seekers_role
(p_person_id    per_all_people_f.person_id%type
) RETURN varchar2 IS
  l_role_name  fnd_user.user_name%type;
  --
  cursor get_usr is
  SELECT usr.user_name
  FROM fnd_user usr
  WHERE usr.employee_id = p_person_id
  and (usr.end_date is null or usr.end_date >=sysdate);
  --
BEGIN
  open get_usr;
  fetch get_usr into l_role_name;
  close get_usr;
  --
  RETURN l_role_name;
EXCEPTION
WHEN OTHERS  THEN
  if (get_usr%isopen) then
    close get_usr;
  end if;
  raise;
END;
--
-- --------------------------------------------------------------------- *
-- Name : set_v2_attributes
-- Purpose: The wf text attributes values can only be 1950chars in length.
--          This procedure converts the possible 15600 plsql varchar2 value
--          to multiple 1950 char sql value chunks that can be held
--          as attributes in the database.
-- (internal)
-- --------------------------------------------------------------------- *
PROCEDURE set_v2_attributes
  (p_wf_attribute_value  VARCHAR2
  ,p_wf_attribute_name   VARCHAR2
  ,p_nid                 NUMBER
  )
IS
  l_attribute_length   NUMBER DEFAULT length(p_wf_attribute_value);
  l_counter            NUMBER DEFAULT 0;
  l_max_no_of_attribs  NUMBER DEFAULT 8;
  l_next_attrib        NUMBER;
BEGIN
  IF l_attribute_length > 1950 THEN
    -- Loop through p_wf_attribute_value and grab chunks of 1950 bytes of it
    -- (up to the max number catered for by the workflow) setting the
    -- appropiate wf attribute.
    FOR x IN 1 .. least
                    (trunc
                      (l_attribute_length/1950), l_max_no_of_attribs)
    LOOP
      l_counter := l_counter + 1;
      wf_notification.setAttrText ( p_nid
                                  , p_wf_attribute_name|| '_' ||x
                                  , substr( p_wf_attribute_value
                                          , ((x * 1950) - 1949)
                                          ,  1950
                                          )
                                  );
    END LOOP;
    -- The previous loop took as many 1950 byte chunks as possible.  If
    -- there is still a workflow attribute available (there are
    -- l_max_no_of_attributes available), use the next one in line to
    -- hold the remainder to the value.
    IF ((l_counter < l_max_no_of_attribs)
      AND mod(l_attribute_length,1950)<> 0) THEN
      l_next_attrib := l_counter + 1;
      wf_notification.setAttrText ( p_nid
                                  , p_wf_attribute_name|| '_' ||l_next_attrib
                                  , substr( p_wf_attribute_value
                                          , l_attribute_length
                                            - (mod (l_attribute_length,1950)- 1)
                                          , l_attribute_length
                                          )
                                  );
    END IF;
  ELSE
   -- There are less than 1950 chars in the value, so it can be stored
   -- whole in the first workflow attribute.
    wf_notification.setAttrText ( p_nid
                                , p_wf_attribute_name|| '_' ||'1'
                                , p_wf_attribute_value
                                );
  END IF;
END;
-- --------------------------------------------------------------------- *
-- Name : send_text_notification
-- Purpose: Send Notification in Text Format
-- --------------------------------------------------------------------- *
FUNCTION send_text_notification
 ( p_user_name IN  varchar2
 , p_subject   IN  varchar2
 , p_text_body IN  varchar2 DEFAULT null
 , p_from_role IN  varchar2 DEFAULT null
 )
RETURN number
IS
PRAGMA autonomous_transaction;
  l_message_type    wf_messages.type%type;
  l_message_name    wf_messages.name%type := 'IRC_TEXT_MSG';
  l_nid             number;
BEGIN
  --
  l_message_type :=fnd_profile.value('IRC_WORKFLOW_ITEM_TYPE');
  l_nid:=wf_notification.send(  upper(p_user_name)
                               ,  l_message_type
                               ,  l_message_name
                               );
  --
  -- p_from_role contains the name of the person who is sending this
  -- Notification
  --
    if(p_from_role is not null)
    then
      wf_notification.setAttrText ( l_nid , '#FROM_ROLE'   , p_from_role);
    end if;
  --
    wf_notification.setAttrText ( l_nid , 'SUBJECT'   , p_subject);
    set_v2_attributes
      (p_wf_attribute_value  => p_text_body
      ,p_wf_attribute_name   => 'TEXT_BODY'
      ,p_nid                 => l_nid);
    wf_notification.denormalize_notification(l_nid);
  commit;
  RETURN l_nid;
END send_text_notification;
--
-- --------------------------------------------------------------------- *
-- Name : send_html_text_notification
-- Purpose: Send Notification in Text and Html Format
-- --------------------------------------------------------------------- *
FUNCTION send_html_text_notification
 ( p_user_name IN  varchar2
 , p_subject   IN  varchar2
 , p_html_body IN  varchar2 DEFAULT null
 , p_text_body IN  varchar2 DEFAULT null
 , p_from_role IN  varchar2 DEFAULT null
 )
RETURN number
IS
PRAGMA autonomous_transaction;
  l_message_type    wf_messages.type%type;
  l_message_name    wf_messages.name%type := 'IRC_TEXT_HTML_MSG';
  l_nid             number;
BEGIN
  --
  l_message_type :=fnd_profile.value('IRC_WORKFLOW_ITEM_TYPE');
  l_nid:=wf_notification.send(  upper(p_user_name)
                               ,  l_message_type
                               ,  l_message_name
                               );
  --
  -- p_from_role contains the name of the person who is sending this
  -- Notification
  --
    if(p_from_role is not null)
    then
      wf_notification.setAttrText ( l_nid , '#FROM_ROLE'   , p_from_role);
    end if;
  --
    wf_notification.setAttrText ( l_nid , 'SUBJECT'   , p_subject);
    set_v2_attributes
      (p_wf_attribute_value  => p_html_body
      ,p_wf_attribute_name   => 'HTML_BODY'
      ,p_nid                 => l_nid);
    if p_text_body is not null then
      set_v2_attributes
        (p_wf_attribute_value  => p_text_body
        ,p_wf_attribute_name   => 'TEXT_BODY'
        ,p_nid                 => l_nid);
    end if;
    wf_notification.denormalize_notification(l_nid);
  commit;
  RETURN l_nid;
END send_html_text_notification;
-- --------------------------------------------------------------------- *

--
-- --------------------------------------------------------------------- *
-- Name : Create_AdHoc_User
-- Purpose: To create Adhoc User
-- --------------------------------------------------------------------- *
FUNCTION Create_AdHoc_User
  (p_email_address  IN VARCHAR2)
RETURN varchar2
IS
PRAGMA autonomous_transaction;
  l_user_name          wf_users.name%TYPE ;
  l_user_display_name  wf_users.display_name%TYPE ;
BEGIN
  -- Create an ad-hoc user
  wf_directory.CreateAdHocUser
  ( name           => l_user_name
  , display_name   => l_user_display_name
  , email_address  => p_email_address
  , notification_preference => 'MAILHTML'
  );
  --
  commit;
  RETURN l_user_name;
END Create_AdHoc_User;
-- --------------------------------------------------------------------- *
-- Name : send_notification (overloaded function)
-- Purpose: See header
-- --------------------------------------------------------------------- *
FUNCTION send_notification
 ( p_email_address  IN  varchar2
 , p_subject        IN  varchar2
 , p_html_body      IN  varchar2 DEFAULT null
 , p_text_body      IN  varchar2 DEFAULT null
 , p_from_role IN  varchar2 DEFAULT null
 )
RETURN number
IS
  l_user_name          wf_users.name%TYPE ;
  l_nid             number;
cursor get_user_name is
select user_name
from fnd_user
where upper(email_address)=upper(p_email_address)
and (end_date is null or end_date >=sysdate);

BEGIN

  open get_user_name;
  fetch get_user_name into l_user_name;
  if get_user_name%notfound then
    close get_user_name;
    -- Create an ad-hoc user
    l_user_name := Create_AdHoc_User
    (  p_email_address  => p_email_address );
  else
    close get_user_name;
  end if;
  --
 l_nid := send_notification
       ( p_user_name => l_user_name
       , p_subject   => p_subject
       , p_html_body => p_html_body
       , p_text_body => p_text_body
       , p_from_role => p_from_role);
  --
  RETURN l_nid;
END;
-- --------------------------------------------------------------------- *
-- Name : send_notification (overloaded function)
-- Purpose: See header
-- --------------------------------------------------------------------- *
FUNCTION send_notification
 ( p_person_id IN  number
 , p_subject   IN  varchar2
 , p_html_body IN  varchar2 DEFAULT null
 , p_text_body IN  varchar2 DEFAULT null
 , p_from_role IN  varchar2 DEFAULT null
 )
RETURN number
IS
  l_seeker_role     wf_roles.name%type;
  l_nid             number;
BEGIN
  -- Get the job seekers role.
  l_seeker_role := get_job_seekers_role ( p_person_id );
  --
  IF l_seeker_role IS NOT NULL THEN
    l_nid := send_notification
       ( p_user_name => l_seeker_role
       , p_subject   => p_subject
       , p_html_body => p_html_body
       , p_text_body => p_text_body
       , p_from_role => p_from_role);
  ELSE
    fnd_message.set_name('PER','IRC_412059_NO_ROLE_4_PARTY');
    fnd_message.raise_error();
  END IF;
  RETURN l_nid;
END;
-- --------------------------------------------------------------------- *
-- Name : send_notification (overloaded function)
-- Purpose: See header
-- --------------------------------------------------------------------- *
FUNCTION send_notification
 ( p_user_name IN  varchar2
 , p_subject   IN  varchar2
 , p_html_body IN  varchar2 DEFAULT null
 , p_text_body IN  varchar2 DEFAULT null
 , p_from_role IN  varchar2 DEFAULT null
 )
RETURN number
IS
  l_nid             number;
BEGIN
  --
  if p_html_body is not null
  then
    l_nid := send_html_text_notification
             ( p_user_name   =>  p_user_name
             , p_subject     =>  p_subject
             , p_html_body   =>  p_html_body
             , p_text_body   =>  p_text_body
             , p_from_role   =>  p_from_role
             );
  else
    l_nid := send_text_notification
             ( p_user_name   =>  p_user_name
             , p_subject     =>  p_subject
             , p_text_body   =>  p_text_body
             , p_from_role   =>  p_from_role
             );
  end if;
  RETURN l_nid;
END send_notification;

--
-- --------------------------------------------------------------------- *
-- Name : send_attach_resume_notify
-- Purpose: The wf attribute corresponding to the resumes should be set .
--          this procedure will decide which message to be used depending
--          upon the number of resumes to be attached
-- (internal)
-- --------------------------------------------------------------------- *
function send_attach_resume_notify
(p_user_name  in  varchar2
 ,p_subject    in  varchar2
 ,p_html_body  in  varchar2 default null
 ,p_from_role  in  varchar2 default null
 ,p_doc_ids    in  g_document_ids)
 return number is
   --
   pragma autonomous_transaction;
   l_message_type    wf_messages.type%Type;
   l_message_name    wf_messages.name%Type;
   l_nid             number;
   l_doc_text        varchar2(2000);
   --
begin
   --
   l_message_type :=fnd_profile.value('IRC_WORKFLOW_ITEM_TYPE');
   --
   if p_doc_ids.count > 0 then
      --
       l_message_name := 'IRC_HTML_RESUME_MSG';
      --
   else
      l_message_name := 'IRC_TEXT_HTML_MSG';
   end if;
   --
   l_nid:=wf_notification.send(upper(p_user_name)
                              ,l_message_type
                              ,l_message_name);
   --
   -- p_from_role contains the name of the person who is sending this
   -- Notification
   --
   if(p_from_role is not null) then
      --
      wf_notification.setAttrText(l_nid, '#FROM_ROLE', p_from_role);
      --
   end if;
   --
   wf_notification.setAttrText(l_nid, 'SUBJECT', p_subject);
   set_v2_attributes(p_wf_attribute_value  => p_html_body
                    ,p_wf_attribute_name   => 'HTML_BODY'
                    ,p_nid                 => l_nid);
   --
   if p_doc_ids.count > 0 then
      --
      for i in p_doc_ids.first..p_doc_ids.count loop
         --
         l_doc_text := 'plsqlblob:irc_notification_helper_pkg.show_resume/'||p_doc_ids(i);
         wf_notification.setAttrText(l_nid,
                                     'IRC_RESUME_'||to_char(i),
                                     l_doc_text);
         --
      end loop;
      --
   end if;
   --
   wf_notification.denormalize_notification(l_nid);
   commit;
   return l_nid;
   --
end send_attach_resume_notify;
--
-- --------------------------------------------------------------------- *
-- Name : attach_resumes_notification
-- Purpose: See header
-- --------------------------------------------------------------------- *
function attach_resumes_notification(
                                     p_user_name  in  varchar2
                                     ,p_subject    in  varchar2
                                     ,p_html_body  in  varchar2 default null
                                     ,p_from_role  in  varchar2 default null
                                     ,p_person_ids in  varchar2 default null
                                     )
   return number is
   --
   l_nid              number;
   l_rank             number         := 1;
   l_resume           varchar2(20)   := 'RESUME';
   l_auto_resume      varchar2(20)   := 'AUTO_RESUME';
   l_count            number         := 1;
   l_doc_ids          g_document_ids;
   Type doc_id_csr    is ref cursor;
   csr_doc            doc_id_csr;
   l_query_str        varchar2(3000):=
                      'select document_id from (
                      select document_id, person_id, rank () over
                      (partition by person_id order by last_update_date desc) rank
                      from irc_documents doc
                      where type in (:p_resume,:p_auto_resume)
                        and (doc.end_Date is null or doc.end_Date > sysdate)
                        and person_id in ('||p_person_ids||'))
                      where rank = :p_rank';
   --
begin
   --
   open csr_doc for l_query_str using l_resume, l_auto_resume, l_rank;
   fetch csr_doc into l_doc_ids(l_count);
   while csr_doc%found loop
     l_count := l_count + 1;
     fetch csr_doc into l_doc_ids(l_count);
   end loop;
   --
   close csr_doc;
   --
   l_nid := send_attach_resume_notify(
            p_user_name   =>  p_user_name
           ,p_subject     =>  p_subject
           ,p_html_body   =>  p_html_body
           ,p_from_role   =>  p_from_role
           ,p_doc_ids     =>  l_doc_ids);
   --
  return l_nid;
  --
end attach_resumes_notification;
--
-- --------------------------------------------------------------------- *
-- Name : get_doc
-- Purpose: See header
-- --------------------------------------------------------------------- *
procedure get_doc (document_id in varchar2
                  ,display_type in varchar2
                  ,document in out nocopy varchar2
                  ,document_type in out nocopy varchar2) is
begin
  document:=document_id;
end get_doc;
--

--
-- --------------------------------------------------------------------- *
-- Name : show_resume
-- Purpose: See header
-- --------------------------------------------------------------------- *
procedure show_resume (document_id    in varchar2
                       ,display_type  in varchar2
                       ,document      in out nocopy blob
                       ,document_type in out nocopy varchar2
                       )is
  l_blob        blob;
  l_mimetype    varchar2(240);
  l_file_name   varchar2(240);
  p_document_id varchar2(100);
  cursor csr_doc is select binary_doc,
                                         mime_type,
                                         file_name
                                from irc_documents
                              where document_id = p_document_id;
begin
  p_document_id := document_id;
  open csr_doc;
  fetch csr_doc into l_blob, l_mimetype,l_file_name;
  close csr_doc;
  document_type := l_mimetype||'; name='||l_file_name;
  dbms_lob.copy(document,l_blob,dbms_lob.getlength(l_blob));
  --
end show_resume;
--
-- --------------------------------------------------------------------- *
-- Name : raiseNotifyEvent
-- Purpose: To raise notifications sending event
-- --------------------------------------------------------------------- *
procedure raiseNotifyEvent( p_eventName    in varchar2
                          , p_assignmentId in number
                          , p_personId     in number
                          , params         in clob)    is
    l_eventData clob;
    l_eventKey  number;
    l_proc varchar2(100) := 'raiseNotifyEvent';
    l_assignmentId number;
    l_personId     number;
    l_eventName    varchar2(30);
    PRAGMA AUTONOMOUS_TRANSACTION;
    begin
      hr_utility.set_location('Entering:'|| g_package||'.'||l_proc, 10);
      l_assignmentId := p_assignmentId;
      l_personId     := p_personId;
      l_eventName    := p_eventName;
      l_eventData := params;
      if l_assignmentId is null
      then
         l_assignmentId := IRC_NOTIFICATION_DATA_PKG.getParamValue
                                   ( p_param     => 'IRC_ASSIGNMENT_ID'
                                   , p_eventData => l_eventData) ;
      else
         l_eventData := l_eventData
                           || 'IRC_ASSIGNMENT_ID:'
                           || l_assignmentId
                           || ';';
      end if;
      if l_personId is null
      then
         l_personId := IRC_NOTIFICATION_DATA_PKG.getParamValue
                                   ( p_param     => 'IRC_CAND_PER_ID'
                                   , p_eventData => l_eventData) ;
      else
         l_eventData := l_eventData
                           || 'IRC_CAND_PER_ID:'
                           || l_personId
                           || ';';
      end if;
      if l_eventName is null
      then
         l_eventName := IRC_NOTIFICATION_DATA_PKG.getParamValue
                                     ( p_param     => 'IRC_EVENT_NAME'
                                     , p_eventData => l_eventData) ;
      else
         l_eventData := l_eventData
                         || 'IRC_EVENT_NAME:'
                         || l_eventName
                         || ';';
      end if;
      if(l_eventName is null or
          (l_eventName = 'CANDREG' and l_personId is null) or
          (l_eventName = 'UPDCANDREF' and l_personId is null) or
          (l_eventName <> 'CANDREG' and l_eventName <> 'UPDCANDREF' and l_assignmentId is null) )
      then
        hr_utility.set_location('All mandatory values not available', 20);
      else
        hr_utility.set_location('Raise event here', 40);
        select IRC_NOTIFICATION_EVENT_KEY_S.nextval into l_eventKey from dual;
        hr_utility.set_location('Event Key : '|| l_eventKey, 50);
        wf_event.raise( p_event_name => 'oracle.apps.per.irc.common.notifications'
                      , p_event_key   => l_eventKey
                      , p_event_data  => l_eventData);
        commit;
      end if;
      hr_utility.set_location('Success - Exiting:'|| g_package||'.'||l_proc, 80);
    exception
      when others then
          hr_utility.set_location('Error - Exiting:'|| g_package||'.'||l_proc, 100);
end raiseNotifyEvent;
--
END irc_notification_helper_pkg;

/
