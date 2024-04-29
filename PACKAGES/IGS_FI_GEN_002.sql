--------------------------------------------------------
--  DDL for Package IGS_FI_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSFI02S.pls 120.1 2005/06/05 20:26:20 appldev  $ */
--HISTORY
--Who            When                What
-- svuppala      31-MAY-2005       Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
--                                 Unit Version and Unit Level
--svuppala       13-Apr-2005         Bug 4297359 Added new field NONZERO_BILLABLE_CP_FLAG in IGS_FI_FEE_TYPE_CI_H_ALL
--pathipat       09-Sep-2003         Enh 3108052 - Add Unit Sets to Rate Table
--                                   Added 4 new params for unit_set_cd and us_version_number
--                                   in procedure finp_ins_far_hist()
--shtatiko       30-MAY-2003         Enh# 2831582, Added new column designated_payment_flag. As an impact modified finp_ins_ft_hist.
-- npalanis    23-OCT-2002  Bug : 2608360
--                          p_new and p_old residency_status_id column is changed to p_residency_status_cd of
--                          datatype varchar2.
--vvutukur      13-Sep-2002       Enh#2564643.Removed parameters p_old_subaccount_id,p_new_subaccount_id
--                                from procedure finp_ins_ft_hist.
--smvk          28-Aug-2002          Procedure finp_ins_fdf_hist is obsolete as part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
--vvutukur      28-Aug-2002   Bug#2531390.Removed the procedure finp_ins_fps_hist.
--jbegum         26-Aug-2002         As part of Enh Bug#2531390 the procedure finp_ins_pps_hist was removed.
--vvutukur       18-Jul-2002         Bug#2425767. Removed parameters p_new_deduction_amount,p_old_deduction_amount
--                                   from procedure finp_ins_frtns_hist and parameters p_new_payment_hierarchy_rank,
--                                   p_old_payment_hierarchy_rank from procedures finp_ins_fcfl_hist and
--                                   finp_ins_ftci_hist.
--vchappid       26-Apr-2002         Bug#2329407, removed the parameters fin_cal_type, fin_ci_sequence_number, account_cd from
--                                   the procedure finp_ins_ftci_hist
-- rnirwani      18-Jan-2002         Obsolete proc FINP_INS_CMA_HIST (2187247)
--masehgal       16-Jan-2002         ENH # 2170429
--                                   Obsoletion of SPONSOR_CD,SPONSORED_AMOUNT from finp_ins_pps_hist
--vvutukur       11-Jan-2002         added new columns to finp_ins_ft_hist
--                                   procedure as part of Bug 2175865
/* Obseleted the procedure finp_ins_fe_hist( as part of bug 2126091 as this is no longer used -sykrishn 29112001 */
--
PROCEDURE finp_ins_cfar_hist (
  p_person_id IN IGS_FI_FEE_AS_RT.person_id%TYPE ,
  p_course_cd IN IGS_FI_FEE_AS_RT.course_cd%TYPE ,
  p_fee_type IN IGS_FI_FEE_AS_RT.FEE_TYPE%TYPE ,
  p_start_dt IN IGS_FI_FEE_AS_RT.start_dt%TYPE ,
  p_new_end_dt IN IGS_FI_FEE_AS_RT.end_dt%TYPE ,
  p_old_end_dt IN IGS_FI_FEE_AS_RT.end_dt%TYPE ,
  p_new_location_cd IN IGS_FI_FEE_AS_RT.location_cd%TYPE ,
  p_old_location_cd IN IGS_FI_FEE_AS_RT.location_cd%TYPE ,
  p_new_attendance_type IN IGS_EN_ATD_TYPE_ALL.ATTENDANCE_TYPE%TYPE ,
  p_old_attendance_type IN IGS_EN_ATD_TYPE_ALL.ATTENDANCE_TYPE%TYPE ,
  p_new_attendance_mode IN IGS_EN_ATD_MODE_ALL.ATTENDANCE_MODE%TYPE ,
  p_old_attendance_mode IN IGS_EN_ATD_MODE_ALL.ATTENDANCE_MODE%TYPE ,
  p_new_chg_rate IN IGS_FI_FEE_AS_RT.chg_rate%TYPE ,
  p_old_chg_rate IN IGS_FI_FEE_AS_RT.chg_rate%TYPE ,
  p_new_lower_nrml_rate_ovrd_ind IN IGS_FI_FEE_AS_RT.lower_nrml_rate_ovrd_ind%TYPE ,
  p_old_lower_nrml_rate_ovrd_ind IN IGS_FI_FEE_AS_RT.lower_nrml_rate_ovrd_ind%TYPE ,
  p_new_last_updated_by IN IGS_FI_FEE_AS_RT.last_updated_by%TYPE ,
  p_old_last_updated_by IN IGS_FI_FEE_AS_RT.last_updated_by%TYPE ,
  p_new_last_update_date IN IGS_FI_FEE_AS_RT.last_update_date%TYPE ,
  p_old_last_update_date IN IGS_FI_FEE_AS_RT.last_update_date%TYPE
  );
