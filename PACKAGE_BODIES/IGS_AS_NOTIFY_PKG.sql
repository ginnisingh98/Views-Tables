--------------------------------------------------------
--  DDL for Package Body IGS_AS_NOTIFY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_NOTIFY_PKG" as
/* $Header: IGSAS40B.pls 120.1 2006/01/18 22:55:57 swaghmar noship $ */
/*
  ||  Created By : nmankodi
  ||  Created On : 04-FEB-2002
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/
FUNCTION get_dt_alias_val (lp_dt_alias IN igs_ca_da_inst.dt_alias%TYPE,
                           lp_teach_cal_type IN igs_ca_inst_all.cal_type%TYPE,
             			   lp_teach_ci_sequence_number IN igs_ca_inst_all.sequence_number%TYPE)
RETURN DATE IS
/*
  ||  Created By : nmankodi
  ||  Created On : 04-FEB-2002
  ||  Purpose : Get the maximum date alias instance value for a given date alias and teaching calendar instance
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/
v_alias_val DATE;
BEGIN

	SELECT	MAX(daiv.alias_val) INTO v_alias_val
	FROM	igs_ca_da_inst_v	daiv
	WHERE	daiv.dt_alias = lp_dt_alias
    AND	    daiv.cal_type = lp_teach_cal_type
	AND	    daiv.ci_sequence_number = lp_teach_ci_sequence_number;

	RETURN v_alias_val;

     EXCEPTION
     WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_NOTIFY_PKG.GET_DT_ALIAS_VAL');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

END get_dt_alias_val; -- get_dt_alias_val

FUNCTION check_grading_cohort (lp_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                               lp_grading_period_cd IN igs_as_grd_schema.grading_schema_cd%TYPE,
                               lp_load_cal_type IN igs_ca_inst_all.cal_type%TYPE,
                               lp_load_ci_sequence_number IN igs_ca_inst_all.sequence_number%TYPE)
RETURN BOOLEAN IS
/*
  ||  Created By : nmankodi
  ||  Created On : 04-FEB-2002
  ||  Purpose : Check if there are any students in the Unit Section which match the Grading Period Cohort.
  ||  Known limitations, enhancements or remarks : The Class Standing check is done last as it is the most costly.
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/

CURSOR	c_sua
IS
SELECT	'X'
FROM    igs_en_su_attempt	sua,
	    igs_en_stdnt_ps_att	spa
WHERE	sua.uoo_id = lp_uoo_id
AND	    sua.person_id = spa.person_id
AND	    sua.course_cd = spa.course_cd
AND	(EXISTS (SELECT 'X'
      		 FROM 	igs_as_gpc_programs gpr
 		     WHERE 	gpr.course_cd = spa.course_cd
		     AND	gpr.course_version_number = spa.version_number
    		 AND 	gpr.grading_period_cd = lp_grading_period_cd)
OR	EXISTS (SELECT 'X'
		    FROM	igs_as_gpc_aca_stndg gas
		    WHERE	spa.progression_status = gas.progression_status
     		AND	gas.grading_period_cd = lp_grading_period_cd)
OR	EXISTS (SELECT 'X'
 		    FROM	igs_pe_prsid_grp_mem pigm,
                    igs_as_gpc_pe_id_grp gpg
     		WHERE  spa.person_id = pigm.person_id
     		AND	pigm.group_id = gpg.group_id
     		AND	gpg.grading_period_cd = lp_grading_period_cd)
OR	EXISTS (SELECT 'X'
            FROM	igs_as_su_setatmpt susa,
                    igs_as_gpc_unit_sets gus
     		WHERE	susa.person_id = spa.person_id
     		AND	susa.course_cd = spa.course_cd
     		AND	(susa.end_dt is NULL
        	OR	susa.rqrmnts_complete_ind = 'Y')
     		AND	susa.unit_set_cd = gus.unit_set_cd
       	    AND	gus.grading_period_cd = lp_grading_period_cd));

CURSOR	c_sua_cs
IS
SELECT	'X'
FROM	igs_en_su_attempt	sua,
	    igs_en_stdnt_ps_att	spa
WHERE	sua.uoo_id = lp_uoo_id
AND	sua.person_id = spa.person_id
AND	sua.course_cd = spa.course_cd
AND	EXISTS (SELECT 'X'
 		FROM	igs_as_gpc_cls_stndg gcs
 		WHERE	gcs.grading_period_cd = lp_grading_period_cd
        AND	gcs.class_standing = IGS_PR_GET_CLASS_STD.Get_Class_Standing(spa.person_id,spa.course_cd,'N',SYSDATE,lp_load_cal_type,lp_load_ci_sequence_number));

v_dummy VARCHAR2(1);

BEGIN

    IF (lp_uoo_id IS NOT NULL AND lp_grading_period_cd IS NOT NULL) THEN
  	-- Check for any students matching the first four Grading Period Cohorts
	OPEN	c_sua ;
	FETCH	c_sua INTO v_dummy;
	IF c_sua%FOUND THEN
		CLOSE	c_sua;
		RETURN TRUE;
	END IF;
	CLOSE	c_sua;


	-- Check for any students matching the Class Standing Grading Period Cohort

	OPEN	c_sua_cs;
	FETCH	c_sua_cs INTO v_dummy;
	IF c_sua_cs%FOUND THEN
		CLOSE	c_sua_cs;
		RETURN TRUE;
	END IF;
	CLOSE	c_sua_cs;

    END IF;
	RETURN FALSE;

    EXCEPTION
     WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_NOTIFY_PKG.CHECK_GRADING_COHORT');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

END check_grading_cohort; --check_grading_cohort


PROCEDURE	raise_business_event (
                lp_internal_name IN VARCHAR2,
                lp_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                lp_teach_description IN igs_ca_inst_all.description%TYPE,
				lp_load_description	IN igs_ca_inst_all.description%TYPE,
				lp_grading_period_start_dt IN DATE,
				lp_grading_period_end_dt IN DATE,
				lp_unit_cd IN igs_ps_unit_ofr_opt_all.unit_cd%TYPE,
				lp_unit_class IN igs_ps_unit_ofr_opt.unit_class%TYPE,
				lp_location_cd IN igs_ps_unit_ofr_opt.location_cd%TYPE,
				lp_location_description	IN igs_ad_location.description%TYPE,
				lp_title IN igs_ps_unit_ver_all.title%TYPE,
				lp_short_title IN igs_ps_unit_ver_all.short_title%TYPE,
				lp_instructor_id IN igs_ps_usec_tch_resp.instructor_id%TYPE )
IS

/*
  ||  Created By : nmankodi
  ||  Created On : 04-FEB-2002
  ||  Purpose : Check if the Business Event has already been raised
  ||            and if it has not raise a new event and record it in the Assessment Notification Business Events table.
  ||  Known limitations, enhancements or remarks : The Class Standing check is done last as it is the most costly.
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/


l_wf_event_t			WF_EVENT_T;
l_wf_parameter_list_t	WF_PARAMETER_LIST_T;
l_key				    NUMBER;
v_dummy                 VARCHAR2(1);
l_rowid                 ROWID;
CURSOR	c_nbe
IS
SELECT	'X'
FROM	igs_as_notify_be	nbe
WHERE	nbe.uoo_id = lp_uoo_id
AND	nbe.internal_name = lp_internal_name;

BEGIN
    IF (lp_uoo_id IS NOT NULL AND lp_internal_name IS NOT NULL) THEN
	-- Check if the Businees Event has already been raised
	OPEN	c_nbe;
	FETCH	c_nbe INTO v_dummy;
	IF c_nbe%FOUND THEN
	CLOSE	c_nbe;
		RETURN;
	END IF;
    CLOSE	c_nbe;
    END IF;

-- Initialize the wf_event_t object
WF_EVENT_T.Initialize(l_wf_event_t);

-- Set the event name
l_wf_event_t.setEventName(pEventName => lp_internal_name);

-- Set the event key
l_wf_event_t.setEventKey (pEventKey => lp_internal_name || lp_uoo_id);

-- Set the parameter list
l_wf_event_t.setParameterList (pParameterList => l_wf_parameter_list_t);

-- Add the parameters to the parameter list
wf_event.AddParameterToList (p_Name => 'UOO_ID',  p_Value => lp_uoo_id, p_parameterlist => l_wf_parameter_list_t);
wf_event.AddParameterToList (p_Name => 'TEACH_DESCRIPTION',  p_Value => lp_teach_description,p_parameterlist => l_wf_parameter_list_t);
wf_event.AddParameterToList (p_Name => 'LOAD_DESCRIPTION',  p_Value => lp_load_description,p_parameterlist => l_wf_parameter_list_t);
wf_event.AddParameterToList (p_Name => 'GRADING_PERIOD_START_DT',  p_Value => lp_grading_period_start_dt,p_parameterlist => l_wf_parameter_list_t);
wf_event.AddParameterToList (p_Name => 'GRADING_PERIOD_END_DT',  p_Value => lp_grading_period_end_dt,p_parameterlist => l_wf_parameter_list_t);
wf_event.AddParameterToList (p_Name => 'UNIT_CD',  p_Value => lp_unit_cd,p_parameterlist => l_wf_parameter_list_t);
wf_event.AddParameterToList (p_Name => 'UNIT_CLASS',  p_Value => lp_unit_class,p_parameterlist => l_wf_parameter_list_t);
wf_event.AddParameterToList (p_Name => 'LOCATION_CD',  p_Value => lp_location_cd,p_parameterlist => l_wf_parameter_list_t);
wf_event.AddParameterToList (p_Name => 'LOCATION_DESCRIPTION',  p_Value => lp_location_description,p_parameterlist => l_wf_parameter_list_t);
wf_event.AddParameterToList (p_Name => 'TITLE',  p_Value => lp_title,p_parameterlist => l_wf_parameter_list_t);
wf_event.AddParameterToList (p_Name => 'SHORT_TITLE',  p_Value => lp_short_title,p_parameterlist => l_wf_parameter_list_t);
wf_event.AddParameterToList (p_Name => 'INSTRUCTOR_ID',  p_Value => lp_instructor_id,p_parameterlist => l_wf_parameter_list_t);

         -- Raise the Business Event
         WF_EVENT.RAISE (p_event_name => lp_internal_name,
                         p_event_key  => lp_internal_name || lp_uoo_id,
                         p_event_data => NULL,
                         p_parameters => l_wf_parameter_list_t);

-- Record that the business event was created
igs_as_notify_be_pkg.insert_row (x_rowid            =>l_rowid,
                                 x_uoo_id           =>lp_uoo_id,
                                 x_internal_name    => lp_internal_name,
                                 x_mode             =>'R'
                                 );

 EXCEPTION
     WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_NOTIFY_PKG.RAISE_BUSINESS_EVENT');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

END raise_business_event; --raise_business_event


PROCEDURE  gen_as_notifications (
     errbuf                     OUT NOCOPY	  VARCHAR2,
     retcode                    OUT NOCOPY	  NUMBER,
     p_load_calendar            IN     VARCHAR2,
     p_attend_advance_offset    IN    NUMBER,
     p_attend_start_offset      IN    NUMBER,
     p_attend_end_offset        IN    NUMBER,
     p_midterm_advance_offset   IN    NUMBER,
     p_midterm_start_offset     IN    NUMBER,
     p_midterm_end_offset       IN    NUMBER,
     p_earlyfinal_advance_offset IN    NUMBER,
     p_earlyfinal_start_offset  IN    NUMBER,
     p_earlyfinal_end_offset    IN    NUMBER,
     p_final_advance_offset     IN    NUMBER,
     p_final_start_offset       IN    NUMBER,
     p_final_end_offset         IN    NUMBER
     )
IS

/*
  ||  Created By : nmankodi
  ||  Created On : 04-FEB-2002
  ||  Purpose : Check if the Business Event has already been raised
  ||            and if it has not raise a new event and record it in the Assessment Notification Business Events table.
  ||  Known limitations, enhancements or remarks : The Class Standing check is done last as it is the most costly.
  ||  Change History :
  ||  Who             When            What
  || swaghmar		16-Jan-2006	Bug# 4951054 - Check for disabling UI's
  ||  (reverse chronological order - newest change first)
*/
l_ld_cal_type                igs_ca_inst_all.cal_type%TYPE;
l_ld_sequence_number         igs_ca_inst_all.sequence_number%TYPE;

