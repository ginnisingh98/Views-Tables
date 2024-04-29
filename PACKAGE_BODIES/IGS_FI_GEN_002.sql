--------------------------------------------------------
--  DDL for Package Body IGS_FI_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GEN_002" AS
/* $Header: IGSFI02B.pls 120.2 2005/07/08 06:05:10 appldev ship $ */
-- HISTORY
--Who           When          What
--svuppala      31-MAY-2005   Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
--                            Unit Version and Unit Level
-- svuppala     13-Apr-2005   Bug 4297359 - ER REGISTRATION FEE ISSUE - ASSESSED TO STUDENTS WITH NO LOAD
--                            Modifications to reflect the data model changes (NONZERO_BILLABLE_CP_FLAG) in
--                            IGS_FI_FEE_TYPE_CI_H_ALL
--pathipat      09-Sep-2003   Enh 3108052 - Add Unit Sets to Rate Table
--                            Added 4 new params for unit_set_cd and us_version_number in procedure finp_ins_far_hist()
--shtatiko      30-MAY-2003   Enh# 2831582, Added new column designated_payment_flag. As an impact modified finp_ins_ft_hist.
-- npalanis    23-OCT-2002  Bug : 2608360
--                          p_new and p_old residency_status_id column is changed to p_residency_status_cd of
--                          datatype residency_status_cd in igs_fi_fee_as_rate table.
--vvutukur      13-Sep-2002   Enh#2564643.Modifications done in procedure finp_ins_ft_hist.
--smvk          28-Aug-2002   Procedure finp_ins_fdf_hist is obsolete as part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
--vvutukur      28-Aug-2002   Bug#2531390.Removed the procedure finp_ins_fps_hist.
--jbegum        26-Aug-2002   As part of Enh Bug#2531390 the procedure finp_ins_pps_hist was removed.
--vvutukur      18-Jul-2002   Bug#2425767.Removed p_new_deduction_amount,p_old_deduction_amount parameters and
--                            its references from procedure finp_ins_frtns_hist.Removed p_new_payment_hierarchy_rank,
--                            p_old_payment_hierarchy_rank and its references from procedures finp_ins_fcfl_hist and
--                            finp_ins_ftci_hist.
--vchappid      26-Apr-2002   Bug#2329407, removed the parameters fin_cal_type, fin_ci_sequence_number, account_cd from
--                            the procedure finp_ins_ftci_hist
--rnirwani      18-Jan-2002   Obsolete procedure finp_ins_sma_hist (2187247)
--masehgal      16-Jan-2002   ENH # 2170429
--                            Obsoletion of SPONSOR_CD,SPONSORED_AMOUNT
--vvutukur      11-Jan-2002   added new columns in finp_ins_ft_hist
--                            procedure as part of Bug 2175865
/* Obseleted the procedure finp_ins_fe_hist( as part of bug 2126091 as this is no longer used -sykrishn 29112001 */
PROCEDURE finp_ins_cfar_hist(
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
  )
AS
	gv_other_detail		VARCHAR2(255);
BEGIN
DECLARE
      X_ROWID                VARCHAR2(25);
	r_cfarh			IGS_FI_FEE_AS_RT_HT%ROWTYPE;
	v_create_history		BOOLEAN := FALSE;
        l_n_org_id              IGS_FI_FEE_AS_RT_HT.org_id%TYPE := igs_ge_gen_003.get_org_id;
BEGIN
	-- Create a history for a IGS_FI_FEE_AS_RT record.
	-- Check if any of the non-primary key fields have been changed
	-- and set the flag v_create_history to indicate so.
	IF NVL(p_new_end_dt, igs_ge_date.igsdate('1000/01/01')) <>
	     NVL(p_old_end_dt, igs_ge_date.igsdate('1000/01/01'))  THEN
		r_cfarh.end_dt := NVL(p_old_end_dt , NULL);
		v_create_history := TRUE;
	END IF;
	IF  p_new_chg_rate <> p_old_chg_rate THEN
		r_cfarh.chg_rate := p_old_chg_rate;
		v_create_history := TRUE;
	END IF;
	IF  p_new_lower_nrml_rate_ovrd_ind <> p_old_lower_nrml_rate_ovrd_ind THEN
		r_cfarh.lower_nrml_rate_ovrd_ind := p_old_lower_nrml_rate_ovrd_ind;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_location_cd, 'NULL') <> NVL(p_old_location_cd, 'NULL') THEN
		r_cfarh.location_cd := p_old_location_cd;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_attendance_type, 'NULL') <>
					NVL(p_old_attendance_type, 'NULL') THEN
		r_cfarh.ATTENDANCE_TYPE := p_old_attendance_type;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_attendance_mode, 'NULL') <>
					NVL(p_old_attendance_mode, 'NULL') THEN
		r_cfarh.ATTENDANCE_MODE := p_old_attendance_mode;
		v_create_history := TRUE;
	END IF;
	-- Create a history record if a column has changed value
	IF v_create_history = TRUE THEN
		r_cfarh.person_id :=  p_person_id;
		r_cfarh.course_cd :=  p_course_cd;
		r_cfarh.FEE_TYPE :=  p_fee_type;
		r_cfarh.start_dt :=  p_start_dt;
		r_cfarh.hist_start_dt := p_old_last_update_date;
		r_cfarh.hist_end_dt := p_new_last_update_date;
		r_cfarh.hist_who := p_old_last_updated_by;
    IGS_FI_FEE_AS_RT_HT_PKG.INSERT_ROW(
                    X_ROWID => X_ROWID,
                    X_person_id => r_cfarh.person_id,
					X_course_cd => r_cfarh.course_cd,
					X_FEE_TYPE => r_cfarh.FEE_TYPE,
					X_start_dt => r_cfarh.start_dt,
					X_hist_start_dt => r_cfarh.hist_start_dt,
					X_hist_end_dt => r_cfarh.hist_end_dt,
					X_hist_who => r_cfarh.hist_who,
					X_end_dt => r_cfarh.end_dt,
					X_location_cd => r_cfarh.location_cd,
					X_ATTENDANCE_TYPE => r_cfarh.ATTENDANCE_TYPE,
					X_ATTENDANCE_MODE => r_cfarh.ATTENDANCE_MODE,
					X_chg_rate => r_cfarh.chg_rate,
					X_lower_nrml_rate_ovrd_ind => r_cfarh.lower_nrml_rate_ovrd_ind,
                                        X_MODE => 'R',
                                        x_org_id => l_n_org_id);
	END IF;
END;

EXCEPTION
WHEN OTHERS THEN
FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
FND_MESSAGE.SET_TOKEN('NAME','IGS_FI_GEN_002.FINP_INS_CFAR_HIST');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END FINP_INS_CFAR_HIST;
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
  p_new_fee_trigger_group_number IN IGS_PS_FEE_TRG.fee_trigger_group_number%TYPE,
  p_old_fee_trigger_group_number IN IGS_PS_FEE_TRG.fee_trigger_group_number%TYPE,
  p_new_last_updated_by IN IGS_PS_FEE_TRG.last_updated_by%TYPE ,
  p_old_last_updated_by IN IGS_PS_FEE_TRG.last_updated_by%TYPE ,
  p_new_last_update_date IN IGS_PS_FEE_TRG.last_update_date%TYPE ,
  p_old_last_update_date IN IGS_PS_FEE_TRG.last_update_date%TYPE )
AS
	gv_other_detail		VARCHAR2(255);
BEGIN
DECLARE
      X_ROWID                 VARCHAR2(25);
	r_cfth			IGS_PS_FEE_TRG_HIST%ROWTYPE;
	v_create_history		BOOLEAN := FALSE;
        l_n_org_id              IGS_PS_FEE_TRG_HIST.org_id%TYPE := igs_ge_gen_003.get_org_id;
