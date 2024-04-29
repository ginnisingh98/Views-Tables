--------------------------------------------------------
--  DDL for Package Body IGS_GR_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_GEN_002" AS
/* $Header: IGSGR14B.pls 120.3 2006/04/19 23:58:41 sepalani noship $ */
PROCEDURE grdp_ins_graduand(
  errbuf  out NOCOPY  varchar2,
	retcode out NOCOPY  number,
	p_ceremony_round  IN VARCHAR2,
	p_course_cd IGS_PS_COURSE.course_cd%TYPE ,
	p_crs_location_cd IN IGS_AD_LOCATION_ALL.location_cd%TYPE,
	p_award_cd IGS_PS_AWD.award_cd%TYPE ,
	p_nominated_completion  VARCHAR2 ,
	p_derived_completion  VARCHAR2 ,
	p_restrict_rqrmnt_complete  VARCHAR2 ,
	p_potential_graduand_status IGS_GR_STAT.graduand_status%TYPE ,
	p_eligible_graduand_status IGS_GR_STAT.graduand_status%TYPE ,
	p_graduand_appr_status IGS_GR_APRV_STAT.graduand_appr_status%TYPE,
  p_org_id IN NUMBER,
	p_graduand_status  IGS_GR_STAT.graduand_status%TYPE ,
  p_approval_status IGS_GR_APRV_STAT.graduand_appr_status%TYPE) AS
	-------------------------------------------------------
  --  Change History :
  --  Who             When            What
  --  (reverse chronological order - newest change first)
	-------------------------------------------------------
  --  Nalin Kumar     23-Nov-2001     Modified the grdpl_ins_new_graduand procedure
  --  															  as per the UK Award Aims DLD. Bug ID: 1366899
  --  svenkata        7-JAN-2002      Bug No. 2172405  Standard Flex Field columns have been added
  --                                  to table handler procedure calls as part of CCR - ENCR022.
  --  Nalin Kumar     29-Oct-2002     Modified the grdp_upd_gac_order procedure as per the Conferral Date TD. Bug# 2640799
  --  Nalin Kumar     05-Dec-2002     Modified the grdpl_ins_new_graduand procedure to fix Bug# 2683072.
	--  Nalin Kumar     10-Dec-2002     Modified the grdp_upd_gac_order procedure to fix Bug# 2691809.
	--  Nalin Kumar     18-DEC-2002     Modified this procedure to fix Bug# 2690151.
	--                                  Added the code to log the parameters value in the log file.
	--  Nalin Kumar     10-Mar-2003     Modified c_crd_sca cursor to considered IGS_CA_DA_INST_V.ALIAS_VAL instead of IGS_CA_DA_INST_V.ABSOLUTE_VAL
	--                                  This is to fix Bug# 2760539.
  --  Nalin Kumar     12-Dec-2003     Modified grdp_upd_gac_order procedure to fix Bug# 3294453.
  --  iJeddy          The Fourth of July, 2005   Bug 4473024, added a join on award_cd to the Cursor c_crd_sca
  --  sepalani        19-Apr-2006     Modified Cursor c_gr_upd on procedure GRDP_PRC_GAC for Bug# 5074150
	-------------------------------------------------------

	p_grd_cal_type  		IGS_GR_CRMN_ROUND.grd_cal_type%TYPE ;
	p_grd_ci_sequence_number   	IGS_GR_CRMN_ROUND.grd_ci_sequence_number%TYPE;
	lv_param_values 		VARCHAR2(1080);
	l_org_id NUMBER(15);
