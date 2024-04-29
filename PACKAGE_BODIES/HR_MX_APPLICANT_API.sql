--------------------------------------------------------
--  DDL for Package Body HR_MX_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MX_APPLICANT_API" AS
/* $Header: hrmxwraa.pkb 120.0 2005/05/31 01:30:41 appldev noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : HR_MX_APPLICANT_API

    Description : This is Mexican wrapper package for hr_applicant_api.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    23-JUN-2004 sdahiya    115.0            Created.
    08-JUL-2004 sdahiya    115.1   3695738  Enabled defaulting of p_first_name in
                                            create_mx_applicant.
                                            Enabled defaulting of following parameters in
                                            hire_mx_applicant procedure :-
                                              - p_validate
                                              - p_assignment_id
                                              - p_person_type_id
                                              - p_curp_id
                                              - p_original_date_of_hire
                                           Added business group check in hire_mx_applicant.
  *****************************************************************************/

    g_proc_name varchar2 (30);
/*******************************************************************************
    Name    : create_mx_applicant
    Purpose : This procedure acts as wrapper for hr_applicant_api.create_applicant.
*******************************************************************************/

PROCEDURE CREATE_MX_APPLICANT
      (p_validate                     in     boolean  default false
      ,p_date_received                in     date
      ,p_business_group_id            in     number
      ,p_paternal_last_name           in     varchar2
      ,p_person_type_id               in     number   default null
      ,p_applicant_number             in out nocopy varchar2
      ,p_per_comments                 in     varchar2 default null
      ,p_date_employee_data_verified  in     date     default null
      ,p_date_of_birth                in     date     default null
      ,p_email_address                in     varchar2 default null
      ,p_expense_check_send_to_addres in     varchar2 default null
      ,p_first_name                   in     varchar2 default null /* Bug 3695738 */
      ,p_known_as                     in     varchar2 default null
      ,p_marital_status               in     varchar2 default null
      ,p_second_name                  in     varchar2 default null
      ,p_nationality                  in     varchar2 default null
      ,p_curp_id                      in     varchar2 default null
      ,p_previous_last_name           in     varchar2 default null
      ,p_registered_disabled_flag     in     varchar2 default null
      ,p_sex                          in     varchar2 default null
      ,p_title                        in     varchar2 default null
      ,p_work_telephone               in     varchar2 default null
      ,p_attribute_category           in     varchar2 default null
      ,p_attribute1                   in     varchar2 default null
      ,p_attribute2                   in     varchar2 default null
      ,p_attribute3                   in     varchar2 default null
      ,p_attribute4                   in     varchar2 default null
      ,p_attribute5                   in     varchar2 default null
      ,p_attribute6                   in     varchar2 default null
      ,p_attribute7                   in     varchar2 default null
      ,p_attribute8                   in     varchar2 default null
      ,p_attribute9                   in     varchar2 default null
      ,p_attribute10                  in     varchar2 default null
      ,p_attribute11                  in     varchar2 default null
      ,p_attribute12                  in     varchar2 default null
      ,p_attribute13                  in     varchar2 default null
      ,p_attribute14                  in     varchar2 default null
      ,p_attribute15                  in     varchar2 default null
      ,p_attribute16                  in     varchar2 default null
      ,p_attribute17                  in     varchar2 default null
      ,p_attribute18                  in     varchar2 default null
      ,p_attribute19                  in     varchar2 default null
      ,p_attribute20                  in     varchar2 default null
      ,p_attribute21                  in     varchar2 default null
      ,p_attribute22                  in     varchar2 default null
      ,p_attribute23                  in     varchar2 default null
      ,p_attribute24                  in     varchar2 default null
      ,p_attribute25                  in     varchar2 default null
      ,p_attribute26                  in     varchar2 default null
      ,p_attribute27                  in     varchar2 default null
      ,p_attribute28                  in     varchar2 default null
      ,p_attribute29                  in     varchar2 default null
      ,p_attribute30                  in     varchar2 default null
      ,p_maternal_last_name             in     varchar2 default null
      ,p_rfc_id                       in     varchar2 default null
      ,p_ss_id                        in     varchar2 default null
      ,p_imss_med_center              in     varchar2 default null
      ,p_fed_gov_affil_id             in     varchar2 default null
      ,p_mil_serv_id                  in     varchar2 default null
      ,p_background_check_status      in     varchar2 default null
      ,p_background_date_check        in     date     default null
      ,p_correspondence_language      in     varchar2 default null
      ,p_fte_capacity                 in     number   default null
      ,p_hold_applicant_date_until    in     date     default null
      ,p_honors                       in     varchar2 default null
      ,p_mailstop                     in     varchar2 default null
      ,p_office_number                in     varchar2 default null
      ,p_on_military_service          in     varchar2 default null
      ,p_pre_name_adjunct             in     varchar2 default null
      ,p_projected_start_date         in     date     default null
      ,p_resume_exists                in     varchar2 default null
      ,p_resume_last_updated          in     date     default null
      ,p_student_status               in     varchar2 default null
      ,p_work_schedule                in     varchar2 default null
      ,p_suffix                       in     varchar2 default null
      ,p_date_of_death                in     date     default null
      ,p_benefit_group_id             in     number   default null
      ,p_receipt_of_death_cert_date   in     date     default null
      ,p_coord_ben_med_pln_no         in     varchar2 default null
      ,p_coord_ben_no_cvg_flag        in     varchar2 default 'N'
      ,p_uses_tobacco_flag            in     varchar2 default null
      ,p_dpdnt_adoption_date          in     date     default null
      ,p_dpdnt_vlntry_svce_flag       in     varchar2 default 'N'
      ,p_original_date_of_hire        in     date     default null
      ,p_town_of_birth                in     varchar2 default null
      ,p_region_of_birth              in     varchar2 default null
      ,p_country_of_birth             in     varchar2 default null
      ,p_global_person_id             in     varchar2 default null
      ,p_party_id                     in     number default null
      ,p_vacancy_id                   in     number default null
      ,p_person_id                       out nocopy number
      ,p_assignment_id                   out nocopy number
      ,p_application_id                  out nocopy number
      ,p_per_object_version_number       out nocopy number
      ,p_asg_object_version_number       out nocopy number
      ,p_apl_object_version_number       out nocopy number
      ,p_per_effective_start_date        out nocopy date
      ,p_per_effective_end_date          out nocopy date
      ,p_full_name                       out nocopy varchar2
      ,p_per_comment_id                  out nocopy number
      ,p_assignment_sequence             out nocopy number
      ,p_name_combination_warning        out nocopy boolean
      ,p_orig_hire_warning               out nocopy boolean
      ) AS

      l_proc_name varchar2(100);

