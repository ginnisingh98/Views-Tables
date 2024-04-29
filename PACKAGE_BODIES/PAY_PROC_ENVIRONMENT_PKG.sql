--------------------------------------------------------
--  DDL for Package Body PAY_PROC_ENVIRONMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PROC_ENVIRONMENT_PKG" as
/* $Header: pycopenv.pkb 120.3.12010000.1 2008/07/27 22:22:46 appldev ship $ */
--
/*
   update_pop_action_status

   This procedure updates the action population then issues a commit.
*/
procedure update_pop_action_status(p_payroll_action_id in number,
                                   p_status in varchar2)
is
begin
--
   UPDATE PAY_PAYROLL_ACTIONS PAC
   SET    PAC.ACTION_POPULATION_STATUS = p_status,
          PAC.LAST_UPDATE_DATE         = SYSDATE,
          PAC.LAST_UPDATED_BY          = g_user_id,
          PAC.LAST_UPDATE_LOGIN        = g_login_id
   WHERE  PAC.PAYROLL_ACTION_ID        = p_payroll_action_id;
--
   commit;
--
end update_pop_action_status;
--
/*
   initialise_proc_env

   Initialise the process env.
*/
procedure initialise_proc_env
is
begin
--
   process_env_type := TRUE;
--
   /* need to setup the trace options */
--
   if (instr(pay_proc_environment_pkg.logging_category,
             pay_proc_logging.PY_INTRSQL) <> 0) then
--
     if (instr(pay_proc_environment_pkg.logging_category,
             pay_proc_logging.PY_HRTRACE) <> 0) then
--
        hr_utility.trace_on;
        hr_utility.set_trace_options('TRACE_DEST:PAY_LOG');
--
     end if;
--
     pay_proc_logging.init_logging;
--
   end if;

   if (instr(pay_proc_environment_pkg.logging_category,
             pay_proc_logging.PY_FORMULA) <> 0)
   then
     pay_proc_logging.init_form_logging;
   end if;


--
end initialise_proc_env;
--
/*
   deinitialise_proc_env

   Deinitialise the process env.
*/
procedure deinitialise_proc_env
is
begin
--
   /* need to setup the trace options */
--
   if (instr(pay_proc_environment_pkg.logging_category,
             pay_proc_logging.PY_INTRSQL) <> 0) then
--
     hr_utility.trace_off;
     pay_proc_logging.deinit_logging;
--
   end if;
--
   if (instr(pay_proc_environment_pkg.logging_category,
             pay_proc_logging.PY_FORMULA) <> 0)
   then
     pay_proc_logging.deinit_form_logging;
   end if;

   process_env_type := FALSE;
--
end deinitialise_proc_env;
--
/*
   get_pactid

   Returns the environment pactid

   This looks like a strange procedure, but its need to workaround
   and RDBMS issue on referening PL/SQL variables in SQL statements
*/
function get_pactid return number
is
begin
   return pactid;
end get_pactid;
--
begin
   logging_level := 0;
   logging_category := '';
   process_env_type := FALSE;
end pay_proc_environment_pkg;

/
