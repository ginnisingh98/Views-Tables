--------------------------------------------------------
--  DDL for Package QP_JAVA_ENGINE_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_JAVA_ENGINE_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXJUTLS.pls 120.1 2005/07/14 11:07:55 appldev ship $ */

--GLOBAL Constant holding the package name

G_PKG_NAME               CONSTANT  VARCHAR2(30) := 'QP_JAVA_ENGINE_UTIL_PUB';
G_QP_INT_TABLES_LOCK     CONSTANT VARCHAR2(30) := 'QP_INT_TABLES_LOCK';
G_HARD_CHAR varchar2(1) := '&';
G_PATN_SEPERATOR varchar2(1) := '|';
G_PARAM_NAME_DBC varchar2(3) := 'dbc';
G_PARAM_NAME_USERID varchar2(6) := 'UserId';
G_PARAM_NAME_RESPID varchar2(6) := 'RespId';
G_PARAM_NAME_RESP_APPL_ID varchar2(10) := 'RespApplId';
G_PARAM_NAME_LOGIN_ID varchar2(7) := 'LoginId';
G_PARAM_NAME_ORG_ID varchar2(5) := 'OrgId';
G_PARAM_NAME_APP_SHORT_NAME varchar2(12) := 'AppShortName';
G_PARAM_NAME_CALL_TYPE varchar2(8) := 'CallType';
G_PARAM_NAME_ACTION varchar2(6) := 'Action';
G_PARAM_NAME_ICX_SESSION_ID varchar2(12) := 'IcxSessionId';
G_PARAM_NAME_STS_CODE varchar2(10) := 'StatusCode';
G_PARAM_NAME_STS_TEXT varchar2(10) := 'StatusText';
G_PARAM_NAME_DETAILS varchar2(10) := 'Details';
G_PARAM_NAME_DEBUG_FLAG varchar2(9) := 'DebugFlag';

G_TRANSFER_TIMEOUT number := 60;
G_NEWLINE_CHARACTER CHAR(1) := FND_GLOBAL.Newline;

--added for HTTP timeout issue handling
G_MAX_STATUS_REQUESTS        NUMBER:=nvl(FND_PROFILE.VALUE('QP_JPE_MAX_STAT_REQUESTS'),240);
G_STATUS_REQUEST_INTERVAL    NUMBER:=nvl(FND_PROFILE.VALUE('QP_JPE_STAT_REQUEST_INTERVAL'),15);   -- seconds
--added for HTTP timeout issue handling

--'Y', JavaEngine is installed, 'N' is not installed.
FUNCTION Java_Engine_Installed RETURN VARCHAR2;

--'Y', JavaEngine is running, 'N' is not running.
FUNCTION Java_Engine_Running RETURN VARCHAR2;

--Return the URL to Servlet where Java Engine is deployed and running.
FUNCTION Get_Engine_Url RETURN VARCHAR2;

PROCEDURE Send_Java_Engine_Request (p_url_param_string IN VARCHAR2,
			x_return_status          OUT NOCOPY  VARCHAR2,
			x_return_status_text     OUT NOCOPY  VARCHAR2,
                        p_transfer_timeout       IN NUMBER DEFAULT -1, -- defaulted to qp utl_http timeout setting
                        p_detailed_excp_support  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_timeout_processing IN VARCHAR2 default FND_API.G_FALSE);

PROCEDURE Send_Java_Engine_Request (p_url_param_string IN VARCHAR2,
			x_return_status          OUT NOCOPY  VARCHAR2,
			x_return_status_text     OUT NOCOPY  VARCHAR2,
			x_return_details         OUT NOCOPY  UTL_HTTP.HTML_PIECES,
                        p_use_request_pieces     IN BOOLEAN,
                        p_transfer_timeout       IN NUMBER DEFAULT -1, -- defaulted to qp utl_http timeout setting
                        p_detailed_excp_support  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_timeout_processing IN VARCHAR2 default FND_API.G_FALSE);

PROCEDURE Send_Java_Request (p_server_url        IN VARCHAR2,
                        p_url_param_string       IN VARCHAR2,
			x_return_status          OUT NOCOPY  VARCHAR2,
			x_return_status_text     OUT NOCOPY  VARCHAR2,
			x_return_details         OUT NOCOPY  UTL_HTTP.HTML_PIECES,
                        p_use_request_pieces     IN BOOLEAN,
                        p_transfer_timeout       IN NUMBER DEFAULT -1,
                        p_detailed_excp_support  IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        p_timeout_processing IN VARCHAR2 DEFAULT FND_API.G_FALSE);

END QP_JAVA_ENGINE_UTIL_PUB;

 

/
