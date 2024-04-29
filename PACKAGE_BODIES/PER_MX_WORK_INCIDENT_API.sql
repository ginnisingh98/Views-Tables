--------------------------------------------------------
--  DDL for Package Body PER_MX_WORK_INCIDENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MX_WORK_INCIDENT_API" AS
/* $Header: pemxwrwi.pkb 120.0 2005/05/31 11:37:36 appldev noship $ */
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

    Name        : PER_MX_WORK_INCIDENT_API

    Description : This is Mexican wrapper package for per_work_incident_api.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    29-JUN-2004 sdahiya    115.0            Created.
    08-JUL-2004 sdahiya    115.1            Added business group check in create_mx_work_incident
                                            and update_mx_work_incident.
  *****************************************************************************/

    g_proc_name varchar2 (50);
/*******************************************************************************
    Name    : create_mx_work_incident
    Purpose : This procedure acts as wrapper for per_work_incident_api.create_work_incident.
*******************************************************************************/

PROCEDURE CREATE_MX_WORK_INCIDENT
    (p_validate                      in     boolean  default false
    ,p_effective_date                in     date
    ,p_person_id                     in     number
    ,p_incident_reference            in     varchar2
    ,p_incident_type                 in     varchar2
    ,p_at_work_flag                  in     varchar2
    ,p_incident_date                 in     date
    ,p_incident_time                 in     varchar2 default null
    ,p_org_notified_date             in     date     default null
    ,p_assignment_id                 in     number   default null
    ,p_location                      in     varchar2 default null
    ,p_report_date                   in     date     default null
    ,p_report_time                   in     varchar2 default null
    ,p_report_method                 in     varchar2 default null
    ,p_person_reported_by            in     number   default null
    ,p_person_reported_to            in     varchar2 default null
    ,p_witness_details               in     varchar2 default null
    ,p_description                   in     varchar2 default null
    ,p_injury_type                   in     varchar2 default null
    ,p_disease_type                  in     varchar2 default null
    ,p_hazard_type                   in     varchar2 default null
    ,p_body_part                     in     varchar2 default null
    ,p_treatment_received_flag       in     varchar2 default null
    ,p_hospital_details              in     varchar2 default null
    ,p_emergency_code                in     varchar2 default null
    ,p_hospitalized_flag             in     varchar2 default null
    ,p_hospital_address              in     varchar2 default null
    ,p_activity_at_time_of_work      in     varchar2 default null
    ,p_objects_involved              in     varchar2 default null
    ,p_privacy_issue                 in     varchar2 default null
    ,p_work_start_time               in     varchar2 default null
    ,p_date_of_death                 in     date     default null
    ,p_report_completed_by           in     varchar2 default null
    ,p_reporting_person_title        in     varchar2 default null
    ,p_reporting_person_phone        in     varchar2 default null
    ,p_days_restricted_work          in     number   default null
    ,p_days_away_from_work           in     number   default null
    ,p_doctor_name                   in     varchar2 default null
    ,p_compensation_date             in     date     default null
    ,p_compensation_currency         in     varchar2 default null
    ,p_compensation_amount           in     number   default null
    ,p_remedial_hs_action            in     varchar2 default null
    ,p_notified_hsrep_id             in     number   default null
    ,p_notified_hsrep_date           in     date     default null
    ,p_notified_rep_id               in     number   default null
    ,p_notified_rep_date             in     date     default null
    ,p_notified_rep_org_id           in     number   default null
    ,p_related_incident_id           in     number   default null
    ,p_over_time_flag                in     varchar2 default null
    ,p_absence_exists_flag           in     varchar2 default null
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
    ,p_type_of_risk                  in     varchar2 default null
    ,p_incident_id                   out nocopy number
    ,p_object_version_number         out nocopy number
    ) AS

    l_proc_name varchar2(100);

