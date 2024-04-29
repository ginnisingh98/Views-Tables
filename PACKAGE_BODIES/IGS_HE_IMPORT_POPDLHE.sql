--------------------------------------------------------
--  DDL for Package Body IGS_HE_IMPORT_POPDLHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_IMPORT_POPDLHE" AS
/* $Header: IGSHE26B.pls 120.1 2006/02/08 20:03:59 anwest noship $ */

TYPE popdlhe_dtls IS RECORD (
    popdlhe_id  igs_he_popdlhe_ints.popdlhe_id%TYPE,
    husid       igs_he_popdlhe_ints.husid%TYPE,
    ownstu      igs_he_popdlhe_ints.ownstu%TYPE,
    xqmode01    igs_he_popdlhe_ints.xqmode01%TYPE,
    ttcid       igs_he_popdlhe_ints.ttcid%TYPE);

-- Function Declarations
FUNCTION  validate_popdlhe(p_popdlhe_dtls IN popdlhe_dtls) RETURN BOOLEAN;

FUNCTION get_person_id(p_popdlhe_dtls IN popdlhe_dtls) RETURN NUMBER;

PROCEDURE log_results(p_return_name      IN  igs_he_sub_rtn_qual.return_name%TYPE,
                      p_qual_period      IN  igs_he_sub_rtn_qual.qual_period_code%TYPE,
                      p_total_dlhe_cnt   IN NUMBER,
                      p_new_dlhe_cnt     IN NUMBER,
                      p_upd_dlhe_cnt     IN NUMBER,
                      p_fail_dlhe_cnt    IN NUMBER,
                      p_not_mod_dlhe_cnt IN NUMBER);


