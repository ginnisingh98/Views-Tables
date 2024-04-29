--------------------------------------------------------
--  DDL for Package Body IGS_AD_NOTE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_NOTE_TYPES_PKG" AS
/* $Header: IGSAI76B.pls 120.1 2005/09/22 05:41:47 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_note_types%RowType;
  new_references igs_ad_note_types%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_notes_type_id IN NUMBER DEFAULT NULL,
    x_notes_category IN VARCHAR2 DEFAULT NULL,
    x_note_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_NOTE_TYPES
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
    new_references.notes_type_id := x_notes_type_id;
    new_references.notes_category := x_notes_category;
    new_references.note_type := x_note_type;
    new_references.description := x_description;
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

  PROCEDURE Check_Constraints (
    Column_Name IN VARCHAR2  DEFAULT NULL,
    Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    IF column_name IS NULL THEN
      NULL;
    ELSIF  UPPER(column_name) = 'CLOSED_IND'  THEN
      new_references.closed_ind := column_value;
    ELSIF  UPPER(column_name) = 'NOTE_TYPE'  THEN
      new_references.note_type := column_value;
    END IF;

    -- The following code checks for check constraints on the Columns.
    IF Upper(Column_Name) = 'CLOSED_IND' OR Column_Name IS NULL THEN
      IF new_references.closed_ind NOT IN ('Y','N') THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF upper(Column_Name) = 'NOTE_TYPE' OR Column_Name IS NULL THEN
      IF new_references.note_type <> UPPER(new_references.note_type) THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Constraints;

  PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    IF Get_Uk_For_Validation (
      new_references.notes_category,
      new_references.note_type
      ) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END Check_Uniqueness ;

  PROCEDURE  Check_Parent_Existance IS
  /**************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose         :
  Know Limitaions , enhancements,or remarks
  Change History
  Who               When          What
  (reverse  chronological Order - newest change first)
  *************************************************************/
  BEGIN
    IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
             'APPLN_NOTE_CATEGORIES',
             new_references.NOTES_CATEGORY
           ) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
  END Check_Parent_existance;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    Igs_Ad_Appl_Notes_Pkg.Get_FK_Igs_Ad_Note_Types (
      old_references.notes_type_id
    );
  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_notes_type_id IN NUMBER,
    x_closed_ind IN VARCHAR2
  ) RETURN BOOLEAN AS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_note_types
      WHERE    notes_type_id = x_notes_type_id AND
               closed_ind = NVL(x_closed_ind,closed_ind)
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

  FUNCTION Get_UK_For_Validation (
    x_notes_category IN VARCHAR2,
    x_note_type IN VARCHAR2,
    x_closed_ind IN VARCHAR2
  ) RETURN BOOLEAN AS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_note_types
      WHERE    notes_category = x_notes_category AND
               note_type = x_note_type 	AND
               ((l_rowid is null) or (rowid <> l_rowid)) AND
               closed_ind = NVL(x_closed_ind,closed_ind);