BEGIN
  -- grdp_ins_graduand
  -- This module is used to identify potential graduands and to create
  -- IGS_GR_GRADUAND records if they haven't already been created.
  igs_ge_gen_003.set_org_id(p_org_id);
  --Block for Parameter Validation/Splitting of Parameters
	retcode:=0;

	DECLARE
		v_message			VARCHAR2(30);
		invalid_parameter		EXCEPTION;
	BEGIN
		p_grd_cal_type 		 :=RTRIM(SUBSTR(p_ceremony_round, 101, 10));
		p_grd_ci_sequence_number :=TO_NUMBER(RTRIM(SUBSTR(p_ceremony_round, 112, 6)));

    --
    --Log the Parameters value in the log file. This is to fix Bug# 2690151
    --
    FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_ANC_LOG_PARM');
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET()||':');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_grd_cal_type = '||p_grd_cal_type);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_grd_ci_sequence_number = '||p_grd_ci_sequence_number);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_course_cd = '||p_course_cd);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_crs_location_cd  = '||p_crs_location_cd);
		FND_FILE.PUT_LINE(FND_FILE.LOG,'p_award_cd = '||p_award_cd);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_nominated_completion  = '||p_nominated_completion);
		FND_FILE.PUT_LINE(FND_FILE.LOG,'p_derived_completion = '||p_derived_completion);
		FND_FILE.PUT_LINE(FND_FILE.LOG,'p_restrict_rqrmnt_complete  = '||p_restrict_rqrmnt_complete);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_potential_graduand_status  = '||p_potential_graduand_status);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_eligible_graduand_status  = '||p_eligible_graduand_status);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_graduand_appr_status  = '||p_graduand_appr_status);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_graduand_status  = '||p_graduand_status);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_approval_status  = '||p_approval_status);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');


		IF  NOT  IGS_GR_VAL_AWC.grdp_val_award_type(p_award_cd, 'COURSE', v_message) THEN
			ERRBUF:=FND_MESSAGE.GET_STRING('IGS', v_message);
			RAISE INVALID_PARAMETER;
		END IF;

		IF p_derived_completion = 'N' AND p_nominated_completion = 'N' THEN
		     	ERRBUF:= FND_MESSAGE.GET_STRING('IGS', 'IGS_GR_NOMIN_DERV_COMPL_SET');
     			RAISE INVALID_PARAMETER;
		END IF;

    IF FND_PROFILE.VALUE('OSS_COUNTRY_CODE')='GB' and (p_graduand_status IS NULL OR p_approval_status IS NULL) THEN
      ERRBUF:= FND_MESSAGE.GET_STRING('IGS', 'IGS_GR_GRAD_APPR_REQ');
     	RAISE INVALID_PARAMETER;
    END IF;
	EXCEPTION
		WHEN INVALID_PARAMETER  THEN
			retcode:=2;
			RETURN;
	END;
  --End of Block for Parameter Validation/Splitting of Parameters

  DECLARE
  cst_potential  CONSTANT VARCHAR2(10) := 'POTENTIAL';
  cst_eligible   CONSTANT VARCHAR2(10) := 'ELIGIBLE';
  cst_waiting    CONSTANT VARCHAR2(10) := 'WAITING';
  cst_approved   CONSTANT VARCHAR2(10) := 'APPROVED';
  cst_completed  CONSTANT VARCHAR2(10) := 'COMPLETED';
  cst_enrolled   CONSTANT VARCHAR2(10) := 'ENROLLED';
  cst_inactive   CONSTANT VARCHAR2(10) := 'INACTIVE';
  cst_intermit   CONSTANT VARCHAR2(10) := 'INTERMIT';
  cst_lapsed     CONSTANT VARCHAR2(10) := 'LAPSED';
  cst_graduated  CONSTANT VARCHAR2(10) := 'GRADUATED';
  cst_surrender  CONSTANT VARCHAR2(10) := 'SURRENDER';
  cst_articulate CONSTANT VARCHAR2(10) := 'ARTICULATE';
  cst_declined   CONSTANT VARCHAR2(10) := 'DECLINED';

  CURSOR c_crd_sca IS
    SELECT crd.grd_cal_type,
      crd.grd_ci_sequence_number,
      sca.person_id,
      sca.course_cd,
      sca.version_number,
      sca.commencement_dt,
      spaa.award_cd
    FROM  igs_en_stdnt_ps_att sca ,
      igs_en_spa_awd_aim      spaa,
      igs_ps_ver              crv ,
      igs_gr_crmn_round       crd ,
      igs_gr_crm_round_prd    crdp,
      igs_ca_da_inst_v        dai1,
      igs_ca_da_inst_v        dai2
    WHERE (p_grd_cal_type IS NULL OR
           (crd.grd_cal_type          = p_grd_cal_type AND
            crd.grd_ci_sequence_number = p_grd_ci_sequence_number)) AND
      dai1.cal_type           = crd.grd_cal_type AND
      dai1.ci_sequence_number = crd.grd_ci_sequence_number AND
      dai1.dt_alias           = crd.start_dt_alias AND
      dai1.sequence_number    = crd.start_dai_sequence_number AND
      dai1.alias_val          IS NOT NULL AND
      dai2.cal_type           = crd.grd_cal_type AND
      dai2.ci_sequence_number = crd.grd_ci_sequence_number AND
      dai2.dt_alias           = crd.end_dt_alias AND
      dai2.sequence_number    = crd.end_dai_sequence_number AND
      dai2.alias_val       IS NOT NULL AND
      TRUNC(SYSDATE)          BETWEEN   NVL(dai1.alias_val, IGS_GE_DATE.IGSDATE('1900/01/01')) AND
			                                  NVL(dai2.alias_val, IGS_GE_DATE.IGSDATE('1900/01/01'))AND
      crdp.grd_cal_type(+)           = crd.grd_cal_type AND
      crdp.grd_ci_sequence_number(+) = crd.grd_ci_sequence_number AND
      (p_course_cd            IS NULL OR
       sca.course_cd          = p_course_cd) AND
      (p_crs_location_cd      IS NULL OR
       sca.location_cd        = p_crs_location_cd) AND
       sca.person_id = spaa.person_id(+) AND
       sca.course_cd = spaa.course_cd(+) AND
      (p_restrict_rqrmnt_complete     = 'N' OR
       sca.course_rqrmnt_complete_ind = 'Y') AND
      ((p_nominated_completion        = 'Y' AND
        sca.nominated_completion_yr   = NVL(crdp.completion_year,   1900) AND
        sca.nominated_completion_perd = NVL(crdp.completion_period, 'NULL')) OR
      (p_derived_completion        = 'Y' AND
       sca.derived_completion_yr   = NVL(crdp.completion_year,   1900) AND
       sca.derived_completion_perd = NVL(crdp.completion_period, ' '))  OR
       (NVL(sca.course_rqrmnts_complete_dt, IGS_GE_DATE.IGSDATE('9998/01/01'))
             BETWEEN NVL(crd.completion_start_date, IGS_GE_DATE.IGSDATE('9999/01/01')) AND
                     NVL(crd.completion_end_date, IGS_GE_DATE.IGSDATE('9999/01/01'))) OR
       (NVL(spaa.conferral_date, IGS_GE_DATE.IGSDATE('9998/01/01'))
             BETWEEN NVL(crd.conferral_start_date, IGS_GE_DATE.IGSDATE('9999/01/01')) AND
                     NVL(crd.conferral_end_date, IGS_GE_DATE.IGSDATE('9999/01/01')))) AND
       sca.course_attempt_status IN (
       cst_completed,
       cst_enrolled ,
       cst_inactive ,
       cst_intermit ,
       cst_lapsed ) AND
      crv.course_cd             = sca.course_cd AND
      crv.version_number        = sca.version_number AND
      crv.graduate_students_ind = 'Y' AND
      ( p_award_cd  IS NULL OR
        spaa.AWARD_CD = p_award_cd )
    ORDER BY sca.person_id;

	CURSOR c_gr (
		cp_person_id		igs_gr_graduand.person_id%TYPE,
		cp_course_cd		igs_gr_graduand.course_cd%TYPE,
    cp_award_cd     igs_en_spa_awd_aim.award_cd%TYPE) IS
		SELECT	'x'
		FROM	igs_gr_graduand	gr,
			IGS_GR_STAT	gst
		WHERE	gr.person_id 	 = cp_person_id AND
			gr.course_cd 		   = cp_course_cd AND
      gr.award_cd        = cp_award_cd  AND
			gr.graduand_status = gst.graduand_status AND
			(gst.s_graduand_status 	IN (
						cst_graduated,
						cst_surrender) OR
			gr.s_graduand_type	IN (
						cst_articulate,
						cst_declined));
	v_gr_exists		VARCHAR2(1);
	v_person_id		IGS_EN_STDNT_PS_ATT.person_id%TYPE DEFAULT 0;
	v_message_name		VARCHAR2(30);

  --Cursor to check the existence of the SPAA records.
  CURSOR cur_spaaa (
		cp_person_id		igs_en_spa_awd_aim.person_id%TYPE,
		cp_course_cd		igs_en_spa_awd_aim.course_cd%TYPE) IS
  SELECT 'x'
  FROM igs_en_spa_awd_aim
  WHERE person_id = cp_person_id AND
        course_cd = cp_course_cd;
  rec_spaaa cur_spaaa%ROWTYPE;

	-- Added the following coursor to get the Person Number. Bug# 2690151
	CURSOR get_person_num(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
	SELECT person_number
	FROM igs_pe_person_base_v
	WHERE person_id = cp_person_id;
	l_person_number VARCHAR2(500) := NULL;
  l_log_person_id VARCHAR2(250);
  l_chk_hold VARCHAR2(250);
-- -----------------------------------------------------------------
	PROCEDURE grdpl_val_graduand_status
	AS
        BEGIN	-- grdpl_val_graduand_status
		-- Validate the status values provided
	DECLARE
		CURSOR c_gst (
			cp_graduand_status	IGS_GR_STAT.graduand_status%TYPE,
			cp_s_graduand_status	IGS_GR_STAT.s_graduand_status%TYPE) IS
			SELECT	gst.closed_ind
			FROM	IGS_GR_STAT	gst
			WHERE	gst.graduand_status 	= cp_graduand_status AND
				gst.s_graduand_status 	= cp_s_graduand_status;
		v_gst_rec	c_gst%ROWTYPE;
		CURSOR c_gas IS
			SELECT	gas.closed_ind
			FROM	IGS_GR_APRV_STAT	gas
			WHERE	gas.graduand_appr_status 	= p_graduand_appr_status AND
				gas.s_graduand_appr_status	IN (
								cst_waiting,
								cst_approved);
		v_gas_rec	c_gas%ROWTYPE;
	BEGIN
		-- Validate the potential IGS_GR_GRADUAND status value
		OPEN c_gst(
			p_potential_graduand_status,
			cst_potential);
		FETCH c_gst INTO v_gst_rec;
		IF c_gst%NOTFOUND THEN
			CLOSE c_gst;
    			Fnd_Message.Set_Name('IGS', 'IGS_GE_INVALID_VALUE');
          --App_Exception.Raise_Exception;
				  FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2690151
          RETURN;
		END IF;
		CLOSE c_gst;
		IF v_gst_rec.closed_ind = 'Y' THEN
   				Fnd_Message.Set_Name('IGS', 'IGS_GR_GRAD_STATUS_CLOSED');
          --App_Exception.Raise_Exception;
				  FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2690151
          RETURN;
		END IF;
		-- Validate the eligible IGS_GR_GRADUAND status value
		OPEN c_gst(
			p_eligible_graduand_status,
			cst_eligible);
		FETCH c_gst INTO v_gst_rec;
		IF c_gst%NOTFOUND THEN
			CLOSE c_gst;
   				Fnd_Message.Set_Name('IGS', 'IGS_GE_INVALID_VALUE');
          --App_Exception.Raise_Exception;
				  FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2690151
          RETURN;
		END IF;
		CLOSE c_gst;
		IF v_gst_rec.closed_ind = 'Y' THEN
   				Fnd_Message.Set_Name('IGS', 'IGS_GR_GRAD_STATUS_CLOSED');
          --App_Exception.Raise_Exception;
				  FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2690151
          RETURN;
		END IF;
		-- Validate the IGS_GR_GRADUAND approval status value
		OPEN c_gas;
		FETCH c_gas INTO v_gas_rec;
		IF c_gas%NOTFOUND THEN
			CLOSE c_gas;
   				Fnd_Message.Set_Name('IGS', 'IGS_GE_INVALID_VALUE');
          --App_Exception.Raise_Exception;
				  FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2690151
          RETURN;
		END IF;
		CLOSE c_gas;
		IF v_gas_rec.closed_ind = 'Y' THEN
   				Fnd_Message.Set_Name('IGS', 'IGS_GR_GRAD_APPR_STATUS_CLOSE');
          --App_Exception.Raise_Exception;
				  FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2690151
          RETURN;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			IF c_gst%ISOPEN THEN
				CLOSE c_gst;
			END IF;
			IF c_gas%ISOPEN THEN
				CLOSE c_gas;
			END IF;
			RAISE;
	END;
	EXCEPTION
		WHEN OTHERS THEN
	       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       			App_Exception.Raise_Exception;
	END grdpl_val_graduand_status;
-------------------------------------------------------------------
  PROCEDURE grdpl_ins_new_graduand(
    p_person_id              igs_en_stdnt_ps_att.person_id%TYPE,
    p_course_cd              igs_en_stdnt_ps_att.course_cd%TYPE,
    p_version_number         igs_en_stdnt_ps_att.version_number%TYPE,
    p_grd_cal_type           igs_gr_crmn_round.grd_cal_type%TYPE,
    p_grd_ci_sequence_number igs_gr_crmn_round.grd_ci_sequence_number%TYPE,
    p_award_cd               igs_en_spa_awd_aim.award_cd%TYPE,
    p_message_name           IN OUT NOCOPY  VARCHAR2)  AS
    --
    --  Change History :
    --  Who             When            What
    --  (reverse chronological order - newest change first)
    --  Nalin Kumar     23-Nov-2001     Modified the grdpl_ins_new_graduand procedure
    --                as per the UK Award Aims DLD. Bug ID: 1366899
    --
  BEGIN -- grdpl_ins_new_graduand
        -- 2.1  Create New Graduands
    DECLARE
      --
      -- New code added for the UK Award Aims DLD.
      --
      CURSOR  c_spaaa  IS
      SELECT  spaaa.award_cd,
              spaaa.start_dt,
              spaaa.complete_ind,
              spaaa.conferral_date
      FROM  igs_en_spa_awd_aim  spaaa
      WHERE spaaa.person_id = p_person_id
      AND spaaa.course_cd   = p_course_cd
      AND spaaa.award_cd    = p_award_cd
      AND ((spaaa.end_dt is NULL OR  spaaa.complete_ind = 'Y')
             OR(spaaa.conferral_date IS NOT NULL))
      AND NOT EXISTS (
        SELECT  'x'
        FROM  IGS_GR_GRADUAND gr
        WHERE gr.person_id = p_person_id
          AND gr.course_cd = p_course_cd
          AND gr.grd_cal_type = p_grd_cal_type
          AND gr.grd_ci_sequence_number = p_grd_ci_sequence_number
          AND gr.award_course_cd = p_course_cd
          AND gr.award_crs_version_number = p_version_number
          AND gr.award_cd = spaaa.award_cd)
        ORDER BY spaaa.start_dt DESC,
                 spaaa.complete_ind DESC;

      --
      -- Added to fix Bug# 2683072
      --
      CURSOR c_spaaa_chk  IS
      SELECT 'X'
      FROM igs_en_spa_awd_aim spaaa
      WHERE spaaa.person_id = p_person_id
      AND spaaa.course_cd   = p_course_cd
      AND spaaa.award_cd    = p_award_cd
      AND NOT EXISTS (
        SELECT  'x'
        FROM  igs_gr_graduand gr
        WHERE gr.person_id = p_person_id
          AND gr.course_cd = p_course_cd
          AND gr.grd_cal_type = p_grd_cal_type
          AND gr.grd_ci_sequence_number = p_grd_ci_sequence_number
          AND gr.award_course_cd = p_course_cd
          AND gr.award_crs_version_number = p_version_number
          AND gr.award_cd = spaaa.award_cd);
      l_rec_spaaa_chk c_spaaa_chk%ROWTYPE;
      --
      -- End of new code added to fix Bug# 2683072
      --

      v_graduand_status   IGS_GR_STAT.graduand_status%TYPE;
      v_approval_status   IGS_GR_APRV_STAT.graduand_appr_status%TYPE;
      v_records_update  NUMBER DEFAULT 0;
      v_records_not_found NUMBER DEFAULT 0;
      v_last_start_dt   DATE;
      v_last_complete_ind VARCHAR2(1);

      l_msg_count    NUMBER;
      l_msg_data      VARCHAR2(2000);
      l_msg_index_out NUMBER;
      l_app_name      VARCHAR2(30) DEFAULT 'IGS';
      l_message_name  VARCHAR2(40);
      l_hold          VARCHAR2(1) := NULL;
    BEGIN
      -- Set the default message number
      p_message_name := NULL;
      --
      -- Loop through the Student Program Attempt Award Aim records
      --
      FOR v_spaaa_rec IN c_spaaa LOOP
        --
        -- If it is the first record OR it has the same start date and completion status as the
        -- previous record insert a graduand record.
        --
        IF (v_spaaa_rec.start_dt     = v_last_start_dt AND
            v_spaaa_rec.complete_ind = v_last_complete_ind) OR
            v_last_start_dt IS NULL THEN
          v_last_complete_ind := v_spaaa_rec.complete_ind;
          v_last_start_dt     := v_spaaa_rec.start_dt;

          --
          -- Determine what the initial graduand status should be
          IF IGS_GR_VAL_GR.grdp_val_aw_eligible(p_person_id,
                                                p_course_cd,
                                                p_course_cd,
                                                p_version_number,
                                                v_spaaa_rec.award_cd,
                                                p_message_name) THEN

            v_graduand_status := p_eligible_graduand_status;
          ELSE
            v_graduand_status := p_potential_graduand_status;
          END IF;
          --
          --  To change the CREATE_DT value by one second to pass the primary key
          --  validation for the IGS_GR_GRADUAND table, which is the combination of the PERSON_ID and CREATE_DT.
          IF p_person_id = v_person_id THEN
            dbms_lock.sleep(1);
          ELSE
            v_person_id := p_person_id;
          END IF;

          --IF v_spaaa_rec.conferral_date IS NOT NULL AND
          IF NVL(v_spaaa_rec.complete_ind, 'N') = 'Y' AND
            /*
             Added the next AND conditions to consider the case when the Completion Flag is 'Y' in the
             IGSEN070 form but the user has not passed the 'Gradutated Status' or 'Approval Status for Graduate'-
             then in this case this Job should not create a new record with 'Conferral Date' mentioned and
             'Graduand Status' as 'ELIGIBLE' or 'POTANTIAL'.
            */
             p_graduand_status IS NOT NULL AND p_approval_status IS NOT NULL THEN
            DECLARE
              CURSOR cur_sca IS
              SELECT sca.course_rqrmnt_complete_ind
              FROM  igs_en_stdnt_ps_att sca
              WHERE sca.person_id = p_person_id AND
              sca.course_cd = p_course_cd;
              rec_sca cur_sca%ROWTYPE;
            BEGIN
              OPEN cur_sca;
              FETCH cur_sca INTO rec_sca;
                IF NVL(rec_sca.course_rqrmnt_complete_ind, 'N') = 'Y' THEN
                  v_graduand_status := p_graduand_status;
                  v_approval_status := p_approval_status;
                ELSE
                  v_approval_status := p_graduand_appr_status;
                END IF;
              CLOSE cur_sca;
            END;
  --*******
          ELSE
            -- if the 'Gradutated Status' or 'Approval Status for Graduated' is null then dont consider the 'Completion Flag'.
            -- Because Conferral Date should not be mentioned with the 'Graduand Status' of 'ELIGIBLE' or 'POTANTIAL'.
            v_approval_status := p_graduand_appr_status;
          END IF;
          --
          -- Insert IGS_GR_GRADUAND record
          --
          DECLARE
            lv_rowid VARCHAR2(25);
            lv_create_dt DATE DEFAULT NULL;
          BEGIN
            l_org_id := igs_ge_gen_003.get_org_id;
            l_hold := 'N';
            IGS_GR_GRADUAND_PKG.INSERT_ROW(
              X_ROWID => lv_rowid,
              X_PERSON_ID => p_person_id,
              X_CREATE_DT => lv_create_dt,
              X_GRD_CAL_TYPE => p_grd_cal_type,
              X_GRD_CI_SEQUENCE_NUMBER => p_grd_ci_sequence_number,
              X_COURSE_CD => p_course_cd,
              X_AWARD_COURSE_CD => p_course_cd,
              X_AWARD_CRS_VERSION_NUMBER => p_version_number,
              X_AWARD_CD => v_spaaa_rec.award_cd,
              X_GRADUAND_STATUS => v_graduand_status,
              X_GRADUAND_APPR_STATUS => v_approval_status,
              X_S_GRADUAND_TYPE => NULL,
              X_GRADUATION_NAME => IGS_GR_GEN_001.grdp_get_grad_name(p_person_id),
              X_PROXY_AWARD_IND => NULL,
              X_PROXY_AWARD_PERSON_ID => NULL,
              X_PREVIOUS_QUALIFICATIONS => NULL,
              X_CONVOCATION_MEMBERSHIP_IND => NULL,
              X_SUR_FOR_COURSE_CD => NULL,
              X_SUR_FOR_CRS_VERSION_NUMBER => NULL,
              X_SUR_FOR_AWARD_CD => NULL,
              X_COMMENTS => NULL,
              X_MODE => 'R',
              X_ORG_ID => l_org_id,
              X_ATTRIBUTE_CATEGORY      => NULL,
              X_ATTRIBUTE1   => NULL,
              X_ATTRIBUTE2   => NULL,
              X_ATTRIBUTE3   => NULL,
              X_ATTRIBUTE4   => NULL,
              X_ATTRIBUTE5   => NULL,
              X_ATTRIBUTE6   => NULL,
              X_ATTRIBUTE7   => NULL,
              X_ATTRIBUTE8   => NULL,
              X_ATTRIBUTE9   => NULL,
              X_ATTRIBUTE10  => NULL,
              X_ATTRIBUTE11  => NULL,
              X_ATTRIBUTE12  => NULL,
              X_ATTRIBUTE13  => NULL,
              X_ATTRIBUTE14  => NULL,
              X_ATTRIBUTE15  => NULL,
              X_ATTRIBUTE16  => NULL,
              X_ATTRIBUTE17  => NULL,
              X_ATTRIBUTE18  => NULL,
              X_ATTRIBUTE19  => NULL,
              X_ATTRIBUTE20  => NULL
            );
          EXCEPTION
           WHEN OTHERS THEN
             --
             -- Check if there was a hold related problem, if yes then display proper error message.
             -- Added to fix bug# 2690151
             --
             l_message_name := NULL;
             IGS_GE_MSG_STACK.GET(IGS_GE_MSG_STACK.COUNT_MSG,'T',l_msg_data,l_msg_index_out);
             FND_MESSAGE.PARSE_ENCODED(l_msg_data, l_app_name, l_message_name);
             IF NVL(l_message_name,'NULL') = 'IGS_GR_CANNOT_BE_APPROVED' THEN
               l_hold := 'Y';
               FND_MESSAGE.SET_NAME('IGS', 'IGS_GR_GRD_HOLD');
               FND_MESSAGE.SET_TOKEN('PERSON',l_person_number);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'  '||FND_MESSAGE.GET);
               EXIT; --If hold is there then don't process any other award...
             ELSIF l_message_name IS NOT NULL THEN
               FND_MESSAGE.SET_NAME('IGS',l_message_name);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'  '||FND_MESSAGE.GET());
               EXIT; --Dont EXIT; Let the system process another SPAAA record for the student.
             ELSE
               --IGS_UC_ERROR_PROC_DATA - Unexpected error encountered while processing VIEW data
               FND_MESSAGE.SET_NAME('IGS','IGS_UC_ERROR_PROC_DATA');
               FND_MESSAGE.SET_TOKEN('VIEW',l_person_number);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'  '||FND_MESSAGE.GET());
               EXIT;
               --RAISE; --Dont raise any error... log it in log file and proceed with next student...
             END IF;
          END;
          FND_MESSAGE.SET_NAME('IGS','IGS_GR_GRD_REC_CRTED');
          FND_MESSAGE.SET_TOKEN('PERSON',l_person_number);
          FND_MESSAGE.SET_TOKEN('COURSE',p_course_cd);
          FND_MESSAGE.SET_TOKEN('AWARD',v_spaaa_rec.award_cd);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'  '||FND_MESSAGE.GET());
          -- End of new code added as per the bug# 2690151
          v_records_update := v_records_update + 1;
        END IF;
      END LOOP;

      --
      -- If records were inserted from the Award Aims table return.  Otherwise insert records from the
      -- Program Award table
      --
      IF v_records_update > 0 THEN
        RETURN;
      END IF;

      --
      -- Added to fix Bug# 2683072
      --
      OPEN c_spaaa_chk;
      FETCH c_spaaa_chk INTO l_rec_spaaa_chk;
      IF c_spaaa_chk%FOUND THEN
        CLOSE c_spaaa_chk;
        IF NVL(l_hold,'N') <> 'Y' THEN --"l_hold = 'N'" Indicates no Hold related problems...
          FND_MESSAGE.SET_NAME('IGS','IGS_PR_PRG');
          l_person_number := l_person_number||' '||FND_MESSAGE.GET()||': '||p_course_cd||' - '||p_award_cd;
          FND_MESSAGE.SET_NAME('IGS','IGS_GR_AWD_AIM_SETUP');
          FND_MESSAGE.SET_TOKEN('PERSON',l_person_number);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'  '||FND_MESSAGE.GET());
        END IF;
        RETURN;
      END IF;
      CLOSE c_spaaa_chk;
      --
      -- End of new code added as per the Bug# 2683072
      --

      DECLARE
        CURSOR cur_spaa_gr_dif  IS
        SELECT 'X'
        FROM igs_en_spa_awd_aim spaaa
        WHERE spaaa.person_id = p_person_id
        AND spaaa.course_cd   = p_course_cd
        AND spaaa.award_cd    = p_award_cd
        AND EXISTS (
          SELECT  'x'
          FROM  igs_gr_graduand gr
          WHERE gr.person_id = p_person_id
            AND gr.course_cd = p_course_cd
            AND gr.grd_cal_type = p_grd_cal_type
            AND gr.grd_ci_sequence_number = p_grd_ci_sequence_number
            AND gr.award_course_cd = p_course_cd
            AND gr.award_crs_version_number = p_version_number
            AND gr.award_cd = spaaa.award_cd);
        rec_spaa_gr_dif cur_spaa_gr_dif%ROWTYPE;
      BEGIN
        IF v_records_update = 0 AND NVL(l_hold,'N') <> 'Y' THEN
          OPEN cur_spaa_gr_dif;
          FETCH cur_spaa_gr_dif INTO rec_spaa_gr_dif;
          IF cur_spaa_gr_dif%NOTFOUND THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_GR_NO_REC_CRETD');
            FND_MESSAGE.SET_TOKEN('PERSON',l_person_number);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'  '||FND_MESSAGE.GET());
          ELSIF cur_spaa_gr_dif%FOUND THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_GR_GRD_REC_EXT');
            FND_MESSAGE.SET_TOKEN('PERSON',l_person_number);
            FND_MESSAGE.SET_TOKEN('COURSE',p_course_cd);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'  '||FND_MESSAGE.GET());
          END IF;
          CLOSE cur_spaa_gr_dif;
        END IF;
      END;
      --
      -- End of new code added to fix bug# 2690151
      --
    EXCEPTION
      WHEN OTHERS THEN
        IF c_spaaa%ISOPEN THEN
          CLOSE c_spaaa;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      App_Exception.Raise_Exception;
  END grdpl_ins_new_graduand;
