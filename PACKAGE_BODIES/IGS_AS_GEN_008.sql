--------------------------------------------------------
--  DDL for Package Body IGS_AS_GEN_008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GEN_008" AS
/* $Header: IGSAS48B.pls 115.4 2003/11/04 13:41:24 msrinivi noship $ */
FUNCTION student_cohort(grading_period 		in varchar2,
			person_id 		in number,
			unit_cd 		in varchar2,
			course_cd 		in varchar2,
			load_cal_type 		in varchar2,
			load_ci_sequence_number in number) RETURN VARCHAR2

IS

CURSOR c_ps(gp_cd varchar2,p_id number) is select 'X' from igs_en_stdnt_ps_att_all a, igs_as_gpc_aca_stndg b
                                                    where  a.progression_status =b.progression_status
                                                    and    b.grading_period_cd = gp_cd
                                                    and    a.person_id = p_id;

CURSOR c_pr(gp_cd varchar2,p_id number) is select 'X' from igs_en_stdnt_ps_att_all a, igs_as_gpc_programs b
                                                    where a.course_cd = b.course_cd
                                                    and   a.version_number = b.course_version_number
                                                    and   b.grading_period_cd = gp_cd
                                                    and   a.person_id = p_id
                                                    and   a.COURSE_ATTEMPT_STATUS = 'ENROLLED';

CURSOR c_us(gp_cd varchar2,p_id number) is select 'X' from igs_as_su_setatmpt a, igs_as_gpc_unit_sets b
                                                    where a.unit_set_cd = b.unit_set_cd
                                                    and   b.grading_period_cd = gp_cd
                                                    and   a.person_id = p_id;

CURSOR c_pg(gp_cd varchar2,p_id number) is select 'X' from igs_pe_prsid_grp_mem_all a, igs_as_gpc_pe_id_grp b
                                                    where a.group_id = b.group_id
                                                    and   b.grading_period_cd = gp_cd
                                                    and   a.person_id = p_id;

CURSOR c_cs(gp_cd varchar2,p_id number,unit_cd varchar2,course_cd varchar2) is select 'X' from igs_as_gpc_cls_stndg a,igs_en_su_attempt_all b
                                                                             where   a.grading_period_cd = gp_cd
                                                                             and   b.unit_cd= unit_cd
                                                                             and   b.course_cd= course_cd
                                                                             and   b.person_id = p_id
                                                                             and   a.class_standing = Igs_Pr_Get_Class_Std.get_class_standing (p_id,b.course_cd,'N',sysdate,load_cal_type,load_ci_sequence_number);

p_status varchar2(30);
p_return char(1);

BEGIN -- student_cohort
	-- Function for finding whether a student exists as per
	-- the grading period cohort set up or not.
	-- This Returns N if student does not exists in any of these cohorts.

	p_return := 'N';

	-- This Cursor checks if Student exists with a particular Progression Status.
	if (grading_period = 'FINAL') then
		p_return := 'Y';
	else
	  open c_ps(grading_period,person_id);
	  fetch c_ps into p_status;
	  if c_ps%NOTFOUND then

		-- This Cursor checks if Student exists with a particular Enrolled Program.
		open c_pr(grading_period,person_id);
		fetch c_pr into p_status;
    		if c_pr%NOTFOUND then

			-- This Cursor checks if Student exists within a particular Unit Set.
    			open c_us(grading_period,person_id);
    			fetch c_us into p_status;
        		if c_us%NOTFOUND then

			  -- This Cursor checks if Student exists within a particular person group.
        		  open c_pg(grading_period,person_id);
        		  fetch c_pg into p_status;
            	  	  if c_pg%NOTFOUND then

			  	-- This Cursor checks if Student exists with a particular Class Standing.
            	  		open c_cs(grading_period,person_id,unit_cd,course_cd);
            	  		fetch c_cs into p_status;
                		if c_cs%FOUND then
                		  p_return := 'Y';
                		end if;

            			close c_cs;


            	  	  else
            		  	p_return := 'Y';
            	  	  end if;

        	 	  close c_pg;


        		else
        		  p_return := 'Y';
        		end if;

        		close c_us;


    		  else
    			p_return := 'Y';
    		  end if;

		close c_pr;

	  else
	  	p_return := 'Y';
	  end if;


	  close c_ps;
	end if;

	RETURN p_return;


  EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_008.student_cohort');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

END student_cohort;

FUNCTION repeat_grades_exist( 	p_person_id		IGS_AS_SU_STMPTOUT_ALL.person_id%TYPE,
				p_unit_cd		IGS_AS_SU_STMPTOUT_ALL.unit_cd%TYPE,
			   	p_course_cd		IGS_AS_SU_STMPTOUT_ALL.course_cd%TYPE,
			   	p_cal_type		IGS_AS_SU_STMPTOUT_ALL.cal_type%TYPE,
			   	p_ci_sequence_number	IGS_AS_SU_STMPTOUT_ALL.ci_sequence_number%TYPE,
                                -- anilk, 22-Apr-2003, Bug# 2829262
				p_uoo_id                IGS_AS_SU_STMPTOUT_ALL.uoo_id%TYPE) RETURN VARCHAR2 IS
