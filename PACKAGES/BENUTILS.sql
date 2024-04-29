--------------------------------------------------------
--  DDL for Package BENUTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BENUTILS" AUTHID CURRENT_USER as
/* $Header: benutils.pkh 120.1.12000000.1 2007/01/19 19:09:41 appldev noship $ */
  --
  g_banner_asterix    varchar2(70) := rpad('*',70,'*');
  g_banner_plus       varchar2(70) := rpad('+',70,'+');
  g_banner_minus      varchar2(70) := rpad('-',70,'-');
  g_sequence          number := 0;
  g_thread_id         number := 0;
  g_benefit_action_id number;
  g_inelg_action_cd  varchar2(40);
  g_empty_tab        ff_exec.outputs_t; -- donot populate. Only to be used a default value
  type g_number_table is varray(10000000) of number;
  type g_varchar2_table is varray(10000000) of varchar2(2000);
  type g_v2_30_table is varray(10000000) of varchar2(30);
  type g_v2_150_table is varray(10000000) of varchar2(150);
  type g_date_table is varray(10000000) of date;
  --
  -- Cache structure for lookups
  --
  type g_cache_lookup_object_rec is record
    (lookup_type hr_lookups.lookup_type%type,
     lookup_code hr_lookups.lookup_code%type);
  --
  type g_cache_lookup_object_table is table of g_cache_lookup_object_rec
    index by binary_integer;
  --
  g_cache_lookup_object g_cache_lookup_object_table;
  --
  type g_active_life_event is record
    (per_in_ler_id         ben_per_in_ler.per_in_ler_id%type,
     lf_evt_ocrd_dt        ben_per_in_ler.lf_evt_ocrd_dt%type,
     ntfn_dt               ben_per_in_ler.ntfn_dt%type,
     ler_id                ben_per_in_ler.ler_id%type,
     name                  ben_ler_f.name%type,
     typ_cd                ben_ler_f.typ_cd%type,
     ovridg_le_flag        ben_ler_f.ovridg_le_flag%type,
     ptnl_ler_trtmt_cd     ben_ler_f.ptnl_ler_trtmt_cd%type,
     object_version_number ben_per_in_ler.object_version_number%type,
     ptnl_ler_for_per_id   ben_per_in_ler.ptnl_ler_for_per_id%type,
     qualg_evt_flag        ben_ler_f.qualg_evt_flag%type);
  --
  type g_ler is record
    (ler_id                ben_ler_f.ler_id%type,
     ler_eval_rl           ben_ler_f.ler_eval_rl%type,
     name                  ben_ler_f.name%type);
  --
  type g_ptnl_ler is record
    (ptnl_ler_for_per_id   ben_ptnl_ler_for_per.ptnl_ler_for_per_id%type,
     object_version_number ben_ptnl_ler_for_per.object_version_number%type);
  --
  -- Create eligibility record
  --
  type g_batch_elig_rec is record
    (batch_elig_id         number,
     benefit_action_id     number,
     person_id             number,
     pgm_id                number,
     pl_id                 number,
     oipl_id               number,
     elig_flag             varchar2(30),
     inelig_text           varchar2(2000),
     business_group_id     number,
     effective_date        date,
     object_version_number number);
  --
  type g_batch_elig_table is varray(10000000) of g_batch_elig_rec;
  --
  type g_batch_ler_rec is record
    (batch_ler_id          number,
     benefit_action_id     number,
     person_id             number,
     ler_id                number,
     lf_evt_ocrd_dt        date,
     replcd_flag           varchar2(30),
     crtd_flag             varchar2(30),
     tmprl_flag            varchar2(30),
     dltd_flag             varchar2(30),
     open_and_clsd_flag    varchar2(30),
     clsd_flag             varchar2(30),
     not_crtd_flag         varchar2(30),
     stl_actv_flag         varchar2(30),
     clpsd_flag            varchar2(30),
     clsn_flag             varchar2(30),
     no_effect_flag        varchar2(30),
     cvrge_rt_prem_flag    varchar2(30),
     per_in_ler_id         number,
     business_group_id     number,
     effective_date        date,
     object_version_number number);
  --
  type g_batch_ler_table is varray(10000000) of g_batch_ler_rec;
  --
  type g_batch_elctbl_rec is record
    (batch_elctbl_id       number,
     benefit_action_id     number,
     person_id             number,
     pgm_id                number,
     pl_id                 number,
     oipl_id               number,
     enrt_cvg_strt_dt      date,
     enrt_perd_strt_dt     date,
     enrt_perd_end_dt      date,
     erlst_deenrt_dt       date,
     dflt_enrt_dt          date,
     enrt_typ_cycl_cd      varchar2(30),
     comp_lvl_cd           varchar2(30),
     mndtry_flag           varchar2(30),
     dflt_flag             varchar2(30),
     business_group_id     number,
     object_version_number number,
     effective_date        date);
  --
  type g_batch_elctbl_table is varray(10000000) of g_batch_elctbl_rec;
  --
  type g_batch_rate_rec is record
    (batch_rt_id           number,
     benefit_action_id     number,
     person_id             number,
     pgm_id                number,
     pl_id                 number,
     oipl_id               number,
     bnft_rt_typ_cd        varchar2(30),
     dflt_flag             varchar2(30),
     val                   number,
     old_val               number,
     tx_typ_cd             varchar2(30),
     acty_typ_cd           varchar2(30),
     mn_elcn_val           number,
     mx_elcn_val           number,
     incrmt_elcn_val       number,
     dflt_val              number,
     rt_strt_dt            date,
     business_group_id     number,
     object_version_number number,
     enrt_cvg_strt_dt      date,
     enrt_cvg_thru_dt      date,
     actn_cd               varchar2(30),
     close_actn_itm_dt     date,
     effective_date        date);
  --
  type g_batch_rate_table is varray(10000000) of g_batch_rate_rec;
  --
  type g_batch_dpnt_rec is record
    (batch_dpnt_id         number,
     benefit_action_id     number,
     person_id             number,
     pgm_id                number,
     pl_id                 number,
     oipl_id               number,
     contact_typ_cd        varchar2(30),
     dpnt_person_id        number,
     business_group_id     number,
     object_version_number number,
     enrt_cvg_strt_dt      date,
     enrt_cvg_thru_dt      date,
     actn_cd               varchar2(30),
     effective_date        date);
  --
  type g_batch_dpnt_table is varray(10000000) of g_batch_dpnt_rec;
  --
  type g_batch_param_rec is record
    (PROCESS_DATE           date,
     MODE_CD                varchar2(30),
     DERIVABLE_FACTORS_FLAG varchar2(30),
     VALIDATE_FLAG          varchar2(30),
     PERSON_ID              number,
     PERSON_TYPE_ID         number,
     PGM_ID                 number,
     BUSINESS_GROUP_ID      number,
     PL_ID                  number,
     POPL_ENRT_TYP_CYCL_ID  number,
     NO_PROGRAMS_FLAG       varchar2(30),
     NO_PLANS_FLAG          varchar2(30),
     COMP_SELECTION_RL      number,
     PERSON_SELECTION_RL    number,
     LER_ID                 number,
     ORGANIZATION_ID        number,
     BENFTS_GRP_ID          number,
     LOCATION_ID            number,
     PSTL_ZIP_RNG_ID        number,
     RPTG_GRP_ID            number,
     PL_TYP_ID              number,
     OPT_ID                 number,
     ELIGY_PRFL_ID          number,
     VRBL_RT_PRFL_ID        number,
     LEGAL_ENTITY_ID        number,
     PAYROLL_ID             number,
     CM_TRGR_TYP_CD         varchar2(30),
     DEBUG_MESSAGES_FLAG    varchar2(30),
     CM_TYP_ID              number,
     AGE_FCTR_ID            number,
     MIN_AGE                number,
     MAX_AGE                number,
     LOS_FCTR_ID            number,
     MIN_LOS                number,
     MAX_LOS                number,
     CMBN_AGE_LOS_FCTR_ID   number,
     MIN_CMBN               number,
     MAX_CMBN               number,
     DATE_FROM              date,
     ELIG_ENROL_CD          varchar2(30),
     ACTN_TYP_ID            number,
     AUDIT_LOG_FLAG         varchar2(30),
     --
     -- PB : 5422
     -- added.
     LF_EVT_OCRD_DT         varchar2(240),
     --
     -- PB : Healthnet change : added LMT_PRPNIP_BY_ORG_FLAG
     --
     LMT_PRPNIP_BY_ORG_FLAG varchar2(30),
     INELG_ACTION_CD        varchar2(30));
  --
  type g_batch_param_table is table of g_batch_param_rec
    index by binary_integer;
