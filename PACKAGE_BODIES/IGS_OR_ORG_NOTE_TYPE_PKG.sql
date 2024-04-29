--------------------------------------------------------
--  DDL for Package Body IGS_OR_ORG_NOTE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_ORG_NOTE_TYPE_PKG" AS
/* $Header: IGSOI17B.pls 120.0 2005/06/01 12:57:41 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references igs_or_org_note_type%RowType;
  new_references igs_or_org_note_type%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_notes_type IN VARCHAR2 DEFAULT NULL,
    x_note_type_description IN VARCHAR2 DEFAULT NULL,
    x_inst_flag IN VARCHAR2 DEFAULT NULL,
    x_unit_flag IN VARCHAR2 DEFAULT NULL,
    x_location_flag IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
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
      FROM     IGS_OR_ORG_NOTE_TYPE
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
    new_references.org_notes_type := x_org_notes_type;
    new_references.note_type_description := x_note_type_description;
    new_references.inst_flag := x_inst_flag;
    new_references.unit_flag := x_unit_flag;
    new_references.location_flag := x_location_flag;
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
      ELSIF  UPPER(column_name) = 'UNIT_FLAG'  THEN
        new_references.unit_flag := column_value;
      ELSIF  UPPER(column_name) = 'LOCATION_FLAG'  THEN
        new_references.location_flag := column_value;
      ELSIF  UPPER(column_name) = 'INST_FLAG'  THEN
        new_references.inst_flag := column_value;
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
      IF Upper(Column_Name) = 'LOCATION_FLAG' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.location_flag IN ('Y', 'N'))  THEN
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

    Igs_Or_Org_Notes_Pkg.Get_FK_Igs_Or_Org_Note_Type (
      old_references.org_notes_type
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_org_notes_type IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : hchauhan
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_or_org_note_type
      WHERE    org_notes_type = x_org_notes_type
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
    x_org_notes_type IN VARCHAR2 DEFAULT NULL,
    x_note_type_description IN VARCHAR2 DEFAULT NULL,
    x_inst_flag IN VARCHAR2 DEFAULT NULL,
    x_unit_flag IN VARCHAR2 DEFAULT NULL,
    x_location_flag IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
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
      x_org_notes_type,
      x_note_type_description,
      x_inst_flag,
      x_unit_flag,
      x_location_flag,
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
    		new_references.org_notes_type)  THEN
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
    		new_references.org_notes_type)  THEN
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
       x_ORG_NOTES_TYPE IN VARCHAR2,
       x_NOTE_TYPE_DESCRIPTION IN VARCHAR2,
       x_INST_FLAG IN VARCHAR2,
       x_UNIT_FLAG IN VARCHAR2,
       x_LOCATION_FLAG IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
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

    cursor C is select ROWID from IGS_OR_ORG_NOTE_TYPE
             where                 ORG_NOTES_TYPE= X_ORG_NOTES_TYPE
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
 	       x_org_notes_type=>X_ORG_NOTES_TYPE,
 	       x_note_type_description=>X_NOTE_TYPE_DESCRIPTION,
 	       x_inst_flag=>X_INST_FLAG,
 	       x_unit_flag=>X_UNIT_FLAG,
 	       x_location_flag=>X_LOCATION_FLAG,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_OR_ORG_NOTE_TYPE (
		ORG_NOTES_TYPE
		,NOTE_TYPE_DESCRIPTION
		,INST_FLAG
		,UNIT_FLAG
		,LOCATION_FLAG
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.ORG_NOTES_TYPE
	        ,NEW_REFERENCES.NOTE_TYPE_DESCRIPTION
	        ,NEW_REFERENCES.INST_FLAG
	        ,NEW_REFERENCES.UNIT_FLAG
	        ,NEW_REFERENCES.LOCATION_FLAG
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
       x_ORG_NOTES_TYPE IN VARCHAR2,
       x_NOTE_TYPE_DESCRIPTION IN VARCHAR2,
       x_INST_FLAG IN VARCHAR2,
       x_UNIT_FLAG IN VARCHAR2,
       x_LOCATION_FLAG IN VARCHAR2  ) AS
  /*************************************************************
  Created By : hchauhan
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      NOTE_TYPE_DESCRIPTION
,      INST_FLAG
,      UNIT_FLAG
,      LOCATION_FLAG
    from IGS_OR_ORG_NOTE_TYPE
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
if ( (  (tlinfo.NOTE_TYPE_DESCRIPTION = X_NOTE_TYPE_DESCRIPTION)
 	    OR ((tlinfo.NOTE_TYPE_DESCRIPTION is null)
		AND (X_NOTE_TYPE_DESCRIPTION is null)))
  AND ((tlinfo.INST_FLAG = X_INST_FLAG)
 	    OR ((tlinfo.INST_FLAG is null)
		AND (X_INST_FLAG is null)))
  AND ((tlinfo.UNIT_FLAG = X_UNIT_FLAG)
 	    OR ((tlinfo.UNIT_FLAG is null)
		AND (X_UNIT_FLAG is null)))
  AND ((tlinfo.LOCATION_FLAG = X_LOCATION_FLAG)
 	    OR ((tlinfo.LOCATION_FLAG is null)
		AND (X_LOCATION_FLAG is null)))
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
       x_ORG_NOTES_TYPE IN VARCHAR2,
       x_NOTE_TYPE_DESCRIPTION IN VARCHAR2,
       x_INST_FLAG IN VARCHAR2,
       x_UNIT_FLAG IN VARCHAR2,
       x_LOCATION_FLAG IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
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
 	       x_org_notes_type=>X_ORG_NOTES_TYPE,
 	       x_note_type_description=>X_NOTE_TYPE_DESCRIPTION,
 	       x_inst_flag=>X_INST_FLAG,
 	       x_unit_flag=>X_UNIT_FLAG,
 	       x_location_flag=>X_LOCATION_FLAG,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_OR_ORG_NOTE_TYPE set
      NOTE_TYPE_DESCRIPTION =  NEW_REFERENCES.NOTE_TYPE_DESCRIPTION,
      INST_FLAG =  NEW_REFERENCES.INST_FLAG,
      UNIT_FLAG =  NEW_REFERENCES.UNIT_FLAG,
      LOCATION_FLAG =  NEW_REFERENCES.LOCATION_FLAG,
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
       x_ORG_NOTES_TYPE IN VARCHAR2,
       x_NOTE_TYPE_DESCRIPTION IN VARCHAR2,
       x_INST_FLAG IN VARCHAR2,
       x_UNIT_FLAG IN VARCHAR2,
       x_LOCATION_FLAG IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
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

    cursor c1 is select ROWID from IGS_OR_ORG_NOTE_TYPE
             where     ORG_NOTES_TYPE= X_ORG_NOTES_TYPE
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_ORG_NOTES_TYPE,
       X_NOTE_TYPE_DESCRIPTION,
       X_INST_FLAG,
       X_UNIT_FLAG,
       X_LOCATION_FLAG,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_ORG_NOTES_TYPE,
       X_NOTE_TYPE_DESCRIPTION,
       X_INST_FLAG,
       X_UNIT_FLAG,
       X_LOCATION_FLAG,
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
 delete from IGS_OR_ORG_NOTE_TYPE
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_or_org_note_type_pkg;

/
