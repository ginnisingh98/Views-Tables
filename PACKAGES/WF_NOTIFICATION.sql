--------------------------------------------------------
--  DDL for Package WF_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_NOTIFICATION" AUTHID CURRENT_USER as
/* $Header: wfntfs.pls 120.9.12010000.22 2017/04/03 10:09:44 nsanika ship $ */
/*#
 * Provides APIs to access the Oracle Workflow Notification
 * System and manage notifications.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Notification System
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_NOTIFICATION
 * @rep:ihelp FND/@notif_api See the related online help
 */

--
-- Type
--
type tdType is table of varchar2(4005) index by binary_integer;

--
-- Constant values
--

-- Document attribute presentation type tags
doc_text varchar2(30) := 'text/plain';
doc_html varchar2(30) := 'text/html';
fwk_region_start varchar2(20) :=  'JSP:/OA_HTML/OA.jsp?';
notification_macro varchar2(20) := 'WF_NOTIFICATION';
fwk_mailer_page varchar2(100) := '/OA_HTML/OA.jsp?page=/oracle/apps/fnd/wf/worklist/webui/NotifMailerPG';


-- Cached NLS values
-- 64 is drawned from v$nls_valid_values view.
nls_language  varchar2(64);
nls_territory varchar2(64);
nls_charset   varchar2(64);

-- Debug
debug   boolean := FALSE;


-- Bug 3065814
-- Global context variables for post-notification
g_context_user  varchar2(320);
g_context_user_comment VARCHAR2(4000);
g_context_recipient_role varchar2(320);
g_context_original_recipient varchar2(320);
g_context_from_role varchar2(320);
g_context_new_role   varchar2(320);
g_context_more_info_role  varchar2(320);
g_context_proxy varchar2(320);

-- User's NLS date mask
g_nls_date_mask varchar2(50);

-- Bug 7476628 - Flag to indicate if WF_RENDER.XML_STYLE_SHEET should be called
-- in PLSQL layer
g_wf_render_xml_style_sheet boolean := true;

-- NTF_TABLE
--   Generate a "Browser Look and Feel (BLAF)" look a like table.
-- ADA compliance is achieved through "scope".
--
-- IN
--   cells - array of table cells
--   col   - number of columns
--   type  - V to generate a vertical table
--         - H to generate a horizontal table
--   rs    - the result html code for the table
--
-- NOTE
--   type - Vertical table is Header always on the first column
--        - Horizontal table is Headers always on first row
--
--   cell has the format:
--     R40%:content of the cell here
--     ^ ^
--     | |
--     | + -- width specification
--     +-- align specification (L-Left, C-Center, R-Right)
--
procedure NTF_Table(cells in tdType,
                    col   in pls_integer,
                    type  in varchar2,  -- 'V'ertical or 'H'orizontal
                    rs    in out nocopy varchar2);
--
-- WF_MSG_ATTR
--   Create a table of message attributes
-- NOTE
--   o Considered using dynamic sql passing in attributes as a comma delimited
--     list.  The cost of non-reusable sql may be high.
--   o Considered using bind variables with dynamic sql.  Then we must impose
--     a hard limit on the number of bind variables.  If a limit exceed we
--     need some fall back handling.
--   o Parsing the comma delimited list and making individual select is more
--     costly.  But the sql will be reusable, it may end up cheaper.
--
function wf_msg_attr(nid    in number,
                     attrs  in varchar2,
                     disptype in varchar2)
return varchar2;

-- AddAttr
--   Add a new run-time notification attribute.
--   The attribute will be completely unvalidated.  It is up to the
--   user to do any validation and insure consistency.
-- IN:
--   nid - Notification Id
--   aname - Attribute name
--
/*#
 * Adds a new runtime notification attribute. Perform validation and insure
 * consistency in the use of the attribute, as it is completely unvalidated
 * by Oracle Workflow.
 * @param nid Notification ID
 * @param aname Attribute Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add Notification Attribute
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_addatt See the related online help
 */
procedure AddAttr(nid in number,
                  aname in varchar2);


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
/*#
 * Sets the value of a notification text attribute at either send or respond
 * time. The notification agent (sender) may set the value of SEND attributes.
 * The performer (responder) may set the value of RESPOND attributes.
 * @param nid Notification ID
 * @param aname Attribute Name
 * @param avalue Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Notification Text Attribute Value
 * @rep:compatibility S
 * @rep:businessevent oracle.apps.wf.notification.setattrtext
 * @rep:ihelp FND/@notif_api#a_setatt See the related online help
 */
procedure SetAttrText(nid in number,
                      aname in varchar2,
                      avalue in varchar2);


-- SetAttrNumber
--   Set the value of a number notification attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
--   avalue - New value for attribute
--
/*#
 * Sets the value of a notification number attribute at either send or respond
 * time. The notification agent (sender) may set the value of SEND attributes.
 * The performer (responder) may set the value of RESPOND attributes.
 * @param nid Notification ID
 * @param aname Attribute Name
 * @param avalue Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Notification Number Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_setatt See the related online help
 */
procedure SetAttrNumber (nid in number,
                         aname in varchar2,
                         avalue in number);


-- SetAttrDate
--   Set the value of a date notification attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
--   avalue - New value for attribute
--
/*#
 * Sets the value of notification date attribute at either send or respond
 * time. The notification agent (sender) may set the value of SEND attributes.
 * The performer (responder) may set the value of RESPOND attributes.
 * @param nid Notification ID
 * @param aname Attribute Name
 * @param avalue Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Notification Date Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_setatt See the related online help
 */
procedure SetAttrDate (nid in number,
                       aname in varchar2,
                       avalue in date);


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
/*#
 * Returns information about a notification attribute, such as its type,
 * subtype, and format, if any is specified. The subtype is always SEND
 * or RESPOND to indicate the attribute's source.
 * @param nid Notification ID
 * @param aname Attribute Name
 * @param atype Attribute Type
 * @param subtype Attribute Subtype ('SEND' or 'RESPOND')
 * @param format Attribute Format
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Notification Attribute Information
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_getattinfo See the related online help
 */
procedure GetAttrInfo(nid in number,
                      aname in varchar2,
                      atype out nocopy varchar2,
                      subtype out nocopy varchar2,
                      format out nocopy varchar2);


-- GetAttrText
--   Get the value of a text notification attribute.
--   If the attribute is a NUMBER or DATE type, then translate the
--   number/date value to a text-string representation using attrbute format.
--   For all other types, get the value directly.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
--   ignore_notfound - Ignore if Not Found
-- RETURNS:
--   Attribute value
/*#
 * Returns the value of a specified text message attribute.
 * @param nid Notification ID
 * @param aname Attribute Name
 * @param ignore_notfound Ignore if Not Found
 * @return Text Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Notification Text Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_getatt See the related online help
 */
