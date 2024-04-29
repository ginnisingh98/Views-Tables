--------------------------------------------------------
--  DDL for Package Body IGS_EN_SU_ATTEMPT_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SU_ATTEMPT_H_PKG" AS
/* $Header: IGSEI37B.pls 120.1 2006/05/10 00:27:48 bdeviset noship $ */

l_rowid VARCHAR2(25);
  old_references IGS_EN_SU_ATTEMPT_H_ALL%RowType;
  new_references IGS_EN_SU_ATTEMPT_H_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_enrolled_dt IN DATE DEFAULT NULL,
    x_unit_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_aus_description IN VARCHAR2 DEFAULT NULL,
    x_discontinued_dt IN DATE DEFAULT NULL,
    x_rule_waived_dt IN DATE DEFAULT NULL,
    x_rule_waived_person_id IN NUMBER DEFAULT NULL,
    x_no_assessment_ind IN VARCHAR2 DEFAULT NULL,
    x_exam_location_cd IN VARCHAR2 DEFAULT NULL,
    x_elo_description IN VARCHAR2 DEFAULT NULL,
    x_sup_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_sup_version_number IN NUMBER DEFAULT NULL,
    x_alternative_title IN VARCHAR2 DEFAULT NULL,
    x_override_enrolled_cp IN NUMBER DEFAULT NULL,
    x_override_eftsu IN NUMBER DEFAULT NULL,
    x_override_achievable_cp IN NUMBER DEFAULT NULL,
    x_override_outcome_due_dt IN DATE DEFAULT NULL,
    x_override_credit_reason IN VARCHAR2 DEFAULT NULL,
    x_dcnt_reason_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_grading_schema_code IN VARCHAR2 DEFAULT NULL,
    x_enr_method_type IN VARCHAR2 DEFAULT NULL,
    x_administrative_priority   IN NUMBER DEFAULT NULL,
    x_waitlist_dt               IN DATE DEFAULT NULL,
    x_request_id                IN NUMBER DEFAULT NULL,
    x_program_application_id    IN NUMBER DEFAULT NULL,
    x_program_id                IN NUMBER DEFAULT NULL,
    x_program_update_date       IN DATE DEFAULT NULL,
    x_cart                      IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd               IN VARCHAR2 DEFAULT NULL,
    x_rsv_seat_ext_id           IN NUMBER DEFAULT NULL,
    x_gs_version_number         IN NUMBER DEFAULT NULL,
    x_failed_unit_rule          IN VARCHAR2 DEFAULT NULL,
    x_deg_aud_detail_id         IN NUMBER DEFAULT NULL,
    x_uoo_id                IN NUMBER DEFAULT NULL,
    x_core_indicator_code            IN VARCHAR2 DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_SU_ATTEMPT_H_ALL
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
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.location_cd := x_location_cd;
    new_references.unit_class := x_unit_class;
    new_references.enrolled_dt := x_enrolled_dt;
    new_references.unit_attempt_status := x_unit_attempt_status;
    new_references.administrative_unit_status := x_administrative_unit_status;
    new_references.aus_description := x_aus_description;
    new_references.discontinued_dt := x_discontinued_dt;
    new_references.rule_waived_dt := x_rule_waived_dt;
    new_references.rule_waived_person_id := x_rule_waived_person_id;
    new_references.no_assessment_ind := x_no_assessment_ind;
    new_references.exam_location_cd := x_exam_location_cd;
    new_references.elo_description := x_elo_description;
    new_references.sup_unit_cd := x_sup_unit_cd;
    new_references.sup_version_number := x_sup_version_number;
    new_references.alternative_title := x_alternative_title;
    new_references.override_enrolled_cp := x_override_enrolled_cp;
    new_references.override_eftsu := x_override_eftsu;
    new_references.override_achievable_cp := x_override_achievable_cp;
    new_references.override_outcome_due_dt := x_override_outcome_due_dt;
    new_references.override_credit_reason := x_override_credit_reason;
    new_references.uoo_id := x_uoo_id;
    /* enhancement */
    new_references.dcnt_reason_cd := x_dcnt_reason_cd;
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
    new_references.org_id := x_org_id;
    new_references.grading_schema_code:=x_grading_schema_code;
    new_references.enr_method_type:=x_enr_method_type;
    new_references.administrative_priority  :=  x_administrative_priority;
    new_references.waitlist_dt              :=  x_waitlist_dt;
    new_references.request_id               :=  x_request_id;
    new_references.program_application_id   :=  x_program_application_id;
    new_references.program_id               :=  x_program_id;
    new_references.program_update_date      :=  x_program_update_date;
    new_references.cart                     :=  x_cart;
    new_references.org_unit_cd              :=  x_org_unit_cd;
    new_references.rsv_seat_ext_id          :=  x_rsv_seat_ext_id;
    new_references.gs_version_number        :=  x_gs_version_number;
    new_references.failed_unit_rule         :=  x_failed_unit_rule;
    new_references.deg_aud_detail_id        :=  x_deg_aud_detail_id;
    new_references.core_indicator_code      :=  x_core_indicator_code;

  END Set_Column_Values;

  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_EN_STDNT_PS_ATT_Pkg.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd
        )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL) OR
         (new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_EN_SU_ATTEMPT_Pkg.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd,
        new_references.uoo_id
        )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;


  END Check_Parent_Existance;
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    29-APR-03    changed the PK columns as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------
  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_hist_start_dt IN DATE,
    x_uoo_id IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_SU_ATTEMPT_H_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      hist_start_dt = x_hist_start_dt
      AND      uoo_id = x_uoo_id
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
  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_SU_ATTEMPT_H_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUAH_SCA_FK');
IGS_GE_MSG_STACK.ADD;
          Close cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_STDNT_PS_ATT;

