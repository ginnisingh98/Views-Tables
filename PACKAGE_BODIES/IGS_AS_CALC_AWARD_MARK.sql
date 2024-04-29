--------------------------------------------------------
--  DDL for Package Body IGS_AS_CALC_AWARD_MARK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_CALC_AWARD_MARK" AS
/* $Header: IGSAS57B.pls 120.5 2006/07/31 07:33:11 ijeddy ship $ */
  /*************************************************************
  Created By : smanglm
  Date Created on : 10-Oct-2003
  Purpose : This package is created as part iof Summary Measurement
            of attainment build.
            This will have program unit to calculate
            unit level marks,
            award marks and honors level.
  Change History
  Who             When            What
  Nalin Kumar     10-Feb-2004     Modified the fn_calc_unit_lvl_mark function to fix Bug# 3427366
  Imran Jeddy     15-Apr-2005     Bug 4281818, Created a new function chk_if_excluded_unit.
                                  It checks if a given uoo_id, unit_cd have the reference_cd_type
                                  of SUMMEAS attached. It returns FALSE if its not and TRUE if it is.
                                  This Check is used in the following cursors:
                                   1. c_avail_cp in the function get_avail_cp.
                                   2. Cursors c_total_unt_lvl_cp_alt, REF CURSORS l_stmt_cp_based and
                                      l_stmt_priority_based and in Cursor c_unit_lvl_mark_wo_setup
                                      in function fn_calc_unit_lvl_mark
   Jitendra	  15-Jun-2005      Changed function fn_calc_unit_lvl_mark for
                                   Transfer Evaluation UI Build.
   swaghmar	  16-Jan-2006	   Bug# 4951054 - Added check for disabling the UI's

  (reverse chronological order - newest change first)
  ***************************************************************/


-- below are some private utilities program units, which will be
-- called by the main public program units

-- ===============Utilities Method Section Begins================

FUNCTION chk_if_excluded_unit (p_uoo_id           igs_en_su_attempt_all.uoo_id%TYPE,
                               p_unit_cd          igs_en_su_attempt_all.unit_cd%TYPE,
                               p_version_number   igs_en_su_attempt_all.version_number%TYPE)
RETURN VARCHAR2
IS
CURSOR C1 (cp_uoo_id           igs_en_su_attempt_all.uoo_id%TYPE,
           cp_unit_cd          igs_en_su_attempt_all.unit_cd%TYPE,
           cp_version_number   igs_en_su_attempt_all.version_number%TYPE)
IS
        SELECT 'X'
          FROM igs_ps_usec_ref_cd refcd,
               igs_ps_usec_ref usecref,
               igs_ge_ref_cd_type rct
         WHERE usecref.uoo_id = cp_uoo_id
           AND usecref.unit_section_reference_id = refcd.unit_section_reference_id
           AND refcd.reference_code_type = rct.reference_cd_type
           AND rct.s_reference_cd_type = 'SUMMEAS'
        UNION
        SELECT 'X'
          FROM igs_ps_unit_ref_cd urc, igs_ge_ref_cd_type rct
         WHERE urc.unit_cd = cp_unit_cd
           AND urc.version_number = cp_version_number
           AND urc.reference_cd_type = rct.reference_cd_type
           AND rct.s_reference_cd_type = 'SUMMEAS'
           AND NOT EXISTS ( SELECT refcd.reference_code_type
                              FROM igs_ps_usec_ref_cd refcd,
                                   igs_ps_usec_ref usecref,
                                   igs_ps_unit_ofr_opt_all opt,
                                   igs_ge_ref_cd_type rct
                             WHERE usecref.uoo_id = cp_uoo_id
                               AND usecref.unit_section_reference_id =
                                                       refcd.unit_section_reference_id
                               AND refcd.reference_code_type = rct.reference_cd_type
                               AND rct.s_reference_cd_type = 'SUMMEAS')
        UNION
        SELECT 'X'
          FROM igs_ps_us_req_ref_cd refcd,
               igs_ps_usec_ref usecref,
               igs_ps_unit_ofr_opt_all opt,
               igs_ge_ref_cd_type rct
         WHERE usecref.uoo_id = cp_uoo_id
           AND usecref.unit_section_reference_id = refcd.unit_section_reference_id
           AND refcd.reference_cd_type = rct.reference_cd_type
           AND rct.s_reference_cd_type = 'SUMMEAS'
        UNION
        SELECT 'X'
          FROM igs_ps_unitreqref_cd urc, igs_ge_ref_cd_type rct
         WHERE urc.unit_cd = cp_unit_cd
           AND urc.version_number = cp_version_number
           AND urc.reference_cd_type = rct.reference_cd_type
           AND rct.s_reference_cd_type = 'SUMMEAS'
           AND NOT EXISTS ( SELECT refcd.reference_cd_type
                            FROM igs_ps_us_req_ref_cd refcd,
                                     igs_ps_usec_ref usecref,
                                     igs_ps_unit_ofr_opt_all opt,
                                     igs_ge_ref_cd_type rct
                               WHERE usecref.uoo_id = cp_uoo_id
                                 AND usecref.unit_section_reference_id =
                                                         refcd.unit_section_reference_id
                                 AND refcd.reference_cd_type = rct.reference_cd_type
                                 AND rct.s_reference_cd_type = 'SUMMEAS');

        temp VARCHAR2(1);
BEGIN
        OPEN c1(p_uoo_id,p_unit_cd,p_version_number);
        FETCH c1 INTO temp;
        IF c1%FOUND THEN
                RETURN 'FALSE';
        ELSE
                RETURN 'TRUE';
        END IF;
        CLOSE c1;
END chk_if_excluded_unit;

FUNCTION get_mark (p_grading_schema_cd igs_as_su_stmptout.grading_schema_cd%TYPE,
                   p_gs_version_number igs_as_su_stmptout.version_number%TYPE,
                   p_grade             igs_as_su_stmptout.grade%TYPE)
RETURN NUMBER
IS

  -- cursor to get amrk from outcome table
     CURSOR c_mark (cp_grading_schema_cd igs_as_su_stmptout.grading_schema_cd%TYPE,
                    cp_gs_version_number igs_as_su_stmptout.version_number%TYPE,
                    cp_grade             igs_as_su_stmptout.grade%TYPE) IS
            SELECT upper_mark_range
            FROM   igs_as_grd_sch_grade
            WHERE  grading_schema_cd = cp_grading_schema_cd
            AND    version_number = cp_gs_version_number
            AND    grade = cp_grade;
     l_mark igs_as_grd_sch_grade.upper_mark_range%TYPE;

BEGIN
  l_mark := NULL;
  -- get the mark
  OPEN c_mark (p_grading_schema_cd,
               p_gs_version_number,
               p_grade);
  FETCH c_mark INTO l_mark;
  CLOSE c_mark;
  RETURN l_mark;
END get_mark;