function GetAttrText (nid in number,
                      aname in varchar2,
   	              ignore_notfound in boolean default NULL)
return varchar2;


-- GetAttrNumber
--   Get the value of a number notification attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
/*#
 * Returns the value of a specified number message attribute.
 * @param nid Notification ID
 * @param aname Attribute Name
 * @return Number Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Notification Number Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_getatt See the related online help
 */
function GetAttrNumber (nid in number,
                        aname in varchar2)
return number;


-- GetAttrDate
--   Get the value of a date notification attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   nid - Notification id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
/*#
 * Returns the value of a specified date message attribute.
 * @param nid Notification ID
 * @param aname Attribute Name
 * @return Date Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Notification Date Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_getatt See the related online help
 */
function GetAttrDate (nid in number,
                      aname in varchar2)
return date;

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
/*#
 * Returns the displayed value of a Document-type attribute. The
 * referenced document appears in either plain text or HTML format, as
 * requested. If you wish to retrieve the actual attribute value, that is,
 * the document key string instead of the actual document, use GetAttrText().
 * @param nid Notification ID
 * @param aname Attribute Name
 * @param disptype Display Type
 * @return Document Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Notification Document Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_gad See the related online help
 */
function GetAttrDoc(
  nid in number,
  aname in varchar2,
  disptype in varchar2)
return varchar2;

--
-- SetFrameworkAgent
--   Check the URL for a JSP: entry and then substitute
--   it with the value of the APPS_FRAMEWORK_AGENT
--   profile option.
-- IN:
--   URL - URL to be ckecked
-- RETURNS:
--   URL with Frame work agent added
-- NOTE:
--   If errors are detected this routine returns some_text untouched
--   instead of raising exceptions.
--
function SetFrameworkAgent(url in varchar2)
return varchar2;

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
/*#
 * Substitutes tokens in an arbitrary text string using token values from a
 * particular notification. This function may return up to 32K characters.
 * You cannot use this function in a view definition or in an Oracle Forms
 * Developer form. For views and forms, use GetShortText() which truncates
 * values at 1950 characters. If an error is detected, this function returns
 * some_text unsubstituted rather than raise exceptions.
 * @param some_text Text to be substituted
 * @param nid Notification ID
 * @param disptype Display Type
 * @return Substituted Text
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Notification Text
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_gettext See the related online help
 */
function GetText(some_text in varchar2,
                 nid in number,
                 disptype in varchar2 default '')
return varchar2;

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
return varchar2;
-- <<sstomar>> bug 8430385 : useing wf_notification_util.getCalendarDate in
-- wf_notification.getTextInternal()
--pragma restrict_references(GetUrlText, WNDS);

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
/*#
 * Substitutes tokens in an arbitrary text string using token values from a
 * particular notification. This function may return up to 1950 characters.
 * This function is meant for use in view definitions and Oracle Forms
 * Developer forms, where the field size is limited to 1950 characters. Use
 * GetText() in other situations where you need to retrieve up to 32K
 * characters. If an error is detected, this function returns some_text
 * unsubstituted rather than raise exceptions.
 * @param some_text Text to be substituted
 * @param nid Notification ID
 * @return Substituted Text
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Notification Short Text
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_gst See the related online help
 */
function GetShortText(some_text in varchar2,
                      nid in number)
return varchar2;
-- <<sstomar>> bug 8430385 : useing wf_notification_util.getCalendarDate in
-- wf_notification.getTextInternal()
--pragma restrict_references(GetShortText, WNDS);

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
/*#
 * Returns the subject line for the notification message. Any message
 * attribute in the subject is token substituted with the value of the
 * corresponding message attribute.
 * @param nid Notification ID
 * @return Subject Text
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Notification Subject
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_getsubj See the related online help
 */
function GetSubject(
  nid in number)
return varchar2;
--pragma restrict_references(GetSubject, WNDS);

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
/*#
 * Returns the HTML or plain text message body for the notification,
 * depending on the message body type specified. Any message attribute
 * in the body is token substituted with the value of the corresponding
 * notification attribute. This function may return up to 32K characters.
 * You cannot use this function in view definitions or in Oracle
 * Developer forms. For views and forms, use GetShortBody( ) which
 * truncates values at 1950 characters. Note that the returned plain text
 * message body is not formatted, it should be wordwrapped as appropriate
 * for the output device. Body text may contain tabs (which indicate
 * indentation) and newlines (which indicate paragraph termination).
 * @param nid Notification ID
 * @param disptype Display Type
 * @return Notification Body
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Notification Body
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_getbody See the related online help
 */
function GetBody(
  nid in number,
  disptype in varchar2 default '')
return varchar2;

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
/*#
 * Returns the message body for the notification. Any message attribute
 * in the body is token substituted with the value of the corresponding
 * notification attribute. This function may return up to 1950 characters.
 * This function is meant for use in view definitions and Oracle Developer
 * forms, where the field size is limited to 1950 characters. Use GetBody()
 * in other situations where you need to retrieve up to 32K characters.
 * Note that the returned plain text message body is not formatted; it
 * should be wordwrapped as appropriate for the output device. Body text
 * may contain tabs (which indicate indentation) and newlines (which
 * indicate paragraph termination). If an error is detected, this function
 * returns the body unsubstituted or null if all else fails, rather than
 * raise exceptions.
 * @param nid Notification ID
 * @return Notification Body
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Notification Short Body
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_gsb See the related online help
 */
function GetShortBody(nid in number)
return varchar2;
-- <<sstomar>> bug 8430385 : useing wf_notification_util.getCalendarDate in
-- wf_notification.getTextInternal()
--pragma restrict_references(GetShortBody, WNDS);

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
/*#
 * Returns the role that the notification is sent to, the item type of the
 * message, the name of the message, the notification priority, the due
 * date and the status for the specified notification.
 * @param nid Notification ID
 * @param role Recipient Role
 * @param message_type Message Type
 * @param message_name Message Name
 * @param priority Priority
 * @param due_date Due Date
 * @param status Status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Notification Information
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_getinfo See the related online help
 */
procedure GetInfo(nid in number,
                  role out nocopy varchar2,
                  message_type out nocopy varchar2,
                  message_name out nocopy varchar2,
                  priority out nocopy varchar2,
                  due_date out nocopy varchar2,
                  status out nocopy varchar2);