PROCEDURE GET_FK_IGS_EN_SU_ATTEMPT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_uoo_id IN NUMBER
     ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_SU_ATTEMPT_H_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      uoo_id = x_uoo_id;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_SUT_SUA_TRANSFER_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_SU_ATTEMPT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_enrolled_dt IN DATE DEFAULT NULL,
    x_unit_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_aus_description IN VARCHAR2 DEFAULT NULL,
    x_discontinued_dt IN DATE DEFAULT NULL,
    x_rule_waived_dt IN DATE DEFAULT NULL,
    x_rule_waived_person_id IN NUMBER DEFAULT NULL,
    x_no_assessment_ind IN VARCHAR2 DEFAULT NULL,
    x_exam_location_cd IN VARCHAR2 DEFAULT NULL,
    x_elo_description IN VARCHAR2 DEFAULT NULL,
    x_sup_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_sup_version_number IN NUMBER DEFAULT NULL,
    x_alternative_title IN VARCHAR2 DEFAULT NULL,
    x_override_enrolled_cp IN NUMBER DEFAULT NULL,
    x_override_eftsu IN NUMBER DEFAULT NULL,
    x_override_achievable_cp IN NUMBER DEFAULT NULL,
    x_override_outcome_due_dt IN DATE DEFAULT NULL,
    x_override_credit_reason IN VARCHAR2 DEFAULT NULL,
    x_dcnt_reason_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_grading_schema_code IN VARCHAR2 DEFAULT NULL,
    x_enr_method_type IN VARCHAR2 DEFAULT NULL,
    x_administrative_priority   IN NUMBER DEFAULT NULL,
    x_waitlist_dt               IN DATE DEFAULT NULL,
    x_request_id                IN NUMBER DEFAULT NULL,
    x_program_application_id    IN NUMBER DEFAULT NULL,
    x_program_id                IN NUMBER DEFAULT NULL,
    x_program_update_date       IN DATE DEFAULT NULL,
    x_cart                      IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd               IN VARCHAR2 DEFAULT NULL,
    x_rsv_seat_ext_id           IN NUMBER DEFAULT NULL,
    x_gs_version_number         IN NUMBER DEFAULT NULL,
    x_failed_unit_rule          IN VARCHAR2 DEFAULT NULL,
    x_deg_aud_detail_id         IN NUMBER DEFAULT NULL,
    x_uoo_id                IN NUMBER DEFAULT NULL,
    x_core_indicator_code IN VARCHAR2 DEFAULT NULL
  ) AS

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --bdeviset    22-Mar-2005  Whenver history record is created for waitlisted status the history start date
  --                         is set to the history end date of the history record having unit attempt status
  --                         as unconfirmed.Bug# 4253954
  --bdeviset    05-MAY-2006  Modified for bug# 5208930
  -------------------------------------------------------------------------------------------

  CURSOR c_hist_end_dt(cp_person_id IN NUMBER,
                       cp_course_cd IN VARCHAR2,
                       cp_uoo_id IN NUMBER) IS
    SELECT HIST_END_DT
    FROM IGS_EN_SU_ATTEMPT_H_ALL
    WHERE person_id = cp_person_id
    AND course_cd = cp_course_cd
    AND uoo_id = cp_uoo_id
    ORDER BY HIST_END_DT DESC
    FOR UPDATE;

    l_hist_end_dt IGS_EN_SU_ATTEMPT_H_ALL.hist_end_dt%TYPE;

  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_location_cd,
      x_unit_class,
      x_enrolled_dt,
      x_unit_attempt_status,
      x_administrative_unit_status,
      x_aus_description,
      x_discontinued_dt,
      x_rule_waived_dt,
      x_rule_waived_person_id,
      x_no_assessment_ind,
      x_exam_location_cd,
      x_elo_description,
      x_sup_unit_cd,
      x_sup_version_number,
      x_alternative_title,
      x_override_enrolled_cp,
      x_override_eftsu,
      x_override_achievable_cp,
      x_override_outcome_due_dt,
      x_override_credit_reason,
      x_dcnt_reason_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id ,
      x_grading_schema_code,
      x_enr_method_type,
      x_administrative_priority,
      x_waitlist_dt,
      x_request_id,
      x_program_application_id  ,
      x_program_id,
      x_program_update_date,
      x_cart,
      x_org_unit_cd,
      x_rsv_seat_ext_id ,
      x_gs_version_number,
      x_failed_unit_rule,
      x_deg_aud_detail_id,
      x_uoo_id,
      x_core_indicator_code
    );
    IF (p_action = 'INSERT') THEN


       OPEN c_hist_end_dt(NEW_REFERENCES.person_id,
                           NEW_REFERENCES.course_cd ,
                           NEW_REFERENCES.uoo_id);
        FETCH c_hist_end_dt INTO l_hist_end_dt;

        IF  c_hist_end_dt%FOUND THEN
					NEW_REFERENCES.hist_start_dt := l_hist_end_dt;
          IF (NEW_REFERENCES.hist_start_dt = NEW_REFERENCES.hist_end_dt) THEN
                NEW_REFERENCES.hist_start_dt := NEW_REFERENCES.hist_start_dt - 1/(60*24*60);
          END IF;
        END IF;
        CLOSE c_hist_end_dt;

      -- Call all the procedures related to Before Insert.

        IF  Get_PK_For_Validation (
         NEW_REFERENCES.person_id,
    NEW_REFERENCES.course_cd ,
    NEW_REFERENCES.hist_start_dt,
    NEW_REFERENCES.uoo_id ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
                 APP_EXCEPTION.RAISE_EXCEPTION;
             END IF;

             Check_Constraints;

      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.


     Check_Constraints;
      Check_Parent_Existance;

        ELSIF (p_action = 'VALIDATE_INSERT') THEN
             IF  Get_PK_For_Validation (
                 NEW_REFERENCES.person_id,
    NEW_REFERENCES.course_cd,
    NEW_REFERENCES.hist_start_dt ,
    NEW_REFERENCES.uoo_id
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_ELO_DESCRIPTION in VARCHAR2,
  X_SUP_UNIT_CD in VARCHAR2,
  X_SUP_VERSION_NUMBER in NUMBER,
  X_ALTERNATIVE_TITLE in VARCHAR2,
  X_OVERRIDE_ENROLLED_CP in NUMBER,
  X_OVERRIDE_EFTSU in NUMBER,
  X_OVERRIDE_ACHIEVABLE_CP in NUMBER,
  X_OVERRIDE_OUTCOME_DUE_DT in DATE,
  X_OVERRIDE_CREDIT_REASON in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_AUS_DESCRIPTION in VARCHAR2,
  X_DISCONTINUED_DT in DATE,
  X_RULE_WAIVED_DT in DATE,
  X_RULE_WAIVED_PERSON_ID in NUMBER,
  X_NO_ASSESSMENT_IND in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_DCNT_REASON_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER,
  X_GRADING_SCHEMA_CODE IN VARCHAR2 DEFAULT NULL,
  X_ENR_METHOD_TYPE IN VARCHAR2 DEFAULT NULL,
  X_ADMINISTRATIVE_PRIORITY     IN NUMBER DEFAULT NULL,
  X_WAITLIST_DT                 IN DATE DEFAULT NULL,
  X_REQUEST_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_APPLICATION_ID      IN NUMBER DEFAULT NULL,
  X_PROGRAM_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_UPDATE_DATE         IN DATE DEFAULT NULL,
  X_CART                        IN VARCHAR2 DEFAULT NULL,
  X_ORG_UNIT_CD                 IN VARCHAR2 DEFAULT NULL,
  X_RSV_SEAT_EXT_ID             IN NUMBER DEFAULT NULL,
  X_GS_VERSION_NUMBER           IN NUMBER DEFAULT NULL,
  X_FAILED_UNIT_RULE            IN VARCHAR2 DEFAULT NULL,
  X_DEG_AUD_DETAIL_ID           IN NUMBER DEFAULT NULL,
  X_UOO_ID                  IN NUMBER,
  X_CORE_INDICATOR_CODE IN VARCHAR2 DEFAULT NULL
  ) AS
    cursor C is select ROWID from IGS_EN_SU_ATTEMPT_H_ALL
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and HIST_START_DT = new_references.HIST_START_DT
      and UOO_ID = X_UOO_ID;
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
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
before_DML(
 p_action=>'INSERT',
x_rowid=>X_ROWID,
x_administrative_unit_status=>X_ADMINISTRATIVE_UNIT_STATUS,
x_alternative_title=>X_ALTERNATIVE_TITLE,
x_aus_description=>X_AUS_DESCRIPTION,
x_cal_type=>X_CAL_TYPE,
x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
x_course_cd=>X_COURSE_CD,
x_discontinued_dt=>X_DISCONTINUED_DT,
x_elo_description=>X_ELO_DESCRIPTION,
x_enrolled_dt=>X_ENROLLED_DT,
x_exam_location_cd=>X_EXAM_LOCATION_CD,
x_hist_end_dt=>X_HIST_END_DT,
x_hist_start_dt=>X_HIST_START_DT,
x_hist_who=>X_HIST_WHO,
x_location_cd=>X_LOCATION_CD,
x_no_assessment_ind=>X_NO_ASSESSMENT_IND,
x_override_achievable_cp=>X_OVERRIDE_ACHIEVABLE_CP,
x_override_credit_reason=>X_OVERRIDE_CREDIT_REASON,
x_override_eftsu=>X_OVERRIDE_EFTSU,
x_override_enrolled_cp=>X_OVERRIDE_ENROLLED_CP,
x_override_outcome_due_dt=>X_OVERRIDE_OUTCOME_DUE_DT,
x_person_id=>X_PERSON_ID,
x_rule_waived_dt=>X_RULE_WAIVED_DT,
x_rule_waived_person_id=>X_RULE_WAIVED_PERSON_ID,
x_sup_unit_cd=>X_SUP_UNIT_CD,
x_sup_version_number=>X_SUP_VERSION_NUMBER,
x_unit_attempt_status=>X_UNIT_ATTEMPT_STATUS,
x_unit_cd=>X_UNIT_CD,
x_unit_class=>X_UNIT_CLASS,
x_version_number=>X_VERSION_NUMBER,
x_dcnt_reason_cd => X_DCNT_REASON_CD,
x_creation_date=>X_LAST_UPDATE_DATE,
x_created_by=>X_LAST_UPDATED_BY,
x_last_update_date=>X_LAST_UPDATE_DATE,
x_last_updated_by=>X_LAST_UPDATED_BY,
x_last_update_login=>X_LAST_UPDATE_LOGIN,
x_org_id  => igs_ge_gen_003.get_org_id ,
x_grading_schema_code =>X_GRADING_SCHEMA_CODE,
x_enr_method_type =>X_ENR_METHOD_TYPE ,
x_administrative_priority   =>  X_ADMINISTRATIVE_PRIORITY,
x_waitlist_dt               =>  X_WAITLIST_DT,
x_request_id                =>  X_REQUEST_ID,
x_program_application_id    =>  X_PROGRAM_APPLICATION_ID ,
x_program_id                =>  X_PROGRAM_ID,
x_program_update_date       =>  X_PROGRAM_UPDATE_DATE,
x_cart                      =>  X_CART,
x_org_unit_cd               =>  X_ORG_UNIT_CD,
x_rsv_seat_ext_id           =>  X_RSV_SEAT_EXT_ID,
x_gs_version_number         =>  X_GS_VERSION_NUMBER,
x_failed_unit_rule          =>  X_FAILED_UNIT_RULE,
x_deg_aud_detail_id         =>  X_DEG_AUD_DETAIL_ID,
x_uoo_id => X_UOO_ID,
x_core_indicator_code       =>  X_CORE_INDICATOR_CODE
);
  insert into IGS_EN_SU_ATTEMPT_H_ALL (
    ELO_DESCRIPTION,
    SUP_UNIT_CD,
    SUP_VERSION_NUMBER,
    ALTERNATIVE_TITLE,
    OVERRIDE_ENROLLED_CP,
    OVERRIDE_EFTSU,
    OVERRIDE_ACHIEVABLE_CP,
    OVERRIDE_OUTCOME_DUE_DT,
    OVERRIDE_CREDIT_REASON,
    PERSON_ID,
    COURSE_CD,
    UNIT_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    LOCATION_CD,
    UNIT_CLASS,
    ENROLLED_DT,
    UNIT_ATTEMPT_STATUS,
    ADMINISTRATIVE_UNIT_STATUS,
    AUS_DESCRIPTION,
    DISCONTINUED_DT,
    RULE_WAIVED_DT,
    RULE_WAIVED_PERSON_ID,
    NO_ASSESSMENT_IND,
    EXAM_LOCATION_CD,
    DCNT_REASON_CD,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    org_id,
    GRADING_SCHEMA_CODE,
    ENR_METHOD_TYPE,
    ADMINISTRATIVE_PRIORITY,
    WAITLIST_DT,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE ,
    CART,
    ORG_UNIT_CD,
    RSV_SEAT_EXT_ID,
    GS_VERSION_NUMBER,
    FAILED_UNIT_RULE,
    DEG_AUD_DETAIL_ID,
    UOO_ID,
    CORE_INDICATOR_CODE
  ) values (
    new_references.ELO_DESCRIPTION,
    new_references.SUP_UNIT_CD,
    new_references.SUP_VERSION_NUMBER,
    new_references.ALTERNATIVE_TITLE,
    new_references.OVERRIDE_ENROLLED_CP,
    new_references.OVERRIDE_EFTSU,
    new_references.OVERRIDE_ACHIEVABLE_CP,
    new_references.OVERRIDE_OUTCOME_DUE_DT,
    new_references.OVERRIDE_CREDIT_REASON,
    new_references.PERSON_ID,
    new_references.COURSE_CD,
    new_references.UNIT_CD,
    new_references.VERSION_NUMBER,
    new_references.CAL_TYPE,
    new_references.CI_SEQUENCE_NUMBER,
    new_references.HIST_START_DT,
    new_references.HIST_END_DT,
    new_references.HIST_WHO,
    new_references.LOCATION_CD,
    new_references.UNIT_CLASS,
    new_references.ENROLLED_DT,
    new_references.UNIT_ATTEMPT_STATUS,
    new_references.ADMINISTRATIVE_UNIT_STATUS,
    new_references.AUS_DESCRIPTION,
    new_references.DISCONTINUED_DT,
    new_references.RULE_WAIVED_DT,
    new_references.RULE_WAIVED_PERSON_ID,
    new_references.NO_ASSESSMENT_IND,
    new_references.EXAM_LOCATION_CD,
    new_references.DCNT_REASON_CD,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    new_references.org_id,
    new_references.GRADING_SCHEMA_CODE,
    new_references.ENR_METHOD_TYPE,
    new_references.ADMINISTRATIVE_PRIORITY,
    new_references.WAITLIST_DT,
    new_references.REQUEST_ID,
    new_references.PROGRAM_APPLICATION_ID,
    new_references.PROGRAM_ID,
    new_references.PROGRAM_UPDATE_DATE,
    new_references.CART,
    new_references.ORG_UNIT_CD,
    new_references.RSV_SEAT_EXT_ID,
    new_references.GS_VERSION_NUMBER,
    new_references.FAILED_UNIT_RULE,
    new_references.DEG_AUD_DETAIL_ID,
    new_references.UOO_ID,
    new_references.CORE_INDICATOR_CODE
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
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_ELO_DESCRIPTION in VARCHAR2,
  X_SUP_UNIT_CD in VARCHAR2,
  X_SUP_VERSION_NUMBER in NUMBER,
  X_ALTERNATIVE_TITLE in VARCHAR2,
  X_OVERRIDE_ENROLLED_CP in NUMBER,
  X_OVERRIDE_EFTSU in NUMBER,
  X_OVERRIDE_ACHIEVABLE_CP in NUMBER,
  X_OVERRIDE_OUTCOME_DUE_DT in DATE,
  X_OVERRIDE_CREDIT_REASON in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_AUS_DESCRIPTION in VARCHAR2,
  X_DISCONTINUED_DT in DATE,
  X_RULE_WAIVED_DT in DATE,
  X_RULE_WAIVED_PERSON_ID in NUMBER,
  X_NO_ASSESSMENT_IND in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_DCNT_REASON_CD IN VARCHAR2,
  X_GRADING_SCHEMA_CODE IN VARCHAR2 DEFAULT NULL,
  X_ENR_METHOD_TYPE IN VARCHAR2 DEFAULT NULL,
  X_ADMINISTRATIVE_PRIORITY     IN NUMBER DEFAULT NULL,
  X_WAITLIST_DT                 IN DATE DEFAULT NULL,
  X_REQUEST_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_APPLICATION_ID      IN NUMBER DEFAULT NULL,
  X_PROGRAM_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_UPDATE_DATE         IN DATE DEFAULT NULL,
  X_CART                        IN VARCHAR2 DEFAULT NULL,
  X_ORG_UNIT_CD                 IN VARCHAR2 DEFAULT NULL,
  X_RSV_SEAT_EXT_ID             IN NUMBER DEFAULT NULL,
  X_GS_VERSION_NUMBER           IN NUMBER DEFAULT NULL,
  X_FAILED_UNIT_RULE            IN VARCHAR2 DEFAULT NULL,
  X_DEG_AUD_DETAIL_ID           IN NUMBER DEFAULT NULL,
  X_UOO_ID                  IN NUMBER,
  X_CORE_INDICATOR_CODE IN VARCHAR2 DEFAULT NULL
) AS
  cursor c1 is select
      ELO_DESCRIPTION,
      SUP_UNIT_CD,
      SUP_VERSION_NUMBER,
      ALTERNATIVE_TITLE,
      OVERRIDE_ENROLLED_CP,
      OVERRIDE_EFTSU,
      OVERRIDE_ACHIEVABLE_CP,
      OVERRIDE_OUTCOME_DUE_DT,
      OVERRIDE_CREDIT_REASON,
      VERSION_NUMBER,
      HIST_END_DT,
      HIST_WHO,
      LOCATION_CD,
      UNIT_CLASS,
      ENROLLED_DT,
      UNIT_ATTEMPT_STATUS,
      ADMINISTRATIVE_UNIT_STATUS,
      AUS_DESCRIPTION,
      DISCONTINUED_DT,
      RULE_WAIVED_DT,
      RULE_WAIVED_PERSON_ID,
      NO_ASSESSMENT_IND,
      EXAM_LOCATION_CD,
      dcnt_reason_cd,
      GRADING_SCHEMA_CODE,
      ENR_METHOD_TYPE,
      ADMINISTRATIVE_PRIORITY ,
      WAITLIST_DT,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      CART,
      ORG_UNIT_CD,
      RSV_SEAT_EXT_ID,
      GS_VERSION_NUMBER,
      FAILED_UNIT_RULE,
      DEG_AUD_DETAIL_ID,
      UOO_ID,
      CORE_INDICATOR_CODE
    from IGS_EN_SU_ATTEMPT_H_ALL
    where PERSON_ID = X_PERSON_ID
    and COURSE_CD = X_COURSE_CD
    and HIST_START_DT = X_HIST_START_DT
    and UOO_ID = X_UOO_ID
    for update of PERSON_ID nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    close c1;
    return;
  end if;
  close c1;
      if ( ((tlinfo.ELO_DESCRIPTION = X_ELO_DESCRIPTION)
           OR ((tlinfo.ELO_DESCRIPTION is null)
               AND (X_ELO_DESCRIPTION is null)))
      AND ((tlinfo.SUP_UNIT_CD = X_SUP_UNIT_CD)
           OR ((tlinfo.SUP_UNIT_CD is null)
               AND (X_SUP_UNIT_CD is null)))
      AND ((tlinfo.SUP_VERSION_NUMBER = X_SUP_VERSION_NUMBER)
           OR ((tlinfo.SUP_VERSION_NUMBER is null)
               AND (X_SUP_VERSION_NUMBER is null)))
      AND ((tlinfo.ALTERNATIVE_TITLE = X_ALTERNATIVE_TITLE)
           OR ((tlinfo.ALTERNATIVE_TITLE is null)
               AND (X_ALTERNATIVE_TITLE is null)))
      AND ((tlinfo.OVERRIDE_ENROLLED_CP = X_OVERRIDE_ENROLLED_CP)
           OR ((tlinfo.OVERRIDE_ENROLLED_CP is null)
               AND (X_OVERRIDE_ENROLLED_CP is null)))
      AND ((tlinfo.OVERRIDE_EFTSU = X_OVERRIDE_EFTSU)
           OR ((tlinfo.OVERRIDE_EFTSU is null)
               AND (X_OVERRIDE_EFTSU is null)))
      AND ((tlinfo.OVERRIDE_ACHIEVABLE_CP = X_OVERRIDE_ACHIEVABLE_CP)
           OR ((tlinfo.OVERRIDE_ACHIEVABLE_CP is null)
               AND (X_OVERRIDE_ACHIEVABLE_CP is null)))
      AND ((tlinfo.OVERRIDE_OUTCOME_DUE_DT = X_OVERRIDE_OUTCOME_DUE_DT)
           OR ((tlinfo.OVERRIDE_OUTCOME_DUE_DT is null)
               AND (X_OVERRIDE_OUTCOME_DUE_DT is null)))
      AND ((tlinfo.OVERRIDE_CREDIT_REASON = X_OVERRIDE_CREDIT_REASON)
           OR ((tlinfo.OVERRIDE_CREDIT_REASON is null)
               AND (X_OVERRIDE_CREDIT_REASON is null)))
      AND ((tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
           OR ((tlinfo.VERSION_NUMBER is null)
               AND (X_VERSION_NUMBER is null)))
      AND (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.UNIT_CLASS = X_UNIT_CLASS)
           OR ((tlinfo.UNIT_CLASS is null)
               AND (X_UNIT_CLASS is null)))
      AND ((tlinfo.ENROLLED_DT = X_ENROLLED_DT)
           OR ((tlinfo.ENROLLED_DT is null)
               AND (X_ENROLLED_DT is null)))
      AND ((tlinfo.UNIT_ATTEMPT_STATUS = X_UNIT_ATTEMPT_STATUS)
           OR ((tlinfo.UNIT_ATTEMPT_STATUS is null)
               AND (X_UNIT_ATTEMPT_STATUS is null)))
      AND ((tlinfo.ADMINISTRATIVE_UNIT_STATUS = X_ADMINISTRATIVE_UNIT_STATUS)
           OR ((tlinfo.ADMINISTRATIVE_UNIT_STATUS is null)
               AND (X_ADMINISTRATIVE_UNIT_STATUS is null)))
      AND ((tlinfo.AUS_DESCRIPTION = X_AUS_DESCRIPTION)
           OR ((tlinfo.AUS_DESCRIPTION is null)
               AND (X_AUS_DESCRIPTION is null)))
      AND ((tlinfo.DISCONTINUED_DT = X_DISCONTINUED_DT)
           OR ((tlinfo.DISCONTINUED_DT is null)
               AND (X_DISCONTINUED_DT is null)))
      AND ((tlinfo.RULE_WAIVED_DT = X_RULE_WAIVED_DT)
           OR ((tlinfo.RULE_WAIVED_DT is null)
               AND (X_RULE_WAIVED_DT is null)))
      AND ((tlinfo.RULE_WAIVED_PERSON_ID = X_RULE_WAIVED_PERSON_ID)
           OR ((tlinfo.RULE_WAIVED_PERSON_ID is null)
               AND (X_RULE_WAIVED_PERSON_ID is null)))
      AND ((tlinfo.NO_ASSESSMENT_IND = X_NO_ASSESSMENT_IND)
           OR ((tlinfo.NO_ASSESSMENT_IND is null)
               AND (X_NO_ASSESSMENT_IND is null)))
      AND ((tlinfo.EXAM_LOCATION_CD = X_EXAM_LOCATION_CD)
           OR ((tlinfo.EXAM_LOCATION_CD is null)
               AND (X_EXAM_LOCATION_CD is null)))
      AND ((tlinfo.dcnt_reason_cd = X_dcnt_reason_Cd)
           OR ((tlinfo.dcnt_reason_cd is null)
               AND (X_dcnt_reason_cd is null)))
      AND ((tlinfo.GRADING_SCHEMA_CODE = X_GRADING_SCHEMA_CODE)
           OR ((tlinfo.GRADING_SCHEMA_CODE is null)
               AND (X_GRADING_SCHEMA_CODE is null)))
      AND ((tlinfo.ENR_METHOD_TYPE = X_ENR_METHOD_TYPE)
           OR ((tlinfo.ENR_METHOD_TYPE is null)
               AND (X_ENR_METHOD_TYPE is null)))

      AND ((tlinfo.ADMINISTRATIVE_PRIORITY = X_ADMINISTRATIVE_PRIORITY)
           OR ((tlinfo.ADMINISTRATIVE_PRIORITY is null)
               AND (X_ADMINISTRATIVE_PRIORITY is null)))

      AND ((tlinfo.WAITLIST_DT = X_WAITLIST_DT)
           OR ((tlinfo.WAITLIST_DT is null)
               AND (X_WAITLIST_DT is null)))

      AND ((tlinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((tlinfo.REQUEST_ID is null)
               AND (X_REQUEST_ID is null)))

      AND ((tlinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
           OR ((tlinfo.PROGRAM_APPLICATION_ID is null)
               AND (X_PROGRAM_APPLICATION_ID is null)))

      AND ((tlinfo.PROGRAM_ID = X_PROGRAM_ID)
           OR ((tlinfo.PROGRAM_ID is null)
               AND (X_PROGRAM_ID is null)))

      AND ((tlinfo.PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE)
           OR ((tlinfo.PROGRAM_UPDATE_DATE is null)
               AND (X_PROGRAM_UPDATE_DATE is null)))

      AND ((tlinfo.CART = X_CART)
           OR ((tlinfo.CART is null)
               AND (X_CART is null)))

      AND ((tlinfo.ORG_UNIT_CD = X_ORG_UNIT_CD)
           OR ((tlinfo.ORG_UNIT_CD is null)
               AND (X_ORG_UNIT_CD is null)))

      AND ((tlinfo.RSV_SEAT_EXT_ID = X_RSV_SEAT_EXT_ID)
           OR ((tlinfo.RSV_SEAT_EXT_ID is null)
               AND (X_RSV_SEAT_EXT_ID is null)))

      AND ((tlinfo.GS_VERSION_NUMBER = X_GS_VERSION_NUMBER)
           OR ((tlinfo.GS_VERSION_NUMBER is null)
               AND (X_GS_VERSION_NUMBER is null)))

      AND ((tlinfo.FAILED_UNIT_RULE = X_FAILED_UNIT_RULE)
           OR ((tlinfo.FAILED_UNIT_RULE is null)
               AND (X_FAILED_UNIT_RULE is null)))

      AND ((tlinfo.DEG_AUD_DETAIL_ID = X_DEG_AUD_DETAIL_ID)
           OR ((tlinfo.DEG_AUD_DETAIL_ID is null)
               AND (X_DEG_AUD_DETAIL_ID is null)))

      AND   ((tlinfo.CORE_INDICATOR_CODE = X_CORE_INDICATOR_CODE)
               OR (( tlinfo.CORE_INDICATOR_CODE is null)
               AND (X_CORE_INDICATOR_CODE is null)))

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
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_ELO_DESCRIPTION in VARCHAR2,
  X_SUP_UNIT_CD in VARCHAR2,
  X_SUP_VERSION_NUMBER in NUMBER,
  X_ALTERNATIVE_TITLE in VARCHAR2,
  X_OVERRIDE_ENROLLED_CP in NUMBER,
  X_OVERRIDE_EFTSU in NUMBER,
  X_OVERRIDE_ACHIEVABLE_CP in NUMBER,
  X_OVERRIDE_OUTCOME_DUE_DT in DATE,
  X_OVERRIDE_CREDIT_REASON in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_AUS_DESCRIPTION in VARCHAR2,
  X_DISCONTINUED_DT in DATE,
  X_RULE_WAIVED_DT in DATE,
  X_RULE_WAIVED_PERSON_ID in NUMBER,
  X_NO_ASSESSMENT_IND in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  x_dcnt_reason_cd IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_GRADING_SCHEMA_CODE IN VARCHAR2 DEFAULT NULL,
  X_ENR_METHOD_TYPE IN VARCHAR2 DEFAULT NULL,
  X_ADMINISTRATIVE_PRIORITY     IN NUMBER DEFAULT NULL,
  X_WAITLIST_DT                 IN DATE DEFAULT NULL,
  X_REQUEST_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_APPLICATION_ID      IN NUMBER DEFAULT NULL,
  X_PROGRAM_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_UPDATE_DATE         IN DATE DEFAULT NULL,
  X_CART                        IN VARCHAR2 DEFAULT NULL,
  X_ORG_UNIT_CD                 IN VARCHAR2 DEFAULT NULL,
  X_RSV_SEAT_EXT_ID             IN NUMBER DEFAULT NULL,
  X_GS_VERSION_NUMBER           IN NUMBER DEFAULT NULL,
  X_FAILED_UNIT_RULE            IN VARCHAR2 DEFAULT NULL,
  X_DEG_AUD_DETAIL_ID           IN NUMBER DEFAULT NULL,
  X_UOO_ID                  IN NUMBER,
  X_CORE_INDICATOR_CODE IN VARCHAR2 DEFAULT NULL
  ) AS
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
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
   before_DML(
 p_action=>'UPDATE',
x_rowid=>X_ROWID,
x_administrative_unit_status=>X_ADMINISTRATIVE_UNIT_STATUS,
x_alternative_title=>X_ALTERNATIVE_TITLE,
x_aus_description=>X_AUS_DESCRIPTION,
x_cal_type=>X_CAL_TYPE,
x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
x_course_cd=>X_COURSE_CD,
x_discontinued_dt=>X_DISCONTINUED_DT,
x_elo_description=>X_ELO_DESCRIPTION,
x_enrolled_dt=>X_ENROLLED_DT,
x_exam_location_cd=>X_EXAM_LOCATION_CD,
x_hist_end_dt=>X_HIST_END_DT,
x_hist_start_dt=>X_HIST_START_DT,
x_hist_who=>X_HIST_WHO,
x_location_cd=>X_LOCATION_CD,
x_no_assessment_ind=>X_NO_ASSESSMENT_IND,
x_override_achievable_cp=>X_OVERRIDE_ACHIEVABLE_CP,
x_override_credit_reason=>X_OVERRIDE_CREDIT_REASON,
x_override_eftsu=>X_OVERRIDE_EFTSU,
x_override_enrolled_cp=>X_OVERRIDE_ENROLLED_CP,
x_override_outcome_due_dt=>X_OVERRIDE_OUTCOME_DUE_DT,
x_person_id=>X_PERSON_ID,
x_rule_waived_dt=>X_RULE_WAIVED_DT,
x_rule_waived_person_id=>X_RULE_WAIVED_PERSON_ID,
x_sup_unit_cd=>X_SUP_UNIT_CD,
x_sup_version_number=>X_SUP_VERSION_NUMBER,
x_unit_attempt_status=>X_UNIT_ATTEMPT_STATUS,
x_unit_cd=>X_UNIT_CD,
x_unit_class=>X_UNIT_CLASS,
x_version_number=>X_VERSION_NUMBER,
x_dcnt_reason_cd => x_dcnt_reason_cd,
x_creation_date=>X_LAST_UPDATE_DATE,
x_created_by=>X_LAST_UPDATED_BY,
x_last_update_date=>X_LAST_UPDATE_DATE,
x_last_updated_by=>X_LAST_UPDATED_BY,
x_last_update_login=>X_LAST_UPDATE_LOGIN,
x_grading_schema_code =>X_GRADING_SCHEMA_CODE,
x_enr_method_type =>X_ENR_METHOD_TYPE,
x_administrative_priority   =>  X_ADMINISTRATIVE_PRIORITY,
x_waitlist_dt               =>  X_WAITLIST_DT,
x_request_id                =>  X_REQUEST_ID,
x_program_application_id    =>  X_PROGRAM_APPLICATION_ID ,
x_program_id                =>  X_PROGRAM_ID,
x_program_update_date       =>  X_PROGRAM_UPDATE_DATE,
x_cart                      =>  X_CART,
x_org_unit_cd               =>  X_ORG_UNIT_CD,
x_rsv_seat_ext_id           =>  X_RSV_SEAT_EXT_ID,
x_gs_version_number         =>  X_GS_VERSION_NUMBER,
x_failed_unit_rule          =>  X_FAILED_UNIT_RULE,
x_deg_aud_detail_id         =>  X_DEG_AUD_DETAIL_ID,
x_uoo_id                => X_UOO_ID,
x_core_indicator_code            =>  X_CORE_INDICATOR_CODE
);
  update IGS_EN_SU_ATTEMPT_H_ALL set
    ELO_DESCRIPTION = new_references.ELO_DESCRIPTION,
    SUP_UNIT_CD = new_references.SUP_UNIT_CD,
    SUP_VERSION_NUMBER = new_references.SUP_VERSION_NUMBER,
    ALTERNATIVE_TITLE = new_references.ALTERNATIVE_TITLE,
    OVERRIDE_ENROLLED_CP = new_references.OVERRIDE_ENROLLED_CP,
    OVERRIDE_EFTSU = new_references.OVERRIDE_EFTSU,
    OVERRIDE_ACHIEVABLE_CP = new_references.OVERRIDE_ACHIEVABLE_CP,
    OVERRIDE_OUTCOME_DUE_DT = new_references.OVERRIDE_OUTCOME_DUE_DT,
    OVERRIDE_CREDIT_REASON = new_references.OVERRIDE_CREDIT_REASON,
    VERSION_NUMBER = new_references.VERSION_NUMBER,
    HIST_END_DT = new_references.HIST_END_DT,
    HIST_WHO = new_references.HIST_WHO,
    LOCATION_CD = new_references.LOCATION_CD,
    UNIT_CLASS = new_references.UNIT_CLASS,
    ENROLLED_DT = new_references.ENROLLED_DT,
    UNIT_ATTEMPT_STATUS = new_references.UNIT_ATTEMPT_STATUS,
    ADMINISTRATIVE_UNIT_STATUS = new_references.ADMINISTRATIVE_UNIT_STATUS,
    AUS_DESCRIPTION = new_references.AUS_DESCRIPTION,
    DISCONTINUED_DT = new_references.DISCONTINUED_DT,
    RULE_WAIVED_DT = new_references.RULE_WAIVED_DT,
    RULE_WAIVED_PERSON_ID = new_references.RULE_WAIVED_PERSON_ID,
    NO_ASSESSMENT_IND = new_references.NO_ASSESSMENT_IND,
    EXAM_LOCATION_CD = new_references.EXAM_LOCATION_CD,
    DCNT_REASON_CD = new_references.DCNT_REASON_CD,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    GRADING_SCHEMA_CODE=new_references.GRADING_SCHEMA_CODE,
    ENR_METHOD_TYPE=new_references.ENR_METHOD_TYPE,
    ADMINISTRATIVE_PRIORITY =  new_references.ADMINISTRATIVE_PRIORITY,
    WAITLIST_DT             =   new_references.WAITLIST_DT,
    REQUEST_ID              =   new_references.REQUEST_ID,
    PROGRAM_APPLICATION_ID  =   new_references.PROGRAM_APPLICATION_ID ,
    PROGRAM_ID              =   new_references.PROGRAM_ID,
    PROGRAM_UPDATE_DATE     =   new_references.PROGRAM_UPDATE_DATE,
    CART                    =   new_references.CART,
    ORG_UNIT_CD             =   new_references.ORG_UNIT_CD,
    RSV_SEAT_EXT_ID         =   new_references.RSV_SEAT_EXT_ID,
    GS_VERSION_NUMBER       =   new_references.GS_VERSION_NUMBER,
    FAILED_UNIT_RULE        =   new_references.FAILED_UNIT_RULE,
    DEG_AUD_DETAIL_ID       =   new_references.DEG_AUD_DETAIL_ID,
    CORE_INDICATOR_CODE          =   new_references.CORE_INDICATOR_CODE
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_ELO_DESCRIPTION in VARCHAR2,
  X_SUP_UNIT_CD in VARCHAR2,
  X_SUP_VERSION_NUMBER in NUMBER,
  X_ALTERNATIVE_TITLE in VARCHAR2,
  X_OVERRIDE_ENROLLED_CP in NUMBER,
  X_OVERRIDE_EFTSU in NUMBER,
  X_OVERRIDE_ACHIEVABLE_CP in NUMBER,
  X_OVERRIDE_OUTCOME_DUE_DT in DATE,
  X_OVERRIDE_CREDIT_REASON in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_AUS_DESCRIPTION in VARCHAR2,
  X_DISCONTINUED_DT in DATE,
  X_RULE_WAIVED_DT in DATE,
  X_RULE_WAIVED_PERSON_ID in NUMBER,
  X_NO_ASSESSMENT_IND in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  x_dcnt_reason_cd IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_org_id IN NUMBER ,
  X_GRADING_SCHEMA_CODE IN VARCHAR2 DEFAULT NULL,
  X_ENR_METHOD_TYPE IN VARCHAR2 DEFAULT NULL,
  X_ADMINISTRATIVE_PRIORITY     IN NUMBER DEFAULT NULL,
  X_WAITLIST_DT                 IN DATE DEFAULT NULL,
  X_REQUEST_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_APPLICATION_ID      IN NUMBER DEFAULT NULL,
  X_PROGRAM_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_UPDATE_DATE         IN DATE DEFAULT NULL,
  X_CART                        IN VARCHAR2 DEFAULT NULL,
  X_ORG_UNIT_CD                 IN VARCHAR2 DEFAULT NULL,
  X_RSV_SEAT_EXT_ID             IN NUMBER DEFAULT NULL,
  X_GS_VERSION_NUMBER           IN NUMBER DEFAULT NULL,
  X_FAILED_UNIT_RULE            IN VARCHAR2 DEFAULT NULL,
  X_DEG_AUD_DETAIL_ID           IN NUMBER DEFAULT NULL,
  X_UOO_ID                  IN NUMBER,
  X_CORE_INDICATOR_CODE IN VARCHAR2 DEFAULT NULL
  ) as
  cursor c1 is select rowid from IGS_EN_SU_ATTEMPT_H_ALL
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and HIST_START_DT = X_HIST_START_DT
     and UOO_ID = X_UOO_ID;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_UNIT_CD,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_HIST_START_DT,
     X_ELO_DESCRIPTION,
     X_SUP_UNIT_CD,
     X_SUP_VERSION_NUMBER,
     X_ALTERNATIVE_TITLE,
     X_OVERRIDE_ENROLLED_CP,
     X_OVERRIDE_EFTSU,
     X_OVERRIDE_ACHIEVABLE_CP,
     X_OVERRIDE_OUTCOME_DUE_DT,
     X_OVERRIDE_CREDIT_REASON,
     X_VERSION_NUMBER,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_LOCATION_CD,
     X_UNIT_CLASS,
     X_ENROLLED_DT,
     X_UNIT_ATTEMPT_STATUS,
     X_ADMINISTRATIVE_UNIT_STATUS,
     X_AUS_DESCRIPTION,
     X_DISCONTINUED_DT,
     X_RULE_WAIVED_DT,
     X_RULE_WAIVED_PERSON_ID,
     X_NO_ASSESSMENT_IND,
     X_EXAM_LOCATION_CD,
     X_DCNT_REASON_CD,
     X_MODE,
     x_org_id,
     X_GRADING_SCHEMA_CODE,
     X_ENR_METHOD_TYPE,
     X_ADMINISTRATIVE_PRIORITY,
     X_WAITLIST_DT,
     X_REQUEST_ID,
     X_PROGRAM_APPLICATION_ID,
     X_PROGRAM_ID,
     X_PROGRAM_UPDATE_DATE,
     X_CART,
     X_ORG_UNIT_CD,
     X_RSV_SEAT_EXT_ID,
     X_GS_VERSION_NUMBER,
     X_FAILED_UNIT_RULE ,
     X_DEG_AUD_DETAIL_ID,
     X_UOO_ID,
     X_CORE_INDICATOR_CODE
  );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_UNIT_CD,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_HIST_START_DT,
   X_ELO_DESCRIPTION,
   X_SUP_UNIT_CD,
   X_SUP_VERSION_NUMBER,
   X_ALTERNATIVE_TITLE,
   X_OVERRIDE_ENROLLED_CP,
   X_OVERRIDE_EFTSU,
   X_OVERRIDE_ACHIEVABLE_CP,
   X_OVERRIDE_OUTCOME_DUE_DT,
   X_OVERRIDE_CREDIT_REASON,
   X_VERSION_NUMBER,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_LOCATION_CD,
   X_UNIT_CLASS,
   X_ENROLLED_DT,
   X_UNIT_ATTEMPT_STATUS,
   X_ADMINISTRATIVE_UNIT_STATUS,
   X_AUS_DESCRIPTION,
   X_DISCONTINUED_DT,
   X_RULE_WAIVED_DT,
   X_RULE_WAIVED_PERSON_ID,
   X_NO_ASSESSMENT_IND,
   X_EXAM_LOCATION_CD,
   X_DCNT_REASON_CD,
   X_MODE,
   X_GRADING_SCHEMA_CODE,
   X_ENR_METHOD_TYPE,
   X_ADMINISTRATIVE_PRIORITY,
   X_WAITLIST_DT,
   X_REQUEST_ID,
   X_PROGRAM_APPLICATION_ID,
   X_PROGRAM_ID,
   X_PROGRAM_UPDATE_DATE,
   X_CART,
   X_ORG_UNIT_CD,
   X_RSV_SEAT_EXT_ID,
   X_GS_VERSION_NUMBER,
   X_FAILED_UNIT_RULE   ,
   X_DEG_AUD_DETAIL_ID,
   X_UOO_ID,
   X_CORE_INDICATOR_CODE
 );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
  Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_EN_SU_ATTEMPT_H_ALL
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

