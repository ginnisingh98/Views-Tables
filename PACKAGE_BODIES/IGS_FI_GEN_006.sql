--------------------------------------------------------
--  DDL for Package Body IGS_FI_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GEN_006" AS
/* $Header: IGSFI44B.pls 120.0 2005/06/01 18:30:52 appldev noship $ */
 --
 -- who               when               what
--  uudayapr       12-dec-2003       Bug#3080983 modfied the procedure finp_mnt_hecs_pymnt_optn
 -- vchappid       20-Feb-2003       Bug# 2747335, new function created, validates user-defined
 --                                  Person Type Id exists in system.
 -- vvutukur       19-Dec-2002       Bug#2680885. Modified finp_mnt_hecs_pymnt_optn.
 -- vvutukur       31-Aug-2002       Bug#2531390.Modified procedures finp_ins_stmnt_o_acc and
 --                                  finp_mnt_pymnt_schd,finp_mnt_hecs_pymnt_optn.
 -- nalkumar       11-Dec-2001       Removed the function finp_mnt_fee_encmb from this package.
 --		                     This is as per the SFCR015-HOLDS DLD. Bug:2126091
 -- Nalin Kumar 16-Jan-2002 Added 'SET VERIFY OFF' before whenever sqlerr... |
 -- gmaheswa      29-Sep-2004     BUG 3787210 Added Closed indicator check for the Alternate Person Id type.

  /* Bug 1956374
   Who msrinivi
   What duplicate removal Pointed genp_val_bus_day to igs_tr_val_tri
  */
