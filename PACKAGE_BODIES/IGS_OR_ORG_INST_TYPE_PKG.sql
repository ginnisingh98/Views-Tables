--------------------------------------------------------
--  DDL for Package Body IGS_OR_ORG_INST_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_ORG_INST_TYPE_PKG" AS
/* $Header: IGSOI19B.pls 120.0 2005/06/01 16:49:51 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references igs_or_org_inst_type_all%RowType;
  new_references igs_or_org_inst_type_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_institution_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_SYSTEM_INST_TYPE VARCHAR2,
    x_close_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    X_ORG_ID in NUMBER  DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : ssahai
  Date Created By : 11/05/2000
  Purpose : Populating the new_references columns to be used by other functions.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_or_org_inst_type_all
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
    new_references.institution_type := x_institution_type;
    new_references.description := x_description;
    new_references.system_inst_type := x_system_inst_type;
    new_references.close_ind := x_close_ind;
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
  Created By : ssahai
  Date Created By : 11/5/2000
  Purpose : To check for the existance of Parent values before inserting into foreign key columns.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'CLOSE_IND'  THEN
        new_references.close_ind := column_value;
        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'CLOSE_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.close_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : ssahai
  Date Created By : 11/5/2000
  Purpose : To check for the existance of of child records before deleting the records from this table
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  Aiyer           04-Feb-2003     Modified for the bug 2664699
                                  Replaced call to IGS_AD_I_ENTRY_STATS_PKG.GET_FK_FOR_VALIDATION
				  with IGS_RC_I_ENT_STATS_PKG.GET_FK_FOR_VALIDATION
  Gmaheswa	  18-Mar-2005     Modified for bug 4207144. Deleted the reference to IGS_RC_I_ENT_STATS_PKG
				  as it is obsoleted.
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Or_Institution_Pkg.Get_FK_Igs_Or_Org_Inst_Type (
      old_references.institution_type
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_institution_type IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : ssahai
  Date Created By : 11/5/2000
  Purpose : This function is used by other TBH's in their check_parent_existance to validate their their Foreign key values to this PK.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_or_org_inst_type_all
      WHERE    institution_type = x_institution_type
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
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_institution_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_SYSTEM_INST_TYPE VARCHAR2 DEFAULT NULL,
    x_close_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER  DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : ssahai
  Date Created By : 11/5/2000
  Purpose : This procedure is called before any DML operation as a parameter.
  This is a function which is called from other functions like insert_row/ add_row etc.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_institution_type,
      x_description,
      x_SYSTEM_INST_TYPE,
      x_close_ind,
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
    		new_references.institution_type)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.institution_type)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : ssahai
  Date Created By : 11/5/2000
  Purpose : In case there are any after dml operations functions are to be performed, those can come in here.
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
       x_INSTITUTION_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_INST_TYPE VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
      X_ORG_ID in NUMBER
  ) AS
  /*************************************************************
  Created By : ssahai
  Date Created By : 11/5/2000
  Purpose : This procedure is called from forms during an insert_row (ON_INSERT) operation.
  This in turn calls before_dml.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from igs_or_org_inst_type_all
             where                 INSTITUTION_TYPE= X_INSTITUTION_TYPE
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
 	       x_institution_type=>X_INSTITUTION_TYPE,
 	       x_description=>X_DESCRIPTION,
               x_SYSTEM_INST_TYPE=>x_system_inst_type,
 	       x_close_ind=>X_CLOSE_IND,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_org_id=>igs_ge_gen_003.get_org_id);

     insert into igs_or_org_inst_type_all (
		INSTITUTION_TYPE
		,DESCRIPTION
		,SYSTEM_INST_TYPE
		,CLOSE_IND
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
            ,ORG_ID
        ) values  (
  	         NEW_REFERENCES.INSTITUTION_TYPE
	        ,NEW_REFERENCES.DESCRIPTION
		,NEW_REFERENCES.SYSTEM_INST_TYPE
	        ,NEW_REFERENCES.CLOSE_IND
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
       x_INSTITUTION_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_INST_TYPE VARCHAR2,
       x_CLOSE_IND IN VARCHAR2  ) AS
  /*************************************************************
  Created By : ssahai
  Date Created By : 11/5/2000
  Purpose : This procedure is called from forms during lock_row (ON_LOCK) operation
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      DESCRIPTION
,      CLOSE_IND
,      SYSTEM_INST_TYPE
    from igs_or_org_inst_type_all
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
if ( (  tlinfo.DESCRIPTION = X_DESCRIPTION)   AND (tlinfo.system_inst_type = x_system_inst_type)
  AND ((tlinfo.CLOSE_IND = X_CLOSE_IND)
 	    OR ((tlinfo.CLOSE_IND is null)
		AND (X_CLOSE_IND is null)))

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
       x_INSTITUTION_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_INST_TYPE VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : ssahai
  Date Created By : 11/5/2000
  Purpose : This procedure is used to update a row in case the PK of the row being updated is present. It is called from ADD_ROW.
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
 	       x_institution_type=>X_INSTITUTION_TYPE,
 	       x_description=>X_DESCRIPTION,
               x_SYSTEM_INST_TYPE => X_SYSTEM_INST_TYPE,
 	       x_close_ind=>X_CLOSE_IND,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update igs_or_org_inst_type_all set
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
      SYSTEM_INST_TYPE = NEW_REFERENCES.SYSTEM_INST_TYPE,
      CLOSE_IND =  NEW_REFERENCES.CLOSE_IND,
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
       x_INSTITUTION_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_INST_TYPE VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
      X_ORG_ID in NUMBER
  ) AS
  /*************************************************************
  Created By : ssahai
  Date Created By : 11/5/2000
  Purpose : This procedure is called from forms during an insert_row (INSERT_ROW) - It checks if there is a
  row for the given PK and if there isn't then it inserts it as a new row. If there is a existing Pk then it
  uses update_row to update the same row.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from igs_or_org_inst_type_all
             where     INSTITUTION_TYPE= X_INSTITUTION_TYPE
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_INSTITUTION_TYPE,
       X_DESCRIPTION,
       x_SYSTEM_INST_TYPE,
       X_CLOSE_IND,
      X_MODE ,
      x_org_id);
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_INSTITUTION_TYPE,
       X_DESCRIPTION,
       x_SYSTEM_INST_TYPE,
       X_CLOSE_IND,
      X_MODE );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : ssahai
  Date Created By : 11/5/2000
  Purpose : This procedure is called from forms during an delete_row (ON_DELETE) operation.
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
 delete from igs_or_org_inst_type_all
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_or_org_inst_type_pkg;

/
