--------------------------------------------------------
--  DDL for Package Body IGS_DA_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_DA_XML_PKG" AS
/* $Header: IGSDA10B.pls 120.3 2006/02/09 01:30:24 ijeddy ship $ */
/***************************************************************************************************************

Created By:        Steven Hogan, Nimit Mankodi

Date Created By:   March-04-2001

Purpose:

Known limitations,enhancements,remarks:

Change History

Who        When           What
shogan     May 8 2003     l_event_key - in Submit_Event Procedure
rvivekan   09-sep-2003    Modified the behaviour of repeatable_ind column in igs_ps_unit_ver table
                          in function get_unit_repeatable . PSP integration build #3052433
smanglm    12-sep-2003    bug 3093223 - added pre_submit_event to write error report and lauch a workflow
shogan     20-feb-2004    Bug #3438386/3472644 - update added loop to procedure Submit_Event
                                       - update added table updates with error_code.
                                       - New procedure added update_stdnts_err - write error code
                                         and report message.
                                       - Alt. update_request_status (reduced parameters)
                                       - remove call from workflow process. igsdaxmlgen.wft
nmankodi   03-Nov-2004    Bug 3936708 - Changed the udpate_request_status procedure.
                                      - Changed the update_req_students spec and body, added p_error_code
jhanda     17-Jan-2005    Bug 4114100 - Changed code added cursor c_ftr_val to check for sending a single
                                        large xml containing information for all students
bradhakr   01-mar-2005   bug -4210676 - Modify the procedure call igs_pr_cp_gpa.get_sua_all to include uoo_id

					or multiple small xml's 1 for each student.
					 | nmankodi   11-Apr-2005     fnd_user.customer_id column has been changed to
 |                            fnd_user.person_party_id as an ebizsuite wide TCA mandate.
swaghmar   15-Sep-2005   bug# 4491456
nmankodi   16-Sep-2005   Bug# 4613611
ijeddy   05-Dec-2006   Bug 4755785  - Modified the update_req_students procedure and added the IF conditions to
                                        check the variable if not null then do the string operation

****************************************************************************************************************** */

  --
  --
  --
  g_pkg_name          CONSTANT     VARCHAR2(30) := 'IGS_DA_XML_PKG';
  PROCEDURE populate_sua_table
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) AS
    --
    v_gpa                NUMBER;
    v_gpa_cp             NUMBER;
    v_gpa_qp             NUMBER;
    v_earned_cp          NUMBER;
    v_attempted_cp       NUMBER;
    v_init_msg_list      VARCHAR2(20):= FND_API.G_TRUE;
    v_return_status      VARCHAR2(1);
    v_msg_count          NUMBER;
    v_msg_data           VARCHAR2(2000);
    v_s_result_type      igs_as_grd_sch_grade.s_result_type%TYPE;
    v_grading_schema_cd  igs_as_grd_sch_grade.grading_schema_cd%TYPE;
    v_gs_version_number  igs_as_grd_sch_grade.version_number%TYPE;
    v_grade              igs_as_grd_sch_grade.grade%TYPE;
    v_mark               igs_as_su_stmptout.mark%TYPE;
    v_outcome_dt         igs_as_su_stmptout.outcome_dt%TYPE;
    v_origin_course_cd   igs_as_su_stmptout.course_cd%TYPE;
    v_unit_cd            igs_en_su_attempt.unit_cd%TYPE;
    v_unit_version_number       igs_en_su_attempt.version_number%TYPE;
    v_teach_cal_type            igs_en_su_attempt.cal_type%TYPE;
    v_teach_ci_sequence_number  igs_en_su_attempt.ci_sequence_number%TYPE;
    v_dummy              VARCHAR2(1);
    --
    CURSOR c_sua IS
    SELECT sua.unit_cd,
           sua.version_number,
           sua.cal_type,
           sua.ci_sequence_number
    FROM   igs_en_su_attempt sua
    WHERE  sua.person_id = p_person_id
    AND    sua.course_cd = p_course_cd
    AND    sua.uoo_id = p_uoo_id;
    --
    CURSOR c_gsg (
      cp_grading_schema_cd  igs_as_grd_sch_grade.grading_schema_cd%TYPE,
      cp_version_number     igs_as_grd_sch_grade.version_number%TYPE,
      cp_grade              igs_as_grd_sch_grade.grade%TYPE
      ) IS
    SELECT 'X'
    FROM   igs_as_grd_sch_grade  gsg
    WHERE  cp_grading_schema_cd = gsg.grading_schema_cd
    AND    cp_version_number    = gsg.version_number
    AND    cp_grade             = gsg.grade
    AND    gsg.show_on_official_ntfctn_ind = 'Y';
    --
  BEGIN
    --
    OPEN c_sua;
    FETCH c_sua INTO v_unit_cd,
                     v_unit_version_number,
                     v_teach_cal_type,
                     v_teach_ci_sequence_number;
    CLOSE c_sua;
    --
    v_s_result_type := igs_as_gen_003.assp_get_sua_outcome (
                         p_person_id,
                         p_course_cd,
                         v_unit_cd,
                         v_teach_cal_type,
                         v_teach_ci_sequence_number,
                         p_unit_attempt_status,
                         'Y',
                         v_outcome_dt,
                         v_grading_schema_cd,
                         v_gs_version_number,
                         v_grade,
                         v_mark,
                         v_origin_course_cd,
                         p_uoo_id,
--added by LKAKI---
			 'N');
    --
    OPEN c_gsg (v_grading_schema_cd,
                v_gs_version_number,
                v_grade);
    FETCH c_gsg INTO v_dummy;
    IF c_gsg%NOTFOUND THEN
        v_grade := NULL;
        v_mark := NULL;
    END IF;
    CLOSE c_gsg;
    --
    -- Get the Student Unit Attempt CP and GPA values
    --
    igs_pr_cp_gpa.get_sua_all (
                              p_person_id                 => p_person_id,
                              p_course_cd                 => p_course_cd,
                              p_unit_cd                   => v_unit_cd,
                              p_unit_version_number       => v_unit_version_number,
                              p_teach_cal_type            => v_teach_cal_type,
                              p_teach_ci_sequence_number  => v_teach_ci_sequence_number,
                              p_stat_type                 => p_stat_type,
                              p_system_stat               => NULL,
                              p_earned_cp                 => v_earned_cp,
                              p_attempted_cp              => v_attempted_cp,
                              p_gpa_value                 => v_gpa,
                              p_gpa_cp                    => v_gpa_cp,
                              p_gpa_quality_points        => v_gpa_qp,
                              p_init_msg_list             => v_init_msg_list,
                              p_return_status             => v_return_status,
                              p_msg_count                 => v_msg_count,
                              p_msg_data                  => v_msg_data,
                              p_uoo_id                    => p_uoo_id
                              );

    --
    -- Store all of the values in the SUA temp table
    --
    sua_table(1).person_id := p_person_id;
    sua_table(1).course_cd :=  p_course_cd;
    sua_table(1).uoo_id :=  p_uoo_id;
    sua_table(1).grade := v_grade;
    sua_table(1).mark := v_mark;
    sua_table(1).s_result_type := v_s_result_type;
    sua_table(1).gpa := v_gpa;
    sua_table(1).gpa_cp := v_gpa_cp;
    sua_table(1).gpa_qp := v_gpa_qp;
    sua_table(1).earned_cp := v_earned_cp;
    sua_table(1).attempted_cp := v_attempted_cp;
    --
  END populate_sua_table;

  --
  --swaghmar 15-Sep-2005 Bug# 4491456
  --
  PROCEDURE populate_load_table
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) AS
    --
    v_cum_gpa             NUMBER;
    v_cum_gpa_cp          NUMBER;
    v_cum_gpa_qp          NUMBER;
    v_cum_earned_cp       NUMBER;
    v_cum_attempted_cp    NUMBER;
    v_init_msg_list       VARCHAR2(20) := FND_API.G_TRUE;
    v_return_status       VARCHAR2(1);
    v_msg_count           NUMBER;
    v_msg_data            VARCHAR2(2000);
    --
  BEGIN
    --
    -- Get the Cum Student Program Attempt CP values
    -- and Student Program Attempt GPA values
    --
    igs_pr_cp_gpa.get_all_stats(
                                  p_person_id                   => p_person_id,
                                  p_course_cd                   => p_course_cd,
                                  p_stat_type                   => p_stat_type,
                                  p_load_cal_type               => p_load_cal_type,
                                  p_load_ci_sequence_number     => p_load_ci_sequence_number,
                                  p_system_stat                 => NULL,
                                  p_cumulative_ind              => 'Y',
                                  p_earned_cp                   => v_cum_earned_cp,
                                  p_attempted_cp                => v_cum_attempted_cp,
                                  p_gpa_value                   => v_cum_gpa,
                                  p_gpa_cp                      => v_cum_gpa_cp,
                                  p_gpa_quality_points          => v_cum_gpa_qp,
                                  p_init_msg_list               => v_init_msg_list,
                                  p_return_status               => v_return_status,
                                  p_msg_count                   => v_msg_count,
                                  p_msg_data                    => v_msg_data
                               );

    --
    -- Store all of the values in the SUA temp table
    --
    load_table(1).person_id := p_person_id;
    load_table(1).course_cd :=  p_course_cd;
    load_table(1).load_cal_type :=  p_load_cal_type;
    load_table(1).load_ci_sequence_number :=  p_load_ci_sequence_number;
    load_table(1).cum_gpa := v_cum_gpa;
    load_table(1).cum_gpa_cp := v_cum_gpa_cp;
    load_table(1).cum_gpa_qp := v_cum_gpa_qp;
    load_table(1).cum_earned_cp := v_cum_earned_cp;
    load_table(1).cum_attempted_cp := v_cum_attempted_cp;
    --
  END populate_load_table;
  --

  --
  --
  --
  FUNCTION get_sua_gpa_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd =  p_course_cd AND
       sua_table(1).uoo_id =  p_uoo_id THEN
      --
      RETURN sua_table(1).gpa_cp;
      --
    ELSE
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_uoo_id,
        p_unit_attempt_status,
        p_stat_type
      );
      --
      RETURN sua_table(1).gpa_cp;
      --
    END IF;
    --
  END get_sua_gpa_cp;
  --
  --
  --
  FUNCTION get_sua_gpa_qp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd =  p_course_cd AND
       sua_table(1).uoo_id =  p_uoo_id THEN
      --
      RETURN sua_table(1).gpa_qp;
      --
    ELSE
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_uoo_id,
        p_unit_attempt_status,
        p_stat_type
      );
      --
      RETURN sua_table(1).gpa_qp;
      --
    END IF;
    --
  END get_sua_gpa_qp;
  --
  --
  --
  FUNCTION get_sua_earned_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd =  p_course_cd AND
       sua_table(1).uoo_id =  p_uoo_id THEN
      --
      RETURN sua_table(1).earned_cp;
      --
    ELSE
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_uoo_id,
        p_unit_attempt_status,
        p_stat_type
      );
      --
      RETURN sua_table(1).earned_cp;
      --
    END IF;
    --
  END get_sua_earned_cp;
  --
  --
  --
  FUNCTION get_sua_attempted_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd = p_course_cd AND
       sua_table(1).uoo_id =  p_uoo_id THEN
      --
      RETURN sua_table(1).attempted_cp;
      --
    ELSE
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_uoo_id,
        p_unit_attempt_status,
        p_stat_type
      );
      --
      RETURN sua_table(1).attempted_cp;
      --
    END IF;
    --
  END get_sua_attempted_cp;
  --
  --
  --
  FUNCTION get_sua_grade
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN VARCHAR2 AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd = p_course_cd AND
       sua_table(1).uoo_id =  p_uoo_id THEN
      --
      RETURN sua_table(1).grade;
      --
    ELSE
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_uoo_id,
        p_unit_attempt_status,
        p_stat_type
      );
      --
      RETURN sua_table(1).grade;
      --
    END IF;
    --
  END get_sua_grade;
  --
  --
  --
  FUNCTION get_sua_mark
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd = p_course_cd AND
       sua_table(1).uoo_id =  p_uoo_id THEN
      --
      RETURN sua_table(1).mark;
      --
    ELSE
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_uoo_id,
        p_unit_attempt_status,
        p_stat_type
      );
      --
      RETURN sua_table(1).mark;
      --
    END IF;
    --
  END get_sua_mark;
  --
  --
  --
  FUNCTION get_sua_result_type
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN VARCHAR2 AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd = p_course_cd AND
       sua_table(1).uoo_id =  p_uoo_id THEN
      --
      RETURN sua_table(1).mark;
      --
    ELSE
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_uoo_id,
        p_unit_attempt_status,
        p_stat_type
      );
      --
      RETURN sua_table(1).s_result_type;
      --
    END IF;
    --
  END get_sua_result_type;
  --
  --
  --
  FUNCTION get_cum_gpa
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF load_table.EXISTS(1) AND
       load_table(1).person_id = p_person_id AND
       load_table(1).course_cd =  p_course_cd AND
       load_table(1).load_cal_type =  p_load_cal_type AND
       load_table(1).load_ci_sequence_number =  p_load_ci_sequence_number THEN
      --
      RETURN load_table(1).cum_gpa;
    ELSE
      --
      populate_load_table (
        p_person_id,
        p_course_cd,
        p_load_cal_type,
        p_load_ci_sequence_number,
        p_stat_type
      );
      --
      RETURN load_table(1).cum_gpa;
      --
    END IF;
    --
  END get_cum_gpa;
  --
  --
  --
  FUNCTION get_cum_gpa_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF load_table.EXISTS(1) AND
       load_table(1).person_id = p_person_id AND
       load_table(1).course_cd =  p_course_cd AND
       load_table(1).load_cal_type =  p_load_cal_type AND
       load_table(1).load_ci_sequence_number =  p_load_ci_sequence_number THEN
      --
      RETURN load_table(1).cum_gpa_cp;
    ELSE
      --
      populate_load_table (
        p_person_id,
        p_course_cd,
        p_load_cal_type,
        p_load_ci_sequence_number,
        p_stat_type
      );
      --
      RETURN load_table(1).cum_gpa_cp;
      --
    END IF;
    --
  END get_cum_gpa_cp;
  --
  --
  --
  FUNCTION get_cum_gpa_qp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF load_table.EXISTS(1) AND
       load_table(1).person_id = p_person_id AND
       load_table(1).course_cd =  p_course_cd AND
       load_table(1).load_cal_type =  p_load_cal_type AND
       load_table(1).load_ci_sequence_number =  p_load_ci_sequence_number THEN
      --
      RETURN load_table(1).cum_gpa_qp;
    ELSE
      --
      populate_load_table (
        p_person_id,
        p_course_cd,
        p_load_cal_type,
        p_load_ci_sequence_number,
        p_stat_type
      );
      --
      RETURN load_table(1).cum_gpa_qp;
      --
    END IF;
    --
  END get_cum_gpa_qp;
  --
  --
  --
  FUNCTION get_cum_earned_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF load_table.EXISTS(1) AND
       load_table(1).person_id = p_person_id AND
       load_table(1).course_cd =  p_course_cd AND
       load_table(1).load_cal_type =  p_load_cal_type AND
       load_table(1).load_ci_sequence_number =  p_load_ci_sequence_number THEN
      --
      RETURN load_table(1).cum_earned_cp;
    ELSE
      --
      populate_load_table (
        p_person_id,
        p_course_cd,
        p_load_cal_type,
        p_load_ci_sequence_number,
        p_stat_type
      );
      --
      RETURN load_table(1).cum_earned_cp;
      --
    END IF;
    --
  END get_cum_earned_cp;
  --
  --
  --
  FUNCTION get_cum_attempted_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_load_cal_type                IN igs_en_su_attempt.cal_type%TYPE,
    p_load_ci_sequence_number      IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF load_table.EXISTS(1) AND
       load_table(1).person_id = p_person_id AND
       load_table(1).course_cd =  p_course_cd AND
       load_table(1).load_cal_type =  p_load_cal_type AND
       load_table(1).load_ci_sequence_number =  p_load_ci_sequence_number THEN
      --
      RETURN load_table(1).cum_attempted_cp;
    ELSE
      --
      populate_load_table (
        p_person_id,
        p_course_cd,
        p_load_cal_type,
        p_load_ci_sequence_number,
        p_stat_type
      );
      --
      RETURN load_table(1).cum_attempted_cp;
      --
    END IF;
    --
  END get_cum_attempted_cp;


