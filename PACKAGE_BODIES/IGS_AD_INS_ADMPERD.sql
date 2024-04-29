--------------------------------------------------------
--  DDL for Package Body IGS_AD_INS_ADMPERD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_INS_ADMPERD" AS
/* $Header: IGSAD14B.pls 115.11 2003/09/29 07:45:51 nsinha ship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |
 | DESCRIPTION
 |      PL/SQL body for package: IGS_AD_INS_ADMPERD
 |
 | NOTES
 |
 | HISTORY
 | Navin.Sinha 9/26/2003 Enhancement: 3132406 ENFORCE SINGLE RESPONSE TO OFFER
 |      Addded call to igs_ad_val_apac.admp_ins_dflt_apapc in FUNCTION admp_ins_adm_ci_roll.
 |
 +=======================================================================*/

  --
  -- Insert admission period details as part of a rollover process.
  PROCEDURE admp_ins_acadci_roll(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY NUMBER,
  p_academic_period IN VARCHAR2,
   p_admission_cat IN VARCHAR2,
  p_org_id        IN NUMBER )
  IS
      p_acad_cal_type			IGS_CA_INST.cal_type%type;
	p_acad_ci_sequence_number     IGS_CA_INST.sequence_number%type;
  BEGIN 	-- admp_ins_acadci_roll
  	-- Routine to rollover all admission period details from the old
  	-- academic period to a new academic period. This can be restricted
  	-- to an admission category
      -- block for parameter validation/splitting of parameters
 	igs_ge_gen_003.set_org_id(p_org_id);
	retcode := 0;

      begin
       p_acad_cal_type := ltrim(rtrim(substr(p_academic_period,102,10)));
       p_acad_ci_sequence_number := IGS_GE_NUMBER.TO_NUM(substr(p_academic_period,113,8));
      end;

      -- end of block for parameter validation/splitting of parameters

  DECLARE
  	cst_admission			CONSTANT VARCHAR2(9) := 'ADMISSION';
  	cst_error			CONSTANT VARCHAR2(1) := 'E';
  	v_alternate_code		IGS_CA_INST.alternate_code%TYPE;
  	v_message_name VARCHAR2(30);
  	v_creation_dt			IGS_GE_S_LOG.creation_dt%TYPE;
  	v_return_type			VARCHAR2(1);
  	v_s_log_type			VARCHAR2(8);
  	CURSOR c_ci (
  			cp_acad_cal_type		IGS_CA_INST.cal_type%TYPE,
  			cp_acad_ci_sequence_number	IGS_CA_INST.sequence_number%TYPE) IS
  		SELECT	ci.alternate_code
  		FROM	IGS_CA_INST			ci
  		WHERE	ci.cal_type			= cp_acad_cal_type AND
  			ci.sequence_number		= cp_acad_ci_sequence_number;
  	CURSOR c_cir (
  			cp_acad_cal_type		IGS_CA_INST.cal_type%TYPE,
  			cp_acad_ci_sequence_number	IGS_CA_INST.sequence_number%TYPE) IS
  		SELECT	ci.cal_type,
  			ci.sequence_number,
  			ci.prior_ci_sequence_number
  		FROM	IGS_CA_INST_REL	cir,
  			IGS_CA_INST			ci,
  			IGS_CA_TYPE			cat
  		WHERE	cat.cal_type			= ci.cal_type AND
  			cat.s_cal_cat			= cst_admission AND
  			cir.sup_cal_type		= cp_acad_cal_type AND
  			cir.sup_ci_sequence_number	= cp_acad_ci_sequence_number AND
  			cir.sub_cal_type		= ci.cal_type AND
  			cir.sub_ci_sequence_number	= ci.sequence_number;
  BEGIN
  	-- Initialise log type
  	v_s_log_type := 'ADM-ROLL';
  	-- Get alternate code for the academic period
  	OPEN	c_ci(
  			p_acad_cal_type,
  			p_acad_ci_sequence_number);
  	FETCH	c_ci INTO v_alternate_code;
  	IF(v_alternate_code IS NULL) THEN
  		v_alternate_code := p_acad_cal_type;
  	END IF;
  	CLOSE c_ci;
  	-- Insert log for exception recording
  	IGS_GE_GEN_003.GENP_INS_LOG(
  		v_s_log_type,
  		v_alternate_code,
  		v_creation_dt);
  	FOR v_cir_rec IN c_cir(
  			p_acad_cal_type,
  			p_acad_ci_sequence_number) LOOP
  		IF v_cir_rec.prior_ci_sequence_number IS NOT NULL THEN
  			IF(IGS_AD_INS_ADMPERD.admp_ins_adm_ci_roll(
  					v_alternate_code,
  					v_cir_rec.cal_type,
  					v_cir_rec.prior_ci_sequence_number,
  					v_cir_rec.sequence_number,
  					p_admission_cat,
  					v_s_log_type,
  					v_creation_dt,
  					v_message_name,
  					v_return_type) = FALSE) then
  				IF(v_return_type = cst_error) THEN
  					IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
  						v_s_log_type,
  						v_creation_dt,
  						'CI,'||v_cir_rec.cal_type ||','||
  						 v_cir_rec.sequence_number||','||
  						FND_NUMBER.NUMBER_TO_CANONICAL(v_cir_rec.prior_ci_sequence_number),
  						v_message_name,
  						NULL);
  				END IF;
  			END IF;
  		END IF;
  	END LOOP;
  	COMMIT;
  	RETURN;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		retcode := 2;
		errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
  END admp_ins_acadci_roll;
  --
  -- Insert admission period course offering option.
  FUNCTION admp_ins_apapc_apcoo(
  p_acad_alternate_code IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_old_adm_ci_sequence_number IN NUMBER ,
  p_old_admission_cat IN VARCHAR2 ,
  p_new_adm_ci_sequence_number IN NUMBER ,
  p_new_admission_cat IN VARCHAR2 ,
  p_rollover_ind IN VARCHAR2 DEFAULT 'N',
  p_s_log_type IN OUT NOCOPY VARCHAR2 ,
  p_creation_dt IN OUT NOCOPY DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN   -- admp_ins_apapc_apcoo
  	-- Routine to insert all details from the one Admission Period Admission
  	-- Category
  	-- to another. This process will be called by the Admission calendar rollover
  	-- process, and from the form for duplicating admission period admission
  	-- categories.
  	-- NOTE: This function will be called after the admission period admission
  	-- category
  	-- has been inserted. The database trigger associated with the admission period
  	-- admission category also in inserts adm_period_admission process categories.
  DECLARE
  	cst_error		CONSTANT	VARCHAR2(1) := 'E';
  	cst_warn		CONSTANT	VARCHAR2(1) := 'W';
  	v_message_name VARCHAR2(30);
  	v_apcoo_one_not_insert	BOOLEAN DEFAULT FALSE;
  	v_apcoo_one_insert	BOOLEAN DEFAULT FALSE;
  	v_apcoo_one_apcoo	BOOLEAN DEFAULT FALSE;
     	CURSOR C_IGS_ADPRD_NUM_S IS
     	SELECT IGS_AD_PRD_PS_OF_OPT_SEQ_NUM_S.NEXTVAL FROM DUAL;
  	CURSOR c_apapc IS
  		SELECT	s_admission_process_type
  		FROM	IGS_AD_PRD_AD_PRC_CA
  		WHERE	adm_cal_type		= p_adm_cal_type	AND
  			adm_ci_sequence_number	= p_new_adm_ci_sequence_number	AND
  			admission_cat	= p_new_admission_cat AND
			closed_ind = 'N';   --added the closed indicator for bug# 2380108 (rghosh)
  	v_apapc_rec	c_apapc%ROWTYPE;
  	CURSOR c_apapc_check (
  		cp_s_adm_process_type	IGS_AD_PRD_AD_PRC_CA.s_admission_process_type%
  TYPE) IS
  		SELECT	'x'
  		FROM	IGS_AD_PRD_AD_PRC_CA
  		WHERE	adm_cal_type		= p_adm_cal_type	AND
  			adm_ci_sequence_number	= p_old_adm_ci_sequence_number	AND
                        admission_cat		= p_old_admission_cat		AND
  			s_admission_process_type = cp_s_adm_process_type        AND
			closed_ind = 'N';    --added the closed indicator for bug# 2380108 (rghosh)
  	v_apapc_check_exist	VARCHAR2(1);
  	CURSOR c_aa_child (
  		cp_s_adm_process_type	IGS_AD_PRD_AD_PRC_CA.s_admission_process_type%
  TYPE) IS
  		SELECT 'x'
  		FROM	IGS_AD_APPL
  		WHERE	adm_cal_type		= p_adm_cal_type	AND
  			adm_ci_sequence_number	= p_new_adm_ci_sequence_number	AND
  			admission_cat		= p_new_admission_cat	AND
  			s_admission_process_type = cp_s_adm_process_type;
  	v_aa_child_exist	VARCHAR2(1);
  	CURSOR c_apcood_child (
  		cp_s_adm_process_type	IGS_AD_PRD_AD_PRC_CA.s_admission_process_type%
  TYPE) IS
  		SELECT 'x'
  		FROM	IGS_AD_PECRS_OFOP_DT
  		WHERE	adm_cal_type		= p_adm_cal_type	AND
  			adm_ci_sequence_number	= p_new_adm_ci_sequence_number	AND
  			admission_cat		= p_new_admission_cat	AND
  			s_admission_process_type = cp_s_adm_process_type;
  	v_apcood_child_exist	VARCHAR2(1);
  	CURSOR c_apcoo(
  		cp_s_admission_process_type
  		IGS_AD_PRD_AD_PRC_CA.s_admission_process_type%TYPE) IS
  		SELECT	adm_cal_type,
  			adm_ci_sequence_number,
  			admission_cat,
  			s_admission_process_type,
  			course_cd,
  			version_number,
  			acad_cal_type,
  			sequence_number,
  			location_cd,
  			attendance_mode,
  			attendance_type,
  			rollover_inclusion_ind
  		FROM	IGS_AD_PRD_PS_OF_OPT
  		WHERE	adm_cal_type		= p_adm_cal_type	AND
  			adm_ci_sequence_number	= p_old_adm_ci_sequence_number	AND
  			admission_cat		= p_old_admission_cat	AND
  			s_admission_process_type = cp_s_admission_process_type;
  	v_apcoo_rec	c_apcoo%ROWTYPE;
  	CURSOR c_val_entry_point(
  		cp_course_cd		IGS_AD_PRD_PS_OF_OPT.course_cd%TYPE,
  		cp_version_number	IGS_AD_PRD_PS_OF_OPT.version_number%TYPE,
  		cp_acad_cal_type	IGS_AD_PRD_PS_OF_OPT.acad_cal_type%TYPE) IS
  		SELECT 'x'
  		FROM	IGS_PS_OFR_PAT		cop,
  			IGS_CA_INST_REL	cir
  		WHERE	cir.sub_cal_type	= p_adm_cal_type	AND
  			cir.sub_ci_sequence_number = p_new_adm_ci_sequence_number	AND
  			cop.course_cd		= cp_course_cd	AND
  			cop.version_number	= cp_version_number	AND
  			cop.cal_type		= cp_acad_cal_type	AND
  			cop.offered_ind		= 'Y'			AND
  			cop.entry_point_ind	= 'Y'			AND
  			cir.sup_cal_type	= cop.cal_type		AND
  			cir.sup_ci_sequence_number	= cop.ci_sequence_number;
  	v_val_ep	c_val_entry_point%ROWTYPE;

      CURSOR Cur_IGS_AD_PRD_AD_PRC_CA (p_adm_cal_type IGS_AD_PRD_AD_PRC_CA.adm_cal_type%TYPE,
			   									p_new_adm_ci_sequence_number IGS_AD_PRD_AD_PRC_CA.adm_ci_sequence_number%TYPE,
												p_new_admission_cat IGS_AD_PRD_AD_PRC_CA.admission_cat%TYPE,
												p_s_admission_process_type IGS_AD_PRD_AD_PRC_CA.s_admission_process_type%TYPE
												)IS
				SELECT  rowid, APAPC.*
                FROM IGS_AD_PRD_AD_PRC_CA APAPC
				WHERE	adm_cal_type			= p_adm_cal_type		AND
  						adm_ci_sequence_number		= p_new_adm_ci_sequence_number	AND
  						admission_cat				= p_new_admission_cat		AND
  						s_admission_process_type 	= p_s_admission_process_type;

      lv_rowid 	VARCHAR2(25);
	lv_nextval	Number;
  	PROCEDURE admpl_ins_insert_log(
  		p_adm_ci_sequence_number
  			IGS_AD_PRD_PS_OF_OPT.adm_ci_sequence_number%TYPE,
  		p_admission_cat			IGS_AD_PRD_PS_OF_OPT.admission_cat%TYPE,
  		p_s_admission_process_type
  			IGS_AD_PRD_PS_OF_OPT.s_admission_process_type%TYPE,
  		p_course_cd			IGS_AD_PRD_PS_OF_OPT.course_cd%TYPE,
  		p_version_number		IGS_AD_PRD_PS_OF_OPT.version_number%TYPE,
  		p_acad_cal_type			IGS_AD_PRD_PS_OF_OPT.acad_cal_type%TYPE,
  		p_sequence_number		IGS_AD_PRD_PS_OF_OPT.sequence_number%TYPE,
  		p_message_name			VARCHAR2)
  	IS
  	BEGIN	-- admpl_ins_insert_log
  	DECLARE
  		v_key		IGS_GE_S_LOG.key%TYPE;
  		v_adm_calendar	VARCHAR2(35);
                  v_s_log_type    IGS_GE_S_LOG.s_log_type%TYPE;
                  v_creation_dt   IGS_GE_S_LOG.creation_dt%TYPE;

  		CURSOR c_start_end_dt IS
  			SELECT	start_dt,
  				end_dt
  			FROM	IGS_CA_INST
  			WHERE	cal_type	= p_adm_cal_type AND
  				sequence_number = p_new_adm_ci_sequence_number;
  		v_dt_rec	c_start_end_dt%ROWTYPE;
  	BEGIN
  		IF (p_s_log_type IS NULL) THEN
  			-- Get start and end dates for the admission period
                          v_s_log_type := 'ADM-ROLL';
  			OPEN c_start_end_dt;
  			FETCH c_start_end_dt INTO v_dt_rec;
  			IF (c_start_end_dt%NOTFOUND) THEN
  				v_adm_calendar := p_adm_cal_type;
  			ELSE
  				v_adm_calendar := p_adm_cal_type || '(' ||
  					TO_CHAR(v_dt_rec.start_dt, 'DD/MM/YYYY') || ' - ' ||
  					TO_CHAR(v_dt_rec.end_dt, 'DD/MM/YYYY') || ')';
  			END IF;
  			CLOSE c_start_end_dt;
  			v_key :=RPAD(p_acad_alternate_code,10)		|| ' ' ||
  				RPAD(v_adm_calendar,35)			|| ' ' ||
  				p_new_admission_cat;
  			IGS_GE_GEN_003.GENP_INS_LOG(
  				v_s_log_type,
  				v_key,
  				v_creation_dt);
  			p_s_log_type := v_s_log_type;
  			p_creation_dt := v_creation_dt;
  		END IF;
  		v_key := 'APCOO,'				|| p_adm_cal_type ||','||
  			FND_NUMBER.NUMBER_TO_CANONICAL(p_new_adm_ci_sequence_number)	||','|| p_new_admission_cat ||','||
  			FND_NUMBER.NUMBER_TO_CANONICAL(p_adm_ci_sequence_number)	||','|| p_admission_cat ||','||
  			p_s_admission_process_type		||','|| p_course_cd ||','||
  			FND_NUMBER.NUMBER_TO_CANONICAL(p_version_number)		||','|| p_acad_cal_type ||','||
  			FND_NUMBER.NUMBER_TO_CANONICAL(p_sequence_number);
  		IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
  			p_s_log_type,
  			p_creation_dt,
  			v_key,
  			v_message_name,
  			NULL);
  	END;
  	END admpl_ins_insert_log;

  BEGIN
  	-- Select IGS_AD_PRD_AD_PRC_CA to duplicate IGS_PS_COURSE offering
  	-- option restrictions.
  	OPEN c_apapc;
  	LOOP
  		FETCH c_apapc INTO v_apapc_rec;
  		EXIT WHEN c_apapc%NOTFOUND;
  		-- For each record, remove apapc if no longer required or inserted via
  		-- the table trigger.
  		OPEN c_apapc_check(
  			v_apapc_rec.s_admission_process_type);
  		FETCH c_apapc_check INTO v_apapc_check_exist;
  		IF c_apapc_check%NOTFOUND THEN
  			CLOSE	c_apapc_check;
  			-- Delete this record, if no child records exist.
  			OPEN c_aa_child(
  				v_apapc_rec.s_admission_process_type);
  			FETCH c_aa_child INTO v_aa_child_exist;
  			IF c_aa_child%NOTFOUND THEN
  				CLOSE c_aa_child;
  				OPEN c_apcood_child(
  					v_apapc_rec.s_admission_process_type);
  				FETCH c_apcood_child INTO v_apcood_child_exist;
  				IF c_apcood_child%NOTFOUND THEN
  					CLOSE c_apcood_child;

					FOR Rec_IGS_AD_PRD_AD_PRC_CA IN Cur_IGS_AD_PRD_AD_PRC_CA(p_adm_cal_type, p_new_adm_ci_sequence_number, p_new_admission_cat, v_apapc_rec.s_admission_process_type) LOOP
					    IGS_AD_PRD_AD_PRC_CA_Pkg.Delete_Row (
					      Rec_IGS_AD_PRD_AD_PRC_CA.RowId
					    );
					END LOOP;
  				ELSE
  					CLOSE c_apcood_child;
  					-- If record found, process next record(APAPC)
  				END IF;
  			ELSE
  				CLOSE c_aa_child;
  				-- If record found, process next record(APAPC)
  			END IF;
  		ELSE	-- c_apapc_check not found
  			CLOSE	c_apapc_check;
  			-- For each record, select the Admission Period COURSE Offering Option
  			-- Restrictions for the process type.
  			OPEN c_apcoo(
  				v_apapc_rec.s_admission_process_type);
  			LOOP
  				FETCH c_apcoo INTO v_apcoo_rec;
  				EXIT WHEN c_apcoo%NOTFOUND;
  				IF (p_rollover_ind = 'Y' AND
  						v_apcoo_rec.rollover_inclusion_ind = 'N') THEN
  					-- Continue processing next IGS_AD_PRD_PS_OF_OPT.
  					NULL;
  				ELSE
  					-- Set variable to indicate one admission period COURSE offering option
  					-- found.
  					v_apcoo_one_apcoo := TRUE;
  					IF (IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_crv(
  						v_apcoo_rec.course_cd,
  						v_apcoo_rec.version_number,
  						v_apcoo_rec.s_admission_process_type,
  						'N', --(this is not offer processing)
  						v_message_name) = FALSE) THEN
  						-- Validate the IGS_PS_COURSE version.
  						-- If FALSE, set variable to indicate at least
  						-- one apcoo could not be inserted
  						v_apcoo_one_not_insert := TRUE;
  						-- Insert log **
  						admpl_ins_insert_log(
  							v_apcoo_rec.adm_ci_sequence_number,
  							v_apcoo_rec.admission_cat,
  							v_apcoo_rec.s_admission_process_type,
  							v_apcoo_rec.course_cd,
  							v_apcoo_rec.version_number,
  							v_apcoo_rec.acad_cal_type,
  							v_apcoo_rec.sequence_number,
  							v_message_name);
  						-- Continue processing COURSE offering option
  						-- restrictions.
  					ELSIF (IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_adm_cat(
  							v_apcoo_rec.course_cd,
  							v_apcoo_rec.version_number,
  							v_apcoo_rec.acad_cal_type,
  							v_apcoo_rec.location_cd,
  							v_apcoo_rec.attendance_mode,
  							v_apcoo_rec.attendance_type,
  							p_new_admission_cat,
  							v_message_name) = FALSE) THEN
  						-- Validate admission category mapping.
  						-- If FALSE, set variable to indicate at least
  						-- one apcoo could not be inserted.
  						v_apcoo_one_not_insert := TRUE;
  						--Insert log **
  						admpl_ins_insert_log(
  							v_apcoo_rec.adm_ci_sequence_number,
  							v_apcoo_rec.admission_cat,
  							v_apcoo_rec.s_admission_process_type,
  							v_apcoo_rec.course_cd,
  							v_apcoo_rec.version_number,
  							v_apcoo_rec.acad_cal_type,
  							v_apcoo_rec.sequence_number,
  							v_message_name);
  					ELSE
  						-- Validate entry point.
  						OPEN c_val_entry_point(
  							v_apcoo_rec.course_cd,
  							v_apcoo_rec.version_number,
  							v_apcoo_rec.acad_cal_type);
  						FETCH c_val_entry_point INTO v_val_ep;
  						IF (c_val_entry_point%NOTFOUND) THEN
  							CLOSE c_val_entry_point;
  							v_message_name := 'IGS_AD_PRGOFOP_NO_PRGOFOP';
  							-- Set variable to indicate at least one
  							-- apcoo could not be inserted.
  							v_apcoo_one_not_insert := TRUE;
  							-- Insert log **
  							admpl_ins_insert_log(
  								v_apcoo_rec.adm_ci_sequence_number,
  								v_apcoo_rec.admission_cat,
  								v_apcoo_rec.s_admission_process_type,
  								v_apcoo_rec.course_cd,
  								v_apcoo_rec.version_number,
  								v_apcoo_rec.acad_cal_type,
  								v_apcoo_rec.sequence_number,
  								v_message_name);
  						ELSE
  							CLOSE c_val_entry_point;
					        OPEN C_IGS_ADPRD_NUM_S;
				   		    FETCH C_IGS_ADPRD_NUM_S INTO lv_nextval;
						    IF C_IGS_ADPRD_NUM_S%NOTFOUND THEN
						       RAISE NO_DATA_FOUND;
						    END IF;
						    CLOSE C_IGS_ADPRD_NUM_S;

    						IGS_AD_PRD_PS_OF_OPT_Pkg.Insert_Row (
      							X_Mode                              => 'R',
      							X_RowId                             => lv_rowid,
      							X_Adm_Cal_Type                      => p_adm_cal_type,
      							X_Adm_Ci_Sequence_Number            => p_new_adm_ci_sequence_number,
      							X_Admission_Cat                     => p_new_admission_cat,
      							X_S_Admission_Process_Type          => v_apcoo_rec.s_admission_process_type,
      							X_Course_Cd                         => v_apcoo_rec.course_cd,
      							X_Version_Number                    => v_apcoo_rec.version_number,
      							X_Acad_Cal_Type                     => v_apcoo_rec.acad_cal_type,
      							X_Sequence_Number                   => lv_nextval,
      							X_Location_Cd                       => v_apcoo_rec.location_cd,
      							X_Attendance_Mode                   => v_apcoo_rec.attendance_mode,
      							X_Attendance_Type                   => v_apcoo_rec.attendance_type,
      							X_Rollover_Inclusion_Ind            => 'Y'
    						);


  							-- Set variable to indicate at least one
  							-- apcoo has been inserted
  							v_apcoo_one_insert := TRUE;
  						END IF; -- c_val_entry_point%NOTFOUND
  					END IF; -- if validate COURSE version return false
  				END IF; --if p_rollver_ind = 'N' and rollover_inclusion_ind = 'N'
  			END LOOP; -- apcoo
  			CLOSE c_apcoo;
  		END IF; -- IF c_apapc_check%NOTFOUND
  	END LOOP; -- apapc
  	IF (c_apapc%ROWCOUNT = 0) THEN
  		CLOSE c_apapc;
		p_message_name := 'IGS_AD_NO_ADM_PERIOD_ADM_DUPL';
  		p_return_type := cst_warn;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_apapc;
  	IF (v_apcoo_one_insert = FALSE AND
  			v_apcoo_one_apcoo = TRUE) THEN
		p_message_name := 'IGS_AD_ADMPRD_NOT_DUPLICATED';
  		p_return_type := cst_warn;
  		RETURN FALSE;
  	END IF;
  	IF (v_apcoo_one_not_insert = TRUE AND
  			v_apcoo_one_apcoo = TRUE) THEN
		p_message_name := 'IGS_AD_ONE_ADMPERIOD_PRG_OFOP';
  		p_return_type := cst_warn;
  		RETURN FALSE;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_INS_ADMPERD.admp_ins_apapc_apcoo');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_ins_apapc_apcoo;
  --
  -- Insert admission period details as part of a rollover process.
  FUNCTION admp_ins_adm_ci_roll(
  p_acad_alternate_code IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_old_adm_ci_sequence_number IN NUMBER ,
  p_new_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_log_type IN OUT NOCOPY VARCHAR2 ,
  p_creation_dt IN OUT NOCOPY DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	--admp_ins_adm_ci_roll
  	--Routine to rollover all details from the old admission period to the new.
  DECLARE
  	cst_error			CONSTANT	VARCHAR2(1) := 'E';
  	cst_warn			CONSTANT	VARCHAR2(1) := 'W';
  	v_ci_start_dt			IGS_CA_INST.start_dt%TYPE;
  	v_ci_end_dt			IGS_CA_INST.end_dt%TYPE;
  	v_creation_dt			IGS_GE_S_LOG.creation_dt%TYPE;
  	v_message_name VARCHAR2(30);
  	v_s_log_type			IGS_GE_S_LOG.s_log_type%TYPE;
  	v_adm_calendar			VARCHAR2(50);
  	v_apac1_rec_exists		BOOLEAN;
  	v_acat_not_ins			BOOLEAN;
  	v_acat_det_not_ins		BOOLEAN;
  	v_acat_ins			BOOLEAN;
  	v_apcoo_exist			VARCHAR2(1);
  	v_apac2_exist			VARCHAR2(1);
  	--parameters required by call to IGS_AD_INS_ADMPERD.admp_val_adm_ci as OUT NOCOPY
  	-- parameters they are not used for any other purpose
  	v_start_dt 	 		IGS_CA_INST.start_dt%TYPE;
    	v_end_dt 	 		IGS_CA_INST.end_dt%TYPE;
    	v_alternate_code 		IGS_CA_INST.alternate_code%TYPE;
  	CURSOR c_apcoo IS
  		SELECT	'X'
  		FROM	IGS_AD_PRD_PS_OF_OPT	apcoo
  		WHERE	apcoo.adm_cal_type		= p_adm_cal_type		AND
  			apcoo.adm_ci_sequence_number	= p_new_adm_ci_sequence_number	AND
  			(p_admission_cat		IS NULL	OR
  			apcoo.admission_cat		= p_admission_cat);
  	CURSOR c_ci IS
  		SELECT	ci.start_dt,
  			ci.end_dt
  		FROM	IGS_CA_INST	ci
  		WHERE	ci.cal_type			= p_adm_cal_type		AND
  			ci.sequence_number		= p_new_adm_ci_sequence_number;
  	CURSOR c_apac1 IS
  		SELECT	apac.adm_cal_type,
  			apac.admission_cat,
  			apac.adm_ci_sequence_number
  		FROM	IGS_AD_PERD_AD_CAT	apac
  		WHERE	apac.adm_cal_type		= p_adm_cal_type		AND
  			apac.adm_ci_sequence_number	= p_old_adm_ci_sequence_number;
  	CURSOR c_apac2(
  		cp_apac1_admission_cat	IGS_AD_PERD_AD_CAT.admission_cat%TYPE) IS
  		SELECT 'X'
  		FROM	IGS_AD_PERD_AD_CAT	apac
  		WHERE	apac.adm_cal_type		= p_adm_cal_type		AND
  			apac.adm_ci_sequence_number	= p_new_adm_ci_sequence_number	AND
  			apac.admission_cat		= cp_apac1_admission_cat;
    lv_rowid 	VARCHAR2(25);
  BEGIN
  	--Initialise variables
  	p_message_name				:= null;
  	v_apac1_rec_exists 			:= FALSE;
  	v_acat_not_ins				:= FALSE;
  	v_acat_det_not_ins			:= FALSE;
  	v_acat_ins				:= FALSE;
  	--Validate Parameters
  	IF (p_adm_cal_type IS NULL	OR
  			p_old_adm_ci_sequence_number IS NULL	OR
  			p_new_adm_ci_sequence_number IS NULL) THEN
		p_message_name := 'IGS_AD_ADMPRD_CALROLL_ROLLED';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	--Validate that the calendar instance is PLANNED or ACTIVE
  	IF (IGS_AD_VAL_APAC.admp_val_adm_ci(
  			p_adm_cal_type,
  			p_new_adm_ci_sequence_number,
  			v_start_dt,
    			v_end_dt,
    			v_alternate_code,
  			v_message_name) = FALSE) THEN
  		p_message_name := v_message_name;
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	--Check that one IGS_AD_PRD_PS_OF_OPT does not already exist
  	OPEN c_apcoo;
  	FETCH c_apcoo INTO v_apcoo_exist;
  	IF (c_apcoo%FOUND) THEN
  		--Admission perd COURSE offering option restrictions
  		--already exist for this adm period
		p_message_name := 'IGS_AD_ADMPERIOD_OFOP_EXIST';
  		p_return_type := cst_error;
  		CLOSE c_apcoo;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_apcoo;
  	--Insert log if it doesn't already exist
  	IF (p_s_log_type IS NULL) THEN
  		v_s_log_type := 'ADM-ROLL';
  		--Get start and end dates for the admission period
  		OPEN c_ci;
  		FETCH c_ci INTO v_ci_start_dt,
  				v_ci_end_dt;
  		IF (c_ci%NOTFOUND) THEN
  			v_adm_calendar := p_adm_cal_type;
  		ELSE
  			v_adm_calendar :=
  					p_adm_cal_type||'('||TO_CHAR(v_ci_start_dt,'DD/MM/YYYY')||'-'||
  					TO_CHAR(v_ci_end_dt,'DD/MM/YYYY')||')';
  		END IF;
  		CLOSE c_ci;
  		--Insert an entry into the system log
  		IGS_GE_GEN_003.GENP_INS_LOG(
  			v_s_log_type,
  			(RPAD(p_acad_alternate_code,10)||' '||RPAD(v_adm_calendar,35)),
  			v_creation_dt);
  	ELSE
  		v_s_log_type	:= p_s_log_type;
  		v_creation_dt	:= p_creation_dt;
  	END IF;
  	FOR v_apac1_rec IN c_apac1 LOOP
  		v_apac1_rec_exists := TRUE;
  		IF (p_admission_cat IS NULL OR
  				(p_admission_cat IS NOT NULL AND
  				p_admission_cat = v_apac1_rec.admission_cat)) THEN
  			--Check that the IGS_AD_PERD_AD_CAT does not already exist
  			OPEN c_apac2(
  				v_apac1_rec.admission_cat);
  			FETCH c_apac2 INTO v_apac2_exist;
  			IF (c_apac2%NOTFOUND) THEN
  				--Check that admission category is not closed
  				IF (IGS_AD_VAL_ACCT.admp_val_ac_closed(
  						v_apac1_rec.admission_cat,
  						v_message_name) = FALSE) THEN
  					--Set variable to indicate that at least one admission category
  					--could not be inserted
  					v_acat_not_ins := TRUE;
  					IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
  							v_s_log_type,
  							v_creation_dt,
  							('APAC' ||','||p_adm_cal_type||','||p_new_adm_ci_sequence_number||','
  							||v_apac1_rec.adm_ci_sequence_number||','||v_apac1_rec.admission_cat),
  							v_message_name,
  							NULL);
  				ELSE
  					--Insert admission period admission category
  					--IGS_GE_NOTE: this will also insert admission period admission process
  					--Categories via the database trigger

					IGS_AD_PERD_AD_CAT_Pkg.Insert_Row (
						X_Mode                              => 'R',
						X_RowId                             => lv_rowid,
						X_Adm_Cal_Type                      => v_apac1_rec.adm_cal_type,
						X_Adm_Ci_Sequence_Number            => p_new_adm_ci_sequence_number,
						X_Admission_Cat                     => v_apac1_rec.admission_cat,
						X_Ci_Start_Dt                       => NULL,
						X_Ci_End_Dt                         => NULL
					);

					  --  Navin.Sinha 9/26/2003 Enhancement: 3132406 ENFORCE SINGLE RESPONSE TO OFFER
					  -- Addded following call to igs_ad_val_apac.admp_ins_dflt_apapc.
					  IF igs_ad_val_apac.admp_ins_dflt_apapc (
						v_apac1_rec.adm_cal_type,
						p_new_adm_ci_sequence_number,
						v_apac1_rec.admission_cat,
						v_message_name,
						p_old_adm_ci_sequence_number -- p_ prior_adm_ci_seq_number is NULL if not Rollover
						 ) = FALSE THEN
						  Fnd_Message.Set_Name ('IGS', v_message_name);
						  IGS_GE_MSG_STACK.ADD;
						  APP_EXCEPTION.RAISE_EXCEPTION;
					  END IF;

  					v_acat_ins := TRUE;
  				END IF;
  			END IF;
  			CLOSE c_apac2;
  			v_acat_ins := TRUE;
  			--Insert admission period COURSE offering options
  			IF (IGS_AD_INS_ADMPERD.admp_ins_apapc_apcoo(
  					p_acad_alternate_code,
  					p_adm_cal_type,
  					p_old_adm_ci_sequence_number,
  					v_apac1_rec.admission_cat,
  					p_new_adm_ci_sequence_number,
  					v_apac1_rec.admission_cat,
  					'Y',  --indicates this is called from the rollover process
  					v_s_log_type,
  					v_creation_dt,
  					v_message_name,
  					p_return_type) = FALSE) THEN
  				v_acat_det_not_ins := TRUE;
  			END IF;
  		END IF;
  	END LOOP;
  	IF (NOT v_apac1_rec_exists) THEN --there are no adm perd adm categories to roll
		p_message_name := 'IGS_AD_NO_ADMPRD_ADMCAT_ROLL';
  		p_return_type := cst_warn;
  		RETURN FALSE;
  	END IF;
  	IF (NOT v_acat_ins) THEN --No adm categories could be rolled
		p_message_name := 'IGS_AD_NONE_ADMCAT_ROLLED';
  		p_return_type := cst_warn;
  		RETURN FALSE;
  	END IF;
  	IF (v_acat_not_ins) THEN --At least adm category could not be rolled
		p_message_name := 'IGS_AD_ONE_ADMPRD_NOT_ROLLED';
  		p_return_type := cst_warn;
  		RETURN FALSE;
  	END IF;
  	IF (v_acat_det_not_ins) THEN --At least one adm category details not rolled
		p_message_name := 'IGS_AD_ADMPRD_NOT_RELATED_ROL';
  		p_return_type := cst_warn;
  		RETURN FALSE;
  	END IF;
  	--All adm categories rolled without error
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_apcoo%ISOPEN) THEN
  			CLOSE c_apcoo;
  		END IF;
  		IF (c_ci%ISOPEN) THEN
  			CLOSE c_ci;
  		END IF;
  		IF (c_apac1%ISOPEN) THEN
  			CLOSE c_apac1;
  		END IF;
  		IF (c_apac2%ISOPEN) THEN
  			CLOSE c_apac2;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_INS_ADMPERD.admp_ins_adm_ci_roll');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_ins_adm_ci_roll;
  --
  -- Validate if IGS_AD_CAT.admission_cat is closed.

  --
  -- Validate admission period calendar instance


END IGS_AD_INS_ADMPERD;

/
