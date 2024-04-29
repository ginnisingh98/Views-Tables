--------------------------------------------------------
--  DDL for Package JG_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_UTILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzzutls.pls 115.2 2002/11/22 19:18:53 tdexter ship $ */
/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    debug             - Display text message if in debug mode               |
 |    log		- Display text message  in the log file		      |
 |    out 		- Display text message  in the out file		      |
 |    enable_debug      - Enable run time debugging                           |
 |    disable_debug     - Disable run time debugging                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard debug information sending it to dbms_output so that   |
 |    the client tool can log it for the user.                                |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |                                                                            |
 *----------------------------------------------------------------------------*/
  debug_flag	BOOLEAN		:= FALSE;

  procedure debug( line in varchar2 ) ;

  procedure log ( line in varchar2 ) ;

  procedure out ( line in varchar2 ) ;

  procedure enable_debug;

  procedure disable_debug;

END JG_UTILITY_PKG;

 

/
