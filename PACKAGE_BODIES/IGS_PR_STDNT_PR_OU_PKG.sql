--------------------------------------------------------
--  DDL for Package Body IGS_PR_STDNT_PR_OU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_STDNT_PR_OU_PKG" AS
/* $Header: IGSQI15B.pls 120.0 2005/07/05 12:07:10 appldev noship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_PR_STDNT_PR_OU_ALL%RowType;
  new_references IGS_PR_STDNT_PR_OU_ALL%RowType;

 /* Forward Declaration of apply_appr_outcome*/
  PROCEDURE apply_appr_outcome;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_prg_cal_type IN VARCHAR2 ,
    x_prg_ci_sequence_number IN NUMBER ,
    x_rule_check_dt IN DATE ,
    x_progression_rule_cat IN VARCHAR2 ,
    x_pra_sequence_number IN NUMBER ,
    x_pro_sequence_number IN NUMBER ,
    x_progression_outcome_type IN VARCHAR2 ,
    x_duration IN NUMBER ,
    x_duration_type IN VARCHAR2 ,
    x_decision_status IN VARCHAR2 ,
    x_decision_dt IN DATE,
    x_decision_org_unit_cd IN VARCHAR2,
    x_decision_ou_start_dt IN DATE,
    x_applied_dt IN DATE,
    x_show_cause_expiry_dt IN DATE,
    x_show_cause_dt IN DATE,
    x_show_cause_outcome_dt IN DATE,
    x_show_cause_outcome_type IN VARCHAR2,
    x_appeal_expiry_dt IN DATE,
    x_appeal_dt IN DATE,
    x_appeal_outcome_dt IN DATE,
    x_appeal_outcome_type IN VARCHAR2 ,
    x_encmb_course_group_cd IN VARCHAR2 ,
    x_restricted_enrolment_cp IN NUMBER ,
    x_restricted_attendance_type IN VARCHAR2,
    x_comments IN VARCHAR2 ,
    x_show_cause_comments IN VARCHAR2,
    x_appeal_comments IN VARCHAR2,
    x_person_id IN NUMBER ,
    x_course_cd IN VARCHAR2 ,
    x_sequence_number IN NUMBER ,
    x_expiry_dt IN DATE ,
    x_pro_pra_sequence_number IN NUMBER,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_STDNT_PR_OU_ALL
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND
       (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.prg_cal_type := x_prg_cal_type;
    new_references.prg_ci_sequence_number := x_prg_ci_sequence_number;
    new_references.rule_check_dt := x_rule_check_dt;
    new_references.progression_rule_cat := x_progression_rule_cat;
    new_references.pra_sequence_number := x_pra_sequence_number;
    new_references.pro_sequence_number := x_pro_sequence_number;
    new_references.progression_outcome_type := x_progression_outcome_type;
    new_references.duration := x_duration;
    new_references.duration_type := x_duration_type;
    new_references.decision_status := x_decision_status;
    new_references.decision_dt := x_decision_dt;
    new_references.decision_org_unit_cd := x_decision_org_unit_cd;
    new_references.decision_ou_start_dt := x_decision_ou_start_dt;
    new_references.applied_dt := x_applied_dt;
    new_references.show_cause_expiry_dt := x_show_cause_expiry_dt;
    new_references.show_cause_dt := x_show_cause_dt;
    new_references.show_cause_outcome_dt := x_show_cause_outcome_dt;
    new_references.show_cause_outcome_type := x_show_cause_outcome_type;
    new_references.appeal_expiry_dt := x_appeal_expiry_dt;
    new_references.appeal_dt := x_appeal_dt;
    new_references.appeal_outcome_dt := x_appeal_outcome_dt;
    new_references.appeal_outcome_type := x_appeal_outcome_type;
    new_references.encmb_course_group_cd := x_encmb_course_group_cd;
    new_references.restricted_enrolment_cp := x_restricted_enrolment_cp;
    new_references.restricted_attendance_type := x_restricted_attendance_type;
    new_references.comments := x_comments;
    new_references.show_cause_comments := x_show_cause_comments;
    new_references.appeal_comments := x_appeal_comments;
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.sequence_number := x_sequence_number;
    new_references.expiry_dt := x_expiry_dt;
    new_references.pro_pra_sequence_number := x_pro_pra_sequence_number;
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
    new_references.org_id := x_org_id;

  END Set_Column_Values;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.restricted_attendance_type =
          new_references.restricted_attendance_type)) OR
        ((new_references.restricted_attendance_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_TYPE_PKG.Get_PK_For_Validation (
        new_references.restricted_attendance_type
        ) THEN
        Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.encmb_course_group_cd =
          new_references.encmb_course_group_cd)) OR
        ((new_references.encmb_course_group_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_GRP_PKG.Get_PK_For_Validation (
        new_references.encmb_course_group_cd
        )THEN
        Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.decision_org_unit_cd =
          new_references.decision_org_unit_cd) AND
         (old_references.decision_ou_start_dt =
          new_references.decision_ou_start_dt)) OR
        ((new_references.decision_org_unit_cd IS NULL) OR
         (new_references.decision_ou_start_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.decision_org_unit_cd,
        new_references.decision_ou_start_dt
        )THEN
        Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.progression_outcome_type =
          new_references.progression_outcome_type)) OR
        ((new_references.progression_outcome_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_OU_TYPE_PKG.Get_PK_For_Validation (
        new_references.progression_outcome_type
        )THEN
        Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.progression_rule_cat =
          new_references.progression_rule_cat) AND
         (old_references.pro_pra_sequence_number =
	  new_references.pro_pra_sequence_number) AND
         (old_references.pro_sequence_number =
	  new_references.pro_sequence_number)) OR
        ((new_references.progression_rule_cat IS NULL) OR
         (new_references.pro_pra_sequence_number IS NULL) OR
         (new_references.pro_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_RU_OU_PKG.Get_PK_For_Validation (
        new_references.progression_rule_cat,
        new_references.pro_pra_sequence_number,
        new_references.pro_sequence_number
        )THEN
        Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.prg_cal_type = new_references.prg_cal_type) AND
         (old_references.prg_ci_sequence_number =
	  new_references.prg_ci_sequence_number) AND
         (old_references.progression_rule_cat =
	  new_references.progression_rule_cat) AND
         (old_references.pra_sequence_number =
	  new_references.pra_sequence_number) AND
         (old_references.rule_check_dt = new_references.rule_check_dt)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL) OR
         (new_references.prg_cal_type IS NULL) OR
         (new_references.prg_ci_sequence_number IS NULL) OR
         (new_references.progression_rule_cat IS NULL) OR
         (new_references.pra_sequence_number IS NULL) OR
         (new_references.rule_check_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_SDT_PR_RU_CK_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd,
        new_references.prg_cal_type,
        new_references.prg_ci_sequence_number,
        new_references.progression_rule_cat,
        new_references.pra_sequence_number,
        new_references.rule_check_dt
        )THEN
        Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN
    igs_pr_ru_appl_pkg.get_fk_igs_pr_stdnt_pr_ou (
      old_references.person_id,
      old_references.course_cd,
      old_references.sequence_number
    );

    igs_pr_stdnt_pr_ps_pkg.get_fk_igs_pr_stdnt_pr_ou (
      old_references.person_id,
      old_references.course_cd,
      old_references.sequence_number
    );

    igs_pr_stdnt_pr_unit_pkg.get_fk_igs_pr_stdnt_pr_ou (
      old_references.person_id,
      old_references.course_cd,
      old_references.sequence_number
    );

    igs_pr_sdt_pr_unt_st_pkg.get_fk_igs_pr_stdnt_pr_ou (
      old_references.person_id,
      old_references.course_cd,
      old_references.sequence_number
    );

    igs_pr_stdnt_pr_awd_pkg.get_fk_igs_pr_stdnt_pr_ou (
      old_references.person_id,
      old_references.course_cd,
      old_references.sequence_number
    );

    igs_pr_stdnt_pr_fnd_pkg.get_fk_igs_pr_stdnt_pr_ou(
      old_references.person_id,
      old_references.course_cd,
      old_references.sequence_number
    );
  END Check_Child_Existance;

FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_pr_stdnt_pr_ou_all
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      sequence_number = x_sequence_number
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return (TRUE);
    ELSE
      Close cur_rowid;
      Return (FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
  ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_pr_stdnt_pr_ou_all
      WHERE    restricted_attendance_type = x_attendance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SPO_ATT_FK');
      IGS_GE_MSG_STACK.ADD;
          Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ATD_TYPE;


	PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_pr_stdnt_pr_ou_all
      WHERE    decision_org_unit_cd = x_org_unit_cd
      AND      decision_ou_start_dt = x_start_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SPO_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_OR_UNIT;

  PROCEDURE GET_FK_IGS_PR_OU_TYPE (
    x_progression_outcome_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_pr_stdnt_pr_ou_all
      WHERE    progression_outcome_type = x_progression_outcome_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SPO_POT_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_OU_TYPE;

  PROCEDURE GET_FK_IGS_PR_RU_OU (
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_pr_stdnt_pr_ou_all
      WHERE    progression_rule_cat = x_progression_rule_cat
      AND      pro_pra_sequence_number = x_pra_sequence_number
      AND      pro_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SPO_PRO_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_RU_OU;

  PROCEDURE GET_FK_IGS_PR_SDT_PR_RU_CK (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_prg_cal_type IN VARCHAR2,
    x_prg_ci_sequence_number IN NUMBER,
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_rule_check_dt IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_pr_stdnt_pr_ou_all
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      prg_cal_type = x_prg_cal_type
      AND      prg_ci_sequence_number = x_prg_ci_sequence_number
      AND      rule_check_dt = x_rule_check_dt
      AND      progression_rule_cat = x_progression_rule_cat
      AND      pra_sequence_number = x_pra_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SPO_SPRC_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_SDT_PR_RU_CK;

  PROCEDURE BeforeInsertUpdate( p_action VARCHAR2 ) AS
  /*
  ||  Created By : anilk
  ||  Created On : 25-FEB-2003
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c_parent (
         cp_progression_rule_cat    IGS_PR_RU_OU.progression_rule_cat%TYPE,
         cp_pro_pra_sequence_number IGS_PR_RU_OU.pra_sequence_number%TYPE,
         cp_sequence_number         IGS_PR_RU_OU.sequence_number%TYPE  ) IS
     SELECT 1
     FROM   IGS_PR_RU_OU pro
     WHERE  pro.progression_rule_cat = cp_progression_rule_cat    AND
            pro.pra_sequence_number  = cp_pro_pra_sequence_number AND
            pro.sequence_number      = cp_sequence_number     AND
            pro.logical_delete_dt is NULL;
    l_dummy NUMBER;
  BEGIN
   IF (p_action = 'INSERT') AND new_references.progression_rule_cat IS NOT NULL
                            AND new_references.pro_pra_sequence_number  IS NOT NULL
                            AND new_references.pro_sequence_number  IS NOT NULL THEN
      OPEN c_parent( new_references.progression_rule_cat, new_references.pro_pra_sequence_number, new_references.pro_sequence_number );
      FETCH c_parent INTO l_dummy;
      IF c_parent%NOTFOUND THEN
          CLOSE c_parent;
          FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      CLOSE c_parent;
   ELSIF(p_action = 'UPDATE') THEN
      IF NVL(new_references.progression_rule_cat,'1') <> NVL(old_references.progression_rule_cat,'1')  OR
         NVL(new_references.pro_pra_sequence_number,1) <> NVL(old_references.pro_pra_sequence_number,1)  OR
         NVL(new_references.pro_sequence_number,1) <> NVL(old_references.pro_sequence_number,1)  THEN
        OPEN c_parent( new_references.progression_rule_cat,  new_references.pro_pra_sequence_number, new_references.pro_sequence_number );
        FETCH c_parent INTO l_dummy;
        IF c_parent%NOTFOUND THEN
          CLOSE c_parent;
          FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
        CLOSE c_parent;
      END IF;
   END IF;
  END BeforeInsertUpdate;

	PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_prg_cal_type IN VARCHAR2,
    x_prg_ci_sequence_number IN NUMBER,
    x_rule_check_dt IN DATE ,
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_pro_sequence_number IN NUMBER,
    x_progression_outcome_type IN VARCHAR2,
    x_duration IN NUMBER ,
    x_duration_type IN VARCHAR2,
    x_decision_status IN VARCHAR2,
    x_decision_dt IN DATE,
    x_decision_org_unit_cd IN VARCHAR2,
    x_decision_ou_start_dt IN DATE,
    x_applied_dt IN DATE,
    x_show_cause_expiry_dt IN DATE,
    x_show_cause_dt IN DATE,
    x_show_cause_outcome_dt IN DATE,
    x_show_cause_outcome_type IN VARCHAR2,
    x_appeal_expiry_dt IN DATE,
    x_appeal_dt IN DATE,
    x_appeal_outcome_dt IN DATE,
    x_appeal_outcome_type IN VARCHAR2,
    x_encmb_course_group_cd IN VARCHAR2,
    x_restricted_enrolment_cp IN NUMBER,
    x_restricted_attendance_type IN VARCHAR2,
    x_comments IN VARCHAR2,
    x_show_cause_comments IN VARCHAR2,
    x_appeal_comments IN VARCHAR2,
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_expiry_dt IN DATE,
    x_pro_pra_sequence_number IN NUMBER ,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_org_id IN NUMBER
  ) AS

    CURSOR c_sysout_type IS
      SELECT s_progression_outcome_type
      FROM   igs_pr_ou_type
      WHERE  progression_outcome_type = x_progression_outcome_type;
    lvSystem_Outcome_Type IGS_PR_ou_type.S_PROGRESSION_OUTCOME_TYPE%TYPE;

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_prg_cal_type,
      x_prg_ci_sequence_number,
      x_rule_check_dt,
      x_progression_rule_cat,
      x_pra_sequence_number,
      x_pro_sequence_number,
      x_progression_outcome_type,
      x_duration,
      x_duration_type,
      x_decision_status,
      x_decision_dt,
      x_decision_org_unit_cd,
      x_decision_ou_start_dt,
      x_applied_dt,
      x_show_cause_expiry_dt,
      x_show_cause_dt,
      x_show_cause_outcome_dt,
      x_show_cause_outcome_type,
      x_appeal_expiry_dt,
      x_appeal_dt,
      x_appeal_outcome_dt,
      x_appeal_outcome_type,
      x_encmb_course_group_cd,
      x_restricted_enrolment_cp,
      x_restricted_attendance_type,
      x_comments,
      x_show_cause_comments,
      x_appeal_comments,
      x_person_id,
      x_course_cd,
      x_sequence_number,
      x_expiry_dt,
      x_pro_pra_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    -- Added this code as part of progression build, bug 2138644, pmarada
    IF (p_action = 'INSERT' OR P_ACTION = 'UPDATE') THEN
      OPEN c_sysout_type;
      FETCH  c_sysout_type  INTO lvSystem_Outcome_Type;
      CLOSE c_sysout_type;
      IF lvSystem_Outcome_Type = 'SUSPENSION' THEN
        IF (x_duration IS NULL OR x_duration_type IS NULL) THEN
          Fnd_Message.Set_Name('IGS','IGS_PR_SUSP_OUC_MUST_DURAT');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
      END IF;
      IF lvSystem_Outcome_Type <> 'PROBATION' THEN
        IF x_duration_type = 'EFFECTIVE' THEN
          Fnd_Message.Set_Name('IGS','IGS_PR_PROB_OUC_ONLY_EFCT_DUR');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
      END IF;
    END IF;    -- end of the added code, pmarada

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      check_parent_existance;
      IF get_pk_for_validation (
           new_references.person_id ,
           new_references.course_cd,
           new_references.sequence_number) THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
           new_references.person_id ,
           new_references.course_cd,
           new_references.sequence_number)  THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

    -- anilk, bug#2784198
    BeforeInsertUpdate(p_action);

  END Before_DML;

  PROCEDURE INSERT_ROW (
    X_ROWID IN OUT NOCOPY VARCHAR2,
    X_PERSON_ID IN NUMBER,
    X_COURSE_CD IN VARCHAR2,
    X_SEQUENCE_NUMBER IN NUMBER,
    X_PRG_CAL_TYPE IN VARCHAR2,
    X_PRG_CI_SEQUENCE_NUMBER IN NUMBER,
    X_RULE_CHECK_DT IN DATE,
    X_PROGRESSION_RULE_CAT IN VARCHAR2,
    X_PRA_SEQUENCE_NUMBER IN NUMBER,
    X_PRO_SEQUENCE_NUMBER IN NUMBER,
    X_PROGRESSION_OUTCOME_TYPE IN VARCHAR2,
    X_DURATION IN NUMBER,
    X_DURATION_TYPE IN VARCHAR2,
    X_DECISION_STATUS IN VARCHAR2,
    X_DECISION_DT IN DATE,
    X_DECISION_ORG_UNIT_CD IN VARCHAR2,
    X_DECISION_OU_START_DT IN DATE,
    X_APPLIED_DT IN DATE,
    X_SHOW_CAUSE_EXPIRY_DT IN DATE,
    X_SHOW_CAUSE_DT IN DATE,
    X_SHOW_CAUSE_OUTCOME_DT IN DATE,
    X_SHOW_CAUSE_OUTCOME_TYPE IN VARCHAR2,
    X_APPEAL_EXPIRY_DT IN DATE,
    X_APPEAL_DT IN DATE,
    X_APPEAL_OUTCOME_DT IN DATE,
    X_APPEAL_OUTCOME_TYPE IN VARCHAR2,
    X_ENCMB_COURSE_GROUP_CD IN VARCHAR2,
    X_RESTRICTED_ENROLMENT_CP IN NUMBER,
    X_RESTRICTED_ATTENDANCE_TYPE IN VARCHAR2,
    X_COMMENTS IN VARCHAR2,
    X_SHOW_CAUSE_COMMENTS IN VARCHAR2,
    X_APPEAL_COMMENTS IN VARCHAR2,
    X_EXPIRY_DT IN DATE,
    X_PRO_PRA_SEQUENCE_NUMBER IN NUMBER,
    X_MODE IN VARCHAR2,
    X_ORG_ID IN NUMBER
    ) AS
      CURSOR C IS
      SELECT ROWID
      FROM   igs_pr_stdnt_pr_ou_all
      WHERE  person_id = x_person_id
      AND    course_cd = x_course_cd
      AND    sequence_number = x_sequence_number;
      X_LAST_UPDATE_DATE DATE;
      X_LAST_UPDATED_BY NUMBER;
      X_LAST_UPDATE_LOGIN NUMBER;
  BEGIN
    X_LAST_UPDATE_DATE := SYSDATE;
    IF (X_MODE = 'I') THEN
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
      FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;

  Before_DML (
      p_action =>'INSERT',
      x_rowid => x_rowid ,
      x_prg_cal_type => x_prg_cal_type ,
      x_prg_ci_sequence_number => x_prg_ci_sequence_number ,
      x_rule_check_dt => x_rule_check_dt ,
      x_progression_rule_cat => x_progression_rule_cat ,
      x_pra_sequence_number => x_pra_sequence_number ,
      x_pro_sequence_number => x_pro_sequence_number ,
      x_progression_outcome_type => x_progression_outcome_type ,
      x_duration => x_duration ,
      x_duration_type => x_duration_type ,
      x_decision_status => x_decision_status ,
      x_decision_dt => x_decision_dt ,
      x_decision_org_unit_cd => x_decision_org_unit_cd ,
      x_decision_ou_start_dt => x_decision_ou_start_dt ,
      x_applied_dt => x_applied_dt ,
      x_show_cause_expiry_dt => x_show_cause_expiry_dt ,
      x_show_cause_dt => x_show_cause_dt ,
      x_show_cause_outcome_dt => x_show_cause_outcome_dt ,
      x_show_cause_outcome_type => x_show_cause_outcome_type ,
      x_appeal_expiry_dt => x_appeal_expiry_dt ,
      x_appeal_dt => x_appeal_dt ,
      x_appeal_outcome_dt => x_appeal_outcome_dt ,
      x_appeal_outcome_type => x_appeal_outcome_type ,
      x_encmb_course_group_cd => x_encmb_course_group_cd ,
      x_restricted_enrolment_cp => x_restricted_enrolment_cp ,
      x_restricted_attendance_type => x_restricted_attendance_type ,
      x_comments => x_comments ,
      x_show_cause_comments => x_show_cause_comments ,
      x_appeal_comments => x_appeal_comments ,
      x_person_id => x_person_id ,
      x_course_cd => x_course_cd ,
      x_sequence_number => x_sequence_number ,
      x_expiry_dt => x_expiry_dt,
      x_pro_pra_sequence_number => x_pro_pra_sequence_number,
      x_creation_date => x_last_update_date ,
      x_created_by => x_last_updated_by ,
      x_last_update_date => x_last_update_date ,
      x_last_updated_by => x_last_updated_by ,
      x_last_update_login => x_last_update_login,
      x_org_id => igs_ge_gen_003.get_org_id
    ) ;

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pr_stdnt_pr_ou_all (
      person_id,
      course_cd,
      sequence_number,
      prg_cal_type,
      prg_ci_sequence_number,
      rule_check_dt,
      progression_rule_cat,
      pra_sequence_number,
      pro_sequence_number,
      progression_outcome_type,
      duration,
      duration_type,
      decision_status,
      decision_dt,
      decision_org_unit_cd,
      decision_ou_start_dt,
      applied_dt,
      show_cause_expiry_dt,
      show_cause_dt,
      show_cause_outcome_dt,
      show_cause_outcome_type,
      appeal_expiry_dt,
      appeal_dt,
      appeal_outcome_dt,
      appeal_outcome_type,
      encmb_course_group_cd,
      restricted_enrolment_cp,
      restricted_attendance_type,
      comments,
      show_cause_comments,
      appeal_comments,
      expiry_dt,
      pro_pra_sequence_number,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id
    ) VALUES (
      new_references.person_id,
      new_references.course_cd,
      new_references.sequence_number,
      new_references.prg_cal_type,
      new_references.prg_ci_sequence_number,
      new_references.rule_check_dt,
      new_references.progression_rule_cat,
      new_references.pra_sequence_number,
      new_references.pro_sequence_number,
      new_references.progression_outcome_type,
      new_references.duration,
      new_references.duration_type,
      new_references.decision_status,
      new_references.decision_dt,
      new_references.decision_org_unit_cd,
      new_references.decision_ou_start_dt,
      new_references.applied_dt,
      new_references.show_cause_expiry_dt,
      new_references.show_cause_dt,
      new_references.show_cause_outcome_dt,
      new_references.show_cause_outcome_type,
      new_references.appeal_expiry_dt,
      new_references.appeal_dt,
      new_references.appeal_outcome_dt,
      new_references.appeal_outcome_type,
      new_references.encmb_course_group_cd,
      new_references.restricted_enrolment_cp,
      new_references.restricted_attendance_type,
      new_references.comments,
      new_references.show_cause_comments,
      new_references.appeal_comments,
      new_references.expiry_dt,
      new_references.pro_pra_sequence_number,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.org_id
    );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    OPEN C;
    FETCH C INTO x_rowid;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;
    apply_appr_outcome;

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
    X_SEQUENCE_NUMBER IN NUMBER,
    X_PRG_CAL_TYPE IN VARCHAR2,
    X_PRG_CI_SEQUENCE_NUMBER IN NUMBER,
    X_RULE_CHECK_DT IN DATE,
    X_PROGRESSION_RULE_CAT IN VARCHAR2,
    X_PRA_SEQUENCE_NUMBER IN NUMBER,
    X_PRO_SEQUENCE_NUMBER IN NUMBER,
    X_PROGRESSION_OUTCOME_TYPE IN VARCHAR2,
    X_DURATION IN NUMBER,
    X_DURATION_TYPE IN VARCHAR2,
    X_DECISION_STATUS IN VARCHAR2,
    X_DECISION_DT IN DATE,
    X_DECISION_ORG_UNIT_CD IN VARCHAR2,
    X_DECISION_OU_START_DT IN DATE,
    X_APPLIED_DT IN DATE,
    X_SHOW_CAUSE_EXPIRY_DT IN DATE,
    X_SHOW_CAUSE_DT IN DATE,
    X_SHOW_CAUSE_OUTCOME_DT IN DATE,
    X_SHOW_CAUSE_OUTCOME_TYPE IN VARCHAR2,
    X_APPEAL_EXPIRY_DT IN DATE,
    X_APPEAL_DT IN DATE,
    X_APPEAL_OUTCOME_DT IN DATE,
    X_APPEAL_OUTCOME_TYPE IN VARCHAR2,
    X_ENCMB_COURSE_GROUP_CD IN VARCHAR2,
    X_RESTRICTED_ENROLMENT_CP IN NUMBER,
    X_RESTRICTED_ATTENDANCE_TYPE IN VARCHAR2,
    X_COMMENTS IN VARCHAR2,
    X_SHOW_CAUSE_COMMENTS IN VARCHAR2,
    X_APPEAL_COMMENTS IN VARCHAR2,
    X_EXPIRY_DT IN DATE,
    X_PRO_PRA_SEQUENCE_NUMBER IN NUMBER
  ) AS
    CURSOR c1 IS SELECT
        prg_cal_type,
        prg_ci_sequence_number,
        rule_check_dt,
        progression_rule_cat,
        pra_sequence_number,
        pro_sequence_number,
        progression_outcome_type,
        duration,
        duration_type,
        decision_status,
        decision_dt,
        decision_org_unit_cd,
        decision_ou_start_dt,
        applied_dt,
        show_cause_expiry_dt,
        show_cause_dt,
        show_cause_outcome_dt,
        show_cause_outcome_type,
        appeal_expiry_dt,
        appeal_dt,
        appeal_outcome_dt,
        appeal_outcome_type,
        encmb_course_group_cd,
        restricted_enrolment_cp,
        restricted_attendance_type,
        comments,
        show_cause_comments,
        appeal_comments,
        expiry_dt,
        pro_pra_sequence_number
      FROM igs_pr_stdnt_pr_ou_all
      WHERE ROWID = x_rowid FOR UPDATE NOWAIT;
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

        IF ( ((tlinfo.PRG_CAL_TYPE = X_PRG_CAL_TYPE)
             OR ((tlinfo.PRG_CAL_TYPE IS NULL)
                 AND (X_PRG_CAL_TYPE IS NULL)))
        AND ((tlinfo.PRG_CI_SEQUENCE_NUMBER = X_PRG_CI_SEQUENCE_NUMBER)
             OR ((tlinfo.PRG_CI_SEQUENCE_NUMBER IS NULL)
                 AND (X_PRG_CI_SEQUENCE_NUMBER IS NULL)))
        AND ((tlinfo.RULE_CHECK_DT = X_RULE_CHECK_DT)
             OR ((tlinfo.RULE_CHECK_DT IS NULL)
                 AND (X_RULE_CHECK_DT IS NULL)))
        AND ((tlinfo.PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT)
             OR ((tlinfo.PROGRESSION_RULE_CAT IS NULL)
                 AND (X_PROGRESSION_RULE_CAT IS NULL)))
        AND ((tlinfo.PRA_SEQUENCE_NUMBER = X_PRA_SEQUENCE_NUMBER)
             OR ((tlinfo.PRA_SEQUENCE_NUMBER IS NULL)
                 AND (X_PRA_SEQUENCE_NUMBER IS NULL)))
        AND ((tlinfo.PRO_SEQUENCE_NUMBER = X_PRO_SEQUENCE_NUMBER)
             OR ((tlinfo.PRO_SEQUENCE_NUMBER IS NULL)
                 AND (X_PRO_SEQUENCE_NUMBER IS NULL)))
        AND ((tlinfo.PROGRESSION_OUTCOME_TYPE = X_PROGRESSION_OUTCOME_TYPE)
             OR ((tlinfo.PROGRESSION_OUTCOME_TYPE IS NULL)
                 AND (X_PROGRESSION_OUTCOME_TYPE IS NULL)))
        AND ((tlinfo.DURATION = X_DURATION)
             OR ((tlinfo.DURATION IS NULL)
                 AND (X_DURATION IS NULL)))
        AND ((tlinfo.DURATION_TYPE = X_DURATION_TYPE)
             OR ((tlinfo.DURATION_TYPE IS NULL)
                 AND (X_DURATION_TYPE IS NULL)))
        AND (tlinfo.DECISION_STATUS = X_DECISION_STATUS)
        AND ((TRUNC(tlinfo.DECISION_DT) = TRUNC(X_DECISION_DT))
             OR ((tlinfo.DECISION_DT IS NULL)
                 AND (X_DECISION_DT IS NULL)))
        AND ((tlinfo.DECISION_ORG_UNIT_CD = X_DECISION_ORG_UNIT_CD)
             OR ((tlinfo.DECISION_ORG_UNIT_CD IS NULL)
                 AND (X_DECISION_ORG_UNIT_CD IS NULL)))
        AND ((TRUNC(tlinfo.DECISION_OU_START_DT) =
              TRUNC(X_DECISION_OU_START_DT))
             OR ((tlinfo.DECISION_OU_START_DT IS NULL)
                 AND (X_DECISION_OU_START_DT IS NULL)))
        AND ((TRUNC(tlinfo.APPLIED_DT) = TRUNC(X_APPLIED_DT))
             OR ((tlinfo.APPLIED_DT IS NULL)
                 AND (X_APPLIED_DT IS NULL)))
        AND ((TRUNC(tlinfo.SHOW_CAUSE_EXPIRY_DT) =
              TRUNC(X_SHOW_CAUSE_EXPIRY_DT))
             OR ((tlinfo.SHOW_CAUSE_EXPIRY_DT IS NULL)
                 AND (X_SHOW_CAUSE_EXPIRY_DT IS NULL)))
        AND ((TRUNC(tlinfo.SHOW_CAUSE_DT) = TRUNC(X_SHOW_CAUSE_DT))
             OR ((tlinfo.SHOW_CAUSE_DT IS NULL)
                 AND (X_SHOW_CAUSE_DT IS NULL)))
        AND ((TRUNC(tlinfo.SHOW_CAUSE_OUTCOME_DT) =
              TRUNC(X_SHOW_CAUSE_OUTCOME_DT))
             OR ((tlinfo.SHOW_CAUSE_OUTCOME_DT IS NULL)
                 AND (X_SHOW_CAUSE_OUTCOME_DT IS NULL)))
        AND ((tlinfo.SHOW_CAUSE_OUTCOME_TYPE = X_SHOW_CAUSE_OUTCOME_TYPE)
             OR ((tlinfo.SHOW_CAUSE_OUTCOME_TYPE IS NULL)
                 AND (X_SHOW_CAUSE_OUTCOME_TYPE IS NULL)))
        AND ((TRUNC(tlinfo.APPEAL_EXPIRY_DT) = TRUNC(X_APPEAL_EXPIRY_DT))
             OR ((tlinfo.APPEAL_EXPIRY_DT IS NULL)
                 AND (X_APPEAL_EXPIRY_DT IS NULL)))
        AND ((TRUNC(tlinfo.APPEAL_DT) = TRUNC(X_APPEAL_DT))
             OR ((tlinfo.APPEAL_DT IS NULL)
                 AND (X_APPEAL_DT IS NULL)))
        AND ((TRUNC(tlinfo.APPEAL_OUTCOME_DT) = TRUNC(X_APPEAL_OUTCOME_DT))
             OR ((tlinfo.APPEAL_OUTCOME_DT IS NULL)
                 AND (X_APPEAL_OUTCOME_DT IS NULL)))
        AND ((tlinfo.APPEAL_OUTCOME_TYPE = X_APPEAL_OUTCOME_TYPE)
             OR ((tlinfo.APPEAL_OUTCOME_TYPE IS NULL)
                 AND (X_APPEAL_OUTCOME_TYPE IS NULL)))
        AND ((tlinfo.ENCMB_COURSE_GROUP_CD = X_ENCMB_COURSE_GROUP_CD)
             OR ((tlinfo.ENCMB_COURSE_GROUP_CD IS NULL)
                 AND (X_ENCMB_COURSE_GROUP_CD IS NULL)))
        AND ((tlinfo.RESTRICTED_ENROLMENT_CP = X_RESTRICTED_ENROLMENT_CP)
             OR ((tlinfo.RESTRICTED_ENROLMENT_CP IS NULL)
                 AND (X_RESTRICTED_ENROLMENT_CP IS NULL)))
        AND ((tlinfo.RESTRICTED_ATTENDANCE_TYPE = X_RESTRICTED_ATTENDANCE_TYPE)
             OR ((tlinfo.RESTRICTED_ATTENDANCE_TYPE IS NULL)
                 AND (X_RESTRICTED_ATTENDANCE_TYPE IS NULL)))
        AND ((tlinfo.COMMENTS = X_COMMENTS)
             OR ((tlinfo.COMMENTS IS NULL)
                 AND (X_COMMENTS IS NULL)))
        AND ((tlinfo.SHOW_CAUSE_COMMENTS = X_SHOW_CAUSE_COMMENTS)
             OR ((tlinfo.SHOW_CAUSE_COMMENTS IS NULL)
                 AND (X_SHOW_CAUSE_COMMENTS IS NULL)))
        AND ((tlinfo.APPEAL_COMMENTS = X_APPEAL_COMMENTS)
             OR ((tlinfo.APPEAL_COMMENTS IS NULL)
                 AND (X_APPEAL_COMMENTS IS NULL)))
        AND ((TRUNC(tlinfo.EXPIRY_DT) = TRUNC(X_EXPIRY_DT))
             OR ((tlinfo.EXPIRY_DT IS NULL)
                 AND (X_EXPIRY_DT IS NULL)))
        AND ((tlinfo.PRO_PRA_SEQUENCE_NUMBER = X_PRO_PRA_SEQUENCE_NUMBER)
             OR ((tlinfo.PRO_PRA_SEQUENCE_NUMBER IS NULL)
                 AND (X_PRO_PRA_SEQUENCE_NUMBER IS NULL)))
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
    X_SEQUENCE_NUMBER IN NUMBER,
    X_PRG_CAL_TYPE IN VARCHAR2,
    X_PRG_CI_SEQUENCE_NUMBER IN NUMBER,
    X_RULE_CHECK_DT IN DATE,
    X_PROGRESSION_RULE_CAT IN VARCHAR2,
    X_PRA_SEQUENCE_NUMBER IN NUMBER,
    X_PRO_SEQUENCE_NUMBER IN NUMBER,
    X_PROGRESSION_OUTCOME_TYPE IN VARCHAR2,
    X_DURATION IN NUMBER,
    X_DURATION_TYPE IN VARCHAR2,
    X_DECISION_STATUS IN VARCHAR2,
    X_DECISION_DT IN DATE,
    X_DECISION_ORG_UNIT_CD IN VARCHAR2,
    X_DECISION_OU_START_DT IN DATE,
    X_APPLIED_DT IN DATE,
    X_SHOW_CAUSE_EXPIRY_DT IN DATE,
    X_SHOW_CAUSE_DT IN DATE,
    X_SHOW_CAUSE_OUTCOME_DT IN DATE,
    X_SHOW_CAUSE_OUTCOME_TYPE IN VARCHAR2,
    X_APPEAL_EXPIRY_DT IN DATE,
    X_APPEAL_DT IN DATE,
    X_APPEAL_OUTCOME_DT IN DATE,
    X_APPEAL_OUTCOME_TYPE IN VARCHAR2,
    X_ENCMB_COURSE_GROUP_CD IN VARCHAR2,
    X_RESTRICTED_ENROLMENT_CP IN NUMBER,
    X_RESTRICTED_ATTENDANCE_TYPE IN VARCHAR2,
    X_COMMENTS IN VARCHAR2,
    X_SHOW_CAUSE_COMMENTS IN VARCHAR2,
    X_APPEAL_COMMENTS IN VARCHAR2,
    X_EXPIRY_DT IN DATE,
    X_PRO_PRA_SEQUENCE_NUMBER IN NUMBER,
    X_MODE IN VARCHAR2
    ) AS
      X_LAST_UPDATE_DATE DATE;
      X_LAST_UPDATED_BY NUMBER;
      X_LAST_UPDATE_LOGIN NUMBER;
  BEGIN
    X_LAST_UPDATE_DATE := SYSDATE;
    IF (X_MODE = 'I') THEN
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
      p_action =>'UPDATE',
      x_rowid => x_rowid ,
      x_prg_cal_type => x_prg_cal_type ,
      x_prg_ci_sequence_number => x_prg_ci_sequence_number ,
      x_rule_check_dt => x_rule_check_dt ,
      x_progression_rule_cat => x_progression_rule_cat ,
      x_pra_sequence_number => x_pra_sequence_number ,
      x_pro_sequence_number => x_pro_sequence_number ,
      x_progression_outcome_type => x_progression_outcome_type ,
      x_duration => x_duration ,
      x_duration_type => x_duration_type ,
      x_decision_status => x_decision_status ,
      x_decision_dt => x_decision_dt ,
      x_decision_org_unit_cd => x_decision_org_unit_cd ,
      x_decision_ou_start_dt => x_decision_ou_start_dt ,
      x_applied_dt => x_applied_dt ,
      x_show_cause_expiry_dt => x_show_cause_expiry_dt ,
      x_show_cause_dt => x_show_cause_dt ,
      x_show_cause_outcome_dt => x_show_cause_outcome_dt ,
      x_show_cause_outcome_type => x_show_cause_outcome_type ,
      x_appeal_expiry_dt => x_appeal_expiry_dt ,
      x_appeal_dt => x_appeal_dt ,
      x_appeal_outcome_dt => x_appeal_outcome_dt ,
      x_appeal_outcome_type => x_appeal_outcome_type ,
      x_encmb_course_group_cd => x_encmb_course_group_cd ,
      x_restricted_enrolment_cp => x_restricted_enrolment_cp ,
      x_restricted_attendance_type => x_restricted_attendance_type ,
      x_comments => x_comments ,
      x_show_cause_comments => x_show_cause_comments ,
      x_appeal_comments => x_appeal_comments ,
      x_person_id => x_person_id ,
      x_course_cd => x_course_cd ,
      x_sequence_number => x_sequence_number ,
      x_expiry_dt => x_expiry_dt,
      x_pro_pra_sequence_number => x_pro_pra_sequence_number,
      x_creation_date => x_last_update_date ,
      x_created_by => x_last_updated_by ,
      x_last_update_date => x_last_update_date ,
      x_last_updated_by => x_last_updated_by ,
      x_last_update_login => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pr_stdnt_pr_ou_all SET
      prg_cal_type = new_references.prg_cal_type,
      prg_ci_sequence_number = new_references.prg_ci_sequence_number,
      rule_check_dt = new_references.rule_check_dt,
      progression_rule_cat = new_references.progression_rule_cat,
      pra_sequence_number = new_references.pra_sequence_number,
      pro_sequence_number = new_references.pro_sequence_number,
      progression_outcome_type = new_references.progression_outcome_type,
      duration = new_references.duration,
      duration_type = new_references.duration_type,
      decision_status = new_references.decision_status,
      decision_dt = new_references.decision_dt,
      decision_org_unit_cd = new_references.decision_org_unit_cd,
      decision_ou_start_dt = new_references.decision_ou_start_dt,
      applied_dt = new_references.applied_dt,
      show_cause_expiry_dt = new_references.show_cause_expiry_dt,
      show_cause_dt = new_references.show_cause_dt,
      show_cause_outcome_dt = new_references.show_cause_outcome_dt,
      show_cause_outcome_type = new_references.show_cause_outcome_type,
      appeal_expiry_dt = new_references.appeal_expiry_dt,
      appeal_dt = new_references.appeal_dt,
      appeal_outcome_dt = new_references.appeal_outcome_dt,
      appeal_outcome_type = new_references.appeal_outcome_type,
      encmb_course_group_cd = new_references.encmb_course_group_cd,
      restricted_enrolment_cp = new_references.restricted_enrolment_cp,
      restricted_attendance_type = new_references.restricted_attendance_type,
      comments = new_references.comments,
      show_cause_comments = new_references.show_cause_comments,
      appeal_comments = new_references.appeal_comments,
      expiry_dt = new_references.expiry_dt,
      pro_pra_sequence_number = new_references.pro_pra_sequence_number,
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by,
      last_update_login = x_last_update_login
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

    apply_appr_outcome;

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
    X_SEQUENCE_NUMBER IN NUMBER,
    X_PRG_CAL_TYPE IN VARCHAR2,
    X_PRG_CI_SEQUENCE_NUMBER IN NUMBER,
    X_RULE_CHECK_DT IN DATE,
    X_PROGRESSION_RULE_CAT IN VARCHAR2,
    X_PRA_SEQUENCE_NUMBER IN NUMBER,
    X_PRO_SEQUENCE_NUMBER IN NUMBER,
    X_PROGRESSION_OUTCOME_TYPE IN VARCHAR2,
    X_DURATION IN NUMBER,
    X_DURATION_TYPE IN VARCHAR2,
    X_DECISION_STATUS IN VARCHAR2,
    X_DECISION_DT IN DATE,
    X_DECISION_ORG_UNIT_CD IN VARCHAR2,
    X_DECISION_OU_START_DT IN DATE,
    X_APPLIED_DT IN DATE,
    X_SHOW_CAUSE_EXPIRY_DT IN DATE,
    X_SHOW_CAUSE_DT IN DATE,
    X_SHOW_CAUSE_OUTCOME_DT IN DATE,
    X_SHOW_CAUSE_OUTCOME_TYPE IN VARCHAR2,
    X_APPEAL_EXPIRY_DT IN DATE,
    X_APPEAL_DT IN DATE,
    X_APPEAL_OUTCOME_DT IN DATE,
    X_APPEAL_OUTCOME_TYPE IN VARCHAR2,
    X_ENCMB_COURSE_GROUP_CD IN VARCHAR2,
    X_RESTRICTED_ENROLMENT_CP IN NUMBER,
    X_RESTRICTED_ATTENDANCE_TYPE IN VARCHAR2,
    X_COMMENTS IN VARCHAR2,
    X_SHOW_CAUSE_COMMENTS IN VARCHAR2,
    X_APPEAL_COMMENTS IN VARCHAR2,
    X_EXPIRY_DT IN DATE,
    X_PRO_PRA_SEQUENCE_NUMBER IN NUMBER,
    X_MODE IN VARCHAR2 ,
    X_ORG_ID IN NUMBER
    ) AS
    CURSOR c1 IS
      SELECT ROWID
      FROM   igs_pr_stdnt_pr_ou_all
      WHERE  person_id = x_person_id
      AND    course_cd = x_course_cd
      AND    sequence_number = x_sequence_number;
  BEGIN
    OPEN c1;
    FETCH c1 INTO X_ROWID;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      INSERT_ROW (
       X_ROWID,
       X_PERSON_ID,
       X_COURSE_CD,
       X_SEQUENCE_NUMBER,
       X_PRG_CAL_TYPE,
       X_PRG_CI_SEQUENCE_NUMBER,
       X_RULE_CHECK_DT,
       X_PROGRESSION_RULE_CAT,
       X_PRA_SEQUENCE_NUMBER,
       X_PRO_SEQUENCE_NUMBER,
       X_PROGRESSION_OUTCOME_TYPE,
       X_DURATION,
       X_DURATION_TYPE,
       X_DECISION_STATUS,
       X_DECISION_DT,
       X_DECISION_ORG_UNIT_CD,
       X_DECISION_OU_START_DT,
       X_APPLIED_DT,
       X_SHOW_CAUSE_EXPIRY_DT,
       X_SHOW_CAUSE_DT,
       X_SHOW_CAUSE_OUTCOME_DT,
       X_SHOW_CAUSE_OUTCOME_TYPE,
       X_APPEAL_EXPIRY_DT,
       X_APPEAL_DT,
       X_APPEAL_OUTCOME_DT,
       X_APPEAL_OUTCOME_TYPE,
       X_ENCMB_COURSE_GROUP_CD,
       X_RESTRICTED_ENROLMENT_CP,
       X_RESTRICTED_ATTENDANCE_TYPE,
       X_COMMENTS,
       X_SHOW_CAUSE_COMMENTS,
       X_APPEAL_COMMENTS,
       X_EXPIRY_DT,
       X_PRO_PRA_SEQUENCE_NUMBER,
       X_MODE,
       X_ORG_ID);
      RETURN;
    END IF;
    CLOSE c1;
    UPDATE_ROW (
     X_ROWID ,
     X_PERSON_ID,
     X_COURSE_CD,
     X_SEQUENCE_NUMBER,
     X_PRG_CAL_TYPE,
     X_PRG_CI_SEQUENCE_NUMBER,
     X_RULE_CHECK_DT,
     X_PROGRESSION_RULE_CAT,
     X_PRA_SEQUENCE_NUMBER,
     X_PRO_SEQUENCE_NUMBER,
     X_PROGRESSION_OUTCOME_TYPE,
     X_DURATION,
     X_DURATION_TYPE,
     X_DECISION_STATUS,
     X_DECISION_DT,
     X_DECISION_ORG_UNIT_CD,
     X_DECISION_OU_START_DT,
     X_APPLIED_DT,
     X_SHOW_CAUSE_EXPIRY_DT,
     X_SHOW_CAUSE_DT,
     X_SHOW_CAUSE_OUTCOME_DT,
     X_SHOW_CAUSE_OUTCOME_TYPE,
     X_APPEAL_EXPIRY_DT,
     X_APPEAL_DT,
     X_APPEAL_OUTCOME_DT,
     X_APPEAL_OUTCOME_TYPE,
     X_ENCMB_COURSE_GROUP_CD,
     X_RESTRICTED_ENROLMENT_CP,
     X_RESTRICTED_ATTENDANCE_TYPE,
     X_COMMENTS,
     X_SHOW_CAUSE_COMMENTS,
     X_APPEAL_COMMENTS,
     X_EXPIRY_DT,
     X_PRO_PRA_SEQUENCE_NUMBER,
     X_MODE
     );
  END ADD_ROW;

  PROCEDURE DELETE_ROW (
    X_ROWID IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  BEGIN
  Before_DML (
      p_action => 'DELETE',
      x_rowid => X_ROWID
    ) ;

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_pr_stdnt_pr_ou_all
    WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  END DELETE_ROW;

  PROCEDURE Check_Constraints (
          Column_Name IN VARCHAR2 ,
          Column_Value IN VARCHAR2
          ) AS
      BEGIN
  IF Column_Name IS NULL THEN
    NULL;
  ELSIF UPPER (Column_name) = 'SEQUENCE_NUMBER' THEN
    new_references.SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
  ELSIF UPPER (Column_name) = 'PRG_CI_SEQUENCE_NUMBER' THEN
    new_references.PRG_CI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
  ELSIF UPPER (Column_name) = 'PRA_SEQUENCE_NUMBER' THEN
    new_references.PRA_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
  ELSIF UPPER (Column_name) = 'PRO_SEQUENCE_NUMBER' THEN
    new_references.PRO_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
  ELSIF UPPER (Column_name) = 'DURATION' THEN
    new_references.DURATION:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;
  ELSIF UPPER (Column_name) = 'DURATION_TYPE' THEN
    new_references.DURATION_TYPE:= COLUMN_VALUE ;
  ELSIF UPPER (Column_name) = 'DECISION_STATUS' THEN
    new_references.DECISION_STATUS:= COLUMN_VALUE ;
  ELSIF UPPER (Column_name) = 'SHOW_CAUSE_OUTCOME_TYPE' THEN
    new_references.SHOW_CAUSE_OUTCOME_TYPE:= COLUMN_VALUE ;
  ELSIF UPPER (Column_name) = 'APPEAL_OUTCOME_TYPE' THEN
    new_references.APPEAL_OUTCOME_TYPE:= COLUMN_VALUE ;
  ELSIF UPPER (Column_name) = 'RESTRICTED_ENROLMENT_CP' THEN
    new_references.RESTRICTED_ENROLMENT_CP:= IGS_GE_NUMBER.to_num(COLUMN_VALUE);
  ELSIF UPPER (Column_name) = 'COURSE_CD' THEN
    new_references.COURSE_CD:= COLUMN_VALUE ;
  ELSIF UPPER (Column_name) = 'DECISION_ORG_UNIT_CD' THEN
    new_references.DECISION_ORG_UNIT_CD:= COLUMN_VALUE ;
  ELSIF UPPER (Column_name) = 'ENCMB_COURSE_GROUP_CD' THEN
    new_references.ENCMB_COURSE_GROUP_CD:= COLUMN_VALUE ;
  ELSIF UPPER (Column_name) = 'PRG_CAL_TYPE' THEN
    new_references.PRG_CAL_TYPE:= COLUMN_VALUE ;
  ELSIF UPPER (Column_name) = 'PROGRESSION_OUTCOME_TYPE' THEN
    new_references.PROGRESSION_OUTCOME_TYPE:= COLUMN_VALUE ;
  ELSIF UPPER (Column_name) = 'PROGRESSION_RULE_CAT' THEN
    new_references.PROGRESSION_RULE_CAT:= COLUMN_VALUE ;
  ELSIF UPPER (Column_name) = 'RESTRICTED_ATTENDANCE_TYPE' THEN
    new_references.RESTRICTED_ATTENDANCE_TYPE:= COLUMN_VALUE ;
  END IF;

  IF UPPER (Column_name) = 'SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.sequence_number < 1 OR
       new_references.SEQUENCE_NUMBER > 999999 THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'PRG_CI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.PRG_CI_SEQUENCE_NUMBER < 1 OR
       new_references.PRG_CI_SEQUENCE_NUMBER > 999999 THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'PRA_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.PRA_SEQUENCE_NUMBER < 1 OR
       new_references.PRA_SEQUENCE_NUMBER > 999999 THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'PRO_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
    IF new_references.PRO_SEQUENCE_NUMBER < 1 OR
       new_references.PRO_SEQUENCE_NUMBER > 999999 THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'DURATION' OR COLUMN_NAME IS NULL THEN
    IF new_references.DURATION < 1 OR new_references.DURATION > 999 THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'DURATION_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.DURATION_TYPE<> UPPER (new_references.DURATION_TYPE) THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
    IF new_references.DURATION_TYPE NOT IN  ('NORMAL' , 'EFFECTIVE') THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'DECISION_STATUS' OR COLUMN_NAME IS NULL THEN
    IF new_references.DECISION_STATUS <> UPPER (new_references.DECISION_STATUS)
    THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
    IF new_references.DECISION_STATUS NOT IN ('PENDING', 'APPROVED',
       'WAIVED', 'CANCELLED', 'REMOVED') THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'SHOW_CAUSE_OUTCOME_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.SHOW_CAUSE_OUTCOME_TYPE <>
       UPPER (new_references.SHOW_CAUSE_OUTCOME_TYPE) THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
    IF new_references.SHOW_CAUSE_OUTCOME_TYPE NOT IN ('UPHELD', 'DISMISSED')
    THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'APPEAL_OUTCOME_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.APPEAL_OUTCOME_TYPE <>
       UPPER (new_references.APPEAL_OUTCOME_TYPE) THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
    IF new_references.APPEAL_OUTCOME_TYPE NOT IN  ('UPHELD' , 'DISMISSED') THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'RESTRICTED_ENROLMENT_CP' OR COLUMN_NAME IS NULL THEN
    IF new_references.RESTRICTED_ENROLMENT_CP < 0 OR
       new_references.RESTRICTED_ENROLMENT_CP > 999.999 THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'COURSE_CD' OR COLUMN_NAME IS NULL THEN
    IF new_references.COURSE_CD<> UPPER (new_references.COURSE_CD) THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'ENCMB_COURSE_GROUP_CD' OR COLUMN_NAME IS NULL THEN
    IF new_references.ENCMB_COURSE_GROUP_CD <>
       UPPER (new_references.ENCMB_COURSE_GROUP_CD) THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'PRG_CAL_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.PRG_CAL_TYPE<> UPPER (new_references.PRG_CAL_TYPE) THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'PROGRESSION_OUTCOME_TYPE' OR COLUMN_NAME IS NULL
  THEN
    IF new_references.PROGRESSION_OUTCOME_TYPE <>
       UPPER (new_references.PROGRESSION_OUTCOME_TYPE) THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'PROGRESSION_RULE_CAT' OR COLUMN_NAME IS NULL THEN
    IF new_references.PROGRESSION_RULE_CAT <>
       UPPER (new_references.PROGRESSION_RULE_CAT) THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  IF UPPER (Column_name) = 'RESTRICTED_ATTENDANCE_TYPE' OR
     COLUMN_NAME IS NULL THEN
    IF new_references.RESTRICTED_ATTENDANCE_TYPE <>
       UPPER (new_references.RESTRICTED_ATTENDANCE_TYPE) THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  END IF ;

  END Check_Constraints;

  PROCEDURE apply_appr_outcome AS
  --Created by:
  --Who      When        What
  --prchandr 09-Oct-2002 Added the New procedure to sent the notification
  --                     when the changes are done to the outcomes
  --                     like applying an outcome, approving an outcome,
  --                     cancelling it, waiving the approved outcomes
  --                     and the outcome with showcause and appeal dates
    CURSOR cur_positive IS
      SELECT   positive_outcome_ind, description
      FROM     igs_pr_ou_type pot
      WHERE    pot.progression_outcome_type =
               new_references.progression_outcome_type;
    lcur_positive  cur_positive%ROWTYPE;
  BEGIN
    OPEN cur_positive;
    FETCH cur_positive INTO lcur_positive;
    IF cur_positive%NOTFOUND THEN
      CLOSE cur_positive;
    END IF;

    IF lcur_positive.positive_outcome_ind = 'N' AND
       old_references.decision_status <> 'APPROVED' AND
       new_references.decision_status = 'APPROVED' AND
       new_references.applied_dt IS NULL THEN
      igs_pr_stdnt_pr_ou_be_pkg.approve_otcm (
        new_references.person_id,
        new_references.course_cd,
        new_references.sequence_number,
        new_references.decision_status,
        new_references.decision_dt,
        new_references.progression_outcome_type,
        lcur_positive.description,
        new_references.appeal_expiry_dt,
        new_references.show_cause_expiry_dt
      );
    END IF;

    IF lcur_positive.positive_outcome_ind = 'Y' AND
       old_references.applied_dt IS NULL AND
       new_references.applied_dt IS NOT NULL AND
       new_references.decision_status = 'APPROVED' THEN
      igs_pr_stdnt_pr_ou_be_pkg.apply_positive_otcm (
        new_references.person_id,
        new_references.course_cd,
        new_references.sequence_number,
        new_references.decision_status,
        new_references.decision_dt,
        new_references.progression_outcome_type,
        lcur_positive.description,
        new_references.applied_dt
      );
    END IF;

    IF lcur_positive.positive_outcome_ind = 'N' AND
       old_references.applied_dt IS NULL AND
       new_references.applied_dt IS NOT NULL AND
       new_references.decision_status = 'APPROVED' THEN
      igs_pr_stdnt_pr_ou_be_pkg.apply_otcm (
        new_references.person_id,
        new_references.course_cd,
        new_references.sequence_number,
        new_references.decision_status,
        new_references.decision_dt,
        new_references.progression_outcome_type,
        lcur_positive.description,
        new_references.appeal_expiry_dt,
        new_references.show_cause_expiry_dt,
        new_references.applied_dt
      );
    END IF;

    IF lcur_positive.positive_outcome_ind = 'N' AND
       ((old_references.show_cause_outcome_type IS NULL AND
        new_references.show_cause_outcome_type IS NOT NULL) OR
       (old_references.show_cause_outcome_type IS NOT NULL AND
        new_references.show_cause_outcome_type IS NOT NULL AND
        new_references.show_cause_outcome_type <>
        old_references.show_cause_outcome_type)) THEN
      igs_pr_stdnt_pr_ou_be_pkg.show_cause_uph_dsm (
        new_references.person_id,
        new_references.course_cd,
        new_references.sequence_number,
        new_references.decision_status,
        new_references.decision_dt,
        new_references.progression_outcome_type,
        lcur_positive.description,
        new_references.applied_dt,
        new_references.show_cause_dt,
        new_references.show_cause_outcome_dt,
        new_references.show_cause_outcome_type
      );
    END IF;

    --
    -- kdande; 10-Jan-2003; Bug# 2696065; Changed the following condition to
    -- raise a workflow notification for appeal outcome type changes
    --
    IF lcur_positive.positive_outcome_ind = 'N' AND
       ((old_references.appeal_outcome_type IS NULL AND
        new_references.appeal_outcome_type IS NOT NULL) OR
       (old_references.appeal_outcome_type IS NOT NULL AND
        new_references.appeal_outcome_type IS NOT NULL AND
        new_references.appeal_outcome_type <>
        old_references.appeal_outcome_type)) THEN
      igs_pr_stdnt_pr_ou_be_pkg.appeal_uph_dsm (
        new_references.person_id,
        new_references.course_cd,
        new_references.sequence_number,
        new_references.decision_status,
        new_references.decision_dt,
        new_references.progression_outcome_type,
        lcur_positive.description,
        new_references.applied_dt,
        new_references.appeal_dt,
        new_references.appeal_outcome_dt,
        new_references.appeal_outcome_type
      );
    END IF;

    IF lcur_positive.positive_outcome_ind = 'N' AND
       old_references.decision_status = 'APPROVED' AND
       new_references.decision_status IN ('REMOVED', 'WAIVED', 'CANCELLED') THEN
      igs_pr_stdnt_pr_ou_be_pkg.remove_waive_cancel_otcm (
        new_references.person_id,
        new_references.course_cd,
        new_references.sequence_number,
        new_references.decision_status,
        new_references.decision_dt,
        new_references.progression_outcome_type,
        lcur_positive.description,
        new_references.applied_dt
      );
 END IF;

 END apply_appr_outcome;

END igs_pr_stdnt_pr_ou_pkg;

/
