--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_005" AS
/* $Header: IGSAD05B.pls 120.0 2005/06/01 17:19:04 appldev noship $ */
/* Change History
 who       when         what
 smvk      09-Jul-2004  Bug # 3676145. Modified cursors c_ucl to use Active (not closed) unit classes.
 */

Function Admp_Get_Crv_Strt_Dt(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER )
RETURN DATE IS
BEGIN	-- admp_get_crv_strt_dt
	-- Routine to return the course version start date
DECLARE
	v_alias_val	DATE;
	CURSOR c_daiv IS
		SELECT 	IGS_CA_GEN_001.calp_set_alias_value(
				daiv.absolute_val,
				IGS_CA_GEN_002.cals_clc_dt_from_dai(
					daiv.ci_sequence_number,
					daiv.CAL_TYPE,
					daiv.DT_ALIAS,
					daiv.sequence_number) ) alias_val
		FROM	IGS_CA_DA_INST daiv,
			IGS_AD_CAL_CONF sacc
		WHERE	daiv.dt_alias 		= sacc.adm_appl_course_strt_dt_alias AND
			daiv.cal_type 		= p_adm_cal_type AND
			daiv.ci_sequence_number = p_adm_ci_sequence_number AND
			sacc.s_control_num 	= 1
		ORDER BY 1 desc;
BEGIN
	OPEN c_daiv;
	FETCH c_daiv INTO v_alias_val;
	IF (c_daiv%NOTFOUND) THEN
		CLOSE c_daiv;
		RETURN NULL;
	ELSE	-- for the first record
		CLOSE c_daiv;
		RETURN v_alias_val;
	END IF;
END;
END admp_get_crv_strt_dt;

