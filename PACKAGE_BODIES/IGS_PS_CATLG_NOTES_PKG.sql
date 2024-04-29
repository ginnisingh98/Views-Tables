--------------------------------------------------------
--  DDL for Package Body IGS_PS_CATLG_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_CATLG_NOTES_PKG" AS
/* $Header: IGSPI0QB.pls 115.11 2002/11/29 01:59:33 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_catlg_notes_ALL%RowType;
  new_references igs_ps_catlg_notes_ALL%RowType;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_catalog_note_id IN NUMBER DEFAULT NULL,
    x_catalog_version_id IN NUMBER DEFAULT NULL,
    x_note_type_id IN NUMBER DEFAULT NULL,
    x_create_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_sequence IN NUMBER DEFAULT NULL,
    x_note_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID IN NUMBER DEFAULT NULL
  ) AS

/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_CATLG_NOTES_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.catalog_note_id := x_catalog_note_id;
    new_references.catalog_version_id := x_catalog_version_id;
    new_references.note_type_id := x_note_type_id;
    new_references.create_date := x_create_date;
    new_references.end_date := x_end_date;
    new_references.sequence := x_sequence;
    new_references.note_text := x_note_text;
    new_references.org_id:=x_org_id;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by    := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by    := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by  := x_last_updated_by;
    new_references.last_update_login:= x_last_update_login;

  END set_column_values;

  PROCEDURE check_constraints (
                 column_name IN VARCHAR2  DEFAULT NULL,
		 column_value IN VARCHAR2  DEFAULT NULL ) AS

/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
| vvutukur      12-MAR-2002     Modified 1st two IF conditions in FOR loop to
|                               fix bug:2070575 to check create and end dates
|                               properly according to business rules without
|                               overlapping.
|(reverse chronological order - newest change first)
*=======================================================================*/

	CURSOR c_date is
          SELECT create_date,end_date
	  FROM igs_ps_catlg_notes_all
	  WHERE catalog_version_id = new_references.catalog_version_id and
	        note_type_id = new_references.note_type_id and
		(
		  (l_rowid is not null AND
		   rowid <>  l_rowid)
                   OR
		  (l_rowid is null)
		)
        ORDER BY create_date;

  BEGIN

	IF  new_references.create_date IS NOT NULL AND new_references.end_date IS NOT NULL THEN
	    IF new_references.create_date> new_references.end_date THEN
	       FND_MESSAGE.SET_NAME('IGS','IGS_PS_CD_GT_ED');
	       IGS_GE_MSG_STACK.ADD;
               APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
        END IF;

        FOR lv_date_rec in c_date LOOP
          IF new_references.end_date IS NULL THEN          --main
            IF lv_date_rec.end_date IS NULL THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_PS_ED_VAL');
              IGS_GE_MSG_STACK.ADD;
              APP_EXCEPTION.RAISE_EXCEPTION;
            ELSIF new_references.create_date < lv_date_rec.end_date THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_PS_CREATE_DT');
              IGS_GE_MSG_STACK.ADD;
              APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
	  ELSE
	    IF lv_date_rec.end_date IS NULL THEN   --inner
              IF new_references.end_date >= lv_date_rec.create_date THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_PS_ED_VAL');
                IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
	      END IF;
	    ELSE
	      IF (new_references.create_date < lv_date_rec.create_date AND
	          new_references.end_date  > lv_date_rec.end_date) THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_PS_DT_RANGE');
	        IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
              END IF;
              IF((new_references.create_date BETWEEN lv_date_rec.create_date AND lv_date_rec.end_date) OR
                 (new_references.end_date BETWEEN lv_date_rec.create_date AND lv_date_rec.end_date)) THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_PS_DT_RANGE');
                   IGS_GE_MSG_STACK.ADD;
                   APP_EXCEPTION.RAISE_EXCEPTION;
              END IF;
	    END IF;  --inner
	  END IF;  --main
        END LOOP;

  END check_constraints;

 PROCEDURE check_uniqueness AS

/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/

   begin
     		IF get_uk_for_validation (
    		new_references.catalog_version_id
    		,new_references.note_type_id
    		,new_references.sequence
    		) THEN
 	          Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                  IGS_GE_MSG_STACK.ADD;
		  APP_EXCEPTION.RAISE_EXCEPTION;
    		END IF;
 END check_uniqueness ;

  PROCEDURE check_parent_existance AS