BEGIN
      l_proc_name := g_proc_name || 'CREATE_MX_APPLICANT';
      hr_utility.trace('Entering '||l_proc_name);
      --
      hr_mx_utility.check_bus_grp (p_business_group_id, 'MX');
      --
      hr_applicant_api.create_applicant
            (p_validate                     => p_validate
            ,p_date_received                => p_date_received
            ,p_business_group_id            => p_business_group_id
            ,p_last_name                    => p_paternal_last_name
            ,p_person_type_id               => p_person_type_id
            ,p_applicant_number             => p_applicant_number
            ,p_per_comments                 => p_per_comments
            ,p_date_employee_data_verified  => p_date_employee_data_verified
            ,p_date_of_birth                => p_date_of_birth
            ,p_email_address                => p_email_address
            ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
            ,p_first_name                   => p_first_name
            ,p_known_as                     => p_known_as
            ,p_marital_status               => p_marital_status
            ,p_middle_names                 => p_second_name
            ,p_nationality                  => p_nationality
            ,p_national_identifier          => p_curp_id
            ,p_previous_last_name           => p_previous_last_name
            ,p_registered_disabled_flag     => p_registered_disabled_flag
            ,p_sex                          => p_sex
            ,p_title                        => p_title
            ,p_work_telephone               => p_work_telephone
            ,p_attribute_category           => p_attribute_category
            ,p_attribute1                   => p_attribute1
            ,p_attribute2                   => p_attribute2
            ,p_attribute3                   => p_attribute3
            ,p_attribute4                   => p_attribute4
            ,p_attribute5                   => p_attribute5
            ,p_attribute6                   => p_attribute6
            ,p_attribute7                   => p_attribute7
            ,p_attribute8                   => p_attribute8
            ,p_attribute9                   => p_attribute9
            ,p_attribute10                  => p_attribute10
            ,p_attribute11                  => p_attribute11
            ,p_attribute12                  => p_attribute12
            ,p_attribute13                  => p_attribute13
            ,p_attribute14                  => p_attribute14
            ,p_attribute15                  => p_attribute15
            ,p_attribute16                  => p_attribute16
            ,p_attribute17                  => p_attribute17
            ,p_attribute18                  => p_attribute18
            ,p_attribute19                  => p_attribute19
            ,p_attribute20                  => p_attribute20
            ,p_attribute21                  => p_attribute21
            ,p_attribute22                  => p_attribute22
            ,p_attribute23                  => p_attribute23
            ,p_attribute24                  => p_attribute24
            ,p_attribute25                  => p_attribute25
            ,p_attribute26                  => p_attribute26
            ,p_attribute27                  => p_attribute27
            ,p_attribute28                  => p_attribute28
            ,p_attribute29                  => p_attribute29
            ,p_attribute30                  => p_attribute30
            ,p_per_information_category     => 'MX'
            ,p_per_information1             => p_maternal_last_name
            ,p_per_information2             => p_rfc_id
            ,p_per_information3             => p_ss_id
            ,p_per_information4             => p_imss_med_center
            ,p_per_information5             => p_fed_gov_affil_id
            ,p_per_information6             => p_mil_serv_id
            ,p_background_check_status      => p_background_check_status
            ,p_background_date_check        => p_background_date_check
            ,p_correspondence_language      => p_correspondence_language
            ,p_fte_capacity                 => p_fte_capacity
            ,p_hold_applicant_date_until    => p_hold_applicant_date_until
            ,p_honors                       => p_honors
            ,p_mailstop                     => p_mailstop
            ,p_office_number                => p_office_number
            ,p_on_military_service          => p_on_military_service
            ,p_pre_name_adjunct             => p_pre_name_adjunct
            ,p_projected_start_date         => p_projected_start_date
            ,p_resume_exists                => p_resume_exists
            ,p_resume_last_updated          => p_resume_last_updated
            ,p_student_status               => p_student_status
            ,p_work_schedule                => p_work_schedule
            ,p_suffix                       => p_suffix
            ,p_date_of_death                => p_date_of_death
            ,p_benefit_group_id             => p_benefit_group_id
            ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
            ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
            ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
            ,p_uses_tobacco_flag            => p_uses_tobacco_flag
            ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
            ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
            ,p_original_date_of_hire        => p_original_date_of_hire
            ,p_town_of_birth                => p_town_of_birth
            ,p_region_of_birth              => p_region_of_birth
            ,p_country_of_birth             => p_country_of_birth
            ,p_global_person_id             => p_global_person_id
            ,p_party_id                     => p_party_id
            ,p_vacancy_id                   => p_vacancy_id
            -- OUT parameters
            ,p_person_id                    => p_person_id
            ,p_assignment_id                => p_assignment_id
            ,p_application_id               => p_application_id
            ,p_per_object_version_number    => p_per_object_version_number
            ,p_asg_object_version_number    => p_asg_object_version_number
            ,p_apl_object_version_number    => p_apl_object_version_number
            ,p_per_effective_start_date     => p_per_effective_start_date
            ,p_per_effective_end_date       => p_per_effective_end_date
            ,p_full_name                    => p_full_name
            ,p_per_comment_id               => p_per_comment_id
            ,p_assignment_sequence          => p_assignment_sequence
            ,p_name_combination_warning     => p_name_combination_warning
            ,p_orig_hire_warning            => p_orig_hire_warning
            );
      hr_utility.trace('Leaving '||l_proc_name);
