--------------------------------------------------------
--  DDL for Package Body IGS_AU_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AU_GEN_003" AS
/* $Header: IGSAU03B.pls 115.21 2003/12/09 12:07:35 rvangala ship $ */
-- WHO		 WHEN 		WHAT
-- pradhakr      03/07/2001	Added a function enrp_get_sph_col in this package.
--				Changes in the function Audp_Get_scah_col, Audp_Get_Suah_Col.
-- smaddali 	 02/07/2001	adding a new function audp_get_enrs_stat in the
--				enrollment processes build of nov 2001 to calculate
--				seats reserved,number of students discontinued and
--				dropped from a unit section
-- adding a new function audp_get_enrs_stat in the enrollment processes
-- build of nov 2001 release , to get the statistics column values
-- bayadav   09-Nov-2001       Added 5 columns in audp_get_scah_col and 2 columns in audp_get_susah_col
-- pkpatel   25-OCT-2002    Bug No: 2613704
--                          Replaced column inst_priority_code_id with inst_priority_cd
--rvangala   01-OCT-2003      Added variable cst_core_indicator and modified cursor c_suah to function
--			      Audp_Get_Suah_Col, Enh Bug# 3052432
--ijeddy      06-Nov-2003    Build  3129913, Program completion Validation.
-- rvangala  09-Dec-2003    Added coo_id, igs_pr_class_std_id to Audp_Get_Scah_Col
--                          Bug #2829263


FUNCTION Audp_Get_Enrs_Stat(
  p_stat_column IN VARCHAR2 ,
  p_uoo_id IN NUMBER    )
RETURN NUMBER AS
BEGIN	-- audp_get_enrs_stat
	-- get the value  for seats reserved or number of students dropped
	-- or number of students discontinued depending on column passed
	-- for the given unit section
   DECLARE
      -- get count of students discontinued in this unit section
      CURSOR cur_disc IS
      SELECT COUNT(*)
      FROM igs_en_su_attempt
      WHERE uoo_id = p_uoo_id
      AND unit_attempt_status = 'DISCONTIN' ;

      -- get count of students dropped in this unit section
      CURSOR cur_drop IS
      SELECT COUNT(*)
      FROM igs_en_su_attempt
      WHERE uoo_id = p_uoo_id
      AND unit_attempt_status = 'DROPPED' ;

      -- get  unit section  preferences
      CURSOR cur_usec_preferences(cp_usec_priority_id IN NUMBER) IS
      SELECT rsv_usec_pri_id ,
             rsv_usec_prf_id,
             percentage_reserved
      FROM igs_ps_rsv_usec_prf
      WHERE rsv_usec_pri_id = cp_usec_priority_id ;

     --get unit section priorities
      CURSOR cur_usec_priorities IS
      SELECT rsv_usec_pri_id
      FROM igs_ps_rsv_usec_pri
      WHERE uoo_id = p_uoo_id ;

      --get maximum enrollment for this unit section or unit
      CURSOR cur_max_enrollment IS
      SELECT NVL( NVL(usec.enrollment_maximum,uv.enrollment_maximum),0)
      FROM igs_ps_usec_lim_wlst usec,
           igs_ps_unit_ver uv,
           igs_ps_unit_ofr_opt uoo
      WHERE uoo.unit_cd = uv.unit_cd
      AND uoo.version_number = uv.version_number
      AND uoo.uoo_id = usec.uoo_id
      AND uoo.uoo_id = p_uoo_id ;

      l_stat_value  NUMBER := 0;
      l_max_enr NUMBER;
    BEGIN
     -- get the number of seats reserved for this unit section
      IF p_stat_column = 'SEATS_RESERVED' THEN
        OPEN cur_max_enrollment ;
        FETCH cur_max_enrollment INTO l_max_enr ;
        CLOSE cur_max_enrollment ;
        FOR rec_usec_priorities IN cur_usec_priorities
        LOOP
          FOR rec_usec_preferences IN cur_usec_preferences( rec_usec_priorities.rsv_usec_pri_id )
          LOOP
            l_stat_value := l_stat_value + FLOOR((l_max_enr * rec_usec_preferences.percentage_reserved) / 100) ;
          END LOOP;
        END LOOP;
     -- get the number of students discontinued for this unit section
      ELSIF p_stat_column = 'DISCONTINUED' THEN
        OPEN cur_disc ;
        FETCH cur_disc INTO l_stat_value ;
        CLOSE cur_disc ;
     -- get the number of students dropped for this unit section
      ELSIF p_stat_column = 'DROPPED' THEN
        OPEN cur_drop ;
        FETCH cur_drop INTO l_stat_value ;
        CLOSE cur_drop ;
      END IF;
      RETURN l_stat_value ;
    END;
  END  audp_get_enrs_stat;


FUNCTION Audp_Get_Gach_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN NUMBER ,
  p_create_dt IN DATE ,
  p_grd_cal_type IN VARCHAR2 ,
  p_grd_ci_sequence_number IN NUMBER ,
  p_ceremony_number IN NUMBER ,
  p_award_course_cd IN VARCHAR2 ,
  p_award_crs_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_hist_date IN DATE )
RETURN VARCHAR2 AS
BEGIN	-- audp_get_gach_col
	-- get the oldest column value (after a given date) for a
	-- specified column, unit_cd and version_number.
  DECLARE
  	cst_us_group_number			VARCHAR2(30) := 'US_GROUP_NUMBER';
	cst_order_in_presentation		VARCHAR2(30) := 'ORDER_IN_PRESENTATION';
	cst_graduand_seat_number		VARCHAR2(30) := 'GRADUAND_SEAT_NUMBER';
	cst_name_pronunciation			VARCHAR2(30) := 'NAME_PRONUNCIATION';
	cst_name_announced			VARCHAR2(30) := 'NAME_ANNOUNCED';
	cst_academic_dress_rqrd_ind		VARCHAR2(30) := 'ACADEMIC_DRESS_RQRD_IND';
	cst_academic_gown_size			VARCHAR2(30) := 'ACADEMIC_GOWN_SIZE';
	cst_academic_hat_size			VARCHAR2(30) := 'ACADEMIC_HAT_SIZE';
	cst_guest_tickets_requested		VARCHAR2(30) := 'GUEST_TICKETS_REQUESTED';
	cst_guest_tickets_allocated		VARCHAR2(30) := 'GUEST_TICKETS_ALLOCATED';
	cst_guest_seats				VARCHAR2(30) := 'GUEST_SEATS';
	cst_fees_paid_ind			VARCHAR2(30) := 'FEES_PAID_IND';
	cst_special_requirements		VARCHAR2(30) := 'SPECIAL_REQUIREMENTS';
	cst_comments				VARCHAR2(30) := 'COMMENTS';
	v_column_value				VARCHAR2(2000) := NULL;
	CURSOR	c_gach IS
	  SELECT  DECODE (p_column_name,
		  	cst_us_group_number,			TO_CHAR(gach.us_group_number),
			cst_order_in_presentation,		TO_CHAR(gach.order_in_presentation),
			cst_graduand_seat_number,		gach.graduand_seat_number,
			cst_name_pronunciation,			gach.name_pronunciation,
			cst_name_announced,			gach.name_announced,
			cst_academic_dress_rqrd_ind,		gach.academic_dress_rqrd_ind,
			cst_academic_gown_size,			gach.academic_gown_size,
			cst_academic_hat_size,			gach.academic_hat_size,
			cst_guest_tickets_requested,		TO_CHAR(gach.guest_tickets_requested),
			cst_guest_tickets_allocated,		TO_CHAR(gach.guest_tickets_allocated),
			cst_guest_seats,			gach.guest_seats,
			cst_fees_paid_ind,			gach.fees_paid_ind,
			cst_special_requirements,		gach.special_requirements,
			cst_comments,				gach.comments)
		FROM	IGS_GR_AWD_CRMN_HIST	gach
		WHERE	gach.person_id			= p_person_id AND
			gach.create_dt			= p_create_dt AND
			gach.grd_cal_type		= p_grd_cal_type AND
			gach.grd_ci_sequence_number	= p_grd_ci_sequence_number AND
			gach.ceremony_number		= p_ceremony_number AND
			gach.award_course_cd		= p_award_course_cd AND
			gach.award_crs_version_number	= p_award_crs_version_number AND
			gach.award_cd			= p_award_cd AND
			gach.hist_end_dt		>= p_hist_date AND
			DECODE (p_column_name,
				cst_us_group_number,			TO_CHAR(gach.us_group_number),
				cst_order_in_presentation,		TO_CHAR(gach.order_in_presentation),
				cst_graduand_seat_number,		gach.graduand_seat_number,
				cst_name_pronunciation,			gach.name_pronunciation,
				cst_name_announced,			gach.name_announced,
				cst_academic_dress_rqrd_ind,		gach.academic_dress_rqrd_ind,
				cst_academic_gown_size,			gach.academic_gown_size,
				cst_academic_hat_size,			gach.academic_hat_size,
				cst_guest_tickets_requested,		TO_CHAR(gach.guest_tickets_requested),
				cst_guest_tickets_allocated,		TO_CHAR(gach.guest_tickets_allocated),
				cst_guest_seats,			gach.guest_seats,
				cst_fees_paid_ind,			gach.fees_paid_ind,
				cst_special_requirements,		gach.special_requirements,
				cst_comments,				gach.comments) IS NOT NULL
		ORDER BY
			gach.hist_end_dt;
      BEGIN
	OPEN c_gach;
	FETCH c_gach INTO v_column_value;
	CLOSE c_gach;
	RETURN v_column_value;
      EXCEPTION
	WHEN OTHERS THEN
	  IF c_gach%ISOPEN THEN
	     CLOSE c_gach;
	  END IF;
	  RAISE;
      END;
