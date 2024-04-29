--------------------------------------------------------
--  DDL for Package Body FND_WF_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WF_NOTIFICATION" as
/* $Header: afwfntfb.pls 115.3 2003/09/08 15:01:01 ctilley noship $ */

-- AddAttr
--   Add a new run-time notification attribute.
--   The attribute will be completely unvalidated.  It is up to the
--   user to do any validation and insure consistency.
-- IN:
--   nid - Notification Id
--   aname - Attribute name
--
procedure AddAttr(nid in number,
                  aname in varchar2)
is
begin
  wf_notification.AddAttr(nid,
                          aname);
end AddAttr;


-- SetAttrText
--   Set the value of a notification attribute, given text representation.
--   If the attribute is a NUMBER or DATE type, then translate the
--   text-string value to a number/date using attribute format.
--   For all other types, store the value directly.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetAttrText(nid in number,
                      aname in varchar2,
                      avalue in varchar2)
is
begin
  wf_notification.SetAttrText(nid,
                              aname,
                              avalue);
end SetAttrText;


-- SetAttrNumber
--   Set the value of a number notification attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetAttrNumber (nid in number,
                         aname in varchar2,
                         avalue in number)
is
begin
   wf_notification.SetAttrNumber(nid,
                                 aname,
                                 avalue);
end SetAttrNumber;


-- SetAttrDate
--   Set the value of a date notification attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetAttrDate (nid in number,
                       aname in varchar2,
                       avalue in date)
is
begin
    wf_notification.SetAttrDate(nid,
                                aname,
                                avalue);
end SetAttrDate;


-- GetAttrInfo
--   Get type information about a notification attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute name
-- OUT:
--   atype  - Attribute type
--   subtype - 'SEND' or 'RESPOND',
--   format - Attribute format
--
procedure GetAttrInfo(nid in number,
                      aname in varchar2,
                      atype out nocopy varchar2,
                      subtype out nocopy varchar2,
                      format out nocopy varchar2)
is
begin
   wf_notification.GetAttrInfo(nid,
                               aname,
                               atype,
                               subtype,
                               format);
end GetAttrInfo;


-- GetAttrText
--   Get the value of a text notification attribute.
--   If the attribute is a NUMBER or DATE type, then translate the
--   number/date value to a text-string representation using attrbute format.
--   For all other types, get the value directly.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value

function GetAttrText (nid in number,
                      aname in varchar2)
return varchar2 is
  lvalue varchar2(4000);
begin
  lvalue := wf_notification.GetAttrText(nid,
                                        aname);
  return lvalue;
end GetAttrText;

-- GetAttrNumber
--   Get the value of a number notification attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value

function GetAttrNumber (nid in number,
                        aname in varchar2)
return number is
  lvalue number;
begin
  lvalue := wf_notification.GetAttrNumber(nid,
                                          aname);
  return lvalue;
end GetAttrNumber;


-- GetAttrDate
--   Get the value of a date notification attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value

function GetAttrDate (nid in number,
                      aname in varchar2)
return date is
  lvalue date;
begin
  lvalue := wf_notification.GetAttrDate(nid,
                                        aname);
  return lvalue;
end GetAttrDate;

--
-- GetAttrDoc
--   Get the displayed value of a DOCUMENT-type attribute.
--   Returns referenced document in format requested.
--   Use GetAttrText to get retrieve the actual attr value (i.e. the
--   document key string instead of the actual document).
-- NOTE:
--   Only PLSQL document type is implemented.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
--   disptype - Requested display type.  Valid values:
--               'text/plain' - plain text
--               'text/html' - html
--               '' - attachment(?)
-- RETURNS:
--   Referenced document in format requested.
--
function GetAttrDoc(
  nid in number,
  aname in varchar2,
  disptype in varchar2)
return varchar2 is
  lvalue varchar2(32000);