-------------------------------------------------------------------
  BEGIN
	-- 1. Check parameters
	IF (p_grd_cal_type IS NULL AND
			p_grd_ci_sequence_number IS NOT NULL) OR
			(p_grd_ci_sequence_number IS NULL AND
			p_grd_cal_type IS NOT NULL) OR
			p_nominated_completion IS NULL OR
			p_derived_completion IS NULL OR
			p_restrict_rqrmnt_complete IS NULL OR
			p_potential_graduand_status IS NULL OR
			p_eligible_graduand_status IS NULL OR
			p_graduand_appr_status IS NULL THEN
   	Fnd_Message.Set_Name('IGS', 'IGS_GE_INVALID_VALUE');
    --App_Exception.Raise_Exception;
		FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2690151
    RETURN;
	END IF;
	-- Validate completion criterion
	IF p_nominated_completion = 'N' AND
			p_derived_completion = 'N' THEN
   	Fnd_Message.Set_Name('IGS', 'IGS_GR_NOMIN_DERV_COMPL_SET');
    --App_Exception.Raise_Exception;
		FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2690151
    RETURN;
	END IF;
  --
	-- Validate the status values provided
  --
	grdpl_val_graduand_status;
  --
  --

  -- Create the SPAA records for all defaulted Awards at the Program level.
  -- This should happen only when there is not even a single SPAA record for the Student.
  FOR v_crd_sca_rec IN c_crd_sca LOOP
    --Check if the SPAA record exists or not. If no SPAA record exists
    --for the given Person Number and Course Code combination then create
    --the SPAA record for each defaulted Awards (defined at the Program Version Level).
    --Added as part of the Program Completion Validation Build; Bug# 3129913; Nalin Kumar;
    OPEN cur_spaaa(v_crd_sca_rec.person_id, v_crd_sca_rec.course_cd);
    FETCH cur_spaaa INTO rec_spaaa;
    IF cur_spaaa%NOTFOUND THEN
      CLOSE cur_spaaa;
      DECLARE
        --Fetch all defaulted Awards for the Program Version.
        CURSOR cur_def_awds IS
        SELECT caw.award_cd,
               grd.grading_schema_cd,
               grd.gs_version_number
        FROM  igs_ps_award caw,
              igs_ps_awd grd
        WHERE caw.course_cd  = v_crd_sca_rec.course_cd AND
          caw.version_number = v_crd_sca_rec.version_number AND
          caw.default_ind    = 'Y' AND
          caw.closed_ind     = 'N' AND
          caw.award_cd       = grd.award_cd(+);
        l_row_id VARCHAR2(30);
      BEGIN
        --Loop through all Defaulted Awards and create the SPAA records.
        FOR rec_def_awds IN cur_def_awds LOOP
          igs_en_spa_awd_aim_pkg.insert_row(
            X_ROWID             => l_row_id,
            X_PERSON_ID         => v_crd_sca_rec.person_id,
            X_COURSE_CD         => v_crd_sca_rec.course_cd,
            X_AWARD_CD          => rec_def_awds.award_cd,
            X_START_DT          => v_crd_sca_rec.commencement_dt,
            X_END_DT            => NULL,
            X_COMPLETE_IND      => 'N',
            X_CONFERRAL_DATE    => NULL,
            X_MODE              => 'R',
            X_AWARD_MARK        => NULL,
            X_AWARD_GRADE       => NULL,
            X_GRADING_SCHEMA_CD => rec_def_awds.grading_schema_cd,
            X_GS_VERSION_NUMBER => rec_def_awds.gs_version_number);
          l_row_id := NULL;
        END LOOP;
      END;
    ELSE
      CLOSE cur_spaaa;
    END IF;
  END LOOP;

	-- 2. Find Potential Graduands
	-- establish the ceremony rounds to process within.
  -- get the completion period to target potential graduands.
	-- get the target potential IGS_GR_GRADUAND details.
  l_log_person_id := 'NULL';
  l_chk_hold := 'NULL';

  FOR v_crd_sca_rec IN c_crd_sca LOOP
		-- check the student hasn't already graduated, articulated
		-- or declined in an IGS_PS_AWD for the IGS_PS_COURSE
		--Get the Person Number
		OPEN get_person_num(v_crd_sca_rec.person_id);
		FETCH get_person_num INTO l_person_number;
		CLOSE get_person_num;

    --Log this message only once for a person.
    IF l_log_person_id = 'NULL' OR
       l_log_person_id <> v_crd_sca_rec.person_id||'-'||v_crd_sca_rec.course_cd THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_MESSAGE.SET_NAME('IGS','IGS_GR_PROCESSING');
      FND_MESSAGE.SET_TOKEN('PERSON',l_person_number);
      FND_MESSAGE.SET_TOKEN('COURSE',v_crd_sca_rec.course_cd);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET());
      l_log_person_id := v_crd_sca_rec.person_id||'-'||v_crd_sca_rec.course_cd;
    END IF;

    OPEN c_gr(
      v_crd_sca_rec.person_id,
      v_crd_sca_rec.course_cd,
      v_crd_sca_rec.award_cd);
    FETCH c_gr INTO v_gr_exists;
		IF c_gr%NOTFOUND THEN
			CLOSE c_gr;
      --Check the Graduation Block.
      IF p_graduand_appr_status = 'APPROVED' THEN
        IF l_chk_hold = 'NULL' OR
           l_chk_hold <> v_crd_sca_rec.person_id||'-'||v_crd_sca_rec.course_cd THEN
          IF igs_gr_val_gr.enrp_val_encmb_efct(
              p_person_id         => v_crd_sca_rec.person_id,
              p_course_cd         => v_crd_sca_rec.course_cd,
              p_effective_dt      => SYSDATE,
              p_encmb_effect_type => 'GRAD_BLK',
              p_message_name      => v_message_name) = TRUE THEN
            FND_MESSAGE.SET_NAME('IGS', 'IGS_GR_GRD_HOLD');
            FND_MESSAGE.SET_TOKEN('PERSON',l_person_number);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'  '||FND_MESSAGE.GET);
            l_chk_hold := v_crd_sca_rec.person_id||'-'||v_crd_sca_rec.course_cd;
          END IF;
        END IF;
      END IF;
      IF l_chk_hold = 'NULL' OR
         l_chk_hold <> v_crd_sca_rec.person_id||'-'||v_crd_sca_rec.course_cd THEN
        -- Do 2.1 Create New IGS_GR_GRADUAND
        grdpl_ins_new_graduand(
            v_crd_sca_rec.person_id,
            v_crd_sca_rec.course_cd,
            v_crd_sca_rec.version_number,
            v_crd_sca_rec.grd_cal_type,
            v_crd_sca_rec.grd_ci_sequence_number,
            v_crd_sca_rec.award_cd,
            v_message_name);
      END IF;
		ELSE
		  FND_MESSAGE.SET_NAME('IGS','IGS_GR_GRD_REC_EXT');
		  FND_MESSAGE.SET_TOKEN('PERSON',l_person_number);
		  FND_MESSAGE.SET_TOKEN('COURSE',v_crd_sca_rec.course_cd);
		  FND_FILE.PUT_LINE(FND_FILE.LOG,'  '||FND_MESSAGE.GET());
		  FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
			CLOSE c_gr;
		END IF;
	END LOOP;	-- crd_sca
  EXCEPTION
	WHEN OTHERS THEN
		IF c_crd_sca%ISOPEN THEN
			CLOSE c_crd_sca;
		END IF;
		IF c_gr%ISOPEN THEN
			CLOSE c_gr;
		END IF;
		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		RETCODE := 2;
		ERRBUF := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END grdp_ins_graduand;


PROCEDURE grdp_ins_gr_hist(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_create_dt  IGS_GR_GRADUAND_ALL.create_dt%TYPE ,
  p_old_grd_cal_type  IGS_GR_GRADUAND_ALL.grd_cal_type%TYPE ,
  p_new_grd_cal_type  IGS_GR_GRADUAND_ALL.grd_cal_type%TYPE ,
  p_old_grd_ci_sequence_number  IGS_GR_GRADUAND_ALL.grd_ci_sequence_number%TYPE ,
  p_new_grd_ci_sequence_number  IGS_GR_GRADUAND_ALL.grd_ci_sequence_number%TYPE ,
  p_old_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_new_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_old_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_new_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_old_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_new_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_old_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_new_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_old_honours_level VARCHAR2 DEFAULT NULL,
  p_new_honours_level VARCHAR2 DEFAULT NULL,
  p_old_conferral_dt  DATE DEFAULT NULL,
  p_new_conferral_dt  DATE DEFAULT NULL,
  p_old_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_new_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_old_graduand_appr_status  IGS_GR_GRADUAND_ALL.graduand_appr_status%TYPE ,
  p_new_graduand_appr_status  IGS_GR_GRADUAND_ALL.graduand_appr_status%TYPE ,
  p_old_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_new_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_old_graduation_name IN IGS_GR_GRADUAND_ALL.graduation_name%TYPE ,
  p_new_graduation_name IN IGS_GR_GRADUAND_ALL.graduation_name%TYPE ,
  p_old_proxy_award_ind  IGS_GR_GRADUAND_ALL.proxy_award_ind%TYPE ,
  p_new_proxy_award_ind  IGS_GR_GRADUAND_ALL.proxy_award_ind%TYPE ,
  p_old_proxy_award_person_id  IGS_GR_GRADUAND_ALL.proxy_award_person_id%TYPE ,
  p_new_proxy_award_person_id  IGS_GR_GRADUAND_ALL.proxy_award_person_id%TYPE ,
  p_old_previous_qualifications  IGS_GR_GRADUAND_ALL.previous_qualifications%TYPE ,
  p_new_previous_qualifications  IGS_GR_GRADUAND_ALL.previous_qualifications%TYPE ,
  p_old_convocation_memb_ind  IGS_GR_GRADUAND_ALL.convocation_membership_ind%TYPE ,
  p_new_convocation_memb_ind  IGS_GR_GRADUAND_ALL.convocation_membership_ind%TYPE ,
  p_old_sur_for_course_cd  IGS_GR_GRADUAND_ALL.sur_for_course_cd%TYPE ,
  p_new_sur_for_course_cd  IGS_GR_GRADUAND_ALL.sur_for_course_cd%TYPE ,
  p_old_sur_for_crs_version_numb  IGS_GR_GRADUAND_ALL.sur_for_crs_version_number%TYPE ,
  p_new_sur_for_crs_version_numb  IGS_GR_GRADUAND_ALL.sur_for_crs_version_number%TYPE ,
  p_old_sur_for_award_cd  IGS_GR_GRADUAND_ALL.sur_for_award_cd%TYPE ,
  p_new_sur_for_award_cd  IGS_GR_GRADUAND_ALL.sur_for_award_cd%TYPE ,
  p_old_update_who  IGS_GR_GRADUAND_ALL.last_updated_by%TYPE ,
  p_new_update_who  IGS_GR_GRADUAND_ALL.last_updated_by%TYPE ,
  p_old_update_on  IGS_GR_GRADUAND_ALL.last_update_date%TYPE ,
  p_new_update_on  IGS_GR_GRADUAND_ALL.last_update_date%TYPE ,
  p_old_comments  IGS_GR_GRADUAND_ALL.comments%TYPE ,
  p_new_comments  IGS_GR_GRADUAND_ALL.comments%TYPE )
AS
l_org_id NUMBER(15);
BEGIN	-- grdp_ins_gr_hist
	-- Insert IGS_GR_GRADUAND history(IGS_GR_GRADUAND_HIST)
DECLARE
	v_gr_rec		IGS_GR_GRADUAND_HIST%ROWTYPE;
	v_create_history	BOOLEAN := FALSE;

