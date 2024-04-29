--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNIT_INT_LVL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNIT_INT_LVL_PKG" as
/* $Header: IGSPI79B.pls 115.5 2002/11/29 02:38:23 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_UNIT_INT_LVL%RowType;
  new_references IGS_PS_UNIT_INT_LVL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_int_course_level_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_weftsu_factor IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_UNIT_INT_LVL
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
    new_references.unit_int_course_level_cd := x_unit_int_course_level_cd;
    new_references.description := x_description;
    new_references.weftsu_factor := x_weftsu_factor;
    new_references.closed_ind := x_closed_ind;
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
	v_description		IGS_PS_UNIT_INT_LVL.description%TYPE		DEFAULT NULL;
	v_weftsu_factor		IGS_PS_UNIT_INT_LVL.weftsu_factor%TYPE	DEFAULT NULL;
	v_closed_ind		IGS_PS_UNIT_INT_LVL.closed_ind%TYPE		DEFAULT NULL;

	x_rowid		VARCHAR2(25);
	l_org_id        NUMBER(15);
	CURSOR SPUIH_CUR IS
		SELECT Rowid
		FROM IGS_PS_UNT_INLV_HIST
		WHERE  unit_int_course_level_cd = old_references.unit_int_course_level_cd;

  BEGIN
	IF p_updating THEN
		IF old_references.description <> new_references.description OR
				nvl(old_references.weftsu_factor,999999) <> nvl(new_references.weftsu_factor,999999) OR
				old_references.closed_ind <> new_references.closed_ind THEN
			IF old_references.description <> new_references.description THEN
				v_description := old_references.description;
			END IF;
			IF nvl(old_references.weftsu_factor,999999) <> nvl(new_references.weftsu_factor,999999) THEN
				v_weftsu_factor := old_references.weftsu_factor;
			END IF;
			IF old_references.closed_ind <> new_references.closed_ind THEN
				v_closed_ind := old_references.closed_ind;
			END IF;


	BEGIN

                        l_org_id :=igs_ge_gen_003.get_org_id;

			IGS_PS_UNT_INLV_HIST_PKG.Insert_Row(
					 X_ROWID                        =>      x_rowid,
					 X_UNIT_INT_COURSE_LEVEL_CD     =>	old_references.unit_int_course_level_cd,
					 X_HIST_START_DT                =>	old_references.last_update_date,
					 X_HIST_END_DT                  =>	new_references.last_update_date,
					 X_HIST_WHO                     =>	old_references.last_updated_by,
					 X_DESCRIPTION                  =>	v_description,
					 X_WEFTSU_FACTOR                =>	v_weftsu_factor,
					 X_CLOSED_IND                   =>	v_closed_ind,
					 X_MODE                         =>      'R',
					 X_ORG_ID                       =>       l_org_id);

  	END;

	END IF;
END IF;
	IF p_deleting THEN
		-- Delete IGS_PS_UNT_INLV_HIST records if the IGS_PS_UNIT_INT_LVL
		-- is deleted.
	BEGIN
		FOR SPUIH_Rec IN SPUIH_CUR
		Loop
			IGS_PS_UNT_INLV_HIST_PKG.Delete_Row(X_ROWID=>SPUIH_Rec.Rowid);
		End Loop;
	END;
	END IF;


  END BeforeRowInsertUpdateDelete1;

PROCEDURE Check_Constraints(
				Column_Name 	IN	VARCHAR2	DEFAULT NULL,
				Column_Value 	IN	VARCHAR2	DEFAULT NULL)
AS
BEGIN

	IF Column_Name IS NULL Then
		NULL;
	ELSIF Upper(Column_Name)='WEFTSU_FACTOR' Then
		New_References.weftsu_factor := igs_ge_number.to_num(Column_Value);
	ELSIF Upper(Column_Name)='CLOSED_IND' Then
		New_References.closed_ind := Column_Value;
	ELSIF Upper(Column_Name)='UNIT_INT_COURSE_LEVEL_CD' Then
		New_References.unit_int_course_level_cd := Column_Value;
	END IF;

	IF Upper(Column_Name)='WEFTSU_FACTOR' OR Column_Name IS NULL Then
		IF New_References.weftsu_factor < 0 AND  New_References.weftsu_factor > 1.80 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='CLOSED_IND' OR Column_Name IS NULL Then
		IF new_references.closed_ind NOT IN ( 'Y' , 'N' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;


	IF Upper(Column_Name)='UNIT_INT_COURSE_LEVEL_CD' OR Column_Name IS NULL Then
		IF New_References.Unit_Int_Course_Level_Cd <> UPPER(New_References.Unit_Int_Course_Level_Cd) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

END Check_Constraints;


  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_SBMAO_FN_UITT_PKG.GET_FK_IGS_PS_UNIT_INT_LVL (
      old_references.unit_int_course_level_cd
      );

    IGS_PS_UNIT_VER_PKG.GET_FK_IGS_PS_UNIT_INT_LVL (
      old_references.unit_int_course_level_cd
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_int_course_level_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_INT_LVL
      WHERE    unit_int_course_level_cd = x_unit_int_course_level_cd
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
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_int_course_level_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_weftsu_factor IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
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
      x_unit_int_course_level_cd,
      x_description,
      x_weftsu_factor,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	  IF Get_PK_For_Validation (New_References.unit_int_course_level_cd) THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
	   END IF;
	   Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
      Check_Child_Existance;
	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	   IF Get_PK_For_Validation (New_References.unit_int_course_level_cd) THEN
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
  BEGIN

    l_rowid := x_rowid;


  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_WEFTSU_FACTOR in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_UNIT_INT_LVL
      where UNIT_INT_COURSE_LEVEL_CD = X_UNIT_INT_COURSE_LEVEL_CD;
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
  x_unit_int_course_level_cd => X_UNIT_INT_COURSE_LEVEL_CD,
  x_description => X_DESCRIPTION,
  x_weftsu_factor => X_WEFTSU_FACTOR,
  x_closed_ind => NVL(X_CLOSED_IND,'N'),
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_PS_UNIT_INT_LVL (
    UNIT_INT_COURSE_LEVEL_CD,
    DESCRIPTION,
    WEFTSU_FACTOR,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.UNIT_INT_COURSE_LEVEL_CD,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.WEFTSU_FACTOR,
    NEW_REFERENCES.CLOSED_IND,
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
 After_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID
    );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_WEFTSU_FACTOR in NUMBER,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      WEFTSU_FACTOR,
      CLOSED_IND
    from IGS_PS_UNIT_INT_LVL
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.WEFTSU_FACTOR = X_WEFTSU_FACTOR)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_WEFTSU_FACTOR in NUMBER,
  X_CLOSED_IND in VARCHAR2,
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

  Before_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID,
  x_unit_int_course_level_cd => X_UNIT_INT_COURSE_LEVEL_CD,
  x_description => X_DESCRIPTION,
  x_weftsu_factor => X_WEFTSU_FACTOR,
  x_closed_ind => X_CLOSED_IND,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_PS_UNIT_INT_LVL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    WEFTSU_FACTOR = NEW_REFERENCES.WEFTSU_FACTOR,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID
    );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_WEFTSU_FACTOR in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PS_UNIT_INT_LVL
     where UNIT_INT_COURSE_LEVEL_CD = X_UNIT_INT_COURSE_LEVEL_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_UNIT_INT_COURSE_LEVEL_CD,
     X_DESCRIPTION,
     X_WEFTSU_FACTOR,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_INT_COURSE_LEVEL_CD,
   X_DESCRIPTION,
   X_WEFTSU_FACTOR,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
  Before_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
    );
  delete from IGS_PS_UNIT_INT_LVL
    where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
    );

end DELETE_ROW;

end IGS_PS_UNIT_INT_LVL_PKG;

/
