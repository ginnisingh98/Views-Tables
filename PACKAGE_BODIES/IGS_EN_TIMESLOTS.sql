--------------------------------------------------------
--  DDL for Package Body IGS_EN_TIMESLOTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_TIMESLOTS" AS
/* $Header: IGSEN74B.pls 120.6 2006/03/15 22:08:15 svanukur ship $ */

  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  jbegum          25-Jun-2003     BUG#2930935
                                  Modified local function ENRP_CUR_CRITERIA
  KNAG.IN         12-APR-2001     Included enrollment credit point
                                  priority in timeslot allocation
                                  as per enh bug 1710227
  Nishikant       05AUG2002       Bug#2443771. The cursor cur_total_admted_stdnts got modified to select the students
                                  who enrolled directly in Student Enrollments. A new function calc_cum_gpa_person was
                                  written to calculate the Total GPA for a student ina provided LOAD or TEACHING calendar.
                                  also a new function acad_teach_rel_exist introduced in Spec and Body to be used in a cursor only.
  Nishikant       20DEC2002       Bug#2712493. The cursors cur_total_enrled_stdnts and cur_total_admted_stdnts got modified,
                                  in the function enrp_total_students, to select properly the students under 'Enrolled'
                              and 'Admitted' category.
  Nishikant       31MAR2003       The field full_name modified to last_name in the record
                                  type pdata_1 and pdata_2. Bug#2455364.
   smaddali   20-sep-2004       Modified enrp_total_students for cursor cur_total_enrled_stdnts bug#3918075
  ctyagi          13-Apr-2005     Modified cursor cur_total_admted_stdnts  bug#4297791
  ckasu           17-JAN-2006     Added igs_ge_gen_003.set_org_id(NULL) in enrp_assign_timeslot procedure as a part of bug#4958173.
  ***************************************************************/

plsql_empty plsql_table_1;
gpa_ord NUMBER :=   0 ;
gpa_sort_ord igs_en_timeslot_pref.preference_code%TYPE;
cpc_ord NUMBER :=   0 ;
cpc_sort_ord igs_en_timeslot_pref.preference_code%TYPE;
ecp_ord NUMBER :=   0 ;
ecp_sort_ord igs_en_timeslot_pref.preference_code%TYPE;

cnt4 NUMBER :=   0;
plsql_4 plsql_table_2;
plsql_empty_4 plsql_table_2;
-------------------------------------------------------------------------------
FUNCTION enrp_total_num_students(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

p_prg_type_gr_cd IN VARCHAR2,
p_stdnt_type IN VARCHAR2,
p_cal_type IN VARCHAR2,
p_seq_num IN NUMBER)
RETURN NUMBER AS
plsql_1 plsql_table_1;
BEGIN
   plsql_1 := enrp_total_students(p_prg_type_gr_cd,p_stdnt_type,p_cal_type,p_seq_num);
   RETURN plsql_1.COUNT;
END enrp_total_num_students;

FUNCTION enrp_get_working_day (
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

 p_prsnt_date DATE
) RETURN DATE
AS
BEGIN
  IF TO_CHAR(p_prsnt_date,'DY') NOT IN ('SAT','SUN') THEN
    -- if present day is working day return the same
    RETURN TRUNC(p_prsnt_date);
  ELSE
  -- call function to get the working day
    RETURN enrp_get_working_day(p_prsnt_date +1);
  END IF;
END enrp_get_working_day;

----------------------------------------------------------------------
PROCEDURE enrp_para_calculation(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

p_program_type_group_cd IN VARCHAR2,
p_student_type IN VARCHAR2,
p_cal_type IN VARCHAR2,
p_seq_number IN NUMBER,
p_timeslot  IN VARCHAR2,
p_ts_start_dt IN DATE,
p_ts_end_dt IN DATE,
p_length_of_time IN VARCHAR2,
p_start_time  IN DATE,
p_end_time IN DATE,
p_total_num_students OUT NOCOPY NUMBER,
p_num_ts_sessions OUT NOCOPY NUMBER) AS

  total_min_per_day NUMBER :=  0;
  total_days NUMBER :=  0;
  v_date DATE;
BEGIN

-- calling the function to get total number of students who satisfied the selection criteria
  p_total_num_students := enrp_total_num_students(p_program_type_group_cd,p_student_type,p_cal_type,p_seq_number);
IF p_length_of_time = 0 THEN
  -- Unlimited Length of Time has been selected
  p_num_ts_sessions := 1;
ELSE
  -- looping to calculate total number of working days
  v_date := enrp_get_working_day(p_ts_start_dt);
  LOOP
    IF v_date <= p_ts_end_dt THEN
      total_days := total_days + 1;
    ELSE
      EXIT; -- reached end_date
    END IF;
    v_date := enrp_get_working_day(v_date+1);
  END LOOP;
  --calculating the total number of timeslot sessions
  -- getting difference in hours  converting to minutes
  total_min_per_day := (TO_NUMBER(TO_CHAR(p_end_time,'HH24')) - TO_NUMBER(TO_CHAR(p_start_time,'HH24'))) * 60;
  -- getting difference in minutes and adding to total
  total_min_per_day := total_min_per_day + TO_NUMBER(TO_CHAR(p_end_time,'MI')) - TO_NUMBER(TO_CHAR(p_start_time,'MI'));
  p_num_ts_sessions := TRUNC( (total_min_per_day * total_days)/p_length_of_time);
END IF;

 EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','Igs_en_timeslots.enrp_para_calculation');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END enrp_para_calculation;

-------------------------------------------------------------------------------
FUNCTION enrp_calc_slots(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

p_start_time IN DATE,
p_end_time IN DATE,
p_start_date IN DATE,
p_end_date IN DATE,
p_length_of_time IN NUMBER)
RETURN plsql_table_3 AS

  plsql_5 plsql_table_3;
  l_start_time NUMBER ;
  l_end_time NUMBER ;
  l_date DATE;
  l_time_counter NUMBER ;
  tmp NUMBER :=  0;
  cnt NUMBER :=   0;

BEGIN
  l_start_time  :=   TO_NUMBER(TO_CHAR(p_start_time,'HH24'))* 60 + TO_NUMBER(TO_CHAR(p_start_time,'MI'));
  l_end_time  :=   TO_NUMBER(TO_CHAR(p_end_time,'HH24'))* 60 + TO_NUMBER(TO_CHAR(p_end_time,'MI'));
  l_time_counter  :=   l_start_time;

IF p_length_of_time = 0 THEN
  plsql_5(1).start_dt_time := TRUNC(p_start_date) + l_start_time/(24*60);
  plsql_5(1).end_dt_time := TRUNC(p_end_date) + l_end_time/(24*60);
ELSE
  l_date := enrp_get_working_day(p_start_date);
  -- looping through to populate start And end date and time of timeslot sessions
  LOOP
    cnt := cnt + 1;
    plsql_5(cnt).start_dt_time := TRUNC(l_date) + l_time_counter/(24*60);
    l_time_counter := l_time_counter + p_length_of_time;
    IF l_time_counter > l_end_time THEN
      l_date := enrp_get_working_day(l_date + 1);
          IF l_date > p_end_date THEN
            plsql_5.DELETE(cnt);
            EXIT; -- reached the end date of the time slot
          END IF;
      tmp := l_time_counter - l_end_time;
      l_time_counter := l_start_time + tmp;
    END IF;
    plsql_5(cnt).end_dt_time := TRUNC(l_date) + l_time_counter/(24*60);
    IF (l_time_counter = l_end_time) THEN
      l_time_counter := l_start_time;
      l_date := enrp_get_working_day(l_date + 1);
      IF l_date > p_end_date THEN
         EXIT; -- reached the end date of the time slot
      END IF;
    END IF;
  END LOOP;
END IF;
  RETURN plsql_5;

 EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','Igs_en_timeslots.enrp_calc_slots');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END enrp_calc_slots;

--------------------------------------------------------------
FUNCTION enrp_cur_criteria(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  (reverse chronological order - newest change first)
  Who             When            What
  jbegum          25-Jun-2003     BUG#2930935
                                  Modified cursors cur_load_teach_prd,cur_enrolled_cp.
  KNAG.IN         12-APR-2001     Included enrollment credit point
                                  priority in timeslot allocation
                                  as per enh bug 1710227
  Nishikant       02AUG2002       Bug#2443771. Calculation of GPA for the student was missing.
                                  Created a local procedure calc_cum_gpa_person to calculate cumulative GPA
                                  for a student of all the program attempts.
  ***************************************************************/

p_plsql_1 IN OUT NOCOPY plsql_table_1,
p_priority_value IN VARCHAR2,
p_preference_code IN VARCHAR2,
p_preference_version IN NUMBER,
p_sequence_number IN NUMBER,
p_pointer IN NUMBER,
p_ts_stup_id IN NUMBER)
RETURN plsql_table_1 IS

CURSOR c_cal_type(p_ts_stup_id NUMBER) IS
  SELECT ets.cal_type, ets.sequence_number
  FROM   igs_en_timeslot_stup ets
  WHERE  igs_en_timeslot_stup_id = p_ts_stup_id;
l_cal_type igs_en_timeslot_stup.cal_type%TYPE;
l_seq_num  igs_en_timeslot_stup.sequence_number%TYPE;

CURSOR cur_prog_type(p_person_id NUMBER , p_course_type VARCHAR2 ) IS
  SELECT sca.person_id
  FROM igs_en_stdnt_ps_att sca,
       igs_ps_ver pv
  WHERE sca.person_id = p_person_id AND
        sca.course_cd = pv.course_cd AND
        sca.version_number = pv.version_number AND
        pv.course_type = p_course_type;

CURSOR cur_org_unit (p_person_id NUMBER , p_org_unit_cd VARCHAR2 ) IS
  SELECT sca.person_id
  FROM igs_en_stdnt_ps_att sca,
       igs_ps_ver pv
  WHERE sca.person_id = p_person_id AND
        sca.course_cd = pv.course_cd AND
        sca.version_number = pv.version_number AND
        pv.responsible_org_unit_cd = p_org_unit_cd;

CURSOR cur_program (p_person_id NUMBER , p_course_cd VARCHAR2,p_version_number NUMBER ) IS
  SELECT sca.person_id
  FROM igs_en_stdnt_ps_att sca
  WHERE sca.person_id = p_person_id AND
        sca.course_cd = p_course_cd AND
        sca.version_number = p_version_number;

CURSOR cur_person_grp (p_person_id NUMBER , p_group_cd VARCHAR2 ) IS
  SELECT pgm.person_id
  FROM igs_pe_prsid_grp_mem pgm,
       igs_pe_persid_group pg
  WHERE pgm.person_id = p_person_id AND
        pgm.group_id = pg.group_id AND
        pg.group_cd = p_group_cd
        AND nvl( pgm.START_DATE,SYSDATE)<= SYSDATE
        AND nvl( pgm.END_DATE,SYSDATE)>= SYSDATE;

CURSOR cur_prog_stage (p_person_id NUMBER , p_course_stage_type VARCHAR2 ) IS
  SELECT sca.person_id
  FROM igs_en_stdnt_ps_att sca,
       igs_ps_stage ps
  WHERE sca.person_id = p_person_id AND
        sca.course_cd = ps.course_cd AND
        sca.version_number = ps.version_number AND
        ps.course_stage_type = p_course_stage_type;

CURSOR cur_prog_cd (p_person_id NUMBER) IS
  SELECT sca.course_cd
  FROM igs_en_stdnt_ps_att sca
  WHERE sca.person_id = p_person_id     and
        sca.course_attempt_status = 'ENROLLED';