--
PROCEDURE finp_ins_cft_hist(
  p_fee_cat IN IGS_PS_FEE_TRG.FEE_CAT%TYPE ,
  p_fee_cal_type IN IGS_PS_FEE_TRG.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_PS_FEE_TRG.fee_ci_sequence_number%TYPE ,
  p_fee_type IN IGS_PS_FEE_TRG.FEE_TYPE%TYPE ,
  p_course_cd IN IGS_PS_FEE_TRG.course_cd%TYPE ,
  p_sequence_number IN IGS_PS_FEE_TRG.sequence_number%TYPE ,
  p_new_version_number IN IGS_PS_FEE_TRG.version_number%TYPE ,
  p_old_version_number IN IGS_PS_FEE_TRG.version_number%TYPE ,
  p_new_cal_type IN IGS_PS_FEE_TRG.CAL_TYPE%TYPE ,
  p_old_cal_type IN IGS_PS_FEE_TRG.CAL_TYPE%TYPE ,
  p_new_location_cd IN IGS_PS_FEE_TRG.location_cd%TYPE ,
  p_old_location_cd IN IGS_PS_FEE_TRG.location_cd%TYPE ,
  p_new_attendance_mode IN IGS_PS_FEE_TRG.ATTENDANCE_MODE%TYPE ,
  p_old_attendance_mode IN IGS_PS_FEE_TRG.ATTENDANCE_MODE%TYPE ,
  p_new_attendance_type IN IGS_PS_FEE_TRG.ATTENDANCE_TYPE%TYPE ,
  p_old_attendance_type IN IGS_PS_FEE_TRG.ATTENDANCE_TYPE%TYPE ,
  p_new_create_dt IN IGS_PS_FEE_TRG.create_dt%TYPE ,
  p_old_create_dt IN IGS_PS_FEE_TRG.create_dt%TYPE ,
  p_new_fee_trigger_group_number IN IGS_PS_FEE_TRG.fee_trigger_group_number%TYPE ,
  p_old_fee_trigger_group_number IN IGS_PS_FEE_TRG.fee_trigger_group_number%TYPE ,
  p_new_last_updated_by IN IGS_PS_FEE_TRG.last_updated_by%TYPE ,
  p_old_last_updated_by IN IGS_PS_FEE_TRG.last_updated_by%TYPE ,
  p_new_last_update_date IN IGS_PS_FEE_TRG.last_update_date%TYPE ,
  p_old_last_update_date IN IGS_PS_FEE_TRG.last_update_date%TYPE );
--
  --PROCEDURE finp_ins_cma_hist has been obsolted since the table IGS_FI_CHG_MTH_APP was being obsoleted
  -- this procedure invoked the tbh for the history rable which also is beng obsolete
  -- bug# 2187247 (rnirwani)
