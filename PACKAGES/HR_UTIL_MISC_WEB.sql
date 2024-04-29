--------------------------------------------------------
--  DDL for Package HR_UTIL_MISC_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_UTIL_MISC_WEB" AUTHID CURRENT_USER AS
/* $Header: hrutlmsw.pkh 120.2 2005/10/26 16:48:03 svittal noship $ */

--
-- owa is the host concated with the agent:
--
  g_owa                varchar2(2000)  := null;
  g_image_dir          varchar2(20)    := '/OA_MEDIA/';
  g_html_dir           varchar2(20)    := '/OA_HTML/';
  g_static_html_dir    varchar2(20)    := '/OA_HTML/';
  g_java_dir           varchar2(20)    := '/OA_JAVA/';
--
  g_region_application_id	constant integer := 601;
  g_application_id          constant integer := 800;
  g_prompts            icx_util.g_prompts_table;
  g_title              varchar(80);
--
-- Global Dates
--
  g_sysdate_char        varchar2(200) := to_char(trunc(sysdate), 'YYYY-MM-DD');
  g_current_yr_char     varchar2(4)   := substr(g_sysdate_char, 1, 4);
  g_sample_date_char    varchar2(200) := g_current_yr_char || '-12-31' ;
  g_sample_date         date      := to_date(g_sample_date_char, 'YYYY-MM-DD');
--When we save the flex date field, we use g_default_date_format so that it
--can be viewed in Oracle Application without date convertion error.
  g_default_date_format varchar2(200) := 'RRRR/MM/DD';

--
-- Variables to mimic the functionality of CHR() functions.
--
  g_null            VARCHAR2(10) := CONVERT (
                                      fnd_global.local_chr(0),
                                      SUBSTR(userenv('LANGUAGE'),
                                        INSTR(userenv('LANGUAGE'),'.') +1),
                                      'WE8ISO8859P1');

  g_line_feed       VARCHAR2(10) := CONVERT (
                                      fnd_global.local_chr(10),
                                      SUBSTR(userenv('LANGUAGE'),
                                        INSTR(userenv('LANGUAGE'),'.') +1),
                                      'WE8ISO8859P1');

  g_new_line        VARCHAR2(10) := CONVERT (
                                      fnd_global.local_chr(10),
                                      SUBSTR(userenv('LANGUAGE'),
                                        INSTR(userenv('LANGUAGE'),'.') +1),
                                      'WE8ISO8859P1');

  g_form_feed       VARCHAR2(10) := CONVERT (
                                      fnd_global.local_chr(12),
                                      SUBSTR(userenv('LANGUAGE'),
                                        INSTR(userenv('LANGUAGE'),'.') +1),
                                      'WE8ISO8859P1');

  g_carriage_return VARCHAR2(10) := CONVERT (
                                      fnd_global.local_chr(13),
                                      SUBSTR(userenv('LANGUAGE'),
                                        INSTR(userenv('LANGUAGE'),'.') +1),
                                      'WE8ISO8859P1');

  g_space           VARCHAR2(10) := CONVERT (
                                      fnd_global.local_chr(32),
                                      SUBSTR(userenv('LANGUAGE'),
                                        INSTR(userenv('LANGUAGE'),'.') +1),
                                      'WE8ISO8859P1');

  g_ampersand       VARCHAR2(10) := CONVERT (
                                      fnd_global.local_chr(38),
                                      SUBSTR(userenv('LANGUAGE'),
                                        INSTR(userenv('LANGUAGE'),'.') +1),
                                      'WE8ISO8859P1');

  g_single_quote    VARCHAR2(10) := CONVERT (
                                      fnd_global.local_chr(39),
                                      SUBSTR(userenv('LANGUAGE'),
                                        INSTR(userenv('LANGUAGE'),'.') +1),
                                      'WE8ISO8859P1');

  g_comma           VARCHAR2(10) := CONVERT (
                                      fnd_global.local_chr(44),
                                      SUBSTR(userenv('LANGUAGE'),
                                        INSTR(userenv('LANGUAGE'),'.') +1),
                                      'WE8ISO8859P1');

--
-- Record types used in the web forms
--
  TYPE g_varchar2_tab_type IS TABLE OF varchar2(2000) INDEX BY BINARY_INTEGER;

--RECORD STRUCTURES
  TYPE g_lookup_values_rec_type
       is record
       ( lookup_type	    VARCHAR2(30)
	,lookup_code        varchar2(30)
        ,meaning            varchar2(80));

--Table structure
  TYPE g_lookup_values_tab_type
       is table of g_lookup_values_rec_type
       INDEX BY BINARY_INTEGER;
--
-- Default Varchar2 PL/SQL Table
--
  g_varchar2_tab_default 	g_varchar2_tab_type;
