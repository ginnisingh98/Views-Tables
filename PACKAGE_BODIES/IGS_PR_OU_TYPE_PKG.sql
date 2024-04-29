--------------------------------------------------------
--  DDL for Package Body IGS_PR_OU_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_OU_TYPE_PKG" as
/* $Header: IGSQI06B.pls 115.9 2003/02/24 11:30:35 gjha ship $ */

l_rowid VARCHAR2(25);
  old_references IGS_PR_OU_TYPE_ALL%RowType;
  new_references IGS_PR_OU_TYPE_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_progression_outcome_type IN VARCHAR2 DEFAULT NULL,
    x_s_progression_outcome_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_encumbrance_type IN VARCHAR2 DEFAULT NULL,
    x_dflt_restricted_enrolment_cp IN NUMBER DEFAULT NULL,
    x_dflt_restricted_att_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id in NUMBER DEFAULT NULL,
    x_positive_outcome_ind IN VARCHAR2 DEFAULT 'N'
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_OU_TYPE_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action not in ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.progression_outcome_type := x_progression_outcome_type;
    new_references.s_progression_outcome_type := x_s_progression_outcome_type;
    new_references.description := x_description;
    new_references.encumbrance_type := x_encumbrance_type;
    new_references.dflt_restricted_enrolment_cp := x_dflt_restricted_enrolment_cp;
    new_references.dflt_restricted_att_type := x_dflt_restricted_att_type;
    new_references.closed_ind := x_closed_ind;
    new_references.comments := x_comments;
    new_references.org_id := x_org_id;
    new_references.positive_outcome_ind := x_positive_outcome_ind;

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

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.dflt_restricted_att_type = new_references.dflt_restricted_att_type)) OR
        ((new_references.dflt_restricted_att_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_TYPE_PKG.Get_PK_For_Validation (
        new_references.dflt_restricted_att_type
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.encumbrance_type = new_references.encumbrance_type)) OR
        ((new_references.encumbrance_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ENCMB_TYPE_PKG.Get_PK_For_Validation (
        new_references.encumbrance_type
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.s_progression_outcome_type = new_references.s_progression_outcome_type)) OR
        ((new_references.s_progression_outcome_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
	  'PROGRESSION_OUTCOME_TYPE',
        new_references.s_progression_outcome_type
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PR_RU_OU_PKG.GET_FK_IGS_PR_OU_TYPE (
      old_references.progression_outcome_type
      );

    IGS_PR_STDNT_PR_OU_PKG.GET_FK_IGS_PR_OU_TYPE (
      old_references.progression_outcome_type
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_progression_outcome_type IN VARCHAR2
    )  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_OU_TYPE_ALL
      WHERE    progression_outcome_type = x_progression_outcome_type ; 	  /* Removed for update of for the Locking issue. Bug 2784198  */

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close Cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_OU_TYPE_ALL
      WHERE    dflt_restricted_att_type = x_attendance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_POT_ATT_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ATD_TYPE;

  PROCEDURE GET_FK_IGS_FI_ENCMB_TYPE (
    x_encumbrance_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_OU_TYPE_ALL
      WHERE    encumbrance_type = x_encumbrance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_POT_ET_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_FI_ENCMB_TYPE;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_progression_outcome_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_OU_TYPE_ALL
      WHERE    s_progression_outcome_type = x_s_progression_outcome_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_POT_SPOT_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE BeforeInsertUpdate(p_inserting BOOLEAN , p_updating BOOLEAN) AS
  p_message_name VARCHAR2(30);
  BEGIN
   IF ( p_inserting = TRUE OR (p_updating = TRUE AND new_references.encumbrance_type <> old_references.encumbrance_type) ) THEN
     IF  NOT igs_en_val_etde.enrp_val_et_closed(new_references.encumbrance_type,p_message_name) THEN
        Fnd_Message.Set_Name('IGS', p_message_name);
    	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;
   END IF;
  END BeforeInsertUpdate;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_progression_outcome_type IN VARCHAR2 DEFAULT NULL,
    x_s_progression_outcome_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_encumbrance_type IN VARCHAR2 DEFAULT NULL,
    x_dflt_restricted_enrolment_cp IN NUMBER DEFAULT NULL,
    x_dflt_restricted_att_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER default NULL,
    x_positive_outcome_ind IN VARCHAR2 DEFAULT 'N'
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_progression_outcome_type,
      x_s_progression_outcome_type,
      x_description,
      x_encumbrance_type,
      x_dflt_restricted_enrolment_cp,
      x_dflt_restricted_att_type,
      x_closed_ind,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      x_positive_outcome_ind
    );

    IF (p_action = 'INSERT') THEN
       BeforeInsertUpdate(TRUE,FALSE);
      -- Call all the procedures related to Before Insert.

	IF Get_PK_For_Validation (
         new_references.progression_outcome_type
         ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
    BeforeInsertUpdate(FALSE,TRUE);
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation (
         new_references.progression_outcome_type
         ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROGRESSION_OUTCOME_TYPE in VARCHAR2,
  X_S_PROGRESSION_OUTCOME_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_DFLT_RESTRICTED_ENROLMENT_CP in NUMBER,
  X_DFLT_RESTRICTED_ATT_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER,
  X_POSITIVE_OUTCOME_IND IN VARCHAR2 DEFAULT 'N'
  ) as
    cursor C is select ROWID from IGS_PR_OU_TYPE_ALL
      where PROGRESSION_OUTCOME_TYPE = X_PROGRESSION_OUTCOME_TYPE;
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
    x_rowid => x_rowid,
    x_progression_outcome_type => x_progression_outcome_type,
    x_s_progression_outcome_type => x_s_progression_outcome_type,
    x_description => x_description,
    x_encumbrance_type => x_encumbrance_type,
    x_dflt_restricted_enrolment_cp => x_dflt_restricted_enrolment_cp,
    x_dflt_restricted_att_type => x_dflt_restricted_att_type,
    x_closed_ind => nvl( x_closed_ind,'N'),
    x_comments => x_comments,
    x_creation_date => x_last_update_date,
    x_created_by => x_last_updated_by,
    x_last_update_date => x_last_update_date,
    x_last_updated_by => x_last_updated_by,
    x_last_update_login => x_last_update_login,
    x_org_id => igs_ge_gen_003.get_org_id,
    x_positive_outcome_ind => x_positive_outcome_ind
  );
  insert into IGS_PR_OU_TYPE_ALL (
    PROGRESSION_OUTCOME_TYPE,
    S_PROGRESSION_OUTCOME_TYPE,
    DESCRIPTION,
    ENCUMBRANCE_TYPE,
    DFLT_RESTRICTED_ENROLMENT_CP,
    DFLT_RESTRICTED_ATT_TYPE,
    CLOSED_IND,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID,
    POSITIVE_OUTCOME_IND
  ) values (
    NEW_REFERENCES.PROGRESSION_OUTCOME_TYPE,
    NEW_REFERENCES.S_PROGRESSION_OUTCOME_TYPE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.ENCUMBRANCE_TYPE,
    NEW_REFERENCES.DFLT_RESTRICTED_ENROLMENT_CP,
    NEW_REFERENCES.DFLT_RESTRICTED_ATT_TYPE,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.POSITIVE_OUTCOME_IND
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
  X_PROGRESSION_OUTCOME_TYPE in VARCHAR2,
  X_S_PROGRESSION_OUTCOME_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_DFLT_RESTRICTED_ENROLMENT_CP in NUMBER,
  X_DFLT_RESTRICTED_ATT_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_POSITIVE_OUTCOME_IND IN VARCHAR2
) as
  cursor c1 is select
      S_PROGRESSION_OUTCOME_TYPE,
      DESCRIPTION,
      ENCUMBRANCE_TYPE,
      DFLT_RESTRICTED_ENROLMENT_CP,
      DFLT_RESTRICTED_ATT_TYPE,
      CLOSED_IND,
      COMMENTS
    from IGS_PR_OU_TYPE_ALL
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.S_PROGRESSION_OUTCOME_TYPE = X_S_PROGRESSION_OUTCOME_TYPE)
      AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND ((tlinfo.ENCUMBRANCE_TYPE = X_ENCUMBRANCE_TYPE)
           OR ((tlinfo.ENCUMBRANCE_TYPE is null)
               AND (X_ENCUMBRANCE_TYPE is null)))
      AND ((tlinfo.DFLT_RESTRICTED_ENROLMENT_CP = X_DFLT_RESTRICTED_ENROLMENT_CP)
           OR ((tlinfo.DFLT_RESTRICTED_ENROLMENT_CP is null)
               AND (X_DFLT_RESTRICTED_ENROLMENT_CP is null)))
      AND ((tlinfo.DFLT_RESTRICTED_ATT_TYPE = X_DFLT_RESTRICTED_ATT_TYPE)
           OR ((tlinfo.DFLT_RESTRICTED_ATT_TYPE is null)
               AND (X_DFLT_RESTRICTED_ATT_TYPE is null)))
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
  X_ROWID in VARCHAR2,
  X_PROGRESSION_OUTCOME_TYPE in VARCHAR2,
  X_S_PROGRESSION_OUTCOME_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_DFLT_RESTRICTED_ENROLMENT_CP in NUMBER,
  X_DFLT_RESTRICTED_ATT_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_POSITIVE_OUTCOME_IND IN VARCHAR2 DEFAULT 'N'
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
    x_rowid => x_rowid,
    x_progression_outcome_type => x_progression_outcome_type,
    x_s_progression_outcome_type => x_s_progression_outcome_type,
    x_description => x_description,
    x_encumbrance_type => x_encumbrance_type,
    x_dflt_restricted_enrolment_cp => x_dflt_restricted_enrolment_cp,
    x_dflt_restricted_att_type => x_dflt_restricted_att_type,
    x_closed_ind => x_closed_ind,
    x_comments => x_comments,
    x_creation_date => x_last_update_date,
    x_created_by => x_last_updated_by,
    x_last_update_date => x_last_update_date,
    x_last_updated_by => x_last_updated_by,
    x_last_update_login => x_last_update_login,
    x_positive_outcome_ind => x_positive_outcome_ind
  );

  update IGS_PR_OU_TYPE_ALL set
    S_PROGRESSION_OUTCOME_TYPE = NEW_REFERENCES.S_PROGRESSION_OUTCOME_TYPE,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    ENCUMBRANCE_TYPE = NEW_REFERENCES.ENCUMBRANCE_TYPE,
    DFLT_RESTRICTED_ENROLMENT_CP = NEW_REFERENCES.DFLT_RESTRICTED_ENROLMENT_CP,
    DFLT_RESTRICTED_ATT_TYPE = NEW_REFERENCES.DFLT_RESTRICTED_ATT_TYPE,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    POSITIVE_OUTCOME_IND = X_POSITIVE_OUTCOME_IND
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROGRESSION_OUTCOME_TYPE in VARCHAR2,
  X_S_PROGRESSION_OUTCOME_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_DFLT_RESTRICTED_ENROLMENT_CP in NUMBER,
  X_DFLT_RESTRICTED_ATT_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_POSITIVE_OUTCOME_IND IN VARCHAR2 DEFAULT 'N'
  ) as
  cursor c1 is select rowid from IGS_PR_OU_TYPE_ALL
     where PROGRESSION_OUTCOME_TYPE = X_PROGRESSION_OUTCOME_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PROGRESSION_OUTCOME_TYPE,
     X_S_PROGRESSION_OUTCOME_TYPE,
     X_DESCRIPTION,
     X_ENCUMBRANCE_TYPE,
     X_DFLT_RESTRICTED_ENROLMENT_CP,
     X_DFLT_RESTRICTED_ATT_TYPE,
     X_CLOSED_IND,
     X_COMMENTS,
     X_MODE,
     X_ORG_ID,
     X_POSITIVE_OUTCOME_IND
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PROGRESSION_OUTCOME_TYPE,
   X_S_PROGRESSION_OUTCOME_TYPE,
   X_DESCRIPTION,
   X_ENCUMBRANCE_TYPE,
   X_DFLT_RESTRICTED_ENROLMENT_CP,
   X_DFLT_RESTRICTED_ATT_TYPE,
   X_CLOSED_IND,
   X_COMMENTS,
   X_MODE,
   X_POSITIVE_OUTCOME_IND);