--
-- Responder
--   Return responder of closed notification.
-- IN
--   nid - Notification Id
-- RETURNS
--   Responder to notification.  If no responder was set or notification
--   not yet closed, return null.
--
/*#
 * Returns the responder of a closed notification. If the notification was
 * closed using the Web Notification interface the value returned will be a
 * valid role defined in the view WF_ROLES. If the Notification was closed
 * using the e-mail interface then the value returned will be an e-mail address.
 * @param nid Notification ID
 * @return Responder
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Notification Responder
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#responder See the related online help
 */
function Responder(
  nid in number)
return varchar2;

-- AccessCheck
--   Check that the notification is open and access key is valid.
-- IN
--   Access string <nid>/<nkey>
-- RETURNS
--   user name (if notificaiton is open and key is valid)
--   othersise null
/*#
 * Returns a username if the notification access string is valid and the
 * notification is open, otherwise it returns null. The access string is
 * automatically generated by the notification mailer that sends the
 * notification and is used to verify the authenticity of both text and
 * HTML versions of e-mail notifications.
 * @param access_str Access String
 * @return Username
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check Notification Access
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_acccheck See the related online help
 */
function AccessCheck(access_str in varchar2) return varchar2;
pragma restrict_references(AccessCheck, WNDS);

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
/*#
 * Sends the specified message to a role, returning a notification ID if
 * successful. The notification ID must be used in all future references
 * to the notification. If your message has message attributes, the procedure
 * looks up the values of the attributes from the message attribute table or
 * it can use an optionally supplied callback interface function to get the
 * value from the item type attributes table.
 * @param role Recipient Role
 * @param msg_type Message Type
 * @param msg_name Message Name
 * @param due_date Due Date
 * @param callback Callback Function
 * @param context Context
 * @param send_comment Send Comment
 * @param priority Priority
 * @return Notification ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Send Notification
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_send See the related online help
 */
function Send(role in varchar2,
              msg_type in varchar2,
              msg_name in varchar2,
              due_date in date default null,
              callback in varchar2 default null,
              context in varchar2 default null,
              send_comment in varchar2 default null,
              priority in number default null)
return number;

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
/*#
 * Sends a separate notification to all the users assigned to a specific role
 * and returns a number called a notification group ID, if successful. The
 * notification group ID identifies that group of users and the notification
 * they each received. If your message has message attributes, the procedure
 * looks up the values of the attributes from the message attribute table or
 * it can use an optionally supplied callback interface function to get the
 * value from the item type attributes table.
 * @param role Recipient Role
 * @param msg_type Message Type
 * @param msg_name Message Name
 * @param due_date Due Date
 * @param callback Callback Function
 * @param context Context
 * @param send_comment Send Comment
 * @param priority Priority
 * @return Notification Group ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Send Group Notification
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_sndgrp See the related online help
 */
function SendGroup(role in varchar2,
                   msg_type in varchar2,
                   msg_name in varchar2,
                   due_date in date default null,
                   callback in varchar2 default null,
                   context in varchar2 default null,
                   send_comment in varchar2 default null,
                   priority in number default null)
return number;

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
--   action_source - From where the procedure is called from
--                  RULE  - Routing Rule
--                  WA    - By Proxy User thro' Worklist Access
--                  ADMIN - Status Monitor
--
/*#
 * Delegates a notification to a new role to perform work, even though
 * the original role recipient still maintains ownership of the notification
 * activity. Also implicitly calls the Callback function specified in the
 * Send or SendGroup function with FORWARD mode. A comment can be supplied
 * to explain why the forward is taking place.
 * @param nid Notification ID
 * @param new_role New Recipient Role for the Notification
 * @param forward_comment Forwarding Comment
 * @param user For Internal Use Only
 * @param cnt For Internal Use Only
 * @param action_source For Internal Use Only
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Forward Notification
 * @rep:compatibility S
 * @rep:businessevent oracle.apps.wf.notification.reassign
 * @rep:ihelp FND/@notif_api#a_forward See the related online help
 */
procedure Forward(nid             in number,
                  new_role        in varchar2,
                  forward_comment in varchar2 default null,
                  user            in varchar2 default null,
                  cnt             in number   default 0,
                  action_source   in varchar2 default null);

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
--   action_source - From where the procedure is called from
--                  RULE  - Routing Rule
--                  WA    - By Proxy User thro' Worklist Access
--                  ADMIN - Status Monitor
--
/*#
 * Forwards a notification to a new role and transfers ownership of the
 * notification to the new role. It also implicitly calls the Callback
 * function specified in the Send or SendGroup function with TRANSFER mode.
 * A comment can be supplied to explain why the forward is taking place.
 * @param nid Notification ID
 * @param new_role New Recipient Role for the Notification
 * @param forward_comment Forwarding Comment
 * @param user For Internal Use Only
 * @param cnt For Internal Use Only
 * @param action_source For Internal Use Only
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Transfer Notification
 * @rep:compatibility S
 * @rep:businessevent oracle.apps.wf.notification.reassign
 * @rep:ihelp FND/@notif_api#a_transfer See the related online help
 */
procedure Transfer(nid in number,
                  new_role in varchar2,
                  forward_comment in varchar2 default null,
                  user in varchar2 default null,
                  cnt in number default 0,
                  action_source in varchar2 default null);

--
-- Cancel
--   Cancel a single notification.
-- IN:
--   nid - Notification Id
--   cancel_comment - Comment to append to notification
--
/*#
 * Cancels a notification. The notification status is then changed to
 * 'CANCELED' but the row is not removed from the WF_NOTIFICATIONS table
 * until a purge operation is performed. If the notification was delivered
 * via e-mail and expects a response, a 'Canceled' e-mail is sent to the
 * original recipient as a warning that the notification is no longer valid.
 * @param nid Notification ID
 * @param cancel_comment Cancel Comment
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Cancel Notification
 * @rep:compatibility S
 * @rep:businessevent oracle.apps.wf.notification.cancel
 * @rep:ihelp FND/@notif_api#a_cancel See the related online help
 */
procedure Cancel(nid in number,
                 cancel_comment in varchar2 default null);

