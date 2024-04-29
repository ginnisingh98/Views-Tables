--------------------------------------------------------
--  DDL for Package Body IGS_EN_SUA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SUA_API" AS
/* $Header: IGSENA0B.pls 120.5 2006/04/26 03:26:26 bdeviset ship $ */
  cst_completed  CONSTANT VARCHAR2(30) := 'COMPLETED';
  cst_discontin  CONSTANT VARCHAR2(30) := 'DISCONTIN';
  cst_dropped    CONSTANT VARCHAR2(30) := 'DROPPED';
  cst_duplicate  CONSTANT VARCHAR2(30) := 'DUPLICATE';
  cst_enrolled   CONSTANT VARCHAR2(30) := 'ENROLLED';
  cst_invalid    CONSTANT VARCHAR2(30) := 'INVALID';
  cst_unconfirm  CONSTANT VARCHAR2(30) := 'UNCONFIRM';
  cst_waitlisted CONSTANT VARCHAR2(30) := 'WAITLISTED';

  l_rowid VARCHAR2(25);

  CURSOR c_sua (CP_ROW_ID VARCHAR2) IS
  SELECT sua.*
  FROM IGS_EN_SU_ATTEMPT_ALL sua
  WHERE ROWID = CP_ROW_ID;


 -- For Enhancement Bug 1287292
 -- Local Procedure added to update enrollment maximum
PROCEDURE upd_enrollment_counts( p_action IN VARCHAR2,
                                 old_references    EN_SUA_REC_TYPE%TYPE,
                                 new_references    EN_SUA_REC_TYPE%TYPE)
AS

  CURSOR  usec_upd_enr_act(p_uoo_id NUMBER) IS
  SELECT ROWID,uoo.*
  FROM   igs_ps_unit_ofr_opt uoo
  WHERE uoo_id = p_uoo_id
  FOR UPDATE;

  usec_row usec_upd_enr_act%ROWTYPE;

 -- For Enhancement Bug 1287292
 -- Local Procedure added to update enrollment maximum
 -- The actual enrollment in the unit section is being updated by 1 when
 -- the unit attempt is successful.
 -- The updation takes place if the parameter upd_act_enr is sent as 'Y'
-- For response to bug 152583, a private procedure that updates the row
-- and also updaes the value that populate into the actual enrolment field
-- of IGS_PS_UNIT_OFR_OPT table. This procedure is called from the
-- upd_enrollment_max procedure