BEGIN	-- If any of the old values (p_old_<column_name>) are
	-- different from the associated new values (p_new_<column_name>)
	-- (with the exception of the last_update_date and last_updated_by columns)
	-- then create a graduand_history record with the old values
	-- (p_old_<column_name>).  Do not set the last_updated_by and last_update_date
	-- columns when creating the history recor
	IF p_new_grd_cal_type <> p_old_grd_cal_type THEN
		v_gr_rec.grd_cal_type := p_old_grd_cal_type;
		v_create_history := TRUE;
	END IF;
	IF p_new_grd_ci_sequence_number <> p_old_grd_ci_sequence_number THEN
		v_gr_rec.grd_ci_sequence_number := p_old_grd_ci_sequence_number;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_course_cd,'NULL') <> NVL(p_old_course_cd,'NULL') THEN
		v_gr_rec.course_cd := p_old_course_cd;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_award_course_cd,'NULL') <> NVL(p_old_award_course_cd,'NULL') THEN
		v_gr_rec.award_course_cd := p_old_award_course_cd;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_award_crs_version_number,0) <>
		NVL(p_old_award_crs_version_number,0) THEN
		v_gr_rec.award_crs_version_number := p_old_award_crs_version_number;
		v_create_history := TRUE;
	END IF;
	IF p_new_award_cd <> p_old_award_cd THEN
		v_gr_rec.award_cd := p_old_award_cd;
		v_create_history := TRUE;
	END IF;
	IF p_new_graduand_status <> p_old_graduand_status THEN
		v_gr_rec.graduand_status := p_old_graduand_status;
		v_create_history := TRUE;
	END IF;
	IF p_new_graduand_appr_status <> p_old_graduand_appr_status THEN
		v_gr_rec.graduand_appr_status := p_old_graduand_appr_status;
		v_create_history := TRUE;
	END IF;
	IF p_new_s_graduand_type <> p_old_s_graduand_type THEN
		v_gr_rec.s_graduand_type := p_old_s_graduand_type;
		v_create_history := TRUE;
	END IF;
	IF p_new_graduation_name <> p_old_graduation_name THEN
		v_gr_rec.graduation_name := p_old_graduation_name;
		v_create_history := TRUE;
	END IF;
	IF p_new_proxy_award_ind <> p_old_proxy_award_ind THEN
		v_gr_rec.proxy_award_ind := p_old_proxy_award_ind;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_proxy_award_person_id,0) <>
		NVL(p_old_proxy_award_person_id,0) THEN
		v_gr_rec.proxy_award_ind := p_old_proxy_award_ind;
	END IF;
	IF NVL(p_new_previous_qualifications,'NULL') <>
			NVL(p_old_previous_qualifications,'NULL') THEN
		v_gr_rec.previous_qualifications := p_old_previous_qualifications;
		v_create_history := TRUE;
	END IF;
	IF p_new_convocation_memb_ind <> p_old_convocation_memb_ind THEN
		v_gr_rec.convocation_membership_ind := p_old_convocation_memb_ind;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_sur_for_course_cd,'NULL') <>
		NVL(p_old_sur_for_course_cd,'NULL') THEN
		v_gr_rec.sur_for_course_cd := p_old_sur_for_course_cd;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_sur_for_crs_version_numb,0) <>
		NVL(p_old_sur_for_crs_version_numb,0) THEN
		v_gr_rec.sur_for_crs_version_number := p_old_sur_for_crs_version_numb;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_sur_for_award_cd,'NULL') <>
		 NVL(p_old_sur_for_award_cd,'NULL') THEN
		v_gr_rec.sur_for_award_cd := p_old_sur_for_award_cd;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_comments,'NULL') <> NVL(p_old_comments,'NULL') THEN
		v_gr_rec.comments := p_old_comments;
		v_create_history := TRUE;
	END IF;
	-- Insert history rec.
	IF v_create_history THEN
		v_gr_rec.person_id := p_person_id;
		v_gr_rec.create_dt := p_create_dt;
		v_gr_rec.hist_start_dt := p_old_update_on;
		v_gr_rec.hist_end_dt := p_new_update_on;
		v_gr_rec.hist_who := p_old_update_who;
		DECLARE
			lv_rowid VARCHAR2(25);
		BEGIN
      l_org_id := igs_ge_gen_003.get_org_id;
			IGS_GR_GRADUAND_HIST_PKG.INSERT_ROW(
			  X_ROWID => lv_rowid,
			  X_PERSON_ID => v_gr_rec.person_id,
			  X_CREATE_DT => v_gr_rec.create_dt,
			  X_HIST_START_DT => v_gr_rec.hist_start_dt,
			  X_HIST_END_DT => v_gr_rec.hist_end_dt,
			  X_HIST_WHO => v_gr_rec.hist_who,
			  X_GRD_CAL_TYPE => v_gr_rec.grd_cal_type,
			  X_GRD_CI_SEQUENCE_NUMBER => v_gr_rec.grd_ci_sequence_number,
			  X_COURSE_CD => v_gr_rec.course_cd,
			  X_AWARD_COURSE_CD => v_gr_rec.award_course_cd,
			  X_AWARD_CRS_VERSION_NUMBER => v_gr_rec.award_crs_version_number,
			  X_AWARD_CD => v_gr_rec.award_cd,
			  X_GRADUAND_STATUS => v_gr_rec.graduand_status,
			  X_GRADUAND_APPR_STATUS => v_gr_rec.graduand_appr_status,
			  X_S_GRADUAND_TYPE => v_gr_rec.s_graduand_type,
			  X_GRADUATION_NAME => v_gr_rec.graduation_name,
			  X_PROXY_AWARD_IND => v_gr_rec.proxy_award_ind,
			  X_PROXY_AWARD_PERSON_ID => v_gr_rec.proxy_award_person_id,
			  X_PREVIOUS_QUALIFICATIONS => v_gr_rec.previous_qualifications,
			  X_CONVOCATION_MEMBERSHIP_IND => v_gr_rec.convocation_membership_ind,
			  X_SUR_FOR_COURSE_CD => v_gr_rec.sur_for_course_cd,
			  X_SUR_FOR_CRS_VERSION_NUMBER => v_gr_rec.sur_for_crs_version_number,
			  X_SUR_FOR_AWARD_CD => v_gr_rec.sur_for_award_cd,
			  X_COMMENTS => v_gr_rec.comments,
			  X_MODE => 'R',
        X_ORG_ID => l_org_id
      );
		END;
	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		App_Exception.Raise_Exception;
END grdp_ins_gr_hist;


PROCEDURE grdp_prc_gac(
  errbuf  out NOCOPY  varchar2,
	retcode out NOCOPY  number,
	p_ceremony_round IN VARCHAR2,
	p_lctn_cd IN VARCHAR2 ,
	p_grdnd_status IN VARCHAR2 ,
	p_resolve_stalemate_type IN VARCHAR2 ,
	p_ignore_unit_sets_ind IN VARCHAR2 ,
  p_org_id NUMBER)
AS
	p_grd_cal_type  			igs_ca_inst.cal_type%type;
	p_grd_ci_sequence_number 	igs_ca_inst.sequence_number%type;
  p_location_cd 		IGS_AD_LOCATION.LOCATION_CD%TYPE;
  p_graduand_status 	IGS_GR_STAT.GRADUAND_STATUS%TYPE;

BEGIN	-- grdp_prc_gac
	-- This process manages the initial allocation of IGS_GR_GRADUAND records to
	-- ceremonies by creating IGS_GR_AWD_CRMN records and the
	-- re-alloaction of graduands when IGS_GR_AWD_CEREMONY and
	-- IGS_GR_AWD_CRM_US_GP records are closed.
	-- The process finds closed IGS_GR_AWD_CEREMONY records for the specified
	-- IGS_GR_CRMN_ROUND, calls GENP_PRC_AWC_CLOSE to re-allocate any associated
	-- graduands.
	-- The process finds closed IGS_GR_AWD_CRM_US_GP records for the specified
	-- IGS_GR_CRMN_ROUND, calls GENP_PRC_ACUSG_CLOSE to re-allocate any associated
	-- graduands.
	-- The process finds any IGS_GR_GRADUAND records for the specified IGS_GR_CRMN_ROUND,
	-- location_cd, and IGS_GR_STAT which do not have an existing
	-- IGS_GR_AWD_CRMN record and calls GENP_INS_GAC to determine if a
	-- ceremony exists suitable for the  IGS_GR_GRADUAND and if one is suitable create
	-- a IGS_GR_AWD_CRMN record linking the IGS_GR_GRADUAND to it.

	--
  --  Change History :
  --  Who             When            What
  --  (reverse chronological order - newest change first)
	--
	--  Nalin Kumar   18-DEC-2002    Modified this procedure to fix Bug# 2690151.
	--                               Added the code to log the parameters value in the log file.
	--

  --Block for Parameter Validation/Splitting of Parameters
	retcode:=0;
      igs_ge_gen_003.set_org_id(p_org_id);
    p_location_cd 		:=	NVL(p_lctn_cd,'%');
    p_graduand_status 	:=	NVL(p_grdnd_status,'%');


	BEGIN
		p_grd_cal_type 		   := RTRIM(SUBSTR(p_ceremony_round, 101, 10));
		p_grd_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_ceremony_round, 112, 6)));
	END;
  --End of Block for Parameter Validation/Splitting of Parameters

DECLARE
	cst_surrender		VARCHAR2(10) := 'SURRENDER';
	cst_attending		VARCHAR2(10) := 'ATTENDING';
	cst_unknown		VARCHAR2(10) := 'UNKNOWN';
	cst_deferred		VARCHAR2(10) := 'DEFERRED';
	e_resource_busy_exception	EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54 );
	v_message_name		VARCHAR2(30);
	v_exit_loop		BOOLEAN := FALSE;

	CURSOR	c_awc IS
	SELECT	awc.ceremony_number,
		awc.award_course_cd,
		awc.award_crs_version_number,
		awc.award_cd
	FROM	IGS_GR_AWD_CEREMONY	awc
	WHERE	awc.grd_cal_type			= p_grd_cal_type AND
		awc.grd_ci_sequence_number 	= p_grd_ci_sequence_number AND
		awc.closed_ind = 'Y';
	CURSOR	c_acusg IS
		SELECT	acusg.ceremony_number,
			acusg.award_course_cd,
			acusg.award_crs_version_number,
			acusg.award_cd,
			acusg.us_group_number
		FROM	IGS_GR_AWD_CRM_US_GP	acusg
		WHERE	acusg.grd_cal_type 		= p_grd_cal_type AND
			acusg.grd_ci_sequence_number 	= p_grd_ci_sequence_number AND
			acusg.closed_ind = 'Y';
	CURSOR	c_gr IS
	SELECT	gr.person_id,
		gr.create_dt,
		gr.s_graduand_type,
		gr.grd_cal_type,
		gr.grd_ci_sequence_number
	FROM	IGS_GR_GRADUAND		gr,
		IGS_GR_STAT		gst,
		IGS_EN_STDNT_PS_ATT	sca
	WHERE	gr.grd_cal_type 		= p_grd_cal_type		AND
		gr.grd_ci_sequence_number 	= p_grd_ci_sequence_number 	AND
		gr.graduand_status 		= gst.graduand_status 		AND
		gst.s_graduand_status 		<> cst_surrender 		AND
		gst.graduand_status 		like p_graduand_status 		AND
		gr.s_graduand_type 		IN (	cst_attending,
							cst_unknown,
							cst_deferred) 		AND
		gr.person_id 			= sca.person_id  		AND
		gr.course_cd 			= sca.course_cd 		AND
		sca.location_cd 		like p_location_cd  		AND
		NOT EXISTS
			(SELECT	'X'
			FROM	IGS_GR_AWD_CRMN	gac
			WHERE	gac.person_id = gr.person_id AND
				gac.create_dt = gr.create_dt);
	--
	-- sepalani Bug# 5074150
	--
	CURSOR c_gr_upd (
		cp_person_id			IGS_GR_GRADUAND_ALL.person_id%TYPE,
		cp_create_dt			IGS_GR_GRADUAND_ALL.create_dt%TYPE) IS
		SELECT 	rowid, gr.*
		FROM 	IGS_GR_GRADUAND_ALL gr
		WHERE	gr.person_id 	= cp_person_id AND
			gr.create_dt	= cp_create_dt
		FOR UPDATE OF s_graduand_type NOWAIT;
	v_gr_del c_gr_upd%ROWTYPE;
