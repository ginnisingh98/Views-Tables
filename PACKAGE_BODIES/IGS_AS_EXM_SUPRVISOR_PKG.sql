--------------------------------------------------------
--  DDL for Package Body IGS_AS_EXM_SUPRVISOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_EXM_SUPRVISOR_PKG" as
/* $Header: IGSDI42B.pls 115.10 2002/12/23 07:08:50 ddey ship $ */

l_rowid VARCHAR2(25);
  old_references IGS_AS_EXM_SUPRVISOR_ALL%RowType;
  new_references IGS_AS_EXM_SUPRVISOR_ALL%RowType;
 PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_exam_supervisor_type IN VARCHAR2 DEFAULT NULL,
    x_previous_sessions IN NUMBER DEFAULT NULL,
    x_responsible_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_responsible_ou_start_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_EXM_SUPRVISOR_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      Igs_Ge_Msg_Stack.Add;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
     new_references.org_id := x_org_id;
    new_references.person_id := x_person_id;
    new_references.exam_supervisor_type := x_exam_supervisor_type;
    new_references.previous_sessions := x_previous_sessions;
    new_references.responsible_org_unit_cd := x_responsible_org_unit_cd;
    new_references.responsible_ou_start_dt := x_responsible_ou_start_dt;
    new_references.comments := x_comments;
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
 PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
	v_message_name  varchar2(30);
  BEGIN
	-- Validate that the exam supervisor type is not closed.
	IF p_inserting OR
	   (p_updating AND
	   (new_references.exam_supervisor_type <> old_references.exam_supervisor_type)) THEN
		IF IGS_AS_VAL_ESU.assp_val_est_closed(new_references.exam_supervisor_type,
						v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     Igs_Ge_Msg_Stack.Add;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate that the organisation IGS_PS_UNIT is not INACTIVE.
	IF p_inserting OR
	   (p_updating AND
	   (NVL(new_references.responsible_org_unit_cd, 'NULL') <>
			NVL(old_references.responsible_org_unit_cd, 'NULL')) OR
	   (NVL(new_references.responsible_ou_start_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
			NVL(old_references.responsible_ou_start_dt, IGS_GE_DATE.IGSDATE('1900/01/01')))) THEN
			-- As part of the bug# 1956374 changed to the below call from IGS_AS_VAL_ESU.crsp_val_ou_sys_sts
		IF IGS_PS_VAL_CRV.crsp_val_ou_sys_sts(new_references.responsible_org_unit_cd,
						new_references.responsible_ou_start_dt,
						v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     Igs_Ge_Msg_Stack.Add;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.exam_supervisor_type = new_references.exam_supervisor_type)) OR
        ((new_references.exam_supervisor_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_AS_EXM_SPRVSRTYP_PKG.Get_PK_For_Validation (
        new_references.exam_supervisor_type
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     Igs_Ge_Msg_Stack.Add;
     App_Exception.Raise_Exception;
      END IF;

    END IF;

    IF (((old_references.responsible_org_unit_cd = new_references.responsible_org_unit_cd) AND
         (old_references.responsible_ou_start_dt = new_references.responsible_ou_start_dt)) OR
        ((new_references.responsible_org_unit_cd IS NULL) OR
         (new_references.responsible_ou_start_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.responsible_org_unit_cd,
        new_references.responsible_ou_start_dt
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        ))THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

PROCEDURE Check_Constraints (
Column_Name	IN	VARCHAR2	DEFAULT NULL,
Column_Value 	IN	VARCHAR2	DEFAULT NULL
	) as
BEGIN
      IF  column_name is null then
         NULL;
      ELSIF upper(Column_name) = 'EXAM_SUPERVISOR_TYPE' then
         new_references.exam_supervisor_type:= column_value;
      ELSIF upper(Column_name) = 'RESPONSIBLE_ORG_UNIT_CD' then
         new_references.responsible_org_unit_cd:= column_value;
      ELSIF upper(Column_name) = 'PREVIOUS_SESSIONS' then
         new_references.previous_sessions:= IGS_GE_NUMBER.TO_NUM(column_value);

      END IF;
     IF upper(column_name) = 'EXAM_SUPERVISOR_TYPE' OR
        column_name is null Then
        IF new_references.exam_supervisor_type <> UPPER(new_references.exam_supervisor_type) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF upper(column_name) = 'PREVIOUS_SESSIONS' OR
        column_name is null Then
        IF  new_references.previous_sessions < 0  AND   new_references.previous_sessions > 9999 Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
END Check_Constraints;


  PROCEDURE Check_Child_Existance as
  BEGIN

    IGS_AS_EXM_INS_SPVSR_PKG.GET_FK_IGS_AS_EXM_SUPRVISOR (
      old_references.person_id
      );

    IGS_AS_EXM_LOC_SPVSR_PKG.GET_FK_IGS_AS_EXM_SUPRVISOR (
      old_references.person_id
      );

    IGS_AS_EXM_SES_VN_SP_PKG.GET_FK_IGS_AS_EXM_SUPRVISOR (
      old_references.person_id
      );

  END Check_Child_Existance;

  FUNCTION   Get_PK_For_Validation (
    x_person_id IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXM_SUPRVISOR_ALL
      WHERE    person_id = x_person_id
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

  PROCEDURE GET_FK_IGS_AS_EXM_SPRVSRTYP (
    x_exam_supervisor_type IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXM_SUPRVISOR_ALL
      WHERE    exam_supervisor_type = x_exam_supervisor_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_ESU_EST_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AS_EXM_SPRVSRTYP;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXM_SUPRVISOR_ALL
      WHERE    responsible_org_unit_cd = x_org_unit_cd
      AND      responsible_ou_start_dt = x_start_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_ESU_OU_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_OR_UNIT;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_EXM_SUPRVISOR_ALL
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_ESU_PE_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_exam_supervisor_type IN VARCHAR2 DEFAULT NULL,
    x_previous_sessions IN NUMBER DEFAULT NULL,
    x_responsible_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_responsible_ou_start_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_person_id,
      x_exam_supervisor_type,
      x_previous_sessions,
      x_responsible_org_unit_cd,
      x_responsible_ou_start_dt,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
IF  Get_PK_For_Validation (
             new_references.person_id
			             ) THEN
Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
Igs_Ge_Msg_Stack.Add;
App_Exception.Raise_Exception;
END IF;

      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
IF  Get_PK_For_Validation (
             new_references.person_id
			             ) THEN
Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
Igs_Ge_Msg_Stack.Add;
App_Exception.Raise_Exception;
END IF;
	        Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	        Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
           Check_Child_Existance;

    END IF;

  END Before_DML;



procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_EXAM_SUPERVISOR_TYPE in VARCHAR2,
  X_PREVIOUS_SESSIONS in NUMBER,
  X_RESPONSIBLE_ORG_UNIT_CD in VARCHAR2,
  X_RESPONSIBLE_OU_START_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_AS_EXM_SUPRVISOR_ALL
      where PERSON_ID = X_PERSON_ID;
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
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
   Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_org_id => igs_ge_gen_003.get_org_id,
 x_comments=>X_COMMENTS,
 x_exam_supervisor_type=>X_EXAM_SUPERVISOR_TYPE,
 x_person_id=>X_PERSON_ID,
 x_previous_sessions=>X_PREVIOUS_SESSIONS,
 x_responsible_org_unit_cd=>X_RESPONSIBLE_ORG_UNIT_CD,
 x_responsible_ou_start_dt=>X_RESPONSIBLE_OU_START_DT,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_AS_EXM_SUPRVISOR_ALL (
    ORG_ID,
    PERSON_ID,
    EXAM_SUPERVISOR_TYPE,
    PREVIOUS_SESSIONS,
    RESPONSIBLE_ORG_UNIT_CD,
    RESPONSIBLE_OU_START_DT,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.EXAM_SUPERVISOR_TYPE,
    NEW_REFERENCES.PREVIOUS_SESSIONS,
    NEW_REFERENCES.RESPONSIBLE_ORG_UNIT_CD,
    NEW_REFERENCES.RESPONSIBLE_OU_START_DT,
    NEW_REFERENCES.COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in  VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXAM_SUPERVISOR_TYPE in VARCHAR2,
  X_PREVIOUS_SESSIONS in NUMBER,
  X_RESPONSIBLE_ORG_UNIT_CD in VARCHAR2,
  X_RESPONSIBLE_OU_START_DT in DATE,
  X_COMMENTS in VARCHAR2
) as
  cursor c1 is select
      EXAM_SUPERVISOR_TYPE,
      PREVIOUS_SESSIONS,
      RESPONSIBLE_ORG_UNIT_CD,
      RESPONSIBLE_OU_START_DT,
      COMMENTS
    from IGS_AS_EXM_SUPRVISOR_ALL
    where ROWID = X_ROWID  for update  nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    Igs_Ge_Msg_Stack.Add;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.EXAM_SUPERVISOR_TYPE = X_EXAM_SUPERVISOR_TYPE)
      AND ((tlinfo.PREVIOUS_SESSIONS = X_PREVIOUS_SESSIONS)
           OR ((tlinfo.PREVIOUS_SESSIONS is null)
               AND (X_PREVIOUS_SESSIONS is null)))
      AND ((tlinfo.RESPONSIBLE_ORG_UNIT_CD = X_RESPONSIBLE_ORG_UNIT_CD)
           OR ((tlinfo.RESPONSIBLE_ORG_UNIT_CD is null)
               AND (X_RESPONSIBLE_ORG_UNIT_CD is null)))
      AND ((tlinfo.RESPONSIBLE_OU_START_DT = X_RESPONSIBLE_OU_START_DT)
           OR ((tlinfo.RESPONSIBLE_OU_START_DT is null)
               AND (X_RESPONSIBLE_OU_START_DT is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in  VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXAM_SUPERVISOR_TYPE in VARCHAR2,
  X_PREVIOUS_SESSIONS in NUMBER,
  X_RESPONSIBLE_ORG_UNIT_CD in VARCHAR2,
  X_RESPONSIBLE_OU_START_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
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
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
   Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_comments=>X_COMMENTS,
  x_exam_supervisor_type=>X_EXAM_SUPERVISOR_TYPE,
  x_person_id=>X_PERSON_ID,
  x_previous_sessions=>X_PREVIOUS_SESSIONS,
  x_responsible_org_unit_cd=>X_RESPONSIBLE_ORG_UNIT_CD,
  x_responsible_ou_start_dt=>X_RESPONSIBLE_OU_START_DT,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  update IGS_AS_EXM_SUPRVISOR_ALL set
    EXAM_SUPERVISOR_TYPE = NEW_REFERENCES.EXAM_SUPERVISOR_TYPE,
    PREVIOUS_SESSIONS = NEW_REFERENCES.PREVIOUS_SESSIONS,
    RESPONSIBLE_ORG_UNIT_CD = NEW_REFERENCES.RESPONSIBLE_ORG_UNIT_CD,
    RESPONSIBLE_OU_START_DT = NEW_REFERENCES.RESPONSIBLE_OU_START_DT,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_EXAM_SUPERVISOR_TYPE in VARCHAR2,
  X_PREVIOUS_SESSIONS in NUMBER,
  X_RESPONSIBLE_ORG_UNIT_CD in VARCHAR2,
  X_RESPONSIBLE_OU_START_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_AS_EXM_SUPRVISOR_ALL
     where PERSON_ID = X_PERSON_ID
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_PERSON_ID,
     X_EXAM_SUPERVISOR_TYPE,
     X_PREVIOUS_SESSIONS,
     X_RESPONSIBLE_ORG_UNIT_CD,
     X_RESPONSIBLE_OU_START_DT,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_EXAM_SUPERVISOR_TYPE,
   X_PREVIOUS_SESSIONS,
   X_RESPONSIBLE_ORG_UNIT_CD,
   X_RESPONSIBLE_OU_START_DT,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2) as
begin
  Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_EXM_SUPRVISOR_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_AS_EXM_SUPRVISOR_PKG;

/
