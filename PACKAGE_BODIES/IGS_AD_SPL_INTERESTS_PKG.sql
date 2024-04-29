--------------------------------------------------------
--  DDL for Package Body IGS_AD_SPL_INTERESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_SPL_INTERESTS_PKG" AS
/* $Header: IGSAI96B.pls 120.3 2005/10/03 08:20:51 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_spl_interests%RowType;
  new_references igs_ad_spl_interests%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_spl_interest_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_special_interest_type_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_SPL_INTERESTS
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
    new_references.spl_interest_id := x_spl_interest_id;
    new_references.person_id := x_person_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.special_interest_type_id := x_special_interest_type_id;
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
  Created By :
  Date Created By :
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
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.special_interest_type_id
    		,new_references.admission_appl_number
    		,new_references.person_id
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
	 (old_references.admission_appl_number = new_references.admission_appl_number)) OR
	((new_references.person_id IS NULL) OR
	 (new_references.admission_appl_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Appl_Pkg.Get_PK_For_Validation (
        		new_references.person_id,
         		 new_references.admission_appl_number
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.special_interest_type_id = new_references.special_interest_type_id)) OR
        ((new_references.special_interest_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.special_interest_type_id ,
             'SPECIAL_INTERESTS',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SPL_INTEREST_TYPE'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_spl_interest_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_spl_interests
      WHERE    spl_interest_id = x_spl_interest_id
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
    x_special_interest_type_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_person_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_spl_interests
      WHERE    special_interest_type_id = x_special_interest_type_id
      AND      person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
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
  END Get_UK_For_Validation ;
  PROCEDURE Get_FK_Igs_Ad_Appl (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_spl_interests
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ASPLI_ACAI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Appl;

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_spl_interests
      WHERE    special_interest_type_id = x_code_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ASPLI_ACDC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Code_Classes;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_spl_interest_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_special_interest_type_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
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
      x_spl_interest_id,
      x_person_id,
      x_admission_appl_number,
      x_special_interest_type_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    igs_ad_gen_002.check_adm_appl_inst_stat(
      nvl(x_person_id,old_references.person_id),
      nvl(x_admission_appl_number,old_references.admission_appl_number),
      NULL,
      NULL,
      'Y'              -- proceed phase - apadegal adtd001 igs.m
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.spl_interest_id)  THEN
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
    		new_references.spl_interest_id)  THEN
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
     l_rowid := NULL;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :
  Date Created By :
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
       x_SPL_INTEREST_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_SPECIAL_INTEREST_TYPE_ID IN NUMBER,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ravishar      05/27/05        Security related changes

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_SPL_INTERESTS
             where                 SPL_INTEREST_ID= X_SPL_INTEREST_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
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
      X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      if (X_REQUEST_ID =  -1) then
        X_REQUEST_ID := NULL;
        X_PROGRAM_ID := NULL;
        X_PROGRAM_APPLICATION_ID := NULL;
        X_PROGRAM_UPDATE_DATE := NULL;
      else
        X_PROGRAM_UPDATE_DATE := SYSDATE;
      end if;
    else
      FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    end if;

   X_SPL_INTEREST_ID := -1;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_spl_interest_id=>X_SPL_INTEREST_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
 	       x_special_interest_type_id=>X_SPECIAL_INTEREST_TYPE_ID,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_AD_SPL_INTERESTS (
		SPL_INTEREST_ID
		,PERSON_ID
		,ADMISSION_APPL_NUMBER
		,SPECIAL_INTEREST_TYPE_ID
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,REQUEST_ID
		,PROGRAM_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_UPDATE_DATE
        ) values  (
	         IGS_AD_SPL_INTERESTS_S.NEXTVAL
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.ADMISSION_APPL_NUMBER
	        ,NEW_REFERENCES.SPECIAL_INTEREST_TYPE_ID
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,X_REQUEST_ID
		,X_PROGRAM_ID
		,X_PROGRAM_APPLICATION_ID
		,X_PROGRAM_UPDATE_DATE
)RETURNING SPL_INTEREST_ID INTO X_SPL_INTEREST_ID;
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
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
END INSERT_ROW;
 PROCEDURE LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_SPL_INTEREST_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_SPECIAL_INTEREST_TYPE_ID IN NUMBER
    ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      PERSON_ID
,      ADMISSION_APPL_NUMBER
,      SPECIAL_INTEREST_TYPE_ID
    from IGS_AD_SPL_INTERESTS
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
  AND (tlinfo.ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER)
  AND (tlinfo.SPECIAL_INTEREST_TYPE_ID = X_SPECIAL_INTEREST_TYPE_ID)
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
       x_SPL_INTEREST_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_SPECIAL_INTEREST_TYPE_ID IN NUMBER,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ravishar      05/27/05        Security related changes

  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
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
 	       x_spl_interest_id=>X_SPL_INTEREST_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
 	       x_special_interest_type_id=>X_SPECIAL_INTEREST_TYPE_ID,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);

    if (X_MODE IN ('R', 'S')) then
      X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      if (X_REQUEST_ID = -1) then
        X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
        X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
        X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
        X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
      else
        X_PROGRAM_UPDATE_DATE := SYSDATE;
      end if;
    end if;

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_AD_SPL_INTERESTS set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      ADMISSION_APPL_NUMBER =  NEW_REFERENCES.ADMISSION_APPL_NUMBER,
      SPECIAL_INTEREST_TYPE_ID =  NEW_REFERENCES.SPECIAL_INTEREST_TYPE_ID,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
,	REQUEST_ID = X_REQUEST_ID,
	PROGRAM_ID = X_PROGRAM_ID,
	PROGRAM_APPLICATION_ID = PROGRAM_APPLICATION_ID,
	PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
	  where ROWID = X_ROWID;
     IF (sql%notfound) THEN
        fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
        igs_ge_msg_stack.add;
        IF (x_mode = 'S') THEN
           igs_sc_gen_001.unset_ctx('R');
        END IF;
        app_exception.raise_exception;
     END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
 END IF;


 After_DML (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID
	);
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_SPL_INTEREST_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_SPECIAL_INTEREST_TYPE_ID IN NUMBER,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_SPL_INTERESTS
             where     SPL_INTEREST_ID= X_SPL_INTEREST_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_SPL_INTEREST_ID,
       X_PERSON_ID,
       X_ADMISSION_APPL_NUMBER,
       X_SPECIAL_INTEREST_TYPE_ID,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_SPL_INTEREST_ID,
       X_PERSON_ID,
       X_ADMISSION_APPL_NUMBER,
       X_SPECIAL_INTEREST_TYPE_ID,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ravishar      05/27/05        Security related changes

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
 delete from IGS_AD_SPL_INTERESTS
 where ROWID = X_ROWID;
  IF (sql%notfound) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
       igs_sc_gen_001.set_ctx('R');
     END IF;
     app_exception.raise_exception;
  END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
EXCEPTION
  WHEN OTHERS THEN
   IF (x_mode = 'S') THEN
     igs_sc_gen_001.unset_ctx('R');
   END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
end DELETE_ROW;

END igs_ad_spl_interests_pkg;

/