BEGIN
	-- Create a history for a IGS_PS_FEE_TRG record.
	-- Check if any of the non-primary key fields have been changed
	-- and set the flag v_create_history to indicate so.
	IF NVL(p_new_version_number, 0) <> NVL(p_old_version_number, 0)  THEN
		r_cfth.version_number := p_old_version_number;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_cal_type, 'NULL') <> NVL(p_old_cal_type, 'NULL')  THEN
		r_cfth.CAL_TYPE := p_old_cal_type;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_location_cd, 'NULL') <> NVL(p_old_location_cd, 'NULL')  THEN
		r_cfth.location_cd := p_old_location_cd;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_attendance_mode, 'NULL') <>
			NVL(p_old_attendance_mode, 'NULL') THEN
		r_cfth.ATTENDANCE_MODE := p_old_attendance_mode;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_attendance_type, 'NULL') <>
			NVL(p_old_attendance_type, 'NULL') THEN
		r_cfth.ATTENDANCE_TYPE := p_old_attendance_type;
		v_create_history := TRUE;
	END IF;
	IF  p_new_create_dt <> p_old_create_dt THEN
		r_cfth.create_dt := p_old_create_dt;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_fee_trigger_group_number, 0) <>
			NVL(p_old_fee_trigger_group_number, 0)  THEN
		r_cfth.fee_trigger_group_number := p_old_fee_trigger_group_number;
		v_create_history := TRUE;
	END IF;
	-- Create a history record if a column has changed value
	IF v_create_history = TRUE THEN
		r_cfth.FEE_CAT :=  p_fee_cat;
		r_cfth.fee_cal_type :=  p_fee_cal_type;
		r_cfth.fee_ci_sequence_number :=  p_fee_ci_sequence_number;
		r_cfth.FEE_TYPE :=  p_fee_type;
		r_cfth.course_cd :=  p_course_cd;
		r_cfth.sequence_number :=  p_sequence_number;
		r_cfth.hist_start_dt := p_old_last_update_date;
		r_cfth.hist_end_dt := p_new_last_update_date;
		r_cfth.hist_who := p_old_last_updated_by;
	  IGS_PS_FEE_TRG_HIST_PKG.INSERT_ROW(
                    X_ROWID => X_ROWID,
                    X_FEE_CAT => r_cfth.FEE_CAT,
					X_fee_cal_type => r_cfth.fee_cal_type,
					X_fee_ci_sequence_number => r_cfth.fee_ci_sequence_number,
					X_FEE_TYPE => r_cfth.FEE_TYPE,
					X_course_cd => r_cfth.course_cd,
					X_sequence_number => r_cfth.sequence_number,
					X_hist_start_dt => r_cfth.hist_start_dt,
					X_hist_end_dt => r_cfth.hist_end_dt,
					X_hist_who => r_cfth.hist_who,
					X_version_number => r_cfth.version_number,
					X_CAL_TYPE => r_cfth.CAL_TYPE,
					X_location_cd => r_cfth.location_cd,
					X_ATTENDANCE_MODE => r_cfth.ATTENDANCE_MODE,
					X_ATTENDANCE_TYPE => r_cfth.ATTENDANCE_TYPE,
					X_create_dt => r_cfth.create_dt,
					X_fee_trigger_group_number => r_cfth.fee_trigger_group_number,
                                        X_MODE => 'R',
                                        x_org_id => l_n_org_id);
	END IF;
END;
EXCEPTION
WHEN OTHERS THEN
FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
FND_MESSAGE.SET_TOKEN('NAME','IGS_FI_GEN_002.FINP_INS_CFT_HIST');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END finp_ins_cft_hist;
--
  -- PROCEDURE finp_ins_cma_hist has been obsoleted since table igs_fi_chg_mth_app was being made obsolte
 -- this procedure invoked the TBH for the history table which was also being obsolete
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
  p_old_last_update_date IN IGS_FI_ELM_RANGE.last_update_date%TYPE )
AS
	gv_other_detail		VARCHAR2(255);
BEGIN
DECLARE
      X_ROWID           VARCHAR2(25);
	r_erh			IGS_FI_ELM_RANGE_H%ROWTYPE;
	v_create_history		BOOLEAN := FALSE;
        l_n_org_id              IGS_FI_ELM_RANGE_H.org_id%TYPE := igs_ge_gen_003.get_org_id;
BEGIN
	-- Create a history for a IGS_FI_ELM_RANGE record.
	-- Check if any of the non-primary key fields have been changed
	-- and set the flag v_create_history to indicate so.
	IF NVL(p_new_fee_cat, 'NULL') <> NVL(p_old_fee_cat, 'NULL')  THEN
		r_erh.FEE_CAT := p_old_fee_cat;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_lower_range, 0) <> NVL(p_old_lower_range, 0)  THEN
		r_erh.lower_range := p_old_lower_range;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_upper_range, 0) <> NVL(p_old_upper_range, 0)  THEN
		r_erh.upper_range := p_old_upper_range;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_s_chg_method_type, 'NULL') <>
			NVL(p_old_s_chg_method_type, 'NULL')  THEN
		r_erh.s_chg_method_type := p_old_s_chg_method_type;
		v_create_history := TRUE;
	END IF;
	-- Create a history record if a column has changed value
	IF v_create_history = TRUE THEN
		r_erh.FEE_TYPE :=  p_fee_type;
		r_erh.fee_cal_type :=  p_fee_cal_type;
		r_erh.fee_ci_sequence_number :=  p_fee_ci_sequence_number;
		r_erh.s_relation_type :=  p_s_relation_type;
		r_erh.range_number :=  p_range_number;
		r_erh.hist_start_dt := p_old_last_update_date;
		r_erh.hist_end_dt := p_new_last_update_date;
		r_erh.hist_who := p_old_last_updated_by;
    IGS_FI_ELM_RANGE_H_PKG.INSERT_ROW(
                    X_ROWID => X_ROWID,
                    X_FEE_TYPE => r_erh.FEE_TYPE,
					X_fee_cal_type => r_erh.fee_cal_type,
					X_fee_ci_sequence_number => r_erh.fee_ci_sequence_number,
					X_s_relation_type => r_erh.s_relation_type,
					X_range_number => r_erh.range_number,
					X_hist_start_dt => r_erh.hist_start_dt,
					X_hist_end_dt => r_erh.hist_end_dt,
					X_hist_who => r_erh.hist_who,
					X_FEE_CAT => r_erh.FEE_CAT,
					X_lower_range => r_erh.lower_range,
					X_upper_range => r_erh.upper_range,
					X_s_chg_method_type => r_erh.s_chg_method_type,
                                        X_MODE => 'R',
                                        x_org_id => l_n_org_id);
	END IF;
