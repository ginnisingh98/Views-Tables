--------------------------------------------------------
--  DDL for Package Body IGS_EN_DASHBOARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_DASHBOARD" AS
/* $Header: IGSENB2B.pls 120.10 2006/03/13 23:06:48 smaddali noship $ */

  -- Function to get the message text for the given message name
 FUNCTION get_message(p_c_msg IN VARCHAR2) RETURN VARCHAR2 ;

  -- contains the translated message text as Schedule
 g_c_schedule_txt  CONSTANT  VARCHAR2(500) := get_message('IGS_EN_SCHEDULE');

  -- contains the translated message text as Planning Sheet
 g_c_planning_txt  CONSTANT VARCHAR2(500) := get_message ('IGS_EN_PLANNING_SHEET') ;

  -- contains the translated message text for View Only
 g_c_view_only_txt CONSTANT  VARCHAR2(500) := get_message('IGS_EN_VIEW_ONLY');

  -- contains the translated message text for Enrollment Now Open
 g_c_enr_open_txt  CONSTANT  VARCHAR2(500) := get_message('IGS_EN_SCHEDULE_OPEN') ;

 -- Function to get the message text for the given message name
 FUNCTION get_message(p_c_msg IN VARCHAR2) RETURN VARCHAR2 IS
 ------------------------------------------------------------------------------------
    --Created by  : Somasekar ( Oracle IDC)
    --Date created: 17-MAY-2005
    --
    --Purpose: this function returns translated message
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
 --------------------------------------------------------------------------------------
   BEGIN
        Fnd_message.set_name('IGS', p_c_msg);
   RETURN Fnd_message.get;
 END get_message;

 PROCEDURE student_api (  p_n_person_id IN NUMBER,
                            p_c_person_type IN VARCHAR2,
                            p_text_tbl    OUT NOCOPY LINK_TEXT_TYPE,
                            p_cal_tbl     OUT NOCOPY CAL_TYPE,
                            p_seq_tbl     OUT NOCOPY SEQ_NUM_TYPE,
                            p_car_tbl     OUT NOCOPY PRG_CAR_TYPE,
                            p_typ_tbl     OUT NOCOPY PLAN_SCHED_TYPE,
                            p_sch_allow   OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------------------------
    --Created by  : Somasekar ( Oracle IDC)
    --Date created: 17-MAY-2005
    --
    --Purpose: this function returns the table for the student
    --                to render the links in the home page.
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --stutta   26-Oct-2005     Plan sheet link should not be displayed only when ther
    --                         schedule is available and there are no units in plan.
    --                         bug #4665592
 --------------------------------------------------------------------------------------

     -- Cursor to get career related information.
     -- Used in career mode.
     CURSOR c_career (cp_n_person_id IN NUMBER) IS
      SELECT distinct pv.course_type career,
             sca.course_cd program_cd,
             sca.version_number program_version,
             ci.cal_type LoadCal,
             ci.sequence_number sequence_number,
             ci.description description,
             ci.start_dt start_dt,
             ci.planning_flag  planning_flag,
              ci.schedule_flag  schedule_flag
      FROM   igs_en_stdnt_ps_att_all sca,
             igs_ca_inst_all ci,
             igs_ca_type ca,
             igs_ca_stat cs,
             igs_ca_inst_rel car,
             igs_ps_ver_all pv
      WHERE  sca.person_id = cp_n_person_id
      AND    sca.course_cd = pv.course_cd
      AND    sca.version_number = pv.version_number
      AND    sca.course_attempt_status IN ('ENROLLED','INACTIVE', 'INTERMIT')
      AND    sca.cal_type = car.sup_cal_type
      AND    car.sub_cal_type  = ci.cal_type
      AND    car.sub_ci_sequence_number  = ci.sequence_number
      AND    ci.cal_type = ca.cal_type
      AND    ca.s_cal_cat = 'LOAD'
      AND    ci.cal_status = cs.cal_status
      AND    (  ci.schedule_flag  ='Y' OR  ci.planning_flag ='Y')
      AND    cs.s_cal_status = 'ACTIVE'
      AND    ca.closed_ind = 'N'
      AND    igs_en_spa_terms_api.get_spat_primary_prg(sca.person_id, sca.course_cd, ci.cal_type,ci.sequence_number)='PRIMARY'
      ORDER BY ci.start_dt desc;

     -- Cursor to get program related information
     -- Used in program mode.
     CURSOR c_program (cp_n_person_id IN NUMBER) IS
       SELECT distinct sca.course_cd program_cd,
              sca.version_number program_version,
              cai.cal_type LoadCal,
              cai.sequence_number sequence_number,
              cai.description description,
              cai.start_dt start_dt,
               cai.planning_flag  planning_flag,
               cai.schedule_flag  schedule_flag
       FROM IGS_EN_STDNT_PS_ATT_ALL sca,
            IGS_CA_INST_REL car,
            IGS_CA_INST_ALL cai,
            IGS_CA_TYPE ca,
            IGS_CA_STAT cs
       WHERE sca.person_id = cp_n_person_id
       AND   sca.course_attempt_status IN ('ENROLLED','INACTIVE', 'INTERMIT')
       AND   sca.cal_type =car.sup_cal_type
       AND   cai.cal_type = car.sub_cal_type
       AND   cai.SEQUENCE_NUMBER = car.sub_ci_sequence_number
       AND   cai.cal_type = ca.cal_type
       AND   ca.s_cal_cat = 'LOAD'
       AND    (  cai.planning_flag  ='Y' OR  cai.schedule_flag ='Y')
       AND   ca.closed_ind = 'N'
       AND   cai.cal_status = cs.cal_status
       AND   cs.s_cal_status = 'ACTIVE'
       ORDER BY cai.start_dt;

     -- Cursor to determine whether finds unit section to be rendered or not.
     CURSOR c_srch_allwd  IS
       SELECT 1
       FROM IGS_CA_INST_ALL ci,
            IGS_CA_TYPE ca,
            IGS_CA_STAT cs
       WHERE ci.ss_displayed = 'Y'
       AND   ci.cal_type = ca.cal_type
       AND   ca.s_cal_cat = 'LOAD'
       AND   ci.cal_status = cs.cal_status
       AND   ca.closed_ind = 'N'
       AND   cs.s_cal_status = 'ACTIVE'       AND   ROWNUM <2;

    -- Cursor to get the status (active/submitted/skipped) of the planning sheet
     CURSOR c_plan_status (cp_n_person_id in NUMBER,
                          cp_c_program IN VARCHAR2,
                          cp_c_cal_type in VARCHAR2,
                          cp_n_seq_num IN NUMBER) IS
       SELECT PLAN_SHT_STATUS
       FROM   igs_en_spa_terms
       WHERE  person_id = cp_n_person_id
       AND    program_cd = cp_c_program
       AND    term_cal_type = cp_c_cal_type
       AND    term_sequence_number = cp_n_seq_num;

     -- Cursor to check whether student has unit section in planning sheet for term and career / program
     CURSOR c_plan_exists (cp_n_person_id IN NUMBER,
                           cp_c_program_cd IN VARCHAR2,
                           cp_c_cal_type IN VARCHAR2,
                           cp_n_seq_num IN NUMBER) IS
       SELECT 1
       FROM   IGS_EN_PLAN_UNITS plan
       WHERE  plan.person_id = cp_n_person_id
       AND    plan.course_cd = cp_c_program_cd
       AND    plan.term_cal_type = cp_c_cal_type
       AND    plan.term_ci_sequence_number = cp_n_seq_num
       AND cart_error_flag='N'
       AND    ROWNUM <2;

     CURSOR c_cal_conf IS
      SELECT planning_open_dt_alias, schedule_open_dt_alias
      FROM   igs_en_cal_conf
      WHERE  s_control_num = 1;
       l_plan_dalias igs_en_cal_conf.planning_open_dt_alias %TYPE;
       l_sch_dalias igs_en_cal_conf.schedule_open_dt_alias%TYPE;

     i NUMBER;
     l_n_temp NUMBER;
     l_d_alias_val DATE;
     l_c_plan_status igs_en_spa_terms.PLAN_SHT_STATUS%TYPE;
     l_schedule_available BOOLEAN := FALSE;
     l_schedule_units_exists BOOLEAN := FALSE;
     l_plan_exists BOOLEAN := FALSE;

 BEGIN
     -- Decide whether search is allowed or not.
     -- Even if search is allowed for a term then the find unit section link should be rendered.

     OPEN c_srch_allwd;
     FETCH c_srch_allwd INTO l_n_temp;
     IF c_srch_allwd%FOUND THEN
        p_sch_allow := 'Y' ; -- Search is allowed
     ELSE
        p_sch_allow := 'N'; -- Search is not allowed
     END IF;
     CLOSE c_srch_allwd;

     -- Initialize the local variables
     i:= 0;

   -- get the planning sheet and schedule alias
     OPEN c_cal_conf;
     FETCH c_cal_conf  INTO    l_plan_dalias, l_sch_dalias;
     CLOSE c_cal_conf;

     --Deciding career mode or program mode
     IF( fnd_profile.value('CAREER_MODEL_ENABLED') = 'Y') THEN
       -- Career mode
       -- Loop thru all the distinct term career combinations
       FOR rec_career IN c_career(p_n_person_id)
        LOOP
          l_schedule_available := FALSE;
          IF rec_career.schedule_flag = 'Y' THEN
                -- get the schedule alias value for the current term.
            l_d_alias_val := igs_ss_enr_details.get_alias_val(rec_career.loadcal, rec_career.sequence_number, l_sch_dalias);
            -- Check whether the planning sheet date alias value is greater than or equal to sysdate
            IF l_d_alias_val IS NOT NULL AND TRUNC (l_d_alias_val) <= TRUNC (SYSDATE) THEN
                l_schedule_available := TRUE;
            END IF;
          END IF;
         -- Check whether the planning sheet profile is ON and planning is allowed for the current term
          IF rec_career.planning_flag = 'Y' AND
              NVL(fnd_profile.value('IGS_EN_USE_PLAN'),'OFF') = 'ON'    THEN

              l_d_alias_val := igs_ss_enr_details.get_alias_val( rec_career.loadcal, rec_career.sequence_number,    l_plan_dalias);

              -- Check whether the planning sheet date alias value is greater than or equal to sysdate
            IF l_d_alias_val IS NOT NULL AND TRUNC (l_d_alias_val) <= TRUNC (SYSDATE) THEN
             -- Add the calendar instance, career and Planning (P)/Schedule (S).
              i:= i+1;
              p_cal_tbl(i) := rec_career.loadcal;
              p_seq_tbl(i) := rec_career.sequence_number;
              p_car_tbl(i) := rec_career.career;
              p_typ_tbl(i) := 'P';    -- active planning sheet.

              -- Check whether the planning sheet exists for this person, and if exists check
              -- whether it is submitted or skipped based on the value in the column PLAN_SHT_FLAG

              OPEN c_plan_status (p_n_person_id, rec_career.program_cd, rec_career.loadcal,
              rec_career.sequence_number);
              FETCH c_plan_status INTO l_c_plan_status;
              IF c_plan_status%NOTFOUND THEN
               l_c_plan_status := 'PLAN';
              END IF;
              CLOSE c_plan_status;

              OPEN c_plan_exists(p_n_person_id, rec_career.program_cd, rec_career.loadcal, rec_career.sequence_number);
              FETCH c_plan_exists INTO l_n_temp;
              IF c_plan_exists%FOUND THEN
                l_plan_exists := TRUE;
              ELSE
                l_plan_exists := FALSE;
              END IF;
              CLOSE c_plan_exists;

              l_schedule_units_exists := Schedule_Units_Exists(p_n_person_id, rec_career.program_cd, rec_career.loadcal, rec_career.sequence_number);

		IF l_schedule_available THEN
		  IF l_schedule_units_exists THEN
		    IF l_plan_exists THEN
                        p_text_tbl(i) := g_c_planning_txt || ' ' || rec_career.description || ' - ' || rec_career.career || ' - ' || g_c_view_only_txt;
                        p_typ_tbl(i) := 'V'; -- planning sheet is view only.
		    ELSE
		      i:= i - 1;
		    END IF;
		  ELSE
		    IF l_plan_exists THEN
		      IF l_c_plan_status IN ('PLAN','NONE') THEN
                      	p_text_tbl(i) := g_c_planning_txt || ' ' || rec_career.description || ' - ' || rec_career.career;
		      ELSE
			p_text_tbl(i) := g_c_planning_txt || ' ' || rec_career.description || ' - ' || rec_career.career || ' - ' || g_c_view_only_txt;
                        p_typ_tbl(i) := 'V'; -- planning sheet is view only.
		      END IF;
		    ELSE
		      i:= i - 1;
		    END IF;
		  END IF;
		ELSE
		  IF l_schedule_units_exists THEN
                    p_text_tbl(i) := g_c_planning_txt || ' ' || rec_career.description || ' - ' || rec_career.career || ' - ' || g_c_view_only_txt;
                    p_typ_tbl(i) := 'V'; -- planning sheet is view only.
		  ELSE
		    IF l_c_plan_status IN ('PLAN','NONE') THEN
		      p_text_tbl(i) := g_c_planning_txt || ' ' || rec_career.description || ' - ' || rec_career.career;
		    ELSE
                        p_text_tbl(i) := g_c_planning_txt || ' ' || rec_career.description || ' - ' || rec_career.career || ' - ' || g_c_view_only_txt;
                        p_typ_tbl(i) := 'V'; -- planning sheet is view only.
		    END IF;
		  END IF;
		END IF;

            END IF; -- end of date alias validation
          END IF;    -- end of planning sheet allowed validation

          -- Check whether the schedule is allowed for the current term
          IF l_schedule_available THEN
                 -- Check whether student has timeslot and
              IF igs_ss_enr_details.stu_timeslot_open (p_n_person_id, p_c_person_type,
                                      rec_career.program_cd, rec_career.loadcal, rec_career.sequence_number) THEN
                 -- Add the calendar instance, career and Planning (P)/Schedule (S).
                 i := i+1;
                 P_cal_tbl(i) := rec_career.loadcal;
                 P_seq_tbl(i) := rec_career.sequence_number;
                 p_car_tbl(i) := rec_career.career;
                 p_typ_tbl(i) := 'S';
                 P_text_tbl(i) := g_c_schedule_txt || ' ' || rec_career.description || ' - ' || rec_career.career || ' - ' || g_c_enr_open_txt;
              END IF;
          END IF;
        END LOOP;
     ELSE
        -- Program mode is enabled.
       FOR rec_program in c_program (p_n_person_id)
        LOOP
          l_schedule_available := FALSE;
          IF rec_program.schedule_flag = 'Y' THEN
            -- get the schedule alias value for the current term.
            l_d_alias_val := igs_ss_enr_details.get_alias_val(rec_program.loadcal, rec_program.sequence_number, l_sch_dalias);
            -- Check whether the planning sheet date alias value is greater than or equal to sysdate
            IF l_d_alias_val IS NOT NULL AND TRUNC(l_d_alias_val) <= TRUNC(SYSDATE)   THEN
                l_schedule_available := TRUE;
            END IF;
          END IF;
          -- Check whether the planning sheet profile is ON and planning is allowed for the current term
          IF rec_program.planning_flag = 'Y' AND  NVL(fnd_profile.value('IGS_EN_USE_PLAN'),'OFF') = 'ON'
            THEN
             -- get the planning sheet alias value for the current term.
             l_d_alias_val := igs_ss_enr_details.get_alias_val(rec_program.loadcal, rec_program.sequence_number, l_plan_dalias);
             -- Check whether the planning sheet date alias value is greater than or equal to sysdate
             IF l_d_alias_val IS NOT NULL AND TRUNC (l_d_alias_val) <= TRUNC (SYSDATE) THEN
                 -- Add the calendar instance, career and Planning (P)/Schedule (S).
                 i:= i+1;
                 p_cal_tbl(i) := rec_program.loadcal;
                 p_seq_tbl(i) := rec_program.sequence_number;
                 p_car_tbl(i) := rec_program.program_cd;
                 p_typ_tbl(i) := 'P';

                 -- Check whether the planning sheet exists for this person,  and if exists check
                 -- whether it is submitted or skipped based on the value in the column PLAN_SHT_FLAG
                 OPEN c_plan_status (p_n_person_id, rec_program.program_cd, rec_program.loadcal, rec_program.sequence_number);
                 FETCH c_plan_status INTO l_c_plan_status;
                 IF c_plan_status%NOTFOUND THEN
                   l_c_plan_status := 'PLAN';
                 END IF;
                 CLOSE c_plan_status;

                 OPEN c_plan_exists (p_n_person_id, rec_program.program_cd,  rec_program.loadcal, rec_program.sequence_number);
                 FETCH c_plan_exists INTO l_n_temp;
                 IF c_plan_exists%FOUND THEN
                   l_plan_exists := TRUE;
                 ELSE
                   l_plan_exists := FALSE;
                  END IF;
                  CLOSE c_plan_exists;

                 l_schedule_units_exists := Schedule_Units_Exists(p_n_person_id, rec_program.program_cd, rec_program.loadcal, rec_program.sequence_number);

		IF l_schedule_available THEN
		  IF l_schedule_units_exists THEN
		    IF l_plan_exists THEN
			    P_text_tbl(i) := g_c_planning_txt || ' ' || rec_program.description || ' - ' || rec_program.program_cd || ' - ' || g_c_view_only_txt;
			    P_typ_tbl(i) := 'V'; -- Denotes planning sheet is view only.
		    ELSE
		      i:= i - 1;
		    END IF;
		  ELSE
		    IF l_plan_exists THEN
		      IF l_c_plan_status IN ('PLAN','NONE') THEN
                            P_text_tbl(i) := g_c_planning_txt || ' ' || rec_program.description || ' - ' || rec_program.program_cd;
		      ELSE
			    P_text_tbl(i) := g_c_planning_txt || ' ' || rec_program.description || ' - ' || rec_program.program_cd || ' - ' || g_c_view_only_txt;
			    P_typ_tbl(i) := 'V'; -- Denotes planning sheet is view only.
		      END IF;
		    ELSE
		      i:= i - 1;
		    END IF;
		  END IF;
		ELSE
		  IF l_schedule_units_exists THEN
		    P_text_tbl(i) := g_c_planning_txt || ' ' || rec_program.description || ' - ' || rec_program.program_cd || ' - ' || g_c_view_only_txt;
		    P_typ_tbl(i) := 'V'; -- Denotes planning sheet is view only.
		  ELSE
		    IF l_c_plan_status IN ('PLAN','NONE') THEN
			  P_text_tbl(i) := g_c_planning_txt || ' ' || rec_program.description || ' - ' || rec_program.program_cd;
		    ELSE
			    P_text_tbl(i) := g_c_planning_txt || ' ' || rec_program.description || ' - ' || rec_program.program_cd || ' - ' || g_c_view_only_txt;
			    P_typ_tbl(i) := 'V'; -- Denotes planning sheet is view only.
		    END IF;
		  END IF;
		END IF;

             END IF;
          END IF;
          -- Check whether the schedule is allowed for the current term
          IF l_schedule_available THEN
               -- Check whether student has timeslot and
              IF igs_ss_enr_details.stu_timeslot_open (p_n_person_id, p_c_person_type,
                   rec_program.program_cd,  rec_program.loadcal, rec_program.sequence_number) THEN
                -- Add the calendar instance, career and Planning (P)/Schedule (S).
                i := i+1;
                p_cal_tbl(i) := rec_program.loadcal;
                P_seq_tbl(i) := rec_program.sequence_number;
                P_car_tbl(i) := rec_program.program_cd;
                p_typ_tbl(i) := 'S';
                P_text_tbl(i) := g_c_schedule_txt || ' ' || rec_program.description || ' - ' || rec_program.program_cd || ' - ' || g_c_enr_open_txt;
              END IF;
          END IF;
        END LOOP;
     END IF;

 END student_api;


  FUNCTION Schedule_Units_Exists ( cp_n_person_id IN NUMBER,
                                   cp_c_program_cd IN VARCHAR2,
                                   cp_c_cal_type IN VARCHAR2,
                                   cp_n_seq_num IN NUMBER ) RETURN BOOLEAN AS
------------------------------------------------------------------------------------
    --Created by  : jnalam ( Oracle IDC)
    --Date created: 18-Nov-2005
    --
    --Purpose: this function returns true/false depending upon whether there are
    -- any units in the schedule or not. Bug #4742735
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -- smaddali  8-mar-06 removed cursor c_sch_pending_units_exists for bug5091853
 --------------------------------------------------------------------------------------

     -- Cursor to check whether student has enrolled unit sections in schedule for term and career / program
     CURSOR c_sch_enr_units_exists IS
        SELECT
            sua.person_id,
            sca.course_cd,
            tt11.load_cal_type term_cal_type,
            tt11.load_ci_sequence_number Term_Sequence_Number,
            sua.unit_attempt_status
        FROM  igs_en_su_attempt sua,
              igs_en_stdnt_ps_att sca,
              igs_ca_teach_to_load_v tt11
        WHERE
            sca.person_id = sua.person_id
        AND sca.course_cd = sua.course_cd
        AND sua.unit_attempt_status NOT IN ('UNCONFIRM')
        AND tt11.teach_cal_type = sua.cal_type
        AND tt11.teach_ci_sequence_number = sua.ci_sequence_number
        AND NOT EXISTS (SELECT * FROM igs_ps_usec_ref usr WHERE usr.uoo_id = sua.uoo_id AND  NVL(CLASS_SCHEDULE_EXCLUSION_FLAG,'N') = 'Y')
        AND sua.person_id = cp_n_person_id
        AND sca.course_cd = cp_c_program_cd
        AND tt11.load_cal_type = cp_c_cal_type
        AND tt11.load_ci_sequence_number = cp_n_seq_num
        AND sua.unit_attempt_status IN ('ENROLLED','DISCONTIN','INVALID', 'COMPLETED', 'WAITLISTED');


    enr_rowid c_sch_enr_units_exists%ROWTYPE;

  BEGIN
    OPEN c_sch_enr_units_exists;
    FETCH c_sch_enr_units_exists INTO enr_rowid;
        IF (c_sch_enr_units_exists%FOUND) THEN
              CLOSE c_sch_enr_units_exists;
              RETURN (TRUE);
        ELSE
              CLOSE c_sch_enr_units_exists;
              RETURN (FALSE);
        END IF;

  END Schedule_Units_Exists;

END igs_en_dashboard;


/
