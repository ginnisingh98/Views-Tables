--------------------------------------------------------
--  DDL for Package OTA_TRAINING_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TRAINING_RECORD" AUTHID CURRENT_USER AS
/* $Header: ottraqry.pkh 120.0.12010000.7 2009/05/05 07:45:01 dparthas noship $ */
/*#
* This is the source file to query certification and course details
* @rep:scope public
* @rep:product ota
* @rep:displayname OTA_TRAINING_RECORD
*/
TYPE cert_description_rectype IS RECORD
    (
        certification_id                ota_certifications_b.certification_id%TYPE,
        initial_completion_date         ota_certifications_b.initial_completion_date%TYPE,
        initial_completion_duration     ota_certifications_b.initial_completion_duration%TYPE,
        initial_compl_duration_units    ota_certifications_b.initial_compl_duration_units%TYPE,
        renewal_duration                ota_certifications_b.renewal_duration%TYPE,
        renewal_duration_units          ota_certifications_b.renewal_duration_units%TYPE,
        notify_days_before_expire       ota_certifications_b.notify_days_before_expire%TYPE,
        validity_duration               ota_certifications_b.validity_duration%TYPE,
        validity_duration_units         ota_certifications_b.validity_duration_units%TYPE,
        renewable_flag_code             ota_certifications_b.renewable_flag%TYPE,
        renewable_flag_meaning          hr_lookups.meaning%TYPE,
        start_date_active               ota_certifications_b.start_date_active%TYPE,
        end_date_active                 ota_certifications_b.end_date_active%TYPE,
        name                            ota_certifications_tl.name%TYPE,
        description                     ota_certifications_tl.description%TYPE,
        objectives                      ota_certifications_tl.objectives%TYPE,
        purpose                         ota_certifications_tl.purpose%TYPE,
        keywords                        ota_certifications_tl.keywords%TYPE,
        initial_period_comments         ota_certifications_tl.initial_period_comments%TYPE,
        renewal_period_comments         ota_certifications_tl.renewal_period_comments%TYPE,
        certification_status_code       ota_cert_enrollments.certification_status_code%TYPE,
        cert_status_meaning             hr_lookups.meaning%TYPE,
        period_status_code              ota_cert_prd_enrollments.period_status_code%TYPE,
        period_status_meaning           hr_lookups.meaning%TYPE,
        expiration_date                 ota_cert_enrollments.expiration_date%TYPE,
        earliest_enroll_date            ota_cert_enrollments.earliest_enroll_date%TYPE,
        cert_period_start_date          ota_cert_prd_enrollments.cert_period_start_date%TYPE,
        cert_period_end_date            ota_cert_prd_enrollments.cert_period_end_date%TYPE,
        cert_enrollment_id              ota_cert_enrollments.cert_enrollment_id%TYPE,
        cert_prd_enrollment_id          ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE,
        cre_completion_date             ota_cert_enrollments.completion_date%TYPE
    );

TYPE cert_comp_rectype IS RECORD(
        competence_id               per_competence_elements.competence_id%TYPE,
        competence_name             per_competences_tl.name%TYPE,
        proficiency_level_id        per_competence_elements.proficiency_level_id%TYPE,
        proficiency_level_name      varchar2(100),
        effective_date_from         per_competence_elements.effective_date_from%TYPE,
        effective_date_to           per_competence_elements.effective_date_to%TYPE,
        object_id                   per_competence_elements.object_id%TYPE,
        business_group_id           per_competence_elements.business_group_id%TYPE
    );

