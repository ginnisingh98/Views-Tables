--------------------------------------------------------
--  DDL for Package Body IGS_EN_METHOD_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_METHOD_TYPE_PKG" AS
/* $Header: IGSEI07B.pls 120.0 2005/06/01 18:30:36 appldev noship $ */
l_rowid VARCHAR2(25);
  old_references IGS_EN_METHOD_TYPE%RowType;
  new_references IGS_EN_METHOD_TYPE%RowType;
PROCEDURE Set_Column_Values (
    p_action            IN VARCHAR2,
    x_rowid             IN VARCHAR2,
    x_enr_method_type   IN VARCHAR2,
    x_description       IN VARCHAR2,
    x_closed_ind        IN VARCHAR2,
    x_creation_date     IN DATE,
    x_created_by        IN NUMBER,
    x_last_update_date  IN DATE,
    x_last_updated_by   IN NUMBER,
    x_last_update_login IN NUMBER,
    x_self_service      IN VARCHAR2,
    x_ivr_display_ind   IN VARCHAR2,
    x_bulk_job_ind      IN VARCHAR2,
    x_transfer_flag     IN VARCHAR2,
    x_dflt_trans_details_flag  IN VARCHAR2
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_METHOD_TYPE
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.enr_method_type := x_enr_method_type;
    new_references.description := x_description;
    new_references.closed_ind := x_closed_ind;
    new_references.self_service := x_self_service;
    new_references.ivr_display_ind := NVL(x_ivr_display_ind,'N');
    new_references.bulk_job_ind := x_bulk_job_ind;
    new_references.transfer_flag := x_transfer_flag;
    new_references.dflt_trans_details_flag := x_dflt_trans_details_flag;
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
        Column_Name     IN      VARCHAR2        DEFAULT NULL,
        Column_Value    IN      VARCHAR2        DEFAULT NULL
 ) as

  BEGIN

    -- The following code checks for check constraints on the Columns.

    IF column_name is NULL THEN
        NULL;
    ELSIF  UPPER(column_name) = 'ENR_METHOD_TYPE' THEN
        new_references.enr_method_type := column_value;
    ELSIF  UPPER(column_name) = 'CLOSED_IND' THEN
        new_references.closed_ind := column_value;
    ELSIF  UPPER(column_name) = 'BULK_JOB_IND' THEN
        new_references.bulk_job_ind := column_value;
    END IF;

    IF ((UPPER (column_name) = 'CLOSED_IND') OR (column_name IS NULL)) THEN
      IF new_references.closed_ind NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'BULK_JOB_IND') OR (column_name IS NULL)) THEN
      IF new_references.bulk_job_ind NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'ENR_METHOD_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.enr_method_type <> UPPER (new_references.enr_method_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'TRANSFER_FLAG') OR (column_name IS NULL)) THEN
      IF new_references.transfer_flag NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'DFLT_TRANS_DETAILS_FLAG') OR (column_name IS NULL)) THEN
      IF new_references.dflt_trans_details_flag NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;


  END Check_Constraints;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_EN_CAT_PRC_DTL_PKG.GET_FK_IGS_EN_METHOD_TYPE (
     old_references.enr_method_type
      );

    igs_en_cpd_ext_pkg.get_fk_igs_en_method_type(
     old_references.enr_method_type
      );
  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_enr_method_type IN VARCHAR2
    ) RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_METHOD_TYPE
      WHERE   enr_method_type = x_enr_method_type
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
    p_action            IN VARCHAR2,
    x_rowid             IN VARCHAR2,
    x_enr_method_type   IN VARCHAR2,
    x_description       IN VARCHAR2,
    x_closed_ind        IN VARCHAR2,
    x_creation_date     IN DATE,
    x_created_by        IN NUMBER,
    x_last_update_date  IN DATE,
    x_last_updated_by   IN NUMBER,
    x_last_update_login IN NUMBER,
    x_self_service      IN VARCHAR2,
    x_ivr_display_ind   IN VARCHAR2,
    x_bulk_job_ind      IN VARCHAR2,
    x_transfer_flag     IN VARCHAR2,
    x_dflt_trans_details_flag  IN VARCHAR2
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_enr_method_type,
      x_description,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_self_service ,
      x_ivr_display_ind ,
      x_bulk_job_ind,
      x_transfer_flag,
      x_dflt_trans_details_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
        IF Get_PK_For_Validation(
                 new_references.enr_method_type) THEN

           Fnd_message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
      IF  Get_PK_For_Validation ( new_references.enr_method_type) THEN
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

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID               IN OUT NOCOPY VARCHAR2,
  X_ENR_METHOD_TYPE     IN VARCHAR2,
  X_DESCRIPTION         IN VARCHAR2,
  X_CLOSED_IND          IN VARCHAR2,
  X_MODE                IN VARCHAR2,
  X_SELF_SERVICE        IN VARCHAR2,
  X_IVR_DISPLAY_IND     IN VARCHAR2,
  X_BULK_JOB_IND        IN VARCHAR2,
  X_TRANSFER_FLAG       IN VARCHAR2,
  X_DFLT_TRANS_DETAILS_FLAG  IN VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_EN_METHOD_TYPE
      where ENR_METHOD_TYPE = X_ENR_METHOD_TYPE;
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
    p_action            =>'INSERT',
    x_rowid             => X_ROWID,
    x_enr_method_type   => X_ENR_METHOD_TYPE,
    x_description       => X_DESCRIPTION,
    x_closed_ind        => NVL(X_CLOSED_IND,'N'),
    x_creation_date     => X_LAST_UPDATE_DATE,
    x_created_by        => X_LAST_UPDATED_BY,
    x_last_update_date  => X_LAST_UPDATE_DATE,
    x_last_updated_by   => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_self_service      => NVL(X_SELF_SERVICE,'N'),
    x_ivr_display_ind   => NVL(X_ivr_display_ind,'N'),
    x_bulk_job_ind      => NVL(x_bulk_job_ind,'N'),
    x_transfer_flag     => x_transfer_flag,
    x_dflt_trans_details_flag => x_dflt_trans_details_flag
  );
  insert into IGS_EN_METHOD_TYPE (
    ENR_METHOD_TYPE,
    DESCRIPTION,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SELF_SERVICE,
    IVR_DISPLAY_IND,
    BULK_JOB_IND,
    TRANSFER_FLAG,
    DFLT_TRANS_DETAILS_FLAG
  ) values (
    NEW_REFERENCES.ENR_METHOD_TYPE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.CLOSED_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.SELF_SERVICE,
    NEW_REFERENCES.IVR_DISPLAY_IND,
    NEW_REFERENCES.BULK_JOB_IND,
    NEW_REFERENCES.TRANSFER_FLAG,
    NEW_REFERENCES.DFLT_TRANS_DETAILS_FLAG
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  After_DML (
    p_action =>'INSERT',
    x_rowid => X_ROWID
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID               IN  VARCHAR2,
  X_ENR_METHOD_TYPE     IN VARCHAR2,
  X_DESCRIPTION         IN VARCHAR2,
  X_CLOSED_IND          IN VARCHAR2,
  X_SELF_SERVICE        IN VARCHAR2,
  X_IVR_DISPLAY_IND     IN VARCHAR2,
  X_BULK_JOB_IND        IN VARCHAR2,
  X_TRANSFER_FLAG       IN VARCHAR2,
  X_DFLT_TRANS_DETAILS_FLAG  IN VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      BULK_JOB_IND,
      CLOSED_IND,
      SELF_SERVICE,
      IVR_DISPLAY_IND,
      TRANSFER_FLAG,
      DFLT_TRANS_DETAILS_FLAG
    from IGS_EN_METHOD_TYPE
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
      AND (tlinfo.BULK_JOB_IND = X_BULK_JOB_IND)
      AND ((tlinfo.SELF_SERVICE = X_SELF_SERVICE)
           OR ((tlinfo.SELF_SERVICE is null)
           AND (X_SELF_SERVICE is null)))
      AND ((tlinfo.IVR_DISPLAY_IND = X_IVR_DISPLAY_IND)
           OR ((tlinfo.IVR_DISPLAY_IND is null)
           AND (X_IVR_DISPLAY_IND is null)))
      AND ((tlinfo.TRANSFER_FLAG = X_TRANSFER_FLAG)
           OR ((tlinfo.TRANSFER_FLAG is null)
           AND (X_TRANSFER_FLAG is null)))
      AND ((tlinfo.DFLT_TRANS_DETAILS_FLAG = X_DFLT_TRANS_DETAILS_FLAG)
           OR ((tlinfo.DFLT_TRANS_DETAILS_FLAG is null)
           AND (X_DFLT_TRANS_DETAILS_FLAG is null)))
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
  X_ROWID               IN VARCHAR2,
  X_ENR_METHOD_TYPE     IN VARCHAR2,
  X_DESCRIPTION         IN VARCHAR2,
  X_CLOSED_IND          IN VARCHAR2,
  X_MODE                IN VARCHAR2,
  X_SELF_SERVICE        IN VARCHAR2,
  X_IVR_DISPLAY_IND     IN VARCHAR2,
  X_BULK_JOB_IND        IN VARCHAR2,
  X_TRANSFER_FLAG       IN VARCHAR2,
  X_DFLT_TRANS_DETAILS_FLAG  IN VARCHAR2
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
  Before_DML (
    p_action            =>'UPDATE',
    x_rowid             => X_ROWID,
    x_enr_method_type   => X_ENR_METHOD_TYPE,
    x_description       => X_DESCRIPTION,
    x_closed_ind        => X_CLOSED_IND,
    x_creation_date     => X_LAST_UPDATE_DATE,
    x_created_by        => X_LAST_UPDATED_BY,
    x_last_update_date  => X_LAST_UPDATE_DATE,
    x_last_updated_by   => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_self_service      => X_SELF_SERVICE,
    x_ivr_display_ind   => X_IVR_DISPLAY_IND,
    x_bulk_job_ind      => X_BULK_JOB_IND,
    x_transfer_flag     => x_transfer_flag,
    x_dflt_trans_details_flag => x_dflt_trans_details_flag
  );
  update IGS_EN_METHOD_TYPE set
    DESCRIPTION         = NEW_REFERENCES.DESCRIPTION,
    CLOSED_IND          = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE    = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY     = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN   = X_LAST_UPDATE_LOGIN,
    SELF_SERVICE        = X_SELF_SERVICE,
    IVR_DISPLAY_IND     = X_IVR_DISPLAY_IND,
    BULK_JOB_IND        = X_BULK_JOB_IND,
    TRANSFER_FLAG       = X_TRANSFER_FLAG,
    DFLT_TRANS_DETAILS_FLAG = X_DFLT_TRANS_DETAILS_FLAG
  where ROWID           = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action =>'UPDATE',
    x_rowid => X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID               IN OUT NOCOPY VARCHAR2,
  X_ENR_METHOD_TYPE     IN VARCHAR2,
  X_DESCRIPTION         IN VARCHAR2,
  X_CLOSED_IND          IN VARCHAR2,
  X_MODE                IN VARCHAR2,
  X_SELF_SERVICE        IN VARCHAR2,
  X_IVR_DISPLAY_IND     IN VARCHAR2,
  X_BULK_JOB_IND        IN VARCHAR2,
  X_TRANSFER_FLAG       IN VARCHAR2,
  X_DFLT_TRANS_DETAILS_FLAG  IN VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_EN_METHOD_TYPE
     where ENR_METHOD_TYPE = X_ENR_METHOD_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ENR_METHOD_TYPE,
     X_DESCRIPTION,
     X_CLOSED_IND,
     X_MODE,
     X_SELF_SERVICE,
     X_IVR_DISPLAY_IND,
     X_BULK_JOB_IND,
     X_TRANSFER_FLAG,
     X_DFLT_TRANS_DETAILS_FLAG
    );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ENR_METHOD_TYPE,
   X_DESCRIPTION,
   X_CLOSED_IND,
   X_MODE,
   X_SELF_SERVICE,
   X_IVR_DISPLAY_IND,
   X_BULK_JOB_IND,
   X_TRANSFER_FLAG,
   X_DFLT_TRANS_DETAILS_FLAG
   );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
  Before_DML (
    p_action =>'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_EN_METHOD_TYPE
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action =>'DELETE',
    x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_EN_METHOD_TYPE_PKG;

/
