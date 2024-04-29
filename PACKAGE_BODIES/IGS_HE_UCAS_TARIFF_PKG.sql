--------------------------------------------------------
--  DDL for Package Body IGS_HE_UCAS_TARIFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_UCAS_TARIFF_PKG" AS
/* $Header: IGSHE20B.pls 120.10 2006/05/04 20:58:36 jchakrab noship $*/

  l_debug_level NUMBER:= fnd_log.g_current_runtime_level;
  l_proc_level  NUMBER:= fnd_log.level_unexpected;


  -----------------------------------------------------------------------------------
  -- ========================== EXTERNAL TARIFF CALCULATION =========================
  -----------------------------------------------------------------------------------
  PROCEDURE External_tariff_calc (
     errbuf              OUT NOCOPY VARCHAR2,
     retcode             OUT NOCOPY NUMBER,
     p_person_identifier IN  NUMBER,
     p_course_code       IN  VARCHAR2,
     p_start_date        IN  VARCHAR2,
     p_end_date          IN  VARCHAR2,
     p_tariff_calc_type  IN  VARCHAR2,
     p_calculate_tariff  IN  VARCHAR2,
     P_recalculate       IN  VARCHAR2,
     p_person_id_grp     IN  NUMBER,
     p_program_group     IN  VARCHAR2,
     p_program_type      IN  VARCHAR2,
     p_report_all_hierarchy_flag IN VARCHAR2
    ) IS

  /*------------------------------------------------------------------
  --Created by  : rgangara, Oracle IDC
  --Date created: 3-Aug-03
  --
  --Purpose: This is to calculate External UCAS tariff into HESA SPA table
  --Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- WHO        WHEN       WHAT
  -- smaddali  21-jan-04  Removed 2 cursors c_prgawd and c_spawd and added call
  --                      to get_gen_qual_aim, bug#3360646
  -- ayedubat  16-MAR-04  Added a new parameter, p_report_all_hierarchy_flag and
  --                      the logic based on this parameter for Bug, 2956444
  -- jbaber    29-NOV-04  Modified procedure, external_tariff_calc to exclude
  --                      students with no qualifications for Bug# 4035243
  -- anwest    24-Jan-05  Bug# 4035243 Variable declaration and logging altered
  --                      for unhandled exception noted in peer review
  -- jbaber    19-Jan-06  Included igs_he_st_spa_all.exclude flag for HE305
  -- jchin     27-Jan-06  Bug 3484372 output full grade name instead of grade val
  -- jchakrab  21-Feb-06  Modified for R12 performance enhs - replaced literal SQL with fnd_dsql
  -- anwest    24-Mar-06  Bug# 5121695 - Modified for impact from R12 SWS changes.
  --                      Replaced IGS_GET_DYNAMIC_SQL(p_pid_group,l_status) with
  --                      GET_DYNAMIC_SQL(p_person_id_grp, l_prs_grp_status, l_group_type)
  --                      and implemented new associated logic.
  -- jchakrab  04-May-06  Modified for 5203018 - closed cursor created using DBMS_SQL
  --------------------------------------------------------------------------*/

    -- get the person number for the person id
    CURSOR c_person_number (cp_person_id igs_pe_person.person_id%TYPE ) IS
    SELECT person_number
    FROM   igs_pe_person_base_v
    WHERE  person_id = cp_person_id ;
    l_person_number igs_pe_person.person_number%TYPE ;

    -- cursor to validate that the course is attached to the program group
    CURSOR prg_group_mem_cur (cp_course_cd igs_ps_grp_mbr.course_cd%TYPE,
                              cp_version   igs_ps_grp_mbr.version_number%TYPE) IS
    SELECT 'X'
    FROM   igs_ps_grp_mbr
    WHERE  course_cd        = cp_course_cd
    AND    version_number   = cp_version
    AND    course_group_cd  = p_program_group;

    -- get the HESA code for oss qualification aim
    CURSOR Cur_qual_aim (cp_student_qual_aim Igs_he_st_spa.Student_qual_aim%TYPE)  IS
    SELECT map1
    FROM  igs_he_code_map_val
    WHERE Association_code ='OSS_HESA_AWD_ASSOC'
    AND   Map2 = cp_Student_qual_aim ;

    -- get all the records for passed exam level of the student where year of qualification is null or
    -- less than spa commencement date
    -- smaddali added nvl to Year to get field ucas_tariff ,for bug 2415679
    -- smaddali modified this cursor for bug 2473397 ,
    -- inorder to calculate ucas_tariff on the fly added the join with igs_as_grd_sch_grade
    -- Modified the cursor to exclude excluded subjects and subjects that are excluded specifically for this award.
    -- Modified the cursor to add subject_code IS NULL for 3224610
    CURSOR Cur_qual_dets (cp_person_id           Igs_uc_qual_dets.person_id%TYPE,
                          cp_commencement_date   Igs_en_stdnt_ps_att.Commencement_dt%TYPE,
                          cp_exam_level          Igs_uc_qual_dets.Exam_level%TYPE,
                          cp_tariff_calc_type    Igs_he_ut_excl_qals.tariff_calc_type_cd%TYPE) IS
    SELECT uqd.Exam_level,
           uqd.Subject_code,
           MAX(grd.rank) ucas_tariff
    FROM   igs_uc_qual_dets uqd,
           igs_as_grd_sch_grade grd
    WHERE  uqd.Person_id         = cp_person_id
      AND  uqd.Exam_level        = cp_exam_level
      AND  grd.grade             = uqd.approved_result
      AND  grd.grading_schema_cd = uqd.grading_schema_cd
      AND  grd.version_number    = uqd.version_number
      AND ( uqd.Year IS NULL OR  uqd.Year  <= TO_CHAR (cp_commencement_date, 'YYYY'))
      AND ( subject_code IS NULL OR subject_code NOT IN (SELECT field_of_study
                                    FROM   igs_he_ut_excl_qals
                                    WHERE  tariff_calc_type_cd = cp_tariff_calc_type
                                    AND  (award_cd IS NULL OR award_cd = cp_exam_level)))
    GROUP BY Exam_level, Subject_code ;

    -- select the distinct exam levels for the passed person
    -- smaddali added nvl to Year for bug 2421505
    -- Added the subqueries as part of HE202_2 enh - Bug# 2717747.
    -- Subquery1 is to include only those exam level records which are setup for inclusion for the given calculation type.
    -- Subquery2 is to filter out exam levels records which are setup for exclusion (Only award without subject)
    -- Subquery3 is to filter out subject records which are setup for exclusion (Only subject without award)
    -- Subquery4 is to filter out Award + subject combination records which are setup for exclusion i.e.
    -- (both Award is not null and subject is not null in exclude qualifications table).
    -- Modified the cursor to add subject_code IS NULL for 3224610
    CURSOR Cur_exam_level (l_person_id igs_uc_qual_dets.person_id%TYPE,
                           l_commencement_date  Igs_en_stdnt_ps_att. Commencement_dt%TYPE,
                           cp_tariff_calc_type  igs_he_ut_lvl_award.tariff_calc_type_cd%TYPE) IS
        SELECT DISTINCT Exam_level
        FROM Igs_uc_qual_dets
        WHERE Person_id    = l_person_id
          AND exam_level     IN  (SELECT hula.award_cd
                                  FROM   igs_he_ut_lvl_award hula
                                  WHERE  hula.tariff_calc_type_cd = cp_tariff_calc_type
                                    AND  hula.closed_ind = 'N')
          AND exam_level NOT IN  (SELECT hueq.award_cd
                                  FROM   igs_he_ut_excl_qals hueq
                                  WHERE  hueq.tariff_calc_type_cd = cp_tariff_calc_type
                                    AND  hueq.field_of_study IS NULL)
          AND (subject_code IS NULL OR subject_code NOT IN  (SELECT field_of_study
                                        FROM   igs_he_ut_excl_qals
                                        WHERE  tariff_calc_type_cd = cp_tariff_calc_type
                                        AND  award_cd IS NULL))
          AND (exam_level, subject_code) NOT IN  (SELECT eqas.award_cd, eqas.field_of_study
                                                  FROM   igs_he_ut_excl_qals eqas
                                                  WHERE  eqas.tariff_calc_type_cd = cp_tariff_calc_type
                                                    AND  eqas.award_cd IS NOT NULL
                                                    AND  eqas.field_of_study IS NOT NULL)
          AND (Year IS NULL OR Year  <= TO_CHAR (l_commencement_date, 'YYYY') ) ;


    -- get the spa record to be updated for fields highest_qual_on_entry , date_qual_on_entry_calc,
    -- total_ucas_tariff
    CURSOR Cur_st_spa_for_update (l_person_id igs_he_st_spa.person_id%TYPE,
                                  l_course_cd igs_he_st_spa.course_cd%TYPE)  IS
        SELECT  ihss.row_id row_id,
                ihss.hesa_st_spa_id hesa_st_spa_id,
                ihss.course_cd       course_cd,
                ihss.version_number    version_number,
                ihss.person_id person_id,
                ihss.fe_student_marker   fe_student_marker,
                ihss.domicile_cd      domicile_cd,
                ihss.inst_last_attended  inst_last_attended,
                ihss.year_left_last_inst   year_left_last_inst,
                ihss.highest_qual_on_entry highest_qual_on_entry,
                ihss.date_qual_on_entry_calc   date_qual_on_entry_calc,
                ihss.a_level_point_score a_level_point_score,
                ihss.highers_points_scores   highers_points_scores,
                ihss.occupation_code  occupation_code,
                ihss.commencement_dt  commencement_dt,
                ihss.special_student    special_student,
                ihss.student_qual_aim    student_qual_aim,
                ihss.student_fe_qual_aim   student_fe_qual_aim,
                ihss.teacher_train_prog_id    teacher_train_prog_id,
                ihss.itt_phase       itt_phase,
                ihss.bilingual_itt_marker bilingual_itt_marker,
                ihss.teaching_qual_gain_sector teaching_qual_gain_sector,
                ihss.teaching_qual_gain_subj1  teaching_qual_gain_subj1,
                ihss.teaching_qual_gain_subj2 teaching_qual_gain_subj2,
                ihss.teaching_qual_gain_subj3  teaching_qual_gain_subj3,
                ihss.student_inst_number    student_inst_number,
                ihss.hesa_return_name     hesa_return_name,
                ihss.hesa_return_id    hesa_return_id,
                ihss.hesa_submission_name  hesa_submission_name,
                ihss.associate_ucas_number associate_ucas_number,
                ihss.associate_scott_cand  associate_scott_cand,
                ihss.associate_teach_ref_num  associate_teach_ref_num,
                ihss.associate_nhs_reg_num  associate_nhs_reg_num,
                ihss.itt_prog_outcome           itt_prog_outcome,
                ihss.nhs_funding_source nhs_funding_source,
                ihss.ufi_place        ufi_place,
                ihss.postcode        postcode,
                ihss.social_class_ind   social_class_ind,
                ihss.destination     destination,
                ihss.occcode     occcode,
                ihss.total_ucas_tariff   total_ucas_tariff,
                ihss.nhs_employer  nhs_employer,
                ihss.return_type,
                ihss.qual_aim_subj1,
                ihss.qual_aim_subj2,
                ihss.qual_aim_subj3,
                ihss.qual_aim_proportion,
                ihss.dependants_cd,
                ihss.implied_fund_rate,
                ihss.gov_initiatives_cd,
                ihss.units_for_qual,
                ihss.disadv_uplift_elig_cd,
                ihss.franch_partner_cd,
                ihss.units_completed,
                ihss.franch_out_arr_cd,
                ihss.employer_role_cd,
                ihss.disadv_uplift_factor,
                ihss.enh_fund_elig_cd,
                ihss.exclude_flag
        FROM   igs_he_st_spa ihss
        WHERE  ihss.person_id  = l_person_id
        AND    ihss.course_cd  = l_course_cd;

    -- get the rowid for Student attempt
    CURSOR Cur_st_spa_ut (l_person_id igs_he_st_spa.person_id%TYPE,
                          l_course_cd igs_he_st_spa.course_cd%TYPE ) IS
    SELECT  rowid
    FROM  Igs_he_st_spa_ut
    WHERE Person_id = l_person_id
    AND   course_cd = l_course_cd;

    --get the Highest qualification on entry as the highest ranked qualification
    --smaddali modified cursor to select only open code_values from igs_he_code_values ,bug 2730388
    --Correct the comparision done in this cursor to compare Iagsta.grading_schema_cd with the Iuqd.grading_schema_cd
    --Not with the Exam Level as mentioned in bug 2782618
    CURSOR Cur_highest_grade (l_person_id igs_he_st_spa.person_id%TYPE ,
                              p_commencement_dt igs_he_st_spa.commencement_dt%TYPE)  IS
        SELECT   Iagsta.grade,
                 Iagsta.To_grading_schema_cd,
                 Iagsta.to_version_number,
                 Iagsta.to_grade,
                 Iagsgv.full_grade_name,  -- jchin 3484372 Added full grade name to output to log file
                 Iagsgv.rank
        FROM     Igs_uc_qual_dets        Iuqd,
                 Igs_as_grd_sch_trn_all  Iagsta,
                 Igs_as_grd_sch_grade_v  Iagsgv,
                 Igs_as_grd_sch_grade grd
        WHERE    Iuqd.person_id =  l_person_id
        AND      Iagsta.grading_schema_cd =  Iuqd.grading_schema_cd
        AND      Iagsta.version_number  = Iuqd.version_number
        AND      grd.grading_schema_cd  = iuqd.grading_schema_cd
        AND      grd.version_number  = Iuqd.version_number
        AND      ( iuqd.approved_result IS NULL
                   OR
                   (grd.grade = iuqd.approved_result  AND grd.s_result_type = 'PASS' )
                 )
        AND      Iagsgv.grading_schema_cd =  Iagsta.to_grading_schema_cd
        AND      Iagsgv.version_number  =  Iagsta.to_version_number
        AND      Iagsgv.grade   =  Iagsta.to_grade
        AND      (Iuqd.Year IS NULL OR Iuqd.Year <= TO_CHAR(p_commencement_dt,'YYYY'))
        AND      EXISTS (SELECT  'X'
                         FROM  Igs_he_code_values
                         WHERE Code_type = 'HESA_HIGH_QUAL_ON_ENT'
                         AND   Value = Iagsta.to_grading_schema_cd
                         AND   NVL(closed_ind,'N') = 'N' )
       ORDER BY Iagsgv.rank  ASC ;

    -- Returns the other awards with the same subject for the current person, exam level, subject being processed.
    -- modified the cursor to include and exclude exam levels that are setup for the calculation type.
    CURSOR cur_check_dup_awards (cp_person_id  igs_uc_qual_dets.person_id%TYPE,
                                 cp_exam_level igs_uc_qual_dets.exam_level%TYPE,
                                 cp_subject_cd igs_uc_qual_dets.subject_code%TYPE,
                                 cp_commencement_date igs_en_stdnt_ps_att.commencement_dt%TYPE,
                                 cp_tariff_calc_type  igs_he_ut_lvl_award.tariff_calc_type_cd%TYPE) IS
       SELECT DISTINCT exam_level
       FROM  igs_uc_qual_dets
       WHERE person_id = cp_person_id
       AND   exam_level <> cp_exam_level
       AND   subject_code = cp_subject_cd
       AND   exam_level     IN (SELECT hula.award_cd
                                FROM   igs_he_ut_lvl_award hula
                                WHERE  hula.tariff_calc_type_cd = cp_tariff_calc_type
                                  AND  hula.closed_ind = 'N')
       AND   exam_level NOT IN (SELECT hueq.award_cd
                                FROM   igs_he_ut_excl_qals hueq
                                WHERE  hueq.tariff_calc_type_cd = cp_tariff_calc_type
                                  AND  hueq.field_of_study IS NULL)
       AND   (year IS NULL OR  Year <= TO_CHAR(cp_commencement_date, 'YYYY'));

    -- For checking whether parent award exists for the passed in award.
    CURSOR cur_check_parent (cp_award_cd igs_he_ut_prt_award.award_cd%TYPE,
                             cp_tariff_calc_type igs_he_ut_prt_award.tariff_calc_type_cd%TYPE) IS
    SELECT parent_award_cd
    FROM (SELECT *
          FROM igs_he_ut_prt_award
          WHERE tariff_calc_type_cd = cp_tariff_calc_type)
    START WITH award_cd = cp_award_cd
    CONNECT BY PRIOR parent_award_cd = award_cd
    AND tariff_calc_type_cd = cp_tariff_calc_type;

    -- anwest Bug#4035243 The original declaration:
    --                    l_tariff_score igs_uc_qual_dets.ucas_tariff%TYPE := 0;
    --                    was causing an Unhandled Exception when value > 999
    --                    because igs_uc_qual_dets.ucas_tariff%TYPE is defined as
    --                    NUMBER(3)
    l_tariff_score       igs_he_st_spa_ut_all.tariff_score%TYPE := 0;
    l_qual_count         Igs_he_st_spa_ut_all.Number_of_qual%TYPE := 0;
    l_total_tariff_score Igs_he_st_spa_all.total_ucas_tariff%TYPE  := 0;
    l_last_update_date   Igs_uc_qual_dets.Last_update_date%TYPE ;
    l_record_inserted    NUMBER := 0;
    l_record_updated     NUMBER := 0;
    l_hesa_st_spau_id    Igs_he_st_spa_ut_all.hesa_st_spau_id%TYPE := 0;
    l_Qual_aim           igs_he_code_map_val.map1%TYPE ;
    l_rowid              VARCHAR2(26) ;
    C_st_spa_for_update  cur_st_spa_for_update%ROWTYPE;
    l_grade              cur_highest_grade%ROWTYPE;
    l_parent_awd_found   BOOLEAN;
    l_recs_for_insert    NUMBER; -- to bypass inserting into SPA_UT table if no qual recs found
    l_prog_grp_exists    VARCHAR2(1); -- to hold that program group and course combination is valid.
    l_calc_tariff_flag   VARCHAR2(1); -- to indicate whether processing should happen based on program group filtering
    l_tariff_exists      VARCHAR2(1); -- to hold that existing tariff records exist.
    l_Int_calc_sql       VARCHAR2(32767);
    l_prs_grp_sql        VARCHAR2(32767);
    l_prs_grp_status     VARCHAR2(10);
    l_recs_processed     NUMBER := 0;
    l_start_date         DATE;
    l_end_date           DATE;

    --jchakrab added for R12 Performance Enhs (4950293)
    l_num_rows           NUMBER;
    l_cursor_id          NUMBER;

    -- anwest added for Bug #5121695
    l_group_type         VARCHAR2(10);

    TYPE st_spa_rec is record (
      student_qual_aim         igs_he_st_spa.student_qual_aim%TYPE
      ,commencement_dt         igs_en_stdnt_ps_att.commencement_dt%TYPE
      ,date_qual_on_entry_calc igs_he_st_spa.date_qual_on_entry_calc%TYPE
      ,person_id               igs_he_st_spa.person_id%TYPE
      ,course_cd               igs_he_st_spa.course_cd%TYPE
      ,version_number          igs_he_st_spa.version_number%TYPE);

    c_st_spa st_spa_rec;

  BEGIN

    -- get date values from varchar
    IF p_start_date IS NOT NULL THEN
       l_start_date := TO_DATE(SUBSTR(p_start_date,1,11),'YYYY/MM/DD');
    END IF;

    IF p_end_date IS NOT NULL THEN
       l_end_date := TO_DATE(SUBSTR(p_end_date,1,11),'YYYY/MM/DD');
    END IF;

    --initialize fnd_dsql data-structures
    fnd_dsql.init;

    -- basic SQL statement for selecting records to be processed
    -- modified for bug 4035243
    fnd_dsql.add_text('SELECT ihss.student_qual_aim , iespa.commencement_dt, ihss.date_qual_on_entry_calc,');
    fnd_dsql.add_text('ihss.person_id, ihss.course_cd, ihss.version_number ');
    fnd_dsql.add_text('FROM   igs_he_st_spa ihss, igs_en_stdnt_ps_att iespa ');
    fnd_dsql.add_text('WHERE  ihss.person_id  = iespa.person_id AND    ihss.course_cd = iespa.course_cd ');
    fnd_dsql.add_text('AND hesa_return_id IS NULL  AND hesa_submission_name IS NULL AND hesa_return_name IS NULL ');
    fnd_dsql.add_text('AND EXISTS (SELECT person_id from igs_uc_qual_dets where person_id = ihss.person_id) ');

    -- if person id is not null append the following filtering criteria
    IF p_person_identifier IS NOT NULL THEN
      fnd_dsql.add_text(' AND ihss.person_id = ');
      fnd_dsql.add_bind(p_person_identifier);
    END IF;

    -- if Course is not null append the following filtering criteria
    IF p_course_code IS NOT NULL THEN
      fnd_dsql.add_text(' AND ihss.course_cd = ');
      fnd_dsql.add_bind(p_course_code);
    END IF;

    -- if Program Type is not null append the following filtering criteria
    IF p_program_type IS NOT NULL THEN
      fnd_dsql.add_text(' AND (ihss.course_cd, ihss.version_number) IN ');
      fnd_dsql.add_text(' (SELECT psv.course_cd, psv.version_number FROM igs_ps_ver psv WHERE psv.course_type = ');
      fnd_dsql.add_bind(p_program_type);
      fnd_dsql.add_text(')');
    END IF;

    -- if End date is not null append the following filtering criteria
    IF l_end_date IS NOT NULL THEN
      fnd_dsql.add_text(' AND (iespa.commencement_dt IS NULL OR iespa.commencement_dt <= ');
      fnd_dsql.add_bind(l_end_date);
      fnd_dsql.add_text(')');
    END IF;

    -- if start date is not null append the following filtering criteria
    IF l_start_date IS NOT NULL THEN
      fnd_dsql.add_text(' AND (iespa.discontinued_dt IS NULL OR iespa.discontinued_dt  >= ');
      fnd_dsql.add_bind(l_start_date);
      fnd_dsql.add_text(')');
      fnd_dsql.add_text(' AND (iespa.course_rqrmnts_complete_dt IS NULL OR iespa.course_rqrmnts_complete_dt >= ');
      fnd_dsql.add_bind(l_start_date);
      fnd_dsql.add_text(')');
    END IF;

    -- Person ID Group filtering. If person ID group is not NULL then append the sql returned to the above sql stmnt.
    -- ANWEST Bug #5121695 Changed IGS_GET_DYNAMIC_SQL(p_pid_group,l_status) to
    --                     GET_DYNAMIC_SQL(p_person_id_grp, l_prs_grp_status, l_group_type)
    --                     and implemented new associated logic.

    IF p_person_id_grp IS NOT NULL THEN

      l_prs_grp_sql := IGS_PE_DYNAMIC_PERSID_GROUP.GET_DYNAMIC_SQL(p_person_id_grp, l_prs_grp_status, l_group_type);

      IF l_prs_grp_status <> 'S' THEN
        fnd_message.set_name('IGS','IGS_HE_UT_PRSN_ID_GRP_ERR');
        fnd_message.set_token('PRSNIDGRP',p_person_id_grp);
        errbuf := fnd_message.get();
        fnd_file.put_line(fnd_file.log, errbuf);  -- as this info is also important to end user.
        retcode := '2';
        RETURN;
      END IF;

      IF l_group_type = 'STATIC' THEN
        l_prs_grp_sql := SUBSTR(l_prs_grp_sql, 1, INSTR(UPPER(l_prs_grp_sql), ':P_GROUPID') - 1);
      END IF;

      -- concatenate the incoming sql stmt to the basic sql to get the complete SQL stmt
      fnd_dsql.add_text(' AND ihss.person_id IN (');
      fnd_dsql.add_text(l_prs_grp_sql);
      IF l_group_type = 'STATIC' THEN
        fnd_dsql.add_bind(p_person_id_grp);
      END IF;
      fnd_dsql.add_text(')');
      l_prs_grp_sql  := NULL; -- initializing to NULL as this variable no more required for processing.

    END IF;

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    fnd_dsql.set_cursor(l_cursor_id);

    l_Int_calc_sql := fnd_dsql.get_text(FALSE);
    DBMS_SQL.PARSE(l_cursor_id, l_Int_calc_sql, DBMS_SQL.NATIVE);
    fnd_dsql.do_binds;

    DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1,c_st_spa.student_qual_aim,30);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 2,c_st_spa.commencement_dt);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 3,c_st_spa.date_qual_on_entry_calc);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 4,c_st_spa.person_id);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 5,c_st_spa.course_cd,6);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 6,c_st_spa.version_number);

    l_num_rows := DBMS_SQL.EXECUTE(l_cursor_id);

    -- If no student program attempt  records exist for which to calculate UCAS Tariff then log error message
    LOOP

      c_st_spa  := NULL;         -- initialize record variable
      l_recs_processed := 1;     -- to indicate that atleast one record is processed.
      l_calc_tariff_flag := 'Y';
      l_person_number := NULL ;

      -- fetch a row
      IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
          EXIT;
      END IF;

      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1,c_st_spa.student_qual_aim);
      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 2,c_st_spa.commencement_dt);
      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 3,c_st_spa.date_qual_on_entry_calc);
      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 4,c_st_spa.person_id);
      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 5,c_st_spa.course_cd);
      DBMS_SQL.COLUMN_VALUE(l_cursor_id, 6,c_st_spa.version_number);

      -- get the Person Number for the person for logging
      OPEN c_person_number(C_st_spa.person_id) ;
      FETCH c_person_number  INTO l_person_number ;
      CLOSE c_person_number ;

      -- Program Group Filtering if program group is entered
      IF p_program_group IS NOT NULL THEN

        -- Since the program group is entered, check that the record being processed is valid for the program group
        -- Process the record only if the course is attached to the entered group.
        OPEN prg_group_mem_cur (C_st_spa.course_cd, C_st_spa.version_number);
        FETCH prg_group_mem_cur INTO l_prog_grp_exists;

        -- if found then process else skip this record
        IF prg_group_mem_cur%FOUND THEN
           l_calc_tariff_flag := 'Y';
        ELSE
           l_calc_tariff_flag := 'N';
        END IF;
        CLOSE prg_group_mem_cur;

      END IF;

      -- Tariff is calculated for existing (already calculated earlier) tariff records only if
      -- the Recalculate parameter is YES. Else existing tariff records are not modified and
      -- tariff calculation is to be bypassed.
      IF (p_recalculate = 'N' AND l_calc_tariff_flag = 'Y' AND c_st_spa.Date_qual_on_entry_calc IS NOT NULL) THEN

        -- set the flag so that no further processing is required for the record
        l_calc_tariff_flag := 'N';

        fnd_message.set_name('IGS','IGS_HE_UT_EXT_NOT_RECALC');
        fnd_message.set_token('PERSON',  l_person_number);
        fnd_message.set_token('PROGRAM', c_st_spa.course_cd);
        fnd_file.put_line(fnd_file.log, fnd_message.get());

      END IF;

      -- Further processing is done only if the flag is set to Y
      IF l_calc_tariff_flag = 'Y' THEN

          l_qual_aim := NULL ;         /* Initializing the counter */ -- added by smaddali for bug 2353094
          l_total_tariff_score := 0;   /* To hold the UCAS tariff grand total for an applicant. */

          -- get the hesa value of general qualification aim for the student program attempt
          -- smaddali 21-jan-04 for bug#3360646, calling field derivation instead of deriving value again
          igs_he_extract_fields_pkg.get_gen_qual_aim
              (p_person_id           =>  c_st_spa.person_id,
               p_course_cd           =>  c_st_spa.course_cd,
               p_version_number      =>  c_st_spa.version_number,
               p_spa_gen_qaim        =>  c_st_spa.student_qual_aim,
               p_hesa_gen_qaim       =>  l_Qual_aim ,
               p_enrl_start_dt       =>  c_st_spa.commencement_dt,
               p_enrl_end_dt         =>  NULL,
               p_awd_conf_start_dt   =>  NULL);

          -- smaddali seperated this condition so that it apples only for UCAS tariff and not for calculating Highest qualification
          --  for bug # 2394366
          -- UCAS tariff is calculated only for qualification aim between 19-52 or 61 or 97

          -- Before calculating the ucas scoress, Delete the all ucas tariff scores for the student attempt
          FOR Cur_st_spa_ut_rec IN Cur_st_spa_ut(c_st_spa.person_id, c_st_spa.course_cd)  LOOP
             Igs_he_st_spa_ut_all_pkg.delete_row(x_rowid => Cur_st_spa_ut_rec.rowid );
          END LOOP;

          IF ((l_qual_aim BETWEEN 18 AND 52) OR (l_qual_aim = 61 OR l_qual_aim = 97)) THEN

            /* This loop will have the list of exam level for an applicant */
            FOR C_exam_level IN Cur_exam_level (c_st_spa.person_id, c_st_spa.commencement_dt, p_tariff_calc_type)
            LOOP

              /* Initializing the counter */
              l_tariff_score := 0;     /* To hold the UCAS Tariff for each Exam level of an applicant. */
              l_qual_count := 0;       /* To hold the count of subjects under each exam level. */

              l_recs_for_insert := 0; -- initialize to zero
              FOR C_qual_dets IN Cur_qual_dets (c_st_spa.person_id,
                                    c_st_spa.commencement_dt,
                                    c_exam_level.exam_level,
                                    p_tariff_calc_type)   LOOP

                -- increment the count. This indicates that cur_qual_dets cursor returns atleast
                -- one record for processing.
                l_recs_for_insert := l_recs_for_insert + 1;

                -- Added Logic for Filtering to prevent double counting as part of HEFD202.1 Build  Bug 2717744.
                l_parent_awd_found := FALSE;
                FOR dup_award_rec IN cur_check_dup_awards(c_st_spa.person_id,
                                            c_qual_dets.exam_level,
                                            c_qual_dets.subject_code,
                                            c_st_spa.commencement_dt,
                                            p_tariff_calc_type)  LOOP

                    FOR parent_awd_rec IN cur_check_parent(c_qual_dets.exam_level, p_tariff_calc_type)
                    LOOP
                       IF parent_awd_rec.parent_award_cd = dup_award_rec.exam_level THEN
                        l_parent_awd_found := TRUE;
                        EXIT;
                       END IF;
                    END LOOP;

                    EXIT WHEN l_parent_awd_found = TRUE;

                END LOOP;

                IF l_parent_awd_found = FALSE THEN

                  -- This will get the total of UCAS Tariff and the number of subjects for an Exam level
                  l_qual_count := l_qual_count + 1;
                  l_tariff_score := l_tariff_score + NVL(c_qual_dets.ucas_tariff,0);

                  /* Getting the total of UCAS Tariff for a person Grand total of UCAS Tariff for an applicant*/
                  l_total_tariff_score:= l_total_tariff_score + NVL(c_qual_dets.ucas_tariff,0);

                ELSIF ( p_report_all_hierarchy_flag = 'Y' ) THEN

                  -- If Qualification has a parent award in the same subject ( Double counting scenario) and
                  -- Report all awards in tariff breakdown is checked then report the Tariff only at Exam Level,
                  -- but should not be reported in the Grand Total Tariff for an applicant
                  -- This logic is added as part of HE311FD - JUly 2004 Enhancement Bug, 2956444
                  l_tariff_score :=  l_tariff_score + NVL(c_qual_dets.ucas_tariff,0);
                  l_qual_count :=  l_qual_count + 1;

                END IF;

              END LOOP;

              IF l_recs_for_insert > 0 THEN

                -- Insert the Tariff scores for each Exam level of an applicant and
                --  the number of subject of each Exam level

                Igs_he_st_spa_ut_all_pkg.Insert_row (
                  x_mode                  => 'R',
                  x_rowid                 => l_rowid,
                  x_hesa_st_spau_id       => l_hesa_st_spau_id,
                  x_Person_id             => c_st_spa.person_id,
                  x_Course_cd             => c_st_spa.course_cd,
                  x_Version_number        => c_st_spa.version_number,
                  x_Qualification_level   => c_exam_level.exam_level,
                  x_Number_of_qual        => l_qual_count,
                  x_tariff_score          => l_tariff_score,
                  x_org_id                => igs_ge_gen_003.get_org_id );

                l_record_inserted := l_record_inserted + 1 ;

                Fnd_Message.Set_Name('IGS','IGS_HE_EXAM_LEVEL_TARIFF');
                Fnd_Message.Set_Token('PERSON_NUMBER',l_person_number);
                Fnd_Message.Set_Token('COURSE_CODE',c_st_spa.course_cd);
                Fnd_Message.Set_Token('EXAM_LEVEL',c_exam_level.Exam_level);
                Fnd_Message.Set_Token('SUBJECT_COUNT',l_qual_count);
                Fnd_Message.Set_Token('TARIFF_SCORE',l_tariff_score);
                fnd_file.put_line(fnd_file.log, fnd_message.get());

              END IF;

            END LOOP;  --end for Cur_exam_level

          END IF ; -- if qualification aim in the set of values


          /* picking up records to update the spa table */
          OPEN Cur_st_spa_for_update (c_st_spa.person_id, c_st_spa.course_cd);
          FETCH Cur_st_spa_for_update INTO c_st_spa_for_update;
          CLOSE Cur_st_spa_for_update;

          /* Getting the highest grade for the applicant to update the spa table */
          l_grade := NULL ; --added by smaddali for bug2353094

          OPEN Cur_highest_grade (C_ST_SPA.person_id, c_st_spa.commencement_dt);
          FETCH Cur_highest_grade  INTO l_grade ;
          CLOSE Cur_highest_grade;

          Igs_he_st_spa_all_pkg.Update_row (
            x_mode                       =>   'R',
            x_rowid                      =>   c_st_spa_for_update.row_id,
            x_hesa_st_spa_id             =>   c_st_spa_for_update.hesa_st_spa_id,
            x_course_cd                  =>   c_st_spa_for_update.course_cd,
            x_version_number             =>   c_st_spa_for_update.version_number,
            x_person_id                  =>   c_st_spa_for_update.person_id,
            x_fe_student_marker          =>   c_st_spa_for_update.fe_student_marker,
            x_domicile_cd                =>   c_st_spa_for_update.domicile_cd,
            x_inst_last_attended         =>   c_st_spa_for_update.inst_last_attended,
            x_year_left_last_inst        =>   c_st_spa_for_update.year_left_last_inst,
            x_highest_qual_on_entry      =>   l_grade.to_grade,
            x_date_qual_on_entry_calc    =>   SYSDATE,
            x_a_level_point_score        =>   c_st_spa_for_update.a_level_point_score,
            x_highers_points_scores      =>   c_st_spa_for_update.highers_points_scores,
            x_occupation_code            =>   c_st_spa_for_update.occupation_code,
            x_commencement_dt            =>   c_st_spa_for_update.commencement_dt,
            x_special_student            =>   c_st_spa_for_update.special_student,
            x_student_qual_aim           =>   c_st_spa_for_update.student_qual_aim,
            x_student_fe_qual_aim        =>   c_st_spa_for_update.student_fe_qual_aim,
            x_teacher_train_prog_id      =>   c_st_spa_for_update.teacher_train_prog_id,
            x_itt_phase                  =>   c_st_spa_for_update.itt_phase,
            x_bilingual_itt_marker       =>   c_st_spa_for_update.bilingual_itt_marker,
            x_teaching_qual_gain_sector  =>   c_st_spa_for_update.teaching_qual_gain_sector,
            x_teaching_qual_gain_subj1   =>   c_st_spa_for_update.teaching_qual_gain_subj1,
            x_teaching_qual_gain_subj2   =>   c_st_spa_for_update.teaching_qual_gain_subj2,
            x_teaching_qual_gain_subj3   =>   c_st_spa_for_update.teaching_qual_gain_subj3,
            x_student_inst_number        =>   c_st_spa_for_update.student_inst_number,
            x_hesa_return_name           =>   c_st_spa_for_update.hesa_return_name,
            x_hesa_return_id             =>   c_st_spa_for_update.hesa_return_id,
            x_hesa_submission_name       =>   c_st_spa_for_update.hesa_submission_name,
            x_associate_ucas_number      =>   c_st_spa_for_update.associate_ucas_number,
            x_associate_scott_cand       =>   c_st_spa_for_update.associate_scott_cand,
            x_associate_teach_ref_num    =>   c_st_spa_for_update.associate_teach_ref_num,
            x_associate_nhs_reg_num      =>   c_st_spa_for_update.associate_nhs_reg_num,
            x_itt_prog_outcome           =>   c_st_spa_for_update.itt_prog_outcome,
            x_nhs_funding_source         =>   c_st_spa_for_update.nhs_funding_source,
            x_ufi_place                  =>   c_st_spa_for_update.ufi_place,
            x_postcode                   =>   c_st_spa_for_update.postcode,
            x_social_class_ind           =>   c_st_spa_for_update.social_class_ind,
            x_destination                =>   c_st_spa_for_update.destination,
            x_occcode                    =>   c_st_spa_for_update.occcode,
            x_total_ucas_tariff          =>   l_total_tariff_score,
            x_nhs_employer               =>   c_st_spa_for_update.nhs_employer,
            x_return_type                =>   c_st_spa_for_update.return_type,
            x_qual_aim_subj1             =>   c_st_spa_for_update.qual_aim_subj1,
            x_qual_aim_subj2             =>   c_st_spa_for_update.qual_aim_subj2,
            x_qual_aim_subj3             =>   c_st_spa_for_update.qual_aim_subj3,
            x_qual_aim_proportion        =>   c_st_spa_for_update.qual_aim_proportion ,
            x_org_id                     =>   igs_ge_gen_003.get_org_id,
            x_dependants_cd              =>   c_st_spa_for_update.dependants_cd ,
            x_implied_fund_rate          =>   c_st_spa_for_update.implied_fund_rate ,
            x_gov_initiatives_cd         =>   c_st_spa_for_update.gov_initiatives_cd ,
            x_units_for_qual             =>   c_st_spa_for_update.units_for_qual ,
            x_disadv_uplift_elig_cd      =>   c_st_spa_for_update.disadv_uplift_elig_cd ,
            x_franch_partner_cd          =>   c_st_spa_for_update.franch_partner_cd ,
            x_units_completed            =>   c_st_spa_for_update.units_completed ,
            x_franch_out_arr_cd          =>   c_st_spa_for_update.franch_out_arr_cd ,
            x_employer_role_cd           =>   c_st_spa_for_update.employer_role_cd ,
            x_disadv_uplift_factor       =>   c_st_spa_for_update.disadv_uplift_factor ,
            x_enh_fund_elig_cd           =>   c_st_spa_for_update.enh_fund_elig_cd,
            x_exclude_flag               =>   c_st_spa_for_update.exclude_flag);

          fnd_message.set_name('IGS','IGS_HE_TOTAL_TARIFF');
          fnd_message.set_token('PERSON_NUMBER',l_person_number);
          fnd_message.set_token('COURSE_CODE',c_st_spa.course_cd);
          IF l_grade.to_grade IS NULL THEN      -- jchin added 3484372
            fnd_message.set_token('HIGH_QUAL', 'NULL');
          ELSE
            fnd_message.set_token('HIGH_QUAL', l_grade.full_grade_name);
          END IF;
          fnd_message.set_token('TOTAL_TARIFF',l_total_tariff_score);
          fnd_file.put_line(fnd_file.log, fnd_message.get());

          l_record_updated := l_record_updated + 1 ;

          COMMIT;

      END IF;  -- bypass processing if Program group is given and Course is not associated to the group

    END LOOP;  -- Loop of Cursor Cur_st_spa

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

    fnd_message.set_name('IGS','IGS_UC_UPD_REC_COUNT');
    fnd_message.set_token('REC_CNT',l_record_updated);
    fnd_file.put_line(fnd_file.log, fnd_message.get());

    fnd_message.set_name('IGS','IGS_UC_INS_REC_COUNT');
    fnd_message.set_token('REC_CNT',l_record_inserted);
    fnd_file.put_line(fnd_file.log, fnd_message.get());

  EXCEPTION
    WHEN OTHERS THEN
      IF l_cursor_id IS NOT NULL THEN
        DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
      END IF;

      ROLLBACK;
      IF  SQLCODE=-1436 THEN
        fnd_message.set_name('IGS','IGS_HE_UT_AWD_CYCLIC_REL');
        fnd_message.set_token('AWARD',NULL);
        -- anwest Bug# 4035243 Peer review noted no actual logging
        fnd_file.put_line(fnd_file.log, fnd_message.get());
      ELSE
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_HE_UCAS_TARIFF_PKG.External_tariff_calc - '||SQLERRM);
        -- anwest Bug# 4035243 Peer review noted no actual logging
        fnd_file.put_line(fnd_file.log, fnd_message.get());
      END IF;

      IF ( fnd_log.level_unexpected >= l_debug_level ) THEN
        fnd_log.message(fnd_log.level_unexpected, 'igs.plsql.hesa.ucas_tariff_calc.exception', FALSE);
      END IF;

      fnd_message.retrieve (Errbuf);
      Retcode := 2 ;
      RETURN;

  END External_tariff_calc;
  ----------------------------------------------------------------------------------------------------
  --            ============ END OF EXTERNAL TARIFF CALCULATION ===========
  ----------------------------------------------------------------------------------------------------


  ----------------------------------------------------------------------------------------------------
  --             ============ BEGIN OF INTERNAL TARIFF CALCULATION ==============
  ----------------------------------------------------------------------------------------------------
  PROCEDURE Internal_tariff_calc (
     errbuf              OUT NOCOPY VARCHAR2,
     retcode             OUT NOCOPY NUMBER,
     p_person_identifier IN  NUMBER,
     p_tariff_calc_type  IN  VARCHAR2,
     p_calculate_tariff  IN  VARCHAR2,
     P_recalculate       IN  VARCHAR2,
     p_person_id_grp     IN  NUMBER,
     p_report_all_hierarchy_flag IN VARCHAR2
    ) IS

  /*------------------------------------------------------------------
  --Created by  : rgangara, Oracle IDC
  --Date created: 30-Aug-03
  --
  --Purpose: This is to calculate Internal UCAS tariff into Person Summary and
  --         person details table
  --Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  WHO        WHEN       WHAT
  ayedubat  16-MAR-04  Added a new parameter, p_report_all_hierarchy_flag and
                       the logic based on this parameter for Bug, 2956444
  jchin     27-Jan-06  Bug 3678414 - Output total tariff score to log
  jchakrab  21-Feb-06  Modified for R12 Performance Enhs (4950293) - removed literal SQL
  anwest    24-Mar-06  Bug# 5121695 - Modified for impact from R12 SWS changes.
                       Replaced IGS_GET_DYNAMIC_SQL(p_pid_group,l_status) with
                       GET_DYNAMIC_SQL(p_person_id_grp, l_prs_grp_status, l_group_type)
                       and implemented new associated logic.
  jchakrab  04-May-06  Modified for 5203018 - closed cursor created using DBMS_SQL
  --------------------------------------------------------------------------*/

    -- Cursor to get only valid exam level records for a person to be processed for tariff calculation.
    -- Subquery1 is to include only those exam level records which are setup for inclusion for the given calculation type.
    -- Subquery2 is to filter out exam levels records which are setup for exclusion (Only award without subject)
    -- Subquery3 is to filter out subject records which are setup for exclusion (Only subject without award)
    -- Subquery4 is to filter out Award + subject combination records which are setup for exclusion i.e.
    -- (both Award is not null and subject is not null in exclude qualifications table).
    -- Modified the cursor to add subject_code IS NULL for 3224610
    CURSOR prsn_exam_level_cur (cp_person_id igs_uc_qual_dets.person_id%TYPE,
                               cp_tariff_calc_type igs_he_ut_lvl_award.tariff_calc_type_cd%TYPE)
    IS
     SELECT DISTINCT exam_level
     FROM   igs_uc_qual_dets
     WHERE  person_id = cp_person_id
       AND  exam_level     IN  (SELECT hula.award_cd
                                FROM   igs_he_ut_lvl_award hula
                                WHERE  hula.tariff_calc_type_cd = cp_tariff_calc_type
                                  AND  hula.closed_ind = 'N')
       AND  exam_level NOT IN  (SELECT hueq.award_cd
                                FROM   igs_he_ut_excl_qals hueq
                                WHERE  hueq.tariff_calc_type_cd = cp_tariff_calc_type
                                  AND  hueq.field_of_study IS NULL)
       AND  (subject_code IS NULL OR subject_code NOT IN (SELECT field_of_study
                                     FROM   igs_he_ut_excl_qals
                                     WHERE  tariff_calc_type_cd = cp_tariff_calc_type
                                     AND  award_cd IS NULL))
       AND  (exam_level, subject_code) NOT IN  (SELECT eqas.award_cd, eqas.field_of_study
                                                FROM   igs_he_ut_excl_qals eqas
                                                WHERE  eqas.tariff_calc_type_cd = cp_tariff_calc_type
                                                  AND  eqas.award_cd IS NOT NULL
                                                  AND  eqas.field_of_study IS NOT NULL);


    -- get all the valid subject records as per setup for passed exam level of the student and person.
    -- igs_as_grd_sch_grade is joined as UCAS Tariff is obtained/derived on the fly.
    -- The subquery is used to exclude excluded subjects and subjects that are excluded specifically for this award.
    -- Modified the cursor to add subject_code IS NULL for 3224610
    CURSOR get_tariff_cur (cp_person_id        Igs_uc_qual_dets.person_id%TYPE,
                           cp_exam_level       Igs_uc_qual_dets.Exam_level%TYPE,
                           cp_tariff_calc_type Igs_he_ut_excl_qals.tariff_calc_type_cd%TYPE) IS
    SELECT uqd.Exam_level,
           uqd.Subject_code,
           MAX(grd.rank) ucas_tariff
    FROM   igs_uc_qual_dets uqd,
           igs_as_grd_sch_grade grd
    WHERE  uqd.Person_id         = cp_person_id
      AND  uqd.Exam_level        = cp_exam_level
      AND  grd.grade             = uqd.approved_result
      AND  grd.grading_schema_cd = uqd.grading_schema_cd
      AND  grd.version_number    = uqd.version_number
      AND  (subject_code IS NULL OR subject_code NOT IN (SELECT field_of_study
                                    FROM   igs_he_ut_excl_qals
                                    WHERE  tariff_calc_type_cd = cp_tariff_calc_type
                                    AND  (award_cd IS NULL OR award_cd = cp_exam_level)))
    GROUP BY uqd.Exam_level, uqd.Subject_code ;


    -- cursor to get records for the passed subject with other exam levels
    CURSOR cur_check_dup_awards (cp_person_id  igs_uc_qual_dets.person_id%TYPE,
                                 cp_exam_level igs_uc_qual_dets.exam_level%TYPE,
                                 cp_subject_cd igs_uc_qual_dets.subject_code%TYPE,
                                 cp_tariff_calc_type igs_he_ut_lvl_award.tariff_calc_type_cd%TYPE)  IS
    SELECT DISTINCT exam_level
    FROM  igs_uc_qual_dets
    WHERE person_id = cp_person_id
    AND   exam_level <> cp_exam_level
    AND   subject_code = cp_subject_cd
    AND   exam_level     IN (SELECT hula.award_cd
                             FROM   igs_he_ut_lvl_award hula
                             WHERE  hula.tariff_calc_type_cd = cp_tariff_calc_type
                               AND  hula.closed_ind = 'N')
    AND   exam_level NOT IN (SELECT hueq.award_cd
                             FROM   igs_he_ut_excl_qals hueq
                             WHERE  hueq.tariff_calc_type_cd = cp_tariff_calc_type
                               AND  hueq.field_of_study IS NULL);

    -- Cursor for checking whether parent award exists for the passed in award.
    CURSOR cur_check_parent (cp_award_cd igs_he_ut_prt_award.award_cd%TYPE,
                              cp_tariff_calc_type igs_he_ut_prt_award.tariff_calc_type_cd%TYPE) IS
      SELECT parent_award_cd
      FROM   ( SELECT *
                FROM igs_he_ut_prt_award
                WHERE tariff_calc_type_cd = cp_tariff_calc_type)
      START WITH award_cd = cp_award_cd
      CONNECT BY PRIOR parent_award_cd=award_cd
      AND tariff_calc_type_cd = cp_tariff_calc_type;

    -- get the person number for the person id for logging user message
    CURSOR person_number_cur (cp_person_id igs_pe_person.person_id%TYPE ) IS
    SELECT person_number
    FROM   igs_pe_person_base_v
    WHERE  person_id = cp_person_id;

    l_person_number igs_pe_person.person_number%TYPE ;

    -- check whether person + calculation type already exists.
    CURSOR check_prsn_tariff_exists_cur (cp_person_id igs_he_ut_prs_calcs.person_id%TYPE,
                                        cp_calc_type igs_he_ut_prs_calcs.tariff_calc_type_cd%TYPE) IS
   SELECT rowid
   FROM   igs_he_ut_prs_calcs
   WHERE  person_id           = cp_person_id
     AND  tariff_calc_type_cd = cp_calc_type;

    check_prsn_tariff_exists_rec check_prsn_tariff_exists_cur%ROWTYPE;

    -- cursor to get the person tariff details records for deleting before calculation
    CURSOR get_prsn_tariff_dtls_cur(cp_person_id igs_he_ut_prs_calcs.person_id%TYPE,
                                    cp_calc_type igs_he_ut_prs_calcs.tariff_calc_type_cd%TYPE) IS
    SELECT upd.rowid
    FROM   igs_he_ut_prs_dtls upd
    WHERE  person_id           = cp_person_id
      AND  tariff_calc_type_cd = cp_calc_type;

    l_Int_calc_sql     VARCHAR2(32767);
    l_prs_grp_sql      VARCHAR2(32767) := NULL;
    l_prs_grp_status   VARCHAR2(1)     := NULL;
    l_parent_awd_found BOOLEAN;
    l_tariff_score     NUMBER ;
    l_total_tariff_score NUMBER;  -- jchin bug 3678414 Hold the total tariff
    l_qual_count       NUMBER ;
    l_record_inserted  NUMBER := 0;
    l_person_id        igs_uc_qual_dets.person_id%TYPE;
    l_calc_prsn_tariff VARCHAR2(1);
    l_rowid VARCHAR2(26);
    l_prnt_awd_closed    VARCHAR2(1);

    --jchakrab added for R12 Performance Enhs (4950293)
    l_num_rows           NUMBER;
    l_cursor_id          NUMBER;

    -- anwest added for Bug #5121695
    l_group_type         VARCHAR2(10);

  BEGIN
    fnd_dsql.init;

    -- basic sql stmt to get list of persons to be processed.
    -- l_Int_calc_sql := 'SELECT DISTINCT person_id FROM   igs_uc_qual_dets WHERE  person_id = NVL(' || p_person_identifier || ', person_id) ';
    fnd_dsql.add_text('SELECT DISTINCT person_id FROM igs_uc_qual_dets ');

    IF p_person_identifier IS NOT NULL OR p_person_id_grp IS NOT NULL THEN

      fnd_dsql.add_text(' WHERE ');

      IF p_person_identifier IS NOT NULL THEN
        fnd_dsql.add_text('person_id = ');
        fnd_dsql.add_bind(p_person_identifier);
      ELSE
        fnd_dsql.add_text('1 = 1 ');
      END IF;

      -- Person ID Group filtering
      IF p_person_id_grp IS NOT NULL THEN
        l_prs_grp_sql := IGS_PE_DYNAMIC_PERSID_GROUP.GET_DYNAMIC_SQL(p_person_id_grp, l_prs_grp_status, l_group_type);

        IF l_prs_grp_status <> 'S' THEN
          fnd_message.set_name('IGS','IGS_HE_UT_PRSN_ID_GRP_ERR');
          fnd_message.set_token('PRSNIDGRP',p_person_id_grp);
          errbuf := fnd_message.get();
          fnd_file.put_line(fnd_file.log, errbuf);  -- this message need to be displayed to user.
          retcode := '2';
          RETURN;
        END IF;

        IF l_group_type = 'STATIC' THEN
          l_prs_grp_sql := SUBSTR(l_prs_grp_sql, 1, INSTR(UPPER(l_prs_grp_sql), ':P_GROUPID') - 1);
        END IF;

        -- concatenate the incoming sql stmt to the basic sql to get the complete SQL stmt
        fnd_dsql.add_text(' AND person_id IN (');
        fnd_dsql.add_text(l_prs_grp_sql);
        IF l_group_type = 'STATIC' THEN
          fnd_dsql.add_bind(p_person_id_grp);
        END IF;
        fnd_dsql.add_text(')');
        l_prs_grp_sql  := NULL; -- initializing to NULL as this variable no more required for processing.
      END IF;

    END IF; -- check for person id or person id group parameters

    l_cursor_id := DBMS_SQL.OPEN_CURSOR;
    fnd_dsql.set_cursor(l_cursor_id);

    l_Int_calc_sql := fnd_dsql.get_text(FALSE);
    DBMS_SQL.PARSE(l_cursor_id, l_Int_calc_sql, DBMS_SQL.NATIVE);
    fnd_dsql.do_binds;

    DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, l_person_id);

    l_num_rows := DBMS_SQL.EXECUTE(l_cursor_id);

    -- Get the list of persons to be processed for the given criteria
    LOOP

        -- fetch a row
        IF DBMS_SQL.FETCH_ROWS(l_cursor_id) = 0 THEN
            EXIT;
        END IF;

        DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_person_id);

        -- variable initialization
        l_person_number := NULL;
        check_prsn_tariff_exists_rec := NULL;
        l_calc_prsn_tariff := 'Y';

        -- get the person number for message logging
        OPEN person_number_cur (l_person_id);
        FETCH person_number_cur INTO l_person_number;
        CLOSE person_number_cur ;

        -- check whether the person + Tariff Calculation type record already exists in the
        -- igs_he_ut_prs_calcs table. If no, then insert a new record irrespective of the
        -- recalculate parameter as in either case, a new record has to be created.
        OPEN  check_prsn_tariff_exists_cur(l_person_id, p_tariff_calc_type);
        FETCH check_prsn_tariff_exists_cur INTO check_prsn_tariff_exists_rec;
        CLOSE check_prsn_tariff_exists_cur ;

        IF check_prsn_tariff_exists_rec.rowid IS NULL THEN

          -- insert a new record
          igs_he_ut_prs_calcs_pkg.insert_row(
             x_rowid               => check_prsn_tariff_exists_rec.rowid
            ,x_tariff_calc_type_cd => p_tariff_calc_type
            ,x_person_id           => l_person_id
            ,x_calc_date           => TRUNC(SYSDATE)
            ,x_mode                => 'R');

          -- set the flag to indicate that tariff calculation has to be run
          l_calc_prsn_tariff := 'Y';

        ELSE
          IF p_recalculate = 'Y' THEN

            -- update the corresponding record's calc date
            igs_he_ut_prs_calcs_pkg.update_row(
                 x_rowid               => check_prsn_tariff_exists_rec.rowid
                ,x_tariff_calc_type_cd => p_tariff_calc_type
                ,x_person_id           => l_person_id
                ,x_calc_date           => TRUNC(SYSDATE)
                ,x_mode                => 'R');

            -- delete all existing tariff records for the person and insert afresh
            FOR del_dtls_rec IN get_prsn_tariff_dtls_cur (l_person_id, p_tariff_calc_type)
            LOOP
                igs_he_ut_prs_dtls_pkg.delete_row(del_dtls_rec.rowid);
            END LOOP;

            -- set the flag to allow tariff calculation
            l_calc_prsn_tariff := 'Y';

          ELSE
            -- existing tariff calculated values to be retained and hence not tariff need
            -- to be calculated. Only log a message in the log
            l_calc_prsn_tariff := 'N';

            fnd_message.set_name('IGS','IGS_HE_UT_NOT_RECALC');
            fnd_message.set_token('PERSON', l_person_number);
            fnd_message.set_token('CALCTYPE', p_tariff_calc_type);
            fnd_file.put_line(fnd_file.log, fnd_message.get());

          END IF;

        END IF; -- check for existence of parent record

        --------------------------------------------------------------------
        --- MAIN PROCESSING FOR TARIFF CALCULATION
        --------------------------------------------------------------------

        IF l_calc_prsn_tariff = 'Y' THEN

          l_total_tariff_score := 0;  --jchin bug 3678414 initialize total tariff score

          -- get the distinct exam levels for the person based on the given criteria and setup
          FOR prsn_exam_level_rec IN prsn_exam_level_cur(l_person_id, p_tariff_calc_type)
          LOOP

            -- variable initialization
            l_tariff_score := 0;
            l_qual_count   := 0;

            -- get tariff
            FOR get_tariff_rec IN  get_tariff_cur (l_person_id, prsn_exam_level_rec.exam_level, p_tariff_calc_type)
            LOOP

              -- variable initialization
              l_parent_awd_found := FALSE;

              -- Logic for Filtering to prevent double counting
              FOR dup_award_rec IN cur_check_dup_awards(l_person_id,
                                          get_tariff_rec.exam_level,
                                          get_tariff_rec.subject_code,
                                          p_tariff_calc_type)  LOOP

                  FOR parent_awd_rec IN cur_check_parent(prsn_exam_level_rec.exam_level, p_tariff_calc_type)
                  LOOP
                     IF parent_awd_rec.parent_award_cd = dup_award_rec.exam_level THEN
                        l_parent_awd_found := TRUE;
                        EXIT;
                     END IF;
                  END LOOP;

                  EXIT WHEN l_parent_awd_found = TRUE;

              END LOOP;

                -- jchin bug 3678414 generating total tariff score
              IF l_parent_awd_found = FALSE THEN

                l_qual_count   :=  l_qual_count + 1;
                l_tariff_score :=  l_tariff_score + NVL(get_tariff_rec.ucas_tariff,0);
                l_total_tariff_score := l_total_tariff_score + NVL(get_tariff_rec.ucas_tariff,0);

              ELSIF p_report_all_hierarchy_flag = 'Y' THEN

                -- Logic for Condition, p_report_all_hierarchy_flag = 'Y'
                -- If Qualification has a parent award in the same subject(Double counting scenario) and
                -- Report all awards in tariff breakdown is checked then report the Tariff at Exam Level
                -- This logic is added as part of HE311FD - JUly 2004 Enhancement Bug, 2956444

                -- Update the count and Tariff score. This will get the total of UCAS Tariff and the
                -- number of subjects for an Exam level

                l_tariff_score :=  l_tariff_score + NVL(get_tariff_rec.ucas_tariff,0);
                l_qual_count   :=  l_qual_count + 1;

              END IF;

            END LOOP;

            -- create tariff details for the person
            l_rowid := NULL;
            igs_he_ut_prs_dtls_pkg.insert_row(
                 x_rowid               => l_rowid
                ,x_tariff_calc_type_cd => p_tariff_calc_type
                ,x_person_id           => l_person_id
                ,x_award_cd            => prsn_exam_level_rec.exam_level
                ,x_number_of_qual      => l_qual_count
                ,x_tariff_score        => l_tariff_score
                ,x_mode                => 'R' );

            l_record_inserted := l_record_inserted + 1 ;

            Fnd_Message.Set_Name('IGS','IGS_HE_EXAM_LEVEL_TARIFF');
            Fnd_Message.Set_Token('PERSON_NUMBER',l_person_number);
            Fnd_Message.Set_Token('COURSE_CODE', '---');
            Fnd_Message.Set_Token('EXAM_LEVEL',prsn_exam_level_rec.Exam_level);
            Fnd_Message.Set_Token('SUBJECT_COUNT',l_qual_count);
            Fnd_Message.Set_Token('TARIFF_SCORE',l_tariff_score);
            fnd_file.put_line(fnd_file.log, fnd_message.get());

          END LOOP; -- for distinct exam levels for a person

          -- jchin bug 3678414 - display total tariff score
          Fnd_Message.Set_Name('IGS','IGS_HE_TOTAL_TARIFF');
          Fnd_Message.Set_Token('PERSON_NUMBER',l_person_number);
          Fnd_Message.Set_Token('COURSE_CODE', '---');
          Fnd_Message.Set_Token('HIGH_QUAL', '---');
          Fnd_Message.Set_Token('TOTAL_TARIFF',l_total_tariff_score);
          fnd_file.put_line(fnd_file.log, fnd_message.get());

        END IF; -- l_calc_prsn_tariff = Y check. If no then bypass the above processing

        COMMIT;

    END LOOP;  -- Loop of Cursor prsn_grp_cur i.e. list of all persons to be processed

    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);

    fnd_message.set_name('IGS','IGS_UC_INS_REC_COUNT');
    fnd_message.set_token('REC_CNT',l_record_inserted);
    fnd_file.put_line(fnd_file.log, fnd_message.get());

  EXCEPTION
    WHEN OTHERS THEN
      IF l_cursor_id IS NOT NULL THEN
        DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
      END IF;

      ROLLBACK;

      IF  SQLCODE=-1436 THEN
        fnd_message.set_name('IGS','IGS_HE_UT_AWD_CYCLIC_REL');
        fnd_message.set_token('AWARD',NULL);
      ELSE
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_HE_UCAS_TARIFF_PKG.internal_tariff_calc - '||SQLERRM);
      END IF;

      IF ( fnd_log.level_unexpected >= l_debug_level ) THEN
        fnd_log.message(fnd_log.level_unexpected, 'igs.plsql.hesa.ucas_tariff_calc.exception', FALSE);
      END IF;

      fnd_message.retrieve (Errbuf);
      Retcode := 2 ;
      RETURN;

  END internal_tariff_calc;

  FUNCTION total_internal_tariff (
    p_tariff_calc_type_cd IN igs_he_ut_prs_calcs.tariff_calc_type_cd%TYPE,
    p_person_id           IN igs_he_ut_prs_calcs.person_id%TYPE)
  RETURN NUMBER AS
  /*------------------------------------------------------------------
  --Created by  : AYEDUBAT, Oracle IDC
  --Date created: 05-05-2004
  --
  --Purpose: To calculate the Total Tariff for a person for an internal tariff calculation type
  --         Used in the view definition, IGS_HE_UT_PRS_CALCS_V
  --Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  WHO        WHEN       WHAT
  AYEDUBAT   05-05-04   Created as part of the bug # 3589897
  --------------------------------------------------------------------------*/

  -- cursor to get the person tariff details records
  CURSOR prsn_tariff_dtls_cur(cp_person_id igs_he_ut_prs_calcs.person_id%TYPE,
                              cp_calc_type igs_he_ut_prs_calcs.tariff_calc_type_cd%TYPE) IS
    SELECT upd.award_cd
    FROM   igs_he_ut_prs_dtls upd
    WHERE  person_id           = cp_person_id
      AND  tariff_calc_type_cd = cp_calc_type;

  CURSOR get_tariff_cur (cp_person_id        Igs_uc_qual_dets.person_id%TYPE,
                         cp_exam_level       Igs_uc_qual_dets.Exam_level%TYPE,
                         cp_tariff_calc_type Igs_he_ut_excl_qals.tariff_calc_type_cd%TYPE) IS
    SELECT uqd.Exam_level,
           uqd.Subject_code,
           MAX(grd.rank) ucas_tariff
    FROM   igs_uc_qual_dets uqd,
           igs_as_grd_sch_grade grd
    WHERE  uqd.Person_id         = cp_person_id
      AND  uqd.Exam_level        = cp_exam_level
      AND  grd.grade             = uqd.approved_result
      AND  grd.grading_schema_cd = uqd.grading_schema_cd
      AND  grd.version_number    = uqd.version_number
      AND  (subject_code IS NULL OR subject_code NOT IN (SELECT field_of_study
                                    FROM   igs_he_ut_excl_qals
                                    WHERE  tariff_calc_type_cd = cp_tariff_calc_type
                                    AND  (award_cd IS NULL OR award_cd = cp_exam_level)))
    GROUP BY uqd.Exam_level, uqd.Subject_code ;

    -- cursor to get records for the passed subject with other exam levels
    CURSOR cur_check_dup_awards (cp_person_id  igs_uc_qual_dets.person_id%TYPE,
                                 cp_exam_level igs_uc_qual_dets.exam_level%TYPE,
                                 cp_subject_cd igs_uc_qual_dets.subject_code%TYPE,
                                 cp_tariff_calc_type igs_he_ut_lvl_award.tariff_calc_type_cd%TYPE)  IS
    SELECT DISTINCT exam_level
    FROM  igs_uc_qual_dets
    WHERE person_id = cp_person_id
    AND   exam_level <> cp_exam_level
    AND   subject_code = cp_subject_cd
    AND   exam_level     IN (SELECT hula.award_cd
                             FROM   igs_he_ut_lvl_award hula
                             WHERE  hula.tariff_calc_type_cd = cp_tariff_calc_type
                               AND  hula.closed_ind = 'N')
    AND   exam_level NOT IN (SELECT hueq.award_cd
                             FROM   igs_he_ut_excl_qals hueq
                             WHERE  hueq.tariff_calc_type_cd = cp_tariff_calc_type
                               AND  hueq.field_of_study IS NULL);

    -- Cursor for checking whether parent award exists for the passed in award.
    CURSOR cur_check_parent (cp_award_cd igs_he_ut_prt_award.award_cd%TYPE,
                              cp_tariff_calc_type igs_he_ut_prt_award.tariff_calc_type_cd%TYPE) IS
      SELECT parent_award_cd
      FROM   ( SELECT *
                FROM igs_he_ut_prt_award
                WHERE tariff_calc_type_cd = cp_tariff_calc_type)
      START WITH award_cd = cp_award_cd
      CONNECT BY PRIOR parent_award_cd=award_cd
      AND tariff_calc_type_cd = cp_tariff_calc_type;

    l_parent_awd_found   BOOLEAN;
    l_tariff_score NUMBER(15);

  BEGIN

    l_tariff_score := 0;

    -- Get the Exam levels for the person from the Person UCAS Tariff Details table
    FOR prsn_tariff_dtls_rec IN prsn_tariff_dtls_cur(p_person_id, p_tariff_calc_type_cd) LOOP

      -- Get the UCAS Tariff
      FOR get_tariff_rec IN  get_tariff_cur (p_person_id, prsn_tariff_dtls_rec.award_cd, p_tariff_calc_type_cd) LOOP

        -- variable initialization
        l_parent_awd_found := FALSE;

        -- Logic for Filtering to prevent double counting
        FOR dup_award_rec IN cur_check_dup_awards(p_person_id,
                                                  get_tariff_rec.exam_level,
                                                  get_tariff_rec.subject_code,
                                                  p_tariff_calc_type_cd)  LOOP

            FOR parent_awd_rec IN cur_check_parent(prsn_tariff_dtls_rec.award_cd, p_tariff_calc_type_cd) LOOP

               IF parent_awd_rec.parent_award_cd = dup_award_rec.exam_level THEN
                  l_parent_awd_found := TRUE;
                  EXIT;
               END IF;

            END LOOP;

            EXIT WHEN l_parent_awd_found = TRUE;

        END LOOP;

        IF l_parent_awd_found = FALSE THEN

          l_tariff_score :=  l_tariff_score + NVL(get_tariff_rec.ucas_tariff,0);

        END IF;

      END LOOP;

    END LOOP;

    RETURN l_tariff_score;

  EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT2_PKG.TOTAL_INTERNAL_TARIFF');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

  END total_internal_tariff;


  -- ============================== END OF INTERNAL TARIFF CALCULATION ===========================

  PROCEDURE ucas_tariff_calc (
     errbuf              OUT NOCOPY VARCHAR2,
     retcode             OUT NOCOPY NUMBER,
     p_tariff_calc_type  IN  VARCHAR2,
     p_calculate_tariff  IN  VARCHAR2,
     p_person_id_grp     IN  NUMBER,
     p_person_identifier IN  NUMBER,
     p_program_group     IN  VARCHAR2,
     p_program_type      IN  VARCHAR2,
     p_course_code       IN  VARCHAR2,
     p_start_date        IN  VARCHAR2,
     p_end_date          IN  VARCHAR2,
     P_recalculate       IN  VARCHAR2
    ) IS

  /*------------------------------------------------------------------
  --Created by  : Bayadav, Oracle IDC
  --Date created: Sekhar Kappaganti
  --
  --Purpose: This is to import UCAS tariff data from Sec/ter table in to SPA table
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  WHO       WHEN          WHAT
  smvk      03-Jun-2003   Bug # 2858436.Modified the cursor c_prgawd to select open program awards only.
  rbezawad  13-Feb-03     Modified w.r.t. HEFD202.1 build, Bug 2717744.
                          Introduced logic to aviod double counting of qualifications
  pmarada   24-jul-2003   Before creating the ucas tariff scores for a student deleting  old
                          ucas tariff score details. so removed the Igs_he_st_spa_ut_all_pkg update row call
                          and added delete row call. as per the bug 3064689
  rgangara  29-Aug-03     Added 4 new parameters and created this as a separate procedure
                          for ease of understanding and maintenance
  ayedubat  16-MAR-04     Added a new parameter, p_report_all_hierarchy_flag to the internal and
                          external tariff calculation procedure calls for Bug, 2956444
  anwest    18-JAN-20     Bug# 4950285 R12 Disable OSS Mandate
  -----------------------------------------------------------------------*/

  CURSOR get_calc_type_cur (p_tariff_calc_type igs_he_ut_calc_type.tariff_calc_type_cd%TYPE) IS
  SELECT tariff_calc_type_cd,
         external_calc_ind,
         report_all_hierarchy_flag
  FROM   igs_he_ut_calc_type
  WHERE  tariff_calc_type_cd = p_tariff_calc_type;

  get_calc_type_rec get_calc_type_cur%ROWTYPE;

  BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    fnd_file.put_line(fnd_file.log, '-------------------------------------------------------');
    fnd_file.put_line(fnd_file.log, 'P_TARIFF_CALC_TYPE      = ' || p_tariff_calc_type);
    fnd_file.put_line(fnd_file.log, 'P_CALCULATE_TARIFF      = ' || p_calculate_tariff);
    fnd_file.put_line(fnd_file.log, 'P_PERSON_ID_GRP         = ' || p_person_id_grp);
    fnd_file.put_line(fnd_file.log, 'P_PERSON_IDENTIFIER     = ' || TO_CHAR(p_person_identifier));
    fnd_file.put_line(fnd_file.log, 'P_PROGRAM_GROUP         = ' || p_program_group);
    fnd_file.put_line(fnd_file.log, 'P_PROGRAM_TYPE          = ' || p_program_type);
    fnd_file.put_line(fnd_file.log, 'P_COURSE_CODE           = ' || p_course_code);
    fnd_file.put_line(fnd_file.log, 'P_START_DATE            = ' || p_start_date);
    fnd_file.put_line(fnd_file.log, 'P_END_DATE              = ' || p_end_date);
    fnd_file.put_line(fnd_file.log, 'P_RECALCULATE           = ' || p_recalculate);
    fnd_file.put_line(fnd_file.log, '-------------------------------------------------------');


    /* Checking whether the UK profile is enabled */
    IF NOT (igs_uc_utils.is_ucas_hesa_enabled) THEN

      fnd_message.set_name('IGS','IGS_UC_HE_NOT_ENABLED');
      fnd_file.put_line(fnd_file.log, fnd_message.get());  -- display to user also
      -- also log using the new logging framework
      IF (fnd_log.level_statement >= l_debug_level ) THEN
        fnd_log.string( fnd_log.level_statement, 'igs.plsql.hesa.ucas_tariff_calc.validation', fnd_message.get());
      END IF;
      retcode := 3 ;
      RETURN ;

    END IF;

    -- Fetch the details of the Tariff Calculation Type
    get_calc_type_rec := NULL;
    OPEN get_calc_type_cur (p_tariff_calc_type);
    FETCH get_calc_type_cur INTO get_calc_type_rec;
    CLOSE get_calc_type_cur;

    IF  p_calculate_tariff = 'Y' THEN

      IF get_calc_type_rec.external_calc_ind <> 'Y' THEN
        --Display log message that HESA Tariff calculation can only be done for External Flagged Calculation type.
        fnd_message.set_name('IGS','IGS_HE_UT_CALC_NOT_EXTERNAL');
        fnd_file.put_line(fnd_file.log, fnd_message.get());
        retcode := 3;
        RETURN;
      END IF;

    END IF;

    -- If internal tariff calculation and start or end dates are not null then log an appropriate message and continue
    IF  p_calculate_tariff = 'N' AND (p_start_date IS NOT NULL OR p_end_date IS NOT NULL) THEN
      fnd_message.set_name('IGS','IGS_HE_UT_DATE_NOT_RELEVANT');
      fnd_file.put_line(fnd_file.log, fnd_message.get());
    END IF;

    -- for Internal tariff calculation, parameters
    -- p_course_cd, p_start_date, p_end_date, p_program_group and p_program_type
    -- have got no relevance.
    -- Based on the HESA Tariff Calculation parameter, call either
    -- internal or external tariff calculation
    IF p_calculate_tariff = 'Y' THEN

      -- external tariff calculation
      External_tariff_calc (
        errbuf              => errbuf             ,
        retcode             => retcode            ,
        p_person_identifier => p_person_identifier,
        p_course_code       => p_course_code      ,
        p_start_date        => p_start_date       ,
        p_end_date          => p_end_date         ,
        p_tariff_calc_type  => p_tariff_calc_type ,
        p_calculate_tariff  => p_calculate_tariff ,
        P_recalculate       => p_recalculate     ,
        p_person_id_grp     => p_person_id_grp   ,
        p_program_group     => p_program_group   ,
        p_program_type      => p_program_type    ,
        p_report_all_hierarchy_flag => get_calc_type_rec.report_all_hierarchy_flag );

     ELSE

      -- Internal tariff calculation
      Internal_tariff_calc (
        errbuf              => errbuf             ,
        retcode             => retcode            ,
        p_person_identifier => p_person_identifier,
        p_tariff_calc_type  => p_tariff_calc_type ,
        p_calculate_tariff  => p_calculate_tariff ,
        p_recalculate       => p_recalculate     ,
        p_person_id_grp     => p_person_id_grp   ,
        p_report_all_hierarchy_flag => get_calc_type_rec.report_all_hierarchy_flag );

     END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      IF  SQLCODE=-1436 THEN
        fnd_message.set_name('IGS','IGS_HE_UT_AWD_CYCLIC_REL');
        fnd_message.set_token('AWARD',NULL);
      ELSE
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_HE_UCAS_TARIFF_PKG.UCAS_TARIFF_CALC - '||SQLERRM);
      END IF;

      IF (fnd_log.level_unexpected >= l_debug_level) THEN
        fnd_log.message(fnd_log.level_unexpected, 'igs.plsql.hesa.ucas_tariff_calc.exception', FALSE);
      END IF;

      fnd_message.retrieve (Errbuf);
      Retcode := 2 ;
      igs_ge_msg_stack.conc_exception_hndl;

  END ucas_tariff_calc;

END igs_he_ucas_tariff_pkg;

/
