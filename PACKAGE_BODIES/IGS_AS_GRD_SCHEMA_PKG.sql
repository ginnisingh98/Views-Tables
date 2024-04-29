--------------------------------------------------------
--  DDL for Package Body IGS_AS_GRD_SCHEMA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GRD_SCHEMA_PKG" AS
 /* $Header: IGSDI23B.pls 115.13 2003/10/09 09:44:18 anilk ship $ */
l_rowid VARCHAR2(25);
  old_references IGS_AS_GRD_SCHEMA%ROWTYPE;
  new_references IGS_AS_GRD_SCHEMA%ROWTYPE;

PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_grading_schema_type IN VARCHAR2 DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_GRD_SCHEMA
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action  NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	   CLOSE cur_old_ref_values;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.version_number := x_version_number;
    new_references.description := x_description;
    new_references.start_dt := x_start_dt;
    new_references.end_dt := x_end_dt;
    new_references.comments := x_comments;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    new_references.grading_schema_type := x_grading_schema_type;

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

 PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Validate that inserts/updates are allowed
	IF  p_inserting OR p_updating THEN
	    -- Validate if grading schema start dt > end dt
	    IF p_inserting OR p_updating THEN
		    IF	igs_ad_val_edtl.genp_val_strt_end_dt(new_references.start_dt,
							 new_references.end_dt,
							 v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		    END IF;
	    END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_gs_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_GRD_SCHEMA
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
    v_message_name	VARCHAR2(30);

  BEGIN
	IF  p_inserting OR p_updating THEN
         IF  IGS_AS_VAL_GS.assp_val_gs_ovrlp (
  					new_references.grading_schema_cd,
  					new_references.version_number,
  					new_references.start_dt,
  					new_references.end_dt,
  					v_message_name) = FALSE THEN
            FND_MESSAGE.SET_NAME('IGS',v_message_name);
            IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
  		END IF;


	END IF;


  END AfterRowInsertUpdate2;


-- Added by DDEY for the checking the Foreign Key Relation
-- of with the table IGS_LOOKUPS_VIEW

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_grading_schema_type IN VARCHAR2
                      )  IS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_AS_GRD_SCHEMA
      WHERE    grading_schema_type = x_grading_schema_type ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_GS_LOV_FK');
      IGS_GE_MSG_STACK.ADD;
      CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_LOOKUPS_VIEW;


  -- Trigger description :-
  -- "OSS_TST".trg_gs_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_GRD_SCHEMA


  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PS_OFR_PAT_PKG.GET_FK_IGS_AS_GRD_SCHEMA (
      old_references.grading_schema_cd,
      old_references.version_number
      );

    IGS_AS_GRD_SCH_GRADE_PKG.GET_FK_IGS_AS_GRD_SCHEMA (
      old_references.grading_schema_cd,
      old_references.version_number
      );

    IGS_EN_SU_ATTEMPT_PKG.GET_FK_IGS_AS_GRD_SCH_GRADE (
      old_references.grading_schema_cd,
      old_references.version_number
      );

    IGS_PS_UNIT_OFR_OPT_PKG.GET_FK_IGS_AS_GRD_SCHEMA (
      old_references.grading_schema_cd,
      old_references.version_number
      );

  ---Added on 13th may b'cos of the new relation with new table.,

   IGS_PS_UNIT_GRD_SCHM_PKG.GET_FK_IGS_AS_GRD_SCHEMA (
     old_references.grading_schema_cd,

     old_references.version_number);
---Added on 18th may

IGS_PS_USEC_GRD_SCHM_PKG.GET_FK_IGS_AS_GRD_SCHEMA (
                    old_references.GRADING_SCHEMA_CD ,
                    old_references.VERSION_NUMBER
                );

-- Added by DDEY as a part of Enhancement Bug # 2162831

IGS_AS_UNITASS_ITEM_PKG.GET_FK_IGS_AS_GRD_SCHEMA (
    old_references.grading_schema_cd ,
    old_references.version_number
    );

-- Added by DDEY as a part of Enhancement Bug # 2162831