PROCEDURE finp_ins_stmnt_o_acc(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  p_correspondence_type IN VARCHAR2 ,
  P_FIN_PERD IN VARCHAR2,
  P_FEE_PERD IN VARCHAR2,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_cat IN IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_person_group_id IN NUMBER ,
  p_institution_cd IN VARCHAR2 ,
  p_addr_type IN VARCHAR2 ,
  P_DATE_OF_ISSUE_C IN VARCHAR2,
  p_comment IN VARCHAR2 ,
  p_test_extraction IN VARCHAR2 ,
  p_org_id NUMBER
 ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        31-Aug-2002  Bug#2531390.Modified message name IGS_GE_OBSOLETE_CONC_PROGRAM to
  ||                               IGS_GE_OBSOLETE_JOB,as the former message name does not exist.
  ----------------------------------------------------------------------------*/
BEGIN
	retcode:=0;
-- As per the SFCR005, this concurrent program is obsolete and if the user tries
-- to run this program, then an error message should be logged into the log file that
-- the concurrent program is obsoleted and should not be run
  FND_MESSAGE.Set_Name('IGS',
                       'IGS_GE_OBSOLETE_JOB');
  FND_FILE.Put_Line(FND_FILE.Log,
                    FND_MESSAGE.Get);
EXCEPTION
	WHEN OTHERS THEN
		RETCODE:=2;
		ERRBUF:=FND_MESSAGE.GET_STRING ('IGS','IGS_GE_UNHANDLED_EXP');
		IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END finp_ins_stmnt_o_acc;

PROCEDURE finp_mnt_pymnt_schdl(
 errbuf  out NOCOPY  varchar2,
 retcode out NOCOPY  number,
 P_FEE_ASSESSMENT_PERIOD IN VARCHAR2,
 p_person_id IN     IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
 p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
 p_fee_category IN  IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
 p_notification_dt_c IN VARCHAR2,
 p_num_days_to_notification  NUMBER ,
 p_next_bus_day_ind IN VARCHAR,
 p_org_id NUMBER
) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        31-Aug-2002  Bug#2531390.Modified message name IGS_GE_OBSOLETE_CONC_PROGRAM to
  ||                               IGS_GE_OBSOLETE_JOB,as the former message name does not exist.
  ----------------------------------------------------------------------------*/
BEGIN
-- As per the SFCR005, this concurrent program is obsolete and if the user tries
-- to run this program, then an error message should be logged into the log file that
-- the concurrent program is obsoleted and should not be run
  FND_MESSAGE.Set_Name('IGS',
                       'IGS_GE_OBSOLETE_JOB');
  FND_FILE.Put_Line(FND_FILE.Log,
                    FND_MESSAGE.Get);
  retcode := 0;

EXCEPTION
  WHEN OTHERS THEN
		RETCODE:=2;
		ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END finp_mnt_pymnt_schdl;

FUNCTION finp_mnt_hecs_pymnt_optn(
  p_effective_dt IN DATE ,
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_fee_cal_type IN IGS_CA_INST_ALL.CAL_TYPE%TYPE ,
  p_fee_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_fee_cat IN IGS_EN_STDNT_PS_ATT_ALL.FEE_CAT%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_update_ind IN VARCHAR2,
  p_deferred_payment_option  IGS_FI_HECS_PAY_OPTN.HECS_PAYMENT_OPTION%TYPE ,
  p_upfront_payment_option  IGS_FI_HECS_PAY_OPTN.HECS_PAYMENT_OPTION%TYPE ,
  p_creation_dt IN OUT NOCOPY IGS_GE_S_LOG.creation_dt%TYPE ,
  p_hecs_payment_type OUT NOCOPY FND_LOOKUP_Values.LOOKUP_CODE%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
       uudayapr         12-12-2003  bug#3080983 made the modification to Cursor c_fadv to point to the table
                                    IGS_FI_FEE_AS instead IGS_FI_FEE_ASS_DEBT_V view.
  ||  vvutukur        19-Dec-2002  Bug#2680885.Commented out cursor c_fpv which selects from igs_fi_fee_pay_v, which
  ||                               is to be dropped.Instead, cursor c_fpv is redefined selecting 0 from dual. This
  ||                               function will be obsoleted as part of HECS functionality obsoletion. As this got
  ||                               deferred for Jan'03 scope,commented out this portion.
  ||  vvutukur        30-Aug-2002  Bug#2531390.Removed default value of p_update_ind parameter to avoid
  ||                               gscc warning.
  ----------------------------------------------------------------------------*/
	gv_other_detail		VARCHAR2(255);
	e_resource_busy_exception	EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
	-- cursor to get student IGS_PS_COURSE HECS payment option details
	CURSOR c_scho(
		cp_effective_dt		DATE,
		cp_person_id		IGS_EN_STDNT_PS_ATT.person_id%TYPE,
		cp_course_cd		IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
                SELECT  IGS_EN_STDNTPSHECSOP.*, rowid
		FROM	IGS_EN_STDNTPSHECSOP
		WHERE	person_id 		= cp_person_id AND
			course_cd 		= cp_course_cd AND
			TRUNC(cp_effective_dt) 	>= TRUNC(start_dt) AND
			TRUNC(cp_effective_dt) 	<= TRUNC(NVL(end_dt, cp_effective_dt))
		FOR UPDATE OF end_dt NOWAIT;
BEGIN	-- finp_mnt_hecs_pymnt_optn
	-- Maintain a student's IGS_PS_COURSE attempt HECS payment option on the basis of
	-- their assessed liability and any up front payment made.
DECLARE
	CURSOR c_hpo (
		cp_payment_option 	IGS_FI_HECS_PAY_OPTN.HECS_PAYMENT_OPTION%TYPE,
		cp_hecs_payment_type	IGS_FI_GOV_HEC_PA_OP.s_hecs_payment_type%TYPE) IS
		SELECT	HECS_PAYMENT_OPTION
		FROM	IGS_FI_HECS_PAY_OPTN 		hpo,
			IGS_FI_GOV_HEC_PA_OP 	ghpo
		WHERE	hpo.HECS_PAYMENT_OPTION 	= cp_payment_option AND
			hpo.closed_ind 			= 'N' AND
			hpo.GOVT_HECS_PAYMENT_OPTION 	= ghpo.GOVT_HECS_PAYMENT_OPTION AND
			ghpo.s_hecs_payment_type 	= cp_hecs_payment_type;
	CURSOR c_ghpo(
		cp_payment_option 	IGS_FI_HECS_PAY_OPTN.HECS_PAYMENT_OPTION%TYPE) IS
		SELECT	ghpo.s_hecs_payment_type
		FROM	IGS_FI_HECS_PAY_OPTN 	 	hpo,
			IGS_FI_GOV_HEC_PA_OP 	ghpo
		WHERE	hpo.HECS_PAYMENT_OPTION 	= cp_payment_option AND
			hpo.GOVT_HECS_PAYMENT_OPTION 	= ghpo.GOVT_HECS_PAYMENT_OPTION;
-- Modified the Cursor c_fadv to fetch the Data from the table IGS_FI_FEE_AS
-- Instead of the the View IGS_FI_FEE_ASS_DEBT_V
	CURSOR c_fadv   IS
     SELECT	SUM(fadv.transaction_amount)
     FROM	IGS_FI_FEE_AS  	fadv,
			    IGS_FI_FEE_TYPE	ft
     WHERE 	fadv.person_id 		= p_person_id
     AND		fadv.fee_cal_type 	= p_fee_cal_type
     AND    fadv.fee_ci_sequence_number = p_fee_ci_sequence_number
     AND    ((fadv.FEE_CAT 		= p_fee_cat) OR (fadv.FEE_CAT IS NULL AND  p_fee_cat IS NULL))
     AND    ((fadv.course_cd 		= p_course_cd ) OR (fadv.course_cd IS NULL AND  p_course_cd IS NULL))
     AND    fadv.FEE_TYPE 		= ft.FEE_TYPE
     AND  	ft.s_fee_type 		= 'HECS'
     AND    fadv.logical_delete_dt IS NULL
     GROUP BY fadv.person_id,fadv.fee_cal_type,fadv.fee_ci_sequence_number
           HAVING SUM(fadv.transaction_amount) >0;

        CURSOR c_fpv IS
        SELECT 0
        FROM   dual;

/*	CURSOR c_fpv IS
		SELECT	SUM(fpv.payment_amount)
		FROM	IGS_FI_FEE_PAY_V 	fpv,
			IGS_FI_FEE_TYPE	ft
		WHERE	fpv.person_id 		= p_person_id AND
			fpv.fee_cal_type 	= p_fee_cal_type AND
			fpv.fee_ci_sequence_number = p_fee_ci_sequence_number AND
			fpv.FEE_CAT 		= p_fee_cat AND
			fpv.course_cd 		= p_course_cd AND
			fpv.payment_amount 	> 0 AND
			fpv.FEE_TYPE 		= ft.FEE_TYPE AND
			ft.s_fee_type 		= 'HECS';*/
	CURSOR c_scho2(
		cp_end_dt			DATE) IS
		SELECT	tax_file_number,
			tax_file_number_collected_dt,
			tax_file_certificate_number
		FROM	IGS_EN_STDNTPSHECSOP
		WHERE	person_id 	= p_person_id AND
			course_cd 	= p_course_cd AND
			start_dt 	> cp_end_dt AND
			(tax_file_number 	IS NOT NULL AND
			tax_file_invalid_dt 	IS NULL) OR
			tax_file_certificate_number IS NOT NULL
		ORDER BY start_dt;
	v_hpo_upfront_rec		c_hpo%ROWTYPE;
	v_hpo_deferred_rec		c_hpo%ROWTYPE;
	v_ghpo_rec			c_ghpo%ROWTYPE;
	v_scho_rec			c_scho%ROWTYPE;
	v_assessment_amount_sum		NUMBER;
	v_payment_amount_sum		NUMBER;
	v_tax_file_number 		IGS_EN_STDNTPSHECSOP.tax_file_number%TYPE;
	v_tax_file_number_collected_dt
			IGS_EN_STDNTPSHECSOP.tax_file_number_collected_dt%TYPE;
	v_tax_file_certificate_number
			IGS_EN_STDNTPSHECSOP.tax_file_certificate_number%TYPE;
	v_deferred_payment_option 	IGS_FI_HECS_PAY_OPTN.HECS_PAYMENT_OPTION%TYPE
					DEFAULT p_deferred_payment_option;
	v_upfront_payment_option 	IGS_FI_HECS_PAY_OPTN.HECS_PAYMENT_OPTION%TYPE
					DEFAULT p_upfront_payment_option;
	v_valid_tax_details 		BOOLEAN DEFAULT FALSE;
	v_key				IGS_GE_S_LOG.key%TYPE DEFAULT NULL;
	v_text				IGS_GE_S_LOG_ENTRY.text%TYPE DEFAULT NULL;
	v_deferred_option		BOOLEAN DEFAULT FALSE;
	v_effective_dt    		DATE ;
        lv_rowid VARCHAR2(25);
BEGIN
	-- Set the default message number
	p_message_name := null;
	-- Check Parameters
	IF p_effective_dt IS NULL OR
			p_person_id IS NULL OR
			p_fee_cal_type IS NULL OR
			p_fee_ci_sequence_number IS NULL OR
			p_fee_cat IS NULL OR
			p_course_cd IS NULL OR
			p_update_ind IS NULL THEN
              Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
               IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
	END IF;
	IF p_effective_dt > SYSDATE THEN
		p_message_name:= 'IGS_GE_INVALID_VALUE';
		RETURN FALSE;
	END IF;
	IF p_update_ind = 'Y' THEN
		-- Validate the deferred payment option parameter
		IF p_deferred_payment_option IS NULL THEN
			p_message_name:= 'IGS_AD_ADMPRD_DTALIAS_EXISTS';
			RETURN FALSE;
		ELSE
			OPEN c_hpo(
				p_deferred_payment_option,
				'DEFERRED');
			FETCH c_hpo INTO v_hpo_deferred_rec;
			IF c_hpo%NOTFOUND THEN
				CLOSE c_hpo;
				p_message_name:= 'IGS_AD_ADMPRD_DTALIAS_EXISTS';
				RETURN FALSE;
			END IF;
			CLOSE c_hpo;
		END IF;
		-- Validate the upfront payment option parameter
		IF p_upfront_payment_option IS NULL THEN
			p_message_name:= 'IGS_GE_INVALID_VALUE';
			RETURN FALSE;
		ELSE
			OPEN c_hpo(
				p_upfront_payment_option,
				'UPFRONT_D');
			FETCH c_hpo INTO v_hpo_upfront_rec;
			IF c_hpo%NOTFOUND THEN
				CLOSE c_hpo;
				p_message_name:= 'IGS_GE_INVALID_VALUE';
				RETURN FALSE;
			END IF;
			CLOSE c_hpo;
		END IF;
	END IF;
	-- Get the HECS payment option matching the effective date.
	-- IGS_GE_NOTE, later entries may exist.
	OPEN c_scho(
		p_effective_dt,
		p_person_id,
		p_course_cd);
	FETCH c_scho INTO v_scho_rec;
	IF c_scho%NOTFOUND THEN
		CLOSE c_scho;
		p_message_name:= 'IGS_GE_INVALID_VALUE';
		RETURN FALSE;
	END IF;
	-- Get the HECS payment option payment type
	OPEN c_ghpo( v_scho_rec.HECS_PAYMENT_OPTION);
	FETCH c_ghpo INTO v_ghpo_rec;
	IF c_ghpo%NOTFOUND THEN
		CLOSE c_ghpo;
		CLOSE c_scho;
		RAISE NO_DATA_FOUND;
	END IF;
	CLOSE c_ghpo;
	p_hecs_payment_type := v_ghpo_rec.s_hecs_payment_type;
	-- Get the current debt balance.
	-- IGS_GE_NOTE, multiple fee types could be recognised as HECS fees.
	OPEN c_fadv;
	FETCH c_fadv INTO v_assessment_amount_sum;
	IF c_fadv%NOTFOUND THEN
		CLOSE c_fadv;
		CLOSE c_scho;
		RETURN TRUE;
	END IF;
	CLOSE c_fadv;
	IF v_assessment_amount_sum IS NULL THEN
		v_assessment_amount_sum := 0;
	END IF;
	-- Check current payment balance
	OPEN c_fpv;
	FETCH c_fpv INTO v_payment_amount_sum;
	IF c_fpv%NOTFOUND THEN
		CLOSE c_fpv;
		-- Considering no payments have been made, the current payment
		-- type should be deferred
		v_deferred_option := TRUE;
	ELSE
		CLOSE c_fpv;
		IF v_payment_amount_sum IS NULL THEN
			v_payment_amount_sum := 0;
		END IF;
		IF v_payment_amount_sum < v_assessment_amount_sum THEN
			-- Considering full payment has not been made, the current payment
			-- type should be deferred
			v_deferred_option := TRUE;
		END IF;
	END IF;
	IF v_deferred_option THEN
		-- 1.1 Deferred Payment
		-- Students with UPFRONT_D (up front with discount) can be switched
		-- to a deferred payment type option when tax file details are known.
		IF v_ghpo_rec.s_hecs_payment_type = 'UPFRONT_D' THEN
			-- 1.1.1 Check Tax File Details
			IF (v_scho_rec.tax_file_number IS NOT NULL AND
					v_scho_rec.tax_file_invalid_dt IS NULL) OR
					v_scho_rec.tax_file_certificate_number IS NOT NULL THEN
				v_tax_file_number := v_scho_rec.tax_file_number;
				v_tax_file_number_collected_dt := v_scho_rec.tax_file_number_collected_dt;
				v_tax_file_certificate_number := v_scho_rec.tax_file_certificate_number;
				v_valid_tax_details := TRUE;
			ELSE
				-- Check later payment option details
				IF v_scho_rec.end_dt IS NOT NULL THEN
					FOR v_scho_chk_rec IN c_scho2(
								v_scho_rec.end_dt) LOOP
							v_tax_file_number := v_scho_chk_rec.tax_file_number;
							v_tax_file_number_collected_dt :=
								v_scho_chk_rec.tax_file_number_collected_dt;
							v_tax_file_certificate_number :=
								v_scho_chk_rec.tax_file_certificate_number;
							v_valid_tax_details := TRUE;
							EXIT;
					END LOOP;
				END IF;
			END IF;
			IF NOT v_valid_tax_details THEN
				v_key := igs_ge_date.igschar(p_effective_dt) || '|' ||
						TO_CHAR(p_person_id) || '|' ||
						p_fee_cal_type || '|' ||
						TO_CHAR(p_fee_ci_sequence_number) || '|' ||
						p_fee_cat || '|' ||
						p_course_cd;
				IF p_creation_dt IS NULL THEN
					-- Initialise the log
					p_creation_dt := SYSDATE;
					IGS_GE_GEN_003.GENP_INS_LOG(
						'HECS-OPT',
						v_key,
						p_creation_dt);
				END IF;
				IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
					'HECS-OPT',
					p_creation_dt,
					v_key,
					'IGS_GE_INVALID_VALUE',
					NULL);
			ELSE	-- valid
				p_hecs_payment_type := 'DEFERRED';
				IF p_update_ind = 'Y' THEN
					IF TRUNC(v_scho_rec.start_dt) <> TRUNC(p_effective_dt) THEN
						-- end the current IGS_EN_STDNTPSHECSOP entry
					        IGS_EN_STDNTPSHECSOP_Pkg.Update_Row (
        					  x_rowid => v_scho_rec.rowid,
        					  x_person_id => v_scho_rec.person_id,
        					  x_course_cd => v_scho_rec.course_cd,
        					  x_start_dt => v_scho_rec.start_dt,
        					  x_end_dt => p_effective_dt - 1,
        					  x_hecs_payment_option => v_scho_rec.hecs_payment_option,
        					  x_differential_hecs_ind => v_scho_rec.differential_hecs_ind,
        					  x_diff_hecs_ind_update_who => v_scho_rec.diff_hecs_ind_update_who,
        					  x_diff_hecs_ind_update_on => v_scho_rec.diff_hecs_ind_update_on,
        					  x_outside_aus_res_ind => v_scho_rec.outside_aus_res_ind,
        					  x_nz_citizen_ind => v_scho_rec.nz_citizen_ind,
        					  x_nz_citizen_less2yr_ind => v_scho_rec.nz_citizen_less2yr_ind,
        					  x_nz_citizen_not_res_ind => v_scho_rec.nz_citizen_not_res_ind,
        					  x_safety_net_ind => v_scho_rec.safety_net_ind,
        					  x_tax_file_number => v_scho_rec.tax_file_number,
        					  x_tax_file_number_collected_dt => v_scho_rec.tax_file_number_collected_dt,
        					  x_tax_file_invalid_dt => v_scho_rec.tax_file_invalid_dt,
        					  x_tax_file_certificate_number => v_scho_rec.tax_file_certificate_number,
        					  x_diff_hecs_ind_update_comment => v_scho_rec.diff_hecs_ind_update_comments,
        					  x_mode => 'R'
      					        );
						-- Create a new hecs payment option entry for
						-- the student IGS_PS_COURSE attempt
                                                 v_effective_dt := p_effective_dt;
                                                IGS_EN_STDNTPSHECSOP_Pkg.Insert_Row (
                                                  x_rowid => lv_rowid,
                                                  x_person_id => v_scho_rec.person_id,
                                                  x_course_cd => v_scho_rec.course_cd,
                                                  x_start_dt => v_effective_dt,
                                                  x_end_dt => v_scho_rec.end_dt,
                                                  x_hecs_payment_option => p_upfront_payment_option,
                                                  x_differential_hecs_ind => v_scho_rec.differential_hecs_ind,
					          x_diff_hecs_ind_update_who => Null,
        					  x_diff_hecs_ind_update_on => Null,
                                                  x_outside_aus_res_ind => v_scho_rec.outside_aus_res_ind,
                                                  x_nz_citizen_ind => v_scho_rec.nz_citizen_ind,
                                                  x_nz_citizen_less2yr_ind => v_scho_rec.nz_citizen_less2yr_ind,
                                                  x_nz_citizen_not_res_ind => v_scho_rec.nz_citizen_not_res_ind,
                                                  x_safety_net_ind => 'Y',
                                                  x_tax_file_number => v_tax_file_number,
                                                  x_tax_file_number_collected_dt => v_tax_file_number_collected_dt,
        					  x_tax_file_invalid_dt => Null,
                                                  x_tax_file_certificate_number => v_tax_file_certificate_number,
					          x_diff_hecs_ind_update_comment => Null,
                                                  x_mode => 'R'
                                                 );
					ELSE	-- HECS option detail commenced on the effective dt
				      		IGS_EN_STDNTPSHECSOP_Pkg.Update_Row (
       							x_rowid => v_scho_rec.rowid,
       							x_person_id => v_scho_rec.person_id,
       							x_course_cd => v_scho_rec.course_cd,
       							x_start_dt => v_scho_rec.start_dt,
       							x_end_dt => v_scho_rec.end_dt,
       							x_hecs_payment_option => p_deferred_payment_option,
       							x_differential_hecs_ind => v_scho_rec.differential_hecs_ind,
       							x_diff_hecs_ind_update_who => v_scho_rec.diff_hecs_ind_update_who,
       							x_diff_hecs_ind_update_on => v_scho_rec.diff_hecs_ind_update_on,
       							x_outside_aus_res_ind => v_scho_rec.outside_aus_res_ind,
       							x_nz_citizen_ind => v_scho_rec.nz_citizen_ind,
       							x_nz_citizen_less2yr_ind => v_scho_rec.nz_citizen_less2yr_ind,
       							x_nz_citizen_not_res_ind => v_scho_rec.nz_citizen_not_res_ind,
       							x_safety_net_ind => 'N',
       							x_tax_file_number => v_tax_file_number,
       							x_tax_file_number_collected_dt => v_tax_file_number_collected_dt,
       							x_tax_file_invalid_dt => v_scho_rec.tax_file_invalid_dt,
       							x_tax_file_certificate_number => v_tax_file_certificate_number,
       							x_diff_hecs_ind_update_comment => v_scho_rec.diff_hecs_ind_update_comments,
       							x_mode => 'R'
      				      		);
 					END IF;
					-- log entry
					v_text := ' ' ||
							v_scho_rec.HECS_PAYMENT_OPTION || '  ' ||
							p_deferred_payment_option;
					v_key := igs_ge_date.igschar(p_effective_dt) || '|' ||
							TO_CHAR(p_person_id) || '|' ||
							p_fee_cal_type || '|' ||
							TO_CHAR(p_fee_ci_sequence_number) || '|' ||
							p_fee_cat || '|' ||
							p_course_cd;
					IF p_creation_dt IS NULL THEN
						-- Initialise the log
						p_creation_dt := SYSDATE;
						IGS_GE_GEN_003.GENP_INS_LOG(
							'HECS-OPT',
							v_key,
							p_creation_dt);
					END IF;
					IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
						'HECS-OPT',
						p_creation_dt,
						v_key,
						NULL,
						v_text);
				END IF;
			END IF;
		END IF;
	ELSE	-- v_deferred_option = FALSE
		-- 1.2 Up Front Payment
		IF v_ghpo_rec.s_hecs_payment_type = 'DEFERRED' THEN
			p_hecs_payment_type := 'UPFRONT_D';
			IF p_update_ind = 'Y' THEN
				IF TRUNC(v_scho_rec.start_dt) <> TRUNC(p_effective_dt) THEN
					-- End the current student IGS_PS_COURSE hecs option entry
				      	IGS_EN_STDNTPSHECSOP_Pkg.Update_Row (
       						x_rowid => v_scho_rec.rowid,
       						x_person_id => v_scho_rec.person_id,
       						x_course_cd => v_scho_rec.course_cd,
       						x_start_dt => v_scho_rec.start_dt,
       						x_end_dt => p_effective_dt - 1,
       						x_hecs_payment_option => v_scho_rec.hecs_payment_option,
       						x_differential_hecs_ind => v_scho_rec.differential_hecs_ind,
       						x_diff_hecs_ind_update_who => v_scho_rec.diff_hecs_ind_update_who,
       						x_diff_hecs_ind_update_on => v_scho_rec.diff_hecs_ind_update_on,
       						x_outside_aus_res_ind => v_scho_rec.outside_aus_res_ind,
       						x_nz_citizen_ind => v_scho_rec.nz_citizen_ind,
       						x_nz_citizen_less2yr_ind => v_scho_rec.nz_citizen_less2yr_ind,
       						x_nz_citizen_not_res_ind => v_scho_rec.nz_citizen_not_res_ind,
       						x_safety_net_ind => v_scho_rec.safety_net_ind,
       						x_tax_file_number => v_scho_rec.tax_file_number,
       						x_tax_file_number_collected_dt => v_scho_rec.tax_file_number_collected_dt,
       						x_tax_file_invalid_dt => v_scho_rec.tax_file_invalid_dt,
       						x_tax_file_certificate_number => v_scho_rec.tax_file_certificate_number,
       						x_diff_hecs_ind_update_comment => v_scho_rec.diff_hecs_ind_update_comments,
       						x_mode => 'R'
      				      	);
					-- Create a new hecs payment option entry for
					-- the student IGS_PS_COURSE attempt
                                         v_effective_dt := p_effective_dt;
                                         IGS_EN_STDNTPSHECSOP_Pkg.Insert_Row (
                                           x_rowid => lv_rowid,
                                           x_person_id => v_scho_rec.person_id,
                                           x_course_cd => v_scho_rec.course_cd,
                                           x_start_dt => v_effective_dt,
                                           x_end_dt => v_scho_rec.end_dt,
                                           x_hecs_payment_option => p_upfront_payment_option,
                                           x_differential_hecs_ind => v_scho_rec.differential_hecs_ind,
                                           x_diff_hecs_ind_update_who => Null,
 					   x_diff_hecs_ind_update_on => Null,
                                           x_outside_aus_res_ind => v_scho_rec.outside_aus_res_ind,
                                           x_nz_citizen_ind => v_scho_rec.nz_citizen_ind,
                                           x_nz_citizen_less2yr_ind => v_scho_rec.nz_citizen_less2yr_ind,
                                           x_nz_citizen_not_res_ind => v_scho_rec.nz_citizen_not_res_ind,
                                           x_safety_net_ind => 'Y',
                                           x_tax_file_number => v_tax_file_number,
                                           x_tax_file_number_collected_dt => v_tax_file_number_collected_dt,
 					   x_tax_file_invalid_dt => Null,
                                           x_tax_file_certificate_number => v_tax_file_certificate_number,
                                           x_diff_hecs_ind_update_comment => Null,
                                           x_mode => 'R'
                                          );
				ELSE	-- HECS option detail commenced on the effective dt
				        IGS_EN_STDNTPSHECSOP_Pkg.Update_Row (
       				  	  x_rowid => v_scho_rec.rowid,
       				  	  x_person_id => v_scho_rec.person_id,
       					  x_course_cd => v_scho_rec.course_cd,
       					  x_start_dt => v_scho_rec.start_dt,
       					  x_end_dt => v_scho_rec.end_dt,
       					  x_hecs_payment_option => p_upfront_payment_option,
       					  x_differential_hecs_ind => v_scho_rec.differential_hecs_ind,
       					  x_diff_hecs_ind_update_who => v_scho_rec.diff_hecs_ind_update_who,
       					  x_diff_hecs_ind_update_on => v_scho_rec.diff_hecs_ind_update_on,
       					  x_outside_aus_res_ind => v_scho_rec.outside_aus_res_ind,
       					  x_nz_citizen_ind => v_scho_rec.nz_citizen_ind,
       					  x_nz_citizen_less2yr_ind => v_scho_rec.nz_citizen_less2yr_ind,
       					  x_nz_citizen_not_res_ind => v_scho_rec.nz_citizen_not_res_ind,
       					  x_safety_net_ind => 'Y',
       					  x_tax_file_number => v_scho_rec.tax_file_number,
       					  x_tax_file_number_collected_dt => v_scho_rec.tax_file_number_collected_dt,
       					  x_tax_file_invalid_dt => v_scho_rec.tax_file_invalid_dt,
       					  x_tax_file_certificate_number => v_scho_rec.tax_file_certificate_number,
       					  x_diff_hecs_ind_update_comment => v_scho_rec.diff_hecs_ind_update_comments,
       					  x_mode => 'R'
      				        );
				END IF;
				-- log entry
				v_text := ' ' ||
						v_scho_rec.HECS_PAYMENT_OPTION || '  ' ||
						p_upfront_payment_option;
				v_key := igs_ge_date.igschar(p_effective_dt) || '|' ||
						TO_CHAR(p_person_id) || '|' ||
						p_fee_cal_type || '|' ||
						TO_CHAR(p_fee_ci_sequence_number) || '|' ||
						p_fee_cat || '|' ||
						p_course_cd;
				IF p_creation_dt IS NULL THEN
					-- Initialise the log
					p_creation_dt := SYSDATE;
					IGS_GE_GEN_003.GENP_INS_LOG(
						'HECS-OPT',
						v_key,
						p_creation_dt);
				END IF;
				IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
					'HECS-OPT',
					p_creation_dt,
					v_key,
					NULL,
					v_text);
			END IF;
		END IF;
	END IF;
	CLOSE c_scho;
	RETURN TRUE;
