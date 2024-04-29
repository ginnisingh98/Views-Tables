--------------------------------------------------------
--  DDL for Package Body PER_ABSENCE_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABSENCE_RECORD" AS
/* $Header: peabsqry.pkb 120.0.12010000.4 2009/01/22 09:44:27 srgnanas noship $ */
PROCEDURE get_absence_details( p_query_options  IN  absence_input_rectype,
                               p_absences       OUT NOCOPY absence_tabletype)
IS
CURSOR  cur_absence(p_person_id                   PER_ABSENCE_ATTENDANCES_V.person_id%TYPE,
                    p_start_person_id             PER_ABSENCE_ATTENDANCES_V.person_id%TYPE,
                    p_end_person_id               PER_ABSENCE_ATTENDANCES_V.person_id%TYPE,
                    p_absence_attendance_id       PER_ABSENCE_ATTENDANCES_V.absence_attendance_id%TYPE) IS
SELECT  a.absence_attendance_id,
        a.business_group_id,
        a.absence_attendance_type_id,
        a.abs_attendance_reason_id,
        a.person_id,
        a.authorising_person_id,
        a.replacement_person_id,
        a.period_of_incapacity_id,
        a.absence_days,
        a.absence_hours,
        a.comments,
        a.date_end,
        a.date_notification,
        a.date_projected_end,
        a.date_projected_start,
        a.date_start,
        a.occurrence,
        a.ssp1_issued,
        a.time_end,
        a.time_projected_end,
        a.time_projected_start,
        a.time_start,
        a.request_id,
        a.program_application_id,
        a.program_id,
        a.program_update_date,
        a.attribute_category,
        a.attribute1,
        a.attribute2,
        a.attribute3,
        a.attribute4,
        a.attribute5,
        a.attribute6,
        a.attribute7,
        a.attribute8,
        a.attribute9,
        a.attribute10,
        a.attribute11,
        a.attribute12,
        a.attribute13,
        a.attribute14,
        a.attribute15,
        a.attribute16,
        a.attribute17,
        a.attribute18,
        a.attribute19,
        a.attribute20,
        a.last_update_date,
        a.last_updated_by,
        a.last_update_login,
        a.created_by,
        a.creation_date,
        a.object_version_number,
        a.c_type_desc,
        a.element_type_id,
        a.absence_category,
        a.category_meaning,
        a.hours_or_days,
        a.value_column,
        a.increasing_or_decreasing,
        a.value_uom,
        a.c_abs_input_value_id,
        a.abs_date_from,
        a.abs_date_to,
        a.c_auth_name,
        a.c_auth_no,
        a.c_rep_name,
        a.c_rep_no,
        a.c_reason_desc,
        a.linked_absence_id,
        a.sickness_start_date,
        a.sickness_end_date,
        a.accept_late_notification_flag,
        a.reason_for_late_notification,
        a.pregnancy_related_illness,
        a.maternity_id,
        a.smp_due_date,
        a.abs_information_category,
        a.abs_information1,
        a.abs_information2,
        a.abs_information3,
        a.abs_information4,
        a.abs_information5,
        a.abs_information6,
        a.abs_information7,
        a.abs_information8,
        a.abs_information9,
        a.abs_information10,
        a.abs_information11,
        a.abs_information12,
        a.abs_information13,
        a.abs_information14,
        a.abs_information15,
        a.abs_information16,
        a.abs_information17,
        a.abs_information18,
        a.abs_information19,
        a.abs_information20,
        a.abs_information21,
        a.abs_information22,
        a.abs_information23,
        a.abs_information24,
        a.abs_information25,
        a.abs_information26,
        a.abs_information27,
        a.abs_information28,
        a.abs_information29,
        a.abs_information30,
        a.approval_status,
        a.confirmed_until,
        a.source,
        a.advance_pay,
        a.absence_case_id
FROM    PER_ABSENCE_ATTENDANCES_V a
WHERE   nvl(p_person_id, a.person_id) = a.person_id
AND     a.person_id BETWEEN nvl(p_start_person_id, a.person_id)
        AND  nvl(p_end_person_id, a.person_id)
AND     nvl(p_absence_attendance_id, a.absence_attendance_id) = a.absence_attendance_id;

l_absence_rec   absence_rectype;
l_absence_tbl   absence_tabletype;
l_count         NUMBER := 1;
BEGIN
    l_absence_tbl := absence_tabletype();
    OPEN    cur_absence( p_query_options.person_id,
                         p_query_options.start_person_id,
                         p_query_options.end_person_id,
                         p_query_options.absence_attendance_id);
    LOOP
        FETCH   cur_absence INTO l_absence_rec;
        IF cur_absence%NOTFOUND THEN
            EXIT;
        END IF;
        l_absence_tbl.EXTEND(1);
        l_absence_tbl(l_count) := l_absence_rec;
        l_count := l_count + 1;
    END LOOP;
    p_absences := l_absence_tbl;
END get_absence_details;
END per_absence_record;

/