CURSOR	c_ttl
IS
SELECT ttl.teach_cal_type,
	   ttl.teach_ci_sequence_number,
	   ttl.teach_description,
	   ttl.load_description
FROM	igs_ca_teach_to_load_v	ttl,
        igs_ca_inst			ci,
        igs_ca_stat			cs
WHERE	ttl.load_cal_type = l_ld_cal_type
AND	    ttl.load_ci_sequence_number = l_ld_sequence_number
AND	    ttl.teach_cal_type = ci.cal_type
AND	    ttl.teach_ci_sequence_number = ci.sequence_number
AND	    ci.cal_status = cs.cal_status
AND	    cs.s_cal_status = 'ACTIVE';


CURSOR	c_uoo (cp_teach_cal_type igs_ca_inst_all.cal_type%TYPE,cp_teach_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE)
IS
SELECT	uoo.uoo_id,
	uoo.unit_cd,
	uoo.unit_class,
	uoo.location_cd,
	loc.description	location_description,
	uoo.call_number,
	uoo.unit_section_start_date,
	uoo.unit_section_end_date,
	uoo.attendance_required_ind,
	uv.title,
	uv.short_title,
	utr.instructor_id
FROM    igs_ps_unit_ofr_opt		uoo,
	    igs_ps_unit_ver		uv,
	    igs_ps_usec_tch_resp	utr,
	    igs_ad_location		loc
