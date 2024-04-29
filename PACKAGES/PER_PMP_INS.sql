--------------------------------------------------------
--  DDL for Package PER_PMP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PMP_INS" AUTHID CURRENT_USER as
/* $Header: pepmprhi.pkh 120.2.12010000.3 2010/01/27 15:49:21 rsykam ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--   This procedure is called to register the next ID value from the database
--   sequence.
--
-- Prerequisites:
--
-- In Parameters:
--   Primary Key
--
-- Post Success:
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_plan_id  in  number);
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
--   If an error has occurred, an error message will be raised.
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
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_pmp_shd.g_rec_type
  ,p_duplicate_name_warning       out nocopy boolean
  ,p_no_life_events_warning       out nocopy boolean
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
--   If an error has occurred, an error message will be raised.
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
  (p_effective_date                 in     date
  ,p_plan_name                      in     varchar2
  ,p_administrator_person_id        in     number
  ,p_previous_plan_id               in     number   default null
  ,p_start_date                     in     date
  ,p_end_date                       in     date
  ,p_automatic_enrollment_flag      in     varchar2
  ,p_assignment_types_code          in     varchar2
  ,p_primary_asg_only_flag          in     varchar2
  ,p_include_obj_setting_flag       in     varchar2
  ,p_obj_set_outside_period_flag    in     varchar2
  ,p_method_code                    in     varchar2
  ,p_notify_population_flag         in     varchar2
  ,p_automatic_allocation_flag      in     varchar2
  ,p_copy_past_objectives_flag      in     varchar2
  ,p_sharing_alignment_task_flag    in     varchar2
  ,p_include_appraisals_flag        in     varchar2
  ,p_hierarchy_type_code            in     varchar2 default null
  ,p_supervisor_id                  in     number   default null
  ,p_supervisor_assignment_id       in     number   default null
  ,p_organization_structure_id      in     number   default null
  ,p_org_structure_version_id       in     number   default null
  ,p_top_organization_id            in     number   default null
  ,p_position_structure_id          in     number   default null
  ,p_pos_structure_version_id       in     number   default null
  ,p_top_position_id                in     number   default null
  ,p_hierarchy_levels               in     number   default null
  ,p_obj_setting_start_date         in     date     default null
  ,p_obj_setting_deadline           in     date     default null
  ,p_change_sc_status_flag   in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_plan_id                           out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_status_code                       out nocopy varchar2
  ,p_duplicate_name_warning            out nocopy boolean
  ,p_no_life_events_warning            out nocopy boolean
  ,p_update_library_objectives in varchar2  default null    -- 8740021 bug fix
  ,p_automatic_approval_flag in varchar2  default null
  );
--
end per_pmp_ins;

/
