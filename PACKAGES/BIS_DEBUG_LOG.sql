--------------------------------------------------------
--  DDL for Package BIS_DEBUG_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DEBUG_LOG" AUTHID CURRENT_USER AS
/* $Header: BISDLOGS.pls 120.1 2005/06/07 10:50:03 aguwalan noship $  */
-- ------------------------
-- Global Variables
-- ------------------------
g_debug BOOLEAN:=FALSE;
-- ------------------------
-- Public Procedures
-- ------------------------
PROCEDURE setup_file(
p_log_file VARCHAR2,
p_out_file VARCHAR2,
p_directory VARCHAR2);
PROCEDURE debug(p_text VARCHAR2);
PROCEDURE debug_line(p_text VARCHAR2);
PROCEDURE debug_line_n(p_text VARCHAR2);
PROCEDURE put(p_text VARCHAR2) ;
PROCEDURE put_line(p_text VARCHAR2);
PROCEDURE put_line_n(p_text VARCHAR2);
PROCEDURE put_out(p_text VARCHAR2);
PROCEDURE put_out_n(p_text VARCHAR2);
PROCEDURE new_line;
PROCEDURE put_time;
PROCEDURE debug_time;

procedure close;
function get_time return date;
procedure set_debug ;
procedure unset_debug;

function get_bis_schema_name return varchar2;


/*
 * Added for FND_LOG uptaking.
 */
PROCEDURE put(p_text VARCHAR2, p_severity NUMBER);
PROCEDURE put_line(p_text VARCHAR2, p_severity NUMBER);
PROCEDURE put_line_n(p_text VARCHAR2, p_severity NUMBER);
PROCEDURE debug(p_text VARCHAR2, p_severity NUMBER);
PROCEDURE debug_line(p_text VARCHAR2, p_severity NUMBER);
PROCEDURE debug_line_n(p_text VARCHAR2, p_severity NUMBER);

end;

 

/