IGS_PS_UNITASS_ITEM_PKG.GET_FK_IGS_AS_GRD_SCHEMA (
    old_references.grading_schema_cd ,
    old_references.version_number
    );

 -- Added by aiyer for the build of PSCR015 Tertiary And Secondary Bug No #2216952

 IGS_PS_AWD_PKG.GET_FK_IGS_AS_GRD_SCHEMA (
    old_references.grading_schema_cd   ,
    old_references.version_number
    );

 -- Added by ijeddy for the build of Program Completion Validation, Bug no 3129913
 IGS_EN_SPA_AWD_AIM_PKG.GET_FK_IGS_AS_GRADING_SCH (
    old_references.grading_schema_cd   ,
    old_references.version_number
    );

 -- Added by anilk for the build of Program Completion Validation , Bug# 3129913
 IGS_EN_SPAA_HIST_PKG.GET_FK_IGS_AS_GRD_SCHEMA (
    old_references.grading_schema_cd   ,
    old_references.version_number
    );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_AS_GRD_SCHEMA
      WHERE    grading_schema_cd = x_grading_schema_cd
      AND      version_number = x_version_number
      ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    	IF (cur_rowid%FOUND) THEN
	      CLOSE cur_rowid;
	      RETURN (TRUE);
	ELSE
	      CLOSE cur_rowid;
	      RETURN (FALSE);
	END IF;
  END Get_PK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_grading_schema_type IN VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_grading_schema_cd,
      x_version_number,
      x_description,
      x_start_dt,
      x_end_dt,
      x_comments,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_grading_schema_type
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      	IF  Get_PK_For_Validation (
	         new_references.grading_schema_cd ,
    new_references.version_number) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;

	     Check_Constraints;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.

	   check_child_existance ;

	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	     IF  Get_PK_For_Validation (
	         new_references.grading_schema_cd ,
    new_references.version_number) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
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
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE );

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE );

    END IF;

  END After_DML;

PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_GRADING_SCHEMA_CD IN VARCHAR2,
  X_VERSION_NUMBER IN NUMBER,
  X_DESCRIPTION IN VARCHAR2,
  X_START_DT IN DATE,
  X_END_DT IN DATE,
  X_COMMENTS IN VARCHAR2,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       X_MODE IN VARCHAR2 DEFAULT 'R',
       x_grading_schema_type IN VARCHAR2

  ) AS
    CURSOR C IS SELECT ROWID FROM IGS_AS_GRD_SCHEMA
      WHERE GRADING_SCHEMA_CD = X_GRADING_SCHEMA_CD
      AND VERSION_NUMBER = X_VERSION_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
BEGIN
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE = 'R') THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF X_LAST_UPDATED_BY IS NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    IF X_LAST_UPDATE_LOGIN IS NULL THEN
      X_LAST_UPDATE_LOGIN := -1;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_comments=>X_COMMENTS,
 x_description=>X_DESCRIPTION,
 x_end_dt=>X_END_DT,
 x_grading_schema_cd=>X_GRADING_SCHEMA_CD,
 x_start_dt=>X_START_DT,
 x_version_number=>X_VERSION_NUMBER,
