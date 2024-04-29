--------------------------------------------------------
--  DDL for Package Body IGS_EN_ELGB_OVR_UOO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ELGB_OVR_UOO_PKG" AS
/* $Header: IGSEI69B.pls 120.10 2006/05/25 10:29:50 amuthu ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_elgb_ovr_uoo%ROWTYPE;
  new_references igs_en_elgb_ovr_uoo%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_elgb_ovr_step_uoo_id              IN     NUMBER,
    x_elgb_ovr_step_id                  IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_step_override_limit               IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_en_elgb_ovr_uoo
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.elgb_ovr_step_uoo_id              := x_elgb_ovr_step_uoo_id;
    new_references.elgb_ovr_step_id                  := x_elgb_ovr_step_id;
    new_references.unit_cd                           := x_unit_cd;
    new_references.version_number                    := x_version_number;
    new_references.uoo_id                            := x_uoo_id;
    new_references.step_override_limit               := x_step_override_limit;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;
--
--Added As part of ENCR013 DLD
PROCEDURE enrp_val_appr_cr_pt AS
 /******************************************************************
  Created By        : knaraset
  Date Created By   : 12-Nov-2001
  Purpose           : This procedure updates Enrolled_Cp and achieveable_Cp in SUA record
                      when Approved Credit Points is created.
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who         When            What
  jbegum       25-Jun-2003    BUG#2930935 - Modified cursor cur_unit_ver.
                              Added the parameter p_uoo_id in the call to IGS_EN_PRC_LOAD.ENRP_CLC_SUA_LOAD
  rvivekan    18-Jun-2003    added reenroll step as per Reenrollmen and repeat enhacement.Modified cur_note_flag
                          cursor to accept step_group_type as a prameter too.
  smanglm      22-Jan-2003   call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
  svenkata     8-Jan-2003    Modified the message handling for eval_min_cp.
  Nishikant    01NOV2002     SEVIS Build. Enh Bug#2641905. notification flag was
                             being fetched from cursor, now modified to get it by
                             calling the function igs_ss_enr_details.get_notification.
  Nishikant   18-OCT-2002     The call to the function Igs_En_Elgbl_Program.eval_min_cp got modified since the signatue
                              got modified. Enrl Elgbl and Validation Build. Bug#2616692.
  mesriniv    12-sep-2002     Added a new parameter waitlist_manual_ind in update row of IGS_EN_SU_ATTEMPT
                              for  Bug 2554109 MINI Waitlist Build for Jan 03 Release
  ayedubat    11-APR-2002    Changed the cursor,cur_note_flag to add an extra 'OR'
                             condition(eru.s_student_comm_type = 'ALL') for s_student_comm_type as part of the bug fix: 2315245
  Nishikant   10-Oct-2001     Added the column session_id  in all Tbh calls of IGS_EN_SU_ATTEMPT_PKG
                             as a part of the bug 2172380.
  myoganat    16-JUN-2003   Bug# 2855870 Modified ENRP_VAL_APPR_CR_PT procedure by removing the IF clause
                                                 before the call to EVAL_MIN_CP and EVAL_MAX_CP. Profile IGS_EN_INCL_AUDIT_CP
                                                 was made obsolete. In the call to igs_en_val_sua.enrp_val_sua_ovrd_cp, the value of
                                                 no_assessment_ind was hardcoded to 'N'.
  rvangala    07-OCT-03    Passing core_indicator_code to IGS_EN_SUA-API.UPDATE_UNIT_ATTEMPT added as part of Prevent Dropping Core
                              Units. Enh Bug# 3052432
  stutta      21-NOV-2003   Replaced a program attempt cursor with a terms api function to return program version.
  vkarthik              22-Jul-2004     Added three dummy variables l_audit_cp, l_billing_cp, l_enrolled_cp for all the calls to
                                                igs_en_prc_load.enrp_clc_sua_load towards EN308 Billable credit points build Enh#3782329

  ******************************************************************/

  CURSOR cur_unit_ver(cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE)IS
  SELECT NVL(cps.enrolled_credit_points,uv.enrolled_credit_points)
  FROM igs_ps_unit_ver uv ,igs_ps_unit_ofr_opt uoo,igs_ps_usec_cps cps
  WHERE uoo.uoo_id = cps.uoo_id(+) AND
        uoo.unit_cd = uv.unit_cd AND
        uoo.version_number = uv.version_number AND
        uoo.uoo_id = cp_uoo_id;

  CURSOR cur_step_cal IS
  SELECT person_id,cal_type,ci_sequence_number
  FROM igs_en_elgb_ovr eo ,igs_en_elgb_ovr_step eos
  WHERE eos.elgb_override_id = eo.elgb_override_id AND
  eos.elgb_ovr_step_id = new_references.elgb_ovr_step_id;

  l_cur_step_cal_rec cur_step_cal%ROWTYPE;

  l_prg_ver igs_en_stdnt_ps_att.version_number%TYPE;
  -- Cursor to check whether the passed calendar is Teaching or not
  CURSOR cur_cal_cat(cp_cal_type VARCHAR2) IS
  SELECT 'x'
  FROM igs_ca_inst ci,
       igs_ca_type ct
  WHERE ci.cal_type = cp_cal_type AND
        ci.cal_type = ct.cal_type AND
        ct.s_cal_cat = 'TEACHING';
  l_cal_cat_rec cur_cal_cat%ROWTYPE;
  -- Cursor to fetch most recent active Term Calendar corresponding to the given teaching calendar
  CURSOR cur_teach_term(cp_cal_type VARCHAR2,cp_sequence_number NUMBER) IS
  SELECT load_cal_type,load_ci_sequence_number
  FROM igs_ca_teach_to_load_v
  WHERE teach_cal_type = cp_cal_type AND
        teach_ci_sequence_number = cp_sequence_number AND
        load_end_dt >= TRUNC(SYSDATE)
  ORDER BY load_start_dt ;
  l_teach_term_rec cur_teach_term%ROWTYPE;

  TYPE cur_sua_def IS REF CURSOR;

  -- bmerugu added for 4433428
  -- Cursor to get the coo_id of the student.
  CURSOR cur_coo_id (cp_person_id igs_en_stdnt_ps_att.person_id%TYPE, cp_program_cd igs_en_stdnt_ps_att.course_cd%TYPE) IS
  SELECT coo_id coo_id
  FROM   igs_en_stdnt_ps_att
  WHERE  person_id = cp_person_id
  AND    course_cd = cp_program_cd ;

  l_attendance_type_reach BOOLEAN := TRUE;
  l_cur_coo_id  cur_coo_id%ROWTYPE;
  l_attendance_types        VARCHAR2(100); -- As returned from the function igs_en_val_sca.enrp_val_coo_att

  l_deny_warn_min_cp VARCHAR2(10) DEFAULT NULL;
  l_deny_warn_max_cp VARCHAR2(10) DEFAULT NULL;
  l_deny_warn_cross_loc  VARCHAR2(10) DEFAULT NULL;
  l_deny_warn_cross_fac  VARCHAR2(10) DEFAULT NULL;
  l_deny_warn_cross_mod  VARCHAR2(10) DEFAULT NULL;
  l_deny_warn_att_type VARCHAR2(100) DEFAULT NULL;
  l_deny_warn_att_type1 VARCHAR2(100) DEFAULT NULL;
  l_deny_warn_reenroll VARCHAR2(100) DEFAULT NULL;

  -- bmerugu added for 4433428 planning sheet variables
  TYPE cur_plan_def IS REF CURSOR;
  cur_plan_def_var cur_sua_def; -- REF cursor variable
  cursor c_dummy is SELECT plan.rowid, plan.*
                           FROM igs_en_plan_units plan
                           WHERE plan.person_id = plan.person_id;
  cur_plan_def_var_rec c_dummy%ROWTYPE;
  l_plan_def_query VARCHAR2(4000);

  cur_sua_def_var cur_sua_def; -- REF cursor variable

    CURSOR c_dummy_cur (cp_person_id igs_en_su_attempt_all.person_id%TYPE
                     , cp_course_cd igs_en_su_attempt_all.course_cd%TYPE
                     , cp_uoo_id igs_en_su_attempt_all.uoo_id%TYPE)IS
  SELECT  sua.rowid row_id, sua.*
  FROM igs_en_su_attempt_all sua
  WHERE person_id = cp_person_id
  and course_cd = cp_course_cd
  and uoo_id = cp_uoo_id;
  cur_sua_def_var_rec c_dummy_cur%ROWTYPE;
  l_upd_credit_cp NUMBER := NULL;
  l_min_upd_credit_cp NUMBER := NULL;
  l_unit_cp igs_en_su_attempt.override_enrolled_cp%TYPE;
  l_message VARCHAR2(2000);
  l_sua_def_query VARCHAR2(4000);
  l_return_val BOOLEAN := FALSE;
  l_ret_status   VARCHAR2(10);
  l_enr_meth_type  igs_en_method_type.ENR_METHOD_TYPE%type;
  l_enr_comm igs_en_cpd_ext.s_student_comm_type%type;
  l_enr_cat igs_en_cpd_ext.enrolment_cat%type;
  l_enr_cal_type igs_ca_inst.cal_type%type;
  l_enr_ci_seq igs_ca_inst.sequence_number%type;
  cst_mincp varchar2(10) := 'FMAX_CRDT';
  cst_maxcp varchar2(10) := 'FMIN_CRDT';
  cst_fatd varchar2(10)  := 'FATD_TYPE';
  cst_crossfac varchar2(10) := 'CROSS_FAC';
  cst_crossmod varchar2(10) := 'CROSS_MOD';
  cst_crossloc varchar2(10) := 'CROSS_LOC';
  cst_reenroll varchar2(10) := 'REENROLL';
  cst_program varchar2(10) :='PROGRAM';
  cst_unit varchar2(10) :='UNIT';
  l_acad_cal_type igs_ca_inst.cal_type%type;
  l_acad_ci_sequence_number igs_ca_inst.sequence_number%type;
  l_acad_start_dt igs_ca_inst.start_dt%type;
  l_acad_end_dt igs_ca_inst.end_dt%type;
  l_alternate_code igs_ca_inst.alternate_code%type;
  l_acad_message varchar2(100);
  l_load_cal_type igs_ca_inst.cal_type%TYPE;
  l_load_sequence_number igs_ca_inst.sequence_number%TYPE;
  l_unit_incurred_cp NUMBER;
  l_dummy NUMBER;
  l_dummy_c VARCHAR2(2000);
  l_over_incurred_cp NUMBER;
  l_lim_incurred_cp NUMBER;
  -- Below local variable added as part of Enrl Elgbl and Validation Build. Bug#2616692
  l_min_credit_point igs_en_config_enr_cp.min_cp_per_term%TYPE := NULL;
  l_person_type  igs_pe_person_types.person_type_code%TYPE;--added by nishikant
  --dummy variable to pick up audit, billing, enrolled credit points
  --due to signature change by EN308 Billing credit hours #3782329
  l_audit_cp IGS_PS_USEC_CPS.billing_credit_points%TYPE;
  l_billing_cp IGS_PS_USEC_CPS.billing_hrs%TYPE;
  l_enrolled_cp IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;