CURSOR cur_load_teach_prd (p_person_id NUMBER,
                           p_cal_type  VARCHAR2,
                           p_sequence_number NUMBER) IS
  SELECT sua.unit_cd,sua.version_number,sua.override_enrolled_cp,sua.uoo_id
  FROM igs_en_su_attempt sua,
       igs_ca_inst_rel carel
  WHERE sua.person_id = p_person_id     and
        sua.unit_attempt_status = 'ENROLLED' and
        ((sua.cal_type = p_cal_type and
         sua.ci_sequence_number = p_sequence_number)OR
        (sua.cal_type = carel.sub_cal_type and
         sua.ci_sequence_number = carel.sub_ci_sequence_number and
         carel.sup_cal_type = p_cal_type and
         carel.sup_ci_sequence_number = p_sequence_number));

CURSOR cur_enrolled_cp (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT NVL(cps.enrolled_credit_points,uv.enrolled_credit_points) enrolled_credit_points
  FROM igs_ps_unit_ver uv ,
       igs_ps_usec_cps cps ,
       igs_ps_unit_ofr_opt uoo
  WHERE
       uoo.uoo_id = cps.uoo_id(+) AND
       uoo.unit_cd = uv.unit_cd AND
       uoo.version_number = uv.version_number AND
       uoo.uoo_id = cp_uoo_id;

        cur_enrolled_cp_rec     cur_enrolled_cp%ROWTYPE;
        cur_load_teach_prd_rec  cur_load_teach_prd%ROWTYPE;
        cur_criteria_rec        igs_en_stdnt_ps_att.person_id%TYPE;
        cnt_2 NUMBER :=  0;
        cnt_tmp NUMBER :=  0;
        plsql_2 plsql_table_1;
        plsql_tmp plsql_table_1;
        l_gpa NUMBER :=   -1;
        l_cpc NUMBER :=   -1;
        l_ecp NUMBER :=   0;
        cur_rec_found BOOLEAN :=   FALSE;

/* Begin of the local Procedure calc_cum_gpa_person */
PROCEDURE calc_cum_gpa_person(
  /*************************************************************
  Created By : Nishikant
  Date Created By : 31JUL2002
  Purpose : This is a local procedure which calculates the cumulative gpa for all
            the program attempt for a person. It considers all the unit attempts for the person
            which are completed or discontinued before the end date of the provided LOAD calendar
            or the load calendar associated with the provided TEACH calendar.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  swaghmar	15-Sep-2005	Bug# 4491456 - Modified datatypes
  (reverse chronological order - newest change first)
  ***************************************************************/
p_person_id   IN   NUMBER,
p_cal_type    IN   VARCHAR2, -- It can be either LOAD or TEACH calendar
p_seq_num     IN   NUMBER,
p_gpa         OUT NOCOPY  NUMBER) AS

CURSOR c_chk_cal_cat IS
SELECT s_cal_cat
FROM   igs_ca_type
WHERE  cal_type = p_cal_type;
l_chk_cal_cat    igs_ca_type.s_cal_cat%TYPE;

CURSOR c_teach_to_load IS
SELECT load_cal_type, load_ci_sequence_number
FROM   igs_ca_teach_to_load_v
WHERE  teach_cal_type  = p_cal_type
AND    teach_ci_sequence_number = p_seq_num
ORDER BY load_start_dt DESC;
l_load_cal_type             igs_ca_teach_to_load_v.load_cal_type%TYPE;
l_load_ci_sequence_number   igs_ca_teach_to_load_v.load_ci_sequence_number%TYPE;

CURSOR c_ps_att IS
SELECT course_cd, version_number, cal_type
FROM   IGS_EN_STDNT_PS_ATT sca
WHERE  person_id = p_person_id;
l_ps_att c_ps_att%ROWTYPE;

l_gpa                        NUMBER;
l_dummy_gpa_cp               NUMBER;
l_dummy_gpa_quality_points   NUMBER;
l_total_gpa                  NUMBER;

l_init_msg_list     VARCHAR2(20) ;
l_return_status     VARCHAR2(30);
l_msg_count         NUMBER(2);
l_msg_data          VARCHAR2(1000);

BEGIN
   l_total_gpa   := 0;
   l_init_msg_list   := FND_API.G_TRUE;

   OPEN c_chk_cal_cat;
   FETCH c_chk_cal_cat INTO l_chk_cal_cat;
   CLOSE c_chk_cal_cat;
   -- It checks here whether the provided calendar is TEACHING or LOAD.
   -- If its TEACHING then it finds out the first LOAD attached with it.
   IF l_chk_cal_cat = 'TEACHING' THEN
        OPEN c_teach_to_load;
        FETCH c_teach_to_load INTO l_load_cal_type, l_load_ci_sequence_number;
        CLOSE c_teach_to_load;
   ELSE
        l_load_cal_type := p_cal_type;
        l_load_ci_sequence_number := p_seq_num;
   END IF;

-- It loops through each program attempts for the person and calls the function to get the
-- GPA for all the unit attempts under the progam attempt whose end date of the TEACHING calendar
-- is earlier than the end date of the LOAD calendar.
   FOR l_ps_att IN c_ps_att
   LOOP

   -- If the Statistic Type and System Statistic Type are sent as NULL then it will find out the STANDARD GPA
   -- for the unit attempts.
      igs_pr_cp_gpa.get_gpa_stats(
           p_person_id,
           l_ps_att.course_cd,
           NULL,                       -- Statistic type
           l_load_cal_type,
           l_load_ci_sequence_number,
           NULL,                       -- System Statistic Type
           'Y',                        -- Cumulative indicator
           l_gpa,                      -- OUT parameter, which will be the required gpa value.
           l_dummy_gpa_cp,             -- OUT parameter, not required.
           l_dummy_gpa_quality_points, -- OUT parameter, not required.
           l_init_msg_list,
           l_return_status,            -- OUT parameter, not required.
           l_msg_count,                -- OUT parameter, not required.
           l_msg_data                  -- OUT parameter, not required.
           );
     -- Sometimes the OUT parameter l_gpa value can be NULL if Statistic Type is not defined at Organisation or Institution level.
     -- A record should exist in the Organization Unit Statistic Type Configuration form or Institution Statistic Type Configuration form
     -- with Standard Indicator as checked and the Timeframe field value should be either Cumulative or Both.
     -- Also when no unit COMPLETED or attempts found then GPA value will be NULL.
       IF l_gpa IS NOT NULL THEN
           l_total_gpa := l_total_gpa + l_gpa;
       END IF;
   END LOOP;
   p_gpa := l_total_gpa;
EXCEPTION
   WHEN OTHERS THEN
        IF c_chk_cal_cat%ISOPEN THEN
             CLOSE c_chk_cal_cat;
        END IF;
        IF c_teach_to_load%ISOPEN THEN
             CLOSE c_teach_to_load;
        END IF;
        IF c_ps_att%ISOPEN THEN
             CLOSE c_ps_att;
        END IF;
END calc_cum_gpa_person; /* end of the local procedure calc_cum_gpa_person*/

BEGIN

    IF p_priority_value = 'PROG_TYPE' THEN
       FOR i IN 1..p_plsql_1.COUNT LOOP
                OPEN cur_prog_type(p_plsql_1(i).person_id,p_preference_code);
                FETCH cur_prog_type INTO cur_criteria_rec;
                IF cur_prog_type%FOUND THEN
                        cnt_2 := cnt_2 + 1;
                        plsql_2(cnt_2) := p_plsql_1(i);
                        ELSE
                        cnt_tmp := cnt_tmp + 1;
                        plsql_tmp(cnt_tmp) := p_plsql_1(i);
                END IF;
                CLOSE cur_prog_type;
       END LOOP; -- plsql_1
           -- instead of deleting the records, storing them into temp. table And asigning back
           p_plsql_1 := plsql_tmp;
           RETURN plsql_2;
    ELSIF p_priority_value = 'ORG_UNIT' THEN
       FOR i IN 1..p_plsql_1.COUNT LOOP
                OPEN cur_org_unit(p_plsql_1(i).person_id,p_preference_code);
                FETCH cur_org_unit INTO cur_criteria_rec;
                IF cur_org_unit%FOUND THEN
                        cnt_2 := cnt_2 + 1;
                        plsql_2(cnt_2) := p_plsql_1(i);
                        ELSE
                        cnt_tmp := cnt_tmp + 1;
                        plsql_tmp(cnt_tmp) := p_plsql_1(i);
                END IF;
                CLOSE cur_org_unit;
       END LOOP; -- plsql_1
           -- instead of deleting the records, storing them into temp. table And asigning back
           p_plsql_1 := plsql_tmp;
           RETURN plsql_2;
    ELSIF p_priority_value = 'PROGRAM' THEN
       FOR i IN 1..p_plsql_1.COUNT LOOP
                OPEN cur_program(p_plsql_1(i).person_id,p_preference_code,p_preference_version);
                FETCH cur_program INTO cur_criteria_rec;
                IF cur_program%FOUND THEN
                        cnt_2 := cnt_2 + 1;
                        plsql_2(cnt_2) := p_plsql_1(i);
                        ELSE
                        cnt_tmp := cnt_tmp + 1;
                        plsql_tmp(cnt_tmp) := p_plsql_1(i);
                END IF;
                CLOSE cur_program;
       END LOOP; -- plsql_1
           -- instead of deleting the records, storing them into temp. table And asigning back
           p_plsql_1 := plsql_tmp;
           RETURN plsql_2;
    ELSIF p_priority_value = 'PERSON_GRP' THEN
       FOR i IN 1..p_plsql_1.COUNT LOOP
                OPEN cur_person_grp(p_plsql_1(i).person_id,p_preference_code);
                FETCH cur_person_grp INTO cur_criteria_rec;
                IF cur_person_grp%FOUND THEN
                        cnt_2 := cnt_2 + 1;
                        plsql_2(cnt_2) := p_plsql_1(i);
                        ELSE
                        cnt_tmp := cnt_tmp + 1;
                        plsql_tmp(cnt_tmp) := p_plsql_1(i);
                END IF;
                CLOSE cur_person_grp;
       END LOOP; -- plsql_1
           -- instead of deleting the records, storing them into temp. table And asigning back
           p_plsql_1 := plsql_tmp;
           RETURN plsql_2;
    ELSIF p_priority_value = 'PROG_STAGE' THEN
       FOR i IN 1..p_plsql_1.COUNT LOOP
                OPEN cur_prog_stage(p_plsql_1(i).person_id,p_preference_code);
                FETCH cur_prog_stage INTO cur_criteria_rec;
                IF cur_prog_stage%FOUND THEN
                        cnt_2 := cnt_2 + 1;
                        plsql_2(cnt_2) := p_plsql_1(i);
                        ELSE
                        cnt_tmp := cnt_tmp + 1;
                        plsql_tmp(cnt_tmp) := p_plsql_1(i);
                END IF;
                CLOSE cur_prog_stage;
       END LOOP; -- plsql_1
           -- instead of deleting the records, storing them into temp. table And asigning back
           p_plsql_1 := plsql_tmp;
           RETURN plsql_2;
    ELSIF p_priority_value = 'GPA' THEN
-- copy the order of GPA priority And preference into variables visible for all methods in package
       gpa_ord := p_pointer;
       gpa_sort_ord := p_preference_code;
       -- Finds out here the cal type and sequence type by the help of parameter p_ts_stup
       OPEN c_cal_type(p_ts_stup_id);
       FETCH c_cal_type INTO l_cal_type, l_seq_num;
       CLOSE c_cal_type;
       FOR i IN 1..p_plsql_1.COUNT LOOP
            calc_cum_gpa_person(                -- Local procudure calculates GPA for the student
                        p_plsql_1(i).person_id,
                        l_cal_type,
                        l_seq_num,
                        l_gpa);
            -- There is chance to get the l_gpa value as 0. That case will not be considered.
            -- If Enrolled Credit point has been defined as 0, and Override Credit points also either defined 0 or
            -- not defined, then the l_gpa value will be zero.
            -- Also if no grading schema found for the unit attempt or the result of unit attempt is FAIL or WITHDRAWN
            -- or UNCOMPLETED then the l_gpa value will be 0.
            IF l_gpa <> 0 THEN
                cnt_2 := cnt_2 + 1;
                plsql_2(cnt_2) := p_plsql_1(i);
                plsql_2(cnt_2).gpa := l_gpa;
            ELSE
                cnt_tmp := cnt_tmp + 1;
                plsql_tmp(cnt_tmp) := p_plsql_1(i);
            END IF;
            l_gpa := -1;
       END LOOP; -- plsql_1
       -- instead of deleting the records, storing them into temp. table And asigning back
       p_plsql_1 := plsql_tmp;
       RETURN plsql_2;
    ELSIF p_priority_value = 'TOTAL_CP' THEN
        -- copy the order of TOTAL_CP priority And preference into variables visible for all methods in package
        cpc_ord := p_pointer;
        cpc_sort_ord := p_preference_code;
        FOR i IN 1..p_plsql_1.COUNT LOOP
                -- Calculating TOTAL_CP for the student

                --initialize the value for each student
                l_cpc  := 0;

                for cur_prog_cd_rec in cur_prog_cd(p_plsql_1(i).person_id) loop
                   l_cpc := l_cpc + NVL(IGS_EN_GEN_001.enrp_clc_sca_pass_cp(p_plsql_1(i).person_id,cur_prog_cd_rec.course_cd,Trunc(sysdate)),0);
                end loop;
                IF l_cpc <> 0 THEN
                        cnt_2 := cnt_2 + 1;
                        plsql_2(cnt_2) := p_plsql_1(i);
                        plsql_2(cnt_2).cpc := l_cpc;
                        ELSE
                        cnt_tmp := cnt_tmp + 1;
                        plsql_tmp(cnt_tmp) := p_plsql_1(i);
                END IF;
       END LOOP; -- plsql_1
           -- instead of deleting the records, storing them into temp. table And asigning back
           p_plsql_1 := plsql_tmp;
           RETURN plsql_2;
    ELSIF p_priority_value = 'ENRCP_ASC' THEN
        -- copy the order of ENRCP_ASC priority And preference into variables visible for all methods in package
        ecp_ord := p_pointer;
        ecp_sort_ord := 'A';
        l_ecp := 0;
        cur_rec_found := FALSE;
        FOR i IN 1..p_plsql_1.COUNT LOOP
                -- Calculating TOTAL_ECP for the student
                OPEN cur_load_teach_prd(p_plsql_1(i).person_id, p_preference_code ,p_sequence_number);
                LOOP
                  FETCH cur_load_teach_prd INTO cur_load_teach_prd_rec;
                  IF cur_load_teach_prd%FOUND THEN
                    cur_rec_found := TRUE;
                    IF cur_load_teach_prd_rec.override_enrolled_cp IS NOT NULL THEN
                      l_ecp := l_ecp + cur_load_teach_prd_rec.override_enrolled_cp;
                    ELSE
                      OPEN cur_enrolled_cp(cur_load_teach_prd_rec.uoo_id);
                      FETCH cur_enrolled_cp INTO cur_enrolled_cp_rec;
                      IF cur_enrolled_cp%FOUND THEN
                        l_ecp := l_ecp + cur_enrolled_cp_rec.enrolled_credit_points;
                      END IF;
                      CLOSE cur_enrolled_cp;
                    END IF;
                  ELSE
                    EXIT;
                  END IF;
                END LOOP;
                CLOSE cur_load_teach_prd;

                IF cur_rec_found THEN
                  cnt_2 := cnt_2 + 1;
                  plsql_2(cnt_2) := p_plsql_1(i);
                  plsql_2(cnt_2).ecp := l_ecp;
                  l_ecp := 0;
                  cur_rec_found := FALSE;
                ELSE
                  cnt_tmp := cnt_tmp + 1;
                  plsql_tmp(cnt_tmp) := p_plsql_1(i);
                END IF;
        END LOOP; -- plsql_1
           -- instead of deleting the records, storing them into temp. table And asigning back
           p_plsql_1 := plsql_tmp;
           RETURN plsql_2;
    ELSIF p_priority_value = 'ENRCP_DESC' THEN
        -- copy the order of ENRCP_DESC priority And preference into variables visible for all methods in package
        ecp_ord := p_pointer;
        ecp_sort_ord := 'D';
        l_ecp := 0;
        cur_rec_found := FALSE;
        FOR i IN 1..p_plsql_1.COUNT LOOP
                -- Calculating TOTAL_ECP for the student
                OPEN cur_load_teach_prd(p_plsql_1(i).person_id, p_preference_code ,p_sequence_number);
                LOOP
                  FETCH cur_load_teach_prd INTO cur_load_teach_prd_rec;
                  IF cur_load_teach_prd%FOUND THEN
                    cur_rec_found := TRUE;
                    IF cur_load_teach_prd_rec.override_enrolled_cp IS NOT NULL THEN
                      l_ecp := l_ecp + cur_load_teach_prd_rec.override_enrolled_cp;
                    ELSE
                      OPEN cur_enrolled_cp(cur_load_teach_prd_rec.uoo_id);
                      FETCH cur_enrolled_cp INTO cur_enrolled_cp_rec;
                      IF cur_enrolled_cp%FOUND THEN
                        l_ecp := l_ecp + cur_enrolled_cp_rec.enrolled_credit_points;
                      END IF;
                      CLOSE cur_enrolled_cp;
                    END IF;
                  ELSE
                    EXIT;
                  END IF;
                END LOOP;
                CLOSE cur_load_teach_prd;

                IF cur_rec_found THEN
                  cnt_2 := cnt_2 + 1;
                  plsql_2(cnt_2) := p_plsql_1(i);
                  plsql_2(cnt_2).ecp := l_ecp;
                  l_ecp := 0;
                  cur_rec_found := FALSE;
                ELSE
                  cnt_tmp := cnt_tmp + 1;
                  plsql_tmp(cnt_tmp) := p_plsql_1(i);
                END IF;
        END LOOP; -- plsql_1
           -- instead of deleting the records, storing them into temp. table And asigning back
           p_plsql_1 := plsql_tmp;
           RETURN plsql_2;
    ELSE
          --error message : selected priority is not available..
          NULL;
    END IF;
 EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','Igs_en_timeslots.enrp_cur_criteria');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END enrp_cur_criteria;

-------------------------------------------------------------------------
FUNCTION enrp_alpha_sort(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

p_plsql_3 IN OUT NOCOPY plsql_table_1,
p_surname_alpha VARCHAR2)
RETURN plsql_table_1 IS
   -- record of plsql_table_1
   plsql_tmp_rec pdata_1;
   startcnt NUMBER :=  1;
   cnt NUMBER :=  0;
   plsql_rslt plsql_table_1;
BEGIN

   FOR i IN 1 .. p_plsql_3.COUNT - 1 LOOP
     FOR j IN i+1 .. p_plsql_3.COUNT LOOP
       IF p_plsql_3(i).last_name > p_plsql_3(j).last_name THEN
         plsql_tmp_rec := p_plsql_3(i);
         p_plsql_3(i) := p_plsql_3(j);
         p_plsql_3(j) := plsql_tmp_rec;
       END IF;
     END LOOP;
   END LOOP;
  -- to sort on given alphbet
  FOR i IN 1 .. p_plsql_3.COUNT LOOP
    IF UPPER(p_plsql_3(i).last_name) >= UPPER(p_surname_alpha)  THEN
      startcnt := i;
      EXIT;
    END IF;
  END LOOP;
  FOR j IN startcnt .. p_plsql_3.COUNT LOOP
    cnt := cnt + 1;
    plsql_rslt(cnt) := p_plsql_3(j);
  END LOOP;
  FOR j IN 1 .. startcnt-1 LOOP
    cnt := cnt + 1;
    plsql_rslt(cnt) := p_plsql_3(j);
  END LOOP;

 RETURN plsql_rslt;

END enrp_alpha_sort;

-----------------------------------------------------------------------------
FUNCTION enrp_gpa_sort(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

p_plsql_3 IN OUT NOCOPY plsql_table_1,
p_surname_alpha VARCHAR2)
RETURN plsql_table_1 IS
   -- record of plsql_table_1
   plsql_tmp_rec pdata_1;
   started BOOLEAN :=   FALSE;
   startcnt NUMBER :=  1;
   cnt NUMBER :=  0;
   plsql_tmp plsql_table_1;
BEGIN
  IF gpa_sort_ord = 'A' THEN
     FOR i IN 1 .. p_plsql_3.COUNT - 1 LOOP
        FOR j IN i+1 .. p_plsql_3.COUNT LOOP
               IF p_plsql_3(i).gpa > p_plsql_3(j).gpa THEN
                    plsql_tmp_rec := p_plsql_3(i);
                    p_plsql_3(i) := p_plsql_3(j);
                    p_plsql_3(j) := plsql_tmp_rec;
               END IF;
         END LOOP;
     END LOOP;
  ELSIF gpa_sort_ord = 'D' THEN
     FOR i IN 1 .. p_plsql_3.COUNT - 1 LOOP
        FOR j IN i+1 .. p_plsql_3.COUNT LOOP
               IF p_plsql_3(i).gpa < p_plsql_3(j).gpa THEN
                   plsql_tmp_rec := p_plsql_3(i);
                   p_plsql_3(i) := p_plsql_3(j);
                   p_plsql_3(j) := plsql_tmp_rec;
                END IF;
        END LOOP;
     END LOOP;
  END IF;
-- sort students alphabetically who has the same GPA
  FOR i IN 1 .. p_plsql_3.COUNT LOOP
    IF i < p_plsql_3.COUNT AND p_plsql_3(i).gpa = p_plsql_3(i+1).gpa AND NOT started THEN
      started := TRUE;
      startcnt := i;
      cnt := 0;
      plsql_tmp := plsql_empty; -- assigning empty plsql table to erase the content
    END IF;
    IF started THEN
      cnt := cnt +1 ;
      plsql_tmp(cnt) := p_plsql_3(i);
      IF i = p_plsql_3.COUNT OR p_plsql_3(i).gpa <> p_plsql_3(i+1).gpa THEN
         started := FALSE;
         plsql_tmp := enrp_alpha_sort(plsql_tmp,p_surname_alpha);
         FOR j IN 1 .. plsql_tmp.COUNT LOOP
            p_plsql_3(startcnt) := plsql_tmp(j);
            startcnt := startcnt +1;
         END LOOP;
      END IF;
    END IF;
  END LOOP;
 RETURN p_plsql_3;
END enrp_gpa_sort;

---------------------------------------------------------------------
FUNCTION enrp_cpc_sort(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

p_plsql_3 IN OUT NOCOPY plsql_table_1,
p_surname_alpha VARCHAR2)
RETURN plsql_table_1 IS
   -- record of plsql_table_1
   plsql_tmp_rec pdata_1;
   started BOOLEAN :=   FALSE;
   startcnt NUMBER :=  1;
   cnt NUMBER :=  0;
   plsql_tmp plsql_table_1;
BEGIN
  IF cpc_sort_ord = 'A' THEN
     FOR i IN 1 .. p_plsql_3.COUNT - 1 LOOP
        FOR j IN i+1 .. p_plsql_3.COUNT LOOP
               IF p_plsql_3(i).cpc > p_plsql_3(j).cpc THEN
                    plsql_tmp_rec := p_plsql_3(i);
                    p_plsql_3(i) := p_plsql_3(j);
                    p_plsql_3(j) := plsql_tmp_rec;
               END IF;
        END LOOP;
     END LOOP;
  ELSIF cpc_sort_ord = 'D' THEN
     FOR i IN 1 .. p_plsql_3.COUNT - 1 LOOP
        FOR j IN i+1 .. p_plsql_3.COUNT LOOP
               IF p_plsql_3(i).cpc < p_plsql_3(j).cpc THEN
                    plsql_tmp_rec := p_plsql_3(i);
                    p_plsql_3(i) := p_plsql_3(j);
                    p_plsql_3(j) := plsql_tmp_rec;
               END IF;
        END LOOP;
     END LOOP;
  END IF;
-- sort students alphabetically who has the same CPC
  FOR i IN 1 .. p_plsql_3.COUNT LOOP
    IF i < p_plsql_3.COUNT AND p_plsql_3(i).cpc = p_plsql_3(i+1).cpc AND NOT started THEN
      started := TRUE;
      startcnt := i;
      cnt := 0;
      plsql_tmp := plsql_empty; -- assigning empty plsql table to erase the content
    END IF;
    IF started THEN
      cnt := cnt +1 ;
      plsql_tmp(cnt) := p_plsql_3(i);

      IF i = p_plsql_3.COUNT OR p_plsql_3(i).cpc <> p_plsql_3(i+1).cpc THEN
         started := FALSE;
         plsql_tmp := enrp_alpha_sort(plsql_tmp,p_surname_alpha);
         FOR j IN 1 .. plsql_tmp.COUNT LOOP
            p_plsql_3(startcnt) := plsql_tmp(j);
            startcnt := startcnt +1;
         END LOOP;
      END IF;
    END IF;
  END LOOP;
 RETURN p_plsql_3;
END enrp_cpc_sort;

-------------------------------------------------------------------------

FUNCTION enrp_ecp_sort(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  KNAG.IN         12-APR-2001     Included enrollment credit point
                                  priority in timeslot allocation
                                  as per enh bug 1710227
  (reverse chronological order - newest change first)
  ***************************************************************/

p_plsql_3 IN OUT NOCOPY plsql_table_1,
p_surname_alpha VARCHAR2)
RETURN plsql_table_1 IS
   -- record of plsql_table_1
   plsql_tmp_rec pdata_1;
   started BOOLEAN :=   FALSE;
   startcnt NUMBER :=  1;
   cnt NUMBER :=  0;
   plsql_tmp plsql_table_1;
BEGIN
  IF ecp_sort_ord = 'A' THEN
     FOR i IN 1 .. p_plsql_3.COUNT - 1 LOOP
        FOR j IN i+1 .. p_plsql_3.COUNT LOOP
               IF p_plsql_3(i).ecp > p_plsql_3(j).ecp THEN
                    plsql_tmp_rec := p_plsql_3(i);
                    p_plsql_3(i) := p_plsql_3(j);
                    p_plsql_3(j) := plsql_tmp_rec;
               END IF;
         END LOOP;
     END LOOP;
  ELSIF ecp_sort_ord = 'D' THEN
     FOR i IN 1 .. p_plsql_3.COUNT - 1 LOOP
        FOR j IN i+1 .. p_plsql_3.COUNT LOOP
               IF p_plsql_3(i).ecp < p_plsql_3(j).ecp THEN
                   plsql_tmp_rec := p_plsql_3(i);
                   p_plsql_3(i) := p_plsql_3(j);
                   p_plsql_3(j) := plsql_tmp_rec;
                END IF;
        END LOOP;
     END LOOP;
  END IF;
-- sort students alphabetically who has the same ECP
  FOR i IN 1 .. p_plsql_3.COUNT LOOP
    IF i < p_plsql_3.COUNT AND p_plsql_3(i).ecp = p_plsql_3(i+1).ecp AND NOT started THEN
      started := TRUE;
      startcnt := i;
      cnt := 0;
      plsql_tmp := plsql_empty; -- assigning empty plsql table to erase the content
    END IF;
    IF started THEN
      cnt := cnt +1 ;
      plsql_tmp(cnt) := p_plsql_3(i);
      IF i = p_plsql_3.COUNT OR p_plsql_3(i).ecp <> p_plsql_3(i+1).ecp THEN
         started := FALSE;
         plsql_tmp := enrp_alpha_sort(plsql_tmp,p_surname_alpha);
         FOR j IN 1 .. plsql_tmp.COUNT LOOP
            p_plsql_3(startcnt) := plsql_tmp(j);
            startcnt := startcnt +1;
         END LOOP;
      END IF;
    END IF;
  END LOOP;
 RETURN p_plsql_3;
END enrp_ecp_sort;

-----------------------------------------------------------------------------

PROCEDURE enrp_sort_mngt(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  KNAG.IN         12-APR-2001     Included enrollment credit point
                                  priority in timeslot allocation
                                  as per enh bug 1710227
  (reverse chronological order - newest change first)
  ***************************************************************/

p_plsql_2 IN OUT NOCOPY plsql_table_1,
p_surname_alpha IN VARCHAR2,
p_pointer NUMBER) IS
  plsql_3 plsql_table_1;
  started       BOOLEAN :=   FALSE;
  started_1     BOOLEAN :=   FALSE;
  started_2     BOOLEAN :=   FALSE;
  startcnt      NUMBER :=  1;
  startcnt_1    NUMBER :=  1;
  startcnt_2    NUMBER :=  1;
  plsql_tmp     plsql_table_1;
  plsql_tmp_1   plsql_table_1;
  plsql_tmp_2   plsql_table_1;
  cnt           NUMBER :=  0;
  cnt_1         NUMBER :=  0;
  cnt_2         NUMBER :=  0;
BEGIN

  IF gpa_ord <= p_pointer AND gpa_ord <> 0 AND
     cpc_ord <= p_pointer AND cpc_ord <> 0 AND
     ecp_ord <= p_pointer AND ecp_ord <> 0 THEN

-- --Begin of GPA has more priority than CPC and ECP----------------------------------

     IF gpa_ord < cpc_ord AND gpa_ord < ecp_ord THEN -- GPA has more priority than CPC and ECP
       plsql_3 := enrp_gpa_sort(p_plsql_2,p_surname_alpha);
       FOR i IN 1 .. plsql_3.COUNT LOOP
         IF i < plsql_3.COUNT AND plsql_3(i).gpa = plsql_3(i+1).gpa AND NOT started_1 THEN
           started_1 := TRUE;
           startcnt_1 := i;
           cnt_1 := 0;
           plsql_tmp_1 := plsql_empty; -- assigning empty plsql table to erase the content
         END IF;
         IF started_1 THEN
           cnt_1 := cnt_1 +1 ;
           plsql_tmp_1(cnt_1) := plsql_3(i);
           IF i = plsql_3.COUNT OR plsql_3(i).gpa <> plsql_3(i+1).gpa THEN
             started_1 := FALSE;
             IF cpc_ord < ecp_ord THEN -- CPC has more priority than ECP
               plsql_tmp_1 := enrp_cpc_sort(plsql_tmp_1,p_surname_alpha);
               started_2 := FALSE;
               startcnt_2 := 1;
               cnt_2 := 0 ;
               FOR j IN 1 .. plsql_tmp_1.COUNT LOOP
                 IF j < plsql_tmp_1.COUNT AND plsql_tmp_1(j).cpc = plsql_tmp_1(j+1).cpc AND
                    NOT started_2 THEN
                   started_2 := TRUE;
                   startcnt_2 := j;
                   cnt_2 := 0;
                   plsql_tmp_2 := plsql_empty; -- assigning empty plsql table to erase the content
                 END IF;
                 IF started_2 THEN
                   cnt_2 := cnt_2 +1 ;
                   plsql_tmp_2(cnt_2) := plsql_tmp_1(j);
                   IF j = plsql_tmp_1.COUNT OR plsql_tmp_1(j).cpc <> plsql_tmp_1(j+1).cpc THEN
                     started_2 := FALSE;
                     plsql_tmp_2 := enrp_ecp_sort(plsql_tmp_2,p_surname_alpha);
                     FOR k IN 1 .. plsql_tmp_2.COUNT LOOP
                       plsql_tmp_1(startcnt_2) := plsql_tmp_2(k);
                       startcnt_2 := startcnt_2 +1;
                     END LOOP;
                   END IF;
                 END IF;
                 FOR k IN 1 .. plsql_tmp_2.COUNT LOOP
                   plsql_3(startcnt_1) := plsql_tmp_1(j);
                   startcnt_1 := startcnt_1 +1;
                 END LOOP;
               END LOOP;
             ELSIF ecp_ord < cpc_ord THEN -- ECP has more priority than CPC
               plsql_tmp_1 := enrp_ecp_sort(plsql_tmp_1,p_surname_alpha);
               started_2 := FALSE;
               startcnt_2 := 1;
               cnt_2 := 0 ;
               FOR j IN 1 .. plsql_tmp_1.COUNT LOOP
                 IF j < plsql_tmp_1.COUNT AND plsql_tmp_1(j).ecp = plsql_tmp_1(j+1).ecp AND
                    NOT started_2 THEN
                   started_2 := TRUE;
                   startcnt_2 := j;
                   cnt_2 := 0;
                   plsql_tmp_2 := plsql_empty; -- assigning empty plsql table to erase the content
                 END IF;
                 IF started_2 THEN
                   cnt_2 := cnt_2 +1 ;
                   plsql_tmp_2(cnt_2) := plsql_tmp_1(j);
                   IF j = plsql_tmp_1.COUNT OR plsql_tmp_1(j).ecp <> plsql_tmp_1(j+1).ecp THEN
                     started_2 := FALSE;
                     plsql_tmp_2 := enrp_cpc_sort(plsql_tmp_2,p_surname_alpha);
                     FOR k IN 1 .. plsql_tmp_2.COUNT LOOP
                       plsql_tmp_1(startcnt_2) := plsql_tmp_2(k);
                       startcnt_2 := startcnt_2 +1;
                     END LOOP;
                   END IF;
                 END IF;
                 FOR k IN 1 .. plsql_tmp_2.COUNT LOOP
                   plsql_3(startcnt_1) := plsql_tmp_1(j);
                   startcnt_1 := startcnt_1 +1;
                 END LOOP;
               END LOOP;
             END IF;
           END IF;
         END IF;
       END LOOP;
     END IF;

-- --End of GPA has more priority than CPC and ECP----------------------------------

-- --Begin of CPC has more priority than GPA and ECP----------------------------------

     IF cpc_ord < gpa_ord AND cpc_ord < ecp_ord THEN -- CPC has more priority than GPA and ECP
       plsql_3 := enrp_cpc_sort(p_plsql_2,p_surname_alpha);
       FOR i IN 1 .. plsql_3.COUNT LOOP
         IF i < plsql_3.COUNT AND plsql_3(i).cpc = plsql_3(i+1).cpc AND NOT started_1 THEN
           started_1 := TRUE;
           startcnt_1 := i;
           cnt_1 := 0;
           plsql_tmp_1 := plsql_empty; -- assigning empty plsql table to erase the content
         END IF;
         IF started_1 THEN
           cnt_1 := cnt_1 +1 ;
           plsql_tmp_1(cnt_1) := plsql_3(i);
           IF i = plsql_3.COUNT OR plsql_3(i).cpc <> plsql_3(i+1).cpc THEN
             started_1 := FALSE;
             IF gpa_ord < ecp_ord THEN -- GPA has more priority than ECP
               plsql_tmp_1 := enrp_gpa_sort(plsql_tmp_1,p_surname_alpha);
               started_2 := FALSE;
               startcnt_2 := 1;
               cnt_2 := 0 ;
               FOR j IN 1 .. plsql_tmp_1.COUNT LOOP
                 IF j < plsql_tmp_1.COUNT AND plsql_tmp_1(j).gpa = plsql_tmp_1(j+1).gpa AND
                    NOT started_2 THEN
                   started_2 := TRUE;
                   startcnt_2 := j;
                   cnt_2 := 0;
                   plsql_tmp_2 := plsql_empty; -- assigning empty plsql table to erase the content
                 END IF;
                 IF started_2 THEN
                   cnt_2 := cnt_2 +1 ;
                   plsql_tmp_2(cnt_2) := plsql_tmp_1(j);
                   IF j = plsql_tmp_1.COUNT OR plsql_tmp_1(j).gpa <> plsql_tmp_1(j+1).gpa THEN
                     started_2 := FALSE;
                     plsql_tmp_2 := enrp_ecp_sort(plsql_tmp_2,p_surname_alpha);
                     FOR k IN 1 .. plsql_tmp_2.COUNT LOOP
                       plsql_tmp_1(startcnt_2) := plsql_tmp_2(k);
                       startcnt_2 := startcnt_2 +1;
                     END LOOP;
                   END IF;
                 END IF;
                 FOR k IN 1 .. plsql_tmp_2.COUNT LOOP
                   plsql_3(startcnt_1) := plsql_tmp_1(j);
                   startcnt_1 := startcnt_1 +1;
                 END LOOP;
               END LOOP;
             ELSIF ecp_ord < gpa_ord THEN -- ECP has more priority than GPA
               plsql_tmp_1 := enrp_ecp_sort(plsql_tmp_1,p_surname_alpha);
               started_2 := FALSE;
               startcnt_2 := 1;
               cnt_2 := 0 ;
               FOR j IN 1 .. plsql_tmp_1.COUNT LOOP
                 IF j < plsql_tmp_1.COUNT AND plsql_tmp_1(j).ecp = plsql_tmp_1(j+1).ecp AND
                    NOT started_2 THEN
                   started_2 := TRUE;
                   startcnt_2 := j;
                   cnt_2 := 0;
                   plsql_tmp_2 := plsql_empty; -- assigning empty plsql table to erase the content
                 END IF;
                 IF started_2 THEN
                   cnt_2 := cnt_2 +1 ;
                   plsql_tmp_2(cnt_2) := plsql_tmp_1(j);
                   IF j = plsql_tmp_1.COUNT OR plsql_tmp_1(j).ecp <> plsql_tmp_1(j+1).ecp THEN
                     started_2 := FALSE;
                     plsql_tmp_2 := enrp_gpa_sort(plsql_tmp_2,p_surname_alpha);
                     FOR k IN 1 .. plsql_tmp_2.COUNT LOOP
                       plsql_tmp_1(startcnt_2) := plsql_tmp_2(k);
                       startcnt_2 := startcnt_2 +1;
                     END LOOP;
                   END IF;
                 END IF;
                 FOR k IN 1 .. plsql_tmp_2.COUNT LOOP
                   plsql_3(startcnt_1) := plsql_tmp_1(j);
                   startcnt_1 := startcnt_1 +1;
                 END LOOP;
               END LOOP;
             END IF;
           END IF;
         END IF;
       END LOOP;
     END IF;

-- --End of CPC has more priority than GPA and ECP----------------------------------

-- --Begin of ECP has more priority than GPA and CPC----------------------------------

     IF ecp_ord < gpa_ord AND ecp_ord < cpc_ord THEN -- ECP has more priority than GPA and CPC
       plsql_3 := enrp_ecp_sort(p_plsql_2,p_surname_alpha);
       FOR i IN 1 .. plsql_3.COUNT LOOP
         IF i < plsql_3.COUNT AND plsql_3(i).ecp = plsql_3(i+1).ecp AND NOT started_1 THEN
           started_1 := TRUE;
           startcnt_1 := i;
           cnt_1 := 0;
           plsql_tmp_1 := plsql_empty; -- assigning empty plsql table to erase the content
         END IF;
         IF started_1 THEN
           cnt_1 := cnt_1 +1 ;
           plsql_tmp_1(cnt_1) := plsql_3(i);
           IF i = plsql_3.COUNT OR plsql_3(i).ecp <> plsql_3(i+1).ecp THEN
             started_1 := FALSE;
             IF gpa_ord < cpc_ord THEN -- GPA has more priority than CPC
               plsql_tmp_1 := enrp_gpa_sort(plsql_tmp_1,p_surname_alpha);
               started_2 := FALSE;
               startcnt_2 := 1;
               cnt_2 := 0 ;
               FOR j IN 1 .. plsql_tmp_1.COUNT LOOP
                 IF j < plsql_tmp_1.COUNT AND plsql_tmp_1(j).gpa = plsql_tmp_1(j+1).gpa AND
                    NOT started_2 THEN
                   started_2 := TRUE;
                   startcnt_2 := j;
                   cnt_2 := 0;
                   plsql_tmp_2 := plsql_empty; -- assigning empty plsql table to erase the content
                 END IF;
                 IF started_2 THEN
                   cnt_2 := cnt_2 +1 ;
                   plsql_tmp_2(cnt_2) := plsql_tmp_1(j);
                   IF j = plsql_tmp_1.COUNT OR plsql_tmp_1(j).gpa <> plsql_tmp_1(j+1).gpa THEN
                     started_2 := FALSE;
                     plsql_tmp_2 := enrp_cpc_sort(plsql_tmp_2,p_surname_alpha);
                     FOR k IN 1 .. plsql_tmp_2.COUNT LOOP
                       plsql_tmp_1(startcnt_2) := plsql_tmp_2(k);
                       startcnt_2 := startcnt_2 +1;
                     END LOOP;
                   END IF;
                 END IF;
                 FOR k IN 1 .. plsql_tmp_2.COUNT LOOP
                   plsql_3(startcnt_1) := plsql_tmp_1(j);
                   startcnt_1 := startcnt_1 +1;
                 END LOOP;
               END LOOP;
             ELSIF cpc_ord < gpa_ord THEN -- CPC has more priority than GPA
               plsql_tmp_1 := enrp_cpc_sort(plsql_tmp_1,p_surname_alpha);
               started_2 := FALSE;
               startcnt_2 := 1;
               cnt_2 := 0 ;
               FOR j IN 1 .. plsql_tmp_1.COUNT LOOP
                 IF j < plsql_tmp_1.COUNT AND plsql_tmp_1(j).cpc = plsql_tmp_1(j+1).cpc AND
                    NOT started_2 THEN
                   started_2 := TRUE;
                   startcnt_2 := j;
                   cnt_2 := 0;
                   plsql_tmp_2 := plsql_empty; -- assigning empty plsql table to erase the content
                 END IF;
                 IF started_2 THEN
                   cnt_2 := cnt_2 +1 ;
                   plsql_tmp_2(cnt_2) := plsql_tmp_1(j);
                   IF j = plsql_tmp_1.COUNT OR plsql_tmp_1(j).cpc <> plsql_tmp_1(j+1).cpc THEN
                     started_2 := FALSE;
                     plsql_tmp_2 := enrp_gpa_sort(plsql_tmp_2,p_surname_alpha);
                     FOR k IN 1 .. plsql_tmp_2.COUNT LOOP
                       plsql_tmp_1(startcnt_2) := plsql_tmp_2(k);
                       startcnt_2 := startcnt_2 +1;
                     END LOOP;
                   END IF;
                 END IF;
                 FOR k IN 1 .. plsql_tmp_2.COUNT LOOP
                   plsql_3(startcnt_1) := plsql_tmp_1(j);
                   startcnt_1 := startcnt_1 +1;
                 END LOOP;
               END LOOP;
             END IF;
           END IF;
         END IF;
       END LOOP;
     END IF;

-- --End of ECP has more priority than GPA and CPC----------------------------------

-- --Begin of GPA has more priority than CPC------------------------------------------

  ELSIF gpa_ord <= p_pointer AND gpa_ord <> 0 AND
        cpc_ord <= p_pointer AND cpc_ord <> 0 AND
        ecp_ord = 0 THEN
     IF gpa_ord < cpc_ord THEN -- GPA has more priority than CPC
            plsql_3 := enrp_gpa_sort(p_plsql_2,p_surname_alpha);
                FOR i IN 1 .. plsql_3.COUNT LOOP
                   IF i < plsql_3.COUNT AND plsql_3(i).gpa = plsql_3(i+1).gpa AND NOT started THEN
                      started := TRUE;
                      startcnt := i;
                      cnt := 0;
                      plsql_tmp := plsql_empty; -- assigning empty plsql table to erase the content
                   END IF;
                   IF started THEN
                     cnt := cnt +1 ;
                     plsql_tmp(cnt) := plsql_3(i);
                     IF i = plsql_3.COUNT OR plsql_3(i).gpa <> plsql_3(i+1).gpa THEN
                       started := FALSE;
                       plsql_tmp := enrp_cpc_sort(plsql_tmp,p_surname_alpha);
                       FOR j IN 1 .. plsql_tmp.COUNT LOOP
                          plsql_3(startcnt) := plsql_tmp(j);
                          startcnt := startcnt +1;
                       END LOOP;
                     END IF;
                   END IF;
                END LOOP;
     ELSE -- CPC has more priority than GPA
            plsql_3 := enrp_cpc_sort(p_plsql_2,p_surname_alpha);
                FOR i IN 1 .. plsql_3.COUNT LOOP
                   IF i < plsql_3.COUNT AND plsql_3(i).cpc = plsql_3(i+1).cpc AND NOT started THEN
                      started := TRUE;
                      startcnt := i;
                      cnt := 0;
                      plsql_tmp := plsql_empty; -- assigning empty plsql table to erase the content
                   END IF;
                   IF started THEN
                     cnt := cnt +1 ;
                     plsql_tmp(cnt) := plsql_3(i);
                     IF i = plsql_3.COUNT OR plsql_3(i).cpc <> plsql_3(i+1).cpc THEN
                       started := FALSE;
                       plsql_tmp := enrp_gpa_sort(plsql_tmp,p_surname_alpha);
                       FOR j IN 1 .. plsql_tmp.COUNT LOOP
                          plsql_3(startcnt) := plsql_tmp(j);
                          startcnt := startcnt +1;
                       END LOOP;
                     END IF;
                   END IF;
                END LOOP;
     END IF;

-- --End of GPA has more priority than CPC------------------------------------------

-- --Begin of GPA has more priority than ECP------------------------------------------

  ELSIF gpa_ord <= p_pointer AND gpa_ord <> 0 AND
        ecp_ord <= p_pointer AND ecp_ord <> 0 AND
        cpc_ord = 0 THEN
     IF gpa_ord < ecp_ord THEN -- GPA has more priority than ECP
            plsql_3 := enrp_gpa_sort(p_plsql_2,p_surname_alpha);
                FOR i IN 1 .. plsql_3.COUNT LOOP
                   IF i < plsql_3.COUNT AND plsql_3(i).gpa = plsql_3(i+1).gpa AND NOT started THEN
                      started := TRUE;
                      startcnt := i;
                      cnt := 0;
                      plsql_tmp := plsql_empty; -- assigning empty plsql table to erase the content
                   END IF;
                   IF started THEN
                     cnt := cnt +1 ;
                     plsql_tmp(cnt) := plsql_3(i);
                     IF i = plsql_3.COUNT OR plsql_3(i).gpa <> plsql_3(i+1).gpa THEN
                       started := FALSE;
                       plsql_tmp := enrp_ecp_sort(plsql_tmp,p_surname_alpha);
                       FOR j IN 1 .. plsql_tmp.COUNT LOOP
                          plsql_3(startcnt) := plsql_tmp(j);
                          startcnt := startcnt +1;
                       END LOOP;
                     END IF;
                   END IF;
                END LOOP;
     ELSE -- ECP has more priority than GPA
            plsql_3 := enrp_ecp_sort(p_plsql_2,p_surname_alpha);
                FOR i IN 1 .. plsql_3.COUNT LOOP
                   IF i < plsql_3.COUNT AND plsql_3(i).ecp = plsql_3(i+1).ecp AND NOT started THEN
                      started := TRUE;
                      startcnt := i;
                      cnt := 0;
                      plsql_tmp := plsql_empty; -- assigning empty plsql table to erase the content
                   END IF;
                   IF started THEN
                     cnt := cnt +1 ;
                     plsql_tmp(cnt) := plsql_3(i);
                     IF i = plsql_3.COUNT OR plsql_3(i).ecp <> plsql_3(i+1).ecp THEN
                       started := FALSE;
                       plsql_tmp := enrp_gpa_sort(plsql_tmp,p_surname_alpha);
                       FOR j IN 1 .. plsql_tmp.COUNT LOOP
                          plsql_3(startcnt) := plsql_tmp(j);
                          startcnt := startcnt +1;
                       END LOOP;
                     END IF;
                   END IF;
                END LOOP;
     END IF;

-- --End of GPA has more priority than ECP------------------------------------------

-- --Begin of CPC has more priority than ECP------------------------------------------

  ELSIF cpc_ord <= p_pointer AND cpc_ord <> 0 AND
        ecp_ord <= p_pointer AND ecp_ord <> 0 AND
        gpa_ord = 0 THEN
     IF cpc_ord < ecp_ord THEN -- CPC has more priority than ECP
            plsql_3 := enrp_cpc_sort(p_plsql_2,p_surname_alpha);
                FOR i IN 1 .. plsql_3.COUNT LOOP
                   IF i < plsql_3.COUNT AND plsql_3(i).cpc = plsql_3(i+1).cpc AND NOT started THEN
                      started := TRUE;
                      startcnt := i;
                      cnt := 0;
                      plsql_tmp := plsql_empty; -- assigning empty plsql table to erase the content
                   END IF;
                   IF started THEN
                     cnt := cnt +1 ;
                     plsql_tmp(cnt) := plsql_3(i);
                     IF i = plsql_3.COUNT OR plsql_3(i).cpc <> plsql_3(i+1).cpc THEN
                       started := FALSE;
                       plsql_tmp := enrp_ecp_sort(plsql_tmp,p_surname_alpha);
                       FOR j IN 1 .. plsql_tmp.COUNT LOOP
                          plsql_3(startcnt) := plsql_tmp(j);
                          startcnt := startcnt +1;
                       END LOOP;
                     END IF;
                   END IF;
                END LOOP;
     ELSE -- ECP has more priority than CPC
            plsql_3 := enrp_ecp_sort(p_plsql_2,p_surname_alpha);
                FOR i IN 1 .. plsql_3.COUNT LOOP
                   IF i < plsql_3.COUNT AND plsql_3(i).ecp = plsql_3(i+1).ecp AND NOT started THEN
                      started := TRUE;
                      startcnt := i;
                      cnt := 0;
                      plsql_tmp := plsql_empty; -- assigning empty plsql table to erase the content
                   END IF;
                   IF started THEN
                     cnt := cnt +1 ;
                     plsql_tmp(cnt) := plsql_3(i);
                     IF i = plsql_3.COUNT OR plsql_3(i).ecp <> plsql_3(i+1).ecp THEN
                       started := FALSE;
                       plsql_tmp := enrp_cpc_sort(plsql_tmp,p_surname_alpha);
                       FOR j IN 1 .. plsql_tmp.COUNT LOOP
                          plsql_3(startcnt) := plsql_tmp(j);
                          startcnt := startcnt +1;
                       END LOOP;
                     END IF;
                   END IF;
                END LOOP;
     END IF;

-- --End of CPC has more priority than ECP------------------------------------------

-- having only GPA in the set of priorities
  ELSIF gpa_ord <= p_pointer AND gpa_ord <> 0 AND
        cpc_ord = 0 AND ecp_ord = 0 THEN
    plsql_3 := enrp_gpa_sort(p_plsql_2,p_surname_alpha);

-- having only CPC in the set of priorities
  ELSIF cpc_ord <= p_pointer AND cpc_ord <> 0 AND
        gpa_ord = 0 AND ecp_ord = 0 THEN
    plsql_3 := enrp_cpc_sort(p_plsql_2,p_surname_alpha);

-- having only ECP in the set of priorities
  ELSIF ecp_ord <= p_pointer AND ecp_ord <> 0 AND
        gpa_ord = 0 AND cpc_ord = 0 THEN
    plsql_3 := enrp_ecp_sort(p_plsql_2,p_surname_alpha);
  ELSE
    plsql_3 := enrp_alpha_sort(p_plsql_2,p_surname_alpha);
  END IF;

  FOR i IN 1 .. plsql_3.COUNT LOOP
    cnt4 := cnt4 + 1; -- cnt4 variable is declared in package spec.
    plsql_4(cnt4).person_id := plsql_3(i).person_id;
    plsql_4(cnt4).last_name := plsql_3(i).last_name;
  END LOOP;

 EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','Igs_en_timeslots.enrp_sort_mngt');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END enrp_sort_mngt;

---------------------------------------------------
PROCEDURE enrp_recur_sort(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  KNAG.IN         12-APR-2001     Included enrollment credit point
                                  priority in timeslot allocation
                                  as per enh bug 1710227
  (reverse chronological order - newest change first)
  Nishikant       23JUL2002       Bug#2443771. The cursor cur_max_prty_ord and cur_prty got modified.
                                  Also the value assigned to the variabke max_prty_ord from the cursor
                                  cur_max_prty_ord before using it down the line.
  svanukur        08jul2003       checking for NVL of max_prty_ord as part of bug 3039661
  ***************************************************************/

  p_plsql_2 IN OUT NOCOPY plsql_table_1,
  p_surname_alpha IN VARCHAR2,
  p_ts_stup_id IN NUMBER,
  p_pointer IN NUMBER
)  IS

CURSOR cur_max_prty_ord IS
  SELECT MAX(priority_order)
  FROM igs_en_timeslot_prty prt
  WHERE prt.igs_en_timeslot_stup_id = p_ts_stup_id; -- Added the where condition by Nishikant - 23JUL2002 - bug#2443771

CURSOR cur_prty_pref(p_IGS_EN_TIMESLOT_STUP_ID NUMBER,p_order NUMBER) IS
  SELECT prt.priority_value,prf.preference_code,prf.preference_version,prf.sequence_number
  FROM igs_en_timeslot_prty prt,
       igs_en_timeslot_pref prf
  WHERE prt.IGS_EN_TIMESLOT_STUP_ID = p_IGS_EN_TIMESLOT_STUP_ID AND
        prt.priority_order = p_order AND
        prt.igs_en_timeslot_prty_id = prf.igs_en_timeslot_prty_id
        order by prt.priority_order, prf.preference_order;

CURSOR cur_prty(p_order NUMBER) IS
  SELECT priority_value
  FROM igs_en_timeslot_prty  prt
  WHERE priority_order = p_order
  AND   prt.igs_en_timeslot_stup_id = p_ts_stup_id; -- Added the AND condition by Nishikant - 23JUL2002 - bug#2443771

        plsql_3 plsql_table_1;
        cnt NUMBER :=  0;
        prty_value igs_en_timeslot_prty.priority_value%TYPE;
        max_prty_ord igs_en_timeslot_prty.priority_order%TYPE;
BEGIN
  OPEN  cur_max_prty_ord;                          -- Code added by Nishikant - 23JUL2002 - bug#2443771
  FETCH cur_max_prty_ord INTO max_prty_ord;        -- Fetching to the variable max_prty_ord
  CLOSE cur_max_prty_ord;                          -- Before using it down the line.

  FOR cur_prty_pref_rec_2 IN cur_prty_pref(p_ts_stup_id,p_pointer) LOOP
     -- All the students are already moved into plsql_4 table( Result Table)
         IF p_plsql_2.COUNT = 0 THEN
           EXIT;
         END IF;
         plsql_3 := enrp_cur_criteria(
                                p_plsql_2,
                                cur_prty_pref_rec_2.priority_value,
                                cur_prty_pref_rec_2.preference_code,
                                cur_prty_pref_rec_2.preference_version,
                                cur_prty_pref_rec_2.sequence_number,
                                p_pointer,
                                p_ts_stup_id);
         Fnd_Message.SET_NAME ('IGS','IGS_EN_TS_PR_PF_PV');
         Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||cur_prty_pref_rec_2.priority_value
                                ||':'||cur_prty_pref_rec_2.preference_code||':'||cur_prty_pref_rec_2.preference_version
                                ||':'||cur_prty_pref_rec_2.sequence_number);
         Fnd_Message.SET_NAME ('IGS','IGS_EN_TS_STD_SAT_PR');
         Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||plsql_3.COUNT);

    IF p_pointer = nvl(max_prty_ord,0) THEN
      enrp_sort_mngt(plsql_3,p_surname_alpha,p_pointer);
      plsql_3 := plsql_empty;
    ELSE
