--------------------------------------------------------
--  DDL for Package Body IGS_FI_GET_SUAEH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GET_SUAEH" AS
/* $Header: IGSFI07B.pls 115.9 2003/05/23 06:53:57 knaraset ship $ */
  -- Routine to save SUA effective history data in a PL/SQL TABLE.
-- Who         When            What
-- knaraset  29-Apr-03   Modified calls to IGS_AU_GEN_003.AUDP_GET_SUAH_COL to add uoo_id, as part of MUS build bug 2829262
--

  PROCEDURE FINP_GET_SUAEH(
  p_person_id IN NUMBER ,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE ,
  p_unit_cd IN IGS_PS_UNIT.unit_cd%TYPE ,
  p_effective_dt IN DATE ,
  p_table_index IN OUT NOCOPY BINARY_INTEGER ,
  p_suaeh_table IN OUT NOCOPY IGS_FI_GET_SUAEH.t_suaeh_dtl)
  AS
  	gv_other_detail         VARCHAR2(255);
        lv_param_values         VARCHAR2(1080);
  BEGIN
  DECLARE
  	-- cursor to get the current student IGS_PS_UNIT attempt status
  	CURSOR c_sua IS
  		SELECT	*
  		FROM	IGS_EN_SU_ATTEMPT	sua
  		WHERE	sua.person_id = p_person_id AND
  			(p_course_cd IS NULL OR
  			sua.course_cd = p_course_cd) AND
  			(p_unit_cd IS NULL OR
  			sua.unit_cd = p_unit_cd);
  	CURSOR c_suah (	cp_course_cd	IGS_PS_COURSE.course_cd%TYPE,
  			cp_unit_cd	IGS_PS_UNIT.unit_cd%TYPE,
  			cp_effective_dt	DATE) IS
  		SELECT	PERSON_ID                      ,
			COURSE_CD                      ,
			UNIT_CD                        ,
			VERSION_NUMBER                 ,
			CAL_TYPE                       ,
			CI_SEQUENCE_NUMBER             ,
			HIST_START_DT                  ,
			HIST_END_DT                    ,
			HIST_WHO                       ,
			LOCATION_CD                    ,
			UNIT_CLASS                     ,
			ENROLLED_DT                    ,
			UNIT_ATTEMPT_STATUS            ,
			ADMINISTRATIVE_UNIT_STATUS     ,
			AUS_DESCRIPTION                ,
			DISCONTINUED_DT                ,
			RULE_WAIVED_DT                 ,
			RULE_WAIVED_PERSON_ID          ,
			NO_ASSESSMENT_IND              ,
			EXAM_LOCATION_CD               ,
			ELO_DESCRIPTION                ,
			SUP_UNIT_CD                    ,
			SUP_VERSION_NUMBER             ,
			ALTERNATIVE_TITLE              ,
			OVERRIDE_ENROLLED_CP           ,
			OVERRIDE_EFTSU                 ,
			OVERRIDE_ACHIEVABLE_CP         ,
			OVERRIDE_OUTCOME_DUE_DT        ,
			OVERRIDE_CREDIT_REASON         ,
			CREATED_BY                     ,
			CREATION_DATE                  ,
			LAST_UPDATED_BY                ,
			LAST_UPDATE_DATE               ,
			LAST_UPDATE_LOGIN              ,
			DCNT_REASON_CD                 ,
			ORG_ID                         ,
            UOO_ID
  		FROM	IGS_EN_SU_ATTEMPT_H	suah
  		WHERE	suah.person_id = p_person_id AND
  			suah.course_cd = cp_course_cd AND
  			suah.unit_cd = cp_unit_cd AND
  			cp_effective_dt	BETWEEN	suah.hist_start_dt AND
  						suah.hist_end_dt;
  	r_sua		IGS_EN_SU_ATTEMPT%ROWTYPE;
  	r_suah		r_t_suaeh_dtl;-- record type
  	v_suah_found	BOOLEAN;
  -------------------------------------------------------------------------------
  	PROCEDURE finpl_ins_sua_rec(
  		p_hist_start_dt		IGS_EN_SU_ATTEMPT_H.hist_start_dt%TYPE,
  		p_hist_end_dt		IGS_EN_SU_ATTEMPT_H.hist_end_dt%TYPE,
  		p_sua_rec		IGS_EN_SU_ATTEMPT%ROWTYPE)
  	AS
  	BEGIN
  	DECLARE
  		v_suah_rec	r_t_suaeh_dtl;
  	BEGIN