WHERE	uoo.cal_type = cp_teach_cal_type
AND	    uoo.ci_sequence_number = cp_teach_ci_sequence_number
AND	    uoo.unit_cd = uv.unit_cd
AND	    uoo.version_number = uv.version_number
AND	    uoo.location_cd = loc.location_cd
AND	    uoo.uoo_id  = utr.uoo_id (+)
AND	    utr.lead_instructor_flag (+) = 'Y'  ;

CURSOR	c_attend_gash (cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
				SELECT	'X'
				FROM	igs_as_gaa_sub_hist		gash
				WHERE	gash.uoo_id = cp_uoo_id
				AND	gash.submission_type = 'ATTENDANCE'
				AND	gash.submission_status = 'COMPLETE'
				AND	gash.submitted_date = (
							SELECT MAX(gash2.submitted_date)
							FROM	igs_as_gaa_sub_hist		gash2
							WHERE	gash2.uoo_id = cp_uoo_id
							AND	gash2.submission_type = 'ATTENDANCE');

CURSOR	c_midterm_gash (cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE)IS
				SELECT	'X'
				FROM	igs_as_gaa_sub_hist		gash
				WHERE	gash.uoo_id = cp_uoo_id
				AND	gash.submission_type = 'GRADE'
				AND	gash.grading_period_cd = 'MIDTERM'
				AND	gash.submission_status = 'COMPLETE'
				AND	gash.submitted_date = (
							SELECT MAX(gash2.submitted_date)
							FROM	igs_as_gaa_sub_hist		gash2
							WHERE	gash2.uoo_id = cp_uoo_id
							AND	gash2.submission_type = 'GRADE'
							AND	gash2.grading_period_cd = 'MIDTERM');

	CURSOR	c_earlyfinal_gash (cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
				SELECT	'X'
				FROM	igs_as_gaa_sub_hist		gash
				WHERE	gash.uoo_id = cp_uoo_id
				AND	gash.submission_type = 'GRADE'
				AND	gash.grading_period_cd = 'EARLY_FINAL'
				AND	gash.submission_status = 'COMPLETE'
				AND	gash.submitted_date = (
						SELECT MAX(gash2.submitted_date)
						FROM	igs_as_gaa_sub_hist		gash2
						WHERE	gash2.uoo_id = cp_uoo_id
						AND	gash2.submission_type = 'GRADE'
						AND	gash2.grading_period_cd = 'EARLY_FINAL');

CURSOR	c_final_gash (cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
				SELECT	'X'
				FROM	igs_as_gaa_sub_hist		gash
				WHERE	gash.uoo_id = cp_uoo_id
				AND	gash.submission_type = 'GRADE'
				AND	gash.grading_period_cd = 'FINAL'
				AND	gash.submission_status = 'COMPLETE'
				AND	gash.submitted_date = (
						SELECT MAX(gash2.submitted_date)
						FROM	igs_as_gaa_sub_hist		gash2
						WHERE	gash2.uoo_id = cp_uoo_id
						AND	gash2.submission_type = 'GRADE'
						AND	gash2.grading_period_cd = 'FINAL');



v_mid_mgs_start_dt_alias    igs_as_cal_conf.mid_mgs_start_dt_alias%TYPE;
v_mid_mgs_end_dt_alias      igs_as_cal_conf.mid_mgs_end_dt_alias%TYPE;
v_efinal_mgs_start_dt_alias igs_as_cal_conf.efinal_mgs_start_dt_alias%TYPE;
v_efinal_mgs_end_dt_alias   igs_as_cal_conf.efinal_mgs_end_dt_alias%TYPE;
v_final_mgs_start_dt_alias  igs_as_cal_conf.final_mgs_start_dt_alias%TYPE;
v_final_mgs_end_dt_alias    igs_as_cal_conf.final_mgs_end_dt_alias%TYPE;
v_midterm_start_dt          DATE;
v_midterm_end_dt            DATE;
v_earlyfinal_start_dt       DATE;
v_earlyfinal_end_dt         DATE;
v_final_start_dt            DATE;
v_final_end_dt              DATE;
v_attend_advance            BOOLEAN;
v_attend_start		        BOOLEAN;
v_attend_end		        BOOLEAN;
v_midterm_advance	        BOOLEAN;
v_midterm_start		        BOOLEAN;
v_midterm_end		        BOOLEAN;
v_earlyfinal_advance	    BOOLEAN;
v_earlyfinal_start	        BOOLEAN;
v_earlyfinal_end	        BOOLEAN;
v_final_advance		        BOOLEAN;
v_final_start		        BOOLEAN;
v_final_end			        BOOLEAN;
v_dummy                     VARCHAR2(1);

BEGIN -- Main


retcode              := 0;
IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054


l_ld_cal_type        := LTRIM(RTRIM(SUBSTR(p_load_calendar,1,10)));
l_ld_sequence_number := TO_NUMBER(SUBSTR(p_load_calendar,-6));

/* Print the Parameters Passed */

      FND_FILE.PUT_LINE(FND_FILE.LOG,'+-------------------------Parameters Passed---------------------------------+');
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Load Calendar Type                : ' || l_ld_cal_type);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Load Calendar Sequence no.        : ' || to_char(l_ld_sequence_number));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Attendance Advance Offset         : ' || TO_CHAR(p_attend_advance_offset));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Attendance Start Offset           : ' || TO_CHAR(p_attend_start_offset))	;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Attendance End Offset             : ' || TO_CHAR(p_attend_end_offset));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Grade-Mid Term Advance Offset     : ' || TO_CHAR(p_midterm_advance_offset));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Grade-Mid Term Start Offset       : ' || TO_CHAR(p_midterm_start_offset));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Grade-Mid Term End Offset         : ' || TO_CHAR(p_midterm_end_offset));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Grade-Early Final Advance Offset  : ' || TO_CHAR(p_earlyfinal_advance_offset));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Grade-Early Final Start Offset    : ' || TO_CHAR(p_earlyfinal_start_offset));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Grade-Early Final End Offset      : ' || TO_CHAR(p_earlyfinal_end_offset));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Grade-Final Advance Offset        : ' || TO_CHAR(p_final_advance_offset));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Grade-Final Start Offset          : ' || TO_CHAR(p_final_start_offset));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Grade-Final End Offset            : ' || TO_CHAR(p_final_end_offset));
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');


