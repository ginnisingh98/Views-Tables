--------------------------------------------------------
--  DDL for Package Body IGS_PS_STDNT_TRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_STDNT_TRN_PKG" AS
/* $Header: IGSPI64B.pls 120.0 2005/06/01 16:18:11 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PS_STDNT_TRN%ROWTYPE;
  new_references IGS_PS_STDNT_TRN%ROWTYPE;

PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    );

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_approved_date IN DATE DEFAULT NULL,
    x_effective_term_cal_type IN VARCHAR2 DEFAULT NULL,
    x_effective_term_sequence_num IN NUMBER DEFAULT NULL,
    x_discontinue_source_flag IN VARCHAR2 DEFAULT NULL,
    x_uooids_to_transfer IN VARCHAR2 DEFAULT NULL,
    x_susa_to_transfer IN VARCHAR2 DEFAULT NULL,
    x_transfer_adv_stand_flag IN VARCHAR2 DEFAULT NULL,
    x_status_date IN DATE ,
    x_status_flag IN VARCHAR2
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_STDNT_TRN
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
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.transfer_course_cd := x_transfer_course_cd;
    new_references.transfer_dt := x_transfer_dt;
    new_references.comments := x_comments;
    new_references.approved_date := x_approved_date;
    new_references.effective_term_cal_type := x_effective_term_cal_type;
    new_references.effective_term_sequence_num := x_effective_term_sequence_num;
    new_references.discontinue_source_flag := x_discontinue_source_flag;
    new_references.uooids_to_transfer := x_uooids_to_transfer;
    new_references.susa_to_transfer := x_susa_to_transfer;
    new_references.transfer_adv_stand_flag := x_transfer_adv_stand_flag;
    new_references.status_date := x_status_date;
    new_references.status_flag := x_status_flag;

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

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Insert validation
	IF	p_inserting THEN

		IF Igs_En_Val_Sct.enrp_val_sct_insert (
				new_references.person_id,
				new_references.course_cd,
				new_references.transfer_course_cd,
				new_references.transfer_dt,
				v_message_name) = FALSE THEN

						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdateDelete1;


 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN

 IF  column_name IS NULL THEN
     NULL;
 ELSIF UPPER(Column_name) = 'COURSE_CD' THEN
     new_references.course_cd := column_value;
 ELSIF UPPER(Column_name) = 'TRANSFER_COURSE_CD' THEN
     new_references.transfer_course_cd := column_value;
 END IF;

IF UPPER(column_name) = 'COURSE_CD' OR
     column_name IS NULL THEN
     IF new_references.course_cd <> UPPER(new_references.course_cd) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF UPPER(column_name) = 'TRANSFER_COURSE_CD' OR
     column_name IS NULL THEN
     IF new_references.transfer_course_cd <> UPPER(new_references.transfer_course_cd) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
END check_constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT Igs_En_Stdnt_Ps_Att_Pkg.Get_PK_For_Validation (
        new_references.person_id,
        new_references.transfer_course_cd
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
--Uncommented This
	    App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.transfer_course_cd = new_references.transfer_course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.transfer_course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT Igs_En_Stdnt_Ps_Att_Pkg.Get_PK_For_Validation (
        new_references.person_id,
        new_references.transfer_course_cd
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.effective_term_cal_type = new_references.effective_term_cal_type) AND
         (old_references.effective_term_sequence_num = new_references.effective_term_sequence_num)) OR
        ((new_references.effective_term_cal_type IS NULL) OR
         (new_references.effective_term_sequence_num IS NULL))) THEN
      NULL;
    ELSE
     IF  NOT IGS_CA_INST_PKG.Get_PK_For_Validation(
                            new_references.effective_term_cal_type,
                            new_references.effective_term_sequence_num) THEN

        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
  	    IGS_GE_MSG_STACK.ADD;
	      App_Exception.Raise_Exception;

      END IF;

    END IF;
  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PS_STDNT_UNT_TRN_PKG.GET_FK_IGS_PS_STDNT_TRN (
      old_references.person_id,
      old_references.course_cd,
      old_references.transfer_course_cd,
      old_references.transfer_dt
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_transfer_course_cd IN VARCHAR2,
    x_transfer_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_PS_STDNT_TRN
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      transfer_course_cd = x_transfer_course_cd
      AND      transfer_dt = x_transfer_dt
      FOR UPDATE NOWAIT;

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

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_PS_STDNT_TRN
      WHERE    (person_id = x_person_id
      AND      course_cd = x_course_cd)
	OR       (person_id = x_person_id
      AND      transfer_course_cd = x_course_cd);

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_SCT_SCA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END GET_FK_IGS_EN_STDNT_PS_ATT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_approved_date IN DATE DEFAULT NULL,
    x_effective_term_cal_type IN VARCHAR2 DEFAULT NULL,
    x_effective_term_sequence_num IN NUMBER DEFAULT NULL,
    x_discontinue_source_flag IN VARCHAR2 DEFAULT NULL,
    x_uooids_to_transfer IN VARCHAR2 DEFAULT NULL,
    x_susa_to_transfer IN VARCHAR2 DEFAULT NULL,
    x_transfer_adv_stand_flag IN VARCHAR2 DEFAULT NULL,
    x_status_date IN DATE ,
    x_status_flag IN VARCHAR2

  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_transfer_course_cd,
      x_transfer_dt,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_approved_date,
      x_effective_term_cal_type,
      x_effective_term_sequence_num,
      x_discontinue_source_flag,
      x_uooids_to_transfer,
      x_susa_to_transfer ,
      x_transfer_adv_stand_flag,
      x_status_date,
      x_status_flag
    );

 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
		    new_references.person_id,
		    new_references.course_cd,
		    new_references.transfer_course_cd,
		    new_references.transfer_dt
         				 ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
       Check_Constraints;
       Check_Parent_Existance;
 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
       Check_Child_Existance;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
		    new_references.person_id,
		    new_references.course_cd,
		    new_references.transfer_course_cd,
		    new_references.transfer_dt
         				 ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
  ) AS
  BEGIN

    l_rowid := x_rowid;

      IF (p_action = 'INSERT') THEN

      -- Call all the procedures related to After Insert.
       AfterRowInsertUpdate2 ( p_inserting => TRUE,
			      p_updating => FALSE,
			      p_deleting => FALSE
			    );
      END IF ;

  END After_DML;


PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS

CURSOR cur_prog_atmpt(cp_transfer_course_cd igs_en_stdnt_ps_att.course_cd%TYPE,
                      cp_person_id igs_en_stdnt_ps_att.person_id%TYPE) IS
  SELECT  person_id,course_cd,version_number,cal_type ,commencement_dt,course_attempt_status ,
          location_cd,attendance_mode,attendance_type
  FROM igs_en_stdnt_ps_att
  WHERE course_cd = cp_transfer_course_cd
  AND   person_id = cp_person_id;

 l_cur_prog_atmpt cur_prog_atmpt%ROWTYPE;

 BEGIN

-- Bug # 2829275 . UK Correspondence. The TBH needs to be modified to so that program transfer business event is raised whenever a program transfer is done

   IF (p_inserting) THEN

     OPEN cur_prog_atmpt(new_references.course_cd,new_references.person_id);
     FETCH cur_prog_atmpt INTO l_cur_prog_atmpt;
     CLOSE cur_prog_atmpt;


      igs_en_workflow.progtrans_event (
				p_personid	=> new_references.person_id,
				p_destprogcd	=> new_references.course_cd,
				p_progstartdt	=> l_cur_prog_atmpt.commencement_dt,
				p_location	=> l_cur_prog_atmpt.location_cd,
				p_atten_type	=> l_cur_prog_atmpt.attendance_type,
				p_atten_mode	=> l_cur_prog_atmpt.attendance_mode,
				p_prog_status	=> l_cur_prog_atmpt.course_attempt_status,
				p_trsnfrdt	=> new_references.transfer_dt,
				p_sourceprogcd	=> new_references.transfer_course_cd
                             );


   END IF ;

 END AfterRowInsertUpdate2;

PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_TRANSFER_COURSE_CD IN VARCHAR2,
  X_TRANSFER_DT IN DATE,
  X_COURSE_CD IN VARCHAR2,
  X_COMMENTS IN VARCHAR2,
  X_MODE IN VARCHAR2,
  X_APPROVED_DATE IN DATE,
  X_EFFECTIVE_TERM_CAL_TYPE IN VARCHAR2,
  X_EFFECTIVE_TERM_SEQUENCE_NUM IN NUMBER,
  X_DISCONTINUE_SOURCE_FLAG IN VARCHAR2,
  X_UOOIDS_TO_TRANSFER IN VARCHAR2,
  X_SUSA_TO_TRANSFER IN VARCHAR2,
  X_TRANSFER_ADV_STAND_FLAG IN VARCHAR2,
  X_STATUS_DATE IN DATE ,
  X_STATUS_FLAG IN VARCHAR2
  ) AS
    CURSOR C IS SELECT ROWID FROM IGS_PS_STDNT_TRN
      WHERE PERSON_ID = X_PERSON_ID
      AND TRANSFER_COURSE_CD = X_TRANSFER_COURSE_CD
      AND TRANSFER_DT = X_TRANSFER_DT
      AND COURSE_CD = X_COURSE_CD;
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
  Before_DML( p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_course_cd => X_COURSE_CD,
    x_transfer_course_cd => X_TRANSFER_COURSE_CD,
    x_transfer_dt => X_TRANSFER_DT,
    x_comments => X_COMMENTS,
    x_approved_date => X_APPROVED_DATE,
    x_effective_term_cal_type =>  X_EFFECTIVE_TERM_CAL_TYPE,
    x_effective_term_sequence_num => X_EFFECTIVE_TERM_SEQUENCE_NUM,
    x_discontinue_source_flag => X_DISCONTINUE_SOURCE_FLAG,
    x_uooids_to_transfer => X_UOOIDS_TO_TRANSFER,
    x_susa_to_transfer => X_SUSA_TO_TRANSFER,
    x_transfer_adv_stand_flag => X_TRANSFER_ADV_STAND_FLAG,
    x_status_date => X_STATUS_DATE,
    x_status_flag => nvl(X_STATUS_FLAG,'T'),
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  INSERT INTO IGS_PS_STDNT_TRN (
    PERSON_ID,
    COURSE_CD,
    TRANSFER_COURSE_CD,
    TRANSFER_DT,
    COMMENTS,
    APPROVED_DATE,
    EFFECTIVE_TERM_CAL_TYPE,
    EFFECTIVE_TERM_SEQUENCE_NUM,
    DISCONTINUE_SOURCE_FLAG,
    UOOIDS_TO_TRANSFER,
    SUSA_TO_TRANSFER,
    TRANSFER_ADV_STAND_FLAG,
    STATUS_DATE,
    STATUS_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.TRANSFER_COURSE_CD,
    NEW_REFERENCES.TRANSFER_DT,
    NEW_REFERENCES.COMMENTS,
    NEW_REFERENCES.APPROVED_DATE,
    NEW_REFERENCES.EFFECTIVE_TERM_CAL_TYPE,
    NEW_REFERENCES.EFFECTIVE_TERM_SEQUENCE_NUM,
    NEW_REFERENCES.DISCONTINUE_SOURCE_FLAG,
    NEW_REFERENCES.UOOIDS_TO_TRANSFER,
    NEW_REFERENCES.SUSA_TO_TRANSFER,
    NEW_REFERENCES.TRANSFER_ADV_STAND_FLAG,
    NEW_REFERENCES.STATUS_DATE,
    NEW_REFERENCES.STATUS_FLAG,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
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
  X_ROWID IN VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_TRANSFER_COURSE_CD IN VARCHAR2,
  X_TRANSFER_DT IN DATE,
  X_COURSE_CD IN VARCHAR2,
  X_COMMENTS IN VARCHAR2,
  X_APPROVED_DATE IN DATE,
  X_EFFECTIVE_TERM_CAL_TYPE IN VARCHAR2,
  X_EFFECTIVE_TERM_SEQUENCE_NUM IN NUMBER,
  X_DISCONTINUE_SOURCE_FLAG IN VARCHAR2,
  X_UOOIDS_TO_TRANSFER IN VARCHAR2,
  X_SUSA_TO_TRANSFER IN VARCHAR2,
  X_TRANSFER_ADV_STAND_FLAG IN VARCHAR2,
  X_STATUS_DATE IN DATE ,
  X_STATUS_FLAG IN VARCHAR2
) AS
  CURSOR c1 IS SELECT
      COMMENTS, APPROVED_DATE, EFFECTIVE_TERM_CAL_TYPE, EFFECTIVE_TERM_SEQUENCE_NUM, DISCONTINUE_SOURCE_FLAG,
      UOOIDS_TO_TRANSFER, SUSA_TO_TRANSFER, TRANSFER_ADV_STAND_FLAG, STATUS_DATE, STATUS_FLAG
    FROM IGS_PS_STDNT_TRN
    WHERE ROWID = X_ROWID FOR UPDATE NOWAIT;
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

      IF ( ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS IS NULL)
               AND (X_COMMENTS IS NULL)))

	  AND ((tlinfo.APPROVED_DATE = X_APPROVED_DATE)
           OR ((tlinfo.APPROVED_DATE IS NULL)
               AND (X_APPROVED_DATE IS NULL)))

	  AND ((tlinfo.EFFECTIVE_TERM_CAL_TYPE = X_EFFECTIVE_TERM_CAL_TYPE)
           OR ((tlinfo.EFFECTIVE_TERM_CAL_TYPE IS NULL)
               AND (X_EFFECTIVE_TERM_CAL_TYPE IS NULL)))

	  AND ((tlinfo.EFFECTIVE_TERM_SEQUENCE_NUM = X_EFFECTIVE_TERM_SEQUENCE_NUM)
           OR ((tlinfo.EFFECTIVE_TERM_SEQUENCE_NUM IS NULL)
               AND (X_EFFECTIVE_TERM_SEQUENCE_NUM IS NULL)))

    AND ((tlinfo.DISCONTINUE_SOURCE_FLAG = X_DISCONTINUE_SOURCE_FLAG)
         OR ((tlinfo.DISCONTINUE_SOURCE_FLAG IS NULL)
             AND (X_DISCONTINUE_SOURCE_FLAG IS NULL)))

    AND ((tlinfo.UOOIDS_TO_TRANSFER = X_UOOIDS_TO_TRANSFER)
           OR ((tlinfo.UOOIDS_TO_TRANSFER IS NULL)
               AND (X_UOOIDS_TO_TRANSFER IS NULL)))

    AND ((tlinfo.SUSA_TO_TRANSFER = X_SUSA_TO_TRANSFER)
       OR ((tlinfo.SUSA_TO_TRANSFER IS NULL)
           AND (X_SUSA_TO_TRANSFER IS NULL)))

    AND ((tlinfo.TRANSFER_ADV_STAND_FLAG = X_TRANSFER_ADV_STAND_FLAG)
       OR ((tlinfo.TRANSFER_ADV_STAND_FLAG IS NULL)
           AND (X_TRANSFER_ADV_STAND_FLAG IS NULL)))


    AND ((tlinfo.STATUS_DATE = X_STATUS_DATE)
       OR ((tlinfo.STATUS_DATE IS NULL)
           AND (X_STATUS_DATE IS NULL)))

    AND ((tlinfo.STATUS_FLAG = X_STATUS_FLAG)
       OR ((tlinfo.STATUS_FLAG IS NULL)
           AND (X_STATUS_FLAG IS NULL)))

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
  X_PERSON_ID IN NUMBER,
  X_TRANSFER_COURSE_CD IN VARCHAR2,
  X_TRANSFER_DT IN DATE,
  X_COURSE_CD IN VARCHAR2,
  X_COMMENTS IN VARCHAR2,
  X_MODE IN VARCHAR2,
  X_APPROVED_DATE IN DATE,
  X_EFFECTIVE_TERM_CAL_TYPE IN VARCHAR2,
  X_EFFECTIVE_TERM_SEQUENCE_NUM IN NUMBER,
  X_DISCONTINUE_SOURCE_FLAG IN VARCHAR2,
  X_UOOIDS_TO_TRANSFER IN VARCHAR2,
  X_SUSA_TO_TRANSFER IN VARCHAR2,
  X_TRANSFER_ADV_STAND_FLAG IN VARCHAR2,
  X_STATUS_DATE IN DATE,
  X_STATUS_FLAG IN VARCHAR2

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
  Before_DML( p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_course_cd => X_COURSE_CD,
    x_transfer_course_cd => X_TRANSFER_COURSE_CD,
    x_transfer_dt => X_TRANSFER_DT,
    x_comments => X_COMMENTS,
    x_approved_date => X_APPROVED_DATE,
    x_effective_term_cal_type =>  X_EFFECTIVE_TERM_CAL_TYPE,
    x_effective_term_sequence_num => X_EFFECTIVE_TERM_SEQUENCE_NUM,
    x_discontinue_source_flag => X_DISCONTINUE_SOURCE_FLAG,
    x_uooids_to_transfer => X_UOOIDS_TO_TRANSFER,
    x_susa_to_transfer => X_SUSA_TO_TRANSFER,
    x_transfer_adv_stand_flag => X_TRANSFER_ADV_STAND_FLAG,
    x_status_date => X_STATUS_DATE,
    x_status_flag => nvl(X_STATUS_FLAG, 'T'),
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  UPDATE IGS_PS_STDNT_TRN SET
    COMMENTS = NEW_REFERENCES.COMMENTS,
    APPROVED_DATE = NEW_REFERENCES.APPROVED_DATE,
    EFFECTIVE_TERM_CAL_TYPE =  NEW_REFERENCES.EFFECTIVE_TERM_CAL_TYPE,
    EFFECTIVE_TERM_SEQUENCE_NUM = NEW_REFERENCES.EFFECTIVE_TERM_SEQUENCE_NUM,
    DISCONTINUE_SOURCE_FLAG = NEW_REFERENCES.DISCONTINUE_SOURCE_FLAG,
    UOOIDS_TO_TRANSFER = NEW_REFERENCES.UOOIDS_TO_TRANSFER,
    SUSA_TO_TRANSFER = NEW_REFERENCES.SUSA_TO_TRANSFER,
    TRANSFER_ADV_STAND_FLAG = NEW_REFERENCES.TRANSFER_ADV_STAND_FLAG,
    STATUS_DATE = NEW_REFERENCES.STATUS_DATE,
    STATUS_FLAG = NEW_REFERENCES.STATUS_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  WHERE ROWID = X_ROWID
  ;
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
  X_PERSON_ID IN NUMBER,
  X_TRANSFER_COURSE_CD IN VARCHAR2,
  X_TRANSFER_DT IN DATE,
  X_COURSE_CD IN VARCHAR2,
  X_COMMENTS IN VARCHAR2,
  X_MODE IN VARCHAR2,
  X_APPROVED_DATE IN DATE,
  X_EFFECTIVE_TERM_CAL_TYPE IN VARCHAR2,
  X_EFFECTIVE_TERM_SEQUENCE_NUM IN NUMBER,
  X_DISCONTINUE_SOURCE_FLAG IN VARCHAR2,
  X_UOOIDS_TO_TRANSFER IN VARCHAR2,
  X_SUSA_TO_TRANSFER IN VARCHAR2,
  X_TRANSFER_ADV_STAND_FLAG IN VARCHAR2,
  X_STATUS_DATE IN DATE,
  X_STATUS_FLAG IN VARCHAR2

  ) AS
  CURSOR c1 IS SELECT ROWID FROM IGS_PS_STDNT_TRN
     WHERE PERSON_ID = X_PERSON_ID
     AND TRANSFER_COURSE_CD = X_TRANSFER_COURSE_CD
     AND TRANSFER_DT = X_TRANSFER_DT
     AND COURSE_CD = X_COURSE_CD
  ;
BEGIN
  OPEN c1;
  FETCH c1 INTO X_ROWID;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_TRANSFER_COURSE_CD,
     X_TRANSFER_DT,
     X_COURSE_CD,
     X_COMMENTS,
     X_MODE,
     X_APPROVED_DATE,
     X_EFFECTIVE_TERM_CAL_TYPE,
     X_EFFECTIVE_TERM_SEQUENCE_NUM,
     X_DISCONTINUE_SOURCE_FLAG,
     X_UOOIDS_TO_TRANSFER,
     X_SUSA_TO_TRANSFER,
     X_TRANSFER_ADV_STAND_FLAG,
     X_STATUS_DATE,
     X_STATUS_FLAG);
    RETURN;
  END IF;
  CLOSE c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_TRANSFER_COURSE_CD,
   X_TRANSFER_DT,
   X_COURSE_CD,
   X_COMMENTS,
   X_MODE,
   X_APPROVED_DATE,
   X_EFFECTIVE_TERM_CAL_TYPE,
   X_EFFECTIVE_TERM_SEQUENCE_NUM,
   X_DISCONTINUE_SOURCE_FLAG,
   X_UOOIDS_TO_TRANSFER,
   X_SUSA_TO_TRANSFER,
   X_TRANSFER_ADV_STAND_FLAG,
   X_STATUS_DATE,
   X_STATUS_FLAG);
END ADD_ROW;

PROCEDURE DELETE_ROW (
  X_ROWID IN VARCHAR2
) AS
BEGIN
  Before_DML( p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  DELETE FROM IGS_PS_STDNT_TRN
  WHERE ROWID = X_ROWID;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
END DELETE_ROW;

END Igs_Ps_Stdnt_Trn_Pkg;

/