END;
EXCEPTION
WHEN OTHERS THEN
FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
FND_MESSAGE.SET_TOKEN('NAME','IGS_FI_GEN_002.FINP_INS_ER_HIST');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END finp_ins_er_hist;
--
PROCEDURE finp_ins_far_hist(
  p_fee_type                       IN IGS_FI_FEE_AS_RATE.FEE_TYPE%TYPE ,
  p_fee_cal_type                   IN IGS_FI_FEE_AS_RATE.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number         IN IGS_FI_FEE_AS_RATE.fee_ci_sequence_number%TYPE ,
  p_s_relation_type                IN IGS_FI_FEE_AS_RATE.s_relation_type%TYPE ,
  p_rate_number                    IN IGS_FI_FEE_AS_RATE.rate_number%TYPE ,
  p_new_fee_cat                    IN IGS_FI_FEE_AS_RATE.FEE_CAT%TYPE ,
  p_old_fee_cat                    IN IGS_FI_FEE_AS_RATE.FEE_CAT%TYPE ,
  p_new_location_cd                IN IGS_FI_FEE_AS_RATE.location_cd%TYPE ,
  p_old_location_cd                IN IGS_FI_FEE_AS_RATE.location_cd%TYPE ,
  p_new_attendance_type            IN IGS_FI_FEE_AS_RATE.ATTENDANCE_TYPE%TYPE ,
  p_old_attendance_type            IN IGS_FI_FEE_AS_RATE.ATTENDANCE_TYPE%TYPE ,
  p_new_attendance_mode            IN IGS_FI_FEE_AS_RATE.ATTENDANCE_MODE%TYPE ,
  p_old_attendance_mode            IN IGS_FI_FEE_AS_RATE.ATTENDANCE_MODE%TYPE ,
  p_new_order_of_precedence        IN IGS_FI_FEE_AS_RATE.order_of_precedence%TYPE ,
  p_old_order_of_precedence        IN IGS_FI_FEE_AS_RATE.order_of_precedence%TYPE ,
  p_new_govt_hecs_payment_option   IN IGS_FI_FEE_AS_RATE.GOVT_HECS_PAYMENT_OPTION%TYPE ,
  p_old_govt_hecs_payment_option   IN IGS_FI_FEE_AS_RATE.GOVT_HECS_PAYMENT_OPTION%TYPE ,
  p_new_govt_hecs_cntrbtn_band     IN IGS_FI_FEE_AS_RATE.govt_hecs_cntrbtn_band%TYPE ,
  p_old_govt_hecs_cntrbtn_band     IN IGS_FI_FEE_AS_RATE.govt_hecs_cntrbtn_band%TYPE ,
  p_new_chg_rate                   IN IGS_FI_FEE_AS_RATE.chg_rate%TYPE ,
  p_old_chg_rate                   IN IGS_FI_FEE_AS_RATE.chg_rate%TYPE ,
  p_new_unit_class                 IN IGS_FI_FEE_AS_RATE.unit_class%TYPE ,
  p_old_unit_class                 IN IGS_FI_FEE_AS_RATE.unit_class%TYPE ,
  p_new_residency_status_cd        IN IGS_FI_FEE_AS_RATE.residency_status_cd%TYPE,
  p_old_residency_status_cd        IN IGS_FI_FEE_AS_RATE.residency_status_cd%TYPE,
  p_new_course_cd                  IN IGS_FI_FEE_AS_RATE.course_cd%TYPE,
  p_old_course_cd                  IN IGS_FI_FEE_AS_RATE.course_cd%TYPE,
  p_new_version_number             IN IGS_FI_FEE_AS_RATE.version_number%TYPE,
  p_old_version_number             IN IGS_FI_FEE_AS_RATE.version_number%TYPE,
  p_new_org_party_id               IN IGS_FI_FEE_AS_RATE.org_party_id%TYPE,
  p_old_org_party_id               IN IGS_FI_FEE_AS_RATE.org_party_id%TYPE,
  p_new_class_standing             IN IGS_FI_FEE_AS_RATE.class_standing%TYPE,
  p_old_class_standing             IN IGS_FI_FEE_AS_RATE.class_standing%TYPE,
  p_new_last_updated_by            IN IGS_FI_FEE_AS_RATE.last_updated_by%TYPE,
  p_old_last_updated_by            IN IGS_FI_FEE_AS_RATE.last_updated_by%TYPE,
  p_new_last_update_date           IN IGS_FI_FEE_AS_RATE.last_update_date%TYPE,
  p_old_last_update_date           IN IGS_FI_FEE_AS_RATE.last_update_date%TYPE,
  p_new_unit_set_cd                IN igs_fi_fee_as_rate.unit_set_cd%TYPE,
  p_old_unit_set_cd                IN igs_fi_fee_as_rate.unit_set_cd%TYPE,
  p_new_us_version_number          IN igs_fi_fee_as_rate.us_version_number%TYPE,
  p_old_us_version_number          IN igs_fi_fee_as_rate.us_version_number%TYPE,
  p_new_unit_cd                    IN igs_fi_fee_as_rate.unit_cd%TYPE DEFAULT NULL,
  p_old_unit_cd                    IN igs_fi_fee_as_rate.unit_cd%TYPE DEFAULT NULL,
  p_new_unit_version_number        IN igs_fi_fee_as_rate.unit_version_number%TYPE DEFAULT NULL,
  p_old_unit_version_number        IN igs_fi_fee_as_rate.unit_version_number%TYPE DEFAULT NULL,
  p_new_unit_level                 IN igs_fi_fee_as_rate.unit_level%TYPE DEFAULT NULL,
  p_old_unit_level                 IN igs_fi_fee_as_rate.unit_level%TYPE DEFAULT NULL,
  p_new_unit_type_id               IN igs_fi_fee_as_rate.unit_type_id%TYPE DEFAULT NULL,
  p_old_unit_type_id               IN igs_fi_fee_as_rate.unit_type_id%TYPE DEFAULT NULL,
  p_new_unit_mode                  IN igs_fi_fee_as_rate.unit_mode%TYPE DEFAULT NULL,
  p_old_unit_mode                  IN igs_fi_fee_as_rate.unit_mode%TYPE DEFAULT NULL
  ) AS
  /*******************************************************************************************/
  -- HISTORY
  --Who           When          What
  --svuppala      31-MAY-2005   Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
  --                            Unit Version and Unit Level
  --pathipat      09-Sep-2003   Enh 3108052 - Add Unit Sets to Rate Table
  --                            Added 4 new params for unit_set_cd and us_version_number
  /*******************************************************************************************/
	gv_other_detail		VARCHAR2(255);
BEGIN
DECLARE
        x_rowid                 VARCHAR2(25);
	r_farh			IGS_FI_FEE_AS_RT_H_ALL%ROWTYPE;
	v_create_history	BOOLEAN := FALSE;
        l_n_org_id              IGS_FI_FEE_AS_RT_H_ALL.org_id%TYPE := igs_ge_gen_003.get_org_id;
BEGIN
	-- Create a history for a IGS_FI_FEE_AS_RATE record.
	-- Check if any of the non-primary key fields have been changed
	-- and set the flag v_create_history to indicate so.
	IF NVL(p_new_fee_cat, 'NULL') <> NVL(p_old_fee_cat, 'NULL')  THEN
		r_farh.FEE_CAT := p_old_fee_cat;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_location_cd, 'NULL') <> NVL(p_old_location_cd, 'NULL')  THEN
		r_farh.location_cd := p_old_location_cd;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_attendance_type, 'NULL') <>
			NVL(p_old_attendance_type, 'NULL') THEN
		r_farh.ATTENDANCE_TYPE := p_old_attendance_type;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_attendance_mode, 'NULL') <>
			NVL(p_old_attendance_mode, 'NULL') THEN
		r_farh.ATTENDANCE_MODE := p_old_attendance_mode;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_order_of_precedence, 0) <> NVL(p_old_order_of_precedence, 0)  THEN
		r_farh.order_of_precedence := p_old_order_of_precedence;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_govt_hecs_payment_option, 'NULL') <>
			NVL(p_old_govt_hecs_payment_option, 'NULL')  THEN
		r_farh.GOVT_HECS_PAYMENT_OPTION := p_old_govt_hecs_payment_option;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_govt_hecs_cntrbtn_band, 0) <>
			NVL(p_old_govt_hecs_cntrbtn_band, 0)  THEN
		r_farh.govt_hecs_cntrbtn_band := p_old_govt_hecs_cntrbtn_band;
		v_create_history := TRUE;
	END IF;
	IF  p_new_chg_rate <> p_old_chg_rate THEN
		r_farh.chg_rate := p_old_chg_rate;
		v_create_history := TRUE;
	END IF;

