--------------------------------------------------------
--  DDL for Package IRC_NOTIFICATION_HELPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTIFICATION_HELPER_PKG" AUTHID CURRENT_USER AS
/* $Header: irnothlp.pkh 120.1.12010000.3 2009/04/22 12:08:00 prasashe ship $ */
--
Type g_document_ids is table of number index by binary_integer;
-- -- --------------------------------------------------------------------- *
-- Name    : get_job_seekers_role
-- -- --------------------------------------------------------------------- *
-- {Start Of Comments}
--
-- Description:
--    This function returns a user_name based on fnd_user.user_name.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--     p_person_id   NUMBER      id of the person to obtain a user name for.
-- Post Success:
--   a username is returned
--
-- Post Failure:
--   null will be returned
--
-- Access Status:
--   Internal HRMS Development
--
-- {End Of Comments}
-- -- --------------------------------------------------------------------- *
FUNCTION get_job_seekers_role
(p_person_id    per_all_people_f.person_id%type
) RETURN varchar2 ;
-- ----------------------------------------------------------------------------
-- |------------------------< send_notification (overloaded) >----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function sends an email notification to an email address.  This is
--    done by creating a new ad hoc wf user.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--     p_email_address  VARCHAR2  email_address to send the notification to
--     p_subject    VARCHAR2    Text to write in the SUBJECT line of the email
--     p_html_body  VARCHAR2    HTML Text to be the body of the email. Used
--                              if the recipient can accept HTML
--     p_text_body  VARCHAR2    Plain Text to be the body of the email. Used
--                              if the recipient can't accept HTML.
--     p_from_role  VARCHAR2    Contains the name of the person who sent the
--                              Notification
-- Note: If only p_text_body is passed in, and the recipients email system does
--       accept HTML, they won't see any body in their email (Workflow doesn't
--       substitute the text body for the html body).
--       Both p_html_body and p_text_body should be passed in to handle all situations
-- Post Success:
--   The notification_id relating to the notification that has just been
--   sent will be passed out.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal HRMS Development
--
-- {End Of Comments}
FUNCTION send_notification
    ( p_email_address IN  varchar2
    , p_subject       IN  varchar2
    , p_html_body     IN  varchar2 DEFAULT null
    , p_text_body     IN  varchar2 DEFAULT null
    , p_from_role     IN  varchar2 DEFAULT null
    ) return number;
-- ----------------------------------------------------------------------------
-- |------------------------< send_notification (overloaded) >----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function sends an email notification to a party.  The email
--    address to use is obtained by searching for the role associated
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--     p_user_name  NUMBER      fnd_user.user_name of the user
--     p_subject    VARCHAR2    Text to write in the SUBJECT line of the email
--     p_html_body  VARCHAR2    HTML Text to be the body of the email. Used
--                              if the recipient can accept HTML
--     p_text_body  VARCHAR2    Plain Text to be the body of the email. Used
--                              if the recipient can't accept HTML.
--     p_from_role  VARCHAR2    Contains the name of the person who sent the
--                              Notification
-- Note: If only p_text_body is passed in, and the recipients email system does
--       accept HTML, they won't see any body in their email (Workflow doesn't
--       substitute the text body for the html body).
--       Both p_html_body and p_text_body should be passed in to handle all situations
-- Post Success:
--   The notification_id relating to the notification that has just been
--   sent will be passed out.
--
-- Post Failure:
--   A exception will be raised if the party_id passed in doesn't have an
--   associated role.  The role is obtained from fnd_user
--   An exception can also occur if there is a problem with the WF message
--   and associated WF notification not being in the database as expected.
--
-- Developer Implementation Notes:
--    Note: This procedure could be enhanced by having another flag which
--    indiates whether it is ok if >1 role is found for the party, and
--    what to do if this situation arises (error, send to first role, warn).
--    It could also check if the role has > 1 email address associated with it.
--   (However, this situation can't occur at the moment because of how the
--    email address is being retrieved).
--
-- Access Status:
--   Internal HRMS Development
--
-- {End Of Comments}
FUNCTION send_notification
    ( p_user_name     IN  varchar2
    , p_subject       IN  varchar2
    , p_html_body     IN  varchar2 DEFAULT null
    , p_text_body     IN  varchar2 DEFAULT null
    , p_from_role     IN  varchar2 DEFAULT null
    ) return number;
