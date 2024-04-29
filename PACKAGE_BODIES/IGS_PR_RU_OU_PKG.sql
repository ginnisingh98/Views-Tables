--------------------------------------------------------
--  DDL for Package Body IGS_PR_RU_OU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_RU_OU_PKG" AS
/* $Header: IGSQI13B.pls 115.13 2003/02/26 07:00:32 shtatiko ship $ */

 l_rowid VARCHAR2(25);
  old_references IGS_PR_RU_OU_ALL%RowType;
  new_references IGS_PR_RU_OU_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER,
    x_number_of_failures IN NUMBER,
    x_progression_outcome_type IN VARCHAR2,
    x_apply_automatically_ind IN VARCHAR2,
    x_prg_rule_repeat_fail_type IN VARCHAR2,
    x_override_show_cause_ind IN VARCHAR2,
    x_override_appeal_ind IN VARCHAR2,
    x_duration IN NUMBER,
    x_duration_type IN VARCHAR2,
    x_rank IN NUMBER,
    x_encmb_course_group_cd IN VARCHAR2,
    x_restricted_enrolment_cp IN NUMBER,
    x_restricted_attendance_type IN VARCHAR2,
    x_comments IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER,
  	-- anilk, bug#2784198
	  x_logical_delete_dt in DATE
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_RU_OU_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action not in ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_old_ref_values;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.progression_rule_cat := x_progression_rule_cat;
    new_references.pra_sequence_number := x_pra_sequence_number;
    new_references.sequence_number := x_sequence_number;
    new_references.number_of_failures := x_number_of_failures;
    new_references.progression_outcome_type := x_progression_outcome_type;
    new_references.apply_automatically_ind := x_apply_automatically_ind;
    new_references.prg_rule_repeat_fail_type := x_prg_rule_repeat_fail_type;
    new_references.override_show_cause_ind := x_override_show_cause_ind;
    new_references.override_appeal_ind := x_override_appeal_ind;
    new_references.duration := x_duration;
    new_references.duration_type := x_duration_type;
    new_references.rank := x_rank;
    new_references.encmb_course_group_cd := x_encmb_course_group_cd;
    new_references.restricted_enrolment_cp := x_restricted_enrolment_cp;
    new_references.restricted_attendance_type := x_restricted_attendance_type;
    new_references.comments := x_comments;
    new_references.org_id := x_org_id;
	  -- anilk, bug#2784198
		new_references.logical_delete_dt := x_logical_delete_dt;

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
PROCEDURE Check_Uniqueness AS

    BEGIN

	IF GET_UK_FOR_VALIDATION(NEW_REFERENCES.progression_rule_cat,
               NEW_REFERENCES.pra_sequence_number,
               NEW_REFERENCES.number_of_failures,
               NEW_REFERENCES.prg_rule_repeat_fail_type,
               NEW_REFERENCES.rank)
THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;

	END IF;