BEGIN -- repeat_grades_exist
	-- This function checks whether a particular student outcome record
	-- has any other records created by repeat process

DECLARE

  v_grade			IGS_AS_GRD_SCH_GRADE.grade%TYPE;
  v_repeat_grade_exists		VARCHAR2(1) := 'N';

  CURSOR c_rg IS
	SELECT suao.grade
	FROM   igs_as_suaoa_v        suao,
       	       igs_as_grd_sch_grade  gsg
	WHERE  suao.person_id = p_person_id
	AND    suao.unit_cd = p_unit_cd
	AND    (suao.course_cd <> p_course_cd
        -- anilk, 22-Apr-2003, Bug# 2829262
	OR     suao.uoo_id <> p_uoo_id)
	AND    suao.finalised_outcome_ind = 'Y'
	AND    suao.grading_period_cd = 'FINAL'
	AND    suao.grading_schema_cd = gsg.grading_schema_cd
	AND    suao.version_number = gsg.version_number
	AND    suao.grade = gsg.repeat_grade;


BEGIN  -- Main

  -- Get repeat grades
  OPEN c_rg;
  FETCH c_rg INTO v_grade;
  IF c_rg%FOUND THEN
	v_repeat_grade_exists := 'Y';
  END IF;
  CLOSE c_rg;

  RETURN v_repeat_grade_exists;

  EXCEPTION
	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_008.repeat_grades_exist');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

END;

END repeat_grades_exist ;

FUNCTION get_occur_details
(
    p_uoo_id    igs_ps_unit_ofr_opt.uoo_id%TYPE,
    p_occurs_id IGS_PS_USEC_OCCURS.UNIT_SECTION_OCCURRENCE_ID%TYPE
)
RETURN VARCHAR2 AS

CURSOR c_occur_dtls IS
SELECT
 uoo_id,
 DECODE(a.monday,  'Y',     'MONDAY',  NULL) Monday,
 DECODE(a.tuesday,  'Y',    'TUESDAY',  NULL) Tuesday,
 DECODE(a.wednesday,  'Y',  'WEDNESDAY',  NULL) Wednesday,
 DECODE(a.thursday,  'Y',   'THURSDAY',  NULL) Thursday,
 DECODE(a.friday,  'Y',     'FRIDAY',  NULL) Friday,
 DECODE(a.saturday,  'Y',   'SATURDAY',  NULL) Saturday,
 DECODE(a.sunday,  'Y',     'SUNDAY',  NULL) Sunday,
 TO_CHAR(a.start_time,  'hh:miam')||'-'|| TO_CHAR(a.end_time,  'hh:miam')||' '||
 NVL(d.description,'-')||' '||
 NVL(b.description,'-')||'  '||
 NVL(c.description,'') location
 FROM igs_ps_usec_occurs a,
     igs_ad_building b,
     igs_ad_room c,
     igs_ad_location d
 WHERE
     a.building_code = b.building_id(+) AND
     a.room_code = c.room_id(+) AND
     b.location_cd = d.location_cd(+)  AND
       a.uoo_id = p_uoo_id and
     a.UNIT_SECTION_OCCURRENCE_ID = p_occurs_id;

     c_occur_dtls_rec c_occur_dtls%ROWTYPE;
     l_day_string  VARCHAR2(2000);
BEGIN

OPEN c_occur_dtls ;
FETCH c_occur_dtls INTO c_occur_dtls_REC;
CLOSE c_occur_dtls;

    IF c_occur_dtls_REC.MONDAY = 'MONDAY' THEN
       l_day_string := l_day_string ||' ' ||'Monday';
    END IF;
    IF c_occur_dtls_REC.TUESDAY = 'TUESDAY' THEN
       l_day_string := l_day_string ||' ' ||'Tuesday';
    END IF;
    IF c_occur_dtls_REC.WEDNESDAY = 'WEDNESDAY' THEN
       l_day_string := l_day_string ||' ' ||'Wednesday';
     END IF;
     IF c_occur_dtls_REC.THURSDAY = 'THURSDAY' THEN
       l_day_string := l_day_string ||' ' ||'Thursday';
    END IF;
    IF c_occur_dtls_REC.FRIDAY = 'FRIDAY' THEN
       l_day_string := l_day_string ||' ' ||'Friday';
    END IF;
    IF c_occur_dtls_REC.SATURDAY = 'SATURDAY' THEN
       l_day_string := l_day_string ||' ' ||'Saturday';
    END IF;
    IF c_occur_dtls_REC.SUNDAY = 'SUNDAY' THEN
       l_day_string := l_day_string ||' ' ||'Sunday';
    END IF;

RETURN l_day_string ||' ' || c_occur_dtls_REC.location;
END get_occur_details;


END IGS_AS_GEN_008;

/
