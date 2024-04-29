--------------------------------------------------------
--  DDL for Package BEN_PROVIDER_POOLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PROVIDER_POOLS" AUTHID CURRENT_USER as
/* $Header: benpstcr.pkh 120.0.12010000.1 2008/07/29 12:29:09 appldev ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Benefit provider pools
Purpose
	This package is used to create benefit provided ledger entries as well
	as flex credit enrolment results.
History
	Date		Who		Version     What?
	----		---		-------	-------
  07 Jun 98   jcarpent  110.0   Created
  10 Nov 98   jcarpent  115.5   Added create_rollover_enrt
  27 May 99   maagrawa  115.6   Added new procedures for flex
                                 credits re-computation when
                                 choices may not be there.
  21 Oct 99   lmcdonal  115.7   Added per-in-ler to create_flex.
  12 Nov 99   lmcdonal  115.8   Added enrt_mthd_cd to create_debit_ledger_entry,
                                recompute_flex_credits
  25 Jan 00   maagrawa  115.9   Added parameter p_per_in_ler_id to procedures
                                create_credit_ledger_entry,
                                create_debit_ledger_entry,
                                cleanup_invalid_ledger_entries,
                                create_flex_credit_enrolment, total_pools,
                                create_rollover_enrollment.
  28 Sep 00   stee      115.10  Added p_net_credit_val to
                                create_flex_credit_enrolment.
  12 Oct 00   maagrawa  115.11  Added p_old_rlovr_amt to
                                create_rollover_enrollment.
  03 Jul 01   tmathers  115.13  fixed 9i compliance issues.
  10 Jul 01   tmathers  115.14  Converted compute_excess, create_credit_ledger_entry and
                                create_debit_ledger_entry for EFC.
  25-Jan-02   pbodla    115.15  Bug 2185478 Added procedure to validate the
                                rollover value entered by the user on flex
                                enrollment form and show proper message immediately
  28-Jan-02   pbodla    115.16  Added dbdrv line.
  08-Aug-02   kmahendr  115.17  Bug#2382651- added additional parameter to total_pools and
                                create_flex_credit_enrollment procedures.
  30-Dec-02   mmudigon  115.19  NOCOPY
*/
--------------------------------------------------------------------------------
g_credit_pool_result_id number:=null;
g_credit_pool_person_id number:=null;
--
-- Bug 2185478 : Globals used for validating the rollover amounts
--
g_balance           number;
g_mx_dstrbl_pct_num number;
g_mx_rlovr_val      number;
g_mx_elcn_val       number;
g_mn_dstrbl_pct_num number;
g_mn_rlovr_val      number;
g_mn_elcn_val       number;
g_mx_rlovr_rl_val   number;
--
procedure validate_rollover_val
  (p_calculate_only_mode  in     boolean default false
  ,p_bnft_prvdr_pool_id   in     number
  ,p_person_id            in     number
  ,p_per_in_ler_id        in     number
  ,p_acty_base_rt_id      in     number default null
  ,p_enrt_mthd_cd         in     varchar2
  ,p_effective_date       in     date
  ,p_datetrack_mode       in     varchar2
  ,p_business_group_id    in     number
  ,p_pct_rndg_cd          in     varchar2
  ,p_pct_rndg_rl          in     number
  ,p_dflt_excs_trtmt_cd   in     varchar2
  ,p_new_rollover_val     in     number
  ,p_rollover_val            out nocopy number
  );
--
procedure accumulate_pools(
	p_validate			in boolean default false,
	p_person_id			in number,
	p_elig_per_elctbl_chc_id	in number,
	p_enrt_mthd_cd			in varchar2,
	p_effective_date		in date,
	p_business_group_id		in number
);

procedure accumulate_pools_for_choice(
	p_validate			in boolean default false,
	p_person_id			in number,
	p_epe_rec			in ben_epe_shd.g_rec_type,
	p_enrt_mthd_cd			in varchar2,
	p_effective_date		in date
);

function person_enrolled_in_choice(
	p_person_id			number,
	p_epe_rec			ben_epe_shd.g_rec_type,
	p_old_result_id			number default hr_api.g_number,
	p_effective_date		date) return boolean;

procedure create_credit_ledger_entry(
	p_validate			in boolean default false,
	p_person_id			in number,
	p_elig_per_elctbl_chc_id	in number,
        p_per_in_ler_id                 in number,
	p_business_group_id		in number,
	p_bnft_prvdr_pool_id		in number,
	p_enrt_mthd_cd			in varchar2,
	p_effective_date		in date
);

procedure create_credit_ledger_entry
  (p_validate            in     boolean default null
  ,p_calculate_only_mode in     boolean default false
  ,p_person_id           in     number
  ,p_epe_rec             in     ben_epe_shd.g_rec_type
  ,p_enrt_mthd_cd        in     varchar2
  ,p_effective_date      in     date
  --
  ,p_bnft_prvdd_ldgr_id     out nocopy number
  ,p_bpl_prvdd_val          out nocopy number
  );
