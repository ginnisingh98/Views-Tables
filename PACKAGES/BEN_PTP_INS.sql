--------------------------------------------------------
--  DDL for Package BEN_PTP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PTP_INS" AUTHID CURRENT_USER as
/* $Header: beptprhi.pkh 120.0 2005/05/28 11:22:42 appldev noship $ */

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
	(p_rec 			 in out nocopy ben_ptp_shd.g_rec_type,
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
  p_rec		   in out nocopy ben_ptp_shd.g_rec_type,
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
  p_pl_typ_id                    out nocopy number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_name                         in varchar2,
  p_mx_enrl_alwd_num             in number           default null,
  p_mn_enrl_rqd_num              in number           default null,
  p_pl_typ_stat_cd               in varchar2         default null,
  p_opt_typ_cd                   in varchar2         default null,
  p_opt_dsply_fmt_cd             in varchar2         default null,
  p_comp_typ_cd                  in varchar2         default null,
  p_ivr_ident                    in varchar2         default null,
  p_no_mx_enrl_num_dfnd_flag     in varchar2         default null,
  p_no_mn_enrl_num_dfnd_flag     in varchar2         default null,
  p_business_group_id            in number           default null,
  p_ptp_attribute_category       in varchar2         default null,
  p_ptp_attribute1               in varchar2         default null,
  p_ptp_attribute2               in varchar2         default null,
  p_ptp_attribute3               in varchar2         default null,
  p_ptp_attribute4               in varchar2         default null,
  p_ptp_attribute5               in varchar2         default null,
  p_ptp_attribute6               in varchar2         default null,
  p_ptp_attribute7               in varchar2         default null,
  p_ptp_attribute8               in varchar2         default null,
  p_ptp_attribute9               in varchar2         default null,
  p_ptp_attribute10              in varchar2         default null,
  p_ptp_attribute11              in varchar2         default null,
  p_ptp_attribute12              in varchar2         default null,
  p_ptp_attribute13              in varchar2         default null,
  p_ptp_attribute14              in varchar2         default null,
  p_ptp_attribute15              in varchar2         default null,
  p_ptp_attribute16              in varchar2         default null,
  p_ptp_attribute17              in varchar2         default null,
  p_ptp_attribute18              in varchar2         default null,
  p_ptp_attribute19              in varchar2         default null,
  p_ptp_attribute20              in varchar2         default null,
  p_ptp_attribute21              in varchar2         default null,
  p_ptp_attribute22              in varchar2         default null,
  p_ptp_attribute23              in varchar2         default null,
  p_ptp_attribute24              in varchar2         default null,
  p_ptp_attribute25              in varchar2         default null,
  p_ptp_attribute26              in varchar2         default null,
  p_ptp_attribute27              in varchar2         default null,
  p_ptp_attribute28              in varchar2         default null,
  p_ptp_attribute29              in varchar2         default null,
  p_ptp_attribute30              in varchar2         default null,
  p_short_name			 in varchar2         default null,		--FHR
  p_short_code			 in varchar2 	     default null,		--FHR
    p_legislation_code			 in varchar2 	     default null,
    p_legislation_subgroup			 in varchar2 	     default null,
  p_object_version_number        out nocopy number,
  p_effective_date		 in date
  );
--
end ben_ptp_ins;

 

/