END audp_get_gach_col;

FUNCTION Audp_Get_Grh_Col(
  p_person_id  IGS_GR_GRADUAND_HIST_ALL.person_id%TYPE ,
  p_create_dt  IGS_GR_GRADUAND_HIST_ALL.create_dt%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_dt  IGS_GR_GRADUAND_HIST_ALL.hist_start_dt%TYPE )
RETURN VARCHAR2 AS
BEGIN	-- audp_get_grh_col
	-- Get the oldest column value(after a given date) for a
	-- given p_person_id and p_create_dt.
   DECLARE
	cst_course_cd			CONSTANT VARCHAR2(30) := 'COURSE_CD';
	cst_award_course_cd		CONSTANT VARCHAR2(30) := 'AWARD_COURSE_CD';
	cst_award_crs_version_number	CONSTANT VARCHAR2(30) := 'AWARD_CRS_VERSION_NUMBER';
	cst_award_cd			CONSTANT VARCHAR2(30) := 'AWARD_CD';
--	cst_honours_level		CONSTANT VARCHAR2(30) := 'HONOURS_LEVEL';
--	cst_conferral_dt		CONSTANT VARCHAR2(30) := 'CONFERRAL_DT';
	cst_graduand_status		CONSTANT VARCHAR2(30) := 'GRADUAND_STATUS';
	cst_graduand_appr_status	CONSTANT VARCHAR2(30) := 'GRADUAND_APPR_STATUS';
	cst_s_graduand_type		CONSTANT VARCHAR2(30) := 'S_GRADUAND_TYPE';
	cst_proxy_award_ind		CONSTANT VARCHAR2(30) := 'PROXY_AWARD_IND';
	cst_proxy_award_person_id	CONSTANT VARCHAR2(30) := 'PROXY_AWARD_PERSON_ID';
	cst_previous_qualifications	CONSTANT VARCHAR2(30) := 'PREVIOUS_QUALIFICATIONS';
	cst_convocation_membership_ind	CONSTANT VARCHAR2(30) := 'CONVOCATION_MEMBERSHIP_IND';
	cst_sur_for_course_cd		CONSTANT VARCHAR2(30) := 'SUR_FOR_COURSE_CD';
	cst_sur_for_crs_version_number	CONSTANT VARCHAR2(30) := 'SUR_FOR_CRS_VERSION_NUMBER';
	cst_sur_for_award_cd		CONSTANT VARCHAR2(30) := 'SUR_FOR_AWARD_CD';
	cst_comments			CONSTANT VARCHAR2(30) := 'COMMENTS';
	v_column_value			VARCHAR2(2000) := NULL;
	CURSOR c_grh IS
	  SELECT DECODE (p_column_name,
		 	cst_course_cd,			grh.course_cd,
			cst_award_course_cd,		grh.award_course_cd,
			cst_award_crs_version_number,	TO_CHAR(grh.award_crs_version_number),
			cst_award_cd,			grh.award_cd,
--			cst_honours_level,		grh.HONOURS_LEVEL,
--			cst_conferral_dt,		IGS_GE_DATE.igscharDT(grh.conferral_dt),
			cst_graduand_status,		grh.GRADUAND_STATUS,
			cst_graduand_appr_status,	grh.GRADUAND_APPR_STATUS,
			cst_s_graduand_type,		grh.s_graduand_type,
			cst_proxy_award_ind,		grh.proxy_award_ind,
			cst_proxy_award_person_id,	TO_CHAR(grh.proxy_award_person_id),
			cst_previous_qualifications,	grh.previous_qualifications,
			cst_convocation_membership_ind,	grh.convocation_membership_ind,
			cst_sur_for_course_cd,		grh.sur_for_course_cd,
			cst_sur_for_crs_version_number,	TO_CHAR(grh.sur_for_crs_version_number),
			cst_sur_for_award_cd,		grh.sur_for_award_cd,
			cst_comments,			grh.comments)
	    FROM  IGS_GR_GRADUAND_HIST grh
   	    WHERE  grh.person_id		= p_person_id AND
		   grh.create_dt		= p_create_dt AND
		   grh.hist_start_dt	>= p_hist_dt AND
		   DECODE (p_column_name,
			cst_course_cd,			grh.course_cd,
			cst_award_course_cd,		grh.award_course_cd,
			cst_award_crs_version_number,	TO_CHAR(grh.award_crs_version_number),
			cst_award_cd,			grh.award_cd,
--			cst_honours_level,		grh.HONOURS_LEVEL,
--			cst_conferral_dt,		IGS_GE_DATE.igscharDT(grh.conferral_dt),
			cst_graduand_status,		grh.GRADUAND_STATUS,
			cst_graduand_appr_status,	grh.GRADUAND_APPR_STATUS,
			cst_s_graduand_type,		grh.s_graduand_type,
			cst_proxy_award_ind,		grh.proxy_award_ind,
			cst_proxy_award_person_id,	TO_CHAR(grh.proxy_award_person_id),
			cst_previous_qualifications,	grh.previous_qualifications,
			cst_convocation_membership_ind,	grh.convocation_membership_ind,
			cst_sur_for_course_cd,		grh.sur_for_course_cd,
			cst_sur_for_crs_version_number,	TO_CHAR(grh.sur_for_crs_version_number),
			cst_sur_for_award_cd,		grh.sur_for_award_cd,
			cst_comments,			grh.comments)IS NOT NULL
	     ORDER BY grh.hist_start_dt;
      BEGIN
	OPEN c_grh;
	FETCH c_grh INTO v_column_value;
	CLOSE c_grh;
	RETURN v_column_value;
      EXCEPTION
	WHEN OTHERS THEN
  	  IF c_grh%ISOPEN THEN
	     CLOSE c_grh;
	  END IF;
	  RAISE;
      END;
