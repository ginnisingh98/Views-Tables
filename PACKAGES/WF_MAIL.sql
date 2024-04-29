--------------------------------------------------------
--  DDL for Package WF_MAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_MAIL" AUTHID CURRENT_USER as
/* $Header: wfmlrs.pls 120.12.12010000.2 2010/12/24 09:11:44 skandepu ship $ */
/*#
 * Provides APIs to access the Oracle Workflow message subsystem and send messages through e-mail.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Message Subsystem
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY WF_NOTIFICATION
 * @rep:compatibility S
 */
--
-- Global table to store the url content.
--
type url_content_array is table of varchar2(2000) index by binary_integer;
content_array url_content_array;

-- bug 2437782
-- record type to store the response attribute information
TYPE resp_attr_rec IS RECORD
(
   attr_prompt  varchar2(80),
   attr_type    varchar2(8),
   attr_name    varchar2(30),
   attr_format  varchar2(240)
);

TYPE resp_attrs_t IS TABLE OF resp_attr_rec INDEX BY BINARY_INTEGER;

-- Test flag. Internal use only
test_flag boolean := FALSE;

--
-- E-mail notification recipient record
--  Name - Name of the recipient
--  Address - Valid e-mail address
--  Recipient_Type - TO or CC or BCC
TYPE wf_recipient_rec_t IS RECORD
(
   NAME     VARCHAR2(360),
   ADDRESS  VARCHAR2(320),
   RECIPIENT_TYPE VARCHAR2(4)
);



-- Global variable to hold a static stylesheet definition
g_newLine varchar2(1) := wf_core.newLine;
g_template_style varchar2(32000) :=
               'body,html,td, p { top-margin:0; padding:0; font-family:Tahoma; font-size:9pt; color:#3c3c3c; }'||g_newline||
               'H2.OraHeader{ color:#343434; padding:0px 0px 0px 0px; font-family:Arial; font-weight:bold; font-size:9pt; vertical-align:middle; }'||g_newline||
               '.OraHeaderSub,.x3w {margin-bottom:0px;color:#426ca7;font-family:Arial;font-weight:bold;font-size:92%;vertical-align:middle;border-bottom:1px solid #aabed5;margin:5px 0px 0px 0px}'||g_newline||
               '.OraHeaderBar,.x6z {color:#3c3c3c;font-family:Tahoma,Arial,Helvetica,Geneva,sans-serif;background-repeat:repeat-x;padding:0px 0px 0px 8px;font-weight:bold;font-size:8pt;vertical-align:middle;'||
	       'border-style:solid;border-width:1px 1px 1px 1px;border-color:#a3bed8;margin-top:5px;margin-bottom:0px}'||g_newline||
               '.OraLink:link,.xd:link,.OraLink:active,.xd:active,.OraLink:visited,.xd:visited,.OraBulletedList A,.xj A,.OraCopyright A,.xv A,'||
               '.OraPrivacy A,.xw A,.OraAbout A,.xx A,.OraLinkText,.x2v,.OraVLinkText,.x2w,.OraALinkText,.x2x,.OraHGridNavRowActiveLink,.x3u,.OraShuttleLinkText,.x4a,.OraSubTab A,.x4h A,.p_OraTreeRow A:link,.x5c A:link,'||
               '.p_OraTreeRow A:active,.x5c A:active,.p_OraTreeRow A:visited,.x5c A:visited {font-family:Tahoma,Arial,Helvetica,Geneva,sans-serif;font-size:x-small;color:#2da0cb}'||g_newline||
               '.OraContentContainerHeader,.xp {background-color:#d6f5ff;margin:5px 0px 0px 0px;padding:0px 0px 0px 8px;font-weight:bold;font-size:8pt;vertical-align:middle;border-bottom:1px solid #aabed5;'||
	       'margin-top:5px;margin-bottom:0px;font-family:Tahoma;color:#343434}'||g_newline||
               '.OraTipLabel,.x55 {font-family:Tahoma,Arial,Helvetica,Geneva,sans-serif;font-weight:bold;color:#426ca7;font-size:8pt}'||
               '.OraTipText,.x56 {font-family:Tahoma,Arial,Helvetica,Geneva,sans-serif;color:#3a5a87;font-size:8pt}'||g_newline||
               '.OraTableColumnHeader, .x1r, .OraTableRowHeader, .x1u { text-align:left;vertical-align:bottom;font-family:Tahoma,Arial,Helvetica,Geneva,'||
               'sans-serif;font-weight:bold;background-color:#cfe0f1;color:#3c3c3c;border-color:#c9cbd3;font-size:8pt }'||g_newline||
               '.OraTableCellText, .x1l { color:#3c3c3c;vertical-align:baseline;font-family:Tahoma,Arial,Helvetica,Geneva,sans-serif;border-color:#c9cbd3;font-size:9pt;background-color:#f2f2f5 }'||g_newline||
               '.OraTableContent,.x1h {border-color:#c9cbd3;border-style:solid;border-width:1px;border-collapse:collapse}'||g_newline||
               '.OraTableHeaderLink,.x24 {text-decoration:none;text-align:left;vertical-align:bottom;font-family:Tahoma,Arial,Helvetica,Geneva,sans-serif;font-weight:bold;background-color:#cfe0f1;'||
	       'color:#3c3c3c;border-color:#c9cbd3;font-size:8pt}'||g_newline||
               '.OraInstructionTextStrong,.x1,.OraDataText,.x2 {font-family:Tahoma,Arial,Helvetica,Geneva,sans-serif;font-size:x-small;font-weight:bold;color:#3c3c3c} '||g_newline||
               '.OraPromptText,.x8 {font-family:Tahoma,Arial,Helvetica,Geneva,sans-serif;font-size:8pt;text-align:right;color:#000000;font-weight:normal} '||g_newline||
               '.OraTableBorder0001,.x4j {border-style:solid;border-width:0px 0px 0px 1px}'||g_newline||
               '.OraTableBorder1000,.x4q {border-style:solid;border-width:1px 0px 0px}'||g_newline||
               '.OraTableBorder1111,.x4x {border-style:solid;border-width:1px}';

