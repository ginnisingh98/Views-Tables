--------------------------------------------------------
--  DDL for Package BEN_CTP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CTP_INS" AUTHID CURRENT_USER as
/* $Header: bectprhi.pkh 120.0 2005/05/28 01:26:21 appldev noship $ */

--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_insert_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within the dt_insert_dml
--   procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
	(p_rec 			 in out nocopy ben_ctp_shd.g_rec_type,
	 p_effective_date	 in	date,
	 p_datetrack_mode	 in	varchar2,
	 p_validation_start_date in	date,
	 p_validation_end_date	 in	date);
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
--   attributes). This process is the main backbone of the ins business
--   process. The processing of this procedure is as follows:
--   1) We must lock parent rows (if any exist).
--   2) The controlling validation process insert_validate is then executed
--      which will execute all private and public validation business rule
--      processes.
--   3) The pre_insert process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   4) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   5) The post_insert process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the process have to be in the record
--   format.
--
-- In Parameters:
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
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
  p_rec		   in out nocopy ben_ctp_shd.g_rec_type,
  p_effective_date in     date
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
--   (e.g. object version number attributes). The processing of this
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
--   p_effective_date
--    Specifies the date of the datetrack insert operation.
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
  p_ptip_id                      out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_coord_cvg_for_all_pls_flag   in varchar2         default 'N',
  p_dpnt_dsgn_cd                 in varchar2         default null,
  p_dpnt_cvg_no_ctfn_rqd_flag    in varchar2         default 'N',
  p_dpnt_cvg_strt_dt_cd          in varchar2         default null,
  p_rt_end_dt_cd                 in varchar2         default null,
  p_rt_strt_dt_cd                in varchar2         default null,
  p_enrt_cvg_end_dt_cd           in varchar2         default null,
  p_enrt_cvg_strt_dt_cd          in varchar2         default null,
  p_dpnt_cvg_strt_dt_rl          in number           default null,
  p_dpnt_cvg_end_dt_cd           in varchar2         default null,
  p_dpnt_cvg_end_dt_rl           in number           default null,
  p_dpnt_adrs_rqd_flag           in varchar2         default 'N',
  p_dpnt_legv_id_rqd_flag        in varchar2         default 'N',
  p_susp_if_dpnt_ssn_nt_prv_cd      in  varchar2   default null,
  p_susp_if_dpnt_dob_nt_prv_cd      in  varchar2   default null,
  p_susp_if_dpnt_adr_nt_prv_cd      in  varchar2   default null,
  p_susp_if_ctfn_not_dpnt_flag      in  varchar2   default 'Y',
  p_dpnt_ctfn_determine_cd          in  varchar2   default null,
  p_postelcn_edit_rl             in number           default null,
  p_rt_end_dt_rl                 in number           default null,
  p_rt_strt_dt_rl                in number           default null,
  p_enrt_cvg_end_dt_rl           in number           default null,
  p_enrt_cvg_strt_dt_rl          in number           default null,
  p_rqd_perd_enrt_nenrt_rl       in number           default null,
  p_auto_enrt_mthd_rl            in  number          default null,
  p_enrt_mthd_cd                 in  varchar2        default null,
  p_enrt_cd                      in  varchar2        default null,
  p_enrt_rl                      in  number          default null,
  p_dflt_enrt_cd                 in  varchar2        default null,
  p_dflt_enrt_det_rl             in  number          default null,
  p_drvbl_fctr_apls_rts_flag     in varchar2         default 'N',
  p_drvbl_fctr_prtn_elig_flag    in varchar2         default 'N',
  p_elig_apls_flag               in varchar2         default 'N',
  p_prtn_elig_ovrid_alwd_flag    in varchar2         default 'N',
  p_trk_inelig_per_flag          in varchar2         default 'N',
  p_dpnt_dob_rqd_flag            in varchar2         default 'N',
  p_crs_this_pl_typ_only_flag    in varchar2         default 'N',
  p_ptip_stat_cd                 in varchar2         default null,
  p_mx_cvg_alwd_amt              in number           default null,
  p_mx_enrd_alwd_ovrid_num       in number           default null,
  p_mn_enrd_rqd_ovrid_num        in number           default null,
  p_no_mx_pl_typ_ovrid_flag      in varchar2         default 'N',
  p_ordr_num                     in number           default null,
  p_prvds_cr_flag                in varchar2         default 'N',
  p_rqd_perd_enrt_nenrt_val      in number           default null,
  p_rqd_perd_enrt_nenrt_tm_uom   in varchar2         default null,
  p_wvbl_flag                    in varchar2         default 'N',
  p_drvd_fctr_dpnt_cvg_flag      in varchar2         default 'N',
  p_no_mn_pl_typ_overid_flag     in varchar2         default 'N',
  p_sbj_to_sps_lf_ins_mx_flag    in varchar2         default 'N',
  p_sbj_to_dpnt_lf_ins_mx_flag   in varchar2         default 'N',
  p_use_to_sum_ee_lf_ins_flag    in varchar2         default 'N',
  p_per_cvrd_cd                  in varchar2         default null,
  p_short_name                  in varchar2         default null,
  p_short_code                  in varchar2         default null,
    p_legislation_code                  in varchar2         default null,
    p_legislation_subgroup                  in varchar2         default null,
  p_vrfy_fmly_mmbr_cd            in varchar2         default null,
  p_vrfy_fmly_mmbr_rl            in number           default null,
  p_ivr_ident                    in varchar2         default null,
  p_url_ref_name                 in varchar2         default null,
  p_rqd_enrt_perd_tco_cd         in varchar2         default null,
  p_pgm_id                       in number           default null,
  p_pl_typ_id                    in number,
  p_cmbn_ptip_id                 in number           default null,
  p_cmbn_ptip_opt_id             in number           default null,
  p_acrs_ptip_cvg_id             in number           default null,
  p_business_group_id            in number,
  p_ctp_attribute_category       in varchar2         default null,
  p_ctp_attribute1               in varchar2         default null,
  p_ctp_attribute2               in varchar2         default null,
  p_ctp_attribute3               in varchar2         default null,
  p_ctp_attribute4               in varchar2         default null,
  p_ctp_attribute5               in varchar2         default null,
  p_ctp_attribute6               in varchar2         default null,
  p_ctp_attribute7               in varchar2         default null,
  p_ctp_attribute8               in varchar2         default null,
  p_ctp_attribute9               in varchar2         default null,
  p_ctp_attribute10              in varchar2         default null,
  p_ctp_attribute11              in varchar2         default null,
  p_ctp_attribute12              in varchar2         default null,
  p_ctp_attribute13              in varchar2         default null,
  p_ctp_attribute14              in varchar2         default null,
  p_ctp_attribute15              in varchar2         default null,
  p_ctp_attribute16              in varchar2         default null,
  p_ctp_attribute17              in varchar2         default null,
  p_ctp_attribute18              in varchar2         default null,
  p_ctp_attribute19              in varchar2         default null,
  p_ctp_attribute20              in varchar2         default null,
  p_ctp_attribute21              in varchar2         default null,
  p_ctp_attribute22              in varchar2         default null,
  p_ctp_attribute23              in varchar2         default null,
  p_ctp_attribute24              in varchar2         default null,
  p_ctp_attribute25              in varchar2         default null,
  p_ctp_attribute26              in varchar2         default null,
  p_ctp_attribute27              in varchar2         default null,
  p_ctp_attribute28              in varchar2         default null,
  p_ctp_attribute29              in varchar2         default null,
  p_ctp_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date
  );
--
end ben_ctp_ins;

 

/