-- ============================================================================

  --
  --

  FUNCTION get_course_abbr_num
  (
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_evaluation_type              IN CHAR DEFAULT 'A'
  ) RETURN VARCHAR2 AS
  --
  l_count NUMBER := 0;
  l_str_length NUMBER := 0;
  --
  BEGIN
        --
        l_count := 1;
        l_str_length:= LENGTH(p_unit_cd);
       --
       IF (l_count <= l_str_length) THEN
        LOOP
          --
          IF SUBSTR (p_unit_cd, l_count, l_count) NOT BETWEEN 'A' and 'Z'
             THEN
                --
                IF (p_evaluation_type = 'A') THEN
                  RETURN SUBSTR (p_unit_cd, 0, l_count-1);
                ELSE
                  RETURN SUBSTR (p_unit_cd, l_count, LENGTH(p_unit_cd));
                END IF;
                --
             ELSE
              --
              IF (l_count <= l_str_length) THEN
                l_count:= l_count + 1;
               ELSE
                --
                IF (p_evaluation_type = 'A') THEN
                   RETURN p_unit_cd;
                 ELSE
                   RETURN ' ';
                END IF;
                --
              END IF;
              --
          END IF;
          --
        END LOOP;
        ELSE
          --
          IF (p_evaluation_type = 'A') THEN
            RETURN p_unit_cd;
           ELSE
            RETURN ' ';
          END IF;
          --
       END IF;
       --
  END get_course_abbr_num;
  --
  --
  --  student_type_list combines the student type into a single list
  --  of student type i.e. Student, Instructor, etc...
  --  Default return is not student type...
