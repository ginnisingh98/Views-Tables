--------------------------------------------------------
--  DDL for Package Body IGS_RE_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_GEN_003" AS
/* $Header: IGSRE03B.pls 120.0 2005/06/01 21:35:49 appldev noship $ */
-- modified procedures resp_ins_tex_tri and resp_ins_tpm_tri to
--add 3 new fields in the tbh calls to IGS_TR_ITEM and IGS_TR_STEP
-- for tracking dld nov 2001 release bug#1837257

  PROCEDURE RESP_INS_MIL_HIST(
    p_person_id IN NUMBER ,
    p_ca_sequence_number IN NUMBER ,
    p_sequence_number IN NUMBER ,
    p_old_milestone_type IN VARCHAR2 ,
    p_new_milestone_type IN VARCHAR2 ,
    p_old_milestone_status IN VARCHAR2 ,
    p_new_milestone_status IN VARCHAR2 ,
    p_old_due_dt IN DATE ,
    p_new_due_dt IN DATE ,
    p_old_description IN VARCHAR2 ,
    p_new_description IN VARCHAR2 ,
    p_old_actual_reached_dt IN DATE ,
    p_new_actual_reached_dt IN DATE ,
    p_old_preced_sequence_number IN NUMBER ,
    p_new_preced_sequence_number IN NUMBER ,
    p_old_ovrd_ntfctn_immnnt_days IN NUMBER ,
    p_new_ovrd_ntfctn_immnnt_days IN NUMBER ,
    p_old_ovrd_ntfctn_rmndr_days IN NUMBER ,
    p_new_ovrd_ntfctn_rmndr_days IN NUMBER ,
    p_old_re_reminder_days IN NUMBER ,
    p_new_re_reminder_days IN NUMBER ,
    p_old_comments IN VARCHAR2 ,
    p_new_comments IN VARCHAR2 ,
    p_old_update_who IN NUMBER ,
    p_new_update_who IN NUMBER ,
    p_old_update_on IN DATE ,
    p_new_update_on IN DATE )
  AS
    gv_other_detail		VARCHAR2(255);
    lv_rowid			VARCHAR2(25);
    v_org_id IGS_PR_MILESTONE_HST.ORG_ID%TYPE := IGS_GE_GEN_003.Get_Org_Id;

  BEGIN	-- resp_ins_mil_hist
    -- Insert IGS_PR_MILESTONE history(IGS_PR_MILESTONE_HST)
    DECLARE
      v_mil_rec		IGS_PR_MILESTONE_HST%ROWTYPE;
      v_create_history	BOOLEAN := FALSE;
    BEGIN
      -- If any of the old values (p_old_<column_name>) are
      -- different from the associated new values (p_new_<column_name>)
      -- (with the exception of the last_update_date and last_updated_by columns)
      -- then create a IGS_PR_MILESTONE_HST history record with the old values
      -- (p_old_<column_name>).  Do not set the last_updated_by and last_update_date
      -- columns when creating the history record.
      IF p_new_milestone_type <> p_old_milestone_type THEN
 	v_mil_rec.milestone_type := p_old_milestone_type;
	v_create_history := TRUE;
      END IF;
      IF p_new_milestone_status <> p_old_milestone_status THEN
	v_mil_rec.milestone_status := p_old_milestone_status;
	v_create_history := TRUE;
      END IF;
      IF p_new_due_dt <> p_old_due_dt THEN
	v_mil_rec.due_dt := p_old_due_dt;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_description,'NULL') <> NVL(p_old_description,'NULL') THEN
	v_mil_rec.description := p_old_description;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_actual_reached_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) <>
 	NVL(p_old_actual_reached_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
	v_mil_rec.actual_reached_dt := p_old_actual_reached_dt;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_preced_sequence_number,0) <>
	NVL(p_old_preced_sequence_number,0) THEN
	v_mil_rec.preced_sequence_number := p_old_preced_sequence_number;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_ovrd_ntfctn_immnnt_days,0) <>
	NVL(p_old_ovrd_ntfctn_immnnt_days,0) THEN
	v_mil_rec.ovrd_ntfctn_imminent_days := p_old_ovrd_ntfctn_immnnt_days;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_ovrd_ntfctn_rmndr_days,0) <>
 	NVL(p_old_ovrd_ntfctn_rmndr_days,0) THEN
	v_mil_rec.ovrd_ntfctn_reminder_days := p_old_ovrd_ntfctn_rmndr_days;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_re_reminder_days,0) <>
 	NVL(p_old_re_reminder_days,0) THEN
	v_mil_rec.ovrd_ntfctn_re_reminder_days := p_old_re_reminder_days;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_comments,'NULL') <> NVL(p_old_comments,'NULL') THEN
 	v_mil_rec.comments := p_old_comments;
	v_create_history := TRUE;
      END IF;
      IF v_create_history THEN
	v_mil_rec.person_id := p_person_id;
	v_mil_rec.ca_sequence_number := p_ca_sequence_number;
	v_mil_rec.sequence_number := p_sequence_number;
	v_mil_rec.hist_start_dt := p_old_update_on;
	v_mil_rec.hist_end_dt := p_new_update_on;
	v_mil_rec.hist_who := p_old_update_who;
        IGS_PR_MILESTONE_HST_PKG.INSERT_ROW(
          X_ROWID =>   LV_ROWID,
	  X_person_id => v_mil_rec.person_id,
	  X_ca_sequence_number => v_mil_rec.ca_sequence_number,
	  X_sequence_number => v_mil_rec.sequence_number,
	  X_hist_start_dt => v_mil_rec.hist_start_dt,
	  X_hist_end_dt => v_mil_rec.hist_end_dt,
	  X_hist_who => v_mil_rec.hist_who,
	  X_milestone_type => v_mil_rec.milestone_type,
	  X_milestone_status => v_mil_rec.milestone_status,
	  X_due_dt => v_mil_rec.due_dt,
	  X_description => v_mil_rec.description,
	  X_actual_reached_dt => v_mil_rec.actual_reached_dt,
	  X_preced_sequence_number=> v_mil_rec.preced_sequence_number,
	  X_ovrd_ntfctn_imminent_days => v_mil_rec.ovrd_ntfctn_imminent_days,
	  X_ovrd_ntfctn_reminder_days => v_mil_rec.ovrd_ntfctn_reminder_days,
	  X_ovrd_ntfctn_re_reminder_days => v_mil_rec.ovrd_ntfctn_re_reminder_days,
	  X_comments => v_mil_rec.comments,
	  X_Org_Id => v_org_id,
	  X_MODE  => 'R');
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      IGS_GE_MSG_STACK.ADD;
      app_Exception.Raise_Exception;
  END resp_ins_mil_hist;


  PROCEDURE RESP_INS_TEX_HIST(
    P_PERSON_ID IN NUMBER ,
    P_CA_SEQUENCE_NUMBER IN NUMBER ,
    P_THE_SEQUENCE_NUMBER IN NUMBER ,
    P_CREATION_DT IN DATE ,
    P_OLD_SUBMISSION_DT IN DATE ,
    P_NEW_SUBMISSION_DT IN DATE ,
    P_OLD_THESIS_EXAM_TYPE IN VARCHAR2 ,
    P_NEW_THESIS_EXAM_TYPE IN VARCHAR2 ,
    p_old_thesis_panel_type IN VARCHAR2 ,
    p_new_thesis_panel_type IN VARCHAR2 ,
    p_old_thesis_result_cd IN VARCHAR2 ,
    p_new_thesis_result_cd IN VARCHAR2 ,
    p_old_tracking_id IN NUMBER ,
    p_new_tracking_id  NUMBER ,
    p_old_update_who IN NUMBER ,
    p_new_update_who IN NUMBER ,
    p_old_update_on IN DATE ,
    p_new_update_on IN DATE )
  AS
    gv_other_detail		VARCHAR2(255);
    LV_ROWID			VARCHAR2(25);
    v_org_id IGS_PR_MILESTONE_HST.ORG_ID%TYPE := IGS_GE_GEN_003.Get_Org_Id;
  BEGIN	-- resp_ins_tex_hist
	-- Insert IGS_RE_THESIS_EXAM history (IGS_RE_THS_EXAM_HIST)
    DECLARE
      v_teh_rec			IGS_RE_THS_EXAM_HIST%ROWTYPE;
      v_create_history		BOOLEAN := FALSE;
      v_hist_start_dt			IGS_RE_THESIS_EXAM.last_update_date%TYPE;
      v_hist_end_dt			IGS_RE_THESIS_EXAM.last_update_date%TYPE;
      v_hist_who			IGS_RE_THESIS_EXAM.last_updated_by%TYPE;
    BEGIN
	-- If any of the old values (p_old_<column_name>) are different from the
	-- associated new  values (p_new_<column_name>)  (with the exception the
	-- last_updated_by and last_update_date columns) then create an IGS_RE_THS_EXAM_HIST history
	-- record with the old values (p_old_<column_name>).  Do not set the
	-- last_updated_by and last_update_date columns when creating the history record.
      IF NVL(p_new_submission_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
 	NVL(p_old_submission_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
	v_teh_rec.submission_dt := p_old_submission_dt;
	v_create_history := TRUE;
      END IF;
      IF p_new_thesis_exam_type <> p_old_thesis_exam_type THEN
	v_teh_rec.thesis_exam_type := p_old_thesis_exam_type;
	v_create_history := TRUE;
      END IF;
      IF p_new_thesis_panel_type <> p_old_thesis_panel_type THEN
	v_teh_rec.thesis_panel_type := p_old_thesis_panel_type;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_tracking_id, -1) <> NVL(p_old_tracking_id, -1) THEN
	v_teh_rec.tracking_id := p_old_tracking_id;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_thesis_result_cd, 'NULL') <>
		 NVL(p_old_thesis_result_cd,'NULL') THEN
	v_teh_rec.thesis_result_cd := NVL(p_old_thesis_result_cd,' ');
	v_create_history := TRUE;
      END IF;
      -- create a history record if any column has changed
      IF v_create_history = TRUE THEN
	v_teh_rec.person_id		:= p_person_id;
	v_teh_rec.ca_sequence_number 	:= p_ca_sequence_number;
	v_teh_rec.the_sequence_number 	:= p_the_sequence_number;
	v_teh_rec.creation_dt	 	:= p_creation_dt;
	v_teh_rec.hist_start_dt 	:= p_old_update_on;
	v_teh_rec.hist_end_dt 		:= NVL(p_new_update_on,SYSDATE);
	v_teh_rec.hist_who 		:= p_old_update_who;
        IGS_RE_THS_EXAM_HIST_PKG.INSERT_ROW(
  	  X_ROWID   => LV_ROWID,
	  X_person_id =>  v_teh_rec.person_id,
	  X_ca_sequence_number => v_teh_rec.ca_sequence_number,
	  X_the_sequence_number => v_teh_rec.the_sequence_number,
	  X_creation_dt => v_teh_rec.creation_dt,
	  X_hist_start_dt => v_teh_rec.hist_start_dt,
	  X_hist_end_dt => v_teh_rec.hist_end_dt,
	  X_hist_who => v_teh_rec.hist_who,
	  X_submission_dt => v_teh_rec.submission_dt,
	  X_thesis_exam_type => v_teh_rec.thesis_exam_type,
	  X_thesis_panel_type => v_teh_rec.thesis_panel_type,
	  X_tracking_id => v_teh_rec.tracking_id,
	  X_thesis_result_cd => v_teh_rec.thesis_result_cd,
	  X_Org_Id => v_org_id,
	  X_MODE => 'R');
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
  END resp_ins_tex_hist;

  FUNCTION RESP_INS_TEX_TRI(
    p_person_id IN NUMBER ,
    p_ca_sequence_number IN NUMBER ,
    p_the_sequence_number IN NUMBER ,
    p_creation_dt IN DATE ,
    p_thesis_panel_type IN VARCHAR2 ,
    p_message_name OUT NOCOPY VARCHAR2 )
  --add 3 new fields in the tbh calls to IGS_TR_ITEM and IGS_TR_STEP
  --for tracking dld nov 2001 release bug#1837257
