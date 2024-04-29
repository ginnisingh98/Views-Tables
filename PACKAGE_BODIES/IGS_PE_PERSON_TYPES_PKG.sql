--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERSON_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERSON_TYPES_PKG" AS
/* $Header: IGSNI43B.pls 115.17 2003/06/11 06:05:56 rnirwani ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_pe_person_types%RowType;
  new_references igs_pe_person_types%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_type_code IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_system_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_rank IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_PERSON_TYPES
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
    new_references.person_type_code := x_person_type_code;
    new_references.description := x_description;
    new_references.system_type := x_system_type;
    new_references.closed_ind := x_closed_ind;
    new_references.rank := x_rank;
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



PROCEDURE check_duplicate_per_type  IS
/*************************************************************
  Created By : kumma
  Date Created By : 15-MAY-2002
  Purpose : To check if dup records exist After inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
   CURSOR dup_system_type IS
   SELECT
	COUNT(1)
   FROM
	IGS_PE_PERSON_TYPES A,
	   IGS_PE_PERSON_TYPES B
    WHERE
	       A.System_Type NOT IN ('USER_DEFINED', 'SS_ENROLL_STAFF')
	   AND A.System_Type = B.System_Type
	   AND A.ROWID <> B.ROWID
	   AND A.CLOSED_IND = 'N'
	   AND A.CLOSED_IND = B.CLOSED_IND;

    l_count NUMBER(2);
 BEGIN

    OPEN dup_system_type;
    FETCH dup_system_type INTO l_count;
    IF l_count > 0 THEN
        Fnd_Message.Set_Name('IGS','IGS_PE_ONE_PE_TY_SYS_TY');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
    END IF;
    CLOSE dup_system_type;
 END check_duplicate_per_type;




PROCEDURE AfterInsertPTC (
	X_person_type_code IN VARCHAR2
)  AS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

	lvRowId VARCHAR2(30);
	ln_Setup_Data_Element_Id NUMBER;
	CURSOR de IS
	SELECT DATA_ELEMENT  FROM IGS_PE_DATA_ELEMENT;
BEGIN
   FOR  de_rec IN de  LOOP
	Igs_Pe_Stup_Data_Emt_Pkg.INSERT_ROW  (
	    X_ROWID => lvRowid,
	    X_SETUP_DATA_ELEMENT_ID => ln_Setup_Data_Element_Id,
	    X_PERSON_TYPE_CODE  => X_person_type_code,
	    X_DATA_ELEMENT => de_rec.DATA_ELEMENT,
	    X_VALUE => NULL,
	    X_REQUIRED_IND => 'N',
	    X_MODE => 'R'
	  );
    END LOOP;
END AfterInsertPTC;

PROCEDURE BeforeDeletePTC   AS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

	lvRowId VARCHAR2(30);
	CURSOR C1 IS
	SELECT ROWID
	FROM IGS_PE_STUP_DATA_EMT
	WHERE person_type_code = new_references.person_type_code;

BEGIN
      FOR tlinfo IN C1 LOOP
        Igs_Pe_Stup_Data_Emt_Pkg.DELETE_ROW (X_ROWID =>tlinfo.ROWID);
      END LOOP;
END BeforeDeletePTC;


PROCEDURE BeforeInsertPTC AS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  KNAG.IN         11-APR-2001     Included check for SS_ENROLL_STAFF
                                  in procedures BeforeInsertPTC and
                                  BeforeUpdatePTC
  KUMMA           21-MAY-2002     Modified cursor to fetch only rows
				  which are having closed ind set to 'N'
  (reverse chronological order - newest change first)
  ***************************************************************/

   CURSOR C2 IS
   SELECT 'X'
   FROM IGS_PE_PERSON_TYPES
   WHERE System_Type = new_references.system_type
   AND CLOSED_IND = 'N';
   tlinfo c2%ROWTYPE;
BEGIN
    IF  (UPPER(new_references.system_type) <> 'USER_DEFINED' AND
         UPPER(new_references.system_type) <> 'SS_ENROLL_STAFF') THEN
    	OPEN C2;
    	FETCH C2 INTO tlinfo;
    	IF (C2%found) THEN
     		Fnd_Message.Set_Name('IGS','IGS_PE_ONE_PE_TY_SYS_TY');
            	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
    	END IF;
	CLOSE C2;
     END IF;
END BeforeInsertPTC;

PROCEDURE BeforeUpdatePTC AS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  KNAG.IN         11-APR-2001     Included check for SS_ENROLL_STAFF
                                  in procedures BeforeInsertPTC and
                                  BeforeUpdatePTC
  (reverse chronological order - newest change first)
  ***************************************************************/

   CURSOR C3 IS
   SELECT 'X'
   FROM IGS_PE_PERSON_TYPES
   WHERE System_Type = new_references.system_type
   AND rowid <> l_rowid
--   AND Person_Type_Code <> new_references.Person_Type_Code
   AND CLOSED_IND = 'N'
   AND new_references.closed_ind = 'N';
   tlinfo c3%ROWTYPE;
