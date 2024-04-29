--------------------------------------------------------
--  DDL for Package Body IGS_PS_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_GEN_004" AS
/* $Header: IGSPS04B.pls 120.6 2006/05/16 00:40:35 sarakshi ship $ */
-------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smvk        08-Jul-2003     Bug # 3084602 , 3084615. Modified func recal_dl_date.
  --smvk        29-Jul-2003     Bug: 3060089 - Modified func recal_dl_date
  --pathipat    11-MAR-2003     Bug: 2822157 - Modified func recal_dl_date
  --Nishikant   13Mar2003       Bug#2845730. The function recal_dl_date got a minor modification.
--------------------------------------------------------------------------


-- forward declaration of the function check_dl_date
FUNCTION    check_dl_date( p_uooid             IN  igs_ps_usec_occurs.uoo_id%TYPE,
                           p_date              IN  DATE,
                           p_formula_method    IN  igs_en_nsu_dlstp.formula_method%TYPE,
			   p_last_meeting_date IN  DATE DEFAULT NULL
                           )
RETURN DATE;

  PROCEDURE log_to_fnd ( p_v_module IN VARCHAR2,
                         p_v_string IN VARCHAR2 ) IS
    /***********************************************************************************************
      Created By     :  smvk
      Date Created By:  18-Sep-2004
      Purpose        :  Procedure to log given String to fnd_log_messages.
                        Threshold level is STATEMENT. (i.e statement level logging)

      Known limitations,enhancements,remarks:
      Change History (in reverse chronological order)
      Who         When            What
    ********************************************************************************************** */

  BEGIN
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_gen_004.' || p_v_module, p_v_string);

    END IF;

  END log_to_fnd;

PROCEDURE crsp_ins_fsr_hist(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_funding_source IN VARCHAR2 ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_dflt_ind IN VARCHAR2,
  p_restricted_ind IN VARCHAR2 )
AS

  CURSOR        c_course_status(
                cp_course_cd IGS_PS_VER.course_cd%TYPE,
                cp_version_number IGS_PS_VER.version_number%TYPE) IS
                SELECT  IGS_PS_STAT.s_course_status
                FROM    IGS_PS_STAT,IGS_PS_VER
                WHERE   IGS_PS_VER.course_cd = cp_course_cd AND
                        IGS_PS_VER.version_number = cp_version_number AND
                        IGS_PS_STAT.course_status = IGS_PS_VER.course_status;
  cst_active    CONSTANT VARCHAR2(8) DEFAULT 'ACTIVE';
  v_course_status       IGS_PS_STAT.s_course_status%TYPE;
  x_rowid               VARCHAR2(25);
  l_org_id              NUMBER(15);

BEGIN
  OPEN c_course_status(
                        p_course_cd,
                        p_version_number);
  FETCH c_course_status INTO v_course_status;
  CLOSE c_course_status;
  l_org_id := IGS_GE_GEN_003.GET_ORG_ID;
  IF(v_course_status = cst_active) THEN
    IGS_FI_FD_SRC_RSTN_H_pkg.Insert_Row(
                                         X_ROWID                =>    x_rowid,
                                         X_COURSE_CD            =>      p_course_cd,
                                         X_HIST_START_DT        =>      p_last_update_on,
                                         X_VERSION_NUMBER       =>      p_version_number,
                                         X_FUNDING_SOURCE       =>      p_funding_source,
                                         X_HIST_END_DT          =>      p_update_on,
                                         X_HIST_WHO             =>      p_last_update_who,
                                         X_DFLT_IND             =>      p_dflt_ind,
                                         X_RESTRICTED_IND       =>      p_restricted_ind,
                                         X_MODE                 =>      'R',
                                         X_ORG_ID               =>      l_org_id);
  END IF;
EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
                Fnd_Message.Set_Token('NAME','IGS_PS_GEN_004.crsp_ins_fsr_hist');
                 IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END crsp_ins_fsr_hist;


FUNCTION crsp_val_call_nbr(
    p_cal_type IN IGS_PS_UNIT_OFR_OPT_ALL.cal_type%TYPE ,
    p_ci_sequence_number  IN IGS_PS_UNIT_OFR_OPT_ALL.ci_sequence_number%TYPE,
    p_call_number IN IGS_PS_UNIT_OFR_OPT_ALL.call_number%TYPE
    )RETURN BOOLEAN AS
   v_dummy VARCHAR2(1) DEFAULT NULL;
   CURSOR c_val_call_nbr is
        SELECT 'x'
        FROM IGS_PS_UNIT_OFR_OPT uoo
        WHERE uoo.cal_type = p_cal_type AND
              uoo.ci_sequence_number = p_ci_sequence_number AND
            uoo.call_number = p_call_number;
BEGIN
  OPEN c_val_call_nbr;
  FETCH c_val_call_nbr INTO v_dummy;
  CLOSE c_val_call_nbr;
  IF v_dummy IS NULL THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END crsp_val_call_nbr;

FUNCTION recal_dl_date (p_v_uoo_id IGS_PS_USEC_OCCURS_V.uoo_id%TYPE,
                                     p_formula_method igs_en_nsu_dlstp.formula_method%TYPE,
                                     p_durationdays      IN OUT NOCOPY igs_en_nstd_usec_dl_v.ENR_DL_TOTAL_DAYS%TYPE,
                                     p_round_method    igs_en_nstd_usec_dl_v.round_method%TYPE,
                                     p_OffsetDuration    igs_en_nstd_usec_dl_v.offset_duration%TYPE,
                                     p_offsetdays IN OUT NOCOPY NUMBER,
                                     p_function_name    igs_en_nstd_usec_dl.function_name%TYPE,
                                     p_setup_id  igs_en_nstd_usec_dl.non_std_usec_dls_id%TYPE,
                                     p_offset_dt_code  igs_en_nsu_dlstp.offset_dt_code%TYPE,
                                     p_msg OUT NOCOPY VARCHAR2
                             )
RETURN DATE IS
------------------------------------------------------------------
  --Created by  : ssomani ( Oracle IDC)
  --Date created: 9-APR-2001
  --
  --Purpose:  Created as part of the build for DLD Enrollment Setup : Calendar, Access, Timeslots (Version 1a)
  --          Used for deadline date calculation for Enrollment setup.
  --          Called from IGSPS101.pll and IGSPS083.pll
  --
  --Known limitations/enhancements and/or remarks:
  --1. For the functions Variation_cuttoff, Record_cutoff and Grading_Schema,
  --the parameter p_function_name = 'FUNCTION'
  --For Discontinuation Dealdine calculation p_function_name = NULL
  --2. The parameter p_setup_id is the corresponding setup id from tables IGS_EN_NSU_DLSTP (for FUNCTION) or
  --   IGS_EN_NSD_DLSTP for Discontinuation.
  --Change History:
  --Who         When            What
  --sarakshi    01-Sep-2005     bug#4114829, added cursor c_weekend_disc such that for discontinuation deadline it checks the respective tables for weekend inclusion
  --sarakshi    23-Aug-2005     bug#4114488, prior to calculating the initial meeting days , removed the holidays from the
  --                            meeting days array, count of this array gives the offsetdays.
  --sarakshi    22-Aug-2005     bug#4113948, when formula method is Meeting days thne passing last meeting days value to check_dl_date
  --sarakshi    19-Aug-2005     Bug#4112602, removed the code added by pathipat for TBA occurrence deadline calculation.
  --sarakshi    19-Aug-2005     Bug#4114992, Set the include weekend flag as Y for no occurrences and formula method Meeting days
  --smvk        08-Jul-2003     Bug # 3084602. Calculated deadline date should n't be holiday / Weekend.
  --                            Bug # 3084615. Should return offset day of meeting day as deadline date.
  --smvk        30-Jul-2003     Bug # 3060089. Calculating the holidays based on the data alias rather than holiday calendar instance duration days.
  --smvk        29-Jul-2003     Bug: 3060089 - Modified code for meeting days,(i.e) For to be announced calculation taking its effective days
  --                            Modified the holiday calculation for meeting days and added into holidays table only when the holiday is a meeting day.
  --                            Sorting the meeting days and returning the deadline date from the meeting days table.
  --                            Modified the cursor cur_occur_unitsection and cal_inst.
  --pathipat    11-MAR-2003     Bug: 2822157 - Modified code for formula_method = 'M'
  --                            Removed local variable no_meeting_day_checked, all its occurrences
  --                            replaced with l_no_meeting_day_checked, added cursor cur_teach_cal
  --                            Modified cursor c_weekdays
  --Nishikant   13Mar2003       Bug#2845730. While calculating the offset days, if the round method is
  --                            Standard then it will simply apply round function of the Duration Days/Meeting Days.
  -------------------------------------------------------------------

        CURSOR c_call_cnstr IS
        SELECT enr_dl_offset_cons_id FROM igs_en_dl_offset_cons
        WHERE non_std_usec_dls_id = p_setup_id
        AND   deadline_type = 'E';
        c_call_cnstr_rec c_call_cnstr%ROWTYPE;

        CURSOR c_call_cnstr_disc IS
        SELECT disc_dl_cons_id FROM igs_en_disc_dl_cons
        WHERE non_std_disc_dl_stp_id = p_setup_id ;
        c_call_cnstr_disc_rec c_call_cnstr_disc%ROWTYPE;

         CURSOR c_st_end_dt IS
         SELECT UNIT_SECTION_START_DATE, UNIT_SECTION_END_DATE
         FROM igs_ps_unit_ofr_opt_all
         WHERE uoo_id = p_v_uoo_id;
         c_st_end_dt_rec c_st_end_dt%ROWTYPE;

         weekends_count BOOLEAN := FALSE;
         weekends NUMBER := 0;

--holiday cal
        CURSOR cal_inst (cp_d_start_dt IN igs_ca_inst_all.start_dt%TYPE,
                         cp_d_end_dt IN igs_ca_inst_all.end_dt%TYPE) IS
        SELECT
                DISTINCT cv.alias_val
        FROM
                igs_ca_inst ci,
                igs_ca_type ct,
                igs_ca_stat cs,
                igs_ca_da_inst_v cv
        WHERE
                ci.cal_type = ct.cal_type AND
                ct.s_cal_cat = 'HOLIDAY' AND
                ci.cal_status = cs.cal_status AND
                cs.s_cal_status = 'ACTIVE' AND
                ci.cal_type = cv.cal_type AND
                ci.sequence_number = cv.ci_sequence_number AND
                ci.start_dt < cp_d_end_dt AND
                ci.end_dt > cp_d_start_dt AND
                (cv.alias_val BETWEEN cp_d_start_dt AND cp_d_end_dt);

--Calculate the Actual Meeting Days.
--for formula method = 'M'

        CURSOR cur_mon is
        select 'TRUE'
        from igs_ps_usec_occurs_v
        where uoo_id = p_v_uoo_id and
                      monday = 'Y';

        CURSOR cur_tue IS
        select 'TRUE'
        from igs_ps_usec_occurs_v
        where uoo_id = p_v_uoo_id and
                      tuesday = 'Y';

        CURSOR cur_wed IS
        select 'TRUE'
        from igs_ps_usec_occurs_v
        where uoo_id = p_v_uoo_id and
                      wednesday = 'Y';

        CURSOR cur_thu IS
        select 'TRUE'
        from igs_ps_usec_occurs_v
        where uoo_id = p_v_uoo_id and
                      thursday = 'Y';

        CURSOR cur_fri IS
        select 'TRUE'
        from igs_ps_usec_occurs_v
        where uoo_id = p_v_uoo_id and
                      friday = 'Y';

        CURSOR cur_sat IS
        select 'TRUE'
        from igs_ps_usec_occurs_v
        where uoo_id = p_v_uoo_id and
                      saturday = 'Y';

        CURSOR cur_sun IS
        select 'TRUE'
        from igs_ps_usec_occurs_v
        where uoo_id = p_v_uoo_id and
                      sunday = 'Y';

        meetingdays   NUMBER       DEFAULT  0;
        l_mon_checked VARCHAR2(10) ;
        l_tue_checked VARCHAR2(10) ;
        l_wed_checked VARCHAR2(10) ;
        l_thu_checked VARCHAR2(10) ;
        l_fri_checked VARCHAR2(10) ;
        l_sat_checked VARCHAR2(10) ;
        l_sun_checked VARCHAR2(10) ;
        l_unitsectionfound VARCHAR2(10) ;
        total_meeting_days         NUMBER  ;

 --Additions With respect to Enrollment Revision

       TYPE meet_days IS TABLE OF DATE INDEX BY BINARY_INTEGER;
       plsql_meet_days meet_days;
       plsql_meet_days_temp meet_days;

      -- new counter
      cnt1 number DEFAULT 0;
--Cursor to fetch the UnitSection Occurrence Start ,End Dates and To Be Announced values (Formula Method='M')
-- not to inculde no set day unit section occurrence as a part of Bug # 3060089.
       CURSOR cur_occur_unitsection
       IS
       SELECT start_date,end_date,to_be_announced,monday, tuesday,wednesday,thursday,friday,saturday,sunday
       FROM   igs_ps_usec_occurs
       WHERE  uoo_id=p_v_uoo_id
       AND    NO_SET_DAY_IND = 'N';

       occur_unitsection_rec cur_occur_unitsection%ROWTYPE;