PROCEDURE import_popdlhe_to_oss (errbuf            OUT NOCOPY VARCHAR2,
                                 retcode           OUT NOCOPY NUMBER,
                                 p_submission_name IN  igs_he_sub_rtn_qual.submission_name%TYPE,
                                 p_return_name     IN  igs_he_sub_rtn_qual.return_name%TYPE,
                                 p_qual_period     IN  igs_he_sub_rtn_qual.qual_period_code%TYPE,
                                 p_census_date     IN  VARCHAR2 ) IS
 /******************************************************************
  Created By      : Jonathan Baber
  Date Created By : 24-Aug-05
  Purpose         : Processes records from IGS_HE_POPDLHE_INTS interface table and
                    updates or inserts corresponding records in igs_he_stdnt_dlhe table
  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
  anwest    18-JAN-2006  Bug# 4950285 R12 Disable OSS Mandate
 *******************************************************************/


    -- Type defs
    TYPE c_popdlhe_typ IS REF CURSOR;
    c_popdlhe    c_popdlhe_typ;


    -- Cursor Defs
    -- cursor to retrieve student dlhe rec infor
    CURSOR c_dlhe_rec(cp_person_id igs_he_stdnt_dlhe.person_id%TYPE) IS
    SELECT dlhe.rowid, dlhe.*
      FROM igs_he_stdnt_dlhe dlhe
     WHERE person_id = cp_person_id
       AND submission_name = p_submission_name
       AND return_name = p_return_name;

    -- cursor to retrieve qualification period details
    CURSOR c_qual_dets (cp_submission_name igs_he_sub_rtn_qual.submission_name%TYPE,
                        cp_return_name     igs_he_sub_rtn_qual.return_name%TYPE,
                        cp_qual_period     igs_he_sub_rtn_qual.qual_period_code%TYPE) IS
    SELECT qual_period_type, qual_period_desc, user_return_subclass, closed_ind
      FROM igs_he_sub_rtn_qual qual
     WHERE qual.submission_name = cp_submission_name
       AND qual.return_name = cp_return_name
       AND qual.qual_period_code = cp_qual_period;


    -- Variable Defs
    l_qualified_teacher  igs_he_stdnt_dlhe.qualified_teacher%TYPE;
    l_pt_study           igs_he_stdnt_dlhe.pt_study%TYPE;
    l_qual_period        igs_he_stdnt_dlhe.qual_period_code%TYPE;
    l_person_id          igs_he_stdnt_dlhe.person_id%TYPE;
    l_qual_dets          c_qual_dets%ROWTYPE;
    l_upd_qual_dets      c_qual_dets%ROWTYPE;
    l_dlhe_rec           c_dlhe_rec%ROWTYPE;
    l_sql_stmt           VARCHAR2(1000);
    l_rowid              VARCHAR2(30);
    l_popdlhe_dtls       popdlhe_dtls;
    l_include            BOOLEAN;

    -- Counters for logging
    l_total_dlhe_cnt     NUMBER := 0;
    l_new_dlhe_cnt       NUMBER := 0;
    l_upd_dlhe_cnt       NUMBER := 0;
    l_fail_dlhe_cnt      NUMBER := 0;
    l_not_mod_dlhe_cnt   NUMBER := 0;

 BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    -- Get Qualifying Period
    OPEN c_qual_dets(p_submission_name, p_return_name, p_qual_period);
    FETCH c_qual_dets INTO l_qual_dets;
    CLOSE c_qual_dets;


    -- Report the Qualifying period details in the log file
    fnd_message.set_name('IGS','IGS_HE_DLHE_QUAL_PERIOD');
    fnd_message.set_token('QUAL_PERIOD',p_qual_period);
    fnd_message.set_token('DESC',l_qual_dets.qual_period_desc);
    fnd_message.set_token('TYPE',l_qual_dets.qual_period_type);
    fnd_file.put_line(fnd_file.log,fnd_message.get);


    --Validate Parameters
    IF l_qual_dets.qual_period_type = 'R' AND p_census_date IS NOT NULL THEN

        -- Set warning for 'R' qual type and census date
        fnd_message.set_name('IGS','IGS_HE_DLHE_CENSUS');
        fnd_file.put_line(fnd_file.log, fnd_message.get);

    ELSIF l_qual_dets.qual_period_type = 'L' AND p_census_date IS NULL THEN

        -- Set error for 'L' qual type and census date and exit
        fnd_message.set_name('IGS','IGS_HE_DLHE_NO_CENSUS');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        errbuf  := fnd_message.get ;
        retcode := 2;
        RETURN;

    END IF;


    -- Construct and open POPDLHE query depending on qualification type
    IF l_qual_dets.qual_period_type = 'L' THEN

        l_sql_stmt := 'SELECT popdlhe_id, husid, ownstu, xqmode01, ttcid ' ||
                     'FROM igs_he_popdlhe_ints ' ||
                     'WHERE popdlhe = ''1'' ' ||
                     'AND census = :1' ;
        OPEN c_popdlhe FOR l_sql_stmt USING p_census_date;

    ELSIF l_qual_dets.qual_period_type = 'R' THEN

        l_sql_stmt := 'SELECT popdlhe_id, husid, ownstu, xqmode01, ttcid ' ||
                     'FROM igs_he_popdlhe_ints ' ||
                     'WHERE rcident IN (''1'',''2'',''3'',''4'',''5'',''6'',''7'') ';
        OPEN c_popdlhe FOR l_sql_stmt;

    END IF;


    -- Loop through all popdlhe records
    LOOP
        FETCH c_popdlhe INTO l_popdlhe_dtls;
        EXIT WHEN c_popdlhe%NOTFOUND;

        l_include := TRUE;

        -- Increment total dlhe record count
        l_total_dlhe_cnt := l_total_dlhe_cnt + 1;


        -- Validate POPDLHE Interface Record
        IF NOT validate_popdlhe(l_popdlhe_dtls) THEN
            l_include := FALSE;
            l_fail_dlhe_cnt := l_fail_dlhe_cnt + 1;
        END IF;


        -- Get PersonID from POPDLHE record
        IF l_include THEN
            l_person_id := get_person_id(l_popdlhe_dtls);

            IF l_person_id IS NULL THEN
                l_include := FALSE;
                l_fail_dlhe_cnt := l_fail_dlhe_cnt + 1;
            END IF;
        END IF;


        IF l_include THEN

            -- Check if Stdnt DLHE record exists
            OPEN c_dlhe_rec(l_person_id);
            FETCH c_dlhe_rec INTO l_dlhe_rec;

            IF c_dlhe_rec%FOUND THEN
                -- Record already exists so may need updating

                 -- Get qual details for existing record
             OPEN c_qual_dets (p_submission_name,
                               p_return_name,
                               l_dlhe_rec.qual_period_code);
             FETCH c_qual_dets INTO l_upd_qual_dets;
                 CLOSE c_qual_dets;

                 -- Need to update record if popdlhe = 'N' or it exists in closed qualifying period
                 IF l_dlhe_rec.popdlhe_flag = 'N' OR l_upd_qual_dets.closed_ind = 'Y' THEN

                     -- If record in closed qualifying period use user selected qualifying period
                     IF l_upd_qual_dets.closed_ind = 'Y' THEN
                         l_qual_period := p_qual_period;
                     ELSE
                         l_qual_period := l_dlhe_rec.qual_period_code;
                     END IF;

                     -- Update record
                     igs_he_stdnt_dlhe_pkg.update_row(
                         x_rowid                     => l_dlhe_rec.rowid,
                         x_person_id                 => l_dlhe_rec.person_id,
                         x_submission_name           => l_dlhe_rec.submission_name,
                         x_user_return_subclass      => l_dlhe_rec.user_return_subclass ,
                         x_return_name               => l_dlhe_rec.return_name,
                         x_qual_period_code          => l_qual_period,
                         x_dlhe_record_status        => l_dlhe_rec.dlhe_record_status,
                         x_participant_source        => l_dlhe_rec.participant_source,
                         x_date_status_changed       => l_dlhe_rec.date_status_changed,
                         x_validation_status         => l_dlhe_rec.validation_status,
                         x_admin_coding              => l_dlhe_rec.admin_coding,
                         x_survey_method             => l_dlhe_rec.survey_method,
                         x_employment                => l_dlhe_rec.employment,
                         x_further_study             => l_dlhe_rec.further_study,
                         x_qualified_teacher         => l_dlhe_rec.qualified_teacher,
                         x_pt_study                  => l_dlhe_rec.pt_study,
                         x_employer_business         => l_dlhe_rec.employer_business,
                         x_employer_name             => l_dlhe_rec.employer_name,
                         x_employer_classification   => l_dlhe_rec.employer_classification,
                         x_employer_location         => l_dlhe_rec.employer_location,
                         x_employer_postcode         => l_dlhe_rec.employer_postcode,
                         x_employer_country          => l_dlhe_rec.employer_country,
                         x_job_title                 => l_dlhe_rec.job_title,
                         x_job_duties                => l_dlhe_rec.job_duties,
                         x_job_classification        => l_dlhe_rec.job_classification,
                         x_employer_size             => l_dlhe_rec.employer_size,
                         x_job_duration              => l_dlhe_rec.job_duration,
                         x_job_salary                => l_dlhe_rec.job_salary,
                         x_salary_refused            => l_dlhe_rec.salary_refused,
                         x_qualification_requirement => l_dlhe_rec.qualification_requirement,
                         x_qualification_importance  => l_dlhe_rec.qualification_importance,
                         x_job_reason1               => l_dlhe_rec.job_reason1,
                         x_job_reason2               => l_dlhe_rec.job_reason2,
                         x_job_reason3               => l_dlhe_rec.job_reason3,
                         x_job_reason4               => l_dlhe_rec.job_reason4,
                         x_job_reason5               => l_dlhe_rec.job_reason5,
                         x_job_reason6               => l_dlhe_rec.job_reason6,
                         x_job_reason7               => l_dlhe_rec.job_reason7,
                         x_job_reason8               => l_dlhe_rec.job_reason8,
                         x_other_job_reason          => l_dlhe_rec.other_job_reason,
                         x_no_other_job_reason       => l_dlhe_rec.no_other_job_reason,
                         x_job_source                => l_dlhe_rec.job_source,
                         x_other_job_source          => l_dlhe_rec.other_job_source,
                         x_no_other_job_source       => l_dlhe_rec.no_other_job_source,
                         x_previous_job              => l_dlhe_rec.previous_job,
                         x_previous_jobtype1         => l_dlhe_rec.previous_jobtype1,
                         x_previous_jobtype2         => l_dlhe_rec.previous_jobtype2,
                         x_previous_jobtype3         => l_dlhe_rec.previous_jobtype3,
                         x_previous_jobtype4         => l_dlhe_rec.previous_jobtype4,
                         x_previous_jobtype5         => l_dlhe_rec.previous_jobtype5,
                         x_previous_jobtype6         => l_dlhe_rec.previous_jobtype6,
                         x_further_study_type        => l_dlhe_rec.further_study_type,
                         x_course_name               => l_dlhe_rec.course_name,
                         x_course_training_subject   => l_dlhe_rec.course_training_subject,
                         x_research_subject          => l_dlhe_rec.research_subject,
                         x_research_training_subject => l_dlhe_rec.research_training_subject,
                         x_further_study_provider    => l_dlhe_rec.further_study_provider,
                         x_further_study_qualaim     => l_dlhe_rec.further_study_qualaim,
                         x_professional_qualification=> l_dlhe_rec.professional_qualification,
                         x_study_reason1             => l_dlhe_rec.study_reason1,
                         x_study_reason2             => l_dlhe_rec.study_reason2,
                         x_study_reason3             => l_dlhe_rec.study_reason3,
                         x_study_reason4             => l_dlhe_rec.study_reason4,
                         x_study_reason5             => l_dlhe_rec.study_reason5,
                         x_study_reason6             => l_dlhe_rec.study_reason6,
                         x_study_reason7             => l_dlhe_rec.study_reason7,
                         x_other_study_reason        => l_dlhe_rec.other_study_reason,
                         x_no_other_study_reason     => l_dlhe_rec.no_other_study_reason,
                         x_employer_sponsored        => l_dlhe_rec.employer_sponsored,
                         x_funding_source            => l_dlhe_rec.funding_source,
                         x_teacher_teaching          => l_dlhe_rec.teacher_teaching,
                         x_teacher_seeking           => l_dlhe_rec.teacher_seeking,
                         x_teaching_sector           => l_dlhe_rec.teaching_sector,
                         x_teaching_level            => l_dlhe_rec.teaching_level,
                         x_reason_for_ptcourse       => l_dlhe_rec.reason_for_ptcourse,
                         x_job_while_studying        => l_dlhe_rec.job_while_studying,
                         x_employer_support1         => l_dlhe_rec.employer_support1,
                         x_employer_support2         => l_dlhe_rec.employer_support2,
                         x_employer_support3         => l_dlhe_rec.employer_support3,
                         x_employer_support4         => l_dlhe_rec.employer_support4,
                         x_employer_support5         => l_dlhe_rec.employer_support5,
                         x_popdlhe_flag              => 'Y'
                         );

                     -- Increment update count
                     l_upd_dlhe_cnt := l_upd_dlhe_cnt + 1;

                 ELSE
                     -- If no need to update, then update not mod counter
                     l_not_mod_dlhe_cnt := l_not_mod_dlhe_cnt + 1;
                 END IF;

            ELSE
                -- Record is new so insert

                -- Determine qualified teacher status from ttcid field
                IF l_popdlhe_dtls.ttcid = 0 THEN
                    l_qualified_teacher  := 'N';
                ELSE
                    l_qualified_teacher  := 'Y';
                END IF;

                -- Determine part time study status from xqmode01 field
                IF l_popdlhe_dtls.xqmode01 = 2 THEN
                    l_pt_study := 'Y';
                ELSE
                    l_pt_study := 'N';
                END IF;

                igs_he_stdnt_dlhe_pkg.insert_row(
            x_rowid                        => l_rowid,
              x_person_id                  => l_person_id,
              x_submission_name            => p_submission_name,
              x_user_return_subclass       => l_qual_dets.user_return_subclass,
              x_return_name                => p_return_name,
              x_qual_period_code           => p_qual_period,
              x_dlhe_record_status         => 'NST',
              x_participant_source         => 'P',
              x_date_status_changed        => NULL,
              x_validation_status          => NULL,
              x_admin_coding               => NULL,
              x_survey_method              => NULL,
              x_employment                 => NULL,
              x_further_study              => NULL,
              x_qualified_teacher          => l_qualified_teacher,
              x_pt_study                   => l_pt_study,
              x_employer_business          => NULL,
              x_employer_name              => NULL,
              x_employer_classification    => NULL,
              x_employer_location          => NULL,
              x_employer_postcode          => NULL,
              x_employer_country           => NULL,
              x_job_title                  => NULL,
              x_job_duties                 => NULL,
              x_job_classification         => NULL,
              x_employer_size              => NULL,
              x_job_duration               => NULL,
              x_job_salary                 => NULL,
              x_salary_refused             => 'N',
              x_qualification_requirement  => NULL,
              x_qualification_importance   => NULL,
              x_job_reason1                => 'N',
              x_job_reason2                => 'N',
              x_job_reason3                => 'N',
              x_job_reason4                => 'N',
              x_job_reason5                => 'N',
              x_job_reason6                => 'N',
              x_job_reason7                => 'N',
              x_job_reason8                => 'N',
              x_other_job_reason           => NULL,
              x_no_other_job_reason        => 'N',
              x_job_source                 => NULL,
              x_other_job_source           => NULL,
              x_no_other_job_source        => 'N',
              x_previous_job               => NULL,
              x_previous_jobtype1          => 'N',
              x_previous_jobtype2          => 'N',
              x_previous_jobtype3          => 'N',
              x_previous_jobtype4          => 'N',
              x_previous_jobtype5          => 'N',
              x_previous_jobtype6          => 'N',
              x_further_study_type         => NULL,
              x_course_name                => NULL,
              x_course_training_subject    => NULL,
              x_research_subject           => NULL,
              x_research_training_subject  => NULL,
              x_further_study_provider     => NULL,
              x_further_study_qualaim      => NULL,
              x_professional_qualification => NULL,
              x_study_reason1              => NULL,
              x_study_reason2              => 'N',
              x_study_reason3              => 'N',
              x_study_reason4              => 'N',
              x_study_reason5              => 'N',
              x_study_reason6              => 'N',
              x_study_reason7              => 'N',
              x_other_study_reason         => NULL,
              x_no_other_study_reason      => 'N',
              x_employer_sponsored         => 'N',
              x_funding_source             => NULL,
              x_teacher_teaching           => 'N',
              x_teacher_seeking            => 'N',
              x_teaching_sector            => NULL,
              x_teaching_level             => NULL,
              x_reason_for_ptcourse        => NULL,
              x_job_while_studying         => 'N',
              x_employer_support1          => 'N',
              x_employer_support2          => 'N',
              x_employer_support3          => 'N',
              x_employer_support4          => 'N',
              x_employer_support5          => 'N',
              x_popdlhe_flag               => 'Y'
            );

                -- update new counter
                l_new_dlhe_cnt := l_new_dlhe_cnt+1;

            END IF; -- c_dlhe_rec%FOUND

            CLOSE c_dlhe_rec;

        END IF;

    END LOOP;

    CLOSE c_popdlhe;


    -- Log counters
    log_results(p_return_name, p_qual_period, l_total_dlhe_cnt, l_new_dlhe_cnt, l_upd_dlhe_cnt, l_fail_dlhe_cnt, l_not_mod_dlhe_cnt);


    EXCEPTION
     WHEN OTHERS THEN

        -- close any open cursors
        IF c_popdlhe%ISOPEN THEN
            CLOSE c_popdlhe;
        END IF;

        IF c_dlhe_rec%ISOPEN THEN
            CLOSE c_dlhe_rec;
        END IF;

        ROLLBACK;
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','igs_he_import_popdlhe.import_popdlhe_to_oss - ' || SQLERRM);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        errbuf  := fnd_message.get ;
        retcode := 2;

        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

