--------------------------------------------------------
--  DDL for Package Body IGS_GE_REF_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_REF_CD_PKG" AS
/* $Header: IGSMI16B.pls 120.1 2005/07/11 03:07:27 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ge_ref_cd%RowType;
  new_references igs_ge_ref_cd%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_reference_code_id IN NUMBER DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_reference_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_default_flag IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GE_REF_CD
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
    new_references.reference_code_id := x_reference_code_id;
    new_references.reference_cd_type := x_reference_cd_type;
    new_references.reference_cd := x_reference_cd;
    new_references.description := x_description;
    new_references.default_flag := x_default_flag;
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
  Created By : sbeerell
  Date Created By : 10-MAY-2000
  Purpose :
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
  Created By : sbeerell
  Date Created By :10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.reference_cd_type
    		,new_references.reference_cd
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.reference_cd_type = new_references.reference_cd_type)) OR
        ((new_references.reference_cd_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ge_Ref_Cd_Type_Pkg.Get_PK_For_Validation (
        		new_references.reference_cd_type
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   swaghmar     11-JULY-2005    Bug#4327987 Added a call to
				igs_as_sua_ref_cds_pkg.get_UFK_Igs_As_Sua_Ref_Cds
				to check for existing child
				Student Unit Reference Codes
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
    igs_ps_ref_cd_pkg.Get_UFK_Igs_Ge_Ref_Cd (
      old_references.reference_cd_type,
      old_references.reference_cd);

    igs_ps_ent_pt_ref_cd_pkg.Get_UFK_Igs_Ge_Ref_Cd (
      old_references.reference_cd_type,
      old_references.reference_cd);

    Igs_Ps_Usec_Ref_Cd_Pkg.Get_UFK_Igs_Ge_Ref_Cd (
      old_references.reference_cd_type,
      old_references.reference_cd);

    igs_ps_unitreqref_cd_pkg.get_UFK_Igs_Ge_Ref_Cd (
      old_references.reference_cd_type,
      old_references.reference_cd
      );
    igs_ps_us_req_ref_cd_pkg.get_UFK_Igs_Ge_Ref_Cd (
      old_references.reference_cd_type,
      old_references.reference_cd);

    igs_ps_usec_ocur_ref_pkg.get_UFK_Igs_Ge_Ref_Cd (
      old_references.reference_cd_type,
      old_references.reference_cd);

    igs_ps_unit_ref_cd_pkg.get_UFK_Igs_Ge_Ref_Cd (
      old_references.reference_cd_type,
      old_references.reference_cd);

    -- swaghmar 11-JULY-2005 Bug#4327987
    -- Added a call to igs_as_sua_ref_cds_pkg.get_UFK_Igs_As_Sua_Ref_Cds to check for existing
    -- child Student Unit Reference Codes

    igs_as_sua_ref_cds_pkg.get_UFK_Igs_As_Sua_Ref_Cds (
      old_references.reference_cd_type,
      old_references.reference_cd);

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_reference_code_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ge_ref_cd
      WHERE    reference_code_id = x_reference_code_id
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
    x_reference_cd_type IN VARCHAR2,
    x_reference_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ge_ref_cd
      WHERE    reference_cd_type = x_reference_cd_type
      AND      reference_cd = x_reference_cd 	and      ((l_rowid is null) or (rowid <> l_rowid))

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
  PROCEDURE Get_FK_Igs_Ge_Ref_Cd_Type (
    x_reference_cd_type IN VARCHAR2
    ) AS

  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ge_ref_cd
      WHERE    reference_cd_type = x_reference_cd_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_RC_RCT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ge_Ref_Cd_Type;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_reference_code_id IN NUMBER DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_reference_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_default_flag IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
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
      x_reference_code_id,
      x_reference_cd_type,
      x_reference_cd,
      x_description,
      x_default_flag,
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
    		new_references.reference_code_id)  THEN
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
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.reference_code_id)  THEN
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

l_rowid :=NULL;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
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

    l_rowid :=NULL;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_REFERENCE_CODE_ID IN OUT NOCOPY NUMBER,
       x_REFERENCE_CD_TYPE IN VARCHAR2,
       x_REFERENCE_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_DEFAULT_FLAG IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_GE_REF_CD
             where                 REFERENCE_CODE_ID= X_REFERENCE_CODE_ID
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
 SELECT IGS_GE_REF_CD_S.NEXTVAL
     INTO X_REFERENCE_CODE_ID FROM Dual;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_reference_code_id=>X_REFERENCE_CODE_ID,
 	       x_reference_cd_type=>X_REFERENCE_CD_TYPE,
 	       x_reference_cd=>X_REFERENCE_CD,
 	       x_description=>X_DESCRIPTION,
 	       x_default_flag=>X_DEFAULT_FLAG,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_GE_REF_CD (
		REFERENCE_CODE_ID
		,REFERENCE_CD_TYPE
		,REFERENCE_CD
		,DESCRIPTION
		,DEFAULT_FLAG
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.REFERENCE_CODE_ID
	        ,NEW_REFERENCES.REFERENCE_CD_TYPE
	        ,NEW_REFERENCES.REFERENCE_CD
	        ,NEW_REFERENCES.DESCRIPTION
	        ,NEW_REFERENCES.DEFAULT_FLAG
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
       x_REFERENCE_CODE_ID IN NUMBER,
       x_REFERENCE_CD_TYPE IN VARCHAR2,
       x_REFERENCE_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_DEFAULT_FLAG IN VARCHAR2  ) AS
  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      REFERENCE_CD_TYPE
,      REFERENCE_CD
,      DESCRIPTION
,      DEFAULT_FLAG
    from IGS_GE_REF_CD
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
if ( (  tlinfo.REFERENCE_CD_TYPE = X_REFERENCE_CD_TYPE)
  AND (tlinfo.REFERENCE_CD = X_REFERENCE_CD)
  AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
  AND (tlinfo.DEFAULT_FLAG = X_DEFAULT_FLAG)
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
       x_REFERENCE_CODE_ID IN NUMBER,
       x_REFERENCE_CD_TYPE IN VARCHAR2,
       x_REFERENCE_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_DEFAULT_FLAG IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
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
 	       x_reference_code_id=>X_REFERENCE_CODE_ID,
 	       x_reference_cd_type=>X_REFERENCE_CD_TYPE,
 	       x_reference_cd=>X_REFERENCE_CD,
 	       x_description=>X_DESCRIPTION,
 	       x_default_flag=>X_DEFAULT_FLAG,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_GE_REF_CD set
      REFERENCE_CD_TYPE =  NEW_REFERENCES.REFERENCE_CD_TYPE,
      REFERENCE_CD =  NEW_REFERENCES.REFERENCE_CD,
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
      DEFAULT_FLAG =  NEW_REFERENCES.DEFAULT_FLAG,
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
       x_REFERENCE_CODE_ID IN OUT NOCOPY NUMBER,
       x_REFERENCE_CD_TYPE IN VARCHAR2,
       x_REFERENCE_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_DEFAULT_FLAG IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_GE_REF_CD
             where     REFERENCE_CODE_ID= X_REFERENCE_CODE_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_REFERENCE_CODE_ID,
       X_REFERENCE_CD_TYPE,
       X_REFERENCE_CD,
       X_DESCRIPTION,
       X_DEFAULT_FLAG,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_REFERENCE_CODE_ID,
       X_REFERENCE_CD_TYPE,
       X_REFERENCE_CD,
       X_DESCRIPTION,
       X_DEFAULT_FLAG,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
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
 delete from IGS_GE_REF_CD
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ge_ref_cd_pkg;

/
