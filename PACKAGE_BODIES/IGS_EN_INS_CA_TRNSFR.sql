--------------------------------------------------------
--  DDL for Package Body IGS_EN_INS_CA_TRNSFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_INS_CA_TRNSFR" AS
/* $Header: IGSEN17B.pls 115.6 2002/11/28 23:53:54 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_ge_gen_004.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------
  -- Insert CAFOS as part of course Transfer.
  FUNCTION ENRP_INS_CAFOSTRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	-- enrp_ins_cafostrnsfr
  	-- This module inserts research IGS_RE_CDT_FLD_OF_SY details as a result of
  	--course transfer. All Candidature research supervisor details
  	--(p_person_id/p_transfer_ca_sequence_number) are to be copied to the
  	--new Candidature (p_person_id/p_ca_sequence_number).
  DECLARE
  	v_cafos_exists				VARCHAR2(1);
  	cst_enrp_ins_ca_trnsfr	CONSTANT	VARCHAR2(18) := 'ENRP_INS_CA_TRNSFR';
  	CURSOR c_cafos IS
  		SELECT	'x'
  		FROM	IGS_RE_CDT_FLD_OF_SY cafos
  		WHERE	cafos.person_id			= p_person_id AND
  			cafos.ca_sequence_number	= p_ca_sequence_number;
  	CURSOR c_cafos1 IS
  		SELECT	cafos.field_of_study,
  			cafos.percentage
  		FROM	IGS_RE_CDT_FLD_OF_SY cafos
  		WHERE	cafos.person_id		= p_person_id AND
  			cafos.ca_sequence_number	= p_transfer_ca_sequence_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	--Check for existence of transfer session details
  	IF igs_as_val_suaap.genp_val_sdtt_sess(
  			cst_enrp_ins_ca_trnsfr) = TRUE THEN
  		--Not processing course transfer Candidature, finish processing
  		RETURN TRUE;
  	END IF;
  	--Validate that Candidature field of study details have not already
  	-- been transferred
  	OPEN c_cafos;
  	FETCH c_cafos INTO v_cafos_exists;
  	IF c_cafos%FOUND THEN
  		CLOSE c_cafos;
  		--Candidature field of study details already exist, cannot transfer
  		p_message_name := 'IGS_RE_CAND_FIELD_STUDY_EXIST';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cafos;
  	SAVEPOINT sp_cand_field_of_study;
  	--Insert Candidature field of study details
  	FOR v_cafos1_rec IN c_cafos1 LOOP
  		BEGIN
                  DECLARE
                           l_rowid VARCHAR2(25);
                  BEGIN
  			IGS_RE_CDT_FLD_OF_SY_PKG.INSERT_ROW(
                                x_rowid =>  l_rowid,
  				x_person_id => p_person_id,
  				x_ca_sequence_number => p_ca_sequence_number,
  				x_field_of_study => v_cafos1_rec.field_of_study,
  				x_percentage => v_cafos1_rec.percentage );
                   END;

  		EXCEPTION
  			WHEN OTHERS THEN
  				ROLLBACK TO sp_cand_field_of_study;
  				p_message_name := 'IGS_RE_CANT_INS_CAND_FLD_STDY';
  				RETURN FALSE;
  		END;
  	END LOOP; --(IGS_RE_CDT_FLD_OF_SY)
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_cafos%ISOPEN THEN
  			CLOSE c_cafos;
  		END IF;
  		IF c_cafos1%ISOPEN THEN
  			CLOSE c_cafos1;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_INS_CA_TRNSFR.enrp_ins_cafostrnsfr');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END enrp_ins_cafostrnsfr;
  --
  -- Insert CAH as part of course Transfer.
  FUNCTION ENRP_INS_CAH_TRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	-- enrp_ins_cah_trnsfr
  	--This module inserts research IGS_RE_CDT_ATT_HIST details as a result of
  	--course transfer. All Candidature research supervisor details
  	--(p_person_id/p_transfer_ca_sequence_number) are to be copied to the new
  	--Candidature (p_person_id/p_ca_sequence_number).
  DECLARE
  	cst_enrp_ins_ca_trnsfr	CONSTANT	VARCHAR2(18) := 'ENRP_INS_CA_TRNSFR';
  	v_cah_exists				VARCHAR2(1);
  	CURSOR c_cah IS
  		SELECT	'x'
  		FROM	IGS_RE_CDT_ATT_HIST cah
  		WHERE	cah.person_id		= p_person_id AND
  			cah.sequence_number	= p_ca_sequence_number;
  	CURSOR c_cah1 IS
  		SELECT	cah.sequence_number,
  			cah.hist_start_dt,
  			cah.hist_end_dt,
  			cah.attendance_type,
  			cah.attendance_percentage
  		FROM	IGS_RE_CDT_ATT_HIST cah
  		WHERE	cah.person_id		= p_person_id AND
  			cah.ca_sequence_number	= p_transfer_ca_sequence_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	--Check for existence of transfer session details
  	IF igs_as_val_suaap.genp_val_sdtt_sess(
  			cst_enrp_ins_ca_trnsfr) = TRUE THEN
  		--Not processing course transfer Candidature, finish processing
  		RETURN TRUE;
  	END IF;
  	--Validate that Candidature attendance history details have not already
  	-- been transferred
  	OPEN c_cah;
  	FETCH c_cah INTO v_cah_exists;
  	IF c_cah%FOUND THEN
  		CLOSE c_cah;
  		--Candidature attendance histories already exist, cannot transfer
  		p_message_name := 'IGS_RE_CAND_ATTN_HIST_EXISTS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_cah;
  	SAVEPOINT sp_candidature_att_hist;
  	--Insert Candidature attendance histories
  	FOR v_cah1_rec IN c_cah1 LOOP
  		BEGIN
                DECLARE
                            l_rowid VARCHAR2(25);
			    l_org_id NUMBER(15) := IGS_GE_GEN_003.GET_ORG_ID;
                BEGIN
  			IGS_RE_CDT_ATT_HIST_PKG.INSERT_ROW(
                                X_ROWID => l_rowid,
                                X_org_id => l_org_id,
  				X_person_id => p_person_id,
  				X_ca_sequence_number => p_ca_sequence_number,
  				X_sequence_number => v_cah1_rec.sequence_number,
  				X_hist_start_dt => v_cah1_rec.hist_start_dt ,
  				X_hist_end_dt => v_cah1_rec.hist_end_dt,
  				X_attendance_type => v_cah1_rec.attendance_type,
  				X_attendance_percentage => v_cah1_rec.attendance_percentage);
                END;

  		EXCEPTION
  			WHEN OTHERS THEN
  				ROLLBACK TO sp_candidature_att_hist;
  				p_message_name := 'IGS_RE_CANT_INS_CAND_ATTN_HIS';
  				RETURN FALSE;
  		END;
  	END LOOP; --(IGS_RE_CDT_ATT_HIST)
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_cah%ISOPEN THEN
  			CLOSE c_cah;
  		END IF;
  		IF c_cah1%ISOPEN THEN
  			CLOSE c_cah1;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_INS_CA_TRNSFR.enrp_ins_cah_trnsfr');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  			  END enrp_ins_cah_trnsfr;
  --
  -- Insert CSC as part of course Transfer.
  FUNCTION ENRP_INS_CSC_TRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	-- enrp_ins_csc_trnsfr
  	--This module inserts research IGS_RE_CAND_SEO_CLS details as a result of IGS_PS_COURSE
  	-- transfer. All Candidature research supervisor details
  	--(p_person_id/p_transfer_ca_sequence_number) are to be copied to the new
  	--Candidature (p_person_id/p_ca_sequence_number).
  DECLARE
  	v_csc_exists				VARCHAR2(1);
  	cst_enrp_ins_ca_trnsfr	CONSTANT	VARCHAR2(18) := 'ENRP_INS_CA_TRNSFR';
  	CURSOR c_csc IS
  		SELECT	'x'
  		FROM	IGS_RE_CAND_SEO_CLS csc
  		WHERE	csc.person_id		= p_person_id AND
  			csc.ca_sequence_number	= p_ca_sequence_number;
  	CURSOR c_csc1 IS
  		SELECT	csc.seo_class_cd,
  			csc.percentage
  		FROM	IGS_RE_CAND_SEO_CLS csc
  		WHERE	csc.person_id		= p_person_id AND
  			csc.ca_sequence_number	= p_transfer_ca_sequence_number;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	--Check for existence of transfer session details
  	IF igs_as_val_suaap.genp_val_sdtt_sess(
  			cst_enrp_ins_ca_trnsfr) = TRUE THEN
  		--Not processing course transfer Candidature, finish processing
  		RETURN TRUE;
  	END IF;
  	--Validate that Candidature socio-economic classification details have not
  	-- already been transferred
  	OPEN c_csc;
  	FETCH c_csc INTO v_csc_exists;
  	IF c_csc%FOUND THEN
  		CLOSE c_csc;
  		--Candidature socio-economic classification details already exist,
  		-- cannot transfer
  		p_message_name := 'IGS_RE_CAND_ECON_CLASS_EXISTS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_csc;
  	SAVEPOINT sp_cand_seo_class;
  	--Insert Candidature socio-economic classification details
  	FOR v_csc1_rec IN c_csc1 LOOP
  		BEGIN
                  DECLARE
                             l_rowid VARCHAR2(25);
                  BEGIN
 			IGS_RE_CAND_SEO_CLS_PKG.INSERT_ROW(
                                x_rowid => l_rowid,
  				x_person_id => p_person_id,
  				x_ca_sequence_number => p_ca_sequence_number,
  				x_seo_class_cd => v_csc1_rec.seo_class_cd,
  				x_percentage =>v_csc1_rec.percentage );
                  END;

  		EXCEPTION
  			WHEN OTHERS THEN
  				ROLLBACK TO sp_cand_seo_class;
  				p_message_name := 'IGS_RE_CANT_INS_CAND_SCO-ECON';
  				RETURN FALSE;
  		END;
  	END LOOP;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_csc%ISOPEN THEN
  			CLOSE c_csc;
  		END IF;
  		IF c_csc1%ISOPEN THEN
  			CLOSE c_csc1;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_INS_CA_TRNSFR.enrp_ins_csc_trnsfr');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END enrp_ins_csc_trnsfr;
  --
  -- Insert SCH as part of course Transfer.
  FUNCTION ENRP_INS_MIL_TRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	-- enrp_ins_mil_trnsfr
  	--This module inserts research milestone details as a result of COURSE
  	--transfer. All Candidature milestone details
  	--(p_person_id/p_transfer_ca_sequence_number) are to be copied to the new
  	--Candidature (p_person_id/p_ca_sequence_number).
  DECLARE
  	v_mil_exists				VARCHAR2(1);
  	cst_enrp_ins_ca_trnsfr	CONSTANT	VARCHAR2(18) := 'ENRP_INS_CA_TRNSFR';
  	CURSOR c_mil IS
  		SELECT	'x'
  		FROM	IGS_PR_MILESTONE mil
  		WHERE	mil.person_id		= p_person_id AND
  			mil.sequence_number	= p_ca_sequence_number;
  	CURSOR c_mil1 IS
  		SELECT	mil.sequence_number,
  			mil.milestone_type,
  			mil.milestone_status,
  			mil.due_dt,
  			mil.description,
  			mil.actual_reached_dt,
  			mil.preced_sequence_number,
  			mil.ovrd_ntfctn_imminent_days,
  			mil.ovrd_ntfctn_reminder_days,
  			mil.ovrd_ntfctn_re_reminder_days,
  			mil.comments
  		FROM	IGS_PR_MILESTONE mil
  		WHERE	mil.person_id		= p_person_id AND
  			mil.ca_sequence_number	= p_transfer_ca_sequence_number
  		ORDER BY mil.due_dt;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	--Check for existence of transfer session details
  	IF igs_as_val_suaap.genp_val_sdtt_sess(
  					'ENRP_INS_CA_TRNSFR') = TRUE THEN
  		--Not processing course transfer Candidature, finish processing
  		RETURN TRUE;
  	END IF;
  	--Validate that milestone details have not already been transferred
  	OPEN c_mil;
  	FETCH c_mil INTO v_mil_exists;
  	IF c_mil%FOUND THEN
  		CLOSE c_mil;
  		--milestone details already exist, cannot transfer
  		p_message_name := 'IGS_RE_MILESTONE_ALREADY_EXIS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_mil;
  	SAVEPOINT sp_milestone;
   	--Insert milestone
  	BEGIN 	--Insert IGS_PR_MILESTONE
  		FOR v_mil1_rec IN c_mil1 LOOP
                  DECLARE
                             l_rowid VARCHAR2(25);
			    l_org_id NUMBER(15) := IGS_GE_GEN_003.GET_ORG_ID;
                  BEGIN
  			IGS_PR_MILESTONE_PKG.INSERT_ROW(
                                        x_rowid => l_rowid,
                                	X_org_id => l_org_id,
  					x_person_id => p_person_id,
  					x_ca_sequence_number => p_ca_sequence_number,
  					x_sequence_number => v_mil1_rec.sequence_number,
  					x_milestone_type => v_mil1_rec.milestone_type,
  					x_milestone_status => v_mil1_rec.milestone_status,
  					x_due_dt => v_mil1_rec.due_dt,
  					x_description => v_mil1_rec.description,
  					x_actual_reached_dt => v_mil1_rec.actual_reached_dt,
  					x_preced_sequence_number => v_mil1_rec.preced_sequence_number,
  					x_ovrd_ntfctn_imminent_days => v_mil1_rec.ovrd_ntfctn_imminent_days,
  					x_ovrd_ntfctn_reminder_days => v_mil1_rec.ovrd_ntfctn_reminder_days,
  					x_ovrd_ntfctn_re_reminder_days => v_mil1_rec.ovrd_ntfctn_re_reminder_days,
  					x_comments => v_mil1_rec.comments );
                     END;

  			END LOOP; --(IGS_PR_MILESTONE)
  	EXCEPTION
  		WHEN OTHERS THEN		-- (exception)
  			ROLLBACK TO sp_milestone;
  			p_message_name := 'IGS_RE_CANT_INSERT_MILESTONES';
  			RETURN FALSE;
  	END;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_mil%ISOPEN THEN
  			CLOSE c_mil;
  		END IF;
  		IF c_mil1%ISOPEN THEN
  			CLOSE c_mil1;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_INS_CA_TRNSFR.enrp_ins_mil_trnsfr');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END enrp_ins_mil_trnsfr;
  --
  -- Insert RSUP as part of course Transfer.
  FUNCTION ENRP_INS_RSUP_TRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	--enrp_ins_rsup_trnsfr
  DECLARE
  	v_rsup_exists				VARCHAR2(1);
  	cst_enrp_ins_ca_trnsfr	CONSTANT	VARCHAR2(18) := 'ENRP_INS_CA_TRNSFR';
  	CURSOR c_rsup IS
  		SELECT	'x'
  		FROM	IGS_RE_SPRVSR rsup
  		WHERE	rsup.ca_person_id	= p_person_id AND
  			rsup.ca_sequence_number	= p_ca_sequence_number;
  	CURSOR c_rsup1 IS
  		SELECT	rsup.person_id,
  			rsup.sequence_number,
  			rsup.start_dt,
  			rsup.end_dt,
  			rsup.research_supervisor_type,
  			rsup.supervisor_profession,
  			rsup.supervision_percentage,
  			rsup.funding_percentage,
  			rsup.org_unit_cd,
  			rsup.ou_start_dt,
  			rsup.replaced_person_id,
  			rsup.replaced_sequence_number,
  			rsup.comments
  		FROM	IGS_RE_SPRVSR rsup
  		WHERE	rsup.ca_person_id	= p_person_id AND
  			rsup.ca_sequence_number	= p_transfer_ca_sequence_number
  		ORDER BY rsup.start_dt;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	--Check for existence of transfer session details
  	IF igs_as_val_suaap.genp_val_sdtt_sess(
  			cst_enrp_ins_ca_trnsfr) = TRUE THEN
  		--Not processing course transfer Candidature, finish processing
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	--Validate that IGS_RE_SPRVSR details have not already been transferred
  	OPEN c_rsup;
  	FETCH c_rsup INTO v_rsup_exists;
  	IF c_rsup%FOUND THEN
  		CLOSE c_rsup;
  		--IGS_RE_SPRVSR details already exist, cannot transfer
  		p_message_name := 'IGS_RE_SUPERVISORS_EXISTS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_rsup;
  	SAVEPOINT sp_research_supervisor;
  	--Insert IGS_RE_SPRVSR details
  	FOR v_rsup1_rec IN c_rsup1 LOOP
  		BEGIN
               DECLARE
                          l_rowid VARCHAR2(25);
               BEGIN
  			IGS_RE_SPRVSR_PKG.INSERT_ROW(
                                x_rowid => l_rowid,
  				x_ca_person_id => p_person_id,
  				x_ca_sequence_number =>p_ca_sequence_number ,
  				x_person_id =>   v_rsup1_rec.person_id,
  				x_sequence_number => v_rsup1_rec.sequence_number,
  				x_start_dt => v_rsup1_rec.start_dt,
  				x_end_dt => v_rsup1_rec.end_dt,
  				x_research_supervisor_type => v_rsup1_rec.research_supervisor_type,
  				x_supervisor_profession => v_rsup1_rec.supervisor_profession,
  				x_supervision_percentage => v_rsup1_rec.supervision_percentage,
  				x_funding_percentage => v_rsup1_rec.funding_percentage,
  				x_org_unit_cd => v_rsup1_rec.org_unit_cd,
  				x_ou_start_dt => v_rsup1_rec.ou_start_dt ,
  				x_replaced_person_id => v_rsup1_rec.replaced_person_id,
  				x_replaced_sequence_number => v_rsup1_rec.replaced_sequence_number,
  				x_comments  => v_rsup1_rec.comments);

                 END;


  		EXCEPTION
  			WHEN OTHERS THEN
  				ROLLBACK TO sp_research_supervisor;
  				p_message_name := 'IGS_RE_SUPERVISORS_CANT_INSER';
  				RETURN FALSE;
  		END;
  	END LOOP; --(IGS_RE_SPRVSR)
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_rsup%ISOPEN THEN
  			CLOSE c_rsup;
  		END IF;
  		IF c_rsup1%ISOPEN THEN
  			CLOSE c_rsup1;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_INS_CA_TRNSFR.enrp_ins_rsup_trnsfr');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END enrp_ins_rsup_trnsfr;
  --
  -- Insert SCH as part of course Transfer.
  FUNCTION ENRP_INS_SCH_TRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	-- enrp_ins_sch_trnsfr
  	--This module inserts research IGS_RE_SCHOLARSHIP details as a
  	--result of course transfer.
  DECLARE
  	cst_enrp_ins_ca_trnsfr	CONSTANT	VARCHAR2(18) := 'ENRP_INS_CA_TRNSFR';
  	v_sch_exists				VARCHAR2(1);
  	v_sch1_scholarship_type			IGS_RE_SCHOLARSHIP.scholarship_type%TYPE;
  	v_sch1_start_dt				IGS_RE_SCHOLARSHIP.start_dt%TYPE;
  	v_sch1_end_dt				IGS_RE_SCHOLARSHIP.end_dt%TYPE;
  	v_sch1_dollar_value			IGS_RE_SCHOLARSHIP.dollar_value%TYPE;
  	v_sch1_description			IGS_RE_SCHOLARSHIP.description%TYPE;
  	v_sch1_other_benefits			IGS_RE_SCHOLARSHIP.other_benefits%TYPE;
  	v_sch1_conditions			IGS_RE_SCHOLARSHIP.conditions%TYPE;
  	CURSOR c_sch IS
  		SELECT	'x'
  		FROM	IGS_RE_SCHOLARSHIP sch
  		WHERE	sch.person_id		= p_person_id AND
  			sch.ca_sequence_number	= p_ca_sequence_number;
  	CURSOR c_sch1 IS
  		SELECT	sch.scholarship_type,
  			sch.start_dt,
  			sch.end_dt,
  			sch.dollar_value,
  			sch.description,
  			sch.other_benefits,
  			sch.conditions
  		FROM 	IGS_RE_SCHOLARSHIP sch
  		WHERE	sch.person_id		= p_person_id AND
  			sch.ca_sequence_number	= p_transfer_ca_sequence_number
  		ORDER BY sch.start_dt;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	--Check for existence of transfer session details
  	IF igs_as_val_suaap.genp_val_sdtt_sess(
  					cst_enrp_ins_ca_trnsfr) = TRUE THEN
  		--Not processing course transfer Candidature, finish processing
  		RETURN TRUE;
  	END IF;
  	--Validate that IGS_RE_SCHOLARSHIP details have not already been transferred
  	OPEN c_sch;
  	FETCH c_sch INTO v_sch_exists;
  	IF c_sch%FOUND THEN
  		CLOSE c_sch;
  		--IGS_RE_SCHOLARSHIP details already exist, cannot transfer
  		p_message_name := 'IGS_RE_SCHOLARSHIP_EXISTS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sch;
  	SAVEPOINT sp_scholarship;
  	BEGIN 	--Insert IGS_RE_SCHOLARSHIP details
  		FOR v_sch1_rec IN c_sch1 LOOP

                 DECLARE
                             l_rowid VARCHAR2(25);
			    l_org_id NUMBER(15) := IGS_GE_GEN_003.GET_ORG_ID;
                 BEGIN
  			IGS_RE_SCHOLARSHIP_PKG.INSERT_ROW(
                                x_rowid => l_rowid,
                                X_org_id => l_org_id,
  				x_person_id => p_person_id,
  				x_ca_sequence_number => p_ca_sequence_number,
  				x_scholarship_type => v_sch1_rec.scholarship_type,
  				x_start_dt => v_sch1_rec.start_dt,
  				x_end_dt => v_sch1_rec.end_dt,
  				x_dollar_value => v_sch1_rec.dollar_value,
  				x_description => v_sch1_rec.description,
  				x_other_benefits => v_sch1_rec.other_benefits,
  				x_conditions => v_sch1_rec.conditions );

                  END;

  		END LOOP; --(IGS_RE_SCHOLARSHIP)
  		EXCEPTION
  			WHEN OTHERS THEN		-- (exception)
  				ROLLBACK TO sp_scholarship;
  				p_message_name :='IGS_RE_CANT_INSERT_SCHOLARSHI';
  				RETURN FALSE;
  	END;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sch%ISOPEN THEN
  			CLOSE c_sch;
  		END IF;
  		IF c_sch1%ISOPEN THEN
  			CLOSE c_sch1;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_INS_CA_TRNSFR.enrp_ins_sch_trnsfr');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END enrp_ins_sch_trnsfr;
  --
  -- Insert THE as part of course Transfer.
  FUNCTION ENRP_INS_THE_TRNSFR(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_transfer_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

	v_user			varchar2(30);
  BEGIN	-- enrp_ins_the_trnsfr
  	--This module inserts research THESIS details as a result of COURSE transfer.
  	--All Candidature THESIS details (p_person_id/p_transfer_ca_sequence_number)
  	--are to be copied to the new Candidature (p_person_id/p_ca_sequence_number).
  DECLARE
  	v_return_val				BOOLEAN;
  	v_the_exists				VARCHAR2(1);
  	v_the_sequence_number			IGS_RE_THESIS.sequence_number%TYPE;
  	cst_enrp_ins_ca_trnsfr	CONSTANT	VARCHAR2(20) := 'ENRP_INS_CA_TRNSFR';
  	CURSOR c_next_val IS
  		SELECT	IGS_RE_THESIS_SEQ_NUM_S.nextval
  		FROM	dual;
  	CURSOR c_the IS
  		SELECT	'x'
  		FROM	IGS_RE_THESIS thes
  		WHERE	thes.person_id		= p_person_id AND
  			thes.ca_sequence_number	= p_ca_sequence_number;
  	CURSOR c_the2 IS
  		SELECT	thes.sequence_number,
  			thes.title,
  			thes.final_title_ind,
  			thes.short_title,
  			thes.abbreviated_title,
  			thes.thesis_result_cd,
  			thes.expected_submission_dt,
  			thes.library_lodgement_dt,
  			thes.library_catalogue_number,
  			thes.embargo_expiry_dt,
  			thes.thesis_format,
  			thes.embargo_details,
  			thes.thesis_topic,
  			thes.citation,
  			thes.comments
  		FROM	IGS_RE_THESIS		thes
  		WHERE	thes.person_id		= p_person_id AND
  			thes.ca_sequence_number	= p_transfer_ca_sequence_number AND
  			thes.logical_delete_dt	IS NULL;
  	CURSOR c_tex(
  		cp_the_sequence_number	IGS_RE_THESIS.sequence_number%TYPE) IS
  		SELECT  tex.the_sequence_number,
  			tex.creation_dt,
  			tex.submission_dt,
  			tex.thesis_exam_type,
  			tex.thesis_panel_type,
  			tex.tracking_id,
  			tex.thesis_result_cd
  		FROM	IGS_RE_THESIS_EXAM tex
  		WHERE	tex.person_id			= p_person_id AND
  			tex.ca_sequence_number		= p_transfer_ca_sequence_number AND
  			tex.the_sequence_number		= cp_the_sequence_number
  		ORDER BY  tex.creation_dt ASC;
  	CURSOR c_teh (
  		cp_tex_the_sequence_number	IGS_RE_THESIS_EXAM.the_sequence_number%TYPE,
  		cp_tex_creation_dt		IGS_RE_THESIS_EXAM.creation_dt%TYPE) IS
  		SELECT	teh.hist_start_dt,
  			teh.hist_end_dt,
  			teh.thesis_result_cd
  		FROM	IGS_RE_THS_EXAM_HIST		teh
  		WHERE	teh.person_id			= p_person_id AND
  			teh.ca_sequence_number		= p_transfer_ca_sequence_number AND
  			teh.the_sequence_number		= cp_tex_the_sequence_number AND
  			teh.creation_dt			= cp_tex_creation_dt AND
  			teh.thesis_result_cd		IS NOT NULL
  		ORDER BY teh.hist_end_dt DESC;
  	CURSOR c_tpm(
  		cp_tex_the_sequence_number	IGS_RE_THESIS_EXAM.the_sequence_number%TYPE,
  		cp_tex_creation_dt		IGS_RE_THESIS_EXAM.creation_dt%TYPE) IS
  		SELECT  tpm.the_sequence_number,
  			tpm.creation_dt,
  			tpm.person_id,
  			tpm.panel_member_type,
  			tpm.confirmed_dt,
  			tpm.declined_dt,
  			tpm.anonymity_ind,
  			tpm.thesis_result_cd,
  			tpm.paid_dt,
  			tpm.tracking_id,
  			tpm.recommendation_summary
  		FROM	IGS_RE_THS_PNL_MBR tpm
  		WHERE	tpm.ca_person_id	= p_person_id AND
  			tpm.ca_sequence_number	= p_transfer_ca_sequence_number AND
  			tpm.the_sequence_number	= cp_tex_the_sequence_number AND
  			tpm.creation_dt		= cp_tex_creation_dt;
  	CURSOR c_tpmh (
  		cp_the_sequence_number		IGS_RE_THS_PNL_MR_HS.the_sequence_number%TYPE,
  		cp_tpm_creation_dt		IGS_RE_THS_PNL_MR_HS.creation_dt%TYPE,
  		cp_tpm_person_id		IGS_RE_THS_PNL_MR_HS.person_id%TYPE) IS
  		SELECT	tpmh.hist_start_dt,
  			tpmh.hist_end_dt,
  			tpmh.thesis_result_cd
  		FROM	IGS_RE_THS_PNL_MR_HS	tpmh
  		WHERE	tpmh.ca_person_id			= p_person_id AND
  			tpmh.ca_sequence_number	= p_transfer_ca_sequence_number AND
  			tpmh.the_sequence_number	= cp_the_sequence_number AND
  			tpmh.creation_dt		= cp_tpm_creation_dt AND
  			tpmh.person_id			= cp_tpm_person_id AND
  			tpmh.thesis_result_cd		IS NOT NULL
  		ORDER BY tpmh.hist_end_dt DESC;
  	v_teh1_rec	c_teh%ROWTYPE;
  	v_tpmh1_rec	c_tpmh%ROWTYPE;
  BEGIN
  	-- Set the defaults
  	p_message_name := null;
  	v_return_val := TRUE;
  	--Check for existence of transfer session details
  	IF igs_as_val_suaap.genp_val_sdtt_sess(
  						cst_enrp_ins_ca_trnsfr) THEN
  		--Not processing course transfer Candidature, finish processing
  		RETURN TRUE;
  	END IF;
  	--Validate that THESIS details have not already been transferred
  	OPEN c_the;
  	FETCH c_the INTO v_the_exists;
  	IF c_the%FOUND THEN
  		CLOSE c_the;
  		--THESIS details already exist, cannot transfer
  		p_message_name := 'IGS_RE_THESIS_ALREADY_EXISTS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_the;
  	SAVEPOINT sp_thesis;
  	--Insert IGS_RE_THESIS
  	FOR v_the1_rec IN c_the2 LOOP
  	BEGIN
  		OPEN c_next_val;
  		FETCH c_next_val INTO v_the_sequence_number;
  		CLOSE c_next_val;
            DECLARE
                    l_rowid VARCHAR2(25);
			    l_org_id NUMBER(15) := IGS_GE_GEN_003.GET_ORG_ID;
            BEGIN
  		IGS_RE_THESIS_PKG.INSERT_ROW(
                        x_rowid => l_rowid,
                        X_org_id => l_org_id,
  			x_person_id =>p_person_id,
  			x_ca_sequence_number => p_ca_sequence_number,
  			x_sequence_number => v_the_sequence_number,
  			x_title=> v_the1_rec.title,
  			x_final_title_ind => v_the1_rec.final_title_ind,
  			x_short_title => v_the1_rec.short_title,
  			x_abbreviated_title => v_the1_rec.abbreviated_title,
  			x_thesis_result_cd => v_the1_rec.thesis_result_cd,
  			x_expected_submission_dt => v_the1_rec.expected_submission_dt,
  			x_library_lodgement_dt => v_the1_rec.library_lodgement_dt,
  			x_library_catalogue_number => v_the1_rec.library_catalogue_number,
  			x_embargo_expiry_dt => v_the1_rec.embargo_expiry_dt,
  			x_thesis_format => v_the1_rec.thesis_format,
  			x_embargo_details => v_the1_rec.embargo_details,
  			x_thesis_topic => v_the1_rec.thesis_topic,
  			x_citation => v_the1_rec.citation,
  			x_comments  => v_the1_rec.comments,
                        x_logical_delete_dt => null);
            END;

  		--Insert IGS_RE_THESIS exam(s)
  		FOR v_tex1_rec IN c_tex(
  						v_the1_rec.sequence_number) LOOP



            DECLARE
                    l_rowid VARCHAR2(25);
            BEGIN

  			IGS_RE_THESIS_EXAM_PKG.INSERT_ROW(
                                x_rowid => l_rowid,
  				x_person_id => p_person_id,
  				x_ca_sequence_number => p_ca_sequence_number,
  				x_the_sequence_number => v_the_sequence_number,
  				x_creation_dt => v_tex1_rec.creation_dt,
  				x_submission_dt => v_tex1_rec.submission_dt,
  				x_thesis_exam_type => v_tex1_rec.thesis_exam_type,
  				x_thesis_panel_type => v_tex1_rec.thesis_panel_type,
  				x_tracking_id => v_tex1_rec.tracking_id,
  				x_thesis_result_cd => v_tex1_rec.thesis_result_cd);

              END;
  			--Insert result code IGS_RE_THESIS exam history if required
  			--Note: IGS_RE_THESIS result code date(see RESF3700) is derived from audit details
  			--And must be retained with the transfer.
  			IF v_tex1_rec.thesis_result_cd IS NOT NULL THEN
  				OPEN c_teh(
  						v_tex1_rec.the_sequence_number,
  						v_tex1_rec.creation_dt);
  				FETCH c_teh INTO v_teh1_rec;
  				IF c_teh%NOTFOUND THEN
  					CLOSE c_teh;
  				ELSE
  					CLOSE c_teh;
					v_user := fnd_global.user_name;

            DECLARE
                    l_rowid VARCHAR2(25);
			    l_org_id NUMBER(15) := IGS_GE_GEN_003.GET_ORG_ID;
            BEGIN

  					IGS_RE_THS_EXAM_HIST_PKG.INSERT_ROW (
                                                x_rowid => l_rowid,
						X_org_id => l_org_id,
  						x_person_id => p_person_id ,
  						x_ca_sequence_number => p_ca_sequence_number,
  						x_the_sequence_number => v_the_sequence_number,
  						x_creation_dt => v_tex1_rec.creation_dt,
  						x_hist_start_dt => v_teh1_rec.hist_start_dt,
  						x_hist_end_dt => v_teh1_rec.hist_end_dt,
  						x_hist_who => v_user,
  						x_submission_dt => NULL,
  						x_thesis_exam_type => NULL,
  						x_thesis_panel_type => NULL,
  						x_tracking_id => NULL,
  						x_thesis_result_cd => v_teh1_rec.thesis_result_cd );
             END;


  				END IF; -- c_teh1%NOTFOUND
  			END IF; -- if result_cd is not null
  			--Insert IGS_RE_THESIS panel member(s)
  			FOR v_tpm1_rec IN c_tpm(
  							v_tex1_rec.the_sequence_number,
  							v_tex1_rec.creation_dt) LOOP
            DECLARE
                    	l_rowid VARCHAR2(25);
            BEGIN

  				IGS_RE_THS_PNL_MBR_PKG.INSERT_ROW(
                                        x_rowid => l_rowid,
  					x_ca_person_id  => p_person_id,
  					x_ca_sequence_number => p_ca_sequence_number,
  					x_the_sequence_number => v_the_sequence_number,
  					x_creation_dt => v_tpm1_rec.creation_dt,
  					x_person_id => v_tpm1_rec.person_id,
  					x_panel_member_type => v_tpm1_rec.panel_member_type,
  					x_confirmed_dt => v_tpm1_rec.confirmed_dt,
  					x_declined_dt => v_tpm1_rec.declined_dt,
  					x_anonymity_ind => v_tpm1_rec.anonymity_ind,
  					x_thesis_result_cd => v_tpm1_rec.thesis_result_cd,
  					x_paid_dt =>  v_tpm1_rec.paid_dt,
  					x_tracking_id  => v_tpm1_rec.tracking_id,
  					x_recommendation_summary  => v_tpm1_rec.recommendation_summary);
              END;


  			--Insert result code IGS_RE_THESIS panel member history if required
  			--Note: IGS_RE_THESIS result code date ( see RESF3700) is derived from audit details
  			--And must be retained with the transfer.
  			IF v_tpm1_rec.thesis_result_cd IS NOT NULL THEN
  				OPEN c_tpmh(
  						v_tpm1_rec.the_sequence_number,
  						v_tpm1_rec.creation_dt,
  						v_tpm1_rec.person_id);
  				FETCH c_tpmh INTO v_tpmh1_rec;
  				IF c_tpmh%NOTFOUND THEN
  					CLOSE c_tpmh;
  				ELSE
  					CLOSE c_tpmh;
					v_user := fnd_global.user_name;
            DECLARE
                    l_rowid VARCHAR2(25);
		    l_org_id NUMBER(15) := IGS_GE_GEN_003.GET_ORG_ID;
            BEGIN

  					IGS_RE_THS_PNL_MR_HS_PKG.INSERT_ROW (
                                                x_rowid => l_rowid,
						X_org_id => l_org_id,
  						x_ca_person_id=> p_person_id,
  						x_ca_sequence_number => p_ca_sequence_number,
  						x_the_sequence_number => v_the_sequence_number,
  						x_creation_dt  => v_tpm1_rec.creation_dt,
  						x_person_id => v_tpm1_rec.person_id,
  						x_hist_start_dt => v_tpmh1_rec.hist_start_dt,
  						x_hist_end_dt => v_tpmh1_rec.hist_end_dt,
  						x_hist_who => v_user,
  						x_panel_member_type => NULL,
  						x_confirmed_dt => NULL,
  						x_declined_dt => NULL,
  						x_anonymity_ind => 'N',
  						x_thesis_result_cd => v_tpm1_rec.thesis_result_cd,
  						x_paid_dt => NULL,
  						x_tracking_id => NULL,
  						x_recommendation_summary => NULL);
                END;

  				END IF; -- c_tpmh%NOTFOUND
  			END IF; -- if IGS_RE_THESIS result_cd IS NOT NULL
  			END LOOP; --(IGS_RE_THS_PNL_MBR)
  		END LOOP; --(IGS_RE_THESIS_EXAM)
  	EXCEPTION
  		WHEN OTHERS THEN
  			ROLLBACK TO sp_thesis;
  			p_message_name := 'IGS_RE_CANT_INSERT_THESIS_DET';
  			v_return_val := FALSE;
  			EXIT;
  	END;
  	END LOOP; --(IGS_RE_THESIS)
  	RETURN v_return_val;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_the%ISOPEN THEN
  			CLOSE c_the;
  		END IF;
  		IF c_the2%ISOPEN THEN
  			CLOSE c_the2;
  		END IF;
  		IF c_tex%ISOPEN THEN
  			CLOSE c_tex;
  		END IF;
  		IF c_tpm%ISOPEN THEN
  			CLOSE c_tpm;
  		END IF;
  		IF c_teh%ISOPEN THEN
  			CLOSE c_teh;
  		END IF;
  		IF c_tpmh%ISOPEN THEN
  			CLOSE c_tpmh;
  		END IF;
  		IF c_next_val%ISOPEN THEN
  			CLOSE c_next_val;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_INS_CA_TRNSFR.enrp_ins_the_trnsfr');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END enrp_ins_the_trnsfr;
  --
  -- Insert Research Candidature as part of course Transfer.
  FUNCTION ENRP_INS_CA_TRNSFR(
  p_person_id IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_transfer_course_cd IN VARCHAR2 ,
  p_parent IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS

  BEGIN	-- enrp_ins_ca_trnsfr
  DECLARE
  	v_ca_to_exists				VARCHAR2(1);
  	cst_ca_to_sca		CONSTANT	VARCHAR2(3):= 'SCA';
  	cst_ca_to_acai		CONSTANT	VARCHAR2(4):= 'ACAI';
  	cst_enrp_ins_ca_trnsfr	CONSTANT	VARCHAR2(18) := 'ENRP_INS_CA_TRNSFR';
  	v_attendance_percentage			IGS_RE_CANDIDATURE.attendance_percentage%TYPE;
  	v_ca_govt_type_of_activity_cd		IGS_RE_CANDIDATURE.govt_type_of_activity_cd%TYPE;
  	v_ca_research_topic			IGS_RE_CANDIDATURE.research_topic%TYPE;
  	v_ca_industry_links			IGS_RE_CANDIDATURE.industry_links%TYPE;
  	v_ca_sequence_number			IGS_RE_CANDIDATURE.sequence_number%TYPE;
  	v_sequence_number			IGS_RE_CANDIDATURE.sequence_number%TYPE;
  	v_message_name				Varchar2(30);
  	v_person_id				IGS_RE_CANDIDATURE.person_id%TYPE;
  	CURSOR c_ca IS
  		SELECT	ca.attendance_percentage,
  			ca.govt_type_of_activity_cd,
  			ca.research_topic,
  			ca.industry_links,
  			ca.sequence_number
  		FROM	IGS_RE_CANDIDATURE ca
  		WHERE	ca.person_id		= p_person_id AND
  			ca.sca_course_cd	= p_transfer_course_cd;
  	CURSOR c_ca_to IS
  		SELECT	'x'
  		FROM	IGS_RE_CANDIDATURE ca_to
  		WHERE	ca_to.person_id				= p_person_id AND
  			(ca_to.sca_course_cd			= p_sca_course_cd AND
  			p_parent				= cst_ca_to_sca) OR
  			(ca_to.acai_admission_appl_number	= p_acai_admission_appl_number AND
  			ca_to.acai_nominated_course_cd		= p_acai_nominated_course_cd AND
  			ca_to.acai_sequence_number		= p_acai_sequence_number AND
  			p_parent				=  cst_ca_to_acai);
  	CURSOR c_dual IS
  		SELECT	IGS_RE_CANDIDATURE_SEQ_NUM_S.nextval
  		FROM dual;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	--Validate that Candidature details exist against the transferring 'from'
  	-- course attempt
  	OPEN c_ca;
  	FETCH c_ca INTO v_attendance_percentage,
  			v_ca_govt_type_of_activity_cd,
  			v_ca_research_topic,
  			v_ca_industry_links,
  			v_sequence_number;
  	IF c_ca%NOTFOUND THEN
  		CLOSE c_ca;
  		--Candidature details do not exist, cannot transfer
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ca;
  	--Validate that Candidature details do not already exist for the
  	--transferring 'to' COURSE
  	OPEN c_ca_to;
  	FETCH c_ca_to INTO v_ca_to_exists;
  	IF c_ca_to%FOUND THEN
  		CLOSE c_ca_to;
  		--Candidature details already exist, cannot transfer
  		p_message_name := 'IGS_RE_CAND_DETAILS_EXISTS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ca_to;
  	SAVEPOINT sp_candidature;
  	--Disable trigger validation
  	IGS_GE_MNT_SDTT.genp_del_sdtt(cst_enrp_ins_ca_trnsfr);

  	-- Inserts a record into the s_disable_table_trigger
		-- database table.
            DECLARE
                    l_rowid VARCHAR2(25);
            BEGIN

	IGS_GE_S_DSB_TAB_TRG_PKG.INSERT_ROW(
		X_ROWID => L_ROWID ,
		X_TABLE_NAME =>cst_enrp_ins_ca_trnsfr,
		X_SESSION_ID => userenv('SESSIONID'),
		x_mode => 'R'
		);
END;

  	--Get next sequence number
  	OPEN c_dual;
  	FETCH c_dual INTO v_ca_sequence_number;
  	--Insert Candidature
  	BEGIN
            DECLARE
                    l_rowid VARCHAR2(25);
		    l_org_id NUMBER(15) := IGS_GE_GEN_003.GET_ORG_ID;
            BEGIN

  		IGS_RE_CANDIDATURE_PKG.INSERT_ROW(
                        x_rowid => l_rowid,
			X_org_id => l_org_id,
  			x_person_id => p_person_id,
  			x_sequence_number => v_ca_sequence_number,
  			x_sca_course_cd => p_sca_course_cd,
  			x_acai_admission_appl_number => p_acai_admission_appl_number,
  			x_acai_nominated_course_cd => p_acai_nominated_course_cd,
  			x_acai_sequence_number => p_acai_sequence_number,
  			x_attendance_percentage => v_attendance_percentage,
  			x_govt_type_of_activity_cd => v_ca_govt_type_of_activity_cd,
  			x_max_submission_dt => NULL,
  			x_min_submission_dt => NULL,
  			x_research_topic => v_ca_research_topic,
  			x_industry_links => v_ca_industry_links );
               END;

  	EXCEPTION
  		WHEN OTHERS THEN
  			ROLLBACK TO sp_candidature;
  			p_message_name := 'IGS_RE_CANT_INS_CAND_DETAILS';
  			RETURN FALSE;
  	END;
  	--Insert Candidature attendance history(s)
  	IF IGS_EN_INS_CA_TRNSFR.enrp_ins_cah_trnsfr(
  						p_person_id,
  						v_ca_sequence_number,
  						v_sequence_number,
  						v_message_name) = FALSE THEN
  		ROLLBACK TO sp_candidature;
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--Insert Candidature field of study(s)
  	IF IGS_EN_INS_CA_TRNSFR.enrp_ins_cafostrnsfr(
  						p_person_id,
  						v_ca_sequence_number,
  						v_sequence_number,
  						v_message_name) = FALSE THEN
  		ROLLBACK TO sp_candidature;
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--Insert Candidature socio-economic classification code(s)
  	IF IGS_EN_INS_CA_TRNSFR.enrp_ins_csc_trnsfr(
  						p_person_id,
  						v_ca_sequence_number,
  						v_sequence_number,
  						v_message_name) = FALSE THEN
  		ROLLBACK TO sp_candidature;
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--Insert Candidature Thesis(s)
  	IF IGS_EN_INS_CA_TRNSFR.enrp_ins_the_trnsfr(
  						p_person_id,
  						v_ca_sequence_number,
  						v_sequence_number,
  						v_message_name) = FALSE THEN
  		ROLLBACK TO sp_candidature;
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--Insert Candidature research supervisor(s)
  	IF IGS_EN_INS_CA_TRNSFR.enrp_ins_rsup_trnsfr(
  						p_person_id,
  						v_ca_sequence_number,
  						v_sequence_number,
  						v_message_name) = FALSE THEN
  		Rollback to sp_candidature;
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--Insert Candidature milestone(s)
  	IF IGS_EN_INS_CA_TRNSFR.enrp_ins_mil_trnsfr(
  						p_person_id,
  						v_ca_sequence_number,
  						v_sequence_number,
  						v_message_name) = FALSE THEN
  		ROLLBACK TO sp_candidature;
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--Insert Candidature research scholarship(s)
  	IF IGS_EN_INS_CA_TRNSFR.enrp_ins_sch_trnsfr(
  						p_person_id,
  						v_ca_sequence_number,
  						v_sequence_number,
  						v_message_name) = FALSE THEN
  		ROLLBACK TO sp_candidature;
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--Enable trigger validation
  	IGS_GE_MNT_SDTT.genp_del_sdtt(cst_enrp_ins_ca_trnsfr);
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_ca%ISOPEN THEN
  			CLOSE c_ca;
  		END IF;
  		IF c_ca_to%ISOPEN THEN
  			CLOSE c_ca_to;
  		END IF;
  		IF c_dual%ISOPEN THEN
  			CLOSE c_dual;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_INS_CA_TRNSFR.enrp_ins_ca_trnsfr');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END enrp_ins_ca_trnsfr;
END igs_en_ins_ca_trnsfr;

/