BEGIN
  --
  --Log the Parameters value in the log file. This is to fix Bug# 2690151
  --
	FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_ANC_LOG_PARM');
	FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET()||':');
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_grd_cal_type = '||p_grd_cal_type);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_grd_ci_sequence_number = '||p_grd_ci_sequence_number);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_location_cd = '||p_location_cd);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_graduand_status  = '||p_graduand_status);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_resolve_stalemate_type = '||p_resolve_stalemate_type);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_ignore_unit_sets_ind  = '||p_ignore_unit_sets_ind);
	FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

	-- 1. Check parameters :
	IF p_grd_cal_type IS NULL OR
			p_grd_ci_sequence_number IS NULL OR
			p_location_cd IS NULL OR
			p_graduand_status IS NULL OR
			p_resolve_stalemate_type IS NULL OR
			p_ignore_unit_sets_ind IS NULL THEN
    		Fnd_Message.Set_Name('IGS', 'IGS_GE_INSUFFICIENT_PARAMETER');
		    App_Exception.Raise_Exception;
	END IF;
	-- 2.1	Find any closed IGS_GR_AWD_CEREMONY records for the specified
	-- IGS_GR_CRMN_ROUND and loop through them.
	FOR v_awc_rec IN c_awc LOOP
		-- 2.2 Call GENP_PRC_AWC_CLOSE to process the graduands for the
		-- IGS_GR_AWD_CEREMONY record and then delete it.
		IF IGS_GR_PRC_GAC.grdp_prc_awc_close(
				p_grd_cal_type,
				p_grd_ci_sequence_number,
				v_awc_rec.ceremony_number,
				v_awc_rec.award_course_cd,
				v_awc_rec.award_crs_version_number,
				v_awc_rec.award_cd,
				p_resolve_stalemate_type,
				p_ignore_unit_sets_ind,
				v_message_name) = FALSE THEN
	    				Fnd_Message.Set_Name('IGS', v_message_name);
			    		App_Exception.Raise_Exception;
		END IF;
	END LOOP; -- c_awc
	-- 3.1 Find closed IGS_GR_AWD_CRM_US_GP records for the specified
	-- IGS_GR_CRMN_ROUND and loop through them.
	FOR v_acusg_rec IN c_acusg LOOP
		-- 3.2 Call GENP_PRC_ACUSG_CLOSE to process the graduands for the
		-- IGS_GR_AWD_CRM_US_GP record and then delete it.
		IF IGS_GR_PRC_GAC.grdp_prc_acusg_close(
				p_grd_cal_type,
				p_grd_ci_sequence_number,
				v_acusg_rec.ceremony_number,
				v_acusg_rec.award_course_cd,
				v_acusg_rec.award_crs_version_number,
				v_acusg_rec.award_cd,
				v_acusg_rec.us_group_number,
				p_resolve_stalemate_type,
				p_ignore_unit_sets_ind,
				v_message_name) = FALSE THEN
	    				Fnd_Message.Set_Name('IGS', v_message_name);
			    		App_Exception.Raise_Exception;
		END IF;
	END LOOP; -- c_acusg
	-- 4.1 Find any IGS_GR_GRADUAND records matching the IGS_GR_CRMN_ROUND, location_cd
	-- and IGS_GR_STAT specified which do not have an existing
	-- IGS_GR_AWD_CRMN record and loop through them.
	FOR v_gr_rec IN c_gr LOOP
		SAVEPOINT sp_prc_gac;
		-- 4.2 If the IGS_GR_GRADUAND has been deferred into this IGS_GR_CRMN_ROUND update the
		-- s_graduand_type from DEFERRED to UNKOWN.  DO NOT COMMIT THIS UPDATE.
		IF v_gr_rec.s_graduand_type = cst_deferred THEN
			BEGIN
				OPEN c_gr_upd(
					v_gr_rec.person_id,
					v_gr_rec.create_dt);
				FETCH c_gr_upd INTO v_gr_del;
				-- 3.Delete the existing IGS_GR_AWD_CRMN record
				IF (c_gr_upd%FOUND) THEN
					IGS_GR_GRADUAND_PKG.UPDATE_ROW(
					  X_ROWID => v_gr_del.rowid,
					  X_PERSON_ID => v_gr_del.person_id,
					  X_CREATE_DT => v_gr_del.create_dt,
					  X_GRD_CAL_TYPE => v_gr_del.grd_cal_type,
					  X_GRD_CI_SEQUENCE_NUMBER => v_gr_del.grd_ci_sequence_number,
					  X_COURSE_CD => v_gr_del.course_cd,
					  X_AWARD_COURSE_CD => v_gr_del.award_course_cd,
					  X_AWARD_CRS_VERSION_NUMBER => v_gr_del.award_crs_version_number,
					  X_AWARD_CD => v_gr_del.award_cd,
					  X_GRADUAND_STATUS => v_gr_del.graduand_status,
					  X_GRADUAND_APPR_STATUS => v_gr_del.graduand_appr_status,
					  X_S_GRADUAND_TYPE => cst_unknown,
					  X_GRADUATION_NAME => v_gr_del.graduation_name,
					  X_PROXY_AWARD_IND => v_gr_del.proxy_award_ind,
					  X_PROXY_AWARD_PERSON_ID => v_gr_del.proxy_award_person_id,
					  X_PREVIOUS_QUALIFICATIONS => v_gr_del.previous_qualifications,
					  X_CONVOCATION_MEMBERSHIP_IND => v_gr_del.convocation_membership_ind,
					  X_SUR_FOR_COURSE_CD => v_gr_del.sur_for_course_cd,
					  X_SUR_FOR_CRS_VERSION_NUMBER => v_gr_del.sur_for_crs_version_number,
					  X_SUR_FOR_AWARD_CD => v_gr_del.sur_for_award_cd,
					  X_COMMENTS => v_gr_del.comments,
					  X_MODE => 'R',
            X_ATTRIBUTE_CATEGORY => v_gr_del.attribute_category,
            X_ATTRIBUTE1         => v_gr_del.attribute1,
            X_ATTRIBUTE2         => v_gr_del.attribute2,
            X_ATTRIBUTE3         => v_gr_del.attribute3,
            X_ATTRIBUTE4         => v_gr_del.attribute4,
            X_ATTRIBUTE5         => v_gr_del.attribute5,
            X_ATTRIBUTE6         => v_gr_del.attribute6,
            X_ATTRIBUTE7         => v_gr_del.attribute7,
            X_ATTRIBUTE8         => v_gr_del.attribute8,
            X_ATTRIBUTE9         => v_gr_del.attribute9,
            X_ATTRIBUTE10        => v_gr_del.attribute10,
            X_ATTRIBUTE11        => v_gr_del.attribute11,
            X_ATTRIBUTE12        => v_gr_del.attribute12,
            X_ATTRIBUTE13        => v_gr_del.attribute13,
            X_ATTRIBUTE14        => v_gr_del.attribute14,
            X_ATTRIBUTE15        => v_gr_del.attribute15,
            X_ATTRIBUTE16        => v_gr_del.attribute16,
            X_ATTRIBUTE17        => v_gr_del.attribute17,
            X_ATTRIBUTE18        => v_gr_del.attribute18,
            X_ATTRIBUTE19        => v_gr_del.attribute19,
            X_ATTRIBUTE20        => v_gr_del.attribute20
            );
				END IF;
				CLOSE c_gr_upd;
			EXCEPTION
				WHEN e_resource_busy_exception THEN
					IF c_gr_upd%ISOPEN THEN
						CLOSE c_gr_upd;
					END IF;
					ROLLBACK TO sp_prc_gac;
		    			Fnd_Message.Set_Name('IGS', 'IGS_GR_CANNOT_UPDATE_GRAD_REC');
				  	App_Exception.Raise_Exception;
				WHEN OTHERS THEN
					ROLLBACK TO sp_prc_gac;
					RAISE;
			END;
		END IF;
		-- 4.3 Call GENP_PRC_GAC_CRMNY for each IGS_GR_GRADUAND record found which will
		-- create a IGS_GR_AWD_CRMN record allocating it to an appropriate
		-- ceremony if one is available.
		IF IGS_GR_PRC_GAC.grdp_ins_gac(
				v_gr_rec.person_id,
				v_gr_rec.create_dt ,
				v_gr_rec.grd_cal_type,
				v_gr_rec.grd_ci_sequence_number,
				NULL,
				NULL,
				'Y',
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				'N',
				NULL,
				p_resolve_stalemate_type,
				p_ignore_unit_sets_ind,
				v_message_name) = FALSE THEN
	    				Fnd_Message.Set_Name('IGS', v_message_name);
			    		App_Exception.Raise_Exception;
		END IF;
		-- 4.4 If the IGS_GR_GRADUAND has been deferred into this IGS_GR_CRMN_ROUND and they
		-- have not been placed in a ceremony, ROLLBACK the change to the
		-- s_graduand_type to DEFERRED.  If they were placed in a ceremony round
		-- this change would have been commited on the insert of the
		-- IGS_GR_AWD_CRMN record.
		IF v_gr_rec.s_graduand_type = cst_deferred THEN
			ROLLBACK;
		END IF;
	END LOOP; -- c_gr
	-- 5. Return no error:
	RETURN;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_awc%ISOPEN) THEN
			CLOSE c_awc;
		END IF;
		IF (c_acusg%ISOPEN) THEN
			CLOSE c_acusg;
		END IF;
		IF (c_gr%ISOPEN) THEN
			CLOSE c_gr;
		END IF;
		IF (c_gr_upd%ISOPEN) THEN
			CLOSE c_gr_upd;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		/*RETCODE:=2;
		ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		commented for the exception handler related changes*/

		RETCODE := 2;
		ERRBUF := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;


END grdp_prc_gac;


PROCEDURE grdp_set_gr_gst(
	errbuf  out NOCOPY  varchar2,
	retcode out NOCOPY  NUMBER,
	p_eligible_graduand_status IGS_GR_STAT.graduand_status%TYPE ,
	p_potential_graduand_status IGS_GR_STAT.graduand_status%TYPE,
        p_org_id NUMBER,
        p_graduand_status  IGS_GR_STAT.graduand_status%TYPE ,
        p_approval_status IGS_GR_APRV_STAT.graduand_appr_status%TYPE)
AS

BEGIN	-- grdp_set_gr_gst
	-- This module checks if a IGS_GR_GRADUAND with a 'POTENTIAL' IGS_GR_GRADUAND status is
	-- now 'ELIGIBLE'. It also checks if an 'ELIGIBLE' IGS_GR_GRADUAND is no longer
	-- eligible. It sets the status accordingly.
	retcode:=0;
      igs_ge_gen_003.set_org_id(p_org_id);
DECLARE
	cst_eligible	CONSTANT	VARCHAR2(10) := 'ELIGIBLE';
	cst_potential	CONSTANT	VARCHAR2(10) := 'POTENTIAL';
	e_resource_busy			EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
	v_graduand_status		IGS_GR_STAT.graduand_status%TYPE;
	v_s_graduand_status		IGS_GR_STAT.s_graduand_status%TYPE;
	v_message_name			VARCHAR2(30);
	v_closed_ind			IGS_GR_STAT.closed_ind%TYPE;
	CURSOR c_gst (
			cp_graduand_status	IGS_GR_STAT.graduand_status%TYPE,
			cp_s_graduand_status	IGS_GR_STAT.s_graduand_status%TYPE) IS
		SELECT	gst.closed_ind
		FROM	IGS_GR_STAT		gst
		WHERE	gst.graduand_status	= cp_graduand_status AND
			gst.s_graduand_status	= cp_s_graduand_status;

    CURSOR	 c_sp_exists(
		cp_person_id		IGS_GR_GRADUAND.person_id%TYPE,
		cp_course_cd		IGS_GR_GRADUAND.course_cd%TYPE,
		cp_award_cd             IGS_GR_GRADUAND.award_cd%TYPE)  IS
    SELECT 	'1'
    FROM	IGS_EN_SPA_AWD_AIM	spaaa
    WHERE	spaaa.person_id = cp_person_id
    AND	spaaa.course_cd = cp_course_cd
		AND     spaaa.award_cd  = cp_award_cd
    AND     spaaa.complete_ind='Y';


	CURSOR c_gr_gst IS
		SELECT	gr.rowid,
			gr.person_id,
			gr.create_dt,
			gr.grd_cal_type,
			gr.grd_ci_sequence_number,
			gr.course_cd,
			gr.award_course_cd,
			gr.award_crs_version_number,
			gr.award_cd,
			gr.graduand_status,
			gr.graduand_appr_status,
			gr.s_graduand_type,
			gr.graduation_name,
			gr.proxy_award_ind,
			gr.proxy_award_person_id,
			gr.previous_qualifications,
			gr.convocation_membership_ind,
			gr.sur_for_course_cd,
			gr.sur_for_crs_version_number,
			gr.sur_for_award_cd,
			gr.comments,
			gst.s_graduand_status,
      gr.attribute_category,
      gr.attribute1,
      gr.attribute2,
      gr.attribute3,
      gr.attribute4,
      gr.attribute5,
      gr.attribute6,
      gr.attribute7,
      gr.attribute8,
      gr.attribute9,
      gr.attribute10,
      gr.attribute11,
      gr.attribute12,
      gr.attribute13,
      gr.attribute14,
      gr.attribute15,
      gr.attribute16,
      gr.attribute17,
      gr.attribute18,
      gr.attribute19,
      gr.attribute20
		FROM	IGS_GR_GRADUAND		gr,
			IGS_GR_STAT		gst
		WHERE	gr.graduand_status	= gst.graduand_status AND
			gst.s_graduand_status IN
						('POTENTIAL',
						'ELIGIBLE')
		FOR UPDATE OF gr.graduand_status NOWAIT;

   v_approval_status       IGS_GR_APRV_STAT.graduand_appr_status%TYPE;
   lc_sp_exists            VARCHAR2(10);
