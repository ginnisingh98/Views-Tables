--------------------------------------------------------
--  DDL for Package Body IGS_LOOKUPS_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_LOOKUPS_VIEW_PKG" as
/* $Header: IGSMI14B.pls 115.13 2003/05/30 10:45:27 ptandon ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_LOOKUPS_view%RowType;

  new_references IGS_LOOKUPS_view%RowType;
/*  new_references_language IGS_LOOKUPS.LANGUAGE%TYPE;


  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_lookup_type IN VARCHAR2 DEFAULT NULL,
    x_lookup_code IN VARCHAR2 DEFAULT NULL,
    x_meaning IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_enabled_flag IN VARCHAR2 DEFAULT NULL,
    x_security_allowed_ind IN VARCHAR2 DEFAULT NULL,
    x_step_type_rstcn_num_ind IN VARCHAR2 DEFAULT NULL,
    x_unit_outcome_ind IN VARCHAR2 DEFAULT NULL,
    x_display_name IN VARCHAR2 DEFAULT NULL,
    x_display_order IN NUMBER DEFAULT NULL,
    x_step_order_applicable_ind IN VARCHAR2 DEFAULT NULL,
    x_academic_transcript_ind IN VARCHAR2 DEFAULT NULL,
    x_cmpltn_requirements_ind IN VARCHAR2 DEFAULT NULL,
    x_fee_ass_ind IN VARCHAR2 DEFAULT NULL,
    x_step_group_type IN VARCHAR2 DEFAULT NULL,
    x_final_result_ind IN VARCHAR2 DEFAULT NULL,
    x_system_generated_ind IN VARCHAR2 DEFAULT NULL,
    x_transaction_cat IN VARCHAR2 DEFAULT NULL,
    x_language IN VARCHAR2 DEFAULT 'US',
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_system_mandatory_ind IN VARCHAR2 DEFAULT NULL,
    x_default_display_seq IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_LOOKUPS_VAL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.lookup_type := x_lookup_type;
    new_references.lookup_code := x_lookup_code;
    new_references.meaning := x_meaning;
    new_references.closed_ind := x_closed_ind;
    new_references.enabled_flag := x_enabled_flag;
    new_references.security_allowed_ind := x_security_allowed_ind;
    new_references.step_type_restriction_num_ind := x_step_type_rstcn_num_ind;
    new_references.unit_outcome_ind := x_unit_outcome_ind;
    new_references.display_name := x_display_name;
    new_references.display_order := x_display_order;
    new_references.step_order_applicable_ind := x_step_order_applicable_ind;
    new_references.academic_transcript_ind := x_academic_transcript_ind;
    new_references.cmpltn_requirements_ind := x_cmpltn_requirements_ind;
    new_references.fee_ass_ind := x_fee_ass_ind;
    new_references.step_group_type := x_step_group_type;
    new_references.final_result_ind := x_final_result_ind;
    new_references.system_generated_ind := x_system_generated_ind;
    new_references.transaction_cat := x_transaction_cat;
    new_references_language := x_language;
    new_references.created_by := x_created_by;
    new_references.creation_date := x_creation_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_date := x_last_update_date;
    new_references.last_update_login := x_last_update_login;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
    new_references.x_system_mandatory_ind := x_system_mandatory_ind;
    new_references.x_default_display_seq  := x_default_display_seq;

  END Set_Column_Values;

*/
PROCEDURE Check_Child_Existance AS
/*
  History
  who        when         what
  smvk       27-Aug-2002  Removed the calls GET_FK_IGS_LOOKUPS_VIEW_ALLOCA and GET_FK_IGS_LOOKUPS_VIEW_DISBUR
                          to the Package IGS_FI_FEE_DSBR_FML_PKG as the package is obsolete.
			  They are associated to lookup_types 'DISBURSEMENT_METHOD' and 'ALLOCATION_METHOD'
			  This is as per SFCR005_Cleanup_Build (Enhancement Bug # 2531390).
*/
  BEGIN


  -- IF old_references.LOOKUP_TYPE = 'SEX' THEN
  --  IGS_PE_PERSON_PKG.GET_FK_IGS_LOOKUPS_VIEW(
  --	old_references.LOOKUP_CODE
  --  );
  -- END IF;


  IF old_references.LOOKUP_TYPE = 'AMOUNT_TYPE' THEN

    IGS_AD_INTAK_TRG_TYP_PKG.GET_FK_IGS_LOOKUPS_VIEW2(
	old_references.LOOKUP_CODE
    );

    IGS_AD_SBMINTAK_TRGT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
    );

    IGS_AD_SBMPS_FN_ITTT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
    );

    IGS_AD_SBMAO_FN_UITT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
    );

    IGS_AD_SBMAO_FN_CTTT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
    );

    IGS_AD_SBMAO_FN_AMTT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
    );

    IGS_AD_SBM_AOU_FNDTT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
    );

  END IF;

