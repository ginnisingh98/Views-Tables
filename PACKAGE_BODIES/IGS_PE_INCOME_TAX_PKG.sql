--------------------------------------------------------
--  DDL for Package Body IGS_PE_INCOME_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_INCOME_TAX_PKG" AS
/* $Header: IGSNI53B.pls 120.3 2005/10/17 04:23:31 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PE_INCOME_TAX_ALL%RowType;
  new_references IGS_PE_INCOME_TAX_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tax_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_tax_info IN VARCHAR2 DEFAULT NULL,
    x_type_code IN VARCHAR2 DEFAULT NULL,
    x_type_code_id IN NUMBER DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :srachako
  Date Created By :11-MAY-2000
  Purpose :Set Column Values
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_INCOME_TAX_ALL
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
    new_references.tax_id := x_tax_id;
    new_references.person_id := x_person_id;
    new_references.tax_info := x_tax_info;
    new_references.type_code := x_type_code;
    new_references.type_code_id := x_type_code_id;
    new_references.start_date := x_start_date;
    new_references.end_date := x_end_date;
    new_references.org_id := x_org_id;
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

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :srachako
  Date Created By :11-MAY-2000
  Purpose : Parent Existance Checking
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
     IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
       'TAX_INFO',
       	  new_references.TAX_INFO
       	  ) THEN
       	    Fnd_Message.Set_Name('FND', 'FORM_RECORD_DELETED');
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
    x_tax_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :srachako
  Date Created By :11-MAY-2000
  Purpose :Primary Key for Validation
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_INCOME_TAX_ALL
      WHERE    tax_id = x_tax_id
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

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :srachako
  Date Created By :11-MAY-2000
  Purpose : Forign Key Check
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_INCOME_TAX_ALL
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN
  Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PIT_PP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;


   FUNCTION Get_UK_For_Validation (
    x_person_id IN NUMBER,
    x_type_code IN VARCHAR2,
    x_type_code_id IN NUMBER
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

    CURSOR cur_rowid(cp_type_code varchar2,cp_type_code_id number) IS
      SELECT   rowid
      FROM     igs_pe_income_tax_all
      WHERE    person_id = x_person_id
      AND     ((cp_type_code is null and cp_type_code_id is not null and NVL(type_code_id,-1) = cp_type_code_id)
      OR      (cp_type_code is not null and cp_type_code_id is null and NVL(type_code,' ') = cp_type_code))
      AND      ((l_rowid is null) or (rowid <> l_rowid))
      ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    IF (new_references.tax_info = 'COUNTRY') THEN --Then type_code_id is null
    Open cur_rowid(x_type_code,NULL);
    ELSE
    Open cur_rowid(NULL,x_type_code_id);
    END IF;

    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        return (true);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  END Get_UK_For_Validation ;


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
    		new_references.person_id
    		,new_references.type_code,new_references.type_code_id
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_PE_INCTAX_DUP_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tax_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_tax_info IN VARCHAR2 DEFAULT NULL,
    x_type_code IN VARCHAR2 DEFAULT NULL,
    x_type_code_id IN NUMBER DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
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
      x_tax_id,
      x_person_id,
      x_tax_info,
      x_type_code,
      x_type_code_id,
      x_start_date,
      x_end_date,
      x_org_id,
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
    		new_references.tax_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_PE_INCTAX_DUP_EXISTS');
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
    		new_references.tax_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_PE_INCTAX_DUP_EXISTS');
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
  Created By :srachako
  Date Created By :11-MAY-2000
  Purpose :After DML Operations
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

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_TAX_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TAX_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_TYPE_CODE_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       X_ORG_ID in NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :srachako
  Date Created By :11-MAY-2000
  Purpose :For Inserting Values
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PE_INCOME_TAX_ALL
             where                 TAX_ID= X_TAX_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     l_TYPE_CODE igs_pe_income_tax_all.type_code%TYPE;
     l_TYPE_CODE_ID igs_pe_income_tax_all.type_code_id%TYPE;
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
       SELECT IGS_PE_INCOME_TAX_S.NEXTVAL
       	    INTO X_TAX_ID
       	   FROM Dual;

	IF (x_TAX_INFO='COUNTRY') THEN
        l_TYPE_CODE_ID := NULL;
	l_type_code :=  x_type_code;
	ELSE
        l_TYPE_CODE := NULL;
	l_type_code_id :=  x_type_code_id;
	END IF;

	 Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_tax_id=>X_TAX_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_tax_info=>X_TAX_INFO,
 	       x_type_code=>l_TYPE_CODE,
	       x_type_code_id=>l_TYPE_CODE_ID,
 	       x_start_date=>X_START_DATE,
 	       x_end_date=>X_END_DATE,
               x_org_id => igs_ge_gen_003.get_org_id,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);


	        IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_PE_INCOME_TAX_ALL (
		TAX_ID
		,PERSON_ID
		,TAX_INFO
		,TYPE_CODE
		,TYPE_CODE_ID
		,START_DATE
		,END_DATE
                ,ORG_ID
                ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	         NEW_REFERENCES.TAX_ID
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.TAX_INFO
	        ,NEW_REFERENCES.TYPE_CODE
	        ,NEW_REFERENCES.TYPE_CODE_ID
	        ,NEW_REFERENCES.START_DATE
	        ,NEW_REFERENCES.END_DATE
                ,NEW_REFERENCES.ORG_ID
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
       x_TAX_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TAX_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_TYPE_CODE_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE  ) AS
  /*************************************************************
  Created By : srachako
  Date Created By :11-MAY-2000
  Purpose :For Locking Row
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  skpandey        23-SEP-2005     Bug: 4593149
                                  Description: Added condition to avoid locking
  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      PERSON_ID
,      TAX_INFO
,      TYPE_CODE
,      TYPE_CODE_ID
,      START_DATE
,      END_DATE
    from IGS_PE_INCOME_TAX_ALL
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;
     l_TYPE_CODE igs_pe_income_tax_all.type_code%TYPE;
     l_TYPE_CODE_ID igs_pe_income_tax_all.type_code_id%TYPE;
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

--skpandey.Bug#4593149
   IF (x_TAX_INFO='COUNTRY') THEN
     l_TYPE_CODE_ID := NULL;
     l_type_code :=  x_type_code;
   ELSE
     l_TYPE_CODE := NULL;
     l_type_code_id :=  x_type_code_id;
   END IF;

if ( (  tlinfo.PERSON_ID = X_PERSON_ID)
  AND (tlinfo.TAX_INFO = X_TAX_INFO)
  AND (NVL(tlinfo.TYPE_CODE,' ') = NVL(l_type_code,' '))
  AND (NVL(tlinfo.TYPE_CODE_ID,-1) = NVL(l_TYPE_CODE_ID,-1))
  AND ((tlinfo.START_DATE = X_START_DATE)
 	    OR ((tlinfo.START_DATE is null)
		AND (X_START_DATE is null)))
  AND ((tlinfo.END_DATE = X_END_DATE)
 	    OR ((tlinfo.END_DATE is null)
		AND (X_END_DATE is null)))
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
       x_TAX_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TAX_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_TYPE_CODE_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :srachako
  Date Created By :11-MAY-2000
  Purpose :For Updation of Row
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     l_TYPE_CODE igs_pe_income_tax_all.type_code%TYPE;
     l_TYPE_CODE_ID igs_pe_income_tax_all.type_code_id%TYPE;
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

       IF (x_TAX_INFO='COUNTRY') THEN
        l_TYPE_CODE_ID := NULL;
	l_type_code :=  x_type_code;
	ELSE
        l_TYPE_CODE := NULL;
	l_type_code_id :=  x_type_code_id;
	END IF;

   Before_DML(
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_tax_id=>X_TAX_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_tax_info=>X_TAX_INFO,
 	       x_type_code=>l_TYPE_CODE,
	       x_type_code_id=>l_TYPE_CODE_ID,
 	       x_start_date=>X_START_DATE,
 	       x_end_date=>X_END_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_PE_INCOME_TAX_ALL set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      TAX_INFO =  NEW_REFERENCES.TAX_INFO,
      TYPE_CODE =  NEW_REFERENCES.TYPE_CODE,
      TYPE_CODE_ID =  NEW_REFERENCES.TYPE_CODE_ID,
      START_DATE =  NEW_REFERENCES.START_DATE,
      END_DATE =  NEW_REFERENCES.END_DATE,
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
       x_TAX_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TAX_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_TYPE_CODE_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       X_ORG_ID in NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :srachako
  Date Created By :11-MAY-2000
  Purpose :for Insertion of Values
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PE_INCOME_TAX_ALL
             where     TAX_ID= X_TAX_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;



    INSERT_ROW (
       X_ROWID,
       X_TAX_ID,
       X_PERSON_ID,
       X_TAX_INFO,
       X_TYPE_CODE,
       X_TYPE_CODE_ID,
       X_START_DATE,
       X_END_DATE,
       X_ORG_ID,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_TAX_ID,
       X_PERSON_ID,
       X_TAX_INFO,
       X_TYPE_CODE,
       X_TYPE_CODE_ID,
       X_START_DATE,
       X_END_DATE,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
  /*************************************************************
  Created By :srachako
  Date Created By :11-MAY-2000
  Purpose :for Deletion of Rows
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
 delete from IGS_PE_INCOME_TAX_ALL
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

END igs_pe_income_tax_pkg;

/
