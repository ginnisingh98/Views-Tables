--------------------------------------------------------
--  DDL for Package Body IGS_EN_SU_ATTEMPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SU_ATTEMPT_PKG" AS
/* $Header: IGSEI36B.pls 120.22 2006/03/02 03:30:18 bdeviset ship $ */

  l_rowid          VARCHAR2(25);
  old_references   IGS_EN_SU_ATTEMPT_ALL%ROWTYPE;
  new_references   IGS_EN_SU_ATTEMPT_ALL%ROWTYPE;
  l_old_cp         NUMBER(10);
  l_new_cp         NUMBER(10);
  l_load_cal_type  IGS_CA_INST.CAL_TYPE%TYPE;
  l_load_seq_num   IGS_CA_INST.SEQUENCE_NUMBER%TYPE;

   -- Cursor to update the enrollment actual column
   -- The field enrollment_actual needs to be updated by 1
   -- if the unit attempt is successful.
   -- decrement by 1 if the unit attempt is discontinued or deleted
  PROCEDURE update_reserved_seat( p_action IN VARCHAR2);

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_uoo_id IN NUMBER ,
    x_enrolled_dt IN DATE ,
    x_unit_attempt_status IN VARCHAR2 ,
    x_administrative_unit_status IN VARCHAR2,
    x_discontinued_dt IN DATE ,
    x_rule_waived_dt IN DATE ,
    x_rule_waived_person_id IN NUMBER,
    x_no_assessment_ind IN VARCHAR2 ,
    x_sup_unit_cd IN VARCHAR2,
    x_sup_version_number IN NUMBER,
    x_exam_location_cd IN VARCHAR2,
    x_alternative_title IN VARCHAR2,
    x_override_enrolled_cp IN NUMBER,
    x_override_eftsu IN NUMBER,
    x_override_achievable_cp IN NUMBER,
    x_override_outcome_due_dt IN DATE,
    x_override_credit_reason IN VARCHAR2,
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2 ,
    x_ci_sequence_number IN NUMBER ,
    x_location_cd IN VARCHAR2 ,
    x_unit_class IN VARCHAR2 ,
    x_ci_start_dt IN DATE ,
    x_ci_end_dt IN DATE ,
    x_administrative_priority IN NUMBER ,
    x_waitlist_dt   IN DATE ,
    x_dcnt_reason_cd IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_org_id IN NUMBER,
    x_gs_version_number IN NUMBER,
    x_enr_method_type   IN VARCHAR2 ,
    x_failed_unit_rule  IN VARCHAR2 ,
    x_cart              IN VARCHAR2 ,
    x_rsv_seat_ext_id   IN NUMBER   ,
    x_org_unit_cd       IN VARCHAR2 ,
    x_grading_schema_code IN VARCHAR2,
    x_subtitle           IN VARCHAR2 ,
    -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
    x_session_id         IN NUMBER ,
    x_deg_aud_detail_id  IN NUMBER ,
    x_student_career_transcript IN VARCHAR2,
    x_student_career_statistics IN VARCHAR2,
    x_waitlist_manual_ind  IN VARCHAR2,--Bug ID: 2554109  added by adhawan
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
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
    -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
    x_wlst_priority_weight_num IN NUMBER,
    x_wlst_preference_weight_num IN NUMBER,
    -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
    x_core_indicator_code IN VARCHAR2,
    X_UPD_AUDIT_FLAG      IN VARCHAR2 DEFAULT 'N',
    X_SS_SOURCE_IND       IN VARCHAR2 DEFAULT 'N'
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    ROWID = x_rowid;
  BEGIN
    l_rowid := x_rowid;
     -- initialising the global variables for bug#5020285
      old_references := NULL;
      new_references := NULL;

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

    /** TRUNCATING the following date fields to remove the hours,minutes and seconds attributes from
        date fields to overcome the lock row and comparison problems w.r.t.2321858 by kkillams **/
      old_references.enrolled_dt     := TRUNC(old_references.enrolled_dt);
      old_references.discontinued_dt := TRUNC(old_references.discontinued_dt);
      old_references.rule_waived_dt  := TRUNC(old_references.rule_waived_dt);
      -- Truncating the following Date fields for the bug fix : 2397855
      old_references.override_outcome_due_dt := TRUNC(old_references.override_outcome_due_dt);
      old_references.waitlist_dt := old_references.waitlist_dt;

    /*************************************************************************/

    -- Populate New Values.
    new_references.uoo_id := x_uoo_id;
    new_references.unit_attempt_status := x_unit_attempt_status;
    new_references.administrative_unit_status:= x_administrative_unit_status;
    IF (old_references.unit_attempt_status IS NULL OR (old_references.unit_attempt_status <> new_references.unit_attempt_status))
	AND  new_references.unit_attempt_status = 'ENROLLED' THEN
	new_references.enrolled_dt := TO_DATE(TO_CHAR(x_enrolled_dt,'DD-MM-YYYY') || ' ' || TO_CHAR(sysdate,'HH24:MI:SS'),'DD-MM-YYYY HH24:MI:SS');
    ELSE
	new_references.enrolled_dt := x_enrolled_dt;
    END IF;
    IF (old_references.unit_attempt_status is null OR (old_references.unit_attempt_status <> new_references.unit_attempt_status))
        AND  new_references.unit_attempt_status IN ('DROPPED','DISCONTIN') THEN
          new_references.discontinued_dt := TO_DATE(TO_CHAR(x_discontinued_dt,'DD-MM-YYYY') || ' ' || TO_CHAR(sysdate,'HH24:MI:SS'),'DD-MM-YYYY HH24:MI:SS');
    ELSE
	  new_references.discontinued_dt := x_discontinued_dt;
    END IF;

    new_references.rule_waived_dt := TRUNC(x_rule_waived_dt);
    new_references.rule_waived_person_id := x_rule_waived_person_id;
    new_references.no_assessment_ind := x_no_assessment_ind;
    new_references.sup_unit_cd := x_sup_unit_cd;
    new_references.sup_version_number := x_sup_version_number;
    new_references.exam_location_cd := x_exam_location_cd;
    new_references.alternative_title := x_alternative_title;
        -- As part of ENCR013 DLD
    IF p_action = 'INSERT' THEN
      -- If the user is override the Value then don't populate the default value
       new_references.override_enrolled_cp := NVL(IGS_EN_GEN_015.enrp_get_appr_cr_pt(x_person_id,x_uoo_id), x_override_enrolled_cp);
       -- Modified as a part of EN317 build.
       new_references.override_achievable_cp := NVL( IGS_EN_GEN_015.enrp_get_appr_cr_pt(x_person_id,x_uoo_id),x_override_achievable_cp);
    ELSE
        new_references.override_enrolled_cp := x_override_enrolled_cp;
        new_references.override_achievable_cp := x_override_achievable_cp;
    END IF;

    new_references.override_eftsu := x_override_eftsu;
    new_references.override_outcome_due_dt := TRUNC(x_override_outcome_due_dt);
    new_references.override_credit_reason := x_override_credit_reason;
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type:= x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.location_cd := x_location_cd;
    new_references.unit_class:= x_unit_class;
    new_references.ci_start_dt := x_ci_start_dt;
    new_references.ci_end_dt := x_ci_end_dt;
    new_references.administrative_priority := x_administrative_priority;
    new_references.waitlist_dt := x_waitlist_dt;
    new_references.dcnt_reason_cd := x_dcnt_reason_cd;
    new_references.org_unit_cd := x_org_unit_cd;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date    := x_last_update_date ;
    new_references.last_updated_by     := x_last_updated_by  ;
    new_references.last_update_login   := x_last_update_login;
    new_references.org_id              := x_org_id           ;
    new_references.gs_version_number   := x_gs_version_number;
    new_references.enr_method_type     := x_enr_method_type  ;
    new_references.failed_unit_rule    := x_failed_unit_rule ;
    new_references.cart                := x_cart             ;
    new_references.rsv_seat_ext_id     := x_rsv_seat_ext_id  ;
    new_references.grading_schema_code := x_grading_schema_code;
    new_references.subtitle            := x_subtitle;
    -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
    new_references.session_id          := x_session_id;
    new_references.deg_aud_detail_id   := x_deg_aud_detail_id;
    new_references.student_career_transcript  := x_student_career_transcript;
    new_references.student_career_statistics  := x_student_career_statistics;
    new_references.waitlist_manual_ind := x_waitlist_manual_ind; --Bug ID: 2554109  added by adhawan
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
    -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
    new_references.wlst_priority_weight_num := x_wlst_priority_weight_num;
    new_references.wlst_preference_weight_num := x_wlst_preference_weight_num;
    -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
    new_references.core_indicator_code := x_core_indicator_code;
    new_references.UPD_AUDIT_FLAG :=  X_UPD_AUDIT_FLAG;
    new_references.SS_SOURCE_IND :=  X_SS_SOURCE_IND;
  END Set_Column_Values;


--For bug 2121602
--Checking whether attempting unit is precluded or not
--added by kkillams,08-MAY-2002
PROCEDURE chk_precluded_unit AS
CURSOR c_adv IS
        SELECT  'x'
        FROM    IGS_AV_STND_UNIT         asu
        WHERE   asu.person_id                   =new_references.person_id       AND
                asu.as_course_cd                =new_references.course_cd       AND
                asu.unit_cd                     =new_references.unit_cd         AND
                asu.version_number              =new_references.version_number  AND
                asu.s_adv_stnd_granting_status IN ('APPROVED','GRANTED')        AND
                asu.s_adv_stnd_recognition_type = 'PRECLUSION';
v_adv_exists    VARCHAR2(1);
BEGIN
      OPEN c_adv;
      FETCH c_adv INTO v_adv_exists;
      IF c_adv%FOUND THEN
      CLOSE c_adv;
          FND_MESSAGE.SET_NAME('IGS','IGS_EN_CANNOT_ATT_PRE_UNIT');
          FND_MESSAGE.SET_TOKEN('UNIT',new_references.unit_cd);
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      CLOSE c_adv;
END chk_precluded_unit;

--
-- For Enhancement Bug 1287292
-- Local Procedure added to check enrollment maximum
-- Called in Before DML
--
PROCEDURE chk_enrollment_max
AS
-- Local variables
 p_uoo_id     NUMBER;
 p_unit_cd    VARCHAR2(10);
 p_version_number NUMBER(3);
 l_actual_enr  NUMBER;
 l_maximum_enr NUMBER;
 l_lvl_unit    VARCHAR2(1);
-- Unit Section Level Cursor
   CURSOR usec_enr_max(p_uoo_id NUMBER) IS
   SELECT NVL(enrollment_maximum,0)
   FROM igs_ps_usec_lim_wlst
   WHERE uoo_id = p_uoo_id;
-- Unit Level Cursor
   CURSOR unit_enr_max ( p_unit_cd VARCHAR2,
                         p_version_number NUMBER ) IS
                    /******************Enhancement  bug no 1517114 -- NVL from 0 made to 999999***********/
   SELECT NVL(enrollment_maximum,999999)
   FROM   igs_ps_unit_ver
   WHERE  unit_cd = p_unit_cd AND
          version_number = p_version_number;
                   /******************Enhancement  bug no 1517114 -- NVL from 0 made to 999999***********/
--
-- Cursor to count the actual enrollment - Unit Section Level
--
-- Bug 19055975
-- previous the cursor was doing a select count(*) from igs_en_su_attempt
-- now changed it to use the enrollment actual from the unit section table
   CURSOR  usec_enr_act(p_uoo_id NUMBER) IS
   SELECT ENROLLMENT_ACTUAL
   FROM  igs_ps_unit_ofr_opt
   WHERE uoo_id = p_uoo_id;
BEGIN
 -- This procedure checks the maximum enrollment for the unit section and
 -- Raises a error message.
 -- When user attempts to confirm a unit attempt for which the maximum enrollment
 -- has been reached, deliver an error message: "Can not confirm enrollment in
 -- unit attempt  UNIT CODE  and VERSION NUMBER.  Maximum enrollment has
 -- been reached."
 -- The enrollment maximum IS SET up IN unit details OR modified IN
 -- unit section details. The system looks first TO unit section details, AND IF
 -- no VALUES are stored AT that LEVEL, THEN looks TO unit details.
 --
 -- Check only if the status is ENROLLED
 IF new_references.unit_attempt_status = 'ENROLLED' AND
    new_references.unit_attempt_status <> NVL(old_references.unit_attempt_status,'Unknown') THEN
 --Intialize the variables from the new references.
                         p_uoo_id := new_references.uoo_id;
                         p_unit_cd := new_references.unit_cd;
                         p_version_number := new_references.version_number;
 -- 1.Get the maximum enroolment values
     l_maximum_enr := 0;
   -- Check in unit section level
   OPEN usec_enr_max(p_uoo_id);
   FETCH usec_enr_max INTO l_maximum_enr;
   CLOSE usec_enr_max;
   -- Check in unit level
   IF l_maximum_enr = 0   THEN
         OPEN  unit_enr_max(p_unit_cd,p_version_number);
     FETCH unit_enr_max INTO l_maximum_enr;
     CLOSE unit_enr_max;
   END IF;

 -- 2.Get the count of actual enrollment
            OPEN  usec_enr_act(p_uoo_id);
            FETCH usec_enr_act INTO l_actual_enr;
            CLOSE usec_enr_act;
      -- Check and raise the Error Message
       IF l_actual_enr >= l_maximum_enr THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_EN_MAX_ENR_REACHED');
                   FND_MESSAGE.SET_TOKEN('UNIT_CODE',p_unit_cd );
                   APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
 END IF;
 -- 3.End of the Procedure
