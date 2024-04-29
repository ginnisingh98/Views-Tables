--------------------------------------------------------
--  DDL for Package PAY_PROC_LOGGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PROC_LOGGING" AUTHID CURRENT_USER as
/* $Header: pycolog.pkh 120.1.12010000.1 2008/07/27 22:22:30 appldev ship $ */

g_log_file clob;
g_log_position number;
g_flog_file clob;
g_flog_position number;

/*
Logging Categories
*/
PY_GENERAL constant varchar2(1) := 'G';
PY_ROUTING constant varchar2(1) := 'M';
PY_PERFORM constant varchar2(1) := 'P';
PY_ELEMETY constant varchar2(1) := 'E';
PY_BALFTCH constant varchar2(1) := 'L';
PY_BALMAIN constant varchar2(1) := 'B';
PY_BALOUTP constant varchar2(1) := 'I';
PY_RREOUTP constant varchar2(1) := 'R';
PY_FORMULA constant varchar2(1) := 'F';
PY_CCACHES constant varchar2(1) := 'C';
PY_CCACHEQ constant varchar2(1) := 'Q';
PY_CCACHEE constant varchar2(1) := 'S';
PY_VERTEXL constant varchar2(1) := 'V';
PY_HRTRACE constant varchar2(1) := 'T';
PY_INTRSQL constant varchar2(1) := 'Z';
PY_ALLCATS constant varchar2(1) := 'A';

procedure PY_ENTRY(p_print_string in varchar2);
procedure PY_EXIT(p_print_string in varchar2);
procedure PY_LOG(p_print_string in varchar2);
procedure PY_LOG_WRT(p_print_string in varchar2);
procedure PY_LOG_TXT(p_logging_type in varchar2,
                     p_print_string in varchar2);
function PY_LOG_FORMULA(p_print_string in varchar2) return number;
procedure init_logging;
procedure deinit_logging;
procedure init_form_logging;
procedure deinit_form_logging;



--
end pay_proc_logging;

/
