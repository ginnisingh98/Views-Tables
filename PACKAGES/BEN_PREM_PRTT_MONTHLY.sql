--------------------------------------------------------
--  DDL for Package BEN_PREM_PRTT_MONTHLY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PREM_PRTT_MONTHLY" AUTHID CURRENT_USER as
/* $Header: benprprm.pkh 115.6 2003/01/01 00:00:56 mmudigon ship $ */

  type g_apr_cak_rec is record
  (sgmt varchar2(60));

  type g_apr_cak_table is table of g_apr_cak_rec
  index by binary_integer;

  g_rec         ben_type.g_report_rec ;

--
-- ----------------------------------------------------------------------------
-- |------------------------< premium_warning >----------------------------|
-- ----------------------------------------------------------------------------
-- Procedure used to create warning messages for premiums.
procedure premium_warning
          (p_person_id            in number default null
          ,p_prtt_enrt_rslt_id    in number
          ,p_effective_start_date in date
          ,p_effective_date       in date
          ,p_warning              in varchar2);

-- ----------------------------------------------------------------------------
-- |------------------------< compute_partial_mo >----------------------------|
-- ----------------------------------------------------------------------------
-- Procedure used to compute partial month premiums.  it's called internally
-- and from benprprc.pkb
procedure compute_partial_mo
                   (p_business_group_id   in number
                   ,p_effective_date      in date
                   ,p_actl_prem_id        in number
                   ,p_person_id           in number
                   ,p_enrt_cvg_strt_dt    in date
                   ,p_enrt_cvg_thru_dt    in date
                   ,p_prtl_mo_det_mthd_cd in varchar2 default null
                   ,p_prtl_mo_det_mthd_rl in number   default null
                   ,p_wsh_rl_dy_mo_num    in number   default null
                   ,p_rndg_cd             in varchar2 default null
                   ,p_rndg_rl             in number   default null
                   ,p_lwr_lmt_calc_rl     in number   default null
                   ,p_lwr_lmt_val         in number   default null
                   ,p_upr_lmt_calc_rl     in number   default null
                   ,p_upr_lmt_val         in number   default null
                   ,p_pgm_id              in number   default null
                   ,p_pl_typ_id           in number   default null
                   ,p_pl_id               in number   default null
                   ,p_opt_id              in number   default null
                   ,p_val                 in out nocopy number) ;
-- ----------------------------------------------------------------------------
-- |------------------------------< main >------------------------------------|
-- ----------------------------------------------------------------------------
-- This is the procedure to call to determine all the 'ENRT' type premiums for
-- the month.
procedure main
  (p_validate                 in varchar2 default 'N'
  ,p_person_id                in number default null
  ,p_person_action_id         in number default null
  ,p_comp_selection_rl        in number default null
  ,p_pgm_id                   in number default null
  ,p_pl_typ_id                in number default null
  ,p_pl_id                    in number default null
  ,p_object_version_number    in out nocopy number
  ,p_business_group_id        in number
  ,p_mo_num                   in number
  ,p_yr_num                   in number
  ,p_first_day_of_month       in date
  ,p_effective_date           in date) ;
end ben_prem_prtt_monthly;

 

/
