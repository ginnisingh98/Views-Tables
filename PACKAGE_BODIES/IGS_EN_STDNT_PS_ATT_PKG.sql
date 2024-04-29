--------------------------------------------------------
--  DDL for Package Body IGS_EN_STDNT_PS_ATT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_STDNT_PS_ATT_PKG" AS
/* $Header: IGSEI24B.pls 120.11 2006/06/29 09:58:09 shimitta ship $ */
    l_rowid VARCHAR2(25);
  old_references IGS_EN_STDNT_PS_ATT_ALL%ROWTYPE;
  new_references IGS_EN_STDNT_PS_ATT_ALL%ROWTYPE;

  TYPE g_prim_prg_record_type IS RECORD(career igs_ps_ver.course_type%TYPE,program_cd igs_ps_ver.course_cd%TYPE);
  TYPE g_prim_prg_rec_table_type IS TABLE OF g_prim_prg_record_type INDEX BY BINARY_INTEGER;
  g_primary_prg_rec g_prim_prg_rec_table_type;
  g_old_key_prg igs_ps_ver.course_cd%TYPE;
  g_primary_prg_rec_count NUMBER;
  g_sec_to_prim_first BOOLEAN;

  PROCEDURE beforerowdelete;
  PROCEDURE AfterRowInsertUpdate5(
      p_inserting IN BOOLEAN,
      p_updating IN BOOLEAN,
      p_deleting IN BOOLEAN
      ) ;
  PROCEDURE enrp_ins_upd_term_rec(P_ACTION IN VARCHAR2);

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_org_id IN NUMBER,
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2,
    x_coo_id IN NUMBER,
    x_student_confirmed_ind IN VARCHAR2,
    x_commencement_dt IN DATE,
    x_course_attempt_status IN VARCHAR2,
    x_progression_status IN VARCHAR2,
    x_derived_att_type IN VARCHAR2,
    x_derived_att_mode IN VARCHAR2,
    x_provisional_ind IN VARCHAR2,
    x_discontinued_dt IN DATE,
    x_discontinuation_reason_cd IN VARCHAR2,
    x_lapsed_dt IN DATE,
    x_funding_source IN VARCHAR2,
    x_exam_location_cd IN VARCHAR2,
    x_derived_completion_yr IN NUMBER,
    x_derived_completion_perd IN VARCHAR2,
    x_nominated_completion_yr IN NUMBER,
    x_nominated_completion_perd IN VARCHAR2,
    x_rule_check_ind IN VARCHAR2,
    x_waive_option_check_ind IN VARCHAR2,
    x_last_rule_check_dt IN DATE,
    x_publish_outcomes_ind IN VARCHAR2,
    x_course_rqrmnt_complete_ind IN VARCHAR2,
    x_course_rqrmnts_complete_dt IN DATE,
    x_s_completed_source_type IN VARCHAR2,
    x_override_time_limitation IN NUMBER,
    x_advanced_standing_ind IN VARCHAR2,
    x_fee_cat IN VARCHAR2,
    x_correspondence_cat IN VARCHAR2,
    x_self_help_group_ind IN VARCHAR2,
    x_logical_delete_dt IN DATE,
    x_adm_admission_appl_number IN NUMBER,
    x_adm_nominated_course_cd IN VARCHAR2,
    x_adm_sequence_number IN NUMBER,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_last_date_of_attendance IN DATE,
    x_dropped_by    IN VARCHAR2,
    x_igs_pr_class_std_id IN NUMBER,
    x_primary_program_type IN VARCHAR2,
    x_primary_prog_type_source IN VARCHAR2,
    x_catalog_cal_type IN VARCHAR2,
    x_catalog_seq_num  IN NUMBER  ,
    x_key_program      IN VARCHAR2,
    x_manual_ovr_cmpl_dt_ind IN VARCHAR2,
    x_override_cmpl_dt       IN DATE    ,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    x_future_dated_trans_flag In VARCHAR2
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    ROWID = x_rowid;
  BEGIN

    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    /**********************************************************************************************/
    old_references.commencement_dt            := TRUNC(old_references.commencement_dt);
    old_references.discontinued_dt            := TRUNC(old_references.discontinued_dt);
    old_references.lapsed_dt                  := TRUNC(old_references.lapsed_dt);
    old_references.last_rule_check_dt         := TRUNC(old_references.last_rule_check_dt);
    old_references.course_rqrmnts_complete_dt := TRUNC(old_references.course_rqrmnts_complete_dt);
    old_references.logical_delete_dt          := TRUNC(old_references.logical_delete_dt);
    old_references.override_cmpl_dt           := TRUNC(old_references.override_cmpl_dt);
    old_references.last_date_of_attendance    := TRUNC(old_references.last_date_of_attendance);
    /************************************************************************************************/

    -- Populate New Values.
    -- Populate New Values.
        -- When the update row of the TBH is called the org_id column is not passed as parameter
        -- and the before_dml procedure accpets the parameter as default hence it comes into this
        -- procedure as null. The new_references.org_id is passed to the
        -- igs_pe_typ_instances_pkg.insert_row call ( which null and not correct)
        -- Hence modified the condition to pick up the old_references.org_id value if the
        -- action was update and the x_org_id parameter value is null
        -- amuthu
        IF p_action = 'UPDATE' AND x_org_id IS NULL THEN
          new_references.org_id := old_references.org_id;
        ELSE
         new_references.org_id := x_org_id;
        END IF;
        new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.location_cd := x_location_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.attendance_type := x_attendance_type;
    new_references.coo_id := x_coo_id;
    new_references.student_confirmed_ind := x_student_confirmed_ind;
    new_references.commencement_dt := TRUNC(x_commencement_dt);
    new_references.course_attempt_status := x_course_attempt_status;
    new_references.progression_status := x_progression_status;
    new_references.derived_att_type := x_derived_att_type;
    new_references.derived_att_mode := x_derived_att_mode;
    new_references.provisional_ind := x_provisional_ind;
    new_references.discontinued_dt := TRUNC(x_discontinued_dt);
    new_references.discontinuation_reason_cd := x_discontinuation_reason_cd;
    new_references.lapsed_dt := TRUNC(x_lapsed_dt);
    new_references.funding_source := x_funding_source;
    new_references.exam_location_cd := x_exam_location_cd;
    new_references.derived_completion_yr := x_derived_completion_yr;
    new_references.derived_completion_perd := x_derived_completion_perd;
    new_references.nominated_completion_yr := x_nominated_completion_yr;
    new_references.nominated_completion_perd := x_nominated_completion_perd;
    new_references.rule_check_ind := x_rule_check_ind;
    new_references.waive_option_check_ind := x_waive_option_check_ind;
    new_references.last_rule_check_dt := TRUNC(x_last_rule_check_dt);
    new_references.publish_outcomes_ind := x_publish_outcomes_ind;
    new_references.course_rqrmnt_complete_ind := x_course_rqrmnt_complete_ind;
    new_references.course_rqrmnts_complete_dt := TRUNC(x_course_rqrmnts_complete_dt);
    new_references.s_completed_source_type := x_s_completed_source_type;
    new_references.override_time_limitation := x_override_time_limitation;
    new_references.advanced_standing_ind := x_advanced_standing_ind;
    new_references.fee_cat := x_fee_cat;
    new_references.correspondence_cat := x_correspondence_cat;
    new_references.self_help_group_ind := x_self_help_group_ind;
    new_references.logical_delete_dt := TRUNC(x_logical_delete_dt);
    new_references.adm_admission_appl_number := x_adm_admission_appl_number;
    new_references.adm_nominated_course_cd := x_adm_nominated_course_cd;
    new_references.adm_sequence_number := x_adm_sequence_number;
    new_references.attribute_category := x_attribute_category;
    new_references.future_dated_trans_flag := x_future_dated_trans_flag;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
    new_references.last_date_of_attendance:=TRUNC(x_last_date_of_attendance);
    new_references.dropped_by:=x_dropped_by;
    new_references.IGS_PR_CLASS_STD_ID := X_IGS_PR_CLASS_STD_ID;

    --added by amuthu for career impact dld
    -- smaddali modified the logic for populating primary_program_type and source for bug#4240694
    -- In program mode these two fields should be populated with NULL
    IF FND_PROFILE.VALUE('CAREER_MODEL_ENABLED') = 'Y' THEN
        new_references.primary_program_type := X_PRIMARY_PROGRAM_TYPE;
        new_references.primary_prog_type_source := X_PRIMARY_PROG_TYPE_SOURCE;
    ELSE
        new_references.primary_program_type := NULL;
        new_references.primary_prog_type_source := NULL;
    END IF;

    new_references.catalog_cal_type := X_CATALOG_CAL_TYPE;
    new_references.catalog_seq_num := X_CATALOG_SEQ_NUM;
    new_references.key_program := NVL(X_KEY_PROGRAM,'N');
    -- added by ayedubat for ENCR015 DLD
    new_references.manual_ovr_cmpl_dt_ind := X_MANUAL_OVR_CMPL_DT_IND;
    new_references.override_cmpl_dt := TRUNC(X_OVERRIDE_CMPL_DT);

  END Set_Column_Values;


  -- Created By : jbegum
  -- Created for : Enhancement Bug #1832130
  -- This procedure gets the last date of attendance
  -- Last date of attendance is date till which student has active unit attempts associated with that program attempt

  PROCEDURE Get_Last_Dt_Of_Att (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_last_date_of_attendance OUT NOCOPY DATE
    ) AS

    CURSOR cur_unit_atmpt_dis IS
      SELECT   cal_type,ci_sequence_number,discontinued_dt
      FROM     IGS_EN_SU_ATTEMPT
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      discontinued_dt IS NOT NULL
      ORDER BY discontinued_dt DESC;

    CURSOR cur_term_cal(p_cal_type VARCHAR2,p_ci_sequence_number NUMBER, p_discontinued_dt DATE) IS
      SELECT   *
      FROM     IGS_CA_TEACH_TO_LOAD_V
      WHERE    teach_cal_type = p_cal_type
      AND      teach_ci_sequence_number = p_ci_sequence_number
      AND      load_start_dt <= TRUNC(p_discontinued_dt)
      ORDER BY load_start_dt DESC;

    CURSOR cur_unit_atmpt_grd IS
      SELECT   cal_type,ci_sequence_number
      FROM     IGS_EN_SU_ATTEMPT
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      unit_attempt_status='COMPLETED';


    CURSOR cur_term_cal_grd(p_cal_type VARCHAR2,p_ci_sequence_number NUMBER) IS
      SELECT   *
      FROM     IGS_CA_TEACH_TO_LOAD_V
      WHERE    teach_cal_type = p_cal_type
      AND      teach_ci_sequence_number = p_ci_sequence_number
      ORDER BY load_end_dt DESC;

    lv_cal_type IGS_CA_TEACH_TO_LOAD_V.teach_cal_type%TYPE;
    lv_ci_sequence_number IGS_CA_TEACH_TO_LOAD_V.teach_ci_sequence_number%TYPE;
    lv_discontinued_dt IGS_EN_SU_ATTEMPT.discontinued_dt%TYPE;

    cur_unit_atmpt_dis_rec cur_unit_atmpt_dis%ROWTYPE;
    cur_term_cal_rec cur_term_cal%ROWTYPE;
    cur_unit_atmpt_grd_rec cur_unit_atmpt_grd%ROWTYPE;
    cur_term_cal_grd_rec cur_term_cal_grd%ROWTYPE;

  BEGIN

    OPEN cur_unit_atmpt_dis;
    FETCH cur_unit_atmpt_dis INTO cur_unit_atmpt_dis_rec;

    IF cur_unit_atmpt_dis%FOUND THEN

         lv_cal_type := cur_unit_atmpt_dis_rec.cal_type;
         lv_ci_sequence_number := cur_unit_atmpt_dis_rec.ci_sequence_number;
         lv_discontinued_dt := cur_unit_atmpt_dis_rec.discontinued_dt;
         CLOSE cur_unit_atmpt_dis;


         OPEN cur_term_cal(lv_cal_type,lv_ci_sequence_number,lv_discontinued_dt);
         FETCH cur_term_cal INTO cur_term_cal_rec;
         IF (cur_term_cal%FOUND) THEN

             x_last_date_of_attendance := lv_discontinued_dt;
             CLOSE cur_term_cal;
         ELSE
             CLOSE cur_term_cal;
             lv_discontinued_dt := NULL;

             FOR cur_unit_atmpt_grd_rec IN cur_unit_atmpt_grd
             LOOP

                  OPEN cur_term_cal_grd(cur_unit_atmpt_grd_rec.cal_type,cur_unit_atmpt_grd_rec.ci_sequence_number);
                  FETCH cur_term_cal_grd INTO cur_term_cal_grd_rec;

                  IF (cur_term_cal_grd%FOUND) THEN

                        IF lv_discontinued_dt IS NULL THEN
                             lv_discontinued_dt := cur_term_cal_grd_rec.load_end_dt;
                        ELSIF lv_discontinued_dt < cur_term_cal_grd_rec.load_end_dt THEN
                             lv_discontinued_dt := cur_term_cal_grd_rec.load_end_dt;
                        END IF;
                  END IF;
                  CLOSE cur_term_cal_grd;
              END LOOP;

              x_last_date_of_attendance := lv_discontinued_dt;
         END IF;

    ELSE

        CLOSE cur_unit_atmpt_dis;
        lv_discontinued_dt := NULL;

        FOR cur_unit_atmpt_grd_rec IN cur_unit_atmpt_grd
        LOOP

           OPEN cur_term_cal_grd(cur_unit_atmpt_grd_rec.cal_type,cur_unit_atmpt_grd_rec.ci_sequence_number);
           FETCH cur_term_cal_grd INTO cur_term_cal_grd_rec;

           IF (cur_term_cal_grd%FOUND) THEN

              IF lv_discontinued_dt IS NULL THEN
                 lv_discontinued_dt := cur_term_cal_grd_rec.load_end_dt;
              ELSIF lv_discontinued_dt < cur_term_cal_grd_rec.load_end_dt THEN
                 lv_discontinued_dt := cur_term_cal_grd_rec.load_end_dt;
              END IF;

              CLOSE cur_term_cal_grd;

           END IF;

         END LOOP;

         x_last_date_of_attendance := lv_discontinued_dt;


    END IF;

  END Get_Last_Dt_Of_Att;

  -- Created By : jbegum
  -- Created for : Enhancement Bug #1832130
  -- This procedure gets the dropped by value
  -- Dropped by is the person type of the person who discontinued the last enrolled unit attempt associated with that program attempt

  PROCEDURE Get_Dropped_By (
  x_course_cd IN VARCHAR2,
  x_dropped_by OUT NOCOPY VARCHAR2
  ) AS

  CURSOR cur_per_type IS

      SELECT   person_type_code
      FROM     IGS_PE_PERSON_TYPES_V
      WHERE    system_type = 'STAFF';

  BEGIN

    x_dropped_by := igs_en_gen_008.enrp_get_person_type(x_course_cd);

    IF x_dropped_by IS NULL THEN
       OPEN cur_per_type;
       FETCH cur_per_type INTO x_dropped_by;
       CLOSE cur_per_type;
    END IF;

  END Get_Dropped_By;

  -- Trigger description :-
  -- "OSS_TST".trg_sca_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_EN_STDNT_PS_ATT
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
        v_message_name                VARCHAR2(30);
        v_course_attempt_status   IGS_EN_STDNT_PS_ATT_ALL.course_attempt_status%TYPE;
        l_last_date_of_attendance IGS_EN_STDNT_PS_ATT_ALL.last_date_of_attendance%TYPE;
        l_dropped_by              IGS_EN_STDNT_PS_ATT_ALL.dropped_by%TYPE;
        v_course_type             IGS_PS_TYPE.COURSE_TYPE%TYPE;

    CURSOR c_course_type IS
          SELECT crv.course_type
          FROM igs_ps_ver crv
          WHERE course_cd = new_references.course_cd
          and version_number = new_references.version_number;

  BEGIN

        -- If trigger has not been disabled, perform required processing
        IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_EN_STDNT_PS_ATT_ALL') THEN
                -- Set course_offering_option key.
                IF p_inserting THEN
                        IGS_PS_GEN_003.CRSP_GET_COO_KEY (
                                new_references.coo_id,
                                new_references.course_cd,
                                new_references.version_number,
                                new_references.cal_type,
                                new_references.location_cd,
                                new_references.attendance_mode,
                                new_references.attendance_type);
                END IF;
                IF p_updating AND
                  ( (old_references.lapsed_dt IS NOT NULL AND
                      new_references.lapsed_dt IS NULL) OR
                    (old_references.lapsed_dt IS NULL AND
                     new_references.lapsed_dt IS NOT NULL) OR
                    (old_references.lapsed_dt <> new_references.lapsed_dt)) THEN
                        -- Validate the lapsed date against the course attempt status and the
                        -- permitted dates.

                        IF Igs_En_Val_Sca.enrp_val_sca_lapse(
                                        new_references.course_attempt_status,
                                        new_references.lapsed_dt,
                                        v_message_name,
                                        'N') = FALSE THEN
                                fnd_message.set_name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                app_exception.raise_exception;
                        END IF;

                END IF;
                IF p_updating THEN
                        IF  (old_references.attendance_type <> new_references.attendance_type) AND
                             (old_references.student_confirmed_ind = new_references.student_confirmed_ind)
                        THEN
                                -- Save the rowid so that candidature attendance history can be inserted
                                -- for change of attendance type
                                IF IGS_EN_GEN_009.ENRP_INS_SCA_CAH(
                                OLD_references.person_id,
                                OLD_references.course_cd,
                                OLD_references.student_confirmed_ind,
                                OLD_references.commencement_dt,
                                OLD_references.attendance_type,
                                v_message_name) = FALSE THEN
                                fnd_message.set_name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                app_exception.raise_exception;
                        END IF;
                END IF;

        END IF;
                IF p_inserting OR p_updating THEN
                                                -- Validate confirming an admission course transfer
                        IF p_inserting OR
                          (p_updating AND
                           new_references.student_confirmed_ind <> old_references.student_confirmed_ind) THEN
                                IF Igs_En_Val_Sca.enrp_val_trnsfr_acpt(
                                        neW_references.person_id,
                                        new_references.course_cd,
                                        new_references.student_confirmed_ind,
                                        new_references.adm_admission_appl_number,
                                        new_references.adm_nominated_course_cd,
                                        NULL,
                                        v_message_name) = FALSE THEN
                                fnd_message.set_name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                app_exception.raise_exception;
                                END IF;
                        END IF;
                        -- Validate discontinuation details
                        IF p_inserting OR
                           (p_updating AND
                           ((new_references.discontinued_dt IS NULL AND
                              old_references.discontinued_dt IS NOT NULL) OR
                            (new_references.discontinued_dt IS NOT NULL AND
                             old_references.discontinued_dt IS NULL) OR
                            (new_references.discontinued_dt IS NOT NULL AND
                             old_references.discontinued_dt <>new_references.discontinued_dt))) THEN
                                IF Igs_En_Val_Sca.enrp_val_sca_discont(
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.version_number,
                                        new_references.course_attempt_status,
                                        new_references.discontinuation_reason_cd,
                                        new_references.discontinued_dt,
                                        new_references.commencement_dt,
                                        v_message_name,
                                        'N') = FALSE THEN
                                fnd_message.set_name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                app_exception.raise_exception;
                                END IF;
                        END IF;
                        -- Validate discontinuation reason code
                        IF p_inserting OR
                           (p_updating AND
                           ((new_references.discontinuation_reason_cd  IS NULL AND
                              old_references.discontinuation_reason_cd  IS NOT NULL) OR
                            (new_references.discontinuation_reason_cd  IS NOT NULL AND
                             old_references.discontinuation_reason_cd  IS NULL) OR
                            (new_references.discontinuation_reason_cd  IS NOT NULL AND
                             old_references.discontinuation_reason_cd <> new_references.discontinuation_reason_cd))) THEN
                                IF Igs_En_Val_Sca.enrp_val_sca_dr(
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.discontinuation_reason_cd,
                                        new_references.discontinued_dt,
                                        v_message_name,
                                        'N') = FALSE THEN
                                fnd_message.set_name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                app_exception.raise_exception;
                                END IF;
                        END IF;
                        -- Validate completing the course
                        IF p_inserting OR
                          (p_updating AND
                           new_references.course_rqrmnt_complete_ind <> old_references.course_rqrmnt_complete_ind) THEN
                              IF new_references.course_rqrmnt_complete_ind = 'Y' THEN
                                -- Validate that SCA Status is not 'COMPLETED' or 'UNCONFIRM'.
                                IF new_references.course_attempt_status IN ('COMPLETED','UNCONFIRM') THEN
                                        Fnd_Message.set_name('IGS','IGS_PR_CANNOT_SET_COMPL_IND');
                                        IGS_GE_MSG_STACK.ADD;
                                        App_Exception.Raise_exception;
                                END IF;
                                -- Validate that no unit sets are incomplete or un-ended.
                                IF IGS_PR_VAL_SCA.prgp_val_susa_cmplt (
                                        new_references.person_id,
                                        new_references.course_cd,
                                        v_message_name) = FALSE THEN
                                fnd_message.set_name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                app_exception.raise_exception;
                                END IF;


                                -- Validate that status is not DISCONTIN, INTERMIT or LAPSED.  If so, the
                                -- course requirements complete indicator cannot be set.
                                IF new_references.course_attempt_status = 'DISCONTIN' THEN
                                        Fnd_Message.set_name('IGS','IGS_PR_DISCON_DT_BE_LIFTED');
                                        IGS_GE_MSG_STACK.ADD;
                                        App_Exception.Raise_exception;
                                ELSIF new_references.course_attempt_status = 'LAPSED' THEN
                                        Fnd_Message.set_name('IGS','IGS_PR_LAPSED_DT_BE_LIFTED');
                                        IGS_GE_MSG_STACK.ADD;
                                        App_Exception.Raise_exception;
                                ELSIF new_references.course_attempt_status = 'INTERMIT' THEN
                                        Fnd_Message.set_name('IGS','IGS_PR_INTERMISSION_BE_LIFTED');
                                        IGS_GE_MSG_STACK.ADD;
                                        App_Exception.Raise_exception;
                                END IF;
                              ELSE
                                -- Check that associated IGS_GR_GRADUAND record does not have a status
                                -- of 'GRADUATED' or 'SURRENDER'.
                                IF IGS_PR_VAL_SCA.prgp_val_undo_cmpltn (
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.version_number,
                                        NULL,
                                        NULL,
                                        v_message_name) = FALSE THEN
                                fnd_message.set_name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                app_exception.raise_exception;
                                END IF;
                            END IF;
                        END IF;
                        -- Validate the IGS_EN_STDNT_PS_ATT_ALL.course_rqrmnts_complete_dt
                        IF p_inserting OR
                          (p_updating AND
                           ((new_references.course_rqrmnts_complete_dt  IS NULL AND
                              old_references.course_rqrmnts_complete_dt  IS NOT NULL) OR
                            (new_references.course_rqrmnts_complete_dt  IS NOT NULL AND
                             old_references.course_rqrmnts_complete_dt  IS NULL) OR
                            (new_references.course_rqrmnts_complete_dt  IS NOT NULL AND
                           new_references.course_rqrmnts_complete_dt <> old_references.course_rqrmnts_complete_dt))) THEN
                                IF IGS_PR_VAL_SCA.prgp_val_sca_cmpl_dt (
                                                new_references.person_id,
                                                new_references.course_cd,
                                                new_references.commencement_dt,
                                                new_references.course_rqrmnts_complete_dt,
                                                v_message_name,
                                                'N') = FALSE THEN
                                fnd_message.set_name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                app_exception.raise_exception;
                                END IF;
                        END IF;
                        -- Validate fee category is open
                        IF p_inserting OR
                          (p_updating AND
                           new_references.fee_cat <> old_references.fee_cat) THEN
                                IF Igs_ad_Val_fcm.finp_val_fc_closed(
                                        new_references.fee_cat,
                                        v_message_name) = FALSE THEN
                                fnd_message.set_name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                app_exception.raise_exception;
                                END IF;
                        END IF;
                        -- Set course attempt status
                        IF new_references.course_attempt_status IS NULL THEN
                                v_course_attempt_status  := 'UNKNOWN';
                        ELSE
                                v_course_attempt_status := new_references.course_attempt_status;
                        END IF;

                      IF (NOT IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml)    THEN
                        IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'N'
                            OR new_references.primary_program_type = 'PRIMARY' THEN
                             new_references.course_attempt_status :=
                                       IGS_EN_GEN_006.ENRP_GET_SCA_STATUS(
                                        new_references.person_id,
                                        new_references.course_cd,
                                        v_course_attempt_status,
                                        new_references.student_confirmed_ind,
                                        new_references.discontinued_dt,
                                        new_references.lapsed_dt,
                                        new_references.course_rqrmnt_complete_ind,
                                        new_references.logical_delete_dt);
                        ELSIF new_references.course_attempt_status IN ('INACTIVE','ENROLLED','LAPSED','INTERMIT') THEN
                               OPEN c_course_type;
                               FETCH c_course_type INTO v_course_type;
                               CLOSE c_course_type;
                                               new_references.course_attempt_status :=
                                                igs_en_career_model.enrp_get_sec_sca_status( new_references.person_id ,
                                                                    new_references.course_cd ,
                                                                    new_references.course_attempt_status,
                                                                    new_references.primary_program_type ,
                                                                    new_references.primary_prog_type_source,
                                                                        v_course_type ,
                                                                        NULL);
                               IF new_references.course_attempt_status IS NULL THEN
                                      new_references.course_attempt_status :=
                                        IGS_EN_GEN_006.ENRP_GET_SCA_STATUS(
                                          new_references.person_id,
                                          new_references.course_cd,
                                          v_course_attempt_status,
                                          new_references.student_confirmed_ind,
                                          new_references.discontinued_dt,
                                          new_references.lapsed_dt,
                                          new_references.course_rqrmnt_complete_ind,
                                          new_references.logical_delete_dt);
                                           END IF;
                           ELSE
                                                   new_references.course_attempt_status :=
                                        IGS_EN_GEN_006.ENRP_GET_SCA_STATUS(
                                          new_references.person_id,
                                          new_references.course_cd,
                                          v_course_attempt_status,
                                          new_references.student_confirmed_ind,
                                          new_references.discontinued_dt,
                                          new_references.lapsed_dt,
                                          new_references.course_rqrmnt_complete_ind,
                                          new_references.logical_delete_dt);

                END IF;
               END IF;

                END IF;
        END IF;

        -- Created By : jbegum
        -- Created for : Enhancement Bug #1832130
        -- When the program attempt status changes from ENROLLED to INACTIVE , INTERMIT , LAPSED , DISCONTIN
        -- Compute values for fields Last_date_of_attendance and dropped_by before updating the record in the
        -- table IGS_EN_STDNT_PS_ATT_ALL

        IF p_updating AND old_references.course_attempt_status= 'ENROLLED'
                      AND new_references.course_attempt_status IN ('INACTIVE','INTERMIT','LAPSED','DISCONTIN') THEN

           Get_Last_Dt_Of_Att (new_references.person_id,new_references.course_cd,l_last_date_of_attendance);
           Get_Dropped_By (new_references.course_cd,l_dropped_by);

           new_references.last_date_of_attendance := l_last_date_of_attendance;
           new_references.dropped_by := l_dropped_by;


        END IF;

        --sanity check to ensure that the course_attempt_status is never null.

        IF p_inserting OR p_updating THEN
           IF new_references.course_attempt_status IS NULL THEN
                                      new_references.course_attempt_status :=
                                        IGS_EN_GEN_006.ENRP_GET_SCA_STATUS(
                                          new_references.person_id,
                                          new_references.course_cd,
                                          v_course_attempt_status,
                                          new_references.student_confirmed_ind,
                                          new_references.discontinued_dt,
                                          new_references.lapsed_dt,
                                          new_references.course_rqrmnt_complete_ind,
                                          new_references.logical_delete_dt);
            END IF;
         END IF;
  END BeforeRowInsertUpdate1;
  -- Trigger description :-
  -- "OSS_TST".trg_sca_br_iud_fin
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_EN_STDNT_PS_ATT
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
        v_sequence_number       NUMBER;
  BEGIN
        -- Log an entry in the IGS_PE_STD_TODO table, indicating that a fee re-assessment
        -- is required.
        IF p_inserting OR p_updating THEN
                v_sequence_number := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(
                                        new_references.person_id,
                                        'FEE_RECALC',
                                        SYSDATE,
                                        'Y');
        ELSE
                v_sequence_number := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(
                                        old_references.person_id,
                                        'FEE_RECALC',
                                        SYSDATE,
                                        'Y');
        END IF;

        IF p_updating THEN
           IF new_references.student_confirmed_ind = 'Y'
             AND old_references.future_dated_trans_flag = 'C'
             AND new_references.future_dated_trans_flag NOT IN ('Y','S' )THEN
                        new_references.future_dated_trans_flag := 'N';
           END IF;
        END IF;

  END BeforeRowInsertUpdateDelete2;

  -- Trigger description :-
  -- "OSS_TST".trg_sca_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_EN_STDNT_PS_ATT
  -- FOR EACH ROW
  PROCEDURE AfterRowInsertUpdate3(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
        v_message_name          VARCHAR2(30);
        v_save_row              BOOLEAN := FALSE;
        r_sca                   IGS_EN_STDNT_PS_ATT_ALL%ROWTYPE;
  BEGIN
        -- mutating table validations / end of processing activities
        -- If trigger has not been disabled, perform required processing
        IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_EN_STDNT_PS_ATT_ALL') THEN
                IF(p_updating AND
                    old_references.student_confirmed_ind = 'N' AND
                    new_references.student_confirmed_ind = 'Y') OR
                   (p_inserting AND
                    new_references.student_confirmed_ind = 'Y') THEN
                        -- update of application response status on confirming the offer
                        v_save_row := TRUE;
                        r_sca.student_confirmed_ind := old_references.student_confirmed_ind;
                END IF;
                -- validate fee category
                IF p_inserting OR
                        (p_updating AND
                        new_references.fee_cat <> old_references.fee_cat) THEN
                        v_save_row := TRUE;
                        r_sca.fee_cat := old_references.fee_cat;
            END IF;
              IF v_save_row = TRUE THEN
                        r_sca.person_id := new_references.person_id;
                        r_sca.course_cd := new_references.course_cd;

                -- a validation to check whether the fee category which is being updated is used for any fee assessment.
                -- in case assessment record exists for this program attempt then the fee categoryu could not be changed
                -- removed call to procedure Igs_En_Val_Sca.enrp_val_sca_fc.
                -- this validation has been removed as a requirement for the fee calc build (bug# 1851586)


                -- Update the offer response status/date
                IF(p_updating AND
                    old_references.student_confirmed_ind = 'N' AND
                    new_references.student_confirmed_ind = 'Y') OR
                   (p_inserting AND
                    new_references.student_confirmed_ind = 'Y') THEN
                        IF Igs_En_Gen_011.ENRP_UPD_ACAI_ACCEPT(
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.adm_admission_appl_number,
                                        new_references.adm_nominated_course_cd,
                                        new_references.adm_sequence_number,
                                        v_message_name) = FALSE THEN
                                fnd_message.set_name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                app_exception.raise_exception;
                       END IF;
                END IF;
              END IF;
          END IF;

  END AfterRowInsertUpdate3;

   PROCEDURE AfterRowInsertUpdate5(
      p_inserting IN BOOLEAN,
      p_updating IN BOOLEAN,
      p_deleting IN BOOLEAN
      ) AS

    BEGIN

    -- Bug # 2829275 . UK Correspondence. The TBH needs to be modified to so that the program discontinuation event is raised when the program attempt is changed .


     IF ( p_updating
         AND ((new_references.location_cd <> old_references.location_cd)
           OR (new_references.attendance_mode <> old_references.attendance_mode)
           OR (new_references.attendance_type <> old_references.attendance_type)
           OR (new_references.cal_type <> old_references.cal_type))) THEN


               igs_en_workflow.progofropt_event (
                                p_personid          => new_references.person_id,
                                p_programcd         => new_references.course_cd,
                                p_locationcd        => new_references.location_cd,
                                p_prev_location_cd  => old_references.location_cd,
                                p_attndmode         => new_references.attendance_mode,
                                p_prev_attndmode    => old_references.attendance_mode,
                                p_attndtype         => new_references.attendance_type,
                                p_prev_attndtype    => old_references.attendance_type

                            ) ;

     END IF;

     IF (( (new_references.location_cd <> old_references.location_cd)
      OR (new_references.attendance_mode <> old_references.attendance_mode)
      OR (new_references.attendance_type <> old_references.attendance_type))
      AND (new_references.key_program = old_references.key_program)
      AND (new_references.key_program = 'Y' ) ) THEN
        igf_aw_coa_gen.ins_coa_todo(p_person_id => new_references.person_id ,
                                     p_calling_module => 'IGSEI24B',
                                     p_program_code => new_references.course_cd,
                                     p_version_number=>new_references.version_number) ;
     END IF;

    END AfterRowInsertUpdate5;

   -- This has been added for bug# 1516605
   -- Changing the Person Type Based on The Program Attempt Status


   PROCEDURE AfterRowInsertUpdate4(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
   /*  HISTORY
    -- who              when                  what
    --ayedubat         09-JUL-2002     Added a new cursor,cur_pe_typ_inst to consider the active person type records
    --                                 of a student program which are mapped to a closed system type.
    --                                 Check whenther the cursor is fetching a record whenever a person type record of a particular
    --                                 system type should be end dated and if found, call the TBH to end date the record for the bug:2389552
    --ayedubat        2nd MAY 2002     Added the code for p_inseting = TRUE as part of the bug fix:2344079
    --                                 This will change the Person_Type from Applicant to Student during the pre_enrollment process
    --                                 through admissions subsystem.
    --shimitta          29 JUNE 2006 Modified l_method acording as bug# 2691653
   */
   --modified cursor for perf bug 3696781
      CURSOR cur_typ_id_inst(p_PERSON_ID NUMBER,p_COURSE_CD VARCHAR2,p_PERSON_TYPE_CODE VARCHAR2) IS
        SELECT pti.*
        FROM igs_pe_typ_instances_all  pti
        WHERE pti.PERSON_ID = p_PERSON_ID AND
              pti.COURSE_CD = p_COURSE_CD AND
              pti.PERSON_TYPE_CODE = p_PERSON_TYPE_CODE AND
              pti.END_DATE IS NULL;

      CURSOR cur_pers_type(p_system_type varchar2) IS
        SELECT PERSON_TYPE_CODE
        FROM igs_pe_person_types
        WHERE SYSTEM_TYPE = p_system_type AND
              CLOSED_IND = 'N';

      -- Cursor used to fetch the Person Type Instance record which is being opened
      -- irrespective of the system person type is closed or not.
      -- Cursor is being created for the bug fix: 2389552
      CURSOR cur_pe_typ_inst( p_person_id   igs_pe_typ_instances.PERSON_ID%TYPE,
                              p_course_cd   igs_pe_typ_instances.course_cd%TYPE,
                              p_system_type igs_pe_person_types.SYSTEM_TYPE%TYPE) IS
        SELECT pti.rowid row_id ,pti.*
        FROM  igs_pe_typ_instances_all pti,
              igs_pe_person_types  pty
        WHERE pti.person_id = p_person_id AND
              pti.course_cd = p_course_cd AND
              pti.end_date IS NULL        AND
              pty.person_type_code = pti.person_type_code AND
              pty.system_type = p_system_type;

       CURSOR cur_find_interm(cp_perosn_id igs_pe_person.person_id%TYPE,
                               cp_course_cd igs_ps_ver.course_cd%TYPE) IS
            SELECT  sci.person_id,sci.course_cd,start_dt, sci.end_dt, sci.voluntary_ind,sci.comments ,sci.created_by ,sci.creation_date ,
                   sci.last_updated_by ,sci.last_update_date , sci.last_update_login , sci.intermission_type , sci.approved ,sci.institution_name,
                   sci.max_credit_pts, sci.max_terms, sci.anticipated_credit_points, sci.approver_id
            FROM  igs_en_stdnt_ps_intm sci,
                  igs_en_intm_types eit
            WHERE sci.course_cd = cp_course_cd
            AND   sci.person_id = cp_perosn_id
            AND   sci.approved  = eit.appr_reqd_ind
            AND   eit.intermission_type = sci.intermission_type
            AND   sci.logical_delete_date = TO_DATE ('31-12-4712','DD-MM-YYYY');



      CURSOR cur_re_canditure(cp_person_id igs_pe_person.person_id%TYPE,
                              cp_course_cd igs_ps_ver.course_cd%TYPE) IS
            SELECT  1
            FROM  igs_re_candidature
            WHERE sca_course_cd = cp_course_cd
            AND   person_id = cp_person_id ;



      cur_pe_typ_inst_rec cur_pe_typ_inst%ROWTYPE;

            v_message_name              VARCHAR2(30);
        v_save_row              BOOLEAN := FALSE;
        r_sca                   IGS_EN_STDNT_PS_ATT_ALL%ROWTYPE;
        l_method         igs_pe_typ_instances.CREATE_METHOD%TYPE;
        l_person_type igs_pe_person_types.PERSON_TYPE_CODE%TYPE;
      l_rowid  VARCHAR2(25);
      l_TYPE_INSTANCE_ID  igs_pe_typ_instances.TYPE_INSTANCE_ID%TYPE;
      cur_typ_id_inst_rec cur_typ_id_inst%ROWTYPE;
      l_cur_find_interm cur_find_interm%ROWTYPE;
      ln_cur_re_canditure NUMBER;

    BEGIN

      IF p_inserting THEN

        IF new_references.course_attempt_status = 'INACTIVE' THEN

           l_person_type := NULL;
           -- Select Person type Code for the System type FORMER_STUDENT
           OPEN cur_pers_type('APPLICANT');
           FETCH cur_pers_type INTO l_person_type;
           CLOSE cur_pers_type;
           IF l_person_type IS NULL THEN
              Fnd_Message.Set_Name ('IGS', 'IGS_EN_PERSON_TYPE_NOT_DEF');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
           END IF;

           l_method := 'PERSON_ENROL_UNIT_SECT';

           -- Check any active record found for this student program, with System Person Type,APPLICANT
           -- This should be considered the active applicants(i.e not end dated) whose system person type is closed
           OPEN cur_pe_typ_inst( new_references.person_id,
                                 new_references.course_cd,
                                 'APPLICANT' );
           FETCH cur_pe_typ_inst INTO cur_pe_typ_inst_rec;
           IF cur_pe_typ_inst%FOUND THEN

              igs_pe_typ_instances_pkg.update_row(
                X_ROWID                 => cur_pe_typ_inst_rec.ROW_ID,
                X_PERSON_ID             => cur_pe_typ_inst_rec.PERSON_ID,
                X_COURSE_CD             => cur_pe_typ_inst_rec.COURSE_CD,
                X_TYPE_INSTANCE_ID      => cur_pe_typ_inst_rec.TYPE_INSTANCE_ID,
                X_PERSON_TYPE_CODE      => cur_pe_typ_inst_rec.PERSON_TYPE_CODE,
                X_CC_VERSION_NUMBER     => cur_pe_typ_inst_rec.CC_VERSION_NUMBER,
                X_FUNNEL_STATUS         => cur_pe_typ_inst_rec.FUNNEL_STATUS,
                X_ADMISSION_APPL_NUMBER => cur_pe_typ_inst_rec.ADMISSION_APPL_NUMBER,
                X_NOMINATED_COURSE_CD   => cur_pe_typ_inst_rec.NOMINATED_COURSE_CD,
                X_NCC_VERSION_NUMBER    => cur_pe_typ_inst_rec.NCC_VERSION_NUMBER,
                X_SEQUENCE_NUMBER       => cur_pe_typ_inst_rec.SEQUENCE_NUMBER,
                X_START_DATE            => cur_pe_typ_inst_rec.START_DATE,
                X_END_DATE              => SYSDATE,
                X_CREATE_METHOD         => cur_pe_typ_inst_rec.CREATE_METHOD,
                X_ENDED_BY              => cur_pe_typ_inst_rec.ENDED_BY,
                X_END_METHOD            => l_method,
                X_MODE                  => 'R' ,
                X_EMPLMNT_CATEGORY_CODE => cur_pe_typ_inst_rec.emplmnt_category_code );

           END IF;
           CLOSE cur_pe_typ_inst;

           l_person_type := NULL;
           -- Select Person type Code for the System type STUDENT
           OPEN cur_pers_type('STUDENT');
           FETCH cur_pers_type INTO l_person_type;
           CLOSE cur_pers_type;
           IF l_person_type IS NULL THEN
              Fnd_Message.Set_Name ('IGS', 'IGS_EN_PERSON_TYPE_NOT_DEF');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
           END IF;

           OPEN cur_typ_id_inst(new_references.PERSON_ID,new_references.COURSE_CD,l_person_type);
           FETCH cur_typ_id_inst INTO cur_typ_id_inst_rec;
           IF cur_typ_id_inst%NOTFOUND THEN
              igs_pe_typ_instances_pkg.insert_row(
                X_ROWID  => l_ROWID,
                X_PERSON_ID => new_references.PERSON_ID,
                X_COURSE_CD => new_references.COURSE_CD,
                X_TYPE_INSTANCE_ID => l_TYPE_INSTANCE_ID,
                X_PERSON_TYPE_CODE => l_person_type,
                X_CC_VERSION_NUMBER => NULL,
                X_FUNNEL_STATUS => NULL,
                X_ADMISSION_APPL_NUMBER => NULL,
                X_NOMINATED_COURSE_CD => NULL,
                X_NCC_VERSION_NUMBER => NULL,
                X_SEQUENCE_NUMBER => NULL,
                X_START_DATE => SYSDATE,
                X_END_DATE => NULL,
                X_CREATE_METHOD => l_method,
                X_ENDED_BY => NULL,
                X_END_METHOD => NULL,
                X_MODE => 'R',
                X_ORG_ID => new_references.ORG_ID                ,
                X_EMPLMNT_CATEGORY_CODE => NULL
                        );
           END IF;
           CLOSE cur_typ_id_inst;

        END IF;


      ELSIF p_updating THEN

        IF new_references.course_attempt_status IN ('ENROLLED','INACTIVE') AND
           new_references.course_attempt_status <> old_references.course_attempt_status THEN

             l_person_type := NULL;

             -- Select Person type Code for the System type FORMER_STUDENT
             OPEN cur_pers_type('FORMER_STUDENT');
             FETCH cur_pers_type INTO l_person_type;
             CLOSE cur_pers_type;
             IF l_person_type IS NULL THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_EN_PERSON_TYPE_NOT_DEF');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
             END IF;

             l_method := 'PERSON_ENROL_UNIT_SECT';

           -- Check any active record found for this student program, with System Person Type,FORMER_STUDENT
           -- This should be considered the active former students (i.e not end dated) whose system person type is closed
           OPEN cur_pe_typ_inst( new_references.person_id,
                                 new_references.COURSE_CD,
                                 'FORMER_STUDENT');

           FETCH cur_pe_typ_inst INTO cur_pe_typ_inst_rec;

           IF cur_pe_typ_inst%FOUND THEN

             l_method := 'PERSON_ENROLL_PRG';

             igs_pe_typ_instances_pkg.update_row(
                X_ROWID                 => cur_pe_typ_inst_rec.ROW_ID,
                X_PERSON_ID             => cur_pe_typ_inst_rec.PERSON_ID,
                X_COURSE_CD             => cur_pe_typ_inst_rec.COURSE_CD,
                X_TYPE_INSTANCE_ID      => cur_pe_typ_inst_rec.TYPE_INSTANCE_ID,
                X_PERSON_TYPE_CODE      => cur_pe_typ_inst_rec.PERSON_TYPE_CODE,
                X_CC_VERSION_NUMBER     => cur_pe_typ_inst_rec.CC_VERSION_NUMBER,
                X_FUNNEL_STATUS         => cur_pe_typ_inst_rec.FUNNEL_STATUS,
                X_ADMISSION_APPL_NUMBER => cur_pe_typ_inst_rec.ADMISSION_APPL_NUMBER,
                X_NOMINATED_COURSE_CD   => cur_pe_typ_inst_rec.NOMINATED_COURSE_CD,
                X_NCC_VERSION_NUMBER    => cur_pe_typ_inst_rec.NCC_VERSION_NUMBER,
                X_SEQUENCE_NUMBER       => cur_pe_typ_inst_rec.SEQUENCE_NUMBER,
                X_START_DATE            => cur_pe_typ_inst_rec.START_DATE,
                X_END_DATE              => SYSDATE,
                X_CREATE_METHOD         => cur_pe_typ_inst_rec.CREATE_METHOD,
                X_ENDED_BY              => cur_pe_typ_inst_rec.ENDED_BY,
                X_END_METHOD            => l_method,
                X_MODE                  => 'R' ,
                X_EMPLMNT_CATEGORY_CODE => cur_pe_typ_inst_rec.emplmnt_category_code);
           END IF;
           CLOSE cur_pe_typ_inst;

           l_person_type := NULL;
           -- Select Person type Code for the System type STUDENT
           OPEN cur_pers_type('STUDENT');
           FETCH cur_pers_type INTO l_person_type;
           CLOSE cur_pers_type;
           IF l_person_type IS NULL THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_EN_PERSON_TYPE_NOT_DEF');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
             END IF;

             OPEN cur_typ_id_inst(new_references.PERSON_ID,new_references.COURSE_CD,l_person_type);
             FETCH cur_typ_id_inst INTO cur_typ_id_inst_rec;
             IF cur_typ_id_inst%NOTFOUND THEN
                 igs_pe_typ_instances_pkg.insert_row(
                                                X_ROWID  => l_ROWID,
                                                X_PERSON_ID => new_references.PERSON_ID,
                                                X_COURSE_CD => new_references.COURSE_CD,
                                                X_TYPE_INSTANCE_ID => l_TYPE_INSTANCE_ID,
                                                X_PERSON_TYPE_CODE => l_person_type,
                                                X_CC_VERSION_NUMBER => NULL,
                                                X_FUNNEL_STATUS => NULL,
                                                X_ADMISSION_APPL_NUMBER => NULL,
                                                X_NOMINATED_COURSE_CD => NULL,
                                                X_NCC_VERSION_NUMBER => NULL,
                                                X_SEQUENCE_NUMBER => NULL,
                                                X_START_DATE => SYSDATE,
                                                X_END_DATE => NULL,
                                                X_CREATE_METHOD => l_method,
                                                X_ENDED_BY => NULL,
                                                X_END_METHOD => NULL,
                                                X_MODE => 'R',
                                                X_ORG_ID => new_references.ORG_ID,
                                                X_EMPLMNT_CATEGORY_CODE => NULL
                                                );
           END IF;
           CLOSE cur_typ_id_inst;

        ELSIF old_references.course_attempt_status IN ('ENROLLED','INACTIVE') AND
              new_references.course_attempt_status IN ('LAPSED','COMPLETED','DISCONTIN') THEN
                IF new_references.course_attempt_status = 'LAPSED' THEN
                   l_method := 'PRG_ATTMPT_ST_LAPSED';
                ELSIF new_references.course_attempt_status = 'DISCONTIN' THEN
                   l_method := 'PERSON_DISCONTINUE_PRG';
--                ElsIf new_references.course_attempt_status = 'COMPLETED' Then
--                   l_method := '';
                END IF;

             l_person_type := NULL;
             -- Select Person type Code for the System type STUDENT
             OPEN cur_pers_type('STUDENT');
             FETCH cur_pers_type INTO l_person_type;
             CLOSE cur_pers_type;
             IF l_person_type IS NULL THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_EN_PERSON_TYPE_NOT_DEF');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
                   END IF;

             -- Check any active record found for this student program, with System Person Type,STUDENT
             -- This should be considered the active students (i.e not end dated) whose system person type is closed
             OPEN cur_pe_typ_inst( new_references.person_id,
                                   new_references.COURSE_CD,
                                   'STUDENT' );
             FETCH cur_pe_typ_inst INTO cur_pe_typ_inst_rec;
             IF cur_pe_typ_inst%FOUND THEN

               l_method := 'PERSON_NO_ENROLL_PRG';

               igs_pe_typ_instances_pkg.update_row(
                  X_ROWID                 => cur_pe_typ_inst_rec.ROW_ID,
                  X_PERSON_ID             => cur_pe_typ_inst_rec.PERSON_ID,
                  X_COURSE_CD             => cur_pe_typ_inst_rec.COURSE_CD,
                  X_TYPE_INSTANCE_ID      => cur_pe_typ_inst_rec.TYPE_INSTANCE_ID,
                  X_PERSON_TYPE_CODE      => cur_pe_typ_inst_rec.PERSON_TYPE_CODE,
                  X_CC_VERSION_NUMBER     => cur_pe_typ_inst_rec.CC_VERSION_NUMBER,
                  X_FUNNEL_STATUS         => cur_pe_typ_inst_rec.FUNNEL_STATUS,
                  X_ADMISSION_APPL_NUMBER => cur_pe_typ_inst_rec.ADMISSION_APPL_NUMBER,
                  X_NOMINATED_COURSE_CD   => cur_pe_typ_inst_rec.NOMINATED_COURSE_CD,
                  X_NCC_VERSION_NUMBER    => cur_pe_typ_inst_rec.NCC_VERSION_NUMBER,
                  X_SEQUENCE_NUMBER       => cur_pe_typ_inst_rec.SEQUENCE_NUMBER,
                  X_START_DATE            => cur_pe_typ_inst_rec.START_DATE,
                  X_END_DATE              => SYSDATE,
                  X_CREATE_METHOD         => cur_pe_typ_inst_rec.CREATE_METHOD,
                  X_ENDED_BY              => cur_pe_typ_inst_rec.ENDED_BY,
                  X_END_METHOD            => l_method,
                  X_MODE                  => 'R' ,
                  X_EMPLMNT_CATEGORY_CODE => cur_pe_typ_inst_rec.emplmnt_category_code);
             END IF;
             CLOSE cur_pe_typ_inst;

             l_person_type := NULL;
             -- Select Person type Code for the System type FORMER_STUDENT
             OPEN cur_pers_type('FORMER_STUDENT');
             FETCH cur_pers_type INTO l_person_type;
             CLOSE cur_pers_type;
             IF l_person_type IS NULL THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_EN_PERSON_TYPE_NOT_DEF');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
             END IF;

             OPEN cur_typ_id_inst(new_references.PERSON_ID,new_references.COURSE_CD,l_person_type);
             FETCH cur_typ_id_inst INTO cur_typ_id_inst_rec;
             IF cur_typ_id_inst%NOTFOUND THEN
                igs_pe_typ_instances_pkg.insert_row(
                                                X_ROWID  => l_ROWID,
                                                X_PERSON_ID => new_references.PERSON_ID,
                                                X_COURSE_CD => new_references.COURSE_CD,
                                                X_TYPE_INSTANCE_ID => l_TYPE_INSTANCE_ID,
                                                X_PERSON_TYPE_CODE => l_person_type,
                                                X_CC_VERSION_NUMBER => NULL,
                                                X_FUNNEL_STATUS => NULL,
                                                X_ADMISSION_APPL_NUMBER => NULL,
                                                X_NOMINATED_COURSE_CD => NULL,
                                                X_NCC_VERSION_NUMBER => NULL,
                                                X_SEQUENCE_NUMBER => NULL,
                                                X_START_DATE => SYSDATE,
                                                X_END_DATE => NULL,
                                                X_CREATE_METHOD => l_method,
                                                X_ENDED_BY => NULL,
                                                X_END_METHOD => NULL,
                                                X_MODE => 'R',
                                                X_ORG_ID => new_references.ORG_ID,
                                                X_EMPLMNT_CATEGORY_CODE => NULL
                                                );
             END IF;
             CLOSE cur_typ_id_inst;
        END IF;

   -- Bug # 2829275 . UK Correspondence. The business event is raised when the program is DISCONTINUED.

          IF ( new_references.course_attempt_status <> old_references.course_attempt_status AND  new_references.course_attempt_status = 'DISCONTIN') THEN

           igs_en_workflow.progdiscont_event(
                                p_personid      => new_references.person_id ,
                                p_programcd     => new_references.course_cd ,
                                p_discontindt   => new_references.discontinued_dt,
                                p_discontincd   => new_references.discontinuation_reason_cd
                                   );
           IF NVL(old_references.key_program,'N') = 'Y' THEN
              igf_aw_coa_gen.ins_coa_todo(
                          p_person_id => new_references.person_id ,
                          p_calling_module => 'IGSEI24B_D',
                          p_program_code => new_references.course_cd,
                          p_version_number => new_references.version_number) ;
           END IF;

          END IF;

  -- Bug # 2829275 . UK Correspondence. The business event is raised when the program is DISCONTINUED.

          IF ( new_references.course_attempt_status <> old_references.course_attempt_status AND  new_references.course_attempt_status = 'INTERMIT') THEN


             OPEN cur_find_interm(new_references.person_id,new_references.course_cd);
             FETCH cur_find_interm INTO l_cur_find_interm;
             CLOSE cur_find_interm;

             IF ( l_cur_find_interm.start_dt <> SYSDATE AND l_cur_find_interm.creation_date <> SYSDATE ) THEN

              igs_en_workflow.intermission_event(
                                 p_personid         => l_cur_find_interm.person_id,
                                 p_program_cd       => l_cur_find_interm.course_cd,
                                 p_intmtype         => l_cur_find_interm.intermission_type,
                                 p_startdt          => l_cur_find_interm.start_dt,
                                 p_enddt            => l_cur_find_interm.end_dt ,
                                 p_inst_name        => l_cur_find_interm.institution_name,
                                 p_max_cp           => l_cur_find_interm.max_credit_pts ,
                                 p_max_term         => l_cur_find_interm.max_terms ,
                                 p_anti_cp          => l_cur_find_interm.anticipated_credit_points ,
                                 p_approver         => l_cur_find_interm.approver_id
                                          );

            END IF;
       END IF;

  -- The changes are done as per the Enrollments Notifications TD Bug # 3052429
  -- Workflow notification is send if :
  -- 1. The program status changed from UNCONFIRM to INACTIVE
  -- 2. If there is a corresponding record exist in IGS_RE_CANDIDATURE


         IF (     new_references.course_attempt_status <> old_references.course_attempt_status
             AND  new_references.course_attempt_status ='INACTIVE' AND old_references.course_attempt_status = 'UNCONFIRM') THEN

              OPEN cur_re_canditure(new_references.person_id,new_references.course_cd);
              FETCH cur_re_canditure INTO ln_cur_re_canditure;
              CLOSE cur_re_canditure;

              IF ( ln_cur_re_canditure = 1 ) THEN

                 igs_re_workflow.confirm_reg_event (
                            p_personid     =>  new_references.person_id ,
                            p_programcd    =>  new_references.course_cd ,
                            p_spa_start_dt =>  new_references.commencement_dt ,
                            p_prog_attempt_stat => new_references.course_attempt_status
                             );

              END IF;
          END IF;
      END IF;
END AfterRowInsertUpdate4;

  -- Trigger description :-
  -- "OSS_TST".trg_sca_ar_u_hist
  -- AFTER UPDATE
  -- ON IGS_EN_STDNT_PS_ATT
  -- FOR EACH ROW

  -- Modified By : jbegum
  -- Modified for : Enhancement Bug #1832130
  -- Added four new parameters to the function call IGS_EN_GEN_009.ENRP_INS_SCA_HIST
  -- new_references.last_date_of_attendance,
  -- old_references.last_date_of_attendance,
  -- new_references.dropped_by,
  -- old_references.dropped_by

  --bdeviset     09-NOV-2004	Bug#4000939 Modified AfterRowUpdate4.

  PROCEDURE AfterRowUpdate4(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS


  BEGIN
        -- create a history
        IGS_EN_GEN_009.ENRP_INS_SCA_HIST(
                old_references.person_id,
                old_references.course_cd,
                new_references.version_number,
                old_references.version_number,
                new_references.cal_type,
                old_references.cal_type,
                new_references.location_cd,
                old_references.location_cd,
                new_references.attendance_mode,
                old_references.attendance_mode,
                new_references.attendance_type,
                old_references.attendance_type,
                new_references.student_confirmed_ind,
                old_references.student_confirmed_ind,
                new_references.commencement_dt,
                old_references.commencement_dt,
                new_references.course_attempt_status,
                old_references.course_attempt_status,
                new_references.progression_status,
                old_references.progression_status,
                new_references.derived_att_type,
                old_references.derived_att_type,
                new_references.derived_att_mode,
                old_references.derived_att_mode,
                new_references.provisional_ind,
                old_references.provisional_ind,
                new_references.discontinued_dt,
                old_references.discontinued_dt,
                new_references.discontinuation_reason_cd,
                old_references.discontinuation_reason_cd,
                new_references.lapsed_dt,
                old_references.lapsed_dt,
                new_references.funding_source,
                old_references.funding_source,
                new_references.exam_location_cd,
                old_references.exam_location_cd,
                new_references.derived_completion_yr,
                old_references.derived_completion_yr,
                new_references.derived_completion_perd,
                old_references.derived_completion_perd,
                new_references.nominated_completion_yr,
                old_references.nominated_completion_yr,
                new_references.nominated_completion_perd,
                old_references.nominated_completion_perd,
                new_references.rule_check_ind,
                old_references.rule_check_ind,
                new_references.waive_option_check_ind,
                old_references.waive_option_check_ind,
                new_references.last_rule_check_dt,
                old_references.last_rule_check_dt,
                new_references.publish_outcomes_ind,
                old_references.publish_outcomes_ind,
                new_references.course_rqrmnt_complete_ind,
                old_references.course_rqrmnt_complete_ind,
                new_references.course_rqrmnts_complete_dt,
                old_references.course_rqrmnts_complete_dt,
                new_references.s_completed_source_type,
                old_references.s_completed_source_type,
                new_references.override_time_limitation,
                old_references.override_time_limitation,
                new_references.advanced_standing_ind,
                old_references.advanced_standing_ind,
                new_references.fee_cat,
                old_references.fee_cat,
                new_references.self_help_group_ind,
                old_references.self_help_group_ind,
                new_references.correspondence_cat,
                old_references.correspondence_cat,
                new_references.adm_admission_appl_number,
                old_references.adm_admission_appl_number,
                new_references.adm_nominated_course_cd,
                old_references.adm_nominated_course_cd,
                new_references.adm_sequence_number,
                old_references.adm_sequence_number,
                new_references.last_updated_by,
                old_references.last_updated_by,
                new_references.last_update_date,
                old_references.last_update_date,
                new_references.last_date_of_attendance,
                old_references.last_date_of_attendance,
                new_references.dropped_by,
                old_references.dropped_by ,
                new_references.primary_program_type ,
                old_references.primary_program_type  ,
                new_references.primary_prog_type_source ,
                old_references.primary_prog_type_source  ,
                new_references.catalog_cal_type ,
                old_references.catalog_cal_type ,
                new_references.catalog_seq_num ,
                old_references.catalog_seq_num  ,
                new_references.key_program ,
                old_references.key_program,
                new_references.override_cmpl_dt,
                old_references.override_cmpl_dt,
                new_references.manual_ovr_cmpl_dt_ind,
                old_references.manual_ovr_cmpl_dt_ind,
                new_references.coo_id,
                old_references.coo_id,
                new_references.igs_pr_class_std_id,
                old_references.igs_pr_class_std_id);




  END AfterRowUpdate4;

  -- Trigger description :-
  -- "OSS_TST".trg_sca_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_EN_STDNT_PS_ATT
  PROCEDURE Check_Constraints(
        Column_name IN VARCHAR2,
        Column_Value IN VARCHAR2
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-May-2002   removed upper check constraint on fee_cat column.bug#2344826.
  ||  kkillams        08-11-2002    Added check constraints for key_program,primary_program_type and
  ||                                primary_prog_type_source columns. Legacy Build Bug no: 2661533
  ----------------------------------------------------------------------------*/
  BEGIN
        IF column_name IS NULL THEN
              NULL;
        ELSIF UPPER(column_name) = 'NOMINATED_COMPLETION_YR' THEN
              new_references.nominated_completion_yr := igs_ge_number.to_num(column_value);
        ELSIF UPPER(column_name) = 'DERIVED_COMPLETION_PERD' THEN
              new_references.derived_completion_perd := column_value;
        ELSIF UPPER(column_name) = 'DERIVED_COMPLETION_YR' THEN
              new_references.derived_completion_yr := igs_ge_number.to_num(column_value);
        ELSIF UPPER(column_name) = 'PROVISIONAL_IND' THEN
              new_references.provisional_ind := column_value;
        ELSIF UPPER(column_name) = 'STUDENT_CONFIRMED_IND' THEN
              new_references.student_confirmed_ind := column_value;
        ELSIF UPPER(column_name) = 'ADM_NOMINATED_COURSE_CD' THEN
              new_references.adm_nominated_course_cd := column_value;
        ELSIF UPPER(column_name) = 'ADVANCED_STANDING_IND' THEN
              new_references.advanced_standing_ind := column_value;
        ELSIF UPPER(column_name) = 'ATTENDANCE_MODE' THEN
              new_references.attendance_mode := column_value;
        ELSIF UPPER(column_name) = 'ATTENDANCE_TYPE' THEN
              new_references.attendance_type := column_value;
        ELSIF UPPER(column_name) = 'CAL_TYPE' THEN
              new_references.cal_type := column_value;
        ELSIF UPPER(column_name) = 'CORRESPONDENCE_CAT' THEN
              new_references.correspondence_cat := column_value;
        ELSIF UPPER(column_name) = 'COURSE_ATTEMPT_STATUS' THEN
              new_references.course_attempt_status := column_value;
        ELSIF UPPER(column_name) = 'COURSE_CD' THEN
              new_references.course_cd := column_value;
        ELSIF UPPER(column_name) = 'COURSE_RQRMNT_COMPLETE_IND' THEN
              new_references.course_rqrmnt_complete_ind := column_value;
        ELSIF UPPER(column_name) = 'DERIVED_ATT_MODE' THEN
              new_references.derived_att_mode := column_value;
        ELSIF UPPER(column_name) = 'DERIVED_ATT_TYPE' THEN
              new_references.derived_att_type := column_value;
        ELSIF UPPER(column_name) = 'DERIVED_COMPLETION_PERD' THEN
              new_references.derived_completion_perd := column_value;
        ELSIF UPPER(column_name) = 'DISCONTINUATION_REASON_CD' THEN
              new_references.discontinuation_reason_cd := column_value;
        ELSIF UPPER(column_name) = 'EXAM_LOCATION_CD' THEN
              new_references.exam_location_cd := column_value;
        ELSIF UPPER(column_name) = 'FUNDING_SOURCE' THEN
              new_references.funding_source := column_value;
        ELSIF UPPER(column_name) = 'LOCATION_CD' THEN
              new_references.location_cd := column_value;
        ELSIF UPPER(column_name) = 'NOMINATED_COMPLETION_PERD' THEN
              new_references.nominated_completion_perd := column_value;
        ELSIF UPPER(column_name) = 'PUBLISH_OUTCOMES_IND' THEN
              new_references.publish_outcomes_ind := column_value;
        ELSIF UPPER(column_name) = 'RULE_CHECK_IND' THEN
              new_references.rule_check_ind := column_value;
        ELSIF UPPER(column_name) = 'SELF_HELP_GROUP_IND' THEN
              new_references.self_help_group_ind := column_value;
        ELSIF UPPER(column_name) = 'LOCATION_CD' THEN
              new_references.location_cd := column_value;
        ELSIF UPPER(column_name) = 'WAIVE_OPTION_CHECK_IND' THEN
              new_references.waive_option_check_ind := column_value;
        ELSIF UPPER(column_name) = 'ADM_SEQUENCE_NUMBER' THEN
              new_references.adm_sequence_number := igs_ge_number.to_num(column_value);
        ELSIF UPPER(column_name) = 'S_COMPLETED_SOURCE_TYPE' THEN
              new_references.s_completed_source_type := column_value;
        ELSIF UPPER(column_name) = 'PRIMARY_PROGRAM_TYPE' THEN
              new_references.primary_program_type := column_value;
        ELSIF UPPER(column_name) = 'OVERRIDE_TIME_LIMITATION' THEN
              new_references.override_time_limitation := igs_ge_number.to_num(column_value);
        ELSIF UPPER(column_name) = 'MANUAL_OVR_CMPL_DT_IND' THEN
              new_references.manual_ovr_cmpl_dt_ind := column_value;
        ELSIF UPPER(column_name) = 'KEY_PROGRAM' THEN
              new_references.key_program := column_value;
        ELSIF UPPER(column_name) = 'PRIMARY_PROG_TYPE_SOURCE' THEN
              new_references.primary_prog_type_source := column_value;
        END IF;

        IF UPPER(column_name) = 'KEY_PROGRAM' OR
               Column_name IS NULL THEN
               IF new_references.key_program   NOT  IN ( 'Y' , 'N')   THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'PRIMARY_PROG_TYPE_SOURCE' OR
               Column_name IS NULL THEN
               IF new_references.primary_prog_type_source   NOT  IN ( 'MANUAL' , 'SYSTEM')   THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'PRIMARY_PROGRAM_TYPE' OR
               Column_name IS NULL THEN
               IF new_references.primary_program_type   NOT  IN ( 'PRIMARY' , 'SECONDARY')   THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;

        IF UPPER(column_name) = 'NOMINATED_COMPLETION_YR' OR
               Column_name IS NULL THEN
               IF new_references.nominated_completion_yr  NOT BETWEEN 0 AND 9999  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'DERIVED_COMPLETION_PERD' OR
               Column_name IS NULL THEN
               IF new_references.derived_completion_perd NOT IN ( 'M' , 'E' , 'S' )  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'DERIVED_COMPLETION_YR' OR
               Column_name IS NULL THEN
               IF new_references.derived_completion_yr NOT BETWEEN 0 AND 9999  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'PROVISIONAL_IND' OR
               Column_name IS NULL THEN
               IF new_references.provisional_ind NOT IN ( 'Y' , 'N' )  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'STUDENT_CONFIRMED_IND' OR
               Column_name IS NULL THEN
               IF new_references.student_confirmed_ind NOT IN ( 'Y' , 'N' )  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'ADM_NOMINATED_COURSE_CD' OR
               Column_name IS NULL THEN
               IF new_references.adm_nominated_course_cd <>
                            UPPER(new_references.adm_nominated_course_cd)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'ADVANCED_STANDING_IND' OR
               Column_name IS NULL THEN
               IF new_references.advanced_standing_ind NOT IN ( 'Y' , 'N' )  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'ATTENDANCE_MODE' OR
               Column_name IS NULL THEN
               IF new_references.attendance_mode <>
                            UPPER(new_references.attendance_mode)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'ATTENDANCE_TYPE' OR
               Column_name IS NULL THEN
               IF new_references.attendance_type <>
                            UPPER(new_references.attendance_type)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'CAL_TYPE' OR
               Column_name IS NULL THEN
               IF new_references.cal_type <>
                            UPPER(new_references.cal_type)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'CORRESPONDENCE_CAT' OR
               Column_name IS NULL THEN
               IF new_references.correspondence_cat <>
                            UPPER(new_references.correspondence_cat)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'COURSE_ATTEMPT_STATUS' OR
               Column_name IS NULL THEN
               IF new_references.course_attempt_status <>
                            UPPER(new_references.course_attempt_status)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'COURSE_CD' OR
               Column_name IS NULL THEN
               IF new_references.course_cd <>
                            UPPER(new_references.course_cd)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'COURSE_RQRMNT_COMPLETE_IND' OR
               Column_name IS NULL THEN
               IF new_references.course_rqrmnt_complete_ind NOT IN ( 'Y' , 'N' )  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'DERIVED_ATT_MODE' OR
               Column_name IS NULL THEN
               IF new_references.derived_att_mode <>
                            UPPER(new_references.derived_att_mode)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'DERIVED_ATT_TYPE' OR
               Column_name IS NULL THEN
               IF new_references.derived_att_type <>
                            UPPER(new_references.derived_att_type)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'DERIVED_COMPLETION_PERD' OR
               Column_name IS NULL THEN
               IF new_references.derived_completion_perd <>
                            UPPER(new_references.derived_completion_perd)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'DISCONTINUATION_REASON_CD' OR
               Column_name IS NULL THEN
               IF new_references.discontinuation_reason_cd <>
                            UPPER(new_references.discontinuation_reason_cd)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'EXAM_LOCATION_CD' OR
               Column_name IS NULL THEN
               IF new_references.exam_location_cd <>
                            UPPER(new_references.exam_location_cd)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'FUNDING_SOURCE' OR
               Column_name IS NULL THEN
               IF new_references.funding_source <>
                            UPPER(new_references.funding_source)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'LOCATION_CD' OR
               Column_name IS NULL THEN
               IF new_references.location_cd <>
                            UPPER(new_references.location_cd)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        /* IF UPPER(column_name) = 'NOMINATED_COMPLETION_PERD' OR
               Column_name IS NULL THEN
               IF new_references.nominated_completion_perd NOT IN ( 'M' , 'E' , 'S' )  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;  */
        IF UPPER(column_name) = 'PUBLISH_OUTCOMES_IND' OR
               Column_name IS NULL THEN
               IF new_references.publish_outcomes_ind NOT IN ( 'Y' , 'N' )  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'RULE_CHECK_IND' OR
               Column_name IS NULL THEN
               IF new_references.rule_check_ind NOT IN ( 'Y' , 'N' )  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'SELF_HELP_GROUP_IND' OR
               Column_name IS NULL THEN
               IF new_references.self_help_group_ind NOT IN ( 'Y' , 'N' )  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'LOCATION_CD' OR
               Column_name IS NULL THEN
               IF new_references.location_cd <>
                            UPPER(new_references.location_cd)  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'WAIVE_OPTION_CHECK_IND' OR
               Column_name IS NULL THEN
               IF new_references.waive_option_check_ind NOT IN ( 'Y' , 'N' )  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'ADM_SEQUENCE_NUMBER' OR
               Column_name IS NULL THEN
               IF new_references.adm_sequence_number  NOT BETWEEN 1
              AND 999999  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'S_COMPLETED_SOURCE_TYPE ' OR
               Column_name IS NULL THEN
               IF new_references.s_completed_source_type   NOT  IN ( 'MANUAL' , 'SYSTEM')   THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'OVERRIDE_TIME_LIMITATION' OR
               Column_name IS NULL THEN
               IF new_references.override_time_limitation  NOT  BETWEEN 0 AND 9999  THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
        END IF;
        IF UPPER(column_name) = 'MANUAL_OVR_CMPL_DT_IND' OR
               Column_name IS NULL THEN
               IF new_references.manual_ovr_cmpl_dt_ind NOT IN ( 'Y' , 'N' )  THEN
                       Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
                       App_Exception.Raise_Exception;
               END IF;
        END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  amuthu          07-JAN-03       Added check for Nominated Completion Period
  ----------------------------------------------------------------------------*/
  BEGIN
    IF (((old_references.progression_status = new_references.progression_status)) OR
        ((new_references.progression_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation (
        'PROGRESSION_STATUS',
        new_references.progression_status
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.derived_att_mode = new_references.derived_att_mode)) OR
        ((new_references.derived_att_mode IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_MODE_PKG.Get_PK_For_Validation (
        new_references.derived_att_mode
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.course_attempt_status = new_references.course_attempt_status)) OR
        ((new_references.course_attempt_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation (
        'CRS_ATTEMPT_STATUS',
        new_references.course_attempt_status
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.adm_admission_appl_number = new_references.adm_admission_appl_number) AND
         (old_references.adm_nominated_course_cd = new_references.adm_nominated_course_cd) AND
         (old_references.adm_sequence_number = new_references.adm_sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.adm_admission_appl_number IS NULL) OR
         (new_references.adm_nominated_course_cd IS NULL) OR
         (new_references.adm_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_PS_APPL_INST_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.adm_admission_appl_number,
        new_references.adm_nominated_course_cd,
        new_references.adm_sequence_number
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.derived_att_type = new_references.derived_att_type)) OR
        ((new_references.derived_att_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_TYPE_PKG.Get_PK_For_Validation (
        new_references.derived_att_type
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF  ;
    END IF;


    IF (((old_references.correspondence_cat = new_references.correspondence_cat)) OR
        ((new_references.correspondence_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CO_CAT_PKG.Get_PK_For_Validation (
        new_references.correspondence_cat
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
       END IF;
    END IF;


    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.location_cd = new_references.location_cd) AND
         (old_references.attendance_mode = new_references.attendance_mode) AND
         (old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.location_cd IS NULL) OR
         (new_references.attendance_mode IS NULL) OR
         (new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSE

      IF NOT IGS_PS_OFR_OPT_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number,
        new_references.cal_type,
        new_references.location_cd,
        new_references.attendance_mode,
        new_references.attendance_type
        ) THEN

              Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
      END IF;

    END IF;

    -- prgoyal 21st May Bug 2383185
    IF (((old_references.coo_id = new_references.coo_id)) OR
          ((new_references.coo_id IS NULL))) THEN
        NULL;
      ELSE
        IF NOT  IGS_PS_OFR_OPT_PKG.Get_UK_For_Validation (
          new_references.coo_id
        ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
       END IF;
    END IF;

    IF (((old_references.discontinuation_reason_cd = new_references.discontinuation_reason_cd)) OR
        ((new_references.discontinuation_reason_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_DCNT_REASONCD_PKG.Get_PK_For_Validation (
        new_references.discontinuation_reason_cd
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_cat = new_references.fee_cat)) OR
        ((new_references.fee_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FEE_CAT_PKG.Get_PK_For_Validation (
        new_references.fee_cat
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF  ;
    END IF;
    IF (((old_references.funding_source = new_references.funding_source)) OR
        ((new_references.funding_source IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FUND_SRC_PKG.Get_PK_For_Validation (
        new_references.funding_source
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.exam_location_cd = new_references.exam_location_cd)) OR
        ((new_references.exam_location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.exam_location_cd,
        'N'
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((old_references.IGS_PR_CLASS_STD_ID = new_references.IGS_PR_CLASS_STD_ID)OR
        (new_references.IGS_PR_CLASS_STD_ID IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_CLASS_STD_PKG.Get_PK_For_Validation (
       new_references.IGS_PR_CLASS_STD_ID
       ) THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF ;
    END IF;

    IF ((old_references.NOMINATED_COMPLETION_PERD = new_references.NOMINATED_COMPLETION_PERD)OR
        (new_references.NOMINATED_COMPLETION_PERD IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_NOM_CMPL_PRD_PKG.Get_PK_For_Validation (
       new_references.NOMINATED_COMPLETION_PERD
       ) THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF ;
    END IF;

    IF (((old_references.PRIMARY_PROG_TYPE_SOURCE = new_references.PRIMARY_PROG_TYPE_SOURCE)) OR
        ((new_references.PRIMARY_PROG_TYPE_SOURCE IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation (
        'IGS_EN_PP_SOURCE',
        new_references.PRIMARY_PROG_TYPE_SOURCE
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
     END IF;

    IF (((old_references.CATALOG_CAL_TYPE = new_references.CATALOG_CAL_TYPE) AND
         (old_references.CATALOG_SEQ_NUM = new_references.CATALOG_SEQ_NUM)) OR
        ((new_references.CATALOG_CAL_TYPE IS NULL) OR
         (new_references.CATALOG_SEQ_NUM IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ca_Inst_Pkg.Get_PK_For_Validation (
                        new_references.CATALOG_CAL_TYPE,
                         new_references.CATALOG_SEQ_NUM
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;


  PROCEDURE Check_Child_Existance AS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --vchappid   25-Apr-2002     Bug#2329407, removed the call to IGS_FI_DSB_DTL_ALC_PKG.GET_FK_IGS_EN_STDNT_PS_ATT
  --                           as table IGS_FI_DSB_DTL_ALC is obsolete in the current fix
  --smadathi   22-Jan-2002     Bug No. 2170429.Removed references to IGS_FI_CRS_AT_F_SPN_PKG.GET_FK_IGS_EN_STDNT_PS_ATT
  --                           call as part of sponsorship DLD
  --pmarada   13-feb-2002      Added IGS_HE_ST_SPA_ALL_PKG.GET_UFK_IGS_EN_ST_PS_ATT_AL for HESA requirment.
  --nmankodi  04-Nov-2002      Added for Posting External Results TD
  --ckasu     04-Dec-2003      Added IGS_EN_SPA_TERMS_PKG.GET_FK_IGS_EN_STDNT_PS_ATT for Term Records Build
  -------------------------------------------------------------------


  BEGIN
    IGS_AD_PS_APPL_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_RE_CANDIDATURE_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_FI_FEE_AS_RT_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_GR_GRADUAND_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_PR_RU_APPL_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_GR_SPECIAL_AWARD_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_EN_STDNTPSHECSOP_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_EN_STDNT_PS_INTM_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_PS_STDNT_TRN_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_PS_STDNT_APV_ALT_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_AS_SC_ATMPT_ENR_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_AS_SC_ATMPT_NOTE_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_PR_SDT_PS_PR_MSR_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_PS_STDNT_SPL_REQ_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_PR_STDNT_PR_CK_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_EN_SU_ATTEMPT_H_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_EN_SU_ATTEMPT_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    IGS_AS_SU_SETATMPT_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    --Added as the following one as part of Term Record Build
    --Bug No# 2829263
    IGS_EN_SPA_TERMS_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
    --
    --  Next call added as per the UK Award Aims DLD.
    --
    igs_en_spa_awd_aim_pkg.get_fk_igs_en_stdnt_ps_att (
      old_references.person_id,
      old_references.course_cd
    );
    --
    --  Next call added as per the class Rank Build.
    --  Bug# 2639109

    igs_pr_cohinst_rank_pkg.get_fk_igs_en_stdnt_ps_att (
      old_references.person_id,
      old_references.course_cd
      );

    IGS_AS_ANON_ID_PS_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );

    IGS_AS_ANON_ID_US_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );

     -- Added the following check chaild existance for the HESA requirment, pmarada
    IGS_HE_ST_SPA_ALL_PKG.GET_FK_IGS_EN_STDNT_PS_ATT_ALL(
    old_references.person_id,
    old_references.course_cd);


     IGS_PR_STU_ACAD_STAT_PKG.GET_FK_IGS_EN_STDNT_PS_ATT (
      old_references.person_id,
      old_references.course_cd
      );
     IGS_EN_PLAN_UNITS_PKG.GET_FK_IGS_EN_STDNT_PS_ATT(
     old_references.person_id,
     old_references.course_cd
     );

  END Check_Child_Existance;


  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

  -- This function does the check to see whether the record for the
  -- mentioned PK exists. No lock is done on a record with a status
  -- other than that of status 'UNCONFIRM' since it is not deletable
  -- records with status UNCONFIRM deletable and hence they would
  -- need to be locked. Since this is the PK hence these columns
  -- cannot be updated.

    CURSOR cur_rec_exist IS
      SELECT course_attempt_status
      FROM igs_en_stdnt_ps_att_all
      WHERE person_id = x_person_id
      AND course_cd = x_course_cd;

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;
    lv_crs_att_status igs_en_stdnt_ps_att_all.course_attempt_status%TYPE;

  BEGIN

    -- Check whether a record exists for the mentioned PK and get
    -- ps attempt status.
    OPEN cur_rec_exist;
    FETCH cur_rec_exist INTO lv_crs_att_status;

    IF cur_rec_exist%FOUND THEN
    -- in this case the record exists for the mentioned PK

      IF lv_crs_att_status = 'UNCONFIRM' THEN

        -- In case the status is unconfirm then a lock is
        -- required on the record.
        OPEN cur_rowid;
        FETCH cur_rowid INTO lv_rowid;
        IF (cur_rowid%FOUND) THEN
          CLOSE cur_rowid;
          CLOSE cur_rec_exist;
          RETURN(TRUE);
        ELSE
          CLOSE cur_rowid;
          CLOSE cur_rec_exist;
          RETURN(FALSE);
        END IF;

      ELSE
        CLOSE cur_rec_exist;
        RETURN(TRUE);
      END IF;

    ELSE
      CLOSE cur_rec_exist;
      RETURN(FALSE);
    END IF;

  END Get_PK_For_Validation;


  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW_Prog (
    x_progression_status IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    progression_status = x_progression_status ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_LKUPV_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_LOOKUPS_VIEW_Prog;

  PROCEDURE GET_FK_IGS_EN_ATD_MODE (
    x_attendance_mode IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    derived_att_mode = x_attendance_mode ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_AM_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_EN_ATD_MODE;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW_CAS (
    x_course_attempt_status IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    course_attempt_status = x_course_attempt_status ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_LKUPV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_LOOKUPS_VIEW_CAS;

  PROCEDURE GET_FK_IGS_AD_PS_APPL_INST (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    person_id = x_person_id
      AND      adm_admission_appl_number = x_admission_appl_number
      AND      adm_nominated_course_cd = x_nominated_course_cd
      AND      adm_sequence_number = x_sequence_number ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_ACAI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_AD_PS_APPL_INST;

  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    derived_att_type = x_attendance_type ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_ATT_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_EN_ATD_TYPE;

  PROCEDURE GET_FK_IGS_CO_CAT (
    x_correspondence_cat IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    correspondence_cat = x_correspondence_cat ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_CC_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_CO_CAT;

  PROCEDURE GET_FK_IGS_PS_OFR_OPT (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      location_cd = x_location_cd
      AND      attendance_mode = x_attendance_mode
      AND      attendance_type = x_attendance_type ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_COO_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_PS_OFR_OPT;

  PROCEDURE GET_UFK_IGS_PS_OFR_OPT (
    x_coo_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    coo_id = x_coo_id;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
-- code modified by Nishikant - 13JUN2002 - as per bug#2413811
-- set the message IGS_EN_SCA_COO_FK instead of IGS_EN_SCA_COO_UFK
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_COO_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_UFK_IGS_PS_OFR_OPT;

   PROCEDURE GET_FK_IGS_PS_COURSE (
    x_course_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    course_cd = x_course_cd ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_CRS_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_PS_COURSE;

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_CRV_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_PS_VER;


  PROCEDURE GET_FK_IGS_FI_FEE_CAT (
    x_fee_cat IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    fee_cat = x_fee_cat ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_FC_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_FI_FEE_CAT;

  PROCEDURE GET_FK_IGS_FI_FUND_SRC (
    x_funding_source IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    funding_source = x_funding_source ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_FS_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_FI_FUND_SRC;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    exam_location_cd = x_location_cd ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_LOC_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_STDNT_PS_ATT_ALL
      WHERE    person_id = x_person_id ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_PE_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_PE_PERSON;

-- added as part of Enroll process Build for class standing dld
-- amuthu 30-JUL-2001
  PROCEDURE GET_FK_IGS_PR_CLASS_STD(
    X_IGS_PR_CLASS_STD_ID IN NUMBER
  ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM IGS_EN_STDNT_PS_ATT_ALL
          WHERE IGS_PR_CLASS_STD_ID = X_IGS_PR_CLASS_STD_ID;

        lv_cur cur_rowid%ROWTYPE;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_cur;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_PCS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_PR_CLASS_STD;


  PROCEDURE GET_FK_IGS_CA_INST (
    X_CATALOG_CAL_TYPE IN VARCHAR2,
    X_CATALOG_SEQ_NUM IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   IGS_EN_STDNT_PS_ATT_ALL
      WHERE  CATALOG_CAL_TYPE = X_CATALOG_CAL_TYPE
            AND  CATALOG_SEQ_NUM = X_CATALOG_SEQ_NUM  ;
    lv_rowid cur_rowid%ROWTYPE;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SCA_CI_FK');
      Igs_Ge_Msg_Stack.ADD;
      CLOSE cur_rowid;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_CA_INST;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_org_id IN NUMBER,
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2,
    x_coo_id IN NUMBER,
    x_student_confirmed_ind IN VARCHAR2,
    x_commencement_dt IN DATE,
    x_course_attempt_status IN VARCHAR2,
    x_progression_status IN VARCHAR2,
    x_derived_att_type IN VARCHAR2,
    x_derived_att_mode IN VARCHAR2,
    x_provisional_ind IN VARCHAR2,
    x_discontinued_dt IN DATE,
    x_discontinuation_reason_cd IN VARCHAR2,
    x_lapsed_dt IN DATE,
    x_funding_source IN VARCHAR2,
    x_exam_location_cd IN VARCHAR2,
    x_derived_completion_yr IN NUMBER,
    x_derived_completion_perd IN VARCHAR2,
    x_nominated_completion_yr IN NUMBER,
    x_nominated_completion_perd IN VARCHAR2,
    x_rule_check_ind IN VARCHAR2,
    x_waive_option_check_ind IN VARCHAR2,
    x_last_rule_check_dt IN DATE,
    x_publish_outcomes_ind IN VARCHAR2,
    x_course_rqrmnt_complete_ind IN VARCHAR2,
    x_course_rqrmnts_complete_dt IN DATE,
    x_s_completed_source_type IN VARCHAR2,
    x_override_time_limitation IN NUMBER,
    x_advanced_standing_ind IN VARCHAR2,
    x_fee_cat IN VARCHAR2,
    x_correspondence_cat IN VARCHAR2,
    x_self_help_group_ind IN VARCHAR2,
    x_logical_delete_dt IN DATE,
    x_adm_admission_appl_number IN NUMBER,
    x_adm_nominated_course_cd IN VARCHAR2,
    x_adm_sequence_number IN NUMBER,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_last_date_of_attendance IN DATE,
    x_dropped_by  IN VARCHAR2,
    x_igs_pr_class_std_id IN NUMBER,
    x_primary_program_type IN VARCHAR2,
    x_primary_prog_type_source IN VARCHAR2,
    x_catalog_cal_type IN VARCHAR2,
    x_catalog_seq_num IN NUMBER,
    x_key_program IN VARCHAR2,
    x_manual_ovr_cmpl_dt_ind IN VARCHAR2,
    x_override_cmpl_dt IN DATE,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    x_future_dated_trans_flag In VARCHAR2
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_person_id,
      x_course_cd,
      x_version_number,
      x_cal_type,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_coo_id,
      x_student_confirmed_ind,
      x_commencement_dt,
      x_course_attempt_status,
      x_progression_status,
      x_derived_att_type,
      x_derived_att_mode,
      x_provisional_ind,
      x_discontinued_dt,
      x_discontinuation_reason_cd,
      x_lapsed_dt,
      x_funding_source,
      x_exam_location_cd,
      x_derived_completion_yr,
      x_derived_completion_perd,
      x_nominated_completion_yr,
      x_nominated_completion_perd,
      x_rule_check_ind,
      x_waive_option_check_ind,
      x_last_rule_check_dt,
      x_publish_outcomes_ind,
      x_course_rqrmnt_complete_ind,
      x_course_rqrmnts_complete_dt,
      x_s_completed_source_type,
      x_override_time_limitation,
      x_advanced_standing_ind,
      x_fee_cat,
      x_correspondence_cat,
      x_self_help_group_ind,
      x_logical_delete_dt,
      x_adm_admission_appl_number,
      x_adm_nominated_course_cd,
      x_adm_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_last_date_of_attendance,
      x_dropped_by,
      X_IGS_PR_CLASS_STD_ID,
      x_primary_program_type,
      x_primary_prog_type_source,
      x_catalog_cal_type,
      x_catalog_seq_num,
      x_key_program,
      x_manual_ovr_cmpl_dt_ind,
      x_override_cmpl_dt,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_future_dated_trans_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE,
                               p_updating  => FALSE,
                               p_deleting  => FALSE);

      BeforeRowInsertUpdateDelete2 ( p_inserting => TRUE,
                                     p_updating  => FALSE,
                                     p_deleting  => FALSE);
      IF Get_PK_For_Validation(
        new_references.person_id ,
        new_references.course_cd
         ) THEN
         FND_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
                IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

      BeforeRowInsertUpdate1 ( p_inserting => FALSE,
                               p_updating  => TRUE,
                               p_deleting  => FALSE);

      BeforeRowInsertUpdateDelete2( p_inserting => FALSE,
                               p_updating  => TRUE,
                               p_deleting  => FALSE);

      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      beforerowdelete;
      BeforeRowInsertUpdateDelete2  ( p_inserting => FALSE,
                                      p_updating  => FALSE,
                                      p_deleting  => TRUE);
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation(
        new_references.person_id ,
        new_references.course_cd
         ) THEN
         FND_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

    -- call the before dml of igs_en_career_model package only if the global variable skip_before_after_dml
    -- is false . This variable will be made true in the after dml procedure of igs_en_career_model package
    -- to avoid calling before and after dml procedures during recursion of UPDATE_ROW call in the career package
    -- donot remove this condition ( included in career_impcat dld)
    IF (p_action in ('INSERT','UPDATE'))  AND  (NOT IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml) THEN


      IGS_EN_CAREER_MODEL.SCA_TBH_BEFORE_DML(
        p_person_id => new_references.person_id,
        p_course_cd => new_references.course_cd,
        p_version_number => new_references.version_number,
        p_old_course_attempt_status => old_references.course_attempt_status ,
        p_new_course_attempt_status => new_references.course_attempt_status ,
        p_primary_program_type => new_references.primary_program_type,
        p_primary_prog_type_source => new_references.primary_prog_type_source,
        p_new_key_program    => new_references.key_program
      );

        END IF;

  END Before_DML;


PROCEDURE AFTER_DML_RECURSIVE_CALLS(p_old_references        IGS_EN_STDNT_PS_ATT_ALL%ROWTYPE,
                                    p_new_references        IGS_EN_STDNT_PS_ATT_ALL%ROWTYPE,
                                    p_action                VARCHAR2,
                                    p_skip_before_after_dml BOOLEAN DEFAULT FALSE) IS

CURSOR cur_fut_dt_trnsf(cp_person_id     IGS_PS_STDNT_TRN.person_id%TYPE,
                        cp_program_cd    IGS_PS_STDNT_TRN.transfer_course_cd%TYPE) IS
			SELECT sct.course_cd,sct.effective_term_cal_type,sct.effective_term_sequence_num
			FROM   IGS_PS_STDNT_TRN sct, IGS_EN_STDNT_PS_ATT sca
			WHERE  sct.person_id = cp_person_id
			AND    sct.transfer_course_cd = cp_program_cd
			AND    sct.course_cd = sca.course_cd
			AND    sct.person_id = sca.person_id
			AND    sca.future_dated_trans_flag = 'Y';

v_eff_term_cal_type  IGS_PS_STDNT_TRN.effective_term_cal_type%TYPE;
v_eff_term_seq_num   IGS_PS_STDNT_TRN.effective_term_sequence_num%TYPE;
v_course_cd	     IGS_EN_STDNT_PS_ATT.course_cd%TYPE;
v_errbuf VARCHAR2(20);

BEGIN

    IF p_action = 'UPDATE' THEN

        -- When a program attempt is intermitted/discontinued/lapsed/unconfirmed and it is the source program for
        -- future dated program transfer then the future dated program transfer must be deleted
        IF (p_old_references.course_attempt_status IN ('ENROLLED','INACTIVE') AND
            p_new_references.course_attempt_status IN ('INTERMIT','DISCONTIN','LAPSED','UNCONFIRM')) THEN

    	   OPEN cur_fut_dt_trnsf(p_new_references.person_id, p_new_references.course_cd);

	       FETCH cur_fut_dt_trnsf INTO v_course_cd,v_eff_term_cal_type,v_eff_term_seq_num;

           IF cur_fut_dt_trnsf%FOUND THEN

        		IGS_EN_FUTURE_DT_TRANS.cleanup_dest_program (
                                     p_new_references.person_id,
	                                   v_course_cd,
                                 	   v_eff_term_cal_type,
                                     v_eff_term_seq_num,
                        					  'CLEANUP'
                    	     				  );

        		IGS_EN_FUTURE_DT_TRANS.cleanup_dest_program (
                                     p_new_references.person_id,
                                     v_course_cd,
                                     v_eff_term_cal_type,
                                     v_eff_term_seq_num,
                                     'DELETE'
                      				      );


           END IF;

	       CLOSE cur_fut_dt_trnsf;

        END IF;

    END IF;

    -- call the after dml of igs_en_career_model package only if the global variable skip_before_after_dml
    -- is false . This variable will be made true in the after dml procedure of igs_en_career_model package
    -- to avoid calling before and after dml procedures during recursion of UPDATE_ROW call in the career package
    -- donot remove this condition ( included in career_impcat dld)
    IF (p_action in ('INSERT','UPDATE'))   AND  (NOT p_skip_before_after_dml) THEN

            IGS_EN_CAREER_MODEL.SCA_TBH_AFTER_DML(
                        p_person_id => p_new_references.person_id,
                        p_course_cd => p_new_references.course_cd,
                        p_version_number => p_new_references.version_number,
                        p_old_course_attempt_status => p_old_references.course_attempt_status ,
                        p_new_course_attempt_status => p_new_references.course_attempt_status ,
                        p_primary_prog_type_source => p_new_references.primary_prog_type_source,
                        p_old_pri_prog_type => p_old_references.primary_program_type,
                        p_new_pri_prog_type => p_new_references.primary_program_type,
                        p_old_key_program  => p_old_references.key_program
                     );

    END IF;

END AFTER_DML_RECURSIVE_CALLS;


PROCEDURE After_DML (
    p_action         IN VARCHAR2,
    x_rowid          IN VARCHAR2
  ) AS
  -------------------------------------------------------------------------------
  -- Bug ID : UK AWARDS AIM DLD  (1366899)
  -- who              when                  what
  -- ayedubat        2nd MAY 2002           Added the call,AfterRowInsertUpdate4 while inserting a record as part of the bug fix:2344079
  --
  -- ayedubat        26th,Nov,2001          This procedure is modified to add a call
  --                                        to IGS_EN_GEN_009.ENRP_INS_AWARD_AIM Procedure
  --
  -- Prajeesh        11-Jun-2002            Added the Award Aim insert call in Both Insertrow and updaterow (2364445)
  -------------------------------------------------------------------------------
  -- Bug ID : 1818617
  -- who              when                  what
  -- sjadhav          jun 28,2001           this procedure is modified to trigger
  --                                        a Concurrent Request (IGFAPJ10) which
  --                                        will create a new record in IGF To
  --                                        Do table
  -- ptandon          28-Nov-2003           Included call to the enrp_ins_upd_term_rec
  --                                        procedure and modified the logic related to
  --                                        invocation of business event procedure.
  --                                        As per Term Based Fee Calc build.
  --                                        Enh. Bug# 2829263.
  -------------------------------------------------------------------------------

  -- Cursor to get the old key program for a student.
  CURSOR cur_get_course_cd_key(cp_person_id igs_en_stdnt_ps_att.person_id%TYPE,
                               cp_course_cd igs_en_stdnt_ps_att.course_cd%TYPE)
  IS
  SELECT course_cd
  FROM   igs_en_stdnt_ps_att
  WHERE  person_id = cp_person_id AND
         course_cd <> cp_course_cd AND
         key_program = 'Y';

  -- Cursor to get the Program Type/Career of a program version.
  CURSOR cur_get_prog_type(cp_course_cd igs_ps_ver.course_cd%TYPE,
                           cp_version_num igs_ps_ver.version_number%TYPE)
  IS
  SELECT course_type
  FROM   igs_ps_ver
  WHERE  course_cd = cp_course_cd AND
         version_number = cp_version_num;

  -- Cursor to get the old primary program in a given career for a student.
  CURSOR cur_get_course_cd_prim(cp_person_id igs_en_stdnt_ps_att.person_id%TYPE,
                                cp_course_cd igs_en_stdnt_ps_att.course_cd%TYPE,
                                cp_version_number igs_en_stdnt_ps_att.version_number%TYPE,
                                cp_course_type igs_ps_ver.course_type%TYPE)
  IS
  SELECT spa.course_cd
  FROM   igs_en_stdnt_ps_att spa,
         igs_ps_ver pv
  WHERE  spa.person_id = cp_person_id AND
         spa.course_cd <> cp_course_cd AND
         spa.primary_program_type = 'PRIMARY' AND
         spa.course_cd = pv.course_cd AND
         spa.version_number = pv.version_number AND
         pv.course_type = cp_course_type;

  -- bmerugu added for build 319 to get the secondary program attemps for student.
  CURSOR cur_pattempts(cp_person_id igs_en_stdnt_ps_att.person_id%TYPE, cp_course_type igs_ps_ver.course_type%TYPE)
  IS
  SELECT spa.person_id, spa.course_cd
  FROM   igs_en_stdnt_ps_att spa,
	 igs_ps_ver pv
  WHERE	 spa.person_id = cp_person_id AND
	 spa.primary_program_type = 'SECONDARY' AND
	 spa.course_cd = pv.course_cd AND
	 spa.version_number = pv.version_number AND
	 pv.course_type = cp_course_type;
  cur_pattempts_rec cur_pattempts%ROWTYPE;

  CURSOR cur_sua_uooid(cp_person_id igs_en_su_attempt_all.person_id%TYPE, cp_course_cd igs_en_su_attempt_all.course_cd%TYPE)
  IS
  SELECT sua.uoo_id
  FROM   igs_en_su_attempt_all sua
  WHERE	 sua.person_id = cp_person_id AND
	 sua.course_cd = cp_course_cd AND
	 sua.unit_attempt_status = 'UNCONFIRM';
  cur_sua_uooid_rec cur_sua_uooid%ROWTYPE;

  l_prog_type igs_ps_ver.course_type%TYPE;
  l_old_key_prg igs_ps_ver.course_cd%TYPE := NULL;
  l_old_prim_prog_cd igs_ps_ver.course_cd%TYPE;
  l_spa_term_cal_type igs_ca_inst.cal_type%TYPE;
  l_spa_term_sequence_number igs_ca_inst.sequence_number%TYPE;
  l_flag BOOLEAN;
  --bmerugu added for build 319 dummy variable to call del_sua_for_reopen
  l_delflag BOOLEAN;
  BEGIN

    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      AfterRowInsertUpdate3 ( p_inserting => TRUE,
                              p_updating  => FALSE,
                              p_deleting  => FALSE);

      AfterRowInsertUpdate4 ( p_inserting => TRUE,
                              p_updating  => FALSE,
                              p_deleting  => FALSE);
      --
      -- This Code is added as part of the 'UK AWARD AIMS' DLD.
      --
      -- Call to the Procedure ENRP_INS_AWARD_AIM of the Package IGS_EN_GEN_009
      -- to insert a record in Student Program Attempt Award Aim for each default Program Award found.
      IF NEW_REFERENCES.COMMENCEMENT_DT IS NOT NULL THEN
       IGS_EN_GEN_009.ENRP_INS_AWARD_AIM (
         p_person_id => NEW_REFERENCES.PERSON_ID,
         p_course_cd => NEW_REFERENCES.COURSE_CD,
         p_version_number => NEW_REFERENCES.VERSION_NUMBER,
         p_start_dt       =>nvl( NEW_REFERENCES.COMMENCEMENT_DT,sysdate)
        );
      END IF;
      --
      -- End of the Code added.

      enrp_ins_upd_term_rec(p_action);

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.

      AfterRowInsertUpdate3 ( p_inserting => FALSE,
                              p_updating  => TRUE,
                              p_deleting  => FALSE);

      AfterRowInsertUpdate4 ( p_inserting => FALSE,
                              p_updating  => TRUE,
                              p_deleting  => FALSE);

      AfterRowUpdate4 ( p_inserting => FALSE,
                        p_updating  => TRUE,
                        p_deleting  => FALSE);

      IF NEW_REFERENCES.COMMENCEMENT_DT IS NOT NULL THEN
        IGS_EN_GEN_009.ENRP_INS_AWARD_AIM (
         p_person_id => NEW_REFERENCES.PERSON_ID,
         p_course_cd => NEW_REFERENCES.COURSE_CD,
         p_version_number => NEW_REFERENCES.VERSION_NUMBER,
         p_start_dt       =>nvl( NEW_REFERENCES.COMMENCEMENT_DT,sysdate)
         );
      END IF;


     AfterRowInsertUpdate5 ( p_inserting => FALSE,
                              p_updating  => TRUE,
                              p_deleting  => FALSE);

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      NULL;
    END IF;

    IF (p_action = 'UPDATE') THEN

      l_spa_term_cal_type := igs_en_spa_terms_api.g_spa_term_cal_type;
      l_spa_term_sequence_number := igs_en_spa_terms_api.g_spa_term_sequence_number;

      -- Invoke the procedure to check whether to create/update the term record.
      enrp_ins_upd_term_rec(p_action);

      -- If an update is happening to the key program.
      IF NVL(new_references.key_program,'N') <> NVL(old_references.key_program,'N') THEN

         -- If the program attempt is being set as key.
         IF NVL(new_references.key_program,'N') = 'Y' AND NVL(old_references.key_program,'N') = 'N' THEN

            l_flag := FALSE;
            IF g_old_key_prg IS NULL THEN
               -- Get the old key program into g_old_key_prg global variable.
               OPEN cur_get_course_cd_key(new_references.person_id,new_references.course_cd);
               FETCH cur_get_course_cd_key INTO g_old_key_prg;
               CLOSE cur_get_course_cd_key;
               l_flag := TRUE;
            END IF;
            l_old_key_prg := g_old_key_prg;

            -- Raise the business event.
            IGS_EN_WLST_GEN_PROC.wf_inform_stud
               (p_person_id => new_references.person_id,
                p_program_cd => new_references.course_cd,
                p_version_number => new_references.version_number,
                p_program_attempt_status => new_references.course_attempt_status,
                p_org_id => new_references.org_id,
                p_old_key_program => g_old_key_prg,
                p_old_prim_program => NULL,
                p_load_cal_type => l_spa_term_cal_type,
                p_load_ci_seq_num => l_spa_term_sequence_number
               );

            -- Resetting the global variable.
            IF l_flag = TRUE THEN
               g_old_key_prg := '*';
            ELSE
               g_old_key_prg := NULL;
            END IF;

         -- The program attempt is being modified to not to be the key any longer then set the
         -- value of program code in the global variable g_old_key_prg.
         ELSE
            IF g_old_key_prg = '*' THEN
               g_old_key_prg := NULL;
            ELSE
               g_old_key_prg := new_references.course_cd;
               l_old_key_prg := g_old_key_prg;
            END IF;
         END IF;

       igf_aw_coa_gen.ins_coa_todo(
                    p_person_id => new_references.person_id ,
 		            p_calling_module => 'IGSEI24B',
                    p_program_code => new_references.course_cd,
                    p_version_number=> new_references.version_number) ;

      END IF;

      -- If an update is happening to the primary program type column.
      IF NVL(new_references.primary_program_type,'SECONDARY') <> NVL(old_references.primary_program_type,'SECONDARY') THEN

         -- Get the Program Type/Career for the program version.
         OPEN cur_get_prog_type(new_references.course_cd,new_references.version_number);
         FETCH cur_get_prog_type INTO l_prog_type;
         CLOSE cur_get_prog_type;

         IF g_primary_prg_rec_count IS NULL THEN
            g_primary_prg_rec_count := 0;
         END IF;

         -- If the program attempt is being set as Primary.
         IF NVL(new_references.primary_program_type,'SECONDARY') = 'PRIMARY' AND
            NVL(old_references.primary_program_type,'SECONDARY') = 'SECONDARY' THEN

            l_old_prim_prog_cd := NULL;

            -- Identify the old primary program by looping through the pl/sql table.
            FOR i IN 1..g_primary_prg_rec_count LOOP
                IF g_primary_prg_rec.exists(i) THEN
                   IF g_primary_prg_rec(i).career = l_prog_type THEN
                      l_old_prim_prog_cd := g_primary_prg_rec(i).program_cd;
                   END IF;
                END IF;
            END LOOP;

            l_flag := FALSE;
            -- If no matching record is found.
            IF l_old_prim_prog_cd IS NULL THEN
               -- Get the old primary program.
               OPEN cur_get_course_cd_prim(new_references.person_id,new_references.course_cd,new_references.version_number,l_prog_type);
               FETCH cur_get_course_cd_prim INTO l_old_prim_prog_cd;
               CLOSE cur_get_course_cd_prim;
               l_flag := TRUE;
            END IF;

            -- Raise the business event.
            IGS_EN_WLST_GEN_PROC.wf_inform_stud
               (p_person_id => new_references.person_id,
                p_program_cd => new_references.course_cd,
                p_version_number => new_references.version_number,
                p_program_attempt_status => new_references.course_attempt_status,
                p_org_id => new_references.org_id,
                p_old_key_program => l_old_key_prg,
                p_old_prim_program => l_old_prim_prog_cd,
                p_load_cal_type => l_spa_term_cal_type,
                p_load_ci_seq_num => l_spa_term_sequence_number
               );

           IF l_flag = TRUE THEN
              g_sec_to_prim_first := TRUE;
           ELSE

              FOR i IN 1..g_primary_prg_rec_count LOOP
                IF g_primary_prg_rec.exists(i) THEN
                   IF g_primary_prg_rec(i).career = l_prog_type THEN
                      g_primary_prg_rec.delete(i);
                   END IF;
                END IF;
              END LOOP;

           END IF;

         -- If the program attempt is being modified to not to be primary any longer then store the
         -- value of the program code in the global pl/sql table g_primary_prg_rec.
         ELSE

               IF g_sec_to_prim_first = TRUE THEN
                  g_sec_to_prim_first := FALSE;
               ELSE
                  g_primary_prg_rec_count := g_primary_prg_rec_count + 1;
                  g_primary_prg_rec(g_primary_prg_rec_count).career := l_prog_type;
                  g_primary_prg_rec(g_primary_prg_rec_count).program_cd := new_references.course_cd;
               END IF;

         END IF;

      END IF;

    END IF;

-- check to ensure that course attempt status is never null
             IF (p_action = 'UPDATE') THEN
               IF new_references.course_attempt_status IS NULL THEN
                      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
                      IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
               END IF;
            END IF;

	     IF p_action = 'INSERT' AND NVL(new_references.key_program,'N') = 'Y' THEN
               igf_aw_coa_gen.ins_coa_todo(
                        p_person_id => new_references.person_id ,
                        p_calling_module => 'IGSEI24B',
                        p_program_code => new_references.course_cd,
                        p_version_number=> new_references.version_number) ;
	     END IF;

	     IF p_action = 'DELETE' AND NVL(old_references.key_program,'N') = 'Y' THEN
              igf_aw_coa_gen. ins_coa_todo(
                    p_person_id => old_references.person_id ,
 		    p_calling_module => 'IGSEI24B_D',
                    p_program_code => old_references.course_cd,
                    p_version_number=> old_references.version_number) ;
	      END IF;

     --bmerugu added for build 319
     IF (p_action='INSERT' OR p_action='UPDATE') THEN
	IF (NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N')='Y') THEN
	   IF (NVL(new_references.primary_program_type,'SECONDARY')='PRIMARY'  AND
		new_references.student_confirmed_ind='Y') THEN
	      BEGIN
		 -- Get the Program Type/Career for the program version.
		 OPEN cur_get_prog_type(new_references.course_cd,new_references.version_number);
		 FETCH cur_get_prog_type INTO l_prog_type;
		 CLOSE cur_get_prog_type;
		 FOR cur_pattempts_rec IN cur_pattempts(new_references.person_id,l_prog_type) LOOP
			FOR cur_sua_uooid_rec IN cur_sua_uooid(cur_pattempts_rec.person_id,cur_pattempts_rec.course_cd) LOOP
				--call to delete the unit attemps
				l_delflag := IGS_EN_FUTURE_DT_TRANS.del_sua_for_reopen(cur_pattempts_rec.person_id,
								  cur_pattempts_rec.course_cd,
								  cur_sua_uooid_rec.uoo_id);
			END LOOP;
		 END LOOP;
	      END;
	   END IF; -- end of check if current program is primary
	END IF; -- end of career_mode check
     END IF; -- end of p_action check


    /**********************************************************************************************************/

    /* Please don't add any code after the call to IGS_EN_CAREER_MODEL.SCA_TBH_AFTER_DML as this procedure    */
    /* recursively calls update_row resetting the package variable new_references which might result in some  */
    /* unexpected behaviour. So, add any new code before this call.                                           */

    /**********************************************************************************************************/

     AFTER_DML_RECURSIVE_CALLS(p_old_references         => old_references,
                               p_new_references         => new_references,
                               p_action                 => p_action,
                               p_skip_before_after_dml  => IGS_EN_STDNT_PS_ATT_PKG.skip_before_after_dml);

  END After_DML;



PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_ORG_ID IN NUMBER,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_ADVANCED_STANDING_IND IN VARCHAR2,
  X_FEE_CAT IN VARCHAR2,
  X_CORRESPONDENCE_CAT IN VARCHAR2,
  X_SELF_HELP_GROUP_IND IN VARCHAR2,
  X_LOGICAL_DELETE_DT IN DATE,
  X_ADM_ADMISSION_APPL_NUMBER IN NUMBER,
  X_ADM_NOMINATED_COURSE_CD IN VARCHAR2,
  X_ADM_SEQUENCE_NUMBER IN NUMBER,
  X_VERSION_NUMBER IN NUMBER,
  X_CAL_TYPE IN VARCHAR2,
  X_LOCATION_CD IN VARCHAR2,
  X_ATTENDANCE_MODE IN VARCHAR2,
  X_ATTENDANCE_TYPE IN VARCHAR2,
  X_COO_ID IN NUMBER,
  X_STUDENT_CONFIRMED_IND IN VARCHAR2,
  X_COMMENCEMENT_DT IN DATE,
  X_COURSE_ATTEMPT_STATUS IN VARCHAR2,
  X_PROGRESSION_STATUS IN VARCHAR2,
  X_DERIVED_ATT_TYPE IN VARCHAR2,
  X_DERIVED_ATT_MODE IN VARCHAR2,
  X_PROVISIONAL_IND IN VARCHAR2,
  X_DISCONTINUED_DT IN DATE,
  X_DISCONTINUATION_REASON_CD IN VARCHAR2,
  X_LAPSED_DT IN DATE,
  X_FUNDING_SOURCE IN VARCHAR2,
  X_EXAM_LOCATION_CD IN VARCHAR2,
  X_DERIVED_COMPLETION_YR IN NUMBER,
  X_DERIVED_COMPLETION_PERD IN VARCHAR2,
  X_NOMINATED_COMPLETION_YR IN NUMBER,
  X_NOMINATED_COMPLETION_PERD IN VARCHAR2,
  X_RULE_CHECK_IND IN VARCHAR2,
  X_WAIVE_OPTION_CHECK_IND IN VARCHAR2,
  X_LAST_RULE_CHECK_DT IN DATE,
  X_PUBLISH_OUTCOMES_IND IN VARCHAR2,
  X_COURSE_RQRMNT_COMPLETE_IND IN VARCHAR2,
  X_COURSE_RQRMNTS_COMPLETE_DT IN DATE,
  X_S_COMPLETED_SOURCE_TYPE IN VARCHAR2,
  X_OVERRIDE_TIME_LIMITATION IN NUMBER,
  X_MODE IN VARCHAR2 ,
  X_LAST_DATE_OF_ATTENDANCE IN DATE,
  X_DROPPED_BY IN VARCHAR2,
  X_IGS_PR_CLASS_STD_ID IN NUMBER,
  X_PRIMARY_PROGRAM_TYPE IN VARCHAR2,
  X_PRIMARY_PROG_TYPE_SOURCE IN VARCHAR2,
  X_CATALOG_CAL_TYPE IN VARCHAR2,
  X_CATALOG_SEQ_NUM IN NUMBER,
  X_KEY_PROGRAM IN VARCHAR2,
  X_MANUAL_OVR_CMPL_DT_IND IN VARCHAR2,
  X_OVERRIDE_CMPL_DT       IN DATE    ,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE16 IN VARCHAR2,
  X_ATTRIBUTE17 IN VARCHAR2,
  X_ATTRIBUTE18 IN VARCHAR2,
  X_ATTRIBUTE19 IN VARCHAR2,
  x_ATTRIBUTE20 IN VARCHAR2,
  X_FUTURE_DATED_TRANS_FLAG IN VARCHAR2
  ) AS
  /*--------------------------------------------------------------------------------------------
  --Change History
  --Who                 When                    What
  --sbaliga             13-feb-2002             Assigned igs_ge_gen_003.get_org_id to x_org_id
  --                                            in call to before_dml as part of SWCR006 build.
  -----------------------------------------------------------------------------------------------*/
  CURSOR C IS
      SELECT ROWID FROM IGS_EN_STDNT_PS_ATT_ALL
      WHERE PERSON_ID = X_PERSON_ID
      AND COURSE_CD = X_COURSE_CD;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
BEGIN
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE IN ('R', 'S')) THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF X_LAST_UPDATED_BY IS NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    IF X_LAST_UPDATE_LOGIN IS NULL THEN
      X_LAST_UPDATE_LOGIN := -1;
    END IF;
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    IF (X_REQUEST_ID = -1) THEN
       X_REQUEST_ID := NULL;
       X_PROGRAM_ID := NULL;
       X_PROGRAM_APPLICATION_ID := NULL;
       X_PROGRAM_UPDATE_DATE := NULL;
    ELSE
       X_PROGRAM_UPDATE_DATE := SYSDATE;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;


  Before_DML (
    p_action => 'INSERT',
    x_rowid =>   X_ROWID,
    x_org_id => igs_ge_gen_003.get_org_id,
    x_person_id => X_PERSON_ID,
    x_course_cd => X_COURSE_CD,
    x_advanced_standing_ind => NVL(X_ADVANCED_STANDING_IND,'N'),
    x_fee_cat => X_FEE_CAT,
    x_correspondence_cat => X_CORRESPONDENCE_CAT,
    x_self_help_group_ind => NVL(X_SELF_HELP_GROUP_IND,'N'),
    x_logical_delete_dt => X_LOGICAL_DELETE_DT,
    x_adm_admission_appl_number => X_ADM_ADMISSION_APPL_NUMBER,
    x_adm_nominated_course_cd => X_ADM_NOMINATED_COURSE_CD,
    x_adm_sequence_number => X_ADM_SEQUENCE_NUMBER,
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_coo_id => X_COO_ID,
    x_student_confirmed_ind => NVL(X_STUDENT_CONFIRMED_IND,'N'),
    x_commencement_dt => X_COMMENCEMENT_DT,
    x_course_attempt_status => X_COURSE_ATTEMPT_STATUS,
    x_progression_status => NVL(X_PROGRESSION_STATUS,'GOODSTAND'),
    x_derived_att_type => X_DERIVED_ATT_TYPE,
    x_derived_att_mode => X_DERIVED_ATT_MODE,
    x_provisional_ind => NVL(X_PROVISIONAL_IND,'N'),
    x_discontinued_dt => X_DISCONTINUED_DT,
    x_discontinuation_reason_cd => X_DISCONTINUATION_REASON_CD,
    x_lapsed_dt => X_LAPSED_DT,
    x_funding_source => X_FUNDING_SOURCE,
    x_exam_location_cd => X_EXAM_LOCATION_CD,
    x_derived_completion_yr => X_DERIVED_COMPLETION_YR,
    x_derived_completion_perd => X_DERIVED_COMPLETION_PERD,
    x_nominated_completion_yr => X_NOMINATED_COMPLETION_YR,
    x_nominated_completion_perd => X_NOMINATED_COMPLETION_PERD,
    x_rule_check_ind => NVL(X_RULE_CHECK_IND,'Y'),
    x_waive_option_check_ind => NVL(X_WAIVE_OPTION_CHECK_IND,'N'),
    x_last_rule_check_dt => X_LAST_RULE_CHECK_DT,
    x_publish_outcomes_ind => NVL(X_PUBLISH_OUTCOMES_IND,'Y'),
    x_course_rqrmnt_complete_ind => NVL(X_COURSE_RQRMNT_COMPLETE_IND,'N'),
    x_course_rqrmnts_complete_dt => X_COURSE_RQRMNTS_COMPLETE_DT,
    x_s_completed_source_type => NVL(X_S_COMPLETED_SOURCE_TYPE,'MANUAL'),
    x_override_time_limitation => X_OVERRIDE_TIME_LIMITATION,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_last_date_of_attendance =>X_LAST_DATE_OF_ATTENDANCE,
    x_dropped_by => X_DROPPED_BY,
    X_IGS_PR_CLASS_STD_ID => X_IGS_PR_CLASS_STD_ID,
    x_primary_program_type => X_PRIMARY_PROGRAM_TYPE,
    x_primary_prog_type_source => X_PRIMARY_PROG_TYPE_SOURCE,
    x_catalog_cal_type => X_CATALOG_CAL_TYPE,
    x_catalog_seq_num => X_CATALOG_SEQ_NUM,
    x_key_program => NVL(X_KEY_PROGRAM,'N'),
    x_manual_ovr_cmpl_dt_ind => X_MANUAL_OVR_CMPL_DT_IND,
    x_override_cmpl_dt       => X_OVERRIDE_CMPL_DT,
   x_attribute_category=>X_ATTRIBUTE_CATEGORY,
   x_future_dated_trans_flag => NVL(X_FUTURE_DATED_TRANS_FLAG,'N'),
   x_attribute1=>X_ATTRIBUTE1,
   x_attribute2=>X_ATTRIBUTE2,
   x_attribute3=>X_ATTRIBUTE3,
   x_attribute4=>X_ATTRIBUTE4,
   x_attribute5=>X_ATTRIBUTE5,
   x_attribute6=>X_ATTRIBUTE6,
   x_attribute7=>X_ATTRIBUTE7,
   x_attribute8=>X_ATTRIBUTE8,
   x_attribute9=>X_ATTRIBUTE9,
   x_attribute10=>X_ATTRIBUTE10,
   x_attribute11=>X_ATTRIBUTE11,
   x_attribute12=>X_ATTRIBUTE12,
   x_attribute13=>X_ATTRIBUTE13,
   x_attribute14=>X_ATTRIBUTE14,
   x_attribute15=>X_ATTRIBUTE15,
   x_attribute16=>X_ATTRIBUTE16,
   x_attribute17=>X_ATTRIBUTE17,
   x_attribute18=>X_ATTRIBUTE18,
   x_attribute19=>X_ATTRIBUTE19,
   x_attribute20=>X_ATTRIBUTE20
  );


  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  INSERT INTO IGS_EN_STDNT_PS_ATT_ALL (
    org_id,
    ADVANCED_STANDING_IND,
    FEE_CAT,
    CORRESPONDENCE_CAT,
    SELF_HELP_GROUP_IND,
    LOGICAL_DELETE_DT,
    ADM_ADMISSION_APPL_NUMBER,
    ADM_NOMINATED_COURSE_CD,
    ADM_SEQUENCE_NUMBER,
    PERSON_ID,
    COURSE_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    LOCATION_CD,
    ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    COO_ID,
    STUDENT_CONFIRMED_IND,
    COMMENCEMENT_DT,
    COURSE_ATTEMPT_STATUS,
    PROGRESSION_STATUS,
    DERIVED_ATT_TYPE,
    DERIVED_ATT_MODE,
    PROVISIONAL_IND,
    DISCONTINUED_DT,
    DISCONTINUATION_REASON_CD,
    LAPSED_DT,
    FUNDING_SOURCE,
    EXAM_LOCATION_CD,
    DERIVED_COMPLETION_YR,
    DERIVED_COMPLETION_PERD,
    NOMINATED_COMPLETION_YR,
    NOMINATED_COMPLETION_PERD,
    RULE_CHECK_IND,
    WAIVE_OPTION_CHECK_IND,
    LAST_RULE_CHECK_DT,
    PUBLISH_OUTCOMES_IND,
    COURSE_RQRMNT_COMPLETE_IND,
    COURSE_RQRMNTS_COMPLETE_DT,
    S_COMPLETED_SOURCE_TYPE,
    OVERRIDE_TIME_LIMITATION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    LAST_DATE_OF_ATTENDANCE,
    DROPPED_BY,
    IGS_PR_CLASS_STD_ID,
    PRIMARY_PROGRAM_TYPE,
    PRIMARY_PROG_TYPE_SOURCE,
    CATALOG_CAL_TYPE,
    CATALOG_SEQ_NUM,
    KEY_PROGRAM,
    MANUAL_OVR_CMPL_DT_IND,
    OVERRIDE_CMPL_DT,
    ATTRIBUTE_CATEGORY,
    FUTURE_DATED_TRANS_FLAG,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20
    ) VALUES (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.ADVANCED_STANDING_IND,
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.CORRESPONDENCE_CAT,
    NEW_REFERENCES.SELF_HELP_GROUP_IND,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
    NEW_REFERENCES.ADM_ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.ADM_NOMINATED_COURSE_CD,
    NEW_REFERENCES.ADM_SEQUENCE_NUMBER,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.COO_ID,
    NEW_REFERENCES.STUDENT_CONFIRMED_IND,
    NEW_REFERENCES.COMMENCEMENT_DT,
    NEW_REFERENCES.COURSE_ATTEMPT_STATUS,
    NEW_REFERENCES.PROGRESSION_STATUS,
    NEW_REFERENCES.DERIVED_ATT_TYPE,
    NEW_REFERENCES.DERIVED_ATT_MODE,
    NEW_REFERENCES.PROVISIONAL_IND,
    NEW_REFERENCES.DISCONTINUED_DT,
    NEW_REFERENCES.DISCONTINUATION_REASON_CD,
    NEW_REFERENCES.LAPSED_DT,
    NEW_REFERENCES.FUNDING_SOURCE,
    NEW_REFERENCES.EXAM_LOCATION_CD,
    NEW_REFERENCES.DERIVED_COMPLETION_YR,
    NEW_REFERENCES.DERIVED_COMPLETION_PERD,
    NEW_REFERENCES.NOMINATED_COMPLETION_YR,
    NEW_REFERENCES.NOMINATED_COMPLETION_PERD,
    NEW_REFERENCES.RULE_CHECK_IND,
    NEW_REFERENCES.WAIVE_OPTION_CHECK_IND,
    NEW_REFERENCES.LAST_RULE_CHECK_DT,
    NEW_REFERENCES.PUBLISH_OUTCOMES_IND,
    NEW_REFERENCES.COURSE_RQRMNT_COMPLETE_IND,
    NEW_REFERENCES.COURSE_RQRMNTS_COMPLETE_DT,
    NEW_REFERENCES.S_COMPLETED_SOURCE_TYPE,
    NEW_REFERENCES.OVERRIDE_TIME_LIMITATION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    NEW_REFERENCES.LAST_DATE_OF_ATTENDANCE,
    NEW_REFERENCES.DROPPED_BY,
    NEW_REFERENCES.IGS_PR_CLASS_STD_ID,
    NEW_REFERENCES.PRIMARY_PROGRAM_TYPE,
    NEW_REFERENCES.PRIMARY_PROG_TYPE_SOURCE,
    NEW_REFERENCES.CATALOG_CAL_TYPE,
    NEW_REFERENCES.CATALOG_SEQ_NUM,
    NEW_REFERENCES.KEY_PROGRAM,
    NEW_REFERENCES.MANUAL_OVR_CMPL_DT_IND,
    NEW_REFERENCES.OVERRIDE_CMPL_DT,
    NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    NEW_REFERENCES.FUTURE_DATED_TRANS_FLAG,
    NEW_REFERENCES.ATTRIBUTE1,
    NEW_REFERENCES.ATTRIBUTE2,
    NEW_REFERENCES.ATTRIBUTE3,
    NEW_REFERENCES.ATTRIBUTE4,
    NEW_REFERENCES.ATTRIBUTE5,
    NEW_REFERENCES.ATTRIBUTE6,
    NEW_REFERENCES.ATTRIBUTE7,
    NEW_REFERENCES.ATTRIBUTE8,
    NEW_REFERENCES.ATTRIBUTE9,
    NEW_REFERENCES.ATTRIBUTE10,
    NEW_REFERENCES.ATTRIBUTE11,
    NEW_REFERENCES.ATTRIBUTE12,
    NEW_REFERENCES.ATTRIBUTE13,
    NEW_REFERENCES.ATTRIBUTE14,
    NEW_REFERENCES.ATTRIBUTE15,
    NEW_REFERENCES.ATTRIBUTE16,
    NEW_REFERENCES.ATTRIBUTE17,
    NEW_REFERENCES.ATTRIBUTE18,
    NEW_REFERENCES.ATTRIBUTE19,
    NEW_REFERENCES.ATTRIBUTE20
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;


   After_DML (
            p_action     => 'INSERT',
            x_rowid      =>  X_ROWID
  );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_ADVANCED_STANDING_IND IN VARCHAR2,
  X_FEE_CAT IN VARCHAR2,
  X_CORRESPONDENCE_CAT IN VARCHAR2,
  X_SELF_HELP_GROUP_IND IN VARCHAR2,
  X_LOGICAL_DELETE_DT IN DATE,
  X_ADM_ADMISSION_APPL_NUMBER IN NUMBER,
  X_ADM_NOMINATED_COURSE_CD IN VARCHAR2,
  X_ADM_SEQUENCE_NUMBER IN NUMBER,
  X_VERSION_NUMBER IN NUMBER,
  X_CAL_TYPE IN VARCHAR2,
  X_LOCATION_CD IN VARCHAR2,
  X_ATTENDANCE_MODE IN VARCHAR2,
  X_ATTENDANCE_TYPE IN VARCHAR2,
  X_COO_ID IN NUMBER,
  X_STUDENT_CONFIRMED_IND IN VARCHAR2,
  X_COMMENCEMENT_DT IN DATE,
  X_COURSE_ATTEMPT_STATUS IN VARCHAR2,
  X_PROGRESSION_STATUS IN VARCHAR2,
  X_DERIVED_ATT_TYPE IN VARCHAR2,
  X_DERIVED_ATT_MODE IN VARCHAR2,
  X_PROVISIONAL_IND IN VARCHAR2,
  X_DISCONTINUED_DT IN DATE,
  X_DISCONTINUATION_REASON_CD IN VARCHAR2,
  X_LAPSED_DT IN DATE,
  X_FUNDING_SOURCE IN VARCHAR2,
  X_EXAM_LOCATION_CD IN VARCHAR2,
  X_DERIVED_COMPLETION_YR IN NUMBER,
  X_DERIVED_COMPLETION_PERD IN VARCHAR2,
  X_NOMINATED_COMPLETION_YR IN NUMBER,
  X_NOMINATED_COMPLETION_PERD IN VARCHAR2,
  X_RULE_CHECK_IND IN VARCHAR2,
  X_WAIVE_OPTION_CHECK_IND IN VARCHAR2,
  X_LAST_RULE_CHECK_DT IN DATE,
  X_PUBLISH_OUTCOMES_IND IN VARCHAR2,
  X_COURSE_RQRMNT_COMPLETE_IND IN VARCHAR2,
  X_COURSE_RQRMNTS_COMPLETE_DT IN DATE,
  X_S_COMPLETED_SOURCE_TYPE IN VARCHAR2,
  X_OVERRIDE_TIME_LIMITATION IN NUMBER,
  X_LAST_DATE_OF_ATTENDANCE IN DATE,
  X_DROPPED_BY IN VARCHAR2,
  X_IGS_PR_CLASS_STD_ID IN NUMBER,
  X_PRIMARY_PROGRAM_TYPE IN VARCHAR2,
  X_PRIMARY_PROG_TYPE_SOURCE IN VARCHAR2,
  X_CATALOG_CAL_TYPE IN VARCHAR2,
  X_CATALOG_SEQ_NUM IN NUMBER ,
  X_KEY_PROGRAM IN VARCHAR2,
  X_MANUAL_OVR_CMPL_DT_IND IN VARCHAR2,
  X_OVERRIDE_CMPL_DT IN DATE,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE16 IN VARCHAR2,
  X_ATTRIBUTE17 IN VARCHAR2,
  X_ATTRIBUTE18 IN VARCHAR2,
  X_ATTRIBUTE19 IN VARCHAR2,
  x_ATTRIBUTE20 IN VARCHAR2,
  X_FUTURE_DATED_TRANS_FLAG IN VARCHAR2
) AS
  CURSOR c1 IS SELECT
      org_id,
      ADVANCED_STANDING_IND,
      FEE_CAT,
      CORRESPONDENCE_CAT,
      SELF_HELP_GROUP_IND,
      LOGICAL_DELETE_DT,
      ADM_ADMISSION_APPL_NUMBER,
      ADM_NOMINATED_COURSE_CD,
      ADM_SEQUENCE_NUMBER,
      VERSION_NUMBER,
      CAL_TYPE,
      LOCATION_CD,
      ATTENDANCE_MODE,
      ATTENDANCE_TYPE,
      COO_ID,
      STUDENT_CONFIRMED_IND,
      COMMENCEMENT_DT,
      COURSE_ATTEMPT_STATUS,
      PROGRESSION_STATUS,
      DERIVED_ATT_TYPE,
      DERIVED_ATT_MODE,
      PROVISIONAL_IND,
      DISCONTINUED_DT,
      DISCONTINUATION_REASON_CD,
      LAPSED_DT,
      FUNDING_SOURCE,
      EXAM_LOCATION_CD,
      DERIVED_COMPLETION_YR,
      DERIVED_COMPLETION_PERD,
      NOMINATED_COMPLETION_YR,
      NOMINATED_COMPLETION_PERD,
      RULE_CHECK_IND,
      WAIVE_OPTION_CHECK_IND,
      LAST_RULE_CHECK_DT,
      PUBLISH_OUTCOMES_IND,
      COURSE_RQRMNT_COMPLETE_IND,
      COURSE_RQRMNTS_COMPLETE_DT,
      S_COMPLETED_SOURCE_TYPE,
      OVERRIDE_TIME_LIMITATION,
      LAST_DATE_OF_ATTENDANCE,
      DROPPED_BY,
      IGS_PR_CLASS_STD_ID,
      PRIMARY_PROGRAM_TYPE,
      PRIMARY_PROG_TYPE_SOURCE,
      CATALOG_CAL_TYPE,
      CATALOG_SEQ_NUM,
      KEY_PROGRAM,
      MANUAL_OVR_CMPL_DT_IND,
      OVERRIDE_CMPL_DT,
      ATTRIBUTE_CATEGORY,
      FUTURE_DATED_TRANS_FLAG,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20
    FROM IGS_EN_STDNT_PS_ATT_ALL
    WHERE ROWID = X_ROWID FOR UPDATE NOWAIT;
  tlinfo c1%ROWTYPE;
BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    RETURN;
  END IF;
  CLOSE c1;
  IF ( (tlinfo.ADVANCED_STANDING_IND = X_ADVANCED_STANDING_IND)
      AND ((tlinfo.FEE_CAT = X_FEE_CAT)
           OR ((tlinfo.FEE_CAT IS NULL)
               AND (X_FEE_CAT IS NULL)))
      AND ((tlinfo.CORRESPONDENCE_CAT = X_CORRESPONDENCE_CAT)
           OR ((tlinfo.CORRESPONDENCE_CAT IS NULL)
               AND (X_CORRESPONDENCE_CAT IS NULL)))
      AND (tlinfo.SELF_HELP_GROUP_IND = X_SELF_HELP_GROUP_IND)
      AND ((TRUNC(tlinfo.LOGICAL_DELETE_DT) = TRUNC(X_LOGICAL_DELETE_DT))
           OR ((tlinfo.LOGICAL_DELETE_DT IS NULL)
               AND (X_LOGICAL_DELETE_DT IS NULL)))
      AND ((tlinfo.ADM_ADMISSION_APPL_NUMBER = X_ADM_ADMISSION_APPL_NUMBER)
           OR ((tlinfo.ADM_ADMISSION_APPL_NUMBER IS NULL)
               AND (X_ADM_ADMISSION_APPL_NUMBER IS NULL)))
      AND ((tlinfo.ADM_NOMINATED_COURSE_CD = X_ADM_NOMINATED_COURSE_CD)
           OR ((tlinfo.ADM_NOMINATED_COURSE_CD IS NULL)
               AND (X_ADM_NOMINATED_COURSE_CD IS NULL)))
      AND ((tlinfo.ADM_SEQUENCE_NUMBER = X_ADM_SEQUENCE_NUMBER)
           OR ((tlinfo.ADM_SEQUENCE_NUMBER IS NULL)
               AND (X_ADM_SEQUENCE_NUMBER IS NULL)))
      AND (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
      AND (tlinfo.CAL_TYPE = X_CAL_TYPE)
      AND (tlinfo.LOCATION_CD = X_LOCATION_CD)
      AND (tlinfo.ATTENDANCE_MODE = X_ATTENDANCE_MODE)
      AND (tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
      AND (tlinfo.COO_ID = X_COO_ID)
      AND (tlinfo.STUDENT_CONFIRMED_IND = X_STUDENT_CONFIRMED_IND)
      AND ((TRUNC(tlinfo.COMMENCEMENT_DT) = TRUNC(X_COMMENCEMENT_DT))
           OR ((tlinfo.COMMENCEMENT_DT IS NULL)
               AND (X_COMMENCEMENT_DT IS NULL)))
      AND ((tlinfo.COURSE_ATTEMPT_STATUS = X_COURSE_ATTEMPT_STATUS)
           OR ((tlinfo.COURSE_ATTEMPT_STATUS IS NULL)
               AND (X_COURSE_ATTEMPT_STATUS IS NULL)))
      AND ((tlinfo.PROGRESSION_STATUS = X_PROGRESSION_STATUS)
           OR ((tlinfo.PROGRESSION_STATUS IS NULL)
               AND (X_PROGRESSION_STATUS IS NULL)))
      AND ((tlinfo.DERIVED_ATT_TYPE = X_DERIVED_ATT_TYPE)
           OR ((tlinfo.DERIVED_ATT_TYPE IS NULL)
               AND (X_DERIVED_ATT_TYPE IS NULL)))
      AND ((tlinfo.DERIVED_ATT_MODE = X_DERIVED_ATT_MODE)
           OR ((tlinfo.DERIVED_ATT_MODE IS NULL)
               AND (X_DERIVED_ATT_MODE IS NULL)))
      AND (tlinfo.PROVISIONAL_IND = X_PROVISIONAL_IND)
      AND ((TRUNC(tlinfo.DISCONTINUED_DT) = TRUNC(X_DISCONTINUED_DT))
           OR ((tlinfo.DISCONTINUED_DT IS NULL)
               AND (X_DISCONTINUED_DT IS NULL)))
      AND ((tlinfo.DISCONTINUATION_REASON_CD = X_DISCONTINUATION_REASON_CD)
           OR ((tlinfo.DISCONTINUATION_REASON_CD IS NULL)
               AND (X_DISCONTINUATION_REASON_CD IS NULL)))
      AND ((TRUNC(tlinfo.LAPSED_DT) = TRUNC(X_LAPSED_DT))
           OR ((tlinfo.LAPSED_DT IS NULL)
               AND (X_LAPSED_DT IS NULL)))
      AND ((tlinfo.FUNDING_SOURCE = X_FUNDING_SOURCE)
           OR ((tlinfo.FUNDING_SOURCE IS NULL)
               AND (X_FUNDING_SOURCE IS NULL)))
      AND ((tlinfo.EXAM_LOCATION_CD = X_EXAM_LOCATION_CD)
           OR ((tlinfo.EXAM_LOCATION_CD IS NULL)
               AND (X_EXAM_LOCATION_CD IS NULL)))
      AND ((tlinfo.DERIVED_COMPLETION_YR = X_DERIVED_COMPLETION_YR)
           OR ((tlinfo.DERIVED_COMPLETION_YR IS NULL)
               AND (X_DERIVED_COMPLETION_YR IS NULL)))
      AND ((tlinfo.DERIVED_COMPLETION_PERD = X_DERIVED_COMPLETION_PERD)
           OR ((tlinfo.DERIVED_COMPLETION_PERD IS NULL)
               AND (X_DERIVED_COMPLETION_PERD IS NULL)))
      AND ((tlinfo.NOMINATED_COMPLETION_YR = X_NOMINATED_COMPLETION_YR)
           OR ((tlinfo.NOMINATED_COMPLETION_YR IS NULL)
               AND (X_NOMINATED_COMPLETION_YR IS NULL)))
      AND ((tlinfo.NOMINATED_COMPLETION_PERD = X_NOMINATED_COMPLETION_PERD)
           OR ((tlinfo.NOMINATED_COMPLETION_PERD IS NULL)
               AND (X_NOMINATED_COMPLETION_PERD IS NULL)))
      AND (tlinfo.RULE_CHECK_IND = X_RULE_CHECK_IND)
      AND (tlinfo.WAIVE_OPTION_CHECK_IND = X_WAIVE_OPTION_CHECK_IND)
      AND ((TRUNC(tlinfo.LAST_RULE_CHECK_DT) = TRUNC(X_LAST_RULE_CHECK_DT))
           OR ((tlinfo.LAST_RULE_CHECK_DT IS NULL)
               AND (X_LAST_RULE_CHECK_DT IS NULL)))
      AND (tlinfo.PUBLISH_OUTCOMES_IND = X_PUBLISH_OUTCOMES_IND)
      AND (tlinfo.COURSE_RQRMNT_COMPLETE_IND = X_COURSE_RQRMNT_COMPLETE_IND)
      AND ((TRUNC(tlinfo.COURSE_RQRMNTS_COMPLETE_DT) = TRUNC(X_COURSE_RQRMNTS_COMPLETE_DT))
           OR ((tlinfo.COURSE_RQRMNTS_COMPLETE_DT IS NULL)
               AND (X_COURSE_RQRMNTS_COMPLETE_DT IS NULL)))
      AND ((tlinfo.S_COMPLETED_SOURCE_TYPE = X_S_COMPLETED_SOURCE_TYPE)
           OR ((tlinfo.S_COMPLETED_SOURCE_TYPE IS NULL)
               AND (X_S_COMPLETED_SOURCE_TYPE IS NULL)))
      AND ((tlinfo.OVERRIDE_TIME_LIMITATION = X_OVERRIDE_TIME_LIMITATION)
           OR ((tlinfo.OVERRIDE_TIME_LIMITATION IS NULL)
               AND (X_OVERRIDE_TIME_LIMITATION IS NULL)))
      AND ((TRUNC(tlinfo.LAST_DATE_OF_ATTENDANCE) = TRUNC(X_LAST_DATE_OF_ATTENDANCE))
           OR ((tlinfo.LAST_DATE_OF_ATTENDANCE IS NULL)
               AND (X_LAST_DATE_OF_ATTENDANCE IS NULL)))
      AND ((tlinfo.DROPPED_BY = X_DROPPED_BY)
           OR ((tlinfo.DROPPED_BY IS NULL)
               AND (X_DROPPED_BY IS NULL)))
      AND ((tlinfo.IGS_PR_CLASS_STD_ID = X_IGS_PR_CLASS_STD_ID)
           OR ((tlinfo.IGS_PR_CLASS_STD_ID IS NULL)
               AND (X_IGS_PR_CLASS_STD_ID IS NULL)))
      AND ((tlinfo.PRIMARY_PROGRAM_TYPE = X_PRIMARY_PROGRAM_TYPE)
           OR ((tlinfo.PRIMARY_PROGRAM_TYPE IS NULL)
               AND (X_PRIMARY_PROGRAM_TYPE IS NULL)))
      AND ((tlinfo.PRIMARY_PROG_TYPE_SOURCE = X_PRIMARY_PROG_TYPE_SOURCE)
           OR ((tlinfo.PRIMARY_PROG_TYPE_SOURCE IS NULL)
               AND (X_PRIMARY_PROG_TYPE_SOURCE IS NULL)))
      AND ((tlinfo.CATALOG_CAL_TYPE = X_CATALOG_CAL_TYPE)
           OR ((tlinfo.CATALOG_CAL_TYPE IS NULL)
               AND (X_CATALOG_CAL_TYPE IS NULL)))
      AND ((tlinfo.CATALOG_SEQ_NUM = X_CATALOG_SEQ_NUM)
           OR ((tlinfo.CATALOG_SEQ_NUM IS NULL)
               AND (X_CATALOG_SEQ_NUM IS NULL)))
      AND ((tlinfo.KEY_PROGRAM = X_KEY_PROGRAM)
           OR ((tlinfo.KEY_PROGRAM IS NULL)
               AND (X_KEY_PROGRAM IS NULL)))
      AND ((tlinfo.MANUAL_OVR_CMPL_DT_IND = X_MANUAL_OVR_CMPL_DT_IND)
           OR ((tlinfo.MANUAL_OVR_CMPL_DT_IND IS NULL)
               AND (X_MANUAL_OVR_CMPL_DT_IND IS NULL)))
      AND ((TRUNC(tlinfo.OVERRIDE_CMPL_DT) = TRUNC(X_OVERRIDE_CMPL_DT))
           OR ((tlinfo.OVERRIDE_CMPL_DT IS NULL)
               AND (X_OVERRIDE_CMPL_DT IS NULL)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY IS NULL)
               AND (X_ATTRIBUTE_CATEGORY IS NULL)))
      AND ((tlinfo.FUTURE_DATED_TRANS_FLAG = X_FUTURE_DATED_TRANS_FLAG)
           OR ((tlinfo.FUTURE_DATED_TRANS_FLAG IS NULL)
               AND (X_FUTURE_DATED_TRANS_FLAG IS NULL)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 IS NULL)
               AND (X_ATTRIBUTE1 IS NULL)))
      AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 IS NULL)
               AND (X_ATTRIBUTE2 IS NULL)))
      AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 IS NULL)
               AND (X_ATTRIBUTE3 IS NULL)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 IS NULL)
               AND (X_ATTRIBUTE4 IS NULL)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 IS NULL)
               AND (X_ATTRIBUTE5 IS NULL)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((tlinfo.ATTRIBUTE6 IS NULL)
               AND (X_ATTRIBUTE6 IS NULL)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 IS NULL)
               AND (X_ATTRIBUTE7 IS NULL)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 IS NULL)
               AND (X_ATTRIBUTE8 IS NULL)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 IS NULL)
               AND (X_ATTRIBUTE9 IS NULL)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 IS NULL)
               AND (X_ATTRIBUTE10 IS NULL)))
      AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((tlinfo.ATTRIBUTE11 IS NULL)
               AND (X_ATTRIBUTE11 IS NULL)))
      AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 IS NULL)
               AND (X_ATTRIBUTE12 IS NULL)))
      AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((tlinfo.ATTRIBUTE13 IS NULL)
               AND (X_ATTRIBUTE13 IS NULL)))
      AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((tlinfo.ATTRIBUTE14 IS NULL)
               AND (X_ATTRIBUTE14 IS NULL)))
      AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((tlinfo.ATTRIBUTE15 IS NULL)
               AND (X_ATTRIBUTE15 IS NULL)))
      AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR ((tlinfo.ATTRIBUTE16 IS NULL)
               AND (X_ATTRIBUTE16 IS NULL)))
      AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
           OR ((tlinfo.ATTRIBUTE17 IS NULL)
               AND (X_ATTRIBUTE17 IS NULL)))
      AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
           OR ((tlinfo.ATTRIBUTE18 IS NULL)
               AND (X_ATTRIBUTE18 IS NULL)))
      AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
           OR ((tlinfo.ATTRIBUTE19 IS NULL)
               AND (X_ATTRIBUTE19 IS NULL)))
      AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
           OR ((tlinfo.ATTRIBUTE20 IS NULL)
              AND (X_ATTRIBUTE20 IS NULL)))
  ) THEN
    NULL;
  ELSE

    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;

  END IF;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_ADVANCED_STANDING_IND IN VARCHAR2,
  X_FEE_CAT IN VARCHAR2,
  X_CORRESPONDENCE_CAT IN VARCHAR2,
  X_SELF_HELP_GROUP_IND IN VARCHAR2,
  X_LOGICAL_DELETE_DT IN DATE,
  X_ADM_ADMISSION_APPL_NUMBER IN NUMBER,
  X_ADM_NOMINATED_COURSE_CD IN VARCHAR2,
  X_ADM_SEQUENCE_NUMBER IN NUMBER,
  X_VERSION_NUMBER IN NUMBER,
  X_CAL_TYPE IN VARCHAR2,
  X_LOCATION_CD IN VARCHAR2,
  X_ATTENDANCE_MODE IN VARCHAR2,
  X_ATTENDANCE_TYPE IN VARCHAR2,
  X_COO_ID IN NUMBER,
  X_STUDENT_CONFIRMED_IND IN VARCHAR2,
  X_COMMENCEMENT_DT IN DATE,
  X_COURSE_ATTEMPT_STATUS IN VARCHAR2,
  X_PROGRESSION_STATUS IN VARCHAR2,
  X_DERIVED_ATT_TYPE IN VARCHAR2,
  X_DERIVED_ATT_MODE IN VARCHAR2,
  X_PROVISIONAL_IND IN VARCHAR2,
  X_DISCONTINUED_DT IN DATE,
  X_DISCONTINUATION_REASON_CD IN VARCHAR2,
  X_LAPSED_DT IN DATE,
  X_FUNDING_SOURCE IN VARCHAR2,
  X_EXAM_LOCATION_CD IN VARCHAR2,
  X_DERIVED_COMPLETION_YR IN NUMBER,
  X_DERIVED_COMPLETION_PERD IN VARCHAR2,
  X_NOMINATED_COMPLETION_YR IN NUMBER,
  X_NOMINATED_COMPLETION_PERD IN VARCHAR2,
  X_RULE_CHECK_IND IN VARCHAR2,
  X_WAIVE_OPTION_CHECK_IND IN VARCHAR2,
  X_LAST_RULE_CHECK_DT IN DATE,
  X_PUBLISH_OUTCOMES_IND IN VARCHAR2,
  X_COURSE_RQRMNT_COMPLETE_IND IN VARCHAR2,
  X_COURSE_RQRMNTS_COMPLETE_DT IN DATE,
  X_S_COMPLETED_SOURCE_TYPE IN VARCHAR2,
  X_OVERRIDE_TIME_LIMITATION IN NUMBER,
  X_MODE IN VARCHAR2,
  X_LAST_DATE_OF_ATTENDANCE IN DATE,
  X_DROPPED_BY IN VARCHAR2,
  X_IGS_PR_CLASS_STD_ID IN NUMBER,
  X_PRIMARY_PROGRAM_TYPE IN VARCHAR2,
  X_PRIMARY_PROG_TYPE_SOURCE IN VARCHAR2,
  X_CATALOG_CAL_TYPE IN VARCHAR2,
  X_CATALOG_SEQ_NUM IN NUMBER,
  X_KEY_PROGRAM  IN VARCHAR2,
  X_MANUAL_OVR_CMPL_DT_IND IN VARCHAR2,
  X_OVERRIDE_CMPL_DT IN DATE,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE16 IN VARCHAR2,
  X_ATTRIBUTE17 IN VARCHAR2,
  X_ATTRIBUTE18 IN VARCHAR2,
  X_ATTRIBUTE19 IN VARCHAR2,
  x_ATTRIBUTE20 IN VARCHAR2,
  X_FUTURE_DATED_TRANS_FLAG IN VARCHAR2
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
BEGIN

  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE IN ('R', 'S')) THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF X_LAST_UPDATED_BY IS NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    IF X_LAST_UPDATE_LOGIN IS NULL THEN
      X_LAST_UPDATE_LOGIN := -1;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;

  Before_DML (
    p_action => 'UPDATE',
    x_rowid =>   X_ROWID,
    x_person_id => X_PERSON_ID,
    x_course_cd => X_COURSE_CD,
    x_advanced_standing_ind => X_ADVANCED_STANDING_IND,
    x_fee_cat => X_FEE_CAT,
    x_correspondence_cat => X_CORRESPONDENCE_CAT,
    x_self_help_group_ind => X_SELF_HELP_GROUP_IND,
    x_logical_delete_dt => X_LOGICAL_DELETE_DT,
    x_adm_admission_appl_number => X_ADM_ADMISSION_APPL_NUMBER,
    x_adm_nominated_course_cd => X_ADM_NOMINATED_COURSE_CD,
    x_adm_sequence_number => X_ADM_SEQUENCE_NUMBER,
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_coo_id => X_COO_ID,
    x_student_confirmed_ind => X_STUDENT_CONFIRMED_IND,
    x_commencement_dt => X_COMMENCEMENT_DT,
    x_course_attempt_status => X_COURSE_ATTEMPT_STATUS,
    x_progression_status => NVL(X_PROGRESSION_STATUS,'GOODSTAND'),
    x_derived_att_type => X_DERIVED_ATT_TYPE,
    x_derived_att_mode => X_DERIVED_ATT_MODE,
    x_provisional_ind => X_PROVISIONAL_IND,
    x_discontinued_dt => X_DISCONTINUED_DT,
    x_discontinuation_reason_cd => X_DISCONTINUATION_REASON_CD,
    x_lapsed_dt => X_LAPSED_DT,
    x_funding_source => X_FUNDING_SOURCE,
    x_exam_location_cd => X_EXAM_LOCATION_CD,
    x_derived_completion_yr => X_DERIVED_COMPLETION_YR,
    x_derived_completion_perd => X_DERIVED_COMPLETION_PERD,
    x_nominated_completion_yr => X_NOMINATED_COMPLETION_YR,
    x_nominated_completion_perd => X_NOMINATED_COMPLETION_PERD,
    x_rule_check_ind => X_RULE_CHECK_IND,
    x_waive_option_check_ind => X_WAIVE_OPTION_CHECK_IND,
    x_last_rule_check_dt => X_LAST_RULE_CHECK_DT,
    x_publish_outcomes_ind => X_PUBLISH_OUTCOMES_IND,
    x_course_rqrmnt_complete_ind => X_COURSE_RQRMNT_COMPLETE_IND,
    x_course_rqrmnts_complete_dt => X_COURSE_RQRMNTS_COMPLETE_DT,
    x_s_completed_source_type => X_S_COMPLETED_SOURCE_TYPE,
    x_override_time_limitation => X_OVERRIDE_TIME_LIMITATION,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN ,
    x_last_date_of_attendance =>X_LAST_DATE_OF_ATTENDANCE,
    x_dropped_by => X_DROPPED_BY,
   X_IGS_PR_CLASS_STD_ID => X_IGS_PR_CLASS_STD_ID,
  x_primary_program_type => X_PRIMARY_PROGRAM_TYPE,
    x_primary_prog_type_source => X_PRIMARY_PROG_TYPE_SOURCE,
    x_catalog_cal_type => X_CATALOG_CAL_TYPE,
    x_catalog_seq_num => X_CATALOG_SEQ_NUM ,
    x_key_program   => X_KEY_PROGRAM,
    x_manual_ovr_cmpl_dt_ind => X_MANUAL_OVR_CMPL_DT_IND,
    x_override_cmpl_dt       => X_OVERRIDE_CMPL_DT,
    x_attribute_category=>X_ATTRIBUTE_CATEGORY,
    x_future_dated_trans_flag => NVL(X_FUTURE_DATED_TRANS_FLAG,'N'),
    x_attribute1=>X_ATTRIBUTE1,
    x_attribute2=>X_ATTRIBUTE2,
    x_attribute3=>X_ATTRIBUTE3,
    x_attribute4=>X_ATTRIBUTE4,
    x_attribute5=>X_ATTRIBUTE5,
    x_attribute6=>X_ATTRIBUTE6,
    x_attribute7=>X_ATTRIBUTE7,
    x_attribute8=>X_ATTRIBUTE8,
    x_attribute9=>X_ATTRIBUTE9,
    x_attribute10=>X_ATTRIBUTE10,
    x_attribute11=>X_ATTRIBUTE11,
    x_attribute12=>X_ATTRIBUTE12,
    x_attribute13=>X_ATTRIBUTE13,
    x_attribute14=>X_ATTRIBUTE14,
    x_attribute15=>X_ATTRIBUTE15,
     x_attribute16=>X_ATTRIBUTE16,
    x_attribute17=>X_ATTRIBUTE17,
    x_attribute18=>X_ATTRIBUTE18,
    x_attribute19=>X_ATTRIBUTE19,
    x_attribute20=>X_ATTRIBUTE20
  );

   IF(X_MODE = 'R') THEN
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    IF(X_REQUEST_ID=-1) THEN
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
    ELSE
     X_PROGRAM_UPDATE_DATE := SYSDATE;
    END IF;
   END IF;

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  UPDATE IGS_EN_STDNT_PS_ATT_ALL SET
    ADVANCED_STANDING_IND = NEW_REFERENCES.ADVANCED_STANDING_IND,
    FEE_CAT = NEW_REFERENCES.FEE_CAT,
    CORRESPONDENCE_CAT = NEW_REFERENCES.CORRESPONDENCE_CAT,
    SELF_HELP_GROUP_IND = NEW_REFERENCES.SELF_HELP_GROUP_IND,
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
    ADM_ADMISSION_APPL_NUMBER = NEW_REFERENCES.ADM_ADMISSION_APPL_NUMBER,
    ADM_NOMINATED_COURSE_CD = NEW_REFERENCES.ADM_NOMINATED_COURSE_CD,
    ADM_SEQUENCE_NUMBER = NEW_REFERENCES.ADM_SEQUENCE_NUMBER,
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    CAL_TYPE = NEW_REFERENCES.CAL_TYPE,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    ATTENDANCE_MODE = NEW_REFERENCES.ATTENDANCE_MODE,
    ATTENDANCE_TYPE = NEW_REFERENCES.ATTENDANCE_TYPE,
    COO_ID = NEW_REFERENCES.COO_ID,
    STUDENT_CONFIRMED_IND = NEW_REFERENCES.STUDENT_CONFIRMED_IND,
    COMMENCEMENT_DT = NEW_REFERENCES.COMMENCEMENT_DT,
    COURSE_ATTEMPT_STATUS = NEW_REFERENCES.COURSE_ATTEMPT_STATUS,
    PROGRESSION_STATUS = NEW_REFERENCES.PROGRESSION_STATUS,
    DERIVED_ATT_TYPE = NEW_REFERENCES.DERIVED_ATT_TYPE,
    DERIVED_ATT_MODE = NEW_REFERENCES.DERIVED_ATT_MODE,
    PROVISIONAL_IND = NEW_REFERENCES.PROVISIONAL_IND,
    DISCONTINUED_DT = NEW_REFERENCES.DISCONTINUED_DT,
    DISCONTINUATION_REASON_CD = NEW_REFERENCES.DISCONTINUATION_REASON_CD,
    LAPSED_DT = NEW_REFERENCES.LAPSED_DT,
    FUNDING_SOURCE = NEW_REFERENCES.FUNDING_SOURCE,
    EXAM_LOCATION_CD = NEW_REFERENCES.EXAM_LOCATION_CD,
    DERIVED_COMPLETION_YR = NEW_REFERENCES.DERIVED_COMPLETION_YR,
    DERIVED_COMPLETION_PERD = NEW_REFERENCES.DERIVED_COMPLETION_PERD,
    NOMINATED_COMPLETION_YR = NEW_REFERENCES.NOMINATED_COMPLETION_YR,
    NOMINATED_COMPLETION_PERD = NEW_REFERENCES.NOMINATED_COMPLETION_PERD,
    RULE_CHECK_IND = NEW_REFERENCES.RULE_CHECK_IND,
    WAIVE_OPTION_CHECK_IND = NEW_REFERENCES.WAIVE_OPTION_CHECK_IND,
    LAST_RULE_CHECK_DT = NEW_REFERENCES.LAST_RULE_CHECK_DT,
    PUBLISH_OUTCOMES_IND = NEW_REFERENCES.PUBLISH_OUTCOMES_IND,
    COURSE_RQRMNT_COMPLETE_IND = NEW_REFERENCES.COURSE_RQRMNT_COMPLETE_IND,
    COURSE_RQRMNTS_COMPLETE_DT = NEW_REFERENCES.COURSE_RQRMNTS_COMPLETE_DT,
    S_COMPLETED_SOURCE_TYPE = NEW_REFERENCES.S_COMPLETED_SOURCE_TYPE,
    OVERRIDE_TIME_LIMITATION = NEW_REFERENCES.OVERRIDE_TIME_LIMITATION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    LAST_DATE_OF_ATTENDANCE = NEW_REFERENCES.LAST_DATE_OF_ATTENDANCE,
    DROPPED_BY = NEW_REFERENCES.DROPPED_BY,
  IGS_PR_CLASS_STD_ID = NEW_REFERENCES.IGS_PR_CLASS_STD_ID,
  PRIMARY_PROGRAM_TYPE = NEW_REFERENCES.PRIMARY_PROGRAM_TYPE,
    PRIMARY_PROG_TYPE_SOURCE = NEW_REFERENCES.PRIMARY_PROG_TYPE_SOURCE,
    CATALOG_CAL_TYPE = NEW_REFERENCES.CATALOG_CAL_TYPE,
    CATALOG_SEQ_NUM = NEW_REFERENCES.CATALOG_SEQ_NUM,
    KEY_PROGRAM   = NEW_REFERENCES.KEY_PROGRAM,
    MANUAL_OVR_CMPL_DT_IND = NEW_REFERENCES.MANUAL_OVR_CMPL_DT_IND,
    OVERRIDE_CMPL_DT = NEW_REFERENCES.OVERRIDE_CMPL_DT,
    ATTRIBUTE_CATEGORY =  NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    FUTURE_DATED_TRANS_FLAG = NEW_REFERENCES.FUTURE_DATED_TRANS_FLAG,
    ATTRIBUTE1 =  NEW_REFERENCES.ATTRIBUTE1,
    ATTRIBUTE2 =  NEW_REFERENCES.ATTRIBUTE2,
    ATTRIBUTE3 =  NEW_REFERENCES.ATTRIBUTE3,
    ATTRIBUTE4 =  NEW_REFERENCES.ATTRIBUTE4,
    ATTRIBUTE5 =  NEW_REFERENCES.ATTRIBUTE5,
    ATTRIBUTE6 =  NEW_REFERENCES.ATTRIBUTE6,
    ATTRIBUTE7 =  NEW_REFERENCES.ATTRIBUTE7,
    ATTRIBUTE8 =  NEW_REFERENCES.ATTRIBUTE8,
    ATTRIBUTE9 =  NEW_REFERENCES.ATTRIBUTE9,
    ATTRIBUTE10 =  NEW_REFERENCES.ATTRIBUTE10,
    ATTRIBUTE11 =  NEW_REFERENCES.ATTRIBUTE11,
    ATTRIBUTE12 =  NEW_REFERENCES.ATTRIBUTE12,
    ATTRIBUTE13 =  NEW_REFERENCES.ATTRIBUTE13,
    ATTRIBUTE14 =  NEW_REFERENCES.ATTRIBUTE14,
    ATTRIBUTE15 =  NEW_REFERENCES.ATTRIBUTE15,
    ATTRIBUTE16 =  NEW_REFERENCES.ATTRIBUTE16,
    ATTRIBUTE17 =  NEW_REFERENCES.ATTRIBUTE17,
    ATTRIBUTE18 =  NEW_REFERENCES.ATTRIBUTE18,
    ATTRIBUTE19 =  NEW_REFERENCES.ATTRIBUTE19,
    ATTRIBUTE20 =  NEW_REFERENCES.ATTRIBUTE20
  WHERE ROWID = X_ROWID;
  IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  After_DML (
            p_action     => 'UPDATE',
            x_rowid      =>  X_ROWID
            );


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

END UPDATE_ROW;

PROCEDURE ADD_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_ORG_ID IN NUMBER,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_ADVANCED_STANDING_IND IN VARCHAR2,
  X_FEE_CAT IN VARCHAR2,
  X_CORRESPONDENCE_CAT IN VARCHAR2,
  X_SELF_HELP_GROUP_IND IN VARCHAR2,
  X_LOGICAL_DELETE_DT IN DATE,
  X_ADM_ADMISSION_APPL_NUMBER IN NUMBER,
  X_ADM_NOMINATED_COURSE_CD IN VARCHAR2,
  X_ADM_SEQUENCE_NUMBER IN NUMBER,
  X_VERSION_NUMBER IN NUMBER,
  X_CAL_TYPE IN VARCHAR2,
  X_LOCATION_CD IN VARCHAR2,
  X_ATTENDANCE_MODE IN VARCHAR2,
  X_ATTENDANCE_TYPE IN VARCHAR2,
  X_COO_ID IN NUMBER,
  X_STUDENT_CONFIRMED_IND IN VARCHAR2,
  X_COMMENCEMENT_DT IN DATE,
  X_COURSE_ATTEMPT_STATUS IN VARCHAR2,
  X_PROGRESSION_STATUS IN VARCHAR2,
  X_DERIVED_ATT_TYPE IN VARCHAR2,
  X_DERIVED_ATT_MODE IN VARCHAR2,
  X_PROVISIONAL_IND IN VARCHAR2,
  X_DISCONTINUED_DT IN DATE,
  X_DISCONTINUATION_REASON_CD IN VARCHAR2,
  X_LAPSED_DT IN DATE,
  X_FUNDING_SOURCE IN VARCHAR2,
  X_EXAM_LOCATION_CD IN VARCHAR2,
  X_DERIVED_COMPLETION_YR IN NUMBER,
  X_DERIVED_COMPLETION_PERD IN VARCHAR2,
  X_NOMINATED_COMPLETION_YR IN NUMBER,
  X_NOMINATED_COMPLETION_PERD IN VARCHAR2,
  X_RULE_CHECK_IND IN VARCHAR2,
  X_WAIVE_OPTION_CHECK_IND IN VARCHAR2,
  X_LAST_RULE_CHECK_DT IN DATE,
  X_PUBLISH_OUTCOMES_IND IN VARCHAR2,
  X_COURSE_RQRMNT_COMPLETE_IND IN VARCHAR2,
  X_COURSE_RQRMNTS_COMPLETE_DT IN DATE,
  X_S_COMPLETED_SOURCE_TYPE IN VARCHAR2,
  X_OVERRIDE_TIME_LIMITATION IN NUMBER,
  X_MODE IN VARCHAR2,
  X_LAST_DATE_OF_ATTENDANCE IN DATE,
  X_DROPPED_BY IN VARCHAR2,
  X_IGS_PR_CLASS_STD_ID IN NUMBER,
  X_PRIMARY_PROGRAM_TYPE IN VARCHAR2,
  X_PRIMARY_PROG_TYPE_SOURCE IN VARCHAR2,
  X_CATALOG_CAL_TYPE IN VARCHAR2,
  X_CATALOG_SEQ_NUM IN NUMBER ,
  X_KEY_PROGRAM  IN VARCHAR2,
  X_MANUAL_OVR_CMPL_DT_IND IN VARCHAR2,
  X_OVERRIDE_CMPL_DT IN DATE,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE16 IN VARCHAR2,
  X_ATTRIBUTE17 IN VARCHAR2,
  X_ATTRIBUTE18 IN VARCHAR2,
  X_ATTRIBUTE19 IN VARCHAR2,
  x_ATTRIBUTE20 IN VARCHAR2,
  X_FUTURE_DATED_TRANS_FLAG IN VARCHAR2
  ) AS
  CURSOR c1 IS SELECT ROWID FROM IGS_EN_STDNT_PS_ATT_ALL
     WHERE PERSON_ID = X_PERSON_ID
     AND COURSE_CD = X_COURSE_CD;
BEGIN
  OPEN c1;
  FETCH c1 INTO X_ROWID;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    INSERT_ROW (
     X_ROWID,
     x_org_id,
     X_PERSON_ID,
     X_COURSE_CD,
     X_ADVANCED_STANDING_IND,
     X_FEE_CAT,
     X_CORRESPONDENCE_CAT,
     X_SELF_HELP_GROUP_IND,
     X_LOGICAL_DELETE_DT,
     X_ADM_ADMISSION_APPL_NUMBER,
     X_ADM_NOMINATED_COURSE_CD,
     X_ADM_SEQUENCE_NUMBER,
     X_VERSION_NUMBER,
     X_CAL_TYPE,
     X_LOCATION_CD,
     X_ATTENDANCE_MODE,
     X_ATTENDANCE_TYPE,
     X_COO_ID,
     X_STUDENT_CONFIRMED_IND,
     X_COMMENCEMENT_DT,
     X_COURSE_ATTEMPT_STATUS,
     X_PROGRESSION_STATUS,
     X_DERIVED_ATT_TYPE,
     X_DERIVED_ATT_MODE,
     X_PROVISIONAL_IND,
     X_DISCONTINUED_DT,
     X_DISCONTINUATION_REASON_CD,
     X_LAPSED_DT,
     X_FUNDING_SOURCE,
     X_EXAM_LOCATION_CD,
     X_DERIVED_COMPLETION_YR,
     X_DERIVED_COMPLETION_PERD,
     X_NOMINATED_COMPLETION_YR,
     X_NOMINATED_COMPLETION_PERD,
     X_RULE_CHECK_IND,
     X_WAIVE_OPTION_CHECK_IND,
     X_LAST_RULE_CHECK_DT,
     X_PUBLISH_OUTCOMES_IND,
     X_COURSE_RQRMNT_COMPLETE_IND,
     X_COURSE_RQRMNTS_COMPLETE_DT,
     X_S_COMPLETED_SOURCE_TYPE,
     X_OVERRIDE_TIME_LIMITATION,
     X_MODE,
     X_LAST_DATE_OF_ATTENDANCE,
     X_DROPPED_BY,
     X_IGS_PR_CLASS_STD_ID,
     X_PRIMARY_PROGRAM_TYPE,
     X_PRIMARY_PROG_TYPE_SOURCE,
     X_CATALOG_CAL_TYPE,
     X_CATALOG_SEQ_NUM,
     X_KEY_PROGRAM  ,
     X_MANUAL_OVR_CMPL_DT_IND,
     X_OVERRIDE_CMPL_DT,
     X_ATTRIBUTE_CATEGORY,
     X_FUTURE_DATED_TRANS_FLAG,
     X_ATTRIBUTE1,
     X_ATTRIBUTE2,
     X_ATTRIBUTE3,
     X_ATTRIBUTE4,
     X_ATTRIBUTE5,
     X_ATTRIBUTE6,
     X_ATTRIBUTE7,
     X_ATTRIBUTE8,
     X_ATTRIBUTE9,
     X_ATTRIBUTE10,
     X_ATTRIBUTE11,
     X_ATTRIBUTE12,
     X_ATTRIBUTE13,
     X_ATTRIBUTE14,
     X_ATTRIBUTE15,
     X_ATTRIBUTE16,
     X_ATTRIBUTE17,
     X_ATTRIBUTE18,
     X_ATTRIBUTE19,
     X_ATTRIBUTE20
    );
    RETURN;
  END IF;
  CLOSE c1;

  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_ADVANCED_STANDING_IND,
   X_FEE_CAT,
   X_CORRESPONDENCE_CAT,
   X_SELF_HELP_GROUP_IND,
   X_LOGICAL_DELETE_DT,
   X_ADM_ADMISSION_APPL_NUMBER,
   X_ADM_NOMINATED_COURSE_CD,
   X_ADM_SEQUENCE_NUMBER,
   X_VERSION_NUMBER,
   X_CAL_TYPE,
   X_LOCATION_CD,
   X_ATTENDANCE_MODE,
   X_ATTENDANCE_TYPE,
   X_COO_ID,
   X_STUDENT_CONFIRMED_IND,
   X_COMMENCEMENT_DT,
   X_COURSE_ATTEMPT_STATUS,
   X_PROGRESSION_STATUS,
   X_DERIVED_ATT_TYPE,
   X_DERIVED_ATT_MODE,
   X_PROVISIONAL_IND,
   X_DISCONTINUED_DT,
   X_DISCONTINUATION_REASON_CD,
   X_LAPSED_DT,
   X_FUNDING_SOURCE,
   X_EXAM_LOCATION_CD,
   X_DERIVED_COMPLETION_YR,
   X_DERIVED_COMPLETION_PERD,
   X_NOMINATED_COMPLETION_YR,
   X_NOMINATED_COMPLETION_PERD,
   X_RULE_CHECK_IND,
   X_WAIVE_OPTION_CHECK_IND,
   X_LAST_RULE_CHECK_DT,
   X_PUBLISH_OUTCOMES_IND,
   X_COURSE_RQRMNT_COMPLETE_IND,
   X_COURSE_RQRMNTS_COMPLETE_DT,
   X_S_COMPLETED_SOURCE_TYPE,
   X_OVERRIDE_TIME_LIMITATION,
   X_MODE,
   X_LAST_DATE_OF_ATTENDANCE,
   X_DROPPED_BY,
   X_IGS_PR_CLASS_STD_ID,
   X_PRIMARY_PROGRAM_TYPE,
   X_PRIMARY_PROG_TYPE_SOURCE,
   X_CATALOG_CAL_TYPE,
   X_CATALOG_SEQ_NUM,
   X_KEY_PROGRAM,
   X_MANUAL_OVR_CMPL_DT_IND,
   X_OVERRIDE_CMPL_DT,
   X_ATTRIBUTE_CATEGORY,
   X_FUTURE_DATED_TRANS_FLAG,
   X_ATTRIBUTE1,
   X_ATTRIBUTE2,
   X_ATTRIBUTE3,
   X_ATTRIBUTE4,
   X_ATTRIBUTE5,
   X_ATTRIBUTE6,
   X_ATTRIBUTE7,
   X_ATTRIBUTE8,
   X_ATTRIBUTE9,
   X_ATTRIBUTE10,
   X_ATTRIBUTE11,
   X_ATTRIBUTE12,
   X_ATTRIBUTE13,
   X_ATTRIBUTE14,
    X_ATTRIBUTE15,
   X_ATTRIBUTE16,
   X_ATTRIBUTE17,
   X_ATTRIBUTE18,
   X_ATTRIBUTE19,
    X_ATTRIBUTE20
  );
END ADD_ROW;

PROCEDURE DELETE_ROW (X_ROWID IN VARCHAR2,
  x_mode IN VARCHAR2)
 AS
BEGIN
  Before_DML (
    p_action => 'DELETE',
    x_rowid =>   X_ROWID
  );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  DELETE FROM IGS_EN_STDNT_PS_ATT_ALL
  WHERE ROWID = X_ROWID;
  IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    After_DML (
            p_action     => 'DELETE',
            x_rowid      =>  X_ROWID
            );

END DELETE_ROW;

PROCEDURE beforerowdelete AS
  ------------------------------------------------------------------
  --Created by  : rnirwani
  --Date created: 03-Jan-03
  --
  --Purpose: Validation to ensure that delation is not allowed
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR c_spa_stat (cp_person_id igs_en_stdnt_ps_att_all.person_id%TYPE,
                     cp_course_cd igs_en_stdnt_ps_att_all.course_cd%TYPE) IS
  SELECT course_attempt_status
    FROM igs_en_stdnt_ps_att_all
   WHERE person_id = cp_person_id
     AND course_cd = cp_course_cd;

  lv_crs_attmpt_stat igs_en_stdnt_ps_att_all.course_attempt_status%TYPE;
BEGIN

-- Deletion is allowed only in case the record has an attempt status of UNCONFIRM.

  OPEN c_spa_stat (old_references.person_id,old_references.course_cd);
  FETCH c_spa_stat INTO lv_crs_attmpt_stat;
  CLOSE c_spa_stat;

  IF lv_crs_attmpt_stat <> 'UNCONFIRM' THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_EN_CANDEL_UNCNFRM_SPA');
    igs_ge_msg_stack.add;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

END beforerowdelete;

PROCEDURE enrp_ins_upd_term_rec( P_ACTION IN VARCHAR2)
IS
  ------------------------------------------------------------------
  --Created by  : ptandon , Oracle India
  --Date created: 28-NOV-2003
  --
  --Purpose: This procedure checks whether to create/update term
  --         records.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --stutta    16-Mar-2004   Passing new parameter p_update_rec in call
  --                        to igs_en_spa_terms_api.create_update_term_rec.
  --                        Bug # 3421436
  --stutta    7-Jan-2005    Allow term record creation whether any attributes
  --                        change or not if called from PROGRAM_TRANSFER
  --stutta    1-Dec-2005    Delete terms when Unconfirming program irrespective
  --                        of whether its a PRIMARY program or not.Bug#4752409
  -------------------------------------------------------------------

-- Cursor to get the effective term calendar.
CURSOR cur_get_effective_term(cp_person_id igs_en_stdnt_ps_att.person_id%TYPE,
                              cp_program_cd igs_en_stdnt_ps_att.course_cd%TYPE,
                              cp_prg_completion_dt igs_en_stdnt_ps_att.course_rqrmnts_complete_dt%TYPE) IS
   SELECT ci.cal_type, ci.sequence_number
   FROM   igs_ca_inst ci,
          igs_ca_inst_rel cir,
          igs_ca_type ct,
          igs_en_stdnt_ps_att sca,
          igs_ca_stat cs
   WHERE  sca.person_id = cp_person_id AND
          sca.course_cd = cp_program_cd AND
          cir.sup_cal_type = sca.cal_type AND
          ci.cal_type = cir.sub_cal_type AND
          ci.sequence_number = cir.sub_ci_sequence_number AND
          ct.cal_type = ci.cal_type AND
          ct.s_cal_cat = 'LOAD' AND
          cs.cal_status = ci.cal_status AND
          cs.s_cal_status = 'ACTIVE' AND
          igs_en_gen_015.get_effective_census_date(ci.cal_type,ci.sequence_number,NULL,NULL) > cp_prg_completion_dt
          ORDER BY ci.start_dt;

   l_message_name          VARCHAR2(100);
   l_create_update_term    BOOLEAN;
   l_prg_completion_date   igs_en_stdnt_ps_att_all.course_rqrmnts_complete_dt%TYPE;
   l_term_cal_type         igs_ca_inst.cal_type%TYPE;
   l_term_ci_seq_num       igs_ca_inst.sequence_number%TYPE;

BEGIN

  -- If the system is in program model or the program attempt is primary.
  IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'N' OR new_references.primary_program_type = 'PRIMARY' THEN

           l_term_cal_type := NULL;
           l_term_ci_seq_num := NULL;
           l_create_update_term := FALSE;

           IF (P_ACTION = 'UPDATE') THEN
                IF (new_references.course_attempt_status = 'COMPLETED' AND new_references.primary_program_type = 'PRIMARY') THEN
                                OPEN cur_get_effective_term(new_references.person_id,
                                             new_references.course_cd,
                                             new_references.course_rqrmnts_complete_dt);
                         FETCH cur_get_effective_term INTO l_term_cal_type,l_term_ci_seq_num;
                         CLOSE cur_get_effective_term;
                         IF (l_term_cal_type IS NOT NULL AND l_term_ci_seq_num IS NOT NULL) THEN
						igs_en_spa_terms_api.create_update_term_rec(
                                                        p_person_id => new_references.person_id,
                                                        p_program_cd => new_references.course_cd,
                                                        p_term_cal_type => l_term_cal_type,
                                                        p_term_sequence_number => l_term_ci_seq_num,
                                                        p_ripple_frwrd => FALSE, -- ripple forward
                                                        p_message_name => l_message_name,
                                                        p_update_rec => TRUE);
                         END IF;

               END IF;
           END IF;
   END IF;

    -- if course attempt status is changing (updated) to UNCONFIRM
  IF (new_references.course_attempt_status = 'UNCONFIRM' AND old_references.course_attempt_status IS NOT NULL
      AND old_references.course_attempt_status <> new_references.course_attempt_status ) THEN
                                -- For a term which is moving from a confirmed status to an unconfirmed status
                                -- Delete all future term records from the current term for an unconfirmed program.
                                igs_en_spa_terms_api.delete_terms_for_program(
                                                p_person_id => new_references.person_id,
                                                p_program_cd => new_references.course_cd);
   END IF;



END enrp_ins_upd_term_rec;

END Igs_En_Stdnt_Ps_Att_Pkg;

/