/*
  --
  -- Remove in ben_type
  --
  type g_batch_action_rec is record
    (person_action_id      number,
     action_status_cd      varchar2(30),
     ler_id                number,
     object_version_number number,
     effective_date        date);
  --
  type g_batch_action_table is varray(10000000) of g_batch_action_rec;
  --
  type g_batch_proc_rec is record
    (batch_ler_id          number,
     benefit_action_id     number,
     strt_dt               date,
     end_dt                date,
     strt_tm               varchar2(30),
     end_tm                varchar2(30),
     elpsd_tm              varchar2(30),
     per_slctd             number,
     per_proc              number,
     per_unproc            number,
     per_proc_succ         number,
     per_err               number,
     business_group_id     number,
     object_version_number number);
  --
  type g_batch_proc_table is varray(10000000) of g_batch_proc_rec;
  --
  type g_batch_commu_rec is record
    (batch_commu_id         number,
     benefit_action_id     number,
     person_id             number,
     per_cm_id             number,
     cm_typ_id             number,
     per_cm_prvdd_id       number,
     to_be_sent_dt         date,
     business_group_id     number,
     object_version_number number);
  --
  type g_batch_commu_table is varray(10000000) of g_batch_commu_rec;
*/
  --
  -- Varrays
  --
  g_report_table_object ben_type.g_report_table := ben_type.g_report_table();
  g_batch_action_table_object ben_type.g_batch_action_table
    := ben_type.g_batch_action_table();
  g_batch_proc_table_object ben_type.g_batch_proc_table
    := ben_type.g_batch_proc_table();
  g_batch_commu_table_object ben_type.g_batch_commu_table
    := ben_type.g_batch_commu_table();
  --
  g_batch_param_table_object g_batch_param_table;
