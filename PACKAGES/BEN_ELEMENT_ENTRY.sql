--------------------------------------------------------
--  DDL for Package BEN_ELEMENT_ENTRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELEMENT_ENTRY" AUTHID CURRENT_USER as
/* $Header: benelmen.pkh 120.1.12010000.1 2008/07/29 12:22:55 appldev ship $ */
--
type g_calculated_values is record
  (element_entry_id    number
  ,zero_pp_date        date
  ,special_pp_date     date
  ,special_amt         number
  ,normal_pp_date      date
  ,normal_amt          number
  ,normal_pp_end_date  date
  ,prtn_flag           varchar2(1)
  ,first_pp_adjustment number
  ,rt_strt_dt          date
  ,range_start         date
  ,last_pp_end_dt      date
  ,payroll_id          number
  );
--
type g_cache_quick_payrun is record
 (person_id      number,
  element_type_id number,
  assignment_id   number,
  assignment_action_id number,
  payroll_end_date     date);

type ext_inpval_tab_rec is record
  (extra_input_value_id       number(15),
   upd_when_ele_ended_cd      varchar2(30),
   input_value_id             number(15),
   return_var_name            varchar2(30),
   return_value               varchar2(2000));
--
type ext_inpval_tab_typ is table of ext_inpval_tab_rec
     index by binary_integer;
--
type inpval_tab_rec is record
(input_value_id     number,
 value              varchar2(60));

type inpval_tab_typ is table of inpval_tab_rec
index by binary_integer;

type g_cache_quick_payrun_rec is table of g_cache_quick_payrun
   index by binary_integer;

g_cache_quick_payrun_object g_cache_quick_payrun_rec;

g_creee_calc_vals g_calculated_values;
--
--
--g_msg_displayed number :=0; --2530582
--g_msg_displayed1 number :=0; --2530582
--
-- prorates rates, coverage, and actual premiums
--
-- ----------------------------------------------------------------------------
-- |---------------------< prorate_amount >-----------------------------|
-- ----------------------------------------------------------------------------
function prorate_amount(p_amt IN NUMBER --per month amount
                       ,p_acty_base_rt_id IN NUMBER default null
                       ,p_actl_prem_id in number default null
                       ,p_cvg_amt_calc_mthd_id in number default null
                       ,p_person_id in number
                       ,p_rndg_cd in varchar2 default null
                       ,p_rndg_rl in number default null
                       ,p_pgm_id in number
                       ,p_pl_typ_id in number
                       ,p_pl_id in number
                       ,p_opt_id in number
                       ,p_ler_id in number
                       ,p_prorate_flag IN OUT NOCOPY VARCHAR2
                       ,p_effective_date in DATE
                       ,p_start_or_stop_cd in varchar2
                       ,p_start_or_stop_date in date
                       ,p_business_group_id in number
                       ,p_assignment_id in number
                       ,p_organization_id in number
                       ,p_jurisdiction_code in varchar2
                       ,p_wsh_rl_dy_mo_num in number
                       ,p_prtl_mo_det_mthd_cd in out nocopy varchar2
                       ,p_prtl_mo_det_mthd_rl in number)
         RETURN NUMBER;
--
procedure get_link
  (p_assignment_id     in number
  ,p_element_type_id   in number
  ,p_business_group_id in number
  ,p_input_value_id    in number
  ,p_effective_date    in date
  --
  ,p_element_link_id   out nocopy number
  );
/*
-- This Function checks the existence of a current
-- Employee or Benefits assignment
-- and returns the assignment_id and payroll_id
--
*/
function chk_assign_exists(p_person_id IN NUMBER
                          ,p_business_group_id IN NUMBER
                          ,p_effective_date    IN DATE
                          ,p_rate_date         IN DATE
                          ,p_acty_base_rt_id   IN NUMBER
                          ,p_assignment_id IN OUT NOCOPY NUMBER
                          ,p_organization_id in out nocopy number
                          ,p_payroll_id IN OUT NOCOPY NUMBER)
         RETURN BOOLEAN;

-- This Procedure creates a benefits assignments
-- If the participant record being enrolled does not
-- have an assignment.
procedure create_benefits_assignment(p_person_id IN NUMBER
                                    ,p_payroll_id IN NUMBER
                                    ,p_assignment_id IN OUT NOCOPY NUMBER
                                    ,p_business_group_id IN NUMBER
                                    ,p_organization_id in out nocopy number
                                    ,p_effective_date IN DATE);