-- call to recursive function to sort on further priorities
      enrp_recur_sort(plsql_3,p_surname_alpha,p_ts_stup_id,p_pointer+1);
      plsql_3 := plsql_empty;
    END IF;
  END LOOP; -- cur_prty_pref_rec_2
-- To handle the case where GPA/CPC/ECP is the last priority,so for the remaining records apply only Alphabetic sort.
-- resetting of these values will be useful in function enrp_sort_mngt
  OPEN  cur_prty(p_pointer);
  FETCH cur_prty INTO prty_value;
  IF prty_value = 'GPA' THEN
    gpa_ord := 0;
  ELSIF prty_value = 'TOTAL_CP' THEN
    cpc_ord := 0;
  ELSIF prty_value = 'ENRCP_ASC' OR prty_value = 'ENRCP_DESC' THEN
    ecp_ord := 0;
  END IF;
  CLOSE cur_prty;
-- sort the remaining students in p_plsql_2 and insert them into plsql_4
IF p_plsql_2.COUNT > 0 THEN
  enrp_sort_mngt(p_plsql_2,p_surname_alpha,p_pointer);
END IF;

END enrp_recur_sort;

--------------------------------------------------------------------------
PROCEDURE enrp_rslt_ins_timeslot(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

p_plsql_4 IN plsql_table_2,
p_plsql_5 IN plsql_table_3,
p_max_head_count IN NUMBER,
p_igs_en_timeslot_para_id IN NUMBER,
p_length_of_time IN NUMBER) AS

  cnt_4 NUMBER :=   0;
  l_rowid VARCHAR2(25);
  l_igs_en_timeslot_rslt_id VARCHAR2(25);