--commented by syam to avoid adchkdrv errors -dbms_output.put_line(' IN PROCEDURE (DECLARE) START : IGS_FI_GET_SUAEH.finpl_ins_sua_rec');

  		v_suah_rec.person_id := p_sua_rec.person_id;
  		v_suah_rec.course_cd := p_sua_rec.course_cd;
  		v_suah_rec.unit_cd := p_sua_rec.unit_cd;
  		v_suah_rec.version_number := p_sua_rec.version_number;
  		v_suah_rec.cal_type := p_sua_rec.cal_type;
  		v_suah_rec.ci_sequence_number := p_sua_rec.ci_sequence_number;
  		v_suah_rec.hist_start_dt := p_hist_start_dt;
  		v_suah_rec.hist_end_dt := p_hist_end_dt;
  		v_suah_rec.hist_who := p_sua_rec.LAST_UPDATED_BY;
  		v_suah_rec.location_cd := p_sua_rec.location_cd;
  		v_suah_rec.unit_class := p_sua_rec.unit_class;
  		v_suah_rec.enrolled_dt := p_sua_rec.enrolled_dt;
  		v_suah_rec.unit_attempt_status := p_sua_rec.unit_attempt_status;
  		v_suah_rec.administrative_unit_status :=
			p_sua_rec.administrative_unit_status ;
  		v_suah_rec.discontinued_dt := p_sua_rec.discontinued_dt;
  		v_suah_rec.rule_waived_dt := p_sua_rec.rule_waived_dt;
  		v_suah_rec.rule_waived_person_id := p_sua_rec.rule_waived_person_id;
   		v_suah_rec.no_assessment_ind := p_sua_rec.no_assessment_ind;
  		v_suah_rec.exam_location_cd := p_sua_rec.exam_location_cd;
  		v_suah_rec.sup_unit_cd := p_sua_rec.sup_unit_cd;
  		v_suah_rec.sup_version_number := p_sua_rec.sup_version_number;
  		v_suah_rec.alternative_title := p_sua_rec.alternative_title;
  		v_suah_rec.override_enrolled_cp := p_sua_rec.override_enrolled_cp;
  		v_suah_rec.override_eftsu := p_sua_rec.override_eftsu;
  		v_suah_rec.override_achievable_cp := p_sua_rec.override_achievable_cp;
  		v_suah_rec.override_outcome_due_dt := p_sua_rec.override_outcome_due_dt;
  		v_suah_rec.LAST_UPDATED_BY := p_sua_rec.LAST_UPDATED_BY;
  		v_suah_rec.LAST_UPDATE_DATE := p_sua_rec.LAST_UPDATE_DATE;
  		v_suah_rec.override_credit_reason := p_sua_rec.override_credit_reason;
  		gv_table_index := gv_table_index + 1;
  		gt_suaeh_table(gv_table_index) := v_suah_rec;
  		p_table_index := gv_table_index;
  		p_suaeh_table(p_table_index) := v_suah_rec;
        v_suah_rec.uoo_id := p_sua_rec.uoo_id;
  	END;

--commented by syam to avoid adchkdrv errors -dbms_output.put_line(' IN PROCEDURE (DECLARE) END : IGS_FI_GET_SUAEH.finpl_ins_sua_rec');
 EXCEPTION
  WHEN OTHERS THEN
        if SQLCODE <> -20001 then
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
		Fnd_Message.Set_Token('NAME','IGS_FI_GET_SUAEH.FINPL_INS_SUA_REC');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception(Null, Null, fnd_message.get);
        else
                RAISE;
        end if;
  	END finpl_ins_sua_rec;
  -------------------------------------------------------------------------------
  	PROCEDURE finpl_ins_suah_rec (
  		p_suah_rec	r_t_suaeh_dtl,
  		p_sua_rec	IGS_EN_SU_ATTEMPT%ROWTYPE)
  	AS
  	BEGIN
  	DECLARE
  		v_suah_rec	r_t_suaeh_dtl;
  	BEGIN

