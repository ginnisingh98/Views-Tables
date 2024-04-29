--------------------------------------------------------
--  DDL for Package Body IGS_PS_FLD_OF_STUDY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_FLD_OF_STUDY_PKG" as
 /* $Header: IGSPI54B.pls 120.1 2006/07/25 15:08:01 sommukhe noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_FLD_OF_STUDY_ALL%RowType;
  new_references IGS_PS_FLD_OF_STUDY_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fos_type_code IN VARCHAR2 DEFAULT NULL,
    x_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_govt_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN  NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_FLD_OF_STUDY_ALL
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
    new_references.fos_type_code := x_fos_type_code;
    new_references.field_of_study := x_field_of_study;
    new_references.description := x_description;
    new_references.govt_field_of_study := x_govt_field_of_study;
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

  PROCEDURE BeforeRowInsertUpdate(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
	v_description		IGS_PS_FLD_OF_STUDY_ALL.description%TYPE;
	v_govt_field_of_study	IGS_PS_FLD_OF_STUDY_ALL.govt_field_of_study%TYPE;
	v_closed_ind		IGS_PS_FLD_OF_STUDY_ALL.closed_ind%TYPE;
	x_rowid  		varchar2(25);
 	l_org_id                 NUMBER(15);
	CURSOR SPFSH_CUR IS
		SELECT Rowid
		FROM IGS_PS_FLD_STDY_HIST_ALL
		WHERE	field_of_study = old_references.field_of_study;

  BEGIN
	-- Validate government field of study.
	IF p_inserting OR
		(p_updating AND
		((old_references.govt_field_of_study <> new_references.govt_field_of_study) OR
		 (old_references.closed_ind = 'Y' AND new_references.closed_ind = 'N'))) THEN
		IF IGS_PS_VAL_FOS.crsp_val_fos_govt (
				new_references.govt_field_of_study,
				v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	-- Create history record.
	IF p_updating THEN
		IF old_references.description <> new_references.description OR
				old_references.govt_field_of_study <> new_references.govt_field_of_study OR
				old_references.closed_ind <> new_references.closed_ind THEN
			SELECT	DECODE (old_references.description,  new_references.description, NULL,
old_references.description),
				DECODE (old_references.govt_field_of_study,  new_references.govt_field_of_study, NULL,
					old_references.govt_field_of_study),
				DECODE (old_references.closed_ind, new_references.closed_ind, NULL,
old_references.closed_ind)
			INTO	v_description,
				v_govt_field_of_study,
				v_closed_ind
			FROM	dual;
			l_org_id := igs_ge_gen_003.get_org_id;
		IGS_PS_FLD_STDY_HIST_PKG.Insert_Row(
				X_ROWID    		=> x_rowid,
				X_FIELD_OF_STUDY       	=> old_references.field_of_study,
				X_HIST_START_DT        	=>old_references.last_update_date,
				X_HIST_END_DT          	=>new_references.last_update_date,
				X_HIST_WHO             	=>old_references.last_updated_by,
				X_DESCRIPTION          	=>v_description,
				X_GOVT_FIELD_OF_STUDY  	=>v_govt_field_of_study,
				X_CLOSED_IND           	=>v_closed_ind,
				X_MODE                 	=>'R',
				X_ORG_ID		=> l_org_id,
				X_FOS_TYPE_CODE		=> old_references.fos_type_code);
		END IF;
	END IF;

  END BeforeRowInsertUpdate;

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN
 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'CLOSED_IND' then
     new_references.closed_ind := column_value;
 ELSIF upper(Column_name) = 'FIELD_OF_STUDY' then
     new_references.field_of_study := column_value;
 ELSIF upper(Column_name) = 'GOVT_FIELD_OF_STUDY' then
     new_references.govt_field_of_study := column_value;
END IF;

END check_constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.govt_field_of_study = new_references.govt_field_of_study)) OR
        ((new_references.govt_field_of_study IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RE_GV_FLD_OF_SDY_PKG.Get_PK_For_Validation (
        new_references.govt_field_of_study
        ) THEN
		 Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
     		App_Exception.Raise_Exception;
	 END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_field_of_study IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_FLD_OF_STUDY_ALL
      WHERE    field_of_study = x_field_of_study;

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

  PROCEDURE GET_FK_IGS_RE_GV_FLD_OF_SDY (
    x_govt_field_of_study IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_FLD_OF_STUDY_ALL
      WHERE    govt_field_of_study = x_govt_field_of_study ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_FOS_GFOS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RE_GV_FLD_OF_SDY;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fos_type_code IN VARCHAR2 DEFAULT NULL,
    x_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_govt_field_of_study IN VARCHAR2 DEFAULT NULL,
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
      x_fos_type_code,
      x_field_of_study,
      x_description,
      x_govt_field_of_study,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate( p_inserting => TRUE, p_updating => FALSE );
      IF  Get_PK_For_Validation (
	    new_references.field_of_study
		) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdate( p_inserting => FALSE, p_updating => TRUE );
       Check_Constraints;
       Check_Parent_Existance;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
	    new_references.field_of_study
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

PROCEDURE INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FOS_TYPE_CODE in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FIELD_OF_STUDY in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  ) as
  /***********************************************************************************
  sbaliga 	13-feb-2002	Assigned igs_ge_gen_003.get_org_id to x_org_id
  				in call to before_dml as part of SWCR006 build.
  *************************************************************************/
    cursor C is select ROWID from IGS_PS_FLD_OF_STUDY_ALL
      where FIELD_OF_STUDY = X_FIELD_OF_STUDY;
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

  Before_DML( p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_fos_type_code =>X_FOS_TYPE_CODE,
    x_field_of_study => X_FIELD_OF_STUDY,
    x_description => X_DESCRIPTION,
    x_govt_field_of_study => X_GOVT_FIELD_OF_STUDY,
    x_closed_ind => NVL(X_CLOSED_IND,'N'),
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
    );

  insert into IGS_PS_FLD_OF_STUDY_ALL (
    FOS_TYPE_CODE,
    FIELD_OF_STUDY,
    DESCRIPTION,
    GOVT_FIELD_OF_STUDY,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.FOS_TYPE_CODE,
    NEW_REFERENCES.FIELD_OF_STUDY,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.GOVT_FIELD_OF_STUDY,
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
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
end INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FOS_TYPE_CODE in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FIELD_OF_STUDY in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) as
  cursor c1 is select
      DESCRIPTION,
      GOVT_FIELD_OF_STUDY,
      CLOSED_IND
    from IGS_PS_FLD_OF_STUDY_ALL
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
      AND (tlinfo.GOVT_FIELD_OF_STUDY IS NULL OR tlinfo.GOVT_FIELD_OF_STUDY = X_GOVT_FIELD_OF_STUDY)
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

