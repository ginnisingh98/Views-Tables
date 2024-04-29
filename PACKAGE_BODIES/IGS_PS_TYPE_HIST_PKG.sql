--------------------------------------------------------
--  DDL for Package Body IGS_PS_TYPE_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_TYPE_HIST_PKG" AS
 /* $Header: IGSPI39B.pls 115.9 2002/11/29 02:24:02 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_TYPE_HIST_ALL%RowType;
  new_references IGS_PS_TYPE_HIST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_course_type IN VARCHAR2 ,
    x_hist_start_dt IN DATE ,
    x_hist_end_dt IN DATE,
    x_hist_who IN NUMBER ,
    x_description IN VARCHAR2 ,
    x_govt_course_type IN NUMBER ,
    x_course_type_group_cd IN VARCHAR2 ,
    x_tac_course_level IN VARCHAR2 ,
    x_award_course_ind IN VARCHAR2 ,
    x_research_type_ind IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_primary_auto_select IN VARCHAR2 ,
    x_fin_aid_program_type IN  VARCHAR2,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_TYPE_HIST_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.course_type := x_course_type;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.description := x_description;
    new_references.govt_course_type := x_govt_course_type;
    new_references.course_type_group_cd := x_course_type_group_cd;
    new_references.tac_course_level := x_tac_course_level;
    new_references.award_course_ind := x_award_course_ind;
    new_references.research_type_ind := x_research_type_ind;
    new_references.closed_ind := x_closed_ind;
    new_references.primary_auto_select := x_primary_auto_select;
    new_references.fin_aid_program_type:= x_fin_aid_program_type;
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
	Column_Name IN VARCHAR2 ,
	Column_Value IN VARCHAR2
  ) IS
  BEGIN
	IF column_name is null THEN
	   NULL;
	ELSIF upper(column_name) = 'RESEARCH_TYPE_IND' THEN
	   new_references.research_type_ind := column_value;
	ELSIF upper(column_name) = 'CLOSED_IND' THEN
	   new_references.closed_ind := column_value;
	ELSIF upper(column_name) = 'AWARD_COURSE_IND' THEN
	   new_references.award_course_ind := column_value;
 	ELSIF upper(column_name) = 'COURSE_TYPE' THEN
	   new_references.course_type:= column_value;
 	ELSIF upper(column_name) = 'COURSE_TYPE_GROUP_CD' THEN
	   new_references.course_type_group_cd := column_value;
	ELSIF upper(column_name) = 'TAC_COURSE_LEVEL' THEN
	   new_references.tac_course_level := column_value;
        ELSIF upper(column_name) = 'PRIMARY_AUTO_SELECT' THEN
	   new_references.primary_auto_select := column_value;
	END IF;

	IF upper(column_name)= 'COURSE_TYPE' OR
		column_name is null THEN
		IF new_references.course_type <> UPPER(new_references.course_type )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'COURSE_TYPE_GROUP_CD' OR
		column_name is null THEN
		IF new_references.course_type_group_cd <> UPPER(new_references.course_type_group_cd )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;


	IF upper(column_name)= 'TAC_COURSE_LEVEL' OR
		column_name is null THEN
		IF new_references.tac_course_level <> UPPER(new_references.tac_course_level)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

 	IF upper(column_name)= 'RESEARCH_TYPE_IND' OR
		column_name is null THEN
		IF new_references.research_type_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
  	IF upper(column_name)= 'CLOSED_IND' OR
		column_name is null THEN
		IF new_references.closed_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                 IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
  	IF upper(column_name)= 'AWARD_COURSE_IND' OR
		column_name is null THEN
		IF new_references.award_course_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(column_name) = 'PRIMARY_AUTO_SELECT' OR
	        column_name is null THEN
		IF new_references.primary_auto_select NOT IN ( 'Y','N' )
		THEN
		Fnd_Message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
        END IF;
  END Check_Constraints;

  FUNCTION Get_PK_For_Validation (
    x_course_type IN VARCHAR2,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_TYPE_HIST_ALL
      WHERE    course_type = x_course_type
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_course_type IN VARCHAR2 ,
    x_hist_start_dt IN DATE,
    x_hist_end_dt IN DATE ,
    x_hist_who IN NUMBER ,
    x_description IN VARCHAR2 ,
    x_govt_course_type IN NUMBER ,
    x_course_type_group_cd IN VARCHAR2 ,
    x_tac_course_level IN VARCHAR2 ,
    x_award_course_ind IN VARCHAR2 ,
    x_research_type_ind IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_primary_auto_select IN VARCHAR2 ,
    x_fin_aid_program_type IN  VARCHAR2,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_course_type,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_description,
      x_govt_course_type,
      x_course_type_group_cd,
      x_tac_course_level,
      x_award_course_ind,
      x_research_type_ind,
      x_closed_ind,
      x_primary_auto_select,
      x_fin_aid_program_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

	IF Get_PK_For_Validation(
    		new_references.course_type,
    		new_references.hist_start_dt
    	) THEN
 	Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
	END IF;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 IF Get_PK_For_Validation(
    		new_references.course_type,
    		new_references.hist_start_dt
   	) THEN
 	Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
	END IF;
     	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
     	Check_Constraints;

    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;


  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_AWARD_COURSE_IND in VARCHAR2,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_TAC_COURSE_LEVEL in VARCHAR2,
  X_RESEARCH_TYPE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_PRIMARY_AUTO_SELECT IN VARCHAR2 ,
  X_FIN_AID_PROGRAM_TYPE IN VARCHAR2,
  X_MODE in VARCHAR2,
  X_ORG_ID in NUMBER
  ) AS

    cursor C is select ROWID from IGS_PS_TYPE_HIST_ALL
      where COURSE_TYPE = X_COURSE_TYPE
      and HIST_START_DT = X_HIST_START_DT;
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
 Before_DML(
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_course_type => X_COURSE_TYPE,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_description => X_DESCRIPTION,
    x_govt_course_type => X_GOVT_COURSE_TYPE,
    x_course_type_group_cd => X_COURSE_TYPE_GROUP_CD,
    x_tac_course_level => X_TAC_COURSE_LEVEL,
    x_award_course_ind => X_AWARD_COURSE_IND,
    x_research_type_ind => X_RESEARCH_TYPE_IND,
    x_closed_ind => X_CLOSED_IND,
    x_primary_auto_select => X_PRIMARY_AUTO_SELECT,
    x_fin_aid_program_type => X_FIN_AID_PROGRAM_TYPE,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
  );
  insert into IGS_PS_TYPE_HIST_ALL (
    COURSE_TYPE,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    DESCRIPTION,
    GOVT_COURSE_TYPE,
    AWARD_COURSE_IND,
    COURSE_TYPE_GROUP_CD,
    TAC_COURSE_LEVEL,
    RESEARCH_TYPE_IND,
    CLOSED_IND,
    PRIMARY_AUTO_SELECT,
    FIN_AID_PROGRAM_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.COURSE_TYPE,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.GOVT_COURSE_TYPE,
    NEW_REFERENCES.AWARD_COURSE_IND,
    NEW_REFERENCES.COURSE_TYPE_GROUP_CD,
    NEW_REFERENCES.TAC_COURSE_LEVEL,
    NEW_REFERENCES.RESEARCH_TYPE_IND,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.PRIMARY_AUTO_SELECT,
    NEW_REFERENCES.FIN_AID_PROGRAM_TYPE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_AWARD_COURSE_IND in VARCHAR2,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_TAC_COURSE_LEVEL in VARCHAR2,
  X_RESEARCH_TYPE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_PRIMARY_AUTO_SELECT IN VARCHAR2 ,
  X_FIN_AID_PROGRAM_TYPE IN VARCHAR2
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      DESCRIPTION,
      GOVT_COURSE_TYPE,
      AWARD_COURSE_IND,
      COURSE_TYPE_GROUP_CD,
      TAC_COURSE_LEVEL,
      RESEARCH_TYPE_IND,
      CLOSED_IND,
      PRIMARY_AUTO_SELECT,
      FIN_AID_PROGRAM_TYPE
    from IGS_PS_TYPE_HIST_ALL
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.GOVT_COURSE_TYPE = X_GOVT_COURSE_TYPE)
           OR ((tlinfo.GOVT_COURSE_TYPE is null)
               AND (X_GOVT_COURSE_TYPE is null)))
      AND ((tlinfo.AWARD_COURSE_IND = X_AWARD_COURSE_IND)
           OR ((tlinfo.AWARD_COURSE_IND is null)
               AND (X_AWARD_COURSE_IND is null)))
      AND ((tlinfo.COURSE_TYPE_GROUP_CD = X_COURSE_TYPE_GROUP_CD)
           OR ((tlinfo.COURSE_TYPE_GROUP_CD is null)
               AND (X_COURSE_TYPE_GROUP_CD is null)))
      AND ((tlinfo.TAC_COURSE_LEVEL = X_TAC_COURSE_LEVEL)
           OR ((tlinfo.TAC_COURSE_LEVEL is null)
               AND (X_TAC_COURSE_LEVEL is null)))
      AND ((tlinfo.RESEARCH_TYPE_IND = X_RESEARCH_TYPE_IND)
           OR ((tlinfo.RESEARCH_TYPE_IND is null)
               AND (X_RESEARCH_TYPE_IND is null)))
      AND ((tlinfo.CLOSED_IND = X_CLOSED_IND)
           OR ((tlinfo.CLOSED_IND is null)
               AND (X_CLOSED_IND is null)))
      AND (( tlinfo.PRIMARY_AUTO_SELECT = X_PRIMARY_AUTO_SELECT)
           OR ((tlinfo.PRIMARY_AUTO_SELECT is null)
	      AND (X_PRIMARY_AUTO_SELECT is null )))
      AND (( tlinfo.FIN_AID_PROGRAM_TYPE= X_FIN_AID_PROGRAM_TYPE)
           OR ((tlinfo.FIN_AID_PROGRAM_TYPE is null)
	      AND (X_FIN_AID_PROGRAM_TYPE is null )))
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
  X_COURSE_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_AWARD_COURSE_IND in VARCHAR2,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_TAC_COURSE_LEVEL in VARCHAR2,
  X_RESEARCH_TYPE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_PRIMARY_AUTO_SELECT IN VARCHAR2 ,
  X_FIN_AID_PROGRAM_TYPE IN VARCHAR2,
  X_MODE in VARCHAR2
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
 Before_DML( p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_course_type => X_COURSE_TYPE,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_description => X_DESCRIPTION,
    x_govt_course_type => X_GOVT_COURSE_TYPE,
    x_course_type_group_cd => X_COURSE_TYPE_GROUP_CD,
    x_tac_course_level => X_TAC_COURSE_LEVEL,
    x_award_course_ind => X_AWARD_COURSE_IND,
    x_research_type_ind => X_RESEARCH_TYPE_IND,
    x_closed_ind => X_CLOSED_IND,
    x_primary_auto_select => X_PRIMARY_AUTO_SELECT,
    x_fin_aid_program_type => X_FIN_AID_PROGRAM_TYPE,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_PS_TYPE_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    GOVT_COURSE_TYPE = NEW_REFERENCES.GOVT_COURSE_TYPE,
    AWARD_COURSE_IND = NEW_REFERENCES.AWARD_COURSE_IND,
    COURSE_TYPE_GROUP_CD = NEW_REFERENCES.COURSE_TYPE_GROUP_CD,
    TAC_COURSE_LEVEL = NEW_REFERENCES.TAC_COURSE_LEVEL,
    RESEARCH_TYPE_IND = NEW_REFERENCES.RESEARCH_TYPE_IND,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    PRIMARY_AUTO_SELECT = NEW_REFERENCES.PRIMARY_AUTO_SELECT,
    FIN_AID_PROGRAM_TYPE = NEW_REFERENCES.FIN_AID_PROGRAM_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_AWARD_COURSE_IND in VARCHAR2,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_TAC_COURSE_LEVEL in VARCHAR2,
  X_RESEARCH_TYPE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_PRIMARY_AUTO_SELECT IN VARCHAR2,
  X_FIN_AID_PROGRAM_TYPE IN VARCHAR2,
  X_MODE in VARCHAR2,
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_PS_TYPE_HIST_ALL
     where COURSE_TYPE = X_COURSE_TYPE
     and HIST_START_DT = X_HIST_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_TYPE,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_DESCRIPTION,
     X_GOVT_COURSE_TYPE,
     X_AWARD_COURSE_IND,
     X_COURSE_TYPE_GROUP_CD,
     X_TAC_COURSE_LEVEL,
     X_RESEARCH_TYPE_IND,
     X_CLOSED_IND,
     X_PRIMARY_AUTO_SELECT,
     X_FIN_AID_PROGRAM_TYPE,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_TYPE,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_DESCRIPTION,
   X_GOVT_COURSE_TYPE,
   X_AWARD_COURSE_IND,
   X_COURSE_TYPE_GROUP_CD,
   X_TAC_COURSE_LEVEL,
   X_RESEARCH_TYPE_IND,
   X_CLOSED_IND,
   X_PRIMARY_AUTO_SELECT,
   X_FIN_AID_PROGRAM_TYPE,
   X_MODE
   );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
 Before_DML( p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_PS_TYPE_HIST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_PS_TYPE_HIST_PKG;

/
