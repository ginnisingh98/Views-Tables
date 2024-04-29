--------------------------------------------------------
--  DDL for Package Body IGS_PS_NOTE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_NOTE_TYPE_PKG" AS
 /* $Header: IGSPI48B.pls 120.3 2006/01/27 02:51:50 sarakshi ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_NOTE_TYPE_ALL%RowType;
  new_references IGS_PS_NOTE_TYPE_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_crs_note_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id In NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_NOTE_TYPE_ALL
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
    new_references.crs_note_type := x_crs_note_type;
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
    new_references.org_id := x_org_id;
  END Set_Column_Values;

  PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
  ) IS
  BEGIN
	IF column_name is null THEN
	   NULL;
	ELSIF upper(column_name) = 'CRS_NOTE_TYPE' THEN
	   new_references.crs_note_type := column_value;
	END IF;
	IF upper(column_name)= 'CRS_NOTE_TYPE' OR
		column_name is null THEN
		IF new_references.crs_note_type<> UPPER(new_references.crs_note_type)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      		IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
 END Check_Constraints;

 PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PS_OFR_NOTE_PKG.GET_FK_IGS_PS_NOTE_TYPE (
      old_references.crs_note_type
      );

    IGS_PS_OFR_OPT_NOTE_PKG.GET_FK_IGS_PS_NOTE_TYPE (
      old_references.crs_note_type      );

    IGS_PS_OFR_PAT_NOTE_PKG.GET_FK_IGS_PS_NOTE_TYPE (
      old_references.crs_note_type
      );

    IGS_PS_VER_NOTE_PKG.GET_FK_IGS_PS_NOTE_TYPE (
      old_references.crs_note_type
      );

    IGS_PS_UNIT_OFR_NOTE_PKG.GET_FK_IGS_PS_NOTE_TYPE (
      old_references.crs_note_type
      );

    IGS_PS_UNT_OFR_OPT_N_PKG.GET_FK_IGS_PS_NOTE_TYPE (
      old_references.crs_note_type
      );

    IGS_PS_UNT_OFR_PAT_N_PKG.GET_FK_IGS_PS_NOTE_TYPE (
      old_references.crs_note_type
      );

    IGS_EN_UNIT_SET_NOTE_PKG.GET_FK_IGS_PS_NOTE_TYPE (
      old_references.crs_note_type
      );

    IGS_PS_UNIT_VER_NOTE_PKG.GET_FK_IGS_PS_NOTE_TYPE (
      old_references.crs_note_type
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_crs_note_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_NOTE_TYPE_ALL
      WHERE    crs_note_type = x_crs_note_type
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
    x_crs_note_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
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
      x_crs_note_type,
      x_description,
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
    		new_references.crs_note_type
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

      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 IF Get_PK_For_Validation(
    		    		new_references.crs_note_type
   	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  ) AS
    cursor C is select ROWID from IGS_PS_NOTE_TYPE_ALL
      where CRS_NOTE_TYPE = X_CRS_NOTE_TYPE;
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

  Before_DML (p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_crs_note_type => X_CRS_NOTE_TYPE,
    x_description => X_DESCRIPTION,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
);

  insert into IGS_PS_NOTE_TYPE_ALL (
    CRS_NOTE_TYPE,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.CRS_NOTE_TYPE,
    NEW_REFERENCES.DESCRIPTION,
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
After_DML (p_action => 'INSERT',
     x_rowid => X_ROWID
   );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION
    from IGS_PS_NOTE_TYPE_ALL
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
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
  X_CRS_NOTE_TYPE in VARCHAR2,
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

  Before_DML (p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_crs_note_type => X_CRS_NOTE_TYPE,
    x_description => X_DESCRIPTION,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
);

  update IGS_PS_NOTE_TYPE_ALL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (p_action => 'UPDATE',
     x_rowid => X_ROWID
   );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  ) AS
  cursor c1 is select rowid from IGS_PS_NOTE_TYPE_ALL
     where CRS_NOTE_TYPE = X_CRS_NOTE_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_CRS_NOTE_TYPE,
     X_DESCRIPTION,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_CRS_NOTE_TYPE,
   X_DESCRIPTION,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
X_ROWID in VARCHAR2
) AS
begin
  Before_DML (p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_PS_NOTE_TYPE_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (p_action => 'DELETE',
     x_rowid => X_ROWID
   );
end DELETE_ROW;


  PROCEDURE LOAD_ROW (
    x_crs_note_type      IN VARCHAR2,
    x_description        IN VARCHAR2,
    x_owner              IN VARCHAR2,
    x_last_update_date   IN VARCHAR2,
    x_custom_mode        IN VARCHAR2  ) IS

    f_luby    number;  -- entity owner in file
    f_ludate  date;    -- entity update date in file
    db_luby   number;  -- entity owner in db
    db_ludate date;    -- entity update date in db

    CURSOR c_igs_ps_note_type_all(cp_crs_note_type  VARCHAR2) IS
    SELECT last_updated_by, last_update_date
    FROM   igs_ps_note_type_all
    WHERE  crs_note_type = cp_crs_note_type;


  BEGIN

    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);


    OPEN  c_igs_ps_note_type_all(x_crs_note_type);
    FETCH c_igs_ps_note_type_all INTO db_luby, db_ludate;
    IF c_igs_ps_note_type_all%FOUND THEN
      IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
				    db_ludate, x_custom_mode)) THEN


	UPDATE IGS_PS_NOTE_TYPE_ALL SET
	  description = x_description,
	  last_updated_by = f_luby,
	  last_update_date = f_ludate,
	  last_update_login = 0
	WHERE crs_note_type = x_crs_note_type;

      END IF;
    ELSE
      INSERT INTO IGS_PS_NOTE_TYPE_ALL
      (
	CRS_NOTE_TYPE,
	DESCRIPTION,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
      )
      VALUES
      (
	x_crs_note_type,
	x_description,
	f_luby,
	f_ludate,
	f_luby,
	f_ludate,
	0
      );
    END IF;
    CLOSE c_igs_ps_note_type_all;

  END LOAD_ROW;


  PROCEDURE LOAD_SEED_ROW (
    x_upload_mode        IN VARCHAR2,
    x_crs_note_type      IN VARCHAR2,
    x_description        IN VARCHAR2,
    x_owner              IN VARCHAR2,
    x_last_update_date   IN VARCHAR2,
    x_custom_mode        IN VARCHAR2  ) IS

  BEGIN

	 IF (x_upload_mode = 'NLS') THEN
	   NULL; --For translated record call Table_pkg.TRANSLATE_ROW
         ELSE
	   igs_ps_note_type_pkg.load_row(
	      x_crs_note_type       => x_crs_note_type ,
	      x_description         => x_description ,
	      x_owner               => x_owner ,
	      x_last_update_date    => x_last_update_date ,
	      x_custom_mode	    => x_custom_mode );
	 END IF;

  END LOAD_SEED_ROW;


end IGS_PS_NOTE_TYPE_PKG;

/
