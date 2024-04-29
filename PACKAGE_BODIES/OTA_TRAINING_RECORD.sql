--------------------------------------------------------
--  DDL for Package Body OTA_TRAINING_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TRAINING_RECORD" AS
/* $Header: ottraqry.pkb 120.0.12010000.10 2009/05/05 07:50:41 dparthas noship $ */
FUNCTION is_required(p_options query_options,
                     p_option_value   VARCHAR2) RETURN BOOLEAN
IS
BEGIN
    IF p_options.COUNT > 0 THEN
        FOR i IN p_options.FIRST..p_options.LAST LOOP
            IF p_options(i) = p_option_value THEN
                RETURN TRUE;
            END IF;
        END LOOP;
    END IF;
    RETURN FALSE;
END is_required;

PROCEDURE get_events(p_event_id              IN  ota_events_v.event_id%TYPE,
                     p_activity_version_id   IN  ota_activity_versions_vl.activity_version_id%TYPE,
                     p_events_tbl            OUT NOCOPY event_tabletype)
IS
CURSOR  cur_event IS
SELECT  event_id,
        object_version_number,
        business_group_id,
        title,
        course_start_date,
        course_start_time,
        course_end_date,
        course_end_time,
        duration,
        duration_units,
        enrolment_start_date,
        enrolment_end_date,
        resource_booking_flag,
        public_event_flag,
        minimum_attendees,
        maximum_attendees,
        maximum_internal_attendees,
        standard_price,
        parent_event_id,
        book_independent_flag,
        actual_cost,
        budget_cost,
        budget_currency_code,
        created_by,
        creation_date,
        last_updated_by,
        last_update_login,
        last_update_date,
        comments,
        evt_information_category,
        evt_information1,
        evt_information2,
        evt_information3,
        evt_information4,
        evt_information5,
        evt_information6,
        evt_information7,
        evt_information8,
        evt_information9,
        evt_information10,
        evt_information11,
        evt_information12,
        evt_information13,
        evt_information14,
        evt_information15,
        evt_information16,
        evt_information17,
        evt_information18,
        evt_information19,
        evt_information20,
        secure_event_flag,
        organization_id,
        organization_name,
        centre,
        centre_meaning,
        currency_code,
        development_event_type,
        development_event_type_meaning,
        language_code,
        language_description,
        price_basis,
        programme_code,
        programme_code_meaning,
        event_status,
        event_status_meaning,
        activity_name,
        activity_version_id,
        activity_version_name,
        event_type,
        event_type_meaning,
        invoiced_amount,
        user_status,
        user_status_meaning,
        vendor_id,
        vendor_name,
        project_id,
        project_name,
        project_number,
        line_id,
        org_id,
        owner_id,
        training_center_id,
        location_id,
        offering_id,
        timezone,
        inventory_item_id,
        parent_offering_id,
        data_source
FROM    OTA_EVENTS_V
WHERE   ((p_event_id IS NULL) OR (p_event_id IS NOT NULL AND event_id = p_event_id))
AND     ((p_activity_version_id IS NULL) OR (p_activity_version_id IS NOT NULL AND activity_version_id = p_activity_version_id));

l_event_rec     event_rectype;
l_events_tbl    event_tabletype;
l_count         NUMBER := 1;
BEGIN
    l_events_tbl := event_tabletype();
    OPEN    cur_event;
    LOOP
        FETCH   cur_event INTO l_event_rec;
        IF cur_event%NOTFOUND THEN
            EXIT;
        END IF;

        l_events_tbl.EXTEND(1);
        l_events_tbl(l_count) := l_event_rec;
        l_count := l_count + 1;
    END LOOP;
    CLOSE   cur_event;
    p_events_tbl := l_events_tbl;
END get_events;

PROCEDURE get_completed_certifications(p_start_person_id     IN  ota_cert_enrollments.person_id%TYPE
                                      ,p_end_person_id       IN  ota_cert_enrollments.person_id%TYPE
                                      ,p_certification_tbl    OUT NOCOPY certification_tabletype)
IS
CURSOR  get_certification IS
    SELECT ctl.name cert_name,
                    cre.certification_id certification_id,
                    cre.certification_status_code certification_status_code,
                    ota_cpe_util.get_cre_status(cre.cert_enrollment_id) cert_status_meaning,
                    cpe.period_status_code period_status_code,
                    cpe_lkp.meaning period_status_meaning,
                    cpe.cert_period_start_date cert_period_start_date,
                    decode(cre.certification_status_code,'CERTIFIED', decode(crt.renewable_flag,'Y',cre.expiration_date,null), cpe.cert_period_end_date) cert_period_end_date,
                    cpe.completion_date cre_completion_date,
                    cre.person_id person_id,
                    cre.contact_id contact_id,
                    cre.cert_enrollment_id,
                    cpe.cert_prd_enrollment_id,
                    cre.is_history_flag,
                    crt.renewable_flag,
                    ota_cpe_util.is_period_renewable(cre.cert_enrollment_id) Is_Period_Renewable,
                    cre.earliest_enroll_date,
                    cpe.expiration_date,
                    crt.start_date_active,
                    crt.end_date_active
            FROM    ota_certifications_b crt
                  ,ota_certifications_tl ctl
                  ,ota_cert_enrollments cre
                  ,ota_cert_prd_enrollments cpe
                  ,hr_lookups cpe_lkp
            WHERE   cre.person_id BETWEEN nvl(p_start_person_id, cre.person_id)
                    AND nvl(p_end_person_id, cre.person_id)
                AND crt.certification_id   = cre.certification_id
                AND cre.cert_enrollment_id = cpe.cert_enrollment_id(+)
                AND crt.certification_id   = ctl.certification_id
                AND ctl.language           = USERENV('LANG')
                AND cpe_lkp.lookup_code(+) = cpe.period_status_code
                AND cpe_lkp.lookup_type(+) = 'OTA_CERT_PRD_ENROLL_STATUS'
        AND cre.certification_status_code = 'CERTIFIED';

l_certification_tbl         certification_tabletype;
l_certification_rec         certification_rectype;
l_count                     NUMBER := 1;

BEGIN
l_certification_tbl := certification_tabletype();

    OPEN    get_certification;
    LOOP
        FETCH   get_certification INTO
                l_certification_rec.cert_name,
                l_certification_rec.certification_id,
                l_certification_rec.certification_status_code,
                l_certification_rec.cert_status_meaning,
                l_certification_rec.period_status_code,
                l_certification_rec.period_status_meaning,
                l_certification_rec.cert_period_start_date,
                l_certification_rec.cert_period_end_date,
                l_certification_rec.cre_completion_date,
                l_certification_rec.person_id,
                l_certification_rec.contact_id,
                l_certification_rec.cert_enrollment_id,
                l_certification_rec.cert_prd_enrollment_id,
                l_certification_rec.is_history_flag,
                l_certification_rec.renewable_flag,
                l_certification_rec.is_period_renewable,
                l_certification_rec.earliest_enroll_date,
                l_certification_rec.expiration_date,
                l_certification_rec.start_date_active,
                l_certification_rec.end_date_active;
        IF  get_certification%NOTFOUND THEN
            EXIT;
        END IF;

        l_certification_tbl.EXTEND(1);
        l_certification_tbl(l_count) := l_certification_rec;
        l_count := l_count + 1;
    END LOOP;
    CLOSE   get_certification;
    p_certification_tbl := l_certification_tbl;
END get_completed_certifications;

PROCEDURE get_certifications(p_person_id            IN  ota_cert_enrollments.person_id%TYPE
                             ,p_start_person_id     IN  ota_cert_enrollments.person_id%TYPE
                             ,p_end_person_id       IN  ota_cert_enrollments.person_id%TYPE
                             ,p_is_history_flag     IN varchar2
                             ,p_certification_tbl   OUT NOCOPY certification_tabletype)