----------------------------------------------------------------------------
--  rt_typ_calc
----------------------------------------------------------------------------
PROCEDURE rt_typ_calc
      (p_val              IN number,
       p_val_2            IN number,
       p_rt_typ_cd        IN varchar2,
       p_calculated_val   OUT NOCOPY number) ;

------------------------------------------------------------------------
--  limit_checks
------------------------------------------------------------------------
PROCEDURE limit_checks (p_lwr_lmt_val       in number,
                     p_lwr_lmt_calc_rl   in number,
                     p_upr_lmt_val       in number,
                     p_upr_lmt_calc_rl   in number,
                     p_effective_date    in date,
                     p_assignment_id     in number,
                     p_organization_id   in number,
                     p_business_group_id in number,
                     p_pgm_id            in number,
                     p_pl_id             in number,
                     p_pl_typ_id         in number,
                     p_opt_id            in number,
                     p_ler_id            in number,
                     p_acty_base_rt_id   in number default null,
                     p_elig_per_elctbl_chc_id   in number default null,
                     p_val               in out nocopy number,
                     p_state             in varchar2) ;

------------------------------------------------------------------------
--
------------------------------------------------------------------------
  procedure write(p_rec in out nocopy ben_type.g_report_rec);
  --
  procedure write(p_rec in out nocopy g_batch_elig_rec);
  --
  procedure write(p_rec in out nocopy g_batch_ler_rec);
  --
  procedure write(p_rec in out nocopy ben_type.g_batch_proc_rec);
  --
  procedure write(p_rec in out nocopy ben_type.g_batch_action_rec);
  --
  procedure write(p_rec in out nocopy g_batch_elctbl_rec);
  --
  procedure write(p_rec in out nocopy g_batch_rate_rec);
  --
  procedure write(p_rec in out nocopy g_batch_dpnt_rec);
  --
  procedure write(p_rec in out nocopy ben_type.g_batch_commu_rec);
  --
  procedure write_table_and_file(p_table          in boolean default true,
                                 p_file           in boolean default true);
  --
  procedure get_batch_parameters(p_benefit_action_id in number,
                                 p_rec               in out nocopy g_batch_param_rec);
  --
  function get_ler_name(p_typ_cd            in varchar2,
                        p_business_group_id in number) return varchar2;
  pragma restrict_references (get_ler_name, RNPS, WNPS,WNDS);
  --
  procedure set_cache_record_position;
  --
  procedure rollback_cache;
  --
  procedure update_life_event_cache(p_open_and_closed in varchar2 default null);
  --
  function get_assignment_id(p_person_id         in number,
                             p_business_group_id in number,
                             p_effective_date    in date) return number;
  --
  function get_lf_evt_ocrd_dt(p_person_id         in number,
                              p_business_group_id in number,
                              p_ler_id            in number default null,
                              p_effective_date    in date) return date;
  --
  function get_per_in_ler_id(p_person_id         in number,
                             p_business_group_id in number,
                             p_ler_id            in number default null,
                             p_effective_date    in date) return number;
  --
  -- added for unrestricted enhancement
  function get_per_in_ler_id(p_person_id         in number,
                             p_business_group_id in number,
                             p_ler_id            in number default null,
                             p_lf_event_mode     in varchar2,
                             p_effective_date    in date) return number;
  --
  procedure get_active_life_event(p_person_id         in  number,
                                  p_business_group_id in  number,
                                  p_effective_date    in  date,
                                  p_rec               out nocopy g_active_life_event);
  --
   -- added for unrestricted enhancement
  procedure get_active_life_event(p_person_id         in  number,
                                  p_business_group_id in  number,
                                  p_effective_date    in  date,
                                  p_lf_event_mode     in varchar2,
                                  p_rec               out nocopy g_active_life_event);
  --
  procedure get_ler(p_business_group_id in  number,
                    p_typ_cd            in  varchar2,
                    p_effective_date    in  date,
                    p_lf_evt_oper_cd    in  varchar2 default null,   /* GSP Rate Sync */
                    p_rec               out nocopy g_ler);
  --
  procedure get_ler(p_business_group_id in  number,
                    p_ler_id            in  number,
                    p_effective_date    in  date,
                    p_rec               out nocopy g_ler);
  --
  procedure get_ptnl_ler(p_business_group_id in  number,
                         p_person_id         in  number,
                         p_ler_id            in  number,
                         p_effective_date    in  date,
                         p_rec               out nocopy g_ptnl_ler);
  --
  function get_primary_key(p_tablename in varchar2) return varchar2;
  --
  function lookups_exist(p_tablename in varchar2) return boolean;
  --
  procedure define_primary_key(p_tablename in varchar2);
  --
  function part_of_pkey(p_column_name in varchar2) return boolean;
  --
  function get_bp_name (p_tablename in varchar2) return varchar2;
  --
  function iftrue(p_expression in boolean,
                  p_true       in varchar2,
                  p_false      in varchar2) return varchar2;
  --
  function business_group_exists(p_tablename in varchar2) return boolean;
  --
  function table_datetracked(p_tablename in varchar2) return boolean;
  --
  function attributes_exist(p_tablename in varchar2) return boolean;
  --
  function get_pk_constraint_name(p_tablename in varchar2) return varchar2;
  --
  function column_changed(p_old_column in varchar2,
                          p_new_column in varchar2,
                          p_new_value in varchar2) return boolean;
  --
  function column_changed(p_old_column in date,
                          p_new_column in date,
                          p_new_value in varchar2) return boolean;
  --
  function column_changed(p_old_column in number,
                          p_new_column in number,
                          p_new_value in varchar2) return boolean;
  --
  procedure write(p_text     in varchar2,
                  p_validate in boolean default false);
  --
  function do_rounding(p_rounding_cd    in varchar2,
                       p_rounding_rl    in number default null,
                       p_assignment_id  in number default null,
                       p_value          in number,
                       p_effective_date in date) return number;
  --
  function do_uom(p_date1    in date,
                  p_date2    in date,
                  p_uom      in varchar2) return number;
  --
  function derive_date(p_date    in date,
                       p_uom     in varchar2,
                       p_min     in number,
                       p_max     in number,
                       p_value   in varchar2,
                       p_decimal_level in varchar2  default 'N'  ) return date;
  --
  function id(p_value in number) return varchar2;
  --
  function zero_to_null(p_value in number) return number;
  --
  function min_max_breach(p_min_value     in number,
                          p_max_value     in number,
                          p_old_value     in number,
                          p_new_value     in number,
                          p_break         out nocopy varchar2,
                          p_decimal_level in  varchar2 default 'N' ) return boolean;
  --
  procedure get_parameter(p_business_group_id in  number,
                          p_batch_exe_cd      in  varchar2,
                          p_threads           out nocopy number,
                          p_chunk_size        out nocopy number,
                          p_max_errors        out nocopy number);
  --
  function eot_to_null(p_date in date) return date;
  --
  function eot_to_null(p_date in varchar2) return varchar2;
  --
  function get_message_name return varchar2;
  --
  function set_to_oct1_prev_year(p_date in date) return date;
  --
  procedure init_lookups(p_lookup_type_1  in varchar2 default null,
                         p_lookup_type_2  in varchar2 default null,
                         p_lookup_type_3  in varchar2 default null,
                         p_lookup_type_4  in varchar2 default null,
                         p_lookup_type_5  in varchar2 default null,
                         p_lookup_type_6  in varchar2 default null,
                         p_lookup_type_7  in varchar2 default null,
                         p_lookup_type_8  in varchar2 default null,
                         p_lookup_type_9  in varchar2 default null,
                         p_lookup_type_10 in varchar2 default null,
                         p_effective_date in date);
  --
  function not_exists_in_hr_lookups(p_lookup_type in varchar2,
                                    p_lookup_code in varchar2)
                                    return boolean;
  --
  function formula_exists(p_formula_id        in number,
                          p_formula_type_id   in number,
                          p_business_group_id in number,
                          p_effective_date    in date) return boolean;
  --
  function formula(p_formula_id            in number,
                   p_business_group_id     in number   default null,
                   p_payroll_id            in number   default null,
                   p_payroll_action_id     in number   default null,
                   p_assignment_id         in number   default null,
                   p_assignment_action_id  in number   default null,
                   p_org_pay_method_id     in number   default null,
                   p_per_pay_method_id     in number   default null,
                   p_organization_id       in number   default null,
                   p_tax_unit_id           in number   default null,
                   p_jurisdiction_code     in varchar2 default null,
                   p_balance_date          in date     default null,
                   p_element_entry_id      in number   default null,
                   p_element_type_id       in number   default null,
                   p_original_entry_id     in number   default null,
                   p_tax_group             in number   default null,
                   p_pgm_id                in number   default null,
                   p_pl_id                 in number   default null,
                   p_pl_typ_id             in number   default null,
                   p_opt_id                in number   default null,
                   p_ler_id                in number   default null,
                   p_communication_type_id in number   default null,
                   p_action_type_id        in number   default null,
                   p_acty_base_rt_id       in number   default null,
                   p_elig_per_elctbl_chc_id in number   default null,
                   p_enrt_bnft_id          in number   default null,
                   p_regn_id               in number   default null,
                   p_rptg_grp_id           in number   default null,
                   p_cm_dlvry_mthd_cd      in varchar2 default null,
                   p_crt_ordr_typ_cd       in varchar2 default null,
                   p_enrt_ctfn_typ_cd      in varchar2 default null,
                   p_bnfts_bal_id          in number   default null,
                   p_elig_per_id           in number   default null,
                   p_per_cm_id             in number   default null,
                   p_prtt_enrt_actn_id     in number   default null,
                   p_effective_date        in date,
                   p_param1                in varchar2 default null,
                   p_param1_value          in varchar2 default null,
                   p_param2                in varchar2 default null,
                   p_param2_value          in varchar2 default null,
                   p_param3                in varchar2 default null,
                   p_param3_value          in varchar2 default null,
                   p_param4                in varchar2 default null,
                   p_param4_value          in varchar2 default null,
                   p_param5                in varchar2 default null,
                   p_param5_value          in varchar2 default null,
                   p_param6                in varchar2 default null,
                   p_param6_value          in varchar2 default null,
                   p_param7                in varchar2 default null,
                   p_param7_value          in varchar2 default null,
                   p_param8                in varchar2 default null,
                   p_param8_value          in varchar2 default null,
                   p_param9                in varchar2 default null,
                   p_param9_value          in varchar2 default null,
                   p_param10               in varchar2 default null,
                   p_param10_value         in varchar2 default null,
                   p_param11            in varchar2 default null,
                   p_param11_value      in varchar2 default null,
                   p_param12            in varchar2 default null,
                   p_param12_value      in varchar2 default null,
                   p_param13            in varchar2 default null,
                   p_param13_value      in varchar2 default null,
                   p_param14            in varchar2 default null,
                   p_param14_value      in varchar2 default null,
                   p_param15            in varchar2 default null,
                   p_param15_value      in varchar2 default null,
                   p_param16            in varchar2 default null,
                   p_param16_value      in varchar2 default null,
                   p_param17            in varchar2 default null,
                   p_param17_value      in varchar2 default null,
                   p_param18            in varchar2 default null,
                   p_param18_value      in varchar2 default null,
                   p_param19            in varchar2 default null,
                   p_param19_value      in varchar2 default null,
                   p_param20           in varchar2 default null,
                   p_param20_value     in varchar2 default null,
                   p_param21           in varchar2 default null,
                   p_param21_value     in varchar2 default null,
                   p_param22           in varchar2 default null,
                   p_param22_value     in varchar2 default null,
                   p_param23           in varchar2 default null,
                   p_param23_value     in varchar2 default null,
                   p_param24           in varchar2 default null,
                   p_param24_value     in varchar2 default null,
                   p_param25           in varchar2 default null,
                   p_param25_value     in varchar2 default null,
                   p_param26           in varchar2 default null,
                   p_param26_value     in varchar2 default null,
                   p_param27           in varchar2 default null,
                   p_param27_value     in varchar2 default null,
                   p_param28           in varchar2 default null,
                   p_param28_value     in varchar2 default null,
                   p_param29           in varchar2 default null,
                   p_param29_value     in varchar2 default null,
                   p_param30           in varchar2 default null,
                   p_param30_value     in varchar2 default null,
                   p_param31           in varchar2 default null,
                   p_param31_value     in varchar2 default null,
                   p_param32           in varchar2 default null,
                   p_param32_value     in varchar2 default null,
                   p_param33           in varchar2 default null,
                   p_param33_value     in varchar2 default null,
                   p_param34           in varchar2 default null,
                   p_param34_value     in varchar2 default null,
                   p_param35           in varchar2 default null,
                   p_param35_value     in varchar2 default null,
                   p_param_tab         in ff_exec.outputs_t default g_empty_tab
            ) return ff_exec.outputs_t;
  --
