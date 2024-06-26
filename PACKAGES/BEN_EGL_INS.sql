--------------------------------------------------------
--  DDL for Package BEN_EGL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EGL_INS" as


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
  p_rec        in out nocopy ben_egl_shd.g_rec_type
  ,p_effective_date                 in  date
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
     p_eligy_criteria_id              out nocopy number
    ,p_name                           in  varchar2     default null
    ,p_short_code                     in  varchar2     default null
    ,p_description                    in  varchar2     default null
    ,p_criteria_type		      in  varchar2     default null
    ,p_crit_col1_val_type_cd	      in  varchar2     default null
    ,p_crit_col1_datatype	      in  varchar2     default null
    ,p_col1_lookup_type		      in  varchar2     default null
    ,p_col1_value_set_id              in  number       default null
    ,p_access_table_name1             in  varchar2     default null
    ,p_access_column_name1	      in  varchar2     default null
    ,p_time_entry_access_tab_nam1     in  varchar2     default null
    ,p_time_entry_access_col_nam1     in  varchar2     default null
    ,p_crit_col2_val_type_cd	      in  varchar2     default null
    ,p_crit_col2_datatype	      in  varchar2     default null
    ,p_col2_lookup_type		      in  varchar2     default null
    ,p_col2_value_set_id              in  number       default null
    ,p_access_table_name2	      in  varchar2     default null
    ,p_access_column_name2	      in  varchar2     default null
    ,p_time_entry_access_tab_nam2     in  varchar2     default null
    ,p_time_entry_access_col_nam2     in  varchar2     default null
    ,p_access_calc_rule		      in  number       default null
    ,p_allow_range_validation_flg     in  varchar2     default null
    ,p_user_defined_flag              in  varchar2     default null
    ,p_business_group_id 	      in  number       default null
    ,p_legislation_code 	      in  varchar2     default null
    ,p_egl_attribute_category         in  varchar2     default null
    ,p_egl_attribute1                 in  varchar2     default null
    ,p_egl_attribute2                 in  varchar2     default null
    ,p_egl_attribute3                 in  varchar2     default null
    ,p_egl_attribute4                 in  varchar2     default null
    ,p_egl_attribute5                 in  varchar2     default null
    ,p_egl_attribute6                 in  varchar2     default null
    ,p_egl_attribute7                 in  varchar2     default null
    ,p_egl_attribute8                 in  varchar2     default null
    ,p_egl_attribute9                 in  varchar2     default null
    ,p_egl_attribute10                in  varchar2     default null
    ,p_egl_attribute11                in  varchar2     default null
    ,p_egl_attribute12                in  varchar2     default null
    ,p_egl_attribute13                in  varchar2     default null
    ,p_egl_attribute14                in  varchar2     default null
    ,p_egl_attribute15                in  varchar2     default null
    ,p_egl_attribute16                in  varchar2     default null
    ,p_egl_attribute17                in  varchar2     default null
    ,p_egl_attribute18                in  varchar2     default null
    ,p_egl_attribute19                in  varchar2     default null
    ,p_egl_attribute20                in  varchar2     default null
    ,p_egl_attribute21                in  varchar2     default null
    ,p_egl_attribute22                in  varchar2     default null
    ,p_egl_attribute23                in  varchar2     default null
    ,p_egl_attribute24                in  varchar2     default null
    ,p_egl_attribute25                in  varchar2     default null
    ,p_egl_attribute26                in  varchar2     default null
    ,p_egl_attribute27                in  varchar2     default null
    ,p_egl_attribute28                in  varchar2     default null
    ,p_egl_attribute29                in  varchar2     default null
    ,p_egl_attribute30                in  varchar2     default null
    ,p_object_version_number          out nocopy number
    ,p_effective_date                 in  date
    ,p_allow_range_validation_flag2   in varchar2      default null
    ,p_access_calc_rule2              in number	       default null
    ,p_time_access_calc_rule1         in number	       default null
    ,p_time_access_calc_rule2         in number	       default null
  );
--
end ben_egl_ins;

 

/