--
PROCEDURE finp_ins_er_hist(
  p_fee_type IN IGS_FI_ELM_RANGE.FEE_TYPE%TYPE ,
  p_fee_cal_type IN IGS_FI_ELM_RANGE.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_FI_ELM_RANGE.fee_ci_sequence_number%TYPE ,
  p_s_relation_type IN IGS_FI_ELM_RANGE.s_relation_type%TYPE ,
  p_range_number IN IGS_FI_ELM_RANGE.range_number%TYPE ,
  p_new_fee_cat IN IGS_FI_ELM_RANGE.FEE_CAT%TYPE ,
  p_old_fee_cat IN IGS_FI_ELM_RANGE.FEE_CAT%TYPE ,
  p_new_lower_range IN IGS_FI_ELM_RANGE.lower_range%TYPE ,
  p_old_lower_range IN IGS_FI_ELM_RANGE.lower_range%TYPE ,
  p_new_upper_range IN IGS_FI_ELM_RANGE.upper_range%TYPE ,
  p_old_upper_range IN IGS_FI_ELM_RANGE.upper_range%TYPE ,
  p_new_s_chg_method_type IN IGS_FI_ELM_RANGE.s_chg_method_type%TYPE ,
  p_old_s_chg_method_type IN IGS_FI_ELM_RANGE.s_chg_method_type%TYPE ,
  p_new_last_updated_by IN IGS_FI_ELM_RANGE.last_updated_by%TYPE ,
  p_old_last_updated_by IN IGS_FI_ELM_RANGE.last_updated_by%TYPE ,
  p_new_last_update_date IN IGS_FI_ELM_RANGE.last_update_date%TYPE ,
  p_old_last_update_date IN IGS_FI_ELM_RANGE.last_update_date%TYPE );