TYPE cert_component_rectype IS RECORD
    (
        cert_mbr_enrollment_id      ota_cert_mbr_enrollments.cert_mbr_enrollment_id%TYPE,
        activity_version_id         ota_activity_versions_vl.activity_version_id%TYPE,
        member_status_code          ota_cert_mbr_enrollments.member_status_code%TYPE,
        course_name                 ota_activity_versions_vl.version_name%TYPE,
        completion_date             ota_cert_mbr_enrollments.completion_date%TYPE,
        member_status_meaning       hr_lookups.meaning%TYPE,
        enrollment_details_icon     varchar2(100),
        version_code                ota_activity_versions_vl.version_code%TYPE,
        activity_version_name       ota_activity_versions_vl.version_name%TYPE,
        start_date                  ota_activity_versions_vl.start_date%TYPE,
        end_date                    ota_activity_versions_vl.end_date%TYPE,
        certification_member_id     ota_certification_members.certification_member_id%TYPE,
        member_sequence             ota_certification_members.member_sequence%TYPE,
        event_id                    ota_events.event_id%TYPE,
        perf_status                 ota_booking_status_types_tl.name%TYPE,
        cert_prd_enrollment_id      ota_cert_mbr_enrollments.cert_prd_enrollment_id%TYPE,
        cert_enrollment_id          ota_cert_enrollments.cert_enrollment_id%TYPE,
        certification_id            ota_cert_enrollments.certification_id%TYPE,
        site_address                varchar2(255),
        site_short_name             varchar2(255),
        fnd_user_name               varchar2(255),
        encoded_site_address        varchar2(32767),
        classroom_id                ota_events.offering_id%TYPE
    );

TYPE cert_competencies_tabletype IS TABLE OF cert_comp_rectype NOT NULL ;
TYPE components_tabletype IS TABLE OF cert_component_rectype NOT NULL ;


TYPE certification_rectype IS RECORD
    (
        cert_name                   ota_certifications_tl.name%TYPE,
        certification_id            ota_cert_enrollments.certification_id%TYPE,
        certification_status_code   ota_cert_enrollments.certification_status_code%TYPE,
        cert_status_meaning         varchar2(240),
        period_status_code          ota_cert_prd_enrollments.period_status_code%TYPE,
        period_status_meaning       hr_lookups.meaning%TYPE,
        cert_period_start_date      ota_cert_prd_enrollments.cert_period_start_date%TYPE,
        cert_period_end_date        ota_cert_prd_enrollments.cert_period_end_date%TYPE,
        cre_completion_date         ota_cert_prd_enrollments.completion_date%TYPE,
        person_id                   ota_cert_enrollments.person_id%TYPE,
        contact_id                  ota_cert_enrollments.contact_id%TYPE,
        cert_enrollment_id          ota_cert_enrollments.cert_enrollment_id%TYPE,
        cert_prd_enrollment_id      ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE,
        is_history_flag             ota_cert_enrollments.is_history_flag%TYPE,
        renewable_flag              ota_certifications_b.renewable_flag%TYPE,
        is_period_renewable         VARCHAR2(1),
        earliest_enroll_date        ota_cert_enrollments.earliest_enroll_date%TYPE,
        expiration_date             ota_cert_prd_enrollments.expiration_date%TYPE,
        start_date_active           ota_certifications_b.start_date_active%TYPE,
        end_date_active             ota_certifications_b.end_date_active%TYPE,
        cert_enrollment_id2         ota_cert_enrollments.cert_enrollment_id%TYPE,
        cert_description            cert_description_rectype,
        cert_competencies           cert_competencies_tabletype,
        cert_components             components_tabletype,
        event_action                VARCHAR2(50)
    );

TYPE certification_tabletype IS TABLE OF certification_rectype NOT NULL;

