--------------------------------------------------------
--  DDL for Package HR_REVTERMINATION_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_REVTERMINATION_SS" AUTHID CURRENT_USER AS
/* $Header: hrrevtrmwrs.pkh 120.0.12010000.2 2010/03/30 06:40:17 amunsi noship $ */

  gtt_transaction_steps hr_transaction_ss.transaction_table;
  gv_TERMINATION_ACTIVITY_NAME CONSTANT
      wf_item_activity_statuses_v.activity_name%TYPE := 'HR_REVTERMINATION_SS';


  --store termination related information
  TYPE rt_termination IS RECORD (
    actual_termination_date
      per_periods_of_service.actual_termination_date%TYPE,
    notified_termination_date
      per_periods_of_service.notified_termination_date%TYPE,
    leaving_reason
      per_periods_of_service.leaving_reason%TYPE,
    comments
      per_periods_of_service.comments%TYPE,
    period_of_service_id
      per_periods_of_service.period_of_service_id%TYPE,
    object_version_number
      per_periods_of_service.object_version_number%TYPE,
    person_type_id
      per_person_types.person_type_id%TYPE,
    assignment_status_type_id
      per_assignment_status_types.assignment_status_type_id%TYPE,
    rehire_recommendation
      per_all_people_f.rehire_recommendation%TYPE,
    rehire_reason
      per_all_people_f.rehire_reason%TYPE,
    last_standard_process_date
      per_periods_of_service.last_standard_process_date%type,
    projected_termination_date
      per_periods_of_service.projected_termination_date%type,
    final_process_date
      per_periods_of_service.final_process_date%type
  );

  -- for DFF
  TYPE t_flex_table IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;


  /*
  ||===========================================================================
  || PROCEDURE: ex_emp_process_save
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Save Termination Transaction to transaction table
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Transaction details that need to be saved to transaction table
  ||
  || out nocopy Arguments:
  ||     None.
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Writes to transaction table
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */
    PROCEDURE ex_emp_process_save (
                   p_validate    		  in     number  default 0
                  ,p_effective_date               in     varchar2
                  ,p_item_type                    in     wf_items.item_type%TYPE
                  ,p_item_key                     in     wf_items.item_key%TYPE
                  ,p_actid                        in     varchar2
                  ,p_transaction_mode             in     varchar2 DEFAULT '#'
                  ,p_period_of_service_id         in     number    default hr_api.g_number
                  ,p_object_version_number        in     number
                  ,p_person_id                    in     number
                  ,p_login_person_id              in     number
                  ,p_actual_termination_date      in     varchar2
                  ,p_last_standard_process_date   in     varchar2
                  ,p_leaving_reason               in     varchar2
                  ,p_comments                     in     varchar2 default hr_api.g_varchar2
                  ,p_notified_termination_date    in     varchar2
                  ,p_review_proc_call             in     varchar2
                  ,p_attribute_category           in     varchar2 default hr_api.g_varchar2
                  ,p_attribute1                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute2                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute3                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute4                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute5                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute6                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute7                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute8                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute9                   in     varchar2 default hr_api.g_varchar2
                  ,p_attribute10                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute11                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute12                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute13                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute14                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute15                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute16                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute17                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute18                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute19                  in     varchar2 default hr_api.g_varchar2
                  ,p_attribute20                  in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information_category     in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information1             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information2             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information3             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information4             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information5             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information6             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information7             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information8             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information9             in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information10            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information11            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information12            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information13            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information14            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information15            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information16            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information17            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information18            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information19            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information20            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information21            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information22            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information23            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information24            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information25            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information26            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information27            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information28            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information29            in     varchar2 default hr_api.g_varchar2
                  ,p_pds_information30            in     varchar2 default hr_api.g_varchar2
                  ,p_person_type_id               in number
                  ,p_assignment_status_type_id    in number
                  ,p_rehire_recommendation        in     varchar2 default hr_api.g_varchar2
                  ,p_rehire_reason                in     varchar2 default hr_api.g_varchar2
                  ,p_projected_termination_date   in     varchar2 default hr_api.g_varchar2
                  ,p_final_process_date           in     varchar2 default hr_api.g_varchar2
                   ,p_clear_details               in     varchar2 default 'Y'
                  ,p_error_message                out nocopy    long

                  );

/*
  ||===========================================================================
  || PROCEDURE: ex_cwk_process_save
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Save Termination Transaction to transaction table
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Transaction details that need to be saved to transaction table
  ||
  || out nocopy Arguments:
  ||     None.
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Writes to transaction table
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public
  ||
  ||===========================================================================
  */
   PROCEDURE ex_cwk_process_save