end Check_Uniqueness;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.restricted_attendance_type = new_references.restricted_attendance_type)) OR
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

    IF (((old_references.encmb_course_group_cd = new_references.encmb_course_group_cd)) OR
        ((new_references.encmb_course_group_cd IS NULL))) THEN
      NULL;
    ELSE
     IF NOT  IGS_PS_GRP_PKG.Get_PK_For_Validation (
        new_references.encmb_course_group_cd
        ) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.progression_outcome_type = new_references.progression_outcome_type)) OR
        ((new_references.progression_outcome_type IS NULL))) THEN
      NULL;
    ELSE
     IF NOT  IGS_PR_OU_TYPE_PKG.Get_PK_For_Validation (
        new_references.progression_outcome_type
        ) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.progression_rule_cat = new_references.progression_rule_cat) AND
         (old_references.pra_sequence_number = new_references.pra_sequence_number)) OR
        ((new_references.progression_rule_cat IS NULL) OR
         (new_references.pra_sequence_number IS NULL))) THEN
      NULL;
    ELSE
     IF NOT  IGS_PR_RU_APPL_PKG.Get_PK_For_Validation (
        new_references.progression_rule_cat,
        new_references.pra_sequence_number
        ) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.prg_rule_repeat_fail_type = new_references.prg_rule_repeat_fail_type)) OR
        ((new_references.prg_rule_repeat_fail_type IS NULL))) THEN
      NULL;
    ELSE
     IF NOT  IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
	'PRG_RULE_REPEAT_FAIL_TYPE',
        new_references.prg_rule_repeat_fail_type
        ) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PR_OU_PS_PKG.GET_FK_IGS_PR_RU_OU (
      old_references.progression_rule_cat,
      old_references.pra_sequence_number,
      old_references.sequence_number
      );

    IGS_PR_OU_UNIT_PKG.GET_FK_IGS_PR_RU_OU (
      old_references.progression_rule_cat,
      old_references.pra_sequence_number,
      old_references.sequence_number
      );

    IGS_PR_OU_UNIT_SET_PKG.GET_FK_IGS_PR_RU_OU (
      old_references.progression_rule_cat,
      old_references.pra_sequence_number,
      old_references.sequence_number
      );

    IGS_PR_RU_APPL_PKG.GET_FK_IGS_PR_RU_OU (
      old_references.progression_rule_cat,
      old_references.pra_sequence_number,
      old_references.sequence_number
      );

    IGS_PR_STDNT_PR_OU_PKG.GET_FK_IGS_PR_RU_OU (
      old_references.progression_rule_cat,
      old_references.pra_sequence_number,
      old_references.sequence_number
      );

    IGS_PR_OU_AWD_PKG.GET_FK_IGS_PR_RU_OU (
      old_references.progression_rule_cat,
      old_references.pra_sequence_number,
      old_references.sequence_number
      );

    IGS_PR_OU_FND_PKG.GET_FK_IGS_PR_RU_OU(
      old_references.progression_rule_cat,
      old_references.pra_sequence_number,
      old_references.sequence_number
      );

  END Check_Child_Existance;