--end for formula method = 'M'
        TYPE  h_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
        plsql_date_tab h_date;
        holidays NUMBER DEFAULT 0;
        cnt NUMBER DEFAULT 0;
        l_date_hol DATE;
        l_date DATE;
        l_start_date DATE;
        l_end_date DATE;
        l_msg_name VARCHAR2(30);
        date_found VARCHAR2(10);
        deadlinedate DATE;
        offsetdays NUMBER DEFAULT 0;
        l_n_offsetdays NUMBER       DEFAULT  0;
        l_no_meeting_day_checked VARCHAR2(10);

        formula_method igs_en_nsu_dlstp.formula_method%TYPE ;
        durationdays igs_en_nstd_usec_dl_v.ENR_DL_TOTAL_DAYS%TYPE;
        round_method igs_en_nstd_usec_dl_v.round_method%TYPE;
        OffsetDuration igs_en_nstd_usec_dl_v.offset_duration%TYPE;
        Meeting_day VARCHAR2(10) ;

        -- Cursor to obtain the Teach Calendar end date
        -- modifying the following cursor to select start date also. Also modified the from and where clause
        CURSOR cur_teach_cal (cp_n_uoo_id  IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
          SELECT ci.start_dt, ci.end_dt
          FROM igs_ca_inst_all ci,
               igs_ps_unit_ofr_opt_all uoo
          WHERE uoo.uoo_id = cp_n_uoo_id
          AND   uoo.cal_type = ci.cal_type
          AND   uoo.ci_sequence_number = ci.sequence_number;

        l_d_teach_end_dt igs_ps_unit_ofr_opt_v.cal_end_dt%TYPE;
        l_d_teach_start_dt igs_ca_inst_all.start_dt%TYPE;
        l_d_temp_end_dt igs_ca_inst_all.end_dt%TYPE;
        l_d_temp_date igs_ca_inst_all.end_dt%TYPE;

        --Cursor to get the check whether we have to include weekends or not
        CURSOR c_weekend (cp_n_id IN NUMBER) IS
        SELECT incl_wkend_duration_flag
        FROM igs_en_nsu_dlstp_all
        WHERE non_std_usec_dls_id = cp_n_id;

        l_c_include_weekends igs_en_nsu_dlstp_all.incl_wkend_duration_flag%TYPE;

	--Cursor to get the check whether we have to include weekends or not for the discontinuation deadline
        CURSOR c_weekend_disc (cp_n_id IN NUMBER) IS
        SELECT incl_wkend_duration_flag
        FROM   igs_en_nsd_dlstp_all
        WHERE  non_std_disc_dl_stp_id = cp_n_id;
BEGIN

    -- Initialization
    meetingdays  := 0;
    l_mon_checked := 'FALSE';
    l_tue_checked := 'FALSE';
    l_wed_checked := 'FALSE';
    l_thu_checked := 'FALSE';
    l_fri_checked := 'FALSE';
    l_sat_checked := 'FALSE';
    l_sun_checked := 'FALSE';
    l_unitsectionfound := 'FALSE';
    deadlinedate :=SYSDATE;
    l_no_meeting_day_checked :='TRUE';
    formula_method := p_formula_method;
    durationdays := p_durationdays ;
    round_method := p_round_method;
    OffsetDuration := p_OffsetDuration;
    Meeting_day := 'FALSE';


    plsql_meet_days.DELETE; --Initialization
    plsql_meet_days_temp.DELETE;
    plsql_date_tab.DELETE;

    p_msg := NULL;
    OPEN c_st_end_dt;
    FETCH c_st_end_dt INTO c_st_end_dt_rec;
    IF c_st_end_dt_rec.UNIT_SECTION_START_DATE IS NULL THEN
        Fnd_Message.Set_Name('IGS', 'IGS_EN_OFFSET_DT_NULL');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
    END IF;
    l_date := c_st_end_dt_rec.UNIT_SECTION_START_DATE;

    IF p_offset_dt_code = 'USEC_EFFCT_ST_DT' THEN
      l_start_date := c_st_end_dt_rec.UNIT_SECTION_START_DATE;
    END IF;

    l_end_date := c_st_end_dt_rec.UNIT_SECTION_END_DATE;

    -- If Unit Section End Date is null, consider the Teach Calendar
    -- End Date as the end_date for the calculation of Deadline Date
    IF l_end_date IS NULL THEN
       OPEN cur_teach_cal(p_v_uoo_id);
       FETCH cur_teach_cal INTO l_d_teach_start_dt,l_d_teach_end_dt;
       l_end_date := l_d_teach_end_dt;
       CLOSE cur_teach_cal;
    END IF;

    CLOSE c_st_end_dt;

    IF (upper(formula_method)='D' ) THEN
       -- Retention Build
       IF p_function_name='FUNCTION' THEN
	 OPEN c_weekend(p_setup_id);
	 FETCH c_weekend INTO l_c_include_weekends;
	 CLOSE c_weekend;
       ELSE
	 OPEN c_weekend_disc(p_setup_id);
	 FETCH c_weekend_disc INTO l_c_include_weekends;
	 CLOSE c_weekend_disc;
       END IF;
       l_c_include_weekends := NVL(l_c_include_weekends,'Y');

       IF l_c_include_weekends = 'Y' THEN
          weekends_count := FALSE;
       ELSE
          weekends_count := TRUE;
          WHILE (l_date<= l_end_date)
          LOOP
             IF TO_CHAR(l_date,'DY') IN ('SAT', 'SUN') THEN
                Weekends := Weekends +1;
             END IF ;
             l_date := l_date +1;
          END LOOP;
       END IF;

       --2. holiday calculation
       -- Bug # 3060089. Calculating the holidays based on the data alias rather than holiday calendar instance duration days. -smvk
       FOR cal_inst_rec IN cal_inst(c_st_end_dt_rec.UNIT_SECTION_START_DATE, NVL(c_st_end_dt_rec.UNIT_SECTION_END_DATE, l_d_teach_end_dt)) LOOP
          l_date_hol := cal_inst_rec.alias_val;
          IF (to_char (l_date_hol , 'DY') IN ('SAT', 'SUN') AND weekends_count) THEN
             NULL;
          ELSE
             cnt := cnt + 1;
             plsql_date_tab(cnt) := l_date_hol;
          END IF;
       END LOOP;

       Holidays := plsql_date_tab.count;

       --3
       DurationDays := ((l_end_date - l_start_date) - (Weekends + Holidays)) + 1;
       -- if duration days is null
       DurationDays := nvl(DurationDays,0);

       --4
       IF ROUND_METHOD = 'A' THEN
          SELECT ceil((DurationDays*OffsetDuration)/100) INTO offsetdays FROM dual;
       ELSIF ROUND_METHOD = 'S' THEN
          SELECT round((DurationDays*OffsetDuration)/100) INTO offsetdays FROM dual;
       END IF;
       -- if offsetdays is null
      offsetdays := nvl(offsetdays,0);

      --5
      DeadlineDate := l_start_date + OffsetDays ; -- assuming offset_date = offsetdays

      --Bug # 3084602. Calculated deadline date should n't be holiday / Weekend. -smvk
      WHILE DeadlineDate <= l_end_date LOOP
          IF to_char(DeadlineDate,'DY') NOT IN ('SAT', 'SUN')  THEN
             date_found := 'FALSE';
             FOR L in 1..plsql_date_tab.count LOOP
                 IF plsql_date_tab(L) = DeadlineDate THEN
                    date_found := 'TRUE';
                    EXIT;
                 END IF;
             END LOOP;
             IF date_found = 'FALSE' THEN
                EXIT;
             END IF;
          END IF;
          DeadlineDate := DeadlineDate + 1;
      END LOOP;

      --6. Get the final deadline date after applying the Offset Constraints(see Appendix B for applying of Constraints) defined for the Setup data.

      IF p_function_name='FUNCTION' THEN
         OPEN c_call_cnstr;
         FETCH c_call_cnstr INTO c_call_cnstr_rec;
         calpl_constraint_resolve (
                                   p_date_val              => deadlineDate,
                                   p_offset_cnstr_id       => c_call_cnstr_rec.enr_dl_offset_cons_id,
                                   p_type                  => p_function_name,
                                   p_deadline_type         => 'E',
                                   p_msg_name              => l_msg_name );
         IF (l_msg_name IS NULL) THEN
            p_offsetdays := offsetdays;
            p_durationdays := DurationDays;
            p_msg := l_msg_name;
            -- check whether Deadline date is beyond usec end date or not
            -- if found yes return usec end date else calculated deadline date
            -- this check is done by the function check_dl_date
            RETURN (check_dl_date (p_uooid          => p_v_uoo_id,
                                   p_date           => DeadlineDate,
                                   p_formula_method => p_formula_method));
         END IF;
         CLOSE c_call_cnstr;
      ELSE
         OPEN c_call_cnstr_disc;
         FETCH c_call_cnstr_disc INTO c_call_cnstr_disc_rec;
         calpl_constraint_resolve (
                                   p_date_val              => deadlineDate,
                                   p_offset_cnstr_id       => c_call_cnstr_disc_rec.disc_dl_cons_id,
                                   p_type                  => p_function_name,
                                   p_deadline_type         => 'E',
                                   p_msg_name              => l_msg_name );
         IF (l_msg_name IS NULL) THEN
            p_offsetdays := offsetdays;
            p_durationdays := DurationDays;
            p_msg := l_msg_name;
            -- check whether Deadline date is beyond usec end date or not
            -- if found yes return usec end date else calculated deadline date
            -- this check is done by the function check_dl_date
            RETURN (check_dl_date (p_uooid          => p_v_uoo_id,
                                   p_date           => DeadlineDate,
                                   p_formula_method => p_formula_method));
         END IF;
         CLOSE c_call_cnstr_disc;
      END IF;-- p_function_name='FUNCTION'

    -------------------------------------------------
    -- Formula Method = 'Meeting Days'
    ELSIF (formula_method='M') THEN

       --Additon of Code with respect to Enrollment Revision DLD
       --1. calculating the meeting days
       OPEN cur_mon;
       FETCH cur_mon INTO l_mon_checked;
       IF cur_mon%FOUND THEN
          l_mon_checked:='TRUE';
          l_no_meeting_day_checked:='FALSE';
       END IF;
       CLOSE cur_mon;

       OPEN cur_tue;
       FETCH cur_tue INTO l_tue_checked;
       IF cur_tue%FOUND THEN
          l_tue_checked:='TRUE';
          l_no_meeting_day_checked:='FALSE';
       END IF;
       CLOSE cur_tue;

       OPEN cur_wed;
       FETCH cur_wed INTO l_wed_checked;
       IF cur_wed%FOUND THEN
          l_wed_checked:='TRUE';
          l_no_meeting_day_checked:='FALSE';
       END IF;
       CLOSE cur_wed;

       OPEN cur_thu;
       FETCH cur_thu INTO l_thu_checked;
       IF cur_thu%FOUND THEN
          l_thu_checked:='TRUE';
          l_no_meeting_day_checked:='FALSE';
       END IF;
       CLOSE cur_thu;

       OPEN cur_fri;
       FETCH cur_fri INTO l_fri_checked;
       IF cur_fri%FOUND THEN
          l_fri_checked:='TRUE';
          l_no_meeting_day_checked:='FALSE';
       END IF;
       CLOSE cur_fri;

       OPEN cur_sat;
       FETCH cur_sat INTO l_sat_checked;
       IF cur_sat%FOUND THEN
          l_sat_checked:='TRUE';
          l_no_meeting_day_checked:='FALSE';
       END IF;
       CLOSE cur_sat;

       OPEN cur_sun;
       FETCH cur_sun INTO l_sun_checked;
       IF cur_sun%FOUND THEN
          l_sun_checked:='TRUE';
          l_no_meeting_day_checked:='FALSE';
       END IF;
       CLOSE cur_sun;

       --Addition of Code with respect to Enrollment Revision


       --Fetch the Unit Section Occurrence Start and End Dates and check if atleast one record is found

       l_unitsectionfound:='FALSE';
       OPEN cur_occur_unitsection;
       FETCH cur_occur_unitsection INTO  occur_unitsection_rec;
       IF cur_occur_unitsection%NOTFOUND THEN
          l_unitsectionfound:='FALSE';
       ELSE
          l_unitsectionfound:='TRUE';
       END IF;
       CLOSE cur_occur_unitsection;

       -- if Unit Section Occurrence records are not fetched
       -- consider this as duration days (Formula method) case with meeting days Monday to Friday

       IF l_unitsectionfound = 'FALSE' THEN

          --If non standard unit section does not have occurrence at all or have only NSD occurrences
	  --then deadline date is calculated using Duration days with include weekend flag checked
	  --Set the include weekend flag as Y for this setup, bug#4114992
	  l_c_include_weekends := 'Y';
          weekends_count := FALSE;

          -- calculate the holiday
          -- Bug # 3060089. Calculating the holidays based on the data alias rather than holiday calendar instance duration days. -smvk
          FOR cal_inst_rec IN cal_inst(c_st_end_dt_rec.UNIT_SECTION_START_DATE, NVL(c_st_end_dt_rec.UNIT_SECTION_END_DATE, l_d_teach_end_dt)) LOOP
              l_date_hol := cal_inst_rec.alias_val;
              IF (to_char (l_date_hol , 'DY') IN ('SAT', 'SUN') AND weekends_count) THEN
                 NULL;
              ELSE
                 cnt := cnt + 1;
                 plsql_date_tab(cnt) := l_date_hol;
              END IF;
          END LOOP;

          Holidays := plsql_date_tab.count;

          --calculation of duration days
          DurationDays := ((l_end_date - l_start_date) - (Weekends + Holidays)) + 1;
          -- if Duration Days is null
          DurationDays := nvl(DurationDays,0);


          --applying round method
          IF ROUND_METHOD = 'A' THEN
             SELECT ceil((DurationDays*OffsetDuration)/100) INTO offsetdays FROM dual;
          ELSIF ROUND_METHOD = 'S' THEN
             SELECT round((DurationDays*OffsetDuration)/100) INTO offsetdays FROM dual;
          END IF;
          -- if offsetdays is null
          offsetdays := nvl(offsetdays,0);

          --calculate deadline date
          -- The offset days are added blindly to the start date. Constraints are applied later.
          DeadlineDate := l_start_date + OffsetDays ; -- assuming offset_date = offsetdays

          --Bug # 3084602. Calculated deadline date should n't be holiday / Weekend. -smvk
          WHILE DeadlineDate <= l_end_date LOOP
             IF to_char(DeadlineDate,'DY') NOT IN ('SAT', 'SUN')  THEN
                date_found := 'FALSE';
                FOR L in 1..plsql_date_tab.count LOOP
                    IF plsql_date_tab(L) = DeadlineDate THEN
                       date_found := 'TRUE';
                       EXIT;
                    END IF;
                END LOOP;
                IF date_found = 'FALSE' THEN
                   EXIT;
                END IF;
             END IF;
             DeadlineDate := DeadlineDate + 1;
          END LOOP;

          -- Get the final deadline date after applying the Offset Constraints(see Appendix B for applying of Constraints)
          -- defined for the Setup data.

          IF p_function_name='FUNCTION' THEN
             OPEN c_call_cnstr;
             FETCH c_call_cnstr INTO c_call_cnstr_rec;
             calpl_constraint_resolve (
                                       p_date_val              => deadlineDate,
                                       p_offset_cnstr_id       => c_call_cnstr_rec.enr_dl_offset_cons_id,
                                       p_type                  => p_function_name,
                                       p_deadline_type         => 'E',
                                       p_msg_name              => l_msg_name );
             IF (l_msg_name IS NULL) THEN
                p_offsetdays := offsetdays;
                p_durationdays := DurationDays;
                p_msg := l_msg_name;
                -- check whether Deadline date is beyond usec end date or not
                -- if found yes return usec end date else calculated deadline date
                -- this check is done by the function check_dl_date
                RETURN (check_dl_date (p_uooid          => p_v_uoo_id,
                                       p_date           => DeadlineDate,
                                       p_formula_method => p_formula_method));
             END IF;
             CLOSE c_call_cnstr;
          ELSE
             OPEN c_call_cnstr_disc;
             FETCH c_call_cnstr_disc INTO c_call_cnstr_disc_rec;
             calpl_constraint_resolve (
                                       p_date_val              => deadlineDate,
                                       p_offset_cnstr_id       => c_call_cnstr_disc_rec.disc_dl_cons_id,
                                       p_type                  => p_function_name,
                                       p_deadline_type         => 'E',
                                       p_msg_name              => l_msg_name );
             IF (l_msg_name IS NULL) THEN
                p_offsetdays := offsetdays;
                p_durationdays := DurationDays;
                p_msg := l_msg_name;
                -- check whether Deadline date is beyond usec end date or not
                -- if found yes return usec end date else calculated deadline date
                -- this check is done by the function check_dl_date
                RETURN (check_dl_date (p_uooid          => p_v_uoo_id,
                                       p_date           => DeadlineDate,
                                       p_formula_method => p_formula_method));
             END IF;
             CLOSE c_call_cnstr_disc;
          END IF;-- p_function_name='FUNCTION'

       -- over   processing for the unit section occurrence if not found
       --Only if the UnitSection Occurrence Records are fetched do we have to process
       ELSIF l_unitsectionfound ='TRUE' THEN
          --Loop Through all the Unit Section occurrences
          FOR  unitsection_occur IN cur_occur_unitsection
          LOOP
             IF unitsection_occur.to_be_announced='Y'  THEN
                -- For to be announced unit section occurrence user can optionally provide the start and end date.
                -- need to consider the start date and end date in the following order 1) occurrence 2) section 3) teaching period.
                l_date := NVL(unitsection_occur.start_date,NVL(c_st_end_dt_rec.unit_section_start_date,l_d_teach_start_dt));
                l_d_temp_end_dt := NVL(unitsection_occur.end_date,NVL(c_st_end_dt_rec.unit_section_end_date,l_d_teach_end_dt));
                WHILE ( l_date <= l_d_temp_end_dt )
                LOOP
                   IF ( TO_CHAR(l_date,'DY') NOT IN ('SAT','SUN')) THEN
                      date_found:='FALSE';
                      FOR i IN 1..plsql_meet_days.count
                      LOOP
                         IF plsql_meet_days(i)=l_date THEN
                            date_found:='TRUE';
                            EXIT;
                         END IF;
                      END LOOP;
                      IF date_found='FALSE' THEN
                         cnt:=cnt+1;
                         plsql_meet_days(cnt):=l_date;
                      END IF;
                   END IF; -- For l_date not in (SAT,SUN)
                   l_date := l_date +1;
                END LOOP;  -- check for l_date bet start and end date of Unit Section Occurrence is over

             --Check if to_be_announced is not 'Y'
             ELSIF unitsection_occur.to_be_announced <> 'Y'  THEN
                IF (unitsection_occur.start_date IS NOT NULL AND unitsection_occur.end_date IS NOT NULL ) THEN
                   IF l_no_meeting_day_checked='TRUE' THEN
                      --Loop for l_date between Unit Section Occurrance Start and End Dates
                      l_date := unitsection_occur.start_date;
                      WHILE (l_date <= unitsection_occur.end_date AND l_date>=unitsection_occur.start_date) LOOP
                         IF (TO_CHAR(l_date,'DY') NOT IN ('SAT','SUN'))  THEN
                            date_found:='FALSE';
                            FOR k IN 1..plsql_meet_days.count
                            LOOP
                               IF plsql_meet_days(k)=l_date THEN
                                  date_found:='TRUE';
                                  EXIT;
                               END IF;

                            END LOOP;
                            IF date_found='FALSE' THEN
                               cnt:=cnt+1;
                               plsql_meet_days(cnt):=l_date;
                            END IF;
                         END IF; -- For l_date not in (SAT,SUN)
                         l_date := l_date + 1;
                      END LOOP;

                      -- for no_meeting_day_checked

                   ELSIF  l_No_meeting_day_checked <> 'TRUE'  THEN
                      l_date:= unitsection_occur.start_date;
                      WHILE ( l_date <= unitsection_occur.end_date AND l_date>=unitsection_occur.start_date) LOOP

                         Meeting_day:='FALSE';
                         -- Bug # 3060089. Modifying the following conditions to refer the current occurrence meeting days.
                         --  and not the meeting days of other occurrences -smvk
                         IF ( TO_CHAR(l_date,'DY')='MON' AND unitsection_occur.monday = 'Y' ) THEN
                            Meeting_day:='TRUE';
                         ELSIF ( TO_CHAR(l_date,'DY')='TUE' AND unitsection_occur.tuesday = 'Y' ) THEN
                            Meeting_day:='TRUE';

                         ELSIF  ( TO_CHAR(l_date,'DY')='WED' AND unitsection_occur.wednesday = 'Y' ) THEN
                            Meeting_day:='TRUE';

                         ELSIF ( TO_CHAR(l_date,'DY')='THU' AND unitsection_occur.thursday = 'Y' ) THEN
                            Meeting_day:='TRUE';

                         ELSIF ( TO_CHAR(l_date,'DY')='FRI' AND unitsection_occur.friday = 'Y' ) THEN
                            Meeting_day:='TRUE';

                         ELSIF ( TO_CHAR(l_date,'DY')='SAT' AND unitsection_occur.saturday = 'Y') THEN
                            Meeting_day:='TRUE';

                         ELSIF ( TO_CHAR(l_date,'DY')='SUN' AND unitsection_occur.sunday = 'Y') THEN
                            Meeting_day:='TRUE';

                         END IF;

                         IF Meeting_day ='TRUE'  THEN
                            date_found:='FALSE';

                            FOR i IN 1..plsql_meet_days.count LOOP

                               IF plsql_meet_days(i)=l_date THEN

                                  date_found:='TRUE';
                                  EXIT;
                               END IF;

                            END LOOP;

                            IF date_found='FALSE' THEN
                               cnt:=cnt+1;
                               plsql_meet_days(cnt):=l_date;
                            END IF;

                         END IF;
                            l_date := l_date + 1;
                      END LOOP;

                   END IF; -- No_meeting_day_checked is over here.

                ELSE  -- If either of the occurrence dates is  null or both are null
                   l_date := c_st_end_dt_rec.unit_section_start_date;
                   WHILE (l_date <= c_st_end_dt_rec.unit_section_end_date AND l_date >=c_st_end_dt_rec.unit_section_start_date) LOOP

                       Meeting_day:='FALSE';

                       IF  ( TO_CHAR(l_date,'DY')='MON' AND l_mon_checked='TRUE' ) THEN
                          Meeting_day:='TRUE';
                       ELSIF ( TO_CHAR(l_date,'DY')='TUE' AND l_tue_checked='TRUE' ) THEN
                          Meeting_day:='TRUE';

                       ELSIF ( TO_CHAR(l_date,'DY')='WED' AND l_wed_checked='TRUE' ) THEN
                          Meeting_day:='TRUE';

                       ELSIF ( TO_CHAR(l_date,'DY')='THU' AND l_thu_checked='TRUE' ) THEN
                          Meeting_day:='TRUE';

                       ELSIF ( TO_CHAR(l_date,'DY')='FRI' AND l_fri_checked='TRUE' ) THEN
                          Meeting_day:='TRUE';

                       ELSIF ( TO_CHAR(l_date,'DY')='SAT' AND l_sat_checked='TRUE' ) THEN
                          Meeting_day:='TRUE';

                       ELSIF ( TO_CHAR(l_date,'DY')='SUN' AND l_sun_checked='TRUE' ) THEN
                          Meeting_day:='TRUE';

                       END IF;

                       IF Meeting_day='TRUE'  THEN
                          date_found:='FALSE';

                          FOR i IN  1..plsql_meet_days.count LOOP

                              IF plsql_meet_days(i)=l_date THEN

                                 date_found:='TRUE';
                                 EXIT;
                              END IF;

                          END LOOP;

                          IF date_found='FALSE' THEN
                             cnt:=cnt+1;
                             plsql_meet_days(cnt):=l_date;
                          END IF;

                       END IF;
                       l_date := l_date + 1;
                   END LOOP;
                END IF; -- for dates being not null
             END IF;    -- End of check against to_be_announced
          END LOOP;   --End of Records fetched
       END IF;    --If only any record is fetched


       --End of Code addition w.r.to Revision DLD
       --Removed the code as a part of the bug#4114488
       /*Total_meeting_days := plsql_meet_days.COUNT;*/


       --changed the validation here as specified in the Revision Enrollment DLD
       --2. holiday calculation
       -- Bug # 3060089. Calculating the holidays based on the data alias rather than holiday calendar instance duration days. -smvk
       FOR cal_inst_rec IN cal_inst(c_st_end_dt_rec.UNIT_SECTION_START_DATE, NVL(c_st_end_dt_rec.UNIT_SECTION_END_DATE, l_d_teach_end_dt)) LOOP
           l_date_hol := cal_inst_rec.alias_val;
           -- Bug # 3060089. Modifying the logic of adding the holiday l_date_hol in holiday PLSQL table plsql_date_tab
           -- only when the holiday is a meeting day (i.e present in the PLSQL table plsql_meet_days). - smvk

           FOR i IN 1..plsql_meet_days.count LOOP
               IF plsql_meet_days(i) = l_date_hol THEN
                  cnt1 := cnt1 + 1;
                  plsql_date_tab(cnt1) := l_date_hol;
                  EXIT;
               END IF;
           END LOOP;
       END LOOP;

       --Get non holiday meeting days in a temp array
       FOR i IN 1..plsql_meet_days.count LOOP
          date_found := 'FALSE';
          FOR j in 1..plsql_date_tab.count LOOP
	     date_found := 'FALSE';
             IF plsql_date_tab(j) = plsql_meet_days(i) THEN
                 date_found := 'TRUE';
		 EXIT;
	     END IF;
          END LOOP;
	  IF date_found = 'FALSE' THEN
            plsql_meet_days_temp(plsql_meet_days_temp.count+1):= plsql_meet_days(i);
	  END IF;
       END LOOP;


       --Assign the temp arrray to the main meeting days.
       plsql_meet_days.delete;
       plsql_meet_days:=plsql_meet_days_temp;

       meetingdays := plsql_meet_days.COUNT;

        --Removed the code as a part of the bug#4114488
       /*Holidays := plsql_date_tab.count;

       --3.final meeting days
       -- Final meeting days is obtained by subtracting holidays from total meeting days (pathipat)
       meetingdays := (Total_meeting_days - Holidays);*/



       --4.
       IF ROUND_METHOD = 'A' THEN
          SELECT ceil((meetingdays*offsetduration)/100) INTO offsetdays FROM dual;
       ELSIF ROUND_METHOD = 'S' THEN
          SELECT round((meetingdays*offsetduration)/100) INTO offsetdays FROM dual;
       END IF;
       -- offsetdays is null
       offsetdays := nvl(offsetdays,0);

       -- The offsetdays is stored in another variable since it is decremented in the following loop
       -- (pathipat)
       l_n_offsetdays := offsetdays;

       --5. deadline date = offset date + Offset days

       l_date := l_start_date; --Offset Date(presently the only value can be Unit Section Start Date)


       IF offsetdays > 0 THEN

          -- Bug # 3060089. Sort the meeting days in the asc order.
          FOR I in 1..plsql_meet_days.COUNT-1 LOOP
             FOR J in I+1..plsql_meet_days.COUNT LOOP
                IF plsql_meet_days(i) > plsql_meet_days(j) THEN
                   l_d_temp_date := plsql_meet_days(i);
                   plsql_meet_days(i) := plsql_meet_days(j);
                   plsql_meet_days(j) := l_d_temp_date;
                END IF;
             END LOOP;
          END LOOP;

          -- Bug # 3084615. if the offset date is 2 then the second meeting date should be considered as holiday (earlier (offsetdate +1) 3 meeting days was considered as deadline date).
          -- Bug # 3084602. if the calculated deadline date is a holiday then find out next meeting day which is not holiday.
          --Removed the code as a part of the bug#4114488
	  /*FOR K in offsetdays..plsql_meet_days.count LOOP
              date_found := 'FALSE';
              FOR L in 1..plsql_date_tab.count LOOP
                IF plsql_date_tab(L) = plsql_meet_days(K) THEN
                  date_found := 'TRUE';
                  EXIT;
                END IF;
              END LOOP;
              IF date_found = 'FALSE' THEN
                 l_date := plsql_meet_days(K);
                 EXIT;
              END IF;
          END LOOP;*/

          l_date := plsql_meet_days(offsetdays);

       END IF;

       DeadlineDate := l_date ;
       --6. apply offset constraint

       IF p_function_name='FUNCTION' THEN
          OPEN c_call_cnstr;
          FETCH c_call_cnstr INTO c_call_cnstr_rec;
          calpl_constraint_resolve (
                                     p_date_val              => deadlineDate,
                                     p_offset_cnstr_id       => c_call_cnstr_rec.enr_dl_offset_cons_id,
                                     p_type                  => p_function_name,
                                     p_deadline_type         => 'E',
                                     p_msg_name              => l_msg_name );

          IF (l_msg_name IS NULL) THEN
             -- Pass back the non-decremented value of offset days (pathipat)
             p_offsetdays := l_n_offsetdays;

             -- For a formula_method of 'M' (Meeting days), the parameter p_durationdays holds
             -- the value of meetingdays (pathipat)
             p_durationdays := meetingdays;
             p_msg := l_msg_name;
             -- check whether Deadline date is beyond usec end date or not
             -- if found yes return usec end date else calculated deadline date
             -- this check is done by the function check_dl_date
             RETURN (check_dl_date (p_uooid          => p_v_uoo_id,
                                    p_date           => DeadlineDate,
                                    p_formula_method => p_formula_method,
				    p_last_meeting_date => plsql_meet_days(plsql_meet_days.count) ));
          END IF;
       ELSE
          OPEN c_call_cnstr_disc;
          FETCH c_call_cnstr_disc INTO c_call_cnstr_disc_rec;
          calpl_constraint_resolve (
                                    p_date_val              => deadlineDate,
                                    p_offset_cnstr_id       => c_call_cnstr_disc_rec.disc_dl_cons_id,
                                    p_type                  => p_function_name,
                                    p_deadline_type         => 'E',
                                    p_msg_name              => l_msg_name );
          IF (l_msg_name IS NULL) THEN
             -- Pass back the non-decremented value of offset days (pathipat)
             p_offsetdays := l_n_offsetdays;
             -- For a formula_method of 'M' (Meeting days), the parameter p_durationdays holds
             -- the value of meetingdays  (pathipat)
             p_durationdays := meetingdays;
             p_msg := l_msg_name;
             -- check whether Deadline date is beyond usec end date or not
             -- if found yes return usec end date else calculated deadline date
             -- this check is done by the function check_dl_date
             RETURN (check_dl_date (p_uooid          => p_v_uoo_id,
                                    p_date           => DeadlineDate,
                                    p_formula_method => p_formula_method,
				    p_last_meeting_date => plsql_meet_days(plsql_meet_days.count) ));
          END IF;
          CLOSE c_call_cnstr_disc;
       END IF;

    END IF; -- formula_method
    -- check whether Deadline date is beyond usec end date or not
    -- if found yes return usec end date else calculated deadline date
    -- this check is done by the function check_dl_date
    RETURN (check_dl_date (p_uooid          => p_v_uoo_id,
                           p_date           => DeadlineDate,
                           p_formula_method => p_formula_method));