--
procedure create_enrollment_element
  (p_validate                  in     boolean default false
  ,p_calculate_only_mode       in     boolean default false
  ,p_person_id                 in     number
  ,p_acty_base_rt_id           in     number
  ,p_acty_ref_perd             in     varchar2
  ,p_rt_start_date             in     date
  ,p_rt                        in     number
  ,p_business_group_id         in     number
  ,p_effective_date            in     date
  ,p_cmncd_rt                  in     number  default null
  ,p_ann_rt                    in     number  default null
  ,p_prtt_rt_val_id            in     number  default null
  ,p_enrt_rslt_id              in     number  default null
  ,p_input_value_id            in     number  default null
  ,p_element_type_id           in     number  default null
  ,p_pl_id                     in     number  default null
  ,p_prv_object_version_number in out nocopy number
  ,p_element_entry_value_id    out nocopy number
  ,p_eev_screen_entry_value    out nocopy number
  );
--
procedure reopen_closed_enrollment(p_validate  IN BOOLEAN default FALSE
                                  ,p_business_group_id number
                                  ,p_person_id number
                                  ,p_acty_base_rt_id NUMBER
                                  ,p_element_type_id NUMBER
                                  ,p_prtt_rt_val_id IN NUMBER default null
                                  ,p_input_value_id NUMBER
                                  ,p_rt NUMBER
                                  ,p_rt_start_date DATE
                                  ,p_effective_date DATE);
--
procedure end_enrollment_element(p_validate IN BOOLEAN default FALSE
                                ,p_business_group_id IN NUMBER
                                ,p_person_id IN NUMBER
                                ,p_enrt_rslt_id IN NUMBER
                                ,p_acty_ref_perd in varchar2
                                ,p_acty_base_rt_id in number
                                ,p_element_link_id IN NUMBER
                                ,p_prtt_rt_val_id in number
                                ,p_rt_end_date IN DATE
                                ,p_effective_date IN DATE
                                ,p_dt_delete_mode IN VARCHAR2
                                ,p_amt in number);
--
procedure get_abr_assignment(p_person_id       IN     NUMBER
                            ,p_effective_date  IN     DATE
                            ,p_acty_base_rt_id IN     NUMBER
                            ,p_organization_id    OUT NOCOPY NUMBER
                            ,p_payroll_id         OUT NOCOPY NUMBER
                            ,p_assignment_id      OUT NOCOPY NUMBER);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_extra_ele_inputs>----------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_extra_ele_inputs
  (
   p_effective_date        in  date
  ,p_person_id             in  number
  ,p_business_group_id     in  number
  ,p_assignment_id         in  number
  ,p_element_link_id       in  number
  ,p_entry_type            in  varchar2
  ,p_input_value_id1       in  number
  ,p_entry_value1          in  varchar2
  ,p_element_entry_id      in  number
  ,p_acty_base_rt_id       in  number
  ,p_input_va_calc_rl      in  number
  ,p_abs_ler               in  boolean
  ,p_organization_id       in  number
  ,p_payroll_id            in  number
  ,p_pgm_id                in  number
  ,p_pl_id                 in  number
  ,p_pl_typ_id             in  number
  ,p_opt_id                in  number
  ,p_ler_id                in  number
  ,p_dml_typ               in  varchar2
  ,p_jurisdiction_code     in  varchar2
  ,p_ext_inpval_tab        out nocopy ext_inpval_tab_typ
  ,p_subpriority           out nocopy number);
--
procedure get_inpval_tab
(p_element_entry_id   in number,
 p_effective_date     in date,
 p_inpval_tab         out nocopy inpval_tab_typ);
--
procedure clear_down_cache;
--
procedure set_no_cache_context;
--
procedure reset_msg_displayed; --bug 2530582
--
procedure create_reimburse_element
  (p_validate                  in     boolean default false
  ,p_person_id                 in     number
  ,p_acty_base_rt_id           in     number
  ,p_amt                       in     number
  ,p_business_group_id         in     number
  ,p_effective_date            in     date
  ,p_prtt_reimbmt_rqst_id      in     number  default null
  ,p_input_value_id            in     number  default null
  ,p_element_type_id           in     number  default null
  ,p_pl_id                     in     number  default null
  ,p_prtt_rmt_aprvd_fr_pymt_id in     number
  ,p_object_version_number     in out nocopy number
  );
--
procedure end_reimburse_element(p_validate IN BOOLEAN default FALSE
                                ,p_business_group_id IN NUMBER
                                ,p_person_id IN NUMBER
                                ,p_prtt_reimbmt_rqst_id IN NUMBER
                                ,p_element_link_id IN NUMBER default null
                                ,p_prtt_rmt_aprvd_fr_pymt_id in number
                                ,p_effective_date IN DATE
                                ,p_dt_delete_mode IN VARCHAR2  default null
                                ,p_element_entry_value_id  in number);
--
end ben_element_entry;

/