END chk_enrollment_max;

  -- Trigger description :-
  -- "OSS_TST".trg_sua_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_EN_SU_ATTEMPT_ALL
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
   /*  WHO       WHEN        WHAT
     pradhakr   20-Jan-2003  Added a parameter no_assessment_ind to the procedue call IGS_EN_VAL_SUA.enrp_val_sua_ovrd_cp
                             as part of ENCR26 build.
     prraj       22-Oct-2002 Added condition  to check new_references.no_assessment_ind <> 'Y'
|                            in the if clause of the call to IGS_EN_VAL_SUA.enrp_val_sua_ovrd_cp for Audit Build(Bug# )
     pmarada   02-sep-2002   bug 2526021, Assigning the waitlist positions to the waitlisted students, and clearing
                             the ADMINISTRATIVE_PRIORITY value to null when unit attempt status is changed from waitlist to any other status
     ayedubat   02-JUL-2002  Removed the Variation Window Validation added in the previous version and moved to IGSEN04B.pls
                             for the same bug fix:2423605
     ayedubat   26-JUN-2002  Added a new validation to check the Variation Window Cutoff Date for the bug Fix:2423605
     ayedubat   30-MAY-2002  Added a new parameter,p_message_name to the Function:Enrp_Get_Rec_Window
                             call and dsiplaying the returning message for the bug fix:2337161.
     ayedubat   19-APR-2002  Changed the message names in the app_exception call from 'IGS_GE_RECORD_ALREADY_EXISTS'
                             to 'IGS_EN_SUA_NOTENR_RECENR_WIN' while validating the record cutoff date and in the remaining
                             places to the message returned by the calling function as part of the bug fix:2332137
     Sudhir 23-MAY-2002 To   show token for the new message in calling the procedure IGS_EN_VAL_SUA.enrp_val_discont_aus
     svanukur  29-APR-03     Passing uoo_id to  IGS_EN_GEN_010.ENRP_INS_SUAO_DISCON as part of MUS build # 2829262
      myoganat  21-MAY-03    Set override enrolled and override achievable CP to zero for a unit section attempt that is being audited and
                             when the record is an audit attempt record the procedure IGS_EN_VAL_SUA.ENRP_VAL_SUA_OVRD_CP will not get called.
                             - as part of the build ENCR032 - Audit Attempt Credit Points. Bug  #2855870
     kkillams   25-07-2003   New cursor c_unit_opt added to lock the unit oferring option table for a uoo_id, to avoid duplicate
                             administrative priorities w.r.t. 2865921.
     ptandon    03-SEP-2003  Modified the logic as per Waitlist Enhancements Build - Bug# 3052426

     ckasu      27-NOV-2005  Added logic inorder to perform/by pass validations when this was called from
                             add_units_api for Calling Object as 'PLAN' as a part of bug#4666102

   */
            --Getting the max administrative priority value, bug 2526021
          CURSOR c_admin_priority (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
          SELECT max(ADMINISTRATIVE_PRIORITY) FROM igs_en_su_attempt
          WHERE uoo_id = cp_uoo_id;

          CURSOR c_unit_opt (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
          SELECT 1 FROM igs_ps_unit_ofr_opt
                   WHERE uoo_id = cp_uoo_id FOR UPDATE;
          CURSOR cur_load(cp_teach_cal_type          IGS_CA_INST.CAL_TYPE%TYPE,
                          cp_teach_ci_sequence_num   IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS
          SELECT load_cal_type, load_ci_sequence_number FROM igs_ca_teach_to_load_v
                                                        WHERE teach_cal_type = cp_teach_cal_type
                                                        AND   teach_ci_sequence_number = cp_teach_ci_sequence_num
                                                        ORDER BY load_start_dt ASC;

          CURSOR cur_sub_uoo IS
          SELECT sup.unit_cd, sup.version_number
          FROM igs_ps_unit_ofr_opt sub, igs_ps_unit_ofr_opt sup
          WHERE sub.uoo_id = new_references.uoo_id
          AND sub.relation_type = 'SUBORDINATE'
          AND sub.sup_uoo_id = sup.uoo_id;

          CURSOR cur_placement_unit IS
          SELECT 1
          FROM igs_ps_unit_ver
          WHERE unit_cd = new_references.unit_cd
          AND version_number = new_references.version_number
          AND practical_ind = 'Y';
          l_sup_unit_cd igs_ps_unit_ofr_opt.unit_cd%TYPE;
          l_sup_ver igs_ps_unit_ofr_opt.version_number%TYPE;
          l_placement_unit NUMBER;

        l_admin_priority                igs_en_su_attempt.administrative_priority%TYPE;
        v_message_name                  VARCHAR2(30);
        v_message_token                 VARCHAR2(2000);
        v_rule_waived_person_id         IGS_EN_SU_ATTEMPT_ALL.rule_waived_person_id%TYPE;
        v_effective_dt                  DATE;
        v_unit_attempt_status           IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE;
        v_return_val                    IGS_PE_STD_TODO.sequence_number%TYPE;
        v_old_unit_attempt_status       IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE;
        v_old_location_cd               IGS_EN_SU_ATTEMPT_ALL.location_cd%TYPE;
        v_old_unit_class                IGS_EN_SU_ATTEMPT_ALL.unit_class%TYPE;
        cst_duplicate                   CONSTANT  VARCHAR2(10) := 'DUPLICATE';
        cst_completed                   CONSTANT  VARCHAR2(10) := 'COMPLETED';
        cst_discontin                   CONSTANT  VARCHAR2(10) := 'DISCONTIN';
        p_duplicate_course_cd           VARCHAR2(30);
        l_dummy                         NUMBER;
        l_pri_weight                    NUMBER;
        l_pref_weight                   NUMBER;
        l_dummy_value                   NUMBER;
  BEGIN


    --For bug No : 2121602, by kkillams
    --Checking the unit whether unit is precluded or not in advance standing
    IF p_inserting THEN
        chk_precluded_unit;
        -- set override enrolled and override achievable CP to zero for a unit section
        --attempt that is being audited
        IF (new_references.no_assessment_ind = 'Y') THEN
            new_references.override_enrolled_cp := 0;
            new_references.override_achievable_cp := 0;
        END IF;

    END IF;

    IF p_updating THEN
      --set override enrolled and override achievable CP to zero
      --for a unit section attempt that is
      --being audited
      IF old_references.no_assessment_ind = 'N'   AND new_references.no_assessment_ind = 'Y' THEN
         new_references.override_enrolled_cp := 0;
         new_references.override_achievable_cp := 0;
      END IF;
    END IF;

    -- If trigger has not been disabled, perform required processing
    --IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_EN_SU_ATTEMPT_ALL') THEN
    -- Set audit details and discontinuation details
    IF p_inserting THEN
            -- Validate that the IGS_PS_UNIT offering option is being offered.
            IF IGS_EN_VAL_SUA.enrp_val_sua_uoo(
                    new_references.unit_cd,
                    new_references.version_number,
                    new_references.cal_type,
                    new_references.ci_sequence_number,
                    new_references.location_cd,
                    new_references.unit_class,
                    v_message_name,
                'N' ) = FALSE THEN
                    IF (new_references.unit_attempt_status IN (cst_duplicate, cst_discontin, cst_completed)) THEN
                            -- Bypass IGS_PS_UNIT version must be active and offered error for duplicates.
                            NULL;
                    ELSE
                            FND_MESSAGE.SET_NAME('IGS',v_message_name);
                            IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
                    END IF;
            END IF;

    END IF;
IF p_inserting OR p_updating THEN

 IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

            IF p_inserting THEN

                    -- Validate that discontinued date is not entered when p_inserting
                    -- This is temporary code
                    IF new_references.discontinued_dt IS NOT NULL AND
                            (new_references.unit_attempt_status NOT IN (cst_duplicate,cst_discontin)) THEN
                            FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_OPER');
                            IGS_GE_MSG_STACK.ADD;
                            APP_EXCEPTION.RAISE_EXCEPTION;
                    END IF;

            END IF;


                    IF p_updating THEN

                       -- Validate that update is allowed
                       IF IGS_EN_VAL_SUA.enrp_val_sua_update(
                               new_references.person_id,
                               new_references.course_cd,
                               new_references.unit_cd,
                               new_references.cal_type,
                               new_references.ci_sequence_number,
                               new_references.unit_attempt_status,
                               new_references.version_number,
                               new_references.location_cd,
                               new_references.unit_class,
                               TRUNC(new_references.enrolled_dt),
                               TRUNC(new_references.discontinued_dt),
                               new_references.administrative_unit_status,
                               TRUNC(new_references.rule_waived_dt),
                               new_references.rule_waived_person_id,
                               new_references.no_assessment_ind,
                               new_references.sup_unit_cd,
                               new_references.sup_version_number,
                               new_references.exam_location_cd,
                               old_references.version_number,
                               old_references.location_cd,
                               old_references.unit_class,
                               TRUNC(old_references.enrolled_dt),
                               TRUNC(old_references.discontinued_dt),
                               old_references.administrative_unit_status,
                               TRUNC(old_references.rule_waived_dt),
                               old_references.rule_waived_person_id,
                               old_references.no_assessment_ind,
                               old_references.sup_unit_cd,
                               old_references.sup_version_number,
                               old_references.exam_location_cd,
                               v_message_name,
                               new_references.uoo_id) = FALSE THEN
                               FND_MESSAGE.SET_NAME('IGS',v_message_name);
                               IGS_GE_MSG_STACK.ADD;
                               APP_EXCEPTION.RAISE_EXCEPTION;
                       END IF;
                    END IF;

                    -- Validate that insert or update is in the variation
                    -- of enrolments window
                    IF p_inserting THEN
                            IF new_references.enrolled_dt IS NULL THEN
                                    v_effective_dt := SYSDATE;
                            ELSE
                                    v_effective_dt := new_references.enrolled_dt;
                            END IF;
                    ELSE
                            v_effective_dt := SYSDATE;
                    END IF;
                    -- Set IGS_PS_UNIT_OFR_OPT key.
                    IGS_PS_GEN_006.CRSP_GET_UOO_KEY (
                            new_references.unit_cd,
                            new_references.version_number,
                            new_references.cal_type,
                            new_references.ci_sequence_number,
                            new_references.location_cd,
                            new_references.UNIT_CLASS,
                            new_references.uoo_id);
                    -- Validate enrolled date

                    IF IGS_EN_VAL_SUA.enrp_val_sua_enr_dt(
                            new_references.person_id,
                            new_references.course_cd,
                            new_references.enrolled_dt,
                            new_references.unit_attempt_status,
                            new_references.ci_end_dt,
                            '',
                            v_message_name , 'N' ) = FALSE THEN
                             FND_MESSAGE.SET_NAME('IGS',v_message_name);
                            IGS_GE_MSG_STACK.ADD;
                            APP_EXCEPTION.RAISE_EXCEPTION;
                    END IF;

                    -- Validate that student IGS_PS_UNIT attempt can only be confirmed or
                    -- unconfirmed in the record enrolments timeframe.
                    IF (new_references.enrolled_dt IS NULL AND
                         old_references.enrolled_dt IS NOT NULL AND
                         old_references.unit_attempt_status <> 'DROPPED') OR
                        (new_references.enrolled_dt IS NOT NULL AND
                         old_references.enrolled_dt IS NULL) THEN
                            IF new_references.enrolled_dt IS NULL THEN
                                    v_effective_dt := SYSDATE;
                            ELSE
                                    v_effective_dt := new_references.enrolled_dt;
                            END IF;
                            IF IGS_EN_GEN_004.ENRP_GET_REC_WINDOW(
                                    new_references.CAL_TYPE,
                                    new_references.ci_sequence_number,
                                    v_effective_dt,
                                  new_references.uoo_id,
                                  v_message_name) = FALSE THEN
                                    FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                    IGS_GE_MSG_STACK.ADD;
                                    APP_EXCEPTION.RAISE_EXCEPTION;
                            END IF;
                    END IF;
                    -- Validate IGS_RU_RULE waived date

                    IF IGS_EN_VAL_SUA.enrp_val_sua_rule_wv(
                            new_references.rule_waived_dt,
                            new_references.enrolled_dt,
                            v_rule_waived_person_id,
                            v_message_name) = FALSE THEN
                            FND_MESSAGE.SET_NAME('IGS',v_message_name);
                            IGS_GE_MSG_STACK.ADD;
                                    APP_EXCEPTION.RAISE_EXCEPTION;
                    ELSE
                            -- Set IGS_RU_RULE waived IGS_PE_PERSON id from oracle username
                            IF new_references.rule_waived_person_id IS NULL THEN
                                    new_references.rule_waived_person_id := v_rule_waived_person_id;
                            END IF;
                    END IF;


                    -- Validate discontinued date
                    IF   (p_updating AND
                            ( new_references.discontinued_dt IS NULL AND
                            old_references.discontinued_dt IS NOT NULL) OR
                            ( new_references.discontinued_dt IS NOT NULL AND
                            TRUNC(new_references.discontinued_dt) <> TRUNC(old_references.discontinued_dt))) THEN
                            IF IGS_EN_VAL_SUA.enrp_val_sua_discont(
                                    new_references.person_id,
                                    new_references.course_cd,
                                    new_references.unit_cd,
                                    new_references.version_number,
                                    new_references.ci_start_dt,
                                    new_references.enrolled_dt,
                                    new_references.administrative_unit_status,
                                    new_references.unit_attempt_status,
                                    new_references.discontinued_dt,
                                    v_message_name,'N') = FALSE THEN
                                    FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                    IGS_GE_MSG_STACK.ADD;
                                    APP_EXCEPTION.RAISE_EXCEPTION;

                            END IF;
                    END IF;
                    -- Validate administrative IGS_PS_UNIT status
                    --
                    IF p_updating THEN
                            IF (new_references.administrative_unit_status IS NULL AND
                             ((new_references.discontinued_dt IS NOT NULL) OR
                               (old_references.administrative_unit_status IS NOT NULL))) OR
                             (new_references.administrative_unit_status IS NOT NULL AND
                              (old_references.administrative_unit_status IS NULL OR
                              (old_references.administrative_unit_status<> new_references.administrative_unit_status)))
                            THEN
                                    IF IGS_EN_VAL_SUA.enrp_val_discont_aus(
                                            new_references.administrative_unit_status,
                                            new_references.discontinued_dt,
                                            new_references.cal_type,
                                            new_references.ci_sequence_number,
                                            v_message_name,
                                            new_references.uoo_id,
                                            v_message_token ,
                                            'N' ) = FALSE THEN
                                            FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                            IF v_message_name = 'IGS_SS_EN_INVLD_ADMIN_UNITST' THEN
                                               FND_MESSAGE.SET_TOKEN('LIST',v_message_token);
                                            END IF;
                                            IGS_GE_MSG_STACK.ADD;
                                            APP_EXCEPTION.RAISE_EXCEPTION;
                                    END IF;
                            END IF;
                    END IF;
                    -- Validate the teaching period against any intermission. This is performed
                    -- on insert and on removal of the discontinuation date.
                    IF p_inserting OR
                         (p_updating AND old_references.discontinued_dt IS NOT NULL AND
                                    new_references.discontinued_dt IS NULL) THEN
                            IF IGS_EN_VAL_SUA.enrp_val_sua_intrmt(
                                    new_references.person_id,
                                    new_references.course_cd,
                                    new_references.cal_type,
                                    new_references.ci_sequence_number,
                                    v_message_name) = FALSE THEN
                                    FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                    IGS_GE_MSG_STACK.ADD;
                                    APP_EXCEPTION.RAISE_EXCEPTION;
                            END IF;
                    END IF;
                    -- validate research units being inserted or confirmed.
                    IF(p_inserting OR
                        (p_updating AND
                         ((old_references.discontinued_dt IS NOT NULL AND
                                             new_references.discontinued_dt IS NULL) OR
                           (old_references.enrolled_dt IS NULL AND
                                            new_references.enrolled_dt IS NOT NULL) OR
                           (old_references.rule_waived_dt IS NULL AND
                            old_references.unit_attempt_status = 'INVALID' AND
                                             new_references.rule_waived_dt IS NOT NULL)))) AND
                         (new_references.enrolled_dt IS NOT NULL AND new_references.discontinued_dt IS NULL) THEN
                            IF IGS_EN_VAL_SUA.resp_val_sua_cnfrm(
                                                    new_references.person_id,
                                                    new_references.course_cd,
                                                    new_references.unit_cd,
                                                    new_references.version_number,
                                                    new_references.cal_type,
                                                    new_references.ci_sequence_number,
                                                    v_message_name ,
                                                   'N' ) = FALSE THEN
                                    FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                    IGS_GE_MSG_STACK.ADD;
                                    APP_EXCEPTION.RAISE_EXCEPTION;
                            END IF;
                    END IF;

   END IF; --IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

  -- Validate that advanced standing does not already exist
  IF p_inserting OR
      (p_updating AND
      (new_references.enrolled_dt IS NOT NULL AND
       old_references.enrolled_dt IS NULL) OR
      (new_references.discontinued_dt IS  NULL AND
       old_references.discontinued_dt IS NOT NULL) OR
       (new_references.rule_waived_dt IS NOT NULL AND
       old_references.rule_waived_dt IS NULL AND
       old_references.unit_attempt_status = 'INVALID')) THEN

                    IF IGS_EN_VAL_SUA.enrp_val_sua_advstnd(
                            new_references.person_id,
                            new_references.course_cd,
                            '',
                            new_references.unit_cd,
                            new_references.version_number,
                            v_message_name,'N' ) = FALSE THEN
                            FND_MESSAGE.SET_NAME('IGS',v_message_name);
                            IGS_GE_MSG_STACK.ADD;
                                            APP_EXCEPTION.RAISE_EXCEPTION;
                    END IF;
  END IF;

  IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

            -- Set IGS_PS_UNIT attempt status
            IF new_references.unit_attempt_status IS NULL THEN
                    v_unit_attempt_status := 'Unknown';
            ELSE
                    v_unit_attempt_status := new_references.unit_attempt_status;
            END IF;
            --
            -- Added as per the Bug# 2335455.
            -- If the Unit Attempt Status is changing from 'Waitlist' to
            -- any other status then make the 'Waitlisted date' as NULL.
            --

            -- Modified as per Bug# 3052426 - Waitlists Enhancements Build
            -- Modified the If condition and assigned NULL to WLST_PRIORITY_WEIGHT_NUM and
            -- WLST_PREFERENCE_WEIGHT_NUM columns also if Unit Attempt Status is changed from 'Waitlisted' - ptandon
            IF p_updating THEN
              IF NVL(old_references.unit_attempt_status,'Unknown') = 'WAITLISTED' AND
                 NVL(NEW_REFERENCES.unit_attempt_status,'Unknown') IN ('DROPPED','ENROLLED')
              THEN
               NEW_REFERENCES.waitlist_dt := NULL;
               NEW_REFERENCES.ADMINISTRATIVE_PRIORITY := NULL;                            -- clearing waitlist position, pmarada, bug 2526021
               NEW_REFERENCES.WAITLIST_MANUAL_IND     :='N';                              --Bug ID 2554109 adhawan
               NEW_REFERENCES.WLST_PRIORITY_WEIGHT_NUM := NULL;
               NEW_REFERENCES.WLST_PREFERENCE_WEIGHT_NUM := NULL;
              END IF;
            END IF;
            --
            -- End of the new code - added as per the Bug# 2335455.
            --
          -- Assigning waitlist positions for waitlisted students. bug 2526021, pmarada

            -- Modified as per Bug# 3052426 - Waitlists Enhancements Build
            -- Modified so that if waitlist priorities/preferences exist then system should calculate
            -- the waitlist position based on the priority/preference weightage otherwise student would
            -- be put at the end of the waitlist queue (FIFO) - ptandon

          IF p_inserting  OR p_updating THEN
            IF (new_references.UNIT_ATTEMPT_STATUS = 'WAITLISTED'
              AND NVL(old_references.unit_attempt_status,'UNCONFIRM') <>  new_references.unit_attempt_status
              AND new_references.waitlist_dt IS NOT NULL
              AND new_references.administrative_priority IS NULL
              AND new_references.wlst_priority_weight_num IS NULL) THEN
                 Igs_En_Wlst_Gen_Proc.enrp_wlst_pri_pref_calc(new_references.person_id,
                                                              new_references.course_cd,
                                                              new_references.uoo_id,
                                                              l_pri_weight,
                                                              l_pref_weight);

                 IF l_pri_weight IS NOT NULL AND l_pref_weight IS NOT NULL THEN
                    NEW_REFERENCES.WLST_PRIORITY_WEIGHT_NUM := l_pri_weight;
                    NEW_REFERENCES.WLST_PREFERENCE_WEIGHT_NUM := l_pref_weight;
                 ELSE
                    OPEN c_unit_opt(new_references.uoo_id); -- Locking the unit offerring option table for the given uoo_id to avoid duplicate administrative priorities.
                    FETCH c_unit_opt INTO l_dummy;
                    OPEN c_admin_priority(new_references.uoo_id);
                    FETCH c_admin_priority INTO l_admin_priority;
                    CLOSE c_admin_priority;
                    CLOSE c_unit_opt;
                    NEW_REFERENCES.ADMINISTRATIVE_PRIORITY := NVL(l_admin_priority,0) + 1;
                    NEW_REFERENCES.WLST_PRIORITY_WEIGHT_NUM := NULL;
                    NEW_REFERENCES.WLST_PREFERENCE_WEIGHT_NUM := NULL;
                 END IF;
             END IF;
          END IF;
       --End of the code added as part of bug 2526021

            new_references.unit_attempt_status := IGS_EN_GEN_007.ENRP_GET_SUA_STATUS(
                    new_references.person_id,
                    new_references.course_cd,
                    new_references.unit_cd,
                    new_references.version_number,
                    new_references.cal_type,
                    new_references.ci_sequence_number,
                    v_unit_attempt_status,
                    new_references.enrolled_dt,
                    new_references.rule_waived_dt,
                    new_references.discontinued_dt,
                    new_references.waitlist_dt,
                    new_references.uoo_id); -- Added waitlist_dt parameter to call IGS_EN_GEN_007.ENRP_GET_SUA_STATUS.
                                                 -- This is as per the Bug# 2335455.
            IF p_inserting THEN
                    -- Validate against IGS_PS_COURSE attempt status
                    IF IGS_EN_VAL_SUA.enrp_val_sua_insert(
                            new_references.person_id,
                            new_references.course_cd,
                            new_references.unit_attempt_status,
                            v_message_name) = FALSE THEN
                            FND_MESSAGE.SET_NAME('IGS',v_message_name);
                            IGS_GE_MSG_STACK.ADD;
                                            APP_EXCEPTION.RAISE_EXCEPTION;
                    END IF;
                    -- Validate that teaching period is not prior to commencement date
                    -- with the exception of DUPLICATE IGS_PS_UNIT attempts
            END IF;

  END IF; -- IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

  IF p_inserting THEN
     IF IGS_EN_VAL_SUA.enrp_val_sua_ci(
                            new_references.person_id,
                            new_references.course_cd,
                            new_references.cal_type,
                            new_references.ci_sequence_number,
                            new_references.unit_attempt_status,
                            NULL,
                            'T', -- Validation called from trigger
                            v_message_name) = FALSE THEN
                            FND_MESSAGE.SET_NAME('IGS',v_message_name);
                            IGS_GE_MSG_STACK.ADD;
                                            APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
  END IF;

  -- Save details when IGS_PS_UNIT attempt status is set to ENROLLED
  -- to validate for duplicates across all student IGS_PS_UNIT attempts
  IF (p_inserting OR
     (p_updating AND
      new_references.unit_attempt_status <> old_references.unit_attempt_status)) THEN
      IF IGS_EN_VAL_SUA.enrp_val_sua_dupl(
            new_references.person_id,
            new_references.course_cd,
            new_references.unit_cd,
            new_references.version_number,
            new_references.cal_type,
            new_references.ci_sequence_number,
            new_references.unit_attempt_status,
            --The column duplicate_course_cd has been changed to course_cd
            p_duplicate_course_cd,
            v_message_name,
            new_references.uoo_id) = FALSE THEN
            FND_MESSAGE.SET_NAME('IGS',v_message_name);
            IGS_GE_MSG_STACK.ADD;
                                            APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
  END IF;


  IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN
            -- Save rowid and old discontinuation date
            -- if discontinuation details change

            IF p_updating THEN
                    IF (old_references.discontinued_dt IS NOT NULL AND
                       new_references.discontinued_dt IS NULL) OR    -- clear discontinuation details
                      (new_references.discontinued_dt IS NOT NULL AND
                       old_references.discontinued_dt IS NULL) OR      -- add  discontinuation details
                      ((old_references.discontinued_dt IS NOT NULL AND
                         new_references.discontinued_dt IS NOT NULL) AND
                       (TRUNC(old_references.discontinued_dt) <> TRUNC(new_references.discontinued_dt))) THEN
                          IF old_references.discontinued_dt IS NOT NULL THEN
                             IGS_EN_GEN_001.ENRP_DEL_SUAO_DISCON(
                                old_references.person_id,
                                old_references.course_cd,
                                old_references.unit_cd,
                                old_references.cal_type,
                                old_references.ci_sequence_number,
                                old_references.discontinued_dt,
                                old_references.uoo_id);
                          END IF;
                          -- Insert student unit attempt outcome
                          IF new_references.discontinued_dt IS NOT NULL THEN
                             IF IGS_EN_GEN_010.ENRP_INS_SUAO_DISCON(
                                   new_references.person_id,
                                   new_references.course_cd,
                                   new_references.unit_cd,
                                   new_references.cal_type,
                                   new_references.ci_sequence_number,
                                   new_references.ci_start_dt,
                                   new_references.ci_end_dt,
                                   new_references.discontinued_dt,
                                   new_references.administrative_unit_status,
                                   v_message_name,
                                   new_references.uoo_id) = FALSE THEN
                                   FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                   IGS_GE_MSG_STACK.ADD;
                                   APP_EXCEPTION.RAISE_EXCEPTION;
                             END IF;
                          END IF;
                    ELSE
                          IF (old_references.administrative_unit_status IS NOT NULL AND
                            new_references.administrative_unit_status IS NULL) OR
                              (new_references.administrative_unit_status IS NOT NULL AND
                               old_references.administrative_unit_status IS NULL) OR
                            ((old_references.administrative_unit_status IS NOT NULL AND
                               new_references.administrative_unit_status IS NOT NULL) AND
                              (old_references.administrative_unit_status <> new_references.administrative_unit_status))
                          THEN
                                 IF old_references.discontinued_dt IS NOT NULL THEN
                                    IGS_EN_GEN_001.ENRP_DEL_SUAO_DISCON(
                                       old_references.person_id,
                                       old_references.course_cd,
                                       old_references.unit_cd,
                                       old_references.cal_type,
                                       old_references.ci_sequence_number,
                                       old_references.discontinued_dt,
                                       old_references.uoo_id);
                                 END IF;
                                 -- Insert student unit attempt outcome
                                 IF new_references.discontinued_dt IS NOT NULL THEN
                                         IF IGS_EN_GEN_010.ENRP_INS_SUAO_DISCON(
                                                 new_references.person_id,
                                                 new_references.course_cd,
                                                 new_references.unit_cd,
                                                 new_references.cal_type,
                                                 new_references.ci_sequence_number,
                                                 new_references.ci_start_dt,
                                                 new_references.ci_end_dt,
                                                 new_references.discontinued_dt,
                                                 new_references.administrative_unit_status,
                                                 v_message_name,
                                                 new_references.uoo_id) = FALSE THEN
                                                    FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                                    IGS_GE_MSG_STACK.ADD;
                                                    APP_EXCEPTION.RAISE_EXCEPTION;
                                         END IF;
                                 END IF;
                          END IF;
                    END IF;
            END IF;

	    -- Validate alternative IGS_PE_TITLE
            IF (p_inserting AND
                    new_references.unit_attempt_status NOT IN (cst_duplicate,cst_discontin,cst_completed)) OR
                    (p_updating AND
                     ((new_references.alternative_title IS  NULL AND
                    old_references.alternative_title IS NOT NULL) OR
                     (new_references.alternative_title IS NOT NULL AND
                    old_references.alternative_title IS NULL))) THEN
                    IF IGS_EN_VAL_SUA.enrp_val_sua_alt_ttl(
                            new_references.unit_cd,
                            new_references.version_number,
                            new_references.alternative_title,
                            v_message_name) = FALSE THEN
                            FND_MESSAGE.SET_NAME('IGS',v_message_name);
                            IGS_GE_MSG_STACK.ADD;
                                            APP_EXCEPTION.RAISE_EXCEPTION;
                    END IF;
            END IF;
  END IF; --IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

  -- Validate override enrolled and achievable credit points
  IF  new_references.no_assessment_ind <> 'Y'   THEN
      --skip validation of override enrolled and achievable credit points for audited record

                                IF (p_inserting AND
                                        new_references.unit_attempt_status NOT IN (cst_duplicate,cst_discontin,cst_completed) AND
                                         new_references.override_enrolled_cp IS  NULL) OR
                                        (p_updating AND
                                        (new_references.override_enrolled_cp IS  NULL AND
                                        old_references.override_enrolled_cp IS NOT NULL) OR
                                        (new_references.override_enrolled_cp IS NOT NULL AND
                                        (old_references.override_enrolled_cp IS NULL OR
                                        old_references.override_enrolled_cp <> new_references.override_enrolled_cp)) OR
                                        (((new_references.override_achievable_cp IS  NULL AND
                                        old_references.override_achievable_cp IS NOT NULL) OR
                                        (new_references.override_achievable_cp IS NOT NULL AND
                                        (old_references.override_achievable_cp IS NULL OR
                                        old_references.override_achievable_cp <> new_references.override_achievable_cp)))) OR
                                        (new_references.override_eftsu IS  NULL AND
                                        old_references.override_eftsu IS NOT NULL) OR
                                        (new_references.override_eftsu IS NOT NULL AND
                                        (old_references.override_eftsu IS NULL OR
                                        old_references.override_eftsu <> new_references.override_eftsu)))
                                        THEN
                                        IF IGS_EN_GEN_015.enrp_get_appr_cr_pt(new_references.person_id,new_references.uoo_id) IS NULL AND
                                           IGS_EN_VAL_SUA.enrp_val_sua_ovrd_cp(
                                                new_references.unit_cd,
                                                new_references.version_number,
                                                new_references.override_enrolled_cp,
                                                new_references.override_achievable_cp,
                                                new_references.override_eftsu,
                                                v_message_name,
                                                new_references.uoo_id, --New parameter uoo_id is added w.r.t. 2375757 by kkillams
                                                new_references.no_assessment_ind) = FALSE THEN
                                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                                IGS_GE_MSG_STACK.ADD;
                                               APP_EXCEPTION.RAISE_EXCEPTION;
                                        END IF;
                                END IF;
  END IF; -- IF  new_references.no_assessment_ind <> 'Y'   THEN

  -- Validate override credit reason
  IF IGS_EN_VAL_SUA.enrp_val_sua_cp_rsn(
                                new_references.override_enrolled_cp,
                                new_references.override_achievable_cp,
                                new_references.override_credit_reason,
                                v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  --ading the following validations as part of placement build to populate the
  --sup unit cd and sup version number if context unit is a subordinate unit

  IF p_inserting  OR p_updating THEN

     OPEN cur_sub_uoo ;
     FETCH cur_sub_uoo INTO l_sup_unit_cd, l_sup_ver;
     IF cur_sub_uoo%FOUND THEN
        new_references.sup_unit_cd := l_sup_unit_cd;
        new_references.sup_version_number := l_sup_ver;
     END IF;
     CLOSE cur_sub_uoo;

  END IF;

  IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

                        -- If required add a todo entry to forced the re-checking of the IGS_PS_UNIT IGS_RU_RULEs
                        -- for the student. This is done in insert of a new ENROLLED/INVALID IGS_PS_UNIT
                        -- attempt, on the confirmation of a IGS_PS_UNIT attempt or on lifting of a
                        -- discontinuation of a IGS_PS_UNIT attempt.
                        IF new_references.unit_attempt_status = 'ENROLLED' OR
                            new_references.unit_attempt_status = 'INVALID' THEN
                                IF p_inserting OR
                                     (p_updating AND
                                      ((old_references.enrolled_dt IS NULL AND
                                         new_references.enrolled_dt IS NOT NULL) OR
                                        (old_references.enrolled_dt IS NOT NULL AND
                                         new_references.enrolled_dt IS NULL) OR
                                        (old_references.discontinued_dt IS NOT NULL AND
                                          new_references.discontinued_dt IS NULL) OR
                                         (old_references.discontinued_dt IS NULL AND
                                           new_references.discontinued_dt IS NOT NULL) OR
                                         (new_references.rule_waived_dt IS NOT NULL AND
                                          old_references.rule_waived_dt IS NULL) OR
                                         (old_references.rule_waived_dt IS NOT NULL AND
                                          new_references.rule_waived_dt IS NULL))) THEN
                                        v_return_val := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(new_references.person_id,
                                                'UNIT-RULES',
                                                NULL,
                                                'Y');
                                END IF;
                        END IF;
                        -- If a IGS_PS_UNIT attempt was unconfirmed from being enrolled, add a todo entry
                        -- to force a re-checking of the students IGS_PS_UNIT rules.
                        IF p_updating AND
                             new_references.unit_attempt_status = 'UNCONFIRM' AND
                             old_references.unit_attempt_status = 'ENROLLED' THEN
                                v_return_val := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(new_references.person_id,
                                        'UNIT-RULES',
                                        NULL,
                                        'Y');
                        END IF;
                        -- If required, add a todo entry to forced the maintenance of default
                        -- stdnt_unit_atmpt_ass_items for the student.
                        -- The todo entry is created for students that have:
                        --      1. have just enrolled
                        --      2. had their enrolment status changed
                        --      3. had their IGS_AD_LOCATION and class details changed
                        IF (p_inserting AND
                             new_references.unit_attempt_status = 'ENROLLED') OR
                                     (p_updating AND
                                      ((old_references.unit_attempt_status <>
                                        new_references.unit_attempt_status) OR
                                      (old_references.location_cd <>
                                       new_references.location_cd) OR
                                      (old_references.unit_class<>
                                       new_references.unit_class))) THEN
                                IF p_inserting THEN
                                        v_old_unit_attempt_status       := NULL;
                                        v_old_location_cd               := NULL;
                                        v_old_unit_class                := NULL;
                                ELSE
                                        v_old_unit_attempt_status       := old_references.unit_attempt_status;
                                        v_old_location_cd               := old_references.location_cd;
                                        v_old_unit_class                := old_references.unit_class;
                                END IF;
                                IGS_AS_GEN_007.ASSP_INS_SUAAI_TODO(
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.unit_cd,
                                        new_references.cal_type,
                                        new_references.ci_sequence_number,
                                        v_old_unit_attempt_status,
                                        new_references.unit_attempt_status,
                                        v_old_location_cd,
                                        new_references.location_cd,
                                        v_old_unit_class,
                                        new_references.unit_class,
                                        new_references.uoo_id);
                        END IF;

                  IF p_updating THEN
                   IF (old_references.unit_attempt_status <> new_references.unit_attempt_status) AND
                      (new_references.unit_attempt_status IN ('DROPPED', 'DISCONTIN')) THEN
                      l_old_cp := NULL;
                      l_load_cal_type := NULL;
                      l_load_seq_num := NULL;
                      OPEN cur_load(new_references.cal_type, new_references.ci_sequence_number);
                      FETCH cur_load INTO l_load_cal_type, l_load_seq_num;
                      IF cur_load%FOUND THEN
                            IGS_EN_PRC_LOAD.enrp_get_prg_eftsu_cp(
                                        p_person_id       =>new_references.person_id,
                                        p_course_cd       =>new_references.course_cd,
                                        p_cal_type        =>l_load_cal_type,
                                        p_sequence_number =>l_load_seq_num,
                                        p_eftsu_total     =>l_dummy_value,
                                        p_credit_points   => l_old_cp);
                      END IF;
                      CLOSE cur_load;
                   END IF;
                END IF;

             IF p_updating THEN
                IF (old_references.unit_attempt_status <> new_references.unit_attempt_status) AND
                  (new_references.unit_attempt_status = 'ENROLLED') THEN
                  OPEN cur_placement_unit;
                FETCH cur_placement_unit INTO l_placement_unit;
                IF cur_placement_unit%FOUND THEN
                   IGS_EN_WORKFLOW.student_placement_event (
                        P_person_id => new_references.person_id,
                        P_program_cd => new_references.course_cd,
                        P_unit_cd => new_references.unit_cd,
                        P_unit_class => new_references.unit_class,
                        P_location_cd => new_references.location_cd,
                        p_uoo_id => new_references.uoo_id);
                END IF;
            CLOSE cur_placement_unit;
            END IF;
           END IF;
  END IF; -- IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

 END IF; -- IF p_inserting OR p_updating THEN
  IF p_deleting THEN

                        -- Validate  student IGS_PS_UNIT attempt
                        IF IGS_EN_VAL_SUA.enrp_val_sua_delete(
                                old_references.person_id,
                                old_references.course_cd,
                                old_references.unit_cd,
                                'T', -- indicates trigger validation
                                old_references.unit_attempt_status,
                                old_references.cal_type,
                                old_references.ci_sequence_number,
                                old_references.discontinued_dt,
                                SYSDATE,
                                v_message_name,
                                old_references.uoo_id) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                                        APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                        -- Save student IGS_PS_COURSE attempt details in package table information
                        -- so that IGS_PS_COURSE attempt status can be updated in
                        -- after statement trigger
                        IF IGS_EN_GEN_012.ENRP_UPD_SCA_STATUS(
                                old_references.person_id,
                                old_references.course_cd,
                                v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                        -- Save student IGS_PS_COURSE attempt details in package table information
                        -- so that student IGS_PS_UNIT transfer detail can be deleted  in an
                        -- after statement trigger
                        IF IGS_EN_GEN_001.ENRP_DEL_SUA_SUT(
                                old_references.person_id,
                                old_references.course_cd,
                                old_references.unit_cd,
                                old_references.cal_type,
                                old_references.ci_sequence_number,
                                old_references.unit_attempt_status,
                                v_message_name,
                                old_references.uoo_id) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                        IF old_references.unit_attempt_status = 'ENROLLED' THEN
                                v_return_val := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(old_references.person_id,
                                        'UNIT-RULES',
                                        NULL,
                                        'Y');
                        END IF;
                        IF NOT IGS_EN_SUA_API.chk_sup_del_alwd( old_references.person_id,
                                           old_references.course_cd,
                                           old_references.uoo_id) THEN
                                FND_MESSAGE.SET_NAME('IGS','IGS_EN_SUP_DEL_NOTALWD');
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;

  END IF; --   IF p_deleting THEN


  END BeforeRowInsertUpdateDelete1;
-- Procedure for checking the uniqueness
PROCEDURE Check_Uniqueness AS
-- The Unique key has been commented as part of the bug fix 2554109
-- The uniqueness will be validated by the the new function igs_en_wlst_gen_proc.enrp_resequence_wlst();
BEGIN

  /*This Uk check was added as part of MUS build, # 2829262*/
  IF Get_Uk_For_Validation(x_unit_cd                 => new_references.unit_cd,
                           x_cal_type                => new_references.cal_type,
                           x_ci_sequence_number      => new_references.ci_sequence_number,
                           x_location_cd             => new_references.location_cd,
                           x_unit_class              => new_references.unit_class,
                           x_person_id               => new_references.person_id,
                           x_course_cd               => new_references.course_cd,
                           x_version_number          => new_references.version_number
                           ) THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_MULTI_ORG_DUP_REC');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

END Check_Uniqueness;

  -- Trigger description :-
  -- "OSS_TST".trg_sua_br_iud_fin
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_EN_SU_ATTEMPT_ALL
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
        v_sequence_number       NUMBER;
        l_special_fee           NUMBER;
        l_apply_spl_fee         BOOLEAN;
        l_load_ci_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
        l_load_cal_type           IGS_CA_INST.CAL_TYPE%TYPE;

   CURSOR cur_special_fee IS
          SELECT count(*)
            FROM IGS_PS_USEC_SP_FEES
           WHERE uoo_id = NVL(old_references.uoo_id, new_references.uoo_id)
             AND closed_flag = 'N';

   CURSOR cur_cal_info IS
        SELECT load_ci_sequence_number, load_cal_type
          FROM igs_ca_teach_to_load_v
         WHERE teach_cal_type = NVL(old_references.cal_type, new_references.cal_type)
           AND teach_ci_sequence_number = NVL(old_references.ci_sequence_number,new_references.ci_sequence_number)
           ORDER BY load_start_dt ASC;

   CURSOR  cur_sua_ref_cds IS
        Select sref.rowid,sref.*
        From IGS_AS_SUA_REF_CDS sref
        Where sref.person_id = old_references.person_id
        And sref.course_cd = old_references.course_cd
        And sref.uoo_id = old_references.uoo_id
        And sref.deleted_date is null;

  BEGIN
        -- anilk, Audit special fee build
        OPEN cur_special_fee;
        FETCH cur_special_fee INTO l_special_fee;
        CLOSE cur_special_fee;

        IF l_special_fee = 0 THEN
          l_apply_spl_fee := FALSE;
        ELSE
          l_apply_spl_fee := TRUE;
        END IF;

        IF l_apply_spl_fee THEN
         IF p_inserting THEN
             l_apply_spl_fee := TRUE;
         ELSIF p_updating AND new_references.unit_attempt_status <> old_references.unit_attempt_status THEN
             l_apply_spl_fee := TRUE;
         ELSIF p_deleting THEN
             l_apply_spl_fee := TRUE;
         ELSE
             l_apply_spl_fee := FALSE;
         END IF;
        END IF;

        IF l_apply_spl_fee THEN

          OPEN cur_cal_info;
          FETCH cur_cal_info INTO  l_load_ci_sequence_number, l_load_cal_type;
          CLOSE cur_cal_info;

          v_sequence_number := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(
            NVL(old_references.person_id, new_references.person_id),
            'SPECIAL_FEE',
            SYSDATE,
            'Y');

          IGS_GE_GEN_003.GENP_INS_TODO_REF(
            NVL(old_references.person_id,new_references.person_id),
            'SPECIAL_FEE',
            v_sequence_number,
            l_load_cal_type,
            l_load_ci_sequence_number,
            NVL(old_references.course_cd, new_references.course_cd),
            NVL(old_references.unit_cd, new_references.unit_cd),
            NULL,
            NVL(old_references.uoo_id, new_references.uoo_id));
        END IF;
        -- END, anilk, Audit special fee build

        -- Log an entry in the IGS_PE_STD_TODO table, indicating that a fee re-assessment
        -- is required.
        IF p_inserting OR p_updating THEN
                v_sequence_number := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(
                                        new_references.person_id,
                                        'FEE_RECALC',
                                        SYSDATE,
                                        'Y');
        ELSE
                v_sequence_number := IGS_GE_GEN_003.GENP_INS_STDNT_TODO(
                                        old_references.person_id,
                                        'FEE_RECALC',
                                        SYSDATE,
                                        'Y');
        END IF;

        --logic for marking unit attempt reference codes as dropped
        --when the unit attempt is being dropped
        IF p_updating AND
           old_references.unit_attempt_status <> 'DROPPED' AND
           new_references.unit_attempt_status = 'DROPPED' THEN

            FOR v_cur_sua_ref_cds IN cur_sua_ref_cds LOOP
              igs_as_sua_ref_cds_pkg.update_row (
                   x_rowid                 => v_cur_sua_ref_cds.rowid,
                   x_suar_id               => v_cur_sua_ref_cds.suar_id,
                   x_person_id             => v_cur_sua_ref_cds.person_id,
                   x_course_cd             => v_cur_sua_ref_cds.course_cd,
                   x_uoo_id                => v_cur_sua_ref_cds.uoo_id,
                   x_reference_code_id     => v_cur_sua_ref_cds.reference_code_id,
                   x_reference_cd_type     => v_cur_sua_ref_cds.reference_cd_type,
                   x_reference_cd          => v_cur_sua_ref_cds.reference_cd,
                   x_applied_course_cd     => v_cur_sua_ref_cds.applied_course_cd,
                   x_deleted_date          => SYSDATE,
                   x_mode                  => 'R' );
            END LOOP;

        END IF;

  END BeforeRowInsertUpdateDelete2;



  -- Trigger description :-
  -- "OSS_TST".trg_sua_ar_iud
  -- AFTER INSERT OR DELETE OR UPDATE
  -- ON IGS_EN_SU_ATTEMPT_ALL
  -- FOR EACH ROW
  PROCEDURE AfterRowInsertUpdateDelete3(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
        v_message_name          VARCHAR2(30);
        v_rowid_saved           BOOLEAN := FALSE;
  BEGIN
        -- If trigger has not been disabled, perform required processing
--      IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_EN_SU_ATTEMPT_ALL') THEN
                IF(p_updating AND
                    old_references.unit_attempt_status <> new_references.unit_attempt_status) OR
                   p_inserting THEN
                        -- update of student IGS_PS_COURSE attempt after student IGS_PS_UNIT attempt is posted
                        -- to the database
                        IF v_rowid_saved = FALSE  THEN
                                 -- Save the rowid of the current row.
                           IF v_rowid_saved = FALSE    THEN
                             IF IGS_EN_GEN_012.ENRP_UPD_SCA_STATUS(
                                new_references.person_id,
                                new_references.course_cd,
                                v_message_name) = FALSE THEN
                                      FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                      IGS_GE_MSG_STACK.ADD;
                                      APP_EXCEPTION.RAISE_EXCEPTION;
                              END IF;
                              v_rowid_saved := TRUE;
                          END IF;
                        END IF;
                END IF;
--      END IF;
  END AfterRowInsertUpdateDelete3;

  -- Trigger description :-
  -- "OSS_TST".trg_sua_ar_u_hist
  -- AFTER UPDATE
  -- ON IGS_EN_SU_ATTEMPT_ALL
  -- FOR EACH ROW
  PROCEDURE AfterRowUpdate4(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
  BEGIN
        -- create a history
        IGS_EN_GEN_010.ENRP_INS_SUA_HIST( old_references.person_id,
                old_references.course_cd,
                old_references.unit_cd,
                old_references.cal_type,
                old_references.ci_sequence_number,
                new_references.version_number,
                old_references.version_number,
                new_references.location_cd,
                old_references.location_cd,
                new_references.unit_class,
                old_references.unit_class,
                new_references.enrolled_dt,
                old_references.enrolled_dt,
                new_references.unit_attempt_status,
                old_references.unit_attempt_status,
                new_references.administrative_unit_status,
                old_references.administrative_unit_status,
                new_references.discontinued_dt,
                old_references.discontinued_dt,
                new_references.rule_waived_dt,
                old_references.rule_waived_dt,
                new_references.rule_waived_person_id,
                old_references.rule_waived_person_id,
                new_references.no_assessment_ind,
                old_references.no_assessment_ind,
                new_references.exam_location_cd,
                old_references.exam_location_cd,
                new_references.sup_unit_cd,
                old_references.sup_unit_cd,
                new_references.sup_version_number,
                old_references.sup_version_number,
                new_references.alternative_title,
                old_references.alternative_title,
                new_references.override_enrolled_cp,
                old_references.override_enrolled_cp,
                new_references.override_eftsu,
                old_references.override_eftsu,
                new_references.override_achievable_cp,
                old_references.override_achievable_cp,
                new_references.override_outcome_due_dt,
                old_references.override_outcome_due_dt,
                new_references.override_credit_reason,
                old_references.override_credit_reason,
                new_references.last_updated_by,
                old_references.last_updated_by,
                new_references.last_update_date,
                old_references.last_update_date,
                new_references.dcnt_reason_cd,
                old_references.dcnt_reason_Cd,
                old_references.uoo_id,
                new_references.core_indicator_code,
                old_references.core_indicator_code);
  END AfterRowUpdate4;
  -- Trigger description :-
  -- "OSS_TST".trg_sua_as_iud
  -- AFTER INSERT OR DELETE OR UPDATE
  -- ON IGS_EN_SU_ATTEMPT_ALL


  PROCEDURE Check_Parent_Existance AS
  BEGIN

   /*  WHO         WHEN            WHAT
       ckasu       27-NOV-2005     Added logic inorder toby pass validation IGS_LOOKUPS_VIEW_PKG.GET_PK_FOR_VALIDATION
                                   when IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop = 'PLAN' since Plaaning Sheet Records
                                   are created in 'PLANNED' Status which is not a looup value as a part of bug#4666102

   */

    IF igs_en_su_attempt_pkg.pkg_source_of_drop  = 'SWAP' THEN
       RETURN;
    END IF;
    IF (((old_references.administrative_unit_status= new_references.administrative_unit_status)) OR
        ((new_references.administrative_unit_status IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AD_ADM_UNIT_STAT_PKG.Get_PK_For_Validation (
        new_references.administrative_unit_status,'N')      THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    -- Check whether Grading schema code and gs_version_number are present in the master table IGS_AS_GRD_SCHEMA
    IF (
         (
           (old_references.grading_schema_code = new_references.grading_schema_code) AND
           (old_references.gs_version_number = new_references.gs_version_number    )
         )
         OR
         (
           (new_references.grading_schema_code IS NULL) OR
           (new_references.gs_version_number IS NULL)
         )
       ) THEN
      NULL;
    ELSIF NOT IGS_AS_GRD_SCHEMA_PKG.Get_PK_For_Validation (
           new_references.grading_schema_code,
           new_references.gs_version_number ) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF (((old_references.CAL_TYPE = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number) AND
         (old_references.ci_start_dt = new_references.ci_start_dt) AND
         (old_references.ci_end_dt = new_references.ci_end_dt)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL) OR
         (new_references.ci_start_dt IS NULL) OR
         (new_references.ci_end_dt IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_CA_INST_PKG.Get_UK_For_Validation (
        new_references.cal_type,
        new_references.ci_sequence_number,
        new_references.ci_start_dt,
        new_references.ci_end_dt  )     THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF (((old_references.exam_location_cd = new_references.exam_location_cd)) OR
        ((new_references.exam_location_cd IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.exam_location_cd,'N'
        )       THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    IF (((old_references.rule_waived_person_id = new_references.rule_waived_person_id)) OR
        ((new_references.rule_waived_person_id IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.rule_waived_person_id         )  THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd
        )       THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    IF (((old_references.unit_attempt_status = new_references.unit_attempt_status)) OR
        ((new_references.unit_attempt_status IS NULL)) OR (IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NOT NULL
          AND IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop = 'PLAN') ) THEN
      NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.GET_PK_FOR_VALIDATION('UNIT_ATTEMPT_STATUS',
                                                        new_references.unit_attempt_status) THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    IF (((old_references.sup_unit_cd = new_references.sup_unit_cd) AND
         (old_references.sup_version_number = new_references.sup_version_number)) OR
        ((new_references.sup_unit_cd IS NULL) OR
         (new_references.sup_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_PS_UNIT_VER_PKG.Get_PK_For_Validation (
        new_references.sup_unit_cd,
        new_references.sup_version_number
        )       THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type= new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number) AND
         (old_references.location_cd = new_references.location_cd) AND
         (old_references.unit_class= new_references.unit_class)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL) OR
         (new_references.location_cd IS NULL) OR
         (new_references.unit_class IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_PS_UNIT_OFR_OPT_PKG.Get_PK_For_Validation (
        new_references.unit_cd,
        new_references.version_number,
        new_references.cal_type,
        new_references.ci_sequence_number,
        new_references.location_cd,
        new_references.unit_class
        )       THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    IF ( (old_references.dcnt_reason_cd = new_references.dcnt_reason_cd) OR
          (new_references.dcnt_reason_Cd IS NULL ) ) THEN
      NULL;
    ELSIF NOT IGS_EN_DCNT_REASONCD_PKG.Get_PK_For_Validation (
         new_references.dcnt_reason_cd
        )       THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF ( (old_references.rsv_seat_ext_id = new_references.rsv_seat_ext_id) OR
          (new_references.rsv_seat_ext_id IS NULL ) ) THEN
      NULL;
    ELSIF NOT IGS_PS_RSV_EXT_PKG.Get_PK_For_Validation (
         new_references.rsv_seat_ext_id
        )       THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;


    IF (((old_references.grading_schema_code = new_references.grading_schema_code) AND
         (old_references.gs_version_number = new_references.gs_version_number) AND
         (old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.grading_schema_code IS NULL) OR
         (new_references.gs_version_number IS NULL) OR
         (new_references.uoo_id IS NULL) )) THEN
       NULL;
    ELSIF NOT IGS_PS_USEC_GRD_SCHM_PKG.Get_UK_For_Validation ( new_references.grading_schema_code,
                                                               new_references.gs_version_number,
                                                               new_references.uoo_id
                                                             )  THEN

            IF (((old_references.version_number = new_references.version_number) AND
                 (old_references.grading_schema_code = new_references.grading_schema_code) AND
                 (old_references.gs_version_number = new_references.gs_version_number) AND
                 (old_references.unit_cd = new_references.unit_cd)) OR
               ((new_references.version_number IS NULL) OR
                (new_references.grading_schema_code IS NULL) OR
                (new_references.gs_version_number IS NULL) OR
                (new_references.unit_cd IS NULL) )) THEN
              NULL;
            ELSIF NOT IGS_PS_UNIT_GRD_SCHM_PKG.Get_UK_For_Validation ( new_references.version_number,
                                                                       new_references.grading_schema_code,
                                                                       new_references.gs_version_number,
                                                                       new_references.unit_cd
                                                                     )  THEN

                 Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                 IGS_GE_MSG_STACK.ADD;
                 APP_EXCEPTION.RAISE_EXCEPTION;
            END IF;
    END IF;

  END Check_Parent_Existance;


  PROCEDURE Check_Child_Existance AS
  CURSOR CUR_IGS_AS_SU_ATMPT_ITM IS
     SELECT ROWID
     FROM   IGS_AS_SU_ATMPT_ITM
     WHERE  person_id = old_references.person_id
     AND    course_cd = old_references.course_cd
     AND    uoo_id = old_references.uoo_id;

     CURSOR CUR_IGS_EN_SU_ATTEMPT_H IS
     SELECT ROWID
     FROM   IGS_EN_SU_ATTEMPT_H_ALL
     WHERE  person_id = old_references.person_id
     AND    course_cd = old_references.course_cd
     AND    uoo_id = old_references.uoo_id;
  BEGIN
    IGS_AS_MSHT_SU_ATMPT_PKG.GET_FK_IGS_EN_SU_ATTEMPT (
      old_references.person_id,
      old_references.course_cd,
      old_references.uoo_id
         );
     /*deleting the history record*/
     FOR IGS_EN_SU_ATTEMPT_H_REC IN CUR_IGS_EN_SU_ATTEMPT_H LOOP
        IGS_EN_SU_ATTEMPT_H_PKG.DELETE_ROW(X_ROWID => IGS_EN_SU_ATTEMPT_H_REC.ROWID);
     END LOOP;
     FOR IGS_AS_SU_ATMPT_ITM_REC IN CUR_IGS_AS_SU_ATMPT_ITM LOOP
        IGS_AS_SU_ATMPT_ITM_PKG.DELETE_ROW(X_ROWID => IGS_AS_SU_ATMPT_ITM_REC.ROWID);
     END LOOP;
    IGS_AS_SU_STMPTOUT_PKG.GET_FK_IGS_EN_SU_ATTEMPT (
      old_references.person_id,
      old_references.course_cd,
      old_references.uoo_id
        );
    IGS_PS_STDNT_UNT_TRN_PKG.GET_FK_IGS_EN_SU_ATTEMPT (
      old_references.person_id,
      old_references.course_cd,
      old_references.uoo_id
           );

    IGS_AS_ANON_ID_US_PKG.GET_FK_IGS_EN_SU_ATTEMPT (
      old_references.person_id,
      old_references.course_cd,
      old_references.uoo_id
        );
  --Bug 3199686
   IGS_AS_SUA_SES_ATTS_pkg.GET_FK_IGS_EN_SU_ATTEMPT(
      old_references.person_id,
      old_references.course_cd,
      old_references.uoo_id
        );

  END Check_Child_Existance;
 -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    29-APR-03    changed the PK columns as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------
  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_uoo_id IN NUMBER
       ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      uoo_id = x_uoo_id
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

  PROCEDURE GET_UFK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_start_dt IN DATE,
    x_end_dt IN DATE
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    cal_type= x_cal_type
      AND      ci_sequence_number = x_sequence_number
      AND      ci_start_dt = x_start_dt
      AND      ci_end_dt = x_end_dt ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUA_CI_UFK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_UFK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    exam_location_cd = x_location_cd ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUA_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE GET_FK_IGS_AS_GRD_SCH_GRADE (
    x_grading_schema_code IN VARCHAR2 ,
    x_gs_version_number   IN NUMBER
    ) AS
     CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    grading_schema_code = x_grading_schema_code
               AND
               gs_version_number =  x_gs_version_number ;

    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUA_GS_FK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
    END GET_FK_IGS_AS_GRD_SCH_GRADE;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    rule_waived_person_id = x_person_id ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUA_PE_FK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUA_SCA_FK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_EN_STDNT_PS_ATT;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_unit_attempt_status IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    unit_attempt_status = x_unit_attempt_status ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUA_LKUPV_FK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    sup_unit_cd = x_unit_cd
      AND      sup_version_number = x_version_number
      OR       (unit_cd = x_unit_cd
      AND      version_number = x_version_number )  ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUA_SUP_UV_FK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_PS_UNIT_VER;

  PROCEDURE GET_FK_IGS_PS_UNIT (
    x_unit_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    unit_cd = x_unit_cd ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUA_UN_FK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_PS_UNIT;

  PROCEDURE GET_FK_IGS_PS_UNIT_OFR_OPT (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_location_cd IN VARCHAR2,
    x_unit_class IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type= x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      location_cd = x_location_cd
      AND      unit_class= x_unit_class ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUA_UOO_UFK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_PS_UNIT_OFR_OPT;

  PROCEDURE GET_UFK_IGS_PS_UNIT_OFR_OPT (
    x_uoo_id IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    uoo_id = x_uoo_id ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_SUA_UOO_UFK');
      IGS_GE_MSG_STACK.ADD;
                CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_UFK_IGS_PS_UNIT_OFR_OPT;

 PROCEDURE  GET_UFK_IGS_PS_UNIT_GRD_SCHM ( x_version_number IN NUMBER,
                                          x_grading_schema_code IN VARCHAR2,
                                          x_gs_version_number IN NUMBER,
                                          x_unit_cd IN VARCHAR2
                                        )  AS
  CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    version_number = x_version_number
      AND      grading_schema_code = x_grading_schema_code
      AND      gs_version_number = x_gs_version_number
      AND      unit_cd = x_unit_cd ;

  lv_rowid   cur_rowid%ROWTYPE;
 BEGIN
   OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SUA_GRD_FK');
      IGS_GE_MSG_STACK.ADD;
      CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
 END GET_UFK_IGS_PS_UNIT_GRD_SCHM;


 PROCEDURE  GET_UFK_IGS_PS_USEC_GRD_SCHM ( x_grading_schema_code IN VARCHAR2,
                                          x_gs_version_number IN NUMBER,
                                          x_uoo_id IN NUMBER
                                        )  AS
 CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    grading_schema_code = x_grading_schema_code
      AND      gs_version_number = x_gs_version_number
      AND      uoo_id = x_uoo_id ;

  lv_rowid   cur_rowid%ROWTYPE;
 BEGIN
   OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SUA_GRD_FK');
      IGS_GE_MSG_STACK.ADD;
      CLOSE cur_rowid;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;
 END GET_UFK_IGS_PS_USEC_GRD_SCHM;




  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_uoo_id IN NUMBER ,
    x_enrolled_dt IN DATE ,
    x_unit_attempt_status IN VARCHAR2,
    x_administrative_unit_status IN VARCHAR2 ,
    x_discontinued_dt IN DATE ,
    x_rule_waived_dt IN DATE ,
    x_rule_waived_person_id IN NUMBER,
    x_no_assessment_ind IN VARCHAR2 ,
    x_sup_unit_cd IN VARCHAR2,
    x_sup_version_number IN NUMBER,
    x_exam_location_cd IN VARCHAR2,
    x_alternative_title IN VARCHAR2 ,
    x_override_enrolled_cp IN NUMBER,
    x_override_eftsu IN NUMBER,
    x_override_achievable_cp IN NUMBER ,
    x_override_outcome_due_dt IN DATE ,
    x_override_credit_reason IN VARCHAR2,
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2 ,
    x_unit_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER ,
    x_location_cd IN VARCHAR2 ,
    x_unit_class IN VARCHAR2 ,
    x_ci_start_dt IN DATE ,
    x_ci_end_dt IN DATE ,
    x_administrative_priority IN NUMBER ,
    x_waitlist_dt IN DATE ,
    x_dcnt_reason_cd IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_org_id            IN NUMBER,
    x_gs_version_number IN NUMBER,
    x_enr_method_type   IN VARCHAR2,
    x_failed_unit_rule  IN VARCHAR2,
    x_cart              IN VARCHAR2,
    x_rsv_seat_ext_id   IN NUMBER  ,
    x_org_unit_cd       IN VARCHAR2,
    x_grading_schema_code IN VARCHAR2,
    x_subtitle            IN VARCHAR2,
    -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
    x_session_id          IN NUMBER ,
    x_deg_aud_detail_id   IN NUMBER ,
    x_student_career_transcript IN VARCHAR2,
    x_student_career_statistics IN VARCHAR2,
    x_waitlist_manual_ind IN VARCHAR2 ,--Bug ID: 2554109  added by adhawan
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2 ,
    x_attribute11 IN VARCHAR2 ,
    x_attribute12 IN VARCHAR2 ,
    x_attribute13 IN VARCHAR2 ,
    x_attribute14 IN VARCHAR2 ,
    x_attribute15 IN VARCHAR2 ,
    x_attribute16 IN VARCHAR2 ,
    x_attribute17 IN VARCHAR2 ,
    x_attribute18 IN VARCHAR2 ,
    x_attribute19 IN VARCHAR2 ,
    x_attribute20 IN VARCHAR2 ,
    -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
    x_wlst_priority_weight_num IN NUMBER ,
    x_wlst_preference_weight_num IN NUMBER,
    -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
    x_core_indicator_code IN VARCHAR2,
    X_UPD_AUDIT_FLAG      IN VARCHAR2 ,
    X_SS_SOURCE_IND       IN VARCHAR2
  ) AS
  -------------------------------------------------------------------------------------
  --who           when            what
  --smadathi      25-jul-2001     Call to Igs_En_Gen_015.validation_step_is_overridden added
  --                              to check for unit section status, if it is CLOSED, check whether
  --                              that has been overriden or not
  --kkillams      27-Mar-03       Modified usec_cur Cursor, replaced * with unit_section_status
  --                              w.r.t. bug 2749648
  --svanukur      29-APR-2003     Created cursor c_same_section to prevent students from enrolling in
  --                              multiple versions of same unit in the same teaching period and also
  --                              changed the where clauses to pass uoo_id as part of MUS build
  --svanukur      23-May-2003     Redefined l_step_override_limit to refer to igs_en_elgb_ovr_uoo
  --                                as part of Deny/War behaviour build # 2829272
  --svanukur      13-Jun-03       Checking for the unit section status of 'Not_offered' as part of
  --                                validation Impact CR bug#2881385
  --svanukur      13-jun-03       The check for cancelled/planned unit section status was done only while
 --                               inserting the unit attempt record but was not checking while
 --                               updating a dropped or discontinued unit attempt.
 --                               Now the check is being done for both for updation and insertion for bug #2980069.
   --rvivekan     16-Jun-2003     Added handling for same_teaching_period (MUS) checkbox in unit_Section level
  --                              as a part of Repeat and reenrollment build #2881363
 --rvivekan   9-sep-2003       PSP integration build#3052433. modified behavior and declarations of
 --                            repeatable_ind in the igs_ps_unit_ver table and the column name of
 --                            same_teaching_period flag in igs_ps_unit_oft_opt to not_multiple_section_flag.
 -- svanukur    14-jan-2004     Added teh code for MUS validations in case of update for bug 3368048
 -- rvangala    25-Feb-2004     Change cursors c_mus_allowed and c_mus_participate to ensure that
 --                             unit attempts not in discontinued status are considered, Bug #3456893
 -- bdeviset    22-NOV-2005     Moved mutiple section validtion to IGS_EN_VAL_SUA procedure and
 --                             Bypassed MUS validation when ss_source_ind is SWAP for bug# 4676023
 -- ckasu       27-NOV-2005     Added logic inorder to perform/by pass validations when this was called from
 --                             add_units_api for Calling Object as 'PLAN' as a part of bug#4666102
  ------------------------------------------------------------------------------------
     CURSOR cur_rowid  IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      uoo_id = x_uoo_id
      AND unit_attempt_status = 'DROPPED';
      l_rowid VARCHAR2(25);
      l_step_override_limit  IGS_EN_ELGB_OVR_UOO.step_override_limit%TYPE ;
      l_result               BOOLEAN ;

     CURSOR  usec_cur(p_uoo_id NUMBER) IS
       SELECT unit_section_status
       FROM   igs_ps_unit_ofr_opt uoo
       WHERE uoo_id = p_uoo_id;

     usec_cur_row usec_cur%ROWTYPE;

  BEGIN
  l_result :=FALSE;
  l_step_override_limit := 0;
    Set_Column_Values (
      p_action,
      x_rowid,
      x_uoo_id,
      x_enrolled_dt,
      x_unit_attempt_status,
      x_administrative_unit_status,
      x_discontinued_dt,
      x_rule_waived_dt,
      x_rule_waived_person_id,
      x_no_assessment_ind,
      x_sup_unit_cd,
      x_sup_version_number,
      x_exam_location_cd,
      x_alternative_title,
      x_override_enrolled_cp,
      x_override_eftsu,
      x_override_achievable_cp,
      x_override_outcome_due_dt,
      x_override_credit_reason,
      x_person_id,
      x_course_cd,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_location_cd,
      x_unit_class,
      x_ci_start_dt,
      x_ci_end_dt,
      x_administrative_priority,
      x_waitlist_dt,
      x_dcnt_reason_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      x_gs_version_number,
      x_enr_method_type  ,
      x_failed_unit_rule ,
      x_cart             ,
      x_rsv_seat_ext_id,
      x_org_unit_cd ,
      x_grading_schema_code,
      x_subtitle,
    -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
      x_session_id,
      x_deg_aud_detail_id,
      x_student_career_transcript,
      x_student_career_statistics,
      x_waitlist_manual_ind ,  --Bug ID: 2554109  added by adhawan
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
      -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
      x_wlst_priority_weight_num,
      x_wlst_preference_weight_num,
      -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
      x_core_indicator_code,
      X_UPD_AUDIT_FLAG,
      X_SS_SOURCE_IND
    );
    IF (p_action = 'INSERT')
        OR
       (
         p_action = 'UPDATE' AND
         old_references.unit_attempt_status IN ('DROPPED','DISCONTIN') AND
         old_references.unit_attempt_status <> new_references.unit_attempt_status
       ) THEN



         -- Enhancement in response to the bug 1552624
         -- This piece of code does NOT allow enrollment into a unit attempt
         -- if the unit section status is NOT open.
         OPEN usec_cur(new_references.uoo_id);
         FETCH usec_cur INTO usec_cur_row;
         CLOSE usec_cur;
         --
         -- check for unit section status, if it is CLOSED, check whether
         -- that has been overriden or not
         -- if not, display error
         -- Also display error if it is PLANNED or CANCELLED
         --added on 25-jul-2001 by smadathi

         -- removed the closed section override code added by smadathi
         -- this will now be checked in IGS_EN_GEN_015.get_usec_status
         -- amuthu 02-Jul-2002

         IF (USEC_CUR_ROW.UNIT_SECTION_STATUS IN ('CANCELLED','PLANNED','NOT_OFFERED') ) THEN
                 FND_MESSAGE.SET_NAME('IGS','IGS_EN_SS_CANNOT_WAITLIST');
                 IGS_GE_MSG_STACK.ADD;
                 APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;

         -- multiple unit sections validation is performed for SWAP in add units api
         -- and it should not be done here as this is done in a autonomus txn.
         IF NVL(X_SS_SOURCE_IND,'N') <> 'S' THEN

           /*checking for multiple versions of same unit section, if exists raise an exception*/
           --processing for same_teaching_period at unit section level added as a part of Repeat and Reeenrollment build
           IGS_EN_VAL_SUA.validate_mus(p_person_id             => x_person_id,
                                       p_course_cd             => x_course_cd,
                                       p_uoo_id                => x_uoo_id);


         END IF; --  IF NVL(X_SS_SOURCE_IND,'N') <> 'S' OR (IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NOT NULL AND IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop = 'PLAN') THEN
    END IF;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE,
                                     p_updating => FALSE,
                                     p_deleting => FALSE );

      IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

              BeforeRowInsertUpdateDelete2 ( p_inserting => TRUE,
                                             p_updating => FALSE,
                                             p_deleting => FALSE);

      END IF; --IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

      IF  Get_PK_For_Validation (
                NEW_REFERENCES.person_id,
                NEW_REFERENCES.course_cd,
                NEW_REFERENCES.uoo_id
                ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

      Check_Constraints;
      Check_Parent_Existance;
      Check_Uniqueness;
      -- For Enhancement Bug 1287292
      -- Commented the call for the bug Fix:2366438
      -- chk_enrollment_max;


    ELSIF (p_action = 'UPDATE') THEN

      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
                                     p_updating => TRUE,
                                     p_deleting => FALSE);
      IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

              BeforeRowInsertUpdateDelete2 ( p_inserting => FALSE,
                                             p_updating => TRUE ,
                                             p_deleting => FALSE);
      END IF;--IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

      Check_Constraints;
      Check_Parent_Existance;
      Check_Uniqueness;
      -- For Enhancement Bug 1287292
      -- Commented the call for the bug Fix:2366438
      --chk_enrollment_max;



    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
                                     p_updating => FALSE ,
                                     p_deleting => TRUE );
      BeforeRowInsertUpdateDelete2 ( p_inserting => FALSE,
                                     p_updating => FALSE ,
                                     p_deleting => TRUE );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
       OPEN cur_rowid;
       FETCH cur_rowid INTO l_rowid;
       -- for Bug 1575677
       IF cur_rowid%NOTFOUND THEN
             IF  Get_PK_For_Validation (
                  NEW_REFERENCES.person_id,
                  NEW_REFERENCES.course_cd,
                  NEW_REFERENCES.uoo_id
                  ) THEN
                  Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                  IGS_GE_MSG_STACK.ADD;
                  APP_EXCEPTION.RAISE_EXCEPTION;
             END IF;
             Check_Constraints;
             Check_Uniqueness;
       END IF;
       CLOSE cur_rowid;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints;
       Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END Before_DML;


  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
    -- Getting the sua details for all waitlisted students, pmarada bug 2526021
    -- ptandon          03-SEP-2003             Added logic to re-sequence the waitlisted
    --                                          students when waitlist priorities/preferences
    --                                          are defined in the system.
    -- stutta          17-NOV-2003             Added code to create a term record, if one doesn't
    --                                         already exist, when a student enrolls or waitlists
    --                                          for a unit. Part of Term Records Build
    --  vkarthik       13-Feb-04               Waitlist position re-sequencing logic was not present
    --                                          in 'Insert' action, added as part bug 3433446
    --  stutta         10-MAR-2004       Added call to igs_en_gen_015.get_academic_cal to get acad cal
    --                                   instance and pass it to c_teach_to_load cursor. BUG# 3481403
    --  stutta         16-Mar-2004      Passing new parameter p_update_rec in call
    --                                   to igs_en_spa_terms_api.create_update_term_rec. Bug # 3421436
    --  stutta         11-Jan-2004        Modified c_teach_to_load to allow term record creation for terms
    --                                   which are subordinate to any instance of the academic cal type.
    --                                   Bug #4016319
    -- ckasu           27-NOV-2005      Added logic inorder to perform/by pass validations when this was called from
    --                                  add_units_api for Calling Object as 'PLAN' as a part of bug#4666102
    -- bdeviset        02-Mar-2006      Modifed cursor c_spa_terms for bug# 5073761

    CURSOR c_sua_details(cp_uoo_id  igs_en_su_attempt.uoo_id%TYPE) IS
    SELECT * FROM igs_en_su_attempt
    WHERE uoo_id = cp_uoo_id AND
         unit_attempt_status = 'WAITLISTED'
         ORDER BY administrative_priority ASC;

    -- Cursor to lock parent unit section record. Bug# 3052426 - ptandon
    CURSOR  c_unit_sec_lock(cp_uoo_id  igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
    SELECT  uoo_id
    FROM    igs_ps_unit_ofr_opt
    WHERE   uoo_id = cp_uoo_id
    FOR UPDATE;

    CURSOR c_repeatable_unit (cp_unit_cd igs_ps_unit_ver.unit_cd%TYPE,
                              cp_uv_version_number igs_ps_unit_ver.version_number%TYPE) IS
    SELECT  uv.repeatable_ind
    FROM    igs_ps_unit_ver uv
    WHERE   uv.unit_cd              = cp_unit_cd AND
            uv.version_number       = cp_uv_version_number;
    CURSOR c_renrollcheck(cp_person_id igs_en_su_attempt.person_id%TYPE,
                           cp_uoo_id igs_en_su_attempt.uoo_id%TYPE,
                           cp_course_cd igs_en_su_attempt.course_cd%TYPE) IS
    SELECT 'x'
    FROM igs_en_su_attempt sua
    WHERE person_id=cp_person_id
    AND   uoo_id=cp_uoo_id
    AND   unit_attempt_status ='COMPLETED'
    AND   course_cd <> cp_course_cd
    AND EXISTS  (SELECT 'x'
                             FROM IGS_PS_STDNT_UNT_TRN sut
                             WHERE sut.person_id = cp_person_id
                             AND sut.uoo_id = cp_uoo_id
                             AND sut.transfer_course_cd = cp_course_cd
                             AND sut.course_cd = sua.course_cd
                  ) ;

    CURSOR c_conflict_suas (cp_person_id igs_en_su_attempt.person_id%TYPE,
                           cp_uoo_id igs_en_su_attempt.uoo_id%TYPE,
                           cp_unit_cd igs_en_su_attempt.unit_cd%TYPE,
                           cp_version_number igs_en_su_attempt.version_number%TYPE,
                           cp_course_cd igs_en_su_attempt.course_cd%TYPE) IS

    SELECT 'x'
    FROM igs_en_su_attempt sua
    WHERE person_id=cp_person_id
    AND   unit_cd=cp_unit_cd
    AND   version_number=cp_version_number
    AND   unit_attempt_status IN ('ENROLLED','DUPLICATE','COMPLETED','DISCONTIN')
    AND   (
            (course_cd <> cp_course_cd
             AND NOT EXISTS (SELECT 'x'
                             FROM IGS_PS_STDNT_UNT_TRN sut
                             WHERE sut.person_id = cp_person_id
                             and sut.uoo_id = cp_uoo_id
                             AND sut.transfer_course_cd = sua.course_cd
                             AND sut.course_cd = cp_course_cd)
             )
           OR
          (course_cd = cp_course_cd AND uoo_id<>cp_uoo_id)); --so that the newly added sua is not counted

   -- find all term calendars assiciated with the teach calendar of the unit and subordinate to any instance
   -- of the academic calendar of the student program attempt.
CURSOR c_teach_to_load(cp_acad_cal_type VARCHAR2) IS
   SELECT ttl.load_cal_type, ttl.load_ci_sequence_number
   FROM IGS_CA_TEACH_TO_LOAD_V ttl,
        IGS_EN_STDNT_PS_ATT spa,
        IGS_CA_INST_REL cir
   WHERE ttl.teach_cal_type= new_references.cal_type
   AND ttl.teach_ci_sequence_number = new_references.ci_sequence_number
   AND spa.person_id = new_references.person_id
   AND spa.course_cd = new_references.course_cd
   AND spa.cal_type = cp_acad_cal_type
   AND cir.sup_cal_type = spa.cal_type
   AND cir.sub_cal_type = ttl.load_cal_type
   AND cir.sub_ci_sequence_number = ttl.load_ci_sequence_number;

   CURSOR c_term (p_person_id number, p_course_cd varchar2,
                p_term_cal_type varchar2, p_term_ci_sequence_number number) IS
   SELECT 'x'
   FROM igs_en_spa_terms spat,  igs_en_stdnt_ps_att curspa,  igs_ps_ver curcv,
                                igs_en_stdnt_ps_att spa,     igs_ps_ver cv
   WHERE spat.person_id = p_person_id
   AND   term_cal_type = p_term_cal_type    AND term_sequence_number = p_term_ci_sequence_number
   AND   curspa.person_id=spat.person_id    AND curspa.course_cd=p_course_Cd
   AND   curcv.course_Cd=curspa.course_cd   AND curcv.version_number=curspa.version_number
   AND   spa.person_id=spat.person_id       AND spat.program_cd=spa.course_cd
   AND   cv.course_Cd=spa.course_cd         AND cv.version_number=spa.version_number
   AND   cv.course_type = curcv.course_type
   AND   (NVL(fnd_profile.value('CAREER_MODEL_ENABLED'),'N') = 'Y'  OR  spat.program_cd = p_course_cd );


   CURSOR c_sca IS
   SELECT attendance_type, attendance_mode, key_program, fee_cat, igs_pr_class_std_id,
              cal_type, location_cd, coo_id, version_number, student_confirmed_ind
   FROM IGS_EN_STDNT_PS_ATT
   WHERE person_id = new_references.person_id
   AND course_cd = new_references.course_cd;

   rec_sca c_sca%ROWTYPE;
   l_message_name VARCHAR2(200);

    CURSOR c_other_key_recs ( cp_person_id IGS_EN_SPA_TERMS.PERSON_ID%TYPE,
                      cp_term_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                      cp_term_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE,
                      cp_program_cd IGS_PS_VER.COURSE_CD%TYPE,
                      cp_acad_cal_type IGS_EN_SPA_TERMS.ACAD_CAL_TYPE%TYPE) IS
        SELECT 'X'
        FROM  IGS_EN_SPA_TERMS
        WHERE person_id            = cp_person_id
        AND   program_cd           <> cp_program_cd
        AND   term_cal_type        = cp_term_cal_type
        AND   term_sequence_number = cp_term_sequence_number
        AND   acad_cal_type        = cp_acad_cal_type
        AND   key_program_flag     = 'Y';

   CURSOR c_spa_terms (p_person_id IN number, p_course_cd IN varchar2,
                p_cal_type IN varchar2, p_ci_sequence_number IN number) IS
   SELECT spat.ROWID ROW_ID, spat.*
   FROM igs_en_spa_terms spat
   WHERE spat.person_id = p_person_id
   AND   program_cd=p_course_cd AND plan_sht_status IN ('PLAN', 'NONE')
   AND  EXISTS
   (SELECT load_cal_type,load_ci_sequence_number FROM igs_ca_load_to_teach_v ltCal
    WHERE ltCal.teach_cal_type = p_cal_type AND ltCal.teach_ci_sequence_number = p_ci_sequence_number
    AND ltCal.load_cal_type = spat.term_cal_type AND ltCal.load_ci_sequence_number = spat.term_sequence_number) ;

   v_dummy c_other_key_recs%ROWTYPE;


   l_sua_details  c_sua_details%ROWTYPE;
   l_cnt  igs_en_su_attempt.administrative_priority%TYPE;
   l_repeatable_unit igs_ps_unit_ver.repeatable_ind%TYPE;
   l_act_enr NUMBER;
   l_dummy          VARCHAR2(10);
   l_dummy_value    NUMBER;
   l_return_status  VARCHAR2(100);
   l_sup_sub_unit_status igs_en_su_attempt.unit_attempt_status%TYPE;

  BEGIN


    IF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      --  AfterRowInsertUpdate5( p_updating => TRUE ); Removed the this procedure from the tbh in the 115.73 version of the file,
      --  the validation moved to the igsss09b.pls at the time of enrolling a unit. pmarada, 2385096
      --adding the call to  ENR_SUA_SUP_SUB_VAL to validate the superior subordinate unit attempt status

      IF old_references.unit_attempt_status <> new_references.unit_attempt_status THEN

        IF NOT IGS_EN_SUA_API.ENR_SUA_SUP_SUB_VAL(new_references.person_id,
                                           new_references.course_cd,
                                           new_references.uoo_id,
                                           new_references.unit_attempt_status,
                                           l_sup_sub_unit_status) THEN

             IF l_sup_sub_unit_status IS NOT NULL THEN
                FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_INVALID_SUP_SUB');
                FND_MESSAGE.SET_TOKEN ('CONSTAT', new_references.unit_attempt_status);
                FND_MESSAGE.SET_TOKEN ('SSTAT',l_sup_sub_unit_status);
              ELSE
                FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_INVALID_SUP');
              END IF;
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;

      END IF; --IF old_references.unit_attempt_status <> new_references.unit_attempt_status THEN

    END IF; -- end of IF (p_action = 'UPDATE') THEN

    IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN


    l_rowid := x_rowid;
        IF (p_action = 'INSERT') THEN
            -- Call all the procedures related to After Insert.
            -- AfterRowInsertUpdate5( p_inserting => TRUE );   Removed the this procedure from the tbh in the 115.73 version of the file,
            --  the validation moved to the igsss09b.pls at the time of enrolling a unit.,pmarada, 2385096

           IF NOT IGS_EN_SUA_API.ENR_SUA_SUP_SUB_VAL(new_references.person_id,
                                                     new_references.course_cd,
                                                     new_references.uoo_id,
                                                     new_references.unit_attempt_status,
                                                     l_sup_sub_unit_status) THEN
              IF l_sup_sub_unit_status IS NOT NULL THEN
                FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_INVALID_SUP_SUB');
                FND_MESSAGE.SET_TOKEN ('CONSTAT', new_references.unit_attempt_status);
                FND_MESSAGE.SET_TOKEN ('SSTAT',l_sup_sub_unit_status);
              ELSE
                FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_INVALID_SUP');
              END IF;
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;

           END IF;
           AfterRowInsertUpdateDelete3 ( p_inserting => TRUE,
                                    p_updating => FALSE,
                                    p_deleting => FALSE);

           --For enhancement 2043044,making a call to UPD_MAT_MRADM_CAT_TERMS procedure
           IGS_EN_GEN_003.UPD_MAT_MRADM_CAT_TERMS(new_references.person_id,
                                             new_references.course_cd,
                                             new_references.unit_attempt_status,
                                             new_references.cal_type,
                                             new_references.ci_sequence_number
                                             ) ;
           -- Code added as part of Waitlist Enhancements Build Bug# 3052426
           -- To re-sequence th students after calculating priority/preference weightages
           -- of the students in context - ptandon
           IF  new_references.wlst_priority_weight_num IS NOT NULL
           AND new_references.wlst_preference_weight_num IS NOT NULL
           AND new_references.unit_attempt_status = 'WAITLISTED'
           AND new_references.administrative_priority IS NULL
           THEN
               Igs_En_Wlst_Gen_proc.enrp_wlst_assign_pos(new_references.person_id,new_references.course_cd,new_references.uoo_id);
           END IF;

    ELSIF (p_action = 'UPDATE') THEN

	-- modified this condition to include DROP also for bug#4864437
    -- this code is being commented here but will be replicated in swap page and Drop page
    -- SwapAMImpl.java :swapSubmit , StdDropAMImpl.java:dropSubmit
	IF NVL(igs_en_su_attempt_pkg.pkg_source_of_drop,'NULL')  NOT IN ( 'SWAP','DROP') THEN

           AfterRowInsertUpdateDelete3 ( p_inserting => FALSE,
                                         p_updating => TRUE,
                                         p_deleting => FALSE );


           --enrollment processes build bug#1832130, pg No:24 s1a version of DLD
           update_reserved_seat('UPDATE');

           --For enhancement 2043044,making a call to UPD_MAT_MRADM_CAT_TERMS procedure
           IGS_EN_GEN_003.UPD_MAT_MRADM_CAT_TERMS(new_references.person_id,
                                                  new_references.course_cd,
                                                  new_references.unit_attempt_status,
                                                  new_references.cal_type,
                                                  new_references.ci_sequence_number
                                                 ) ;

        END IF;

        AfterRowUpdate4 ( p_inserting => FALSE,
                          p_updating => TRUE,
                          p_deleting => FALSE);

       -- when a waitlisted student is enrolled/dropped from the unit section then
     -- Re-sequence the waitlisted positions for the succeeding waitlisted students. pmarada, bug 2526021
      IF (OLD_REFERENCES.UNIT_ATTEMPT_STATUS = 'WAITLISTED' AND
         NVL(old_references.unit_attempt_status,'WAITLISTED') <> new_references.unit_attempt_status) THEN
           -- Lock the parent unit section record before updating unit attempt records - Bug# 3052426
           OPEN c_unit_sec_lock(new_references.uoo_id);

           l_cnt := 1;
           -- For each uoo_id updating the sua with administrative_priority
          FOR l_sua_details IN c_sua_details(new_references.uoo_id) LOOP
            IF l_cnt <> NVL(l_sua_details.administrative_priority,0) THEN
              l_sua_details.administrative_priority := l_cnt;
              BEGIN
                igs_en_su_attempt_pkg.update_row(
                        X_ROWID                        =>     l_sua_details.row_id                        ,
                        X_PERSON_ID                    =>     l_sua_details.person_id                      ,
                        X_COURSE_CD                    =>     l_sua_details.course_cd                      ,
                        X_UNIT_CD                      =>     l_sua_details.unit_cd                        ,
                        X_CAL_TYPE                     =>     l_sua_details.cal_type                       ,
                        X_CI_SEQUENCE_NUMBER           =>     l_sua_details.ci_sequence_number             ,
                        X_VERSION_NUMBER               =>     l_sua_details.version_number                 ,
                        X_LOCATION_CD                  =>     l_sua_details.location_cd                    ,
                        X_UNIT_CLASS                   =>     l_sua_details.unit_class                     ,
                        X_CI_START_DT                  =>     l_sua_details.ci_start_dt                    ,
                        X_CI_END_DT                    =>     l_sua_details.ci_end_dt                      ,
                        X_UOO_ID                       =>     l_sua_details.uoo_id                         ,
                        X_ENROLLED_DT                  =>     l_sua_details.enrolled_dt                    ,
                        X_UNIT_ATTEMPT_STATUS          =>     l_sua_details.unit_attempt_status            ,
                        X_ADMINISTRATIVE_UNIT_STATUS   =>     l_sua_details.administrative_unit_status     ,
                        X_DISCONTINUED_DT              =>     l_sua_details.discontinued_dt                ,
                        X_RULE_WAIVED_DT               =>     l_sua_details.rule_waived_dt                 ,
                        X_RULE_WAIVED_PERSON_ID        =>     l_sua_details.rule_waived_person_id          ,
                        X_NO_ASSESSMENT_IND            =>     l_sua_details.no_assessment_ind              ,
                        X_SUP_UNIT_CD                  =>     l_sua_details.sup_unit_cd                    ,
                        X_SUP_VERSION_NUMBER           =>     l_sua_details.sup_version_number             ,
                        X_EXAM_LOCATION_CD             =>     l_sua_details.exam_location_cd               ,
                        X_ALTERNATIVE_TITLE            =>     l_sua_details.alternative_title              ,
                        X_OVERRIDE_ENROLLED_CP         =>     l_sua_details.override_enrolled_cp           ,
                        X_OVERRIDE_EFTSU               =>     l_sua_details.override_eftsu                 ,
                        X_OVERRIDE_ACHIEVABLE_CP       =>     l_sua_details.override_achievable_cp         ,
                        X_OVERRIDE_OUTCOME_DUE_DT      =>     l_sua_details.override_outcome_due_dt        ,
                        X_OVERRIDE_CREDIT_REASON       =>     l_sua_details.override_credit_reason         ,
                        X_ADMINISTRATIVE_PRIORITY      =>     l_sua_details.administrative_priority        ,
                        X_WAITLIST_DT                  =>     l_sua_details.waitlist_dt                    ,
                        X_DCNT_REASON_CD               =>     l_sua_details.dcnt_reason_cd                 ,
                        X_MODE                         =>     'R'                                          ,
                        X_GS_VERSION_NUMBER            =>     l_sua_details.gs_version_number              ,
                        X_ENR_METHOD_TYPE              =>     l_sua_details.enr_method_type                ,
                        X_FAILED_UNIT_RULE             =>     l_sua_details.failed_unit_rule               ,
                        X_CART                         =>     l_sua_details.cart                           ,
                        X_RSV_SEAT_EXT_ID              =>     l_sua_details.rsv_seat_ext_id                ,
                        X_ORG_UNIT_CD                  =>     l_sua_details.org_unit_cd                    ,
                        X_SESSION_ID                   =>     l_sua_details.session_id,
                        X_GRADING_SCHEMA_CODE          =>     l_sua_details.grading_schema_code            ,
                        X_DEG_AUD_DETAIL_ID            =>     l_sua_details.deg_aud_detail_id    ,
                        X_STUDENT_CAREER_TRANSCRIPT    =>     l_sua_details.student_career_transcript,
                        X_STUDENT_CAREER_STATISTICS    =>     l_sua_details.student_career_statistics,
                        x_waitlist_manual_ind          =>     'N',  --Bug ID: 2554109  added by adhawan
                        X_ATTRIBUTE_CATEGORY           =>     l_sua_details.attribute_category,
                        X_ATTRIBUTE1                   =>     l_sua_details.attribute1,
                        X_ATTRIBUTE2                   =>     l_sua_details.attribute2,
                        X_ATTRIBUTE3                   =>     l_sua_details.attribute3,
                        X_ATTRIBUTE4                   =>     l_sua_details.attribute4,
                        X_ATTRIBUTE5                   =>     l_sua_details.attribute5,
                        X_ATTRIBUTE6                   =>     l_sua_details.attribute6,
                        X_ATTRIBUTE7                   =>     l_sua_details.attribute7,
                        X_ATTRIBUTE8                   =>     l_sua_details.attribute8,
                        X_ATTRIBUTE9                   =>     l_sua_details.attribute9,
                        X_ATTRIBUTE10                  =>     l_sua_details.attribute10,
                        X_ATTRIBUTE11                  =>     l_sua_details.attribute11,
                        X_ATTRIBUTE12                  =>     l_sua_details.attribute12,
                        X_ATTRIBUTE13                  =>     l_sua_details.attribute13,
                        X_ATTRIBUTE14                  =>     l_sua_details.attribute14,
                        X_ATTRIBUTE15                  =>     l_sua_details.attribute15,
                        X_ATTRIBUTE16                  =>     l_sua_details.attribute16,
                        X_ATTRIBUTE17                  =>     l_sua_details.attribute17,
                        X_ATTRIBUTE18                  =>     l_sua_details.attribute18,
                        X_ATTRIBUTE19                  =>     l_sua_details.attribute19,
                        X_ATTRIBUTE20                  =>     l_sua_details.attribute20,
                        -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
                        X_WLST_PRIORITY_WEIGHT_NUM     =>     l_sua_details.wlst_priority_weight_num,
                        X_WLST_PREFERENCE_WEIGHT_NUM   =>     l_sua_details.wlst_preference_weight_num,
                        -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
                        X_CORE_INDICATOR_CODE          =>     l_sua_details.core_indicator_code,
                        X_UPD_AUDIT_FLAG               =>     l_sua_details.UPD_AUDIT_FLAG ,
                        X_SS_SOURCE_IND                =>     l_sua_details.SS_SOURCE_IND
                      );
              END;
            END IF;
             l_cnt := l_cnt + 1;
          END LOOP;
          CLOSE c_unit_sec_lock;
      END IF;
      -- end of the code added as part of the bug 2526021

      -- Code added as part of Waitlist Enhancements Build Bug# 3052426
      -- To re-sequence th students after calculating priority/preference weightages
      -- of the students in context - ptandon
      IF  new_references.wlst_priority_weight_num IS NOT NULL
      AND new_references.wlst_preference_weight_num IS NOT NULL
      AND new_references.unit_attempt_status = 'WAITLISTED'
      AND new_references.administrative_priority IS NULL
      THEN
          Igs_En_Wlst_Gen_proc.enrp_wlst_assign_pos(new_references.person_id,new_references.course_cd,new_references.uoo_id);
      END IF;

    END IF;

  END IF; --IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

    IF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowInsertUpdateDelete3 ( p_inserting => FALSE,
                                    p_updating => FALSE,
                                    p_deleting => TRUE );
      update_reserved_seat('DELETE');
          -- This block of code is included to ensure that the counter gets
          -- decremented even if an enrolled unit attempt is deleted from the
          -- unit attempt window. This works as an additional enhancement for
          -- the bug #1525863
            IF ( (old_references.unit_attempt_status IN ('ENROLLED', 'UNCONFIRM')) AND
                 p_action = 'DELETE'  ) THEN

                  igs_en_sua_api.upd_enrollment_counts( 'DELETE',
                                                         old_references,
                                                         new_references
                                                      );
            END IF;

    END IF; -- IF (p_action = 'DELETE') THEN

    --validate newly enrolled units and check if the person has any active
    --unit attempts in diff. unit sections of the same unit across program/careers
    IF new_references.unit_attempt_status ='ENROLLED' THEN
      OPEN c_repeatable_unit(new_references.unit_cd,new_references.version_number);
      FETCH c_repeatable_unit INTO l_repeatable_unit;
      CLOSE c_repeatable_unit;
      IF l_repeatable_unit='X' THEN

      OPEN c_renrollcheck(new_references.person_id,new_references.uoo_id,new_references.course_cd);
       FETCH c_renrollcheck INTO l_dummy;
        IF  c_renrollcheck%FOUND THEN

              CLOSE  c_renrollcheck;
        ELSE
              CLOSE  c_renrollcheck;

              OPEN c_conflict_suas(new_references.person_id,new_references.uoo_id,new_references.unit_cd,
                             new_references.version_number,new_references.course_cd);
              FETCH c_conflict_suas INTO l_dummy;
              IF c_conflict_suas%FOUND THEN
                CLOSE c_conflict_suas;
                fnd_message.set_name('IGS', 'IGS_EN_REP_REENR_NOT_ALWD');
                IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
              END IF;
              CLOSE c_conflict_suas;
         END IF; --renroll check
       END IF; --l_repeatable_unit
    END IF;

  IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

    IF (p_action = 'UPDATE') THEN
       IF (old_references.unit_attempt_status <> new_references.unit_attempt_status) AND
          (new_references.unit_attempt_status IN ('DROPPED', 'DISCONTIN')) THEN
          l_new_cp := NULL;
          IF l_load_cal_type IS NOT NULL THEN
                --Get the total enrolled cp after unit section got discontinue.
                IGS_EN_PRC_LOAD.enrp_get_prg_eftsu_cp(
                            p_person_id       =>new_references.person_id,
                            p_course_cd       =>new_references.course_cd,
                            p_cal_type        =>l_load_cal_type,
                            p_sequence_number =>l_load_seq_num,
                            p_eftsu_total     =>l_dummy_value,
                            p_credit_points   => l_new_cp);
                --Api Raises the drop business event.
                igs_ss_en_wrappers.drop_all_workflow(
                            p_uoo_idS                =>new_references.uoo_id,
                            p_person_id              =>new_references.person_id,
                            p_load_cal_type          =>l_load_cal_type,
                            p_load_sequence_number   =>l_load_seq_num,
                            p_program_cd             =>new_references.course_cd,
                            p_return_status          =>l_return_status,
                            p_drop_date              =>new_references.discontinued_dt,
                            p_old_cp                 =>l_old_cp,
                            p_new_cp                 =>l_new_cp);
          END IF;
       END IF;
    END IF;

   IF new_references.unit_attempt_status IN ('WAITLISTED', 'ENROLLED','UNCONFIRM') THEN
      OPEN c_sca;
      FETCH c_sca into rec_sca;
      CLOSE c_sca;
      IF (rec_sca.student_confirmed_ind = 'Y')   THEN
		  FOR rec_tl in c_teach_to_load(rec_sca.cal_type)
		  LOOP
		  IF  NVL(fnd_profile.value('CAREER_MODEL_ENABLED'),'N') = 'N' OR
			  ('PRIMARY'=igs_en_spa_terms_api.get_spat_primary_prg (new_references.person_id, new_references.course_cd,
				rec_tl.load_cal_type, rec_tl.load_ci_sequence_number)) THEN

			OPEN c_term (new_references.person_id, new_references.course_cd,
						   rec_tl.load_cal_type, rec_tl.load_ci_sequence_number);
			FETCH c_term INTO l_dummy;
			l_message_name := NULL;

			IF c_term%NOTFOUND THEN
					igs_en_spa_terms_api.create_update_term_rec (
							p_person_id => new_references.person_id,
							p_program_cd => new_references.course_cd,
							p_term_cal_type => rec_tl.load_cal_type ,
							p_term_sequence_number => rec_tl.load_ci_sequence_number ,
							p_ripple_frwrd => FALSE, -- ripple forward
							p_message_name => l_message_name,
							p_update_rec => TRUE);
			END IF;
			CLOSE c_term;
			IF l_message_name IS NOT NULL THEN
					fnd_message.set_name('IGS', l_message_name);
					IGS_GE_MSG_STACK.ADD;
					app_exception.raise_exception;
			END IF;
		  END IF;
		  END LOOP;
	  END IF;
   END IF;

  IF p_action in ('INSERT','UPDATE') AND
    old_references.unit_attempt_status <> new_references.unit_attempt_status AND
    new_references.unit_attempt_status IN ('ENROLLED','WAITLISTED') THEN

    FOR rec_spa_terms IN
     c_spa_terms(new_references.person_id, new_references.course_cd, new_references.cal_type , new_references.ci_sequence_number)
     LOOP
          igs_en_spa_terms_pkg.update_row(
                 x_rowid                =>rec_spa_terms.row_id,
                 x_term_record_id       =>rec_spa_terms.term_record_id,
                 x_person_id            =>rec_spa_terms.person_id,
                 x_program_cd           =>rec_spa_terms.program_cd,
                 x_program_version      =>rec_spa_terms.program_version,
                 x_acad_cal_type        =>rec_spa_terms.acad_cal_type,
                 x_term_cal_type        =>rec_spa_terms.term_cal_type,
                 x_term_sequence_number =>rec_spa_terms.term_sequence_number,
                 x_key_program_flag     =>rec_spa_terms.key_program_flag,
                 x_location_cd          =>rec_spa_terms.location_cd,
                 x_attendance_mode      =>rec_spa_terms.attendance_mode,
                 x_attendance_type      =>rec_spa_terms.attendance_type,
                 x_fee_cat              =>rec_spa_terms.fee_cat,
                 x_coo_id               =>rec_spa_terms.coo_id,
                 x_class_standing_id    =>rec_spa_terms.class_standing_id,
                 x_attribute_category   =>rec_spa_terms.attribute_category,
                 x_attribute1           =>rec_spa_terms.attribute1,
                 x_attribute2           =>rec_spa_terms.attribute2,
                 x_attribute3           =>rec_spa_terms.attribute3,
                 x_attribute4           =>rec_spa_terms.attribute4,
                 x_attribute5           =>rec_spa_terms.attribute5,
                 x_attribute6           =>rec_spa_terms.attribute6,
                 x_attribute7           =>rec_spa_terms.attribute7,
                 x_attribute8           =>rec_spa_terms.attribute8,
                 x_attribute9           =>rec_spa_terms.attribute9,
                 x_attribute10          =>rec_spa_terms.attribute10,
                 x_attribute11          =>rec_spa_terms.attribute11,
                 x_attribute12          =>rec_spa_terms.attribute12,
                 x_attribute13          =>rec_spa_terms.attribute13,
                 x_attribute14          =>rec_spa_terms.attribute14,
                 x_attribute15          =>rec_spa_terms.attribute15,
                 x_attribute16          =>rec_spa_terms.attribute16,
                 x_attribute17          =>rec_spa_terms.attribute17,
                 x_attribute18          =>rec_spa_terms.attribute18,
                 x_attribute19          =>rec_spa_terms.attribute19,
                 x_attribute20          =>rec_spa_terms.attribute20,
                 x_mode                 =>'R',
                 x_plan_sht_status      =>'SKIP');
     END LOOP;
   END IF;

  END IF; -- IF IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop IS NULL OR IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop <> 'PLAN' THEN

  END After_DML;
--
PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_UNIT_CD IN VARCHAR2,
  X_CAL_TYPE IN VARCHAR2,
  X_CI_SEQUENCE_NUMBER IN NUMBER,
  X_VERSION_NUMBER IN NUMBER,
  X_LOCATION_CD IN VARCHAR2,
  X_UNIT_CLASS IN VARCHAR2,
  X_CI_START_DT IN DATE,
  X_CI_END_DT IN DATE,
  X_UOO_ID IN NUMBER,
  X_ENROLLED_DT IN DATE,
  X_UNIT_ATTEMPT_STATUS IN VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS IN VARCHAR2,
  X_DISCONTINUED_DT IN DATE,
  X_RULE_WAIVED_DT IN DATE,
  X_RULE_WAIVED_PERSON_ID IN NUMBER,
  X_NO_ASSESSMENT_IND IN VARCHAR2,
  X_SUP_UNIT_CD IN VARCHAR2,
  X_SUP_VERSION_NUMBER IN NUMBER,
  X_EXAM_LOCATION_CD IN VARCHAR2,
  X_ALTERNATIVE_TITLE IN VARCHAR2,
  X_OVERRIDE_ENROLLED_CP IN NUMBER,
  X_OVERRIDE_EFTSU IN NUMBER,
  X_OVERRIDE_ACHIEVABLE_CP IN NUMBER,
  X_OVERRIDE_OUTCOME_DUE_DT IN DATE,
  X_OVERRIDE_CREDIT_REASON IN VARCHAR2,
  X_ADMINISTRATIVE_PRIORITY IN NUMBER,
  X_WAITLIST_DT IN DATE,
  X_DCNT_REASON_CD IN VARCHAR2,
  X_MODE IN VARCHAR2 ,
  x_org_id IN NUMBER,
  X_GS_VERSION_NUMBER IN NUMBER    ,
  X_ENR_METHOD_TYPE   IN VARCHAR2  ,
  X_FAILED_UNIT_RULE  IN VARCHAR2  ,
  X_CART              IN VARCHAR2 ,
  X_RSV_SEAT_EXT_ID   IN NUMBER   ,
  X_org_unit_cd       IN VARCHAR2 ,
  X_GRADING_SCHEMA_CODE IN VARCHAR2 ,
  x_subtitle            IN VARCHAR2 ,
  -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
  x_session_id          IN NUMBER ,
  x_deg_aud_detail_id   IN NUMBER ,
  x_student_career_transcript IN VARCHAR2 ,
  x_student_career_statistics IN VARCHAR2 ,
  X_WAITLIST_MANUAL_IND    IN VARCHAR2,--Bug ID: 2554109  added by adhawan
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  x_ATTRIBUTE20 IN VARCHAR2 ,
  -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
  X_WLST_PRIORITY_WEIGHT_NUM IN NUMBER ,
  X_WLST_PREFERENCE_WEIGHT_NUM IN NUMBER ,
  -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
  X_CORE_INDICATOR_CODE IN VARCHAR2,
  X_UPD_AUDIT_FLAG      IN VARCHAR2,
  X_SS_SOURCE_IND       IN VARCHAR2
  ) AS
  /*------------------------------------------------------------------------------------------------------------------------------------------
   knaraset   10-Jul-2003    Added unique key along with pk to check existance of Dropped units
   svanukur   28-APR-03      changed the where clauses to reflect teh new Primary key
                             as part of MUS build, # 2829262
   sbaliga    13-feb-2002    assigned igs_ge_gen_003.get_org_id to x_org_id in call to before_dml
                             as part of SWCR006 build.
---------------------------------------------------------------------------------------*/
-- Changing the parameters X_UNIT_CD, X_CAL_TYPE, X_CI_SEQUENCE_NUMBER TO NEW_REFERENCES
-- in response to the bug 1766230. For further detils please refer to version 115.19 of IGSEI36B.pls

    CURSOR C IS SELECT ROWID FROM IGS_EN_SU_ATTEMPT_ALL
      WHERE PERSON_ID = X_PERSON_ID
      AND COURSE_CD = X_COURSE_CD
      AND UOO_ID = X_UOO_ID;


     CURSOR cur_rowid  IS
      SELECT   ROWID
      FROM     IGS_EN_SU_ATTEMPT_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND unit_attempt_status = 'DROPPED'
      AND ( uoo_id = x_uoo_id
           OR ( unit_cd = x_unit_cd AND
                version_number = x_version_number AND
                cal_type = x_cal_type AND
                ci_sequence_number = x_ci_sequence_number AND
                location_cd = x_location_cd AND
                unit_class = x_unit_class
                ));

    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;

    resource_busy  EXCEPTION;
    PRAGMA EXCEPTION_INIT(resource_busy,-00054);

BEGIN

OPEN cur_rowid;
FETCH cur_rowid INTO x_rowid;
-- for Bug 1575677
IF cur_rowid%FOUND THEN
UPDATE_ROW (
   x_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_UNIT_CD,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_VERSION_NUMBER,
   X_LOCATION_CD,
   X_UNIT_CLASS,
   X_CI_START_DT,
   X_CI_END_DT,
   X_UOO_ID,
   X_ENROLLED_DT,
   X_UNIT_ATTEMPT_STATUS,
   X_ADMINISTRATIVE_UNIT_STATUS,
   X_DISCONTINUED_DT,
   X_RULE_WAIVED_DT,
   X_RULE_WAIVED_PERSON_ID,
   X_NO_ASSESSMENT_IND,
   X_SUP_UNIT_CD,
   X_SUP_VERSION_NUMBER,
   X_EXAM_LOCATION_CD,
   X_ALTERNATIVE_TITLE,
   X_OVERRIDE_ENROLLED_CP,
   X_OVERRIDE_EFTSU,
   X_OVERRIDE_ACHIEVABLE_CP,
   X_OVERRIDE_OUTCOME_DUE_DT,
   X_OVERRIDE_CREDIT_REASON,
   X_ADMINISTRATIVE_PRIORITY,
   X_WAITLIST_DT,
   X_DCNT_REASON_CD,
   X_MODE,
   X_GS_VERSION_NUMBER ,
   X_ENR_METHOD_TYPE   ,
   X_FAILED_UNIT_RULE  ,
   X_CART              ,
   X_RSV_SEAT_EXT_ID    ,
   X_org_unit_cd        ,
   X_GRADING_SCHEMA_CODE,
   x_subtitle,
   -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
   x_session_id,
   x_deg_aud_detail_id,
   x_student_career_transcript,
   x_student_career_statistics,
   x_waitlist_manual_ind  ,--Bug ID: 2554109  added by adhawan
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
   -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
   X_WLST_PRIORITY_WEIGHT_NUM,
   X_WLST_PREFERENCE_WEIGHT_NUM,
   -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
   X_CORE_INDICATOR_CODE,
   X_UPD_AUDIT_FLAG,
   X_SS_SOURCE_IND
);
ELSE
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
ELSIF (X_MODE IN ('R', 'S')) THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF X_LAST_UPDATED_BY IS NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    IF X_LAST_UPDATE_LOGIN IS NULL THEN
      X_LAST_UPDATE_LOGIN := -1;
   END IF;
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  IF (X_REQUEST_ID = -1) THEN
     X_REQUEST_ID := NULL;
     X_PROGRAM_ID := NULL;
     X_PROGRAM_APPLICATION_ID := NULL;
     X_PROGRAM_UPDATE_DATE := NULL;
 ELSE
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 END IF;
  ELSE
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
--
   Before_DML(
    p_action=>'INSERT',
    x_rowid=>NULL,
    x_administrative_unit_status=>X_ADMINISTRATIVE_UNIT_STATUS,
    x_alternative_title=>X_ALTERNATIVE_TITLE,
    x_cal_type=>X_CAL_TYPE,
    x_ci_end_dt=>X_CI_END_DT,
    x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
    x_ci_start_dt=>X_CI_START_DT,
    x_course_cd=>X_COURSE_CD,
    x_discontinued_dt=>X_DISCONTINUED_DT,
    x_enrolled_dt=>X_ENROLLED_DT,
    x_exam_location_cd=>X_EXAM_LOCATION_CD,
    x_location_cd=>X_LOCATION_CD,
    x_no_assessment_ind=> NVL(X_NO_ASSESSMENT_IND,'N'),
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
    x_uoo_id=>X_UOO_ID,
    x_version_number=>X_VERSION_NUMBER,
    x_administrative_priority=>X_ADMINISTRATIVE_PRIORITY,
    x_waitlist_dt=>X_WAITLIST_DT,
    x_dcnt_reason_cd => X_DCNT_REASON_CD,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN,
    x_org_id  => igs_ge_gen_003.get_org_id,
    x_gs_version_number => X_GS_VERSION_NUMBER,
    x_enr_method_type   => X_ENR_METHOD_TYPE  ,
    x_failed_unit_rule  => X_FAILED_UNIT_RULE ,
    x_cart              => X_CART             ,
    x_rsv_seat_ext_id   => X_RSV_SEAT_EXT_ID,
    x_org_unit_cd=>X_ORG_UNIT_CD              ,
    x_grading_schema_code => X_GRADING_SCHEMA_CODE,
    x_subtitle            => x_subtitle,
    -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
    x_session_id          => x_session_id,
    x_deg_aud_detail_id   => x_deg_aud_detail_id,
    x_student_career_transcript   =>  x_student_career_transcript,
    x_student_career_statistics    =>  x_student_career_statistics,
    x_waitlist_manual_ind   =>   x_waitlist_manual_ind ,--Bug ID: 2554109  added by adhawan
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
    -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
    x_wlst_priority_weight_num=>X_WLST_PRIORITY_WEIGHT_NUM,
    x_wlst_preference_weight_num=>X_WLST_PREFERENCE_WEIGHT_NUM,
    -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
    x_core_indicator_code=>X_CORE_INDICATOR_CODE,
    X_UPD_AUDIT_FLAG     =>X_UPD_AUDIT_FLAG,
    X_SS_SOURCE_IND      =>  X_SS_SOURCE_IND
    );
--
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  INSERT INTO IGS_EN_SU_ATTEMPT_ALL (
    PERSON_ID,
    COURSE_CD,
    UNIT_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    LOCATION_CD,
    UNIT_CLASS,
    CI_START_DT,
    CI_END_DT,
    UOO_ID,
    ENROLLED_DT,
    UNIT_ATTEMPT_STATUS,
    ADMINISTRATIVE_UNIT_STATUS,
    DISCONTINUED_DT,
    RULE_WAIVED_DT,
    RULE_WAIVED_PERSON_ID,
    NO_ASSESSMENT_IND,
    SUP_UNIT_CD,
    SUP_VERSION_NUMBER,
    EXAM_LOCATION_CD,
    ALTERNATIVE_TITLE,
    OVERRIDE_ENROLLED_CP,
    OVERRIDE_EFTSU,
    OVERRIDE_ACHIEVABLE_CP,
    OVERRIDE_OUTCOME_DUE_DT,
    OVERRIDE_CREDIT_REASON,
    ADMINISTRATIVE_PRIORITY,
    WAITLIST_DT,
    DCNT_REASON_CD,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    org_id,
    GS_VERSION_NUMBER,
    ENR_METHOD_TYPE  ,
    FAILED_UNIT_RULE ,
    CART             ,
    RSV_SEAT_EXT_ID   ,
    ORG_UNIT_CD      ,
    GRADING_SCHEMA_CODE ,
    subtitle,
    -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
    session_id,
    deg_aud_detail_id,
    student_career_transcript,
    student_career_statistics,
    waitlist_manual_ind ,--Bug ID: 2554109  added by adhawan
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
    -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
    WLST_PRIORITY_WEIGHT_NUM,
    WLST_PREFERENCE_WEIGHT_NUM,
    -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
    CORE_INDICATOR_CODE,
    UPD_AUDIT_FLAG,
    SS_SOURCE_IND ) VALUES (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.UNIT_CLASS,
    NEW_REFERENCES.CI_START_DT,
    NEW_REFERENCES.CI_END_DT,
    NEW_REFERENCES.UOO_ID,
    NEW_REFERENCES.ENROLLED_DT,
    NEW_REFERENCES.UNIT_ATTEMPT_STATUS,
    NEW_REFERENCES.ADMINISTRATIVE_UNIT_STATUS,
    NEW_REFERENCES.DISCONTINUED_DT,
    TRUNC(NEW_REFERENCES.RULE_WAIVED_DT),
    NEW_REFERENCES.RULE_WAIVED_PERSON_ID,
    NEW_REFERENCES.NO_ASSESSMENT_IND,
    NEW_REFERENCES.SUP_UNIT_CD,
    NEW_REFERENCES.SUP_VERSION_NUMBER,
    NEW_REFERENCES.EXAM_LOCATION_CD,
    NEW_REFERENCES.ALTERNATIVE_TITLE,
    NEW_REFERENCES.OVERRIDE_ENROLLED_CP,
    NEW_REFERENCES.OVERRIDE_EFTSU,
    NEW_REFERENCES.OVERRIDE_ACHIEVABLE_CP,
    NEW_REFERENCES.OVERRIDE_OUTCOME_DUE_DT,
    NEW_REFERENCES.OVERRIDE_CREDIT_REASON,
    NEW_REFERENCES.ADMINISTRATIVE_PRIORITY,
    NEW_REFERENCES.WAITLIST_DT,
    NEW_REFERENCES.DCNT_REASON_CD,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    NEW_REFERENCES.org_id,
    NEW_REFERENCES.GS_VERSION_NUMBER,
    NEW_REFERENCES.ENR_METHOD_TYPE,
    NEW_REFERENCES.FAILED_UNIT_RULE,
    NEW_REFERENCES.CART             ,
    NEW_REFERENCES.RSV_SEAT_EXT_ID       ,
    NEW_REFERENCES.ORG_UNIT_CD       ,
    NEW_REFERENCES.GRADING_SCHEMA_CODE ,
    new_references.subtitle,
    -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
    new_references.session_id,
    new_references.deg_aud_detail_id ,
    new_references.student_career_transcript,
    new_references.student_career_statistics,
    new_references.waitlist_manual_ind ,--Bug ID: 2554109  added by adhawan
    NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    NEW_REFERENCES.ATTRIBUTE1,
    NEW_REFERENCES.ATTRIBUTE2,
    NEW_REFERENCES.ATTRIBUTE3,
    NEW_REFERENCES.ATTRIBUTE4,
    NEW_REFERENCES.ATTRIBUTE5,
    NEW_REFERENCES.ATTRIBUTE6,
    NEW_REFERENCES.ATTRIBUTE7,
    NEW_REFERENCES.ATTRIBUTE8,
    NEW_REFERENCES.ATTRIBUTE9,
    NEW_REFERENCES.ATTRIBUTE10,
    NEW_REFERENCES.ATTRIBUTE11,
    NEW_REFERENCES.ATTRIBUTE12,
    NEW_REFERENCES.ATTRIBUTE13,
    NEW_REFERENCES.ATTRIBUTE14,
    NEW_REFERENCES.ATTRIBUTE15,
    NEW_REFERENCES.ATTRIBUTE16,
    NEW_REFERENCES.ATTRIBUTE17,
    NEW_REFERENCES.ATTRIBUTE18,
    NEW_REFERENCES.ATTRIBUTE19,
    NEW_REFERENCES.ATTRIBUTE20,
    -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
    NEW_REFERENCES.WLST_PRIORITY_WEIGHT_NUM,
    NEW_REFERENCES.WLST_PREFERENCE_WEIGHT_NUM,
    -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
    NEW_REFERENCES.CORE_INDICATOR_CODE,
      NEW_REFERENCES.UPD_AUDIT_FLAG,
      NEW_REFERENCES.SS_SOURCE_IND      );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;
--
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
--
END IF;
CLOSE cur_rowid;

EXCEPTION
  WHEN resource_busy THEN
    fnd_message.set_name('FND', 'FND_LOCK_RECORD_ERROR');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_ROWID IN  VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_UNIT_CD IN VARCHAR2,
  X_CAL_TYPE IN VARCHAR2,
  X_CI_SEQUENCE_NUMBER IN NUMBER,
  X_VERSION_NUMBER IN NUMBER,
  X_LOCATION_CD IN VARCHAR2,
  X_UNIT_CLASS IN VARCHAR2,
  X_CI_START_DT IN DATE,
  X_CI_END_DT IN DATE,
  X_UOO_ID IN NUMBER,
  X_ENROLLED_DT IN DATE,
  X_UNIT_ATTEMPT_STATUS IN VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS IN VARCHAR2,
  X_DISCONTINUED_DT IN DATE,
  X_RULE_WAIVED_DT IN DATE,
  X_RULE_WAIVED_PERSON_ID IN NUMBER,
  X_NO_ASSESSMENT_IND IN VARCHAR2,
  X_SUP_UNIT_CD IN VARCHAR2,
  X_SUP_VERSION_NUMBER IN NUMBER,
  X_EXAM_LOCATION_CD IN VARCHAR2,
  X_ALTERNATIVE_TITLE IN VARCHAR2,
  X_OVERRIDE_ENROLLED_CP IN NUMBER,
  X_OVERRIDE_EFTSU IN NUMBER,
  X_OVERRIDE_ACHIEVABLE_CP IN NUMBER,
  X_OVERRIDE_OUTCOME_DUE_DT IN DATE,
  X_OVERRIDE_CREDIT_REASON IN VARCHAR2,
  X_ADMINISTRATIVE_PRIORITY IN NUMBER,
  X_WAITLIST_DT IN DATE,
  X_DCNT_REASON_CD IN VARCHAR2,
  X_GS_VERSION_NUMBER IN NUMBER  ,
  X_ENR_METHOD_TYPE   IN VARCHAR2,
  X_FAILED_UNIT_RULE  IN VARCHAR2,
  X_CART              IN VARCHAR2,
  X_RSV_SEAT_EXT_ID   IN NUMBER  ,
  X_ORG_UNIT_CD IN VARCHAR2 ,
  X_GRADING_SCHEMA_CODE IN VARCHAR2 ,
  x_subtitle            IN VARCHAR2 ,
  -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
  x_session_id          IN NUMBER ,
  X_deg_aud_detail_id   IN NUMBER ,
  x_student_career_transcript IN VARCHAR2 ,
  x_student_career_statistics IN VARCHAR2 ,
  x_waitlist_manual_ind    IN VARCHAR2,--Bug ID: 2554109  added by adhawan
  X_ATTRIBUTE_CATEGORY IN VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE16 IN VARCHAR2,
  X_ATTRIBUTE17 IN VARCHAR2,
  X_ATTRIBUTE18 IN VARCHAR2,
  X_ATTRIBUTE19 IN VARCHAR2,
  x_ATTRIBUTE20 IN VARCHAR2,
  -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
  X_WLST_PRIORITY_WEIGHT_NUM IN NUMBER,
  X_WLST_PREFERENCE_WEIGHT_NUM IN NUMBER,
  -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
  X_CORE_INDICATOR_CODE IN VARCHAR2,
  X_UPD_AUDIT_FLAG      IN VARCHAR2,
  X_SS_SOURCE_IND       IN VARCHAR2
) AS
  CURSOR c1 IS SELECT
      VERSION_NUMBER,
      LOCATION_CD,
      UNIT_CLASS,
      CI_START_DT,
      CI_END_DT,
      UOO_ID,
      ENROLLED_DT,
      UNIT_ATTEMPT_STATUS,
      ADMINISTRATIVE_UNIT_STATUS,
      DISCONTINUED_DT,
      RULE_WAIVED_DT,
      RULE_WAIVED_PERSON_ID,
      NO_ASSESSMENT_IND,
      SUP_UNIT_CD,
      SUP_VERSION_NUMBER,
      EXAM_LOCATION_CD,
      ALTERNATIVE_TITLE,
      OVERRIDE_ENROLLED_CP,
      OVERRIDE_EFTSU,
      OVERRIDE_ACHIEVABLE_CP,
      OVERRIDE_OUTCOME_DUE_DT,
      OVERRIDE_CREDIT_REASON,
      ADMINISTRATIVE_PRIORITY,
      WAITLIST_DT,
      dcnt_reason_cd,
      GS_VERSION_NUMBER,
      ENR_METHOD_TYPE  ,
      FAILED_UNIT_RULE ,
      CART             ,
      RSV_SEAT_EXT_ID ,
      ORG_UNIT_CD     ,
      GRADING_SCHEMA_CODE,
      subtitle,
    -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
      session_id,
     deg_aud_detail_id,
     student_career_transcript,
     student_career_statistics,
     waitlist_manual_ind ,--Bug ID: 2554109  added by adhawan
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     ATTRIBUTE16,
     ATTRIBUTE17,
     ATTRIBUTE18,
     ATTRIBUTE19,
     ATTRIBUTE20,
     -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
     WLST_PRIORITY_WEIGHT_NUM,
     WLST_PREFERENCE_WEIGHT_NUM,
     -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
     CORE_INDICATOR_CODE,
     UPD_AUDIT_FLAG,
     SS_SOURCE_IND
   FROM IGS_EN_SU_ATTEMPT_ALL
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
  IF ( (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
      AND (tlinfo.LOCATION_CD = X_LOCATION_CD)
      AND (tlinfo.UNIT_CLASS = X_UNIT_CLASS)
      AND (tlinfo.CI_START_DT = X_CI_START_DT)
      AND (tlinfo.CI_END_DT = X_CI_END_DT)
      AND (tlinfo.UOO_ID = X_UOO_ID)
      AND (( TRUNC(tlinfo.ENROLLED_DT) = TRUNC(X_ENROLLED_DT) )
           OR ((tlinfo.ENROLLED_DT IS NULL)
               AND (X_ENROLLED_DT IS NULL)))
      AND (tlinfo.UNIT_ATTEMPT_STATUS = X_UNIT_ATTEMPT_STATUS)
      AND ((tlinfo.ADMINISTRATIVE_UNIT_STATUS = X_ADMINISTRATIVE_UNIT_STATUS)
           OR ((tlinfo.ADMINISTRATIVE_UNIT_STATUS IS NULL)
               AND (X_ADMINISTRATIVE_UNIT_STATUS IS NULL)))
      AND (( TRUNC(tlinfo.DISCONTINUED_DT) = TRUNC(X_DISCONTINUED_DT) )
           OR ((tlinfo.DISCONTINUED_DT IS NULL)
               AND (X_DISCONTINUED_DT IS NULL)))
      AND (( TRUNC(tlinfo.RULE_WAIVED_DT) = TRUNC(X_RULE_WAIVED_DT))
           OR ((tlinfo.RULE_WAIVED_DT IS NULL)
               AND (X_RULE_WAIVED_DT IS NULL)))
      AND ((tlinfo.RULE_WAIVED_PERSON_ID = X_RULE_WAIVED_PERSON_ID)
           OR ((tlinfo.RULE_WAIVED_PERSON_ID IS NULL)
               AND (X_RULE_WAIVED_PERSON_ID IS NULL)))
      AND (tlinfo.NO_ASSESSMENT_IND = X_NO_ASSESSMENT_IND)
      AND ((tlinfo.SUP_UNIT_CD = X_SUP_UNIT_CD)
           OR ((tlinfo.SUP_UNIT_CD IS NULL)
               AND (X_SUP_UNIT_CD IS NULL)))
      AND ((tlinfo.SUP_VERSION_NUMBER = X_SUP_VERSION_NUMBER)
           OR ((tlinfo.SUP_VERSION_NUMBER IS NULL)
               AND (X_SUP_VERSION_NUMBER IS NULL)))
      AND ((tlinfo.EXAM_LOCATION_CD = X_EXAM_LOCATION_CD)
           OR ((tlinfo.EXAM_LOCATION_CD IS NULL)
               AND (X_EXAM_LOCATION_CD IS NULL)))
      AND ((tlinfo.ALTERNATIVE_TITLE = X_ALTERNATIVE_TITLE)
           OR ((tlinfo.ALTERNATIVE_TITLE IS NULL)
               AND (X_ALTERNATIVE_TITLE IS NULL)))
      AND ((tlinfo.OVERRIDE_ENROLLED_CP = X_OVERRIDE_ENROLLED_CP)
           OR ((tlinfo.OVERRIDE_ENROLLED_CP IS NULL)
               AND (X_OVERRIDE_ENROLLED_CP IS NULL)))
      AND ((tlinfo.OVERRIDE_EFTSU = X_OVERRIDE_EFTSU)
           OR ((tlinfo.OVERRIDE_EFTSU IS NULL)
               AND (X_OVERRIDE_EFTSU IS NULL)))
      AND ((tlinfo.OVERRIDE_ACHIEVABLE_CP = X_OVERRIDE_ACHIEVABLE_CP)
           OR ((tlinfo.OVERRIDE_ACHIEVABLE_CP IS NULL)
               AND (X_OVERRIDE_ACHIEVABLE_CP IS NULL)))
      AND (( TRUNC(tlinfo.OVERRIDE_OUTCOME_DUE_DT) = TRUNC(X_OVERRIDE_OUTCOME_DUE_DT))
           OR ((tlinfo.OVERRIDE_OUTCOME_DUE_DT IS NULL)
               AND (X_OVERRIDE_OUTCOME_DUE_DT IS NULL)))
      AND ((tlinfo.OVERRIDE_CREDIT_REASON = X_OVERRIDE_CREDIT_REASON)
           OR ((tlinfo.OVERRIDE_CREDIT_REASON IS NULL)
               AND (X_OVERRIDE_CREDIT_REASON IS NULL)))
      AND ((tlinfo.dcnt_reason_cd = X_dcnt_reason_Cd)
           OR ((tlinfo.dcnt_reason_cd IS NULL)
               AND (X_dcnt_reason_cd IS NULL)))
      AND ((tlinfo.GS_VERSION_NUMBER = X_GS_VERSION_NUMBER)
           OR ((tlinfo.GS_VERSION_NUMBER IS NULL)
               AND (X_GS_VERSION_NUMBER IS NULL)))
      AND ((tlinfo.ENR_METHOD_TYPE = X_ENR_METHOD_TYPE)
           OR ((tlinfo.ENR_METHOD_TYPE IS NULL)
               AND (X_ENR_METHOD_TYPE IS NULL)))
      AND ((tlinfo.FAILED_UNIT_RULE = X_FAILED_UNIT_RULE)
           OR ((tlinfo.FAILED_UNIT_RULE IS NULL)
               AND (X_FAILED_UNIT_RULE IS NULL)))
      AND ((tlinfo.CART = X_CART)
           OR ((tlinfo.CART IS NULL)
               AND (X_CART IS NULL)))
      AND ((tlinfo.RSV_SEAT_EXT_ID = X_RSV_SEAT_EXT_ID)
           OR ((tlinfo.RSV_SEAT_EXT_ID IS NULL)
               AND (X_RSV_SEAT_EXT_ID IS NULL)))
      AND ((tlinfo.ORG_UNIT_CD = X_ORG_UNIT_CD)
           OR ((tlinfo.ORG_UNIT_CD IS NULL)
               AND (X_ORG_UNIT_CD IS NULL)))
      AND ((tlinfo.GRADING_SCHEMA_CODE = X_GRADING_SCHEMA_CODE)
           OR ((tlinfo.GRADING_SCHEMA_CODE IS NULL)
               AND (X_GRADING_SCHEMA_CODE IS NULL)))
      AND ((tlinfo.subtitle= X_subtitle)
           OR ((tlinfo.subtitle  IS NULL)
               AND (X_subtitle IS NULL)))
    -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
      AND ((tlinfo.session_id = x_session_id)
           OR ((tlinfo.session_id  IS NULL)
               AND (x_session_id IS NULL)))
      AND ((tlinfo.deg_aud_detail_id = X_deg_aud_detail_id)
           OR ((tlinfo.deg_aud_detail_id  IS NULL)
               AND (X_deg_aud_detail_id IS NULL)))
      AND ((tlinfo.student_career_transcript = X_student_career_transcript)
           OR ((tlinfo.student_career_transcript  IS NULL)
               AND (X_student_career_transcript IS NULL)))

      AND ((tlinfo.student_career_statistics = X_student_career_statistics)
           OR ((tlinfo.student_career_statistics  IS NULL)
               AND (X_student_career_statistics IS NULL)))

--Bug ID: 2554109  added by adhawan
      AND   ((tlinfo.waitlist_manual_ind = X_waitlist_manual_ind)
               OR (( tlinfo.waitlist_manual_ind IS NULL )
               AND (X_WAITLIST_MANUAL_IND IS NULL)))

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
      AND ((tlinfo.ADMINISTRATIVE_PRIORITY = X_ADMINISTRATIVE_PRIORITY)
           OR ((tlinfo.ADMINISTRATIVE_PRIORITY IS NULL)
               AND (X_ADMINISTRATIVE_PRIORITY IS NULL)))
      AND (( TRUNC(tlinfo.WAITLIST_DT) = TRUNC(X_WAITLIST_DT) )
           OR ((tlinfo.WAITLIST_DT IS NULL)
               AND (X_WAITLIST_DT IS NULL)))
      -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
      AND   ((tlinfo.wlst_priority_weight_num = X_wlst_priority_weight_num)
               OR (( tlinfo.wlst_priority_weight_num IS NULL )
               AND (X_WLST_PRIORITY_WEIGHT_NUM IS NULL)))
      AND   ((tlinfo.wlst_preference_weight_num = X_wlst_preference_weight_num)
               OR (( tlinfo.wlst_preference_weight_num IS NULL )
               AND (X_WLST_PREFERENCE_WEIGHT_NUM IS NULL)))
      -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
      AND   ((tlinfo.core_indicator_code = X_core_indicator_code)
               OR (( tlinfo.core_indicator_code IS NULL )
               AND (X_CORE_INDICATOR_CODE IS NULL)))
      AND (tlinfo.UPD_AUDIT_FLAG = X_UPD_AUDIT_FLAG)
      AND (tlinfo.SS_SOURCE_IND = X_SS_SOURCE_IND)
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  RETURN;
END LOCK_ROW;

/*------------------------------------------------------------------------------------------------------------------------------------------
   svanukur             28-APR-03          Not allowing the update of uoo_id as it is now part of Pk
   --                                      as part of MUS build, # 2829262
---------------------------------------------------------------------------------------*/
PROCEDURE UPDATE_ROW (
  X_ROWID IN  VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_UNIT_CD IN VARCHAR2,
  X_CAL_TYPE IN VARCHAR2,
  X_CI_SEQUENCE_NUMBER IN NUMBER,
  X_VERSION_NUMBER IN NUMBER,
  X_LOCATION_CD IN VARCHAR2,
  X_UNIT_CLASS IN VARCHAR2,
  X_CI_START_DT IN DATE,
  X_CI_END_DT IN DATE,
  X_UOO_ID IN NUMBER,
  X_ENROLLED_DT IN DATE,
  X_UNIT_ATTEMPT_STATUS IN VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS IN VARCHAR2,
  X_DISCONTINUED_DT IN DATE,
  X_RULE_WAIVED_DT IN DATE,
  X_RULE_WAIVED_PERSON_ID IN NUMBER,
  X_NO_ASSESSMENT_IND IN VARCHAR2,
  X_SUP_UNIT_CD IN VARCHAR2,
  X_SUP_VERSION_NUMBER IN NUMBER,
  X_EXAM_LOCATION_CD IN VARCHAR2,
  X_ALTERNATIVE_TITLE IN VARCHAR2,
  X_OVERRIDE_ENROLLED_CP IN NUMBER,
  X_OVERRIDE_EFTSU IN NUMBER,
  X_OVERRIDE_ACHIEVABLE_CP IN NUMBER,
  X_OVERRIDE_OUTCOME_DUE_DT IN DATE,
  X_OVERRIDE_CREDIT_REASON IN VARCHAR2,
  X_ADMINISTRATIVE_PRIORITY IN NUMBER,
  X_WAITLIST_DT IN DATE,
  x_dcnt_reason_cd IN VARCHAR2,
  X_MODE IN VARCHAR2 ,
  X_GS_VERSION_NUMBER IN NUMBER  ,
  X_ENR_METHOD_TYPE   IN VARCHAR2,
  X_FAILED_UNIT_RULE  IN VARCHAR2,
  X_CART              IN VARCHAR2,
  X_RSV_SEAT_EXT_ID   IN NUMBER  ,
  X_ORG_UNIT_CD          IN VARCHAR2 ,
  X_GRADING_SCHEMA_CODE  IN VARCHAR2 ,
  x_subtitle             IN VARCHAR2 ,
  -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
  x_session_id           IN NUMBER ,
  x_deg_aud_detail_id   IN NUMBER ,
  x_student_career_transcript IN VARCHAR2 ,
  x_student_career_statistics IN VARCHAR2 ,
  x_waitlist_manual_ind  IN VARCHAR2,--Bug ID: 2554109  added by adhawan
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  x_ATTRIBUTE20 IN VARCHAR2 ,
  -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
  X_WLST_PRIORITY_WEIGHT_NUM IN NUMBER ,
  X_WLST_PREFERENCE_WEIGHT_NUM IN NUMBER ,
  -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
  X_CORE_INDICATOR_CODE IN VARCHAR2,
  X_UPD_AUDIT_FLAG      IN VARCHAR2 ,
  X_SS_SOURCE_IND       IN VARCHAR2
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;

    resource_busy  EXCEPTION;
    PRAGMA EXCEPTION_INIT(resource_busy,-00054);

BEGIN
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE IN ('R', 'S')) THEN
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
    x_administrative_unit_status=>X_ADMINISTRATIVE_UNIT_STATUS,
    x_alternative_title=>X_ALTERNATIVE_TITLE,
    x_cal_type=>X_CAL_TYPE,
    x_ci_end_dt=>X_CI_END_DT,
    x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
    x_ci_start_dt=>X_CI_START_DT,
    x_course_cd=>X_COURSE_CD,
    x_discontinued_dt=>X_DISCONTINUED_DT,
    x_enrolled_dt=>X_ENROLLED_DT,
    x_exam_location_cd=>X_EXAM_LOCATION_CD,
    x_location_cd=>X_LOCATION_CD,
    x_no_assessment_ind=>NVL(X_NO_ASSESSMENT_IND,'N'),
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
    x_uoo_id=>X_UOO_ID,
    x_version_number=>X_VERSION_NUMBER,
    x_administrative_priority=>X_ADMINISTRATIVE_PRIORITY,
    x_waitlist_dt=>X_WAITLIST_DT,
    x_dcnt_reason_cd => x_dcnt_reason_cd,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN,
    x_gs_version_number=>X_GS_VERSION_NUMBER,
    x_enr_method_type=>X_ENR_METHOD_TYPE,
    x_failed_unit_rule=>X_FAILED_UNIT_RULE,
    x_cart            => X_CART,
    x_rsv_seat_ext_id => X_RSV_SEAT_EXT_ID,
    x_org_unit_cd => X_ORG_UNIT_CD   ,
    x_grading_schema_code => X_GRADING_SCHEMA_CODE ,
    x_subtitle            => x_subtitle,
    -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
    x_session_id          => x_session_id,
    x_deg_aud_detail_id   => x_deg_aud_detail_id,
    x_student_career_transcript   =>  x_student_career_transcript,
    x_student_career_statistics    =>  x_student_career_statistics,
    x_waitlist_manual_ind => x_waitlist_manual_ind,--Bug ID: 2554109  added by adhawan
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
    -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
    x_wlst_priority_weight_num=>X_WLST_PRIORITY_WEIGHT_NUM,
    x_wlst_preference_weight_num=>X_WLST_PREFERENCE_WEIGHT_NUM,
    -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
    x_core_indicator_code=>X_CORE_INDICATOR_CODE,
    X_UPD_AUDIT_FLAG => X_UPD_AUDIT_FLAG,
    X_SS_SOURCE_IND  => X_SS_SOURCE_IND
    );
 IF (X_MODE IN ('R', 'S')) THEN
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  IF (X_REQUEST_ID = -1) THEN
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
 ELSE
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 END IF;
--Before_DML(
--
END IF;

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  UPDATE IGS_EN_SU_ATTEMPT_ALL SET
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    UNIT_CLASS = NEW_REFERENCES.UNIT_CLASS,
    CI_START_DT = NEW_REFERENCES.CI_START_DT,
    CI_END_DT = NEW_REFERENCES.CI_END_DT,
    ENROLLED_DT = NEW_REFERENCES.ENROLLED_DT,
    UNIT_ATTEMPT_STATUS = NEW_REFERENCES.UNIT_ATTEMPT_STATUS,
    ADMINISTRATIVE_UNIT_STATUS = NEW_REFERENCES.ADMINISTRATIVE_UNIT_STATUS,
    DISCONTINUED_DT = NEW_REFERENCES.DISCONTINUED_DT,
    RULE_WAIVED_DT = TRUNC(NEW_REFERENCES.RULE_WAIVED_DT),
    RULE_WAIVED_PERSON_ID = NEW_REFERENCES.RULE_WAIVED_PERSON_ID,
    NO_ASSESSMENT_IND = NEW_REFERENCES.NO_ASSESSMENT_IND,
    SUP_UNIT_CD = NEW_REFERENCES.SUP_UNIT_CD,
    SUP_VERSION_NUMBER = NEW_REFERENCES.SUP_VERSION_NUMBER,
    EXAM_LOCATION_CD = NEW_REFERENCES.EXAM_LOCATION_CD,
    ALTERNATIVE_TITLE = NEW_REFERENCES.ALTERNATIVE_TITLE,
    OVERRIDE_ENROLLED_CP = NEW_REFERENCES.OVERRIDE_ENROLLED_CP,
    OVERRIDE_EFTSU = NEW_REFERENCES.OVERRIDE_EFTSU,
    OVERRIDE_ACHIEVABLE_CP = NEW_REFERENCES.OVERRIDE_ACHIEVABLE_CP,
    OVERRIDE_OUTCOME_DUE_DT = NEW_REFERENCES.OVERRIDE_OUTCOME_DUE_DT,
    OVERRIDE_CREDIT_REASON = NEW_REFERENCES.OVERRIDE_CREDIT_REASON,
    ADMINISTRATIVE_PRIORITY = NEW_REFERENCES.ADMINISTRATIVE_PRIORITY,
    WAITLIST_DT = NEW_REFERENCES.WAITLIST_DT,
    DCNT_REASON_CD = new_references.DCNT_REASON_CD,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    GS_VERSION_NUMBER   = NEW_REFERENCES.GS_VERSION_NUMBER,
    ENR_METHOD_TYPE     = NEW_REFERENCES.ENR_METHOD_TYPE  ,
    FAILED_UNIT_RULE    = NEW_REFERENCES.FAILED_UNIT_RULE ,
    CART                = NEW_REFERENCES.CART             ,
    RSV_SEAT_EXT_ID     = NEW_REFERENCES.RSV_SEAT_EXT_ID,
    ORG_UNIT_CD         = NEW_REFERENCES.ORG_UNIT_CD           ,
    GRADING_SCHEMA_CODE = NEW_REFERENCES.GRADING_SCHEMA_CODE,
    subtitle            = new_references.subtitle,
    -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
    session_id          = new_references.session_id,
    deg_aud_detail_id   = new_references.deg_aud_detail_id  ,
    student_career_transcript = new_references.student_career_transcript,
    student_career_statistics =  new_references.student_career_statistics,
    waitlist_manual_ind =  new_references.waitlist_manual_ind,--Bug ID: 2554109  added by adhawan
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
    -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
    WLST_PRIORITY_WEIGHT_NUM = NEW_REFERENCES.WLST_PRIORITY_WEIGHT_NUM,
    WLST_PREFERENCE_WEIGHT_NUM = NEW_REFERENCES.WLST_PREFERENCE_WEIGHT_NUM,
    -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
    CORE_INDICATOR_CODE = NEW_REFERENCES.CORE_INDICATOR_CODE,
    UPD_AUDIT_FLAG      = NEW_REFERENCES.UPD_AUDIT_FLAG ,
    SS_SOURCE_IND       = NEW_REFERENCES. SS_SOURCE_IND
  WHERE ROWID = X_ROWID;
  IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

--
After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
--
EXCEPTION
  WHEN resource_busy THEN
    fnd_message.set_name('FND', 'FND_LOCK_RECORD_ERROR');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

END UPDATE_ROW;
PROCEDURE ADD_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_PERSON_ID IN NUMBER,
  X_COURSE_CD IN VARCHAR2,
  X_UNIT_CD IN VARCHAR2,
  X_CAL_TYPE IN VARCHAR2,
  X_CI_SEQUENCE_NUMBER IN NUMBER,
  X_VERSION_NUMBER IN NUMBER,
  X_LOCATION_CD IN VARCHAR2,
  X_UNIT_CLASS IN VARCHAR2,
  X_CI_START_DT IN DATE,
  X_CI_END_DT IN DATE,
  X_UOO_ID IN NUMBER,
  X_ENROLLED_DT IN DATE,
  X_UNIT_ATTEMPT_STATUS IN VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS IN VARCHAR2,
  X_DISCONTINUED_DT IN DATE,
  X_RULE_WAIVED_DT IN DATE,
  X_RULE_WAIVED_PERSON_ID IN NUMBER,
  X_NO_ASSESSMENT_IND IN VARCHAR2,
  X_SUP_UNIT_CD IN VARCHAR2,
  X_SUP_VERSION_NUMBER IN NUMBER,
  X_EXAM_LOCATION_CD IN VARCHAR2,
  X_ALTERNATIVE_TITLE IN VARCHAR2,
  X_OVERRIDE_ENROLLED_CP IN NUMBER,
  X_OVERRIDE_EFTSU IN NUMBER,
  X_OVERRIDE_ACHIEVABLE_CP IN NUMBER,
  X_OVERRIDE_OUTCOME_DUE_DT IN DATE,
  X_OVERRIDE_CREDIT_REASON IN VARCHAR2,
  X_ADMINISTRATIVE_PRIORITY IN NUMBER,
  X_WAITLIST_DT IN DATE,
  x_dcnt_reason_cd IN VARCHAR2,
  X_MODE IN VARCHAR2 ,
  x_org_id IN NUMBER,
  X_GS_VERSION_NUMBER IN NUMBER   ,
  X_ENR_METHOD_TYPE   IN VARCHAR2 ,
  X_FAILED_UNIT_RULE  IN VARCHAR2 ,
  X_CART              IN VARCHAR2 ,
  X_RSV_SEAT_EXT_ID   IN NUMBER   ,
  X_ORG_UNIT_CD  IN VARCHAR2 ,
  X_GRADING_SCHEMA_CODE IN VARCHAR2 ,
  x_subtitle            IN VARCHAR2 ,
  -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
  x_session_id          IN NUMBER   ,
  X_deg_aud_detail_id   IN NUMBER   ,
  x_student_career_transcript IN VARCHAR2 ,
  x_student_career_statistics IN VARCHAR2 ,
  x_waitlist_manual_ind  IN VARCHAR2,--Bug ID: 2554109  added by adhawan
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1 IN VARCHAR2 ,
  X_ATTRIBUTE2 IN VARCHAR2 ,
  X_ATTRIBUTE3 IN VARCHAR2 ,
  X_ATTRIBUTE4 IN VARCHAR2 ,
  X_ATTRIBUTE5 IN VARCHAR2 ,
  X_ATTRIBUTE6 IN VARCHAR2 ,
  X_ATTRIBUTE7 IN VARCHAR2 ,
  X_ATTRIBUTE8 IN VARCHAR2 ,
  X_ATTRIBUTE9 IN VARCHAR2 ,
  X_ATTRIBUTE10 IN VARCHAR2 ,
  X_ATTRIBUTE11 IN VARCHAR2 ,
  X_ATTRIBUTE12 IN VARCHAR2 ,
  X_ATTRIBUTE13 IN VARCHAR2 ,
  X_ATTRIBUTE14 IN VARCHAR2 ,
  X_ATTRIBUTE15 IN VARCHAR2 ,
  X_ATTRIBUTE16 IN VARCHAR2 ,
  X_ATTRIBUTE17 IN VARCHAR2 ,
  X_ATTRIBUTE18 IN VARCHAR2 ,
  X_ATTRIBUTE19 IN VARCHAR2 ,
  x_ATTRIBUTE20 IN VARCHAR2 ,
  -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
  X_WLST_PRIORITY_WEIGHT_NUM IN NUMBER ,
  X_WLST_PREFERENCE_WEIGHT_NUM IN NUMBER ,
  -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
  X_CORE_INDICATOR_CODE IN VARCHAR2,
  X_UPD_AUDIT_FLAG      IN VARCHAR2 ,
  X_SS_SOURCE_IND       IN VARCHAR2
  ) AS
  CURSOR c1 IS SELECT ROWID FROM IGS_EN_SU_ATTEMPT_ALL
     WHERE PERSON_ID = X_PERSON_ID
     AND COURSE_CD = X_COURSE_CD
     AND UOO_ID = X_UOO_ID

  ;
BEGIN
  OPEN c1;
  FETCH c1 INTO X_ROWID;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_UNIT_CD,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_VERSION_NUMBER,
     X_LOCATION_CD,
     X_UNIT_CLASS,
     X_CI_START_DT,
     X_CI_END_DT,
     X_UOO_ID,
     X_ENROLLED_DT,
     X_UNIT_ATTEMPT_STATUS,
     X_ADMINISTRATIVE_UNIT_STATUS,
     X_DISCONTINUED_DT,
     X_RULE_WAIVED_DT,
     X_RULE_WAIVED_PERSON_ID,
     X_NO_ASSESSMENT_IND,
     X_SUP_UNIT_CD,
     X_SUP_VERSION_NUMBER,
     X_EXAM_LOCATION_CD,
     X_ALTERNATIVE_TITLE,
     X_OVERRIDE_ENROLLED_CP,
     X_OVERRIDE_EFTSU,
     X_OVERRIDE_ACHIEVABLE_CP,
     X_OVERRIDE_OUTCOME_DUE_DT,
     X_OVERRIDE_CREDIT_REASON,
     X_ADMINISTRATIVE_PRIORITY,
     X_WAITLIST_DT,
     X_DCNT_REASON_CD,
     X_MODE,
     x_org_id ,
     X_GS_VERSION_NUMBER  ,
     X_ENR_METHOD_TYPE    ,
     X_FAILED_UNIT_RULE   ,
     X_CART               ,
     X_RSV_SEAT_EXT_ID ,
     X_ORG_UNIT_CD    ,
     X_GRADING_SCHEMA_CODE ,
     X_subtitle,
    -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
     x_session_id,
     X_deg_aud_detail_id  ,
     x_student_career_transcript,
     x_student_career_statistics,
     X_waitlist_manual_ind,--Bug ID: 2554109  added by adhawan
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
     -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
     X_WLST_PRIORITY_WEIGHT_NUM,
     X_WLST_PREFERENCE_WEIGHT_NUM,
     -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
     X_CORE_INDICATOR_CODE,
     X_UPD_AUDIT_FLAG,
     X_SS_SOURCE_IND
  );
    RETURN;
  END IF;
  CLOSE c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_UNIT_CD,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_VERSION_NUMBER,
   X_LOCATION_CD,
   X_UNIT_CLASS,
   X_CI_START_DT,
   X_CI_END_DT,
   X_UOO_ID,
   X_ENROLLED_DT,
   X_UNIT_ATTEMPT_STATUS,
   X_ADMINISTRATIVE_UNIT_STATUS,
   X_DISCONTINUED_DT,
   X_RULE_WAIVED_DT,
   X_RULE_WAIVED_PERSON_ID,
   X_NO_ASSESSMENT_IND,
   X_SUP_UNIT_CD,
   X_SUP_VERSION_NUMBER,
   X_EXAM_LOCATION_CD,
   X_ALTERNATIVE_TITLE,
   X_OVERRIDE_ENROLLED_CP,
   X_OVERRIDE_EFTSU,
   X_OVERRIDE_ACHIEVABLE_CP,
   X_OVERRIDE_OUTCOME_DUE_DT,
   X_OVERRIDE_CREDIT_REASON,
   X_ADMINISTRATIVE_PRIORITY,
   X_WAITLIST_DT,
   X_DCNT_REASON_CD,
   X_MODE,
   X_GS_VERSION_NUMBER,
   X_ENR_METHOD_TYPE,
   X_FAILED_UNIT_RULE,
   X_CART               ,
   X_RSV_SEAT_EXT_ID ,
   X_ORG_UNIT_CD,
   X_GRADING_SCHEMA_CODE ,
   X_subtitle,
   -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
   x_session_id,
   X_deg_aud_detail_id  ,
   x_student_career_transcript,
   x_student_career_statistics,
   X_waitlist_manual_ind,--Bug ID: 2554109  added by adhawan
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
   -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
   X_WLST_PRIORITY_WEIGHT_NUM,
   X_WLST_PREFERENCE_WEIGHT_NUM,
   -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
   X_CORE_INDICATOR_CODE,
   X_UPD_AUDIT_FLAG,
   X_SS_SOURCE_IND
  );
END ADD_ROW;
PROCEDURE DELETE_ROW (
  X_ROWID IN VARCHAR2,
  x_mode IN VARCHAR2) AS

    /* Cursor to get the unit attempt attempts attributes, bug 3000742*/
    CURSOR cur_sua (cp_rowid VARCHAR2) IS
    SELECT *
    FROM igs_en_su_attempt
    WHERE row_id = cp_rowid;

    /* Cursor to check whether the unit attempt status before adding to cart is DROPPED, bug 3000742*/
    CURSOR cur_sua_hist (cp_person_id NUMBER,cp_course_cd VARCHAR2, cp_uoo_id NUMBER) IS
    SELECT unit_attempt_status
    FROM igs_en_su_attempt_h
    WHERE person_id = cp_person_id
    AND   course_cd = cp_course_cd
    AND   uoo_id = cp_uoo_id
    ORDER BY hist_end_dt DESC;

    l_cur_sua_rec cur_sua%ROWTYPE;
    l_sua_status igs_en_su_attempt.unit_attempt_status%TYPE;

BEGIN

OPEN cur_sua(X_ROWID);
FETCH cur_sua INTO l_cur_sua_rec;
CLOSE cur_sua;
--
  OPEN cur_sua_hist(l_cur_sua_rec.person_id,l_cur_sua_rec.course_cd,l_cur_sua_rec.uoo_id );
  FETCH cur_sua_hist INTO l_sua_status;
  CLOSE cur_sua_hist;
  --
  -- If the unit attempt status before adding to cart was DROPPED then while cleaning the cart move back the unit
  -- to DROPPED status.
  --
  IF l_sua_status='DROPPED' THEN
      igs_en_sua_api.update_unit_attempt(
             X_ROWID                          => X_ROWID,
             X_PERSON_ID                      => l_cur_sua_rec.PERSON_ID,
             X_COURSE_CD                      => l_cur_sua_rec.COURSE_CD ,
             X_UNIT_CD                        => l_cur_sua_rec.UNIT_CD,
             X_CAL_TYPE                       => l_cur_sua_rec.CAL_TYPE,
             X_CI_SEQUENCE_NUMBER             => l_cur_sua_rec.CI_SEQUENCE_NUMBER ,
             X_VERSION_NUMBER                 => l_cur_sua_rec.version_number ,
             X_LOCATION_CD                    => l_cur_sua_rec.location_cd,
             X_UNIT_CLASS                     => l_cur_sua_rec.unit_class,
             X_CI_START_DT                    => l_cur_sua_rec.CI_START_DT,
             X_CI_END_DT                      => l_cur_sua_rec.CI_END_DT,
             X_UOO_ID                         => l_cur_sua_rec.uoo_id,
             X_ENROLLED_DT                    => l_cur_sua_rec.ENROLLED_DT,
             X_UNIT_ATTEMPT_STATUS            => 'DROPPED',
             X_ADMINISTRATIVE_UNIT_STATUS     => l_cur_sua_rec.administrative_unit_status,
             X_ADMINISTRATIVE_PRIORITY        => l_cur_sua_rec.administrative_priority,
             X_DISCONTINUED_DT                => nvl(l_cur_sua_rec.discontinued_dt,SYSDATE),
             X_DCNT_REASON_CD                 => l_cur_sua_rec.DCNT_REASON_CD ,
             X_RULE_WAIVED_DT                 => l_cur_sua_rec.RULE_WAIVED_DT ,
             X_RULE_WAIVED_PERSON_ID          => l_cur_sua_rec.RULE_WAIVED_PERSON_ID ,
             X_NO_ASSESSMENT_IND              => l_cur_sua_rec.NO_ASSESSMENT_IND,
             X_SUP_UNIT_CD                    => l_cur_sua_rec.SUP_UNIT_CD ,
             X_SUP_VERSION_NUMBER             => l_cur_sua_rec.SUP_VERSION_NUMBER,
             X_EXAM_LOCATION_CD               => l_cur_sua_rec.EXAM_LOCATION_CD,
             X_ALTERNATIVE_TITLE              => l_cur_sua_rec.ALTERNATIVE_TITLE ,
             X_OVERRIDE_ENROLLED_CP           => l_cur_sua_rec.OVERRIDE_ENROLLED_CP,
             X_OVERRIDE_EFTSU                 => l_cur_sua_rec.OVERRIDE_EFTSU ,
             X_OVERRIDE_ACHIEVABLE_CP         => l_cur_sua_rec.OVERRIDE_ACHIEVABLE_CP,
             X_OVERRIDE_OUTCOME_DUE_DT        => l_cur_sua_rec.OVERRIDE_OUTCOME_DUE_DT,
             X_OVERRIDE_CREDIT_REASON         => l_cur_sua_rec.OVERRIDE_CREDIT_REASON,
             X_WAITLIST_DT                    => l_cur_sua_rec.waitlist_dt,
             X_MODE                           =>  'R' ,
             X_GS_VERSION_NUMBER              => l_cur_sua_rec.gs_version_number,
             X_ENR_METHOD_TYPE                => l_cur_sua_rec.enr_method_type,
             X_FAILED_UNIT_RULE               => l_cur_sua_rec.failed_unit_rule ,
             X_CART                           => l_cur_sua_rec.cart ,
             X_RSV_SEAT_EXT_ID                => l_cur_sua_rec.rsv_seat_ext_id,
             X_ORG_UNIT_CD                    => l_cur_sua_rec.org_unit_cd,
             X_SESSION_ID                     => l_cur_sua_rec.session_id,
             X_GRADING_SCHEMA_CODE            => l_cur_sua_rec.grading_schema_code,
             X_DEG_AUD_DETAIL_ID              => l_cur_sua_rec.deg_aud_detail_id,
             X_SUBTITLE                       => l_cur_sua_rec.subtitle,
             X_STUDENT_CAREER_TRANSCRIPT      => l_cur_sua_rec.student_career_transcript ,
             X_STUDENT_CAREER_STATISTICS      => l_cur_sua_rec.student_career_statistics,
             X_ATTRIBUTE_CATEGORY             => l_cur_sua_rec.attribute_category,
             X_ATTRIBUTE1                     => l_cur_sua_rec.attribute1,
             X_ATTRIBUTE2                     => l_cur_sua_rec.attribute2,
             X_ATTRIBUTE3                     => l_cur_sua_rec.attribute3,
             X_ATTRIBUTE4                     => l_cur_sua_rec.attribute4,
             X_ATTRIBUTE5                     => l_cur_sua_rec.attribute5,
             X_ATTRIBUTE6                     => l_cur_sua_rec.attribute6,
             X_ATTRIBUTE7                     => l_cur_sua_rec.attribute7,
             X_ATTRIBUTE8                     => l_cur_sua_rec.attribute8,
             X_ATTRIBUTE9                     => l_cur_sua_rec.attribute9,
             X_ATTRIBUTE10                    => l_cur_sua_rec.attribute10,
             X_ATTRIBUTE11                    => l_cur_sua_rec.attribute11,
             X_ATTRIBUTE12                    => l_cur_sua_rec.attribute12,
             X_ATTRIBUTE13                    => l_cur_sua_rec.attribute13,
             X_ATTRIBUTE14                    => l_cur_sua_rec.attribute14,
             X_ATTRIBUTE15                    => l_cur_sua_rec.attribute15,
             X_ATTRIBUTE16                    => l_cur_sua_rec.attribute16,
             X_ATTRIBUTE17                    => l_cur_sua_rec.attribute17,
             X_ATTRIBUTE18                    => l_cur_sua_rec.attribute18,
             X_ATTRIBUTE19                    => l_cur_sua_rec.attribute19,
             X_ATTRIBUTE20                    => l_cur_sua_rec.attribute20,
             X_WAITLIST_MANUAL_IND            => l_cur_sua_rec.waitlist_manual_ind,
             -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
             X_WLST_PRIORITY_WEIGHT_NUM       => l_cur_sua_rec.wlst_priority_weight_num,
             X_WLST_PREFERENCE_WEIGHT_NUM     => l_cur_sua_rec.wlst_preference_weight_num,
             -- CORE_INDICATOR_CODE added by ptandon 01-OCT-2003. Enh Bug# 3052432
             X_CORE_INDICATOR_CODE            => l_cur_sua_rec.core_indicator_code/*,
             X_UPD_AUDIT_FLAG                 => l_cur_sua_rec.UPD_AUDIT_FLAG ,
             X_SS_SOURCE_IND                  => l_cur_sua_rec.SS_SOURCE_IND    */
  );
  ELSE
     --

     Before_DML(
       p_action => 'DELETE',
       x_rowid => X_ROWID
       );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  DELETE FROM IGS_EN_SU_ATTEMPT_ALL
     WHERE ROWID = X_ROWID;

     IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

     --
     After_DML(
         p_action => 'DELETE',
         x_rowid => X_ROWID
         );
     --
  END IF;

END DELETE_ROW;
PROCEDURE Check_Constraints (
Column_Name     IN      VARCHAR2,
Column_Value    IN      VARCHAR2
)
AS
BEGIN
IF  column_name IS NULL THEN
    NULL;
ELSIF UPPER(Column_name) = 'ADMINISTRATIVE_UNIT_STATUS' THEN
    new_references.ADMINISTRATIVE_UNIT_STATUS := column_value;
 ELSIF UPPER(Column_name) = 'ALTERNATIVE_TITLE' THEN
    new_references.ALTERNATIVE_TITLE := column_value;
  ELSIF UPPER(Column_name) = 'CAL_TYPE' THEN
    new_references.CAL_TYPE := column_value;
  ELSIF UPPER(Column_name) = 'COURSE_CD' THEN
    new_references.COURSE_CD := column_value;
      ELSIF UPPER(Column_name) = 'EXAM_LOCATION_CD' THEN
    new_references.EXAM_LOCATION_CD := column_value;
      ELSIF UPPER(Column_name) = 'LOCATION_CD' THEN
    new_references.LOCATION_CD := column_value;
      ELSIF UPPER(Column_name) = 'NO_ASSESSMENT_IND' THEN
    new_references.NO_ASSESSMENT_IND := column_value;
      ELSIF UPPER(Column_name) = 'SUP_UNIT_CD' THEN
    new_references.SUP_UNIT_CD := column_value;
      ELSIF UPPER(Column_name) = 'UNIT_ATTEMPT_STATUS' THEN
    new_references.UNIT_ATTEMPT_STATUS := column_value;
      ELSIF UPPER(Column_name) = 'UNIT_CD' THEN
    new_references.UNIT_CD := column_value;
      ELSIF UPPER(Column_name) = 'UNIT_CLASS' THEN
    new_references.UNIT_CLASS := column_value;
      ELSIF UPPER(Column_name) = 'OVERRIDE_EFTSU' THEN
    new_references.OVERRIDE_EFTSU := igs_ge_number.to_num(column_value);
      ELSIF UPPER(Column_name) = 'OVERRIDE_ENROLLED_CP' THEN
    new_references.OVERRIDE_ENROLLED_CP := igs_ge_number.to_num(column_value);
      ELSIF UPPER(Column_name) = 'NO_ASSESSMENT_IND' THEN
    new_references.NO_ASSESSMENT_IND := column_value;
      ELSIF UPPER(Column_name) = 'OVERRIDE_ACHIEVABLE_CP' THEN
    new_references.OVERRIDE_ACHIEVABLE_CP := igs_ge_number.to_num(column_value);
      ELSIF UPPER(Column_name) = 'DCNT_REASON_CD' THEN
    new_references.DCNT_REASON_CD := column_value;
      END IF;
      IF UPPER(column_name) = 'ADMINISTRATIVE_UNIT_STATUS' OR
       column_name IS NULL THEN
     IF new_references.ADMINISTRATIVE_UNIT_STATUS <> UPPER(new_references.ADMINISTRATIVE_UNIT_STATUS) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'ALTERNATIVE_TITLE' OR
     column_name IS NULL THEN
     IF new_references.ALTERNATIVE_TITLE <> UPPER(new_references.ALTERNATIVE_TITLE) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
 IF UPPER(column_name) = 'CAL_TYPE' OR
     column_name IS NULL THEN
     IF new_references.CAL_TYPE <> UPPER(new_references.CAL_TYPE) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
 IF UPPER(column_name) = 'COURSE_CD' OR
     column_name IS NULL THEN
     IF new_references.COURSE_CD <> UPPER(new_references.COURSE_CD) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'EXAM_LOCATION_CD' OR
     column_name IS NULL THEN
     IF new_references.EXAM_LOCATION_CD <> UPPER(new_references.EXAM_LOCATION_CD) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'LOCATION_CD' OR
     column_name IS NULL THEN
     IF new_references.LOCATION_CD <> UPPER(new_references.LOCATION_CD) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'NO_ASSESSMENT_IND' OR
     column_name IS NULL THEN
     IF new_references.NO_ASSESSMENT_IND <> UPPER(new_references.NO_ASSESSMENT_IND) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'SUP_UNIT_CD' OR
     column_name IS NULL THEN
     IF new_references.SUP_UNIT_CD <> UPPER(new_references.SUP_UNIT_CD) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'UNIT_ATTEMPT_STATUS' OR
     column_name IS NULL THEN
     IF new_references.UNIT_ATTEMPT_STATUS <> UPPER(new_references.UNIT_ATTEMPT_STATUS) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'UNIT_CD' OR
     column_name IS NULL THEN
     IF new_references.UNIT_CD <> UPPER(new_references.UNIT_CD) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'UNIT_CLASS' OR
     column_name IS NULL THEN
     IF new_references.UNIT_CLASS <> UPPER(new_references.UNIT_CLASS) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'OVERRIDE_EFTSU' OR
     column_name IS NULL THEN
     IF new_references.OVERRIDE_EFTSU < 0 OR  new_references.OVERRIDE_EFTSU > 9999.999 THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'OVERRIDE_ENROLLED_CP' OR
     column_name IS NULL THEN
     IF new_references.OVERRIDE_ENROLLED_CP < 0 OR  new_references.OVERRIDE_ENROLLED_CP> 999.999 THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'NO_ASSESSMENT_IND' OR
     column_name IS NULL THEN
     IF new_references.NO_ASSESSMENT_IND NOT IN ('Y','N') THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'OVERRIDE_ACHIEVABLE_CP' OR
     column_name IS NULL THEN
     IF new_references.OVERRIDE_ACHIEVABLE_CP < 0 OR new_references.OVERRIDE_ACHIEVABLE_CP > 999.999 THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
                   END IF;
              END IF;
     IF UPPER(column_name) = 'DCNT_REASON_CD' OR
     column_name IS NULL THEN
     IF new_references.DCNT_REASON_CD <> UPPER(new_references.DCNT_REASON_CD) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;

END IF;
        END Check_Constraints;
-- Function for getting the UK
-- If the record exists for the parameters passed, then it returns TRUE
-- Else it returns false
--changed the UK columns as part of MUS build, # 2829262

 FUNCTION Get_Uk_For_Validation (
    x_unit_cd   IN  VARCHAR2,
    x_cal_type  IN  VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_location_cd  IN VARCHAR2,
    x_unit_class   IN VARCHAR2,
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) RETURN BOOLEAN AS
  CURSOR cur_sua IS
    SELECT ROWID
    FROM   IGS_EN_SU_ATTEMPT_ALL
    WHERE  unit_cd                 = x_unit_cd
    AND    cal_type                = x_cal_type
    AND    ci_sequence_number      = x_ci_sequence_number
    AND    location_cd             = x_location_cd
    AND    unit_class              = x_unit_class
    AND    person_id               = x_person_id
    AND    course_cd              = x_course_cd
    AND    version_number          = x_version_number
    AND    ((l_rowid IS NULL) OR (rowid <> l_rowid));
  lv_row_id     cur_sua%ROWTYPE;
 BEGIN
  /*IF x_administrative_priority IN (NULL,0) THEN
    RETURN (FALSE);
  ELSE*/
    OPEN cur_sua;
    FETCH cur_sua INTO lv_row_id;
    IF cur_sua%FOUND THEN
      CLOSE cur_sua;
      RETURN(TRUE);
    ELSE
      CLOSE cur_sua;
      RETURN(FALSE);
    END IF;

 END Get_Uk_For_Validation;

  PROCEDURE update_reserved_seat( p_action IN VARCHAR2)
  AS
  --
-- For Enhancement Bug 1832830
-- Local Procedure added to decrement actual_seat_enrolled once the
-- unit administrative status changes from ENROLLED/INVALID to DROPPED/DISCCONTIN
-- Called in After DML
--
-- 25-Jun-2002  pmarada  Added the code when the unit deleting from the su_attempt, decreasing the
--                       actual enrollment. bug 2423787

    CURSOR cur_igs_ps_rsv_ext (cp_rsv_ext_id igs_ps_rsv_ext.rsv_ext_id%TYPE)
    IS
    SELECT rsv.ROWID row_id, rsv.*
    FROM   igs_ps_rsv_ext rsv
    WHERE  rsv_ext_id = cp_rsv_ext_id;

    l_cur_igs_ps_rsv_ext  cur_igs_ps_rsv_ext%ROWTYPE;
    l_rsv_ext_id          igs_ps_rsv_ext.rsv_ext_id%TYPE;

  BEGIN
    IF ( p_action = 'UPDATE') THEN
      -- checking if the unit attempt status has been changed from ENROLLED/INVALID to DROPPED/DISCONTIN
      IF  (old_references.unit_attempt_status IN ('ENROLLED','INVALID')
           AND (new_references.unit_attempt_status IN ('DROPPED','DISCONTIN'))) THEN
        IF ( old_references.rsv_seat_ext_id =  new_references.rsv_seat_ext_id ) THEN
           l_rsv_ext_id := old_references.rsv_seat_ext_id;
        ELSE
           l_rsv_ext_id := new_references.rsv_seat_ext_id;
        END IF;

        OPEN  cur_igs_ps_rsv_ext(l_rsv_ext_id);
        FETCH cur_igs_ps_rsv_ext INTO l_cur_igs_ps_rsv_ext;
        CLOSE cur_igs_ps_rsv_ext;


        -- If the unit attempt status is changed then the actual seats enrolled column has to be decreased by one
        IF ((l_cur_igs_ps_rsv_ext.actual_seat_enrolled -1) >= 0) THEN
            igs_ps_rsv_ext_pkg.update_row( x_rowid                => l_cur_igs_ps_rsv_ext.row_id,
                                           x_rsv_ext_id           => l_cur_igs_ps_rsv_ext.rsv_ext_id,
                                           x_uoo_id               => l_cur_igs_ps_rsv_ext.uoo_id,
                                           x_priority_id          => l_cur_igs_ps_rsv_ext.priority_id,
                                           x_preference_id        => l_cur_igs_ps_rsv_ext.preference_id,
                                           x_rsv_level            => l_cur_igs_ps_rsv_ext.rsv_level,
                                           x_actual_seat_enrolled => l_cur_igs_ps_rsv_ext.actual_seat_enrolled -1,
                                           x_mode                 => 'R'
                                         );
        END IF;
      END IF;
    ELSIF p_action ='DELETE' THEN
    -- While deleting the su attempt record, if record exists in the reserve extension table with this reserve extension id decreasing the
    -- actual seat enrollment.
    -- Suppose user added the unit to cart and closed the browser or timeout, the actual enrollment is matching.
    -- while user login into SS, decrementing the actual seat enrollment., pmarada, bug 2423787

       IF old_references.rsv_seat_ext_id IS NOT NULL THEN
          OPEN  cur_igs_ps_rsv_ext(old_references.rsv_seat_ext_id);
          FETCH cur_igs_ps_rsv_ext INTO l_cur_igs_ps_rsv_ext;
          CLOSE cur_igs_ps_rsv_ext;
          IF ((l_cur_igs_ps_rsv_ext.actual_seat_enrolled -1) >= 0) THEN
             igs_ps_rsv_ext_pkg.update_row( x_rowid                => l_cur_igs_ps_rsv_ext.row_id,
                                           x_rsv_ext_id           => l_cur_igs_ps_rsv_ext.rsv_ext_id,
                                           x_uoo_id               => l_cur_igs_ps_rsv_ext.uoo_id,
                                           x_priority_id          => l_cur_igs_ps_rsv_ext.priority_id,
                                           x_preference_id        => l_cur_igs_ps_rsv_ext.preference_id,
                                           x_rsv_level            => l_cur_igs_ps_rsv_ext.rsv_level,
                                           x_actual_seat_enrolled => l_cur_igs_ps_rsv_ext.actual_seat_enrolled -1,
                                           x_mode                 => 'R'
                                         );
          END IF;
       END IF;
    END IF;
  END update_reserved_seat;

END Igs_En_Su_Attempt_Pkg;

/