procedure clear_down_cache;
--
-- This procedure is used to execute the rule : per_info_chg_cs_ler_rl
-- This procedure is called from the trigger packages like
-- ben_add_ler.
--
procedure exec_rule(
             p_formula_id        in  number,
             p_effective_date    in  date,
             p_lf_evt_ocrd_dt    in  date,
             p_business_group_id in  number,
             p_person_id         in  number default null,
             p_new_value         in  varchar2 default null,
             p_old_value         in  varchar2 default null,
             p_column_name       in  varchar2 default null,
             p_pk_id             in  varchar2 default null,
             p_param5            in varchar2 default null,
             p_param5_value      in varchar2 default null,
             p_param6            in varchar2 default null,
             p_param6_value      in varchar2 default null,
             p_param7            in varchar2 default null,
             p_param7_value      in varchar2 default null,
             p_param8            in varchar2 default null,
             p_param8_value      in varchar2 default null,
             p_param9            in varchar2 default null,
             p_param9_value      in varchar2 default null,
             p_param10           in varchar2 default null,
             p_param10_value     in varchar2 default null,
             p_param11            in varchar2 default null,
             p_param11_value      in varchar2 default null,
             p_param12            in varchar2 default null,
             p_param12_value      in varchar2 default null,
             p_param13            in varchar2 default null,
             p_param13_value      in varchar2 default null,
             p_param14            in varchar2 default null,
             p_param14_value      in varchar2 default null,
             p_param15            in varchar2 default null,
             p_param15_value      in varchar2 default null,
             p_param16            in varchar2 default null,
             p_param16_value      in varchar2 default null,
             p_param17            in varchar2 default null,
             p_param17_value      in varchar2 default null,
             p_param18            in varchar2 default null,
             p_param18_value      in varchar2 default null,
             p_param19            in varchar2 default null,
             p_param19_value      in varchar2 default null,
             p_param20           in varchar2 default null,
             p_param20_value     in varchar2 default null,
             p_param21           in varchar2 default null,
             p_param21_value     in varchar2 default null,
             p_param22           in varchar2 default null,
             p_param22_value     in varchar2 default null,
             p_param23           in varchar2 default null,
             p_param23_value     in varchar2 default null,
             p_param24           in varchar2 default null,
             p_param24_value     in varchar2 default null,
             p_param25           in varchar2 default null,
             p_param25_value     in varchar2 default null,
             p_param26           in varchar2 default null,
             p_param26_value     in varchar2 default null,
             p_param27           in varchar2 default null,
             p_param27_value     in varchar2 default null,
             p_param28           in varchar2 default null,
             p_param28_value     in varchar2 default null,
             p_param29           in varchar2 default null,
             p_param29_value     in varchar2 default null,
             p_param30           in varchar2 default null,
             p_param30_value     in varchar2 default null,
             p_param31           in varchar2 default null,
             p_param31_value     in varchar2 default null,
             p_param32           in varchar2 default null,
             p_param32_value     in varchar2 default null,
             p_param33           in varchar2 default null,
             p_param33_value     in varchar2 default null,
             p_param34           in varchar2 default null,
             p_param34_value     in varchar2 default null,
             p_param35           in varchar2 default null,
             p_param35_value     in varchar2 default null,
             p_param_tab         in ff_exec.outputs_t default g_empty_tab,
             p_ret_val           out nocopy varchar2);