END recal_dl_date;



PROCEDURE calpl_constraint_resolve (
        p_date_val              IN OUT NOCOPY IGS_EN_NSTD_USEC_DL.ENR_DL_DATE%TYPE,
        p_offset_cnstr_id       IN IGS_EN_DL_OFFSET_CONS.ENR_DL_OFFSET_CONS_ID%TYPE,
        p_type                  IN IGS_EN_NSTD_USEC_DL.FUNCTION_NAME%TYPE,
        p_deadline_type         IN VARCHAR2,
        p_msg_name              OUT NOCOPY VARCHAR2 )
 AS

 ------------------------------------------------------------------
  --Created by  : pradhakr ( Oracle IDC)
  --Date created: 9-APR-2001
  --
  --Purpose:  Created as part of the build for DLD Enrollment Setup : Calendar, Access, Timeslots (Version 1a)
  --          Used for deadline date calculation for Enrollment setup by applying Offset Constraints.
  --          Called from IGSPS101.pll and IGSPS083.pll
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sarakshi    16-May-2006     bug#5190760,replaced ENR_DL_OFFSET_CONS_ID with NON_STD_USEC_DLS_ID in the cousor c_daoc_func
  -------------------------------------------------------------------



        cst_must        CONSTANT        VARCHAR2(10)    DEFAULT 'MUST';
        cst_must_not    CONSTANT        VARCHAR2(10)    DEFAULT 'MUST NOT';
        cst_monday      CONSTANT        VARCHAR2(10)    DEFAULT 'MONDAY';
        cst_tuesday     CONSTANT        VARCHAR2(10)    DEFAULT 'TUESDAY';
        cst_wednesday   CONSTANT        VARCHAR2(10)    DEFAULT 'WEDNESDAY';
        cst_thursday    CONSTANT        VARCHAR2(10)    DEFAULT 'THURSDAY';
        cst_friday      CONSTANT        VARCHAR2(10)    DEFAULT 'FRIDAY';
        cst_saturday    CONSTANT        VARCHAR2(10)    DEFAULT 'SATURDAY';
        cst_sunday      CONSTANT        VARCHAR2(10)    DEFAULT 'SUNDAY';
        cst_week_day    CONSTANT        VARCHAR2(10)    DEFAULT 'WEEK DAY';
        cst_holiday     CONSTANT        VARCHAR2(10)    DEFAULT 'HOLIDAY';
        cst_inst_break  CONSTANT        VARCHAR2(10)    DEFAULT 'INST BREAK';
        cst_active      CONSTANT        VARCHAR2(10)    DEFAULT 'ACTIVE';
        v_mod_count                     NUMBER(5);
        v_constraint_count              NUMBER(5);
        v_loop_count                    NUMBER(5);
        v_message_name   varchar2(30);
        v_alias_val     IGS_CA_DA_INST.absolute_val%TYPE;


        v_msg_name                      VARCHAR2(30);
        v_changed                       BOOLEAN;
        p_constraint_count              NUMBER(5);
        p_mod_count                     NUMBER(5);
        p_message_name                  VARCHAR2(30);

        CURSOR c_daoc_func IS
                SELECT  daoc.OFFSET_CONS_TYPE_CD,
                        daoc.CONSTRAINT_CONDITION,
                        daoc.CONSTRAINT_RESOLUTION
                FROM IGS_EN_DL_OFFSET_CONS daoc
                WHERE  daoc.NON_STD_USEC_DLS_ID = p_offset_cnstr_id --bug#5190760,replaced ENR_DL_OFFSET_CONS_ID with NON_STD_USEC_DLS_ID
                AND    daoc.deadline_type =  p_deadline_type;

        CURSOR c_daoc_adm IS
                SELECT  daoc.OFFSET_CONS_TYPE_CD,
                        daoc.CONSTRAINT_CONDITION,
                        daoc.CONSTRAINT_RESOLUTION
                FROM IGS_EN_DISC_DL_CONS daoc
                WHERE  daoc.DISC_DL_CONS_ID = p_offset_cnstr_id;



