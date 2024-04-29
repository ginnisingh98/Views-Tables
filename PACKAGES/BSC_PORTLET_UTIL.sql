--------------------------------------------------------
--  DDL for Package BSC_PORTLET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PORTLET_UTIL" AUTHID CURRENT_USER AS
/* $Header: BSCPUTLS.pls 120.0 2005/06/01 14:37:58 appldev noship $ */

CODE_RET_SUCCESS CONSTANT NUMBER := 0;
CODE_RET_ERROR CONSTANT NUMBER := -1;
CODE_RET_SESSION_EXP CONSTANT NUMBER := -2;
CODE_RET_NOROW CONSTANT NUMBER := -3;


VALUE_NOT_SET CONSTANT NUMBER := -1923;


PR_KCODE      CONSTANT VARCHAR2(20) := 'sKCode';
PR_TABCODE    CONSTANT VARCHAR2(20) := 'sTabCode';
PR_PORLETNAME CONSTANT VARCHAR2(20) := 'portletName';
PR_RESPID CONSTANT VARCHAR2(20) := 'responsibilityId';

-- message names ------
MSGNM_UPDATE_ERR CONSTANT VARCHAR2(30) := 'BSC_PKGRAPH_UPD_ERR';
MSGNM_SESSION_EXP CONSTANT VARCHAR2(30) := 'BSC_SESSION_EXPIRE';


-- message texts ------
MSGTXT_SUCCESS CONSTANT VARCHAR2(30) := 'SUCCESS';
MSGTXT_NOROW CONSTANT VARCHAR2(30) := 'Row not found.';
MSGTXT_SESSION_EXP CONSTANT VARCHAR2(30) := 'You session has expired.';

FUNCTION get_jsp_server RETURN VARCHAR2;
FUNCTION get_webdb_host RETURN VARCHAR2;
FUNCTION get_webdb_port RETURN VARCHAR2;

FUNCTION get_bsc_url(
    p_session_id IN NUMBER,
    p_plug_id IN NUMBER,
    p_jsp_name IN VARCHAR2,
    p_ext_params IN VARCHAR2,
    p_is_respid_used IN BOOLEAN
) RETURN VARCHAR2;



FUNCTION get_bsc_jsp_path RETURN VARCHAR2;


PROCEDURE gotoMainMenu(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2);


PROCEDURE update_portlet_name(
    p_user_id IN NUMBER,
    p_plug_id      IN pls_integer,
    p_display_name IN VARCHAR2
 );




PROCEDURE decrypt_plug_info(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2,
    p_session_id OUT NOCOPY NUMBER,
    p_plug_id OUT NOCOPY NUMBER);




FUNCTION request_html_pieces(
    p_url     IN VARCHAR2,
    p_proxy   IN VARCHAR2 DEFAULT NULL
) RETURN utl_http.html_pieces;




FUNCTION re_align_html_pieces(
    src       IN utl_http.html_pieces
) RETURN utl_http.html_pieces;



PROCEDURE test_https(
    url       IN VARCHAR2
);



--==========================================================================

FUNCTION getValue(
  p_key        IN VARCHAR2
 ,p_parameters IN VARCHAR2
 ,p_delimiter  IN VARCHAR2 := '&'
) RETURN VARCHAR2;


END bsc_portlet_util;

 

/
