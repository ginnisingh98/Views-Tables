--------------------------------------------------------
--  DDL for Package Body IGS_AS_NON_ENR_STDOT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_NON_ENR_STDOT_PKG" AS
/* $Header: IGSDI17B.pls 115.7 2002/11/28 23:14:38 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AS_NON_ENR_STDOT_ALL%RowType;
  new_references IGS_AS_NON_ENR_STDOT_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    X_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_s_grade_creation_method_type IN VARCHAR2 DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_gs_version_number IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_mark IN NUMBER DEFAULT NULL,
    x_resolved_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_NON_ENR_STDOT_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action  NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	        Close cur_old_ref_values;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.org_id := x_org_id;
    new_references.person_id := x_person_id;
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.course_cd := x_course_cd;
    new_references.location_cd := x_location_cd;
    new_references.unit_mode := x_unit_mode;
    new_references.unit_class := x_unit_class;
    new_references.s_grade_creation_method_type := X_S_GRADE_CREATION_METHOD_TYPE;
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.gs_version_number := x_gs_version_number;
    new_references.grade := x_grade;
    new_references.mark := x_mark;
    new_references.resolved_ind := x_resolved_ind;
    new_references.comments := x_comments;
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
	v_message_name	VARCHAR2(30);
  BEGIN
	IF p_inserting OR p_updating THEN
		IF IGS_AS_VAL_NESO.assp_val_neso_ins(
				new_references.person_id,
				new_references.course_cd,
				new_references.unit_cd,
				new_references.version_number,
				new_references.mark,
				new_references.grade,
                                new_references.grading_schema_cd,
                                new_references.gs_version_number,
				new_references.s_grade_creation_method_type,
				v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	IF p_inserting OR
	    (p_updating AND old_references.location_cd <> new_references.location_cd AND
			 new_references.location_cd IS NOT NULL) THEN
		IF IGS_AS_VAL_ELS.ORGP_VAL_LOC_CLOSED(
				new_references.location_cd,
				v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	IF p_inserting OR
	    (p_updating AND old_references.unit_mode <> new_references.unit_mode AND
			new_references.unit_mode IS NOT NULL) THEN
			-- As part of the bug# 1956374 changed to the below call from IGS_AS_VAL_NESO.crsp_val_um_closed
		IF IGS_AS_VAL_UAI.crsp_val_um_closed(
				new_references.unit_mode,
				v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	IF p_inserting OR
	    (p_updating AND old_references.unit_class <> new_references.unit_class AND
			new_references.unit_class IS NOT NULL) THEN

		-- As part of the bug# 1956374 changed to the below call from IGS_AS_VAL_NESO.crsp_val_ucl_closed
		IF IGS_AS_VAL_UAI.crsp_val_ucl_closed(
				new_references.unit_mode,
				v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.gs_version_number = new_references.gs_version_number) AND
         (old_references.grade = new_references.grade)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.gs_version_number IS NULL) OR
         (new_references.grade IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AS_GRD_SCH_GRADE_PKG.Get_PK_For_Validation (
        new_references.grading_schema_cd,
        new_references.gs_version_number,
        new_references.grade         )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF (((old_references.s_grade_creation_method_type = new_references.s_grade_creation_method_type)) OR
        ((new_references.s_grade_creation_method_type IS NULL))) THEN
      NULL;
    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd) OR
         (old_references.version_number = new_references.version_number) OR
         (old_references.cal_type = new_references.cal_type) OR
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_PS_UNIT_OFR_PAT_PKG.Get_PK_For_Validation (
        new_references.unit_cd,
        new_references.version_number,
        new_references.cal_type,
        new_references.ci_sequence_number
        )	THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd)) OR
        ((new_references.course_cd IS NULL))) THEN
      NULL;
    ELSif not iGS_PS_COURSE_PKG.Get_PK_For_Validation (
        new_references.course_cd
        )THEN
		  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_NON_ENR_STDOT_ALL
      WHERE    person_id = x_person_id
      AND      unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    	IF (cur_rowid%FOUND) THEN
	      Close cur_rowid;
	      Return (TRUE);
	ELSE
	      Close cur_rowid;
	      Return (FALSE);
	END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_AS_GRD_SCH_GRADE (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_NON_ENR_STDOT_ALL
      WHERE    grading_schema_cd = x_grading_schema_cd
      AND      gs_version_number = x_version_number
      AND      grade = x_grade ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_NESO_GSG_FK');
IGS_GE_MSG_STACK.ADD;
	        Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AS_GRD_SCH_GRADE;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_NON_ENR_STDOT_ALL
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_NESO_PE_FK');
IGS_GE_MSG_STACK.ADD;
	        Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_s_grade_creation_method_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_NON_ENR_STDOT_ALL
      WHERE    s_grade_creation_method_type = x_s_grade_creation_method_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_NESO_SLV_FK');
IGS_GE_MSG_STACK.ADD;
	        Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE GET_FK_IGS_PS_UNIT_OFR_PAT (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_NON_ENR_STDOT_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_NESO_UOP_FK');
IGS_GE_MSG_STACK.ADD;
	        Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_OFR_PAT;

  PROCEDURE GET_FK_IGS_PS_COURSE (
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_NON_ENR_STDOT_ALL
      WHERE    course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_NESO_CRS_FK');
IGS_GE_MSG_STACK.ADD;
	        Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_COURSE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_s_grade_creation_method_type IN VARCHAR2 DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_gs_version_number IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_mark IN NUMBER DEFAULT NULL,
    x_resolved_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_person_id,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_course_cd,
      x_location_cd,
      x_unit_mode,
      x_unit_class,
      X_S_GRADE_CREATION_METHOD_TYPE,
      x_grading_schema_cd,
      x_gs_version_number,
      x_grade,
      x_mark,
      x_resolved_ind,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );

	IF  Get_PK_For_Validation (
	         NEW_REFERENCES.person_id ,
    NEW_REFERENCES.unit_cd ,
    NEW_REFERENCES.version_number,
    NEW_REFERENCES.cal_type ,
    NEW_REFERENCES.ci_sequence_number
) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
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
	         NEW_REFERENCES.person_id ,
    NEW_REFERENCES.unit_cd ,
    NEW_REFERENCES.version_number,
    NEW_REFERENCES.cal_type ,
    NEW_REFERENCES.ci_sequence_number
) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
	         APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;

	     Check_Constraints;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN

	      Check_Constraints;
    END IF;



  END Before_DML;




procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_s_grade_creation_method_type in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_MARK in NUMBER,
  X_RESOLVED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AS_NON_ENR_STDOT_ALL
      where PERSON_ID = X_PERSON_ID
      and UNIT_CD = X_UNIT_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and CAL_TYPE = X_CAL_TYPE
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;

   X_PROGRAM_APPLICATION_ID :=
                                       FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := NULL;
     X_PROGRAM_ID := NULL;
     X_PROGRAM_APPLICATION_ID := NULL;
     X_PROGRAM_UPDATE_DATE := NULL;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_org_id => igs_ge_gen_003.get_org_id,
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_comments=>X_COMMENTS,
  x_course_cd=>X_COURSE_CD,
  x_grade=>X_GRADE,
  x_grading_schema_cd=>X_GRADING_SCHEMA_CD,
  x_gs_version_number=>X_GS_VERSION_NUMBER,
  x_location_cd=>X_LOCATION_CD,
  x_mark=>X_MARK,
  x_person_id=>X_PERSON_ID,
  x_resolved_ind=> NVL(X_RESOLVED_IND,'N'),
  X_S_GRADE_CREATION_METHOD_TYPE=>X_S_GRADE_CREATION_METHOD_TYPE,
  x_unit_cd=>X_UNIT_CD,
  x_unit_class=>X_UNIT_CLASS,
  x_unit_mode=>X_UNIT_MODE,
  x_version_number=>X_VERSION_NUMBER,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );

  insert into IGS_AS_NON_ENR_STDOT_ALL (
    ORG_ID,
    PERSON_ID,
    UNIT_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    COURSE_CD,
    LOCATION_CD,
    UNIT_MODE,
    UNIT_CLASS,
    S_GRADE_CREATION_METHOD_TYPE,
    GRADING_SCHEMA_CD,
    GS_VERSION_NUMBER,
    GRADE,
    MARK,
    RESOLVED_IND,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.UNIT_MODE,
    NEW_REFERENCES.UNIT_CLASS,
    NEW_REFERENCES.S_GRADE_CREATION_METHOD_TYPE,
    NEW_REFERENCES.GRADING_SCHEMA_CD,
    NEW_REFERENCES.GS_VERSION_NUMBER,
    NEW_REFERENCES.GRADE,
    NEW_REFERENCES.MARK,
    NEW_REFERENCES.RESOLVED_IND,
    NEW_REFERENCES.COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
  );
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;


end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in  VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_s_grade_creation_method_type in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_MARK in NUMBER,
  X_RESOLVED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select
      COURSE_CD,
      LOCATION_CD,
      UNIT_MODE,
      UNIT_CLASS,
      S_GRADE_CREATION_METHOD_TYPE,
      GRADING_SCHEMA_CD,
      GS_VERSION_NUMBER,
      GRADE,
      MARK,
      RESOLVED_IND,
      COMMENTS
    from IGS_AS_NON_ENR_STDOT_ALL
    where ROWID = X_ROWID  for update  nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    close c1;
    return;
  end if;
  close c1;

      if ( ((tlinfo.COURSE_CD = X_COURSE_CD)
           OR ((tlinfo.COURSE_CD is null)
               AND (X_COURSE_CD is null)))
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.UNIT_MODE = X_UNIT_MODE)
           OR ((tlinfo.UNIT_MODE is null)
               AND (X_UNIT_MODE is null)))
      AND ((tlinfo.UNIT_CLASS = X_UNIT_CLASS)
           OR ((tlinfo.UNIT_CLASS is null)
               AND (X_UNIT_CLASS is null)))
      AND (tlinfo.S_GRADE_CREATION_METHOD_TYPE = X_S_GRADE_CREATION_METHOD_TYPE)
      AND ((tlinfo.GRADING_SCHEMA_CD = X_GRADING_SCHEMA_CD)
           OR ((tlinfo.GRADING_SCHEMA_CD is null)
               AND (X_GRADING_SCHEMA_CD is null)))
      AND ((tlinfo.GS_VERSION_NUMBER = X_GS_VERSION_NUMBER)
           OR ((tlinfo.GS_VERSION_NUMBER is null)
               AND (X_GS_VERSION_NUMBER is null)))
      AND ((tlinfo.GRADE = X_GRADE)
           OR ((tlinfo.GRADE is null)
               AND (X_GRADE is null)))
      AND ((tlinfo.MARK = X_MARK)
           OR ((tlinfo.MARK is null)
               AND (X_MARK is null)))
      AND ((tlinfo.RESOLVED_IND = X_RESOLVED_IND)
           OR ((tlinfo.RESOLVED_IND is null)
               AND (X_RESOLVED_IND is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in  VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_s_grade_creation_method_type in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_MARK in NUMBER,
  X_RESOLVED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;

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
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

 Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_comments=>X_COMMENTS,
  x_course_cd=>X_COURSE_CD,
  x_grade=>X_GRADE,
  x_grading_schema_cd=>X_GRADING_SCHEMA_CD,
  x_gs_version_number=>X_GS_VERSION_NUMBER,
  x_location_cd=>X_LOCATION_CD,
  x_mark=>X_MARK,
  x_person_id=>X_PERSON_ID,
  x_resolved_ind=>X_RESOLVED_IND,
  X_S_GRADE_CREATION_METHOD_TYPE=>X_S_GRADE_CREATION_METHOD_TYPE,
  x_unit_cd=>X_UNIT_CD,
  x_unit_class=>X_UNIT_CLASS,
  x_unit_mode=>X_UNIT_MODE,
  x_version_number=>X_VERSION_NUMBER,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );

 if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
end if;


  update IGS_AS_NON_ENR_STDOT_ALL set
    COURSE_CD = NEW_REFERENCES.COURSE_CD,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    UNIT_MODE = NEW_REFERENCES.UNIT_MODE,
    UNIT_CLASS = NEW_REFERENCES.UNIT_CLASS,
    S_GRADE_CREATION_METHOD_TYPE = NEW_REFERENCES.S_GRADE_CREATION_METHOD_TYPE,
    GRADING_SCHEMA_CD = NEW_REFERENCES.GRADING_SCHEMA_CD,
    GS_VERSION_NUMBER = NEW_REFERENCES.GS_VERSION_NUMBER,
    GRADE = NEW_REFERENCES.GRADE,
    MARK = NEW_REFERENCES.MARK,
    RESOLVED_IND = NEW_REFERENCES.RESOLVED_IND,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_s_grade_creation_method_type in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_MARK in NUMBER,
  X_RESOLVED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AS_NON_ENR_STDOT_ALL
     where PERSON_ID = X_PERSON_ID
     and UNIT_CD = X_UNIT_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and CAL_TYPE = X_CAL_TYPE
     and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_PERSON_ID,
     X_UNIT_CD,
     X_VERSION_NUMBER,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_COURSE_CD,
     X_LOCATION_CD,
     X_UNIT_MODE,
     X_UNIT_CLASS,
     X_S_GRADE_CREATION_METHOD_TYPE,
     X_GRADING_SCHEMA_CD,
     X_GS_VERSION_NUMBER,
     X_GRADE,
     X_MARK,
     X_RESOLVED_IND,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_UNIT_CD,
   X_VERSION_NUMBER,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_COURSE_CD,
   X_LOCATION_CD,
   X_UNIT_MODE,
   X_UNIT_CLASS,
   X_S_GRADE_CREATION_METHOD_TYPE,
   X_GRADING_SCHEMA_CD,
   X_GS_VERSION_NUMBER,
   X_GRADE,
   X_MARK,
   X_RESOLVED_IND,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_NON_ENR_STDOT_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

	PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	)
	AS
	BEGIN

	IF  column_name is null then
	    NULL;
ELSIF upper(Column_name) = 'CAL_TYPE' then
	    new_references.CAL_TYPE := column_value;
ELSIF upper(Column_name) = 'COURSE_CD' then
	    new_references.COURSE_CD := column_value;
ELSIF upper(Column_name) = 'GRADE' then
	    new_references.GRADE := column_value;
ELSIF upper(Column_name) = 'GRADING_SCHEMA_CD' then
	    new_references.GRADING_SCHEMA_CD := column_value;
ELSIF upper(Column_name) = 'LOCATION_CD' then
	    new_references.LOCATION_CD := column_value;
ELSIF upper(Column_name) = 'S_GRADE_CREATION_METHOD_TYPE' then
	    new_references.S_GRADE_CREATION_METHOD_TYPE := column_value;
ELSIF upper(Column_name) = 'UNIT_CD' then
	    new_references.UNIT_CD := column_value;
ELSIF upper(Column_name) = 'UNIT_CLASS' then
	    new_references.UNIT_CLASS := column_value;
ELSIF upper(Column_name) = 'CI_SEQUENCE_NUMBER' then
	    new_references.CI_SEQUENCE_NUMBER := IGS_GE_NUMBER.TO_NUM(column_value);
ELSIF upper(Column_name) = 'MARK' then
	    new_references.MARK := IGS_GE_NUMBER.TO_NUM(column_value);
ELSIF upper(Column_name) = 'RESOLVED_IND' then
	    new_references.RESOLVED_IND := column_value;
		END IF;

IF upper(column_name) = 'CAL_TYPE' OR
     column_name is null Then
     IF new_references.CAL_TYPE <> UPPER(new_references.CAL_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.COURSE_CD <> UPPER(new_references.COURSE_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'GRADE' OR
     column_name is null Then
     IF new_references.GRADE <> UPPER(new_references.GRADE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'GRADING_SCHEMA_CD' OR
     column_name is null Then
     IF new_references.GRADING_SCHEMA_CD <> UPPER(new_references.GRADING_SCHEMA_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'LOCATION_CD' OR
     column_name is null Then
     IF new_references.LOCATION_CD <> UPPER(new_references.LOCATION_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'S_GRADE_CREATION_METHOD_TYPE' OR
     column_name is null Then
     IF new_references.S_GRADE_CREATION_METHOD_TYPE <> UPPER(new_references.S_GRADE_CREATION_METHOD_TYPE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'UNIT_CD' OR
     column_name is null Then
     IF new_references.UNIT_CD <> UPPER(new_references.UNIT_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
IF upper(column_name) = 'UNIT_CLASS' OR
     column_name is null Then
     IF new_references.UNIT_CLASS <> UPPER(new_references.UNIT_CLASS) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


IF upper(column_name) = 'CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.CI_SEQUENCE_NUMBER < 1 OR new_references.CI_SEQUENCE_NUMBER >  999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


IF upper(column_name) = 'MARK' OR
     column_name is null Then
     IF new_references.MARK < 0 OR new_references.MARK > 999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


IF upper(column_name) = 'RESOLVED_IND' OR
     column_name is null Then
     IF new_references.RESOLVED_IND NOT IN ('Y','N') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
	END Check_Constraints;



end IGS_AS_NON_ENR_STDOT_PKG;

/
