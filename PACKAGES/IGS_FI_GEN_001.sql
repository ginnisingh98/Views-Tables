--------------------------------------------------------
--  DDL for Package IGS_FI_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSFI01S.pls 120.0 2005/06/01 20:29:16 appldev noship $ */

  /******************************************************************
  Change History
  Who		 When		 What
  uudayapr       06-Jan-2004     Enh#3167098 Added the Added the function CHECK_STDNT_PRG_ATT_LIABLE .
  vvutukur       1-Dec-2002      Enh#2584986.Removed references to igs_fi_fee_pay_schd, which is an obsoleted object.
  sarakshi       23-sep-2002     Enh#2564643,removed parameter p_subaccount_id from finp_get_total_planned_credits
  SMVK           13-Sep-2002     Bug#2531390. Restored the functions finp_get_fps_end_dt,FINP_GET_FDF_END_DT,
                                 FINP_GET_FDF_ST_DT,finp_get_fps_start_dt, which are obsolete as the part of same bug.
  vvutukur       02-Sep-2002     Bug#2531390. Removed the function finp_get_fps_end_dt.
  smvk           28-Aug-2002     Bug#2531390.Removed the functions FINP_GET_FDF_END_DT, FINP_GET_FDF_ST_DT (SFCR005_Cleanup_Build)
  vvutukur       26-Aug-2002     Bug#2531390.Removed the function finp_get_fps_start_dt.
  jbegum         26-Aug-2002     As part of Enh Bug#2531390 the procedure finp_get_overdue_dtl was removed.
  rnirwani       25-Apr-02       Obsoleting the procedure finp_get_dj_totals,
                                   since this is not being used.
                                 Bug# 2329407

 SYkrishn         02-APR-2002    Bug 2293676 - Added functions finp_get_planned_credits_ind and
                                       finp_get_total_planned_credits
 schodava	 18-Jan-2002	 Enh # 2187247
				 Added functions finp_get_lfci_reln
				 and finp_chk_lfci_reln
  ******************************************************************/
