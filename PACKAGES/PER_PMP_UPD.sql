--------------------------------------------------------
--  DDL for Package PER_PMP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PMP_UPD" AUTHID CURRENT_USER as
/* $Header: pepmprhi.pkh 120.2.12010000.3 2010/01/27 15:49:21 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< upd >---------------------------------|
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
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy per_pmp_shd.g_rec_type
  ,p_duplicate_name_warning       out nocopy boolean
  ,p_no_life_events_warning       out nocopy boolean
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
Procedure upd
  (p_effective_date               in     date
  ,p_plan_id                      in     number
  ,p_object_version_number        in out nocopy number
  ,p_plan_name                    in     varchar2  default hr_api.g_varchar2
  ,p_administrator_person_id      in     number    default hr_api.g_number
  ,p_previous_plan_id             in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_automatic_enrollment_flag    in     varchar2  default hr_api.g_varchar2
  ,p_assignment_types_code        in     varchar2  default hr_api.g_varchar2
  ,p_primary_asg_only_flag        in     varchar2  default hr_api.g_varchar2
  ,p_include_obj_setting_flag     in     varchar2  default hr_api.g_varchar2
  ,p_obj_set_outside_period_flag  in     varchar2  default hr_api.g_varchar2
  ,p_method_code                  in     varchar2  default hr_api.g_varchar2
  ,p_notify_population_flag       in     varchar2  default hr_api.g_varchar2
  ,p_automatic_allocation_flag    in     varchar2  default hr_api.g_varchar2
  ,p_copy_past_objectives_flag    in     varchar2  default hr_api.g_varchar2
  ,p_sharing_alignment_task_flag  in     varchar2  default hr_api.g_varchar2
  ,p_include_appraisals_flag      in     varchar2  default hr_api.g_varchar2
  ,p_hierarchy_type_code          in     varchar2  default hr_api.g_varchar2
  ,p_supervisor_id                in     number    default hr_api.g_number
  ,p_supervisor_assignment_id     in     number    default hr_api.g_number
  ,p_organization_structure_id    in     number    default hr_api.g_number
  ,p_org_structure_version_id     in     number    default hr_api.g_number
  ,p_top_organization_id          in     number    default hr_api.g_number
  ,p_position_structure_id        in     number    default hr_api.g_number
  ,p_pos_structure_version_id     in     number    default hr_api.g_number
  ,p_top_position_id              in     number    default hr_api.g_number
  ,p_hierarchy_levels             in     number    default hr_api.g_number
  ,p_obj_setting_start_date       in     date      default hr_api.g_date
  ,p_obj_setting_deadline         in     date      default hr_api.g_date
  ,p_change_sc_status_flag in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_status_code                  in out nocopy varchar2
  ,p_duplicate_name_warning          out nocopy boolean
  ,p_no_life_events_warning          out nocopy boolean
  ,p_update_library_objectives in varchar2  default hr_api.g_varchar2     -- 8740021 bug fix
  ,p_automatic_approval_flag in varchar2  default hr_api.g_varchar2
  );
--
end per_pmp_upd;

/