END import_popdlhe_to_oss;


FUNCTION validate_popdlhe(p_popdlhe_dtls IN popdlhe_dtls) RETURN BOOLEAN IS
 /******************************************************************
  Created By      : Jonathan Baber
  Date Created By : 24-Aug-05
  Purpose         : Validates POPDLHE Interface table records
  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
 *******************************************************************/

   l_error_message  VARCHAR2(100);
   l_error_husid    BOOLEAN := FALSE;
   l_error_xqmode01 BOOLEAN := FALSE;
   l_error_ttcid    BOOLEAN := FALSE;
   l_error_cnt      NUMBER := 0;
   l_temp           NUMBER;
BEGIN


    -- Check HUSID
    -- 1) Should not be null
    -- 2) Should be numeric
    -- 3) Should be 13 characters in length
    BEGIN
        l_temp := TO_NUMBER(p_popdlhe_dtls.husid);
        IF p_popdlhe_dtls.husid IS NULL OR LENGTH(p_popdlhe_dtls.husid) <> 13 THEN
            l_error_husid := TRUE;
        END IF;
    EXCEPTION
     WHEN VALUE_ERROR THEN
        l_error_husid := TRUE;
    END;

    -- Check XQMode01
    -- 1) Should not be null
    -- 2) Should be numeric
    -- 3) Should be either 1 or 2
    BEGIN
        IF p_popdlhe_dtls.xqmode01 IS NULL OR TO_NUMBER(p_popdlhe_dtls.xqmode01) NOT IN (1,2) THEN
            l_error_xqmode01 := TRUE;
        END IF;
    EXCEPTION
     WHEN VALUE_ERROR THEN
        l_error_xqmode01 := TRUE;
    END;

    -- Check TTCID
    -- 1) Should not be null
    -- 2) Should be numeric
    -- 3) Should be between 0 and 7
    BEGIN
        IF p_popdlhe_dtls.ttcid IS NULL OR TO_NUMBER(p_popdlhe_dtls.ttcid) NOT BETWEEN 0 AND 7 THEN
            l_error_ttcid := TRUE;
        END IF;
    EXCEPTION
     WHEN VALUE_ERROR THEN
        l_error_ttcid := TRUE;
    END;

    IF NOT l_error_husid AND NOT l_error_xqmode01 AND NOT l_error_ttcid THEN
        -- If no errors return TRUE
        RETURN TRUE;
    ELSE
        -- If errors, log error message and return FALSE
        IF l_error_husid THEN
            l_error_message := 'HUSID';
            l_error_cnt := l_error_cnt + 1;
        END IF;

        IF l_error_xqmode01 THEN
            IF l_error_cnt = 0 THEN
                l_error_message := 'XQMode01';
            ELSIF l_error_cnt = 1 THEN
                l_error_message := 'XQMode01 and ' || l_error_message;
            ELSE
                l_error_message := 'XQMode01, ' || l_error_message;
            END IF;
            l_error_cnt := l_error_cnt + 1;
        END IF;

        IF l_error_ttcid THEN
            IF l_error_cnt = 0 THEN
                l_error_message := 'TTCID';
            ELSIF l_error_cnt = 1 THEN
                l_error_message := 'TTCID and ' || l_error_message;
            ELSE
                l_error_message := 'TTCID, ' || l_error_message;
            END IF;
            l_error_cnt := l_error_cnt + 1;
        END IF;

        Fnd_Message.Set_Name('IGS','IGS_HE_DLHE_FAIL_FIELD_DERIVE');
        Fnd_Message.Set_Token('FIELD',l_error_message);
        Fnd_Message.Set_Token('POPDLHE_ID',p_popdlhe_dtls.popdlhe_id);
        Fnd_Message.Set_Token('HUSID',p_popdlhe_dtls.husid);
        fnd_file.put_line(fnd_file.log, fnd_message.get);

        RETURN FALSE;
    END IF;

    EXCEPTION
     WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','igs_he_import_popdlhe.validate_popdlhe - ' ||SQLERRM);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        App_Exception.Raise_Exception;

