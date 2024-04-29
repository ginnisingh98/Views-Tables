--------------------------------------------------------
--  DDL for Package GMF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_UTIL" AUTHID CURRENT_USER AS
/* $Header: gmfutils.pls 115.1 1999/11/11 14:40:09 pkm ship      $ */

/*****************************************************************************
 *  PACKAGE
 *    gmf_util
 *
 *  DESCRIPTION
 *    GMF Utilities Package
 *
 *  CONTENTS
 *    PROCEDURE	trace ( msg IN VARCHAR2, trace_level IN NUMBER DEFAULT 1 )
 *    PROCEDURE log ( log_msg IN VARCHAR2 )
 *    PROCEDURE log
 *    PROCEDURE msg_log ( msg_name , value1, value2, value3, value4, value5 )
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *
 ******************************************************************************/

PROCEDURE trace (
	pi_emsg		IN VARCHAR2,
	pi_trace_level	IN NUMBER DEFAULT 1,
	pi_trace_file	IN NUMBER DEFAULT 1
	);

PROCEDURE log (
	pi_log_msg	IN VARCHAR2
	);

PROCEDURE log;

PROCEDURE msg_log (
	pi_message_name	IN VARCHAR2,
	pi_value1	IN VARCHAR2 DEFAULT NULL,
	pi_value2	IN VARCHAR2 DEFAULT NULL,
	pi_value3	IN VARCHAR2 DEFAULT NULL,
	pi_value4	IN VARCHAR2 DEFAULT NULL,
	pi_value5	IN VARCHAR2 DEFAULT NULL
	);

END gmf_util;

 

/