-- Code added for New Field Unit Class added to the IGS_FI_FEE_AS_RATE table
        IF ((p_new_unit_class <> p_old_unit_class) OR
            ((p_new_unit_class IS NOT NULL AND p_old_unit_class IS NULL) OR
             (p_new_unit_class IS NULL AND p_old_unit_class IS NOT NULL))) THEN
          r_farh.unit_class := p_old_unit_class;
          v_create_history := TRUE;
        END IF;
-- Code added for five New Fields added to the IGS_FI_FEE_AS_RATE table
	IF  NVL(p_new_residency_status_cd,0) <> NVL(p_old_residency_status_cd,0) THEN
		r_farh.residency_status_cd := p_old_residency_status_cd;
		v_create_history := TRUE;
	END IF;
	IF  NVL(p_new_course_cd,'NULL') <> NVL(p_old_course_cd,'NULL') THEN
		r_farh.course_cd := p_old_course_cd;
		v_create_history := TRUE;
	END IF;
	IF  NVL(p_new_version_number,0) <> NVL(p_old_version_number,0) THEN
		r_farh.version_number := p_old_version_number;
		v_create_history := TRUE;
	END IF;
	IF  NVL(p_new_org_party_id,0) <> NVL(p_old_org_party_id,0) THEN
		r_farh.org_party_id := p_old_org_party_id;
		v_create_history := TRUE;
	END IF;
	IF  NVL(p_new_class_standing,'NULL') <> NVL(p_old_class_standing,'NULL') THEN
		r_farh.class_standing := p_old_class_standing;
		v_create_history := TRUE;
	END IF;
        IF ((p_new_unit_set_cd <> p_old_unit_set_cd)
             OR ( (p_new_unit_set_cd IS NOT NULL AND p_old_unit_set_cd IS NULL) OR
                  (p_new_unit_set_cd IS NULL AND p_old_unit_set_cd IS NOT NULL)
                )
           ) THEN
		r_farh.unit_set_cd := p_old_unit_set_cd;
		v_create_history := TRUE;
	END IF;
	IF  NVL(p_new_us_version_number,0) <> NVL(p_old_us_version_number,0) THEN
		r_farh.us_version_number := p_old_us_version_number;
		v_create_history := TRUE;
	END IF;

         IF ((p_new_unit_cd <> p_old_unit_cd) OR
            ((p_new_unit_cd IS NOT NULL AND p_old_unit_cd IS NULL) OR
             (p_new_unit_cd IS NULL AND p_old_unit_cd IS NOT NULL))) THEN
          r_farh.unit_cd := p_old_unit_cd;
          v_create_history := TRUE;
        END IF;
        IF  NVL(p_new_unit_version_number,0) <> NVL(p_old_unit_version_number,0) THEN
		r_farh.unit_version_number := p_old_unit_version_number;
		v_create_history := TRUE;
	END IF;

        IF ((p_new_unit_level <> p_old_unit_level) OR
            ((p_new_unit_level IS NOT NULL AND p_old_unit_level IS NULL) OR
             (p_new_unit_level IS NULL AND p_old_unit_level IS NOT NULL))) THEN
          r_farh.unit_level := p_old_unit_level;
          v_create_history := TRUE;
        END IF;
         IF ((p_new_unit_mode <> p_old_unit_mode) OR
            ((p_new_unit_mode IS NOT NULL AND p_old_unit_mode IS NULL) OR
             (p_new_unit_mode IS NULL AND p_old_unit_mode IS NOT NULL))) THEN
          r_farh.unit_mode := p_old_unit_mode;
          v_create_history := TRUE;
        END IF;

        IF  NVL(p_new_unit_type_id,0) <> NVL(p_old_unit_type_id,0) THEN
		r_farh.unit_type_id := p_old_unit_type_id;
		v_create_history := TRUE;
	END IF;

	-- Create a history record if a column has changed value
	IF v_create_history = TRUE THEN
		r_farh.fee_type     :=  p_fee_type;
		r_farh.fee_cal_type :=  p_fee_cal_type;
		r_farh.fee_ci_sequence_number :=  p_fee_ci_sequence_number;
		r_farh.s_relation_type :=  p_s_relation_type;
		r_farh.rate_number     :=  p_rate_number;
		r_farh.hist_start_dt   := p_old_last_update_date;
		r_farh.hist_end_dt     := p_new_last_update_date;
		r_farh.hist_who        := p_old_last_updated_by;

                igs_fi_fee_as_rt_h_pkg.insert_row(
                                        x_rowid               => x_rowid,
   					x_fee_type            => r_farh.fee_type,
					x_fee_cal_type        => r_farh.fee_cal_type,
					x_fee_ci_sequence_number => r_farh.fee_ci_sequence_number,
					x_s_relation_type     => r_farh.s_relation_type,
					x_rate_number         => r_farh.rate_number,
					x_hist_start_dt       => r_farh.hist_start_dt,
					x_hist_end_dt         => r_farh.hist_end_dt,
					x_hist_who            => r_farh.hist_who,
					x_fee_cat             => r_farh.fee_cat,
					x_location_cd         => r_farh.location_cd,
					x_attendance_type     => r_farh.attendance_type,
					x_attendance_mode     => r_farh.attendance_mode,
					x_order_of_precedence => r_farh.order_of_precedence,
					x_govt_hecs_payment_option => r_farh.govt_hecs_payment_option,
					x_govt_hecs_cntrbtn_band => r_farh.govt_hecs_cntrbtn_band,
					x_chg_rate            => r_farh.chg_rate,
                                        x_unit_class          => r_farh.unit_class,
-- added by nishikant , to include the following five new fields for enhancement bug#1851586
                                        x_residency_status_cd => r_farh.residency_status_cd,
                                        x_course_cd           => r_farh.course_cd,
                                        x_version_number      => r_farh.version_number,
                                        x_org_party_id        => r_farh.org_party_id,
                                        x_class_standing      => r_farh.class_standing,
                                        x_org_id              => l_n_org_id,
                                        x_mode                => 'R',
                                        x_unit_set_cd         => r_farh.unit_set_cd,
                                        x_us_version_number   => r_farh.us_version_number,
 --svuppala   Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code, Unit Version and Unit Level
                                        x_unit_cd             => r_farh.unit_cd,
                                        x_unit_version_number => r_farh.unit_version_number,
                                        x_unit_level          => r_farh.unit_level ,
                                        x_unit_type_id        => r_farh.unit_type_id,
                                        x_unit_mode           => r_farh.unit_mode
                                     );
	END IF;
END;
EXCEPTION
   WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_FI_GEN_002.FINP_INS_FAR_HIST');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END finp_ins_far_hist;
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
  p_old_last_update_date IN IGS_FI_F_CAT_CA_INST.last_update_date%TYPE )
AS
	gv_other_detail		VARCHAR2(255);
BEGIN
DECLARE
      X_ROWID                 VARCHAR2(25);
	r_fccih			IGS_FI_FEE_CAT_CI_HT%ROWTYPE;
	v_create_history		BOOLEAN := FALSE;
        l_n_org_id              IGS_FI_FEE_CAT_CI_HT.org_id%TYPE := igs_ge_gen_003.get_org_id;