BEGIN
-- if the length of time is unlimited
  IF p_length_of_time = 0 THEN
    FOR i IN 1 .. plsql_4.COUNT LOOP
          l_rowid := null;
          Igs_En_Timeslot_Rslt_Pkg.insert_row ( x_rowid => l_rowid,
                                                x_igs_en_timeslot_rslt_id => l_igs_en_timeslot_rslt_id,
                                                x_igs_en_timeslot_para_id => p_igs_en_timeslot_para_id,
                                                x_person_id => p_plsql_4(i).person_id,
                                                x_start_dt_time => p_plsql_5(1).start_dt_time,
                                                x_end_dt_time => p_plsql_5(1).end_dt_time,
                                                x_mode => 'R');
    END LOOP;
 ELSE
  FOR i IN 1 .. p_plsql_5.COUNT LOOP
    FOR j IN 1 .. p_max_head_count LOOP
          cnt_4 := cnt_4 +1;
          l_rowid := null;
          Igs_En_Timeslot_Rslt_Pkg.insert_row ( x_rowid => l_rowid,
                                                x_igs_en_timeslot_rslt_id => l_igs_en_timeslot_rslt_id,
                                                x_igs_en_timeslot_para_id => p_igs_en_timeslot_para_id,
                                                x_person_id => p_plsql_4(cnt_4).person_id,
                                                x_start_dt_time => p_plsql_5(i).start_dt_time,
                                                x_end_dt_time => p_plsql_5(i).end_dt_time,
                                                x_mode => 'R');
          IF cnt_4 >= p_plsql_4.COUNT THEN
             EXIT;
          END IF;
    END LOOP; -- j
      IF cnt_4 >= p_plsql_4.COUNT THEN
         EXIT;
      END IF;
  END LOOP; -- i
