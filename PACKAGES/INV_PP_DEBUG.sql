--------------------------------------------------------
--  DDL for Package INV_PP_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PP_DEBUG" AUTHID CURRENT_USER AS
/* $Header: INVPPDGS.pls 120.0 2005/05/25 05:58:19 appldev noship $ */
g_debug_mode_yes CONSTANT NUMBER := 1;
g_debug_mode_no  CONSTANT NUMBER := 0;
PROCEDURE set_debug_mode(p_mode IN NUMBER);
FUNCTION  is_debug_mode RETURN BOOLEAN;
PROCEDURE set_last_dynamic_sql(p_sql IN long);
FUNCTION  get_last_dynamic_sql RETURN long;
PROCEDURE set_last_error_message(p_error_msg IN long);
FUNCTION  get_last_error_message RETURN long;
PROCEDURE set_last_error_position(p_error_pos IN NUMBER);
FUNCTION  get_last_error_position RETURN NUMBER;
PROCEDURE set_debug_pipe_name(p_pipename IN VARCHAR2);
PROCEDURE send_message_to_pipe(p_message IN VARCHAR2);
PROCEDURE send_long_to_pipe(p_message IN long);
PROCEDURE send_last_dynamic_sql;
PROCEDURE send_last_error_position;
PROCEDURE send_last_error_message;

END inv_pp_debug;

 

/
