--------------------------------------------------------
--  DDL for Package Body IGS_PR_UPLOAD_EXT_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_UPLOAD_EXT_RESULTS" AS
/* $Header: IGSPR38B.pls 120.1 2006/01/18 23:08:29 swaghmar noship $ */
/****************************************************************************************************************
  ||  Created By : nmankodi
  ||  Created On : 07-NOV-2002
  ||  Purpose : This Job validates and uploads the Interface data for External Stats and Degree Completion
  ||  This process can be called from the concurrent manager .
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who     When        What
  ||  (reverse chronological order - newest change first)
  ||  smanglm 18-AUG-2003 Bug: 3102152 - Timeframe check for BOTH , CUMULATIVE and PERIOD
  ||  kdande  10-Sep-2003 Bug: 3076139 - Enhanced the error logging behavior
  ||    for the Degree Comnpletion Import.
****************************************************************************************************************/

  FUNCTION validate_record (
    p_stu_acad_stat_int_rec      IN       igs_pr_stu_acad_stat_int%ROWTYPE,
    p_error_code                 OUT NOCOPY igs_pr_stu_acad_stat_int.error_code%TYPE,
    p_person_id                  OUT NOCOPY hz_parties.party_id%TYPE,
    p_cal_type                   OUT NOCOPY igs_ca_inst.cal_type%TYPE,
    p_ci_sequence_number         OUT NOCOPY igs_ca_inst.sequence_number%TYPE
  )
    RETURN BOOLEAN IS
  -- This cursor fetches the interface table records

    CURSOR cur_hz_parties (
      cp_person_number                      igs_pr_stu_acad_stat_int.person_number%TYPE
    ) IS
      SELECT hz.party_id
      FROM   hz_parties hz
      WHERE  hz.party_number = cp_person_number;

    CURSOR cur_spa_exists (
      cp_person_id                          igs_en_stdnt_ps_att.person_id%TYPE,
      cp_course_cd                          igs_en_stdnt_ps_att.course_cd%TYPE
    ) IS
      SELECT 'X'
      FROM   igs_en_stdnt_ps_att spa
      WHERE  spa.person_id = cp_person_id
      AND    spa.course_cd = cp_course_cd;

    CURSOR cur_ci_exists (
      cp_alternate_code                     igs_ca_inst.alternate_code%TYPE
    ) IS
      SELECT ci.cal_type,
             ci.sequence_number
      FROM   igs_ca_inst ci,
             igs_ca_type ct
      WHERE  ci.alternate_code = cp_alternate_code
      AND    ci.cal_type = ct.cal_type
      AND    ct.s_cal_cat = 'LOAD';

    CURSOR cur_org_stat_type (
      cp_person_id                          igs_en_stdnt_ps_att.person_id%TYPE,
      cp_course_cd                          igs_en_stdnt_ps_att.course_cd%TYPE,
      cp_stat_type                          igs_pr_stat_type.stat_type%TYPE
    ) IS
      SELECT ost.timeframe,
             stty.closed_ind,
             stty.derivation
      FROM   igs_en_stdnt_ps_att spa,
             igs_ps_ver pv,
             igs_pr_org_stat ost,
             igs_pr_stat_type stty
      WHERE  spa.person_id = cp_person_id
      AND    spa.course_cd = cp_course_cd
      AND    spa.course_cd = pv.course_cd
      AND    spa.version_number = pv.version_number
      AND    ost.org_unit_cd = pv.responsible_org_unit_cd
      AND    ost.stat_type = cp_stat_type
      AND    ost.stat_type = stty.stat_type;

    CURSOR cur_inst_stat_type (
      cp_stat_type                          igs_pr_stat_type.stat_type%TYPE
    ) IS
      SELECT ist.timeframe,
             stty.closed_ind,
             stty.derivation
      FROM   igs_pr_inst_stat ist,
             igs_pr_stat_type stty
      WHERE  ist.stat_type = cp_stat_type
      AND    ist.stat_type = stty.stat_type;

    CURSOR cur_stat_ele (
      cp_stat_type                          igs_pr_stat_type.stat_type%TYPE,
      cp_s_stat_element                     igs_pr_sta_type_ele.s_stat_element%TYPE
    ) IS
      SELECT 'X'
      FROM   igs_pr_sta_type_ele stte
      WHERE  stte.stat_type = cp_stat_type
      AND    stte.s_stat_element = cp_s_stat_element;

    hz_parties_rec     cur_hz_parties%ROWTYPE;
    spa_exists_rec     cur_spa_exists%ROWTYPE;
    ci_exists_rec      cur_ci_exists%ROWTYPE;
    org_stat_type_rec  cur_org_stat_type%ROWTYPE;
    inst_stat_type_rec cur_inst_stat_type%ROWTYPE;
    stat_ele_rec       cur_stat_ele%ROWTYPE;
    l_stat_closed_ind  igs_pr_stat_type.closed_ind%TYPE;
    l_stat_derivation  igs_pr_stat_type.derivation%TYPE;
    l_stat_timeframe   igs_pr_org_stat.timeframe%TYPE;
  BEGIN
    IF (igs_ge_gen_004.genp_get_lookup (
          'PR_EXTERNAL_STAT_SOURCE',
          p_stu_acad_stat_int_rec.source_type
        ) IS NULL
       ) THEN
      p_error_code := 'IGS_PR_INVALID_SOURCE';
      RETURN FALSE;
    END IF;

    IF    NVL (p_stu_acad_stat_int_rec.attempted_credit_points, 0) < 0
       OR NVL (p_stu_acad_stat_int_rec.earned_credit_points, 0) < 0
       OR NVL (p_stu_acad_stat_int_rec.gpa, 0) < 0
       OR NVL (p_stu_acad_stat_int_rec.gpa_credit_points, 0) < 0
       OR NVL (p_stu_acad_stat_int_rec.gpa_quality_points, 0) < 0 THEN
      p_error_code := 'IGS_PR_NEGATIVE_STAT_VALUE';
      RETURN FALSE;
    END IF;

    OPEN cur_hz_parties (p_stu_acad_stat_int_rec.person_number);
    FETCH cur_hz_parties INTO hz_parties_rec;

    IF (cur_hz_parties%NOTFOUND) THEN
      p_error_code := 'IGS_PR_PERSON_NOT_FOUND';
      CLOSE cur_hz_parties;
      RETURN FALSE;
    ELSE
      p_person_id := hz_parties_rec.party_id;
      CLOSE cur_hz_parties;
    END IF;

    OPEN cur_spa_exists (
      hz_parties_rec.party_id,
      p_stu_acad_stat_int_rec.course_cd
    );
    FETCH cur_spa_exists INTO spa_exists_rec;

    IF (cur_spa_exists%NOTFOUND) THEN
      p_error_code := 'IGS_PR_SPA_NOT_EXISTS';
      CLOSE cur_spa_exists;
      RETURN FALSE;
    ELSE
      CLOSE cur_spa_exists;
    END IF;

    OPEN cur_ci_exists (p_stu_acad_stat_int_rec.alternate_code);
    FETCH cur_ci_exists INTO ci_exists_rec;

    IF (cur_ci_exists%NOTFOUND) THEN
      p_error_code := 'IGS_PR_CI_NOT_EXISTS';
      CLOSE cur_ci_exists;
      RETURN FALSE;
    ELSE
      p_cal_type := ci_exists_rec.cal_type;
      p_ci_sequence_number := ci_exists_rec.sequence_number;
      CLOSE cur_ci_exists;
    END IF;

    OPEN cur_org_stat_type (
      hz_parties_rec.party_id,
      p_stu_acad_stat_int_rec.course_cd,
      p_stu_acad_stat_int_rec.stat_type
    );
    FETCH cur_org_stat_type INTO org_stat_type_rec;
    OPEN cur_inst_stat_type (p_stu_acad_stat_int_rec.stat_type);
    FETCH cur_inst_stat_type INTO inst_stat_type_rec;

    IF (cur_org_stat_type%FOUND) THEN
      l_stat_closed_ind := org_stat_type_rec.closed_ind;
      l_stat_derivation := org_stat_type_rec.derivation;
      l_stat_timeframe := org_stat_type_rec.timeframe;
      CLOSE cur_org_stat_type;
    ELSIF (cur_inst_stat_type%FOUND) THEN
      l_stat_closed_ind := inst_stat_type_rec.closed_ind;
      l_stat_derivation := inst_stat_type_rec.derivation;
      l_stat_timeframe := inst_stat_type_rec.timeframe;
      CLOSE cur_org_stat_type;
      CLOSE cur_inst_stat_type;
    ELSE
      p_error_code := 'IGS_PR_STAT_NOT_DEF';
      CLOSE cur_org_stat_type;
      CLOSE cur_inst_stat_type;
      RETURN FALSE;
    END IF;

    IF l_stat_closed_ind = 'Y' THEN
      p_error_code := 'IGS_PR_STAT_CLOSED';
      RETURN FALSE;
    END IF;

    IF l_stat_derivation = 'CALCULATED' THEN
      p_error_code := 'IGS_PR_DERIV_CALC';
      RETURN FALSE;
    END IF;

    -- code fix for bug 3102152 starts
    IF UPPER (l_stat_timeframe) <> UPPER (p_stu_acad_stat_int_rec.timeframe) THEN
      IF      UPPER (l_stat_timeframe) = 'BOTH'
          AND (   UPPER (p_stu_acad_stat_int_rec.timeframe) = 'CUMULATIVE'
               OR UPPER (p_stu_acad_stat_int_rec.timeframe) = 'PERIOD'
              ) THEN
        NULL;
      ELSE
        p_error_code := 'IGS_PR_TIMEFRAME_INC';
        RETURN FALSE;
      END IF;
    END IF;

    -- code fix for bug 3102152 ends
    OPEN cur_stat_ele (p_stu_acad_stat_int_rec.stat_type, 'CP_ATTEMPTED');
    FETCH cur_stat_ele INTO stat_ele_rec;

    IF (p_stu_acad_stat_int_rec.attempted_credit_points IS NULL
        AND cur_stat_ele%FOUND
       ) THEN
      p_error_code := 'IGS_PR_ELE_CP_ATTEMPT_NULL';
      CLOSE cur_stat_ele;
      RETURN FALSE;
    ELSIF (p_stu_acad_stat_int_rec.attempted_credit_points IS NOT NULL
           AND cur_stat_ele%NOTFOUND
          ) THEN
      p_error_code := 'IGS_PR_ELE_CP_ATTEMPT_INCL';
      CLOSE cur_stat_ele;
      RETURN FALSE;
    ELSE
      CLOSE cur_stat_ele;
    END IF;

    OPEN cur_stat_ele (p_stu_acad_stat_int_rec.stat_type, 'CP_EARNED');
    FETCH cur_stat_ele INTO stat_ele_rec;

    IF (p_stu_acad_stat_int_rec.earned_credit_points IS NULL
        AND cur_stat_ele%FOUND
       ) THEN
      p_error_code := 'IGS_PR_ELE_CP_EARN_NULL';
      CLOSE cur_stat_ele;
      RETURN FALSE;
    ELSIF (    p_stu_acad_stat_int_rec.earned_credit_points IS NOT NULL
           AND cur_stat_ele%NOTFOUND
          ) THEN
      p_error_code := 'IGS_PR_ELE_CP_EARN_INCL';
      CLOSE cur_stat_ele;
      RETURN FALSE;
    ELSE
      CLOSE cur_stat_ele;
    END IF;

    OPEN cur_stat_ele (p_stu_acad_stat_int_rec.stat_type, 'GPA');
    FETCH cur_stat_ele INTO stat_ele_rec;

    IF (p_stu_acad_stat_int_rec.gpa IS NULL
        AND cur_stat_ele%FOUND
       ) THEN
      p_error_code := 'IGS_PR_ELE_GPA_NULL';
      CLOSE cur_stat_ele;
      RETURN FALSE;
    ELSIF (p_stu_acad_stat_int_rec.gpa IS NOT NULL
           AND cur_stat_ele%NOTFOUND
          ) THEN
      p_error_code := 'IGS_PR_ELE_GPA_INCL';
      CLOSE cur_stat_ele;
      RETURN FALSE;
    ELSE
      CLOSE cur_stat_ele;
    END IF;

    OPEN cur_stat_ele (p_stu_acad_stat_int_rec.stat_type, 'GPA CP');
    FETCH cur_stat_ele INTO stat_ele_rec;

    IF (p_stu_acad_stat_int_rec.gpa_credit_points IS NULL
        AND cur_stat_ele%FOUND
       ) THEN
      p_error_code := 'IGS_PR_ELE_GPA_CP_NULL';
      CLOSE cur_stat_ele;
      RETURN FALSE;
    ELSIF (p_stu_acad_stat_int_rec.gpa_credit_points IS NOT NULL
           AND cur_stat_ele%NOTFOUND
          ) THEN
      p_error_code := 'IGS_PR_ELE_GPA_CP_INCL';
      CLOSE cur_stat_ele;
      RETURN FALSE;
    ELSE
      CLOSE cur_stat_ele;
    END IF;

    OPEN cur_stat_ele (p_stu_acad_stat_int_rec.stat_type, 'GPA QP');
    FETCH cur_stat_ele INTO stat_ele_rec;

    IF (p_stu_acad_stat_int_rec.gpa_quality_points IS NULL
        AND cur_stat_ele%FOUND
       ) THEN
      p_error_code := 'IGS_PR_ELE_GPA_QP_NULL';
      CLOSE cur_stat_ele;
      RETURN FALSE;
    ELSIF (p_stu_acad_stat_int_rec.gpa_quality_points IS NOT NULL
           AND cur_stat_ele%NOTFOUND
          ) THEN
      p_error_code := 'IGS_PR_ELE_GPA_QP_INCL';
      CLOSE cur_stat_ele;
      RETURN FALSE;
    ELSE
      CLOSE cur_stat_ele;
    END IF;

    RETURN TRUE;
  END validate_record;

  PROCEDURE upload_external_stats (
    errbuf                       OUT NOCOPY VARCHAR2, -- Standard Error Buffer Variable
    retcode                      OUT NOCOPY NUMBER, -- Standard Concurrent Return code
    p_batch_id                   IN       NUMBER -- The batch id which needs to be uploaded
  ) IS

