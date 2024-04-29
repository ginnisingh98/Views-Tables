--------------------------------------------------------
--  DDL for Package Body IGS_PS_LGCY_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_LGCY_CONC_PKG" AS
/* $Header: IGSPS87B.pls 120.3 2006/01/24 00:33:31 sarakshi ship $ */

  /******************************************************************
  Created By         :
  Date Created By    :
  Purpose            :
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who       When        What
  sarakshi  02-sep-2003 Enh#3052452,removed the reference of the column sup_unit_allowed_ind and sub_unit_allowed_ind. Also populated the data for unit section
  vvutukur  05-Aug-2003 Enh#3045069.PSP Enh Build. Modified legacy_batch_process.
  ******************************************************************/

  PROCEDURE legacy_batch_process(
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY NUMBER,
    p_n_batch_id NUMBER,
    p_c_del_flag VARCHAR2
   )
    AS
    /**********************************************************
    Created By : jdeekoll

    Date Created By : 29-NOV-2002

    Purpose : For scheduling the Unit Section occurrences

    Know limitations, enhancements or remarks

    Change History

    Who                When                 What
    sarakshi           12-Jan-2006          bug#4926548, replaced the cursor c_table with the pl-sql table .
    sommukhe           9-JAN-2006           Bug# 4869737,included call to igs_ge_gen_003.set_org_id.
    smvk               28-Jul-2004          Bug # 3793580. Allowing the user to import instructors for No Set Day USO.
                                            Added column no_set_day_ind to interface table IGS_PS_LGCY_INS_INT.
    sarakshi           04-May-2004          Enh#3568858,populated columns ovrd_wkld_val_flag, workload_val_code to the unit record type
    smvk               19-Apr-2004          Bug # 3565536. Picking up multiple unit section grading schemas, Also added order by clause to print the
                                            log file information order by interface sequence identifier.
    sarakshi           16-Feb-2004          Bug#3431844, added owner filter in the cursor c_table and modified its usage accordingly
    sarakshi           10-Nov-2003          Enh#3116171, added logic related to the newly introduced field BILLING_CREDIT_POINTS in unit and unit section level
    vvutukur           05-Aug-2003          Enh#3045069.PSP Enh Build. Added code to populate data for column
                                            not_multiple_section_flag at unit section level.
    sarakshi           28-Jun-2003          Enh#2930935,added enrolled and achievable credit points to
                                            the unit section pl/sql table
    smvk               27-Jun-2003          Enh Bug # 2999888. Added Gen_ref_flag in unit reference code.
    jbegum             02-June-2003         Enh#2972950
                                            For Legacy Enhancements TD:
                                            Appropriate changes carried out for the inclusion of
                                            igs_ps_lgcy_ins_int interface table also added few column in the
                                            unit section table to get imported.
                                            For PSP Scheduling Enhancements TD:
                                            Select preferred_region_code and no_set_day_indicator values from
                                            legacy interface table IGS_PS_LGCY_OC_INT into PL/SQL table v_tab_uso.
                              		  Select unit section occurrence start date/end date and no set day indicator
                                            values from legacy interface table IGS_PS_LGCY_UR_INT into PL/SQL table v_tab_unit_ref.
    smvk               11-Dec-2002          Bug # 2702065. Modified rec_c_unit_sec.version_number,
                                            l_unit_ver_rec.contact_hrs_lab and rec_c_unit_sec.unit_cd.
    smvk               23-Dec-2002          Bug # 2702147. Logging of successful message in the log file and
                                            updation of import_status of the record as 'I' only when the
                                            overall status (x_return_status of API) is 'S'.
    smvk               24-Dec-2002          Bug # 2702147. Printing the row head if the value of
                                            the variable is l_b_print_row_heading TRUE.
    smvk               31-Dec-2002          Bug # 2710978. Collecting the statistics of the interface table as per standards.
    smvk               02-Jan-2002          Bug # 2695956. The process return status is set to Success even if one of the
                                            record is successfully imported.(i.e the process status will be error only if all
                                            the attempted records to import ends up in error).
    (reverse chronological order - newest change first)
   ***************************************************************/

  -- Distinct Unit Versions from all 8 Interface Tables
       CURSOR c_all_units IS
         SELECT DISTINCT
           unit_cd,
           version_number
           FROM   igs_ps_lgcy_uv_int
           WHERE batch_id=p_n_batch_id
           AND import_status IN ('U','R')
         UNION
           SELECT DISTINCT
             unit_cd,
             version_number
             FROM   igs_ps_lgcy_tr_int
             WHERE batch_id=p_n_batch_id
             AND import_status IN ('U','R')
         UNION
           SELECT DISTINCT
             unit_cd,
             version_number
             FROM   igs_ps_lgcy_ud_int
             WHERE batch_id=p_n_batch_id
             AND import_status IN ('U','R')
         UNION
           SELECT DISTINCT
             unit_cd,
             unit_version_number
             FROM igs_ps_lgcy_ug_int
             WHERE batch_id=p_n_batch_id
             AND import_status IN ('U','R')
         UNION
           SELECT DISTINCT
             unit_cd,
             version_number
             FROM   igs_ps_lgcy_us_int
             WHERE batch_id=p_n_batch_id
             AND import_status IN ('U','R')
         UNION
           SELECT DISTINCT
             unit_cd,
             version_number
             FROM   igs_ps_lgcy_sg_int
             WHERE batch_id=p_n_batch_id
             AND import_status IN ('U','R')
              UNION
           SELECT DISTINCT
             unit_cd,
             version_number
             FROM   igs_ps_lgcy_oc_int
                   WHERE batch_id=p_n_batch_id
             AND import_status IN ('U','R')
              UNION
           SELECT DISTINCT
             unit_cd,
             version_number
             FROM   igs_ps_lgcy_ur_int
                  WHERE batch_id=p_n_batch_id
             AND import_status IN ('U','R')
              UNION
           SELECT DISTINCT
             unit_cd,
             version_number
             FROM   igs_ps_lgcy_ins_int
                  WHERE batch_id=p_n_batch_id
             AND import_status IN ('U','R')
         ORDER BY unit_cd,version_number;

    -- Unit Version Interface Table cursor

       CURSOR c_unit_ver(cp_c_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,cp_n_version_number igs_ps_unit_ver_all.version_number%TYPE) IS
         SELECT *
         FROM igs_ps_lgcy_uv_int
         WHERE batch_id=p_n_batch_id
         AND   unit_cd=cp_c_unit_cd
         AND   version_number=cp_n_version_number
         AND   import_status IN ('U','R');

    -- Teaching Responsibility Interface Table cursor

       CURSOR c_teach_resp(cp_c_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,cp_n_version_number igs_ps_unit_ver_all.version_number%TYPE) IS
         SELECT *
         FROM igs_ps_lgcy_tr_int
         WHERE batch_id=p_n_batch_id
         AND   unit_cd=cp_c_unit_cd
         AND   version_number=cp_n_version_number
         AND   import_status IN ('U','R')
         ORDER BY unit_cd,version_number, teach_resp_int_id;

    -- Unit Discplines Interface Table cursor

       CURSOR c_unit_disp(cp_c_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,cp_n_version_number igs_ps_unit_ver_all.version_number%TYPE) IS
         SELECT *
         FROM igs_ps_lgcy_ud_int
         WHERE batch_id=p_n_batch_id
         AND   unit_cd=cp_c_unit_cd
         AND   version_number=cp_n_version_number
         AND   import_status IN ('U','R')
         ORDER BY unit_cd,version_number, unit_discip_int_id;


    -- Grading Schema Interface Table cursor

       CURSOR c_grd_sch(cp_c_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,cp_n_version_number igs_ps_unit_ver_all.version_number%TYPE) IS
         SELECT *
         FROM igs_ps_lgcy_ug_int
         WHERE batch_id=p_n_batch_id
         AND   unit_cd=cp_c_unit_cd
         AND   unit_version_number=cp_n_version_number
         AND   import_status IN ('U','R')
         ORDER BY unit_cd,unit_version_number, uv_grd_schm_int_id;

    -- Unit Section Interface Table cursor

       CURSOR c_unit_sec(cp_c_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,cp_n_version_number igs_ps_unit_ver_all.version_number%TYPE) IS
         SELECT *
         FROM igs_ps_lgcy_us_int
         WHERE batch_id=p_n_batch_id
         AND   unit_cd=cp_c_unit_cd
         AND   version_number=cp_n_version_number
         AND   import_status IN ('U','R')
         ORDER BY unit_cd,version_number, unit_section_int_id;

    -- Unit Section Grading Schema Interface Table cursor

       CURSOR c_us_grd_sch(cp_c_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,cp_n_version_number igs_ps_unit_ver_all.version_number%TYPE) IS
         SELECT *
         FROM igs_ps_lgcy_sg_int
         WHERE batch_id=p_n_batch_id
         AND   unit_cd=cp_c_unit_cd
         AND   version_number=cp_n_version_number
         AND   import_status IN ('U','R')
         ORDER BY unit_cd,version_number, usec_grd_schm_int_id;

    -- Unit Section Occurrences Interface Table cursor

       CURSOR c_uso(cp_c_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,cp_n_version_number igs_ps_unit_ver_all.version_number%TYPE) IS
         SELECT *
         FROM igs_ps_lgcy_oc_int
         WHERE batch_id=p_n_batch_id
         AND   unit_cd=cp_c_unit_cd
         AND   version_number=cp_n_version_number
         AND   import_status IN ('U','R')
         ORDER BY unit_cd,version_number, usec_occur_int_id;

    -- Unit Reference Codes Interface Table cursor

       CURSOR c_unit_ref_cd(cp_c_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,cp_n_version_number igs_ps_unit_ver_all.version_number%TYPE) IS
         SELECT *
         FROM igs_ps_lgcy_ur_int
         WHERE batch_id=p_n_batch_id
         AND   unit_cd=cp_c_unit_cd
         AND   version_number=cp_n_version_number
         AND   import_status IN ('U','R')
         ORDER BY unit_cd,version_number, unit_reference_int_id;

    -- Instructor Interface Table Cursor
     CURSOR c_ins ( cp_n_batch_id igs_ps_lgcy_ins_int.batch_id%TYPE ,
                    cp_c_unit_cd igs_ps_lgcy_ins_int.unit_cd%TYPE,
                    cp_n_version_number igs_ps_lgcy_ins_int.version_number%TYPE) IS
       SELECT *
       FROM igs_ps_lgcy_ins_int
       WHERE batch_id=cp_n_batch_id
       AND unit_cd=cp_c_unit_cd
       AND version_number=cp_n_version_number
       AND import_status IN ('U','R')
       ORDER BY unit_cd,version_number, uso_instructor_int_id;


	TYPE tabnames IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
        tablenames_tbl tabnames;


        rec_c_all_units   c_all_units%ROWTYPE;
        l_n_chld_cntr     NUMBER(7);
        l_c_return_status VARCHAR2(1);
        l_n_msg_count     NUMBER(10);
        l_c_msg_data      VARCHAR2(2000);
        l_n_msg_num       fnd_new_messages.message_number%TYPE;
        l_c_msg_txt       fnd_new_messages.message_text%TYPE;
        l_c_msg_name      fnd_new_messages.message_name%TYPE;
        l_appl_name       VARCHAR2(30);

        rec_c_unit_ver     c_unit_ver%ROWTYPE;
        l_unit_ver_rec     igs_ps_generic_pub.unit_ver_rec_type;
        v_tab_unit_tr      igs_ps_generic_pub.unit_tr_tbl_type;
        v_tab_unit_dscp    igs_ps_generic_pub.unit_dscp_tbl_type;
        v_tab_unit_gs      igs_ps_generic_pub.unit_gs_tbl_type;
        v_tab_usec         igs_ps_generic_pub.usec_tbl_type;
        v_tab_usec_gs      igs_ps_generic_pub.usec_gs_tbl_type;
        v_tab_uso          igs_ps_generic_pub.uso_tbl_type;
        v_tab_unit_ref     igs_ps_generic_pub.unit_ref_tbl_type;
        v_tab_ins          igs_ps_generic_pub.uso_ins_tbl_type;
        l_n_request_id     igs_ps_lgcy_uv_int.request_id%TYPE;
        l_n_prog_appl_id   igs_ps_lgcy_uv_int.program_application_id%TYPE;
        l_n_prog_id        igs_ps_lgcy_uv_int.program_id%TYPE;
        l_d_prog_upd_dt    igs_ps_lgcy_uv_int.program_update_date%TYPE;
        p_head             BOOLEAN ;
        l_ret_status       BOOLEAN ;  -- Holds return status, TRUE if all the attempted records to import result in Error.
        l_c_import_desc    VARCHAR2(80);
        l_c_succ_desc      VARCHAR2(80);
        l_c_status         VARCHAR2(1);
        l_c_industry       VARCHAR2(1);
        l_c_schema         VARCHAR2(30);
        l_b_return         BOOLEAN;

        l_b_print_row_heading BOOLEAN ;  -- Use for logging the row_head

            /* Procedure to get messages */

    PROCEDURE get_message(p_c_msg_name VARCHAR2,p_n_msg_num OUT NOCOPY NUMBER,p_c_msg_txt OUT NOCOPY VARCHAR2) AS

       CURSOR c_msg(cp_c_msg_name fnd_new_messages.message_name%TYPE ) IS
         SELECT
           message_number,
           message_text
         FROM   fnd_new_messages
         WHERE  application_id=8405
	 AND    language_code = USERENV('LANG')
	 AND    message_name=cp_c_msg_name;

         rec_c_msg         c_msg%ROWTYPE;
     BEGIN
       OPEN c_msg(p_c_msg_name);
       FETCH c_msg INTO rec_c_msg;
       IF c_msg%FOUND THEN
         p_n_msg_num := rec_c_msg.message_number;
         p_c_msg_txt := rec_c_msg.message_text;
       ELSE
         p_c_msg_txt := p_c_msg_name;
       END IF;
       CLOSE c_msg;
     END get_message;

      /* Procedure to write log file */
    PROCEDURE log_file(p_c_text VARCHAR2,p_c_type VARCHAR2) AS
      /* different types are P -> fnd_file.put, L-> fnd_file.put_line,N -> fnd_file.new_line */
    BEGIN

      IF p_c_type = 'P' THEN
        fnd_file.put(fnd_file.log,p_c_text);
      ELSIF p_c_type = 'L' THEN
        fnd_file.put_line(fnd_file.log,p_c_text);
      ELSIF p_c_type = 'N' THEN
        fnd_file.new_line(fnd_file.log);
      END IF;
    END log_file;

        /* Procedure to char - n times */
    PROCEDURE print_char(p_n_count NUMBER,p_c_char VARCHAR2) AS
    BEGIN
      FOR I IN 1..p_n_count
      LOOP
        log_file(p_c_char,'P');
      END LOOP;
    END print_char;

    /* Get message from Message Stack */

    FUNCTION get_msg_from_stack(l_n_msg_count NUMBER) RETURN VARCHAR2 AS
      l_c_msg VARCHAR2(3000);
      l_c_msg_name fnd_new_messages.message_name%TYPE;
    BEGIN
      l_c_msg := FND_MSG_PUB.GET(p_msg_index => l_n_msg_count, p_encoded => 'T');
      FND_MESSAGE.SET_ENCODED (l_c_msg);
      FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED,l_appl_name, l_c_msg_name);
      RETURN l_c_msg_name;
    END get_msg_from_stack;

    PROCEDURE row_head(p_c_row_type VARCHAR2,p_n_unit_cd VARCHAR2,p_n_vers_num NUMBER) AS
    BEGIN
      log_file(' ','N');
      get_message('IGS_EN_ROW_TYPE',l_n_msg_num,l_c_msg_txt);
      log_file(l_c_msg_txt,'P');
      log_file(' ','P');
      log_file(igs_ps_validate_lgcy_pkg.get_lkup_meaning(p_c_row_type,'LEGACY_PS_REC_TABLES'),'P');
      log_file(' ','P');
      log_file(igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_CD','LEGACY_TOKENS'),'P');
      log_file(' : ','P');
      log_file(p_n_unit_cd,'P');
      log_file(' ','P');
      log_file(igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_VER_NUM','LEGACY_TOKENS'),'P');
      log_file(' : ','P');
      log_file(p_n_vers_num,'L');
      log_file(' ','N');

    END row_head;

    PROCEDURE print_heading AS
      CURSOR c_batch_desc IS
         SELECT
           description
         FROM   igs_ps_lgcy_bat_int
         WHERE  batch_id=p_n_batch_id;

      l_c_batch_desc igs_ps_lgcy_bat_int.description%TYPE;

    BEGIN
          IF p_head THEN

          /****************** Begin Heading **********************/

             print_char(80,'=');
             log_file(' ','N');

             OPEN c_batch_desc;
             FETCH c_batch_desc INTO l_c_batch_desc;
             CLOSE c_batch_desc;

             get_message('IGS_EN_BATCH_ID',l_n_msg_num,l_c_msg_txt);
             log_file(l_c_msg_txt,'P');
             log_file(' : ','P');
             log_file(p_n_batch_id,'P');
             log_file(' ','P');
             get_message('IGS_EN_REG_LOG_DESC',l_n_msg_num,l_c_msg_txt);
             log_file(l_c_msg_txt,'P');
             log_file(' : ','P');
             log_file(l_c_batch_desc,'L');


             print_char(80,'-');
             log_file(' ','N');
             get_message('IGS_EN_INTERFACE_ID',l_n_msg_num,l_c_msg_txt);
             log_file(l_c_msg_txt,'P');
             print_char(4,' ');

             get_message('IGS_EN_MESSAGE_NUM',l_n_msg_num,l_c_msg_txt);
             log_file(l_c_msg_txt,'P');
             print_char(1,' ');

             get_message('IGS_EN_ROW_STATUS',l_n_msg_num,l_c_msg_txt);
             log_file(l_c_msg_txt,'P');
             print_char(1,' ');

             get_message('IGS_EN_MSG_TXT',l_n_msg_num,l_c_msg_txt);
             log_file(l_c_msg_txt,'L');

             print_char(80,'-');
             log_file(' ','N');

             p_head := FALSE;

          /******************End Heading**********************/

       END IF;
    END print_heading;

  BEGIN /* Main Begin */

     igs_ge_gen_003.set_org_id (NULL);
     -- Initializing the values to overcome file.sql.35 warning.
     p_head                := TRUE;
     l_ret_status          := TRUE;  -- Holds return status, TRUE if all the attempted records to import result in Error.
     l_b_print_row_heading := TRUE;  -- Use for logging the row_head

     -- To fetch table schema name for gather statistics
     l_b_return := fnd_installation.get_app_info('IGS', l_c_status, l_c_industry, l_c_schema);

     -- Collect statistics of the interface table as per standards. Bug # 2710978
     tablenames_tbl(1) := 'IGS_PS_LGCY_UV_INT';
     tablenames_tbl(2) := 'IGS_PS_LGCY_TR_INT';
     tablenames_tbl(3) := 'IGS_PS_LGCY_UD_INT';
     tablenames_tbl(4) := 'IGS_PS_LGCY_UG_INT';
     tablenames_tbl(5) := 'IGS_PS_LGCY_US_INT';
     tablenames_tbl(6) := 'IGS_PS_LGCY_SG_INT';
     tablenames_tbl(7) := 'IGS_PS_LGCY_OC_INT';
     tablenames_tbl(8) := 'IGS_PS_LGCY_UR_INT';
     tablenames_tbl(9) := 'IGS_PS_LGCY_INS_INT';

     FOR i IN 1.. tablenames_tbl.LAST
     LOOP

       -- Gather statistics of interface tables
       fnd_stats.gather_table_stats(ownname => l_c_schema,
                                    tabname => tablenames_tbl(i),
                                    cascade => TRUE
                                   );
     END LOOP;

     -- Set the default status as success
    retcode := 0;

     /* Setting concurrent program values */

    l_n_request_id := fnd_global.conc_request_id;
    l_n_prog_appl_id := fnd_global.prog_appl_id;
    l_n_prog_id := fnd_global.conc_program_id;
    l_d_prog_upd_dt := SYSDATE;
    IF l_n_request_id = -1 THEN
      l_n_request_id := NULL;
      l_n_prog_appl_id := NULL;
      l_n_prog_id := NULL;
      l_d_prog_upd_dt := NULL;
    END IF;

    get_message('IGS_EN_LGCY_SUCCESS',l_n_msg_num,l_c_succ_desc);
    l_c_import_desc := igs_ps_validate_lgcy_pkg.get_lkup_meaning('I','LEGACY_STATUS');

    FOR rec_c_all_units IN c_all_units
    LOOP

         /******************Begin of Unit Version Record ************************/

         OPEN c_unit_ver(rec_c_all_units.unit_cd,rec_c_all_units.version_number);
         FETCH  c_unit_ver INTO rec_c_unit_ver;
            IF c_unit_ver%FOUND THEN

              print_heading;

              l_unit_ver_rec.unit_cd := rec_c_unit_ver.unit_cd;
              l_unit_ver_rec.version_number := rec_c_unit_ver.version_number;
              l_unit_ver_rec.start_dt := rec_c_unit_ver.start_dt;
              l_unit_ver_rec.review_dt  := rec_c_unit_ver.review_dt;
              l_unit_ver_rec.expiry_dt  := rec_c_unit_ver.expiry_dt;
              l_unit_ver_rec.end_dt  := rec_c_unit_ver.end_dt;
              l_unit_ver_rec.unit_status := rec_c_unit_ver.unit_status;
              l_unit_ver_rec.title := rec_c_unit_ver.title;
              l_unit_ver_rec.short_title := rec_c_unit_ver.short_title;
              l_unit_ver_rec.title_override_ind  := rec_c_unit_ver.title_override_ind;
              l_unit_ver_rec.abbreviation  := rec_c_unit_ver.abbreviation;
              l_unit_ver_rec.unit_level := rec_c_unit_ver.unit_level;
              l_unit_ver_rec.credit_point_descriptor := rec_c_unit_ver.credit_point_descriptor;
              l_unit_ver_rec.enrolled_credit_points := rec_c_unit_ver.enrolled_credit_points;
              l_unit_ver_rec.points_override_ind := rec_c_unit_ver.points_override_ind;
              l_unit_ver_rec.supp_exam_permitted_ind := rec_c_unit_ver.supp_exam_permitted_ind;
              l_unit_ver_rec.coord_person_number := rec_c_unit_ver.coord_person_number;
              l_unit_ver_rec.owner_org_unit_cd := rec_c_unit_ver.owner_org_unit_cd;
              l_unit_ver_rec.award_course_only_ind := rec_c_unit_ver.award_course_only_ind;
              l_unit_ver_rec.research_unit_ind := rec_c_unit_ver.research_unit_ind;
              l_unit_ver_rec.industrial_ind := rec_c_unit_ver.industrial_ind;
              l_unit_ver_rec.practical_ind := rec_c_unit_ver.practical_ind;
              l_unit_ver_rec.repeatable_ind := rec_c_unit_ver.repeatable_ind;
              l_unit_ver_rec.assessable_ind := rec_c_unit_ver.assessable_ind;
              l_unit_ver_rec.achievable_credit_points  := rec_c_unit_ver.achievable_credit_points;
              l_unit_ver_rec.points_increment := rec_c_unit_ver.points_increment;
              l_unit_ver_rec.points_min := rec_c_unit_ver.points_min;
              l_unit_ver_rec.points_max := rec_c_unit_ver.points_max;
              l_unit_ver_rec.unit_int_course_level_cd  := rec_c_unit_ver.unit_int_course_level_cd;
              l_unit_ver_rec.subtitle_modifiable_flag  := rec_c_unit_ver.subtitle_modifiable_flag;
              l_unit_ver_rec.approval_date := rec_c_unit_ver.approval_date;
              l_unit_ver_rec.lecture_credit_points  := rec_c_unit_ver.lecture_credit_points;
              l_unit_ver_rec.lab_credit_points := rec_c_unit_ver.lab_credit_points;
              l_unit_ver_rec.other_credit_points := rec_c_unit_ver.other_credit_points;
              l_unit_ver_rec.clock_hours := rec_c_unit_ver.clock_hours;
              l_unit_ver_rec.work_load_cp_lecture := rec_c_unit_ver.work_load_cp_lecture;
              l_unit_ver_rec.work_load_cp_lab := rec_c_unit_ver.work_load_cp_lab;
              l_unit_ver_rec.continuing_education_units := rec_c_unit_ver.continuing_education_units;
              l_unit_ver_rec.enrollment_expected := rec_c_unit_ver.enrollment_expected;
              l_unit_ver_rec.enrollment_minimum  := rec_c_unit_ver.enrollment_minimum;
              l_unit_ver_rec.enrollment_maximum  := rec_c_unit_ver.enrollment_maximum;
              l_unit_ver_rec.advance_maximum  := rec_c_unit_ver.advance_maximum;
              l_unit_ver_rec.state_financial_aid := rec_c_unit_ver.state_financial_aid;
              l_unit_ver_rec.federal_financial_aid  := rec_c_unit_ver.federal_financial_aid;
              l_unit_ver_rec.institutional_financial_aid  := rec_c_unit_ver.institutional_financial_aid;
              l_unit_ver_rec.same_teaching_period := rec_c_unit_ver.same_teaching_period;
              l_unit_ver_rec.max_repeats_for_credit := rec_c_unit_ver.max_repeats_for_credit;
              l_unit_ver_rec.max_repeats_for_funding := rec_c_unit_ver.max_repeats_for_funding;
              l_unit_ver_rec.max_repeat_credit_points  := rec_c_unit_ver.max_repeat_credit_points;
              l_unit_ver_rec.same_teach_period_repeats := rec_c_unit_ver.same_teach_period_repeats;
              l_unit_ver_rec.same_teach_period_repeats_cp := rec_c_unit_ver.same_teach_period_repeats_cp;
              l_unit_ver_rec.attribute_category  := rec_c_unit_ver.attribute_category;
              l_unit_ver_rec.attribute1 := rec_c_unit_ver.attribute1;
              l_unit_ver_rec.attribute2 := rec_c_unit_ver.attribute2;
              l_unit_ver_rec.attribute3 := rec_c_unit_ver.attribute3;
              l_unit_ver_rec.attribute4 := rec_c_unit_ver.attribute4;
              l_unit_ver_rec.attribute5 := rec_c_unit_ver.attribute5;
              l_unit_ver_rec.attribute6 := rec_c_unit_ver.attribute6;
              l_unit_ver_rec.attribute7 := rec_c_unit_ver.attribute7;
              l_unit_ver_rec.attribute8 := rec_c_unit_ver.attribute8;
              l_unit_ver_rec.attribute9 := rec_c_unit_ver.attribute9;
              l_unit_ver_rec.attribute10 := rec_c_unit_ver.attribute10;
              l_unit_ver_rec.attribute11 := rec_c_unit_ver.attribute11;
              l_unit_ver_rec.attribute12 := rec_c_unit_ver.attribute12;
              l_unit_ver_rec.attribute13 := rec_c_unit_ver.attribute13;
              l_unit_ver_rec.attribute14 := rec_c_unit_ver.attribute14;
              l_unit_ver_rec.attribute15 := rec_c_unit_ver.attribute15;
              l_unit_ver_rec.attribute16 := rec_c_unit_ver.attribute16;
              l_unit_ver_rec.attribute17 := rec_c_unit_ver.attribute17;
              l_unit_ver_rec.attribute18 := rec_c_unit_ver.attribute18;
              l_unit_ver_rec.attribute19 := rec_c_unit_ver.attribute19;
              l_unit_ver_rec.attribute20 := rec_c_unit_ver.attribute20;
              l_unit_ver_rec.ivr_enrol_ind := rec_c_unit_ver.ivr_enrol_ind;
              l_unit_ver_rec.ss_enrol_ind  := rec_c_unit_ver.ss_enrol_ind;
              l_unit_ver_rec.work_load_other  := rec_c_unit_ver.work_load_other;
              l_unit_ver_rec.contact_hrs_lecture := rec_c_unit_ver.contact_hrs_lecture;
              l_unit_ver_rec.contact_hrs_lab  := rec_c_unit_ver.contact_hrs_lab;
              l_unit_ver_rec.contact_hrs_other := rec_c_unit_ver.contact_hrs_other;
              l_unit_ver_rec.non_schd_required_hrs  := rec_c_unit_ver.non_schd_required_hrs;
              l_unit_ver_rec.exclude_from_max_cp_limit := rec_c_unit_ver.exclude_from_max_cp_limit;
              l_unit_ver_rec.record_exclusion_flag  := rec_c_unit_ver.record_exclusion_flag;
              l_unit_ver_rec.ss_display_ind := rec_c_unit_ver.ss_display_ind;
              l_unit_ver_rec.enrol_load_alt_cd := rec_c_unit_ver.enrol_load_alt_cd;
              l_unit_ver_rec.offer_load_alt_cd := rec_c_unit_ver.offer_load_alt_cd;
              l_unit_ver_rec.override_enrollment_max := rec_c_unit_ver.override_enrollment_max;
              l_unit_ver_rec.repeat_code := rec_c_unit_ver.repeat_code;
              l_unit_ver_rec.level_code := rec_c_unit_ver.level_code;
              l_unit_ver_rec.special_permission_ind := rec_c_unit_ver.special_permission_ind;
              l_unit_ver_rec.rev_account_cd := rec_c_unit_ver.rev_account_cd;
              l_unit_ver_rec.claimable_hours  := rec_c_unit_ver.claimable_hours;
              l_unit_ver_rec.anon_unit_grading_ind  := rec_c_unit_ver.anon_unit_grading_ind;
              l_unit_ver_rec.anon_assess_grading_ind := rec_c_unit_ver.anon_assess_grading_ind;
              l_unit_ver_rec.subtitle := rec_c_unit_ver.subtitle;
              l_unit_ver_rec.subtitle_approved_ind  := rec_c_unit_ver.subtitle_approved_ind;
              l_unit_ver_rec.subtitle_closed_ind := rec_c_unit_ver.subtitle_closed_ind;
              l_unit_ver_rec.curriculum_id := rec_c_unit_ver.curriculum_id;
              l_unit_ver_rec.curriculum_description := rec_c_unit_ver.curriculum_description;
              l_unit_ver_rec.curriculum_closed_ind  := rec_c_unit_ver.curriculum_closed_ind;
              l_unit_ver_rec.auditable_ind := rec_c_unit_ver.auditable_ind;
              l_unit_ver_rec.audit_permission_ind := rec_c_unit_ver.audit_permission_ind;
              l_unit_ver_rec.max_auditors_allowed := rec_c_unit_ver.max_auditors_allowed;
	      l_unit_ver_rec.billing_credit_points := rec_c_unit_ver.billing_credit_points;
              l_unit_ver_rec.interface_id := rec_c_unit_ver.unit_version_int_id;
	      l_unit_ver_rec.ovrd_wkld_val_flag := rec_c_unit_ver.ovrd_wkld_val_flag;
              l_unit_ver_rec.workload_val_code := rec_c_unit_ver.workload_val_code;
              l_unit_ver_rec.billing_hrs := rec_c_unit_ver.billing_hrs;
            END IF;
            CLOSE c_unit_ver;

           /******************End Unit Version Record ************************/

          /******************Begin Teaching Responsibility **********************/

           l_n_chld_cntr :=1;

           FOR rec_c_teach_resp IN c_teach_resp(rec_c_all_units.unit_cd,rec_c_all_units.version_number)
           LOOP

             print_heading;

             v_tab_unit_tr(l_n_chld_cntr).unit_cd := rec_c_teach_resp.unit_cd;
             v_tab_unit_tr(l_n_chld_cntr).version_number := rec_c_teach_resp.version_number;
             v_tab_unit_tr(l_n_chld_cntr).org_unit_cd := rec_c_teach_resp.org_unit_cd;
             v_tab_unit_tr(l_n_chld_cntr).percentage := rec_c_teach_resp.percentage;
             v_tab_unit_tr(l_n_chld_cntr).interface_id := rec_c_teach_resp.teach_resp_int_id;

             l_n_chld_cntr := l_n_chld_cntr+1;

           END LOOP;

          /******************End Teaching Responsibility **********************/

          /******************Begin Unit Disciplines **********************/

           l_n_chld_cntr :=1;

           FOR rec_c_unit_disp IN c_unit_disp(rec_c_all_units.unit_cd,rec_c_all_units.version_number)
           LOOP

             print_heading;

             v_tab_unit_dscp(l_n_chld_cntr).unit_cd := rec_c_unit_disp.unit_cd;
             v_tab_unit_dscp(l_n_chld_cntr).version_number := rec_c_unit_disp.version_number;
             v_tab_unit_dscp(l_n_chld_cntr).discipline_group_cd := rec_c_unit_disp.discipline_group_cd;
             v_tab_unit_dscp(l_n_chld_cntr).percentage  := rec_c_unit_disp.percentage;
             v_tab_unit_dscp(l_n_chld_cntr).interface_id := rec_c_unit_disp.unit_discip_int_id;

             l_n_chld_cntr := l_n_chld_cntr+1;

           END LOOP;

          /******************End Unit Disciplines **********************/

          /******************Begin Grading Sch **********************/

           l_n_chld_cntr :=1;

           FOR rec_c_grd_sch IN c_grd_sch(rec_c_all_units.unit_cd,rec_c_all_units.version_number)
           LOOP

             print_heading;

             v_tab_unit_gs(l_n_chld_cntr).unit_cd := rec_c_grd_sch.unit_cd;
             v_tab_unit_gs(l_n_chld_cntr).version_number := rec_c_grd_sch.unit_version_number;
             v_tab_unit_gs(l_n_chld_cntr).grading_schema_code     := rec_c_grd_sch.grading_schema_code;
             v_tab_unit_gs(l_n_chld_cntr).grd_schm_version_number  := rec_c_grd_sch.grd_schm_version_number;
             v_tab_unit_gs(l_n_chld_cntr).default_flag := rec_c_grd_sch.default_flag;
             v_tab_unit_gs(l_n_chld_cntr).interface_id := rec_c_grd_sch.uv_grd_schm_int_id;

             l_n_chld_cntr := l_n_chld_cntr+1;

           END LOOP;

          /******************End Grading Sch **********************/

           /******************Begin Unit Section **********************/

           l_n_chld_cntr :=1;

           FOR rec_c_unit_sec IN c_unit_sec(rec_c_all_units.unit_cd,rec_c_all_units.version_number)
           LOOP

              print_heading;

              v_tab_usec(l_n_chld_cntr).unit_cd := rec_c_unit_sec.unit_cd;
              v_tab_usec(l_n_chld_cntr).version_number := rec_c_unit_sec.version_number;
              v_tab_usec(l_n_chld_cntr).teach_cal_alternate_code := rec_c_unit_sec.teach_cal_alternate_code;
              v_tab_usec(l_n_chld_cntr).location_cd := rec_c_unit_sec.location_cd;
              v_tab_usec(l_n_chld_cntr).unit_class := rec_c_unit_sec.unit_class;
              v_tab_usec(l_n_chld_cntr).ivrs_available_ind := rec_c_unit_sec.ivrs_available_ind;
              v_tab_usec(l_n_chld_cntr).call_number := rec_c_unit_sec.call_number;
              v_tab_usec(l_n_chld_cntr).unit_section_status := rec_c_unit_sec.unit_section_status;
              v_tab_usec(l_n_chld_cntr).unit_section_start_date := rec_c_unit_sec.unit_section_start_date;
              v_tab_usec(l_n_chld_cntr).unit_section_end_date := rec_c_unit_sec.unit_section_end_date;
              v_tab_usec(l_n_chld_cntr).offered_ind := rec_c_unit_sec.offered_ind;
              v_tab_usec(l_n_chld_cntr).state_financial_aid := rec_c_unit_sec.state_financial_aid;
              v_tab_usec(l_n_chld_cntr).grading_schema_prcdnce_ind := rec_c_unit_sec.grading_schema_prcdnce_ind;
              v_tab_usec(l_n_chld_cntr).federal_financial_aid := rec_c_unit_sec.federal_financial_aid;
              v_tab_usec(l_n_chld_cntr).unit_quota := rec_c_unit_sec.unit_quota;
              v_tab_usec(l_n_chld_cntr).unit_quota_reserved_places := rec_c_unit_sec.unit_quota_reserved_places;
              v_tab_usec(l_n_chld_cntr).institutional_financial_aid := rec_c_unit_sec.institutional_financial_aid;
              v_tab_usec(l_n_chld_cntr).grading_schema_cd := rec_c_unit_sec.grading_schema_cd;
              v_tab_usec(l_n_chld_cntr).gs_version_number := rec_c_unit_sec.gs_version_number;
              v_tab_usec(l_n_chld_cntr).unit_contact_number := rec_c_unit_sec.unit_contact_number;
              v_tab_usec(l_n_chld_cntr).ss_enrol_ind := rec_c_unit_sec.ss_enrol_ind;
              v_tab_usec(l_n_chld_cntr).owner_org_unit_cd := rec_c_unit_sec.owner_org_unit_cd;
              v_tab_usec(l_n_chld_cntr).attendance_required_ind := rec_c_unit_sec.attendance_required_ind;
              v_tab_usec(l_n_chld_cntr).reserved_seating_allowed := rec_c_unit_sec.reserved_seating_allowed;
              v_tab_usec(l_n_chld_cntr).special_permission_ind := rec_c_unit_sec.special_permission_ind;
              v_tab_usec(l_n_chld_cntr).ss_display_ind := rec_c_unit_sec.ss_display_ind;
              v_tab_usec(l_n_chld_cntr).rev_account_cd := rec_c_unit_sec.rev_account_cd;
              v_tab_usec(l_n_chld_cntr).anon_unit_grading_ind := rec_c_unit_sec.anon_unit_grading_ind;
              v_tab_usec(l_n_chld_cntr).anon_assess_grading_ind := rec_c_unit_sec.anon_assess_grading_ind;
              v_tab_usec(l_n_chld_cntr).non_std_usec_ind := rec_c_unit_sec.non_std_usec_ind;
              v_tab_usec(l_n_chld_cntr).auditable_ind := rec_c_unit_sec.auditable_ind;
              v_tab_usec(l_n_chld_cntr).audit_permission_ind := rec_c_unit_sec.audit_permission_ind;
              v_tab_usec(l_n_chld_cntr).waitlist_allowed := rec_c_unit_sec.waitlist_allowed;
              v_tab_usec(l_n_chld_cntr).max_students_per_waitlist := rec_c_unit_sec.max_students_per_waitlist;
              v_tab_usec(l_n_chld_cntr).minimum_credit_points := rec_c_unit_sec.minimum_credit_points;
              v_tab_usec(l_n_chld_cntr).maximum_credit_points := rec_c_unit_sec.maximum_credit_points;
              v_tab_usec(l_n_chld_cntr).variable_increment := rec_c_unit_sec.variable_increment;
              v_tab_usec(l_n_chld_cntr).lecture_credit_points := rec_c_unit_sec.lecture_credit_points;
              v_tab_usec(l_n_chld_cntr).lab_credit_points := rec_c_unit_sec.lab_credit_points;
              v_tab_usec(l_n_chld_cntr).other_credit_points := rec_c_unit_sec.other_credit_points;
              v_tab_usec(l_n_chld_cntr).clock_hours := rec_c_unit_sec.clock_hours;
              v_tab_usec(l_n_chld_cntr).work_load_cp_lecture := rec_c_unit_sec.work_load_cp_lecture;
              v_tab_usec(l_n_chld_cntr).work_load_cp_lab := rec_c_unit_sec.work_load_cp_lab;
              v_tab_usec(l_n_chld_cntr).continuing_education_units := rec_c_unit_sec.continuing_education_units;
              v_tab_usec(l_n_chld_cntr).work_load_other := rec_c_unit_sec.work_load_other;
              v_tab_usec(l_n_chld_cntr).contact_hrs_lecture := rec_c_unit_sec.contact_hrs_lecture;
              v_tab_usec(l_n_chld_cntr).contact_hrs_lab := rec_c_unit_sec.contact_hrs_lab;
              v_tab_usec(l_n_chld_cntr).contact_hrs_other := rec_c_unit_sec.contact_hrs_other;
              v_tab_usec(l_n_chld_cntr).non_schd_required_hrs := rec_c_unit_sec.non_schd_required_hrs;
              v_tab_usec(l_n_chld_cntr).exclude_from_max_cp_limit := rec_c_unit_sec.exclude_from_max_cp_limit;
              v_tab_usec(l_n_chld_cntr).claimable_hours := rec_c_unit_sec.claimable_hours;
              v_tab_usec(l_n_chld_cntr).achievable_credit_points := rec_c_unit_sec.achievable_credit_points;
              v_tab_usec(l_n_chld_cntr).enrolled_credit_points := rec_c_unit_sec.enrolled_credit_points;
	      v_tab_usec(l_n_chld_cntr).billing_credit_points := rec_c_unit_sec.billing_credit_points;
              v_tab_usec(l_n_chld_cntr).reference_subtitle := rec_c_unit_sec.reference_subtitle;
              v_tab_usec(l_n_chld_cntr).reference_short_title := rec_c_unit_sec.reference_short_title;
              v_tab_usec(l_n_chld_cntr).reference_subtitle_mod_flag := rec_c_unit_sec.reference_subtitle_mod_flag;
              v_tab_usec(l_n_chld_cntr).reference_class_sch_excl_flag := rec_c_unit_sec.reference_class_sch_excl_flag;
              v_tab_usec(l_n_chld_cntr).reference_rec_exclusion_flag := rec_c_unit_sec.reference_rec_exclusion_flag;
              v_tab_usec(l_n_chld_cntr).reference_title := rec_c_unit_sec.reference_title;
              v_tab_usec(l_n_chld_cntr).reference_attribute_category  := rec_c_unit_sec.reference_attribute_category;
              v_tab_usec(l_n_chld_cntr).reference_attribute1 := rec_c_unit_sec.reference_attribute1;
              v_tab_usec(l_n_chld_cntr).reference_attribute2 := rec_c_unit_sec.reference_attribute2;
              v_tab_usec(l_n_chld_cntr).reference_attribute3 := rec_c_unit_sec.reference_attribute3;
              v_tab_usec(l_n_chld_cntr).reference_attribute4 := rec_c_unit_sec.reference_attribute4;
              v_tab_usec(l_n_chld_cntr).reference_attribute5 := rec_c_unit_sec.reference_attribute5;
              v_tab_usec(l_n_chld_cntr).reference_attribute6 := rec_c_unit_sec.reference_attribute6;
              v_tab_usec(l_n_chld_cntr).reference_attribute7 := rec_c_unit_sec.reference_attribute7;
              v_tab_usec(l_n_chld_cntr).reference_attribute8 := rec_c_unit_sec.reference_attribute8;
              v_tab_usec(l_n_chld_cntr).reference_attribute9 := rec_c_unit_sec.reference_attribute9;
              v_tab_usec(l_n_chld_cntr).reference_attribute10 := rec_c_unit_sec.reference_attribute10;
              v_tab_usec(l_n_chld_cntr).reference_attribute11 := rec_c_unit_sec.reference_attribute11;
              v_tab_usec(l_n_chld_cntr).reference_attribute12 := rec_c_unit_sec.reference_attribute12;
              v_tab_usec(l_n_chld_cntr).reference_attribute13 := rec_c_unit_sec.reference_attribute13;
              v_tab_usec(l_n_chld_cntr).reference_attribute14 := rec_c_unit_sec.reference_attribute14;
              v_tab_usec(l_n_chld_cntr).reference_attribute15 := rec_c_unit_sec.reference_attribute15;
              v_tab_usec(l_n_chld_cntr).reference_attribute16 := rec_c_unit_sec.reference_attribute16;
              v_tab_usec(l_n_chld_cntr).reference_attribute17 := rec_c_unit_sec.reference_attribute17;
              v_tab_usec(l_n_chld_cntr).reference_attribute18 := rec_c_unit_sec.reference_attribute18;
              v_tab_usec(l_n_chld_cntr).reference_attribute19 := rec_c_unit_sec.reference_attribute19;
              v_tab_usec(l_n_chld_cntr).reference_attribute20 := rec_c_unit_sec.reference_attribute20;
              v_tab_usec(l_n_chld_cntr).enrollment_expected := rec_c_unit_sec.enrollment_expected;
              v_tab_usec(l_n_chld_cntr).enrollment_minimum := rec_c_unit_sec.enrollment_minimum;
              v_tab_usec(l_n_chld_cntr).enrollment_maximum := rec_c_unit_sec.enrollment_maximum;
              v_tab_usec(l_n_chld_cntr).advance_maximum := rec_c_unit_sec.advance_maximum;
              v_tab_usec(l_n_chld_cntr).usec_waitlist_allowed := rec_c_unit_sec.usec_waitlist_allowed;
              v_tab_usec(l_n_chld_cntr).usec_max_students_per_waitlist := rec_c_unit_sec.usec_max_students_per_waitlist;
              v_tab_usec(l_n_chld_cntr).override_enrollment_maximum := rec_c_unit_sec.override_enrollment_maximum;
              v_tab_usec(l_n_chld_cntr).max_auditors_allowed := rec_c_unit_sec.max_auditors_allowed;
              v_tab_usec(l_n_chld_cntr).interface_id := rec_c_unit_sec.unit_section_int_id;
	      v_tab_usec(l_n_chld_cntr).not_multiple_section_flag := rec_c_unit_sec.not_multiple_section_flag;
	      v_tab_usec(l_n_chld_cntr).sup_unit_cd := rec_c_unit_sec.sup_unit_cd;
              v_tab_usec(l_n_chld_cntr).sup_version_number := rec_c_unit_sec.sup_version_number;
              v_tab_usec(l_n_chld_cntr).sup_teach_cal_alternate_code := rec_c_unit_sec.sup_teach_cal_alternate_code;
              v_tab_usec(l_n_chld_cntr).sup_location_cd := rec_c_unit_sec.sup_location_cd;
              v_tab_usec(l_n_chld_cntr).sup_unit_class := rec_c_unit_sec.sup_unit_class;
              v_tab_usec(l_n_chld_cntr).default_enroll_flag := rec_c_unit_sec.default_enroll_flag;
              v_tab_usec(l_n_chld_cntr).billing_hrs := rec_c_unit_sec.billing_hrs;


             l_n_chld_cntr := l_n_chld_cntr+1;

           END LOOP;

          /******************End Unit Section **********************/

          /******************Begin Unit Section Grading Sch **********************/

           l_n_chld_cntr :=1;

           FOR rec_c_us_grd_sch IN c_us_grd_sch(rec_c_all_units.unit_cd,rec_c_all_units.version_number)
           LOOP

             print_heading;

             v_tab_usec_gs(l_n_chld_cntr).unit_cd := rec_c_us_grd_sch.unit_cd;
             v_tab_usec_gs(l_n_chld_cntr).version_number := rec_c_us_grd_sch.version_number;
             v_tab_usec_gs(l_n_chld_cntr).teach_cal_alternate_code := rec_c_us_grd_sch.teach_cal_alternate_code;
             v_tab_usec_gs(l_n_chld_cntr).location_cd := rec_c_us_grd_sch.location_cd;
             v_tab_usec_gs(l_n_chld_cntr).unit_class := rec_c_us_grd_sch.unit_class;
             v_tab_usec_gs(l_n_chld_cntr).grading_schema_code := rec_c_us_grd_sch.grading_schema_code;
             v_tab_usec_gs(l_n_chld_cntr).grd_schm_version_number := rec_c_us_grd_sch.grd_schm_version_number;
             v_tab_usec_gs(l_n_chld_cntr).default_flag := rec_c_us_grd_sch.default_flag;
             v_tab_usec_gs(l_n_chld_cntr).interface_id := rec_c_us_grd_sch.usec_grd_schm_int_id;

             l_n_chld_cntr := l_n_chld_cntr+1;

           END LOOP;

          /******************End Unit Section Grading Sch **********************/

          /******************Begin Unit Section Occurrences **********************/

           l_n_chld_cntr :=1;

           -- As part of bug#2972950 for PSP Scheduling Enhancements TD assigning values to the newly
           -- added fields preferred_region_code and no_set_day_ind of the PL/SQL tables v_tab_uso.
           FOR rec_c_uso IN c_uso(rec_c_all_units.unit_cd,rec_c_all_units.version_number)
           LOOP

             print_heading;

             v_tab_uso(l_n_chld_cntr).unit_cd := rec_c_uso.unit_cd;
             v_tab_uso(l_n_chld_cntr).version_number := rec_c_uso.version_number;
             v_tab_uso(l_n_chld_cntr).teach_cal_alternate_code := rec_c_uso.teach_cal_alternate_code;
             v_tab_uso(l_n_chld_cntr).location_cd := rec_c_uso.location_cd;
             v_tab_uso(l_n_chld_cntr).unit_class := rec_c_uso.unit_class;
             v_tab_uso(l_n_chld_cntr).occurrence_identifier := rec_c_uso.occurrence_identifier;
             v_tab_uso(l_n_chld_cntr).to_be_announced     := rec_c_uso.to_be_announced;
             v_tab_uso(l_n_chld_cntr).monday := rec_c_uso.monday;
             v_tab_uso(l_n_chld_cntr).tuesday := rec_c_uso.tuesday;
             v_tab_uso(l_n_chld_cntr).wednesday := rec_c_uso.wednesday;
             v_tab_uso(l_n_chld_cntr).thursday := rec_c_uso.thursday;
             v_tab_uso(l_n_chld_cntr).friday := rec_c_uso.friday;
             v_tab_uso(l_n_chld_cntr).saturday := rec_c_uso.saturday;
             v_tab_uso(l_n_chld_cntr).sunday := rec_c_uso.sunday;
             v_tab_uso(l_n_chld_cntr).start_date := rec_c_uso.start_date;
             v_tab_uso(l_n_chld_cntr).end_date := rec_c_uso.end_date;
             v_tab_uso(l_n_chld_cntr).start_time := rec_c_uso.start_time;
             v_tab_uso(l_n_chld_cntr).end_time := rec_c_uso.end_time;
             v_tab_uso(l_n_chld_cntr).building_code := rec_c_uso.building_code;
             v_tab_uso(l_n_chld_cntr).room_code := rec_c_uso.room_code;
             v_tab_uso(l_n_chld_cntr).dedicated_building_code := rec_c_uso.dedicated_building_code;
             v_tab_uso(l_n_chld_cntr).dedicated_room_code := rec_c_uso.dedicated_room_code;
             v_tab_uso(l_n_chld_cntr).preferred_building_code := rec_c_uso.preferred_building_code;
             v_tab_uso(l_n_chld_cntr).preferred_room_code := rec_c_uso.preferred_room_code;
             v_tab_uso(l_n_chld_cntr).no_set_day_ind := rec_c_uso.no_set_day_ind;
             v_tab_uso(l_n_chld_cntr).preferred_region_code := rec_c_uso.preferred_region_code;
             v_tab_uso(l_n_chld_cntr).attribute_category := rec_c_uso.attribute_category;
             v_tab_uso(l_n_chld_cntr).attribute1 := rec_c_uso.attribute1;
             v_tab_uso(l_n_chld_cntr).attribute2 := rec_c_uso.attribute2;
             v_tab_uso(l_n_chld_cntr).attribute3 := rec_c_uso.attribute3;
             v_tab_uso(l_n_chld_cntr).attribute4 := rec_c_uso.attribute4;
             v_tab_uso(l_n_chld_cntr).attribute5 := rec_c_uso.attribute5;
             v_tab_uso(l_n_chld_cntr).attribute6 := rec_c_uso.attribute6;
             v_tab_uso(l_n_chld_cntr).attribute7 := rec_c_uso.attribute7;
             v_tab_uso(l_n_chld_cntr).attribute8 := rec_c_uso.attribute8;
             v_tab_uso(l_n_chld_cntr).attribute9 := rec_c_uso.attribute9;
             v_tab_uso(l_n_chld_cntr).attribute10 := rec_c_uso.attribute10;
             v_tab_uso(l_n_chld_cntr).attribute11 := rec_c_uso.attribute11;
             v_tab_uso(l_n_chld_cntr).attribute12 := rec_c_uso.attribute12;
             v_tab_uso(l_n_chld_cntr).attribute13 := rec_c_uso.attribute13;
             v_tab_uso(l_n_chld_cntr).attribute14 := rec_c_uso.attribute14;
             v_tab_uso(l_n_chld_cntr).attribute15 := rec_c_uso.attribute15;
             v_tab_uso(l_n_chld_cntr).attribute16 := rec_c_uso.attribute16;
             v_tab_uso(l_n_chld_cntr).attribute17 := rec_c_uso.attribute17;
             v_tab_uso(l_n_chld_cntr).attribute18 := rec_c_uso.attribute18;
             v_tab_uso(l_n_chld_cntr).attribute19 := rec_c_uso.attribute19;
             v_tab_uso(l_n_chld_cntr).attribute20 := rec_c_uso.attribute20;
             v_tab_uso(l_n_chld_cntr).interface_id := rec_c_uso.usec_occur_int_id;

             l_n_chld_cntr := l_n_chld_cntr+1;

           END LOOP;

          /******************End Unit Section Occurrences **********************/

          /******************Begin Unit Reference Codes **********************/

           l_n_chld_cntr :=1;

           -- As part of bug#2972950 for PSP Scheduling Enhancements TD assigning values
           -- to the newly added fields uso_start_date,uso_end_date and no_set_day_ind
           -- of the PL/SQL tables v_tab_unit_ref.
           FOR rec_c_unit_ref_cd IN c_unit_ref_cd(rec_c_all_units.unit_cd,rec_c_all_units.version_number)
           LOOP

             print_heading;

             v_tab_unit_ref(l_n_chld_cntr).production_uso_id := rec_c_unit_ref_cd.production_uso_id;
             v_tab_unit_ref(l_n_chld_cntr).unit_cd := rec_c_unit_ref_cd.unit_cd;
             v_tab_unit_ref(l_n_chld_cntr).version_number := rec_c_unit_ref_cd.version_number;
             v_tab_unit_ref(l_n_chld_cntr).data_type := rec_c_unit_ref_cd.data_type;
             v_tab_unit_ref(l_n_chld_cntr).teach_cal_alternate_code := rec_c_unit_ref_cd.teach_cal_alternate_code;
             v_tab_unit_ref(l_n_chld_cntr).location_cd := rec_c_unit_ref_cd.location_cd;
             v_tab_unit_ref(l_n_chld_cntr).unit_class := rec_c_unit_ref_cd.unit_class;
             v_tab_unit_ref(l_n_chld_cntr).occurrence_identifier := rec_c_unit_ref_cd.occurrence_identifier;
             v_tab_unit_ref(l_n_chld_cntr).reference_cd_type := rec_c_unit_ref_cd.reference_cd_type;
             v_tab_unit_ref(l_n_chld_cntr).reference_cd := rec_c_unit_ref_cd.reference_cd;
             v_tab_unit_ref(l_n_chld_cntr).description := rec_c_unit_ref_cd.description;
             v_tab_unit_ref(l_n_chld_cntr).gen_ref_flag := rec_c_unit_ref_cd.gen_ref_flag;
             v_tab_unit_ref(l_n_chld_cntr).interface_id := rec_c_unit_ref_cd.unit_reference_int_id;

             l_n_chld_cntr := l_n_chld_cntr+1;

           END LOOP;

          /******************End Unit Reference Codes **********************/

          /******************Begin Instructor **********************/

           l_n_chld_cntr :=1;
           FOR rec_ins IN c_ins(p_n_batch_id, rec_c_all_units.unit_cd, rec_c_all_units.version_number)
           LOOP

             print_heading;
             v_tab_ins(l_n_chld_cntr).instructor_person_number := rec_ins.instructor_person_number;
             v_tab_ins(l_n_chld_cntr).production_uso_id := rec_ins.production_uso_id;
             v_tab_ins(l_n_chld_cntr).unit_cd := rec_ins.unit_cd;
             v_tab_ins(l_n_chld_cntr).version_number := rec_ins.version_number;
             v_tab_ins(l_n_chld_cntr).teach_cal_alternate_code := rec_ins.teach_cal_alternate_code;
             v_tab_ins(l_n_chld_cntr).location_cd := rec_ins.location_cd;
             v_tab_ins(l_n_chld_cntr).unit_class := rec_ins.unit_class;
             v_tab_ins(l_n_chld_cntr).occurrence_identifier := rec_ins.occurrence_identifier;
             v_tab_ins(l_n_chld_cntr).confirmed_flag := rec_ins.confirmed_flag;
             v_tab_ins(l_n_chld_cntr).wl_percentage_allocation := rec_ins.wl_percentage_allocation;
             v_tab_ins(l_n_chld_cntr).instructional_load_lecture := rec_ins.instructional_load_lecture;
             v_tab_ins(l_n_chld_cntr).instructional_load_laboratory :=  rec_ins.instructional_load_laboratory;
             v_tab_ins(l_n_chld_cntr).instructional_load_other :=  rec_ins.instructional_load_other;
             v_tab_ins(l_n_chld_cntr).lead_instructor_flag := rec_ins.lead_instructor_flag;
             v_tab_ins(l_n_chld_cntr).interface_id := rec_ins.uso_instructor_int_id;

             l_n_chld_cntr := l_n_chld_cntr+1;

           END LOOP;

          /******************End Instructor **********************/



         /* Call to Public API  */

            igs_ps_unit_lgcy_pvt.create_unit
             (
               p_api_version => 1.0,
               p_init_msg_list => FND_API.G_TRUE,
               p_commit => FND_API.G_TRUE,
               p_unit_ver_rec => l_unit_ver_rec,
               p_unit_tr_tbl => v_tab_unit_tr,
               p_unit_dscp_tbl => v_tab_unit_dscp,
               p_unit_gs_tbl => v_tab_unit_gs,
               p_usec_tbl =>  v_tab_usec,
               p_usec_gs_tbl =>  v_tab_usec_gs,
               p_uso_tbl => v_tab_uso,
               p_unit_ref_tbl => v_tab_unit_ref,
               p_uso_ins_tbl => v_tab_ins,
               x_return_status => l_c_return_status,
               x_msg_count => l_n_msg_count,
               x_msg_data => l_c_msg_data
              );
         /* -----------------------------*/

            /* Error out if none of the tables have data */

            IF l_n_msg_count = 1 THEN
              IF get_msg_from_stack(l_n_msg_count) = 'IGS_PS_LGCY_DATA_NOT_PASSED' THEN
                get_message('IGS_PS_LGCY_DATA_NOT_PASSED',l_n_msg_num,l_c_msg_txt);
                log_file(l_c_msg_txt,'L');
                retcode := 2;
                RETURN;
              END IF;
            END IF;

            IF l_ret_status AND l_c_return_status = 'S' THEN
              l_ret_status := FALSE;
            END IF;

          /* -----------------------------------------------*/

          /******************Begin Unit Version Log and Error**********************/

             IF l_unit_ver_rec.status IN ('S','W','E') THEN
                row_head('PS_UNIT_VERSION',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
             END IF;

             IF l_unit_ver_rec.status = 'S' AND l_c_return_status = 'S' THEN

               /* Update the interface table */

               UPDATE igs_ps_lgcy_uv_int
               SET import_status = 'I'
               WHERE batch_id=p_n_batch_id
               AND unit_version_int_id = l_unit_ver_rec.interface_id;

               /* Write into log file */

               log_file(RPAD(l_unit_ver_rec.interface_id,31,' '),'P');
               log_file(RPAD(l_c_import_desc,10,' '),'P');
               print_char(1,' ');
               log_file(l_c_succ_desc,'L');

             ELSIF l_unit_ver_rec.status IN ('W','E') THEN

              /* Update the interface table */

               UPDATE igs_ps_lgcy_uv_int
               SET import_status = l_unit_ver_rec.status
               WHERE batch_id=p_n_batch_id
               AND unit_version_int_id = l_unit_ver_rec.interface_id;

               /* Write into log file */

               FOR l_curr_num IN l_unit_ver_rec.msg_from..l_unit_ver_rec.msg_to
               LOOP
                  l_c_msg_name := get_msg_from_stack(l_curr_num);
                  get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
                  l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');

                  INSERT INTO igs_ps_lgcy_err_int
                    (
                      err_message_id,
                      int_table_code,
                      int_table_id,
                      message_num,
                      message_text,
                      created_by,
                      creation_date,
                      last_updated_by,
                      last_update_date,
                      last_update_login,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date)
                  VALUES
                    (
                      igs_ps_lgcy_err_int_s.nextval,
                      igs_ps_validate_lgcy_pkg.get_lkup_meaning('PS_UNIT_VERSION','LEGACY_PS_REC_TABLES'),
                      l_unit_ver_rec.interface_id,
                      l_n_msg_num,
                      l_c_msg_txt,
                      NVL(fnd_global.user_id,-1),
                      SYSDATE,
                      NVL(fnd_global.user_id,-1),
                      SYSDATE,
                      NVL(fnd_global.login_id,-1),
                      l_n_request_id,
                      l_n_prog_appl_id,
                      l_n_prog_id,
                      l_d_prog_upd_dt
                    );

                  /* Write into log file */

                     log_file(RPAD(l_unit_ver_rec.interface_id,16,' '),'P');
                     log_file(RPAD(l_n_msg_num,15,' '),'P');
                     IF l_n_msg_num IS NULL THEN
                       print_char(15,' ');
                     END IF;
                     log_file(RPAD(igs_ps_validate_lgcy_pkg.get_lkup_meaning(l_unit_ver_rec.status,'LEGACY_STATUS'),10,' '),'P');
                     print_char(1,' ');
                     log_file(l_c_msg_txt,'L');

               END LOOP;
             END IF;
             l_unit_ver_rec.status := NULL;

          /******************End Unit Version Log and Error***********************/

          /******************Begin Teaching Resp Log and Error**********************/
             l_b_print_row_heading := TRUE;
             IF v_tab_unit_tr.EXISTS(1) THEN
                IF l_b_print_row_heading AND l_c_return_status = 'S' THEN
                   row_head('PS_TEACH_RESP',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                   l_b_print_row_heading := FALSE ;
                END IF;

               FOR i IN 1..v_tab_unit_tr.LAST
               LOOP

                 IF v_tab_unit_tr(i).status = 'S' AND l_c_return_status = 'S' THEN

                 /* Update the interface table */

                   UPDATE igs_ps_lgcy_tr_int
                    SET import_status = 'I'
                   WHERE batch_id=p_n_batch_id
                   AND teach_resp_int_id = v_tab_unit_tr(i).interface_id;

                 /* Write into log file */

                   log_file(RPAD(v_tab_unit_tr(i).interface_id,31,' '),'P');
                   log_file(RPAD(l_c_import_desc,10,' '),'P');
                   print_char(1,' ');
                   log_file(l_c_succ_desc,'L');

                 ELSIF v_tab_unit_tr(i).status IN ('W','E') THEN

                    IF l_b_print_row_heading THEN
                       row_head('PS_TEACH_RESP',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                       l_b_print_row_heading := FALSE ;
                    END IF;

                /* Update the interface table */

                   UPDATE igs_ps_lgcy_tr_int
                   SET import_status = v_tab_unit_tr(i).status
                   WHERE batch_id=p_n_batch_id
                   AND teach_resp_int_id = v_tab_unit_tr(i).interface_id;

                 /* Write into log file */

                   FOR l_curr_num IN v_tab_unit_tr(i).msg_from..v_tab_unit_tr(i).msg_to
                   LOOP

                     l_c_msg_name := get_msg_from_stack(l_curr_num);
                     get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
                     l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');

                     INSERT INTO igs_ps_lgcy_err_int
                      (
                        err_message_id,
                        int_table_code,
                        int_table_id,
                        message_num,
                        message_text,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date)
                     VALUES
                      (
                        igs_ps_lgcy_err_int_s.nextval,
                        igs_ps_validate_lgcy_pkg.get_lkup_meaning('PS_TEACH_RESP','LEGACY_PS_REC_TABLES'),
                        v_tab_unit_tr(i).interface_id,
                        l_n_msg_num,
                        l_c_msg_txt,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.login_id,-1),
                        l_n_request_id,
                        l_n_prog_appl_id,
                        l_n_prog_id,
                        l_d_prog_upd_dt
                      );

                    /* Write into log file */

                       log_file(RPAD(v_tab_unit_tr(i).interface_id,16,' '),'P');
                       log_file(RPAD(l_n_msg_num,15,' '),'P');
                       IF l_n_msg_num IS NULL THEN
                         print_char(15,' ');
                       END IF;
                       log_file(RPAD(igs_ps_validate_lgcy_pkg.get_lkup_meaning(v_tab_unit_tr(i).status,'LEGACY_STATUS'),10,' '),'P');
                       print_char(1,' ');
                       log_file(l_c_msg_txt,'L');

                   END LOOP; /* Messages loop */
                 END IF;
               END LOOP; /* Teaching Responsibility Loop */
                     v_tab_unit_tr.DELETE;
            END IF;

          /******************End Teaching Resp Log and Error***********************/

          /******************Begin Unit Disciplines Log and Error**********************/

             l_b_print_row_heading := TRUE;
             IF v_tab_unit_dscp.EXISTS(1) THEN

                IF l_b_print_row_heading AND l_c_return_status = 'S' THEN
                   row_head('PS_UNIT_DISCP',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                   l_b_print_row_heading := FALSE ;
                END IF;

               FOR i IN 1.. v_tab_unit_dscp.LAST
               LOOP

                 IF v_tab_unit_dscp(i).status = 'S' AND l_c_return_status = 'S' THEN

                 /* Update the interface table */

                   UPDATE igs_ps_lgcy_ud_int
                   SET import_status = 'I'
                   WHERE batch_id=p_n_batch_id
                   AND unit_discip_int_id = v_tab_unit_dscp(i).interface_id;

                 /* Write into log file */

                   log_file(RPAD(v_tab_unit_dscp(i).interface_id,31,' '),'P');
                   log_file(RPAD(l_c_import_desc,10,' '),'P');
                   print_char(1,' ');
                   log_file(l_c_succ_desc,'L');

                 ELSIF v_tab_unit_dscp(i).status IN ('W','E') THEN

                    IF l_b_print_row_heading THEN
                       row_head('PS_UNIT_DISCP',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                       l_b_print_row_heading := FALSE ;
                    END IF;

                /* Update the interface table */

                   UPDATE igs_ps_lgcy_ud_int
                   SET import_status = v_tab_unit_dscp(i).status
                   WHERE batch_id=p_n_batch_id
                   AND unit_discip_int_id = v_tab_unit_dscp(i).interface_id;

                 /* Write into log file */

                   FOR l_curr_num IN v_tab_unit_dscp(i).msg_from..v_tab_unit_dscp(i).msg_to
                   LOOP
                     l_c_msg_name := get_msg_from_stack(l_curr_num);
                     get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
                     l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');

                     INSERT INTO igs_ps_lgcy_err_int
                      (
                        err_message_id,
                        int_table_code,
                        int_table_id,
                        message_num,
                        message_text,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date)
                     VALUES
                      (
                        igs_ps_lgcy_err_int_s.nextval,
                        igs_ps_validate_lgcy_pkg.get_lkup_meaning('PS_UNIT_DISCP','LEGACY_PS_REC_TABLES'),
                        v_tab_unit_dscp(i).interface_id,
                        l_n_msg_num,
                        l_c_msg_txt,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.login_id,-1),
                        l_n_request_id,
                        l_n_prog_appl_id,
                        l_n_prog_id,
                        l_d_prog_upd_dt
                      );

                    /* Write into log file */

                       log_file(RPAD(v_tab_unit_dscp(i).interface_id,16,' '),'P');
                       log_file(RPAD(l_n_msg_num,15,' '),'P');
                       IF l_n_msg_num IS NULL THEN
                         print_char(15,' ');
                       END IF;
                       log_file(RPAD(igs_ps_validate_lgcy_pkg.get_lkup_meaning(v_tab_unit_dscp(i).status,'LEGACY_STATUS'),10,' '),'P');
                       print_char(1,' ');
                       log_file(l_c_msg_txt,'L');

                   END LOOP; /* Messages loop */
                 END IF;
               END LOOP; /* Unit Disciplines Loop */
               v_tab_unit_dscp.DELETE;
            END IF;

          /******************End Unit Disciplines Log and Error***********************/

          /******************Begin Grading Schema Log and Error**********************/
             l_b_print_row_heading := TRUE;
             IF  v_tab_unit_gs.EXISTS(1) THEN

               IF l_b_print_row_heading AND l_c_return_status = 'S' THEN
                  row_head('PS_GRD_SCH',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                  l_b_print_row_heading := FALSE ;
               END IF;

               FOR i IN 1.. v_tab_unit_gs.LAST
               LOOP

                 IF v_tab_unit_gs(i).status = 'S' AND l_c_return_status = 'S' THEN

                 /* Update the interface table */

                   UPDATE igs_ps_lgcy_ug_int
                   SET import_status = 'I'
                   WHERE batch_id=p_n_batch_id
                   AND uv_grd_schm_int_id = v_tab_unit_gs(i).interface_id;

                 /* Write into log file */

                   log_file(RPAD(v_tab_unit_gs(i).interface_id,31,' '),'P');
                   log_file(RPAD(l_c_import_desc,10,' '),'P');
                   print_char(1,' ');
                   log_file(l_c_succ_desc,'L');

                 ELSIF v_tab_unit_gs(i).status IN ('W','E') THEN

                    IF l_b_print_row_heading THEN
                       row_head('PS_GRD_SCH',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                       l_b_print_row_heading := FALSE ;
                    END IF;

                /* Update the interface table */

                   UPDATE igs_ps_lgcy_ug_int
                   SET import_status = v_tab_unit_gs(i).status
                   WHERE batch_id=p_n_batch_id
                   AND uv_grd_schm_int_id = v_tab_unit_gs(i).interface_id;

                 /* Write into log file */

                   FOR l_curr_num IN v_tab_unit_gs(i).msg_from..v_tab_unit_gs(i).msg_to
                   LOOP
                     l_c_msg_name := get_msg_from_stack(l_curr_num);
                     get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
                     l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');

                     INSERT INTO igs_ps_lgcy_err_int
                      (
                        err_message_id,
                        int_table_code,
                        int_table_id,
                        message_num,
                        message_text,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date)
                     VALUES
                      (
                        igs_ps_lgcy_err_int_s.nextval,
                        igs_ps_validate_lgcy_pkg.get_lkup_meaning('PS_GRD_SCH','LEGACY_PS_REC_TABLES'),
                        v_tab_unit_gs(i).interface_id,
                        l_n_msg_num,
                        l_c_msg_txt,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.login_id,-1),
                        l_n_request_id,
                        l_n_prog_appl_id,
                        l_n_prog_id,
                        l_d_prog_upd_dt
                      );

                    /* Write into log file */

                       log_file(RPAD(v_tab_unit_gs(i).interface_id,16,' '),'P');
                       log_file(RPAD(l_n_msg_num,15,' '),'P');
                       IF l_n_msg_num IS NULL THEN
                         print_char(15,' ');
                       END IF;
                       log_file(RPAD(igs_ps_validate_lgcy_pkg.get_lkup_meaning(v_tab_unit_gs(i).status,'LEGACY_STATUS'),10,' '),'P');
                       print_char(1,' ');
                       log_file(l_c_msg_txt,'L');

                   END LOOP; /* Messages loop */
                 END IF;
               END LOOP; /* Grading Schema Loop */
               v_tab_unit_gs.DELETE;
            END IF;

          /******************End Grading Schema Log and Error***********************/

          /******************Begin Unit Section Log and Error**********************/
             l_b_print_row_heading := TRUE;
             IF  v_tab_usec.EXISTS(1) THEN

                IF l_b_print_row_heading AND l_c_return_status = 'S' THEN
                   row_head('PS_UNIT_REC',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                   l_b_print_row_heading := FALSE ;
                END IF;

               FOR i IN 1.. v_tab_usec.LAST
               LOOP

                 IF v_tab_usec(i).status = 'S' AND l_c_return_status = 'S' THEN

                 /* Update the interface table */

                   UPDATE igs_ps_lgcy_us_int
                   SET import_status = 'I'
                   WHERE batch_id=p_n_batch_id
                   AND unit_section_int_id = v_tab_usec(i).interface_id;

                 /* Write into log file */

                   log_file(RPAD(v_tab_usec(i).interface_id,31,' '),'P');
                   log_file(RPAD(l_c_import_desc,10,' '),'P');
                   print_char(1,' ');
                   log_file(l_c_succ_desc,'L');

                 ELSIF v_tab_usec(i).status IN ('W','E') THEN

                    IF l_b_print_row_heading THEN
                       row_head('PS_UNIT_REC',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                       l_b_print_row_heading := FALSE ;
                    END IF;

                /* Update the interface table */

                   UPDATE igs_ps_lgcy_us_int
                   SET import_status = v_tab_usec(i).status
                   WHERE batch_id=p_n_batch_id
                   AND unit_section_int_id = v_tab_usec(i).interface_id;

                 /* Write into log file */

                   FOR l_curr_num IN v_tab_usec(i).msg_from..v_tab_usec(i).msg_to
                   LOOP
                     l_c_msg_name := get_msg_from_stack(l_curr_num);
                     get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
                     l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');

                     INSERT INTO igs_ps_lgcy_err_int
                      (
                        err_message_id,
                        int_table_code,
                        int_table_id,
                        message_num,
                        message_text,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date)
                     VALUES
                      (
                        igs_ps_lgcy_err_int_s.nextval,
                        igs_ps_validate_lgcy_pkg.get_lkup_meaning('PS_UNIT_SEC','LEGACY_PS_REC_TABLES'),
                        v_tab_usec(i).interface_id,
                        l_n_msg_num,
                        l_c_msg_txt,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.login_id,-1),
                        l_n_request_id,
                        l_n_prog_appl_id,
                        l_n_prog_id,
                        l_d_prog_upd_dt
                      );

                    /* Write into log file */

                       log_file(RPAD(v_tab_usec(i).interface_id,16,' '),'P');
                       log_file(RPAD(l_n_msg_num,15,' '),'P');
                       IF l_n_msg_num IS NULL THEN
                       print_char(15,' ');
                       END IF;
                       log_file(RPAD(igs_ps_validate_lgcy_pkg.get_lkup_meaning(v_tab_usec(i).status,'LEGACY_STATUS'),10,' '),'P');
                       print_char(1,' ');
                       log_file(l_c_msg_txt,'L');

                   END LOOP; /* Messages loop */
                 END IF;
               END LOOP; /* Unit Section Loop */
               v_tab_usec.DELETE;
            END IF;

          /******************End Unit Section Log and Error***********************/

          /******************Begin Unit Section Grading Schema Log and Error**********************/

             l_b_print_row_heading := TRUE;
             IF  v_tab_usec_gs.EXISTS(1) THEN

               IF l_b_print_row_heading AND l_c_return_status = 'S' THEN
                 row_head('PS_UNIT_GRD_SCH',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                 l_b_print_row_heading := FALSE ;
               END IF;

               FOR i IN 1.. v_tab_usec_gs.LAST
               LOOP

                 IF v_tab_usec_gs(i).status = 'S' AND l_c_return_status = 'S' THEN

                 /* Update the interface table */

                   UPDATE igs_ps_lgcy_sg_int
                   SET import_status = 'I'
                   WHERE batch_id=p_n_batch_id
                   AND usec_grd_schm_int_id = v_tab_usec_gs(i).interface_id;

                 /* Write into log file */

                   log_file(RPAD(v_tab_usec_gs(i).interface_id,31,' '),'P');
                   log_file(RPAD(l_c_import_desc,10,' '),'P');
                   print_char(1,' ');
                   log_file(l_c_succ_desc,'L');

                 ELSIF v_tab_usec_gs(i).status IN ('W','E') THEN

                   IF l_b_print_row_heading THEN
                     row_head('PS_UNIT_GRD_SCH',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                     l_b_print_row_heading := FALSE ;
                   END IF;

                /* Update the interface table */

                   UPDATE igs_ps_lgcy_sg_int
                   SET import_status = v_tab_usec_gs(i).status
                   WHERE batch_id=p_n_batch_id
                   AND usec_grd_schm_int_id = v_tab_usec_gs(i).interface_id;

                 /* Write into log file */

                   FOR l_curr_num IN v_tab_usec_gs(i).msg_from..v_tab_usec_gs(i).msg_to
                   LOOP
                     l_c_msg_name := get_msg_from_stack(l_curr_num);
                     get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
                     l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');

                     INSERT INTO igs_ps_lgcy_err_int
                      (
                        err_message_id,
                        int_table_code,
                        int_table_id,
                        message_num,
                        message_text,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date
                      )
                     VALUES
                      (
                        igs_ps_lgcy_err_int_s.nextval,
                        igs_ps_validate_lgcy_pkg.get_lkup_meaning('PS_UNIT_GRD_SCH','LEGACY_PS_REC_TABLES'),
                        v_tab_usec_gs(i).interface_id,
                        l_n_msg_num,
                        l_c_msg_txt,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.login_id,-1),
                        l_n_request_id,
                        l_n_prog_appl_id,
                        l_n_prog_id,
                        l_d_prog_upd_dt
                      );

                    /* Write into log file */

                       log_file(RPAD(v_tab_usec_gs(i).interface_id,16,' '),'P');
                       log_file(RPAD(l_n_msg_num,15,' '),'P');
                       IF l_n_msg_num IS NULL THEN
                         print_char(15,' ');
                       END IF;
                       log_file(RPAD(igs_ps_validate_lgcy_pkg.get_lkup_meaning(v_tab_usec_gs(i).status,'LEGACY_STATUS'),10,' '),'P');
                       print_char(1,' ');
                       log_file(l_c_msg_txt,'L');

                   END LOOP; /* Messages loop */
                 END IF;
               END LOOP; /* Unit Section Grading Schema Loop */
                      v_tab_usec_gs.DELETE;
            END IF;

           /******************End Unit Section Grading Schema Log and Error***********************/

          /******************Begin Unit Section Occurrences Log and Error**********************/
             l_b_print_row_heading := TRUE;
             IF  v_tab_uso.EXISTS(1) THEN

               IF l_b_print_row_heading AND l_c_return_status = 'S' THEN
                 row_head('PS_UNIT_SEC_OCCUR',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                 l_b_print_row_heading := FALSE ;
               END IF;

               FOR i IN 1.. v_tab_uso.LAST
               LOOP

                 IF v_tab_uso(i).status = 'S' AND l_c_return_status = 'S' THEN

                 /* Update the interface table */

                   UPDATE igs_ps_lgcy_oc_int
                   SET import_status = 'I'
                   WHERE batch_id=p_n_batch_id
                   AND usec_occur_int_id = v_tab_uso(i).interface_id;

                 /* Write into log file */

                   log_file(RPAD(v_tab_uso(i).interface_id,31,' '),'P');
                   log_file(RPAD(l_c_import_desc,10,' '),'P');
                   print_char(1,' ');
                   log_file(l_c_succ_desc,'L');

                 ELSIF v_tab_uso(i).status IN ('W','E') THEN

                   IF l_b_print_row_heading THEN
                     row_head('PS_UNIT_SEC_OCCUR',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                     l_b_print_row_heading := FALSE ;
                   END IF;

                /* Update the interface table */

                   UPDATE igs_ps_lgcy_oc_int
                   SET import_status = v_tab_uso(i).status
                   WHERE batch_id=p_n_batch_id
                   AND usec_occur_int_id = v_tab_uso(i).interface_id;

                 /* Write into log file */

                   FOR l_curr_num IN v_tab_uso(i).msg_from..v_tab_uso(i).msg_to
                   LOOP
                     l_c_msg_name := get_msg_from_stack(l_curr_num);
                     get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
                     l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');

                     INSERT INTO igs_ps_lgcy_err_int
                      (
                        err_message_id,
                        int_table_code,
                        int_table_id,
                        message_num,
                        message_text,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date)
                     VALUES
                      (
                        igs_ps_lgcy_err_int_s.nextval,
                        igs_ps_validate_lgcy_pkg.get_lkup_meaning('PS_UNIT_SEC_OCCUR','LEGACY_PS_REC_TABLES'),
                         v_tab_uso(i).interface_id,
                        l_n_msg_num,
                        l_c_msg_txt,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.login_id,-1),
                        l_n_request_id,
                        l_n_prog_appl_id,
                        l_n_prog_id,
                        l_d_prog_upd_dt
                      );

                    /* Write into log file */

                       log_file(RPAD(v_tab_uso(i).interface_id,16,' '),'P');
                       log_file(RPAD(l_n_msg_num,15,' '),'P');
                       IF l_n_msg_num IS NULL THEN
                         print_char(15,' ');
                       END IF;
                       log_file(RPAD(igs_ps_validate_lgcy_pkg.get_lkup_meaning(v_tab_uso(i).status,'LEGACY_STATUS'),10,' '),'P');
                       print_char(1,' ');
                       log_file(l_c_msg_txt,'L');

                   END LOOP; /* Messages loop */
                 END IF;
               END LOOP; /* Unit Section Occurrences Loop */
               v_tab_uso.DELETE;
            END IF;

          /******************End Unit Section Occurrences Log and Error***********************/

          /******************Begin Unit Reference Code Log and Error**********************/
             l_b_print_row_heading := TRUE;
             IF  v_tab_unit_ref.EXISTS(1) THEN

               IF l_b_print_row_heading AND l_c_return_status = 'S' THEN
                 row_head('PS_UNIT_REF',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                 l_b_print_row_heading := FALSE ;
               END IF;

               FOR i IN 1.. v_tab_unit_ref.LAST
               LOOP

                 IF v_tab_unit_ref(i).status = 'S' AND l_c_return_status = 'S' THEN

                 /* Update the interface table */

                   UPDATE igs_ps_lgcy_ur_int
                   SET import_status = 'I'
                   WHERE batch_id=p_n_batch_id
                   AND unit_reference_int_id = v_tab_unit_ref(i).interface_id;

                 /* Write into log file */

                   log_file(RPAD(v_tab_unit_ref(i).interface_id,31,' '),'P');
                   log_file(RPAD(l_c_import_desc,10,' '),'P');
                   print_char(1,' ');
                   log_file(l_c_succ_desc,'L');

                 ELSIF v_tab_unit_ref(i).status IN ('W','E') THEN

                   IF l_b_print_row_heading THEN
                     row_head('PS_UNIT_REF',rec_c_all_units.unit_cd,rec_c_all_units.version_number);
                     l_b_print_row_heading := FALSE ;
                   END IF;

                /* Update the interface table */

                   UPDATE igs_ps_lgcy_ur_int
                   SET import_status = v_tab_unit_ref(i).status
                   WHERE batch_id=p_n_batch_id
                   AND unit_reference_int_id = v_tab_unit_ref(i).interface_id;

                 /* Write into log file */

                   FOR l_curr_num IN v_tab_unit_ref(i).msg_from..v_tab_unit_ref(i).msg_to
                   LOOP
                     l_c_msg_name := get_msg_from_stack(l_curr_num);
                     get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
                     l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');

                     INSERT INTO igs_ps_lgcy_err_int
                      (
                        err_message_id,
                        int_table_code,
                        int_table_id,
                        message_num,
                        message_text,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date)
                     VALUES
                      (
                        igs_ps_lgcy_err_int_s.nextval,
                        igs_ps_validate_lgcy_pkg.get_lkup_meaning('PS_UNIT_REF','LEGACY_PS_REC_TABLES'),
                        v_tab_unit_ref(i).interface_id,
                        l_n_msg_num,
                        l_c_msg_txt,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.user_id,-1),
                        SYSDATE,
                        NVL(fnd_global.login_id,-1),
                        l_n_request_id,
                        l_n_prog_appl_id,
                        l_n_prog_id,
                        l_d_prog_upd_dt
                      );

                    /* Write into log file */

                       log_file(RPAD(v_tab_unit_ref(i).interface_id,16,' '),'P');
                       log_file(RPAD(l_n_msg_num,15,' '),'P');
                       IF l_n_msg_num IS NULL THEN
                         print_char(15,' ');
                       END IF;
                       log_file(RPAD(igs_ps_validate_lgcy_pkg.get_lkup_meaning(v_tab_unit_ref(i).status,'LEGACY_STATUS'),10,' '),'P');
                       print_char(1,' ');
                       log_file(l_c_msg_txt,'L');

                   END LOOP; /* Messages loop */
                 END IF;
               END LOOP; /* Unit References Code Loop */
               v_tab_unit_ref.DELETE;
            END IF;

          /******************End Unit Reference Code Log and Error***********************/

          /******************Begin Instructor Log and Error**********************/
           l_b_print_row_heading := TRUE;
           IF v_tab_ins.EXISTS(1) THEN

               IF l_b_print_row_heading AND l_c_return_status = 'S' THEN
                  log_file(' ','N');
                  get_message('IGS_EN_ROW_TYPE',l_n_msg_num,l_c_msg_txt);
                  log_file(l_c_msg_txt,'P');
                  log_file(' ','P');
		  fnd_message.set_name('IGS','IGS_PS_USO_INS');
                  log_file(fnd_message.get,'P');
                  log_file(' ','P');
                  log_file(igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_CD','LEGACY_TOKENS'),'P');
                  log_file(' : ','P');
                  log_file(rec_c_all_units.unit_cd,'P');
                  log_file(' ','P');
                  log_file(igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_VER_NUM','LEGACY_TOKENS'),'P');
                  log_file(' : ','P');
                  log_file(rec_c_all_units.version_number,'L');
                  log_file(' ','N');
                  l_b_print_row_heading := FALSE ;
               END IF;

               FOR i IN 1.. v_tab_ins.LAST LOOP
                   IF v_tab_ins(i).status = 'S' AND l_c_return_status = 'S' THEN

		        /* Update the interface table */

                        UPDATE igs_ps_lgcy_ins_int
                        SET import_status = 'I'
                        WHERE batch_id=p_n_batch_id
                        AND uso_instructor_int_id = v_tab_ins(i).interface_id;

		        /* Write into log file */

		        log_file(RPAD(v_tab_ins(i).interface_id,31,' '),'P');
                        log_file(RPAD(l_c_import_desc,10,' '),'P');
		        print_char(1,' ');
                        log_file(l_c_succ_desc,'L');

                   ELSIF v_tab_ins(i).status IN ('W','E') THEN

                         IF l_b_print_row_heading THEN
                            log_file(' ','N');
                            get_message('IGS_EN_ROW_TYPE',l_n_msg_num,l_c_msg_txt);
                            log_file(l_c_msg_txt,'P');
                            log_file(' ','P');
		            fnd_message.set_name('IGS','IGS_PS_USO_INS');
                            log_file(fnd_message.get,'P');
                            log_file(' ','P');
                            log_file(igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_CD','LEGACY_TOKENS'),'P');
                            log_file(' : ','P');
                            log_file(rec_c_all_units.unit_cd,'P');
                            log_file(' ','P');
                            log_file(igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_VER_NUM','LEGACY_TOKENS'),'P');
                            log_file(' : ','P');
                            log_file(rec_c_all_units.version_number,'L');
                            log_file(' ','N');
                            l_b_print_row_heading := FALSE ;
                         END IF;

                         /* Update the interface table */

		         UPDATE igs_ps_lgcy_ins_int
                         SET import_status = v_tab_ins(i).status
                         WHERE batch_id=p_n_batch_id
                         AND uso_instructor_int_id = v_tab_ins(i).interface_id;

                         /* Write into log file */

                        FOR l_curr_num IN v_tab_ins(I).msg_from..v_tab_ins(I).msg_to LOOP

                             l_c_msg_name := get_msg_from_stack(l_curr_num);
                             get_message(l_c_msg_name,l_n_msg_num,l_c_msg_txt);
                             l_c_msg_txt := fnd_msg_pub.get(l_curr_num,'F');

                             fnd_message.set_name('IGS','IGS_PS_USO_INS_TBL_NAME');

                             INSERT INTO igs_ps_lgcy_err_int(
                                   err_message_id,
                                   int_table_code,
                                   int_table_id,
                                   message_num,
                                   message_text,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login,
                                   request_id,
                                   program_application_id,
                                   program_id,
                                   program_update_date
                                   ) VALUES(
                                   igs_ps_lgcy_err_int_s.nextval,
				   fnd_message.get,
                                   v_tab_ins(i).interface_id,
                                   l_n_msg_num,
                                   l_c_msg_txt,
                                   NVL(fnd_global.user_id,-1),
                                   SYSDATE,
                                   NVL(fnd_global.user_id,-1),
                                   SYSDATE,
                                   NVL(fnd_global.login_id,-1),
                                   l_n_request_id,
                                   l_n_prog_appl_id,
                                   l_n_prog_id,
                                   l_d_prog_upd_dt);

                                 /* Write into log file */

		               log_file(RPAD(v_tab_ins(i).interface_id,16,' '),'P');
                               log_file(RPAD(l_n_msg_num,15,' '),'P');

		               IF l_n_msg_num IS NULL THEN
                                    print_char(15,' ');
                               END IF;

		               log_file( RPAD( igs_ps_validate_lgcy_pkg.get_lkup_meaning(v_tab_ins(i).status, 'LEGACY_STATUS'),10,' '),'P');
                               print_char(1,' ');
                               log_file(l_c_msg_txt,'L');

                         END LOOP;
                        /* Messages loop */
                    END IF;
                END LOOP;
                v_tab_ins.DELETE;
           END IF;


          /******************End Instructor Log and Error***********************/

   END LOOP; /* Main loop - c_all_units cursor*/

 /* Delete imported records if user wishes to delete by passing the parameter p_delete='Y' */

         IF p_c_del_flag='Y' AND l_c_return_status = 'S' THEN

            /* Delete from Unit Version Interface Table */

            DELETE FROM igs_ps_lgcy_uv_int
            WHERE batch_id=p_n_batch_id
            AND import_status = 'I';

                /* Delete from Teaching Responsibility Interface Table */

            DELETE FROM igs_ps_lgcy_tr_int
            WHERE batch_id=p_n_batch_id
            AND import_status = 'I';

                /* Delete from Unit Disciplines Interface Table */

            DELETE FROM igs_ps_lgcy_ud_int
            WHERE batch_id=p_n_batch_id
            AND import_status = 'I';

                /* Delete from Grading Schema Interface Table */

            DELETE FROM igs_ps_lgcy_ug_int
            WHERE batch_id=p_n_batch_id
            AND import_status = 'I';

                /* Delete from Unit Section Interface Table */

            DELETE FROM igs_ps_lgcy_us_int
            WHERE batch_id=p_n_batch_id
            AND import_status = 'I';

                /* Delete from Unit Section Grading Schema Interface Table */

            DELETE FROM igs_ps_lgcy_sg_int
            WHERE batch_id=p_n_batch_id
            AND import_status = 'I';

                /* Delete from Unit Section Occurrences Interface Table */

            DELETE FROM igs_ps_lgcy_oc_int
            WHERE batch_id=p_n_batch_id
            AND import_status = 'I';

                /* Delete from Unit Reference Codes Table */

            DELETE FROM igs_ps_lgcy_ur_int
            WHERE batch_id=p_n_batch_id
            AND import_status = 'I';

                /* Delete from Instructor Table */

            DELETE FROM igs_ps_lgcy_ins_int
            WHERE batch_id=p_n_batch_id
            AND import_status = 'I';

         END If;

/*  If none of the interface tables has not appropriate data that is to be processed, then set the message and error out */
        IF l_c_return_status IS NULL THEN
          get_message('IGS_PS_LGCY_DATA_NOT_PASSED',l_n_msg_num,l_c_msg_txt);
          log_file(l_c_msg_txt,'L');
          retcode := 2;
          RETURN;
	ELSE
	      print_char(80,'=');
        END IF;

        -- Set the concurrent program status to Error if the API return status is Error for all the attempted records

        IF l_ret_status THEN
          retcode:=2;
        END IF;

     -- End of Procedure
  EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK;
       retcode:=2;
       fnd_file.put_line(fnd_file.log,sqlerrm);
       errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') ;
       igs_ge_msg_stack.conc_exception_hndl;

  END legacy_batch_process;

END igs_ps_lgcy_conc_pkg;

/