--
-- CancelGroup
--   Cancel all notifications belonging to a notification group
-- IN:
--   gid - Notification group id
--   cancel_comment - Comment to append to all notifications
--
/*#
 * Cancels the individual copies of a specific notification sent to all users in
 * a notification group. The notifications are identified by the notification
 * Group ID (gid). The notification status is then changed to 'CANCELED' but the
 * rows are not removed from the WF_NOTIFICATIONS table until a purge operation
 * is performed. If the notification was delivered via e-mail and expects a
 * response, a 'Canceled' e-mail is sent to the original recipient as a warning
 * that the notification is no longer valid.
 * @param gid Notification Group ID
 * @param cancel_comment Cancel Comment
 * @param timeout Timeout
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Cancel Group Notification
 * @rep:compatibility S
 * @rep:businessevent oracle.apps.wf.notification.cancel
 * @rep:ihelp FND/@notif_api#a_cnclgrp See the related online help
 */
procedure CancelGroup(gid in number,
                      cancel_comment in varchar2 default null,
		      timeout in boolean default FALSE);

--
-- Respond
--   Respond to a notification.
--   ER 10177347: Moved its code to Respond2 and Complete APIs
-- IN:
--   nid - Notification Id
--   respond_comment - Comment to append to notification
--   responder - User or role responding to notification
--   action_source - From where the procedure is called from
--                  RULE  - Routing Rule
--                  WA    - By Proxy User thro' Worklist Access
--                  ADMIN - Status Monitory
--
/*#
 * Completes the response to the notification when the performer applies the
 * response. The procedure marks the notification as 'CLOSED' and communicates
 * RESPOND attributes back to the database via the callback function (if supplied).
 * This procedure also accepts the name of the individual who actually responded
 * to the notification and stores in the RESPONDER column of WF_NOTIFICATIONS table.
 * @param nid Notification ID
 * @param respond_comment Respond Comment
 * @param responder Performer who responded to the notification
 * @param action_source For Internal Use Only
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Respond to Notification
 * @rep:compatibility S
 * @rep:businessevent oracle.apps.wf.notification.respond
 * @rep:ihelp FND/@notif_api#a_respond See the related online help
 */
procedure Respond(nid             in number,
                  respond_comment in varchar2 default null,
                  responder       in varchar2 default null,
                  action_source   in varchar2 default null);

--
-- TestContext
--   Test if current context is correct
-- IN
--   nid - Notification id
-- RETURNS
--   TRUE if context ok, or context check not implemented
--   FALSE if context check fails
--
/*#
 * Tests if the current context is correct by calling the Item Type
 * Selector/Callback function. This function returns TRUE if the context
 * check is OK, or if no Selector/Callback function is implemented. It
 * returns FALSE if the context check fails.
 * @param nid Notification ID
 * @return True if check is OK, False otherwise
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Test Context
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_tc See the related online help
 */
function TestContext(
  nid in number)
return boolean;

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
/*#
 * Counts the number of responses for a specified result code.
 * @param Gid Notification Group ID
 * @param ResultCode Result code to be tallied
 * @param ResultCount Vote Count
 * @param PercentOfTotalPop Percent of total population
 * @param PercentOfVotes Percent of votes cast
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Vote Count
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_votec See the related online help
 */
procedure VoteCount (   Gid                     in  number,
                        ResultCode              in  varchar2,
                        ResultCount             out nocopy number,
                        PercentOfTotalPop       out nocopy number,
                        PercentOfVotes          out nocopy number );
--
-- OpenNotificationsExist
--      Determine if any Notifications in the Group are OPEN
--
--IN:
--      Gid -  Notification group id
--
--Returns:
--      TRUE  - if the Group contains open notifications
--      FALSE - if the group does NOT contain open notifications
--
/*#
 * Returns 'TRUE' if any notification associated with the specified notification
 * group ID is 'OPEN', otherwise it returns 'FALSE'.
 * @param Gid Notification Group ID
 * @return Notification Open Status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Open Notifications Exist
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_opennt See the related online help
 */
function OpenNotificationsExist( Gid    in Number ) return Boolean;

--
-- WorkCount
--   Count number of open notifications for user
-- IN:
--   username - user to check
-- RETURNS:
--   Number of open notifications for that user
--
/*#
 * Returns the number of open notifications assigned to a role.
 * @param username Recipient Role
 * @return Open Notification Count
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Work Count
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_wct See the related online help
 */
function WorkCount(
  username in varchar2)
return number;

--
-- Close
--   Close a notification.
-- IN:
--   nid - Notification Id
--   resp - Respond Required?  0 - No, 1 - Yes
--   responder - User or role close this notification
--
/*#
 * Closes a notification.
 * @param nid Notification ID
 * @param responder Role performing close
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Close Notification
 * @rep:compatibility S
 * @rep:businessevent oracle.apps.wf.notification.close
 * @rep:ihelp FND/@notif_api#a_close See the related online help
 */
procedure Close(nid in number,
                responder in varchar2 default null);

-- GetSubSubjectDisplay
--   Get the design subject of a notification and Substitute tokens in text
--   with the display name of the attributes in the subject.
--   This is used in routing rule poplists
-- IN:
--   message_type - Item type of the message
--   message_name - Name of the message to substitute
--
function GetSubSubjectDisplay(message_type IN VARCHAR2, message_name IN VARCHAR2)
return varchar2;

-- GetSubSubjectDisplayShort
--   Get the design subject of a notification and Substitute tokens in text
--   with ellipsis (...)
--   This is used in routing rule poplists on the Web screens
-- IN:
--   message_type - Item type of the message
--   message_name - Name of the message to substitute
--
function GetSubSubjectDisplayShort(message_type IN VARCHAR2, message_name IN VARCHAR2)
return varchar2;

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
                       disptype in varchar2 default 'text/plain');

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
                              disptype in varchar2 default 'text/plain');

--Name WriteToClob (PUBLIC)
/*#
 * Appends a character string to the end of a character large object
 * (CLOB). You can use this procedure to help build the CLOB for a
 * PL/SQL CLOB document attribute for a notification.
 * @param clob_loc CLOB Locator
 * @param msg_string Message string to append
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Write to CLOB
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_wrtclob See the related online help
 */
procedure WriteToClob  ( clob_loc      in out nocopy clob,
                         msg_string    in  varchar2);

--
-- GetAttrClob
--   Get the displayed value of a PLSQLCLOB DOCUMENT-type attribute.
--   Returns referenced document in format requested.
--   Use GetAttrText to get retrieve the actual attr value (i.e. the
--   document key string instead of the actual document).
-- NOTE:
--   Only PLSQL document type is implemented.
-- IN:
--   nid      - Notification id
--   astring  - the string to substitute on (ex: '&ATTR1 is your order..')
--   disptype - Requested display type.  Valid values:
--               wf_notification.doc_text - 'text/plain'
--               wf_notification.doc_html - 'text/html'
--   document - The clob into which
--   aname    - Attribute Name (the first part of the string that matches
--              the attr list)
--
procedure GetAttrClob(
  nid       in number,
  astring   in varchar2,
  disptype  in varchar2,
  document  in out nocopy clob,
  aname     out nocopy varchar2);