/****************************************************************************************************************
  ||  Created By : nmankodi
  ||  Created On : 04-NOV-2002
  ||  Purpose : This Job validates and uploads and then purges the Interface data for External Stats and Degree
Completion
  ||  This process can be called from the concurrent manager .
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||swaghmar    16-Jan-2006    Bug# 4951054  Added check for disabling UI's
****************************************************************************************************************/

    CURSOR cur_stu_acad_stat_int (
      cp_batch_id                           igs_pr_stu_acad_stat_int.batch_id%TYPE
    ) IS
      SELECT     sasi.*
      FROM       igs_pr_stu_acad_stat_int sasi
      WHERE      sasi.batch_id = cp_batch_id
      FOR UPDATE;

    stu_acad_stat_int_rec         cur_stu_acad_stat_int%ROWTYPE;
    l_rowid                       VARCHAR2 (4000)                    DEFAULT NULL;
    l_valid_record                BOOLEAN                           DEFAULT FALSE;
    l_error_code                  igs_pr_stu_acad_stat_int.error_code%TYPE;
    l_person_id                   hz_parties.party_id%TYPE;
    l_cal_type                    igs_ca_inst.cal_type%TYPE;
    l_ci_sequence_number          igs_ca_inst.sequence_number%TYPE;
    invalid_parameter_combination EXCEPTION;
  BEGIN
    retcode := 0;
    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054