TYPE event_rectype IS RECORD
        (
        event_id OTA_EVENTS_V.event_id%TYPE,
        object_version_number OTA_EVENTS_V.object_version_number%TYPE,
        business_group_id OTA_EVENTS_V.business_group_id%TYPE,
        title OTA_EVENTS_V.title%TYPE,
        course_start_date OTA_EVENTS_V.course_start_date%TYPE,
        course_start_time OTA_EVENTS_V.course_start_time%TYPE,
        course_end_date OTA_EVENTS_V.course_end_date%TYPE,
        course_end_time OTA_EVENTS_V.course_end_time%TYPE,
        duration OTA_EVENTS_V.duration%TYPE,
        duration_units OTA_EVENTS_V.duration_units%TYPE,
        enrolment_start_date OTA_EVENTS_V.enrolment_start_date%TYPE,
        enrolment_end_date OTA_EVENTS_V.enrolment_end_date%TYPE,
        resource_booking_flag OTA_EVENTS_V.resource_booking_flag%TYPE,
        public_event_flag OTA_EVENTS_V.public_event_flag%TYPE,
        minimum_attendees OTA_EVENTS_V.minimum_attendees%TYPE,
        maximum_attendees OTA_EVENTS_V.maximum_attendees%TYPE,
        maximum_internal_attendees OTA_EVENTS_V.maximum_internal_attendees%TYPE,
        standard_price OTA_EVENTS_V.standard_price%TYPE,
        parent_event_id OTA_EVENTS_V.parent_event_id%TYPE,
        book_independent_flag OTA_EVENTS_V.book_independent_flag%TYPE,
        actual_cost OTA_EVENTS_V.actual_cost%TYPE,
        budget_cost OTA_EVENTS_V.budget_cost%TYPE,
        budget_currency_code OTA_EVENTS_V.budget_currency_code%TYPE,
        created_by OTA_EVENTS_V.created_by%TYPE,
        creation_date OTA_EVENTS_V.creation_date%TYPE,
        last_updated_by OTA_EVENTS_V.last_updated_by%TYPE,
        last_update_login OTA_EVENTS_V.last_update_login%TYPE,
        last_update_date OTA_EVENTS_V.last_update_date%TYPE,
        comments OTA_EVENTS_V.comments%TYPE,
        evt_information_category OTA_EVENTS_V.evt_information_category%TYPE,
        evt_information1 OTA_EVENTS_V.evt_information1%TYPE,
        evt_information2 OTA_EVENTS_V.evt_information2%TYPE,
        evt_information3 OTA_EVENTS_V.evt_information3%TYPE,
        evt_information4 OTA_EVENTS_V.evt_information4%TYPE,
        evt_information5 OTA_EVENTS_V.evt_information5%TYPE,
        evt_information6 OTA_EVENTS_V.evt_information6%TYPE,
        evt_information7 OTA_EVENTS_V.evt_information7%TYPE,
        evt_information8 OTA_EVENTS_V.evt_information8%TYPE,
        evt_information9 OTA_EVENTS_V.evt_information9%TYPE,
        evt_information10 OTA_EVENTS_V.evt_information10%TYPE,
        evt_information11 OTA_EVENTS_V.evt_information11%TYPE,
        evt_information12 OTA_EVENTS_V.evt_information12%TYPE,
        evt_information13 OTA_EVENTS_V.evt_information13%TYPE,
        evt_information14 OTA_EVENTS_V.evt_information14%TYPE,
        evt_information15 OTA_EVENTS_V.evt_information15%TYPE,
        evt_information16 OTA_EVENTS_V.evt_information16%TYPE,
        evt_information17 OTA_EVENTS_V.evt_information17%TYPE,
        evt_information18 OTA_EVENTS_V.evt_information18%TYPE,
        evt_information19 OTA_EVENTS_V.evt_information19%TYPE,
        evt_information20 OTA_EVENTS_V.evt_information20%TYPE,
        secure_event_flag OTA_EVENTS_V.secure_event_flag%TYPE,
        organization_id OTA_EVENTS_V.organization_id%TYPE,
        organization_name OTA_EVENTS_V.organization_name%TYPE,
        centre OTA_EVENTS_V.centre%TYPE,
        centre_meaning OTA_EVENTS_V.centre_meaning%TYPE,
        currency_code OTA_EVENTS_V.currency_code%TYPE,
        development_event_type OTA_EVENTS_V.development_event_type%TYPE,
        development_event_type_meaning OTA_EVENTS_V.development_event_type_meaning%TYPE,
        language_code OTA_EVENTS_V.language_code%TYPE,
        language_description OTA_EVENTS_V.language_description%TYPE,
        price_basis OTA_EVENTS_V.price_basis%TYPE,
        programme_code OTA_EVENTS_V.programme_code%TYPE,
        programme_code_meaning OTA_EVENTS_V.programme_code_meaning%TYPE,
        event_status OTA_EVENTS_V.event_status%TYPE,
        event_status_meaning OTA_EVENTS_V.event_status_meaning%TYPE,
        activity_name OTA_EVENTS_V.activity_name%TYPE,
        activity_version_id OTA_EVENTS_V.activity_version_id%TYPE,
        activity_version_name OTA_EVENTS_V.activity_version_name%TYPE,
        event_type OTA_EVENTS_V.event_type%TYPE,
        event_type_meaning OTA_EVENTS_V.event_type_meaning%TYPE,
        invoiced_amount OTA_EVENTS_V.invoiced_amount%TYPE,
        user_status OTA_EVENTS_V.user_status%TYPE,
        user_status_meaning OTA_EVENTS_V.user_status_meaning%TYPE,
        vendor_id OTA_EVENTS_V.vendor_id%TYPE,
        vendor_name OTA_EVENTS_V.vendor_name%TYPE,
        project_id OTA_EVENTS_V.project_id%TYPE,
        project_name OTA_EVENTS_V.project_name%TYPE,
        project_number OTA_EVENTS_V.project_number%TYPE,
        line_id OTA_EVENTS_V.line_id%TYPE,
        org_id OTA_EVENTS_V.org_id%TYPE,
        owner_id OTA_EVENTS_V.owner_id%TYPE,
        training_center_id OTA_EVENTS_V.training_center_id%TYPE,
        location_id OTA_EVENTS_V.location_id%TYPE,
        offering_id OTA_EVENTS_V.offering_id%TYPE,
        timezone OTA_EVENTS_V.timezone%TYPE,
        inventory_item_id OTA_EVENTS_V.inventory_item_id%TYPE,
        parent_offering_id OTA_EVENTS_V.parent_offering_id%TYPE,
        data_source OTA_EVENTS_V.data_source%TYPE
        );