--
function get_rt_val(p_per_in_ler_id in number,
                    p_prtt_rt_val_id in number,
					p_effective_date in date)
return number;
--
--
function get_ann_rt_val(p_per_in_ler_id in number,
                    p_prtt_rt_val_id in number,
					p_effective_date in date)
return number;
--
--
function get_val(p_per_in_ler_id in number,
                    p_prtt_rt_val_id in number,
					p_effective_date in date)
return number;

--
--
function get_concat_val(p_per_in_ler_id in number,
                    p_prtt_rt_val_id in number)
return varchar2;

function get_choice_status(p_elig_per_elctbl_chc_id in number)
return varchar2;
--
function in_workflow(p_person_id in number)
return varchar2;
--
------------------------------------------------------------------------
--  CWB Changes
--  get_active_life_event
--  returns compensation type active life event
------------------------------------------------------------------------
procedure get_active_life_event(p_person_id         in  number,
                                p_business_group_id in  number,
                                p_effective_date    in  date,
                                p_lf_evt_ocrd_dt    in  date,
                                p_ler_id            in number,
                                p_rec               out nocopy g_active_life_event);
--
-- Bug No 2258174
--
function basis_to_plan_conversion(p_pl_id          in number,
                                  p_effective_date in date,
                                  p_amount         in number,
                                  p_assignment_id  in number
                                 ) return number;
