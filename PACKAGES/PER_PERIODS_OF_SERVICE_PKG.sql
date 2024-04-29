--------------------------------------------------------
--  DDL for Package PER_PERIODS_OF_SERVICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERIODS_OF_SERVICE_PKG" AUTHID CURRENT_USER AS
/* $Header: pepds01t.pkh 115.7 2002/12/09 14:08:58 pkakar ship $ */
-----------------------------------------------------------------------------
procedure delete_per_pay_proposals(p_period_of_service_id number
                                  ,p_actual_termination_date date);
-----------------------------------------------------------------------------
procedure get_years_months(p_session_date  IN DATE,
                           p_period_of_service_id IN NUMBER,
                           p_business_group_id    IN     NUMBER,
                           p_person_id            IN     NUMBER,
                           p_tp_years             IN OUT NOCOPY NUMBER,
                           p_tp_months            IN OUT NOCOPY NUMBER,
                           p_total_years          IN OUT NOCOPY NUMBER,
                           p_total_months         IN OUT NOCOPY NUMBER);
-----------------------------------------------------------------------------
procedure get_final_dates(p_period_of_service_id NUMBER,
                         p_person_id NUMBER,
                         p_actual_termination_date DATE,
                         p_no_payrolls IN OUT NOCOPY NUMBER,
                         p_final_process_date IN OUT NOCOPY DATE,
                         p_last_standard_process_date IN OUT NOCOPY DATE);