-- Fetching the records from the Interface Table and validating the data
    IF (p_batch_id IS NOT NULL) THEN
      FOR stu_acad_stat_int_rec IN cur_stu_acad_stat_int (p_batch_id) LOOP
        l_valid_record := validate_record (
                            stu_acad_stat_int_rec,
                            l_error_code,
                            l_person_id,
                            l_cal_type,
                            l_ci_sequence_number
                          );

        IF l_valid_record THEN
          igs_pr_stu_acad_stat_pkg.add_row (
            x_rowid                       => l_rowid,
            x_person_id                   => l_person_id,
            x_course_cd                   => stu_acad_stat_int_rec.course_cd,
            x_cal_type                    => l_cal_type,
            x_ci_sequence_number          => l_ci_sequence_number,
            x_stat_type                   => stu_acad_stat_int_rec.stat_type,
            x_timeframe                   => UPPER (stu_acad_stat_int_rec.timeframe),
            x_source_type                 => stu_acad_stat_int_rec.source_type,
            x_source_reference            => stu_acad_stat_int_rec.source_reference,
            x_attempted_credit_points     => stu_acad_stat_int_rec.attempted_credit_points,
            x_earned_credit_points        => stu_acad_stat_int_rec.earned_credit_points,
            x_gpa                         => stu_acad_stat_int_rec.gpa,
            x_gpa_credit_points           => stu_acad_stat_int_rec.gpa_credit_points,
            x_gpa_quality_points          => stu_acad_stat_int_rec.gpa_quality_points,
            x_mode                        => 'R'
          );

          IF l_rowid IS NOT NULL THEN
            DELETE FROM igs_pr_stu_acad_stat_int
            WHERE  CURRENT OF cur_stu_acad_stat_int;
          END IF;
        ELSE
          UPDATE igs_pr_stu_acad_stat_int
          SET    error_code = l_error_code
          WHERE  CURRENT OF cur_stu_acad_stat_int;
        END IF;
      END LOOP;
    ELSIF (p_batch_id IS NULL) THEN