FUNCTION get_unit_ver (p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE)
RETURN NUMBER
IS
   -- cursor to get the unit version number
      CURSOR c_unit_ver (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
             SELECT version_number
       FROM   igs_ps_unit_ofr_opt
       WHERE  uoo_id = cp_uoo_id;
      l_unit_ver igs_ps_unit_ofr_opt.version_number%TYPE := 1;

BEGIN
     OPEN c_unit_ver (p_uoo_id);
     FETCH c_unit_ver INTO l_unit_ver;
     CLOSE c_unit_ver;
     RETURN l_unit_ver;
END get_unit_ver;

FUNCTION get_earned_cp (p_person_id       igs_as_su_stmptout.person_id%TYPE,
                        p_course_cd       igs_as_su_stmptout.course_cd%TYPE,
                        p_unit_cd         igs_as_su_stmptout.unit_cd%TYPE,
                        p_version_number  igs_ps_unit_ver.version_number%TYPE,
                        p_unit_attempt_status igs_en_su_attempt.unit_attempt_status%TYPE,
                        p_teach_cal_type  igs_ca_inst.cal_type%TYPE,
                        p_teach_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
                        p_uoo_id          igs_ps_unit_ofr_opt.uoo_id%TYPE,
                        p_override_achievable_cp NUMBER DEFAULT NULL,
                        p_override_enrolled_cp   NUMBER DEFAULT NULL)
RETURN NUMBER IS
    -- cursor to get the cp defined at sua
    CURSOR c_sua_cp (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE,
                     cp_unit_cd igs_ps_unit_ver.unit_cd%TYPE,
                     cp_version_number igs_ps_unit_ver.version_number%TYPE) IS
           SELECT NVL(uc.achievable_credit_points,
                      NVL(uv.achievable_credit_points,
                          NVL(p_override_enrolled_cp,
                              NVL(uc.enrolled_credit_points,uv.enrolled_credit_points
                                 )
                             )
                         )
                     ) sua_cp
           FROM  igs_ps_unit_ver uv,
                 igs_ps_unit_ofr_opt uoo,
                 igs_ps_usec_cps uc
           WHERE uoo.uoo_id = cp_uoo_id
           AND   uoo.uoo_id = uc.uoo_id(+)
           AND   uv.unit_cd = cp_unit_cd
           AND   uv.version_number = cp_version_number;

    l_earned_cp   NUMBER;
    l_result_type VARCHAR2(200);


    -- OUT variables for the assp_get_sua_outcomes
    l_outcome_dt           igs_as_su_stmptout.outcome_dt%TYPE;
    l_grading_schema_cd    igs_as_su_stmptout.grading_schema_cd%TYPE;
    l_gs_version_number    igs_as_su_stmptout.version_number%TYPE;
    l_grade                igs_as_su_stmptout.grade%TYPE;
    l_mark                 igs_as_su_stmptout.mark%TYPE;
    l_origin_course_cd     igs_ps_ver.course_cd%TYPE;

BEGIN
    IF p_override_achievable_cp IS NULL THEN
       OPEN c_sua_cp (p_uoo_id,
                      p_unit_cd,
                      p_version_number);
       FETCH c_sua_cp INTO l_earned_cp;
       CLOSE c_sua_cp;
     ELSE l_earned_cp := p_override_achievable_cp;
    END IF;

    -- Use the repeat functionality to determine whether the
    -- CP is to be returned or not

    /*

 OPEN ISSUE

    */

    -- check the outcome for the unit attempt
    l_result_type := igs_as_gen_003.assp_get_sua_outcome
                     (
                        p_person_id            => p_person_id,
                        p_course_cd            => p_course_cd,
                        p_unit_cd              => p_unit_cd,
                        p_cal_type             => p_teach_cal_type,
                        p_ci_sequence_number   => p_teach_ci_sequence_number,
                        p_unit_attempt_status  => p_unit_attempt_status,
                        p_finalised_ind        => 'Y',
                        p_outcome_dt           => l_outcome_dt,
                        p_grading_schema_cd    => l_grading_schema_cd,
                        p_gs_version_number    => l_gs_version_number,
                        p_grade                => l_grade,
                        p_mark                 => l_mark,
                        p_origin_course_cd     => l_origin_course_cd,
                        p_uoo_id               => p_uoo_id,
			p_use_released_ind     => 'N'
                     );
    IF l_result_type = 'PASS' THEN
       RETURN l_earned_cp;
    ELSE  -- Result type is in WITHDRAWN, FAIL, AUDIT, INCOMP
       RETURN NULL;
    END IF;

END get_earned_cp;

FUNCTION get_avail_cp (p_person_id       igs_as_su_stmptout.person_id%TYPE,
                       p_course_cd       igs_as_su_stmptout.course_cd%TYPE,
                       p_core_ind_code   igs_pr_ul_mark_dtl.core_indicator_code%TYPE,
                       p_unit_level      igs_pr_ul_mark_cnfg.unit_level%TYPE)
RETURN NUMBER
IS
  -- cursor to get the sum of available cp
     CURSOR c_avail_cp (cp_person_id       igs_as_su_stmptout.person_id%TYPE,
                        cp_course_cd       igs_as_su_stmptout.course_cd%TYPE,
                        cp_core_ind_code   igs_pr_ul_mark_dtl.core_indicator_code%TYPE,
                        cp_unit_level      igs_pr_ul_mark_cnfg.unit_level%TYPE) IS
            SELECT SUM(
                        get_earned_cp
                          (
                            sua.person_id,
                            sua.course_cd,
                            sua.unit_cd,
                            sua.version_number,
                            sua.unit_attempt_status,
                            sua.cal_type,
                            sua.ci_sequence_number,
                            sua.uoo_id,
                            sua.override_achievable_cp,
                            sua.override_enrolled_cp
                          )
                       ) avail_cp
             FROM igs_en_su_attempt_all sua,
                  igs_ps_unit_lvl_all ul ,
                  igs_ps_unit_ver_all uv
            WHERE sua.person_id = cp_person_id
            AND   sua.course_cd = p_course_cd
            AND   NVL(sua.core_indicator_code, 'ELECTIVE')  =   cp_core_ind_code  --Core indicator filter
            AND   sua.unit_cd = uv.unit_cd
            AND   sua.version_number = uv.version_number
            AND   sua.course_cd = ul.course_cd(+)
            AND   sua.unit_cd = ul.unit_cd(+)
            AND   sua.version_number = ul.version_number(+)
            AND   NVL(UL.UNIT_LEVEL, UV.UNIT_LEVEL) = cp_unit_level
            AND   chk_if_excluded_unit (sua.uoo_id,sua.unit_cd,sua.version_number) = 'TRUE';

    l_avail_cp NUMBER:=0;
BEGIN
    OPEN c_avail_cp (p_person_id     ,
                     p_course_cd     ,
                     p_core_ind_code ,
                     p_unit_level    );
    FETCH c_avail_cp INTO l_avail_cp;
    CLOSE c_avail_cp;
    RETURN l_avail_cp;

END get_avail_cp;

-- ================Utilities Method Section Ends=================

FUNCTION fn_calc_unit_lvl_mark (
   p_person_id       IN              NUMBER,
   p_course_cd       IN              VARCHAR2,
   p_unit_level      IN              VARCHAR2,
   x_return_status   OUT NOCOPY      VARCHAR2,
   x_msg_data        OUT NOCOPY      VARCHAR2,
   x_msg_count       OUT NOCOPY      NUMBER
)
   RETURN NUMBER
IS
   /*************************************************************
   Created By : smanglm
   Date Created on : 13-Oct-2003
   Purpose : This package is created as part iof Summary Measurement
             of attainment build.
             This program unit calculate the unit level mark for the
             given
             p_person_id  -- name of the student
             p_course_cd  -- program for which the calculation is to
                             be done
             p_unit_level -- unit level for which the mark is being
                             calcualted
   Change History
   Who             When            What
   Nalin Kumar     10-Feb-2004     Modified the fn_calc_unit_lvl_mark function to fix Bug# 3427366

   (reverse chronological order - newest change first)
   ***************************************************************/

   -- ref type cursor
   TYPE ref_cur IS REF CURSOR;

   c_cp_based                   ref_cur;
   c_priority_based             ref_cur;
   l_unit_lvl_mark              NUMBER;
   l_total_unit_lvl_cp          NUMBER;
   l_total_unit_lvl_cp_config   NUMBER;
   exlude_cp                    NUMBER;

   -- CURSOR to get the COURSE CODE version NUMBER
   CURSOR c_course_version_number (
      cp_person_id   igs_en_stdnt_ps_att.person_id%TYPE,
      cp_course_cd   igs_en_stdnt_ps_att.course_cd%TYPE
   )
   IS
      SELECT version_number
        FROM igs_en_stdnt_ps_att
       WHERE person_id = cp_person_id AND course_cd = cp_course_cd;

   l_course_version_number      igs_en_stdnt_ps_att.version_number%TYPE;

   -- CURSOR to get the total unit level
   CURSOR c_total_unt_lvl_cp (
      cp_unit_level       igs_pr_ul_mark_cnfg.unit_level%TYPE,
      cp_course_cd        igs_pr_ul_mark_cnfg.course_cd%TYPE,
      cp_version_number   igs_pr_ul_mark_cnfg.version_number%TYPE
   )
   IS
      SELECT total_unit_level_credits, mark_config_id, selection_method_code
        FROM igs_pr_ul_mark_cnfg umc
       WHERE umc.unit_level = cp_unit_level
         AND (   (    umc.course_cd = cp_course_cd
                  AND umc.version_number = cp_version_number
                 )
              OR (    umc.course_cd IS NULL
                  AND umc.version_number IS NULL
                  AND NOT EXISTS ( SELECT 1
                                     FROM igs_pr_ul_mark_cnfg umc_in
                                    WHERE umc_in.unit_level = cp_unit_level
                                      AND umc_in.course_cd = cp_course_cd
                                      AND umc_in.version_number =
                                                            cp_version_number)
                 )
             );

   l_mark_config_id             igs_pr_ul_mark_cnfg.mark_config_id%TYPE;
   l_selection_method_code      igs_pr_ul_mark_cnfg.selection_method_code%TYPE;

   -- CURSOR to get the sum of earned cp in case total unit_level_credits is
   -- not available from the set up table
   CURSOR c_total_unt_lvl_cp_alt (
      cp_unit_level   igs_pr_ul_mark_cnfg.unit_level%TYPE,
      cp_course_cd    igs_pr_ul_mark_cnfg.course_cd%TYPE,
      cp_person_id    igs_en_su_attempt.person_id%TYPE,
      cp_include      VARCHAR2
   )
   IS
      SELECT SUM (
                get_earned_cp (
                   sua.person_id,
                   sua.course_cd,
                   sua.unit_cd,
                   sua.version_number,
                   sua.unit_attempt_status,
                   sua.cal_type,
                   sua.ci_sequence_number,
                   sua.uoo_id,
                   sua.override_achievable_cp,
                   sua.override_enrolled_cp
                )
             ) total_cp
        FROM igs_en_su_attempt_all sua,
             igs_ps_unit_lvl_all ul,
             igs_ps_unit_ver_all uv
       WHERE sua.person_id = cp_person_id
         AND sua.course_cd = cp_course_cd
         AND sua.unit_cd = uv.unit_cd
         AND sua.version_number = uv.version_number
         AND sua.course_cd = ul.course_cd(+)
         AND sua.unit_cd = ul.unit_cd(+)
         AND sua.version_number = ul.version_number(+)
         AND NVL (ul.unit_level, uv.unit_level) = cp_unit_level
         AND chk_if_excluded_unit (
                sua.uoo_id,
                sua.unit_cd,
                sua.version_number
             ) = cp_include;

   -- CURSOR to get cnfg details
   CURSOR c_ul_mark_dtl (
      cp_mark_config_id   igs_pr_ul_mark_dtl.mark_config_id%TYPE
   )
   IS
      SELECT   core_indicator_code, total_credits, required_flag,
               priority_num, unit_selection_code
          FROM igs_pr_ul_mark_dtl
         WHERE mark_config_id = cp_mark_config_id
      ORDER BY priority_num ASC;

   rec_ul_mark_dtl              c_ul_mark_dtl%ROWTYPE;
   -- define the local variables to store the above values
   p1_core_indicator_code       igs_pr_ul_mark_dtl.core_indicator_code%TYPE;
   p1_total_credits             igs_pr_ul_mark_dtl.total_credits%TYPE;
   p1_required_flag             igs_pr_ul_mark_dtl.required_flag%TYPE;
   p1_priority_num              igs_pr_ul_mark_dtl.priority_num%TYPE;
   p1_unit_selection_code       igs_pr_ul_mark_dtl.unit_selection_code%TYPE;
   p2_core_indicator_code       igs_pr_ul_mark_dtl.core_indicator_code%TYPE;
   p2_total_credits             igs_pr_ul_mark_dtl.total_credits%TYPE;
   p2_required_flag             igs_pr_ul_mark_dtl.required_flag%TYPE;
   p2_priority_num              igs_pr_ul_mark_dtl.priority_num%TYPE;
   p2_unit_selection_code       igs_pr_ul_mark_dtl.unit_selection_code%TYPE;
   p3_core_indicator_code       igs_pr_ul_mark_dtl.core_indicator_code%TYPE;
   p3_total_credits             igs_pr_ul_mark_dtl.total_credits%TYPE;
   p3_required_flag             igs_pr_ul_mark_dtl.required_flag%TYPE;
   p3_priority_num              igs_pr_ul_mark_dtl.priority_num%TYPE;
   p3_unit_selection_code       igs_pr_ul_mark_dtl.unit_selection_code%TYPE;
   -- following local variable to manipulate the derived cp at each unit level
   p1_avail_cp                  NUMBER                                      := 0;
   p1_config_cp                 NUMBER                                      := 0;
   p1_required_cp               NUMBER                                      := 0;
   p1_excess_cp                 NUMBER                                      := 0;
   p1_final_derived_cp          NUMBER                                      := 0;
   p2_avail_cp                  NUMBER                                      := 0;
   p2_config_cp                 NUMBER                                      := 0;
   p2_required_cp               NUMBER                                      := 0;
   p2_excess_cp                 NUMBER                                      := 0;
   p2_final_derived_cp          NUMBER                                      := 0;
   p3_avail_cp                  NUMBER                                      := 0;
   p3_config_cp                 NUMBER                                      := 0;
   p3_required_cp               NUMBER                                      := 0;
   p3_excess_cp                 NUMBER                                      := 0;
   p3_final_derived_cp          NUMBER                                      := 0;

   -- cursor to get the config details based on mark_config_id
   CURSOR c_cnfg_dtls (
      cp_mark_config_id   igs_pr_ul_mark_dtl.mark_config_id%TYPE
   )
   IS
      SELECT   core_indicator_code, total_credits, required_flag,
               priority_num, unit_selection_code
          FROM igs_pr_ul_mark_dtl
         WHERE mark_config_id = cp_mark_config_id
      ORDER BY priority_num ASC;

   /* jhanda */
   CURSOR c_av_ulvl_marks (
      cp_person_id    igs_as_su_stmptout_all.person_id%TYPE,
      cp_course_cd    igs_as_su_stmptout_all.course_cd%TYPE,
      cp_unit_level   igs_ps_unit_lvl.unit_level%TYPE
   )
   IS
      SELECT NVL(SUM (NVL (ulvl.unit_level_mark, 0)),0) avstdmarks,
             SUM (NVL (ulvl.credit_points, 0)) avstdcp
        FROM igs_av_stnd_unit_lvl_all ulvl, igs_av_adv_standing_all advstd
       WHERE ulvl.person_id = advstd.person_id
         AND ulvl.as_course_cd = advstd.course_cd
         AND ulvl.as_version_number = advstd.version_number
         AND ulvl.exemption_institution_cd = advstd.exemption_institution_cd
         AND advstd.person_id = cp_person_id
         AND advstd.course_cd = cp_course_cd
         AND ulvl.unit_level = cp_unit_level
         AND ulvl.s_adv_stnd_granting_status = 'GRANTED';
   l_stmt_cp_based              VARCHAR2 (4000)
   :=    ' SELECT sua.unit_cd,                                               '
      || '        sua.uoo_id,                                                '
      || '        NVL(stmpt.mark,igs_as_calc_award_mark.get_mark             '
      || '                      (stmpt.grading_schema_cd,                    '
      || '                       stmpt.version_number,stmpt.grade)) mark,    '
      || '        stmpt.grade,                                               '
      || '        igs_as_calc_award_mark.get_earned_cp                       '
      || '              (stmpt.person_id,stmpt.course_cd,sua.unit_cd,        '
      || '               sua.version_number,sua.unit_attempt_status,         '
      || '               sua.cal_type,sua.ci_sequence_number,                '
      || '               sua.uoo_id,sua.override_achievable_cp,              '
      || '               sua.override_enrolled_cp ) earned_cp,                '
      || ' NVL(ul.wam_weighting,NVL( lvl.wam_weighting,1)) wam_weight '
      || ' FROM   igs_as_su_stmptout stmpt,  igs_en_su_attempt sua ,IGS_PS_UNIT_LVL_ALL UL , IGS_PS_UNIT_VER_ALL UV , IGS_PS_UNIT_LEVEL_ALL LVL           '
      || ' WHERE  stmpt.person_id =  :1  AND stmpt.course_cd =  :2           '
      || ' AND    stmpt.person_id = sua.person_id                            '
      || ' AND    stmpt.course_cd = sua.course_cd                            '
      || ' AND    stmpt.uoo_id        = sua.uoo_id                           '
      || ' AND     NVL(sua.core_indicator_code, ''ELECTIVE'') = :3 AND                              '
      || ' SUA.UNIT_CD = UV.UNIT_CD AND'
      || ' SUA.VERSION_NUMBER = UV.VERSION_NUMBER AND'
      || ' SUA.COURSE_CD = UL.COURSE_CD(+) AND'
      || '  SUA.UNIT_CD = UL.UNIT_CD(+) AND'
      || '  SUA.VERSION_NUMBER = UL.VERSION_NUMBER(+) AND'
      || '  NVL(UL.UNIT_LEVEL, UV.UNIT_LEVEL) = :4  AND '
      || ' LVL.UNIT_LEVEL= UV.UNIT_LEVEL'
      || '  AND MARK IS NOT NULL '
      || 'AND   sua.uoo_id        = stmpt.uoo_id'
      || ' AND    NVL(stmpt.mark,igs_as_calc_award_mark.get_mark             '
      || '          (stmpt.grading_schema_cd,                                '
      || '            stmpt.version_number,stmpt.grade)) IS NOT NULL         '
      || ' AND    stmpt.outcome_dt     = (  SELECT max(outcome_dt)           '
      || '        FROM igs_as_su_stmptout  suao                              '
      || '        WHERE suao.person_id = stmpt.person_id                     '
      || '        AND   suao.course_cd =stmpt.course_cd                      '
      || '        AND   suao.outcome_dt = stmpt.outcome_dt                   '
      || '        AND   suao.grading_period_cd = stmpt. grading_period_cd    '
      || '        AND   suao.uoo_id= stmpt.uoo_id )                          '
      || ' AND   igs_as_calc_award_mark.chk_if_excluded_unit (sua.uoo_id,sua.unit_cd,sua.version_number) = ''TRUE'' ';
   l_stmt_cp_based_orig         VARCHAR2 (4000)               := l_stmt_cp_based;
   l_stmt_priority_based        VARCHAR2 (4000)
   :=    '   SELECT    sua.unit_cd,                                                       '
      || '             sua.uoo_id,                                                        '
      || '             NVL(suao.mark,igs_as_calc_award_mark.get_mark                      '
      || '              (suao.grading_schema_cd,suao.version_number,suao.grade)) mark,    '
      || '             suao.grade,                                                        '
      || '             NVL(ul.wam_weighting,NVL( lvl.wam_weighting,1)) wam_weight,        '
      || '             igs_as_calc_award_mark.get_earned_cp                               '
      || '                           (suao.person_id,suao.course_cd,sua.unit_cd,          '
      || '                            sua.version_number,sua.unit_attempt_status,         '
      || '                            sua.cal_type,sua.ci_sequence_number,                '
      || '                            sua.uoo_id,sua.override_achievable_cp,              '
      || '                            sua.override_enrolled_cp ) earned_cp                '
      || '   FROM     igs_as_su_stmptout_all suao, igs_en_su_attempt_all sua,             '
      || '            igs_ps_unit_lvl_all ul, igs_ps_unit_ver_all uv ,                    '
      || '            igs_ps_unit_level_all lvl                                           '
      || '   WHERE  suao.person_id = :1           AND suao.course_cd  = :2                '
      || '   AND    suao.person_id= sua.person_id AND suao.course_cd  = sua.course_cd     '
      || '   AND    suao.uoo_id   = sua.uoo_id    AND NVL(sua.core_indicator_code, ''ELECTIVE'') = :3        '
      || '   AND    sua.unit_cd   = uv.unit_cd AND sua.version_number = uv.version_number '
      || '   AND    sua.course_cd = ul.course_cd(+) AND sua.unit_cd   = ul.unit_cd(+)     '
      || '   AND    sua.version_number = ul.version_number(+)                             '
      || '   AND    NVL(ul.unit_level,uv.unit_level) = :4                                 '
      || '   AND    lvl.unit_level     = uv.unit_level                                    '
      || '   AND    NVL(suao.mark,igs_as_calc_award_mark.get_mark                         '
      || '          (suao.grading_schema_cd,suao.version_number,suao.grade)) IS NOT NULL  '
      || '   AND    suao.outcome_dt     = ( SELECT max(outcome_dt)                        '
      || '               FROM igs_as_su_stmptout_all suao2                                '
      || '               WHERE suao2.person_id = suao.person_id                           '
      || '               AND   suao2.course_cd = suao.course_cd                           '
      || '               AND   suao2.grading_period_cd = suao.grading_period_cd           '
      || '               AND   suao2.uoo_id= suao.uoo_id )                                '
      || ' AND   igs_as_calc_award_mark.chk_if_excluded_unit (sua.uoo_id,sua.unit_cd,sua.version_number) = ''TRUE'' ';
   l_stmt_priority_based_orig   VARCHAR2 (4000)         := l_stmt_priority_based;
   -- local variables to store the output of the ref cursor
   l_unit_cd                    igs_ps_unit_ver.unit_cd%TYPE;
   l_uoo_id                     igs_ps_unit_ofr_opt.uoo_id%TYPE;
   l_mark                       NUMBER;
   l_grade                      igs_as_su_stmptout_all.grade%TYPE;
   l_earned_cp                  NUMBER;
   l_wam_weight                 igs_ps_unit_lvl.wam_weighting%TYPE;
   /*jhanda */
   l_advstnd_cp                 NUMBER;

   -- cursor to fetch earned cp, mark and wam when there is no setup available
   CURSOR c_unit_lvl_mark_wo_setup (
      cp_person_id    igs_as_su_stmptout_all.person_id%TYPE,
      cp_course_cd    igs_as_su_stmptout_all.course_cd%TYPE,
      cp_unit_level   igs_ps_unit_lvl.unit_level%TYPE
   )
   IS
      SELECT sua.unit_cd, sua.uoo_id,
             NVL (
                suao.mark,
                igs_as_calc_award_mark.get_mark (
                   suao.grading_schema_cd,
                   suao.version_number,
                   suao.grade
                )
             ) mark,
             suao.grade,
             NVL (ul.wam_weighting, NVL (lvl.wam_weighting, 1)) wam_weight,
             igs_as_calc_award_mark.get_earned_cp (
                suao.person_id,
                suao.course_cd,
                sua.unit_cd,
                sua.version_number,
                sua.unit_attempt_status,
                sua.cal_type,
                sua.ci_sequence_number,
                sua.uoo_id,
                sua.override_achievable_cp,
                sua.override_enrolled_cp
             )
                   earned_cp
        FROM igs_as_su_stmptout_all suao,
             igs_en_su_attempt_all sua,
             igs_ps_unit_lvl_all ul,
             igs_ps_unit_ver_all uv,
             igs_ps_unit_level_all lvl
       WHERE suao.person_id = cp_person_id
         AND suao.course_cd = cp_course_cd
         AND suao.person_id = sua.person_id
         AND suao.course_cd = sua.course_cd
         AND suao.uoo_id = sua.uoo_id
         AND sua.unit_cd = uv.unit_cd
         AND sua.version_number = uv.version_number
         AND sua.course_cd = ul.course_cd(+)
         AND sua.unit_cd = ul.unit_cd(+)
         AND sua.version_number = ul.version_number(+)
         AND NVL (ul.unit_level, uv.unit_level) = cp_unit_level
         AND lvl.unit_level = uv.unit_level
         AND NVL (
                suao.mark,
                igs_as_calc_award_mark.get_mark (
                   suao.grading_schema_cd,
                   suao.version_number,
                   suao.grade
                )
             ) IS NOT NULL
         AND suao.outcome_dt = (SELECT MAX (outcome_dt)
                                  FROM igs_as_su_stmptout_all suao2
                                 WHERE suao2.person_id = suao.person_id
                                   AND suao2.course_cd = suao.course_cd
                                   AND suao2.grading_period_cd =
                                                       suao.grading_period_cd
                                   AND suao2.uoo_id = suao.uoo_id)
         AND chk_if_excluded_unit (
                sua.uoo_id,
                sua.unit_cd,
                sua.version_number
             ) = 'TRUE';
BEGIN -- main begin
   --Initialize the variables
   fnd_msg_pub.initialize;
   l_total_unit_lvl_cp_config := NULL;
   l_total_unit_lvl_cp := 0;
   l_unit_lvl_mark := 0;
   l_mark_config_id := NULL;

   -- validate that all the IN parameters are passed
   IF    p_person_id IS NULL
      OR p_course_cd IS NULL
      OR p_unit_level IS NULL
   THEN
      fnd_message.set_name ('IGS', 'IGS_PR_CALC_UNIT_LVL_PARAM_REQ');
      igs_ge_msg_stack.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   -- obtain the course version number
   OPEN c_course_version_number (p_person_id, p_course_cd);
   FETCH c_course_version_number INTO l_course_version_number;
   CLOSE c_course_version_number;
   -- check whether the set up is available or not
   -- this cursor also serves the puprose of fetching
   -- toal unit_level_credits,
   -- mark_config_id, pk for the table
   -- selection_method_code
   OPEN c_total_unt_lvl_cp (
      p_unit_level,
      p_course_cd,
      l_course_version_number
   );
   FETCH c_total_unt_lvl_cp INTO l_total_unit_lvl_cp_config,
                                 l_mark_config_id,
                                 l_selection_method_code;
   CLOSE c_total_unt_lvl_cp;
   /* jhanda
      Fetch unit level advanced standing marks and cp .
      (ijeddy) and set the adv standing marks to l_unit_lvl_mark.
   */

   OPEN c_av_ulvl_marks (p_person_id, p_course_cd, p_unit_level);
   FETCH c_av_ulvl_marks INTO l_unit_lvl_mark, l_advstnd_cp;
   CLOSE c_av_ulvl_marks;

   IF l_mark_config_id IS NOT NULL
   THEN --setup is available
      /*
         If the setup is available, following steps are carried out
         1. Select the Total Unit Level Credits for a particular unit level
         2. Select the various core unit indicators setups
         3. Arrive at the CPs to be selected from each unit level
         4. Select the student unit attempt outcomes based on the the setups from 1, 2 and 3
         5. Calculate the unit level mark
      */
      -- 1. Select the Total Unit Level Credits for a particular unit level
      -- this has been done at the time of setup check up
      IF l_total_unit_lvl_cp_config IS NULL
      THEN
         -- obtain the sum of earned cp
         -- The below cursor query basically tests for CP
         -- at the sua attempt level. If this is not present,
         -- then setup is checked for the unit section level.
         -- If this is also not present then, the unit level
         -- CP is taken into consideration
         OPEN c_total_unt_lvl_cp_alt (
            p_unit_level,
            p_course_cd,
            p_person_id,
            'TRUE'
         );
         FETCH c_total_unt_lvl_cp_alt INTO l_total_unit_lvl_cp_config;
         CLOSE c_total_unt_lvl_cp_alt;
      ELSE
         OPEN c_total_unt_lvl_cp_alt (
            p_unit_level,
            p_course_cd,
            p_person_id,
            'FALSE'
         );
         FETCH c_total_unt_lvl_cp_alt INTO exlude_cp;
         CLOSE c_total_unt_lvl_cp_alt;
         l_total_unit_lvl_cp_config :=
                               l_total_unit_lvl_cp_config
                             - NVL (exlude_cp, 0);
      END IF;

      -- 2. Select the various core unit indicators setups
      OPEN c_ul_mark_dtl (l_mark_config_id);

      LOOP
         FETCH c_ul_mark_dtl INTO rec_ul_mark_dtl;
         EXIT WHEN c_ul_mark_dtl%NOTFOUND;

         -- below priority_num is assumed to have values 1,2 and 3
         IF rec_ul_mark_dtl.priority_num = 1
         THEN
            p1_core_indicator_code := rec_ul_mark_dtl.core_indicator_code;
            p1_total_credits := rec_ul_mark_dtl.total_credits;
            p1_required_flag := rec_ul_mark_dtl.required_flag;
            p1_priority_num := rec_ul_mark_dtl.priority_num;
            p1_unit_selection_code := rec_ul_mark_dtl.unit_selection_code;
         ELSIF rec_ul_mark_dtl.priority_num = 2
         THEN
            p2_core_indicator_code := rec_ul_mark_dtl.core_indicator_code;
            p2_total_credits := rec_ul_mark_dtl.total_credits;
            p2_required_flag := rec_ul_mark_dtl.required_flag;
            p2_priority_num := rec_ul_mark_dtl.priority_num;
            p2_unit_selection_code := rec_ul_mark_dtl.unit_selection_code;
         ELSIF rec_ul_mark_dtl.priority_num = 3
         THEN
            p3_core_indicator_code := rec_ul_mark_dtl.core_indicator_code;
            p3_total_credits := rec_ul_mark_dtl.total_credits;
            p3_required_flag := rec_ul_mark_dtl.required_flag;
            p3_priority_num := rec_ul_mark_dtl.priority_num;
            p3_unit_selection_code := rec_ul_mark_dtl.unit_selection_code;
         END IF;
      END LOOP;

      CLOSE c_ul_mark_dtl;

      -- 3. Arrive at the CPs to be selected from each unit level

      /*
         This step is required only if the selection method is based on Credit Points.
         If it is priority based, this step has to be skipped.

         What is being done in this step?

         In this step, the following is calculated : How much CP should be taken from
         the students outcome table at each level. For example, if the setup states
         that priority 1 should contribute, say, 72 cps , priority two should contribute
         36 and priority 3 should contribute 12, but due to a shortfall in the students
         CPs at a priority, the other priorities should compensate for this shortfall.
         The shortfall in CPs should come from priority 1 if available, if not then it
         should be compensated by priority 2, priority 3 depending on availibilty. Before
         the suas are actually selected, how much each core indicator unit attempt should
         contribute is being calculated here
      */

      -- check whether the selection criteria is credit points or priority
      -- based on selection_method_code as obtained by above cursor c_total_unt_lvl_cp

      IF l_selection_method_code = 'CREDITS'
      THEN
         -- store the sum of earned cp for each priority for the
         -- given core_indicator code
         p1_avail_cp := get_avail_cp (
                           p_person_id,
                           p_course_cd,
                           p1_core_indicator_code,
                           p_unit_level
                        );
         p2_avail_cp := get_avail_cp (
                           p_person_id,
                           p_course_cd,
                           p2_core_indicator_code,
                           p_unit_level
                        );
         p3_avail_cp := get_avail_cp (
                           p_person_id,
                           p_course_cd,
                           p3_core_indicator_code,
                           p_unit_level
                        );
         --Add advanced standing credit points to the earned credit points for
         --each of the priority levels
         --ijeddy, since l_advstnd_cp may be NULL, added a nvl.
         p1_avail_cp :=   p1_avail_cp
                        + NVL(l_advstnd_cp,0);
         p1_config_cp := NVL (p1_total_credits, 0);
         p2_config_cp := NVL (p2_total_credits, 0);
         p3_config_cp := NVL (p3_total_credits, 0);
         p1_required_cp := p1_config_cp;

         IF   NVL (p3_avail_cp, 0)
            - NVL (p3_config_cp, 0) <= 0
         THEN -- this section deals with shortage
            IF p3_required_flag = 'N'
            THEN
               p1_required_cp :=
                     p1_required_cp
                   + NVL ((  p3_config_cp
                           - p3_avail_cp
                          ), 0);
               p3_final_derived_cp := p3_avail_cp;
            ELSE
               p3_final_derived_cp := p3_avail_cp;
            END IF;
         ELSE -- IF p3_avail_cp - p3_config_cp < 0 THEN  i.e. this section deals with surplus
            p3_final_derived_cp := p3_config_cp;
            p3_excess_cp := NVL ((  p3_avail_cp
                                  - p3_config_cp
                                 ), 0);
         END IF;

         IF   NVL (p2_avail_cp, 0)
            - NVL (p2_config_cp, 0) <= 0
         THEN
            IF p2_required_flag = 'N'
            THEN
               p1_required_cp :=
                     p1_required_cp
                   + NVL ((  p2_config_cp
                           - p2_avail_cp
                          ), 0);
               p2_final_derived_cp := p2_avail_cp;
            ELSE
               p2_final_derived_cp := p2_avail_cp;
            END IF;
         ELSE
            p2_final_derived_cp := p2_config_cp;
            p2_excess_cp := NVL ((  p2_avail_cp
                                  - p2_config_cp
                                 ), 0);
         END IF;

         /*
            The above section basically puts any shortfall in priorities 2 and 3 into 1.
            The above also checks if the required indicator is checked at the priority
            level is checked or not. If it is checked, then the compensation or rollover
            should not occur.

            The next section tries to compensate any shortfall in priority 1 through 2 and 3.
         */
         IF (  p1_avail_cp
             - p1_required_cp
            ) < 0
         THEN
            IF p2_excess_cp > 0
            THEN
               IF (  NVL (p2_excess_cp, 0)
                   - (NVL ((  p1_required_cp
                            - p1_avail_cp
                           ), 0)
                     )
                  ) > 0
               THEN
                  IF p1_required_flag = 'N'
                  THEN
                     p2_final_derived_cp :=
                              p2_config_cp
                            + (  p1_required_cp
                               - p1_avail_cp
                              );
                     p1_final_derived_cp := p1_avail_cp;
                     p3_final_derived_cp := p3_avail_cp;
                  ELSE -- required = 'Y'
                     p1_final_derived_cp := p1_config_cp;
                     p2_final_derived_cp := p2_avail_cp;
                     p1_final_derived_cp := p3_avail_cp;
                  END IF; -- IF p1_required_flag = 'N' THEN
               ELSE -- IF (p2_excess_cp - (p1_required_cp - p1_avail_cp)) >=0 THEN
                  p2_final_derived_cp :=
                                  NVL (p2_config_cp, 0)
                                + NVL (p2_excess_cp, 0);
                  p1_required_cp :=
                                NVL (p1_required_cp, 0)
                              - NVL (p2_excess_cp, 0);
                  p2_final_derived_cp := p1_required_cp;

                  IF NVL (p3_excess_cp, 0) > 0
                  THEN
                     IF p1_required_flag = 'N'
                     THEN
                        IF (  NVL (p3_excess_cp, 0)
                            - NVL ((  p1_required_cp
                                    - p1_avail_cp
                                   ), 0)
                           ) > 0
                        THEN
                           p3_final_derived_cp :=
                                   NVL (p3_config_cp, 0)
                                 + (  (  NVL (p1_required_cp, 0)
                                       - NVL (p1_avail_cp, 0)
                                      )
                                    - NVL (p3_excess_cp, 0)
                                   );
                           p1_final_derived_cp := p1_avail_cp;
                        ELSE
                           p1_final_derived_cp := p1_config_cp;
                           p3_final_derived_cp := p3_config_cp;
                        END IF;
                     ELSE
                        p1_final_derived_cp := p1_config_cp;
                        p3_final_derived_cp := p3_config_cp;
                     END IF;
                  END IF; -- IF p3_excess_cp > 0 THEN
               END IF; -- IF (p2_excess_cp - (p1_required_cp - p1_avail_cp)) >= THEN
            ELSE -- IF p2_excess_cp > 0 THEN
               IF NVL (p3_excess_cp, 0) > 0
               THEN
                  IF (  NVL (p3_excess_cp, 0)
                      - (  NVL (p1_required_cp, 0)
                         - NVL (p1_avail_cp, 0)
                        )
                     ) > 0
                  THEN
                     IF p1_required_flag = 'N'
                     THEN
                        p3_final_derived_cp :=   NVL (p3_config_cp, 0)
                                               + (  (  NVL (
                                                          p1_required_cp,
                                                          0
                                                       )
                                                     - NVL (p1_avail_cp, 0)
                                                    )
                                                  - NVL (p3_excess_cp, 0)
                                                 );
                        p1_final_derived_cp := p1_avail_cp;
                     ELSE
                        p1_final_derived_cp := NVL (p1_config_cp, 0);
                        p3_final_derived_cp := NVL (p3_config_cp, 0);
                     END IF;
                  ELSE -- IF (p3_excess_cp - (p1_required_cp - p1_avail_cp)) > 0 THEN
                     IF p1_required_flag = 'N'
                     THEN
                        p3_final_derived_cp := NVL (p3_avail_cp, 0);
                        p1_final_derived_cp := p1_avail_cp;
                     ELSE
                        p1_final_derived_cp := p1_config_cp;
                        p3_final_derived_cp := NVL (p3_config_cp, 0);
                     END IF;
                  END IF; -- IF (p3_excess_cp - (p1_required_cp - p1_avail_cp)) > 0 THEN
               ELSE
                  p1_final_derived_cp := p1_avail_cp;
                  p2_final_derived_cp := NVL (p2_avail_cp, 0);
                  p3_final_derived_cp := NVL (p3_avail_cp, 0);
               END IF; -- IF p3_excess_cp > 0 THEN
            END IF; -- IF p2_excess_cp > 0 THEN
         ELSE -- IF (p1_avail_cp - p1_required_cp) < 0 THEN
            p1_final_derived_cp := p1_required_cp;

            IF NVL (p2_config_cp, 0) > NVL (p2_avail_cp, 0)
            THEN
               p2_final_derived_cp := NVL (p2_avail_cp, 0);
            ELSE
               p2_final_derived_cp := p2_config_cp;
            END IF;

            IF NVL (p3_config_cp, 0) > NVL (p3_avail_cp, 0)
            THEN
               p3_final_derived_cp := NVL (p3_avail_cp, 0);
            ELSE
               p3_final_derived_cp := p3_config_cp;
            END IF;
         END IF; -- IF (p1_avail_cp - p1_required_cp) < 0 THEN
      END IF; -- IF l_selection_method_code = 'CREDITS' THEN

      /*
         At the end of the above calculation,
         p1_final_derived_cp, p2_final_derived_cp and p3_final_derived_cp are determined.
         Thus how much each priority should contribute has been defined.
      */

      -- 4. Select the student unit attempt outcomes based on the the setups from 1, 2 and 3

      -- check out the selection method code
      IF l_selection_method_code = 'PRIORITY'
      THEN
         FOR rec_cnfg_dtls IN c_cnfg_dtls (l_mark_config_id)
         LOOP
            -- decide the order by clause
            IF rec_cnfg_dtls.unit_selection_code = 'BEST_MARK'
            THEN
               l_stmt_priority_based :=
                           l_stmt_priority_based_orig
                        || ' ORDER BY mark desc ';
            ELSE
               l_stmt_priority_based :=    l_stmt_priority_based_orig
                                        || ' ORDER BY suao.creation_date desc';
            END IF;

            -- now open the ref cursor
            OPEN c_priority_based FOR l_stmt_priority_based
               USING   p_person_id,
                       p_course_cd,
                       rec_cnfg_dtls.core_indicator_code,
                       p_unit_level;

            LOOP
               FETCH c_priority_based INTO l_unit_cd,
                                           l_uoo_id,
                                           l_mark,
                                           l_grade,
                                           l_wam_weight,
                                           l_earned_cp;
               EXIT WHEN c_priority_based%NOTFOUND;

               IF (  l_total_unit_lvl_cp_config
                   - (  l_total_unit_lvl_cp
                      + l_earned_cp
                     )
                  ) >= 0
               THEN
                  l_total_unit_lvl_cp :=   l_total_unit_lvl_cp
                                         + l_earned_cp;
                  l_unit_lvl_mark :=   l_unit_lvl_mark
                                     + (l_wam_weight * l_earned_cp * l_mark);
               END IF;
            END LOOP;
            CLOSE c_priority_based;
         END LOOP; -- FOR rec_cnfg_dtls IN c_cnfg_dtls
      ELSE -- else of IF l_selection_method_code = 'PRIORITY' THEN i.e. CREDITS
         FOR rec_cnfg_dtls IN c_cnfg_dtls (l_mark_config_id)
         LOOP
            -- decide the order by clause
            IF rec_cnfg_dtls.unit_selection_code = 'BEST_MARK'
            THEN
               l_stmt_cp_based :=
                                 l_stmt_cp_based_orig
                              || ' ORDER BY mark desc ';
            ELSE
               l_stmt_cp_based :=    l_stmt_cp_based_orig
                                  || ' ORDER BY stmpt.creation_date desc';
            END IF;

            -- now open the ref cursor
            OPEN c_cp_based FOR l_stmt_cp_based
               USING   p_person_id,
                       p_course_cd,
                       rec_cnfg_dtls.core_indicator_code,
                       p_unit_level;

            LOOP
               FETCH c_cp_based INTO l_unit_cd,
                                     l_uoo_id,
                                     l_mark,
                                     l_grade,
                                     l_earned_cp,
                                     l_wam_weight;
               EXIT WHEN c_cp_based%NOTFOUND;

               -- below priority_num is assumed to have values 1,2 and 3
               IF rec_cnfg_dtls.priority_num = 1
               THEN
                  IF   p1_final_derived_cp
                     - l_earned_cp >= 0
                  THEN
                     p1_final_derived_cp :=
                                            p1_final_derived_cp
                                          - l_earned_cp;
                     l_unit_lvl_mark :=   l_unit_lvl_mark
                                        + (  NVL (l_wam_weight, 1)
                                           * l_earned_cp
                                           * l_mark
                                          );
                  END IF;
               ELSIF rec_cnfg_dtls.priority_num = 2
               THEN
                  IF   p2_final_derived_cp
                     - l_earned_cp >= 0
                  THEN
                     p2_final_derived_cp :=
                                            p2_final_derived_cp
                                          - l_earned_cp;
                     l_unit_lvl_mark :=   l_unit_lvl_mark
                                        + (  NVL (l_wam_weight, 1)
                                           * l_earned_cp
                                           * l_mark
                                          );
                  END IF;
               ELSIF rec_cnfg_dtls.priority_num = 3
               THEN
                  IF   p3_final_derived_cp
                     - l_earned_cp >= 0
                  THEN
                     p3_final_derived_cp :=
                                            p3_final_derived_cp
                                          - l_earned_cp;
                     l_unit_lvl_mark :=   l_unit_lvl_mark
                                        + (  NVL (l_wam_weight, 1)
                                           * l_earned_cp
                                           * l_mark
                                          );
                  END IF;
               END IF; -- IF rec_cnfg_dtls.priority_num = 1 THEN
            END LOOP; -- OPEN c_cp_based FOR l_stmt_cp_based;
            CLOSE c_cp_based;
         END LOOP; -- FOR rec_cnfg_dtls IN c_cnfg_dtls
      END IF; -- end of IF l_selection_method_code = 'CREDITS' THEN

      -- 5. Calculate the unit level mark
      l_unit_lvl_mark := l_unit_lvl_mark / NVL (l_total_unit_lvl_cp_config, 1);
   ELSE -- IF l_mark_config_id IS NOT NULL THEN i.e. setup is not available
      -- Get the total cp that is to be used as denominator for calculation of unit level mark
      OPEN c_total_unt_lvl_cp_alt (
         p_unit_level,
         p_course_cd,
         p_person_id,
         'TRUE'
      );
      FETCH c_total_unt_lvl_cp_alt INTO l_total_unit_lvl_cp_config;
      CLOSE c_total_unt_lvl_cp_alt;

      FOR rec IN c_unit_lvl_mark_wo_setup (
                    p_person_id,
                    p_course_cd,
                    p_unit_level
                 )
      LOOP
         l_unit_lvl_mark :=
                l_unit_lvl_mark
              + (rec.mark * rec.earned_cp * rec.wam_weight);
      END LOOP;

      -- jhanda
      l_total_unit_lvl_cp_config := NVL (l_total_unit_lvl_cp_config,0) + NVL(l_advstnd_cp,0);
      IF (l_total_unit_lvl_cp_config = 0 ) THEN
          l_total_unit_lvl_cp_config := 1;
      END IF;
      l_unit_lvl_mark := l_unit_lvl_mark / l_total_unit_lvl_cp_config;
   END IF; -- IF l_mark_config_id IS NOT NULL THEN

   -- Initialize API return status to success.
   x_return_status := fnd_api.g_ret_sts_success;
   -- Standard call to get message count and if count is 1, get message
   -- info.
   fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   IF l_unit_lvl_mark IS NOT NULL
   THEN
      RETURN TO_NUMBER (TO_CHAR (l_unit_lvl_mark, '999.999'));
   ELSE
      RETURN l_unit_lvl_mark;
   END IF;
EXCEPTION
   WHEN fnd_api.g_exc_error
   THEN
      l_unit_lvl_mark := NULL;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (
         p_count=> x_msg_count,
         p_data=> x_msg_data
      );
      RETURN TO_NUMBER (NULL);
   WHEN fnd_api.g_exc_unexpected_error
   THEN
      l_unit_lvl_mark := NULL;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (
         p_count=> x_msg_count,
         p_data=> x_msg_data
      );
      RETURN TO_NUMBER (NULL);
   WHEN OTHERS
   THEN
      l_unit_lvl_mark := NULL;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME',    'pr_calc_unit_lvl_mark : '
                                     || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (
         p_count=> x_msg_count,
         p_data=> x_msg_data
      );
      RETURN l_unit_lvl_mark;
END fn_calc_unit_lvl_mark;


PROCEDURE get_hnr_grade(
  p_award_cd             VARCHAR2,
  p_sum                  NUMBER  ,
  p_honors_level     OUT NOCOPY VARCHAR2,
  p_grad_sch_code    OUT NOCOPY VARCHAR2,
  p_grad_Version_num OUT NOCOPY NUMBER) IS
  /*
    ||==============================================================================||
    ||  Created By : Nalin Kumar                                                    ||
    ||  Created On : 03-Jun-2004                                                    ||
    ||  Purpose    : To find the Grading Schema and version number attached to the Award||
    ||  Known limitations, enhancements or remarks :                                ||
    ||  Change History :                                                            ||
    ||  Who             When            What                                        ||
    ||  (reverse chronological order - newest change first)                         ||
    ||==============================================================================||
  */
  -- cursor to derive the grade (honors level)
  CURSOR c_honors_level (cp_award_cd igs_ps_awd.award_cd%TYPE,
                         cp_sum NUMBER) IS
  SELECT gsg.grade, gs.grading_schema_cd, gs.version_number
  FROM   igs_as_grd_schema gs,
         igs_as_grd_sch_grade gsg,
         igs_ps_awd pa
  WHERE  gs.grading_schema_cd = gsg.grading_schema_cd
  AND gs.version_number    = gsg.version_number
  AND gs.grading_schema_type = 'HONORS'
  AND pa.award_cd = cp_award_cd
  AND pa.grading_schema_cd = gsg.grading_schema_cd
  AND  pa.gs_version_number = gsg.version_number
  AND NVL(gsg.lower_mark_range, 1) <= NVL((cp_sum), NVL(gsg.lower_mark_range, 1))
  AND NVL(gsg.upper_mark_range, 1) >= NVL((cp_sum), NVL(gsg.upper_mark_range, 1));

  CURSOR c_honors_level1 (cp_sum   NUMBER) IS
  SELECT gsg.grade, gs.grading_schema_cd, gs.version_number
  FROM igs_as_grd_schema gs,
       igs_as_grd_sch_grade gsg
  WHERE  gs.grading_schema_cd = gsg.grading_schema_cd
  AND gs.version_number = gsg.version_number
  AND gs.grading_schema_type = 'HONORS'
  AND gs.start_dt <= SYSDATE
  AND nvl(gs.end_dt,SYSDATE) >= SYSDATE
  AND gsg.lower_mark_range <= (cp_sum)
  AND gsg.upper_mark_range >= (cp_sum);

  l_grading_schema_cd IGS_AS_GRD_SCH_GRADE.GRADING_SCHEMA_CD%TYPE;
  l_gs_version_number IGS_AS_GRD_SCH_GRADE.VERSION_NUMBER%TYPE;
  l_honors_level     igs_as_grd_sch_grade.grade%TYPE; -- stores honors level
  l_honors_level_not_used VARCHAR2(30);
BEGIN
  OPEN c_honors_level (p_award_cd,p_sum);
  FETCH c_honors_level INTO l_honors_level, l_grading_schema_cd, l_GS_VERSION_NUMBER;
  CLOSE c_honors_level;

  IF l_grading_schema_cd IS NULL THEN
    OPEN c_honors_level1 (p_sum);
    FETCH c_honors_level1 INTO l_honors_level, l_grading_schema_cd, l_GS_VERSION_NUMBER;
    CLOSE c_honors_level1;
  END IF;
  --Cursor to get the grading schema and version associated with award. So that if none of the
  --GS cover the range of mark calculated, return the Grading schema and version
  -- so that user can select from the lov in the form.

  IF l_grading_schema_cd IS NULL THEN
    OPEN c_honors_level (p_award_cd, TO_NUMBER(NULL));
    FETCH c_honors_level INTO l_honors_level_not_used, l_grading_schema_cd, l_GS_VERSION_NUMBER;
    CLOSE c_honors_level;
  END IF;
  p_honors_level := l_honors_level;
  p_grad_sch_code := l_grading_schema_cd;
  p_grad_Version_num := l_GS_VERSION_NUMBER;
END get_hnr_grade;

PROCEDURE pr_calc_award_mark (
  p_person_id         IN          NUMBER,
  p_course_cd         IN          VARCHAR2,
  p_award_cd          IN          VARCHAR2,
  p_award_mark        OUT NOCOPY NUMBER,
  p_honors_level      OUT NOCOPY VARCHAR2,
  p_grading_schema_cd OUT NOCOPY VARCHAR2,
  p_version_number    OUT NOCOPY NUMBER,
  X_RETURN_STATUS     OUT NOCOPY VARCHAR2,
  X_MSG_DATA          OUT NOCOPY VARCHAR2,
  X_MSG_COUNT         OUT NOCOPY NUMBER) IS
/*
  Description of the parameters:
  IN PARAMETERS
  p_person_id - The ID of the person to calculate an award
  p_course_cd - The Program (Course Code) for which the award mark
                has to be calculated
  p_award_cd  - Award Code for the which the award nark has to be
                calculated

  OUT PARAMETERS
  p_award_mark    - Calculated award mark
  p_honors_level  - Derived honours level based on the calculated
                    award mark
  x_return_status - Stores the success or failure of the program unit
  x_msg_data      - Stores the error message
  x_msg_count     - stores the count of error

*/

  -- cursor to fetch all associated unit level with the passed award code. Note that if there is no configuration done here for
  -- the unit level in table igs_ps_awd_hnr_base and the student has attempted some unit at that level, then the weghted avg mark should be
  -- considered as 1.
  CURSOR c_unit_levels (cp_award_cd igs_ps_awd.award_cd%TYPE) IS
  SELECT unit_level, weighted_average
  FROM   igs_ps_awd_hnr_base
  WHERE award_cd = cp_award_cd
  AND   unit_level IS NOT NULL
  UNION
  SELECT NVL(ul.unit_level, uv.unit_level) AS unit_level, 1 AS weighted_average
  FROM igs_en_su_attempt_all sua ,
       igs_ps_unit_ver_all uv, igs_ps_unit_lvl_all ul
  WHERE
    sua.unit_cd = uv.unit_cd AND
    sua.version_number = uv.version_number AND
    sua.course_cd = ul.course_cd(+) AND
    sua.unit_cd = ul.unit_cd(+) AND
    sua.version_number = ul.version_number(+) AND
    sua.person_id = p_person_id and sua.course_cd = p_course_cd AND
    NOT EXISTS (SELECT 1 FROM igs_ps_awd_hnr_base hb WHERE NVL(ul.unit_level, uv.unit_level) = hb.unit_level);

  -- cursor to get the stat details
  CURSOR c_stat_dtls (cp_award_cd igs_ps_awd.award_cd%TYPE) IS
  SELECT stat_type,
          s_stat_element,
          timeframe
  FROM   igs_ps_awd_hnr_base
  WHERE  award_cd = cp_award_cd
  AND    stat_type IS NOT NULL;

  rec_stat_dtls c_stat_dtls%ROWTYPE;

  -- cursor to get the load cal tpe and sequence_number
  CURSOR c_load_dtls (cp_person_id igs_en_su_attempt.person_id%TYPE,
                      cp_course_cd igs_en_su_attempt.course_cd%TYPE) IS
  SELECT load_cal_type,
         load_ci_sequence_number
  FROM   igs_ca_teach_to_load_v
  WHERE  (teach_cal_type,teach_ci_sequence_number)
    IN( SELECT cal_type, ci_sequence_number
        FROM (SELECT cal_type, ci_sequence_number
              FROM igs_en_su_attempt
              WHERE course_cd = cp_course_cd
              AND   person_id = cp_person_id
              AND   unit_attempt_status IN ('COMPLETED','DUPLICATE','ENROLLED')
              ORDER BY ci_start_dt DESC)
        WHERE rownum = 1)
  ORDER BY load_start_dt DESC;
  rec_load_dtls   c_load_dtls%ROWTYPE;

  --local variables
  l_unit_level_mark    NUMBER; -- stores unit level mark
  l_sum                NUMBER; -- sum of l_unit_level_mark*l_unit_level_wam
  l_honors_level       igs_as_grd_sch_grade.grade%TYPE; -- stores honors level
  l_gpa_value          NUMBER;
  l_gpa_cp             NUMBER;
  l_gpa_quality_points NUMBER;
  l_acad_cal_type      VARCHAR2(30);
  l_acad_ci_seq_num    NUMBER;
  l_load_cal_type      VARCHAR2(30);
  l_load_ci_seq_num    NUMBER;
  l_load_ci_alt_code   VARCHAR2(30);
  l_load_ci_start_dt   DATE;
  l_load_ci_end_dt     DATE;
  l_message_name       VARCHAR2(30):=NULL;
  l_grading_schema_cd igs_as_grd_sch_grade.grading_schema_cd%TYPE;
  l_gs_version_number igs_as_grd_sch_grade.version_number%TYPE;
BEGIN
  --Initialize the variables
  FND_MSG_PUB.initialize;
  l_unit_level_mark :=0;
  l_sum             :=0;
  -- validate the IN parameters for null values
  -- raise error msg IGS_PR_CALC_AWD_MARK_PARAM_REQ
  -- in case of violation
  IF p_person_id IS NULL OR
     p_course_cd IS NULL OR
     p_award_cd IS NULL THEN
     FND_MESSAGE.SET_NAME('IGS', 'IGS_PR_CALC_AWD_MARK_PARAM_REQ');
     IGS_GE_MSG_STACK.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- check for the career enabled model
  IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'N' THEN -- i..e Program Centric
    -- Loop through the various unit levels fetched by the cursor
    -- make the call to calc_unit_level_mark(person_id,program, unit_level)
    -- and keep adding to a local variable
    FOR rec_unit_levels IN c_unit_levels (p_award_cd)LOOP
      l_unit_level_mark := fn_calc_unit_lvl_mark(
                             p_person_id     => p_person_id,
                             p_course_cd     => p_course_cd,
                             p_unit_level    => rec_unit_levels.unit_level,
                             X_RETURN_STATUS => X_RETURN_STATUS,
                             X_MSG_DATA      => X_MSG_DATA,
                             X_MSG_COUNT     => X_MSG_COUNT);
      l_sum := l_sum + l_unit_level_mark*nvl(rec_unit_levels.weighted_average,1);
    END LOOP; --FOR rec_unit_levels IN c_unit_levels
    -- so, l_sum has the calculated award mark
    -- now, derive the honors level

    get_hnr_grade(
      p_award_cd ,
      l_Sum ,
      l_honors_level ,
      l_grading_schema_cd,
      l_GS_VERSION_NUMBER);

     p_grading_schema_cd :=  l_grading_schema_cd ;
     p_version_number := l_gs_version_number;




  ELSE  -- i.e. Career Enabled
        -- get the stat details
    OPEN c_stat_dtls(p_award_cd);
    FETCH c_stat_dtls INTO rec_stat_dtls;
    CLOSE c_stat_dtls;

   --Get the load cal and load ci sequence number
   -- this is to avoid dependency on igs_en_gen_015
   OPEN c_load_dtls(p_person_id,p_course_cd);
   FETCH c_load_dtls INTO rec_load_dtls;
   CLOSE c_load_dtls;

   -- now get the GPA
   igs_pr_cp_gpa.get_gpa_stats
     ( p_person_id               => p_person_id,
       p_course_cd               => p_course_cd,
       p_stat_type               => rec_stat_dtls.stat_type,  --Pass NULL if no setup is done...
       p_load_cal_type           => rec_load_dtls.load_cal_type,
       p_load_ci_sequence_number => rec_load_dtls.load_ci_sequence_number,
       p_system_stat             => NULL,
       p_cumulative_ind          => 'Y',
       p_gpa_value               => l_gpa_value,
       p_gpa_cp                  => l_gpa_cp,
       p_gpa_quality_points      => l_gpa_quality_points,
       p_init_msg_list           => FND_API.G_TRUE,
       p_return_status           => X_RETURN_STATUS,
       p_msg_count               => X_MSG_COUNT,
       p_msg_data                => X_MSG_DATA
     );

   IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
     FND_MESSAGE.SET_NAME('IGS',X_MSG_DATA);
     IGS_GE_MSG_STACK.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- now derive the honofrs level
   l_sum := l_gpa_value;
   get_hnr_grade(
     p_award_cd,
     l_Sum,
     l_honors_level,
     l_grading_schema_cd,
     l_gs_version_number);

     p_grading_schema_cd := l_grading_schema_cd;
     p_version_number    := l_gs_version_number;

  END IF;

  --IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'N' THEN
  -- now assign the out parameters
    p_award_mark := l_sum;
    p_honors_level := l_honors_level;
  -- Initialize API return status to success.
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_MSG_COUNT,
    p_data  => X_MSG_DATA);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_MSG_COUNT,
        p_data  => X_MSG_DATA);
      RETURN;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_MSG_COUNT,
        p_data  => X_MSG_DATA);
      RETURN;
    WHEN OTHERS THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('NAME','pr_calc_award_mark : '||SQLERRM);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_MSG_COUNT,
        p_data  => X_MSG_DATA);
     RETURN;
