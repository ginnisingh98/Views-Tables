--------------------------------------------------------
--  DDL for Package BEN_EPE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPE_UPD" AUTHID CURRENT_USER as
/* $Header: beeperhi.pkh 120.0 2005/05/28 02:37:08 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ben_epe_shd.g_rec_type);
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
  p_effective_date               in date,
  p_rec        in out nocopy ben_epe_shd.g_rec_type
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
  p_effective_date               in date,
  p_elig_per_elctbl_chc_id       in number,
--  p_enrt_typ_cycl_cd             in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
--  p_enrt_perd_end_dt             in date             default hr_api.g_date,
--  p_enrt_perd_strt_dt            in date             default hr_api.g_date,
  p_enrt_cvg_strt_dt_rl          in varchar2         default hr_api.g_varchar2,
--  p_rt_strt_dt                   in date             default hr_api.g_date,
--  p_rt_strt_dt_rl                in varchar2         default hr_api.g_varchar2,
--  p_rt_strt_dt_cd                in varchar2         default hr_api.g_varchar2,
  p_ctfn_rqd_flag                in varchar2         default hr_api.g_varchar2,
  p_pil_elctbl_chc_popl_id       in number           default hr_api.g_number,
  p_roll_crs_flag                in varchar2         default hr_api.g_varchar2,
  p_crntly_enrd_flag             in varchar2         default hr_api.g_varchar2,
  p_dflt_flag                    in varchar2         default hr_api.g_varchar2,
  p_elctbl_flag                  in varchar2         default hr_api.g_varchar2,
  p_mndtry_flag                  in varchar2         default hr_api.g_varchar2,
  p_in_pndg_wkflow_flag          in varchar2         default hr_api.g_varchar2,
--  p_dflt_enrt_dt                 in date             default hr_api.g_date,
  p_dpnt_cvg_strt_dt_cd          in varchar2         default hr_api.g_varchar2,
  p_dpnt_cvg_strt_dt_rl          in varchar2         default hr_api.g_varchar2,
  p_enrt_cvg_strt_dt             in date             default hr_api.g_date,
  p_alws_dpnt_dsgn_flag          in varchar2         default hr_api.g_varchar2,
  p_dpnt_dsgn_cd                 in varchar2         default hr_api.g_varchar2,
  p_ler_chg_dpnt_cvg_cd          in varchar2         default hr_api.g_varchar2,
  p_erlst_deenrt_dt              in date             default hr_api.g_date,
  p_procg_end_dt                 in date             default hr_api.g_date,
  p_comp_lvl_cd                  in varchar2         default hr_api.g_varchar2,
  p_pl_id                        in number           default hr_api.g_number,
  p_oipl_id                      in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_plip_id                      in number           default hr_api.g_number,
  p_ptip_id                      in number           default hr_api.g_number,
  p_pl_typ_id                    in number           default hr_api.g_number,
  p_oiplip_id                    in number           default hr_api.g_number,
  p_cmbn_plip_id                 in number           default hr_api.g_number,
  p_cmbn_ptip_id                 in number           default hr_api.g_number,
  p_cmbn_ptip_opt_id             in number           default hr_api.g_number,
  p_assignment_id                in number           default hr_api.g_number,
  p_spcl_rt_pl_id                in number           default hr_api.g_number,
  p_spcl_rt_oipl_id              in number           default hr_api.g_number,
  p_must_enrl_anthr_pl_id        in number           default hr_api.g_number,
  p_int_elig_per_elctbl_chc_id        in number           default hr_api.g_number,
  p_prtt_enrt_rslt_id            in number           default hr_api.g_number,
  p_bnft_prvdr_pool_id           in number           default hr_api.g_number,
  p_per_in_ler_id                in number           default hr_api.g_number,
  p_yr_perd_id                   in number           default hr_api.g_number,
  p_auto_enrt_flag               in varchar2         default hr_api.g_varchar2,
  p_business_group_id            in number           default hr_api.g_number,
  p_pl_ordr_num                  in number           default hr_api.g_number,
  p_plip_ordr_num                  in number           default hr_api.g_number,
  p_ptip_ordr_num                  in number           default hr_api.g_number,
  p_oipl_ordr_num                  in number           default hr_api.g_number,
  -- cwb
  p_comments                        in  varchar2       default hr_api.g_varchar2,
  p_elig_flag                       in  varchar2       default hr_api.g_varchar2,
  p_elig_ovrid_dt                   in  date           default hr_api.g_date,
  p_elig_ovrid_person_id            in  number         default hr_api.g_number,
  p_inelig_rsn_cd                   in  varchar2       default hr_api.g_varchar2,
  p_mgr_ovrid_dt                    in  date           default hr_api.g_date,
  p_mgr_ovrid_person_id             in  number         default hr_api.g_number,
  p_ws_mgr_id                       in  number         default hr_api.g_number,
  -- cwb
  p_epe_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_epe_attribute1               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute2               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute3               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute4               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute5               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute6               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute7               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute8               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute9               in varchar2         default hr_api.g_varchar2,
  p_epe_attribute10              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute11              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute12              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute13              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute14              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute15              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute16              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute17              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute18              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute19              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute20              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute21              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute22              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute23              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute24              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute25              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute26              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute27              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute28              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute29              in varchar2         default hr_api.g_varchar2,
  p_epe_attribute30              in varchar2         default hr_api.g_varchar2,
  p_approval_status_cd           in varchar2         default hr_api.g_varchar2,
  p_fonm_cvg_strt_dt             in date             default hr_api.g_date,
  p_cryfwd_elig_dpnt_cd          in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number
  );
--
end ben_epe_upd;

 

/