PROCEDURE Check_Constraints (
Column_Name     IN      VARCHAR2        DEFAULT NULL,
Column_Value    IN      VARCHAR2        DEFAULT NULL
) AS

        BEGIN
      IF  column_name is null then
            NULL;
          ELSIF upper(Column_name) = 'ADMINISTRATIVE_UNIT_STATUS' then
            new_references.ADMINISTRATIVE_UNIT_STATUS := column_value;
      ELSIF upper(Column_name) = 'ALTERNATIVE_TITLE' then
        new_references.ALTERNATIVE_TITLE := column_value;
      ELSIF upper(Column_name) = 'CAL_TYPE' then
        new_references.CAL_TYPE := column_value;
      ELSIF upper(Column_name) = 'COURSE_CD' then
        new_references.COURSE_CD := column_value;
      ELSIF upper(Column_name) = 'EXAM_LOCATION_CD' then
        new_references.EXAM_LOCATION_CD := column_value;
      ELSIF upper(Column_name) = 'NO_ASSESSMENT_IND' then
        new_references.NO_ASSESSMENT_IND := column_value;
      ELSIF upper(Column_name) = 'SUP_UNIT_CD' then
        new_references.SUP_UNIT_CD := column_value;
      ELSIF upper(Column_name) = 'UNIT_ATTEMPT_STATUS' then
        new_references.UNIT_ATTEMPT_STATUS := column_value;
      ELSIF upper(Column_name) = 'UNIT_CD' then
        new_references.UNIT_CD := column_value;
      ELSIF upper(Column_name) = 'UNIT_CLASS' then
        new_references.UNIT_CLASS := column_value;
        ELSIF upper(Column_name) = 'PERSON_ID' then
        new_references.PERSON_ID := igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'LOCATION_CD' then
        new_references.LOCATION_CD := column_value;
      ELSIF upper(Column_name) = 'VERSION_NUMBER' then
        new_references.VERSION_NUMBER := igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'CI_SEQUENCE_NUMBER' then
        new_references.CI_SEQUENCE_NUMBER := igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'RULE_WAIVED_PERSON_ID' then
        new_references.RULE_WAIVED_PERSON_ID := igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'NO_ASSESSMENT_IND' then
        new_references.NO_ASSESSMENT_IND := column_value;
      ELSIF upper(Column_name) = 'SUP_VERSION_NUMBER' then
        new_references.SUP_VERSION_NUMBER := igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'OVERRIDE_ENROLLED_CP' then
        new_references.OVERRIDE_ENROLLED_CP := igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'OVERRIDE_EFTSU' then
        new_references.OVERRIDE_EFTSU := igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'OVERRIDE_ACHIEVABLE_CP' then
        new_references.OVERRIDE_ACHIEVABLE_CP := igs_ge_number.to_num(column_value);
      ELSIF upper(Column_name) = 'CORE_INDICATOR_CODE' then
        new_references.CORE_INDICATOR_CODE := column_value;
          END IF;