FUNCTION calpl_holiday_resolve (

        p_date_val                      IN OUT NOCOPY   DATE,
        p_cnstrt_condition              IN IGS_EN_DL_OFFSET_CONS.constraint_condition%TYPE,
        p_cnstrt_resolution             IN IGS_EN_DL_OFFSET_CONS.constraint_resolution%TYPE )

        RETURN VARCHAR2
        AS

                v_changed               BOOLEAN;
                v_dummy                 VARCHAR2(1);
                v_tmp_mod_count         NUMBER;
                v_tmp_date_val                  DATE;
                v_max_alias_val         DATE    DEFAULT NULL;
                v_min_alias_val         DATE    DEFAULT NULL;

                CURSOR c_m_alias_val IS
                        SELECT  TRUNC(max(dai.absolute_val)), TRUNC(min(dai.absolute_val))
                        FROM    IGS_CA_DA_INST  dai,
                                IGS_CA_INST             ci,
                                IGS_CA_TYPE             ct,
                                IGS_CA_STAT             cs
                        WHERE   ci.CAL_TYPE             = ct.CAL_TYPE   AND
                                ct.S_CAL_CAT            = cst_holiday   AND
                                cs.s_cal_status         = ci.CAL_STATUS AND
                                cs.s_cal_status         = cst_active    AND
                                dai.CAL_TYPE            = ci.CAL_TYPE;

                CURSOR c_holiday (
                                cp_date_val             IGS_CA_DA_INST.absolute_val%TYPE) IS
                        SELECT  'x'
                        FROM    IGS_CA_TYPE ct
                        WHERE   ct.S_CAL_CAT            = cst_holiday   AND
                        EXISTS  (SELECT 'x'
                                 FROM   IGS_CA_INST ci,
                                        IGS_CA_STAT cs
                                WHERE   ci.CAL_TYPE     = ct.CAL_TYPE   AND
                                        ci.CAL_STATUS   = cs.CAL_STATUS AND
                                        cs.s_cal_status = cst_active    AND
                                        EXISTS  (SELECT 'x'
                                                 FROM   IGS_CA_DA_INST dai
                                                 WHERE  dai.CAL_TYPE = ct.CAL_TYPE      AND
                                                        TRUNC(dai.absolute_val)= cp_date_val));
        BEGIN
                OPEN c_m_alias_val;
                FETCH c_m_alias_val INTO        v_max_alias_val,
                                                v_min_alias_val;
                CLOSE c_m_alias_val;
                IF v_max_alias_val IS NULL      AND
                                v_min_alias_val IS NULL THEN
                        -- No HOLIDAY date alias instances have been defined which can be resolved.
                        IF p_cnstrt_condition = cst_must_not THEN
                                -- constraint does not require resolving
                                RETURN null;
                        ELSE
                                -- constraint cannot be resolved
                                RETURN ('IGS_CA_HOLIDAY_CONST_UNRSLVD');
                        END IF;
                ELSE
                        IF      p_cnstrt_condition = cst_must THEN
                                IF      (p_date_val     > v_max_alias_val AND
                                         p_cnstrt_resolution >0 ) OR
                                        (p_date_val     < v_min_alias_val AND
                                         p_cnstrt_resolution <0 ) THEN
                                        -- constraint cannot be resolved
                                        RETURN ('IGS_CA_HOLIDAY_CONS_UNRSVLD');
                                END IF;
                        END IF;
                        v_tmp_date_val := p_date_val;

                        LOOP
                                v_changed := FALSE;
                                OPEN c_holiday (v_tmp_date_val);
                                FETCH c_holiday INTO v_dummy;
                                IF c_holiday%FOUND THEN
                                        CLOSE c_holiday;
                                        IF p_cnstrt_condition = cst_must_not THEN
                                                --update the date value and test again.
                                                v_tmp_date_val := v_tmp_date_val + p_cnstrt_resolution;
                                                v_changed := TRUE;
                                        END IF;
                                ELSE    -- record not found
                                        CLOSE c_holiday;
                                        IF p_cnstrt_condition = cst_must THEN
                                                --update the date value and test again.
                                                v_tmp_date_val := v_tmp_date_val + p_cnstrt_resolution;

                                                IF      (v_tmp_date_val > v_max_alias_val AND
                                                         p_cnstrt_resolution    >0 ) OR
                                                        (v_tmp_date_val < v_min_alias_val AND
                                                         p_cnstrt_resolution    <0 ) THEN
                                                        -- constraint cannot be resolved
                                                        RETURN ('IGS_CA_HOLIDAY_CONS_UNRSVLD');
                                                END IF;
                                                v_changed := TRUE;
                                        END IF;
                                END IF;
                                EXIT WHEN v_changed = FALSE;
                        END LOOP;
                        -- resolve success or no resolving needed.
                        p_date_val := v_tmp_date_val;

                        RETURN null;
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_m_alias_val%ISOPEN THEN
                                CLOSE c_m_alias_val;
                        END IF;
                        IF c_holiday%ISOPEN THEN
                                CLOSE c_holiday;
                        END IF;
                        RAISE;

        END calpl_holiday_resolve;



