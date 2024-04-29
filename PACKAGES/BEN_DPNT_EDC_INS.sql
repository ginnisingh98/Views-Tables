--------------------------------------------------------
--  DDL for Package BEN_DPNT_EDC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_EDC_INS" AUTHID CURRENT_USER AS
/* $Header: beedvrhi.pkh 120.0.12010000.1 2010/04/09 06:34:15 pvelvano noship $ */
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
	(p_rec 			 in out nocopy ben_dpnt_edc_shd.g_rec_type,
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
  p_rec		   in out nocopy ben_dpnt_edc_shd.g_rec_type,
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
   p_dpnt_eligy_crit_values_id         Out nocopy Number
  ,p_dpnt_cvg_eligy_prfl_id          In      Number  default NULL
  ,p_eligy_criteria_dpnt_id            In  Number       default NULL
  ,p_effective_start_date         Out nocopy Date
  ,p_effective_end_date           Out nocopy Date
  ,p_ordr_num                     In  Number       default NULL
  ,p_number_value1                In  Number       default NULL
  ,p_number_value2                In  Number       default NULL
  ,p_char_value1                  In  Varchar2     default NULL
  ,p_char_value2                  In  Varchar2     default NULL
  ,p_date_value1                  In  Date         default NULL
  ,p_date_value2                  In  Date         default NULL
  ,p_excld_flag                   In  Varchar2     default 'N'
  ,p_business_group_id            In  Number       default NULL
  ,p_edc_attribute_category       In  Varchar2     default NULL
  ,p_edc_attribute1               In  Varchar2     default NULL
  ,p_edc_attribute2               In  Varchar2     default NULL
  ,p_edc_attribute3               In  Varchar2     default NULL
  ,p_edc_attribute4               In  Varchar2     default NULL
  ,p_edc_attribute5               In  Varchar2     default NULL
  ,p_edc_attribute6               In  Varchar2     default NULL
  ,p_edc_attribute7               In  Varchar2     default NULL
  ,p_edc_attribute8               In  Varchar2     default NULL
  ,p_edc_attribute9               In  Varchar2     default NULL
  ,p_edc_attribute10              In  Varchar2     default NULL
  ,p_edc_attribute11              In  Varchar2     default NULL
  ,p_edc_attribute12              In  Varchar2     default NULL
  ,p_edc_attribute13              In  Varchar2     default NULL
  ,p_edc_attribute14              In  Varchar2     default NULL
  ,p_edc_attribute15              In  Varchar2     default NULL
  ,p_edc_attribute16              In  Varchar2     default NULL
  ,p_edc_attribute17              In  Varchar2     default NULL
  ,p_edc_attribute18              In  Varchar2     default NULL
  ,p_edc_attribute19              In  Varchar2     default NULL
  ,p_edc_attribute20              In  Varchar2     default NULL
  ,p_edc_attribute21              In  Varchar2     default NULL
  ,p_edc_attribute22              In  Varchar2     default NULL
  ,p_edc_attribute23              In  Varchar2     default NULL
  ,p_edc_attribute24              In  Varchar2     default NULL
  ,p_edc_attribute25              In  Varchar2     default NULL
  ,p_edc_attribute26              In  Varchar2     default NULL
  ,p_edc_attribute27              In  Varchar2     default NULL
  ,p_edc_attribute28              In  Varchar2     default NULL
  ,p_edc_attribute29              In  Varchar2     default NULL
  ,p_edc_attribute30              In  Varchar2     default NULL
  ,p_object_version_number        Out nocopy Number
  ,p_effective_date               In  Date
  ,p_Char_value3                  In  Varchar2     default NULL
  ,p_Char_value4                  In  Varchar2     default NULL
  ,p_Number_value3                In  Number	   default NULL
  ,p_Number_value4                In  Number	   default NULL
  ,p_Date_value3                  In  Date	   default NULL
  ,p_Date_value4                  In  Date	   default NULL
  );
--
end ben_dpnt_edc_ins;

/
