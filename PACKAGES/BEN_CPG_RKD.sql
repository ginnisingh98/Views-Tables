--------------------------------------------------------
--  DDL for Package BEN_CPG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPG_RKD" AUTHID CURRENT_USER as
/* $Header: becpgrhi.pkh 120.0 2005/05/28 01:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_group_per_in_ler_id          in number
  ,p_group_pl_id                  in number
  ,p_group_oipl_id                in number
  ,p_lf_evt_ocrd_dt_o             in date
  ,p_bdgt_pop_cd_o                in varchar2
  ,p_due_dt_o                     in date
  ,p_access_cd_o                  in varchar2
  ,p_approval_cd_o                in varchar2
  ,p_approval_date_o              in date
  ,p_approval_comments_o          in varchar2
  ,p_submit_cd_o                  in varchar2
  ,p_submit_date_o                in date
  ,p_submit_comments_o            in varchar2
  ,p_dist_bdgt_val_o              in number
  ,p_ws_bdgt_val_o                in number
  ,p_rsrv_val_o                   in number
  ,p_dist_bdgt_mn_val_o           in number
  ,p_dist_bdgt_mx_val_o           in number
  ,p_dist_bdgt_incr_val_o         in number
  ,p_ws_bdgt_mn_val_o             in number
  ,p_ws_bdgt_mx_val_o             in number
  ,p_ws_bdgt_incr_val_o           in number
  ,p_rsrv_mn_val_o                in number
  ,p_rsrv_mx_val_o                in number
  ,p_rsrv_incr_val_o              in number
  ,p_dist_bdgt_iss_val_o          in number
  ,p_ws_bdgt_iss_val_o            in number
  ,p_dist_bdgt_iss_date_o         in date
  ,p_ws_bdgt_iss_date_o           in date
  ,p_ws_bdgt_val_last_upd_date_o  in date
  ,p_dist_bdgt_val_last_upd_dat_o in date
  ,p_rsrv_val_last_upd_date_o     in date
  ,p_ws_bdgt_val_last_upd_by_o    in number
  ,p_dist_bdgt_val_last_upd_by_o  in number
  ,p_rsrv_val_last_upd_by_o       in number
  ,p_object_version_number_o      in number
  );
--
end ben_cpg_rkd;

 

/
