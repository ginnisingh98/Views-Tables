--------------------------------------------------------
--  DDL for Package Body HR_MX_CONTACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MX_CONTACT_API" AS
/* $Header: hrmxwrca.pkb 120.0 2005/05/31 01:31:02 appldev noship $ */
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

    Name        : HR_MX_CONTACT_API

    Description : This is Mexican wrapper package for hr_contact_api.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    28-JUN-2004 sdahiya    115.0            Created.
    07-JUL-2004 ardsouza   115.1   3695738  Made First Name non-mandatory
  *****************************************************************************/

    g_proc_name varchar2 (50);
/*******************************************************************************
    Name    : create_mx_person
    Purpose : This procedure acts as wrapper for hr_contact_api.create_person.
*******************************************************************************/

PROCEDURE CREATE_MX_PERSON
    (p_validate                      in     boolean  default false
    ,p_start_date                    in     date
    ,p_business_group_id             in     number
    ,p_paternal_last_name            in     varchar2
    ,p_sex                           in     varchar2
    ,p_person_type_id                in     number   default null
    ,p_comments                      in     varchar2 default null
    ,p_date_employee_data_verified   in     date     default null
    ,p_date_of_birth                 in     date     default null
    ,p_email_address                 in     varchar2 default null
    ,p_expense_check_send_to_addres  in     varchar2 default null
    ,p_first_name                    in     varchar2 default null
    ,p_known_as                      in     varchar2 default null
    ,p_marital_status                in     varchar2 default null
    ,p_second_name                   in     varchar2 default null
    ,p_nationality                   in     varchar2 default null
    ,p_curp_id                       in     varchar2 default null
    ,p_previous_last_name            in     varchar2 default null
    ,p_registered_disabled_flag      in     varchar2 default null
    ,p_title                         in     varchar2 default null
    ,p_vendor_id                     in     number   default null
    ,p_work_telephone                in     varchar2 default null
    ,p_attribute_category            in     varchar2 default null
    ,p_attribute1                    in     varchar2 default null
    ,p_attribute2                    in     varchar2 default null
    ,p_attribute3                    in     varchar2 default null
    ,p_attribute4                    in     varchar2 default null
    ,p_attribute5                    in     varchar2 default null
    ,p_attribute6                    in     varchar2 default null
    ,p_attribute7                    in     varchar2 default null
    ,p_attribute8                    in     varchar2 default null
    ,p_attribute9                    in     varchar2 default null
    ,p_attribute10                   in     varchar2 default null
    ,p_attribute11                   in     varchar2 default null
    ,p_attribute12                   in     varchar2 default null
    ,p_attribute13                   in     varchar2 default null
    ,p_attribute14                   in     varchar2 default null
    ,p_attribute15                   in     varchar2 default null
    ,p_attribute16                   in     varchar2 default null
    ,p_attribute17                   in     varchar2 default null
    ,p_attribute18                   in     varchar2 default null
    ,p_attribute19                   in     varchar2 default null
    ,p_attribute20                   in     varchar2 default null
    ,p_attribute21                   in     varchar2 default null
    ,p_attribute22                   in     varchar2 default null
    ,p_attribute23                   in     varchar2 default null
    ,p_attribute24                   in     varchar2 default null
    ,p_attribute25                   in     varchar2 default null
    ,p_attribute26                   in     varchar2 default null
    ,p_attribute27                   in     varchar2 default null
    ,p_attribute28                   in     varchar2 default null
    ,p_attribute29                   in     varchar2 default null
    ,p_attribute30                   in     varchar2 default null
    ,p_maternal_last_name            in     varchar2 default null
    ,p_correspondence_language       in     varchar2 default null
    ,p_honors                        in     varchar2 default null
    ,p_benefit_group_id              in     number   default null
    ,p_on_military_service           in     varchar2 default null
    ,p_student_status                in     varchar2 default null
    ,p_uses_tobacco_flag             in     varchar2 default null
    ,p_coord_ben_no_cvg_flag         in     varchar2 default null
    ,p_pre_name_adjunct              in     varchar2 default null
    ,p_suffix                        in     varchar2 default null
    ,p_town_of_birth                 in     varchar2 default null
    ,p_region_of_birth               in     varchar2 default null
    ,p_country_of_birth              in     varchar2 default null
    ,p_global_person_id              in     varchar2 default null
    ,p_person_id                        out nocopy number
    ,p_object_version_number            out nocopy number
    ,p_effective_start_date             out nocopy date
    ,p_effective_end_date               out nocopy date
    ,p_full_name                        out nocopy varchar2
    ,p_comment_id                       out nocopy number
    ,p_name_combination_warning         out nocopy boolean
    ,p_orig_hire_warning                out nocopy boolean
    ) AS