Function Admp_Get_Dflt_Ccm(
  p_admission_cat IN VARCHAR2 ,
  p_description OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN	-- admp_get_dflt_ccm
	-- Gets the default correspondence category mapping for an admission category.
	-- The default value must not be closed.
p_description := NULL;
DECLARE
	CURSOR c_ccm IS
		SELECT	ccm.correspondence_cat,
			cc.description
		FROM	IGS_CO_CAT_MAP  	ccm,
			IGS_CO_CAT 		cc
		WHERE   ccm.admission_cat 	= p_admission_cat AND
			ccm.dflt_cat_ind	= 'Y' AND
			cc.correspondence_cat 	= ccm.correspondence_cat AND
			cc.closed_ind		= 'N';
	v_ccm_rec		c_ccm%ROWTYPE;
	v_correspondence_cat	IGS_CO_CAT_MAP.correspondence_cat%TYPE
						DEFAULT NULL;
BEGIN
	-- get the correspondence_cat record and check for Multiple Rows
	FOR v_ccm_rec IN c_ccm LOOP
		IF c_ccm%ROWCOUNT > 1 THEN
			v_correspondence_cat := NULL;
			p_description := NULL;
			EXIT;
		END IF;
		v_correspondence_cat := v_ccm_rec.correspondence_cat;
		p_description := v_ccm_rec.description;
	END LOOP;
	RETURN v_correspondence_cat;
EXCEPTION
	WHEN OTHERS THEN
		IF c_ccm%ISOPEN THEN
			CLOSE c_ccm;
		END IF;
		App_Exception.Raise_Exception;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_005.admp_get_dflt_ccm');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_dflt_ccm;

Function Admp_Get_Dflt_Ecm(
  p_admission_cat IN VARCHAR2 ,
  p_description OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN	-- admp_get_dflt_ecm
	-- Gets the default enrolment category mapping for an admission category.
	-- The default value must not be closed.
DECLARE
	CURSOR c_ecm IS
		SELECT	ecm.enrolment_cat,
			ec.description
		FROM	IGS_EN_CAT_MAPPING  	ecm,
			IGS_EN_ENROLMENT_CAT		ec
		WHERE	ecm.admission_cat 	= p_admission_cat AND
			ecm.dflt_cat_ind	= 'Y' AND
			ec.enrolment_cat	= ecm.enrolment_cat AND
			ec.closed_ind		= 'N';
	v_ecm_rec		c_ecm%ROWTYPE;
	v_enrolment_cat		IGS_EN_CAT_MAPPING.enrolment_cat%TYPE DEFAULT NULL;
BEGIN
	-- get the enrolment_cat record and check for Multiple Rows
	FOR v_ecm_rec IN c_ecm LOOP
		IF c_ecm%ROWCOUNT > 1 THEN
			v_enrolment_cat := NULL;
			p_description := NULL;
			EXIT;
		END IF;
		v_enrolment_cat := v_ecm_rec.enrolment_cat;
		p_description := v_ecm_rec.description;
	END LOOP;
	RETURN v_enrolment_cat;
EXCEPTION
	WHEN OTHERS THEN
		IF c_ecm%ISOPEN THEN
			CLOSE c_ecm;
		END IF;
		App_Exception.Raise_Exception;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_005.admp_get_dflt_ecm');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_dflt_ecm ;

Function Admp_Get_Dflt_Fcm(
  p_admission_cat IN VARCHAR2 ,
  p_description OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN	-- admp_get_dflt_fcm
	-- Gets the default fee category mapping for an admission category.
	-- The default value must not be closed.
DECLARE
	CURSOR c_fcm IS
		SELECT	fcm.fee_cat,
			fc.description
		FROM	IGS_FI_FEE_CAT_MAP fcm,
			IGS_FI_FEE_CAT		fc
		WHERE	admission_cat 	= p_admission_cat AND
			dflt_cat_ind	= 'Y' AND
			fc.fee_cat	= fcm.fee_cat AND
			fc.closed_ind 	= 'N';
	v_fcm_rec	c_fcm%ROWTYPE;
	v_fee_cat	IGS_FI_FEE_CAT_MAP.fee_cat%TYPE DEFAULT NULL;
BEGIN
	--get the fee_cat record and check for Multiple Rows
	FOR v_fcm_rec IN c_fcm LOOP
		IF c_fcm%ROWCOUNT > 1 THEN
			v_fee_cat := NULL;
			p_description := NULL;
			EXIT;
		END IF;
		v_fee_cat := v_fcm_rec.fee_cat;
		p_description := v_fcm_rec.description;
	END LOOP;
	RETURN v_fee_cat;
EXCEPTION
	WHEN OTHERS THEN
		IF c_fcm%ISOPEN THEN
			CLOSE c_fcm;
		END IF;
		App_Exception.Raise_Exception;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_005.admp_get_dflt_fcm');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_dflt_fcm ;

Function Admp_Get_Dflt_Fs(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_description OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN	-- admp_get_dflt_fs
	-- Description: This module gets the default funding source for a course
	-- version. The default value must not be closed
DECLARE
	v_loop_boolean		BOOLEAN DEFAULT FALSE;
	v_funding_source	IGS_FI_FUND_SRC.funding_source%TYPE;
	CURSOR	c_fsr_fs IS
		SELECT 	fsr.funding_source,
			fs.description
		FROM 	IGS_FI_FND_SRC_RSTN fsr,
			IGS_FI_FUND_SRC 		fs
		WHERE	fsr.course_cd 		= p_course_cd AND
			fsr.version_number 	= p_version_number AND
			fsr.dflt_ind 		= 'Y' AND
			fs.funding_source 	= fsr.funding_source AND
			fs.closed_ind 		= 'N';
BEGIN
	FOR v_fsr_fs_recs IN  c_fsr_fs LOOP
		IF ((c_fsr_fs%ROWCOUNT) > 1) THEN
			v_loop_boolean := TRUE;
			EXIT;
		ELSE
			p_description := v_fsr_fs_recs.description;
			v_funding_source := v_fsr_fs_recs.funding_source;
		END IF;
	END LOOP;
	IF v_loop_boolean = TRUE THEN
		RETURN NULL;
	ELSE
		RETURN v_funding_source;
	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_005.admp_get_dflt_fs');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_dflt_fs;

Function Admp_Get_Dflt_Hpo(
  p_admission_cat IN VARCHAR2 ,
  p_description OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN 	-- admp_get_dflt_hpo
	-- Returns the default HECS payment option for an admission category.
	-- The default value only exists when one and only one HECS payment option
	-- is mapped to the admission category.
	-- If no default value exists the routine returns a null value.
	-- The default value must not be closed.
DECLARE
	v_hecs_payment_option	IGS_AD_CT_HECS_PAYOP.hecs_payment_option%TYPE;
	CURSOR c_achpo (
			cp_admission_cat	IGS_AD_CT_HECS_PAYOP.admission_cat%TYPE) IS
		SELECT	achpo.hecs_payment_option,
			hpo.description
		FROM	IGS_AD_CT_HECS_PAYOP	achpo,
			IGS_FI_HECS_PAY_OPTN		hpo
		WHERE	achpo.admission_cat		= cp_admission_cat AND
			1 = (
				SELECT 	count(*)
				FROM	IGS_AD_CT_HECS_PAYOP	achpo
				WHERE	achpo.admission_cat		= cp_admission_cat) AND
			hpo.hecs_payment_option 	= achpo.hecs_payment_option AND
			hpo.closed_ind			= 'N';
BEGIN
	OPEN 	c_achpo(
			p_admission_cat);
	FETCH	c_achpo	INTO v_hecs_payment_option,
				p_description;
	IF(c_achpo%FOUND) THEN
		CLOSE c_achpo;
		RETURN v_hecs_payment_option;
	ELSE
		CLOSE c_achpo;
		RETURN NULL;
	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_005.admp_get_dflt_hpo');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_dflt_hpo;

Function Admp_Get_Dflt_Uc(
  p_unit_mode IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN	-- admp_get_dflt_uc
	-- Return the default unit class for a unit mode.
DECLARE
	v_multiple_records	BOOLEAN DEFAULT FALSE;
	v_unit_class		IGS_AS_UNIT_CLASS.unit_class%TYPE;
	CURSOR c_ucl IS
		SELECT	UNIQUE ucl.unit_class
		FROM	IGS_AS_UNIT_CLASS	ucl
		WHERE	ucl.unit_mode	= p_unit_mode AND
			ucl.closed_ind	= 'N';
BEGIN
	FOR v_ucl_rec IN c_ucl LOOP
		IF (c_ucl%ROWCOUNT > 1) THEN
			v_multiple_records := TRUE;
			EXIT;
		END IF;
		v_unit_class := v_ucl_rec.unit_class;
	END LOOP;
	IF NOT v_multiple_records THEN
		RETURN v_unit_class;
	ELSE -- multiple records
		RETURN NULL;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		IF c_ucl%ISOPEN THEN
			CLOSE c_ucl;
		END IF;
		App_Exception.Raise_Exception;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_005.admp_get_dflt_uc');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_dflt_uc;

Function Admp_Get_Dflt_Um(
  p_unit_class IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN 	-- admp_get_dflt_um
	-- Return the default unit mode for a unit class
DECLARE
	v_unit_mode		IGS_AS_UNIT_CLASS.unit_mode%TYPE;
	v_count_OK		BOOLEAN DEFAULT FALSE;
	CURSOR	c_ucl IS
		SELECT	ucl.unit_mode
		FROM	IGS_AS_UNIT_CLASS	ucl
		WHERE	ucl.unit_class 	= p_unit_class
		AND     ucl.closed_ind = 'N';
BEGIN
	FOR v_ucl_rec IN c_ucl LOOP
		IF c_ucl%ROWCOUNT = 1 THEN
			v_unit_mode := v_ucl_rec.unit_mode;
			v_count_OK := TRUE;
		ELSE
			v_count_OK := FALSE;
			EXIT;
		END IF;
	END LOOP;
	IF NOT v_count_OK THEN
		RETURN NULL;
	END IF;
	RETURN v_unit_mode;
EXCEPTION
	WHEN OTHERS THEN
		IF c_ucl%ISOPEN THEN
			CLOSE c_ucl;
		END IF;
		App_Exception.Raise_Exception;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_005.admp_get_dflt_um');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_dflt_um;

END IGS_AD_GEN_005;

/
