--------------------------------------------------------
--  DDL for Package BEN_COBRA_REQUIREMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COBRA_REQUIREMENTS" AUTHID CURRENT_USER AS
/* $Header: bencobra.pkh 120.1.12000000.1 2007/01/19 15:09:56 appldev noship $ */
--
g_cobra_enrollment_change   boolean := FALSE;
--
function get_lf_evt_ocrd_dt
           (p_per_in_ler_id     in number
           ,p_business_group_id in number)
           return date;
--
function chk_enrld_or_cvrd
           (p_pgm_id            in number default null
           ,p_ptip_id           in number default null
           ,p_person_id         in number
           ,p_effective_date    in date
           ,p_business_group_id in number
           ,p_cvrd_today        in varchar2 default null)
           return boolean;
--
function chk_init_evt
           (p_per_in_ler_id     in number
           ,p_business_group_id in number)
           return boolean;
--
function get_cbr_elig_end_dt
           (p_cbr_elig_perd_strt_dt  in date
           ,p_person_id              in number
           ,p_pl_typ_id              in number default null
           ,p_mx_poe_uom             in varchar2
           ,p_mx_poe_val             in number
           ,p_mx_poe_rl              in number
           ,p_pgm_id                 in number
           ,p_effective_date         in date
           ,p_business_group_id      in number
           ,p_ler_id                 in number)
           return date;
--
function chk_pgm_typ
           (p_pgm_id            in number
           ,p_effective_date    in date
           ,p_business_group_id in number)
           return boolean;
--
function get_max_cvg_thru_dt
           (p_person_id         in number
           ,p_lf_evt_ocrd_dt    in date
           ,p_pgm_id            in number default null
           ,p_ptip_id           in number default null
           ,p_per_in_ler_id     in number
           ,p_effective_date    in date
           ,p_business_group_id in number)
           return date;
--
function check_max_poe_eligibility
           (p_person_id           in number
           ,p_mx_poe_apls_cd      in varchar2
           ,p_cvrd_emp_person_id  in number default null
           ,p_quald_bnf_person_id in number default null
           ,p_cbr_quald_bnf_id    in number default null
           ,p_lf_evt_ocrd_dt      in date
           ,p_business_group_id   in number)
           return boolean;
--
function chk_dsbld
          (p_person_id             in number
          ,p_lf_evt_ocrd_dt        in date default null
          ,p_effective_date        in date
          ,p_business_group_id     in number
          )
          return boolean;
---------------------------------------------------------------
procedure update_cobra_elig_info
           (p_person_id             in number
           ,p_per_in_ler_id         in number
           ,p_lf_evt_ocrd_dt        in date
           ,p_effective_date        in date
           ,p_business_group_id     in number
           ,p_validate              in boolean  default false
           );
---------------------------------------------------------------
procedure update_cobra_info
           (p_per_in_ler_id             in number
           ,p_person_id                 in number
           ,p_cbr_quald_bnf_id          in number   default null
           ,p_cqb_object_version_number in number   default null
           ,p_cbr_elig_perd_strt_dt     in date     default null
           ,p_old_cbr_elig_perd_end_dt  in date     default null
           ,p_cbr_elig_perd_end_dt      in date
           ,p_dsbld_apls                in boolean  default false
           ,p_lf_evt_ocrd_dt            in date
           ,p_quald_bnf_flag            in varchar2 default 'Y'
           ,p_cvrd_emp_person_id        in number   default null
           ,p_cbr_inelg_rsn_cd          in varchar2 default hr_api.g_varchar2
           ,p_business_group_id         in number
           ,p_effective_date            in date
           ,p_pgm_id                    in number   default null
           ,p_ptip_id                   in number   default null
           ,p_pl_typ_id                 in number   default null
           ,p_validate                  in boolean  default false
           );
---------------------------------------------------------------
procedure chk_cobra_eligibility
           (p_per_in_ler_id             in number
           ,p_person_id                 in number
           ,p_pgm_id                    in number
           ,p_lf_evt_ocrd_dt            in date
           ,p_business_group_id         in number
           ,p_effective_date            in date
           ,p_validate                  in boolean default false
           );
---------------------------------------------------------------
procedure update_dpnt_cobra_info
           (p_per_in_ler_id             in number
           ,p_person_id                 in number
           ,p_business_group_id         in number
           ,p_effective_date            in date
           ,p_prtt_enrt_rslt_id         in number
           ,p_validate                  in boolean  default false
           );

