--------------------------------------------------------
--  DDL for Package Body PAY_PROC_LOGGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PROC_LOGGING" as
/* $Header: pycolog.pkb 120.1.12010000.1 2008/07/27 22:22:28 appldev ship $ */

/*
   PY_ENTRY

   Standard log entry point call for batch processing
*/
procedure PY_ENTRY(p_print_string in varchar2)
is
l_print varchar2(4000);
begin
--
   if (instr(pay_proc_environment_pkg.logging_category,
              PY_ROUTING) <>  0
       or pay_proc_environment_pkg.process_env_type = FALSE
       ) then
--
    l_print := '';
    for i in 1..pay_proc_environment_pkg.logging_level loop
      l_print := l_print||'  ';
    end loop;
    l_print := l_print||'In  { '||p_print_string;
    PY_LOG_WRT(l_print);
--
    pay_proc_environment_pkg.logging_level :=
            pay_proc_environment_pkg.logging_level + 1;
--
   end if;
--
end PY_ENTRY;
--
/*
   PY_EXIT

   Standard log exit point call for batch processing
*/

procedure PY_EXIT(p_print_string in varchar2)
is
l_print varchar2(4000);
begin
--
   if (instr(pay_proc_environment_pkg.logging_category,
              PY_ROUTING) <> 0
       or pay_proc_environment_pkg.process_env_type = FALSE) then
--
    pay_proc_environment_pkg.logging_level :=
            pay_proc_environment_pkg.logging_level - 1;
--
    l_print := '';
    for i in 1..pay_proc_environment_pkg.logging_level loop
      l_print := l_print||'  ';
    end loop;
    l_print := l_print||'Out } '||p_print_string;
    PY_LOG_WRT(l_print);
--
   end if;
--
end PY_EXIT;
--
/*
   PY_LOG

   General logging call, used for the PY_GENERAL category.
*/
procedure PY_LOG(p_print_string in varchar2)
is
begin
--
   if (instr(pay_proc_environment_pkg.logging_category,
              PY_GENERAL) <> 0
       or pay_proc_environment_pkg.process_env_type = FALSE) then
--
    PY_LOG_WRT(p_print_string);
--
   end if;
--
end PY_LOG;
--
/*
   PY_LOG_WRT

   Writes the print string directly to the log file.
*/
procedure PY_LOG_WRT(p_print_string in varchar2)
is
text_size number;
begin
--
   if (pay_proc_environment_pkg.process_env_type = FALSE) then
--
      hr_utility.trace(p_print_string);
--
   elsif (instr(pay_proc_environment_pkg.logging_category,
             PY_INTRSQL) <> 0) then
--
      text_size := length(p_print_string||'
');
--
      dbms_lob.write(g_log_file,
                     text_size,
                     g_log_position,
                     p_print_string||'
'
                    );
--
      g_log_position := g_log_position + text_size;
--
   end if;
--
end PY_LOG_WRT;
--
/*
   PY_LOG_TXT

   Writes the print string directly to the log file
   for a specific logging category..
*/
procedure PY_LOG_TXT(p_logging_type in varchar2,
                     p_print_string in varchar2)
is
begin
--
   if (instr(pay_proc_environment_pkg.logging_category,
             p_logging_type) <> 0
        or p_logging_type = PY_ALLCATS
        or pay_proc_environment_pkg.process_env_type = FALSE) then

--
    PY_LOG_WRT(p_print_string);
--
   end if;
--
end PY_LOG_TXT;
--
/*
   init_logging

   Setup the process logging
*/
procedure init_logging
is
begin
   dbms_lob.createtemporary(g_log_file, TRUE);
end init_logging;

/*
   deinit_logging

   Shutdown the process logging
*/
procedure deinit_logging
is
begin
   dbms_lob.freetemporary(g_log_file);
   g_log_file := null;
   g_log_position := 1;
end deinit_logging;
--
/*
   init_logging

   Setup the formula logging
*/
procedure init_form_logging
is
begin
   dbms_lob.createtemporary(g_flog_file, TRUE);
end init_form_logging;

/*
   deinit_logging

   Shutdown the formula logging
*/
procedure deinit_form_logging
is
begin
   dbms_lob.freetemporary(g_flog_file);
   g_flog_file := null;
   g_flog_position := 1;
end deinit_form_logging;

/*
   PY_LOG_FORM

   Writes the print string directly to the formula log
*/
function PY_LOG_FORMULA(p_print_string in varchar2) return number
is
text_size number;
begin
--
   if (instr(pay_proc_environment_pkg.logging_category,
             PY_FORMULA) <> 0) then
--
      text_size := length(p_print_string||' ');
--
      dbms_lob.write(g_flog_file,
                     text_size,
                     g_flog_position,
                     p_print_string||' '
                    );
--
      g_flog_position := g_flog_position + text_size;
--
   end if;
--
return 1;
end PY_LOG_FORMULA;
--
begin
g_log_file := null;
g_log_position := 1;
g_flog_file := null;
g_flog_position := 1;

end pay_proc_logging;

/
