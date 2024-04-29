--------------------------------------------------------
--  DDL for Package BEN_BPP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BPP_INS" AUTHID CURRENT_USER as
/* $Header: bebpprhi.pkh 120.0 2005/05/28 00:48:43 appldev noship $ */

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
	(p_rec 			 in out nocopy ben_bpp_shd.g_rec_type,
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
  p_rec		   in out nocopy ben_bpp_shd.g_rec_type,
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
  p_bnft_prvdr_pool_id           out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2,
  p_pgm_pool_flag                in varchar2,
  p_excs_alwys_fftd_flag         in varchar2,
  p_use_for_pgm_pool_flag        in varchar2,
  p_pct_rndg_cd                  in varchar2         default null,
  p_pct_rndg_rl                  in number           default null,
  p_val_rndg_cd                  in varchar2         default null,
  p_val_rndg_rl                  in number           default null,
  p_dflt_excs_trtmt_cd           in varchar2         default null,
  p_dflt_excs_trtmt_rl           in number           default null,
  p_rlovr_rstrcn_cd              in varchar2         default null,
  p_no_mn_dstrbl_pct_flag        in varchar2,
  p_no_mn_dstrbl_val_flag        in varchar2,
  p_no_mx_dstrbl_pct_flag        in varchar2,
  p_no_mx_dstrbl_val_flag        in varchar2,
  p_auto_alct_excs_flag          in varchar2         default 'N',
  p_alws_ngtv_crs_flag           in varchar2         default 'N',
  p_uses_net_crs_mthd_flag       in varchar2         default 'N',
  p_mx_dfcit_pct_pool_crs_num    in number           default null,
  p_mx_dfcit_pct_comp_num        in number           default null,
  p_comp_lvl_fctr_id             in number           default null,
  p_mn_dstrbl_pct_num            in number           default null,
  p_mn_dstrbl_val                in number           default null,
  p_mx_dstrbl_pct_num            in number           default null,
  p_mx_dstrbl_val                in number           default null,
  p_excs_trtmt_cd                in varchar2         default null,
  p_ptip_id                      in number           default null,
  p_plip_id                      in number           default null,
  p_pgm_id                       in number,
  p_oiplip_id                    in number           default null,
  p_cmbn_plip_id                 in number           default null,
  p_cmbn_ptip_id                 in number           default null,
  p_cmbn_ptip_opt_id             in number           default null,
  p_business_group_id            in number,
  p_bpp_attribute_category       in varchar2         default null,
  p_bpp_attribute1               in varchar2         default null,
  p_bpp_attribute2               in varchar2         default null,
  p_bpp_attribute3               in varchar2         default null,
  p_bpp_attribute4               in varchar2         default null,
  p_bpp_attribute5               in varchar2         default null,
  p_bpp_attribute6               in varchar2         default null,
  p_bpp_attribute7               in varchar2         default null,
  p_bpp_attribute8               in varchar2         default null,
  p_bpp_attribute9               in varchar2         default null,
  p_bpp_attribute10              in varchar2         default null,
  p_bpp_attribute11              in varchar2         default null,
  p_bpp_attribute12              in varchar2         default null,
  p_bpp_attribute13              in varchar2         default null,
  p_bpp_attribute14              in varchar2         default null,
  p_bpp_attribute15              in varchar2         default null,
  p_bpp_attribute16              in varchar2         default null,
  p_bpp_attribute17              in varchar2         default null,
  p_bpp_attribute18              in varchar2         default null,
  p_bpp_attribute19              in varchar2         default null,
  p_bpp_attribute20              in varchar2         default null,
  p_bpp_attribute21              in varchar2         default null,
  p_bpp_attribute22              in varchar2         default null,
  p_bpp_attribute23              in varchar2         default null,
  p_bpp_attribute24              in varchar2         default null,
  p_bpp_attribute25              in varchar2         default null,
  p_bpp_attribute26              in varchar2         default null,
  p_bpp_attribute27              in varchar2         default null,
  p_bpp_attribute28              in varchar2         default null,
  p_bpp_attribute29              in varchar2         default null,
  p_bpp_attribute30              in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date
  );
--
end ben_bpp_ins;

 

/
