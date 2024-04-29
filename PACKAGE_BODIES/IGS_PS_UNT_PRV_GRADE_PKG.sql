--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNT_PRV_GRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNT_PRV_GRADE_PKG" AS
/* $Header: IGSPI0BB.pls 115.7 2002/11/29 01:55:10 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ps_unt_prv_grade%RowType;
  new_references igs_ps_unt_prv_grade%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_prev_grade_id IN NUMBER DEFAULT NULL,
    x_unit_code IN VARCHAR2 DEFAULT NULL,
    x_unit_version_number IN NUMBER DEFAULT NULL,
    x_grading_schema_code IN VARCHAR2 DEFAULT NULL,
    x_grading_schema_ver_num IN NUMBER DEFAULT NULL,
    x_grading_schema_value IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_UNT_PRV_GRADE
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
    new_references.unit_prev_grade_id := x_unit_prev_grade_id;
    new_references.unit_code := x_unit_code;
    new_references.unit_version_number := x_unit_version_number;
    new_references.grading_schema_code := x_grading_schema_code;
    new_references.grading_schema_version_number := x_grading_schema_ver_num;
    new_references.grading_schema_value := x_grading_schema_value;
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
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
        NULL;
      END IF;




  END Check_Constraints;

 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.unit_code
    		,new_references.unit_version_number
    		,new_references.grading_schema_code
    		,new_references.grading_schema_value
    		,new_references.grading_schema_version_number
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.grading_schema_code = new_references.grading_schema_code) AND
         (old_references.grading_schema_version_number = new_references.grading_schema_version_number) AND
         (old_references.grading_schema_value = new_references.grading_schema_value)) OR
        ((new_references.grading_schema_code IS NULL) OR
         (new_references.grading_schema_version_number IS NULL) OR
         (new_references.grading_schema_value IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_As_Grd_Sch_Grade_Pkg.Get_PK_For_Validation (
        		new_references.grading_schema_code,
         		 new_references.grading_schema_version_number,
         		 new_references.grading_schema_value
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.unit_code = new_references.unit_code) AND
         (old_references.unit_version_number = new_references.unit_version_number)) OR
        ((new_references.unit_code IS NULL) OR
         (new_references.unit_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Unit_Ver_Pkg.Get_PK_For_Validation (
        		new_references.unit_code,
         		 new_references.unit_version_number
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_prev_grade_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unt_prv_grade
      WHERE    unit_prev_grade_id = x_unit_prev_grade_id
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
    x_unit_code IN VARCHAR2,
    x_unit_version_number IN NUMBER,
    x_grading_schema_code IN VARCHAR2,
    x_grading_schema_value IN VARCHAR2,
    x_grading_schema_ver_num IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unt_prv_grade
      WHERE    unit_code = x_unit_code
      AND      unit_version_number = x_unit_version_number
      AND      grading_schema_code = x_grading_schema_code
      AND      grading_schema_value = x_grading_schema_value
      AND      grading_schema_version_number = x_grading_schema_ver_num 	and      ((l_rowid is null) or (rowid <> l_rowid))

      ;
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
  PROCEDURE Get_FK_Igs_As_Grd_Sch_Grade (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2
    ) AS

  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unt_prv_grade
      WHERE    grading_schema_code = x_grading_schema_cd
      AND      grading_schema_version_number = x_version_number
      AND      grading_schema_value = x_grade ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UPG_GSG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_As_Grd_Sch_Grade;

  PROCEDURE Get_FK_Igs_Ps_Unit_Ver (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unt_prv_grade
      WHERE    unit_code = x_unit_cd
      AND      unit_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UPG_UV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ps_Unit_Ver;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_prev_grade_id IN NUMBER DEFAULT NULL,
    x_unit_code IN VARCHAR2 DEFAULT NULL,
    x_unit_version_number IN NUMBER DEFAULT NULL,
    x_grading_schema_code IN VARCHAR2 DEFAULT NULL,
    x_grading_schema_ver_num IN NUMBER DEFAULT NULL,
    x_grading_schema_value IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_prev_grade_id,
      x_unit_code,
      x_unit_version_number,
      x_grading_schema_code,
      x_grading_schema_ver_num,
      x_grading_schema_value,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.unit_prev_grade_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.unit_prev_grade_id)  THEN
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
      Null;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
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
       x_UNIT_PREV_GRADE_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_GRADING_SCHEMA_CODE IN VARCHAR2,
       x_GRADING_SCHEMA_VER_NUM IN NUMBER,
       x_GRADING_SCHEMA_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PS_UNT_PRV_GRADE
             where                 UNIT_PREV_GRADE_ID= X_UNIT_PREV_GRADE_ID
;
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
   select igs_ps_unt_prv_grade_s.nextval
   into x_unit_prev_grade_id
   from dual;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_unit_prev_grade_id=>X_UNIT_PREV_GRADE_ID,
 	       x_unit_code=>X_UNIT_CODE,
 	       x_unit_version_number=>X_UNIT_VERSION_NUMBER,
 	       x_grading_schema_code=>X_GRADING_SCHEMA_CODE,
 	       x_grading_schema_ver_num=>X_GRADING_SCHEMA_VER_NUM,
 	       x_grading_schema_value=>X_GRADING_SCHEMA_VALUE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_PS_UNT_PRV_GRADE (
		UNIT_PREV_GRADE_ID
		,UNIT_CODE
		,UNIT_VERSION_NUMBER
		,GRADING_SCHEMA_CODE
		,GRADING_SCHEMA_VERSION_NUMBER
		,GRADING_SCHEMA_VALUE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.UNIT_PREV_GRADE_ID
	        ,NEW_REFERENCES.UNIT_CODE
	        ,NEW_REFERENCES.UNIT_VERSION_NUMBER
	        ,NEW_REFERENCES.GRADING_SCHEMA_CODE
	        ,NEW_REFERENCES.GRADING_SCHEMA_VERSION_NUMBER
	        ,NEW_REFERENCES.GRADING_SCHEMA_VALUE
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
end INSERT_ROW;
 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_PREV_GRADE_ID IN NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_GRADING_SCHEMA_CODE IN VARCHAR2,
       x_GRADING_SCHEMA_VER_NUM IN NUMBER,
       x_GRADING_SCHEMA_VALUE IN VARCHAR2  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      UNIT_CODE
,      UNIT_VERSION_NUMBER
,      GRADING_SCHEMA_CODE
,      GRADING_SCHEMA_VERSION_NUMBER
,      GRADING_SCHEMA_VALUE
    from IGS_PS_UNT_PRV_GRADE
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
  AND (tlinfo.UNIT_VERSION_NUMBER = X_UNIT_VERSION_NUMBER)
  AND (tlinfo.GRADING_SCHEMA_CODE = X_GRADING_SCHEMA_CODE)
  AND (tlinfo.GRADING_SCHEMA_VERSION_NUMBER = X_GRADING_SCHEMA_VER_NUM)
  AND (tlinfo.GRADING_SCHEMA_VALUE = X_GRADING_SCHEMA_VALUE)
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
       x_UNIT_PREV_GRADE_ID IN NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_GRADING_SCHEMA_CODE IN VARCHAR2,
       x_GRADING_SCHEMA_VER_NUM IN NUMBER,
       x_GRADING_SCHEMA_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
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
 	       x_unit_prev_grade_id=>X_UNIT_PREV_GRADE_ID,
 	       x_unit_code=>X_UNIT_CODE,
 	       x_unit_version_number=>X_UNIT_VERSION_NUMBER,
 	       x_grading_schema_code=>X_GRADING_SCHEMA_CODE,
 	       x_grading_schema_ver_num=>X_GRADING_SCHEMA_VER_NUM,
 	       x_grading_schema_value=>X_GRADING_SCHEMA_VALUE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_PS_UNT_PRV_GRADE set
      UNIT_CODE =  NEW_REFERENCES.UNIT_CODE,
      UNIT_VERSION_NUMBER =  NEW_REFERENCES.UNIT_VERSION_NUMBER,
      GRADING_SCHEMA_CODE =  NEW_REFERENCES.GRADING_SCHEMA_CODE,
      GRADING_SCHEMA_VERSION_NUMBER =  NEW_REFERENCES.GRADING_SCHEMA_VERSION_NUMBER,
      GRADING_SCHEMA_VALUE =  NEW_REFERENCES.GRADING_SCHEMA_VALUE,
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
       x_UNIT_PREV_GRADE_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_GRADING_SCHEMA_CODE IN VARCHAR2,
       x_GRADING_SCHEMA_VER_NUM IN NUMBER,
       x_GRADING_SCHEMA_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PS_UNT_PRV_GRADE
             where     UNIT_PREV_GRADE_ID= X_UNIT_PREV_GRADE_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_UNIT_PREV_GRADE_ID,
       X_UNIT_CODE,
       X_UNIT_VERSION_NUMBER,
       X_GRADING_SCHEMA_CODE,
       X_GRADING_SCHEMA_VER_NUM,
       X_GRADING_SCHEMA_VALUE,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_UNIT_PREV_GRADE_ID,
       X_UNIT_CODE,
       X_UNIT_VERSION_NUMBER,
       X_GRADING_SCHEMA_CODE,
       X_GRADING_SCHEMA_VER_NUM,
       X_GRADING_SCHEMA_VALUE,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 5-MAY-2000
  Purpose : Creation of TBH
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
 delete from IGS_PS_UNT_PRV_GRADE
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ps_unt_prv_grade_pkg;

/
