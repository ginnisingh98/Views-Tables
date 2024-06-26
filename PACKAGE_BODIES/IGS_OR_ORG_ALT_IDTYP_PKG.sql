--------------------------------------------------------
--  DDL for Package Body IGS_OR_ORG_ALT_IDTYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_ORG_ALT_IDTYP_PKG" AS
/* $Header: IGSOI16B.pls 115.11 2003/09/29 06:08:48 ssaleem ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_or_org_alt_idtyp%RowType;
  new_references igs_or_org_alt_idtyp%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_org_alternate_id_type IN VARCHAR2 ,
    x_id_type_description IN VARCHAR2 ,
    x_inst_flag IN VARCHAR2 ,
    x_unit_flag IN VARCHAR2 ,
    x_close_ind IN VARCHAR2 ,
    x_SYSTEM_ID_TYPE IN VARCHAR2 ,
    x_PREF_INST_IND IN VARCHAR2 ,
    x_PREF_UNIT_IND IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS

  /*************************************************************
  Created By : hchauhan
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_OR_ORG_ALT_IDTYP
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
    new_references.org_alternate_id_type := x_org_alternate_id_type;
    new_references.id_type_description := x_id_type_description;
    new_references.inst_flag := x_inst_flag;
    new_references.unit_flag := x_unit_flag;
    new_references.close_ind := x_close_ind;

    new_references.system_id_type := x_system_id_type;
    new_references.pref_inst_ind := x_pref_inst_ind;
    new_references.pref_unit_ind := x_pref_unit_ind;

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
		 Column_Value IN VARCHAR2 ) AS
  /*************************************************************
  Created By : hchauhan
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'INST_FLAG'  THEN
        new_references.inst_flag := column_value;
      ELSIF  UPPER(column_name) = 'UNIT_FLAG'  THEN
        new_references.unit_flag := column_value;
      ELSIF  UPPER(column_name) = 'CLOSE_IND'  THEN
        new_references.close_ind := column_value;
        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'UNIT_FLAG' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.unit_flag IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'CLOSE_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.close_ind IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'INST_FLAG' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.inst_flag IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : hchauhan
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Or_Org_Alt_Ids_Pkg.Get_FK_Igs_Or_Org_Alt_Idtyp (
      old_references.org_alternate_id_type
      );

    igs_da_setup_pkg.get_fk_igs_or_org_alt_idtyp(old_references.org_alternate_id_type);

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_org_alternate_id_type IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : hchauhan
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ssaleem         19-SEP-2003     Added another condition (CLOSE_IND = 'N') for pk validation
  pkpatel         8-SEP-2003      Bug 3132214 (Removed the FOR UPDATE NOWAIT since delete is not allowed any more)
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_or_org_alt_idtyp
      WHERE    org_alternate_id_type = x_org_alternate_id_type AND
               CLOSE_IND = 'N';

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
    x_org_alternate_id_type IN VARCHAR2 ,
    x_id_type_description IN VARCHAR2 ,
    x_inst_flag IN VARCHAR2 ,
    x_unit_flag IN VARCHAR2 ,
    x_close_ind IN VARCHAR2 ,
    x_SYSTEM_ID_TYPE IN VARCHAR2 ,
    x_PREF_INST_IND IN VARCHAR2 ,
    x_PREF_UNIT_IND IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
  /*************************************************************
  Created By : hchauhan
  Date Created By : 2000/05/12
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
      x_org_alternate_id_type,
      x_id_type_description,
      x_inst_flag,
      x_unit_flag,
      x_close_ind,
      x_system_id_type,
      x_pref_inst_ind,
      x_pref_unit_ind,
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
    		new_references.org_alternate_id_type)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
    		new_references.org_alternate_id_type)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
  Created By : hchauhan
  Date Created By : 2000/05/12
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

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_ORG_ALTERNATE_ID_TYPE IN VARCHAR2,
       x_ID_TYPE_DESCRIPTION IN VARCHAR2,
       x_INST_FLAG IN VARCHAR2,
       x_UNIT_FLAG IN VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
       x_SYSTEM_ID_TYPE IN VARCHAR2 ,
       x_PREF_INST_IND IN VARCHAR2 ,
       x_PREF_UNIT_IND IN VARCHAR2 ,
       X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By : hchauhan
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_OR_ORG_ALT_IDTYP
             where                 ORG_ALTERNATE_ID_TYPE= X_ORG_ALTERNATE_ID_TYPE
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
 	       x_org_alternate_id_type=>X_ORG_ALTERNATE_ID_TYPE,
 	       x_id_type_description=>X_ID_TYPE_DESCRIPTION,
 	       x_inst_flag=>X_INST_FLAG,
 	       x_unit_flag=>X_UNIT_FLAG,
 	       x_close_ind=>X_CLOSE_IND,
		   x_SYSTEM_ID_TYPE=>X_SYSTEM_ID_TYPE,
 	       x_PREF_INST_IND=>X_PREF_INST_IND,
 	       x_PREF_UNIT_IND=>X_PREF_UNIT_IND,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_OR_ORG_ALT_IDTYP (
		ORG_ALTERNATE_ID_TYPE
		,ID_TYPE_DESCRIPTION
		,INST_FLAG
		,UNIT_FLAG
		,CLOSE_IND
        ,SYSTEM_ID_TYPE
        ,PREF_INST_IND
        ,PREF_UNIT_IND
	    ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.ORG_ALTERNATE_ID_TYPE
	        ,NEW_REFERENCES.ID_TYPE_DESCRIPTION
	        ,NEW_REFERENCES.INST_FLAG
	        ,NEW_REFERENCES.UNIT_FLAG
	        ,NEW_REFERENCES.CLOSE_IND
	        ,NEW_REFERENCES.SYSTEM_ID_TYPE
	        ,NEW_REFERENCES.PREF_INST_IND
	        ,NEW_REFERENCES.PREF_UNIT_IND
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
       x_ORG_ALTERNATE_ID_TYPE IN VARCHAR2,
       x_ID_TYPE_DESCRIPTION IN VARCHAR2,
       x_INST_FLAG IN VARCHAR2,
       x_UNIT_FLAG IN VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
	   x_SYSTEM_ID_TYPE IN VARCHAR2 ,
       x_PREF_INST_IND IN VARCHAR2 ,
       x_PREF_UNIT_IND IN VARCHAR2 ) AS
  /*************************************************************
  Created By : hchauhan
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select *
    from IGS_OR_ORG_ALT_IDTYP
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
if ( (  tlinfo.ID_TYPE_DESCRIPTION = X_ID_TYPE_DESCRIPTION)
  AND ((tlinfo.INST_FLAG = X_INST_FLAG)
 	    OR ((tlinfo.INST_FLAG is null)
		AND (X_INST_FLAG is null)))
  AND ((tlinfo.UNIT_FLAG = X_UNIT_FLAG)
 	    OR ((tlinfo.UNIT_FLAG is null)
		AND (X_UNIT_FLAG is null)))
  AND ((tlinfo.CLOSE_IND = X_CLOSE_IND)
 	    OR ((tlinfo.CLOSE_IND is null)
		AND (X_CLOSE_IND is null)))
  AND ((tlinfo.SYSTEM_ID_TYPE = X_SYSTEM_ID_TYPE)
 	    OR ((tlinfo.SYSTEM_ID_TYPE is null)
		AND (X_SYSTEM_ID_TYPE is null)))
  AND ((tlinfo.PREF_INST_IND = X_PREF_INST_IND)
 	    OR ((tlinfo.PREF_INST_IND is null)
		AND (X_PREF_INST_IND is null)))
  AND ((tlinfo.PREF_UNIT_IND = X_PREF_UNIT_IND)
 	    OR ((tlinfo.PREF_UNIT_IND is null)
		AND (X_PREF_UNIT_IND is null)))
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
       x_ORG_ALTERNATE_ID_TYPE IN VARCHAR2,
       x_ID_TYPE_DESCRIPTION IN VARCHAR2,
       x_INST_FLAG IN VARCHAR2,
       x_UNIT_FLAG IN VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
       x_SYSTEM_ID_TYPE IN VARCHAR2 ,
       x_PREF_INST_IND IN VARCHAR2 ,
       x_PREF_UNIT_IND IN VARCHAR2 ,
       X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By : hchauhan
  Date Created By : 2000/05/12
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
 	       x_org_alternate_id_type=>X_ORG_ALTERNATE_ID_TYPE,
 	       x_id_type_description=>X_ID_TYPE_DESCRIPTION,
 	       x_inst_flag=>X_INST_FLAG,
 	       x_unit_flag=>X_UNIT_FLAG,
 	       x_close_ind=>X_CLOSE_IND,
 	       x_SYSTEM_ID_TYPE=>X_SYSTEM_ID_TYPE,
 	       x_PREF_INST_IND=>X_PREF_INST_IND,
 	       x_PREF_UNIT_IND=>X_PREF_UNIT_IND,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);

   update IGS_OR_ORG_ALT_IDTYP set
      ID_TYPE_DESCRIPTION =  NEW_REFERENCES.ID_TYPE_DESCRIPTION,
      INST_FLAG =  NEW_REFERENCES.INST_FLAG,
      UNIT_FLAG =  NEW_REFERENCES.UNIT_FLAG,
      CLOSE_IND =  NEW_REFERENCES.CLOSE_IND,
      SYSTEM_ID_TYPE =  NEW_REFERENCES.SYSTEM_ID_TYPE,
      PREF_INST_IND =  NEW_REFERENCES.PREF_INST_IND,
      PREF_UNIT_IND =  NEW_REFERENCES.PREF_UNIT_IND,
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
       x_ORG_ALTERNATE_ID_TYPE IN VARCHAR2,
       x_ID_TYPE_DESCRIPTION IN VARCHAR2,
       x_INST_FLAG IN VARCHAR2,
       x_UNIT_FLAG IN VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
       x_SYSTEM_ID_TYPE IN VARCHAR2 ,
       x_PREF_INST_IND IN VARCHAR2 ,
       x_PREF_UNIT_IND IN VARCHAR2 ,
       X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By : hchauhan
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_OR_ORG_ALT_IDTYP
             where     ORG_ALTERNATE_ID_TYPE= X_ORG_ALTERNATE_ID_TYPE
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_ORG_ALTERNATE_ID_TYPE,
       X_ID_TYPE_DESCRIPTION,
       X_INST_FLAG,
       X_UNIT_FLAG,
       X_CLOSE_IND,
       X_SYSTEM_ID_TYPE,
       X_PREF_INST_IND,
       X_PREF_UNIT_IND,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_ORG_ALTERNATE_ID_TYPE,
       X_ID_TYPE_DESCRIPTION,
       X_INST_FLAG,
       X_UNIT_FLAG,
       X_CLOSE_IND,
       X_SYSTEM_ID_TYPE,
       X_PREF_INST_IND,
       X_PREF_UNIT_IND,
      X_MODE );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : hchauhan
  Date Created By : 2000/05/12
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
 delete from IGS_OR_ORG_ALT_IDTYP
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;

END igs_or_org_alt_idtyp_pkg;

/