begin
  lvalue := wf_notification.GetAttrDoc(nid,
                                       aname,
                                       disptype);
  return lvalue;
end GetAttrDoc;


--
-- GetText
--   Substitute tokens in an arbitrary text string.
--     This function may return up to 32K chars. It can NOT be used in a view
--   definition or in a Form.  For views and forms, use GetShortText, which
--   truncates values at 2000 chars.
-- IN:
--   some_text - Text to be substituted
--   nid - Notification id of notification to use for token values
--   disptype - Display type ('text/plain', 'text/html', '')
-- RETURNS:
--   Some_text with tokens substituted.
-- NOTE:
--   If errors are detected this routine returns some_text untouched
--   instead of raising exceptions.
--
function GetText(some_text in varchar2,
                 nid in number,
                 disptype in varchar2 default '')
return varchar2 is
   lvalue varchar2(32000);
begin
   lvalue := wf_notification.GetText(some_text,
                                     nid,
                                     disptype);
   return lvalue;
end GetText;

--
-- GetUrlText
--   Substitute url-style tokens (with dashes) an arbitrary text string.
--     This function may return up to 32K chars. It can NOT be used in a view
--   definition or in a Form.  For views and forms, use GetShortText, which
--   truncates values at 2000 chars.
-- IN:
--   some_text - Text to be substituted
--   nid - Notification id of notification to use for token values
-- RETURNS:
--   Some_text with tokens substituted.
-- NOTE:
--   If errors are detected this routine returns some_text untouched
--   instead of raising exceptions.
--
function GetUrlText(some_text in varchar2,
                    nid in number)
return varchar2 is
  lvalue varchar2(32000);
begin
  lvalue := wf_notification.GetUrlText(some_text,
                                       nid);
  return lvalue;
end GetUrlText;

--
-- GetShortText
--   Substitute tokens in an arbitrary text string, limited to 2000 chars.
--     This function is meant to be used in view definitions and Forms, where
--   the field size must be limited to 2000 chars.  Use GetText() to retrieve
--   up to 32K if the text may be longer.
-- IN:
--   some_text - Text to be substituted
--   nid - Notification id of notification to use for token values
-- RETURNS:
--   Some_text with tokens substituted.
-- NOTE:
--   If errors are detected this routine returns some_text untouched
--   instead of raising exceptions.
--
function GetShortText(some_text in varchar2,
                      nid in number)
return varchar2 is
    lvalue varchar2(32000);
begin
   lvalue := wf_notification.GetShortText(some_text,
                                          nid);
   return lvalue;
end GetShortText;

--
-- GetSubject
--   Get subject of notification message with token values substituted
--   from notification attributes.
-- IN:
--   nid - Notification Id
-- RETURNS:
--   Substituted message subject
-- NOTE:
--   If errors are detected this routine returns the subject unsubstituted,
--   or null if all else fails, instead of raising exceptions.  It must do
--   this so the routine can be pragma'd and used in the
--   wf_notifications_view view.
--
function GetSubject(
                     nid in number)
return varchar2 is
   lvalue varchar2(240);
begin
   lvalue := wf_notification.GetSubject(nid);
   return lvalue;
end GetSubject;

--
-- GetBody
--   Get body of notification message with token values substituted
--   from notification attributes.
--     This function may return up to 32K chars. It can NOT be used in a view
--   definition or in a Form.  For views and forms, use GetShortBody, which
--   truncates values at 2000 chars.
-- IN:
--   nid - Notification Id
--   disptype - Display type ('text/plain', 'text/html', '')
-- RETURNS:
--   Substituted message body
-- NOTE:
--   If errors are detected this routine returns the body unsubstituted,
--   or null if all else fails, instead of raising exceptions.
--
function GetBody(
  nid in number,
  disptype in varchar2 default '')
return varchar2 is
   lvalue varchar2(32000);
begin
   lvalue := wf_notification.GetBody(nid,
                                     disptype);
   return lvalue;