END audp_get_grh_col;




FUNCTION Audp_Get_Ih_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_institution_cd IN IGS_OR_INST_HIST_ALL.institution_cd%TYPE ,
  p_hist_end_dt IN IGS_OR_INST_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2 AS
/*
  ||  Created By : Sameer.Manglm@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel         13-MAR-2002     Bug No: 2224621
  ||                                  Removed the TO_CHAR for govt_institution_cd, since it is it is modified
  ||                                  to VARCHAR2 now.
  ||  pkpatel         25-OCT-2002    Bug No: 2613704
  ||                                 Replaced column inst_priority_code_id with inst_priority_cd
  ||  (reverse chronological order - newest change first)
*/
BEGIN	-- audp_get_ih_col
	-- get the oldest column value (after a given date) for a
	-- specified column and institution_cd for IGS_OR_INST_HIST table
   DECLARE
	    cst_name			VARCHAR2(4)  := 'NAME';
       -- added more columns as a fix for bug number 2251484
        cst_inst_phone_country_code     VARCHAR2(23) := 'INST_PHONE_COUNTRY_CODE';
        cst_inst_phone_area_code     	VARCHAR2(20) := 'INST_PHONE_AREA_CODE';
        cst_inst_phone_number     	VARCHAR2(17) := 'INST_PHONE_NUMBER';
        cst_inst_priority_cd        VARCHAR2(21) := 'INST_PRIORITY_CODE_CD';
	    cst_eps_code		        VARCHAR2(8) := 'EPS_CODE';
	    cst_institution_status		VARCHAR2(18) := 'INSTITUTION_STATUS';
	    cst_local_institution_ind	VARCHAR2(21) := 'LOCAL_INSTITUTION_IND';
	    cst_os_ind			VARCHAR2(6)  := 'OS_IND';
	    cst_govt_institution_cd		VARCHAR2(19) := 'GOVT_INSTITUTION_CD';
        cst_institution_type           VARCHAR2(16) := 'INSTITUTION_TYPE';
	    cst_description			VARCHAR2(11) := 'DESCRIPTION';
        cst_inst_control_type           VARCHAR2(17) := 'INST_CONTROL_TYPE';

	CURSOR c_ih IS
	  SELECT
	    DECODE (
	 	p_column_name,
		cst_name,			ih.name,

	        cst_inst_phone_country_code,     ih.inst_phone_country_code ,
        	cst_inst_phone_area_code,     	ih.inst_phone_area_code,
	        cst_inst_phone_number,     	ih.inst_phone_number ,
            cst_inst_priority_cd,      ih.inst_priority_cd ,
		    cst_eps_code,		        ih.eps_code,
		    cst_institution_status,		ih.INSTITUTION_STATUS,
		    cst_local_institution_ind,	ih.local_institution_ind,
		    cst_os_ind,			ih.os_ind,
		    cst_govt_institution_cd,	ih.GOVT_INSTITUTION_CD,
		    cst_institution_type,           ih.INSTITUTION_TYPE,
		    cst_description,		ih.description,
		    cst_inst_control_type,          ih.INST_CONTROL_TYPE )
	    FROM  IGS_OR_INST_HIST_ALL	ih
  	    WHERE ih.institution_cd	= p_institution_cd AND
		  ih.hist_start_dt	>= p_hist_end_dt AND
		  DECODE (
			p_column_name,
			cst_name,			ih.name,
		        cst_inst_phone_country_code,     ih.inst_phone_country_code ,
        		cst_inst_phone_area_code,     	ih.inst_phone_area_code,
		        cst_inst_phone_number,     	ih.inst_phone_number ,
                cst_inst_priority_cd,       ih.inst_priority_cd,
		  	    cst_eps_code,		        ih.eps_code,
			    cst_institution_status,		ih.INSTITUTION_STATUS,
			    cst_local_institution_ind,	ih.local_institution_ind,
			    cst_os_ind,			ih.os_ind,
			    cst_govt_institution_cd,	ih.GOVT_INSTITUTION_CD,
		        cst_institution_type,            ih.INSTITUTION_TYPE,
			    cst_description,		ih.description,
  		        cst_inst_control_type,           ih.INST_CONTROL_TYPE  ) IS NOT NULL
		  ORDER BY
		    ih.hist_start_dt;
 v_column_value 	VARCHAR2(2000) := NULL;


    BEGIN
    OPEN c_ih;
    FETCH c_ih INTO v_column_value;
    CLOSE c_ih;

    RETURN v_column_value;

    EXCEPTION
      WHEN OTHERS THEN
        IF c_ih%ISOPEN THEN
 	  CLOSE c_ih;
        END IF;
        RAISE;
    END;
END audp_get_ih_col;




FUNCTION Audp_Get_Ouh_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_org_unit_cd IN IGS_OR_UNIT_HIST_ALL.institution_cd%TYPE ,
  p_ou_start_dt IN IGS_OR_UNIT_HIST_ALL.ou_start_dt%TYPE ,
  p_hist_end_dt IN IGS_OR_UNIT_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2 AS
BEGIN	-- audp_get_ouh_col
	-- get the oldest column value (after a given date) for a
	-- specified column and institution_cd for IGS_OR_UNIT_HIST table
DECLARE
	cst_ou_end_dt			VARCHAR2(10) := 'OU_END_DT';
	cst_description			VARCHAR2(11) := 'DESCRIPTION';
	cst_org_status			VARCHAR2(10) := 'ORG_STATUS';
	cst_org_type			VARCHAR2(8)  := 'ORG_TYPE';
	cst_member_type			VARCHAR2(11) := 'MEMBER_TYPE';
	cst_INSTITUTION_CD		VARCHAR2(14) := 'INSTITUTION_CD';
	cst_name			VARCHAR2(4)  := 'NAME';
	CURSOR c_ouh IS
	  SELECT
	    DECODE (
		p_column_name,
		cst_ou_end_dt,		IGS_GE_DATE.igscharDT(ouh.ou_end_dt),
		cst_description,	ouh.description,
		cst_org_status,		ouh.ORG_STATUS,
		cst_org_type,		ouh.ORG_TYPE,
		cst_member_type,	ouh.MEMBER_TYPE,
		cst_INSTITUTION_CD,	ouh.institution_cd,
		cst_name,		ouh.NAME)
	   FROM	IGS_OR_UNIT_HIST	ouh
	   WHERE ouh.org_unit_cd	= p_org_unit_cd AND
		 ouh.ou_start_dt	= p_ou_start_dt AND
		 ouh.hist_start_dt	>= p_hist_end_dt AND
		 DECODE (
			p_column_name,
			cst_ou_end_dt,		IGS_GE_DATE.igscharDT(ouh.ou_end_dt),
			cst_description,	ouh.description,
			cst_org_status,		ouh.ORG_STATUS,
			cst_org_type,		ouh.ORG_TYPE,
			cst_member_type,	ouh.MEMBER_TYPE,
			cst_INSTITUTION_CD,	ouh.institution_cd,
			cst_name,		ouh.NAME) IS NOT NULL
	    ORDER BY    ouh.hist_start_dt;
	v_column_value		VARCHAR2(2000) := NULL;
   BEGIN
     OPEN c_ouh;
     FETCH c_ouh INTO v_column_value;
     CLOSE c_ouh;
     RETURN v_column_value;
   EXCEPTION
     WHEN OTHERS THEN
       IF c_ouh%ISOPEN THEN
 	 CLOSE c_ouh;
       END IF;
       RAISE;
  END;
END audp_get_ouh_col;


