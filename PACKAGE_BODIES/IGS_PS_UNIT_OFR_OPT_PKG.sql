--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNIT_OFR_OPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNIT_OFR_OPT_PKG" as
/* $Header: IGSPI85B.pls 120.6 2006/05/08 00:15:34 bdeviset ship $ */
  /*************************************************************
  -- Bug # 1956374 Procedure assp_val_gs_cur_fut reference is changed

   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   vvutukur       05-Aug-2003     Enh#3045069.PSP Enh Build. Added new column not_multiple_section_flag.
   rgangara       07-May-2001     Added Ss
   (reverse chronological order - newest change first)
  ***************************************************************/
  l_rowid VARCHAR2(25);
  old_references IGS_PS_UNIT_OFR_OPT_ALL%RowType;
  new_references IGS_PS_UNIT_OFR_OPT_ALL%RowType;

  PROCEDURE beforerowdelete AS
    ------------------------------------------------------------------
    --Created by  : SMVK, Oracle India
    --Date created: 08-Jan-2002
    --
    --Purpose: Only planned unit section status are allowed for deletion
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------

  BEGIN
    -- Only planned unit status are allowed for deletion
    IF old_references.unit_section_status <> 'PLANNED' THEN
      fnd_message.set_name('IGS','IGS_PS_USEC_NO_DEL_ALLOWED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END beforerowdelete;


  PROCEDURE check_status_transition( p_n_uoo_id IN NUMBER,
                                     p_c_old_usec_sts IN VARCHAR2,
                                     p_c_new_usec_sts IN VARCHAR2) AS

    ------------------------------------------------------------------
    --Created by  : smvk, Oracle India
    --Date created: 30-Dec-2004
    --
    --Purpose: This procedure has the consolidated validation which deals with
    --         unit section status transition.
    --         Please refere the document Unit Section Status Tansistions.doc
    --         available at the following location in OFO to understand unit section
    --         status transition with respect to unit attempt statuses.
    -- Oracle Student System Development  >  IGS.L  >  PSP  >  Administration
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --sommukhe    10-AUG-2005     Bug #4417223, Made the status transition from OPEN to HOLD as a valid one.
    --smvk        30-Dec-2004     Bug #4089230, Created the procedure
    -------------------------------------------------------------------


     -- Cursor to check whether any unit attempt exists for the unit section with unit attempt status other than 'DISCONTIN' and 'DROPPED'.
     CURSOR c_discontin(cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT  unit_attempt_status
     FROM    igs_en_su_attempt_all
     WHERE   uoo_id= cp_n_uoo_id
     AND     unit_attempt_status NOT IN ('DISCONTIN', 'DROPPED')
     AND     ROWNUM <2 ;

     l_c_unit_attempt_status  igs_en_su_attempt_all.unit_attempt_status%TYPE;

     -- Cursor to check whether any unit attempt exists for the unit section.
     CURSOR c_exist (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT 1
     FROM   igs_en_su_attempt_all
     WHERE  uoo_id = cp_n_uoo_id
     AND    ROWNUM < 2 ;

     l_n_exist NUMBER;

     -- Cursor to check whether unit attempt exists for the unit section in unit attempt statuses
     -- other than 'DISCONTIN','DROPPED','COMPLETED','DUPLICATE'
     CURSOR c_enrollment_status(cp_n_uoo_id  igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT DISTINCT unit_attempt_status
     FROM   igs_en_su_attempt_all
     WHERE  uoo_id = cp_n_uoo_id
     AND    unit_attempt_status NOT IN ('DISCONTIN','DROPPED','COMPLETED','DUPLICATE');


     -- Cursor to get system unit status for the unit section.
     CURSOR c_unit_sts (cp_n_uoo_id IN IGS_PS_UNIT_OFR_OPT_ALL.UOO_ID%TYPE) IS
     SELECT a.s_unit_status
     FROM   igs_ps_unit_stat a,
            igs_ps_unit_ver_all b,
            igs_ps_unit_ofr_opt_all c
     WHERE  a.unit_status = b.unit_status
     AND    b.unit_cd = c.unit_cd
     AND    b.version_number = c.version_number
     AND    c.uoo_id = cp_n_uoo_id;

     l_c_unit_status  IGS_PS_UNIT_STAT.S_UNIT_STATUS%TYPE;

     -- Internal function to get the meaning for the given lookup_type and lookup_code.
     FUNCTION get_meaning(p_c_lookup_type IN VARCHAR2,
                          p_c_lookup_code IN VARCHAR2) RETURN VARCHAR2 IS

       CURSOR c_meaning (cp_c_lookup_type IN VARCHAR2,
                         cp_c_lookup_code IN VARCHAR2) IS
       SELECT meaning
       FROM   igs_lookup_values
       WHERE  lookup_type = cp_c_lookup_type
       AND    lookup_code = cp_c_lookup_code
       AND    enabled_flag = 'Y'
       AND    NVL(closed_ind,'N') = 'N'
       AND    SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE) AND NVL(END_DATE_ACTIVE,SYSDATE);

       l_c_meaning igs_lookup_values.meaning%TYPE;

     BEGIN
       OPEN c_meaning(p_c_lookup_type,p_c_lookup_code) ;
       FETCH c_meaning INTO l_c_meaning;
       CLOSE c_meaning;
       RETURN l_c_meaning;
     END get_meaning;

  BEGIN

    -- Any Other Statuses to 'PLANNED' is invalid - Overcome locking issue. (Status Codes 7,13,19,25,31,37)
    IF p_c_new_usec_sts = 'PLANNED' AND
       p_c_old_usec_sts <> 'PLANNED' THEN
       fnd_message.set_name ('IGS','IGS_PS_USEC_STATUS_TO_PLANNED');
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
    END IF;

    -- get the unit version system status
    l_c_unit_status := NULL;
    OPEN c_unit_sts (p_n_uoo_id);
    FETCH c_unit_sts INTO l_c_unit_status;
    CLOSE c_unit_sts;

   -- if unit version is planned then it can have unit section in status 'PLANNED' or 'NOT_OFFERED'.
    IF l_c_unit_status IS NOT NULL AND l_c_unit_status = 'PLANNED' AND
       p_c_new_usec_sts NOT IN ('PLANNED', 'NOT_OFFERED') THEN
       fnd_message.set_name ('IGS','IGS_PS_PLN_UNT_VER');
       fnd_message.set_token('STATUS',get_meaning('UNIT_SECTION_STATUS', p_c_new_usec_sts));
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
    END IF;

    -- Following Status transition are invalid.
    -- (2) PLANNED -> FULLWAITOK, (5) PLANNED -> CLOSED, (27) CANCELLED -> FULLWAITOK, (29) CANCELLED -> CLOSED
    IF p_c_old_usec_sts IN ('CANCELLED','PLANNED') AND
       p_c_new_usec_sts IN ('CLOSED', 'FULLWAITOK') THEN
          fnd_message.set_name('IGS','IGS_PS_INVALID_STATE_TRANS' );
          fnd_message.set_token('OLD_STATUS_DESC', get_meaning('UNIT_SECTION_STATUS',p_c_old_usec_sts));
          fnd_message.set_token('NEW_STATUS_DESC', get_meaning('UNIT_SECTION_STATUS',p_c_new_usec_sts));
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
    END IF;

    -- Can reach 'HOLD' status only from FULLWAITOK,OPEN and CLOSED.
    -- Following status transitions are valid
    -- (15) FULLOWAITOK -> HOLD , (34) CLOSED -> HOLD  ,(9) OPEN -> HOLD,
    -- Following status transitions are invalid
    -- (3) PLANNED -> HOLD, (28) CANCELLED -> HOLD, (40) NOT_OFFERED -> HOLD
    IF p_c_old_usec_sts NOT IN ('FULLWAITOK','CLOSED','OPEN') AND
       p_c_new_usec_sts = 'HOLD' THEN
          fnd_message.set_name('IGS','IGS_PS_INVALID_STATE_TRANS' );
          fnd_message.set_token('OLD_STATUS_DESC', get_meaning('UNIT_SECTION_STATUS',p_c_old_usec_sts));
          fnd_message.set_token('NEW_STATUS_DESC', get_meaning('UNIT_SECTION_STATUS',p_c_new_usec_sts));
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
    END IF;


    -- Can Cancel the unit section status if it does not have unit attempt or have unit attempt in unit attempt status 'DISCONTIN' and/or 'DROPPED'.
    -- (4) PLANNED -> CANCELLED, (10) OPEN -> CANCELLED, (16) FULLWAITOK -> CANCELLED, (22) HOLD -> CANCELLED, (35) CLOSED -> CANCELLED, (41) NOT_OFFERED -> CANCELLED
    IF p_c_new_usec_sts = 'CANCELLED' THEN
      OPEN c_discontin(p_n_uoo_id);
      FETCH c_discontin INTO l_c_unit_attempt_status;
      IF c_discontin%FOUND THEN
        CLOSE c_discontin;
        fnd_message.set_name('IGS','IGS_PS_USEC_STATUS_PLN_CNC');
        fnd_message.set_token('SUASTATUS',get_meaning('UNIT_ATTEMPT_STATUS',l_c_unit_attempt_status));
        -- IGS_PS_USEC_STATUS_CNC'); -- "Unit Section status cannot be changed to Cancelled as there exists student unit attempt which is not discontinued"
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      CLOSE c_discontin;
    END IF;

    -- Can reach 'NOT_OFFERED' status only when unit section does not have student attempt (irrespective of unit attempt status)
    -- (6) PLANNED -> NOT_OFFERED, (12) OPEN -> NOT_OFFERED, (18) FULLWAITOK -> NOT_OFFERED, (24) HOLD -> NOT_OFFERED, (30) CANCELLED -> NOT_OFFERED, (36) CLOSED -> NOT_OFFERED
    IF p_c_new_usec_sts = 'NOT_OFFERED' THEN
       OPEN c_exist(p_n_uoo_id);
       FETCH c_exist INTO l_n_exist;
       IF c_exist%FOUND THEN
          CLOSE c_exist;
          fnd_message.set_name ('IGS','IGS_PS_CNT_UPD_NOT_OFFERED');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        END IF;
       CLOSE c_exist;
    END IF;

    -- From NOT_OFFERED status only allowed status transition is 'OPEN', when the deactived calendar is activated.
    -- (38) NOT_OFFERED -> OPEN Valid transition
    -- (39) NOT_OFFERED -> FULLWAITOK,  (42) NOT_OFFERED -> CLOSED - Invalid transition
    IF p_c_old_usec_sts = 'NOT_OFFERED' AND
       p_c_new_usec_sts <> 'OPEN' THEN
         fnd_message.set_name('IGS','IGS_PS_INVALID_STATE_TRANS' );
         fnd_message.set_token('OLD_STATUS_DESC', get_meaning('UNIT_SECTION_STATUS',p_c_old_usec_sts));
         fnd_message.set_token('NEW_STATUS_DESC', get_meaning('UNIT_SECTION_STATUS',p_c_new_usec_sts));
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
    END IF;

  END check_status_transition;

  PROCEDURE beforerowupdate AS
    ------------------------------------------------------------------
    --Created by  : smvk, Oracle India
    --Date created: 03-Jan-2003
    --
    --Purpose: once the unit section status is changed to any other status
    --         from planned, then it cannot go back to planned.
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --smvk        30-Dec-2005     Bug #4089230, Modified the procedure to call check_status_transition
    --                            when the unit section is getting modified.
    --sarakshi    26-Jul-2004     Bug#3793607, added validation regarding the unit section status
    -------------------------------------------------------------------

  BEGIN
     -- if the unit section status is getting modified, calling the procedure check_status_transition
     -- to check whether the transition is valid.
     IF new_references.unit_section_status <> old_references.unit_section_status THEN
        check_status_transition( p_n_uoo_id       => new_references.uoo_id,
                                 p_c_old_usec_sts => old_references.unit_section_status,
                                 p_c_new_usec_sts => new_references.unit_section_status);
     END IF;

  END beforerowupdate;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_unit_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_cal_type IN VARCHAR2 ,
    x_ci_sequence_number IN NUMBER ,
    x_location_cd IN VARCHAR2 ,
    x_unit_class IN VARCHAR2 ,
    x_uoo_id IN NUMBER ,
    x_ivrs_available_ind IN VARCHAR2 ,
    x_call_number IN NUMBER ,
    x_unit_section_status IN VARCHAR2 ,
    x_unit_section_start_date IN DATE ,
    x_unit_section_end_date IN DATE ,
    x_enrollment_actual IN NUMBER ,
    x_waitlist_actual IN NUMBER ,
    x_offered_ind IN VARCHAR2 ,
    x_state_financial_aid IN VARCHAR2 ,
    x_grading_schema_prcdnce_ind IN VARCHAR2 ,
    x_federal_financial_aid IN VARCHAR2 ,
    x_unit_quota IN NUMBER ,
    x_unit_quota_reserved_places IN NUMBER ,
    x_institutional_financial_aid IN VARCHAR2 ,
    x_unit_contact IN NUMBER ,
    x_grading_schema_cd IN VARCHAR2 ,
    x_gs_version_number IN NUMBER ,
    x_owner_org_unit_cd                 IN     VARCHAR2 ,
    x_attendance_required_ind           IN     VARCHAR2 ,
    x_reserved_seating_allowed          IN     VARCHAR2 ,
    x_special_permission_ind            IN     VARCHAR2 ,
    x_ss_display_ind                    IN     VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER ,
    x_ss_enrol_ind IN VARCHAR2 ,
    x_dir_enrollment IN NUMBER ,
    x_enr_from_wlst  IN NUMBER ,
    x_inq_not_wlst  IN NUMBER ,
    x_rev_account_cd IN VARCHAR2 ,
    x_anon_unit_grading_ind IN VARCHAR2 ,
    x_anon_assess_grading_ind IN VARCHAR2 ,
    X_NON_STD_USEC_IND IN VARCHAR2 ,
    x_auditable_ind IN VARCHAR2,
    x_audit_permission_ind IN VARCHAR2,
    x_not_multiple_section_flag IN VARCHAR2,
    x_sup_uoo_id IN NUMBER ,
    x_relation_type VARCHAR2 ,
    x_default_enroll_flag VARCHAR2,
    x_abort_flag VARCHAR2

  ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By :2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
    vvutukur      05-Aug-2003     Enh#3045069.PSP Enh Build. Added column not_multiple_section_flag.
    shtatiko      06-NOV-2001     Added auditable_ind and audit_permission_ind as part of Bug# 2636716.
    rgangara      07-May-2001     Added ss_enrol_ind Col
   (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_UNIT_OFR_OPT_ALL
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
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.location_cd := x_location_cd;
    new_references.unit_class := x_unit_class;
    new_references.uoo_id := x_uoo_id;
    new_references.ivrs_available_ind := x_ivrs_available_ind;
    new_references.call_number := x_call_number;
    new_references.unit_section_status := x_unit_section_status;
    new_references.unit_section_start_date := x_unit_section_start_date;
    new_references.unit_section_end_date := x_unit_section_end_date;
    new_references.enrollment_actual := x_enrollment_actual;
    new_references.waitlist_actual := x_waitlist_actual;
    new_references.offered_ind := x_offered_ind;
    new_references.state_financial_aid := x_state_financial_aid;
    new_references.grading_schema_prcdnce_ind := x_grading_schema_prcdnce_ind;
    new_references.federal_financial_aid := x_federal_financial_aid;
    new_references.unit_quota := x_unit_quota;
    new_references.unit_quota_reserved_places := x_unit_quota_reserved_places;
    new_references.institutional_financial_aid := x_institutional_financial_aid;
    new_references.unit_contact := x_unit_contact;
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.gs_version_number := x_gs_version_number;
    new_references.owner_org_unit_cd := x_owner_org_unit_cd;
    new_references.attendance_required_ind := x_attendance_required_ind;
    new_references.reserved_seating_allowed := x_reserved_seating_allowed;
    new_references.special_permission_ind := x_special_permission_ind;
    new_references.ss_display_ind := x_ss_display_ind;
    new_references.org_id:=x_org_id;
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
    new_references.ss_enrol_ind := x_ss_enrol_ind;
    new_references.dir_enrollment:=x_dir_enrollment;
    new_references.enr_from_wlst:=x_enr_from_wlst;
    new_references.inq_not_wlst:=x_inq_not_wlst;
    new_references.rev_account_cd    := x_rev_account_cd;
    new_references.anon_unit_grading_ind := x_anon_unit_grading_ind;
    new_references.anon_assess_grading_ind := x_anon_assess_grading_ind;
    new_references.non_std_usec_ind := x_non_std_usec_ind;
    new_references.auditable_ind := x_auditable_ind;
    new_references.audit_permission_ind := x_audit_permission_ind;
    new_references.not_multiple_section_flag := x_not_multiple_section_flag;
    new_references.sup_uoo_id:= x_sup_uoo_id;
    new_references.relation_type:= x_relation_type;
    new_references.default_enroll_flag:= x_default_enroll_flag;
    new_references.abort_flag:= x_abort_flag;

  END Set_Column_Values;

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
        v_unit_cd                       IGS_PS_UNIT_OFR_OPT_ALL.unit_cd%TYPE;
        v_version_number                IGS_PS_UNIT_OFR_OPT_ALL.version_number%TYPE;
        v_cal_type              IGS_PS_UNIT_OFR_OPT_ALL.cal_type%TYPE;
        v_ci_sequence_number    IGS_PS_UNIT_OFR_OPT_ALL.ci_sequence_number%TYPE;
        v_message_name          Varchar2(30);
  BEGIN

        -- Validation : Unit Section Start Date is mandatory for Non Standard Unit Section
        -- Added as a part of Non Standard Unit Section Retention date build.
        IF (p_inserting OR p_updating) AND
            ( NVL(new_references.non_std_usec_ind,'N') = 'Y' AND
                  new_references.unit_section_start_date IS NULL
             )THEN
           fnd_message.set_name ('IGS','IGS_EN_OFFSET_DT_NULL');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
        END IF;

        -- Set variables.
        IF p_deleting THEN
                v_unit_cd := old_references.unit_cd;
                v_version_number := old_references.version_number;
                v_cal_type := old_references.cal_type;
                v_ci_sequence_number := old_references.ci_sequence_number;
        ELSE -- p_inserting or p_updating
                v_unit_cd := new_references.unit_cd;
                v_version_number := new_references.version_number;
                v_cal_type := new_references.cal_type;
                v_ci_sequence_number := new_references.ci_sequence_number;
        END IF;
        -- Validate the insert/update/delete.
        IF IGS_PS_VAL_UNIT.crsp_val_iud_uv_dtl (
                        v_unit_cd,
                        v_version_number,
v_message_name) = FALSE THEN
                Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END IF;
--      IF IGS_aS_VAL_uai.crsp_val_crs_ci (
--                      v_cal_type,
--                      v_ci_sequence_number,
--                      v_message_num) = FALSE THEN
--              raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(374));
--      END IF;
        IF p_inserting THEN
                -- Validate calendar type.
                -- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_UOo.crsp_val_uo_cal_type
                IF IGS_AS_VAL_UAI.crsp_val_uo_cal_type (
                                new_references.cal_type,
                                v_message_name) = FALSE THEN
                                Fnd_Message.Set_Name('IGS','IGS_PS_UOO_UAI_CANNOT_CREATE');
      IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
                -- Validate IGS_AD_LOCATION code.  IGS_AD_LOCATION code is not updateable.
                IF IGS_PS_VAL_UOo.crsp_val_loc_cd (
                                new_references.location_cd,
v_message_name) = FALSE THEN
                Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
                END IF;
                -- Validate IGS_PS_UNIT class.  IGS_PS_UNIT class is not updateable.
                IF IGS_PS_VAL_UOo.crsp_val_uoo_uc (
                                new_references.unit_class,
v_message_name) = FALSE THEN
                Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
                END IF;
        END IF;
        IF p_inserting OR p_updating THEN
                -- Validate grading schema.
                IF IGS_AS_VAL_GSG.assp_val_gs_cur_fut (
                                new_references.grading_schema_cd,
                                new_references.gs_version_number,
v_message_name) = FALSE THEN
                Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate IGS_PS_UNIT contact.
        IF new_references.unit_contact IS NOT NULL AND
                (NVL(old_references.unit_contact, 0) <> new_references.unit_contact) THEN
                IF igs_ad_val_acai.genp_val_staff_prsn (
                                new_references.unit_contact,
v_message_name) = FALSE THEN
                Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
                END IF;
        END IF;

        -- Validate that atleast one enrollment method is checked
        IF p_inserting or p_updating THEN
              IF NOT (new_references.ss_enrol_ind = 'Y' or new_references.ivrs_available_ind = 'Y') THEN
                   Fnd_Message.Set_Name('IGS','IGS_PS_ONE_UNIT_ENR_MTHD');
                   IGS_GE_MSG_STACK.ADD;
                   App_Exception.Raise_Exception;
              END IF;
        END IF;

       --Record cannot be updated if the values of location_cd and unit_class unit_class r different
       IF p_updating THEN
         IF new_references.location_cd<> old_references.location_cd OR
           new_references.unit_class<> old_references.unit_class THEN
             Fnd_message.Set_Name('IGS','IGS_PS_UPDN_LOCCD_UNTCLS');
             IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
        END IF;
      END IF;
  END BeforeRowInsertUpdateDelete1;

FUNCTION  check_call_number (p_teach_cal_type igs_ca_teach_to_load_v.teach_cal_type%TYPE,
                             p_teach_sequence_num igs_ca_teach_to_load_v.teach_ci_sequence_number%TYPE,
                             p_call_number  igs_ps_unit_ofr_opt_pe_v.call_number%TYPE,
                             p_rowid   VARCHAR2)
RETURN BOOLEAN AS
  /*************************************************************
   Created By : sarakshi
   Date Created By :9-Apr-2002
   Purpose :To create unique call number across a load calendar as a part of bug#1689872
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   --sarakshi      17-sep-2003     Bug#3060094,removed cursor cur_parent and changed the view igs_ps_unit_ofr_opt_pe_v
                                   to igs_pe_unit_ofr_opt_all in the cursor cur_detail.
   (reverse chronological order - newest change first)
  ***************************************************************/

CURSOR cur_teach_load(cp_cal_type        igs_ca_teach_to_load_v.teach_cal_type%TYPE,
                      cp_sequence_number igs_ca_teach_to_load_v.teach_ci_sequence_number%TYPE)  IS
SELECT load_cal_type,load_ci_sequence_number
FROM   igs_ca_teach_to_load_v
WHERE  teach_cal_type=cp_cal_type
AND    teach_ci_sequence_number=cp_sequence_number;

CURSOR  cur_load_teach(cp_cal_type         igs_ca_load_to_teach_v.load_cal_type%TYPE,
                       cp_sequence_number  igs_ca_load_to_teach_v.load_ci_sequence_number%TYPE) IS
SELECT  teach_cal_type,teach_ci_sequence_number
FROM    igs_ca_load_to_teach_v
WHERE   load_cal_type=cp_cal_type
AND     load_ci_sequence_number=cp_sequence_number;

CURSOR  cur_detail (cp_cal_type         igs_ps_unit_ofr_opt_all.cal_type%TYPE,
                    cp_sequence_number  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE) IS
SELECT  'X'
FROM    igs_ps_unit_ofr_opt_all
WHERE   cal_type=cp_cal_type
AND     ci_sequence_number=cp_sequence_number
AND     call_number=p_call_number
AND    (rowid <> p_rowid OR (p_rowid IS NULL))
AND     ROWNUM = 1;

l_c_var  VARCHAR2(1);

BEGIN
  FOR l_cur_teach_load IN cur_teach_load(p_teach_cal_type,p_teach_sequence_num) LOOP
    FOR l_cur_load_teach IN cur_load_teach(l_cur_teach_load.load_cal_type,l_cur_teach_load.load_ci_sequence_number) LOOP
        OPEN cur_detail(l_cur_load_teach.teach_cal_type,l_cur_load_teach.teach_ci_sequence_number);
        FETCH cur_detail INTO l_c_var;
        IF cur_detail%FOUND THEN
          CLOSE cur_detail;
          RETURN FALSE;
        END IF;
        CLOSE cur_detail;
    END LOOP;
  END LOOP;
  --call number is unique
  RETURN TRUE;

END check_call_number;

PROCEDURE Check_Uniqueness AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   sarakshi        09-Apr-2002     Removed the unique key igs_ps_unit_ofr_opt_all_uk2, hence removing the
                                   call to the get_uk2_for_validation , bug#1689872
   (reverse chronological order - newest change first)
  ***************************************************************/
BEGIN

        IF Get_UK_For_Validation (new_references.uoo_id) THEN
                        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
        END IF;

END Check_Uniqueness;

PROCEDURE Check_Constraints(
                                Column_Name     IN      VARCHAR2   ,
                                Column_Value    IN      VARCHAR2   )
AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   vvutukur        05-Aug-2003     Enh#3045069.PSP Enh Build. Added validation
                                   to restrict values of new column not_multiple_section_flag to either 'Y' or 'N'.
   shtatiko        25-NOV-2002     Changed the validating condition of unit_quota and ci_sequence_number
                                   (Bug# 2649028, Legacy Data Import)
   (reverse chronological order - newest change first)
  ***************************************************************/
BEGIN

        IF Column_Name IS NULL Then
                NULL;
        ELSIF Upper(Column_Name)='CAL_TYPE' Then
                New_References.Cal_Type := Column_Value;
        ELSIF Upper(Column_Name)='GRADING_SCHEMA_CD' Then
                New_References.Grading_Schema_Cd := Column_Value;
        ELSIF Upper(Column_Name)='GRADING_SCHEMA_PRCDNCE_IND' Then
                New_References.grading_schema_prcdnce_ind := Column_Value;
        ELSIF Upper(Column_Name)='IVRS_AVAILABLE_IND' Then
                New_References.ivrs_available_ind := Column_Value;
        ELSIF Upper(Column_Name)='LOCATION_CD' Then
                New_References.Location_Cd := Column_Value;
        ELSIF Upper(Column_Name)='OFFERED_IND' Then
                New_References.Offered_ind := Column_Value;
        ELSIF Upper(Column_Name)='UNIT_CD' Then
                New_References.Unit_Cd := Column_Value;
        ELSIF Upper(Column_Name)='UNIT_CLASS' Then
                New_References.Unit_Class := Column_Value;
        ELSIF Upper(Column_Name)='UNIT_QUOTA' Then
                New_References.Unit_Quota := igs_ge_number.to_num(Column_Value);
        ELSIF Upper(Column_Name)='CI_SEQUENCE_NUMBER' Then
                New_References.Ci_Sequence_Number := igs_ge_number.to_num(Column_Value);
        ELSIF Upper(Column_Name)='SS_ENROL_IND' THEN
                New_References.Ss_enrol_ind := Column_value;
        ELSIF Upper(Column_Name)= 'NON_STD_USEC_IND' THEN
                New_References.Non_std_usec_ind := Column_value;
        ELSIF Upper(Column_Name)= 'AUDITABLE_IND' THEN
                New_References.auditable_ind := Column_value;
        ELSIF Upper(Column_Name)= 'AUDIT_PERMISSION_IND' THEN
                New_References.audit_permission_ind := Column_value;
        ELSIF UPPER(column_name)= 'NOT_MULTIPLE_SECTION_FLAG' THEN
                new_references.not_multiple_section_flag := column_value;
        ELSIF UPPER(column_name)= 'DEFAULT_ENROLL_FLAG' THEN
                new_references.default_enroll_flag:= column_value;
        ELSIF UPPER(column_name)= 'ABORT_FLAG' THEN
                new_references.abort_flag:= column_value;
        END IF;


        IF Upper(Column_Name)='CAL_TYPE' OR Column_Name IS NULL Then
                IF New_References.Cal_Type <> UPPER(New_References.Cal_Type) Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='GRADING_SCHEMA_CD' OR Column_Name IS NULL Then
                IF New_References.Grading_Schema_Cd <> UPPER(New_References.Grading_Schema_Cd) Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='GRADING_SCHEMA_PRCDNCE_IND' OR Column_Name IS NULL Then

                IF New_References.grading_schema_prcdnce_ind NOT IN ( 'Y' , 'N' ) Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;

        END IF;

        IF Upper(Column_Name)='IVRS_AVAILABLE_IND' OR Column_Name IS NULL Then

                IF New_References.ivrs_available_ind NOT IN ( 'Y' , 'N' ) Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;

        END IF;

        IF Upper(Column_Name)='OFFERED_IND' OR Column_Name IS NULL Then

                IF New_References.Offered_ind NOT IN ( 'Y' , 'N' ) Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;

        END IF;

        IF Upper(Column_Name)='LOCATION_CD' OR Column_Name IS NULL Then
                IF New_References.Location_Cd <> UPPER(New_References.Location_Cd) Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='UNIT_CD' OR Column_Name IS NULL Then
                IF New_References.Unit_Cd <> UPPER(New_References.Unit_CD) Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='UNIT_CLASS' OR Column_Name IS NULL Then
                IF New_References.Unit_Class <> UPPER(New_References.Unit_Class) Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='UNIT_QUOTA' OR Column_Name IS NULL Then
                IF New_References.Unit_Quota < 0 OR New_References.Unit_Quota > 999999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF Upper(Column_Name)='CI_SEQUENCE_NUMBER' OR Column_Name IS NULL Then
                IF New_References.Ci_sequence_Number < 1 OR New_References.Ci_sequence_Number > 999999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;


        -- Validate that atleast one enrollment method is checked
        IF (Upper(Column_Name)='SS_ENROL_IND' OR Upper(Column_Name)='IVRS_AVAILABLE_IND') OR Column_Name is NULL THEN
              IF NOT (new_references.ss_enrol_ind = 'Y' OR new_references.ivrs_available_ind = 'Y') THEN
                   Fnd_Message.Set_Name('IGS','IGS_PS_ONE_UNIT_ENR_MTHD');
                   IGS_GE_MSG_STACK.ADD;
                   App_Exception.Raise_Exception;
              END IF;
        END IF;

        -- Added by Prem Raj for the build of PSCR017 bug #2224366
        -- To check that NON_STD_USEC_IND should have a value in 'Y' or 'N'
        IF Upper(Column_Name)= 'NON_STD_USEC_IND' OR Column_Name IS NULL Then
          IF New_References.Non_std_usec_ind NOT IN ( 'Y' , 'N' ) Then
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
          END IF;
        END IF;

        --Added by shtatiko as part of Bug# 2636716, EN Integration
        IF Upper(Column_Name)= 'AUDITABLE_IND' OR Column_Name IS NULL Then
          IF New_References.auditable_ind NOT IN ( 'Y' , 'N' ) Then
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
          END IF;
        END IF;

        IF Upper(Column_Name)= 'AUDIT_PERMISSION_IND' OR Column_Name IS NULL Then
          IF New_References.audit_permission_ind NOT IN ( 'Y' , 'N' ) Then
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
          END IF;
        END IF;

        IF Upper(Column_Name)='UNIT_QUOTA_RESERVED_PLACES' OR Column_Name IS NULL Then
                IF New_References.unit_quota_reserved_places < 0 OR New_References.unit_quota_reserved_places > 999999 Then
                                Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                END IF;
        END IF;

        IF UPPER(column_name)= 'NOT_MULTIPLE_SECTION_FLAG' OR column_name IS NULL THEN
          IF new_references.not_multiple_section_flag NOT IN ('Y','N') THEN
            fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
          END IF;
        END IF;

        IF UPPER(column_name)= 'DEFAULT_ENROLL_FLAG' OR column_name IS NULL THEN
          IF new_references.default_enroll_flag NOT IN ('Y','N') THEN
            fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
          END IF;
        END IF;

	IF UPPER(column_name)= 'ABORT_FLAG' OR column_name IS NULL THEN
          IF new_references.abort_flag NOT IN ('Y','N') THEN
            fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
          END IF;
        END IF;

  END Check_Constraints;


  PROCEDURE Check_Parent_Existance AS
  CURSOR c_check_hz_exists IS
  SELECT 'x' FROM hz_parties hp,igs_pe_hz_parties pe
  WHERE hp.party_id = pe.party_id
  AND pe.oss_org_unit_cd =new_references.owner_org_unit_cd;
  cur_rec_hz_exists c_check_hz_exists%ROWTYPE;
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
  sommukhe      12-AUG-2005	  Bug#4377818,changed the cursor c_check_hz_exists, included table igs_pe_hz_parties in
				  FROM clause and modified the WHERE clause by joining HZ_PARTIES and IGS_PE_HZ_PARTIES
				  using party_id and org unit being compared with oss_org_unit_cd of IGS_PE_HZ_PARTIES.
  smadathi       25-MAY-2001      foreign key references to IGS_PS_USEC_RPT_FMLY removed as per new DLD
   (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.gs_version_number = new_references.gs_version_number)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.gs_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AS_GRD_SCHEMA_PKG.Get_PK_For_Validation (
        new_references.grading_schema_cd,
        new_references.gs_version_number) THEN
                                  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                          IGS_GE_MSG_STACK.ADD;
                          App_Exception.Raise_Exception;
        END IF;

    END IF;

    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.location_cd, 'N') THEN
                                    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
        END IF;

    END IF;

    IF (((old_references.unit_contact = new_references.unit_contact)) OR
        ((new_references.unit_contact IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.unit_contact) THEN
                                    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
        END IF;

    END IF;

    IF (((old_references.unit_class = new_references.unit_class)) OR
        ((new_references.unit_class IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AS_UNIT_CLASS_PKG.Get_PK_For_Validation (
        new_references.unit_class) THEN
                                    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
        END IF;

    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
          IF NOT IGS_PS_UNIT_OFR_PAT_PKG.Get_PK_For_Validation (
        new_references.unit_cd,
        new_references.version_number,
        new_references.cal_type,
        new_references.ci_sequence_number)  THEN
                                    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
        END IF;

    END IF;


    IF (((old_references.owner_org_unit_cd = new_references.owner_org_unit_cd)) OR
        ((new_references.owner_org_unit_cd IS NULL))) THEN
      NULL;
    ELSE
        OPEN c_check_hz_exists;
        FETCH c_check_hz_exists INTO cur_rec_hz_exists;
        IF c_check_hz_exists%NOTFOUND THEN
          CLOSE c_check_hz_exists;
          fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        ELSE
              CLOSE c_check_hz_exists;
        END IF;
     END IF;

    IF ((old_references.rev_account_cd = new_references.rev_account_cd) OR
         (new_references.rev_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.rev_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    --check the existance of sup_uoo_id as a uoo_id
    IF ((old_references.sup_uoo_id = new_references.sup_uoo_id) OR
         (new_references.sup_uoo_id IS NULL)) THEN
      NULL;
    ELSE
      IF NOT Get_UK_For_Validation (
               new_references.sup_uoo_id
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION get_call_number ( p_c_cal_type IN igs_ca_type.cal_type%TYPE,
                             p_n_seq_num IN igs_ca_inst_all.sequence_number%TYPE ) RETURN NUMBER AS

     -- Cursor to lock all the load calendars for the given teaching calendar instance
     -- in the table igs_ps_usec_cal_nums
     CURSOR c_loc_cal_num (cp_c_cal_type IN VARCHAR2,
                           cp_n_seq_num IN NUMBER) IS
     SELECT call_number
     FROM igs_ps_usec_cal_nums a,
          igs_ca_teach_to_load_v b
     WHERE a.calender_type = b.load_cal_type AND
           a.ci_sequence_number = b.load_ci_sequence_number AND
           b.teach_cal_type = cp_c_cal_type AND
           b.teach_ci_sequence_number = cp_n_seq_num
     FOR UPDATE OF call_number;

     -- Cursor to get the maximum call number across different load calendars for the given teaching calendar instance
     CURSOR c_max_cal_num (cp_c_cal_type IN VARCHAR2,
                           cp_n_seq_num IN NUMBER) IS
     SELECT MAX(call_number)
     FROM igs_ps_usec_cal_nums a,
          igs_ca_teach_to_load_v b
     WHERE a.calender_type = b.load_cal_type AND
           a.ci_sequence_number = b.load_ci_sequence_number AND
         b.teach_cal_type = cp_c_cal_type AND
         b.teach_ci_sequence_number = cp_n_seq_num;

     -- Cursor to get the information of igs_ps_usec_cal_nums record, for updating the record
     CURSOR c_call_number ( cp_cal_type igs_ca_type.cal_type%TYPE,
                            cp_seq_num igs_ca_inst_all.sequence_number%TYPE ) IS
     SELECT rowid ROW_ID, unit_section_call_number_id call_id
     FROM   igs_ps_usec_cal_nums
     WHERE  calender_type = cp_cal_type AND
           ci_sequence_number = cp_seq_num;

     rec_call_number c_call_number%ROWTYPE;

     -- Cursor to get load claendar instance information for creating new records in igs_ps_usec_cal_nums
     CURSOR c_teach_to_load ( cp_cal_type igs_ca_type.cal_type%TYPE,
                              cp_seq_num igs_ca_inst_all.sequence_number%TYPE ) IS
     SELECT load_cal_type lcal_type, load_ci_sequence_number lseq_num
     FROM igs_ca_teach_to_load_v
     WHERE
     teach_cal_type = cp_cal_type AND
     teach_ci_sequence_number = cp_seq_num;

     -- Gets the maximum call number
     l_n_max_cal_num igs_ps_usec_cal_nums.call_number%TYPE;
     l_c_rowid ROWID;
     l_n_usc_number_id igs_ps_usec_cal_nums.unit_section_call_number_id%TYPE;

  BEGIN

    SAVEPOINT  IGS_PS_USEC_CAL_NUMS;

    OPEN c_loc_cal_num (p_c_cal_type,p_n_seq_num);
    FETCH c_loc_cal_num INTO l_n_max_cal_num;
    CLOSE c_loc_cal_num;

    l_n_max_cal_num := NULL;

    OPEN c_max_cal_num (p_c_cal_type,p_n_seq_num);
    FETCH c_max_cal_num INTO l_n_max_cal_num;
    CLOSE c_max_cal_num;

    l_n_max_cal_num := NVL(l_n_max_cal_num,0);
    l_n_max_cal_num := l_n_max_cal_num + 1;

    FOR rec_teach_to_load IN c_teach_to_load(p_c_cal_type,p_n_seq_num) LOOP
        OPEN c_call_number (rec_teach_to_load.lcal_type,rec_teach_to_load.lseq_num);
        FETCH c_call_number INTO rec_call_number;
        IF c_call_number%FOUND THEN
           igs_ps_usec_cal_nums_pkg.update_row(  x_mode                        => 'R',
                                                 x_rowid                       => rec_call_number.row_id,
                                                 x_unit_section_call_number_id => rec_call_number.call_id,
                                                 x_calender_type               => rec_teach_to_load.lcal_type,
                                                 x_ci_sequence_number          => rec_teach_to_load.lseq_num,
                                                 x_call_number                 => l_n_max_cal_num);

        ELSE
           l_c_rowid := NULL;
           l_n_usc_number_id := NULL;
           igs_ps_usec_cal_nums_pkg.insert_row ( x_rowid                       => l_c_rowid,
                                                 x_unit_section_call_number_id => l_n_usc_number_id,
                                                 x_calender_type               => rec_teach_to_load.lcal_type,
                                                 x_ci_sequence_number          => rec_teach_to_load.lseq_num,
                                                 x_call_number                 => l_n_max_cal_num,
                                                 x_mode                        => 'R' );

        END IF;
        CLOSE c_call_number;
    END LOOP;
    RETURN l_n_max_cal_num;

  EXCEPTION
     WHEN OTHERS THEN
        ROLLBACK TO IGS_PS_USEC_CAL_NUMS;
        RETURN -1;
  END get_call_number;

  PROCEDURE get_ufk_for_validation (
    x_uoo_id IN NUMBER
    ) AS
  /*************************************************************
   Created By : sarakshi
   Date Created By : 30-oct-2003
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
    SELECT   rowid
    FROM     IGS_PS_UNIT_OFR_OPT_ALL
    WHERE    sup_uoo_id=x_uoo_id;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
     Fnd_Message.Set_Name ('IGS', 'IGS_PS_UOO_UOO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END get_ufk_for_validation;

  PROCEDURE Check_Child_Existance AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
  svuppala   15-JUL-2005    Enh 3442712 - Called igs_fi_invln_int_pkg.get_fk_igs_ps_unit_ofr_opt_all
  sarakshi   27-Jul-2004  Bug#3795883, shifted Uk related child to Check_UK_Child_Existance procedure.
  sarakshi     15-sep-2003  Enh#2520994,added a call to igs_ps_usec_pri_pkg.get_ufk_igs_ps_unit_ofr_opt
  vvutukur    10-Jun-2003  Enh#2831572.Financial Accounting Build.Added call to igs_fi_ftci_accts_pkg.get_ufk_igs_ps_unit_ofr_opt.
   smvk        08-May-2003        Bug #2532094. Added child table call igs_ps_usec_x_grpmem_pkg.get_ufk_igs_ps_unit_ofr_opt.
   sarakshi    28-Oct-2002        Enh#2613933,added child table IGS_PS_USO_CLAS_MEET existance of record.
   smadathi    02-May-2002        Bug 2261649. This procedure contains reference to table IGS_PS_USEC_CHARGE.
                                  The table became obsolete. The references to the same have been removed.
                                  Removed IGS_PS_USEC_CHARGE_PKG.GET_UFK_IGS_PS_UNIT_OFR_OPT removed.
   smadathi        03-JUL-2001    Added IGS_EN_ELGB_OVR_STEP_PKG.GET_UFK_IGS_PS_UNIT_OFR_OPT . This is as per
                                  enhancement bug no. 1830175
   svenkata     02-06-2003       Modified to remove references to TBH of pkg IGS_EN_ELGB_OVR_STEP_PKG. Instead , added
                                 references to package IGS_EN_ELGB_OVR_UOO.Bug #2829272
   (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN

    IGS_AD_PS_APLINSTUNT_PKG.GET_FK_IGS_PS_UNIT_OFR_OPT (
      old_references.unit_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.ci_sequence_number,
      old_references.location_cd,
      old_references.unit_class
      );

    IGS_EN_SU_ATTEMPT_PKG.GET_FK_IGS_PS_UNIT_OFR_OPT (
      old_references.unit_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.ci_sequence_number,
      old_references.location_cd,
      old_references.unit_class
      );

    IGS_PS_TCH_RESP_OVRD_PKG.GET_FK_IGS_PS_UNIT_OFR_OPT (
      old_references.unit_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.ci_sequence_number,
      old_references.location_cd,
      old_references.unit_class
      );

    IGS_PS_TCH_RSOV_HIST_PKG.GET_FK_IGS_PS_UNIT_OFR_OPT (
      old_references.unit_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.ci_sequence_number,
      old_references.location_cd,
      old_references.unit_class
      );

    IGS_PS_UNT_OFR_OPT_N_PKG.GET_FK_IGS_PS_UNIT_OFR_OPT (
      old_references.unit_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.ci_sequence_number,
      old_references.location_cd,
      old_references.unit_class
      );

    igs_fi_invln_int_pkg.get_fk_igs_ps_unit_ofr_opt_all (
           old_references.uoo_id
         );

  END Check_Child_Existance;


  PROCEDURE Check_UK_Child_Existance AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
   sarakshi    23-sep-2004  Bug#3888835, added child validation for igs_ps_nsus_rtn_pkg.
   sarakshi    27-Jul-2004  Bug#3795883, shifted Uk related child to Check_UK_Child_Existance procedure and added few new entries.
   vvutukur    04-Aug-2003  Enh#3045069.PSP Enh Build. Removed call
                            to igs_ps_usec_rpt_cond_pkg.get_ufk_igs_ps_unit_ofr_opt.
  ***************************************************************/
  BEGIN

      igs_en_nstd_usec_dl_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      igs_en_usec_disc_dl_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      igs_en_elgb_ovr_uoo_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id );

      igs_en_su_attempt_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_ps_tch_resp_ovrd_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_ps_unt_ofr_opt_n_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_ps_usec_grd_schm_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      igs_ps_usec_occurs_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id );

      igs_ps_usec_lim_wlst_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      igs_ps_usec_cps_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      igs_ps_usec_spnsrshp_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      igs_ps_usec_tch_resp_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      igs_ps_usec_as_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      igs_ps_usec_ref_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      igs_ps_us_exam_meet_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      igs_ps_us_unsched_cl_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      igs_ps_usec_category_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_ps_rsv_usec_pri_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_en_spl_perm_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_ps_usec_accts_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_ps_uso_clas_meet_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_ps_usec_x_grpmem_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      igs_ps_usec_wlst_pri_pkg.get_ufk_igs_ps_unit_ofr_opt (old_references.uoo_id);

      --To prevent deletion of unit section which is superior
      get_ufk_for_validation(old_references.uoo_id);

      --Bug 3199686
      --Created IGS_AS_USEC_SESSNS table
      igs_as_usec_sessns_pkg.get_fk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      --To prevent deletion of unit section if unit section special fees exists.
      igs_ps_usec_sp_fees_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_ps_rsv_ext_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_ps_usec_ru_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_as_us_ai_group_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_fi_ftci_accts_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

      igs_ps_nsus_rtn_pkg.get_ufk_igs_ps_unit_ofr_opt(old_references.uoo_id);

  END Check_UK_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_location_cd IN VARCHAR2,
    x_unit_class IN VARCHAR2
    ) RETURN BOOLEAN AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
  smvk           08-Jan-2003      Bug # 2735076. Locking the record only when the status of the unit section is 'PLANNED'.
   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_OFR_OPT_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      location_cd = x_location_cd
      AND      unit_class = x_unit_class
      FOR UPDATE NOWAIT;

    CURSOR cur_status IS
      SELECT   unit_section_status
      FROM     IGS_PS_UNIT_OFR_OPT_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      location_cd = x_location_cd
      AND      unit_class = x_unit_class;

    lv_rowid cur_rowid%RowType;
    l_c_usec_status igs_ps_unit_ofr_opt_all.unit_section_status%TYPE;

  BEGIN

    OPEN cur_status ;
    FETCH cur_status INTO l_c_usec_status;
    IF cur_status%FOUND THEN                -- whether the record exists
       CLOSE cur_status;
       IF l_c_usec_status = 'PLANNED' THEN  -- for planned unit section
         OPEN cur_rowid;
         FETCH cur_rowid INTO lv_rowid;
         IF (cur_rowid%FOUND) THEN
           CLOSE cur_rowid;
           RETURN(TRUE);
         ELSE
           CLOSE cur_rowid;
           RETURN(FALSE);
         END IF;
       ELSE                                 -- for other unit section statuses
         RETURN(TRUE);
       END IF;
    ELSE                                    -- Unit section record does n't exists.
       CLOSE cur_status;
       RETURN(FALSE);
    END IF;

  END Get_PK_For_Validation;

  FUNCTION Get_UK_For_Validation (
    x_uoo_id IN NUMBER
    ) RETURN BOOLEAN AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   smvk           08-Jan-2003      Bug # 2735076. Locking the record only when the status of the unit section is 'PLANNED'.
   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_OFR_OPT_ALL
      WHERE    uoo_id = x_uoo_id
      AND      (l_rowid IS NULL OR rowid <> l_rowid)
      FOR UPDATE NOWAIT;

    CURSOR cur_status IS
      SELECT   unit_section_status
      FROM     IGS_PS_UNIT_OFR_OPT_ALL
      WHERE    uoo_id = x_uoo_id
      AND      (l_rowid IS NULL OR rowid <> l_rowid);

    lv_rowid cur_rowid%RowType;
    l_c_usec_status igs_ps_unit_ofr_opt_all.unit_section_status%TYPE;

  BEGIN
    OPEN cur_status ;
    FETCH cur_status INTO l_c_usec_status;
    IF cur_status%FOUND THEN                -- whether the record exists
       CLOSE cur_status ;
       IF l_c_usec_status ='PLANNED' THEN   -- for planned unit section
         OPEN cur_rowid;
         FETCH cur_rowid INTO lv_rowid;
         IF (cur_rowid%FOUND) THEN
           CLOSE cur_rowid;
           RETURN(TRUE);
         ELSE
           CLOSE cur_rowid;
           RETURN(FALSE);
         END IF;
       ELSE                                 -- for other unit section statuses
         RETURN TRUE;
       END IF;
    ELSE                                    -- Unit section record does n't exists.
       CLOSE cur_status ;
       RETURN FALSE;
    END IF;

  END Get_UK_For_Validation;


  PROCEDURE GET_FK_IGS_AS_GRD_SCHEMA (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_OFR_OPT_ALL
      WHERE    grading_schema_cd = x_grading_schema_cd
      AND      gs_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UOO_GS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AS_GRD_SCHEMA;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_OFR_OPT_ALL
      WHERE    location_cd = x_location_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UOO_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN VARCHAR2
    ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_OFR_OPT_ALL
      WHERE    unit_contact = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UOO_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_PS_UNIT_OFR_PAT (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_OFR_OPT_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UOO_UOP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_OFR_PAT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_unit_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_cal_type IN VARCHAR2 ,
    x_ci_sequence_number IN NUMBER ,
    x_location_cd IN VARCHAR2 ,
    x_unit_class IN VARCHAR2 ,
    x_uoo_id IN NUMBER ,
    x_ivrs_available_ind IN VARCHAR2 ,
    x_call_number IN NUMBER ,
    x_unit_section_status IN VARCHAR2 ,
    x_unit_section_start_date IN DATE ,
    x_unit_section_end_date IN DATE ,
    x_enrollment_actual IN NUMBER ,
    x_waitlist_actual IN NUMBER ,
    x_offered_ind IN VARCHAR2 ,
    x_state_financial_aid IN VARCHAR2 ,
    x_grading_schema_prcdnce_ind IN VARCHAR2 ,
    x_federal_financial_aid IN VARCHAR2 ,
    x_unit_quota IN NUMBER ,
    x_unit_quota_reserved_places IN NUMBER ,
    x_institutional_financial_aid IN VARCHAR2 ,
    x_unit_contact IN NUMBER ,
    x_grading_schema_cd IN VARCHAR2 ,
    x_gs_version_number IN NUMBER ,
    x_owner_org_unit_cd                 IN     VARCHAR2 ,
    x_attendance_required_ind           IN     VARCHAR2 ,
    x_reserved_seating_allowed          IN     VARCHAR2 ,
    x_special_permission_ind            IN     VARCHAR2 ,
    x_ss_display_ind                    IN     VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER ,
    x_ss_enrol_ind IN VARCHAR2 ,
    x_dir_enrollment IN NUMBER ,
    x_enr_from_wlst  IN NUMBER ,
    x_inq_not_wlst  IN NUMBER ,
    x_rev_account_cd IN VARCHAR2 ,
    x_anon_unit_grading_ind IN VARCHAR2 ,
    x_anon_assess_grading_ind IN VARCHAR2 ,
    X_NON_STD_USEC_IND IN VARCHAR2,
    x_auditable_ind IN VARCHAR2,
    x_audit_permission_ind IN VARCHAR2,
    x_not_multiple_section_flag IN VARCHAR2,
    x_sup_uoo_id IN NUMBER ,
    x_relation_type VARCHAR2 ,
    x_default_enroll_flag VARCHAR2,
    x_abort_flag VARCHAR2
  ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   smvk             21-Jul-2004     Bug # 3765800. Adding billing_hrs.
   sarakshi         12-Apr-2004     Bug#3555871, call_number function is only called for profile option of USER_DEFINED
   vvutukur         05-Aug-2003     Enh#3045069.PSP Enh Build. Added column not_multiple_section_flag.
   shtatiko         06-NOV-2002     bug# 2616716, Added auditable_ind and audit_permission_ind columns
   sarakshi         18-Sep-2002     bug#2563596, added check for cal type associated to a load cal
   msrinivi         17-Aug-2001     Added new col rev_account_cd bug 1882122
   rgangara         07-May-2001     Added ss_enrol_ind column
   (reverse chronological order - newest change first)
  ***************************************************************/
        --Bug#2563596,Check that teach calendar is associated to a load calendar
        CURSOR cur_teach_to_load(cp_cal_type        igs_ca_teach_to_load_v.teach_cal_type%TYPE,
                                 cp_sequence_number igs_ca_teach_to_load_v.teach_ci_sequence_number%TYPE)
        IS
        SELECT load_cal_type,load_ci_sequence_number
        FROM   igs_ca_teach_to_load_v
        WHERE  teach_cal_type=cp_cal_type
        AND    teach_ci_sequence_number=cp_sequence_number;
        l_cur_teach_to_load   cur_teach_to_load%ROWTYPE;

        CURSOR c_audit_credit (cp_c_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
        SELECT ucp.rowid,ucp.*
        FROM   igs_ps_usec_cps ucp
        WHERE  ucp.uoo_id= cp_c_uoo_id
        AND    ucp.billing_credit_points IS NOT NULL;
        l_c_audit_credit c_audit_credit%ROWTYPE;

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_location_cd,
      x_unit_class,
      x_uoo_id,
      x_ivrs_available_ind,
      x_call_number,
      x_unit_section_status,
      x_unit_section_start_date,
      x_unit_section_end_date,
      x_enrollment_actual,
      x_waitlist_actual,
      x_offered_ind,
      x_state_financial_aid,
      x_grading_schema_prcdnce_ind,
      x_federal_financial_aid,
      x_unit_quota,
      x_unit_quota_reserved_places,
      x_institutional_financial_aid,
      x_unit_contact,
      x_grading_schema_cd,
      x_gs_version_number,
      x_owner_org_unit_cd,
      x_attendance_required_ind,
      x_reserved_seating_allowed,
      x_special_permission_ind,
      x_ss_display_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      x_ss_enrol_ind,
      x_dir_enrollment,
      x_enr_from_wlst,
      x_inq_not_wlst,
      x_rev_account_cd,
      x_anon_unit_grading_ind,
      x_anon_assess_grading_ind,
      x_non_std_usec_ind,
      x_auditable_ind,
      x_audit_permission_ind,
      x_not_multiple_section_flag,
      x_sup_uoo_id ,
      x_relation_type ,
      x_default_enroll_flag,
      x_abort_flag
     );


    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE,p_updating=>FALSE,p_deleting=>FALSE );
          IF Get_PK_For_Validation (
                                             New_References.unit_cd,
                                             New_References.version_number,
                                             New_References.cal_type,
                                             New_References.ci_sequence_number,
                                             New_References.location_cd,
                                             New_References.unit_class) THEN
                    Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
           END IF;
           Check_Uniqueness;
           Check_Constraints;
           Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
       beforerowupdate;
       BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,p_updating=>TRUE,p_deleting=>FALSE );
       Check_Constraints;
       Check_Parent_Existance;


       --Added as a part of Enh#3116171
       IF new_references.auditable_ind = 'N' THEN
         OPEN c_audit_credit(new_references.uoo_id);
         FETCH c_audit_credit INTO l_c_audit_credit;
         IF c_audit_credit%FOUND THEN
           igs_ps_usec_cps_pkg.update_row(
                x_rowid                        =>l_c_audit_credit.rowid,
                x_unit_sec_credit_points_id    =>l_c_audit_credit.unit_sec_credit_points_id,
                x_uoo_id                       =>l_c_audit_credit.uoo_id,
                x_minimum_credit_points        =>l_c_audit_credit.minimum_credit_points,
                x_maximum_credit_points        =>l_c_audit_credit.maximum_credit_points,
                x_variable_increment           =>l_c_audit_credit.variable_increment,
                x_lecture_credit_points        =>l_c_audit_credit.lecture_credit_points,
                x_lab_credit_points            =>l_c_audit_credit.lab_credit_points,
                x_other_credit_points          =>l_c_audit_credit.other_credit_points,
                x_clock_hours                  =>l_c_audit_credit.clock_hours,
                x_work_load_cp_lecture         =>l_c_audit_credit.work_load_cp_lecture,
                x_work_load_cp_lab             =>l_c_audit_credit.work_load_cp_lab,
                x_continuing_education_units   =>l_c_audit_credit.continuing_education_units,
                x_work_load_other              =>l_c_audit_credit.work_load_other,
                x_contact_hrs_lecture          =>l_c_audit_credit.contact_hrs_lecture,
                x_contact_hrs_lab              =>l_c_audit_credit.contact_hrs_lab,
                x_contact_hrs_other            =>l_c_audit_credit.contact_hrs_other,
                x_non_schd_required_hrs        =>l_c_audit_credit.non_schd_required_hrs,
                x_exclude_from_max_cp_limit    =>l_c_audit_credit.exclude_from_max_cp_limit,
                x_mode                         =>'R',
                x_claimable_hours              =>l_c_audit_credit.claimable_hours,
                x_achievable_credit_points     =>l_c_audit_credit.achievable_credit_points,
                x_enrolled_credit_points       =>l_c_audit_credit.enrolled_credit_points,
                x_billing_credit_points        =>NULL,
                x_billing_hrs                  => l_c_audit_credit.billing_hrs
               );
         END IF;
         CLOSE c_audit_credit;
       END IF;


    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      beforerowdelete;
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,p_updating=>FALSE,p_deleting=>TRUE);
      Check_Child_Existance;
      Check_UK_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
           IF Get_PK_For_Validation (New_References.unit_cd,
                                             New_References.version_number,
                                             New_References.cal_type,
                                             New_References.ci_sequence_number,
                                             New_References.location_cd,
                                             New_References.unit_class) THEN
                      Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
              IGS_GE_MSG_STACK.ADD;
                      App_Exception.Raise_Exception;
           END IF;
           Check_Uniqueness;
           Check_Constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
           beforerowupdate;
           Check_Uniqueness;
           Check_Constraints;
   ELSIF (p_action = 'VALIDATE_DELETE') THEN
           beforerowdelete;
           Check_Child_Existance;
           Check_UK_Child_Existance;
   END IF;

   --This if condition is added as a part of bug#1689872
   IF p_action IN ( 'INSERT', 'VALIDATE_INSERT') THEN

      --Bug#2563596,Check that teach calendar is associated to a load calendar
      OPEN cur_teach_to_load(x_cal_type,x_ci_sequence_number);
      FETCH cur_teach_to_load INTO l_cur_teach_to_load ;
      IF cur_teach_to_load%NOTFOUND THEN
         CLOSE cur_teach_to_load;
         fnd_message.set_name('IGS','IGS_PS_TECH_NO_LOAD_CAL_EXST');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      CLOSE cur_teach_to_load;

      --check the call number uniqueness
      IF ((FND_PROFILE.VALUE('IGS_PS_CALL_NUMBER') = 'USER_DEFINED') AND (x_call_number IS NOT NULL) ) THEN
        IF NOT check_call_number(x_cal_type,x_ci_sequence_number,x_call_number,x_rowid) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_PS_DUPLICATE_CALL_NUMBER');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

   ELSIF  p_action IN ('UPDATE','VALIDATE_UPDATE')  THEN

      IF ((old_references.call_number = new_references.call_number) OR
         (new_references.call_number IS NULL)) THEN
         NULL;
      ELSE
        --check the call number uniqueness
        IF ((FND_PROFILE.VALUE('IGS_PS_CALL_NUMBER') = 'USER_DEFINED') AND (x_call_number IS NOT NULL) ) THEN
          IF NOT check_call_number(x_cal_type,x_ci_sequence_number,x_call_number,x_rowid) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_PS_DUPLICATE_CALL_NUMBER');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
          END IF;
        END IF;

      END IF;
   END IF;


  END Before_DML;

Procedure     dflt_usec_ref_code ( p_n_uoo_id      IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE )
  AS

  /************************************************************************
  Created By                                : Aiyer
  Date Created By                           : 14/06/2001
  Purpose                                   : Inserts into table IGS_PS_USEC_REF values inherited from igs_ps_unit_ver and  IGS_PS_USEC_REF_CD
                                            : mandatory ref code types for unit_section with default ref code id's for the current uoo_id
                                            : at unit_section level
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  stutta      14-May-2004   Passing 'N' as default value for X_CLASS_SCHED_EXCLUSION_FLAG in call
                            to igs_ps_usec_ref_pkg.INSERT_ROW
  *************************************************************************/
  CURSOR c_igs_ge_ref_cd_type
  IS
  SELECT
      reference_cd_type
  FROM
      igs_ge_ref_cd_type
  WHERE
      mandatory_flag ='Y'
  AND
      unit_section_flag ='Y'
  AND
      restricted_flag='Y'
  AND
      closed_ind = 'N';

  CURSOR c_igs_ge_ref_cd (p_c_reference_cd_type IGS_GE_REF_CD_TYPE.REFERENCE_CD_TYPE%TYPE)
  IS
  SELECT
         reference_cd_type,reference_cd,description
  FROM
         igs_ge_ref_cd
  WHERE
         reference_cd_type = p_c_reference_cd_type
  AND
         default_flag      =  'Y';

  -- Used to Inherit value from IGS_PS_UNIT_VER table
  CURSOR c_igs_ps_unit_ver
   IS
  SELECT
         SHORT_TITLE,
         SUBTITLE_MODIFIABLE_FLAG,
         RECORD_EXCLUSION_FLAG ,
         TITLE ,
         SUBTITLE_ID ,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1  ,
         ATTRIBUTE2  ,
         ATTRIBUTE3  ,
         ATTRIBUTE4  ,
         ATTRIBUTE5  ,
         ATTRIBUTE6  ,
         ATTRIBUTE7  ,
         ATTRIBUTE8  ,
         ATTRIBUTE9  ,
         ATTRIBUTE10 ,
         ATTRIBUTE11 ,
         ATTRIBUTE12 ,
         ATTRIBUTE13 ,
         ATTRIBUTE14 ,
         ATTRIBUTE15 ,
         ATTRIBUTE16 ,
         ATTRIBUTE17 ,
         ATTRIBUTE18 ,
         ATTRIBUTE19 ,
         ATTRIBUTE20
   FROM
         igs_ps_unit_ofr_opt_all uoo,
         igs_ps_unit_ver    uv
   WHERE
         uv.unit_cd = uoo.unit_cd
   AND
         uv.version_number = uoo.version_number
   AND
         uoo.uoo_id = p_n_uoo_id;
   ln_usec_ref_id        IGS_PS_USEC_REF.UNIT_SECTION_REFERENCE_ID%TYPE := NULL;
   ln_usec_ref_cd_id     IGS_PS_USEC_REF_CD.UNIT_SECTION_REFERENCE_CD_ID%TYPE := NULL;
   l_c_rowid1            VARCHAR2(25)   :=NULL;
   l_c_rowid2            VARCHAR2(25)   :=NULL;
 BEGIN
  FOR cur_igs_ps_unit_ver IN c_igs_ps_unit_ver
  LOOP
  BEGIN
    l_c_rowid1:=NULL;
    igs_ps_usec_ref_pkg.INSERT_ROW (
                                     X_ROWID                        => l_c_rowid1,
                                     X_UNIT_SECTION_REFERENCE_ID    => ln_usec_ref_id,
                                     X_UOO_ID                       => p_n_uoo_id,
                                     X_CLASS_SCHED_EXCLUSION_FLAG   => 'N',
                                     X_SHORT_TITLE                  => cur_igs_ps_unit_ver.Short_title,
                                     X_SUBTITLE                     => NULL   ,
                                     X_SUBTITLE_MODIFIABLE_FLAG     => cur_igs_ps_unit_ver.Subtitle_modifiable_flag,
                                     X_REGISTRATION_EXCLUSION_FLAG  => NULL  ,
                                     X_RECORD_EXCLUSION_FLAG        => cur_igs_ps_unit_ver.Record_exclusion_flag ,
                                     X_TITLE                        => cur_igs_ps_unit_ver.Title ,
                                     X_SUBTITLE_ID                  => cur_igs_ps_unit_ver.Subtitle_id,
                                     X_ATTRIBUTE_CATEGORY           => cur_igs_ps_unit_ver.Attribute_category,
                                     X_ATTRIBUTE1                   => cur_igs_ps_unit_ver.Attribute1  ,
                                     X_ATTRIBUTE2                   => cur_igs_ps_unit_ver.Attribute2  ,
                                     X_ATTRIBUTE3                   => cur_igs_ps_unit_ver.Attribute3  ,
                                     X_ATTRIBUTE4                   => cur_igs_ps_unit_ver.Attribute4  ,
                                     X_ATTRIBUTE5                   => cur_igs_ps_unit_ver.Attribute5  ,
                                     X_ATTRIBUTE6                   => cur_igs_ps_unit_ver.Attribute6  ,
                                     X_ATTRIBUTE7                   => cur_igs_ps_unit_ver.Attribute7  ,
                                     X_ATTRIBUTE8                   => cur_igs_ps_unit_ver.Attribute8  ,
                                     X_ATTRIBUTE9                   => cur_igs_ps_unit_ver.Attribute9  ,
                                     X_ATTRIBUTE10                  => cur_igs_ps_unit_ver.Attribute10 ,
                                     X_ATTRIBUTE11                  => cur_igs_ps_unit_ver.Attribute11 ,
                                     X_ATTRIBUTE12                  => cur_igs_ps_unit_ver.Attribute12 ,
                                     X_ATTRIBUTE13                  => cur_igs_ps_unit_ver.Attribute13 ,
                                     X_ATTRIBUTE14                  => cur_igs_ps_unit_ver.Attribute14 ,
                                     X_ATTRIBUTE15                  => cur_igs_ps_unit_ver.Attribute15 ,
                                     X_ATTRIBUTE16                  => cur_igs_ps_unit_ver.Attribute16 ,
                                     X_ATTRIBUTE17                  => cur_igs_ps_unit_ver.Attribute17 ,
                                     X_ATTRIBUTE18                  => cur_igs_ps_unit_ver.Attribute18 ,
                                     X_ATTRIBUTE19                  => cur_igs_ps_unit_ver.Attribute19 ,
                                     X_ATTRIBUTE20                  => cur_igs_ps_unit_ver.Attribute20 ,
                                     X_MODE                         => 'R'
                                   );
    FOR cur_igs_ge_ref_cd_type IN c_igs_ge_ref_cd_type
    LOOP
      FOR cur_igs_ge_ref_cd IN c_igs_ge_ref_cd (cur_igs_ge_ref_cd_type.reference_cd_type)
      LOOP
        l_c_rowid2:=NULL;
        ln_usec_ref_cd_id:=NULL;
        igs_ps_usec_ref_cd_pkg.INSERT_ROW (
                                            X_ROWID                           => l_c_rowid2,
                                            X_UNIT_SECTION_REFERENCE_CD_ID    => ln_usec_ref_cd_id,
                                            X_UNIT_SECTION_REFERENCE_ID       => ln_usec_ref_id,
                                            X_MODE                            => 'R',
                                            x_reference_code_type             => cur_igs_ge_ref_cd.reference_cd_type,
                                            x_reference_code                  => cur_igs_ge_ref_cd.reference_cd,
                                            x_reference_code_desc             => cur_igs_ge_ref_cd.description

                                          );
      END LOOP;
    END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
       NULL;
   END;
  END LOOP;
  EXCEPTION
   WHEN OTHERS THEN
     -- If an error occurs during insertion in igs_ps_ref_cd then raise an exception.
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
    RETURN;
END dflt_usec_ref_code;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : jdeekoll
  Date Created By : 27-Dec-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  -- This code has been added by aiyer.
  -- After inserting value into igs_ps_unit_ofr_opt insert values into igs_ps_usec_ref and mandatory reference_cd_types of unit_section type
  -- a having default reference_cd in the table igs_ps_usec_ref_cd
  CURSOR c_igs_ps_unit_ofr_opt
   IS
   SELECT uoo_id
   FROM
         IGS_PS_UNIT_OFR_OPT
   WHERE
         row_id = x_rowid;
  BEGIN
   l_rowid := x_rowid;
   IF (p_action = 'INSERT') THEN
        l_rowid:=NULL;
        FOR cur_igs_ps_unit_ofr_opt IN c_igs_ps_unit_ofr_opt
        LOOP
          dflt_usec_ref_code (p_n_uoo_id => cur_igs_ps_unit_ofr_opt.uoo_id);
        END LOOP;
    END IF;
   l_rowid:=NULL;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_LOCATION_CD IN VARCHAR2,
       x_UNIT_CLASS IN VARCHAR2,
       x_UOO_ID IN NUMBER,
       x_IVRS_AVAILABLE_IND IN VARCHAR2,
       x_CALL_NUMBER IN OUT NOCOPY NUMBER,
       x_UNIT_SECTION_STATUS IN VARCHAR2,
       x_UNIT_SECTION_START_DATE IN DATE,
       x_UNIT_SECTION_END_DATE IN DATE,
       x_ENROLLMENT_ACTUAL IN NUMBER,
       x_WAITLIST_ACTUAL IN NUMBER,
       x_OFFERED_IND IN VARCHAR2,
       x_STATE_FINANCIAL_AID IN VARCHAR2,
       x_GRADING_SCHEMA_PRCDNCE_IND IN VARCHAR2,
       x_FEDERAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_QUOTA IN NUMBER,
       x_UNIT_QUOTA_RESERVED_PLACES IN NUMBER,
       x_INSTITUTIONAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_CONTACT IN NUMBER,
       x_GRADING_SCHEMA_CD IN VARCHAR2,
       x_GS_VERSION_NUMBER IN NUMBER,
       x_owner_org_unit_cd                 IN     VARCHAR2 ,
       x_attendance_required_ind           IN     VARCHAR2 ,
       x_reserved_seating_allowed          IN     VARCHAR2 ,
       x_special_permission_ind            IN     VARCHAR2 ,
       x_ss_display_ind                    IN     VARCHAR2 ,
       X_MODE in VARCHAR2 ,
       x_org_id IN NUMBER,
       x_ss_enrol_ind IN VARCHAR2 ,
       x_dir_enrollment IN NUMBER ,
       x_enr_from_wlst  IN NUMBER ,
       x_inq_not_wlst  IN NUMBER ,
       x_rev_account_cd IN VARCHAR2 ,
       x_anon_unit_grading_ind IN VARCHAR2 ,
       x_anon_assess_grading_ind IN VARCHAR2 ,
       X_NON_STD_USEC_IND IN VARCHAR2 ,
       x_auditable_ind IN VARCHAR2,
       x_audit_permission_ind IN VARCHAR2,
       x_not_multiple_section_flag IN VARCHAR2,
       x_sup_uoo_id IN NUMBER ,
       x_relation_type VARCHAR2 ,
       x_default_enroll_flag VARCHAR2,
       x_abort_flag VARCHAR2
  ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   vvutukur        05-Aug-2003     Enh#3045069.PSP Enh Build. Added column not_multiple_section_flag.
   shtatiko        06-NOV-2002     Added auditable_ind and audit_permission_ind as part of Bug# 2636716
   sbaliga         13-feb-2002     Assigned igs_ge_gen_003.get_org_id to x_org_id in call to before_dml
                                   as part of SWCR006 build.
   rgangara        07-May-2001     Ss_enrol_ind column added
   (reverse chronological order - newest change first)
  ***************************************************************/
    cursor C is select ROWID from IGS_PS_UNIT_OFR_OPT_ALL
      where UNIT_CD = X_UNIT_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and LOCATION_CD = X_LOCATION_CD
      and UNIT_CLASS = X_UNIT_CLASS
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
      and CAL_TYPE = X_CAL_TYPE;
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

   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
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
    app_exception.raise_exception;
  end if;



    Before_DML(
                p_action=>'INSERT',
                x_rowid=>X_ROWID,
               x_unit_cd=>X_UNIT_CD,
               x_version_number=>X_VERSION_NUMBER,
               x_cal_type=>X_CAL_TYPE,
               x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
               x_location_cd=>X_LOCATION_CD,
               x_unit_class=>X_UNIT_CLASS,
               x_uoo_id=>X_UOO_ID,
               x_ivrs_available_ind=>NVL(X_IVRS_AVAILABLE_IND,'Y' ),
               x_call_number=>X_CALL_NUMBER,
               x_unit_section_status=>X_UNIT_SECTION_STATUS,
               x_unit_section_start_date=>X_UNIT_SECTION_START_DATE,
               x_unit_section_end_date=>X_UNIT_SECTION_END_DATE,
               x_enrollment_actual=>X_ENROLLMENT_ACTUAL,
               x_waitlist_actual=>X_WAITLIST_ACTUAL,
               x_offered_ind=>NVL(X_OFFERED_IND,'Y' ),
               x_state_financial_aid=>X_STATE_FINANCIAL_AID,
               x_grading_schema_prcdnce_ind=>NVL(X_GRADING_SCHEMA_PRCDNCE_IND,'N' ),
               x_federal_financial_aid=>X_FEDERAL_FINANCIAL_AID,
               x_unit_quota=>X_UNIT_QUOTA,
               x_unit_quota_reserved_places=>X_UNIT_QUOTA_RESERVED_PLACES,
               x_institutional_financial_aid=>X_INSTITUTIONAL_FINANCIAL_AID,
               x_unit_contact=>X_UNIT_CONTACT,
               x_grading_schema_cd=>X_GRADING_SCHEMA_CD,
               x_gs_version_number=>X_GS_VERSION_NUMBER,
               x_owner_org_unit_cd =>X_OWNER_ORG_UNIT_CD,
               x_attendance_required_ind =>NVL(X_ATTENDANCE_REQUIRED_IND,'N'),
               x_reserved_seating_allowed =>NVL(X_RESERVED_SEATING_ALLOWED,'Y'),
               x_special_permission_ind => NVL(X_SPECIAL_PERMISSION_IND,'N'),
               x_ss_display_ind  => NVL(X_SS_DISPLAY_IND,'N'),
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_org_id=>igs_ge_gen_003.get_org_id,
               x_ss_enrol_ind => X_SS_ENROL_IND,
               x_dir_enrollment =>X_DIR_ENROLLMENT,
               x_enr_from_wlst =>X_ENR_FROM_WLST ,
               x_inq_not_wlst =>X_INQ_NOT_WLST,
               x_rev_account_cd => x_rev_account_cd ,
               x_anon_unit_grading_ind => x_anon_unit_grading_ind,
               x_anon_assess_grading_ind => x_anon_assess_grading_ind,
               x_non_std_usec_ind => x_non_std_usec_ind,
               x_auditable_ind => x_auditable_ind,
               x_audit_permission_ind => x_audit_permission_ind,
               x_not_multiple_section_flag => x_not_multiple_section_flag,
               x_sup_uoo_id => x_sup_uoo_id ,
               x_relation_type => x_relation_type ,
               x_default_enroll_flag => x_default_enroll_flag,
	       x_abort_flag => x_abort_flag
             );

     --When the profile option is AUTO then use the sequence number to populate the call_number value
     IF FND_PROFILE.VALUE('IGS_PS_CALL_NUMBER') = 'AUTO' THEN
        x_call_number := get_call_number(new_references.cal_type, new_references.ci_sequence_number);
        IF x_call_number = -1 THEN
           fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
           app_exception.raise_exception;
        END IF;
     END IF;

     insert into IGS_PS_UNIT_OFR_OPT_ALL (
                UNIT_CD
                ,VERSION_NUMBER
                ,CAL_TYPE
                ,CI_SEQUENCE_NUMBER
                ,LOCATION_CD
                ,UNIT_CLASS
                ,UOO_ID
                ,IVRS_AVAILABLE_IND
                ,CALL_NUMBER
                ,UNIT_SECTION_STATUS
                ,UNIT_SECTION_START_DATE
                ,UNIT_SECTION_END_DATE
                ,ENROLLMENT_ACTUAL
                ,WAITLIST_ACTUAL
                ,OFFERED_IND
                ,STATE_FINANCIAL_AID
                ,GRADING_SCHEMA_PRCDNCE_IND
                ,FEDERAL_FINANCIAL_AID
                ,UNIT_QUOTA
                ,UNIT_QUOTA_RESERVED_PLACES
                ,INSTITUTIONAL_FINANCIAL_AID
                ,UNIT_CONTACT
                ,GRADING_SCHEMA_CD
                ,GS_VERSION_NUMBER
                ,owner_org_unit_cd
                ,attendance_required_ind
                ,reserved_seating_allowed
                ,special_permission_ind
                ,ss_display_ind
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,REQUEST_ID
                ,PROGRAM_ID
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_UPDATE_DATE
                ,ORG_ID
                ,SS_ENROL_IND
                ,DIR_ENROLLMENT
                ,ENR_FROM_WLST
                ,INQ_NOT_WLST
                ,rev_account_cd
                ,anon_unit_grading_ind
                ,anon_assess_grading_ind
                ,non_std_usec_ind,
                auditable_ind,
                audit_permission_ind,
                not_multiple_section_flag,
                sup_uoo_id,
                relation_type,
                default_enroll_flag,
		abort_flag
        ) values  (
                NEW_REFERENCES.UNIT_CD
                ,NEW_REFERENCES.VERSION_NUMBER
                ,NEW_REFERENCES.CAL_TYPE
                ,NEW_REFERENCES.CI_SEQUENCE_NUMBER
                ,NEW_REFERENCES.LOCATION_CD
                ,NEW_REFERENCES.UNIT_CLASS
                ,NEW_REFERENCES.UOO_ID
                ,NEW_REFERENCES.IVRS_AVAILABLE_IND
                ,x_call_number
                ,NEW_REFERENCES.UNIT_SECTION_STATUS
                ,NEW_REFERENCES.UNIT_SECTION_START_DATE
                ,NEW_REFERENCES.UNIT_SECTION_END_DATE
                ,NEW_REFERENCES.ENROLLMENT_ACTUAL
                ,NEW_REFERENCES.WAITLIST_ACTUAL
                ,NEW_REFERENCES.OFFERED_IND
                ,NEW_REFERENCES.STATE_FINANCIAL_AID
                ,NEW_REFERENCES.GRADING_SCHEMA_PRCDNCE_IND
                ,NEW_REFERENCES.FEDERAL_FINANCIAL_AID
                ,NEW_REFERENCES.UNIT_QUOTA
                ,NEW_REFERENCES.UNIT_QUOTA_RESERVED_PLACES
                ,NEW_REFERENCES.INSTITUTIONAL_FINANCIAL_AID
                ,NEW_REFERENCES.UNIT_CONTACT
                ,NEW_REFERENCES.GRADING_SCHEMA_CD
                ,NEW_REFERENCES.GS_VERSION_NUMBER
                ,NEW_REFERENCES.owner_org_unit_cd
                ,NEW_REFERENCES.attendance_required_ind
                ,NEW_REFERENCES.reserved_seating_allowed
                ,NEW_REFERENCES.special_permission_ind
                ,NEW_REFERENCES.ss_display_ind
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_LOGIN
                ,X_REQUEST_ID
                ,X_PROGRAM_ID
                ,X_PROGRAM_APPLICATION_ID
                ,X_PROGRAM_UPDATE_DATE
                ,NEW_REFERENCES.ORG_ID
                ,NEW_REFERENCES.SS_ENROL_IND
                ,NEW_REFERENCES.DIR_ENROLLMENT
                ,NEW_REFERENCES.ENR_FROM_WLST
                ,NEW_REFERENCES.INQ_NOT_WLST
                ,new_references.rev_account_cd
                ,new_references.anon_unit_grading_ind
                ,new_references.anon_assess_grading_ind
                ,new_references.non_std_usec_ind,
                new_references.auditable_ind,
                new_references.audit_permission_ind,
                new_references.not_multiple_section_flag,
                new_references.sup_uoo_id,
                new_references.relation_type,
                new_references.default_enroll_flag,
		new_references.abort_flag
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
                x_rowid => X_ROWID
            );

end INSERT_ROW;

procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_LOCATION_CD IN VARCHAR2,
       x_UNIT_CLASS IN VARCHAR2,
       x_UOO_ID IN NUMBER,
       x_IVRS_AVAILABLE_IND IN VARCHAR2,
       x_CALL_NUMBER IN NUMBER,
       x_UNIT_SECTION_STATUS IN VARCHAR2,
       x_UNIT_SECTION_START_DATE IN DATE,
       x_UNIT_SECTION_END_DATE IN DATE,
       x_ENROLLMENT_ACTUAL IN NUMBER,
       x_WAITLIST_ACTUAL IN NUMBER,
       x_OFFERED_IND IN VARCHAR2,
       x_STATE_FINANCIAL_AID IN VARCHAR2,
       x_GRADING_SCHEMA_PRCDNCE_IND IN VARCHAR2,
       x_FEDERAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_QUOTA IN NUMBER,
       x_UNIT_QUOTA_RESERVED_PLACES IN NUMBER,
       x_INSTITUTIONAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_CONTACT IN NUMBER,
       x_GRADING_SCHEMA_CD IN VARCHAR2,
       x_GS_VERSION_NUMBER IN NUMBER,
       x_owner_org_unit_cd                 IN     VARCHAR2 ,
       x_attendance_required_ind           IN     VARCHAR2 ,
       x_reserved_seating_allowed          IN     VARCHAR2 ,
       x_special_permission_ind            IN     VARCHAR2 ,
       x_ss_display_ind                    IN     VARCHAR2 ,
       x_ss_enrol_ind in VARCHAR2 ,
       x_dir_enrollment IN NUMBER ,
       x_enr_from_wlst  IN NUMBER ,
       x_inq_not_wlst  IN NUMBER ,
       x_rev_account_cd IN VARCHAR2 ,
       x_anon_unit_grading_ind IN VARCHAR2 ,
       x_anon_assess_grading_ind IN VARCHAR2 ,
       X_NON_STD_USEC_IND IN VARCHAR2,
       x_auditable_ind IN VARCHAR2,
       x_audit_permission_ind IN VARCHAR2,
       x_not_multiple_section_flag IN VARCHAR2,
       x_sup_uoo_id IN NUMBER ,
       x_relation_type VARCHAR2 ,
       x_default_enroll_flag VARCHAR2,
       x_abort_flag VARCHAR2
  ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   vvutukur        05-Aug-2003     Enh#3045069.PSP Enh Build. Added column not_multiple_section_flag.
   shtatiko        06-NOV-2002     added auditable_ind and audit_permission_ind as part of Bug# 2636716.
   rgangara        07-May-2001     ss_enrol_ind col added
   (reverse chronological order - newest change first)
  ***************************************************************/
   cursor c1 is select
      UOO_ID
,      IVRS_AVAILABLE_IND
,      CALL_NUMBER
,      UNIT_SECTION_STATUS
,      UNIT_SECTION_START_DATE
,      UNIT_SECTION_END_DATE
,      ENROLLMENT_ACTUAL
,      WAITLIST_ACTUAL
,      OFFERED_IND
,      STATE_FINANCIAL_AID
,      GRADING_SCHEMA_PRCDNCE_IND
,      FEDERAL_FINANCIAL_AID
,      UNIT_QUOTA
,      UNIT_QUOTA_RESERVED_PLACES
,      INSTITUTIONAL_FINANCIAL_AID
,      UNIT_CONTACT
,      GRADING_SCHEMA_CD
,      GS_VERSION_NUMBER
,      OWNER_ORG_UNIT_CD
,      ATTENDANCE_REQUIRED_IND
,      RESERVED_SEATING_ALLOWED
,      SPECIAL_PERMISSION_IND
,      SS_DISPLAY_IND
,      SS_ENROL_IND
,      DIR_ENROLLMENT
,      ENR_FROM_WLST
,      INQ_NOT_WLST
,      rev_account_cd
,      anon_unit_grading_ind
,      anon_assess_grading_ind
,      NON_STD_USEC_IND,
auditable_ind,
audit_permission_ind,
not_multiple_section_flag,
sup_uoo_id,
relation_type,
default_enroll_flag,
abort_flag
    from IGS_PS_UNIT_OFR_OPT_ALL
    where ROWID = X_ROWID
    for update nowait;

        tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

if ( (  tlinfo.UOO_ID = X_UOO_ID)
  AND (tlinfo.IVRS_AVAILABLE_IND = X_IVRS_AVAILABLE_IND)
  AND ((tlinfo.CALL_NUMBER = X_CALL_NUMBER)
            OR ((tlinfo.CALL_NUMBER is null)
                AND (X_CALL_NUMBER is null)))
  AND ((tlinfo.UNIT_SECTION_STATUS = X_UNIT_SECTION_STATUS)
            OR ((tlinfo.UNIT_SECTION_STATUS is null)
                AND (X_UNIT_SECTION_STATUS is null)))
  AND ((tlinfo.UNIT_SECTION_START_DATE = X_UNIT_SECTION_START_DATE)
            OR ((tlinfo.UNIT_SECTION_START_DATE is null)
                AND (X_UNIT_SECTION_START_DATE is null)))
  AND ((tlinfo.UNIT_SECTION_END_DATE = X_UNIT_SECTION_END_DATE)
            OR ((tlinfo.UNIT_SECTION_END_DATE is null)
                AND (X_UNIT_SECTION_END_DATE is null)))
  AND ((tlinfo.ENROLLMENT_ACTUAL = X_ENROLLMENT_ACTUAL)
            OR ((tlinfo.ENROLLMENT_ACTUAL is null)
                AND (X_ENROLLMENT_ACTUAL is null)))
  AND ((tlinfo.WAITLIST_ACTUAL = X_WAITLIST_ACTUAL)
            OR ((tlinfo.WAITLIST_ACTUAL is null)
                AND (X_WAITLIST_ACTUAL is null)))
  AND (tlinfo.OFFERED_IND = X_OFFERED_IND)
  AND ((tlinfo.STATE_FINANCIAL_AID = X_STATE_FINANCIAL_AID)
            OR ((tlinfo.STATE_FINANCIAL_AID is null)
                AND (X_STATE_FINANCIAL_AID is null)))
  AND (tlinfo.GRADING_SCHEMA_PRCDNCE_IND = X_GRADING_SCHEMA_PRCDNCE_IND)
  AND ((tlinfo.FEDERAL_FINANCIAL_AID = X_FEDERAL_FINANCIAL_AID)
            OR ((tlinfo.FEDERAL_FINANCIAL_AID is null)
                AND (X_FEDERAL_FINANCIAL_AID is null)))
  AND ((tlinfo.UNIT_QUOTA = X_UNIT_QUOTA)
            OR ((tlinfo.UNIT_QUOTA is null)
                AND (X_UNIT_QUOTA is null)))
  AND ((tlinfo.UNIT_QUOTA_RESERVED_PLACES = X_UNIT_QUOTA_RESERVED_PLACES)
            OR ((tlinfo.UNIT_QUOTA_RESERVED_PLACES is null)
                AND (X_UNIT_QUOTA_RESERVED_PLACES is null)))
  AND ((tlinfo.INSTITUTIONAL_FINANCIAL_AID = X_INSTITUTIONAL_FINANCIAL_AID)
            OR ((tlinfo.INSTITUTIONAL_FINANCIAL_AID is null)
                AND (X_INSTITUTIONAL_FINANCIAL_AID is null)))
  AND ((tlinfo.UNIT_CONTACT = X_UNIT_CONTACT)
            OR ((tlinfo.UNIT_CONTACT is null)
                AND (X_UNIT_CONTACT is null)))
  AND (tlinfo.GRADING_SCHEMA_CD = X_GRADING_SCHEMA_CD)
  AND (tlinfo.GS_VERSION_NUMBER = X_GS_VERSION_NUMBER)
  AND ((tlinfo.owner_org_unit_cd = x_owner_org_unit_cd)
            OR ((tlinfo.owner_org_unit_cd IS NULL)
                AND (X_owner_org_unit_cd IS NULL)))
  AND ((tlinfo.attendance_required_ind = x_attendance_required_ind)
            OR ((tlinfo.attendance_required_ind IS NULL)
                AND (X_attendance_required_ind IS NULL)))
  AND ((tlinfo.reserved_seating_allowed = x_reserved_seating_allowed)
            OR ((tlinfo.reserved_seating_allowed IS NULL)
                AND (X_reserved_seating_allowed IS NULL)))
  AND ((tlinfo.special_permission_ind = x_special_permission_ind)
            OR ((tlinfo.special_permission_ind IS NULL)
                AND (X_special_permission_ind IS NULL)))
  AND ((tlinfo.ss_display_ind = x_ss_display_ind)
            OR ((tlinfo.ss_display_ind IS NULL)
                AND (X_ss_display_ind IS NULL)))
  AND ((tlinfo.SS_ENROL_IND = X_SS_ENROL_IND)
      OR ((tlinfo.SS_ENROL_IND IS NULL)
         AND (X_SS_ENROL_IND is NULL)))
  AND ((tlinfo.DIR_ENROLLMENT = X_DIR_ENROLLMENT)
      OR ((tlinfo.DIR_ENROLLMENT IS NULL)
         AND (X_DIR_ENROLLMENT is NULL)))
  AND ((tlinfo.ENR_FROM_WLST = X_ENR_FROM_WLST)
      OR ((tlinfo.ENR_FROM_WLST IS NULL)
         AND (X_ENR_FROM_WLST is NULL)))
  AND ((tlinfo.INQ_NOT_WLST = X_INQ_NOT_WLST)
      OR ((tlinfo.INQ_NOT_WLST IS NULL)
         AND (X_INQ_NOT_WLST is NULL)))
  AND ((tlinfo.rev_account_cd = x_rev_account_cd)
     OR ((tlinfo.rev_account_cd IS NULL)
        AND (x_rev_account_cd is NULL)))
  AND ((tlinfo.anon_unit_grading_ind = x_anon_unit_grading_ind)
     OR ((tlinfo.anon_unit_grading_ind IS NULL)
        AND (x_anon_unit_grading_ind is NULL)))
  AND ((tlinfo.anon_assess_grading_ind = x_anon_assess_grading_ind)
     OR ((tlinfo.anon_assess_grading_ind IS NULL)
        AND (x_anon_assess_grading_ind is NULL)))
  AND ((tlinfo.non_std_usec_ind = x_non_std_usec_ind)
     OR ((tlinfo.non_std_usec_ind IS NULL)
        AND (x_non_std_usec_ind is NULL)))
  AND ((tlinfo.auditable_ind = x_auditable_ind)
     OR ((tlinfo.auditable_ind IS NULL)
        AND (x_auditable_ind is NULL)))
  AND ((tlinfo.audit_permission_ind = x_audit_permission_ind)
     OR ((tlinfo.audit_permission_ind IS NULL)
        AND (x_audit_permission_ind is NULL)))
  AND ((tlinfo.not_multiple_section_flag = x_not_multiple_section_flag)
     OR ((tlinfo.not_multiple_section_flag IS NULL)
        AND (x_not_multiple_section_flag IS NULL)))
  AND ((tlinfo.sup_uoo_id= x_sup_uoo_id)
     OR ((tlinfo.sup_uoo_id IS NULL)
        AND (x_sup_uoo_id IS NULL)))
  AND ((tlinfo.relation_type= x_relation_type)
     OR ((tlinfo.relation_type IS NULL)
        AND (x_relation_type IS NULL)))
  AND ((tlinfo.default_enroll_flag= x_default_enroll_flag)
     OR ((tlinfo.default_enroll_flag IS NULL)
        AND (x_default_enroll_flag IS NULL)))
 AND (tlinfo.abort_flag = x_abort_flag)

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
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_LOCATION_CD IN VARCHAR2,
       x_UNIT_CLASS IN VARCHAR2,
       x_UOO_ID IN NUMBER,
       x_IVRS_AVAILABLE_IND IN VARCHAR2,
       x_CALL_NUMBER IN NUMBER,
       x_UNIT_SECTION_STATUS IN VARCHAR2,
       x_UNIT_SECTION_START_DATE IN DATE,
       x_UNIT_SECTION_END_DATE IN DATE,
       x_ENROLLMENT_ACTUAL IN NUMBER,
       x_WAITLIST_ACTUAL IN NUMBER,
       x_OFFERED_IND IN VARCHAR2,
       x_STATE_FINANCIAL_AID IN VARCHAR2,
       x_GRADING_SCHEMA_PRCDNCE_IND IN VARCHAR2,
       x_FEDERAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_QUOTA IN NUMBER,
       x_UNIT_QUOTA_RESERVED_PLACES IN NUMBER,
       x_INSTITUTIONAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_CONTACT IN NUMBER,
       x_GRADING_SCHEMA_CD IN VARCHAR2,
       x_GS_VERSION_NUMBER IN NUMBER,
       x_owner_org_unit_cd                 IN     VARCHAR2 ,
       x_attendance_required_ind           IN     VARCHAR2 ,
       x_reserved_seating_allowed          IN     VARCHAR2 ,
       x_special_permission_ind            IN     VARCHAR2 ,
       x_ss_display_ind                    IN     VARCHAR2 ,
       X_MODE in VARCHAR2 ,
       x_ss_enrol_ind IN VARCHAR2 ,
       x_dir_enrollment IN NUMBER ,
       x_enr_from_wlst  IN NUMBER ,
       x_inq_not_wlst  IN NUMBER ,
       x_rev_account_cd IN VARCHAR2 ,
       x_anon_unit_grading_ind IN VARCHAR2 ,
       x_anon_assess_grading_ind IN VARCHAR2 ,
       X_NON_STD_USEC_IND IN VARCHAR2,
       x_auditable_ind IN VARCHAR2,
       x_audit_permission_ind IN VARCHAR2,
       x_not_multiple_section_flag IN VARCHAR2,
       x_sup_uoo_id IN NUMBER ,
       x_relation_type VARCHAR2 ,
       x_default_enroll_flag VARCHAR2,
       x_abort_flag VARCHAR2

  ) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   bdeviset        03-MAY-2006     Bug# 5204703. Modified the if condition for calling
                                   'Enroll Students From Waitlist Process' CP.
   vvutukur        05-Aug-2003     Enh#3045069.PSP Enh Build. Added column not_multiple_section_flag.
   shtatiko        06-NOV-2002     Added auditable_ind and audit_permission_ind as part of Bug# 2636716.
   (reverse chronological order - newest change first)
  ***************************************************************/
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
    app_exception.raise_exception;
  end if;

   Before_DML(
                p_action=>'UPDATE',
                x_rowid=>X_ROWID,
               x_unit_cd=>X_UNIT_CD,
               x_version_number=>X_VERSION_NUMBER,
               x_cal_type=>X_CAL_TYPE,
               x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
               x_location_cd=>X_LOCATION_CD,
               x_unit_class=>X_UNIT_CLASS,
               x_uoo_id=>X_UOO_ID,
               x_ivrs_available_ind=>NVL(X_IVRS_AVAILABLE_IND,'Y' ),
               x_call_number=>X_CALL_NUMBER,
               x_unit_section_status=>X_UNIT_SECTION_STATUS,
               x_unit_section_start_date=>X_UNIT_SECTION_START_DATE,
               x_unit_section_end_date=>X_UNIT_SECTION_END_DATE,
               x_enrollment_actual=>X_ENROLLMENT_ACTUAL,
               x_waitlist_actual=>X_WAITLIST_ACTUAL,
               x_offered_ind=>NVL(X_OFFERED_IND,'Y' ),
               x_state_financial_aid=>X_STATE_FINANCIAL_AID,
               x_grading_schema_prcdnce_ind=>NVL(X_GRADING_SCHEMA_PRCDNCE_IND,'N' ),
               x_federal_financial_aid=>X_FEDERAL_FINANCIAL_AID,
               x_unit_quota=>X_UNIT_QUOTA,
               x_unit_quota_reserved_places=>X_UNIT_QUOTA_RESERVED_PLACES,
               x_institutional_financial_aid=>X_INSTITUTIONAL_FINANCIAL_AID,
               x_unit_contact=>X_UNIT_CONTACT,
               x_grading_schema_cd=>X_GRADING_SCHEMA_CD,
               x_gs_version_number=>X_GS_VERSION_NUMBER,
               x_owner_org_unit_cd                 => x_owner_org_unit_cd,
               x_attendance_required_ind           => x_attendance_required_ind,
               x_reserved_seating_allowed          => x_reserved_seating_allowed,
               x_special_permission_ind            => x_special_permission_ind,
               x_ss_display_ind                    => x_ss_display_ind,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_ss_enrol_ind =>X_SS_ENROL_IND,
               x_dir_enrollment =>X_DIR_ENROLLMENT,
               x_enr_from_wlst =>X_ENR_FROM_WLST,
               x_inq_not_wlst =>X_INQ_NOT_WLST,
               x_rev_account_cd => x_rev_account_cd,
               x_anon_unit_grading_ind => x_anon_unit_grading_ind,
               x_anon_assess_grading_ind => x_anon_assess_grading_ind,
               x_non_std_usec_ind => x_non_std_usec_ind,
               x_auditable_ind => x_auditable_ind,
               x_audit_permission_ind => x_audit_permission_ind,
               x_not_multiple_section_flag => x_not_multiple_section_flag,
               x_sup_uoo_id => x_sup_uoo_id,
               x_relation_type => x_relation_type,
               x_default_enroll_flag => x_default_enroll_flag,
	       x_abort_flag => x_abort_flag
);

  if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID :=
                OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE :=
                  OLD_REFERENCES.PROGRAM_UPDATE_DATE;
  else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
  end if;
  end if;

   update IGS_PS_UNIT_OFR_OPT_ALL set
      UOO_ID =  NEW_REFERENCES.UOO_ID,
      IVRS_AVAILABLE_IND =  NEW_REFERENCES.IVRS_AVAILABLE_IND,
      CALL_NUMBER =  NEW_REFERENCES.CALL_NUMBER,
      UNIT_SECTION_STATUS =  NEW_REFERENCES.UNIT_SECTION_STATUS,
      UNIT_SECTION_START_DATE =  NEW_REFERENCES.UNIT_SECTION_START_DATE,
      UNIT_SECTION_END_DATE =  NEW_REFERENCES.UNIT_SECTION_END_DATE,
      ENROLLMENT_ACTUAL =  NEW_REFERENCES.ENROLLMENT_ACTUAL,
      WAITLIST_ACTUAL =  NEW_REFERENCES.WAITLIST_ACTUAL,
      OFFERED_IND =  NEW_REFERENCES.OFFERED_IND,
      STATE_FINANCIAL_AID =  NEW_REFERENCES.STATE_FINANCIAL_AID,
      GRADING_SCHEMA_PRCDNCE_IND =  NEW_REFERENCES.GRADING_SCHEMA_PRCDNCE_IND,
      FEDERAL_FINANCIAL_AID =  NEW_REFERENCES.FEDERAL_FINANCIAL_AID,
      UNIT_QUOTA =  NEW_REFERENCES.UNIT_QUOTA,
      UNIT_QUOTA_RESERVED_PLACES =  NEW_REFERENCES.UNIT_QUOTA_RESERVED_PLACES,
      INSTITUTIONAL_FINANCIAL_AID =  NEW_REFERENCES.INSTITUTIONAL_FINANCIAL_AID,
      UNIT_CONTACT =  NEW_REFERENCES.UNIT_CONTACT,
      GRADING_SCHEMA_CD =  NEW_REFERENCES.GRADING_SCHEMA_CD,
      GS_VERSION_NUMBER =  NEW_REFERENCES.GS_VERSION_NUMBER,
      owner_org_unit_cd                 = new_references.owner_org_unit_cd,
      attendance_required_ind           = new_references.attendance_required_ind,
      reserved_seating_allowed          = new_references.reserved_seating_allowed,
      special_permission_ind            = new_references.special_permission_ind,
      ss_display_ind                    = new_references.ss_display_ind,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      REQUEST_ID = X_REQUEST_ID,
      PROGRAM_ID = X_PROGRAM_ID,
      PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
      SS_ENROL_IND = X_SS_ENROL_IND,
      DIR_ENROLLMENT = new_references.DIR_ENROLLMENT,
      ENR_FROM_WLST = new_references.ENR_FROM_WLST,
      INQ_NOT_WLST = new_references.INQ_NOT_WLST,
      rev_account_cd = new_references.rev_account_cd ,
      anon_unit_grading_ind = new_references.anon_unit_grading_ind ,
      anon_assess_grading_ind = new_references.anon_assess_grading_ind,
      NON_STD_USEC_IND = new_references.NON_STD_USEC_IND ,
      auditable_ind = new_references.auditable_ind,
      audit_permission_ind = new_references.audit_permission_ind,
      not_multiple_section_flag = new_references.not_multiple_section_flag,
      sup_uoo_id = new_references.sup_uoo_id,
      relation_type = new_references.relation_type,
      default_enroll_flag = new_references.default_enroll_flag,
      abort_flag= new_references.abort_flag
     where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
  --
  -- code added as part of waitlist part 1 build
  -- code is added to call the auto enroll process
  --
  DECLARE
      l_request_id   NUMBER;
      l_auto_enroll igs_en_inst_wl_stps.auto_enroll_waitlist_flag%TYPE;
      CURSOR cur_auto_enroll is
      SELECT auto_enroll_waitlist_flag
      FROM IGS_EN_INST_WL_STPS;
  BEGIN
    OPEN cur_auto_enroll;
    FETCH cur_auto_enroll INTO l_auto_enroll;
    CLOSE cur_auto_enroll;


    IF new_references.unit_section_status = 'HOLD'AND
        (old_references.unit_section_status <> 'HOLD' OR new_references.reserved_seating_allowed = 'Y') AND
        nvl(l_auto_enroll,'N') = 'Y' THEN

      l_request_id := FND_REQUEST.SUBMIT_REQUEST (
         application => 'IGS',
         program => 'IGSENJ04',
         description => 'Enroll Students From Waitlist Process',
         start_time => NULL,
         sub_request => FALSE,
         argument1 => new_references.uoo_id,
         argument2 => new_references.org_id,
         argument3 => chr(0),
         argument4  => '', argument5  => '', argument6  => '', argument7  => '', argument8  => '',
         argument9  => '', argument10 => '', argument11 => '', argument12 => '', argument13 => '',
         argument14 => '', argument15 => '', argument16 => '', argument17 => '', argument18 => '',
         argument19 => '', argument20 => '', argument21 => '', argument22 => '', argument23 => '',
         argument24 => '', argument25 => '', argument26 => '', argument27 => '', argument28 => '',
         argument29 => '', argument30 => '', argument31 => '', argument32 => '', argument33 => '',
         argument34 => '', argument35 => '', argument36 => '', argument37 => '', argument38 => '',
         argument39 => '', argument40 => '', argument41 => '', argument42 => '', argument43 => '',
         argument44 => '', argument45 => '', argument46 => '', argument47 => '', argument48 => '',
         argument49 => '', argument50 => '', argument51 => '', argument52 => '', argument53 => '',
         argument54 => '', argument55 => '', argument56 => '', argument57 => '', argument58 => '',
         argument59 => '', argument60 => '', argument61 => '', argument62 => '', argument63 => '',
         argument64 => '', argument65 => '', argument66 => '', argument67 => '', argument68 => '',
         argument69 => '', argument70 => '', argument71 => '', argument72 => '', argument73 => '',
         argument74 => '', argument75 => '', argument76 => '', argument77 => '', argument78 => '',
         argument79 => '', argument80 => '', argument81 => '', argument82 => '', argument83 => '',
         argument84 => '', argument85 => '', argument86 => '', argument87 => '', argument88 => '',
         argument89 => '', argument90 => '', argument91 => '', argument92 => '', argument93 => '',
         argument94 => '', argument95 => '', argument96 => '', argument97 => '', argument98 => '',
         argument99 => '', argument100 => '');

    END IF;
  END; -- end of code addition as part of waitlist part 1
  After_DML (
                p_action => 'UPDATE' ,
                x_rowid => X_ROWID );

end UPDATE_ROW;

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_LOCATION_CD IN VARCHAR2,
       x_UNIT_CLASS IN VARCHAR2,
       x_UOO_ID IN NUMBER,
       x_IVRS_AVAILABLE_IND IN VARCHAR2,
       x_CALL_NUMBER IN OUT NOCOPY NUMBER,
       x_UNIT_SECTION_STATUS IN VARCHAR2,
       x_UNIT_SECTION_START_DATE IN DATE,
       x_UNIT_SECTION_END_DATE IN DATE,
       x_ENROLLMENT_ACTUAL IN NUMBER,
       x_WAITLIST_ACTUAL IN NUMBER,
       x_OFFERED_IND IN VARCHAR2,
       x_STATE_FINANCIAL_AID IN VARCHAR2,
       x_GRADING_SCHEMA_PRCDNCE_IND IN VARCHAR2,
       x_FEDERAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_QUOTA IN NUMBER,
       x_UNIT_QUOTA_RESERVED_PLACES IN NUMBER,
       x_INSTITUTIONAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_CONTACT IN NUMBER,
       x_GRADING_SCHEMA_CD IN VARCHAR2,
       x_GS_VERSION_NUMBER IN NUMBER,
       x_owner_org_unit_cd                 IN     VARCHAR2 ,
       x_attendance_required_ind           IN     VARCHAR2 ,
       x_reserved_seating_allowed          IN     VARCHAR2 ,
       x_special_permission_ind            IN     VARCHAR2 ,
       x_ss_display_ind                    IN     VARCHAR2 ,
       X_MODE in VARCHAR2 ,
       X_ORG_ID IN NUMBER,
       x_SS_ENROL_IND IN VARCHAR2 ,
       x_dir_enrollment IN NUMBER ,
       x_enr_from_wlst  IN NUMBER ,
       x_inq_not_wlst  IN NUMBER ,
       x_rev_account_cd IN VARCHAR2 ,
       x_anon_unit_grading_ind IN VARCHAR2 ,
       x_anon_assess_grading_ind IN VARCHAR2 ,
       X_NON_STD_USEC_IND IN VARCHAR2 ,
       x_auditable_ind IN VARCHAR2,
       x_audit_permission_ind IN VARCHAR2,
       x_not_multiple_section_flag IN VARCHAR2,
       x_sup_uoo_id IN NUMBER ,
       x_relation_type VARCHAR2 ,
       x_default_enroll_flag VARCHAR2,
       x_abort_flag VARCHAR2

  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  vvutukur        05-Aug-2003     Enh#3045069.PSP Enh Build. Added column not_multiple_section_flag.
  shtatiko        06-NOV-2002     Added auditable_ind and audit_permission_ind
                                  as part of Bug# 2636716
  msrinivi        17 Aug-2001     Bug 1882122 : Added rev_account_cd
  rgangara        07-May-2001     Added ss_enrol_ind col
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PS_UNIT_OFR_OPT_ALL
             where     UNIT_CD= X_UNIT_CD
            and VERSION_NUMBER = X_VERSION_NUMBER
            and CAL_TYPE = X_CAL_TYPE
            and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
            and LOCATION_CD = X_LOCATION_CD
            and UNIT_CLASS = X_UNIT_CLASS
;
begin
        open c1;
                fetch c1 into X_ROWID;
        if (c1%notfound) then
        close c1;
    INSERT_ROW (
      X_ROWID,
       X_UNIT_CD,
       X_VERSION_NUMBER,
       X_CAL_TYPE,
       X_CI_SEQUENCE_NUMBER,
       X_LOCATION_CD,
       X_UNIT_CLASS,
       X_UOO_ID,
       X_IVRS_AVAILABLE_IND,
       X_CALL_NUMBER,
       X_UNIT_SECTION_STATUS,
       X_UNIT_SECTION_START_DATE,
       X_UNIT_SECTION_END_DATE,
       X_ENROLLMENT_ACTUAL,
       X_WAITLIST_ACTUAL,
       X_OFFERED_IND,
       X_STATE_FINANCIAL_AID,
       X_GRADING_SCHEMA_PRCDNCE_IND,
       X_FEDERAL_FINANCIAL_AID,
       X_UNIT_QUOTA,
       X_UNIT_QUOTA_RESERVED_PLACES,
       X_INSTITUTIONAL_FINANCIAL_AID,
       X_UNIT_CONTACT,
       X_GRADING_SCHEMA_CD,
       X_GS_VERSION_NUMBER,
       x_owner_org_unit_cd,
       x_attendance_required_ind,
       x_reserved_seating_allowed,
       x_special_permission_ind,
       x_ss_display_ind,
      X_MODE,
      X_ORG_ID,
      X_SS_ENROL_IND,
      X_DIR_ENROLLMENT,
      X_ENR_FROM_WLST,
      X_INQ_NOT_WLST,
      x_rev_account_cd ,
      x_anon_unit_grading_ind,
      x_anon_assess_grading_ind,
      X_NON_STD_USEC_IND,
      x_auditable_ind,
      x_audit_permission_ind,
      x_not_multiple_section_flag,
      x_sup_uoo_id,
      x_relation_type,
      x_default_enroll_flag,
      x_abort_flag
 );
     return;
        end if;
           close c1;
UPDATE_ROW (
      X_ROWID,
       X_UNIT_CD,
       X_VERSION_NUMBER,
       X_CAL_TYPE,
       X_CI_SEQUENCE_NUMBER,
       X_LOCATION_CD,
       X_UNIT_CLASS,
       X_UOO_ID,
       X_IVRS_AVAILABLE_IND,
       X_CALL_NUMBER,
       X_UNIT_SECTION_STATUS,
       X_UNIT_SECTION_START_DATE,
       X_UNIT_SECTION_END_DATE,
       X_ENROLLMENT_ACTUAL,
       X_WAITLIST_ACTUAL,
       X_OFFERED_IND,
       X_STATE_FINANCIAL_AID,
       X_GRADING_SCHEMA_PRCDNCE_IND,
       X_FEDERAL_FINANCIAL_AID,
       X_UNIT_QUOTA,
       X_UNIT_QUOTA_RESERVED_PLACES,
       X_INSTITUTIONAL_FINANCIAL_AID,
       X_UNIT_CONTACT,
       X_GRADING_SCHEMA_CD,
       X_GS_VERSION_NUMBER,
       x_owner_org_unit_cd,
       x_attendance_required_ind,
       x_reserved_seating_allowed,
       x_special_permission_ind,
       x_ss_display_ind,
       X_MODE,
       X_SS_ENROL_IND,
       X_DIR_ENROLLMENT,
       X_ENR_FROM_WLST,
       X_INQ_NOT_WLST,
       x_rev_account_cd,
       x_anon_unit_grading_ind,
       x_anon_assess_grading_ind,
       X_NON_STD_USEC_IND,
       x_auditable_ind,
       x_audit_permission_ind,
       x_not_multiple_section_flag,
       x_sup_uoo_id,
       x_relation_type,
       x_default_enroll_flag,
       x_abort_flag
);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
   Created By : kdande@in
   Date Created By : 2000/05/11
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

  delete from IGS_PS_UNIT_OFR_OPT_ALL
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
                p_action => 'DELETE' ,
                x_rowid => X_ROWID );

end DELETE_ROW;

end IGS_PS_UNIT_OFR_OPT_PKG;

/
