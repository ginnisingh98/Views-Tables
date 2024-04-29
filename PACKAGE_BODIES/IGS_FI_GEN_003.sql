--------------------------------------------------------
--  DDL for Package Body IGS_FI_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GEN_003" AS
/* $Header: IGSFI03B.pls 120.5 2005/08/29 05:21:14 appldev ship $ */

/******************************************************************
 Change History
     svuppala  23-JUN-2005   Bug 3392088 Modifications as part of CPF build
                             Added 2 functions finp_del_fsert , finp_del_fser
    rnirwani       05-May-02        removed reference to IGS_FI_DSBR_SPSHT
                                    bug# 2329407
    rnirwani       25-Apr-02        Obsoleted the procedures:
                                    finp_ins_disb_jnl
                                    FINP_DEL_DISB_JNL
                                    Bug# 2329407
 --
 -- nalkumar       30-Nov-2001       Removed the funtion FINP_INS_PRSN_ENCMB from this package.
 --		                     This is as per the SFCR015-HOLDS DLD. Bug:2126091
 -- nalkumar       16-Jan-2002 Added 'SET VERIFY OFF' before whenever sqlerr... |
 --
--
*************************************************************************/

PROCEDURE FINP_DEL_DISB_SNPSHT(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  NUMBER,
  p_fee_period IN VARCHAR2,
  p_fee_type VARCHAR2 ,
  p_snapshot_create_dt_C VARCHAR2 ,
  p_delete_ds_ind  VARCHAR2 ,
  p_delete_dsd_ind  VARCHAR2 ,
  p_delete_dda_ind  VARCHAR2 ,
  p_org_id NUMBER
) AS
BEGIN
-- As per SFCR005, this Concurrent Program is obsolete and if the user is trying to
-- run the program then an error message should be written to the Log file that
-- the Concurrent Program is obsolete and this should not be run
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
END finp_del_disb_snpsht;
--
FUNCTION finp_del_err(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_range_number IN NUMBER ,
  p_rate_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- finp_del_err
	-- This routine will logically delete all IGS_FI_ELM_RANGE_RT records
	-- associated with an IGS_FI_ELM_RANGE or IGS_FI_FEE_AS_RATE record which is
	-- being logically deleted.
DECLARE
	e_resource_busy_exception		EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
	CURSOR c_err IS
		SELECT
                  ROWID,
                  err_id,
			FEE_TYPE,
			FEE_CAL_TYPE,
			FEE_CI_SEQUENCE_NUMBER,
			S_RELATION_TYPE,
			RANGE_NUMBER,
			RATE_NUMBER,
			CREATE_DT,
			FEE_CAT,
			LOGICAL_DELETE_DT
		FROM	IGS_FI_ELM_RANGE_RT err
		WHERE	err.FEE_TYPE 			= p_fee_type 		AND
			err.fee_cal_type	 	= p_fee_cal_type 			AND
			err.fee_ci_sequence_number	= p_fee_ci_sequence_number	AND
			err.s_relation_type 		= p_s_relation_type 		AND
			NVL(err.FEE_CAT, 'NULL')	= NVL(p_fee_cat, 'NULL') 		AND
			err.range_number 		= NVL(p_range_number, err.range_number) AND
			err.rate_number  		= NVL(p_rate_number, err.rate_number) 	AND
			err.logical_delete_dt 		IS NULL
		FOR UPDATE OF err.logical_delete_dt NOWAIT;
BEGIN
	-- Set the default message number
	p_message_name := Null;
	-- 1. Check parameters.
	IF p_fee_type IS NULL OR
			p_fee_cal_type IS NULL OR
			p_fee_ci_sequence_number IS NULL OR
			p_s_relation_type IS NULL OR
			(p_range_number IS NULL AND
			p_rate_number IS NULL) OR
			(p_range_number IS NOT NULL AND
			p_rate_number IS NOT NULL) THEN
		RETURN TRUE;
	END IF;
	-- 2. Issue a save point for the module so that if locks exist,
	-- a rollback can be performed.
	SAVEPOINT sp_save_point;
	-- Perform a logical delete of the associated IGS_FI_ELM_RANGE_RT items.
	-- Update the appropriate records with NOWAIT option.
	FOR v_err_rec IN c_err LOOP
		IGS_FI_ELM_RANGE_RT_PKG.UPDATE_ROW(
			X_ROWID  => v_err_rec.ROWID,
                        X_ERR_ID => v_err_rec.ERR_ID,
			X_FEE_TYPE  => v_err_rec.FEE_TYPE,
			X_FEE_CAL_TYPE => v_err_rec.FEE_CAL_TYPE,
			X_FEE_CI_SEQUENCE_NUMBER => v_err_rec.FEE_CI_SEQUENCE_NUMBER,
			X_S_RELATION_TYPE => v_err_rec.S_RELATION_TYPE,
			X_RANGE_NUMBER  => v_err_rec.RANGE_NUMBER,
			X_RATE_NUMBER => v_err_rec.RATE_NUMBER,
			X_CREATE_DT => v_err_rec.CREATE_DT,
			X_FEE_CAT => v_err_rec.FEE_CAT,
			X_LOGICAL_DELETE_DT => SYSDATE,
			X_MODE => 'R');
	END LOOP;
	RETURN TRUE;
EXCEPTION
	WHEN e_resource_busy_exception THEN
		IF c_err%ISOPEN THEN
			CLOSE c_err;
		END IF;
		ROLLBACK TO sp_save_point;
		p_message_name := 'IGS_FI_UNABLE_LOGDEL_ELERNG';
		RETURN FALSE;
	WHEN OTHERS THEN
		IF c_err%ISOPEN THEN
			CLOSE c_err;
		END IF;
		RAISE;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
Fnd_Message.Set_Token('NAME','IGS_FI_GEN_003.FINP_DEL_ERR');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END finp_del_err;
--
PROCEDURE finp_del_minor_debt(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  number,
  P_FEE_ASSESSMENT_PERIOD IN VARCHAR2 ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_cat IN IGS_EN_STDNT_PS_ATT_ALL.fee_cat%TYPE ,
  p_course_cd IN igs_ps_course.course_cd%type,
  p_person_id      IN HZ_PARTIES.PARTY_ID%type,
  p_group_id IN IGS_PE_PERSID_GROUP_ALL.group_id%TYPE ,
  p_min_days_overdue IN NUMBER,
  p_max_outstanding IN IGS_FI_FEE_AS_ALL.transaction_amount%TYPE ,
  p_comments IN igs_fi_fee_as_all.comments%type,
  p_org_id NUMBER
) AS

BEGIN
-- As per the CCR05 for Student Finance, this concurrent program is obsoleted
-- and if the user tries to run this program ,then  a message should be logged in the
-- Error log that the Concurrent Program is obsolete and should not be run.
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
END finp_del_minor_debt;
--
FUNCTION finp_ins_cfar(
  p_person_id  IGS_FI_FEE_AS_RT.person_id%TYPE ,
  p_course_cd  IGS_FI_FEE_AS_RT.course_cd%TYPE ,
  p_fee_type  IGS_FI_FEE_AS_RT.FEE_TYPE%TYPE ,
  p_start_dt  IGS_FI_FEE_AS_RT.start_dt%TYPE ,
  p_end_dt  IGS_FI_FEE_AS_RT.end_dt%TYPE ,
  p_location_cd  IGS_FI_FEE_AS_RT.location_cd%TYPE ,
  p_attendance_type  IGS_FI_FEE_AS_RT.ATTENDANCE_TYPE%TYPE ,
  p_attendance_mode  IGS_FI_FEE_AS_RT.ATTENDANCE_MODE%TYPE ,
  p_chg_rate  IGS_FI_FEE_AS_RT.chg_rate%TYPE ,
  p_lower_nrml_rate_ovrd_ind  IGS_FI_FEE_AS_RT.lower_nrml_rate_ovrd_ind%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- finp_ins_cfar
	-- This routine is used to insert a contract fee assessment rate record.
DECLARE
       X_ROWID      VARCHAR2(25);
	v_ret_val	BOOLEAN	DEFAULT TRUE;
BEGIN
	p_message_name := Null;
	IF NOT IGS_FI_VAL_CFAR.finp_val_ft_closed(
						p_fee_type,
						p_message_name) THEN
		RETURN FALSE;
	END IF;
	IF NOT IGS_FI_VAL_CFAR.finp_val_cfar_ins(
					p_person_id,
					p_course_cd,
					p_fee_type,
					p_message_name) THEN
		RETURN FALSE;
	END IF;
	IF NOT IGS_FI_VAL_CFAR.finp_val_att_closed(
					p_attendance_type,
					p_message_name) THEN
		RETURN FALSE;
	END IF;
	IF NOT IGS_FI_VAL_CFAR.finp_val_am_closed(
					p_attendance_mode,
					p_message_name) THEN
		RETURN FALSE;
	END IF;
	IF NOT IGS_FI_VAL_CFAR.finp_val_loc_closed(
					p_location_cd,
					p_message_name) THEN
		RETURN FALSE;
	END IF;
	--Validate the IGS_FI_FEE_AS_RT (cfar) table to ensure that for
	--records with the same person_id, course_cd and IGS_FI_FEE_TYPE, that only
	--one record has a open end_dt.
	IF p_end_dt IS NULL THEN
		IF NOT IGS_FI_VAL_CFAR.finp_val_cfar_open (
						p_person_id,
						p_course_cd,
						p_fee_type,
						p_start_dt,
						p_message_name) THEN
			RETURN FALSE;
		END IF;
	END IF;
	--Validate the IGS_FI_FEE_AS_RT (cfar) table to ensure that for
	--records with the same person_id, course_cd and IGS_FI_FEE_TYPE, that the
	--date ranges don't overlap.
	IF NOT IGS_FI_VAL_CFAR.finp_val_cfar_ovrlp (
						p_person_id,
						p_course_cd,
						p_fee_type,
						p_start_dt,
						p_end_dt,
						p_message_name) THEN
		RETURN FALSE;
	END IF;
	--Insert the contract fee assessment rate
         IGS_FI_FEE_AS_RT_PKG.INSERT_ROW(
            X_ROWID => X_ROWID,
		X_person_id => p_person_id,
		X_course_cd => p_course_cd,
		X_FEE_TYPE => p_fee_type,
		X_start_dt => p_start_dt,
		X_end_dt => p_end_dt,
		X_location_cd => p_location_cd,
		X_ATTENDANCE_TYPE => p_attendance_type,
		X_ATTENDANCE_MODE => p_attendance_mode,
		X_chg_rate => p_chg_rate,
		X_lower_nrml_rate_ovrd_ind => p_lower_nrml_rate_ovrd_ind,
            X_MODE => 'R');
	RETURN v_ret_val;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
Fnd_Message.Set_Token('NAME','IGS_FI_GEN_003.FINP_INS_CFAR');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;

END finp_ins_cfar;

-- Function to delete FSERT block
FUNCTION finp_del_fsert(
  p_sub_er_id NUMBER,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
	gv_other_detail		VARCHAR2(255);
BEGIN
        -- This routine will logically delete all IGS_FI_SUB_ER_RT records

DECLARE
	e_resource_busy_exception		EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
	CURSOR c_fsert IS
		SELECT
                  ROWID,
		 SUB_ERR_ID ,
                 SUB_ER_ID ,
                 FAR_ID   ,
                 CREATE_DATE ,
                 LOGICAL_DELETE_DATE
  		FROM	IGS_FI_SUB_ER_RT fsert
  		WHERE	fsert.sub_er_id	 = p_sub_er_id	AND
  			fsert.logical_delete_date IS NULL
		FOR UPDATE OF fsert.logical_delete_date NOWAIT;
BEGIN
	-- Set the default message number
	p_message_name := Null;
	-- 1. Check parameters.
	IF  (p_sub_er_id IS NULL)
            THEN
		RETURN TRUE;
	END IF;
	-- 2. Issue a save point for the module so that if locks exist,
	-- a rollback can be performed.
	SAVEPOINT sp_save_point;
	-- Perform a logical delete of the associated IGS_FI_SUB_ER_RT items.
	-- Update the appropriate records with NOWAIT option.
	FOR v_fsert_rec IN c_fsert LOOP
               igs_fi_sub_er_rt_pkg.update_row (
                  x_mode                              => 'R',
                  x_rowid                             => v_fsert_rec.ROWID,
                  x_sub_err_id                        => v_fsert_rec.SUB_ERR_ID,
                  x_sub_er_id                         => v_fsert_rec.SUB_ER_ID,
                  x_far_id                            => v_fsert_rec.FAR_ID,
                  x_create_date                       => v_fsert_rec.CREATE_DATE,
                  x_logical_delete_date               => SYSDATE
                  );

	END LOOP;
	RETURN TRUE;
EXCEPTION
	WHEN e_resource_busy_exception THEN
		IF c_fsert%ISOPEN THEN
			CLOSE c_fsert;
		END IF;
		ROLLBACK TO sp_save_point;
		p_message_name := 'IGS_FI_UNABLE_LOGDEL_SUB_ER_RT';
		RETURN FALSE;
	WHEN OTHERS THEN
		IF c_fsert%ISOPEN THEN
			CLOSE c_fsert;
		END IF;
		RAISE;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
Fnd_Message.Set_Token('NAME','IGS_FI_GEN_003.FINP_DEL_FSERT');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END finp_del_fsert;


FUNCTION finp_del_fser(
  p_er_id NUMBER,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
	gv_other_detail		VARCHAR2(255);
BEGIN
        -- This routine will logically delete all IGS_FI_SUB_ER_RT records

DECLARE
	e_resource_busy_exception		EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
	CURSOR c_fser IS
		SELECT
                  ROWID,
		 SUB_ER_ID ,
                 ER_ID ,
                 sub_range_num,
                 sub_lower_range,
                 sub_upper_range,
                 sub_chg_method_code,
                 LOGICAL_DELETE_DATE
  		FROM	IGS_FI_SUB_ELM_RNG fser
  		WHERE	fser.er_id     = p_er_id	AND
  			fser.logical_delete_date	IS NULL
		FOR UPDATE OF fser.logical_delete_date NOWAIT;
        v_message_name          VARCHAR2(30);
        v_message_icon varchar2(10);
BEGIN
	-- Set the default message number
	p_message_name := Null;
	-- 1. Check parameters.
	IF  (p_er_id IS NULL)
            THEN
		RETURN TRUE;
	END IF;
	-- 2. Issue a save point for the module so that if locks exist,
	-- a rollback can be performed.
	SAVEPOINT sp_fser_save_point;
	-- Perform a logical delete of the associated IGS_FI_SUB_ELM_RNG items.
	-- Update the appropriate records with NOWAIT option.
	FOR v_fser_rec IN c_fser LOOP

        igs_fi_sub_elm_rng_pkg.update_row (
              x_mode                              => 'R',
              x_rowid                             => v_fser_rec.ROWID,
              x_sub_er_id                         => v_fser_rec.SUB_ER_ID,
              x_er_id                             => v_fser_rec.ER_ID,
              x_sub_range_num                     => v_fser_rec.SUB_RANGE_NUM,
              x_sub_lower_range                   => v_fser_rec.SUB_LOWER_RANGE,
              x_sub_upper_range                   => v_fser_rec.SUB_UPPER_RANGE,
              x_sub_chg_method_code               => v_fser_rec.SUB_CHG_METHOD_CODE,
              x_logical_delete_date               => SYSDATE
            );

             IF IGS_FI_GEN_003.FINP_DEL_FSERT (v_fser_rec.SUB_ER_ID,
                                                 v_message_name) = FALSE THEN
                                    fnd_message.set_name ('IGS', v_message_name);
                                    FND_FILE.Put_Line(FND_FILE.Log,
                                                      FND_MESSAGE.Get);
             END IF;


	END LOOP;
	RETURN TRUE;
EXCEPTION
	WHEN e_resource_busy_exception THEN
		IF c_fser%ISOPEN THEN
			CLOSE c_fser;
		END IF;
		ROLLBACK TO sp_fser_save_point;
		p_message_name := ': IGS_FI_UNABLE_LOGDEL_SUB_ELM_RNG';
		RETURN FALSE;
	WHEN OTHERS THEN
		IF c_fser%ISOPEN THEN
			CLOSE c_fser;
		END IF;
		RAISE;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
Fnd_Message.Set_Token('NAME','IGS_FI_GEN_003.FINP_DEL_FSER');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END finp_del_fser;

-- Function to delete Rate in FSERT block
FUNCTION finp_del_sub_rt(
  p_sub_err_id NUMBER,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
	gv_other_detail		VARCHAR2(255);
BEGIN
        -- This routine will logically delete particular record in IGS_FI_SUB_ER_RT

DECLARE
	e_resource_busy_exception		EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
	CURSOR c_fsert IS
		SELECT
                 ROWID,
                 SUB_ER_ID ,
                 FAR_ID   ,
                 CREATE_DATE
  		FROM	IGS_FI_SUB_ER_RT fsert
  		WHERE	fsert.sub_err_id	 = p_sub_err_id	AND
  			fsert.logical_delete_date IS NULL
		FOR UPDATE OF fsert.logical_delete_date NOWAIT;

  l_rowid          ROWID;
	l_sub_er_id      igs_fi_sub_er_rt.sub_er_id%TYPE;
	l_far_id         igs_fi_sub_er_rt.far_id%TYPE;
	l_create_date    igs_fi_sub_er_rt.create_date%TYPE;

BEGIN
	-- Set the default message number
	p_message_name := Null;
	-- 1. Check parameters.
	IF  (p_sub_err_id IS NULL)
            THEN
		RETURN TRUE;
	END IF;
	-- 2. Issue a save point for the module so that if locks exist,
	-- a rollback can be performed.
	SAVEPOINT sp_save_point;
	-- Perform a logical delete of the associated IGS_FI_SUB_ER_RT items.
	-- Update the appropriate records with NOWAIT option.
	OPEN c_fsert;
	FETCH c_fsert INTO l_rowid, l_sub_er_id,l_far_id,l_create_date;
	IF c_fsert%FOUND THEN
            CLOSE c_fsert;
            igs_fi_sub_er_rt_pkg.update_row (
                  x_mode                              => 'R',
                  x_rowid                             => l_rowid,
                  x_sub_err_id                        => p_sub_err_id,
                  x_sub_er_id                         => l_sub_er_id,
                  x_far_id                            => l_far_id,
                  x_create_date                       => l_create_date,
                  x_logical_delete_date               => SYSDATE
                  );
	RETURN TRUE;
       END IF;
   CLOSE c_fsert;
EXCEPTION
	WHEN e_resource_busy_exception THEN
		IF c_fsert%ISOPEN THEN
			CLOSE c_fsert;
		END IF;
		ROLLBACK TO sp_save_point;
		p_message_name := 'IGS_FI_UNABLE_LOGDEL_SUB_ER_RT';
		RETURN FALSE;
	WHEN OTHERS THEN
		IF c_fsert%ISOPEN THEN
			CLOSE c_fsert;
		END IF;
		RAISE;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
Fnd_Message.Set_Token('NAME','IGS_FI_GEN_003.FINP_DEL_SUB_RT');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END finp_del_sub_rt;
--
END IGS_FI_GEN_003;

/