-- if unassigned students are there, then inserting into result table with NULL start And end date_time
  IF cnt_4 < plsql_4.COUNT THEN
    FOR i IN cnt_4 + 1 .. plsql_4.COUNT LOOP
          l_rowid := null;
          Igs_En_Timeslot_Rslt_Pkg.insert_row ( x_rowid => l_rowid,
                                                x_igs_en_timeslot_rslt_id => l_igs_en_timeslot_rslt_id,
                                                x_igs_en_timeslot_para_id => p_igs_en_timeslot_para_id,
                                                x_person_id => p_plsql_4(i).person_id,
                                                x_start_dt_time => NULL,
                                                x_end_dt_time => NULL,
                                                x_mode => 'R');
    END LOOP;
  END IF; -- cnt_4
END IF;--p_length_of_time = 0

 EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','Igs_en_timeslots.enrp_rslt_ins_timeslot');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END enrp_rslt_ins_timeslot;

---------------------------------------------------------------------------
PROCEDURE enrp_assign_timeslot(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  KNAG.IN         12-APR-2001     Included enrollment credit point
                                  priority in timeslot allocation
                                  as per enh bug 1710227
  (reverse chronological order - newest change first)
  Nishikant       23JUL2002       Bug#2443771. The cursor cur_max_prty_ord got modified to include the where condition.
                                  The cursor cur_assign_ran_alpha got modified to select surname_alphabet also. The cursor cur_alpha
                                  which was existing for selecting the surname_alphabet got removed.
  svanukur        08jul2003       modified the check for variable max_prty_ord ,if it is null instead of
                                  checking if the cur_max_prty_ord cursor is not found since an aggregate function is used.
                                  as part of bug 3039661
  ckasu           17-JAN-2006     Added igs_ge_gen_003.set_org_id(NULL); as a prt of bug#4958173.
  ***************************************************************/

ERRBUF OUT NOCOPY VARCHAR2,
RETCODE OUT NOCOPY NUMBER,
p_prg_type_gr_cd IN VARCHAR2,
p_cal_type IN VARCHAR2,
p_seq_num IN NUMBER,
p_stud_type IN VARCHAR2,
p_timeslot IN VARCHAR2,
p_start_date IN DATE,
p_end_date IN DATE,
p_max_headcount IN NUMBER,
p_length_of_time IN NUMBER,
p1_start_time IN VARCHAR2,
p1_end_time IN VARCHAR2,
p_mode IN VARCHAR2,
p_orgid IN NUMBER
)  AS