END CREATE_MX_APPLICANT;


/*******************************************************************************
    Name    : hire_mx_applicant
    Purpose : This procedure acts as wrapper for hr_applicant_api.hire_applicant.
*******************************************************************************/

PROCEDURE HIRE_MX_APPLICANT
  (p_validate                  in     boolean default false,
   p_hire_date                 in     date,
   p_person_id                 in     per_all_people_f.person_id%TYPE,
   p_assignment_id             in     number default null,
   p_person_type_id            in     number default null,
   p_curp_id                   in     per_all_people_f.national_identifier%type default hr_api.g_varchar2,
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_employee_number           in out nocopy  per_all_people_f.employee_number%TYPE,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean,
   p_oversubscribed_vacancy_id    out nocopy  number,
   p_original_date_of_hire     in     date default null,
   p_migrate                   in     boolean default true
) AS
    l_proc_name varchar2(100);

BEGIN
      l_proc_name := g_proc_name || 'HIRE_MX_APPLICANT';
      hr_utility.trace('Entering '||l_proc_name);
      --
      hr_mx_utility.check_bus_grp (hr_mx_utility.get_bg_from_person(p_person_id), 'MX');
      --
      hr_applicant_api.hire_applicant
          (p_validate                  => p_validate,
           p_hire_date                 => p_hire_date,
           p_person_id                 => p_person_id,
           p_assignment_id             => p_assignment_id,
           p_person_type_id            => p_person_type_id,
           p_national_identifier       => p_curp_id,
           p_per_object_version_number => p_per_object_version_number,
           p_employee_number           => p_employee_number,
           p_per_effective_start_date  => p_per_effective_start_date,
           p_per_effective_end_date    => p_per_effective_end_date,
           p_unaccepted_asg_del_warning=> p_unaccepted_asg_del_warning,
           p_assign_payroll_warning    => p_assign_payroll_warning,
           p_oversubscribed_vacancy_id => p_oversubscribed_vacancy_id,
           p_original_date_of_hire     => p_original_date_of_hire,
           p_migrate                   => p_migrate);

      hr_utility.trace('Leaving '||l_proc_name);
END HIRE_MX_APPLICANT;

BEGIN
    g_proc_name := 'HR_MX_APPLICANT_API.';
END HR_MX_APPLICANT_API;

/