BEGIN
    l_proc_name := g_proc_name||'CREATE_MX_WORK_INCIDENT';
    hr_utility.trace('Entering '||l_proc_name);

    --
    hr_mx_utility.check_bus_grp(hr_mx_utility.get_bg_from_person(p_person_id),'MX');
    --

    per_work_incident_api.create_work_incident
        (p_validate                      => p_validate
        ,p_effective_date                => p_effective_date
        ,p_person_id                     => p_person_id
        ,p_incident_reference            => p_incident_reference
        ,p_incident_type                 => p_incident_type
        ,p_at_work_flag                  => p_at_work_flag
        ,p_incident_date                 => p_incident_date
        ,p_incident_time                 => p_incident_time
        ,p_org_notified_date             => p_org_notified_date
        ,p_assignment_id                 => p_assignment_id
        ,p_location                      => p_location
        ,p_report_date                   => p_report_date
        ,p_report_time                   => p_report_time
        ,p_report_method                 => p_report_method
        ,p_person_reported_by            => p_person_reported_by
        ,p_person_reported_to            => p_person_reported_to
        ,p_witness_details               => p_witness_details
        ,p_description                   => p_description
        ,p_injury_type                   => p_injury_type
        ,p_disease_type                  => p_disease_type
        ,p_hazard_type                   => p_hazard_type
        ,p_body_part                     => p_body_part
        ,p_treatment_received_flag       => p_treatment_received_flag
        ,p_hospital_details              => p_hospital_details
        ,p_emergency_code                => p_emergency_code
        ,p_hospitalized_flag             => p_hospitalized_flag
        ,p_hospital_address              => p_hospital_address
        ,p_activity_at_time_of_work      => p_activity_at_time_of_work
        ,p_objects_involved              => p_objects_involved
        ,p_privacy_issue                 => p_privacy_issue
        ,p_work_start_time               => p_work_start_time
        ,p_date_of_death                 => p_date_of_death
        ,p_report_completed_by           => p_report_completed_by
        ,p_reporting_person_title        => p_reporting_person_title
        ,p_reporting_person_phone        => p_reporting_person_phone
        ,p_days_restricted_work          => p_days_restricted_work
        ,p_days_away_from_work           => p_days_away_from_work
        ,p_doctor_name                   => p_doctor_name
        ,p_compensation_date             => p_compensation_date
        ,p_compensation_currency         => p_compensation_currency
        ,p_compensation_amount           => p_compensation_amount
        ,p_remedial_hs_action            => p_remedial_hs_action
        ,p_notified_hsrep_id             => p_notified_hsrep_id
        ,p_notified_hsrep_date           => p_notified_hsrep_date
        ,p_notified_rep_id               => p_notified_rep_id
        ,p_notified_rep_date             => p_notified_rep_date
        ,p_notified_rep_org_id           => p_notified_rep_org_id
        ,p_related_incident_id           => p_related_incident_id
        ,p_over_time_flag                => p_over_time_flag
        ,p_absence_exists_flag           => p_absence_exists_flag
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
        ,p_inc_information_category      => 'MX'
        ,p_inc_information1              => p_type_of_risk
        ,p_incident_id                   => p_incident_id
        ,p_object_version_number         => p_object_version_number);

    hr_utility.trace('Leaving '||l_proc_name);
END CREATE_MX_WORK_INCIDENT;


/*******************************************************************************
    Name    : update_mx_work_incident
    Purpose : This procedure acts as wrapper for per_work_incident_api.create_work_incident.
*******************************************************************************/

PROCEDURE UPDATE_MX_WORK_INCIDENT
    (p_validate                      in     boolean  default false
    ,p_effective_date                in     date
    ,p_incident_id                   in     number
    ,p_object_version_number         in out nocopy number
    ,p_incident_reference            in     varchar2 default hr_api.g_varchar2
    ,p_incident_type                 in     varchar2 default hr_api.g_varchar2
    ,p_at_work_flag                  in     varchar2 default hr_api.g_varchar2
    ,p_incident_date                 in     date     default hr_api.g_date
    ,p_incident_time                 in     varchar2 default hr_api.g_varchar2
    ,p_org_notified_date             in     date     default hr_api.g_date
    ,p_assignment_id                 in     number   default hr_api.g_number
    ,p_location                      in     varchar2 default hr_api.g_varchar2
    ,p_report_date                   in     date     default hr_api.g_date
    ,p_report_time                   in     varchar2 default hr_api.g_varchar2
    ,p_report_method                 in     varchar2 default hr_api.g_varchar2
    ,p_person_reported_by            in     number   default hr_api.g_number
    ,p_person_reported_to            in     varchar2 default hr_api.g_varchar2
    ,p_witness_details               in     varchar2 default hr_api.g_varchar2
    ,p_description                   in     varchar2 default hr_api.g_varchar2
    ,p_injury_type                   in     varchar2 default hr_api.g_varchar2
    ,p_disease_type                  in     varchar2 default hr_api.g_varchar2
    ,p_hazard_type                   in     varchar2 default hr_api.g_varchar2
    ,p_body_part                     in     varchar2 default hr_api.g_varchar2
    ,p_treatment_received_flag       in     varchar2 default hr_api.g_varchar2
    ,p_hospital_details              in     varchar2 default hr_api.g_varchar2
    ,p_emergency_code                in     varchar2 default hr_api.g_varchar2
    ,p_hospitalized_flag             in     varchar2 default hr_api.g_varchar2
    ,p_hospital_address              in     varchar2 default hr_api.g_varchar2
    ,p_activity_at_time_of_work      in     varchar2 default hr_api.g_varchar2
    ,p_objects_involved              in     varchar2 default hr_api.g_varchar2
    ,p_privacy_issue                 in     varchar2 default hr_api.g_varchar2
    ,p_work_start_time               in     varchar2 default hr_api.g_varchar2
    ,p_date_of_death                 in     date     default hr_api.g_date
    ,p_report_completed_by           in     varchar2 default hr_api.g_varchar2
    ,p_reporting_person_title        in     varchar2 default hr_api.g_varchar2
    ,p_reporting_person_phone        in     varchar2 default hr_api.g_varchar2
    ,p_days_restricted_work          in     number   default hr_api.g_number
    ,p_days_away_from_work           in     number   default hr_api.g_number
    ,p_doctor_name                   in     varchar2 default hr_api.g_varchar2
    ,p_compensation_date             in     date     default hr_api.g_date
    ,p_compensation_currency         in     varchar2 default hr_api.g_varchar2
    ,p_compensation_amount           in     number   default hr_api.g_number
    ,p_remedial_hs_action            in     varchar2 default hr_api.g_varchar2
    ,p_notified_hsrep_id             in     number   default hr_api.g_number
    ,p_notified_hsrep_date           in     date     default hr_api.g_date
    ,p_notified_rep_id               in     number   default hr_api.g_number
    ,p_notified_rep_date             in     date     default hr_api.g_date
    ,p_notified_rep_org_id           in     number   default hr_api.g_number
    ,p_related_incident_id           in     number   default hr_api.g_number
    ,p_over_time_flag                in     varchar2 default hr_api.g_varchar2
    ,p_absence_exists_flag           in     varchar2 default hr_api.g_varchar2
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
    ,p_type_of_risk                  in     varchar2 default hr_api.g_varchar2) AS

    cursor c_get_person is
         select person_id
         from per_work_incidents
         where incident_id = p_incident_id;

    l_proc_name varchar2(100);
    l_person_id per_work_incidents.person_id%type;