--      FOR UPDATE NOWAIT; not needed - apadegal adt001 igs.m
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        return (true);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  END Get_UK_For_Validation ;

  FUNCTION Get_UK2_For_Validation (
    x_notes_type_id IN NUMBER,
    x_notes_category IN VARCHAR2,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN AS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_note_types
      WHERE     notes_category = NVL(x_notes_category,notes_category ) AND
               notes_type_id = x_notes_type_id 	AND
               ((l_rowid is null) or (rowid <> l_rowid)) AND
               closed_ind = NVL(x_closed_ind,closed_ind) ;
   --      FOR UPDATE NOWAIT; not needed - apadegal adt001 igs.m
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        return (true);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  END Get_UK2_For_Validation ;



  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_notes_type_id IN NUMBER DEFAULT NULL,
    x_notes_category IN VARCHAR2 DEFAULT NULL,
    x_note_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_notes_type_id,
      x_notes_category,
      x_note_type,
      x_description,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_Pk_For_Validation(new_references.notes_type_id)  THEN
	Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (new_references.notes_type_id)  THEN
	Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;
 l_rowid := NULL;
  END Before_DML;

  procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_NOTES_TYPE_ID IN  OUT NOCOPY NUMBER,
    x_NOTES_CATEGORY IN VARCHAR2,
    x_NOTE_TYPE IN VARCHAR2,
    x_DESCRIPTION IN VARCHAR2,
    x_CLOSED_IND IN VARCHAR2,
    X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    cursor C is
      select ROWID from IGS_AD_NOTE_TYPES
      where NOTES_TYPE_ID= X_NOTES_TYPE_ID;
    X_LAST_UPDATE_DATE DATE ;
    X_LAST_UPDATED_BY NUMBER ;
    X_LAST_UPDATE_LOGIN NUMBER ;
     l_mode        VARCHAR2(1);
  begin
    l_mode := NVL(x_mode, 'R');
    X_LAST_UPDATE_DATE := SYSDATE;
    if (l_mode = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    elsif (l_mode = 'R') then
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

    X_NOTES_TYPE_ID := -1;
    Before_DML(
      p_action=>'INSERT',
      x_rowid=>X_ROWID,
      x_notes_type_id=>X_NOTES_TYPE_ID,
      x_notes_category=>X_NOTES_CATEGORY,
      x_note_type=>X_NOTE_TYPE,
      x_description=>X_DESCRIPTION,
      x_closed_ind=>X_CLOSED_IND,
      x_creation_date=>X_LAST_UPDATE_DATE,
      x_created_by=>X_LAST_UPDATED_BY,
      x_last_update_date=>X_LAST_UPDATE_DATE,
      x_last_updated_by=>X_LAST_UPDATED_BY,
      x_last_update_login=>X_LAST_UPDATE_LOGIN
    );
    insert into IGS_AD_NOTE_TYPES (
      NOTES_TYPE_ID
      ,NOTES_CATEGORY
      ,NOTE_TYPE
      ,DESCRIPTION
      ,CLOSED_IND
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
     ) values  (
	         IGS_AD_NOTE_TYPES_S.NEXTVAL
	        ,NEW_REFERENCES.NOTES_CATEGORY
	        ,NEW_REFERENCES.NOTE_TYPE
	        ,NEW_REFERENCES.DESCRIPTION
	        ,NEW_REFERENCES.CLOSED_IND
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
    )RETURNING NOTES_TYPE_ID INTO X_NOTES_TYPE_ID;
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
    x_NOTES_TYPE_ID IN NUMBER,
    x_NOTES_CATEGORY IN VARCHAR2,
    x_NOTE_TYPE IN VARCHAR2,
    x_DESCRIPTION IN VARCHAR2,
    x_CLOSED_IND IN VARCHAR2  ) AS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    cursor c1 is
      select NOTES_CATEGORY,
             NOTE_TYPE,
             DESCRIPTION,
             CLOSED_IND
      from IGS_AD_NOTE_TYPES
      where ROWID = X_ROWID
      for update nowait;
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
    if ( (  tlinfo.NOTES_CATEGORY = X_NOTES_CATEGORY)
        AND (tlinfo.NOTE_TYPE = X_NOTE_TYPE)
        AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
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

  Procedure UPDATE_ROW (
    X_ROWID in  VARCHAR2,
    x_NOTES_TYPE_ID IN NUMBER,
    x_NOTES_CATEGORY IN VARCHAR2,
    x_NOTE_TYPE IN VARCHAR2,
    x_DESCRIPTION IN VARCHAR2,
    x_CLOSED_IND IN VARCHAR2,
    X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    X_LAST_UPDATE_DATE DATE ;
    X_LAST_UPDATED_BY NUMBER ;
    X_LAST_UPDATE_LOGIN NUMBER ;
     l_mode        VARCHAR2(1);
  begin
    l_mode := NVL(x_mode, 'R');
    X_LAST_UPDATE_DATE := SYSDATE;
    if (l_mode = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    elsif (l_mode = 'R') then
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
      p_action=>'UPDATE',
      x_rowid=>X_ROWID,
      x_notes_type_id=>X_NOTES_TYPE_ID,
      x_notes_category=>X_NOTES_CATEGORY,
      x_note_type=>X_NOTE_TYPE,
      x_description=>X_DESCRIPTION,
      x_closed_ind=>X_CLOSED_IND,
      x_creation_date=>X_LAST_UPDATE_DATE,
      x_created_by=>X_LAST_UPDATED_BY,
      x_last_update_date=>X_LAST_UPDATE_DATE,
      x_last_updated_by=>X_LAST_UPDATED_BY,
      x_last_update_login=>X_LAST_UPDATE_LOGIN
    );
    update IGS_AD_NOTE_TYPES
    set NOTES_CATEGORY =  NEW_REFERENCES.NOTES_CATEGORY,
        NOTE_TYPE =  NEW_REFERENCES.NOTE_TYPE,
        DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
        CLOSED_IND =  NEW_REFERENCES.CLOSED_IND,
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
    x_NOTES_TYPE_ID IN OUT NOCOPY NUMBER,
    x_NOTES_CATEGORY IN VARCHAR2,
    x_NOTE_TYPE IN VARCHAR2,
    x_DESCRIPTION IN VARCHAR2,
    x_CLOSED_IND IN VARCHAR2,
    X_MODE in VARCHAR2
   ) AS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    cursor c1 is
      select ROWID
      from IGS_AD_NOTE_TYPES
      where NOTES_TYPE_ID= X_NOTES_TYPE_ID;
      l_mode        VARCHAR2(1);
  begin
    l_mode := NVL(x_mode, 'R');
    open c1;
    fetch c1 into X_ROWID;
    if (c1%notfound) then
      close c1;
      INSERT_ROW (
        X_ROWID,
        X_NOTES_TYPE_ID,
        X_NOTES_CATEGORY,
        X_NOTE_TYPE,
        X_DESCRIPTION,
        X_CLOSED_IND,
        l_mode
      );
      return;
    end if;
    close c1;
    UPDATE_ROW (
      X_ROWID,
      X_NOTES_TYPE_ID,
      X_NOTES_CATEGORY,
      X_NOTE_TYPE,
      X_DESCRIPTION,
      X_CLOSED_IND,
      l_mode
    );
  end ADD_ROW;

  procedure DELETE_ROW (
    X_ROWID in VARCHAR2
  ) AS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  begin
    Before_DML (
      p_action => 'DELETE',
      x_rowid => X_ROWID
    );
    delete from IGS_AD_NOTE_TYPES
      where ROWID = X_ROWID;
    if (sql%notfound) then
      raise no_data_found;
    end if;
  end DELETE_ROW;

END igs_ad_note_types_pkg;

/
