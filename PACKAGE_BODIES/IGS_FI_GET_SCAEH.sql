--------------------------------------------------------
--  DDL for Package Body IGS_FI_GET_SCAEH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GET_SCAEH" AS
/* $Header: IGSFI06B.pls 115.5 2002/11/29 00:15:15 nsidana ship $ */
  --
  -- Routine to save SCA effective history data in a PL/SQL RECORD.
  PROCEDURE FINP_GET_SCAEH(
  p_person_id IN NUMBER ,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE ,
  p_effective_dt IN DATE ,
  p_data_found OUT NOCOPY BOOLEAN ,
  p_scaeh_dtl IN OUT NOCOPY IGS_AS_SC_ATTEMPT_H_ALL%ROWTYPE )
  AS
  	gv_other_detail         VARCHAR2(255);
  BEGIN
  DECLARE
  	-- cursor to get the current student IGS_PS_COURSE attempt status
  	CURSOR c_sca IS
  		SELECT	*
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = p_course_cd AND
  			sca.logical_delete_dt IS NULL;
  	CURSOR c_scah (cp_effective_dt		DATE) IS
  		SELECT	*
  		FROM	IGS_AS_SC_ATTEMPT_H	scah
  		WHERE	scah.person_id = p_person_id AND
  			scah.course_cd = p_course_cd AND
  			cp_effective_dt	BETWEEN	scah.hist_start_dt AND
  						scah.hist_end_dt;
  	r_sca		IGS_EN_STDNT_PS_ATT%ROWTYPE;
  	r_scah		IGS_AS_SC_ATTEMPT_H%ROWTYPE;
  	v_scah_found	BOOLEAN;
  -------------------------------------------------------------------------------
  	PROCEDURE finpl_ins_sca_rec(
  		p_hist_start_dt		IGS_AS_SC_ATTEMPT_H.hist_start_dt%TYPE,
  		p_hist_end_dt		IGS_AS_SC_ATTEMPT_H.hist_end_dt%TYPE,
  		p_sca_rec		IGS_EN_STDNT_PS_ATT%ROWTYPE)
  	AS
  	BEGIN
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('IN finpl_ins_sca_rec');
  		gr_scaeh.r_scah.person_id := p_sca_rec.person_id;
  		gr_scaeh.r_scah.course_cd := p_sca_rec.course_cd;
  		gr_scaeh.r_scah.hist_start_dt := p_hist_start_dt;
  		gr_scaeh.r_scah.hist_end_dt := p_hist_end_dt;
  		gr_scaeh.r_scah.hist_who := p_sca_rec.LAST_UPDATED_BY;
  		gr_scaeh.r_scah.version_number := p_sca_rec.version_number;
  		gr_scaeh.r_scah.cal_type := p_sca_rec.cal_type;
  		gr_scaeh.r_scah.location_cd := p_sca_rec.location_cd;
  		gr_scaeh.r_scah.attendance_mode := p_sca_rec.attendance_mode;
  		gr_scaeh.r_scah.attendance_type := p_sca_rec.attendance_type;
  		gr_scaeh.r_scah.student_confirmed_ind := p_sca_rec.student_confirmed_ind;
  		gr_scaeh.r_scah.commencement_dt := p_sca_rec.commencement_dt;
  		gr_scaeh.r_scah.course_attempt_status := p_sca_rec.course_attempt_status;
  		gr_scaeh.r_scah.progression_status := p_sca_rec.progression_status;
  		gr_scaeh.r_scah.derived_att_type := p_sca_rec.derived_att_type;
  		gr_scaeh.r_scah.derived_att_mode := p_sca_rec.derived_att_mode;
  		gr_scaeh.r_scah.provisional_ind := p_sca_rec.provisional_ind;
  		gr_scaeh.r_scah.discontinued_dt := p_sca_rec.discontinued_dt;
  		gr_scaeh.r_scah.discontinuation_reason_cd :=
  			p_sca_rec.discontinuation_reason_cd ;
  		gr_scaeh.r_scah.lapsed_dt := p_sca_rec.lapsed_dt;
  		gr_scaeh.r_scah.funding_source  := p_sca_rec.funding_source ;
  		-- gr_scaeh.r_scah.fs_description :=
  		gr_scaeh.r_scah.exam_location_cd := p_sca_rec.exam_location_cd;
  		-- gr_scaeh.r_scah.elo_description :=
  		gr_scaeh.r_scah.derived_completion_yr := p_sca_rec.derived_completion_yr;
  		gr_scaeh.r_scah.derived_completion_perd := p_sca_rec.derived_completion_perd;
  		gr_scaeh.r_scah.nominated_completion_yr := p_sca_rec.nominated_completion_yr;
  		gr_scaeh.r_scah.nominated_completion_perd :=
  			p_sca_rec.nominated_completion_perd;
  		gr_scaeh.r_scah.rule_check_ind := p_sca_rec.rule_check_ind;
  		gr_scaeh.r_scah.waive_option_check_ind := p_sca_rec.waive_option_check_ind;
  		gr_scaeh.r_scah.last_rule_check_dt := p_sca_rec.last_rule_check_dt;
  		gr_scaeh.r_scah.publish_outcomes_ind := p_sca_rec.publish_outcomes_ind;
  		gr_scaeh.r_scah.course_rqrmnt_complete_ind :=
  			p_sca_rec.course_rqrmnt_complete_ind;
  		gr_scaeh.r_scah.course_rqrmnts_complete_dt :=
  			p_sca_rec.course_rqrmnts_complete_dt;
  		gr_scaeh.r_scah.s_completed_source_type := p_sca_rec.s_completed_source_type;
  		gr_scaeh.r_scah.override_time_limitation :=
  			p_sca_rec.override_time_limitation;
  		gr_scaeh.r_scah.advanced_standing_ind := p_sca_rec.advanced_standing_ind;
  		gr_scaeh.r_scah.fee_cat:= p_sca_rec.fee_cat;
  		gr_scaeh.r_scah.correspondence_cat:= p_sca_rec.correspondence_cat;
  		gr_scaeh.r_scah.self_help_group_ind := p_sca_rec.self_help_group_ind;
  		gr_scaeh.r_scah.adm_admission_appl_number :=
  			p_sca_rec.adm_admission_appl_number;
  		gr_scaeh.r_scah.adm_nominated_course_cd := p_sca_rec.adm_nominated_course_cd;
  		gr_scaeh.r_scah.adm_sequence_number := p_sca_rec.adm_sequence_number;
  		gr_scaeh.r_scah.LAST_UPDATED_BY := p_sca_rec.LAST_UPDATED_BY;
  		gr_scaeh.r_scah.LAST_UPDATE_DATE := p_sca_rec.LAST_UPDATE_DATE;
  		p_data_found := TRUE;
  		p_scaeh_dtl := gr_scaeh.r_scah;
       EXCEPTION
        WHEN OTHERS THEN
         Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_FI_GET_SCAEH.FINPL_INS_SCA_REC');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
  	END finpl_ins_sca_rec;
  -------------------------------------------------------------------------------
  	PROCEDURE finpl_ins_scah_rec (
  		p_scah_rec	IGS_AS_SC_ATTEMPT_H%ROWTYPE,
  		p_sca_rec	IGS_EN_STDNT_PS_ATT%ROWTYPE)
  	AS
  	BEGIN
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('IN finpl_ins_scah_rec');
  		gr_scaeh.r_scah.person_id := p_scah_rec.person_id;
  		gr_scaeh.r_scah.course_cd := p_scah_rec.course_cd;
  		gr_scaeh.r_scah.hist_start_dt := p_scah_rec.hist_start_dt;
  		gr_scaeh.r_scah.hist_end_dt := p_scah_rec.hist_end_dt;
  		gr_scaeh.r_scah.hist_who := p_scah_rec.hist_who;
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL1');
  		gr_scaeh.r_scah.version_number :=
  			NVL(p_scah_rec.version_number,
  				NVL(TO_NUMBER(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('VERSION_NUMBER',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt)),
  					p_sca_rec.version_number));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL1');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL2');
  		gr_scaeh.r_scah.cal_type:=
                  	NVL(p_scah_rec.cal_type,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('CAL_TYPE',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_scah_rec.cal_type));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL2');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL3');
  		gr_scaeh.r_scah.location_cd :=
                  	NVL(p_scah_rec.location_cd,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('LOCATION_CD',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.location_cd));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL3');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL4');
  		gr_scaeh.r_scah.attendance_mode :=
  			NVL(p_scah_rec.attendance_mode,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('ATTENDANCE_MODE',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.ATTENDANCE_MODE));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL4');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL5');
  		gr_scaeh.r_scah.attendance_type :=
  			NVL(p_scah_rec.attendance_type,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('ATTENDANCE_TYPE',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.attendance_mode));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL5');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL6');
  		gr_scaeh.r_scah.student_confirmed_ind :=
   			NVL(p_scah_rec.student_confirmed_ind,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('STUDENT_CONFIRMED_IND',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.student_confirmed_ind));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL6');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL7');
  		gr_scaeh.r_scah.commencement_dt :=
                 		NVL(p_scah_rec.commencement_dt,
  				NVL(igs_ge_date.igsdate(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('COMMENCEMENT_DT',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt)),
  					p_sca_rec.commencement_dt));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL7');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL8');
  		gr_scaeh.r_scah.course_attempt_status :=
  			NVL(p_scah_rec.course_attempt_status,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('COURSE_ATTEMPT_STATUS',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.course_attempt_status));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL8');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL9');
  		gr_scaeh.r_scah.progression_status :=
  			NVL(p_scah_rec.progression_status,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('PROGRESSION_STATUS',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.progression_status));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL9');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL10');
  		gr_scaeh.r_scah.derived_att_type :=
  			NVL(p_scah_rec.derived_att_type,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('DERIVED_ATT_TYPE',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.derived_att_type));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL10');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL11');
  		gr_scaeh.r_scah.derived_att_mode :=
  			NVL(p_scah_rec.derived_att_mode,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('DERIVED_ATT_MODE',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.derived_att_mode));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL11');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL12');
  		gr_scaeh.r_scah.provisional_ind :=
                		NVL(p_scah_rec.provisional_ind,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('PROVISIONAL_IND',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.provisional_ind));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL12');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL13');
  		gr_scaeh.r_scah.discontinued_dt :=
                 		NVL(p_scah_rec.discontinued_dt,
  				NVL(igs_ge_date.igsdate(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('DISCONTINUED_DT',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt)),
  					p_sca_rec.discontinued_dt));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL13');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL14');
  		gr_scaeh.r_scah.discontinuation_reason_cd :=
  			NVL(p_scah_rec.discontinuation_reason_cd,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('DISCONTINUATION_REASON_CD',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.discontinuation_reason_cd));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL14');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL15');
  		gr_scaeh.r_scah.lapsed_dt :=
       			NVL(p_scah_rec.lapsed_dt,
  				NVL(igs_ge_date.igsdate(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('LAPSED_DT',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt)),
  					p_sca_rec.lapsed_dt));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL15');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL16');
  		gr_scaeh.r_scah.funding_source :=
  			NVL(p_scah_rec.funding_source,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('FUNDING_SOURCE',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.funding_source));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL16');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL17');
  		gr_scaeh.r_scah.exam_location_cd :=
                  	NVL(p_scah_rec.exam_location_cd,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('EXAM_LOCATION_CD',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.exam_location_cd));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL17');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL18');
 		gr_scaeh.r_scah.derived_completion_yr :=
  			NVL(p_scah_rec.derived_completion_yr,
  				NVL(TO_NUMBER(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('DERIVED_COMPLETION_YR',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt)),
  					p_sca_rec.derived_completion_yr));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL18');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL19');
  		gr_scaeh.r_scah.derived_completion_perd :=
  			NVL(p_scah_rec.derived_completion_perd,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('DERIVED_COMPLETION_PERD',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.derived_completion_perd));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL19');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL20');
  		gr_scaeh.r_scah.nominated_completion_yr :=
  			NVL(p_scah_rec.nominated_completion_yr,
  				NVL(TO_NUMBER(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('NOMINATED_COMPLETION_YR',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt)),
  					p_sca_rec.nominated_completion_yr));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL20');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL21');
  		gr_scaeh.r_scah.nominated_completion_perd :=
  			NVL(p_scah_rec.nominated_completion_perd,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('NOMINATED_COMPLETION_PERD',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.nominated_completion_perd));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL21');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL22');
  		gr_scaeh.r_scah.rule_check_ind :=
  			NVL(p_scah_rec.rule_check_ind,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('RULE_CHECK_IND',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.rule_check_ind));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL22');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL23');
  		gr_scaeh.r_scah.waive_option_check_ind :=
  			NVL(p_scah_rec.waive_option_check_ind,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('WAIVE_OPTION_CHECK_IND',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.waive_option_check_ind));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL23');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL24');
  		gr_scaeh.r_scah.last_rule_check_dt :=
         			NVL(p_scah_rec.last_rule_check_dt,
  				NVL(igs_ge_date.igsdate(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('LAST_RUL_CHECK_DT',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt)),
  					p_sca_rec.last_rule_check_dt));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL24');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL25');
  		gr_scaeh.r_scah.publish_outcomes_ind :=
          		NVL(p_scah_rec.publish_outcomes_ind,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('PUBLISH_OUTCOMES_IND',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.publish_outcomes_ind));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL25');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL26');
  		gr_scaeh.r_scah.course_rqrmnt_complete_ind :=
            		NVL(p_scah_rec.course_rqrmnt_complete_ind,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('COURSE_RQRMNT_COMPLETE_IND',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.course_rqrmnt_complete_ind));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL26');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL27');
  		gr_scaeh.r_scah.course_rqrmnts_complete_dt :=
         			NVL(p_scah_rec.course_rqrmnts_complete_dt,
  				NVL(igs_ge_date.igsdate(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('COURSE_RQRMNTS_COMPLETE_DT',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt)),
  					p_sca_rec.course_rqrmnts_complete_dt));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL27');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL28');
  		gr_scaeh.r_scah.s_completed_source_type :=
          		NVL(p_scah_rec.s_completed_source_type,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('S_COMPLETED_SOURCE_TYPE',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.s_completed_source_type));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL28');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL29');
  		gr_scaeh.r_scah.override_time_limitation :=
  			NVL(p_scah_rec.override_time_limitation,
  				NVL(TO_NUMBER(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('OVERRIDE_TIME_LIMITATION',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt)),
  					p_sca_rec.override_time_limitation));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL29');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL30');
  		gr_scaeh.r_scah.advanced_standing_ind :=
         			NVL(p_scah_rec.advanced_standing_ind,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('ADVANCED_STANDING_IND',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.advanced_standing_ind));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL30');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL31');
  		gr_scaeh.r_scah.fee_cat :=
            		NVL(p_scah_rec.fee_cat,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('FEE_CAT',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.fee_cat));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL31');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL32');
  		gr_scaeh.r_scah.correspondence_cat:=
  			NVL(p_scah_rec.correspondence_cat,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('CORRESPONDENCE_CAT',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.correspondence_cat));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL33');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL34');
  		--gr_scaeh.r_scah.cc_description :=
  		gr_scaeh.r_scah.self_help_group_ind :=
  			NVL(p_scah_rec.self_help_group_ind,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('SELF_HELP_GROUP_IND',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.self_help_group_ind));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL34');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL35');
  		gr_scaeh.r_scah.adm_admission_appl_number :=
   			NVL(p_scah_rec.adm_admission_appl_number,
  				NVL(TO_NUMBER(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('ADM_ADMISSION_APPL_NUMBER',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt)),
  					p_sca_rec.adm_admission_appl_number));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL35');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL36');
  		gr_scaeh.r_scah.adm_nominated_course_cd :=
  			NVL(p_scah_rec.adm_nominated_course_cd,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('ADM_NOMINATED_COURSE_CD',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt),
  					p_sca_rec.adm_nominated_course_cd));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL36');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL37');
  		gr_scaeh.r_scah.adm_sequence_number :=
          		NVL(p_scah_rec.adm_sequence_number,
  				NVL(TO_NUMBER(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('ADM_SEQUENCE_NUMBER',
  						p_scah_rec.person_id,
  						p_scah_rec.course_cd,
  						p_scah_rec.hist_end_dt)),
  					p_sca_rec.adm_sequence_number));
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL37');
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL38');
  		gr_scaeh.r_scah.LAST_UPDATED_BY := p_scah_rec.LAST_UPDATED_BY;
  		gr_scaeh.r_scah.LAST_UPDATE_DATE := p_scah_rec.LAST_UPDATE_DATE;
  		p_data_found := TRUE;
  		p_scaeh_dtl := gr_scaeh.r_scah;
       EXCEPTION
        WHEN OTHERS THEN
         Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_FI_GET_SCAEH.FINPL_INS_SCAH_REC');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
