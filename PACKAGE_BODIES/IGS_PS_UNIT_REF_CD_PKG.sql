--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNIT_REF_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNIT_REF_CD_PKG" as
/* $Header: IGSPI88B.pls 115.10 2003/05/09 06:51:56 sarakshi ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_UNIT_REF_CD%RowType;
  new_references IGS_PS_UNIT_REF_CD%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_reference_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_UNIT_REF_CD
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
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.reference_cd_type := x_reference_cd_type;
    new_references.reference_cd := x_reference_cd;
    new_references.description := x_description;
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
	v_unit_cd		IGS_PS_UNIT_REF_CD.unit_cd%TYPE;
	v_version_number	IGS_PS_UNIT_REF_CD.version_number%TYPE;
	v_description	IGS_PS_UNIT_REF_CD.description%TYPE;
	v_message_name	Varchar2(20);
  BEGIN
	-- Set variables.
	IF p_deleting THEN
		v_unit_cd := old_references.unit_cd;
		v_version_number := old_references.version_number;
	ELSE -- p_inserting or p_updating
		v_unit_cd := new_references.unit_cd;
		v_version_number := new_references.version_number;
	END IF;
	-- Validate the insert/update/delete.
	IF  IGS_PS_VAL_UNIT.crsp_val_iud_uv_dtl (
			v_unit_cd,
			v_version_number,
v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	-- Validate reference code type.  Referenece code type is not updateable.
	IF p_inserting THEN
	-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_URC.crsp_val_ref_cd_type
		IF IGS_PS_VAL_CRFC.crsp_val_ref_cd_type(
				new_references.reference_cd_type,
v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Create history record.
	IF p_updating THEN
		IF NVL(old_references.description,'null') <> NVL(new_references.description,'null') THEN
			SELECT	DECODE(NVL(old_references.description,'NULL'),NVL(new_references.description,'NULL'),
						NULL,old_references.description)
			INTO	v_description
			FROM	dual;
			IGS_PS_GEN_005.CRSP_INS_URC_HIST(
				old_references.unit_cd,
				old_references.version_number,
				old_references.reference_cd_type,
				old_references.reference_cd,
				old_references.last_update_date,
				new_references.last_update_date,
				old_references.last_updated_by,
				v_description);
		END IF;
	END IF;
	-- Create history record on delete
	IF p_deleting THEN
	  IF igs_ps_val_atl.chk_mandatory_ref_cd(old_references.reference_cd_type) THEN
	      Fnd_Message.Set_Name ('IGS', 'IGS_PS_REF_CD_MANDATORY');
              IGS_GE_MSG_STACK.ADD;
	      App_Exception.Raise_Exception;
	   END IF;
	   IGS_PS_GEN_005.CRSP_INS_URC_HIST(
			old_references.unit_cd,
			old_references.version_number,
			old_references.reference_cd_type,
			old_references.reference_cd,
			old_references.last_update_date,
			SYSDATE,
			old_references.last_updated_by,
			old_references.description);
	END IF;


  END BeforeRowInsertUpdateDelete1;

PROCEDURE Check_Constraints(
				Column_Name 	IN	VARCHAR2	DEFAULT NULL,
				Column_Value 	IN	VARCHAR2	DEFAULT NULL)
AS
BEGIN

	IF Column_Name IS NULL Then
		NULL;
	ELSIF Upper(Column_Name)='REFERENCE_CD' Then
		New_References.Reference_Cd := Column_Value;
	ELSIF Upper(Column_Name)='REFERENCE_CD_TYPE' Then
		New_References.Reference_Cd_Type := Column_Value;
	ELSIF Upper(Column_Name)='UNIT_CD' Then
		New_References.Unit_Cd := Column_Value;
	END IF;

	IF Upper(Column_Name)='REFERENCE_CD' OR Column_Name IS NULL Then
		IF New_References.Reference_Cd <> UPPER(New_References.Reference_Cd) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='REFERENCE_CD_TYPE' OR Column_Name IS NULL Then
		IF New_References.Reference_Cd_Type <> UPPER(New_References.Reference_Cd_Type) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;


	IF Upper(Column_Name)='UNIT_CD' OR Column_Name IS NULL Then
		IF New_References.Unit_Cd <> UPPER(New_References.Unit_CD) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

END Check_Constraints;

PROCEDURE Check_Uniqueness AS
BEGIN
	IF Get_UK_For_Validation (
	    New_References.unit_cd,
	    New_References.version_number,
    	    New_References.reference_cd_type) THEN
		      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
	END IF;
END Check_Uniqueness;


FUNCTION Get_UK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_reference_cd_type IN VARCHAR2
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_REF_CD
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      reference_cd_type = x_reference_cd_type
	AND 	   (l_rowid IS NULL OR rowid <> l_rowid)
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

END Get_UK_For_Validation;


  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   smvk           31-Jan-2003     Bug # 2532094. Added the foreign key checking with igs_ge_ref_cd.
  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR cur_reference_cd_chk(cp_reference_cd_type igs_ge_ref_cd_type_all.reference_cd_type%TYPE) IS
  SELECT 'X'
  FROM   igs_ge_ref_cd_type_all
  WHERE  restricted_flag='Y'
  AND    reference_cd_type=cp_reference_cd_type;
  l_var  VARCHAR2(1);

  BEGIN

    IF (((old_references.reference_cd_type = new_references.reference_cd_type)) OR
        ((new_references.reference_cd_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GE_REF_CD_TYPE_PKG.Get_PK_For_Validation (
        new_references.reference_cd_type) THEN
				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;


    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_UNIT_VER_PKG.Get_PK_For_Validation (
        new_references.unit_cd,
        new_references.version_number) THEN
				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;


    END IF;

    OPEN cur_reference_cd_chk(new_references.reference_cd_type);
    FETCH cur_reference_cd_chk INTO l_var;
    IF cur_reference_cd_chk%FOUND THEN
      IF (((old_references.reference_cd_type = new_references.reference_cd_type) AND
           (old_references.reference_cd = new_references.reference_cd)) OR
          ((new_references.reference_cd_type IS NULL) OR
           (new_references.reference_cd IS NULL))) THEN
  	 NULL;
      ELSIF NOT igs_ge_ref_cd_pkg.get_uk_for_validation (
                          new_references.reference_cd_type,
                          new_references.reference_cd
          )  THEN
          Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
    END IF;
    CLOSE cur_reference_cd_chk;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_reference_cd_type IN VARCHAR2,
    x_reference_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_REF_CD
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      reference_cd_type = x_reference_cd_type
      AND      reference_cd = x_reference_cd
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

  PROCEDURE GET_FK_IGS_GE_REF_CD_TYPE (
    x_reference_cd_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_REF_CD
      WHERE    reference_cd_type = x_reference_cd_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_URC_RCT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GE_REF_CD_TYPE;

   PROCEDURE get_ufk_igs_ge_ref_cd (
    x_reference_cd_type IN VARCHAR2,
    x_reference_cd IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :sarakshi
  Date Created By :8-May-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_unit_ref_cd
      WHERE    reference_cd_type = x_reference_cd_type
      AND      reference_cd = x_reference_cd ;

    lv_rowid cur_rowid%ROWTYPE;

 BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_URC_RC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ge_ref_cd;


  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_REF_CD
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_URC_UV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_VER;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_reference_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
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
      x_unit_cd,
      x_version_number,
      x_reference_cd_type,
      x_reference_cd,
      x_description,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	   IF Get_PK_For_Validation (New_References.unit_cd,
						New_References.version_number,
						New_References.reference_cd_type,
						New_References.reference_cd) THEN
		      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
	   END IF;
	   Check_Constraints;
	   Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
	   Check_Constraints;
	   Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
   ELSIF (p_action = 'VALIDATE_INSERT') THEN
	   IF Get_PK_For_Validation (New_References.unit_cd,
						New_References.version_number,
						New_References.reference_cd_type,
						New_References.reference_cd) THEN
		      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
	   END IF;
	   Check_Constraints;
 	   Check_Uniqueness;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	   Check_Constraints;
	   Check_Uniqueness;

   END IF;

  l_rowid := NULL;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

l_rowid:=NULL;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_REFERENCE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_UNIT_REF_CD
      where UNIT_CD = X_UNIT_CD
      and REFERENCE_CD_TYPE = X_REFERENCE_CD_TYPE
      and VERSION_NUMBER = X_VERSION_NUMBER
      and REFERENCE_CD = X_REFERENCE_CD;
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
  x_unit_cd => X_UNIT_CD,
  x_version_number => X_VERSION_NUMBER,
  x_reference_cd_type => X_REFERENCE_CD_TYPE,
  x_reference_cd => X_REFERENCE_CD,
  x_description => X_DESCRIPTION,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_PS_UNIT_REF_CD (
    UNIT_CD,
    VERSION_NUMBER,
    REFERENCE_CD_TYPE,
    REFERENCE_CD,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.REFERENCE_CD_TYPE,
    NEW_REFERENCES.REFERENCE_CD,
    NEW_REFERENCES.DESCRIPTION,
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
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_REFERENCE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION
    from IGS_PS_UNIT_REF_CD
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

      if ( ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
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
  X_UNIT_CD in VARCHAR2,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_REFERENCE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
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
  x_unit_cd => X_UNIT_CD,
  x_version_number => X_VERSION_NUMBER,
  x_reference_cd_type => X_REFERENCE_CD_TYPE,
  x_reference_cd => X_REFERENCE_CD,
  x_description => X_DESCRIPTION,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_PS_UNIT_REF_CD set
    UNIT_CD = NEW_REFERENCES.UNIT_CD,
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    REFERENCE_CD_TYPE = NEW_REFERENCES.REFERENCE_CD_TYPE,
    REFERENCE_CD= NEW_REFERENCES.REFERENCE_CD,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
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
  X_UNIT_CD in VARCHAR2,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_REFERENCE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PS_UNIT_REF_CD
     where UNIT_CD = X_UNIT_CD
     and REFERENCE_CD_TYPE = X_REFERENCE_CD_TYPE
     and VERSION_NUMBER = X_VERSION_NUMBER
     and REFERENCE_CD = X_REFERENCE_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_UNIT_CD,
     X_REFERENCE_CD_TYPE,
     X_VERSION_NUMBER,
     X_REFERENCE_CD,
     X_DESCRIPTION,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_CD,
   X_REFERENCE_CD_TYPE,
   X_VERSION_NUMBER,
   X_REFERENCE_CD,
   X_DESCRIPTION,
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
  delete from IGS_PS_UNIT_REF_CD
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
    );

end DELETE_ROW;

end IGS_PS_UNIT_REF_CD_PKG;

/
