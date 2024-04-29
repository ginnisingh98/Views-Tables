--------------------------------------------------------
--  DDL for Package BEN_CPG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CPG_RKI" AUTHID CURRENT_USER as
/* $Header: becpgrhi.pkh 120.0 2005/05/28 01:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_group_per_in_ler_id          in number
  ,p_group_pl_id                  in number
  ,p_group_oipl_id                in number
  ,p_lf_evt_ocrd_dt               in date
  ,p_bdgt_pop_cd                  in varchar2
  ,p_due_dt                       in date
  ,p_access_cd                    in varchar2
  ,p_approval_cd                  in varchar2
  ,p_approval_date                in date
  ,p_approval_comments            in varchar2
  ,p_submit_cd                    in varchar2
  ,p_submit_date                  in date
  ,p_submit_comments              in varchar2
  ,p_dist_bdgt_val                in number
  ,p_ws_bdgt_val                  in number
  ,p_rsrv_val                     in number
  ,p_dist_bdgt_mn_val             in number
  ,p_dist_bdgt_mx_val             in number
  ,p_dist_bdgt_incr_val           in number
  ,p_ws_bdgt_mn_val               in number
  ,p_ws_bdgt_mx_val               in number
  ,p_ws_bdgt_incr_val             in number
  ,p_rsrv_mn_val                  in number
  ,p_rsrv_mx_val                  in number
  ,p_rsrv_incr_val                in number
  ,p_dist_bdgt_iss_val            in number
  ,p_ws_bdgt_iss_val              in number
  ,p_dist_bdgt_iss_date           in date
  ,p_ws_bdgt_iss_date             in date
  ,p_ws_bdgt_val_last_upd_date    in date
  ,p_dist_bdgt_val_last_upd_date  in date
  ,p_rsrv_val_last_upd_date       in date
  ,p_ws_bdgt_val_last_upd_by      in number
  ,p_dist_bdgt_val_last_upd_by    in number
  ,p_rsrv_val_last_upd_by         in number
  ,p_object_version_number        in number
  );
end ben_cpg_rki;

 

/