END finpl_ins_scah_rec;
  -------------------------------------------------------------------------------
  	PROCEDURE finpl_ins_scahv_rec (
  		p_hist_start_dt		IGS_AS_SC_ATTEMPT_H.hist_start_dt%TYPE,
  		p_scahv_rec		IGS_AS_SCA_H_V%ROWTYPE)
  	AS
  	BEGIN
  		gr_scaeh.r_scah.person_id := p_scahv_rec.person_id;
  		gr_scaeh.r_scah.course_cd := p_scahv_rec.course_cd;
  		gr_scaeh.r_scah.hist_start_dt := p_hist_start_dt;
  		gr_scaeh.r_scah.hist_end_dt := p_scahv_rec.hist_end_dt;
  		gr_scaeh.r_scah.hist_who := p_scahv_rec.hist_who;
  		gr_scaeh.r_scah.version_number := p_scahv_rec.version_number;
  		gr_scaeh.r_scah.cal_type := p_scahv_rec.cal_type;
  		gr_scaeh.r_scah.location_cd := p_scahv_rec.location_cd;
  		gr_scaeh.r_scah.attendance_mode := p_scahv_rec.attendance_mode;
  		gr_scaeh.r_scah.attendance_type := p_scahv_rec.attendance_type;
  		gr_scaeh.r_scah.student_confirmed_ind := p_scahv_rec.student_confirmed_ind;
  		gr_scaeh.r_scah.commencement_dt := p_scahv_rec.commencement_dt;
  		gr_scaeh.r_scah.course_attempt_status := p_scahv_rec.course_attempt_status;
  		gr_scaeh.r_scah.progression_status := p_scahv_rec.progression_status;
  		gr_scaeh.r_scah.derived_att_type := p_scahv_rec.derived_att_type;
  		gr_scaeh.r_scah.derived_att_mode := p_scahv_rec.derived_att_mode;
  		gr_scaeh.r_scah.provisional_ind := p_scahv_rec.provisional_ind;
  		gr_scaeh.r_scah.discontinued_dt := p_scahv_rec.discontinued_dt;
  		gr_scaeh.r_scah.discontinuation_reason_cd :=
  			p_scahv_rec.discontinuation_reason_cd;
  		gr_scaeh.r_scah.lapsed_dt := p_scahv_rec.lapsed_dt;
  		gr_scaeh.r_scah.funding_source:= p_scahv_rec.funding_source;
  		gr_scaeh.r_scah.exam_location_cd := p_scahv_rec.exam_location_cd;
  		gr_scaeh.r_scah.derived_completion_yr := p_scahv_rec.derived_completion_yr;
  		gr_scaeh.r_scah.derived_completion_perd :=
  			p_scahv_rec.derived_completion_perd;
  		gr_scaeh.r_scah.nominated_completion_yr :=
  			p_scahv_rec.nominated_completion_yr;
  		gr_scaeh.r_scah.nominated_completion_perd :=
  			p_scahv_rec.nominated_completion_perd;
  		gr_scaeh.r_scah.rule_check_ind := p_scahv_rec.rule_check_ind;
  		gr_scaeh.r_scah.waive_option_check_ind := p_scahv_rec.waive_option_check_ind;
  		gr_scaeh.r_scah.last_rule_check_dt := p_scahv_rec.last_rule_check_dt;
  		gr_scaeh.r_scah.publish_outcomes_ind := p_scahv_rec.publish_outcomes_ind;
  		gr_scaeh.r_scah.course_rqrmnt_complete_ind :=
  			p_scahv_rec.course_rqrmnt_complete_ind;
  		gr_scaeh.r_scah.course_rqrmnts_complete_dt :=
  			p_scahv_rec.course_rqrmnts_complete_dt;
  		gr_scaeh.r_scah.s_completed_source_type :=
  			p_scahv_rec.s_completed_source_type;
  		gr_scaeh.r_scah.override_time_limitation :=
  			p_scahv_rec.override_time_limitation;
  		gr_scaeh.r_scah.advanced_standing_ind := p_scahv_rec.advanced_standing_ind;
  		gr_scaeh.r_scah.fee_cat := p_scahv_rec.fee_cat;
  		-- gr_scaeh.r_scah.fc_description :=
  		gr_scaeh.r_scah.correspondence_cat:= p_scahv_rec.correspondence_cat;
  		--gr_scaeh.r_scah.cc_description :=
  		gr_scaeh.r_scah.self_help_group_ind := p_scahv_rec.self_help_group_ind;
  		gr_scaeh.r_scah.adm_admission_appl_number :=
  			p_scahv_rec.adm_admission_appl_number;
  		gr_scaeh.r_scah.adm_nominated_course_cd :=
  			p_scahv_rec.adm_nominated_course_cd;
  		gr_scaeh.r_scah.adm_sequence_number := p_scahv_rec.adm_sequence_number;
  		gr_scaeh.r_scah.LAST_UPDATED_BY := p_scahv_rec.LAST_UPDATED_BY;
  		gr_scaeh.r_scah.LAST_UPDATE_DATE := p_scahv_rec.LAST_UPDATE_DATE;
  		p_data_found := TRUE;
  		p_scaeh_dtl := gr_scaeh.r_scah;
       EXCEPTION
        WHEN OTHERS THEN
         Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_FI_GET_SCAEH.FINPL_INS_SCAHV_REC');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
  	END finpl_ins_scahv_rec;
  -------------------------------------------------------------------------------
  	PROCEDURE finpl_prc_sca_enrhist(
  		p_sca_rec	IN OUT NOCOPY	IGS_EN_STDNT_PS_ATT%ROWTYPE)
  	AS
  	BEGIN
  	DECLARE
  		CURSOR c_scahv_last_enr (cp_effective_dt		DATE) IS
  			SELECT	*
  			FROM	IGS_AS_SCA_H_V	scahv
  			WHERE	scahv.person_id = p_person_id AND
  				scahv.course_cd = p_course_cd AND
  				scahv.course_attempt_status = 'ENROLLED' AND
  				cp_effective_dt	<= scahv.hist_start_dt
  			ORDER BY scahv.hist_start_dt desc;
  		r_scahv		IGS_AS_SCA_H_V%ROWTYPE;
  	BEGIN
  		-- check the last enrolled history for a match
  		OPEN	c_scahv_last_enr(p_sca_rec.commencement_dt);
  		FETCH	c_scahv_last_enr INTO	r_scahv;
  		IF (c_scahv_last_enr%FOUND) THEN
  			CLOSE	c_scahv_last_enr;
  			IF TRUNC(gv_effective_dt) <= TRUNC(r_scahv.hist_end_dt) THEN
  				-- save the sca history data when last enrolled
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_scahv_rec');
  				finpl_ins_scahv_rec(
  						p_sca_rec.commencement_dt,
  						r_scahv);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_scahv_rec');
  			ELSE
  				-- save the current student IGS_PS_UNIT attempt data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_sca_rec');
  				finpl_ins_sca_rec(
  						r_scahv.hist_end_dt,
  						SYSDATE,
  						p_sca_rec);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_sca_rec');
  			END IF;
  		ELSE -- missing enrolment history
  			CLOSE	c_scahv_last_enr;
  			-- check if the effective date falls within the period
  			-- of the current student IGS_PS_UNIT attempt values
  			IF TRUNC(gv_effective_dt) >= TRUNC(p_sca_rec.LAST_UPDATE_DATE) THEN
  				-- save the current sca data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_sca_rec');
  				finpl_ins_sca_rec(
  						p_sca_rec.LAST_UPDATE_DATE,
  						SYSDATE,
  						p_sca_rec);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_sca_rec');
  			ELSE
  				-- simulate an enrolment history
  				p_sca_rec.course_attempt_status := 'ENROLLED';
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_sca_rec');
  				finpl_ins_sca_rec(
  						p_sca_rec.commencement_dt,
  						p_sca_rec.LAST_UPDATE_DATE,
  						p_sca_rec);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_sca_rec');
  			END IF;
  		END IF;
  	END;
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('out finpl_prc_sca_enrhist');
       EXCEPTION
        WHEN OTHERS THEN
         Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_FI_GET_SCAEH.FINPL_PRC_SCA_ENRHIST');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
  	END finpl_prc_sca_enrhist;
  -------------------------------------------------------------------------------
  BEGIN	-- finp_get_scaeh
  	-- effective history logic is based upon the following assumptions -
  	-- the transitions between IGS_PS_COURSE status's are;
  	--	UNCONFIRM	-> ENROLLED
  	--	  		-> DELETED
  	--			-> INACTIVE
  	--
  	--	DELETED		-> UNCONFIRM
  	--
  	--	ENROLLED	-> UNCONFIRM
  	--			-> DISCONTIN
  	--			-> LAPSED
  	--			-> INACTIVE
  	--			-> INTERMIT
  	--			-> COMPLETED
  	--
  	--	LAPSED		-> ENROLLED
  	--			-> DISCONTIN
  	--			-> INACTIVE
  	--
  	--	INACTIVE	-> UNCONFIRM
  	--			-> ENROLLED
  	--			-> DISCONTIN
  	--			-> COMPLETED
  	--			-> INTERMIT
  	--			-> LAPSED
  	--
  	--	INTERMIT	-> ENROLLED
  	--			-> DISCONTIN
  	--			-> COMPLETED
  	--			-> INACTIVE
  	--
  	--	DISCONTIN	-> ENROLLED
  	--			-> LAPSED
  	--			-> INACTIVE
  	--			-> INTERMIT
  	--
  	--	COMPLETE	-> ENROLLED
  	--			-> INACTIVE
  	--
  	-- the effective history transitions are
  	--	UNCONFIRM -> ENROLLED -> INTERMIT -> ENROLLED -> COMPLETED
  	--	UNCONFIRM -> ENROLLED -> DISCONTIN
  	-- check parameters
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('in procedure : IGS_FI_GET_SCAEH.FINP_GET_SCAEH');
    	IF p_person_id IS NULL OR
    		p_course_cd IS NULL OR
    		p_effective_dt IS NULL THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
    	END IF;
  	-- check if the effective history has already been captured
  	IF gv_person_id IS NOT NULL AND
  		gv_course_cd IS NOT NULL AND
  		gv_effective_dt IS NOT NULL THEN
  		IF gv_person_id = p_person_id AND
  			gv_course_cd = p_course_cd AND
  			TRUNC(gv_effective_dt) = TRUNC(p_effective_dt) THEN
  			p_data_found := TRUE;
  			p_scaeh_dtl := gr_scaeh.r_scah;
  			RETURN;
  		END IF;
  	END IF;
  	gv_person_id := p_person_id;
  	gv_course_cd := p_course_cd;
  	gv_effective_dt :=igs_ge_date.igsdate(igs_ge_date.igschar(p_effective_dt)|| '23:59:59');
  	p_data_found := FALSE;
  	-- get the current student IGS_PS_COURSE attempt details
  	OPEN	c_sca;
  	FETCH	c_sca	INTO	r_sca;
  	IF (c_sca%NOTFOUND) THEN
  		CLOSE	c_sca;
  		RETURN;
  	END IF;
  	CLOSE	c_sca;
  	-- check if effective date is set today or into the future
  	IF TRUNC(gv_effective_dt) >= TRUNC(SYSDATE) THEN
  		IF r_sca.course_attempt_status IN (
  						'COMPLETED',
  						'ENROLLED',
  						'INTERMIT',
  						'LAPSED',
  						'INACTIVE') THEN
  			-- check if commencing on or before the effective date
  			IF TRUNC(r_sca.commencement_dt) <= TRUNC(gv_effective_dt) THEN
  				-- save the current student IGS_PS_COURSE attempt data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_sca_rec');
  				finpl_ins_sca_rec(
  					r_sca.commencement_dt,
  					gv_effective_dt,
  					r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_sca_rec');
  			ELSE
  				-- save the current student IGS_PS_COURSE attempt data as an
  				-- unconfirmed history
  				r_sca.course_attempt_status := 'UNCONFIRM';
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_sca_rec');
  				finpl_ins_sca_rec(
  					gv_effective_dt,
  					r_sca.commencement_dt,
  					r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_sca_rec');
  			END IF;
  		ELSIF r_sca.course_attempt_status = 'DISCONTIN' THEN
  			-- save the current student IGS_PS_COURSE attempt data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_sca_rec');
  			finpl_ins_sca_rec(
  					r_sca.discontinued_dt,
  					gv_effective_dt,
  					r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_sca_rec');
  		ELSIF r_sca.course_attempt_status = 'UNCONFIRM' THEN
  			-- save the current student IGS_PS_COURSE attempt data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_sca_rec');
  			finpl_ins_sca_rec(
  					r_sca.LAST_UPDATE_DATE,
  					gv_effective_dt,
  					r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_sca_rec');
  		ELSE	-- unrecognised status
          Fnd_Message.Set_Name ('IGS', 'IGS_FI_UNRECOG_SPA_STATUS');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
  		END IF;
  		RETURN;
  	END IF;
  	-- process history effective up until the current day
  	-- check if effective date falls within a student IGS_PS_COURSE attempt history
  	OPEN	c_scah(gv_effective_dt);
  	FETCH	c_scah	INTO	r_scah;
  	IF (c_scah%FOUND) THEN
  		v_scah_found := TRUE;
  		IF r_scah.course_attempt_status IS NULL THEN
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before IGS_AU_GEN_003.AUDP_GET_SCAH_COL');
  			r_scah.course_attempt_status :=
  				NVL(IGS_AU_GEN_003.AUDP_GET_SCAH_COL('COURSE_ATTEMPT_STATUS',
  						r_scah.person_id,
  						r_scah.course_cd,
  						r_scah.hist_end_dt),
  					r_sca.course_attempt_status);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after IGS_AU_GEN_003.AUDP_GET_SCAH_COL');
  		END IF;
  	ELSE
  		v_scah_found := FALSE;
  	END IF;
  	CLOSE	c_scah;
  	IF r_sca.course_attempt_status = 'ENROLLED' THEN
  		-- check if the effective date falls within the effective
  		-- enrolled period
  		IF TRUNC(gv_effective_dt) >= TRUNC(r_sca.commencement_dt) THEN
  			IF v_scah_found = TRUE THEN
  				IF r_scah.course_attempt_status IN (
  								'ENROLLED',
  								'INTERMIT') THEN
  					-- save the student IGS_PS_COURSE attempt history data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_scah_rec');
  					finpl_ins_scah_rec(
  							r_scah,
  							r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_scah_rec');
  				ELSE	-- enrolment overrides history
  					-- save the current student IGS_PS_COURSE attempt data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_sca_rec');
  					finpl_ins_sca_rec(r_sca.commencement_dt,
  							SYSDATE,
  							r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_sca_rec');
  				END IF;
  			ELSE	-- no matching history
  				-- save the current student IGS_PS_COURSE attempt data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_sca_rec');
  				finpl_ins_sca_rec(r_sca.commencement_dt,
  						SYSDATE,
  						r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_sca_rec');
  			END IF;
  		ELSE	-- prior to student IGS_PS_COURSE attempt commencement
  			IF v_scah_found = TRUE THEN
  				IF r_scah.course_attempt_status IN ('UNCONFIRM') THEN
  					-- save the student IGS_PS_COURSE attempt history data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_scah_rec');
  					finpl_ins_scah_rec(
  							r_scah,
  							r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_scah_rec');
  				ELSE
  					RETURN;
  				END IF;
  			ELSE
  				RETURN;
  			END IF;
  		END IF;
  	ELSIF r_sca.course_attempt_status = 'COMPLETED' THEN
  		-- check if the effective date falls within the effective
  		-- enrolled period
  		IF TRUNC(gv_effective_dt) >= TRUNC(r_sca.commencement_dt) THEN
  			IF v_scah_found = TRUE THEN
  				IF r_scah.course_attempt_status IN (
  								'COMPLETED',
  								'ENROLLED',
  								'INTERMIT') THEN
  					-- save the student IGS_PS_COURSE attempt history data

--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_scah_rec');
  					finpl_ins_scah_rec(
  							r_scah,
  							r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_scah_rec');
  				ELSE	-- not an expected history
  					-- assume ENROLLED -> COMPLETED
  					-- use the last enrolled history
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_prc_sca_enrhist');
  					finpl_prc_sca_enrhist(r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_prc_sca_enrhist');
  				END IF;
  			ELSE	-- no matching history
  				-- assume ENROLLED -> COMPLETED
  				-- use the last enrolled history
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_prc_sca_enrhist');
  				finpl_prc_sca_enrhist(r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_prc_sca_enrhist');
  			END IF;
  		ELSE	-- prior to student IGS_PS_COURSE attempt commencement
  			IF v_scah_found = TRUE THEN
  				IF r_scah.course_attempt_status IN ('UNCONFIRM') THEN
  					-- save the student IGS_PS_COURSE attempt history data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_scah_rec');
  					finpl_ins_scah_rec(
  							r_scah,
  							r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_scah_rec');
  				ELSE
  					RETURN;
  				END IF;
  			ELSE
  				RETURN;
  			END IF;
  		END IF;
  	ELSIF r_sca.course_attempt_status = 'DISCONTIN' THEN
  		-- check if the effective date falls within the effective
  		-- discontinuation period
  		IF TRUNC(gv_effective_dt) >= TRUNC(r_sca.discontinued_dt) THEN
  			IF v_scah_found = TRUE THEN
  				IF r_scah.course_attempt_status = 'DISCONTIN' THEN
  					-- save the student IGS_PS_COURSE attempt history data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_scah_rec');
  					finpl_ins_scah_rec(
  							r_scah,
  							r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_scah_rec');
  				ELSE	-- discontinuation overrides the history
  					-- save the current student IGS_PS_COURSE attempt data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_sca_rec');
  					finpl_ins_sca_rec(r_sca.discontinued_dt,
  							SYSDATE,
  							r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_sca_rec');
  				END IF;
  			ELSE	-- no matching history
  				-- save the current student IGS_PS_COURSE attempt data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_sca_rec');
  				finpl_ins_sca_rec(r_sca.discontinued_dt,
  						SYSDATE,
  						r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_sca_rec');
  			END IF;
  		ELSE -- prior to student IGS_PS_COURSE attempt discontinuation
  			IF gv_effective_dt >= TRUNC(r_sca.commencement_dt) THEN
  				-- within the enrolled period
  				IF v_scah_found = TRUE THEN
  					IF r_scah.course_attempt_status IN (
  									'ENROLLED',
  									'LAPSED',
  									'INACTIVE',
  									'INTERMIT') THEN
  						-- save the student IGS_PS_COURSE attempt history data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_scah_rec');
  						finpl_ins_scah_rec(
  								r_scah,
  								r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_scah_rec');
  					ELSE	-- not an expected history
  						-- assume ENROLLED -> DISCONTIN
  						-- use the last enrolled history
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_prc_sca_enrhist');
  						finpl_prc_sca_enrhist(r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_prc_sca_enrhist');
  					END IF;
  				ELSE	-- no matching history
  					-- assume ENROLLED -> DISCONTIN
  					-- use the last enrolled history
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_prc_sca_enrhist');
  					finpl_prc_sca_enrhist(r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_prc_sca_enrhist');
  				END IF;
  			ELSE	-- prior to student IGS_PS_COURSE attempt commencement
  				IF v_scah_found = TRUE THEN
  					IF r_scah.course_attempt_status IN ('UNCONFIRM') THEN
  						-- save the student IGS_PS_COURSE attempt history data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_scah_rec');
  						finpl_ins_scah_rec(
  								r_scah,
  								r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('after finpl_ins_scah_rec');
  					ELSE
  						RETURN;
  					END IF;
  				ELSE
  					RETURN;
  				END IF;
  			END IF;
    		END IF;
  	ELSIF r_sca.course_attempt_status = 'UNCONFIRM' THEN
  		IF v_scah_found = TRUE THEN
  			IF r_scah.course_attempt_status = 'UNCONFIRM' THEN
  				-- save the student IGS_PS_COURSE attempt history data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('before finpl_ins_scah_rec');
  				finpl_ins_scah_rec(
  						r_scah,
  						r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('a finpl_ins_scah_rec');
  			ELSE	-- unconfirm overrides history
  				-- save the current student IGS_PS_COURSE attempt data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('b finpl_ins_sca_rec');
  				finpl_ins_sca_rec(gv_effective_dt,
  						SYSDATE,
  						r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('a finpl_ins_sca_rec');
  			END IF;
  		ELSE	-- no matching history
  			-- check if the effective date falls within the period the
  			-- student IGS_PS_COURSE attempt was created and today
  			IF TRUNC(gv_effective_dt) >= TRUNC(r_sca.LAST_UPDATE_DATE) THEN
  				-- save the current student IGS_PS_COURSE attempt data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('b finpl_ins_sca_rec');
  				finpl_ins_sca_rec(r_sca.LAST_UPDATE_DATE,
  						SYSDATE,
  						r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('a finpl_ins_sca_rec');
  			ELSE -- prior to student IGS_PS_COURSE attempt record creation
  				RETURN;
  			END IF;
  		END IF;
  	ELSIF r_sca.course_attempt_status IN (
  					'LAPSED',
  					'INACTIVE',
  					'INTERMIT') THEN
  		-- check if the effective date falls within the effective
  		-- enrolled period
  		IF TRUNC(gv_effective_dt) >= TRUNC(r_sca.commencement_dt) THEN
  			IF v_scah_found = TRUE THEN
  				IF r_scah.course_attempt_status IN (
  								'ENROLLED',
  								'LAPSED',
  								'INACTIVE',
  								'INTERMIT') THEN
  					-- save the student IGS_PS_COURSE attempt history data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('b finpl_ins_scah_rec');
  					finpl_ins_scah_rec(
  							r_scah,
  							r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('a finpl_ins_scah_rec');
  				ELSE	-- not an expected history
  					-- assume ENROLLED -> LAPSED/INACTIVE/INTERMIT
  					-- use the last enrolled history
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('b finpl_prc_sca_enrhist');
  					finpl_prc_sca_enrhist(r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('a finpl_prc_sca_enrhist');
  				END IF;
  			ELSE	-- no matching history
  				-- assume ENROLLED -> LAPSED/INACTIVE/INTERMIT
  				-- use the last enrolled history
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('b finpl_prc_sca_enrhist');
  				finpl_prc_sca_enrhist(r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('a finpl_prc_sca_enrhist');
  			END IF;
  		ELSE	-- prior to student IGS_PS_COURSE attempt commencement
  			IF v_scah_found = TRUE THEN
  				IF r_scah.course_attempt_status IN ('UNCONFIRM') THEN
  					-- save the student IGS_PS_COURSE attempt history data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('b finpl_ins_scah_rec');
  					finpl_ins_scah_rec(
  							r_scah,
  							r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('a finpl_ins_scah_rec');
  				ELSE
  					RETURN;
  				END IF;
  			ELSE
  				RETURN;
  			END IF;
  		END IF;
  	ELSIF r_sca.course_attempt_status = 'DELETED' THEN
  		IF v_scah_found = TRUE THEN
  			IF r_scah.course_attempt_status IN ('DELETED',
  							'UNCONFIRM') THEN
  				-- save the student IGS_PS_COURSE attempt history data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('b finpl_ins_scah_rec');
  				finpl_ins_scah_rec(
  						r_scah,
  						r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('a finpl_ins_scah_rec');
  			ELSE	-- delete overrides history
  				-- save the current student IGS_PS_COURSE attempt data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('b finpl_ins_sca_rec');
  				finpl_ins_sca_rec(	gv_effective_dt,
  							SYSDATE,
  							r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('a finpl_ins_sca_rec');
  			END IF;
  		ELSE
  			-- check if the effective date falls within the period the
  			-- student IGS_PS_COURSE attempt was created and today
  			IF TRUNC(gv_effective_dt) >= TRUNC(r_sca.LAST_UPDATE_DATE) THEN
  				-- save the current student IGS_PS_COURSE attempt data
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('b finpl_ins_sca_rec');
  				finpl_ins_sca_rec(	r_sca.LAST_UPDATE_DATE,
  							SYSDATE,
  							r_sca);
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('a finpl_ins_sca_rec');
  			ELSE -- prior to student IGS_PS_COURSE attempt record creation
  				RETURN;
  			END IF;
  		END IF;
  	ELSE	-- unrecognised status
        Fnd_Message.Set_Name ('IGS', 'IGS_FI_UNRECOG_SPA_STATUS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
  	END IF;
  END;
--commented by syam to avoid adchkdrv errors -dbms_output.put_line('out procedure : IGS_FI_GET_SCAEH.FINP_GET_SCAEH');
       EXCEPTION
        WHEN OTHERS THEN
         Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_FI_GET_SCAEH.FINP_GET_SCAEH');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
  END finp_get_scaeh;
END IGS_FI_GET_SCAEH;

/