-- Defining explicit formatting values for whatever output that requires it
-- Header attributes
g_th_bgcolor varchar2(7) := '#cfe0f1';
g_th_fontcolor varchar2(7) := '#3c3c3c';
g_th_fontface varchar2(80) := 'Tahoma, Arial, Helvetica, Geneva, sans-serif';
g_th_fontsize varchar2(2) := '2';

-- Cell attributes
g_td_bgcolor varchar2(7) := '#f2f2f5';
g_td_fontcolor varchar2(7) := '#3c3c3c';
g_td_fontface varchar2(80) := 'Tahoma, Arial, Helvetica, Geneva, sans-serif';
g_td_fontsize varchar2(2) := '2';

-- Table of recipient record
TYPE wf_recipient_list_t IS TABLE OF wf_recipient_rec_t INDEX BY BINARY_INTEGER;

-- UpdateStatus
--   Update mail status and close any notification with no response.
--   Handle error.
-- IN
--   notification id
--   status
--   error name (null if error is in WF_CORE)
procedure UpdateStatus(
    nid        in number,
    status     in varchar2,
    error_name in varchar2 default null);

-- UpdateStatus2
--   Update mail status and close any notification with no response.
--   Handle error.
-- IN
--   nid notification id
--   status Status to set the notification
--   autoclose Flag to specify whether the notification should be closed
--             automitically
--   error name (null if error is in WF_CORE)
--   external_error Any error message that can not be reflected or captured
--                  through the wf_core.context facilty ie Java.
procedure UpdateStatus2(
    nid        in number,
    status     in varchar2,
    autoclose  in varchar2,
    error_name in varchar2 default null,
    external_error in varchar2 default null);

-- ResetFailed
--   Update mail status from FAILED to MAIL.
-- IN
--   Queue number
procedure ResetFailed(p_queue varchar2 default '1');

-- HandleSendError
--   Call any callback in error mode if error occurs in sending mail.
-- IN
--   notification id
--   error name (null if error is in WF_CORE)
--   external_error Any error message that can not be reflected or captured
--                  through the wf_core.context facilty ie Java.
procedure HandleSendError(
    nid        in number,
    status     in varchar2,
    error_name in varchar2 default null,
    external_error in varchar2 default null);


