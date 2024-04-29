--------------------------------------------------------
--  DDL for Package CN_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_DEBUG" AUTHID CURRENT_USER AS
-- $Header: cnsydbgs.pls 115.1 99/07/16 07:17:18 porting ship $


--
-- Procedure Name
--   print_msg
-- Purpose
--   Dumps a message into a debug messages table
-- History
--   11/17/93           Devesh Khatu		Created
--
  PROCEDURE print_msg (
	X_message	VARCHAR2,
	debug_code	NUMBER);

--
-- Procedure Name
--   set_debug_level
-- Purpose
--   Sets current value of debug level
-- History
--   11/17/93           Devesh Khatu		Created
--
  PROCEDURE set_debug_level (new_level  NUMBER);

--
-- Procedure Name
--   set_pipename
-- Purpose
--   Sets name of dbms pipe to output error mesages to
-- History
--   11/17/93           Devesh Khatu		Created
--
  PROCEDURE set_pipename (name  VARCHAR2);

--
-- Procedure Name
--   init_pipe
-- Purpose
--   Initializes name of dbms pipe and the debug_level
-- History
--   1/17/94           Devesh Khatu		Created
--
  PROCEDURE init_pipe (name  VARCHAR2, new_level	NUMBER);


END cn_debug;

 

/
