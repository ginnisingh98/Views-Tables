--------------------------------------------------------
--  DDL for Package Body IGS_AD_CONV_GS_VALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_CONV_GS_VALS_PKG" AS
/* $Header: IGSAIB0B.pls 115.15 2003/01/23 04:41:07 knag ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_conv_gs_vals%RowType;
  new_references igs_ad_conv_gs_vals%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_conv_gs_values_id IN NUMBER DEFAULT NULL,
    x_conv_gs_types_id IN NUMBER DEFAULT NULL,
    x_from_gpa IN VARCHAR2,
    x_to_gpa IN VARCHAR2,
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
      FROM     IGS_AD_CONV_GS_VALS
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
    new_references.conv_gs_values_id := x_conv_gs_values_id;
    new_references.conv_gs_types_id := x_conv_gs_types_id;
    new_references.from_gpa := x_from_gpa;
    new_references.to_gpa := x_to_gpa;
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
    Column_Value IN VARCHAR2  DEFAULT NULL
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
   IF column_name IS NULL THEN
      NULL;
    ELSIF upper(column_name) = 'FROM_GPA' THEN
    --  new_references.from_gpa := IGS_GE_NUMBER.TO_NUM(column_value);
      null;
    ELSIF upper(column_name) = 'TO_GPA' THEN
    --  new_references.to_gpa := IGS_GE_NUMBER.TO_NUM(column_value);
      null;
    END IF;

    IF upper(column_name) = 'FROM_GPA' OR column_name IS NULL THEN
--      IF new_references.from_gpa < 0 THEN
--        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
--	IGS_GE_MSG_STACK.ADD;
--       APP_EXCEPTION.RAISE_EXCEPTION;
--      END IF;
null;
    END IF;

    IF upper(column_name) = 'TO_GPA' OR column_name IS NULL THEN
--  IF new_references.to_gpa < 0 THEN
--    FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
--	IGS_GE_MSG_STACK.ADD;
--       APP_EXCEPTION.RAISE_EXCEPTION;
--    END IF;
null;
    END IF;

     null;
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
  begin
    IF Get_Uk_For_Validation (
         new_references.conv_gs_types_id
         ,new_references.from_gpa
         ,new_references.to_gpa
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
    IF (((old_references.conv_gs_types_id = new_references.conv_gs_types_id)) OR
        ((new_references.conv_gs_types_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Conv_Gs_Types_Pkg.Get_PK_For_Validation (
                new_references.conv_gs_types_id ) THEN
      Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_conv_gs_values_id IN NUMBER
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
      FROM     igs_ad_conv_gs_vals
      WHERE    conv_gs_values_id = x_conv_gs_values_id
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
    x_conv_gs_types_id IN NUMBER,
    x_from_gpa IN VARCHAR2,
    x_to_gpa IN VARCHAR2
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
      FROM     igs_ad_conv_gs_vals
      WHERE    from_gpa = x_from_gpa
      AND      conv_gs_types_id = x_conv_gs_types_id
      AND      to_gpa = x_to_gpa and ((l_rowid is null) or (rowid <> l_rowid));
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

  PROCEDURE Get_FK_Igs_Ad_Conv_Gs_Types (
    x_conv_gs_types_id IN NUMBER
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
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_conv_gs_vals
      WHERE    conv_gs_types_id = x_conv_gs_types_id ;

    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACGV_ACGT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END Get_FK_Igs_Ad_Conv_Gs_Types;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2 ,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_conv_gs_values_id IN NUMBER DEFAULT NULL,
    x_conv_gs_types_id IN NUMBER DEFAULT NULL,
    x_from_gpa IN VARCHAR2,
    x_to_gpa IN VARCHAR2,
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
      x_conv_gs_values_id,
      x_conv_gs_types_id,
      x_from_gpa,
      x_to_gpa,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_Pk_For_Validation(
           new_references.conv_gs_values_id
          ) THEN
        Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      --Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Uniqueness;
      --Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
           new_references.conv_gs_values_id
         ) THEN
	Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      --Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      --Check_Constraints;
    END IF;
  END Before_DML;

  procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_CONV_GS_VALUES_ID IN OUT NOCOPY  NUMBER,
    x_CONV_GS_TYPES_ID IN NUMBER,
    x_FROM_GPA IN VARCHAR2,
    x_TO_GPA IN VARCHAR2,
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
      from IGS_AD_CONV_GS_VALS
      where CONV_GS_VALUES_ID = X_CONV_GS_VALUES_ID;
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

    X_CONV_GS_VALUES_ID := -1;
    Before_DML(
      p_action=>'INSERT',
      x_rowid=>X_ROWID,
      x_conv_gs_values_id=>X_CONV_GS_VALUES_ID,
      x_conv_gs_types_id=>X_CONV_GS_TYPES_ID,
      x_from_gpa=>X_FROM_GPA,
      x_to_gpa=>X_TO_GPA,
      x_creation_date=>X_LAST_UPDATE_DATE,
      x_created_by=>X_LAST_UPDATED_BY,
      x_last_update_date=>X_LAST_UPDATE_DATE,
      x_last_updated_by=>X_LAST_UPDATED_BY,
      x_last_update_login=>X_LAST_UPDATE_LOGIN
    );
    insert into IGS_AD_CONV_GS_VALS (
      CONV_GS_VALUES_ID
      ,CONV_GS_TYPES_ID
      ,FROM_GPA
      ,TO_GPA
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
    ) values  (
      IGS_AD_CONV_GS_VALUES_S.NEXTVAL
      ,NEW_REFERENCES.CONV_GS_TYPES_ID
      ,NEW_REFERENCES.FROM_GPA
      ,NEW_REFERENCES.TO_GPA
      ,X_LAST_UPDATE_DATE
      ,X_LAST_UPDATED_BY
      ,X_LAST_UPDATE_DATE
      ,X_LAST_UPDATED_BY
      ,X_LAST_UPDATE_LOGIN
    )RETURNING CONV_GS_VALUES_ID INTO X_CONV_GS_VALUES_ID;
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
    x_CONV_GS_VALUES_ID IN NUMBER,
    x_CONV_GS_TYPES_ID IN NUMBER,
    x_FROM_GPA IN VARCHAR2,
    x_TO_GPA IN VARCHAR2
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
      select CONV_GS_TYPES_ID
             ,FROM_GPA
             ,TO_GPA
      from IGS_AD_CONV_GS_VALS
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
    if (( tlinfo.CONV_GS_TYPES_ID = X_CONV_GS_TYPES_ID)
        AND (tlinfo.FROM_GPA = X_FROM_GPA)
        AND (tlinfo.TO_GPA = X_TO_GPA)
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
    x_CONV_GS_VALUES_ID IN NUMBER,
    x_CONV_GS_TYPES_ID IN NUMBER,
    x_FROM_GPA IN VARCHAR2,
    x_TO_GPA IN VARCHAR2,
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
      x_conv_gs_values_id=>X_CONV_GS_VALUES_ID,
      x_conv_gs_types_id=>X_CONV_GS_TYPES_ID,
      x_from_gpa=>X_FROM_GPA,
      x_to_gpa=>X_TO_GPA,
      x_creation_date=>X_LAST_UPDATE_DATE,
      x_created_by=>X_LAST_UPDATED_BY,
      x_last_update_date=>X_LAST_UPDATE_DATE,
      x_last_updated_by=>X_LAST_UPDATED_BY,
      x_last_update_login=>X_LAST_UPDATE_LOGIN
    );
    update IGS_AD_CONV_GS_VALS
      set
        CONV_GS_TYPES_ID =  NEW_REFERENCES.CONV_GS_TYPES_ID,
        FROM_GPA =  NEW_REFERENCES.FROM_GPA,
        TO_GPA =  NEW_REFERENCES.TO_GPA,
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
    x_CONV_GS_VALUES_ID IN OUT NOCOPY NUMBER,
    x_CONV_GS_TYPES_ID IN NUMBER,
    x_FROM_GPA IN VARCHAR2,
    x_TO_GPA IN VARCHAR2,
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
      from IGS_AD_CONV_GS_VALS
      where  CONV_GS_VALUES_ID = X_CONV_GS_VALUES_ID;
  begin
    open c1;
    fetch c1 into X_ROWID;
    if (c1%notfound) then
      close c1;
      INSERT_ROW (
        X_ROWID,
        X_CONV_GS_VALUES_ID,
        X_CONV_GS_TYPES_ID,
        X_FROM_GPA,
        X_TO_GPA,
        X_MODE
      );
      return;
    end if;
    close c1;
    UPDATE_ROW (
      X_ROWID,
      X_CONV_GS_VALUES_ID,
      X_CONV_GS_TYPES_ID,
      X_FROM_GPA,
      X_TO_GPA,
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
 /*   Before_DML (
      p_action => 'DELETE',
      x_rowid => X_ROWID
    ); */


   Before_DML(
      p_action=>'DELETE',
      x_rowid=>X_ROWID,
      x_conv_gs_values_id=>NULL,
      x_conv_gs_types_id=>NULL,
      x_from_gpa=>NULL,
      x_to_gpa=>NULL,
      x_creation_date=>NULL,
      x_created_by=>NULL,
      x_last_update_date=>NULL,
      x_last_updated_by=>NULL,
      x_last_update_login=>NULL
    );

   delete
     from IGS_AD_CONV_GS_VALS
     where ROWID = X_ROWID;
    if (sql%notfound) then
      raise no_data_found;
    end if;
  end DELETE_ROW;

END igs_ad_conv_gs_vals_pkg;

/
