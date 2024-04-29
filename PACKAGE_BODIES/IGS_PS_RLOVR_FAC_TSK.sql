--------------------------------------------------------
--  DDL for Package Body IGS_PS_RLOVR_FAC_TSK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_RLOVR_FAC_TSK" AS
/* $Header: IGSPS83B.pls 120.5 2006/05/01 07:33:22 sommukhe noship $ */

--who        when            what
--
--============================================================================


  FUNCTION crsp_chk_inst_time_conft(
    p_start_dt_1  IN DATE ,
    p_end_dt_1  IN DATE,
    p_monday_1  IN VARCHAR2 ,
    p_tuesday_1  IN VARCHAR2 ,
    p_wednesday_1 IN VARCHAR2 ,
    p_thursday_1  IN VARCHAR2 ,
    p_friday_1  IN VARCHAR2 ,
    p_saturday_1  IN VARCHAR2 ,
    p_sunday_1  IN VARCHAR2 ,
    p_start_dt_2  IN DATE ,
    p_end_dt_2  IN DATE,
    p_monday_2  IN VARCHAR2 ,
    p_tuesday_2  IN VARCHAR2 ,
    p_wednesday_2 IN VARCHAR2 ,
    p_thursday_2  IN VARCHAR2 ,
    p_friday_2  IN VARCHAR2 ,
    p_saturday_2  IN VARCHAR2 ,
    p_sunday_2 IN VARCHAR2
  ) RETURN BOOLEAN AS
  --------------------------------------------------------------------------------
  --Created by  : smaddali ( Oracle IDC)
  --Date created: 21-JAN-2002
  --
  --Purpose: This function will check wether the two unit section ocurences passed are
  -- overlapping at instance level ( ie actual calendar day is overlapping)
  --if yes return true else false
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
  ------------------------------------------------------------------------------
    l_overlap_mon  VARCHAR2(3) DEFAULT NULL;
    l_overlap_tue  VARCHAR2(3) DEFAULT NULL;
    l_overlap_wed  VARCHAR2(3) DEFAULT NULL;
    l_overlap_thu  VARCHAR2(3) DEFAULT NULL;
    l_overlap_fri  VARCHAR2(3) DEFAULT NULL;
    l_overlap_sat  VARCHAR2(3) DEFAULT NULL;
    l_overlap_sun  VARCHAR2(3) DEFAULT NULL;
    l_overlap_start_date  DATE ;
    l_overlap_end_date  DATE ;
    l_loop_date_cntr  DATE ;

  BEGIN
    -- Capture all the days where both unit section occurences are meeting
    IF  p_monday_1 ='Y' AND  p_monday_2 ='Y'  THEN
        l_overlap_mon := 'MON' ;
    END IF;
    IF  p_tuesday_1 ='Y' AND  p_tuesday_2 ='Y'  THEN
        l_overlap_tue := 'TUE' ;
    END IF;
    IF  p_wednesday_1 ='Y' AND  p_wednesday_2 ='Y'  THEN
        l_overlap_wed := 'WED' ;
    END IF;
    IF  p_thursday_1 ='Y' AND  p_thursday_2 ='Y'  THEN
        l_overlap_thu := 'THU' ;
    END IF;
    IF  p_friday_1 ='Y' AND  p_friday_2 ='Y'  THEN
        l_overlap_fri := 'FRI' ;
    END IF;
    IF  p_saturday_1 ='Y' AND  p_saturday_2 ='Y'  THEN
        l_overlap_sat := 'SAT' ;
    END IF;
    IF  p_sunday_1 ='Y' AND  p_sunday_2 ='Y'  THEN
        l_overlap_sun := 'SUN' ;
    END IF;

    --Determine the start date and end date of the overlap period
    --following are the possible scenarios of overlap
    IF (p_start_dt_1 <= p_start_dt_2 AND p_end_dt_1 <= p_end_dt_2) THEN
      --  S1--------------E1
      --        S2-------------------E2
      l_overlap_start_date := p_start_dt_2 ;
      l_overlap_end_date  :=  p_end_dt_1 ;
    ELSIF  (p_start_dt_1 <= p_start_dt_2 AND p_end_dt_1 >= p_end_dt_2 ) THEN
      --  S1----------------------E1
      --        S2--------------E2
      l_overlap_start_date  := p_start_dt_2 ;
      l_overlap_end_date  := p_end_dt_2 ;
    ELSIF  (p_start_dt_1 >= p_start_dt_2 AND  p_end_dt_1 >= p_end_dt_2 ) THEN
      --     S1 --------------- E1
      --   S2 -------------E2
      l_overlap_start_date := p_start_dt_1 ;
      l_overlap_end_date  :=  p_end_dt_2;
    ELSIF  (p_start_dt_1 >= p_start_dt_2 AND p_end_dt_1 <= p_end_dt_2 ) THEN
      --    S1 -----------------E1
      --S2--------------------------E2
      l_overlap_start_date  := p_start_dt_1 ;
      l_overlap_end_date  :=  p_end_dt_1 ;
    END IF;

    --loop thru the overlap dates and check if the unit sections are meeting on
    -- that day  , if yes return true as conflict exists else false
    l_loop_date_cntr  :=  l_overlap_start_date ;
    WHILE l_loop_date_cntr  <= l_overlap_end_date LOOP
       IF  TO_CHAR(l_loop_date_cntr,'DY') IN (l_overlap_mon,l_overlap_tue,
                    l_overlap_wed,l_overlap_thu,l_overlap_fri,l_overlap_sat,
                     l_overlap_sun) THEN
              RETURN TRUE ;
       END IF;
       l_loop_date_cntr  := l_loop_date_cntr + 1;
    END LOOP  ;
    RETURN  FALSE ;

  EXCEPTION
    WHEN OTHERS THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME','Igs_ps_rlovr_fac_tsk.crsp_chk_inst_time_conft');
       IGS_GE_MSG_STACK.ADD;
       App_exception.raise_exception  ;

  END crsp_chk_inst_time_conft;

  --
  FUNCTION crsp_instrct_time_conflct(
    p_person_id  IN NUMBER ,
    p_unit_section_occurrence_id  IN NUMBER ,
    p_monday  IN VARCHAR2 ,
    p_tuesday  IN VARCHAR2 ,
    p_wednesday  IN VARCHAR2 ,
    p_thursday  IN VARCHAR2 ,
    p_friday  IN VARCHAR2 ,
    p_saturday  IN VARCHAR2 ,
    p_sunday  IN VARCHAR2 ,
    p_start_time  IN DATE ,
    p_end_time  IN DATE ,
    p_start_date IN DATE ,
    p_end_date IN DATE ,
    p_calling_module  IN VARCHAR2 ,
    p_message_name  OUT NOCOPY  VARCHAR2
  ) RETURN BOOLEAN AS
  --------------------------------------------------------------------------------
  --Created by  : smaddali ( Oracle IDC)
  --Date created: 22-JAN-2002
  --
  --Purpose: This function will check wether time conflicting unit section ocurences exists
  -- for the passed unit section occurrence
  --if yes return false else true
  --this function is called from the form IGSPS084 and the below procedure within this package
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smvk        21-Apr-2003     Bug # 2902710. Modified the cursor cur_time_conflct to check for
  --                            unit section in meet with class instead unit section occurrence.
  ------------------------------------------------------------------------------

    l_rowid  VARCHAR2(25) ;
    l_start_time  DATE ;
    l_end_time DATE ;
    l_time_conflct_exists  BOOLEAN DEFAULT  FALSE ;

    -- select all the other unit section occurrences assigned to the same instructor as the passed uso
    -- which conflict in date/day/time with the passed unit section occurrence
    -- excluding cross listed and meeting with class group usos , which are not to be announced
    CURSOR cur_time_conflct(cp_start_time DATE , cp_end_time DATE) IS
    SELECT uso.row_id , uso.unit_section_occurrence_id , uso.monday,uso.tuesday,uso.wednesday,
        uso.thursday,uso.friday,uso.saturday , uso.sunday,uso.start_date,uso.end_date
    FROM  igs_ps_usec_occurs uso ,
          igs_ps_uso_instrctrs usoi ,
          igs_ps_unit_ofr_opt uoo ,
          igs_ca_inst ci
    WHERE   usoi.instructor_id = p_person_id AND
            usoi.unit_section_occurrence_id <> p_unit_section_occurrence_id  AND
            usoi.unit_section_occurrence_id = uso.unit_section_occurrence_id AND
            uoo.uoo_id = uso.uoo_id  AND
            uoo.cal_type = ci.cal_type AND
            uoo.ci_sequence_number = ci.sequence_number AND
            ( (uso.monday = p_monday  AND p_monday = 'Y' ) OR
              (uso.tuesday = p_tuesday AND p_tuesday='Y') OR
              (uso.wednesday = p_wednesday AND p_wednesday='Y')  OR
              (uso.thursday = p_thursday AND p_thursday='Y')  OR
              (uso.friday = p_friday  AND p_friday='Y') OR
              (uso.saturday = p_saturday AND p_saturday='Y')  OR
              (uso.sunday = p_sunday  AND p_sunday='Y') )  AND
            ( (NVL(uso.start_date,NVL(uoo.unit_section_start_date,ci.start_dt)) BETWEEN p_start_date AND p_end_date) OR
              (NVL(uso.end_date,NVL(uoo.unit_section_end_date,ci.end_dt)) BETWEEN p_start_date AND p_end_date ) OR
              (p_start_date BETWEEN  NVL(uso.start_date,NVL(uoo.unit_section_start_date,ci.start_dt)) AND
                                  NVL(uso.end_date,NVL(uoo.unit_section_end_date,ci.end_dt)))
            )  AND
            (  (TO_DATE(TO_CHAR(uso.start_time,'HH24:MI'),'HH24:MI') BETWEEN cp_start_time AND cp_end_time) OR
               (TO_DATE(TO_CHAR(uso.end_time,'HH24:MI'),'HH24:MI') BETWEEN cp_start_time AND cp_end_time) OR
               (cp_start_time BETWEEN TO_DATE(TO_CHAR(uso.start_time,'HH24:MI'),'HH24:MI') AND
                                     TO_DATE(TO_CHAR(uso.end_time,'HH24:MI'),'HH24:MI') )
            )  AND
            -- considering boundary conditions as no conflict
            (  (TO_DATE(TO_CHAR(uso.start_time,'HH24:MI'),'HH24:MI') <> cp_end_time) AND
               (TO_DATE(TO_CHAR(uso.end_time,'HH24:MI'),'HH24:MI') <> cp_start_time )
            ) AND
            NVL(uso.to_be_announced,'N') = 'N' AND
            NOT EXISTS (SELECT 'x' FROM igs_ps_uso_clas_meet ucm
                        WHERE ucm.uoo_id = uso.uoo_id )  AND
            NOT EXISTS  (SELECT 'x' FROM igs_ps_usec_x_grpmem uxg
                         WHERE  uxg.uoo_id = uso.uoo_id)
        ORDER BY uso.row_id asc;

        --check if the conflicting record already exists in the temp table before inserting it.
        -- here if we r trying to insert usec_occur_id1 and 2 then we check to see if
        -- usec_occur2 , 1 already exists ,because order doesn't matter
        CURSOR cur_tmp_exists(cp_usec_occur_id2 igs_ps_usec_occurs.unit_section_occurrence_id%TYPE) IS
        SELECT 'x' FROM igs_ps_fac_tcft_tmp
        WHERE  person_id = p_person_id AND
              usec_occur_id1 = cp_usec_occur_id2 AND
              usec_occur_id2 = p_unit_section_occurrence_id  ;
        cur_tmp_exists_rec  cur_tmp_exists%ROWTYPE ;

  BEGIN
    -- format the dates
    --
    l_start_time := TO_DATE(TO_CHAR(p_start_time,'HH24:MI'),'HH24:MI') ;
    l_end_time := TO_DATE(TO_CHAR(p_end_time,'HH24:MI'),'HH24:MI') ;

    -- for each of the conflicting unit section  occurrences loop
    --
    FOR cur_time_conflct_rec IN cur_time_conflct(l_start_time,l_end_time) LOOP
       --  check if time conflict exists at calendar date instance level
       --
       IF NOT crsp_chk_inst_time_conft( p_start_dt_1 => p_start_date,
                                    p_end_dt_1 => p_end_date,
                                    p_monday_1 => p_monday,
                                    p_tuesday_1 => p_tuesday,
                                    p_wednesday_1 => p_wednesday,
                                    p_thursday_1 => p_thursday ,
                                    p_friday_1 => p_friday,
                                    p_saturday_1 => p_saturday,
                                    p_sunday_1 => p_sunday,
                                    p_start_dt_2 => cur_time_conflct_rec.start_date ,
                                    p_end_dt_2 =>  cur_time_conflct_rec.end_date,
                                    p_monday_2 => cur_time_conflct_rec.monday ,
                                    p_tuesday_2 => cur_time_conflct_rec.tuesday,
                                    p_wednesday_2 => cur_time_conflct_rec.wednesday,
                                    p_thursday_2 =>  cur_time_conflct_rec.thursday,
                                    p_friday_2 => cur_time_conflct_rec.friday,
                                    p_saturday_2 => cur_time_conflct_rec.saturday,
                                    p_sunday_2 => cur_time_conflct_rec.sunday )  THEN
            NULL ;
        ELSE
           -- if conflict exists then
           --
            l_time_conflct_exists :=  TRUE ;
            --if form is calling this function then return false
            --
            IF p_calling_module = 'FORM' THEN
                p_message_name :=  'IGS_PS_TIME_CONFLCT_EXIST' ;
                RETURN FALSE ;
            -- if report is calling this function then insert the conflicting record
            --in the temporary table, from where the report displays it
            --
            ELSIF  p_calling_module = 'REPORT'  THEN
              -- check if the record doesn't already exist then insert
              --here  order does not matter  so u1 , u2  and  u2 , u1  both should not exist
               OPEN cur_tmp_exists(cur_time_conflct_rec.unit_section_occurrence_id ) ;
               FETCH cur_tmp_exists INTO cur_tmp_exists_rec ;
               IF cur_tmp_exists%NOTFOUND THEN

                   igs_ps_fac_tcft_tmp_pkg.insert_row (
                        x_rowid     =>  l_rowid ,
                        x_person_id  => p_person_id  ,
                        x_usec_occur_id1   => p_unit_section_occurrence_id ,
                        x_usec_occur_id2   => cur_time_conflct_rec.unit_section_occurrence_id ,
                        x_mode    =>  'R'
                        );
               END IF;
               CLOSE cur_tmp_exists ;
            ELSE
                 RETURN FALSE ;
            END IF ;
        END IF; -- end function call
     END LOOP ;
     --if time conflict exists then return false else return true
     IF  l_time_conflct_exists  THEN
            RETURN FALSE ;
     END IF;
     RETURN TRUE ;

  EXCEPTION
    WHEN OTHERS THEN
       IF cur_tmp_exists%ISOPEN  THEN
         CLOSE cur_tmp_exists ;
       END IF;
       IF  cur_time_conflct%ISOPEN THEN
          CLOSE cur_time_conflct ;
       END IF;
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_RLOVR_FAC_TSK.crsp_instrct_time_conflct');
       IGS_GE_MSG_STACK.ADD;
       App_exception.raise_exception  ;

  END  crsp_instrct_time_conflct;

  --
  PROCEDURE  crsp_prc_inst_time_cft(
    p_person_id IN NUMBER ,
    p_cal_type IN VARCHAR2 ,
    p_sequence_number IN NUMBER
  )  AS
  --------------------------------------------------------------------------------
  --Created by  : smaddali ( Oracle IDC)
  --Date created: 21-JAN-2002
  --
  --Purpose: This procedure will report all the time conflicting unit section ocurences for the
  -- passed instructor(or all instrcutors) . the report IGSPSS12 will use the temp table
  -- where these recs are inserted
  --this procedure is called from report IGSPSS12
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sarakshi    12-Jan-2006     Bug#4926548, modified cursor cur_inst_usec_occur to address the performance issue.
  ------------------------------------------------------------------------------
  -- p_person_id instructor id for which the rollover should be performed ,
  --  run the rollover for all the instructors if null
  -- p_cal_type and p_sequence_number is the load calendar which is mandatory

  --select all the records in the temp table for deletion
    CURSOR  cur_tmp IS
    SELECT rowid
    FROM igs_ps_fac_tcft_tmp  ;


    TYPE teach_cal_rec IS RECORD(
				 cal_type igs_ca_inst_all.cal_type%TYPE,
				 sequence_number igs_ca_inst_all.sequence_number%TYPE
				 );
    TYPE teachCalendar IS TABLE OF teach_cal_rec INDEX BY BINARY_INTEGER;
    teachCalendar_tbl teachCalendar;
    l_n_counter NUMBER(10);
    l_c_proceed BOOLEAN ;

    CURSOR cur_load_teach IS
    SELECT teach_cal_type,teach_ci_sequence_number
    FROM   igs_ca_load_to_teach_v
    WHERE  load_cal_type = p_cal_type
    AND    load_ci_sequence_number = p_sequence_number;

    --select all the unit section occurrences for the passed instructor or all instructors
    -- whose teach cals lie within load calendar passed and to be announced = 'N'
    CURSOR cur_inst_usec_occur IS
    SELECT usoi.instructor_id ,
           uso.unit_section_occurrence_id ,
           uso.monday,
           uso.tuesday,
           uso.wednesday ,
           uso.thursday ,
           uso.friday,
           uso.saturday ,
           uso.sunday ,
           NVL(uso.start_date,NVL(uoo.unit_section_start_date,ci.start_dt))  start_date ,
           NVL(uso.end_date ,NVL(uoo.unit_section_end_date,ci.end_dt))  end_date ,
           uso.start_time ,
           uso.end_time,
	   uoo.cal_type,
	   uoo.ci_sequence_number
    FROM  igs_ps_usec_occurs uso,
          igs_ps_uso_instrctrs usoi ,
          igs_ps_unit_ofr_opt  uoo ,
          igs_ca_inst ci
    WHERE  usoi.instructor_id = p_person_id AND
           usoi.unit_section_occurrence_id = uso.unit_section_occurrence_id AND
           uso.uoo_id = uoo.uoo_id AND
           uoo.cal_type = ci.cal_type  AND
           uoo.ci_sequence_number = ci.sequence_number AND
           NVL(uso.to_be_announced,'N') = 'N' ;

