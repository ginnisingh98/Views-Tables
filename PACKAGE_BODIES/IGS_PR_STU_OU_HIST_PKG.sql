--------------------------------------------------------
--  DDL for Package Body IGS_PR_STU_OU_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_STU_OU_HIST_PKG" AS
/* $Header: IGSQI28B.pls 115.10 2002/12/23 07:34:00 ddey ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_pr_stu_ou_hist_all%RowType;
  new_references igs_pr_stu_ou_hist_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_appeal_comments IN VARCHAR2 DEFAULT NULL,
    x_appeal_dt IN DATE DEFAULT NULL,
    x_appeal_expiry_dt IN DATE DEFAULT NULL,
    x_appeal_outcome_dt IN DATE DEFAULT NULL,
    x_appeal_outcome_type IN VARCHAR2 DEFAULT NULL,
    x_applied_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_decision_dt IN DATE DEFAULT NULL,
    x_decision_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_decision_ou_start_dt IN DATE DEFAULT NULL,
    x_decision_status IN VARCHAR2 DEFAULT NULL,
    x_duration IN NUMBER DEFAULT NULL,
    x_duration_type IN VARCHAR2 DEFAULT NULL,
    x_encmb_course_group_cd IN VARCHAR2 DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_prg_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_progression_outcome_type IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_pro_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_pro_sequence_number IN NUMBER DEFAULT NULL,
    x_restricted_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_restricted_enrolment_cp IN NUMBER DEFAULT NULL,
    x_rule_check_dt IN DATE DEFAULT NULL,
    x_show_cause_comments IN VARCHAR2 DEFAULT NULL,
    x_show_cause_dt IN DATE DEFAULT NULL,
    x_show_cause_expiry_dt IN DATE DEFAULT NULL,
    x_show_cause_outcome_dt IN DATE DEFAULT NULL,
    x_show_cause_outcome_type IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_STU_OU_HIST_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.sequence_number := x_sequence_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.appeal_comments := x_appeal_comments;
    new_references.appeal_dt := x_appeal_dt;
    new_references.appeal_expiry_dt := x_appeal_expiry_dt;
    new_references.appeal_outcome_dt := x_appeal_outcome_dt;
    new_references.appeal_outcome_type := x_appeal_outcome_type;
    new_references.applied_dt := x_applied_dt;
    new_references.comments := x_comments;
    new_references.decision_dt := x_decision_dt;
    new_references.decision_org_unit_cd := x_decision_org_unit_cd;
    new_references.decision_ou_start_dt := x_decision_ou_start_dt;
    new_references.decision_status := x_decision_status;
    new_references.duration := x_duration;
    new_references.duration_type := x_duration_type;
    new_references.encmb_course_group_cd := x_encmb_course_group_cd;
    new_references.expiry_dt := x_expiry_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.pra_sequence_number := x_pra_sequence_number;
    new_references.prg_cal_type := x_prg_cal_type;
    new_references.prg_ci_sequence_number := x_prg_ci_sequence_number;
    new_references.progression_outcome_type := x_progression_outcome_type;
    new_references.progression_rule_cat := x_progression_rule_cat;
    new_references.pro_pra_sequence_number := x_pro_pra_sequence_number;
    new_references.pro_sequence_number := x_pro_sequence_number;
    new_references.restricted_attendance_type := x_restricted_attendance_type;
    new_references.restricted_enrolment_cp := x_restricted_enrolment_cp;
    new_references.rule_check_dt := x_rule_check_dt;
    new_references.show_cause_comments := x_show_cause_comments;
    new_references.show_cause_dt := x_show_cause_dt;
    new_references.show_cause_expiry_dt := x_show_cause_expiry_dt;
    new_references.show_cause_outcome_dt := x_show_cause_outcome_dt;
    new_references.show_cause_outcome_type := x_show_cause_outcome_type;
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

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'COURSE_CD'  THEN
        new_references.course_cd := column_value;
      ELSIF  UPPER(column_name) = 'APPEAL_OUTCOME_TYPE'  THEN
        new_references.appeal_outcome_type := column_value;
      ELSIF  UPPER(column_name) = 'DECISION_ORG_UNIT_CD'  THEN
        new_references.decision_org_unit_cd := column_value;
      ELSIF  UPPER(column_name) = 'DECISION_STATUS'  THEN
        new_references.decision_status := column_value;
      ELSIF  UPPER(column_name) = 'DURATION_TYPE'  THEN
        new_references.duration_type := column_value;
      ELSIF  UPPER(column_name) = 'ENCMB_COURSE_GROUP_CD'  THEN
        new_references.encmb_course_group_cd := column_value;
      ELSIF  UPPER(column_name) = 'HIST_WHO'  THEN
        new_references.hist_who := column_value;
      ELSIF  UPPER(column_name) = 'PRG_CAL_TYPE'  THEN
        new_references.prg_cal_type := column_value;
      ELSIF  UPPER(column_name) = 'PROGRESSION_OUTCOME_TYPE'  THEN
        new_references.progression_outcome_type := column_value;
      ELSIF  UPPER(column_name) = 'PROGRESSION_RULE_CAT'  THEN
        new_references.progression_rule_cat := column_value;
      ELSIF  UPPER(column_name) = 'RESTRICTED_ATTENDANCE_TYPE'  THEN
        new_references.restricted_attendance_type := column_value;
        NULL;
      END IF;



      IF  UPPER(Column_Name) = 'COURSE_CD' OR
      		Column_Name IS NULL THEN
        IF new_references.COURSE_CD <> UPPER(new_references.course_cd) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF  UPPER(Column_Name) = 'APPEAL_OUTCOME_TYPE' OR
      		Column_Name IS NULL THEN
        IF new_references.APPEAL_OUTCOME_TYPE <> UPPER(new_references.appeal_outcome_type) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;


      IF  UPPER(Column_Name) = 'DECISION_STATUS' OR
      		Column_Name IS NULL THEN
        IF new_references.DECISION_STATUS <> UPPER(new_references.decision_status) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF  UPPER(Column_Name) = 'DURATION_TYPE' OR
      		Column_Name IS NULL THEN
        IF new_references.DURATION_TYPE <> UPPER(new_references.duration_type) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF  UPPER(Column_Name) = 'ENCMB_COURSE_GROUP_CD' OR
      		Column_Name IS NULL THEN
        IF new_references.ENCMB_COURSE_GROUP_CD <> UPPER(new_references.encmb_course_group_cd) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF  UPPER(Column_Name) = 'HIST_WHO' OR
      		Column_Name IS NULL THEN
        IF new_references.HIST_WHO <> UPPER(new_references.hist_who) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF  UPPER(Column_Name) = 'PRG_CAL_TYPE' OR
      		Column_Name IS NULL THEN
        IF new_references.PRG_CAL_TYPE <> UPPER(new_references.prg_cal_type) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF  UPPER(Column_Name) = 'PROGRESSION_OUTCOME_TYPE' OR
      		Column_Name IS NULL THEN
        IF new_references.PROGRESSION_OUTCOME_TYPE <> UPPER(new_references.progression_outcome_type) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF  UPPER(Column_Name) = 'PROGRESSION_RULE_CAT' OR
      		Column_Name IS NULL THEN
        IF new_references.PROGRESSION_RULE_CAT <> UPPER(new_references.progression_rule_cat) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF  UPPER(Column_Name) = 'RESTRICTED_ATTENDANCE_TYPE' OR
      		Column_Name IS NULL THEN
        IF new_references.RESTRICTED_ATTENDANCE_TYPE <> UPPER(new_references.restricted_attendance_type) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.sequence_number = new_references.sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL) OR
         (new_references.sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pr_Stdnt_Pr_Ou_Pkg.Get_PK_For_Validation (
        		new_references.person_id,
         		 new_references.course_cd,
         		 new_references.sequence_number
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_stu_ou_hist_all
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      sequence_number = x_sequence_number
      AND      hist_start_dt = x_hist_start_dt
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;
  END Get_PK_For_Validation;

  PROCEDURE Get_FK_Igs_Pr_Stdnt_Pr_Ou (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_stu_ou_hist_all
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pr_Stdnt_Pr_Ou;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_appeal_comments IN VARCHAR2 DEFAULT NULL,
    x_appeal_dt IN DATE DEFAULT NULL,
    x_appeal_expiry_dt IN DATE DEFAULT NULL,
    x_appeal_outcome_dt IN DATE DEFAULT NULL,
    x_appeal_outcome_type IN VARCHAR2 DEFAULT NULL,
    x_applied_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_decision_dt IN DATE DEFAULT NULL,
    x_decision_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_decision_ou_start_dt IN DATE DEFAULT NULL,
    x_decision_status IN VARCHAR2 DEFAULT NULL,
    x_duration IN NUMBER DEFAULT NULL,
    x_duration_type IN VARCHAR2 DEFAULT NULL,
    x_encmb_course_group_cd IN VARCHAR2 DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_prg_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_progression_outcome_type IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_pro_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_pro_sequence_number IN NUMBER DEFAULT NULL,
    x_restricted_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_restricted_enrolment_cp IN NUMBER DEFAULT NULL,
    x_rule_check_dt IN DATE DEFAULT NULL,
    x_show_cause_comments IN VARCHAR2 DEFAULT NULL,
    x_show_cause_dt IN DATE DEFAULT NULL,
    x_show_cause_expiry_dt IN DATE DEFAULT NULL,
    x_show_cause_outcome_dt IN DATE DEFAULT NULL,
    x_show_cause_outcome_type IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_sequence_number,
      x_hist_start_dt,
      x_appeal_comments,
      x_appeal_dt,
      x_appeal_expiry_dt,
      x_appeal_outcome_dt,
      x_appeal_outcome_type,
      x_applied_dt,
      x_comments,
      x_decision_dt,
      x_decision_org_unit_cd,
      x_decision_ou_start_dt,
      x_decision_status,
      x_duration,
      x_duration_type,
      x_encmb_course_group_cd,
      x_expiry_dt,
      x_hist_end_dt,
      x_hist_who,
      x_pra_sequence_number,
      x_prg_cal_type,
      x_prg_ci_sequence_number,
      x_progression_outcome_type,
      x_progression_rule_cat,
      x_pro_pra_sequence_number,
      x_pro_sequence_number,
      x_restricted_attendance_type,
      x_restricted_enrolment_cp,
      x_rule_check_dt,
      x_show_cause_comments,
      x_show_cause_dt,
      x_show_cause_expiry_dt,
      x_show_cause_outcome_dt,
      x_show_cause_outcome_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.person_id,
    		new_references.course_cd,
    		new_references.sequence_number,
    		new_references.hist_start_dt)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.person_id,
    		new_references.course_cd,
    		new_references.sequence_number,
    		new_references.hist_start_dt)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_HIST_START_DT IN DATE,
       x_APPEAL_COMMENTS IN VARCHAR2,
       x_APPEAL_DT IN DATE,
       x_APPEAL_EXPIRY_DT IN DATE,
       x_APPEAL_OUTCOME_DT IN DATE,
       x_APPEAL_OUTCOME_TYPE IN VARCHAR2,
       x_APPLIED_DT IN DATE,
       x_COMMENTS IN VARCHAR2,
       x_DECISION_DT IN DATE,
       x_DECISION_ORG_UNIT_CD IN VARCHAR2,
       x_DECISION_OU_START_DT IN DATE,
       x_DECISION_STATUS IN VARCHAR2,
       x_DURATION IN NUMBER,
       x_DURATION_TYPE IN VARCHAR2,
       x_ENCMB_COURSE_GROUP_CD IN VARCHAR2,
       x_EXPIRY_DT IN DATE,
       x_HIST_END_DT IN DATE,
       x_HIST_WHO IN VARCHAR2,
       x_PRA_SEQUENCE_NUMBER IN NUMBER,
       x_PRG_CAL_TYPE IN VARCHAR2,
       x_PRG_CI_SEQUENCE_NUMBER IN NUMBER,
       x_PROGRESSION_OUTCOME_TYPE IN VARCHAR2,
       x_PROGRESSION_RULE_CAT IN VARCHAR2,
       x_PRO_PRA_SEQUENCE_NUMBER IN NUMBER,
       x_PRO_SEQUENCE_NUMBER IN NUMBER,
       x_RESTRICTED_ATTENDANCE_TYPE IN VARCHAR2,
       x_RESTRICTED_ENROLMENT_CP IN NUMBER,
       x_RULE_CHECK_DT IN DATE,
       x_SHOW_CAUSE_COMMENTS IN VARCHAR2,
       x_SHOW_CAUSE_DT IN DATE,
       x_SHOW_CAUSE_EXPIRY_DT IN DATE,
       x_SHOW_CAUSE_OUTCOME_DT IN DATE,
       x_SHOW_CAUSE_OUTCOME_TYPE IN DATE,
      X_MODE in VARCHAR2 default 'R',
       X_ORG_ID IN NUMBER
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PR_STU_OU_HIST_ALL
             where                 PERSON_ID= X_PERSON_ID
            and COURSE_CD = X_COURSE_CD
            and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
            and HIST_START_DT = X_HIST_START_DT
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (X_MODE = 'R') then
               X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
            if X_LAST_UPDATED_BY is NULL then
                X_LAST_UPDATED_BY := -1;
            end if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
         if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
          end if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_person_id=>X_PERSON_ID,
 	       x_course_cd=>X_COURSE_CD,
 	       x_sequence_number=>X_SEQUENCE_NUMBER,
 	       x_hist_start_dt=>X_HIST_START_DT,
 	       x_appeal_comments=>X_APPEAL_COMMENTS,
 	       x_appeal_dt=>X_APPEAL_DT,
 	       x_appeal_expiry_dt=>X_APPEAL_EXPIRY_DT,
 	       x_appeal_outcome_dt=>X_APPEAL_OUTCOME_DT,
 	       x_appeal_outcome_type=>X_APPEAL_OUTCOME_TYPE,
 	       x_applied_dt=>X_APPLIED_DT,
 	       x_comments=>X_COMMENTS,
 	       x_decision_dt=>X_DECISION_DT,
 	       x_decision_org_unit_cd=>X_DECISION_ORG_UNIT_CD,
 	       x_decision_ou_start_dt=>X_DECISION_OU_START_DT,
 	       x_decision_status=>X_DECISION_STATUS,
 	       x_duration=>X_DURATION,
 	       x_duration_type=>X_DURATION_TYPE,
 	       x_encmb_course_group_cd=>X_ENCMB_COURSE_GROUP_CD,
 	       x_expiry_dt=>X_EXPIRY_DT,
 	       x_hist_end_dt=>X_HIST_END_DT,
 	       x_hist_who=>X_HIST_WHO,
 	       x_pra_sequence_number=>X_PRA_SEQUENCE_NUMBER,
 	       x_prg_cal_type=>X_PRG_CAL_TYPE,
 	       x_prg_ci_sequence_number=>X_PRG_CI_SEQUENCE_NUMBER,
 	       x_progression_outcome_type=>X_PROGRESSION_OUTCOME_TYPE,
 	       x_progression_rule_cat=>X_PROGRESSION_RULE_CAT,
 	       x_pro_pra_sequence_number=>X_PRO_PRA_SEQUENCE_NUMBER,
 	       x_pro_sequence_number=>X_PRO_SEQUENCE_NUMBER,
 	       x_restricted_attendance_type=>X_RESTRICTED_ATTENDANCE_TYPE,
 	       x_restricted_enrolment_cp=>X_RESTRICTED_ENROLMENT_CP,
 	       x_rule_check_dt=>X_RULE_CHECK_DT,
 	       x_show_cause_comments=>X_SHOW_CAUSE_COMMENTS,
 	       x_show_cause_dt=>X_SHOW_CAUSE_DT,
 	       x_show_cause_expiry_dt=>X_SHOW_CAUSE_EXPIRY_DT,
 	       x_show_cause_outcome_dt=>X_SHOW_CAUSE_OUTCOME_DT,
 	       x_show_cause_outcome_type=>X_SHOW_CAUSE_OUTCOME_TYPE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_org_id=>igs_ge_gen_003.get_org_id);
     insert into IGS_PR_STU_OU_HIST_ALL (
		PERSON_ID
		,COURSE_CD
		,SEQUENCE_NUMBER
		,HIST_START_DT
		,APPEAL_COMMENTS
		,APPEAL_DT
		,APPEAL_EXPIRY_DT
		,APPEAL_OUTCOME_DT
		,APPEAL_OUTCOME_TYPE
		,APPLIED_DT
		,COMMENTS
		,DECISION_DT
		,DECISION_ORG_UNIT_CD
		,DECISION_OU_START_DT
		,DECISION_STATUS
		,DURATION
		,DURATION_TYPE
		,ENCMB_COURSE_GROUP_CD
		,EXPIRY_DT
		,HIST_END_DT
		,HIST_WHO
		,PRA_SEQUENCE_NUMBER
		,PRG_CAL_TYPE
		,PRG_CI_SEQUENCE_NUMBER
		,PROGRESSION_OUTCOME_TYPE
		,PROGRESSION_RULE_CAT
		,PRO_PRA_SEQUENCE_NUMBER
		,PRO_SEQUENCE_NUMBER
		,RESTRICTED_ATTENDANCE_TYPE
		,RESTRICTED_ENROLMENT_CP
		,RULE_CHECK_DT
		,SHOW_CAUSE_COMMENTS
		,SHOW_CAUSE_DT
		,SHOW_CAUSE_EXPIRY_DT
		,SHOW_CAUSE_OUTCOME_DT
		,SHOW_CAUSE_OUTCOME_TYPE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,ORG_ID
        ) values  (
	        NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.COURSE_CD
	        ,NEW_REFERENCES.SEQUENCE_NUMBER
	        ,NEW_REFERENCES.HIST_START_DT
	        ,NEW_REFERENCES.APPEAL_COMMENTS
	        ,NEW_REFERENCES.APPEAL_DT
	        ,NEW_REFERENCES.APPEAL_EXPIRY_DT
	        ,NEW_REFERENCES.APPEAL_OUTCOME_DT
	        ,NEW_REFERENCES.APPEAL_OUTCOME_TYPE
	        ,NEW_REFERENCES.APPLIED_DT
	        ,NEW_REFERENCES.COMMENTS
	        ,NEW_REFERENCES.DECISION_DT
	        ,NEW_REFERENCES.DECISION_ORG_UNIT_CD
	        ,NEW_REFERENCES.DECISION_OU_START_DT
	        ,NEW_REFERENCES.DECISION_STATUS
	        ,NEW_REFERENCES.DURATION
	        ,NEW_REFERENCES.DURATION_TYPE
	        ,NEW_REFERENCES.ENCMB_COURSE_GROUP_CD
	        ,NEW_REFERENCES.EXPIRY_DT
	        ,NEW_REFERENCES.HIST_END_DT
	        ,NEW_REFERENCES.HIST_WHO
	        ,NEW_REFERENCES.PRA_SEQUENCE_NUMBER
	        ,NEW_REFERENCES.PRG_CAL_TYPE
	        ,NEW_REFERENCES.PRG_CI_SEQUENCE_NUMBER
	        ,NEW_REFERENCES.PROGRESSION_OUTCOME_TYPE
	        ,NEW_REFERENCES.PROGRESSION_RULE_CAT
	        ,NEW_REFERENCES.PRO_PRA_SEQUENCE_NUMBER
	        ,NEW_REFERENCES.PRO_SEQUENCE_NUMBER
	        ,NEW_REFERENCES.RESTRICTED_ATTENDANCE_TYPE
	        ,NEW_REFERENCES.RESTRICTED_ENROLMENT_CP
	        ,NEW_REFERENCES.RULE_CHECK_DT
	        ,NEW_REFERENCES.SHOW_CAUSE_COMMENTS
	        ,NEW_REFERENCES.SHOW_CAUSE_DT
	        ,NEW_REFERENCES.SHOW_CAUSE_EXPIRY_DT
	        ,NEW_REFERENCES.SHOW_CAUSE_OUTCOME_DT
	        ,NEW_REFERENCES.SHOW_CAUSE_OUTCOME_TYPE
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,NEW_REFERENCES.ORG_ID
);
		open c;
		 fetch c into X_ROWID;
 		if (c%notfound) then
		close c;
 	     raise no_data_found;
		end if;
 		close c;
    After_DML (
		p_action => 'INSERT' ,
		x_rowid => X_ROWID );
end INSERT_ROW;
 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_HIST_START_DT IN DATE,
       x_APPEAL_COMMENTS IN VARCHAR2,
       x_APPEAL_DT IN DATE,
       x_APPEAL_EXPIRY_DT IN DATE,
       x_APPEAL_OUTCOME_DT IN DATE,
       x_APPEAL_OUTCOME_TYPE IN VARCHAR2,
       x_APPLIED_DT IN DATE,
       x_COMMENTS IN VARCHAR2,
       x_DECISION_DT IN DATE,
       x_DECISION_ORG_UNIT_CD IN VARCHAR2,
       x_DECISION_OU_START_DT IN DATE,
       x_DECISION_STATUS IN VARCHAR2,
       x_DURATION IN NUMBER,
       x_DURATION_TYPE IN VARCHAR2,
       x_ENCMB_COURSE_GROUP_CD IN VARCHAR2,
       x_EXPIRY_DT IN DATE,
       x_HIST_END_DT IN DATE,
       x_HIST_WHO IN VARCHAR2,
       x_PRA_SEQUENCE_NUMBER IN NUMBER,
       x_PRG_CAL_TYPE IN VARCHAR2,
       x_PRG_CI_SEQUENCE_NUMBER IN NUMBER,
       x_PROGRESSION_OUTCOME_TYPE IN VARCHAR2,
       x_PROGRESSION_RULE_CAT IN VARCHAR2,
       x_PRO_PRA_SEQUENCE_NUMBER IN NUMBER,
       x_PRO_SEQUENCE_NUMBER IN NUMBER,
       x_RESTRICTED_ATTENDANCE_TYPE IN VARCHAR2,
       x_RESTRICTED_ENROLMENT_CP IN NUMBER,
       x_RULE_CHECK_DT IN DATE,
       x_SHOW_CAUSE_COMMENTS IN VARCHAR2,
       x_SHOW_CAUSE_DT IN DATE,
       x_SHOW_CAUSE_EXPIRY_DT IN DATE,
       x_SHOW_CAUSE_OUTCOME_DT IN DATE,
       x_SHOW_CAUSE_OUTCOME_TYPE IN DATE
       ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      APPEAL_COMMENTS
,      APPEAL_DT
,      APPEAL_EXPIRY_DT
,      APPEAL_OUTCOME_DT
,      APPEAL_OUTCOME_TYPE
,      APPLIED_DT
,      COMMENTS
,      DECISION_DT
,      DECISION_ORG_UNIT_CD
,      DECISION_OU_START_DT
,      DECISION_STATUS
,      DURATION
,      DURATION_TYPE
,      ENCMB_COURSE_GROUP_CD
,      EXPIRY_DT
,      HIST_END_DT
,      HIST_WHO
,      PRA_SEQUENCE_NUMBER
,      PRG_CAL_TYPE
,      PRG_CI_SEQUENCE_NUMBER
,      PROGRESSION_OUTCOME_TYPE
,      PROGRESSION_RULE_CAT
,      PRO_PRA_SEQUENCE_NUMBER
,      PRO_SEQUENCE_NUMBER
,      RESTRICTED_ATTENDANCE_TYPE
,      RESTRICTED_ENROLMENT_CP
,      RULE_CHECK_DT
,      SHOW_CAUSE_COMMENTS
,      SHOW_CAUSE_DT
,      SHOW_CAUSE_EXPIRY_DT
,      SHOW_CAUSE_OUTCOME_DT
,      SHOW_CAUSE_OUTCOME_TYPE
    from IGS_PR_STU_OU_HIST_ALL
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
if ( (  (tlinfo.APPEAL_COMMENTS = X_APPEAL_COMMENTS)
 	    OR ((tlinfo.APPEAL_COMMENTS is null)
		AND (X_APPEAL_COMMENTS is null)))
  AND ((tlinfo.APPEAL_DT = X_APPEAL_DT)
 	    OR ((tlinfo.APPEAL_DT is null)
		AND (X_APPEAL_DT is null)))
  AND ((tlinfo.APPEAL_EXPIRY_DT = X_APPEAL_EXPIRY_DT)
 	    OR ((tlinfo.APPEAL_EXPIRY_DT is null)
		AND (X_APPEAL_EXPIRY_DT is null)))
  AND ((tlinfo.APPEAL_OUTCOME_DT = X_APPEAL_OUTCOME_DT)
 	    OR ((tlinfo.APPEAL_OUTCOME_DT is null)
		AND (X_APPEAL_OUTCOME_DT is null)))
  AND ((tlinfo.APPEAL_OUTCOME_TYPE = X_APPEAL_OUTCOME_TYPE)
 	    OR ((tlinfo.APPEAL_OUTCOME_TYPE is null)
		AND (X_APPEAL_OUTCOME_TYPE is null)))
  AND ((tlinfo.APPLIED_DT = X_APPLIED_DT)
 	    OR ((tlinfo.APPLIED_DT is null)
		AND (X_APPLIED_DT is null)))
  AND ((tlinfo.COMMENTS = X_COMMENTS)
 	    OR ((tlinfo.COMMENTS is null)
		AND (X_COMMENTS is null)))
  AND ((tlinfo.DECISION_DT = X_DECISION_DT)
 	    OR ((tlinfo.DECISION_DT is null)
		AND (X_DECISION_DT is null)))
  AND ((tlinfo.DECISION_ORG_UNIT_CD = X_DECISION_ORG_UNIT_CD)
 	    OR ((tlinfo.DECISION_ORG_UNIT_CD is null)
		AND (X_DECISION_ORG_UNIT_CD is null)))
  AND ((tlinfo.DECISION_OU_START_DT = X_DECISION_OU_START_DT)
 	    OR ((tlinfo.DECISION_OU_START_DT is null)
		AND (X_DECISION_OU_START_DT is null)))
  AND ((tlinfo.DECISION_STATUS = X_DECISION_STATUS)
 	    OR ((tlinfo.DECISION_STATUS is null)
		AND (X_DECISION_STATUS is null)))
  AND ((tlinfo.DURATION = X_DURATION)
 	    OR ((tlinfo.DURATION is null)
		AND (X_DURATION is null)))
  AND ((tlinfo.DURATION_TYPE = X_DURATION_TYPE)
 	    OR ((tlinfo.DURATION_TYPE is null)
		AND (X_DURATION_TYPE is null)))
  AND ((tlinfo.ENCMB_COURSE_GROUP_CD = X_ENCMB_COURSE_GROUP_CD)
 	    OR ((tlinfo.ENCMB_COURSE_GROUP_CD is null)
		AND (X_ENCMB_COURSE_GROUP_CD is null)))
  AND ((tlinfo.EXPIRY_DT = X_EXPIRY_DT)
 	    OR ((tlinfo.EXPIRY_DT is null)
		AND (X_EXPIRY_DT is null)))
  AND (tlinfo.HIST_END_DT = X_HIST_END_DT)
  AND (tlinfo.HIST_WHO = X_HIST_WHO)
  AND ((tlinfo.PRA_SEQUENCE_NUMBER = X_PRA_SEQUENCE_NUMBER)
 	    OR ((tlinfo.PRA_SEQUENCE_NUMBER is null)
		AND (X_PRA_SEQUENCE_NUMBER is null)))
  AND ((tlinfo.PRG_CAL_TYPE = X_PRG_CAL_TYPE)
 	    OR ((tlinfo.PRG_CAL_TYPE is null)
		AND (X_PRG_CAL_TYPE is null)))
  AND ((tlinfo.PRG_CI_SEQUENCE_NUMBER = X_PRG_CI_SEQUENCE_NUMBER)
 	    OR ((tlinfo.PRG_CI_SEQUENCE_NUMBER is null)
		AND (X_PRG_CI_SEQUENCE_NUMBER is null)))
  AND ((tlinfo.PROGRESSION_OUTCOME_TYPE = X_PROGRESSION_OUTCOME_TYPE)
 	    OR ((tlinfo.PROGRESSION_OUTCOME_TYPE is null)
		AND (X_PROGRESSION_OUTCOME_TYPE is null)))
  AND ((tlinfo.PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT)
 	    OR ((tlinfo.PROGRESSION_RULE_CAT is null)
		AND (X_PROGRESSION_RULE_CAT is null)))
  AND ((tlinfo.PRO_PRA_SEQUENCE_NUMBER = X_PRO_PRA_SEQUENCE_NUMBER)
 	    OR ((tlinfo.PRO_PRA_SEQUENCE_NUMBER is null)
		AND (X_PRO_PRA_SEQUENCE_NUMBER is null)))
  AND ((tlinfo.PRO_SEQUENCE_NUMBER = X_PRO_SEQUENCE_NUMBER)
 	    OR ((tlinfo.PRO_SEQUENCE_NUMBER is null)
		AND (X_PRO_SEQUENCE_NUMBER is null)))
  AND ((tlinfo.RESTRICTED_ATTENDANCE_TYPE = X_RESTRICTED_ATTENDANCE_TYPE)
 	    OR ((tlinfo.RESTRICTED_ATTENDANCE_TYPE is null)
		AND (X_RESTRICTED_ATTENDANCE_TYPE is null)))
  AND ((tlinfo.RESTRICTED_ENROLMENT_CP = X_RESTRICTED_ENROLMENT_CP)
 	    OR ((tlinfo.RESTRICTED_ENROLMENT_CP is null)
		AND (X_RESTRICTED_ENROLMENT_CP is null)))
  AND ((tlinfo.RULE_CHECK_DT = X_RULE_CHECK_DT)
 	    OR ((tlinfo.RULE_CHECK_DT is null)
		AND (X_RULE_CHECK_DT is null)))
  AND ((tlinfo.SHOW_CAUSE_COMMENTS = X_SHOW_CAUSE_COMMENTS)
 	    OR ((tlinfo.SHOW_CAUSE_COMMENTS is null)
		AND (X_SHOW_CAUSE_COMMENTS is null)))
  AND ((tlinfo.SHOW_CAUSE_DT = X_SHOW_CAUSE_DT)
 	    OR ((tlinfo.SHOW_CAUSE_DT is null)
		AND (X_SHOW_CAUSE_DT is null)))
  AND ((tlinfo.SHOW_CAUSE_EXPIRY_DT = X_SHOW_CAUSE_EXPIRY_DT)
 	    OR ((tlinfo.SHOW_CAUSE_EXPIRY_DT is null)
		AND (X_SHOW_CAUSE_EXPIRY_DT is null)))
  AND ((tlinfo.SHOW_CAUSE_OUTCOME_DT = X_SHOW_CAUSE_OUTCOME_DT)
 	    OR ((tlinfo.SHOW_CAUSE_OUTCOME_DT is null)
		AND (X_SHOW_CAUSE_OUTCOME_DT is null)))
  AND ((tlinfo.SHOW_CAUSE_OUTCOME_TYPE = X_SHOW_CAUSE_OUTCOME_TYPE)
 	    OR ((tlinfo.SHOW_CAUSE_OUTCOME_TYPE is null)
		AND (X_SHOW_CAUSE_OUTCOME_TYPE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_HIST_START_DT IN DATE,
       x_APPEAL_COMMENTS IN VARCHAR2,
       x_APPEAL_DT IN DATE,
       x_APPEAL_EXPIRY_DT IN DATE,
       x_APPEAL_OUTCOME_DT IN DATE,
       x_APPEAL_OUTCOME_TYPE IN VARCHAR2,
       x_APPLIED_DT IN DATE,
       x_COMMENTS IN VARCHAR2,
       x_DECISION_DT IN DATE,
       x_DECISION_ORG_UNIT_CD IN VARCHAR2,
       x_DECISION_OU_START_DT IN DATE,
       x_DECISION_STATUS IN VARCHAR2,
       x_DURATION IN NUMBER,
       x_DURATION_TYPE IN VARCHAR2,
       x_ENCMB_COURSE_GROUP_CD IN VARCHAR2,
       x_EXPIRY_DT IN DATE,
       x_HIST_END_DT IN DATE,
       x_HIST_WHO IN VARCHAR2,
       x_PRA_SEQUENCE_NUMBER IN NUMBER,
       x_PRG_CAL_TYPE IN VARCHAR2,
       x_PRG_CI_SEQUENCE_NUMBER IN NUMBER,
       x_PROGRESSION_OUTCOME_TYPE IN VARCHAR2,
       x_PROGRESSION_RULE_CAT IN VARCHAR2,
       x_PRO_PRA_SEQUENCE_NUMBER IN NUMBER,
       x_PRO_SEQUENCE_NUMBER IN NUMBER,
       x_RESTRICTED_ATTENDANCE_TYPE IN VARCHAR2,
       x_RESTRICTED_ENROLMENT_CP IN NUMBER,
       x_RULE_CHECK_DT IN DATE,
       x_SHOW_CAUSE_COMMENTS IN VARCHAR2,
       x_SHOW_CAUSE_DT IN DATE,
       x_SHOW_CAUSE_EXPIRY_DT IN DATE,
       x_SHOW_CAUSE_OUTCOME_DT IN DATE,
       x_SHOW_CAUSE_OUTCOME_TYPE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (X_MODE = 'R') then
               X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
            if X_LAST_UPDATED_BY is NULL then
                X_LAST_UPDATED_BY := -1;
            end if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
         if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
          end if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;
   Before_DML(
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_person_id=>X_PERSON_ID,
 	       x_course_cd=>X_COURSE_CD,
 	       x_sequence_number=>X_SEQUENCE_NUMBER,
 	       x_hist_start_dt=>X_HIST_START_DT,
 	       x_appeal_comments=>X_APPEAL_COMMENTS,
 	       x_appeal_dt=>X_APPEAL_DT,
 	       x_appeal_expiry_dt=>X_APPEAL_EXPIRY_DT,
 	       x_appeal_outcome_dt=>X_APPEAL_OUTCOME_DT,
 	       x_appeal_outcome_type=>X_APPEAL_OUTCOME_TYPE,
 	       x_applied_dt=>X_APPLIED_DT,
 	       x_comments=>X_COMMENTS,
 	       x_decision_dt=>X_DECISION_DT,
 	       x_decision_org_unit_cd=>X_DECISION_ORG_UNIT_CD,
 	       x_decision_ou_start_dt=>X_DECISION_OU_START_DT,
 	       x_decision_status=>X_DECISION_STATUS,
 	       x_duration=>X_DURATION,
 	       x_duration_type=>X_DURATION_TYPE,
 	       x_encmb_course_group_cd=>X_ENCMB_COURSE_GROUP_CD,
 	       x_expiry_dt=>X_EXPIRY_DT,
 	       x_hist_end_dt=>X_HIST_END_DT,
 	       x_hist_who=>X_HIST_WHO,
 	       x_pra_sequence_number=>X_PRA_SEQUENCE_NUMBER,
 	       x_prg_cal_type=>X_PRG_CAL_TYPE,
 	       x_prg_ci_sequence_number=>X_PRG_CI_SEQUENCE_NUMBER,
 	       x_progression_outcome_type=>X_PROGRESSION_OUTCOME_TYPE,
 	       x_progression_rule_cat=>X_PROGRESSION_RULE_CAT,
 	       x_pro_pra_sequence_number=>X_PRO_PRA_SEQUENCE_NUMBER,
 	       x_pro_sequence_number=>X_PRO_SEQUENCE_NUMBER,
 	       x_restricted_attendance_type=>X_RESTRICTED_ATTENDANCE_TYPE,
 	       x_restricted_enrolment_cp=>X_RESTRICTED_ENROLMENT_CP,
 	       x_rule_check_dt=>X_RULE_CHECK_DT,
 	       x_show_cause_comments=>X_SHOW_CAUSE_COMMENTS,
 	       x_show_cause_dt=>X_SHOW_CAUSE_DT,
 	       x_show_cause_expiry_dt=>X_SHOW_CAUSE_EXPIRY_DT,
 	       x_show_cause_outcome_dt=>X_SHOW_CAUSE_OUTCOME_DT,
 	       x_show_cause_outcome_type=>X_SHOW_CAUSE_OUTCOME_TYPE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN );
   update IGS_PR_STU_OU_HIST_ALL set
      APPEAL_COMMENTS =  NEW_REFERENCES.APPEAL_COMMENTS,
      APPEAL_DT =  NEW_REFERENCES.APPEAL_DT,
      APPEAL_EXPIRY_DT =  NEW_REFERENCES.APPEAL_EXPIRY_DT,
      APPEAL_OUTCOME_DT =  NEW_REFERENCES.APPEAL_OUTCOME_DT,
      APPEAL_OUTCOME_TYPE =  NEW_REFERENCES.APPEAL_OUTCOME_TYPE,
      APPLIED_DT =  NEW_REFERENCES.APPLIED_DT,
      COMMENTS =  NEW_REFERENCES.COMMENTS,
      DECISION_DT =  NEW_REFERENCES.DECISION_DT,
      DECISION_ORG_UNIT_CD =  NEW_REFERENCES.DECISION_ORG_UNIT_CD,
      DECISION_OU_START_DT =  NEW_REFERENCES.DECISION_OU_START_DT,
      DECISION_STATUS =  NEW_REFERENCES.DECISION_STATUS,
      DURATION =  NEW_REFERENCES.DURATION,
      DURATION_TYPE =  NEW_REFERENCES.DURATION_TYPE,
      ENCMB_COURSE_GROUP_CD =  NEW_REFERENCES.ENCMB_COURSE_GROUP_CD,
      EXPIRY_DT =  NEW_REFERENCES.EXPIRY_DT,
      HIST_END_DT =  NEW_REFERENCES.HIST_END_DT,
      HIST_WHO =  NEW_REFERENCES.HIST_WHO,
      PRA_SEQUENCE_NUMBER =  NEW_REFERENCES.PRA_SEQUENCE_NUMBER,
      PRG_CAL_TYPE =  NEW_REFERENCES.PRG_CAL_TYPE,
      PRG_CI_SEQUENCE_NUMBER =  NEW_REFERENCES.PRG_CI_SEQUENCE_NUMBER,
      PROGRESSION_OUTCOME_TYPE =  NEW_REFERENCES.PROGRESSION_OUTCOME_TYPE,
      PROGRESSION_RULE_CAT =  NEW_REFERENCES.PROGRESSION_RULE_CAT,
      PRO_PRA_SEQUENCE_NUMBER =  NEW_REFERENCES.PRO_PRA_SEQUENCE_NUMBER,
      PRO_SEQUENCE_NUMBER =  NEW_REFERENCES.PRO_SEQUENCE_NUMBER,
      RESTRICTED_ATTENDANCE_TYPE =  NEW_REFERENCES.RESTRICTED_ATTENDANCE_TYPE,
      RESTRICTED_ENROLMENT_CP =  NEW_REFERENCES.RESTRICTED_ENROLMENT_CP,
      RULE_CHECK_DT =  NEW_REFERENCES.RULE_CHECK_DT,
      SHOW_CAUSE_COMMENTS =  NEW_REFERENCES.SHOW_CAUSE_COMMENTS,
      SHOW_CAUSE_DT =  NEW_REFERENCES.SHOW_CAUSE_DT,
      SHOW_CAUSE_EXPIRY_DT =  NEW_REFERENCES.SHOW_CAUSE_EXPIRY_DT,
      SHOW_CAUSE_OUTCOME_DT =  NEW_REFERENCES.SHOW_CAUSE_OUTCOME_DT,
      SHOW_CAUSE_OUTCOME_TYPE =  NEW_REFERENCES.SHOW_CAUSE_OUTCOME_TYPE,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
	  where ROWID = X_ROWID;
	if (sql%notfound) then
		raise no_data_found;
	end if;

 After_DML (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID
	);
end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_HIST_START_DT IN DATE,
       x_APPEAL_COMMENTS IN VARCHAR2,
       x_APPEAL_DT IN DATE,
       x_APPEAL_EXPIRY_DT IN DATE,
       x_APPEAL_OUTCOME_DT IN DATE,
       x_APPEAL_OUTCOME_TYPE IN VARCHAR2,
       x_APPLIED_DT IN DATE,
       x_COMMENTS IN VARCHAR2,
       x_DECISION_DT IN DATE,
       x_DECISION_ORG_UNIT_CD IN VARCHAR2,
       x_DECISION_OU_START_DT IN DATE,
       x_DECISION_STATUS IN VARCHAR2,
       x_DURATION IN NUMBER,
       x_DURATION_TYPE IN VARCHAR2,
       x_ENCMB_COURSE_GROUP_CD IN VARCHAR2,
       x_EXPIRY_DT IN DATE,
       x_HIST_END_DT IN DATE,
       x_HIST_WHO IN VARCHAR2,
       x_PRA_SEQUENCE_NUMBER IN NUMBER,
       x_PRG_CAL_TYPE IN VARCHAR2,
       x_PRG_CI_SEQUENCE_NUMBER IN NUMBER,
       x_PROGRESSION_OUTCOME_TYPE IN VARCHAR2,
       x_PROGRESSION_RULE_CAT IN VARCHAR2,
       x_PRO_PRA_SEQUENCE_NUMBER IN NUMBER,
       x_PRO_SEQUENCE_NUMBER IN NUMBER,
       x_RESTRICTED_ATTENDANCE_TYPE IN VARCHAR2,
       x_RESTRICTED_ENROLMENT_CP IN NUMBER,
       x_RULE_CHECK_DT IN DATE,
       x_SHOW_CAUSE_COMMENTS IN VARCHAR2,
       x_SHOW_CAUSE_DT IN DATE,
       x_SHOW_CAUSE_EXPIRY_DT IN DATE,
       x_SHOW_CAUSE_OUTCOME_DT IN DATE,
       x_SHOW_CAUSE_OUTCOME_TYPE IN DATE,
      X_MODE in VARCHAR2 default 'R',
       x_ORG_ID IN NUMBER
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PR_STU_OU_HIST_ALL
             where     PERSON_ID= X_PERSON_ID
            and COURSE_CD = X_COURSE_CD
            and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
            and HIST_START_DT = X_HIST_START_DT
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_PERSON_ID,
       X_COURSE_CD,
       X_SEQUENCE_NUMBER,
       X_HIST_START_DT,
       X_APPEAL_COMMENTS,
       X_APPEAL_DT,
       X_APPEAL_EXPIRY_DT,
       X_APPEAL_OUTCOME_DT,
       X_APPEAL_OUTCOME_TYPE,
       X_APPLIED_DT,
       X_COMMENTS,
       X_DECISION_DT,
       X_DECISION_ORG_UNIT_CD,
       X_DECISION_OU_START_DT,
       X_DECISION_STATUS,
       X_DURATION,
       X_DURATION_TYPE,
       X_ENCMB_COURSE_GROUP_CD,
       X_EXPIRY_DT,
       X_HIST_END_DT,
       X_HIST_WHO,
       X_PRA_SEQUENCE_NUMBER,
       X_PRG_CAL_TYPE,
       X_PRG_CI_SEQUENCE_NUMBER,
       X_PROGRESSION_OUTCOME_TYPE,
       X_PROGRESSION_RULE_CAT,
       X_PRO_PRA_SEQUENCE_NUMBER,
       X_PRO_SEQUENCE_NUMBER,
       X_RESTRICTED_ATTENDANCE_TYPE,
       X_RESTRICTED_ENROLMENT_CP,
       X_RULE_CHECK_DT,
       X_SHOW_CAUSE_COMMENTS,
       X_SHOW_CAUSE_DT,
       X_SHOW_CAUSE_EXPIRY_DT,
       X_SHOW_CAUSE_OUTCOME_DT,
       X_SHOW_CAUSE_OUTCOME_TYPE,
      X_MODE,
       X_ORG_ID );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_PERSON_ID,
       X_COURSE_CD,
       X_SEQUENCE_NUMBER,
       X_HIST_START_DT,
       X_APPEAL_COMMENTS,
       X_APPEAL_DT,
       X_APPEAL_EXPIRY_DT,
       X_APPEAL_OUTCOME_DT,
       X_APPEAL_OUTCOME_TYPE,
       X_APPLIED_DT,
       X_COMMENTS,
       X_DECISION_DT,
       X_DECISION_ORG_UNIT_CD,
       X_DECISION_OU_START_DT,
       X_DECISION_STATUS,
       X_DURATION,
       X_DURATION_TYPE,
       X_ENCMB_COURSE_GROUP_CD,
       X_EXPIRY_DT,
       X_HIST_END_DT,
       X_HIST_WHO,
       X_PRA_SEQUENCE_NUMBER,
       X_PRG_CAL_TYPE,
       X_PRG_CI_SEQUENCE_NUMBER,
       X_PROGRESSION_OUTCOME_TYPE,
       X_PROGRESSION_RULE_CAT,
       X_PRO_PRA_SEQUENCE_NUMBER,
       X_PRO_SEQUENCE_NUMBER,
       X_RESTRICTED_ATTENDANCE_TYPE,
       X_RESTRICTED_ENROLMENT_CP,
       X_RULE_CHECK_DT,
       X_SHOW_CAUSE_COMMENTS,
       X_SHOW_CAUSE_DT,
       X_SHOW_CAUSE_EXPIRY_DT,
       X_SHOW_CAUSE_OUTCOME_DT,
       X_SHOW_CAUSE_OUTCOME_TYPE,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
 delete from IGS_PR_STU_OU_HIST_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_pr_stu_ou_hist_pkg;

/
