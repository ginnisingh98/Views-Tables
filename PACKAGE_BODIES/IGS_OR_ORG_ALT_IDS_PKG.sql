--------------------------------------------------------
--  DDL for Package Body IGS_OR_ORG_ALT_IDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_ORG_ALT_IDS_PKG" AS
/* $Header: IGSOI22B.pls 120.1 2006/03/28 09:12:42 skpandey noship $ */
  l_rowid VARCHAR2(25);
  old_references igs_or_org_alt_ids%RowType;
  new_references igs_or_org_alt_ids%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_structure_id IN VARCHAR2 DEFAULT NULL,
    x_org_structure_type IN VARCHAR2 DEFAULT NULL,
    x_org_alternate_id_type IN VARCHAR2 DEFAULT NULL,
    x_org_alternate_id IN VARCHAR2 DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : sbonam@in
  Date Created By : 2000/05/12
  Purpose : Populating the new_reference columns to be used by other
            Functions
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_OR_ORG_ALT_IDS
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
    new_references.org_structure_id := x_org_structure_id;
    new_references.org_structure_type := x_org_structure_type;
    new_references.org_alternate_id_type := x_org_alternate_id_type;
    new_references.org_alternate_id := x_org_alternate_id;
    new_references.start_date := x_start_date;
    new_references.end_date := x_end_date;
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
  Created By : sbonam@in
  Date Created By : 2000/05/12
  Purpose : To validate against any check constraints if any
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
  Created By : sbonam@in
  Date Created By : 2000/05/12
  Purpose : To check for Existence of Parent Values before
            inserting into foreign key columns
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.org_alternate_id_type = new_references.org_alternate_id_type)) OR
        ((new_references.org_alternate_id_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Or_Org_Alt_Idtyp_Pkg.Get_PK_For_Validation (
        		new_references.org_alternate_id_type
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;
    IF NOT Igs_Lookups_View_Pkg.Get_Pk_For_Validation('ORG_STRUCTURE_TYPE',new_references.org_structure_type) THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF new_references.org_structure_type = 'INSTITUTE' THEN
       IF NOT Igs_Or_Institution_Pkg.Get_Pk_For_Validation(new_references.org_structure_id) THEN
           FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
    ELSIF new_references.org_structure_type = 'LOCATION' THEN
       IF NOT Igs_Ad_Location_Pkg.Get_Pk_For_Validation(new_references.org_structure_id,
            'N') THEN
           FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
    ELSIF new_references.org_structure_type = 'ORG_UNIT' THEN
       IF NOT Igs_Or_Unit_Pkg.Get_Pk_For_Str_Validation(new_references.org_structure_id) THEN
           FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
    END IF;


  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_org_alternate_id IN VARCHAR2,
    x_org_alternate_id_type IN VARCHAR2,
    x_org_structure_id IN VARCHAR2,
    x_org_structure_type IN VARCHAR2,
    x_start_date IN DATE
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : sbonam@in.
  Date Created By : 2000/05/12
  Purpose : This function is used by other table handler's in their
            check_parent_existance to validate their foreign key
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_or_org_alt_ids
      WHERE    org_alternate_id = x_org_alternate_id
      AND      org_alternate_id_type = x_org_alternate_id_type
      AND      org_structure_id = x_org_structure_id
      AND      org_structure_type = x_org_structure_type
      AND      start_date = x_start_date
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

  PROCEDURE Get_FK_Igs_Or_Org_Alt_Idtyp (
    x_org_alternate_id_type IN VARCHAR2
    ) AS

  /*************************************************************
  Created By : sbonam@in
  Date Created By : 2000/05/12
  Purpose : This procedure is called from other tbh's check_child_existence
            to validate against the existence of records in the current table
            which is actually a child of the master table whose name appears
            in Get_Fk_<table_name>
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_or_org_alt_ids
      WHERE    org_alternate_id_type = x_org_alternate_id_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OLI_OAIT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Or_Org_Alt_Idtyp;

/*************************************************************
  Created By : sbonam@in
  Date Created By : 2000/05/23
  Purpose : This procedure is called from other tbh's check_child_existence
            to validate against the existence of records in the current table
            which is actually a child of the master table whose name appears
            in Get_Fk_<table_name>
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  PROCEDURE Get_Fk_Igs_Or_Institution(
    x_institution_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_OR_ORG_ALT_IDS
      WHERE    (
                (org_structure_id = x_institution_cd) AND (org_structure_type = 'INSTITUTE')
               );
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OLI_INS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END Get_Fk_Igs_Or_Institution;

/*************************************************************
  Created By : sbonam@in
  Date Created By : 2000/05/23
  Purpose : This procedure is called from other tbh's check_child_existence
            to validate against the existence of records in the current table
            which is actually a child of the master table whose name appears
            in Get_Fk_<table_name>
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
***************************************************************/
  PROCEDURE Get_Fk_Igs_Or_Unit (
    x_org_unit_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_OR_ORG_ALT_IDS
      WHERE    (
                (org_structure_id = x_org_unit_cd) AND (org_structure_type = 'ORG_UNIT')
               );

    lv_rowid  cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OLI_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END Get_Fk_Igs_Or_Unit;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_structure_id IN VARCHAR2 DEFAULT NULL,
    x_org_structure_type IN VARCHAR2 DEFAULT NULL,
    x_org_alternate_id_type IN VARCHAR2 DEFAULT NULL,
    x_org_alternate_id IN VARCHAR2 DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : sbonam@in
  Date Created By : 2000/05/12
  Purpose : This procedure is called before any DML operation
            with the DML operation as a parameter. This is
            a function that is called from other functions only like
            insert_row/add_row etc. This would not be called from Forms directly.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_structure_id,
      x_org_structure_type,
      x_org_alternate_id_type,
      x_org_alternate_id,
      x_start_date,
      x_end_date,
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
    		new_references.org_alternate_id,
    		new_references.org_alternate_id_type,
    		new_references.org_structure_id,
    		new_references.org_structure_type,
    		new_references.start_date)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
    		new_references.org_alternate_id,
    		new_references.org_alternate_id_type,
    		new_references.org_structure_id,
    		new_references.org_structure_type,
    		new_references.start_date)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
  Created By : sbonam@in
  Date Created By : 2000/05/12
  Purpose : This procedure is called after any DML operation
            with the DML operation as a parameter. This is
            a function that is called from other functions only like
            insert_row/add_row etc. This would not be called from Forms directly.
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
       x_ORG_STRUCTURE_ID IN VARCHAR2,
       x_ORG_STRUCTURE_TYPE IN VARCHAR2,
       x_ORG_ALTERNATE_ID_TYPE IN VARCHAR2,
       x_ORG_ALTERNATE_ID IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :
  Date Created By : 2000/05/12
  Purpose : This procedure is called from Forms during an
            insert_row (ON_INSERT) operation. This in turn
            calls Before_DML which inturn calls set_columns
            and check_parent_existance  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_OR_ORG_ALT_IDS
             where                 ORG_ALTERNATE_ID= X_ORG_ALTERNATE_ID
            and ORG_ALTERNATE_ID_TYPE = X_ORG_ALTERNATE_ID_TYPE
            and ORG_STRUCTURE_ID = X_ORG_STRUCTURE_ID
            and ORG_STRUCTURE_TYPE = X_ORG_STRUCTURE_TYPE
            and START_DATE = X_START_DATE
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
 	       x_org_structure_id=>X_ORG_STRUCTURE_ID,
 	       x_org_structure_type=>X_ORG_STRUCTURE_TYPE,
 	       x_org_alternate_id_type=>X_ORG_ALTERNATE_ID_TYPE,
 	       x_org_alternate_id=>X_ORG_ALTERNATE_ID,
 	       x_start_date=>X_START_DATE,
 	       x_end_date=>X_END_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_OR_ORG_ALT_IDS (
		ORG_STRUCTURE_ID
		,ORG_STRUCTURE_TYPE
		,ORG_ALTERNATE_ID_TYPE
		,ORG_ALTERNATE_ID
		,START_DATE
		,END_DATE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.ORG_STRUCTURE_ID
	        ,NEW_REFERENCES.ORG_STRUCTURE_TYPE
	        ,NEW_REFERENCES.ORG_ALTERNATE_ID_TYPE
	        ,NEW_REFERENCES.ORG_ALTERNATE_ID
	        ,NEW_REFERENCES.START_DATE
	        ,NEW_REFERENCES.END_DATE
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
       x_ORG_STRUCTURE_ID IN VARCHAR2,
       x_ORG_STRUCTURE_TYPE IN VARCHAR2,
       x_ORG_ALTERNATE_ID_TYPE IN VARCHAR2,
       x_ORG_ALTERNATE_ID IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE  ) AS
  /*************************************************************
  Created By : sbonam@in
  Date Created By : 2000/05/12
  Purpose : This procedure is called from Forms during an
            lock_row (ON_LOCK) operation.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      END_DATE
    from IGS_OR_ORG_ALT_IDS
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
if ( (  (tlinfo.END_DATE = X_END_DATE)
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
       x_ORG_STRUCTURE_ID IN VARCHAR2,
       x_ORG_STRUCTURE_TYPE IN VARCHAR2,
       x_ORG_ALTERNATE_ID_TYPE IN VARCHAR2,
       x_ORG_ALTERNATE_ID IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : sbonam@in.
  Date Created By : 2000/05/12
  Purpose : This procedure is called from Forms during an
            insert_row (ON_UPDATE) operation. This procedure
            checks if there is a row for the given primary key and
            if there isn't one then inserts it.
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
 	       x_org_structure_id=>X_ORG_STRUCTURE_ID,
 	       x_org_structure_type=>X_ORG_STRUCTURE_TYPE,
 	       x_org_alternate_id_type=>X_ORG_ALTERNATE_ID_TYPE,
 	       x_org_alternate_id=>X_ORG_ALTERNATE_ID,
 	       x_start_date=>X_START_DATE,
 	       x_end_date=>X_END_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_OR_ORG_ALT_IDS set
      END_DATE =  NEW_REFERENCES.END_DATE,
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
       x_ORG_STRUCTURE_ID IN VARCHAR2,
       x_ORG_STRUCTURE_TYPE IN VARCHAR2,
       x_ORG_ALTERNATE_ID_TYPE IN VARCHAR2,
       x_ORG_ALTERNATE_ID IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : sbonam@in
  Date Created By : 2000/05/12
  Purpose : This procedure is called from Forms during an
            insert_row (ON_INSERT) operation. This procedure
            checks if there is a row for the given primary key and
            if there isn't one then inserts it.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_OR_ORG_ALT_IDS
             where     ORG_ALTERNATE_ID= X_ORG_ALTERNATE_ID
            and ORG_ALTERNATE_ID_TYPE = X_ORG_ALTERNATE_ID_TYPE
            and ORG_STRUCTURE_ID = X_ORG_STRUCTURE_ID
            and ORG_STRUCTURE_TYPE = X_ORG_STRUCTURE_TYPE
            and START_DATE = X_START_DATE
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_ORG_STRUCTURE_ID,
       X_ORG_STRUCTURE_TYPE,
       X_ORG_ALTERNATE_ID_TYPE,
       X_ORG_ALTERNATE_ID,
       X_START_DATE,
       X_END_DATE,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_ORG_STRUCTURE_ID,
       X_ORG_STRUCTURE_TYPE,
       X_ORG_ALTERNATE_ID_TYPE,
       X_ORG_ALTERNATE_ID,
       X_START_DATE,
       X_END_DATE,
      X_MODE );
end ADD_ROW;


PROCEDURE DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : sbonam@in
  Date Created By : 2000/05/12
  Purpose : This procedure is called from Forms during an
            delete_row (ON_DELETE) operation.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  skpandey        28-MAR-2006     Bug#:3634881, RECORD ALREADY EXISTS WHEN INSERTING A NEW ORG ALTERNATE ID, DUPLICATE AT INST
  (reverse chronological order - newest change first)
  ***************************************************************/
--Check Duplicate record and then delete
CURSOR cur_get_rowid(cp_org_alt_id_typ igs_or_cwlk_dtl.alt_id_type%TYPE, cp_alt_id_val igs_or_cwlk_dtl.alt_id_value%TYPE, cp_rowid ROWID) IS
      SELECT   rowid
      FROM     igs_or_cwlk_dtl
      WHERE    alt_id_type = cp_org_alt_id_typ
      AND      alt_id_value = cp_alt_id_val
      AND NOT EXISTS ( SELECT 1
		       FROM igs_or_org_alt_ids
		       WHERE org_alternate_id_type = alt_id_type
		       AND org_alternate_id = alt_id_value
		       AND rowid <> cp_rowid);
l_row_id ROWID;

BEGIN
	Before_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
	);

	OPEN cur_get_rowid(old_references.org_alternate_id_type, old_references.org_alternate_id, X_ROWID );
	FETCH cur_get_rowid INTO l_row_id;
	CLOSE cur_get_rowid;

	 delete from IGS_OR_ORG_ALT_IDS
	 where ROWID = X_ROWID;
	  if (sql%notfound) then
	    raise no_data_found;
	  end if;

	After_DML (
	 p_action => 'DELETE',
	 x_rowid => X_ROWID
	);
	IF l_row_id IS NOT NULL THEN
		igs_or_cwlk_dtl_pkg.delete_row(x_rowid => l_row_id);
	END IF;

END DELETE_ROW;

END igs_or_org_alt_ids_pkg;

/