x_attribute_category=>X_ATTRIBUTE_CATEGORY,
x_attribute1=>X_ATTRIBUTE1,
x_attribute2=>X_ATTRIBUTE2,
x_attribute3=>X_ATTRIBUTE3,
x_attribute4=>X_ATTRIBUTE4,
x_attribute5=>X_ATTRIBUTE5,
x_attribute6=>X_ATTRIBUTE6,
x_attribute7=>X_ATTRIBUTE7,
x_attribute8=>X_ATTRIBUTE8,
x_attribute9=>X_ATTRIBUTE9,
x_attribute10=>X_ATTRIBUTE10,
x_attribute11=>X_ATTRIBUTE11,
x_attribute12=>X_ATTRIBUTE12,
x_attribute13=>X_ATTRIBUTE13,
x_attribute14=>X_ATTRIBUTE14,
x_attribute15=>X_ATTRIBUTE15,
x_attribute16=>X_ATTRIBUTE16,
x_attribute17=>X_ATTRIBUTE17,
x_attribute18=>X_ATTRIBUTE18,
x_attribute19=>X_ATTRIBUTE19,
x_attribute20=>X_ATTRIBUTE20,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_grading_schema_type => x_grading_schema_type
 );
  INSERT INTO IGS_AS_GRD_SCHEMA (
    GRADING_SCHEMA_CD,
    VERSION_NUMBER,
    DESCRIPTION,
    START_DT,
    END_DT,
    COMMENTS,
ATTRIBUTE_CATEGORY
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,ATTRIBUTE16
,ATTRIBUTE17
,ATTRIBUTE18
,ATTRIBUTE19
,ATTRIBUTE20,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    grading_schema_type
  ) VALUES (
    NEW_REFERENCES.GRADING_SCHEMA_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.COMMENTS
,NEW_REFERENCES.ATTRIBUTE_CATEGORY
,NEW_REFERENCES.ATTRIBUTE1
,NEW_REFERENCES.ATTRIBUTE2
,NEW_REFERENCES.ATTRIBUTE3
,NEW_REFERENCES.ATTRIBUTE4
,NEW_REFERENCES.ATTRIBUTE5
,NEW_REFERENCES.ATTRIBUTE6
,NEW_REFERENCES.ATTRIBUTE7
,NEW_REFERENCES.ATTRIBUTE8
,NEW_REFERENCES.ATTRIBUTE9
,NEW_REFERENCES.ATTRIBUTE10
,NEW_REFERENCES.ATTRIBUTE11
,NEW_REFERENCES.ATTRIBUTE12
,NEW_REFERENCES.ATTRIBUTE13
,NEW_REFERENCES.ATTRIBUTE14
,NEW_REFERENCES.ATTRIBUTE15
,NEW_REFERENCES.ATTRIBUTE16
,NEW_REFERENCES.ATTRIBUTE17
,NEW_REFERENCES.ATTRIBUTE18
,NEW_REFERENCES.ATTRIBUTE19
,NEW_REFERENCES.ATTRIBUTE20,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.grading_schema_type
  );

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;
After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
END INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_ROWID IN  VARCHAR2,
  X_GRADING_SCHEMA_CD IN VARCHAR2,
  X_VERSION_NUMBER IN NUMBER,
  X_DESCRIPTION IN VARCHAR2,
  X_START_DT IN DATE,
  X_END_DT IN DATE,
  X_COMMENTS IN VARCHAR2,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       x_grading_schema_type IN VARCHAR2
) AS
  CURSOR c1 IS SELECT
      DESCRIPTION,
      START_DT,
      END_DT,
      COMMENTS
,      ATTRIBUTE_CATEGORY
,      ATTRIBUTE1
,      ATTRIBUTE2
,      ATTRIBUTE3
,      ATTRIBUTE4
,      ATTRIBUTE5
,      ATTRIBUTE6
,      ATTRIBUTE7
,      ATTRIBUTE8
,      ATTRIBUTE9
,      ATTRIBUTE10
,      ATTRIBUTE11
,      ATTRIBUTE12
,      ATTRIBUTE13
,      ATTRIBUTE14
,      ATTRIBUTE15
,      ATTRIBUTE16
,      ATTRIBUTE17
,      ATTRIBUTE18
,      ATTRIBUTE19
,      ATTRIBUTE20
,      grading_schema_type
    FROM IGS_AS_GRD_SCHEMA
    WHERE ROWID = X_ROWID  FOR UPDATE  NOWAIT;
  tlinfo c1%ROWTYPE;

BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    CLOSE c1;
    RETURN;
  END IF;
  CLOSE c1;

  IF ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.START_DT = X_START_DT)
      AND ((tlinfo.END_DT = X_END_DT)
           OR ((tlinfo.END_DT IS NULL)
               AND (X_END_DT IS NULL)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS IS NULL)
               AND (X_COMMENTS IS NULL)))
  AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
 	    OR ((tlinfo.ATTRIBUTE_CATEGORY IS NULL)
		AND (X_ATTRIBUTE_CATEGORY IS NULL)))
  AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
 	    OR ((tlinfo.ATTRIBUTE1 IS NULL)
		AND (X_ATTRIBUTE1 IS NULL)))
  AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
 	    OR ((tlinfo.ATTRIBUTE2 IS NULL)
		AND (X_ATTRIBUTE2 IS NULL)))
  AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
 	    OR ((tlinfo.ATTRIBUTE3 IS NULL)
		AND (X_ATTRIBUTE3 IS NULL)))
  AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
 	    OR ((tlinfo.ATTRIBUTE4 IS NULL)
		AND (X_ATTRIBUTE4 IS NULL)))
  AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
 	    OR ((tlinfo.ATTRIBUTE5 IS NULL)
		AND (X_ATTRIBUTE5 IS NULL)))
  AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
 	    OR ((tlinfo.ATTRIBUTE6 IS NULL)
		AND (X_ATTRIBUTE6 IS NULL)))
  AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
 	    OR ((tlinfo.ATTRIBUTE7 IS NULL)
		AND (X_ATTRIBUTE7 IS NULL)))
  AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
 	    OR ((tlinfo.ATTRIBUTE8 IS NULL)
		AND (X_ATTRIBUTE8 IS NULL)))
  AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
 	    OR ((tlinfo.ATTRIBUTE9 IS NULL)
		AND (X_ATTRIBUTE9 IS NULL)))
  AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
 	    OR ((tlinfo.ATTRIBUTE10 IS NULL)
		AND (X_ATTRIBUTE10 IS NULL)))
  AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
 	    OR ((tlinfo.ATTRIBUTE11 IS NULL)
		AND (X_ATTRIBUTE11 IS NULL)))
  AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
 	    OR ((tlinfo.ATTRIBUTE12 IS NULL)
		AND (X_ATTRIBUTE12 IS NULL)))
  AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
 	    OR ((tlinfo.ATTRIBUTE13 IS NULL)
		AND (X_ATTRIBUTE13 IS NULL)))
  AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
 	    OR ((tlinfo.ATTRIBUTE14 IS NULL)
		AND (X_ATTRIBUTE14 IS NULL)))
  AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
 	    OR ((tlinfo.ATTRIBUTE15 IS NULL)
		AND (X_ATTRIBUTE15 IS NULL)))
  AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
 	    OR ((tlinfo.ATTRIBUTE16 IS NULL)
		AND (X_ATTRIBUTE16 IS NULL)))
  AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
 	    OR ((tlinfo.ATTRIBUTE17 IS NULL)
		AND (X_ATTRIBUTE17 IS NULL)))
  AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
 	    OR ((tlinfo.ATTRIBUTE18 IS NULL)
		AND (X_ATTRIBUTE18 IS NULL)))
  AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
 	    OR ((tlinfo.ATTRIBUTE19 IS NULL)
		AND (X_ATTRIBUTE19 IS NULL)))
  AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
 	    OR ((tlinfo.ATTRIBUTE20 IS NULL)
		AND (X_ATTRIBUTE20 IS NULL)))
 AND ((tlinfo.grading_schema_type = X_grading_schema_type)
 	    OR ((tlinfo.grading_schema_type IS NULL)
		AND (x_grading_schema_type IS NULL)))

  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  X_ROWID IN  VARCHAR2,
  X_GRADING_SCHEMA_CD IN VARCHAR2,
  X_VERSION_NUMBER IN NUMBER,
  X_DESCRIPTION IN VARCHAR2,
  X_START_DT IN DATE,
  X_END_DT IN DATE,
  X_COMMENTS IN VARCHAR2,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       X_MODE IN VARCHAR2 DEFAULT 'R',
       x_grading_schema_type IN VARCHAR2

  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