FUNCTION Audp_Get_Scah_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN IGS_AS_SC_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd IN IGS_AS_SC_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_hist_end_dt IN IGS_AS_SC_ATTEMPT_H_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2 AS
BEGIN    -- audp_get_scah_col
    -- get the oldest column value (after a given date) for the
    -- student course attempt history table
   DECLARE
    cst_version_number        CONSTANT VARCHAR2(30) := 'VERSION_NUMBER';
    cst_cal_type            CONSTANT VARCHAR2(30) := 'CAL_TYPE';
    cst_location_cd            CONSTANT VARCHAR2(30) := 'LOCATION_CD';
    cst_attendance_mode        CONSTANT VARCHAR2(30) := 'ATTENDANCE_MODE';
    cst_attendance_type        CONSTANT VARCHAR2(30) := 'ATTENDANCE_TYPE';
    cst_student_confirmed_ind    CONSTANT VARCHAR2(30) := 'STUDENT_CONFIRMED_IND';
    cst_commencement_dt        CONSTANT VARCHAR2(30) := 'COMMENCEMENT_DT';
    cst_course_attempt_status    CONSTANT VARCHAR2(30) := 'COURSE_ATTEMPT_STATUS';
    cst_progression_status        CONSTANT VARCHAR2(30) := 'PROGRESSION_STATUS';
    cst_derived_att_type        CONSTANT VARCHAR2(30) := 'DERIVED_ATT_TYPE';
    cst_derived_att_mode        CONSTANT VARCHAR2(30) := 'DERIVED_ATT_MODE';
    cst_provisional_ind        CONSTANT VARCHAR2(30) := 'PROVISIONAL_IND';
    cst_discontinued_dt        CONSTANT VARCHAR2(30) := 'DISCONTINUED_DT';
    cst_discontinuation_reason_cd    CONSTANT VARCHAR2(30) := 'DISCONTINUATION_REASON_CD';
    cst_funding_source        CONSTANT VARCHAR2(30) := 'FUNDING_SOURCE';
    cst_fs_description        CONSTANT VARCHAR2(30) := 'FS_DESCRIPTION';
    cst_exam_location_cd        CONSTANT VARCHAR2(30) := 'EXAM_LOCATION_CD';
    cst_elo_description        CONSTANT VARCHAR2(30) := 'ELO_DESCRIPTION';
    cst_derived_completion_yr    CONSTANT VARCHAR2(30) := 'DERIVED_COMPLETION_YR';
    cst_derived_completion_perd    CONSTANT VARCHAR2(30) := 'DERIVED_COMPLETION_PERD';
    cst_nominated_completion_yr    CONSTANT VARCHAR2(30) := 'NOMINATED_COMPLETION_YR';
    cst_nominated_completion_perd    CONSTANT VARCHAR2(30) := 'NOMINATED_COMPLETION_PERD';
    cst_rule_check_ind        CONSTANT VARCHAR2(30) := 'RULE_CHECK_IND';
    cst_waive_option_check_ind    CONSTANT VARCHAR2(30) := 'WAIVE_OPTION_CHECK_IND';
    cst_last_rule_check_dt        CONSTANT VARCHAR2(30) := 'LAST_RULE_CHECK_DT';
    cst_publish_outcomes_ind    CONSTANT VARCHAR2(30) := 'PUBLISH_OUTCOMES_IND';
    cst_course_rqrmnt_complete_ind    CONSTANT VARCHAR2(30) := 'COURSE_RQRMNT_COMPLETE_IND';
    cst_course_rqrmnts_complete_dt    CONSTANT VARCHAR2(30) := 'COURSE_RQRMNTS_COMPLETE_DT';
    cst_s_completed_source_type    CONSTANT VARCHAR2(30) := 'S_COMPLETED_SOURCE_TYPE';
    cst_override_time_limitation    CONSTANT VARCHAR2(30) := 'OVERRIDE_TIME_LIMITATION';
    cst_advanced_standing_ind    CONSTANT VARCHAR2(30) := 'ADVANCED_STANDING_IND';
    cst_fee_cat            CONSTANT VARCHAR2(30) := 'FEE_CAT';
    cst_fc_description        CONSTANT VARCHAR2(30) := 'FC_DESCRIPTION';
    cst_correspondence_cat        CONSTANT VARCHAR2(30) := 'CORRESPONDENCE_CAT';
    cst_cc_description        CONSTANT VARCHAR2(30) := 'CC_DESCRIPTION';
    cst_self_help_group_ind        CONSTANT VARCHAR2(30) := 'SELF_HELP_GROUP_IND';
    cst_lapsed_dt            CONSTANT VARCHAR2(30) := 'LAPSED_DT';
    cst_adm_admission_appl_number    CONSTANT VARCHAR2(30) := 'ADM_ADMISSION_APPL_NUMBER';
    cst_adm_nominated_course_cd    CONSTANT VARCHAR2(30) := 'ADM_NOMINATED_COURSE_CD';
    cst_adm_sequence_number        CONSTANT VARCHAR2(30) := 'ADM_SEQUENCE_NUMBER';
    cst_last_date_of_attendance        CONSTANT VARCHAR2(30) := 'LAST_DATE_OF_ATTENDANCE';
    cst_dropped_by             CONSTANT VARCHAR2(30) := 'DROPPED_BY';
    cst_key_program         CONSTANT VARCHAR2(30) := 'KEY_PROGRAM';
    cst_primary_program_type    CONSTANT VARCHAR2(30) := 'PRIMARY_PROGRAM_TYPE';
    cst_primary_prog_type_source    CONSTANT VARCHAR2(30) := 'PRIMARY_PROG_TYPE_SOURCE';
    cst_catalog_cal_type        CONSTANT VARCHAR2(30) := 'CATALOG_CAL_TYPE';
    cst_catalog_seq_num        CONSTANT VARCHAR2(30) := 'CATALOG_SEQ_NUM';
    cst_manual_ovr_cmpl_dt_ind    CONSTANT VARCHAR2(30) := 'MANUAL_OVR_CMPL_DT_IND';
    cst_override_cmpl_dt        CONSTANT VARCHAR2(30) := 'OVERRIDE_CMPL_DT';
    cst_coo_id        CONSTANT VARCHAR2(30) := 'COO_ID';
    cst_IGS_PR_CLASS_STD_ID        CONSTANT VARCHAR2(30) := 'IGS_PR_CLASS_STD_ID';

    CURSOR    c_scah IS
      SELECT DECODE (p_column_name,
            cst_version_number,        TO_CHAR(scah.version_number),
            cst_cal_type,            scah.CAL_TYPE,
            cst_location_cd,        scah.location_cd,
            cst_attendance_mode,        scah.ATTENDANCE_MODE,
            cst_attendance_type,        scah.ATTENDANCE_TYPE,
            cst_student_confirmed_ind,    scah.student_confirmed_ind,
            cst_commencement_dt,        IGS_GE_DATE.igscharDT(scah.commencement_dt),
            cst_course_attempt_status,    scah.course_attempt_status,
            cst_progression_status,        scah.progression_status,
            cst_derived_att_type,        scah.derived_att_type,
            cst_derived_att_mode,        scah.derived_att_mode,
            cst_provisional_ind,        scah.provisional_ind,
            cst_discontinued_dt,        IGS_GE_DATE.igscharDT(scah.discontinued_dt),
            cst_discontinuation_reason_cd,    scah.DISCONTINUATION_REASON_CD,
            cst_funding_source,        scah.FUNDING_SOURCE,
            cst_fs_description,        scah.fs_description,
            cst_exam_location_cd,        scah.exam_location_cd,
            cst_elo_description,        scah.elo_description,
            cst_derived_completion_yr,    TO_CHAR(scah.derived_completion_yr),
            cst_derived_completion_perd,    scah.derived_completion_perd,
            cst_nominated_completion_yr,    TO_CHAR(scah.nominated_completion_yr),
            cst_nominated_completion_perd,    scah.nominated_completion_perd,
            cst_rule_check_ind,        scah.rule_check_ind,
            cst_waive_option_check_ind,    scah.waive_option_check_ind,
            cst_last_rule_check_dt,        IGS_GE_DATE.igscharDT(scah.last_rule_check_dt),
            cst_publish_outcomes_ind,    scah.publish_outcomes_ind,
            cst_course_rqrmnt_complete_ind,    scah.course_rqrmnt_complete_ind,
            cst_course_rqrmnts_complete_dt,    IGS_GE_DATE.igscharDT(scah.course_rqrmnts_complete_dt),
            cst_s_completed_source_type,    scah.s_completed_source_type,
            cst_override_time_limitation,    TO_CHAR(scah.override_time_limitation),
            cst_advanced_standing_ind,    scah.advanced_standing_ind,
            cst_fee_cat,            scah.FEE_CAT,
            cst_fc_description,        scah.fc_description,
            cst_correspondence_cat,        scah.CORRESPONDENCE_CAT,
            cst_cc_description,        scah.cc_description,
            cst_self_help_group_ind,    scah.self_help_group_ind,
            cst_lapsed_dt,            IGS_GE_DATE.igscharDT(scah.lapsed_dt),
            cst_adm_admission_appl_number,    TO_CHAR(scah.adm_admission_appl_number),
            cst_adm_nominated_course_cd,    scah.adm_nominated_course_cd,
            cst_adm_sequence_number,    TO_CHAR(scah.adm_sequence_number),
            cst_last_date_of_attendance,     IGS_GE_DATE.igscharDT(scah.last_date_of_attendance),
            cst_dropped_by,         scah.dropped_by,
            cst_key_program,         scah.key_program,
                    cst_primary_program_type,    scah.primary_program_type,
                    cst_primary_prog_type_source,    scah.primary_prog_type_source,
                    cst_catalog_cal_type,        scah.catalog_cal_type,
                    cst_catalog_seq_num,        TO_CHAR(scah.catalog_seq_num),
            cst_manual_ovr_cmpl_dt_ind,    scah.manual_ovr_cmpl_dt_ind ,
            cst_override_cmpl_dt,        IGS_GE_DATE.igscharDT(scah.override_cmpl_dt),
            cst_coo_id, TO_CHAR(scah.coo_id),
      cst_IGS_PR_CLASS_STD_ID, TO_CHAR(scah.IGS_PR_CLASS_STD_ID)
            )
        FROM   IGS_AS_SC_ATTEMPT_H    scah
        WHERE    scah.person_id        = p_person_id AND
            scah.course_cd        = p_course_cd AND
            scah.hist_start_dt    >= p_hist_end_dt AND
            DECODE (p_column_name,
                cst_version_number,        TO_CHAR(scah.version_number),
                cst_cal_type,            scah.CAL_TYPE,
                cst_location_cd,        scah.location_cd,
                cst_attendance_mode,        scah.ATTENDANCE_MODE,
                cst_attendance_type,        scah.ATTENDANCE_TYPE,
                cst_student_confirmed_ind,    scah.student_confirmed_ind,
                cst_commencement_dt,        IGS_GE_DATE.igscharDT(scah.commencement_dt),
                cst_course_attempt_status,    scah.course_attempt_status,
                cst_progression_status,        scah.progression_status,
                cst_derived_att_type,        scah.derived_att_type,
                cst_derived_att_mode,        scah.derived_att_mode,
                cst_provisional_ind,        scah.provisional_ind,
                cst_discontinued_dt,        IGS_GE_DATE.igscharDT(scah.discontinued_dt),
                cst_discontinuation_reason_cd,    scah.DISCONTINUATION_REASON_CD,
                cst_funding_source,        scah.FUNDING_SOURCE,
                cst_fs_description,        scah.fs_description,
                cst_exam_location_cd,        scah.exam_location_cd,
                cst_elo_description,        scah.elo_description,
                cst_derived_completion_yr,    TO_CHAR(scah.derived_completion_yr),
                cst_derived_completion_perd,    scah.derived_completion_perd,
                cst_nominated_completion_yr,    TO_CHAR(scah.nominated_completion_yr),
                cst_nominated_completion_perd,    scah.nominated_completion_perd,
                cst_rule_check_ind,        scah.rule_check_ind,
                cst_waive_option_check_ind,    scah.waive_option_check_ind,
                cst_last_rule_check_dt,        IGS_GE_DATE.igscharDT(scah.last_rule_check_dt),
                cst_publish_outcomes_ind,    scah.publish_outcomes_ind,
                cst_course_rqrmnt_complete_ind,    scah.course_rqrmnt_complete_ind,
                cst_course_rqrmnts_complete_dt,    IGS_GE_DATE.igscharDT(scah.course_rqrmnts_complete_dt),
                cst_s_completed_source_type,    scah.s_completed_source_type,
                cst_override_time_limitation,    TO_CHAR(scah.override_time_limitation),
                cst_advanced_standing_ind,    scah.advanced_standing_ind,
                cst_fee_cat,            scah.FEE_CAT,
                cst_fc_description,        scah.fc_description,
                cst_correspondence_cat,        scah.CORRESPONDENCE_CAT,
                cst_cc_description,        scah.cc_description,
                cst_self_help_group_ind,    scah.self_help_group_ind,
                cst_lapsed_dt,            IGS_GE_DATE.igscharDT(scah.lapsed_dt),
                cst_adm_admission_appl_number,    TO_CHAR(scah.adm_admission_appl_number),
                cst_adm_nominated_course_cd,    scah.adm_nominated_course_cd,
                cst_adm_sequence_number,    TO_CHAR(scah.adm_sequence_number),
                cst_last_date_of_attendance,     IGS_GE_DATE.igscharDT(scah.last_date_of_attendance),
                cst_dropped_by,         scah.dropped_by  ,
                cst_key_program ,        scah.key_program,
                            cst_primary_program_type,    scah.primary_program_type,
                            cst_primary_prog_type_source,    scah.primary_prog_type_source,
                            cst_catalog_cal_type,        scah.catalog_cal_type,
                            cst_catalog_seq_num,        TO_CHAR(scah.catalog_seq_num),
                cst_manual_ovr_cmpl_dt_ind,    scah.manual_ovr_cmpl_dt_ind,
                cst_override_cmpl_dt,        IGS_GE_DATE.igscharDT(scah.override_cmpl_dt),
                cst_coo_id, TO_CHAR(scah.coo_id),
                cst_IGS_PR_CLASS_STD_ID, TO_CHAR(scah.IGS_PR_CLASS_STD_ID)
                ) IS NOT NULL
        ORDER BY scah.hist_start_dt;
    v_column_value        VARCHAR2(2000) := NULL;
   BEGIN
     OPEN c_scah;
     FETCH c_scah INTO v_column_value;
     CLOSE c_scah;
     RETURN v_column_value;
   EXCEPTION
     WHEN OTHERS THEN
       IF c_scah%ISOPEN THEN
       CLOSE c_scah;
       END IF;
       RAISE;
   END;
