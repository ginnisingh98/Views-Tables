--------------------------------------------------------
--  DDL for Package Body PER_MX_DISABILITY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MX_DISABILITY_API" AS
/* $Header: pemxwrda.pkb 120.0 2005/05/31 11:32:02 appldev noship $ */
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

    Name        : PER_MX_DISABILITY_API

    Description : This is Mexican wrapper package for per_disability_api.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    29-JUN-2004 sdahiya    115.0            Created.
    29-JUN-2004 sdahiya    115.1            Removed parameter p_deg_of_perm_disability
    08-JUL-2004 sdahiya    115.2            Enabled defaulting of p_registration_id
                                            parameter of update_mx_disability procedure.
    08-JUL-2004 sdahiya    115.3            Introduced business group check in create_mx_disability
                                            and update_mx_disability procedures.
  *****************************************************************************/

    g_proc_name varchar2 (100);

/*******************************************************************************
    Name    : create_mx_disability
    Purpose : This procedure acts as wrapper for per_disability_api.create_disability.
*******************************************************************************/

PROCEDURE CREATE_MX_DISABILITY
    (p_validate                      in     boolean  default false
    ,p_effective_date                in     date
    ,p_person_id                     in     number
    ,p_category                      in     varchar2
    ,p_status                        in     varchar2
    ,p_quota_fte                     in     number   default 1.00
    ,p_organization_id               in     number   default null
    ,p_registration_id               in     varchar2
    ,p_registration_date             in     date     default null
    ,p_registration_exp_date         in     date     default null
    ,p_description                   in     varchar2 default null
    ,p_degree                        in     number   default null
    ,p_reason                        in     varchar2 default null
    ,p_work_restriction              in     varchar2 default null
    ,p_incident_id                   in     number   default null
    ,p_medical_assessment_id         in     number   default null
    ,p_pre_registration_job          in     varchar2 default null
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
    ,p_related_disability_id         in     varchar2 default null
    ,p_disability_id                    out nocopy number
    ,p_object_version_number            out nocopy number
    ,p_effective_start_date             out nocopy date
    ,p_effective_end_date               out nocopy date
    ) AS

    l_proc_name varchar2(100);

BEGIN
    l_proc_name := g_proc_name ||'CREATE_MX_DISABILITY';
    hr_utility.trace('Entering '||l_proc_name);

    fnd_profile.put('PER_PERSON_ID',p_person_id);
    hr_mx_utility.check_bus_grp(hr_mx_utility.get_bg_from_person(p_person_id),'MX');

    per_disability_api.create_disability
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_person_id                     => p_person_id
    ,p_category                      => p_category
    ,p_status                        => p_status
    ,p_quota_fte                     => p_quota_fte
    ,p_organization_id               => p_organization_id
    ,p_registration_id               => p_registration_id
    ,p_registration_date             => p_registration_date
    ,p_registration_exp_date         => p_registration_exp_date
    ,p_description                   => p_description
    ,p_degree                        => p_degree
    ,p_reason                        => p_reason
    ,p_work_restriction              => p_work_restriction
    ,p_incident_id                   => p_incident_id
    ,p_medical_assessment_id         => p_medical_assessment_id
    ,p_pre_registration_job          => p_pre_registration_job
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
    ,p_dis_information_category      => 'MX'
    ,p_dis_information1              => p_related_disability_id
    -- OUT parameters
    ,p_disability_id                 => p_disability_id
    ,p_object_version_number         => p_object_version_number
    ,p_effective_start_date          => p_effective_start_date
    ,p_effective_end_date            => p_effective_end_date);

    hr_utility.trace('Leaving '||l_proc_name);
END CREATE_MX_DISABILITY;


/*******************************************************************************
    Name    : update_mx_disability
    Purpose : This procedure acts as wrapper for per_disability_api.update_disability
*******************************************************************************/

PROCEDURE UPDATE_MX_DISABILITY
    (p_validate                      in     boolean  default false
    ,p_effective_date                in     date
    ,p_datetrack_mode                in     varchar2
    ,p_disability_id                 in     number
    ,p_object_version_number         in out nocopy number
    ,p_category                      in     varchar2 default hr_api.g_varchar2
    ,p_status                        in     varchar2 default hr_api.g_varchar2
    ,p_quota_fte                     in     number   default hr_api.g_number
    ,p_organization_id               in     number   default hr_api.g_number
    ,p_registration_id               in     varchar2 default hr_api.g_varchar2
    ,p_registration_date             in     date     default hr_api.g_date
    ,p_registration_exp_date         in     date     default hr_api.g_date
    ,p_description                   in     varchar2 default hr_api.g_varchar2
    ,p_degree                        in     number   default hr_api.g_number
    ,p_reason                        in     varchar2 default hr_api.g_varchar2
    ,p_work_restriction              in     varchar2 default hr_api.g_varchar2
    ,p_incident_id                   in     number   default hr_api.g_number
    ,p_medical_assessment_id         in     number   default hr_api.g_number
    ,p_pre_registration_job          in     varchar2 default hr_api.g_varchar2
    ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
    ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
    ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
    ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
    ,p_related_disability_id         in     varchar2 default null
    ,p_effective_start_date             out nocopy date
    ,p_effective_end_date               out nocopy date) AS

    CURSOR csr_get_person_id IS
        SELECT person_id
          FROM per_disabilities_f
         WHERE disability_id = p_disability_id
           AND rownum < 2;

    l_proc_name varchar2(100);
    l_person_id per_disabilities_v.person_id%type;

BEGIN
    l_proc_name := g_proc_name ||'UPDATE_MX_DISABILITY';
    hr_utility.trace('Entering '||l_proc_name);

    OPEN csr_get_person_id;
        FETCH csr_get_person_id INTO l_person_id;
    CLOSE csr_get_person_id;

    fnd_profile.put('PER_PERSON_ID',l_person_id);
    hr_mx_utility.check_bus_grp(hr_mx_utility.get_bg_from_person(l_person_id),'MX');

    per_disability_api.update_disability
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_disability_id                 => p_disability_id
    ,p_object_version_number         => p_object_version_number
    ,p_category                      => p_category
    ,p_status                        => p_status
    ,p_quota_fte                     => p_quota_fte
    ,p_organization_id               => p_organization_id
    ,p_registration_id               => p_registration_id
    ,p_registration_date             => p_registration_date
    ,p_registration_exp_date         => p_registration_exp_date
    ,p_description                   => p_description
    ,p_degree                        => p_degree
    ,p_reason                        => p_reason
    ,p_work_restriction              => p_work_restriction
    ,p_incident_id                   => p_incident_id
    ,p_medical_assessment_id         => p_medical_assessment_id
    ,p_pre_registration_job          => p_pre_registration_job
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
    ,p_dis_information_category      => 'MX'
    ,p_dis_information1              => p_related_disability_id
    ,p_effective_start_date          => p_effective_start_date
    ,p_effective_end_date            => p_effective_end_date);

    hr_utility.trace('Leaving '||l_proc_name);
END UPDATE_MX_DISABILITY;

BEGIN
    g_proc_name := 'PER_MX_DISABILITY_API.';
END PER_MX_DISABILITY_API;

/