BEGIN
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE = 'R') THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF X_LAST_UPDATED_BY IS NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    IF X_LAST_UPDATE_LOGIN IS NULL THEN
      X_LAST_UPDATE_LOGIN := -1;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_comments=>X_COMMENTS,
 x_description=>X_DESCRIPTION,
 x_end_dt=>X_END_DT,
 x_grading_schema_cd=>X_GRADING_SCHEMA_CD,
 x_start_dt=>X_START_DT,
 x_version_number=>X_VERSION_NUMBER,
x_attribute_category=>X_ATTRIBUTE_CATEGORY,
x_attribute1=>X_ATTRIBUTE1,
x_attribute2=>X_ATTRIBUTE2,
x_attribute3=>X_ATTRIBUTE3,
x_attribute4=>X_ATTRIBUTE4,
x_attribute5=>X_ATTRIBUTE5,
x_attribute6=>X_ATTRIBUTE6,
x_attribute7=>X_ATTRIBUTE7,
x_attribute8=>X_ATTRIBUTE8,
x_attribute9=>X_ATTRIBUTE9,
x_attribute10=>X_ATTRIBUTE10,
x_attribute11=>X_ATTRIBUTE11,
x_attribute12=>X_ATTRIBUTE12,
x_attribute13=>X_ATTRIBUTE13,
x_attribute14=>X_ATTRIBUTE14,
x_attribute15=>X_ATTRIBUTE15,
x_attribute16=>X_ATTRIBUTE16,
x_attribute17=>X_ATTRIBUTE17,
x_attribute18=>X_ATTRIBUTE18,
x_attribute19=>X_ATTRIBUTE19,
x_attribute20=>X_ATTRIBUTE20,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_grading_schema_type =>x_grading_schema_type
 );
  UPDATE IGS_AS_GRD_SCHEMA SET
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    START_DT = NEW_REFERENCES.START_DT,
    END_DT = NEW_REFERENCES.END_DT,
    COMMENTS = NEW_REFERENCES.COMMENTS,
      ATTRIBUTE_CATEGORY =  NEW_REFERENCES.ATTRIBUTE_CATEGORY,
      ATTRIBUTE1 =  NEW_REFERENCES.ATTRIBUTE1,
      ATTRIBUTE2 =  NEW_REFERENCES.ATTRIBUTE2,
      ATTRIBUTE3 =  NEW_REFERENCES.ATTRIBUTE3,
      ATTRIBUTE4 =  NEW_REFERENCES.ATTRIBUTE4,
      ATTRIBUTE5 =  NEW_REFERENCES.ATTRIBUTE5,
      ATTRIBUTE6 =  NEW_REFERENCES.ATTRIBUTE6,
      ATTRIBUTE7 =  NEW_REFERENCES.ATTRIBUTE7,
      ATTRIBUTE8 =  NEW_REFERENCES.ATTRIBUTE8,
      ATTRIBUTE9 =  NEW_REFERENCES.ATTRIBUTE9,
      ATTRIBUTE10 =  NEW_REFERENCES.ATTRIBUTE10,
      ATTRIBUTE11 =  NEW_REFERENCES.ATTRIBUTE11,
      ATTRIBUTE12 =  NEW_REFERENCES.ATTRIBUTE12,
      ATTRIBUTE13 =  NEW_REFERENCES.ATTRIBUTE13,
      ATTRIBUTE14 =  NEW_REFERENCES.ATTRIBUTE14,
      ATTRIBUTE15 =  NEW_REFERENCES.ATTRIBUTE15,
      ATTRIBUTE16 =  NEW_REFERENCES.ATTRIBUTE16,
      ATTRIBUTE17 =  NEW_REFERENCES.ATTRIBUTE17,
      ATTRIBUTE18 =  NEW_REFERENCES.ATTRIBUTE18,
      ATTRIBUTE19 =  NEW_REFERENCES.ATTRIBUTE19,
      ATTRIBUTE20 =  NEW_REFERENCES.ATTRIBUTE20,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    grading_schema_type = NEW_REFERENCES.grading_schema_type
  WHERE ROWID = X_ROWID;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );

END UPDATE_ROW;