-- When the batch_id is passed as null there is no batch to process.
      RAISE invalid_parameter_combination;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN invalid_parameter_combination THEN
      fnd_file.put_line (fnd_file.LOG, 'SQL Error Message :' || SQLERRM);
      fnd_file.put_line (fnd_file.LOG, fnd_message.get);
      retcode := 2;
      errbuf := fnd_message.get_string ('IGS', 'IGS_PR_RNK_INV_PRM');
      igs_ge_msg_stack.conc_exception_hndl;
    WHEN OTHERS THEN
      fnd_file.put_line (fnd_file.LOG, 'SQL Error Message :' || SQLERRM);
      fnd_file.put_line (fnd_file.LOG, fnd_message.get);
      retcode := 2;
      errbuf := fnd_message.get_string ('IGS', 'IGS_GE_UNHANDLED_EXP');
      igs_ge_msg_stack.conc_exception_hndl;
  END upload_external_stats;


-- =========================================================================================

  FUNCTION validate_spa_record (
    p_person_number              IN       igs_pr_spa_complete_int.person_number%TYPE,
    p_course_cd                  IN       igs_pr_spa_complete_int.course_cd%TYPE,
    p_error_code                 OUT NOCOPY igs_pr_spa_complete_int.error_code%TYPE,
    p_person_id                  OUT NOCOPY hz_parties.party_id%TYPE,
    p_rowid                      OUT NOCOPY ROWID
  )
    RETURN BOOLEAN IS

