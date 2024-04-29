--------------------------------------------------------
--  DDL for Package EDW_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_LOG" AUTHID CURRENT_USER AS
/* $Header: EDWSRLGS.pls 115.8 2003/11/06 01:06:04 vsurendr ship $  */
VERSION	CONSTANT CHAR(80) := '$Header: EDWSRLGS.pls 115.8 2003/11/06 01:06:04 vsurendr ship $';

-- ------------------------
-- Global Variables
-- ------------------------
Type varcharTableType is Table of varchar2(400) index by binary_integer;
g_debug				BOOLEAN := FALSE;
g_version_GT_1159 BOOLEAN;
g_fnd_log_module varchar2(200);
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
PROCEDURE put_line(p_text VARCHAR2,p_severity number);
procedure put_fnd_log(p_text varchar2,p_severity number);
function is_oracle_apps_GT_1159 return boolean;
function get_app_version return varchar2;
function parse_names(
p_list varchar2,
p_separator varchar2,
p_names out NOCOPY varcharTableType,
p_number_names out NOCOPY number) return boolean;
procedure put_conc_log(p_text varchar2);
end;

 

/