--
-- GetAttrClob
--   Get the displayed value of a PLSQLCLOB DOCUMENT-type attribute.
--   Returns referenced document in format requested.
--   Use GetAttrText to get retrieve the actual attr value (i.e. the
--   document key string instead of the actual document).
--   The document type of the PLSQLCLOB document is returned from the
--   user-defined API
-- NOTE:
--   Only PLSQL document type is implemented.
-- IN:
--   nid      - Notification id
--   astring  - the string to substitute on (ex: '&ATTR1 is your order..')
--   disptype - Requested display type.  Valid values:
--               wf_notification.doc_text - 'text/plain'
--               wf_notification.doc_html - 'text/html'
--   document - Th clob into which
--   aname    - Attribute Name (the first part of the string that matches
--              the attr list)
--
procedure GetAttrClob(
  nid       in  number,
  astring   in  varchar2,
  disptype  in  varchar2,
  document  in  out nocopy clob,
  doctype   out nocopy varchar2,
  aname     out nocopy varchar2);

--Name Read_Clob
--reads a specific clob in 32K chunks. Call this repeatedly until
--end_of_clob is true.
procedure read_clob (line out nocopy varchar2 ,
                     end_of_clob in out nocopy boolean);

-- Name: NewClob
-- Creates a new record in the temp table with a clob
-- this is necessary because clobs cannot reside in plsql
-- but must be part of a table.
procedure NewClob  (clobloc       in out nocopy clob,
                    msg_string    in  varchar2);


--Name ReadAttrClob (PUBLIC)
--Desc : Gets full text of a PLSQLCLOB variable
--       and returns the 32K chunks in the doctext out variable.
--       Call this repeatedly until end_of_text is true.
--USE :  use this to get the value of idividual PLSQLCLOBs such as attachments.
--       to susbtitute a PLSQLSQL clob into a message body, use GetFullBody
procedure ReadAttrClob(nid in number,
                       aname in varchar2,
                       doctext in out nocopy varchar2,
                       end_of_text in out nocopy boolean);

--variable used in clob manipulation
last_nid       pls_integer;
last_disptype  varchar(30);
clob_exists    pls_integer;
clob_chunk     pls_integer:=0;
temp_clob      clob;


--
-- Denormalization of Notifications
--

--
-- GetSessionLanguage (PRIVATE)
--   Try to return the cached session language value.
--   If it is not cached yet, call the real query function.
--
function GetSessionLanguage
return varchar2;

--
-- GetNLSLanguage (PRIVATE)
--   Get the NLS Lanugage setting of current session
--   Try to cached the value for future use.
-- NOTE:
--   Because it tried to use cached values first.  The subsequent calls
-- will give you the cached values instead of the current value.
--
procedure GetNLSLanguage(language  out nocopy varchar2,
                         territory out nocopy varchar2,
                         charset   out nocopy varchar2);

--
-- Denormalize_Notification
--   Populate the donormalized value to WF_NOTIFICATIONS table according
-- to the language setting of username provided.
-- IN:
--   nid - Notification id
--   username - optional role name, if not provided, use the
--              recipient_role of the notification.
--   langcode - language code
--
-- NOTE: username has precedence over langcode.  Either username or
--       langcode is needed.
--
/*#
 * Stores denormalized values for certain notification fields, including the
 * notification subject, in the WF_NOTIFICATIONS table. If you are using
 * the Notification System to send a notification outside of a workflow
 * process, you must call Denormalize_Notification() after setting the values
 * for any notification attributes, in order to populate the denormalized
 * fields. This procedure tests whether the language in which the notification
 * should be delivered matches the current session language, and stores the
 * denormalized information according to this setting only if the languages match.
 * @param nid Notification ID
 * @param username Recipient Role
 * @param langcode Language Code
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Denormalize Notification
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_dnrm See the related online help
 */
procedure Denormalize_Notification(nid      in number,
                                   username in varchar2 default null,
                                   langcode in varchar2 default null);

--
-- NtfSignRequirementsMet
--   Checks if the notification's singature requirements are met
-- IN
--   nid - notification id
-- OUT
--   true - if the ntf is signed
--   false - if the ntf is not signed
--
/*#
 * Returns 'TRUE' if the response to a notification meets the signature
 * requirements imposed by the electronic signature policy for the
 * notification.
 * @param nid Notification ID
 * @return Signature Status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Notification Signature Requirements Met
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_signmet See the related online help
 */
function NtfSignRequirementsMet(nid in number)
return boolean;

--
-- Request More Info
--

--
-- UpdateInfo
--   non-null username: Ask this user for more information
--   null username: Reply to the inquery
--   comment could be question or answer
-- IN
--   nid - Notification Id
--   username - User to whom the comment is intended
--   comment - Comment text
--   wl_user - Worklist user to whom the notfication belongs, in case a proxy is acting
--   action_source - Source from where the call is made. Could be null or 'WA'
--
procedure UpdateInfo(nid      in number,
                     username in varchar2 default null,
                     comment  in varchar2 default null,
                     wl_user  in varchar2 default null,
                     action_source in varchar2 default null,
                     cnt      in number default 0);

--
-- Transfer Request Information
--

--
-- TransferMoreInfo
-- NOTE:
--   This API is used to Transfer Request More Information notification.
-- 	 A Recipient or a Workflow Admin can transfer Request More Info Notification
--   to any other user.
-- IN
--   p_nid - Notification Id
--   p_new_user - User to whom the Question is Transferred
--   p_comment - Comment text while Transfer Request MorInformation
--   p_p_wl_user - Worklist user to whom the notfication belongs, in case a proxy is acting
--   p_action_source - Source from where the call is made. Could be null or 'WA'
--	 p_count - Count used for recursive calls when there are vacation rules set recursively
--	 p_routing_rule_user - User for which Routing rule is present.
--
procedure TransferMoreInfo(p_nid      in number,
						p_new_user in varchar2 default null,
						p_comment  in varchar2 default null,
						p_wl_user  in varchar2 default null,
						p_action_source in varchar2 default null,
						p_count      in number default 0,
						p_routing_rule_user in varchar2 default null);

--
-- Route Request Information
--

