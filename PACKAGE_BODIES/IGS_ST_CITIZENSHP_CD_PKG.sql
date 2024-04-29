--------------------------------------------------------
--  DDL for Package Body IGS_ST_CITIZENSHP_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_CITIZENSHP_CD_PKG" as
 /* $Header: IGSVI01B.pls 115.7 2002/12/24 05:45:22 npalanis ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_ST_CITIZENSHP_CD%RowType;
  new_references IGS_ST_CITIZENSHP_CD%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_citizenship_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_citizenship_cd IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_ST_CITIZENSHP_CD
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
    new_references.citizenship_cd := x_citizenship_cd;
    new_references.govt_citizenship_cd := x_govt_citizenship_cd;
    new_references.description := x_description;
    new_references.closed_ind := x_closed_ind;
    new_references.notes := x_notes;
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
	v_message_name	varchar2(30);
  BEGIN

	-- Validate GOVERNMENT CITIZENSHIP CODE.
	IF p_inserting OR ((old_references.govt_citizenship_cd <> new_references.govt_citizenship_cd) OR
			 (new_references.closed_ind = 'Y' AND new_references.closed_ind = 'N')) THEN
		IF IGS_EN_VAL_CIC.enrp_val_cic_govt (
				new_references.govt_citizenship_cd,
				v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS',v_message_name);
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
		END IF;
	END IF;

  END BeforeRowInsertUpdate1;

PROCEDURE   Check_Constraints (
                 Column_Name     IN   VARCHAR2    DEFAULT NULL ,
                 Column_Value    IN   VARCHAR2    DEFAULT NULL
                                )  as
Begin

IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'CLOSED_IND' THEN
  new_references.CLOSED_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'CITIZENSHIP_CD' THEN
  new_references.CITIZENSHIP_CD:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'CLOSED_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.CLOSED_IND<> upper(new_references.CLOSED_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.CLOSED_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'CITIZENSHIP_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.CITIZENSHIP_CD<> upper(new_references.CITIZENSHIP_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

 END Check_Constraints;

  PROCEDURE Check_Uniqueness as
  BEGIN

      IF Get_PK_For_Validation (
      new_references.citizenship_cd ) THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
  END Check_Uniqueness ;


  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.govt_citizenship_cd = new_references.govt_citizenship_cd)) OR
       ((new_references.govt_citizenship_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_GOVCITIZEN_CD_PKG.Get_PK_For_Validation (
        new_references.govt_citizenship_cd
        )  THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF ;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_citizenship_cd IN VARCHAR2
    ) RETURN BOOLEAN
   as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_CITIZENSHP_CD
      WHERE    citizenship_cd = x_citizenship_cd
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

  PROCEDURE GET_FK_IGS_PE_GOVCITIZEN_CD (
    x_govt_citizenship_cd IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_CITIZENSHP_CD
      WHERE    govt_citizenship_cd = x_govt_citizenship_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_ST_CIC_GCC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_GOVCITIZEN_CD;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_citizenship_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_citizenship_cd IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_notes IN VARCHAR2 DEFAULT NULL,
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
      x_citizenship_cd,
      x_govt_citizenship_cd,
      x_description,
      x_closed_ind,
      x_notes,
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
         new_references.govt_citizenship_cd
      ) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
     Check_Uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
   --   BeforeRowInsertUpdate1 ( p_updating => TRUE );
       Check_Constraints;
       Check_Parent_Existance;
   --       Check_Uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
       null;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
         new_references.govt_citizenship_cd
           ) THEN
           Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    Check_Uniqueness;
     ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints;
  --     Check_Uniqueness;
     ELSIF (p_action = 'VALIDATE_DELETE') THEN
         null;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) as
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_GOVT_CITIZENSHIP_CD in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_ST_CITIZENSHP_CD
      where CITIZENSHIP_CD = X_CITIZENSHIP_CD;
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
    p_action=>'INSERT' ,
    x_rowid=>X_ROWID ,
    x_citizenship_cd => X_CITIZENSHIP_CD ,
    x_govt_citizenship_cd => X_GOVT_CITIZENSHIP_CD ,
    x_description => X_DESCRIPTION,
    x_closed_ind =>  NVL(X_CLOSED_IND,'N') ,
    x_notes => X_NOTES,
    x_creation_date => X_LAST_UPDATE_DATE ,
    x_created_by=>X_LAST_UPDATED_BY ,
    x_last_update_date=>X_LAST_UPDATE_DATE ,
    x_last_updated_by=>X_LAST_UPDATED_BY ,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
       );

  insert into IGS_ST_CITIZENSHP_CD (
    CITIZENSHIP_CD,
    GOVT_CITIZENSHIP_CD,
    DESCRIPTION,
    CLOSED_IND,
    NOTES,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.CITIZENSHIP_CD,
    NEW_REFERENCES.GOVT_CITIZENSHIP_CD,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.NOTES,
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

After_DML(
  p_action=>'INSERT',
  x_rowid=> X_ROWID
         );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_GOVT_CITIZENSHIP_CD in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2
) as
  cursor c1 is select
      GOVT_CITIZENSHIP_CD,
      DESCRIPTION,
      CLOSED_IND,
      NOTES
    from IGS_ST_CITIZENSHP_CD
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

  if ( (tlinfo.GOVT_CITIZENSHIP_CD = X_GOVT_CITIZENSHIP_CD)
      AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
      AND ((tlinfo.NOTES = X_NOTES)
           OR ((tlinfo.NOTES is null)
               AND (X_NOTES is null)))
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
  X_CITIZENSHIP_CD in VARCHAR2,
  X_GOVT_CITIZENSHIP_CD in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
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
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

 Before_DML(
    p_action=>'UPDATE' ,
    x_rowid=>X_ROWID ,
    x_citizenship_cd => x_citizenship_cd ,
    x_govt_citizenship_cd => x_govt_citizenship_cd ,
    x_description => x_description ,
    x_closed_ind => x_closed_ind ,
    x_notes => x_notes ,
    x_creation_date => X_LAST_UPDATE_DATE ,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE ,
    x_last_updated_by=>X_LAST_UPDATED_BY ,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
       );

  update IGS_ST_CITIZENSHP_CD set
    GOVT_CITIZENSHIP_CD = NEW_REFERENCES.GOVT_CITIZENSHIP_CD,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    NOTES = NEW_REFERENCES.NOTES,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

After_DML(
  p_action=>'UPDATE',
  x_rowid=> X_ROWID
         );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_GOVT_CITIZENSHIP_CD in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_ST_CITIZENSHP_CD
     where CITIZENSHIP_CD = X_CITIZENSHIP_CD
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_CITIZENSHIP_CD,
     X_GOVT_CITIZENSHIP_CD,
     X_DESCRIPTION,
     X_CLOSED_IND,
     X_NOTES,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_CITIZENSHIP_CD,
   X_GOVT_CITIZENSHIP_CD,
   X_DESCRIPTION,
   X_CLOSED_IND,
   X_NOTES,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

Before_DML(
  p_action=>'DELETE',
  x_rowid=> X_ROWID
         );

  delete from IGS_ST_CITIZENSHP_CD
  where  ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

After_DML(
  p_action=>'DELETE',
  x_rowid=> X_ROWID
         );


end DELETE_ROW;

end IGS_ST_CITIZENSHP_CD_PKG;

/