/****************************************************************************************************************
  ||  Created By : dlarsen
  ||  Created On : 16-DEC-2002
  ||  Purpose : This validate the Person Number and that Student Program Attempt record exists and
  ||            is not already completed or ended.
  ||
  ||  This process can be called from upload_external_completion.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/

    CURSOR c_parties (
      cp_person_number                      igs_pr_spa_complete_int.person_number%TYPE
    ) IS
      SELECT hz.party_id
      FROM   hz_parties hz
      WHERE  hz.party_number = cp_person_number;

    CURSOR c_spa (
      cp_person_id                          igs_en_stdnt_ps_att.person_id%TYPE,
      cp_course_cd                          igs_en_stdnt_ps_att.course_cd%TYPE
    ) IS
      SELECT spa.ROWID,
             spa.course_attempt_status
      FROM   igs_en_stdnt_ps_att spa
      WHERE  spa.person_id = cp_person_id
      AND    spa.course_cd = cp_course_cd;

    l_person_id             hz_parties.party_id%TYPE;
    l_rowid                 ROWID;
    l_course_attempt_status igs_en_stdnt_ps_att.course_attempt_status%TYPE;
  BEGIN
    p_error_code := NULL;
    -- Check the Person Number relates to a valid Person/Party ID
    OPEN c_parties (p_person_number);
    FETCH c_parties INTO l_person_id;

    IF (c_parties%NOTFOUND) THEN
      p_error_code := 'IGS_PR_PERSON_NOT_FOUND';
      CLOSE c_parties;
      RETURN FALSE;
    ELSE
      p_person_id := l_person_id;
      CLOSE c_parties;
    END IF;

    -- Check if the Student Program Attempt exists and is of the correct Course Attempt Status
    OPEN c_spa (l_person_id, p_course_cd);
    FETCH c_spa INTO l_rowid,
                     l_course_attempt_status;

    IF (c_spa%NOTFOUND) THEN
      p_error_code := 'IGS_PR_SPA_NOT_EXISTS';
      CLOSE c_spa;
      RETURN FALSE;
    ELSE
      CLOSE c_spa;

      -- Check if the Student Program Attempt has a valid status
      IF l_course_attempt_status NOT IN ('ENROLLED', 'INACTIVE') THEN
        p_error_code := 'IGS_PR_SPA_STATUS';
        RETURN FALSE;
      END IF;
    END IF;

    -- Return the rowid of the Student Program Attempt record
    p_rowid := l_rowid;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line (fnd_file.LOG, 'SQL Error Message :' || SQLERRM);
      fnd_file.put_line (fnd_file.LOG, fnd_message.get);
      igs_ge_msg_stack.conc_exception_hndl;
  END validate_spa_record;


-- =========================================================================================

  FUNCTION validate_susa_record (
    p_person_id                  IN       hz_parties.party_id%TYPE,
    p_course_cd                  IN       igs_pr_susa_complete_int.course_cd%TYPE,
    p_unit_set_cd                IN       igs_pr_susa_complete_int.unit_set_cd%TYPE,
    p_error_code                 OUT NOCOPY igs_pr_susa_complete_int.error_code%TYPE,
    p_rowid                      OUT NOCOPY ROWID
  )
    RETURN BOOLEAN IS

/****************************************************************************************************************
  ||  Created By : dlarsen
  ||  Created On : 16-DEC-2002
  ||  Purpose : This validate the Student Unit Set Attempt record exists and is not already completed or ended.
  ||
  ||  This process can be called from upload_external_completion.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/

    CURSOR c_susa (
      cp_person_id                          igs_as_su_setatmpt.person_id%TYPE,
      cp_course_cd                          igs_as_su_setatmpt.course_cd%TYPE,
      cp_unit_set_cd                        igs_as_su_setatmpt.unit_set_cd%TYPE
    ) IS
      SELECT susa.ROWID,
             susa.end_dt,
             susa.rqrmnts_complete_ind
      FROM   igs_as_su_setatmpt susa
      WHERE  susa.person_id = cp_person_id
      AND    susa.course_cd = cp_course_cd
      AND    susa.unit_set_cd = cp_unit_set_cd;

    l_rowid                ROWID;
    l_end_dt               igs_as_su_setatmpt.end_dt%TYPE;
    l_rqrmnts_complete_ind igs_as_su_setatmpt.rqrmnts_complete_ind%TYPE;
  BEGIN
    p_error_code := NULL;
    -- Check if the Student Unit Set Attempt exists and is not ended or completed
    OPEN c_susa (p_person_id, p_course_cd, p_unit_set_cd);
    FETCH c_susa INTO l_rowid,
                      l_end_dt,
                      l_rqrmnts_complete_ind;

    IF (c_susa%NOTFOUND) THEN
      p_error_code := 'IGS_PR_SUSA_NOT_EXISTS';
      CLOSE c_susa;
      RETURN FALSE;
    ELSE
      CLOSE c_susa;

      -- Check if the Student Unit Set Attempt is already completed
      IF l_rqrmnts_complete_ind = 'Y' THEN
        p_error_code := 'IGS_PR_SUSA_COMPLETE';
        RETURN FALSE;
      END IF;

      -- Check if the Student Unit Set Attempt is already ended
      IF l_end_dt IS NOT NULL THEN
        p_error_code := 'IGS_PR_SUSA_ENDED';
        RETURN FALSE;
      END IF;
    END IF;

    -- Return the rowid of the Student Unit Set Attempt record
    p_rowid := l_rowid;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line (fnd_file.LOG, 'SQL Error Message :' || SQLERRM);
      fnd_file.put_line (fnd_file.LOG, fnd_message.get);
      igs_ge_msg_stack.conc_exception_hndl;
  END validate_susa_record;


-- =========================================================================================

  PROCEDURE update_susa (
    errbuf                       OUT NOCOPY VARCHAR2,
    retcode                      OUT NOCOPY NUMBER,
    p_rowid                      IN       ROWID,
    p_end_dt                     IN       igs_as_su_setatmpt.end_dt%TYPE,
    p_voluntary_end_ind          IN       igs_as_su_setatmpt.voluntary_end_ind%TYPE,
    p_rqrmnts_complete_ind       IN       igs_as_su_setatmpt.rqrmnts_complete_ind%TYPE,
    p_rqrmnts_complete_dt        IN       igs_as_su_setatmpt.rqrmnts_complete_dt%TYPE,
    p_s_completed_source_type    IN       igs_as_su_setatmpt.s_completed_source_type%TYPE
  ) IS

/****************************************************************************************************************
  ||  Created By : dlarsen
  ||  Created On : 16-DEC-2002
  ||  Purpose : This updates the Student Unit Set Attempt record with the completion or ending details.
  ||
  ||  This process can be called from upload_external_completion.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/

    CURSOR c_susa (
      cp_rowid                              ROWID
    ) IS
      SELECT     susa.*
      FROM       igs_as_su_setatmpt susa
      WHERE      susa.ROWID = cp_rowid
      FOR UPDATE NOWAIT;
  BEGIN
    retcode := 0;

    FOR v_susa_rec IN c_susa (p_rowid) LOOP
      igs_as_su_setatmpt_pkg.update_row (
        x_mode                        => 'R',
        x_rowid                       => p_rowid,
        x_person_id                   => v_susa_rec.person_id,
        x_course_cd                   => v_susa_rec.course_cd,
        x_unit_set_cd                 => v_susa_rec.unit_set_cd,
        x_us_version_number           => v_susa_rec.us_version_number,
        x_sequence_number             => v_susa_rec.sequence_number,
        x_selection_dt                => v_susa_rec.selection_dt,
        x_student_confirmed_ind       => v_susa_rec.student_confirmed_ind,
        x_end_dt                      => p_end_dt,
        x_parent_unit_set_cd          => v_susa_rec.parent_unit_set_cd,
        x_parent_sequence_number      => v_susa_rec.parent_sequence_number,
        x_primary_set_ind             => v_susa_rec.primary_set_ind,
        x_voluntary_end_ind           => p_voluntary_end_ind,
        x_authorised_person_id        => v_susa_rec.authorised_person_id,
        x_authorised_on               => v_susa_rec.authorised_on,
        x_override_title              => v_susa_rec.override_title,
        x_rqrmnts_complete_ind        => p_rqrmnts_complete_ind,
        x_rqrmnts_complete_dt         => p_rqrmnts_complete_dt,
        x_s_completed_source_type     => p_s_completed_source_type,
        x_catalog_cal_type            => v_susa_rec.catalog_cal_type,
        x_catalog_seq_num             => v_susa_rec.catalog_seq_num,
        x_attribute_category          => v_susa_rec.attribute_category,
        x_attribute1                  => v_susa_rec.attribute1,
        x_attribute2                  => v_susa_rec.attribute2,
        x_attribute3                  => v_susa_rec.attribute3,
        x_attribute4                  => v_susa_rec.attribute4,
        x_attribute5                  => v_susa_rec.attribute5,
        x_attribute6                  => v_susa_rec.attribute6,
        x_attribute7                  => v_susa_rec.attribute7,
        x_attribute8                  => v_susa_rec.attribute8,
        x_attribute9                  => v_susa_rec.attribute9,
        x_attribute10                 => v_susa_rec.attribute10,
        x_attribute11                 => v_susa_rec.attribute11,
        x_attribute12                 => v_susa_rec.attribute12,
        x_attribute13                 => v_susa_rec.attribute13,
        x_attribute14                 => v_susa_rec.attribute14,
        x_attribute15                 => v_susa_rec.attribute15,
        x_attribute16                 => v_susa_rec.attribute16,
        x_attribute17                 => v_susa_rec.attribute17,
        x_attribute18                 => v_susa_rec.attribute18,
        x_attribute19                 => v_susa_rec.attribute19,
        x_attribute20                 => v_susa_rec.attribute20
      );
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        app_short_name VARCHAR2 (10);
        message_name   VARCHAR2 (100);
      BEGIN
        fnd_file.put_line (fnd_file.LOG, 'SQL Error Message :' || SQLERRM);
        fnd_message.parse_encoded (
          fnd_message.get_encoded,
          app_short_name,
          message_name
        );
        retcode := 2;
        errbuf := message_name;
      END;
  END update_susa;


-- =========================================================================================

  PROCEDURE update_spa (
    errbuf                       OUT NOCOPY VARCHAR2,
    retcode                      OUT NOCOPY NUMBER,
    p_rowid                      IN       ROWID,
    p_course_rqrmnts_complete_dt IN       igs_en_stdnt_ps_att.course_rqrmnts_complete_dt%TYPE
  ) IS

/****************************************************************************************************************
  ||  Created By : dlarsen
  ||  Created On : 16-DEC-2002
  ||  Purpose : This updates the Student Program Attempt record with the completion details.
  ||
  ||  This process can be called from upload_external_completion.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  sarakshi    16-Nov-2004     Enh#4000939, added column FUTURE_DATED_TRANS_FLAG  in the update row call of IGS_EN_STDNT_PS_ATT_PKG
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/

    CURSOR c_spa (
      cp_rowid                              ROWID
    ) IS
      SELECT     spa.*
      FROM       igs_en_stdnt_ps_att spa
      WHERE      spa.ROWID = cp_rowid
      FOR UPDATE NOWAIT;
  BEGIN
    retcode := 0;

    FOR v_spa_rec IN c_spa (p_rowid) LOOP
      igs_en_stdnt_ps_att_pkg.update_row (
        x_mode                        => 'R',
        x_rowid                       => p_rowid,
        x_person_id                   => v_spa_rec.person_id,
        x_course_cd                   => v_spa_rec.course_cd,
        x_version_number              => v_spa_rec.version_number,
        x_cal_type                    => v_spa_rec.cal_type,
        x_location_cd                 => v_spa_rec.location_cd,
        x_attendance_mode             => v_spa_rec.attendance_mode,
        x_attendance_type             => v_spa_rec.attendance_type,
        x_coo_id                      => v_spa_rec.coo_id,
        x_student_confirmed_ind       => v_spa_rec.student_confirmed_ind,
        x_commencement_dt             => v_spa_rec.commencement_dt,
        x_course_attempt_status       => v_spa_rec.course_attempt_status,
        x_progression_status          => v_spa_rec.progression_status,
        x_derived_att_type            => v_spa_rec.derived_att_type,
        x_derived_att_mode            => v_spa_rec.derived_att_mode,
        x_provisional_ind             => v_spa_rec.provisional_ind,
        x_discontinued_dt             => v_spa_rec.discontinued_dt,
        x_discontinuation_reason_cd   => v_spa_rec.discontinuation_reason_cd,
        x_lapsed_dt                   => v_spa_rec.lapsed_dt,
        x_funding_source              => v_spa_rec.funding_source,
        x_exam_location_cd            => v_spa_rec.exam_location_cd,
        x_derived_completion_yr       => v_spa_rec.derived_completion_yr,
        x_derived_completion_perd     => v_spa_rec.derived_completion_perd,
        x_nominated_completion_yr     => v_spa_rec.nominated_completion_yr,
        x_nominated_completion_perd   => v_spa_rec.nominated_completion_perd,
        x_rule_check_ind              => v_spa_rec.rule_check_ind,
        x_waive_option_check_ind      => v_spa_rec.waive_option_check_ind,
        x_last_rule_check_dt          => v_spa_rec.last_rule_check_dt,
        x_publish_outcomes_ind        => v_spa_rec.publish_outcomes_ind,
        x_course_rqrmnt_complete_ind  => 'Y',
        x_course_rqrmnts_complete_dt  => p_course_rqrmnts_complete_dt,
        x_s_completed_source_type     => 'SYSTEM',
        x_override_time_limitation    => v_spa_rec.override_time_limitation,
        x_advanced_standing_ind       => v_spa_rec.advanced_standing_ind,
        x_fee_cat                     => v_spa_rec.fee_cat,
        x_correspondence_cat          => v_spa_rec.correspondence_cat,
        x_self_help_group_ind         => v_spa_rec.self_help_group_ind,
        x_logical_delete_dt           => v_spa_rec.logical_delete_dt,
        x_adm_admission_appl_number   => v_spa_rec.adm_admission_appl_number,
        x_adm_nominated_course_cd     => v_spa_rec.adm_nominated_course_cd,
        x_adm_sequence_number         => v_spa_rec.adm_sequence_number,
        x_last_date_of_attendance     => v_spa_rec.last_date_of_attendance,
        x_dropped_by                  => v_spa_rec.dropped_by,
        x_igs_pr_class_std_id         => v_spa_rec.igs_pr_class_std_id,
        x_primary_program_type        => v_spa_rec.primary_program_type,
        x_primary_prog_type_source    => v_spa_rec.primary_prog_type_source,
        x_catalog_cal_type            => v_spa_rec.catalog_cal_type,
        x_catalog_seq_num             => v_spa_rec.catalog_seq_num,
        x_key_program                 => v_spa_rec.key_program,
        x_override_cmpl_dt            => v_spa_rec.override_cmpl_dt,
        x_manual_ovr_cmpl_dt_ind      => v_spa_rec.manual_ovr_cmpl_dt_ind,
        x_attribute_category          => v_spa_rec.attribute_category,
        x_attribute1                  => v_spa_rec.attribute1,
        x_attribute2                  => v_spa_rec.attribute2,
        x_attribute3                  => v_spa_rec.attribute3,
        x_attribute4                  => v_spa_rec.attribute4,
        x_attribute5                  => v_spa_rec.attribute5,
        x_attribute6                  => v_spa_rec.attribute6,
        x_attribute7                  => v_spa_rec.attribute7,
        x_attribute8                  => v_spa_rec.attribute8,
        x_attribute9                  => v_spa_rec.attribute9,
        x_attribute10                 => v_spa_rec.attribute10,
        x_attribute11                 => v_spa_rec.attribute11,
        x_attribute12                 => v_spa_rec.attribute12,
        x_attribute13                 => v_spa_rec.attribute13,
        x_attribute14                 => v_spa_rec.attribute14,
        x_attribute15                 => v_spa_rec.attribute15,
        x_attribute16                 => v_spa_rec.attribute16,
        x_attribute17                 => v_spa_rec.attribute17,
        x_attribute18                 => v_spa_rec.attribute18,
        x_attribute19                 => v_spa_rec.attribute19,
        x_attribute20                 => v_spa_rec.attribute20,
	x_future_dated_trans_flag     => v_spa_rec.future_dated_trans_flag
      );
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      DECLARE
        app_short_name VARCHAR2 (10);
        message_name   VARCHAR2 (100);
      BEGIN
        fnd_file.put_line (fnd_file.LOG, 'SQL Error Message :' || SQLERRM);
        fnd_message.parse_encoded (
          fnd_message.get_encoded,
          app_short_name,
          message_name
        );
        retcode := 2;
        errbuf := message_name;
      END;
  END update_spa;


-- =========================================================================================


  PROCEDURE upload_external_completion (
    errbuf                       OUT NOCOPY VARCHAR2,
    retcode                      OUT NOCOPY NUMBER,
    p_batch_id                   IN       NUMBER,
    p_unit_set_method            IN       VARCHAR2
  ) IS

/****************************************************************************************************************
  ||  Created By : dlarsen
  ||  Created On : 16-DEC-2002
  ||  Purpose : This Job validates, uploads and then purges the Interface data for Student Unit Set Attempt
  ||            and Student Program Attempt Completion
  ||
  ||  This process can be called from the concurrent manager .
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||swaghmar    16-Jan-2006    Bug# 4951054  Added check for disabling UI's
****************************************************************************************************************/

    CURSOR c_susaci (
      cp_batch_id                           igs_pr_susa_complete_int.batch_id%TYPE
    ) IS
      SELECT     susaci.ROWID,
                 susaci.*
      FROM       igs_pr_susa_complete_int susaci
      WHERE      susaci.batch_id = cp_batch_id
      FOR UPDATE;

    CURSOR c_spaci (
      cp_batch_id                           igs_pr_spa_complete_int.batch_id%TYPE
    ) IS
      SELECT     spaci.ROWID,
                 spaci.*
      FROM       igs_pr_spa_complete_int spaci
      WHERE      spaci.batch_id = cp_batch_id
      FOR UPDATE;

    CURSOR c_susa (
      cp_person_id                          igs_as_su_setatmpt.person_id%TYPE,
      cp_course_cd                          igs_as_su_setatmpt.course_cd%TYPE
    ) IS
      SELECT susa.ROWID
      FROM   igs_as_su_setatmpt susa
      WHERE  susa.person_id = cp_person_id
      AND    susa.course_cd = cp_course_cd
      AND    susa.end_dt IS NULL
      AND    susa.rqrmnts_complete_ind = 'N';

    l_susa_rowid                  ROWID;
    l_spa_rowid                   ROWID;
    l_susa_error_code             igs_pr_susa_complete_int.error_code%TYPE;
    l_spa_error_code              igs_pr_spa_complete_int.error_code%TYPE;
    l_person_id                   hz_parties.party_id%TYPE;
    l_errbuf                      VARCHAR2 (1000);
    l_retcode                     NUMBER (1);
    l_message                     VARCHAR2 (2000);
    invalid_parameter_combination EXCEPTION;
  BEGIN
    retcode := 0;
    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054

    -- Validate the paramters
    IF      p_batch_id IS NOT NULL
        AND p_unit_set_method IN ('COMPLETED', 'ENDED') THEN
      -- Loop through Student Unit Set Attempt completion records
      FOR v_susaci_rec IN c_susaci (p_batch_id) LOOP
        -- Validate the Student Program Attempt before validating the Student Unit Set Attempt

        IF validate_spa_record (
             v_susaci_rec.person_number,
             v_susaci_rec.course_cd,
             l_spa_error_code,
             l_person_id,
             l_spa_rowid
           ) THEN
          -- Validate the Student Unit Set Attempt
          IF validate_susa_record (
               l_person_id,
               v_susaci_rec.course_cd,
               v_susaci_rec.unit_set_cd,
               l_susa_error_code,
               l_susa_rowid
             ) THEN
            -- Update the Student Unit Set Attempt record with the completion details
            IF p_unit_set_method = 'COMPLETED' THEN
              -- Update the Student Unit Set Attempt record with the completion details
              update_susa (
                l_errbuf,
                l_retcode,
                l_susa_rowid,
                NULL,
                'N',
                'Y',
                v_susaci_rec.complete_dt,
                'SYSTEM'
              );
            ELSE -- p_unit_set_method = 'ENDED'
              -- Update the Student Unit Set Attempt record with the ended details
              update_susa (
                l_errbuf,
                l_retcode,
                l_susa_rowid,
                v_susaci_rec.complete_dt,
                'Y',
                'N',
                NULL,
                NULL
              );
            END IF;

            IF (l_retcode <> 0) THEN
              UPDATE igs_pr_susa_complete_int
              SET    error_code = l_errbuf
              WHERE  CURRENT OF c_susaci;
            ELSE
              -- If there is no error delete the record from the interface table
              DELETE FROM igs_pr_susa_complete_int
              WHERE  CURRENT OF c_susaci;
            END IF;
          ELSE
            -- Otherwise update the inteface record with the error code
            UPDATE igs_pr_susa_complete_int
            SET    error_code = l_susa_error_code
            WHERE  CURRENT OF c_susaci;
          END IF;
        ELSE
          -- Otherwise update the inteface record with the error code
          UPDATE igs_pr_susa_complete_int
          SET    error_code = l_spa_error_code
          WHERE  CURRENT OF c_susaci;
        END IF;
      END LOOP;

      -- Loop through Student Program Attempt completion records
      FOR v_spaci_rec IN c_spaci (p_batch_id) LOOP
        -- Validate the Student Program Attempt
        IF validate_spa_record (
             v_spaci_rec.person_number,
             v_spaci_rec.course_cd,
             l_spa_error_code,
             l_person_id,
             l_spa_rowid
           ) THEN
          -- Find any Student Unit Set Attempt records which are not complete or ended.
          FOR v_susa_rec IN c_susa (l_person_id, v_spaci_rec.course_cd) LOOP
            IF p_unit_set_method = 'COMPLETED' THEN
              -- Update the Student Unit Set Attempt record with the completion details
              update_susa (
                l_errbuf,
                l_retcode,
                v_susa_rec.ROWID,
                NULL,
                'N',
                'Y',
                v_spaci_rec.complete_dt,
                'SYSTEM'
              );
            ELSE -- p_unit_set_method = 'ENDED'
              -- Update the Student Unit Set Attempt record with the ended details
              update_susa (
                l_errbuf,
                l_retcode,
                v_susa_rec.ROWID,
                v_spaci_rec.complete_dt,
                'Y',
                'N',
                NULL,
                NULL
              );
            END IF;
          END LOOP;

          -- Update the Student Program Attempt record with the completion details
          update_spa (
            l_errbuf,
            l_retcode,
            l_spa_rowid,
            v_spaci_rec.complete_dt
          );

          -- If there is no error delete the record from the interface table
          IF (l_retcode <> 0) THEN
            UPDATE igs_pr_spa_complete_int
            SET    error_code = l_errbuf
            WHERE  CURRENT OF c_spaci;
          ELSE
            DELETE FROM igs_pr_spa_complete_int
            WHERE  CURRENT OF c_spaci;
          END IF;
        ELSE
          -- Otherwise update the inteface record with the error code
          UPDATE igs_pr_spa_complete_int
          SET    error_code = l_spa_error_code
          WHERE  CURRENT OF c_spaci;
        END IF;
      END LOOP;
    ELSE
      -- When the batch_id is passed as null there is no batch to process.
      RAISE invalid_parameter_combination;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN invalid_parameter_combination THEN
      fnd_file.put_line (
        fnd_file.LOG,
	'SQL Error Message :' || SUBSTR (SQLERRM, 1, 200)
      );
      fnd_file.put_line (fnd_file.LOG, fnd_message.get);
      retcode := 2;
      errbuf := fnd_message.get_string ('IGS', 'IGS_PR_RNK_INV_PRM');
      igs_ge_msg_stack.conc_exception_hndl;
    WHEN OTHERS THEN
      fnd_file.put_line (
        fnd_file.LOG,
        'SQL Error Message :' || SUBSTR (SQLERRM, 1, 200)
      );
      fnd_file.put_line (fnd_file.LOG, fnd_message.get);
      retcode := 2;
      errbuf := fnd_message.get_string ('IGS', 'IGS_GE_UNHANDLED_EXP');
      igs_ge_msg_stack.conc_exception_hndl;
  END upload_external_completion;
END igs_pr_upload_ext_results;

/