IF upper(column_name) = 'ADMINISTRATIVE_UNIT_STATUS' OR
     column_name is null Then
     IF new_references.ADMINISTRATIVE_UNIT_STATUS <> UPPER(new_references.ADMINISTRATIVE_UNIT_STATUS) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(column_name) = 'ALTERNATIVE_TITLE' OR
     column_name is null Then
     IF new_references.ALTERNATIVE_TITLE <> UPPER(new_references.ALTERNATIVE_TITLE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
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

IF upper(column_name) = 'EXAM_LOCATION_CD' OR
     column_name is null Then
     IF new_references.EXAM_LOCATION_CD <> UPPER(new_references.EXAM_LOCATION_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(column_name) = 'NO_ASSESSMENT_IND' OR
     column_name is null Then
     IF new_references.NO_ASSESSMENT_IND <> UPPER(new_references.NO_ASSESSMENT_IND) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(column_name) = 'SUP_UNIT_CD' OR
     column_name is null Then
     IF new_references.SUP_UNIT_CD <> UPPER(new_references.SUP_UNIT_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

IF upper(column_name) = 'UNIT_ATTEMPT_STATUS' OR
     column_name is null Then
     IF new_references.UNIT_ATTEMPT_STATUS <> UPPER(new_references.UNIT_ATTEMPT_STATUS) Then
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


    IF upper(column_name) = 'PERSON_ID ' OR
     column_name is null Then
     IF new_references.PERSON_ID < 0 OR new_references.PERSON_ID > 9999999999 Then
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


    IF upper(column_name) = 'VERSION_NUMBER ' OR
     column_name is null Then
     IF new_references.VERSION_NUMBER < 0 OR new_references.VERSION_NUMBER > 999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

   IF upper(column_name) = 'CI_SEQUENCE_NUMBER ' OR
     column_name is null Then
     IF new_references.CI_SEQUENCE_NUMBER < 1 OR new_references.CI_SEQUENCE_NUMBER >  999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


   IF upper(column_name) = 'RULE_WAIVED_PERSON_ID' OR
     column_name is null Then
     IF new_references.RULE_WAIVED_PERSON_ID < 0 OR new_references.RULE_WAIVED_PERSON_ID > 9999999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


   IF upper(column_name) = 'NO_ASSESSMENT_IND' OR
     column_name is null Then
     IF new_references.NO_ASSESSMENT_IND NOT IN ('Y','N') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

   IF upper(column_name) = 'SUP_VERSION_NUMBER' OR
     column_name is null Then
     IF new_references.SUP_VERSION_NUMBER < 0 OR new_references.SUP_VERSION_NUMBER > 999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

   IF upper(column_name) = 'OVERRIDE_ENROLLED_CP' OR
     column_name is null Then
     IF new_references.OVERRIDE_ENROLLED_CP < 0 OR new_references.OVERRIDE_ENROLLED_CP> 999.999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
   IF upper(column_name) = 'OVERRIDE_EFTSU' OR
     column_name is null Then
     IF new_references.OVERRIDE_EFTSU < 0 OR new_references.OVERRIDE_EFTSU > 9999.999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

   IF upper(column_name) = 'OVERRIDE_ACHIEVABLE_CP' OR
     column_name is null Then
     IF new_references.OVERRIDE_ACHIEVABLE_CP < 0 OR new_references.OVERRIDE_ACHIEVABLE_CP > 999.999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;


   IF upper(column_name) = 'DCNT_REASON_CD' OR
     column_name is null Then
     IF new_references.DCNT_REASON_CD <> UPPER(new_references.DCNT_REASON_CD) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;

   IF upper(column_name) = 'CORE_INDICATOR_CODE' OR
     column_name is null Then
     IF new_references.CORE_INDICATOR_CODE <> UPPER(new_references.CORE_INDICATOR_CODE) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
   END IF;

        END Check_Constraints;


end IGS_EN_SU_ATTEMPT_H_PKG;

/
