--------------------------------------------------------
--  DDL for Package Body IGS_AD_CONV_GS_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_CONV_GS_TYPES_PKG" AS
/* $Header: IGSAI77B.pls 115.12 2003/12/09 11:06:49 akadam ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_conv_gs_types%RowType;
  new_references igs_ad_conv_gs_types%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_conv_gs_types_id IN NUMBER DEFAULT NULL,
    x_from_code_id IN NUMBER DEFAULT NULL,
    x_to_code_id IN NUMBER DEFAULT NULL,
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
      FROM     IGS_AD_CONV_GS_TYPES
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
    new_references.conv_gs_types_id := x_conv_gs_types_id;
    new_references.from_code_id := x_from_code_id;
    new_references.to_code_id := x_to_code_id;
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
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
  ) AS
  /*************************************************************
  Created By :  Subramanikandan, Oracle IDC. (ssomasun.in)
  Date Created : 19-May-2000
  Purpose : To ensure that the FROM_CODE_ID and TO_CODE_ID are not the same
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    IF p_inserting OR p_updating THEN
      IF (new_references.from_code_id = new_references.to_code_id) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_FROMTO_GRADE_SAME');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
  END;

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
  begin
    IF Get_Uk_For_Validation (
      new_references.from_code_id
      ,new_references.to_code_id
    ) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    END IF;
  END Check_Uniqueness ;

  PROCEDURE Check_Parent_Existance AS
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
    IF (((old_references.to_code_id = new_references.to_code_id)) OR
        ((new_references.to_code_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
                new_references.to_code_id,
                'GRADING_SCALE_TYPES',
                'N'
              ) THEN
      Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.from_code_id = new_references.from_code_id)) OR
        ((new_references.from_code_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
                new_references.from_code_id,
                'GRADING_SCALE_TYPES',
                'N'
              ) THEN
      Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

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
    Igs_Ad_Conv_Gs_Vals_Pkg.Get_FK_Igs_Ad_Conv_Gs_Types (
      old_references.conv_gs_types_id
    );
  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_conv_gs_types_id IN NUMBER
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
      FROM     igs_ad_conv_gs_types
      WHERE    conv_gs_types_id = x_conv_gs_types_id
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
    x_from_code_id IN NUMBER,
    x_to_code_id IN NUMBER
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
      FROM     igs_ad_conv_gs_types
      WHERE    from_code_id = x_from_code_id
      AND      to_code_id = x_to_code_id and ((l_rowid is null) or (rowid <> l_rowid));
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

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
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
    CURSOR cur_rowid1 IS
      SELECT   rowid
      FROM     igs_ad_conv_gs_types
      WHERE    to_code_id = x_code_id ;

    CURSOR cur_rowid2 IS
      SELECT   rowid
      FROM     igs_ad_conv_gs_types
      WHERE    from_code_id = x_code_id ;

    lv_rowid1 cur_rowid1%RowType;
    lv_rowid2 cur_rowid2%RowType;

  BEGIN
    Open cur_rowid1;
    Fetch cur_rowid1 INTO lv_rowid1;
    IF (cur_rowid1%FOUND) THEN
      Close cur_rowid1;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACGT_ACDC_FK2');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid1;

    Open cur_rowid2;
    Fetch cur_rowid2 INTO lv_rowid2;
    IF (cur_rowid2%FOUND) THEN
      Close cur_rowid2;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACGT_ACDC_FK1');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid2;

  END Get_FK_Igs_Ad_Code_Classes;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_conv_gs_types_id IN NUMBER DEFAULT NULL,
    x_from_code_id IN NUMBER DEFAULT NULL,
    x_to_code_id IN NUMBER DEFAULT NULL,
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
      x_conv_gs_types_id,
      x_from_code_id,
      x_to_code_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate ( p_inserting => TRUE );
      IF Get_Pk_For_Validation(
           new_references.conv_gs_types_id
         ) THEN
        Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate ( p_updating => TRUE );
      Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
           new_references.conv_gs_types_id
         ) THEN
	Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END Before_DML;

  procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_CONV_GS_TYPES_ID IN OUT NOCOPY NUMBER,
    x_FROM_CODE_ID IN NUMBER,
    x_TO_CODE_ID IN NUMBER,
    X_MODE in VARCHAR2 default 'R'
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
      select ROWID
      from IGS_AD_CONV_GS_TYPES
      where CONV_GS_TYPES_ID= X_CONV_GS_TYPES_ID;
    X_LAST_UPDATE_DATE DATE ;
    X_LAST_UPDATED_BY NUMBER ;
    X_LAST_UPDATE_LOGIN NUMBER ;
  begin
    X_LAST_UPDATE_DATE := SYSDATE;
    if (X_MODE = 'I') then
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

    X_CONV_GS_TYPES_ID := -1;
    Before_DML(
      p_action=>'INSERT',
      x_rowid=>X_ROWID,
      x_conv_gs_types_id=>X_CONV_GS_TYPES_ID,
      x_from_code_id=>X_FROM_CODE_ID,
      x_to_code_id=>X_TO_CODE_ID,
      x_creation_date=>X_LAST_UPDATE_DATE,
      x_created_by=>X_LAST_UPDATED_BY,
      x_last_update_date=>X_LAST_UPDATE_DATE,
      x_last_updated_by=>X_LAST_UPDATED_BY,
      x_last_update_login=>X_LAST_UPDATE_LOGIN
    );
    insert into IGS_AD_CONV_GS_TYPES (
      CONV_GS_TYPES_ID
      ,FROM_CODE_ID
      ,TO_CODE_ID
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
    ) values  (
       IGS_AD_CONV_GS_TYPES_S.NEXTVAL
      ,NEW_REFERENCES.FROM_CODE_ID
      ,NEW_REFERENCES.TO_CODE_ID
      ,X_LAST_UPDATE_DATE
      ,X_LAST_UPDATED_BY
      ,X_LAST_UPDATE_DATE
      ,X_LAST_UPDATED_BY
      ,X_LAST_UPDATE_LOGIN
    )RETURNING CONV_GS_TYPES_ID INTO X_CONV_GS_TYPES_ID;
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
    x_CONV_GS_TYPES_ID IN NUMBER,
    x_FROM_CODE_ID IN NUMBER,
    x_TO_CODE_ID IN NUMBER
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
      select FROM_CODE_ID
             , TO_CODE_ID
      from IGS_AD_CONV_GS_TYPES
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
    if (( tlinfo.FROM_CODE_ID = X_FROM_CODE_ID)
        AND (tlinfo.TO_CODE_ID = X_TO_CODE_ID)) then
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
    x_CONV_GS_TYPES_ID IN NUMBER,
    x_FROM_CODE_ID IN NUMBER,
    x_TO_CODE_ID IN NUMBER,
    X_MODE in VARCHAR2 default 'R'
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
  begin
    X_LAST_UPDATE_DATE := SYSDATE;
    if (X_MODE = 'I') then
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
      p_action=>'UPDATE',
      x_rowid=>X_ROWID,
      x_conv_gs_types_id=>X_CONV_GS_TYPES_ID,
      x_from_code_id=>X_FROM_CODE_ID,
      x_to_code_id=>X_TO_CODE_ID,
      x_creation_date=>X_LAST_UPDATE_DATE,
      x_created_by=>X_LAST_UPDATED_BY,
      x_last_update_date=>X_LAST_UPDATE_DATE,
      x_last_updated_by=>X_LAST_UPDATED_BY,
      x_last_update_login=>X_LAST_UPDATE_LOGIN
    );
    update IGS_AD_CONV_GS_TYPES
      set
        FROM_CODE_ID =  NEW_REFERENCES.FROM_CODE_ID,
        TO_CODE_ID =  NEW_REFERENCES.TO_CODE_ID,
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
    x_CONV_GS_TYPES_ID IN  OUT NOCOPY NUMBER,
    x_FROM_CODE_ID IN NUMBER,
    x_TO_CODE_ID IN NUMBER,
    X_MODE in VARCHAR2 default 'R'
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
      from IGS_AD_CONV_GS_TYPES
      where CONV_GS_TYPES_ID= X_CONV_GS_TYPES_ID;
  begin
    open c1;
    fetch c1 into X_ROWID;
    if (c1%notfound) then
      close c1;
      INSERT_ROW (
        X_ROWID,
        X_CONV_GS_TYPES_ID,
        X_FROM_CODE_ID,
        X_TO_CODE_ID,
        X_MODE
      );
      return;
    end if;
    close c1;
    UPDATE_ROW (
      X_ROWID,
      X_CONV_GS_TYPES_ID,
      X_FROM_CODE_ID,
      X_TO_CODE_ID,
      X_MODE
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
    delete from IGS_AD_CONV_GS_TYPES
      where ROWID = X_ROWID;
    if (sql%notfound) then
      raise no_data_found;
    end if;
  end DELETE_ROW;

END igs_ad_conv_gs_types_pkg;

/