---------------------------------------------------------------
procedure determine_cobra_elig_dates
            (p_pgm_id                 in     number default null
            ,p_ptip_id                in     number default null
            ,p_pl_typ_id              in     number default null
            ,p_person_id              in     number
            ,p_per_in_ler_id          in     number
            ,p_lf_evt_ocrd_dt         in     date
            ,p_business_group_id      in     number
            ,p_effective_date         in     date
            ,p_validate               in     boolean default false
            ,p_cbr_elig_perd_strt_dt     out nocopy date
            ,p_cbr_elig_perd_end_dt      out nocopy date
            ,p_old_cbr_elig_perd_end_dt  out nocopy date
            ,p_cbr_quald_bnf_id          out nocopy number
            ,p_cqb_object_version_number out nocopy number
            ,p_cvrd_emp_person_id        out nocopy number
            ,p_dsbld_apls                out nocopy boolean
            ,p_update                    out nocopy boolean
            );
---------------------------------------------------------------
procedure end_prtt_cobra_eligibility
            (p_per_in_ler_id         in     number
            ,p_person_id             in     number
            ,p_business_group_id     in     number
            ,p_effective_date        in     date
            ,p_validate              in     boolean default false
            );
---------------------------------------------------------------
procedure end_cobra_eligibility
          (p_per_in_ler_id             in number
          ,p_cbr_quald_bnf_id          in number
          ,p_cqb_object_version_number in number
          ,p_quald_bnf_flag            in varchar2 default 'Y'
          ,p_old_cbr_elig_perd_end_dt  in date
          ,p_cbr_elig_perd_end_dt      in date
          ,p_cbr_inelg_rsn_cd          in varchar2 default hr_api.g_varchar2
          ,p_business_group_id         in number
          ,p_effective_date            in date
          ,p_validate                  in boolean default false
          );
---------------------------------------------------------------
procedure get_amount_due
          (p_person_id         in number
          ,p_business_group_id in number
          ,p_assignment_id     in number
          ,p_payroll_id        in number
          ,p_organization_id   in number
          ,p_effective_date    in date
          ,p_prtt_enrt_rslt_id in number
          ,p_acty_base_rt_id   in number
          ,p_ann_rt_val        in number
          ,p_mlt_cd            in varchar2
          ,p_rt_strt_dt        in date
          ,p_rt_end_dt         in date
          ,p_first_month_amt   out nocopy number
          ,p_per_month_amt     out nocopy number
          ,p_last_month_amt    out nocopy number
          );
---------------------------------------------------------------
procedure allocate_payment
          (p_effective_date    in date
          ,p_amount_paid       in number
          ,p_acty_base_rt_id   in number
          ,p_prtt_enrt_rslt_id in number
          ,p_business_group_id in number
          ,p_person_id         in number
          ,p_rt_strt_dt        in date
          ,p_month_strt_dt     in date
          ,p_warning           out nocopy boolean
          ,p_excess_amount     out nocopy number
          );
---------------------------------------------------------------
procedure get_unpaid_rate
          (p_person_id            in number
          ,p_pgm_id               in number
          ,p_pl_typ_id            in number
          ,p_business_group_id    in number
          ,p_effective_date       in date
          ,p_element_type_id      in number
          ,p_input_value_id       in number
          ,p_mode                 in varchar2
          ,p_prev_rt_strt_dt      in date
          ,p_rt_strt_dt           out nocopy date
          ,p_elm_chg_warning      out nocopy varchar2
          );
---------------------------------------------------------------
procedure get_due_and_payment_amt
          (p_person_id         in number
          ,p_effective_date    in date
          ,p_acty_base_rt_id   in number
          ,p_business_group_id in number
          ,p_prtt_enrt_rslt_id in number
          ,p_rt_strt_dt        in date
          ,p_rt_end_dt         in date
          ,p_ann_rt_val        in number
          ,p_mlt_cd            in varchar2
          ,p_amt_due           out nocopy number
          ,p_prev_pymts        out nocopy number
          );
---------------------------------------------------------------
function get_comp_object_name
         (p_pl_id          in number
         ,p_oipl_id        in number
         ,p_effective_date in date
         )
         return varchar2;
---------------------------------------------------------------

END;

 

/
