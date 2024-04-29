--------------------------------------------------------
--  DDL for Package PER_ABSENCE_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABSENCE_RECORD" AUTHID CURRENT_USER AS
/* $Header: peabsqry.pkh 120.0.12010000.4 2009/01/22 09:44:06 srgnanas noship $ */
/*#
* This is the source file to query absence details
* @rep:scope public
* @rep:product per
* @rep:displayname PER_EMPLOYEE_ABSENCE
*/
TYPE absence_rectype IS RECORD
	(
	absence_attendance_id PER_ABSENCE_ATTENDANCES_V.absence_attendance_id%TYPE,
	business_group_id PER_ABSENCE_ATTENDANCES_V.business_group_id%TYPE,
	absence_attendance_type_id PER_ABSENCE_ATTENDANCES_V.absence_attendance_type_id%TYPE,
	abs_attendance_reason_id PER_ABSENCE_ATTENDANCES_V.abs_attendance_reason_id%TYPE,
	person_id PER_ABSENCE_ATTENDANCES_V.person_id%TYPE,
	authorising_person_id PER_ABSENCE_ATTENDANCES_V.authorising_person_id%TYPE,
	replacement_person_id PER_ABSENCE_ATTENDANCES_V.replacement_person_id%TYPE,
	period_of_incapacity_id PER_ABSENCE_ATTENDANCES_V.period_of_incapacity_id%TYPE,
	absence_days PER_ABSENCE_ATTENDANCES_V.absence_days%TYPE,
	absence_hours PER_ABSENCE_ATTENDANCES_V.absence_hours%TYPE,
	comments PER_ABSENCE_ATTENDANCES_V.comments%TYPE,
	date_end PER_ABSENCE_ATTENDANCES_V.date_end%TYPE,
	date_notification PER_ABSENCE_ATTENDANCES_V.date_notification%TYPE,
	date_projected_end PER_ABSENCE_ATTENDANCES_V.date_projected_end%TYPE,
	date_projected_start PER_ABSENCE_ATTENDANCES_V.date_projected_start%TYPE,
	date_start PER_ABSENCE_ATTENDANCES_V.date_start%TYPE,
	occurrence PER_ABSENCE_ATTENDANCES_V.occurrence%TYPE,
	ssp1_issued PER_ABSENCE_ATTENDANCES_V.ssp1_issued%TYPE,
	time_end PER_ABSENCE_ATTENDANCES_V.time_end%TYPE,
	time_projected_end PER_ABSENCE_ATTENDANCES_V.time_projected_end%TYPE,
	time_projected_start PER_ABSENCE_ATTENDANCES_V.time_projected_start%TYPE,
	time_start PER_ABSENCE_ATTENDANCES_V.time_start%TYPE,
	request_id PER_ABSENCE_ATTENDANCES_V.request_id%TYPE,
	program_application_id PER_ABSENCE_ATTENDANCES_V.program_application_id%TYPE,
	program_id PER_ABSENCE_ATTENDANCES_V.program_id%TYPE,
	program_update_date PER_ABSENCE_ATTENDANCES_V.program_update_date%TYPE,
	attribute_category PER_ABSENCE_ATTENDANCES_V.attribute_category%TYPE,
	attribute1 PER_ABSENCE_ATTENDANCES_V.attribute1%TYPE,
	attribute2 PER_ABSENCE_ATTENDANCES_V.attribute2%TYPE,
	attribute3 PER_ABSENCE_ATTENDANCES_V.attribute3%TYPE,
	attribute4 PER_ABSENCE_ATTENDANCES_V.attribute4%TYPE,
	attribute5 PER_ABSENCE_ATTENDANCES_V.attribute5%TYPE,
	attribute6 PER_ABSENCE_ATTENDANCES_V.attribute6%TYPE,
	attribute7 PER_ABSENCE_ATTENDANCES_V.attribute7%TYPE,
	attribute8 PER_ABSENCE_ATTENDANCES_V.attribute8%TYPE,
	attribute9 PER_ABSENCE_ATTENDANCES_V.attribute9%TYPE,
	attribute10 PER_ABSENCE_ATTENDANCES_V.attribute10%TYPE,
	attribute11 PER_ABSENCE_ATTENDANCES_V.attribute11%TYPE,
	attribute12 PER_ABSENCE_ATTENDANCES_V.attribute12%TYPE,
	attribute13 PER_ABSENCE_ATTENDANCES_V.attribute13%TYPE,
	attribute14 PER_ABSENCE_ATTENDANCES_V.attribute14%TYPE,
	attribute15 PER_ABSENCE_ATTENDANCES_V.attribute15%TYPE,
	attribute16 PER_ABSENCE_ATTENDANCES_V.attribute16%TYPE,
	attribute17 PER_ABSENCE_ATTENDANCES_V.attribute17%TYPE,
	attribute18 PER_ABSENCE_ATTENDANCES_V.attribute18%TYPE,
	attribute19 PER_ABSENCE_ATTENDANCES_V.attribute19%TYPE,
	attribute20 PER_ABSENCE_ATTENDANCES_V.attribute20%TYPE,
	last_update_date PER_ABSENCE_ATTENDANCES_V.last_update_date%TYPE,
	last_updated_by PER_ABSENCE_ATTENDANCES_V.last_updated_by%TYPE,
	last_update_login PER_ABSENCE_ATTENDANCES_V.last_update_login%TYPE,
	created_by PER_ABSENCE_ATTENDANCES_V.created_by%TYPE,
	creation_date PER_ABSENCE_ATTENDANCES_V.creation_date%TYPE,
	object_version_number PER_ABSENCE_ATTENDANCES_V.object_version_number%TYPE,
	c_type_desc PER_ABSENCE_ATTENDANCES_V.c_type_desc%TYPE,
	element_type_id PER_ABSENCE_ATTENDANCES_V.element_type_id%TYPE,
	absence_category PER_ABSENCE_ATTENDANCES_V.absence_category%TYPE,
	category_meaning PER_ABSENCE_ATTENDANCES_V.category_meaning%TYPE,
	hours_or_days PER_ABSENCE_ATTENDANCES_V.hours_or_days%TYPE,
	value_column PER_ABSENCE_ATTENDANCES_V.value_column%TYPE,
	increasing_or_decreasing PER_ABSENCE_ATTENDANCES_V.increasing_or_decreasing%TYPE,
	value_uom PER_ABSENCE_ATTENDANCES_V.value_uom%TYPE,
	c_abs_input_value_id PER_ABSENCE_ATTENDANCES_V.c_abs_input_value_id%TYPE,
	abs_date_from PER_ABSENCE_ATTENDANCES_V.abs_date_from%TYPE,
	abs_date_to PER_ABSENCE_ATTENDANCES_V.abs_date_to%TYPE,
	c_auth_name PER_ABSENCE_ATTENDANCES_V.c_auth_name%TYPE,
	c_auth_no PER_ABSENCE_ATTENDANCES_V.c_auth_no%TYPE,
	c_rep_name PER_ABSENCE_ATTENDANCES_V.c_rep_name%TYPE,
	c_rep_no PER_ABSENCE_ATTENDANCES_V.c_rep_no%TYPE,
	c_reason_desc PER_ABSENCE_ATTENDANCES_V.c_reason_desc%TYPE,
	linked_absence_id PER_ABSENCE_ATTENDANCES_V.linked_absence_id%TYPE,
	sickness_start_date PER_ABSENCE_ATTENDANCES_V.sickness_start_date%TYPE,
	sickness_end_date PER_ABSENCE_ATTENDANCES_V.sickness_end_date%TYPE,
	accept_late_notification_flag PER_ABSENCE_ATTENDANCES_V.accept_late_notification_flag%TYPE,
	reason_for_late_notification PER_ABSENCE_ATTENDANCES_V.reason_for_late_notification%TYPE,
	pregnancy_related_illness PER_ABSENCE_ATTENDANCES_V.pregnancy_related_illness%TYPE,
	maternity_id PER_ABSENCE_ATTENDANCES_V.maternity_id%TYPE,
	smp_due_date PER_ABSENCE_ATTENDANCES_V.smp_due_date%TYPE,
	abs_information_category PER_ABSENCE_ATTENDANCES_V.abs_information_category%TYPE,
	abs_information1 PER_ABSENCE_ATTENDANCES_V.abs_information1%TYPE,
	abs_information2 PER_ABSENCE_ATTENDANCES_V.abs_information2%TYPE,
	abs_information3 PER_ABSENCE_ATTENDANCES_V.abs_information3%TYPE,
	abs_information4 PER_ABSENCE_ATTENDANCES_V.abs_information4%TYPE,
	abs_information5 PER_ABSENCE_ATTENDANCES_V.abs_information5%TYPE,
	abs_information6 PER_ABSENCE_ATTENDANCES_V.abs_information6%TYPE,
	abs_information7 PER_ABSENCE_ATTENDANCES_V.abs_information7%TYPE,
	abs_information8 PER_ABSENCE_ATTENDANCES_V.abs_information8%TYPE,
	abs_information9 PER_ABSENCE_ATTENDANCES_V.abs_information9%TYPE,
	abs_information10 PER_ABSENCE_ATTENDANCES_V.abs_information10%TYPE,
	abs_information11 PER_ABSENCE_ATTENDANCES_V.abs_information11%TYPE,
	abs_information12 PER_ABSENCE_ATTENDANCES_V.abs_information12%TYPE,
	abs_information13 PER_ABSENCE_ATTENDANCES_V.abs_information13%TYPE,
	abs_information14 PER_ABSENCE_ATTENDANCES_V.abs_information14%TYPE,
	abs_information15 PER_ABSENCE_ATTENDANCES_V.abs_information15%TYPE,
	abs_information16 PER_ABSENCE_ATTENDANCES_V.abs_information16%TYPE,
	abs_information17 PER_ABSENCE_ATTENDANCES_V.abs_information17%TYPE,
	abs_information18 PER_ABSENCE_ATTENDANCES_V.abs_information18%TYPE,
	abs_information19 PER_ABSENCE_ATTENDANCES_V.abs_information19%TYPE,
	abs_information20 PER_ABSENCE_ATTENDANCES_V.abs_information20%TYPE,
	abs_information21 PER_ABSENCE_ATTENDANCES_V.abs_information21%TYPE,
	abs_information22 PER_ABSENCE_ATTENDANCES_V.abs_information22%TYPE,
	abs_information23 PER_ABSENCE_ATTENDANCES_V.abs_information23%TYPE,
	abs_information24 PER_ABSENCE_ATTENDANCES_V.abs_information24%TYPE,
	abs_information25 PER_ABSENCE_ATTENDANCES_V.abs_information25%TYPE,
	abs_information26 PER_ABSENCE_ATTENDANCES_V.abs_information26%TYPE,
	abs_information27 PER_ABSENCE_ATTENDANCES_V.abs_information27%TYPE,
	abs_information28 PER_ABSENCE_ATTENDANCES_V.abs_information28%TYPE,
	abs_information29 PER_ABSENCE_ATTENDANCES_V.abs_information29%TYPE,
	abs_information30 PER_ABSENCE_ATTENDANCES_V.abs_information30%TYPE,
	approval_status PER_ABSENCE_ATTENDANCES_V.approval_status%TYPE,
	confirmed_until PER_ABSENCE_ATTENDANCES_V.confirmed_until%TYPE,
	source PER_ABSENCE_ATTENDANCES_V.source%TYPE,
	advance_pay PER_ABSENCE_ATTENDANCES_V.advance_pay%TYPE,
	absence_case_id PER_ABSENCE_ATTENDANCES_V.absence_case_id%TYPE
	);

TYPE absence_tabletype IS TABLE OF absence_rectype NOT NULL;

TYPE    absence_input_rectype IS RECORD
    (
        person_id                     PER_ABSENCE_ATTENDANCES_V.person_id%TYPE    DEFAULT NULL,
        start_person_id               PER_ABSENCE_ATTENDANCES_V.person_id%TYPE    DEFAULT NULL,
        end_person_id                 PER_ABSENCE_ATTENDANCES_V.person_id%TYPE    DEFAULT NULL,
        absence_attendance_id         PER_ABSENCE_ATTENDANCES_V.absence_attendance_id%TYPE DEFAULT NULL
    );

/*#
* This is procedure for querying absence details.
* @rep:displayname Get Absence Details
* @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
* @rep:scope public
* @rep:lifecycle active
*/
PROCEDURE get_absence_details( p_query_options  IN  absence_input_rectype,
                               p_absences       OUT NOCOPY absence_tabletype);
END per_absence_record;

/