IF 	old_references.LOOKUP_TYPE = 'ADMISSION_PROCESS_TYPE' then
 IGS_AD_PECRS_OFOP_DT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;

IF 	old_references.LOOKUP_TYPE = 'ADMISSION_PROCESS_TYPE' then
 IGS_AD_PRCS_CAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ADMISSION_STEP_TYPE' then
 IGS_AD_PRCS_CAT_STEP_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ADM_APPL_STATUS' then
 IGS_AD_APPL_STAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ADM_CNDTNL_OFFER_STATUS' then
 IGS_AD_CNDNL_OFRSTAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ADM_DOC_STATUS' then
 IGS_AD_DOC_STAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ADM_ENTRY_QUAL_STATUS' then
 IGS_AD_ENT_QF_STAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ADM_FEE_STATUS' then
 IGS_AD_FEE_STAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ADM_OFFER_DFRMNT_STATUS' then
 IGS_AD_OFRDFRMT_STAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ADM_OFFER_RESP_STATUS' then
 IGS_AD_OFR_RESP_STAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ADM_OUTCOME_STATUS' then
 IGS_AD_OU_STAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ADM_OUTCOME_STATUS' then
 IGS_AD_UNIT_OU_STAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;

IF 	old_references.LOOKUP_TYPE = 'ADV_STND_GRANTING_STATUS' then
 IGS_AV_STND_UNIT_LVL_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ADV_STND_GRANTING_STATUS' then
 IGS_AV_STND_UNIT_PKG.GET_FK_IGS_LOOKUPS_VIEW_1(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ADV_STND_RECOGNITION_TYPE' then
 IGS_AV_STND_UNIT_PKG.GET_FK_IGS_LOOKUPS_VIEW_2(
	old_references.LOOKUP_CODE
		);
end if;

IF 	old_references.LOOKUP_TYPE = 'CAL_CAT' then
 IGS_CA_TYPE_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'CAL_CAT' then
 IGS_CA_DA_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;

IF 	old_references.LOOKUP_TYPE = 'CALENDAR_STATUS' then
 IGS_CA_STAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;

IF 	old_references.LOOKUP_TYPE = 'CHG_METHOD' then
 IGS_FI_EL_RNG_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'CHG_METHOD' then
 IGS_FI_F_CAT_FEE_LBL_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'CHG_METHOD' then
 IGS_FI_F_TYP_CA_INST_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'COURSE_GROUP_TYPE' then
 IGS_PS_GRP_TYPE_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'CRS_ATTEMPT_STATUS' then
 IGS_EN_STDNT_PS_ATT_PKG.GET_FK_IGS_LOOKUPS_VIEW_CAS(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'DISCONTINUATION_REASON_TYPE' then
 IGS_EN_DCNT_REASONCD_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'DT_OFFSET_CONSTRAINT_TYPE' then
 IGS_CA_DA_INST_OFCNT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'DT_OFFSET_CONSTRAINT_TYPE' then
 IGS_CA_DA_OFFCNT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ENROLMENT_STEP_TYPE' then
 IGS_EN_CAT_PRC_STEP_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'ENR_NOTE_TYPE' then
 IGS_EN_NOTE_TYPE_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'GRADE_CREATION_METHOD_TYPE' then
 IGS_AS_NON_ENR_STDOT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'GRADE_CREATION_METHOD_TYPE' then
 IGS_AS_SU_STMPTOUT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'HECS_PAYMENT_TYPE' then
 IGS_FI_GOV_HEC_PA_OP_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'INTAKE_TARGET_TYPE' then
 IGS_AD_INTAK_TRG_TYP_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'LOCATION_TYPE' then
 IGS_AD_LOCATION_TYPE_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'MILESTONE_STATUS' then
 IGS_PR_MS_STAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'NOTE_FORMAT_TYPE' then
 IGS_GE_NOTE_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
/*IF 	old_references.LOOKUP_TYPE = 'LETTER_OBJECT' then
 IGS_CO_S_LTR_PKG.GET_FK_IGS_LOOKUPS_VIEW_LETOBJ(
	old_references.LOOKUP_CODE
		);
end if ;
IF 	old_references.LOOKUP_TYPE = 'LETTER_REFERENCE_TYPE' then
 IGS_CO_S_LTR_PKG.GET_FK_IGS_LOOKUPS_VIEW_LETREF(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'OTHER_REFERENCE_TYPE' then
 IGS_CO_OU_CO_REF_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
*/
IF 	old_references.LOOKUP_TYPE = 'PERSON_ID_TYPE' then
 IGS_PE_PERSON_ID_TYP_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'PRG_CHECK_TYPE' then
 IGS_PR_STDNT_PR_CK_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'PRG_MEASURE_TYPE' then
 IGS_PR_SDT_PS_PR_MSR_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'PRG_RULE_REPEAT_FAIL_TYPE' then
 IGS_PR_RU_OU_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'PROGRESSION_OUTCOME_TYPE' then
 IGS_PR_OU_TYPE_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'PROGRESSION_STATUS' then
 IGS_EN_STDNT_PS_ATT_PKG.GET_FK_IGS_LOOKUPS_VIEW_PROG(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'REFERENCE_CD_TYPE' then
 IGS_GE_REF_CD_TYPE_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'RESULT_TYPE' then
 IGS_AS_GRD_SCH_GRADE_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'SCNDRY_SCHOOL_TYPE' then
 IGS_AD_AUS_SEC_ED_SC_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'STUDENT_TODO_TYPE' then
 IGS_PE_STD_TODO_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'THESIS_RESULT' then
 IGS_RE_THESIS_RESULT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'TRACKING_STEP_TYPE' then
 IGS_TR_STEP_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'TRACKING_STEP_TYPE' then
 IGS_TR_TYPE_STEP_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'TRANSACTION_TYPE' then
 IGS_FI_FEE_AS_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'UNIT_ATTEMPT_STATUS' then
 IGS_AD_ADM_UNIT_STAT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;
IF 	old_references.LOOKUP_TYPE = 'UNIT_ATTEMPT_STATUS' then
 IGS_EN_SU_ATTEMPT_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
end if;

IF 	old_references.LOOKUP_TYPE = 'VS_EN_COMMENCE' then
 igs_en_cpd_ext_pkg.get_fk_igs_lookups_view_1(
	old_references.LOOKUP_CODE
		);
END IF;

IF 	old_references.LOOKUP_TYPE = 'ENROLMENT_STEP_TYPE_EXT' then
 igs_en_cpd_ext_pkg.get_fk_igs_lookups_view_2(
	old_references.LOOKUP_CODE
		);
END IF;

--   Added by DDEY as a part of Bug # 2162831

IF  old_references.LOOKUP_TYPE = 'MARKS_GRADE_CHANGE_COMMENT' then
 IGS_AS_SU_ATMPT_ITM_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
END IF;

--   Added by DDEY as a part of Bug # 2162831

IF  old_references.LOOKUP_TYPE = 'GRADING_SCHEMA_TYPES' then
 IGS_AS_GRD_SCHEMA_PKG.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
END IF;

IF  old_references.LOOKUP_TYPE = 'UNIT_WAITLIST' then
 igs_en_orun_wlst_pri_pkg.GET_FK_IGS_LOOKUPS_VIEW(
	old_references.LOOKUP_CODE
		);
END IF;

  END Check_Child_Existance;

FUNCTION Get_PK_For_Validation (
    X_LOOKUP_TYPE in VARCHAR2,
    X_LOOKUP_CODE in VARCHAR2
   )RETURN BOOLEAN AS

CURSOR cur_rowid IS
      SELECT    1
      FROM     IGS_LOOKUPS_VIEW
      WHERE    LOOKUP_TYPE = x_LOOKUP_TYPE
      AND      LOOKUP_CODE = x_LOOKUP_CODE;

    lv_rowid cur_rowid%RowType;
  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
	IF (cur_rowid%FOUND) THEN
	  Close cur_rowid;
	  Return(TRUE);
	ELSE
	  Close cur_rowid;
	  Return(FALSE);
	END IF;
  END Get_PK_For_Validation;

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_lookup_type                       IN     VARCHAR2,
    x_lookup_code                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_security_allowed_ind              IN     VARCHAR2,
    x_step_type_restriction_num_in     IN     VARCHAR2,
    x_unit_outcome_ind                  IN     VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_step_order_applicable_ind         IN     VARCHAR2,
    x_academic_transcript_ind           IN     VARCHAR2,
    x_cmpltn_requirements_ind           IN     VARCHAR2,
    x_fee_ass_ind                       IN     VARCHAR2,
    x_step_group_type                   IN     VARCHAR2,
    x_final_result_ind                  IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_transaction_cat                   IN     VARCHAR2,
    x_encumbrance_level                 IN     NUMBER,
    x_open_for_enrollments              IN     VARCHAR2,
    x_system_calculated                 IN     VARCHAR2,
    x_system_mandatory_ind              IN     VARCHAR2,
    x_default_display_seq               IN     NUMBER,
    x_av_transcript_disp_options        IN     VARCHAR2
  ) AS

  cursor cur_rowid is SELECT rowid row_id
    FROM IGS_LOOKUPS_VAL
    WHERE LOOKUP_TYPE = X_LOOKUP_TYPE
    AND LOOKUP_CODE = X_LOOKUP_CODE;

  row_val VARCHAR2(30);

BEGIN
      OPEN cur_rowid;
      FETCH cur_rowid INTO row_val;
      CLOSE cur_rowid;
      igs_lookups_val_pkg.lock_row(
          x_rowid                             =>  row_val,
          x_lookup_type                       =>  x_lookup_type,
          x_lookup_code                       =>  x_lookup_code,
          x_closed_ind                        =>  x_closed_ind,
          x_security_allowed_ind              =>  x_security_allowed_ind,
          x_step_type_restriction_num_in     =>  x_step_type_restriction_num_in,
          x_unit_outcome_ind                  =>  x_unit_outcome_ind,
          x_display_name                      =>  x_display_name,
          x_display_order                     =>  x_display_order,
          x_step_order_applicable_ind         =>  x_step_order_applicable_ind,
          x_academic_transcript_ind           =>  x_academic_transcript_ind,
          x_cmpltn_requirements_ind           =>  x_cmpltn_requirements_ind,
          x_fee_ass_ind                       =>  x_fee_ass_ind,
          x_step_group_type                   =>  x_step_group_type,
          x_final_result_ind                  =>  x_final_result_ind,
          x_system_generated_ind              =>  x_system_generated_ind,
          x_transaction_cat                   =>  x_transaction_cat,
          x_encumbrance_level                 =>  x_encumbrance_level,
          x_open_for_enrollments              =>  x_open_for_enrollments,
          x_system_calculated                 =>  x_system_calculated,
          x_system_mandatory_ind              =>  x_system_mandatory_ind,
          x_default_display_seq               =>  x_default_display_seq,
          x_av_transcript_disp_options        =>  x_av_transcript_disp_options);

EXCEPTION
 WHEN OTHERS THEN
  fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
  igs_ge_msg_stack.add;
  app_Exception.RAISE_exception;
END LOCK_ROW;

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_lookup_type                       IN     VARCHAR2,
    x_lookup_code                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_security_allowed_ind              IN     VARCHAR2,
    x_step_type_restriction_num_in     IN     VARCHAR2,
    x_unit_outcome_ind                  IN     VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_step_order_applicable_ind         IN     VARCHAR2,
    x_academic_transcript_ind           IN     VARCHAR2,
    x_cmpltn_requirements_ind           IN     VARCHAR2,
    x_fee_ass_ind                       IN     VARCHAR2,
    x_step_group_type                   IN     VARCHAR2,
    x_final_result_ind                  IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_transaction_cat                   IN     VARCHAR2,
    x_encumbrance_level                 IN     NUMBER,
    x_open_for_enrollments              IN     VARCHAR2,
    x_system_calculated                 IN     VARCHAR2,
    x_system_mandatory_ind              IN     VARCHAR2,
    x_default_display_seq               IN     NUMBER,
    x_av_transcript_disp_options        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) as

/*
  History
  who        when         what
  smvk       28-Aug-2002  Removed the default value of x_mode parameter as it gives 'File.Pkg.22' gscc warning.
			  as a part of SFCR005_Cleanup_Build (Enhancement Bug # 2531390).
*/


  cursor cur_rowid is SELECT rowid row_id
    FROM IGS_LOOKUPS_VAL
    WHERE LOOKUP_TYPE = X_LOOKUP_TYPE
    AND LOOKUP_CODE = X_LOOKUP_CODE;

  row_val VARCHAR2(30);

BEGIN
      OPEN cur_rowid;
      FETCH cur_rowid INTO row_val;
      CLOSE cur_rowid;
      igs_lookups_val_pkg.update_row(
          x_rowid                             =>  row_val,
          x_lookup_type                       =>  x_lookup_type,
          x_lookup_code                       =>  x_lookup_code,
          x_closed_ind                        =>  x_closed_ind,
          x_security_allowed_ind              =>  x_security_allowed_ind,
          x_step_type_restriction_num_in     =>  x_step_type_restriction_num_in,
          x_unit_outcome_ind                  =>  x_unit_outcome_ind,
          x_display_name                      =>  x_display_name,
          x_display_order                     =>  x_display_order,
          x_step_order_applicable_ind         =>  x_step_order_applicable_ind,
          x_academic_transcript_ind           =>  x_academic_transcript_ind,
          x_cmpltn_requirements_ind           =>  x_cmpltn_requirements_ind,
          x_fee_ass_ind                       =>  x_fee_ass_ind,
          x_step_group_type                   =>  x_step_group_type,
          x_final_result_ind                  =>  x_final_result_ind,
          x_system_generated_ind              =>  x_system_generated_ind,
          x_transaction_cat                   =>  x_transaction_cat,
          x_encumbrance_level                 =>  x_encumbrance_level,
          x_open_for_enrollments              =>  x_open_for_enrollments,
          x_system_calculated                 =>  x_system_calculated,
          x_system_mandatory_ind              =>  x_system_mandatory_ind,
          x_default_display_seq               =>  x_default_display_seq,
          x_av_transcript_disp_options        =>  x_av_transcript_disp_options ,
          x_mode                              =>  'R' );
EXCEPTION
 WHEN OTHERS THEN
   RAISE;

END UPDATE_ROW;


end IGS_LOOKUPS_VIEW_PKG;

/