--
PROCEDURE finp_ins_far_hist(
  p_fee_type IN IGS_FI_FEE_AS_RATE.FEE_TYPE%TYPE ,
  p_fee_cal_type IN IGS_FI_FEE_AS_RATE.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_FI_FEE_AS_RATE.fee_ci_sequence_number%TYPE ,
  p_s_relation_type IN IGS_FI_FEE_AS_RATE.s_relation_type%TYPE ,
  p_rate_number IN IGS_FI_FEE_AS_RATE.rate_number%TYPE ,
  p_new_fee_cat IN IGS_FI_FEE_AS_RATE.FEE_CAT%TYPE ,
  p_old_fee_cat IN IGS_FI_FEE_AS_RATE.FEE_CAT%TYPE ,
  p_new_location_cd IN IGS_FI_FEE_AS_RATE.location_cd%TYPE ,
  p_old_location_cd IN IGS_FI_FEE_AS_RATE.location_cd%TYPE ,
  p_new_attendance_type IN IGS_FI_FEE_AS_RATE.ATTENDANCE_TYPE%TYPE ,
  p_old_attendance_type IN IGS_FI_FEE_AS_RATE.ATTENDANCE_TYPE%TYPE ,
  p_new_attendance_mode IN IGS_FI_FEE_AS_RATE.ATTENDANCE_MODE%TYPE ,
  p_old_attendance_mode IN IGS_FI_FEE_AS_RATE.ATTENDANCE_MODE%TYPE ,
  p_new_order_of_precedence IN IGS_FI_FEE_AS_RATE.order_of_precedence%TYPE ,
  p_old_order_of_precedence IN IGS_FI_FEE_AS_RATE.order_of_precedence%TYPE ,
  p_new_govt_hecs_payment_option IN IGS_FI_FEE_AS_RATE.GOVT_HECS_PAYMENT_OPTION%TYPE ,
  p_old_govt_hecs_payment_option IN IGS_FI_FEE_AS_RATE.GOVT_HECS_PAYMENT_OPTION%TYPE ,
  p_new_govt_hecs_cntrbtn_band IN IGS_FI_FEE_AS_RATE.govt_hecs_cntrbtn_band%TYPE ,
  p_old_govt_hecs_cntrbtn_band IN IGS_FI_FEE_AS_RATE.govt_hecs_cntrbtn_band%TYPE ,
  p_new_chg_rate IN IGS_FI_FEE_AS_RATE.chg_rate%TYPE ,
  p_old_chg_rate IN IGS_FI_FEE_AS_RATE.chg_rate%TYPE ,
  p_new_unit_class IN IGS_FI_FEE_AS_RATE.unit_class%TYPE ,
  p_old_unit_class IN IGS_FI_FEE_AS_RATE.unit_class%TYPE ,
-- Added by Nishikant , to include the following five new fields for enhancement bug#1851586
  p_new_residency_status_cd IN IGS_FI_FEE_AS_RATE.residency_status_cd%TYPE DEFAULT NULL,
  p_old_residency_status_cd IN IGS_FI_FEE_AS_RATE.residency_status_cd%TYPE DEFAULT NULL,
  p_new_course_cd IN IGS_FI_FEE_AS_RATE.course_cd%TYPE DEFAULT NULL,
  p_old_course_cd IN IGS_FI_FEE_AS_RATE.course_cd%TYPE DEFAULT NULL,
  p_new_version_number IN IGS_FI_FEE_AS_RATE.version_number%TYPE DEFAULT NULL,
  p_old_version_number IN IGS_FI_FEE_AS_RATE.version_number%TYPE DEFAULT NULL,
  p_new_org_party_id IN IGS_FI_FEE_AS_RATE.org_party_id%TYPE DEFAULT NULL,
  p_old_org_party_id IN IGS_FI_FEE_AS_RATE.org_party_id%TYPE DEFAULT NULL,
  p_new_class_standing IN IGS_FI_FEE_AS_RATE.class_standing%TYPE DEFAULT NULL,
  p_old_class_standing IN IGS_FI_FEE_AS_RATE.class_standing%TYPE DEFAULT NULL,
  p_new_last_updated_by IN IGS_FI_FEE_AS_RATE.last_updated_by%TYPE DEFAULT NULL,
  p_old_last_updated_by IN IGS_FI_FEE_AS_RATE.last_updated_by%TYPE DEFAULT NULL,
  p_new_last_update_date IN IGS_FI_FEE_AS_RATE.last_update_date%TYPE DEFAULT NULL,
  p_old_last_update_date IN IGS_FI_FEE_AS_RATE.last_update_date%TYPE DEFAULT NULL,
  p_new_unit_set_cd          IN igs_fi_fee_as_rate.unit_set_cd%TYPE DEFAULT NULL,
  p_old_unit_set_cd          IN igs_fi_fee_as_rate.unit_set_cd%TYPE DEFAULT NULL,
  p_new_us_version_number    IN igs_fi_fee_as_rate.us_version_number%TYPE DEFAULT NULL,
  p_old_us_version_number    IN igs_fi_fee_as_rate.us_version_number%TYPE DEFAULT NULL,
  p_new_unit_cd    IN igs_fi_fee_as_rate.unit_cd%TYPE DEFAULT NULL,
  p_old_unit_cd    IN igs_fi_fee_as_rate.unit_cd%TYPE DEFAULT NULL,
  p_new_unit_version_number    IN igs_fi_fee_as_rate.unit_version_number%TYPE DEFAULT NULL,
  p_old_unit_version_number    IN igs_fi_fee_as_rate.unit_version_number%TYPE DEFAULT NULL,
  p_new_unit_level    IN igs_fi_fee_as_rate.unit_level%TYPE DEFAULT NULL,
  p_old_unit_level    IN igs_fi_fee_as_rate.unit_level%TYPE DEFAULT NULL,
  p_new_unit_type_id    IN igs_fi_fee_as_rate.unit_type_id%TYPE DEFAULT NULL,
  p_old_unit_type_id    IN igs_fi_fee_as_rate.unit_type_id%TYPE DEFAULT NULL,
  p_new_unit_mode    IN igs_fi_fee_as_rate.unit_mode%TYPE DEFAULT NULL,
  p_old_unit_mode    IN igs_fi_fee_as_rate.unit_mode%TYPE DEFAULT NULL

  );