CURSOR cur_max_prty_ord(p_igs_en_timeslot_stup_id NUMBER) IS -- Added the parameters of the cursor by Nishikant - 23JUL2002 - bug#2443771
  SELECT MAX(priority_order)
  FROM igs_en_timeslot_prty prt
  WHERE prt.igs_en_timeslot_stup_id = p_igs_en_timeslot_stup_id; -- Added the where condition by Nishikant - 23JUL2002 - bug#2443771

CURSOR cur_ts_stup_id(p_prg_type_gr_cd VARCHAR2, p_cal_type VARCHAR2, p_seq_num NUMBER, p_stud_type VARCHAR2) IS
  SELECT  ets.IGS_EN_TIMESLOT_STUP_ID
    FROM igs_en_timeslot_stup ets
    WHERE ets.PROGRAM_TYPE_GROUP_CD = p_prg_type_gr_cd AND
          ets.CAL_TYPE = p_cal_type AND
          ets.SEQUENCE_NUMBER = p_seq_num AND
          ets.STUDENT_TYPE = p_stud_type;

CURSOR cur_prty_pref(p_IGS_EN_TIMESLOT_STUP_ID NUMBER,p_order NUMBER) IS
  SELECT prt.priority_value,prf.preference_code,prf.preference_version,prf.sequence_number
    FROM igs_en_timeslot_prty prt,
         igs_en_timeslot_pref prf
    WHERE prt.IGS_EN_TIMESLOT_STUP_ID = p_IGS_EN_TIMESLOT_STUP_ID AND
          prt.priority_order = p_order AND
          prt.igs_en_timeslot_prty_id = prf.igs_en_timeslot_prty_id
          order by prf.preference_order;

  CURSOR cur_assign_ran_alpha IS
    SELECT ets.ASSIGN_RANDOMLY, ets.SURNAME_ALPHABET
    FROM igs_en_timeslot_stup ets
    WHERE ets.PROGRAM_TYPE_GROUP_CD = p_prg_type_gr_cd AND
          ets.CAL_TYPE = p_cal_type AND
          ets.SEQUENCE_NUMBER = p_seq_num AND
          ets.STUDENT_TYPE = p_stud_type;

  CURSOR cur_mode_check IS
  SELECT etp.ROWID,etp.igs_en_timeslot_para_id,etp.ts_mode
  FROM igs_en_timeslot_para etp
  WHERE etp.program_type_group_cd = p_prg_type_gr_cd  AND
        etp.student_type = p_stud_type AND
        etp.cal_type = p_cal_type AND
        etp.sequence_number = p_seq_num AND
        etp.timeslot_calendar = p_timeslot;

  CURSOR cur_rslt(p_igs_en_timeslot_para_id igs_en_timeslot_para.igs_en_timeslot_para_id%TYPE) IS
    SELECT tsr.ROWID row_id
    FROM Igs_En_Timeslot_Rslt tsr
    WHERE tsr.igs_en_timeslot_para_id = p_igs_en_timeslot_para_id;

  p_start_time DATE ;
  p_end_time DATE ;
  l_ts_para_id igs_en_timeslot_para.igs_en_timeslot_para_id%TYPE;
  l_ts_stup_id  igs_en_timeslot_stup.IGS_EN_TIMESLOT_STUP_ID%TYPE;
  surname_alpha igs_en_timeslot_stup.SURNAME_ALPHABET%TYPE;
  assign_random igs_en_timeslot_stup.ASSIGN_RANDOMLY%TYPE;
  max_prty_ord igs_en_timeslot_prty.priority_order%TYPE;

  plsql_1 plsql_table_1  ;
  plsql_2 plsql_table_1;
  plsql_5 plsql_table_3;
  l_rowid VARCHAR2(25);
  l_igs_en_timeslot_para_id NUMBER;
  l_ts_mode varchar2(1);