END pr_calc_award_mark;

FUNCTION fn_calc_award_mark(
  p_person_id     IN         NUMBER,
  p_course_cd     IN         VARCHAR2,
  p_award_cd      IN         VARCHAR2 ,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_DATA      OUT NOCOPY VARCHAR2,
  X_MSG_COUNT     OUT NOCOPY NUMBER) RETURN NUMBER IS

  -- define variable for OUT params to call pr_calc_award_mark
  l_award_mark    NUMBER;
  l_honors_level  VARCHAR2(1000);
  l_grading_schema_cd VARCHAR2(30);
  l_gs_version_number NUMBER(30);
BEGIN
  -- call pr_calc_award_mark
  pr_calc_award_mark(
    p_person_id       => p_person_id,
    p_course_cd       => p_course_cd,
    p_award_cd        => p_award_cd,
    p_award_mark      => l_award_mark,
    p_honors_level    => l_honors_level,
    p_grading_schema_cd => l_grading_schema_cd,
    p_version_number =>  l_gs_version_number,
    X_RETURN_STATUS   => X_RETURN_STATUS,
    X_MSG_DATA        => X_MSG_DATA,
    X_MSG_COUNT       => X_MSG_COUNT);

  IF X_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    FND_MESSAGE.SET_NAME('IGS',X_MSG_DATA);
    IGS_GE_MSG_STACK.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --Calculation sucessful hence return properly with value.
  RETURN l_award_mark;

  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_MSG_COUNT,
    p_data  => X_MSG_DATA);
 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_MSG_COUNT,
      p_data  => X_MSG_DATA);
     RETURN l_award_mark;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
       p_count => x_MSG_COUNT,
       p_data  => X_MSG_DATA);
     RETURN l_award_mark;
   WHEN OTHERS THEN
     X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
     FND_MESSAGE.SET_TOKEN('NAME','pr_calc_award_mark : '||SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
       p_count => x_MSG_COUNT,
       p_data  => X_MSG_DATA);
     RETURN l_award_mark;