--
PROCEDURE finp_ins_fcci_hist(
  p_fee_cat IN IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE ,
  p_fee_cal_type IN IGS_FI_F_CAT_CA_INST.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_FI_F_CAT_CA_INST.fee_ci_sequence_number%TYPE ,
  p_new_fee_cat_ci_status IN IGS_FI_F_CAT_CA_INST.fee_cat_ci_status%TYPE ,
  p_old_fee_cat_ci_status IN IGS_FI_F_CAT_CA_INST.fee_cat_ci_status%TYPE ,
  p_new_start_dt_alias IN IGS_FI_F_CAT_CA_INST.start_dt_alias%TYPE ,
  p_old_start_dt_alias IN IGS_FI_F_CAT_CA_INST.start_dt_alias%TYPE ,
  p_new_start_dai_sequence_num IN IGS_FI_F_CAT_CA_INST.start_dai_sequence_number%TYPE ,
  p_old_start_dai_sequence_num IN IGS_FI_F_CAT_CA_INST.start_dai_sequence_number%TYPE ,
  p_new_end_dt_alias IN IGS_FI_F_CAT_CA_INST.end_dt_alias%TYPE ,
  p_old_end_dt_alias IN IGS_FI_F_CAT_CA_INST.end_dt_alias%TYPE ,
  p_new_end_dai_sequence_num IN IGS_FI_F_CAT_CA_INST.end_dai_sequence_number%TYPE ,
  p_old_end_dai_sequence_num IN IGS_FI_F_CAT_CA_INST.end_dai_sequence_number%TYPE ,
  p_new_retro_dt_alias IN IGS_FI_F_CAT_CA_INST.retro_dt_alias%TYPE ,
  p_old_retro_dt_alias IN IGS_FI_F_CAT_CA_INST.retro_dt_alias%TYPE ,
  p_new_retro_dai_sequence_num IN IGS_FI_F_CAT_CA_INST.retro_dai_sequence_number%TYPE ,
  p_old_retro_dai_sequence_num IN IGS_FI_F_CAT_CA_INST.retro_dai_sequence_number%TYPE ,
  p_new_last_updated_by IN IGS_FI_F_CAT_CA_INST.last_updated_by%TYPE ,
  p_old_last_updated_by IN IGS_FI_F_CAT_CA_INST.last_updated_by%TYPE ,
  p_new_last_update_date IN IGS_FI_F_CAT_CA_INST.last_update_date%TYPE ,
  p_old_last_update_date IN IGS_FI_F_CAT_CA_INST.last_update_date%TYPE );
--
PROCEDURE finp_ins_fcfl_hist(
  p_fee_cat IN IGS_FI_FEE_CAT_ALL.FEE_CAT%TYPE ,
  p_fee_cal_type IN IGS_CA_TYPE.CAL_TYPE%TYPE ,
  p_fee_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.FEE_TYPE%TYPE ,
  p_new_fee_liability_status IN VARCHAR2 ,
  p_old_fee_liability_status IN VARCHAR2 ,
  p_new_start_dt_alias IN IGS_CA_DA.DT_ALIAS%TYPE ,
  p_old_start_dt_alias IN IGS_CA_DA.DT_ALIAS%TYPE ,
  p_new_start_dai_sequence_num IN IGS_CA_DA_INST.sequence_number%TYPE ,
  p_old_start_dai_sequence_num IN IGS_CA_DA_INST.sequence_number%TYPE ,
  p_new_s_chg_method_type IN FND_LOOKUP_VALUES.lookup_code%TYPE ,
  p_old_s_chg_method_type IN FND_LOOKUP_VALUES.lookup_code%TYPE ,
  p_new_rul_sequence_number IN IGS_RU_RULE.sequence_number%TYPE ,
  p_old_rul_sequence_number IN IGS_RU_RULE.sequence_number%TYPE ,
  p_new_last_updated_by IN IGS_FI_F_CAT_FEE_LBL_ALL.last_updated_by%TYPE ,
  p_old_last_updated_by IN IGS_FI_F_CAT_FEE_LBL_ALL.last_updated_by%TYPE ,
  p_new_last_update_date IN IGS_FI_F_CAT_FEE_LBL_ALL.last_update_date%TYPE ,
  p_old_last_update_date IN IGS_FI_F_CAT_FEE_LBL_ALL.last_update_date%TYPE );
--
/* procedure finp_ins_fdf_hist is obsolete as part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390) */
--
/* Obseleted the procedure finp_ins_fe_hist( as part of bug 2126091 as this is no longer used -sykrishn 29112001 */
--
--Removed procedure finp_ins_fps_hist as part of SFCR005- Clean Up Build. Bug#2531390.