BEGIN

RETCODE :=0;
igs_ge_gen_003.set_org_id(NULL);

  p_start_time  :=   TO_DATE(p1_start_time,'DD/MM/YYYY HH24:MI');
  p_end_time  :=   TO_DATE(p1_end_time,'DD/MM/YYYY HH24:MI');

-- getting the FK Value of setup table
  OPEN cur_ts_stup_id(p_prg_type_gr_cd ,p_cal_type ,p_seq_num,p_stud_type ) ;
  FETCH cur_ts_stup_id INTO l_ts_stup_id;
  CLOSE cur_ts_stup_id ;

  plsql_1 := enrp_total_students(p_prg_type_gr_cd ,p_stud_type ,p_cal_type ,p_seq_num);

  Fnd_Message.SET_NAME ('IGS','IGS_EN_TS_STD_SAT_CRI');
  Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||plsql_1.COUNT);
  OPEN cur_assign_ran_alpha;
  FETCH cur_assign_ran_alpha INTO assign_random, surname_alpha; -- Assigned here to surname_alpha also by Nishikant - 23JUL2002 - bug#2443771
  CLOSE cur_assign_ran_alpha;

-- If assigning the timeslots randomly/if time is unlimited then no need to sort
IF p_length_of_time = 0 OR assign_random = 'Y' THEN
  Fnd_Message.SET_NAME ('IGS','IGS_EN_TS_ASSGN_RAN');
  Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET);
  FOR i IN 1 .. plsql_1.COUNT LOOP
    cnt4 := cnt4 + 1; -- cnt4 variable is declared in package spec.
    plsql_4(cnt4).person_id := plsql_1(i).person_id;
    plsql_4(cnt4).last_name := plsql_1(i).last_name;
  END LOOP;
ELSE
  OPEN cur_max_prty_ord(l_ts_stup_id);
  FETCH cur_max_prty_ord INTO max_prty_ord;
-- No Priorities were defined
  IF max_prty_ord IS NULL THEN
    max_prty_ord :=0;
  END IF;
  CLOSE cur_max_prty_ord;
  FOR i IN 1 .. max_prty_ord LOOP
    -- All the students are already moved into plsql_4 table( Result Table)
    IF plsql_1.COUNT = 0 THEN
        EXIT;
    END IF;
    FOR cur_prty_pref_rec_1 IN cur_prty_pref(l_ts_stup_id,i) LOOP
      -- All the students are already moved into plsql_4 table( Result Table)
          IF plsql_1.COUNT = 0 THEN
            EXIT;
          END IF;
          plsql_2 := enrp_cur_criteria(
                        plsql_1,
                        cur_prty_pref_rec_1.priority_value,
                        cur_prty_pref_rec_1.preference_code,
                        cur_prty_pref_rec_1.preference_version,
                        cur_prty_pref_rec_1.sequence_number,
                        i,
                        l_ts_stup_id);
          Fnd_Message.SET_NAME ('IGS','IGS_EN_TS_PR_PF_PV');
          Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||cur_prty_pref_rec_1.priority_value
                                ||':'||cur_prty_pref_rec_1.preference_code||':'||cur_prty_pref_rec_1.preference_version
                                ||':'||cur_prty_pref_rec_1.sequence_number);
          Fnd_Message.SET_NAME ('IGS','IGS_EN_TS_STD_SAT_PR');
          Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||plsql_2.COUNT);
          IF i < max_prty_ord THEN
             -- call to recursive function to sort according to priority And preferences
             enrp_recur_sort(plsql_2,surname_alpha,l_ts_stup_id,i+1);
          ELSE
             -- call the function, which sorts the records with pointer = i and insert into plsql_4
             enrp_sort_mngt(plsql_2,surname_alpha,i);
          END IF;
    END LOOP; -- cur_prty_pref_rec_1
  END LOOP; -- max_prty_ord
  Fnd_Message.SET_NAME ('IGS','IGS_EN_TS_STD_NOT_SAT');
  Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||plsql_1.COUNT);
  -- sort the remaining students in plsql_1 and insert them into plsql_4
  plsql_2 := enrp_alpha_sort(plsql_1,surname_alpha);
  FOR i IN 1 .. plsql_2.COUNT LOOP
    cnt4 := cnt4 + 1; -- cnt4 variable is declared in package spec.
    plsql_4(cnt4).person_id := plsql_2(i).person_id;
    plsql_4(cnt4).last_name := plsql_2(i).last_name;
  END LOOP;