IS
CURSOR  get_certification IS
    select  ctl.name cert_name,
            cre.certification_id certification_id,
            cre.certification_status_code certification_status_code,
            ota_cpe_util.get_cre_status(cre.cert_enrollment_id) cert_status_meaning,
            cpe.period_status_code period_status_code,
            cpe_lkp.meaning period_status_meaning,
            cpe.cert_period_start_date cert_period_start_date,
            decode(cre.certification_status_code,'CERTIFIED', decode(crt.renewable_flag,'Y',cre.expiration_date,null), cpe.cert_period_end_date) cert_period_end_date,
            cpe.completion_date cre_completion_date,
            cre.person_id person_id,
            cre.contact_id contact_id,
            cre.cert_enrollment_id,
            cpe.cert_prd_enrollment_id,
            cre.is_history_flag,
            crt.renewable_flag,
            ota_cpe_util.is_period_renewable(cre.cert_enrollment_id) Is_Period_Renewable,
            cre.earliest_enroll_date,
            cpe.expiration_date,
            crt.start_date_active,
            crt.end_date_active
    FROM    ota_certifications_b crt
          ,ota_certifications_tl ctl
          ,ota_cert_enrollments cre
          ,ota_cert_prd_enrollments cpe
          ,hr_lookups cpe_lkp
    WHERE
    nvl(p_person_id, cre.person_id) = cre.person_id
    AND     cre.person_id BETWEEN nvl(p_start_person_id, cre.person_id)
        AND  nvl(p_end_person_id, cre.person_id)
    AND crt.certification_id   = cre.certification_id
            AND cre.cert_enrollment_id = cpe.cert_enrollment_id(+)
            AND crt.certification_id   = ctl.certification_id
            AND ctl.language           = USERENV('LANG')
            AND cpe_lkp.lookup_code(+) = cpe.period_status_code
            AND cpe_lkp.lookup_type(+) = 'OTA_CERT_PRD_ENROLL_STATUS'
    AND ((p_is_history_flag = 'Y' and
               ((cre.is_history_flag ='Y'
    OR (CERTIFICATION_STATUS_CODE IN ('CANCELLED','EXPIRED'))
    OR (crt.renewable_flag ='Y' AND PERIOD_STATUS_CODE NOT IN ('ACTIVE','ENROLLED'))
    OR (NVL(TRUNC(crt.end_date_active), TRUNC(SYSDATE)) < TRUNC(SYSDATE))) OR (NVL(TRUNC(cpe.cert_period_end_date), TRUNC(SYSDATE)) < TRUNC(SYSDATE))))
    OR (p_is_history_flag = 'N' AND ((cre.is_history_flag IS NULL OR cre.is_history_flag = 'N')
    AND (NVL(TRUNC(crt.end_date_active), TRUNC(SYSDATE)) >= TRUNC(SYSDATE))
    AND CERTIFICATION_STATUS_CODE NOT                IN ('CANCELLED','REJECTED','AWAITING_APPROVAL')
    AND ((cpe.cert_prd_enrollment_id                     IS NULL)
    OR (cpe.cert_prd_enrollment_id                      IS NOT NULL
    AND cpe.cert_prd_enrollment_id                        =
        (SELECT MAX(cpe2.cert_prd_enrollment_id)
        FROM    ota_cert_prd_enrollments cpe2
        WHERE   cpe2.cert_enrollment_id(+) = cre.cert_enrollment_id))))));

l_certification_tbl         certification_tabletype;
l_certification_rec         certification_rectype;
l_count                     NUMBER := 1;

BEGIN
l_certification_tbl := certification_tabletype();

    OPEN    get_certification;
    LOOP
        FETCH   get_certification INTO
                l_certification_rec.cert_name,
                l_certification_rec.certification_id,
                l_certification_rec.certification_status_code,
                l_certification_rec.cert_status_meaning,
                l_certification_rec.period_status_code,
                l_certification_rec.period_status_meaning,
                l_certification_rec.cert_period_start_date,
                l_certification_rec.cert_period_end_date,
                l_certification_rec.cre_completion_date,
                l_certification_rec.person_id,
                l_certification_rec.contact_id,
                l_certification_rec.cert_enrollment_id,
                l_certification_rec.cert_prd_enrollment_id,
                l_certification_rec.is_history_flag,
                l_certification_rec.renewable_flag,
                l_certification_rec.is_period_renewable,
                l_certification_rec.earliest_enroll_date,
                l_certification_rec.expiration_date,
                l_certification_rec.start_date_active,
                l_certification_rec.end_date_active;
        IF  get_certification%NOTFOUND AND l_count = 1 THEN
            RAISE invalid_person_id;
        ELSIF get_certification%NOTFOUND THEN
            EXIT;
        END IF;

        l_certification_tbl.EXTEND(1);
        l_certification_tbl(l_count) := l_certification_rec;
        l_count := l_count + 1;
    END LOOP;
    CLOSE   get_certification;
    p_certification_tbl := l_certification_tbl;
END get_certifications;

PROCEDURE get_certifications(p_person_id  IN  ota_cert_enrollments.person_id%TYPE
                            ,p_certification_id     IN  ota_cert_enrollments.certification_id%TYPE
                            ,p_certification_tbl   OUT NOCOPY certification_tabletype)
IS
CURSOR  get_certification IS
    select ctl.name cert_name,
            cre.certification_id certification_id,
            cre.certification_status_code certification_status_code,
            ota_cpe_util.get_cre_status(cre.cert_enrollment_id) cert_status_meaning,
            cpe.period_status_code period_status_code,
            cpe_lkp.meaning period_status_meaning,
            cpe.cert_period_start_date cert_period_start_date,
            decode(cre.certification_status_code,'CERTIFIED', decode(crt.renewable_flag,'Y',cre.expiration_date,null), cpe.cert_period_end_date) cert_period_end_date,
            cpe.completion_date cre_completion_date,
            cre.person_id person_id,
            cre.contact_id contact_id,
            cre.cert_enrollment_id,
            cpe.cert_prd_enrollment_id,
            cre.is_history_flag,
            crt.renewable_flag,
            ota_cpe_util.is_period_renewable(cre.cert_enrollment_id) Is_Period_Renewable,
            cre.earliest_enroll_date,
            cpe.expiration_date,
            crt.start_date_active,
            crt.end_date_active
    FROM    ota_certifications_b crt
          ,ota_certifications_tl ctl
          ,ota_cert_enrollments cre
          ,ota_cert_prd_enrollments cpe
          ,hr_lookups cpe_lkp
    WHERE   ((p_person_id IS NULL) OR (p_person_id IS NOT NULL AND cre.person_id = p_person_id))
         AND ((p_certification_id IS NULL) OR (cre.certification_id = p_certification_id))
        AND crt.certification_id   = cre.certification_id
        AND cre.cert_enrollment_id = cpe.cert_enrollment_id(+)
        AND crt.certification_id   = ctl.certification_id
        AND ctl.language           = USERENV('LANG')
        AND cpe_lkp.lookup_code(+) = cpe.period_status_code
        AND cpe_lkp.lookup_type(+) = 'OTA_CERT_PRD_ENROLL_STATUS';

l_certification_tbl         certification_tabletype;
l_certification_rec         certification_rectype;
l_count                     NUMBER := 1;

BEGIN
l_certification_tbl := certification_tabletype();

    OPEN    get_certification;
    LOOP
        FETCH   get_certification INTO
                l_certification_rec.cert_name,
                l_certification_rec.certification_id,
                l_certification_rec.certification_status_code,
                l_certification_rec.cert_status_meaning,
                l_certification_rec.period_status_code,
                l_certification_rec.period_status_meaning,
                l_certification_rec.cert_period_start_date,
                l_certification_rec.cert_period_end_date,
                l_certification_rec.cre_completion_date,
                l_certification_rec.person_id,
                l_certification_rec.contact_id,
                l_certification_rec.cert_enrollment_id,
                l_certification_rec.cert_prd_enrollment_id,
                l_certification_rec.is_history_flag,
                l_certification_rec.renewable_flag,
                l_certification_rec.is_period_renewable,
                l_certification_rec.earliest_enroll_date,
                l_certification_rec.expiration_date,
                l_certification_rec.start_date_active,
                l_certification_rec.end_date_active;
        IF  get_certification%NOTFOUND AND l_count = 1 THEN
            RAISE invalid_certification_id;
        ELSIF get_certification%NOTFOUND THEN
            EXIT;
        END IF;

        l_certification_tbl.EXTEND(1);
        l_certification_tbl(l_count) := l_certification_rec;
        l_count := l_count + 1;
    END LOOP;
    CLOSE   get_certification;
    p_certification_tbl := l_certification_tbl;
END get_certifications;

PROCEDURE get_certification_description(p_certification_id          IN  ota_certifications_b.certification_id%TYPE,
                                        p_cert_enrollment_id        IN  ota_cert_enrollments.cert_enrollment_id%TYPE,
                                        p_cert_prd_enrollment_id    IN  ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE,
                                        p_certification_desc_rec    OUT NOCOPY cert_description_rectype)
IS
CURSOR get_cert_description IS
    select
              b.certification_id certification_id
            , b.INITIAL_COMPLETION_DATE
            , b.INITIAL_COMPLETION_DURATION
            , b.INITIAL_COMPL_DURATION_UNITS
            , b.RENEWAL_DURATION
            , b.RENEWAL_DURATION_UNITS
            , b.NOTIFY_DAYS_BEFORE_EXPIRE
            , b.VALIDITY_DURATION
            , b.VALIDITY_DURATION_UNITS
            , b.RENEWABLE_FLAG RENEWABLE_FLAG_CODE
            , ota_utility.get_lookup_meaning('YES_NO',b.renewable_flag, '810') renewable_flag_meaning
            , b.start_date_active
            , B.END_DATE_ACTIVE
            , tl.name Name
            , tl.description Description
            , tl.objectives Objectives
            , tl.purpose Purpose
            , tl.keywords Keywords
            , INITIAL_PERIOD_COMMENTS
            , tl.RENEWAL_PERIOD_COMMENTS
    from ota_certifications_b b,
         ota_certifications_tl tl
    where
    b.certification_id = tl.certification_id
    --and b.business_group_id = ota_general.get_business_group_id
    and tl.language = USERENV ('LANG')
    and b.certification_id = p_certification_id;