--
-- RouteMoreInfo
-- This API checks whether there is any Routing rule defined for a user
-- and transfers the Request More Information if there is one by calling
-- TransferMoreInfo API recursively.
-- IN
--   p_nid - Notification Id
--   p_wl_user - Worklist user to whom the notfication belongs, in case a proxy is acting
--   p_action_source - Source from where the call is made. Could be null or 'WA'
--	 p_count - Count used for recursive calls when there are vacation rules set recursively
--
procedure RouteMoreInfo(p_nid      in number,
					p_wl_user  in varchar2, -- Logged in User (Can be a proxy user too)
					p_action_source in varchar2,
                    p_count      in number);

--
-- IsValidInfoRole
--   Check to see if a role is a participant so far
function IsValidInfoRole(nid      in number,
                         username in varchar2)
return boolean;

--
-- More Info mailer support - bug 2282139
--
-- UpdateInfo2 - Called from mailer
--   non-null username - Ask this user for more information
--   null username - Reply to the inquery
--   from email - From email id of responder/requestor
--   comment - could be question or answer
--
procedure UpdateInfo2(nid        in number,
                     username   in varchar2 default null,
                     from_email in varchar2 default null,
                     comment    in varchar2 default null);

-- UpdateInfoGuest - Called for updating more info when access
--                   key is present
--   responder - Sesson user responding to More info request
--   moreinfoanswer - could be question or answer
--
procedure UpdateInfoGuest(nid                in number,
                          moreinforesponder  in varchar2 default null,
                          moreinfoanswer     in varchar2 default null);

--
-- HideMoreInfo
--   Checks the notification attribute #HIDE_MOREINFO to see if the
--   More Information request button is allowed or hidden. Just in case
--   more_info_role becomes not null with direct table update...
function HideMoreInfo(nid in number) return varchar2;

--
-- GetComments
--   Consolidates the questions and answers asked for the notification.
--   Also returns the last question asked
--   This is for the mailer to send the history with the email.
procedure GetComments(nid          in  number,
                      display_type in  varchar2,
                      html_history out nocopy varchar2,
                      last_ques    out nocopy varchar2);

-- bug 2581129
-- GetSubject
--   Get subject of notification message with token values substituted
--   from notification attributes. Overloaded to have display type
-- IN
--   nid - Notification Id
--   disptype - Display Type
-- RETURNS
--   Substituted message subject
-- NOTE
--   If errors are detected this routine returns the subject unsubstituted,
--   or null if all else fails, instead of raising exceptions.
--
function GetSubject(nid      in number,
                    disptype in varchar2)
return varchar2;
--pragma restrict_references(GetSubject, WNDS);

--
-- GetAttrBlob
--   Get the displayed value of a PLSQLBLOB DOCUMENT-type attribute.
--   Returns referenced document in format requested.
--   Use GetAttrText to get retrieve the actual attr value (i.e. the
--   document key string instead of the actual document).
-- NOTE:
--   Only PLSQL document type is implemented.
-- IN:
--   nid      - Notification id
--   astring  - the string to substitute on (ex: '&ATTR1 is your order..')
--   disptype - Requested display type.  Valid values:
--               wf_notification.doc_text - 'text/plain'
--               wf_notification.doc_html - 'text/html'
--   document - The blob into which
--   aname    - Attribute Name (the first part of the string that matches
--              the attr list)
--
procedure GetAttrBlob(
  nid       in number,
  astring   in varchar2,
  disptype  in varchar2,
  document  in out nocopy blob,
  aname     out nocopy varchar2);

--
-- GetAttrBlob
--   Get the displayed value of a PLSQLBLOB DOCUMENT-type attribute.
--   Returns referenced document in format requested.
--   Use GetAttrText to get retrieve the actual attr value (i.e. the
--   document key string instead of the actual document).
--   The document type of the PLSQLBLOB document is returned from the
--   user-defined API
-- NOTE:
--   Only PLSQL document type is implemented.
-- IN:
--   nid      - Notification id
--   astring  - the string to substitute on (ex: '&ATTR1 is your order..')
--   disptype - Requested display type.  Valid values:
--               wf_notification.doc_text - 'text/plain'
--               wf_notification.doc_html - 'text/html'
--   document - Th blob into which
--   aname    - Attribute Name (the first part of the string that matches
--              the attr list)
--
procedure GetAttrBlob(
  nid       in  number,
  astring   in  varchar2,
  disptype  in  varchar2,
  document  in  out nocopy blob,
  doctype   out nocopy varchar2,
  aname     out nocopy varchar2);

--
-- Set_NTF_Table_Direction
-- Sets the default direction of notification tables
-- generated through wf_notification.wf_ntf_history
-- and wf_notification.wf_msg_attr
procedure Set_NTF_Table_Direction(direction in varchar2);

--
-- Set_NTF_Table_Type
-- Sets the default table type for attr tables
-- generated through wf_notification.wf_msg_attr
procedure Set_NTF_Table_type(tableType in varchar2);

--
-- SubstituteSpecialChars (PUBLIC)
--   Substitutes the occurence of special characters like <, >, \, ', " etc
--   with their html codes in any arbitrary string.
-- IN
--   some_text - text to be substituted
-- RETURN
--   substituted text
/*#
 * Substitutes HTML character entity references for special characters in
 * a text string and returns the modified text including the substitutions.
 * You can use this function as a security precaution when creating a PL/SQL
 * document or a PL/SQL CLOB document that contains HTML, to ensure that only
 * the HTML code you intend to include is executed.
 * @param some_text Text string with HTML characters
 * @return String with HTML characters substituted with HTML codes
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Substitute HTML Special Characters
 * @rep:compatibility S
 * @rep:ihelp FND/@notif_api#a_subsc See the related online help
 */
function SubstituteSpecialChars(some_text in varchar2)
return varchar2;
pragma restrict_references(SubstituteSpecialChars, WNDS);



--
-- isFwkRegion
-- Verifies whether message body is embedded with framework regions
-- IN
--  nid - Notificatin ID
-- RETURN
--  'Y' or 'N'
function isFwkRegion(nid in number) return varchar2;

--
-- isFwkRegion
-- Overridden for bug 5456241: Default doc type is text/html
-- Verifies whether message body is embedded with framework regions
-- IN
--  nid - Notificatin ID
--  content_type display type (text/plain or text/html)
-- RETURN
--  'Y' or 'N'
function isFwkRegion(nid in number, content_type in varchar2 ) return varchar2;

--
-- isFwkBody
-- Verifies whether message body is embedded with framework regions
-- IN
--  nid - Notificatin ID
-- RETURN
--  'Y' or 'N'
function isFwkBody(nid in number) return varchar2;