--
function plan_to_basis_conversion(p_pl_id          in number,
                                  p_effective_date in date,
                                  p_amount         in number,
                                  p_assignment_id  in number
                                 ) return number;
--
-- Bug 2016857
procedure set_data_migrator_mode;
-- Bug 2016857

-- Bug 2428672
function ben_get_abp_plan_opt_names
         (p_bnft_prvdr_pool_id  IN ben_bnft_prvdr_pool_f.bnft_prvdr_pool_id%TYPE,
   p_business_group_id  IN ben_acty_base_rt_f.business_group_id%TYPE,
   p_acty_base_rt_id  IN ben_acty_base_rt_f.acty_base_rt_id%TYPE,
   p_session_id   IN fnd_sessions.session_id%TYPE,
   ret_flag     IN varchar2)
return varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------< return_concat_kf_segments >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the display concatenated string for the segments1..30.
--   The function calls hr_api.return_concat_kf_segments to get the
--   concatenated segments.
--   This function has been added to benutils as part of fix for bug 2599034
--   Since there is a package HR_API present in PLD library and backend, it is
--   conflicting with each other when we try to use the backend package from
--   form. But hard-coding Apps.<package name> is not a good practice.
--   Hence creating a wrapper for the hr_api.return_concat_kf_segments in
--   benutils to accomplish the same.
--
-- Pre-conditions:
--   The id_flex_num and segments have been fully validated.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function return_concat_kf_segments
           (p_id_flex_num    in number,
            p_application_id in number,
            p_id_flex_code   in varchar2,
            p_segment1       in varchar2 default null,
            p_segment2       in varchar2 default null,
            p_segment3       in varchar2 default null,
            p_segment4       in varchar2 default null,
            p_segment5       in varchar2 default null,
            p_segment6       in varchar2 default null,
            p_segment7       in varchar2 default null,
            p_segment8       in varchar2 default null,
            p_segment9       in varchar2 default null,
            p_segment10      in varchar2 default null,
            p_segment11      in varchar2 default null,
            p_segment12      in varchar2 default null,
            p_segment13      in varchar2 default null,
            p_segment14      in varchar2 default null,
            p_segment15      in varchar2 default null,
            p_segment16      in varchar2 default null,
            p_segment17      in varchar2 default null,
            p_segment18      in varchar2 default null,
            p_segment19      in varchar2 default null,
            p_segment20      in varchar2 default null,
            p_segment21      in varchar2 default null,
            p_segment22      in varchar2 default null,
            p_segment23      in varchar2 default null,
            p_segment24      in varchar2 default null,
            p_segment25      in varchar2 default null,
            p_segment26      in varchar2 default null,
            p_segment27      in varchar2 default null,
            p_segment28      in varchar2 default null,
            p_segment29      in varchar2 default null,
            p_segment30      in varchar2 default null)
         return varchar2;

