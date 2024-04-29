--------------------------------------------------------
--  DDL for Package ECX_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_ACTIONS" AUTHID CURRENT_USER as
-- $Header: ECXACTNS.pls 120.4 2006/01/05 03:50:06 arsriniv ship $

function find_stack_variable
	(
	i_variable_name		IN		VARCHAR2,
	i_stack_pos		OUT NOCOPY	pls_integer
	) return boolean;

procedure execute_stage_data
        (
        i_stage         	IN      pls_integer,
        i_level         	IN      pls_integer,
        i_direction         	IN      varchar2
        );

procedure append_clause_for_view
        (
        i_stage         	IN      pls_integer,
        i_level         	IN      pls_integer
        );

procedure bind_variables_for_view
        (
        i_stage         	IN      pls_integer,
        i_level         	IN      pls_integer
        );

g_xslt_dir		varchar2(2000);
g_server_timezone	varchar2(2000);

/**
  Gets the timezone offset for the DB server timezone based on the date
**/
Function getTimeZoneOffset (year number, month number, day number, hour number,
                            minute number, second number, timezone varchar2)
return number;
procedure set_error_exit_program
    (
    i_err_type    in  pls_integer,
    i_err_code    in  pls_integer,
    i_err_msg     in  varchar2
    );

procedure set_error_exit_program(
    i_err_type    in  pls_integer,
    i_err_code    in  pls_integer,
    i_err_msg     in  varchar2,
    p_token1       in varchar2,
    p_value1       in varchar2 default null,
    p_token2       in varchar2 default null,
    p_value2       in varchar2 default null,
    p_token3       in varchar2 default null,
    p_value3       in varchar2 default null,
    p_token4       in varchar2 default null,
    p_value4       in varchar2 default null,
    p_token5       in varchar2 default null,
    p_value5       in varchar2 default null,
    p_token6       in varchar2 default null,
    p_value6       in varchar2 default null,
    p_token7       in varchar2 default null,
    p_value7       in varchar2 default null,
    p_token8       in varchar2 default null,
    p_value8       in varchar2 default null,
    p_token9       in varchar2 default null,
    p_value9       in varchar2 default null,
    p_token10      in varchar2 default null,
    p_value10      in varchar2 default null);


procedure transform_xml_with_xslt
	(
	i_filename		in	varchar2,
	i_version		in	number		default null,
	i_application_code	in	varchar2	default null
	);

Procedure get_clob(clobValue in clob , value in Varchar2 , clobout out nocopy clob);

procedure get_varchar(clobValue in clob , value in Varchar2 ,
                      valueOut out nocopy varchar2);

procedure delete_doctype;

procedure get_xml_fragment
          ( proc_name IN varchar2,
            xml_fragment  OUT NOCOPY varchar2
          );
end ecx_actions;

 

/