PROCEDURE UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FOS_TYPE_CODE in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FIELD_OF_STUDY in VARCHAR2,
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

  Before_DML( p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_fos_type_code =>X_FOS_TYPE_CODE,
    x_field_of_study => X_FIELD_OF_STUDY,
    x_description => X_DESCRIPTION,
    x_govt_field_of_study => X_GOVT_FIELD_OF_STUDY,
    x_closed_ind => X_CLOSED_IND,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_PS_FLD_OF_STUDY_ALL set
    FOS_TYPE_CODE = NEW_REFERENCES.FOS_TYPE_CODE,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    GOVT_FIELD_OF_STUDY = NEW_REFERENCES.GOVT_FIELD_OF_STUDY,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
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

PROCEDURE ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FOS_TYPE_CODE in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FIELD_OF_STUDY in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  ) as
  cursor c1 is select rowid from IGS_PS_FLD_OF_STUDY_ALL
     where FIELD_OF_STUDY = X_FIELD_OF_STUDY
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FOS_TYPE_CODE,
     X_FIELD_OF_STUDY,
     X_DESCRIPTION,
     X_GOVT_FIELD_OF_STUDY,
     X_CLOSED_IND,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FOS_TYPE_CODE,
   X_FIELD_OF_STUDY,
   X_DESCRIPTION,
   X_GOVT_FIELD_OF_STUDY,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;

end IGS_PS_FLD_OF_STUDY_PKG;

/
