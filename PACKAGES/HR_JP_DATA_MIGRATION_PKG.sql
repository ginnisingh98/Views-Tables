--------------------------------------------------------
--  DDL for Package HR_JP_DATA_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JP_DATA_MIGRATION_PKG" AUTHID CURRENT_USER AS
/* $Header: hrjpdtmg.pkh 120.3.12010000.1 2008/07/28 03:26:14 appldev ship $ */
--
g_legislation_code varchar2(2);
--
g_skip_qualify varchar2(1);
--
g_sql_run varchar2(1);
--
g_mig_date date;
g_skip_manual_upd varchar2(1) := 'Y';
g_skip_out_range_upd varchar2(1) := 'Y';
g_upd_mode varchar2(30); /* UPDATE, OVERRIDE */
g_exc_match_exp_smr varchar2(1) := 'N';
--
type t_ass_hi_smr_rec is record(
  bg_id    per_business_groups.business_group_id%type,
  bg_name  per_business_groups.name%type,
  ass_id   per_all_assignments_f.assignment_id%type,
  ass_num  per_all_assignments_f.assignment_number%type,
  del_done varchar2(1),
  hi_mr    pay_element_entry_values_f.screen_entry_value%type);
--
type t_ass_hi_smr_tbl is table of t_ass_hi_smr_rec index by binary_integer;
--
g_range_ass_hi_smr_tbl t_ass_hi_smr_tbl;
--
g_valid varchar2(1) := 'N';
g_log   varchar2(1) := 'Y';
--
g_detail_debug boolean := false;
g_debug boolean := hr_utility.debug_enabled;
--
--
  PROCEDURE ELEMENT_RUN_RESULT_COPY(
    P_MODE        IN  VARCHAR2,
    P_PARAMETER_NAME  IN  VARCHAR2,
    P_PARAMETER_VALUE IN  NUMBER);
--
  PROCEDURE ADD_NEW_INPUT_VALUE(
    P_MODE        IN  VARCHAR2,
    P_PARAMETER_NAME  IN  VARCHAR2,
    P_PARAMETER_VALUE IN  NUMBER);
--
  PROCEDURE END_ELEMENT_ENTRY(
    P_MODE        IN  VARCHAR2,
    P_PARAMETER_NAME  IN  VARCHAR2,
    P_PARAMETER_VALUE IN  NUMBER,
    P_SESSION_DATE    IN DATE);
--
--
function get_ass_info(
  p_assignment_id  in number,
  p_effective_date in date)
return t_ass_hi_smr_rec;
--
function get_mig_date
return date;
--
procedure insert_session(
            p_effective_date in date);
--
procedure delete_session;
--
procedure qualify_hi_smr_hd(
  p_assignment_id in number);
--
procedure migrate_hi_smr_hd(
  p_assignment_id in number);
--
procedure init_def_hi_smr_data;
--
procedure val_mig_smr_assact(
  p_business_group_id   in number,
  p_business_group_name in varchar2,
  p_assignment_id       in number,
  p_assignment_number   in varchar2,
  p_session_date        in date,
  p_valid_delete        in out nocopy varchar2);
--
procedure mig_smr_assact(
  p_business_group_id   in number,
  p_business_group_name in varchar2,
  p_assignment_id       in number,
  p_assignment_number   in varchar2,
  p_session_date        in date,
  p_hi_mr               in varchar2);
--
-- this is for manual run by script, recommend to use generic upgrade instead of this.
procedure run_mig_smr;
--
END HR_JP_DATA_MIGRATION_PKG;

/
