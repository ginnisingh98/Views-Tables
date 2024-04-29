--------------------------------------------------------
--  DDL for Package BEN_PROCESS_COMPENSATION_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PROCESS_COMPENSATION_W" AUTHID CURRENT_USER AS
/* $Header: bencmpws.pkh 120.0 2005/05/28 03:50:25 appldev noship $*/
--
-- Global constants
g_column_delimiter      constant varchar2(3) := '~^|';
--
--
-- ---------------------------------------------------------------------------+
-- ---------------------- < get_comp_data_from_tt> -------------------------+
-- ---------------------------------------------------------------------------+
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is an overloaded version.
-- ---------------------------------------------------------------------------+
procedure get_comp_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  number
   ,p_elig_per_elctbl_chc_id          in out nocopy number
   ,p_prtt_enrt_rslt_id               out nocopy number
   ,p_person_id                       out nocopy number
   ,p_per_in_ler_id                   out nocopy number
   ,p_pgm_id                          out nocopy number
   ,p_pl_id                           out nocopy number
   ,p_effective_date                  out nocopy date
   ,p_enrt_bnft_id                    out nocopy number
   ,p_bnft_amt                        out nocopy number
   ,p_enrt_rt_id                      out nocopy number
   ,p_prtt_rt_val_id                  out nocopy number
   ,p_rt_val                          out nocopy number
   ,p_datetrack_mode                  out nocopy varchar2
   ,p_effective_start_date            out nocopy date
   ,p_object_version_number           out nocopy number
   ,p_business_group_id               out nocopy number
   ,p_enrt_cvg_strt_dt                out nocopy date
   ,p_enrt_cvg_thru_dt                out nocopy date
   ,p_justification                   out nocopy varchar2
   ,p_pl_name                         out nocopy varchar2
   ,p_frequency_meaning               out nocopy varchar2
   ,p_frequency_cd                    out nocopy varchar2
   ,p_entr_rt_at_enrt_flag            out nocopy varchar2
   ,p_entr_bnft_at_enrt_flag          out nocopy varchar2
   ,p_rt_nnmntry_uom                  out nocopy varchar2
   ,p_bnft_nnmntry_uom                out nocopy varchar2
   ,p_rt_uom                          out nocopy varchar2
   ,p_bnft_uom                        out nocopy varchar2
   ,p_rt_mn_val                       out nocopy number
   ,p_rt_mx_val                       out nocopy number
   ,p_bnft_mn_val                     out nocopy number
   ,p_bnft_mx_val                     out nocopy number
   ,p_enrt_cvg_strt_dt_cd             out nocopy varchar2
   ,p_acty_ref_perd_cd                out nocopy varchar2
   ,p_currency_cd                     out nocopy varchar2
   ,p_limit_enrt_rt_id                out nocopy number
   ,p_limit_prtt_rt_val_id            out nocopy number
   ,p_limit_rt_val                    out nocopy number
   ,p_limit_entr_rt_at_enrt_flag      out nocopy varchar2
   ,p_pl_typ_id                       out nocopy number
   ,p_ler_id                          out nocopy number
   ,p_limit_dsply_on_enrt_flag        out nocopy varchar2
   ,p_currency_symbol                 out nocopy varchar2
   ,p_rt_strt_dt                      out nocopy date
   ,p_rt_end_dt                       out nocopy date
   ,p_rt_strt_dt_cd                   out nocopy varchar2
   ,p_rt_end_dt_cd                    out nocopy varchar2
   ,p_rslt_bnft_amt                   out nocopy number
   ,p_rtval_rt_end_dt                 out nocopy date
   ,p_rtval_rt_val                    out nocopy number
   ,p_rtval_limit_rt_val              out nocopy number
   ,p_bnft_typ_meaning                out nocopy varchar2
   ,p_ctfn_names                      out nocopy varchar2
   ,p_rt_update_mode                  out nocopy varchar2
   ,p_rtval_rt_strt_dt                out nocopy date
   ,p_nip_pl_uom                      out nocopy varchar2
);
--
-- ---------------------------------------------------------------------------+
-- ---------------------- < get_comp_data_from_tt> -------------------------+
-- ---------------------------------------------------------------------------+
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is the procedure which does the actual work.
-- ---------------------------------------------------------------------------+
procedure get_comp_data_from_tt
   (p_transaction_step_id             in  number
   ,p_elig_per_elctbl_chc_id          out nocopy number
   ,p_prtt_enrt_rslt_id               out nocopy number
   ,p_person_id                       out nocopy number
   ,p_per_in_ler_id                   out nocopy number
   ,p_pgm_id                          out nocopy number
   ,p_pl_id                           out nocopy number
   ,p_effective_date                  out nocopy date
   ,p_enrt_bnft_id                    out nocopy number
   ,p_bnft_amt                        out nocopy number
   ,p_enrt_rt_id                      out nocopy number
   ,p_prtt_rt_val_id                  out nocopy number
   ,p_rt_val                          out nocopy number
   ,p_datetrack_mode                  out nocopy varchar2
   ,p_effective_start_date            out nocopy date
   ,p_object_version_number           out nocopy number
   ,p_business_group_id               out nocopy number
   ,p_enrt_cvg_strt_dt                out nocopy date
   ,p_enrt_cvg_thru_dt                out nocopy date
   ,p_justification                   out nocopy varchar2
   ,p_pl_name                         out nocopy varchar2
   ,p_frequency_meaning               out nocopy varchar2
   ,p_frequency_cd                    out nocopy varchar2
   ,p_entr_rt_at_enrt_flag            out nocopy varchar2
   ,p_entr_bnft_at_enrt_flag          out nocopy varchar2
   ,p_rt_nnmntry_uom                  out nocopy varchar2
   ,p_bnft_nnmntry_uom                out nocopy varchar2
   ,p_rt_uom                          out nocopy varchar2
   ,p_bnft_uom                        out nocopy varchar2
   ,p_rt_mn_val                       out nocopy number
   ,p_rt_mx_val                       out nocopy number
   ,p_bnft_mn_val                     out nocopy number
   ,p_bnft_mx_val                     out nocopy number
   ,p_enrt_cvg_strt_dt_cd             out nocopy varchar2
   ,p_acty_ref_perd_cd                out nocopy varchar2
   ,p_currency_cd                     out nocopy varchar2
   ,p_limit_enrt_rt_id                out nocopy number
   ,p_limit_prtt_rt_val_id            out nocopy number
   ,p_limit_rt_val                    out nocopy number
   ,p_limit_entr_rt_at_enrt_flag      out nocopy varchar2
   ,p_pl_typ_id                       out nocopy number
   ,p_ler_id                          out nocopy number
   ,p_limit_dsply_on_enrt_flag        out nocopy varchar2
   ,p_currency_symbol                 out nocopy varchar2
   ,p_rt_strt_dt                      out nocopy date
   ,p_rt_end_dt                       out nocopy date
   ,p_rt_strt_dt_cd                   out nocopy varchar2
   ,p_rt_end_dt_cd                    out nocopy varchar2
   ,p_rslt_bnft_amt                   out nocopy number
   ,p_rtval_rt_end_dt                 out nocopy date
   ,p_rtval_rt_val                    out nocopy number
   ,p_rtval_limit_rt_val              out nocopy number
   ,p_bnft_typ_meaning                out nocopy varchar2
   ,p_ctfn_names                      out nocopy varchar2
   ,p_rt_update_mode                  out nocopy varchar2
   ,p_rtval_rt_strt_dt                out nocopy date
   ,p_nip_pl_uom                      out nocopy varchar2);
