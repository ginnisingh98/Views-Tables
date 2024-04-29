--------------------------------------------------------
--  DDL for Package CZ_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_UTILS" AUTHID CURRENT_USER AS
/*	$Header: czcutils.pls 120.2 2006/01/18 04:23:49 amdixit ship $		*/

nDebugLevel 			CZ_DB_SETTINGS.VALUE%TYPE:=NULL;
nReportLevel 			CZ_DB_SETTINGS.VALUE%TYPE:=1;
EPOCH_BEGIN_                  DATE:=TO_DATE('12/1/109','MM/DD/YYYY');
EPOCH_END_                    DATE:=TO_DATE('1/31/4711','MM/DD/YYYY');

FUNCTION LOG_REPORT (Msg in VARCHAR2, Urgency in NUMBER, ByCaller in VARCHAR2,
	StatusCode in NUMBER) RETURN BOOLEAN;

FUNCTION LOG_REPORT (Msg in VARCHAR2, Urgency in NUMBER, ByCaller in VARCHAR2,
	StatusCode in NUMBER, RunId in NUMBER) RETURN BOOLEAN;

FUNCTION REPORT (Msg in VARCHAR2, Urgency in NUMBER, ByCaller in VARCHAR2,
	StatusCode in NUMBER) RETURN BOOLEAN;

FUNCTION TODATE (fromString in VARCHAR2) return DATE;
PRAGMA RESTRICT_REFERENCES (TODATE, WNDS, WNPS);

FUNCTION EPOCH_BEGIN RETURN DATE;
pragma restrict_references(EPOCH_BEGIN, wnds, wnps, rnds);

FUNCTION EPOCH_END RETURN DATE;
pragma restrict_references(EPOCH_END, wnds, wnps, rnds);

FUNCTION GET_PK_USEEXPANSION_FLAG(TABLE_NAME IN VARCHAR2,
	inXFR_GROUP IN VARCHAR2)
RETURN NUMBER;

FUNCTION GET_NOUPDATE_FLAG(TABLE_NAME IN VARCHAR2,
	COLUMN_NAME IN VARCHAR2,
	inXFR_GROUP IN VARCHAR2)
RETURN NUMBER;

FUNCTION ISNUM(nVALUE IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE GET_USER_NAME(forSPXID IN NUMBER, outNAME OUT NOCOPY VARCHAR2);

FUNCTION CONV_NUM(str VARCHAR2) return NUMBER;
pragma restrict_references(conv_num, wnds, wnps, rnds, rnps);

FUNCTION CONV_NUM(str VARCHAR2, format VARCHAR2) return number;
pragma restrict_references(conv_num, wnds, wnps, rnds, rnps);

FUNCTION SPX_UID RETURN INTEGER;
PRAGMA RESTRICT_REFERENCES (SPX_UID, WNDS, WNPS);

FUNCTION SPX_LOGIN_TYPE RETURN CHAR;
PRAGMA RESTRICT_REFERENCES (SPX_LOGIN_TYPE, WNDS, WNPS);

FUNCTION GET_TEXT(inMessageName IN VARCHAR2) RETURN VARCHAR2;
FUNCTION GET_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2, inValue1 IN VARCHAR2) RETURN VARCHAR2;
FUNCTION GET_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2, inValue1 IN VARCHAR2,
                  inToken2 IN VARCHAR2, inValue2 IN VARCHAR2) RETURN VARCHAR2;
FUNCTION GET_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2, inValue1 IN VARCHAR2,
                  inToken2 IN VARCHAR2, inValue2 IN VARCHAR2,
                  inToken3 IN VARCHAR2, inValue3 IN VARCHAR2) RETURN VARCHAR2;
FUNCTION GET_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2, inValue1 IN VARCHAR2,
                  inToken2 IN VARCHAR2, inValue2 IN VARCHAR2,
                  inToken3 IN VARCHAR2, inValue3 IN VARCHAR2,
                  inToken4 IN VARCHAR2, inValue4 IN VARCHAR2) RETURN VARCHAR2;
FUNCTION GET_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2, inValue1 IN VARCHAR2,
                  inToken2 IN VARCHAR2, inValue2 IN VARCHAR2,
                  inToken3 IN VARCHAR2, inValue3 IN VARCHAR2,
                  inToken4 IN VARCHAR2, inValue4 IN VARCHAR2,
                  inToken5 IN VARCHAR2, inValue5 IN VARCHAR2) RETURN VARCHAR2;
FUNCTION GET_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2, inValue1 IN VARCHAR2,
                  inToken2 IN VARCHAR2, inValue2 IN VARCHAR2,
                  inToken3 IN VARCHAR2, inValue3 IN VARCHAR2,
                  inToken4 IN VARCHAR2, inValue4 IN VARCHAR2,
                  inToken5 IN VARCHAR2, inValue5 IN VARCHAR2,
		      inToken6 IN VARCHAR2, inValue6 IN VARCHAR2) RETURN VARCHAR2;

FUNCTION check_installed_lang(p_server_id		IN NUMBER) RETURN NUMBER;

PROCEDURE report_html_tags;

PROCEDURE LOG_REPORT (p_pkg_name VARCHAR2,
		          p_routine  VARCHAR2,
                      p_ndebug    NUMBER,
		          p_msg      VARCHAR2,
		          p_log_level NUMBER);

FUNCTION retrieve_db_link(p_server_id IN PLS_INTEGER)
RETURN   VARCHAR2;

/* use this procedure to add an error message
   to the stack.  In some cases, the return status needs to be set,
   use the statement x_return_status := FND_API.G_RET_STS_ERROR;
   to set the error condition before calling this routine
*/

PROCEDURE add_error_message_to_stack(p_message_name IN VARCHAR2,
                            p_token_name1   IN VARCHAR2 ,
                            p_token_value1  IN VARCHAR2 ,
                            p_token_name2   IN VARCHAR2 ,
                            p_token_value2  IN VARCHAR2 ,
                            p_token_name3   IN VARCHAR2 ,
                            p_token_value3  IN VARCHAR2 ,
                            x_msg_count     IN OUT NOCOPY NUMBER,
                            x_msg_data     IN OUT NOCOPY VARCHAR2);

PROCEDURE add_error_message_to_stack(p_message_name IN VARCHAR2,
                            p_token_name1   IN VARCHAR2 ,
                            p_token_value1  IN VARCHAR2 ,
                            x_msg_count     IN OUT NOCOPY NUMBER,
                            x_msg_data     IN OUT NOCOPY VARCHAR2);


PROCEDURE add_error_message_to_stack(p_message_name IN VARCHAR2,
                            p_token_name1   IN VARCHAR2 ,
                            p_token_value1  IN VARCHAR2 ,
                            p_token_name2   IN VARCHAR2 ,
                            p_token_value2  IN VARCHAR2 ,
                            x_msg_count     IN OUT NOCOPY NUMBER,
                            x_msg_data     IN OUT NOCOPY VARCHAR2);


/* use this procedure to add an error message
   to the stack.  In some cases, the return status needs to be set,
   use the statement return_status := FND_API.G_RET_STS_ERROR, and
   add msg_count := 1 to initialize the message coutnt
   to set the error condition before calling this routine
*/

PROCEDURE add_exc_msg_to_fndstack
(p_package_name IN VARCHAR2,
 p_procedure_name IN  VARCHAR2,
 p_error_message  IN  VARCHAR2);

END CZ_UTILS;

 

/