END audp_get_scah_col;


  -- adding a new function Enrp_Get_Sph_col in the enrollment processes
  -- build of nov 2001 release.

FUNCTION Enrp_Get_Sph_col (
  p_column_name IN VARCHAR2,
  p_spl_perm_request_h_id IN NUMBER,
  p_hist_end_dt IN DATE )
RETURN VARCHAR2 AS
BEGIN
  DECLARE
      cst_date_submission 	  CONSTANT  VARCHAR2(20) := 'DATE_SUBMISSION';
      cst_audit_the_course	  CONSTANT  VARCHAR2(20) := 'AUDIT_THE_COURSE';
      cst_approval_status 	  CONSTANT  VARCHAR2(20) := 'APPROVAL_STATUS';
      cst_reason_for_request	  CONSTANT  VARCHAR2(20) := 'REASON_FOR_REQUEST';
      cst_instructor_more_info    CONSTANT  VARCHAR2(25) := 'INSTRUCTOR_MORE_INFO';
      cst_instructor_deny_info    CONSTANT  VARCHAR2(25) := 'INSTRUCTOR_DENY_INFO';
      cst_student_more_info	  CONSTANT  VARCHAR2(25) := 'STUDENT_MORE_INFO';
      cst_transaction_type	  CONSTANT  VARCHAR2(20) := 'TRANSACTION_TYPE';

      CURSOR c_sph IS
        SELECT
   	  DECODE (
	   	  p_column_name,
		  cst_date_submission,  	IGS_GE_DATE.igscharDT(sph.date_submission),
		  cst_reason_for_request, 	sph.reason_for_request,
		  cst_instructor_more_info, 	sph.instructor_more_info,
		  cst_instructor_deny_info, 	sph.instructor_deny_info,
		  cst_student_more_info,	sph.student_more_info,
		  cst_approval_status, 		sph.approval_status,
		  cst_audit_the_course,	 	sph.audit_the_course,
		  cst_transaction_type, 	sph.transaction_type
		  )
	FROM IGS_EN_SPL_PERM_H sph
	WHERE 	sph.spl_perm_request_h_id = p_spl_perm_request_h_id AND
		sph.hist_start_dt	 >= p_hist_end_dt AND
	  DECODE (
		  p_column_name,
	  	  cst_date_submission, 		IGS_GE_DATE.igscharDT(sph.date_submission),
		  cst_reason_for_request, 	sph.reason_for_request,
		  cst_instructor_more_info,  	sph.instructor_more_info,
		  cst_instructor_deny_info,  	sph.instructor_deny_info,
		  cst_student_more_info,	sph.student_more_info,
		  cst_approval_status, 		sph.approval_status,
		  cst_audit_the_course, 	sph.audit_the_course,
		  cst_transaction_type,		sph.transaction_type
		  ) IS NOT NULL
	 ORDER BY sph.hist_start_dt;

      v_column_value  VARCHAR2(4000) := NULL;

      BEGIN
 	OPEN c_sph;
	FETCH c_sph INTO v_column_value;
	CLOSE c_sph;
	RETURN v_column_value;
      EXCEPTION
	WHEN OTHERS THEN
	IF c_sph%ISOPEN THEN
	   CLOSE c_sph;
	END IF;
	RAISE;
     END;
  END Enrp_Get_Sph_col;