-- isFwkBody :
-- Overridden for bug 5456241: Default doc type is text/html
-- Verifies whether message body is embedded with framework regions
-- IN
--  nid - Notificatin ID
--  content_type - Display Type (text/plain or text/html)
-- RETURN
--  'Y' or 'N'

function isFwkBody(nid in number, content_type in varchar2) return varchar2;

--
-- fwkTokenExist
-- Checks if any notification attribute exist in given message body,
-- is of type DOCUMENT and its value starts with 'JSP:/OA_HTML/OA.jsp?';
--
-- IN
--  nid - Notification ID
--  msgbody - Notification Message body
-- RETURN
--  'Y' or 'N'
--
function fwkTokenExist(nid in number, msgbody in varchar2) return varchar2;

--
-- getNtfActInfo
-- Fetches Itemtype, itemkey, activity id of a notification
-- IN
--  nid - Notification ID
-- OUT
--  l_itype Itemtype of the notification activity
--  l_itype Itemkey of the process part of which the notification was sent
--  l_actid Activity ID of the Notification Activity in the process

procedure getNtfActInfo (nid     in  number,
                         l_itype out nocopy varchar2,
                         l_ikey  out nocopy varchar2,
                         l_actid out nocopy number);

--
-- GetAttrDoc2
--   Get the displayed value of a DOCUMENT-type attribute.
--   Returns referenced document in format requested along with the
--   document type specified by the user.
-- NOTE:
--   Only PLSQL document type is implemented.
--   This procedure wraps the  original implementation and the function
--   GetAttrDoc will call this procedure.
-- IN:
--   nid      - Notification id
--   aname    - Attribute Name
--   disptype - Requested display type.  Valid values:
--               'text/plain' - plain text
--               'text/html' - html
--               '' - attachment(?)
-- RETURNS:
--   Referenced document in format requested.
--   Document type specified by the user
--

procedure GetAttrDoc2(
   nid      in number,
   aname    in varchar2,
   disptype in varchar2,
   document out nocopy varchar2,
   doctype  out nocopy varchar2);

--
-- getFwkBodyURL
--   This API returns a URL to access notification body with
--   Framework content embedded
-- IN:
--   nid      - Notification id
--   disptype - Requested display type.  Valid values:
--               'text/plain' - plain text
--               'text/html' - html
-- RETURNS:
--   Returns the URL returned by call to getFwkBodyURLLang
--

function getFwkBodyURL( nid in number,
                        contenttype varchar2 ) return varchar2;

--
-- getFwkBodyURLLang
--   This API returns a URL to access notification body with
--   Framework content embedded.
-- IN:
--   nid      - Notification id
--   disptype - Requested display type.  Valid values:
--               'text/plain' - plain text
--               'text/html' - html
-- RETURNS:
--   Returns the URL to access the notification detail body
--

function getFwkBodyURLLang( nid in number,
                            contenttype varchar2,
                            language varchar2) return varchar2;


--
-- getFwkBodyURL
--   This API returns a URL to access notification body with
--   Framework content embedded.
-- IN:
--   p_nid      - Notification id
--   p_contenttype - Requested display type.  Valid values:
--                 'text/plain' - plain text
--                 'text/html' - html,
--   p_language     language value of that notification / user
--   p_nlsCalendar  nls calender of that user
--
-- RETURNS:
--   Returns the URL to access the notification detail body
--

function getFwkBodyURL2( p_nid in number,
                         p_contenttype varchar2,
                         p_language varchar2,
                         p_nlsCalendar varchar2) return varchar2;


--
-- getSummaryURL
--   This API returns a URL to access summary of notiifications
--
-- IN:
--   mailer_role  - role for which summary of notifications required
--   disptype     - Requested display type.  Valid values:
--               'text/plain' - plain text
--               'text/html' - html
-- RETURNS:
--   Returns the URL to access the summary of notiification for the role
--

function getSummaryURL( mailer_role varchar2,
                        contenttype varchar2 ) return varchar2;



-- getSummaryURL
--   This API returns a URL to access summary of notiifications
--
-- IN:
--   p_mailer_role   - role for which summary of notifications required
--   p_contentType   - Requested display type.  Valid values:
--                   'text/plain' - plain text
--                   'text/html' - html
--   p_nlsCalendar   - nls Calender of that role / user
--
-- RETURNS:
--   Returns the URL to access the summary of notiification for the role
--

function getSummaryURL2( p_mailer_role IN varchar2,
                         p_contentType IN varchar2,
                         p_nlsCalendar IN varchar2) return varchar2;


-- GetSignatureRequired
-- Determine signing requirements for a policy
-- IN:
--   nid - Notification id - used for error context only
--   p_sig_policy - Policy Name
-- OUT:
--   p_sig_required - Y/N
--   p_fwk_sig_flavor - sigFlavor for browser signing.
--   p_email_sig_flavor - sigFlavor for email
--   p_render_hint - hints like ATTR_ONLY or FULL_TEXT

procedure GetSignatureRequired(p_sig_policy in varchar2,
     p_nid in number,
     p_sig_required out nocopy varchar2,
     p_fwk_sig_flavor out nocopy varchar2,
     p_email_sig_flavor out nocopy varchar2,
     p_render_hint out nocopy varchar2);

-- SetUIErrorMessage
-- API for Enhanced error handling for OAFwk UI Bug#2845488 grengara
-- This procedure can be used for handling exceptions gracefully when dynamic SQL is invloved

procedure SetUIErrorMessage;

--
-- GetComments2
--   Creates the Action History table for a given a notification id based on
--   different filter criteria.
-- IN
--   p_nid - Notification id
--   p_display_type - Display Type
--   p_action_type - Action Type to look for (REASSIGN, RESPOND, QA,...)
--   p_comment_date - Comment Date
--   p_from_role - Comment provider
--   p_to_role - Comment receiver
--   p_hide_reassign - If Reassign comments be shown or not
--   p_hide_requestinfo - If More Info request be shown or not
-- OUT
--   p_action_history - Action History table
--
procedure GetComments2(p_nid              in  number,
                       p_display_type     in  varchar2 default '',
                       p_action_type      in  varchar2 default null,
                       p_comment_date     in  date     default null,
                       p_from_role        in  varchar2 default null,
                       p_to_role          in  varchar2 default null,
                       p_hide_reassign    in  varchar2 default 'N',
                       p_hide_requestinfo in  varchar2 default 'N',
                       p_action_history   out nocopy varchar2);