PROCEDURE local_update_unit_section( p_action       IN VARCHAR2,
                                     old_references    EN_SUA_REC_TYPE%TYPE,
                                     new_references    EN_SUA_REC_TYPE%TYPE,
                                     usec_row          usec_upd_enr_act%ROWTYPE
                                   ) AS
  /*************************************************************
   Created By :
   Date Created By :
   Purpose :
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   sommukhe      28-JUL-2005     Bug#4344483,Modified the call to igs_ps_unit_ofr_opt_pkg.update_row to include new parameter abort_flag.
   stutta        23-Aug-2004     Bug#3803790, passed course_cd as parameter to igs_en_gen_015.get_usec_status
   sarakshi      13-Jul-2004     Bug#3729462, Added predicate DELETE_FLAG='N' to the cursor c_max_std_per_wait_uofr_pat,c_wait_allow_unit_offering  .
   sarakshi      22-Sep-2003     Enh#3052452, Modified the call to igs_ps_unit_ofr_opt_pkg.update_row to include
                                 new parameters sup_uoo_id,relation_type,default_enroll_flag.
   vvutukur      05-Aug-2003     Enh#3045069.PSP Enh Build. Modified the calls to igs_ps_unit_ofr_opt_pkg.update_row to
                                 include new parameter not_multiple_section_flag.
   (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR   c_usec_lim (cp_uoo_id IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE) IS
  SELECT   NVL (usec.enrollment_maximum, NVL(uv.enrollment_maximum,999999) ) enrollment_maximum
  FROM     igs_ps_usec_lim_wlst usec,
                     igs_ps_unit_ver uv,
                     igs_ps_unit_ofr_opt uoo
  WHERE    uoo.unit_cd = uv.unit_cd
  AND      uoo.version_number = uv.version_number
  AND      uoo.uoo_id = usec.uoo_id (+)
  AND      uoo.uoo_id = cp_uoo_id;

  --
  -- The following three cursors added as part of the bug  2375362. pmarada
  -- getting maximum students per waitlist in the unit section level.
  CURSOR c_max_std_per_wait_usec(cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT max_students_per_waitlist  FROM igs_ps_usec_lim_wlst_v
  WHERE uoo_id = cp_uoo_id;
  l_max_std_per_wait_usec  igs_ps_usec_lim_wlst_v.max_students_per_waitlist%TYPE;

  -- Getting the maximum students per waitlist from unit offering pattern level.
  CURSOR c_max_std_per_wait_uofr_pat (cp_unit_cd igs_ps_unit_ofr_opt.unit_cd%TYPE,
         cp_version_number igs_ps_unit_ofr_opt.version_number%TYPE,
         cp_cal_type igs_ps_unit_ofr_opt.cal_type%TYPE,
         cp_ci_sequence_number igs_ps_unit_ofr_opt.ci_sequence_number%TYPE) IS
  SELECT max_students_per_waitlist FROM igs_ps_unit_ofr_pat
  WHERE unit_cd = cp_unit_cd
  AND  version_number = cp_version_number
  AND cal_type = cp_cal_type
  AND ci_sequence_number = cp_ci_sequence_number
  AND delete_flag='N';
  l_max_std_per_wait_uofr_pat igs_ps_unit_ofr_pat.max_students_per_waitlist%TYPE;

-- Getting the maximum students per waitlist from organization level.
  CURSOR c_max_std_per_wait_org (cp_org_unit_cd igs_ps_unit_ofr_opt.owner_org_unit_cd%TYPE,
         cp_cal_type igs_ps_unit_ofr_opt.cal_type%TYPE,
         cp_ci_sequence_number igs_ps_unit_ofr_opt.ci_sequence_number%TYPE) IS
  SELECT max_stud_per_wlst FROM igs_en_or_unit_wlst_v
  WHERE  org_unit_cd = cp_org_unit_cd
  AND cal_type = cp_cal_type
  AND sequence_number = cp_ci_sequence_number ;
  l_max_std_per_wait_org  igs_en_or_unit_wlst_v.max_stud_per_wlst%TYPE;

  -- end of the added three cursors. pmarada
  -- Cursor to Check if Waitlisting is allowed at the unit section level .
  CURSOR c_wait_allow_unit_section ( cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
         SELECT  waitlist_allowed
         FROM IGS_PS_USEC_LIM_WLST
         WHERE uoo_id = cp_uoo_id ;
 --
 -- Cursor Check if Waitlisting is allowed at the unit offering level .
 --
  CURSOR c_wait_allow_unit_offering ( cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
         SELECT  waitlist_allowed
         FROM IGS_PS_UNIT_OFR_PAT
         WHERE  delete_flag='N' AND (unit_cd , version_number , cal_type , ci_sequence_number ) IN
                        (SELECT unit_cd , version_number , cal_type, ci_sequence_number
                         FROM   igs_ps_unit_ofr_opt
                         WHERE  uoo_id = cp_uoo_id);

  -- Cursor to check whether the unit section belongs to any cross listed group or not.
  CURSOR  c_cross_listed (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  grp.max_enr_group, grpmem.usec_x_listed_group_id
  FROM    igs_ps_usec_x_grpmem grpmem,
          igs_ps_usec_x_grp grp
  WHERE   grp.usec_x_listed_group_id = grpmem.usec_x_listed_group_id
  AND     grpmem.uoo_id = l_uoo_id;

  -- Cursor to check whether the unit section belongs to any Meet With Class or not.
  CURSOR  c_meet_with_cls (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT  grp.max_enr_group, ucm.class_meet_group_id
  FROM    igs_ps_uso_clas_meet ucm,
          igs_ps_uso_cm_grp grp
  WHERE   grp.class_meet_group_id = ucm.class_meet_group_id
  AND     ucm.uoo_id = l_uoo_id;


  -- Cursor to get the Actual enrollment of all the unit sections that
  -- belong to the class listed group.
  CURSOR c_actual_enr_crs_lst(l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE,
                             l_usec_x_listed_group_id igs_ps_usec_x_grpmem.usec_x_listed_group_id%TYPE) IS
  SELECT SUM(enrollment_actual)
  FROM   igs_ps_unit_ofr_opt uoo,
         igs_ps_usec_x_grpmem ugrp
  WHERE  uoo.uoo_id = ugrp.uoo_id
  AND    ugrp.uoo_id <> l_uoo_id
  AND    ugrp.usec_x_listed_group_id = l_usec_x_listed_group_id;


  -- Cursor to get the Actual enrollment of all the unit sections that
  -- belong to the Meet With Class.
  CURSOR c_actual_enr_meet_cls(l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE,
                               l_class_meet_group_id igs_ps_uso_clas_meet.class_meet_group_id%TYPE) IS
  SELECT SUM(enrollment_actual)
  FROM   igs_ps_unit_ofr_opt uoo,
         igs_ps_uso_clas_meet ucls
  WHERE  uoo.uoo_id = ucls.uoo_id
  AND    ucls.uoo_id <> l_uoo_id
  AND    ucls.class_meet_group_id = l_class_meet_group_id;


  -- Cursor to get the unit section details that belongs to the cross listed group.
  CURSOR c_cross_lst_details(l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE,
                             l_usec_x_listed_group_id igs_ps_usec_x_grpmem.usec_x_listed_group_id%TYPE,
                             l_unit_section_status igs_ps_unit_ofr_opt.unit_section_status%TYPE) IS
  SELECT uoo.rowid, uoo.*
  FROM   igs_ps_unit_ofr_opt uoo,
         igs_ps_usec_x_grpmem ugrp
  WHERE  uoo.uoo_id = ugrp.uoo_id
  AND    ugrp.uoo_id <> l_uoo_id
  AND    ugrp.usec_x_listed_group_id = l_usec_x_listed_group_id
  AND    uoo.unit_section_status <> l_unit_section_status;


    -- Cursor to get the unit section details that belongs to the Meet with class.
  CURSOR c_meet_with_cls_details(l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE,
                                 l_class_meet_group_id igs_ps_uso_clas_meet.class_meet_group_id%TYPE,
                                 l_unit_section_status igs_ps_unit_ofr_opt.unit_section_status%TYPE) IS
  SELECT uoo.rowid, uoo.*
  FROM   igs_ps_unit_ofr_opt_all uoo,
         igs_ps_uso_clas_meet ucls
  WHERE  uoo.uoo_id = ucls.uoo_id
  AND    ucls.uoo_id <> l_uoo_id
  AND    ucls.class_meet_group_id = l_class_meet_group_id
  AND    uoo.unit_section_status <> l_unit_section_status;


   v_enr_max             igs_ps_usec_lim_wlst.enrollment_maximum%TYPE;
   v_max_std_wlst        igs_ps_usec_lim_wlst.max_students_per_waitlist%TYPE;
   lv_unit_section_status igs_ps_unit_ofr_opt.unit_section_status%TYPE ;
   l_waitlist_allowed     IGS_PS_UNIT_OFR_PAT.waitlist_allowed%TYPE ;
   l_cross_listed_row c_cross_listed%ROWTYPE;
   l_meet_with_cls_row c_meet_with_cls%ROWTYPE;
   l_usec_partof_group BOOLEAN;
   v_grp_max igs_ps_usec_x_grp.max_enr_group%TYPE;
   v_grp_actual       igs_ps_unit_ofr_opt.enrollment_actual%TYPE;
   l_setup_found NUMBER;
   l_dir_enr              igs_ps_unit_ofr_opt_all.dir_enrollment%TYPE;
   l_enr_from_wlst        igs_ps_unit_ofr_opt_all.enr_from_wlst%TYPE ;

BEGIN
-- In this procedure the enrollment maximum and waitlist maximum are passed
-- throught the usec_row record ( after updating the record itself with the
-- new values) from upd_enrollment_max. Which in turn is called in the after dml
-- The code in this procudure calculate the unit section status and updates
-- the same in to the unit section table.
-- amuthu 09-AUG-2001 Enroll Process DLD
--
-- svenkata 16-Apr-02 Validations for changing Unit Section Status have been modified so that
-- they incorporate all checks before changing status .Bug # 2318942.
--

   l_usec_partof_group := FALSE;
   l_setup_found := 0;

    -- Check whether the unit section belongs to any cross listed group.
    OPEN c_cross_listed(usec_row.uoo_id);
    FETCH c_cross_listed INTO l_cross_listed_row ;

    IF c_cross_listed%FOUND THEN
         -- Get the maximum enrollment limit from the cross listed group level.
       IF l_cross_listed_row.max_enr_group IS NULL THEN
          l_usec_partof_group := FALSE;
       ELSE
        l_usec_partof_group := TRUE;
        l_setup_found := 1;
        v_grp_max := l_cross_listed_row.max_enr_group;

        -- Get the actual enrollment count of all the unit sections that belongs to the cross listed group.
        OPEN c_actual_enr_crs_lst(usec_row.uoo_id, l_cross_listed_row.usec_x_listed_group_id);
        FETCH c_actual_enr_crs_lst INTO v_grp_actual;
        CLOSE c_actual_enr_crs_lst;
      END IF;

   ELSE

      -- Check whether the unit section belongs to any meet with class group.
      OPEN c_meet_with_cls(usec_row.uoo_id);
      FETCH c_meet_with_cls INTO l_meet_with_cls_row ;

      IF c_meet_with_cls%FOUND THEN
         -- Check whether the maximum enrollment limit is defined in group level.
         IF l_meet_with_cls_row.max_enr_group IS NULL THEN
           l_usec_partof_group := FALSE;
         ELSE
           l_usec_partof_group := TRUE;
           l_setup_found := 2;
           v_grp_max := l_meet_with_cls_row.max_enr_group;
           -- Get the actual enrollment count of all the unit sections that belongs to
           -- the meet with class group.
           OPEN c_actual_enr_meet_cls(usec_row.uoo_id, l_meet_with_cls_row.class_meet_group_id);
           FETCH c_actual_enr_meet_cls INTO v_grp_actual;
           CLOSE c_actual_enr_meet_cls;
         END IF;

       ELSE
         l_usec_partof_group := FALSE;
       END IF;
       CLOSE c_meet_with_cls;
     END IF;
     CLOSE c_cross_listed;

     -- Setup is not done in the group level, so get the details from Unit Section / Unit level.
     IF l_usec_partof_group = FALSE THEN

        OPEN c_usec_lim(usec_row.uoo_id);
        FETCH c_usec_lim INTO v_enr_max;
        CLOSE c_usec_lim;

          --
          -- At the lowest level , waitlist allowed can be set at the Unit Section level . First check if waitlist has been
          -- allowed at Unit Section Level . If waitlisting is not allowed , then check at the next level - Unit Offering.
          -- If waitlisting is permitted at the Unit Offering level , return p_waitlist_ind = 'Y'
          --
          OPEN c_wait_allow_unit_section(usec_row.uoo_id) ;
          FETCH c_wait_allow_unit_section INTO   l_waitlist_allowed ;
          IF c_wait_allow_unit_section%NOTFOUND THEN
                OPEN c_wait_allow_unit_offering(usec_row.uoo_id) ;
                FETCH c_wait_allow_unit_offering INTO   l_waitlist_allowed ;
                CLOSE c_wait_allow_unit_offering;
          END IF;
          CLOSE c_wait_allow_unit_section;

          -- added the following code as part of 2375362, pmarada
          OPEN c_max_std_per_wait_usec(usec_row.uoo_id );
          FETCH c_max_std_per_wait_usec INTO l_max_std_per_wait_usec;
          -- Checking defined any max student per wait list exist at unit section level
          IF c_max_std_per_wait_usec%FOUND THEN
             v_max_std_wlst := l_max_std_per_wait_usec;
          ELSE
            OPEN c_max_std_per_wait_uofr_pat(usec_row.unit_cd,
               usec_row.version_number,
               usec_row.cal_type,
               usec_row.ci_sequence_number);
            FETCH c_max_std_per_wait_uofr_pat INTO l_max_std_per_wait_uofr_pat;
             -- checking defined any max students per wait list exist at unit offering pattern level
            IF c_max_std_per_wait_uofr_pat%FOUND THEN
                v_max_std_wlst := l_max_std_per_wait_uofr_pat;
            ELSE
              OPEN c_max_std_per_wait_org (usec_row.owner_org_unit_cd,
                   usec_row.cal_type,
                   usec_row.ci_sequence_number);
              FETCH c_max_std_per_wait_org INTO l_max_std_per_wait_org;
              -- checking defined any max students oer wait list exist at organization level.
              IF c_max_std_per_wait_org%FOUND THEN
                  v_max_std_wlst := l_max_std_per_wait_org;
              END IF;
              CLOSE c_max_std_per_wait_org;
            END IF;
              CLOSE c_max_std_per_wait_uofr_pat ;
          END IF;
          CLOSE c_max_std_per_wait_usec;
          -- end of the code added. pmarada

         IF NVL(l_waitlist_allowed, 'N') = 'N' THEN
            IF (NVL(usec_row.enrollment_actual,0) >= NVL(v_enr_max,999999) ) THEN
               lv_unit_section_status :='CLOSED';
            ELSIF NVL(usec_row.enrollment_actual,0) < NVL(v_enr_max,999999) THEN
               lv_unit_section_status :='OPEN';
            END IF;
         ELSE

           IF  (NVL(usec_row.enrollment_actual,0) >= NVL(v_enr_max,999999))
              AND ( NVL(usec_row.waitlist_actual,0) >= NVL(v_max_std_wlst,999999) )THEN
              --update the status of the unit section to 'CLOSED'
              lv_unit_section_status :='CLOSED';

           ELSIF (NVL(usec_row.enrollment_actual,0) < NVL(v_enr_max,999999)
              AND NVL(usec_row.waitlist_actual,0) > 0 ) THEN
              --update the status of the unit section to 'HOLD'
              lv_unit_section_status :='HOLD';

           ELSIF ( (NVL(usec_row.enrollment_actual,0) >= NVL(v_enr_max,999999) )
             AND NVL(usec_row.waitlist_actual,0) < NVL(v_max_std_wlst,999999)) THEN
             --update the status of the unit section to 'FULLWAITOK'
             lv_unit_section_status :='FULLWAITOK';

           ELSIF (NVL(usec_row.enrollment_actual,0) < NVL(v_enr_max,999999)
             AND NVL(usec_row.waitlist_actual,0) = 0) THEN
             --update the status of the unit section to 'OPEN'
             lv_unit_section_status :='OPEN';
           END IF;

        END IF;

     ELSE

        -- If actual enrollment is greater than the maximim enrollment limit in the group level
        -- Change the unit section status to 'Closed' and update all the unit sections which
        -- belong to that group to closed.

        IF (NVL(v_grp_actual,0) + NVL(usec_row.enrollment_actual,0)) >= v_grp_max  THEN
          lv_unit_section_status := 'CLOSED';
        ELSE
          lv_unit_section_status := 'OPEN';
        END IF;

    END IF;  -- End if moved here as part of Bug# 2672325


   -- The direct enrollment count needs to be incremented when the
   -- unit attempt is inserted with a unit attempt status of 'ENROLLED
   -- The enrolled from waitlist count is incremented if a unit attempt
   -- is moved to 'Enrolled' Status from 'WAitlist' status

    l_enr_from_wlst := usec_row.ENR_FROM_WLST ;
    l_dir_enr := usec_row.DIR_ENROLLMENT ;

    IF p_action = 'INSERT' THEN
      IF new_references.UNIT_ATTEMPT_STATUS = cst_enrolled THEN
        l_dir_enr := NVL(usec_row.DIR_ENROLLMENT,0) + 1 ;
        l_enr_from_wlst := usec_row.ENR_FROM_WLST ;
      END IF;
    ELSIF p_action = 'UPDATE' THEN
      IF (new_references.UNIT_ATTEMPT_STATUS = cst_enrolled AND
        old_references.UNIT_ATTEMPT_STATUS = cst_waitlisted ) THEN
         -- if the student has been enrolled from the waitlist then increment
         -- counter ENR_FROM_WLST
          l_enr_from_wlst := NVL(usec_row.ENR_FROM_WLST, 0) + 1;
          l_dir_enr := usec_row.DIR_ENROLLMENT ;
      END IF;
    END IF;

       IGS_PS_UNIT_OFR_OPT_PKG.UPDATE_ROW (
               X_ROWID =>  usec_row.ROWID ,
               x_UNIT_CD  =>  usec_row.UNIT_CD ,
               x_VERSION_NUMBER  =>  usec_row.VERSION_NUMBER ,
               x_CAL_TYPE  =>  usec_row.CAL_TYPE ,
               x_CI_SEQUENCE_NUMBER  =>  usec_row.CI_SEQUENCE_NUMBER ,
               x_LOCATION_CD  =>  usec_row.LOCATION_CD ,
               x_UNIT_CLASS  =>  usec_row.UNIT_CLASS ,
               x_UOO_ID  =>  usec_row.UOO_ID ,
               x_IVRS_AVAILABLE_IND  =>  usec_row.IVRS_AVAILABLE_IND ,
               x_CALL_NUMBER  =>  usec_row.CALL_NUMBER ,
               x_UNIT_SECTION_STATUS  =>  NVL(lv_unit_section_status,usec_row.UNIT_SECTION_STATUS ),
               x_UNIT_SECTION_START_DATE  =>  usec_row.UNIT_SECTION_START_DATE ,
               x_UNIT_SECTION_END_DATE  =>  usec_row.UNIT_SECTION_END_DATE ,
               x_ENROLLMENT_ACTUAL  =>  usec_row.ENROLLMENT_ACTUAL,
               x_WAITLIST_ACTUAL  =>  usec_row.WAITLIST_ACTUAL ,
               x_OFFERED_IND  =>  usec_row.OFFERED_IND ,
               x_STATE_FINANCIAL_AID  =>  usec_row.STATE_FINANCIAL_AID ,
               x_GRADING_SCHEMA_PRCDNCE_IND  =>  usec_row.GRADING_SCHEMA_PRCDNCE_IND,
               x_FEDERAL_FINANCIAL_AID  =>  usec_row.FEDERAL_FINANCIAL_AID ,
               x_UNIT_QUOTA  =>  usec_row.UNIT_QUOTA ,
               x_UNIT_QUOTA_RESERVED_PLACES  =>  usec_row.UNIT_QUOTA_RESERVED_PLACES ,
               x_INSTITUTIONAL_FINANCIAL_AID  =>  usec_row.INSTITUTIONAL_FINANCIAL_AID ,
               x_UNIT_CONTACT  =>  usec_row.UNIT_CONTACT ,
               x_GS_VERSION_NUMBER  =>  usec_row.GS_VERSION_NUMBER ,
               X_MODE  =>  'R',
               X_SS_ENROL_IND => usec_row.ss_enrol_ind,
               X_SS_DISPLAY_IND => usec_row.ss_display_ind,
               x_owner_org_unit_cd        =>  usec_row.owner_org_unit_cd,
               x_attendance_required_ind  =>  usec_row.attendance_required_ind,
               x_reserved_seating_allowed =>  usec_row.reserved_seating_allowed,
               x_special_permission_ind   =>  usec_row.special_permission_ind,
               x_dir_enrollment => l_dir_enr,
               x_enr_from_wlst => l_enr_from_wlst,
               x_inq_not_wlst =>usec_row.inq_not_wlst,
               x_rev_account_cd  => usec_row.rev_account_cd ,
               x_GRADING_SCHEMA_CD  =>  usec_row.GRADING_SCHEMA_CD,
               X_NON_STD_USEC_IND => usec_row.NON_STD_USEC_IND,
               X_ANON_UNIT_GRADING_IND => usec_row.anon_unit_grading_ind,
               X_ANON_ASSESS_GRADING_IND => usec_row.anon_assess_grading_ind,
               x_auditable_ind => usec_row.auditable_ind,
               x_audit_permission_ind => usec_row.audit_permission_ind,
               x_not_multiple_section_flag => usec_row.not_multiple_section_flag,
               x_sup_uoo_id => usec_row.sup_uoo_id,
               x_relation_type => usec_row.relation_type,
               x_default_enroll_flag => usec_row.default_enroll_flag,
               x_abort_flag => usec_row.abort_flag
               );

       -- Setup is defined in the cross listed group level.
       IF l_setup_found = 1 THEN

          -- Update the unit sections status that belong to the cross listed group with the derived value.
          FOR unit_sec in c_cross_lst_details(usec_row.uoo_id, l_cross_listed_row.usec_x_listed_group_id, lv_unit_section_status) LOOP

          -- Added auditable_ind and audit_permission_ind parameters as part of Bug# 2636716
             IGS_PS_UNIT_OFR_OPT_PKG.UPDATE_ROW (
               X_ROWID =>  unit_sec.ROWID ,
               x_UNIT_CD  =>  unit_sec.UNIT_CD ,
               x_VERSION_NUMBER  =>  unit_sec.VERSION_NUMBER ,
               x_CAL_TYPE  =>  unit_sec.CAL_TYPE ,
               x_CI_SEQUENCE_NUMBER  =>  unit_sec.CI_SEQUENCE_NUMBER ,
               x_LOCATION_CD  =>  unit_sec.LOCATION_CD ,
               x_UNIT_CLASS  =>  unit_sec.UNIT_CLASS ,
               x_UOO_ID  =>  unit_sec.UOO_ID ,
               x_IVRS_AVAILABLE_IND  =>  unit_sec.IVRS_AVAILABLE_IND ,
               x_CALL_NUMBER  =>  unit_sec.CALL_NUMBER ,
               x_UNIT_SECTION_STATUS  =>  NVL(lv_unit_section_status,unit_sec.UNIT_SECTION_STATUS ),
               x_UNIT_SECTION_START_DATE  =>  unit_sec.UNIT_SECTION_START_DATE ,
               x_UNIT_SECTION_END_DATE  =>  unit_sec.UNIT_SECTION_END_DATE ,
               x_ENROLLMENT_ACTUAL  =>  unit_sec.ENROLLMENT_ACTUAL,
               x_WAITLIST_ACTUAL  =>  unit_sec.WAITLIST_ACTUAL ,
               x_OFFERED_IND  =>  unit_sec.OFFERED_IND ,
               x_STATE_FINANCIAL_AID  =>  unit_sec.STATE_FINANCIAL_AID ,
               x_GRADING_SCHEMA_PRCDNCE_IND  =>  unit_sec.GRADING_SCHEMA_PRCDNCE_IND,
               x_FEDERAL_FINANCIAL_AID  =>  unit_sec.FEDERAL_FINANCIAL_AID ,
               x_UNIT_QUOTA  =>  unit_sec.UNIT_QUOTA ,
               x_UNIT_QUOTA_RESERVED_PLACES  =>  unit_sec.UNIT_QUOTA_RESERVED_PLACES ,
               x_INSTITUTIONAL_FINANCIAL_AID  =>  unit_sec.INSTITUTIONAL_FINANCIAL_AID ,
               x_UNIT_CONTACT  =>  unit_sec.UNIT_CONTACT ,
               x_GS_VERSION_NUMBER  =>  unit_sec.GS_VERSION_NUMBER ,
               X_MODE  =>  'R',
               X_SS_ENROL_IND => unit_sec.ss_enrol_ind,
               X_SS_DISPLAY_IND => unit_sec.ss_display_ind,
               x_owner_org_unit_cd        =>  unit_sec.owner_org_unit_cd,
               x_attendance_required_ind  =>  unit_sec.attendance_required_ind,
               x_reserved_seating_allowed =>  unit_sec.reserved_seating_allowed,
               x_special_permission_ind   =>  unit_sec.special_permission_ind,
               x_dir_enrollment =>unit_sec.dir_enrollment,
               x_enr_from_wlst =>unit_sec.enr_from_wlst,
               x_inq_not_wlst =>unit_sec.inq_not_wlst,
               x_rev_account_cd  => unit_sec.rev_account_cd ,
               x_GRADING_SCHEMA_CD  =>  unit_sec.GRADING_SCHEMA_CD,
               X_NON_STD_USEC_IND => unit_sec.NON_STD_USEC_IND,
               X_ANON_UNIT_GRADING_IND => unit_sec.anon_unit_grading_ind,
               X_ANON_ASSESS_GRADING_IND => unit_sec.anon_assess_grading_ind,
               x_auditable_ind => unit_sec.auditable_ind,
               x_audit_permission_ind => unit_sec.audit_permission_ind,
               x_not_multiple_section_flag => unit_sec.not_multiple_section_flag,
               x_sup_uoo_id => unit_sec.sup_uoo_id,
               x_relation_type => unit_sec.relation_type,
               x_default_enroll_flag => unit_sec.default_enroll_flag,
               x_abort_flag => unit_sec.abort_flag
          );

       END LOOP;

     ELSIF l_setup_found = 2 THEN
          -- Setup is done in the Meet with class group.
          -- Update the unit sections status that belong to the group with the derived value.
        FOR usec_meet_with in c_meet_with_cls_details(usec_row.uoo_id, l_meet_with_cls_row.class_meet_group_id, lv_unit_section_status) LOOP

        -- Added auditable_ind and audit_permission_ind parameters as part of Bug# 2636716
             IGS_PS_UNIT_OFR_OPT_PKG.UPDATE_ROW (
               X_ROWID =>  usec_meet_with.ROWID ,
               x_UNIT_CD  =>  usec_meet_with.UNIT_CD ,
               x_VERSION_NUMBER  =>  usec_meet_with.VERSION_NUMBER ,
               x_CAL_TYPE  =>  usec_meet_with.CAL_TYPE ,
               x_CI_SEQUENCE_NUMBER  =>  usec_meet_with.CI_SEQUENCE_NUMBER ,
               x_LOCATION_CD  =>  usec_meet_with.LOCATION_CD ,
               x_UNIT_CLASS  =>  usec_meet_with.UNIT_CLASS ,
               x_UOO_ID  =>  usec_meet_with.UOO_ID ,
               x_IVRS_AVAILABLE_IND  =>  usec_meet_with.IVRS_AVAILABLE_IND ,
               x_CALL_NUMBER  =>  usec_meet_with.CALL_NUMBER ,
               x_UNIT_SECTION_STATUS  =>  NVL(lv_unit_section_status,usec_meet_with.UNIT_SECTION_STATUS ),
               x_UNIT_SECTION_START_DATE  =>  usec_meet_with.UNIT_SECTION_START_DATE ,
               x_UNIT_SECTION_END_DATE  =>  usec_meet_with.UNIT_SECTION_END_DATE ,
               x_ENROLLMENT_ACTUAL  =>  usec_meet_with.ENROLLMENT_ACTUAL,
               x_WAITLIST_ACTUAL  =>  usec_meet_with.WAITLIST_ACTUAL ,
               x_OFFERED_IND  =>  usec_meet_with.OFFERED_IND ,
               x_STATE_FINANCIAL_AID  =>  usec_meet_with.STATE_FINANCIAL_AID ,
               x_GRADING_SCHEMA_PRCDNCE_IND  =>  usec_meet_with.GRADING_SCHEMA_PRCDNCE_IND,
               x_FEDERAL_FINANCIAL_AID  =>  usec_meet_with.FEDERAL_FINANCIAL_AID ,
               x_UNIT_QUOTA  =>  usec_meet_with.UNIT_QUOTA ,
               x_UNIT_QUOTA_RESERVED_PLACES  =>  usec_meet_with.UNIT_QUOTA_RESERVED_PLACES ,
               x_INSTITUTIONAL_FINANCIAL_AID  =>  usec_meet_with.INSTITUTIONAL_FINANCIAL_AID ,
               x_UNIT_CONTACT  =>  usec_meet_with.UNIT_CONTACT ,
               x_GS_VERSION_NUMBER  =>  usec_meet_with.GS_VERSION_NUMBER ,
               X_MODE  =>  'R',
               X_SS_ENROL_IND => usec_meet_with.ss_enrol_ind,
               X_SS_DISPLAY_IND => usec_meet_with.ss_display_ind,
               x_owner_org_unit_cd        =>  usec_meet_with.owner_org_unit_cd,
               x_attendance_required_ind  =>  usec_meet_with.attendance_required_ind,
               x_reserved_seating_allowed =>  usec_meet_with.reserved_seating_allowed,
               x_special_permission_ind   =>  usec_meet_with.special_permission_ind,
               x_dir_enrollment =>usec_meet_with.dir_enrollment,
               x_enr_from_wlst =>usec_meet_with.enr_from_wlst,
               x_inq_not_wlst =>usec_meet_with.inq_not_wlst,
               x_rev_account_cd  => usec_meet_with.rev_account_cd ,
               x_GRADING_SCHEMA_CD  =>  usec_meet_with.GRADING_SCHEMA_CD,
               X_NON_STD_USEC_IND => usec_meet_with.NON_STD_USEC_IND,
               X_ANON_UNIT_GRADING_IND => usec_meet_with.anon_unit_grading_ind,
               X_ANON_ASSESS_GRADING_IND => usec_meet_with.anon_assess_grading_ind,
               x_auditable_ind => usec_meet_with.auditable_ind,
               x_audit_permission_ind => usec_meet_with.audit_permission_ind,
               x_not_multiple_section_flag => usec_meet_with.not_multiple_section_flag,
               x_sup_uoo_id => usec_meet_with.sup_uoo_id,
               x_relation_type => usec_meet_with.relation_type,
               x_default_enroll_flag => usec_meet_with.default_enroll_flag,
               x_abort_flag => usec_meet_with.abort_flag
          );
       END LOOP;
    END IF;

   END local_update_unit_section;

   --  This procedure is used to get the status of the Unit Section and Waitlist Indicator,
   --  which determine whether student can Enroll, Waitlist or will be shown error message.
   PROCEDURE local_usec_status ( old_references    IN EN_SUA_REC_TYPE%TYPE,
                                 new_references    IN EN_SUA_REC_TYPE%TYPE,
                                 usec_row          OUT NOCOPY usec_upd_enr_act%ROWTYPE
                               ) AS
/*------------------------------------------------------------------

vkarthik   10-dec-2003  Bug3140571. Added a cursor to pick up version for the given person and course and another to get
                        max_wlst_per_stud given the course and version.  Made use of these cursors to include program level
                        EN waitlist

------------------------------------------------------------------*/

     -- Cursor to get the load calander for the passed teaching calander.
     CURSOR cur_teach_to_load( p_teach_cal_type IGS_CA_INST.cal_type%TYPE,
                               p_teach_ci_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
       SELECT load_cal_type, load_ci_sequence_number
       FROM   IGS_CA_TEACH_TO_LOAD_V
       WHERE  teach_cal_type = p_teach_cal_type
       AND    teach_ci_sequence_number = p_teach_ci_sequence_number
       ORDER BY LOAD_START_DT ASC;

     --Cursor to check the maximum audit enrollments for a unit section
     CURSOR c_max_auditors_allowed(cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
     SELECT max_auditors_allowed
     FROM igs_ps_usec_lim_wlst
     WHERE uoo_id = cp_uoo_id;
     l_max_auditors_allowed     igs_ps_usec_lim_wlst.max_auditors_allowed%TYPE;

     --Cursor to get the count of audit attempts
     CURSOR c_audit_attempts_count(cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
     SELECT count(*)
     FROM igs_en_su_attempt
     WHERE no_assessment_ind='Y'
     AND uoo_id = cp_uoo_id
     AND unit_attempt_status in (cst_enrolled,cst_completed,cst_invalid,cst_unconfirm);
     l_audit_attempts_count     NUMBER;

     rec_teach_to_load cur_teach_to_load%ROWTYPE;
     l_unit_section_status  igs_ps_unit_ofr_opt.unit_section_status%TYPE;
     l_waitlist_ind VARCHAR2(10);

     -- cursor that gets version number given person_id and course_cd
     CURSOR cur_get_prog_ver(cp_person_id       igs_en_su_attempt.person_id%TYPE,
                             cp_course_cd       igs_en_su_attempt.course_cd%TYPE) IS
     SELECT version_number
     FROM igs_en_stdnt_ps_att
     WHERE
                person_id       =       cp_person_id    AND
                course_cd       =       cp_course_cd;

     -- cursor that gets max_wlst_stud_ps given course and version
     CURSOR cur_max_wlst_stud_ps(cp_course_cd           igs_ps_ver.course_cd%TYPE,
                                 cp_version_number      igs_ps_ver.version_number%TYPE) IS
     SELECT max_wlst_per_stud
     FROM igs_ps_ver
     WHERE
                course_cd       =       cp_course_cd    AND
                version_number  =       cp_version_number;

     --cursors to check max waitlist per student and validations for simultaneous wailists
     --as part of wailist enhancement build , bug# 3052426.
     CURSOR cur_max_wlst_stud IS
     SELECT max_waitlists_student_num
     FROM IGS_EN_INST_WL_STPS;

     CURSOR cur_count_wlsts_stud(cp_person_id igs_en_su_attempt.person_id%TYPE,
                                cp_load_cal_type IGS_CA_INST.cal_type%TYPE,
                                cp_load_seq_num IGS_CA_INST.sequence_number%TYPE) IS
     SELECT count(*)
     FROM  igs_en_su_attempt
     WHERE person_id = cp_person_id
     AND unit_attempt_status =cst_waitlisted
     AND (cal_type, ci_sequence_number) IN
          (SELECT teach_cal_type, teach_ci_sequence_number
           FROM igs_ca_load_to_teach_v
           WHERE load_cal_type = cp_load_cal_type
           AND load_ci_sequence_number = cp_load_seq_num);

     CURSOR cur_mus_allwd(cp_unit_cd igs_ps_unit_ver.unit_cd%TYPE,
                          cp_version_number igs_ps_unit_ver.version_number%TYPE) IS
     SELECT same_teaching_period
     FROM   igs_ps_unit_ver
     WHERE  unit_cd = cp_unit_cd
     AND    version_number = cp_version_number;

     CURSOR cur_wlst_same_unit(cp_person_id igs_en_su_attempt.person_id%TYPE,
                               cp_course_cd igs_en_su_attempt.course_cd%TYPE,
                               cp_unit_cd igs_en_su_attempt.unit_cd%TYPE,
                               cp_cal_type IGS_CA_INST.cal_type%TYPE,
                               cp_sequence_number IGS_CA_INST.sequence_number%TYPE,
                                cp_uoo_id igs_en_su_attempt.uoo_id%TYPE ) IS
     SELECT 'X'
     FROM igs_en_su_attempt sua
     WHERE sua.person_id = cp_person_id AND
     sua.course_cd = cp_course_cd AND
     sua.unit_cd = cp_unit_cd AND
     sua.cal_type = cp_cal_type AND
     sua.ci_sequence_number = cp_sequence_number AND
     sua.unit_attempt_status = cst_waitlisted AND
     sua.uoo_id <> cp_uoo_id;

    CURSOR cur_simul_wlst_flag IS
    SELECT simultaneous_wlst_alwd_flag
    FROM  igs_en_inst_wl_stps;

    CURSOR cur_simul_term_wlst_flag(p_load_cal_type IGS_CA_INST.cal_type%TYPE) IS
    SELECT 'X'
    FROM igs_en_inst_wlst_opt
    WHERE cal_type = p_load_cal_type AND
          smlnes_waitlist_alwd = 'N';

    CURSOR cur_simul_org_allwd(cp_load_cal_type IGS_CA_INST.cal_type%TYPE,
                               cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
    SELECT smtanus_wlst_unit_enr_alwd
    FROM igs_En_or_unit_wlst
    WHERE cal_type = cp_load_cal_type AND
    closed_flag = 'N' AND
    org_unit_cd = (SELECT nvl(uoo.owner_org_unit_Cd, uv.owner_org_unit_cd)
                   FROM igs_ps_unit_ofr_opt uoo,
                   igs_ps_unit_ver uv
                   WHERE uoo.uoo_id = cp_uoo_id AND
                   uv.unit_cd = uoo.unit_cd AND
                   uv.version_number = uoo.version_number);

    v_max_wlst_stud IGS_EN_INST_WL_STPS.max_waitlists_student_num%type;
    v_count_wlst_stud NUMBER;
    v_mus_allwd igs_ps_unit_ver.same_teaching_period%type;
    v_simul_wlst_flag VARCHAR(1);
    v_wlst_same_unit VARCHAR2(1);
    v_simul_term_wlst_flag VARCHAR2(1);
    v_simul_org_allwd VARCHAR2(1);

   l_prog_version_spat       igs_en_stdnt_ps_att.version_number%TYPE;

   BEGIN

     OPEN usec_upd_enr_act(new_references.uoo_id);
     FETCH usec_upd_enr_act INTO usec_row;
     CLOSE usec_upd_enr_act;


     --Get the maximum audit enrollments for the unit section
     OPEN c_max_auditors_allowed(usec_row.uoo_id);
     FETCH c_max_auditors_allowed INTO l_max_auditors_allowed;
     CLOSE c_max_auditors_allowed;

     --Get the count of Audit attempts
     OPEN c_audit_attempts_count(usec_row.uoo_id);
     FETCH c_audit_attempts_count INTO l_audit_attempts_count;
     CLOSE c_audit_attempts_count;

     -- Raise an exception in case the enrolled count for audit
     -- exceeds the maximum allowed number
     IF (l_audit_attempts_count > l_max_auditors_allowed) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_EN_AU_LIM_UNIT_CROSS');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;

     -- Get the Load calander for the passed Teaching calander.
     OPEN cur_teach_to_load( usec_row.cal_type, usec_row.ci_sequence_number );
     FETCH cur_teach_to_load INTO rec_teach_to_load;
     CLOSE cur_teach_to_load;

     igs_en_gen_015.get_usec_status (
        usec_row.uoo_id,
        NVL(old_references.person_id,new_references.person_ID),
        l_unit_section_status,
        l_waitlist_ind,
        rec_teach_to_load.load_cal_type,
        rec_teach_to_load.load_ci_sequence_number,
        new_references.course_cd
      );

     IF new_references.UNIT_ATTEMPT_STATUS = cst_waitlisted AND l_waitlist_ind IS NULL THEN
       usec_row := NULL;
       FND_MESSAGE.SET_NAME('IGS','IGS_EN_MAX_WAIT_REACH');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
     ELSIF ((l_waitlist_ind IS NULL OR l_waitlist_ind = 'Y') AND (new_references.UNIT_ATTEMPT_STATUS <> cst_waitlisted))  THEN
       usec_row := NULL;
       FND_MESSAGE.SET_NAME('IGS','IGS_EN_MAX_ENR_REACH');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;

     -- get the program version
     OPEN cur_get_prog_ver(new_references.person_id, new_references.course_cd);
     FETCH cur_get_prog_ver INTO l_prog_version_spat;
     CLOSE cur_get_prog_ver;

     -- get the program level max_wlst_per_stud
     OPEN cur_max_wlst_stud_ps(new_references.course_cd, l_prog_version_spat);
     FETCH cur_max_wlst_stud_ps INTO v_max_wlst_stud;
     CLOSE cur_max_wlst_stud_ps;

     -- when program level max_wlst_per_stud is not defined, proceed to insitute level max_wlst_per_stud
     IF v_max_wlst_stud IS NULL THEN
        OPEN cur_max_wlst_stud;
        FETCH cur_max_wlst_stud INTO v_max_wlst_stud;
        CLOSE cur_max_wlst_stud;
     END IF;

        OPEN cur_count_wlsts_stud(new_references.person_id,rec_teach_to_load.load_cal_type,rec_teach_to_load.load_ci_sequence_number);
        FETCH cur_count_wlsts_stud INTO v_count_wlst_stud;
        CLOSE cur_count_wlsts_stud;

   IF new_references.UNIT_ATTEMPT_STATUS = cst_waitlisted THEN
     IF nvl(v_count_wlst_Stud,0) > nvl(v_max_wlst_stud,9999) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_MAX_WLST_STUD_RCH');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
   END IF;

   --simultaneaous wailist validations
    IF new_references.UNIT_ATTEMPT_STATUS = cst_waitlisted THEN
     --check if multipls sections allwed in the same unit.
       OPEN cur_mus_allwd(new_references.unit_cd, new_references.version_number);
       FETCH cur_mus_allwd INTO v_mus_allwd;
       CLOSE cur_mus_allwd;

       IF nvl(v_mus_allwd,'N') = 'Y' THEN
          OPEN cur_wlst_same_unit(new_references.person_ID,new_references.course_cd,new_references.unit_cd,
                                  new_references.cal_type, new_references.ci_sequence_number,
                                  new_references.uoo_id);
          FETCH cur_wlst_same_unit INTO v_wlst_same_unit;
          CLOSE cur_wlst_same_unit;

          IF v_wlst_same_unit IS NOT NULL THEN
          --implies student is attempting to wailist in more than one section of same unit
          --hence check if simultaneous wailist allowed at inst level
             OPEN cur_simul_wlst_flag;
             FETCH cur_simul_wlst_flag INTO v_simul_wlst_flag;
             CLOSE cur_simul_wlst_flag;

             IF v_simul_wlst_flag = 'Y' THEN

               --check if restricted at term calendar level
                 OPEN cur_simul_term_wlst_flag(rec_teach_to_load.load_cal_type);
                 FETCH cur_simul_term_wlst_flag INTO v_simul_term_wlst_flag;
                 CLOSE cur_simul_term_wlst_flag;

                 IF v_simul_term_wlst_flag IS NOT NULL THEN --restricted hence raise error
                     FND_MESSAGE.SET_NAME('IGS','IGS_EN_SIMULT_WLST_NOT_ALLWD');
                     IGS_GE_MSG_STACK.ADD;
                     APP_EXCEPTION.RAISE_EXCEPTION;
                 ELSE
                     --check at org level if simultaneous  waitlist allowed
                      OPEN cur_simul_org_allwd(rec_teach_to_load.load_cal_type,new_references.uoo_id);
                      FETCH cur_simul_org_allwd INTO v_simul_org_allwd;
                      CLOSE cur_simul_org_allwd;

                      IF v_simul_org_allwd = 'N' THEN
                         FND_MESSAGE.SET_NAME('IGS','IGS_EN_SIMULT_WLST_NOT_ALLWD');--org level
                         IGS_GE_MSG_STACK.ADD;
                         APP_EXCEPTION.RAISE_EXCEPTION;
                      END IF;
                 END IF;

             ELSE
                 FND_MESSAGE.SET_NAME('IGS','IGS_EN_SIMULT_WLST_NOT_ALLWD');--instituion level
                 IGS_GE_MSG_STACK.ADD;
                 APP_EXCEPTION.RAISE_EXCEPTION;
             END IF;
          END IF;
        END IF;
    END IF;


  END local_usec_status;

BEGIN  ------ begin of upd_enrollment_counts procedure

  IF p_action = 'INSERT' THEN
    IF (new_references.UNIT_ATTEMPT_STATUS IN (cst_enrolled, cst_invalid, cst_completed)) OR
      (new_references.UNIT_ATTEMPT_STATUS = cst_unconfirm AND new_references.CART = 'N') THEN
       local_usec_status (old_references, new_references,usec_row);
       usec_row.ENROLLMENT_ACTUAL := NVL(usec_row.ENROLLMENT_ACTUAL, 0) + 1;
       local_update_unit_section(p_action, old_references, new_references, usec_row);
    ELSIF new_references.UNIT_ATTEMPT_STATUS = cst_waitlisted THEN
       local_usec_status (old_references, new_references,usec_row);
       usec_row.WAITLIST_ACTUAL := NVL(usec_row.WAITLIST_ACTUAL, 0) + 1;
       local_update_unit_section(p_action, old_references, new_references, usec_row);
    END IF;


  ELSIF p_action = 'UPDATE' THEN
      IF (old_references.UNIT_ATTEMPT_STATUS IN (cst_dropped,cst_discontin,cst_duplicate, cst_waitlisted) AND
          new_references.UNIT_ATTEMPT_STATUS IN (cst_enrolled,cst_invalid,cst_completed) ) OR
         (old_references.UNIT_ATTEMPT_STATUS = cst_unconfirm AND
          new_references.UNIT_ATTEMPT_STATUS = cst_unconfirm AND
          new_references.CART IN ('S','I','J') AND NVL(old_references.CART,'X') <> 'N') THEN

            local_usec_status (old_references, new_references,usec_row);
            usec_row.ENROLLMENT_ACTUAL := NVL(usec_row.ENROLLMENT_ACTUAL, 0) + 1;
            IF old_references.UNIT_ATTEMPT_STATUS = cst_waitlisted THEN
               usec_row.WAITLIST_ACTUAL := NVL(usec_row.WAITLIST_ACTUAL, 0) - 1;
            END IF;
            local_update_unit_section(p_action, old_references, new_references, usec_row);

      ELSIF ( old_references.UNIT_ATTEMPT_STATUS IN (cst_enrolled, cst_invalid,cst_completed, cst_unconfirm ) AND
              new_references.UNIT_ATTEMPT_STATUS IN (cst_dropped,cst_discontin,cst_duplicate, cst_waitlisted) ) THEN


          IF (old_references.UNIT_ATTEMPT_STATUS = cst_unconfirm AND
             new_references.UNIT_ATTEMPT_STATUS = cst_waitlisted) THEN
             NULL;
          ELSE
            OPEN usec_upd_enr_act(new_references.uoo_id);
            FETCH usec_upd_enr_act INTO usec_row;
            CLOSE usec_upd_enr_act;
            usec_row.ENROLLMENT_ACTUAL := NVL(usec_row.ENROLLMENT_ACTUAL, 0) - 1;
          END IF;

          IF new_references.UNIT_ATTEMPT_STATUS = cst_waitlisted THEN
            local_usec_status (old_references, new_references,usec_row);
            usec_row.WAITLIST_ACTUAL := NVL(usec_row.WAITLIST_ACTUAL, 0) + 1;
          END IF;
          local_update_unit_section(p_action, old_references, new_references, usec_row);

      ELSIF ( old_references.UNIT_ATTEMPT_STATUS = cst_waitlisted AND
           new_references.UNIT_ATTEMPT_STATUS <> old_references.UNIT_ATTEMPT_STATUS ) THEN
        OPEN usec_upd_enr_act(new_references.uoo_id);
        FETCH usec_upd_enr_act INTO usec_row;
        CLOSE usec_upd_enr_act;
        usec_row.WAITLIST_ACTUAL := NVL(usec_row.WAITLIST_ACTUAL, 0) - 1;
        local_update_unit_section(p_action, old_references, new_references, usec_row);
      -- End of new code, Added as per the Bug# 2373469.
      END IF;

  ELSIF   p_action = 'DELETE' THEN
    IF (old_references.UNIT_ATTEMPT_STATUS IN (cst_enrolled,cst_unconfirm,cst_invalid, cst_completed)) THEN
      OPEN usec_upd_enr_act(old_references.uoo_id);
      FETCH usec_upd_enr_act INTO usec_row;
      CLOSE usec_upd_enr_act;
      usec_row.ENROLLMENT_ACTUAL := NVL(usec_row.ENROLLMENT_ACTUAL, 0) - 1;
      local_update_unit_section(p_action, old_references, new_references, usec_row);
    ELSIF (old_references.UNIT_ATTEMPT_STATUS IN (cst_waitlisted)) THEN
      OPEN usec_upd_enr_act(old_references.uoo_id);
      FETCH usec_upd_enr_act INTO usec_row;
      CLOSE usec_upd_enr_act;
      usec_row.WAITLIST_ACTUAL := NVL(usec_row.WAITLIST_ACTUAL, 0) - 1;
      local_update_unit_section(p_action, old_references, new_references, usec_row);
    END IF;

  END IF;



END upd_enrollment_counts;

PROCEDURE CREATE_UNIT_ATTEMPT (
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
  X_GS_VERSION_NUMBER IN NUMBER     ,
  X_ENR_METHOD_TYPE  IN VARCHAR2    ,
  X_FAILED_UNIT_RULE IN VARCHAR2    ,
  X_CART             IN VARCHAR2    ,
  X_RSV_SEAT_EXT_ID  IN NUMBER      ,
  X_ORG_UNIT_CD  IN VARCHAR2        ,
  X_GRADING_SCHEMA_CODE IN VARCHAR2 ,
  X_SUBTITLE            IN VARCHAR2 ,
  X_SESSION_ID          IN NUMBER ,
  X_DEG_AUD_DETAIL_ID   IN NUMBER   ,
  X_STUDENT_CAREER_TRANSCRIPT IN VARCHAR2 ,
  X_STUDENT_CAREER_STATISTICS IN VARCHAR2 ,
  X_WAITLIST_MANUAL_IND IN VARCHAR2 ,
  X_ATTRIBUTE_CATEGORY IN VARCHAR2 ,
  X_ATTRIBUTE1  IN VARCHAR2 ,
  X_ATTRIBUTE2  IN VARCHAR2 ,
  X_ATTRIBUTE3  IN VARCHAR2 ,
  X_ATTRIBUTE4  IN VARCHAR2 ,
  X_ATTRIBUTE5  IN VARCHAR2 ,
  X_ATTRIBUTE6  IN VARCHAR2 ,
  X_ATTRIBUTE7  IN VARCHAR2 ,
  X_ATTRIBUTE8  IN VARCHAR2 ,
  X_ATTRIBUTE9  IN VARCHAR2 ,
  X_ATTRIBUTE10  IN VARCHAR2,
  X_ATTRIBUTE11  IN VARCHAR2,
  X_ATTRIBUTE12  IN VARCHAR2,
  X_ATTRIBUTE13  IN VARCHAR2,
  X_ATTRIBUTE14  IN VARCHAR2,
  X_ATTRIBUTE15  IN VARCHAR2,
  X_ATTRIBUTE16  IN VARCHAR2,
  X_ATTRIBUTE17  IN VARCHAR2,
  X_ATTRIBUTE18  IN VARCHAR2,
  X_ATTRIBUTE19  IN VARCHAR2,
  x_ATTRIBUTE20  IN VARCHAR2,
  X_WLST_PRIORITY_WEIGHT_NUM IN NUMBER,
  X_WLST_PREFERENCE_WEIGHT_NUM IN NUMBER,
  X_CORE_INDICATOR_CODE IN VARCHAR2
  ) AS
  ------------------------------------------------------------------------------------------------
  --rvangala        07-OCT-2003      Value for CORE_INDICATOR_CODE passed to IGS_EN_SU_ATTEMPT_PKG.UPDATE_ROW
  --                                 and IGS_EN_SU_ATTEMPT_PKG.INSERT_ROW added as part of Prevent Dropping Core Units. Enh Bug# 3052432
  ------------------------------------------------------------------------------------------------

  new_references    EN_SUA_REC_TYPE%TYPE;


BEGIN
    SAVEPOINT create_unit_attempt;
    IGS_EN_SU_ATTEMPT_PKG.INSERT_ROW (
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
     x_session_id,
     X_deg_aud_detail_id  ,
     x_student_career_transcript,
     x_student_career_statistics,
     X_WAITLIST_MANUAL_IND,
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
     X_WLST_PRIORITY_WEIGHT_NUM ,
     X_WLST_PREFERENCE_WEIGHT_NUM,
     X_CORE_INDICATOR_CODE,
     'N', -- for UPD_AUDIT_IND
     'A' -- for SS_SOURCE_IND
  );

  OPEN C_SUA (X_ROWID);
  FETCH C_SUA INTO new_references;
  CLOSE C_SUA;

  upd_enrollment_counts('INSERT',
                         NULL,
                         new_references);
EXCEPTION
        WHEN OTHERS THEN
             ROLLBACK TO create_unit_attempt;
             RAISE;
END create_unit_attempt;

PROCEDURE UPDATE_UNIT_ATTEMPT (
  X_ROWID IN VARCHAR2,
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
  X_GS_VERSION_NUMBER    IN NUMBER   ,
  X_ENR_METHOD_TYPE      IN VARCHAR2 ,
  X_FAILED_UNIT_RULE     IN VARCHAR2 ,
  X_CART                 IN VARCHAR2 ,
  X_RSV_SEAT_EXT_ID      IN NUMBER   ,
  X_ORG_UNIT_CD              IN VARCHAR2 ,
  X_GRADING_SCHEMA_CODE  IN VARCHAR2 ,
  X_SUBTITLE                 IN VARCHAR2 ,
  X_SESSION_ID           IN NUMBER   ,
  X_DEG_AUD_DETAIL_ID    IN NUMBER   ,
  X_STUDENT_CAREER_TRANSCRIPT IN VARCHAR2 ,
  X_STUDENT_CAREER_STATISTICS IN VARCHAR2 ,
  X_WAITLIST_MANUAL_IND     IN VARCHAR2,
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
  X_ATTRIBUTE20 IN VARCHAR2,
  X_WLST_PRIORITY_WEIGHT_NUM IN NUMBER,
  X_WLST_PREFERENCE_WEIGHT_NUM IN NUMBER,
  X_CORE_INDICATOR_CODE IN VARCHAR2
  ) AS

  old_references    EN_SUA_REC_TYPE%TYPE;
  new_references    EN_SUA_REC_TYPE%TYPE;

  -- cursor to get person type
  CURSOR cur_per_typ IS
  SELECT person_type_code
  FROM igs_pe_person_types
  WHERE system_type = 'OTHER';
  l_cur_per_typ cur_per_typ%ROWTYPE;
  lv_person_type igs_pe_person_types.person_type_code%TYPE;

  -- cursor tp get system person type
  CURSOR cur_sys_pers_type(cp_person_type_code VARCHAR2) IS
  SELECT system_type
  FROM igs_pe_person_types
  WHERE person_type_code = cp_person_type_code;

	l_sys_per_type		igs_pe_person_types.system_type%TYPE;

  -- added for bug 3526251
  NO_AUSL_RECORD_FOUND EXCEPTION;
  PRAGMA EXCEPTION_INIT(NO_AUSL_RECORD_FOUND , -20010);

BEGIN


  OPEN C_SUA (X_ROWID);
  FETCH C_SUA INTO old_references;
  CLOSE C_SUA;

  IF X_UNIT_ATTEMPT_STATUS = 'ENROLLED' AND old_references.SS_SOURCE_IND = 'S' THEN

    OPEN cur_per_typ;
    FETCH cur_per_typ INTO l_cur_per_typ;
    lv_person_type := NVL(Igs_En_Gen_008.enrp_get_person_type(X_COURSE_CD),l_cur_per_typ.person_type_code);
    CLOSE cur_per_typ;

    OPEN cur_sys_pers_type(lv_person_type);
    FETCH cur_sys_pers_type INTO l_sys_per_type;
    CLOSE cur_sys_pers_type;

    IF l_sys_per_type = 'STUDENT' THEN
      old_references.SS_SOURCE_IND := 'N';
    ELSE
      old_references.SS_SOURCE_IND := 'A';
    END IF;

  END IF;

 SAVEPOINT update_unit_attempt;

 IGS_EN_SU_ATTEMPT_PKG.UPDATE_ROW (
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
   x_session_id,
   X_deg_aud_detail_id  ,
   x_student_career_transcript,
   x_student_career_statistics,
   X_WAITLIST_MANUAL_IND,
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
   X_WLST_PRIORITY_WEIGHT_NUM,
   X_WLST_PREFERENCE_WEIGHT_NUM,
   X_CORE_INDICATOR_CODE,
   old_references.UPD_AUDIT_FLAG,
   old_references.SS_SOURCE_IND
  );

   -- 	smaddali 8-dec-2005   added condition to  bypass update of seat counts  for DROP : bug#4864437
   -- this code is being commented here but will be replicated in Drop page
  -- StdDropAMImpl.java:dropSubmit
  --bdeviset  26-APR-2006  Modified if condition for bug# 5119136
  IF X_UNIT_ATTEMPT_STATUS NOT IN ('DROPPED','DISCONTIN' ) OR
     NVL(igs_en_su_attempt_pkg.pkg_source_of_drop,'NULL') <>'DROP' THEN
     OPEN C_SUA (X_ROWID);
     FETCH C_SUA INTO new_references;
    CLOSE C_SUA;

    upd_enrollment_counts('UPDATE',
                         old_references,
                         new_references);
  END IF;

EXCEPTION
        -- added for bug 3526251
        WHEN NO_AUSL_RECORD_FOUND THEN
               ROLLBACK TO update_unit_attempt;
               RAISE;
        WHEN OTHERS THEN
               ROLLBACK TO update_unit_attempt;
               RAISE;
END update_unit_attempt;

FUNCTION Enr_sua_sup_sub_val(
P_PERSON_ID     IN      NUMBER,
P_COURSE_CD     IN      VARCHAR2,
P_UOO_ID        IN      NUMBER,
P_UNIT_ATTEMPT_STATUS   IN      VARCHAR2,
P_SUP_SUB_STATUS        OUT     NOCOPY VARCHAR2
) RETURN BOOLEAN AS

 /*************************************************************
   Created By : Satya Vanukuri, IDC
   Date Created By :11-OCT-2003
   Purpose :validates the context student unit attempt status against superior and subordinate unit section relationships.
   Function returns true if unit attempt status is valid otherwise returns false
   Know limitations, enhancements or remarks
   Change History
   Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/
        CURSOR cur_rel_type IS
        SELECT relation_type
        FROM igs_ps_unit_ofr_opt
        WHERE uoo_id = p_uoo_Id;

       l_rel_type igs_ps_unit_ofr_opt.relation_type%TYPE;

       l_sub_uoo igs_ps_unit_ofr_opt.uoo_id%TYPE;

       CURSOR cur_sub_uoo IS
       SELECT sua.uoo_id sub_uoo_id, sua.unit_attempt_status sub_uoo_status
       FROM igs_en_su_attempt sua, igs_ps_unit_ofr_opt uoo
       WHERE uoo.sup_uoo_id = p_uoo_id
       AND uoo.relation_type = 'SUBORDINATE'
       AND sua.uoo_id = uoo.uoo_id
       AND sua.person_id = p_person_id
       AND sua.course_cd = p_course_cd
       AND sua.unit_attempt_status <> 'DUPLICATE';

       l_sub_uoo_status igs_en_su_attempt.unit_attempt_status%TYPE;

       CURSOR cur_sup_uoo IS
       SELECT uoo.sup_uoo_id sup_uoo_id, sua.unit_attempt_status sup_uoo_status
       FROM   igs_en_su_attempt sua, igs_ps_unit_ofr_opt uoo
       WHERE uoo.uoo_id = p_uoo_id
       AND uoo.sup_uoo_id = sua.uoo_id
       AND sua.person_id = p_person_id
       AND sua.course_cd = p_course_cd;

        l_sup_uoo_Id igs_ps_unit_ofr_opt.uoo_id%TYPE;
       l_sup_attempt_status igs_en_su_attempt.unit_attempt_status%TYPE;


  BEGIN
  --initialize out parameter
  P_SUP_SUB_STATUS := NULL;
  --get the relation type for unit
        OPEN cur_rel_type;
        FETCH cur_rel_type INTO l_rel_type;
        CLOSE cur_rel_type;
--if NONE implies unit is neither superior nor sub, hence return true
        IF nvl(l_rel_type,'NONE') = 'NONE' THEN
            RETURN TRUE;
   --unit is neither sup nor sub

--validate subordinate unit status if context unit is superior
        ELSIF l_rel_type = 'SUPERIOR' THEN
                OPEN cur_sub_uoo;
                LOOP
                    --fetch the sub unit sections attempted and their status
                    FETCH cur_sub_uoo INTO l_sub_uoo,l_sub_uoo_status;
                    EXIT WHEN cur_sub_uoo%NOTFOUND;

                    --validate the sub attmept status against the sup attempt status passed as parameter to function
                    IF p_unit_attempt_status = 'ENROLLED' THEN
                       RETURN TRUE;

                    ELSIF p_unit_attempt_status = 'WAITLISTED' THEN
                       IF l_sub_uoo_status NOT IN ('UNCONFIRM','DROPPED') THEN
                           p_sup_sub_status := l_sub_uoo_status;
                           RETURN FALSE;
                       ELSE
                           RETURN TRUE;
                       END IF;
                   ELSIF p_unit_attempt_status = 'UNCONFIRM' THEN
                       IF  l_sub_uoo_status NOT IN ('UNCONFIRM','DROPPED') THEN
                           p_sup_sub_status := l_sub_uoo_status;
                           RETURN FALSE;
                       ELSE
                           RETURN TRUE;
                       END IF;

                   ELSIF p_unit_attempt_status = 'COMPLETED' THEN
                       IF  l_sub_uoo_status NOT IN ('DISCONTIN', 'COMPLETED', 'DROPPED') THEN
                           p_sup_sub_status := l_sub_uoo_status;
                           RETURN FALSE;
                       ELSE
                           RETURN TRUE;
                       END IF;
                   ELSIF p_unit_attempt_status = 'DROPPED' THEN
                       IF  l_sub_uoo_status NOT IN ('DROPPED','INVALID') THEN
                           p_sup_sub_status := l_sub_uoo_status;
                           RETURN FALSE;
                       ELSE
                           RETURN TRUE;
                       END IF;

                  ELSIF p_unit_attempt_status = 'DISCONTIN' THEN
                       IF  l_sub_uoo_status NOT IN ('DROPPED','INVALID','DISCONTIN','COMPLETED') THEN
                           p_sup_sub_status := l_sub_uoo_status;
                           RETURN FALSE;
                       ELSE
                           RETURN TRUE;
                       END IF;
                  ELSIF p_unit_attempt_status = 'DUPLICATE' THEN
                       IF  l_sub_uoo_status NOT IN ('DROPPED','DISCONTIN') THEN
                            p_sup_sub_status := l_sub_uoo_status;
                            RETURN FALSE;
                       ELSE
                            RETURN TRUE;
                       END IF;
                 ELSIF p_unit_attempt_status = 'INVALID' THEN
                       IF  l_sub_uoo_status NOT IN ('DROPPED','DISCONTIN','INVALID','UNCONFIRM','WAITLISTED','COMPLETED') THEN
                           p_sup_sub_status := l_sub_uoo_status;
                           RETURN FALSE;
                       ELSE
                           RETURN TRUE;
                       END IF;
                 ELSE
                      RETURN TRUE;
                  END IF;
             END LOOP;
       CLOSE cur_sub_uoo;
             RETURN TRUE;


     --validate superior unit status if context unit is subordinate
        ELSIF l_rel_type = 'SUBORDINATE' THEN
              --fetch the superior unit attempt status
               OPEN cur_sup_uoo;
               FETCH cur_sup_uoo INTO l_sup_uoo_Id, l_sup_attempt_status;
               CLOSE cur_sup_uoo;
               IF l_sup_uoo_Id IS NULL THEN
               RETURN FALSE;
               END IF;
               IF p_unit_attempt_status = 'ENROLLED' THEN
                  IF l_sup_attempt_status <> 'ENROLLED' THEN
                     p_sup_sub_status := l_sup_attempt_status;
                     RETURN FALSE;
                  ELSE
                     RETURN TRUE;
                  END IF;
               ELSIF p_unit_attempt_status = 'WAITLISTED' THEN
                  IF l_sup_attempt_status <> 'ENROLLED' THEN
                     p_sup_sub_status := l_sup_attempt_status;
                     RETURN FALSE;
                  ELSE
                     RETURN TRUE;
                  END IF;
               ELSIF p_unit_attempt_status = 'UNCONFIRM' THEN
                  IF l_sup_attempt_status NOT IN('UNCONFIRM','INVALID','WAITLISTED','ENROLLED') THEN
                     p_sup_sub_status := l_sup_attempt_status;
                     RETURN FALSE;
                  ELSE
                     RETURN TRUE;
                  END IF;
               ELSIF p_unit_attempt_status = 'COMPLETED' THEN
                  IF l_sup_attempt_status NOT IN ('COMPLETED','ENROLLED' ) THEN
                     p_sup_sub_status := l_sup_attempt_status;
                     RETURN FALSE;
                  ELSE
                     RETURN TRUE;
                  END IF;
                ELSIF p_unit_attempt_status = 'DROPPED' THEN

                     RETURN TRUE;

               ELSIF p_unit_attempt_status = 'DISCONTIN' THEN
                  IF l_sup_attempt_status NOT IN ('COMPLETED','ENROLLED', 'DISCONTIN','INVALID') THEN
                     p_sup_sub_status := l_sup_attempt_status;
                     RETURN FALSE;
                   ELSE
                     RETURN TRUE;
                  END IF;
               ELSIF p_unit_attempt_status = 'DUPLICATE' THEN
                  IF l_sup_attempt_status <>  'DUPLICATE' THEN
                     p_sup_sub_status := l_sup_attempt_status;
                     RETURN FALSE;
                  ELSE
                     RETURN TRUE;
                  END IF;
              ELSIF p_unit_attempt_status = 'INVALID' THEN
                  IF l_sup_attempt_status NOT IN ('DROPPED','ENROLLED', 'DISCONTIN','INVALID') THEN
                     p_sup_sub_status := l_sup_attempt_status;
                     RETURN FALSE;
                   ELSE
                     RETURN TRUE;
                  END IF;
              ELSE
              RETURN TRUE;
              END IF;
          END IF;

 EXCEPTION
 WHEN OTHERS THEN
   IF cur_sup_uoo%ISOPEN THEN
     close cur_sup_uoo;
   END IF;
IF cur_sub_uoo%ISOPEN THEN
     close cur_sub_uoo;
   END IF;
    RAISE;
END Enr_sua_sup_sub_val;

FUNCTION chk_sup_del_alwd(p_person_id IN NUMBER,
p_course_cd IN VARCHAR2,
p_uoo_id IN NUMBER) RETURN BOOLEAN AS
  /*
  ||  Created By : svanukur
  ||  Created On :
  ||  Purpose : to check if deletion of superior is allwd.
  ||            a superior unit cannot be deleted if subordinate is
  ||             in any status other than dropped or discontinued.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

CURSOR cur_chk_sup IS
SELECT relation_type
FROM igs_ps_unit_ofr_opt
WHERE uoo_id = p_uoo_Id;

CURSOR cur_sub IS
SELECT  sua.unit_attempt_status
FROM igs_ps_unit_ofr_opt uoo,
igs_en_su_attempt sua
WHERE uoo.sup_uoo_id = p_uoo_id
AND uoo.relation_type = 'SUPERIOR'
AND sua.uoo_id = uoo.uoo_id
AND sua.person_Id = p_person_id
AND sua.course_cd = p_course_cd
AND sua.unit_attempt_status NOT IN ('DROPPED','DUPLICATE');

v_sub_status igs_en_su_attempt.unit_attempt_status%TYPE;
v_sup igs_ps_unit_ofr_opt.relation_type%TYPE;

BEGIN

OPEN cur_chk_sup;
FETCH cur_chk_sup INTO v_sup;
CLOSE cur_chk_sup;

  IF  v_sup = 'SUPERIOR' THEN
  --chk subordinate unit attempt status
       OPEN cur_sub;
       FETCH cur_sub INTO v_sub_status;
       CLOSE cur_sub;

       IF v_sub_status IS NOT NULL THEN
        RETURN FALSE;
      END IF;

  END IF;
RETURN TRUE ;

EXCEPTION
  WHEN others THEN
    IF cur_chk_sup%ISOPEN THEN
    close cur_chk_sup;
    END IF;
    IF cur_sub%ISOPEN THEN
    close cur_sub;
    END IF;
     RAISE;
END chk_sup_del_alwd;


END igs_en_sua_api;

/