END fn_calc_award_mark;

FUNCTION fn_derive_honors_level (p_person_id IN NUMBER,
                                 p_course_cd IN VARCHAR2,
                                 p_award_cd  IN VARCHAR2 ) RETURN VARCHAR2 IS
  -- define variable for OUT params to call pr_calc_award_mark
  l_award_mark    NUMBER;
  l_honors_level  VARCHAR2(1000);
  l_return_status VARCHAR2(100);
  l_msg_data      VARCHAR2(2000);
  l_msg_count     NUMBER;
  l_grading_schema_cd VARCHAR2(30);
  l_gs_version_number NUMBER(30);
BEGIN
  -- call pr_calc_award_mark
  pr_calc_award_mark(
    p_person_id         => p_person_id,
    p_course_cd         => p_course_cd,
    p_award_cd          => p_award_cd,
    p_award_mark        => l_award_mark,
    p_honors_level      => l_honors_level,
    p_grading_schema_cd => l_grading_schema_cd,
    p_version_number    => l_gs_version_number,
    X_RETURN_STATUS     => l_return_status,
    X_MSG_DATA          => l_msg_data,
    X_MSG_COUNT         => l_msg_count);
  RETURN l_honors_level;
END fn_derive_honors_level;

PROCEDURE upgrade_awards (errbuff OUT NOCOPY VARCHAR2,
                          retcode OUT NOCOPY NUMBER,
                          p_award_cd igs_ps_awd.AWARD_CD%TYPE) IS
  -- Cursor to get all the award aims which are to be updated with the award marks and award grades...
  CURSOR cur_spaa(cp_awd_cd VARCHAR2) IS
  SELECT spaa.rowid row_id, spaa.*
  FROM igs_en_spa_awd_aim spaa
  WHERE spaa.AWARD_CD = cp_awd_cd AND
  spaa.AWARD_MARK IS NULL AND
  spaa.AWARD_GRADE IS NULL;

  CURSOR Cur_awd_grd_sch IS
  SELECT pa.grading_schema_cd, pa.gs_version_number
  FROM igs_ps_awd pa
  WHERE pa.award_cd   = p_award_cd;

  CURSOR Cur_Awd_grd(cp_grd_sch VARCHAR2, cp_grd_ver NUMBER, cp_grade VARCHAR2) IS
  SELECT gsg.grade, gs.grading_schema_cd, gs.version_number,
         gsg.lower_mark_range, gsg.upper_mark_range
  FROM igs_as_grd_schema gs, igs_as_grd_sch_grade gsg
  WHERE gs.grading_schema_cd = gsg.grading_schema_cd
   AND gs.version_number = gsg.version_number
   AND gs.grading_schema_type = 'HONORS'
   AND gs.grading_schema_cd = cp_grd_sch
   AND gs.version_number = cp_grd_ver
   AND gsg.GRADE = cp_grade;

  lAwdMark igs_en_spa_awd_aim.AWARD_MARK%TYPE;
  lAwadrdGrade IGS_as_grd_sch_grade.Grade%TYPE;
  lReturnStatus VARCHAR2(10);
  lMsgData VARCHAR2(2000);
  l_enc_msg  VARCHAR2(2000);
  l_mesg_text VARCHAR2(4000);
  l_msg_index NUMBER;
  l_msg_count NUMBER;
  l_grading_schema_cd VARCHAR2(30);
  l_gs_version_number NUMBER(30);
  l_total_spa_rec NUMBER := 0;
  l_total_spa_updated_rec NUMBER := 0;
  lrow_awd_grd_sch   Cur_awd_grd_sch%ROWTYPE;
  lrowAwd_grd Cur_Awd_grd%ROWTYPE;