--
PROCEDURE finp_ins_frtns_hist(
  p_fee_cal_type IN IGS_FI_FEE_RET_SCHD.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_FI_FEE_RET_SCHD.fee_ci_sequence_number%TYPE ,
  p_s_relation_type IN IGS_FI_FEE_RET_SCHD.s_relation_type%TYPE ,
  p_sequence_number IN IGS_FI_FEE_RET_SCHD.sequence_number%TYPE ,
  p_new_fee_type IN IGS_FI_FEE_RET_SCHD.FEE_TYPE%TYPE ,
  p_old_fee_type IN IGS_FI_FEE_RET_SCHD.FEE_TYPE%TYPE ,
  p_new_fee_cat IN IGS_FI_FEE_RET_SCHD.FEE_CAT%TYPE ,
  p_old_fee_cat IN IGS_FI_FEE_RET_SCHD.FEE_CAT%TYPE ,
  p_new_schedule_number IN IGS_FI_FEE_RET_SCHD.schedule_number%TYPE ,
  p_old_schedule_number IN IGS_FI_FEE_RET_SCHD.schedule_number%TYPE ,
  p_new_dt_alias IN IGS_FI_FEE_RET_SCHD.DT_ALIAS%TYPE ,
  p_old_dt_alias IN IGS_FI_FEE_RET_SCHD.DT_ALIAS%TYPE ,
  p_new_dai_sequence_number IN IGS_FI_FEE_RET_SCHD.dai_sequence_number%TYPE ,
  p_old_dai_sequence_number IN IGS_FI_FEE_RET_SCHD.dai_sequence_number%TYPE ,
  p_new_retention_percentage IN IGS_FI_FEE_RET_SCHD.retention_percentage%TYPE ,
  p_old_retention_percentage IN IGS_FI_FEE_RET_SCHD.retention_percentage%TYPE ,
  p_new_retention_amount IN IGS_FI_FEE_RET_SCHD.retention_amount%TYPE ,
  p_old_retention_amount IN IGS_FI_FEE_RET_SCHD.retention_amount%TYPE ,
  p_new_last_updated_by IN IGS_FI_FEE_RET_SCHD.last_updated_by%TYPE ,
  p_old_last_updated_by IN IGS_FI_FEE_RET_SCHD.last_updated_by%TYPE ,
  p_new_last_update_date IN IGS_FI_FEE_RET_SCHD.last_update_date%TYPE ,
  p_old_last_update_date IN IGS_FI_FEE_RET_SCHD.last_update_date%TYPE );