BEGIN

  --
  --
     OPEN cur_step_cal;
     FETCH cur_step_cal INTO l_cur_step_cal_rec;
     CLOSE cur_step_cal;

  -- Override record defined at Unit Section level
  IF new_references.uoo_id <>-1 THEN
  -- fetch all Unit Atempts where sua.uoo_id = new_references.uoo_id
     l_sua_def_query := 'SELECT sua.rowid row_id, sua.*
                         FROM igs_en_su_attempt_all sua
                         WHERE unit_attempt_status IN (''ENROLLED'',''WAITLISTED'') AND uoo_id = :1 AND person_id = :2 AND no_assessment_ind<>''Y''';

     OPEN cur_sua_def_var FOR l_sua_def_query USING new_references.uoo_id, l_cur_step_cal_rec.person_id;

  -- Override record defined at Unit level
  ELSIF new_references.unit_cd IS NOT NULL THEN
  -- fetch all Unit Atempts where sua.unit_cd = new_references.unit_cd
     l_sua_def_query := 'SELECT sua.rowid row_id, sua.*
                         FROM igs_en_su_attempt_all sua
                         WHERE sua.unit_attempt_status IN (''ENROLLED'',''WAITLISTED'') AND sua.unit_cd = :1 AND sua.version_number = :2 AND person_id = :3 AND
                         ((sua.cal_type = :4 AND
                                  sua.ci_sequence_number = :5 ) OR
                                         ((sua.cal_type,sua.ci_sequence_number) IN
                                            (SELECT teach_cal_type,teach_ci_sequence_number
                                             FROM igs_ca_load_to_teach_v
                                             WHERE load_cal_type = :6  AND load_ci_sequence_number = :7 )))
                         AND  no_assessment_ind<>''Y''';

     OPEN cur_sua_def_var FOR l_sua_def_query USING new_references.unit_cd, new_references.version_number, l_cur_step_cal_rec.person_id,
            l_cur_step_cal_rec.cal_type, l_cur_step_cal_rec.ci_sequence_number,
            l_cur_step_cal_rec.cal_type, l_cur_step_cal_rec.ci_sequence_number;

  -- Override record defined at Teaching or Term calendar level
  ELSE

  -- fetch all Unit Atempts where sua teach cal type is equal to or sub ordinate to the Cal Type
  -- where Override record is defined.
     l_sua_def_query := 'SELECT  sua.rowid row_id, sua.*
                           FROM igs_en_su_attempt_all sua
                           WHERE sua.unit_attempt_status IN (''ENROLLED'',''WAITLISTED'') AND sua.person_id = :1 AND
                                  ((sua.cal_type = :2 AND
                                  sua.ci_sequence_number = :3 ) OR
                                         ((sua.cal_type,sua.ci_sequence_number) IN
                                            (SELECT teach_cal_type,teach_ci_sequence_number
                                             FROM igs_ca_load_to_teach_v
                                             WHERE load_cal_type = :4  AND load_ci_sequence_number = :5 ))) AND no_assessment_ind<>''Y''';

     OPEN cur_sua_def_var FOR l_sua_def_query USING l_cur_step_cal_rec.person_id, l_cur_step_cal_rec.cal_type, l_cur_step_cal_rec.ci_sequence_number,
            l_cur_step_cal_rec.cal_type, l_cur_step_cal_rec.ci_sequence_number;

  END IF;


  <<loop_sua_rec >> -- loop lable
  LOOP
     FETCH cur_sua_def_var INTO cur_sua_def_var_rec;
         EXIT WHEN cur_sua_def_var%NOTFOUND;

         -- Derive the Unit's CP
            OPEN cur_unit_ver(cur_sua_def_var_rec.uoo_id);
            FETCH cur_unit_ver INTO l_unit_cp;
            CLOSE cur_unit_ver;

         -- As the step can be overriden at Load as well as Teach calendars.
         OPEN cur_cal_cat(cur_sua_def_var_rec.cal_type);
         FETCH cur_cal_cat INTO l_cal_cat_rec;
         IF cur_cal_cat%FOUND THEN
         -- If defined at Teach level then deriving the Load Calendar as below.
           OPEN cur_teach_term(cur_sua_def_var_rec.cal_type,cur_sua_def_var_rec.ci_sequence_number);
           fetch cur_teach_term INTO l_teach_term_rec;
           CLOSE cur_teach_term;
           l_load_cal_type := l_teach_term_rec.load_cal_type;
           l_load_sequence_number := l_teach_term_rec.load_ci_sequence_number;
         ELSE
         -- Defined at Load Calendar level.
           l_load_cal_type := cur_sua_def_var_rec.cal_type;
           l_load_sequence_number := cur_sua_def_var_rec.ci_sequence_number;
         END IF;
         CLOSE cur_cal_cat;

         -- Calculate the value of the Parameter to be passed to Min_Cp/Max_Cp functions
         IF new_references.step_override_limit IS NULL THEN
            IF cur_sua_def_var_rec.override_enrolled_cp IS NOT NULL THEN
              -- When Approved Credit Points made NULL from NOT NULL
                  -- calculate CP incurred in the given Load calendar for Enrolled credit points.
                  -- These changes are done as part of bug 2401891.
                  l_unit_incurred_cp := Igs_En_Prc_Load.enrp_clc_sua_load(
                                                                  p_unit_cd => cur_sua_def_var_rec.unit_cd,
                                                                  p_version_number => cur_sua_def_var_rec.version_number,
                                                                  p_cal_type => cur_sua_def_var_rec.cal_type,
                                                                  p_ci_sequence_number => cur_sua_def_var_rec.ci_sequence_number,
                                                                  p_load_cal_type => l_load_cal_type,
                                                                  p_load_ci_sequence_number => l_load_sequence_number,
                                                                  p_override_enrolled_cp => l_unit_cp,
                                                                  p_override_eftsu => NULL,
                                                                  p_return_eftsu => l_dummy,
                                                                  p_uoo_id => cur_sua_def_var_rec.uoo_id,
                                                                  -- anilk, Audit special fee build
                                                                  p_include_as_audit => 'N',
                                                                  p_audit_cp => l_audit_cp,
                                                                  p_billing_cp => l_billing_cp,
                                                                  p_enrolled_cp => l_enrolled_cp);

                  -- calculate CP incurred in the given Load calendar for Override Enrolled credit points.
                  l_over_incurred_cp := Igs_En_Prc_Load.enrp_clc_sua_load(
                                                                  p_unit_cd => cur_sua_def_var_rec.unit_cd,
                                                                  p_version_number => cur_sua_def_var_rec.version_number,
                                                                  p_cal_type => cur_sua_def_var_rec.cal_type,
                                                                  p_ci_sequence_number => cur_sua_def_var_rec.ci_sequence_number,
                                                                  p_load_cal_type => l_load_cal_type,
                                                                  p_load_ci_sequence_number => l_load_sequence_number,
                                                                  p_override_enrolled_cp => cur_sua_def_var_rec.override_enrolled_cp,
                                                                  p_override_eftsu => NULL,
                                                                  p_return_eftsu => l_dummy,
                                                                  p_uoo_id => cur_sua_def_var_rec.uoo_id,
                                                                  -- anilk, Audit special fee build
                                                                  p_include_as_audit => 'N',
                                                                  p_audit_cp => l_audit_cp,
                                                                  p_billing_cp => l_billing_cp,
                                                                  p_enrolled_cp => l_enrolled_cp);

              -- l_upd_credit_cp := l_unit_cp - cur_sua_def_var_rec.override_enrolled_cp;
              l_upd_credit_cp := l_unit_incurred_cp - l_over_incurred_cp;
            END IF;
         ELSE
                  -- calculate CP incurred in the given Load calendar for Step Override Limit.
                  l_lim_incurred_cp := Igs_En_Prc_Load.enrp_clc_sua_load(
                                                                  p_unit_cd => cur_sua_def_var_rec.unit_cd,
                                                                  p_version_number => cur_sua_def_var_rec.version_number,
                                                                  p_cal_type => cur_sua_def_var_rec.cal_type,
                                                                  p_ci_sequence_number => cur_sua_def_var_rec.ci_sequence_number,
                                                                  p_load_cal_type => l_load_cal_type,
                                                                  p_load_ci_sequence_number => l_load_sequence_number,
                                                                  p_override_enrolled_cp => new_references.step_override_limit,
                                                                  p_override_eftsu => NULL,
                                                                  p_return_eftsu => l_dummy,
                                                                  p_uoo_id => cur_sua_def_var_rec.uoo_id,
                                                                  -- anilk, Audit special fee build
                                                                  p_include_as_audit => 'N',
                                                                  p_audit_cp => l_audit_cp,
                                                                  p_billing_cp => l_billing_cp,
                                                                  p_enrolled_cp => l_enrolled_cp);

                  -- calculate CP incurred in the given Load calendar for Override/Enrolled credit points.
                  l_over_incurred_cp := Igs_En_Prc_Load.enrp_clc_sua_load(
                                                                  p_unit_cd => cur_sua_def_var_rec.unit_cd,
                                                                  p_version_number => cur_sua_def_var_rec.version_number,
                                                                  p_cal_type => cur_sua_def_var_rec.cal_type,
                                                                  p_ci_sequence_number => cur_sua_def_var_rec.ci_sequence_number,
                                                                  p_load_cal_type => l_load_cal_type,
                                                                  p_load_ci_sequence_number => l_load_sequence_number,
                                                                  p_override_enrolled_cp => NVL(cur_sua_def_var_rec.override_enrolled_cp,l_unit_cp),
                                                                  p_override_eftsu => NULL,
                                                                  p_return_eftsu => l_dummy,
                                                                  p_uoo_id => cur_sua_def_var_rec.uoo_id,
                                                                  -- anilk, Audit special fee build
                                                                  p_include_as_audit => 'N',
                                                                  p_audit_cp => l_audit_cp,
                                                                  p_billing_cp => l_billing_cp,
                                                                  p_enrolled_cp => l_enrolled_cp);

            --l_upd_credit_cp :=  new_references.step_override_limit - NVL(cur_sua_def_var_rec.override_enrolled_cp,l_unit_cp);
            l_upd_credit_cp :=  l_lim_incurred_cp - l_over_incurred_cp;
         END IF;
         --
         -- Get the version of the program in context
         l_prg_ver := igs_en_spa_terms_api.get_spat_program_version(  p_person_id => cur_sua_def_var_rec.person_id,
                                        p_program_cd => cur_sua_def_var_rec.course_cd,
                                        p_term_cal_type => l_load_cal_type,
                                        p_term_sequence_number => l_load_sequence_number);
          -- added below logic to get the Academic Calendar which is used by method enrp_get_enr_cat
          --
          -- get the academic calendar of the given Load Calendar
          --
          l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                                p_cal_type                => l_cur_step_cal_rec.cal_type,
                                p_ci_sequence_number      => l_cur_step_cal_rec.ci_sequence_number,
                                p_acad_cal_type           => l_acad_cal_type,
                                p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                                p_acad_ci_start_dt        => l_acad_start_dt,
                                p_acad_ci_end_dt          => l_acad_end_dt,
                                p_message_name            => l_acad_message );

            IF l_acad_message IS NOT NULL THEN
                 Fnd_Message.Set_Name ('IGS',l_acad_message );
                 IGS_GE_MSG_STACK.ADD;
                 App_Exception.Raise_Exception;
            END IF;

         --
         -- Get Enrollment Category, Commencement Type and Enrollemnt Method
         --
          l_dummy_c := NULL;
          l_enr_cat := igs_en_gen_003.enrp_get_enr_cat(
                          cur_sua_def_var_rec.person_id,
                          cur_sua_def_var_rec.course_cd,
                          l_acad_cal_type,
                          l_acad_ci_sequence_number,
                          NULL,
                          l_enr_cal_type,
                          l_enr_ci_seq,
                          l_enr_comm,
                          l_dummy_c);

          IF l_enr_comm = 'BOTH' THEN
             l_enr_comm :='ALL';
          END IF;

          -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
          igs_en_gen_017.enrp_get_enr_method(
               p_enr_method_type => l_enr_meth_type,
               p_error_message   => l_message,
               p_ret_status      => l_ret_status);
          l_person_type := Igs_En_Gen_008.enrp_get_person_type(NULL);

			l_message := NULL;
			l_deny_warn_min_cp := igs_ss_enr_details.get_notification(
					 p_person_type         => l_person_type,
					 p_enrollment_category => l_enr_cat,
					 p_comm_type           => l_enr_comm,
					 p_enr_method_type     => l_enr_meth_type,
					 p_step_group_type     => cst_program,
					 p_step_type           => cst_mincp,
					 p_person_id           => cur_sua_def_var_rec.person_id,
					 p_message             => l_message);
			IF l_message IS NOT NULL THEN
				fnd_message.set_name ('IGS', l_message);
				igs_ge_msg_stack.add;
				app_exception.raise_exception;
			END IF;
			l_min_upd_credit_cp := l_upd_credit_cp;
			-- The Four parameters p_enrollment_category, p_comm_type, p_method_type, p_min_credit_point
			-- added in the below function call, as part of Enrl Elgbl and Validation Build. Bug#2616692
			IF l_deny_warn_min_cp ='DENY' AND NOT igs_en_elgbl_program.eval_min_cp(p_person_id => cur_sua_def_var_rec.person_id,
									 p_load_calendar_type => l_cur_step_cal_rec.cal_type,
									 p_load_cal_sequence_number => l_cur_step_cal_rec.ci_sequence_number,
									 p_uoo_id => cur_sua_def_var_rec.uoo_id,
									 p_program_cd => cur_sua_def_var_rec.course_cd,
									 p_program_version => l_prg_ver,
									 p_message => l_message,
									 p_deny_warn => l_deny_warn_min_cp,
									 p_credit_points => l_min_upd_credit_cp ,
									 p_enrollment_category => l_enr_cat,
									 p_comm_type  => l_enr_comm,
									 p_method_type => l_enr_meth_type,
									 p_min_credit_point => l_min_credit_point,
									 p_calling_obj      => 'JOB'
								   ) AND  l_message = 'IGS_SS_DENY_MIN_CP_REACHED' THEN
				 Fnd_Message.Set_Name ('IGS',l_message );
				 IGS_GE_MSG_STACK.ADD;
				 App_Exception.Raise_Exception;
			END IF;

			l_message := NULL;
			l_deny_warn_max_cp := igs_ss_enr_details.get_notification(
								 p_person_type         => l_person_type,
								 p_enrollment_category => l_enr_cat,
								 p_comm_type           => l_enr_comm,
								 p_enr_method_type     => l_enr_meth_type,
								 p_step_group_type     => cst_program,
								 p_step_type           => cst_maxcp,
								 p_person_id           => cur_sua_def_var_rec.person_id,
								 p_message             => l_message);
			IF l_message IS NOT NULL THEN
			  fnd_message.set_name ('IGS', l_message);
			  igs_ge_msg_stack.add;
			  app_exception.raise_exception;
			END IF;
			IF  l_deny_warn_max_cp ='DENY' AND  NOT igs_en_elgbl_program.eval_max_cp (
							p_person_id => cur_sua_def_var_rec.person_id,
							p_load_calendar_type => l_cur_step_cal_rec.cal_type,
							p_load_cal_sequence_number => l_cur_step_cal_rec.ci_sequence_number,
							p_uoo_id => cur_sua_def_var_rec.uoo_id,
							p_program_cd => cur_sua_def_var_rec.course_cd,
							p_program_version => l_prg_ver,
							p_message => l_message,
							p_deny_warn => l_deny_warn_max_cp,
							p_upd_cp => l_upd_credit_cp,
							p_calling_obj      => 'JOB') THEN
				Fnd_Message.Set_Name ('IGS',l_message );
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
			END IF;
--------------------------------------------------------------------------------------------------------------------------------------------
			l_message := NULL;
			l_deny_warn_reenroll := igs_ss_enr_details.get_notification(
								 p_person_type         => l_person_type,
								 p_enrollment_category => l_enr_cat,
								 p_comm_type           => l_enr_comm,
								 p_enr_method_type     => l_enr_meth_type,
								 p_step_group_type     => cst_unit,
								 p_step_type           => cst_reenroll,
								 p_person_id           => cur_sua_def_var_rec.person_id,
								 p_message             => l_message);
			IF l_message IS NOT NULL THEN
			  fnd_message.set_name ('IGS', l_message);
			  igs_ge_msg_stack.add;
			  app_exception.raise_exception;
			END IF;
			IF  l_deny_warn_reenroll ='DENY' AND  NOT igs_en_elgbl_unit.eval_unit_reenroll (
					p_person_id => cur_sua_def_var_rec.person_id,
					p_load_cal_type => l_cur_step_cal_rec.cal_type,
					p_load_cal_seq_number => l_cur_step_cal_rec.ci_sequence_number,
					p_uoo_id => cur_sua_def_var_rec.uoo_id,
					p_program_cd => cur_sua_def_var_rec.course_cd,
					p_program_version => l_prg_ver,
					p_message => l_message,
					p_deny_warn => l_deny_warn_reenroll,
					p_upd_cp => new_references.step_override_limit - NVL(cur_sua_def_var_rec.override_enrolled_cp,l_unit_cp),
					p_val_level => 'CREDIT_POINT',
					p_calling_obj => 'JOB') THEN
				Fnd_Message.Set_Name ('IGS',l_message );
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
			END IF;

            -- smaddali added the check that message <> IGS_EN_OVERRIDE_EFTSU_VALUES for EN317 build
            -- because credit approval can be provided even for a unit which doesnt allow overriding of cp
           IF NOT igs_en_val_sua.enrp_val_sua_ovrd_cp(
                p_unit_cd => cur_sua_def_var_rec.unit_cd,
                p_version_number => cur_sua_def_var_rec.version_number ,
                p_override_enrolled_cp => new_references.step_override_limit ,
                p_override_achievable_cp => NULL ,
                p_override_eftsu => NULL ,
                p_message_name => l_message,
                p_uoo_id => cur_sua_def_var_rec.uoo_id,
                p_no_assessment_ind => 'N' ) AND l_message <> 'IGS_EN_OVERRIDE_EFTSU_VALUES' THEN
                            Fnd_Message.Set_Name ('IGS',l_message );
                            IGS_GE_MSG_STACK.ADD;
                            App_Exception.Raise_Exception;
           END IF;

		  -- bmerugu added for 4433428
			l_message := NULL;
			l_deny_warn_att_type  := igs_ss_enr_details.get_notification(
			p_person_type               => l_person_type,
			p_enrollment_category       => l_enr_cat,
			p_comm_type                 => l_enr_comm,
			p_enr_method_type           => l_enr_meth_type,
			p_step_group_type           => cst_program,
			p_step_type                 => cst_fatd,
			p_person_id                 => cur_sua_def_var_rec.person_id,
			p_message                   => l_message
			) ;
			IF l_message IS NOT NULL THEN
				fnd_message.set_name ('IGS', l_message);
				igs_ge_msg_stack.add;
				app_exception.raise_exception;
			END IF;

			l_message := NULL;
			l_deny_warn_cross_loc  := igs_ss_enr_details.get_notification(
			p_person_type               => l_person_type,
			p_enrollment_category       => l_enr_cat,
			p_comm_type                 => l_enr_comm,
			p_enr_method_type           => l_enr_meth_type,
			p_step_group_type           => cst_program,
			p_step_type                 => cst_crossloc,
			p_person_id                 => cur_sua_def_var_rec.person_id,
			p_message                   => l_message
			) ;
			IF l_message IS NOT NULL THEN
				fnd_message.set_name ('IGS', l_message);
				igs_ge_msg_stack.add;
				app_exception.raise_exception;
			END IF;

			l_message := NULL;
			l_deny_warn_cross_mod  := igs_ss_enr_details.get_notification(
			p_person_type               => l_person_type,
			p_enrollment_category       => l_enr_cat,
			p_comm_type                 => l_enr_comm,
			p_enr_method_type           => l_enr_meth_type,
			p_step_group_type           => cst_program,
			p_step_type                 => cst_crossmod,
			p_person_id                 => cur_sua_def_var_rec.person_id,
			p_message                   => l_message
			) ;
			IF l_message IS NOT NULL THEN
				fnd_message.set_name ('IGS', l_message);
				igs_ge_msg_stack.add;
				app_exception.raise_exception;
			END IF;

			l_message := NULL;
			l_deny_warn_cross_fac  := igs_ss_enr_details.get_notification(
			p_person_type               => l_person_type,
			p_enrollment_category       => l_enr_cat,
			p_comm_type                 => l_enr_comm,
			p_enr_method_type           => l_enr_meth_type,
			p_step_group_type           => cst_program,
			p_step_type                 => cst_crossfac,
			p_person_id                 => cur_sua_def_var_rec.person_id,
			p_message                   => l_message
			) ;
			IF l_message IS NOT NULL THEN
				fnd_message.set_name ('IGS', l_message);
				igs_ge_msg_stack.add;
				app_exception.raise_exception;
			END IF;

         IF l_deny_warn_att_type ='DENY' THEN
              -- bmerugu added for 4433428
              OPEN  cur_coo_id(cur_sua_def_var_rec.person_id, cur_sua_def_var_rec.course_cd);
              FETCH cur_coo_id INTO l_cur_coo_id;
              CLOSE cur_coo_id;
              l_message := NULL;

              --Modified as a part of bug#5191592
              -- Check if the Forced Attendance Type has already been reached for the Student before transferring .
              l_attendance_type_reach := igs_en_val_sca.enrp_val_coo_att(p_person_id          => cur_sua_def_var_rec.person_id,
                  p_coo_id             => l_cur_coo_id.coo_id,
                  p_cal_type           => l_acad_cal_type,
                  p_ci_sequence_number => l_acad_ci_sequence_number,
                  p_message_name       => l_message,
                  p_attendance_types   => l_attendance_types,
                  p_load_or_teach_cal_type => cur_sua_def_var_rec.cal_type,
                  p_load_or_teach_seq_number =>cur_sua_def_var_rec.ci_sequence_number);

                  -- Assign values to the parameter p_deny_warn_att based on if Attendance Type has not been already reached or not.
              IF l_attendance_type_reach THEN
                  l_deny_warn_att_type1  := 'AttTypReached' ;
              ELSE
                  l_deny_warn_att_type1  := 'AttTypNotReached' ;
              END IF ;
        END IF;

        igs_en_sua_api.update_unit_attempt (
                                        X_ROWID                        =>     cur_sua_def_var_rec.row_id                         ,
                                        X_PERSON_ID                    =>     cur_sua_def_var_rec.person_id                      ,
                                        X_COURSE_CD                    =>     cur_sua_def_var_rec.course_cd                      ,
                                        X_UNIT_CD                      =>     cur_sua_def_var_rec.unit_cd                        ,
                                        X_CAL_TYPE                     =>     cur_sua_def_var_rec.cal_type                       ,
                                        X_CI_SEQUENCE_NUMBER           =>     cur_sua_def_var_rec.ci_sequence_number             ,
                                        X_VERSION_NUMBER               =>     cur_sua_def_var_rec.version_number                 ,
                                        X_LOCATION_CD                  =>     cur_sua_def_var_rec.location_cd                    ,
                                        X_UNIT_CLASS                   =>     cur_sua_def_var_rec.unit_class                     ,
                                        X_CI_START_DT                  =>     cur_sua_def_var_rec.ci_start_dt                    ,
                                        X_CI_END_DT                    =>     cur_sua_def_var_rec.ci_end_dt                      ,
                                        X_UOO_ID                       =>     cur_sua_def_var_rec.uoo_id                         ,
                                        X_ENROLLED_DT                  =>     cur_sua_def_var_rec.enrolled_dt                    ,
                                        X_UNIT_ATTEMPT_STATUS          =>     cur_sua_def_var_rec.unit_attempt_status            ,
                                        X_ADMINISTRATIVE_UNIT_STATUS   =>     cur_sua_def_var_rec.administrative_unit_status     ,
                                        X_DISCONTINUED_DT              =>     cur_sua_def_var_rec.discontinued_dt                ,
                                        X_RULE_WAIVED_DT               =>     cur_sua_def_var_rec.rule_waived_dt                 ,
                                        X_RULE_WAIVED_PERSON_ID        =>     cur_sua_def_var_rec.rule_waived_person_id          ,
                                        X_NO_ASSESSMENT_IND            =>     cur_sua_def_var_rec.no_assessment_ind              ,
                                        X_SUP_UNIT_CD                  =>     cur_sua_def_var_rec.sup_unit_cd                    ,
                                        X_SUP_VERSION_NUMBER           =>     cur_sua_def_var_rec.sup_version_number             ,
                                        X_EXAM_LOCATION_CD             =>     cur_sua_def_var_rec.exam_location_cd               ,
                                        X_ALTERNATIVE_TITLE            =>     cur_sua_def_var_rec.alternative_title              ,
                                        X_OVERRIDE_ENROLLED_CP         =>     new_references.step_override_limit           ,
                                        X_OVERRIDE_EFTSU               =>     cur_sua_def_var_rec.override_eftsu                 ,
                                        -- as part of ENCR026 Changed the below col value. The new value was being
                                        -- set to the override limit, now setting to the original value in the db and not changing it
                                        X_OVERRIDE_ACHIEVABLE_CP       =>     cur_sua_def_var_rec.override_achievable_cp         ,
                                        X_OVERRIDE_OUTCOME_DUE_DT      =>     cur_sua_def_var_rec.override_outcome_due_dt        ,
                                        X_OVERRIDE_CREDIT_REASON       =>     cur_sua_def_var_rec.override_credit_reason         ,
                                        X_ADMINISTRATIVE_PRIORITY      =>     cur_sua_def_var_rec.administrative_priority        ,
                                        X_WAITLIST_DT                  =>     cur_sua_def_var_rec.waitlist_dt                    ,
                                        X_DCNT_REASON_CD               =>     cur_sua_def_var_rec.dcnt_reason_cd                 ,
                                        X_MODE                         =>     'R'                                                ,
                                        X_GS_VERSION_NUMBER            =>     cur_sua_def_var_rec.gs_version_number              ,
                                        X_ENR_METHOD_TYPE              =>     cur_sua_def_var_rec.enr_method_type                ,
                                        X_FAILED_UNIT_RULE             =>     cur_sua_def_var_rec.failed_unit_rule               ,
                                        X_CART                         =>     cur_sua_def_var_rec.cart                           ,
                                        X_RSV_SEAT_EXT_ID              =>     cur_sua_def_var_rec.RSV_SEAT_EXT_ID ,
                                        X_ORG_UNIT_CD                  =>     cur_sua_def_var_rec.ORG_UNIT_CD,
                                        -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                        X_SESSION_ID                   =>     cur_sua_def_var_rec.session_id,
                                        X_DEG_AUD_DETAIL_ID            =>     cur_sua_def_var_rec.deg_aud_detail_id,
                                        X_GRADING_SCHEMA_CODE          =>     cur_sua_def_var_rec.grading_schema_code,
                                        X_STUDENT_CAREER_STATISTICS    =>     cur_sua_def_var_rec.student_career_statistics,
                                        X_STUDENT_CAREER_TRANSCRIPT    =>     cur_sua_def_var_rec.student_career_transcript,
                                        X_SUBTITLE                     =>     cur_sua_def_var_rec.subtitle              ,
                                        X_ATTRIBUTE_CATEGORY           =>     cur_sua_def_var_rec.attribute_category,
                                        X_ATTRIBUTE1                   =>     cur_sua_def_var_rec.attribute1,
                                        X_ATTRIBUTE2                   =>     cur_sua_def_var_rec.attribute2,
                                        X_ATTRIBUTE3                   =>     cur_sua_def_var_rec.attribute3,
                                        X_ATTRIBUTE4                   =>     cur_sua_def_var_rec.attribute4,
                                        X_ATTRIBUTE5                   =>     cur_sua_def_var_rec.attribute5,
                                        X_ATTRIBUTE6                   =>     cur_sua_def_var_rec.attribute6,
                                        X_ATTRIBUTE7                   =>     cur_sua_def_var_rec.attribute7,
                                        X_ATTRIBUTE8                   =>     cur_sua_def_var_rec.attribute8,
                                        X_ATTRIBUTE9                   =>     cur_sua_def_var_rec.attribute9,
                                        X_ATTRIBUTE10                  =>     cur_sua_def_var_rec.attribute10,
                                        X_ATTRIBUTE11                  =>     cur_sua_def_var_rec.attribute11,
                                        X_ATTRIBUTE12                  =>     cur_sua_def_var_rec.attribute12,
                                        X_ATTRIBUTE13                  =>     cur_sua_def_var_rec.attribute13,
                                        X_ATTRIBUTE14                  =>     cur_sua_def_var_rec.attribute14,
                                        X_ATTRIBUTE15                  =>     cur_sua_def_var_rec.attribute15,
                                        X_ATTRIBUTE16                  =>     cur_sua_def_var_rec.attribute16,
                                        X_ATTRIBUTE17                  =>     cur_sua_def_var_rec.attribute17,
                                        X_ATTRIBUTE18                  =>     cur_sua_def_var_rec.attribute18,
                                        X_ATTRIBUTE19                  =>     cur_sua_def_var_rec.attribute19,
                                        X_ATTRIBUTE20                  =>     cur_sua_def_var_rec.attribute20,
                                        X_WAITLIST_MANUAL_IND          =>     cur_sua_def_var_rec.waitlist_manual_ind ,--Added by mesriniv for Bug 2554109 Mini Waitlist Build.,
                                        X_WLST_PRIORITY_WEIGHT_NUM     =>     cur_sua_def_var_rec.wlst_priority_weight_num,
                                        X_WLST_PREFERENCE_WEIGHT_NUM   =>     cur_sua_def_var_rec.wlst_preference_weight_num,
                                        -- CORE_INDICATOR_CODE --added by rvangala 07-OCT-2003. Enh Bug# 3052432
                                        X_CORE_INDICATOR_CODE          =>     cur_sua_def_var_rec.core_indicator_code
                                   ) ;


        l_message := NULL;
		IF l_deny_warn_att_type='DENY' AND NOT igs_en_elgbl_program.eval_unit_forced_type(
											  p_person_id                 => cur_sua_def_var_rec.person_id,
											  p_load_calendar_type        => l_load_cal_type,
											  p_load_cal_sequence_number  => l_load_sequence_number,
											  p_uoo_id                    => cur_sua_def_var_rec.uoo_id,
											  p_course_cd                 => cur_sua_def_var_rec.course_cd,
											  p_course_version            => l_prg_ver,
											  p_message                   => l_message,
											  p_deny_warn                 => l_deny_warn_att_type1 ,
											  p_enrollment_category       => l_enr_cat,
											  p_comm_type                 => l_enr_comm,
											  p_method_type               => l_enr_meth_type,
											  p_calling_obj               => 'JOB' ) THEN

				Fnd_Message.Set_Name ('IGS',l_message );
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF ;

        l_message := NULL;
		IF l_deny_warn_cross_fac ='DENY' AND  NOT igs_en_elgbl_program.eval_cross_validation (
											 p_person_id                 =>  cur_sua_def_var_rec.person_id,
											 p_load_cal_type             =>  l_load_cal_type,
											 p_load_ci_sequence_number   =>  l_load_sequence_number,
											 p_uoo_id                    =>  cur_sua_def_var_rec.uoo_id,
											 p_course_cd                 =>  cur_sua_def_var_rec.course_cd,
											 p_program_version           =>  l_prg_ver,
											 p_message                   =>  l_message,
											 p_deny_warn                 =>  l_deny_warn_cross_fac,
											 p_upd_cp                    =>  NULL ,
											 p_eligibility_step_type     =>  cst_crossfac,
											 p_calling_obj               => 'JOB' ) THEN
				Fnd_Message.Set_Name ('IGS',l_message );
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF ;

        l_message := NULL;
		IF l_deny_warn_cross_mod ='DENY' AND NOT igs_en_elgbl_program.eval_cross_validation (
										 p_person_id                 =>  cur_sua_def_var_rec.person_id,
										 p_load_cal_type             =>  l_load_cal_type,
										 p_load_ci_sequence_number   =>  l_load_sequence_number,
										 p_uoo_id                    =>  cur_sua_def_var_rec.uoo_id,
										 p_course_cd                 =>  cur_sua_def_var_rec.course_cd,
										 p_program_version           =>  l_prg_ver,
										 p_message                   =>  l_message,
										 p_deny_warn                 =>  l_deny_warn_cross_mod,
										 p_upd_cp                    =>  NULL ,
										 p_eligibility_step_type     =>  cst_crossmod,
										 p_calling_obj               => 'JOB' ) THEN

				Fnd_Message.Set_Name ('IGS',l_message );
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF ;

        l_message := NULL;
		IF l_deny_warn_cross_loc ='DENY' AND NOT igs_en_elgbl_program.eval_cross_validation (
										 p_person_id                 =>  cur_sua_def_var_rec.person_id,
										 p_load_cal_type             =>  l_load_cal_type,
										 p_load_ci_sequence_number   =>  l_load_sequence_number,
										 p_uoo_id                    =>  cur_sua_def_var_rec.uoo_id,
										 p_course_cd                 =>  cur_sua_def_var_rec.course_cd,
										 p_program_version           =>  l_prg_ver,
										 p_message                   =>  l_message,
										 p_deny_warn                 =>  l_deny_warn_cross_loc,
										 p_upd_cp                    =>  NULL ,
										 p_eligibility_step_type     =>  cst_crossloc,
										 p_calling_obj               => 'JOB') THEN

				Fnd_Message.Set_Name ('IGS',l_message );
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF ;

  END LOOP loop_sua_rec;

  -- bmerugu added for 4433428
  -- update all the active planning sheet records for this person with the approved cp
  -- Override record defined at Unit Section level
  IF new_references.uoo_id <> -1 THEN
	 -- fetch all plan unit Atempts where plan.uoo_id = new_references.uoo_id
     l_plan_def_query := 'SELECT plan.rowid, plan.*
                         FROM igs_en_plan_units plan
                         WHERE plan.uoo_id = :1 AND plan.person_id = :2
							AND plan.no_assessment_ind <> ''Y''
							AND EXISTS(SELECT ''x'' FROM  igs_en_spa_terms spa
									where spa.person_id=plan.person_id
									and   spa.program_cd=plan.course_cd
									and   spa.term_cal_type=plan.term_cal_type
									and   spa.term_sequence_number=plan.term_ci_sequence_number
									and   spa.plan_sht_status IN (''PLAN'',''NONE''))
									';
     OPEN cur_plan_def_var FOR l_plan_def_query USING new_references.uoo_id, l_cur_step_cal_rec.person_id;
  -- Override record defined at Unit level
  ELSIF new_references.unit_cd IS NOT NULL THEN
	 -- fetch all plan unit attempts for the student with matching unit_cd
     l_plan_def_query := 'SELECT plan.rowid,plan.*
                         FROM igs_en_plan_units plan , igs_ps_unit_ofr_opt_all b
                         WHERE plan.person_id = :1
						 AND plan.uoo_id = b.uoo_id
						 AND b.unit_cd = :2 AND b.version_number = :3
						   AND plan.no_assessment_ind <> ''Y''
                            AND ((plan.term_cal_type = :4 AND
                                    plan.term_ci_sequence_number = :5 ) OR
                                         ((plan.term_cal_type,plan.term_ci_sequence_number) IN
                                            (SELECT load_cal_type,load_ci_sequence_number
                                             FROM igs_ca_teach_to_load_v
                                             WHERE teach_cal_type = :6  AND teach_ci_sequence_number = :7 )))
						   AND EXISTS(SELECT ''x'' FROM  igs_en_spa_terms spa
								where spa.person_id=plan.person_id
								and   spa.program_cd=plan.course_cd
								and   spa.term_cal_type=plan.term_cal_type
								and   spa.term_sequence_number=plan.term_ci_sequence_number
								and   spa.plan_sht_status IN (''PLAN'',''NONE''))
							';
	 OPEN cur_plan_def_var FOR l_plan_def_query USING l_cur_step_cal_rec.person_id,new_references.unit_cd, new_references.version_number,
      l_cur_step_cal_rec.cal_type, l_cur_step_cal_rec.ci_sequence_number,
     l_cur_step_cal_rec.cal_type, l_cur_step_cal_rec.ci_sequence_number;
  -- Override record defined at Teaching or Term calendar level
  ELSE
		-- fetch all plan Unit Atempts where sua teach cal type is equal to or sub ordinate to the Cal Type
		-- where Override record is defined.
     l_plan_def_query := 'SELECT DISTINCT plan.rowid, plan.*
                           FROM igs_en_plan_units plan
                           WHERE plan.person_id = :1
								AND plan.no_assessment_ind <> ''Y''
                                AND ((plan.term_cal_type = :2 AND
                                    plan.term_ci_sequence_number = :3 ) OR
                                         ((plan.term_cal_type,plan.term_ci_sequence_number) IN
                                            (SELECT load_cal_type,load_ci_sequence_number
                                             FROM igs_ca_teach_to_load_v
                                             WHERE teach_cal_type = :4  AND teach_ci_sequence_number = :5 )))
								AND   EXISTS(SELECT ''x'' FROM  igs_en_spa_terms spa
								WHERE spa.person_id=plan.person_id
								and   spa.program_cd=plan.course_cd
								and   spa.term_cal_type=plan.term_cal_type
								and   spa.term_sequence_number=plan.term_ci_sequence_number
								and   spa.plan_sht_status IN (''PLAN'',''NONE''))
								';
     OPEN cur_plan_def_var FOR l_plan_def_query USING l_cur_step_cal_rec.person_id, l_cur_step_cal_rec.cal_type, l_cur_step_cal_rec.ci_sequence_number,
     l_cur_step_cal_rec.cal_type, l_cur_step_cal_rec.ci_sequence_number;
  END IF;
  <<loop_plan_rec >> -- loop lable
  LOOP
		FETCH cur_plan_def_var INTO cur_plan_def_var_rec;
			 EXIT WHEN cur_plan_def_var%NOTFOUND;
		 -- call IGS_EN_PLAN_UNITS_PKG.UPDATE_ROW
		   igs_en_plan_units_pkg.update_row(
			x_rowid                    => cur_plan_def_var_rec.rowid,
			x_person_id                => cur_plan_def_var_rec.person_id,
			x_course_cd                => cur_plan_def_var_rec.course_cd,
			x_uoo_id                   => cur_plan_def_var_rec.uoo_id,
			x_term_cal_type            => cur_plan_def_var_rec.term_cal_type,
			x_term_ci_sequence_number  => cur_plan_def_var_rec.term_ci_sequence_number,
			x_no_assessment_ind        => cur_plan_def_var_rec.no_assessment_ind,
			x_sup_uoo_id               => cur_plan_def_var_rec.sup_uoo_id,
			x_override_enrolled_cp     => new_references.step_override_limit,
			x_grading_schema_code      => cur_plan_def_var_rec.grading_schema_code,
			x_gs_version_number        => cur_plan_def_var_rec.gs_version_number,
			x_core_indicator_code      => cur_plan_def_var_rec.core_indicator_code,
			x_alternative_title        => cur_plan_def_var_rec.alternative_title,
			x_cart_error_flag          => cur_plan_def_var_rec.cart_error_flag,
			x_session_id              =>  cur_plan_def_var_rec.session_id,
			x_mode                     => 'R'
		   );
	END LOOP loop_plan_rec;

END enrp_val_appr_cr_pt;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.elgb_ovr_step_id,
           new_references.unit_cd,
           new_references.version_number,
           new_references.uoo_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

PROCEDURE AfterRowInsertUpdate(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN
    ) AS

  CURSOR get_step_type is
  SELECT eos.step_override_type
  FROM igs_en_elgb_ovr_step eos
  WHERE eos.elgb_ovr_step_id = NEW_REFERENCES.elgb_ovr_step_id       ;

  l_step_override_type  igs_en_elgb_ovr_step.step_override_type%TYPE := NULL;

  BEGIN

      IF p_inserting OR p_updating  THEN
         OPEN get_step_type ;
        FETCH get_step_type INTO l_step_override_type  ;
        CLOSE get_step_type ;

         IF l_step_override_type = 'VAR_CREDIT_APPROVAL' AND
            NVL(NEW_REFERENCES.step_override_limit,-1) <> NVL(OLD_REFERENCES.step_override_limit,-1) Then
               enrp_val_appr_cr_pt;
          END IF;
      END IF;
   END ;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.elgb_ovr_step_id = new_references.elgb_ovr_step_id)) OR
        ((new_references.elgb_ovr_step_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_elgb_ovr_step_pkg.get_pk_for_validation (
                new_references.elgb_ovr_step_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (old_references.uoo_id = new_references.uoo_id) OR
        (new_references.uoo_id IS NULL) OR  (new_references.uoo_id = -1 ) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ofr_opt_pkg.get_uk_For_validation (
                new_references.uoo_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ver_pkg.get_pk_for_validation (
                new_references.unit_cd,
                new_references.version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE  get_fk_igs_en_elgb_ovr_step (
    x_elgb_ovr_step_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_elgb_ovr_uoo
      WHERE   ((elgb_ovr_step_id  = x_elgb_ovr_step_id ));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_ELGB_STEP_UNIT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_elgb_ovr_step;


  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_elgb_ovr_step
      WHERE   ((uoo_id = x_uoo_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_EOS_UOO_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ps_unit_ofr_opt;


  PROCEDURE get_fk_igs_ps_unit_ver (
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_elgb_ovr_step
      WHERE   ((unit_cd = x_unit_cd) AND
               (version_number = x_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_EOS_UV_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_unit_ver;


  FUNCTION get_pk_for_validation (
    x_elgb_ovr_step_uoo_id              IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_elgb_ovr_uoo
      WHERE    elgb_ovr_step_uoo_id = x_elgb_ovr_step_uoo_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_pk_for_validation;


  FUNCTION get_uk_for_validation (
    x_elgb_ovr_step_id                  IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_uoo_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_elgb_ovr_uoo
      WHERE    elgb_ovr_step_id = x_elgb_ovr_step_id
      AND      unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      ( uoo_id = x_uoo_id or ( x_uoo_id IS NULL AND uoo_id = -1))
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_elgb_ovr_step_uoo_id              IN     NUMBER,
    x_elgb_ovr_step_id                  IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_step_override_limit               IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_elgb_ovr_step_uoo_id,
      x_elgb_ovr_step_id,
      x_unit_cd,
      x_version_number,
      x_uoo_id,
      x_step_override_limit,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.elgb_ovr_step_uoo_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance ;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance ;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.elgb_ovr_step_uoo_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  END before_dml;

PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN
    l_rowid := x_rowid;
     IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate( p_inserting => TRUE ,p_updating=>FALSE);
     ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate( p_inserting=>FALSE,p_updating => TRUE );
     ELSIF (p_action = 'DELETE') THEN
      null;
    END IF;
  END After_DML;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_elgb_ovr_step_uoo_id              IN OUT NOCOPY NUMBER,
    x_elgb_ovr_step_id                  IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_step_override_limit               IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'IGS_EN_ELGB_OVR_UOO_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_elgb_ovr_step_uoo_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_elgb_ovr_step_uoo_id              => x_elgb_ovr_step_uoo_id,
      x_elgb_ovr_step_id                  => x_elgb_ovr_step_id,
      x_unit_cd                           => x_unit_cd,
      x_version_number                    => x_version_number,
      x_uoo_id                            => x_uoo_id,
      x_step_override_limit               => x_step_override_limit,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF new_references.uoo_id IS NULL THEN
          new_references.uoo_id := -1 ;
       END IF ;

    INSERT INTO igs_en_elgb_ovr_uoo (
      elgb_ovr_step_uoo_id,
      elgb_ovr_step_id,
      unit_cd,
      version_number,
      uoo_id,
      step_override_limit,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
         igs_en_elgb_ovr_step_uoo_s.NEXTVAL,
      new_references.elgb_ovr_step_id,
      new_references.unit_cd,
      new_references.version_number,
      new_references.uoo_id,
      new_references.step_override_limit,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, elgb_ovr_step_uoo_id INTO x_rowid, x_elgb_ovr_step_uoo_id;

 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_elgb_ovr_step_uoo_id              IN     NUMBER,
    x_elgb_ovr_step_id                  IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_step_override_limit               IN     NUMBER
  ) AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        elgb_ovr_step_id,
        unit_cd,
        version_number,
        uoo_id,
        step_override_limit
      FROM  igs_en_elgb_ovr_uoo
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.elgb_ovr_step_id = x_elgb_ovr_step_id)
        AND (tlinfo.unit_cd = x_unit_cd)
        AND (tlinfo.version_number = x_version_number)
        AND (tlinfo.uoo_id = x_uoo_id)
        AND ((tlinfo.step_override_limit = x_step_override_limit) OR ((tlinfo.step_override_limit IS NULL) AND (X_step_override_limit IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_elgb_ovr_step_uoo_id              IN     NUMBER,
    x_elgb_ovr_step_id                  IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_step_override_limit               IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'IGS_EN_ELGB_OVR_UOO_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;



    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_elgb_ovr_step_uoo_id              => x_elgb_ovr_step_uoo_id,
      x_elgb_ovr_step_id                  => x_elgb_ovr_step_id,
      x_unit_cd                           => x_unit_cd,
      x_version_number                    => x_version_number,
      x_uoo_id                            => x_uoo_id,
      x_step_override_limit               => x_step_override_limit,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF new_references.uoo_id IS NULL THEN
          new_references.uoo_id := -1 ;
       END IF ;

    UPDATE igs_en_elgb_ovr_uoo
      SET
        elgb_ovr_step_id                  = new_references.elgb_ovr_step_id,
        unit_cd                           = new_references.unit_cd,
        version_number                    = new_references.version_number,
        uoo_id                            = new_references.uoo_id,
        step_override_limit               = new_references.step_override_limit,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

   After_DML(
         p_action => 'UPDATE',
         x_rowid => X_ROWID  );

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_elgb_ovr_step_uoo_id              IN OUT NOCOPY NUMBER,
    x_elgb_ovr_step_id                  IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_step_override_limit               IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_elgb_ovr_uoo
      WHERE    elgb_ovr_step_uoo_id              = x_elgb_ovr_step_uoo_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_elgb_ovr_step_uoo_id,
        x_elgb_ovr_step_id,
        x_unit_cd,
        x_version_number,
        x_uoo_id,
        x_step_override_limit,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_elgb_ovr_step_uoo_id,
      x_elgb_ovr_step_id,
      x_unit_cd,
      x_version_number,
      x_uoo_id,
      x_step_override_limit,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sankari.venkatachalam@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igs_en_elgb_ovr_uoo
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    After_DML(
         p_action => 'DELETE',
         x_rowid => X_ROWID  );

  END delete_row;

END igs_en_elgb_ovr_uoo_pkg;

/