FUNCTION Get_PK_For_Validation (
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_OU_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat
      AND      pra_sequence_number = x_pra_sequence_number
      AND      sequence_number = x_sequence_number;

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
    x_attendance_type IN varchar2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_OU_ALL
      WHERE    restricted_attendance_type = x_attendance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRO_ATT_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ATD_TYPE;

  PROCEDURE GET_FK_IGS_PR_OU_TYPE (
    x_progression_outcome_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_OU_ALL
      WHERE    progression_outcome_type = x_progression_outcome_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRO_POT_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_OU_TYPE;

  PROCEDURE GET_FK_IGS_PR_RU_APPL (
    x_progression_rule_cat IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_OU_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat
      AND      pra_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRO_PRA_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_RU_APPL;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_prg_rule_repeat_fail_type IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_OU_ALL
      WHERE    prg_rule_repeat_fail_type = x_s_prg_rule_repeat_fail_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRO_SPRRFT_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2,
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER,
    x_number_of_failures IN NUMBER,
    x_progression_outcome_type IN VARCHAR2,
    x_apply_automatically_ind IN VARCHAR2,
    x_prg_rule_repeat_fail_type IN VARCHAR2,
    x_override_show_cause_ind IN VARCHAR2,
    x_override_appeal_ind IN VARCHAR2,
    x_duration IN NUMBER,
    x_duration_type IN VARCHAR2,
    x_rank IN NUMBER,
    x_encmb_course_group_cd IN VARCHAR2,
    x_restricted_enrolment_cp IN NUMBER,
    x_restricted_attendance_type IN VARCHAR2,
    x_comments IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_org_id IN NUMBER,
  	-- anilk, bug#2784198
	  x_logical_delete_dt in DATE
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_progression_rule_cat,
      x_pra_sequence_number,
      x_sequence_number,
      x_number_of_failures,
      x_progression_outcome_type,
      x_apply_automatically_ind,
      x_prg_rule_repeat_fail_type,
      x_override_show_cause_ind,
      x_override_appeal_ind,
      x_duration,
      x_duration_type,
      x_rank,
      x_encmb_course_group_cd,
      x_restricted_enrolment_cp,
      x_restricted_attendance_type,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id,
    	-- anilk, bug#2784198
    	x_logical_delete_dt
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Check_Parent_Existance;
	IF Get_PK_For_Validation (
		    new_references.progression_rule_cat,
		    new_references.pra_sequence_number,
		    new_references.sequence_number)  THEN
 	Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;

	END IF;
	CHECK_UNIQUENESS;
	CHECK_CONSTRAINTS;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Parent_Existance;
	CHECK_UNIQUENESS;
	CHECK_CONSTRAINTS;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;

	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation (
		    new_references.progression_rule_cat,
		    new_references.pra_sequence_number,
		    new_references.sequence_number)  THEN
 	Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;

	END IF;
	CHECK_UNIQUENESS;
	CHECK_CONSTRAINTS;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	CHECK_UNIQUENESS;
	CHECK_CONSTRAINTS;

	ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;

    END IF;

  END Before_DML;
  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : jdeekoll
  Date Created On : 27-12-2000
  Purpose : Creation of TBH
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
l_rowid:=NULL;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_NUMBER_OF_FAILURES in NUMBER,
  X_PROGRESSION_OUTCOME_TYPE in VARCHAR2,
  X_APPLY_AUTOMATICALLY_IND in VARCHAR2,
  X_PRG_RULE_REPEAT_FAIL_TYPE in VARCHAR2,
  X_OVERRIDE_SHOW_CAUSE_IND in VARCHAR2,
  X_OVERRIDE_APPEAL_IND in VARCHAR2,
  X_DURATION in NUMBER,
  X_DURATION_TYPE in VARCHAR2,
  X_RANK in NUMBER,
  X_ENCMB_COURSE_GROUP_CD in VARCHAR2,
  X_RESTRICTED_ENROLMENT_CP in NUMBER,
  X_RESTRICTED_ATTENDANCE_TYPE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2,
  X_ORG_ID IN NUMBER,
	-- anilk, bug#2784198
	X_LOGICAL_DELETE_DT in DATE
  ) AS
    cursor C is select ROWID from IGS_PR_RU_OU_ALL
      where PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT
      and PRA_SEQUENCE_NUMBER = X_PRA_SEQUENCE_NUMBER
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
Before_DML (
    p_action => 'INSERT',
    x_rowid => x_rowid ,
    x_progression_rule_cat => x_progression_rule_cat ,
    x_pra_sequence_number => x_pra_sequence_number ,
    x_sequence_number => x_sequence_number ,
    x_number_of_failures => x_number_of_failures ,
    x_progression_outcome_type => x_progression_outcome_type ,
    x_apply_automatically_ind => nvl( x_apply_automatically_ind, 'N') ,
    x_prg_rule_repeat_fail_type => x_prg_rule_repeat_fail_type ,
    x_override_show_cause_ind => x_override_show_cause_ind ,
    x_override_appeal_ind => x_override_appeal_ind ,
    x_duration => x_duration ,
    x_duration_type => x_duration_type ,
    x_rank => x_rank ,
    x_encmb_course_group_cd => x_encmb_course_group_cd ,
    x_restricted_enrolment_cp => x_restricted_enrolment_cp ,
    x_restricted_attendance_type => x_restricted_attendance_type ,
    x_comments => x_comments ,
    x_creation_date => x_last_update_date ,
    x_created_by =>  x_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by =>  x_last_updated_by ,
    x_last_update_login => x_last_update_login,
    x_org_id => igs_ge_gen_003.get_org_id,
  	-- anilk, bug#2784198
		x_logical_delete_dt => x_logical_delete_dt
  ) ;
  insert into IGS_PR_RU_OU_ALL (
    PROGRESSION_RULE_CAT,
    PRA_SEQUENCE_NUMBER,
    SEQUENCE_NUMBER,
    NUMBER_OF_FAILURES,
    PROGRESSION_OUTCOME_TYPE,
    APPLY_AUTOMATICALLY_IND,
    PRG_RULE_REPEAT_FAIL_TYPE,
    OVERRIDE_SHOW_CAUSE_IND,
    OVERRIDE_APPEAL_IND,
    DURATION,
    DURATION_TYPE,
    RANK,
    ENCMB_COURSE_GROUP_CD,
    RESTRICTED_ENROLMENT_CP,
    RESTRICTED_ATTENDANCE_TYPE,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID,
  	-- anilk, bug#2784198
	  LOGICAL_DELETE_DT

  ) values (
    NEW_REFERENCES.PROGRESSION_RULE_CAT,
    NEW_REFERENCES.PRA_SEQUENCE_NUMBER,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.NUMBER_OF_FAILURES,
    NEW_REFERENCES.PROGRESSION_OUTCOME_TYPE,
    NEW_REFERENCES.APPLY_AUTOMATICALLY_IND,
    NEW_REFERENCES.PRG_RULE_REPEAT_FAIL_TYPE,
    NEW_REFERENCES.OVERRIDE_SHOW_CAUSE_IND,
    NEW_REFERENCES.OVERRIDE_APPEAL_IND,
    NEW_REFERENCES.DURATION,
    NEW_REFERENCES.DURATION_TYPE,
    NEW_REFERENCES.RANK,
    NEW_REFERENCES.ENCMB_COURSE_GROUP_CD,
    NEW_REFERENCES.RESTRICTED_ENROLMENT_CP,
    NEW_REFERENCES.RESTRICTED_ATTENDANCE_TYPE,
    NEW_REFERENCES.COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID,
	  -- anilk, bug#2784198
	  NEW_REFERENCES.LOGICAL_DELETE_DT
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
  X_ROWID in VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_NUMBER_OF_FAILURES in NUMBER,
  X_PROGRESSION_OUTCOME_TYPE in VARCHAR2,
  X_APPLY_AUTOMATICALLY_IND in VARCHAR2,
  X_PRG_RULE_REPEAT_FAIL_TYPE in VARCHAR2,
  X_OVERRIDE_SHOW_CAUSE_IND in VARCHAR2,
  X_OVERRIDE_APPEAL_IND in VARCHAR2,
  X_DURATION in NUMBER,
  X_DURATION_TYPE in VARCHAR2,
  X_RANK in NUMBER,
  X_ENCMB_COURSE_GROUP_CD in VARCHAR2,
  X_RESTRICTED_ENROLMENT_CP in NUMBER,
  X_RESTRICTED_ATTENDANCE_TYPE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
	-- anilk, bug#2784198
	X_LOGICAL_DELETE_DT in DATE
) AS
  cursor c1 is select
      NUMBER_OF_FAILURES,
      PROGRESSION_OUTCOME_TYPE,
      APPLY_AUTOMATICALLY_IND,
      PRG_RULE_REPEAT_FAIL_TYPE,
      OVERRIDE_SHOW_CAUSE_IND,
      OVERRIDE_APPEAL_IND,
      DURATION,
      DURATION_TYPE,
      RANK,
      ENCMB_COURSE_GROUP_CD,
      RESTRICTED_ENROLMENT_CP,
      RESTRICTED_ATTENDANCE_TYPE,
      COMMENTS,
	    -- anilk, bug#2784198
	    LOGICAL_DELETE_DT
    from IGS_PR_RU_OU_ALL
    where ROWID = X_ROWID for update nowait;
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

   if (

    ((tlinfo.NUMBER_OF_FAILURES = X_NUMBER_OF_FAILURES)
    OR (tlinfo.NUMBER_OF_FAILURES is null and   X_NUMBER_OF_FAILURES is null))
     AND
      (tlinfo.PROGRESSION_OUTCOME_TYPE = X_PROGRESSION_OUTCOME_TYPE)
      AND (tlinfo.APPLY_AUTOMATICALLY_IND = X_APPLY_AUTOMATICALLY_IND)
      AND ((tlinfo.PRG_RULE_REPEAT_FAIL_TYPE = X_PRG_RULE_REPEAT_FAIL_TYPE)
      OR (tlinfo.PRG_RULE_REPEAT_FAIL_TYPE is null and X_PRG_RULE_REPEAT_FAIL_TYPE is null))
      AND ((tlinfo.OVERRIDE_SHOW_CAUSE_IND = X_OVERRIDE_SHOW_CAUSE_IND)
           OR ((tlinfo.OVERRIDE_SHOW_CAUSE_IND is null)
               AND (X_OVERRIDE_SHOW_CAUSE_IND is null)))
      AND ((tlinfo.OVERRIDE_APPEAL_IND = X_OVERRIDE_APPEAL_IND)
           OR ((tlinfo.OVERRIDE_APPEAL_IND is null)
               AND (X_OVERRIDE_APPEAL_IND is null)))
      AND ((tlinfo.DURATION = X_DURATION)
           OR ((tlinfo.DURATION is null)
               AND (X_DURATION is null)))
      AND ((tlinfo.DURATION_TYPE = X_DURATION_TYPE)
           OR ((tlinfo.DURATION_TYPE is null)
               AND (X_DURATION_TYPE is null)))
      AND (tlinfo.RANK = X_RANK)
      AND ((tlinfo.ENCMB_COURSE_GROUP_CD = X_ENCMB_COURSE_GROUP_CD)
           OR ((tlinfo.ENCMB_COURSE_GROUP_CD is null)
               AND (X_ENCMB_COURSE_GROUP_CD is null)))
      AND ((tlinfo.RESTRICTED_ENROLMENT_CP = X_RESTRICTED_ENROLMENT_CP)
           OR ((tlinfo.RESTRICTED_ENROLMENT_CP is null)
               AND (X_RESTRICTED_ENROLMENT_CP is null)))
      AND ((tlinfo.RESTRICTED_ATTENDANCE_TYPE = X_RESTRICTED_ATTENDANCE_TYPE)
           OR ((tlinfo.RESTRICTED_ATTENDANCE_TYPE is null)
               AND (X_RESTRICTED_ATTENDANCE_TYPE is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
	    -- anilk, bug#2784198
      AND ((tlinfo.LOGICAL_DELETE_DT = X_LOGICAL_DELETE_DT)
           OR ((tlinfo.LOGICAL_DELETE_DT is null)
               AND (X_LOGICAL_DELETE_DT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_NUMBER_OF_FAILURES in NUMBER,
  X_PROGRESSION_OUTCOME_TYPE in VARCHAR2,
  X_APPLY_AUTOMATICALLY_IND in VARCHAR2,
  X_PRG_RULE_REPEAT_FAIL_TYPE in VARCHAR2,
  X_OVERRIDE_SHOW_CAUSE_IND in VARCHAR2,
  X_OVERRIDE_APPEAL_IND in VARCHAR2,
  X_DURATION in NUMBER,
  X_DURATION_TYPE in VARCHAR2,
  X_RANK in NUMBER,
  X_ENCMB_COURSE_GROUP_CD in VARCHAR2,
  X_RESTRICTED_ENROLMENT_CP in NUMBER,
  X_RESTRICTED_ATTENDANCE_TYPE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 ,
	-- anilk, bug#2784198
	X_LOGICAL_DELETE_DT in DATE
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
Before_DML (
    p_action => 'UPDATE',
    x_rowid => x_rowid ,
    x_progression_rule_cat => x_progression_rule_cat ,
    x_pra_sequence_number => x_pra_sequence_number ,
    x_sequence_number => x_sequence_number ,
    x_number_of_failures => x_number_of_failures ,
    x_progression_outcome_type => x_progression_outcome_type ,
    x_apply_automatically_ind => x_apply_automatically_ind ,
    x_prg_rule_repeat_fail_type => x_prg_rule_repeat_fail_type ,
    x_override_show_cause_ind => x_override_show_cause_ind ,
    x_override_appeal_ind => x_override_appeal_ind ,
    x_duration => x_duration ,
    x_duration_type => x_duration_type ,
    x_rank => x_rank ,
    x_encmb_course_group_cd => x_encmb_course_group_cd ,
    x_restricted_enrolment_cp => x_restricted_enrolment_cp ,
    x_restricted_attendance_type => x_restricted_attendance_type ,
    x_comments => x_comments ,
    x_creation_date => x_last_update_date ,
    x_created_by =>  x_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by =>  x_last_updated_by ,
    x_last_update_login => x_last_update_login,
  	-- anilk, bug#2784198
	  x_logical_delete_dt => x_logical_delete_dt
  ) ;

  update IGS_PR_RU_OU_ALL set
    NUMBER_OF_FAILURES = NEW_REFERENCES.NUMBER_OF_FAILURES,
    PROGRESSION_OUTCOME_TYPE = NEW_REFERENCES.PROGRESSION_OUTCOME_TYPE,
    APPLY_AUTOMATICALLY_IND = NEW_REFERENCES.APPLY_AUTOMATICALLY_IND,
    PRG_RULE_REPEAT_FAIL_TYPE = NEW_REFERENCES.PRG_RULE_REPEAT_FAIL_TYPE,
    OVERRIDE_SHOW_CAUSE_IND = NEW_REFERENCES.OVERRIDE_SHOW_CAUSE_IND,
    OVERRIDE_APPEAL_IND = NEW_REFERENCES.OVERRIDE_APPEAL_IND,
    DURATION = NEW_REFERENCES.DURATION,
    DURATION_TYPE = NEW_REFERENCES.DURATION_TYPE,
    RANK = NEW_REFERENCES.RANK,
    ENCMB_COURSE_GROUP_CD = NEW_REFERENCES.ENCMB_COURSE_GROUP_CD,
    RESTRICTED_ENROLMENT_CP = NEW_REFERENCES.RESTRICTED_ENROLMENT_CP,
    RESTRICTED_ATTENDANCE_TYPE = NEW_REFERENCES.RESTRICTED_ATTENDANCE_TYPE,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
  	-- anilk, bug#2784198
	  LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

      After_DML (
		p_action => 'UPDATE' ,
		x_rowid => X_ROWID );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_NUMBER_OF_FAILURES in NUMBER,
  X_PROGRESSION_OUTCOME_TYPE in VARCHAR2,
  X_APPLY_AUTOMATICALLY_IND in VARCHAR2,
  X_PRG_RULE_REPEAT_FAIL_TYPE in VARCHAR2,
  X_OVERRIDE_SHOW_CAUSE_IND in VARCHAR2,
  X_OVERRIDE_APPEAL_IND in VARCHAR2,
  X_DURATION in NUMBER,
  X_DURATION_TYPE in VARCHAR2,
  X_RANK in NUMBER,
  X_ENCMB_COURSE_GROUP_CD in VARCHAR2,
  X_RESTRICTED_ENROLMENT_CP in NUMBER,
  X_RESTRICTED_ATTENDANCE_TYPE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ORG_ID IN NUMBER,
	-- anilk, bug#2784198
	X_LOGICAL_DELETE_DT in DATE
  ) AS
  cursor c1 is select rowid from IGS_PR_RU_OU_ALL
     where PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT
     and PRA_SEQUENCE_NUMBER = X_PRA_SEQUENCE_NUMBER
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PROGRESSION_RULE_CAT,
     X_PRA_SEQUENCE_NUMBER,
     X_SEQUENCE_NUMBER,
     X_NUMBER_OF_FAILURES,
     X_PROGRESSION_OUTCOME_TYPE,
     X_APPLY_AUTOMATICALLY_IND,
     X_PRG_RULE_REPEAT_FAIL_TYPE,
     X_OVERRIDE_SHOW_CAUSE_IND,
     X_OVERRIDE_APPEAL_IND,
     X_DURATION,
     X_DURATION_TYPE,
     X_RANK,
     X_ENCMB_COURSE_GROUP_CD,
     X_RESTRICTED_ENROLMENT_CP,
     X_RESTRICTED_ATTENDANCE_TYPE,
     X_COMMENTS,
     X_MODE,
     x_org_id,
  	 -- anilk, bug#2784198
	   X_LOGICAL_DELETE_DT
		 );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID ,
   X_PROGRESSION_RULE_CAT,
   X_PRA_SEQUENCE_NUMBER,
   X_SEQUENCE_NUMBER,
   X_NUMBER_OF_FAILURES,
   X_PROGRESSION_OUTCOME_TYPE,
   X_APPLY_AUTOMATICALLY_IND,
   X_PRG_RULE_REPEAT_FAIL_TYPE,
   X_OVERRIDE_SHOW_CAUSE_IND,
   X_OVERRIDE_APPEAL_IND,
   X_DURATION,
   X_DURATION_TYPE,
   X_RANK,
   X_ENCMB_COURSE_GROUP_CD,
   X_RESTRICTED_ENROLMENT_CP,
   X_RESTRICTED_ATTENDANCE_TYPE,
   X_COMMENTS,
   X_MODE,
   -- anilk, bug#2784198
	 X_LOGICAL_DELETE_DT
	 );
end ADD_ROW;

FUNCTION GET_UK_FOR_VALIDATION(X_progression_rule_cat IN VARCHAR2,
               X_pra_sequence_number IN NUMBER,
               X_number_of_failures IN NUMBER,
               X_prg_rule_repeat_fail_type IN VARCHAR2,
               X_rank IN NUMBER)
 RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_OU_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat
      AND      pra_sequence_number = x_pra_sequence_number
      AND	   prg_rule_repeat_fail_type = X_prg_rule_repeat_fail_type
      AND      number_of_failures = X_number_of_failures
	AND	   rank = X_rank
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
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
END GET_UK_FOR_VALIDATION;

PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2,
	Column_Value IN VARCHAR2
	) AS
    BEGIN

IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'PRA_SEQUENCE_NUMBER' THEN
  new_references.PRA_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' THEN
  new_references.SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'APPLY_AUTOMATICALLY_IND' THEN
  new_references.APPLY_AUTOMATICALLY_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'OVERRIDE_SHOW_CAUSE_IND' THEN
  new_references.OVERRIDE_SHOW_CAUSE_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'OVERRIDE_APPEAL_IND' THEN
  new_references.OVERRIDE_APPEAL_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'DURATION' THEN
  new_references.DURATION:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'DURATION_TYPE' THEN
  new_references.DURATION_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'ENCMB_COURSE_GROUP_CD' THEN
  new_references.ENCMB_COURSE_GROUP_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PRG_RULE_REPEAT_FAIL_TYPE' THEN
  new_references.PRG_RULE_REPEAT_FAIL_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PROGRESSION_OUTCOME_TYPE' THEN
  new_references.PROGRESSION_OUTCOME_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PROGRESSION_RULE_CAT' THEN
  new_references.PROGRESSION_RULE_CAT:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'RESTRICTED_ATTENDANCE_TYPE' THEN
  new_references.RESTRICTED_ATTENDANCE_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'RANK' THEN
  new_references.RANK:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'RESTRICTED_ENROLMENT_CP' THEN
  new_references.RESTRICTED_ENROLMENT_CP:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'PRA_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRA_SEQUENCE_NUMBER < 1 or new_references.PRA_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.SEQUENCE_NUMBER < 1 or new_references.SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'APPLY_AUTOMATICALLY_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.APPLY_AUTOMATICALLY_IND<> upper(new_references.APPLY_AUTOMATICALLY_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.APPLY_AUTOMATICALLY_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'OVERRIDE_SHOW_CAUSE_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.OVERRIDE_SHOW_CAUSE_IND<> upper(new_references.OVERRIDE_SHOW_CAUSE_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.OVERRIDE_SHOW_CAUSE_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'OVERRIDE_APPEAL_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.OVERRIDE_APPEAL_IND<> upper(new_references.OVERRIDE_APPEAL_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.OVERRIDE_APPEAL_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'DURATION' OR COLUMN_NAME IS NULL THEN
  IF new_references.DURATION < 1 or new_references.DURATION > 999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'DURATION_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.DURATION_TYPE<> upper(new_references.DURATION_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.DURATION_TYPE not in  ( 'NORMAL' , 'EFFECTIVE' ) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'ENCMB_COURSE_GROUP_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.ENCMB_COURSE_GROUP_CD<> upper(new_references.ENCMB_COURSE_GROUP_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRG_RULE_REPEAT_FAIL_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRG_RULE_REPEAT_FAIL_TYPE<> upper(new_references.PRG_RULE_REPEAT_FAIL_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PROGRESSION_OUTCOME_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.PROGRESSION_OUTCOME_TYPE<> upper(new_references.PROGRESSION_OUTCOME_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PROGRESSION_RULE_CAT' OR COLUMN_NAME IS NULL THEN
  IF new_references.PROGRESSION_RULE_CAT<> upper(new_references.PROGRESSION_RULE_CAT) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'RESTRICTED_ATTENDANCE_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.RESTRICTED_ATTENDANCE_TYPE<> upper(new_references.RESTRICTED_ATTENDANCE_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'RANK' OR COLUMN_NAME IS NULL THEN
  IF new_references.RANK < 0 or new_references.RANK > 99 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'RESTRICTED_ENROLMENT_CP' OR COLUMN_NAME IS NULL THEN
  IF new_references.RESTRICTED_ENROLMENT_CP < 0 or new_references.RESTRICTED_ENROLMENT_CP > 999.999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

END Check_Constraints;


END IGS_PR_RU_OU_PKG;

/