--commented by syam to avoid adchkdrv errors -dbms_output.put_line(' IN PROCEDURE (DECLARE) START : IGS_FI_GET_SUAEH.finpl_ins_suah_rec');
  		v_suah_rec.person_id := p_suah_rec.person_id;
  		v_suah_rec.course_cd := p_suah_rec.course_cd;
  		v_suah_rec.unit_cd := p_suah_rec.unit_cd;
  		v_suah_rec.version_number := p_suah_rec.version_number;
  		v_suah_rec.cal_type := p_suah_rec.cal_type;
  		v_suah_rec.ci_sequence_number := p_suah_rec.ci_sequence_number;
  		v_suah_rec.hist_start_dt := p_suah_rec.hist_start_dt;
  		v_suah_rec.hist_end_dt := p_suah_rec.hist_end_dt;
  		v_suah_rec.hist_who := p_suah_rec.hist_who;
  		v_suah_rec.location_cd :=
                  	NVL(p_suah_rec.location_cd,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('LOCATION_CD',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id),
  					p_sua_rec.location_cd));
  		v_suah_rec.unit_class :=
  			NVL(p_suah_rec.unit_class ,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('UNIT_CLASS',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id),
  					p_sua_rec.unit_class ));
  		v_suah_rec.enrolled_dt :=
                 		NVL(p_suah_rec.enrolled_dt,
  				NVL(igs_ge_date.igsdate(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('ENROLLED_DT',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id)),
  					p_sua_rec.enrolled_dt));
  		v_suah_rec.unit_attempt_status :=
  			NVL(p_suah_rec.unit_attempt_status,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('UNIT_ATTEMPT_STATUS',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id),
  					p_sua_rec.unit_attempt_status));
  		v_suah_rec.administrative_unit_status :=
  			NVL(p_suah_rec.administrative_unit_status,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('ADMINISTRATIVE_UNIT_STATUS',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id),
  					p_sua_rec.administrative_unit_status));
  		v_suah_rec.discontinued_dt :=
                 		NVL(p_suah_rec.discontinued_dt,
  				NVL(igs_ge_date.igsdate(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('DISCONTINUED_DT',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id)),
  					p_sua_rec.discontinued_dt));
  		v_suah_rec.rule_waived_dt :=
                 		NVL(p_suah_rec.rule_waived_dt,
  				NVL(igs_ge_date.igsdate(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('RULE_WAIVED_DT',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id)),
  					p_sua_rec.rule_waived_dt));
  		v_suah_rec.rule_waived_person_id :=
                 		NVL(p_suah_rec.rule_waived_person_id,
  				NVL(TO_NUMBER(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('RULE_WAIVED_PERSON_ID',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id)),
  					p_sua_rec.rule_waived_person_id));
  		v_suah_rec.no_assessment_ind :=
   			NVL(p_suah_rec.no_assessment_ind,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('NO_ASSESSMENT_IND',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id),
  					p_sua_rec.no_assessment_ind));
  		v_suah_rec.exam_location_cd :=
                  	NVL(p_suah_rec.exam_location_cd,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('EXAM_LOCATION_CD',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id),
  					p_sua_rec.exam_location_cd));
  		v_suah_rec.sup_unit_cd :=
  			NVL(p_suah_rec.sup_unit_cd,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('SUP_UNIT_CD',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id),
  					p_sua_rec.sup_unit_cd));
  		v_suah_rec.sup_version_number :=
          		NVL(p_suah_rec.sup_version_number,
  				NVL(TO_NUMBER(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('SUP_VERSION_NUMBER',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id)),
  					p_sua_rec.sup_version_number));
  		v_suah_rec.alternative_title :=
  			NVL(p_suah_rec.alternative_title,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('ALTERNATIVE_TITLE',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id),
  					p_sua_rec.alternative_title));
  		v_suah_rec.override_enrolled_cp :=
  			NVL(p_suah_rec.override_enrolled_cp,
  				NVL(TO_NUMBER(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('OVERRIDE_ENROLLED_CP',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id)),
  					p_sua_rec.override_enrolled_cp));
  		v_suah_rec.override_eftsu :=
  			NVL(p_suah_rec.override_eftsu,
  				NVL(TO_NUMBER(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('OVERRIDE_EFTSU',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id)),
  					p_sua_rec.override_eftsu));
  		v_suah_rec.override_achievable_cp :=
  			NVL(p_suah_rec.override_achievable_cp,
  				NVL(TO_NUMBER(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('OVERRIDE_ACHIEVABLE_CP',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id)),
  					p_sua_rec.override_achievable_cp));
  		v_suah_rec.override_outcome_due_dt :=
         			NVL(p_suah_rec.override_outcome_due_dt,
  				NVL(igs_ge_date.igsdate(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('OVERRIDE_OUTCOME_DUE_DT',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id)),
  					p_sua_rec.override_outcome_due_dt));
  		v_suah_rec.LAST_UPDATED_BY := p_suah_rec.LAST_UPDATED_BY;
  		v_suah_rec.LAST_UPDATE_DATE := p_suah_rec.LAST_UPDATE_DATE;
  		v_suah_rec.override_credit_reason :=
  			NVL(p_suah_rec.override_credit_reason,
  				NVL(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('OVERRIDE_CREDIT_REASON',
  						p_suah_rec.person_id,
  						p_suah_rec.course_cd,
  						p_suah_rec.hist_end_dt,
                        p_suah_rec.uoo_id),
  					p_sua_rec.override_credit_reason));
  		v_suah_rec.uoo_id := p_suah_rec.uoo_id;
  		gv_table_index := gv_table_index + 1;
  		gt_suaeh_table(gv_table_index) := v_suah_rec;
  		p_table_index := gv_table_index;
  		p_suaeh_table(p_table_index) := v_suah_rec;
  	END;

