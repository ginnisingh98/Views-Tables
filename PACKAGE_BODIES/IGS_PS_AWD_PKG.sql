--------------------------------------------------------
--  DDL for Package Body IGS_PS_AWD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_AWD_PKG" AS
  /* $Header: IGSPI01B.pls 115.9 2003/02/25 08:10:44 sarakshi ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_AWD%ROWTYPE;
  new_references IGS_PS_AWD%ROWTYPE;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_award_title IN VARCHAR2 DEFAULT NULL,
    x_s_award_type IN VARCHAR2 DEFAULT NULL,
    x_testamur_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL ,
    x_gs_version_number IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_AWD
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception; RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.award_cd := x_award_cd;
    new_references.award_title := x_award_title;
    new_references.s_award_type := x_s_award_type;
    new_references.testamur_type := x_testamur_type;
    new_references.closed_ind := x_closed_ind;
    new_references.notes := x_notes;
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

    -- Added by aiyer for the build of PSCR015 Tertiary And Secondary Bug No #2216952
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.gs_version_number := x_gs_version_number;

  END Set_Column_Values;

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate the IGS_PS_AWD is not closed
	IF p_inserting OR p_updating THEN
		IF NVL(new_references.testamur_type, 'NULL') <> NVL(old_references.testamur_type, 'NULL') THEN
			IF new_references.testamur_type IS NOT NULL THEN
				IF IGS_PS_VAL_AW.crsp_val_tt_closed(
						new_references.testamur_type,
						v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS',v_message_name);
					IGS_GE_MSG_STACK.ADD;
					App_Exception.Raise_Exception;
				END IF;
			END IF;
		END IF;
	END IF;
	-- Validate update to IGS_PS_AWD system IGS_PS_AWD type
	IF p_updating THEN
		IF IGS_PS_VAL_AW.crsp_val_aw_upd(
					new_references.award_cd,
					new_references.s_award_type,
					old_references.s_award_type,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;

  END BeforeRowInsertUpdate1;

 PROCEDURE Check_Constraints (
 Column_Name	IN VARCHAR2	DEFAULT NULL,
 Column_Value 	IN VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN

	IF column_name IS NULL THEN
	    NULL;
	ELSIF UPPER(Column_name) = 'CLOSED_IND' THEN
	    new_references.closed_ind := column_value;
	ELSIF UPPER(Column_name) = 'S_AWARD_TYPE' THEN
	    new_references.s_award_type := column_value;
	ELSIF UPPER(Column_name) = 'AWARD_CD' THEN
	    new_references.award_cd := column_value;
	ELSIF UPPER(Column_name) = 'TESTAMUR_TYPE' THEN
	    new_references.testamur_type := column_value;
        ELSIF UPPER(Column_name) = 'GRADING_SCHEMA_CD' THEN
            new_references.GRADING_SCHEMA_CD := column_value;
        ELSIF UPPER(Column_name) = 'GS_VERSION_NUMBER' THEN
            new_references.GS_VERSION_NUMBER := igs_ge_number.to_num(column_value);
       END IF;

    IF UPPER(column_name) = 'CLOSED_IND' OR
    column_name IS NULL THEN
  	IF ( new_references.closed_ind NOT IN ( 'Y' , 'N' ) ) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF  UPPER(column_name) = 'S_AWARD_TYPE' OR
    column_name IS NULL THEN
   IF ( new_references.s_award_type NOT IN ( 'COURSE' , 'HONORARY' , 'MEDAL' , 'PRIZE' ,'ENTRYQUAL') ) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF UPPER(column_name) = 'AWARD_CD' OR
    column_name IS NULL THEN
   IF ( new_references.award_cd <> UPPER(new_references.award_cd) ) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF UPPER(column_name) = 'CLOSED_IND' OR
    column_name IS NULL THEN
   IF ( new_references.closed_ind <> UPPER(new_references.closed_ind) ) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF UPPER(column_name) = 'S_AWARD_TYPE' OR
    column_name IS NULL THEN
   IF ( new_references.s_award_type <> UPPER(new_references.s_award_type) ) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
          END IF;
      END IF;

    IF UPPER(column_name) = 'TESTAMUR_TYPE' OR
    column_name IS NULL THEN
     IF ( new_references.testamur_type <> UPPER(new_references.testamur_type) ) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
    END IF;

  -- Added by aiyer for the build of PSCR015 Tertiary And Secondary Bug No #2216952
   IF UPPER(column_name) = 'GRADING_SCHEMA_CD' OR
     column_name IS NULL THEN
     IF new_references.GRADING_SCHEMA_CD <> UPPER(new_references.GRADING_SCHEMA_CD) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
   END IF;

  -- Added by aiyer for the build of PSCR015 Tertiary And Secondary Bug No #2216952
   IF UPPER(column_name) = 'GS_VERSION_NUMBER' OR
      column_name IS NULL THEN
     IF new_references.GS_VERSION_NUMBER <  0 OR new_references.GS_VERSION_NUMBER >  999 THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
   END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.testamur_type = new_references.testamur_type)) OR
        ((new_references.testamur_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_TESTAMUR_TYPE_PKG.Get_PK_For_Validation (
        new_references.testamur_type ) THEN
	        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
      END IF;
    END IF;

  -- Added by aiyer for the build of PSCR015 Tertiary And Secondary Bug No #2216952

   IF (
        (
         (old_references.grading_schema_cd = new_references.grading_schema_cd)
          AND
         (old_references.gs_version_number = new_references.gs_version_number)
        )
        OR
        (
         (new_references.grading_schema_cd IS NULL)
          AND
         (new_references.gs_version_number IS NULL)
        )
      )
      THEN
      NULL;
    ELSE
      IF NOT IGS_AS_GRD_SCHEMA_PKG.Get_PK_For_Validation (
        new_references.grading_schema_cd,
	new_references.gs_version_number
	) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;


  FUNCTION Get_PK_For_Validation (
    x_award_cd IN VARCHAR2 )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_PS_AWD
      WHERE    award_cd = x_award_cd;

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

  PROCEDURE GET_FK_IGS_GR_TESTAMUR_TYPE (
    x_testamur_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_PS_AWD
      WHERE    testamur_type = x_testamur_type ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_AW_TT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END GET_FK_IGS_GR_TESTAMUR_TYPE;

  -- Added by aiyer for the build of PSCR015 Tertiary And Secondary Bug No #2216952

 PROCEDURE get_fk_igs_as_grd_schema (
    x_grading_schema_cd  IN VARCHAR2 ,
    x_gs_version_number  IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_PS_AWD
      WHERE    grading_schema_cd =  x_grading_schema_cd
               AND
               gs_version_number =  x_gs_version_number;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_AW_GS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_as_grd_schema;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_award_title IN VARCHAR2 DEFAULT NULL,
    x_s_award_type IN VARCHAR2 DEFAULT NULL,
    x_testamur_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL ,
    x_gs_version_number IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_award_cd,
      x_award_title,
      x_s_award_type,
      x_testamur_type,
      x_closed_ind,
      x_notes,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_grading_schema_cd ,
      x_gs_version_number
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
	   new_references.award_cd) THEN
	   Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	   IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF  Get_PK_For_Validation (
            new_references.award_cd ) THEN
	    Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Constraints;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    END After_DML;

PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_AWARD_CD IN VARCHAR2,
  X_AWARD_TITLE IN VARCHAR2,
  X_S_AWARD_TYPE IN VARCHAR2,
  X_TESTAMUR_TYPE IN VARCHAR2,
  X_CLOSED_IND IN VARCHAR2,
  X_NOTES IN VARCHAR2,
  X_MODE IN VARCHAR2 DEFAULT 'R' ,
  X_GRADING_SCHEMA_CD IN VARCHAR2  ,
  X_GS_VERSION_NUMBER IN NUMBER
  ) AS
    CURSOR C IS SELECT ROWID FROM IGS_PS_AWD
      WHERE AWARD_CD = X_AWARD_CD;
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
    app_exception.raise_exception;
  END IF;

Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_award_cd => X_AWARD_CD,
    x_award_title => X_AWARD_TITLE,
    x_s_award_type => X_S_AWARD_TYPE,
    x_testamur_type => X_TESTAMUR_TYPE,
    x_closed_ind => NVL(X_CLOSED_IND,'N'),
    x_notes => X_NOTES,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN  ,
    x_grading_schema_cd => X_GRADING_SCHEMA_CD,
    x_gs_version_number => X_GS_VERSION_NUMBER
 );

  INSERT INTO IGS_PS_AWD (
    AWARD_CD,
    AWARD_TITLE,
    S_AWARD_TYPE,
    TESTAMUR_TYPE,
    CLOSED_IND,
    NOTES,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    GRADING_SCHEMA_CD,
    GS_VERSION_NUMBER
  ) VALUES (
    NEW_REFERENCES.AWARD_CD,
    NEW_REFERENCES.AWARD_TITLE,
    NEW_REFERENCES.S_AWARD_TYPE,
    NEW_REFERENCES.TESTAMUR_TYPE,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.NOTES,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.GRADING_SCHEMA_CD,
    NEW_REFERENCES.GS_VERSION_NUMBER
  );

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

After_DML (
	p_action => 'INSERT',
	x_rowid => X_ROWID
);

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_AWARD_CD IN VARCHAR2,
  X_AWARD_TITLE IN VARCHAR2,
  X_S_AWARD_TYPE IN VARCHAR2,
  X_TESTAMUR_TYPE IN VARCHAR2,
  X_CLOSED_IND IN VARCHAR2,
  X_NOTES IN VARCHAR2 ,
  X_GRADING_SCHEMA_CD IN VARCHAR2  ,
  X_GS_VERSION_NUMBER IN NUMBER
) AS
  CURSOR c1 IS SELECT
      AWARD_TITLE,
      S_AWARD_TYPE,
      TESTAMUR_TYPE,
      CLOSED_IND,
      NOTES,
      GRADING_SCHEMA_CD,
      GS_VERSION_NUMBER
    FROM IGS_PS_AWD
    WHERE ROWID = X_ROWID
    FOR UPDATE NOWAIT;
  tlinfo c1%ROWTYPE;

BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    RETURN;
  END IF;
  CLOSE c1;

  IF (
      (tlinfo.AWARD_TITLE = X_AWARD_TITLE)
      AND (tlinfo.S_AWARD_TYPE = X_S_AWARD_TYPE)
      AND ((tlinfo.TESTAMUR_TYPE = X_TESTAMUR_TYPE)
           OR ((tlinfo.TESTAMUR_TYPE IS NULL)
               AND (X_TESTAMUR_TYPE IS NULL)))
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
      AND ((tlinfo.NOTES = X_NOTES)
           OR ((tlinfo.NOTES IS NULL)
               AND (X_NOTES IS NULL)))
      AND (
              (tlinfo.grading_schema_cd = X_grading_schema_cd)
 	      OR
	    (
	      (tlinfo.grading_schema_cd IS NULL)
              AND
	      (x_grading_schema_cd IS NULL)
	    )
	  )
      AND (
             (tlinfo.gs_version_number = X_gs_version_number)
 	     OR
	   (
	     (tlinfo.gs_version_number IS NULL)
             AND
	     (x_gs_version_number IS NULL)
	   )
	  )

  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_AWARD_CD IN VARCHAR2,
  X_AWARD_TITLE IN VARCHAR2,
  X_S_AWARD_TYPE IN VARCHAR2,
  X_TESTAMUR_TYPE IN VARCHAR2,
  X_CLOSED_IND IN VARCHAR2,
  X_NOTES IN VARCHAR2,
  X_MODE IN VARCHAR2 DEFAULT 'R' ,
  X_GRADING_SCHEMA_CD IN VARCHAR2  ,
  X_GS_VERSION_NUMBER IN NUMBER
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
    app_exception.raise_exception;
  END IF;

Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_award_cd => X_AWARD_CD ,
    x_award_title => X_AWARD_TITLE ,
    x_s_award_type => X_S_AWARD_TYPE ,
    x_testamur_type => X_TESTAMUR_TYPE ,
    x_closed_ind => X_CLOSED_IND ,
    x_notes => X_NOTES ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN  ,
    x_grading_schema_cd =>  X_GRADING_SCHEMA_CD ,
    x_gs_version_number =>  X_GS_VERSION_NUMBER
 );

  UPDATE IGS_PS_AWD SET
    AWARD_TITLE       = NEW_REFERENCES.AWARD_TITLE,
    S_AWARD_TYPE      = NEW_REFERENCES.S_AWARD_TYPE,
    TESTAMUR_TYPE     = NEW_REFERENCES.TESTAMUR_TYPE,
    CLOSED_IND        = NEW_REFERENCES.CLOSED_IND,
    NOTES             = NEW_REFERENCES.NOTES,
    LAST_UPDATE_DATE  = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY   =  X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    GRADING_SCHEMA_CD = NEW_REFERENCES.GRADING_SCHEMA_CD ,
    GS_VERSION_NUMBER = NEW_REFERENCES.GS_VERSION_NUMBER
  WHERE ROWID = X_ROWID
  ;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

After_DML (
	p_action => 'UPDATE',
	x_rowid => X_ROWID
);

END UPDATE_ROW;

PROCEDURE ADD_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_AWARD_CD IN VARCHAR2,
  X_AWARD_TITLE IN VARCHAR2,
  X_S_AWARD_TYPE IN VARCHAR2,
  X_TESTAMUR_TYPE IN VARCHAR2,
  X_CLOSED_IND IN VARCHAR2,
  X_NOTES IN VARCHAR2,
  X_MODE IN VARCHAR2 DEFAULT 'R',
  X_GRADING_SCHEMA_CD IN VARCHAR2  ,
  X_GS_VERSION_NUMBER IN NUMBER
  ) AS
  CURSOR c1 IS SELECT ROWID FROM IGS_PS_AWD
     WHERE AWARD_CD = X_AWARD_CD
  ;
BEGIN
  OPEN c1;
  FETCH c1 INTO X_ROWID;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    INSERT_ROW (
     X_ROWID,
     X_AWARD_CD,
     X_AWARD_TITLE,
     X_S_AWARD_TYPE,
     X_TESTAMUR_TYPE,
     X_CLOSED_IND,
     X_NOTES,
     X_MODE,
     X_GRADING_SCHEMA_CD   ,
     X_GS_VERSION_NUMBER
     );
    RETURN;
  END IF;
  CLOSE c1;
  UPDATE_ROW (
   X_ROWID,
   X_AWARD_CD,
   X_AWARD_TITLE,
   X_S_AWARD_TYPE,
   X_TESTAMUR_TYPE,
   X_CLOSED_IND,
   X_NOTES,
   X_MODE,
   X_GRADING_SCHEMA_CD   ,
   X_GS_VERSION_NUMBER
   );
END ADD_ROW;


END IGS_PS_AWD_PKG;

/