BEGIN
    g_proc_name := 'HR_MX_CONTACT_API.CREATE_MX_PERSON';
    hr_utility.trace('Entering '||g_proc_name);
    --
    hr_mx_utility.check_bus_grp (p_business_group_id, 'MX');
    --
    hr_contact_api.create_person
    (p_validate                      => false
    ,p_start_date                    => p_start_date
    ,p_business_group_id             => p_business_group_id
    ,p_last_name                     => p_paternal_last_name
    ,p_sex                           => p_sex
    ,p_person_type_id                => p_person_type_id
    ,p_comments                      => p_comments
    ,p_date_employee_data_verified   => p_date_employee_data_verified
    ,p_date_of_birth                 => p_date_of_birth
    ,p_email_address                 => p_email_address
    ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
    ,p_first_name                    => p_first_name
    ,p_known_as                      => p_known_as
    ,p_marital_status                => p_marital_status
    ,p_middle_names                  => p_second_name
    ,p_nationality                   => p_nationality
    ,p_national_identifier           => p_curp_id
    ,p_previous_last_name            => p_previous_last_name
    ,p_registered_disabled_flag      => p_registered_disabled_flag
    ,p_title                         => p_title
    ,p_vendor_id                     => p_vendor_id
    ,p_work_telephone                => p_work_telephone
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_attribute21                   => p_attribute21
    ,p_attribute22                   => p_attribute22
    ,p_attribute23                   => p_attribute23
    ,p_attribute24                   => p_attribute24
    ,p_attribute25                   => p_attribute25
    ,p_attribute26                   => p_attribute26
    ,p_attribute27                   => p_attribute27
    ,p_attribute28                   => p_attribute28
    ,p_attribute29                   => p_attribute29
    ,p_attribute30                   => p_attribute30
    ,p_per_information1              => p_maternal_last_name
    ,p_correspondence_language       => p_correspondence_language
    ,p_honors                        => p_honors
    ,p_benefit_group_id              => p_benefit_group_id
    ,p_on_military_service           => p_on_military_service
    ,p_student_status                => p_student_status
    ,p_uses_tobacco_flag             => p_uses_tobacco_flag
    ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
    ,p_pre_name_adjunct              => p_pre_name_adjunct
    ,p_suffix                        => p_suffix
    ,p_town_of_birth                 => p_town_of_birth
    ,p_region_of_birth               => p_region_of_birth
    ,p_country_of_birth              => p_country_of_birth
    ,p_global_person_id              => p_global_person_id
    -- OUT parameters
    ,p_person_id                     => p_person_id
    ,p_object_version_number         => p_object_version_number
    ,p_effective_start_date          => p_effective_start_date
    ,p_effective_end_date            => p_effective_end_date
    ,p_full_name                     => p_full_name
    ,p_comment_id                    => p_comment_id
    ,p_name_combination_warning      => p_name_combination_warning
    ,p_orig_hire_warning             => p_orig_hire_warning);

    hr_utility.trace('Leaving '||g_proc_name);
END CREATE_MX_PERSON;

END HR_MX_CONTACT_API;

/