BEGIN

  -- Next check has been added as per the 'Progression Completion' TD Bug# 2636792
  IF p_graduand_status IS NULL OR p_approval_status IS NULL THEN
    FND_MESSAGE.SET_NAME('IGS', 'IGS_GR_GRAD_APPR_REQ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET());
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    RETURN;
  END IF;
  -- Check paramenters
	IF p_eligible_graduand_status IS NULL OR
	  p_potential_graduand_status IS NULL THEN
    	  Fnd_Message.Set_Name('IGS', 'IGS_GE_INVALID_VALUE');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET());
          FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
	  RETURN;
	END IF;
	-- Validate the status values provided
	OPEN c_gst(
		p_eligible_graduand_status,
		cst_eligible);
	FETCH c_gst INTO v_closed_ind;
	IF c_gst%NOTFOUND THEN
	  CLOSE c_gst;
   	  Fnd_Message.Set_Name('IGS', 'IGS_GE_INVALID_VALUE');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET());
          FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
	  RETURN;
	ELSE
		CLOSE c_gst;
		IF v_closed_ind = 'Y' THEN
	   	  Fnd_Message.Set_Name('IGS', 'IGS_GR_GRAD_STATUS_CLOSED');
		  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET());
		  FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
		  RETURN;
		END IF;
	END IF;
	OPEN c_gst(
		p_potential_graduand_status,
		cst_potential);
	FETCH c_gst INTO v_closed_ind;
	IF c_gst%NOTFOUND THEN
	  CLOSE c_gst;
  	  Fnd_Message.Set_Name('IGS', 'IGS_GE_INVALID_VALUE');
	  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET());
	  FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
	  RETURN;
	ELSE
		CLOSE c_gst;
		IF v_closed_ind = 'Y' THEN
		  Fnd_Message.Set_Name('IGS', 'IGS_GR_GRAD_STATUS_CLOSED');
		  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET());
		  FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
		  RETURN;
		END IF;
	END IF;
  -- Find potential and eligible graduands
  FOR v_gr_gst_rec IN c_gr_gst LOOP
    -- Check the eligibility status
    IF IGS_GR_VAL_GR.grdp_val_aw_eligible (
        v_gr_gst_rec.person_id,
        v_gr_gst_rec.course_cd,
        v_gr_gst_rec.award_course_cd,
        v_gr_gst_rec.award_crs_version_number,
        v_gr_gst_rec.award_cd,
        v_message_name) THEN
      v_graduand_status := p_eligible_graduand_status;
      v_s_graduand_status := cst_eligible;
    ELSE
      v_graduand_status := p_potential_graduand_status;
      v_s_graduand_status := cst_potential;
    END IF;

    OPEN c_sp_exists(v_gr_gst_rec.person_id, v_gr_gst_rec.award_course_cd, v_gr_gst_rec.award_cd); --**
    FETCH c_sp_exists INTO lc_sp_exists;
      IF c_sp_exists%FOUND THEN
        v_graduand_status := p_graduand_status;
        v_approval_status := p_approval_status;
      ELSE
        v_s_graduand_status := cst_potential;
        v_approval_status := v_gr_gst_rec.graduand_appr_status;
      END IF;

      IF NVL(v_gr_gst_rec.s_graduand_status,'NULL') <> NVL(v_s_graduand_status,'NULL') OR
        (c_sp_exists%FOUND AND p_graduand_status IS NOT NULL AND p_approval_status IS NOT NULL) THEN
        DECLARE
          l_message_text fnd_new_messages.message_text%TYPE;
        BEGIN
          IGS_GR_GRADUAND_PKG.UPDATE_ROW(
            X_ROWID => v_gr_gst_rec.rowid,
            X_PERSON_ID => v_gr_gst_rec.person_id,
            X_CREATE_DT => v_gr_gst_rec.create_dt,
            X_GRD_CAL_TYPE => v_gr_gst_rec.grd_cal_type,
            X_GRD_CI_SEQUENCE_NUMBER => v_gr_gst_rec.grd_ci_sequence_number,
            X_COURSE_CD => v_gr_gst_rec.course_cd,
            X_AWARD_COURSE_CD => v_gr_gst_rec.award_course_cd,
            X_AWARD_CRS_VERSION_NUMBER => v_gr_gst_rec.award_crs_version_number,
            X_AWARD_CD => v_gr_gst_rec.award_cd,
            X_GRADUAND_STATUS => v_graduand_status,
            X_GRADUAND_APPR_STATUS => v_approval_status,
            X_S_GRADUAND_TYPE => v_gr_gst_rec.s_graduand_type,
            X_GRADUATION_NAME => v_gr_gst_rec.graduation_name,
            X_PROXY_AWARD_IND => v_gr_gst_rec.proxy_award_ind,
            X_PROXY_AWARD_PERSON_ID => v_gr_gst_rec.proxy_award_person_id,
            X_PREVIOUS_QUALIFICATIONS => v_gr_gst_rec.previous_qualifications,
            X_CONVOCATION_MEMBERSHIP_IND => v_gr_gst_rec.convocation_membership_ind,
            X_SUR_FOR_COURSE_CD => v_gr_gst_rec.sur_for_course_cd,
            X_SUR_FOR_CRS_VERSION_NUMBER => v_gr_gst_rec.sur_for_crs_version_number,
            X_SUR_FOR_AWARD_CD => v_gr_gst_rec.sur_for_award_cd,
            X_COMMENTS => v_gr_gst_rec.comments,
            X_MODE => 'R',
            X_ATTRIBUTE_CATEGORY => v_gr_gst_rec.attribute_category,
            X_ATTRIBUTE1         => v_gr_gst_rec.attribute1,
            X_ATTRIBUTE2         => v_gr_gst_rec.attribute2,
            X_ATTRIBUTE3         => v_gr_gst_rec.attribute3,
            X_ATTRIBUTE4         => v_gr_gst_rec.attribute4,
            X_ATTRIBUTE5         => v_gr_gst_rec.attribute5,
            X_ATTRIBUTE6         => v_gr_gst_rec.attribute6,
            X_ATTRIBUTE7         => v_gr_gst_rec.attribute7,
            X_ATTRIBUTE8         => v_gr_gst_rec.attribute8,
            X_ATTRIBUTE9         => v_gr_gst_rec.attribute9,
            X_ATTRIBUTE10        => v_gr_gst_rec.attribute10,
            X_ATTRIBUTE11        => v_gr_gst_rec.attribute11,
            X_ATTRIBUTE12        => v_gr_gst_rec.attribute12,
            X_ATTRIBUTE13        => v_gr_gst_rec.attribute13,
            X_ATTRIBUTE14        => v_gr_gst_rec.attribute14,
            X_ATTRIBUTE15        => v_gr_gst_rec.attribute15,
            X_ATTRIBUTE16        => v_gr_gst_rec.attribute16,
            X_ATTRIBUTE17        => v_gr_gst_rec.attribute17,
            X_ATTRIBUTE18        => v_gr_gst_rec.attribute18,
            X_ATTRIBUTE19        => v_gr_gst_rec.attribute19,
            X_ATTRIBUTE20        => v_gr_gst_rec.attribute20);
           EXCEPTION WHEN OTHERS THEN
             DECLARE
               CURSOR cur_get_person_num (cp_person_id NUMBER)IS
               SELECT person_number
               FROM igs_pe_person_base_v
               WHERE person_id = cp_person_id;
               rec_get_person_num cur_get_person_num%ROWTYPE;
               l_log VARCHAR2(4000);
             BEGIN
               OPEN cur_get_person_num(v_gr_gst_rec.person_id);
               FETCH cur_get_person_num INTO rec_get_person_num;
               CLOSE cur_get_person_num;
               l_message_text := fnd_message.get;
	             FND_MESSAGE.SET_NAME('IGS', 'IGS_GR_ERROR_OCC');
               l_log := FND_MESSAGE.GET()||' '''||rec_get_person_num.person_number||'''';
	             FND_MESSAGE.SET_NAME('IGS', 'IGS_PR_PRG');
               l_log := l_log||' '||FND_MESSAGE.GET()||': '''||v_gr_gst_rec.course_cd||' '||v_gr_gst_rec.award_crs_version_number||'''';
	             FND_MESSAGE.SET_NAME('IGS', 'IGS_PR_PROGRAM_AWARDS');
               l_log := l_log||' '||FND_MESSAGE.GET()||': '''||v_gr_gst_rec.award_cd||'''';
               FND_FILE.PUT_LINE(FND_FILE.LOG, l_log);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'  '||l_message_text);
               FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
             END;
           END;
      END IF;
    CLOSE c_sp_exists;
  END LOOP;
EXCEPTION
  WHEN e_resource_busy THEN
    IF c_gr_gst%ISOPEN THEN
      CLOSE c_gr_gst;
    END IF;
    ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_RECORD_LOCKED');
    RETCODE:=2;
  WHEN OTHERS THEN

    IF c_gst%ISOPEN THEN
      CLOSE c_gst;
    END IF;
    IF c_gr_gst%ISOPEN THEN
      CLOSE c_gr_gst;
    END IF;
    RAISE;
END;
EXCEPTION
  WHEN OTHERS THEN
    /*RETCODE:=2;
    ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    commented for exception handler related changes */

    RETCODE := 2;
    ERRBUF := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END grdp_set_gr_gst;


PROCEDURE grdp_upd_gac_order(
  errbuf  out NOCOPY  varchar2,
  retcode out NOCOPY  NUMBER,
  p_grd_perd VARCHAR2,
  p_order_by IN VARCHAR2 ,
  p_ignore_unit_sets_ind IN VARCHAR2 ,
  p_group_multi_award_ind IN VARCHAR2,
  p_mode IN VARCHAR2 ,  -- Added a new parameter as part of Order in Presentation DLD.
  p_org_id NUMBER
      )
AS
  --
  --  Change History :
  --  Who             When            What
  --  (reverse chronological order - newest change first)
  --  pradhakr     14-Sep-2002     Changes as per Order in Presentation DLD
  --
  --  Nalin Kumar  29-Oct-2002     Modified the dynamic SQL which creates the main select stetament (v_gac_upd_select)
  --                               to fetch records to update the 'Order in presantation' (removed the 'System Graduand Type'
  --                               check from the where clause. This is as per the Conferral Date TD Bug# 2640799
	--
	--  Nalin Kumar   10-DEC-2002    Modified this procedure to fix Bug# 2691809. Modified the code to log error
	--                               messages in the log file instead of raising unhandled exception.
	--
	--
	--  Nalin Kumar   18-DEC-2002    Modified this procedure to fix Bug# 2690151.
	--                               Added the code to log the parameters value in the log file.
	--
	p_grd_cal_type 			IGS_GR_CRMN_ROUND.grd_cal_type%type;
	p_grd_ci_sequence_number  	IGS_GR_CRMN_ROUND.grd_ci_sequence_number%type;
	p_ceremony_number 		IGS_GR_CRMN.ceremony_number%type;
  l_index NUMBER;
  l_app_name VARCHAR2(30) := 'IGS';
  l_msg_text varchar2(200);
	l_message_name VARCHAR2(200);

BEGIN	-- grdp_upd_gac_order
	-- Set the IGS_GR_AWD_CRMN.order_in_presentation based on the
	-- IGS_GR_AWD_CEREMONY.order_in_ceremony, IGS_GR_AWD_CRM_US_GP.order_in_award
	-- and the parameters passed.

  --Block for Parameter Validation/Splitting of Parameters
	retcode:=0;
      igs_ge_gen_003.set_org_id(p_org_id);
	BEGIN
		p_grd_cal_type 		   := RTRIM(SUBSTR(p_grd_perd, 1,10 ));
		p_grd_ci_sequence_number   := TO_NUMBER(RTRIM(SUBSTR(p_grd_perd, 11, 10)));
                --Modified the next line to fix Bug# 2691848;
		p_ceremony_number 	   := RTRIM(SUBSTR(p_grd_perd,21));
  END;
  --End of Block for Parameter Validation/Splitting of Parameters

DECLARE
	cst_eligible	CONSTANT VARCHAR2(10) := 'ELIGIBLE';
	cst_graduated	CONSTANT VARCHAR2(10) := 'GRADUATED';
	cst_approved	CONSTANT VARCHAR2(10) := 'APPROVED';
	cst_attending	CONSTANT VARCHAR2(10) := 'ATTENDING';
	cst_update_of_clause
			CONSTANT VARCHAR2(40) := 'FOR UPDATE OF gac.person_id NOWAIT';
	e_resource_busy		EXCEPTION;
	PRAGMA	EXCEPTION_INIT(e_resource_busy, -54 );
	v_order_count	        NUMBER;
	v_index		        NUMBER := 1;
	v_gac_upd_select	VARCHAR2(2000);
	v_order_by_clause	VARCHAR2(500);
	v_gac_upd_c_handle	INTEGER;
	v_gac_upd_c_exe_result	INTEGER;
	-- Record declaration for Dynamic SQL
	TYPE gac_upd_rectype IS RECORD (
		person_id			IGS_GR_AWD_CRMN.person_id%TYPE,
		create_dt			IGS_GR_AWD_CRMN.create_dt%TYPE,
		award_course_cd			IGS_GR_AWD_CRMN.award_course_cd%TYPE,
		award_crs_version_number
					IGS_GR_AWD_CRMN.award_crs_version_number%TYPE,
		award_cd			IGS_GR_AWD_CRMN.award_cd%TYPE,
		grd_cal_type			IGS_GR_AWD_CRMN.grd_cal_type%TYPE,
		grd_ci_sequence_number		IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE,
		ceremony_number			IGS_GR_AWD_CRMN.ceremony_number%TYPE);
	v_gac_upd_rec	gac_upd_rectype;
	CURSOR	c_gc IS
		SELECT	gc.ceremony_number
		FROM	IGS_GR_CRMN	gc
		WHERE	gc.grd_cal_type			= p_grd_cal_type AND
			gc.grd_ci_sequence_number	= p_grd_ci_sequence_number AND
			gc.ceremony_number 		LIKE p_ceremony_number;
	CURSOR c_awc (
		cp_ceremony_number	IGS_GR_CRMN.ceremony_number%TYPE) IS
		SELECT	/*+ INDEX(awc awc_uk*/
			'X'
		FROM	IGS_GR_AWD_CEREMONY		awc
		WHERE	awc.grd_cal_type		= p_grd_cal_type AND
			awc.grd_ci_sequence_number	= p_grd_ci_sequence_number AND
			awc.ceremony_number		= cp_ceremony_number AND
			awc.closed_ind			= 'Y' AND
			EXISTS	(SELECT	'X'
				FROM	IGS_GR_AWD_CRMN	gac
				WHERE	gac.grd_cal_type		= awc.grd_cal_type AND
					gac.grd_ci_sequence_number	= awc.grd_ci_sequence_number AND
					gac.ceremony_number		= awc.ceremony_number AND
					((gac.award_course_cd 		IS NULL AND
					awc.award_course_cd		IS NULL) OR
					gac.award_course_cd		= awc.award_course_cd) AND
					((gac.award_crs_version_number 	IS NULL AND
					awc.award_crs_version_number	IS NULL) OR
					awc.award_crs_version_number	= gac.award_crs_version_number) AND
					awc.award_cd			= gac.award_cd);
	v_awc_exists	VARCHAR2(1);

	CURSOR	c_acusg (
		cp_ceremony_number	IGS_GR_CRMN.ceremony_number%TYPE) IS
		SELECT	/*+ INDEX(acusg acusg_pk)*/
			'X'
		FROM	IGS_GR_AWD_CRM_US_GP		acusg
		WHERE	acusg.grd_cal_type		= p_grd_cal_type AND
			acusg.grd_ci_sequence_number	= p_grd_ci_sequence_number AND
			acusg.ceremony_number		= cp_ceremony_number AND
			acusg.closed_ind		= 'Y' AND
			EXISTS
			(SELECT	'X'
			FROM	IGS_GR_AWD_CRMN		gac
			WHERE	gac.grd_cal_type		= acusg.grd_cal_type AND
				gac.grd_ci_sequence_number	= acusg.grd_ci_sequence_number AND
				gac.ceremony_number		= acusg.ceremony_number AND
				gac.award_course_cd		= acusg.award_course_cd AND
				gac.award_crs_version_number	= acusg.award_crs_version_number AND
				gac.award_cd			= acusg.award_cd AND
				gac.us_group_number		= acusg.us_group_number);
	v_acusg_exists	VARCHAR2(1);
	CURSOR	c_gac_del(
		cp_ceremony_number	IGS_GR_CRMN.ceremony_number%TYPE) IS
		SELECT	rowid, gac.*
		FROM	IGS_GR_AWD_CRMN		gac
		WHERE	gac.grd_cal_type		= p_grd_cal_type AND
			gac.grd_ci_sequence_number	= p_grd_ci_sequence_number AND
			gac.ceremony_number		= cp_ceremony_number
		FOR UPDATE OF gac.order_in_presentation NOWAIT;
	CURSOR	c_existing_order(
		cp_ceremony_number	IGS_GR_CRMN.ceremony_number%TYPE,
		cp_person_id		IGS_GR_AWD_CRMN.person_id%TYPE,
		cp_create_dt		IGS_GR_AWD_CRMN.create_dt%TYPE,
		cp_award_course_cd	IGS_GR_AWD_CRMN.award_course_cd%TYPE,
		cp_award_crs_version_number
					IGS_GR_AWD_CRMN.award_crs_version_number%TYPE,
		cp_award_cd		IGS_GR_AWD_CRMN.award_cd%TYPE) IS
		SELECT	gac.order_in_presentation
		FROM	IGS_GR_AWD_CRMN	gac
		WHERE	gac.person_id			= cp_person_id AND
			gac.grd_cal_type		= p_grd_cal_type AND
			gac.grd_ci_sequence_number	= p_grd_ci_sequence_number AND
			gac.ceremony_number		= cp_ceremony_number AND
			(((gac.award_course_cd		IS NULL AND
			cp_award_course_cd		IS NULL) OR
			gac.award_course_cd		<> cp_award_course_cd) OR
			((gac.award_crs_version_number 	IS NULL AND
			cp_award_crs_version_number	IS NULL) OR
			cp_award_crs_version_number	<> gac.award_crs_version_number) OR
			gac.award_cd 			<> cp_award_cd) AND
			gac.order_in_presentation	IS NOT NULL;

	-- Cursor to get the maximum number of the 'Order in Presentation' for a given ceremony
	-- Added as part of Order in Presentation DLD Bug# 2578638
	-- pradhakr; 14-Sep-2002;

	CURSOR c_max_ord_num IS
		SELECT max(order_in_presentation)
		FROM  igs_gr_awd_crmn
		WHERE grd_cal_type = p_grd_cal_type
		AND   grd_ci_sequence_number = p_grd_ci_sequence_number
		AND   ceremony_number = p_ceremony_number;

	v_existing_order	IGS_GR_AWD_CRMN.order_in_presentation%TYPE;
BEGIN
	--
	--Log the Parameters value in the log file. This is to fix Bug# 2690151
	--
	FND_MESSAGE.SET_NAME('IGS', 'IGS_FI_ANC_LOG_PARM');
	FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET()||':');
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_grd_cal_type = '||p_grd_cal_type);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_grd_ci_sequence_number = '||p_grd_ci_sequence_number);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_ceremony_number = '||p_ceremony_number);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_order_by  = '||p_order_by);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_ignore_unit_sets_ind = '||p_ignore_unit_sets_ind);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_group_multi_award_ind  = '||p_group_multi_award_ind);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_mode  = '||p_mode);

	--1. Check parameters :
	IF p_grd_cal_type IS NULL OR
			p_grd_ci_sequence_number IS NULL OR
			p_ceremony_number IS NULL OR
			p_order_by IS NULL OR
			p_ignore_unit_sets_ind IS NULL OR
			p_group_multi_award_ind IS NULL THEN
    			Fnd_Message.Set_Name('IGS', 'IGS_GE_INSUFFICIENT_PARAMETER');
		    	--App_Exception.Raise_Exception;
				  FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2691809
          RETURN;
	END IF;
	--2.	Loop through all of the IGS_GR_CRMN records
	--	which match the specifed parameters.
	FOR v_gc_rec IN c_gc LOOP
		--3.	Check if the IGS_GR_CRMN has any related IGS_GR_AWD_CRMN
		--	records linked to closed IGS_GR_AWD_CEREMONY records.
		OPEN c_awc(v_gc_rec.ceremony_number);
		FETCH c_awc INTO v_awc_exists;
		IF c_awc%FOUND THEN
			--4. If any records are found raise an error.
			CLOSE c_awc;
    			Fnd_Message.Set_Name('IGS', 'IGS_GR_AWD_CERM_REC_CLOSED');
		    	--App_Exception.Raise_Exception;
				  FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get); --Added as per bug# 2691809
          RETURN;
		END IF;
		CLOSE c_awc;
		--5. Check if the IGS_GR_CRMN has any related graduand_award_cermony
		--	records linked to closed IGS_GR_AWD_CRM_US_GP records.
		OPEN c_acusg(
			v_gc_rec.ceremony_number);
		FETCH c_acusg INTO v_acusg_exists;
		IF c_acusg%FOUND THEN
			--6. If any records are found raise an error.
			CLOSE c_acusg;
   				Fnd_Message.Set_Name('IGS', 'IGS_GR_AWD_CERM_UNIT_SET_CLOS');
	    		--App_Exception.Raise_Exception;
				  FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2691809
          RETURN;
		END IF;
		CLOSE c_acusg;
		--7. Clear the order_in_presentation for all of the IGS_GR_AWD_CRMN
		--   records related to this IGS_GR_CRMN.

		-- If the concurrent process is executed in 'Reallocate' mode then update
		-- all the order in presentation column to NULL. This will allows to
		-- assign a fresh order for the graduants who satify the given criteria.
		-- Added the IF condition as part of order in Presentation DLD.
		-- pradhakr; 14-Sep-2002; Bug# 2578638

		IF p_mode = 'R' THEN

  		   BEGIN -- local block to trap exception
			SAVEPOINT sp_gac_del;

			FOR v_gac_del_rec IN c_gac_del(
							v_gc_rec.ceremony_number) LOOP

				IGS_GR_AWD_CRMN_PKG.UPDATE_ROW(
				  X_ROWID =>v_gac_del_rec.rowid,
				  X_GAC_ID =>v_gac_del_rec.GAC_ID,
				  X_GRADUAND_SEAT_NUMBER =>v_gac_del_rec.graduand_seat_number,
				  X_NAME_PRONUNCIATION =>v_gac_del_rec.name_pronunciation,
				  X_NAME_ANNOUNCED =>v_gac_del_rec.name_announced,
				  X_ACADEMIC_DRESS_RQRD_IND =>v_gac_del_rec.academic_dress_rqrd_ind,
				  X_ACADEMIC_GOWN_SIZE =>v_gac_del_rec.academic_gown_size,
				  X_ACADEMIC_HAT_SIZE =>v_gac_del_rec.academic_hat_size,
				  X_GUEST_TICKETS_REQUESTED =>v_gac_del_rec.guest_tickets_requested,
				  X_GUEST_TICKETS_ALLOCATED =>v_gac_del_rec.guest_tickets_allocated,
				  X_GUEST_SEATS =>v_gac_del_rec.guest_seats,
				  X_FEES_PAID_IND =>v_gac_del_rec.fees_paid_ind,
				  X_SPECIAL_REQUIREMENTS =>v_gac_del_rec.special_requirements,
				  X_COMMENTS =>v_gac_del_rec.COMMENTS,
				  X_PERSON_ID =>v_gac_del_rec.person_id,
				  X_CREATE_DT =>v_gac_del_rec.create_dt,
				  X_GRD_CAL_TYPE =>v_gac_del_rec.grd_cal_type,
				  X_GRD_CI_SEQUENCE_NUMBER =>v_gac_del_rec.grd_ci_sequence_number,
				  X_CEREMONY_NUMBER =>v_gac_del_rec.ceremony_number,
				  X_AWARD_COURSE_CD =>v_gac_del_rec.award_course_cd,
				  X_AWARD_CRS_VERSION_NUMBER =>v_gac_del_rec.award_crs_version_number,
				  X_AWARD_CD =>v_gac_del_rec.award_cd,
				  X_US_GROUP_NUMBER =>v_gac_del_rec.us_group_number,
				  X_ORDER_IN_PRESENTATION => NULL,
				  X_MODE => 'R');

			END LOOP; -- c_gac_del
			COMMIT;
		   EXCEPTION
			WHEN e_resource_busy THEN
				-- Error 4713 for locking conflict exception and ROLLBACK.
				IF c_gac_del%ISOPEN THEN
					CLOSE c_gac_del;
				END IF;
				ROLLBACK TO sp_gac_del;
    				Fnd_Message.Set_Name('IGS', 'IGS_GR_AWD_CERM_CANNOT_UPDATE');
		    		--App_Exception.Raise_Exception;
            FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2691809
      WHEN OTHERS THEN
        ROLLBACK TO sp_gac_del;
        l_msg_text := fnd_message.get;
        IGS_GE_MSG_STACK.GET(1,'T',l_msg_text,  l_index );
        FND_MESSAGE.PARSE_ENCODED (l_msg_text, l_app_name, l_message_name);
        IF l_message_name IN ('IGS_GR_INVALID_PROC_PERIOD','IGS_GR_INV_DT_GRAD_CERM', 'IGS_GR_CLOSING_DT_REACHED') THEN
          Fnd_Message.Set_Name('IGS', l_message_name);
          FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2691809
          RETURN;
        END IF;
        RAISE;
       END;
    END IF;
    -- Main Select contents for dynamic SQL construction.

    v_gac_upd_select :=
      'SELECT '                       ||
        'gac.person_id, '             ||
        'gac.create_dt, '             ||
        'gac.award_course_cd, '       ||
        'gac.award_crs_version_number, '||
        'gac.award_cd, '              ||
        'gac.grd_cal_type, '          ||
        'gac.grd_ci_sequence_number, '||
        'gac.ceremony_number '        ||
      'FROM IGS_GR_AWD_CRMN gac, '    ||
        'IGS_GR_GRADUAND gr, '        ||
        'IGS_GR_STAT gst, '           ||
        'IGS_PE_PERSON  pe, '         ||
        'IGS_GR_AWD_CEREMONY  awc, '  ||
        'IGS_GR_AWD_CRM_US_GP acusg, '||
        'IGS_GR_APRV_STAT gas '       ||
      'WHERE  gac.grd_cal_type='''    || p_grd_cal_type || ''' AND '    ||
        'gac.grd_ci_sequence_number=' || TO_CHAR(p_grd_ci_sequence_number) || ' AND '||
        'gac.ceremony_number='        || TO_CHAR(v_gc_rec.ceremony_number) || ' AND '||
        'gac.person_id=gr.person_id AND '         ||
        'gac.create_dt=gr.create_dt AND '         ||
        'gac.person_id=pe.person_id AND '         ||
        'gr.graduand_status=gst.graduand_status AND '       ||
        '(gst.s_graduand_status='''   || cst_eligible  || ''' OR '      ||
        'gst.s_graduand_status='''    || cst_graduated || ''') AND '    ||
        'gr.graduand_appr_status=gas.graduand_appr_status AND '         ||
        'gas.s_graduand_appr_status=''' || cst_approved  || ''' AND '   ||
        'gr.s_graduand_type = ''' || cst_attending  || ''' AND '   ||       /* Added to fix Bug# 3294453 */
        'gac.grd_cal_type=awc.grd_cal_type AND '         ||
        'gac.grd_ci_sequence_number=awc.grd_ci_sequence_number AND '    ||
        'gac.ceremony_number=awc.ceremony_number AND ' ||
        '((gac.award_course_cd IS NULL AND '           ||
        'awc.award_course_cd IS NULL) OR '             ||
        'gac.award_course_cd=awc.award_course_cd) AND '||
        '((gac.award_crs_version_number IS NULL AND '  ||
        'awc.award_crs_version_number IS NULL) OR '    ||
        'awc.award_crs_version_number=gac.award_crs_version_number) AND ' ||
        'gac.award_cd=awc.award_cd AND '               ||
        'gac.grd_cal_type=acusg.grd_cal_type(+) AND '  ||
        'gac.grd_ci_sequence_number=acusg.grd_ci_sequence_number(+) AND ' ||
        'gac.ceremony_number=acusg.ceremony_number(+) AND '     ||
        'gac.award_course_cd=acusg.award_course_cd(+) AND '     ||
        'gac.award_crs_version_number=acusg.award_crs_version_number(+) AND ' ||
        'gac.award_cd=acusg.award_cd(+) AND '         ||
        'gac.us_group_number=acusg.us_group_number(+) ';


		-- If job is running in 'Allocate' Mode then - select the Graduands
		-- who has 'Order in Presentation' as NULL.
		-- pradhakr; 15-Sep-2002; Bug# 2578638

		IF p_mode = 'A' THEN
		  v_gac_upd_select := v_gac_upd_select || 'AND gac.order_in_presentation IS  NULL ' || 'ORDER BY ';
		ELSE
		  v_gac_upd_select := v_gac_upd_select || 'ORDER BY ';
		END IF;

		--7.1 Construct the order by clause for the select statement:
		v_order_by_clause := 'awc.order_in_ceremony ASC';
		IF p_ignore_unit_sets_ind = 'N' THEN
			v_order_by_clause := v_order_by_clause || ', acusg.order_in_award ASC';
		END IF;

    --The Honours Level has been obsoleted so directly set the ORDER BY on the 'SURNAME' and 'GIVEN NAME'
    --Program Completion Validation Build.
   	v_order_by_clause := v_order_by_clause || ', pe.surname ASC, pe.given_names ASC';

		-- Open Dynamic Cursor, pass reference to v_cursor_handle.
		v_gac_upd_c_handle := DBMS_SQL.OPEN_CURSOR;
		-- Parse the complete SQL statement.
		DBMS_SQL.PARSE (
			v_gac_upd_c_handle,
			v_gac_upd_select || ' ' || v_order_by_clause || ' ' || cst_update_of_clause,
			DBMS_SQL.NATIVE);
		-- Define the columns in the dynamic SQL query.
		DBMS_SQL.DEFINE_COLUMN(v_gac_upd_c_handle,  1, v_gac_upd_rec.person_id);
		DBMS_SQL.DEFINE_COLUMN(v_gac_upd_c_handle,  2, v_gac_upd_rec.create_dt);
		DBMS_SQL.DEFINE_COLUMN(v_gac_upd_c_handle,  3,
						v_gac_upd_rec.award_course_cd, 6);
		DBMS_SQL.DEFINE_COLUMN(v_gac_upd_c_handle,  4,
						v_gac_upd_rec.award_crs_version_number);
		DBMS_SQL.DEFINE_COLUMN(v_gac_upd_c_handle,  5, v_gac_upd_rec.award_cd, 10);
		DBMS_SQL.DEFINE_COLUMN(v_gac_upd_c_handle,  6,
						v_gac_upd_rec.grd_cal_type, 10);
		DBMS_SQL.DEFINE_COLUMN(v_gac_upd_c_handle,  7,
						v_gac_upd_rec.grd_ci_sequence_number);
		DBMS_SQL.DEFINE_COLUMN(v_gac_upd_c_handle,  8, v_gac_upd_rec.ceremony_number);

		-- Now execute the dynamic cursor.
		v_gac_upd_c_exe_result := DBMS_SQL.EXECUTE(
							v_gac_upd_c_handle);


               -- Check if the 'Append' Mode then get the maximum number of the 'Order in Presentation'
               -- in a variable else just assign '1' to that variable (v_order_count).
  	       -- pradhakr; 15-Sep-2002
               IF p_mode = 'A' THEN
                 OPEN c_max_ord_num;
                 FETCH c_max_ord_num INTO v_order_count;
                 v_order_count := NVL(v_order_count, 0) + 1;
                 CLOSE c_max_ord_num;
               ELSE
                 v_order_count := 1;
               END IF;

		--8. Find all of the IGS_GR_AWD_CRMN records for
		--	this IGS_GR_CRMN.
		--9. Loop through the IGS_GR_AWD_CRMN records setting the
		--	order_in_presentation.
		LOOP	-- Dynamic Cursor associated with handle 'v_gac_upd_c_handle'
			Exit WHEN DBMS_SQL.FETCH_ROWS(v_gac_upd_c_handle) = 0;
			-- Retrieve the data associated with the Dynamic SQL cursor
			--  v_gac_upd_c_handle
			DBMS_SQL.COLUMN_VALUE(v_gac_upd_c_handle,  1, v_gac_upd_rec.person_id);
			DBMS_SQL.COLUMN_VALUE(v_gac_upd_c_handle,  2, v_gac_upd_rec.create_dt);
			DBMS_SQL.COLUMN_VALUE(v_gac_upd_c_handle,  3, v_gac_upd_rec.award_course_cd);
			DBMS_SQL.COLUMN_VALUE(v_gac_upd_c_handle,  4,
							v_gac_upd_rec.award_crs_version_number);
			DBMS_SQL.COLUMN_VALUE(v_gac_upd_c_handle,  5, v_gac_upd_rec.award_cd);
			DBMS_SQL.COLUMN_VALUE(v_gac_upd_c_handle, 6, v_gac_upd_rec.grd_cal_type);
			DBMS_SQL.COLUMN_VALUE(v_gac_upd_c_handle, 7,
							v_gac_upd_rec.grd_ci_sequence_number);
			DBMS_SQL.COLUMN_VALUE(v_gac_upd_c_handle, 8, v_gac_upd_rec.ceremony_number);

			BEGIN -- local block for update error trapping
				SAVEPOINT sp_gac_upd;
				IF p_group_multi_award_ind = 'Y' THEN
					OPEN c_existing_order(
							v_gc_rec.ceremony_number,
							v_gac_upd_rec.person_id,
							v_gac_upd_rec.create_dt,
							v_gac_upd_rec.award_course_cd,
							v_gac_upd_rec.award_crs_version_number,
							v_gac_upd_rec.award_cd);
					FETCH c_existing_order INTO v_existing_order;
					IF c_existing_order%FOUND THEN
						CLOSE c_existing_order;
						DECLARE
							CURSOR cur_gac IS
								SELECT rowid, gac.*
								FROM IGS_GR_AWD_CRMN gac
								WHERE   person_id = v_gac_upd_rec.person_id    AND
									create_dt = v_gac_upd_rec.create_dt    AND
									NVL(award_course_cd, 'NULL' )
										= NVL(v_gac_upd_rec.award_course_cd, 'NULL') AND
									NVL(award_crs_version_number, 0 )
										= NVL(v_gac_upd_rec.award_crs_version_number, 0 ) AND
									award_cd = v_gac_upd_rec.award_cd       AND
									grd_cal_type = v_gac_upd_rec.grd_cal_type   AND
									grd_ci_sequence_number = v_gac_upd_rec.grd_ci_sequence_number AND
									ceremony_number = v_gac_upd_rec.ceremony_number;
						BEGIN
							for gac_rec in cur_gac loop
							  BEGIN
								gac_rec.order_in_presentation := v_existing_order;
							        IGS_GR_AWD_CRMN_PKG.UPDATE_ROW(
							          X_ROWID =>gac_rec.rowid,
							          X_GAC_ID =>gac_rec.GAC_ID,
							          X_GRADUAND_SEAT_NUMBER =>gac_rec.graduand_seat_number,
							          X_NAME_PRONUNCIATION =>gac_rec.name_pronunciation,
							          X_NAME_ANNOUNCED =>gac_rec.name_announced,
							          X_ACADEMIC_DRESS_RQRD_IND =>gac_rec.academic_dress_rqrd_ind,
							          X_ACADEMIC_GOWN_SIZE =>gac_rec.academic_gown_size,
							          X_ACADEMIC_HAT_SIZE =>gac_rec.academic_hat_size,
							          X_GUEST_TICKETS_REQUESTED =>gac_rec.guest_tickets_requested,
							          X_GUEST_TICKETS_ALLOCATED =>gac_rec.guest_tickets_allocated,
							          X_GUEST_SEATS =>gac_rec.guest_seats,
							          X_FEES_PAID_IND =>gac_rec.fees_paid_ind,
							          X_SPECIAL_REQUIREMENTS =>gac_rec.special_requirements,
							          X_COMMENTS =>gac_rec.COMMENTS,
							          X_PERSON_ID =>gac_rec.person_id,
							          X_CREATE_DT =>gac_rec.create_dt,
							          X_GRD_CAL_TYPE =>gac_rec.grd_cal_type,
							          X_GRD_CI_SEQUENCE_NUMBER =>gac_rec.grd_ci_sequence_number,
							          X_CEREMONY_NUMBER =>gac_rec.ceremony_number,
							          X_AWARD_COURSE_CD =>gac_rec.award_course_cd,
							          X_AWARD_CRS_VERSION_NUMBER =>gac_rec.award_crs_version_number,
							          X_AWARD_CD =>gac_rec.award_cd,
							          X_US_GROUP_NUMBER =>gac_rec.us_group_number,
							          X_ORDER_IN_PRESENTATION => gac_rec.order_in_presentation,
							          X_MODE => 'R');
							  EXCEPTION
							    WHEN OTHERS THEN
			  				      l_msg_text := fnd_message.get;
 							      igs_ge_msg_stack.get(1,'T',l_msg_text,  l_index );
				 		              fnd_message.parse_encoded (l_msg_text, l_app_name, l_message_name);
							      IF l_message_name IN ('IGS_GR_INVALID_PROC_PERIOD','IGS_GR_INV_DT_GRAD_CERM', 'IGS_GR_CLOSING_DT_REACHED') THEN
							       	Fnd_Message.Set_Name('IGS', l_message_name);
			 				        FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);
								RETURN;
							      END IF;
						          END;
							end loop;
						END;
					ELSE
						CLOSE c_existing_order;
						DECLARE
							CURSOR cur_gac IS
								SELECT rowid, gac.*
								FROM IGS_GR_AWD_CRMN gac
								WHERE	person_id = v_gac_upd_rec.person_id    AND
									create_dt = v_gac_upd_rec.create_dt    AND
									NVL(award_course_cd, 'NULL' )
										= NVL(v_gac_upd_rec.award_course_cd, 'NULL') AND
									NVL(award_crs_version_number, 0 )
										= NVL(v_gac_upd_rec.award_crs_version_number, 0 ) AND
									award_cd = v_gac_upd_rec.award_cd       AND
									grd_cal_type = v_gac_upd_rec.grd_cal_type   AND
									grd_ci_sequence_number = v_gac_upd_rec.grd_ci_sequence_number AND
									ceremony_number = v_gac_upd_rec.ceremony_number;
						BEGIN
							for gac_rec in cur_gac loop
							BEGIN
								gac_rec.order_in_presentation := v_order_count;
							        IGS_GR_AWD_CRMN_PKG.UPDATE_ROW(
							          X_ROWID =>gac_rec.rowid,
							          X_GAC_ID =>gac_rec.GAC_ID,
							          X_GRADUAND_SEAT_NUMBER =>gac_rec.graduand_seat_number,
							          X_NAME_PRONUNCIATION =>gac_rec.name_pronunciation,
							          X_NAME_ANNOUNCED =>gac_rec.name_announced,
							          X_ACADEMIC_DRESS_RQRD_IND =>gac_rec.academic_dress_rqrd_ind,
							          X_ACADEMIC_GOWN_SIZE =>gac_rec.academic_gown_size,
							          X_ACADEMIC_HAT_SIZE =>gac_rec.academic_hat_size,
							          X_GUEST_TICKETS_REQUESTED =>gac_rec.guest_tickets_requested,
							          X_GUEST_TICKETS_ALLOCATED =>gac_rec.guest_tickets_allocated,
							          X_GUEST_SEATS =>gac_rec.guest_seats,
							          X_FEES_PAID_IND =>gac_rec.fees_paid_ind,
							          X_SPECIAL_REQUIREMENTS =>gac_rec.special_requirements,
							          X_COMMENTS =>gac_rec.COMMENTS,
							          X_PERSON_ID =>gac_rec.person_id,
							          X_CREATE_DT =>gac_rec.create_dt,
							          X_GRD_CAL_TYPE =>gac_rec.grd_cal_type,
							          X_GRD_CI_SEQUENCE_NUMBER =>gac_rec.grd_ci_sequence_number,
							          X_CEREMONY_NUMBER =>gac_rec.ceremony_number,
							          X_AWARD_COURSE_CD =>gac_rec.award_course_cd,
							          X_AWARD_CRS_VERSION_NUMBER =>gac_rec.award_crs_version_number,
							          X_AWARD_CD =>gac_rec.award_cd,
							          X_US_GROUP_NUMBER =>gac_rec.us_group_number,
							          X_ORDER_IN_PRESENTATION => gac_rec.order_in_presentation,
							          X_MODE => 'R');

							  EXCEPTION
							    WHEN OTHERS THEN
			  				      l_msg_text := fnd_message.get;
 							      igs_ge_msg_stack.get(1,'T',l_msg_text,  l_index );
				 		              fnd_message.parse_encoded (l_msg_text, l_app_name, l_message_name);
							      IF l_message_name IN ('IGS_GR_INVALID_PROC_PERIOD','IGS_GR_INV_DT_GRAD_CERM', 'IGS_GR_CLOSING_DT_REACHED') THEN
							       	Fnd_Message.Set_Name('IGS', l_message_name);
			 				        FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);
				                                RETURN;
							      END IF;
						          END;
						    END LOOP;
						END;
    						v_order_count := v_order_count + 1;
					END IF;
				ELSE
					DECLARE
						CURSOR cur_gac IS
							SELECT rowid, gac.*
							FROM IGS_GR_AWD_CRMN gac
										WHERE	person_id = v_gac_upd_rec.person_id    AND
											create_dt = v_gac_upd_rec.create_dt    AND
											NVL(award_course_cd, 'NULL' )
												= NVL(v_gac_upd_rec.award_course_cd, 'NULL') AND
											NVL(award_crs_version_number, 0 )
												= NVL(v_gac_upd_rec.award_crs_version_number, 0 ) AND
											award_cd = v_gac_upd_rec.award_cd       AND
											grd_cal_type = v_gac_upd_rec.grd_cal_type   AND
											grd_ci_sequence_number = v_gac_upd_rec.grd_ci_sequence_number AND
											ceremony_number = v_gac_upd_rec.ceremony_number;

					BEGIN
						for gac_rec in cur_gac loop
							gac_rec.order_in_presentation := v_order_count;
							IGS_GR_AWD_CRMN_PKG.UPDATE_ROW(
							  X_ROWID =>gac_rec.rowid,
							  X_GAC_ID =>gac_rec.GAC_ID,
							  X_GRADUAND_SEAT_NUMBER =>gac_rec.graduand_seat_number,
							  X_NAME_PRONUNCIATION =>gac_rec.name_pronunciation,
							  X_NAME_ANNOUNCED =>gac_rec.name_announced,
							  X_ACADEMIC_DRESS_RQRD_IND =>gac_rec.academic_dress_rqrd_ind,
							  X_ACADEMIC_GOWN_SIZE =>gac_rec.academic_gown_size,
							  X_ACADEMIC_HAT_SIZE =>gac_rec.academic_hat_size,
							  X_GUEST_TICKETS_REQUESTED =>gac_rec.guest_tickets_requested,
							  X_GUEST_TICKETS_ALLOCATED =>gac_rec.guest_tickets_allocated,
							  X_GUEST_SEATS =>gac_rec.guest_seats,
							  X_FEES_PAID_IND =>gac_rec.fees_paid_ind,
							  X_SPECIAL_REQUIREMENTS =>gac_rec.special_requirements,
							  X_COMMENTS =>gac_rec.COMMENTS,
							  X_PERSON_ID =>gac_rec.person_id,
							  X_CREATE_DT =>gac_rec.create_dt,
							  X_GRD_CAL_TYPE =>gac_rec.grd_cal_type,
							  X_GRD_CI_SEQUENCE_NUMBER =>gac_rec.grd_ci_sequence_number,
							  X_CEREMONY_NUMBER =>gac_rec.ceremony_number,
							  X_AWARD_COURSE_CD =>gac_rec.award_course_cd,
							  X_AWARD_CRS_VERSION_NUMBER =>gac_rec.award_crs_version_number,
							  X_AWARD_CD =>gac_rec.award_cd,
							  X_US_GROUP_NUMBER =>gac_rec.us_group_number,
							  X_ORDER_IN_PRESENTATION => gac_rec.order_in_presentation,
							  X_MODE => 'R');
						end loop;
					END;
					v_order_count := v_order_count + 1;
				END IF; -- p_group_multi_award_ind
			EXCEPTION
				WHEN e_resource_busy THEN
					-- Error 4713 for locking conflict exception and ROLLBACK.
					IF c_existing_order%ISOPEN THEN
						CLOSE c_existing_order;
					END IF;
		               		DBMS_SQL.CLOSE_CURSOR(v_gac_upd_c_handle);
					ROLLBACK TO sp_gac_upd;
    			  FND_MESSAGE.SET_NAME('IGS', 'IGS_GR_AWD_CERM_CANNOT_UPDATE');
		    	  --App_Exception.Raise_Exception;
				    FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);  --Added as per bug# 2691809
            RETURN;
				WHEN OTHERS THEN
					ROLLBACK TO sp_gac_upd;
					RAISE;
			END;
		END LOOP; -- Dynamic Cursor associated with handle 'v_gac_upd_c_handle'
		DBMS_SQL.CLOSE_CURSOR(v_gac_upd_c_handle);
        COMMIT;
	END LOOP; -- c_gc
	--10. Return no error:
	RETURN;
EXCEPTION
	WHEN OTHERS THEN
		IF c_gc%ISOPEN THEN
			CLOSE c_gc;
		END IF;
		IF c_awc%ISOPEN THEN
			CLOSE c_awc;
		END IF;
		IF c_acusg%ISOPEN THEN
			CLOSE c_acusg;
		END IF;
		IF c_gac_del%ISOPEN THEN
			CLOSE c_gac_del;
		END IF;
		IF DBMS_SQL.IS_OPEN(v_gac_upd_c_handle) THEN
			DBMS_SQL.CLOSE_CURSOR(v_gac_upd_c_handle);
		END IF;
		IF c_existing_order%ISOPEN THEN
			CLOSE c_existing_order;
		END IF;
		ROLLBACK;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
		/*RETCODE:=2;
		ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		commented for exception handler related changes */

		RETCODE := 2;
		ERRBUF := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

END grdp_upd_gac_order;

END IGS_GR_GEN_002 ;

/