--
--
procedure get_comp_data_from_tt
   (p_transaction_step_id           in number
   ,p_column_names                  in varchar2
   ,p_column_values                 out nocopy varchar2);
--
--
procedure get_comp_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_elig_per_elctbl_chc_id          in  number
   ,p_column_names                    in  varchar2
   ,p_column_values                   out nocopy varchar2);
--
-- ---------------------------------------------------------------------------+
-- ----------------------- < update_compensation > ---------------------------+
-- ---------------------------------------------------------------------------+
-- Purpose: This procedure will perform validations when a user presses Next
--          on Update Plan Details entry page or on the Review page.
--          Either case, the data will be saved to the transaction table.
--          If this procedure is invoked from Review page, it will first check
--          that if a transaction already exists.  If it does, it will update
--          the current transaction record.
-- ---------------------------------------------------------------------------+
procedure update_compensation
  (p_item_type                    in varchar2
  ,p_item_key                     in varchar2
  ,p_actid                        in number
  ,p_login_person_id              in number
  ,p_process_section_name         in varchar2
  ,p_review_page_region_code      in varchar2
  ,p_elig_per_elctbl_chc_id       in number
  ,p_prtt_enrt_rslt_id            in number
  ,p_person_id                    in number
  ,p_per_in_ler_id                in number
  ,p_pgm_id                       in number
  ,p_pl_id                        in number
  ,p_effective_date               in date
  ,p_enrt_bnft_id                 in number
  ,p_bnft_amt                     in number
  ,p_enrt_rt_id                   in number
  ,p_prtt_rt_val_id               in number
  ,p_rt_val                       in number
  ,p_datetrack_mode               in varchar2
  ,p_effective_start_date         in date
  ,p_object_version_number        in number
  ,p_business_group_id            in number
  ,p_enrt_cvg_strt_dt             in date
  ,p_enrt_cvg_thru_dt             in date
  ,p_justification                in varchar2
  ,p_pl_name                      in varchar2
  ,p_frequency_meaning            in varchar2
  ,p_frequency_cd                 in varchar2
  ,p_entr_rt_at_enrt_flag         in varchar2
  ,p_entr_bnft_at_enrt_flag       in varchar2
  ,p_rt_nnmntry_uom               in varchar2
  ,p_bnft_nnmntry_uom             in varchar2
  ,p_rt_uom                       in varchar2
  ,p_bnft_uom                     in varchar2
  ,p_rt_mn_val                    in number
  ,p_rt_mx_val                    in number
  ,p_bnft_mn_val                  in number
  ,p_bnft_mx_val                  in number
  ,p_enrt_cvg_strt_dt_cd          in varchar2
  ,p_acty_ref_perd_cd             in varchar2
  ,p_currency_cd                  in varchar2
  ,p_limit_enrt_rt_id             in number
  ,p_limit_prtt_rt_val_id         in number
  ,p_limit_rt_val                 in number
  ,p_limit_entr_rt_at_enrt_flag   in varchar2
  ,p_pl_typ_id                    in number
  ,p_ler_id                       in number
  ,p_limit_dsply_on_enrt_flag     in varchar2
  ,p_currency_symbol              in varchar2
  ,p_rt_strt_dt                   in date
  ,p_rt_end_dt                    in date
  ,p_rt_strt_dt_cd                in varchar2
  ,p_rt_end_dt_cd                 in varchar2
  ,p_rslt_bnft_amt                in number
  ,p_rtval_rt_end_dt              in date
  ,p_rtval_rt_val                 in number
  ,p_rtval_limit_rt_val           in number
  ,p_bnft_typ_meaning             in varchar2
  ,p_ctfn_names                   in varchar2
  ,p_rt_update_mode               in varchar2
  ,p_rtval_rt_strt_dt             in date
  ,p_save_mode                    in varchar2 default null
  ,p_nip_pl_uom                   in varchar2
 );
--
-- ---------------------------------------------------------------------------+
-- ----------------------------- < process_api > -----------------------------+
-- ---------------------------------------------------------------------------+
-- Purpose: This procedure will be invoked in workflow notification
--          when an approver approves all the changes.  This procedure
--          will call the api to update to the database with p_validate
--          equal to false.
-- ---------------------------------------------------------------------------+
procedure process_api
          (p_validate            in boolean default false
          ,p_transaction_step_id in number
          ,p_effective_date      in varchar2 default null);
--
--
procedure back_from_review(p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode        in varchar2,
                           result         out nocopy varchar2);
--
procedure update_object_version
          (p_transaction_step_id in     number
          ,p_login_person_id     in     number);
--
--
end ben_process_compensation_w;
--
--

 

/
