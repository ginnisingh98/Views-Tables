--------------------------------------------------------
--  DDL for Package Body IGS_PS_FACLTY_DEGRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_FACLTY_DEGRS_PKG" AS
/* $Header: IGSPI0OB.pls 120.1 2005/06/28 06:23:35 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ps_faclty_degrs%RowType;
  new_references igs_ps_faclty_degrs%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_faclty_degrd_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_degree_cd IN VARCHAR2 DEFAULT NULL,
    x_program IN VARCHAR2 DEFAULT NULL,
    x_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_degree_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_FACLTY_DEGRS
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
    new_references.faclty_degrd_id := x_faclty_degrd_id;
    new_references.person_id := x_person_id;
    new_references.degree_cd := x_degree_cd;
    new_references.program := x_program;
    new_references.institution_cd := x_institution_cd;
    new_references.degree_date := x_degree_date;
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
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur      26-03-2002       restricted program column to upper case only.
                                 for bug:2082568.
  ***************************************************************/

  BEGIN

    IF column_name IS NULL THEN
      NULL;
    ELSIF UPPER(column_name) = 'PROGRAM' THEN
      new_references.program := column_value;
    END IF;

   --If entered value in program column is not in upper case ,error out.
    IF UPPER(column_name) = 'PROGRAM' OR column_name IS NULL THEN
      IF new_references.program <> UPPER(new_references.program) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

  END Check_Constraints;

 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.degree_cd
    		,new_references.person_id
                ,new_references.program
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.degree_cd = new_references.degree_cd)) OR
        ((new_references.degree_cd IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Degrees_Pkg.Get_PK_For_Validation (
        		new_references.degree_cd
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.institution_cd = new_references.institution_cd)) OR
        ((new_references.institution_cd IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Or_Institution_Pkg.Get_PK_For_Validation (
        		new_references.institution_cd
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Pkg.Get_PK_For_Validation (
        		new_references.person_id
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_faclty_degrd_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_faclty_degrs
      WHERE    faclty_degrd_id = x_faclty_degrd_id
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

  FUNCTION get_uk_for_validation (
    x_degree_cd IN VARCHAR2,
    x_person_id IN NUMBER,
    x_program   IN VARCHAR2  --for bug:2082568
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  vvutukur       14-MAR-2002     added program column also as a part
                                 of unique key for bug:2082568.
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_faclty_degrs
      WHERE    degree_cd = x_degree_cd
      AND      person_id = x_person_id
      AND      program   = x_program
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;
  END get_uk_for_validation;

  PROCEDURE Get_FK_Igs_Ps_Degrees (
    x_degree_cd IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_faclty_degrs
      WHERE    degree_cd = x_degree_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_FD_DEG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ps_Degrees;

  PROCEDURE Get_FK_Igs_Or_Institution (
    x_institution_cd IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_faclty_degrs
      WHERE    institution_cd = x_institution_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_FD_INS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Or_Institution;

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_faclty_degrs
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_FD_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_faclty_degrd_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_degree_cd IN VARCHAR2 DEFAULT NULL,
    x_program IN VARCHAR2 DEFAULT NULL,
    x_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_degree_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_faclty_degrd_id,
      x_person_id,
      x_degree_cd,
      x_program,
      x_institution_cd,
      x_degree_date,
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
    		new_references.faclty_degrd_id)  THEN
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
    		new_references.faclty_degrd_id)  THEN
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
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
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
       x_FACLTY_DEGRD_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DEGREE_CD IN VARCHAR2,
       x_PROGRAM IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_DEGREE_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) AS

  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PS_FACLTY_DEGRS
             where                 FACLTY_DEGRD_ID= X_FACLTY_DEGRD_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (X_MODE IN ('R', 'S')) then
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
       SELECT IGS_PS_FACLTY_DEGRD_ID_S.nextval INTO x_FACLTY_DEGRD_ID FROM dual;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_faclty_degrd_id=>X_FACLTY_DEGRD_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_degree_cd=>X_DEGREE_CD,
 	       x_program=>X_PROGRAM,
 	       x_institution_cd=>X_INSTITUTION_CD,
 	       x_degree_date=>X_DEGREE_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_PS_FACLTY_DEGRS (
		FACLTY_DEGRD_ID
		,PERSON_ID
		,DEGREE_CD
		,PROGRAM
		,INSTITUTION_CD
		,DEGREE_DATE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.FACLTY_DEGRD_ID
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.DEGREE_CD
	        ,NEW_REFERENCES.PROGRAM
	        ,NEW_REFERENCES.INSTITUTION_CD
	        ,NEW_REFERENCES.DEGREE_DATE
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
);
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

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
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end INSERT_ROW;
 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_FACLTY_DEGRD_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DEGREE_CD IN VARCHAR2,
       x_PROGRAM IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_DEGREE_DATE IN DATE  ) AS
  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      PERSON_ID
,      DEGREE_CD
,      PROGRAM
,      INSTITUTION_CD
,      DEGREE_DATE
    from IGS_PS_FACLTY_DEGRS
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
if ( (  tlinfo.PERSON_ID = X_PERSON_ID)
  AND (tlinfo.DEGREE_CD = X_DEGREE_CD)
  AND (tlinfo.PROGRAM = X_PROGRAM)
  AND (tlinfo.INSTITUTION_CD = X_INSTITUTION_CD)
  AND (tlinfo.DEGREE_DATE = X_DEGREE_DATE)
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
       x_FACLTY_DEGRD_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DEGREE_CD IN VARCHAR2,
       x_PROGRAM IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_DEGREE_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
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
         elsif (X_MODE IN ('R', 'S')) then
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
 	       x_faclty_degrd_id=>X_FACLTY_DEGRD_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_degree_cd=>X_DEGREE_CD,
 	       x_program=>X_PROGRAM,
 	       x_institution_cd=>X_INSTITUTION_CD,
 	       x_degree_date=>X_DEGREE_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_PS_FACLTY_DEGRS set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      DEGREE_CD =  NEW_REFERENCES.DEGREE_CD,
      PROGRAM =  NEW_REFERENCES.PROGRAM,
      INSTITUTION_CD =  NEW_REFERENCES.INSTITUTION_CD,
      DEGREE_DATE =  NEW_REFERENCES.DEGREE_DATE,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
	  where ROWID = X_ROWID;
	if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
	end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


 After_DML (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID
	);
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_FACLTY_DEGRD_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DEGREE_CD IN VARCHAR2,
       x_PROGRAM IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_DEGREE_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PS_FACLTY_DEGRS
             where     FACLTY_DEGRD_ID= X_FACLTY_DEGRD_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_FACLTY_DEGRD_ID,
       X_PERSON_ID,
       X_DEGREE_CD,
       X_PROGRAM,
       X_INSTITUTION_CD,
       X_DEGREE_DATE,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_FACLTY_DEGRD_ID,
       X_PERSON_ID,
       X_DEGREE_CD,
       X_PROGRAM,
       X_INSTITUTION_CD,
       X_DEGREE_DATE,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
  /*************************************************************
  Created By :ssuri
  Date Created By :11-MAY-2000
  Purpose :NEW TABLE
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
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_PS_FACLTY_DEGRS
 where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ps_faclty_degrs_pkg;

/