procedure create_debit_ledger_entry
  (p_validate                in     boolean default false
  ,p_calculate_only_mode     in     boolean default false
  ,p_person_id               in     number
  ,p_per_in_ler_id           in     number
  ,p_elig_per_elctbl_chc_id  in     number
  ,p_prtt_enrt_rslt_id       in     number
  ,p_decr_bnft_prvdr_pool_id in     number
  ,p_acty_base_rt_id         in     number
  ,p_prtt_rt_val_id          in     number
  ,p_enrt_mthd_cd            in     varchar2
  ,p_val                     in     number
  ,p_bnft_prvdd_ldgr_id      in out nocopy number
  ,p_business_group_id       in     number
  ,p_effective_date          in     date
  --
  ,p_bpl_used_val                  out nocopy number
  );

procedure create_debit_ledger_entry
  (p_validate            in     boolean default false
  ,p_calculate_only_mode in     boolean default false
  ,p_person_id           in     number
  ,p_enrt_mthd_cd        in     varchar2
  ,p_epe_rec             in     ben_epe_shd.g_rec_type
  ,p_enrt_rt_rec         in     ben_ecr_shd.g_rec_type
  ,p_bnft_prvdd_ldgr_id  in out nocopy number
  ,p_business_group_id   in     number
  ,p_effective_date      in     date
  --
  ,p_bpl_used_val           out nocopy number
  );

procedure cleanup_invalid_ledger_entries(  -- so few args because uses global table
	p_validate			in boolean default false,
	p_person_id			in number,
	p_prtt_enrt_rslt_id		in number,
	p_effective_date		in date,
	p_business_group_id		in number
);

procedure cleanup_invalid_ledger_entries(  -- so few args because uses global table
	p_validate			in boolean default false,
	p_person_id			in number,
        p_per_in_ler_id                 in number,
	p_effective_date		in date,
	p_business_group_id		in number
);

procedure create_flex_credit_enrolment(
	p_validate			in boolean default false,
	p_person_id			in number,
	p_enrt_mthd_cd                  in varchar2,
	p_business_group_id             in number,
	p_effective_date                in date,
	p_prtt_enrt_rslt_id             out nocopy number,
	p_prtt_rt_val_id                out nocopy number,
  	p_per_in_ler_id                 in number,
	p_rt_val                        in number,
	p_net_credit_val                in number default null,
        p_pgm_id                        in number default null
);

procedure total_pools(
	p_validate			in boolean default false,
	p_prtt_enrt_rslt_id		in out nocopy number,
	p_prtt_rt_val_id		in out nocopy number,
	p_acty_ref_perd_cd	 out nocopy varchar2,
	p_acty_base_rt_id	 out nocopy number,
	p_rt_strt_dt		 out nocopy date,
	p_rt_val		 out nocopy number,
	p_element_type_id	 out nocopy number,
	p_person_id			in number,
        p_per_in_ler_id                 in number,
	p_enrt_mthd_cd			in varchar2,
	p_effective_date		in date,
	p_business_group_id		in number,
        p_pgm_id                        in number  default null
);

procedure remove_bnft_prvdd_ldgr(
	p_prtt_enrt_rslt_id		in number,
	p_effective_date		in date,
	p_business_group_id		in number,
	p_validate			in boolean,
	p_datetrack_mode		in varchar2
);
procedure create_rollover_enrollment(
        p_bnft_prvdr_pool_id  in number,
        p_person_id           in  number,
        p_per_in_ler_id       in number,
        p_effective_date      in date,
        p_datetrack_mode      in varchar2,
        p_acty_base_rt_id     in number,
        p_rlovr_amt           in number,
        p_old_rlovr_amt       in number,
        p_business_group_id   in number,
        p_enrt_mthd_cd        in varchar2
);
--
procedure update_rate(p_prtt_rt_val_id      in out nocopy number,
                      p_val                 in  number,
                      p_prtt_enrt_rslt_id   in  number,
                      p_ended_per_in_ler_id in  number,
                      p_effective_date      in  date,
                      p_business_group_id   in  number);
 --
procedure compute_excess
  (p_calculate_only_mode in     boolean default false
  ,p_bnft_prvdr_pool_id  in     number
  ,p_flex_rslt_id        in     number
  ,p_person_id           in     number
  ,p_per_in_ler_id       in     number
  ,p_enrt_mthd_cd        in     varchar2
  ,p_effective_date      in     date
  ,p_business_group_id   in     number
  --
  ,p_frftd_val              out nocopy number
  ,p_def_exc_amount         out nocopy number
  ,p_bpl_cash_recd_val      out nocopy number
  );
--
procedure recompute_flex_credits
  (p_person_id            in     number
  ,p_enrt_mthd_cd         in     varchar2
  ,p_prtt_enrt_rslt_id    in     number
  ,p_per_in_ler_id        in     number
  ,p_pgm_id               in     number
  ,p_business_group_id    in     number
  ,p_effective_date       in     date
  );
--
end ben_provider_pools;

/
