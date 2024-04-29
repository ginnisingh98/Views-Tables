--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_009
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_009" AS
/* $Header: IGSAD09B.pls 115.2 2002/02/12 16:21:09 pkm ship    $ */

Function Admp_Get_Sys_Acos(
  p_s_adm_cndtnl_offer_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN
	-- admp_get_sys_acos
	-- Routine to return the user-defined system default admission conditional
	-- offer status for given the system admission conditional offer status.
DECLARE
	v_adm_cndtnl_offer_status	IGS_AD_CNDNL_OFRSTAT.adm_cndtnl_offer_status%TYPE;
	CURSOR c_acos IS
		SELECT	acos.adm_cndtnl_offer_status
		FROM	IGS_AD_CNDNL_OFRSTAT   acos
		WHERE	acos.s_adm_cndtnl_offer_status = p_s_adm_cndtnl_offer_status  AND
			acos.system_default_ind        = 'Y'			      AND
			acos.closed_ind		       = 'N';
BEGIN
	-- If no record is found, return value is NULL
	v_adm_cndtnl_offer_status := NULL;
	FOR v_acos_rec IN c_acos LOOP
		IF (c_acos%ROWCOUNT>1)THEN
			v_adm_cndtnl_offer_status := NULL;     -- more than one record found
			exit;
		END IF;
		v_adm_cndtnl_offer_status := v_acos_rec.adm_cndtnl_offer_status;
	END LOOP;
	RETURN v_adm_cndtnl_offer_status;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_009.admp_get_sys_acos');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_sys_acos;

Function Admp_Get_Sys_Ads(
  p_s_adm_doc_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_get_sys_ads
	-- routine to return the user-defined system default admission documentation
	-- status for given the system admission documentation status
DECLARE
	CURSOR c_ads IS
		SELECT	ads.adm_doc_status
		FROM	IGS_AD_DOC_STAT ads
		WHERE	ads.s_adm_doc_status 	= p_s_adm_doc_status AND
			ads.system_default_ind  = 'Y' AND
			ads.closed_ind	        = 'N';
	v_adm_doc_status		IGS_AD_DOC_STAT.adm_doc_status%TYPE;
BEGIN
	FOR v_ads_rec IN c_ads LOOP
		IF c_ads%ROWCOUNT > 1 THEN
			v_adm_doc_status := NULL;
			exit;
		END IF;
		v_adm_doc_status := v_ads_rec.adm_doc_status;
	END LOOP;
	-- return null if no records or more than one record found
	RETURN v_adm_doc_status;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_009.admp_get_sys_ads');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_sys_ads;

Function Admp_Get_Sys_Aeqs(
  p_s_adm_entry_qual_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_get_sys_aeqs
	-- routine to return the user-defined system default admission entry status for
	-- system admission entry status
DECLARE
	CURSOR c_aeqs IS
		SELECT	aeqs.adm_entry_qual_status
		FROM	IGS_AD_ENT_QF_STAT aeqs
		WHERE	aeqs.s_adm_entry_qual_status = p_s_adm_entry_qual_status AND
			aeqs.system_default_ind      = 'Y' AND
			aeqs.closed_ind	             = 'N';
	v_adm_ent_qual_sts		IGS_AD_ENT_QF_STAT.adm_entry_qual_status%TYPE;
BEGIN
	FOR v_aeqs_rec IN c_aeqs LOOP
		IF c_aeqs%ROWCOUNT > 1 THEN
			v_adm_ent_qual_sts := NULL;
			exit;
		END IF;
		v_adm_ent_qual_sts := v_aeqs_rec.adm_entry_qual_status;
	END LOOP;
	-- return null if no records or more than one record found
	RETURN v_adm_ent_qual_sts;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_009.admp_get_sys_aeqs');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_sys_aeqs;

Function Admp_Get_Sys_Afs(
  p_s_adm_fee_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_get_sys_afs
	-- routine to return the user-defined system default admission fee status
	-- for the given system admission fee status
DECLARE
	CURSOR c_afs IS
		SELECT	afs.adm_fee_status
		FROM	IGS_AD_FEE_STAT afs
		WHERE	afs.s_adm_fee_status 	= p_s_adm_fee_status AND
			afs.system_default_ind  = 'Y' AND
			afs.closed_ind	        = 'N';
	v_adm_fee_status		IGS_AD_FEE_STAT.adm_fee_status%TYPE := NULL;
BEGIN
	FOR v_afs_rec IN c_afs LOOP
		IF c_afs%ROWCOUNT > 1 THEN
			v_adm_fee_status := NULL;
			exit;
		END IF;
		v_adm_fee_status := v_afs_rec.adm_fee_status;
	END LOOP;
	-- return null if no records or more than one record found
	RETURN v_adm_fee_status;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_009.admp_get_sys_afs');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_sys_afs;

Function Admp_Get_Sys_Aods(
  p_s_adm_offer_dfrmnt_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN
	-- admp_get_sys_aods
	-- Routine to return the user-defined system default admission offer
	-- deferment status for given the system admission offer deferment status.
DECLARE
	v_adm_offer_dfrmnt_status IGS_AD_OFRDFRMT_STAT.adm_offer_dfrmnt_status%TYPE;
	CURSOR c_aods IS
		SELECT	aods.adm_offer_dfrmnt_status
		FROM	IGS_AD_OFRDFRMT_STAT   aods
		WHERE	aods.s_adm_offer_dfrmnt_status = p_s_adm_offer_dfrmnt_status  AND
			aods.system_default_ind        = 'Y'		              AND
			aods.closed_ind		       = 'N';
BEGIN
	-- If no record is found, return value is NULL
	v_adm_offer_dfrmnt_status := NULL;
	FOR v_aods_rec IN c_aods LOOP
		IF (c_aods%ROWCOUNT>1)THEN
			v_adm_offer_dfrmnt_status := NULL;     -- more than one record found
			exit;
		END IF;
		v_adm_offer_dfrmnt_status := v_aods_rec.adm_offer_dfrmnt_status;
	END LOOP;
	RETURN v_adm_offer_dfrmnt_status;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_009.admp_get_sys_aods');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_sys_aods;

Function Admp_Get_Sys_Aors(
  p_s_adm_offer_resp_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN
	-- admp_get_sys_aors
	-- Routine to return the user-defined system default admission offer
	-- response status for given the system admission offer response status.
DECLARE
	v_adm_offer_resp_status		IGS_AD_OFR_RESP_STAT.adm_offer_resp_status%TYPE;
	CURSOR c_aors IS
		SELECT	aors.adm_offer_resp_status
		FROM	IGS_AD_OFR_RESP_STAT   aors
		WHERE	aors.s_adm_offer_resp_status = p_s_adm_offer_resp_status  AND
			aors.system_default_ind      = 'Y'			  AND
			aors.closed_ind		     = 'N';
BEGIN
	-- If no record is found, return value is NULL
	v_adm_offer_resp_status := NULL;
	FOR v_aors_rec IN c_aors LOOP
		IF (c_aors%ROWCOUNT>1)THEN
			v_adm_offer_resp_status := NULL;     -- more than one record found
			exit;
		END IF;
		v_adm_offer_resp_status := v_aors_rec.adm_offer_resp_status;
	END LOOP;
	RETURN v_adm_offer_resp_status;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_009.admp_get_sys_aors');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_sys_aors;

Function Admp_Get_Sys_Aos(
  p_s_adm_outcome_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN
	-- admp_get_sys_aos
	-- Routine to return the user-defined system default admission outcome
	-- status for given the system admission outcome status.
DECLARE
	v_adm_outcome_status		IGS_AD_OU_STAT.adm_outcome_status%TYPE;
	CURSOR c_aos IS
		SELECT	aos.adm_outcome_status
		FROM	IGS_AD_OU_STAT   aos
		WHERE	aos.s_adm_outcome_status = p_s_adm_outcome_status  AND
			aos.system_default_ind   = 'Y'		           AND
			aos.closed_ind		 = 'N';
BEGIN
	-- If no record is found, return value is NULL
	v_adm_outcome_status := NULL;
	FOR v_aos_rec IN c_aos LOOP
		IF (c_aos%ROWCOUNT>1)THEN
			v_adm_outcome_status := NULL;     -- more than one record found
			exit;
		END IF;
		v_adm_outcome_status := v_aos_rec.adm_outcome_status;
	END LOOP;
	RETURN v_adm_outcome_status;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_009.admp_get_sys_aos');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_sys_aos;

Function Admp_Get_Sys_Auos(
  p_s_adm_outcome_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	--admp_get_sys_auos
	--return the user-defined system default admission unit outcome status
	--for a given system admission unit outcome status.
DECLARE
	v_auos_cnt		NUMBER	DEFAULT 0;
	v_adm_outcome_status	IGS_AD_UNIT_OU_STAT.adm_unit_outcome_status%TYPE;
	CURSOR c_auos IS
		SELECT	auos.adm_unit_outcome_status
		FROM	IGS_AD_UNIT_OU_STAT		auos
		WHERE	s_adm_outcome_status = p_s_adm_outcome_status	AND
			system_default_ind = 'Y'				AND
			closed_ind = 'N';
BEGIN
	FOR v_auos_rec IN c_auos LOOP
		v_auos_cnt := v_auos_cnt + 1;
		IF (v_auos_cnt > 1) THEN
			exit;
		END IF;
		v_adm_outcome_status := v_auos_rec.adm_unit_outcome_status;
	END LOOP;
	IF (v_auos_cnt <> 1) THEN
		RETURN NULL;
	END IF;
	RETURN v_adm_outcome_status;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_auos%ISOPEN) THEN
			CLOSE c_auos;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_009.admp_get_sys_auos');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_sys_auos;

END IGS_AD_GEN_009;

/