BEGIN


  --initialize
  retcode:= 0;
  errbuff:= NULL;
  --start
  IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054

  OPEN cur_awd_grd_sch;
  FETCH cur_awd_grd_sch INTO lrow_awd_grd_sch;
  CLOSE cur_awd_grd_sch;

  FOR spaa_rec IN cur_spaa(p_award_cd) LOOP

    IF lrow_awd_grd_sch.grading_schema_cd IS NOT NULL THEN
      OPEN cur_awd_grd(lrow_awd_grd_sch.grading_schema_cd,
                       lrow_awd_grd_sch.gs_version_number,spaa_rec.honours_level);
     FETCH Cur_Awd_grd INTO lrowAwd_grd;
    CLOSE Cur_Awd_grd;

    END IF;

    -- increment the totla spa record selected by 1;
    l_total_spa_rec := l_total_spa_rec + 1;
    ---- Get the award mark, Honors level, grading schema and grading schem version
    --  by making a call to procedure pr_calc_award_mark of package igs_as_calc_award_mark.

    igs_as_calc_award_mark.pr_calc_award_mark(
      p_person_id         => spaa_rec.person_id,
      p_course_cd         => spaa_rec.course_cd ,
      p_award_cd          => spaa_rec.award_cd,
      p_award_mark        => lAwdMark,
      p_honors_level      => lAwadrdGrade,
      p_grading_schema_cd => l_grading_schema_cd,
      p_version_number    => l_gs_version_number,
      x_return_status     => lReturnStatus,
      x_msg_data          => lmsgdata,
      x_msg_count         => l_msg_count);



    IF ((lReturnStatus  <> FND_API.G_RET_STS_SUCCESS) OR (NVL(lrowawd_grd.grade, lawadrdgrade) IS NULL) )THEN
     -- Get the proper message and log it to the file
        FOR l_index IN 1..NVL(l_msg_count, 0) LOOP

			FND_MSG_PUB.GET (
			FND_MSG_PUB.G_FIRST,
			FND_API.G_TRUE,
			l_enc_msg,
			l_msg_index
		);
		FND_MESSAGE.SET_ENCODED(l_enc_msg);
		lmsgdata := FND_MESSAGE.GET;
		l_mesg_text := l_mesg_text ||  lmsgdata || ';' ;
		FND_MSG_PUB.DELETE_MSG(l_msg_index);
	END LOOP;

      fnd_file.put_line (fnd_file.LOG, ' Failed to Update ' ||  spaa_rec.person_id || ' - ' || spaa_rec.course_cd || ' - ' || P_AWARD_CD  );
      fnd_file.put_line (fnd_file.LOG, l_mesg_text);

    ELSE -- The mark and honors level were calculated successfully. Now update the SPAA record.