END;
EXCEPTION
	WHEN e_resource_busy_exception THEN
		CLOSE c_scho;
		p_message_name:= 'IGS_AD_OFRST_LATE_FEES';
		RETURN FALSE;
	WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	       Fnd_Message.Set_Token('NAME','IGS_FI_GEN_006.finp_mnt_hecs_pymnt_optn');
        IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END finp_mnt_hecs_pymnt_optn;

PROCEDURE validate_prsn_id_typ(p_c_usr_alt_prs_id_typ IN VARCHAR2,
                               p_c_unique IN VARCHAR2,
                               p_b_status OUT NOCOPY BOOLEAN,
                               p_c_sys_alt_prs_id_typ OUT NOCOPY VARCHAR2)
AS
  /*----------------------------------------------------------------------------
  ||  Created By : Vinay Chappidi
  ||  Created On : 20-Feb-2003
  ||  Purpose : Validates user-defined person id type
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gmaheswa      29-Sep-2004     BUG 3787210 Added Closed indicator check for the Alternate Person Id type.
  ----------------------------------------------------------------------------*/

  CURSOR cur_usr_alt_prs_id_typ(cp_c_usr_alt_prs_id_typ igs_pe_person_id_typ.person_id_type%TYPE,
                                cp_c_unique igs_pe_person_id_typ.unique_ind%TYPE)
  IS
  SELECT s_person_id_type
  FROM igs_pe_person_id_typ
  WHERE person_id_type = cp_c_usr_alt_prs_id_typ AND
        NVL(unique_ind,'N') = cp_c_unique AND
	closed_ind = 'N';
  l_c_sys_prsn_id_typ  igs_pe_person_id_typ.s_person_id_type%TYPE;