--
-- ----------------------------------------------------------------------------
-- |---------------------< get_comp_obj_disp_dt >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Function to return effective_date based on which the compensation object names
-- can be retrieved. The function takes the profile value for BEN_DSPL_NAME_BASIS
-- and based on the profile set, return the correct date
--
-- Profile Value       Return
-- SESSION             Will return the session date. All comp objects names
--                     displayed will be effective of session date
-- LEOD                Will return the Life Event Occured Date. All comp objects names
--                     displayed will be effective of the Life Event Occurred Date
-- MXLECVG             Will return the greatest of Life Event Occurred Date or the Coverage
--                     Start Date. All comp objects names displayed will be effective this date
--
--
-- Pre-conditions:
--
-- In Arguments:
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-----------------------------------------------------------------------------
--
FUNCTION get_comp_obj_disp_dt
    (p_session_date     date  default null,
     p_lf_evt_ocrd_dt   date  default null,
     p_cvg_strt_dt      date  default null)
return date;
--
-- Over Loaded Function
--
FUNCTION get_comp_obj_disp_dt
    (p_session_date     date    default null,
     p_per_in_ler_id    number,
     p_cvg_strt_dt      date    default null)
return date;
--
--
-- g_ben_dspl_name_basis will store the value of profile BEN_DSPL_NAME_BASIS
--
g_ben_dspl_name_basis varchar2(100);
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_post_enrt_cvg_and_rt_val >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Procedure to retrieve the Coverage amount and Rate Amount values for
-- those coverage and rates whose Calculation method is 'Post-Enrollment
-- Calculation Rule'
--
-- Pre-conditions: Specifically written for self-service and should be used
-- only after Election Information and Post-Process is called.
--
-- In Arguments: choice id, bnft id, and rt ids.
--
-- Post Success: returns all relevant amounts.
--
-- Post Failure: returns null
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-----------------------------------------------------------------------------
--
procedure get_post_enrt_cvg_and_rt_val
      (p_elig_per_elctbl_chc_id in number,
       p_enrt_bnft_id           in number default null,
       p_effective_date         in date,
       p_enrt_rt_id             in number default null,
       p_enrt_rt_id2            in number default null,
       p_enrt_rt_id3            in number default null,
       p_enrt_rt_id4            in number default null,
       p_bnft_amt               out nocopy number,
       p_val                    out nocopy number,
       p_rt_val                 out nocopy number,
       p_ann_rt_val             out nocopy number,
       p_val2                   out nocopy number,
       p_rt_val2                out nocopy number,
       p_ann_rt_val2            out nocopy number,
       p_val3                   out nocopy number,
       p_rt_val3                out nocopy number,
       p_ann_rt_val3            out nocopy number,
       p_val4                   out nocopy number,
       p_rt_val4                out nocopy number,
       p_ann_rt_val4            out nocopy number) ;
