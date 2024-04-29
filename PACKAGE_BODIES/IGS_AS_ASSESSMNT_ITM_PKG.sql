--------------------------------------------------------
--  DDL for Package Body IGS_AS_ASSESSMNT_ITM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_ASSESSMNT_ITM_PKG" as
/* $Header: IGSDI38B.pls 115.10 2003/02/24 11:58:23 anilk ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AS_ASSESSMNT_ITM_ALL%RowType;
  new_references IGS_AS_ASSESSMNT_ITM_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_assessment_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_exam_scheduled_ind IN VARCHAR2 DEFAULT NULL,
    x_exam_working_time IN DATE DEFAULT NULL,
    x_exam_announcements IN VARCHAR2 DEFAULT NULL,
    x_exam_short_paper_name IN VARCHAR2 DEFAULT NULL,
    x_exam_paper_name IN VARCHAR2 DEFAULT NULL,
    x_exam_perusal_time IN DATE DEFAULT NULL,
    x_exam_supervisor_instrctn IN VARCHAR2 DEFAULT NULL,
    x_exam_allowable_instrctn IN VARCHAR2 DEFAULT NULL,
    x_exam_non_allowed_instrctn IN VARCHAR2 DEFAULT NULL,
    x_exam_supplied_instrctn IN VARCHAR2 DEFAULT NULL,
    x_question_or_title IN VARCHAR2 DEFAULT NULL,
    x_ass_length_or_duration IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_exam_constraints IN VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE_CATEGORY IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE1         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE2         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE3         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE4         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE5         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE6         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE7         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE8         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE9         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE10        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE11        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE12        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE13        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE14        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE15        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE16        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE17        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE18        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE19        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE20        IN    VARCHAR2 DEFAULT NULL ,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    -- anilk, bug#2784198
    x_closed_ind IN VARCHAR2 DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_ASSESSMNT_ITM_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.org_id := x_org_id;
    new_references.ass_id := x_ass_id;
    new_references.assessment_type := x_assessment_type;
    new_references.description := x_description;
    new_references.exam_scheduled_ind := x_exam_scheduled_ind;
    new_references.exam_working_time := x_exam_working_time;
    new_references.exam_announcements := x_exam_announcements;
    new_references.exam_short_paper_name := x_exam_short_paper_name;
    new_references.exam_paper_name := x_exam_paper_name;
    new_references.exam_perusal_time := x_exam_perusal_time;
    new_references.exam_supervisor_instrctn := x_exam_supervisor_instrctn;
    new_references.exam_allowable_instrctn := x_exam_allowable_instrctn;
    new_references.exam_non_allowed_instrctn := x_exam_non_allowed_instrctn;
    new_references.exam_supplied_instrctn := x_exam_supplied_instrctn;
    new_references.question_or_title := x_question_or_title;
    new_references.ass_length_or_duration := x_ass_length_or_duration;
    new_references.comments := x_comments;
    new_references.exam_constraints := x_exam_constraints;
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
    -- anilk, bug#2784198
    new_references.closed_ind := x_closed_ind;


  END Set_Column_Values;

  -- Trigger description :-
  -- "OSS_TST".trg_ai_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_AS_ASSESSMNT_ITM
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
  v_message_name  varchar2(30);
  BEGIN
  -- Validate that inserts are allowed
  IF  p_inserting THEN
      -- <ai1>
      -- Validate assessment type closed indicator
      IF  IGS_AS_VAL_AI.assp_val_atyp_closed(new_references.assessment_type,
             v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
      END IF;
  END IF;
  -- Validate that inserts/updates are allowed
  IF  p_inserting OR p_updating THEN
      -- <ai2>
      -- Validate the approp. ass item details set and are not set for the
      -- respective assessment type examinable indicator setting
      IF  IGS_AS_VAL_AI.assp_val_ai_details(new_references.assessment_type,
            new_references.exam_scheduled_ind,
            new_references.exam_working_time,
            new_references.exam_announcements,
            new_references.exam_short_paper_name,
            new_references.exam_paper_name,
            new_references.exam_perusal_time,
            new_references.exam_supervisor_instrctn,
            new_references.exam_allowable_instrctn,
            new_references.exam_non_allowed_instrctn,
            new_references.exam_supplied_instrctn,
            new_references.question_or_title,
            new_references.ass_length_or_duration,
            v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
      END IF;
      -- <ai3>
      -- Validate exam times
      IF  IGS_AS_VAL_AI.assp_val_ai_ex_times(new_references.assessment_type,
             new_references.exam_working_time,
             new_references.exam_perusal_time,
             v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
      END IF;
  END IF;


  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_ai_ar_u
  -- AFTER UPDATE
  -- ON IGS_AS_ASSESSMNT_ITM
  -- FOR EACH ROW

  PROCEDURE AfterRowUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as

  v_message_name  varchar2(30);
  BEGIN
  IF  p_updating AND
    (new_references.ASSESSMENT_TYPE <> old_references.ASSESSMENT_TYPE) THEN
    -- Validate that p_updating the assessment type will not cause non-unique
    -- IGS_AS_UNITASS_ITEM.reference within a IGS_PS_UNIT offering pattern.
    -- Save row id as validation causes a mutating trigger.
                 IF IGS_AS_VAL_AI.assp_val_ai_type(
            new_references.ass_id,
            new_references.assessment_type,
            new_references.assessment_type,
            v_message_name) = FALSE THEN
        -- Error.
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
      END IF;


  END IF;


  END AfterRowUpdate2;

  -- Trigger description :-
  -- "OSS_TST".trg_ai_as_u
  -- AFTER UPDATE
  -- ON IGS_AS_ASSESSMNT_ITM



  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.assessment_type = new_references.assessment_type)) OR
        ((new_references.assessment_type IS NULL))) THEN
      NULL;
    ELSE
            IF NOT(IGS_AS_ASSESSMNT_TYP_PKG.Get_PK_For_Validation (
        new_references.assessment_type
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
      END IF;

    END IF;

  END Check_Parent_Existance;

PROCEDURE Check_Constraints (
Column_Name IN  VARCHAR2  DEFAULT NULL,
Column_Value  IN  VARCHAR2  DEFAULT NULL
  ) as
BEGIN
      IF  column_name is null then
         NULL;
      ELSIF upper(Column_name) = 'ASSESSMENT_TYPE' then
         new_references.assessment_type:= column_value;
      ELSIF upper(Column_name) = 'ASS_LENGTH_OR_DURATION' then
         new_references.ass_length_or_duration:= column_value;
      ELSIF upper(Column_name) = 'EXAM_SCHEDULED_IND' then
         new_references.exam_scheduled_ind:= column_value;
      END IF;
     IF upper(column_name) = 'ASSESSMENT_TYPE' OR
        column_name is null Then
        IF new_references.assessment_type <> UPPER(new_references.assessment_type) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF upper(column_name) = 'ASS_LENGTH_OR_DURATION' OR
        column_name is null Then
        IF new_references.ass_length_or_duration <> UPPER(new_references.ass_length_or_duration) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF upper(column_name) = 'EXAM_SCHEDULED_IND' OR
        column_name is null Then
        IF new_references.exam_scheduled_ind <> UPPER(new_references.exam_scheduled_ind) OR new_references.exam_scheduled_ind NOT IN ( 'Y' , 'N' ) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

END Check_Constraints;



  PROCEDURE Check_Child_Existance as
  BEGIN

    IGS_AS_COURSE_TYPE_PKG.GET_FK_IGS_AS_ASSESSMNT_ITM (
      old_references.ass_id
      );

    IGS_AS_ITEM_ASSESSOR_PKG.GET_FK_IGS_AS_ASSESSMNT_ITM (
      old_references.ass_id
      );

    IGS_AS_ITM_EXAM_MTRL_PKG.GET_FK_IGS_AS_ASSESSMNT_ITM (
      old_references.ass_id
      );

    IGS_AS_EXAM_INSTANCE_PKG.GET_FK_IGS_AS_ASSESSMNT_ITM (
      old_references.ass_id
      );

    IGS_AS_SU_ATMPT_ITM_PKG.GET_FK_IGS_AS_ASSESSMNT_ITM (
      old_references.ass_id
      );

    IGS_AS_UNITASS_ITEM_PKG.GET_FK_IGS_AS_ASSESSMNT_ITM (
      old_references.ass_id
      );

  END Check_Child_Existance;

  FUNCTION   Get_PK_For_Validation (
    x_ass_id IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_ASSESSMNT_ITM_ALL
      WHERE    ass_id = x_ass_id;

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

  PROCEDURE GET_FK_IGS_AS_ASSESSMNT_TYP (
    x_assessment_type IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_ASSESSMNT_ITM_ALL
      WHERE    assessment_type = x_assessment_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_AI_ATYP_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AS_ASSESSMNT_TYP;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_assessment_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_exam_scheduled_ind IN VARCHAR2 DEFAULT NULL,
    x_exam_working_time IN DATE DEFAULT NULL,
    x_exam_announcements IN VARCHAR2 DEFAULT NULL,
    x_exam_short_paper_name IN VARCHAR2 DEFAULT NULL,
    x_exam_paper_name IN VARCHAR2 DEFAULT NULL,
    x_exam_perusal_time IN DATE DEFAULT NULL,
    x_exam_supervisor_instrctn IN VARCHAR2 DEFAULT NULL,
    x_exam_allowable_instrctn IN VARCHAR2 DEFAULT NULL,
    x_exam_non_allowed_instrctn IN VARCHAR2 DEFAULT NULL,
    x_exam_supplied_instrctn IN VARCHAR2 DEFAULT NULL,
    x_question_or_title IN VARCHAR2 DEFAULT NULL,
    x_ass_length_or_duration IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_exam_constraints IN VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE_CATEGORY IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE1         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE2         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE3         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE4         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE5         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE6         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE7         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE8         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE9         IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE10        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE11        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE12        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE13        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE14        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE15        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE16        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE17        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE18        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE19        IN    VARCHAR2 DEFAULT NULL,
    x_ATTRIBUTE20        IN    VARCHAR2 DEFAULT NULL ,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    -- anilk, bug#2784198
    x_closed_ind IN VARCHAR2 DEFAULT NULL

  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_ass_id,
      x_assessment_type,
      x_description,
      x_exam_scheduled_ind,
      x_exam_working_time,
      x_exam_announcements,
      x_exam_short_paper_name,
      x_exam_paper_name,
      x_exam_perusal_time,
      x_exam_supervisor_instrctn,
      x_exam_allowable_instrctn,
      x_exam_non_allowed_instrctn,
      x_exam_supplied_instrctn,
      x_question_or_title,
      x_ass_length_or_duration,
      x_comments,
      x_exam_constraints,
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
      x_last_update_login,
      -- anilk, bug#2784198
      x_closed_ind

    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
IF  Get_PK_For_Validation (
             new_references.ass_id
       ) THEN
Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
IF  Get_PK_For_Validation (
             new_references.ass_id
       ) THEN
Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_ASSESSMENT_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXAM_SHORT_PAPER_NAME in VARCHAR2,
  X_EXAM_PAPER_NAME in VARCHAR2,
  X_EXAM_WORKING_TIME in DATE,
  X_EXAM_PERUSAL_TIME in DATE,
  X_EXAM_SCHEDULED_IND in VARCHAR2,
  X_EXAM_SUPERVISOR_INSTRCTN in VARCHAR2,
  X_EXAM_ANNOUNCEMENTS in VARCHAR2,
  X_EXAM_ALLOWABLE_INSTRCTN in VARCHAR2,
  X_EXAM_NON_ALLOWED_INSTRCTN in VARCHAR2,
  X_EXAM_SUPPLIED_INSTRCTN in VARCHAR2,
  X_EXAM_CONSTRAINTS in VARCHAR2,
  X_QUESTION_OR_TITLE in VARCHAR2,
  X_ASS_LENGTH_OR_DURATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  x_attribute_category IN VARCHAR2,
  x_attribute1 IN VARCHAR2,
  x_attribute2 IN VARCHAR2,
  x_attribute3 IN VARCHAR2,
  x_attribute4 IN VARCHAR2,
  x_attribute5 IN VARCHAR2,
  x_attribute6 IN VARCHAR2,
  x_attribute7 IN VARCHAR2,
  x_attribute8 IN VARCHAR2,
  x_attribute9 IN VARCHAR2,
  x_attribute10 IN VARCHAR2,
  x_attribute11 IN VARCHAR2,
  x_attribute12 IN VARCHAR2,
  x_attribute13 IN VARCHAR2,
  x_attribute14 IN VARCHAR2,
  x_attribute15 IN VARCHAR2,
  x_attribute16 IN VARCHAR2,
  x_attribute17 IN VARCHAR2,
  x_attribute18 IN VARCHAR2,
  x_attribute19 IN VARCHAR2,
  x_attribute20 IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  -- anilk, bug#2784198
  x_closed_ind IN VARCHAR2
  ) as
    cursor C is select ROWID from IGS_AS_ASSESSMNT_ITM_all
      where ASS_ID = X_ASS_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
 x_org_id => igs_ge_gen_003.get_org_id,
 x_ass_id=>X_ASS_ID,
 x_ass_length_or_duration=>X_ASS_LENGTH_OR_DURATION,
 x_assessment_type=>X_ASSESSMENT_TYPE,
 x_comments=>X_COMMENTS,
 x_description=>X_DESCRIPTION,
 x_exam_allowable_instrctn=>X_EXAM_ALLOWABLE_INSTRCTN,
 x_exam_announcements=>X_EXAM_ANNOUNCEMENTS,
 x_exam_constraints=>X_EXAM_CONSTRAINTS,
 x_exam_non_allowed_instrctn=>X_EXAM_NON_ALLOWED_INSTRCTN,
 x_exam_paper_name=>X_EXAM_PAPER_NAME,
 x_exam_perusal_time=>X_EXAM_PERUSAL_TIME,
 x_exam_scheduled_ind=>X_EXAM_SCHEDULED_IND,
 x_exam_short_paper_name=>X_EXAM_SHORT_PAPER_NAME,
 x_exam_supervisor_instrctn=>X_EXAM_SUPERVISOR_INSTRCTN,
 x_exam_supplied_instrctn=>X_EXAM_SUPPLIED_INSTRCTN,
 x_exam_working_time=>X_EXAM_WORKING_TIME,
 x_question_or_title=>X_QUESTION_OR_TITLE,
 x_attribute_category=>x_attribute_category,
 x_attribute1=>x_attribute1,
 x_attribute2=>x_attribute2,
 x_attribute3=>x_attribute3,
 x_attribute4=>x_attribute4,
 x_attribute5=>x_attribute5,
 x_attribute6=>x_attribute6,
 x_attribute7=>x_attribute7,
 x_attribute8=>x_attribute8,
 x_attribute9=>x_attribute9,
 x_attribute10=>x_attribute10,
 x_attribute11=>x_attribute11,
 x_attribute12=>x_attribute12,
 x_attribute13=>x_attribute13,
 x_attribute14=>x_attribute14,
 x_attribute15=>x_attribute15,
 x_attribute16=>x_attribute16,
 x_attribute17=>x_attribute17,
 x_attribute18=>x_attribute18,
 x_attribute19=>x_attribute19,
 x_attribute20=>x_attribute20,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 -- anilk, bug#2784198
 x_closed_ind => x_closed_ind

 );
  insert into IGS_AS_ASSESSMNT_ITM_ALL (
     ORG_ID,
    ASS_ID,
    ASSESSMENT_TYPE,
    DESCRIPTION,
    EXAM_SHORT_PAPER_NAME,
    EXAM_PAPER_NAME,
    EXAM_WORKING_TIME,
    EXAM_PERUSAL_TIME,
    EXAM_SCHEDULED_IND,
    EXAM_SUPERVISOR_INSTRCTN,
    EXAM_ANNOUNCEMENTS,
    EXAM_ALLOWABLE_INSTRCTN,
    EXAM_NON_ALLOWED_INSTRCTN,
    EXAM_SUPPLIED_INSTRCTN,
    EXAM_CONSTRAINTS,
    QUESTION_OR_TITLE,
    ASS_LENGTH_OR_DURATION,
    COMMENTS,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute16,
    attribute17,
    attribute18,
    attribute19,
    attribute20,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    -- anilk, bug#2784198
    closed_ind
  ) values (
     NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.ASS_ID,
    NEW_REFERENCES.ASSESSMENT_TYPE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.EXAM_SHORT_PAPER_NAME,
    NEW_REFERENCES.EXAM_PAPER_NAME,
    NEW_REFERENCES.EXAM_WORKING_TIME,
    NEW_REFERENCES.EXAM_PERUSAL_TIME,
    NEW_REFERENCES.EXAM_SCHEDULED_IND,
    NEW_REFERENCES.EXAM_SUPERVISOR_INSTRCTN,
    NEW_REFERENCES.EXAM_ANNOUNCEMENTS,
    NEW_REFERENCES.EXAM_ALLOWABLE_INSTRCTN,
    NEW_REFERENCES.EXAM_NON_ALLOWED_INSTRCTN,
    NEW_REFERENCES.EXAM_SUPPLIED_INSTRCTN,
    NEW_REFERENCES.EXAM_CONSTRAINTS,
    NEW_REFERENCES.QUESTION_OR_TITLE,
    NEW_REFERENCES.ASS_LENGTH_OR_DURATION,
    NEW_REFERENCES.COMMENTS,
    new_references.attribute_category,
    new_references.attribute1,
    new_references.attribute2,
    new_references.attribute3,
    new_references.attribute4,
    new_references.attribute5,
    new_references.attribute6,
    new_references.attribute7,
    new_references.attribute8,
    new_references.attribute9,
    new_references.attribute10,
    new_references.attribute11,
    new_references.attribute12,
    new_references.attribute13,
    new_references.attribute14,
    new_references.attribute15,
    new_references.attribute16,
    new_references.attribute17,
    new_references.attribute18,
    new_references.attribute19,
    new_references.attribute20,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    -- anilk, bug#2784198
    new_references.closed_ind
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
  X_ASS_ID in NUMBER,
  X_ASSESSMENT_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXAM_SHORT_PAPER_NAME in VARCHAR2,
  X_EXAM_PAPER_NAME in VARCHAR2,
  X_EXAM_WORKING_TIME in DATE,
  X_EXAM_PERUSAL_TIME in DATE,
  X_EXAM_SCHEDULED_IND in VARCHAR2,
  X_EXAM_SUPERVISOR_INSTRCTN in VARCHAR2,
  X_EXAM_ANNOUNCEMENTS in VARCHAR2,
  X_EXAM_ALLOWABLE_INSTRCTN in VARCHAR2,
  X_EXAM_NON_ALLOWED_INSTRCTN in VARCHAR2,
  X_EXAM_SUPPLIED_INSTRCTN in VARCHAR2,
  X_EXAM_CONSTRAINTS in VARCHAR2,
  X_QUESTION_OR_TITLE in VARCHAR2,
  X_ASS_LENGTH_OR_DURATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  x_attribute_category IN VARCHAR2,
  x_attribute1 IN VARCHAR2,
  x_attribute2 IN VARCHAR2,
  x_attribute3 IN VARCHAR2,
  x_attribute4 IN VARCHAR2,
  x_attribute5 IN VARCHAR2,
  x_attribute6 IN VARCHAR2,
  x_attribute7 IN VARCHAR2,
  x_attribute8 IN VARCHAR2,
  x_attribute9 IN VARCHAR2,
  x_attribute10 IN VARCHAR2,
  x_attribute11 IN VARCHAR2,
  x_attribute12 IN VARCHAR2,
  x_attribute13 IN VARCHAR2,
  x_attribute14 IN VARCHAR2,
  x_attribute15 IN VARCHAR2,
  x_attribute16 IN VARCHAR2,
  x_attribute17 IN VARCHAR2,
  x_attribute18 IN VARCHAR2,
  x_attribute19 IN VARCHAR2,
  x_attribute20 IN VARCHAR2,
  -- anilk, bug#2784198
  x_closed_ind IN VARCHAR2
) as
  cursor c1 is select
      ASSESSMENT_TYPE,
      DESCRIPTION,
      EXAM_SHORT_PAPER_NAME,
      EXAM_PAPER_NAME,
      EXAM_WORKING_TIME,
      EXAM_PERUSAL_TIME,
      EXAM_SCHEDULED_IND,
      EXAM_SUPERVISOR_INSTRCTN,
      EXAM_ANNOUNCEMENTS,
      EXAM_ALLOWABLE_INSTRCTN,
      EXAM_NON_ALLOWED_INSTRCTN,
      EXAM_SUPPLIED_INSTRCTN,
      EXAM_CONSTRAINTS,
      QUESTION_OR_TITLE,
      ASS_LENGTH_OR_DURATION,
      COMMENTS,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      -- anilk, bug#2784198
      closed_ind
    from IGS_AS_ASSESSMNT_ITM_ALL

    where ROWID = X_ROWID  for update  nowait;
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

  if ( (tlinfo.ASSESSMENT_TYPE = X_ASSESSMENT_TYPE)
      AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND ((tlinfo.EXAM_SHORT_PAPER_NAME = X_EXAM_SHORT_PAPER_NAME)
           OR ((tlinfo.EXAM_SHORT_PAPER_NAME is null)
               AND (X_EXAM_SHORT_PAPER_NAME is null)))
      AND ((tlinfo.EXAM_PAPER_NAME = X_EXAM_PAPER_NAME)
           OR ((tlinfo.EXAM_PAPER_NAME is null)
               AND (X_EXAM_PAPER_NAME is null)))
      AND ((tlinfo.EXAM_WORKING_TIME = X_EXAM_WORKING_TIME)
           OR ((tlinfo.EXAM_WORKING_TIME is null)
               AND (X_EXAM_WORKING_TIME is null)))
      AND ((tlinfo.EXAM_PERUSAL_TIME = X_EXAM_PERUSAL_TIME)
           OR ((tlinfo.EXAM_PERUSAL_TIME is null)
               AND (X_EXAM_PERUSAL_TIME is null)))
      AND (tlinfo.EXAM_SCHEDULED_IND = X_EXAM_SCHEDULED_IND)
      AND ((tlinfo.EXAM_SUPERVISOR_INSTRCTN = X_EXAM_SUPERVISOR_INSTRCTN)
           OR ((tlinfo.EXAM_SUPERVISOR_INSTRCTN is null)
               AND (X_EXAM_SUPERVISOR_INSTRCTN is null)))
      AND ((tlinfo.EXAM_ANNOUNCEMENTS = X_EXAM_ANNOUNCEMENTS)
           OR ((tlinfo.EXAM_ANNOUNCEMENTS is null)
               AND (X_EXAM_ANNOUNCEMENTS is null)))
      AND ((tlinfo.EXAM_ALLOWABLE_INSTRCTN = X_EXAM_ALLOWABLE_INSTRCTN)
           OR ((tlinfo.EXAM_ALLOWABLE_INSTRCTN is null)
               AND (X_EXAM_ALLOWABLE_INSTRCTN is null)))
      AND ((tlinfo.EXAM_NON_ALLOWED_INSTRCTN = X_EXAM_NON_ALLOWED_INSTRCTN)
           OR ((tlinfo.EXAM_NON_ALLOWED_INSTRCTN is null)
               AND (X_EXAM_NON_ALLOWED_INSTRCTN is null)))
      AND ((tlinfo.EXAM_SUPPLIED_INSTRCTN = X_EXAM_SUPPLIED_INSTRCTN)
           OR ((tlinfo.EXAM_SUPPLIED_INSTRCTN is null)
               AND (X_EXAM_SUPPLIED_INSTRCTN is null)))
      AND ((tlinfo.EXAM_CONSTRAINTS = X_EXAM_CONSTRAINTS)
           OR ((tlinfo.EXAM_CONSTRAINTS is null)
               AND (X_EXAM_CONSTRAINTS is null)))
      AND ((tlinfo.QUESTION_OR_TITLE = X_QUESTION_OR_TITLE)
           OR ((tlinfo.QUESTION_OR_TITLE is null)
               AND (X_QUESTION_OR_TITLE is null)))
      AND ((tlinfo.ASS_LENGTH_OR_DURATION = X_ASS_LENGTH_OR_DURATION)
           OR ((tlinfo.ASS_LENGTH_OR_DURATION is null)
               AND (X_ASS_LENGTH_OR_DURATION is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
      AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (x_attribute_category IS NULL)))
      AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (x_attribute1 IS NULL)))
      AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (x_attribute2 IS NULL)))
      AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (x_attribute3 IS NULL)))
      AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (x_attribute4 IS NULL)))
      AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (x_attribute5 IS NULL)))
      AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (x_attribute6 IS NULL)))
      AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (x_attribute7 IS NULL)))
      AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (x_attribute8 IS NULL)))
      AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (x_attribute9 IS NULL)))
      AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (x_attribute10 IS NULL)))
      AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (x_attribute11 IS NULL)))
      AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (x_attribute12 IS NULL)))
      AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (x_attribute13 IS NULL)))
      AND ((tlinfo.attribute14 = x_attribute14)  OR ((tlinfo.attribute14 IS NULL) AND (x_attribute14 IS NULL)))
      AND ((tlinfo.attribute15 = x_attribute15)  OR ((tlinfo.attribute15 IS NULL) AND (x_attribute15 IS NULL)))
      AND ((tlinfo.attribute16 = x_attribute16)  OR ((tlinfo.attribute16 IS NULL) AND (x_attribute16 IS NULL)))
      AND ((tlinfo.attribute17 = x_attribute17)  OR ((tlinfo.attribute17 IS NULL) AND (x_attribute17 IS NULL)))
      AND ((tlinfo.attribute18 = x_attribute18)  OR ((tlinfo.attribute18 IS NULL) AND (x_attribute18 IS NULL)))
      AND ((tlinfo.attribute19 = x_attribute19)  OR ((tlinfo.attribute19 IS NULL) AND (x_attribute19 IS NULL)))
      AND ((tlinfo.attribute20 = x_attribute20)  OR ((tlinfo.attribute20 IS NULL) AND (x_attribute20 IS NULL)))

      -- anilk, bug#2784198
      AND ((tlinfo.closed_ind = x_closed_ind)
           OR ((tlinfo.closed_ind IS NULL)
               AND (x_closed_ind IS NULL)))

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in  VARCHAR2,
  X_ASS_ID in NUMBER,
  X_ASSESSMENT_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXAM_SHORT_PAPER_NAME in VARCHAR2,
  X_EXAM_PAPER_NAME in VARCHAR2,
  X_EXAM_WORKING_TIME in DATE,
  X_EXAM_PERUSAL_TIME in DATE,
  X_EXAM_SCHEDULED_IND in VARCHAR2,
  X_EXAM_SUPERVISOR_INSTRCTN in VARCHAR2,
  X_EXAM_ANNOUNCEMENTS in VARCHAR2,
  X_EXAM_ALLOWABLE_INSTRCTN in VARCHAR2,
  X_EXAM_NON_ALLOWED_INSTRCTN in VARCHAR2,
  X_EXAM_SUPPLIED_INSTRCTN in VARCHAR2,
  X_EXAM_CONSTRAINTS in VARCHAR2,
  X_QUESTION_OR_TITLE in VARCHAR2,
  X_ASS_LENGTH_OR_DURATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  x_attribute_category IN VARCHAR2,
  x_attribute1 IN VARCHAR2,
  x_attribute2 IN VARCHAR2,
  x_attribute3 IN VARCHAR2,
  x_attribute4 IN VARCHAR2,
  x_attribute5 IN VARCHAR2,
  x_attribute6 IN VARCHAR2,
  x_attribute7 IN VARCHAR2,
  x_attribute8 IN VARCHAR2,
  x_attribute9 IN VARCHAR2,
  x_attribute10 IN VARCHAR2,
  x_attribute11 IN VARCHAR2,
  x_attribute12 IN VARCHAR2,
  x_attribute13 IN VARCHAR2,
  x_attribute14 IN VARCHAR2,
  x_attribute15 IN VARCHAR2,
  x_attribute16 IN VARCHAR2,
  x_attribute17 IN VARCHAR2,
  x_attribute18 IN VARCHAR2,
  x_attribute19 IN VARCHAR2,
  x_attribute20 IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  -- anilk, bug#2784198
  x_closed_ind IN VARCHAR2
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_ass_id=>X_ASS_ID,
 x_ass_length_or_duration=>X_ASS_LENGTH_OR_DURATION,
 x_assessment_type=>X_ASSESSMENT_TYPE,
 x_comments=>X_COMMENTS,
 x_description=>X_DESCRIPTION,
 x_exam_allowable_instrctn=>X_EXAM_ALLOWABLE_INSTRCTN,
 x_exam_announcements=>X_EXAM_ANNOUNCEMENTS,
 x_exam_constraints=>X_EXAM_CONSTRAINTS,
 x_exam_non_allowed_instrctn=>X_EXAM_NON_ALLOWED_INSTRCTN,
 x_exam_paper_name=>X_EXAM_PAPER_NAME,
 x_exam_perusal_time=>X_EXAM_PERUSAL_TIME,
 x_exam_scheduled_ind=>X_EXAM_SCHEDULED_IND,
 x_exam_short_paper_name=>X_EXAM_SHORT_PAPER_NAME,
 x_exam_supervisor_instrctn=>X_EXAM_SUPERVISOR_INSTRCTN,
 x_exam_supplied_instrctn=>X_EXAM_SUPPLIED_INSTRCTN,
 x_exam_working_time=>X_EXAM_WORKING_TIME,
  x_attribute_category=>x_attribute_category,
 x_attribute1=>x_attribute1,
 x_attribute2=>x_attribute2,
 x_attribute3=>x_attribute3,
 x_attribute4=>x_attribute4,
 x_attribute5=>x_attribute5,
 x_attribute6=>x_attribute6,
 x_attribute7=>x_attribute7,
 x_attribute8=>x_attribute8,
 x_attribute9=>x_attribute9,
 x_attribute10=>x_attribute10,
 x_attribute11=>x_attribute11,
 x_attribute12=>x_attribute12,
 x_attribute13=>x_attribute13,
 x_attribute14=>x_attribute14,
 x_attribute15=>x_attribute15,
 x_attribute16=>x_attribute16,
 x_attribute17=>x_attribute17,
 x_attribute18=>x_attribute18,
 x_attribute19=>x_attribute19,
 x_attribute20=>x_attribute20,
 x_question_or_title=>X_QUESTION_OR_TITLE,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 -- anilk, bug#2784198
 x_closed_ind => x_closed_ind
 );

  update IGS_AS_ASSESSMNT_ITM_ALL set
    ASSESSMENT_TYPE = NEW_REFERENCES.ASSESSMENT_TYPE,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    EXAM_SHORT_PAPER_NAME = NEW_REFERENCES.EXAM_SHORT_PAPER_NAME,
    EXAM_PAPER_NAME = NEW_REFERENCES.EXAM_PAPER_NAME,
    EXAM_WORKING_TIME = NEW_REFERENCES.EXAM_WORKING_TIME,
    EXAM_PERUSAL_TIME = NEW_REFERENCES.EXAM_PERUSAL_TIME,
    EXAM_SCHEDULED_IND = NEW_REFERENCES.EXAM_SCHEDULED_IND,
    EXAM_SUPERVISOR_INSTRCTN = NEW_REFERENCES.EXAM_SUPERVISOR_INSTRCTN,
    EXAM_ANNOUNCEMENTS = NEW_REFERENCES.EXAM_ANNOUNCEMENTS,
    EXAM_ALLOWABLE_INSTRCTN = NEW_REFERENCES.EXAM_ALLOWABLE_INSTRCTN,
    EXAM_NON_ALLOWED_INSTRCTN = NEW_REFERENCES.EXAM_NON_ALLOWED_INSTRCTN,
    EXAM_SUPPLIED_INSTRCTN = NEW_REFERENCES.EXAM_SUPPLIED_INSTRCTN,
    EXAM_CONSTRAINTS = NEW_REFERENCES.EXAM_CONSTRAINTS,
    QUESTION_OR_TITLE = NEW_REFERENCES.QUESTION_OR_TITLE,
    ASS_LENGTH_OR_DURATION = NEW_REFERENCES.ASS_LENGTH_OR_DURATION,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    attribute_category =  new_references.attribute_category,
    attribute1 =  new_references.attribute1,
    attribute2 =  new_references.attribute2,
    attribute3 =  new_references.attribute3,
    attribute4 =  new_references.attribute4,
    attribute5 =  new_references.attribute5,
    attribute6 =  new_references.attribute6,
    attribute7 =  new_references.attribute7,
    attribute8 =  new_references.attribute8,
    attribute9 =  new_references.attribute9,
    attribute10 =  new_references.attribute10,
    attribute11 =  new_references.attribute11,
    attribute12 =  new_references.attribute12,
    attribute13 =  new_references.attribute13,
    attribute14 =  new_references.attribute14,
    attribute15 =  new_references.attribute15,
    attribute16 =  new_references.attribute16,
    attribute17 =  new_references.attribute17,
    attribute18 =  new_references.attribute18,
    attribute19 =  new_references.attribute19,
    attribute20 =  new_references.attribute20,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    -- anilk, bug#2784198
    closed_ind = new_references.closed_ind
  where ROWID = X_ROWID;
    if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_ASSESSMENT_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXAM_SHORT_PAPER_NAME in VARCHAR2,
  X_EXAM_PAPER_NAME in VARCHAR2,
  X_EXAM_WORKING_TIME in DATE,
  X_EXAM_PERUSAL_TIME in DATE,
  X_EXAM_SCHEDULED_IND in VARCHAR2,
  X_EXAM_SUPERVISOR_INSTRCTN in VARCHAR2,
  X_EXAM_ANNOUNCEMENTS in VARCHAR2,
  X_EXAM_ALLOWABLE_INSTRCTN in VARCHAR2,
  X_EXAM_NON_ALLOWED_INSTRCTN in VARCHAR2,
  X_EXAM_SUPPLIED_INSTRCTN in VARCHAR2,
  X_EXAM_CONSTRAINTS in VARCHAR2,
  X_QUESTION_OR_TITLE in VARCHAR2,
  X_ASS_LENGTH_OR_DURATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  x_attribute_category IN VARCHAR2,
  x_attribute1 IN VARCHAR2,
  x_attribute2 IN VARCHAR2,
  x_attribute3 IN VARCHAR2,
  x_attribute4 IN VARCHAR2,
  x_attribute5 IN VARCHAR2,
  x_attribute6 IN VARCHAR2,
  x_attribute7 IN VARCHAR2,
  x_attribute8 IN VARCHAR2,
  x_attribute9 IN VARCHAR2,
  x_attribute10 IN VARCHAR2,
  x_attribute11 IN VARCHAR2,
  x_attribute12 IN VARCHAR2,
  x_attribute13 IN VARCHAR2,
  x_attribute14 IN VARCHAR2,
  x_attribute15 IN VARCHAR2,
  x_attribute16 IN VARCHAR2,
  x_attribute17 IN VARCHAR2,
  x_attribute18 IN VARCHAR2,
  x_attribute19 IN VARCHAR2,
  x_attribute20 IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  -- anilk, bug#2784198
  x_closed_ind IN VARCHAR2
  ) as
  cursor c1 is select rowid from IGS_AS_ASSESSMNT_ITM_ALL
     where ASS_ID = X_ASS_ID
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_ASS_ID,
     X_ASSESSMENT_TYPE,
     X_DESCRIPTION,
     X_EXAM_SHORT_PAPER_NAME,
     X_EXAM_PAPER_NAME,
     X_EXAM_WORKING_TIME,
     X_EXAM_PERUSAL_TIME,
     X_EXAM_SCHEDULED_IND,
     X_EXAM_SUPERVISOR_INSTRCTN,
     X_EXAM_ANNOUNCEMENTS,
     X_EXAM_ALLOWABLE_INSTRCTN,
     X_EXAM_NON_ALLOWED_INSTRCTN,
     X_EXAM_SUPPLIED_INSTRCTN,
     X_EXAM_CONSTRAINTS,
     X_QUESTION_OR_TITLE,
     X_ASS_LENGTH_OR_DURATION,
     X_COMMENTS,
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
     X_MODE,
     -- anilk, bug#2784198
     x_closed_ind
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ASS_ID,
   X_ASSESSMENT_TYPE,
   X_DESCRIPTION,
   X_EXAM_SHORT_PAPER_NAME,
   X_EXAM_PAPER_NAME,
   X_EXAM_WORKING_TIME,
   X_EXAM_PERUSAL_TIME,
   X_EXAM_SCHEDULED_IND,
   X_EXAM_SUPERVISOR_INSTRCTN,
   X_EXAM_ANNOUNCEMENTS,
   X_EXAM_ALLOWABLE_INSTRCTN,
   X_EXAM_NON_ALLOWED_INSTRCTN,
   X_EXAM_SUPPLIED_INSTRCTN,
   X_EXAM_CONSTRAINTS,
   X_QUESTION_OR_TITLE,
   X_ASS_LENGTH_OR_DURATION,
   X_COMMENTS,
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
   X_MODE,
   -- anilk, bug#2784198
   x_closed_ind
   );
end ADD_ROW;

end IGS_AS_ASSESSMNT_ITM_PKG;

/