-- UpdateRecipient
--    Updates the recipient of a notification to DISABLED where
--    there has been a failure to deliver to their email address.
--    This function is triggered by the oracle.apps.wf.notification.send.failure
--    event.
function Disable_Recipient_Ntf_Pref(p_subscription_guid in raw,
                     p_event in out NOCOPY WF_EVENT_T) return varchar2;

-- HandleResponseError (PRIVATE) handle exception in response
--
--   Sets the MAIL_ERROR error message attribute, then sets the
--   notification status to INVALID.
--
-- IN
--   notification id
--   lookup type
--   value found

procedure HandleResponseError(nid in number,
                              lk_type in varchar2,
                              lk_meaning in varchar2,
                              error_result in out NOCOPY varchar2);


-- WordWrap (PRIVATE)
--   Insert newlines to word wrap a line buffer.
-- Inputs:
--   text - text buffer
--   indent - number of tabs to indent each line by
-- Returns:
--   buffer contents with newlines and tabs embedded
function WordWrap(
  text in varchar2,
  indent in number default 0) return varchar2;

-- GetWarning - get warning messages
--
-- IN
--   Template
--   unsolicited from
--   unsolicited subject
--   unsolicited body
-- OUT
--   message subject
--   message body (text)
--   message body (html)
procedure GetWarning(
    template  in  varchar2,
    ufrom     in  varchar2,
    usubject  in  varchar2,
    ubody     in varchar2,
    subject   out NOCOPY varchar2,
    text_body_text out NOCOPY varchar2,
    html_body_text out NOCOPY varchar2) ;

-- GetWarning - get warning messages
--
-- IN
--   unsolicited from
--   unsolicited subject
--   unsolicited body
-- OUT
--   message subject
--   message body (text)
--   message body (html)
procedure GetWarning(
    ufrom     in  varchar2,
    usubject  in  varchar2,
    ubody     in varchar2,
    subject   out NOCOPY varchar2,
    text_body_text out NOCOPY varchar2,
    html_body_text out NOCOPY varchar2) ;

-- GetSummary - get summary messages for one role
-- where the summary body can be a LOB
-- Bug# 2358498
--
-- IN
--   role name
--   role display name
--   mailer node name
-- OUT
--   message subject
--   message body (text)
--   message body (html)
--   lob (Y or N)
procedure GetSummary(
    role      in  varchar2,
    dname     in  varchar2,
    node      in  varchar2,
    subject   out NOCOPY varchar2,
    body_text out NOCOPY varchar2,
    lob       out NOCOPY varchar2);

-- GetSummary - get summary messages for one role
--
-- IN
--   role name
--   role display name
--   mailer node name
-- OUT
--   message subject
--   message body (text)
--   message body (html)
procedure GetSummary(
    role      in  varchar2,
    dname     in  varchar2,
    node      in  varchar2,
    subject   out NOCOPY varchar2,
    body_text out NOCOPY varchar2);

-- GetSummary2 - get summary messages for one role
-- Support the render flag for Applications Framework.
-- If set, no body will be rendered as it will be
-- deferred to the middle tier.
-- IN
--   role name
--   role display name
--   mailer node name
--   content type
-- OUT
--   message subject
--   message body (text)
--   message body (html)
--   lob (Y or N)
procedure GetSummary2(
    role      in  varchar2,
    dname     in  varchar2,
    node      in  varchar2,
    renderBody in varchar2,
    contType   in varchar2,
    subject   out NOCOPY varchar2,
    body_text out NOCOPY varchar2,
    lob       out NOCOPY varchar2);

-- GetMessage - get email message data
--
-- IN
--   notification id
--   mailer node name
--   web agent path
--   Replyto Address
--   DIRECT_RESPONSE Flag
-- OUT
--   message subject
--   message body (text)
--   message body (html)
--   message attachments
procedure GetMessage(
    nid       in  number,
    node      in  varchar2,
    agent     in  varchar2,
    replyto   in  varchar2,
    subject   out NOCOPY varchar2,
    text_body out NOCOPY varchar2,
    html_body out NOCOPY varchar2,
    body_atth out NOCOPY varchar2,
    error_result in out NOCOPY varchar2);

--
-- setContext (PRIVATE)
--   Set the context by executing the selector function
-- IN
--   nid - Notification id
--
procedure setContext(nid NUMBER);