FUNCTION student_type_list
  (p_person_id IN igs_en_su_attempt.person_id%TYPE
  ) RETURN VARCHAR2 AS

   l_count NUMBER := 0;
   l_counter NUMBER := 0;
   l_str_length NUMBER := 0;
   l_student_type VARCHAR2(100):= '';

    CURSOR c_student_type_data IS
           SELECT person_type_code
             FROM igs_pe_typ_instances_all
            WHERE end_date IS NULL
              AND person_id = p_person_id;

    l_student_type_rec c_student_type_data%ROWTYPE;

   TYPE r_student_type_rec IS RECORD (
        person_type_code     igs_pe_typ_instances_all.person_type_code%TYPE);
   TYPE t_student_type_table IS TABLE OF r_student_type_rec INDEX BY BINARY_INTEGER;
      student_type_table t_student_type_table;

  BEGIN

        OPEN c_student_type_data;
        LOOP
        FETCH c_student_type_data INTO l_student_type_rec;
              student_type_table(l_count).person_type_code := l_student_type_rec.person_type_code;
             l_count := c_student_type_data%ROWCOUNT;
        EXIT WHEN  c_student_type_data%NOTFOUND;
        END LOOP;
        CLOSE c_student_type_data;
         IF (l_count = 0) THEN
           RETURN student_type_table(0).person_type_code;
         END IF;
         IF (l_count >= 1) THEN
           l_student_type:= student_type_table(l_counter).person_type_code;
           l_counter:= l_counter + 1;
           LOOP
            l_student_type:= l_student_type || ', ' || student_type_table(l_counter).person_type_code;
            l_counter := l_counter + 1;
            IF (l_counter >= l_count) THEN
                RETURN l_student_type;
            END IF;
           END LOOP;
           RETURN l_student_type;
         END IF;
      RETURN l_count;
  END student_type_list;
  --
  --
  --
  --
  FUNCTION get_unit_repeatable
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE
  ) RETURN VARCHAR2 AS
  --
    CURSOR suao_gsg_cur is
          SELECT suao.grade, gsg.grade valid_grade, gsg.repeat_grade
          FROM igs_as_grd_sch_grade gsg, igs_as_su_stmptout_all suao
          WHERE
                suao.unit_cd = p_unit_cd
            AND suao.finalised_outcome_ind = 'Y'
            AND suao.grade = gsg.grade
            AND suao.grading_schema_cd = gsg.grading_schema_cd
            AND suao.person_id = p_person_id
            AND suao.unit_cd = p_unit_cd
            AND suao.course_cd = p_course_cd
            AND suao.version_number = p_version_number
            AND suao.cal_type = p_teach_cal_type
            AND suao.ci_sequence_number = p_teach_ci_sequence_number;

        l_suao_gsg_rec suao_gsg_cur%ROWTYPE;
        TYPE r_suao_gsg_rec IS RECORD (
        grade           igs_as_su_stmptout_all.grade%TYPE,
        valid_grade     igs_as_grd_sch_grade.grade%TYPE,
        repeat_grade    igs_as_grd_sch_grade.repeat_grade%TYPE
        );
      TYPE t_suao_gsg_table IS TABLE OF r_suao_gsg_rec INDEX BY BINARY_INTEGER;
      suao_gsg_table t_suao_gsg_table;
  --
    CURSOR repeatable_cur is
         SELECT uv.repeatable_ind
       FROM hz_parties p, igs_en_stdnt_ps_att spa, igs_ps_ver crv, igs_ca_teach_to_load_v ttl,
       igs_en_su_attempt sua, igs_ps_unit_ver uv, igs_ps_unit_ofr_opt uoo, IGS_PS_PRG_UNIT_REL pur,
       igs_as_su_atmptout_h_all atm
       WHERE p.party_id = sua.person_id
       AND sua.person_id = p_person_id
       AND sua.unit_cd = p_unit_cd
       AND sua.course_cd = p_course_cd
       AND sua.version_number = p_version_number
       AND sua.cal_type  = p_teach_cal_type
       AND sua.ci_sequence_number = p_teach_ci_sequence_number
       AND sua.unit_attempt_status = p_unit_attempt_status
       AND sua.person_id = spa.person_id
       AND sua.course_cd = spa.course_cd
       AND sua.person_id = atm.person_id
       AND sua.course_cd = atm.course_cd
       AND atm.unit_cd = sua.unit_cd
       AND sua.unit_attempt_status IN ('ENROLLED','COMPLETED','DUPLICATE','DISCONTIN')
       AND uv.unit_cd = sua.unit_cd
       AND uv.version_number = sua.version_number
       AND sua.uoo_id = uoo.uoo_id
       AND spa.course_cd = crv.course_cd
       AND spa.version_number = crv.version_number
       AND sua.cal_type = ttl.teach_cal_type
       AND sua.ci_sequence_number = ttl.teach_ci_sequence_number
       AND (sua.student_career_transcript = 'Y'
       OR (sua.student_career_transcript IS NULL
       AND pur.unit_type_id = uv.unit_type_id
       AND pur.student_career_level = crv.course_type
       AND pur.student_career_transcript = 'Y'));

      l_repeatable_rec repeatable_cur%ROWTYPE;

      TYPE r_repeatable_rec IS RECORD (
        repeatable_ind     igs_ps_unit_ver.repeatable_ind%TYPE
        );
      TYPE t_repeat_table IS TABLE OF r_repeatable_rec INDEX BY BINARY_INTEGER;
      repeat_table t_repeat_table;

       l_count NUMBER := 0;
      l_str_length NUMBER := 0;

  BEGIN
       OPEN repeatable_cur;
        LOOP
         FETCH repeatable_cur INTO l_repeatable_rec;
         repeat_table(l_count).repeatable_ind := l_repeatable_rec.repeatable_ind;
         EXIT WHEN repeatable_cur%ROWCOUNT > 2 OR repeatable_cur%NOTFOUND;
         -- Check to see if unit is repeatable
         IF (repeat_table(l_count).repeatable_ind = 'N') THEN
         l_count := repeatable_cur%ROWCOUNT;
         END IF; -- end check of repeat indicator
        END LOOP;
         CLOSE repeatable_cur;
       -- Is there more than one attempt on the unit?
          IF (l_count > 1) THEN
          l_count := 0;
          OPEN suao_gsg_cur;
           LOOP
            FETCH suao_gsg_cur INTO l_suao_gsg_rec;
            suao_gsg_table(l_count).grade := l_suao_gsg_rec.grade;
            suao_gsg_table(l_count).valid_grade := l_suao_gsg_rec.grade;
            suao_gsg_table(l_count).repeat_grade := l_suao_gsg_rec.repeat_grade;

            IF  (l_count-1 > 0) THEN
             IF ((suao_gsg_table(l_count).grade = suao_gsg_table(l_count -1).repeat_grade
                  AND suao_gsg_table(l_count -1).repeat_grade <> NULL)
                 OR suao_gsg_table(l_count).grade <> NULL ) THEN
                RETURN 'true';
               ELSE
                RETURN 'false';
             END IF;
             ELSE
                RETURN 'false';
            END IF;
            l_count := l_count + 1;
           END LOOP;
            CLOSE suao_gsg_cur;
          END IF;
          RETURN 'false';
       --
       --
       --
  END get_unit_repeatable;


  PROCEDURE get_person_details
  (
  p_person_id_code                 IN igs_pe_alt_pers_id.api_person_id%TYPE,
  p_person_id_code_type            IN igs_pe_alt_pers_id.api_person_id%TYPE,
  p_person_id                      OUT NOCOPY hz_parties.party_id%TYPE,
  p_person_number                  OUT NOCOPY hz_parties.party_number%TYPE) IS

   CURSOR c1 IS
   SELECT hp.party_id
   FROM hz_parties hp
   WHERE hp.party_number = p_person_id_code;

   CURSOR c2 IS
   SELECT hp.party_id, hp.party_number
   FROM   hz_parties hp,
          igs_pe_alt_pers_id  api,
          igs_da_setup ds
   WHERE  ds.s_control_num = 1
   AND    api.api_person_id = p_person_id_code
   AND    api.person_id_type = ds.default_student_id_type
   AND    api.pe_person_id = hp.party_id
   AND    (api.end_dt >= SYSDATE or api.end_dt is null);


  BEGIN

   IF p_person_id_code_type = 'OSS' THEN
      FOR v_dummy IN c1 LOOP
      p_person_id := v_dummy.party_id;
      END LOOP;
      p_person_number := p_person_id_code;

   ELSE
       FOR v_dummy IN c2 LOOP
       p_person_id :=  v_dummy.party_id;
       p_person_number := v_dummy.party_number;
       END LOOP;
   END IF;
   RETURN;

 END;

PROCEDURE update_stdnts_err (
  p_batch_id   IN igs_da_req_stdnts.batch_id%TYPE,
  p_person_id_code  IN igs_pe_alt_pers_id.api_person_id%TYPE,
  p_person_id_code_type IN igs_pe_alt_pers_id.person_id_type%TYPE,
  p_report_text IN igs_da_req_stdnts.report_text%TYPE,
  p_error_code IN igs_da_req_stdnts.error_code%TYPE,
  x_return_status  OUT NOCOPY VARCHAR2
  ) IS
  l_err_msg_pos1 VARCHAR2(30);
  l_person_id  hz_parties.party_id%TYPE;
  l_person_number hz_parties.party_number%TYPE;


  CURSOR c1 IS
      SELECT ROWID,drs.*
      FROM   igs_da_req_stdnts drs
      WHERE  drs.batch_id = p_batch_id
      AND    drs.person_id = l_person_id;

  l_found BOOLEAN := FALSE;

BEGIN
  ecx_debug.push('IGS_DA_XML_PKG.UPDATE_STDNTS_ERR');
  x_return_status := 'S';

   get_person_details (p_person_id_code,p_person_id_code_type,l_person_id,l_person_number);

         l_err_msg_pos1 := 'IGS_PROGRAM_ERROR C1';
         FOR v_dummy IN c1 LOOP
         IGS_DA_REQ_STDNTS_PKG.UPDATE_ROW
         (v_dummy.ROWID,
          v_dummy.batch_id,
          v_dummy.igs_da_req_stdnts_id,
          v_dummy.person_id,
          v_dummy.program_code,
          v_dummy.wif_program_code,
          v_dummy.special_program_code,
          v_dummy.major_unit_set_cd,
          v_dummy.program_major_code,
          p_report_text,
          v_dummy.wif_id,
          'R',
          p_error_code);
          l_found := TRUE;
         END LOOP;

      --Update the request status bug #3438386
   IF (l_found) THEN
    update_request_status(p_batch_id);
   END IF;

   IF NOT (l_found) THEN
      ecx_debug.pl (0, 'IGS', 'IGS_PROCEDURE_EXECUTION', 'PROCEDURE_NAME',g_pkg_name);
      ecx_debug.pl (0, 'IGS', 'IGS_ERROR_MSG'||'Error Code =' || p_error_code ,'E: Unable to Update');
      x_return_status := 'E: Unable to Update';
   END IF;

   ecx_debug.pop('IGS_DA_XML_PKG.UPDATE_REQ_STUDENTS');
-- Check if the error code updated successfully , else return status error.
 EXCEPTION
         WHEN NO_DATA_FOUND THEN
               ecx_debug.pl(0,'IGS','IGS_PROGRAM_ERROR','PROGRESS_LEVEL','IGS_DA_XML_PKG.UPDATE_REQ_STUDENTS');
               ecx_debug.pl(0,'IGS','IGS_ERROR_MSG - NO DATA','ERROR_MESSAGE',SQLERRM);
               ecx_debug.setErrorInfo(2,30,SQLERRM||' -IGS_DA_XML_PKG.UPDATE_REQ_STUDENTS');
               x_return_status := 'E: UPDATE FAILED';
         WHEN OTHERS THEN
               ecx_debug.pl(0,'IGS','IGS_PROGRAM_ERROR','PROGRESS_LEVEL','IGS_DA_XML_PKG.UPDATE_REQ_STUDENTS');
               ecx_debug.pl(0,'IGS','IGS_ERROR_MSG - OTHERS','ERROR_MESSAGE',SQLERRM);
               ecx_debug.setErrorInfo(2,30,SQLERRM||' -IGS_DA_XML_PKG.UPDATE_REQ_STUDENTS');
               x_return_status := 'E: Other Exception';

END;


