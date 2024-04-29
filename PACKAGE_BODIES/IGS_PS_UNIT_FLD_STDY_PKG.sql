--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNIT_FLD_STDY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNIT_FLD_STDY_PKG" AS
/* $Header: IGSPI0GB.pls 115.7 2003/03/21 07:58:28 sarakshi ship $ */
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/
  l_rowid VARCHAR2(25);
  old_references igs_ps_unit_fld_stdy%RowType;
  new_references igs_ps_unit_fld_stdy%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_field_of_study_id IN NUMBER DEFAULT NULL,
    x_unit_code IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_UNIT_FLD_STDY
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
    new_references.unit_field_of_study_id := x_unit_field_of_study_id;
    new_references.unit_code := x_unit_code;
    new_references.version_number := x_version_number;
    new_references.field_of_study := x_field_of_study;
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

  PROCEDURE Check_Uniqueness AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
     	IF Get_Uk_For_Validation (
      	  new_references.field_of_study,
    	  new_references.unit_code,
   	  new_references.version_number
    	) THEN
 	  Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
    	END IF;
  END Check_Uniqueness ;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN

    IF (((old_references.unit_code = new_references.unit_code) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.unit_code IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Unit_Ver_Pkg.Get_PK_For_Validation (
        		new_references.unit_code,
        		new_references.version_number
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_field_of_study_id IN NUMBER
    ) RETURN BOOLEAN AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_fld_stdy
      WHERE    unit_field_of_study_id = x_unit_field_of_study_id
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
    x_field_of_study IN VARCHAR2,
    x_unit_code IN VARCHAR2,
    x_version_number IN NUMBER
    ) RETURN BOOLEAN AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_fld_stdy
      WHERE    field_of_study = x_field_of_study
      AND      unit_code = x_unit_code
      AND      version_number = x_version_number
      AND      ((l_rowid is null) or (rowid <> l_rowid));

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
  END Get_UK_For_Validation;

  PROCEDURE Get_FK_Igs_Ps_Fld_Of_Study (
    x_field_of_study IN VARCHAR2
    ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_fld_stdy
      WHERE    field_of_study = x_field_of_study;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UFS_FOS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ps_Fld_Of_Study;

  PROCEDURE Get_FK_Igs_Ps_Unit_Ver (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_fld_stdy
      WHERE    unit_code = x_unit_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UFS_UV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ps_Unit_Ver;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_field_of_study_id IN NUMBER DEFAULT NULL,
    x_unit_code IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
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
      x_unit_field_of_study_id,
      x_unit_code,
      x_version_number,
      x_field_of_study,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	     IF Get_Pk_For_Validation(
    		new_references.unit_field_of_study_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
               IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
         IF Get_PK_For_Validation (
    		new_references.unit_field_of_study_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
               IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	 END IF;
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;

  l_rowid:=NULL;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/
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

    l_rowid:=NULL;

  END After_DML;

  procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_FIELD_OF_STUDY_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_FIELD_OF_STUDY IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PS_UNIT_FLD_STDY
             where UNIT_FIELD_OF_STUDY_ID= X_UNIT_FIELD_OF_STUDY_ID;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
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
       SELECT   igs_ps_unit_fld_stdy_s.nextval
       INTO     x_unit_field_of_study_id
       FROM     dual;
       Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_unit_field_of_study_id=>X_UNIT_FIELD_OF_STUDY_ID,
 	       x_unit_code=>X_UNIT_CODE,
 	       x_version_number=>X_VERSION_NUMBER,
 	       x_field_of_study=>X_FIELD_OF_STUDY,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
       insert into IGS_PS_UNIT_FLD_STDY (
		UNIT_FIELD_OF_STUDY_ID
		,UNIT_CODE
		,VERSION_NUMBER
		,FIELD_OF_STUDY
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.UNIT_FIELD_OF_STUDY_ID
	        ,NEW_REFERENCES.UNIT_CODE
	        ,NEW_REFERENCES.VERSION_NUMBER
	        ,NEW_REFERENCES.FIELD_OF_STUDY
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
        );
		open c;
		 fetch c into X_ROWID;
 		if (c%notfound) then
		close c;
 	     raise no_data_found;
		end if;
 		close c;
         After_DML (
		p_action => 'INSERT' ,
		x_rowid => X_ROWID );
  END INSERT_ROW;
  PROCEDURE LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_FIELD_OF_STUDY_ID IN NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_FIELD_OF_STUDY IN VARCHAR2  ) AS
   cursor c1 is select
      UNIT_CODE
,      VERSION_NUMBER
,      FIELD_OF_STUDY
    from IGS_PS_UNIT_FLD_STDY
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
if ( (  tlinfo.UNIT_CODE = X_UNIT_CODE)
  AND (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
  AND (tlinfo.FIELD_OF_STUDY = X_FIELD_OF_STUDY)
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
       x_UNIT_FIELD_OF_STUDY_ID IN NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_FIELD_OF_STUDY IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
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
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_unit_field_of_study_id=>X_UNIT_FIELD_OF_STUDY_ID,
 	       x_unit_code=>X_UNIT_CODE,
 	       x_version_number=>X_VERSION_NUMBER,
 	       x_field_of_study=>X_FIELD_OF_STUDY,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_PS_UNIT_FLD_STDY set
      UNIT_CODE =  NEW_REFERENCES.UNIT_CODE,
      VERSION_NUMBER =  NEW_REFERENCES.VERSION_NUMBER,
      FIELD_OF_STUDY =  NEW_REFERENCES.FIELD_OF_STUDY,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
	  where ROWID = X_ROWID;
	if (sql%notfound) then
		raise no_data_found;
	end if;

 After_DML (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID
	);
  end UPDATE_ROW;

  procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_FIELD_OF_STUDY_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_FIELD_OF_STUDY IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/
    cursor c1 is select ROWID from IGS_PS_UNIT_FLD_STDY
             where     UNIT_FIELD_OF_STUDY_ID= X_UNIT_FIELD_OF_STUDY_ID ;
  begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_UNIT_FIELD_OF_STUDY_ID,
       X_UNIT_CODE,
       X_VERSION_NUMBER,
       X_FIELD_OF_STUDY,
      X_MODE );
     return;
	end if;
	   close c1;
  UPDATE_ROW (
      X_ROWID,
       X_UNIT_FIELD_OF_STUDY_ID,
       X_UNIT_CODE,
       X_VERSION_NUMBER,
       X_FIELD_OF_STUDY,
      X_MODE );
  end ADD_ROW;

  procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
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
 delete from IGS_PS_UNIT_FLD_STDY
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
END DELETE_ROW;

END igs_ps_unit_fld_stdy_pkg;

/
