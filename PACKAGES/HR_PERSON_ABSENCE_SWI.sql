--------------------------------------------------------
--  DDL for Package HR_PERSON_ABSENCE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_ABSENCE_SWI" AUTHID CURRENT_USER As
/* $Header: hrabsswi.pkh 120.1.12010000.4 2009/09/25 10:25:10 ckondapi ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_person_absence >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_absence_api.create_person_absence
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_person_absence
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_business_group_id            in     number
  ,p_absence_attendance_type_id   in     number
  ,p_abs_attendance_reason_id     in     number    default null
  ,p_comments                     in     long      default null
  ,p_date_notification            in     date      default null
  ,p_date_projected_start         in     date      default null
  ,p_time_projected_start         in     varchar2  default null
  ,p_date_projected_end           in     date      default null
  ,p_time_projected_end           in     varchar2  default null
  ,p_date_start                   in     date      default null
  ,p_time_start                   in     varchar2  default null
  ,p_date_end                     in     date      default null
  ,p_time_end                     in     varchar2  default null
  ,p_absence_days                 in out nocopy number
  ,p_absence_hours                in out nocopy number
  ,p_authorising_person_id        in     number    default null
  ,p_replacement_person_id        in     number    default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_period_of_incapacity_id      in     number    default null
  ,p_ssp1_issued                  in     varchar2  default null
  ,p_maternity_id                 in     number    default null
  ,p_sickness_start_date          in     date      default null
  ,p_sickness_end_date            in     date      default null
  ,p_pregnancy_related_illness    in     varchar2  default null
  ,p_reason_for_notification_dela in     varchar2  default null
  ,p_accept_late_notification_fla in     varchar2  default null
  ,p_linked_absence_id            in     number    default null
  ,p_batch_id                     in     number    default null
  ,p_create_element_entry         in     number    default null
  ,p_abs_information_category     in     varchar2  default null
  ,p_abs_information1             in     varchar2  default null
  ,p_abs_information2             in     varchar2  default null
  ,p_abs_information3             in     varchar2  default null
  ,p_abs_information4             in     varchar2  default null
  ,p_abs_information5             in     varchar2  default null
  ,p_abs_information6             in     varchar2  default null
  ,p_abs_information7             in     varchar2  default null
  ,p_abs_information8             in     varchar2  default null
  ,p_abs_information9             in     varchar2  default null
  ,p_abs_information10            in     varchar2  default null
  ,p_abs_information11            in     varchar2  default null
  ,p_abs_information12            in     varchar2  default null
  ,p_abs_information13            in     varchar2  default null
  ,p_abs_information14            in     varchar2  default null
  ,p_abs_information15            in     varchar2  default null
  ,p_abs_information16            in     varchar2  default null
  ,p_abs_information17            in     varchar2  default null
  ,p_abs_information18            in     varchar2  default null
  ,p_abs_information19            in     varchar2  default null
  ,p_abs_information20            in     varchar2  default null
  ,p_abs_information21            in     varchar2  default null
  ,p_abs_information22            in     varchar2  default null
  ,p_abs_information23            in     varchar2  default null
  ,p_abs_information24            in     varchar2  default null
  ,p_abs_information25            in     varchar2  default null
  ,p_abs_information26            in     varchar2  default null
  ,p_abs_information27            in     varchar2  default null
  ,p_abs_information28            in     varchar2  default null
  ,p_abs_information29            in     varchar2  default null
  ,p_abs_information30            in     varchar2  default null
  ,p_absence_case_id              in     number    default null
  ,p_absence_attendance_id        in   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_occurrence                      out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_person_absence >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_absence_api.update_person_absence
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_person_absence
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_absence_attendance_id        in     number
  ,p_abs_attendance_reason_id     in     number    default hr_api.g_number
  ,p_comments                     in     long      default hr_api.g_varchar2
  ,p_date_notification            in     date      default hr_api.g_date
  ,p_date_projected_start         in     date      default hr_api.g_date
  ,p_time_projected_start         in     varchar2  default hr_api.g_varchar2
  ,p_date_projected_end           in     date      default hr_api.g_date
  ,p_time_projected_end           in     varchar2  default hr_api.g_varchar2
  ,p_date_start                   in     date      default hr_api.g_date
  ,p_time_start                   in     varchar2  default hr_api.g_varchar2
  ,p_date_end                     in     date      default hr_api.g_date
  ,p_time_end                     in     varchar2  default hr_api.g_varchar2
  ,p_absence_days                 in out nocopy number
  ,p_absence_hours                in out nocopy number
  ,p_authorising_person_id        in     number    default hr_api.g_number
  ,p_replacement_person_id        in     number    default hr_api.g_number
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
  ,p_period_of_incapacity_id      in     number    default hr_api.g_number
  ,p_ssp1_issued                  in     varchar2  default hr_api.g_varchar2
  ,p_maternity_id                 in     number    default hr_api.g_number
  ,p_sickness_start_date          in     date      default hr_api.g_date
  ,p_sickness_end_date            in     date      default hr_api.g_date
  ,p_pregnancy_related_illness    in     varchar2  default hr_api.g_varchar2
  ,p_reason_for_notification_dela in     varchar2  default hr_api.g_varchar2
  ,p_accept_late_notification_fla in     varchar2  default hr_api.g_varchar2
  ,p_linked_absence_id            in     number    default hr_api.g_number
  ,p_batch_id                     in     number    default hr_api.g_number
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
  ,p_absence_case_id              in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_absence >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_absence_api.delete_person_absence
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_person_absence
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_absence_attendance_id        in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );

-- ----------------------------------------------------------------------------
-- |---------------------------< process_api >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
-- This procedure is responsible for commiting data from transaction
-- table (hr_api_transaction_step_id) to the base table
--
-- Parameters:
-- p_document is the document having the data that needs to be committed
-- p_return_status is the return status after committing the date. In case of
-- any errors/warnings the p_return_status is populated with 'E' or 'W'
-- p_validate is the flag to indicate whether to rollback data or not
-- p_effective_date is the current effective date
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------

Procedure process_api
( p_document                in           CLOB
 ,p_return_status           out  nocopy  VARCHAR2
 ,p_validate                in           number    default hr_api.g_false_num
 ,p_effective_date          in           date      default null
);

 function chk_overlap(
    p_person_id          IN NUMBER
   ,p_business_group_id  IN NUMBER
   ,p_date_start         IN DATE
   ,p_date_end           IN DATE
   ,p_time_start         IN VARCHAR2
   ,p_time_end           IN VARCHAR2
  ) return boolean;

function getStartDate(p_transaction_id in number) return date;

function getEndDate(p_transaction_id in number) return date;

procedure delete_absences_in_tt
(p_transaction_id in	   number);

procedure otl_hr_check
(
p_person_id number default null,
p_date_start date default null,
p_date_end date default null,
p_scope varchar2 default null,
p_ret_value out nocopy varchar2,
p_error_name out nocopy varchar2
);

end hr_person_absence_swi;

/
