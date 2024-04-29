--------------------------------------------------------
--  DDL for Package MSD_CONC_LOG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_CONC_LOG_UTIL" AUTHID CURRENT_USER as
/* $Header: msdcluts.pls 115.3 2002/11/06 22:59:24 pinamati ship $ */
    --
    -- Define Exception
    --
    EX_FATAL_ERROR Exception;
    --
    --
    C_FATAL_ERROR Constant varchar2(30):='FATAL ERROR';
    C_ERROR       Constant varchar2(30):='ERROR';
    C_WARNING     Constant varchar2(30):='WARNING';
    C_INFORMATION Constant varchar2(30):='INFORMATION';
    C_HEADING     Constant varchar2(30):='HEADING';
    C_SECTION     Constant varchar2(30):='SECTION';
    C_SUCCESS	  Constant varchar2(30):='SUCCESS';
    --
    C_OUTPUT_TO_FNDFILE Constant varchar2(30):='FNDFILE';
    C_OUTPUT_TO_SERVER  Constant varchar2(30):='SERVER';
    --
    -- functions/proceudres
    --
    Procedure display_message(p_text varchar2, msg_type varchar2);
    Procedure Initilize;
    Procedure Initilize(p_output_to in varchar2);
    Function Result return varchar2;
    Function retcode return number;
    --
End;

 

/