-- GetLOBMessage4 - get email message data
-- Bug 10202313: Added n_status, n_mstatus parameters to store the status, mail_status
-- columns of wf_notifications table
--
-- IN
--   notification id
--   mailer node name
--   web agent path
--   Replyto Address
--   recipient role
--   language
--   territory
--   notification preference
--   email address
--   display name
--   render body flag
--   notification status
--   notification mail status
-- OUT
--   message subject
--   message attachments
--   bodyToken a flag to indicate if there is a BODY token in the
--   main message template
procedure GetLOBMessage4(
    nid       in  number,
    node      in  varchar2,
    agent     in  varchar2,
    replyto   in  varchar2,
    recipient in  varchar2,
    language  in  varchar2,
    territory in  varchar2,
    ntf_pref  in varchar2,
    email     in varchar2,
    dname     in varchar2,
    renderbody in varchar2,
    subject   out NOCOPY varchar2,
    body_atth out NOCOPY varchar2,
    error_result in out NOCOPY varchar2,
    bodyToken in out NOCOPY varchar2,
    n_status in out NOCOPY varchar2,
    n_mstatus in out NOCOPY varchar2);

-- GetLOBMessage3 - get email message data
--
-- IN
--   notification id
--   mailer node name
--   web agent path
--   Replyto Address
--   recipient role
--   language
--   territory
--   notification preference
--   email address
--   display name
--   render body flag
-- OUT
--   message subject
--   message attachments
--   bodyToken a flag to indicate if there is a BODY token in the
--   main message template
procedure GetLOBMessage3(
    nid       in  number,
    node      in  varchar2,
    agent     in  varchar2,
    replyto   in  varchar2,
    recipient in  varchar2,
    language  in  varchar2,
    territory in  varchar2,
    ntf_pref  in varchar2,
    email     in varchar2,
    dname     in varchar2,
    renderbody in varchar2,
    subject   out NOCOPY varchar2,
    body_atth out NOCOPY varchar2,
    error_result in out NOCOPY varchar2,
    bodyToken in out NOCOPY varchar2);

-- GetLOBMessage2 - get email message data
--
-- IN
--   notification id
--   mailer node name
--   web agent path
--   Replyto Address
--   recipient role
--   language
--   territory
--   notification preference
--   email address
--   display name
-- OUT
--   message subject
--   message attachments
procedure GetLOBMessage2(
    nid       in  number,
    node      in  varchar2,
    agent     in  varchar2,
    replyto   in  varchar2,
    recipient in  varchar2,
    language  in  varchar2,
    territory in  varchar2,
    ntf_pref  in varchar2,
    email     in varchar2,
    dname     in varchar2,
    subject   out NOCOPY varchar2,
    body_atth out NOCOPY varchar2,
    error_result in out NOCOPY varchar2);

-- GetLOBMessage - get email message data
--
-- IN
--   notification id
--   mailer node name
--   web agent path
--   Replyto Address
--   DIRECT_RESPONSE Flag
-- OUT
--   message subject
--   message attachments
procedure GetLOBMessage(
    nid       in  number,
    node      in  varchar2,
    agent     in  varchar2,
    replyto   in  varchar2,
    subject   out NOCOPY varchar2,
    body_atth out NOCOPY varchar2,
    error_result in out NOCOPY varchar2);

-- initFetchLOB
--
-- IN
-- type - Document type (TEXT or HTML)
--
procedure InitFetchLOB(doc_type VARCHAR2 default WF_NOTIFICATION.doc_text,
                       doc_length OUT NOCOPY NUMBER);


-- FetchLOBContent
--
-- IN
-- type of document to fetch TEXT/HTML
-- End of LOB marker
-- OUT
-- 32K chunk of the LOB
--
-- Use the API in the following manner
-- WF_MAIL.InitFetchLob(WF_NOTIFICATION.doc_text)
-- while not clob_end loop
--    WF_MAIL.FetchLobContent(cBuf, WF_NOTIFICATION.doc_text, clob_end);
--    ...
-- end loop;
--
procedure FetchLOBContent(buffer OUT NOCOPY VARCHAR2,
                          doc_type IN VARCHAR2 DEFAULT WF_NOTIFICATION.doc_text,
                          end_of_clob IN OUT NOCOPY NUMBER);
-- CloseLOB - Close the message LOBs ready for use again later
--
-- IN
--    Document type
procedure CloseLOB(doc_type in VARCHAR2);