FUNCTION calpl_inst_break_resolve (
                p_date_val                      IN OUT NOCOPY   DATE,
                p_cnstrt_condition              IN      IGS_EN_DL_OFFSET_CONS.constraint_condition%TYPE,
                p_cnstrt_resolution             IN      IGS_EN_DL_OFFSET_CONS.constraint_resolution%TYPE )

        RETURN varchar2
        AS
                v_changed               BOOLEAN;
                v_dummy                 VARCHAR2(1);
                v_tmp_mod_count         NUMBER;
                v_tmp_date_val          DATE;
                v_max_alias_val         DATE    DEFAULT NULL;
                v_min_alias_val         DATE    DEFAULT NULL;

                CURSOR c_m_alias_val2 IS
                        SELECT  TRUNC(MAX(dai2.absolute_val)), TRUNC(MIN(dai1.absolute_val))
                        FROM    IGS_CA_DA_INST          dai1,
                                IGS_CA_DA_INST          dai2,
                                IGS_CA_DA_INST_PAIR     daip,
                                IGS_CA_INST             ci,
                                IGS_CA_TYPE             ct,
                                IGS_CA_STAT             cs
                        WHERE   ci.CAL_TYPE             = ct.CAL_TYPE                           AND
                                ct.S_CAL_CAT            = cst_holiday                           AND
                                cs.cal_status           = ci.CAL_STATUS                         AND
                                cs.s_cal_status         = cst_active                            AND
                                dai1.CAL_TYPE           = ci.CAL_TYPE                           AND
                                dai1.DT_ALIAS           = daip.DT_ALIAS                         AND
                                dai1.sequence_number    = daip.dai_sequence_number              AND
                                dai1.CAL_TYPE           = daip.CAL_TYPE                         AND
                                dai1.ci_sequence_number = daip.ci_sequence_number               AND
                                dai2.DT_ALIAS           = daip.related_dt_alias                 AND
                                dai2.sequence_number    = daip.related_dai_sequence_number      AND
                                dai2.CAL_TYPE           = daip.related_cal_type                 AND
                                dai2.ci_sequence_number = daip.related_ci_sequence_number;

                CURSOR c_instbreak (
                                cp_date_val             IGS_CA_DA_INST.absolute_val%TYPE) IS
                        SELECT  'x'
                        FROM    IGS_CA_TYPE ct
                        WHERE   ct.S_CAL_CAT = cst_holiday      AND
                        EXISTS  (SELECT 'x'
                                 FROM   IGS_CA_INST ci,
                                        IGS_CA_STAT cs
                                 WHERE  ci.CAL_TYPE     = ct.CAL_TYPE   AND
                                        ci.CAL_STATUS   = cs.CAL_STATUS AND
                                        cs.s_cal_status = cst_active    AND
                                        EXISTS  (SELECT 'x'
                                        FROM    IGS_CA_DA_INST dai1,
                                                IGS_CA_DA_INST dai2,
                                                IGS_CA_DA_INST_PAIR daip
                                        WHERE   dai1.CAL_TYPE   = ct.CAL_TYPE   AND
                                                dai1.DT_ALIAS    = daip.DT_ALIAS    AND
                                                dai1.sequence_number    = daip.dai_sequence_number  AND
                                                dai1.CAL_TYPE   = daip.CAL_TYPE    AND
                                                dai1.ci_sequence_number = daip.ci_sequence_number  AND
                                                dai2.DT_ALIAS   = daip.related_dt_alias   AND
                                                dai2.sequence_number    = daip.related_dai_sequence_number AND
                                                dai2.CAL_TYPE   = daip.related_cal_type   AND
                                                dai2.ci_sequence_number = daip.related_ci_sequence_number AND
                                                 cp_date_val BETWEEN TRUNC(dai1.absolute_val) AND
                                                        TRUNC(dai2.absolute_val)));
        BEGIN
                OPEN c_m_alias_val2;
                FETCH c_m_alias_val2 INTO       v_max_alias_val,
                                                v_min_alias_val;
                CLOSE c_m_alias_val2;
                IF v_max_alias_val IS NULL      AND
                                v_min_alias_val IS NULL THEN
                        -- No HOLIDAY date alias instances have been defined which can be resolved.
                        IF p_cnstrt_condition = cst_must_not THEN
                                -- constraint does not require resolving
                                RETURN null;
                        ELSE
                                -- constraint cannot be resolved
                                RETURN ('IGS_CA_INSTBREAK_CONST_UNRSLV');
                        END IF;
                ELSE
                        IF      p_cnstrt_condition = cst_must THEN
                                IF      (p_date_val     > v_max_alias_val AND
                                         p_cnstrt_resolution >0 ) OR
                                        (p_date_val     < v_min_alias_val AND
                                         p_cnstrt_resolution <0 ) THEN
                                        -- constraint cannot be resolved
                                        RETURN ('IGS_CA_INSTBREAK_CONS_UNRSVLD');
                                END IF;
                        END IF;
                        v_tmp_date_val := p_date_val;

                        LOOP
                                v_changed := FALSE;
                                OPEN c_instbreak (v_tmp_date_val);
                                FETCH c_instbreak INTO v_dummy;
                                IF c_instbreak%FOUND THEN
                                        CLOSE c_instbreak;
                                        IF p_cnstrt_condition = cst_must_not THEN
                                                --update the date value and test again.
                                                v_tmp_date_val := v_tmp_date_val + p_cnstrt_resolution;

                                                v_changed := TRUE;
                                        END IF;
                                ELSE    -- record not found
                                        CLOSE c_instbreak;
                                        IF p_cnstrt_condition = cst_must THEN
                                                --update the date value and test again.
                                                v_tmp_date_val := v_tmp_date_val + p_cnstrt_resolution;

                                                IF      (v_tmp_date_val > v_max_alias_val AND
                                                         p_cnstrt_resolution    >0 ) OR
                                                        (v_tmp_date_val < v_min_alias_val AND
                                                         p_cnstrt_resolution    <0 ) THEN
                                                        -- constraint cannot be resolved
                                                        RETURN ('IGS_CA_INSTBREAK_CONS_UNRSVLD');
                                                END IF;
                                                v_changed := TRUE;
                                        END IF;
                                END IF;
                                EXIT WHEN v_changed = FALSE;
                        END LOOP;
                        -- resolve success or no resolving needed.
                        p_date_val := v_tmp_date_val;

                        RETURN null;
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_m_alias_val2%ISOPEN THEN
                                CLOSE c_m_alias_val2;
                        END IF;
                        IF c_instbreak%ISOPEN THEN
                                CLOSE c_instbreak;
                        END IF;
                        RAISE;

        END calpl_inst_break_resolve;

 BEGIN  -- begin of calpl_constraint_resolve

                v_msg_name := NULL;

                IF p_type = 'FUNCTION' THEN
                  FOR v_daoc_rec IN c_daoc_func LOOP

                        p_constraint_count := p_constraint_count + 1;
                        IF v_daoc_rec.OFFSET_CONS_TYPE_CD IN (  cst_monday,
                                                                        cst_tuesday,
                                                                        cst_wednesday,
                                                                        cst_thursday,
                                                                        cst_friday,
                                                                        cst_saturday,
                                                                        cst_sunday)     THEN
                                IF v_daoc_rec.constraint_condition = cst_must   THEN
                                        -- Use an inner loop to check and resolve any clash.
                                        WHILE RTRIM(TO_CHAR(p_date_val,'DAY')) <>
                                                                v_daoc_rec.OFFSET_CONS_TYPE_CD LOOP
                                                p_date_val := p_date_val + v_daoc_rec.constraint_resolution;

                                        END LOOP;
                                ELSE    -- NUST NOT
                                        -- Use an inner loop to check and resolve any clash.
                                        WHILE RTRIM(TO_CHAR(p_date_val,'DAY')) =
                                                                v_daoc_rec.OFFSET_CONS_TYPE_CD LOOP
                                                p_date_val := p_date_val + v_daoc_rec.constraint_resolution;

                                        END LOOP;
                                END IF;
                        ELSIF   v_daoc_rec.OFFSET_CONS_TYPE_CD = cst_week_day THEN
                                IF v_daoc_rec.constraint_condition = cst_must   THEN
                                        -- Use an inner loop to check and resolve any clash.
                                        WHILE RTRIM(TO_CHAR(p_date_val,'DAY')) NOT IN (cst_monday,
                                                                                        cst_tuesday,
                                                                                        cst_wednesday,
                                                                                        cst_thursday,
                                                                                        cst_friday) LOOP
                                                p_date_val := p_date_val + v_daoc_rec.constraint_resolution;

                                        END LOOP;
                                ELSE    -- MUST NOT
                                        -- Use an inner loop to check and resolve any clash.
                                        WHILE RTRIM(TO_CHAR(p_date_val,'DAY')) IN (     cst_monday,
                                                                                        cst_tuesday,
                                                                                        cst_wednesday,
                                                                                        cst_thursday,
                                                                                        cst_friday) LOOP
                                                p_date_val := p_date_val + v_daoc_rec.constraint_resolution;

                                        END LOOP;
                                END IF;
                        ELSIF   v_daoc_rec.OFFSET_CONS_TYPE_CD = cst_holiday THEN
                                -- If the constraint type is 'HOLIDAY', check that the date does not clash
                                -- against any date alias instance values in HOLIDAY calendars if the
                                -- condition is 'MUST NOT' or that it matches a date alias instance value
                                -- in a HOLIDAY calendar if the condition is 'MUST'.


                                v_msg_name := calpl_holiday_resolve (
                                                                p_date_val,
                                                                v_daoc_rec.constraint_condition,
                                                                v_daoc_rec.constraint_resolution);


                                IF v_msg_name IS NOT NULL THEN
                                        p_message_name := v_msg_name;
                                END IF;
                        ELSIF   v_daoc_rec.OFFSET_CONS_TYPE_CD = cst_inst_break THEN
                                --If the constraint type is 'INST BREAK', check that the date does not fall
                                -- between the dates defined by any date alias instance pairs in HOLIDAY
                                -- calendars if the condition is 'MUST NOT' or that it does if the
                                -- condition is 'MUST'.
                                -- Use an inner loop to match the date against all defined DAIP's.
                                -- Find the start and end dates of any DAI Pair.
                                v_msg_name := calpl_inst_break_resolve (
                                                                        p_date_val,
                                                                        v_daoc_rec.constraint_condition,
                                                                        v_daoc_rec.constraint_resolution );

                                IF v_msg_name IS NOT NULL THEN
                                        p_message_name := v_msg_name;
                                END IF;
                        END IF;
                END LOOP;       -- daoc_func loop

        ELSE
                       FOR v_daoc_rec IN c_daoc_adm LOOP

                        p_constraint_count := p_constraint_count + 1;
                        IF v_daoc_rec.OFFSET_CONS_TYPE_CD IN (  cst_monday,
                                                                        cst_tuesday,
                                                                        cst_wednesday,
                                                                        cst_thursday,
                                                                        cst_friday,
                                                                        cst_saturday,
                                                                        cst_sunday)     THEN
                                IF v_daoc_rec.constraint_condition = cst_must   THEN
                                        -- Use an inner loop to check and resolve any clash.
                                        WHILE RTRIM(TO_CHAR(p_date_val,'DAY')) <>
                                                                v_daoc_rec.OFFSET_CONS_TYPE_CD LOOP
                                                p_date_val := p_date_val + v_daoc_rec.constraint_resolution;

                                        END LOOP;
                                ELSE    -- NUST NOT
                                        -- Use an inner loop to check and resolve any clash.
                                        WHILE RTRIM(TO_CHAR(p_date_val,'DAY')) =
                                                                v_daoc_rec.OFFSET_CONS_TYPE_CD LOOP
                                                p_date_val := p_date_val + v_daoc_rec.constraint_resolution;

                                        END LOOP;
                                END IF;
                        ELSIF   v_daoc_rec.OFFSET_CONS_TYPE_CD = cst_week_day THEN
                                IF v_daoc_rec.constraint_condition = cst_must   THEN
                                        -- Use an inner loop to check and resolve any clash.
                                        WHILE RTRIM(TO_CHAR(p_date_val,'DAY')) NOT IN (cst_monday,
                                                                                        cst_tuesday,
                                                                                        cst_wednesday,
                                                                                        cst_thursday,
                                                                                        cst_friday) LOOP
                                                p_date_val := p_date_val + v_daoc_rec.constraint_resolution;

                                        END LOOP;
                                ELSE    -- MUST NOT
                                        -- Use an inner loop to check and resolve any clash.
                                        WHILE RTRIM(TO_CHAR(p_date_val,'DAY')) IN (     cst_monday,
                                                                                        cst_tuesday,
                                                                                        cst_wednesday,
                                                                                        cst_thursday,
                                                                                        cst_friday) LOOP
                                                p_date_val := p_date_val + v_daoc_rec.constraint_resolution;

                                        END LOOP;
                                END IF;
                        ELSIF   v_daoc_rec.OFFSET_CONS_TYPE_CD = cst_holiday THEN
                                -- If the constraint type is 'HOLIDAY', check that the date does not clash
                                -- against any date alias instance values in HOLIDAY calendars if the
                                -- condition is 'MUST NOT' or that it matches a date alias instance value
                                -- in a HOLIDAY calendar if the condition is 'MUST'.


                                v_msg_name := calpl_holiday_resolve (
                                                                p_date_val,
                                                                v_daoc_rec.constraint_condition,
                                                                v_daoc_rec.constraint_resolution);


                                IF v_msg_name IS NOT NULL THEN
                                        p_message_name := v_msg_name;
                                END IF;
                        ELSIF   v_daoc_rec.OFFSET_CONS_TYPE_CD = cst_inst_break THEN
                                --If the constraint type is 'INST BREAK', check that the date does not fall
                                -- between the dates defined by any date alias instance pairs in HOLIDAY
                                -- calendars if the condition is 'MUST NOT' or that it does if the
                                -- condition is 'MUST'.
                                -- Use an inner loop to match the date against all defined DAIP's.
                                -- Find the start and end dates of any DAI Pair.
                                v_msg_name := calpl_inst_break_resolve (
                                                                        p_date_val,
                                                                        v_daoc_rec.constraint_condition,
                                                                        v_daoc_rec.constraint_resolution );

                                IF v_msg_name IS NOT NULL THEN
                                        p_message_name := v_msg_name;
                                END IF;
                        END IF;
                END LOOP;       -- daoc_adm loop

        END IF;


        EXCEPTION
                WHEN OTHERS THEN
                        IF c_daoc_func%ISOPEN THEN
                                CLOSE c_daoc_func;
                        END IF;

                        IF c_daoc_func%ISOPEN THEN
                                CLOSE c_daoc_func;
                        END IF;

                        RAISE;