--
FUNCTION check_stdnt_prg_att_liable(
            p_n_person_id IN PLS_INTEGER,
            p_v_course_cd IN VARCHAR2,
            p_n_course_version IN PLS_INTEGER,
            p_v_fee_cat IN VARCHAR2,
            p_v_fee_type IN VARCHAR2,
            p_v_s_fee_trigger_cat IN VARCHAR2,
            p_v_fee_cal_type IN VARCHAR2,
            p_n_fee_ci_seq_number IN PLS_INTEGER,
            p_n_adm_appl_number IN NUMBER,
            p_v_adm_nom_course_cd IN VARCHAR2,
            p_n_adm_seq_number IN NUMBER,
            p_d_commencement_dt IN DATE,
            p_d_disc_dt IN DATE,
            p_v_cal_type IN VARCHAR2,
            p_v_location_cd IN VARCHAR2,
            p_v_attendance_mode IN VARCHAR2,
            p_v_attendance_type IN VARCHAR2
) RETURN VARCHAR2;
--
FUNCTION finp_get_currency(
  p_fee_cal_type IN IGS_CA_TYPE.CAL_TYPE%TYPE ,
  p_fee_ci_sequence_num IN igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE ,
  p_s_relation_type IN VARCHAR2,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.FEE_TYPE%TYPE ,
  p_fee_category IN IGS_FI_FEE_CAT_ALL.FEE_CAT%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(finp_get_currency,WNDS);
--
--
FUNCTION FINP_GET_FAS_MAN_IND(
  p_person_id IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE ,
  p_transaction_cat IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(FINP_GET_FAS_MAN_IND,WNDS);
--
FUNCTION FINP_GET_FCFL_DAI(
  p_dt_alias_column_name IN VARCHAR2 ,
  p_dai_seq_num_column_name IN VARCHAR2 ,
  p_get_column_name IN VARCHAR2 ,
  p_fee_cat IN IGS_FI_F_CAT_FEE_LBL_ALL.FEE_CAT%TYPE ,
  p_fee_cal_type IN IGS_FI_F_CAT_FEE_LBL_ALL.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_FI_F_CAT_FEE_LBL_ALL.fee_ci_sequence_number%TYPE ,
  p_fee_type IN IGS_FI_F_CAT_FEE_LBL_ALL.FEE_TYPE%TYPE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(FINP_GET_FCFL_DAI,WNDS, WNPS);
--
FUNCTION finp_get_fdf_end_dt(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_override_formula IN NUMBER ,
  p_fee_cat IN VARCHAR2 )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(finp_get_fdf_end_dt,WNDS,WNPS);
--
FUNCTION finp_get_fdf_st_dt(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_override_formula IN NUMBER ,
  p_fee_cat IN VARCHAR2 )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(finp_get_fdf_st_dt,WNDS,WNPS);
--
FUNCTION FINP_GET_FEE_TRIGGER(
  p_fee_cat IN IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE ,
  p_fee_cal_type IN IGS_FI_F_CAT_CA_INST.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_FI_F_CAT_CA_INST.fee_ci_sequence_number%TYPE ,
  p_fee_type IN IGS_FI_F_CAT_FEE_LBL_ALL.FEE_TYPE%TYPE ,
  p_s_fee_trigger_cat IN IGS_FI_FEE_TYPE_ALL.s_fee_trigger_cat%TYPE ,
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_version_number IN IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_cal_type IN IGS_EN_STDNT_PS_ATT_ALL.CAL_TYPE%TYPE ,
  p_location_cd IN IGS_EN_STDNT_PS_ATT_ALL.location_cd%TYPE ,
  p_attendance_mode IN IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_MODE%TYPE ,
  p_attendance_type IN IGS_EN_STDNT_PS_ATT_ALL.ATTENDANCE_TYPE%TYPE )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(FINP_GET_FEE_TRIGGER,WNDS,WNPS);
--
FUNCTION finp_get_fps_end_dt(
  p_fee_cal_type IN IGS_FI_F_TYP_CA_INST_ALL.fee_cal_type%TYPE,
  p_fee_ci_sequence_num IN IGS_FI_F_TYP_CA_INST_ALL.fee_ci_sequence_number%TYPE,
  p_s_relation_type IN VARCHAR2 ,
  p_fee_type IN IGS_FI_F_TYP_CA_INST_ALL.FEE_TYPE%TYPE,
  p_fee_cat IN IGS_FI_FEE_CAT_ALL.FEE_CAT%TYPE  ,
  p_schedule_number IN NUMBER,
  p_dt_alias IN  IGS_FI_F_TYP_CA_INST_ALL.START_DT_ALIAS%TYPE,
  p_dai_sequence_num IN NUMBER )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(finp_get_fps_end_dt,WNDS);
--
FUNCTION finp_get_fps_start_dt(
  p_fee_cal_type IN IGS_FI_F_TYP_CA_INST_ALL.fee_cal_type%TYPE,
  p_fee_ci_sequence_num IN IGS_FI_F_TYP_CA_INST_ALL.fee_ci_sequence_number%TYPE,
  p_s_relation_type IN VARCHAR2 ,
  p_fee_type IN IGS_FI_F_TYP_CA_INST_ALL.FEE_TYPE%TYPE,
  p_fee_cat IN IGS_FI_FEE_CAT_ALL.FEE_CAT%TYPE,
  p_schedule_number IN NUMBER,
  p_dt_alias IN IGS_FI_F_TYP_CA_INST_ALL.START_DT_ALIAS%TYPE,
  p_dai_sequence_num IN NUMBER )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(finp_get_fps_start_dt,WNDS,WNPS);

--
FUNCTION finp_get_frtns_end_dt(
  p_fee_cal_type IN IGS_FI_FEE_RET_SCHD.fee_cal_type%TYPE ,
  p_fee_ci_sequence_num IN IGS_FI_FEE_RET_SCHD.fee_ci_sequence_number%TYPE ,
  p_s_relation_type IN IGS_FI_FEE_RET_SCHD.s_relation_type%TYPE ,
  p_fee_type IN IGS_FI_FEE_RET_SCHD.FEE_TYPE%TYPE ,
  p_fee_cat IN IGS_FI_FEE_RET_SCHD.FEE_CAT%TYPE ,
  p_dt_alias IN IGS_FI_FEE_RET_SCHD.DT_ALIAS%TYPE ,
  p_dai_sequence_num IN NUMBER )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(finp_get_frtns_end_dt,WNDS);
--
FUNCTION finp_get_hecs_amt_pd(
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(finp_get_hecs_amt_pd,WNDS);
--
FUNCTION finp_get_hecs_fee(
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(finp_get_hecs_fee,WNDS);
--
FUNCTION finp_get_hecs_pymnt_optn(
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_effective_dt IN DATE ,
  p_fee_cal_type IN IGS_CA_INST_ALL.CAL_TYPE%TYPE ,
  p_fee_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_start_dt_alias IN IGS_FI_F_TYP_CA_INST_ALL.start_dt_alias%TYPE ,
  p_start_dai_sequence_number IN IGS_FI_F_TYP_CA_INST_ALL.start_dai_sequence_number%TYPE ,
  p_end_dt_alias IN IGS_FI_F_TYP_CA_INST_ALL.end_dt_alias%TYPE ,
  p_end_dai_sequence_number IN IGS_FI_F_TYP_CA_INST_ALL.end_dai_sequence_number%TYPE )
RETURN varchar2;
PRAGMA RESTRICT_REFERENCES(finp_get_hecs_pymnt_optn,WNDS,WNPS);

--
FUNCTION finp_get_tuition_fee(
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(finp_get_tuition_fee,WNDS);
--
FUNCTION finp_get_lfci_reln(
  p_cal_type			IN igs_ca_inst.cal_type%TYPE,
  p_ci_sequence_number		IN igs_ca_inst.sequence_number%TYPE,
  p_cal_category		IN igs_ca_type.s_cal_cat%TYPE,
  p_ret_cal_type		OUT NOCOPY igs_ca_inst.cal_type%TYPE,
  p_ret_ci_sequence_number	OUT NOCOPY igs_ca_inst.sequence_number%TYPE,
  p_message_name		OUT NOCOPY FND_NEW_MESSAGES.MESSAGE_NAME%TYPE)
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(finp_get_lfci_reln,WNDS);
--
FUNCTION finp_chk_lfci_reln(
  p_cal_type			IN igs_ca_inst.cal_type%TYPE,
  p_ci_sequence_number		IN igs_ca_inst.sequence_number%TYPE,
  p_cal_category		IN igs_ca_type.s_cal_cat%TYPE)
  RETURN VARCHAR2;
--
FUNCTION finp_get_planned_credits_ind(
  p_message_name   OUT NOCOPY fnd_new_messages.message_name%TYPE)
  RETURN VARCHAR2;
--
FUNCTION finp_get_total_planned_credits(
  p_person_id IN igs_fi_parties_v.person_id%TYPE,
  p_start_date IN DATE,
  p_end_date IN DATE,
  p_message_name  OUT NOCOPY fnd_new_messages.message_name%TYPE)
  RETURN NUMBER;

END IGS_FI_GEN_001 ;

 

/
