--------------------------------------------------------
--  DDL for Package Body JG_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_UTILITY_PKG" as
/* $Header: jgzzutlb.pls 115.1 2002/11/18 14:19:18 arimai ship $ */

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    out NOCOPY	- Print an output line					      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard output	information sending it to outfile so that     |
 |    the client tool can out NOCOPY it for the user.                                |
 |                                                                            |
 | REQUIRES                                                                   |
 |    line			The line of text that will be displayed.      |
 |                                                                            |
 | HISTORY                                                                    |
 |	30-12-1998		Kai Pigg	Created			      |
 *----------------------------------------------------------------------------*/
  procedure out( line in varchar2 ) is
  begin
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, line);
  end;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    log - Print an log line					              |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard output	information sending it to logfile so that     |
 |    the client tool can out NOCOPY it for the user.                                |
 |                                                                            |
 | REQUIRES                                                                   |
 |    line			The line of text that will be displayed.      |
 |                                                                            |
 | HISTORY                                                                    |
 |	30-12-1998		Kai Pigg	Created			      |
 *----------------------------------------------------------------------------*/
  procedure log( line in varchar2 ) is
  begin
    FND_FILE.PUT_LINE(FND_FILE.LOG, line);
  end;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    debug      - Print a debug message                                      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard debug information sending it to logfile so that       |
 |    the client tool can log it for the user.                                |
 |                                                                            |
 | REQUIRES                                                                   |
 |    line			The line of text that will be displayed.      |
 |                                                                            |
 | HISTORY                                                                    |
 |	30-12-1998		Kai Pigg	Created			      |
 *----------------------------------------------------------------------------*/
  procedure debug( line in varchar2 ) is
  begin
    if JG_UTILITY_PKG.debug_flag then
      FND_FILE.PUT_LINE(FND_FILE.LOG, line);
    end if;
  end;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    enable_debug      - Enable run time debugging                           |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard debug information sending it to dbms_output so that   |
 |    the client tool can log it for the user.                                |
 |                                                                            |
 | REQUIRES                                                                   |
 |                                                                            |
 | HISTORY                                                                    |
 |    30-DEC-1998	Kai Pigg	Created                               |
 *----------------------------------------------------------------------------*/
procedure enable_debug is
begin
   JG_UTILITY_PKG.debug_flag := true;
end;

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    disable_debug     - Disable run time debugging                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard debug information sending it to dbms_output so that   |
 |    the client tool can log it for the user.                                |
 |                                                                            |
 | REQUIRES                                                                   |
 |                                                                            |
 | HISTORY                                                                    |
 |    30-12-1998	Kai Pigg	Created				      |
 *----------------------------------------------------------------------------*/
 procedure disable_debug is
 begin
   JG_UTILITY_PKG.debug_flag := false;
 end;

end JG_UTILITY_PKG;

/