END validate_popdlhe;


FUNCTION get_person_id(p_popdlhe_dtls IN popdlhe_dtls) RETURN NUMBER IS
 /******************************************************************
  Created By      : Jonathan Baber
  Date Created By : 24-Aug-05
  Purpose         : Retrieves PersonID from either ownstu or husid
  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
 *******************************************************************/
    -- Determines PersonID from ownstu (party number)
    CURSOR c_ownstu (cp_ownstu igs_he_popdlhe_ints.ownstu%TYPE) IS
    SELECT party_id
    FROM hz_parties
    WHERE party_number = cp_ownstu;

    -- Determines PersonID from alternateID table using HUSID
    CURSOR c_husid (cp_husid igs_he_popdlhe_ints.husid%TYPE) IS
    SELECT pe_person_id
    FROM igs_pe_alt_pers_id
    WHERE api_person_id = cp_husid
      AND person_id_type= 'HUSID'
      AND (end_dt IS NULL OR start_dt <> end_dt)
    ORDER BY start_dt DESC;

    l_person_id     NUMBER;

BEGIN

    -- try using owntsu to lookup hz_parties first
    IF p_popdlhe_dtls.ownstu IS NOT NULL THEN

        OPEN c_ownstu(p_popdlhe_dtls.ownstu);
        FETCH c_ownstu INTO l_person_id;
        CLOSE c_ownstu;

        IF l_person_id IS NOT NULL THEN
            RETURN l_person_id;
        END IF;

    END IF;

    -- resort to HUSID
    OPEN c_husid(p_popdlhe_dtls.husid);
    FETCH c_husid INTO l_person_id;
    CLOSE c_husid;

    IF l_person_id IS NOT NULL THEN
        RETURN l_person_id;
    END IF;

    -- At this stage we have not found person id
    -- return NULL and log message
    Fnd_Message.Set_Name('IGS','IGS_HE_DLHE_FAIL_PERSON_DERIVE');
    Fnd_Message.Set_Token('POPDLHE_ID',p_popdlhe_dtls.popdlhe_id);
    Fnd_Message.Set_Token('HUSID',p_popdlhe_dtls.husid);
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    RETURN NULL;


    EXCEPTION
     WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','igs_he_import_popdlhe.get_person_id - ' ||SQLERRM);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        App_Exception.Raise_Exception;

