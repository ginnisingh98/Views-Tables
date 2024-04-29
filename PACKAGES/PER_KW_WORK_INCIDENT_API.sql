--------------------------------------------------------
--  DDL for Package PER_KW_WORK_INCIDENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KW_WORK_INCIDENT_API" AUTHID CURRENT_USER as
/* $Header: peinckwi.pkh 120.1 2005/10/02 02:42:07 aroussel $ */
/*#
 * This package contains APIs for work incidents for Kuwait.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Work Incidents for Kuwait
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_kw_work_incident >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a work incident record for a Kuwaiti person.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Person must exist.
 *
 * <p><b>Post Success</b><br>
 * The work incident record is successfully inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the work incident and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person for whom you create the work
 * incident record.
 * @param p_incident_reference Reference code for the incident record.
 * @param p_incident_type The type of work incident that is being recorded.
 * @param p_at_work_flag Indicates whether work incident occurred at work or en
 * route.
 * @param p_incident_date The date that the work incident occurred.
 * @param p_incident_time The time that the incident occurred. (HH24:MI).
 * @param p_org_notified_date The date that the organization was notified of
 * the work incident.
 * @param p_assignment_id Identifies the assignment for which you create the
 * work incident record.
 * @param p_location Location of incident (not an HRMS location).
 * @param p_report_date The date the incident was reported.
 * @param p_report_time The time the incident was reported. (HH24:MI).
 * @param p_report_method The method by which the incident was reported.
 * @param p_person_reported_by The id if the person who reported the work
 * incident to the authorities.
 * @param p_person_reported_to The name and contact details of the person (not
 * held on HRMS) representing the authority that the incident has been reported
 * to.
 * @param p_witness_details The name and contact details of any witnesses to
 * the work incident.
 * @param p_description Description of the work incident.
 * @param p_injury_type Type of injury suffered by the person in the work
 * incident.
 * @param p_disease_type Type of disease diagnosed as resulting from the work
 * incident.
 * @param p_hazard_type Object or substance involved in the work incident.
 * @param p_body_part Details of the injured or diseased area of the person's
 * anatomy.
 * @param p_treatment_received_flag Indicates if medical treatment has been
 * administered to the person.
 * @param p_hospital_details Name and contact details of the hospital where
 * treatment has been administered.
 * @param p_emergency_code Indicates whether admitted to an emergency room.
 * @param p_hospitalized_flag Indicates whether hospitalized.
 * @param p_hospital_address Address of the hospital.
 * @param p_activity_at_time_of_work Activity of the person at the time of the
 * incident.
 * @param p_objects_involved Objects or substances involved in the incident.
 * @param p_privacy_issue Indicates whether the incident is should be kept
 * private.
 * @param p_work_start_time Time the person started work (HH24:MI).
 * @param p_date_of_death Date of persons death.
 * @param p_report_completed_by Name of the person completing this incident
 * report.
 * @param p_reporting_person_title Title of the person completing this incident
 * report.
 * @param p_reporting_person_phone Phone number of the person completing this
 * incident report.
 * @param p_days_restricted_work Number of days the person is on restricted
 * work.
 * @param p_days_away_from_work Number of days the person is away from work or
 * on transfer.
 * @param p_doctor_name Name of the medical practitioner coordinating the
 * treatment of the person.
 * @param p_compensation_date Date compensation was awarded.
 * @param p_compensation_currency Currency (code) in which compensation was
 * awarded.
 * @param p_compensation_amount Amount of compensation awarded.
 * @param p_remedial_hs_action Description of any corrective action that has
 * been recommended by the health and safety representative.
 * @param p_notified_hsrep_id The person id of the health and safety
 * representative notified of the work incident.
 * @param p_notified_hsrep_date The date the health and safety representative
 * was notified.
 * @param p_notified_rep_id The id of the person who has been notified of the
 * work incident and who represents (by role) the representative body.
 * @param p_notified_rep_date The date the representative body representative
 * was notified.
 * @param p_notified_rep_org_id The id (organization) of the notified
 * representative body.
 * @param p_related_incident_id The id of the work incident that is related to
 * the current work incident.
 * @param p_over_time_flag Indicates if the incident occurred over a period of
 * time.
 * @param p_absence_exists_flag Indicates if person has been absent (not an
 * HRMS absence) due to the incident. over time.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_length_of_treatment Duration of any treatment as a result of the
 * work incident.
 * @param p_units Units of treatment duration.
 * @param p_incident_id If p_validate is false, uniquely identifies the work
 * incident created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, set to the version
 * number of this work incident. If p_validate is true, set to null.
 * @rep:displayname Create Work Incident for Kuwait
 * @rep:category BUSINESS_ENTITY PER_WORK_INCIDENT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_kw_work_incident
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
  ,p_length_of_treatment           in     varchar2 default null
  ,p_units                         in     varchar2 default null
  ,p_incident_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_kw_work_incident >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a work incident record for a person as identified by
 * p_incident_id.
 *
 * This API is an alternative to the API update_work_incident.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The work incident record identified by p_incident_id and
 * object_version_number must exist.
 *
 * <p><b>Post Success</b><br>
 * The work incident record is successfully updated in the database. The work
 * incident record is created and the API sets the following out
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the work incident record and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_incident_id Surrogate id of the incident record.
 * @param p_object_version_number If p_validate is false, set to the new
 * version number of this work incident. If p_validate is true, set to null
 * same value passed in.
 * @param p_incident_reference Reference code for the incident record.
 * @param p_incident_type The type of work incident that is being updated.
 * @param p_at_work_flag Indicates whether work incident occurred at work or en
 * route.
 * @param p_incident_date The date that the incident occurred.
 * @param p_incident_time The time that the incident occurred. (HH24:MI).
 * @param p_org_notified_date The date that the organization was notified of
 * the work incident.
 * @param p_assignment_id Identifies the assignment for which you create the
 * work incident record.
 * @param p_location Location of incident (not an HRMS location).
 * @param p_report_date The date the incident was reported.
 * @param p_report_time The time the incident was reported. (HH24:MI).
 * @param p_report_method The method by which the incident was reported.
 * @param p_person_reported_by The id if the person who reported the work
 * incident to the authorities.
 * @param p_person_reported_to The name and contact details of the person (not
 * held on HRMS) representing the authority that the incident has been reported
 * to.
 * @param p_witness_details The name and contact details of any witnesses to
 * the work incident.
 * @param p_description Description of the work incident.
 * @param p_injury_type Type of injury suffered by the person in the work
 * incident.
 * @param p_disease_type Type of disease diagnosed as resulting from the work
 * incident.
 * @param p_hazard_type Object or substance involved in the work incident.
 * @param p_body_part Details of the injured or diseased area of the person's
 * anatomy.
 * @param p_treatment_received_flag Indicates if medical treatment has been
 * administered to the person.
 * @param p_hospital_details Name and contact details of the hospital where
 * treatment has been administered.
 * @param p_emergency_code Indicates whether admitted to an emergency room.
 * @param p_hospitalized_flag Indicates whether hospitalized.
 * @param p_hospital_address Address of the hospital.
 * @param p_activity_at_time_of_work Activity of the person at the time of the
 * incident.
 * @param p_objects_involved Objects or substances involved in the incident.
 * @param p_privacy_issue Indicates whether the incident is should be kept
 * private.
 * @param p_work_start_time Time the person started work (HH24:MI).
 * @param p_date_of_death Date of persons death.
 * @param p_report_completed_by Name of the person completing this incident
 * report.
 * @param p_reporting_person_title Title of the person completing this incident
 * report.
 * @param p_reporting_person_phone Phone number of the person completing this
 * incident report.
 * @param p_days_restricted_work Number of days the person is on restricted
 * work.
 * @param p_days_away_from_work Number of days the person is away from work or
 * on transfer.
 * @param p_doctor_name Name of the medical practitioner coordinating the
 * treatment of the person.
 * @param p_compensation_date Date compensation was awarded.
 * @param p_compensation_currency Currency (code) in which compensation was
 * awarded.
 * @param p_compensation_amount Amount of compensation awarded.
 * @param p_remedial_hs_action Description of any corrective action that has
 * been recommended by the health and safety representative.
 * @param p_notified_hsrep_id The person id of the health and safety
 * representative notified of the work incident.
 * @param p_notified_hsrep_date The date the health and safety representative
 * was notified.
 * @param p_notified_rep_id The id of the person who has been notified of the
 * work incident and who represents (by role) the representative body.
 * @param p_notified_rep_date The date the representative body representative
 * was notified.
 * @param p_notified_rep_org_id The id (organization) of the notified
 * representative body.
 * @param p_related_incident_id The id of the work incident that is related to
 * the current work incident.
 * @param p_over_time_flag Indicates if the medical condition (injury or
 * disease) occurred over a period of time.
 * @param p_absence_exists_flag Indicates if person has been absent (not an
 * HRMS absence) due to the incident.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_length_of_treatment Duration of any treatment as a result of the
 * work incident.
 * @param p_units Units of treatment duration.
 * @rep:displayname Update Work Incident for Kuwait
 * @rep:category BUSINESS_ENTITY PER_WORK_INCIDENT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_kw_work_incident
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
  ,p_length_of_treatment           in     varchar2 default hr_api.g_varchar2
  ,p_units                         in     varchar2 default hr_api.g_varchar2
  );

end per_kw_work_incident_api;

 

/