END calpl_constraint_resolve;

FUNCTION    check_dl_date( p_uooid             IN  igs_ps_usec_occurs.uoo_id%TYPE,
                           p_date              IN  DATE,
                           p_formula_method    IN  igs_en_nsu_dlstp.formula_method%TYPE,
			   p_last_meeting_date IN  DATE
                           )
RETURN DATE
 ------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 05-MAY-2001
  --
  --Purpose: created for checking whther the calculated dedaline is with unit section end date or not
  --          Called from procedure recal_dl_date
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sarakshi    22-Aug-2005     bug#4113948, Return the last meeting date if p_date is greater than the last meeting date
  -------------------------------------------------------------------
IS

 l_cal_type           igs_ca_inst.cal_type%TYPE;
 l_seq_number         igs_ca_inst.sequence_number%TYPE;
 l_enddate            DATE; -- new deadline date

  l_return            VARCHAR2(1) ; -- decide whether old date exists as deadline or not
  p_unit_sec_end_date DATE;

-- Cursor to get the cal type and sequence number for a given uoo_id
 CURSOR cur_cal_seq (cp_uoo_id igs_ps_usec_occurs.uoo_id%TYPE) IS
        SELECT cal_type,ci_sequence_number
        FROM   igs_ps_unit_ofr_opt
        WHERE  uoo_id = cp_uoo_id;