-- ----------------------------------------------------------------------------
-- |------------------< send_notification (overloaded) >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function sends an email notification to a party.  The email
--    address to use is obtained by searching for the role associated
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--     p_person_id  NUMBER      ID of the person to send the email too
--     p_subject    VARCHAR2    Text to write in the SUBJECT line of the email
--     p_html_body  VARCHAR2    HTML Text to be the body of the email. Used
--                              if the recipient can accept HTML
--     p_text_body  VARCHAR2    Plain Text to be the body of the email. Used
--                              if the recipient can't accept HTML.
--     p_from_role  VARCHAR2    Contains the name of the person who sent the
--                              Notification
-- Note: If only p_text_body is passed in, and the recipients email system does
--       accept HTML, they won't see any body in their email (Workflow doesn't
--       substitute the text body for the html body).
--       Both p_html_body and p_text_body should be passed in to handle all situations
-- Post Success:
--   The notification_id relating to the notification that has just been
--   sent will be passed out.
--
-- Post Failure:
--   A exception will be raised if the party_id passed in doesn't have an
--   associated role.  The role is obtained from fnd_user
--   An exception can also occur if there is a problem with the WF message
--   and associated WF notification not being in the database as expected.
--
-- Developer Implementation Notes:
--    Note: This procedure could be enhanced by having another flag which
--    indiates whether it is ok if >1 role is found for the party, and
--    what to do if this situation arises (error, send to first role, warn).
--    It could also check if the role has > 1 email address associated with it.
--   (However, this situation can't occur at the moment because of how the
--    email address is being retrieved).
--
-- Access Status:
--   Internal HRMS Development
--
-- {End Of Comments}
FUNCTION send_notification
    ( p_person_id     IN  number
    , p_subject       IN  varchar2
    , p_html_body     IN  varchar2 DEFAULT null
    , p_text_body     IN  varchar2 DEFAULT null
    , p_from_role     IN  varchar2 DEFAULT null
    ) return number;
-- ----------------------------------------------------------------------------
-- |------------------< get_doc >---------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This procedure is called from the attribute IRC_DOCUMENT_1
--    to IRC_DOCUMENT_8 which is of type Document. This attribute
--    is present in message IRC_GENERAL_NOTIFICATION_MSG
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--     document_id   VARCHAR2    A string that uniquely identifies a document.
--     display_type  VARCHAR2    Display type for the document.
--     document      VARCHAR2    The outbound text buffer where up to 32K
--                               of document text is returned.
--     document_type VARCHAR2    The outbound text buffer where the document
--                               content type is returned
-- Post Success:
--   The value in the attribute HTML_BODY_1 to HTML_BODY_8 will be set
--   to IRC_DOCUMENT_1 to IRC_DOCUMENT_8
--
-- Post Failure:
--    None.
--
-- Developer Implementation Notes:
--    Note:
--
-- Access Status:
--   Internal HRMS Development
--
-- {End Of Comments}
procedure get_doc (document_id in varchar2
                  ,display_type in varchar2
                  ,document in out nocopy varchar2
                  ,document_type in out nocopy varchar2);

--
-- ----------------------------------------------------------------------------
-- |------------------------< attach_resumes_notification >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This function sends an email notification to a party.  The email
--    address to use is obtained by searching for the role associated
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--     p_user_name  NUMBER      fnd_user.user_name of the user
--     p_subject    VARCHAR2    Text to write in the SUBJECT line of the email
--     p_text_body  VARCHAR2    Plain Text to be the body of the email. Used
--                              if the recipient can't accept HTML.
--     p_from_role  VARCHAR2    Contains the name of the person who sent the
--                              Notification
--     p_person_ids VARCHAR2    Contains the personIds of all person to be
--                              referred in Notification
-- Post Success:
--   The notification_id relating to the notification that has just been
--   sent will be passed out.
--
-- Post Failure:
--   An exception can occur if there is a problem with the WF message
--   and associated WF notification not being in the database as expected.
--
-- Developer Implementation Notes:
--    Note: This procedure could be enhanced by having another flag which
--    indiates whether it is ok if >1 role is found for the party, and
--    what to do if this situation arises (error, send to first role, warn).
--    It could also check if the role has > 1 email address associated with it.
--   (However, this situation can't occur at the moment because of how the
--    email address is being retrieved).
--
-- Access Status:
--   Internal HRMS Development
--
-- {End Of Comments}
function attach_resumes_notification(p_user_name  in  varchar2
                                    ,p_subject    in  varchar2
                                    ,p_html_body  in  varchar2 default null
                                    ,p_from_role  in  varchar2 default null
                                    ,p_person_ids in  varchar2 default null)
return number;
--
--
-- ----------------------------------------------------------------------------
-- |------------------< show_resume >---------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This procedure is called from the attribute IRC_RESUME_1
--    to IRC_RESUME_10 which is of type Document. This attribute
--    is present in message IRC_TEXT_RESUME_MSG_<N>
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--     document_id   VARCHAR2    A string that uniquely identifies a document.
--     display_type  VARCHAR2    Display type for the document.
--     document      VARCHAR2    The outbound text buffer where up to 32K
--                               of document text is returned.
--     document_type VARCHAR2    The outbound text buffer where the document
--                               content type is returned
-- Post Success:
--  None
--
-- Post Failure:
--    None.
--
-- Developer Implementation Notes:
--    Note:
--
-- Access Status:
--   Internal HRMS Development
--
-- {End Of Comments}

procedure show_resume (document_id    in varchar2
                       ,display_type  in varchar2
                       ,document      in out nocopy blob
                       ,document_type in out nocopy varchar2
                       )
;
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
  );
--
--
PROCEDURE raiseNotifyEvent( p_eventName    in varchar2
                          , p_assignmentId in number
                          , p_personId     in number
                          , params         in clob);
--
-- Global variable --
g_package constant varchar2(100) := 'irc_notification_helper_pkg';
--
END irc_notification_helper_pkg;

/