end GetBody;

--
-- GetShortBody
--   Get body of notification message with token values substituted
--   from notification attributes.
--     This function is meant to be used in view definitions and Forms, where
--   the field size must be limited to 2000 chars.  Use GetBody() to retrieve
--   up to 32K if the text may be longer.
-- IN:
--   nid - Notification Id
-- RETURNS:
--   Substituted message body
-- NOTE:
--   If errors are detected this routine returns the body unsubstituted,
--   or null if all else fails, instead of raising exceptions.  It must do
--   this so the routine can be pragma'd and used in the
--   wf_notifications_view view.
--
function GetShortBody(nid in number)
return varchar2 is
  lvalue varchar2(32000);
begin

  lvalue := wf_notification.GetShortBody(nid);
  return lvalue;
end GetShortBody;

--
-- GetInfo
--   Return info about notification
-- IN
--   nid - Notification Id
-- OUT
--   role - Role notification is sent to
--   message_type - Type flag of message
--   message_name - Message name
--   priority - Notification priority
--   due_date - Due date
--   status - Notification status (OPEN, CLOSED, CANCELED)
--
procedure GetInfo(nid in number,
                  role out nocopy varchar2,
                  message_type out nocopy varchar2,
                  message_name out nocopy varchar2,
                  priority out nocopy varchar2,
                  due_date out nocopy varchar2,
                  status out nocopy varchar2)
is
begin
   wf_notification.GetInfo(nid,
                           role,
                           message_type,
                           message_name,
                           priority,
                           due_date,
                           status);
end GetInfo;

--
-- Responder
--   Return responder of closed notification.
-- IN
--   nid - Notification Id
-- RETURNS
--   Responder to notification.  If no responder was set or notification
--   not yet closed, return null.
--
function Responder(
  nid in number)
return varchar2 is
   lvalue varchar2(240);
begin
   lvalue := wf_notification.Responder(nid);
   return lvalue;
end Responder;


-- AccessCheck
--   Check that the notification is open and access key is valid.
-- IN
--   Access string <nid>/<nkey>
-- RETURNS
--   user name (if notificaiton is open and key is valid)
--   othersise null
function AccessCheck(access_str in varchar2)
return varchar2 is
  lvalue varchar2(320);
begin
   lvalue := wf_notification.AccessCheck(access_str);
   return lvalue;
end AccessCheck;

--
-- Send
--   Send the role the specified message.
--   Insert a single notification in the notifications table, and set
--   the default send and respond attributes for the notification.
-- IN:
--   role - Role to send notification to
--   msg_type - Message type
--   msg_name - Message name
--   due_date - Date due
--   callback - Callback function
--   context - Data for callback
--   send_comment - Comment to add to notification
--   priority - Notification priority
-- RETURNS:
--   Notification Id
--
function Send(role in varchar2,
              msg_type in varchar2,
              msg_name in varchar2,
              due_date in date default null,
              callback in varchar2 default null,
              context in varchar2 default null,
              send_comment in varchar2 default null,
              priority in number default null)
return number is
   lvalue number;
begin
   lvalue := wf_notification.Send(role,
                                  msg_type,
                                  msg_name,
                                  due_date,
                                  callback,
                                  context,
                                  send_comment,
                                  priority);
    return lvalue;
end Send;

--
-- SendGroup
--   Send the role users the specified message.
--   Send a separate notification to every user assigned to the role.
-- IN:
--   role - Role of users to send notification to
--   msg_type - Message type
--   msg_name - Message name
--   due_date - Date due
--   callback - Callback function
--   context - Data for callback
--   send_comment - Comment to add to notification
--   priority - Notification priority
-- RETURNS:
--   Group ID - Id of notification group
--
function SendGroup(role in varchar2,
                   msg_type in varchar2,
                   msg_name in varchar2,
                   due_date in date default null,
                   callback in varchar2 default null,
                   context in varchar2 default null,
                   send_comment in varchar2 default null,
                   priority in number default null)