BEGIN
    l_proc_name := g_proc_name||'UPDATE_MX_WORK_INCIDENT';
    hr_utility.trace('Entering '||l_proc_name);

    open c_get_person;
        fetch c_get_person into l_person_id;
    close c_get_person;

    hr_mx_utility.check_bus_grp (hr_mx_utility.get_bg_from_person(l_person_id),'MX');

    per_work_incident_api.update_work_incident
        (p_validate                      => p_validate
        ,p_effective_date                => p_effective_date
        ,p_incident_id                   => p_incident_id
        ,p_object_version_number         => p_object_version_number
        ,p_incident_reference            => p_incident_reference
        ,p_incident_type                 => p_incident_type
        ,p_at_work_flag                  => p_at_work_flag
        ,p_incident_date                 => p_incident_date
        ,p_incident_time                 => p_incident_time
        ,p_org_notified_date             => p_org_notified_date
        ,p_assignment_id                 => p_assignment_id
        ,p_location                      => p_location
        ,p_report_date                   => p_report_date
        ,p_report_time                   => p_report_time
        ,p_report_method                 => p_report_method
        ,p_person_reported_by            => p_person_reported_by
        ,p_person_reported_to            => p_person_reported_to
        ,p_witness_details               => p_witness_details
        ,p_description                   => p_description
        ,p_injury_type                   => p_injury_type
        ,p_disease_type                  => p_disease_type
        ,p_hazard_type                   => p_hazard_type
        ,p_body_part                     => p_body_part
        ,p_treatment_received_flag       => p_treatment_received_flag
        ,p_hospital_details              => p_hospital_details
        ,p_emergency_code                => p_emergency_code
        ,p_hospitalized_flag             => p_hospitalized_flag
        ,p_hospital_address              => p_hospital_address
        ,p_activity_at_time_of_work      => p_activity_at_time_of_work
        ,p_objects_involved              => p_objects_involved
        ,p_privacy_issue                 => p_privacy_issue
        ,p_work_start_time               => p_work_start_time
        ,p_date_of_death                 => p_date_of_death
        ,p_report_completed_by           => p_report_completed_by
        ,p_reporting_person_title        => p_reporting_person_title
        ,p_reporting_person_phone        => p_reporting_person_phone
        ,p_days_restricted_work          => p_days_restricted_work
        ,p_days_away_from_work           => p_days_away_from_work
        ,p_doctor_name                   => p_doctor_name
        ,p_compensation_date             => p_compensation_date
        ,p_compensation_currency         => p_compensation_currency
        ,p_compensation_amount           => p_compensation_amount
        ,p_remedial_hs_action            => p_remedial_hs_action
        ,p_notified_hsrep_id             => p_notified_hsrep_id
        ,p_notified_hsrep_date           => p_notified_hsrep_date
        ,p_notified_rep_id               => p_notified_rep_id
        ,p_notified_rep_date             => p_notified_rep_date
        ,p_notified_rep_org_id           => p_notified_rep_org_id
        ,p_related_incident_id           => p_related_incident_id
        ,p_over_time_flag                => p_over_time_flag
        ,p_absence_exists_flag           => p_absence_exists_flag
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
        ,p_inc_information_category      => 'MX'
        ,p_inc_information1              => p_type_of_risk);

    hr_utility.trace('Leaving '||l_proc_name);
END UPDATE_MX_WORK_INCIDENT;
BEGIN
    g_proc_name := 'PER_MX_WORK_INCIDENT_API.';
END PER_MX_WORK_INCIDENT_API;

/
