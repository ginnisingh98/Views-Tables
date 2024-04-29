--------------------------------------------------------
--  DDL for Package FEM_RU_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_RU_ENGINE_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVRUES.pls 120.0 2005/06/06 21:31:14 appldev noship $ */

---------------------------------------------
--  Package Constants
---------------------------------------------
  G_BLOCK                constant varchar2(80) := 'FEM.PLSQL.FEM_RU_ENGINE_PVT';
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
    ,hier_rollup_table            varchar2_std_t%type
    ,hier_versioning_type_code    varchar2_std_t%type
  );

  type request_record is record (
    continue_process_on_err_flg   flag_t%type
    ,dataset_grp_obj_def_id       id_t%type
    ,dataset_grp_obj_id           id_t%type
    ,dimension_rec                dimension_record
    ,effective_date               date
    ,effective_date_varchar       varchar2_240_t%type
    ,entered_currency_flag        flag_t%type
    ,exch_rate_date               date
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
    ,rollup_obj_type_code         varchar2_std_t%type
    ,rollup_rule_def_table        varchar2_std_t%type
    ,rollup_type_code             varchar2_std_t%type
    ,ruleset_obj_def_id           id_t%type
    ,ruleset_obj_id               id_t%type
    ,ruleset_obj_name             varchar2_150_t%type
    ,source_system_code           number
    ,submit_obj_id                id_t%type
    ,submit_obj_type_code         varchar2_std_t%type
    ,user_id                      number
  );

  type rule_record is record (
    cond_exists                   boolean
    ,cond_obj_def_id              id_t%type
    ,cond_obj_id                  id_t%type
    ,entered_currency_code        currency_code_t%type
    ,entered_exch_rate            number
    ,entered_exch_rate_den        number
    ,entered_exch_rate_num        number
    ,hier_obj_def_id              id_t%type
    ,hier_obj_id                  id_t%type
    ,hier_rollup_table            varchar2_std_t%type
    ,local_vs_combo_id            id_t%type
    ,rollup_obj_def_id            id_t%type
    ,rollup_obj_id                id_t%type
    ,rollup_obj_name              varchar2_150_t%type
    ,rollup_obj_type_code         varchar2_std_t%type
    ,rollup_sequence              number
    ,sequence_name                varchar2_std_t%type
    ,statistic_basis_id           number
  );

  type sql_record is record (
    comp_dim_comp_cols_using      long
    ,comp_dim_data_cols_using     long
    ,comp_dim_data_cols_on        long
    ,comp_dim_comp_cols_insert    long
    ,comp_dim_data_cols_insert    long
    ,comp_dim_comp_cols_values    long
    ,comp_dim_data_cols_values    long
  );

  type ledger_record is record (
    currency_code                 currency_code_t%type
    ,exch_rate                    number
    ,exch_rate_den                number
    ,exch_rate_num                number
  );

  type number_table is table of number
  index by binary_integer;

  type ledger_table is table of ledger_record
  index by binary_integer;


/*===========================================================================+
 | PROCEDURE
 |              Rollup_Request
 |
 | DESCRIPTION
 |              todo
 |
 | SCOPE - PUBLIC
 |
 +===========================================================================*/


PROCEDURE Rollup_Request (
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



END FEM_RU_ENGINE_PVT;

 

/
