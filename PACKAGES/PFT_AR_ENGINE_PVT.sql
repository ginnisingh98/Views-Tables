--------------------------------------------------------
--  DDL for Package PFT_AR_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PFT_AR_ENGINE_PVT" AUTHID CURRENT_USER AS
/* $Header: PFTVARES.pls 120.0 2005/06/06 19:03:45 appldev noship $ */

---------------------------------------------
--  Package Constants
---------------------------------------------
  G_BLOCK                constant varchar2(80) := 'PFT.PLSQL.PFT_AR_ENGINE_PVT';
  G_PFT                  constant varchar2(3)  := 'PFT';
  G_FEM                  constant varchar2(3)  := 'FEM';
  G_PFT_SOURCE_SYSTEM_DC constant varchar2(3)  := 'PFT';


---------------------------------------------
--  Variable Types
---------------------------------------------
  id_t                            number(9);
  pct_t                           number(3,2);
  flag_t                          varchar2(1);
  currency_code_t                 varchar2(15);
  varchar2_std_t                  varchar2(30);
  varchar2_150_t                  varchar2(150);
  varchar2_240_t                  varchar2(240);

---------------------------------------------
--  Package Types
---------------------------------------------

  type dynamic_cursor is ref cursor;

  type dimension_record is record (
    dimension_id                  number
    ,dimension_varchar_label      varchar2_std_t%type
    ,composite_dimension_flag     flag_t%type
    ,member_col                   varchar2_std_t%type
    ,member_b_table               varchar2_std_t%type
    ,attr_table                   varchar2_std_t%type
    ,hier_table                   varchar2_std_t%type
    ,hier_versioning_type_code    varchar2_std_t%type
  );

  type request_record is record (
    continue_process_on_err_flg   flag_t%type
    ,act_rate_obj_type_code        varchar2_std_t%type
    ,dataset_grp_obj_def_id       id_t%type
    ,dataset_grp_obj_id           id_t%type
    ,dimension_rec                dimension_record
    ,effective_date               date
    ,effective_date_varchar       varchar2_240_t%type
    ,entered_currency_flag        flag_t%type
    ,entered_exch_rate_date       date
    ,functional_currency_code     currency_code_t%type
    ,ledger_id                    number
    ,local_vs_combo_id            id_t%type
    ,login_id                     number
    ,output_cal_period_id         number
    ,output_dataset_code          number
    ,pgm_app_id                   number
    ,pgm_id                       number
    ,resp_id                      number
    ,request_id                   number
    ,ruleset_obj_def_id           id_t%type
    ,ruleset_obj_id               id_t%type
    ,ruleset_obj_name             varchar2_150_t%type
    ,source_system_code           number
    ,source_system_display_code   varchar2_150_t%type
    ,submit_obj_id                id_t%type
    ,submit_obj_type_code         varchar2_std_t%type
    ,user_id                      number
  );

  type rule_record is record (
    act_rate_obj_id               id_t%type
    ,act_rate_obj_def_id          id_t%type
    ,act_rate_obj_type_code       varchar2_std_t%type
    ,act_rate_sequence            number
    ,cond_exists                  boolean
    ,cond_obj_def_id              id_t%type
    ,cond_obj_id                  id_t%type
    ,entered_currency_code        currency_code_t%type
    ,entered_exch_rate            number
    ,entered_exch_rate_den        number
    ,entered_exch_rate_num        number
    ,hier_obj_def_id              id_t%type
    ,hier_obj_id                  id_t%type
    ,local_vs_combo_id            id_t%type
    ,rate_sequence_name           varchar2_std_t%type
    ,drv_sequence_name            varchar2_std_t%type
    ,top_node_flag                flag_t%type
    ,output_to_rate_stat_flag     flag_t%type
    ,act_rate_obj_name            varchar2_150_t%type
  );

  type rowid_type is table of rowid
  index by binary_integer;

  type number_type is table of number
  index by binary_integer;

  type pct_type is table of number(3,2)
  index by binary_integer;

  type date_type is table of date
  index by binary_integer;

  type flag_type is table of varchar2(1)
  index by binary_integer;

  type lang_type is table of varchar2(4)
  index by binary_integer;

  type varchar2_std_type is table of varchar2(30)
  index by binary_integer;

  type varchar2_150_type is table of varchar2(150)
  index by binary_integer;

  type varchar2_1000_type is table of varchar2(1000)
  index by binary_integer;



/*===========================================================================+
 | PROCEDURE
 |   Act_Rate_Request
 |
 | DESCRIPTION
 |   This procedure is called by Concurrent Manager to run the activity rate
 |   engine
 |
 | SCOPE - PUBLIC
 |
 +===========================================================================*/

PROCEDURE Act_Rate_Request (
  errbuf                          out nocopy varchar2
  ,retcode                        out nocopy varchar2
  ,p_obj_id                       in number
  ,p_effective_date               in varchar2
  ,p_ledger_id                    in number
  ,p_output_cal_period_id         in number
  ,p_dataset_grp_obj_def_id       in number
  ,p_continue_process_on_err_flg  in varchar2
  ,p_source_system_code           in number
);

/*===========================================================================+
 | PROCEDURE
 |   Calc_Driver_Values
 |
 | DESCRIPTION
 |   This procedure is called by the Multi-Processing Engine so that driver
 |   calculation can be done in parallel through multiple subrequests.
 |
 | SCOPE - PUBLIC
 |
 +===========================================================================*/

PROCEDURE Calc_Driver_Values (
  p_eng_sql                       in varchar2
  ,p_slc_pred                     in varchar2
  ,p_proc_num                     in number
  ,p_part_code                    in number
  ,p_fetch_limit                  in number
  ,p_request_id                   in number
  ,p_dataset_grp_obj_def_id       in number
  ,p_effective_date_varchar       in varchar2
  ,p_output_cal_period_id         in number
  ,p_ledger_id                    in number
  ,p_local_vs_combo_id            in number
  ,p_user_id                      in number
  ,p_login_id                     in number
  ,p_act_rate_obj_id              in number
  ,p_act_rate_obj_def_id          in number
  ,p_hier_obj_def_id              in number
  ,p_act_hier_where_clause        in long
  ,p_act_cond_where_clause        in long
);




END PFT_AR_ENGINE_PVT;

 

/