BEGIN
	-- Create a history for the IGS_FI_F_CAT_CA_INST table.
	-- Check if any of the non-primary key fields have been changed
	-- and set the flag v_create_history to indicate so.
	IF  p_new_fee_cat_ci_status <> p_old_fee_cat_ci_status THEN
		r_fccih.fee_cat_ci_status := p_old_fee_cat_ci_status;
		v_create_history := TRUE;
	END IF;
	IF  p_new_start_dt_alias <> p_old_start_dt_alias  THEN
		r_fccih.start_dt_alias   := p_old_start_dt_alias  ;
		v_create_history := TRUE;
	END IF;
	IF  p_new_start_dai_sequence_num <> p_old_start_dai_sequence_num  THEN
		r_fccih.start_dai_sequence_number := p_old_start_dai_sequence_num;
		v_create_history := TRUE;
	END IF;
	IF  p_new_end_dt_alias <> p_old_end_dt_alias  THEN
		r_fccih.end_dt_alias := p_old_end_dt_alias;
		v_create_history := TRUE;
	END IF;
	IF  p_new_end_dai_sequence_num <> p_old_end_dai_sequence_num  THEN
		r_fccih.end_dai_sequence_number := p_old_end_dai_sequence_num;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_retro_dt_alias, 'NULL') <> NVL(p_old_retro_dt_alias, 'NULL')  THEN
		r_fccih.retro_dt_alias := p_old_retro_dt_alias;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_retro_dai_sequence_num, 0) <>
			NVL(p_old_retro_dai_sequence_num, 0)  THEN
		r_fccih.retro_dai_sequence_number := p_old_retro_dai_sequence_num;
		v_create_history := TRUE;
	END IF;
	-- Create a history record if a column has changed value
	IF v_create_history = TRUE THEN
		r_fccih.FEE_CAT :=  p_fee_cat;
		r_fccih.fee_cal_type :=  p_fee_cal_type;
		r_fccih.fee_ci_sequence_number :=  p_fee_ci_sequence_number;
		r_fccih.hist_start_dt := p_old_last_update_date;
		r_fccih.hist_end_dt := p_new_last_update_date;
		r_fccih.hist_who := p_old_last_updated_by;
                 IGS_FI_FEE_CAT_CI_HT_PKG.INSERT_ROW(
                              X_ROWID => X_ROWID,
 					X_FEE_CAT => r_fccih.FEE_CAT,
					X_fee_cal_type => r_fccih.fee_cal_type,
					X_fee_ci_sequence_number => r_fccih.fee_ci_sequence_number,
					X_hist_start_dt => r_fccih.hist_start_dt,
					X_hist_end_dt => r_fccih.hist_end_dt,
					X_hist_who => r_fccih.hist_who,
					X_fee_cat_ci_status => r_fccih.fee_cat_ci_status,
					X_start_dt_alias => r_fccih.start_dt_alias,
					X_start_dai_sequence_number => r_fccih.start_dai_sequence_number,
					X_end_dt_alias => r_fccih.end_dt_alias,
					X_end_dai_sequence_number => r_fccih.end_dai_sequence_number,
					X_retro_dt_alias => r_fccih.retro_dt_alias,
					X_retro_dai_sequence_number => r_fccih.retro_dai_sequence_number,
                                        X_MODE => 'R',
                                        x_org_id => l_n_org_id);
	END IF;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
Fnd_Message.Set_Token('NAME','IGS_FI_GEN_002.FINP_INS_FCCI_HIST');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END finp_ins_fcci_hist;
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
  p_old_last_update_date IN IGS_FI_F_CAT_FEE_LBL_ALL.last_update_date%TYPE )
AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-Jul-2002  Bug#2425767.Removed parameters p_new_payment_hierarchy_rank,
  ||                               p_old_payment_hierarchy_rank and its references(from if condition and
  ||                               from call IGS_FI_F_CAT_F_LBL_H_PKG.INSERT_ROW).
  ----------------------------------------------------------------------------*/

	gv_other_detail		VARCHAR2(255);
BEGIN
DECLARE
      X_ROWID                 VARCHAR2(25);
	r_fcflh			IGS_FI_F_CAT_F_LBL_H%ROWTYPE;
	v_create_history		BOOLEAN := FALSE;
        l_n_org_id              IGS_FI_F_CAT_F_LBL_H.org_id%TYPE := igs_ge_gen_003.get_org_id;
BEGIN
	-- Create a history for a IGS_FI_F_CAT_FEE_LBL record.
	-- Check if any of the non-primary key fields have been changed
	-- and set the flag v_create_history to indicate so.
	IF  p_new_fee_liability_status <> p_old_fee_liability_status THEN
		r_fcflh.fee_liability_status := p_old_fee_liability_status;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_start_dt_alias, 'NULL') <> NVL(p_old_start_dt_alias, 'NULL')  THEN
		r_fcflh.start_dt_alias := p_old_start_dt_alias;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_start_dai_sequence_num, 0) <>
			NVL(p_old_start_dai_sequence_num, 0)  THEN
		r_fcflh.start_dai_sequence_number := p_old_start_dai_sequence_num;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_s_chg_method_type, 'NULL') <>
			NVL(p_old_s_chg_method_type, 'NULL')  THEN
		r_fcflh.s_chg_method_type := p_old_s_chg_method_type;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_rul_sequence_number, 0) <>
			NVL(p_old_rul_sequence_number, 0)  THEN
		r_fcflh.rul_sequence_number := p_old_rul_sequence_number;
		v_create_history := TRUE;
	END IF;
	-- Create a history record if a column has changed value
	IF v_create_history = TRUE THEN
		r_fcflh.FEE_CAT :=  p_fee_cat;
		r_fcflh.fee_cal_type :=  p_fee_cal_type;
		r_fcflh.fee_ci_sequence_number :=  p_fee_ci_sequence_number;
		r_fcflh.FEE_TYPE :=  p_fee_type;
		r_fcflh.hist_start_dt := p_old_last_update_date;
		r_fcflh.hist_end_dt := p_new_last_update_date;
		r_fcflh.hist_who := p_old_last_updated_by;
           IGS_FI_F_CAT_F_LBL_H_PKG.INSERT_ROW(
                X_ROWID => X_ROWID,
 		X_FEE_CAT => r_fcflh.FEE_CAT,
		X_fee_cal_type => r_fcflh.fee_cal_type,
		X_fee_ci_sequence_number => r_fcflh.fee_ci_sequence_number,
		X_FEE_TYPE => r_fcflh.FEE_TYPE,
		X_hist_start_dt => r_fcflh.hist_start_dt,
		X_hist_end_dt => r_fcflh.hist_end_dt,
		X_hist_who => r_fcflh.hist_who,
		X_fee_liability_status => r_fcflh.fee_liability_status,
		X_start_dt_alias => r_fcflh.start_dt_alias,
	        X_start_dai_sequence_number => r_fcflh.start_dai_sequence_number,
		X_s_chg_method_type => r_fcflh.s_chg_method_type,
		X_rul_sequence_number => r_fcflh.rul_sequence_number,
          	X_MODE => 'R',
                x_org_id => l_n_org_id);
	END IF;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
Fnd_Message.Set_Token('NAME','IGS_FI_GEN_002.FINP_INS_FCFL_HIST');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END finp_ins_fcfl_hist;
--
/* PROCEDURE finp_ins_fdf_hist() is obsolete as part of Build SFCR005_Cleanup_Build (Enhancement Bug # 2531390)
--
--
/* Obseleted the procedure finp_ins_fe_hist( as part of bug 2126091 as this is no longer used */
--
--Removed the procedure finp_ins_fps_hist as part of SFCR005 Clean Up Build. Bug#2531390.
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
  p_old_last_update_date IN IGS_FI_FEE_RET_SCHD.last_update_date%TYPE )
AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-Jul-2002  Bug#2425767.removed parameter p_new_deduction_amount,p_old_deduction_amount
  ||                               and its references(if condition and from call IGS_FI_F_RET_SCHD_HT_PKG.INSERT_ROW).
  ----------------------------------------------------------------------------*/
	gv_other_detail			VARCHAR2(255);
BEGIN
DECLARE
      X_ROWID                 VARCHAR2(25);
	r_frtnsh			IGS_FI_F_RET_SCHD_HT%ROWTYPE;
	v_create_history		BOOLEAN := FALSE;
        l_n_org_id              IGS_FI_F_RET_SCHD_HT.org_id%TYPE := igs_ge_gen_003.get_org_id;
BEGIN
	-- Create a history for a IGS_FI_FEE_RET_SCHD record.
	-- Check if any of the non-primary key fields have been changed
	-- and set the flag v_create_history to indicate so.
	IF NVL(p_new_fee_type, 'NULL') <> NVL(p_old_fee_type, 'NULL')  THEN
		r_frtnsh.FEE_TYPE := p_old_fee_type;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_fee_cat, 'NULL') <> NVL(p_old_fee_cat, 'NULL')  THEN
		r_frtnsh.FEE_CAT := p_old_fee_cat;
		v_create_history := TRUE;
	END IF;

	--Commented the underline code while solving bug 1534058.As schedule number never changes on updating the existing
	--exist records so the p_old_schedule_number should be passed as such without any validation in IF-END FI loop
	--If included in the loop the condition will never be satisfied and as a result shecudule will always be passed as a null.
	-- Due to which it will result in unique key voilation and record will not get insert into history table.


        --IF  p_new_schedule_number <> p_old_schedule_number THEN
		r_frtnsh.schedule_number := p_old_schedule_number;
	--	v_create_history := TRUE;
	-- END IF;
	IF NVL(p_new_dt_alias, 'NULL') <> NVL(p_old_dt_alias, 'NULL')  THEN
		r_frtnsh.DT_ALIAS := p_old_dt_alias;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_dai_sequence_number, 0) <> NVL(p_old_dai_sequence_number, 0)  THEN
		r_frtnsh.dai_sequence_number := p_old_dai_sequence_number;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_retention_percentage, 0) <>
			NVL(p_old_retention_percentage, 0) THEN
		r_frtnsh.retention_percentage := p_old_retention_percentage;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_retention_amount, 0) <> NVL(p_old_retention_amount, 0)  THEN
		r_frtnsh.retention_amount := p_old_retention_amount;
		v_create_history := TRUE;
	END IF;
	-- Create a history record if a column has changed value
	IF v_create_history = TRUE THEN
		r_frtnsh.fee_cal_type :=  p_fee_cal_type;
		r_frtnsh.fee_ci_sequence_number :=  p_fee_ci_sequence_number;
		r_frtnsh.s_relation_type :=  p_s_relation_type;
		r_frtnsh.sequence_number :=  p_sequence_number;
		r_frtnsh.hist_start_dt := p_old_last_update_date;
		r_frtnsh.hist_end_dt := p_new_last_update_date;
		r_frtnsh.hist_who := p_old_last_updated_by;
                 IGS_FI_F_RET_SCHD_HT_PKG.INSERT_ROW(
                    X_ROWID => X_ROWID,
					X_fee_cal_type => r_frtnsh.fee_cal_type,
					X_fee_ci_sequence_number => r_frtnsh.fee_ci_sequence_number,
					X_s_relation_type => r_frtnsh.s_relation_type,
					X_sequence_number => r_frtnsh.sequence_number,
					X_hist_start_dt => r_frtnsh.hist_start_dt,
					X_hist_end_dt => r_frtnsh.hist_end_dt,
					X_hist_who => r_frtnsh.hist_who,
					X_FEE_TYPE => r_frtnsh.FEE_TYPE,
					X_FEE_CAT => r_frtnsh.FEE_CAT,
					X_schedule_number => r_frtnsh.schedule_number,
					X_DT_ALIAS => r_frtnsh.DT_ALIAS,
					X_dai_sequence_number => r_frtnsh.dai_sequence_number,
					X_retention_percentage => r_frtnsh.retention_percentage,
					X_retention_amount => r_frtnsh.retention_amount,
                                        X_MODE => 'R',
                                        x_org_id => l_n_org_id);
	END IF;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
Fnd_Message.Set_Token('NAME','IGS_FI_GEN_002.FINP_INS_FRTNS_HIST');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END finp_ins_frtns_hist;
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
  p_old_last_update_date IN IGS_FI_F_TYP_CA_INST_ALL.last_update_date%TYPE,
-- Added by Nishikant , to include the following new fields for enhancement bug#1851586
  p_new_initial_default_amount IN IGS_FI_F_TYP_CA_INST_ALL.initial_default_amount%TYPE,
  p_old_initial_default_amount IN IGS_FI_F_TYP_CA_INST_ALL.initial_default_amount%TYPE,
--Added by svuppala,as a part of bug:4295379 New field "nonzero_billable_cp_flag"
  p_new_nonzero_billable_cp_flag IN IGS_FI_F_TYP_CA_INST_ALL.nonzero_billable_cp_flag%TYPE,
  p_old_nonzero_billable_cp_flag IN IGS_FI_F_TYP_CA_INST_ALL.nonzero_billable_cp_flag%TYPE)

AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  svuppala        13-Apr-2005   Bug 4297359 - ER REGISTRATION FEE ISSUE - ASSESSED TO STUDENTS WITH NO LOAD
  ||                                Added new field NONZERO_BILLABLE_CP_FLAG in IGS_FI_FEE_TYPE_CI_H_ALL
  ||  vvutukur        19-Jul-2002  Bug#2425767.Removed parameters p_new_payment_hierarchy_rank,
  ||                               p_old_payment_hierarchy_rank and its references(from if condition and
  ||                               from call to IGS_FI_FEE_TYPE_CI_H_PKG.INSERT_ROW.
  ----------------------------------------------------------------------------*/
	gv_other_detail			VARCHAR2(255);
BEGIN
DECLARE
      X_ROWID				VARCHAR2(25);
	r_ftcih				IGS_FI_FEE_TYPE_CI_H%ROWTYPE;
	v_create_history			BOOLEAN := FALSE;
        l_n_org_id              IGS_FI_FEE_TYPE_CI_H.org_id%TYPE := igs_ge_gen_003.get_org_id;
BEGIN
	-- Check if any of the non-primary key fields have been changed
	-- and set the flag v_create_history to indicate so.
	IF p_new_fee_type_ci_status <> p_old_fee_type_ci_status THEN
		r_ftcih.fee_type_ci_status := p_old_fee_type_ci_status;
		v_create_history := TRUE;
	END IF;
	IF p_new_start_dt_alias <> p_old_start_dt_alias THEN
		r_ftcih.start_dt_alias := p_old_start_dt_alias;
		v_create_history := TRUE;
	END IF;
	IF p_new_start_dai_sequence_num <> p_old_start_dai_sequence_num THEN
		r_ftcih.start_dai_sequence_number := p_old_start_dai_sequence_num;
		v_create_history := TRUE;
	END IF;
	IF p_new_end_dt_alias <> p_old_end_dt_alias THEN
		r_ftcih.end_dt_alias := p_old_end_dt_alias;
		v_create_history := TRUE;
	END IF;
	IF p_new_end_dai_sequence_number <> p_old_end_dai_sequence_number THEN
		r_ftcih.end_dai_sequence_number := p_old_end_dai_sequence_number;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_retro_dt_alias, 'NULL') <> NVL(p_old_retro_dt_alias, 'NULL') THEN
		r_ftcih.retro_dt_alias := p_old_retro_dt_alias;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_retro_dai_sequence_num, 0) <>
			NVL(p_old_retro_dai_sequence_num, 0) THEN
		r_ftcih.retro_dai_sequence_number := p_old_retro_dai_sequence_num;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_s_chg_method_type, 'NULL') <>
			NVL(p_old_s_chg_method_type, 'NULL') THEN
		r_ftcih.s_chg_method_type := p_old_s_chg_method_type;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_rul_sequence_number, 0) <> NVL(p_old_rul_sequence_number, 0) THEN
		r_ftcih.rul_sequence_number := p_old_rul_sequence_number;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_initial_default_amount, 0) <>
			NVL(p_old_initial_default_amount, 0) THEN
		r_ftcih.initial_default_amount := p_old_initial_default_amount;
		v_create_history := TRUE;
	END IF;
        IF NVL(p_new_nonzero_billable_cp_flag, 0) <>
			NVL(p_old_nonzero_billable_cp_flag, 0) THEN
		r_ftcih.nonzero_billable_cp_flag := p_old_nonzero_billable_cp_flag;
		v_create_history := TRUE;
	END IF;

	-- Create a history record if a column has changed value
	IF v_create_history = TRUE THEN
		r_ftcih.FEE_TYPE := p_fee_type;
		r_ftcih.fee_cal_type := p_fee_cal_type;
		r_ftcih.fee_ci_sequence_number := p_fee_ci_sequence_number;
		r_ftcih.hist_start_dt := p_old_last_update_date;
		r_ftcih.hist_end_dt := p_new_last_update_date;
		r_ftcih.hist_who := p_old_last_updated_by;
		r_ftcih.fee_type_ci_status := p_old_fee_type_ci_status;
	     IGS_FI_FEE_TYPE_CI_H_PKG.INSERT_ROW(
                    X_ROWID => X_ROWID,
					X_FEE_TYPE => r_ftcih.FEE_TYPE,
					X_fee_cal_type => r_ftcih.fee_cal_type,
					X_fee_ci_sequence_number => r_ftcih.fee_ci_sequence_number,
					X_hist_start_dt => r_ftcih.hist_start_dt,
					X_hist_end_dt => r_ftcih.hist_end_dt,
					X_hist_who => r_ftcih.hist_who,
					X_fee_type_ci_status => r_ftcih.fee_type_ci_status,
					X_start_dt_alias => r_ftcih.start_dt_alias,
					X_start_dai_sequence_number => r_ftcih.start_dai_sequence_number,
					X_end_dt_alias => r_ftcih.retro_dt_alias,
					X_end_dai_sequence_number => r_ftcih.retro_dai_sequence_number,
					X_retro_dt_alias => r_ftcih.retro_dt_alias,
					X_retro_dai_sequence_number => r_ftcih.retro_dai_sequence_number,
					X_s_chg_method_type => r_ftcih.s_chg_method_type,
					X_rul_sequence_number => r_ftcih.rul_sequence_number,
-- Added by Nishikant , to include the following new field for enhancement bug#1851586
				        X_initial_default_amount => r_ftcih.initial_default_amount,
					X_MODE => 'R',
                                        x_org_id => l_n_org_id,
        --Added by svuppala,as a part of bug:4295379 New field "nonzero_billable_cp_flag"
                                        x_nonzero_billable_cp_flag => r_ftcih.nonzero_billable_cp_flag);
	END IF;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
Fnd_Message.Set_Token('NAME','IGS_FI_GEN_002.FINP_INS_FTCI_HIST');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END finp_ins_ftci_hist;
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
  p_new_fee_class               IN IGS_FI_FEE_TYPE_ALL.fee_class%TYPE,    --for Bug 2175865
  p_old_fee_class               IN IGS_FI_FEE_TYPE_ALL.fee_class%TYPE,    --for Bug 2175865
  p_new_designated_payment_flag IN igs_fi_fee_type_all.designated_payment_flag%TYPE,
  p_old_designated_payment_flag IN igs_fi_fee_type_all.designated_payment_flag%TYPE,
  p_new_last_updated_by IN IGS_FI_FEE_TYPE_ALL.last_updated_by%TYPE ,
  p_old_last_updated_by IN IGS_FI_FEE_TYPE_ALL.last_updated_by%TYPE ,
  p_new_last_update_date IN IGS_FI_FEE_TYPE_ALL.last_update_date%TYPE ,
  p_old_last_update_date IN IGS_FI_FEE_TYPE_ALL.last_update_date%TYPE ,
  p_new_comments IN IGS_FI_FEE_TYPE_ALL.comments%TYPE ,
  p_old_comments IN IGS_FI_FEE_TYPE_ALL.comments%TYPE )
AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  shtatiko     30-MAY-2003      Enh# 2831582, Added new column designated_payment_flag.
  ||  vvutukur     13-Sep-2002      Enh#2564643.Removed parameters p_new_subaccount_id,p_old_subaccount_id.
  ||                                and related validation,also removed the parameter P_SUBACCOUNT_ID
  ||                                from the call to IGS_FI_FEE_TYPE_HIST_PKG.INSERT_ROW.
  ----------------------------------------------------------------------------*/

	gv_other_detail		VARCHAR2(255);
BEGIN
DECLARE
      X_ROWID		VARCHAR2(25) := NULL;
	r_fth			IGS_FI_FEE_TYPE_HIST%ROWTYPE;
	v_create_history	BOOLEAN := FALSE;
        l_n_org_id              IGS_FI_FEE_TYPE_HIST.org_id%TYPE := igs_ge_gen_003.get_org_id;
BEGIN
	-- Create a history for the IGS_FI_FEE_TYPE table.
	-- Check if any of the non-primary key fields have been changed
	-- and set the flag v_create_history to indicate so.
	IF NVL(p_new_s_fee_type, 'NULL') <> NVL(p_old_s_fee_type, 'NULL')  THEN
		r_fth.s_fee_type := p_old_s_fee_type;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_s_fee_trigger_cat, 'NULL') <>
			NVL(p_old_s_fee_trigger_cat, 'NULL')  THEN
		r_fth.s_fee_trigger_cat := p_old_s_fee_trigger_cat;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_description, 'NULL') <> NVL(p_old_description, 'NULL')  THEN
		r_fth.description := p_old_description;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_optional_payment_ind, 'NULL') <>
			NVL(p_old_optional_payment_ind, 'NULL')  THEN
		r_fth.optional_payment_ind := p_old_optional_payment_ind;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_closed_ind, 'NULL') <> NVL(p_old_closed_ind, 'NULL')  THEN
		r_fth.closed_ind := p_old_closed_ind;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_comments, 'NULL') <> NVL(p_old_comments, 'NULL')  THEN
		r_fth.comments := p_old_comments;
		v_create_history := TRUE;
	END IF;
	--for Bug 2175865 as part of SFCR017/SFCR022
	IF NVL(p_new_fee_class, 'NULL') <>
	                                 NVL(p_old_fee_class, 'NULL') THEN
                r_fth.fee_class := p_old_fee_class;
                v_create_history :=TRUE;
        END IF;

        -- Added designated_payment_flag as part of Enh# 2831582, Lockbox Build
        IF NVL(p_new_designated_payment_flag, 'NULL') <> NVL(p_old_designated_payment_flag, 'NULL') THEN
          r_fth.designated_payment_flag := p_old_designated_payment_flag;
          v_create_history :=TRUE;
        END IF;

	-- Create a history record if a column has changed value
	IF v_create_history = TRUE THEN
		r_fth.FEE_TYPE := p_fee_type;
		r_fth.hist_start_dt := p_old_last_update_date;
		r_fth.hist_end_dt := p_new_last_update_date;
		r_fth.hist_who := p_old_last_updated_by;
              IGS_FI_FEE_TYPE_HIST_PKG.INSERT_ROW(
                                X_ROWID => X_ROWID,
				X_FEE_TYPE => r_fth.FEE_TYPE,
				X_hist_start_dt => r_fth.hist_start_dt,
				X_hist_end_dt => r_fth.hist_end_dt,
				X_hist_who => r_fth.hist_who,
				X_s_fee_type => r_fth.s_fee_type,
				X_s_fee_trigger_cat => r_fth.s_fee_trigger_cat,
				X_description => r_fth.description,
				X_optional_payment_ind => r_fth.optional_payment_ind,
				X_closed_ind => r_fth.closed_ind,
				X_comments => r_fth.comments,
                                X_Fee_class => r_fth.fee_class,
                                x_designated_payment_flag => r_fth.designated_payment_flag,
                                X_MODE => 'R',
                                x_org_id => l_n_org_id);
	END IF;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