--
-- Declare an empty table for initialization
  g_lookup_values_tab_default  	g_lookup_values_tab_type;
--
--
-- EXCEPTIONS
-- Use the following exceptions for checking date lookup code
   g_invalid_time_period        exception;
   g_invalid_time_length        exception;
   g_invalid_time_unit          exception;
--
-- Use g_date_error to check if such an error is detected by the subroutine
-- which has not handled issue of the error.
   g_date_error    exception;
--
-- Use this when the routine raising the error has completely handled
-- the situation.
  g_error_handled exception;

--
-- Used in validate session when the product required to run the selected
-- function is not installed.
--
  g_no_app_error exception;
--
-- use this variable to detect that validate_session has been entered and
-- detected a validation error;  no need to run validate_session again
--
  g_error_handled_var boolean;
-- ------------------------------------------------------------------------
-- get_nls_parameter
-- ------------------------------------------------------------------------
  FUNCTION get_nls_parameter(p_parameter in varchar2)
  RETURN VARCHAR2;

-- ------------------------------------------------------------------------
-- get_group_separator
-- ------------------------------------------------------------------------
  FUNCTION get_group_separator
  RETURN VARCHAR2;

-- ------------------------------------------------------------------------
-- get_currency_mask
-- ------------------------------------------------------------------------
  FUNCTION get_currency_mask
  RETURN VARCHAR2;


-- ------------------------------------------------------------------------
-- is_valid_number
-- ------------------------------------------------------------------------
  FUNCTION is_valid_number(p_number in varchar2)
  RETURN BOOLEAN;

-- ------------------------------------------------------------------------
-- is_valid_currency
-- ------------------------------------------------------------------------
  FUNCTION is_valid_currency(p_currency in varchar2)
  RETURN BOOLEAN;

-- ------------------------------------------------------------------------
-- get_language_code
-- ------------------------------------------------------------------------

  FUNCTION get_language_code
  RETURN varchar2;

-- ------------------------------------------------------------------------
-- get_image_directory
-- ------------------------------------------------------------------------

  FUNCTION get_image_directory
  RETURN varchar2;

-- ------------------------------------------------------------------------
-- get_calendar_file
-- ------------------------------------------------------------------------

  FUNCTION get_calendar_file
  RETURN varchar2;

-- ------------------------------------------------------------------------
-- get_html_directory
-- ------------------------------------------------------------------------

  FUNCTION get_html_directory
  RETURN varchar2;

-- ------------------------------------------------------------------------
-- get_person_rec
-- ------------------------------------------------------------------------

  FUNCTION get_person_rec(p_effective_date in varchar2
                         ,p_person_id      in number)
  RETURN per_people_f%ROWTYPE;

-- ------------------------------------------------------------------------
-- return_msg_text
--
-- Purpose: This function can be called to return the message text which
--          can then be used for display in javascript alert or confirm box.
-- ------------------------------------------------------------------------
FUNCTION return_msg_text(p_message_name IN VARCHAR2
                        ,p_application_id IN VARCHAR2 DEFAULT 'PER')
RETURN VARCHAR2;
-- ------------------------------------------------------------------------
-- |----------------------< get_user_date_format>-------------------------|
-- ------------------------------------------------------------------------
function get_user_date_format
  return varchar2;
--
-- ---------------------------------------------------------------------------
-- ------------------------ <build_date2char_expression>----------------------
-- ---------------------------------------------------------------------------
Function build_date2char_expression(p_date        in date
                                   ,p_date_format in varchar2)
  return varchar2;
--
-- ---------------------------------------------------------------------------
-- ------------------------ <validate_date_lookup_code> ----------------------
-- ---------------------------------------------------------------------------
Function validate_date_lookup_code
         (p_lookup_type            in varchar2
         ,p_effective_date         in date default trunc(sysdate))
  return hr_util_misc_web.g_lookup_values_tab_type;
--
--
-- ------------------------------------------------------------------------
-- insert_session_row
--
-- Description:
--   This procedure insert a record into the fnd_sessions table so that we
--   may select data from date-tracked tables.  It's over-loaded to accept a
--   date field or a varchar2 encrypted date.  It also checks the user's
--   security
-- ------------------------------------------------------------------------

  PROCEDURE insert_session_row(p_effective_date in date default sysdate);

