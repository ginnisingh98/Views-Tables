--------------------------------------------------------
--  DDL for Package Body IGS_PR_ACAD_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_ACAD_DETAILS" AS
/* $Header: IGSPR34B.pls 120.1 2005/09/15 03:19:26 appldev ship $ */
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the PROCEDURE populate_sua_table
  -- swaghmar 15-Sep-2005 Bug# 4491456
  --
  PROCEDURE populate_sua_table
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE
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
    v_dummy              VARCHAR2(1);
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
    -- kdande; 23-Apr-2003; Bug# 2829262
    -- Added uoo_id parameter to the igs_as_gen_003.assp_get_sua_outcome
    -- FUNCTION call
    --
    v_s_result_type := igs_as_gen_003.assp_get_sua_outcome (
                         p_person_id,
                         p_course_cd,
                         p_unit_cd,
                         p_teach_cal_type,
                         p_teach_ci_sequence_number,
                         p_unit_attempt_status,
                         'Y',
                         v_outcome_dt,
                         v_grading_schema_cd,
                         v_gs_version_number,
                         v_grade,
                         v_mark,
                         v_origin_course_cd,
                         p_uoo_id,
--added by LKAKI----
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
    -- As part of FA111 build bug 2708843 replaced the calls to
    -- igs_pr_cp_gpa.get_sua_gpa and igs_pr_cp_gpa.get_sua_cp
    -- with a single call to igs_pr_cp_gpa.get_sua_all
    --
    -- kdande; 23-Apr-2003; Bug# 2829262
    -- Added uoo_id parameter to the igs_pr_cp_gpa.get_sua_all FUNCTION call
    --
    igs_pr_cp_gpa.get_sua_all (
      p_person_id                 => p_person_id,
      p_course_cd                 => p_course_cd,
      p_unit_cd                   => p_unit_cd,
      p_unit_version_number       => p_version_number,
      p_teach_cal_type            => p_teach_cal_type,
      p_teach_ci_sequence_number  => p_teach_ci_sequence_number,
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
    sua_table(1).unit_cd :=  p_unit_cd;
    sua_table(1).version_number :=  p_version_number;
    sua_table(1).teach_cal_type :=  p_teach_cal_type;
    sua_table(1).teach_ci_sequence_number :=  p_teach_ci_sequence_number;
    sua_table(1).grade := v_grade;
    sua_table(1).mark := v_mark;
    sua_table(1).gpa := v_gpa;
    sua_table(1).gpa_cp := v_gpa_cp;
    sua_table(1).gpa_qp := v_gpa_qp;
    sua_table(1).earned_cp := v_earned_cp;
    sua_table(1).attempted_cp := v_attempted_cp;
    sua_table(1).uoo_id := p_uoo_id;
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
    v_load_gpa            igs_as_grd_sch_grade.gpa_val%TYPE;
    v_load_gpa_cp         igs_ps_unit_ver.achievable_credit_points%TYPE;
    v_load_gpa_qp         igs_ps_unit_ver.achievable_credit_points%TYPE;
    v_load_earned_cp      igs_ps_unit_ver.achievable_credit_points%TYPE;
    v_load_attempted_cp   igs_ps_unit_ver.achievable_credit_points%TYPE;
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
    -- Get the Term Student Program Attempt CP and
    -- Term Student Program Attempt GPA values
    --
    /*
       As part of FA111 build bug 2708843
       replaced the calls to igs_pr_cp_gpa.get_cp_stats
       and igs_pr_cp_gpa.get_gpa_stats with a single call to
       igs_pr_cp_gpa.get_all_stats
    */
    igs_pr_cp_gpa.get_all_stats(
                                  p_person_id                   => p_person_id,
                                  p_course_cd                   => p_course_cd,
                                  p_stat_type                   => p_stat_type,
                                  p_load_cal_type               => p_load_cal_type,
                                  p_load_ci_sequence_number     => p_load_ci_sequence_number,
                                  p_system_stat                 => NULL,
                                  p_cumulative_ind              => 'N',
                                  p_earned_cp                   => v_load_earned_cp,
                                  p_attempted_cp                => v_load_attempted_cp,
                                  p_gpa_value                   => v_load_gpa,
                                  p_gpa_cp                      => v_load_gpa_cp,
                                  p_gpa_quality_points          => v_load_gpa_qp,
                                  p_init_msg_list               => v_init_msg_list,
                                  p_return_status               => v_return_status,
                                  p_msg_count                   => v_msg_count,
                                  p_msg_data                    => v_msg_data
                               );

    --
    -- Get the Cum Student Program Attempt CP values
    -- and Student Program Attempt GPA values
    --
    /*
       As part of FA111 build bug 2708843
       replaced the calls to igs_pr_cp_gpa.get_cp_stats
       and igs_pr_cp_gpa.get_gpa_stats with a single call to
       igs_pr_cp_gpa.get_all_stats
    */
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
    load_table(1).load_gpa := v_load_gpa;
    load_table(1).load_gpa_cp := v_load_gpa_cp;
    load_table(1).load_gpa_qp := v_load_gpa_qp;
    load_table(1).load_earned_cp := v_load_earned_cp;
    load_table(1).load_attempted_cp := v_load_attempted_cp;
    load_table(1).cum_gpa := v_cum_gpa;
    load_table(1).cum_gpa_cp := v_cum_gpa_cp;
    load_table(1).cum_gpa_qp := v_cum_gpa_qp;
    load_table(1).cum_earned_cp := v_cum_earned_cp;
    load_table(1).cum_attempted_cp := v_cum_attempted_cp;
    --
  END populate_load_table;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_gpa
  --
  FUNCTION get_sua_gpa
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd = p_course_cd AND
       sua_table(1).unit_cd = p_unit_cd AND
       sua_table(1).version_number = p_version_number AND
       sua_table(1).teach_cal_type = p_teach_cal_type AND
       sua_table(1).teach_ci_sequence_number = p_teach_ci_sequence_number AND
       sua_table(1).uoo_id = p_uoo_id THEN
      --
      RETURN sua_table(1).gpa;
      --
    ELSE
      --
      -- kdande; 23-Apr-2003; Bug# 2829262
      -- Added uoo_id parameter to the populate_sua_table PROCEDURE call
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_unit_cd,
        p_version_number,
        p_teach_cal_type,
        p_teach_ci_sequence_number,
        p_unit_attempt_status,
        p_stat_type,
        p_uoo_id
      );
      --
      RETURN sua_table(1).gpa;
      --
    END IF;
    --
  END get_sua_gpa;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_gpa_cp
  --
  FUNCTION get_sua_gpa_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd = p_course_cd AND
       sua_table(1).unit_cd = p_unit_cd AND
       sua_table(1).version_number = p_version_number AND
       sua_table(1).teach_cal_type = p_teach_cal_type AND
       sua_table(1).teach_ci_sequence_number = p_teach_ci_sequence_number AND
       sua_table(1).uoo_id = p_uoo_id THEN
      --
      RETURN sua_table(1).gpa_cp;
      --
    ELSE
      --
      -- kdande; 23-Apr-2003; Bug# 2829262
      -- Added uoo_id parameter to the populate_sua_table PROCEDURE call
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_unit_cd,
        p_version_number,
        p_teach_cal_type,
        p_teach_ci_sequence_number,
        p_unit_attempt_status,
        p_stat_type,
        p_uoo_id
      );
      --
      RETURN sua_table(1).gpa_cp;
      --
    END IF;
    --
  END get_sua_gpa_cp;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_gpa_qp
  --
  FUNCTION get_sua_gpa_qp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd =  p_course_cd AND
       sua_table(1).unit_cd =  p_unit_cd AND
       sua_table(1).version_number =  p_version_number AND
       sua_table(1).teach_cal_type =  p_teach_cal_type AND
       sua_table(1).teach_ci_sequence_number =  p_teach_ci_sequence_number AND
       sua_table(1).uoo_id = p_uoo_id THEN
      --
      RETURN sua_table(1).gpa_qp;
      --
    ELSE
      --
      -- kdande; 23-Apr-2003; Bug# 2829262
      -- Added uoo_id parameter to the populate_sua_table PROCEDURE call
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_unit_cd,
        p_version_number,
        p_teach_cal_type,
        p_teach_ci_sequence_number,
        p_unit_attempt_status,
        p_stat_type,
        p_uoo_id
      );
      --
      RETURN sua_table(1).gpa_qp;
      --
    END IF;
    --
  END get_sua_gpa_qp;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_earned_cp
  --
  FUNCTION get_sua_earned_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd =  p_course_cd AND
       sua_table(1).unit_cd =  p_unit_cd AND
       sua_table(1).version_number =  p_version_number AND
       sua_table(1).teach_cal_type =  p_teach_cal_type AND
       sua_table(1).teach_ci_sequence_number =  p_teach_ci_sequence_number AND
       sua_table(1).uoo_id = p_uoo_id THEN
      --
      RETURN sua_table(1).earned_cp;
      --
    ELSE
      --
      -- kdande; 23-Apr-2003; Bug# 2829262
      -- Added uoo_id parameter to the populate_sua_table PROCEDURE call
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_unit_cd,
        p_version_number,
        p_teach_cal_type,
        p_teach_ci_sequence_number,
        p_unit_attempt_status,
        p_stat_type,
        p_uoo_id
      );
      --
      RETURN sua_table(1).earned_cp;
      --
    END IF;
    --
  END get_sua_earned_cp;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_attempted_cp
  --
  FUNCTION get_sua_attempted_cp
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd = p_course_cd AND
       sua_table(1).unit_cd = p_unit_cd AND
       sua_table(1).version_number = p_version_number AND
       sua_table(1).teach_cal_type = p_teach_cal_type AND
       sua_table(1).teach_ci_sequence_number = p_teach_ci_sequence_number AND
       sua_table(1).uoo_id = p_uoo_id THEN
      --
      RETURN sua_table(1).attempted_cp;
      --
    ELSE
      --
      -- kdande; 23-Apr-2003; Bug# 2829262
      -- Added uoo_id parameter to the populate_sua_table PROCEDURE call
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_unit_cd,
        p_version_number,
        p_teach_cal_type,
        p_teach_ci_sequence_number,
        p_unit_attempt_status,
        p_stat_type,
        p_uoo_id
      );
      --
      RETURN sua_table(1).attempted_cp;
      --
    END IF;
    --
  END get_sua_attempted_cp;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_grade
  --
  FUNCTION get_sua_grade
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE
  ) RETURN VARCHAR2 AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd = p_course_cd AND
       sua_table(1).unit_cd = p_unit_cd AND
       sua_table(1).version_number = p_version_number AND
       sua_table(1).teach_cal_type = p_teach_cal_type AND
       sua_table(1).teach_ci_sequence_number = p_teach_ci_sequence_number AND
       sua_table(1).uoo_id = p_uoo_id THEN
      --
      RETURN sua_table(1).grade;
      --
    ELSE
      --
      -- kdande; 23-Apr-2003; Bug# 2829262
      -- Added uoo_id parameter to the populate_sua_table PROCEDURE call
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_unit_cd,
        p_version_number,
        p_teach_cal_type,
        p_teach_ci_sequence_number,
        p_unit_attempt_status,
        p_stat_type,
        p_uoo_id
      );
      --
      RETURN sua_table(1).grade;
      --
    END IF;
    --
  END get_sua_grade;
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION get_sua_mark
  --
  FUNCTION get_sua_mark
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_unit_cd                      IN igs_en_su_attempt.unit_cd%TYPE,
    p_version_number               IN igs_en_su_attempt.version_number%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE,
    p_unit_attempt_status          IN igs_en_su_attempt.unit_attempt_status%TYPE,
    p_stat_type                    IN igs_pr_org_stat.stat_type%TYPE,
    p_uoo_id                       IN igs_en_su_attempt.uoo_id%TYPE
  ) RETURN NUMBER AS
  --
  BEGIN
    --
    IF sua_table.EXISTS(1) AND
       sua_table(1).person_id = p_person_id AND
       sua_table(1).course_cd = p_course_cd AND
       sua_table(1).unit_cd = p_unit_cd AND
       sua_table(1).version_number = p_version_number AND
       sua_table(1).teach_cal_type = p_teach_cal_type AND
       sua_table(1).teach_ci_sequence_number = p_teach_ci_sequence_number AND
       sua_table(1).uoo_id = p_uoo_id THEN
      --
      RETURN sua_table(1).mark;
      --
    ELSE
      --
      -- kdande; 23-Apr-2003; Bug# 2829262
      -- Added uoo_id parameter to the populate_sua_table PROCEDURE call
      --
      populate_sua_table (
        p_person_id,
        p_course_cd,
        p_unit_cd,
        p_version_number,
        p_teach_cal_type,
        p_teach_ci_sequence_number,
        p_unit_attempt_status,
        p_stat_type,
        p_uoo_id
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
  FUNCTION get_sua_yop
  (
    p_person_id                    IN igs_en_su_attempt.person_id%TYPE,
    p_course_cd                    IN igs_en_su_attempt.course_cd%TYPE,
    p_teach_cal_type               IN igs_en_su_attempt.cal_type%TYPE,
    p_teach_ci_sequence_number     IN igs_en_su_attempt.ci_sequence_number%TYPE
  ) RETURN VARCHAR2 AS
    --
    -- This function returns the Unit Set Code of any YOP specific Student Unit
    -- Set Attempts which have Selection and Requirements Complete/End Dates
    -- which span the Census Date of the Teaching Period provided. If more than
    -- one exists the one with the latest selection date will be returned
    --
    v_unit_set_cd      IGS_EN_UNIT_SET.unit_set_cd%TYPE;
    --
    CURSOR c_susa IS
    SELECT us.unit_set_cd
    FROM   IGS_AS_SU_SETATMPT SUSA,
           IGS_EN_UNIT_SET US,
           IGS_EN_UNIT_SET_CAT USC
    WHERE  p_person_id = susa.person_id
    AND    p_course_cd = susa.course_cd
    AND    (igs_en_gen_015.get_effective_census_date(
           NULL, NULL, p_teach_cal_type, p_teach_ci_sequence_number)
           BETWEEN susa.selection_dt AND NVL(susa.rqrmnts_complete_dt,
           NVL(susa.end_dt, fnd_date.canonical_to_date('9999/12/31'))))
    AND    susa.unit_set_cd = us.unit_set_cd
    AND    us.unit_set_cat = usc.unit_set_cat
    AND    usc.s_unit_set_cat = 'PRENRL_YR'
    ORDER BY susa.selection_dt DESC;
    --
  BEGIN
    --
    OPEN  c_susa;
    FETCH c_susa INTO v_unit_set_cd;
    --
    IF c_susa%FOUND THEN
        CLOSE c_susa;
        RETURN v_unit_set_cd;
    ELSE
        CLOSE c_susa;
        RETURN NULL;
    END IF;
    --
  END get_sua_yop;
  --
  --
  --
  FUNCTION get_load_gpa
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
      RETURN load_table(1).load_gpa;
      --
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
      RETURN load_table(1).load_gpa;
      --
    END IF;
    --
  END get_load_gpa;
  --
  --
  --
  FUNCTION get_load_gpa_cp
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
      RETURN load_table(1).load_gpa_cp;
      --
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
      RETURN load_table(1).load_gpa_cp;
      --
    END IF;
    --
  END get_load_gpa_cp;
  --
  --
  --
  FUNCTION get_load_gpa_qp
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
      RETURN load_table(1).load_gpa_qp;
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
      RETURN load_table(1).load_gpa_qp;
      --
    END IF;
    --
  END get_load_gpa_qp;
  --
  --
  --
  FUNCTION get_load_earned_cp
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
      RETURN load_table(1).load_earned_cp;
      --
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
      RETURN load_table(1).load_earned_cp;
      --
    END IF;
    --
  END get_load_earned_cp;
  --
  --
  --
  FUNCTION get_load_attempted_cp
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
      RETURN load_table(1).load_attempted_cp;
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
      RETURN load_table(1).load_attempted_cp;
      --
    END IF;
    --
  END get_load_attempted_cp;
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
  --
END IGS_PR_ACAD_DETAILS;

/
