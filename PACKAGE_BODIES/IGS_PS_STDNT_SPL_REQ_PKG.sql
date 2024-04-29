--------------------------------------------------------
--  DDL for Package Body IGS_PS_STDNT_SPL_REQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_STDNT_SPL_REQ_PKG" as
/* $Header: IGSPI66B.pls 120.1 2005/07/04 00:19:45 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PS_STDNT_SPL_REQ%RowType;
  new_references IGS_PS_STDNT_SPL_REQ%RowType;

PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_special_requirement_cd IN VARCHAR2 DEFAULT NULL,
    x_completed_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_reference IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_STDNT_SPL_REQ
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
    new_references.special_requirement_cd := x_special_requirement_cd;
    new_references.completed_dt := x_completed_dt;
    new_references.expiry_dt := x_expiry_dt;
    new_references.reference := x_reference;
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

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate Student IGS_PS_COURSE Special Requirement
	-- Validate the Student IGS_PS_COURSE Attempt is active
	IF p_inserting OR p_updating THEN
		IF  IGS_EN_VAL_SCSR.enrp_val_scsr_scas(
				new_references.person_id,
				new_references.course_cd,
				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_deleting THEN
		IF  IGS_EN_VAL_SCSR.enrp_val_scsr_scas(
				old_references.person_id,
				old_references.course_cd,
				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the completed date
	IF p_inserting THEN
		IF  IGS_EN_VAL_SCSR.enrp_val_scsr_cmp_dt(
				new_references.completed_dt,
				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the expiry date
	IF p_inserting OR p_updating THEN
		IF new_references.expiry_dt IS NOT NULL THEN
			IF  IGS_EN_VAL_SCSR.enrp_val_scsr_exp_dt(
					new_references.completed_dt,
					new_references.expiry_dt,
					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;
	-- Validate the special requirement code is not closed
	IF p_inserting THEN
		IF  IGS_EN_VAL_SCSR.enrp_val_srq_closed(
				new_references.special_requirement_cd,
				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

 PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate the student IGS_PS_COURSE special requirement dates
	IF p_inserting OR p_updating THEN
  		-- Validate the Student course Special Requirement dates
  		IF IGS_EN_VAL_SCSR.enrp_val_scsr_dates(
  				new_references.person_id,
  				new_references.course_cd,
  				new_references.special_requirement_cd,
  				new_references.completed_dt,
  				new_references.expiry_dt,
  				v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS', v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
  		END IF;
	END IF;

  END AfterRowInsertUpdate2;

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN

 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'COURSE_CD' then
     new_references.course_cd := column_value;
 ELSIF upper(Column_name) = 'SPECIAL_REQUIREMENT_CD' then
     new_references.special_requirement_cd := column_value;
 ELSIF upper(Column_name) = 'REFERENCE' then
     new_references.reference := column_value;
 END IF;

IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.course_cd <> UPPER(new_references.course_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'SPECIAL_REQUIREMENT_CD' OR
     column_name is null Then
     IF new_references.special_requirement_cd <> UPPER(new_references.special_requirement_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'REFERENCE' OR
     column_name is null Then
     IF new_references.reference <> UPPER(new_references.reference) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
END check_constraints;

PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd
        ) THEN
		    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.special_requirement_cd = new_references.special_requirement_cd)) OR
        ((new_references.special_requirement_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GE_SPL_REQ_PKG.Get_PK_For_Validation (
        new_references.special_requirement_cd
        ) THEN
		    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		    IGS_GE_MSG_STACK.ADD;
		    App_Exception.Raise_Exception;
	END IF;
    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_special_requirement_cd IN VARCHAR2,
    x_completed_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_STDNT_SPL_REQ
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      special_requirement_cd = x_special_requirement_cd
      AND      completed_dt = x_completed_dt
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

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_STDNT_SPL_REQ
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_SCSR_SCA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_STDNT_PS_ATT;

  PROCEDURE GET_FK_IGS_GE_SPL_REQ (
    x_special_requirement_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_STDNT_SPL_REQ
      WHERE    special_requirement_cd = x_special_requirement_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_SCSR_SRQ_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GE_SPL_REQ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_special_requirement_cd IN VARCHAR2 DEFAULT NULL,
    x_completed_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_reference IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_special_requirement_cd,
      x_completed_dt,
      x_expiry_dt,
      x_reference,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
			    new_references.person_id,
			    new_references.course_cd,
			    new_references.special_requirement_cd,
			    new_references.completed_dt
					  ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
       Check_Constraints;
       Check_Parent_Existance;
 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
	BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
			    new_references.person_id,
			    new_references.course_cd,
			    new_references.special_requirement_cd,
			    new_references.completed_dt
					  ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE );

    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SPECIAL_REQUIREMENT_CD in VARCHAR2,
  X_COMPLETED_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_EXPIRY_DT in DATE,
  X_REFERENCE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_PS_STDNT_SPL_REQ
      where PERSON_ID = X_PERSON_ID
      and SPECIAL_REQUIREMENT_CD = X_SPECIAL_REQUIREMENT_CD
      and COMPLETED_DT = X_COMPLETED_DT
      and COURSE_CD = X_COURSE_CD;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
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
  x_person_id => X_PERSON_ID,
  x_course_cd => X_COURSE_CD,
  x_special_requirement_cd => X_SPECIAL_REQUIREMENT_CD,
  x_completed_dt => X_COMPLETED_DT,
  x_expiry_dt => X_EXPIRY_DT,
  x_reference => X_REFERENCE,
  x_comments => X_COMMENTS,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );


  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_PS_STDNT_SPL_REQ (
    PERSON_ID,
    COURSE_CD,
    SPECIAL_REQUIREMENT_CD,
    COMPLETED_DT,
    EXPIRY_DT,
    REFERENCE,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.SPECIAL_REQUIREMENT_CD,
    NEW_REFERENCES.COMPLETED_DT,
    NEW_REFERENCES.EXPIRY_DT,
    NEW_REFERENCES.REFERENCE,
    NEW_REFERENCES.COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  After_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SPECIAL_REQUIREMENT_CD in VARCHAR2,
  X_COMPLETED_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_EXPIRY_DT in DATE,
  X_REFERENCE in VARCHAR2,
  X_COMMENTS in VARCHAR2
) as
  cursor c1 is select
      EXPIRY_DT,
      REFERENCE,
      COMMENTS
    from IGS_PS_STDNT_SPL_REQ
    where ROWID = X_ROWID
    for update nowait;
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

      if ( ((tlinfo.EXPIRY_DT = X_EXPIRY_DT)
           OR ((tlinfo.EXPIRY_DT is null)
               AND (X_EXPIRY_DT is null)))
      AND ((tlinfo.REFERENCE = X_REFERENCE)
           OR ((tlinfo.REFERENCE is null)
               AND (X_REFERENCE is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
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
  X_ROWID IN VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SPECIAL_REQUIREMENT_CD in VARCHAR2,
  X_COMPLETED_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_EXPIRY_DT in DATE,
  X_REFERENCE in VARCHAR2,
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
  elsif (X_MODE IN ('R', 'S')) then
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

  Before_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID,
  x_person_id =>X_PERSON_ID,
  x_course_cd => X_COURSE_CD,
  x_special_requirement_cd => X_SPECIAL_REQUIREMENT_CD,
  x_completed_dt => X_COMPLETED_DT,
  x_expiry_dt => X_EXPIRY_DT,
  x_reference => X_REFERENCE,
  x_comments => X_COMMENTS,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_PS_STDNT_SPL_REQ set
    EXPIRY_DT = NEW_REFERENCES.EXPIRY_DT,
    REFERENCE = NEW_REFERENCES.REFERENCE,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    where ROWID = X_ROWID
  ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

  After_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID
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

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SPECIAL_REQUIREMENT_CD in VARCHAR2,
  X_COMPLETED_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_EXPIRY_DT in DATE,
  X_REFERENCE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_PS_STDNT_SPL_REQ
     where PERSON_ID = X_PERSON_ID
     and SPECIAL_REQUIREMENT_CD = X_SPECIAL_REQUIREMENT_CD
     and COMPLETED_DT = X_COMPLETED_DT
     and COURSE_CD = X_COURSE_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_SPECIAL_REQUIREMENT_CD,
     X_COMPLETED_DT,
     X_COURSE_CD,
     X_EXPIRY_DT,
     X_REFERENCE,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_SPECIAL_REQUIREMENT_CD,
   X_COMPLETED_DT,
   X_COURSE_CD,
   X_EXPIRY_DT,
   X_REFERENCE,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) as
begin
  Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_PS_STDNT_SPL_REQ
    where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_PS_STDNT_SPL_REQ_PKG;

/
