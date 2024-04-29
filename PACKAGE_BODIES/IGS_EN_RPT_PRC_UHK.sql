--------------------------------------------------------
--  DDL for Package Body IGS_EN_RPT_PRC_UHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_RPT_PRC_UHK" AS
/* $Header: IGSEN84B.pls 120.0 2005/06/01 20:21:22 appldev noship $ */


  --  User Hook - which can be customisable by the customer.
  --
  --  This function returns the Derived Completion Date which in turn
  --  is to be passed back to the calling program unit. This function
  --  is to be called from the API IGS_EN_GEN_015.ENRP_DRV_CMPL_DT.
  --  If the Derived Completion Date is not manually overridden in
  --  Student Enrollment form (IGSEN022), then the API
  --  IGS_EN_GEN_015.ENRP_DRV_CMPL_DT is called and the return value
  --  is shown in the form to the user, but it is not stored anywhere in
  --  the database. The User Hook should not be directly called from
  --  any where in the code, instead the API should be used.
  --  Who         When            What
  --  bdeviset    04-AUG-2004     Removed function repeat_allowed  and added function
  --                              repeat_reenroll_allowed as part of Bug 3620784


 FUNCTION enrf_drv_cmpl_dt_uhk
  (
    p_person_id			   IN	  NUMBER,
    p_course_cd			   IN	  VARCHAR2,
    p_achieved_cp		   IN	  NUMBER,
    p_attendance_type		   IN     VARCHAR2,
    p_load_cal_type                IN     VARCHAR2,
    p_load_ci_seq_number           IN     NUMBER,
    p_load_ci_alt_code		   IN     VARCHAR2,
    p_load_ci_start_dt		   IN	  DATE,
    p_load_ci_end_dt		   IN	  DATE,
    p_init_load_cal_type	   IN	  VARCHAR2,
    p_init_load_ci_seq_num	   IN	  NUMBER,
    p_init_load_ci_alt_code        IN     VARCHAR2,
    p_init_load_ci_start_dt	   IN     DATE,
    p_init_load_ci_end_dt	   IN     DATE
  ) RETURN DATE IS
  --
  --  Parameters Description:
  --
  --  p_person_id		   -> Person Identifier
  --  p_course_cd		   -> Program code
  --  p_achieved_cp		   -> Credit point achieved
  --  p_attendance_type		   -> Attendance Type
  --  p_load_cal_type              -> Term or Load Calendar Type
  --  p_load_ci_seq_number         -> Term or Load Calendar Type Sequence Number
  --  p_load_ci_alt_code	   -> Load Calendar Alternate Code
  --  p_load_ci_start_dt	   -> Load Calendar Start Date
  --  p_load_ci_end_dt		   -> Load Calendar End Date
  --  p_init_load_cal_type	   -> Initial Load Calendar
  --  p_init_load_ci_seq_num	   -> Initial Load Sequence Number
  --  p_init_load_ci_alt_code      -> Initial Load Alternate Code
  --  p_init_load_ci_start_dt	   -> Initial Load Start Date
  --  p_init_load_ci_end_dt	   -> Initial Load End Date
  --

  BEGIN

    -- PUT YOUR CODE HERE
     RETURN NULL;

  END enrf_drv_cmpl_dt_uhk;


  FUNCTION repeat_reenroll_allowed (
    p_person_id                    IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_repeat_reenroll              IN     VARCHAR2,
    p_load_cal_type                IN     VARCHAR2,
    p_load_ci_seq_number           IN     NUMBER,
    p_mus_ind                      IN     VARCHAR2,
    p_reenroll_max                 IN     NUMBER,
    p_reenroll_max_cp              IN     NUMBER,
    p_repeat_max                   IN     NUMBER,
    p_repeat_funding               IN     NUMBER,
    p_same_tch_reenroll_max        IN     NUMBER,
    p_same_tch_reenroll_max_cp     IN     NUMBER,
    p_message                      OUT    NOCOPY VARCHAR2
   ) RETURN BOOLEAN IS
  --------------------------------------------------------------------------------
  --Created by  : bdeviset
  --Date created: 04-AUG-2004
  --
  --Purpose:   User Hook - which is customisable by the customer.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --stutta  11-8-2004   Modifying user hook to return true for testing. Would
  --                    be reverting back to return null. bug #3826194
  --------------------------------------------------------------------------------
  -- p_repeat_reenroll   ->  is used to identify whether the user hook call is made to validate a repeatable unit
  --                         a reenrollable unit. p_repeat_reenroll is passed as 'REPEAT' for repeatable units and
  --                         'REENROLL' for reenrollable units.
  -- p_mus_ind           ->  indicates whether the unit section allows enrollment into multiple unit sections after
  --                         considering 'Exclude from Multiple Unit Section'  indicator at unit section level.
  --                         p_mus_ind = 'Y'  if Multiple Unit Section is checked at unit level and Exclude from
  --                         Multiple Unit section in not checked at unit section level.
  --                         p_mus_ind = 'N' if Multiple Unit Section is not set at unit level or  Multiple Unit
  --                         section set a unit level, but excluded at unit section level.
  -- All other parameter values are fetched from the repeat/reenroll setup done at unit level.