Fnd_Message.Set_Token('NAME','IGS_FI_GEN_002.FINP_INS_FT_HIST'||sqlerrm);
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END finp_ins_ft_hist;

--
--ENH # 2170429 by masehgal on 16-Jan-2002
--Obsoletion of SPONSOR_CD,SPONSORED_AMOUNT from finp_ins_pps_hist
--
-- As part of Enh Bug#2531390 the procedure finp_ins_pps_hist was removed
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
  p_old_last_update_date IN IGS_FI_UNIT_FEE_TRG.last_update_date%TYPE )
AS
	gv_other_detail			VARCHAR2(255);
BEGIN
DECLARE
      X_ROWID				VARCHAR2(25);
	r_ufth				IGS_FI_UNIT_FEE_TR_H%ROWTYPE;
	v_create_history			BOOLEAN := FALSE;
        l_n_org_id              IGS_FI_UNIT_FEE_TR_H.org_id%TYPE := igs_ge_gen_003.get_org_id;
BEGIN
	-- Create a history for a IGS_FI_UNIT_FEE_TRG record.
	-- Check if any of the non-primary key fields have been changed
	-- and set the flag v_create_history to indicate so.
	IF NVL(p_new_version_number, 0) <> NVL(p_old_version_number, 0)  THEN
		r_ufth.version_number := p_old_version_number;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_cal_type, 'NULL') <> NVL(p_old_cal_type, 'NULL')  THEN
		r_ufth.CAL_TYPE := p_old_cal_type;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_ci_sequence_number, 0) <> NVL(p_old_ci_sequence_number, 0)  THEN
		r_ufth.ci_sequence_number := p_old_ci_sequence_number;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_location_cd, 'NULL') <> NVL(p_old_location_cd, 'NULL')  THEN
		r_ufth.location_cd := p_old_location_cd;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_unit_class, 'NULL') <> NVL(p_old_unit_class, 'NULL')  THEN
		r_ufth.UNIT_CLASS := p_old_unit_class;
		v_create_history := TRUE;
	END IF;
	IF  p_new_create_dt <> p_old_create_dt THEN
		r_ufth.create_dt := p_old_create_dt;
		v_create_history := TRUE;
	END IF;
	IF NVL(p_new_fee_trigger_group_number, 0) <>
			NVL(p_old_fee_trigger_group_number, 0)  THEN
		r_ufth.fee_trigger_group_number := p_old_fee_trigger_group_number;
		v_create_history := TRUE;
	END IF;
	-- Create a history record if a column has changed value
	IF v_create_history = TRUE THEN
		r_ufth.FEE_CAT :=  p_fee_cat;
		r_ufth.fee_cal_type :=  p_fee_cal_type;
		r_ufth.fee_ci_sequence_number :=  p_fee_ci_sequence_number;
		r_ufth.FEE_TYPE :=  p_fee_type;
		r_ufth.unit_cd :=  p_unit_cd;
		r_ufth.sequence_number :=  p_sequence_number;
		r_ufth.hist_start_dt := p_old_last_update_date;
		r_ufth.hist_end_dt := p_new_last_update_date;
		r_ufth.hist_who := p_old_last_updated_by;
        IGS_FI_UNIT_FEE_TR_H_PKG.INSERT_ROW(
                    X_ROWID => X_ROWID,
					X_FEE_CAT => r_ufth.FEE_CAT,
					X_fee_cal_type => r_ufth.fee_cal_type,
					X_fee_ci_sequence_number => r_ufth.fee_ci_sequence_number,
					X_FEE_TYPE => r_ufth.FEE_TYPE,
					X_unit_cd => r_ufth.unit_cd,
					X_sequence_number => r_ufth.sequence_number,
					X_hist_start_dt => r_ufth.hist_start_dt,
					X_hist_end_dt => r_ufth.hist_end_dt,
					X_hist_who => r_ufth.hist_who,
					X_version_number => r_ufth.version_number,
					X_CAL_TYPE => r_ufth.CAL_TYPE,
					X_ci_sequence_number => r_ufth.ci_sequence_number,
					X_location_cd => r_ufth.location_cd,
					X_UNIT_CLASS => r_ufth.UNIT_CLASS,
					X_create_dt => r_ufth.create_dt,
					X_fee_trigger_group_number => r_ufth.fee_trigger_group_number,
                                        X_MODE => 'R',
                                        x_org_id => l_n_org_id);
	END IF;
END;
EXCEPTION
WHEN OTHERS THEN
Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
Fnd_Message.Set_Token('NAME','IGS_FI_GEN_002.FINP_INS_UFT_HIST');
IGS_GE_MSG_STACK.ADD;
 APP_EXCEPTION.RAISE_EXCEPTION;
END finp_ins_uft_hist;

-- New function as part of Bug 2324088 - SYkrishn
FUNCTION finp_validate_ccid(p_ccid   IN   igs_fi_cr_activities.dr_gl_ccid%TYPE) RETURN BOOLEAN AS

/***********************************************************************************************
Created By:         sykrishn
Date Created By:    19-APR-2002
Purpose:            This generic function this function validates whether
the ccid exists in the GL_CODE_COMBINATIONS table for the chart of account
identified by the Set of Books. The function call igs_fi_gen_007.get_coa_id
is called to get the Chart of Accounts for the Set of Books setup
in the IGS_FI_CONTROL.  - Bug 2324088
Known limitations,enhancements,remarks:
Change History
Who     When       What
********************************************************************************************** */
--Cursor to check existence of the ccid with the combination of the chart of accounts

CURSOR cur_ccid_exist (cp_ccid   IN   igs_fi_cr_activities.dr_gl_ccid%TYPE)  IS
      SELECT 'X'
      FROM   gl_code_combinations
      WHERE  code_combination_id = cp_ccid
      AND    chart_of_accounts_id = igs_fi_gen_007.get_coa_id;

l_ccid_exist VARCHAR2(1);
BEGIN
     OPEN    cur_ccid_exist (p_ccid);
     FETCH   cur_ccid_exist  INTO l_ccid_exist;
       IF cur_ccid_exist%FOUND THEN
          CLOSE   cur_ccid_exist;
          RETURN TRUE;
       ELSE
          CLOSE   cur_ccid_exist;
          RETURN FALSE;
       END IF;
END finp_validate_ccid;
-- End of New function added as part of Bug 2324088 - SYkrishn
END IGS_FI_GEN_002;

/