fnd_file.put_line (fnd_file.LOG,'-------------------------***----------------------');
      BEGIN
        igs_en_spa_awd_aim_pkg.update_row(
          x_rowid             => spaa_rec.row_id,
          x_person_id         => spaa_rec.person_id,
          x_course_cd         => spaa_rec.course_cd,
          x_award_cd          => spaa_rec.award_cd,
          x_start_dt          => spaa_rec.start_dt,
          x_end_dt            => spaa_rec.end_dt,
          x_complete_ind      => spaa_rec.complete_ind,
          x_honours_level     => spaa_rec.honours_level,
          x_conferral_date    => spaa_rec.conferral_date,
          x_award_mark        => lawdmark,
          x_award_grade       => NVL(lrowawd_grd.grade, lawadrdgrade),
          x_grading_schema_cd => NVL(lrowawd_grd.grading_schema_cd, l_grading_schema_cd),
          x_gs_version_number => NVL(lrowawd_grd.version_number, l_gs_version_number));

      IF NVL(lrowawd_grd.grade, lawadrdgrade) IS NOT NULL THEN
      --Print the success in log...
	fnd_file.put_line (fnd_file.LOG,'Updated  ' ||spaa_rec.person_id || ': ' || spaa_rec.course_cd || ': ' || spaa_rec.award_cd || ': With award grade :' || NVL(lrowawd_grd.grade, lawadrdgrade) );
      -- Increment the total updated records by 1
	 l_total_spa_updated_rec := l_total_spa_updated_rec + 1;
      END IF;


      EXCEPTION
       WHEN OTHERS THEN
        fnd_file.put_line (fnd_file.LOG, 'Error Occured For '||  spaa_rec.PERSON_ID || ' - ' || spaa_rec.COURSE_CD || ' - ' || P_AWARD_CD || SQLERRM  );
      END;
    END IF;
  END LOOP;

  --Print the total statistics in log.
  fnd_file.put_line (fnd_file.LOG, 'Total program attempt award records selected : ' || l_total_spa_rec);
  fnd_file.put_line (fnd_file.LOG, 'Total program attempt award records updated successfully  : ' || l_total_spa_updated_rec);

 EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        FOR l_index IN 1..NVL(l_msg_count, 0) LOOP
		FND_MSG_PUB.GET (
		FND_MSG_PUB.G_FIRST,
		FND_API.G_TRUE,
		l_enc_msg,
		l_msg_index );

		FND_MESSAGE.SET_ENCODED(l_enc_msg);
		lmsgdata := FND_MESSAGE.GET;
		l_mesg_text := l_mesg_text ||  lmsgdata || ';' ;
		FND_MSG_PUB.DELETE_MSG(l_msg_index);
	END LOOP;
      fnd_file.put_line (fnd_file.LOG,  'Error Ocuured : ' ||l_mesg_text );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FOR l_index IN 1..NVL(l_msg_count, 0) LOOP

			FND_MSG_PUB.GET (
			FND_MSG_PUB.G_FIRST,
			FND_API.G_TRUE,
			l_enc_msg,
			l_msg_index
			);
			FND_MESSAGE.SET_ENCODED(l_enc_msg);
			lmsgdata := FND_MESSAGE.GET;
			l_mesg_text := l_mesg_text ||  lmsgdata || ';' ;
			FND_MSG_PUB.DELETE_MSG(l_msg_index);
	END LOOP;
      fnd_file.put_line (fnd_file.LOG,  'Error Ocuured : ' ||l_mesg_text );

      WHEN OTHERS THEN
      retcode:=2;
    fnd_file.put_line (fnd_file.LOG, 'Error encountered : ' || SQLERRM);
END upgrade_awards;



FUNCTION fn_ret_unit_lvl_mark (p_person_id     IN NUMBER,
                                 p_course_cd     IN VARCHAR2,
                                 p_unit_level    IN VARCHAR2
                                 ) RETURN NUMBER
IS
 L_RETURN_STATUS     VARCHAR2(1000);
 L_MSG_DATA          VARCHAR2(1000);
 L_MSG_COUNT         NUMBER;
 l_unit_level_mark   NUMBER ;

Begin

  l_unit_level_mark := fn_calc_unit_lvl_mark (p_person_id     ,
                                 p_course_cd     ,
                                 p_unit_level    ,
                                 L_RETURN_STATUS ,
                                 L_MSG_DATA      ,
                                 L_MSG_COUNT     );


  return  l_unit_level_mark;
EXCEPTION
  WHEN OTHERS THEN
  fnd_file.put_line (fnd_file.LOG, 'Error encountered : ' || SQLERRM);
End fn_ret_unit_lvl_mark;

END igs_as_calc_award_mark;

/
