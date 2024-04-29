--------------------------------------------------------
--  DDL for Package POA_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_LOG" AUTHID CURRENT_USER AS
/* $Header: POALOGS.pls 115.4 2003/01/09 23:22:05 rvickrey ship $  */

-- ------------------------
-- Global Variables
-- ------------------------
g_debug				BOOLEAN := FALSE;

-- ------------------------
-- Public Procedures
-- ------------------------
PROCEDURE put_names(
		p_log_file		VARCHAR2,
		p_out_file		VARCHAR2,
		p_directory		VARCHAR2);

FUNCTION duration(
		p_duration		number) RETURN VARCHAR2;

PROCEDURE debug_line(
                p_text			VARCHAR2);

PROCEDURE put_line(
                p_text			VARCHAR2);

PROCEDURE output_line(
                p_text                  VARCHAR2);

PROCEDURE setup(filename                VARCHAR2);

PROCEDURE wrapup(status                 VARCHAR2);

end;

 

/
