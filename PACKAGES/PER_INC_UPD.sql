--------------------------------------------------------
--  DDL for Package PER_INC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_INC_UPD" AUTHID CURRENT_USER as
/* $Header: peincrhi.pkh 120.0 2005/05/31 10:08:42 appldev noship $ */
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
  ,p_rec                          in out nocopy per_inc_shd.g_rec_type
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
  ,p_incident_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_incident_reference           in     varchar2  default hr_api.g_varchar2
  ,p_incident_type                in     varchar2  default hr_api.g_varchar2
  ,p_incident_date                in     date      default hr_api.g_date
  ,p_at_work_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_related_incident_id          in     number    default hr_api.g_number
  ,p_incident_time                in     varchar2  default hr_api.g_varchar2
  ,p_org_notified_date            in     date      default hr_api.g_date
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_report_date                  in     date      default hr_api.g_date
  ,p_report_time                  in     varchar2  default hr_api.g_varchar2
  ,p_report_method                in     varchar2  default hr_api.g_varchar2
  ,p_person_reported_by           in     number    default hr_api.g_number
  ,p_person_reported_to           in     varchar2  default hr_api.g_varchar2
  ,p_witness_details              in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_injury_type                  in     varchar2  default hr_api.g_varchar2
  ,p_disease_type                 in     varchar2  default hr_api.g_varchar2
  ,p_hazard_type                  in     varchar2  default hr_api.g_varchar2
  ,p_body_part                    in     varchar2  default hr_api.g_varchar2
  ,p_treatment_received_flag      in     varchar2  default hr_api.g_varchar2
  ,p_hospital_details             in     varchar2  default hr_api.g_varchar2
    ,p_emergency_code                 in     varchar2 default hr_api.g_varchar2
    ,p_hospitalized_flag              in     varchar2 default hr_api.g_varchar2
    ,p_hospital_address               in     varchar2 default hr_api.g_varchar2
    ,p_activity_at_time_of_work       in     varchar2 default hr_api.g_varchar2
    ,p_objects_involved               in     varchar2 default hr_api.g_varchar2
    ,p_privacy_issue                  in     varchar2 default hr_api.g_varchar2
    ,p_work_start_time                in     varchar2 default hr_api.g_varchar2
    ,p_date_of_death                  in     date     default hr_api.g_date
    ,p_report_completed_by            in     varchar2 default hr_api.g_varchar2
    ,p_reporting_person_title         in     varchar2 default hr_api.g_varchar2
    ,p_reporting_person_phone         in     varchar2 default hr_api.g_varchar2
    ,p_days_restricted_work           in     number   default hr_api.g_number
    ,p_days_away_from_work            in     number   default hr_api.g_number
  ,p_doctor_name                  in     varchar2  default hr_api.g_varchar2
  ,p_compensation_date            in     date      default hr_api.g_date
  ,p_compensation_currency        in     varchar2  default hr_api.g_varchar2
  ,p_compensation_amount          in     number    default hr_api.g_number
  ,p_remedial_hs_action           in     varchar2  default hr_api.g_varchar2
  ,p_notified_hsrep_id            in     number    default hr_api.g_number
  ,p_notified_hsrep_date          in     date      default hr_api.g_date
  ,p_notified_rep_id              in     number    default hr_api.g_number
  ,p_notified_rep_date            in     date      default hr_api.g_date
  ,p_notified_rep_org_id          in     number    default hr_api.g_number
  ,p_over_time_flag               in     varchar2  default hr_api.g_varchar2
  ,p_absence_exists_flag          in     varchar2  default hr_api.g_varchar2
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
  ,p_inc_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_inc_information1             in     varchar2  default hr_api.g_varchar2
  ,p_inc_information2             in     varchar2  default hr_api.g_varchar2
  ,p_inc_information3             in     varchar2  default hr_api.g_varchar2
  ,p_inc_information4             in     varchar2  default hr_api.g_varchar2
  ,p_inc_information5             in     varchar2  default hr_api.g_varchar2
  ,p_inc_information6             in     varchar2  default hr_api.g_varchar2
  ,p_inc_information7             in     varchar2  default hr_api.g_varchar2
  ,p_inc_information8             in     varchar2  default hr_api.g_varchar2
  ,p_inc_information9             in     varchar2  default hr_api.g_varchar2
  ,p_inc_information10            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information11            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information12            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information21            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information22            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information23            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information24            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information25            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information26            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information27            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information28            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information29            in     varchar2  default hr_api.g_varchar2
  ,p_inc_information30            in     varchar2  default hr_api.g_varchar2
  );
--
end per_inc_upd;

 

/