-- Cursor to use when the person_id is null
    CURSOR cur_inst_usec_occur1 IS
    SELECT usoi.instructor_id ,
           uso.unit_section_occurrence_id ,
           uso.monday,
           uso.tuesday,
           uso.wednesday ,
           uso.thursday ,
           uso.friday,
           uso.saturday ,
           uso.sunday ,
           NVL(uso.start_date,NVL(uoo.unit_section_start_date,ci.start_dt))  start_date ,
           NVL(uso.end_date ,NVL(uoo.unit_section_end_date,ci.end_dt))  end_date ,
           uso.start_time ,
           uso.end_time,
	   uoo.cal_type,
	   uoo.ci_sequence_number
    FROM  igs_ps_usec_occurs uso,
          igs_ps_uso_instrctrs usoi ,
          igs_ps_unit_ofr_opt  uoo ,
          igs_ca_inst ci
    WHERE  usoi.instructor_id > -1 AND
           usoi.unit_section_occurrence_id = uso.unit_section_occurrence_id AND
           uso.uoo_id = uoo.uoo_id AND
           uoo.cal_type = ci.cal_type  AND
           uoo.ci_sequence_number = ci.sequence_number AND
           NVL(uso.to_be_announced,'N') = 'N'
    ORDER BY usoi.instructor_id , uso.row_id asc  ;

    l_conflct_exists  BOOLEAN DEFAULT FALSE;
    l_message_name  VARCHAR2(300);
  BEGIN

    -- delete all the records from the temp table before inserting new records
    --
    FOR cur_tmp_rec IN cur_tmp LOOP
        IGS_PS_FAC_TCFT_TMP_PKG.DELETE_ROW (X_ROWID => cur_tmp_rec.rowid) ;
    END LOOP ;

    --for all the unit section occurrences for the passed instructor or all instructors check
    --if any of them conflict with each other and insert those records
    --
    l_n_counter :=1;
    FOR cur_load_teach_rec IN cur_load_teach LOOP
      teachCalendar_tbl(l_n_counter).cal_type :=cur_load_teach_rec.teach_cal_type;
      teachCalendar_tbl(l_n_counter).sequence_number :=cur_load_teach_rec.teach_ci_sequence_number;
      l_n_counter:=l_n_counter+1;
    END LOOP;

    IF teachCalendar_tbl.EXISTS(1) THEN
      IF p_person_id is NOT NULL THEN
      FOR cur_inst_usec_occur_rec IN cur_inst_usec_occur LOOP
	 l_c_proceed:= FALSE;

	   FOR i IN 1..teachCalendar_tbl.last LOOP
	     IF cur_inst_usec_occur_rec.cal_type=teachCalendar_tbl(i).cal_type AND
		cur_inst_usec_occur_rec.ci_sequence_number=teachCalendar_tbl(i).sequence_number THEN
		l_c_proceed:= TRUE;
		EXIT;
	     END IF;
	   END LOOP;


	 IF l_c_proceed THEN
	   l_conflct_exists := crsp_instrct_time_conflct(
	       p_person_id => cur_inst_usec_occur_rec.instructor_id ,
	       p_unit_section_occurrence_id => cur_inst_usec_occur_rec.unit_section_occurrence_id ,
	       p_monday => cur_inst_usec_occur_rec.monday ,
	       p_tuesday => cur_inst_usec_occur_rec.tuesday ,
	       p_wednesday => cur_inst_usec_occur_rec.wednesday ,
	       p_thursday => cur_inst_usec_occur_rec.thursday ,
	       p_friday =>  cur_inst_usec_occur_rec.friday ,
	       p_saturday => cur_inst_usec_occur_rec.saturday ,
	       p_sunday => cur_inst_usec_occur_rec.sunday ,
	       p_start_time => cur_inst_usec_occur_rec.start_time ,
	       p_end_time => cur_inst_usec_occur_rec.end_time ,
	       p_start_date => cur_inst_usec_occur_rec.start_date ,
	       p_end_date => cur_inst_usec_occur_rec.end_date ,
	       p_calling_module => 'REPORT' ,
	       p_message_name => l_message_name) ;
	 END IF;

      END LOOP;
      ELSE
        FOR cur_inst_usec_occur_rec IN cur_inst_usec_occur1 LOOP
	   l_c_proceed:= FALSE;

	     FOR i IN 1..teachCalendar_tbl.last LOOP
	       IF cur_inst_usec_occur_rec.cal_type=teachCalendar_tbl(i).cal_type AND
		  cur_inst_usec_occur_rec.ci_sequence_number=teachCalendar_tbl(i).sequence_number THEN
		  l_c_proceed:= TRUE;
		  EXIT;
	       END IF;
	     END LOOP;


	   IF l_c_proceed THEN
	     l_conflct_exists := crsp_instrct_time_conflct(
		 p_person_id => cur_inst_usec_occur_rec.instructor_id ,
		 p_unit_section_occurrence_id => cur_inst_usec_occur_rec.unit_section_occurrence_id ,
		 p_monday => cur_inst_usec_occur_rec.monday ,
		 p_tuesday => cur_inst_usec_occur_rec.tuesday ,
		 p_wednesday => cur_inst_usec_occur_rec.wednesday ,
		 p_thursday => cur_inst_usec_occur_rec.thursday ,
		 p_friday =>  cur_inst_usec_occur_rec.friday ,
		 p_saturday => cur_inst_usec_occur_rec.saturday ,
		 p_sunday => cur_inst_usec_occur_rec.sunday ,
		 p_start_time => cur_inst_usec_occur_rec.start_time ,
		 p_end_time => cur_inst_usec_occur_rec.end_time ,
		 p_start_date => cur_inst_usec_occur_rec.start_date ,
		 p_end_date => cur_inst_usec_occur_rec.end_date ,
		 p_calling_module => 'REPORT' ,
		 p_message_name => l_message_name) ;
	   END IF;

	END LOOP;

      END IF;
    teachCalendar_tbl.DELETE;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
       IF cur_inst_usec_occur%ISOPEN  THEN
         CLOSE cur_inst_usec_occur ;
       END IF;
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_RLOVR_FAC_TSK.crsp_prc_inst_time_cft');
      IGS_GE_MSG_STACK.ADD;
       App_exception.raise_exception ;
  END  crsp_prc_inst_time_cft;

   PROCEDURE log_messages ( p_msg_name IN VARCHAR2 ,
                           p_msg_val  IN VARCHAR2
                         ) IS
  ------------------------------------------------------------------
  --Created by  : smaddali, Oracle IDC
  --Date created:23/01/2002
  --
  --Purpose: This procedure is private to this package body .
  --         The procedure logs all the parameter values ,
  --         in the log file
  --  called from job procedure rollover_fac_task
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  BEGIN

    FND_MESSAGE.SET_NAME('IGS','IGS_FI_CAL_BALANCES_LOG');
    FND_MESSAGE.SET_TOKEN('PARAMETER_NAME',p_msg_name);
    FND_MESSAGE.SET_TOKEN('PARAMETER_VAL' ,p_msg_val) ;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  END log_messages ;


  --
  PROCEDURE  rollover_fac_task(
    errbuf  OUT NOCOPY VARCHAR2 ,
    retcode OUT NOCOPY NUMBER ,
    p_person_id  IN NUMBER ,
    p_source_cal_type  IN VARCHAR2 ,  --mandatory
    p_dest_cal_type  IN VARCHAR2 ,  -- mandatory
    p_org_id  IN NUMBER  --mandatory
  )  AS
  --------------------------------------------------------------------------------
  --Created by  : smaddali ( Oracle IDC)
  --Date created: 21-JAN-2002
  --
  --Purpose: This procedure is called from the job IGSPSJ11
  --this procedure will rollover faculty workload and tasks from one calendar to the next.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sommukhe     1-May-2006     Bug #5099457, Changes included as incorporated for 4111806
  --sommukhe    10-FEB-2006     Bug #3712546,modified the cursor cur_fac_wl also added cursors cur_fac_wl_null and cur_fac_asg_task
  --sommukhe    24-Jan-2006     Bug #4926548,replaced igs_pe_person_v with hz_parties for cursor c_per_id
  -- sarakshi   14-Feb-2005     Bug#4099575, obsoleted the column std_exp_wl, removed the code asssociated with it
  ------------------------------------------------------------------------------
  -- p_person_id instructor id for which the rollover should be performed ,
  --  run the rollover for all the instructors if null
  -- the  source and dest calendars passed must be of the same calendar category
  --and source is earlier than the dest
  --
    l_source_cal_type  igs_ca_inst.cal_type%TYPE ;
    l_dest_cal_type  igs_ca_inst.cal_type%TYPE;
    l_source_sequence_number  igs_ca_inst.sequence_number%TYPE;
    l_dest_sequence_number  igs_ca_inst.sequence_number%TYPE;
    l_source_start_date  igs_ca_inst.start_dt%TYPE ;
    l_dest_start_date  igs_ca_inst.start_dt%TYPE ;
    l_source_cal_cat  igs_ca_type.s_cal_cat%TYPE ;
    l_dest_cal_cat  igs_ca_type.s_cal_cat%TYPE ;
    l_fac_wl_id  igs_ps_fac_wl.fac_wl_id%TYPE DEFAULT NULL;


    --get the calendar category for the passed calendar
    --
    CURSOR cur_cal_cat(cp_cal_type  igs_ca_type.cal_type%TYPE ) IS
    SELECT s_cal_cat
    FROM  igs_ca_type
    WHERE  cal_type = cp_cal_type ;

    --get all the faculty records
    --
    CURSOR cur_fac_wl  IS
    SELECT person_id , fac_wl_id
    FROM  igs_ps_fac_wl fw
    WHERE  fw.cal_type = l_source_cal_type AND
           fw.ci_sequence_number = l_source_sequence_number AND
           fw.person_id = p_person_id;


    CURSOR  cur_fac_wl_null IS
    SELECT person_id , fac_wl_id
    FROM  igs_ps_fac_wl fw
    WHERE  fw.cal_type = l_source_cal_type
    AND fw.ci_sequence_number = l_source_sequence_number
    AND fw.person_id > -1
    ORDER BY person_id ;

   CURSOR cur_fac_asg_task(cp_fac_wl_id igs_ps_fac_asg_task.fac_wl_id%TYPE)  IS
   SELECT 'x' FROM igs_ps_fac_asg_task
   WHERE  fac_wl_id = cp_fac_wl_id
   AND   NVL(num_rollover_period,99) >= 1
   AND   NVL(rollover_flag,' ') <> 'S';
   cur_fac_asg_task_rec cur_fac_asg_task%ROWTYPE;
    -- check if the faculty record already exists for the dest calendar
    --
    CURSOR cur_fac_wl_exists(cp_person_id  igs_ps_fac_wl.person_id%TYPE)  IS
    SELECT fac_wl_id
    FROM  igs_ps_fac_wl
    WHERE  person_id = cp_person_id AND
           cal_type = l_dest_cal_type AND
           ci_sequence_number = l_dest_sequence_number ;

     -- check if faculty task record already exists in the destination calendar
     --
    CURSOR cur_fat_exists(cp_fac_wl_id  igs_ps_fac_asg_task.fac_wl_id%TYPE ,
                     cp_faculty_task_type   igs_ps_fac_asg_task.faculty_task_type%TYPE) IS
    SELECT  'x'
    FROM  igs_ps_fac_asg_task
    WHERE  fac_wl_id = cp_fac_wl_id AND
          faculty_task_type = cp_faculty_task_type ;
    cur_fat_exists_rec  cur_fat_exists%ROWTYPE ;

    -- get all the assigned tasks for the faculty
    --
    CURSOR  cur_source_tasks(cp_fac_wl_id  igs_ps_fac_asg_task.fac_wl_id%TYPE) IS
    SELECT  *
    FROM  igs_ps_fac_Asg_task_v
    WHERE  fac_wl_id = cp_fac_wl_id AND
           NVL(num_rollover_period,99)  >= 1  ;

    --update the source task type to set rollover_flag='S'
    --
    CURSOR cur_upd_src_task(cp_rowid VARCHAR2 ) IS
    SELECT rowid,igs_ps_fac_asg_task.*
    FROM igs_ps_fac_asg_task
    WHERE rowid = cp_rowid
    FOR UPDATE OF  rollover_flag NOWAIT;

    cur_upd_src_task_rec  cur_upd_src_task%ROWTYPE ;

    --get the faculty name and person number to be logged
    --
    CURSOR c_per_id (cp_person_id  igs_pe_person_v.person_id%TYPE) IS
    SELECT party_number person_number, party_name person_name
    FROM hz_parties
    WHERE party_id =cp_person_id;
    l_per_id    c_per_id%ROWTYPE;

    TYPE plsql_rec IS RECORD (
         person_id  NUMBER ,
         fac_wl_id  NUMBER ) ;
    TYPE plsql_tab  IS TABLE OF plsql_rec INDEX BY BINARY_INTEGER ;
    l_tab_person_id  plsql_tab ;
    cntr  NUMBER DEFAULT 0 ;

  BEGIN
     retcode := 0;
     savepoint a;
     -- set org_id as in request of job
     IGS_GE_GEN_003.set_org_id(p_org_id);

     -- extract the cal type and sequence_numbers,start date from the passed parameters
     --
     l_source_cal_type               := RTRIM(SUBSTR (p_source_cal_type, 1, 10));
     l_source_sequence_number        := TO_NUMBER(RTRIM(SUBSTR (p_source_cal_type,75,7)));
     l_source_start_date  :=  TRUNC(TO_DATE(SUBSTR(p_source_cal_type,12,10),'DD/MM/YY')) ;
     l_dest_cal_type :=   RTRIM(SUBSTR (p_dest_cal_type, 1, 10));
     l_dest_sequence_number := TO_NUMBER(RTRIM(SUBSTR (p_dest_cal_type,75,7))) ;
     l_dest_start_date  :=  TRUNC(TO_DATE(SUBSTR(p_dest_cal_type,12,10),'DD/MM/YY')) ;

      /** logs all the parameters in the LOG **/
      --
     Fnd_Message.Set_Name('IGS','IGS_FI_ANC_LOG_PARM');
     Fnd_File.Put_Line(Fnd_File.LOG,FND_MESSAGE.GET);
      IF p_person_id IS NOT NULL THEN
       OPEN c_per_id(p_person_id);
       FETCH c_per_id INTO l_per_id;
       CLOSE c_per_id;
     END IF;
     log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('PERSON_NUMBER','LEGACY_TOKENS'),l_per_id.person_number);
     log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('SOURCE_CAL','IGS_PS_LOG_PARAMETERS'),p_source_cal_type);
     log_messages(igs_ps_validate_lgcy_pkg.get_lkup_meaning('DEST_CAL','IGS_PS_LOG_PARAMETERS'),p_dest_cal_type);
     FND_FILE.PUT_LINE(Fnd_File.LOG,' ') ;

     -- get the source and dest calendar categories
     --
     OPEN cur_cal_cat(l_source_cal_type);
     FETCH cur_cal_cat INTO l_source_cal_cat ;
     CLOSE cur_cal_cat ;
     OPEN cur_cal_cat(l_dest_cal_type) ;
     FETCH cur_cal_cat  INTO l_dest_cal_cat ;
     CLOSE cur_cal_cat ;

     -- if the source and dest calendars are not of the same category then log message to file and return
     --
     IF l_source_cal_cat <> l_dest_cal_cat THEN
        retcode := 2 ;
        FND_MESSAGE.SET_NAME('IGS','IGS_PS_SAME_CAL_CAT');
        FND_FILE.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET) ;
        RETURN ;
     END IF;

     --if source calendar starts later than the dest calendar then log message in file and return
     --
     IF l_source_start_date >=  l_dest_start_date  THEN
        retcode := 2 ;
        FND_MESSAGE.SET_NAME('IGS','IGS_PS_SOURCE_MORE_DEST');
        FND_FILE.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET) ;
        RETURN ;
     END IF;

     -- copy all the eligible faculty workload records to be rolled over ,into the plsql table
     --
     cntr := 0 ;
     IF p_person_id IS NOT NULL THEN
       FOR cur_fac_wl_rec IN cur_fac_wl LOOP
         OPEN cur_fac_asg_task(cur_fac_wl_rec.fac_wl_id);
	 FETCH cur_fac_asg_task INTO cur_fac_asg_task_rec;
	 IF cur_fac_asg_task%FOUND THEN
	   cntr  := cntr + 1 ;
	   l_tab_person_id(cntr) := cur_fac_wl_rec ;
	 END IF;
	 CLOSE cur_fac_asg_task;
       END LOOP ;
     ELSE
       FOR cur_fac_wl_null_rec IN cur_fac_wl_null LOOP
	 OPEN cur_fac_asg_task(cur_fac_wl_null_rec.fac_wl_id);
	 FETCH cur_fac_asg_task INTO cur_fac_asg_task_rec;
	 IF cur_fac_asg_task%FOUND THEN
	   cntr  := cntr + 1 ;
	   l_tab_person_id(cntr) := cur_fac_wl_null_rec ;
	 END IF;
	 CLOSE cur_fac_asg_task;
       END LOOP ;
     END IF;

     -- if no records found then return after loging message
     --
     IF l_tab_person_id.COUNT = 0 THEN
        retcode := 2 ;
        FND_MESSAGE.SET_NAME('IGS','IGS_PS_NO_ROLLOVER');
        FND_FILE.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET) ;
        RETURN ;
     END IF;

     -- log the heading
     --
     FND_MESSAGE.SET_NAME('IGS','IGS_PS_ROLLOVER_FAC_PROC');
     FND_FILE.PUT_LINE(Fnd_File.LOG, Fnd_Message.GET ) ;

     -- for each of the eligible faculty records rollover into dest calendar
     -- and copy the tasks assigned to that faculty to the dest calendar also
     --
     FOR i IN 1 .. l_tab_person_id.COUNT LOOP
       --
       --log the faculty name and number being processed
       --
        l_fac_wl_id := NULL ;
        OPEN   c_per_id(l_tab_person_id(i).person_id);
        FETCH  c_per_id INTO l_per_id;
        FND_MESSAGE.SET_NAME('IGS','IGS_PS_RLOVR_FACULTY');
        FND_MESSAGE.SET_TOKEN('NUMBER',RPAD(l_per_id.person_number,30));
        FND_MESSAGE.SET_TOKEN('NAME',l_per_id.person_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
        CLOSE  c_per_id;

       OPEN cur_fac_wl_exists(l_tab_person_id(i).person_id) ;
       FETCH cur_fac_wl_exists INTO l_fac_wl_id ;
       -- if the faculty record for the dest calendar doesn't exist already
       --then insert it for the dest calendar
       --
       IF  cur_fac_wl_exists%NOTFOUND  THEN
         DECLARE
           l_rowid  VARCHAR2(40) ;
         BEGIN
            IGS_PS_FAC_WL_PKG.INSERT_ROW (
               X_ROWID => l_rowid ,
               X_FAC_WL_ID           =>  l_fac_wl_id   ,
               X_PERSON_ID           =>   l_tab_person_id(i).person_id ,
               X_CALENDAR_CAT        =>  l_dest_cal_cat ,
               X_CAL_TYPE            =>  l_dest_cal_type ,
               X_CI_SEQUENCE_NUMBER  =>  l_dest_sequence_number ,
               X_ATTRIBUTE_CATEGORY   => NULL ,
               X_ATTRIBUTE1    => NULL ,
               X_ATTRIBUTE2    => NULL ,
               X_ATTRIBUTE3    => NULL ,
               X_ATTRIBUTE4    => NULL ,
               X_ATTRIBUTE5    => NULL ,
               X_ATTRIBUTE6    => NULL ,
               X_ATTRIBUTE7    => NULL ,
               X_ATTRIBUTE8    => NULL ,
               X_ATTRIBUTE9    => NULL ,
               X_ATTRIBUTE10   => NULL ,
               X_ATTRIBUTE11   => NULL ,
               X_ATTRIBUTE12   => NULL ,
               X_ATTRIBUTE13   => NULL ,
               X_ATTRIBUTE14   => NULL ,
               X_ATTRIBUTE15   => NULL ,
               X_ATTRIBUTE16   => NULL ,
               X_ATTRIBUTE17   => NULL ,
               X_ATTRIBUTE18   => NULL ,
               X_ATTRIBUTE19   => NULL ,
               X_ATTRIBUTE20   => NULL ,
               X_MODE    => 'R' ) ;
         END  ;
       END IF ; -- if faculty record in dest cal already exists
       CLOSE cur_fac_wl_exists ;

       -- loop through all the tasks assigned to that faculty in source calendar: fac_wl_id
       --
       FOR cur_source_tasks_rec IN  cur_source_tasks(l_tab_person_id(i).fac_wl_id)  LOOP
           OPEN  cur_fat_exists(l_fac_wl_id,cur_source_tasks_rec.faculty_task_type) ;
           FETCH cur_fat_exists INTO cur_fat_exists_rec ;
           --if the task is not already assigned to the faculty in the dest calendar
           -- then insert it now
           --
           IF cur_fat_exists%NOTFOUND THEN
             DECLARE
               l_rowid1  VARCHAR2(40);
             BEGIN
               IGS_PS_FAC_ASG_TASK_PKG.INSERT_ROW(
                 X_ROWID                    =>  l_rowid1 ,
                 X_FAC_WL_ID                =>  l_fac_wl_id ,
                 X_FACULTY_TASK_TYPE        =>  cur_source_tasks_rec.faculty_task_type ,
                 X_CONFIRMED_IND            =>  cur_source_tasks_rec.confirmed_ind,
                 X_NUM_ROLLOVER_PERIOD      =>  (NVL(cur_source_tasks_rec.num_rollover_period,99) - 1) ,
                 X_ROLLOVER_FLAG            =>  'D' ,
                 X_DEPT_BUDGET_CD           =>  cur_source_tasks_rec.dept_budget_cd ,
                 X_DEFAULT_WL               =>  cur_source_tasks_rec.default_wl  ,
                 X_MODE                     => 'R' );
              -- log the task rolled over
              --
               FND_MESSAGE.SET_NAME('IGS','IGS_PS_FAC_RLOVR_TASK');
               FND_MESSAGE.SET_TOKEN('TASK',cur_source_tasks_rec.faculty_task_type );
               FND_FILE.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET ) ;
             END ;
           END IF; -- task does not exists already
           CLOSE cur_fat_exists ;

           -- update the source task type ,set rollover flag to 'S'
           --
           OPEN cur_upd_src_task( cur_source_tasks_rec.row_id);
           FETCH cur_upd_src_task  INTO  cur_upd_src_task_rec ;
           IF  cur_upd_src_task%FOUND THEN
               IGS_PS_FAC_ASG_TASK_PKG.UPDATE_ROW(
                 X_ROWID                    =>  cur_upd_src_task_rec.rowid,
                 X_FAC_WL_ID                => cur_upd_src_task_rec.fac_wl_id ,
                 X_FACULTY_TASK_TYPE        =>  cur_upd_src_task_rec.faculty_task_type ,
                 X_CONFIRMED_IND            =>  cur_upd_src_task_rec.confirmed_ind,
                 X_NUM_ROLLOVER_PERIOD      =>  cur_upd_src_task_rec.num_rollover_period,
                 X_ROLLOVER_FLAG            =>  'S' ,
                 X_DEPT_BUDGET_CD           =>  cur_upd_src_task_rec.dept_budget_cd ,
                 X_DEFAULT_WL               =>  cur_upd_src_task_rec.default_wl  ,
                 X_MODE                     => 'R' );

           END IF; -- source task type is updated
           CLOSE  cur_upd_src_task ;
        END LOOP  ;  -- copying the source task types to dest

     END LOOP ; -- loop all the faculty workloads to be rolled over

     -- log the successful completion of the job and return
     --
     FND_MESSAGE.SET_NAME('IGS','IGS_PS_FAC_RLOVR_SUC');
     FND_FILE.PUT_LINE(Fnd_File.LOG,Fnd_Message.GET) ;
     RETURN ;

  EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO a;
          retcode:= 2;
          ERRBUF := Fnd_Message.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
          IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
  END  rollover_fac_task;


END igs_ps_rlovr_fac_tsk;

/