-- Get grading date aliases
SELECT	acc.mid_mgs_start_dt_alias,
        acc.mid_mgs_end_dt_alias,
        acc.efinal_mgs_start_dt_alias,
        acc.efinal_mgs_end_dt_alias,
        acc.final_mgs_start_dt_alias,
        acc.final_mgs_end_dt_alias
INTO
        v_mid_mgs_start_dt_alias,
        v_mid_mgs_end_dt_alias,
        v_efinal_mgs_start_dt_alias,
        v_efinal_mgs_end_dt_alias,
        v_final_mgs_start_dt_alias,
        v_final_mgs_end_dt_alias
FROM	igs_as_cal_conf	acc
WHERE	s_control_num = 1;


FOR v_ttl_rec IN c_ttl LOOP
FND_FILE.PUT_LINE(FND_FILE.LOG,'+-------------------------Processing for Teaching Calendar'||':'||v_ttl_rec.teach_description||'---------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
	-- Get the date alias values for each of the grading date aliases
v_midterm_start_dt := get_dt_alias_val      (lp_dt_alias                 => v_mid_mgs_start_dt_alias,
                                            lp_teach_cal_type           => v_ttl_rec.teach_cal_type,
                                            lp_teach_ci_sequence_number => v_ttl_rec.teach_ci_sequence_number);
v_midterm_end_dt := get_dt_alias_val        (lp_dt_alias                 => v_mid_mgs_end_dt_alias,
                                            lp_teach_cal_type           => v_ttl_rec.teach_cal_type,
                                            lp_teach_ci_sequence_number => v_ttl_rec.teach_ci_sequence_number);
v_earlyfinal_start_dt := get_dt_alias_val   (lp_dt_alias                 => v_efinal_mgs_start_dt_alias,
                                            lp_teach_cal_type           => v_ttl_rec.teach_cal_type,
                                            lp_teach_ci_sequence_number => v_ttl_rec.teach_ci_sequence_number);
v_earlyfinal_end_dt := get_dt_alias_val     (lp_dt_alias                 => v_efinal_mgs_end_dt_alias,
                                            lp_teach_cal_type           => v_ttl_rec.teach_cal_type,
                                            lp_teach_ci_sequence_number => v_ttl_rec.teach_ci_sequence_number);
v_final_start_dt := get_dt_alias_val        (lp_dt_alias                 => v_final_mgs_start_dt_alias,
                                            lp_teach_cal_type           => v_ttl_rec.teach_cal_type,
                                            lp_teach_ci_sequence_number => v_ttl_rec.teach_ci_sequence_number);
v_final_end_dt := get_dt_alias_val          (lp_dt_alias                  => v_final_mgs_end_dt_alias,
                                            lp_teach_cal_type           => v_ttl_rec.teach_cal_type,
                                            lp_teach_ci_sequence_number => v_ttl_rec.teach_ci_sequence_number);

    FND_FILE.PUT_LINE(FND_FILE.LOG,'+-------------------------Alias Date Values Derived---------------------------------+');
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
	-- Attendance Notifications

	-- Check if the Attendance Advanced Notification date
    -- has been reached.  Offset from final grading start date.
	IF (p_attend_advance_offset IS NOT NULL AND
        v_final_start_dt IS NOT NULL AND
        TRUNC(v_final_start_dt - p_attend_advance_offset) <= TRUNC(SYSDATE)) THEN
		v_attend_advance := TRUE;
	ELSE

		v_attend_advance := FALSE;
	END IF;


	-- Check if the Attendance Start Notification date has
    -- been reached.  Offset from final grading start date.
	IF (p_attend_start_offset IS NOT NULL AND
	   v_final_start_dt IS NOT NULL AND
       TRUNC(v_final_start_dt - p_attend_start_offset) <= TRUNC(SYSDATE)) THEN

		v_attend_start := TRUE;
	ELSE

		v_attend_start := FALSE;
	END IF;

	-- Check if the Attendance End Notification date has
    -- been reached.  Offset from final grading end date.
	IF (p_attend_end_offset IS NOT NULL AND
	   v_final_end_dt IS NOT NULL AND
        TRUNC(v_final_end_dt - p_attend_end_offset)<= TRUNC(SYSDATE)) THEN

		v_attend_end := TRUE;
	ELSE

		v_attend_end := FALSE;
	END IF;


	-- Mid Term Grading Notifications

	-- Check if the Mid Term Grading Advanced Notification date has
    -- been reached.  Offset from mid term grading start date.
	IF (p_midterm_advance_offset IS NOT NULL AND
	   v_midterm_start_dt IS NOT NULL AND
       TRUNC(v_midterm_start_dt - p_midterm_advance_offset) <= TRUNC(SYSDATE)) THEN

		v_midterm_advance := TRUE;
	ELSE

		v_midterm_advance := FALSE;
	END IF;


	-- Check if the Mid Term Grading Start Notification date has
    -- been reached.  Offset from mid term grading start date.
	IF (p_midterm_start_offset IS NOT NULL AND
	   v_midterm_start_dt IS NOT NULL AND
        TRUNC(v_midterm_start_dt - p_midterm_start_offset) <= TRUNC(SYSDATE)) THEN

		v_midterm_start := TRUE;
	ELSE

		v_midterm_start := FALSE;
	END IF;

	-- Check if the Mid Term Grading End Notification date has
    -- been reached.  Offset from mid term grading end date.
	IF (p_midterm_end_offset IS NOT NULL AND
	   v_midterm_end_dt IS NOT NULL AND
        TRUNC(v_midterm_end_dt - p_midterm_end_offset) <= TRUNC(SYSDATE)) THEN

		v_midterm_end := TRUE;
	ELSE

		v_midterm_end := FALSE;
	END IF;


	-- Early Final Grading Notifications

	-- Check if the Early Final Grading Advanced Notification date has
    -- been reached.  Offset from early final grading start date.
	IF (p_earlyfinal_advance_offset IS NOT NULL AND
	   v_earlyfinal_start_dt IS NOT NULL AND
        TRUNC(v_earlyfinal_start_dt - p_earlyfinal_advance_offset) <= TRUNC(SYSDATE)) THEN

		v_earlyfinal_advance := TRUE;
	ELSE

		v_earlyfinal_advance := FALSE;
	END IF;


	-- Check if the Early Final Grading Start Notification date has
    -- been reached.  Offset from early final grading start date.
	IF (p_earlyfinal_start_offset IS NOT NULL AND
	   v_earlyfinal_start_dt IS NOT NULL AND
        TRUNC(v_earlyfinal_start_dt - p_earlyfinal_start_offset) <= TRUNC(SYSDATE)) THEN

		v_earlyfinal_start := TRUE;
	ELSE

		v_earlyfinal_start := FALSE;
	END IF;

	-- Check if the Early Final Grading End Notification date has
    -- been reached.  Offset from early final grading end date.
	IF (p_earlyfinal_end_offset IS NOT NULL AND
	   v_earlyfinal_end_dt IS NOT NULL AND
       TRUNC(v_earlyfinal_end_dt - p_earlyfinal_end_offset) <= TRUNC(SYSDATE)) THEN

		v_earlyfinal_end := TRUE;
	ELSE

		v_earlyfinal_end := FALSE;
	END IF;


	-- Final Grading Notifications

	-- Check if the Final Grading Advanced Notification date has
    -- been reached.  Offset from final grading start date.
	IF (p_final_advance_offset IS NOT NULL AND
	   v_final_start_dt IS NOT NULL AND
       TRUNC(v_final_start_dt - p_final_advance_offset) <= TRUNC(SYSDATE)) THEN

		v_final_advance := TRUE;
	ELSE

		v_final_advance := FALSE;
	END IF;


	-- Check if the Final Grading Start Notification date has
    -- been reached.  Offset from final grading start date.
	IF (p_final_start_offset IS NOT NULL AND
	   v_final_start_dt IS NOT NULL AND
        TRUNC(v_final_start_dt - p_final_start_offset) <= TRUNC(SYSDATE)) THEN

		v_final_start := TRUE;
	ELSE

		v_final_start := FALSE;
	END IF;

	-- Check if the Final Grading End Notification date has
    -- been reached.  Offset from final grading end date.
	IF (p_final_end_offset IS NOT NULL AND
	   v_final_end_dt IS NOT NULL AND
       TRUNC(v_final_end_dt - p_final_end_offset) <= TRUNC(SYSDATE)) THEN

		v_final_end := TRUE;
	ELSE

		v_final_end := FALSE;
	END IF;


	-- If any of the notification dates have been met loop
	-- through the Unit Sections and create notification business
    -- event where applicable.
	IF (v_attend_advance OR
	   v_attend_start OR
	   v_attend_end OR
	   v_midterm_advance OR
	   v_midterm_start OR
	   v_midterm_end OR
	   v_earlyfinal_advance OR
	   v_earlyfinal_start OR
	   v_earlyfinal_end OR
	   v_final_advance OR
	   v_final_start OR
	   v_final_end )THEN

		FOR v_uoo_rec IN c_uoo(v_ttl_rec.teach_cal_type,v_ttl_rec.teach_ci_sequence_number) LOOP

        FND_FILE.PUT_LINE(FND_FILE.LOG,'+----Processing for Unit Section'||':'||to_char(v_uoo_rec.uoo_id)||':'||v_uoo_rec.unit_cd||':'||v_uoo_rec.unit_class||'----+');
        FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
			-- Attendance Notifications
			IF (v_uoo_rec.attendance_required_ind = 'Y' AND
   			    (v_attend_advance OR
	   		    v_attend_start OR
                v_attend_end)) THEN

				-- Check if Attendance has already been completed
			    OPEN	c_attend_gash(v_uoo_rec.uoo_id);
				FETCH	c_attend_gash INTO v_dummy;

				IF (c_attend_gash%NOTFOUND) THEN
                    CLOSE c_attend_gash;
                    IF (v_attend_advance) THEN

						raise_business_event(
							lp_internal_name             => 'oracle.apps.igs.as.attend.notify_advanced',
							lp_uoo_id                    => v_uoo_rec.uoo_id,
							lp_teach_description         => v_ttl_rec.teach_description,
							lp_load_description          => v_ttl_rec.load_description,
							lp_grading_period_start_dt   => v_final_start_dt,
							lp_grading_period_end_dt     => v_final_end_dt,
							lp_unit_cd                   => v_uoo_rec.unit_cd,
							lp_unit_class                => v_uoo_rec.unit_class,
							lp_location_cd               => v_uoo_rec.location_cd,
							lp_location_description      => v_uoo_rec.location_description,
							lp_title                     => v_uoo_rec.title,
							lp_short_title               => v_uoo_rec.short_title,
							lp_instructor_id             => v_uoo_rec.instructor_id);

					END IF;
                    IF (v_attend_start) THEN

						raise_business_event(
							lp_internal_name             => 'oracle.apps.igs.as.attend.notify_start',
							lp_uoo_id                    => v_uoo_rec.uoo_id,
							lp_teach_description         => v_ttl_rec.teach_description,
							lp_load_description          => v_ttl_rec.load_description,
							lp_grading_period_start_dt   => v_final_start_dt,
							lp_grading_period_end_dt     => v_final_end_dt,
							lp_unit_cd                   => v_uoo_rec.unit_cd,
							lp_unit_class                => v_uoo_rec.unit_class,
							lp_location_cd               => v_uoo_rec.location_cd,
							lp_location_description      => v_uoo_rec.location_description,
							lp_title                     => v_uoo_rec.title,
							lp_short_title               => v_uoo_rec.short_title,
							lp_instructor_id             => v_uoo_rec.instructor_id);


                    END IF;
	   				IF (v_attend_end) THEN

						raise_business_event(
							lp_internal_name             => 'oracle.apps.igs.as.attend.notify_end',
							lp_uoo_id                    => v_uoo_rec.uoo_id,
							lp_teach_description         => v_ttl_rec.teach_description,
							lp_load_description          => v_ttl_rec.load_description,
							lp_grading_period_start_dt   => v_final_start_dt,
							lp_grading_period_end_dt     => v_final_end_dt,
							lp_unit_cd                   => v_uoo_rec.unit_cd,
							lp_unit_class                => v_uoo_rec.unit_class,
							lp_location_cd               => v_uoo_rec.location_cd,
							lp_location_description      => v_uoo_rec.location_description,
							lp_title                     => v_uoo_rec.title,
							lp_short_title               => v_uoo_rec.short_title,
							lp_instructor_id             => v_uoo_rec.instructor_id);


					END IF;
                ELSE
                CLOSE	c_attend_gash;
				END IF;

			END IF;


			-- Mid Term Grading Notifications
			IF (v_midterm_advance OR
	   		   v_midterm_start OR
               v_midterm_end) THEN
				-- Check if Mid Term Grading has been completed
				OPEN	c_midterm_gash(v_uoo_rec.uoo_id);
				FETCH	c_midterm_gash INTO v_dummy;
				IF (c_midterm_gash%NOTFOUND AND
                    check_grading_cohort(v_uoo_rec.uoo_id, 'MIDTERM',l_ld_cal_type,l_ld_sequence_number)) THEN
                    CLOSE c_midterm_gash;
                    IF (v_midterm_advance) THEN

						raise_business_event(
							lp_internal_name             => 'oracle.apps.igs.as.midterm.notify_advanced',
                            lp_uoo_id                    => v_uoo_rec.uoo_id,
							lp_teach_description         => v_ttl_rec.teach_description,
							lp_load_description          => v_ttl_rec.load_description,
							lp_grading_period_start_dt   => v_midterm_start_dt,
							lp_grading_period_end_dt     => v_midterm_end_dt,
							lp_unit_cd                   => v_uoo_rec.unit_cd,
							lp_unit_class                => v_uoo_rec.unit_class,
							lp_location_cd               => v_uoo_rec.location_cd,
							lp_location_description      => v_uoo_rec.location_description,
							lp_title                     => v_uoo_rec.title,
							lp_short_title               => v_uoo_rec.short_title,
							lp_instructor_id             => v_uoo_rec.instructor_id);


					END IF;
                    IF (v_midterm_start) THEN

						raise_business_event(
							lp_internal_name             => 'oracle.apps.igs.as.midterm.notify_start',
						    lp_uoo_id                    => v_uoo_rec.uoo_id,
							lp_teach_description         => v_ttl_rec.teach_description,
							lp_load_description          => v_ttl_rec.load_description,
							lp_grading_period_start_dt   => v_midterm_start_dt,
							lp_grading_period_end_dt     => v_midterm_end_dt,
							lp_unit_cd                   => v_uoo_rec.unit_cd,
							lp_unit_class                => v_uoo_rec.unit_class,
							lp_location_cd               => v_uoo_rec.location_cd,
							lp_location_description      => v_uoo_rec.location_description,
							lp_title                     => v_uoo_rec.title,
							lp_short_title               => v_uoo_rec.short_title,
							lp_instructor_id             => v_uoo_rec.instructor_id);
                    END IF;
	   				IF (v_midterm_end) THEN

						raise_business_event(
							lp_internal_name             => 'oracle.apps.igs.as.midterm.notify_end',
					        lp_uoo_id                    => v_uoo_rec.uoo_id,
							lp_teach_description         => v_ttl_rec.teach_description,
							lp_load_description          => v_ttl_rec.load_description,
							lp_grading_period_start_dt   => v_midterm_start_dt,
							lp_grading_period_end_dt     => v_midterm_end_dt,
							lp_unit_cd                   => v_uoo_rec.unit_cd,
							lp_unit_class                => v_uoo_rec.unit_class,
							lp_location_cd               => v_uoo_rec.location_cd,
							lp_location_description      => v_uoo_rec.location_description,
							lp_title                     => v_uoo_rec.title,
							lp_short_title               => v_uoo_rec.short_title,
							lp_instructor_id             => v_uoo_rec.instructor_id);

					END IF;
                ELSE
                CLOSE c_midterm_gash;
				END IF;

		      END IF;

			-- Early Final Grading Notifications
			IF (v_earlyfinal_advance OR
	   		    v_earlyfinal_start OR
                v_earlyfinal_end) THEN
            -- Check if Early Final Grading has been completed
				OPEN	c_earlyfinal_gash(v_uoo_rec.uoo_id);
				FETCH	c_earlyfinal_gash INTO v_dummy;

				IF (c_earlyfinal_gash%NOTFOUND AND
                   check_grading_cohort (v_uoo_rec.uoo_id, 'EARLY_FINAL',l_ld_cal_type,l_ld_sequence_number)) THEN
                   CLOSE c_earlyfinal_gash;
                    IF v_earlyfinal_advance THEN

						raise_business_event(
							lp_internal_name             => 'oracle.apps.igs.as.earlyfinal.notify_advanced',
                            lp_uoo_id                    => v_uoo_rec.uoo_id,
							lp_teach_description         => v_ttl_rec.teach_description,
							lp_load_description          => v_ttl_rec.load_description,
							lp_grading_period_start_dt   => v_earlyfinal_start_dt,
							lp_grading_period_end_dt     => v_earlyfinal_end_dt,
							lp_unit_cd                   => v_uoo_rec.unit_cd,
							lp_unit_class                => v_uoo_rec.unit_class,
							lp_location_cd               => v_uoo_rec.location_cd,
							lp_location_description      => v_uoo_rec.location_description,
							lp_title                     => v_uoo_rec.title,
							lp_short_title               => v_uoo_rec.short_title,
							lp_instructor_id             => v_uoo_rec.instructor_id);

					END IF;
                    IF v_earlyfinal_start THEN

						raise_business_event(
							lp_internal_name             => 'oracle.apps.igs.as.earlyfinal.notify_start',
							lp_uoo_id                    => v_uoo_rec.uoo_id,
							lp_teach_description         => v_ttl_rec.teach_description,
							lp_load_description          => v_ttl_rec.load_description,
							lp_grading_period_start_dt   => v_earlyfinal_start_dt,
							lp_grading_period_end_dt     => v_earlyfinal_end_dt,
							lp_unit_cd                   => v_uoo_rec.unit_cd,
							lp_unit_class                => v_uoo_rec.unit_class,
							lp_location_cd               => v_uoo_rec.location_cd,
							lp_location_description      => v_uoo_rec.location_description,
							lp_title                     => v_uoo_rec.title,
							lp_short_title               => v_uoo_rec.short_title,
							lp_instructor_id             => v_uoo_rec.instructor_id);

                    END IF;
	   				IF v_earlyfinal_end THEN

						raise_business_event(
							lp_internal_name             => 'oracle.apps.igs.as.earlyfinal.notify_end',
							lp_uoo_id                    => v_uoo_rec.uoo_id,
							lp_teach_description         => v_ttl_rec.teach_description,
							lp_load_description          => v_ttl_rec.load_description,
							lp_grading_period_start_dt   => v_earlyfinal_start_dt,
							lp_grading_period_end_dt     => v_earlyfinal_end_dt,
							lp_unit_cd                   => v_uoo_rec.unit_cd,
							lp_unit_class                => v_uoo_rec.unit_class,
							lp_location_cd               => v_uoo_rec.location_cd,
							lp_location_description      => v_uoo_rec.location_description,
							lp_title                     => v_uoo_rec.title,
							lp_short_title               => v_uoo_rec.short_title,
							lp_instructor_id             => v_uoo_rec.instructor_id);

					END IF;
                ELSE
                CLOSE c_earlyfinal_gash;
				END IF;

    		END IF;


			-- Final Grading Notifications
			IF (v_final_advance OR
	   		   v_final_start OR
               v_final_end )THEN
            -- Check if Early Final Grading has been completed
				OPEN	c_final_gash(v_uoo_rec.uoo_id);
				FETCH	c_final_gash INTO v_dummy;

                IF c_final_gash%NOTFOUND THEN
                    CLOSE c_final_gash;
                    IF v_final_advance THEN
						raise_business_event(
							lp_internal_name             => 'oracle.apps.igs.as.final.notify_advanced',
							lp_uoo_id                    => v_uoo_rec.uoo_id,
							lp_teach_description         => v_ttl_rec.teach_description,
							lp_load_description          => v_ttl_rec.load_description,
							lp_grading_period_start_dt   => v_final_start_dt,
							lp_grading_period_end_dt     => v_final_end_dt,
							lp_unit_cd                   => v_uoo_rec.unit_cd,
							lp_unit_class                => v_uoo_rec.unit_class,
							lp_location_cd               => v_uoo_rec.location_cd,
							lp_location_description      => v_uoo_rec.location_description,
							lp_title                     => v_uoo_rec.title,
							lp_short_title               => v_uoo_rec.short_title,
							lp_instructor_id             => v_uoo_rec.instructor_id);

					END IF;
                    IF v_final_start THEN
						raise_business_event(
							lp_internal_name             => 'oracle.apps.igs.as.final.notify_start',
							lp_uoo_id                    => v_uoo_rec.uoo_id,
							lp_teach_description         => v_ttl_rec.teach_description,
							lp_load_description          => v_ttl_rec.load_description,
							lp_grading_period_start_dt   => v_final_start_dt,
							lp_grading_period_end_dt     => v_final_end_dt,
							lp_unit_cd                   => v_uoo_rec.unit_cd,
							lp_unit_class                => v_uoo_rec.unit_class,
							lp_location_cd               => v_uoo_rec.location_cd,
							lp_location_description      => v_uoo_rec.location_description,
							lp_title                     => v_uoo_rec.title,
							lp_short_title               => v_uoo_rec.short_title,
							lp_instructor_id             => v_uoo_rec.instructor_id);

                    END IF;
	   				IF v_final_end THEN
						raise_business_event(
							lp_internal_name             => 'oracle.apps.igs.as.final.notify_end',
							lp_uoo_id                    => v_uoo_rec.uoo_id,
							lp_teach_description         => v_ttl_rec.teach_description,
							lp_load_description          => v_ttl_rec.load_description,
							lp_grading_period_start_dt   => v_final_start_dt,
							lp_grading_period_end_dt     => v_final_end_dt,
							lp_unit_cd                   => v_uoo_rec.unit_cd,
							lp_unit_class                => v_uoo_rec.unit_class,
							lp_location_cd               => v_uoo_rec.location_cd,
							lp_location_description      => v_uoo_rec.location_description,
							lp_title                     => v_uoo_rec.title,
							lp_short_title               => v_uoo_rec.short_title,
							lp_instructor_id             => v_uoo_rec.instructor_id);
					END IF;
                ELSE
                CLOSE c_final_gash;
				END IF;

    		END IF;
		END LOOP; -- c_uoo

	END IF;
END LOOP; -- c_ttl

 EXCEPTION
     WHEN OTHERS THEN
      errbuf :=  FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      retcode := 2;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_NOTIFY_PKG.GEN_AS_NOTIFICATIONS');
      FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
      IGS_GE_MSG_STACK.ADD;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;


END gen_as_notifications; --gen_as_notifications

PROCEDURE raise_sua_ref_cd_be(P_AUTH_PERSON_ID IN NUMBER,
                                P_PERSON_ID IN NUMBER,
                			       	  P_SUAR_ID  IN NUMBER,
                				        P_ACTION         IN VARCHAR2 ) IS

    CURSOR c_seq_num IS
    SELECT IGS_AS_WF_BESUAREFCDS_S.nextval
    FROM DUAL;
    ln_seq_val            NUMBER;
    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    BEGIN

   -- initialize the parameter list.
     wf_event_t.Initialize(l_event_t);

   -- set the parameters.
     wf_event.AddParameterToList ( p_name => 'AUTH_PERSON_ID'     , p_value => P_AUTH_PERSON_ID   , p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_name => 'PERSON_ID'     , p_value => P_PERSON_ID     , p_parameterlist  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'SUAR_ID'     , p_Value => P_SUAR_ID     , p_ParameterList  => l_parameter_list_t);
     wf_event.AddParameterToList ( p_Name => 'ACTION'        , p_Value => p_action        , p_ParameterList  => l_parameter_list_t);

   -- get the sequence value to be added to EVENT KEY to make it unique.
     OPEN  c_seq_num;
     FETCH c_seq_num INTO ln_seq_val ;
     CLOSE c_seq_num ;
     -- raise event
     if (P_ACTION = 'UPDATE') then
          WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.as.SUArefcd.update',
           p_event_key  => 'SUA_REF'||ln_seq_val,
	         p_parameters => l_parameter_list_t);
      end if ;
    if (P_ACTION = 'INSERT') then
       WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.as.SUArefcd.insert',
       p_event_key  => 'SUA_REF'||ln_seq_val,
	     p_parameters => l_parameter_list_t);
    end if ;
END raise_sua_ref_cd_be;
END igs_as_notify_pkg;

/
