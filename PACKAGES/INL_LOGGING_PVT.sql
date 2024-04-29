--------------------------------------------------------
--  DDL for Package INL_LOGGING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INL_LOGGING_PVT" AUTHID CURRENT_USER AS
/* $Header: INLVLOGS.pls 120.4.12010000.1 2008/09/25 07:34:16 appldev ship $ */

PROCEDURE Log_Statement (p_module_name IN VARCHAR2,
                         p_procedure_name IN VARCHAR2,
                         p_debug_info IN VARCHAR2);

PROCEDURE Log_Variable (p_module_name IN VARCHAR2,
                        p_procedure_name IN VARCHAR2,
                        p_var_name IN VARCHAR2,
                        p_var_value IN VARCHAR2);

PROCEDURE Log_BeginProc (p_module_name IN VARCHAR2,
                         p_procedure_name IN VARCHAR2);

PROCEDURE Log_EndProc (p_module_name IN VARCHAR2,
                       p_procedure_name IN VARCHAR2);

PROCEDURE Log_APICallIn (p_module_name IN VARCHAR2,
                         p_procedure_name IN VARCHAR2,
                         p_call_api_name IN VARCHAR2,
                         p_in_param_name1 IN VARCHAR2   := NULL,
                         p_in_param_value1 IN VARCHAR2  := NULL,
                         p_in_param_name2 IN VARCHAR2   := NULL,
                         p_in_param_value2 IN VARCHAR2  := NULL,
                         p_in_param_name3 IN VARCHAR2   := NULL,
                         p_in_param_value3 IN VARCHAR2  := NULL,
                         p_in_param_name4 IN VARCHAR2   := NULL,
                         p_in_param_value4 IN VARCHAR2  := NULL,
                         p_in_param_name5 IN VARCHAR2   := NULL,
                         p_in_param_value5 IN VARCHAR2  := NULL,
                         p_in_param_name6 IN VARCHAR2   := NULL,
                         p_in_param_value6 IN VARCHAR2  := NULL,
                         p_in_param_name7 IN VARCHAR2   := NULL,
                         p_in_param_value7 IN VARCHAR2  := NULL,
                         p_in_param_name8 IN VARCHAR2   := NULL,
                         p_in_param_value8 IN VARCHAR2  := NULL,
                         p_in_param_name9 IN VARCHAR2   := NULL,
                         p_in_param_value9 IN VARCHAR2  := NULL,
                         p_in_param_name10 IN VARCHAR2  := NULL,
                         p_in_param_value10 IN VARCHAR2 := NULL);

PROCEDURE Log_APICallOut (p_module_name IN VARCHAR2,
                          p_procedure_name IN VARCHAR2,
                          p_call_api_name IN VARCHAR2,
                          p_out_param_name1 IN VARCHAR2   := NULL,
                          p_out_param_value1 IN VARCHAR2  := NULL,
                          p_out_param_name2 IN VARCHAR2   := NULL,
                          p_out_param_value2 IN VARCHAR2  := NULL,
                          p_out_param_name3 IN VARCHAR2   := NULL,
                          p_out_param_value3 IN VARCHAR2  := NULL,
                          p_out_param_name4 IN VARCHAR2   := NULL,
                          p_out_param_value4 IN VARCHAR2  := NULL,
                          p_out_param_name5 IN VARCHAR2   := NULL,
                          p_out_param_value5 IN VARCHAR2  := NULL,
                          p_out_param_name6 IN VARCHAR2   := NULL,
                          p_out_param_value6 IN VARCHAR2  := NULL,
                          p_out_param_name7 IN VARCHAR2   := NULL,
                          p_out_param_value7 IN VARCHAR2  := NULL,
                          p_out_param_name8 IN VARCHAR2   := NULL,
                          p_out_param_value8 IN VARCHAR2  := NULL,
                          p_out_param_name9 IN VARCHAR2   := NULL,
                          p_out_param_value9 IN VARCHAR2  := NULL,
                          p_out_param_name10 IN VARCHAR2  := NULL,
                          p_out_param_value10 IN VARCHAR2 := NULL) ;

PROCEDURE Log_Event (p_module_name IN VARCHAR2,
                     p_procedure_name IN VARCHAR2,
                     p_debug_info IN VARCHAR2);

PROCEDURE Log_Exception   (p_module_name IN VARCHAR2,
                           p_procedure_name IN VARCHAR2);

PROCEDURE Log_ExpecError (p_module_name IN VARCHAR2,
                          p_procedure_name IN VARCHAR2,
                          p_debug_info IN VARCHAR2 := NULL);

PROCEDURE Log_UnexpecError (p_module_name IN VARCHAR2,
                           p_procedure_name IN VARCHAR2);

END INL_LOGGING_PVT;

/
