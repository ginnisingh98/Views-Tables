--------------------------------------------------------
--  DDL for Package Body IGS_PS_OCCUP_TITLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_OCCUP_TITLES_PKG" AS
/* $Header: IGSPI0FB.pls 115.10 2003/03/21 08:13:27 sarakshi ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ps_occup_titles_all%RowType;
  new_references igs_ps_occup_titles_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_prgm_occupational_title_id IN NUMBER DEFAULT NULL,
    x_program_code IN VARCHAR2 DEFAULT NULL,
    x_occupational_title_code IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id  IN NUMBER DEFAULT NULL
  ) AS


/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/



    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_OCCUP_TITLES_ALL
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
    new_references.program_occupational_title_id := x_prgm_occupational_title_id;
    new_references.program_code := x_program_code;
    new_references.occupational_title_code := x_occupational_title_code;
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
    new_references.org_id := x_org_id;
  END Set_Column_Values;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) AS

/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
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
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/



   begin
     		IF Get_Uk_For_Validation (
    		new_references.occupational_title_code
    		,new_references.program_code
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS

/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks : A cursor has been added for
checking whether a record exist in the parent table or not. This done in this
way because the parent table IGS_PS_VER has composite primary key ,where as this table is referencing only Program Code
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_VER_ALL
      WHERE    course_cd =new_references.Program_Code
      FOR UPDATE NOWAIT;

lv_rowid cur_rowid%RowType;

  BEGIN

    IF (((old_references.occupational_title_code = new_references.occupational_title_code)) OR
        ((new_references.occupational_title_code IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Dic_Occ_Titls_Pkg.Get_PK_For_Validation (
        		new_references.occupational_title_code
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
        IF (cur_rowid%NOTFOUND) THEN
         Close cur_rowid;
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
        END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_prgm_occupational_title_id IN NUMBER
    ) RETURN BOOLEAN AS

/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/


    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_occup_titles_all
      WHERE    program_occupational_title_id = x_prgm_occupational_title_id
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
    x_occupational_title_code IN VARCHAR2,
    x_program_code IN VARCHAR2
    ) RETURN BOOLEAN AS

/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/



    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_occup_titles_all
      WHERE    occupational_title_code = x_occupational_title_code
      AND      program_code = x_program_code 	and      ((l_rowid is null) or (rowid <> l_rowid))

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
  PROCEDURE Get_FK_Igs_Ps_Dic_Occ_Titls (
    x_occupational_title_code IN VARCHAR2
    ) AS

/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_occup_titles_all
      WHERE    occupational_title_code = x_occupational_title_code ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_OCT_DOT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ps_Dic_Occ_Titls;

PROCEDURE Get_FK_Igs_Ps_Ver (
    x_program_code IN VARCHAR2
    ) AS

/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_occup_titles_all
      WHERE    program_code = x_program_code ;

    lv_rowid cur_rowid%RowType;

  BEGIN

   Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_OCT_CRV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ps_Ver;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_prgm_occupational_title_id IN NUMBER DEFAULT NULL,
    x_program_code IN VARCHAR2 DEFAULT NULL,
    x_occupational_title_code IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
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
      x_prgm_occupational_title_id,
      x_program_code,
      x_occupational_title_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.program_occupational_title_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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
    		new_references.program_occupational_title_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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

    l_rowid:=NULL;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS

/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
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
       x_PRGM_OCCUPATIONAL_TITLE_ID IN OUT NOCOPY NUMBER,
       x_PROGRAM_CODE IN VARCHAR2,
       x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R',
      X_ORG_ID IN NUMBER
  ) AS

/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PS_OCCUP_TITLES
             where                 PROGRAM_OCCUPATIONAL_TITLE_ID= X_PRGM_OCCUPATIONAL_TITLE_ID
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

  SELECT igs_ps_dic_occ_titls_s.nextval
  INTO x_prgm_occupational_title_id
  FROM dual;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_prgm_occupational_title_id=>X_PRGM_OCCUPATIONAL_TITLE_ID,
 	       x_program_code=>X_PROGRAM_CODE,
 	       x_occupational_title_code=>X_OCCUPATIONAL_TITLE_CODE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_org_id => igs_ge_gen_003.get_org_id);
     insert into IGS_PS_OCCUP_TITLES (
		PROGRAM_OCCUPATIONAL_TITLE_ID
		,PROGRAM_CODE
		,OCCUPATIONAL_TITLE_CODE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,ORG_ID
        ) values  (
	        NEW_REFERENCES.PROGRAM_OCCUPATIONAL_TITLE_ID
	        ,NEW_REFERENCES.PROGRAM_CODE
	        ,NEW_REFERENCES.OCCUPATIONAL_TITLE_CODE
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,NEW_REFERENCES.ORG_ID
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
       x_PRGM_OCCUPATIONAL_TITLE_ID IN NUMBER,
       x_PROGRAM_CODE IN VARCHAR2,
       x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2  ) AS
/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      PROGRAM_CODE
,      OCCUPATIONAL_TITLE_CODE
    from IGS_PS_OCCUP_TITLES_ALL
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
if ( (  tlinfo.PROGRAM_CODE = X_PROGRAM_CODE)
  AND (tlinfo.OCCUPATIONAL_TITLE_CODE = X_OCCUPATIONAL_TITLE_CODE)
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
       x_PRGM_OCCUPATIONAL_TITLE_ID IN NUMBER,
       x_PROGRAM_CODE IN VARCHAR2,
       x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
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
 	       x_prgm_occupational_title_id=>X_PRGM_OCCUPATIONAL_TITLE_ID,
 	       x_program_code=>X_PROGRAM_CODE,
 	       x_occupational_title_code=>X_OCCUPATIONAL_TITLE_CODE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_PS_OCCUP_TITLES_ALL set
      PROGRAM_CODE =  NEW_REFERENCES.PROGRAM_CODE,
      OCCUPATIONAL_TITLE_CODE =  NEW_REFERENCES.OCCUPATIONAL_TITLE_CODE,
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
       x_PRGM_OCCUPATIONAL_TITLE_ID IN OUT NOCOPY NUMBER,
       x_PROGRAM_CODE IN VARCHAR2,
       x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
      X_ORG_ID IN NUMBER
  ) AS

/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/



    cursor c1 is select ROWID from IGS_PS_OCCUP_TITLES_ALL
             where     PROGRAM_OCCUPATIONAL_TITLE_ID= X_PRGM_OCCUPATIONAL_TITLE_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_PRGM_OCCUPATIONAL_TITLE_ID,
       X_PROGRAM_CODE,
       X_OCCUPATIONAL_TITLE_CODE,
      X_MODE,
      X_ORG_ID);
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_PRGM_OCCUPATIONAL_TITLE_ID,
       X_PROGRAM_CODE,
       X_OCCUPATIONAL_TITLE_CODE,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS

/*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
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
 delete from IGS_PS_OCCUP_TITLES
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ps_occup_titles_pkg;

/