-- CloseLOB - Close the message LOBs ready for use again later
--
procedure CloseLOB;

-- FetchUrlContent - Fetched the content from the global buffer which
--                   populated by GetUrlContent().
--
-- IN
--   piece_count - the index to the url_content_array.
-- OUT
--   piece_value - the data stored in the global content_array table.
function FetchUrlContent(piece_count in number,
                         error_result in out NOCOPY varchar2) return varchar2;

-- GetUrlContent - get URL content
--
-- IN
--   url address id
-- OUT
--   piece_count
--   error result
procedure GetUrlContent(
    url          in  varchar2,
    piece_count  out NOCOPY number,
    error_result in out NOCOPY varchar2);

-- GetDocContent - get Document content
--
-- IN
--   notification id
--   document attribute name
--   display type
-- OUT
--   document content
--   error result
procedure GetDocContent(
    nid          in  number,
    docattrname  in  varchar2,
    disptype     in  varchar2,
    doccontent   out NOCOPY varchar2,
    error_result in out NOCOPY varchar2);

-- GetLOBDocContent - get LOB Document content
--
-- IN
--   notification id
--   document attribute name
--   display type
-- OUT
--   document content
--   error result
procedure GetLOBDocContent(
    nid          in  number,
    docattrname  in  varchar2,
    disptype     in  varchar2,
    error_result in out NOCOPY varchar2);

-- GetLOBDocContent - get LOB Document content
--   Returns the document type of the PLSQLCLOB document
--
-- IN
--   notification id
--   document attribute name
--   display type
-- OUT
--   document type
--   document content
--   error result
procedure GetLOBDocContent(
    nid          in  number,
    docattrname  in  varchar2,
    disptype     in  varchar2,
    doctype      out NOCOPY varchar2,
    error_result in  out NOCOPY varchar2);

-- GetLovMeaning (PRIVATE)
--   Return the displayed meaning of a lookup
-- Inputs:
--   lk_type - lookup type
--   lk_code - lookup code
-- Returns:
--   lookup meaning
function GetLovMeaning(
  lk_type in varchar2,
  lk_code in varchar2) return varchar2;

-- GetLovCode (PRIVATE) Return the hidden code of a lookup
--
-- IN
--   lookup type
--   lookup meaning
-- RETURN
--   lookup code
function GetLovCode(
    lk_type    in varchar2,
    lk_meaning in varchar2)
return varchar2;


-- PutMessage - response processing
--
-- IN
--   notification id
--   node name
--   response body
--   from address
procedure PutMessage(
    nid       in  number,
    node      in  varchar2,
    resp_body in  varchar2,
    from_addr in  varchar2,
    error_result in out NOCOPY varchar2);

-- PutDirectMessage - direct response processing
--
-- IN
--   notification id
--   node name
--   response body
--   from address
procedure PutDirectMessage(
    nid       in  number,
    node      in  varchar2,
    resp_body in  varchar2,
    from_addr in  varchar2,
    error_result in out NOCOPY varchar2);

-- More Info Feature - bug 2282139
-- PutMoreInfoRequest
--   Reply processor.  Read body of a request for more information
--   parse the body for the role to send the request to.
--   Used by the notification mail response processor.
-- IN
--   notification id
--   mailer node name
--   response body text
--   email 'from' address
procedure PutMoreInfoRequest(
    nid       in  number,
    node      in  varchar2,
    resp_body in  varchar2,
    from_addr in  varchar2,
    error_result in out NOCOPY varchar2);

-- PutMoreInfoMessage
--   Reply processor.  Read body of a reply for more information
--   request, parse the body for the comments from the user and
--   update wf_notification and wf_comments apropriately
--   Used by the notification mail response processor.
-- IN
--   notification id
--   mailer node name
--   response body text
--   email 'from' address
procedure PutMoreInfoMessage(
    nid       in  number,
    node      in  varchar2,
    resp_body in  varchar2,
    from_addr in  varchar2,
    error_result in out NOCOPY varchar2);

-- direct_response - Return the value of the direct response flag
--
-- OUT
--   Direct Response as [TRUE|FALSE]
function direct_response return boolean;

-- send_accesskey - Return the value of the send access key flag
--
-- OUT
--   Direct Response as [TRUE|FALSE]
function send_accesskey return boolean;

