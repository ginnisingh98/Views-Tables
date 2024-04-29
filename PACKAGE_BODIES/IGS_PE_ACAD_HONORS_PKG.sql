--------------------------------------------------------
--  DDL for Package Body IGS_PE_ACAD_HONORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_ACAD_HONORS_PKG" AS
/* $Header: IGSNI99B.pls 120.2 2005/10/17 02:22:26 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_pe_acad_honors%RowType;
  new_references igs_pe_acad_honors%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_acad_honor_id IN NUMBER ,
    x_person_id IN NUMBER,
    x_comments IN VARCHAR2,
    x_honor_date IN DATE ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER ,
    x_acad_honor_type IN VARCHAR2
  ) AS

  /*************************************************************
  Created By :samaresh
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  kamohan	1/21/02		Removed references of nominated_course_Cd
				and sequence_number
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_acad_honors
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
    new_references.acad_honor_id := x_acad_honor_id;
    new_references.person_id := x_person_id;
    new_references.comments := x_comments;
    new_references.honor_date := x_honor_date; --code added in the next line by gautam
    new_references.acad_honor_type:=x_acad_honor_type;
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
		 Column_Name IN VARCHAR2  ,
		 Column_Value IN VARCHAR2  ) AS
  /*************************************************************
  Created By :samaresh
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
      IF column_name IS NULL THEN
        NULL;
      END IF;
  END Check_Constraints;

  FUNCTION Get_UK_For_Validation (
    x_acad_honor_type IN VARCHAR2,
    x_honor_date IN DATE,
    x_person_id IN NUMBER
  ) RETURN BOOLEAN AS
  /*************************************************************
  Created By :ssomasun.in
  Date Created By :29-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

 (reverse chronological order - newest change first)
  kamohan	1/21/02		removed the reference to Nominated_course_cd
				and sequence_number
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_acad_honors
      WHERE    acad_honor_type = x_acad_honor_type
      AND      nvl(honor_date,sysdate) = nvl(x_honor_date,sysdate)
      AND      person_id = x_person_id
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

  PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By :ssomasun.in
  Date Created By :29-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
   begin
     IF Get_Uk_For_Validation (
    	new_references.acad_honor_type,  --changed acad_honor_type_id to acad_honor_TYPE
	new_references.honor_date,
 	new_references.person_id
      ) THEN
 	  Fnd_Message.Set_Name ('IGS', 'IGS_PE_ACAD_HNRS_DUP_EXISTS');
          IGS_GE_MSG_STACK.ADD;
	  app_exception.raise_exception;
      END IF;
 END Check_Uniqueness ;

 PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :ssomasun.in
  Date Created By :29-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  kamohan	1/21/02		removed the ref to Nominated_course_cd
				and sequence_number
  ***************************************************************/

  BEGIN

    IF (((old_references.acad_honor_type = new_references.acad_honor_type)) OR
        ((new_references.acad_honor_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_lookups_view_Pkg.Get_PK_For_Validation (
       	'PE_ACAD_HONORS', new_references.acad_honor_type
      )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;



  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_acad_honor_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :samaresh
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_acad_honors
      WHERE    acad_honor_id = x_acad_honor_id
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
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_acad_honor_id IN NUMBER,
    x_person_id IN NUMBER ,
    x_comments IN VARCHAR2 ,
    x_honor_date IN DATE ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_acad_honor_type IN VARCHAR2
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
      x_acad_honor_id,
      x_person_id,
      x_comments,
      x_honor_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_acad_honor_type
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
     IF Get_Pk_For_Validation(
	new_references.acad_honor_id)  THEN
       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
     Check_Uniqueness;
     Check_Constraints;
     Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.acad_honor_id)  THEN
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
  Created By :samaresh
  Date Created By :15-May-2000
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
       x_ACAD_HONOR_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_COMMENTS IN VARCHAR2,
       x_HONOR_DATE IN DATE,
      X_MODE in VARCHAR2  ,
      X_ACAD_HONOR_TYPE IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :samaresh
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from igs_pe_acad_honors
           where     ACAD_HONOR_ID= X_ACAD_HONOR_ID;

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



   SELECT igs_pe_acad_honors_s.nextval
   INTO X_ACAD_HONOR_ID
   FROM dual;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_acad_honor_id=>X_ACAD_HONOR_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_comments=>X_COMMENTS,
 	       x_honor_date=>X_HONOR_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_acad_honor_type=>X_ACAD_HONOR_TYPE);



      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into igs_pe_acad_honors (
		ACAD_HONOR_ID
		,PERSON_ID
		,COMMENTS
		,HONOR_DATE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,REQUEST_ID
		,PROGRAM_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_UPDATE_DATE
		,ACAD_HONOR_TYPE
        ) values  (
	        NEW_REFERENCES.ACAD_HONOR_ID
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.COMMENTS
	        ,NEW_REFERENCES.HONOR_DATE
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,X_REQUEST_ID
		,X_PROGRAM_ID
		,X_PROGRAM_APPLICATION_ID
		,X_PROGRAM_UPDATE_DATE
		,NEW_REFERENCES.ACAD_HONOR_TYPE
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
       x_ACAD_HONOR_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_COMMENTS IN VARCHAR2,
       x_HONOR_DATE IN DATE,
       x_ACAD_HONOR_TYPE IN VARCHAR2) AS
  /*************************************************************
  Created By :samaresh
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  kamohan	1/21/02		Removed the reference to nominated_course_cd
				and sequence_number
  ***************************************************************/

   cursor c1 is select
      PERSON_ID
,      ACAD_HONOR_TYPE --changed type_id to cd
,      COMMENTS
,      HONOR_DATE
    from igs_pe_acad_honors
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
  AND (tlinfo.ACAD_HONOR_TYPE = X_ACAD_HONOR_TYPE) --CHANGED ACAD_HONOR_TYPE_ID TO ACAD_HONOR_TYPE AND ID TO CD
  AND ((tlinfo.COMMENTS = X_COMMENTS)
 	    OR ((tlinfo.COMMENTS is null)
		AND (X_COMMENTS is null)))
  AND ((tlinfo.HONOR_DATE = X_HONOR_DATE)
 	    OR ((tlinfo.HONOR_DATE is null)
		AND (X_HONOR_DATE is null)))
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
       x_ACAD_HONOR_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_COMMENTS IN VARCHAR2,
       x_HONOR_DATE IN DATE,
      X_MODE in VARCHAR2 ,
      x_ACAD_HONOR_TYPE IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :samaresh
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

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
 	       x_acad_honor_id=>X_ACAD_HONOR_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_comments=>X_COMMENTS,
 	       x_honor_date=>X_HONOR_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_acad_honor_type=>x_ACAD_HONOR_TYPE);

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
 update igs_pe_acad_honors set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      ACAD_HONOR_TYPE =  NEW_REFERENCES.ACAD_HONOR_TYPE,--CHANGED HERE
      COMMENTS =  NEW_REFERENCES.COMMENTS,
      HONOR_DATE =  NEW_REFERENCES.HONOR_DATE,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	REQUEST_ID = X_REQUEST_ID,
	PROGRAM_ID = X_PROGRAM_ID,
	PROGRAM_APPLICATION_ID = PROGRAM_APPLICATION_ID,
	PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
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
       x_ACAD_HONOR_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_COMMENTS IN VARCHAR2,
       x_HONOR_DATE IN DATE,
      X_MODE in VARCHAR2  ,
      x_ACAD_HONOR_TYPE IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :samaresh
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from igs_pe_acad_honors
          where     ACAD_HONOR_ID= X_ACAD_HONOR_ID;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
       X_ROWID,
       X_ACAD_HONOR_ID,
       X_PERSON_ID,
       X_COMMENTS,
       X_HONOR_DATE,
       X_MODE,
       x_ACAD_HONOR_TYPE);
     return;
	end if;
	   close c1;
UPDATE_ROW (
       X_ROWID,
       X_ACAD_HONOR_ID,
       X_PERSON_ID,
       X_COMMENTS,
       X_HONOR_DATE,
       X_MODE,
       x_ACAD_HONOR_TYPE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :samaresh
  Date Created By :15-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

begin
/*Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID,
);*/
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from igs_pe_acad_honors
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

END IGS_PE_ACAD_HONORS_PKG;

/