END get_person_id;


PROCEDURE log_results(p_return_name      IN  igs_he_sub_rtn_qual.return_name%TYPE,
                      p_qual_period      IN  igs_he_sub_rtn_qual.qual_period_code%TYPE,
                      p_total_dlhe_cnt   IN NUMBER,
                      p_new_dlhe_cnt     IN NUMBER,
                      p_upd_dlhe_cnt     IN NUMBER,
                      p_fail_dlhe_cnt    IN NUMBER,
                      p_not_mod_dlhe_cnt IN NUMBER) IS
 /******************************************************************
  Created By      : Jonathan Baber
  Date Created By : 24-Aug-05
  Purpose         : Logs process stats
  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
 *******************************************************************/
BEGIN

    -- Report the total number of DLHE records processed
    fnd_message.set_name('IGS','IGS_HE_DLHE_IMP_IDENT_POP');
    fnd_message.set_token('TOTAL_DLHE', p_total_dlhe_cnt);
    fnd_message.set_token('RETURN_NAME',p_return_name);
    fnd_message.set_token('QUAL_PERIOD',p_qual_period);
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Report the total number of new student DLHE records created
    fnd_message.set_name('IGS','IGS_HE_DLHE_REC_CREATED');
    fnd_message.set_token('CREATED_DLHE', p_new_dlhe_cnt);
    fnd_message.set_token('RETURN_NAME',p_return_name);
    fnd_message.set_token('QUAL_PERIOD',p_qual_period);
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Report the total number of student DLHE records updated with the current qualifying period
    fnd_message.set_name('IGS','IGS_HE_DLHE_REC_UPDATED');
    fnd_message.set_token('UPDATED_DLHE', p_upd_dlhe_cnt);
    fnd_message.set_token('RETURN_NAME',p_return_name);
    fnd_message.set_token('QUAL_PERIOD',p_qual_period);
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Report the total number of students failed to satisfy the field validations
    fnd_message.set_name('IGS','IGS_HE_DLHE_FAILED_STD');
    fnd_message.set_token('FAIL_DLHE', p_fail_dlhe_cnt);
    fnd_message.set_token('RETURN_NAME',p_return_name);
    fnd_message.set_token('QUAL_PERIOD',p_qual_period);
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Report the total number of students have the student DLHE records with open qualifying period,
    -- for them not required to modify student DLHE record.
    fnd_message.set_name('IGS','IGS_HE_DLHE_NOT_MODIFIED');
    fnd_message.set_token('NOT_MOD', p_not_mod_dlhe_cnt);
    fnd_message.set_token('RETURN_NAME',p_return_name);
    fnd_message.set_token('QUAL_PERIOD',p_qual_period);
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    EXCEPTION
     WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','igs_he_import_popdlhe.log_results - ' ||SQLERRM);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        App_Exception.Raise_Exception;

END log_results;

END igs_he_import_popdlhe;

/
