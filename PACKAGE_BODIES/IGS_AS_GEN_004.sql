--------------------------------------------------------
--  DDL for Package Body IGS_AS_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GEN_004" AS
/* $Header: IGSAS04B.pls 120.1 2005/11/28 03:38:11 appldev ship $ */
/*======================================================================+
 |                                                                      |
 | DESCRIPTION                                                          |
 |      PL/SQL boby for package: igs_as_gen_001                         |
 |                                                                      |
 | NOTES                                                                |
 |                                                                      |
 | CHANGE HISTORY                                                       |
 +======================================================================+
 | WHO      WHEN            WHAT                                        |
 +======================================================================+
 | nalkumar 24-May-2003 Modified the call to the igs_as_su_atmpt_itm_pkg|
 |                      Added two new parameters                        |
 |                      x_unit_section_ass_item_id and                  |
 |                      x_unit_ass_item_id in the call;                 |
 |                      This is as per 'Assessment Item description     |
 |                      Build'; Bug# 2829291                            |
 | ijeddy 19-Jun-2003   Bug 2884615, addition of notified_date in       |
 |                      assp_ins_scap_lovall.                           |
 | kdande 18-Aug-2003   Bug# 2895945. Changed the cursors to use        |
 |                      hz_parties table instead of igs_pe_person view. |
 | smvk   09-Jul-2004   Bug # 3676145. Modified the cursors c_id_no_ind,|
 |                      c_id_with_ind, c_surname_no_ind, c_sua_person_id,
 |                      c_surname_with_ind, c_uop and c_sua_surname to  |
 |                      select active (not closed) unit classes.        |
 | ijeddy 11/28/2005    Bug 4763207, modified c_suaai_an.               |
 +======================================================================+*/
  --
  -- Bug No. 1956374 Procedure assp_val_suaai_ins reference is changed
  --
  PROCEDURE asss_ins_transcript (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_course_org_unit_cd           IN     VARCHAR2,
    p_course_group_cd              IN     VARCHAR2,
    p_course_cd                    IN     VARCHAR2,
    p_course_location_cd           IN     VARCHAR2,
    p_course_attendance_mode       IN     VARCHAR2,
    p_course_award                 IN     VARCHAR2 DEFAULT 'BOTH',
    p_course_attempt_status        IN     VARCHAR2,
    p_progression_status           IN     VARCHAR2,
    p_graduand_status              IN     VARCHAR2,
    p_person_id_group              IN     NUMBER,
    p_person_id                    IN     NUMBER,
    p_transcript_type              IN     VARCHAR2,
    p_include_fail_grades_ind      IN     VARCHAR2 DEFAULT 'N',
    p_enrolled_units_ind           IN     VARCHAR2 DEFAULT 'C',
    p_exclude_research_units_ind   IN     VARCHAR2 DEFAULT 'N',
    p_exclude_unit_category        IN     VARCHAR2,
    p_extract_course_cd            IN     VARCHAR2,
    p_include_related_crs_ind      IN     VARCHAR2 DEFAULT 'N',
    p_order_by                     IN     VARCHAR2 DEFAULT 'YEAR',
    p_external_order_by            IN     VARCHAR2 DEFAULT 'SURNAME',
    p_correspondence_ind           IN     VARCHAR2 DEFAULT 'N',
    p_org_id                       IN     NUMBER
  ) IS
  BEGIN
    --
    retcode := 0;
    --
    -- As per 2239087, this concurrent program is obsolete and if the user
    -- tries to run this program then an error message should be logged into the log
    -- file that the concurrent program is obsolete and should not be run.
    --
    fnd_message.set_name ('IGS', 'IGS_GE_OBSOLETE_JOB');
    fnd_file.put_line (fnd_file.LOG, fnd_message.get);
    --
  EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;
      errbuf := fnd_message.get_string ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      igs_ge_msg_stack.conc_exception_hndl;
  END asss_ins_transcript;
  --
  -- This function is obsolete as the Grade Book Enhancement obsoleted the
  -- Assessment Patterns functionality
  --
  FUNCTION assp_get_uap_cd (
    p_ass_pattern_id               IN NUMBER
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN NULL;
  END assp_get_uap_cd;
  --
  --
  --
  FUNCTION assp_ins_dflt_evsa (
    p_venue_cd                     IN     VARCHAR2,
    p_exam_cal_type                IN     VARCHAR2,
    p_exam_ci_sequence_number      IN     NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
    l_org_id        NUMBER (15);
  BEGIN -- assp_ins_dflt_evsa
    -- Routine to insert default session details for a nominated examination
    -- IGS_GR_VENUE and period.
    -- The routine will only insert if there are no existing record for the
    -- IGS_GR_VENUE under the nominated examination period.
    DECLARE
      v_inserted_flag BOOLEAN       DEFAULT FALSE;
      l_rowid         VARCHAR2 (25);
      v_evsa_exists   VARCHAR2 (1);
      CURSOR c_evsa IS
        SELECT 'x'
        FROM   igs_as_exmvnu_sesavl
        WHERE  venue_cd = p_venue_cd
        AND    exam_cal_type = p_exam_cal_type
        AND    exam_ci_sequence_number = p_exam_ci_sequence_number;
      CURSOR c_es IS
        SELECT exam_cal_type,
               exam_ci_sequence_number,
               dt_alias,
               dai_sequence_number,
               start_time,
               end_time,
               ese_id,
               comments
        FROM   igs_as_exam_session
        WHERE  exam_cal_type = p_exam_cal_type
        AND    exam_ci_sequence_number = p_exam_ci_sequence_number;
    BEGIN
      -- Set the default message number
      p_message_name := NULL;
      -- 1. Check that there are no existing details under the nominated
      -- period/IGS_GR_VENUE combination.
      OPEN c_evsa;
      FETCH c_evsa INTO v_evsa_exists;
      IF (c_evsa%FOUND) THEN
        p_message_name := 'IGS_AS_CANNOT_DFLT_RECORDS';
        RETURN FALSE;
      END IF;
      -- 2. Default the session availability for all sessions within the
      -- nominated examination calendar.
      FOR v_es_rec IN c_es LOOP
        v_inserted_flag := TRUE;
        --get org id
        l_org_id := igs_ge_gen_003.get_org_id;
        igs_as_exmvnu_sesavl_pkg.insert_row (
          x_mode                         => 'R',
          x_rowid                        => l_rowid,
          x_org_id                       => l_org_id,
          x_venue_cd                     => p_venue_cd,
          x_exam_cal_type                => v_es_rec.exam_cal_type,
          x_exam_ci_sequence_number      => v_es_rec.exam_ci_sequence_number,
          x_dt_alias                     => v_es_rec.dt_alias,
          x_dai_sequence_number          => v_es_rec.dai_sequence_number,
          x_start_time                   => v_es_rec.start_time,
          x_end_time                     => v_es_rec.end_time,
          x_ese_id                       => v_es_rec.ese_id,
          x_comments                     => v_es_rec.comments
        );
      END LOOP;
      IF (v_inserted_flag = FALSE) THEN
        -- no sessions found
        p_message_name := 'IGS_AS_NOEXAM_SESSIONS_FOUND';
        RETURN FALSE;
      END IF;
      COMMIT WORK;
      RETURN TRUE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_004.assp_ins_dflt_evsa');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_ins_dflt_evsa;
  --
  --
  --
  FUNCTION assp_ins_get (
    p_keying_who                   IN     VARCHAR2,
    p_sheet_number                 IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_sequence_number              IN     NUMBER,
    p_unit_cd                      IN     VARCHAR2,
    p_location_cd                  IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_include_discont_ind          IN     VARCHAR2,
    p_sort_by                      IN     VARCHAR2,
    p_keying_time                  OUT NOCOPY DATE
  ) RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN
    DECLARE
      cst_enrolled        igs_en_su_attempt.unit_attempt_status%TYPE   := 'ENROLLED';
      cst_discontin       igs_en_su_attempt.unit_attempt_status%TYPE   := 'DISCONTIN';
      cst_completed       igs_en_su_attempt.unit_attempt_status%TYPE   := 'COMPLETED';
      cst_yes             VARCHAR2 (1)                                 := 'Y';
      cst_no              VARCHAR2 (1)                                 := 'N';
      cst_id              VARCHAR2 (10)                                := 'ID';
      cst_surname         VARCHAR2 (10)                                := 'SURNAME';
      cst_v7              INTEGER                                      := 2;
      v_keying_time       DATE;
      v_exists_flag       CHAR;
      v_exit_loop_flag    BOOLEAN                                      DEFAULT FALSE;
      v_sort_parse        VARCHAR2 (30);
      v_select_statuses   VARCHAR2 (50);
      v_return            INTEGER;
      v_cursor_handle     INTEGER;
      v_student_seq       NUMBER                                       DEFAULT 1;
      v_parse_command     VARCHAR2 (1000);
      v_get_record        igs_as_ins_grd_entry%ROWTYPE;
      v_initials          igs_pe_person.given_names%TYPE;
      v_location_cd       igs_ps_unit_ofr_opt.location_cd%TYPE;
      v_unit_class        igs_ps_unit_ofr_opt.unit_class%TYPE;
      v_unit_mode         igs_as_unit_class.unit_mode%TYPE;
      CURSOR c_chk_keying_time (cp_keying_time DATE, cp_keying_who igs_as_ins_grd_entry.keying_who%TYPE) IS
        SELECT 'x'
        FROM   DUAL
        WHERE  EXISTS ( SELECT *
                        FROM   igs_as_ins_grd_entry iaige
                        WHERE  iaige.keying_time = cp_keying_time
                        AND    iaige.keying_who = cp_keying_who);
      CURSOR c_chk_mark_sheets (cp_mark_sheet igs_as_mark_sheet.sheet_number%TYPE) IS
        SELECT 'x'
        FROM   DUAL
        WHERE  EXISTS ( SELECT *
                        FROM   igs_as_msht_su_atmpt iamsa
                        WHERE  iamsa.sheet_number = cp_mark_sheet);
      CURSOR c_grd_entry_tmp IS
        SELECT p_keying_who,
               v_keying_time,
               mssua.student_sequence,
               mssua.person_id,
               pe.person_last_name surname,
               mssua.course_cd,
               mssua.unit_cd,
               sua.version_number,
               mssua.cal_type,
               mssua.ci_sequence_number,
               sua.location_cd,
               sua.unit_class,
               sua.unit_attempt_status,
               NULL n1,
               NULL n2,
               NULL n3,
               NULL n4,
               'N'
        FROM   igs_as_msht_su_atmpt mssua,
               hz_parties pe,
               igs_en_su_attempt sua
        WHERE  mssua.sheet_number = p_sheet_number
        AND    pe.party_id = mssua.person_id
        AND    sua.person_id(+) = mssua.person_id
        AND    sua.course_cd(+) = mssua.course_cd
        AND    sua.uoo_id(+) = mssua.uoo_id;
      --
      c_grd_entry_tmp_rec c_grd_entry_tmp%ROWTYPE;
      l_rowid             VARCHAR2 (25);
    BEGIN
      -- Generate the keying time
      v_keying_time := SYSDATE;
      LOOP
        -- If any records exist matching the p_keying_who with the same date/time
        -- then increment the time by 5 seconds and try again
        EXIT WHEN v_exit_loop_flag;
        OPEN c_chk_keying_time (v_keying_time, p_keying_who);
        FETCH c_chk_keying_time INTO v_exists_flag;
        IF c_chk_keying_time%FOUND THEN
          v_keying_time := v_keying_time + 1 / 17280;
        ELSE
          v_exit_loop_flag := TRUE;
        END IF;
        CLOSE c_chk_keying_time;
      END LOOP;
      IF p_sheet_number IS NOT NULL THEN
        -- The routine should copy the records from the nominated mark sheet
        -- Copy records from IGS_AS_MSHT_SU_ATMPT to the IGS_AS_INS_GRD_ENTRY table
        -- where the sheet_number matches p_sheet_number
        FOR c_grd_entry_tmp_rec IN c_grd_entry_tmp LOOP
          igs_as_ins_grd_entry_pkg.insert_row (
            x_mode                         => 'R',
            x_rowid                        => l_rowid,
            x_keying_who                   => c_grd_entry_tmp_rec.p_keying_who,
            x_keying_time                  => c_grd_entry_tmp_rec.v_keying_time,
            x_student_sequence             => c_grd_entry_tmp_rec.student_sequence,
            x_person_id                    => c_grd_entry_tmp_rec.person_id,
            x_name                         => c_grd_entry_tmp_rec.surname,
            x_course_cd                    => c_grd_entry_tmp_rec.course_cd,
            x_unit_cd                      => c_grd_entry_tmp_rec.unit_cd,
            x_version_number               => c_grd_entry_tmp_rec.version_number,
            x_cal_type                     => c_grd_entry_tmp_rec.cal_type,
            x_ci_sequence_number           => c_grd_entry_tmp_rec.ci_sequence_number,
            x_location_cd                  => c_grd_entry_tmp_rec.location_cd,
            x_unit_class                   => c_grd_entry_tmp_rec.unit_class,
            x_unit_attempt_status          => c_grd_entry_tmp_rec.unit_attempt_status,
            x_mark                         => NULL,
            x_grading_schema_cd            => NULL,
            x_gs_version_number            => NULL,
            x_grade                        => NULL,
            x_specified_grade_ind          => NULL
          );
        END LOOP;
        OPEN c_chk_mark_sheets (p_sheet_number);
        FETCH c_chk_mark_sheets INTO v_exists_flag;
        IF c_chk_mark_sheets%NOTFOUND THEN
          CLOSE c_chk_mark_sheets;
          p_keying_time := NULL;
          RETURN FALSE;
        ELSE
          CLOSE c_chk_mark_sheets;
          p_keying_time := v_keying_time;
          COMMIT;
          RETURN TRUE;
        END IF;
      ELSE
        -- The routine must query the students and create the temporary structure
        -- v_sort_parse is set to pe.person_number though the incoming p_sort_by remains as ID
        -- this is done to make the sort happen by person_number instead of person_id
        -- without affecting the call to this procedure
        -- so the call to this procedure will still pass ID if the sort is to be done by person_number
        --
        IF p_sort_by = cst_id THEN
          v_sort_parse := 'pe.person_number';
        ELSIF p_sort_by = cst_surname THEN
          v_sort_parse := 'pe.surname';
        END IF;
        IF p_include_discont_ind = cst_no THEN
          v_select_statuses := '''' || cst_enrolled || ''', ''' || cst_completed || '''';
        ELSE
          v_select_statuses := '''' || cst_enrolled || ''', ''' || cst_discontin || ''', ''' || cst_completed || '''';
        END IF;
        IF p_unit_mode IS NOT NULL THEN
          v_unit_mode := p_unit_mode;
          v_unit_class := '%';
        ELSE
          v_unit_mode := '%';
          IF p_unit_class IS NOT NULL THEN
            v_unit_class := p_unit_class;
          ELSE
            v_unit_class := '%';
          END IF;
        END IF;
        IF p_location_cd IS NOT NULL THEN
          v_location_cd := p_location_cd;
        ELSE
          v_location_cd := '%';
        END IF;
        --
        -- Code to replace the earlier existing Dynamic SQL
        --
        DECLARE
          CURSOR c_id_no_ind IS
            SELECT   sua.location_cd,
                     sua.unit_class,
                     sua.person_id,
                     sua.course_cd,
                     sua.unit_attempt_status,
                     pe.person_last_name surname,
                     igs_ge_gen_002.genp_get_initials (pe.person_first_name),
                     sua.version_number
            FROM     igs_ps_unit_ofr_opt uoo,
                     igs_en_su_attempt sua,
                     hz_parties pe,
                     igs_as_unit_class ucl
            WHERE    uoo.unit_cd = p_unit_cd
            AND      uoo.cal_type = p_cal_type
            AND      uoo.ci_sequence_number = TO_CHAR (p_sequence_number)
            AND      uoo.location_cd LIKE v_location_cd
            AND      uoo.unit_class LIKE v_unit_class
            AND      ucl.unit_class = uoo.unit_class
            AND      ucl.unit_mode LIKE v_unit_mode
            AND      sua.uoo_id = uoo.uoo_id
            AND      sua.unit_attempt_status IN ('ENROLLED', 'COMPLETED')
            AND      pe.party_id = sua.person_id
	    AND      ucl.closed_ind = 'N'
            ORDER BY pe.party_number;
          --
          -- Including Discontin Status alongwith ENROLLED,COMPLETED,DISCONTIN
          --
          CURSOR c_id_with_ind IS
            SELECT   sua.location_cd,
                     sua.unit_class,
                     sua.person_id,
                     sua.course_cd,
                     sua.unit_attempt_status,
                     pe.person_last_name surname,
                     igs_ge_gen_002.genp_get_initials (pe.person_first_name),
                     sua.version_number
            FROM     igs_ps_unit_ofr_opt uoo,
                     igs_en_su_attempt sua,
                     hz_parties pe,
                     igs_as_unit_class ucl
            WHERE    uoo.unit_cd = p_unit_cd
            AND      uoo.cal_type = p_cal_type
            AND      uoo.ci_sequence_number = TO_CHAR (p_sequence_number)
            AND      uoo.location_cd LIKE v_location_cd
            AND      uoo.unit_class LIKE v_unit_class
            AND      ucl.unit_class = uoo.unit_class
            AND      ucl.unit_mode LIKE v_unit_mode
            AND      sua.uoo_id = uoo.uoo_id
            AND      sua.unit_attempt_status IN ('ENROLLED', 'DISCONTIN', 'COMPLETED')
            AND      pe.party_id = sua.person_id
	    AND      ucl.closed_ind = 'N'
            ORDER BY pe.party_number;
          --
          -- Excluding Discontin Status that is JUST with  ENROLLED,COMPLETED
          --
          CURSOR c_surname_no_ind (
            cp_unit_cd                            VARCHAR2,
            cp_cal_type                           VARCHAR2,
            cp_sequence_number                    NUMBER,
            cp_location_cd                        VARCHAR2,
            cp_unit_class                         VARCHAR2,
            cp_unit_mode                          VARCHAR2
          ) IS
            SELECT   sua.location_cd,
                     sua.unit_class,
                     sua.person_id,
                     sua.course_cd,
                     sua.unit_attempt_status,
                     pe.person_last_name surname,
                     igs_ge_gen_002.genp_get_initials (pe.person_first_name),
                     sua.version_number
            FROM     igs_ps_unit_ofr_opt uoo,
                     igs_en_su_attempt sua,
                     hz_parties pe,
                     igs_as_unit_class ucl
            WHERE    uoo.unit_cd = cp_unit_cd
            AND      uoo.cal_type = cp_cal_type
            AND      uoo.ci_sequence_number = TO_CHAR (cp_sequence_number)
            AND      uoo.location_cd LIKE cp_location_cd
            AND      uoo.unit_class LIKE cp_unit_class
            AND      ucl.unit_class = uoo.unit_class
            AND      ucl.unit_mode LIKE cp_unit_mode
            AND      sua.uoo_id = uoo.uoo_id
            AND      sua.unit_attempt_status IN ('ENROLLED', 'COMPLETED')
            AND      pe.party_id = sua.person_id
	    AND      ucl.closed_ind = 'N'
            ORDER BY pe.person_last_name;
          --
          CURSOR c_surname_with_ind (
            cp_unit_cd                            VARCHAR2,
            cp_cal_type                           VARCHAR2,
            cp_sequence_number                    NUMBER,
            cp_location_cd                        VARCHAR2,
            cp_unit_class                         VARCHAR2,
            cp_unit_mode                          VARCHAR2
          ) IS
            SELECT   sua.location_cd,
                     sua.unit_class,
                     sua.person_id,
                     sua.course_cd,
                     sua.unit_attempt_status,
                     pe.person_last_name surname,
                     igs_ge_gen_002.genp_get_initials (pe.person_first_name),
                     sua.version_number
            FROM     igs_ps_unit_ofr_opt uoo,
                     igs_en_su_attempt sua,
                     hz_parties pe,
                     igs_as_unit_class ucl
            WHERE    uoo.unit_cd = cp_unit_cd
            AND      uoo.cal_type = cp_cal_type
            AND      uoo.ci_sequence_number = TO_CHAR (cp_sequence_number)
            AND      uoo.location_cd LIKE cp_location_cd
            AND      uoo.unit_class LIKE cp_unit_class
            AND      ucl.unit_class = uoo.unit_class
            AND      ucl.unit_mode LIKE cp_unit_mode
            AND      sua.uoo_id = uoo.uoo_id
            AND      sua.unit_attempt_status IN ('ENROLLED', 'DISCONTIN', 'COMPLETED')
            AND      pe.party_id = sua.person_id
	    AND      ucl.closed_ind = 'N'
            ORDER BY pe.person_last_name;
          --
          l_location_cd         VARCHAR2 (10);
          l_unit_class          VARCHAR2 (10);
          l_person_id           NUMBER;
          l_course_cd           VARCHAR2 (10);
          l_unit_attempt_status igs_en_su_attempt.unit_attempt_status%TYPE;
          l_name                VARCHAR2 (30);
          l_initials            VARCHAR2 (10);
          l_version_number      NUMBER;
          l_rowid               VARCHAR2 (25);
        BEGIN
          IF (v_sort_parse = 'pe.person_number') THEN
            IF p_include_discont_ind = cst_no THEN
              OPEN c_id_no_ind;
              LOOP
                FETCH c_id_no_ind INTO l_location_cd,
                                       l_unit_class,
                                       l_person_id,
                                       l_course_cd,
                                       l_unit_attempt_status,
                                       l_name,
                                       l_initials,
                                       l_version_number;
                IF c_id_no_ind%NOTFOUND THEN
                  EXIT;
                END IF;
                igs_as_ins_grd_entry_pkg.insert_row (
                  x_mode                         => 'R',
                  x_rowid                        => l_rowid,
                  x_keying_who                   => p_keying_who,
                  x_keying_time                  => v_keying_time,
                  x_student_sequence             => v_student_seq,
                  x_person_id                    => l_person_id,
                  x_name                         => l_name || ', ' || l_initials,
                  x_course_cd                    => l_course_cd,
                  x_unit_cd                      => p_unit_cd,
                  x_version_number               => l_version_number,
                  x_cal_type                     => p_cal_type,
                  x_ci_sequence_number           => p_sequence_number,
                  x_location_cd                  => l_location_cd,
                  x_unit_class                   => l_unit_class,
                  x_unit_attempt_status          => l_unit_attempt_status,
                  x_mark                         => NULL,
                  x_grading_schema_cd            => NULL,
                  x_gs_version_number            => NULL,
                  x_grade                        => NULL,
                  x_specified_grade_ind          => 'N'
                );
                v_student_seq := v_student_seq + 1;
              END LOOP;
              CLOSE c_id_no_ind;
            ELSE
              OPEN c_id_with_ind;
              LOOP
                FETCH c_id_with_ind INTO l_location_cd,
                                         l_unit_class,
                                         l_person_id,
                                         l_course_cd,
                                         l_unit_attempt_status,
                                         l_name,
                                         l_initials,
                                         l_version_number;
                IF c_id_with_ind%NOTFOUND THEN
                  EXIT;
                END IF;
                igs_as_ins_grd_entry_pkg.insert_row (
                  x_mode                         => 'R',
                  x_rowid                        => l_rowid,
                  x_keying_who                   => p_keying_who,
                  x_keying_time                  => v_keying_time,
                  x_student_sequence             => v_student_seq,
                  x_person_id                    => l_person_id,
                  x_name                         => l_name || ', ' || l_initials,
                  x_course_cd                    => l_course_cd,
                  x_unit_cd                      => p_unit_cd,
                  x_version_number               => l_version_number,
                  x_cal_type                     => p_cal_type,
                  x_ci_sequence_number           => p_sequence_number,
                  x_location_cd                  => l_location_cd,
                  x_unit_class                   => l_unit_class,
                  x_unit_attempt_status          => l_unit_attempt_status,
                  x_mark                         => NULL,
                  x_grading_schema_cd            => NULL,
                  x_gs_version_number            => NULL,
                  x_grade                        => NULL,
                  x_specified_grade_ind          => 'N'
                );
                v_student_seq := v_student_seq + 1;
              END LOOP;
              CLOSE c_id_with_ind;
            END IF;
          ELSIF v_sort_parse = 'pe.surname' THEN
            IF p_include_discont_ind = cst_no THEN
              OPEN c_surname_no_ind (
                p_unit_cd,
                p_cal_type,
                p_sequence_number,
                v_location_cd,
                v_unit_class,
                v_unit_mode
              );
              LOOP
                FETCH c_surname_no_ind INTO l_location_cd,
                                            l_unit_class,
                                            l_person_id,
                                            l_course_cd,
                                            l_unit_attempt_status,
                                            l_name,
                                            l_initials,
                                            l_version_number;
                IF c_surname_no_ind%NOTFOUND THEN
                  EXIT;
                END IF;
                igs_as_ins_grd_entry_pkg.insert_row (
                  x_mode                         => 'R',
                  x_rowid                        => l_rowid,
                  x_keying_who                   => p_keying_who,
                  x_keying_time                  => v_keying_time,
                  x_student_sequence             => v_student_seq,
                  x_person_id                    => l_person_id,
                  x_name                         => l_name || ', ' || l_initials,
                  x_course_cd                    => l_course_cd,
                  x_unit_cd                      => p_unit_cd,
                  x_version_number               => l_version_number,
                  x_cal_type                     => p_cal_type,
                  x_ci_sequence_number           => p_sequence_number,
                  x_location_cd                  => l_location_cd,
                  x_unit_class                   => l_unit_class,
                  x_unit_attempt_status          => l_unit_attempt_status,
                  x_mark                         => NULL,
                  x_grading_schema_cd            => NULL,
                  x_gs_version_number            => NULL,
                  x_grade                        => NULL,
                  x_specified_grade_ind          => 'N'
                );
                v_student_seq := v_student_seq + 1;
              END LOOP;
              CLOSE c_surname_no_ind;
            ELSE
              OPEN c_surname_with_ind (
                p_unit_cd,
                p_cal_type,
                p_sequence_number,
                v_location_cd,
                v_unit_class,
                v_unit_mode
              );
              LOOP
                FETCH c_surname_with_ind INTO l_location_cd,
                                              l_unit_class,
                                              l_person_id,
                                              l_course_cd,
                                              l_unit_attempt_status,
                                              l_name,
                                              l_initials,
                                              l_version_number;
                IF c_surname_with_ind%NOTFOUND THEN
                  EXIT;
                END IF;
                igs_as_ins_grd_entry_pkg.insert_row (
                  x_mode                         => 'R',
                  x_rowid                        => l_rowid,
                  x_keying_who                   => p_keying_who,
                  x_keying_time                  => v_keying_time,
                  x_student_sequence             => v_student_seq,
                  x_person_id                    => l_person_id,
                  x_name                         => l_name || ', ' || l_initials,
                  x_course_cd                    => l_course_cd,
                  x_unit_cd                      => p_unit_cd,
                  x_version_number               => l_version_number,
                  x_cal_type                     => p_cal_type,
                  x_ci_sequence_number           => p_sequence_number,
                  x_location_cd                  => l_location_cd,
                  x_unit_class                   => l_unit_class,
                  x_unit_attempt_status          => l_unit_attempt_status,
                  x_mark                         => NULL,
                  x_grading_schema_cd            => NULL,
                  x_gs_version_number            => NULL,
                  x_grade                        => NULL,
                  x_specified_grade_ind          => 'N'
                );
                v_student_seq := v_student_seq + 1;
              END LOOP;
              CLOSE c_surname_with_ind;
            END IF;
          END IF;
        END;
        OPEN c_chk_keying_time (v_keying_time, p_keying_who);
        FETCH c_chk_keying_time INTO v_exists_flag;
        IF c_chk_keying_time%NOTFOUND THEN
          CLOSE c_chk_keying_time;
          p_keying_time := NULL;
          RETURN FALSE;
        ELSE
          CLOSE c_chk_keying_time;
          p_keying_time := v_keying_time;
          COMMIT;
          RETURN TRUE;
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_004.assp_ins_get');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_ins_get;
  --
  --
  --
  FUNCTION assp_ins_mark_sheet (
    p_assess_cal_type              IN     VARCHAR2,
    p_assess_sequence_number       IN     NUMBER,
    p_teach_cal_type               IN     VARCHAR2,
    p_teach_sequence_number        IN     NUMBER,
    p_unit_org_unit_cd             IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_location_cd                  IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_include_discont_ind          IN     VARCHAR2,
    p_sort_by                      IN     VARCHAR2,
    p_group_sequence_number        OUT NOCOPY NUMBER,
    p_grading_period_cd            IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_call_number                  IN     NUMBER
  ) RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_ins_mark_sheet
    -- Inserts mark sheet records (ms and mssua)for students matching the passed
    -- parameters
    DECLARE
      -- select the mark sheets to produce based on parameters
      e_resource_busy         EXCEPTION;
      --PRAGMA        EXCEPTION_INIT(e_resource_busy, -54);
      v_mss_mark_sheet        igs_as_mark_sheet.sheet_number%TYPE;
      v_ms_sequence_number    igs_as_mark_sheet.sheet_number%TYPE;
      v_group_sequence_number igs_as_mark_sheet.group_sequence_number%TYPE;
      cst_no         CONSTANT CHAR                                           := 'N';
      v_duplicate_sheet       BOOLEAN                                        DEFAULT FALSE;
      v_not_duplicate         BOOLEAN;
      v_duplicate_ind         VARCHAR2 (1)                                   := 'N';
      v_ins_ms                BOOLEAN                                        DEFAULT FALSE;
      v_sheet_number          igs_as_mark_sheet.sheet_number%TYPE;
      v_person_id             igs_as_msht_su_atmpt.person_id%TYPE;
      v_course_cd             igs_as_msht_su_atmpt.course_cd%TYPE;
      v_unit_cd               igs_as_msht_su_atmpt.unit_cd%TYPE;
      v_cal_type              igs_as_msht_su_atmpt.cal_type%TYPE;
      v_ci_sequence_number    igs_as_msht_su_atmpt.ci_sequence_number%TYPE;
      v_unit_class            igs_as_msht_su_atmpt.unit_class%TYPE;
      v_student_sequence      igs_as_msht_su_atmpt.student_sequence%TYPE;
      v_update_on             igs_as_msht_su_atmpt.last_update_date%TYPE;
      v_update_who            igs_as_msht_su_atmpt.last_updated_by%TYPE;
      CURSOR c_uop (
        cp_assess_cal_type             IN     igs_ca_inst.cal_type%TYPE,
        cp_assess_sequence_number      IN     igs_ca_inst.sequence_number%TYPE,
        cp_teach_cal_type              IN     igs_ps_unit_ofr_opt.cal_type%TYPE,
        cp_teach_sequence_number       IN     igs_ps_unit_ofr_opt.ci_sequence_number%TYPE
      ) IS
        SELECT DISTINCT uop.unit_cd,
                        uop.version_number,
                        uop.cal_type,
                        uop.ci_sequence_number,
                        uop.location_cd,
                        ucl.unit_mode,
                        uop.uoo_id
        FROM            igs_ps_unit_ofr_opt uop,
                        igs_as_unit_class ucl,
                        igs_ca_inst ci,
                        igs_ps_unit_ver uv,
                        igs_ca_stat cs,
                        igs_ps_unit_stat us
        WHERE           uop.unit_cd LIKE p_unit_cd
        AND             uop.unit_cd = uv.unit_cd
        AND             uop.version_number = uv.version_number
        AND             uv.unit_status = us.unit_status
        AND             uv.owner_org_unit_cd LIKE NVL (p_unit_org_unit_cd, uv.owner_org_unit_cd)
        AND             us.s_unit_status = 'ACTIVE'
        AND             uop.location_cd LIKE NVL (p_location_cd, uop.location_cd)
        AND             ucl.unit_class = uop.unit_class
        AND             ucl.unit_mode LIKE NVL (p_unit_mode, ucl.unit_mode)
	AND             ucl.closed_ind = 'N'
        AND             uop.cal_type = ci.cal_type
        AND             uop.ci_sequence_number = ci.sequence_number
        AND             ci.cal_status = cs.cal_status
        AND             cs.s_cal_status = 'ACTIVE'
        AND             ((cp_assess_cal_type IS NULL
                          OR (cp_assess_cal_type IS NOT NULL
                              AND igs_en_gen_014.enrs_get_within_ci (
                                    cp_assess_cal_type,
                                    cp_assess_sequence_number,
                                    uop.cal_type,
                                    uop.ci_sequence_number,
                                    'N'
                                  ) = 'Y'
                             )
                         )
                        )
        AND             (cp_teach_cal_type IS NULL
                         OR (cp_teach_cal_type IS NOT NULL
                             AND uop.cal_type = cp_teach_cal_type
                             AND uop.ci_sequence_number = cp_teach_sequence_number
                             AND uop.call_number LIKE NVL (p_call_number, uop.call_number)
                             AND ucl.unit_class LIKE NVL (p_unit_class, ucl.unit_class)
                            )
                        );
      CURSOR c_ms1 (
        cp_uop_unit_cd                 IN     igs_ps_unit_ofr_pat.unit_cd%TYPE,
        cp_uop_version_number          IN     igs_ps_unit_ofr_pat.version_number%TYPE,
        cp_uop_cal_type                IN     igs_ps_unit_ofr_pat.cal_type%TYPE,
        cp_uop_ci_sequence_number      IN     igs_ps_unit_ofr_pat.ci_sequence_number%TYPE,
        cp_ms_sequence_number          IN     igs_as_mark_sheet.sheet_number%TYPE
      ) IS
        SELECT sheet_number
        FROM   igs_as_mark_sheet ms
        WHERE  ms.unit_cd = cp_uop_unit_cd
        AND    ms.version_number = cp_uop_version_number
        AND    ms.cal_type = cp_uop_cal_type
        AND    ms.ci_sequence_number = cp_uop_ci_sequence_number
        AND    ms.sheet_number <> cp_ms_sequence_number
        AND    ms.grading_period_cd = p_grading_period_cd;
      CURSOR c_mssua1 (cp_ms_sequence_number IN igs_as_mark_sheet.sheet_number%TYPE) IS
        SELECT mssua.person_id
        FROM   igs_as_msht_su_atmpt mssua
        WHERE  mssua.sheet_number = cp_ms_sequence_number;
      CURSOR c_mss (cp_ms_sequence_number IN igs_as_mark_sheet.sheet_number%TYPE) IS
        SELECT        mss.sheet_number
        FROM          igs_as_mark_sheet mss
        WHERE         mss.sheet_number = cp_ms_sequence_number
        FOR UPDATE OF duplicate_ind NOWAIT;
      CURSOR c_mssua2 (
        cp_ms_mark_sheet               IN     igs_as_mark_sheet.sheet_number%TYPE,
        cp_mssua1_person_id            IN     igs_as_msht_su_atmpt.person_id%TYPE
      ) IS
        SELECT sheet_number,
               person_id,
               course_cd,
               unit_cd,
               cal_type,
               ci_sequence_number,
               student_sequence,
               unit_class,
               last_update_date,
               last_updated_by
        FROM   igs_as_msht_su_atmpt mssua2
        WHERE  mssua2.sheet_number = cp_ms_mark_sheet
        AND    mssua2.person_id = cp_mssua1_person_id;
      CURSOR c_get_nxt_seq_no IS
        SELECT igs_as_mark_sheet_grpseqnum_s.NEXTVAL
        FROM   DUAL;
      CURSOR c_get_nxt_grp_seq_no IS
        SELECT igs_as_mark_sheet_grpseqnum_s.NEXTVAL
        FROM   DUAL;
        ----------------------------------------ASSPL_INS_MSSUA_SORT--------------------
        -- procedure used to mainly insert student records (orderd by
        -- PERSON_ID/SURNAME) into MSSUA
      PROCEDURE asspl_ins_mssua_sort (
        lp_location_cd                 IN     igs_ps_unit_ofr_opt.location_cd%TYPE,
        lp_unit_mode                   IN     igs_as_unit_class.unit_mode%TYPE,
        lp_sort_by                     IN     VARCHAR2,
        lp_uop_unit_cd                 IN     igs_ps_unit_ofr_pat.unit_cd%TYPE,
        lp_uop_version_number          IN     igs_ps_unit_ofr_pat.version_number%TYPE,
        lp_uop_cal_type                IN     igs_ps_unit_ofr_pat.cal_type%TYPE,
        lp_uop_ci_sequence_number      IN     igs_ps_unit_ofr_pat.ci_sequence_number%TYPE,
        lp_ms_sequence_number          IN     igs_as_mark_sheet.sheet_number%TYPE,
        lp_group_sequence_number       IN     igs_as_mark_sheet.group_sequence_number%TYPE,
        lp_uoo_id                      IN     NUMBER
      ) IS
        -- select the students to be included (where p_assess_cal_type is specified)
        -- in mark sheets and ORDER BY person_id
        CURSOR c_sua_person_id (
          cp_uop_unit_cd                 IN     igs_ps_unit_ofr_pat.unit_cd%TYPE,
          cp_uop_version_number          IN     igs_ps_unit_ofr_pat.version_number%TYPE,
          cp_uop_cal_type                IN     igs_ps_unit_ofr_pat.cal_type%TYPE,
          cp_uop_ci_sequence_number      IN     igs_ps_unit_ofr_pat.ci_sequence_number%TYPE,
          cp_location_cd                 IN     igs_ps_unit_ofr_opt.location_cd%TYPE,
          cp_unit_mode                   IN     igs_as_unit_class.unit_mode%TYPE,
          cp_uoo_id                      IN     igs_en_su_attempt.uoo_id%TYPE
        ) IS
          SELECT   sua.person_id,
                   sua.course_cd,
                   sua.unit_cd,
                   sua.cal_type,
                   sua.ci_sequence_number,
                   sua.location_cd,
                   ucl.unit_mode,
                   sua.unit_class,
                   unit_attempt_status
          FROM     igs_en_su_attempt sua,
                   igs_as_unit_class ucl
          WHERE    ucl.unit_class = sua.unit_class
          AND      sua.uoo_id = cp_uoo_id
          AND      sua.location_cd = cp_location_cd
          AND      ucl.unit_mode = cp_unit_mode
	  AND      ucl.closed_ind = 'N'
          AND      sua.unit_attempt_status IN ('ENROLLED', 'COMPLETED', 'DISCONTIN')
          AND      (p_grading_period_cd = 'FINAL'
                    OR (EXISTS ( SELECT 'x'
                                 FROM   igs_as_gpc_programs gpr
                                 WHERE  gpr.course_cd = sua.course_cd)
                        OR EXISTS ( SELECT 'x'
                                    FROM   igs_en_stdnt_ps_att sca,
                                           igs_as_gpc_aca_stndg gas
                                    WHERE  sca.person_id = sua.person_id
                                    AND    sca.course_cd = sua.course_cd
                                    AND    sca.progression_status = gas.progression_status)
                        OR EXISTS ( SELECT 'x'
                                    FROM   igs_pe_prsid_grp_mem pigm,
                                           igs_as_gpc_pe_id_grp gpg
                                    WHERE  sua.person_id = pigm.person_id
                                    AND    pigm.GROUP_ID = gpg.GROUP_ID)
                        OR EXISTS ( SELECT 'x'
                                    FROM   igs_as_gpc_cls_stndg gcs
                                    WHERE  gcs.class_standing =
                                               igs_pr_get_class_std.get_class_standing (
                                                 sua.person_id,
                                                 sua.course_cd,
                                                 'N',
                                                 SYSDATE,
                                                 sua.cal_type,
                                                 sua.ci_sequence_number
                                               ))
                        OR EXISTS ( SELECT 'x'
                                    FROM   igs_as_su_setatmpt iass,
                                           igs_as_gpc_unit_sets gus
                                    WHERE  iass.person_id = sua.person_id
                                    AND    iass.course_cd = sua.course_cd
                                    AND    iass.unit_set_cd = gus.unit_set_cd)
                       )
                   )
          ORDER BY sua.person_id;
        --
        -- select the students to be included (where p_assess_cal_type is specified)
        -- in mark sheets and ORDER BY pe.person_name, person_id
        --
        CURSOR c_sua_surname (
          cp_uop_unit_cd                 IN     igs_ps_unit_ofr_pat.unit_cd%TYPE,
          cp_uop_version_number          IN     igs_ps_unit_ofr_pat.version_number%TYPE,
          cp_uop_cal_type                IN     igs_ps_unit_ofr_pat.cal_type%TYPE,
          cp_uop_ci_sequence_number      IN     igs_ps_unit_ofr_pat.ci_sequence_number%TYPE,
          cp_location_cd                 IN     igs_ps_unit_ofr_opt.location_cd%TYPE,
          cp_unit_mode                   IN     igs_as_unit_class.unit_mode%TYPE,
          cp_uoo_id                      IN     igs_en_su_attempt.uoo_id%TYPE
        ) IS
          SELECT   pe.person_last_name surname,
                   sua.person_id,
                   sua.course_cd,
                   sua.unit_cd,
                   sua.cal_type,
                   sua.ci_sequence_number,
                   sua.location_cd,
                   ucl.unit_mode,
                   sua.unit_class,
                   unit_attempt_status
          FROM     igs_en_su_attempt sua,
                   igs_as_unit_class ucl,
                   hz_parties pe
          WHERE    sua.person_id = pe.party_id
          AND      ucl.unit_class = sua.unit_class
	  AND      ucl.closed_ind = 'N'
          AND      sua.uoo_id = cp_uoo_id
          AND      sua.location_cd = cp_location_cd
          AND      ucl.unit_mode = cp_unit_mode
          AND      sua.unit_attempt_status IN ('ENROLLED', 'COMPLETED', 'DISCONTIN')
          AND      (p_grading_period_cd = 'FINAL'
                    OR (EXISTS ( SELECT 'x'
                                 FROM   igs_as_gpc_programs gpr
                                 WHERE  gpr.course_cd = sua.course_cd)
                        OR EXISTS ( SELECT 'x'
                                    FROM   igs_en_stdnt_ps_att sca,
                                           igs_as_gpc_aca_stndg gas
                                    WHERE  sca.person_id = sua.person_id
                                    AND    sca.course_cd = sua.course_cd
                                    AND    sca.progression_status = gas.progression_status)
                        OR EXISTS ( SELECT 'x'
                                    FROM   igs_pe_prsid_grp_mem pigm,
                                           igs_as_gpc_pe_id_grp gpg
                                    WHERE  sua.person_id = pigm.person_id
                                    AND    pigm.GROUP_ID = gpg.GROUP_ID)
                        OR EXISTS ( SELECT 'x'
                                    FROM   igs_as_gpc_cls_stndg gcs
                                    WHERE  gcs.class_standing =
                                               igs_pr_get_class_std.get_class_standing (
                                                 sua.person_id,
                                                 sua.course_cd,
                                                 'N',
                                                 SYSDATE,
                                                 sua.cal_type,
                                                 sua.ci_sequence_number
                                               ))
                        OR EXISTS ( SELECT 'x'
                                    FROM   igs_as_su_setatmpt iass,
                                           igs_as_gpc_unit_sets gus
                                    WHERE  iass.person_id = sua.person_id
                                    AND    iass.course_cd = sua.course_cd
                                    AND    iass.unit_set_cd = gus.unit_set_cd)
                       )
                   )
          ORDER BY pe.person_last_name,
                   sua.person_id;
        --
        v_stdnt_seq NUMBER (10) := 0;
      BEGIN
        IF p_sort_by = 'ID' THEN
          FOR v_sua_person_id_rec IN c_sua_person_id (
                                       lp_uop_unit_cd,
                                       lp_uop_version_number,
                                       lp_uop_cal_type,
                                       lp_uop_ci_sequence_number,
                                       lp_location_cd,
                                       lp_unit_mode,
                                       lp_uoo_id
                                     ) LOOP
            -- If parameter says not to include discontinued students, then exclude and
            -- go to the next student and insert records into mark_sheet_stnd_unit_atmpt
            IF NOT ((p_include_discont_ind = 'N')
                    AND (v_sua_person_id_rec.unit_attempt_status = 'DISCONTIN')
                   ) THEN
              v_stdnt_seq := v_stdnt_seq + 1;
              DECLARE
                l_rowid1 VARCHAR2 (25);
              BEGIN
                igs_as_msht_su_atmpt_pkg.insert_row (
                  x_mode                         => 'R',
                  x_rowid                        => l_rowid1,
                  x_sheet_number                 => v_ms_sequence_number,
                  x_person_id                    => v_sua_person_id_rec.person_id,
                  x_course_cd                    => v_sua_person_id_rec.course_cd,
                  x_unit_cd                      => v_sua_person_id_rec.unit_cd,
                  x_cal_type                     => v_sua_person_id_rec.cal_type,
                  x_ci_sequence_number           => v_sua_person_id_rec.ci_sequence_number,
                  x_location_cd                  => v_sua_person_id_rec.location_cd,
                  x_unit_mode                    => v_sua_person_id_rec.unit_mode,
                  x_unit_class                   => v_sua_person_id_rec.unit_class,
                  x_student_sequence             => v_stdnt_seq,
                  x_uoo_id                       => lp_uoo_id
                );
              END;
            END IF;
          END LOOP;
        ELSIF p_sort_by = 'SURNAME' THEN
          FOR v_sua_surname_rec IN c_sua_surname (
                                     lp_uop_unit_cd,
                                     lp_uop_version_number,
                                     lp_uop_cal_type,
                                     lp_uop_ci_sequence_number,
                                     lp_location_cd,
                                     lp_unit_mode,
                                     lp_uoo_id
                                   ) LOOP
            IF NOT (p_include_discont_ind = 'N'
                    AND v_sua_surname_rec.unit_attempt_status = 'DISCONTIN'
                   ) THEN
              v_stdnt_seq := v_stdnt_seq + 1;
              DECLARE
                l_rowid4 VARCHAR2 (25);
              BEGIN
                igs_as_msht_su_atmpt_pkg.insert_row (
                  x_mode                         => 'R',
                  x_rowid                        => l_rowid4,
                  x_sheet_number                 => v_ms_sequence_number,
                  x_person_id                    => v_sua_surname_rec.person_id,
                  x_course_cd                    => v_sua_surname_rec.course_cd,
                  x_unit_cd                      => v_sua_surname_rec.unit_cd,
                  x_cal_type                     => v_sua_surname_rec.cal_type,
                  x_ci_sequence_number           => v_sua_surname_rec.ci_sequence_number,
                  x_location_cd                  => v_sua_surname_rec.location_cd,
                  x_unit_mode                    => v_sua_surname_rec.unit_mode,
                  x_unit_class                   => v_sua_surname_rec.unit_class,
                  x_student_sequence             => v_stdnt_seq,
                  x_uoo_id                       => lp_uoo_id
                );
              END;
            END IF;
          END LOOP; -- v_sua_surname_rec
        END IF;
      END asspl_ins_mssua_sort;
      ----------------------------------------------- MAIN ---------------------------
    BEGIN
      IF p_assess_cal_type IS NOT NULL THEN
        IF p_assess_sequence_number IS NULL THEN
          p_group_sequence_number := NULL;
          RETURN FALSE;
        END IF;
      ELSIF p_assess_sequence_number IS NOT NULL THEN
        p_group_sequence_number := NULL;
        RETURN FALSE;
      END IF;
      IF p_teach_cal_type IS NOT NULL THEN
        IF p_teach_sequence_number IS NULL THEN
          p_group_sequence_number := NULL;
          RETURN FALSE;
        END IF;
      ELSIF p_teach_sequence_number IS NOT NULL THEN
        p_group_sequence_number := NULL;
        RETURN FALSE;
      END IF;
      IF (p_unit_cd IS NULL)
         OR (p_include_discont_ind NOT IN ('Y', 'N'))
         OR (p_sort_by NOT IN ('ID', 'SURNAME')) THEN
        p_group_sequence_number := NULL;
        RETURN FALSE;
      END IF;
      -- get the next IGS_AS_MARK_SHEET.group_sequence_number for the new mark sheet
      OPEN c_get_nxt_grp_seq_no;
      FETCH c_get_nxt_grp_seq_no INTO v_group_sequence_number;
      CLOSE c_get_nxt_grp_seq_no;
      -- select the mark sheets to produce based on the input parameters
      FOR v_uop_rec IN c_uop (p_assess_cal_type, p_assess_sequence_number, p_teach_cal_type, p_teach_sequence_number) LOOP
        -- store IGS_AS_MARK_SHEET.sheet_number and create mark sheet record
        OPEN c_get_nxt_seq_no;
        FETCH c_get_nxt_seq_no INTO v_ms_sequence_number;
        CLOSE c_get_nxt_seq_no;
        DECLARE
          l_rowid6 VARCHAR2 (25);
          l_org_id NUMBER (15);
        BEGIN
          -- get org_id
          l_org_id := igs_ge_gen_003.get_org_id;
          igs_as_mark_sheet_pkg.insert_row (
            x_mode                         => 'R',
            x_rowid                        => l_rowid6,
            x_org_id                       => l_org_id,
            x_sheet_number                 => v_ms_sequence_number,
            x_group_sequence_number        => v_group_sequence_number,
            x_unit_cd                      => v_uop_rec.unit_cd,
            x_version_number               => v_uop_rec.version_number,
            x_cal_type                     => v_uop_rec.cal_type,
            x_ci_sequence_number           => v_uop_rec.ci_sequence_number,
            x_location_cd                  => v_uop_rec.location_cd,
            x_unit_mode                    => v_uop_rec.unit_mode,
            x_production_dt                => SYSDATE,
            x_duplicate_ind                => NULL,
            x_grading_period_cd            => p_grading_period_cd
          );
        END;
        v_ins_ms := TRUE;
        -- select students to be included in mark sheets and insert student details in
        -- to MSSUA
        asspl_ins_mssua_sort (
          v_uop_rec.location_cd,
          v_uop_rec.unit_mode,
          p_sort_by,
          v_uop_rec.unit_cd,
          v_uop_rec.version_number,
          v_uop_rec.cal_type,
          v_uop_rec.ci_sequence_number,
          v_ms_sequence_number,
          v_group_sequence_number,
          v_uop_rec.uoo_id
        );
        -- Check if the sheet is not a duplicate of another mark sheet
        v_duplicate_sheet := FALSE;
        FOR v_ms_rec IN c_ms1 (
                          v_uop_rec.unit_cd,
                          v_uop_rec.version_number,
                          v_uop_rec.cal_type,
                          v_uop_rec.ci_sequence_number,
                          v_ms_sequence_number
                        ) LOOP
          FOR v_mssua1_rec IN c_mssua1 (v_ms_sequence_number) LOOP
            v_not_duplicate := FALSE;
            OPEN c_mssua2 (v_ms_rec.sheet_number, v_mssua1_rec.person_id);
            FETCH c_mssua2 INTO v_sheet_number,
                                v_person_id,
                                v_course_cd,
                                v_unit_cd,
                                v_cal_type,
                                v_ci_sequence_number,
                                v_student_sequence,
                                v_unit_class,
                                v_update_on,
                                v_update_who;

            IF (c_mssua2%NOTFOUND) THEN
              v_not_duplicate := TRUE;
            END IF;
            CLOSE c_mssua2;
            EXIT;
          END LOOP;
          IF v_not_duplicate = FALSE THEN
            v_duplicate_sheet := TRUE;
            -- open cursor in which the update of IGS_AS_MARK_SHEET.duplicate_ind is based on
            -- if table is busy, update will be abandoned without waiting (NO_WAIT)
            OPEN c_mss (v_ms_sequence_number);
            FETCH c_mss INTO v_mss_mark_sheet;
            UPDATE igs_as_mark_sheet_all
               SET duplicate_ind = 'Y'
             WHERE  CURRENT OF c_mss;
            CLOSE c_mss;
            EXIT;
          END IF;
        END LOOP;
      END LOOP;
      IF v_ins_ms = TRUE THEN
        -- Delete sheets which were created but have no students.
        DELETE igs_as_mark_sheet_all
        WHERE  group_sequence_number = v_group_sequence_number
        AND         NOT EXISTS ( SELECT sheet_number
                                 FROM   igs_as_msht_su_atmpt
                                 WHERE  sheet_number = igs_as_mark_sheet_all.sheet_number);
        p_group_sequence_number := v_group_sequence_number;
        RETURN TRUE;
      ELSE
        p_group_sequence_number := NULL;
        RETURN FALSE;
      END IF;
    EXCEPTION
      WHEN e_resource_busy THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_LOCKED');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
        RETURN FALSE;
      WHEN OTHERS THEN
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token ('NAME', 'IGS_AS_GEN_004.assp_ins_mark_sheet_INNER');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_004.assp_ins_mark_sheet');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_ins_mark_sheet;
  --
  --
  --
  FUNCTION assp_ins_scap_lovall (
    p_person_id                    IN     igs_as_spl_cons_appl.person_id%TYPE,
    p_course_cd                    IN     igs_as_spl_cons_appl.course_cd%TYPE,
    p_unit_cd                      IN     igs_as_spl_cons_appl.unit_cd%TYPE,
    p_cal_type                     IN     igs_as_spl_cons_appl.cal_type%TYPE,
    p_ci_sequence_number           IN     NUMBER,
    p_received_dt                  IN     DATE,
    p_spcl_consideration_cat       IN     VARCHAR2,
    p_estimated_processing_days    IN     NUMBER,
    p_sought_outcome               IN     VARCHAR2,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_notified_date                IN     DATE
  ) RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_ins_scap_lovall
    -- This procedure is responsible for copying all of the assessment
    -- items for a Student IGS_PS_UNIT Attempt to the Special Consideration
    -- Application table.
    DECLARE
      v_ass_id                 igs_as_su_atmpt_itm.ass_id%TYPE;
      v_creation_dt            igs_as_su_atmpt_itm.creation_dt%TYPE;
      v_spcl_consideration_cat igs_as_spcl_cons_cat.spcl_consideration_cat%TYPE;
      v_static_sysdate         igs_as_spl_cons_appl.received_dt%TYPE;
      v_ins_fail_flag          BOOLEAN                                            DEFAULT FALSE;
      v_scap_exists_flag       BOOLEAN                                            DEFAULT FALSE;
      v_scap_error_flag        BOOLEAN                                            DEFAULT FALSE;
      v_suaai_error_flag       BOOLEAN                                            DEFAULT FALSE;
      v_select_ktr             NUMBER                                             DEFAULT 0;
      v_insert_ktr             NUMBER                                             DEFAULT 0;
      v_message_name           VARCHAR2 (30)                                      DEFAULT NULL;
      CURSOR c_suaai IS
        SELECT suaai.ass_id,
               suaai.creation_dt
        FROM   igs_as_su_atmpt_itm suaai
        WHERE  suaai.person_id = p_person_id
        AND    suaai.course_cd = p_course_cd
        AND    suaai.uoo_id = p_uoo_id
        AND    suaai.logical_delete_dt IS NULL
        AND    suaai.creation_dt = (SELECT MAX (suaai2.creation_dt)
                                    FROM   igs_as_su_atmpt_itm suaai2
                                    WHERE  suaai2.person_id = suaai.person_id
                                    AND    suaai2.course_cd = suaai.course_cd
                                    AND    suaai2.uoo_id = suaai.uoo_id
                                    AND    suaai2.logical_delete_dt IS NULL
                                    AND    suaai2.ass_id = suaai.ass_id);
      CURSOR c_scap (cp_ass_id igs_as_spl_cons_appl.ass_id%TYPE) IS
        SELECT ass_id
        FROM   igs_as_spl_cons_appl
        WHERE  person_id = p_person_id
        AND    course_cd = p_course_cd
        AND    uoo_id = p_uoo_id
        AND    ass_id = cp_ass_id;
    BEGIN
      -- Initialise message number and variable
      p_message_name := NULL;
      v_static_sysdate := SYSDATE;
      OPEN c_suaai;
      FETCH c_suaai INTO v_ass_id,
                         v_creation_dt;
      IF (c_suaai%NOTFOUND) THEN
        -- SUAAI do not exist
        CLOSE c_suaai;
        p_message_name := 'IGS_AS_ASSITEM_DOESNOT_EXISTS';
        RETURN FALSE;
      END IF;
      CLOSE c_suaai;
      FOR v_suaai_rec IN c_suaai LOOP
        v_select_ktr := v_select_ktr + 1;
        -- Check to see if ass item already has a special consid applic
        OPEN c_scap (v_suaai_rec.ass_id);
        FETCH c_scap INTO v_ass_id;
        IF (c_scap%FOUND) THEN
          v_scap_exists_flag := TRUE;
        ELSE
          v_scap_exists_flag := FALSE;
        END IF;
        CLOSE c_scap;
        IF (igs_as_val_scap.assp_val_suaai_ins (
              p_person_id,
              p_course_cd,
              p_unit_cd,
              p_cal_type,
              p_ci_sequence_number,
              v_suaai_rec.ass_id,
              v_message_name,
              p_uoo_id
            ) = FALSE
            AND v_message_name <> 'IGS_AS_SUA_STATUS_INVALID_COM'
           ) THEN
          -- Do not perform insert
          IF v_message_name = 'IGS_AS_SUA_STATUS_INVALID' THEN
            -- SUA IGS_PS_UNIT status is invalid
            p_message_name := 'IGS_AS_SPLAPPL_NC_ASSITEM_SUA';
            RETURN FALSE;
          ELSE
            -- SUA ass item is invalid
            v_suaai_error_flag := TRUE;
          END IF;
        ELSE
          IF v_scap_exists_flag = TRUE THEN
            -- Do not perform insert
            -- SCAP already exist for ass item
            v_scap_error_flag := TRUE;
          ELSE
            DECLARE
              l_rowid7 VARCHAR (25);
            BEGIN
              igs_as_spl_cons_appl_pkg.insert_row (
                x_mode                         => 'R',
                x_rowid                        => l_rowid7,
                x_person_id                    => p_person_id,
                x_course_cd                    => p_course_cd,
                x_unit_cd                      => p_unit_cd,
                x_cal_type                     => p_cal_type,
                x_ci_sequence_number           => p_ci_sequence_number,
                x_ass_id                       => v_suaai_rec.ass_id,
                x_creation_dt                  => v_suaai_rec.creation_dt,
                x_received_dt                  => p_received_dt,
                x_spcl_consideration_cat       => p_spcl_consideration_cat,
                x_sought_outcome               => p_sought_outcome,
                x_spcl_consideration_outcome   => NULL,
                x_tracking_id                  => NULL,
                x_estimated_processing_days    => p_estimated_processing_days,
                x_comments                     =>    'Special consideration application for'
                                                  || ' all assessment items for the unit attempt.',
                x_uoo_id                       => p_uoo_id,
                x_notified_date                => p_notified_date
              );
              v_insert_ktr := v_insert_ktr + 1;
            END;
          END IF;
        END IF;
      END LOOP;
      IF v_insert_ktr = 0 THEN
        IF v_scap_error_flag THEN
          IF v_suaai_error_flag THEN
            p_message_name := 'IGS_AS_SPLAPPL_NC_ASSITEM_INV';
            RETURN FALSE;
          ELSE
            p_message_name := 'IGS_AS_SPLAPPL_NC_ASSITEM_AI';
            RETURN FALSE;
          END IF;
        ELSE
          IF v_suaai_error_flag THEN
            p_message_name := 'IGS_AS_SPLAPPL_NC_AI_INVALID';
            RETURN FALSE;
          ELSE
            p_message_name := 'IGS_AS_SPLAPPL_NC_INVESTIGATI';
            RETURN FALSE;
          END IF;
        END IF;
      END IF;
      IF v_insert_ktr < v_select_ktr THEN
        IF v_scap_error_flag THEN
          IF v_suaai_error_flag THEN
            p_message_name := 'IGS_AS_SPLAPPL_NC_APPL_EXISTS';
            RETURN FALSE;
          ELSE
            p_message_name := 'IGS_AS_SPLAPPL_NC_APPL_EXIST';
            RETURN FALSE;
          END IF;
        ELSE
          IF v_suaai_error_flag THEN
            p_message_name := 'IGS_AS_SPLAPPL_NC_ASI_INVALID';
            RETURN FALSE;
          ELSE
            p_message_name := 'IGS_AS_SPLCONS_APPL_NOT_CREAT';
            RETURN FALSE;
          END IF;
        END IF;
      END IF;
      RETURN TRUE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_004.assp_ins_scap_lovall');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_ins_scap_lovall;
  --
  -- This routine will insert default Assessment Items for the student or update
  -- the changed setup for Assessment Items
  --
  FUNCTION assp_ins_suaai_dflt (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_ass_id                       IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_ass_id_usec_unit_ind         IN     VARCHAR2 DEFAULT 'UNIT', -- Added by DDEY as a part of enhancement Bug # 2162831
    p_creation_dt                  IN     DATE,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_ass_item_id                  IN NUMBER ,
    p_group_id                     IN NUMBER,
    p_midterm_mandatory_type_code  IN VARCHAR2,
    p_midterm_weight_qty           IN NUMBER ,
    p_final_mandatory_type_code    IN VARCHAR2,
    p_final_weight_qty             IN NUMBER,
    p_grading_schema_cd            IN VARCHAR2,
    p_gs_version_number            IN NUMBER,
    p_uoo_id                       IN  NUMBER
  ) RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN
    --
    DECLARE
      cst_yes      CONSTANT CHAR                                         := 'Y';
      cst_enrolled CONSTANT VARCHAR2 (10)                                := 'ENROLLED';
      cst_pattern  CONSTANT VARCHAR2 (10)                                := 'PATTERN';
      cst_item     CONSTANT VARCHAR2 (10)                                := 'ITEM';
      e_resource_busy       EXCEPTION;
      v_dummy               VARCHAR2 (1);
      v_level               VARCHAR2 (10);
      v_message_name        VARCHAR2 (30);
      v_attempt_number      igs_as_su_atmpt_itm.attempt_number%TYPE;
      v_course_type         igs_ps_ver.course_type%TYPE;
      v_creation_dt         DATE;
      l_update_flag         VARCHAR2 (20)                                := 'FALSE';
    --  l_grading_schema_cd   igs_ps_unitass_item.grading_schema_cd%TYPE;
    --  l_gs_version_number   igs_ps_unitass_item.gs_version_number%TYPE;
      --
      -- Get the Unit Section ID
      --
/*      CURSOR cur_uoo_id IS
        SELECT uoo_id
        FROM   igs_ps_unit_ofr_opt
        WHERE  unit_cd = p_unit_cd
        AND    version_number = p_version_number
        AND    cal_type = p_cal_type
        AND    ci_sequence_number = p_ci_sequence_number
        AND    location_cd = p_location_cd
        AND    unit_class = p_unit_class;*/
      --
     -- rec_uoo_id            cur_uoo_id%ROWTYPE;
      --
      -- For checking the unit status i.e., it should be ENROLLED.
      --
      CURSOR c_sua_status (cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
        SELECT 'X'
        FROM   igs_en_su_attempt sua
        WHERE  sua.person_id = p_person_id
        AND    sua.course_cd = p_course_cd
        AND    sua.uoo_id = cp_uoo_id
        AND    sua.unit_attempt_status = cst_enrolled;
      --
      sua_status_rec        c_sua_status%ROWTYPE;
      --
      -- For checking if the unit assessment item is MANUALLY delete or not.
      --
      CURSOR c_suaai_deleted (cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
        SELECT 'x'
        FROM   igs_as_su_atmpt_itm suaai
        WHERE  suaai.person_id = p_person_id
        AND    suaai.course_cd = p_course_cd
        AND    suaai.uoo_id = cp_uoo_id
        AND    suaai.ass_id = p_ass_id
        AND    suaai.logical_delete_dt IS NOT NULL
        AND    suaai.s_default_ind = 'N'
        AND    NOT EXISTS ( SELECT 'x'
                            FROM   igs_as_su_atmpt_itm suaai
                            WHERE  suaai.person_id = p_person_id
                            AND    suaai.course_cd = p_course_cd
                            AND    suaai.uoo_id = cp_uoo_id
                            AND    suaai.ass_id = p_ass_id
                            AND    suaai.logical_delete_dt IS NULL);
      --
      CURSOR c_crv IS
        SELECT crv.course_type
        FROM   igs_en_stdnt_ps_att sca,
               igs_ps_ver crv
        WHERE  sca.person_id = p_person_id
        AND    sca.course_cd = p_course_cd
        AND    sca.course_cd = crv.course_cd
        AND    sca.version_number = crv.version_number;
      --
      --
      --
      CURSOR c_suaai_an (cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
        SELECT NVL (MAX (suaai.attempt_number), 0) + 1
        FROM   igs_as_su_atmpt_itm suaai
        WHERE  suaai.person_id = p_person_id
        AND    suaai.course_cd = p_course_cd
        AND    suaai.uoo_id = cp_uoo_id
        AND    suaai.ass_id = p_ass_id
        AND    suaai.logical_delete_dt IS NULL;
      --
      -- Added by DDEY as a part of enhancement Bug # 2162831
      -- This cursor is declared to fetch the Assessment Items which are are attached to the
      -- Assessment Pattern , but already logically deleted. This would enable the logical deleted
      -- record to be back in the system.
      --
      CURSOR c_suaai_upd (cp_ass_id igs_ps_unitass_item.ass_id%TYPE, cp_uoo_id igs_en_su_attempt.uoo_id%TYPE , cp_ass_item_id igs_as_su_atmpt_itm.unit_section_ass_item_id%TYPE ) IS
        SELECT        suaai.ROWID,
                      suaai.*,
                      sag.unit_ass_item_group_id,
                      sag.us_ass_item_group_id
        FROM          igs_as_su_atmpt_itm suaai,
                      igs_as_sua_ai_group sag
        WHERE         suaai.person_id = p_person_id
        AND           suaai.course_cd = p_course_cd
        AND           suaai.uoo_id = cp_uoo_id
        AND           suaai.ass_id = cp_ass_id
        AND           (suaai.unit_section_ass_item_id = cp_ass_item_id OR suaai.UNIT_ASS_ITEM_ID = cp_ass_item_id)
        AND           suaai.sua_ass_item_group_id = sag.sua_ass_item_group_id
       /* AND    NOT EXISTS (
                 SELECT 'X'
                 FROM   igs_as_su_atmpt_itm suaai1
                 WHERE  suaai1.person_id = suaai.person_id
                 AND    suaai1.course_cd = suaai.course_cd
                 AND    suaai1.uoo_id = suaai.uoo_id
                 AND    suaai1.unit_section_ass_item_id IS NOT NULL
                 AND    p_ass_id_usec_unit_ind = 'UNIT'
                 ) */;
      --
      suaai_upd_rec         c_suaai_upd%ROWTYPE;
      --
    BEGIN
      --
      -- Set the default values
      --
      p_message_name := NULL;
      v_level := cst_item;
      p_error_count := 0;
      p_warning_count := 0;
/*      OPEN cur_uoo_id;
      FETCH cur_uoo_id INTO rec_uoo_id;
      CLOSE cur_uoo_id;
*/      --
      -- Check the status of the student unit attempt. Assessment items will only be
      -- assigned if the status is 'ENROLLED'. The status may have been updated
      -- since the triggering action for this process was created (IGS_PE_STD_TODO).
      --
      OPEN c_sua_status (p_uoo_id);
      FETCH c_sua_status INTO sua_status_rec;
      IF c_sua_status%NOTFOUND THEN
        CLOSE c_sua_status;
        p_message_name := 'IGS_AS_SUA_STATUS_INVALID_ENR';
        RETURN FALSE;
      END IF;
      CLOSE c_sua_status;
      --
      -- Validate that the Assessment Item has not been manually deleted previously
      -- (ie. s_default_ind = 'N'). If such occurance has happened, then do not add
      -- the item to the student again.
      --
      OPEN c_suaai_deleted (p_uoo_id);
      FETCH c_suaai_deleted INTO v_dummy;
      IF c_suaai_deleted%FOUND THEN
        CLOSE c_suaai_deleted;
        --
        -- Log warning that the item has not been added as has been previously deleted
        --
        igs_ge_ins_sle.genp_set_log_entry (
          p_s_log_type,
          p_key,
          p_sle_key,
          'IGS_AS_CANNOT_CREATE_DFLT_AI', -- Cannot create item as it has previously been deleted
          'WARNING|' || v_level || '|' || TO_CHAR (NULL) || '|' || TO_CHAR (p_ass_id)
        );
        p_warning_count := p_warning_count + 1;
        p_message_name := 'IGS_AS_CANNOT_CREATE_DFLT_AI';
        RETURN FALSE;
      END IF;
      CLOSE c_suaai_deleted;
      --
      -- If the assessment item is valid then check if any course type restrictions.
      --
      OPEN c_crv;
      FETCH c_crv INTO v_course_type;
      CLOSE c_crv;
      --
      IF igs_as_val_suaai.assp_val_ai_acot (
           p_ass_id,
           v_course_type,
           v_message_name
         ) = FALSE THEN
        -- Log warning that there exists a course restriction
        --
        igs_ge_ins_sle.genp_set_log_entry (
          p_s_log_type,
          p_key,
          p_sle_key,
          v_message_name, -- Warn item cannot be added due to course restriction
          -- against the item
          'WARNING|' || v_level || '|' || TO_CHAR (NULL) || '|' || TO_CHAR (p_ass_id)
        );
        p_warning_count := p_warning_count + 1;
        p_message_name := v_message_name;
        RETURN FALSE;
      END IF;
      --
      IF p_creation_dt IS NULL THEN
        v_creation_dt := SYSDATE;
      ELSE
        v_creation_dt := p_creation_dt;
      END IF;
      --
      -- Insert/Update the Assessment Item for the Student Unit Attempt
      --
      DECLARE
        l_rowid8                   VARCHAR2 (25);

     -- Bug # 3749413
        --
        -- Start of new code added as per Bug# 2829291;
        -- Check if the Assessment Item is attached from the Unit Section Level.
        --
    /*    CURSOR cur_c1 (
          cp_person_id                          NUMBER,
          cp_ass_id                             NUMBER,
          cp_course_cd                          VARCHAR2,
          cp_uoo_id                             NUMBER,
          cp_group_id                           NUMBER
        ) IS
          SELECT suv.unit_section_ass_item_id,
                 suv.us_ass_item_group_id,
                 suv.midterm_mandatory_type_code,
                 suv.midterm_weight_qty,
                 suv.final_mandatory_type_code,
                 suv.final_weight_qty,
                 suv.grading_schema_cd,
                 suv.gs_version_number,
                 usaig.group_name
          FROM   igs_as_usecai_sua_v suv,
                 igs_as_us_ai_group usaig
          WHERE  suv.person_id = cp_person_id
          AND    suv.ass_id = cp_ass_id
          AND    suv.course_cd = cp_course_cd
          AND    suv.uoo_id = cp_uoo_id
          AND    usaig.us_ass_item_group_id = cp_group_id
          AND    suv.us_ass_item_group_id = usaig.us_ass_item_group_id;
        */


        -- rec_c1                     cur_c1%ROWTYPE;

        --
        -- Check if the Assessment Item is attached from the Unit Level.
        --
       /*
        CURSOR cur_c2 (
          cp_person_id                          NUMBER,
          cp_ass_id                             NUMBER,
          cp_course_cd                          VARCHAR2,
          cp_uoo_id                             NUMBER,
          cp_group_id                           NUMBER
        ) IS
          SELECT suv.unit_ass_item_id,
                 suv.unit_ass_item_group_id,
                 suv.midterm_mandatory_type_code,
                 suv.midterm_weight_qty,
                 suv.final_mandatory_type_code,
                 suv.final_weight_qty,
                 suv.grading_schema_cd,
                 suv.gs_version_number,
                 uaig.group_name
          FROM   igs_as_uai_sua_v suv,
                 igs_as_unit_ai_grp uaig
          WHERE  suv.person_id = cp_person_id
          AND    suv.ass_id = cp_ass_id
          AND    suv.course_cd = cp_course_cd
          AND    suv.uoo_id = cp_uoo_id
          AND    uaig.unit_ass_item_group_id = cp_group_id
          AND    suv.unit_ass_item_group_id = uaig.unit_ass_item_group_id; */
      --
      --  rec_c2                     cur_c2%ROWTYPE;


      -- Bug # 3749413

        --
        -- Check if there are any Unit Section Assessment Items which are active
        --
        CURSOR cur_usec_ass_items_exist (
                 cp_uoo_id NUMBER
               ) IS
          SELECT 'Y' ass_item_exists
          FROM   igs_ps_unitass_item
          WHERE  uoo_id = cp_uoo_id
          AND    logical_delete_dt IS NULL;
        --
        rec_usec_ass_items_exist cur_usec_ass_items_exist%ROWTYPE;
        --
        -- Get all the Student Unit Attempt Assessment Items that are attached
        -- from Unit level
        --
        CURSOR cur_suaai_from_unit (
          cp_person_id                          NUMBER,
          cp_course_cd                          VARCHAR2,
          cp_uoo_id                             NUMBER
        ) IS
          SELECT suaai.ROWID,
                 suaai.*
          FROM   igs_as_su_atmpt_itm suaai
          WHERE  person_id = cp_person_id
          AND    course_cd = cp_course_cd
          AND    uoo_id = cp_uoo_id
          AND    unit_ass_item_id IS NOT NULL
          AND    logical_delete_dt IS NULL;
        --
        -- Unit Section Assessment Item Group Details
        --
        CURSOR cur_usec_aig (
                 cp_us_ass_item_group_id IN NUMBER
               ) IS
          SELECT   usaig.*
          FROM     igs_as_us_ai_group usaig
          WHERE    usaig.us_ass_item_group_id = cp_us_ass_item_group_id;
        --
        rec_usec_aig cur_usec_aig%ROWTYPE;
        --
        -- Unit Assessment Item Group Details
        --
        CURSOR cur_unit_aig (
                 cp_unit_ass_item_group_id IN NUMBER
               ) IS
          SELECT   uaig.*
          FROM     igs_as_unit_ai_grp uaig
          WHERE    uaig.unit_ass_item_group_id = cp_unit_ass_item_group_id;
        --
        rec_unit_aig cur_unit_aig%ROWTYPE;
        --
        -- Check if the Student Unit Attempt Assessment Item Group exists for
        -- the items copied from Unit Assessment Items
        --
        CURSOR cur_unit_suaig_exists (
                 cp_group_id IN NUMBER,
                 cp_person_id IN NUMBER,
                 cp_course_cd IN VARCHAR2,
                 cp_uoo_id IN VARCHAR2
               ) IS
          SELECT   sua_ass_item_group_id,
                   us_ass_item_group_id,
                   unit_ass_item_group_id,
                   group_name,
                   rowid
          FROM     igs_as_sua_ai_group suaaig
          WHERE    suaaig.unit_ass_item_group_id = cp_group_id
          AND      suaaig.person_id = cp_person_id
          AND      suaaig.course_cd = cp_course_cd
          AND      suaaig.uoo_id = cp_uoo_id
          ORDER BY unit_ass_item_group_id, us_ass_item_group_id;
        --
        -- Check if the Student Unit Attempt Assessment Item Group exists for
        -- the items copied from Unit Section Assessment Items
        --
        CURSOR cur_usec_suaig_exists (
                 cp_group_id IN NUMBER,
                 cp_person_id IN NUMBER,
                 cp_course_cd IN VARCHAR2,
                 cp_uoo_id IN VARCHAR2
               ) IS
          SELECT   sua_ass_item_group_id,
                   us_ass_item_group_id,
                   unit_ass_item_group_id,
                   group_name,
                   rowid
          FROM     igs_as_sua_ai_group suaaig
          WHERE    suaaig.us_ass_item_group_id = cp_group_id
          AND      suaaig.person_id = cp_person_id
          AND      suaaig.course_cd = cp_course_cd
          AND      suaaig.uoo_id = cp_uoo_id
          FOR UPDATE OF logical_delete_date NOWAIT;
        --
        rec_suaig cur_unit_suaig_exists%ROWTYPE;
        l_group_name VARCHAR2(30);
    -- Bug # 3749413

      /*  l_unit_section_ass_item_id igs_ps_unitass_item.unit_section_ass_item_id%TYPE;
        l_unit_ass_item_id         igs_as_unitass_item_all.unit_ass_item_id%TYPE;
        l_midterm_mandatory_type_code VARCHAR2(30);
        l_midterm_weight_qty NUMBER(6,3);
        l_final_mandatory_type_code VARCHAR2(30);
        l_final_weight_qty NUMBER(6,3);
        l_grading_schema_cd VARCHAR2(30);
        l_gs_version_number NUMBER; */

    -- Bug # 3749413

        l_return_pk_id NUMBER;
        l_unit_assessment_id igs_ps_unitass_item.unit_section_ass_item_id%TYPE;
        l_us_assessment_id   igs_ps_unitass_item.unit_section_ass_item_id%TYPE;

        -- End of new code added as per Bug# 2829291;
      BEGIN
        --
        -- Start of new code added as per Bug# 2829291;
        -- Initialise local variables.
        --

        /* l_unit_section_ass_item_id := NULL;
           l_unit_ass_item_id := NULL; */

        --
        -- Check if the Assessment Item is attached from the Unit Section Level.
        --

   -- Bug # 3749413

       /*
        OPEN cur_c1 (
               p_person_id,
               p_ass_id,
               p_course_cd,
               rec_uoo_id.uoo_id,
               p_group_id
             );
        FETCH cur_c1 INTO rec_c1;
        IF cur_c1%FOUND THEN
          CLOSE cur_c1;
          l_unit_section_ass_item_id := rec_c1.unit_section_ass_item_id;
          l_midterm_mandatory_type_code := rec_c1.midterm_mandatory_type_code;
          l_midterm_weight_qty := rec_c1.midterm_weight_qty;
          l_final_mandatory_type_code := rec_c1.final_mandatory_type_code;
          l_final_weight_qty := rec_c1.final_weight_qty;
          l_grading_schema_cd := rec_c1.grading_schema_cd;
          l_gs_version_number := rec_c1.gs_version_number;
        ELSE
          CLOSE cur_c1;
          --
          -- Check if the Assessment Item is attached from the Unit Level.
          --
          OPEN cur_c2 (
                 p_person_id,
                 p_ass_id,
                 p_course_cd,
                 rec_uoo_id.uoo_id,
                 p_group_id
               );
          FETCH cur_c2 INTO rec_c2;
          IF cur_c2%FOUND THEN
            l_unit_ass_item_id := rec_c2.unit_ass_item_id;
            l_midterm_mandatory_type_code := rec_c2.midterm_mandatory_type_code;
            l_midterm_weight_qty := rec_c2.midterm_weight_qty;
            l_final_mandatory_type_code := rec_c2.final_mandatory_type_code;
            l_final_weight_qty := rec_c2.final_weight_qty;
            l_grading_schema_cd := rec_c2.grading_schema_cd;
            l_gs_version_number := rec_c2.gs_version_number;
          END IF;
          CLOSE cur_c2;
        END IF;
        */
   -- Bug # 3749413
        --
        -- End of new code added as per Bug# 2829291;
        -- Added by DDEY as a part of enhancement Bug # 2162831
        --
        -- Check if the Assessment Item Group is already created for the
        -- Assessment Item being added. If not created then create the
        -- Assessment Item Group and then the Assessment Items under that Group
        -- Get the details of the Assessment Item Group either from Unit Section
        -- or Unit level based on from where the item is being attached
        --
        IF (p_ass_id_usec_unit_ind = 'USEC') THEN
          --
          -- Check if there exists any assessment item setup for the student's
          -- unit section. If the setup exists at unit section level and the
          -- student carries assessment items from unit level, then logically
          -- delete all the student unit assessment items and attach to the
          -- student all default active assessment items from unit section level.
          --
          OPEN cur_usec_ass_items_exist (p_uoo_id);
          FETCH cur_usec_ass_items_exist INTO rec_usec_ass_items_exist;
          CLOSE cur_usec_ass_items_exist;
          --
          IF (rec_usec_ass_items_exist.ass_item_exists = 'Y') THEN
            --
            UPDATE igs_as_su_atmpt_itm suaai
               SET suaai.logical_delete_dt = SYSDATE,
                   suaai.last_update_date = SYSDATE,
                   suaai.last_updated_by = fnd_global.user_id,
                   suaai.last_update_login = fnd_global.login_id,
                   suaai.request_id = fnd_global.conc_request_id,
                   suaai.program_id = fnd_global.conc_program_id,
                   suaai.program_application_id = fnd_global.prog_appl_id,
                   suaai.program_update_date = SYSDATE
             WHERE suaai.person_id = p_person_id
             AND   suaai.course_cd = p_course_cd
             AND   suaai.uoo_id = p_uoo_id
             AND   suaai.unit_ass_item_id IS NOT NULL
             AND   suaai.logical_delete_dt IS NULL;
            --
            UPDATE igs_as_sua_ai_group suaaig
            SET    suaaig.logical_delete_date = SYSDATE,
                   suaaig.last_update_date = SYSDATE,
                   suaaig.last_updated_by = fnd_global.user_id,
                   suaaig.last_update_login = fnd_global.login_id
            WHERE  suaaig.person_id = p_person_id
             AND   suaaig.course_cd = p_course_cd
             AND   suaaig.uoo_id = p_uoo_id
             AND   suaaig.unit_ass_item_group_id IS NOT NULL
             AND   suaaig.logical_delete_date IS NULL;
            --
            OPEN cur_usec_suaig_exists (
                   p_group_id,
                   p_person_id,
                   p_course_cd,
                   p_uoo_id
                 );
            FETCH cur_usec_suaig_exists INTO rec_suaig;
            --
            IF (cur_usec_suaig_exists%NOTFOUND) THEN
              CLOSE cur_usec_suaig_exists;
              OPEN cur_usec_aig (p_group_id);
              FETCH cur_usec_aig INTO rec_usec_aig;
              CLOSE cur_usec_aig;
              l_rowid8 := NULL;
              igs_as_sua_ai_group_pkg.insert_row (
                x_rowid                             => l_rowid8,
                x_sua_ass_item_group_id             => l_return_pk_id,
                x_person_id                         => p_person_id,
                x_course_cd                         => p_course_cd,
                x_uoo_id                            => p_uoo_id,
                x_group_name                        => rec_usec_aig.group_name,
                x_midterm_formula_code              => rec_usec_aig.midterm_formula_code,
                x_midterm_formula_qty               => rec_usec_aig.midterm_formula_qty,
                x_midterm_weight_qty                => rec_usec_aig.midterm_weight_qty,
                x_final_formula_code                => rec_usec_aig.final_formula_code,
                x_final_formula_qty                 => rec_usec_aig.final_formula_qty,
                x_final_weight_qty                  => rec_usec_aig.final_weight_qty,
                x_unit_ass_item_group_id            => NULL,
                x_us_ass_item_group_id              => rec_usec_aig.us_ass_item_group_id,
                x_logical_delete_date               => NULL,
                x_mode                              => 'R'
              );
            ELSE
              --
              -- Update the SUAI Group definition from latest USAIG definition
              --
              OPEN cur_usec_aig (p_group_id);
              FETCH cur_usec_aig INTO rec_usec_aig;
              CLOSE cur_usec_aig;
              igs_as_sua_ai_group_pkg.update_row (
                x_rowid                             => rec_suaig.rowid,
                x_sua_ass_item_group_id             => rec_suaig.sua_ass_item_group_id,
                x_person_id                         => p_person_id,
                x_course_cd                         => p_course_cd,
                x_uoo_id                            => p_uoo_id,
                x_group_name                        => rec_suaig.group_name,
                x_midterm_formula_code              => rec_usec_aig.midterm_formula_code,
                x_midterm_formula_qty               => rec_usec_aig.midterm_formula_qty,
                x_midterm_weight_qty                => rec_usec_aig.midterm_weight_qty,
                x_final_formula_code                => rec_usec_aig.final_formula_code,
                x_final_formula_qty                 => rec_usec_aig.final_formula_qty,
                x_final_weight_qty                  => rec_usec_aig.final_weight_qty,
                x_unit_ass_item_group_id            => NULL,
                x_us_ass_item_group_id              => rec_usec_aig.us_ass_item_group_id,
                x_logical_delete_date               => NULL,
                x_mode                              => 'R'
              );
              l_return_pk_id := rec_suaig.sua_ass_item_group_id;
            END IF;
          END IF;
        ELSIF (p_ass_id_usec_unit_ind = 'UNIT') THEN
          OPEN cur_unit_suaig_exists (
                 p_group_id,
                 p_person_id,
                 p_course_cd,
                 p_uoo_id
               );
          FETCH cur_unit_suaig_exists INTO rec_suaig;
          IF (cur_unit_suaig_exists%NOTFOUND) THEN
            CLOSE cur_unit_suaig_exists;
            OPEN cur_unit_aig (p_group_id);
            FETCH cur_unit_aig INTO rec_unit_aig;
            CLOSE cur_unit_aig;
            l_rowid8 := NULL;
            igs_as_sua_ai_group_pkg.insert_row (
              x_rowid                             => l_rowid8,
              x_sua_ass_item_group_id             => l_return_pk_id,
              x_person_id                         => p_person_id,
              x_course_cd                         => p_course_cd,
              x_uoo_id                            => p_uoo_id,
              x_group_name                        => rec_unit_aig.group_name,
              x_midterm_formula_code              => rec_unit_aig.midterm_formula_code,
              x_midterm_formula_qty               => rec_unit_aig.midterm_formula_qty,
              x_midterm_weight_qty                => rec_unit_aig.midterm_weight_qty,
              x_final_formula_code                => rec_unit_aig.final_formula_code,
              x_final_formula_qty                 => rec_unit_aig.final_formula_qty,
              x_final_weight_qty                  => rec_unit_aig.final_weight_qty,
              x_unit_ass_item_group_id            => rec_unit_aig.unit_ass_item_group_id,
              x_us_ass_item_group_id              => NULL,
              x_logical_delete_date               => NULL,
              x_mode                              => 'R'
            );
          ELSE
            CLOSE cur_unit_suaig_exists;
            OPEN cur_unit_aig (p_group_id);
            FETCH cur_unit_aig INTO rec_unit_aig;
            CLOSE cur_unit_aig;
            --
            -- Update the SUAI Group definition from latest UAIG definition
            --
            igs_as_sua_ai_group_pkg.update_row (
              x_rowid                             => rec_suaig.rowid,
              x_sua_ass_item_group_id             => rec_suaig.sua_ass_item_group_id,
              x_person_id                         => p_person_id,
              x_course_cd                         => p_course_cd,
              x_uoo_id                            => p_uoo_id,
              x_group_name                        => rec_unit_aig.group_name,
              x_midterm_formula_code              => rec_unit_aig.midterm_formula_code,
              x_midterm_formula_qty               => rec_unit_aig.midterm_formula_qty,
              x_midterm_weight_qty                => rec_unit_aig.midterm_weight_qty,
              x_final_formula_code                => rec_unit_aig.final_formula_code,
              x_final_formula_qty                 => rec_unit_aig.final_formula_qty,
              x_final_weight_qty                  => rec_unit_aig.final_weight_qty,
              x_unit_ass_item_group_id            => rec_unit_aig.unit_ass_item_group_id,
              x_us_ass_item_group_id              => NULL,
              x_logical_delete_date               => NULL,
              x_mode                              => 'R'
            );
            l_return_pk_id := rec_suaig.sua_ass_item_group_id;
          END IF;
        END IF;
        --
        -- Added by DDEY as a part of enhancement Bug # 2162831
        -- Assessment Item already available in the system but is Logically Deleted
        -- So update the Logically Deleted Date to NULL to bring it back into the system
        --
        OPEN c_suaai_upd (p_ass_id, p_uoo_id,p_ass_item_id);
        FETCH c_suaai_upd INTO suaai_upd_rec;
        --
        IF ((c_suaai_upd%FOUND) AND
            (((p_ass_id_usec_unit_ind = 'UNIT') AND (suaai_upd_rec.unit_ass_item_id IS NOT NULL) AND suaai_upd_rec.unit_ass_item_group_id = p_group_id) OR
             ((p_ass_id_usec_unit_ind = 'USEC') AND (suaai_upd_rec.unit_section_ass_item_id IS NOT NULL) AND suaai_upd_rec.us_ass_item_group_id = p_group_id )) AND
            (suaai_upd_rec.logical_delete_dt IS NOT NULL)) THEN
          CLOSE c_suaai_upd;
          --
          UPDATE igs_as_su_atmpt_itm suaai
          SET    suaai.logical_delete_dt = NULL,
                 suaai.last_update_date = SYSDATE,
                 suaai.last_updated_by = fnd_global.user_id,
                 suaai.last_update_login = fnd_global.login_id,
                 suaai.request_id = fnd_global.conc_request_id,
                 suaai.program_id = fnd_global.conc_program_id,
                 suaai.program_application_id = fnd_global.prog_appl_id,
                 suaai.program_update_date = SYSDATE ,
                 suaai.midterm_mandatory_type_code = p_midterm_mandatory_type_code,
                 suaai.midterm_weight_qty          = p_midterm_weight_qty,
                 suaai.final_mandatory_type_code   = p_final_mandatory_type_code,
                 suaai.final_weight_qty            = p_final_weight_qty,
                 suaai.grading_schema_cd           = p_grading_schema_cd,
                 suaai.gs_version_number           = p_gs_version_number
          WHERE  suaai.rowid = suaai_upd_rec.ROWID;

/*          igs_as_su_atmpt_itm_pkg.update_row (
            x_mode                         => 'R',
            x_rowid                        => suaai_upd_rec.ROWID,
            x_person_id                    => suaai_upd_rec.person_id,
            x_course_cd                    => suaai_upd_rec.course_cd,
            x_unit_cd                      => suaai_upd_rec.unit_cd,
            x_cal_type                     => suaai_upd_rec.cal_type,
            x_ci_sequence_number           => suaai_upd_rec.ci_sequence_number,
            x_ass_id                       => suaai_upd_rec.ass_id,
            x_creation_dt                  => suaai_upd_rec.creation_dt,
            x_attempt_number               => suaai_upd_rec.attempt_number,
            x_outcome_dt                   => suaai_upd_rec.outcome_dt,
            x_override_due_dt              => suaai_upd_rec.override_due_dt,
            x_tracking_id                  => suaai_upd_rec.tracking_id,
            x_logical_delete_dt            => NULL,
            x_s_default_ind                => suaai_upd_rec.s_default_ind,
            x_ass_pattern_id               => suaai_upd_rec.ass_pattern_id,
            x_grading_schema_cd            => suaai_upd_rec.grading_schema_cd,
            x_gs_version_number            => suaai_upd_rec.gs_version_number,
            x_grade                        => suaai_upd_rec.grade,
            x_outcome_comment_code         => suaai_upd_rec.outcome_comment_code,
            x_mark                         => suaai_upd_rec.mark,
            x_attribute_category           => suaai_upd_rec.attribute_category,
            x_attribute1                   => suaai_upd_rec.attribute1,
            x_attribute2                   => suaai_upd_rec.attribute2,
            x_attribute3                   => suaai_upd_rec.attribute3,
            x_attribute4                   => suaai_upd_rec.attribute4,
            x_attribute5                   => suaai_upd_rec.attribute5,
            x_attribute6                   => suaai_upd_rec.attribute6,
            x_attribute7                   => suaai_upd_rec.attribute7,
            x_attribute8                   => suaai_upd_rec.attribute8,
            x_attribute9                   => suaai_upd_rec.attribute9,
            x_attribute10                  => suaai_upd_rec.attribute10,
            x_attribute11                  => suaai_upd_rec.attribute11,
            x_attribute12                  => suaai_upd_rec.attribute12,
            x_attribute13                  => suaai_upd_rec.attribute13,
            x_attribute14                  => suaai_upd_rec.attribute14,
            x_attribute15                  => suaai_upd_rec.attribute15,
            x_attribute16                  => suaai_upd_rec.attribute16,
            x_attribute17                  => suaai_upd_rec.attribute17,
            x_attribute18                  => suaai_upd_rec.attribute18,
            x_attribute19                  => suaai_upd_rec.attribute19,
            x_attribute20                  => suaai_upd_rec.attribute20,
            x_uoo_id                       => suaai_upd_rec.uoo_id,
            x_unit_section_ass_item_id     => suaai_upd_rec.unit_section_ass_item_id,
            x_unit_ass_item_id             => suaai_upd_rec.unit_ass_item_id,
            x_sua_ass_item_group_id        => suaai_upd_rec.sua_ass_item_group_id,
            x_midterm_mandatory_type_code  => p_midterm_mandatory_type_code,
            x_midterm_weight_qty           => p_midterm_weight_qty,
            x_final_mandatory_type_code    => p_final_mandatory_type_code,
            x_final_weight_qty             => p_final_weight_qty,
            x_submitted_date               => suaai_upd_rec.submitted_date,
            x_waived_flag                  => suaai_upd_rec.waived_flag,
            x_penalty_applied_flag         => suaai_upd_rec.penalty_applied_flag
          );*/
        ELSIF ((c_suaai_upd%FOUND) AND
               (((p_ass_id_usec_unit_ind = 'UNIT') AND (suaai_upd_rec.unit_ass_item_id IS NOT NULL) AND suaai_upd_rec.unit_ass_item_group_id = p_group_id ) OR
               ((p_ass_id_usec_unit_ind = 'USEC') AND (suaai_upd_rec.unit_section_ass_item_id IS NOT NULL) AND suaai_upd_rec.us_ass_item_group_id = p_group_id)) AND
                (suaai_upd_rec.logical_delete_dt IS NULL)) THEN
          CLOSE c_suaai_upd;
          --
          -- Item already exists; so apply the changed assessment item definition if any
          --
          UPDATE igs_as_su_atmpt_itm suaai
          SET    suaai.last_update_date = SYSDATE,
                 suaai.last_updated_by = fnd_global.user_id,
                 suaai.last_update_login = fnd_global.login_id,
                 suaai.request_id = fnd_global.conc_request_id,
                 suaai.program_id = fnd_global.conc_program_id,
                 suaai.program_application_id = fnd_global.prog_appl_id,
                 suaai.program_update_date = SYSDATE,
                 suaai.midterm_mandatory_type_code = p_midterm_mandatory_type_code,
                 suaai.midterm_weight_qty          = p_midterm_weight_qty,
                 suaai.final_mandatory_type_code   = p_final_mandatory_type_code,
                 suaai.final_weight_qty            = p_final_weight_qty,
                 suaai.grading_schema_cd           = p_grading_schema_cd,
                 suaai.gs_version_number           = p_gs_version_number
          WHERE  suaai.rowid = suaai_upd_rec.ROWID;
/*          igs_as_su_atmpt_itm_pkg.update_row (
            x_mode                         => 'R',
            x_rowid                        => suaai_upd_rec.ROWID,
            x_person_id                    => suaai_upd_rec.person_id,
            x_course_cd                    => suaai_upd_rec.course_cd,
            x_unit_cd                      => suaai_upd_rec.unit_cd,
            x_cal_type                     => suaai_upd_rec.cal_type,
            x_ci_sequence_number           => suaai_upd_rec.ci_sequence_number,
            x_ass_id                       => suaai_upd_rec.ass_id,
            x_creation_dt                  => suaai_upd_rec.creation_dt,
            x_attempt_number               => suaai_upd_rec.attempt_number,
            x_outcome_dt                   => suaai_upd_rec.outcome_dt,
            x_override_due_dt              => suaai_upd_rec.override_due_dt,
            x_tracking_id                  => suaai_upd_rec.tracking_id,
            x_logical_delete_dt            => suaai_upd_rec.logical_delete_dt,
            x_s_default_ind                => suaai_upd_rec.s_default_ind,
            x_ass_pattern_id               => suaai_upd_rec.ass_pattern_id,
            x_grading_schema_cd            => p_grading_schema_cd,
            x_gs_version_number            => p_gs_version_number ,
            x_grade                        => suaai_upd_rec.grade,
            x_outcome_comment_code         => suaai_upd_rec.outcome_comment_code,
            x_mark                         => suaai_upd_rec.mark,
            x_attribute_category           => suaai_upd_rec.attribute_category,
            x_attribute1                   => suaai_upd_rec.attribute1,
            x_attribute2                   => suaai_upd_rec.attribute2,
            x_attribute3                   => suaai_upd_rec.attribute3,
            x_attribute4                   => suaai_upd_rec.attribute4,
            x_attribute5                   => suaai_upd_rec.attribute5,
            x_attribute6                   => suaai_upd_rec.attribute6,
            x_attribute7                   => suaai_upd_rec.attribute7,
            x_attribute8                   => suaai_upd_rec.attribute8,
            x_attribute9                   => suaai_upd_rec.attribute9,
            x_attribute10                  => suaai_upd_rec.attribute10,
            x_attribute11                  => suaai_upd_rec.attribute11,
            x_attribute12                  => suaai_upd_rec.attribute12,
            x_attribute13                  => suaai_upd_rec.attribute13,
            x_attribute14                  => suaai_upd_rec.attribute14,
            x_attribute15                  => suaai_upd_rec.attribute15,
            x_attribute16                  => suaai_upd_rec.attribute16,
            x_attribute17                  => suaai_upd_rec.attribute17,
            x_attribute18                  => suaai_upd_rec.attribute18,
            x_attribute19                  => suaai_upd_rec.attribute19,
            x_attribute20                  => suaai_upd_rec.attribute20,
            x_uoo_id                       => suaai_upd_rec.uoo_id,
            x_unit_section_ass_item_id     => suaai_upd_rec.unit_section_ass_item_id,
            x_unit_ass_item_id             => suaai_upd_rec.unit_ass_item_id,
            x_sua_ass_item_group_id        => suaai_upd_rec.sua_ass_item_group_id,
            x_midterm_mandatory_type_code  => p_midterm_mandatory_type_code,
            x_midterm_weight_qty           => p_midterm_weight_qty,
            x_final_mandatory_type_code    => p_final_mandatory_type_code,
            x_final_weight_qty             => p_final_weight_qty,
            x_submitted_date               => suaai_upd_rec.submitted_date,
            x_waived_flag                  => suaai_upd_rec.waived_flag,
            x_penalty_applied_flag         => suaai_upd_rec.penalty_applied_flag
          );*/
        ELSE
          CLOSE c_suaai_upd;
          l_rowid8 := NULL;
          --
          -- Create the Assessment Item under the Student Unit Attempt
          -- Assessment Item Group
          --
            IF( p_ass_id_usec_unit_ind = 'USEC' ) THEN
              l_unit_assessment_id  := NULL;
              l_us_assessment_id    := p_ass_item_id;
             ELSE
              l_unit_assessment_id  := p_ass_item_id;
              l_us_assessment_id    := NULL;
             END IF;
          OPEN c_suaai_an (p_uoo_id);
          FETCH c_suaai_an INTO v_attempt_number;
          CLOSE c_suaai_an;
          igs_as_su_atmpt_itm_pkg.insert_row (
            x_mode                         => 'R',
            x_rowid                        => l_rowid8,
            x_person_id                    => p_person_id,
            x_course_cd                    => p_course_cd,
            x_unit_cd                      => p_unit_cd,
            x_cal_type                     => p_cal_type,
            x_ci_sequence_number           => p_ci_sequence_number,
            x_ass_id                       => p_ass_id,
            x_creation_dt                  => v_creation_dt,
            x_attempt_number               => v_attempt_number,
            x_outcome_dt                   => NULL,
            x_override_due_dt              => NULL,
            x_tracking_id                  => NULL,
            x_logical_delete_dt            => NULL,
            x_s_default_ind                => cst_yes,
            x_ass_pattern_id               => NULL,
            x_grading_schema_cd            => p_grading_schema_cd,
            x_gs_version_number            => p_gs_version_number,
            x_grade                        => NULL,
            x_outcome_comment_code         => NULL,
            x_mark                         => NULL,
            x_attribute_category           => NULL,
            x_attribute1                   => NULL,
            x_attribute2                   => NULL,
            x_attribute3                   => NULL,
            x_attribute4                   => NULL,
            x_attribute5                   => NULL,
            x_attribute6                   => NULL,
            x_attribute7                   => NULL,
            x_attribute8                   => NULL,
            x_attribute9                   => NULL,
            x_attribute10                  => NULL,
            x_attribute11                  => NULL,
            x_attribute12                  => NULL,
            x_attribute13                  => NULL,
            x_attribute14                  => NULL,
            x_attribute15                  => NULL,
            x_attribute16                  => NULL,
            x_attribute17                  => NULL,
            x_attribute18                  => NULL,
            x_attribute19                  => NULL,
            x_attribute20                  => NULL,
            x_uoo_id                       => p_uoo_id,
            x_unit_section_ass_item_id     => l_us_assessment_id,
            x_unit_ass_item_id             => l_unit_assessment_id,
            x_sua_ass_item_group_id        => l_return_pk_id,
            x_midterm_mandatory_type_code  => p_midterm_mandatory_type_code,
            x_midterm_weight_qty           => p_midterm_weight_qty,
            x_final_mandatory_type_code    => p_final_mandatory_type_code,
            x_final_weight_qty             => p_final_weight_qty,
            x_submitted_date               => NULL,
            x_waived_flag                  => 'N',
            x_penalty_applied_flag         => 'N'
          );
        END IF;
      END;
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_sua_status%ISOPEN THEN
          CLOSE c_sua_status;
        END IF;
        IF c_suaai_deleted%ISOPEN THEN
          CLOSE c_suaai_deleted;
        END IF;
        IF c_crv%ISOPEN THEN
          CLOSE c_crv;
        END IF;
        IF c_suaai_an%ISOPEN THEN
          CLOSE c_suaai_an;
        END IF;
        IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string (
            fnd_log.level_exception, 'igs_as_gen_004.assp_ins_suaai_dflt.exception_while_insert_update',
            'SQLERRM:' || SQLERRM
          );
        END IF;
        RETURN FALSE;
    END;

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string (
          fnd_log.level_exception, 'igs_as_gen_004.assp_ins_suaai_dflt.final_exception_while_insert_update',
          'SQLERRM:' || SQLERRM
        );
      END IF;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_004.assp_ins_suaai_dflt');
      igs_ge_msg_stack.ADD;
      RETURN FALSE;
  END assp_ins_suaai_dflt;
  --
  -- This function is obsolete as the Grade Book Enhancement obsoleted the
  -- Assessment Patterns functionality
  --
  FUNCTION assp_ins_suaap_dflt (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_ass_pattern_id               IN     NUMBER,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
  BEGIN
    RETURN FALSE;
  END assp_ins_suaap_dflt;
  --
  -- This function is obsolete as the Grade Book Enhancement obsoleted the
  -- Assessment Patterns functionality
  --
  FUNCTION assp_ins_suaap_suaai (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_creation_dt                  IN     DATE,
    p_s_default_ind                IN     VARCHAR2 DEFAULT 'N',
    p_call_from_db_trg             IN     VARCHAR2 DEFAULT 'N',
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_uoo_id                       IN     NUMBER
  ) RETURN BOOLEAN IS
  BEGIN
    RETURN FALSE;
  END assp_ins_suaap_suaai;
  --
  --
  --
  FUNCTION assp_ins_transcript (
    p_course_org_unit_cd           IN     VARCHAR2,
    p_course_group_cd              IN     VARCHAR2,
    p_course_cd                    IN     VARCHAR2,
    p_course_location_cd           IN     VARCHAR2,
    p_course_attendance_mode       IN     VARCHAR2,
    p_course_award                 IN     VARCHAR2 DEFAULT 'BOTH',
    p_course_attempt_status        IN     VARCHAR2,
    p_progression_status           IN     VARCHAR2,
    p_graduand_status              IN     VARCHAR2,
    p_person_id_group              IN     NUMBER,
    p_person_id                    IN     NUMBER,
    p_transcript_type              IN     VARCHAR2,
    p_include_fail_grades_ind      IN     VARCHAR2 DEFAULT 'N',
    p_enrolled_units_ind           IN     VARCHAR2 DEFAULT 'C',
    p_exclude_research_units_ind   IN     VARCHAR2 DEFAULT 'N',
    p_exclude_unit_category        IN     VARCHAR2,
    p_extract_course_cd            IN     VARCHAR2,
    p_include_related_crs_ind      IN     VARCHAR2 DEFAULT 'N',
    p_order_by                     IN     VARCHAR2 DEFAULT 'YEAR',
    p_external_order_by            IN     VARCHAR2 DEFAULT 'SURNAME',
    p_correspondence_ind           IN     VARCHAR2 DEFAULT 'N',
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_reference_number             OUT NOCOPY NUMBER
  ) RETURN BOOLEAN IS
  BEGIN
    --
    -- As per 2239087, this concurrent program is obsolete and if the user
    -- tries to run this program then an error message should be logged into the log
    -- file that the concurrent program is obsolete and should not be run.
    --
    fnd_message.set_name ('IGS', 'IGS_GE_OBSOLETE_JOB');
    fnd_file.put_line (fnd_file.LOG, fnd_message.get);
    --
  EXCEPTION
    WHEN OTHERS THEN
      igs_ge_msg_stack.conc_exception_hndl;
  END assp_ins_transcript;
  --
  -- This function is obsolete as the Grade Book Enhancement obsoleted the
  -- Assessment Patterns functionality
  --
  FUNCTION assp_get_uapi_ap (
    p_ass_pattern_id               IN NUMBER,
    p_ass_id                       IN NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END assp_get_uapi_ap;
END igs_as_gen_004;

/
