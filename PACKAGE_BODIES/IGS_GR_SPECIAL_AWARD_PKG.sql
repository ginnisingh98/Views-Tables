--------------------------------------------------------
--  DDL for Package Body IGS_GR_SPECIAL_AWARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_SPECIAL_AWARD_PKG" as
/* $Header: IGSGI16B.pls 120.1 2005/07/06 23:31:02 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_GR_SPECIAL_AWARD_ALL%RowType;
  new_references IGS_GR_SPECIAL_AWARD_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_award_dt IN DATE DEFAULT NULL,
    x_ceremony_announced_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_SPECIAL_AWARD_ALL
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
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.award_cd := x_award_cd;
    new_references.award_dt := x_award_dt;
    new_references.ceremony_announced_ind := x_ceremony_announced_ind;
    new_references.comments := x_comments;
    new_references.org_id := x_org_id;
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
  -- "OSS_TST".trg_spa_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_GR_SPECIAL_AWARD_ALL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	IF p_inserting OR (p_updating AND new_references.award_cd <> old_references.award_cd) THEN
		-- Validate the award is not closed
		IF igs_gr_val_awc.crsp_val_aw_closed(
				new_references.award_cd,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
  				App_Exception.Raise_Exception;
		END IF;
		-- validate the system award type
		IF  IGS_GR_VAL_AWC.GRDP_VAL_AWARD_TYPE(
				new_references.award_cd,
				'SPECIAL',
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS', v_message_name);
  				App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.award_cd = new_references.award_cd)) OR
        ((new_references.award_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_AWD_PKG.Get_PK_For_Validation (
        new_references.award_cd
        ) THEN
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

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
		FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
		APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_award_cd IN VARCHAR2,
    x_award_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_SPECIAL_AWARD_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      award_cd = x_award_cd
      AND      award_dt = x_award_dt
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

  PROCEDURE CHECK_CONSTRAINTS(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) AS
  BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'CEREMONY_ANNOUNCED_IND' THEN
  new_references.CEREMONY_ANNOUNCED_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'AWARD_CD' THEN
  new_references.AWARD_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'CEREMONY_ANNOUNCED_IND' THEN
  new_references.CEREMONY_ANNOUNCED_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'COURSE_CD' THEN
  new_references.COURSE_CD:= COLUMN_VALUE ;
END IF ;

IF upper(Column_name) = 'CEREMONY_ANNOUNCED_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.CEREMONY_ANNOUNCED_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'AWARD_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.AWARD_CD<> upper(new_references.AWARD_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;
END IF ;

IF upper(Column_name) = 'COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.COURSE_CD<> upper(new_references.COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

  END CHECK_CONSTRAINTS;


  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_SPECIAL_AWARD_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_SPA_SCA_FK');
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_STDNT_PS_ATT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_award_dt IN DATE DEFAULT NULL,
    x_ceremony_announced_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_award_cd,
      x_award_dt,
      x_ceremony_announced_ind,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF GET_PK_FOR_VALIDATION(
		    NEW_REFERENCES.person_id,
		    NEW_REFERENCES.course_cd,
		    NEW_REFERENCES.award_cd,
		    NEW_REFERENCES.award_dt
		) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		App_Exception.Raise_Exception;
	END IF;

	check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );

	check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(
		    NEW_REFERENCES.person_id,
		    NEW_REFERENCES.course_cd,
		    NEW_REFERENCES.award_cd,
		    NEW_REFERENCES.award_dt
		) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		App_Exception.Raise_Exception;
	END IF;

	check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN

	check_constraints;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_AWARD_DT in DATE,
  X_CEREMONY_ANNOUNCED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_GR_SPECIAL_AWARD_ALL
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and AWARD_CD = X_AWARD_CD
      and AWARD_DT = X_AWARD_DT;
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
    app_exception.raise_exception;
  end if;

 Before_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_course_cd => X_COURSE_CD,
    x_award_cd => X_AWARD_CD,
    x_award_dt => X_AWARD_DT,
    x_ceremony_announced_ind => NVL(X_CEREMONY_ANNOUNCED_IND, 'N'),
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN,
     x_org_id => igs_ge_gen_003.get_org_id
  );

   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_GR_SPECIAL_AWARD_ALL (
    PERSON_ID,
    COURSE_CD,
    AWARD_CD,
    AWARD_DT,
    CEREMONY_ANNOUNCED_IND,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.AWARD_CD,
    NEW_REFERENCES.AWARD_DT,
    NEW_REFERENCES.CEREMONY_ANNOUNCED_IND,
    NEW_REFERENCES.COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
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
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_AWARD_DT in DATE,
  X_CEREMONY_ANNOUNCED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select
      CEREMONY_ANNOUNCED_IND,
      COMMENTS
    from IGS_GR_SPECIAL_AWARD_ALL
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.CEREMONY_ANNOUNCED_IND = X_CEREMONY_ANNOUNCED_IND)
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_AWARD_DT in DATE,
  X_CEREMONY_ANNOUNCED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
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
    app_exception.raise_exception;
  end if;

 Before_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_course_cd => X_COURSE_CD,
    x_award_cd => X_AWARD_CD,
    x_award_dt => X_AWARD_DT,
    x_ceremony_announced_ind => X_CEREMONY_ANNOUNCED_IND,
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
 update IGS_GR_SPECIAL_AWARD_ALL set
    CEREMONY_ANNOUNCED_IND = NEW_REFERENCES.CEREMONY_ANNOUNCED_IND,
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
  X_COURSE_CD in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_AWARD_DT in DATE,
  X_CEREMONY_ANNOUNCED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_GR_SPECIAL_AWARD_ALL
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and AWARD_CD = X_AWARD_CD
     and AWARD_DT = X_AWARD_DT
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
     X_AWARD_CD,
     X_AWARD_DT,
     X_CEREMONY_ANNOUNCED_IND,
     X_COMMENTS,
     X_MODE,
      x_org_id
);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_AWARD_CD,
   X_AWARD_DT,
   X_CEREMONY_ANNOUNCED_IND,
   X_COMMENTS,
   X_MODE
);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
begin

   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_GR_SPECIAL_AWARD_ALL
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


end DELETE_ROW;

end IGS_GR_SPECIAL_AWARD_PKG;

/
