--------------------------------------------------------
--  DDL for Package BEN_UPDATE_LEDGERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_UPDATE_LEDGERS" AUTHID CURRENT_USER as
/* $Header: benbplup.pkh 115.3 2002/12/24 15:43:55 bmanyam noship $ */

Procedure main;

procedure get_cmcd_ann_values
           (p_bnft_prvdd_ldgr_id   in number default null,
           p_acty_base_rt_id       in number,
           p_prtt_enrt_rslt_id     in number,
           p_business_group_id     in number,
           p_effective_start_date  in date,
           p_per_in_ler_id         in number,
           p_frftd_val             in number,
           p_used_val              in number,
           p_prvdd_val             in number,
           p_cash_recd_val         in number,
           p_rld_up_val            in number,
           p_acty_ref_perd_cd    out nocopy varchar2,
           p_cmcd_ref_perd_cd    out nocopy varchar2,
           p_cmcd_frftd_val      out nocopy number,
           p_cmcd_prvdd_val      out nocopy number,
           p_cmcd_rld_up_val     out nocopy number,
           p_cmcd_used_val       out nocopy number,
           p_cmcd_cash_recd_val  out nocopy number,
           p_ann_frftd_val       out nocopy number,
           p_ann_prvdd_val       out nocopy number,
           p_ann_rld_up_val      out nocopy number,
           p_ann_used_val        out nocopy number,
           p_ann_cash_recd_val   out nocopy number) ;

procedure get_dt_mode
          (p_effective_date        in  date,
           p_base_key_value        in  number,
           p_mode                  out nocopy varchar2) ;
end ben_update_ledgers;


 

/