--
PROCEDURE finp_ins_ftci_hist(
  p_fee_type IN IGS_FI_F_TYP_CA_INST_ALL.FEE_TYPE%TYPE ,
  p_fee_cal_type IN IGS_FI_F_TYP_CA_INST_ALL.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_FI_F_TYP_CA_INST_ALL.fee_ci_sequence_number%TYPE ,
  p_new_fee_type_ci_status IN IGS_FI_F_TYP_CA_INST_ALL.fee_type_ci_status%TYPE ,
  p_old_fee_type_ci_status IN IGS_FI_F_TYP_CA_INST_ALL.fee_type_ci_status%TYPE ,
  p_new_start_dt_alias IN IGS_FI_F_TYP_CA_INST_ALL.start_dt_alias%TYPE ,
  p_old_start_dt_alias IN IGS_FI_F_TYP_CA_INST_ALL.start_dt_alias%TYPE ,
  p_new_start_dai_sequence_num IN IGS_FI_F_TYP_CA_INST_ALL.start_dai_sequence_number%TYPE ,
  p_old_start_dai_sequence_num IN IGS_FI_F_TYP_CA_INST_ALL.start_dai_sequence_number%TYPE ,
  p_new_end_dt_alias IN IGS_FI_F_TYP_CA_INST_ALL.end_dt_alias%TYPE ,
  p_old_end_dt_alias IN IGS_FI_F_TYP_CA_INST_ALL.end_dt_alias%TYPE ,
  p_new_end_dai_sequence_number IN IGS_FI_F_TYP_CA_INST_ALL.end_dai_sequence_number%TYPE ,
  p_old_end_dai_sequence_number IN IGS_FI_F_TYP_CA_INST_ALL.end_dai_sequence_number%TYPE ,
  p_new_retro_dt_alias IN IGS_FI_F_TYP_CA_INST_ALL.retro_dt_alias%TYPE ,
  p_old_retro_dt_alias IN IGS_FI_F_TYP_CA_INST_ALL.retro_dt_alias%TYPE ,
  p_new_retro_dai_sequence_num IN IGS_FI_F_TYP_CA_INST_ALL.retro_dai_sequence_number%TYPE ,
  p_old_retro_dai_sequence_num IN IGS_FI_F_TYP_CA_INST_ALL.retro_dai_sequence_number%TYPE ,
  p_new_s_chg_method_type IN IGS_FI_F_TYP_CA_INST_ALL.s_chg_method_type%TYPE ,
  p_old_s_chg_method_type IN IGS_FI_F_TYP_CA_INST_ALL.s_chg_method_type%TYPE ,
  p_new_rul_sequence_number IN IGS_FI_F_TYP_CA_INST_ALL.rul_sequence_number%TYPE ,
  p_old_rul_sequence_number IN IGS_FI_F_TYP_CA_INST_ALL.rul_sequence_number%TYPE ,
  p_new_last_updated_by IN IGS_FI_F_TYP_CA_INST_ALL.last_updated_by%TYPE ,
  p_old_last_updated_by IN IGS_FI_F_TYP_CA_INST_ALL.last_updated_by%TYPE ,
  p_new_last_update_date IN IGS_FI_F_TYP_CA_INST_ALL.last_update_date%TYPE ,
  p_old_last_update_date IN IGS_FI_F_TYP_CA_INST_ALL.last_update_date%TYPE ,
-- Added by Nishikant , to include the following new field for enhancement bug#1851586
  p_new_initial_default_amount IN IGS_FI_F_TYP_CA_INST_ALL.initial_default_amount%TYPE DEFAULT NULL,
  p_old_initial_default_amount IN IGS_FI_F_TYP_CA_INST_ALL.initial_default_amount%TYPE DEFAULT NULL,
  --Added by svuppala,as a part of bug:4295379 New field "nonzero_billable_cp_flag"
  p_new_nonzero_billable_cp_flag IN IGS_FI_F_TYP_CA_INST_ALL.nonzero_billable_cp_flag%TYPE DEFAULT NULL,
  p_old_nonzero_billable_cp_flag IN IGS_FI_F_TYP_CA_INST_ALL.nonzero_billable_cp_flag%TYPE DEFAULT NULL);
--
PROCEDURE finp_ins_ft_hist(
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.FEE_TYPE%TYPE ,
  p_new_s_fee_type IN IGS_FI_FEE_TYPE_ALL.s_fee_type%TYPE ,
  p_old_s_fee_type IN IGS_FI_FEE_TYPE_ALL.s_fee_type%TYPE ,
  p_new_s_fee_trigger_cat IN IGS_FI_FEE_TYPE_ALL.s_fee_trigger_cat%TYPE ,
  p_old_s_fee_trigger_cat IN IGS_FI_FEE_TYPE_ALL.s_fee_trigger_cat%TYPE ,
  p_new_description IN IGS_FI_FEE_TYPE_ALL.description%TYPE ,
  p_old_description IN IGS_FI_FEE_TYPE_ALL.description%TYPE ,
  p_new_optional_payment_ind IN IGS_FI_FEE_TYPE_ALL.optional_payment_ind%TYPE ,
  p_old_optional_payment_ind IN IGS_FI_FEE_TYPE_ALL.optional_payment_ind%TYPE ,
  p_new_closed_ind IN IGS_FI_FEE_TYPE_ALL.closed_ind%TYPE ,
  p_old_closed_ind IN IGS_FI_FEE_TYPE_ALL.closed_ind%TYPE ,
  p_new_fee_class               IN IGS_FI_FEE_TYPE_ALL.fee_class%TYPE,    --for Bug 2175865 by vvutukur
  p_old_fee_class               IN IGS_FI_FEE_TYPE_ALL.fee_class%TYPE,    --for Bug 2175865 by vvutukur
  p_new_designated_payment_flag IN igs_fi_fee_type_all.designated_payment_flag%TYPE,
  p_old_designated_payment_flag IN igs_fi_fee_type_all.designated_payment_flag%TYPE,
  p_new_last_updated_by IN IGS_FI_FEE_TYPE_ALL.last_updated_by%TYPE ,
  p_old_last_updated_by IN IGS_FI_FEE_TYPE_ALL.last_updated_by%TYPE ,
  p_new_last_update_date IN IGS_FI_FEE_TYPE_ALL.last_update_date%TYPE ,
  p_old_last_update_date IN IGS_FI_FEE_TYPE_ALL.last_update_date%TYPE ,
  p_new_comments IN IGS_FI_FEE_TYPE_ALL.comments%TYPE ,
  p_old_comments IN IGS_FI_FEE_TYPE_ALL.comments%TYPE );