return number is
   lvalue number;
begin
   lvalue := wf_notification.SendGroup(role,
                                  msg_type,
                                  msg_name,
                                  due_date,
                                  callback,
                                  context,
                                  send_comment,
                                  priority);
    return lvalue;
end SendGroup;

--
-- Forward
--   Forward a notification, identified by NID to another user. Validate
--   the user and Return error messages ...
-- IN:
--   nid - Notification Id
--   new_role - Role to forward notification to
--   forward_comment - comment to append to notification
--   user - role who perform this action if provided
--   cnt - count for recursive purpose
--
procedure Forward(nid in number,
                  new_role in varchar2,
                  forward_comment in varchar2 default null,
                  user in varchar2 default null,
                  cnt in number default 0)
is
begin
    wf_notification.Forward(nid,
                            new_role,
                            forward_comment,
                            user,
                            cnt);
end Forward;

--
-- Transfer
--   Transfer a notification, identified by NID to another user. Validate
--   the user and Return error messages ...
-- IN:
--   nid - Notification Id
--   new_role - Role to transfer notification to
--   forward_comment - comment to append to notification
--   user - role who perform this action if provided
--   cnt - count for recursive purpose
--
procedure Transfer(nid in number,
                  new_role in varchar2,
                  forward_comment in varchar2 default null,
                  user in varchar2 default null,
                  cnt in number default 0)
is
begin
     wf_notification.Transfer(nid,
                            new_role,
                            forward_comment,
                            user,
                            cnt);
end Transfer;

--
-- Cancel
--   Cancel a single notification.
-- IN:
--   nid - Notification Id
--   cancel_comment - Comment to append to notification
--
procedure Cancel(nid in number,
                 cancel_comment in varchar2 default null)
is
begin
   wf_notification.Cancel(nid, cancel_comment);
end Cancel;

--
-- CancelGroup
--   Cancel all notifications belonging to a notification group
-- IN:
--   gid - Notification group id
--   cancel_comment - Comment to append to all notifications
--
procedure CancelGroup(gid in number,
                      cancel_comment in varchar2 default null)
is
begin
   wf_notification.CancelGroup(gid, cancel_comment);
end CancelGroup;

--
-- Respond
--   Respond to a notification.
-- IN:
--   nid - Notification Id
--   respond_comment - Comment to append to notification
--   responder - User or role responding to notification
--
procedure Respond(nid in number,
                  respond_comment in varchar2 default null,
                  responder in varchar2 default null)
is
begin
   wf_notification.Respond(nid,
                           respond_comment,
                           responder);
end Respond;

--
-- TestContext
--   Test if current context is correct
-- IN
--   nid - Notification id
-- RETURNS
--   TRUE if context ok, or context check not implemented
--   FALSE if context check fails
--
function TestContext(
  nid in number)
return boolean
is
begin

   return (wf_notification.TestContext(nid));

end TestContext;

--
--
-- VoteCount
--      Count the number of responses for a result_code
-- IN:
--      Gid -  Notification group id
--      ResultCode - Result code to be tallied
-- OUT:
--      ResultCount - Number of responses for ResultCode
--      PercentOfTotalPop - % ResultCode ( As a % of total population )
--      PercentOfVotes - % ResultCode ( As a % of votes cast )
--
procedure VoteCount (   Gid                     in  number,
                        ResultCode              in  varchar2,
                        ResultCount             out nocopy number,
                        PercentOfTotalPop       out nocopy number,
                        PercentOfVotes          out nocopy number )
is
begin
    wf_notification.VoteCount(Gid,
                              ResultCode,
                              ResultCount,
                              PercentOfTotalPop,
                              PercentOfVotes);