PROCEDURE update_req_students (
  p_batch_id   IN igs_da_req_stdnts.batch_id%TYPE,
  p_person_id_code  IN igs_pe_alt_pers_id.api_person_id%TYPE,
  p_person_id_code_type IN igs_pe_alt_pers_id.person_id_type%TYPE,
  p_report_text IN igs_da_req_stdnts.report_text%TYPE,
  p_academicsubprogram_codes IN VARCHAR2,
  p_program_code IN igs_da_req_stdnts.program_code%TYPE,
  p_error_code IN igs_da_req_stdnts.error_code%TYPE,
  x_return_status  OUT NOCOPY VARCHAR2
  ) IS

  l_api_name   CONSTANT VARCHAR2(30)   := 'UPDATE_REQ_STUDENTS';
  l_error_code VARCHAR2(30);
  l_person_id  hz_parties.party_id%TYPE;
  l_person_number hz_parties.party_number%TYPE;
  l_progmajor_ind igs_da_setup.program_definition_ind%TYPE;
  l_prog_comparison_type igs_da_rqst.program_comparison_type%TYPE;
  pos1 NUMBER ;
  pos2 NUMBER ;
  pos3 NUMBER ;
  l_academicsubprogramcode1 igs_en_unit_set.unit_set_cd%TYPE;
  l_academicsubprogramcode2 igs_en_unit_set.unit_set_cd%TYPE;
  l_academicsubprogramcode3 igs_en_unit_set.unit_set_cd%TYPE;

   CURSOR c_prog_comp IS
   SELECT dr.program_comparison_type
   FROM igs_da_rqst dr
   WHERE dr.batch_id =  RTRIM(LTRIM(p_batch_id)) ;

   CURSOR c_prog_def IS
   SELECT ds.program_definition_ind
   FROM igs_da_setup ds
   WHERE ds.s_control_num = 1;

  CURSOR c1 IS
      SELECT ROWID,drs.*
      FROM   igs_da_req_stdnts drs
      WHERE  drs.batch_id =  RTRIM(LTRIM(p_batch_id))
      AND    drs.person_id = l_person_id
      AND    drs.program_major_code =  RTRIM(LTRIM(p_program_code));

  CURSOR c2 IS
      SELECT ROWID,drs.*
      FROM   igs_da_req_stdnts drs
      WHERE  drs.batch_id =  RTRIM(LTRIM(p_batch_id))
      AND    drs.person_id = l_person_id
      AND    drs.program_major_code =  RTRIM(LTRIM(p_program_code))
      AND    EXISTS (SELECT 'X'
                     FROM   igs_da_req_wif drw
                     WHERE  drw.batch_id = drs.batch_id
                     AND    drw.wif_id = drs.wif_id
                     AND    drw.program_code = drs.wif_program_code
                     AND    drw.major_unit_set_cd1 = drs.major_unit_set_cd
                     AND    (drw.minor_unit_set_cd1 =  RTRIM(LTRIM(l_academicsubprogramcode1))
                            AND    EXISTS (SELECT 'X'
                                    FROM   igs_en_unit_set eus,igs_en_unit_set_stat euss, igs_da_setup ds
                                    WHERE  eus.unit_set_status=euss.unit_set_status
                                    AND    euss.s_unit_set_status = 'ACTIVE'
                                    AND    eus.unit_set_cd = drw.minor_unit_set_cd1
                                    AND    eus.unit_set_cat = ds.wif_minor_unit_set_cat
                                    AND    ds.s_control_num =1)
                             OR drw.minor_unit_set_cd1 IS NULL)
                     AND    (drw.track_unit_set_cd1 =  RTRIM(LTRIM(l_academicsubprogramcode2))
                             AND    EXISTS (SELECT 'X'
                                    FROM   igs_en_unit_set eus,igs_en_unit_set_stat euss, igs_da_setup ds
                                    WHERE  eus.unit_set_status=euss.unit_set_status
                                    AND    euss.s_unit_set_status = 'ACTIVE'
                                    AND    eus.unit_set_cd = drw.track_unit_set_cd1
                                    AND    eus.unit_set_cat = ds.wif_track_unit_set_cat
                                    AND    ds.s_control_num =1)
                             OR drw.track_unit_set_cd1 IS NULL));

      CURSOR c3 IS
      SELECT  ROWID,drs.*
      FROM   igs_da_req_stdnts drs
      WHERE  drs.batch_id =  RTRIM(LTRIM(p_batch_id))
      AND    drs.person_id = l_person_id
      AND    drs.program_code =  RTRIM(LTRIM(p_program_code));

      CURSOR c4 IS
      SELECT  ROWID,drs.*
      FROM igs_da_req_stdnts drs
      WHERE  drs.batch_id =  RTRIM(LTRIM(p_batch_id))
      AND    drs.person_id = l_person_id
      AND    drs.special_program_code =  RTRIM(LTRIM(p_program_code));

      CURSOR c5 IS
      SELECT  ROWID,drs.*
      FROM   igs_da_req_stdnts drs
      WHERE  drs.batch_id =  RTRIM(LTRIM(p_batch_id))
      AND    drs.person_id = l_person_id
      AND    drs.wif_program_code =  RTRIM(LTRIM(p_program_code))
      AND    exists (SELECT 'X'
                     FROM   igs_da_req_wif drw
                     WHERE  drw.batch_id = drs.batch_id
                     AND    drw.wif_id = drs.wif_id
                     AND    drw.program_code = drs.wif_program_code
                     AND    (drw.major_unit_set_cd1 =  RTRIM(LTRIM(l_academicsubprogramcode1))
                             AND    EXISTS (SELECT 'X'
                                    FROM   igs_en_unit_set eus,igs_en_unit_set_stat euss, igs_da_setup ds
                                    WHERE  eus.unit_set_status=euss.unit_set_status
                                    AND    euss.s_unit_set_status = 'ACTIVE'
                                    AND    eus.unit_set_cd = drw.major_unit_set_cd1
                                    AND    eus.unit_set_cat = ds.wif_major_unit_set_cat
                                    AND    ds.s_control_num =1)
                             OR drw.major_unit_set_cd1 IS NULL)
                     AND    (drw.minor_unit_set_cd1 =  RTRIM(LTRIM(l_academicsubprogramcode2))
                             AND    EXISTS (SELECT 'X'
                                    FROM   igs_en_unit_set eus,igs_en_unit_set_stat euss, igs_da_setup ds
                                    WHERE  eus.unit_set_status=euss.unit_set_status
                                    AND    euss.s_unit_set_status = 'ACTIVE'
                                    AND    eus.unit_set_cd = drw.minor_unit_set_cd1
                                    AND    eus.unit_set_cat = ds.wif_minor_unit_set_cat
                                    AND    ds.s_control_num =1)
                             OR drw.minor_unit_set_cd1 IS NULL)
                     AND    (drw.track_unit_set_cd1 =  RTRIM(LTRIM(l_academicsubprogramcode3))
                             AND    EXISTS (SELECT 'X'
                                    FROM   igs_en_unit_set eus,igs_en_unit_set_stat euss, igs_da_setup ds
                                    WHERE  eus.unit_set_status=euss.unit_set_status
                                    AND    euss.s_unit_set_status = 'ACTIVE'
                                    AND    eus.unit_set_cd = drw.track_unit_set_cd1
                                    AND    eus.unit_set_cat = ds.wif_track_unit_set_cat
                                    AND    ds.s_control_num =1)
                             OR drw.track_unit_set_cd1 IS NULL));

  l_found BOOLEAN := FALSE;

BEGIN

   -- need to be changed for NLS
   -- need to add 'REPLY_ERROR' to IGS_LOOKUP_VALUES.
   -- Check if the <ErrorCode> element is present , if yes then update all the request student rows.
   IF p_error_code IS NOT NULL THEN
   l_error_code := 'REPLY_ERROR';
   END IF;

   ecx_debug.push('IGS_DA_XML_PKG.UPDATE_REQ_STUDENTS');
   x_return_status := 'S';

   get_person_details ( RTRIM(LTRIM(p_person_id_code)), RTRIM(LTRIM(p_person_id_code_type)),l_person_id,l_person_number);

   FOR v_dummy IN c_prog_comp LOOP
   l_prog_comparison_type := v_dummy.program_comparison_type;
   END LOOP;

   FOR v_dummy IN c_prog_def LOOP
   l_progmajor_ind := v_dummy.program_definition_ind;
   END LOOP;
   -- Bug 4961469 Added the IF condition to check if the values are not null then do the string operation.
   pos1 := instr( RTRIM(LTRIM(p_academicsubprogram_codes)),',',1,1);
   IF (pos1 <>  NULL) THEN
        l_academicsubprogramcode1 := substr( RTRIM(LTRIM(p_academicsubprogram_codes)),1,pos1-1);
   END IF;
   pos2 := instr(p_academicsubprogram_codes,',',1,2);
   IF (pos2 <> NULL) THEN
           l_academicsubprogramcode2 := substr( RTRIM(LTRIM(p_academicsubprogram_codes)),pos1+1,pos2-pos1-1);
   END IF;
   pos3 := instr(p_academicsubprogram_codes,',',1,3);
   IF (pos3 <> NULL) THEN
           l_academicsubprogramcode3 := substr( RTRIM(LTRIM(p_academicsubprogram_codes)),pos2+1,pos3-pos2-1);
   END IF;

   IF (l_progmajor_ind = 'Y' ) THEN
      IF ((l_prog_comparison_type ='DP') OR (l_prog_comparison_type ='SP')) THEN
         FOR v_dummy IN c1 LOOP
         IGS_DA_REQ_STDNTS_PKG.UPDATE_ROW
         (v_dummy.ROWID,
          v_dummy.batch_id,
          v_dummy.igs_da_req_stdnts_id,
          v_dummy.person_id,
          v_dummy.program_code,
          v_dummy.wif_program_code,
          v_dummy.special_program_code,
          v_dummy.major_unit_set_cd,
          v_dummy.program_major_code,
          p_report_text,
          v_dummy.wif_id,
          'R',
          l_error_code);
          l_found := TRUE;
         END LOOP;
      ELSIF (l_prog_comparison_type ='WIF') THEN
         FOR v_dummy IN c2 LOOP
         IGS_DA_REQ_STDNTS_PKG.UPDATE_ROW
         (v_dummy.ROWID,
          v_dummy.batch_id,
          v_dummy.igs_da_req_stdnts_id,
          v_dummy.person_id,
          v_dummy.program_code,
          v_dummy.wif_program_code,
          v_dummy.special_program_code,
          v_dummy.major_unit_set_cd,
          v_dummy.program_major_code,
          p_report_text,
          v_dummy.wif_id,
          'R',
          l_error_code);
          l_found := TRUE;
         END LOOP;
      END IF;
   ELSE
      IF (l_prog_comparison_type ='DP') THEN
         FOR v_dummy IN c3 LOOP
         IGS_DA_REQ_STDNTS_PKG.UPDATE_ROW
         (v_dummy.ROWID,
          v_dummy.batch_id,
          v_dummy.igs_da_req_stdnts_id,
          v_dummy.person_id,
          v_dummy.program_code,
          v_dummy.wif_program_code,
          v_dummy.special_program_code,
          v_dummy.major_unit_set_cd,
          v_dummy.program_major_code,
          p_report_text,
          v_dummy.wif_id,
          'R',
          l_error_code);
            l_found := TRUE;
         END LOOP;
      ELSIF (l_prog_comparison_type ='SP') THEN
         FOR v_dummy IN c4 LOOP
         IGS_DA_REQ_STDNTS_PKG.UPDATE_ROW
         (v_dummy.ROWID,
          v_dummy.batch_id,
          v_dummy.igs_da_req_stdnts_id,
          v_dummy.person_id,
          v_dummy.program_code,
          v_dummy.wif_program_code,
          v_dummy.special_program_code,
          v_dummy.major_unit_set_cd,
          v_dummy.program_major_code,
          p_report_text,
          v_dummy.wif_id,
          'R',
          l_error_code);
            l_found := TRUE;
         END LOOP;
      ELSIF (l_prog_comparison_type ='WIF') THEN
         FOR v_dummy IN c5 LOOP
         IGS_DA_REQ_STDNTS_PKG.UPDATE_ROW
         (v_dummy.ROWID,
          v_dummy.batch_id,
          v_dummy.igs_da_req_stdnts_id,
          v_dummy.person_id,
          v_dummy.program_code,
          v_dummy.wif_program_code,
          v_dummy.special_program_code,
          v_dummy.major_unit_set_cd,
          v_dummy.program_major_code,
          p_report_text,
          v_dummy.wif_id,
          'R',
          l_error_code);
            l_found := TRUE;
         END LOOP;
      END IF;
   END IF;

   --Update the request status bug #3438386
   IF (l_found )THEN
    update_request_status(p_batch_id);
   END IF;

   IF NOT (l_found) THEN
      ecx_debug.pl (0, 'IGS', 'IGS_PROCEDURE_EXECUTION', 'PROCEDURE_NAME',g_pkg_name);
      ecx_debug.pl (0, 'IGS', 'IGS_REPORT_UPDATE_FAILED','E: Unable to Update');
      x_return_status := 'E: Unable to Update';
   END IF;

   ecx_debug.pop('IGS_DA_XML_PKG.UPDATE_REQ_STUDENTS');
