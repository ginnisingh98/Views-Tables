--------------------------------------------------------
--  DDL for Package Body IGS_PR_PROUT_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_PROUT_LGCY_PUB" AS
/* $Header: IGSPPR1B.pls 120.1 2006/02/21 02:27:32 ijeddy noship $ */
  --
  -- MODIFICATION HISTORY:
  --  Kalyan Dande 03-Sep-2003 Bug# 3102377: Added a check for NOT NULL for
  --                           Organization Unit validation
  --  Kalyan Dande 02-Jan-2003 Bug# 2732563: Changed the logic to check for the
  --                           decision_dt instead of decision_status.
  --                           Bug# 2732564: Changed the logic to check for the
  --                           decision_dt instead of decision_status.
  --                           Bug# 2732567: Changed the logic to check for the
  --                           progression_outcome_type before deriving the
  --                           Hold Effects and return FALSE when the system
  --                           progression outcome type is not in AWARD, MANUAL,
  --                           NOPENALTY, REPEATYR, ADVANCE and hold effect type
  --                           is not set and changed the logic to set the
  --                           x_return_value to FALSE when the Progression
  --                           Outcome Type is not already defined in the system.
  --                           Bug# 2732568; Removed the call to
  --                           FND_MSG_PUB.Add_Exc_Msg to avoid message repeatition.
  --  Kalyan Dande 24-Dec-2002 Bug# 2717485. Added the following IF condition
  --                           to create the record only if the hold effect
  --                           type is either 'SUS_COURSE' or 'EXC_COURSE'
  --  Kalyan Dande 24-Dec-2002 Bug# 2717616. Changed the OR condition to AND
  --                           for the following IF condition
  --  Kalyan Dande 11-Nov-2002 Created
  --
  g_pkg_name CONSTANT VARCHAR2(30) := 'IGS_PR_PROUT_LGCY_PUB';
  --
  -- Validate the elements in the record that is to be processed and return
  -- FALSE if the validation fails else return TRUE.
  --
  FUNCTION validate_parameters (
    p_lgcy_prout_rec               IN OUT NOCOPY lgcy_prout_rec_type
  ) RETURN BOOLEAN IS
    --
    l_return_value BOOLEAN := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    --
  BEGIN
    --
    -- If the Person Number is not passed then log an error and continue.
    --
    IF (p_lgcy_prout_rec.person_number IS NULL) THEN
      l_return_value := FND_API.TO_BOOLEAN (FND_API.G_FALSE);
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_PER_NUM_NULL');
      FND_MSG_PUB.ADD;
    END IF;
    --
    -- If the Program Code is not passed then log an error and continue.
    --
    IF (p_lgcy_prout_rec.program_cd IS NULL) THEN
      l_return_value := FND_API.TO_BOOLEAN (FND_API.G_FALSE);
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_PRGM_CD_NULL');
      FND_MSG_PUB.ADD;
    END IF;
    --
    -- If the Alternate Code of the Progression Calendar is not passed then
    -- log an error and continue.
    --
    IF (p_lgcy_prout_rec.prg_cal_alternate_code IS NULL) THEN
      l_return_value := FND_API.TO_BOOLEAN (FND_API.G_FALSE);
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PRG_ALT_CODE_NULL');
      FND_MSG_PUB.ADD;
    END IF;
    --
    -- If the Decision Status is not passed then log an error and continue.
    --
    IF (p_lgcy_prout_rec.decision_status IS NULL) THEN
      l_return_value := FND_API.TO_BOOLEAN (FND_API.G_FALSE);
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_PRG_DECI_STAT_NULL');
      FND_MSG_PUB.ADD;
    END IF;
    --
    -- Return the status of the validation.
    -- TRUE if all validations are passed else FALSE.
    --
    RETURN (l_return_value);
    --
  END validate_parameters;
  --
  --
  --
  PROCEDURE derive_pr_stnd_lvl_data (
    p_lgcy_prout_rec               IN OUT NOCOPY lgcy_prout_rec_type,
    p_person_id                    OUT    NOCOPY igs_pe_person.person_id%TYPE,
    p_prg_cal_type                 OUT    NOCOPY igs_ca_inst.cal_type%TYPE,
    p_prg_sequence_number          OUT    NOCOPY igs_ca_inst.sequence_number%TYPE,
    p_outcome_sequence_number      OUT    NOCOPY igs_pr_stdnt_pr_ou_all.sequence_number%TYPE,
    p_hold_effect_type             OUT    NOCOPY igs_fi_enc_dflt_eft.s_encmb_effect_type%TYPE,
    p_org_start_dt                 OUT    NOCOPY igs_pe_hz_parties.ou_start_dt%TYPE,
    x_return_value                 OUT    NOCOPY BOOLEAN
  ) IS
    --
    CURSOR cur_sequence_number IS
      SELECT   sequence_number
      FROM     igs_pr_stdnt_pr_ou_all
      WHERE    person_id = p_person_id
      AND      progression_outcome_type = p_lgcy_prout_rec.progression_outcome_type
      AND      course_cd = p_lgcy_prout_rec.program_cd
      AND      prg_cal_type = p_prg_cal_type
      AND      prg_ci_sequence_number = p_prg_sequence_number;
    --
    CURSOR cur_hold_effect_type IS
      SELECT   s_encmb_effect_type, s_progression_outcome_type
      FROM     igs_fi_enc_dflt_eft dft,
               igs_pr_ou_type ou
      WHERE    dft.encumbrance_type = ou.encumbrance_type
      AND      ou.progression_outcome_type = p_lgcy_prout_rec.progression_outcome_type;
    --
    l_return_status VARCHAR2(10);
    l_start_dt DATE;
    l_end_dt DATE;
    l_hold_effect_type VARCHAR2(10);
    l_s_progression_outcome_type igs_pr_ou_type.s_progression_outcome_type%TYPE;
    --
  BEGIN
    --
    -- Initialise the return value
    --
    x_return_value := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    --
    -- Derive Person ID from Person Number
    --
    p_person_id := igs_ge_gen_003.get_person_id (p_lgcy_prout_rec.person_number);
    --
    -- Error out if the Person is not found in OSS
    --
    IF (p_person_id IS NULL) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
      FND_MSG_PUB.ADD;
      x_return_value := FND_API.TO_BOOLEAN (FND_API.G_FALSE);
      RETURN;
    END IF;
    --
    -- Derive the Progression Calendar Information for the Alternate Code passed
    --
    igs_ge_gen_003.get_calendar_instance (
      p_lgcy_prout_rec.prg_cal_alternate_code,
      NULL,
      p_prg_cal_type,
      p_prg_sequence_number,
      l_start_dt,
      l_end_dt,
      l_return_status
    );
    --
    -- Error out if the Calendar is not defined or defined more than once in OSS
    --
    IF ((p_prg_cal_type IS NULL) OR (p_prg_sequence_number IS NULL)) THEN
      --
      -- Raise an error if no Calendar definition is found in OSS
      --
      IF (l_return_status = 'INVALID') THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_NO_ALT_CODE');
        FND_MSG_PUB.ADD;
      --
      -- Raise an error if more than one Calendar definition is found in OSS
      --
      ELSIF (l_return_status = 'MULTIPLE') THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_MULTI_ALT_CODE');
        FND_MSG_PUB.ADD;
      END IF;
      x_return_value := FND_API.TO_BOOLEAN (FND_API.G_FALSE);
      RETURN;
    END IF;
    --
    -- Derive the Outcome Sequence Number.
    -- Check for the existance of Student Progression Outcome in OSS which
    -- matches with the record in interface table. If the record exists then
    -- assign p_outcome_sequence_number with
    -- igs_pr_stdnt_pr_ou_all.sequence_number else assign the new sequence value
    -- from igs_pr_spo_seq_num_s sequence.
    --
    OPEN cur_sequence_number;
    FETCH cur_sequence_number INTO p_outcome_sequence_number;
    IF (cur_sequence_number%NOTFOUND) THEN
      CLOSE cur_sequence_number;
      SELECT   igs_pr_spo_seq_num_s.NEXTVAL
      INTO     p_outcome_sequence_number
      FROM     dual
      WHERE    ROWNUM = 1;
    ELSE
      CLOSE cur_sequence_number;
    END IF;
    --
    -- Derive the Organization Unit Start Date
    --
    IF (p_lgcy_prout_rec.decision_org_unit_cd IS NOT NULL) THEN
      IF (NOT igs_re_val_rsup.get_org_unit_dtls (
                p_org_unit_cd                  => p_lgcy_prout_rec.decision_org_unit_cd,
                p_start_dt                     => p_org_start_dt
              )) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_NO_ORG_START_DT');
        FND_MSG_PUB.ADD;
        x_return_value := FND_API.TO_BOOLEAN (FND_API.G_FALSE);
      END IF;
    END IF;
    --
    -- Derive the Hold Effect Type if Progression Outcome Type is specified.
    -- kdande; 02-Jan-2003; Bug# 2732567; Changed the logic to check for the
    -- progression_outcome_type before deriving the Hold Effects and return
    -- FALSE when the system progression outcome type is not in AWARD, MANUAL,
    -- NOPENALTY, REPEATYR, ADVANCE and hold effect type is not set.
    --
    IF (p_lgcy_prout_rec.progression_outcome_type IS NOT NULL) THEN
      OPEN cur_hold_effect_type;
      FETCH cur_hold_effect_type INTO l_hold_effect_type, l_s_progression_outcome_type;
      IF (cur_hold_effect_type%NOTFOUND) THEN
        IF (l_s_progression_outcome_type NOT IN ('AWARD', 'MANUAL', 'NOPENALTY', 'REPEATYR', 'ADVANCE')) THEN
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_NO_HOLD_EFCT');
          FND_MSG_PUB.ADD;
          x_return_value := FND_API.TO_BOOLEAN (FND_API.G_FALSE);
        END IF;
      END IF;
      --
      p_hold_effect_type := l_hold_effect_type;
      --
      LOOP
        FETCH cur_hold_effect_type INTO l_hold_effect_type, l_s_progression_outcome_type;
        EXIT WHEN (cur_hold_effect_type%NOTFOUND);
        p_hold_effect_type := p_hold_effect_type || ',' || l_hold_effect_type;
      END LOOP;
      CLOSE cur_hold_effect_type;
    END IF;
    --
  END derive_pr_stnd_lvl_data;
  --
  -- This function performs all the data integrity validations and keeps
  -- adding error message to stack as an when a validation fails.
  --
  FUNCTION validate_spo_db_cons (
    p_lgcy_prout_rec               IN     lgcy_prout_rec_type,
    p_person_id                    IN     igs_pe_person.person_id%TYPE,
    p_sequence_number              IN     igs_pr_stdnt_pr_ou.sequence_number%TYPE,
    p_org_start_dt                 IN     igs_pe_hz_parties.ou_start_dt%TYPE

  ) RETURN BOOLEAN IS
    --
    x_return_value BOOLEAN := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    --
  BEGIN
    --
    -- Foreign Key checks (Parent Existence)
    --
    -- Check for Attendance Type Existence
    --
    IF (p_lgcy_prout_rec.restricted_attendance_type IS NOT NULL) THEN
      IF (NOT igs_en_atd_type_pkg.get_pk_for_validation (
                p_lgcy_prout_rec.restricted_attendance_type
              )) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_ATD_TYP_FK');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- Check for Program Group Existence
    --
    IF (p_lgcy_prout_rec.encmb_program_group_cd IS NOT NULL) THEN
      IF (NOT igs_ps_grp_pkg.get_pk_for_validation (
                p_lgcy_prout_rec.encmb_program_group_cd
              )) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_PS_GRP_FK');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- Check for Organization Unit Existence
    --
    IF (p_lgcy_prout_rec.decision_org_unit_cd IS NOT NULL) THEN
      IF (NOT igs_or_unit_pkg.get_pk_for_validation (
                p_lgcy_prout_rec.decision_org_unit_cd,
                p_org_start_dt
              )) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_OR_UNIT_FK');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- Check for Outcome Type Existence
    -- kdande; 02-Jan-2003; Bug# 2732567; Changed the logic to set the
    -- x_return_value to FALSE when the Progression Outcome Type is not
    -- already defined in the system.
    --
    IF (p_lgcy_prout_rec.progression_outcome_type IS NOT NULL) THEN
      IF (NOT igs_pr_ou_type_pkg.get_pk_for_validation (
                p_lgcy_prout_rec.progression_outcome_type
              )) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_OU_TYPE_FK');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- Primary Key validation
    --
    IF (igs_pr_stdnt_pr_ou_pkg.get_pk_for_validation (
          p_person_id,
          p_lgcy_prout_rec.program_cd,
          p_sequence_number
        )) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_NO_SPO_EXIST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Valid Value Checks
    --
    IF (p_lgcy_prout_rec.duration IS NOT NULL) THEN
      BEGIN
        igs_pr_stdnt_pr_ou_pkg.check_constraints (
          'DURATION',
          p_lgcy_prout_rec.duration
        );
      EXCEPTION
        WHEN OTHERS THEN
          --
          -- Delete the top message and add a new message in place of it
          --
          FND_MSG_PUB.Delete_Msg (FND_MSG_PUB.Count_Msg);
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_DURATION_FORMAT');
          FND_MSG_PUB.ADD;
          x_return_value := FALSE;
      END;
    END IF;
    --
    IF (p_lgcy_prout_rec.restricted_enrolment_cp IS NOT NULL) THEN
      BEGIN
        igs_pr_stdnt_pr_ou_pkg.check_constraints (
          'RESTRICTED_ENROLMENT_CP',
          p_lgcy_prout_rec.restricted_enrolment_cp
        );
      EXCEPTION
        WHEN OTHERS THEN
          --
          -- Delete the top message and add a new message in place of it
          --
          FND_MSG_PUB.Delete_Msg (FND_MSG_PUB.Count_Msg);
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_RESENR_FORMAT');
          FND_MSG_PUB.ADD;
          x_return_value := FALSE;
      END;
    END IF;
    --
    IF (p_lgcy_prout_rec.duration_type IS NOT NULL) THEN
      BEGIN
        igs_pr_stdnt_pr_ou_pkg.check_constraints (
          'DURATION_TYPE',
          p_lgcy_prout_rec.duration_type
        );
      EXCEPTION
        WHEN OTHERS THEN
          --
          -- Delete the top message and add a new message in place of it
          --
          FND_MSG_PUB.Delete_Msg (FND_MSG_PUB.Count_Msg);
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_DURTYP_VALID');
          FND_MSG_PUB.ADD;
          x_return_value := FALSE;
      END;
    END IF;
    --
    IF (p_lgcy_prout_rec.decision_status IS NOT NULL) THEN
      BEGIN
        igs_pr_stdnt_pr_ou_pkg.check_constraints (
          'DECISION_STATUS',
          p_lgcy_prout_rec.decision_status
        );
      EXCEPTION
        WHEN OTHERS THEN
          --
          -- Delete the top message and add a new message in place of it
          --
          FND_MSG_PUB.Delete_Msg (FND_MSG_PUB.Count_Msg);
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_DURSTAT_VALID');
          FND_MSG_PUB.ADD;
          x_return_value := FALSE;
      END;
    END IF;
    --
    IF (p_lgcy_prout_rec.show_cause_outcome_type IS NOT NULL) THEN
      BEGIN
        igs_pr_stdnt_pr_ou_pkg.check_constraints (
          'SHOW_CAUSE_OUTCOME_TYPE',
          p_lgcy_prout_rec.show_cause_outcome_type
        );
      EXCEPTION
        WHEN OTHERS THEN
          --
          -- Delete the top message and add a new message in place of it
          --
          FND_MSG_PUB.Delete_Msg (FND_MSG_PUB.Count_Msg);
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_SHOWCAUSE_VALID');
          FND_MSG_PUB.ADD;
          x_return_value := FALSE;
      END;
    END IF;
    --
    IF (p_lgcy_prout_rec.appeal_outcome_type IS NOT NULL) THEN
      BEGIN
        igs_pr_stdnt_pr_ou_pkg.check_constraints (
          'APPEAL_OUTCOME_TYPE',
          p_lgcy_prout_rec.appeal_outcome_type
        );
      EXCEPTION
        WHEN OTHERS THEN
          --
          -- Delete the top message and add a new message in place of it
          --
          FND_MSG_PUB.Delete_Msg (FND_MSG_PUB.Count_Msg);
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_APPEAL_VALID');
          FND_MSG_PUB.ADD;
          x_return_value := FALSE;
      END;
    END IF;
    --
    RETURN (x_return_value);
    --
  END validate_spo_db_cons;
  --
  -- This function validates all the business rules before inserting a record in
  -- the table IGS_PR_STDNT_PR_OU.
  --
  FUNCTION validate_stdnt_prg_otcm (
    p_lgcy_prout_rec               IN     lgcy_prout_rec_type,
    p_person_id                    IN     igs_pe_person.person_id%TYPE,
    p_prg_cal_type                 IN     igs_ca_inst.cal_type%TYPE,
    p_prg_sequence_number          IN     igs_ca_inst.sequence_number%TYPE,
    p_outcome_sequence_number      IN     igs_pr_stdnt_pr_ou_all.sequence_number%TYPE,
    p_hold_effect_type             IN     VARCHAR2,
    p_decision_ou_start_dt         IN     igs_pe_hz_parties.ou_start_dt%TYPE
  ) RETURN BOOLEAN IS
    --
    CURSOR cur_sca IS
      SELECT   course_attempt_status
      FROM     igs_en_stdnt_ps_att sca
      WHERE    person_id = p_person_id
      AND      course_cd = p_lgcy_prout_rec.program_cd
      AND      course_attempt_status = 'UNCONFIRM';
    --
    CURSOR cur_pot IS
      SELECT   s_progression_outcome_type
      FROM     igs_pr_ou_type pot
      WHERE    pot.progression_outcome_type = p_lgcy_prout_rec.progression_outcome_type;
    --
    rec_sca cur_sca%ROWTYPE;
    x_return_value BOOLEAN := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    x_message_name fnd_new_messages.message_name%TYPE;
    v_s_progression_outcome_type igs_pr_ou_type.s_progression_outcome_type%TYPE;
    l_where_clause VARCHAR2(2000);
    TYPE ref_cur IS REF CURSOR;
    l_ref_cur ref_cur;
    l_record_found VARCHAR2(1) := 'N';
    curr_stat            VARCHAR2(2000);
    l_func_name          VARCHAR2(30);
    --
  BEGIN
    --
    -- Check whether the Program Attempt Status is Unconfirmed
    --
    OPEN cur_sca;
    FETCH cur_sca INTO rec_sca;
    IF (cur_sca%FOUND) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_PRATMTSTAT_UNCONFIRM');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    CLOSE cur_sca;
    --
    -- Validate the Progression Calendar Instance to check whether it is Active
    --
    IF (NOT igs_pr_val_spo.prgp_val_prg_ci (
              p_prg_cal_type,
              p_prg_sequence_number,
              x_message_name
            )) THEN
      FND_MESSAGE.SET_NAME ('IGS', x_message_name);
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Validate the Expiry Date to check that it is not a future date
    --
    IF (NOT igs_pr_val_spo.prgp_val_spo_exp_dt (
              p_lgcy_prout_rec.expiry_dt,
              x_message_name
            )) THEN
      FND_MESSAGE.SET_NAME ('IGS', x_message_name);
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Validate whether the Decision Date and Decision Organization Unit Code is
    -- entered when the Decision Status is 'PENDING'
    --
    IF (p_lgcy_prout_rec.decision_status = 'PENDING') THEN
      IF ((p_lgcy_prout_rec.decision_dt IS NOT NULL) OR
          (p_lgcy_prout_rec.decision_org_unit_cd IS NOT NULL) OR
          (p_decision_ou_start_dt IS NOT NULL)) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_DEDT_DORG_CNT_DEST_PEN');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- Validate whether the Decision Organization Unit Code or Decision Date are
    -- Null when the Decision Status is 'APPROVED' or 'WAIVED'
    --
    IF (p_lgcy_prout_rec.decision_status IN ('APPROVED', 'WAIVED')) THEN
      IF ((p_lgcy_prout_rec.decision_dt IS NULL) OR
          (p_lgcy_prout_rec.decision_org_unit_cd IS NULL) OR
          (p_decision_ou_start_dt IS NULL)) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_DEDT_DEOR_CNT_DEST_PEN');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- Validate the Decision Date and check that it should not be a future date
    --
    IF (NOT igs_pr_val_spo.prgp_val_spo_dcsn_dt (
              p_lgcy_prout_rec.decision_dt,
              x_message_name
            )) THEN
      FND_MESSAGE.SET_NAME ('IGS', x_message_name);
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Validate that the Student Progression Outcome Program Code cannot be
    -- specified if the hold effect type does not contains one (or more than
    -- one) of 'SUS_COURSE, EXC_COURSE'
    --
    -- kdande; 24-Dec-2002; Bug# 2717616. Changed the OR condition to AND for
    -- the following IF condition
    --
    IF ((INSTR (p_hold_effect_type, 'SUS_COURSE') = 0) AND
        (INSTR (p_hold_effect_type, 'EXC_COURSE') = 0)) THEN
      IF (p_lgcy_prout_rec.spo_program_cd IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_PRGOTCM_NOT_IN_SUS_EXC');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- Validate that the Unit Set Code cannot be specified if the hold effect
    -- type is not set to 'EXC_CRS_US' - Exclusion from a Unit set
    --
    IF (INSTR (p_hold_effect_type, 'EXC_CRS_US') = 0) THEN
      IF (p_lgcy_prout_rec.unit_set_cd IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_USTOTCM_NOT_IN_PROG_US');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- Validate that the Unit of type EXCLUDED cannot be specified if the hold
    -- effect type is not set to 'EXC_CRS_U' - Exclude Unit
    --
    IF (INSTR (p_hold_effect_type, 'EXC_CRS_U') = 0) THEN
      IF (p_lgcy_prout_rec.s_unit_type = 'EXCLUDED') THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UOTCM_NOT_IN_PROG_U');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- Validate that the Unit of type REQUIRED cannot be specified if the hold
    -- effect type is not set to 'RQRD_CRS_U' - Required Unit
    --
    IF (INSTR (p_hold_effect_type, 'RQRD_CRS_U') = 0) THEN
      IF (p_lgcy_prout_rec.s_unit_type = 'REQUIRED') THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UOTCM_NOT_IN_RQRD');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- When the Progression Outcome Type is related to hold of type 'RSTR_GE_CP'
    -- or 'RSTR_LE_CP' validate whether the Restricted Enrolment CP is set
    --
    IF ((INSTR (p_hold_effect_type, 'RSTR_GE_CP') > 0) OR
        (INSTR (p_hold_effect_type, 'RSTR_LE_CP') > 0)) THEN
      IF (p_lgcy_prout_rec.restricted_enrolment_cp IS NULL) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_RERN_CPO_MEN_URE');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- When the Progression Outcome Type is related to hold of type 'RSTR_AT_TY'
    -- validate whether the Restricted Attendance Type is set
    --
    IF (INSTR (p_hold_effect_type, 'RSTR_AT_TY') > 0) THEN
      IF (p_lgcy_prout_rec.restricted_attendance_type IS NULL) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_REATY_MEN_PROT_ATRES');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- When the Progression Outcome Type is related to hold of type 'EXC_CRS_GP'
    -- validate whether the Encumbrance Program Group Code is set
    --
    IF (INSTR (p_hold_effect_type, 'EXC_CRS_GP') > 0) THEN
      IF (p_lgcy_prout_rec.encmb_program_group_cd IS NULL) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_ENCUM_CGP_MEN_EXC');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- Check that the Excluded Program Group can be set only when the Progression
    -- Outcome Type is related to a hold with the 'EXC_CRS_GP' effect
    --
    IF (NOT igs_pr_val_spo.prgp_val_spo_cgr (
              p_lgcy_prout_rec.progression_outcome_type,
              p_lgcy_prout_rec.encmb_program_group_cd,
              x_message_name
            )) THEN
      FND_MESSAGE.SET_NAME ('IGS', x_message_name);
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that the Restricted Attendance Type can be set only when the
    -- Progression Outcome Type is related to a hold with the 'RSTR_AT_TY' effect
    --
    IF (NOT igs_pr_val_spo.prgp_val_spo_att (
              p_lgcy_prout_rec.progression_outcome_type,
              p_lgcy_prout_rec.restricted_attendance_type,
              x_message_name
            )) THEN
      FND_MESSAGE.SET_NAME ('IGS', x_message_name);
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that the Restricted Enrollment CP can be set only when the
    -- Progression Outcome Type is related to a hold with the 'RSTR_GE_CP' or
    -- 'RSTR_LE_CP' effect
    --
    IF (NOT igs_pr_val_spo.prgp_val_spo_cp (
              p_lgcy_prout_rec.progression_outcome_type,
              p_lgcy_prout_rec.restricted_enrolment_cp,
              x_message_name
            )) THEN
      FND_MESSAGE.SET_NAME ('IGS', x_message_name);
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that when Duration is set, the Duration Type must also be set and vice versa
    --
    IF (NOT igs_pr_val_spo.prgp_val_spo_rqrd (
              p_lgcy_prout_rec.progression_outcome_type,
              p_lgcy_prout_rec.duration,
              p_lgcy_prout_rec.duration_type,
              x_message_name
            )) THEN
      FND_MESSAGE.SET_NAME ('IGS', x_message_name);
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- When the System Progression Outcome Type corresponding to the Progression
    -- Outcome Type is 'SUSPENSION' then Duration must be set
    --
    OPEN cur_pot;
    FETCH cur_pot INTO v_s_progression_outcome_type;
    CLOSE cur_pot;
    --
    IF ((v_s_progression_outcome_type = 'SUSPENSION') AND
        (p_lgcy_prout_rec.duration IS NULL)) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_DU_DUTY_SUS');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- When the System Progression Outcome Type corresponding to the Progression
    -- Outcome Type is one of 'EXCLUSION', 'EXPULSION', 'EX_FUND' or 'NOPENALTY'
    -- then Duration must not be set
    --
    IF ((v_s_progression_outcome_type IN ('EXCLUSION', 'EXPULSION', 'NOPENALTY', 'EX_FUND')) AND
        (p_lgcy_prout_rec.duration IS NOT NULL)) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_DUTY_PRTY_EXC_NOP');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- When the System Progression Outcome Type corresponding to the Progression
    -- Outcome Type is not in 'PROBATION' or 'MANUAL' then Duration Type cannot
    -- be 'EFFECTIVE'
    --
    IF ((v_s_progression_outcome_type NOT IN ('PROBATION', 'MANUAL')) AND
        (p_lgcy_prout_rec.duration_type = 'EFFECTIVE')) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_DTYP_CNTEF_PRO_MAN');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- When the Show Cause Date is Null then the Show Cause Outcome Date and
    -- Show Cause Outcome Type cannot be Not Null
    --
    IF ((p_lgcy_prout_rec.show_cause_dt IS NULL) AND
        ((p_lgcy_prout_rec.show_cause_outcome_dt IS NOT NULL) OR
         (p_lgcy_prout_rec.show_cause_outcome_type IS NOT NULL))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_SHCA_OTY_ODTCT_SCDT_NT');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that Show Cause Outcome Date is not greater than System Date
    --
    IF ((p_lgcy_prout_rec.show_cause_outcome_dt IS NOT NULL) AND
        (TRUNC(p_lgcy_prout_rec.show_cause_outcome_dt) > TRUNC(SYSDATE))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_SHCA_OUDT_CNT_FUT');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that when the Show Cause Outcome Date is set then the Show Cause
    -- Outcome Type should also be set and vice versa
    --
    IF ((p_lgcy_prout_rec.show_cause_outcome_dt IS NULL) AND
        (p_lgcy_prout_rec.show_cause_outcome_type IS NOT NULL)) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_SCADT_MST_SHOTY_ST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    IF ((p_lgcy_prout_rec.show_cause_outcome_dt IS NOT NULL) AND
        (p_lgcy_prout_rec.show_cause_outcome_type IS NULL)) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_SHOT_TYMST_SCO_DTST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that the Show Cause Date is not a future date
    --
    IF ((p_lgcy_prout_rec.show_cause_dt IS NOT NULL) AND
        (TRUNC(p_lgcy_prout_rec.show_cause_dt) > TRUNC(SYSDATE))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_SHCA_DT_CNT_FUT');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that Show Cause Date is not set when the Decision Date is Null
    --
    IF ((p_lgcy_prout_rec.show_cause_dt IS NOT NULL) AND
        (p_lgcy_prout_rec.decision_dt IS NULL)) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_SHCDT_CNT_ST_DEDT_NST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that Show Cause Date is not set when Show Cause Expiry Date is Null
    --
    IF ((p_lgcy_prout_rec.show_cause_expiry_dt IS NULL) AND
        (p_lgcy_prout_rec.show_cause_dt IS NOT NULL)) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_SCADT_CNT_SHEX_DTNST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that Show Cause Expiry Date is not set when decision is not made.
    -- kdande; 02-Jan-2003; Bug# 2732563; Changed the logic to check for the
    -- decision_dt instead of decision_status.
    --
    IF ((p_lgcy_prout_rec.show_cause_expiry_dt IS NOT NULL) AND
        (p_lgcy_prout_rec.decision_dt IS NULL)) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_SHCA_EXPDT_CNTB_DSTNA');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that Show Cause Expiry Date is not greater than the Appeal Expiry Date
    --
    IF (TRUNC (NVL (p_lgcy_prout_rec.show_cause_expiry_dt,
                  igs_ge_date.igsdate('0001/01/01'))) >
        TRUNC (NVL (p_lgcy_prout_rec.appeal_expiry_dt,
                  igs_ge_date.igsdate('9999/01/01')))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_SH_EXPDT_CNT_APEXDT');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that when Appeal Date is Null then Appeal Outcome Date and
    -- Appeal Outcome Type cannot be Not Null.
    --
    IF ((p_lgcy_prout_rec.appeal_dt IS NULL) AND
        ((p_lgcy_prout_rec.appeal_outcome_dt IS NOT NULL) OR
         (p_lgcy_prout_rec.appeal_outcome_type IS NOT NULL))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_APOTY_DTCNT_APDT_NST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that Appeal Outcome Date not greater than System date
    --
    IF ((p_lgcy_prout_rec.appeal_outcome_dt IS NOT NULL) AND
        (TRUNC(p_lgcy_prout_rec.appeal_outcome_dt) > TRUNC(SYSDATE))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_APOUT_DT_CNT_FUT');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that Appeal Outcome Date is set then the Appeal Outcome Type should
    -- also be set and vice versa
    --
    IF ((p_lgcy_prout_rec.appeal_outcome_dt IS NULL) AND
        (p_lgcy_prout_rec.appeal_outcome_type IS NOT NULL)) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_APODT_MST_AOTY_ST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    IF ((p_lgcy_prout_rec.appeal_outcome_dt IS NOT NULL) AND
        (p_lgcy_prout_rec.appeal_outcome_type IS NULL)) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_APOTY_MST_AODT_ST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that the Appeal Date is not a future date
    --
    IF ((p_lgcy_prout_rec.appeal_dt IS NOT NULL) AND
        (TRUNC(p_lgcy_prout_rec.appeal_dt) > TRUNC(SYSDATE))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_APOUT_DT_CNT_FUT');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that Appeal Date is not lesser than the Show Cause Date
    --
    IF (TRUNC (NVL (p_lgcy_prout_rec.appeal_dt,
                  igs_ge_date.igsdate('9999/01/01'))) <
        TRUNC (NVL (p_lgcy_prout_rec.show_cause_dt,
                  igs_ge_date.igsdate('0001/01/01')))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_APDT_CNTS_BSHDT');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that Appeal Expiry Date is not set when decision is not made
    -- kdande; 02-Jan-2003; Bug# 2732564; Changed the logic to check for the
    -- decision_dt instead of decision_status.
    --
    IF ((p_lgcy_prout_rec.appeal_expiry_dt IS NOT NULL) AND
        (p_lgcy_prout_rec.decision_dt IS NULL)) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_AEXDT_CNT_ST_DECST_NTAP');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Organization Unit Filter Integration Validation
    --
    -- kdande; 03-Sep-2003; Bug# 3102377; Validate only when the Decision
    -- Organization Unit Code is NOT NULL
    --
    IF (p_lgcy_prout_rec.decision_org_unit_cd IS NOT NULL) THEN
      l_func_name := 'PROG_OUTCOME_LGCY';
      igs_or_gen_012_pkg.get_where_clause_api (l_func_name,l_where_clause);

      IF l_where_clause IS NOT NULL THEN
              curr_stat := 'SELECT ''x'' FROM igs_or_unit WHERE org_unit_cd = :1 AND '||l_where_clause;
              OPEN l_ref_cur FOR curr_stat USING p_lgcy_prout_rec.decision_org_unit_cd,l_func_name;
      ELSE
              curr_stat := 'SELECT ''x'' FROM igs_or_unit WHERE org_unit_cd = :1 ';
              OPEN l_ref_cur FOR curr_stat USING p_lgcy_prout_rec.decision_org_unit_cd;
      END IF;

      FETCH l_ref_cur INTO l_record_found;
      IF (l_ref_cur%NOTFOUND) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_INV');
        FND_MESSAGE.SET_TOKEN ('PARAM', p_lgcy_prout_rec.decision_org_unit_cd);
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
      CLOSE l_ref_cur;
    END IF;
    --
    RETURN (x_return_value);
    --
  END validate_stdnt_prg_otcm;
  --
  -- This function performs all the data integrity validation and keeps adding
  -- error message to stack as an when it encounters one.
  --
  FUNCTION validate_prg_db_cons (
    p_lgcy_prout_rec               IN     lgcy_prout_rec_type,
    p_person_id                    IN     igs_pe_person.person_id%TYPE,
    p_sequence_number              IN     igs_pr_stdnt_pr_ou.sequence_number%TYPE
  ) RETURN BOOLEAN IS
    --
    x_return_value BOOLEAN := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    --
  BEGIN
    --
    -- Foreign Key Checks (Checking Parent Existence)
    -- Course Code Existence
    --
    IF ((p_lgcy_prout_rec.program_cd IS NOT NULL) AND
        (NOT igs_ps_course_pkg.get_pk_for_validation (
           p_lgcy_prout_rec.program_cd
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_PS_COURSE_FK');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Student Progression Outcome Existence
    --
    IF ((p_person_id IS NOT NULL) AND
        (p_lgcy_prout_rec.program_cd IS NOT NULL) AND
        (p_sequence_number IS NOT NULL) AND
        (NOT igs_pr_stdnt_pr_ou_pkg.get_pk_for_validation (
           p_person_id,
           p_lgcy_prout_rec.program_cd,
           p_sequence_number
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_PRG_SPO_FK');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Primary Key Validation
    --
    IF ((p_person_id IS NOT NULL) AND
        (p_lgcy_prout_rec.program_cd IS NOT NULL) AND
        (p_sequence_number IS NOT NULL) AND
        (p_lgcy_prout_rec.spo_program_cd IS NOT NULL) AND
        (igs_pr_stdnt_pr_ps_pkg.get_pk_for_validation (
           p_person_id,
           p_lgcy_prout_rec.program_cd,
           p_sequence_number,
           p_lgcy_prout_rec.spo_program_cd
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_NO_SPPRG_EXIST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    RETURN (x_return_value);
    --
  END validate_prg_db_cons;
  --
  -- This function validates all the business rules before inserting a record
  -- in the table IGS_PR_STDNT_PR_PS
  --
  FUNCTION validate_progression (
    p_lgcy_prout_rec               IN     lgcy_prout_rec_type,
    p_hold_effect_type             IN     VARCHAR2
  ) RETURN BOOLEAN IS
    --
    x_return_value BOOLEAN := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    --
  BEGIN
    --
    -- Check that spo_program_cd is Not Null only when the hold effect type is
    -- 'SUS_COURSE' or 'EXC_COURSE'
    --
    -- kdande; 24-Dec-2002; Bug# 2717616. Changed the OR condition to AND for
    -- the following IF condition
    --
    IF ((INSTR (p_hold_effect_type, 'SUS_COURSE') = 0) AND
        (INSTR (p_hold_effect_type, 'EXC_COURSE') = 0)) THEN
      IF (p_lgcy_prout_rec.spo_program_cd IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_PRGOTCM_NOT_IN_SUS_EXC');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    RETURN (x_return_value);
    --
  END validate_progression;
  --
  -- This function performs all the data integrity validation and keeps
  -- adding error message to stack as an when it encounters one
  --
  FUNCTION validate_uset_db_cons (
    p_lgcy_prout_rec               IN     lgcy_prout_rec_type,
    p_person_id                    IN     igs_pe_person.person_id%TYPE,
    p_sequence_number              IN     igs_pr_stdnt_pr_ou.sequence_number%TYPE
  ) RETURN BOOLEAN IS
    --
    x_return_value BOOLEAN := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    --
  BEGIN
    --
    -- Foreign Key Checks (Checking Parent Existence)
    -- Unit Set Existence
    --
    IF ((p_lgcy_prout_rec.unit_set_cd IS NOT NULL) AND
        (p_lgcy_prout_rec.us_version_number IS NOT NULL) AND
        (NOT igs_en_unit_set_pkg.get_pk_for_validation (
           p_lgcy_prout_rec.unit_set_cd,
           p_lgcy_prout_rec.us_version_number
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_USET_UNITSET_FK');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Student Progression Outcome Existence
    --
    IF ((p_person_id IS NOT NULL) AND
        (p_lgcy_prout_rec.program_cd IS NOT NULL) AND
        (p_sequence_number IS NOT NULL) AND
        (NOT igs_pr_stdnt_pr_ou_pkg.get_pk_for_validation (
           p_person_id,
           p_lgcy_prout_rec.program_cd,
           p_sequence_number
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_PRG_SPO_FK');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Primary Key Validation
    --
    IF ((p_person_id IS NOT NULL) AND
        (p_lgcy_prout_rec.program_cd IS NOT NULL) AND
        (p_sequence_number IS NOT NULL) AND
        (p_lgcy_prout_rec.unit_set_cd IS NOT NULL) AND
        (p_lgcy_prout_rec.us_version_number IS NOT NULL) AND
        (igs_pr_sdt_pr_unt_st_pkg.get_pk_for_validation (
           p_person_id,
           p_lgcy_prout_rec.program_cd,
           p_sequence_number,
           p_lgcy_prout_rec.unit_set_cd,
           p_lgcy_prout_rec.us_version_number
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_NO_SPUSET_EXIST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    RETURN (x_return_value);
    --
  END validate_uset_db_cons;
  --
  -- This function validates all the business rules before inserting a record
  -- in the table IGS_PR_SDT_PR_UNT_ST
  --
  FUNCTION validate_unit_set (
    p_lgcy_prout_rec               IN     lgcy_prout_rec_type,
    p_person_id                    IN     igs_pe_person.person_id%TYPE,
    p_sequence_number              IN     igs_pr_stdnt_pr_ou.sequence_number%TYPE,
    p_hold_effect_type             IN     VARCHAR2
  ) RETURN BOOLEAN IS
    --
    CURSOR cur_us_uss IS
      SELECT   'Y'
      FROM     igs_en_unit_set us,
               igs_en_unit_set_stat uss
      WHERE    us.unit_set_cd = p_lgcy_prout_rec.unit_set_cd
      AND      us.version_number = p_lgcy_prout_rec.us_version_number
      AND      us.unit_set_status = uss.unit_set_status
      AND      uss.s_unit_set_status <> 'PLANNED';
    --
    x_return_value BOOLEAN := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    x_message_name fnd_new_messages.message_name%TYPE;
    l_record_found VARCHAR2(1) := 'N';
    --
  BEGIN
    --
    -- Check that Unit Set is Not Null only when the hold effect type is 'EXC_CRS_US'
    --
    IF ((INSTR (p_hold_effect_type, 'EXC_CRS_US') = 0) AND
        (p_lgcy_prout_rec.unit_set_cd IS NOT NULL) AND
        (p_lgcy_prout_rec.us_version_number IS NOT NULL)) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_STPR_OUT_EXC_CRS_US');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
    END IF;
    IF ((p_lgcy_prout_rec.unit_set_cd IS NOT NULL) AND
        (p_lgcy_prout_rec.us_version_number IS NOT NULL)) THEN
      IF (NOT igs_pr_val_spus.prgp_val_spus_spo (
                p_person_id,
                p_lgcy_prout_rec.program_cd,
                p_sequence_number,
                x_message_name
              )) THEN
        FND_MESSAGE.SET_NAME ('IGS', x_message_name);
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- Check that Unit Set is not Planned
    --
    IF ((p_lgcy_prout_rec.unit_set_cd IS NOT NULL) AND
        (p_lgcy_prout_rec.us_version_number IS NOT NULL)) THEN
      OPEN cur_us_uss;
      FETCH cur_us_uss INTO l_record_found;
      IF (cur_us_uss%NOTFOUND) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNIT_SET_NOT_PLANNED');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
      CLOSE cur_us_uss;
    END IF;
    --
    RETURN (x_return_value);
    --
  END validate_unit_set;
  --
  -- This function performs all the data integrity validation and keeps
  -- adding error message to stack as an when it encounters one
  --
  FUNCTION validate_unit_db_cons (
    p_lgcy_prout_rec               IN     lgcy_prout_rec_type,
    p_person_id                    IN     igs_pe_person.person_id%TYPE,
    p_sequence_number              IN     igs_pr_stdnt_pr_ou.sequence_number%TYPE
  ) RETURN BOOLEAN IS
    --
    x_return_value BOOLEAN := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    --
  BEGIN
    --
    -- Foreign Key Checks (Checking Parent Existence)
    -- Unit Existence
    --
    IF ((p_lgcy_prout_rec.unit_cd IS NOT NULL) AND
        (NOT igs_ps_unit_pkg.get_pk_for_validation (
           p_lgcy_prout_rec.unit_cd
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNIT_UEXIST_FK');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Student Progression Outcome Existence
    --
    IF ((p_person_id IS NOT NULL) AND
        (p_lgcy_prout_rec.program_cd IS NOT NULL) AND
        (p_sequence_number IS NOT NULL) AND
        (NOT igs_pr_stdnt_pr_ou_pkg.get_pk_for_validation (
           p_person_id,
           p_lgcy_prout_rec.program_cd,
           p_sequence_number
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_PRG_SPO_FK');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Primary Key Validation
    --
    IF ((p_person_id IS NOT NULL) AND
        (p_lgcy_prout_rec.program_cd IS NOT NULL) AND
        (p_sequence_number IS NOT NULL) AND
        (p_lgcy_prout_rec.unit_cd IS NOT NULL) AND
        (igs_pr_stdnt_pr_unit_pkg.get_pk_for_validation (
           p_person_id,
           p_lgcy_prout_rec.program_cd,
           p_sequence_number,
           p_lgcy_prout_rec.unit_cd
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_NO_SPUNIT_EXIST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Valid Value Checks
    --
    IF (p_lgcy_prout_rec.s_unit_type IS NOT NULL) THEN
      BEGIN
        igs_pr_stdnt_pr_unit_pkg.check_constraints  (
          'S_UNIT_TYPE',
          p_lgcy_prout_rec.s_unit_type
        );
      EXCEPTION
        WHEN OTHERS THEN
          --
          -- Delete the top message and add a new message in place of it
          --
          FND_MSG_PUB.Delete_Msg (FND_MSG_PUB.Count_Msg);
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_UNIT_TYPE_VALID');
          FND_MSG_PUB.ADD;
          x_return_value := FALSE;
      END;
    END IF;
    --
    RETURN (x_return_value);
    --
  END validate_unit_db_cons;
  --
  -- This function validates all the business rules before inserting a record
  -- in the table IGS_PR_STDNT_PR_UNIT
  --
  FUNCTION validate_unit (
    p_lgcy_prout_rec               IN     lgcy_prout_rec_type,
    p_hold_effect_type             IN     VARCHAR2
  ) RETURN BOOLEAN IS
    --
    x_return_value BOOLEAN := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    --
  BEGIN
    --
    -- Check that Unit is Not Null with s_unit_type as 'EXCLUDED' only when the
    -- hold effect type is 'EXC_CRS_U'
    --
    IF ((p_lgcy_prout_rec.unit_cd IS NOT NULL) AND
        (p_lgcy_prout_rec.s_unit_type = 'EXCLUDED') AND
        (INSTR (p_hold_effect_type, 'EXC_CRS_U') = 0)) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_STPR_OUT_EXC_CRS_U');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Check that Unit is Not Null with s_unit_type as 'REQUIRED' only when the
    -- hold effect type is 'RQRD_CRS_U'
    --
    IF ((p_lgcy_prout_rec.unit_cd IS NOT NULL) AND
        (p_lgcy_prout_rec.s_unit_type = 'REQUIRED') AND
        (INSTR (p_hold_effect_type, 'RQRD_CRS_U') = 0)) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_STPR_OUT_RQRD_CRS_U');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    RETURN (x_return_value);
    --
  END validate_unit;
  --
  -- This function performs all the data integrity validation and keeps
  -- adding error message to stack as an when it encounters one
  --
  FUNCTION validate_awd_db_cons (
    p_lgcy_prout_rec               IN     lgcy_prout_rec_type,
    p_person_id                    IN     igs_pe_person.person_id%TYPE,
    p_sequence_number              IN     igs_pr_stdnt_pr_ou.sequence_number%TYPE
  ) RETURN BOOLEAN IS
    --
    x_return_value BOOLEAN := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    --
  BEGIN
    --
    -- Foreign Key Checks (Checking Parent Existence)
    -- Award Existence
    --
    IF ((p_lgcy_prout_rec.award_cd IS NOT NULL) AND
        (NOT igs_ps_awd_pkg.get_pk_for_validation (
           p_lgcy_prout_rec.award_cd
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_AWD_AWARD_FK');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Student Progression Outcome Existence
    --
    IF ((p_person_id IS NOT NULL) AND
        (p_lgcy_prout_rec.program_cd IS NOT NULL) AND
        (p_sequence_number IS NOT NULL) AND
        (NOT igs_pr_stdnt_pr_ou_pkg.get_pk_for_validation (
           p_person_id,
           p_lgcy_prout_rec.program_cd,
           p_sequence_number
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_PRG_SPO_FK');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Primary Key Validation
    --
    IF ((p_person_id IS NOT NULL) AND
        (p_lgcy_prout_rec.program_cd IS NOT NULL) AND
        (p_sequence_number IS NOT NULL) AND
        (p_lgcy_prout_rec.award_cd IS NOT NULL) AND
        (igs_pr_stdnt_pr_awd_pkg.get_pk_for_validation (
           p_person_id,
           p_lgcy_prout_rec.program_cd,
           p_sequence_number,
           p_lgcy_prout_rec.award_cd
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_NO_SPAWD_EXIST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    RETURN (x_return_value);
    --
  END validate_awd_db_cons;
  --
  -- This function validates all the business rules before inserting a record
  -- in the table IGS_PR_STDNT_PR_AWD
  --
  FUNCTION validate_award (
    p_lgcy_prout_rec               IN     lgcy_prout_rec_type
  ) RETURN BOOLEAN IS
    --
    CURSOR cur_award IS
      SELECT   s_award_type
      FROM     igs_ps_awd
      WHERE    award_cd = p_lgcy_prout_rec.award_cd;
    --
    CURSOR cur_positive_otcm IS
      SELECT   positive_outcome_ind
      FROM     igs_pr_ou_type
      WHERE    progression_outcome_type = p_lgcy_prout_rec.progression_outcome_type;
    --
    x_return_value BOOLEAN := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    rec_award cur_award%ROWTYPE;
    rec_positive_otcm cur_positive_otcm%ROWTYPE;
    --
  BEGIN
    --
    -- Check that the Award must be a medal or prize
    --
    IF (p_lgcy_prout_rec.award_cd IS NOT NULL) THEN
      OPEN cur_award;
      FETCH cur_award INTO rec_award;
      CLOSE cur_award;
      IF (rec_award.s_award_type NOT IN ('MEDAL','PRIZE')) THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_AWD_MED_PRIZE');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    -- Check that Award Code must be specified only for Positive Outcomes
    --
    IF (p_lgcy_prout_rec.award_cd IS NOT NULL) THEN
      OPEN cur_positive_otcm;
      FETCH cur_positive_otcm INTO rec_positive_otcm;
      CLOSE cur_positive_otcm;
      IF (rec_positive_otcm.positive_outcome_ind <> 'Y') THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_AWD_NOT_POS');
        FND_MSG_PUB.ADD;
        x_return_value := FALSE;
      END IF;
    END IF;
    --
    RETURN (x_return_value);
    --
  END validate_award;
  --
  --
  -- anilk, Bug# 3021236, adding fund_code to interface table.
  -- Hence creating this procedure.
  --
  -- This function performs all the data integrity validation and keeps
  -- adding error message to stack as an when it encounters one
  --
  FUNCTION validate_fnd_db_cons (
    p_lgcy_prout_rec               IN     lgcy_prout_rec_type,
    p_person_id                    IN     igs_pe_person.person_id%TYPE,
    p_sequence_number              IN     igs_pr_stdnt_pr_ou.sequence_number%TYPE
  ) RETURN BOOLEAN IS
    --
    x_return_value BOOLEAN := FND_API.TO_BOOLEAN (FND_API.G_TRUE);
    --
  BEGIN
    --
    -- Foreign Key Checks (Checking Parent Existence)
    -- Fund Code Existence
    --
    IF ((p_lgcy_prout_rec.fund_code IS NOT NULL) AND
        (NOT igf_aw_fund_cat_pkg.get_uk_for_validation (
           p_lgcy_prout_rec.fund_code
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_FUND_CODE_FK');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    -- Primary Key Validation
    --
    IF ((p_person_id IS NOT NULL) AND
        (p_lgcy_prout_rec.program_cd IS NOT NULL) AND
        (p_sequence_number IS NOT NULL) AND
        (p_lgcy_prout_rec.fund_code IS NOT NULL) AND
        (igs_pr_stdnt_pr_fnd_pkg.get_pk_for_validation (
           p_person_id,
           p_lgcy_prout_rec.program_cd,
           p_sequence_number,
           p_lgcy_prout_rec.fund_code
         ))) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_PR_NO_SPFUND_EXIST');
      FND_MSG_PUB.ADD;
      x_return_value := FALSE;
    END IF;
    --
    RETURN (x_return_value);
    --
  END validate_fnd_db_cons;
  --
  PROCEDURE create_outcome (
    p_api_version                  IN     NUMBER,
    p_init_msg_list                IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                       IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level             IN     NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
    x_return_status                OUT    NOCOPY VARCHAR2,
    x_msg_count                    OUT    NOCOPY NUMBER,
    x_msg_data                     OUT    NOCOPY VARCHAR2,
    p_lgcy_prout_rec               IN OUT NOCOPY lgcy_prout_rec_type
  ) IS
    --
    l_api_name CONSTANT VARCHAR2(30) := 'create_outcome';
    l_api_version CONSTANT NUMBER := 1.0;
    -- Local params
    l_person_id igs_pe_person.person_id%TYPE;
    l_prg_cal_type igs_ca_inst.cal_type%TYPE;
    l_prg_sequence_number igs_ca_inst.sequence_number%TYPE;
    l_outcome_sequence_number igs_pr_stdnt_pr_ou_all.sequence_number%TYPE;
    l_hold_effect_type VARCHAR2(2000);
    l_org_start_dt igs_pe_hz_parties.ou_start_dt%TYPE;
    l_return_value VARCHAR2(1);
    l_return_boolean_value BOOLEAN;
    l_rowid VARCHAR2(25);
    --
  BEGIN
    --
    -- Standard start of API savepoint
    --
    SAVEPOINT create_outcome;
    --
    -- Standard call to check for call compatibility.
    --
    IF (NOT FND_API.Compatible_API_Call (
             l_api_version,
             p_api_version,
             l_api_name,
             g_pkg_name)) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF (FND_API.to_Boolean (p_init_msg_list)) THEN
      FND_MSG_PUB.Initialize;
    END IF;
    --
    -- Initialize API return status to success.
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    -- API body
    --
    -- Validate the params passed to this API
    --
    IF (NOT validate_parameters (p_lgcy_prout_rec)) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    -- Derive Progression Outcome Type data
    --
    derive_pr_stnd_lvl_data (
      p_lgcy_prout_rec               => p_lgcy_prout_rec,
      p_person_id                    => l_person_id,
      p_prg_cal_type                 => l_prg_cal_type,
      p_prg_sequence_number          => l_prg_sequence_number,
      p_outcome_sequence_number      => l_outcome_sequence_number,
      p_hold_effect_type             => l_hold_effect_type,
      p_org_start_dt                 => l_org_start_dt,
      x_return_value                 => l_return_boolean_value
    );
    IF (NOT l_return_boolean_value) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    -- Check Student Progression Outcome Database Constraints
    --
    IF (NOT validate_spo_db_cons (
              p_lgcy_prout_rec               => p_lgcy_prout_rec,
              p_person_id                    => l_person_id,
              p_sequence_number              => l_outcome_sequence_number,
              p_org_start_dt                 => l_org_start_dt
            )) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    -- Validate all the business rules before inserting a record IGS_PR_STDNT_PR_OU
    --
    IF (NOT validate_stdnt_prg_otcm (
              p_lgcy_prout_rec               => p_lgcy_prout_rec,
              p_person_id                    => l_person_id,
              p_prg_cal_type                 => l_prg_cal_type,
              p_prg_sequence_number          => l_prg_sequence_number,
              p_outcome_sequence_number      => l_outcome_sequence_number,
              p_hold_effect_type             => l_hold_effect_type,
              p_decision_ou_start_dt         => l_org_start_dt
            )) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    -- Create an entry in the Student Program Outcome table is does not already exist
    --
    IF (NOT igs_pr_stdnt_pr_ou_pkg.get_pk_for_validation (
              l_person_id,
              p_lgcy_prout_rec.program_cd,
              l_outcome_sequence_number
            )) THEN
      l_rowid := NULL;
      igs_pr_stdnt_pr_ou_pkg.insert_row (
        x_rowid                         => l_rowid,
        x_person_id                     => l_person_id,
        x_course_cd                     => p_lgcy_prout_rec.program_cd,
        x_sequence_number               => l_outcome_sequence_number,
        x_prg_cal_type                  => l_prg_cal_type,
        x_prg_ci_sequence_number        => l_prg_sequence_number,
        x_rule_check_dt                 => NULL,
        x_progression_rule_cat          => NULL,
        x_pra_sequence_number           => NULL,
        x_pro_sequence_number           => NULL,
        x_progression_outcome_type      => p_lgcy_prout_rec.progression_outcome_type,
        x_duration                      => p_lgcy_prout_rec.duration,
        x_duration_type                 => p_lgcy_prout_rec.duration_type,
        x_decision_status               => p_lgcy_prout_rec.decision_status,
        x_decision_dt                   => p_lgcy_prout_rec.decision_dt,
        x_decision_org_unit_cd          => p_lgcy_prout_rec.decision_org_unit_cd,
        x_decision_ou_start_dt          => l_org_start_dt,
        x_applied_dt                    => NULL,
        x_show_cause_expiry_dt          => p_lgcy_prout_rec.show_cause_expiry_dt,
        x_show_cause_dt                 => p_lgcy_prout_rec.show_cause_dt,
        x_show_cause_outcome_dt         => p_lgcy_prout_rec.show_cause_outcome_dt,
        x_show_cause_outcome_type       => p_lgcy_prout_rec.show_cause_outcome_type,
        x_appeal_expiry_dt              => p_lgcy_prout_rec.appeal_expiry_dt,
        x_appeal_dt                     => p_lgcy_prout_rec.appeal_dt,
        x_appeal_outcome_dt             => p_lgcy_prout_rec.appeal_outcome_dt,
        x_appeal_outcome_type           => p_lgcy_prout_rec.appeal_outcome_type,
        x_encmb_course_group_cd         => p_lgcy_prout_rec.encmb_program_group_cd,
        x_restricted_enrolment_cp       => p_lgcy_prout_rec.restricted_enrolment_cp,
        x_restricted_attendance_type    => p_lgcy_prout_rec.restricted_attendance_type,
        x_comments                      => p_lgcy_prout_rec.comments,
        x_show_cause_comments           => p_lgcy_prout_rec.show_cause_comments,
        x_appeal_comments               => p_lgcy_prout_rec.appeal_comments,
        x_expiry_dt                     => p_lgcy_prout_rec.expiry_dt,
        x_pro_pra_sequence_number       => NULL,
        x_mode                          => 'R',
        x_org_id                        => igs_ge_gen_003.get_org_id
      );
    END IF;
    --
    -- Perform all the data integrity validations
    --
    IF (NOT validate_prg_db_cons (
              p_lgcy_prout_rec               => p_lgcy_prout_rec,
              p_person_id                    => l_person_id,
              p_sequence_number              => l_outcome_sequence_number
            )) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    -- Validate all the business rules before inserting a record into IGS_PR_STDNT_PR_PS
    --
    IF (NOT validate_progression (
              p_lgcy_prout_rec               => p_lgcy_prout_rec,
              p_hold_effect_type             => l_hold_effect_type
            )) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    -- Create an entry in the igs_pr_stdnt_pr_ps if the hold effect type is
    -- either 'SUS_COURSE' or 'EXC_COURSE'
    --
    -- kdande; 24-Dec-2002; Bug# 2717485. Added the following IF condition to
    -- create the record only if the hold effect type is either 'SUS_COURSE' or
    -- 'EXC_COURSE'
    --
    l_rowid := NULL;
    IF ((INSTR (l_hold_effect_type, 'SUS_COURSE') > 0) OR
        (INSTR (l_hold_effect_type, 'EXC_COURSE') > 0)) THEN
      IF (p_lgcy_prout_rec.spo_program_cd IS NOT NULL AND
          l_outcome_sequence_number IS NOT NULL AND
          p_lgcy_prout_rec.program_cd IS NOT NULL) THEN
        igs_pr_stdnt_pr_ps_pkg.insert_row (
          x_rowid                             => l_rowid,
          x_person_id                         => l_person_id,
          x_spo_course_cd                     => p_lgcy_prout_rec.spo_program_cd,
          x_spo_sequence_number               => l_outcome_sequence_number,
          x_course_cd                         => p_lgcy_prout_rec.program_cd,
          x_mode                              => 'R'
        );
      END IF;
    END IF;
    --
    IF (INSTR (l_hold_effect_type, 'EXC_CRS_US') > 0) THEN
      --
      -- Perform all the data integrity validations
      --
      IF (NOT validate_uset_db_cons (
                p_lgcy_prout_rec               => p_lgcy_prout_rec,
                p_person_id                    => l_person_id,
                p_sequence_number              => l_outcome_sequence_number
              )) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      -- Validate all the business rules before inserting a record into IGS_PR_SDT_PR_UNT_ST
      --
      IF (NOT validate_unit_set (
                p_lgcy_prout_rec               => p_lgcy_prout_rec,
                p_person_id                    => l_person_id,
                p_sequence_number              => l_outcome_sequence_number,
                p_hold_effect_type             => l_hold_effect_type
              )) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      -- Create an entry in the igs_pr_sdt_pr_unt_st if the hold effect type is 'EXC_CRS_US'
      --
      l_rowid := NULL;
      igs_pr_sdt_pr_unt_st_pkg.insert_row (
        x_rowid                             => l_rowid,
        x_person_id                         => l_person_id,
        x_course_cd                         => p_lgcy_prout_rec.program_cd,
        x_spo_sequence_number               => l_outcome_sequence_number,
        x_unit_set_cd                       => p_lgcy_prout_rec.unit_set_cd,
        x_version_number                    => p_lgcy_prout_rec.us_version_number,
        x_mode                              => 'R'
      );
    END IF;
    --
    IF ((INSTR (l_hold_effect_type, 'EXC_CRS_U') > 0) OR
        (INSTR (l_hold_effect_type, 'RQRD_CRS_U') > 0)) THEN
      l_rowid := NULL;
      IF ((p_lgcy_prout_rec.unit_cd IS NOT NULL) AND
          (p_lgcy_prout_rec.s_unit_type IS NOT NULL)) THEN
        --
        -- Perform all the data integrity validations
        --
        IF (NOT validate_unit_db_cons (
                  p_lgcy_prout_rec               => p_lgcy_prout_rec,
                  p_person_id                    => l_person_id,
                  p_sequence_number              => l_outcome_sequence_number
                )) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        -- Validate all the business rules before inserting a record into IGS_PR_STDNT_PR_UNIT
        --
        IF (NOT validate_unit (
                  p_lgcy_prout_rec               => p_lgcy_prout_rec,
                  p_hold_effect_type             => l_hold_effect_type
                )) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        --
        -- Create an entry in the igs_pr_stdnt_pr_unit if the hold effect type is
        -- either 'EXC_CRS_U' or 'RQRD_CRS_U'
        --
        l_rowid := NULL;
        igs_pr_stdnt_pr_unit_pkg.insert_row (
          x_rowid                             => l_rowid,
          x_person_id                         => l_person_id,
          x_course_cd                         => p_lgcy_prout_rec.program_cd,
          x_spo_sequence_number               => l_outcome_sequence_number,
          x_unit_cd                           => p_lgcy_prout_rec.unit_cd,
          x_s_unit_type                       => p_lgcy_prout_rec.s_unit_type,
          x_mode                              => 'R'
        );
      END IF;
    END IF;
    --
    IF (p_lgcy_prout_rec.award_cd IS NOT NULL) THEN
      --
      -- Perform all the data integrity validations
      --
      IF (NOT validate_awd_db_cons (
                p_lgcy_prout_rec               => p_lgcy_prout_rec,
                p_person_id                    => l_person_id,
                p_sequence_number              => l_outcome_sequence_number
              )) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      -- Validate all the business rules before inserting a record into IGS_PR_STDNT_PR_AWD
      --
      IF (NOT validate_award (
                p_lgcy_prout_rec               => p_lgcy_prout_rec
              )) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      -- Create an entry in the Student Program Awards table if the outcome is positive
      --
      l_rowid := NULL;
      igs_pr_stdnt_pr_awd_pkg.insert_row (
        x_rowid                             => l_rowid,
        x_person_id                         => l_person_id,
        x_course_cd                         => p_lgcy_prout_rec.program_cd,
        x_spo_sequence_number               => l_outcome_sequence_number,
        x_award_cd                          => p_lgcy_prout_rec.award_cd,
        x_mode                              => 'R'
      );
    END IF;

    IF (p_lgcy_prout_rec.fund_code IS NOT NULL) THEN
      --anilk, Bug# 3021236, adding fund_code
      --
      -- Perform all the data integrity validations
      --
      IF (NOT validate_fnd_db_cons (
                p_lgcy_prout_rec               => p_lgcy_prout_rec,
                p_person_id                    => l_person_id,
                p_sequence_number              => l_outcome_sequence_number
              )) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
      -- Create an entry in the igs_pr_stdnt_pr_fnd table
      --
      l_rowid := NULL;
      igs_pr_stdnt_pr_fnd_pkg.insert_row (
        x_rowid                             => l_rowid,
        x_person_id                         => l_person_id,
        x_course_cd                         => p_lgcy_prout_rec.program_cd,
        x_spo_sequence_number               => l_outcome_sequence_number,
        x_fund_code                         => p_lgcy_prout_rec.fund_code,
        x_mode                              => 'R'
      );
    END IF;

    --
    -- End of API body
    --
    -- Standard check of p_commit.
    --
    IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
    END IF;
    --
    -- Standard call to get message count and if count is 1, get message info.
    --
    FND_MSG_PUB.Count_And_Get (
      p_count                 => x_msg_count,
      p_data                  => x_msg_data
    );
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_outcome;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
        p_count                 => x_msg_count,
        p_data                  => x_msg_data
      );
    --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_outcome;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
        p_count                 => x_msg_count,
        p_data                  => x_msg_data
      );
    --
    WHEN OTHERS THEN
      ROLLBACK TO create_outcome;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --
      -- kdande; 02-Jan-2003; Bug# 2732568; Removed the call to
      -- FND_MSG_PUB.Add_Exc_Msg to avoid message repeatition.
      --
      FND_MSG_PUB.Count_And_Get (
        p_count                 => x_msg_count,
        p_data                  => x_msg_data
      );
  END create_outcome;

END igs_pr_prout_lgcy_pub;

/
