--------------------------------------------------------
--  DDL for Package BEN_ECR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECR_UPD" AUTHID CURRENT_USER as
/* $Header: beecrrhi.pkh 120.0 2005/05/28 01:53:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the update
--   process for the specified entity. The role of this process is
--   to update a fully validated row for the HR schema passing back
--   to the calling process, any system generated values (e.g.
--   object version number attribute). This process is the main
--   backbone of the upd business process. The processing of this
--   procedure is as follows:
--   1) The row to be updated is locked and selected into the record
--      structure g_old_rec.
--   2) Because on update parameters which are not part of the update do not
--      have to be defaulted, we need to build up the updated row by
--      converting any system defaulted parameters to their corresponding
--      value.
--   3) The controlling validation process update_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   4) The pre_update process is then executed which enables any
--      logic to be processed before the update dml process is executed.
--   5) The update_dml process will physical perform the update dml into the
--      specified entity.
--   6) The post_update process is then executed which enables any
--      logic to be processed after the update dml process.
--
-- Prerequisites:
--   The main parameters to the business process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   The specified row will be fully validated and updated for the specified
--   entity without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy ben_ecr_shd.g_rec_type,
  p_effective_date               in date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the update
--   process for the specified entity and is the outermost layer. The role
--   of this process is to update a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes). The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record upd
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be updated for the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be supplied with the work
--   rolled back.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure upd
  (
    p_effective_date              in  date,
  	p_enrt_rt_id                  in  NUMBER,
  	p_ordr_num		      in number  default hr_api.g_number,
  	p_acty_typ_cd                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_tx_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ctfn_rqd_flag               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_flag                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_pndg_ctfn_flag         in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dsply_on_enrt_flag          in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_use_to_calc_net_flx_cr_flag in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_entr_val_at_enrt_flag       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_asn_on_enrt_flag            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rl_crs_only_flag            in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dflt_val                    in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_val                     in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_mn_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_ann_mx_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_val                         in  NUMBER    DEFAULT hr_api.g_number,
  	p_nnmntry_uom                 in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_mx_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  	p_mn_elcn_val                 in  NUMBER    DEFAULT hr_api.g_number,
  	p_incrmt_elcn_val             in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_acty_ref_perd_cd       in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_cmcd_mn_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_mx_elcn_val            in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_val                    in  NUMBER    DEFAULT hr_api.g_number,
  	p_cmcd_dflt_val               in  NUMBER    DEFAULT hr_api.g_number,
  	p_rt_usg_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ann_dflt_val                in  NUMBER    DEFAULT hr_api.g_number,
  	p_bnft_rt_typ_cd              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_mlt_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_dsply_mn_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  	p_dsply_mx_elcn_val           in  NUMBER    DEFAULT hr_api.g_number,
  	p_entr_ann_val_flag           in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_strt_dt                  in  DATE      DEFAULT hr_api.g_date,
  	p_rt_strt_dt_cd               in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_rt_strt_dt_rl               in  NUMBER    DEFAULT hr_api.g_number,
  	p_rt_typ_cd                   in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_elig_per_elctbl_chc_id      in  NUMBER    DEFAULT hr_api.g_number,
  	p_acty_base_rt_id             in  NUMBER    DEFAULT hr_api.g_number,
  	p_spcl_rt_enrt_rt_id          in  NUMBER    DEFAULT hr_api.g_number,
  	p_enrt_bnft_id                in  NUMBER    DEFAULT hr_api.g_number,
  	p_prtt_rt_val_id              in  NUMBER    DEFAULT hr_api.g_number,
  	p_decr_bnft_prvdr_pool_id     in  NUMBER    DEFAULT hr_api.g_number,
  	p_cvg_amt_calc_mthd_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_actl_prem_id                in  NUMBER    DEFAULT hr_api.g_number,
  	p_comp_lvl_fctr_id            in  NUMBER    DEFAULT hr_api.g_number,
  	p_ptd_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_clm_comp_lvl_fctr_id        in  NUMBER    DEFAULT hr_api.g_number,
  	p_business_group_id           in  NUMBER    DEFAULT hr_api.g_number,
        --cwb
        p_iss_val                     in  number    DEFAULT hr_api.g_number,
        p_val_last_upd_date           in  date      DEFAULT hr_api.g_date,
        p_val_last_upd_person_id      in  number    DEFAULT hr_api.g_number,
        --cwb
        p_pp_in_yr_used_num           in  number    default hr_api.g_number,
  	p_ecr_attribute_category      in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute1              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute2              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute3              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute4              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute5              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute6              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute7              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute8              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute9              in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute10             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute11             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute12             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute13             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute14             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute15             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute16             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute17             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute18             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute19             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute20             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute21             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
  	p_ecr_attribute22             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute23             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute24             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute25             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute26             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute27             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute28             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute29             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_ecr_attribute30             in  VARCHAR2  DEFAULT hr_api.g_varchar2,
    p_last_update_login           in  NUMBER    DEFAULT hr_api.g_number,
    p_created_by                  in  NUMBER    DEFAULT hr_api.g_number,
    p_creation_date               in  DATE      DEFAULT hr_api.g_date,
    p_last_updated_by             in  NUMBER    DEFAULT hr_api.g_number,
    p_last_update_date            in  DATE      DEFAULT hr_api.g_date,
    p_request_id                  in  NUMBER    DEFAULT hr_api.g_number,
    p_program_application_id      in  NUMBER    DEFAULT hr_api.g_number,
    p_program_id                  in  NUMBER    DEFAULT hr_api.g_number,
    p_program_update_date         in  DATE      DEFAULT hr_api.g_date,
    p_object_version_number       in out nocopy NUMBER
  );
--
end ben_ecr_upd;

 

/