-----------------------------------------------------------------------------
procedure delete_row(p_row_id VARCHAR2);
-----------------------------------------------------------------------------
procedure insert_row(p_row_id in out nocopy VARCHAR2
,p_period_of_service_id in out nocopy NUMBER
,p_business_group_id              NUMBER
,p_person_id                      NUMBER
,p_date_start                     DATE
,p_termination_accepted_per_id NUMBER
,p_accepted_termination_date      DATE
,p_actual_termination_date        DATE
,p_comments                       VARCHAR2
,p_final_process_date             DATE
,p_last_standard_process_date     DATE
,p_leaving_reason                 VARCHAR2
,p_notified_termination_date      DATE
,p_projected_termination_date     DATE
,p_request_id                     NUMBER
,p_program_application_id         NUMBER
,p_program_id                     NUMBER
,p_program_update_date            DATE
,p_attribute_category             VARCHAR2
,p_attribute1                     VARCHAR2
,p_attribute2                     VARCHAR2
,p_attribute3                     VARCHAR2
,p_attribute4                     VARCHAR2
,p_attribute5                     VARCHAR2
,p_attribute6                     VARCHAR2
,p_attribute7                     VARCHAR2
,p_attribute8                     VARCHAR2
,p_attribute9                     VARCHAR2
,p_attribute10                    VARCHAR2
,p_attribute11                    VARCHAR2
,p_attribute12                    VARCHAR2
,p_attribute13                    VARCHAR2
,p_attribute14                    VARCHAR2
,p_attribute15                    VARCHAR2
,p_attribute16                    VARCHAR2
,p_attribute17                    VARCHAR2
,p_attribute18                    VARCHAR2
,p_attribute19                    VARCHAR2
,p_attribute20                    VARCHAR2
,p_adjusted_svc_date              DATE);
-----------------------------------------------------------------------------
procedure lock_row(p_row_id VARCHAR2
,p_period_of_service_id           NUMBER
,p_business_group_id              NUMBER
,p_person_id                      NUMBER
,p_date_start                     DATE
,p_termination_accepted_per_id NUMBER
,p_accepted_termination_date      DATE
,p_actual_termination_date        DATE
,p_comments                       VARCHAR2
,p_final_process_date             DATE
,p_last_standard_process_date     DATE
,p_leaving_reason                 VARCHAR2
,p_notified_termination_date      DATE
,p_projected_termination_date     DATE
,p_request_id                     NUMBER
,p_program_application_id         NUMBER
,p_program_id                     NUMBER
,p_program_update_date            DATE
,p_attribute_category             VARCHAR2
,p_attribute1                     VARCHAR2
,p_attribute2                     VARCHAR2
,p_attribute3                     VARCHAR2
,p_attribute4                     VARCHAR2
,p_attribute5                     VARCHAR2
,p_attribute6                     VARCHAR2
,p_attribute7                     VARCHAR2
,p_attribute8                     VARCHAR2
,p_attribute9                     VARCHAR2
,p_attribute10                    VARCHAR2
,p_attribute11                    VARCHAR2
,p_attribute12                    VARCHAR2
,p_attribute13                    VARCHAR2
,p_attribute14                    VARCHAR2
,p_attribute15                    VARCHAR2
,p_attribute16                    VARCHAR2
,p_attribute17                    VARCHAR2
,p_attribute18                    VARCHAR2
,p_attribute19                    VARCHAR2
,p_attribute20                    VARCHAR2
,p_pds_information_category       VARCHAR2
,p_pds_information1               VARCHAR2
,p_pds_information2               VARCHAR2
,p_pds_information3               VARCHAR2
,p_pds_information4               VARCHAR2
,p_pds_information5               VARCHAR2
,p_pds_information6               VARCHAR2
,p_pds_information7               VARCHAR2
,p_pds_information8               VARCHAR2
,p_pds_information9               VARCHAR2
,p_pds_information10              VARCHAR2
,p_pds_information11              VARCHAR2
,p_pds_information12              VARCHAR2
,p_pds_information13              VARCHAR2
,p_pds_information14              VARCHAR2
,p_pds_information15              VARCHAR2
,p_pds_information16              VARCHAR2
,p_pds_information17              VARCHAR2
,p_pds_information18              VARCHAR2
,p_pds_information19              VARCHAR2
,p_pds_information20              VARCHAR2
,p_pds_information21              VARCHAR2
,p_pds_information22              VARCHAR2
,p_pds_information23              VARCHAR2
,p_pds_information24              VARCHAR2
,p_pds_information25              VARCHAR2
,p_pds_information26              VARCHAR2
,p_pds_information27              VARCHAR2
,p_pds_information28              VARCHAR2
,p_pds_information29              VARCHAR2
,p_pds_information30              VARCHAR2
,p_adjusted_svc_date              DATE);
-----------------------------------------------------------------------------
procedure update_term_row(p_row_id VARCHAR2
,p_period_of_service_id           NUMBER
,p_business_group_id              NUMBER
,p_person_id                      NUMBER
,p_date_start                     DATE
,p_termination_accepted_per_id NUMBER
,p_accepted_termination_date      DATE
,p_actual_termination_date        DATE
,p_comments                       VARCHAR2
,p_final_process_date             DATE
,p_last_standard_process_date     DATE
,p_leaving_reason                 VARCHAR2
,p_notified_termination_date      DATE
,p_projected_termination_date     DATE
,p_request_id                     NUMBER
,p_program_application_id         NUMBER
,p_program_id                     NUMBER
,p_program_update_date            DATE
,p_attribute_category             VARCHAR2
,p_attribute1                     VARCHAR2
,p_attribute2                     VARCHAR2
,p_attribute3                     VARCHAR2
,p_attribute4                     VARCHAR2
,p_attribute5                     VARCHAR2
,p_attribute6                     VARCHAR2
,p_attribute7                     VARCHAR2
,p_attribute8                     VARCHAR2
,p_attribute9                     VARCHAR2
,p_attribute10                    VARCHAR2
,p_attribute11                    VARCHAR2
,p_attribute12                    VARCHAR2
,p_attribute13                    VARCHAR2
,p_attribute14                    VARCHAR2
,p_attribute15                    VARCHAR2
,p_attribute16                    VARCHAR2
,p_attribute17                    VARCHAR2
,p_attribute18                    VARCHAR2
,p_attribute19                    VARCHAR2
,p_attribute20                    VARCHAR2
,p_initiate_cancellation          VARCHAR2
,p_s_final_process_date IN OUT NOCOPY    DATE
,p_s_actual_termination_date IN OUT NOCOPY DATE
,p_c_assignment_status_type_id IN OUT NOCOPY NUMBER
,p_d_status                       VARCHAR2
,p_requery_required        IN OUT NOCOPY VARCHAR2
,p_clear_details  VARCHAR2 DEFAULT 'N'
,p_legislation_code               VARCHAR2
,p_pds_information_category       VARCHAR2
,p_pds_information1               VARCHAR2
,p_pds_information2               VARCHAR2
,p_pds_information3               VARCHAR2
,p_pds_information4               VARCHAR2
,p_pds_information5               VARCHAR2
,p_pds_information6               VARCHAR2
,p_pds_information7               VARCHAR2
,p_pds_information8               VARCHAR2
,p_pds_information9               VARCHAR2
,p_pds_information10              VARCHAR2
,p_pds_information11              VARCHAR2
,p_pds_information12              VARCHAR2
,p_pds_information13              VARCHAR2
,p_pds_information14              VARCHAR2
,p_pds_information15              VARCHAR2
,p_pds_information16              VARCHAR2
,p_pds_information17              VARCHAR2
,p_pds_information18              VARCHAR2
,p_pds_information19              VARCHAR2
,p_pds_information20              VARCHAR2
,p_pds_information21              VARCHAR2
,p_pds_information22              VARCHAR2
,p_pds_information23              VARCHAR2
,p_pds_information24              VARCHAR2
,p_pds_information25              VARCHAR2
,p_pds_information26              VARCHAR2
,p_pds_information27              VARCHAR2
,p_pds_information28              VARCHAR2
,p_pds_information29              VARCHAR2
,p_pds_information30              VARCHAR2
,p_adjusted_svc_date              DATE
);
-----------------------------------------------------------------------------
procedure update_term_row(p_row_id VARCHAR2
,p_period_of_service_id           NUMBER
,p_business_group_id              NUMBER
,p_person_id                      NUMBER
,p_date_start                     DATE
,p_termination_accepted_per_id NUMBER
,p_accepted_termination_date      DATE
,p_actual_termination_date        DATE
,p_comments                       VARCHAR2
,p_final_process_date             DATE
,p_last_standard_process_date     DATE
,p_leaving_reason                 VARCHAR2
,p_notified_termination_date      DATE
,p_projected_termination_date     DATE
,p_request_id                     NUMBER
,p_program_application_id         NUMBER
,p_program_id                     NUMBER
,p_program_update_date            DATE
,p_attribute_category             VARCHAR2
,p_attribute1                     VARCHAR2
,p_attribute2                     VARCHAR2
,p_attribute3                     VARCHAR2
,p_attribute4                     VARCHAR2
,p_attribute5                     VARCHAR2
,p_attribute6                     VARCHAR2
,p_attribute7                     VARCHAR2
,p_attribute8                     VARCHAR2
,p_attribute9                     VARCHAR2
,p_attribute10                    VARCHAR2
,p_attribute11                    VARCHAR2
,p_attribute12                    VARCHAR2
,p_attribute13                    VARCHAR2
,p_attribute14                    VARCHAR2
,p_attribute15                    VARCHAR2
,p_attribute16                    VARCHAR2
,p_attribute17                    VARCHAR2
,p_attribute18                    VARCHAR2
,p_attribute19                    VARCHAR2
,p_attribute20                    VARCHAR2
,p_initiate_cancellation          VARCHAR2
,p_s_final_process_date IN OUT NOCOPY    DATE
,p_s_actual_termination_date IN OUT NOCOPY DATE
,p_c_assignment_status_type_id IN OUT NOCOPY NUMBER
,p_d_status                       VARCHAR2
,p_requery_required        IN OUT NOCOPY VARCHAR2
,p_clear_details  VARCHAR2 DEFAULT 'N'
,p_legislation_code               VARCHAR2
,p_pds_information_category       VARCHAR2
,p_pds_information1               VARCHAR2
,p_pds_information2               VARCHAR2
,p_pds_information3               VARCHAR2
,p_pds_information4               VARCHAR2
,p_pds_information5               VARCHAR2
,p_pds_information6               VARCHAR2
,p_pds_information7               VARCHAR2
,p_pds_information8               VARCHAR2
,p_pds_information9               VARCHAR2
,p_pds_information10              VARCHAR2
,p_pds_information11              VARCHAR2
,p_pds_information12              VARCHAR2
,p_pds_information13              VARCHAR2
,p_pds_information14              VARCHAR2
,p_pds_information15              VARCHAR2
,p_pds_information16              VARCHAR2
,p_pds_information17              VARCHAR2
,p_pds_information18              VARCHAR2
,p_pds_information19              VARCHAR2
,p_pds_information20              VARCHAR2
,p_pds_information21              VARCHAR2
,p_pds_information22              VARCHAR2
,p_pds_information23              VARCHAR2
,p_pds_information24              VARCHAR2
,p_pds_information25              VARCHAR2
,p_pds_information26              VARCHAR2
,p_pds_information27              VARCHAR2
,p_pds_information28              VARCHAR2
,p_pds_information29              VARCHAR2
,p_pds_information30              VARCHAR2
,p_adjusted_svc_date              DATE
,p_dodwarning                OUT NOCOPY  VARCHAR2);
-----------------------------------------------------------------------------
procedure update_row(p_row_id VARCHAR2
,p_period_of_service_id           NUMBER
,p_business_group_id              NUMBER
,p_person_id                      NUMBER
,p_date_start                     DATE
,p_termination_accepted_per_id NUMBER
,p_accepted_termination_date      DATE
,p_actual_termination_date        DATE
,p_comments                       VARCHAR2
,p_final_process_date             DATE
,p_last_standard_process_date     DATE
,p_leaving_reason                 VARCHAR2
,p_notified_termination_date      DATE
,p_projected_termination_date     DATE
,p_request_id                     NUMBER
,p_program_application_id         NUMBER
,p_program_id                     NUMBER
,p_program_update_date            DATE
,p_attribute_category             VARCHAR2
,p_attribute1                     VARCHAR2
,p_attribute2                     VARCHAR2
,p_attribute3                     VARCHAR2
,p_attribute4                     VARCHAR2
,p_attribute5                     VARCHAR2
,p_attribute6                     VARCHAR2
,p_attribute7                     VARCHAR2
,p_attribute8                     VARCHAR2
,p_attribute9                     VARCHAR2
,p_attribute10                    VARCHAR2
,p_attribute11                    VARCHAR2
,p_attribute12                    VARCHAR2
,p_attribute13                    VARCHAR2
,p_attribute14                    VARCHAR2
,p_attribute15                    VARCHAR2
,p_attribute16                    VARCHAR2
,p_attribute17                    VARCHAR2
,p_attribute18                    VARCHAR2
,p_attribute19                    VARCHAR2
,p_attribute20                    VARCHAR2
,p_pds_information_category       VARCHAR2
,p_pds_information1               VARCHAR2
,p_pds_information2               VARCHAR2
,p_pds_information3               VARCHAR2
,p_pds_information4               VARCHAR2
,p_pds_information5               VARCHAR2
,p_pds_information6               VARCHAR2
,p_pds_information7               VARCHAR2
,p_pds_information8               VARCHAR2
,p_pds_information9               VARCHAR2
,p_pds_information10              VARCHAR2
,p_pds_information11              VARCHAR2
,p_pds_information12              VARCHAR2
,p_pds_information13              VARCHAR2
,p_pds_information14              VARCHAR2
,p_pds_information15              VARCHAR2
,p_pds_information16              VARCHAR2
,p_pds_information17              VARCHAR2
,p_pds_information18              VARCHAR2
,p_pds_information19              VARCHAR2
,p_pds_information20              VARCHAR2
,p_pds_information21              VARCHAR2
,p_pds_information22              VARCHAR2
,p_pds_information23              VARCHAR2
,p_pds_information24              VARCHAR2
,p_pds_information25              VARCHAR2
,p_pds_information26              VARCHAR2
,p_pds_information27              VARCHAR2
,p_pds_information28              VARCHAR2
,p_pds_information29              VARCHAR2
,p_pds_information30              VARCHAR2
,p_adjusted_svc_date              DATE);
-------------------------------------------------------------------------------
procedure populate_status(p_person_id NUMBER
                         ,p_status in out nocopy VARCHAR2
                         ,p_assignment_status_id in out nocopy number);
-----------------------------------------------------------------------------
procedure form_post_query(p_session_date DATE
                         ,p_period_of_service_id NUMBER
                         ,p_business_group_id NUMBER
                         ,p_person_id NUMBER
                         ,p_tp_years IN OUT NOCOPY NUMBER
                         ,p_tp_months IN OUT NOCOPY NUMBER
                         ,p_total_years IN OUT NOCOPY NUMBER
                         ,p_total_months IN OUT NOCOPY NUMBER
                         ,p_actual_termination_date DATE
                         ,p_status IN OUT NOCOPY VARCHAR2
                         ,p_termination_accepted_id IN NUMBER
                         ,p_terminated_name IN OUT NOCOPY VARCHAR2
                         ,p_terminated_number IN OUT NOCOPY VARCHAR2
                         ,p_assignment_status_id IN OUT NOCOPY NUMBER);
-------------------------------------------------------------------------------

END PER_PERIODS_OF_SERVICE_PKG;

 

/