BEGIN
    IF  (UPPER(new_references.system_type) <> 'USER_DEFINED' AND
         UPPER(new_references.system_type) <> 'SS_ENROLL_STAFF') THEN
    	OPEN C3;
    	FETCH C3 INTO tlinfo;
    	IF (C3%found) THEN
     		Fnd_Message.Set_Name('IGS','IGS_PE_ONE_PE_TY_SYS_TY');
            	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
    	END IF;
	CLOSE C3;
     END IF;
END BeforeUpdatePTC;


PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To check the constraints
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'CLOSED_IND'  THEN
        new_references.closed_ind := column_value;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'CLOSED_IND' OR
      	Column_Name IS NULL THEN
      IF NOT (new_references.closed_ind IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To Check if child records exist before deleting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Pe_Typ_Instances_Pkg.Get_FK_Igs_Pe_Person_Types (
      old_references.person_type_code
      );

    Igs_Pe_Usr_Arg_pkg.Get_FK_Igs_Pe_Person_Types (
      old_references.person_type_code
      );

    Igs_Pe_Usr_Aval_pkg.Get_FK_Igs_Pe_Person_Types (
      old_references.person_type_code
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_type_code IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To check if dup records exist before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         8-JUL-2002      Bug No: 2389552
                                  The for update nowait was removed since records can not be deleted from the form
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_person_types
      WHERE    UPPER(person_type_code) = UPPER(x_person_type_code);

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
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_type_code IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_system_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_rank IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To validate the fields before doing the DML operation.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  kumma		  21-MAY-2002     Commented the call to BeforeInsertPTC
                                  and to --BeforeUpdatePTC as the logic have
				  been moved to post_forms_commit, Bug 2379779
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_type_code,
      x_description,
      x_system_type,
      x_closed_ind,
      x_rank,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	     IF Get_Pk_For_Validation(
    	       new_references.person_type_code)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
               IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      --BeforeInsertPTC;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      --BeforeUpdatePTC;
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.person_type_code)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
      BeforeDeletePTC;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To validate the fields after doing the DML operation.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  kumma           21-MAY-2002	 Added call to check_duplicate_per_type, Bug 2379779
  pkpatel         8-JUL-2002     Bug No: 2389552
                                 Removed the call to check_duplicate_per_type. This logic is now moved to post_forms_commit of the form.
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
    	AfterInsertPTC(new_references.Person_Type_Code);
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
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_TYPE IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_RANK IN NUMBER DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To insert a record.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PE_PERSON_TYPES
             where                 PERSON_TYPE_CODE= X_PERSON_TYPE_CODE
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
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_person_type_code=>X_PERSON_TYPE_CODE,
 	       x_description=>X_DESCRIPTION,
 	       x_system_type=>X_SYSTEM_TYPE,
 	       x_closed_ind=>X_CLOSED_IND,
 	       x_rank=>X_RANK,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_PE_PERSON_TYPES (
		PERSON_TYPE_CODE
		,DESCRIPTION
		,SYSTEM_TYPE
		,CLOSED_IND
		,RANK
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.PERSON_TYPE_CODE
	        ,NEW_REFERENCES.DESCRIPTION
	        ,NEW_REFERENCES.SYSTEM_TYPE
	        ,NEW_REFERENCES.CLOSED_IND
	        ,NEW_REFERENCES.RANK
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
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_TYPE IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_RANK IN NUMBER  DEFAULT NULL ) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To lock a record.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      DESCRIPTION
,      SYSTEM_TYPE
,      CLOSED_IND
    from IGS_PE_PERSON_TYPES
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
if ( (  tlinfo.DESCRIPTION = X_DESCRIPTION)
  AND (tlinfo.SYSTEM_TYPE = X_SYSTEM_TYPE)
  AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_TYPE IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_RANK IN NUMBER DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To update a record.
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
 	       x_person_type_code=>X_PERSON_TYPE_CODE,
 	       x_description=>X_DESCRIPTION,
 	       x_system_type=>X_SYSTEM_TYPE,
 	       x_closed_ind=>X_CLOSED_IND,
 	       x_rank=>X_RANK,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_PE_PERSON_TYPES set
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
      SYSTEM_TYPE =  NEW_REFERENCES.SYSTEM_TYPE,
      CLOSED_IND =  NEW_REFERENCES.CLOSED_IND,
      RANK =  NEW_REFERENCES.RANK,
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
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_TYPE IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_RANK IN NUMBER DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To insert/update a record.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PE_PERSON_TYPES
             where     PERSON_TYPE_CODE= X_PERSON_TYPE_CODE
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_PERSON_TYPE_CODE,
       X_DESCRIPTION,
       X_SYSTEM_TYPE,
       X_CLOSED_IND,
       X_RANK,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_PERSON_TYPE_CODE,
       X_DESCRIPTION,
       X_SYSTEM_TYPE,
       X_CLOSED_IND,
       X_RANK,
      X_MODE );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To delete a record.
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
 delete from IGS_PE_PERSON_TYPES
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_pe_person_types_pkg;

/
