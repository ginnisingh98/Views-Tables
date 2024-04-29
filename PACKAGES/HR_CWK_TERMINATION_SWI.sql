--------------------------------------------------------
--  DDL for Package HR_CWK_TERMINATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CWK_TERMINATION_SWI" AUTHID CURRENT_USER As
/* $Header: hrcwtswi.pkh 120.0 2005/05/30 23:33 appldev noship $ */
    gv_TERMINATION_ACTIVITY_NAME CONSTANT
      wf_item_activity_statuses_v.activity_name%TYPE := 'HR_CWK_TERMINATION_SWI';

-- ----------------------------------------------------------------------------
-- |---------------------< actual_termination_placement >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_contingent_worker_api.actual_termination_placement
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
PROCEDURE actual_termination_placement
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in out nocopy date
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_termination_reason           in     varchar2  default hr_api.g_varchar2
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< final_process_placement >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_contingent_worker_api.final_process_placement
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
PROCEDURE final_process_placement
  (p_validate                     in     boolean
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_object_version_number        in out nocopy number
  ,p_final_process_date           in out nocopy date
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< get_length_of_placement >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_contingent_worker_api.get_length_of_placement
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
PROCEDURE get_length_of_placement
  (p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_total_years                     out nocopy number
  ,p_total_months                    out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< reverse_terminate_placement >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_contingent_worker_api.reverse_terminate_placement
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
PROCEDURE reverse_terminate_placement
  (p_validate                     in     boolean
  ,p_person_id                    in     number
  ,p_actual_termination_date      in     date
  ,p_clear_details                in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< terminate_placement >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_contingent_worker_api.terminate_placement
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
PROCEDURE terminate_placement
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_object_version_number        in out nocopy number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_assignment_status_type_id    in     number    default hr_api.g_number
  ,p_actual_termination_date      in     date      default hr_api.g_date
  ,p_final_process_date           in out nocopy date
  ,p_last_standard_process_date   in out nocopy date
  ,p_termination_reason           in     varchar2  default hr_api.g_varchar2
  ,p_projected_termination_date   in     date      default hr_api.g_date
  ,p_rehire_recommendation        in     varchar2  default hr_api.g_varchar2
  ,p_rehire_reason                in     varchar2  default hr_api.g_varchar2
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
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  );

PROCEDURE process_save
(  p_item_type                    in     wf_items.item_type%TYPE
  ,p_item_key                     in     wf_items.item_key%TYPE
  ,p_actid                        in     varchar2
  ,p_transaction_mode             in     varchar2 DEFAULT '#'
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_object_version_number        in     number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_actual_termination_date      in     date      default hr_api.g_date
  ,p_final_process_date           in     date
  ,p_last_standard_process_date   in     date
  ,p_termination_reason           in     varchar2  default hr_api.g_varchar2
  ,p_projected_termination_date   in     date      default hr_api.g_date
  ,p_rehire_recommendation        in     varchar2  default hr_api.g_varchar2
  ,p_rehire_reason                in     varchar2  default hr_api.g_varchar2
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
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ,p_information21                 in     varchar2 default hr_api.g_varchar2
  ,p_information22                 in     varchar2 default hr_api.g_varchar2
  ,p_information23                 in     varchar2 default hr_api.g_varchar2
  ,p_information24                 in     varchar2 default hr_api.g_varchar2
  ,p_information25                 in     varchar2 default hr_api.g_varchar2
  ,p_information26                 in     varchar2 default hr_api.g_varchar2
  ,p_information27                 in     varchar2 default hr_api.g_varchar2
  ,p_information28                 in     varchar2 default hr_api.g_varchar2
  ,p_information29                 in     varchar2 default hr_api.g_varchar2
  ,p_information30                 in     varchar2 default hr_api.g_varchar2
  ,p_review_proc_call             in     varchar2  default hr_api.g_varchar2
  ,p_effective_date_option        in     varchar2  default hr_api.g_varchar2
  ,p_login_person_id              in     number
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ,p_return_on_warning             in     varchar2 default null --Bug fix 1370960
);

PROCEDURE getTransactionDetails
(  p_transaction_step_id          in      varchar2
  ,p_person_id                    out nocopy     number
  ,p_date_start                   out nocopy     date
  ,p_object_version_number        out nocopy     number
  ,p_person_type_id               out nocopy     number
  ,p_actual_termination_date      out nocopy     date
  ,p_final_process_date           out nocopy     date
  ,p_last_standard_process_date   out nocopy     date
  ,p_termination_reason           out nocopy     varchar2
  ,p_rehire_recommendation        out nocopy     varchar2
  ,p_rehire_reason                out nocopy     varchar2
  ,p_projected_termination_date   out nocopy     date
  ,p_attribute_category           out nocopy     varchar2
  ,p_attribute1                   out nocopy     varchar2
  ,p_attribute2                   out nocopy     varchar2
  ,p_attribute3                   out nocopy     varchar2
  ,p_attribute4                   out nocopy     varchar2
  ,p_attribute5                   out nocopy     varchar2
  ,p_attribute6                   out nocopy     varchar2
  ,p_attribute7                   out nocopy     varchar2
  ,p_attribute8                   out nocopy     varchar2
  ,p_attribute9                   out nocopy     varchar2
  ,p_attribute10                  out nocopy     varchar2
  ,p_attribute11                  out nocopy     varchar2
  ,p_attribute12                  out nocopy     varchar2
  ,p_attribute13                  out nocopy     varchar2
  ,p_attribute14                  out nocopy     varchar2
  ,p_attribute15                  out nocopy     varchar2
  ,p_attribute16                  out nocopy     varchar2
  ,p_attribute17                  out nocopy     varchar2
  ,p_attribute18                  out nocopy     varchar2
  ,p_attribute19                  out nocopy     varchar2
  ,p_attribute20                  out nocopy     varchar2
  ,p_attribute21                  out nocopy     varchar2
  ,p_attribute22                  out nocopy     varchar2
  ,p_attribute23                  out nocopy     varchar2
  ,p_attribute24                  out nocopy     varchar2
  ,p_attribute25                  out nocopy     varchar2
  ,p_attribute26                  out nocopy     varchar2
  ,p_attribute27                  out nocopy     varchar2
  ,p_attribute28                  out nocopy     varchar2
  ,p_attribute29                  out nocopy     varchar2
  ,p_attribute30                  out nocopy     varchar2
  ,p_information_category         out NOCOPY     varchar2
  ,p_information1                 out nocopy     varchar2
  ,p_information2                 out nocopy     varchar2
  ,p_information3                 out nocopy     varchar2
  ,p_information4                 out nocopy     varchar2
  ,p_information5                 out nocopy     varchar2
  ,p_information6                 out nocopy     varchar2
  ,p_information7                 out nocopy     varchar2
  ,p_information8                 out nocopy     varchar2
  ,p_information9                 out nocopy     varchar2
  ,p_information10                out nocopy     varchar2
  ,p_information11                out nocopy     varchar2
  ,p_information12                out nocopy     varchar2
  ,p_information13                out nocopy     varchar2
  ,p_information14                out nocopy     varchar2
  ,p_information15                out nocopy     varchar2
  ,p_information16                out nocopy     varchar2
  ,p_information17                out nocopy     varchar2
  ,p_information18                out nocopy     varchar2
  ,p_information19                out nocopy     varchar2
  ,p_information20                out nocopy     varchar2
  ,p_information21                out nocopy     varchar2
  ,p_information22                out nocopy     varchar2
  ,p_information23                out nocopy     varchar2
  ,p_information24                out nocopy     varchar2
  ,p_information25                out nocopy     varchar2
  ,p_information26                out nocopy     varchar2
  ,p_information27                out nocopy     varchar2
  ,p_information28                out nocopy     varchar2
  ,p_information29                out nocopy     varchar2
  ,p_information30                out nocopy     varchar2
);

procedure process_api
(    p_validate			  in	boolean  default false
    ,p_transaction_step_id	  in	number   default null
    ,p_effective_date		  in	varchar2 default NULL
);

end hr_cwk_termination_swi;

 

/