--
--

function run_osb_benmngle_flag
           ( p_person_id          in number,
             p_business_group_id  in number,
             p_effective_date     in date)
return boolean;

function get_pl_annualization_factor(p_acty_ref_perd_cd in varchar2) return number;

--
FUNCTION is_task_enabled
  	 (p_access_cd 		in varchar2,
	  p_population_cd 	in varchar2,
	  p_status_cd 		in varchar2,
	  p_dist_bdgt_iss_dt 	in date,
	  p_wksht_grp_cd	in varchar2)
return varchar2;
--
FUNCTION get_manager_name(p_emp_per_in_ler_id in number,
                      	  p_level 	      in number)
return varchar2;
--
FUNCTION get_profile(p_profile_name in varchar2)
return varchar2;

-- Function get_dpnt_prev_cvrd_flag will find out if a dependent is covered in a
-- previous lifevent. Currently this is used by SSBEN in the DependentsPeopleVO query.
--
FUNCTION get_dpnt_prev_cvrd_flag(p_prtt_enrt_rslt_id in number,
                                 p_efective_date date,
                                 p_dpnt_person_id number,
                                 p_elig_per_elctbl_chc_id number,
                                 p_elig_cvrd_dpnt_id number,
                                 p_elig_dpnt_id number,
                                 p_per_in_ler_id number )
return varchar2;
--
end benutils;

 

/
