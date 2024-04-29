--------------------------------------------------------
--  DDL for Package ARP_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_DEBUG" AUTHID CURRENT_USER AS
/* $Header: ARDBGMGS.pls 120.0 2006/05/25 20:24:28 jypandey noship $ */


/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  TYPES                                                           |
 |                                                                         |
 +-------------------------------------------------------------------------*/

    TYPE      PROFILE_TYPE IS RECORD
        (
              PROGRAM_APPLICATION_ID    NUMBER := 0,
              PROGRAM_ID                NUMBER := 0,
              REQUEST_ID                NUMBER := 0,
              USER_ID                   NUMBER := 0,
              LAST_UPDATE_LOGIN         NUMBER := 0,
              LANGUAGE_ID               NUMBER := 0,
              LANGUAGE_CODE             VARCHAR2(50) := NULL
         );

/*-------------------------------------------------------------------------+
 |                                                                         |
 | Data type: PRV_MESSAGE_TYPE,                                            |
 |   Procedure calls to fnd_message store each of the parameters passed so |
 |   that a calling PL/SQL block can access the same message and tokens    |
 |   and determine the processing steps required.                          |
 |                                                                         |
 +-------------------------------------------------------------------------*/

    TYPE 	PRV_MESSAGE_TYPE IS RECORD
	(
   		name varchar2(30),
   		t1   varchar2(240),
   		v1   varchar2(240),
   		t2   varchar2(240),
   		v2   varchar2(240),
   		t3   varchar2(240),
   		v3   varchar2(240),
   		t4   varchar2(240),
   		v4   varchar2(240)
	);

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  VARIABLES                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/


    sysparm   		AR_SYSTEM_PARAMETERS%ROWTYPE;

    profile   		PROFILE_TYPE;
    previous_msg 	PRV_MESSAGE_TYPE;

    application_id                      NUMBER;
    g_msg_module                        VARCHAR2(256);

/*-------------------------------------------------------------------------+
 |                                                                         |
 | PUBLIC  FUNCTIONS                                                       |
 |                                                                         |
 +-------------------------------------------------------------------------*/



procedure debug( line in varchar2,
          msg_prefix  in varchar2 DEFAULT 'plsql',
          msg_module  in varchar2 DEFAULT NULL,
          msg_level   in number   DEFAULT NULL ) ;


procedure enable_file_debug(path_name IN varchar2,
			file_name IN VARCHAR2);

procedure disable_file_debug;


END ARP_DEBUG;

 

/
