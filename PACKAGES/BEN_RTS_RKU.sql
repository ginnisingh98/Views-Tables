--------------------------------------------------------
--  DDL for Package BEN_RTS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RTS_RKU" AUTHID CURRENT_USER as
/* $Header: bertsrhi.pkh 120.1 2006/01/09 14:36 maagrawa noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_person_rate_id               in number
  ,p_group_per_in_ler_id          in number
  ,p_pl_id                        in number
  ,p_oipl_id                      in number
  ,p_group_pl_id                  in number
  ,p_group_oipl_id                in number
  ,p_lf_evt_ocrd_dt               in date
  ,p_person_id                    in number
  ,p_assignment_id                in number
  ,p_elig_flag                    in varchar2
  ,p_ws_val                       in number
  ,p_ws_mn_val                    in number
  ,p_ws_mx_val                    in number
  ,p_ws_incr_val                  in number
  ,p_elig_sal_val                 in number
  ,p_stat_sal_val                 in number
  ,p_oth_comp_val                 in number
  ,p_tot_comp_val                 in number
  ,p_misc1_val                    in number
  ,p_misc2_val                    in number
  ,p_misc3_val                    in number
  ,p_rec_val                      in number
  ,p_rec_mn_val                   in number
  ,p_rec_mx_val                   in number
  ,p_rec_incr_val                 in number
  ,p_ws_val_last_upd_date         in date
  ,p_ws_val_last_upd_by           in number
  ,p_pay_proposal_id              in number
  ,p_element_entry_value_id       in number
  ,p_inelig_rsn_cd                in varchar2
  ,p_elig_ovrid_dt                in date
  ,p_elig_ovrid_person_id         in number
  ,p_copy_dist_bdgt_val           in number
  ,p_copy_ws_bdgt_val             in number
  ,p_copy_rsrv_val                in number
  ,p_copy_dist_bdgt_mn_val        in number
  ,p_copy_dist_bdgt_mx_val        in number
  ,p_copy_dist_bdgt_incr_val      in number
  ,p_copy_ws_bdgt_mn_val          in number
  ,p_copy_ws_bdgt_mx_val          in number
  ,p_copy_ws_bdgt_incr_val        in number
  ,p_copy_rsrv_mn_val             in number
  ,p_copy_rsrv_mx_val             in number
  ,p_copy_rsrv_incr_val           in number
  ,p_copy_dist_bdgt_iss_val       in number
  ,p_copy_ws_bdgt_iss_val         in number
  ,p_copy_dist_bdgt_iss_date      in date
  ,p_copy_ws_bdgt_iss_date        in date
  ,p_comp_posting_date            in date
  ,p_ws_rt_start_date             in date
  ,p_currency                     in varchar2
  ,p_object_version_number        in number
  ,p_group_per_in_ler_id_o        in number
  ,p_pl_id_o                      in number
  ,p_oipl_id_o                    in number
  ,p_group_pl_id_o                in number
  ,p_group_oipl_id_o              in number
  ,p_lf_evt_ocrd_dt_o             in date
  ,p_person_id_o                  in number
  ,p_assignment_id_o              in number
  ,p_elig_flag_o                  in varchar2
  ,p_ws_val_o                     in number
  ,p_ws_mn_val_o                  in number
  ,p_ws_mx_val_o                  in number
  ,p_ws_incr_val_o                in number
  ,p_elig_sal_val_o               in number
  ,p_stat_sal_val_o               in number
  ,p_oth_comp_val_o               in number
  ,p_tot_comp_val_o               in number
  ,p_misc1_val_o                  in number
  ,p_misc2_val_o                  in number
  ,p_misc3_val_o                  in number
  ,p_rec_val_o                    in number
  ,p_rec_mn_val_o                 in number
  ,p_rec_mx_val_o                 in number
  ,p_rec_incr_val_o               in number
  ,p_ws_val_last_upd_date_o       in date
  ,p_ws_val_last_upd_by_o         in number
  ,p_pay_proposal_id_o            in number
  ,p_element_entry_value_id_o     in number
  ,p_inelig_rsn_cd_o              in varchar2
  ,p_elig_ovrid_dt_o              in date
  ,p_elig_ovrid_person_id_o       in number
  ,p_copy_dist_bdgt_val_o         in number
  ,p_copy_ws_bdgt_val_o           in number
  ,p_copy_rsrv_val_o              in number
  ,p_copy_dist_bdgt_mn_val_o      in number
  ,p_copy_dist_bdgt_mx_val_o      in number
  ,p_copy_dist_bdgt_incr_val_o    in number
  ,p_copy_ws_bdgt_mn_val_o        in number
  ,p_copy_ws_bdgt_mx_val_o        in number
  ,p_copy_ws_bdgt_incr_val_o      in number
  ,p_copy_rsrv_mn_val_o           in number
  ,p_copy_rsrv_mx_val_o           in number
  ,p_copy_rsrv_incr_val_o         in number
  ,p_copy_dist_bdgt_iss_val_o     in number
  ,p_copy_ws_bdgt_iss_val_o       in number
  ,p_copy_dist_bdgt_iss_date_o    in date
  ,p_copy_ws_bdgt_iss_date_o      in date
  ,p_comp_posting_date_o          in date
  ,p_ws_rt_start_date_o           in date
  ,p_currency_o                   in varchar2
  ,p_object_version_number_o      in number
  );
--
end ben_rts_rku;

 

/