END IF; -- p_length_of_time

-- calculate the number of Tim slot sessions in the given Timeslot with the given "length of time"
  plsql_5 := enrp_calc_slots(p_start_time,
                             p_end_time,
                             p_start_date,
                             p_end_date,
                             p_length_of_time);
 Fnd_Message.SET_NAME ('IGS','IGS_EN_TS_TOT_TS_SES');
 Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET||plsql_5.COUNT );

-- If the same Criteria has run in Trial Mode, then delete the existing records and insert the new set of data
OPEN cur_mode_check;
FETCH cur_mode_check INTO l_rowid ,l_ts_para_id , l_ts_mode;
IF cur_mode_check%FOUND THEN
  IF l_ts_mode = 'T' THEN
    FOR cur_rslt_rec IN cur_rslt(l_ts_para_id) LOOP
      Igs_En_Timeslot_Rslt_Pkg.delete_row(x_rowid => cur_rslt_rec.row_id);
    END LOOP;
    Igs_En_Timeslot_Para_Pkg.delete_row(x_rowid => l_rowid);
  ELSIF l_ts_mode = 'F' THEN
     fnd_message.set_name('IGS','IGS_EN_TS_CRI_FINAL_AL');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
  END IF;
END IF;
CLOSE cur_mode_check;

-- insertion of parameters into Parameter Table
  Igs_En_Timeslot_Para_Pkg.insert_row(x_rowid => l_rowid,
    x_igs_en_timeslot_para_id => l_igs_en_timeslot_para_id,
    x_program_type_group_cd => p_prg_type_gr_cd,
    x_cal_type => p_cal_type,
    x_sequence_number => p_seq_num,
    x_student_type => p_stud_type,
    x_timeslot_calendar => p_timeslot,
    x_timeslot_st_time => p_start_time,
    x_timeslot_end_time => p_end_time,
    x_ts_mode => p_mode,
    x_max_head_count => p_max_headcount,
    x_length_of_time => p_length_of_time,
    x_mode  => 'R',
    x_org_id => p_orgid);

-- inserting results of timeslot assignment into results Table
enrp_rslt_ins_timeslot(plsql_4,plsql_5,p_max_headcount,l_igs_en_timeslot_para_id,p_length_of_time);

Fnd_Message.SET_NAME ('IGS','IGS_EN_TS_COMP_SUSS');
Fnd_File.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET);
plsql_4 := plsql_empty_4;
cnt4:=0;

EXCEPTION
        WHEN OTHERS THEN
          retcode:=2;
          Fnd_File.PUT_LINE(Fnd_File.LOG,'Error due to :'||sqlerrm);
          ERRBUF := Fnd_Message.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
          IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END enrp_assign_timeslot;

--------------------------------------------------------------------------

FUNCTION acad_teach_rel_exist(
  /*************************************************************
  Created By : Nishikant
  Date Created By : 23JUL2002
  Purpose :  Created while fix of the Bug#2443771. To check the relationship exists between
             the Academic Calendar Type and Teach Calendar Type passed as parameters.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
             p_acad_cal_type   IN VARCHAR2,
             p_teach_cal_type  IN VARCHAR2,
             p_teach_seq_num   IN NUMBER)
RETURN VARCHAR2 AS
     CURSOR cur_find_rel IS
       SELECT 'x' FROM  igs_ca_inst_rel cir2
       WHERE  cir2.sup_cal_type = p_acad_cal_type
       AND    cir2.sub_cal_type = p_teach_cal_type
       AND    cir2.sub_ci_sequence_number = p_teach_seq_num;
     l_dummy VARCHAR2(1);
BEGIN
  OPEN cur_find_rel;
  FETCH cur_find_rel INTO l_dummy;
  CLOSE cur_find_rel;
  IF l_dummy = 'x' THEN
    RETURN 'TRUE';
  ELSE
    RETURN 'FALSE';
  END IF;
END acad_teach_rel_exist;

FUNCTION enrp_total_students(
  /*************************************************************
  Created By : sraj
  Date Created By : 2000/13/05
  Purpose : To set the column values before inserting.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  Nishikant       20DEC2002       Bug#2712493. The cursors cur_total_enrled_stdnts and cur_total_admted_stdnts got
                                  modified to select properly the students under 'Enrolled' and 'Admitted' category.
  Nishikant       23JUL2002       The cursor cur_total_admted_stdnts got modified to consider the students
                                  enrolled directly through the Student Enrollments form.
 rnirwani   13-Sep-2004    changed cursor cur_total_enrled_stdnts to not consider logically deleted records. Bug# 3885804
 smaddali   20-sep-2004   Modified for cursor cur_total_enrled_stdnts bug#3918075, to add outer join between intermissions and program attempts
 stutta     17-Feb-2006   Modified cursor cur_total_admted_stdnts for perf bug#5042384
  (reverse chronological order - newest change first)
  ***************************************************************/

p_prg_type_gr_cd IN VARCHAR2,
p_stdnt_type IN VARCHAR2,
p_cal_type IN VARCHAR2,
p_seq_num IN NUMBER)
RETURN plsql_table_1 AS

--Bug#2712493. The below cursor got modified to select students in "Enrolled" category as below
--Entered through Student Enrollments, having program attempt of status ENROLLED.
--And students having program status INACTIVE and have at least one unit attempt(of any status).
--And students having program attempts of INTERMIT status where the end date of the intermission should
--  be before the start date of the calendar instance provided.
-- smaddali modified for bug#3918075, to move intermissions join to a subquery
CURSOR cur_total_enrled_stdnts(p_start_dt DATE )  IS
SELECT DISTINCT (pe.person_id) person_id ,pe.last_name
FROM   igs_en_stdnt_ps_att sca,
       igs_pe_person_base_v pe,
       igs_ps_ver pv,
       igs_ps_type pt
WHERE  pe.person_id = sca.person_id AND
       pv.course_cd = sca.course_cd AND
       pv.course_type = pt.course_type AND
       pt.course_type_group_cd = p_prg_type_gr_cd AND
       ( sca.course_attempt_status = 'ENROLLED'
         OR
         ( sca.course_attempt_status = 'INTERMIT' AND
           EXISTS (SELECT 'X' FROM   igs_en_stdnt_ps_intm sci,  igs_en_intm_types eit  WHERE
           sci.end_dt    < p_start_dt AND
           sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY') AND
           sca.person_id  = sci.person_id AND
           sca.course_cd  = sci.course_cd AND
           sci.approved  = eit.appr_reqd_ind AND
           eit.intermission_type = sci.intermission_type )
         )
         OR
         ( sca.course_attempt_status = 'INACTIVE'
           AND EXISTS ( SELECT 'X'
                        FROM   IGS_EN_SU_ATTEMPT
                        WHERE  person_id = sca.person_id
                        AND    course_cd = sca.course_cd
                      )
         )
       );

--Bug#2712493. The Below cursor got modified to select students in "Admitted" category as below
--1. Entered through Direct Admission, having program attempt of status INACTIVE  or UNCONFIRM,
--   where the application exists in application instance table and admission calendar is
--   subordinate to the teaching calendar.
--2. Entered through Student Enrollments, having program attempt of status INACTIVE and is not
--   having any unit attempts.
CURSOR cur_total_admted_stdnts(cp_cal_type IGS_CA_INST.CAL_TYPE%TYPE, cp_seq_num IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS

SELECT sca.person_id person_id ,(select person_last_name from hz_parties where party_id = sca.person_id) last_name
    FROM  IGS_EN_STDNT_PS_ATT_ALL sca,
          igs_ps_ver_all pv,
          igs_ps_type_all pt,
	  IGS_AD_PS_APPL_INST_all acai,
	  IGS_AD_APPL_all aav,
	  IGS_CA_INST_REL cir
    WHERE pv.course_cd = sca.course_cd AND
          pv.version_number = sca.version_number AND
          sca.course_attempt_status IN ('INACTIVE','UNCONFIRM') AND
          pv.course_type = pt.course_type AND
          pt.course_type_group_cd =  p_prg_type_gr_cd  AND
	  acai.person_id = sca.person_id AND
	  sca.course_cd  = acai.course_cd AND
          sca.version_number  = acai.crv_version_number AND
	  aav.person_id = acai.person_id  AND
          aav.admission_appl_number =  acai.admission_appl_number AND
	  aav.adm_cal_type =  cir.SUB_CAL_TYPE  AND
          aav.adm_ci_sequence_number = cir.SUB_CI_SEQUENCE_NUMBER AND
	  ((cir.sup_cal_type = cp_cal_type AND
          cir.sup_ci_sequence_number = cp_seq_num) OR
	  (
	     (cir.sup_cal_type,cir.sup_ci_sequence_number) IN
                                ( SELECT  teach_cal_type,teach_ci_sequence_number
                                    FROM  igs_ca_load_to_teach_v
                                   WHERE  load_cal_type = cp_cal_type
                                     AND  load_ci_sequence_number = cp_seq_num
                                )
             )
	  )

UNION
SELECT sca2.person_id person_id ,(select person_last_name from hz_parties where party_id = sca2.person_id) last_name
       FROM     igs_ps_ver_all pv2,
                igs_ps_type_all pt2,
                IGS_EN_STDNT_PS_ATT_ALL sca2
       WHERE    pt2.course_type_group_cd = p_prg_type_gr_cd AND
                pv2.course_type = pt2.course_type AND
                pv2.course_cd = sca2.course_cd AND
                pv2.version_number = sca2.version_number AND
                sca2.course_attempt_status = 'INACTIVE' AND
       NOT EXISTS
                (SELECT 'x' FROM  igs_en_su_attempt_all sua
                            WHERE sua.person_id = sca2.person_id AND
                                  sua.course_cd = sca2.course_cd AND
                                  sua.course_cd = pv2.course_cd) AND
               igs_en_timeslots.acad_teach_rel_exist(sca2.cal_type,cp_cal_type,cp_seq_num) = 'TRUE' ;




  CURSOR cur_cal_st_dt(p_cal_type VARCHAR2,p_seq_num NUMBER) IS
     SELECT start_dt
     FROM igs_ca_inst
     WHERE cal_type = p_cal_type AND
           sequence_number=p_seq_num;

  start_date DATE;
  cnt NUMBER :=  0;
  plsql_1 plsql_table_1;

 BEGIN
  OPEN cur_cal_st_dt(p_cal_type ,p_seq_num);
  FETCH cur_cal_st_dt INTO start_date;
  CLOSE cur_cal_st_dt;

IF p_stdnt_type = 'ENROLLED' THEN
  -- insert all students who is ENROLLED and whose course_type_group_cd matches the given value
  FOR rec_cur_total_enrled_stdnts IN cur_total_enrled_stdnts(start_date) LOOP
       cnt := cnt + 1;
       plsql_1(cnt).person_id := rec_cur_total_enrled_stdnts.person_id ;
       plsql_1(cnt).last_name := rec_cur_total_enrled_stdnts.last_name ;
  END LOOP; -- cur_enrolled
ELSIF p_stdnt_type = 'ADMITTED' THEN
  -- insert all students who is ADMITTED and whose admission commencement period is subordinate to the given teaching period
  --and whose course_type_group_cd matches the given value
  FOR rec_cur_total_admted_stdnts IN cur_total_admted_stdnts(p_cal_type,p_seq_num) LOOP
       cnt := cnt + 1;
       plsql_1(cnt).person_id := rec_cur_total_admted_stdnts.person_id ;
       plsql_1(cnt).last_name := rec_cur_total_admted_stdnts.last_name ;
  END LOOP; -- cur_total_admted_stdnts
END IF;
RETURN plsql_1;
END enrp_total_students;

END Igs_En_Timeslots;

/
