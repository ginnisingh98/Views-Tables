--------------------------------------------------------
--  DDL for Package Body CN_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_DEBUG" AS
-- $Header: cnsydbgb.pls 115.1 99/07/16 07:17:15 porting ship $


--
-- Private package variables
--
  debug_level	NUMBER := 0;	-- the current debug level; 0 = off.
  pipename	VARCHAR2(20) := NULL;

--
-- Public Procedures
--

  PROCEDURE print_msg (
	X_message	VARCHAR2,
	debug_code	NUMBER) IS
    status	integer;
  BEGIN

    IF ((debug_level > 0) AND (debug_code <= debug_level) AND
	(pipename IS NOT NULL)) THEN

null;
--       dbms_output.put_line(X_message);
--      dbms_pipe.pack_message(X_message);
--      status := dbms_pipe.send_message(pipename);

    END IF;

  END print_msg;


  PROCEDURE set_debug_level (new_level	NUMBER) IS
  BEGIN
    debug_level := new_level;
  END set_debug_level;


  PROCEDURE set_pipename (name	VARCHAR2) IS
  BEGIN
    pipename := name;
  END set_pipename;


  PROCEDURE init_pipe (name	VARCHAR2, new_level	NUMBER) IS
  BEGIN
    pipename := name;
    debug_level := new_level;
  END init_pipe;


END cn_debug;

/