-- Autoclose_FYI - Return the value of the Autoclose FYI flag
--
-- OUT
--   AUTOCLOSE_FYI as [TRUE|FALSE]
function Autoclose_FYI return boolean;

-- Autoclose_FYI_on - Set the Autoclose flag to TRUE
--
-- OUT
procedure Autoclose_FYI_On;

-- Autoclose_FYI_off - Set the Autoclose flag to TRUE
--
-- OUT
procedure Autoclose_FYI_Off;

-- direct_response_on - Set the value of the direct response flag to TRUE
--
procedure direct_response_on;

-- direct_response - Set the value of the direct response flag to FALSE
--
procedure direct_response_off;

-- send_accesskey - Set the value of the send acces key flag to TRUE
--
procedure send_access_key_on;

-- send_accesskey - Set the value of the send acces key flag to FALSE
--
procedure send_access_key_off;


function UrlEncode(in_string varchar2) return varchar2;
pragma restrict_references(UrlEncode, WNDS);

procedure GetUrlAttachment (nid in number,
                            buffer out NOCOPY varchar2,
                            error_result out NOCOPY varchar2);

-- set_template - Set the mail template
-- if nothing is specify, it will clear the mail template value.
procedure set_template(name in varchar2 default null);

--
-- GetCharset (PRIVATE)
--   Get the character set base of the language and territory info.
-- NOTE
--   We may do more in the future to find the character set.
--
procedure GetCharset(lang in varchar2,
                     terr in varchar2 default null,
                     charset out NOCOPY varchar2);

-- GetSessionLanguage
-- Get the session language and territory for the
-- current session
--
-- OUT
-- Language
-- Territory
-- codeset
procedure GetSessionLanguage(lang out NOCOPY varchar2,
                             terr out NOCOPY varchar2,
                             codeset out NOCOPY varchar2);

-- Bug 2375920
-- GetSignaturePolicy (PUBLIC)
--    Get the signature policy for the notification from
--    the notification attribute
-- IN
--   nid  -  Notification id
-- OUT
--   sig_policy  - Signature policy

procedure GetSignaturePolicy(nid        in  number,
                             sig_policy out NOCOPY varchar2);

-- gets the size of the current LOB table
function getLobTableSize return number;

-- GetTemplateName (For Internal Use only)
--    Get the template type and name based on the status of the
--    notification and whether, or not,  name has been overridden
--    in the configuration parameters or on the message definition
--    itself.
--
-- IN
--    Notification ID
--    Notification status
--    Notification Mail status
-- OUT
--    Item type for template
--    Message name for template

procedure getTemplateName(nid in number, n_status in varchar2,
                          n_mstatus in varchar2, t_type out NOCOPY varchar2,
                          t_name out NOCOPY varchar2);

-- ProcessSecurityPolicy
--    Processes the security policy for the notification. The security policy
--    is determined by the #WF_SECURITY_POLICY.
-- IN
--    p_nid   - Notification id
-- OUT
--    p_email - Determines whether content is secure or not
--    p_message_name - If the notification is not to be sent through email,
--                     suggest a template to use.
procedure ProcessSecurityPolicy(p_nid          in  number,
                                p_email        out NOCOPY varchar2,
                                p_message_name out NOCOPY varchar2);

-- get_Ntf_Function_URL (For internal use only)
-- Returns the Applications Framework URL
-- IN
-- Notification ID
-- Notification Access Key
-- Signature policy
function get_Ntf_Function_URL(nid              in number,
                              n_key            in varchar2,
                              n_sig_policy     in varchar2,
                              n_override_agent in varchar2 default null)
return varchar2;

-- Set_FYI_Flag (Private)
--   Sets a global flag to identify if the current e-mail being processed is a
--   FYI notification
-- IN
--   p_fyi  boolean
procedure Set_FYI_Flag(p_fyi in boolean);

-- Get_FYI_Flag (Private)
--   Returns a global flag to identify if the current e-mail being processed is
--   a FYI notification
-- OUT
--   Boolean value
function Get_FYI_Flag return boolean;