end ADD_ROW;

/*Removed procedure Delete_row for Records Locking Bug 2784198 */

PROCEDURE  Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
  ) AS

BEGIN
  IF Column_Name is null THEN
    NULL;
  ELSIF upper(Column_name) = 'CLOSED_IND' THEN
    new_references.CLOSED_IND:= COLUMN_VALUE ;

  ELSIF upper(Column_name) = 'DESCRIPTION' THEN
    new_references.DESCRIPTION:= COLUMN_VALUE ;

  ELSIF upper(Column_name) = 'DFLT_RESTRICTED_ATT_TYPE' THEN
    new_references.DFLT_RESTRICTED_ATT_TYPE:= COLUMN_VALUE ;

  ELSIF upper(Column_name) = 'ENCUMBRANCE_TYPE' THEN
    new_references.ENCUMBRANCE_TYPE:= COLUMN_VALUE ;

  ELSIF upper(Column_name) = 'PROGRESSION_OUTCOME_TYPE' THEN
    new_references.PROGRESSION_OUTCOME_TYPE:= COLUMN_VALUE ;

  ELSIF upper(Column_name) = 'S_PROGRESSION_OUTCOME_TYPE' THEN
    new_references.S_PROGRESSION_OUTCOME_TYPE:= COLUMN_VALUE ;

  ELSIF upper(Column_name) = 'DFLT_RESTRICTED_ENROLMENT_CP' THEN
    new_references.DFLT_RESTRICTED_ENROLMENT_CP:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

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

  IF upper(Column_name) = 'ENCUMBRANCE_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.ENCUMBRANCE_TYPE<> upper(new_references.ENCUMBRANCE_TYPE) then
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;

  END IF ;

  IF upper(Column_name) = 'PROGRESSION_OUTCOME_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.PROGRESSION_OUTCOME_TYPE<> upper(new_references.PROGRESSION_OUTCOME_TYPE) then
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;

  END IF ;

  IF upper(Column_name) = 'S_PROGRESSION_OUTCOME_TYPE' OR COLUMN_NAME IS NULL THEN
    IF new_references.S_PROGRESSION_OUTCOME_TYPE<> upper(new_references.S_PROGRESSION_OUTCOME_TYPE) then
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;

  END IF ;

  IF upper(Column_name) = 'DFLT_RESTRICTED_ENROLMENT_CP' OR COLUMN_NAME IS NULL THEN
    IF new_references.DFLT_RESTRICTED_ENROLMENT_CP < 0 or new_references.DFLT_RESTRICTED_ENROLMENT_CP > 999.999 then
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;

  END IF ;
END Check_Constraints;

end IGS_PR_OU_TYPE_PKG;

/