end VoteCount;
--
-- OpenNotifications
--      Determine if any Notifications in the Group are OPEN
--
--IN:
--      Gid -  Notification group id
--
--Returns:
--      TRUE  - if the Group contains open notifications
--      FALSE - if the group does NOT contain open notifications
--
function OpenNotificationsExist( Gid    in Number )
return Boolean
is
begin
   return (wf_notification.OpenNotificationsExist(Gid));

end OpenNotificationsExist;

--
-- WorkCount
--   Count number of open notifications for user
-- IN:
--   username - user to check
-- RETURNS:
--   Number of open notifications for that user
--
function WorkCount(
  username in varchar2)
return number
is
  lvalue number;
begin
  lvalue := wf_notification.WorkCount(username);
  return lvalue;
end WorkCount;

--
-- Close
--   Close a notification.
-- IN:
--   nid - Notification Id
--   resp - Respond Required?  0 - No, 1 - Yes
--   responder - User or role close this notification
--
procedure Close(nid in number,
                responder in varchar2 default null)
is
begin
   wf_notification.Close(nid,
                         responder);
end Close;

-- GetSubSubjectDisplay
--   Get the design subject of a notification and Substitute tokens in text
--   with the display name of the attributes in the subject.
--   This is used in routing rule poplists
-- IN:
--   message_type - Item type of the message
--   message_name - Name of the message to substitute
--
function GetSubSubjectDisplay(message_type IN VARCHAR2, message_name IN VARCHAR2)
return varchar2
is
   lvalue varchar2(2000);
begin

   lvalue := wf_notification.GetSubSubjectDisplay(message_type,
                                                  message_name);
   return lvalue;
end GetSubSubjectDisplay;

-- GetSubSubjectDisplayShort
--   Get the design subject of a notification and Substitute tokens in text
--   with ellipsis (...)
--   This is used in routing rule poplists on the Web screens
-- IN:
--   message_type - Item type of the message
--   message_name - Name of the message to substitute
--
function GetSubSubjectDisplayShort(message_type IN VARCHAR2, message_name IN VARCHAR2)
return varchar2
is
   lvalue varchar2(2000);
begin

   lvalue := wf_notification.GetSubSubjectDisplayShort(message_type,
                                                       message_name);
   return lvalue;
end GetSubSubjectDisplayShort;

-- PLSQL-Clob Processing

--Name : GetFullBody (PUBLIC)
--Desc : Gets full body of message with all PLSQLCLOB variables transalted.
--       and returns the message in 32K chunks in the msgbody out variable.
--       Call this repeatedly until end_of_body is true.
--       Call syntax is
--while not (end_of_msgbody) loop
--   wf_notification.getfullbody(nid,msgbody,end_of_msgbody);
--end loop;
procedure GetFullBody (nid in number,
                       msgbody  out nocopy varchar2,
                       end_of_body in out nocopy boolean,
                       disptype in varchar2 default 'text/plain')
is
begin
    wf_notification.GetFullBody(nid,
                                msgbody,
                                end_of_body,
                                disptype);
end GetFullBody;

--Name: GetFullBodyWrapper (PUBLIC)
--Desc : Gets full body of message with all PLSQLCLOB variables transalted.
--       and returns the message in 32K chunks in the msgbody out variable.
--       Call this repeatedly until end_of_body is "Y". Uses string arg
--       instead of boolean like GetFullBody for end_of_msg_body. Created
--       since booleans cannot be passed via JDBC.
--       Call syntax is
--while (end_of_msgbody <> "Y") loop
--   wf_notification.getfullbody(nid,msgbody,end_of_msgbody);
--end loop;
procedure GetFullBodyWrapper (nid in number,
                              msgbody  out nocopy varchar2,
                              end_of_body out nocopy varchar2,
                              disptype in varchar2 default 'text/plain')
is
begin
   wf_notification.GetFullBodyWrapper(nid,
                                msgbody,
                                end_of_body,
                                disptype);
end GetFullBodyWrapper;



END FND_WF_NOTIFICATION;

/