/*-----------------------------------------------------------------------
who           when           what
svanukur      07-sep-2004   modified cursor c_pe for performance bug 3866423
--------------------------------------------------------------------------*/
  RETURN NUMBER AS
    gv_other_detail		VARCHAR2(255);
  BEGIN	-- resp_ins_tex_tri
	-- Insert tracking item for a thesis_examination_record.
	-- The routine returns the tracking ID of the item created.
	-- IGS_GE_NOTE: A commit is not done from this routine as it is done as part of the
	-- calling routine
    DECLARE
      cst_s_tracking_type	CONSTANT
					IGS_TR_TYPE.s_tracking_type%TYPE := 'RES_TEX';
      cst_stst_principal	CONSTANT
					IGS_TR_STEP.s_tracking_step_type%TYPE := 'RES_TEX_PR';
      cst_stst_student	CONSTANT
					IGS_TR_STEP.s_tracking_step_type%TYPE := 'RES_TEX_ST';
      cst_stst_originator	CONSTANT
					IGS_TR_STEP.s_tracking_step_type%TYPE := 'RES_TEX_OR';
      cst_stst_chair		CONSTANT
					IGS_TR_STEP.s_tracking_step_type%TYPE	:= 'RES_TEX_CH';
      cst_active		CONSTANT	IGS_TR_STATUS.s_tracking_status%TYPE := 'ACTIVE';
      v_message_name		VARCHAR2(30);
      v_originator_id		IGS_RE_THS_PNL_MBR.person_id%TYPE;
      v_recipient_id		IGS_TR_STEP.recipient_id%TYPE;
      v_tts_recipient_id		IGS_TR_TYPE_STEP.recipient_id%TYPE;
      v_principal_id		IGS_PE_PERSON.person_id%TYPE;
      v_chair_id			IGS_PE_PERSON.person_id%TYPE;
      v_tracking_id		IGS_TR_ITEM.tracking_id%TYPE;
      v_target_days		NUMBER;
      v_tracking_type		IGS_TR_TYPE.tracking_type%TYPE;
      v_tracking_status	IGS_TR_STATUS.tracking_status%TYPE;
      v_person_id		IGS_RE_SPRVSR.person_id%TYPE;
      v_start_dt		IGS_TR_ITEM.start_dt%TYPE;
      v_business_days_ind	IGS_TR_ITEM.business_days_ind%TYPE;
      v_action_dt		IGS_TR_STEP_V.action_dt%TYPE;
      v_current_person_id	IGS_PE_PERSON.person_id%TYPE;

      CURSOR c_pe IS
        SELECT	PERSON_PARTY_ID
        FROM fnd_user
        WHERE user_id = fnd_global.user_id;
      CURSOR c_rst_rsup IS
	SELECT	rsup.person_id
	FROM	IGS_RE_SPRVSR		rsup,
		IGS_RE_SPRVSR_TYPE	rst
	WHERE	rsup.ca_person_id		= p_person_id AND
         	rsup.ca_sequence_number		= p_ca_sequence_number AND
		rst.research_supervisor_type	= rsup.research_supervisor_type AND
		rst.principal_supervisor_ind	= 'Y'
	ORDER BY rsup.supervision_percentage DESC;
      CURSOR c_tpt (
		cp_thesis_panel_type	IGS_RE_THS_PNL_TYPE.thesis_panel_type%TYPE) IS
	SELECT	tpt.tracking_type
	FROM	IGS_RE_THS_PNL_TYPE	tpt
	WHERE	tpt.thesis_panel_type  	= cp_thesis_panel_type;
      CURSOR c_ts IS
	SELECT	ts.tracking_status
	FROM	IGS_TR_STATUS		ts
	WHERE	ts.s_tracking_status	= cst_active AND
		ts.closed_ind		= 'N'
	ORDER BY ts.tracking_status ASC;
      CURSOR c_tri (
		cp_tracking_id	IGS_TR_ITEM.tracking_id%TYPE) IS
	SELECT	tri.start_dt,
		tri.business_days_ind
	FROM	IGS_TR_ITEM		tri
	WHERE	tri.tracking_id		= cp_tracking_id;
      CURSOR c_tsdv (
 		cp_tracking_id		IGS_TR_ITEM.tracking_id%TYPE) IS
	SELECT	MAX(tsdv.action_dt)
	FROM	IGS_TR_STEP_V	tsdv
	WHERE	tsdv.tracking_id	= cp_tracking_id;
      CURSOR c_trs (
	            cp_tracking_id  IGS_TR_ITEM.tracking_id%TYPE) IS
	SELECT	trs.tracking_step_id,
		trs.s_tracking_step_type
	FROM	IGS_TR_STEP trs
	WHERE	trs.tracking_id = cp_tracking_id;
      CURSOR	c_tts (
		cp_tracking_type	IGS_TR_TYPE_STEP.tracking_type%TYPE,
		cp_tracking_type_step_id	IGS_TR_TYPE_STEP.tracking_type_step_id%TYPE) IS
	SELECT	tts.recipient_id
	FROM	IGS_TR_TYPE_STEP tts
	WHERE	tracking_type = cp_tracking_type	AND
		tracking_type_step_id = cp_tracking_type_step_id;
      CURSOR c_tpm (
		cp_person_id	IGS_RE_THS_PNL_MBR.ca_person_id%TYPE,
		cp_ca_sequence_number	IGS_RE_THS_PNL_MBR.ca_sequence_number%TYPE,
		cp_the_sequence_number	IGS_RE_THS_PNL_MBR.the_sequence_number%TYPE,
		cp_creation_dt			IGS_RE_THS_PNL_MBR.creation_dt%TYPE) IS
	SELECT	tpm.person_id
	FROM	IGS_RE_THS_PNL_MBR	tpm,
			IGS_RE_THS_PNL_MR_TP tpmt
	WHERE	tpm.ca_person_id = cp_person_id	AND
		tpm.ca_sequence_number = cp_ca_sequence_number	AND
		tpm.the_sequence_number = cp_the_sequence_number	AND
		tpm.creation_dt = cp_creation_dt	AND
		tpm.confirmed_dt IS NOT NULL AND
		tpmt.panel_member_type = tpm.panel_member_type	AND
		tpmt.panel_chair_ind = 'Y';
      CURSOR   CUR_IGS_TR_STEP  ( cp_tracking_id  IGS_TR_STEP.tracking_id%TYPE,
                           cp_tracking_STEP_id  IGS_TR_STEP.tracking_STEP_id%TYPE)  IS
        SELECT rowid , IGS_TR_STEP.*
        FROM    IGS_TR_STEP
        WHERE tracking_id = CP_tracking_id	AND
		 tracking_step_id = CP_tracking_step_id;
      CURSOR CUR_IGS_TR_ITEM ( cp_tracking_id  IGS_TR_ITEM.tracking_id%TYPE)IS
                     	    SELECT   rowid , IGS_TR_ITEM.*
        FROM      IGS_TR_ITEM
        WHERE  tracking_id	= CP_tracking_id;

    BEGIN
      -- Set the default message number and issue a savepoint
      p_message_name := NULL;
      SAVEPOINT	s_before_insert;
      -- Retrieve the principal supervisor ID
      OPEN c_rst_rsup;
      FETCH c_rst_rsup INTO v_person_id;
      IF c_rst_rsup%NOTFOUND THEN
        v_principal_id := NULL;
      ELSE
        v_principal_id := v_person_id;
      END IF;
      CLOSE c_rst_rsup;
      -- Retrieve the ID of the IGS_PS_UNIT chair
      OPEN c_tpm (p_person_id, p_ca_sequence_number,
		 p_the_sequence_number, p_creation_dt);
      FETCH c_tpm INTO v_person_id;
      IF c_tpm%NOTFOUND THEN
        v_chair_id := NULL;
      ELSE
        v_chair_id := v_person_id;
      END IF;
      CLOSE c_tpm;
      -- Set the originator id.

      OPEN c_pe;
      FETCH c_pe INTO v_current_person_id;

      IF c_pe%FOUND THEN
        CLOSE c_pe;
        v_originator_id := v_current_person_id;
      ELSE
        CLOSE c_pe;
        IF v_principal_id IS NOT NULL THEN
		v_originator_id := v_principal_id;
        ELSE
 	  v_originator_id := p_person_id;
        END IF;
      END IF;
      -- Determine the tracking type from the system type.
      OPEN c_tpt (p_thesis_panel_type);
      FETCH c_tpt INTO v_tracking_type;
      IF c_tpt%NOTFOUND THEN
        CLOSE c_tpt;
        RETURN NULL;
      ELSIF v_tracking_type IS NULL THEN
        CLOSE c_tpt;
        p_message_name := 'IGS_RE_CANT_LOC_TRK_TYPE_THES';
        RETURN NULL;
      END IF;
      CLOSE c_tpt;
      -- Determine the active tracking status.
      OPEN c_ts;
      FETCH c_ts INTO v_tracking_status;
      IF c_ts%NOTFOUND THEN
        CLOSE c_ts;
        p_message_name := 'IGS_RE_CANT_FIND_TRK_STATUS';
        RETURN NULL;
      END IF;
      CLOSE c_ts;
      -- Call routine to insert a tracking item of the appropriate type.
      IGS_TR_GEN_002.trkp_ins_trk_item (
			v_tracking_status,
			v_tracking_type,
			p_person_id,
			SYSDATE,		-- tracking start date
			NULL,			-- target days
			NULL,			-- sequence indicator
			NULL,			-- business days
			v_originator_id,	-- originator
			'Y',			-- s_created_ind
			v_tracking_id,		-- OUT NOCOPY
			v_message_name);
      IF v_message_name IS NOT NULL THEN
	ROLLBACK TO s_before_insert;
	p_message_name := v_message_name;
	RETURN NULL;
      END IF;
      -- Update the recipient IDs for the tracking steps.
      FOR v_trs_rec IN c_trs (v_tracking_id)
      LOOP
        IF v_trs_rec.s_tracking_step_type = cst_stst_principal THEN
	  v_recipient_id := NVL(v_principal_id,v_originator_id);
        ELSIF v_trs_rec.s_tracking_step_type = cst_stst_student THEN
	  v_recipient_id := p_person_id;
        ELSIF v_trs_rec.s_tracking_step_type = cst_stst_originator THEN
	  v_recipient_id := v_originator_id;
        ELSIF v_trs_rec.s_tracking_step_type = cst_stst_chair THEN
	  v_recipient_id := v_chair_id;
        ELSE
	  v_recipient_id := NULL;
        END IF;
        IF v_recipient_id IS NULL THEN
	  OPEN c_tts(	v_tracking_type,
         	v_trs_rec.tracking_step_id);
  	  FETCH c_tts INTO v_tts_recipient_id;
	  IF c_tts%FOUND THEN
	    v_recipient_id := v_tts_recipient_id;
	  END IF;
	  CLOSE c_tts;
        END IF;
        IF v_recipient_id IS NOT NULL THEN
	  -- Call routine to update the current step.
	  IF NOT IGS_TR_GEN_002.trkp_upd_trst (
  		v_tracking_id,
		v_trs_rec.tracking_step_id,			-- tracking step ID
		v_trs_rec.s_tracking_step_type, -- system tracking step type
		NULL,			-- action date
		NULL,			-- completion date
		NULL,			-- step completion indicator
		NULL,			-- by pass indicator
		v_recipient_id,	-- recipient_id
		v_message_name) THEN
	    ROLLBACK TO s_before_insert;
	    p_message_name := v_message_name;
	    RETURN NULL;
	  END IF;
        ELSE
	  -- Clear the recipient ID (IGS_GE_NOTE: no locking check as the record has been
	  -- created by this routine.
          BEGIN
            FOR IGS_TR_STEP_REC IN CUR_IGS_TR_STEP(V_TRACKING_ID, v_trs_rec.tracking_step_id)
            LOOP
              IGS_TR_STEP_PKG.UPDATE_ROW(
		X_ROWID => IGS_TR_STEP_REC.ROWID,
		X_TRACKING_ID => IGS_TR_STEP_REC.TRACKING_ID,
		X_TRACKING_STEP_ID => IGS_TR_STEP_REC.TRACKING_STEP_ID,
		X_TRACKING_STEP_NUMBER => IGS_TR_STEP_REC.TRACKING_STEP_NUMBER,
		X_DESCRIPTION  => IGS_TR_STEP_REC.DESCRIPTION,
		X_S_TRACKING_STEP_TYPE => IGS_TR_STEP_REC.S_TRACKING_STEP_TYPE ,
		X_COMPLETION_DT  => IGS_TR_STEP_REC.COMPLETION_DT,
		X_ACTION_DAYS  => IGS_TR_STEP_REC.ACTION_DAYS,
		X_STEP_COMPLETION_IND  => IGS_TR_STEP_REC.STEP_COMPLETION_IND  ,
		X_BY_PASS_IND  => IGS_TR_STEP_REC.BY_PASS_IND ,
		X_RECIPIENT_ID  => NULL,
		--add 3 new fields in the tbh call
                -- for tracking dld nov 2001 release bug#1837257
		X_STEP_GROUP_ID => IGS_TR_STEP_REC.STEP_GROUP_ID,
		X_PUBLISH_IND   => IGS_TR_STEP_REC.PUBLISH_IND,
		X_STEP_CATALOG_CD => IGS_TR_STEP_REC.STEP_CATALOG_CD,
		X_MODE  => 'R');
            END LOOP;
          END;
	END IF;
      END LOOP;
	-- Update the target days of the item. This is done in two separate queries
	-- as the view does quite a bit of processing and this is considered to be
	-- the most efficient approach.
      OPEN c_tri (
	v_tracking_id);
      FETCH c_tri INTO v_start_dt,
		 v_business_days_ind;
      CLOSE c_tri;
      OPEN c_tsdv (
	v_tracking_id);
      FETCH c_tsdv INTO v_action_dt;
      CLOSE c_tsdv;
      v_target_days := IGS_TR_GEN_001.trkp_clc_days_ovrdue (
						v_start_dt,
						v_action_dt,
						v_business_days_ind);
      BEGIN
        FOR IGS_TR_ITEM_REC IN CUR_IGS_TR_ITEM (V_TRACKING_ID)
        LOOP
          IGS_TR_ITEM_REC.TARGET_DAYS := v_target_days;
          IGS_TR_ITEM_PKG.UPDATE_ROW(
	    X_ROWID  => IGS_TR_ITEM_REC.ROWID,
	    X_TRACKING_ID => IGS_TR_ITEM_REC.TRACKING_ID,
	    X_TRACKING_STATUS => IGS_TR_ITEM_REC.TRACKING_STATUS,
	    X_TRACKING_TYPE =>  IGS_TR_ITEM_REC.TRACKING_TYPE,
	    X_SOURCE_PERSON_ID  => IGS_TR_ITEM_REC.SOURCE_PERSON_ID,
            X_START_DT => IGS_TR_ITEM_REC.START_DT,
  	    X_TARGET_DAYS  =>  IGS_TR_ITEM_REC.TARGET_DAYS,
	    X_SEQUENCE_IND =>  IGS_TR_ITEM_REC.SEQUENCE_IND,
	    X_BUSINESS_DAYS_IND =>  IGS_TR_ITEM_REC.BUSINESS_DAYS_IND,
	    X_ORIGINATOR_PERSON_ID =>IGS_TR_ITEM_REC.ORIGINATOR_PERSON_ID  ,
	    X_S_CREATED_IND =>  IGS_TR_ITEM_REC.S_CREATED_IND,
	   --add 3 new fields in the tbh call
           -- for tracking dld nov 2001 release bug#1837257
	    X_COMPLETION_DUE_DT => IGS_TR_ITEM_REC.COMPLETION_DUE_DT,
	    X_OVERRIDE_OFFSET_CLC_IND => IGS_TR_ITEM_REC.OVERRIDE_OFFSET_CLC_IND ,
	    X_PUBLISH_IND  => IGS_TR_ITEM_REC.PUBLISH_IND,
	    X_MODE => 'R');
        END LOOP;
      END;
      RETURN v_tracking_id;
    EXCEPTION
      WHEN OTHERS THEN
	IF c_pe%ISOPEN THEN
  	  CLOSE c_pe;
	END IF;
	IF c_rst_rsup%ISOPEN THEN
	  CLOSE c_rst_rsup;
	END IF;
	IF c_tpt%ISOPEN THEN
	  CLOSE c_tpt;
	END IF;
	IF c_tpm%ISOPEN THEN
	  CLOSE c_tpm;
	END IF;
	IF c_ts%ISOPEN THEN
	  CLOSE c_ts;
	END IF;
	IF c_tri%ISOPEN THEN
	  CLOSE c_tri;
	END IF;
	IF c_tsdv%ISOPEN THEN
	   CLOSE c_tsdv;
	END IF;
	IF c_tts%ISOPEN THEN
	  CLOSE c_tts;
	END IF;
	RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END resp_ins_tex_tri;


  PROCEDURE RESP_INS_THE_HIST(
    p_person_id IN NUMBER ,
    p_ca_sequence_number IN NUMBER ,
    p_sequence_number IN NUMBER ,
    p_old_title IN VARCHAR2 ,
    p_new_title IN VARCHAR2 ,
    p_old_final_title_ind IN VARCHAR2 ,
    p_new_final_title_ind IN VARCHAR2 ,
    p_old_short_title IN VARCHAR2 ,
    p_new_short_title IN VARCHAR2 ,
    p_old_abbreviated_title IN VARCHAR2 ,
    p_new_abbreviated_title IN VARCHAR2 ,
    p_old_thesis_result_cd IN VARCHAR2 ,
    p_new_thesis_result_cd IN VARCHAR2 ,
    p_old_expected_submission_dt IN DATE ,
    p_new_expected_submission_dt IN DATE ,
    p_old_library_lodgement_dt IN DATE ,
    p_new_library_lodgement_dt IN DATE ,
    p_old_library_catalogue_number IN VARCHAR2 ,
    p_new_library_catalogue_number IN VARCHAR2 ,
    p_old_embargo_expiry_dt IN DATE ,
    p_new_embargo_expiry_dt IN DATE ,
    p_old_thesis_format IN VARCHAR2 ,
    p_new_thesis_format IN VARCHAR2 ,
    p_old_logical_delete_dt IN DATE ,
    p_new_logical_delete_dt IN DATE ,
    p_old_embargo_details IN VARCHAR2 ,
    p_new_embargo_details IN VARCHAR2 ,
    p_old_thesis_topic IN VARCHAR2 ,
    p_new_thesis_topic IN VARCHAR2 ,
    p_old_citation IN VARCHAR2 ,
    p_new_citation IN VARCHAR2 ,
    p_old_comments IN VARCHAR2 ,
    p_new_comments IN VARCHAR2 ,
    p_old_update_who IN NUMBER ,
    p_new_update_who IN NUMBER ,
    p_old_update_on IN DATE ,
    p_new_update_on IN DATE )
  AS
    gv_other_detail		VARCHAR2(255);
    LV_ROWID			VARCHAR2(25);
    v_org_id IGS_PR_MILESTONE_HST.ORG_ID%TYPE := IGS_GE_GEN_003.Get_Org_Id;

  BEGIN	-- resp_ins_the_hist
	-- Insert IGS_RE_THESIS history (IGS_RE_THESIS_HIST)
    DECLARE
	v_th_rec			IGS_RE_THESIS_HIST%ROWTYPE;
	v_create_history		BOOLEAN := FALSE;
	v_hist_start_dt			IGS_RE_THESIS.last_update_date%TYPE;
	v_hist_end_dt			IGS_RE_THESIS.last_update_date%TYPE;
	v_hist_who			IGS_RE_THESIS.last_updated_by%TYPE;
    BEGIN
	-- If any of the old values (p_old_<column_name>) are different from the
	-- associated new  values (p_new_<column_name>)  (with the exception the
	-- last_updated_by and last_update_date columns) then create an IGS_RE_THESIS_HIST history
	-- record with the old values (p_old_<column_name>).  Do not set the
	-- last_updated_by and last_update_date columns when creating the history record.
	IF p_new_title <> p_old_title THEN
		v_th_rec.title := p_old_title;
		v_create_history := TRUE;
	END IF;
	IF p_new_final_title_ind <> p_old_final_title_ind THEN
		v_th_rec.final_title_ind := p_old_final_title_ind;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_short_title, 'NULL') <> NVL(p_old_short_title, 'NULL') THEN
		v_th_rec.short_title := p_old_short_title;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_abbreviated_title, 'NULL') <>
					NVL(p_old_abbreviated_title, 'NULL')  THEN
		v_th_rec.abbreviated_title := p_old_abbreviated_title;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_thesis_result_cd, 'NULL') <>
					NVL(p_old_thesis_result_cd, 'NULL') THEN
		v_th_rec.thesis_result_cd := NVL(p_old_thesis_result_cd,' ');
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_expected_submission_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
			NVL(p_old_expected_submission_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
		v_th_rec.expected_submission_dt := p_old_expected_submission_dt;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_library_lodgement_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
			NVL(p_old_library_lodgement_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
		v_th_rec.date_of_library_lodgement := p_old_library_lodgement_dt;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_library_catalogue_number, 'NULL') <>
					 NVL(p_old_library_catalogue_number, 'NULL') THEN
		v_th_rec.library_catalogue_number := p_old_library_catalogue_number;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_embargo_expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
			NVL(p_old_embargo_expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
		v_th_rec.embargo_expiry_dt := p_old_embargo_expiry_dt;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_thesis_format, 'NULL') <> NVL(p_old_thesis_format, 'NULL') THEN
		v_th_rec.thesis_format := p_old_thesis_format;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_logical_delete_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
			NVL(p_old_logical_delete_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
		v_th_rec.logical_delete_dt := p_old_logical_delete_dt;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_embargo_details, 'NULL') <>
						 NVL(p_old_embargo_details, 'NULL') THEN
		v_th_rec.embargo_details := p_old_embargo_details;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_thesis_topic, 'NULL') <> NVL(p_old_thesis_topic, 'NULL') THEN
		v_th_rec.thesis_topic := p_old_thesis_topic;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_citation, 'NULL') <> NVL(p_old_citation, 'NULL') THEN
		v_th_rec.citation := p_old_citation;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_comments, 'NULL') <> NVL(p_old_comments, 'NULL') THEN
		v_th_rec.comments := p_old_comments;
		v_create_history := TRUE;
	END IF;
	IF v_create_history = TRUE THEN
		v_th_rec.person_id		:= p_person_id;
		v_th_rec.ca_sequence_number 	:= p_ca_sequence_number;
		v_th_rec.sequence_number 	:= p_sequence_number;
		v_th_rec.hist_start_dt 		:= p_old_update_on;
		v_th_rec.hist_end_dt 		:= NVL(p_new_update_on,SYSDATE);
		v_th_rec.hist_who 		:= p_old_update_who;
                IGS_RE_THESIS_HIST_PKG.INSERT_ROW(
			X_ROWID  => LV_ROWID,
			X_person_id => v_th_rec.person_id,
			X_ca_sequence_number => v_th_rec.ca_sequence_number,
			X_sequence_number => v_th_rec.sequence_number,
			X_hist_start_dt => v_th_rec.hist_start_dt,
			X_hist_end_dt => v_th_rec.hist_end_dt,
			X_hist_who => v_th_rec.hist_who,
			X_title => v_th_rec.title,
			X_final_title_ind => v_th_rec.final_title_ind,
			X_short_title => v_th_rec.short_title,
			X_abbreviated_title => v_th_rec.abbreviated_title,
			X_thesis_result_cd => v_th_rec.thesis_result_cd,
			X_expected_submission_dt => v_th_rec.expected_submission_dt,
			X_date_of_library_lodgement => v_th_rec.date_of_library_lodgement,
			X_library_catalogue_number => v_th_rec.library_catalogue_number,
			X_embargo_expiry_dt => v_th_rec.embargo_expiry_dt,
			X_thesis_format => v_th_rec.thesis_format,
			X_logical_delete_dt => v_th_rec.logical_delete_dt,
			X_embargo_details => v_th_rec.embargo_details,
			X_thesis_topic => v_th_rec.thesis_topic,
			X_citation => v_th_rec.citation,
			X_comments => v_th_rec.comments,
			X_Org_Id => v_org_id,
                  X_MODE => 'R');
	END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END resp_ins_the_hist;


  PROCEDURE RESP_INS_TPM_HIST(
    p_ca_person_id IN NUMBER ,
    p_ca_sequence_number IN NUMBER ,
    p_the_sequence_number IN NUMBER ,
    p_creation_dt IN DATE ,
    p_person_id IN NUMBER ,
    p_old_panel_member_type IN VARCHAR2 ,
    p_new_panel_member_type IN VARCHAR2 ,
    p_old_confirmed_dt IN DATE ,
    p_new_confirmed_dt IN DATE ,
    p_old_declined_dt IN DATE ,
    p_new_declined_dt IN DATE ,
    p_old_anonymity_ind IN VARCHAR2 ,
    p_new_anonymity_ind IN VARCHAR2 ,
    p_old_thesis_result_cd IN VARCHAR2 ,
    p_new_thesis_result_cd IN VARCHAR2 ,
    p_old_paid_dt IN DATE ,
    p_new_paid_dt IN DATE ,
    p_old_tracking_id IN NUMBER ,
    p_new_tracking_id IN NUMBER ,
    p_old_recommendation_summary IN VARCHAR2 ,
    p_new_recommendation_summary IN VARCHAR2 ,
    p_old_update_who IN NUMBER ,
    p_new_update_who IN NUMBER ,
    p_old_update_on IN DATE ,
    p_new_update_on IN DATE )
  AS
    gv_other_detail		VARCHAR2(255);
    LV_ROWID			VARCHAR2(25);
    v_org_id IGS_PR_MILESTONE_HST.ORG_ID%TYPE := IGS_GE_GEN_003.Get_Org_Id;
  BEGIN	-- resp_ins_tpm_hist
	-- Insert IGS_RE_THS_PNL_MBR history (IGS_RE_THS_PNL_MR_HS)
    DECLARE
      v_tpmh_rec			IGS_RE_THS_PNL_MR_HS%ROWTYPE;
      v_create_history		BOOLEAN := FALSE;
      v_hist_start_dt			IGS_RE_THS_PNL_MBR.last_update_date%TYPE;
      v_hist_end_dt			IGS_RE_THS_PNL_MBR.last_update_date%TYPE;
      v_hist_who			IGS_RE_THS_PNL_MBR.last_updated_by%TYPE;
    BEGIN
        -- If any of the old values (p_old_<column_name>) are different from the
	-- associated new  values (p_new_<column_name>)  (with the exception the
	-- last_updated_by and last_update_date columns) then create an IGS_RE_THS_EXAM_HIST history
	-- record with the old values (p_old_<column_name>).  Do not set the
	-- last_updated_by and last_update_date columns when creating the history record.
      IF p_new_panel_member_type <> p_old_panel_member_type THEN
	v_tpmh_rec.panel_member_type := p_old_panel_member_type;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_confirmed_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
  	NVL(p_old_confirmed_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
	v_tpmh_rec.confirmed_dt := p_old_confirmed_dt;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_declined_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
		NVL(p_old_declined_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
	v_tpmh_rec.declined_dt := p_old_declined_dt;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_anonymity_ind, 'NULL') <> NVL(p_old_anonymity_ind, 'NULL') THEN
 	v_tpmh_rec.anonymity_ind := p_old_anonymity_ind;
	v_create_history := TRUE;
      END IF;
     IF NVL(p_new_thesis_result_cd, 'NULL') <>
			 NVL(p_old_thesis_result_cd, 'NULL') THEN
	v_tpmh_rec.thesis_result_cd := NVL(p_old_thesis_result_cd, ' ');
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_paid_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
		NVL(p_old_paid_dt, IGS_GE_DATE.IGSDATE('1900/01/01' )) THEN
	v_tpmh_rec.paid_dt := p_old_paid_dt;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_tracking_id, -1) <> NVL(p_old_tracking_id, -1) THEN
	v_tpmh_rec.tracking_id := p_old_tracking_id;
	v_create_history := TRUE;
      END IF;
      IF NVL(p_new_recommendation_summary, 'NULL') <>
			NVL(p_old_recommendation_summary, 'NULL') THEN
	v_tpmh_rec.recommendation_summary := p_old_recommendation_summary;
	v_create_history := TRUE;
      END IF;
      -- create a history record if any column has changed
      IF v_create_history = TRUE THEN
	v_tpmh_rec.ca_person_id		:= p_ca_person_id;
	v_tpmh_rec.ca_sequence_number 	:= p_ca_sequence_number;
	v_tpmh_rec.the_sequence_number 	:= p_the_sequence_number;
	v_tpmh_rec.creation_dt	 	:= p_creation_dt;
	v_tpmh_rec.person_id		:= p_person_id;
	v_tpmh_rec.hist_start_dt 	:= p_old_update_on;
	v_tpmh_rec.hist_end_dt 		:= NVL(p_new_update_on,SYSDATE);
	v_tpmh_rec.hist_who 		:= p_old_update_who;
         IGS_RE_THS_PNL_MR_HS_PKG.INSERT_ROW(
			X_ROWID  => LV_ROWID,
			X_ca_person_id => v_tpmh_rec.ca_person_id,
			X_ca_sequence_number => v_tpmh_rec.ca_sequence_number,
			X_the_sequence_number => v_tpmh_rec.the_sequence_number,
			X_creation_dt => v_tpmh_rec.creation_dt,
			X_person_id => v_tpmh_rec.person_id,
			X_hist_start_dt => v_tpmh_rec.hist_start_dt,
			X_hist_end_dt => v_tpmh_rec.hist_end_dt,
			X_hist_who => v_tpmh_rec.hist_who,
			X_panel_member_type => v_tpmh_rec.panel_member_type,
			X_confirmed_dt => v_tpmh_rec.confirmed_dt,
			X_declined_dt => v_tpmh_rec.declined_dt,
			X_anonymity_ind => v_tpmh_rec.anonymity_ind,
			X_thesis_result_cd => v_tpmh_rec.thesis_result_cd,
			X_paid_dt => v_tpmh_rec.paid_dt,
			X_tracking_id => v_tpmh_rec.tracking_id,
			X_recommendation_summary => v_tpmh_rec.recommendation_summary,
			X_Org_Id => v_org_id,
			X_MODE => 'R');

      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END resp_ins_tpm_hist;


  FUNCTION RESP_INS_TPM_TRI(
    p_ca_person_id IN NUMBER ,
    p_ca_sequence_number IN NUMBER ,
    p_person_id IN NUMBER ,
    p_panel_member_type IN VARCHAR2 ,
    p_message_name OUT NOCOPY VARCHAR2 )
  --add 3 new fields in the tbh calls to IGS_TR_ITEM and IGS_TR_STEP
  -- for tracking dld nov 2001 release bug#1837257
