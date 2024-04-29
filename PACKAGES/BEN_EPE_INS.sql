--------------------------------------------------------
--  DDL for Package BEN_EPE_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPE_INS" AUTHID CURRENT_USER as
/* $Header: beeperhi.pkh 120.0 2005/05/28 02:37:08 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) The controlling validation process insert_validate is executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   3) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   4) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
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
Procedure ins
  (
  p_effective_date               in date,
  p_rec        in out nocopy ben_epe_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
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
Procedure ins
  (
  p_effective_date               in date,
  p_elig_per_elctbl_chc_id       out nocopy number,
--  p_enrt_typ_cycl_cd             in varchar2         default null,
  p_enrt_cvg_strt_dt_cd          in varchar2         default null,
--  p_enrt_perd_end_dt             in date             default null,
--  p_enrt_perd_strt_dt            in date             default null,
  p_enrt_cvg_strt_dt_rl          in varchar2         default null,
--  p_rt_strt_dt                   in date             default null,
--  p_rt_strt_dt_rl                in varchar2         default null,
--  p_rt_strt_dt_cd                in varchar2         default null,
  p_ctfn_rqd_flag                in varchar2,
  p_pil_elctbl_chc_popl_id       in number,
  p_roll_crs_flag                in varchar2         default null,
  p_crntly_enrd_flag             in varchar2,
  p_dflt_flag                    in varchar2,
  p_elctbl_flag                  in varchar2,
  p_mndtry_flag                  in varchar2,
  p_in_pndg_wkflow_flag          in varchar2           default 'N',
--  p_dflt_enrt_dt                 in date             default null,
  p_dpnt_cvg_strt_dt_cd          in varchar2         default null,
  p_dpnt_cvg_strt_dt_rl          in varchar2         default null,
  p_enrt_cvg_strt_dt             in date             default null,
  p_alws_dpnt_dsgn_flag          in varchar2,
  p_dpnt_dsgn_cd                 in varchar2         default null,
  p_ler_chg_dpnt_cvg_cd          in varchar2         default null,
  p_erlst_deenrt_dt              in date             default null,
  p_procg_end_dt                 in date             default null,
  p_comp_lvl_cd                  in varchar2         default null,
  p_pl_id                        in number,
  p_oipl_id                      in number           default null,
  p_pgm_id                       in number           default null,
  p_plip_id                      in number           default null,
  p_ptip_id                      in number           default null,
  p_pl_typ_id                    in number           default null,
  p_oiplip_id                    in number           default null,
  p_cmbn_plip_id                 in number           default null,
  p_cmbn_ptip_id                 in number           default null,
  p_cmbn_ptip_opt_id             in number           default null,
  p_assignment_id                in number           default null,
  p_spcl_rt_pl_id                in number,
  p_spcl_rt_oipl_id              in number,
  p_must_enrl_anthr_pl_id        in number,
  p_int_elig_per_elctbl_chc_id        in number,
  p_prtt_enrt_rslt_id            in number           default null,
  p_bnft_prvdr_pool_id           in number,
  p_per_in_ler_id                in number,
  p_yr_perd_id                   in number           default null,
  p_auto_enrt_flag               in varchar2         default null,
  p_business_group_id            in number,
  p_pl_ordr_num                  in number           default null,
  p_plip_ordr_num                  in number           default null,
  p_ptip_ordr_num                  in number           default null,
  p_oipl_ordr_num                  in number           default null,
  -- cwb
  p_comments                        in  varchar2       default null,
  p_elig_flag                       in  varchar2       default null,
  p_elig_ovrid_dt                   in  date       default null,
  p_elig_ovrid_person_id            in  number       default null,
  p_inelig_rsn_cd                   in  varchar2       default null,
  p_mgr_ovrid_dt                    in  date       default null,
  p_mgr_ovrid_person_id             in  number       default null,
  p_ws_mgr_id                       in  number       default null,
  -- cwb
  p_epe_attribute_category       in varchar2         default null,
  p_epe_attribute1               in varchar2         default null,
  p_epe_attribute2               in varchar2         default null,
  p_epe_attribute3               in varchar2         default null,
  p_epe_attribute4               in varchar2         default null,
  p_epe_attribute5               in varchar2         default null,
  p_epe_attribute6               in varchar2         default null,
  p_epe_attribute7               in varchar2         default null,
  p_epe_attribute8               in varchar2         default null,
  p_epe_attribute9               in varchar2         default null,
  p_epe_attribute10              in varchar2         default null,
  p_epe_attribute11              in varchar2         default null,
  p_epe_attribute12              in varchar2         default null,
  p_epe_attribute13              in varchar2         default null,
  p_epe_attribute14              in varchar2         default null,
  p_epe_attribute15              in varchar2         default null,
  p_epe_attribute16              in varchar2         default null,
  p_epe_attribute17              in varchar2         default null,
  p_epe_attribute18              in varchar2         default null,
  p_epe_attribute19              in varchar2         default null,
  p_epe_attribute20              in varchar2         default null,
  p_epe_attribute21              in varchar2         default null,
  p_epe_attribute22              in varchar2         default null,
  p_epe_attribute23              in varchar2         default null,
  p_epe_attribute24              in varchar2         default null,
  p_epe_attribute25              in varchar2         default null,
  p_epe_attribute26              in varchar2         default null,
  p_epe_attribute27              in varchar2         default null,
  p_epe_attribute28              in varchar2         default null,
  p_epe_attribute29              in varchar2         default null,
  p_epe_attribute30              in varchar2         default null,
  p_approval_status_cd           in varchar2         default null,
  p_fonm_cvg_strt_dt             in date             default null,
  p_cryfwd_elig_dpnt_cd          in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number
  );
--
end ben_epe_ins;

 

/