--
-- SetComments
--   Private procedure that is used to store a comment record into WF_COMMENTS
--   table with the denormalized information. A record is inserted for every
--   action performed on a notification.
-- IN
--   p_nid - Notification Id
--   p_from_role - Internal Name of the comment provider
--   p_to_role - Internal Name of the comment recipient
--   p_action - Action performed
--   p_action_source - Source from where the action is performed
--   p_user_comment - Comment Text
--
procedure SetComments(p_nid           in number,
                      p_from_role     in varchar2,
                      p_to_role       in varchar2,
                      p_action        in varchar2,
                      p_action_source in varchar2,
                      p_user_comment  in varchar2);

--
-- Resend
--   Private procedure to resend a notification given the notification id. This
--   procedure checks the mail status and recipient's notification preference to
--   see if it is eligible to send e-mail.
-- IN
--   p_nid - Notification Id
--
procedure Resend(p_nid in number);

--
-- getNtfResponse
-- Fetches result(response) CODE and response display prompt to the notification
-- IN
--  p_nid - Notification ID
-- OUT
--  p_result_code    Result code of the notification
--  p_result_display Display value of the result code

procedure getNtfResponse (p_nid     in  number,
                          p_result_code out nocopy varchar2,
                          p_result_display  out nocopy varchar2);

--
-- SetNLSLanguage (PRIVATE)
--   Set the NLS Lanugage setting of current session
--
procedure SetNLSLanguage(p_language  in varchar2,
                         p_territory in varchar2);

--
-- PropagateHistory (PUBLIC)
--  This API allows Product Teams to publish custom action
--  to WF_COMMENTS table.
--
procedure propagatehistory(p_item_type     in varchar2,
                           p_item_key      in varchar2,
                           p_document_id   in varchar2,
                           p_from_role     in varchar2,
                           p_to_role       in varchar2,
                           p_action        in varchar2,
                           p_action_source in varchar2,
                           p_user_comment  in varchar2) ;

--
-- Resend_Failed_Error_Ntfs (CONCURRENT PROGRAM API)
--   API to re-enqueue notifications with mail_status FAILED and UNAVAIL in order
--   to re-send them. Mailer had processed these notifications earlier and updated
--   the status since these notifications could not be delivered/processed.
--
-- OUT
--   errbuf  - CP error message
--   retcode - CP return code (0 = success, 1 = warning, 2 = error)
-- IN
--   p_mail_status - Mail status that needs to be resent.
--                   ERROR - Only for FYI notifications
--                   FAILED - All notifications
--   p_msg_type - Message type of the notification
--   p_role     - Workflow role whose notifications are to be re-enqueued
--
--   p_from_date - Notification has been sent on or after this date
--   p_to_date   - Notification has been sent on before this date
--               - Type is varchar2 because CP reports problems with Date type
--
procedure Resend_Failed_Error_Ntfs(errbuf        out nocopy varchar2,
                                   retcode       out nocopy varchar2,
                                   p_mail_status in varchar2 default null,
                                   p_msg_type    in varchar2 default null,
                                   p_role        in varchar2 default null,
				   p_from_date   in varchar2 default null,
				   p_to_date     in varchar2 default null);

-- Denormalize Custom Columns
procedure denormalizeColsConcurrent(retcode      out nocopy varchar2,
  			            errbuf       out nocopy varchar2,
			            p_item_type  in varchar2,
			            p_status     in varchar2,
    			            p_recipient  in varchar2);

--
-- GetText2 (INTERNAL ONLY)
--   This procedure is same as GetText above. Only difference is, this provides
--   a flag to suppress substitution of DOCUMENT type tokens in the text. This
--   is created for internal purposes only to substitute tokens within the
--   PLSQL DOCUMENT attribute's value. We don't support DOCUMENT type tokens
--   within a DOCUMENT type attribute.
-- IN:
--   some_text - Text to be substituted
--   nid - Notification id of notification to use for token values
--   disptype - Display type ('text/plain', 'text/html', '')
--   sub_doc - Substitute DOCUMENT type tokens (true, false)
-- RETURNS:
--   Some_text with tokens substituted.
--
function GetText2(some_text in varchar2,
                  nid       in number,
                  disptype  in varchar2 default '',
                  sub_doc   in boolean default true)
return varchar2;


--
-- isFYINtf (INTERNAL ONLY)
--   This function checks whether a notification is FYI or Response Required notification.
-- IN:
--   nid - Notification id to be checked
-- RETURNS:
--   boolean value true | false.
--
function isFYI(nid   in number)  return boolean;

--
-- Respond2
--   ER 10177347: Process the response to the notification when the performer
--   applies the response from worklist in deferred mode. It has the same
--   functionality as that of the respond() API except that it does not
--   call Complete procedure to complete the notification activity.
-- IN
--   nid Notification ID
--   respond_comment Respond Comment
--   responder Performer who responded to the notification
--   action_source For Internal Use Only
--   response_found boolean value that tells whether respond attributes exists or not
procedure Respond2(nid            in  number,
                  respond_comment in  varchar2 default null,
                  responder       in  varchar2 default null,
                  action_source   in  varchar2 default null,
                  response_found  out nocopy boolean);

--
--
-- process_response
--   ER 10177347: Determines that the notification response has to be
--   processed in synschronous mode or defer mode, calls the respond()
--   or respond2() API and enqueues the event into WF_NOTIFICATION_IN queue
--   accordingly based on the value of the parameter 'defer_response'
-- IN
--   nid Notification ID
--   respond_comment Respond Comment
--   responder Performer who responded to the notification
--   action_source For Internal Use Only
--   defer_response value of the profile option 'WF_NTF_DEFER_RESPONSE_PROCESS'
procedure process_response(nid       in number,
                     respond_comment in varchar2 default null,
                     responder       in varchar2 default null,
                     action_source   in varchar2 default null,
                     defer_response  in varchar2 default null);


--
-- Complete
--   ER 10177347: This procedure executes the callback function in
--   COMPLETE mode to comeplete the notification activity
-- IN
--   p_nid Notification ID
procedure Complete(p_nid in number);

-- This procedure raises a business event to send Push Notifications.
-- The event is raised only for Item Types and Messages configured
-- for Approvals Data Services i.e., Item Types and Messages present
-- in table wf_wl_config_types
-- IN
-- p_recipient_role - Role to send notification to
-- p_msg_type - Message type
-- p_msg_name - Message name
-- p_nid - Notification ID
-- p_is_more_info - Is More Info Request?

procedure RaisePushNotificationEvent(p_recipient_role in varchar2,
                                     p_msg_type       in varchar2,
                                     p_msg_name       in varchar2,
                                     p_nid            in number,
                                     p_is_more_info   in boolean default false);


END WF_Notification;

/