--Cursor to get unit_sec_end_date
 CURSOR cur_unit_sec_end_date (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
        SELECT unit_section_end_date
        FROM   igs_ps_unit_ofr_opt
        WHERE  uoo_id = cp_uoo_id;


--Cursor to fetch the Calendar Instance End Date
  CURSOR cur_calinst (cp_cal_type  igs_ca_inst.cal_type%TYPE,
                      cp_seq_number igs_ca_inst.sequence_number%TYPE)
  IS
  SELECT end_dt
  FROM   igs_ca_inst
  WHERE  cal_type=cp_cal_type
  AND    sequence_number=cp_seq_number;


BEGIN
  -- Initialization of plsql table
  l_return := 'N'; -- decide whether old date exists as deadline or not

  -- get the cal type nad sequence number
  OPEN cur_cal_seq (p_uooid);
  FETCH cur_cal_seq INTO l_cal_type, l_seq_number;
  CLOSE cur_cal_seq;

  -- get the unit section end date
  OPEN cur_unit_sec_end_date(p_uooid) ;
  FETCH cur_unit_sec_end_date INTO p_unit_sec_end_date;
  CLOSE cur_unit_sec_end_date;
  --Depending on the Formula Method select the end date.
  --IF Formula Method is Duration Days

  l_enddate:=NULL;

  IF p_formula_method='D' OR (p_formula_method='M' AND p_last_meeting_date IS NULL )THEN
     BEGIN
        IF p_unit_sec_end_date IS NULL  THEN
           --Fetch the Cal Inst End Date
           OPEN cur_calinst (l_cal_type, l_seq_number);
           FETCH cur_calinst INTO l_enddate;
           CLOSE cur_calinst;
        ELSE
           l_enddate := p_unit_sec_end_date;
        END IF;

        --If the DeaLine date calculated is > the End date then DeadLine Date is the End date
        IF p_date > l_enddate THEN
           l_return:='Y';
        ELSE
           l_return:='N';
        END IF;
     END;
     --If the Formula Method is Meeting Days
  ELSIF  p_formula_method ='M' THEN

     -- Return the last meeting date if p_date is greater than the last meeting date
     --Added this as a part of bug#4113948
     IF p_date > p_last_meeting_date THEN
           l_return:='Y';
           l_enddate:= p_last_meeting_date;
     END IF;

  END IF; -- End of Formula Method Check

  -- depending  on the value of l_return either p_date will be deadline or l_enddate
  IF l_return = 'N' THEN
     return p_date;
  ELSE
     return l_enddate;
  END IF;

END check_dl_date;

  FUNCTION f_retention_offset_date (
    p_n_uoo_id IN NUMBER,                 -- Unique Identifier for Unit Section
    p_c_formula_method IN VARCHAR2,       -- Formula Method 'D' -> Duration Days, 'N' -> Meeting Days, 'P' -> Percentage of Duration Days, 'M' -> Percentage of Meeting Days.
    p_c_round_method IN VARCHAR2,         -- Round Method 'S' -> Standard Round, 'A' -> Always Round
    p_c_incl_wkend_duration IN VARCHAR2,  -- Include Weekend duration Flag 'Y' -> Duration days is calculated inclusive of weekends otherwise not.
    p_n_offset_value IN NUMBER)           -- Offset value entered by user, may be days or percentages.
  RETURN DATE AS

  /***********************************************************************************************
    Created By     :  smvk
    Date Created By:  18-Sep-2004
    Purpose        :  Function calculates and retuns Retention Offset Date

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

    l_d_us_st_dt igs_ps_unit_ofr_opt_all.unit_section_start_date%TYPE; -- Holds Unit Section Start Date
    l_d_end_dt igs_ps_unit_ofr_opt_all.unit_section_end_date%TYPE;     -- Holds Effection Unit Section End Date (i.e, if available, unit section end date otherwise teaching calendar end date)

    CURSOR c_date(cp_n_uoo_id IN NUMBER) IS
      SELECT a.unit_section_start_date,
             NVL(a.unit_section_end_date,b.end_dt)
      FROM   igs_ps_unit_ofr_opt_all a,
             igs_ca_inst_all b
      WHERE  a.uoo_id = cp_n_uoo_id
      AND    a.cal_type = b.cal_type
      AND    a.ci_sequence_number = b.sequence_number;

    l_c_msg VARCHAR2(30);

  BEGIN

    --LOGGING THE INPUT PARAMETERS
    log_to_fnd('f_retention_offset_date.parameter.p_n_uoo_id',p_n_uoo_id);
    log_to_fnd('f_retention_offset_date.parameter.p_c_formula_method',p_c_formula_method);
    log_to_fnd('f_retention_offset_date.parameter.p_c_round_method',p_c_round_method);
    log_to_fnd('f_retention_offset_date.parameter.p_c_incl_wkend_duration',p_c_incl_wkend_duration);
    log_to_fnd('f_retention_offset_date.parameter.p_n_offset_value',p_n_offset_value);

    -- Populate the dates into local variable for further calculation
    OPEN c_date (p_n_uoo_id);
    FETCH c_date INTO l_d_us_st_dt, l_d_end_dt;
    CLOSE c_date;

    -- Functional Validation : Unit Section Start Date is mandatory for Non Standard Unit Section.
    -- Otherwise calculation will not be done.
    IF l_d_us_st_dt IS NULL THEN
       l_c_msg := 'IGS_EN_OFFSET_DT_NULL';
       fnd_message.set_name ('IGS',l_c_msg);
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
       log_to_fnd('f_retention_offset_date.l_d_us_st_dt','NULL');

       -- Logging the error message (NEED TO REVISIT HERE).
       IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string( fnd_log.level_exception, 'igs.plsql.igs_ps_gen_004.f_retention_offset_date.l_d_us_st_dt', fnd_message.get);
       END IF;

       RETURN NULL;
    END IF;

    log_to_fnd('f_retention_offset_date.l_d_us_st_dt',l_d_us_st_dt);
    log_to_fnd('f_retention_offset_date.l_d_end_dt',l_d_end_dt);

    -- Check the whether it is duration days or meeting days and delegate the call to corresponding functions.
    IF p_c_formula_method IN ('D','P') THEN

       RETURN(duration_days(  p_n_uoo_id              => p_n_uoo_id,
                              p_d_us_st_dt            => l_d_us_st_dt,
                              p_d_end_dt              => l_d_end_dt,
                              p_c_formula_method      => p_c_formula_method,
                              p_c_round_method        => p_c_round_method,
                              p_c_incl_wkend_duration => p_c_incl_wkend_duration,
                              p_n_offset_value        => p_n_offset_value,
                              p_c_msg                 => l_c_msg));

    ELSIF p_c_formula_method IN ('N','M') THEN
       RETURN(meeting_days(  p_n_uoo_id              => p_n_uoo_id,
                              p_d_us_st_dt            => l_d_us_st_dt,
                              p_d_end_dt              => l_d_end_dt,
                              p_c_formula_method      => p_c_formula_method,
                              p_c_round_method        => p_c_round_method,
                              p_c_incl_wkend_duration => p_c_incl_wkend_duration,
                              p_n_offset_value        => p_n_offset_value,
                              p_c_msg                 => l_c_msg));
    END IF;

  END f_retention_offset_date;

  FUNCTION duration_days(   p_n_uoo_id              IN NUMBER,      -- Unique Identifier for Unit Section
                            p_d_us_st_dt            IN DATE,        -- Unit Section Start Date
                            p_d_end_dt              IN DATE,        -- Unit Section End Date
                            p_c_formula_method      IN VARCHAR2,    -- Formula Method 'D' -> Duration Days, 'P' -> Percentage of Duration Days
                            p_c_round_method        IN VARCHAR2,    -- Round Method 'S' -> Standard Round, 'A' -> Always Round
                            p_c_incl_wkend_duration IN VARCHAR2,    -- Include Weekend duration Flag 'Y' -> Duration days is calculated inclusive of weekends otherwise not.
                            p_n_offset_value        IN NUMBER,      -- Offset value entered by user, may be days or percentages.
                            p_c_msg                 OUT NOCOPY VARCHAR2) RETURN DATE IS
  /***********************************************************************************************
    Created By     :  smvk
    Date Created By:  18-Sep-2004
    Purpose        :  Function calculates and retuns Retention Offset Date for formula methods duration days

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

    l_n_duration_days     NUMBER;    -- Holds the number of duration days.
    l_n_weekends          NUMBER;    -- Holds the number of weekends (i.e Saturdays and Sundays).
    l_n_holidays          NUMBER;    -- Holds the number of holidays.
    l_n_total_days        NUMBER;    -- Holds the total number of (duration / meeting) days.
    l_n_offset_days       NUMBER;    -- Holds the offset days.
    l_d_init_retention_dt DATE;      -- Holds the intial retention date.
--    l_d_retention_dt      DATE;    -- Holds the final calculated retention date, returned to the form.
    l_tab_holidays tab_date_type;    -- Holds the date's of Holidays.
    l_b_found             BOOLEAN;   -- Boolean variable holds true/false. contains value true if it finds a hit.

    l_n_cons_id IGS_PS_NSUS_RTN.NON_STD_USEC_RTN_ID%TYPE;

    FUNCTION is_holiday(p_d_date IN DATE) RETURN BOOLEAN IS
      /***********************************************************************************************
       Created By     :  smvk
       Date Created By:  18-Sep-2004
       Purpose        :  Function checks whether the input date is holiday or not.
                         Returns true if holiday is found otherwise false.

       Known limitations,enhancements,remarks:
       Change History (in reverse chronological order)
       Who         When            What
      ********************************************************************************************** */

      l_b_found BOOLEAN;

    BEGIN
      l_b_found := FALSE;
      FOR i IN 1..l_tab_holidays.COUNT LOOP
        IF l_tab_holidays(i) = p_d_date THEN
           l_b_found := TRUE;
           EXIT;
        END IF;
      END LOOP;
      RETURN l_b_found;
    END is_holiday;

    PROCEDURE num_duration_days IS
      /***********************************************************************************************
       Created By     :  smvk
       Date Created By:  18-Sep-2004
       Purpose        :  Procedure to calculate initial retention date based on formula method "Number of Duration Days"
                         l_d_init_retention_dt - holds the calculated initial retention date.

       Known limitations,enhancements,remarks:
       Change History (in reverse chronological order)
       Who         When            What
      ********************************************************************************************** */

      i NUMBER; -- local iteration variable.
      l_n_offset_value NUMBER; -- local variable to hold offet value.
    BEGIN

      -- CALCULATION OF OFFFSET DAYS
      -- For formula method "Number of duration days" is offset value is offset days.
      l_n_offset_value := p_n_offset_value;
      log_to_fnd('num_duration_days.l_n_offset_days',l_n_offset_value);

      -- CALCULATION OF INITIAL OFFSET RETENTION DATE
      -- Initialize the offset date as unit section start date
      -- Increment the date to number of days provided in offset value
      -- Holidays are ignored while incrementing the days.
      -- Weekends are ignored while incrementing if the include weekend in duration flag is unchecked.
      l_d_init_retention_dt := p_d_us_st_dt;
      i := 1;
      log_to_fnd('num_duration_days.before_round_up',l_n_offset_value);
      round_up(p_c_round_method , l_n_offset_value);
      log_to_fnd('num_duration_days.after_round_up',l_n_offset_value);

      WHILE (i <= l_n_offset_value) LOOP
        l_d_init_retention_dt := l_d_init_retention_dt + 1;
        IF NOT (
                  is_holiday(l_d_init_retention_dt) OR
                  (p_c_incl_wkend_duration = 'N' AND
                   TO_CHAR(l_d_init_retention_dt,'D','nls_date_language = american') IN ('1','7')
                   )
               )THEN
           i := i +1;
         END IF;
      END LOOP;
      log_to_fnd('num_duration_days.end',l_d_init_retention_dt);
    END num_duration_days;

    PROCEDURE per_duration_days IS
      /***********************************************************************************************
       Created By     :  smvk
       Date Created By:  18-Sep-2004
       Purpose        :  Procedure to calculate initial retention date based on formula method "Percent of Duration Days"
                         l_d_init_retention_dt - holds the calculated initial retention date.

       Known limitations,enhancements,remarks:
       Change History (in reverse chronological order)
       Who         When            What
      ********************************************************************************************** */

    BEGIN
      -- CALCULATION OF DURATION DAYS: Effective End date - Start Date + 1
      l_n_duration_days := (p_d_end_dt - p_d_us_st_dt ) + 1;
      log_to_fnd('per_duration_days.l_n_duration_days',l_n_duration_days);


      -- CALCULATION OF WEEKENDS:
      IF p_c_incl_wkend_duration = 'N' THEN

         -- Call the function get_weekends to get the total number of weekends (saturdays and sundays)
         l_n_weekends := get_weekends(p_d_us_st_dt,p_d_end_dt);

      ELSE

         -- Should consider weekends during the total duration days. so initializing it to zero.
         l_n_weekends := 0;

      END IF;
      log_to_fnd('per_duration_days.l_n_weekends',l_n_weekends);


      --CALCULATION OF TOTAL NUMBER OF HOLIDAYS.
      l_n_holidays := l_tab_holidays.COUNT;
      log_to_fnd('per_duration_days.l_n_holidays',l_n_holidays);

      -- CALCULATION OF TOTAL DURATION DAYS:
      l_n_total_days :=  l_n_duration_days - (l_n_weekends + l_n_holidays);
      log_to_fnd('per_duration_days.l_n_total_days',l_n_total_days);

      -- CALCULATION OF OFFSET DAYS:
      -- Offset days is offset value percentage of total duration days.
      l_n_offset_days := l_n_total_days * p_n_offset_value / 100;
      log_to_fnd('per_duration_days.before_round_up',l_n_offset_days);

      round_up(p_c_round_method,l_n_offset_days);
      log_to_fnd('per_duration_days.after_round_up',l_n_offset_days);

      -- Initial Retention date is offset days from unit section start date.
      l_d_init_retention_dt := p_d_us_st_dt + l_n_offset_days;
      log_to_fnd('per_duration_days.end',l_d_init_retention_dt);

    END per_duration_days;

  BEGIN  -- Begining of duration days functions.
    -- initialize the PL/SQL table.
    l_tab_holidays.DELETE;

    -- CALCULATION OF HOLIDAYS: It containts 2 steps
    -- Step 1: Call the procedure populate_holidays to populate holidays dates (Date Alias instances defined for holiday calendar) in the PL/SQL table l_tab_holidays
    -- Step 2: Count of dates in holidays PL/SQL table.
    populate_holidays(p_d_us_st_dt, p_d_end_dt, p_c_incl_wkend_duration, l_tab_holidays);


    -- CALCULATION OF INITIAL RETENTION DATE:
    IF p_c_formula_method = 'D' THEN
       num_duration_days;
    ELSIF p_c_formula_method = 'P'THEN
       per_duration_days;
    END IF;


    -- Initial Retention date should not fall on Institution defined holidays or Weekend(saturday / sunday).
    WHILE (l_d_init_retention_dt <= p_d_end_dt) LOOP

      IF (TO_CHAR(l_d_init_retention_dt,'D','nls_date_language = american')) NOT IN ('1','7') THEN

         l_b_found := FALSE;

         FOR i in 1..l_tab_holidays.count LOOP

           IF l_tab_holidays(i) = l_d_init_retention_dt THEN
              l_b_found := TRUE;
              EXIT;
           END IF;

         END LOOP;

         IF NOT l_b_found THEN
            EXIT;
         END IF;

      END IF;

      l_d_init_retention_dt := l_d_init_retention_dt + 1;

    END LOOP;
    log_to_fnd('duration_days.before_constraints',l_d_init_retention_dt);

    -- APPLYING CONSTRAINTS
    l_n_cons_id := get_inst_constraint_id;
    IF l_n_cons_id IS NOT NULL THEN
       log_to_fnd('duration_days.l_n_cons_id',l_n_cons_id);
       calpl_constraint_resolve (  p_date_val              => l_d_init_retention_dt,
                                   p_offset_cnstr_id       => l_n_cons_id,
                                   p_type                  => 'FUNCTION' ,
                                   p_deadline_type         => 'R',
                                   p_msg_name              => p_c_msg );
    END IF;
    log_to_fnd('duration_days.after_constraints',l_d_init_retention_dt);

    IF p_c_msg IS NULL THEN
       -- Final retention date should be less than unit section effective end date.
       -- Otherwise return unit section effective end date
       IF l_d_init_retention_dt <= p_d_end_dt THEN
          RETURN l_d_init_retention_dt;
       ELSE
          RETURN p_d_end_dt;
       END IF;
    ELSE
       log_to_fnd('duration_days.constraints_msg',p_c_msg);
       fnd_message.set_name ('IGS',p_c_msg);
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
    END IF;

  END duration_days;

  FUNCTION meeting_days(    p_n_uoo_id              IN NUMBER,      -- Unique Identifier for Unit Section
                            p_d_us_st_dt            IN DATE,        -- Unit Section Start Date
                            p_d_end_dt              IN DATE,        -- Unit Section End Date
                            p_c_formula_method      IN VARCHAR2,    -- Formula Method 'N' -> Meeting Days, 'M' -> Percentage of Meeting Days.
                            p_c_round_method        IN VARCHAR2,    -- Round Method 'S' -> Standard Round, 'A' -> Always Round
                            p_c_incl_wkend_duration IN VARCHAR2,    -- Include Weekend duration Flag 'Y' -> Duration days is calculated inclusive of weekends otherwise not.
                            p_n_offset_value        IN NUMBER,      -- Offset value entered by user, may be days or percentages.
                            p_c_msg                 OUT NOCOPY VARCHAR2) RETURN DATE IS

    /***********************************************************************************************
       Created By     :  smvk
       Date Created By:  18-Sep-2004
       Purpose        :  Procedure to calculate and return retention date based on formula methods "Meeting Days"

       Known limitations,enhancements,remarks:
       Change History (in reverse chronological order)
       Who         When            What
      ********************************************************************************************** */

    l_b_uso_found         BOOLEAN;     -- Unit Section Occurrence is found for meeting days calcualation or not.
    l_b_date_found        BOOLEAN;
    l_c_formula_method    VARCHAR2(1); -- Local variable to hold formula method.
    l_d_st_dt             DATE;        -- local date variable for iteration between occurrences effective dates.
    l_d_ed_dt             DATE;        -- local date variable to hold occurrence effective end date.
    l_n_tot_meet_days     NUMBER;      -- local variable to hold total number of meeting days.
    l_n_meet_days         NUMBER;      -- local variable to hold number of meeting days.
    l_n_offset_days       NUMBER;      -- local variable to hold offset days.
    l_d_init_retention_dt DATE;        -- local variable to hold initial retention date.
--       l_d_retention_dt      DATE; -- local variable to hold retention date.
    l_n_cons_id IGS_PS_NSUS_RTN.NON_STD_USEC_RTN_ID%TYPE;

    CURSOR c_uso (cp_n_uoo_id IN NUMBER) IS
      SELECT start_date,end_date,to_be_announced,monday, tuesday,wednesday,thursday,friday,saturday,sunday
      FROM   igs_ps_usec_occurs
      WHERE  uoo_id=cp_n_uoo_id
      AND    NO_SET_DAY_IND = 'N';

    l_tab_meeting_days tab_date_type; -- local PL/SQL table to hold meeting dates of unit section
    l_tab_holidays     tab_date_type; -- local PL/SQL table to hold holiday dates which are also meeting dates of unit section.
    l_temp_meeting_days tab_date_type; -- local PL/SQL table to hold meeting dates of unit section

    FUNCTION is_exists(p_d_date IN DATE) RETURN BOOLEAN IS
      /***********************************************************************************************
       Created By     :  smvk
       Date Created By:  18-Sep-2004
       Purpose        :  Function to check whether the meeting date is already existing in the meeting days PL/SQL table.
                         Returns true if exists otherwise false.

       Known limitations,enhancements,remarks:
       Change History (in reverse chronological order)
       Who         When            What
      ********************************************************************************************** */
    BEGIN
       FOR i in 1..l_tab_meeting_days.count LOOP
         IF l_tab_meeting_days(i) = p_d_date THEN
            RETURN TRUE;
         END IF;
       END LOOP;
       RETURN FALSE;
    END is_exists;

    FUNCTION is_holiday(p_d_date IN DATE) RETURN BOOLEAN IS

    BEGIN
      FOR I IN 1 .. l_tab_holidays.COUNT LOOP
          IF l_tab_holidays.exists(I) AND l_tab_holidays(I) = p_d_date THEN
             RETURN TRUE;
          END IF;
      END LOOP;
      RETURN FALSE;
    END is_holiday;

    PROCEDURE trim_meeting_days IS

    BEGIN

      l_temp_meeting_days.delete;
      FOR I in 1 .. l_tab_meeting_days.COUNT LOOP
          IF l_tab_meeting_days.exists(I) AND (NOT is_holiday(l_tab_meeting_days(i))) THEN
             l_temp_meeting_days(l_temp_meeting_days.count + 1) := l_tab_meeting_days(i);
          END IF;
      END LOOP;
    END trim_meeting_days;

    PROCEDURE add_meeting_day (p_d_date IN DATE) IS
      /***********************************************************************************************
       Created By     :  smvk
       Date Created By:  18-Sep-2004
       Purpose        :  Procedure adds the date as a meeting day, if not already exist in meeting days PL/SQL Table.

       Known limitations,enhancements,remarks:
       Change History (in reverse chronological order)
       Who         When            What
      ********************************************************************************************** */

    BEGIN
      IF NOT is_exists(p_d_date) THEN
         l_tab_meeting_days (l_tab_meeting_days.count + 1) := p_d_date;
         log_to_fnd('add_meeting_day.l_tab_meeting_days (' ||l_tab_meeting_days.count || ')',l_tab_meeting_days(l_tab_meeting_days.count));
      END IF;
    END add_meeting_day;

    PROCEDURE trim_holidays IS
      /***********************************************************************************************
       Created By     :  smvk
       Date Created By:  18-Sep-2004
       Purpose        :  Procedure removes the holidays which are not meeting days for this unit section.

       Known limitations,enhancements,remarks:
       Change History (in reverse chronological order)
       Who         When            What
      ********************************************************************************************** */
    BEGIN
      FOR i IN 1 .. l_tab_holidays.COUNT LOOP
          IF NOT is_exists(l_tab_holidays(i)) THEN
             l_tab_holidays.delete(i);
          END IF;
      END LOOP;

    END trim_holidays;

  BEGIN -- Begining of the function meeting_days
    l_b_uso_found := FALSE;

    -- Iterate through the occurrences of unit section and get the meeting dates.
    FOR rec_uso IN c_uso(p_n_uoo_id) LOOP
        l_b_uso_found := TRUE; -- Atleast one Non 'no set day' occurrence exists for unit section.

        log_to_fnd('meeting_days.rec_uso.to_be_announced',rec_uso.to_be_announced);
        -- Check whether the occurrence is to be announced occurrence
        IF rec_uso.to_be_announced = 'Y' THEN
           -- Calculation for to be announced unit section occurrence
           l_d_st_dt := NVL(rec_uso.start_date,p_d_us_st_dt);
           l_d_ed_dt := NVL(rec_uso.end_date,p_d_end_dt);
           log_to_fnd('meeting_days.tba.l_d_st_dt',l_d_st_dt);
           log_to_fnd('meeting_days.tba.l_d_ed_dt',l_d_ed_dt);
           WHILE (l_d_st_dt <= l_d_ed_dt ) LOOP
             IF (TO_CHAR(l_d_st_dt,'D','nls_date_language = american')) NOT IN ('1','7') THEN
                 add_meeting_day(l_d_st_dt);
             END IF;
             l_d_st_dt := l_d_st_dt + 1;
           END LOOP;

        ELSE

           -- Calculation for normal unit section occurrence.
           l_d_st_dt := NVL(rec_uso.start_date,p_d_us_st_dt);
           l_d_ed_dt := NVL(rec_uso.end_date,p_d_end_dt);
           log_to_fnd('meeting_days.uso.l_d_st_dt',l_d_st_dt);
           log_to_fnd('meeting_days.uso.l_d_ed_dt',l_d_ed_dt);
           WHILE (l_d_st_dt <= l_d_ed_dt ) LOOP
             IF(TO_CHAR(l_d_st_dt,'D','nls_date_language = american')) = '1'     AND  rec_uso.sunday = 'Y' THEN
                add_meeting_day(l_d_st_dt);
             ELSIF (TO_CHAR(l_d_st_dt,'D','nls_date_language = american')) = '2' AND  rec_uso.monday = 'Y' THEN
                add_meeting_day(l_d_st_dt);
             ELSIF (TO_CHAR(l_d_st_dt,'D','nls_date_language = american')) = '3' AND  rec_uso.tuesday = 'Y' THEN
                add_meeting_day(l_d_st_dt);
             ELSIF (TO_CHAR(l_d_st_dt,'D','nls_date_language = american')) = '4' AND  rec_uso.wednesday = 'Y' THEN
                add_meeting_day(l_d_st_dt);
             ELSIF (TO_CHAR(l_d_st_dt,'D','nls_date_language = american')) = '5' AND  rec_uso.thursday = 'Y' THEN
                add_meeting_day(l_d_st_dt);
             ELSIF (TO_CHAR(l_d_st_dt,'D','nls_date_language = american')) = '6' AND  rec_uso.friday = 'Y' THEN
                add_meeting_day(l_d_st_dt);
             ELSIF (TO_CHAR(l_d_st_dt,'D','nls_date_language = american')) = '7' AND  rec_uso.saturday = 'Y' THEN
                add_meeting_day(l_d_st_dt);
             END IF;
             l_d_st_dt := l_d_st_dt + 1;
           END LOOP;

        END IF;

    END LOOP;

    IF l_b_uso_found THEN
       -- Flow of execution when the unit section has occurrences other than 'No Set Day' Occurrence.
       populate_holidays ( p_d_start_dt      => p_d_us_st_dt,
                           p_d_end_dt        => p_d_end_dt,
                           p_c_incl_weekends => 'Y',
                           p_tab_holiday     => l_tab_holidays
                         );
       log_to_fnd('meeting_days.l_tab_holidays.count',l_tab_holidays.count);
       IF l_tab_holidays.count > 0 THEN
          -- Trim the holidays PL/SQL table to hold only holidays which are meeting days.
          trim_holidays;
       END IF;

       log_to_fnd('meeting_days.l_tab_meeting_days.COUNT',l_tab_meeting_days.COUNT);
       log_to_fnd('meeting_days.l_tab_holidays.COUNT',l_tab_holidays.COUNT);

       l_n_meet_days := l_tab_meeting_days.COUNT - l_tab_holidays.COUNT;

       log_to_fnd('meeting_days.l_n_meet_days',l_n_meet_days);

       IF p_c_formula_method = 'N' THEN
          l_n_offset_days := p_n_offset_value;
       ELSIF p_c_formula_method = 'M' THEN
          l_n_offset_days := l_n_meet_days * p_n_offset_value /100;
       END IF;

       log_to_fnd('meeting_days.before_round',l_n_offset_days);
       round_up(p_c_round_method,l_n_offset_days);
       log_to_fnd('meeting_days.after_round',l_n_offset_days);

       -- Sort the meeting dates in the ascending order;
       sort_date_array(l_tab_meeting_days);
       trim_meeting_days;

       IF l_n_offset_days = 0  OR l_temp_meeting_days.count = 0 THEN
          l_d_init_retention_dt := p_d_us_st_dt;
       ELSIF l_n_offset_days >= l_temp_meeting_days.count THEN
          l_d_init_retention_dt := l_temp_meeting_days(l_temp_meeting_days.count);
       ELSE
         FOR k in l_n_offset_days..l_temp_meeting_days.count LOOP
             l_b_date_found := FALSE;
             FOR L in 1..l_tab_holidays.count LOOP
               IF l_tab_holidays.exists(L) AND  l_tab_holidays(L) = l_temp_meeting_days(K) THEN
                 l_b_date_found := TRUE;
                 EXIT;
               END IF;
             END LOOP;
             IF NOT l_b_date_found THEN
                l_d_init_retention_dt := l_temp_meeting_days(K);
                EXIT;
             END IF;
         END LOOP;
       END IF;

       log_to_fnd('meeting_days.l_d_init_retention_dt',l_d_init_retention_dt);


       -- APPLYING CONSTRAINTS
       l_n_cons_id := get_inst_constraint_id;
       IF l_n_cons_id IS NOT NULL THEN
          log_to_fnd('meeting_days.l_n_cons_id ',l_n_cons_id );
          calpl_constraint_resolve (  p_date_val              => l_d_init_retention_dt,
                                      p_offset_cnstr_id       => l_n_cons_id,
                                      p_type                  => 'FUNCTION' ,
                                      p_deadline_type         => 'R',
                                      p_msg_name              => p_c_msg );
       END IF;

       log_to_fnd('meeting_days.after_constraints ',l_d_init_retention_dt );
       IF p_c_msg IS NULL THEN
          -- Final retention date should be less than unit section effective end date.
          -- Otherwise return unit section effective end date
          IF l_temp_meeting_days.count = 0 OR l_d_init_retention_dt <= l_temp_meeting_days(l_temp_meeting_days.count) THEN
             RETURN l_d_init_retention_dt;
          ELSE
             RETURN l_temp_meeting_days(l_temp_meeting_days.count);
          END IF;
       ELSE
         log_to_fnd('meeting_days.constraints_msg ',p_c_msg );
          -- Error occurred while applying constraints.
         fnd_message.set_name ('IGS',p_c_msg);
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
       END IF;

    ELSE

       -- This particular piece of code will be executed in the following scenarios only
       -- 1. Unit Section has only no set day occurrences.
       -- 2. Unit Section has no occurrences.
       IF p_c_formula_method = 'N' THEN
          l_c_formula_method := 'D';
       ELSIF p_c_formula_method = 'M' THEN
          l_c_formula_method := 'P';
       END IF;

       return ( duration_days(p_n_uoo_id,
                              p_d_us_st_dt,
                              p_d_end_dt,
                              l_c_formula_method,
                              p_c_round_method,
                              'Y', -- Always include weekends in duration days, as meeting dates are counted if the day is on weekend.
                              p_n_offset_value,
                              p_c_msg ));
    END IF;
  END meeting_days;

  FUNCTION get_weekends ( p_d_start_dt  IN DATE,
                          p_d_end_dt    IN DATE
                        ) RETURN NUMBER IS
    /***********************************************************************************************
     Created By     :  smvk
     Date Created By:  18-Sep-2004
     Purpose        :  Funtion retuns number of weekends (Saturday and Sunday) in the given period (p_d_start_dt, p_d_end_dt).

     Known limitations,enhancements,remarks:
     Change History (in reverse chronological order)
     Who         When            What
    ********************************************************************************************** */

    l_d_date DATE;
    l_n_weekend_count NUMBER;
  BEGIN
    l_n_weekend_count := 0;
    l_d_date := p_d_start_dt;

    WHILE (l_d_date <=p_d_end_dt) LOOP

        IF TO_CHAR(l_d_date,'D','nls_date_language = american') IN ('1','7') THEN
           l_n_weekend_count := l_n_weekend_count + 1;
        END IF;

        l_d_date := l_d_date + 1;

    END LOOP;

    RETURN l_n_weekend_count;

  END get_weekends;

  PROCEDURE populate_holidays ( p_d_start_dt      IN DATE,
                              p_d_end_dt        IN DATE,
                              p_c_incl_weekends IN VARCHAR2,
                              p_tab_holiday     IN OUT NOCOPY tab_date_type
                            )  IS

    /***********************************************************************************************
     Created By     :  smvk
     Date Created By:  18-Sep-2004
     Purpose        :  Procedure to populate holiday dates in PL/SQL table p_tab_holiday for the given period (p_d_start_dt, p_d_end_dt).
                       If the holiday is on saturday or sunday and include weekends flag is checked ('Y') then add them also in p_tab_holiday, Otherwise not.

     Known limitations,enhancements,remarks:
     Change History (in reverse chronological order)
     Who         When            What
    ********************************************************************************************** */

    CURSOR c_cal_inst (cp_d_start_dt IN igs_ca_inst_all.start_dt%TYPE,
                       cp_d_end_dt IN igs_ca_inst_all.end_dt%TYPE) IS
    SELECT DISTINCT ai.absolute_val
    FROM   igs_ca_da_inst ai,
           igs_ca_inst_all ci,
           igs_ca_type ct,
           igs_ca_stat cs
    WHERE  ai.cal_type = ci.cal_type
    AND    ai.ci_sequence_number = ci.sequence_number
    AND    ci.cal_type = ct.cal_type
    AND    ct.s_cal_cat = 'HOLIDAY'
    AND    ci.CAL_STATUS  = cs.CAL_STATUS
    AND    cs.S_CAL_STATUS = 'ACTIVE'
    AND    ct.closed_ind = 'N'
    AND    cs.closed_ind = 'N'
    AND    ci.start_dt < cp_d_end_dt
    AND    ci.end_dt > cp_d_start_dt
    AND    (ai.absolute_val between cp_d_start_dt AND cp_d_end_dt);

    l_n_cnt NUMBER;

  BEGIN

    -- Set the initial counter as zero
    l_n_cnt := 0;
    p_tab_holiday.delete;
    -- For all the holiday calendar instance between given effective dates
    FOR rec_cal_inst IN c_cal_inst(p_d_start_dt, p_d_end_dt) LOOP
        log_to_fnd('populate_holidays.rec_cal_inst.absolute_val',rec_cal_inst.absolute_val);
        -- Add the holiday date into holidays table unless
        -- Holiday is on weekend (i.e saturday or sunday) and the weekends are not included duration days calculation
        IF NOT (TO_CHAR(rec_cal_inst.absolute_val, 'D','nls_date_language = american') IN ('1','7') AND p_c_incl_weekends = 'N') THEN
           l_n_cnt := l_n_cnt + 1;
           p_tab_holiday(l_n_cnt) := rec_cal_inst.absolute_val;
           log_to_fnd('populate_holidays.p_tab_holiday(' ||l_n_cnt || ')',p_tab_holiday(l_n_cnt));
        END IF;

    END LOOP;

  END populate_holidays;

  -- Procedure to sort the date array.
  PROCEDURE sort_date_array (p_tab_array IN OUT NOCOPY tab_date_type) IS
    /***********************************************************************************************
     Created By     :  smvk
     Date Created By:  18-Sep-2004
     Purpose        :  Procedure to sort date values in the array.

     Known limitations,enhancements,remarks:
     Change History (in reverse chronological order)
     Who         When            What
    ********************************************************************************************** */

    l_d_temp DATE; -- temporary varible to hold date during swapping.

  BEGIN

    FOR i IN 1..p_tab_array.COUNT -1 LOOP
       FOR j in i+1 ..p_tab_array.COUNT LOOP
           IF p_tab_array(i) > p_tab_array(j) THEN
              l_d_temp := p_tab_array(i);
              p_tab_array(i) := p_tab_array(j);
              p_tab_array(j) := l_d_temp;
            END IF;
       END LOOP;
    END LOOP;

  END sort_date_array;

  PROCEDURE round_up( p_c_round_method IN VARCHAR2,
                      p_n_value IN OUT NOCOPY NUMBER) IS

    /***********************************************************************************************
     Created By     :  smvk
     Date Created By:  18-Sep-2004
     Purpose        :  Procedure to round up the value (p_n_value) based on rounding method (p_c_round_method).

     Known limitations,enhancements,remarks:
     Change History (in reverse chronological order)
     Who         When            What
    ********************************************************************************************** */

  BEGIN

    -- if the round method is Standard then use normal rounding (ie. 4.2 = 4, 4.5 = 5, 4.6 = 5)
    IF p_c_round_method = 'S' THEN
       p_n_value := ROUND(p_n_value);
    ELSIF p_c_round_method ='A' THEN
    -- if the round method is Always Round up then use ceil value(ie. 4.2 = 5, 4.5 = 5, 4.6 = 5)
       p_n_value := CEIL(p_n_value);
    END IF;

  END round_up;

 FUNCTION get_inst_constraint_id RETURN NUMBER IS
    CURSOR c_call_cnstr IS
      SELECT non_std_usec_rtn_id
      FROM   igs_ps_nsus_rtn
      WHERE  definition_code = 'INSTITUTION'
      AND    ROWNUM <2 ;

    l_n_cons_id IGS_PS_NSUS_RTN.NON_STD_USEC_RTN_ID%TYPE;

BEGIN
  OPEN c_call_cnstr;
  FETCH  c_call_cnstr INTO l_n_cons_id ;
  CLOSE c_call_cnstr;
  RETURN l_n_cons_id;
END get_inst_constraint_id;

END IGS_PS_GEN_004;


/