BEGIN

  -- Check if the mandatory parameters are passed to this procedure
  -- return from the procedure when not passed
  IF (p_c_usr_alt_prs_id_typ IS NULL OR p_c_unique IS NULL) THEN
    p_b_status := FALSE;
    p_c_sys_alt_prs_id_typ := NULL;
    RETURN;
  END IF;

  -- Check if the p_c_unique parameter value is other than 'Y' or 'N'
  -- return from the procedure when any other values are passed
  IF (p_c_unique NOT IN ('Y','N')) THEN
    p_b_status := FALSE;
    p_c_sys_alt_prs_id_typ := NULL;
    RETURN;
  END IF;

  -- When all the mandatory validations are successful, check if the user-defined alternate person id type
  -- exists in the system and assign appropriate values to OUT variables and return from the procedure.
  OPEN cur_usr_alt_prs_id_typ(p_c_usr_alt_prs_id_typ, p_c_unique);
  FETCH cur_usr_alt_prs_id_typ INTO l_c_sys_prsn_id_typ;
  IF (cur_usr_alt_prs_id_typ%NOTFOUND) THEN
    CLOSE cur_usr_alt_prs_id_typ;
    p_b_status := FALSE;
    p_c_sys_alt_prs_id_typ := NULL;
  ELSE
    CLOSE cur_usr_alt_prs_id_typ;
    p_b_status := TRUE;
    p_c_sys_alt_prs_id_typ := l_c_sys_prsn_id_typ;
  END IF;
END validate_prsn_id_typ;
END igs_fi_gen_006;

/