-- ------------------------------------------------------------------------
-- autonomous_commit_fnd_sess_row
--
-- Description:
--   This procedure inserts a record into the fnd_sessions table so that we
--   may select data from date-tracked tables.  It commits the insert
--   by using an autonomous transaction.
--   This explicit  commit is necessary because in V4 tech stack,
--   whenever there is an error or warning, FWK will issue a JDBC
--   JDBC rollback.  Thus any fnd_session row inserted before the error
--   was issued will be rolled back.
--   This will create a problem, e.g. in Work Schedule, the Time Card
--   Approver segment uses a value set which points to per_all_people
--   view.  That view uses fnd_session.effective_date.  Thus, if we
--   don't commit this fnd_session row, on the second pass of submit
--   after an error has either been corrected or a warning has been
--   acknowledged, you will get an "invalid value" error from flex
--   field because fnd_session row is rolled back.  Thus, we need to use
--   an autonomous transaction to commit the insert.
--
-- Updated for bug 1940440
-- ------------------------------------------------------------------------
PROCEDURE autonomous_commit_fnd_sess_row
     (p_effective_date   in  date
     ,p_session_id       out nocopy number);


  PROCEDURE remove_session_row;

-- ------------------------------------------------------------------------
-- validate_session
--
-- Description:
--   This procedure calls the Internet Commerce security routine that check
--   that the user has a full, appropriate 'cookie' for their web session.
--   It also obtains the Person_Id of the user.
-- ------------------------------------------------------------------------

  PROCEDURE validate_session(p_person_id  out nocopy    number
                            ,p_check_ota  in   varchar2 default 'N'
                            ,p_check_ben  in   varchar2 default 'N'
                            ,p_check_pay  in   varchar2 default 'N'
                            ,p_icx_update in   boolean default true
                            ,p_icx_commit in   boolean default false);

  PROCEDURE validate_session(p_person_id  out nocopy  number
                            ,p_web_username out nocopy  varchar2
                            ,p_check_ota    in   varchar2 default 'N'
                            ,p_check_ben    in   varchar2 default 'N'
                            ,p_check_pay    in   varchar2 default 'N'
                            ,p_icx_update   in   boolean  default true
                            ,p_icx_commit   in   boolean  default false);

-- ------------------------------------------------------------------------
-- prepare_parameter
--
-- Description:
--   This procedure takes in a parameter and makes it URL ready by changing
--   spaces to '+' and placing a '&' at the front of the parmameter name
--   when p_prefix is true (the parameter is not first in the list).
-- ------------------------------------------------------------------------

  FUNCTION prepare_parameter(p_name   in varchar2
                            ,p_value  in varchar2
                            ,p_prefix in boolean default true)
  RETURN varchar2;
FUNCTION get_complete_url(p_url IN VARCHAR2 DEFAULT NULL) RETURN LONG;
--
FUNCTION get_owa_url RETURN VARCHAR2;

-- ------------------------------------------------------------------------
-- get_resume
-- ------------------------------------------------------------------------
-- get_resume procedure used in apply for job and Professional info modules

procedure get_resume(
		p_person_id IN NUMBER DEFAULT NULL
		,p_resume out nocopy varchar2
		,p_rowid out nocopy varchar2
                ,p_creation_date out nocopy varchar2);


procedure insert_attachment_v4
     (p_attachment_text    in  long default null
     ,p_entity_name        in varchar2 default null
     ,p_pk1_value          in varchar2 default null
     ,p_name               in fnd_document_categories_tl.name%TYPE
     ,p_rowid              out nocopy varchar2
     ,p_login_person_id    in  number);
-- ---------------------------------------------------------------------------
-- |--------------------------< insert_attachment >---------------------------
-- ---------------------------------------------------------------------------
procedure insert_attachment
     (p_attachment_text    in  long default null
     ,p_entity_name        in varchar2 default null
     ,p_pk1_value          in varchar2 default null
     ,p_name               in fnd_document_categories_tl.name%TYPE
                              default 'HR_RESUME'
     ,p_attached_document_id  out
          fnd_attached_documents.attached_document_id%TYPE
     ,p_document_id           out nocopy fnd_documents.document_id%TYPE
     ,p_media_id              out nocopy fnd_documents_tl.media_id%TYPE
     ,p_rowid                 out nocopy varchar2
     ,p_login_person_id    in  number);     -- 10/14/97 Changed

-- ---------------------------------------------------------------------------
-- |--------------------------< update_attachment >---------------------------
-- ---------------------------------------------------------------------------
procedure update_attachment
     (p_attachment_text    in  long default null
     ,p_entity_name        in varchar2 default null
     ,p_pk1_value          in varchar2 default null
     ,p_rowid              in varchar2
     ,p_login_person_id    in  number);     -- 10/14/97 Changed