PROCEDURE ADD_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_GRADING_SCHEMA_CD IN VARCHAR2,
  X_VERSION_NUMBER IN NUMBER,
  X_DESCRIPTION IN VARCHAR2,
  X_START_DT IN DATE,
  X_END_DT IN DATE,
  X_COMMENTS IN VARCHAR2,
x_ATTRIBUTE_CATEGORY IN VARCHAR2,
x_ATTRIBUTE1 IN VARCHAR2,
x_ATTRIBUTE2 IN VARCHAR2,
x_ATTRIBUTE3 IN VARCHAR2,
x_ATTRIBUTE4 IN VARCHAR2,
x_ATTRIBUTE5 IN VARCHAR2,
x_ATTRIBUTE6 IN VARCHAR2,
x_ATTRIBUTE7 IN VARCHAR2,
x_ATTRIBUTE8 IN VARCHAR2,
x_ATTRIBUTE9 IN VARCHAR2,
x_ATTRIBUTE10 IN VARCHAR2,
x_ATTRIBUTE11 IN VARCHAR2,
x_ATTRIBUTE12 IN VARCHAR2,
x_ATTRIBUTE13 IN VARCHAR2,
x_ATTRIBUTE14 IN VARCHAR2,
x_ATTRIBUTE15 IN VARCHAR2,
x_ATTRIBUTE16 IN VARCHAR2,
x_ATTRIBUTE17 IN VARCHAR2,
x_ATTRIBUTE18 IN VARCHAR2,
x_ATTRIBUTE19 IN VARCHAR2,
x_ATTRIBUTE20 IN VARCHAR2,
X_MODE IN VARCHAR2 DEFAULT 'R',
x_grading_schema_type IN VARCHAR2
  ) AS
  CURSOR c1 IS SELECT ROWID FROM IGS_AS_GRD_SCHEMA
     WHERE GRADING_SCHEMA_CD = X_GRADING_SCHEMA_CD
     AND VERSION_NUMBER = X_VERSION_NUMBER;
BEGIN
  OPEN c1;
  FETCH c1 INTO X_ROWID;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    INSERT_ROW (
     X_ROWID,
     X_GRADING_SCHEMA_CD,
     X_VERSION_NUMBER,
     X_DESCRIPTION,
     X_START_DT,
     X_END_DT,
     X_COMMENTS,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_ATTRIBUTE16,
       X_ATTRIBUTE17,
       X_ATTRIBUTE18,
       X_ATTRIBUTE19,
       X_ATTRIBUTE20,
     X_MODE,
     x_grading_schema_type );
    RETURN;
  END IF;
  CLOSE c1;
  UPDATE_ROW (
   X_ROWID,
   X_GRADING_SCHEMA_CD,
   X_VERSION_NUMBER,
   X_DESCRIPTION,
   X_START_DT,
   X_END_DT,
   X_COMMENTS,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_ATTRIBUTE16,
       X_ATTRIBUTE17,
       X_ATTRIBUTE18,
       X_ATTRIBUTE19,
       X_ATTRIBUTE20,
   X_MODE,
   x_grading_schema_type );
END ADD_ROW;


	PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	)
	AS
	BEGIN
	IF  column_name IS NULL THEN
	    NULL;
            ELSIF UPPER(Column_name) = 'GRADING_SCHEMA_CD' THEN
                new_references.GRADING_SCHEMA_CD := column_value;
            ELSIF UPPER(Column_name) = 'VERSION_NUMBER' THEN
                new_references.VERSION_NUMBER := igs_ge_number.to_num(column_value);
	END IF;


IF UPPER(column_name) = 'GRADING_SCHEMA_CD' OR
     column_name IS NULL THEN
     IF new_references.GRADING_SCHEMA_CD <> UPPER(new_references.GRADING_SCHEMA_CD) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF UPPER(column_name) = 'VERSION_NUMBER' OR
     column_name IS NULL THEN
     IF new_references.VERSION_NUMBER <  0 OR new_references.VERSION_NUMBER >  999 THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
END IF;

END Check_Constraints;

END IGS_AS_GRD_SCHEMA_PKG;

/