CURSOR  get_certification_details IS
    SELECT  cre.certification_status_code certification_status_code
          , crt_lkp.meaning cert_status_meaning
          , cpe.period_status_code period_status_code
          , cpe_lkp.meaning period_status_meaning
          , cre.expiration_date
          , cre.earliest_enroll_date
          , cpe.cert_period_start_date cert_period_start_date
          , cpe.cert_period_end_date cert_period_end_date
          , cre.cert_enrollment_id cert_enrollment_id
          , cpe.cert_prd_enrollment_id cert_prd_enrollment_id
          , cre.completion_date cre_completion_date
    FROM    ota_cert_enrollments cre
          , ota_cert_prd_enrollments cpe
          , hr_lookups crt_lkp
          , hr_lookups cpe_lkp
    WHERE   cre.cert_enrollment_id         = cpe.cert_enrollment_id (+)
        AND crt_lkp.lookup_code            = cre.certification_status_code
        AND crt_lkp.lookup_type            = 'OTA_CERT_ENROLL_STATUS'
        AND cpe_lkp.lookup_code (+)        = cpe.period_status_code
        AND cpe_lkp.lookup_type (+)        = 'OTA_CERT_PRD_ENROLL_STATUS'
        AND cre.cert_enrollment_id         = p_cert_enrollment_id
        AND cpe.cert_prd_enrollment_id (+) = p_cert_prd_enrollment_id;

l_certification_desc_rec    cert_description_rectype := NULL;

BEGIN
    OPEN    get_cert_description;
    FETCH   get_cert_description INTO
            l_certification_desc_rec.certification_id,
            l_certification_desc_rec.initial_completion_date,
            l_certification_desc_rec.initial_completion_duration,
            l_certification_desc_rec.initial_compl_duration_units,
            l_certification_desc_rec.renewal_duration,
            l_certification_desc_rec.renewal_duration_units,
            l_certification_desc_rec.notify_days_before_expire,
            l_certification_desc_rec.validity_duration,
            l_certification_desc_rec.validity_duration_units,
            l_certification_desc_rec.renewable_flag_code,
            l_certification_desc_rec.renewable_flag_meaning,
            l_certification_desc_rec.start_date_active,
            l_certification_desc_rec.end_date_active,
            l_certification_desc_rec.name,
            l_certification_desc_rec.description,
            l_certification_desc_rec.objectives,
            l_certification_desc_rec.purpose,
            l_certification_desc_rec.keywords,
            l_certification_desc_rec.initial_period_comments,
            l_certification_desc_rec.renewal_period_comments;
    CLOSE   get_cert_description;

    --get certification details
    OPEN    get_certification_details;
    FETCH   get_certification_details INTO
            l_certification_desc_rec.certification_status_code,
            l_certification_desc_rec.cert_status_meaning,
            l_certification_desc_rec.period_status_code,
            l_certification_desc_rec.period_status_meaning,
            l_certification_desc_rec.expiration_date,
            l_certification_desc_rec.earliest_enroll_date,
            l_certification_desc_rec.cert_period_start_date,
            l_certification_desc_rec.cert_period_end_date,
            l_certification_desc_rec.cert_enrollment_id,
            l_certification_desc_rec.cert_prd_enrollment_id,
            l_certification_desc_rec.cre_completion_date;
    CLOSE   get_certification_details;
    p_certification_desc_rec := l_certification_desc_rec;

END get_certification_description;

PROCEDURE get_cert_competencies(p_certification_id  IN  ota_certifications_b.certification_id%TYPE,
                                p_competencies_tbl  OUT NOCOPY cert_competencies_tabletype)
IS
CURSOR get_competencies IS
        SELECT  comp.competence_id Competence_Id,
                cpn.name Competence_Name,
                comp.proficiency_level_id Proficiency_Level_Id,
                ratl1.step_value || DECODE(ratl1.name,'','', ' - ' || ratl1.name) Proficiency_Level_Name,
                comp.effective_date_from Effective_Date_From,
                comp.effective_date_to Effective_Date_To,
                comp.object_id object_id,
                comp.business_group_id Business_Group_Id
        FROM    per_competence_elements comp,
                per_competences_tl cpn, per_rating_levels ratl1
        WHERE   comp.object_id = p_certification_id
        AND     comp.type = 'OTA_CERTIFICATION'
        AND     cpn.competence_id = comp.competence_id
        AND     comp.proficiency_level_id = ratl1.rating_level_id(+)
        AND     cpn.language = USERENV('LANG')
        ORDER BY COMPETENCE_NAME;

l_competencies_rec          cert_comp_rectype := NULL;
l_competencies_tbl          cert_competencies_tabletype;
l_count                     NUMBER := 1;
BEGIN
    l_competencies_tbl := cert_competencies_tabletype();
    OPEN    get_competencies;
    LOOP
        FETCH   get_competencies INTO l_competencies_rec;
        IF  get_competencies%NOTFOUND THEN
            EXIT;
        END IF;
        l_competencies_tbl.EXTEND(1);
        l_competencies_tbl(l_count) := l_competencies_rec;
        l_count := l_count + 1;

    END LOOP;
    CLOSE   get_competencies;
    p_competencies_tbl := l_competencies_tbl;
END get_cert_competencies;

PROCEDURE get_cert_components(p_cert_prd_enrollment_id  IN  ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE,
                              p_components_tbl          OUT NOCOPY components_tabletype)
IS
CURSOR get_components IS
    select  cme.cert_mbr_enrollment_id cert_mbr_enrollment_id,
            tav.activity_version_id Activity_version_Id,
            cme.member_status_code member_status_code,
            tav.version_name Course_Name,
            cme.completion_date completion_date,
            lkp.meaning Member_Status_Meaning,
            decode( ota_cme_util.chk_active_cme_enrl(cme.cert_mbr_enrollment_id),
                    'F', 'DetailsIconDisabled',
                    decode( cme.member_status_code,
                            'ACTIVE','DetailsIconEnabled',
                            'CANCELLED','DetailsIconDisabled',
                            'PLANNED','DetailsIconDisabled',
                            'AWAITING_APPROVAL','DetailsIconDisabled',
                            'COMPLETED','DetailsIconEnabled')
                   ) Enrollment_Details_Icon,
            tav.Version_Code Version_Code,
            tav.Version_Name Activity_Version_Name,
            tav.Start_Date Start_Date,
            tav.End_Date End_Date,
            cmb.certification_member_id certification_member_id,
            cmb.MEMBER_SEQUENCE MEMBER_SEQUENCE,
            OTA_LO_UTILITY.get_cme_online_event_id(NVL(cre.person_id, cre.contact_id),
                                                       DECODE(cre.person_id, NULL, 'C', 'E'),
                                                       cme.cert_mbr_enrollment_id) as Event_Id,
            OTA_LO_UTILITY.get_cert_lo_status(NVL(cre.person_id, cre.contact_id),
                                              DECODE(cre.person_id, NULL, 'C', 'E'),
                                              cme.cert_mbr_enrollment_id) as Perf_Status, cme.Cert_Prd_Enrollment_Id,
            cre.Cert_Enrollment_Id,
            cre.Certification_Id,
            fnd_profile.value('OTA_ILEARNING_SITE_ADDRESS') AS SITE_ADDRESS ,
            fnd_profile.value('OTA_ILEARNING_SITE_ID') AS SITE_SHORT_NAME ,
            fnd_profile.value('USERNAME') AS FND_USER_NAME ,
            WFA_HTML.CONV_SPECIAL_URL_CHARS(fnd_profile.value('OTA_ILEARNING_SITE_ADDRESS')) Encoded_Site_Address ,
            (select e.offering_id
             from   ota_events e
             where  e.event_id = OTA_LO_UTILITY.get_cme_online_event_id(NVL(cre.person_id, cre.contact_id),
                                    DECODE(cre.person_id, NULL, 'C', 'E'), cme.cert_mbr_enrollment_id))AS CLASSROOM_ID
    from    ota_cert_enrollments cre,
            ota_cert_prd_enrollments cpe,
            ota_cert_mbr_enrollments cme,
            ota_certification_members cmb,
            ota_activity_versions_vl tav,
            hr_lookups lkp
    where   tav.activity_version_id = cmb.object_id
    and     cmb.object_type = 'H'
    and     cmb.certification_member_id = cme.cert_member_id
    and     lkp.lookup_code = cme.member_status_code
    and     lkp.lookup_type = 'OTA_CERT_MBR_ENROLL_STATUS'
    AND     trunc(sysdate) BETWEEN NVL(lkp.start_date_active,trunc(sysdate))
    AND     NVL (lkp.end_date_active, trunc(sysdate))
    AND     lkp.enabled_flag ='Y'
    and     cpe.cert_enrollment_id = cre.cert_enrollment_id
    and     cme.cert_prd_enrollment_id = cpe.cert_prd_enrollment_id
    and     cme.cert_prd_enrollment_id = p_cert_prd_enrollment_id
    order   by MEMBER_SEQUENCE asc;