-- Get_Ntf_Language (PRIVATE)
--   Overrides the language and territory setting for the notification based
--   on the #WFM_LANGUAGE and #WFM_TERRITORY attributes. If neither user's
--   preference nor the notification level setting are valid, the base NLS
--   setting is used-- IN
--   p_nid - Notification Id
-- IN OUT
--   p_language   - NLS Language
--   p_territory  - NLS Territory
--   p_codeset    - NLS Codeset
procedure Get_Ntf_Language(p_nid       in            number,
                           p_language  in out nocopy varchar2,
                           p_territory in out nocopy varchar2,
                           p_codeset   in out nocopy varchar2);

--
-- Generic mailer routines
--
-- Send
--   Sends a e-mail notification to the specified list of recipients.
--   This API unlike wf_notification.send does not require workflow
--   message or workflow roles to send a notification.
/*#
 * Sends a message to be dispatched through e-mail by the Oracle Workflow
 * Notification Mailer. The message content and recipients provided in the
 * parameters do not need to be associated with any workflow process or
 * directory service roles. The message content must be complete,
 * preformatted, and email-ready, and should conform to the content type
 * specified in the p_content_type parameter. Where possible, Oracle
 * recommends setting only the required parameters and using the default
 * values for the optional parameters.
 * @param p_subject The Subject header value
 * @paraminfo {@rep:required}
 * @param p_message The message content
 * @paraminfo {@rep:required}
 * @param p_recipient_list The list of recipients to whom the message should be sent
 * @paraminfo {@rep:innertype WF_MAIL#wf_recipient_list_t} {@rep:required}
 * @param p_module The program or application to which the message belongs
 * @paraminfo {@rep:required}
 * @param p_idstring An optional identifier for the message, used in response processing
 * @param p_from An optional From header value
 * @param p_replyto An optional Reply-To header value
 * @param p_language An optional language setting for the message
 * @param p_territory An optional territory setting for the message
 * @param p_codeset An optional codeset encoding specification for the message
 * @param p_content_type An optional Content-Type header value
 * @param p_callback_event The event raised to enable further processing, if needed, after the message is dispatched
 * @param p_event_key The key that identifies the message when the message is enqueued for dispatch
 * @param p_fyi_flag A flag to indicate whether the message is for your information (FYI) or requires a response
 *
 * @rep:displayname Send Message
 * @rep:businessevent oracle.apps.wf.notification.send
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 *
 */
procedure send(p_subject        in varchar2,
               p_message        in out nocopy clob,
               p_recipient_list in wf_recipient_list_t,
               p_module         in varchar2,
               p_idstring       in varchar2 default null,
               p_from           in varchar2 default null,
               p_replyto        in varchar2 default null,
               p_language       in varchar2 default 'AMERICAN',
               p_territory      in varchar2 default 'AMERICA',
               p_codeset        in varchar2 default 'UTF8',
               p_content_type   in varchar2 default 'text/plain',
               p_callback_event in varchar2 default null,
               p_event_key      in varchar2 default null,
               p_fyi_flag       in varchar2 default null);


 --
 -- SendMoreInfoResponseWarning
 --   procedure to send a warning notification about the answer for a More
 --   Informantion request that has already been answered.
 -- IN
 --   p_nid - Notification Id
 --   p_from_email - Email address of the responder

 procedure SendMoreInfoResponseWarning(p_nid IN NUMBER,
                                       p_from_email IN VARCHAR2 default null);

-- SetNtfEventsSubStatus
--   This procedure sets the status of seeded subscription to the event group
--   oracle.apps.wf.notification.send.group. This subscription is responsible
--   for notification XML message generation and presenting it to the mailer for
--   e-mail dispatch. Disabling this subscription causes e-mails not to be sent.
--
--    ENABLED  - E-mails are sent
--    DISABLED - E-mails are not sent
-- IN
--   p_status - Subscription status (Either ENABLED or DISABLED)
procedure SetNtfEventsSubStatus(p_status in varchar2);

-- SetResponseDelimiters
-- Sets the package level variables with one procedure call. The
-- response delimiters are used to determine the free form text
-- values in email notification responses.
--
-- IN
-- open_text - Opening text/plain delimiter
-- close_text - Closing text/plain delimiter
-- open_html - Opening text/html delimiter
-- close_html - Closing text/html delimiter
procedure SetResponseDelimiters(open_text in varchar2,
                                close_text in varchar2,
                                open_html in varchar2,
                                close_html in varchar2);

end WF_MAIL;

/
