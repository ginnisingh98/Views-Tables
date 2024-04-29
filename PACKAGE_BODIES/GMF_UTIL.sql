--------------------------------------------------------
--  DDL for Package Body GMF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_UTIL" AS
/* $Header: gmfutilb.pls 115.1 1999/11/11 14:40:05 pkm ship      $ */

/*****************************************************************************
 *  PROCEDURE
 *    trace
 *
 *  PARAMETERS
 *    msg IN VARCHAR2		- Message to be printed
 *    trace_level IN NUMBER	- Trace Level, 1 by default
 *
 *  DESCRIPTION
 *	trace() prints messages to the log file FND_FILE.LOG when called
 *	from a concurrent pl/sql program.  Trace will get the debug level via
 *	the profile option GMF_CONC_DEBUG.  Messages that are passed with a
 *	trace level lesser or equal to the profile value will be printed.
 *	By default a debug level of 0 will be assumed if the profile
 *	does not exist.
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *    10-Nov-1999 Rajesh Seshadri - Added another default parameter to specify
 *	whether the msg is to be printed to the log ( = 1, default) or the
 *	output ( = 2 ) file.
 *
 ******************************************************************************/

PROCEDURE trace (
	pi_emsg		IN VARCHAR2,
	pi_trace_level	IN NUMBER DEFAULT 1,
	pi_trace_file	IN NUMBER DEFAULT 1
	)
IS
	l_profile_value		VARCHAR2(10);
	l_profile_level		NUMBER := 0;
	l_dt VARCHAR2(31);
BEGIN
	l_dt := TO_CHAR( SYSDATE, 'YYYY-MM-DD HH24:MI:SS' );
	l_profile_level := 0;

	BEGIN
		l_profile_value := FND_PROFILE.VALUE( 'GMF_CONC_DEBUG' );
		IF( l_profile_value IS NOT NULL ) THEN
			l_profile_level := TO_NUMBER( l_profile_value );
		END IF;
	EXCEPTION
		WHEN others THEN
			l_profile_level := 0;
	END;

	IF( pi_trace_level > l_profile_level ) THEN
		RETURN;
	ELSE
		IF( pi_trace_file = 2 )
		THEN
			FND_FILE.PUT_LINE( FND_FILE.OUTPUT, pi_emsg || '  ' || l_dt );
		ELSE
			FND_FILE.PUT_LINE( FND_FILE.LOG, pi_emsg || '  ' || l_dt );
		END IF;
	END IF;

END trace;

/*****************************************************************************
 *  PROCEDURE
 *    log
 *
 *  PARAMETERS
 *    log_msg IN VARCHAR2	- Message to be printed
 *
 *  DESCRIPTION
 *    Prints the log message passed in to FND_FILE.LOG with timestamp
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *
 ******************************************************************************/

PROCEDURE log (
	pi_log_msg	IN VARCHAR2
	)
IS
	l_dt VARCHAR2(64);
BEGIN
	l_dt := TO_CHAR( SYSDATE, 'YYYY-MM-DD HH24:MI:SS' );

	IF( pi_log_msg IS NOT NULL ) THEN
		FND_FILE.PUT_LINE( FND_FILE.LOG, pi_log_msg || '  ' || l_dt );
	ELSE
		FND_FILE.NEW_LINE( FND_FILE.LOG, 1 );
	END IF;

END log;

/*****************************************************************************
 *  PROCEDURE
 *    log
 *
 *  PARAMETERS
 *    NONE
 *
 *  DESCRIPTION
 *    Prints a new line in FND_FILE.LOG
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *
 ******************************************************************************/

PROCEDURE log
IS
BEGIN
	log( null );
END log;

/*****************************************************************************
 *  PROCEDURE
 *    msg_log
 *
 *  PARAMETERS
 *    message_name, value1 thru 5 (defaulted to NULL)
 *
 *  DESCRIPTION
 *    Retrieves the message from msg dictionary and substitutes the tokens
 *    with the non-null values passed.
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *
 ******************************************************************************/

PROCEDURE msg_log(
	pi_message_name	IN VARCHAR2,
	pi_value1	IN VARCHAR2 DEFAULT NULL,
	pi_value2	IN VARCHAR2 DEFAULT NULL,
	pi_value3	IN VARCHAR2 DEFAULT NULL,
	pi_value4	IN VARCHAR2 DEFAULT NULL,
	pi_value5	IN VARCHAR2 DEFAULT NULL
	)
IS

	l_msg_text	VARCHAR2(2000);

BEGIN

	FND_MESSAGE.SET_NAME( 'GMF', pi_message_name );

	IF( pi_value1 IS NOT NULL ) THEN
		FND_MESSAGE.SET_TOKEN( 'S1', pi_value1 );
	END IF;

	IF( pi_value2 IS NOT NULL ) THEN
		FND_MESSAGE.SET_TOKEN( 'S2', pi_value2 );
	END IF;

	IF( pi_value3 IS NOT NULL ) THEN
		FND_MESSAGE.SET_TOKEN( 'S3', pi_value3 );
	END IF;

	IF( pi_value4 IS NOT NULL ) THEN
		FND_MESSAGE.SET_TOKEN( 'S4', pi_value4 );
	END IF;

	IF( pi_value5 IS NOT NULL ) THEN
		FND_MESSAGE.SET_TOKEN( 'S5', pi_value5 );
	END IF;

	l_msg_text := FND_MESSAGE.GET;

	log( l_msg_text );

END msg_log;

END gmf_util;

/