l_components_rec            cert_component_rectype := NULL;
l_components_tbl            components_tabletype;
l_count                     NUMBER := 1;
BEGIN
    l_components_tbl := components_tabletype();
    OPEN    get_components;
    LOOP
        FETCH   get_components INTO l_components_rec;
        IF get_components%NOTFOUND THEN
            EXIT;
        END IF;
        l_components_tbl.EXTEND(1);
        l_components_tbl(l_count) := l_components_rec;
        l_count := l_count+1;
    END LOOP;
    CLOSE   get_components;
    p_components_tbl := l_components_tbl;
END get_cert_components;

PROCEDURE get_learner(p_cert_enrollment_id  IN  ota_cert_enrollments.cert_enrollment_id%TYPE,
                      p_person_id           OUT NOCOPY ota_cert_enrollments.person_id%TYPE,
                      p_certification_id    OUT NOCOPY ota_cert_enrollments.certification_id%TYPE)
IS
CURSOR get_info IS
    SELECT  oce.person_id,
            oce.certification_id
    FROM    ota_cert_enrollments oce
    WHERE   oce.cert_enrollment_id = p_cert_enrollment_id;

l_person_id         ota_cert_enrollments.person_id%TYPE;
l_certification_id  ota_cert_enrollments.certification_id%TYPE;

BEGIN
    OPEN    get_info;
    FETCH   get_info into l_person_id, l_certification_id;
    IF get_info%NOTFOUND THEN
        RAISE invalid_cert_enrollment_id;
    END IF;
    CLOSE   get_info;

    p_person_id := l_person_id;
    p_certification_id := l_certification_id;
END get_learner;

PROCEDURE get_certification_details(  p_query_options               IN   cert_query_input_rectype,
                                      p_certifications              OUT  NOCOPY certification_tabletype)
IS
l_certification_rec         certification_rectype;
l_certification_desc_rec    cert_description_rectype := NULL;
l_competencies_rec          cert_comp_rectype := NULL;
l_components_rec            cert_component_rectype := NULL;

l_certification_tbl         certification_tabletype;
l_competencies_tbl          cert_competencies_tabletype;
l_components_tbl            components_tabletype;

l_person_id                 ota_cert_enrollments.person_id%TYPE := NULL;
l_certification_id          ota_cert_enrollments.certification_id%TYPE := NULL;

l_details_required          BOOLEAN := FALSE;
l_competencies_required     BOOLEAN := FALSE;
l_components_required       BOOLEAN := FALSE;

BEGIN
--l_details_required := is_required(p_query_options.options, 'DETAIL');
l_details_required := TRUE;
l_competencies_required := is_required(p_query_options.options, 'COMPETENCY');
l_components_required := is_required(p_query_options.options, 'COMPONENT');

IF p_query_options.person_id IS NOT NULL THEN
        IF p_query_options.view_history THEN
           get_certifications(   p_person_id           => p_query_options.person_id
                                ,p_start_person_id     => p_query_options.start_person_id
                                ,p_end_person_id       => p_query_options.end_person_id
                                ,p_is_history_flag     => 'Y'
                                ,p_certification_tbl   => l_certification_tbl);
        ELSE
           get_certifications(   p_person_id           => p_query_options.person_id
                                ,p_start_person_id     => p_query_options.start_person_id
                                ,p_end_person_id       => p_query_options.end_person_id
                                ,p_is_history_flag     => 'N'
                                ,p_certification_tbl   => l_certification_tbl);
        END IF;
ELSIF p_query_options.certification_id IS NOT NULL THEN
      get_certifications( p_person_id           => null
                         ,p_certification_id    => p_query_options.certification_id
                         ,p_certification_tbl   => l_certification_tbl);
ELSIF p_query_options.cert_enrollment_id IS NOT NULL THEN
       get_learner( p_query_options.cert_enrollment_id,
                    l_person_id,
                    l_certification_id);
       get_certifications( p_person_id          => l_person_id
                          ,p_certification_id   => l_certification_id
                          ,p_certification_tbl  => l_certification_tbl);
ELSE
    get_completed_certifications(p_start_person_id     => p_query_options.start_person_id
                                ,p_end_person_id       => p_query_options.end_person_id
                                ,p_certification_tbl   => l_certification_tbl);
END IF;

IF l_certification_tbl.COUNT > 0 THEN
    FOR i in l_certification_tbl.FIRST..l_certification_tbl.LAST LOOP
        l_certification_rec := l_certification_tbl(i);

        IF l_details_required THEN
            -- get certification descriptions
            get_certification_description(l_certification_rec.certification_id,
                                          l_certification_rec.cert_enrollment_id,
                                          l_certification_rec.cert_prd_enrollment_id,
                                          l_certification_desc_rec);

            l_certification_rec.cert_description := l_certification_desc_rec;
        END IF;

        IF l_competencies_required THEN
            -- get competencies
            get_cert_competencies(l_certification_rec.certification_id,
                                  l_competencies_tbl);
            l_certification_rec.cert_competencies := l_competencies_tbl;
        END IF;

        IF l_components_required THEN
            -- get components
            get_cert_components(l_certification_rec.cert_prd_enrollment_id,
                                l_components_tbl);
            l_certification_rec.cert_components := l_components_tbl;
        END IF;

        -- set certification status code
        l_certification_rec.event_action := 'CERTIFICATION_' || l_certification_rec.certification_status_code;

        l_certification_tbl(i) := l_certification_rec;
    END LOOP;
END IF;
p_certifications := l_certification_tbl;
EXCEPTION
    WHEN invalid_cert_enrollment_id THEN
        p_certifications := certification_tabletype();
    WHEN invalid_person_id  THEN
        p_certifications := certification_tabletype();
    WHEN invalid_certification_id THEN
        p_certifications := certification_tabletype();
END get_certification_details;

FUNCTION is_part_of_certification(p_booking_id          IN  ota_delegate_bookings.booking_id%TYPE,
                                  p_cert_enrollment_id  OUT NOCOPY ota_cert_enrollments.cert_enrollment_id%TYPE) RETURN BOOLEAN
IS

CURSOR  get_enrollments IS
    SELECT  *
    FROM    (
        SELECT  cpe.cert_prd_enrollment_id,
                cre.cert_enrollment_id,
                cre.certification_id,
                to_char(b.booking_id) Enrollment_Number,
                cme.cert_mbr_enrollment_id,
                cre.person_id,
                cpe.cert_period_start_date,
                cpe.cert_period_end_date,
                e.course_end_date Course_End,
                e.course_start_date event_start_date,
                e.event_type event_type
        FROM    ota_events e,
                ota_events_tl et,
                hr_all_organization_units o,
                hr_all_organization_units_tl haotl,
                ota_activity_versions a,
                ota_delegate_bookings b,
                ota_booking_status_types_VL s,
                ota_cert_enrollments cre,
                ota_cert_prd_enrollments cpe,
                ota_cert_mbr_enrollments cme,
                ota_certification_members cmb,
                ota_offerings ofr,
                ota_category_usages c
        WHERE   e.event_id = b.event_id
        AND     cre.cert_enrollment_id = cpe.cert_enrollment_id
        AND     cpe.cert_prd_enrollment_id = cme.cert_prd_enrollment_id
        AND     e.event_id= et.event_id
        AND     s.type <> 'C'
        AND     et.language = USERENV('LANG')
        AND     e.training_center_id = o.organization_id(+)
        And     haotl.organization_id(+) = o.organization_id
        AND     cme.cert_member_id = cmb.certification_member_id
        AND     cmb.object_id = a.activity_version_id
        AND     cmb.object_type = 'H'
        AND     e.parent_offering_id = ofr.offering_id
        And     haotl.language(+) = USERENV ('LANG')
        AND     e.activity_version_id = a.activity_version_id
        AND     b.booking_status_type_id = s.booking_status_type_id
        AND     ((cre.person_id IS NOT NULL AND b.delegate_person_id = cre.person_id)
                    OR
                 (cre.CONTACT_ID IS NOT NULL AND b.delegate_contact_id = cre.contact_id))
        AND     E.PARENT_OFFERING_ID=OFR.OFFERING_ID
        AND     OFR.DELIVERY_MODE_ID = C.CATEGORY_USAGE_ID
        ) QRSLT
    WHERE   (enrollment_number = p_booking_id
    AND     (
                (   event_start_date >= cert_period_start_date
                and nvl(course_end,to_date('4712/12/31', 'YYYY/MM/DD')) <= cert_period_end_date )
            or  (   event_type ='SELFPACED'
                and ((cert_period_end_date >= event_start_date) AND ((course_end is null) or (course_end IS NOT NULL AND course_end >= cert_period_start_date)) ))));