TYPE event_tabletype IS TABLE OF event_rectype NOT NULL;

TYPE booking_rectype IS RECORD
    (
    delegate_person_id            ota_delegate_bookings.delegate_person_id%TYPE,
    status                        ota_booking_status_types_tl.name%TYPE,
    player_status                 hr_lookups.meaning%TYPE,
    booking_id                    ota_delegate_bookings.booking_id%TYPE,
    is_history_flag               ota_delegate_bookings.is_history_flag%TYPE,
    date_status_changed           ota_delegate_bookings.date_status_changed%TYPE,
    successful_attendance_flag    ota_delegate_bookings.successful_attendance_flag%TYPE,
    is_mandatory_enrollment       ota_delegate_bookings.is_mandatory_enrollment%TYPE
    );
TYPE activity_rectype IS RECORD
    (
        activity_version_id         ota_activity_versions_vl.activity_version_id%TYPE,
        activity_version_name       ota_activity_versions_vl.version_name%TYPE,
        activity_description        ota_activity_versions_vl.description%TYPE,
        activity_objectives         ota_activity_versions_vl.objectives%TYPE,
        activity_audience           ota_activity_versions_vl.intended_audience%TYPE,
        activity_keywords           ota_activity_versions_vl.keywords%TYPE,
        tav_information_category    ota_activity_versions_vl.tav_information_category%TYPE,
        tav_information1            ota_activity_versions_vl.tav_information1%TYPE,
        tav_information2            ota_activity_versions_vl.tav_information2%TYPE,
        tav_information3            ota_activity_versions_vl.tav_information3%TYPE,
        tav_information4            ota_activity_versions_vl.tav_information4%TYPE,
        tav_information5            ota_activity_versions_vl.tav_information5%TYPE,
        tav_information6            ota_activity_versions_vl.tav_information6%TYPE,
        tav_information7            ota_activity_versions_vl.tav_information7%TYPE,
        tav_information8            ota_activity_versions_vl.tav_information8%TYPE,
        tav_information9            ota_activity_versions_vl.tav_information9%TYPE,
        tav_information10           ota_activity_versions_vl.tav_information10%TYPE,
        tav_information11           ota_activity_versions_vl.tav_information11%TYPE,
        tav_information12           ota_activity_versions_vl.tav_information12%TYPE,
        tav_information13           ota_activity_versions_vl.tav_information13%TYPE,
        tav_information14           ota_activity_versions_vl.tav_information14%TYPE,
        tav_information15           ota_activity_versions_vl.tav_information15%TYPE,
        tav_information16           ota_activity_versions_vl.tav_information16%TYPE,
        tav_information17           ota_activity_versions_vl.tav_information17%TYPE,
        tav_information18           ota_activity_versions_vl.tav_information18%TYPE,
        tav_information19           ota_activity_versions_vl.tav_information19%TYPE,
        tav_information20           ota_activity_versions_vl.tav_information20%TYPE,
        activity_version_code       ota_activity_versions_vl.version_code%TYPE,
        success_criteria            hr_lookups.meaning%TYPE,
        professional_credits        ota_activity_versions_vl.professional_credits%TYPE,
        professional_credit_meaning hr_lookups.meaning%TYPE,
        controlling_person_id       ota_activity_versions.controlling_person_id%type,
        events                      event_tabletype,
        booking                     booking_rectype,
        event_action                VARCHAR2(50)
    );

