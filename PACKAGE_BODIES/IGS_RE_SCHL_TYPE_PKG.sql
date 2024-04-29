--------------------------------------------------------
--  DDL for Package Body IGS_RE_SCHL_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_SCHL_TYPE_PKG" as
/* $Header: IGSRI10B.pls 115.5 2002/11/29 03:33:46 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_RE_SCHL_TYPE_ALL%RowType;
  new_references IGS_RE_SCHL_TYPE_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_scholarship_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd_from IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt_from IN DATE DEFAULT NULL,
    x_person_id_from IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RE_SCHL_TYPE_ALL
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
    new_references.scholarship_type := x_scholarship_type;
    new_references.description := x_description;
    new_references.org_unit_cd_from := x_org_unit_cd_from;
    new_references.ou_start_dt_from := x_ou_start_dt_from;
    new_references.person_id_from := x_person_id_from;
    new_references.closed_ind := x_closed_ind;
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

PROCEDURE Check_Constraints (
    Column_Name in VARCHAR2 DEFAULT NULL ,
    Column_Value in VARCHAR2 DEFAULT NULL
  ) AS
 BEGIN
 IF Column_Name is null then
   NULL;
 ELSIF upper(Column_name) = 'CLOSED_IND' THEN
   new_references.closed_ind := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'SCHOLARSHIP_TYPE' THEN
   new_references.SCHOLARSHIP_TYPE := COLUMN_VALUE ;
 ELSIF upper(Column_name) = 'PERSON_ID_FROM' THEN
   new_references.PERSON_ID_FROM := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

 END IF;

  IF upper(column_name) = 'CLOSED_IND' OR COLUMN_NAME IS NULL THEN
    IF new_references.closed_ind <> upper(NEW_REFERENCES.closed_ind) OR new_references.closed_ind NOT IN ('Y', 'N') THEN
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'SCHOLARSHIP_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.SCHOLARSHIP_TYPE <> upper(NEW_REFERENCES.SCHOLARSHIP_TYPE) THEN
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
  IF upper(column_name) = 'PERSON_ID_FROM' OR COLUMN_NAME IS NULL THEN
    IF new_references.PERSON_ID_FROM < 1 OR new_references.PERSON_ID_FROM > 9999999999 THEN
	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception ;
	END IF;
  END IF;
 END Check_Constraints ;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.org_unit_cd_from = new_references.org_unit_cd_from) AND
         (old_references.ou_start_dt_from = new_references.ou_start_dt_from)) OR
        ((new_references.org_unit_cd_from IS NULL) OR
         (new_references.ou_start_dt_from IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.org_unit_cd_from,
        new_references.ou_start_dt_from
        ) THEN
     	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     	     IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
       END IF;
    END IF;

    IF (((old_references.person_id_from = new_references.person_id_from)) OR
        ((new_references.person_id_from IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id_from
        ) THEN
     	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     	     IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
       END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_RE_SCHOLARSHIP_PKG.GET_FK_IGS_RE_SCHL_TYPE (
      old_references.scholarship_type
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_scholarship_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_SCHL_TYPE_ALL
      WHERE    scholarship_type = x_scholarship_type
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
 	RETURN(TRUE);
    ELSE
        Close cur_rowid;
        RETURN(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_SCHL_TYPE_ALL
      WHERE    org_unit_cd_from = x_org_unit_cd
      AND      ou_start_dt_from = x_start_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_SCT_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_OR_UNIT;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RE_SCHL_TYPE_ALL
      WHERE    person_id_from = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RE_SCT_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_scholarship_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd_from IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt_from IN DATE DEFAULT NULL,
    x_person_id_from IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
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
      x_scholarship_type,
      x_description,
      x_org_unit_cd_from,
      x_ou_start_dt_from,
      x_person_id_from,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
	    new_references.scholarship_type
      ) THEN

	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	 IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (
	    new_references.scholarship_type
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

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SCHOLARSHIP_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_UNIT_CD_FROM in VARCHAR2,
  X_OU_START_DT_FROM in DATE,
  X_PERSON_ID_FROM in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) As
    cursor C is select ROWID from IGS_RE_SCHL_TYPE_ALL
      where SCHOLARSHIP_TYPE = X_SCHOLARSHIP_TYPE;
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
    x_rowid => X_ROWID,
    x_scholarship_type => X_SCHOLARSHIP_TYPE,
    x_description => X_DESCRIPTION,
    x_org_unit_cd_from => X_ORG_UNIT_CD_FROM,
    x_ou_start_dt_from => X_OU_START_DT_FROM,
    x_person_id_from => X_PERSON_ID_FROM,
    x_closed_ind => NVL(X_CLOSED_IND, 'N'),
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
 );

  insert into IGS_RE_SCHL_TYPE_ALL (
    SCHOLARSHIP_TYPE,
    DESCRIPTION,
    ORG_UNIT_CD_FROM,
    OU_START_DT_FROM,
    PERSON_ID_FROM,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.SCHOLARSHIP_TYPE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.ORG_UNIT_CD_FROM,
    NEW_REFERENCES.OU_START_DT_FROM,
    NEW_REFERENCES.PERSON_ID_FROM,
    NEW_REFERENCES.CLOSED_IND,
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SCHOLARSHIP_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_UNIT_CD_FROM in VARCHAR2,
  X_OU_START_DT_FROM in DATE,
  X_PERSON_ID_FROM in NUMBER,
  X_CLOSED_IND in VARCHAR2
) as
  cursor c1 is select
      DESCRIPTION,
      ORG_UNIT_CD_FROM,
      OU_START_DT_FROM,
      PERSON_ID_FROM,
      CLOSED_IND
    from IGS_RE_SCHL_TYPE_ALL
    where ROWID = X_ROWID
    for update nowait;
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND ((tlinfo.ORG_UNIT_CD_FROM = X_ORG_UNIT_CD_FROM)
           OR ((tlinfo.ORG_UNIT_CD_FROM is null)
               AND (X_ORG_UNIT_CD_FROM is null)))
      AND ((tlinfo.OU_START_DT_FROM = X_OU_START_DT_FROM)
           OR ((tlinfo.OU_START_DT_FROM is null)
               AND (X_OU_START_DT_FROM is null)))
      AND ((tlinfo.PERSON_ID_FROM = X_PERSON_ID_FROM)
           OR ((tlinfo.PERSON_ID_FROM is null)
               AND (X_PERSON_ID_FROM is null)))
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)


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
  X_SCHOLARSHIP_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_UNIT_CD_FROM in VARCHAR2,
  X_OU_START_DT_FROM in DATE,
  X_PERSON_ID_FROM in NUMBER,
  X_CLOSED_IND in VARCHAR2,
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

  Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_scholarship_type => X_SCHOLARSHIP_TYPE,
    x_description => X_DESCRIPTION,
    x_org_unit_cd_from => X_ORG_UNIT_CD_FROM,
    x_ou_start_dt_from => X_OU_START_DT_FROM,
    x_person_id_from => X_PERSON_ID_FROM,
    x_closed_ind => X_CLOSED_IND,
    x_created_by => X_LAST_UPDATED_BY ,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  update IGS_RE_SCHL_TYPE_ALL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    ORG_UNIT_CD_FROM = NEW_REFERENCES.ORG_UNIT_CD_FROM,
    OU_START_DT_FROM = NEW_REFERENCES.OU_START_DT_FROM,
    PERSON_ID_FROM = NEW_REFERENCES.PERSON_ID_FROM,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SCHOLARSHIP_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_UNIT_CD_FROM in VARCHAR2,
  X_OU_START_DT_FROM in DATE,
  X_PERSON_ID_FROM in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
  cursor c1 is select rowid from IGS_RE_SCHL_TYPE_ALL
     where SCHOLARSHIP_TYPE = X_SCHOLARSHIP_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SCHOLARSHIP_TYPE,
     X_DESCRIPTION,
     X_ORG_UNIT_CD_FROM,
     X_OU_START_DT_FROM,
     X_PERSON_ID_FROM,
     X_CLOSED_IND,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SCHOLARSHIP_TYPE,
   X_DESCRIPTION,
   X_ORG_UNIT_CD_FROM,
   X_OU_START_DT_FROM,
   X_PERSON_ID_FROM,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
   );

  delete from IGS_RE_SCHL_TYPE_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_RE_SCHL_TYPE_PKG;

/