l_cursor_rec    get_enrollments%ROWTYPE;
BEGIN
    OPEN    get_enrollments;
    FETCH   get_enrollments INTO l_cursor_rec;
    IF  get_enrollments%FOUND THEN
        p_cert_enrollment_id := l_cursor_rec.cert_enrollment_id;
        RETURN TRUE;
    END IF;
    RETURN FALSE;
    CLOSE   get_enrollments;
END is_part_of_certification;

PROCEDURE get_training_details_internal(p_person_id         IN  ota_delegate_bookings.delegate_person_id%TYPE,
                                        p_start_person_id   IN  ota_delegate_bookings.delegate_person_id%TYPE,
                                        p_end_person_id     IN  ota_delegate_bookings.delegate_person_id%TYPE,
                                        p_view_history      IN  VARCHAR,
                                        p_activity_tbl      OUT NOCOPY activity_tabletype)
IS
CURSOR get_activity_rec IS
SELECT  distinct
a.activity_version_id Activity_Version_Id,
            a.version_name Activity_Version_Name,
            a.description Activity_Description,
            a.objectives Activity_Objectives,
            a.intended_audience Activity_Audience,
            a.keywords Activity_Keywords,
            a.tav_information_category ,
            a.tav_information1,
            a.tav_information2,
            a.tav_information3,
            a.tav_information4,
            a.tav_information5,
            a.tav_information6,
            a.tav_information7,
            a.tav_information8,
            a.tav_information9,
            a.tav_information10,
            a.tav_information11,
            a.tav_information12,
            a.tav_information13,
            a.tav_information14,
            a.tav_information15,
            a.tav_information16,
            a.tav_information17,
            a.tav_information18,
            a.tav_information19,
            a.tav_information20,
            a.Version_Code Activity_Version_Code,
            hr_general_utilities.get_lookup_meaning('ACTIVITY_SUCCESS_CRITERIA', a.success_criteria) Success_Criteria,
            a.professional_credits,
            hr_general.decode_lookup('PROFESSIONAL_CREDIT_TYPE', a.professional_credit_type) Professional_Credit_Meaning,
            a.Controlling_Person_Id Controlling_Person_Id,
            ST.NAME status,
             DECODE(C.ONLINE_FLAG ,'Y',OTA_LO_UTILITY.get_enroll_lo_status(NVL(D.delegate_person_id, D.contact_id), DECODE(D.delegate_person_id, NULL, 'C', 'E') , E.EVENT_ID,D.BOOKING_STATUS_TYPE_ID,D.BOOKING_ID,null,'N'), null) player_status
        ,D.BOOKING_ID
        ,D.DELEGATE_PERSON_ID
        ,D.IS_HISTORY_FLAG
        ,D.DATE_STATUS_CHANGED
                ,D.SUCCESSFUL_ATTENDANCE_FLAG
        , nvl(D.IS_MANDATORY_ENROLLMENT,'N') is_mandatory_enrollment
                ,E.EVENT_ID
    FROM    ota_activity_versions_vl a ,
            OTA_EVENTS E,
            OTA_EVENTS_TL ET,
                OTA_DELEGATE_BOOKINGS D,
                OTA_BOOKING_STATUS_TYPES S,
            OTA_BOOKING_STATUS_TYPES_TL ST,
                OTA_OFFERINGS O,
                OTA_OFFERINGS_TL OT,
                OTA_CATEGORY_USAGES C,
                OTA_CATEGORY_USAGES_TL CT,
            OTA_ACTIVITY_VERSIONS_TL OAV,
            OTA_EVALUATIONS EVAL
    WHERE   a.activity_version_id = e.activity_version_id
    AND OAV.ACTIVITY_VERSION_ID = a.ACTIVITY_VERSION_ID
    AND     E.EVENT_ID=D.EVENT_ID
    AND     S.BOOKING_STATUS_TYPE_ID=D.BOOKING_STATUS_TYPE_ID
    --AND     E.BUSINESS_GROUP_ID = OTA_GENERAL.GET_BUSINESS_GROUP_ID
    AND     E.PARENT_OFFERING_ID=O.OFFERING_ID
    AND     O.DELIVERY_MODE_ID = C.CATEGORY_USAGE_ID
    AND     a.ACTIVITY_VERSION_ID = O.ACTIVITY_VERSION_ID
    AND     OAV.LANGUAGE=USERENV('LANG')
    AND     E.EVENT_ID = ET.EVENT_ID
    AND     ET.LANGUAGE=USERENV('LANG')
    AND     S.BOOKING_STATUS_TYPE_ID = ST.BOOKING_STATUS_TYPE_ID
    AND     ST.LANGUAGE=USERENV('LANG')
    AND     O.OFFERING_ID = OT.OFFERING_ID
    AND     OT.LANGUAGE=USERENV('LANG')
    AND     C.CATEGORY_USAGE_ID = CT.CATEGORY_USAGE_ID
    AND     CT.LANGUAGE=USERENV('LANG')
    AND     E.EVENT_TYPE IN ('SCHEDULED','SELFPACED')
    AND     E.BOOK_INDEPENDENT_FLAG = 'N'
    AND     E.EVENT_ID = EVAL.OBJECT_ID(+)
    AND     (EVAL.OBJECT_TYPE is null or EVAL.OBJECT_TYPE = 'E')
    AND     nvl(p_person_id, D.delegate_person_id) = D.delegate_person_id
    AND     D.delegate_person_id BETWEEN nvl(p_start_person_id, D.delegate_person_id)
        AND  nvl(p_end_person_id, D.delegate_person_id)
    AND     (( ( p_view_history = 'N'  AND
            ((D.IS_HISTORY_FLAG IS NULL OR D.IS_HISTORY_FLAG = 'N')
            AND ( E.COURSE_END_DATE IS NULL
                OR TO_DATE( TO_CHAR(nvl(E.COURSE_END_DATE,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD') ||
                                    ' ' || nvl(E.COURSE_END_TIME,'23:59'), 'YYYY/MM/DD HH24:MI')
                         >= OTA_TIMEZONE_UTIL.CONVERT_DATE(TRUNC(SYSDATE), TO_CHAR(SYSDATE, 'HH24:MI'),
                                 OTA_TIMEZONE_UTIL.GET_SERVER_TIMEZONE_CODE, E.TIMEZONE)
            )
            AND ((C.ONLINE_FLAG = 'Y' AND S.TYPE IN ('A','P','E')) OR (C.ONLINE_FLAG = 'N' AND S.TYPE in( 'P','E'))))))
        OR
            (p_view_history = 'Y'
            AND ((S.TYPE NOT IN ('R','W'))
            AND ((D.IS_HISTORY_FLAG = 'Y')
                OR ( E.COURSE_END_DATE IS NOT NULL
                      AND TO_DATE( TO_CHAR(nvl(E.COURSE_END_DATE,to_date('4712/12/31','YYYY/MM/DD')),'YYYY/MM/DD')
                                       || ' ' || nvl(E.COURSE_END_TIME,'23:59'), 'YYYY/MM/DD HH24:MI')
                         < OTA_TIMEZONE_UTIL.CONVERT_DATE(TRUNC(SYSDATE), TO_CHAR(SYSDATE, 'HH24:MI'),
                                 OTA_TIMEZONE_UTIL.GET_SERVER_TIMEZONE_CODE, E.TIMEZONE)
                )
                OR (C.ONLINE_FLAG = 'N' AND S.TYPE IN ('A','C'))
                OR (C.ONLINE_FLAG = 'Y' AND S.TYPE IN ('C'))
            )
            )));

            l_activity_rec      activity_rectype;
            l_activity_tbl      activity_tabletype;
            l_count             NUMBER := 1;
                        l_event_id              ota_events.event_id%TYPE;
      BEGIN
      l_activity_tbl := activity_tabletype();
    OPEN get_activity_rec;
    LOOP
        FETCH   get_activity_rec INTO
                l_activity_rec.activity_version_id,
                l_activity_rec.activity_version_name,
                l_activity_rec.activity_description,
                l_activity_rec.activity_objectives,
                l_activity_rec.activity_audience,
                l_activity_rec.activity_keywords,
                l_activity_rec.tav_information_category,
                l_activity_rec.tav_information1,
                l_activity_rec.tav_information2,
                l_activity_rec.tav_information3,
                l_activity_rec.tav_information4,
                l_activity_rec.tav_information5,
                l_activity_rec.tav_information6,
                l_activity_rec.tav_information7,
                l_activity_rec.tav_information8,
                l_activity_rec.tav_information9,
                l_activity_rec.tav_information10,
                l_activity_rec.tav_information11,
                l_activity_rec.tav_information12,
                l_activity_rec.tav_information13,
                l_activity_rec.tav_information14,
                l_activity_rec.tav_information15,
                l_activity_rec.tav_information16,
                l_activity_rec.tav_information17,
                l_activity_rec.tav_information18,
                l_activity_rec.tav_information19,
                l_activity_rec.tav_information20,
                l_activity_rec.activity_version_code,
                l_activity_rec.success_criteria,
                l_activity_rec.professional_credits,
                l_activity_rec.professional_credit_meaning,
                l_activity_rec.controlling_person_id,
                l_activity_rec.booking.status,
                l_activity_rec.booking.player_status,
                l_activity_rec.booking.booking_id,
                l_activity_rec.booking.delegate_person_id,
                l_activity_rec.booking.is_history_flag,
                l_activity_rec.booking.date_status_changed,
                l_activity_rec.booking.successful_attendance_flag,
                l_activity_rec.booking.is_mandatory_enrollment,
                l_event_id;
        IF get_activity_rec%NOTFOUND AND l_count = 1 THEN
            RAISE invalid_person_id;
        ELSIF get_activity_rec%NOTFOUND THEN
            EXIT;
        END IF;

                 get_events(p_event_id               => l_event_id,
                       p_activity_version_id    => l_activity_rec.activity_version_id,
                       p_events_tbl             => l_activity_rec.events);

        l_activity_tbl.EXTEND(1);
        l_activity_tbl(l_count) := l_activity_rec;
        l_count := l_count + 1;

    END LOOP;
    CLOSE   get_activity_rec;
    p_activity_tbl := l_activity_tbl;
END get_training_details_internal;

PROCEDURE get_training_details_internal(p_booking_id IN  OTA_DELEGATE_BOOKINGS.BOOKING_ID%TYPE
                                       ,p_activity_tbl  OUT NOCOPY activity_tabletype)
IS
CURSOR get_activity_rec IS
SELECT  distinct
a.activity_version_id Activity_Version_Id,
            a.version_name Activity_Version_Name,
            a.description Activity_Description,
            a.objectives Activity_Objectives,
            a.intended_audience Activity_Audience,
            a.keywords Activity_Keywords,
            a.tav_information_category ,
            a.tav_information1,
            a.tav_information2,
            a.tav_information3,
            a.tav_information4,
            a.tav_information5,
            a.tav_information6,
            a.tav_information7,
            a.tav_information8,
            a.tav_information9,
            a.tav_information10,
            a.tav_information11,
            a.tav_information12,
            a.tav_information13,
            a.tav_information14,
            a.tav_information15,
            a.tav_information16,
            a.tav_information17,
            a.tav_information18,
            a.tav_information19,
            a.tav_information20,
            a.Version_Code Activity_Version_Code,
            hr_general_utilities.get_lookup_meaning('ACTIVITY_SUCCESS_CRITERIA', a.success_criteria) Success_Criteria,
            a.professional_credits,
            hr_general.decode_lookup('PROFESSIONAL_CREDIT_TYPE', a.professional_credit_type) Professional_Credit_Meaning,
            a.Controlling_Person_Id Controlling_Person_Id,
            ST.NAME status,
             DECODE(C.ONLINE_FLAG ,'Y',OTA_LO_UTILITY.get_enroll_lo_status(NVL(D.delegate_person_id, D.contact_id), DECODE(D.delegate_person_id, NULL, 'C', 'E') , E.EVENT_ID,D.BOOKING_STATUS_TYPE_ID,D.BOOKING_ID,null,'N'), null) player_status
        ,D.BOOKING_ID
        ,D.DELEGATE_PERSON_ID
        ,D.IS_HISTORY_FLAG
        ,D.DATE_STATUS_CHANGED
                ,D.SUCCESSFUL_ATTENDANCE_FLAG
        , nvl(D.IS_MANDATORY_ENROLLMENT,'N') is_mandatory_enrollment
                ,E.EVENT_ID
    FROM    ota_activity_versions_vl a ,
            OTA_EVENTS E,
            OTA_EVENTS_TL ET,
                OTA_DELEGATE_BOOKINGS D,
                OTA_BOOKING_STATUS_TYPES S,
            OTA_BOOKING_STATUS_TYPES_TL ST,
                OTA_OFFERINGS O,
                OTA_OFFERINGS_TL OT,
                OTA_CATEGORY_USAGES C,
                OTA_CATEGORY_USAGES_TL CT,
            OTA_ACTIVITY_VERSIONS_TL OAV,
            OTA_EVALUATIONS EVAL
    WHERE   a.activity_version_id = e.activity_version_id
    AND OAV.ACTIVITY_VERSION_ID = a.ACTIVITY_VERSION_ID
    AND     E.EVENT_ID=D.EVENT_ID
    AND     S.BOOKING_STATUS_TYPE_ID=D.BOOKING_STATUS_TYPE_ID
    --AND     E.BUSINESS_GROUP_ID = OTA_GENERAL.GET_BUSINESS_GROUP_ID
    AND     E.PARENT_OFFERING_ID=O.OFFERING_ID
    AND     O.DELIVERY_MODE_ID = C.CATEGORY_USAGE_ID
    AND     a.ACTIVITY_VERSION_ID = O.ACTIVITY_VERSION_ID
    AND     OAV.LANGUAGE=USERENV('LANG')
    AND     E.EVENT_ID = ET.EVENT_ID
    AND     ET.LANGUAGE=USERENV('LANG')
    AND     S.BOOKING_STATUS_TYPE_ID = ST.BOOKING_STATUS_TYPE_ID
    AND     ST.LANGUAGE=USERENV('LANG')
    AND     O.OFFERING_ID = OT.OFFERING_ID
    AND     OT.LANGUAGE=USERENV('LANG')
    AND     C.CATEGORY_USAGE_ID = CT.CATEGORY_USAGE_ID
    AND     CT.LANGUAGE=USERENV('LANG')
    AND     E.EVENT_TYPE IN ('SCHEDULED','SELFPACED')
    AND     E.BOOK_INDEPENDENT_FLAG = 'N'
    AND     E.EVENT_ID = EVAL.OBJECT_ID(+)
    AND     (EVAL.OBJECT_TYPE is null or EVAL.OBJECT_TYPE = 'E')
    AND     D.BOOKING_ID = p_booking_id;

    l_activity_rec      activity_rectype;
    l_activity_tbl      activity_tabletype;
    l_event_id        ota_events.event_id%TYPE;
BEGIN
    l_activity_tbl := activity_tabletype();

    OPEN get_activity_rec;
    FETCH   get_activity_rec INTO
            l_activity_rec.activity_version_id,
            l_activity_rec.activity_version_name,
            l_activity_rec.activity_description,
            l_activity_rec.activity_objectives,
            l_activity_rec.activity_audience,
            l_activity_rec.activity_keywords,
            l_activity_rec.tav_information_category,
            l_activity_rec.tav_information1,
            l_activity_rec.tav_information2,
            l_activity_rec.tav_information3,
            l_activity_rec.tav_information4,
            l_activity_rec.tav_information5,
            l_activity_rec.tav_information6,
            l_activity_rec.tav_information7,
            l_activity_rec.tav_information8,
            l_activity_rec.tav_information9,
            l_activity_rec.tav_information10,
            l_activity_rec.tav_information11,
            l_activity_rec.tav_information12,
            l_activity_rec.tav_information13,
            l_activity_rec.tav_information14,
            l_activity_rec.tav_information15,
            l_activity_rec.tav_information16,
            l_activity_rec.tav_information17,
            l_activity_rec.tav_information18,
            l_activity_rec.tav_information19,
            l_activity_rec.tav_information20,
            l_activity_rec.activity_version_code,
            l_activity_rec.success_criteria,
            l_activity_rec.professional_credits,
            l_activity_rec.professional_credit_meaning,
            l_activity_rec.controlling_person_id,
            l_activity_rec.booking.status,
            l_activity_rec.booking.player_status,
            l_activity_rec.booking.booking_id,
            l_activity_rec.booking.delegate_person_id,
            l_activity_rec.booking.is_history_flag,
            l_activity_rec.booking.date_status_changed,
            l_activity_rec.booking.successful_attendance_flag,
            l_activity_rec.booking.is_mandatory_enrollment,
            l_event_id;
        IF get_activity_rec%NOTFOUND THEN
            RAISE invalid_delegate_booking_id;
        END IF;

                get_events(p_event_id                   => l_event_id,
                       p_activity_version_id    => l_activity_rec.activity_version_id,
                       p_events_tbl             => l_activity_rec.events);

        l_activity_tbl.EXTEND(1);
        l_activity_tbl(1) := l_activity_rec;
    CLOSE   get_activity_rec;
    p_activity_tbl := l_activity_tbl;
END get_training_details_internal;



PROCEDURE get_training_details_internal(p_course_id IN  ota_activity_versions.activity_id%TYPE
                                        ,p_activity_tbl  OUT NOCOPY activity_tabletype)
IS
CURSOR get_activity_rec IS
SELECT
          a.activity_version_id Activity_Version_Id,
            a.version_name Activity_Version_Name,
            a.description Activity_Description,
            a.objectives Activity_Objectives,
            a.intended_audience Activity_Audience,
            a.keywords Activity_Keywords,
            a.tav_information_category ,
            a.tav_information1,
            a.tav_information2,
            a.tav_information3,
            a.tav_information4,
            a.tav_information5,
            a.tav_information6,
            a.tav_information7,
            a.tav_information8,
            a.tav_information9,
            a.tav_information10,
            a.tav_information11,
            a.tav_information12,
            a.tav_information13,
            a.tav_information14,
            a.tav_information15,
            a.tav_information16,
            a.tav_information17,
            a.tav_information18,
            a.tav_information19,
            a.tav_information20,
            a.Version_Code Activity_Version_Code,
            hr_general_utilities.get_lookup_meaning('ACTIVITY_SUCCESS_CRITERIA', a.success_criteria) Success_Criteria,
            a.professional_credits,
            hr_general.decode_lookup('PROFESSIONAL_CREDIT_TYPE', a.professional_credit_type) Professional_Credit_Meaning,
            a.Controlling_Person_Id Controlling_Person_Id
    FROM    ota_activity_versions_vl a
    WHERE   a.activity_version_id = p_course_id;
            l_activity_rec      activity_rectype;
            l_activity_tbl      activity_tabletype;
BEGIN
    l_activity_tbl := activity_tabletype();
    OPEN get_activity_rec;
    FETCH   get_activity_rec INTO
            l_activity_rec.activity_version_id,
            l_activity_rec.activity_version_name,
            l_activity_rec.activity_description,
            l_activity_rec.activity_objectives,
            l_activity_rec.activity_audience,
            l_activity_rec.activity_keywords,
            l_activity_rec.tav_information_category,
            l_activity_rec.tav_information1,
            l_activity_rec.tav_information2,
            l_activity_rec.tav_information3,
            l_activity_rec.tav_information4,
            l_activity_rec.tav_information5,
            l_activity_rec.tav_information6,
            l_activity_rec.tav_information7,
            l_activity_rec.tav_information8,
            l_activity_rec.tav_information9,
            l_activity_rec.tav_information10,
            l_activity_rec.tav_information11,
            l_activity_rec.tav_information12,
            l_activity_rec.tav_information13,
            l_activity_rec.tav_information14,
            l_activity_rec.tav_information15,
            l_activity_rec.tav_information16,
            l_activity_rec.tav_information17,
            l_activity_rec.tav_information18,
            l_activity_rec.tav_information19,
            l_activity_rec.tav_information20,
            l_activity_rec.activity_version_code,
            l_activity_rec.success_criteria,
            l_activity_rec.professional_credits,
            l_activity_rec.professional_credit_meaning,
            l_activity_rec.controlling_person_id;
        IF get_activity_rec%NOTFOUND THEN
            RAISE invalid_course_id;
        END IF;

                get_events(p_event_id               => null,
                   p_activity_version_id    => l_activity_rec.activity_version_id,
                   p_events_tbl             => l_activity_rec.events);

        l_activity_tbl.EXTEND(1);
        l_activity_tbl(1) := l_activity_rec;
    CLOSE   get_activity_rec;
    p_activity_tbl := l_activity_tbl;
END get_training_details_internal;

PROCEDURE get_training_details_internal(p_start_person_id   IN  ota_delegate_bookings.delegate_person_id%TYPE,
                                        p_end_person_id     IN  ota_delegate_bookings.delegate_person_id%TYPE,
                                        p_activity_tbl  OUT NOCOPY activity_tabletype)
IS
CURSOR get_activity_rec IS
SELECT  distinct
a.activity_version_id Activity_Version_Id,
            a.version_name Activity_Version_Name,
            a.description Activity_Description,
            a.objectives Activity_Objectives,
            a.intended_audience Activity_Audience,
            a.keywords Activity_Keywords,
            a.tav_information_category ,
            a.tav_information1,
            a.tav_information2,
            a.tav_information3,
            a.tav_information4,
            a.tav_information5,
            a.tav_information6,
            a.tav_information7,
            a.tav_information8,
            a.tav_information9,
            a.tav_information10,
            a.tav_information11,
            a.tav_information12,
            a.tav_information13,
            a.tav_information14,
            a.tav_information15,
            a.tav_information16,
            a.tav_information17,
            a.tav_information18,
            a.tav_information19,
            a.tav_information20,
            a.Version_Code Activity_Version_Code,
            hr_general_utilities.get_lookup_meaning('ACTIVITY_SUCCESS_CRITERIA', a.success_criteria) Success_Criteria,
            a.professional_credits,
            hr_general.decode_lookup('PROFESSIONAL_CREDIT_TYPE', a.professional_credit_type) Professional_Credit_Meaning,
            a.Controlling_Person_Id Controlling_Person_Id,
            ST.NAME status,
             DECODE(C.ONLINE_FLAG ,'Y',OTA_LO_UTILITY.get_enroll_lo_status(NVL(D.delegate_person_id, D.contact_id), DECODE(D.delegate_person_id, NULL, 'C', 'E') , E.EVENT_ID,D.BOOKING_STATUS_TYPE_ID,D.BOOKING_ID,null,'N'), null) player_status
        ,D.BOOKING_ID
        ,D.DELEGATE_PERSON_ID
        ,D.IS_HISTORY_FLAG
        ,D.DATE_STATUS_CHANGED
                ,D.SUCCESSFUL_ATTENDANCE_FLAG
        , nvl(D.IS_MANDATORY_ENROLLMENT,'N') is_mandatory_enrollment
                ,E.EVENT_ID
    FROM    ota_activity_versions_vl a ,
            OTA_EVENTS E,
            OTA_EVENTS_TL ET,
                OTA_DELEGATE_BOOKINGS D,
                OTA_BOOKING_STATUS_TYPES S,
            OTA_BOOKING_STATUS_TYPES_TL ST,
                OTA_OFFERINGS O,
                OTA_OFFERINGS_TL OT,
                OTA_CATEGORY_USAGES C,
                OTA_CATEGORY_USAGES_TL CT,
            OTA_ACTIVITY_VERSIONS_TL OAV,
            OTA_EVALUATIONS EVAL
    WHERE   a.activity_version_id = e.activity_version_id
    AND OAV.ACTIVITY_VERSION_ID = a.ACTIVITY_VERSION_ID
    AND     E.EVENT_ID=D.EVENT_ID
    AND     S.BOOKING_STATUS_TYPE_ID=D.BOOKING_STATUS_TYPE_ID
    --AND     E.BUSINESS_GROUP_ID = OTA_GENERAL.GET_BUSINESS_GROUP_ID
    AND     E.PARENT_OFFERING_ID=O.OFFERING_ID
    AND     O.DELIVERY_MODE_ID = C.CATEGORY_USAGE_ID
    AND     a.ACTIVITY_VERSION_ID = O.ACTIVITY_VERSION_ID
    AND     OAV.LANGUAGE=USERENV('LANG')
    AND     E.EVENT_ID = ET.EVENT_ID
    AND     ET.LANGUAGE=USERENV('LANG')
    AND     S.BOOKING_STATUS_TYPE_ID = ST.BOOKING_STATUS_TYPE_ID
    AND     ST.LANGUAGE=USERENV('LANG')
    AND     O.OFFERING_ID = OT.OFFERING_ID
    AND     OT.LANGUAGE=USERENV('LANG')
    AND     C.CATEGORY_USAGE_ID = CT.CATEGORY_USAGE_ID
    AND     CT.LANGUAGE=USERENV('LANG')
    AND     E.EVENT_TYPE IN ('SCHEDULED','SELFPACED')
    AND     E.BOOK_INDEPENDENT_FLAG = 'N'
    AND     E.EVENT_ID = EVAL.OBJECT_ID(+)
    AND     (EVAL.OBJECT_TYPE is null or EVAL.OBJECT_TYPE = 'E')
    AND     D.SUCCESSFUL_ATTENDANCE_FLAG = 'Y'
    AND     D.delegate_person_id BETWEEN nvl(p_start_person_id, D.delegate_person_id)
            AND  nvl(p_end_person_id, D.delegate_person_id);

            l_activity_rec      activity_rectype;
            l_activity_tbl      activity_tabletype;
            l_count             NUMBER := 1;
                        l_event_id        ota_events.event_id%TYPE;
      BEGIN
      l_activity_tbl := activity_tabletype();

    OPEN get_activity_rec;
    LOOP
        FETCH   get_activity_rec INTO
                l_activity_rec.activity_version_id,
                l_activity_rec.activity_version_name,
                l_activity_rec.activity_description,
                l_activity_rec.activity_objectives,
                l_activity_rec.activity_audience,
                l_activity_rec.activity_keywords,
                l_activity_rec.tav_information_category,
                l_activity_rec.tav_information1,
                l_activity_rec.tav_information2,
                l_activity_rec.tav_information3,
                l_activity_rec.tav_information4,
                l_activity_rec.tav_information5,
                l_activity_rec.tav_information6,
                l_activity_rec.tav_information7,
                l_activity_rec.tav_information8,
                l_activity_rec.tav_information9,
                l_activity_rec.tav_information10,
                l_activity_rec.tav_information11,
                l_activity_rec.tav_information12,
                l_activity_rec.tav_information13,
                l_activity_rec.tav_information14,
                l_activity_rec.tav_information15,
                l_activity_rec.tav_information16,
                l_activity_rec.tav_information17,
                l_activity_rec.tav_information18,
                l_activity_rec.tav_information19,
                l_activity_rec.tav_information20,
                l_activity_rec.activity_version_code,
                l_activity_rec.success_criteria,
                l_activity_rec.professional_credits,
                l_activity_rec.professional_credit_meaning,
                l_activity_rec.controlling_person_id,
                l_activity_rec.booking.status,
                l_activity_rec.booking.player_status,
                l_activity_rec.booking.BOOKING_ID,
                l_activity_rec.booking.delegate_person_id,
                l_activity_rec.booking.IS_HISTORY_FLAG,
                l_activity_rec.booking.DATE_STATUS_CHANGED,
                l_activity_rec.booking.SUCCESSFUL_ATTENDANCE_FLAG,
                l_activity_rec.booking.is_mandatory_enrollment,
                l_event_id;
        IF get_activity_rec%NOTFOUND THEN
            EXIT;
        END IF;

                get_events(p_event_id               => l_event_id,
                       p_activity_version_id    => l_activity_rec.activity_version_id,
                       p_events_tbl             => l_activity_rec.events);

        l_activity_tbl.EXTEND(1);
        l_activity_tbl(l_count) := l_activity_rec;
        l_count := l_count + 1;
    END LOOP;
    CLOSE   get_activity_rec;
    p_activity_tbl := l_activity_tbl;
END get_training_details_internal;

PROCEDURE get_booking_status(p_delegate_booking_id IN   ota_delegate_bookings.booking_id%TYPE,
                             p_status_name         OUT NOCOPY  ota_booking_status_types_VL.name%TYPE,
                             p_status_type         OUT NOCOPY  ota_booking_status_types_VL.type%TYPE)
IS
CURSOR get_status IS
    SELECT s.name,
           s.type
    FROM   ota_delegate_bookings b,
           ota_booking_status_types_VL s
    WHERE  b.booking_status_type_id = s.booking_status_type_id
    AND    b.booking_id = p_delegate_booking_id;

l_name      ota_booking_status_types_VL.name%TYPE;
l_type      ota_booking_status_types_VL.type%TYPE;

BEGIN
    OPEN    get_status;
    FETCH   get_status INTO
            l_name,
            l_type;
    CLOSE   get_status;
    p_status_name := l_name;
    p_status_type := l_type;
END get_booking_status;

PROCEDURE get_training_details(p_query_options               IN   course_query_input_rectype,
                               p_training                    OUT NOCOPY  activity_tabletype,
                               p_certifications              OUT NOCOPY  certification_tabletype,
                               p_ispartofcertification       OUT NOCOPY  BOOLEAN)
IS
l_person_id             ota_delegate_bookings.delegate_person_id%TYPE := NULL;
l_activity_version_id   ota_activity_versions.activity_id%TYPE := NULL;
l_cert_enrollment_id    ota_cert_enrollments.cert_enrollment_id%TYPE;
l_event_id              ota_events.event_id%TYPE := NULL;
l_activity_rec          activity_rectype;
l_event_rec             event_rectype;

l_events_tbl            event_tabletype;
l_activity_tbl          activity_tabletype;

l_event_action          VARCHAR2(50);
l_is_part_of_certification      BOOLEAN := FALSE;
l_status_name           ota_booking_status_types_VL.name%TYPE;
l_status_type           ota_booking_status_types_VL.type%TYPE;

--certification input options
l_cert_input_options   cert_query_input_rectype;
l_certifications_tbl   certification_tabletype;
l_query_options   query_options;
BEGIN

    IF p_query_options.person_id  IS NOT NULL THEN
        IF p_query_options.view_history THEN
            get_training_details_internal(p_person_id       => p_query_options.person_id
                                         ,p_start_person_id => p_query_options.start_person_id
                                         ,p_end_person_id   => p_query_options.end_person_id
                                         ,p_view_history    => 'Y'
                                         ,p_activity_tbl    => l_activity_tbl);
        ELSE
            get_training_details_internal(p_person_id       => p_query_options.person_id
                                         ,p_start_person_id => p_query_options.start_person_id
                                         ,p_end_person_id   => p_query_options.end_person_id
                                         ,p_view_history    => 'N'
                                         ,p_activity_tbl    => l_activity_tbl);
        END IF;
    ELSIF p_query_options.course_id IS NOT NULL THEN
            get_training_details_internal(p_course_id       => p_query_options.course_id
                                         ,p_activity_tbl    => l_activity_tbl);
    ELSIF p_query_options.delegate_booking_id IS NOT NULL THEN
            get_training_details_internal(p_booking_id      => p_query_options.delegate_booking_id
                                         ,p_activity_tbl    => l_activity_tbl);
    ELSE
            get_training_details_internal(p_start_person_id => p_query_options.start_person_id
                                         ,p_end_person_id   => p_query_options.end_person_id
                                         ,p_activity_tbl    => l_activity_tbl);
    END IF;

    --get status of booking
    get_booking_status(p_delegate_booking_id => p_query_options.delegate_booking_id,
                         p_status_name       => l_status_name,
                         p_status_type       => l_status_type);

    --set event action in training record
    IF l_status_type='A' AND (upper(l_status_name) ='ATTENDED' OR upper(l_status_name) ='PASSED') THEN
        l_event_action := 'TRAINING_COMPLETED';
    ELSIF l_status_type='A' AND (upper(l_status_name) ='FAILED') THEN
        l_event_action := 'TRAINING_FAILED';
    ELSIF l_status_type='R' THEN
        l_event_action := 'TRAINING_REQUESTED';
    ELSIF l_status_type='P' THEN
        l_event_action := 'TRAINING_ENROLLED';
    ELSIF l_status_type='W' THEN
        l_event_action := 'TRAINING_WAITLISTED';
    ELSIF l_status_type='C' THEN
        l_event_action := 'TRAINING_CANCELLED';
    END IF;

    --if part of certification fetch the certification and pass it to the output also
        IF p_query_options.delegate_booking_id IS NOT NULL THEN

        l_is_part_of_certification := is_part_of_certification(p_query_options.delegate_booking_id,l_cert_enrollment_id);

            IF l_is_part_of_certification THEN
                l_query_options(1) := 'DETAIL';
                l_query_options(2) := 'COMPETENCY';
                l_query_options(3) := 'COMPONENT';
                l_cert_input_options.options := l_query_options;
                l_cert_input_options.cert_enrollment_id := l_cert_enrollment_id;
                get_certification_details(p_query_options   => l_cert_input_options,
                                          p_certifications  => l_certifications_tbl);

                -- set output
                p_ispartofcertification := l_is_part_of_certification;
                p_certifications := l_certifications_tbl;
            ELSE
                p_certifications := certification_tabletype();
                p_ispartofcertification := NULL;
            END IF;
        ELSE
            p_certifications := certification_tabletype();
            p_ispartofcertification := NULL;
        END IF;

    --set the event action if delegate booking is passed
    IF p_query_options.delegate_booking_id IS NOT NULL AND l_activity_tbl.COUNT = 1 THEN
        l_activity_tbl(1).event_action := l_event_action;
    END IF;

    p_training := l_activity_tbl;
EXCEPTION
    WHEN invalid_delegate_booking_id THEN
        p_training := activity_tabletype();
        p_certifications := certification_tabletype();
        p_ispartofcertification := NULL;
    WHEN invalid_course_id THEN
        p_training := activity_tabletype();
        p_certifications := certification_tabletype();
        p_ispartofcertification := NULL;
    WHEN invalid_person_id THEN
        p_training := activity_tabletype();
        p_certifications := certification_tabletype();
        p_ispartofcertification := NULL;
END get_training_details;
END ota_training_record;

/
