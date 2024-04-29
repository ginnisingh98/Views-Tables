--------------------------------------------------------
--  DDL for Package PAY_PROC_ENVIRONMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PROC_ENVIRONMENT_PKG" AUTHID CURRENT_USER as
/* $Header: pycopenv.pkh 120.5.12010000.1 2008/07/27 22:22:48 appldev ship $ */

/*

Action Types

*/
      PYG_AT_RET constant varchar2(1) := 'O';
      PYG_AT_ARC constant varchar2(1) := 'X';
      PYG_AT_RUN constant varchar2(1) := 'R';
      PYG_AT_ADV constant varchar2(1) := 'F';
      PYG_AT_RTA constant varchar2(1) := 'G';
      PYG_AT_RTE constant varchar2(1) := 'L';
      PYG_AT_RCS constant varchar2(1) := 'S';
      PYG_AT_PUR constant varchar2(1) := 'Z';  -- Purge.
      PYG_AT_ADE constant varchar2(1) := 'W';
      PYG_AT_BEE constant varchar2(3) := 'BEE';  -- BEE Process
      PYG_AT_ECS constant varchar2(3) := 'EC';  -- Estimate Costing  Process
      PYG_AT_BAL constant varchar2(1) := 'B';
      PYG_AT_PAY constant varchar2(1) := 'P';
      PYG_AT_MAG constant varchar2(1) := 'M';
      PYG_AT_CHQ constant varchar2(1) := 'H';
      PYG_AT_CSH constant varchar2(1) := 'A';
      PYG_AT_COS constant varchar2(1) := 'C';
      PYG_AT_PST constant varchar2(2) := 'PP';
      PYG_AT_PRU constant varchar2(3) := 'PRU'; -- Payment Roll up
      PYG_AT_TGL constant varchar2(1) := 'T';
      PYG_AT_REV constant varchar2(1) := 'V';   -- Reversal

      /* Environment Info */
      chunk_size   number;
      chunk_method pay_legislation_rules.rule_mode%type;
      logging_category pay_action_parameters.parameter_value%type;
      logging_level    number;
      g_user_id number;
      g_login_id number;
      process_env_type boolean;

      /* Payroll Action Info */
      action_type         pay_payroll_actions.action_type%type;
      payroll_id          pay_payroll_actions.payroll_id%type;
      retro_definition_id pay_payroll_actions.retro_definition_id%type;
      pactid              pay_payroll_actions.payroll_action_id%type;
      bgid                pay_payroll_actions.business_group_id%type;
      legc                per_business_groups.legislation_code%TYPE;
--
/*
   update_pop_action_status

   This procedure updates the action population then issues a commit.
*/
procedure update_pop_action_status(p_payroll_action_id in number,
                                   p_status in varchar2);

/*
   initialise_proc_env

   This procedure initialises the processing environment after some of
   the above globals are set.
*/
procedure initialise_proc_env;
/*
   deinitialise_proc_env

   This procedure deinitialises the processing environment.
*/
procedure deinitialise_proc_env;
--
/*
   get_pactid

   Returns the environment pactid

   This looks like a strange procedure, but its need to workaround
   and RDBMS issue on referening PL/SQL variables in SQL statements
*/
function get_pactid return number;
--
end pay_proc_environment_pkg;

/
