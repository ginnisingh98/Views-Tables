--------------------------------------------------------
--  DDL for Package Body IGS_AS_SU_SETATMPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SU_SETATMPT_PKG" AS
/* $Header: IGSDI29B.pls 120.2 2006/05/29 07:53:01 sarakshi noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AS_SU_SETATMPT%ROWTYPE;
  new_references IGS_AS_SU_SETATMPT%ROWTYPE;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_person_id IN NUMBER ,
    x_course_cd IN VARCHAR2 ,
    x_unit_set_cd IN VARCHAR2 ,
    x_us_version_number IN NUMBER ,
    x_sequence_number IN NUMBER ,
    x_selection_dt IN DATE ,
    x_student_confirmed_ind IN VARCHAR2 ,
    x_end_dt IN DATE ,
    x_parent_unit_set_cd IN VARCHAR2 ,
    x_parent_sequence_number IN NUMBER ,
    x_primary_set_ind IN VARCHAR2 ,
    x_voluntary_end_ind IN VARCHAR2 ,
    x_authorised_person_id IN NUMBER ,
    x_authorised_on IN DATE ,
    x_override_title IN VARCHAR2 ,
    x_rqrmnts_complete_ind IN VARCHAR2 ,
    x_rqrmnts_complete_dt IN DATE ,
    x_s_completed_source_type IN VARCHAR2 ,
    x_catalog_cal_type IN VARCHAR2 ,
    x_catalog_seq_num IN NUMBER ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2 ,
    x_attribute11 IN VARCHAR2 ,
    x_attribute12 IN VARCHAR2 ,
    x_attribute13 IN VARCHAR2 ,
    x_attribute14 IN VARCHAR2 ,
    x_attribute15 IN VARCHAR2 ,
    x_attribute16 IN VARCHAR2 ,
    x_attribute17 IN VARCHAR2 ,
    x_attribute18 IN VARCHAR2 ,
    x_attribute19 IN VARCHAR2 ,
    x_attribute20 IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_SU_SETATMPT
      WHERE    ROWID = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      CLOSE cur_old_ref_values;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.us_version_number := x_us_version_number;
    new_references.sequence_number := x_sequence_number;
    new_references.selection_dt := x_selection_dt;
    new_references.student_confirmed_ind := x_student_confirmed_ind;
    new_references.end_dt := x_end_dt;
    new_references.parent_unit_set_cd := x_parent_unit_set_cd;
    new_references.parent_sequence_number := x_parent_sequence_number;
    new_references.primary_set_ind := x_primary_set_ind;
    new_references.voluntary_end_ind := x_voluntary_end_ind;
    new_references.authorised_person_id := x_authorised_person_id;
    new_references.authorised_on := x_authorised_on;
    new_references.override_title := x_override_title;
    new_references.rqrmnts_complete_ind := x_rqrmnts_complete_ind;
    new_references.rqrmnts_complete_dt := x_rqrmnts_complete_dt;
    new_references.s_completed_source_type := x_s_completed_source_type;
    new_references.catalog_cal_type := x_catalog_cal_type;
    new_references.catalog_seq_num := x_catalog_seq_num;
    new_references.attribute_category:= x_attribute_category;
    new_references.attribute1:= x_attribute1;
    new_references.attribute2:= x_attribute2;
    new_references.attribute3:= x_attribute3;
    new_references.attribute4:= x_attribute4;
    new_references.attribute5:= x_attribute5;
    new_references.attribute6:= x_attribute6;
    new_references.attribute7:= x_attribute7;
    new_references.attribute8:= x_attribute8;
    new_references.attribute9:= x_attribute9;
    new_references.attribute10:= x_attribute10;
    new_references.attribute11:= x_attribute11;
    new_references.attribute12:= x_attribute12;
    new_references.attribute13:= x_attribute13;
    new_references.attribute14:= x_attribute14;
    new_references.attribute15:= x_attribute15;
    new_references.attribute16:= x_attribute16;
    new_references.attribute17:= x_attribute17;
    new_references.attribute18:= x_attribute18;
    new_references.attribute19:= x_attribute19;
    new_references.attribute20:= x_attribute20;
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
  END Set_Column_Values;
  -- Trigger description :-
  -- "OSS_TST".trg_susa_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_AS_SU_SETATMPT
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
    -- check whether the unit set is a valid one for the prorgam offering option
   CURSOR c_us_valid IS
     SELECT 'x'
       FROM IGS_PS_OFR_OPT_UNIT_SET_V usoo,
 	   IGS_EN_STDNT_PS_ATT spa
      WHERE spa.person_id = new_references.person_id
        AND spa.course_cd = new_references.course_cd
        AND usoo.unit_set_cd = new_references.unit_set_cd
        AND usoo.us_version_number = new_references.us_version_number
        AND usoo.coo_id = spa.coo_id;

   l_dummy VARCHAR2(1);

   v_message_name  VARCHAR2(30);
  BEGIN
    -- verify if this unit set is a valid unit set for the program offering option
 	IF p_updating THEN
 		OPEN c_us_valid;
 		FETCH c_us_valid INTO l_dummy;
 		IF c_us_valid%NOTFOUND THEN
 	            CLOSE c_us_valid;
         	    Fnd_Message.Set_Name('IGS', 'IGS_EN_UNIT_SETNOT_PERMITTED');
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
 		END IF;
 		CLOSE c_us_valid;
 	END IF;

        -- If trigger has not been disabled, perform required processing
        -- Warning: disabling has been done for IGS_EN_GEN_013.ENRP_UPD_SUSA_END_DT and
        -- IGS_EN_GEN_013.ENRP_UPD_SUSA_SCI processing which occurs within the after statment
        -- trigger. If wishing to disable the triggers, use a different table name as
        -- an identifier eg. 'STUDENT_UNIT_SET_ATTEMPT2'
        -- IGS_GE_NOTE: Any alterations to susa triggers should be applied to module
        -- enrp_val_susa.
        IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_AS_SU_SETATMPT') THEN
                IF p_inserting THEN
                        -- Validate the the IGS_PS_UNIT set is able to be created.
                        -- against the student IGS_PS_COURSE attempt.
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_sca(
                                                new_references.person_id,
                                                new_references.course_cd,
                                                   v_message_name ) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                        END IF;
                        -- Validate the the IGS_PS_UNIT set is able to be created.
                        -- The student cannot have completed it previously,
                        -- no encumbrances must exist and it must be applicable
                        -- to the IGS_PS_COURSE offering.
                        -- p_legacy value passed as 'N' as function is called in non-legacy mode
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_ins(
                                                new_references.person_id,
                                                new_references.course_cd,
                                                new_references.unit_set_cd,
                                                new_references.sequence_number,
                                                new_references.us_version_number,
                                                v_message_name,
                                                'N') = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Validate that the authorisation fields can only be set when end date is set
                -- or the IGS_PS_UNIT set cd requires authorisation (IGS_EN_UNIT_SET.authorisation_ind =
                -- 'Y')
                IF p_inserting OR
                  (p_updating AND
                   ((NVL(new_references.authorised_person_id, 0) <>
                                NVL(old_references.authorised_person_id, 0)) OR
                    (NVL(new_references.authorised_on,IGS_GE_DATE.IGSDATE('1900/01/01'))
                         <> NVL(old_references.authorised_on, IGS_GE_DATE.IGSDATE('1900/01/01'))))) THEN

                         -- p_legacy value passed as 'N' as function is called in non-legacy mode
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_auth(
                                        new_references.unit_set_cd,
                                        new_references.us_version_number,
                                        new_references.end_dt,
                                        new_references.authorised_person_id,
                                        new_references.authorised_on,
                                        v_message_name,
                                        'N') = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                        END IF;
                END IF;
                IF p_inserting OR
                  (p_updating AND
                   ((NVL(new_references.authorised_person_id, 0) <>
                                NVL(old_references.authorised_person_id, 0)) OR
                    (new_references.student_confirmed_ind <> old_references.student_confirmed_ind) OR
                    (NVL(new_references.authorised_on,IGS_GE_DATE.IGSDATE('1900/01/01'))
                         <> NVL(old_references.authorised_on, IGS_GE_DATE.IGSDATE('1900/01/01'))))) THEN
                        -- Validate that the authorisation fields must be set when
                        -- the IGS_PS_UNIT set cd requires authorisation (IGS_EN_UNIT_SET.authorisation_ind = 'Y')
                        -- Check required only when the IGS_PS_UNIT set is confirmed.
                        IF (new_references.student_confirmed_ind = 'Y') THEN
                                IF IGS_EN_VAL_SUSA.enrp_val_susa_us_ath(
                                                new_references.unit_set_cd,
                                                new_references.us_version_number,
                                                new_references.authorised_person_id,
                                                new_references.authorised_on,
                                                v_message_name ) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                END IF;
                -- Validate that the completion fields can only be set when IGS_PS_UNIT set is
                -- confirmed
                IF p_inserting OR
                  (p_updating AND
                   ((NVL(new_references.rqrmnts_complete_ind, 'x')
                        <> NVL(old_references.rqrmnts_complete_ind, 'x')) OR
                    (NVL(new_references.rqrmnts_complete_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
                         <> NVL(old_references.rqrmnts_complete_dt,
                                IGS_GE_DATE.IGSDATE('1900/01/01')))))THEN

                        -- p_legacy value passed as 'N' as function is called in non-legacy mode
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_cmplt(
                                        new_references.rqrmnts_complete_dt,
                                        new_references.rqrmnts_complete_ind,
                                        new_references.student_confirmed_ind,
                                        v_message_name,
                                        'N') = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Validate that the system competed source type field can only be
                -- set when completion fields are set.
                IF p_inserting OR
                  (p_updating AND
                   ((NVL(new_references.rqrmnts_complete_ind, 'x')
                        <> NVL(old_references.rqrmnts_complete_ind, 'x')) OR
                    (NVL(new_references.s_completed_source_type, 'x')
                        <> NVL(old_references.s_completed_source_type, 'x')) OR
                    (NVL(new_references.rqrmnts_complete_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
                         <> NVL(old_references.rqrmnts_complete_dt,
                                IGS_GE_DATE.IGSDATE('1900/01/01')))))THEN
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_scst(
                                        new_references.rqrmnts_complete_dt,
                                        new_references.rqrmnts_complete_ind,
                                        new_references.s_completed_source_type,
                                        v_message_name ) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- The peice of code was existing here to Validate the date fields. Which got removed in UK Enhancement Build.
                -- Enh Bug#2580731. The code was raising exception if the Selection_dt, end_dt or rqrmnts_complete_dt is more than sysdate.

                -- Validate that the selection date can only be set/unset when IGS_PS_UNIT set is
                -- confirmed/unconfirmed
                IF p_inserting OR
                  (p_updating AND
                   ((new_references.student_confirmed_ind <> old_references.student_confirmed_ind) OR
                    (NVL(new_references.selection_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
                         <> NVL(old_references.selection_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))))) THEN

                         -- p_legacy value passed as 'N' as function is called in non-legacy mode
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_sci_sd(
                                        new_references.student_confirmed_ind,
                                        new_references.selection_dt,
                                        v_message_name,
                                        'N') = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Validate that the voluntary_end_ind can only be set when the end date is
                -- set.
                IF p_inserting OR
                  (p_updating AND
                   ((new_references.voluntary_end_ind <> old_references.voluntary_end_ind) OR
                    (NVL(new_references.end_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
                         <> NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))))) THEN
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_end_vi(
                                        new_references.voluntary_end_ind,
                                        new_references.end_dt,
                                        v_message_name ) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                        END IF;
                END IF;
                -- Validate that the IGS_PS_UNIT set version number cannot be updated.
                IF (p_updating AND
                   (new_references.us_version_number <> old_references.us_version_number)) THEN
                     Fnd_Message.Set_Name('IGS', 'IGS_EN_UNIT_SET_VERNUM_NOTUPD');
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                END IF;
                IF p_deleting THEN
                        -- Validate that the records can be deleted.
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_del(
                                                old_references.person_id,
                                                old_references.course_cd,
                                                old_references.unit_set_cd,
                                                old_references.sequence_number,
                                                old_references.us_version_number,
                                                old_references.end_dt,
                                                old_references.rqrmnts_complete_ind,
                                                'Y', -- indicating this is called from db trigger.
                                                v_message_name ) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                        END IF;
                END IF;
        END IF;
  END BeforeRowInsertUpdateDelete1;
  PROCEDURE RowValMutation(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN ,
    p_parent_unit_set_cd IN VARCHAR2 ,
    p_end_dt IN DATE ,
    p_student_confirmed_ind IN VARCHAR2 ,
    p_primary_set_ind IN VARCHAR2
    ) AS
        v_insert                BOOLEAN;
        v_update                BOOLEAN;
        v_delete                BOOLEAN;
        cst_error               CONSTANT        CHAR := 'E';
   v_message_name  VARCHAR2(30);
  BEGIN
        IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_AS_SU_SETATMPT') THEN
                IF p_inserting THEN
                        -- Validate the the unit set is able to be created
                        -- with the unit set status being valid and the
                        -- expiry date not set. If set then person must have
                        -- previously selected it.
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_us_act(
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.unit_set_cd,
                                        new_references.sequence_number,
                                        new_references.us_version_number,
                                        v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                        END IF;
                END IF;
                IF (p_inserting OR p_updating) AND
                   p_parent_unit_set_cd  IS NOT NULL THEN
                        -- Validate if the unit set is to be defined as a subordinate or if
                        -- relationship specified, that it is valid within the course offering.
                        -- p_legacy value passed as 'N' as function is called in non-legacy mode
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_cousr(
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.unit_set_cd,
                                        new_references.us_version_number,
                                        new_references.parent_unit_set_cd,
                                        new_references.parent_sequence_number,
                                        cst_error,
                                        v_message_name,
                                        'N') = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                        END IF;
                        -- Validate if the parent unit set has a null end date, unit set is
                        -- not being linked to itself (directly or indirectly). Cannot be
                        -- confirmed if parent is unconfirmed.
                        -- p_legacy value passed as 'N' as function is called in non-legacy mode
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_parent(
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.unit_set_cd,
                                        new_references.sequence_number,
                                        new_references.parent_unit_set_cd,
                                        new_references.parent_sequence_number,
                                        new_references.student_confirmed_ind,
                                        v_message_name,
                                        'N') = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                        END IF;
                END IF;
                IF (p_inserting OR p_updating) AND
                   p_end_dt IS NOT NULL THEN
                        -- Validate the end date, check if the authorisation details
                        -- need to be set or if more than one open end dated instance
                        -- of the unit set exists. Also cannot be cleared if parent ended.
                        -- If part of the admissions offer, authorisation required to end
                        -- the unit set.
                        -- p_legacy value passed as 'N' as function is called in non-legacy mode
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_end_dt(
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.unit_set_cd,
                                        new_references.sequence_number,
                                        new_references.us_version_number,
                                        new_references.end_dt,
                                        new_references.authorised_person_id,
                                        new_references.authorised_on,
                                        new_references.parent_unit_set_cd,
                                        new_references.parent_sequence_number,
                                        cst_error,
                                        v_message_name,
                                        'N') = FALSE THEN
                                -- Check if warning message returned.
                                IF v_message_name <> 'IGS_EN_UNITSET_REQ_AUTHORISAT' THEN
                                     Fnd_Message.Set_Name('IGS', v_message_name);
                                     IGS_GE_MSG_STACK.ADD;
                                     App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                        -- If updating and the end date has been set, cascade the end date
                        -- through to any descendant unit sets (Inserted records cannot have
                        -- children at that point).
                        IF p_updating AND
                            new_references.end_dt IS NOT NULL THEN
                                IF IGS_EN_GEN_013.ENRP_UPD_SUSA_END_DT(
                                                new_references.person_id,
                                                new_references.course_cd,
                                                new_references.unit_set_cd,
                                                new_references.sequence_number,
                                                new_references.end_dt,
                                                new_references.voluntary_end_ind,
                                                new_references.authorised_person_id,
                                                new_references.authorised_on,
                                                v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                END IF;
                IF (p_inserting OR p_updating) AND
                   p_student_confirmed_ind IS NOT NULL THEN
                        -- Validate that the unit set is not confirmed when the student course
                        -- attempt is unconfirmed.
                        -- Also check that not unset one end date or complete date set. Cannot be
                        -- confirmed and linked to a parent that is unconfirmed. Cannot be
                        -- confirmed if encumbrances exist.
                        -- p_legacy value passed as 'N' as function is called in non-legacy mode
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_sci(
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.unit_set_cd,
                                        new_references.sequence_number,
                                        new_references.us_version_number,
                                        new_references.parent_unit_set_cd,
                                        new_references.parent_sequence_number,
                                        new_references.student_confirmed_ind,
                                        new_references.selection_dt,
                                        new_references.end_dt,
                                        new_references.rqrmnts_complete_ind,
                                        v_message_name,
                                        'N') = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                        END IF;
                        -- If updating and the student confirmed indicator is being unset,
                        -- then unset any descendant unit sets. (Only concerned with update
                        -- as unit set cannot have descendant at the point of creation).
                        IF p_updating AND
                            new_references.student_confirmed_ind = 'N' THEN
                                IF IGS_EN_GEN_013.ENRP_UPD_SUSA_SCI(
                                                new_references.person_id,
                                                new_references.course_cd,
                                                new_references.unit_set_cd,
                                                new_references.sequence_number,
                                                new_references.student_confirmed_ind,
                                                v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                                END IF;
                        END IF;
                END IF;
                IF (p_inserting OR p_updating) AND
                   p_primary_set_ind  IS NOT NULL THEN
                        -- Validate the primary set indicator is only set for
                        -- non-administrative sets and that there does not already
                        -- exist a unit set that has a higher rank.
                        -- p_legacy value passed as 'N' as function is called in non-legacy mode
                        IF IGS_EN_VAL_SUSA.enrp_val_susa_prmry(
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.unit_set_cd,
                                        new_references.us_version_number,
                                        new_references.primary_set_ind,
                                        v_message_name,
                                        'N') = FALSE THEN
                             Fnd_Message.Set_Name('IGS', v_message_name);
                             IGS_GE_MSG_STACK.ADD;
                             App_Exception.Raise_Exception;
                        END IF;
                END IF;
        END IF;
  END RowValMutation;
  -- Trigger description :-
  -- "OSS_TST".trg_susa_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_SU_SETATMPT
  -- FOR EACH ROW
  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
  ------------------------------------------------------------------------------
  -- Change History:
  -- Who         When            What
  -- SVANUKUR    27-NOV-2003      added logic to create a TODO record of the TODO type FEE_RECALC
  --                              If a record is being inserted/updated/deleted
  ------------------------------------------------------------------------------
        v_tmp_end_dt    DATE;
        v_sequence_number NUMBER;
        v_unit_set VARCHAR2(1);

        --check if the unit set attempt being inserted/update/deleted is
        --of type 'PRE-ENROLL'
        CURSOR c_unit_set(cp_unit_set_cd IGS_EN_UNIT_SET.unit_set_cd%TYPE) IS
        SELECT 'X'
        FROM IGS_EN_UNIT_SET us,
             IGS_EN_UNIT_SET_CAT usc
        WHERE us.unit_set_cd = cp_unit_set_cd
        AND us.unit_set_cat = usc.unit_set_cat
        AND usc.unit_set_cat = 'PRE-ENROLL';



  BEGIN
        -- If trigger has not been disabled, perform required processing
        -- Warning: disabling has been done for IGS_EN_GEN_013.ENRP_UPD_SUSA_END_DT and
        -- IGS_EN_GEN_013.ENRP_UPD_SUSA_SCI processing which occurs within the after statment
        -- trigger. If wishing to disable the triggers, use a different table name as
        -- an identifier eg. 'STUDENT_UNIT_SET_ATTEMPT2'
        IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_AS_SU_SETATMPT') THEN
                -- Validate the the IGS_PS_UNIT set is able to be created
                -- with the IGS_PS_UNIT set status being valid and the
                -- expiry date not set. If set then IGS_PE_PERSON must have
                -- previously selected it.
                IF p_inserting THEN
                        -- Validate the the IGS_PS_UNIT set is able to be created
                        -- with the IGS_PS_UNIT set status being valid and the
                        -- expiry date not set. If set then IGS_PE_PERSON must have
                        -- previously selected it. (IGS_EN_VAL_SUSA.enrp_val_susa_us_act)
                        -- Cannot call modules because trigger will be mutating.
                        -- Save the rowid of the current row.
                        RowValMutation(
                                p_inserting ,
                                p_updating ,
                                p_deleting ,
                                NULL ,
                                NULL ,
                                'N',
                                'N'
                                );
                END IF;
                -- Validate if the IGS_PS_UNIT set parent relationship.
                IF p_inserting OR
                  (p_updating AND
                   ((NVL(new_references.parent_unit_set_cd, 'NULL')
                        <> NVL(old_references.parent_unit_set_cd, 'NULL')) OR
                   (NVL(new_references.parent_sequence_number, 0)
                        <> NVL(old_references.parent_sequence_number, 0)))) THEN
                        -- Validate if the IGS_PS_UNIT set is to be defined as a subordinate or if
                        -- relationship specified, that it is valid within the IGS_PS_COURSE offering
                        -- (IGS_EN_VAL_SUSA.enrp_val_susa_cousr).
                        -- Validate if the parent IGS_PS_UNIT set has a null end date, IGS_PS_UNIT set is
                        -- not being linked to itself (directly or indirectly). Cannot be
                        -- confirmed if parent is unconfirmed (IGS_EN_VAL_SUSA.enrp_val_susa_parent).
                        -- Cannot call modules because trigger will be mutating.
                        -- Save the rowid of the current row setting the parent IGS_PS_UNIT set field to
                        -- indicate to perform parent IGS_PS_UNIT set code validation
                        RowValMutation(
                                p_inserting ,
                                p_updating ,
                                p_deleting ,
                                new_references.parent_unit_set_cd ,
                                NULL ,
                                'N',
                                'N'
                                );
                END IF;
                -- Validate the end date, check if the authorisation details
                -- need to be set or if more than one open end dated instance
                -- of the IGS_PS_UNIT set exists. Also cannot be cleared if parent ended.
                -- If part of the admissions offer, authorisation required to end
                -- the IGS_PS_UNIT set.
                IF p_inserting OR
                    (NVL(new_references.end_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))
                         <> NVL(old_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
                        -- Store away the rowid as the validation will cause a mutating trigger.
                        -- Set the end date field to indicate validation required for end date.
                        -- If p_inserting, validation is still to occur. If end_is null then set it
                        -- such that validation will happen in the after statement trigger.
                        IF p_inserting AND
                           (NVL(new_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))
                                         = IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
                                v_tmp_end_dt := IGS_GE_DATE.IGSDATE('1900/01/01');
                        ELSE
                                v_tmp_end_dt := new_references.end_dt;
                        END IF;
                        RowValMutation(
                                p_inserting ,
                                p_updating ,
                                p_deleting ,
                                NULL ,
                                v_tmp_end_dt,
                                'N',
                                'N'
                                );
                END IF;
                -- Validate if the IGS_PS_UNIT set parent relationship.
                IF (p_inserting AND new_references.student_confirmed_ind = 'Y') OR
                  (p_updating AND
                   (new_references.student_confirmed_ind  <> old_references.student_confirmed_ind)) THEN
                        -- Validate that the IGS_PS_UNIT set is not confirmed when the student IGS_PS_COURSE
                        -- attempt is unconfirmed.
                        -- Also check that not unset one end date or complete date set. Cannot be
                        -- confirmed and linked to a parent that is unconfirmed. Cannot be
                        -- confirmed if encumbrances exist.
                        -- Cannot call modules because trigger will be mutating.
                        -- Save the rowid of the current row setting the student confirmed field to
                        -- indicate to perform student_confirmed_ind validation
                        RowValMutation(
                                p_inserting ,
                                p_updating ,
                                p_deleting ,
                                NULL ,
                                NULL,
                                new_references.student_confirmed_ind,
                                'N'
                                );
                END IF;
                -- Validate if the primary set indicator.
                IF p_inserting OR
                  (p_updating AND
                   (new_references.primary_set_ind  <> old_references.primary_set_ind)) THEN
                        -- Validate the primary set indicator is only set for
                        -- non-administrative sets and that there does not already
                        -- exist a IGS_PS_UNIT set that has a higher rank.
                        -- Cannot call modules because trigger will be mutating.
                        -- Save the rowid of the current row setting the primary_set field to
                        -- indicate to perform primary_set_ind validation
                        RowValMutation(
                                p_inserting ,
                                p_updating ,
                                p_deleting ,
                                NULL ,
                                NULL,
                                'N',
                                new_references.primary_set_ind
                                );
                END IF;
        END IF;
        IF p_inserting OR p_updating THEN
           v_unit_set := NULL;
           OPEN c_unit_set(new_references.unit_set_cd);
           FETCH c_unit_set INTO v_unit_set;
           CLOSE c_unit_set;
           IF v_unit_set IS NOT NULL THEN
                v_sequence_number := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(
                                        new_references.person_id,
                                        'FEE_RECALC',
                                        SYSDATE,
                                        'Y');
           END IF;
        ELSE
           v_unit_set := NULL;
           OPEN c_unit_set(old_references.unit_set_cd);
           FETCH c_unit_set INTO v_unit_set;
           CLOSE c_unit_set;
           IF v_unit_set IS NOT NULL THEN
                v_sequence_number := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(
                                        old_references.person_id,
                                        'FEE_RECALC',
                                        SYSDATE,
                                        'Y');
           END IF;
        END IF;
  END AfterRowInsertUpdate2;
  -- Trigger description :-
  -- "OSS_TST".trg_susa_ar_ud_hist
  -- AFTER DELETE OR UPDATE
  -- ON IGS_AS_SU_SETATMPT
  -- FOR EACH ROW
  PROCEDURE AfterRowUpdateDelete3(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
        v_message_name  VARCHAR2(30);
  BEGIN
        IF p_updating THEN
                -- Create IGS_AS_SU_SETATMPT history record.
                IGS_EN_GEN_010.ENRP_INS_SUSA_HIST (
                        new_references.person_id,
                        new_references.course_cd,
                        new_references.unit_set_cd,
                        new_references.sequence_number,
                        new_references.us_version_number,
                        old_references.us_version_number ,
                        new_references.selection_dt,
                        old_references.selection_dt,
                        new_references.student_confirmed_ind,
                        old_references.student_confirmed_ind,
                        new_references.end_dt,
                        old_references.end_dt,
                        new_references.parent_unit_set_cd,
                        old_references.parent_unit_set_cd,
                        new_references.parent_sequence_number,
                        old_references.parent_sequence_number,
                        new_references.primary_set_ind,
                        old_references.primary_set_ind,
                        new_references.voluntary_end_ind,
                        old_references.voluntary_end_ind,
                        new_references.authorised_person_id,
                        old_references.authorised_person_id,
                        new_references.authorised_on,
                        old_references.authorised_on,
                        new_references.override_title,
                        old_references.override_title,
                        new_references.rqrmnts_complete_ind,
                        old_references.rqrmnts_complete_ind,
                        new_references.rqrmnts_complete_dt,
                        old_references.rqrmnts_complete_dt,
                        new_references.s_completed_source_type,
                        old_references.s_completed_source_type,
                        new_references.catalog_cal_type ,
                        old_references.catalog_cal_type ,
                        new_references.catalog_seq_num ,
                        old_references.catalog_seq_num ,
                        new_references.last_updated_by,
                        old_references.last_updated_by,
                        new_references.last_update_date,
                        old_references.last_update_date);
        END IF;
        IF p_deleting THEN
                -- Delete IGS_AS_SU_SETATMPT history records.
                IF IGS_EN_GEN_001.ENRP_DEL_SUSA_HIST (
                                old_references.person_id,
                                old_references.course_cd,
                                old_references.unit_set_cd,
                                old_references.sequence_number,
                                v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
                END IF;
        END IF;
  END AfterRowUpdateDelete3;
  -- Trigger description :-
  -- "OSS_TST".trg_susa_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_SU_SETATMPT

  PROCEDURE Check_Parent_Existance AS

    -- check if the parent unit set is a valid one
    CURSOR c_parent_rel_exists IS

    SELECT	'x'
   		FROM	IGS_PS_OF_UNT_SET_RL cousr,
 			IGS_AS_SU_SETATMPT susa,
 			IGS_EN_STDNT_PS_ATT spa
   		WHERE	spa.person_id = susa.person_id AND
 			spa.course_cd = susa.course_cd AND
 			susa.person_id = new_references.person_id AND
 			susa.course_cd = new_references.course_cd AND
 			susa.unit_set_cd = new_references.parent_unit_set_cd AND
 			susa.sequence_number = new_references.parent_sequence_number AND
 			cousr.course_cd 		= spa.course_cd			AND
   			cousr.crv_version_number	= spa.version_number		AND
   			cousr.cal_type			= spa.cal_type			AND
   			cousr.sub_unit_set_cd		= new_references.unit_set_cd			AND
   			cousr.sub_us_version_number 	= new_references.us_version_number		AND
   			cousr.sup_unit_set_cd		= susa.unit_set_cd		AND
   			cousr.sup_us_version_number	= susa.us_version_number;
   l_dummy VARCHAR2(1);

  BEGIN

     IF (new_references.parent_unit_set_cd IS NOT NULL AND
         new_references.parent_sequence_number IS NOT NULL) THEN
       OPEN c_parent_rel_exists;
       FETCH c_parent_rel_exists INTO l_dummy;
       IF c_parent_rel_exists%NOTFOUND THEN
         CLOSE c_parent_rel_exists;
     	Fnd_Message.Set_Name ('IGS', 'IGS_EN_UNIT_SET_RELATIONSHIP');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
       CLOSE c_parent_rel_exists;
     END IF;


    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        (new_references.person_id IS NULL) OR
        (new_references.course_cd IS NULL)) THEN
      NULL;
    ELSE
       IF  NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd
        ) THEN
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
       END IF;
    END IF;
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.parent_unit_set_cd = new_references.parent_unit_set_cd) AND
         (old_references.parent_sequence_number = new_references.parent_sequence_number)) OR
        (new_references.person_id IS NULL) OR
        (new_references.course_cd IS NULL) OR
        (new_references.parent_unit_set_cd IS NULL) OR
        (new_references.parent_sequence_number IS NULL)) THEN
      NULL;
    ELSE
      IF  NOT IGS_AS_SU_SETATMPT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd,
        new_references.parent_unit_set_cd,
        new_references.parent_sequence_number
        )THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.us_version_number = new_references.us_version_number)) OR
        (new_references.unit_set_cd IS NULL) OR
        (new_references.us_version_number IS NULL)) THEN
      NULL;
    ELSE
      IF  NOT IGS_EN_UNIT_SET_PKG.Get_PK_For_Validation (
        new_references.unit_set_cd,
        new_references.us_version_number
        )THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Parent_Existance;

PROCEDURE Check_Constraints (
 Column_Name    IN      VARCHAR2        ,
 Column_Value   IN      VARCHAR2
 )
 AS
 BEGIN

      IF  column_name IS NULL THEN
         NULL;
      ELSIF UPPER(Column_name) = 'AUTHORISED_PERSON_ID' THEN
         new_references.authorised_person_id:= column_value;
      ELSIF UPPER(Column_name) = 'COURSE_CD' THEN
         new_references.course_cd:= column_value;
      ELSIF UPPER(Column_name) = 'OVERRIDE_TITLE' THEN
         new_references.override_title:= column_value;
      ELSIF UPPER(Column_name) = 'PARENT_SEQUENCE_NUMBER' THEN
         new_references.parent_sequence_number:= igs_ge_number.to_num(column_value);
      ELSIF UPPER(Column_name) = 'PARENT_UNIT_SET_CD' THEN
         new_references.parent_unit_set_cd:= column_value;
      ELSIF UPPER(Column_name) = 'PRIMARY_SET_IND' THEN
         new_references.primary_set_ind:= column_value;
      ELSIF UPPER(Column_name) = 'RQRMNTS_COMPLETE_IND' THEN
         new_references.rqrmnts_complete_ind:= column_value;
      ELSIF UPPER(Column_name) = 'S_COMPLETED_SOURCE_TYPE' THEN
         new_references.s_completed_source_type:= column_value;
      ELSIF UPPER(Column_name) = 'SEQUENCE_NUMBER' THEN
         new_references.sequence_number:= column_value;
      ELSIF UPPER(Column_name) = 'STUDENT_CONFIRMED_IND' THEN
         new_references.student_confirmed_ind:= column_value;
      ELSIF UPPER(Column_name) = 'UNIT_SET_CD' THEN
         new_references.unit_set_cd:= column_value;
      ELSIF UPPER(Column_name) = 'VOLUNTARY_END_IND' THEN
         new_references.voluntary_end_ind:= column_value;
      END IF;

     IF UPPER(column_name) = 'AUTHORISED_PERSON_ID' OR
        column_name IS NULL THEN
        IF (new_references.authorised_person_id  < 0  AND   new_references.authorised_person_id  > 9999999999)  THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF UPPER(column_name) = 'COURSE_CD' OR
        column_name IS NULL THEN
        IF new_references.course_cd <> UPPER(new_references.course_cd) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF UPPER(column_name) = 'PARENT_SEQUENCE_NUMBER' OR
        column_name IS NULL THEN
        IF  new_references.parent_sequence_number < 1  AND   new_references.parent_sequence_number > 999999  THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF UPPER(column_name) = 'PARENT_UNIT_SET_CD' OR
        column_name IS NULL THEN
        IF new_references.parent_unit_set_cd <> UPPER(new_references.parent_unit_set_cd) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF UPPER(column_name) = 'PRIMARY_SET_IND' OR
        column_name IS NULL THEN
        IF new_references.primary_set_ind <> UPPER(new_references.primary_set_ind) OR new_references.primary_set_ind  NOT IN ( 'Y' , 'N' )  THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF UPPER(column_name) = 'RQRMNTS_COMPLETE_IND' OR
        column_name IS NULL THEN
        IF new_references.rqrmnts_complete_ind <> UPPER(new_references.rqrmnts_complete_ind) OR new_references.rqrmnts_complete_ind NOT IN ( 'Y' , 'N' ) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF UPPER(column_name) = 'S_COMPLETED_SOURCE_TYPE' OR
        column_name IS NULL THEN
        IF new_references.s_completed_source_type <> UPPER(new_references.s_completed_source_type) OR (new_references.s_completed_source_type NOT IN ( 'SYSTEM' , 'MANUAL' )) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF UPPER(column_name) = 'SEQUENCE_NUMBER' OR
        column_name IS NULL THEN
        IF  new_references.sequence_number < 1  AND   new_references.sequence_number > 999999  THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF UPPER(column_name) = 'STUDENT_CONFIRMED_IND' OR
        column_name IS NULL THEN
        IF new_references.student_confirmed_ind <> UPPER(new_references.student_confirmed_ind) OR new_references.student_confirmed_ind NOT IN ( 'Y' , 'N' ) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF UPPER(column_name) = 'UNIT_SET_CD' OR
        column_name IS NULL THEN
        IF new_references.unit_set_cd <> UPPER(new_references.unit_set_cd) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF UPPER(column_name) = 'VOLUNTARY_END_IND' OR
        column_name IS NULL THEN
        IF new_references.voluntary_end_ind <> UPPER(new_references.voluntary_end_ind) OR new_references.voluntary_end_ind NOT IN ( 'Y' , 'N' ) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
 END Check_Constraints;


  PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_AS_SU_SETATMPT_PKG.GET_FK_IGS_AS_SU_SETATMPT (
      OLD_references.person_id,
      OLD_references.course_cd,
      OLD_references.unit_set_cd,
      OLD_references.sequence_number
      );
  END Check_Child_Existance;
FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_unit_set_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_AS_SU_SETATMPT
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      unit_set_cd = x_unit_set_cd
      AND      sequence_number = x_sequence_number
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
 IF (cur_rowid%FOUND) THEN
       CLOSE cur_rowid;
       RETURN (TRUE);
 ELSE
       CLOSE cur_rowid;
       RETURN (FALSE);
 END IF;
  END Get_PK_For_Validation;
  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_AS_SU_SETATMPT
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUSA_SCA_FK');
      IGS_GE_MSG_STACK.ADD;
      CLOSE cur_rowid;
      App_Exception.Raise_Exception;

      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_EN_STDNT_PS_ATT;
  PROCEDURE GET_FK_IGS_AS_SU_SETATMPT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_unit_set_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_AS_SU_SETATMPT
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      parent_unit_set_cd = x_unit_set_cd
      AND      parent_sequence_number = x_sequence_number ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUSA_SUSA_PRNT_FK');
      IGS_GE_MSG_STACK.ADD;
      CLOSE cur_rowid;
      App_Exception.Raise_Exception;

      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_AS_SU_SETATMPT;
  PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_AS_SU_SETATMPT
      WHERE    unit_set_cd = x_unit_set_cd
      AND      us_version_number = x_version_number ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUSA_US_FK');
      IGS_GE_MSG_STACK.ADD;
      CLOSE cur_rowid;
      App_Exception.Raise_Exception;

      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_EN_UNIT_SET;



  PROCEDURE GET_FK_IGS_CA_INST (
    X_CATALOG_CAL_TYPE IN VARCHAR2,
    X_CATALOG_SEQ_NUM IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   IGS_AS_SU_SETATMPT
      WHERE  CATALOG_CAL_TYPE = X_CATALOG_CAL_TYPE
            AND  CATALOG_SEQ_NUM = X_CATALOG_SEQ_NUM
          ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUSA_CI_FK');
      Igs_Ge_Msg_Stack.ADD;
      CLOSE cur_rowid;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_PS_OFR_UNIT_SET (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_unit_set_cd IN VARCHAR2,
    x_us_version_number IN NUMBER
    ) AS
  /*************************************************************
  Created By :sarakshi
  Date Created By :29-May-2006
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
    SELECT   a.rowid
    FROM   igs_as_su_setatmpt a, igs_en_stdnt_ps_att b
    WHERE  a.course_cd=b.course_cd
    AND    a.person_id=b.person_id
    AND    b.course_cd=x_course_cd
    AND    b.version_number=x_version_number
    AND    b.cal_type = x_cal_type
    AND    a.unit_set_cd = x_unit_set_cd
    AND    a.us_version_number = x_us_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUSA_US_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_OFR_UNIT_SET;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_person_id IN NUMBER ,
    x_course_cd IN VARCHAR2 ,
    x_unit_set_cd IN VARCHAR2 ,
    x_us_version_number IN NUMBER ,
    x_sequence_number IN NUMBER ,
    x_selection_dt IN DATE ,
    x_student_confirmed_ind IN VARCHAR2 ,
    x_end_dt IN DATE ,
    x_parent_unit_set_cd IN VARCHAR2 ,
    x_parent_sequence_number IN NUMBER ,
    x_primary_set_ind IN VARCHAR2 ,
    x_voluntary_end_ind IN VARCHAR2 ,
    x_authorised_person_id IN NUMBER ,
    x_authorised_on IN DATE ,
    x_override_title IN VARCHAR2 ,
    x_rqrmnts_complete_ind IN VARCHAR2 ,
    x_rqrmnts_complete_dt IN DATE ,
    x_s_completed_source_type IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_catalog_cal_type IN VARCHAR2 ,
    x_catalog_seq_num IN NUMBER ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2 ,
    x_attribute11 IN VARCHAR2 ,
    x_attribute12 IN VARCHAR2 ,
    x_attribute13 IN VARCHAR2 ,
    x_attribute14 IN VARCHAR2 ,
    x_attribute15 IN VARCHAR2 ,
    x_attribute16 IN VARCHAR2 ,
    x_attribute17 IN VARCHAR2 ,
    x_attribute18 IN VARCHAR2 ,
    x_attribute19 IN VARCHAR2 ,
    x_attribute20 IN VARCHAR2
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_unit_set_cd,
      x_us_version_number,
      x_sequence_number,
      x_selection_dt,
      x_student_confirmed_ind,
      x_end_dt,
      x_parent_unit_set_cd,
      x_parent_sequence_number,
      x_primary_set_ind,
      x_voluntary_end_ind,
      x_authorised_person_id,
      x_authorised_on,
      x_override_title,
      x_rqrmnts_complete_ind,
      x_rqrmnts_complete_dt,
      x_s_completed_source_type,
      x_catalog_cal_type,
      x_catalog_seq_num,
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
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE, p_updating=> FALSE,  p_deleting=> FALSE );
      IF  Get_PK_For_Validation (
             new_references.person_id,
             new_references.course_cd,
             new_references.unit_set_cd,
             new_references.sequence_number
           ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE, p_updating=> TRUE,  p_deleting=> FALSE );
       Check_Constraints; -- if procedure present
       Check_Parent_Existance; -- if procedure present
 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE, p_updating=> FALSE,  p_deleting=> TRUE );
       Check_Child_Existance; -- if procedure present
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
             new_references.person_id,
             new_references.course_cd,
             new_references.unit_set_cd,
             new_references.sequence_number
           ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
                Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
                Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
              Check_Child_Existance;

 END IF;

  END Before_DML;


  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  ------------------------------------------------------------------------------
  -- Change History:
  -- Who         When            What
  -- svanukur    27-NOV-2003     added call to AfterRowInsertUpdate2 if p_action=delete
  ------------------------------------------------------------------------------
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE, p_updating => FALSE, p_deleting => FALSE);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_inserting => FALSE, p_updating => TRUE, p_deleting => FALSE);
      AfterRowUpdateDelete3 ( p_inserting => FALSE, p_updating => TRUE, p_deleting => FALSE);
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowUpdateDelete3 ( p_inserting => FALSE, p_updating => FALSE, p_deleting => TRUE);
      AfterRowInsertUpdate2 ( p_inserting => FALSE, p_updating => FALSE, p_deleting => TRUE);
    END IF;
  END After_DML;
--
PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_UNIT_SET_CD IN VARCHAR2,
  X_SEQUENCE_NUMBER IN NUMBER,
  X_US_VERSION_NUMBER IN NUMBER,
  X_SELECTION_DT IN DATE,
  X_STUDENT_CONFIRMED_IND IN VARCHAR2,
  X_END_DT IN DATE,
  X_PARENT_UNIT_SET_CD IN VARCHAR2,
  X_PARENT_SEQUENCE_NUMBER IN NUMBER,
  X_PRIMARY_SET_IND IN VARCHAR2,
  X_VOLUNTARY_END_IND IN VARCHAR2,
  X_AUTHORISED_PERSON_ID IN NUMBER,
  X_AUTHORISED_ON IN DATE,
  X_OVERRIDE_TITLE IN VARCHAR2,
  X_RQRMNTS_COMPLETE_IND IN VARCHAR2,
  X_RQRMNTS_COMPLETE_DT IN DATE,
  X_S_COMPLETED_SOURCE_TYPE IN VARCHAR2,
  X_CATALOG_CAL_TYPE IN VARCHAR2 ,
  X_CATALOG_SEQ_NUM IN NUMBER ,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  X_ATTRIBUTE20 IN VARCHAR2 ,
  X_MODE IN VARCHAR2
  ) AS
    CURSOR C IS SELECT ROWID FROM IGS_AS_SU_SETATMPT
      WHERE PERSON_ID = X_PERSON_ID
      AND COURSE_CD = X_COURSE_CD
      AND UNIT_SET_CD = X_UNIT_SET_CD
      AND SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
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
--
   Before_DML(
    p_action=>'INSERT',
    x_rowid=>X_ROWID,
    x_authorised_on=>X_AUTHORISED_ON,
    x_authorised_person_id=>X_AUTHORISED_PERSON_ID,
    x_course_cd=>X_COURSE_CD,
    x_end_dt=>X_END_DT,
    x_override_title=>X_OVERRIDE_TITLE,
    x_parent_sequence_number=>X_PARENT_SEQUENCE_NUMBER,
    x_parent_unit_set_cd=>X_PARENT_UNIT_SET_CD,
    x_person_id=>X_PERSON_ID,
    x_primary_set_ind=> NVL(X_PRIMARY_SET_IND,'N'),
    x_rqrmnts_complete_dt=>X_RQRMNTS_COMPLETE_DT,
    x_rqrmnts_complete_ind=> NVL(X_RQRMNTS_COMPLETE_IND,'N'),
    x_s_completed_source_type=>X_S_COMPLETED_SOURCE_TYPE,
    x_selection_dt=>X_SELECTION_DT,
    x_sequence_number=>X_SEQUENCE_NUMBER,
    x_student_confirmed_ind=>X_STUDENT_CONFIRMED_IND,
    x_unit_set_cd=>X_UNIT_SET_CD,
    x_us_version_number=>X_US_VERSION_NUMBER,
    x_voluntary_end_ind=> NVL(X_VOLUNTARY_END_IND,'N'),
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN,
    x_catalog_cal_type => X_CATALOG_CAL_TYPE,
    x_catalog_seq_num => X_CATALOG_SEQ_NUM,
    x_attribute_category=> X_ATTRIBUTE_CATEGORY,
    x_attribute1=>  X_ATTRIBUTE1,
    x_attribute2=>  X_ATTRIBUTE2,
    x_attribute3=>  X_ATTRIBUTE3,
    x_attribute4=>  X_ATTRIBUTE4,
    x_attribute5=>  X_ATTRIBUTE5,
    x_attribute6=>  X_ATTRIBUTE6,
    x_attribute7=>  X_ATTRIBUTE7,
    x_attribute8=>  X_ATTRIBUTE8,
    x_attribute9=>  X_ATTRIBUTE9,
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
--
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  INSERT INTO IGS_AS_SU_SETATMPT (
    PERSON_ID,
    COURSE_CD,
    UNIT_SET_CD,
    US_VERSION_NUMBER,
    SEQUENCE_NUMBER,
    SELECTION_DT,
    STUDENT_CONFIRMED_IND,
    END_DT,
    PARENT_UNIT_SET_CD,
    PARENT_SEQUENCE_NUMBER,
    PRIMARY_SET_IND,
    VOLUNTARY_END_IND,
    AUTHORISED_PERSON_ID,
    AUTHORISED_ON,
    OVERRIDE_TITLE,
    RQRMNTS_COMPLETE_IND,
    RQRMNTS_COMPLETE_DT,
    S_COMPLETED_SOURCE_TYPE,
    CATALOG_CAL_TYPE,
    CATALOG_SEQ_NUM,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    ATTRIBUTE_CATEGORY,
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
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.US_VERSION_NUMBER,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.SELECTION_DT,
    NEW_REFERENCES.STUDENT_CONFIRMED_IND,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.PARENT_UNIT_SET_CD,
    NEW_REFERENCES.PARENT_SEQUENCE_NUMBER,
    NEW_REFERENCES.PRIMARY_SET_IND,
    NEW_REFERENCES.VOLUNTARY_END_IND,
    NEW_REFERENCES.AUTHORISED_PERSON_ID,
    NEW_REFERENCES.AUTHORISED_ON,
    NEW_REFERENCES.OVERRIDE_TITLE,
    NEW_REFERENCES.RQRMNTS_COMPLETE_IND,
    NEW_REFERENCES.RQRMNTS_COMPLETE_DT,
    NEW_REFERENCES.S_COMPLETED_SOURCE_TYPE,
    NEW_REFERENCES.CATALOG_CAL_TYPE,
    NEW_REFERENCES.CATALOG_SEQ_NUM,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    NEW_REFERENCES.ATTRIBUTE_CATEGORY,
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
--
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
--
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
  X_ROWID IN  VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_UNIT_SET_CD IN VARCHAR2,
  X_SEQUENCE_NUMBER IN NUMBER,
  X_US_VERSION_NUMBER IN NUMBER,
  X_SELECTION_DT IN DATE,
  X_STUDENT_CONFIRMED_IND IN VARCHAR2,
  X_END_DT IN DATE,
  X_PARENT_UNIT_SET_CD IN VARCHAR2,
  X_PARENT_SEQUENCE_NUMBER IN NUMBER,
  X_PRIMARY_SET_IND IN VARCHAR2,
  X_VOLUNTARY_END_IND IN VARCHAR2,
  X_AUTHORISED_PERSON_ID IN NUMBER,
  X_AUTHORISED_ON IN DATE,
  X_OVERRIDE_TITLE IN VARCHAR2,
  X_RQRMNTS_COMPLETE_IND IN VARCHAR2,
  X_RQRMNTS_COMPLETE_DT IN DATE,
  X_S_COMPLETED_SOURCE_TYPE IN VARCHAR2,
  X_CATALOG_CAL_TYPE IN VARCHAR2 ,
  X_CATALOG_SEQ_NUM IN NUMBER ,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  X_ATTRIBUTE20 IN VARCHAR2
) AS
  CURSOR c1 IS SELECT
      US_VERSION_NUMBER,
      SELECTION_DT,
      STUDENT_CONFIRMED_IND,
      END_DT,
      PARENT_UNIT_SET_CD,
      PARENT_SEQUENCE_NUMBER,
      PRIMARY_SET_IND,
      VOLUNTARY_END_IND,
      AUTHORISED_PERSON_ID,
      AUTHORISED_ON,
      OVERRIDE_TITLE,
      RQRMNTS_COMPLETE_IND,
      RQRMNTS_COMPLETE_DT,
      S_COMPLETED_SOURCE_TYPE,
      CATALOG_CAL_TYPE,
      CATALOG_SEQ_NUM,
      ATTRIBUTE_CATEGORY,
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
    FROM IGS_AS_SU_SETATMPT
    WHERE ROWID = X_ROWID  FOR UPDATE  NOWAIT;
  tlinfo c1%ROWTYPE;
BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    CLOSE c1;
    app_exception.raise_exception;

    RETURN;
  END IF;
  CLOSE c1;
  IF ( (tlinfo.US_VERSION_NUMBER = X_US_VERSION_NUMBER)
      AND ((trunc(tlinfo.SELECTION_DT) = trunc(X_SELECTION_DT))
           OR ((tlinfo.SELECTION_DT IS NULL)
               AND (X_SELECTION_DT IS NULL)))
      AND (tlinfo.STUDENT_CONFIRMED_IND = X_STUDENT_CONFIRMED_IND)
      AND ((trunc(tlinfo.END_DT) = trunc(X_END_DT))
           OR ((tlinfo.END_DT IS NULL)
               AND (X_END_DT IS NULL)))
      AND ((tlinfo.PARENT_UNIT_SET_CD = X_PARENT_UNIT_SET_CD)
           OR ((tlinfo.PARENT_UNIT_SET_CD IS NULL)
               AND (X_PARENT_UNIT_SET_CD IS NULL)))
      AND ((tlinfo.PARENT_SEQUENCE_NUMBER = X_PARENT_SEQUENCE_NUMBER)
           OR ((tlinfo.PARENT_SEQUENCE_NUMBER IS NULL)
               AND (X_PARENT_SEQUENCE_NUMBER IS NULL)))
      AND (tlinfo.PRIMARY_SET_IND = X_PRIMARY_SET_IND)
      AND (tlinfo.VOLUNTARY_END_IND = X_VOLUNTARY_END_IND)
      AND ((tlinfo.AUTHORISED_PERSON_ID = X_AUTHORISED_PERSON_ID)
           OR ((tlinfo.AUTHORISED_PERSON_ID IS NULL)
               AND (X_AUTHORISED_PERSON_ID IS NULL)))
      AND ((tlinfo.AUTHORISED_ON = X_AUTHORISED_ON)
           OR ((tlinfo.AUTHORISED_ON IS NULL)
               AND (X_AUTHORISED_ON IS NULL)))
      AND ((tlinfo.OVERRIDE_TITLE = X_OVERRIDE_TITLE)
           OR ((tlinfo.OVERRIDE_TITLE IS NULL)
               AND (X_OVERRIDE_TITLE IS NULL)))
      AND (tlinfo.RQRMNTS_COMPLETE_IND = X_RQRMNTS_COMPLETE_IND)
      AND ((trunc(tlinfo.RQRMNTS_COMPLETE_DT) = trunc(X_RQRMNTS_COMPLETE_DT))
           OR ((tlinfo.RQRMNTS_COMPLETE_DT IS NULL)
               AND (X_RQRMNTS_COMPLETE_DT IS NULL)))
      AND ((tlinfo.S_COMPLETED_SOURCE_TYPE = X_S_COMPLETED_SOURCE_TYPE)
           OR ((tlinfo.S_COMPLETED_SOURCE_TYPE IS NULL)
               AND (X_S_COMPLETED_SOURCE_TYPE IS NULL)))
      AND ((tlinfo.CATALOG_CAL_TYPE = X_CATALOG_CAL_TYPE)
           OR ((tlinfo.CATALOG_CAL_TYPE IS NULL)
               AND (X_CATALOG_CAL_TYPE IS NULL)))
      AND ((tlinfo.CATALOG_SEQ_NUM = X_CATALOG_SEQ_NUM)
           OR ((tlinfo.CATALOG_SEQ_NUM IS NULL)
               AND (X_CATALOG_SEQ_NUM IS NULL)))
           AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY IS NULL)
           AND (X_ATTRIBUTE_CATEGORY IS NULL)))
      AND ((tlinfo.ATTRIBUTE1= X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 IS NULL)
           AND (X_ATTRIBUTE1 IS NULL)))
     AND ((tlinfo.ATTRIBUTE2= X_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 IS NULL)
           AND (X_ATTRIBUTE2 IS NULL)))
     AND ((tlinfo.ATTRIBUTE3= X_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 IS NULL)
           AND (X_ATTRIBUTE3 IS NULL)))
     AND ((tlinfo.ATTRIBUTE4= X_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 IS NULL)
           AND (X_ATTRIBUTE4 IS NULL)))
     AND ((tlinfo.ATTRIBUTE5= X_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 IS NULL)
           AND (X_ATTRIBUTE5 IS NULL)))
     AND ((tlinfo.ATTRIBUTE6= X_ATTRIBUTE6)
           OR ((tlinfo.ATTRIBUTE6 IS NULL)
           AND (X_ATTRIBUTE6 IS NULL)))
     AND ((tlinfo.ATTRIBUTE7= X_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 IS NULL)
           AND (X_ATTRIBUTE7 IS NULL)))
     AND ((tlinfo.ATTRIBUTE8= X_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 IS NULL)
           AND (X_ATTRIBUTE8 IS NULL)))
     AND ((tlinfo.ATTRIBUTE9= X_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 IS NULL)
           AND (X_ATTRIBUTE9 IS NULL)))
     AND ((tlinfo.ATTRIBUTE10= X_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 IS NULL)
           AND (X_ATTRIBUTE10 IS NULL)))
     AND ((tlinfo.ATTRIBUTE11= X_ATTRIBUTE11)
           OR ((tlinfo.ATTRIBUTE11 IS NULL)
           AND (X_ATTRIBUTE11 IS NULL)))
     AND ((tlinfo.ATTRIBUTE12= X_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 IS NULL)
           AND (X_ATTRIBUTE12 IS NULL)))
     AND ((tlinfo.ATTRIBUTE13= X_ATTRIBUTE13)
           OR ((tlinfo.ATTRIBUTE13 IS NULL)
           AND (X_ATTRIBUTE13 IS NULL)))
     AND ((tlinfo.ATTRIBUTE14= X_ATTRIBUTE14)
           OR ((tlinfo.ATTRIBUTE14 IS NULL)
           AND (X_ATTRIBUTE14 IS NULL)))
     AND ((tlinfo.ATTRIBUTE15= X_ATTRIBUTE15)
           OR ((tlinfo.ATTRIBUTE15 IS NULL)
           AND (X_ATTRIBUTE15 IS NULL)))
     AND ((tlinfo.ATTRIBUTE16= X_ATTRIBUTE16)
           OR ((tlinfo.ATTRIBUTE16 IS NULL)
           AND (X_ATTRIBUTE16 IS NULL)))
     AND ((tlinfo.ATTRIBUTE17= X_ATTRIBUTE17)
           OR ((tlinfo.ATTRIBUTE17 IS NULL)
           AND (X_ATTRIBUTE17 IS NULL)))
     AND ((tlinfo.ATTRIBUTE18= X_ATTRIBUTE18)
           OR ((tlinfo.ATTRIBUTE18 IS NULL)
           AND (X_ATTRIBUTE18 IS NULL)))
     AND ((tlinfo.ATTRIBUTE19= X_ATTRIBUTE19)
           OR ((tlinfo.ATTRIBUTE19 IS NULL)
           AND (X_ATTRIBUTE19 IS NULL)))
     AND ((tlinfo.ATTRIBUTE20= X_ATTRIBUTE20)
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
  X_ROWID IN  VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_UNIT_SET_CD IN VARCHAR2,
  X_SEQUENCE_NUMBER IN NUMBER,
  X_US_VERSION_NUMBER IN NUMBER,
  X_SELECTION_DT IN DATE,
  X_STUDENT_CONFIRMED_IND IN VARCHAR2,
  X_END_DT IN DATE,
  X_PARENT_UNIT_SET_CD IN VARCHAR2,
  X_PARENT_SEQUENCE_NUMBER IN NUMBER,
  X_PRIMARY_SET_IND IN VARCHAR2,
  X_VOLUNTARY_END_IND IN VARCHAR2,
  X_AUTHORISED_PERSON_ID IN NUMBER,
  X_AUTHORISED_ON IN DATE,
  X_OVERRIDE_TITLE IN VARCHAR2,
  X_RQRMNTS_COMPLETE_IND IN VARCHAR2,
  X_RQRMNTS_COMPLETE_DT IN DATE,
  X_S_COMPLETED_SOURCE_TYPE IN VARCHAR2,
  X_CATALOG_CAL_TYPE IN VARCHAR2 ,
  X_CATALOG_SEQ_NUM IN NUMBER ,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  X_ATTRIBUTE20 IN VARCHAR2 ,
  X_MODE IN VARCHAR2
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
Before_DML(
    p_action=>'UPDATE',
    x_rowid=>X_ROWID,
    x_authorised_on=>X_AUTHORISED_ON,
    x_authorised_person_id=>X_AUTHORISED_PERSON_ID,
    x_course_cd=>X_COURSE_CD,
    x_end_dt=>X_END_DT,
    x_override_title=>X_OVERRIDE_TITLE,
    x_parent_sequence_number=>X_PARENT_SEQUENCE_NUMBER,
    x_parent_unit_set_cd=>X_PARENT_UNIT_SET_CD,
    x_person_id=>X_PERSON_ID,
    x_primary_set_ind=>X_PRIMARY_SET_IND,
    x_rqrmnts_complete_dt=>X_RQRMNTS_COMPLETE_DT,
    x_rqrmnts_complete_ind=>X_RQRMNTS_COMPLETE_IND,
    x_s_completed_source_type=>X_S_COMPLETED_SOURCE_TYPE,
    x_selection_dt=>X_SELECTION_DT,
    x_sequence_number=>X_SEQUENCE_NUMBER,
    x_student_confirmed_ind=>X_STUDENT_CONFIRMED_IND,
    x_unit_set_cd=>X_UNIT_SET_CD,
    x_us_version_number=>X_US_VERSION_NUMBER,
    x_voluntary_end_ind=>X_VOLUNTARY_END_IND,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN,
    x_catalog_cal_type => X_CATALOG_CAL_TYPE,
    x_catalog_seq_num => X_CATALOG_SEQ_NUM,
    x_attribute_category=> X_ATTRIBUTE_CATEGORY,
    x_attribute1=>  X_ATTRIBUTE1,
    x_attribute2=>  X_ATTRIBUTE2,
    x_attribute3=>  X_ATTRIBUTE3,
    x_attribute4=>  X_ATTRIBUTE4,
    x_attribute5=>  X_ATTRIBUTE5,
    x_attribute6=>  X_ATTRIBUTE6,
    x_attribute7=>  X_ATTRIBUTE7,
    x_attribute8=>  X_ATTRIBUTE8,
    x_attribute9=>  X_ATTRIBUTE9,
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
 IF (X_MODE IN ('R', 'S')) THEN
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  IF (X_REQUEST_ID = -1) THEN
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
 ELSE
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 END IF;
--
--
END IF;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  UPDATE IGS_AS_SU_SETATMPT SET
    US_VERSION_NUMBER = NEW_REFERENCES.US_VERSION_NUMBER,
    SELECTION_DT = NEW_REFERENCES.SELECTION_DT,
    STUDENT_CONFIRMED_IND = NEW_REFERENCES.STUDENT_CONFIRMED_IND,
    END_DT = NEW_REFERENCES.END_DT,
    PARENT_UNIT_SET_CD = NEW_REFERENCES.PARENT_UNIT_SET_CD,
    PARENT_SEQUENCE_NUMBER = NEW_REFERENCES.PARENT_SEQUENCE_NUMBER,
    PRIMARY_SET_IND = NEW_REFERENCES.PRIMARY_SET_IND,
    VOLUNTARY_END_IND = NEW_REFERENCES.VOLUNTARY_END_IND,
    AUTHORISED_PERSON_ID = NEW_REFERENCES.AUTHORISED_PERSON_ID,
    AUTHORISED_ON = NEW_REFERENCES.AUTHORISED_ON,
    OVERRIDE_TITLE = NEW_REFERENCES.OVERRIDE_TITLE,
    RQRMNTS_COMPLETE_IND = NEW_REFERENCES.RQRMNTS_COMPLETE_IND,
    RQRMNTS_COMPLETE_DT = NEW_REFERENCES.RQRMNTS_COMPLETE_DT,
    S_COMPLETED_SOURCE_TYPE = NEW_REFERENCES.S_COMPLETED_SOURCE_TYPE,
    CATALOG_CAL_TYPE = NEW_REFERENCES.CATALOG_CAL_TYPE,
    CATALOG_SEQ_NUM = NEW_REFERENCES.CATALOG_SEQ_NUM,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
   ATTRIBUTE_CATEGORY=X_ATTRIBUTE_CATEGORY,
   ATTRIBUTE1=NEW_REFERENCES.ATTRIBUTE1,
   ATTRIBUTE2=NEW_REFERENCES.ATTRIBUTE2,
   ATTRIBUTE3=NEW_REFERENCES.ATTRIBUTE3,
   ATTRIBUTE4=NEW_REFERENCES.ATTRIBUTE4,
   ATTRIBUTE5=NEW_REFERENCES.ATTRIBUTE5,
   ATTRIBUTE6=NEW_REFERENCES.ATTRIBUTE6,
   ATTRIBUTE7=NEW_REFERENCES.ATTRIBUTE7,
   ATTRIBUTE8=NEW_REFERENCES.ATTRIBUTE8,
   ATTRIBUTE9=NEW_REFERENCES.ATTRIBUTE9,
   ATTRIBUTE10=NEW_REFERENCES.ATTRIBUTE10,
   ATTRIBUTE11=NEW_REFERENCES.ATTRIBUTE11,
   ATTRIBUTE12=NEW_REFERENCES.ATTRIBUTE12,
   ATTRIBUTE13=NEW_REFERENCES.ATTRIBUTE13,
   ATTRIBUTE14=NEW_REFERENCES.ATTRIBUTE14,
   ATTRIBUTE15=NEW_REFERENCES.ATTRIBUTE15,
   ATTRIBUTE16=NEW_REFERENCES.ATTRIBUTE16,
   ATTRIBUTE17=NEW_REFERENCES.ATTRIBUTE17,
   ATTRIBUTE18=NEW_REFERENCES.ATTRIBUTE18,
   ATTRIBUTE19=NEW_REFERENCES.ATTRIBUTE19,
   ATTRIBUTE20=NEW_REFERENCES.ATTRIBUTE20
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

--
 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
--
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
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_UNIT_SET_CD IN VARCHAR2,
  X_SEQUENCE_NUMBER IN NUMBER,
  X_US_VERSION_NUMBER IN NUMBER,
  X_SELECTION_DT IN DATE,
  X_STUDENT_CONFIRMED_IND IN VARCHAR2,
  X_END_DT IN DATE,
  X_PARENT_UNIT_SET_CD IN VARCHAR2,
  X_PARENT_SEQUENCE_NUMBER IN NUMBER,
  X_PRIMARY_SET_IND IN VARCHAR2,
  X_VOLUNTARY_END_IND IN VARCHAR2,
  X_AUTHORISED_PERSON_ID IN NUMBER,
  X_AUTHORISED_ON IN DATE,
  X_OVERRIDE_TITLE IN VARCHAR2,
  X_RQRMNTS_COMPLETE_IND IN VARCHAR2,
  X_RQRMNTS_COMPLETE_DT IN DATE,
  X_S_COMPLETED_SOURCE_TYPE IN VARCHAR2,
  X_CATALOG_CAL_TYPE IN VARCHAR2 ,
  X_CATALOG_SEQ_NUM IN NUMBER ,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  X_ATTRIBUTE20 IN VARCHAR2 ,
  X_MODE IN VARCHAR2
  ) AS
  CURSOR c1 IS SELECT ROWID FROM IGS_AS_SU_SETATMPT
     WHERE PERSON_ID = X_PERSON_ID
     AND COURSE_CD = X_COURSE_CD
     AND UNIT_SET_CD = X_UNIT_SET_CD
     AND SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;
BEGIN
  OPEN c1;
  FETCH c1 INTO X_ROWID;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_UNIT_SET_CD,
     X_SEQUENCE_NUMBER,
     X_US_VERSION_NUMBER,
     X_SELECTION_DT,
     X_STUDENT_CONFIRMED_IND,
     X_END_DT,
     X_PARENT_UNIT_SET_CD,
     X_PARENT_SEQUENCE_NUMBER,
     X_PRIMARY_SET_IND,
     X_VOLUNTARY_END_IND,
     X_AUTHORISED_PERSON_ID,
     X_AUTHORISED_ON,
     X_OVERRIDE_TITLE,
     X_RQRMNTS_COMPLETE_IND,
     X_RQRMNTS_COMPLETE_DT,
     X_S_COMPLETED_SOURCE_TYPE,
     X_CATALOG_CAL_TYPE,
     X_CATALOG_SEQ_NUM,
    X_ATTRIBUTE_CATEGORY,
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
    X_ATTRIBUTE20,
     X_MODE);
    RETURN;
  END IF;
  CLOSE c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_UNIT_SET_CD,
   X_SEQUENCE_NUMBER,
   X_US_VERSION_NUMBER,
   X_SELECTION_DT,
   X_STUDENT_CONFIRMED_IND,
   X_END_DT,
   X_PARENT_UNIT_SET_CD,
   X_PARENT_SEQUENCE_NUMBER,
   X_PRIMARY_SET_IND,
   X_VOLUNTARY_END_IND,
   X_AUTHORISED_PERSON_ID,
   X_AUTHORISED_ON,
   X_OVERRIDE_TITLE,
   X_RQRMNTS_COMPLETE_IND,
   X_RQRMNTS_COMPLETE_DT,
   X_S_COMPLETED_SOURCE_TYPE,
   X_CATALOG_CAL_TYPE,
   X_CATALOG_SEQ_NUM,
   X_ATTRIBUTE_CATEGORY,
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
   X_ATTRIBUTE20,
   X_MODE);
END ADD_ROW;
PROCEDURE DELETE_ROW (
  X_ROWID IN VARCHAR2,
  x_mode IN VARCHAR2) AS
BEGIN
--
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
--
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  DELETE FROM IGS_AS_SU_SETATMPT
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

--
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
--
END DELETE_ROW;
END IGS_AS_SU_SETATMPT_PKG;

/