/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/


  BEGIN

    IF (((old_references.catalog_version_id = new_references.catalog_version_id)) OR
        ((new_references.catalog_version_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Catlg_Vers_Pkg.Get_PK_For_Validation (
        		new_references.catalog_version_id
        )  THEN
	 FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF (((old_references.note_type_id = new_references.note_type_id)) OR
        ((new_references.note_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_note_types_pkg.get_pk_for_validation (
        		new_references.note_type_id
        )  THEN
          FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  END check_parent_existance;

  FUNCTION Get_PK_For_Validation (
    x_catalog_note_id IN NUMBER
    ) RETURN BOOLEAN AS
/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/


    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_catlg_notes_ALL
      WHERE    catalog_note_id = x_catalog_note_id
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

  FUNCTION Get_UK_For_Validation (
    x_catalog_version_id IN NUMBER,
    x_note_type_id IN NUMBER,
    x_sequence IN NUMBER
    ) RETURN BOOLEAN AS

  /*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/


    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_catlg_notes_ALL
      WHERE    catalog_version_id = x_catalog_version_id
      AND      note_type_id = x_note_type_id
      AND      sequence = x_sequence 	and      ((l_rowid is null) or (rowid <> l_rowid))

      ;
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

  PROCEDURE Get_FK_Igs_Ps_Catlg_Vers (
    x_catalog_version_id IN NUMBER
    ) AS
/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_catlg_notes_ALL
      WHERE    catalog_version_id = x_catalog_version_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CNDV_CATV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ps_Catlg_Vers;

  PROCEDURE Get_FK_Igs_Ps_Note_Types (
    x_note_type_id IN NUMBER
    ) AS

/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_catlg_notes_ALL
      WHERE    note_type_id = x_note_type_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CNDV_NTPV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ps_Note_Types;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_catalog_note_id IN NUMBER DEFAULT NULL,
    x_catalog_version_id IN NUMBER DEFAULT NULL,
    x_note_type_id IN NUMBER DEFAULT NULL,
    x_create_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_sequence IN NUMBER DEFAULT NULL,
    x_note_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID IN NUMBER DEFAULT NULL
  ) AS

/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_catalog_note_id,
      x_catalog_version_id,
      x_note_type_id,
      x_create_date,
      x_end_date,
      x_sequence,
      x_note_text,
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
    		new_references.catalog_note_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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
    		new_references.catalog_note_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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

/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/

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
   l_rowid := null;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_CATALOG_NOTE_ID IN OUT NOCOPY NUMBER,
       x_CATALOG_VERSION_ID IN NUMBER,
       x_NOTE_TYPE_ID IN NUMBER,
       x_CREATE_DATE IN DATE,
       x_END_DATE IN DATE,
       x_SEQUENCE IN NUMBER,
       x_NOTE_TEXT IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R',
      X_ORG_ID IN NUMBER
  ) AS

/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/

    cursor C is select ROWID from IGS_PS_CATLG_NOTES_ALL
             where                 CATALOG_NOTE_ID= X_CATALOG_NOTE_ID
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
       SELECT IGS_PS_CATLG_NOTES_S.nextval INTO x_CATALOG_NOTE_ID FROM DUAL;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_catalog_note_id=>X_CATALOG_NOTE_ID,
 	       x_catalog_version_id=>X_CATALOG_VERSION_ID,
 	       x_note_type_id=>X_NOTE_TYPE_ID,
 	       x_create_date=>X_CREATE_DATE,
 	       x_end_date=>X_END_DATE,
 	       x_sequence=>X_SEQUENCE,
 	       x_note_text=>X_NOTE_TEXT,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_org_id=>igs_ge_gen_003.get_org_id);
     insert into IGS_PS_CATLG_NOTES_ALL (
		CATALOG_NOTE_ID
		,CATALOG_VERSION_ID
		,NOTE_TYPE_ID
		,CREATE_DATE
		,END_DATE
		,SEQUENCE
		,NOTE_TEXT
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,ORG_ID
        ) values  (
	        NEW_REFERENCES.CATALOG_NOTE_ID
	        ,NEW_REFERENCES.CATALOG_VERSION_ID
	        ,NEW_REFERENCES.NOTE_TYPE_ID
	        ,NEW_REFERENCES.CREATE_DATE
	        ,NEW_REFERENCES.END_DATE
	        ,NEW_REFERENCES.SEQUENCE
	        ,NEW_REFERENCES.NOTE_TEXT
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,NEW_REFERENCES.ORG_ID
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
       x_CATALOG_NOTE_ID IN NUMBER,
       x_CATALOG_VERSION_ID IN NUMBER,
       x_NOTE_TYPE_ID IN NUMBER,
       x_CREATE_DATE IN DATE,
       x_END_DATE IN DATE,
       x_SEQUENCE IN NUMBER,
       x_NOTE_TEXT IN VARCHAR2
       ) AS

/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/

   cursor c1 is select
      CATALOG_VERSION_ID
,      NOTE_TYPE_ID
,      CREATE_DATE
,      END_DATE
,      SEQUENCE
,      NOTE_TEXT

    from IGS_PS_CATLG_NOTES_ALL
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
if ( (  tlinfo.CATALOG_VERSION_ID = X_CATALOG_VERSION_ID)
  AND (tlinfo.NOTE_TYPE_ID = X_NOTE_TYPE_ID)
  AND (tlinfo.CREATE_DATE = X_CREATE_DATE)
  AND ((tlinfo.END_DATE = X_END_DATE)
 	    OR ((tlinfo.END_DATE is null)
		AND (X_END_DATE is null)))
  AND ((tlinfo.SEQUENCE = X_SEQUENCE)
 	    OR ((tlinfo.SEQUENCE is null)
		AND (X_SEQUENCE is null)))
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
       x_CATALOG_NOTE_ID IN NUMBER,
       x_CATALOG_VERSION_ID IN NUMBER,
       x_NOTE_TYPE_ID IN NUMBER,
       x_CREATE_DATE IN DATE,
       x_END_DATE IN DATE,
       x_SEQUENCE IN NUMBER,
       x_NOTE_TEXT IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
    ) AS

/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/

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
 	       x_catalog_note_id=>X_CATALOG_NOTE_ID,
 	       x_catalog_version_id=>X_CATALOG_VERSION_ID,
 	       x_note_type_id=>X_NOTE_TYPE_ID,
 	       x_create_date=>X_CREATE_DATE,
 	       x_end_date=>X_END_DATE,
 	       x_sequence=>X_SEQUENCE,
 	       x_note_text=>X_NOTE_TEXT,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN
);
   update IGS_PS_CATLG_NOTES_ALL set
      CATALOG_VERSION_ID =  NEW_REFERENCES.CATALOG_VERSION_ID,
      NOTE_TYPE_ID =  NEW_REFERENCES.NOTE_TYPE_ID,
      CREATE_DATE =  NEW_REFERENCES.CREATE_DATE,
      END_DATE =  NEW_REFERENCES.END_DATE,
      SEQUENCE =  NEW_REFERENCES.SEQUENCE,
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
       x_CATALOG_NOTE_ID IN OUT NOCOPY NUMBER,
       x_CATALOG_VERSION_ID IN NUMBER,
       x_NOTE_TYPE_ID IN NUMBER,
       x_CREATE_DATE IN DATE,
       x_END_DATE IN DATE,
       x_SEQUENCE IN NUMBER,
       x_NOTE_TEXT IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R',
      X_ORG_ID IN NUMBER

  ) AS

/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/

    cursor c1 is select ROWID from IGS_PS_CATLG_NOTES_ALL
             where     CATALOG_NOTE_ID= X_CATALOG_NOTE_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_CATALOG_NOTE_ID,
       X_CATALOG_VERSION_ID,
       X_NOTE_TYPE_ID,
       X_CREATE_DATE,
       X_END_DATE,
       X_SEQUENCE,
       X_NOTE_TEXT,
      X_MODE,
      X_ORG_ID
);
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_CATALOG_NOTE_ID,
       X_CATALOG_VERSION_ID,
       X_NOTE_TYPE_ID,
       X_CREATE_DATE,
       X_END_DATE,
       X_SEQUENCE,
       X_NOTE_TEXT,
      X_MODE
);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS

/*=======================================================================+
|
| Created By : ssuri
|
| Date Created By : 10-MAY-2000
|
| Purpose : NEW TABLE
|
| Know limitations, enhancements or remarks
|
| Change History
|
| Who		When 		What
|
|
|(reverse chronological order - newest change first)
*=======================================================================*/

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
 delete from IGS_PS_CATLG_NOTES_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ps_catlg_notes_pkg;

/
