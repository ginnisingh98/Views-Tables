--------------------------------------------------------
--  DDL for Package Body IGS_OR_ORG_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_ORG_NOTES_PKG" AS
/* $Header: IGSOI18B.pls 115.8 2003/10/30 13:29:55 rghosh ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_or_org_notes%RowType;
  new_references igs_or_org_notes%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_structure_id IN VARCHAR2 DEFAULT NULL,
    x_org_structure_type IN VARCHAR2 DEFAULT NULL,
    x_org_note_sequence IN NUMBER DEFAULT NULL,
    x_org_note_type IN VARCHAR2 DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_note_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :rareddy
  Date Created By :
  Purpose : initilizing column values
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_OR_ORG_NOTES
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
    new_references.org_note_sequence := x_org_note_sequence;
    new_references.org_note_type := x_org_note_type;
    new_references.start_date := x_start_date;
    new_references.end_date := x_end_date;
    new_references.note_text := x_note_text;
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
  Created By :rareddy
  Date Created By :
  Purpose : item level validation
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
  Created By :rareddy
  Date Created By :
  Purpose : when a DML is made in child
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.org_note_type = new_references.org_note_type)) OR
        ((new_references.org_note_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Or_Org_Note_Type_Pkg.Get_PK_For_Validation (
        		new_references.org_note_type
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;
    IF NOT Igs_Lookups_View_Pkg.Get_Pk_For_Validation('ORG_STRUCTURE_TYPE',
    new_references.org_structure_type) THEN
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
    x_org_structure_type IN VARCHAR2,
    x_org_note_sequence IN NUMBER,
    x_org_note_type IN VARCHAR2,
    x_org_structure_id IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :rareddy
  Date Created By :
  Purpose : PK check
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_or_org_notes
      WHERE    org_structure_type = x_org_structure_type
      AND      org_note_sequence = x_org_note_sequence
      AND      org_note_type = x_org_note_type
      AND      org_structure_id = x_org_structure_id
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

  PROCEDURE Get_FK_Igs_Or_Org_Note_Type (
    x_org_notes_type IN VARCHAR2
    ) AS

  /*************************************************************
  Created By :rareddy
  Date Created By :
  Purpose : FK check
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_or_org_notes
      WHERE    org_note_type = x_org_notes_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OON_ONT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Or_Org_Note_Type;

  PROCEDURE GET_FK_IGS_OR_INSTITUTION (
    x_institution_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_OR_ORG_NOTES
      WHERE    (
                 (org_structure_id = x_institution_cd) AND (org_structure_type = 'INSTITUTE')
               );
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OON_INS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_OR_INSTITUTION;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_OR_ORG_NOTES
      WHERE    (
                 (org_structure_id = x_location_cd) AND (org_structure_type = 'LOCATION')
               );
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OON_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_OR_ORG_NOTES
      WHERE    (
                 (org_structure_id = x_org_unit_cd) AND (org_structure_type = 'ORG_UNIT')
               );
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OON_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_OR_UNIT;



  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_structure_id IN VARCHAR2 DEFAULT NULL,
    x_org_structure_type IN VARCHAR2 DEFAULT NULL,
    x_org_note_sequence IN NUMBER DEFAULT NULL,
    x_org_note_type IN VARCHAR2 DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_note_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :rareddy
  Date Created By :
  Purpose : before any DML.,
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
      x_org_note_sequence,
      x_org_note_type,
      x_start_date,
      x_end_date,
      x_note_text,
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
    		new_references.org_structure_type,
    		new_references.org_note_sequence,
    		new_references.org_note_type,
    		new_references.org_structure_id)  THEN
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
    		new_references.org_structure_type,
    		new_references.org_note_sequence,
    		new_references.org_note_type,
    		new_references.org_structure_id)  THEN
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
  Created By :rareddy
  Date Created By :
  Purpose : after any DML.,
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
       x_ORG_NOTE_SEQUENCE IN OUT NOCOPY NUMBER,
       x_ORG_NOTE_TYPE IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_NOTE_TEXT IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :rareddy
  Date Created By :
  Purpose : BEFORE AND  AFTER  any INSERT
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_OR_ORG_NOTES
             where                 ORG_STRUCTURE_TYPE= X_ORG_STRUCTURE_TYPE
            and ORG_NOTE_SEQUENCE = X_ORG_NOTE_SEQUENCE
            and ORG_NOTE_TYPE = X_ORG_NOTE_TYPE
            and ORG_STRUCTURE_ID = X_ORG_STRUCTURE_ID
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
   SELECT
        IGS_OR_ORG_NOTE_SEQUENCE_S.NEXTVAL
   INTO
        x_org_note_sequence
   FROM
        dual;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_org_structure_id=>X_ORG_STRUCTURE_ID,
 	       x_org_structure_type=>X_ORG_STRUCTURE_TYPE,
 	       x_org_note_sequence=>X_ORG_NOTE_SEQUENCE,
 	       x_org_note_type=>X_ORG_NOTE_TYPE,
 	       x_start_date=>X_START_DATE,
 	       x_end_date=>X_END_DATE,
 	       x_note_text=>X_NOTE_TEXT,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_OR_ORG_NOTES (
		ORG_STRUCTURE_ID
		,ORG_STRUCTURE_TYPE
		,ORG_NOTE_SEQUENCE
		,ORG_NOTE_TYPE
		,START_DATE
		,END_DATE
		,NOTE_TEXT
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.ORG_STRUCTURE_ID
	        ,NEW_REFERENCES.ORG_STRUCTURE_TYPE
	        ,NEW_REFERENCES.ORG_NOTE_SEQUENCE
	        ,NEW_REFERENCES.ORG_NOTE_TYPE
	        ,NEW_REFERENCES.START_DATE
	        ,NEW_REFERENCES.END_DATE
	        ,NEW_REFERENCES.NOTE_TEXT
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
       x_ORG_NOTE_SEQUENCE IN NUMBER,
       x_ORG_NOTE_TYPE IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_NOTE_TEXT IN VARCHAR2  ) AS
  /*************************************************************
  Created By :rareddy
  Date Created By :
  Purpose : before and after  a lock is made
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      START_DATE
,      END_DATE
,      NOTE_TEXT
    from IGS_OR_ORG_NOTES
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
if ( (  tlinfo.START_DATE = X_START_DATE)
  AND ((tlinfo.END_DATE = X_END_DATE)
 	    OR ((tlinfo.END_DATE is null)
		AND (X_END_DATE is null)))
  AND ((tlinfo.NOTE_TEXT = X_NOTE_TEXT)
 	    OR ((tlinfo.NOTE_TEXT is null)
		AND (X_NOTE_TEXT is null)))
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
       x_ORG_NOTE_SEQUENCE IN NUMBER,
       x_ORG_NOTE_TYPE IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_NOTE_TEXT IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :rareddy
  Date Created By :
  Purpose :before and after a row update
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
 	       x_org_note_sequence=>X_ORG_NOTE_SEQUENCE,
 	       x_org_note_type=>X_ORG_NOTE_TYPE,
 	       x_start_date=>X_START_DATE,
 	       x_end_date=>X_END_DATE,
 	       x_note_text=>X_NOTE_TEXT,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_OR_ORG_NOTES set
      START_DATE =  NEW_REFERENCES.START_DATE,
      END_DATE =  NEW_REFERENCES.END_DATE,
      NOTE_TEXT =  NEW_REFERENCES.NOTE_TEXT,
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
       x_ORG_NOTE_SEQUENCE IN NUMBER,
       x_ORG_NOTE_TYPE IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_NOTE_TEXT IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :rareddy
  Date Created By :
  Purpose :before and after row addition
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_OR_ORG_NOTES
             where     ORG_STRUCTURE_TYPE= X_ORG_STRUCTURE_TYPE
            and ORG_NOTE_SEQUENCE = X_ORG_NOTE_SEQUENCE
            and ORG_NOTE_TYPE = X_ORG_NOTE_TYPE
            and ORG_STRUCTURE_ID = X_ORG_STRUCTURE_ID
;
     XX_ORG_NOTE_SEQUENCE   NUMBER := X_ORG_NOTE_SEQUENCE;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_ORG_STRUCTURE_ID,
       X_ORG_STRUCTURE_TYPE,
       XX_ORG_NOTE_SEQUENCE,
       X_ORG_NOTE_TYPE,
       X_START_DATE,
       X_END_DATE,
       X_NOTE_TEXT,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_ORG_STRUCTURE_ID,
       X_ORG_STRUCTURE_TYPE,
       X_ORG_NOTE_SEQUENCE,
       X_ORG_NOTE_TYPE,
       X_START_DATE,
       X_END_DATE,
       X_NOTE_TEXT,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By :rareddy
  Date Created By :
  Purpose : before and after a delete
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
 delete from IGS_OR_ORG_NOTES
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_or_org_notes_pkg;

/