TYPE activity_tabletype IS TABLE OF activity_rectype NOT NULL;

TYPE query_options IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;

TYPE cert_query_input_rectype IS RECORD
    (
        person_id                   ota_cert_enrollments.person_id%TYPE            DEFAULT NULL,
        start_person_id             ota_cert_enrollments.person_id%TYPE            DEFAULT NULL,
        end_person_id               ota_cert_enrollments.person_id%TYPE            DEFAULT NULL,
        certification_id            ota_certifications_b.certification_id%TYPE     DEFAULT NULL,
        cert_enrollment_id          ota_cert_enrollments.cert_enrollment_id%TYPE   DEFAULT NULL,
        view_history                BOOLEAN                                        DEFAULT FALSE,
        options                     query_options
    );

TYPE course_query_input_rectype IS RECORD
    (
        person_id                   ota_delegate_bookings.delegate_person_id%TYPE     DEFAULT NULL,
        start_person_id             ota_cert_enrollments.person_id%TYPE               DEFAULT NULL,
        end_person_id               ota_cert_enrollments.person_id%TYPE               DEFAULT NULL,
        course_id                   ota_activity_versions.activity_id%TYPE            DEFAULT NULL,
        delegate_booking_id         ota_delegate_bookings.booking_id%TYPE             DEFAULT NULL,
        view_history                BOOLEAN                                           DEFAULT FALSE,
        options                     query_options
    );
/*#
* This is procedure for querying certificate details.
* @rep:displayname Get Certification Details
* @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
* @rep:scope public
* @rep:lifecycle active
*/
PROCEDURE get_certification_details(  p_query_options               IN   cert_query_input_rectype,
                                      p_certifications              OUT NOCOPY certification_tabletype);
/*#
* This is procedure for querying course details.
* @rep:displayname Get Training Details
* @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
* @rep:scope public
* @rep:lifecycle active
*/
PROCEDURE get_training_details(p_query_options               IN   course_query_input_rectype,
                               p_training                    OUT NOCOPY activity_tabletype,
                               p_certifications              OUT NOCOPY certification_tabletype,
                               p_ispartofcertification       OUT NOCOPY BOOLEAN);

invalid_cert_enrollment_id  EXCEPTION;
invalid_delegate_booking_id EXCEPTION;
invalid_course_id           EXCEPTION;
invalid_person_id           EXCEPTION;
invalid_certification_id    EXCEPTION;
END ota_training_record;

/
