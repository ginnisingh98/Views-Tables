--------------------------------------------------------
--  DDL for Package Body IGS_PE_STUP_DATA_EMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_STUP_DATA_EMT_PKG" AS
/* $Header: IGSNI45B.pls 115.8 2002/11/29 01:24:36 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_pe_stup_data_emt_all%RowType;
  new_references igs_pe_stup_data_emt_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_setup_data_element_id IN NUMBER DEFAULT NULL,
    x_person_type_code IN VARCHAR2 DEFAULT NULL,
    x_data_element IN VARCHAR2 DEFAULT NULL,
    x_value IN VARCHAR2 DEFAULT NULL,
    x_required_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    X_ORG_ID in NUMBER default NULL
  ) AS

  /*************************************************************
  Created By : svenkata
  Date Created By : 2000/05/11
  Purpose : To set column values before inserting / updating a row
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_stup_data_emt_all
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
    new_references.setup_data_element_id := x_setup_data_element_id;
    new_references.person_type_code := x_person_type_code;
    new_references.data_element := x_data_element;
    new_references.value := x_value;
    new_references.required_ind := x_required_ind;
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
  Created By : svenkata
  Date Created By : 2000/05/11
  Purpose : Checks if constraints are satisfied before insertion or modification of a record
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'REQUIRED_IND'  THEN
        new_references.required_ind := column_value;
        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'REQUIRED_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.required_ind IN ('M', 'P', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : svenkata
  Date Created By : 2000/05/11
  Purpose : Checks if a parent record exists before inserting or updating a row
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.person_type_code = new_references.person_type_code)) OR
        ((new_references.person_type_code IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Types_Pkg.Get_PK_For_Validation (
        		new_references.person_type_code
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.data_element = new_references.data_element)) OR
        ((new_references.data_element IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Data_Element_Pkg.Get_PK_For_Validation (
        		new_references.data_element
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_setup_data_element_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : svenkata
  Date Created By : 2000/05/11
  Purpose : Checks for duplicate Primary key
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_stup_data_emt_all
      WHERE    setup_data_element_id = x_setup_data_element_id
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

  PROCEDURE Get_FK_Igs_Pe_Person_Types (
    x_person_type_code IN VARCHAR2
    ) AS

  /*************************************************************
  Created By : svenkata
  Date Created By : 2000/05/11
  Purpose : Checks existance of child record
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_stup_data_emt_all
      WHERE    person_type_code = x_person_type_code ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PSDE_PT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person_Types;

  PROCEDURE Get_FK_Igs_Pe_Data_Element (
    x_data_element IN VARCHAR2
    ) AS

  /*************************************************************
  Created By : svenkata
  Date Created By : 2000/05/11
  Purpose : Checks existance of child record
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_stup_data_emt_all
      WHERE    data_element = x_data_element ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PSDE_PDE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Data_Element;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_setup_data_element_id IN NUMBER DEFAULT NULL,
    x_person_type_code IN VARCHAR2 DEFAULT NULL,
    x_data_element IN VARCHAR2 DEFAULT NULL,
    x_value IN VARCHAR2 DEFAULT NULL,
    x_required_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER default NULL
  ) AS
  /*************************************************************
  Created By : svenkata
  Date Created By : 2000/05/11
  Purpose : Executes steps to be carried out NOCOPY before any DML operation
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_setup_data_element_id,
      x_person_type_code,
      x_data_element,
      x_value,
      x_required_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.setup_data_element_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.setup_data_element_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
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
  Date Created By : 2000/05/11
  Purpose : Executes steps to be carried out NOCOPY after any DML operation
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
       x_SETUP_DATA_ELEMENT_ID IN OUT NOCOPY NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_REQUIRED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       x_org_id IN NUMBER
  ) AS
  /*************************************************************
  Created By : svenkata
  Date Created By : 2000/05/11
  Purpose : Inserts a row into a table
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from igs_pe_stup_data_emt_all
             where                 SETUP_DATA_ELEMENT_ID= X_SETUP_DATA_ELEMENT_ID
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


       SELECT IGS_PE_STUP_DATA_EMT_S.NEXTVAL INTO x_setup_data_element_id FROM DUAL;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_setup_data_element_id=>X_SETUP_DATA_ELEMENT_ID,
 	       x_person_type_code=>X_PERSON_TYPE_CODE,
 	       x_data_element=>X_DATA_ELEMENT,
 	       x_value=>X_VALUE,
 	       x_required_ind=>X_REQUIRED_IND,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
 	       x_org_id=>igs_ge_gen_003.get_org_id
);
     insert into igs_pe_stup_data_emt_all (
		SETUP_DATA_ELEMENT_ID
		,PERSON_TYPE_CODE
		,DATA_ELEMENT
		,VALUE
		,REQUIRED_IND
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN,
		 ORG_ID
        ) values  (
	        NEW_REFERENCES.SETUP_DATA_ELEMENT_ID
	        ,NEW_REFERENCES.PERSON_TYPE_CODE
	        ,NEW_REFERENCES.DATA_ELEMENT
	        ,NEW_REFERENCES.VALUE
	        ,NEW_REFERENCES.REQUIRED_IND
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN,
              NEW_REFERENCES.ORG_ID
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
       x_SETUP_DATA_ELEMENT_ID IN NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_REQUIRED_IND IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : svenkata
  Date Created By : 2000/05/11
  Purpose : Locks a particular row in a table
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      PERSON_TYPE_CODE
,      DATA_ELEMENT
,      VALUE
,      REQUIRED_IND
    from igs_pe_stup_data_emt_all
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
if ( (  tlinfo.PERSON_TYPE_CODE = X_PERSON_TYPE_CODE)
  AND (tlinfo.DATA_ELEMENT = X_DATA_ELEMENT)
  AND ((tlinfo.VALUE = X_VALUE)
 	    OR ((tlinfo.VALUE is null)
		AND (X_VALUE is null)))
  AND ((tlinfo.REQUIRED_IND = X_REQUIRED_IND)
 	    OR ((tlinfo.REQUIRED_IND is null)
		AND (X_REQUIRED_IND is null)))
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
       x_SETUP_DATA_ELEMENT_ID IN NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_REQUIRED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : svenkata
  Date Created By : 2000/05/11
  Purpose : Updates a row in the table
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
 	       x_setup_data_element_id=>X_SETUP_DATA_ELEMENT_ID,
 	       x_person_type_code=>X_PERSON_TYPE_CODE,
 	       x_data_element=>X_DATA_ELEMENT,
 	       x_value=>X_VALUE,
 	       x_required_ind=>X_REQUIRED_IND,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN
);
   update igs_pe_stup_data_emt_all set
      PERSON_TYPE_CODE =  NEW_REFERENCES.PERSON_TYPE_CODE,
      DATA_ELEMENT =  NEW_REFERENCES.DATA_ELEMENT,
      VALUE =  NEW_REFERENCES.VALUE,
      REQUIRED_IND =  NEW_REFERENCES.REQUIRED_IND,
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
       x_SETUP_DATA_ELEMENT_ID IN OUT NOCOPY NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_REQUIRED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  ) AS
  /*************************************************************
  Created By : svenkata
  Date Created By : 2000/05/11
  Purpose : Adds a new row to the table
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from igs_pe_stup_data_emt_all
             where     SETUP_DATA_ELEMENT_ID= X_SETUP_DATA_ELEMENT_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_SETUP_DATA_ELEMENT_ID,
       X_PERSON_TYPE_CODE,
       X_DATA_ELEMENT,
       X_VALUE,
       X_REQUIRED_IND,
      X_MODE ,
      x_org_id
);
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_SETUP_DATA_ELEMENT_ID,
       X_PERSON_TYPE_CODE,
       X_DATA_ELEMENT,
       X_VALUE,
       X_REQUIRED_IND,
      X_MODE
);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : svenkata
  Date Created By : 2000/05/11
  Purpose : Deletes a row from the table
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
 delete from igs_pe_stup_data_emt_all
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_pe_stup_data_emt_pkg;

/