-- Check if the update is successfull , else return status error.
 EXCEPTION
         WHEN NO_DATA_FOUND THEN
               ecx_debug.pl(0,'IGS','IGS_PROGRAM_ERROR','PROGRESS_LEVEL','IGS_DA_XML_PKG.UPDATE_REQ_STUDENTS');
               ecx_debug.pl(0,'IGS','IGS_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
               ecx_debug.setErrorInfo(2,30,SQLERRM||' -IGS_DA_XML_PKG.UPDATE_REQ_STUDENTS');
               x_return_status := 'E: UPDATE FAILED';
         WHEN OTHERS THEN
               ecx_debug.pl(0,'IGS','IGS_PROGRAM_ERROR','PROGRESS_LEVEL','IGS_DA_XML_PKG.UPDATE_REQ_STUDENTS');
               ecx_debug.pl(0,'IGS','IGS_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
               ecx_debug.setErrorInfo(2,30,SQLERRM||' -IGS_DA_XML_PKG.UPDATE_REQ_STUDENTS');
               x_return_status := 'E: Other Exception';

END;

PROCEDURE insert_gpa
  (
  p_batch_id                       IN igs_pr_stu_acad_stat_int.batch_id%TYPE,
  p_person_id_code                 IN igs_pe_alt_pers_id.api_person_id%TYPE,
  p_person_id_code_type            IN igs_pe_alt_pers_id.person_id_type%TYPE,
  p_program_code                   IN igs_da_req_stdnts.program_code%TYPE,
  p_alternate_code                 IN igs_pr_stu_acad_stat_int.alternate_code%TYPE,
  p_stat_type                      IN igs_pr_stu_acad_stat_int.stat_type%TYPE,
  p_timeframe                      IN igs_pr_stu_acad_stat_int.timeframe%TYPE,
  p_attempted_credit_points        IN igs_pr_stu_acad_stat_int.attempted_credit_points%TYPE,
  p_earned_credit_points           IN igs_pr_stu_acad_stat_int.earned_credit_points%TYPE,
  p_gpa                            IN igs_pr_stu_acad_stat_int.gpa%TYPE,
  p_gpa_credit_points              IN igs_pr_stu_acad_stat_int.gpa_credit_points%TYPE,
  p_gpa_quality_points             IN igs_pr_stu_acad_stat_int.gpa_quality_points%TYPE,
  x_return_status                  OUT NOCOPY VARCHAR2
  ) IS

  l_api_name   CONSTANT VARCHAR2(30)   := 'INSERT_GPA';
  l_person_id  hz_parties.party_id%TYPE;
  l_person_number hz_parties.party_number%TYPE;
  l_program_code igs_pr_stu_acad_stat_int.course_cd%TYPE;

  CURSOR c1 IS
    SELECT drs.program_code
    FROM igs_da_req_stdnts drs
    WHERE  drs.batch_id =  RTRIM(LTRIM(p_batch_id))
    AND    drs.person_id = l_person_id
    AND    ((drs.program_major_code =  RTRIM(LTRIM(p_program_code))) OR (drs.program_code =  RTRIM(LTRIM(p_program_code))));

BEGIN
     ecx_debug.push('IGS_DA_XML_PKG.INSERT_GPA');
     x_return_status := 'S';

     get_person_details ( RTRIM(LTRIM(p_person_id_code)), RTRIM(LTRIM(p_person_id_code_type)),l_person_id,l_person_number);

     FOR v_dummy IN c1 LOOP
     l_program_code := v_dummy.program_code;
     END LOOP;

     INSERT INTO igs_pr_stu_acad_stat_int
     (BATCH_ID,
     COURSE_CD,
     PERSON_NUMBER,
     ALTERNATE_CODE,
     STAT_TYPE,
     TIMEFRAME,
     SOURCE_TYPE,
     SOURCE_REFERENCE,
     ATTEMPTED_CREDIT_POINTS,
     EARNED_CREDIT_POINTS,
     GPA,
     GPA_CREDIT_POINTS,
     GPA_QUALITY_POINTS,
     ERROR_CODE,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN
     )
     VALUES
     (
      RTRIM(LTRIM(p_batch_id)),
     l_program_code,
     l_person_number,
     RTRIM(LTRIM(p_alternate_code)),
     RTRIM(LTRIM(p_stat_type)),
     RTRIM(LTRIM(p_timeframe)),
     'DEGREE AUDIT',
     'DEGREE AUDIT',
      RTRIM(LTRIM(p_attempted_credit_points)),
      RTRIM(LTRIM(p_earned_credit_points)),
      RTRIM(LTRIM(p_gpa)),
      RTRIM(LTRIM(p_gpa_credit_points)),
      RTRIM(LTRIM(p_gpa_quality_points)),
     NULL,
     1,
     SYSDATE,
     1,
     SYSDATE,
     NULL);

     ecx_debug.pop('IGS_DA_XML_PKG.INSERT_GPA');
      EXCEPTION
         WHEN OTHERS THEN
               ecx_debug.pl(0,'IGS','IGS_PROGRAM_ERROR','PROGRESS_LEVEL','IGS_DA_XML_PKG.INSERT_GPA');
               ecx_debug.pl(0,'IGS','IGS_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
               ecx_debug.setErrorInfo(2,30,SQLERRM||' -IGS_DA_XML_PKG.INSERT_GPA');
               x_return_status := 'E: Other Exception';
END;

PROCEDURE insert_program_completion
  (
  p_batch_id                       IN igs_pr_spa_complete_int.batch_id%TYPE,
  p_person_id_code                 IN igs_pe_alt_pers_id.api_person_id%TYPE,
  p_person_id_code_type            IN igs_pe_alt_pers_id.person_id_type%TYPE,
  p_program_code                   IN igs_da_req_stdnts.program_code%TYPE,
  p_program_complete               IN VARCHAR2,
  p_program_complete_date          IN VARCHAR2,
  x_return_status                  OUT NOCOPY VARCHAR2
  ) IS

  l_api_name   CONSTANT VARCHAR2(30)   := 'INSERT_PROGRAM_COMPLETION';
  l_person_id  hz_parties.party_id%TYPE;
  l_person_number hz_parties.party_number%TYPE;
  l_program_code igs_pr_spa_complete_int.course_cd%TYPE;

  CURSOR c1 IS
    SELECT drs.program_code
    FROM igs_da_req_stdnts drs
    WHERE  drs.batch_id =  RTRIM(LTRIM(p_batch_id))
    AND    drs.person_id = l_person_id
    AND    ((drs.program_major_code =  RTRIM(LTRIM(p_program_code))) OR (drs.program_code =  RTRIM(LTRIM(p_program_code))));

BEGIN
     ecx_debug.push('IGS_DA_XML_PKG.INSERT_DEGREE_COMPLETION');
     x_return_status := 'S';

     get_person_details ( RTRIM(LTRIM(p_person_id_code)), RTRIM(LTRIM(p_person_id_code_type)),l_person_id,l_person_number);

     FOR v_dummy IN c1 LOOP
     l_program_code := v_dummy.program_code;
     END LOOP;

     IF ( RTRIM(LTRIM(p_program_complete)) ='true') THEN
     INSERT INTO igs_pr_spa_complete_int
     (BATCH_ID,
      PERSON_NUMBER,
      COURSE_CD,
      COMPLETE_DT,
      ERROR_CODE,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
      )
      VALUES
      ( RTRIM(LTRIM(p_batch_id)),
      l_person_number,
      l_program_code,
      -- Modified by nmankodi, Bug # 4613611
      NVL(to_date(substr(RTRIM(LTRIM(p_program_complete_date)),1,10),'YYYY-MM-DD'),SYSDATE),
      NULL,
      1,
      SYSDATE,
      1,
      SYSDATE,
      NULL);
      END IF;

      ecx_debug.pop('IGS_DA_XML_PKG.INSERT_DEGREE_COMPLETION');

       EXCEPTION
         WHEN OTHERS THEN
               ecx_debug.pl(0,'IGS','IGS_PROGRAM_ERROR','PROGRESS_LEVEL','IGS_DA_XML_PKG.INSERT_PROGRAM_COMPLETION');
               ecx_debug.pl(0,'IGS','IGS_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
               ecx_debug.setErrorInfo(2,30,SQLERRM||' -IGS_DA_XML_PKG.INSERT_PROGRAM_COMPLETION');
               x_return_status := 'E: Other Exception';
END;

/*****************************************************************/
PROCEDURE Submit_Event (
  p_batch_id   IN IGS_DA_REQ_STDNTS.BATCH_ID%TYPE
)
IS

  l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
  l_event_name    VARCHAR2(255);
  l_event_key     VARCHAR2(255);
  l_party_id      HZ_PARTY_SITES.PARTY_ID%TYPE;
  l_party_site_id HZ_PARTY_SITES.PARTY_SITE_ID%TYPE;
  l_trans_type    VARCHAR2(30) :='DA';
  l_trans_subtype VARCHAR2(30) ;
  l_party_type    VARCHAR2(30) :='C';
  l_debug_level   NUMBER := 0;
  l_wif           NUMBER := 0;
  l_count         NUMBER := 0;
  l_doc_id        IGS_DA_REQ_STDNTS.BATCH_ID%TYPE;
  l_batch_profile VARCHAR2(1) := 'N';

  CURSOR c_student IS
   SELECT drs.person_id
   FROM igs_da_req_stdnts drs
   WHERE drs.batch_id = p_batch_id;


  CURSOR c_party_data IS
 SELECT party_id,
          party_site_id
     FROM ecx_tp_headers
    WHERE tp_header_id IN
          ( SELECT tp_header_id
              FROM ecx_tp_details
             WHERE ext_process_id IN
             ( SELECT ext_process_id
                 FROM ecx_ext_processes
                WHERE direction = 'OUT'
                      AND transaction_id IN
                 (SELECT et.transaction_id
                    FROM ecx_transactions et, ecx_ext_processes ep
                   WHERE transaction_type='DA'
                   and  ep.transaction_id = et.transaction_id
                   and ep.ext_type =
                               (select dcry.request_type
                                 from igs_da_cnfg_req_typ dcry, igs_da_rqst dr
                                 where dr.batch_id = p_batch_id
                                 and dcry.request_type_id = dr.request_type_id )
                                 and ep.direction = 'OUT')
              )
           );

         CURSOR c_transaction_data IS
                   SELECT et.transaction_subtype
                     FROM ecx_transactions et, ecx_ext_processes ep
                    WHERE transaction_type='DA'
                      and  ep.transaction_id = et.transaction_id
                      and ep.direction = 'OUT'
                      and ep.ext_type = (select dcry.request_type
                                from igs_da_cnfg_req_typ dcry, igs_da_rqst dr
                                where dr.batch_id = p_batch_id
                                and dcry.request_type_id = dr.request_type_id );

/******************************************************************************/
/***** wif --  What-If --                                                                 */
/*Degree Audit process needs to be able to distinguish between Standard Degree*/
/*Audits and What-If Degree Audits - Request Types.                           */
/*  For added processing by the Trading Partners                              */
/******************************************************************************/

         CURSOR c_wif IS
                 SELECT count(drs.wif_program_code)
                   FROM igs_da_req_stdnts drs
                  WHERE drs.batch_id = p_batch_id
                    AND wif_program_code is not null;

        CURSOR c_transaction_wif_data IS
               SELECT et.transaction_subtype
                     FROM ecx_transactions et, ecx_ext_processes ep
                    WHERE transaction_type='DA'
                      and  ep.transaction_id = et.transaction_id
                      and ep.direction = 'OUT'
                      and ep.ext_type = 'WF';
        /* Cursor to determine if single large XML is to be generated or multiple small xml's */

        CURSOR c_ftr_val IS
	    SELECT feature_value
		  FROM igs_da_req_ftrs
	    WHERE batch_id = p_batch_id AND feature_code = 'SNG' ;

/******************************************************************************/


BEGIN

   l_event_name := 'oracle.apps.igs.da.xml.reqsubm';

  OPEN c_transaction_data;
  FETCH c_transaction_data INTO l_trans_subtype;
  CLOSE c_transaction_data;

  OPEN c_party_data;
  FETCH c_party_data INTO l_party_id, l_party_site_id;
  CLOSE c_party_data;

/******************************************************************************/
/***** wif
/******************************************************************************/
  OPEN c_wif;
  FETCH c_wif INTO l_wif;
  CLOSE c_wif;

  IF l_wif <> 0 THEN
     OPEN c_transaction_wif_data;
     FETCH c_transaction_wif_data INTO l_trans_subtype;
     CLOSE c_transaction_wif_data;
  END IF;
/******************************************************************************/

  IF l_party_id IS NULL THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_SV_PRTNR_STP_ERR'); -- No trading partner setup  found
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;


  OPEN c_ftr_val ;
  FETCH c_ftr_val INTO l_batch_profile ;
  IF c_ftr_val%NOTFOUND THEN
    l_batch_profile := 'N';
  END IF;
  CLOSE c_ftr_val;

-- if single large xml document needs to be generated...
  IF l_batch_profile = 'Y' THEN

-- Use person_id and batch_id for event key.
  l_event_key := p_batch_id || l_count+1;
  -- Create a new document ID for each student XML document created.
  l_doc_id    := p_batch_id || l_count ;

    wf_event.AddParameterToList(p_name=>'ECX_DOCUMENT_ID',p_value=>l_doc_id
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'PARAMETER5',p_value=>p_batch_id
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'PARAMETER4',p_value=>NULL
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ECX_PARTY_ID',p_value=>l_party_id
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ECX_PARTY_SITE_ID',p_value=>l_party_site_id
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ECX_TRANSACTION_TYPE',p_value=>l_trans_type
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ECX_TRANSACTION_SUBTYPE',p_value=>l_trans_subtype
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ECX_PARTY_TYPE',p_value=>l_party_type
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ECX_DEBUG_LEVEL',p_value=>l_debug_level
                                                  ,p_parameterlist=>l_parameter_list);
  -- Raise the Event without the message
  -- The Generate Function Callback will create the XML Document
  -- Also possible that an API might be called from here to
  -- to generate the XML document
  wf_event.raise( p_event_name => l_event_name,
                  p_event_key  => l_event_key,
                  p_parameters => l_parameter_list);

  l_parameter_list.DELETE;


  ELSE
  --Loop through all the students in the batch request.
  --And generate a workflow request for each student.
  FOR v_dummy IN c_student LOOP

  -- Use person_id and batch_id for event key.
  l_event_key := v_dummy.person_id || p_batch_id ;
  -- Create a new document ID for each student XML document created.
  l_doc_id    := p_batch_id || l_count ;

    wf_event.AddParameterToList(p_name=>'ECX_DOCUMENT_ID',p_value=>l_doc_id
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'PARAMETER5',p_value=>p_batch_id
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'PARAMETER4',p_value=>v_dummy.person_id
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ECX_PARTY_ID',p_value=>l_party_id
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ECX_PARTY_SITE_ID',p_value=>l_party_site_id
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ECX_TRANSACTION_TYPE',p_value=>l_trans_type
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ECX_TRANSACTION_SUBTYPE',p_value=>l_trans_subtype
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ECX_PARTY_TYPE',p_value=>l_party_type
                                                  ,p_parameterlist=>l_parameter_list);
    wf_event.AddParameterToList(p_name=>'ECX_DEBUG_LEVEL',p_value=>l_debug_level
                                                  ,p_parameterlist=>l_parameter_list);
  -- Raise the Event without the message
  -- The Generate Function Callback will create the XML Document
  -- Also possible that an API might be called from here to
  -- to generate the XML document
  wf_event.raise( p_event_name => l_event_name,
                  p_event_key  => l_event_key,
                  p_parameters => l_parameter_list);

  l_parameter_list.DELETE;
  l_count     := l_count + 1;

 END LOOP;
 END IF;
END;
/*****************************************************************************************/

PROCEDURE process_reply_failure
(p_batch_id   IN igs_da_req_stdnts.batch_id%TYPE
) IS
  l_da_wf_admin_id fnd_profile_options.profile_option_name%TYPE := FND_PROFILE.VALUE('IGS_DA_WF_ADMIN');
  CURSOR c_request_status IS
      SELECT 'X'
      FROM igs_da_rqst dr
      WHERE  dr.batch_id = p_batch_id
      FOR UPDATE OF dr.request_status NOWAIT;

  CURSOR c_requestor IS
      SELECT dr.requestor_id,fdu.user_name
      FROM   igs_da_rqst dr, fnd_user fdu
      WHERE  dr.batch_id = p_batch_id
      AND    dr.requestor_id = fdu.person_party_id;
  CURSOR c_da_wf_admin IS
      SELECT fdu.person_party_id,fdu.user_name
      FROM   fnd_user fdu
      WHERE  fdu.person_party_id = l_da_wf_admin_id;


  l_da_wf_admin_name  fnd_user.user_name%TYPE;
  l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
  l_event_name    VARCHAR2(255);
  l_event_key     VARCHAR2(255);
  l_debug_level   NUMBER := 3;
  l_requester     fnd_user.user_name%TYPE;
  l_error_type    VARCHAR2(2) := '25';
  l_error_code    VARCHAR2(2) := '25';
  l_error_message VARCHAR2(20);

BEGIN
SAVEPOINT PROCESS_REPLY_FAILURE;
     ecx_debug.push('IGS_DA_XML_PKG.PROCESS_REPLY_FAILURE');
     FOR v_dummy IN c_request_status LOOP
         UPDATE igs_da_rqst
         SET request_status = 'ERROR'
         WHERE CURRENT OF c_request_status;
     END LOOP;

     IF (l_da_wf_admin_id IS NOT NULL) THEN
        FOR v_dummy IN c_requestor LOOP
        l_requester := v_dummy.user_name;
        END LOOP;
        FOR v_dummy IN c_da_wf_admin LOOP
        l_da_wf_admin_name := v_dummy.user_name;
        END LOOP;

        l_event_name := 'oracle.apps.igs.da.xml.rcverr';
        l_event_key := p_batch_id;
        wf_event.AddParameterToList(p_name=>'TO_USERNAME',p_value=>l_da_wf_admin_name
                                               ,p_parameterlist=>l_parameter_list);
        wf_event.AddParameterToList(p_name=>'BATCH_ID',p_value=>p_batch_id
                                               ,p_parameterlist=>l_parameter_list);
        wf_event.AddParameterToList(p_name=>'REQ_USERNAME',p_value=>l_requester
                                               ,p_parameterlist=>l_parameter_list);

        wf_event.raise( p_event_name => l_event_name,
                        p_event_key  => l_event_key,
                        p_parameters => l_parameter_list);

        l_parameter_list.DELETE;


     ELSE
     ECX_ACTIONS.SET_ERROR_EXIT_PROGRAM(l_error_type,l_error_code,l_error_message);
     END IF;
     ecx_debug.pop('IGS_DA_XML_PKG.PROCESS_REPLY_FAILURE');
END;

PROCEDURE update_request_status
(p_batch_id   IN  igs_da_req_stdnts.batch_id%TYPE
) IS
 l_api_name           CONSTANT VARCHAR2(30) := 'UPDATE_REQUEST_STATUS' ;
 l_request_status     VARCHAR2(30) := 'SUBMITTED';
 l_RETURN_STATUS      VARCHAR2(10);
 l_err_count          NUMBER(10):= 0;
 l_noClob_count       NUMBER(10):= 0;
 l_clob_count         NUMBER(10):= 0;
 l_reply_err_count    NUMBER(10):= 0;
 l_request_err_count  NUMBER(10):= 0;

  CURSOR c_request_status IS
      SELECT ROWID,dr.*
      FROM igs_da_rqst dr
      WHERE  dr.batch_id = p_batch_id;

BEGIN

SAVEPOINT UPDATE_REQUEST_STATUS;

-- Get the current error count of students that failed in the pre-processing and could not make it in the Request XML Document
-- of the selected batch_id
  select count(*)
  into l_request_err_count
  from igs_da_req_stdnts
  where batch_id = p_batch_id
  and error_code ='PRE- SUBMISSION FAILURE';

-- Get the current error count of students that failed with the a <Error Code> element in the ReplyXML
-- of the selected batch_id
-- need to be changed for NLS
-- need to add 'REPLY_ERROR' to IGS_LOOKUP_VALUES.
  select count(*)
  into l_reply_err_count
  from igs_da_req_stdnts
  where batch_id = p_batch_id
  and error_code ='REPLY_ERROR';

-- Get the current count of students not containing reports
-- in the selected batch_id
  select count(*)
  into l_noClob_count
  from igs_da_req_stdnts
  where batch_id = p_batch_id
  and report_text is null;

-- Get the current count of students containing reports
-- in the selected batch_id
  select count(*)
  into l_clob_count
  from igs_da_req_stdnts
  where batch_id = p_batch_id
  and report_text is not null;

--Set the current Status of the batch requst.
l_err_count := l_request_err_count + l_reply_err_count;


IF l_err_count = 0 THEN
      IF (l_noClob_count = 0) THEN l_request_status := 'COMPLETED'; END IF;
      IF(l_noClob_count > 0 AND l_Clob_count > 0) THEN l_request_status := 'COMPLETE_ERROR' ; END IF;
      IF (l_Clob_count = 0) THEN l_request_status := 'SUBMITTED'; END IF;
ELSE
      IF ( l_reply_err_count >0 ) THEN l_request_status := 'COMPLETE_ERROR';  END IF;
      IF (l_request_err_count > 0 AND l_Clob_count > l_request_err_count)  THEN l_request_status := 'COMPLETE_ERROR'; END IF;
      IF (l_request_err_count > 0 AND l_Clob_count = l_request_err_count)  THEN l_request_status := 'SUBMIT_ERROR'; END IF;
END IF;

   UPDATE igs_da_rqst
	SET  REQUEST_STATUS =  l_request_status
	WHERE batch_id = p_batch_id;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  --If execution error, rollback all database changes, generate message text
  --and return failure status to the WF
     ROLLBACK TO UPDATE_REQUEST_STATUS;

     return;

WHEN OTHERS THEN
     RAISE ;

END;

PROCEDURE launch_notify_err_wf (p_batch_id igs_da_req_stdnts.batch_id%TYPE) IS
   l_item_key VARCHAR2(100);
   -- cursor to find the requestor
      CURSOR c_req (cp_batch_id igs_da_rqst.batch_id%TYPE) IS
             SELECT user_name
	     FROM   fnd_user
	     WHERE  person_party_id IN (SELECT requestor_id
	                            FROM igs_da_rqst
				    WHERE batch_id = cp_batch_id);
      l_req VARCHAR2(2000);
BEGIN
     ECX_DEBUG.PUSH('IGS_DA_XML_PKG.LAUNCH_NOTIFY_ERR_WF');
     l_item_key := 'DANTFERR'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISSSSS');
     OPEN c_req(p_batch_id);
     FETCH c_req INTO l_req;
     CLOSE c_req;
     IF l_req IS NULL THEN
        l_req := 'SYSADMIN';
     END IF;
     WF_ENGINE.CreateProcess  (ItemType => 'DANTFERR',
                               Itemkey  => l_item_key,
			       process  => 'NTFREQST');
     WF_ENGINE.SetItemAttrText(ItemType => 'DANTFERR',
                               ItemKey  => l_item_key,
			       aname    => 'BATCH_ID',
			       avalue   => to_char(p_batch_id));
     WF_ENGINE.SetItemAttrText(ItemType => 'DANTFERR',
                               ItemKey  => l_item_key,
			       aname    => 'REQUESTOR',
			       avalue   => l_req);

     WF_ENGINE.StartProcess (ItemType => 'DANTFERR',
                             ItemKey  => l_item_key);
     ECX_DEBUG.POP('IGS_DA_XML_PKG.LAUNCH_NOTIFY_ERR_WF');
  EXCEPTION
     WHEN OTHERS THEN
        WF_CORE.Context('IGS_DA_XML_PKG','launch_notify_err_wf',l_item_key);
	RAISE;
END launch_notify_err_wf;

PROCEDURE pre_submit_event (p_batch_id IN igs_da_req_stdnts.batch_id%TYPE) IS
/*
   This procedure filters out the erroroneous record from the batch and show
   the error message through the html report. It can happen that in a batch id,
   which is having more than 1 students and 1 student's record fails to meet the
   mandatory criteria. Also if it happens that the complete batch id is failing,
   no call to submit_event, which generates the XML Message will be made.
*/

-- cursor to fetch the list of person_id in the given batch_id
   CURSOR c_list_person_id (cp_batch_id igs_da_req_stdnts.batch_id%TYPE,
                            cp_igs_da_req_stdnts_id igs_da_req_stdnts.igs_da_req_stdnts_id%TYPE) IS
          SELECT person_id, igs_da_req_stdnts_id
	  FROM   igs_da_req_stdnts
	  WHERE  batch_id = cp_batch_id
	  AND    igs_da_req_stdnts_id=cp_igs_da_req_stdnts_id;

-- curosr to count the person_id in the batch_id
   CURSOR c_count_person_id (cp_batch_id igs_da_req_stdnts.batch_id%TYPE) IS
          SELECT count(*)
	  FROM   igs_da_req_stdnts
	  WHERE  batch_id = cp_batch_id;

   l_count_person_id  NUMBER;

-- cursor to validate the record from the view IGS_DA_XML_PERSON_V
   CURSOR c_person_v (cp_batch_id igs_da_req_stdnts.batch_id%TYPE,
                      cp_person_id igs_da_req_stdnts.person_id%TYPE) IS
          SELECT  person_code_qualifier,
                  person_id_code,
                  name_type,
                  name_first,
                  name_last
          FROM    igs_da_xml_person_v
	  WHERE   batch_id = cp_batch_id
	  AND     person_id = cp_person_id;

-- cursor to validate the record from the view IGS_DA_XML_DEGREEPROGRAM_V
/* removing this chech as igs_da_xml_degreeprogram_v has three cols only and
   all of them are not null

   CURSOR c_degprg_v (cp_batch_id igs_da_req_stdnts.batch_id%TYPE,
                  cp_person_id igs_da_req_stdnts.person_id%TYPE) IS
          SELECT institution_cd
	  FROM   igs_da_xml_degreeprogram_v
	  WHERE  batch_id = cp_batch_id
	  AND    person_id = cp_person_id;
*/
-- cursor to validate the record from the view IGS_DA_XML_ACADEMICPROGRAM_V
   CURSOR c_acadprg_v (cp_batch_id igs_da_req_stdnts.batch_id%TYPE,
                       cp_person_id igs_da_req_stdnts.person_id%TYPE) IS
          SELECT program_type,
	         program_code,
		 program_catalog_year
	  FROM   igs_da_xml_academicprogram_v
	  WHERE  batch_id = cp_batch_id
	  AND    person_id = cp_person_id;

-- cursor to update igs_da_req_stdnts
   CURSOR c_req_stdnts (cp_batch_id igs_da_req_stdnts.batch_id%TYPE,
                       cp_person_id igs_da_req_stdnts.person_id%TYPE,
		       cp_igs_da_req_stdnts_id igs_da_req_stdnts.igs_da_req_stdnts_id%TYPE) IS
          SELECT rowid, a.*
	  FROM   igs_da_req_stdnts a
	  WHERE  batch_id = cp_batch_id
	  AND    person_id = cp_person_id
	  AND    igs_da_req_stdnts_id = cp_igs_da_req_stdnts_id;

-- cursor to run for each req_stdnts_id
   CURSOR c_req_stdnts_id (cp_batch_id igs_da_req_stdnts.batch_id%TYPE) IS
          SELECT igs_da_req_stdnts_id
	  FROM   igs_da_req_stdnts
	  WHERE  batch_id = cp_batch_id;
   ctr_tbl NUMBER;
   pid_exists VARCHAR2(1);
   v_report_text VARCHAR2(4000);
   l_pcode_qual_exists  VARCHAR2(1);
   l_pid_code_exists    VARCHAR2(1);
   l_name_type_exists   VARCHAR2(1);
   l_name_first_exists  VARCHAR2(1);
   l_name_last_exists   VARCHAR2(1);
   l_prog_type_exists   VARCHAR2(1);
   l_prog_code_exists   VARCHAR2(1);
   l_prog_cat_exists    VARCHAR2(1);
     -- need to be changed for NLS
     -- needt to add 'PRE-SUBMISSION FAILURE' to IGS_LOOKUP_VALUES.
   l_error_code         VARCHAR2(30) := 'PRE- SUBMISSION FAILURE';

     FUNCTION get_person (pp_person_id igs_da_req_stdnts.person_id%TYPE) RETURN VARCHAR2 IS
        CURSOR c_get_pers (cp_person_id igs_da_req_stdnts.person_id%TYPE) IS
	       SELECT party_name||' ('||party_number||') '
	       FROM   hz_parties
	       WHERE  party_id = cp_person_id;
        v_get_pers VARCHAR2(4000);
     BEGIN
        OPEN c_get_pers (pp_person_id);
	FETCH c_get_pers INTO v_get_pers;
	CLOSE c_get_pers;
	RETURN v_get_pers;
     END get_person;

BEGIN
  ECX_DEBUG.PUSH('IGS_DA_XML_PKG.PRE_SUBMIT_EVENT');
  -- initialize the variable
  ctr_tbl:=0;
  pid_exists:='N';
  l_pcode_qual_exists:='N';
  l_pid_code_exists  :='N';
  l_name_type_exists :='N';
  l_name_first_exists:='N';
  l_name_last_exists :='N';
  l_prog_type_exists :='N';
  l_prog_code_exists :='N';
  l_prog_cat_exists  :='N';

  -- find the count of person in the given batch id
  OPEN c_count_person_id(p_batch_id);
  FETCH c_count_person_id INTO l_count_person_id;
  CLOSE c_count_person_id;
  -- loop through the list of person id in the given batch
  -- to identify the missing attribute
  FOR rec_req_stdnts_id IN c_req_stdnts_id(p_batch_id)
  LOOP
	  FOR rec_list_person_id IN c_list_person_id(p_batch_id,rec_req_stdnts_id.igs_da_req_stdnts_id)
	  LOOP
		     -- check whether PersonIdCodeQualifier, PersonIdCode
		     -- NameType, NameFirst, NameLast exist for the person id or not
		     FOR rec_person_v IN c_person_v (p_batch_id,rec_list_person_id.person_id)
		     LOOP
			     IF rec_person_v.person_code_qualifier IS NULL OR
				rec_person_v.person_id_code IS NULL OR
				rec_person_v.name_type IS NULL OR
				rec_person_v.name_first IS NULL OR
				rec_person_v.name_last IS NULL THEN
				ctr_tbl := ctr_tbl+1;
				pid_exists := 'Y';
				v_report_text := v_report_text ||' '|| get_person(rec_list_person_id.person_id) || ' does not have: <BR> ';
			     END IF;
			     IF rec_person_v.person_code_qualifier IS NULL AND l_pcode_qual_exists = 'N' THEN
			        l_pcode_qual_exists:='Y';
				v_report_text := v_report_text ||' '|| ' Person Code Qualifier. <BR>';
			     END IF;
			     IF rec_person_v.person_id_code IS NULL AND l_pid_code_exists = 'N' THEN
			        l_pid_code_exists := 'Y';
				v_report_text := v_report_text ||' '|| ' Person Id Code. <BR>';
			     END IF;
			     IF rec_person_v.name_type IS NULL AND l_name_type_exists = 'N' THEN
			        l_name_type_exists := 'Y';
				v_report_text := v_report_text ||' '|| ' Name Type. <BR>';
			     END IF;
			     IF rec_person_v.name_first IS NULL AND l_name_first_exists = 'N' THEN
			        l_name_first_exists := 'Y';
				v_report_text := v_report_text ||' '|| ' Name First. <BR>';
			     END IF;
			     IF rec_person_v.name_last IS NULL AND l_name_last_exists = 'N' THEN
			        l_name_last_exists:='Y';
				v_report_text := v_report_text ||' '|| ' Name Last. <BR>';
			     END IF;
		    END LOOP; --FOR rec_person_v IN c_person_v (p_batch_id,rec_list_person_id.person_id)

		    -- check that the student has local institution defined in IGS_DA_XML_DEGREEPROGRAM_V
		    /* removing this chech as igs_da_xml_degreeprogram_v has three cols only and
		       all of them are not null
		    FOR rec_degprg_v IN c_degprg_v (p_batch_id,rec_list_person_id.person_id)
		    LOOP
			    IF rec_degprg_v.institution_cd IS NULL THEN
			       IF pid_exists = 'N' THEN
				  ctr_tbl := ctr_tbl+1;
				  v_report_text := v_report_text ||' '|| get_person(rec_list_person_id.person_id) ||' '|| ' does not have: <BR> ';
			       END IF;
			       v_report_text := v_report_text ||' '|| ' Local Institution. <BR>';
			    END IF;
		    END LOOP; --FOR rec_degprg_v IN c_degprg_v (p_batch_id,rec_list_person_id.person_id)
		    */
		    -- check that the student has valid record in IGS_DA_XML_ACADEMICPROGRAM_V
		    FOR rec_acadprg_v IN c_acadprg_v (p_batch_id,rec_list_person_id.person_id)
		    LOOP
			     IF rec_acadprg_v.program_type IS NULL OR
				rec_acadprg_v.program_code IS NULL OR
				rec_acadprg_v.program_catalog_year IS NULL THEN
				IF pid_exists = 'N' THEN
				   ctr_tbl := ctr_tbl + 1;
				   pid_exists := 'Y';
				   v_report_text := v_report_text ||' '||get_person(rec_list_person_id.person_id) ||' does not have: <BR> ';
				END IF;
			     END IF;
			     IF rec_acadprg_v.program_type IS NULL AND l_prog_type_exists = 'N' THEN
			        l_prog_type_exists := 'Y';
				v_report_text := v_report_text ||' '|| ' Program Type. <BR>';
			     END IF;
			     IF rec_acadprg_v.program_code IS NULL AND l_prog_code_exists = 'N' THEN
			        l_prog_code_exists := 'Y';
				v_report_text := v_report_text ||' '|| ' Program Code. <BR>';
			     END IF;
			     IF rec_acadprg_v.program_catalog_year IS NULL AND l_prog_cat_exists = 'N' THEN
			        l_prog_cat_exists := 'Y';
				v_report_text := v_report_text ||' '|| ' Program Catalog Year. <BR>';
			     END IF;
		    END LOOP; --     FOR rec_acadprg_v IN c_acadprg_v (p_batch_id,rec_list_person_id.person_id)
		    -- now update the req_stdnts table
		    IF v_report_text IS NOT NULL THEN
			v_report_text := ' <HTML> <BODY> Error Report <BR> <BR> '||v_report_text||' '|| ' </BODY> </HTML> ';
		    END IF;
                    IF v_report_text IS NOT NULL THEN
			UPDATE igs_da_req_stdnts
			SET report_text = v_report_text,
                -- bug fix 3438386 - update error code for internal request failues.
                error_code = l_error_code
			WHERE batch_id = p_batch_id
			AND   person_id = rec_list_person_id.person_id
			AND   igs_da_req_stdnts_id = rec_req_stdnts_id.igs_da_req_stdnts_id;
		    END IF;
		/*
			igs_da_req_stdnts_pkg.update_row (
				X_ROWID                        => rec_req_stdnts.ROWID,
				X_BATCH_ID                     => rec_req_stdnts.batch_id,
				X_IGS_DA_REQ_STDNTS_ID         => rec_req_stdnts.igs_da_req_stdnts_id,
				X_PERSON_ID                    => rec_req_stdnts.person_id,
				X_PROGRAM_CODE                 => rec_req_stdnts.program_code,
				X_WIF_PROGRAM_CODE             => rec_req_stdnts.wif_program_code,
				X_SPECIAL_PROGRAM_CODE         => rec_req_stdnts.special_program_code,
				X_MAJOR_UNIT_SET_CD            => rec_req_stdnts.major_unit_set_cd,
				X_PROGRAM_MAJOR_CODE           => rec_req_stdnts.program_major_code,
				X_REPORT_TEXT                  => v_report_text,
				X_WIF_ID                       => rec_req_stdnts.wif_id,
				X_MODE                         => 'R'
							  );
		  */
		    v_report_text := NULL;
		    pid_exists := 'N';
		    l_pcode_qual_exists:='N';
                    l_pid_code_exists  :='N';
                    l_name_type_exists :='N';
                    l_name_first_exists:='N';
                    l_name_last_exists :='N';
                    l_prog_type_exists :='N';
                    l_prog_code_exists :='N';
                    l_prog_cat_exists  :='N';
	  END LOOP; -- FOR rec_list_person_id IN c_list_person_id(p_batch_id,rec_req_stdnts_id.igs_da_req_stdnts_id)
  END LOOP; --    FOR rec_req_stdnts_id IN c_req_stdnts_id(p_batch_id)
  /*
     now, check the count and directly call the
     submit_event else first launch the workflow to notify the error
  */
  ECX_DEBUG.PUSH('BEFORE CALL TO SUBMIT_EVENT');
  IF ctr_tbl = 0 THEN
     submit_event(p_batch_id);
  ELSE
     launch_notify_err_wf(p_batch_id);
     IF l_count_person_id <> ctr_tbl THEN
        submit_event(p_batch_id);
     END IF;
  END IF; -- IF v_person_tbl.COUNT = 0 THEN
  ECX_DEBUG.POP('BEFORE CALL TO SUBMIT_EVENT');
  ECX_DEBUG.POP('IGS_DA_XML_PKG.PRE_SUBMIT_EVENT');
END pre_submit_event;

END IGS_DA_XML_PKG;

/