FUNCTION Audp_Get_Suah_Col(
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_person_id  IGS_EN_SU_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd  IGS_EN_SU_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_hist_end_dt  IGS_EN_SU_ATTEMPT_H_ALL.hist_end_dt%TYPE ,
  p_uoo_id  IGS_EN_SU_ATTEMPT_H_ALL.uoo_id%TYPE)
RETURN VARCHAR2 AS
--
-- Who         When            What
-- knaraset  29-Apr-03   added p_uoo_id as parameter used the same in cursor c_suah,also removed the other parameter unit_cd,cal_type and sequence_number
--                        as part of MUS build bug 2829262
----rvangala   01-OCT-2003      Added variable cst_core_indicator and modified cursor c_suah to function
--			      Audp_Get_Suah_Col, Enh Bug# 3052432
	gv_other_detail  VARCHAR2(255);
BEGIN
  DECLARE
	cst_version_number		CONSTANT VARCHAR2(30) := 'VERSION_NUMBER';
	cst_location_cd			CONSTANT VARCHAR2(30) := 'LOCATION_CD';
	cst_unit_class			CONSTANT VARCHAR2(30) := 'UNIT_CLASS';
	cst_enrolled_dt			CONSTANT VARCHAR2(30) := 'ENROLLED_DT';
	cst_unit_attempt_status		CONSTANT VARCHAR2(30) := 'UNIT_ATTEMPT_STATUS';
	cst_administrative_unit_status	CONSTANT VARCHAR2(30) := 'ADMINISTRATIVE_UNIT_STATUS';
	cst_aus_description		CONSTANT VARCHAR2(30) := 'AUS_DESCRIPTION';
	cst_discontinued_dt		CONSTANT VARCHAR2(30) := 'DISCONTINUED_DT';
	cst_rule_waived_dt		CONSTANT VARCHAR2(30) := 'RULE_WAIVED_DT';
	cst_rule_waived_person_id	CONSTANT VARCHAR2(30) := 'RULE_WAIVED_PERSON_ID';
	cst_no_assessment_ind		CONSTANT VARCHAR2(30) := 'NO_ASSESSMENT_IND';
	cst_exam_location_cd		CONSTANT VARCHAR2(30) := 'EXAM_LOCATION_CD';
	cst_elo_description		CONSTANT VARCHAR2(30) := 'ELO_DESCRIPTION';
	cst_sup_unit_cd			CONSTANT VARCHAR2(30) := 'SUP_UNIT_CD';
	cst_sup_version_number		CONSTANT VARCHAR2(30) := 'SUP_VERSION_NUMBER';
	cst_alternative_title		CONSTANT VARCHAR2(30) := 'ALTERNATIVE_TITLE';
	cst_override_enrolled_cp	CONSTANT VARCHAR2(30) := 'OVERRIDE_ENROLLED_CP';
	cst_override_eftsu		CONSTANT VARCHAR2(30) := 'OVERRIDE_EFTSU';
	cst_override_achievable_cp	CONSTANT VARCHAR2(30) := 'OVERRIDE_ACHIEVABLE_CP';
	cst_override_outcome_due_dt 	CONSTANT VARCHAR2(30) := 'OVERRIDE_OUTCOME_DUE_DT';
	cst_override_credit_reason	CONSTANT VARCHAR2(30) := 'OVERRIDE_CREDIT_REASON';
	cst_enr_method_type 		CONSTANT VARCHAR2(30) := 'ENR_METHOD_TYPE';
	cst_grading_schema_code  	CONSTANT VARCHAR2(30) := 'GRADING_SCHEMA_CODE';
	--added by rvangala 01-OCT-2003. Enh Bug# 3052432
	cst_core_indicator              CONSTANT VARCHAR2(30) := 'CORE_INDICATOR';

	CURSOR c_suah IS
		SELECT DECODE (p_column_name,
			cst_version_number, 	 	 TO_CHAR(suah.version_number),
			cst_location_cd,  	 	 suah.location_cd,
			cst_unit_class,   		 suah.UNIT_CLASS,
			cst_enrolled_dt,  	 	 IGS_GE_DATE.igscharDT(suah.enrolled_dt),
			cst_unit_attempt_status,	 suah.unit_attempt_status,
			cst_administrative_unit_status,  suah.ADMINISTRATIVE_UNIT_STATUS,
			cst_aus_description,  		 suah.aus_description,
			cst_discontinued_dt,    	 IGS_GE_DATE.igscharDT(suah.discontinued_dt),
			cst_rule_waived_dt,   		 IGS_GE_DATE.igscharDT(suah.rule_waived_dt),
			cst_rule_waived_person_id, 	 TO_CHAR(suah.rule_waived_person_id),
			cst_no_assessment_ind,   	 suah.no_assessment_ind,
			cst_exam_location_cd,   	 suah.exam_location_cd,
			cst_elo_description, 		 suah.elo_description,
			cst_sup_unit_cd,  		 suah.sup_unit_cd,
			cst_sup_version_number, 	 TO_CHAR(suah.sup_version_number),
			cst_alternative_title,   	 suah.alternative_title,
			cst_override_enrolled_cp, 	 TO_CHAR(suah.override_enrolled_cp),
			cst_override_eftsu,   		 TO_CHAR(suah.override_eftsu),
			cst_override_achievable_cp,  	 TO_CHAR(suah.override_achievable_cp),
			cst_override_outcome_due_dt,   	 IGS_GE_DATE.igscharDT(suah.override_outcome_due_dt),
			cst_override_credit_reason, 	 suah.override_credit_reason,
			cst_grading_schema_code, 	 suah.grading_schema_code,
			cst_enr_method_type,		 suah.enr_method_type,
			--added by rvangala 01-OCT-2003. Enh Bug# 3052432
			cst_core_indicator,              suah.core_indicator_code)
		FROM	IGS_EN_SU_ATTEMPT_H suah
		WHERE	suah.person_id	= p_person_id AND
			suah.course_cd	= p_course_cd AND
			suah.uoo_id	= p_uoo_id AND
			suah.hist_start_dt >= p_hist_end_dt AND
			DECODE (p_column_name,
				cst_version_number, 		 TO_CHAR(suah.version_number),
				cst_location_cd,  		 suah.location_cd,
				cst_unit_class,   		 suah.UNIT_CLASS,
				cst_enrolled_dt,   		 TO_CHAR(suah.enrolled_dt),
				cst_unit_attempt_status,	 suah.unit_attempt_status,
				cst_administrative_unit_status,  suah.ADMINISTRATIVE_UNIT_STATUS,
				cst_aus_description, 		 suah.aus_description,
				cst_discontinued_dt,  		 TO_CHAR(suah.discontinued_dt),
				cst_rule_waived_dt,  		 TO_CHAR(suah.rule_waived_dt),
				cst_rule_waived_person_id, 	 TO_CHAR(suah.rule_waived_person_id),
				cst_no_assessment_ind, 		 suah.no_assessment_ind,
				cst_exam_location_cd, 		 suah.exam_location_cd,
				cst_elo_description,  		 suah.elo_description,
				cst_sup_unit_cd, 		 suah.sup_unit_cd,
				cst_sup_version_number,		 TO_CHAR(suah.sup_version_number),
				cst_alternative_title,  	 suah.alternative_title,
				cst_override_enrolled_cp, 	 TO_CHAR(suah.override_enrolled_cp),
				cst_override_eftsu,   		 TO_CHAR(suah.override_eftsu),
				cst_override_achievable_cp,  	 TO_CHAR(suah.override_achievable_cp),
				cst_override_outcome_due_dt, 	 TO_CHAR(suah.override_outcome_due_dt),
				cst_override_credit_reason,	 suah.override_credit_reason,
				cst_grading_schema_code, 	 suah.grading_schema_code,
				cst_enr_method_type, 		 suah.enr_method_type,
				--added by rvangala 01-OCT-2003. Enh Bug# 3052432
				cst_core_indicator,              suah.core_indicator_code) IS NOT NULL
	ORDER BY
		suah.hist_start_dt ;
	v_column_value   VARCHAR2(2000);
     BEGIN	-- audp_get_suah_col
	OPEN c_suah;
	FETCH c_suah INTO v_column_value;
	CLOSE c_suah;
	RETURN v_column_value;
     EXCEPTION
	WHEN OTHERS THEN
	  IF (c_suah%ISOPEN) THEN
	     CLOSE c_suah;
	  END IF;
	RAISE;
    END;