--commented by syam to avoid adchkdrv errors -dbms_output.put_line(' IN PROCEDURE (DECLARE) END : IGS_FI_GET_SUAEH.finpl_ins_suah_rec');
 EXCEPTION
  WHEN OTHERS THEN
        if SQLCODE <> -20001 then
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
		Fnd_Message.Set_Token('NAME','IGS_FI_GET_SUAEH.FINP_INS_SUAH_REC');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception(Null, Null, fnd_message.get);
        else
                RAISE;
        end if;
  	END finpl_ins_suah_rec;
  -------------------------------------------------------------------------------
  	PROCEDURE finpl_ins_suahv_rec (
  		p_hist_start_dt		IGS_EN_SU_ATTEMPT_H.hist_start_dt%TYPE,
  		p_suahv_rec		IGS_AS_SUA_H_V%ROWTYPE)
  	AS
  	BEGIN
  	DECLARE
  		v_suah_rec	r_t_suaeh_dtl;
  	BEGIN

--commented by syam to avoid adchkdrv errors -dbms_output.put_line(' IN PROCEDURE (DECLARE) START : IGS_FI_GET_SUAEH.finpl_ins_suahv_rec');

  		v_suah_rec.person_id := p_suahv_rec.person_id;
  		v_suah_rec.course_cd := p_suahv_rec.course_cd;
  		v_suah_rec.unit_cd := p_suahv_rec.unit_cd;
  		v_suah_rec.version_number := p_suahv_rec.version_number;
  		v_suah_rec.cal_type := p_suahv_rec.cal_type;
  		v_suah_rec.ci_sequence_number := p_suahv_rec.ci_sequence_number;
  		v_suah_rec.hist_start_dt := p_hist_start_dt;
  		v_suah_rec.hist_end_dt := p_suahv_rec.hist_end_dt;
  		v_suah_rec.hist_who := p_suahv_rec.hist_who;
  		v_suah_rec.location_cd := p_suahv_rec.location_cd;
  		v_suah_rec.unit_class:= p_suahv_rec.unit_class;
  		v_suah_rec.enrolled_dt := p_suahv_rec.enrolled_dt;
  		v_suah_rec.unit_attempt_status := p_suahv_rec.unit_attempt_status;
  		v_suah_rec.administrative_unit_status :=
  			p_suahv_rec.administrative_unit_status;
                  -- v_suah_rec.aus_description :=
  		v_suah_rec.discontinued_dt := p_suahv_rec.discontinued_dt;
  		v_suah_rec.rule_waived_dt := p_suahv_rec.rule_waived_dt;
  		v_suah_rec.rule_waived_person_id := p_suahv_rec.rule_waived_person_id;
     		v_suah_rec.no_assessment_ind := p_suahv_rec.no_assessment_ind;
  		v_suah_rec.exam_location_cd := p_suahv_rec.exam_location_cd;
  		-- v_suah_rec.elo_description :=
  		v_suah_rec.sup_unit_cd := p_suahv_rec.sup_unit_cd;
  		v_suah_rec.sup_version_number := p_suahv_rec.sup_version_number;
  		v_suah_rec.alternative_title := p_suahv_rec.alternative_title;
  		v_suah_rec.override_enrolled_cp := p_suahv_rec.override_enrolled_cp;
  		v_suah_rec.override_eftsu := p_suahv_rec.override_eftsu;
  		v_suah_rec.override_achievable_cp := p_suahv_rec.override_achievable_cp;
  		v_suah_rec.override_outcome_due_dt := p_suahv_rec.override_outcome_due_dt;
  		v_suah_rec.LAST_UPDATED_BY := p_suahv_rec.LAST_UPDATED_BY;
  		v_suah_rec.LAST_UPDATE_DATE := p_suahv_rec.LAST_UPDATE_DATE;
  		v_suah_rec.override_credit_reason := p_suahv_rec.override_credit_reason;
  		v_suah_rec.uoo_id := p_suahv_rec.uoo_id;
  		gv_table_index := gv_table_index + 1;
  		gt_suaeh_table(gv_table_index) := v_suah_rec;
  		p_table_index := gv_table_index;
  		p_suaeh_table(p_table_index) := v_suah_rec;
  	END;