(  p_validate                      in     number  default 0
  ,p_item_type                    in     wf_items.item_type%TYPE
  ,p_item_key                     in     wf_items.item_key%TYPE
  ,p_actid                        in     varchar2
  ,p_transaction_mode             in     varchar2 DEFAULT '#'
  ,p_effective_date               in     varchar2
  ,p_person_id                    in     number
  ,p_date_start                   in     varchar2
  ,p_object_version_number        in     number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_actual_termination_date      in     varchar2      default to_char(hr_api.g_date)
  ,p_final_process_date           in     varchar2
  ,p_last_standard_process_date   in     varchar2
  ,p_termination_reason           in     varchar2  default hr_api.g_varchar2
  ,p_projected_termination_date   in     varchar2      default to_char(hr_api.g_date)
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
  ,p_clear_details                 in     varchar2 default 'Y'
  ,p_fut_actns_exist_warning         out nocopy number
  ,p_error_message                 out nocopy    long

);

  /*
  ||==========================================================================
  || PROCEDURE: process_api
  ||--------------------------------------------------------------------------
  ||
  || Description:
  ||    This procedure is invoked whenever approvers have approved the
  ||    termination proposal. It is called from workflow.
  ||    It will call the termination APIs to update hr tables.
  ||
  || Pre-Requisities:
  ||    The transaction step must exist.
  ||
  || In Parameters:
  ||    p_validate             Determines if the API should be called in
  ||                           validate mode.
  ||    p_transaction_step_id  Specifies which transaction step is to be
  ||                           processed.
  ||
  || Post Success:
  ||    Termination APIs will be processed.
  ||
  || Post Failure:
  ||    None
  ||
  || Access Status:
  ||    Public.
  ||
  ||==========================================================================
  */
  PROCEDURE process_api (
    p_validate            IN BOOLEAN DEFAULT FALSE,
    p_transaction_step_id IN NUMBER DEFAULT NULL,
    p_effective_date      IN VARCHAR2 DEFAULT NULL
  );


procedure checkPersonType( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     );

PROCEDURE getCwkTransactionDetails
(  p_transaction_step_id          in      varchar2
  ,p_person_id                    out nocopy     number
  ,p_date_start                   out nocopy     Date
  ,p_object_version_number        out nocopy     number
  ,p_person_type_id               out nocopy     number
  ,p_actual_termination_date      out nocopy     Date
  ,p_final_process_date           out nocopy     Date
  ,p_last_standard_process_date   out nocopy     Date
  ,p_termination_reason           out nocopy     varchar2
  ,p_rehire_recommendation        out nocopy     varchar2
  ,p_rehire_reason                out nocopy     varchar2
  ,p_projected_termination_date   out nocopy     Date
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
  ,p_clear_details                out nocopy     varchar2
);

PROCEDURE getEmpTransactionDetails
(  p_transaction_step_id          in      varchar2
  ,p_person_id                    out nocopy     number
  ,period_of_service_id           out nocopy     number
  ,p_object_version_number        out nocopy     number
  ,p_actual_termination_date      out nocopy     Date
  ,p_leaving_reason                out nocopy    varchar2
  ,p_notified_termination_date     out nocopy    Date
  ,p_comments                      out nocopy    varchar2
  ,p_last_standard_process_date    out nocopy    Date
  ,p_projected_termination_date   out nocopy     Date
  ,p_final_process_date           out nocopy     Date
  ,p_rehire_recommendation       out nocopy    varchar2
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
  ,p_pds_information_category         out NOCOPY     varchar2
  ,p_pds_information1                 out nocopy     varchar2
  ,p_pds_information2                 out nocopy     varchar2
  ,p_pds_information3                 out nocopy     varchar2
  ,p_pds_information4                 out nocopy     varchar2
  ,p_pds_information5                 out nocopy     varchar2
  ,p_pds_information6                 out nocopy     varchar2
  ,p_pds_information7                 out nocopy     varchar2
  ,p_pds_information8                 out nocopy     varchar2
  ,p_pds_information9                 out nocopy     varchar2
  ,p_pds_information10                out nocopy     varchar2
  ,p_pds_information11                out nocopy     varchar2
  ,p_pds_information12                out nocopy     varchar2
  ,p_pds_information13                out nocopy     varchar2
  ,p_pds_information14                out nocopy     varchar2
  ,p_pds_information15                out nocopy     varchar2
  ,p_pds_information16                out nocopy     varchar2
  ,p_pds_information17                out nocopy     varchar2
  ,p_pds_information18                out nocopy     varchar2
  ,p_pds_information19                out nocopy     varchar2
  ,p_pds_information20                out nocopy     varchar2
  ,p_pds_information21                out nocopy     varchar2
  ,p_pds_information22                out nocopy     varchar2
  ,p_pds_information23                out nocopy     varchar2
  ,p_pds_information24                out nocopy     varchar2
  ,p_pds_information25                out nocopy     varchar2
  ,p_pds_information26                out nocopy     varchar2
  ,p_pds_information27                out nocopy     varchar2
  ,p_pds_information28                out nocopy     varchar2
  ,p_pds_information29                out nocopy     varchar2
  ,p_pds_information30                out nocopy     varchar2
  ,p_clear_details                out nocopy     varchar2
);

END hr_revtermination_ss;

/