END audp_get_suah_col;


FUNCTION Audp_Get_Suaoh_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_outcome_dt IN DATE ,
  p_hist_end_dt IN DATE,
  p_uoo_id IN NUMBER)
RETURN VARCHAR2 AS
BEGIN	-- audp_get_suaoh_col
	-- get the oldest column value (after a given date) for a
	-- specified column, person_id, course_cd, unit_cd, CAL_TYPE
	-- ci_sequence_number and for table IGS_AS_SU_ATMPTOUT_H
   DECLARE
	cst_grading_schema_cd			VARCHAR2(17) := 'GRADING_SCHEMA_CD';
	cst_version_number			VARCHAR2(14) := 'VERSION_NUMBER';
	cst_grade				VARCHAR2(5)  := 'GRADE';
	cst_s_grade_creatn_method_type		VARCHAR2(28) := 'S_GRADE_CREATION_METHOD_TYPE';
	cst_finalised_outcome_ind		VARCHAR2(21) := 'FINALISED_OUTCOME_IND';
	cst_mark				VARCHAR2(4)  := 'MARK';
	cst_number_times_keyed			VARCHAR2(18) := 'NUMBER_TIMES_KEYED';
	cst_trnslted_grading_schema_cd		VARCHAR2(28) := 'TRANSLATED_GRADING_SCHEMA_CD';
	cst_translated_version_no    		VARCHAR2(25) := 'TRANSLATED_VERSION_NUMBER';
	cst_translated_grade			VARCHAR2(16) := 'TRANSLATED_GRADE';
	cst_translated_dt			VARCHAR2(13) := 'TRANSLATED_DT';
	CURSOR c_suaoh IS
	   SELECT
		DECODE (
			p_column_name,
			cst_grading_schema_cd,		suaoh.grading_schema_cd,
			cst_version_number,		TO_CHAR(suaoh.version_number),
			cst_grade,			suaoh.grade,
			cst_s_grade_creatn_method_type,	suaoh.s_grade_creation_method_type,
			cst_finalised_outcome_ind,	suaoh.finalised_outcome_ind,
			cst_mark,			TO_CHAR(suaoh.mark),
			cst_number_times_keyed,		TO_CHAR(suaoh.number_times_keyed),
			cst_trnslted_grading_schema_cd,	suaoh.translated_grading_schema_cd,
			cst_translated_version_no,	TO_CHAR(suaoh.translated_version_number),
			cst_translated_grade,		suaoh.translated_grade,
			cst_translated_dt,		TO_CHAR(suaoh.translated_dt))
	    FROM	IGS_AS_SU_ATMPTOUT_H	suaoh
	    WHERE	suaoh.person_id		 = p_person_id AND
			suaoh.course_cd		 = p_course_cd AND
			suaoh.uoo_id		 = p_uoo_id AND
			suaoh.outcome_dt 	 = p_outcome_dt AND
			suaoh.hist_start_dt	>= p_hist_end_dt AND
			DECODE (
				p_column_name,
				cst_grading_schema_cd,		suaoh.grading_schema_cd,
				cst_version_number,		TO_CHAR(suaoh.version_number),
				cst_grade,			suaoh.grade,
				cst_s_grade_creatn_method_type,	suaoh.s_grade_creation_method_type,
				cst_finalised_outcome_ind,	suaoh.finalised_outcome_ind,
				cst_mark,			TO_CHAR(suaoh.mark),
				cst_number_times_keyed,		TO_CHAR(suaoh.number_times_keyed),
				cst_trnslted_grading_schema_cd,	suaoh.translated_grading_schema_cd,
				cst_translated_version_no,	TO_CHAR(suaoh.translated_version_number),
				cst_translated_grade,		suaoh.translated_grade,
				cst_translated_dt,		TO_CHAR(suaoh.translated_dt)) IS NOT NULL
		ORDER BY	suaoh.hist_start_dt;
	v_column_value		VARCHAR2(2000) := NULL;
   BEGIN
	OPEN c_suaoh;
	FETCH c_suaoh INTO v_column_value;
	CLOSE c_suaoh;
	RETURN v_column_value;
   EXCEPTION
     WHEN OTHERS THEN
     IF c_suaoh%ISOPEN THEN
          CLOSE c_suaoh;
        END IF;
     RAISE;
   END;