/*  CURSOR cur_unit_details IS
      SELECT   unit_cd,
               version_number,
               cal_type,
               ci_sequence_number
      FROM     igs_ps_unit_ofr_opt
      WHERE    uoo_id = p_uoo_id;

    --
    --  Cursor to select all the reenrolled Unit Attempts of the Student.
        -- when the unit is added to the cart , the uncinfirmed unit attempt is created with cart = null.
    -- hence when calculating re-enrollment/repeat limits we should ignore the current unit which has been added to the cart from the limits check.
    -- the condition cart is not null does this .
  CURSOR cur_student_attempts_reenroll (
         cp_unit_cd   igs_ps_unit_ver.unit_cd%TYPE,
         cp_version_number igs_ps_unit_ver.version_number%TYPE
       ) IS
  SELECT  sua.unit_cd,
          sua.version_number,
          sua.cal_type,
          sua.ci_sequence_number,
          sua.uoo_id,
          NVL(sua.override_enrolled_cp,NVL(cps.enrolled_credit_points,uv.enrolled_credit_points))  override_enrolled_cp ,
          sua.course_cd
  FROM     igs_en_su_attempt sua,
           igs_ps_unit_ver uv,
           igs_ps_usec_cps cps
  WHERE    sua.person_id = p_person_id
  AND      sua.unit_cd = uv.unit_cd
  AND      sua.version_number = uv.version_number
  AND      sua.unit_cd = cp_unit_cd
  AND      sua.version_number = cp_version_number
  AND      sua.uoo_id = cps.uoo_id(+)
  AND      sua.unit_attempt_status IN ('ENROLLED', 'DISCONTIN','COMPLETED','INVALID','UNCONFIRM')
  AND      sua.cart IS NOT NULL;


  rec_cur_unit_details cur_unit_details%ROWTYPE;
  l_no_of_reenrollments NUMBER;
  l_total_reenroll_credit_points NUMBER;
  l_same_tp_cp NUMBER;
  l_same_tp_reenrollments NUMBER; */
  BEGIN
    -- PUT YOUR CODE HERE
 /*   OPEN cur_unit_details;
    FETCH cur_unit_details INTO rec_cur_unit_details;
    CLOSE cur_unit_details;
    -- This is sample code for REENROLL
    IF  (p_repeat_reenroll = 'REENROLL') THEN
         l_no_of_reenrollments := 0;
         l_total_reenroll_credit_points := 0;
         l_same_tp_cp := 0;
         l_same_tp_reenrollments := 0;
         FOR rec_cur_student_attempts IN cur_student_attempts_reenroll(rec_cur_unit_details.unit_cd, rec_cur_unit_details.version_number) LOOP
            l_total_reenroll_credit_points := l_total_reenroll_credit_points + rec_cur_student_attempts.override_enrolled_cp;
            l_no_of_reenrollments := l_no_of_reenrollments + 1;
            IF ((rec_cur_unit_details.cal_type = rec_cur_student_attempts.cal_type) AND
              (rec_cur_unit_details.ci_sequence_number = rec_cur_student_attempts.ci_sequence_number)) THEN
                 l_same_tp_cp := l_same_tp_cp +  rec_cur_student_attempts.override_enrolled_cp;
                 l_same_tp_reenrollments  := l_same_tp_reenrollments + 1 ;
            END IF;
         END LOOP;
         IF l_no_of_reenrollments > p_reenroll_max THEN
            RETURN FALSE;
         ELSIF  l_same_tp_reenrollments  > p_same_tch_reenroll_max THEN
            RETURN FALSE;
         ELSIF l_same_tp_cp > p_same_tch_reenroll_max_cp THEN
            RETURN FALSE;
         ELSIF l_total_reenroll_credit_points > p_reenroll_max_cp THEN
            RETURN FALSE;
         END IF;
         RETURN TRUE;
     ELSIF (p_repeat_reenroll = 'REPEAT') THEN
        -- Similarly specific REPEAT processing can also be coded.
        RETURN TRUE;
    END IF; */

    RETURN NULL;
  END repeat_reenroll_allowed;


END igs_en_rpt_prc_uhk;

/
