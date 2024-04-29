--------------------------------------------------------
--  DDL for Package HR_SESSION_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SESSION_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: hrsessuw.pkh 120.1 2005/09/23 15:54:43 svittal noship $*/
-- ----------------------------------------------------------------------------
-- |--< comments >------------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- NOTE:
-- This package must not have any print calls (to htp.p or procedures that
-- contain it, or anything else, such as javascript alert);
-- errors (as exceptions) must be handled in the packages which called the
-- function (or the parent of that package if it is a child).
-- package prepared in part from: (comments and dates remain in the code for
-- cross-referencing)
--   hr_util_web 	Header: hrutlweb.pkb 110.16 97/12/05
--   per_cm_util_web	Header: pecmuweb.pkb 110.19 97/11/19
-- ----------------------------------------------------------------------------
-- |--< EXCEPTIONS >----------------------------------------------------------|
-- ----------------------------------------------------------------------------

g_fatal_error			EXCEPTION;
PRAGMA EXCEPTION_INIT(g_fatal_error, -20001);
g_validation_error		EXCEPTION;
PRAGMA EXCEPTION_INIT(g_validation_error, -20002);
g_coding_error			EXCEPTION;
-- ----------------------------------------------------------------------------
-- |--< GLOBALS >-------------------------------------------------------------|
-- ----------------------------------------------------------------------------
g_error 			EXCEPTION;
g_package 			VARCHAR2 (200) := 'HR_SESSION_UTILITIES';
g_region_application_id		VARCHAR2 (3) := '601';
g_PER_application_id		VARCHAR2 (3) := '800';
g_image_dir			CONSTANT VARCHAR2 (8)  := 'OA_MEDIA';
g_html_dir			CONSTANT VARCHAR2 (6)  := 'OA_DOC';
g_static_html_dir		CONSTANT VARCHAR2 (7)  := 'OA_HTML';
g_java_dir			CONSTANT VARCHAR2 (7)  := 'OA_JAVA';
g_error_handled			BOOLEAN;
-- ----------------------------------------------------------------------------
-- |--< TYPES >---------------------------------------------------------------|
-- ----------------------------------------------------------------------------
TYPE r_workflow_process_rec
IS RECORD
  ( item_type		wf_items.item_type%TYPE
  , item_key		wf_items.item_key%TYPE
  , actid		NUMBER
  , prt_switch		VARCHAR2 (2000)
  , obj_switch		VARCHAR2 (2000)
  , asn_switch		VARCHAR2 (2000)
  , qun_switch		VARCHAR2 (2000)
  , rev_switch		VARCHAR2 (2000)
  , gpr_switch		VARCHAR2 (2000)
  , aprv_appraiser_switch        VARCHAR2 (2000)
  );
-- ----------------------------------------------------------------------------
-- |--< Get_LoggedIn_User >---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- gets the person record of the logged in user
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Get_LoggedIn_User
RETURN per_people_f%ROWTYPE;
-- ----------------------------------------------------------------------------
-- |--< insert_session_row >--------------------------------------------------|
-- ----------------------------------------------------------------------------
-- name:
--   insert_session_row
-- description:
--   insert an fnd session row so that selects from date tracked
--   tables is successful.
-- requirement:
--   remember to use remove_session_row
--   when your select is complete.
-- ----------------------------------------------------------------------------
PROCEDURE insert_session_row
	(p_effective_date in varchar2);
-- ----------------------------------------------------------------------------
-- |--< insert_session_row >--------------------------------------------------|
-- ----------------------------------------------------------------------------
-- overloaded to accept an encrypted effective date
-- ----------------------------------------------------------------------------
PROCEDURE insert_session_row
	(p_effective_date in date);
-- ----------------------------------------------------------------------------
-- |--< remove_session_row >--------------------------------------------------|
-- ----------------------------------------------------------------------------
-- name:
--   remove_session_row
-- description:
--   removes the fnd session row created by insert_session_row
-- ------------------------------------------------------------------------
PROCEDURE remove_session_row;
-- ----------------------------------------------------------------------------
-- |--< get_ <procedures >>---------------------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- retrieve NLS language code, directory locations, user profile date format
-- and current data
--
-- Prerequisites:
-- none
--
-- Post Success:
--
-- Post Failure:
-- n/a
--
-- Access Status:
-- Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
-- |--< get_language_code >---------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_language_code
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< get_image_directory >-------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_image_directory
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< get_html_directory >--------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_html_directory
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< get_static_html_directory >-------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_static_html_directory
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< get_java_directory >--------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_java_directory
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< get_user_date_format >------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_user_date_format
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< Get_Base_HREF >-------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Base_HREF
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< Get_Today >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Today
RETURN DATE;
-- ----------------------------------------------------------------------------
-- |--< Get_Today_As_Text >---------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Today_As_Text
RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |--< Get_Print_Action >----------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_Print_Action
  ( p_frame_index	 IN NUMBER
  )
RETURN VARCHAR2;
RETURN hr_session_utilities.r_workflow_process_rec;

END HR_SESSION_UTILITIES;
--

 

/