--
PROCEDURE finp_ins_uft_hist(
  p_fee_cat IN IGS_FI_UNIT_FEE_TRG.FEE_CAT%TYPE ,
  p_fee_cal_type IN IGS_FI_UNIT_FEE_TRG.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_FI_UNIT_FEE_TRG.fee_ci_sequence_number%TYPE ,
  p_fee_type IN IGS_FI_UNIT_FEE_TRG.FEE_TYPE%TYPE ,
  p_unit_cd IN IGS_FI_UNIT_FEE_TRG.unit_cd%TYPE ,
  p_sequence_number IN IGS_FI_UNIT_FEE_TRG.sequence_number%TYPE ,
  p_new_version_number IN IGS_FI_UNIT_FEE_TRG.version_number%TYPE ,
  p_old_version_number IN IGS_FI_UNIT_FEE_TRG.version_number%TYPE ,
  p_new_cal_type IN IGS_FI_UNIT_FEE_TRG.CAL_TYPE%TYPE ,
  p_old_cal_type IN IGS_FI_UNIT_FEE_TRG.CAL_TYPE%TYPE ,
  p_new_ci_sequence_number IN IGS_FI_UNIT_FEE_TRG.ci_sequence_number%TYPE ,
  p_old_ci_sequence_number IN IGS_FI_UNIT_FEE_TRG.ci_sequence_number%TYPE ,
  p_new_location_cd IN IGS_FI_UNIT_FEE_TRG.location_cd%TYPE ,
  p_old_location_cd IN IGS_FI_UNIT_FEE_TRG.location_cd%TYPE ,
  p_new_unit_class IN IGS_FI_UNIT_FEE_TRG.UNIT_CLASS%TYPE ,
  p_old_unit_class IN IGS_FI_UNIT_FEE_TRG.UNIT_CLASS%TYPE ,
  p_new_create_dt IN IGS_FI_UNIT_FEE_TRG.create_dt%TYPE ,
  p_old_create_dt IN IGS_FI_UNIT_FEE_TRG.create_dt%TYPE ,
  p_new_fee_trigger_group_number IN IGS_FI_UNIT_FEE_TRG.fee_trigger_group_number%TYPE ,
  p_old_fee_trigger_group_number IN IGS_FI_UNIT_FEE_TRG.fee_trigger_group_number%TYPE ,
  p_new_last_updated_by IN IGS_FI_UNIT_FEE_TRG.last_updated_by%TYPE ,
  p_old_last_updated_by IN IGS_FI_UNIT_FEE_TRG.last_updated_by%TYPE ,
  p_new_last_update_date IN IGS_FI_UNIT_FEE_TRG.last_update_date%TYPE ,
  p_old_last_update_date IN IGS_FI_UNIT_FEE_TRG.last_update_date%TYPE );
--
-- New function as part of Bug 2324088 - SYkrishn
FUNCTION finp_validate_ccid (p_ccid  IN   igs_fi_cr_activities.dr_gl_ccid%TYPE) RETURN BOOLEAN;
 -- New function as part of Bug 2324088 - SYkrishn
END IGS_FI_GEN_002;

 

/
