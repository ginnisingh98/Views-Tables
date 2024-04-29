--------------------------------------------------------
--  DDL for Package PER_ABS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABS_UPD" AUTHID CURRENT_USER as
/* $Header: peabsrhi.pkh 120.3.12010000.3 2009/12/22 10:04:55 ghshanka ship $ */
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
-- Out Parameters:
--   p_dur_dys_less_warning  - true, when HR_EMP_ABS_SHORT_DURATION warning
--                             is raised.
--   p_dur_hrs_less_warning  - true, when HR_ABS_HOUR_LESS_DURATION warning
--                             is raised.
--   p_exceeds_pto_entit_warning - true, when HR_EMP_NOT_ENTITLED warning
--                             is raised.
--   p_exceeds_run_total_warning - true, when HR_ABS_DET_RUNNING_ZERO warning
--                             is raised.
--   p_abs_overlap_warning   - true, when HR_ABS_DET_OVERLAP warning is
--                             raised.
--   p_abs_day_after_warning - true, when HR_ABS_DET_ABS_DAY_AFTER warning
--                             is raised.
--   p_dur_overwritten_warning true, when the absence durations have been
--                             overwritten by the Fast Formula values.
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
  (p_effective_date               in     date
  ,p_rec                          in out nocopy per_abs_shd.g_rec_type
  ,p_dur_dys_less_warning         out nocopy    boolean
  ,p_dur_hrs_less_warning         out nocopy    boolean
  ,p_exceeds_pto_entit_warning    out nocopy    boolean
  ,p_exceeds_run_total_warning    out nocopy    boolean
  ,p_abs_overlap_warning          out nocopy    boolean
  ,p_abs_day_after_warning        out nocopy    boolean
  ,p_dur_overwritten_warning      out nocopy    boolean
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
-- Out Parameters:
--   p_dur_dys_less_warning  - true, when HR_EMP_ABS_SHORT_DURATION warning
--                             is raised.
--   p_dur_hrs_less_warning  - true, when HR_ABS_HOUR_LESS_DURATION warning
--                             is raised.
--   p_exceeds_pto_entit_warning - true, when HR_EMP_NOT_ENTITLED warning
--                             is raised.
--   p_exceeds_run_total_warning - true, when HR_ABS_DET_RUNNING_ZERO warning
--                             is raised.
--   p_abs_overlap_warning   - true, when HR_ABS_DET_OVERLAP warning is
--                             raised.
--   p_abs_day_after_warning - true, when HR_ABS_DET_ABS_DAY_AFTER warning
--                             is raised.
--   p_dur_overwritten_warning true, when the absence durations have been
--                             overwritten by the Fast Formula values.
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
  ,p_absence_attendance_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_abs_attendance_reason_id     in     number    default hr_api.g_number
  ,p_authorising_person_id        in     number    default hr_api.g_number
  ,p_replacement_person_id        in     number    default hr_api.g_number
  ,p_period_of_incapacity_id      in     number    default hr_api.g_number
  ,p_absence_days                 in out nocopy number
  ,p_absence_hours                in out nocopy number
  --start changes for bug 5987410
  --,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     long  default null
  --end changes for bug 5987410
  ,p_date_notification            in     date      default hr_api.g_date
  ,p_date_start                   in     date      default hr_api.g_date
  ,p_date_end                     in     date      default hr_api.g_date
  ,p_date_projected_start         in     date      default hr_api.g_date
  ,p_date_projected_end           in     date      default hr_api.g_date
  ,p_time_start                   in     varchar2  default hr_api.g_varchar2
  ,p_time_end                     in     varchar2  default hr_api.g_varchar2
  ,p_time_projected_start         in     varchar2  default hr_api.g_varchar2
  ,p_time_projected_end           in     varchar2  default hr_api.g_varchar2
  ,p_occurrence                   in     number    default hr_api.g_number
  ,p_ssp1_issued                  in     varchar2  default hr_api.g_varchar2
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
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
  ,p_maternity_id                 in     number    default hr_api.g_number
  ,p_sickness_start_date          in     date      default hr_api.g_date
  ,p_sickness_end_date            in     date      default hr_api.g_date
  ,p_pregnancy_related_illness    in     varchar2  default hr_api.g_varchar2
  ,p_reason_for_notification_dela in     varchar2  default hr_api.g_varchar2
  ,p_accept_late_notification_fla in     varchar2  default hr_api.g_varchar2
  ,p_linked_absence_id            in     number    default hr_api.g_number
  ,p_abs_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_abs_information1             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information2             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information3             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information4             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information5             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information6             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information7             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information8             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information9             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information10            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information11            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information12            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information13            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information14            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information15            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information16            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information17            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information18            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information19            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information20            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information21            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information22            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information23            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information24            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information25            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information26            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information27            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information28            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information29            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information30            in     varchar2  default hr_api.g_varchar2
  ,p_batch_id                     in     number    default hr_api.g_number
  ,p_absence_case_id              in     number    default hr_api.g_number
  ,p_dur_dys_less_warning         out nocopy    boolean
  ,p_dur_hrs_less_warning         out nocopy    boolean
  ,p_exceeds_pto_entit_warning    out nocopy    boolean
  ,p_exceeds_run_total_warning    out nocopy    boolean
  ,p_abs_overlap_warning          out nocopy    boolean
  ,p_abs_day_after_warning        out nocopy    boolean
  ,p_dur_overwritten_warning      out nocopy    boolean
  );
--
end per_abs_upd;

/