--commented by syam to avoid adchkdrv errors -dbms_output.put_line(' IN PROCEDURE (DECLARE) END : IGS_FI_GET_SUAEH.finpl_ins_suahv_rec');
 EXCEPTION
  WHEN OTHERS THEN
        if SQLCODE <> -20001 then
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
		Fnd_Message.Set_Token('NAME','IGS_FI_GET_SUAEH.FINPL_INS_SUAHV_REC');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception(Null, Null, fnd_message.get);
        else
                RAISE;
        end if;
  	END finpl_ins_suahv_rec;
  -------------------------------------------------------------------------------
  	PROCEDURE finpl_prc_sua_enrhist(
  		p_sua_rec	IN OUT NOCOPY	IGS_EN_SU_ATTEMPT%ROWTYPE)
  	AS
  	BEGIN
  	DECLARE
  		CURSOR c_suahv_last_enr (
  				cp_course_cd	 IGS_PS_COURSE.course_cd%TYPE,
  				cp_unit_cd	 IGS_PS_UNIT.unit_cd%TYPE,
  				cp_effective_dt	DATE) IS
  			SELECT	*
  			FROM	IGS_AS_SUA_H_V	suahv
  			WHERE	suahv.person_id = p_person_id AND
  				suahv.course_cd = cp_course_cd AND
  				suahv.unit_cd = cp_unit_cd AND
  				suahv.unit_attempt_status = 'ENROLLED' AND
  				cp_effective_dt	<= suahv.hist_start_dt
  			ORDER BY suahv.hist_start_dt desc;
  		r_suahv		IGS_AS_SUA_H_V%ROWTYPE;
  	BEGIN
  		-- check the last enrolled history for a match
--commented by syam to avoid adchkdrv errors -dbms_output.put_line(' IN PROCEDURE (DECLARE) START : IGS_FI_GET_SUAEH.finpl_prc_sua_enrhist');

  		OPEN	c_suahv_last_enr(
  					p_sua_rec.course_cd,
  					p_sua_rec.unit_cd,
  					p_sua_rec.enrolled_dt);
  		FETCH	c_suahv_last_enr INTO	r_suahv;
  		IF (c_suahv_last_enr%FOUND) THEN
  			CLOSE	c_suahv_last_enr;
  			IF TRUNC(gv_effective_dt) <= TRUNC(r_suahv.hist_end_dt) THEN
  				-- save the SUA history data when last enrolled
  				finpl_ins_suahv_rec(
  						p_sua_rec.enrolled_dt,
  						r_suahv);
  			ELSE
  				-- save the current student IGS_PS_UNIT attempt data
  				finpl_ins_sua_rec(
  						r_suahv.hist_end_dt,
  						SYSDATE,
  						p_sua_rec);
  			END IF;
  		ELSE -- missing enrolment history
  			CLOSE	c_suahv_last_enr;
  			-- check if the effective date falls within the period
  			-- of the current student IGS_PS_UNIT attempt values
  			IF TRUNC(gv_effective_dt) >= TRUNC(p_sua_rec.LAST_UPDATE_DATE) THEN
  				-- save the current sua data
  				finpl_ins_sua_rec(
  						p_sua_rec.LAST_UPDATE_DATE,
  						SYSDATE,
  						p_sua_rec);
  			ELSE
  				-- simulate an enrolment history
  				p_sua_rec.unit_attempt_status := 'ENROLLED';
  				finpl_ins_sua_rec(
  						p_sua_rec.enrolled_dt,
  						p_sua_rec.LAST_UPDATE_DATE,
  						p_sua_rec);
  			END IF;
  		END IF;
  	END;

--commented by syam to avoid adchkdrv errors -dbms_output.put_line(' IN PROCEDURE (DECLARE) END : IGS_FI_GET_SUAEH.finpl_prc_sua_enrhist');
 EXCEPTION
  WHEN OTHERS THEN
        if SQLCODE <> -20001 then
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
		Fnd_Message.Set_Token('NAME','IGS_FI_GET_SUAEH.FINPL_PRC_SUA_ENRHIST');
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception(Null, Null, fnd_message.get);
        else
                RAISE;
        end if;
  	END finpl_prc_sua_enrhist;
  -------------------------------------------------------------------------------
  BEGIN	-- finp_get_suaeh
  	-- effective history logic is based upon the following assumptions -
  	-- the transitions between IGS_PS_UNIT status's are;
  	--	UNCONFIRM -> ENROLLED
  	--
  	--	ENROLLED  -> UNCONFIRM
  	--		  -> DISCONTIN
  	--		  -> INVALID
  	--		  -> COMPLETED
  	--
  	--	INVALID	  -> ENROLLED
  	--		  -> DISCONTIN
  	--
  	--	DISCONTIN -> ENROLLED
  	--		  -> DUPLICATE (transfer from another SCA)
  	--
  	--	COMPLETED -> ENROLLED
  	--		  -> DUPLICATE (transfer from another SCA)
  	--
  	--	DUPLICATE -> DUPLICATE
  	--
  	-- the effective history transitions are;
  	--	UNCONFIRM -> ENROLLED -> COMPLETED
  	--	UNCONFIRM -> ENROLLED -> DISCONTIN
  	-- check parameters