/*-----------------------------------------------------------------------
who           when           what
svanukur      07-sep-2004   modified cursor c_pe for performance bug 3866423
--------------------------------------------------------------------------*/
  RETURN NUMBER AS
	gv_other_detail		VARCHAR2(255);
  BEGIN 	-- resp_ins_tpm_tri
	-- Insert tracking item for a IGS_RE_THS_PNL_MBR.
	-- The routine returns the tracking ID of the item created.
	-- IGS_GE_NOTE: A commit is not done from this routine as it is done as part of
	-- the calling routine.
    DECLARE
	cst_s_tracking_type		CONSTANT	VARCHAR2(10) := 'RES_TPM';
	cst_stst_person			CONSTANT	VARCHAR2(10) := 'RES_TPM_PE';
	cst_stst_originator		CONSTANT	VARCHAR2(10) := 'RES_TPM_OR';
	v_message_name		VARCHAR2(30);
	 v_current_person_id IGS_PE_PERSON.person_id%TYPE;
	v_originator_id		IGS_RE_THS_PNL_MBR.person_id%TYPE;
	v_recipient_id		IGS_TR_STEP.recipient_id%TYPE;
	v_tts_recipient_id		IGS_TR_TYPE_STEP.recipient_id%TYPE;
	v_tracking_id		IGS_TR_ITEM.tracking_id%TYPE;
	v_target_days		NUMBER;
	v_tracking_type		IGS_TR_TYPE.tracking_type%TYPE;
	v_tracking_status	IGS_TR_STATUS.tracking_status%TYPE;
	v_person_id		IGS_RE_SPRVSR.person_id%TYPE;
	v_start_dt		IGS_TR_ITEM.start_dt%TYPE;
	v_business_days_ind	IGS_TR_ITEM.business_days_ind%TYPE;
	v_action_dt		IGS_TR_STEP_V.action_dt%TYPE;
	CURSOR c_pe IS
	SELECT	PERSON_PARTY_ID
        FROM fnd_user
        WHERE user_id = fnd_global.user_id;
	CURSOR c_rst_rsup IS
		SELECT	rsup.person_id
		FROM	IGS_RE_SPRVSR		rsup,
			IGS_RE_SPRVSR_TYPE	rst
		WHERE	rsup.ca_person_id		= p_ca_person_id AND
			rsup.ca_sequence_number		= p_ca_sequence_number AND
			rst.research_supervisor_type	= rsup.research_supervisor_type AND
			rst.principal_supervisor_ind	= 'Y'
		ORDER BY rsup.supervision_percentage DESC;
	CURSOR c_tmpt (
			cp_panel_member_type    IGS_RE_THS_PNL_MR_TP.panel_member_type%TYPE) IS
		SELECT	tmpt.tracking_type
		FROM	IGS_RE_THS_PNL_MR_TP		tmpt
		WHERE	tmpt.panel_member_type = cp_panel_member_type;
	CURSOR c_ts IS
		SELECT	ts.tracking_status
		FROM	IGS_TR_STATUS		ts
		WHERE	ts.s_tracking_status	= 'ACTIVE' AND
			ts.closed_ind		= 'N'
		ORDER BY ts.tracking_status ASC;
	CURSOR c_tri (
			cp_tracking_id	IGS_TR_ITEM.tracking_id%TYPE) IS
		SELECT	tri.start_dt,
			tri.business_days_ind
		FROM	IGS_TR_ITEM		tri
		WHERE	tri.tracking_id		= cp_tracking_id;
	CURSOR c_tsdv (
			cp_tracking_id	IGS_TR_ITEM.tracking_id%TYPE) IS
		SELECT	MAX(tsdv.action_dt)
		FROM	IGS_TR_STEP_V	tsdv
		WHERE	tsdv.tracking_id	= cp_tracking_id;
	CURSOR c_trs (
			cp_tracking_id  IGS_TR_ITEM.tracking_id%TYPE) IS
		SELECT  trs.tracking_step_id,
				trs.s_tracking_step_type
		FROM	IGS_TR_STEP trs
		WHERE	trs.tracking_id = cp_tracking_id;
	CURSOR	c_tts (
			cp_tracking_type	IGS_TR_TYPE_STEP.tracking_type%TYPE,
			cp_tracking_type_step_id	IGS_TR_TYPE_STEP.tracking_type_step_id%TYPE) IS
		SELECT	tts.recipient_id
		FROM	IGS_TR_TYPE_STEP tts
		WHERE	tracking_type = cp_tracking_type	AND
			tracking_type_step_id = cp_tracking_type_step_id;
	 CURSOR   CUR_IGS_TR_STEP  ( cp_tracking_id  IGS_TR_STEP.tracking_id%TYPE,
                            cp_tracking_STEP_id  IGS_TR_STEP.tracking_STEP_id%TYPE)  IS
                                   SELECT rowid , IGS_TR_STEP.*
		   FROM    IGS_TR_STEP
		   WHERE tracking_id = CP_tracking_id	AND
			 tracking_step_id = CP_tracking_step_id;
       CURSOR CUR_IGS_TR_ITEM ( cp_tracking_id  IGS_TR_ITEM.tracking_id%TYPE)IS
                     	    SELECT   rowid , IGS_TR_ITEM.*
		   FROM      IGS_TR_ITEM
                                   WHERE  tracking_id	= CP_tracking_id;



    BEGIN
	p_message_name := NULL;
	SAVEPOINT s_before_update;
	-- Get the originator IGS_PE_PERSON ID, being the principal supervisor with the
	-- greatest supervising load. If multiple principal supervisors exist, then
	-- use the first.

        OPEN c_pe;
	FETCH c_pe INTO v_current_person_id;
	IF c_pe%FOUND THEN
		CLOSE c_pe;
		v_originator_id := v_current_person_id;
	ELSE
		CLOSE c_pe;
		OPEN c_rst_rsup;
		FETCH c_rst_rsup INTO v_person_id;
		IF c_rst_rsup%NOTFOUND THEN
			CLOSE c_rst_rsup;
			v_originator_id := p_ca_person_id;
		ELSE
			CLOSE c_rst_rsup;
			v_originator_id := v_person_id;
		END IF;
	END IF;
	-- Determine the tracking type from the system type.
	OPEN c_tmpt (p_panel_member_type);
	FETCH c_tmpt INTO v_tracking_type;
	IF c_tmpt%NOTFOUND THEN
		CLOSE c_tmpt;
		RETURN NULL;
	ELSIF v_tracking_type IS NULL THEN
		CLOSE c_tmpt;
		p_message_name := 'IGS_RE_CANT_LOC_TRK_TYPE_MEM';
		RETURN NULL;
	END IF;
	CLOSE c_tmpt;
	-- Determine the active tracking status.
	OPEN c_ts;
	FETCH c_ts INTO v_tracking_status;
	IF c_ts%NOTFOUND THEN
		CLOSE c_ts;
		p_message_name := 'IGS_RE_CANT_FIND_TRK_STATUS';
		RETURN NULL;
	END IF;
	CLOSE c_ts;
	-- Call routine to insert a tracking item of the appropriate type.
	IGS_TR_GEN_002.trkp_ins_trk_item (
			v_tracking_status,
			v_tracking_type,
			p_person_id,
			SYSDATE,		-- tracking start date
			NULL,			-- target days
			NULL,			-- sequence indicator
			NULL,			-- business days
			v_originator_id,	-- originator
			'Y',			-- s_created_ind
			v_tracking_id,		-- OUT NOCOPY
			v_message_name);
	IF v_message_name IS NOT NULL THEN
		ROLLBACK TO s_before_update;
		p_message_name := v_message_name;
		RETURN NULL;
	END IF;
	FOR v_trs_rec IN c_trs (v_tracking_id)
	LOOP
		IF v_trs_rec.s_tracking_step_type = cst_stst_person THEN
				v_recipient_id := p_person_id;
		ELSIF v_trs_rec.s_tracking_step_type = cst_stst_originator THEN
				v_recipient_id := v_originator_id;
		ELSE
				v_recipient_id := NULL;
		END IF;
		IF v_recipient_id IS NULL THEN
			OPEN c_tts(	v_tracking_type,
					v_trs_rec.tracking_step_id);
			FETCH c_tts INTO v_tts_recipient_id;
			IF c_tts%FOUND THEN
				v_recipient_id := v_tts_recipient_id;
			END IF;
			CLOSE c_tts;
		END IF;
		IF v_recipient_id IS NOT NULL THEN
			-- Update the recipient ID to the panel member for steps linked to the
			-- appropriate s_tracking_step_type.
			IF NOT IGS_TR_GEN_002.trkp_upd_trst (
					v_tracking_id,
					v_trs_rec.tracking_step_id,	-- tracking step ID
					v_trs_rec.s_tracking_step_type, -- system tracking step type
					NULL,			-- action date
					NULL,			-- completion date
					NULL,			-- step completion indicator
					NULL,			-- by pass indicator
					v_recipient_id,	-- recipient_id
					v_message_name) THEN
				ROLLBACK TO s_before_update;
				p_message_name := v_message_name;
				RETURN NULL;
			END IF;
		ELSE
			-- Clear the recipient ID.
                  BEGIN
                     FOR IGS_TR_STEP_REC IN CUR_IGS_TR_STEP (v_tracking_id, v_trs_rec.tracking_step_id)
                     LOOP

                       IGS_TR_STEP_PKG.UPDATE_ROW(
				X_ROWID => IGS_TR_STEP_REC.ROWID,
				X_TRACKING_ID => IGS_TR_STEP_REC.TRACKING_ID,
				X_TRACKING_STEP_ID => IGS_TR_STEP_REC.TRACKING_STEP_ID,
				X_TRACKING_STEP_NUMBER => IGS_TR_STEP_REC.TRACKING_STEP_NUMBER,
				X_DESCRIPTION  => IGS_TR_STEP_REC.DESCRIPTION,
				X_S_TRACKING_STEP_TYPE => IGS_TR_STEP_REC.S_TRACKING_STEP_TYPE ,
				X_COMPLETION_DT  => IGS_TR_STEP_REC.COMPLETION_DT        ,
				X_ACTION_DAYS  => IGS_TR_STEP_REC.ACTION_DAYS,
				X_STEP_COMPLETION_IND  => IGS_TR_STEP_REC.STEP_COMPLETION_IND  ,
				X_BY_PASS_IND  => IGS_TR_STEP_REC.BY_PASS_IND ,
				X_RECIPIENT_ID  => NULL,
				--add 3 new fields in the tbh call
                                -- for tracking dld nov 2001 release bug#1837257
				X_STEP_GROUP_ID => IGS_TR_STEP_REC.STEP_GROUP_ID,
				X_PUBLISH_IND   => IGS_TR_STEP_REC.PUBLISH_IND,
				X_STEP_CATALOG_CD => IGS_TR_STEP_REC.STEP_CATALOG_CD,
				X_MODE  => 'R');
                     END LOOP;
                   END;
		END IF;
	END LOOP;
	-- Update the target days of the item. This is done in two separate queries
	-- as the view does quite a bit of processing and this is considered to be
	-- the most efficient approach.
	OPEN c_tri (
		v_tracking_id);
	FETCH c_tri INTO v_start_dt,
			 v_business_days_ind;
	CLOSE c_tri;
	OPEN c_tsdv (
		v_tracking_id);
	FETCH c_tsdv INTO v_action_dt;
	CLOSE c_tsdv;
	v_target_days := IGS_TR_GEN_001.trkp_clc_days_ovrdue (
						v_start_dt,
						v_action_dt,
						v_business_days_ind);
        BEGIN
          FOR IGS_TR_ITEM_REC IN CUR_IGS_TR_ITEM (V_TRACKING_ID)
          LOOP
                                                  IGS_TR_ITEM_REC.TARGET_DAYS := v_target_days;
              IGS_TR_ITEM_PKG.UPDATE_ROW(
			X_ROWID  => IGS_TR_ITEM_REC.ROWID,
			X_TRACKING_ID => IGS_TR_ITEM_REC.TRACKING_ID,
			X_TRACKING_STATUS => IGS_TR_ITEM_REC.TRACKING_STATUS,
			X_TRACKING_TYPE =>  IGS_TR_ITEM_REC.TRACKING_TYPE,
			X_SOURCE_PERSON_ID  => IGS_TR_ITEM_REC.SOURCE_PERSON_ID,
			X_START_DT => IGS_TR_ITEM_REC.START_DT,
			X_TARGET_DAYS  =>  IGS_TR_ITEM_REC.TARGET_DAYS,
			X_SEQUENCE_IND =>  IGS_TR_ITEM_REC.SEQUENCE_IND,
			X_BUSINESS_DAYS_IND =>  IGS_TR_ITEM_REC.BUSINESS_DAYS_IND,
			X_ORIGINATOR_PERSON_ID =>IGS_TR_ITEM_REC.ORIGINATOR_PERSON_ID  ,
			X_S_CREATED_IND =>  IGS_TR_ITEM_REC.S_CREATED_IND,
			--add 3 new fields in the tbh call
                        -- for tracking dld nov 2001 release bug#1837257
			X_COMPLETION_DUE_DT => IGS_TR_ITEM_REC.COMPLETION_DUE_DT,
			X_OVERRIDE_OFFSET_CLC_IND => IGS_TR_ITEM_REC.OVERRIDE_OFFSET_CLC_IND ,
			X_PUBLISH_IND  => IGS_TR_ITEM_REC.PUBLISH_IND,
			X_MODE => 'R');
            END LOOP;
      END;
      RETURN v_tracking_id;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_pe%ISOPEN THEN
          CLOSE c_pe;
        END IF;
	IF c_rst_rsup%ISOPEN THEN
	  CLOSE c_rst_rsup;
	END IF;
	IF c_tmpt%ISOPEN THEN
          CLOSE c_tmpt;
	END IF;
	IF c_ts%ISOPEN THEN
	  CLOSE c_ts;
	END IF;
	IF c_tri%ISOPEN THEN
	  CLOSE c_tri;
	END IF;
	IF c_tsdv%ISOPEN THEN
	  CLOSE c_tsdv;
	END IF;
	IF c_tts%ISOPEN THEN
	  CLOSE c_tts;
	END IF;
	RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END resp_ins_tpm_tri;


END IGS_RE_GEN_003 ;

/
