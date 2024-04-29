--------------------------------------------------------
--  DDL for Package Body IGS_PE_VOTE_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_VOTE_INFO_PKG" AS
/* $Header: IGSNI50B.pls 120.3 2005/10/17 04:23:52 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_vote_info_all%RowType;
  new_references igs_pe_vote_info_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_voter_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_voter_info IN VARCHAR2 DEFAULT NULL,
    x_type_code IN VARCHAR2 DEFAULT NULL,
    x_type_code_id IN NUMBER DEFAULT NULL,
    x_voter_regn_st_date IN DATE DEFAULT NULL,
    x_voter_regn_end_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : svenkata
  Date Created By :15-MAY-200
  Purpose : SETS COLUMN VALUES
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_vote_info_all
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
    new_references.voter_id := x_voter_id;
    new_references.person_id := x_person_id;
    new_references.voter_info := x_voter_info;
    new_references.type_code := x_type_code;
    new_references.type_code_id := x_type_code_id;
    new_references.voter_regn_st_date := x_voter_regn_st_date;
    new_references.voter_regn_end_date := x_voter_regn_end_date;
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
  Created By : svenkata
  Date Created By :15-MAY-200
  Purpose : CHECKS CONSTRAINTS
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
  Created By : svenkata
  Date Created By :15-MAY-200
  Purpose : CHECKS FOR PARENT EXISTANCE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

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

    If NOT igs_lookups_view_pkg.get_pk_for_validation('VOTER_INFO' , new_references.voter_info) then
    	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
	 IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    end if;


  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_voter_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : svenkata
  Date Created By :15-MAY-200
  Purpose : checks primary key
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_vote_info_all
      WHERE    voter_id = x_voter_id
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
  Created By : svenkata
  Date Created By :15-MAY-200
  Purpose : CHECKS FOREIGN KEY
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_vote_info_all
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PPT_PP_FK');
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
      FROM     igs_pe_vote_info_all
      WHERE    person_id = x_person_id
      AND     ((cp_type_code is null and cp_type_code_id is not null and NVL(type_code_id,-1) = cp_type_code_id)
      OR      (cp_type_code is not null and cp_type_code_id is null and NVL(type_code,' ') = cp_type_code))
      AND      ((l_rowid is null) or (rowid <> l_rowid))
      ;
    lv_rowid cur_rowid%RowType;

  BEGIN

    IF new_references.voter_info='COUNTRY' THEN --Then type_code_id is null
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
    		,new_references.type_code
		,new_references.type_code_id
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_PE_VOTE_DUP_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;


PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_voter_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_voter_info IN VARCHAR2 DEFAULT NULL,
    x_type_code IN VARCHAR2 DEFAULT NULL,
    x_type_code_id IN NUMBER DEFAULT NULL,
    x_voter_regn_st_date IN DATE DEFAULT NULL,
    x_voter_regn_end_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
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
      x_voter_id,
      x_person_id,
      x_voter_info,
      x_type_code,
      x_type_code_id,
      x_voter_regn_st_date,
      x_voter_regn_end_date,
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
    		new_references.voter_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_PE_VOTE_DUP_EXISTS');
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
    		new_references.voter_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_PE_VOTE_DUP_EXISTS');
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
  Created By : svenkata
  Date Created By :15-MAY-200
  Purpose : DOES AFTER DML VALIDATIONS
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
       x_VOTER_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_VOTER_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_VOTER_REGN_ST_DATE IN DATE,
       x_VOTER_REGN_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R',
      X_ORG_ID in NUMBER ,
      x_TYPE_CODE_ID IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : svenkata
  Date Created By :15-MAY-200
  Purpose : INSERTS A ROW
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from igs_pe_vote_info_all
             where   VOTER_ID= X_VOTER_ID;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     l_TYPE_CODE igs_pe_vote_info_all.type_code%TYPE;
     l_TYPE_CODE_ID igs_pe_vote_info_all.type_code_id%TYPE;

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

       SELECT IGS_PE_VOTE_INFO_S.NEXTVAL
       INTO x_voter_id
       FROM  DUAL;

       --l_type_code :=  x_type_code;
       --l_type_code_id :=  x_type_code_id;

        IF (x_VOTER_INFO='COUNTRY') THEN
            l_TYPE_CODE_ID := NULL;
	    l_type_code :=  x_type_code;
	ELSE
            l_TYPE_CODE := NULL;
	    l_type_code_id :=  x_type_code_id;
	END IF;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_voter_id=>X_VOTER_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_voter_info=>X_VOTER_INFO,
 	       x_type_code=>l_TYPE_CODE,
	       x_type_code_id=>l_TYPE_CODE_ID,
 	       x_voter_regn_st_date=>X_VOTER_REGN_ST_DATE,
 	       x_voter_regn_end_date=>X_VOTER_REGN_END_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_org_id=>igs_ge_gen_003.get_org_id
	);
      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into igs_pe_vote_info_all (
		VOTER_ID
		,PERSON_ID
		,VOTER_INFO
		,TYPE_CODE
		,TYPE_CODE_ID
		,VOTER_REGN_ST_DATE
		,VOTER_REGN_END_DATE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,ORG_ID
        ) values  (
	        NEW_REFERENCES.VOTER_ID
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.VOTER_INFO
	        ,NEW_REFERENCES.TYPE_CODE
		,NEW_REFERENCES.TYPE_CODE_ID
	        ,NEW_REFERENCES.VOTER_REGN_ST_DATE
	        ,NEW_REFERENCES.VOTER_REGN_END_DATE
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
	        ,NEW_REFERENCES.ORG_ID
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
       x_VOTER_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_VOTER_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_VOTER_REGN_ST_DATE IN DATE,
       x_VOTER_REGN_END_DATE IN DATE ,
      x_TYPE_CODE_ID IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
   Created By : svenkata
  Date Created By :15-MAY-200
  Purpose : LOCKS A ROW
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  skpandey        08-SEP-2005     Bug: 4593149
                                  Description: Modified lock_row parameters
  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      PERSON_ID
,      VOTER_INFO
,      TYPE_CODE
,      TYPE_CODE_ID
,      VOTER_REGN_ST_DATE
,      VOTER_REGN_END_DATE
    from igs_pe_vote_info_all
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;

   l_TYPE_CODE igs_pe_vote_info_all.type_code%TYPE;
   l_TYPE_CODE_ID igs_pe_vote_info_all.type_code_id%TYPE;

BEGIN
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
  --skpandey. Bug: 4593149
  IF (x_VOTER_INFO='COUNTRY') THEN
      l_TYPE_CODE_ID := NULL;
      l_type_code :=  x_type_code;
  ELSE
      l_TYPE_CODE := NULL;
      l_type_code_id :=  x_type_code_id;
  END IF;

  IF ( (  tlinfo.PERSON_ID = X_PERSON_ID)
      AND (tlinfo.VOTER_INFO = X_VOTER_INFO)
      AND (NVL(tlinfo.TYPE_CODE,'  ') = NVL(l_type_code,'  '))
      AND (NVL(tlinfo.TYPE_CODE_ID,-1) = NVL(l_TYPE_CODE_ID,-1))
      AND ((tlinfo.VOTER_REGN_ST_DATE = X_VOTER_REGN_ST_DATE)
      OR ((tlinfo.VOTER_REGN_ST_DATE is null)
      AND (X_VOTER_REGN_ST_DATE is null)))
      AND ((tlinfo.VOTER_REGN_END_DATE = X_VOTER_REGN_END_DATE)
      OR ((tlinfo.VOTER_REGN_END_DATE is null)
      AND (X_VOTER_REGN_END_DATE is null)))
      ) THEN
      NULL;
  ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
  END IF;
  RETURN;
END LOCK_ROW;

 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_VOTER_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_VOTER_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_VOTER_REGN_ST_DATE IN DATE,
       x_VOTER_REGN_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R' ,
      x_TYPE_CODE_ID IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : svenkata
  Date Created By :15-MAY-200
  Purpose : UPDATES A ROW
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     l_TYPE_CODE igs_pe_vote_info_all.type_code%TYPE;
     l_TYPE_CODE_ID igs_pe_vote_info_all.type_code_id%TYPE;

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

     IF (x_VOTER_INFO='COUNTRY') THEN
        l_TYPE_CODE_ID := NULL;
	l_type_code :=  x_type_code;
	ELSE
        l_TYPE_CODE := NULL;
	l_type_code_id :=  x_type_code_id;
	END IF;

   Before_DML(
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_voter_id=>X_VOTER_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_voter_info=>X_VOTER_INFO,
 	       x_type_code=>l_TYPE_CODE,
               x_type_code_id=>l_TYPE_CODE_ID,
 	       x_voter_regn_st_date=>X_VOTER_REGN_ST_DATE,
 	       x_voter_regn_end_date=>X_VOTER_REGN_END_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update igs_pe_vote_info_all set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      VOTER_INFO =  NEW_REFERENCES.VOTER_INFO,
      TYPE_CODE =  NEW_REFERENCES.TYPE_CODE,
      TYPE_CODE_ID =  NEW_REFERENCES.TYPE_CODE_ID,
      VOTER_REGN_ST_DATE =  NEW_REFERENCES.VOTER_REGN_ST_DATE,
      VOTER_REGN_END_DATE =  NEW_REFERENCES.VOTER_REGN_END_DATE,
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
       x_VOTER_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_VOTER_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_VOTER_REGN_ST_DATE IN DATE,
       x_VOTER_REGN_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R',
      X_ORG_ID in NUMBER ,
       x_TYPE_CODE_ID IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
   Created By : svenkata
  Date Created By :15-MAY-200
  Purpose : ADDS A ROW
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from igs_pe_vote_info_all
             where VOTER_ID= X_VOTER_ID;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_VOTER_ID,
       X_PERSON_ID,
       X_VOTER_INFO,
       X_TYPE_CODE,
       X_VOTER_REGN_ST_DATE,
       X_VOTER_REGN_END_DATE,
      X_MODE,
      X_ORG_ID,  X_TYPE_CODE_ID );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_VOTER_ID,
       X_PERSON_ID,
       X_VOTER_INFO,
       X_TYPE_CODE,
       X_VOTER_REGN_ST_DATE,
       X_VOTER_REGN_END_DATE,
      X_MODE ,  X_TYPE_CODE_ID);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
  /*************************************************************
  Created By : svenkata
  Date Created By :15-MAY-200
  Purpose : DELETES A ROW
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
 delete from igs_pe_vote_info_all
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
END igs_pe_vote_info_pkg;

/