--commented by syam to avoid adchkdrv errors -dbms_output.put_line(' IN PROCEDURE START : IGS_FI_GET_SUAEH.finp_get_suaeh');

    	IF p_person_id IS NULL OR
    		p_effective_dt IS NULL THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	  IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception(Null, Null, fnd_message.get);
    	END IF;
  	-- check if the effective history has already been captured
  	IF gv_person_id IS NOT NULL AND
  		gv_effective_dt IS NOT NULL THEN
  		IF gv_table_index > 0 THEN
  			IF gv_person_id = p_person_id AND
  				NVL(gv_course_cd,'NULL') = NVL(p_course_cd,'NULL') AND
  				NVL(gv_unit_cd,'NULL') = NVL(p_unit_cd,'NULL') AND
  				TRUNC(gv_effective_dt) = TRUNC(p_effective_dt) THEN
  				FOR p_table_index IN 1..gv_table_index
  				LOOP
  					p_suaeh_table(p_table_index) := gt_suaeh_table(p_table_index);
  				END LOOP;
  				p_table_index := gv_table_index;
  				RETURN;
  			END IF;
  		END IF;
  	END IF;
  	-- initialise data
  	gt_suaeh_table := gt_empty_table;
  	gv_table_index := 0;
  	gv_person_id := p_person_id;
  	gv_course_cd := p_course_cd;
  	gv_unit_cd := p_unit_cd;
  	gv_effective_dt := igs_ge_date.igsdate(igs_ge_date.igschar(p_effective_dt)|| '23:59:59');
  	-- get the current student IGS_PS_UNIT attempt detail
  	FOR v_sua_rec IN c_sua
  	LOOP
  		r_sua := v_sua_rec;
  		-- check if effective date is set today or into the future
  		IF TRUNC(gv_effective_dt) >= TRUNC(SYSDATE) THEN
  			IF r_sua.unit_attempt_status IN (
  							'COMPLETED',
  							'ENROLLED',
  							'INVALID') THEN
  				-- check if commencing on or before the effective date
  				IF TRUNC(r_sua.enrolled_dt) <= TRUNC(gv_effective_dt) THEN
  					-- save the current student IGS_PS_UNIT attempt data
  					finpl_ins_sua_rec(
  						r_sua.enrolled_dt,
  						gv_effective_dt,
  						r_sua);
  				ELSE
  					-- save the current student IGS_PS_UNIT attempt data as an
  					-- unconfirmed history
  					r_sua.unit_attempt_status := 'UNCONFIRM';
  					finpl_ins_sua_rec(
  						gv_effective_dt,
  						r_sua.enrolled_dt,
  						r_sua);
  				END IF;
  			ELSIF r_sua.unit_attempt_status = 'DISCONTIN' THEN
  				-- save the current student IGS_PS_UNIT attempt data
  				finpl_ins_sua_rec(
  						r_sua.discontinued_dt,
  						gv_effective_dt,
  						r_sua);
  			ELSIF r_sua.unit_attempt_status = 'UNCONFIRM' THEN
  				-- save the current student IGS_PS_UNIT attempt data
  				finpl_ins_sua_rec(
  						r_sua.LAST_UPDATE_DATE,
  						gv_effective_dt,
  						r_sua);
  			ELSE	-- unrecognised status
              Fnd_Message.Set_Name ('IGS', 'IGS_FI_UNRECOG_SUA_STATUS');
	      IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception(Null, Null, fnd_message.get);
  			END IF;
  		ELSE	-- processing history effective up until the current day
  			-- check if effective date falls within the current SUA history
  			OPEN	c_suah(	r_sua.course_cd,
  					r_sua.unit_cd,
  					gv_effective_dt);
  			FETCH	c_suah	INTO	r_suah;
  			IF (c_suah%FOUND) THEN
  				v_suah_found := TRUE;
  				IF r_suah.unit_attempt_status IS NULL THEN
  					r_suah.unit_attempt_status :=
  						NVL(IGS_AU_GEN_003.AUDP_GET_SUAH_COL('UNIT_ATTEMPT_STATUS',
  								r_suah.person_id,
  								r_suah.course_cd,
  								r_suah.hist_end_dt,
                                r_suah.uoo_id),
  							r_sua.unit_attempt_status);
  				END IF;
  			ELSE
  				v_suah_found := FALSE;
  			END IF;
  			CLOSE	c_suah;
  			IF r_sua.unit_attempt_status = 'ENROLLED' THEN
  				-- check if the effective date falls within the effective
  				-- enrolled period
  				IF TRUNC(gv_effective_dt) >= TRUNC(r_sua.enrolled_dt) THEN
  					IF v_suah_found = TRUE THEN
  						IF r_suah.unit_attempt_status IN ('ENROLLED') THEN
  							-- save the sua history data
  							finpl_ins_suah_rec(
  									r_suah,
  									r_sua);
  						ELSE	-- enrolment overrides history
  							-- save the current sua data
  							finpl_ins_sua_rec(r_sua.enrolled_dt,
  									SYSDATE,
  									r_sua);
  						END IF;
  					ELSE	-- no matching history
  						-- save the current sua data
  						finpl_ins_sua_rec(r_sua.enrolled_dt,
  								SYSDATE,
  								r_sua);
  					END IF;
  				ELSE -- prior to student IGS_PS_UNIT attempt enrolment
  					IF v_suah_found = TRUE THEN
  						IF r_suah.unit_attempt_status IN ('UNCONFIRM') THEN
  							-- save the sua history data
  							finpl_ins_suah_rec(
  									r_suah,
  									r_sua);
  						ELSE
  							RETURN;
  						END IF;
  					ELSE
  						RETURN;
  					END IF;
  				END IF;
  			ELSIF r_sua.unit_attempt_status = 'COMPLETED' THEN
  				-- check if the effective date falls within the effective
  				-- enrolled period
  				IF TRUNC(gv_effective_dt) >= TRUNC(r_sua.enrolled_dt) THEN
  					IF v_suah_found = TRUE THEN
  						IF r_suah.unit_attempt_status IN (
  										'COMPLETED',
  										'ENROLLED') THEN
  							-- save the sua history data
  							finpl_ins_suah_rec(
  									r_suah,
  									r_sua);
  						ELSE	-- not an expected history
  							-- assume ENROLLED -> COMPLETED
  							-- use the last enrolled history
  							finpl_prc_sua_enrhist(r_sua);
  						END IF;
  					ELSE	-- no matching history
  						-- assume ENROLLED -> COMPLETED
  						-- use the last enrolled history
  						finpl_prc_sua_enrhist(r_sua);
  					END IF;
  				ELSE -- prior to student IGS_PS_UNIT attempt enrolment
  					IF v_suah_found = TRUE THEN
    						IF r_suah.unit_attempt_status IN ('UNCONFIRM') THEN
  							-- save the sua history data
  							finpl_ins_suah_rec(
  									r_suah,
  									r_sua);
  						ELSE
  							RETURN;
  						END IF;
  					ELSE
    						RETURN;  -- no history
  					END IF;
  				END IF;
  			ELSIF r_sua.unit_attempt_status = 'DISCONTIN' THEN
  				-- check if the effective date falls within the effective
  				-- discontinuation period
  				IF TRUNC(gv_effective_dt) >= TRUNC(r_sua.discontinued_dt) THEN
  					IF v_suah_found = TRUE THEN
  						IF r_suah.unit_attempt_status = 'DISCONTIN' THEN
  							-- save the sua history data
  							finpl_ins_suah_rec(
  									r_suah,
  									r_sua);
  						ELSE	-- discontinuation overrides the history
  							-- save the current sua data
  							finpl_ins_sua_rec(r_sua.discontinued_dt,
  									SYSDATE,
  									r_sua);
  						END IF;
  					ELSE	-- no matching history
  						-- save the current sua data
  						finpl_ins_sua_rec(r_sua.discontinued_dt,
  								SYSDATE,
  								r_sua);
  					END IF;
  				ELSE -- prior to student IGS_PS_UNIT attempt discontinuation
  					IF gv_effective_dt >= TRUNC(r_sua.enrolled_dt) THEN
  						-- within the enrolled period
  						IF v_suah_found = TRUE THEN
  							IF r_suah.unit_attempt_status IN (
  										'ENROLLED',
  										'INVALID') THEN
  								-- save the SUA history data
  								finpl_ins_suah_rec(
  										r_suah,
  										r_sua);
  							ELSE	-- not an expected history
  								-- assume  ENROLLED -> DISCONTIN
  								-- use the last enrolled history
  								finpl_prc_sua_enrhist(r_sua);
  							END IF;
  						ELSE	-- no matching history
  							-- assume  ENROLLED -> DISCONTIN
  							-- use the last enrolled history
  							finpl_prc_sua_enrhist(r_sua);
  						END IF;
  					ELSE	-- prior to student IGS_PS_UNIT attempt enrolment
  						IF v_suah_found = TRUE THEN
    							IF r_suah.unit_attempt_status IN (
  										'UNCONFIRM') THEN
  								-- save the SUA history data
  								finpl_ins_suah_rec(
  										r_suah,
  										r_sua);
  							ELSE
  								RETURN;
  							END IF;
  						ELSE
    							RETURN;  -- no history
  						END IF;
  					END IF;
    				END IF;
  			ELSIF r_sua.unit_attempt_status = 'UNCONFIRM' THEN
  				IF v_suah_found = TRUE THEN
  					IF r_suah.unit_attempt_status = 'UNCONFIRM' THEN
  						-- save the sua history data
  						finpl_ins_suah_rec(
  								r_suah,
  								r_sua);
  					ELSE	-- unconfirm overrides history
  						-- save the current sua data
  						finpl_ins_sua_rec(
  								gv_effective_dt,
  								SYSDATE,
  								r_sua);
  					END IF;
  				ELSE	-- no matching history
  					-- check if the effective date falls within the
  					-- period the sua was created and today
  					IF TRUNC(gv_effective_dt) >= TRUNC(r_sua.LAST_UPDATE_DATE) THEN
  						-- save the current sua data
  						finpl_ins_sua_rec(
  								r_sua.LAST_UPDATE_DATE,
  								SYSDATE,
  								r_sua);
  					ELSE -- prior to student IGS_PS_UNIT attempt record creation
  						RETURN;
  					END IF;
  				END IF;
  			ELSIF r_sua.unit_attempt_status = 'INVALID' THEN
  				-- check if the effective date falls within the effective
  				-- enrolled period
  				IF TRUNC(gv_effective_dt) >= TRUNC(r_sua.enrolled_dt) THEN
  					IF v_suah_found = TRUE THEN
  						IF r_suah.unit_attempt_status IN (
  										'INVALID',
  										'ENROLLED') THEN
  							-- save the sua history data
  							finpl_ins_suah_rec(
  									r_suah,
  									r_sua);
  						ELSE	-- not an expected history
  							-- assume ENROLLED -> INVALID
  							-- use the last enrolled history
  							finpl_prc_sua_enrhist(r_sua);
  						END IF;
  					ELSE	-- no matching history
  						-- assume ENROLLED -> INVALID
  						-- use the last enrolled history
  						finpl_prc_sua_enrhist(r_sua);
  					END IF;
  				ELSE	-- prior to student IGS_PS_UNIT attempt enrolment
  					IF v_suah_found = TRUE THEN
    						IF r_suah.unit_attempt_status IN ('UNCONFIRM') THEN
  							-- save the SUA history data
    							finpl_ins_suah_rec(
    									r_suah,
    									r_sua);
  						ELSE
  							RETURN;
  						END IF;
  					ELSE
    						RETURN;
  					END IF;
  				END IF;
  			ELSIF r_sua.unit_attempt_status = 'DUPLICATE' THEN
  				-- check if the effective date falls within the original
  				-- effective discontinuation or enrolled period
  				IF TRUNC(gv_effective_dt) >= NVL(TRUNC(r_sua.discontinued_dt),
  								TRUNC(r_sua.enrolled_dt)) THEN
  					IF v_suah_found = TRUE THEN
  						IF r_suah.unit_attempt_status IN (
  										'DUPLICATE') THEN
  							-- save the sua history data
  							finpl_ins_suah_rec(
  									r_suah,
  									r_sua);
  						ELSE	-- not an expected history
  							RETURN;  -- no history
  						END IF;
  					ELSE	-- no matching history
  						-- save the current sua data
  						finpl_ins_sua_rec(
  							NVL(r_sua.discontinued_dt, r_sua.enrolled_dt),
  							SYSDATE,
  							r_sua);
  					END IF;
  				ELSE 	-- prior to original student IGS_PS_UNIT attempt
  					-- dicontinuation/enrolment
  					RETURN;  -- no history
  				END IF;
  			ELSE	-- unrecognised status
              Fnd_Message.Set_Name ('IGS', 'IGS_FI_UNRECOG_SUA_STATUS');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception(Null, Null, fnd_message.get);
  			END IF;
  		END IF;
  	END LOOP;
  END;

--commented by syam to avoid adchkdrv errors -dbms_output.put_line(' IN PROCEDURE END : IGS_FI_GET_SUAEH.finp_get_suaeh');
 EXCEPTION
WHEN OTHERS THEN
	if SQLCODE <> -20001 then
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_FI_GET_SUAEH.FINP_GET_SUAEH');
		IGS_GE_MSG_STACK.ADD;
		lv_param_values := to_char(p_person_id)||','||
		  p_course_cd||','||p_unit_cd||','||
		  igs_ge_date.igschardt(p_effective_dt);
		 FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARAMETERS');
		 FND_MESSAGE.SET_TOKEN('VALUE',lv_param_values);
		 IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception(Null, Null, fnd_message.get);
        else
                RAISE;
        end if;
  END finp_get_suaeh;
END IGS_FI_GET_SUAEH;

/