-- ----------------------------------------------------------------------------
-- |--------------------------< get_attachment >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_attachment
     (p_attachment_text    out nocopy long
     ,p_entity_name        in varchar2 default null
     ,p_pk1_value          in varchar2 default null
     ,p_effective_date     in varchar2
     ,p_attached_document_id  out
          fnd_attached_documents.attached_document_id%TYPE
     ,p_document_id           out nocopy fnd_documents.document_id%TYPE
     ,p_media_id              out nocopy fnd_documents_tl.media_id%TYPE
     ,p_rowid                 out nocopy varchar2
     ,p_category_id           out nocopy fnd_documents.category_id%type
     ,p_seq_num               out nocopy fnd_attached_documents.seq_num%type
     ,p_creation_date         out nocopy fnd_documents_tl.creation_date%type
     ,p_user_name          in     fnd_document_categories_tl.user_name%TYPE
                                      DEFAULT 'HR_RESUME'
     );

procedure get_attachment_v4
          (p_attachment_text    out nocopy long
          ,p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_effective_date     in date
          ,p_name               in fnd_document_categories_tl.name%TYPE
          ,p_rowid              out nocopy varchar2
          );

----------------------------------------------------------------------------
-- Fuction string to URL
----------------------------------------------------------------------------
FUNCTION string_to_url ( p_url in varchar2) return varchar2;
FUNCTION isManager
	(p_item_type IN VARCHAR2
	,p_item_key IN VARCHAR
	) RETURN BOOLEAN;

/*------------------------------------------------------------------------------
|       Name           : isSelfUpdating
|       Purpose        :
|
|       Returns TRUE if the login person is same as the person being updated.
|               FALSE, if the login person is different from person being updated.
+-----------------------------------------------------------------------------*/

FUNCTION isSelfUpdating
        (p_item_type IN VARCHAR2
        ,p_item_key IN VARCHAR
        ) RETURN BOOLEAN;
  FUNCTION get_called_from RETURN VARCHAR2;
  FUNCTION get_fnd_form_function(p_function_id IN NUMBER)
		RETURN fnd_form_functions%ROWTYPE;

/*------------------------------------------------------------------------------
|       Name           : get_process_name
|
|       Purpose        :
|
|       This function will return the string which appears after
|       'p_process_name=' in the direct access menu function's.
|       parameters.
|       Usage          :
|        This function is to be used when the FND form Function is
|       defined as exactly 'P_PROCESS_NAME=YourProcess&P_ITEM_TYPE=...'
|       i.e P_PROCESS_NAMEis followed by &P_ITEM_TYPE
+-----------------------------------------------------------------------------*/
  FUNCTION get_process_name RETURN VARCHAR2;

/*------------------------------------------------------------------------------
|       Name           : get_item_type
|
|       Purpose        :
|
|       This function will only return the string which appears after
|       'p_item_type=' in the direct access menu function's.
|       parameters.
|       Usage          :
|        This function is used to get the item_type from FND form Function
+-----------------------------------------------------------------------------*/
  FUNCTION get_item_type RETURN VARCHAR2;
  /*
 ||===========================================================================
 || FUNCTION: get_business_group_id
 ||---------------------------------------------------------------------------
 ||
 || Description:
 ||     If p_person_id is passed, the function call returns
 ||     Business Group ID for the current person. Otherwise,
 ||     the Function call returns the Business Group ID
 ||     for the current session's login responsibility.
 ||     The defaulting levels are as defined in the
 ||     package FND_PROFILE. It returns business group id
 ||     value for a specific user/resp/appl combo.
 ||     Default is user/resp/appl/site is current login.
 ||
 || Pre Conditions:
 ||
 || In Arguments:
 ||
 || out nocopy Arguments:
 ||
 || In out nocopy Arguments:
 ||
 || Post Success:
 ||     Returns the business group id.
 ||
 || Post Failure:
 ||
 || Access Status:
 ||     Public.
 ||
 ||===========================================================================
 */

  FUNCTION get_business_group_id
	 (p_person_id IN NUMBER DEFAULT NULL)
	   RETURN   per_business_groups.business_group_id%TYPE;

  /*
  ||===========================================================================
  || PROCEDURE check_business_group
  ||===========================================================================
  || Description:  This procedure display error page if the passed person's
  ||               business group is not same as the responsibility's
  ||               business group.
  ||===========================================================================
  */
  PROCEDURE check_business_group
    (p_person_id IN NUMBER);

  /*
  ||===========================================================================
  || PROCEDURE initialize_hr_globals
  ||===========================================================================
  || Description:
  ||===========================================================================
  */
  PROCEDURE initialize_hr_globals(p_reset_errors IN VARCHAR2 DEFAULT 'Y');


-- ---------------------------------------------------------------------------
-- ------------------------ <decode_date_lookup_code> ------------------------
-- ---------------------------------------------------------------------------
Function decode_date_lookup_code
         (p_date_compare_to_column  in varchar2 default null
         ,p_date_lookup_code        in varchar2
         ,p_effective_date          in date default trunc(sysdate))
  return varchar2;


END hr_util_misc_web;

 

/