END audp_get_suaoh_col;


FUNCTION Audp_Get_Susah_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_hist_end_dt IN DATE )
RETURN VARCHAR2 AS
BEGIN	-- audp_get_susah_col
	-- get the oldest column value (after a given date) for a
	-- specified column, person_id, course_cd, unit_set_cd, sequence_number
	-- for IGS_AS_SU_SETATMPT_H table
   DECLARE
	cst_us_version_number		VARCHAR2(17) := 'US_VERSION_NUMBER';
	cst_selection_dt		VARCHAR2(12) := 'SELECTION_DT';
	cst_student_confirmed_ind	VARCHAR2(21) := 'STUDENT_CONFIRMED_IND';
	cst_end_dt			VARCHAR2(6)  := 'END_DT';
	cst_parent_unit_set_cd		VARCHAR2(18) := 'PARENT_UNIT_SET_CD';
	cst_parent_sequence_number	VARCHAR2(22) := 'PARENT_SEQUENCE_NUMBER';
	cst_primary_set_ind		VARCHAR2(15) := 'PRIMARY_SET_IND';
	cst_voluntary_end_ind		VARCHAR2(17) := 'VOLUNTARY_END_IND';
	cst_authorised_person_id	VARCHAR2(20) := 'AUTHORISED_PERSON_ID';
	cst_authorised_on		VARCHAR2(13) := 'AUTHORISED_ON';
	cst_override_title		VARCHAR2(14) := 'OVERRIDE_TITLE';
	cst_rqrmnts_complete_ind	VARCHAR2(20) := 'RQRMNTS_COMPLETE_IND';
	cst_rqrmnts_complete_dt 	VARCHAR2(19) := 'RQRMNTS_COMPLETE_DT';
	cst_s_completed_source_type   	VARCHAR2(23) := 'S_COMPLETED_SOURCE_TYPE';
	cst_catalog_cal_type    	VARCHAR2(16) := 'CATALOG_CAL_TYPE';
	cst_catalog_seq_num       	VARCHAR2(15) := 'CATALOG_SEQ_NUM';
	CURSOR c_susah IS
	  SELECT
	 	DECODE (
			p_column_name,
			cst_us_version_number, 		TO_CHAR(susah.us_version_number),
			cst_selection_dt,		IGS_GE_DATE.igscharDT(susah.selection_dt),
			cst_student_confirmed_ind,	susah.student_confirmed_ind,
			cst_end_dt,			IGS_GE_DATE.igscharDT(susah.end_dt),
			cst_parent_unit_set_cd,		susah.parent_unit_set_cd,
			cst_parent_sequence_number,	TO_CHAR(susah.parent_sequence_number),
			cst_primary_set_ind, 		susah.primary_set_ind,
			cst_voluntary_end_ind,		susah.voluntary_end_ind,
			cst_authorised_person_id,	TO_CHAR(susah.authorised_person_id),
			cst_authorised_on,		TO_CHAR(susah.authorised_on),
			cst_override_title,		susah.override_title,
			cst_rqrmnts_complete_ind,	susah.rqrmnts_complete_ind,
			cst_rqrmnts_complete_dt,	IGS_GE_DATE.igscharDT(susah.rqrmnts_complete_dt),
			cst_s_completed_source_type,	susah.s_completed_source_type,
			cst_catalog_cal_type,           susah.catalog_cal_type ,
			cst_catalog_seq_num,            TO_CHAR(susah.catalog_seq_num) )
		FROM	IGS_AS_SU_SETATMPT_H 	susah
		WHERE	susah.person_id		= p_person_id AND
			susah.course_cd		= p_course_cd AND
			susah.unit_set_cd	= p_unit_set_cd AND
			susah.sequence_number	= p_sequence_number AND
			susah.hist_start_dt    >= p_hist_end_dt AND
			DECODE (
				p_column_name,
				cst_us_version_number, 		TO_CHAR(susah.us_version_number),
				cst_selection_dt,		IGS_GE_DATE.igscharDT(susah.selection_dt),
				cst_student_confirmed_ind,	susah.student_confirmed_ind,
				cst_end_dt,			IGS_GE_DATE.igscharDT(susah.end_dt),
				cst_parent_unit_set_cd,		susah.parent_unit_set_cd,
				cst_parent_sequence_number,	TO_CHAR(susah.parent_sequence_number),
				cst_primary_set_ind, 		susah.primary_set_ind,
				cst_voluntary_end_ind,		susah.voluntary_end_ind,
				cst_authorised_person_id,	TO_CHAR(susah.authorised_person_id),
				cst_authorised_on,		IGS_GE_DATE.igscharDT(susah.authorised_on),
				cst_override_title,		susah.override_title,
				cst_rqrmnts_complete_ind,	susah.rqrmnts_complete_ind,
				cst_rqrmnts_complete_dt,	IGS_GE_DATE.igscharDT(susah.rqrmnts_complete_dt),
				cst_s_completed_source_type,	susah.s_completed_source_type,
				cst_catalog_cal_type,           susah.catalog_cal_type ,
			        cst_catalog_seq_num,            TO_CHAR(susah.catalog_seq_num) ) IS NOT NULL
		ORDER BY	susah.hist_start_dt;
	v_column_value		VARCHAR2(2000) := NULL;
   BEGIN
     OPEN c_susah;
     FETCH c_susah INTO v_column_value;
     CLOSE c_susah;
     RETURN v_column_value;
   EXCEPTION
     WHEN OTHERS THEN
     IF c_susah%ISOPEN THEN
        CLOSE c_susah;
     END IF;
     RAISE;
   END;
END audp_get_susah_col;

FUNCTION ENRP_RET_WAIVE_PERSON_ID(
P_H_RULE_WAIVED_PERSON_ID IN NUMBER,
P_person_id IN NUMBER,
P_course_cd IN VARCHAR2,
P_hist_end_dt IN DATE,
p_uoo_id IN IGS_EN_SU_ATTEMPT_H_ALL.uoo_id%TYPE
)
RETURN NUMBER IS
----------------------------------------------
-- This Function returns Rule_waived_person_id
-- Which will be used in WHERE clause of IGS_AS_SUA_H_V
-- This is to avoid error message for the outer Join
-- with HZ_PARTIES table
--
-- Who         When            What
-- knaraset  29-Apr-03   added p_uoo_id as parameter,also removed the other parameters unit_cd,cal_type and sequence_number
--                       passed uoo_id in call of Igs_Au_Gen_003.audp_get_suah_col,
--                       as part of MUS build bug 2829262
--
----------------------------------------------
  CURSOR CUR_RWP IS
  SELECT rule_waived_person_id
  FROM IGS_EN_SU_ATTEMPT
  WHERE person_id=p_person_id AND
        course_cd = p_course_cd AND
        uoo_id = p_uoo_id;
  P_RWP NUMBER;
  p_pers_id_ret NUMBER;
BEGIN
--
-- Get the rule_waived_person_id from the Main Table()
-- which will be returned if rule_waived_person_id is null in History table.
--
 OPEN CUR_RWP;
 FETCH CUR_RWP INTO P_RWP;
 p_pers_id_ret := NVL(P_H_rule_waived_person_id, NVL(Igs_Au_Gen_003.audp_get_suah_col('RULE_WAIVED_PERSON_ID', P_person_id, P_course_cd, P_hist_end_dt,p_uoo_id), P_RWP));

--
-- Return the rule_waived_person_id calculated above.
--
 RETURN p_pers_id_ret;

END ENRP_RET_WAIVE_PERSON_ID;

END igs_au_gen_003;

/
