--------------------------------------------------------
--  DDL for Package GMF_SESSION_VARS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_SESSION_VARS" AUTHID CURRENT_USER AS
/*       $Header: gmfsesns.pls 120.0 2005/05/25 18:10:29 appldev noship $ */
        /* Initialization of variable done once per session. */
	INITIALIZED varchar2(1) default 'N';
        APPS_BASE_LANGUAGE  varchar2(16) default 'US';
	GL_LOG_TRIGGER_ERROR number default to_number(nvl(FND_PROFILE.VALUE('GMF$LOG_TRIGGER_ERROR'),1));
        GLSYNCH_ERROR_FILE  varchar2(16) default ' ';
	LAST_UPDATED_BY number default -1;
        GL$VEND_DELIMITER fnd_profile_options_vl.profile_option_name%TYPE default nvl(FND_PROFILE.VALUE('GL$VEND_DELIMITER'),'-');
        GL$CUST_DELIMITER fnd_profile_options_vl.profile_option_name%TYPE default '-';
	GL_EXCP_CO_CODE sy_excp_tbl.co_code%TYPE default '';
	ex_error_found	exception;

	/* Variables to be initialized before every  */
	/* event (start of trigger). */
        FOUND_ERRORS varchar2(1) default 'Y';
	ERROR_TEXT 	varchar2(512) default ' ';

	/* B1297909 */
        GMA_INSTALLED   VARCHAR2(1)     default 'I';
	GMI_INSTALLED   VARCHAR2(1)     default 'I';
	GMF_INSTALLED   VARCHAR2(1)     default 'I';
	GML_INSTALLED   VARCHAR2(1)     default 'I';
	PO_INSTALLED    VARCHAR2(1)     default 'I';
	INV_INSTALLED   VARCHAR2(1)     default 'I';
	AR_INSTALLED    VARCHAR2(1)     default 'I';

	/* BUG 1325844
	   Following variables are used by item triggers.
	   These were added to avoid mutating trigger problem.
	   Variables are populated by trigger on ic_item_mst_b
	   table and later used by trigger on ic_item_mst_tl
	   table. */
	item_id		number	default 0;
	item_no		varchar2(32)	default ' ';

END; /* GmF_Session_Vars package */

 

/
