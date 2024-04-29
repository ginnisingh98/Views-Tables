--------------------------------------------------------
--  DDL for Package Body IGS_FI_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_GEN_001" AS
/* $Header: IGSFI01B.pls 120.3 2006/02/23 20:50:48 skharida noship $ */

/******************************************************************
  Change History
  Who                 When                 What
  skharida      23-Feb-2006      After Code Review: Modified finpl_val_trig_group() Bug# 5018036,
  skharida      15-Feb-2006      Modified finpl_val_trig_group() Bug# 5018036, (version 12.1)
  uudyapr       06-Jan-2004      ENh#3167098 Added the function CHECK_STDNT_PRG_ATT_LIABLE .
  uudayapr      12-dec-2003      Bug#3080983 Modified the Functions finp_get_hecs_fee  and finp_get_tuition_fee
  uudayapr      16-oct-2003      Enh#3117341 audit and special fees built. Modification done in
                                 function finp_get_fee_trigger.
  vvutukur      15-Jul-2003      Enh#3038511.FICR106 Build. Modified procedure finp_get_total_planned_credits.
  vvutukur       1-Dec-2002      Enh#2584986.Modifications done in function finp_get_currency,finp_get_fps_start_dt.
  SMVK           13-Sep-2002     Bug#2531390. Restored the functions finp_get_fps_end_dt,FINP_GET_FDF_END_DT,
                                 FINP_GET_FDF_ST_DT and finp_get_fps_start_dt which are obsolete as the part of same bug.
                                 The functions have been modified to return null to make the views which are using to compile
  vvutukur       02-Sep-2002     Bug#2531390.Removed function finp_get_fps_end_dt,as this is not used
                                 anywhere in the system.(resulted in as impact of modification done
                                 in IGSFI31B.pls as part of this bug 2531390.
  smvk           28-Aug-2002     Bug#2531390.Removed the functions FINP_GET_FDF_END_DT, FINP_GET_FDF_ST_DT (SFCR005_Cleanup_Build)
  vvutukur       26-Aug-2002     Bug#2531390.Removed the function finp_get_fps_start_dt.
  jbegum         26-Aug-2002     As part of Enh Bug#2531390 the procedure finp_get_overdue_dtl was removed.
  rnirwani       06-May-02       Bug# 2345570
                                 When selecting from view IGS_FI_FEE_TRG_GRP_V, replacing column trigger_type with trigger_type_code.
                                 This change has been made in the procedure finpl_val_trig_group
  rnirwani       25-Apr-02       Obsoleting the procedure finp_get_dj_totals,
                                   since this is not being used.
                                 Bug# 2329407

   SYkrishn      02-APR-2002     Bug 2293676
                                 Added functions finp_get_planned_credits_ind and
                                 finp_get_total_planned_credits

  schodava         21-Jan-2002         Enh # 2187247
                                 Added functions FINP_GET_LFCI_RELN
                                 and FINP_CHK_LFCI_RELN
                                 Modified functions finp_get_hecs_amt_pd,
                                 finp_get_hecs_fee, finp_get_tuition_fee


******************************************************************/
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
) RETURN VARCHAR2 AS
/*----------------------------------------------------------------------------
||  Created By : UMESH UDAYAPRAKASH
||  Created On : 06-JAN-2004
||  Purpose :Function To Identify Whther A Student Program Attempt Is Liable
||           For A Fee Category Fee Liability
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
----------------------------------------------------------------------------*/
CURSOR c_fcfldate IS
  SELECT TRUNC(da1.alias_val) start_dt_alias_val,
         TRUNC(da2.alias_val) end_dt_alias_val
  FROM igs_fi_f_cat_fee_lbl_v fcflv,
       igs_ca_da_inst_v da1,
       igs_ca_da_inst_v da2
  WHERE da1.dt_alias = fcflv.start_dt_alias
  AND da1.sequence_number = fcflv.start_dai_sequence_number
  AND da1.cal_type = fcflv.fee_cal_type
  AND da1.ci_sequence_number = fcflv.fee_ci_sequence_number
  AND da1.alias_val IS NOT NULL
  AND da2.dt_alias = fcflv.end_dt_alias
  AND da2.sequence_number = fcflv.end_dai_sequence_number
  AND da2.cal_type = fcflv.fee_cal_type
  AND da2.ci_sequence_number = fcflv.fee_ci_sequence_number
  AND da2.alias_val IS NOT NULL
  AND fcflv.fee_cat = p_v_fee_cat
  AND fcflv.fee_type = p_v_fee_type
  AND fcflv.fee_cal_type = p_v_fee_cal_type
  AND fcflv.fee_ci_sequence_number = p_n_fee_ci_seq_number;

l_c_fcfldate c_fcfldate%ROWTYPE;
l_d_start_dt DATE;
l_d_end_dt DATE;
l_d_commencement_dt DATE;
l_v_trigger_fired igs_fi_fee_type_all.s_fee_trigger_cat%TYPE;
BEGIN
  IF (p_n_person_id IS NULL OR
      p_v_course_cd IS NULL OR
      p_n_course_version IS NULL OR
      p_v_fee_cat IS NULL OR
      p_v_fee_type IS NULL OR
      p_v_s_fee_trigger_cat IS NULL OR
      p_v_fee_cal_type IS NULL  OR
      p_n_fee_ci_seq_number IS NULL OR
      p_v_cal_type IS NULL OR
      p_v_location_cd IS NULL OR
      p_v_attendance_mode IS NULL OR
      p_v_attendance_type IS NULL )THEN

    RETURN 'FALSE'; -- If Mandatory Parameter Are Not Provided Return False
  ELSE
    OPEN c_fcfldate;
    FETCH c_fcfldate INTO l_c_fcfldate;
    --If No Matching FCFL records are found then return from the Function.
    IF (c_fcfldate%NOTFOUND) THEN
      CLOSE c_fcfldate;
      RETURN 'FALSE';
    END IF;
    CLOSE c_fcfldate;
    l_d_commencement_dt := p_d_commencement_dt;
    IF p_d_commencement_dt IS NULL THEN
       --Derive the Commencement Date if commencement date Parameter is Not Provided.
        l_d_commencement_dt := igs_en_gen_002.enrp_get_acad_comm( p_acad_cal_type             => NULL,
                                                                  p_acad_ci_sequence_number   => NULL,
                                                                  p_person_id                 => p_n_person_id,
                                                                  p_course_cd                 => p_v_course_cd,
                                                                  p_adm_admission_appl_number => p_n_adm_appl_number,
                                                                  p_adm_nominated_course_cd   => p_v_adm_nom_course_cd,
                                                                  p_adm_sequence_number       => p_n_adm_seq_number,
                                                                  p_chk_adm_prpsd_comm_ind    => 'Y');
       IF l_d_commencement_dt IS NULL THEN
         RETURN 'FALSE';
       END IF;
    END IF; --End Of Commencement Date Is Null Check

    IF l_d_commencement_dt > SYSDATE THEN
     l_d_commencement_dt := TRUNC(l_d_commencement_dt);
     IF NOT ((l_d_commencement_dt >= l_c_fcfldate.start_dt_alias_val) AND (l_d_commencement_dt <= l_c_fcfldate.end_dt_alias_val)) THEN
      RETURN 'FALSE';
     END IF;
    END IF; --END OF SYSDATE COMPARISION.

    IF p_d_disc_dt IS NOT NULL THEN
      IF NOT ((TRUNC(p_d_disc_dt) >= l_c_fcfldate.start_dt_alias_val) AND (TRUNC(p_d_disc_dt) <= l_c_fcfldate.end_dt_alias_val)) THEN
        RETURN 'FALSE';
      END IF;
    END IF; -- END OF p_d_disc_dt CHECK.
    IF p_v_s_fee_trigger_cat = 'INSTITUTN' THEN
      RETURN 'TRUE'; -- If the FeeTrigger Category is Institution then Return True.
    ELSE
     --Call finp_get_fee_trigger function with the Input PArameter it will Return the Trigger Fired.
     l_v_trigger_fired :=  igs_fi_gen_001.finp_get_fee_trigger(  p_fee_cat                    => p_v_fee_cat,
                                                                     p_fee_cal_type           => p_v_fee_cal_type,
                                                                     p_fee_ci_sequence_number => p_n_fee_ci_seq_number,
                                                                     p_fee_type               => p_v_fee_type,
                                                                     p_s_fee_trigger_cat      => p_v_s_fee_trigger_cat,
                                                                     p_person_id              => p_n_person_id,
                                                                     p_course_cd              => p_v_course_cd,
                                                                     p_version_number         => p_n_course_version,
                                                                     p_cal_type               => p_v_cal_type,
                                                                     p_location_cd            => p_v_location_cd,
                                                                     p_attendance_mode        => p_v_attendance_mode,
                                                                     p_attendance_type        => p_v_attendance_type);

     --If No Trigger Has Been Fired then Return False
     IF l_v_trigger_fired  IS NULL THEN
       RETURN 'FALSE';
     ELSE
       RETURN 'TRUE';
     END IF;
    END IF;
  END IF; -- END OF THE PARAMETER VALIDATION.
END check_stdnt_prg_att_liable;


FUNCTION finp_get_currency(
  p_fee_cal_type IN IGS_CA_TYPE.CAL_TYPE%TYPE ,
  p_fee_ci_sequence_num IN igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE ,
  p_s_relation_type IN VARCHAR2,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.FEE_TYPE%TYPE ,
  p_fee_category IN IGS_FI_FEE_CAT_ALL.FEE_CAT%TYPE )
RETURN VARCHAR2 AS
/*----------------------------------------------------------------------------
||  Created By :
||  Created On :
||  Purpose :
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
|| vvutukur       1-Dec-2002 Enh#2584986.Removed the references to igs_fi_cur. Instead referenced the currency
||                           that is set up in System Options Form.Also removed the references to igs_fi_fee_pay_schd
||                           as the same had been obsoleted.
----------------------------------------------------------------------------*/

BEGIN
DECLARE
        --Cursor to fetch the currency code that is setup in System Options Form.
        CURSOR cur_ctrl  IS
        SELECT currency_cd
        FROM   igs_fi_control;

        --Cursor to fetch the currency code value for a fee category
        CURSOR c_fc (cp_fee_cat  IGS_FI_FEE_CAT.FEE_CAT%TYPE) IS
                SELECT        currency_cd
                FROM        IGS_FI_FEE_CAT fc
                WHERE        FEE_CAT = cp_fee_cat;
        -- this cursor finds the relation type value for a fee ass rate
        CURSOR c_far (        cp_fee_type          IGS_FI_FEE_AS_RATE.FEE_TYPE%TYPE,
                        cp_fee_cal_type        IGS_FI_FEE_AS_RATE.fee_cal_type%TYPE,
                        cp_fee_ci_seq_num
                                        IGS_FI_FEE_AS_RATE.fee_ci_sequence_number%TYPE,
                        cp_fee_cat  IGS_FI_FEE_CAT.FEE_CAT%TYPE) IS
                SELECT DISTINCT
                        s_relation_type
                FROM        IGS_FI_FEE_AS_RATE
                WHERE        FEE_TYPE = cp_fee_type AND
                        fee_cal_type = cp_fee_cal_type AND
                        fee_ci_sequence_number = cp_fee_ci_seq_num AND
                        NVL(FEE_CAT, cp_fee_cat) = cp_fee_cat;

v_currency_cd                  igs_fi_control.currency_cd%TYPE;
v_s_relation_type        IGS_FI_FEE_AS_RATE.s_relation_type%TYPE;
l_ctrl_currency         igs_fi_control.currency_cd%TYPE;

BEGIN
  OPEN cur_ctrl;
  FETCH cur_ctrl INTO l_ctrl_currency;
  CLOSE cur_ctrl;

        -- Determine where to source the currency code
        IF NVL(p_s_relation_type, 'NULL') <> 'NULL' THEN
                IF p_s_relation_type = 'FTCI' THEN
                 --Return the currency code value that is set up in System Options Form.
                        RETURN l_ctrl_currency;
                ELSE
                        IF NVL(p_fee_category, 'NULL') <> 'NULL' THEN
                                -- get fee category currency.
                                OPEN c_fc (p_fee_category);
                                FETCH c_fc INTO v_currency_cd;
                                CLOSE c_fc;
                                IF v_currency_cd IS NULL THEN
                                --Return the currency code value that is set up in System Options Form.
                                  RETURN l_ctrl_currency;
                                END IF;
                                RETURN v_currency_cd;
                        ELSE
                          --Return the currency code value that is set up in System Options Form.
                          RETURN l_ctrl_currency;
                        END IF;
                END IF;
        ELSE
                IF NVL(p_fee_cal_type, 'NULL') <> 'NULL' AND
                        NVL(p_fee_ci_sequence_num, 0) <> 0 AND
                        NVL(p_fee_type, 'NULL') <> 'NULL' AND
                        NVL(p_fee_category, 'NULL') <> 'NULL' THEN
                        OPEN c_far (        p_fee_type,
                                        p_fee_cal_type,
                                        p_fee_ci_sequence_num,
                                        p_fee_category);
                        FETCH c_far INTO v_s_relation_type;
                        CLOSE c_far;
                        IF v_s_relation_type = 'FTCI' THEN
                          --Return the currency code value that is set up in System Options Form.
                          RETURN l_ctrl_currency;
                        ELSE
                                -- get fee category currency.
                                OPEN c_fc (p_fee_category);
                                FETCH c_fc INTO v_currency_cd;
                                CLOSE c_fc;
                                IF v_currency_cd IS NULL THEN
                                  --Return the currency code value that is set up in System Options Form.
                                  RETURN l_ctrl_currency;
                                END IF;
                                RETURN v_currency_cd;
                        END IF;
                ELSE
                        IF NVL(p_fee_category, 'NULL') <> 'NULL' THEN
                                -- get fee category currency.
                                OPEN c_fc (p_fee_category);
                                FETCH c_fc INTO v_currency_cd;
                                CLOSE c_fc;
                                IF v_currency_cd IS NULL THEN
                                  --Return the currency code value that is set up in System Options Form.
                                  RETURN l_ctrl_currency;
                                END IF;
                                RETURN v_currency_cd;
                        ELSE
                          --Return the currency code value that is set up in System Options Form.
                          RETURN l_ctrl_currency;
                        END IF;
                END IF;
        END IF;
END;
END finp_get_currency;
--
--
FUNCTION finp_get_fas_man_ind(
  p_person_id IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE ,
  p_transaction_cat IN VARCHAR2 )
RETURN VARCHAR2 AS

BEGIN
DECLARE
        CURSOR c_fee_ass (cp_person_id                        IGS_FI_FEE_AS.person_id%TYPE,
                        cp_fee_type                        IGS_FI_FEE_AS.FEE_TYPE%TYPE,
                        cp_fee_cal_type                        IGS_FI_FEE_AS.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number        IGS_FI_FEE_AS.fee_ci_sequence_number%TYPE,
                        cp_fee_cat                        IGS_FI_FEE_AS.FEE_CAT%TYPE,
                        cp_course_cd                        IGS_FI_FEE_AS.course_cd%TYPE,
                        cp_transaction_cat                IGS_LOOKUPS_view.transaction_cat%TYPE) IS
                SELECT        fas.s_transaction_type
                FROM        IGS_FI_FEE_AS fas,
                        IGS_LOOKUPS_view        strty
                WHERE        fas.person_id = cp_person_id AND
                        fas.fee_type = cp_fee_type AND
                        fas.fee_cal_type = cp_fee_cal_type AND
                        NVL(fas.FEE_CAT, ' ') = NVL(cp_fee_cat, ' ') AND
                        NVL(fas.course_cd, ' ') = NVL(cp_course_cd, ' ') AND
                        fas.logical_delete_dt IS NULL AND
                        fas.fee_ci_sequence_number = cp_fee_ci_sequence_number AND
                        strty.lookup_code = fas.s_transaction_type AND
                        strty.lookup_type = 'TRANSACTION_TYPE' AND
                        strty.transaction_cat = cp_transaction_cat AND
                        strty.system_generated_ind = 'N';
        v_transaction_type        IGS_FI_FEE_AS.S_TRANSACTION_TYPE%TYPE;
        BEGIN
                -- attempt to find manual entry transactions
                OPEN        c_fee_ass(p_person_id,
                                p_fee_type,
                                p_fee_cal_type,
                                p_fee_ci_sequence_number,
                                p_fee_cat,
                                p_course_cd,
                                p_transaction_cat);
                LOOP
                        FETCH        c_fee_ass        INTO        v_transaction_type;
                        IF (c_fee_ass%NOTFOUND) THEN
                                CLOSE c_fee_ass;
                                RETURN 'N';
                        ELSE
                                CLOSE c_fee_ass;
                                RETURN 'Y';
                        END IF;
                END LOOP;
        END;
END finp_get_fas_man_ind;
--
FUNCTION finp_get_fcfl_dai(
  p_dt_alias_column_name IN VARCHAR2 ,
  p_dai_seq_num_column_name IN VARCHAR2 ,
  p_get_column_name IN VARCHAR2 ,
  p_fee_cat IN IGS_FI_F_CAT_FEE_LBL_ALL.FEE_CAT%TYPE ,
  p_fee_cal_type IN IGS_FI_F_CAT_FEE_LBL_ALL.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_FI_F_CAT_FEE_LBL_ALL.fee_ci_sequence_number%TYPE ,
  p_fee_type IN IGS_FI_F_CAT_FEE_LBL_ALL.FEE_TYPE%TYPE )
RETURN VARCHAR2 AS

BEGIN
DECLARE
        -- cursor to get dt alias's for the fee type calendar instance
        CURSOR c_ftci_dai (cp_dt_alias_column_name                user_tab_columns.column_name%TYPE,
                        cp_dai_seq_num_column_name        user_tab_columns.column_name%TYPE,
                        cp_fee_cal_type                        IGS_FI_F_CAT_FEE_LBL.fee_cal_type%TYPE ,
                        cp_fee_ci_sequence_number        IGS_FI_F_CAT_FEE_LBL.fee_ci_sequence_number%TYPE,
                          cp_fee_type                        IGS_FI_F_CAT_FEE_LBL.FEE_TYPE%TYPE ) IS
                SELECT        DECODE(cp_dt_alias_column_name,
                                        'START_DT_ALIAS', ftci.start_dt_alias,
                                        'END_DT_ALIAS', ftci.end_dt_alias,
                                        'RETRO_DT_ALIAS', ftci.retro_dt_alias),
                        DECODE(cp_dai_seq_num_column_name,
                                        'START_DAI_SEQUENCE_NUMBER', ftci.start_dai_sequence_number,
                                        'END_DAI_SEQUENCE_NUMBER', ftci.end_dai_sequence_number,
                                        'RETRO_DAI_SEQUENCE_NUMBER', ftci.retro_dai_sequence_number)
                FROM        IGS_FI_F_TYP_CA_INST        ftci
                WHERE        ftci.FEE_TYPE = cp_fee_type AND
                        ftci.fee_cal_type = cp_fee_cal_type AND
                        ftci.fee_ci_sequence_number = cp_fee_ci_sequence_number;
        -- cursor to get dt alias's for the fee category calendar instance
        CURSOR c_fcci_dai (cp_dt_alias_column_name                user_tab_columns.column_name%TYPE,
                        cp_dai_seq_num_column_name        user_tab_columns.column_name%TYPE,
                        cp_fee_cat                         IGS_FI_F_CAT_FEE_LBL.FEE_CAT%TYPE ,
                        cp_fee_cal_type                        IGS_FI_F_CAT_FEE_LBL.fee_cal_type%TYPE ,
                        cp_fee_ci_sequence_number
                                IGS_FI_F_CAT_FEE_LBL.fee_ci_sequence_number%TYPE) IS
                SELECT        DECODE(cp_dt_alias_column_name,
                                        'START_DT_ALIAS', fcci.start_dt_alias,
                                        'END_DT_ALIAS', fcci.end_dt_alias,
                                        'RETRO_DT_ALIAS', fcci.retro_dt_alias),
                        DECODE(cp_dai_seq_num_column_name,
                                        'START_DAI_SEQUENCE_NUMBER', fcci.start_dai_sequence_number,
                                        'END_DAI_SEQUENCE_NUMBER', fcci.end_dai_sequence_number,
                                        'RETRO_DAI_SEQUENCE_NUMBER', fcci.retro_dai_sequence_number)
                FROM        IGS_FI_F_CAT_CA_INST        fcci
                WHERE        fcci.FEE_CAT = cp_fee_cat AND
                        fcci.fee_cal_type = cp_fee_cal_type AND
                        fcci.fee_ci_sequence_number = cp_fee_ci_sequence_number;
        v_ftci_alias_value        IGS_CA_DA_INST_V.alias_val%TYPE;
        v_ftci_dt_alias                IGS_CA_DA.DT_ALIAS%TYPE;
        v_ftci_dai_seq_num        IGS_CA_DA_INST.sequence_number%TYPE;
        v_fcci_alias_value        IGS_CA_DA_INST_V.alias_val%TYPE;
        v_fcci_dt_alias                IGS_CA_DA.DT_ALIAS%TYPE;
        v_fcci_dai_seq_num        IGS_CA_DA_INST.sequence_number%TYPE;
        BEGIN
                -- get the required dt alias from the fee type calendar instance
                OPEN        c_ftci_dai (p_dt_alias_column_name,
                                p_dai_seq_num_column_name,
                                p_fee_cal_type,
                                p_fee_ci_sequence_number,
                                p_fee_type);
                FETCH        c_ftci_dai         INTO        v_ftci_dt_alias,
                                                v_ftci_dai_seq_num;
                CLOSE c_ftci_dai;
                IF v_ftci_dt_alias IS NOT NULL THEN
                v_ftci_alias_value := IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
                                                v_ftci_dt_alias,
                                                v_ftci_dai_seq_num,
                                                p_fee_cal_type,
                                                p_fee_ci_sequence_number);
                ELSE
                        v_ftci_alias_value := NULL;
                END IF;
                -- get the required dt alias from the fee category calendar instance
                OPEN        c_fcci_dai (p_dt_alias_column_name,
                                p_dai_seq_num_column_name,
                                p_fee_cat,
                                p_fee_cal_type,
                                p_fee_ci_sequence_number);
                FETCH        c_fcci_dai         INTO        v_fcci_dt_alias,
                                                v_fcci_dai_seq_num;
                CLOSE c_fcci_dai;
                IF v_fcci_dt_alias IS NOT NULL THEN
                        v_fcci_alias_value := IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(v_fcci_dt_alias,
                                                        v_fcci_dai_seq_num,
                                                        p_fee_cal_type,
                                                        p_fee_ci_sequence_number);
                ELSE
                        v_ftci_alias_value := NULL;
                END IF;
                IF p_dt_alias_column_name = 'START_DT_ALIAS' THEN
                        -- return the latest start dt alias detail
                        IF v_ftci_alias_value > v_fcci_alias_value THEN
                                  IF p_get_column_name = p_dt_alias_column_name THEN
                                        RETURN v_ftci_dt_alias;
                                ELSIF p_get_column_name = p_dai_seq_num_column_name THEN
                                        RETURN TO_CHAR(v_ftci_dai_seq_num);
                                END IF;
                        ELSE
                                IF p_get_column_name = p_dt_alias_column_name THEN
                                        RETURN v_fcci_dt_alias;
                                ELSIF p_get_column_name = p_dai_seq_num_column_name THEN
                                        RETURN TO_CHAR(v_fcci_dai_seq_num);
                                END IF;
                        END IF;
                ELSIF p_dt_alias_column_name = 'END_DT_ALIAS' THEN
                        -- return the earlist end dt alias detail
                        IF v_ftci_alias_value < v_fcci_alias_value THEN
                                  IF p_get_column_name = p_dt_alias_column_name THEN
                                        RETURN v_ftci_dt_alias;
                                ELSIF p_get_column_name = p_dai_seq_num_column_name THEN
                                        RETURN TO_CHAR(v_ftci_dai_seq_num);
                                END IF;
                        ELSE
                                IF p_get_column_name = p_dt_alias_column_name THEN
                                        RETURN v_fcci_dt_alias;
                                ELSIF p_get_column_name = p_dai_seq_num_column_name THEN
                                        RETURN TO_CHAR(v_fcci_dai_seq_num);
                                END IF;
                        END IF;
                ELSIF p_dt_alias_column_name = 'RETRO_DT_ALIAS' THEN
                        -- return the earliest retro dt alias detail defined
                        IF v_ftci_alias_value IS NULL AND
                           v_fcci_alias_value IS NULL THEN
                                RETURN NULL;
                        END IF;
                        IF NVL(v_ftci_alias_value, v_fcci_alias_value) <
                                        NVL(v_fcci_alias_value, v_ftci_alias_value) THEN
                                  IF p_get_column_name = p_dt_alias_column_name THEN
                                        RETURN NVL(v_ftci_dt_alias, v_fcci_dt_alias);
                                ELSIF p_get_column_name = p_dai_seq_num_column_name THEN
                                        RETURN TO_CHAR(NVL(v_ftci_dai_seq_num, v_fcci_dai_seq_num));
                                END IF;
                        ELSE
                                IF p_get_column_name = p_dt_alias_column_name THEN
                                        RETURN NVL(v_fcci_dt_alias, v_ftci_dt_alias);
                                ELSIF p_get_column_name = p_dai_seq_num_column_name THEN
                                        RETURN TO_CHAR(NVL(v_fcci_dai_seq_num, v_ftci_dai_seq_num));
                                END IF;
                        END IF;
                END IF;
                RETURN NULL;
        END;
END finp_get_fcfl_dai;
--
FUNCTION finp_get_fdf_end_dt(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_override_formula IN NUMBER ,
  p_fee_cat IN VARCHAR2 )
RETURN DATE AS

BEGIN
 return NULL;
END finp_get_fdf_end_dt;

--
FUNCTION finp_get_fdf_st_dt(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_override_formula IN NUMBER ,
  p_fee_cat IN VARCHAR2 )
RETURN DATE AS

BEGIN
 return NULL;
END finp_get_fdf_st_dt;
--
FUNCTION finp_get_fee_trigger(
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
RETURN VARCHAR2 AS

BEGIN
        DECLARE
                CURSOR c_ft IS
                        SELECT        ft.s_fee_trigger_cat
                        FROM        IGS_FI_FEE_TYPE        ft
                        WHERE        ft.FEE_TYPE = p_fee_type;
                CURSOR c_ctft IS
                        SELECT        ctft.COURSE_TYPE
                        FROM        IGS_PS_TYPE_FEE_TRG        ctft,
                                IGS_PS_VER                cv
                        WHERE        ctft.FEE_CAT = p_fee_cat AND
                                ctft.fee_cal_type = p_fee_cal_type AND
                                ctft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                                ctft.FEE_TYPE = p_fee_type AND
                                cv.course_cd = p_course_cd AND
                                cv.version_number = p_version_number AND
                                cv.COURSE_TYPE = ctft.COURSE_TYPE AND
                                ctft.logical_delete_dt IS NULL;
                CURSOR c_cgft IS
                        SELECT        cgft.course_group_cd
                        FROM        IGS_PS_GRP_FEE_TRG        cgft,
                                IGS_PS_GRP_MBR        cgm
                        WHERE        cgft.FEE_CAT = p_fee_cat AND
                                cgft.fee_cal_type = p_fee_cal_type AND
                                cgft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                                cgft.FEE_TYPE = p_fee_type AND
                                cgm.course_cd = p_course_cd AND
                                cgm.version_number = p_version_number AND
                                cgm.course_group_cd = cgft.course_group_cd AND
                                cgft.logical_delete_dt IS NULL;
                CURSOR c_cft IS
                        SELECT        cft.fee_trigger_group_number
                        FROM        IGS_PS_FEE_TRG                cft
                        WHERE        cft.FEE_CAT = p_fee_cat AND
                                cft.fee_cal_type = p_fee_cal_type AND
                                cft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                                cft.FEE_TYPE = p_fee_type AND
                                cft.course_cd = p_course_cd AND
                                (cft.version_number IS NULL OR
                                cft.version_number = p_version_number) AND
                                p_cal_type LIKE NVL(cft.CAL_TYPE, '%') AND
                                p_location_cd LIKE NVL(cft.location_cd, '%') AND
                                p_attendance_mode LIKE NVL(cft.ATTENDANCE_MODE, '%') AND
                                p_attendance_type LIKE NVL(cft.ATTENDANCE_TYPE, '%') AND
                                cft.logical_delete_dt IS NULL;
                CURSOR c_uft        IS
                        SELECT        uft.unit_cd,
                                uft.version_number,
                                uft.CAL_TYPE,
                                uft.ci_sequence_number,
                                uft.location_cd,
                                uft.UNIT_CLASS,
                                uft.fee_trigger_group_number
                        FROM        IGS_FI_UNIT_FEE_TRG                uft
                        WHERE        uft.FEE_CAT = p_fee_cat AND
                                uft.fee_cal_type = p_fee_cal_type AND
                                uft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                                uft.FEE_TYPE = p_fee_type AND
                                uft.logical_delete_dt IS NULL;
                CURSOR c_sua        (cp_unit_cd        IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
                                cp_version_number
                                                IGS_EN_SU_ATTEMPT.version_number%TYPE,
                                cp_cal_type        IGS_EN_SU_ATTEMPT.CAL_TYPE%TYPE,
                                cp_ci_sequence_number
                                                IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
                                cp_location_cd        IGS_EN_SU_ATTEMPT.location_cd%TYPE,
                                cp_unit_class        IGS_EN_SU_ATTEMPT.UNIT_CLASS%TYPE) IS
                        SELECT        'X'
                        FROM        IGS_EN_SU_ATTEMPT        sua,
                                IGS_LOOKUPS_view        suas
                        WHERE        sua.person_id = p_person_id AND
                                sua.course_cd = p_course_cd AND
                                sua.unit_cd = cp_unit_cd AND
                                (cp_version_number IS NULL OR
                                sua.version_number = cp_version_number) AND
                                (cp_cal_type IS NULL OR
                                sua.CAL_TYPE = cp_cal_type) AND
                                (cp_ci_sequence_number IS NULL OR
                                sua.ci_sequence_number = cp_ci_sequence_number) AND
                                (cp_location_cd IS NULL OR
                                sua.location_cd = cp_location_cd) AND
                                (cp_unit_class IS NULL OR
                                sua.UNIT_CLASS = cp_unit_class) AND
                                suas.lookup_code = sua.unit_attempt_status AND
                                suas.lookup_type = 'UNIT_ATTEMPT_STATUS' AND
                                suas.fee_ass_ind = 'Y';
                CURSOR c_usft        IS
                        SELECT        usft.unit_set_cd,
                                usft.version_number,
                                usft.fee_trigger_group_number
                        FROM        IGS_EN_UNITSETFEETRG                usft
                        WHERE        usft.FEE_CAT = p_fee_cat AND
                                usft.fee_cal_type = p_fee_cal_type AND
                                usft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                                usft.FEE_TYPE = p_fee_type AND
                                usft.logical_delete_dt IS NULL;
                CURSOR c_susa        (cp_unit_set_cd                IGS_AS_SU_SETATMPT.unit_set_cd%TYPE,
                                cp_version_number        IGS_AS_SU_SETATMPT.us_version_number%TYPE) IS
                        SELECT        'X'
                        FROM        IGS_AS_SU_SETATMPT        susa
                        WHERE        susa.person_id = p_person_id AND
                                susa.course_cd = p_course_cd AND
                                susa.unit_set_cd = cp_unit_set_cd AND
                                susa.us_version_number = cp_version_number AND
                                susa.student_confirmed_ind = 'Y' AND
                                (susa.selection_dt IS NOT NULL AND
                                TRUNC(SYSDATE) >= TRUNC(susa.selection_dt)) AND
                                (susa.end_dt IS NULL OR
                                TRUNC(SYSDATE) <= TRUNC(susa.end_dt)) AND
                                (susa.rqrmnts_complete_dt IS NULL OR
                                TRUNC(SYSDATE) <= TRUNC(susa.rqrmnts_complete_dt));
                v_s_fee_trigger_cat        IGS_FI_FEE_TYPE.s_fee_trigger_cat%TYPE;
                v_check                        CHAR(1);
--------------------------------------------------------------------------------
        FUNCTION finpl_val_trig_group (p_fee_trigger_group_number
                                IGS_FI_FEE_TRG_GRP.fee_trigger_group_number%TYPE)
        RETURN BOOLEAN AS
        BEGIN
                -- validate the fee trigger group members match the student
        DECLARE
                CURSOR c_ftgv_course   IS
                        SELECT          lkp.lookup_code trigger_type_code,
                                cft.course_cd code,
                                cft.version_number
                        FROM            IGS_PS_FEE_TRG  cft,
                                IGS_PS_VER  crv,
                                IGS_LOOKUP_VALUES lkp
                        WHERE           cft.FEE_CAT = p_fee_cat AND
                                cft.fee_cal_type = p_fee_cal_type AND
                                cft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                                cft.FEE_TYPE = p_fee_type AND
                                cft.fee_trigger_group_number = p_fee_trigger_group_number AND
                                lkp.lookup_type = 'IGS_FI_TRIGGER_GROUP' AND
                                lkp.lookup_code = 'COURSE' AND
                                cft.fee_trigger_group_number IS NOT NULL AND
                                cft.logical_delete_dt IS NULL AND
                                cft.course_cd = crv.course_cd AND
                                (cft.version_number = crv.version_number OR
                                (cft.version_number IS NULL AND
                                crv.version_number = ( SELECT  MAX(crv2.version_number)
                                                       FROM IGS_PS_VER crv2
                                                       WHERE   crv2.course_cd = crv.course_cd)));
                CURSOR c_ftgv_unit   IS
                        SELECT          lkp.lookup_code trigger_type_code,
                                uft.unit_cd code,
                                uft.version_number
                        FROM            IGS_FI_UNIT_FEE_TRG     uft,
                                IGS_PS_UNIT_VER         uv,
                                IGS_LOOKUP_VALUES       lkp
                        WHERE           uft.FEE_CAT = p_fee_cat AND
                                uft.fee_cal_type = p_fee_cal_type AND
                                uft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                                uft.FEE_TYPE = p_fee_type AND
                                uft.fee_trigger_group_number = p_fee_trigger_group_number AND
                                lkp.lookup_type = 'IGS_FI_TRIGGER_GROUP' AND
                                lkp.lookup_code = 'UNIT' AND
                                uft.fee_trigger_group_number IS NOT NULL AND
                                uft.logical_delete_dt IS NULL AND
                                uft.unit_cd = uv.unit_cd AND
                                (uft.version_number = uv.version_number OR
                                (uft.version_number IS NULL AND
                                uv.version_number = (   SELECT  MAX(uv2.version_number)
                                                        FROM    IGS_PS_UNIT_VER uv2
                                                        WHERE   uv2.unit_cd = uv.unit_cd)));
                CURSOR c_ftgv_unitset   IS
                        SELECT          usft.unit_set_cd code,   usft.version_number,
                                lkp.lookup_code trigger_type_code
                        FROM            IGS_EN_UNITSETFEETRG    usft,
                                IGS_EN_UNIT_SET         us,
                                IGS_LOOKUP_VALUES       lkp
                        WHERE           usft.FEE_CAT = p_fee_cat AND
                                usft.fee_cal_type = p_fee_cal_type AND
                                usft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                                usft.FEE_TYPE = p_fee_type AND
                                usft.fee_trigger_group_number = p_fee_trigger_group_number AND
                                lkp.lookup_type = 'IGS_FI_TRIGGER_GROUP' AND
                                lkp.lookup_code = 'UNITSET' AND
                                usft.fee_trigger_group_number IS NOT NULL AND
                                usft.logical_delete_dt IS NULL AND
                                usft.unit_set_cd = us.unit_set_cd AND
                                usft.version_number = us.version_number;

                CURSOR c_ftg_uft        (
                                        cp_unit_cd        IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
                                        cp_version_number
                                                        IGS_EN_SU_ATTEMPT.version_number%TYPE)IS
                        SELECT        uft.unit_cd,
                                uft.version_number,
                                uft.CAL_TYPE,
                                uft.ci_sequence_number,
                                uft.location_cd,
                                uft.UNIT_CLASS,
                                uft.fee_trigger_group_number
                        FROM        IGS_FI_UNIT_FEE_TRG                uft
                        WHERE        uft.FEE_CAT = p_fee_cat AND
                                uft.fee_cal_type = p_fee_cal_type AND
                                uft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                                uft.FEE_TYPE = p_fee_type AND
                                uft.unit_cd = cp_unit_cd AND
                                (uft.version_number IS NULL OR
                                uft.version_number = cp_version_number) AND
                                uft.logical_delete_dt IS NULL;
                CURSOR c_ftg_usft        (
                                        cp_unit_set_cd
                                                IGS_AS_SU_SETATMPT.unit_set_cd%TYPE,
                                        cp_version_number
                                                IGS_AS_SU_SETATMPT.us_version_number%TYPE) IS
                        SELECT        usft.unit_set_cd,
                                usft.version_number,
                                usft.fee_trigger_group_number
                        FROM        IGS_EN_UNITSETFEETRG                usft
                        WHERE        usft.FEE_CAT = p_fee_cat AND
                                usft.fee_cal_type = p_fee_cal_type AND
                                usft.fee_ci_sequence_number = p_fee_ci_sequence_number AND
                                usft.FEE_TYPE = p_fee_type AND
                                usft.unit_set_cd = cp_unit_set_cd AND
                                usft.version_number = cp_version_number AND
                                usft.logical_delete_dt IS NULL;
                v_trigger_group_fired        BOOLEAN;
        BEGIN
                -- check the fee trigger group members
                v_trigger_group_fired := TRUE;
                FOR v_ftgv_rec IN c_ftgv_course LOOP
                -- check for matching student IGS_PS_COURSE attempt
                        IF (v_ftgv_rec.code <> p_course_cd OR
                                NVL(v_ftgv_rec.version_number, p_version_number) <>
                                                                p_version_number) THEN
                                v_trigger_group_fired := FALSE;
                                RETURN v_trigger_group_fired;
                        END IF;
                END LOOP;
                FOR v_ftgv_rec IN c_ftgv_unit LOOP
                        FOR v_ftg_uft_rec IN c_ftg_uft (   v_ftgv_rec.code,
                                                           v_ftgv_rec.version_number) LOOP
                        -- check for matching student IGS_PS_UNIT attempt
                                OPEN c_sua (        v_ftg_uft_rec.unit_cd,
                                                        v_ftg_uft_rec.version_number,
                                                        v_ftg_uft_rec.CAL_TYPE,
                                                        v_ftg_uft_rec.ci_sequence_number,
                                                        v_ftg_uft_rec.location_cd,
                                                        v_ftg_uft_rec.UNIT_CLASS);
                                FETCH c_sua INTO v_check;
                                IF (c_sua%NOTFOUND) THEN
                                        CLOSE c_sua;
                                        v_trigger_group_fired := FALSE;
                                        RETURN v_trigger_group_fired;
                                END IF;
                                CLOSE c_sua;
                        END LOOP;
                END LOOP;
                FOR v_ftgv_rec IN c_ftgv_unitset LOOP
                        FOR v_ftg_usft_rec IN c_ftg_usft (   v_ftgv_rec.code,
                                                             v_ftgv_rec.version_number) LOOP
                        -- check for matching student IGS_PS_UNIT set attempt
                                OPEN c_susa (        v_ftg_usft_rec.unit_set_cd,
                                                     v_ftg_usft_rec.version_number);
                                FETCH c_susa INTO v_check;
                                IF (c_susa%NOTFOUND) THEN
                                        CLOSE c_susa;
                                        v_trigger_group_fired := FALSE;
                                        RETURN v_trigger_group_fired;
                                END IF;
                                CLOSE c_susa;
                        END LOOP;
                END LOOP;
                RETURN v_trigger_group_fired;
        END;
        END finpl_val_trig_group;
--------------------------------------------------------------------------------
        BEGIN        -- finp_get_fee_trigger
                -- This routine checks the students enrolment details to test
                -- for matching a fee trigger.
                IF p_s_fee_trigger_cat IS NULL THEN
                        OPEN        c_ft;
                        FETCH        c_ft        INTO        v_s_fee_trigger_cat;
                        CLOSE        c_ft;
                ELSE
                        v_s_fee_trigger_cat := p_s_fee_trigger_cat;
                END IF;
                -- added AUDIT and SPECIAL In the If condition.
                IF (v_s_fee_trigger_cat = 'INSTITUTN') THEN
                        -- IGS_GE_NOTE, IGS_OR_INSTITUTION fees have no triggers - they always apply.
                        -- Trigger Fired
                        RETURN 'INSTITUTN';
                ELSIF (v_s_fee_trigger_cat = 'COURSE') THEN
                        FOR v_ctft_rec IN c_ctft LOOP
                                -- Trigger Fired
                                RETURN 'CTFT';
                        END LOOP;
                        FOR v_cgft_rec IN c_cgft LOOP
                                -- Trigger Fired
                                RETURN 'CGFT';
                        END LOOP;
                        FOR v_cft_rec IN c_cft LOOP
                                -- Trigger Fired
                                RETURN 'CFT';
                        END LOOP;
                    -- added AUDIT In the If condition.
                ELSIF (v_s_fee_trigger_cat IN ('UNIT','AUDIT')) THEN
                        FOR v_uft_rec IN c_uft LOOP
                                OPEN c_sua (    v_uft_rec.unit_cd,
                                                v_uft_rec.version_number,
                                                v_uft_rec.CAL_TYPE,
                                                v_uft_rec.ci_sequence_number,
                                                v_uft_rec.location_cd,
                                                v_uft_rec.UNIT_CLASS);
                                FETCH c_sua INTO v_check;
                                IF (c_sua%FOUND) THEN
                                        CLOSE c_sua;
                                        -- Trigger Fired
                                        IF(v_s_fee_trigger_cat = 'UNIT') THEN
                                          RETURN 'UFT';
                                        ELSE
                                          RETURN 'AUDIT';
                                        END IF;
                                END IF;
                                CLOSE c_sua;
                        END LOOP;
                ELSIF (v_s_fee_trigger_cat = 'UNITSET') THEN
                        FOR v_usft_rec IN c_usft LOOP
                                OPEN c_susa (        v_usft_rec.unit_set_cd,
                                                v_usft_rec.version_number);
                                FETCH c_susa INTO v_check;
                                IF (c_susa%FOUND) THEN
                                        CLOSE c_susa;
                                        -- Trigger Fired
                                        RETURN 'USFT';
                                END IF;
                                CLOSE c_susa;
                        END LOOP;
                ELSIF (v_s_fee_trigger_cat = 'COMPOSITE') THEN
                        -- check IGS_PS_COURSE fee triggers
                        FOR v_cft_rec IN c_cft LOOP
                                IF (v_cft_rec.fee_trigger_group_number IS NULL) THEN
                                        -- Trigger Fired
                                        RETURN 'CFT';
                                ELSE
                                        -- check the fee trigger group members
                                        IF (finpl_val_trig_group(v_cft_rec.fee_trigger_group_number) = TRUE) THEN
                                                -- Trigger Fired
                                                RETURN 'COMPOSITE';
                                        END IF;
                                END IF;
                        END LOOP;
                        -- check IGS_PS_UNIT fee triggers
                        FOR v_uft_rec IN c_uft LOOP
                                IF (v_uft_rec.fee_trigger_group_number IS NOT NULL) THEN
                                        -- check the fee trigger group members
                                        IF (finpl_val_trig_group(v_uft_rec.fee_trigger_group_number) = TRUE) THEN
                                                -- Trigger Fired
                                                RETURN 'COMPOSITE';
                                        END IF;
                                ELSE
                                        OPEN c_sua        (v_uft_rec.unit_cd,
                                                        v_uft_rec.version_number,
                                                        v_uft_rec.CAL_TYPE,
                                                        v_uft_rec.ci_sequence_number,
                                                        v_uft_rec.location_cd,
                                                        v_uft_rec.UNIT_CLASS);
                                        FETCH c_sua INTO v_check;
                                        IF (c_sua%FOUND) THEN
                                                CLOSE c_sua;
                                                -- Trigger Fired
                                                RETURN 'UFT';
                                        END IF;
                                        CLOSE c_sua;
                                END IF;
                        END LOOP;
                        -- check IGS_PS_UNIT set fee triggers
                        FOR v_usft_rec IN c_usft LOOP
                                IF (v_usft_rec.fee_trigger_group_number IS NOT NULL) THEN
                                        -- check the fee trigger group members
                                        IF (finpl_val_trig_group(v_usft_rec.fee_trigger_group_number) = TRUE) THEN
                                                -- Trigger Fired
                                                RETURN 'COMPOSITE';
                                        END IF;
                                ELSE
                                        OPEN c_susa (        v_usft_rec.unit_set_cd,
                                                        v_usft_rec.version_number);
                                        FETCH c_susa INTO v_check;
                                        IF (c_susa%FOUND) THEN
                                                CLOSE c_susa;
                                                -- Trigger Fired
                                                RETURN 'USFT';
                                        END IF;
                                        CLOSE c_susa;
                                END IF;
                        END LOOP;
                END IF;
                -- Trigger did not fire
                RETURN NULL;
        END;
        END finp_get_fee_trigger;
--
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
RETURN DATE AS

BEGIN
 return NULL;
END finp_get_fps_end_dt;
--
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
RETURN DATE AS
/*----------------------------------------------------------------------------
||  Created By :
||  Created On :
||  Purpose :
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
|| VVUTUKUR      1-DEC-2002      Enh#2584986.Removed references to igs_fi_fee_pay_schd.
  ----------------------------------------------------------------------------*/
BEGIN
 return NULL;
END finp_get_fps_start_dt;
--
FUNCTION finp_get_frtns_end_dt(
  p_fee_cal_type IN IGS_FI_FEE_RET_SCHD.fee_cal_type%TYPE ,
  p_fee_ci_sequence_num IN IGS_FI_FEE_RET_SCHD.fee_ci_sequence_number%TYPE ,
  p_s_relation_type IN IGS_FI_FEE_RET_SCHD.s_relation_type%TYPE ,
  p_fee_type IN IGS_FI_FEE_RET_SCHD.FEE_TYPE%TYPE ,
  p_fee_cat IN IGS_FI_FEE_RET_SCHD.FEE_CAT%TYPE ,
  p_dt_alias IN IGS_FI_FEE_RET_SCHD.DT_ALIAS%TYPE ,
  p_dai_sequence_num IN NUMBER )
RETURN DATE AS

BEGIN
DECLARE
        -- this cursor finds the next retention schedule entry
        -- date alias instance value
        CURSOR c_frtns (cp_fee_cal_type                IGS_FI_FEE_RET_SCHD.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_num        IGS_FI_FEE_RET_SCHD.fee_ci_sequence_number%TYPE,
                        cp_s_relation_type        IGS_FI_FEE_RET_SCHD.s_relation_type%TYPE,
                        cp_fee_type                IGS_FI_FEE_RET_SCHD.FEE_TYPE%TYPE,
                        cp_fee_cat                IGS_FI_FEE_RET_SCHD.FEE_CAT%TYPE,
                        cp_alias_val                IGS_CA_DA_INST_V.alias_val%TYPE) IS
                SELECT        daiv.alias_val
                FROM        IGS_FI_FEE_RET_SCHD        frtns,
                        IGS_CA_DA_INST_V        daiv
                WHERE        frtns.fee_cal_type = cp_fee_cal_type AND
                        frtns.fee_ci_sequence_number = cp_fee_ci_sequence_num AND
                        frtns.s_relation_type = cp_s_relation_type AND
                        NVL(frtns.FEE_TYPE,'NULL') = NVL(cp_fee_type,'NULL') AND
                        NVL(frtns.FEE_CAT,'NULL') = NVL(cp_fee_cat,'NULL') AND
                        daiv.DT_ALIAS =frtns.DT_ALIAS AND
                        daiv.sequence_number = frtns.dai_sequence_number AND
                        daiv.CAL_TYPE = frtns.fee_cal_type AND
                        daiv.ci_sequence_number =frtns.fee_ci_sequence_number AND
                        daiv.alias_val > cp_alias_val
                ORDER BY        daiv.alias_val ASC;
        v_alias_val                IGS_CA_DA_INST_V.alias_val%TYPE;
-------------------------------------------------------------------------------
         FUNCTION finl_get_ass_end_dt(
                p_fee_cal_type                IN IGS_FI_FEE_RET_SCHD.fee_cal_type%TYPE,
                p_fee_ci_sequence_num        IN IGS_FI_FEE_RET_SCHD.fee_ci_sequence_number%TYPE,
                p_s_relation_type                IN IGS_FI_FEE_RET_SCHD.s_relation_type%TYPE,
                p_fee_type                IN IGS_FI_FEE_RET_SCHD.FEE_TYPE%TYPE,
                p_fee_cat                IN IGS_FI_FEE_RET_SCHD.FEE_CAT%TYPE)
        RETURN DATE AS
        BEGIN
        DECLARE
                -- this cursor finds the fee type cal instance end date alias instance value
                CURSOR c_ftci (        cp_fee_type                IGS_FI_F_TYP_CA_INST.FEE_TYPE%TYPE,
                                cp_fee_cal_type                IGS_FI_F_TYP_CA_INST.fee_cal_type%TYPE,
                                cp_fee_ci_sequence_num        IGS_FI_F_TYP_CA_INST.fee_ci_sequence_number%TYPE) IS
                        SELECT        daiv.alias_val
                        FROM        IGS_CA_DA_INST_V        daiv,
                                IGS_FI_F_TYP_CA_INST        ftci
                        WHERE        ftci.FEE_TYPE = cp_fee_type AND
                                ftci.fee_cal_type = cp_fee_cal_type AND
                                ftci.fee_ci_sequence_number = cp_fee_ci_sequence_num AND
                                daiv.DT_ALIAS = ftci.end_dt_alias AND
                                daiv.sequence_number = ftci.end_dai_sequence_number AND
                                daiv.CAL_TYPE = ftci.fee_cal_type AND
                                daiv.ci_sequence_number = ftci.fee_ci_sequence_number;
                -- this cursor finds the fee cat cal instance end date alias instance value
                CURSOR c_fcci (        cp_fee_cat                IGS_FI_F_CAT_CA_INST.FEE_CAT%TYPE,
                                cp_fee_cal_type                IGS_FI_F_CAT_CA_INST.fee_cal_type%TYPE,
                                cp_fee_ci_sequence_num        IGS_FI_F_CAT_CA_INST.fee_ci_sequence_number%TYPE) IS
                        SELECT        daiv.alias_val
                        FROM        IGS_CA_DA_INST_V        daiv,
                                IGS_FI_F_CAT_CA_INST        fcci
                        WHERE        fcci.FEE_CAT = cp_fee_cat AND
                                fcci.fee_cal_type = cp_fee_cal_type AND
                                fcci.fee_ci_sequence_number = cp_fee_ci_sequence_num AND
                                daiv.DT_ALIAS = fcci.end_dt_alias AND
                                daiv.sequence_number = fcci.end_dai_sequence_number AND
                                daiv.CAL_TYPE = fcci.fee_cal_type AND
                                daiv.ci_sequence_number = fcci.fee_ci_sequence_number;
                v_alias_val        IGS_CA_DA_INST_V.alias_val%TYPE;
                BEGIN
                        -- check the retention schedule relationship
                        IF p_s_relation_type = 'FTCI' THEN
                                -- retention schedule is for a fee type cal instance
                                OPEN        c_ftci(        p_fee_type,
                                                p_fee_cal_type,
                                                p_fee_ci_sequence_num);
                                FETCH        c_ftci        INTO        v_alias_val;
                                CLOSE        c_ftci;
                                RETURN        v_alias_val;
                        ELSE
                                -- retention schedule is for a fee cat cal instance or fee cat fee liability
                                OPEN        c_fcci(        p_fee_cat,
                                                p_fee_cal_type,
                                                p_fee_ci_sequence_num);
                                FETCH        c_fcci        INTO        v_alias_val;
                                CLOSE        c_fcci;
                                RETURN        v_alias_val;
                        END IF;
                END;
        END finl_get_ass_end_dt;
-------------------------------------------------------------------------------
        BEGIN
                -- get the alias value for the current schedule
                v_alias_val := IGS_CA_GEN_001.calp_get_alias_val(p_dt_alias,
                                        p_dai_sequence_num,
                                        p_fee_cal_type,
                                        p_fee_ci_sequence_num);
                -- attempt to find the next retention schedule entry
                OPEN        c_frtns(p_fee_cal_type,
                                p_fee_ci_sequence_num,
                                p_s_relation_type,
                                p_fee_type,
                                p_fee_cat,
                                v_alias_val);
                FETCH        c_frtns        INTO        v_alias_val;
                IF (c_frtns%NOTFOUND) THEN
                        -- The fee assessment end date is used
                        CLOSE        c_frtns;
                        RETURN finl_get_ass_end_dt(p_fee_cal_type,
                                        p_fee_ci_sequence_num,
                                        p_s_relation_type,
                                        p_fee_type,
                                        p_fee_cat);
                ELSE
                        -- end alias value is the day prior to the next schedule
                        CLOSE        c_frtns;
                        RETURN        (v_alias_val - 1);
                END IF;
        END;
END finp_get_frtns_end_dt;
--
FUNCTION finp_get_hecs_amt_pd(
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN NUMBER AS
/******************************************************************
  Change History
  Who                 When                 What
  schodava         21-Jan-2002         Enh # 2187247
                                 SFCR021 - LCI-FCI Relation
******************************************************************/

        -- finp_get_hecs_amt_pd
        -- Routine to calculate the HECS amount paid.  DETYA element 381.
        -- If no amount has been paid a zero value is returned.

        cst_hecs        CONSTANT        VARCHAR2(10) := 'HECS';
        cst_payment        CONSTANT        VARCHAR2(10) := 'PAYMENT';
        cst_discount        CONSTANT        VARCHAR2(10) := 'DISCOUNT';
        v_fp_total                        NUMBER;
        v_fee_cal_type                        igs_ca_inst.cal_type%TYPE;
        v_fee_ci_sequence_number        igs_ca_inst.sequence_number%TYPE;
        v_message_name                        fnd_new_messages.message_name%TYPE;

        CURSOR c_fp_total(cp_fee_cal_type IN igs_ca_inst.cal_type%TYPE,
                          cp_fee_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE) IS
                SELECT        SUM(fas.transaction_amount/fas.exchange_rate)
                FROM        IGS_FI_FEE_TYPE                        ft,
                        IGS_FI_FEE_AS                          fas
                WHERE        ft.s_fee_type                        = cst_hecs                AND
                        fas.person_id                        = p_person_id                AND
                        fas.course_cd                        = p_course_cd                AND
                        fas.FEE_TYPE                        = ft.FEE_TYPE                AND
                        fas.S_TRANSACTION_TYPE in
                         (SELECT        strty.lookup_code
                         FROM        IGS_LOOKUPS_view        strty
                         WHERE        strty.lookup_code = fas.S_TRANSACTION_TYPE AND
                                strty.lookup_type = 'TRANSACTION_TYPE' AND
                                 strty.transaction_cat = cst_payment)                 AND
                        fas.S_TRANSACTION_TYPE <> cst_discount                         AND
                         fas.logical_delete_dt  IS NULL                                 AND
                        fas.fee_cal_type                = cp_fee_cal_type        AND
                        fas.fee_ci_sequence_number        = cp_fee_ci_sequence_number;
BEGIN
        -- Enh # 2187247
        -- Derive the related Fee Calendar Instance for the passed Load
        -- Calendar Instance

        IF igs_fi_gen_001.finp_get_lfci_reln(p_load_cal_type,
                                          p_load_ci_sequence_number,
                                          'LOAD',
                                          v_fee_cal_type,
                                          v_fee_ci_sequence_number,
                                          v_message_name) = TRUE THEN
          -- Get the total payments received for fee category fee liability assessments
          -- associated with a HECS fee with respect to the load calendar.
          OPEN c_fp_total(v_fee_cal_type,
                        v_fee_ci_sequence_number);
          FETCH c_fp_total INTO v_fp_total;
          CLOSE c_fp_total;
          IF v_fp_total IS NULL THEN
                -- Record not found
                v_fp_total := 0;
          END IF;
          RETURN v_fp_total;
        ELSE
        -- Enh # 2187247
        -- The LCI cannot be determined
          v_fp_total := 0;
        END IF;
        RETURN v_fp_total;
EXCEPTION
        WHEN OTHERS THEN
                IF c_fp_total%ISOPEN THEN
                        CLOSE c_fp_total;
                END IF;
                RAISE;
END finp_get_hecs_amt_pd;
--
FUNCTION finp_get_hecs_fee(
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN NUMBER AS
/******************************************************************
  Change History
  Who                 When                 What
  uudayapr         12-12-2003       bug#3080983 made the modification to the
                                    Cursor c_fp_total to point to the table
                                    IGS_FI_FEE_AS instead IGS_FI_FEE_ASS_DEBT_V view.
  schodava         21-Jan-2002         Enh # 2187247
                                 SFCR021 - LCI-FCI Relation
******************************************************************/
        -- finp_get_hecs_fee
        -- Routine to determine the HECS Fee assessed for a student IGS_PS_COURSE attempt.

        cst_hecs        CONSTANT        VARCHAR2(4) := 'HECS';
        v_fp_total                        NUMBER;
        v_fee_cal_type                        igs_ca_inst.cal_type%TYPE;
        v_fee_ci_sequence_number        igs_ca_inst.sequence_number%TYPE;
        v_message_name                        fnd_new_messages.message_name%TYPE;
--modification to the    Cursor c_fp_total to point to the table  IGS_FI_FEE_AS instead IGS_FI_FEE_ASS_DEBT_V view.
          CURSOR c_fp_total(cp_fee_cal_type IN igs_ca_inst.cal_type%TYPE,
                            cp_fee_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE) IS
          SELECT  SUM(fadv.transaction_amount/fadv.exchange_rate)  local_assessment_amount
          FROM    IGS_FI_FEE_TYPE                ft,
                  IGS_FI_FEE_AS                  fadv
          WHERE   ft.s_fee_type                  = cst_hecs
          AND     fadv.person_id                 = p_person_id
          AND     ((fadv.course_cd                 = p_course_cd) OR ( fadv.course_cd IS NULL AND  p_course_cd IS NULL))
          AND     fadv.FEE_TYPE                  = ft.FEE_TYPE
          AND     fadv.fee_cal_type              = cp_fee_cal_type
          AND     fadv.fee_ci_sequence_number    = cp_fee_ci_sequence_number
          AND     fadv.logical_delete_dt is NULL;

BEGIN
        -- Enh # 2187247
        -- Derive the related Fee Calendar Instance for the passed Load
        -- Calendar Instance

        IF igs_fi_gen_001.finp_get_lfci_reln(p_load_cal_type,
                                          p_load_ci_sequence_number,
                                          'LOAD',
                                          v_fee_cal_type,
                                          v_fee_ci_sequence_number,
                                          v_message_name) = TRUE THEN

          -- Get the total assessed for fee category fee liability assessments
          -- associated with a HECS fee with respect to the load calendar.
          OPEN c_fp_total(v_fee_cal_type,
                        v_fee_ci_sequence_number);
          FETCH c_fp_total INTO v_fp_total;
          CLOSE c_fp_total;
          IF v_fp_total IS NULL THEN
                -- Record not found
                v_fp_total := 0;
          END IF;
          RETURN v_fp_total;
        ELSE
        -- Enh # 2187247
        -- The LCI cannot be determined
          v_fp_total := 0;
        END IF;
        RETURN v_fp_total;
EXCEPTION
        WHEN OTHERS THEN
                IF c_fp_total%ISOPEN THEN
                        CLOSE c_fp_total;
                END IF;
                RAISE;
END finp_get_hecs_fee;
--
FUNCTION finp_get_hecs_pymnt_optn(
  p_person_id IN IGS_EN_STDNT_PS_ATT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_effective_dt IN DATE ,
  p_fee_cal_type IN IGS_CA_INST_ALL.CAL_TYPE%TYPE ,
  p_fee_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_start_dt_alias IN IGS_FI_F_TYP_CA_INST_ALL.start_dt_alias%TYPE ,
  p_start_dai_sequence_number IN IGS_FI_F_TYP_CA_INST_ALL.start_dai_sequence_number%TYPE,
  p_end_dt_alias IN IGS_FI_F_TYP_CA_INST_ALL.end_dt_alias%TYPE ,
  p_end_dai_sequence_number IN IGS_FI_F_TYP_CA_INST_ALL.end_dai_sequence_number%
TYPE )

RETURN varchar2 AS

BEGIN
DECLARE
        -- cursor to get student IGS_PS_COURSE HECS payment option details
        CURSOR c_scho(
                cp_effective_dt                DATE,
                cp_person_id                IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                cp_course_cd                IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
                SELECT        HECS_PAYMENT_OPTION
                FROM        IGS_EN_STDNTPSHECSOP
                WHERE        person_id                 = cp_person_id AND
                        course_cd                 = cp_course_cd AND
                        TRUNC(cp_effective_dt)         >= TRUNC(start_dt) AND
                        TRUNC(cp_effective_dt)         <= TRUNC(NVL(end_dt, cp_effective_dt));
        v_start_dt                DATE;
        v_end_dt                DATE;
        v_effective_dt                DATE;
        v_hecs_payment_option        IGS_EN_STDNTPSHECSOP.HECS_PAYMENT_OPTION%TYPE;
BEGIN        -- finp_get_hecs_pymnt_optn
        -- Get HECS payment option relevant to a fee assessment period
        -- Check Parameters
        IF p_person_id IS NULL OR
                p_course_cd IS NULL OR
                p_effective_dt IS NULL OR
                p_fee_cal_type IS NULL OR
                p_fee_ci_sequence_number IS NULL OR
                p_start_dt_alias IS NULL OR
                p_start_dai_sequence_number IS NULL OR
                p_end_dt_alias IS NULL OR
                p_end_dai_sequence_number IS NULL THEN
                RETURN NULL;
        END IF;
        v_start_dt := IGS_CA_GEN_001.calp_get_alias_val(
                                p_start_dt_alias,
                                     p_start_dai_sequence_number,
                                     p_fee_cal_type,
                                     p_fee_ci_sequence_number);
        IF v_start_dt IS NULL THEN
                RETURN NULL;
        END IF;
        v_end_dt := IGS_CA_GEN_001.calp_get_alias_val(
                                p_end_dt_alias,
                                     p_end_dai_sequence_number,
                                     p_fee_cal_type,
                                     p_fee_ci_sequence_number);
        IF v_end_dt IS NULL THEN
                RETURN NULL;
        END IF;
        IF v_start_dt > p_effective_dt THEN
                v_effective_dt := v_start_dt;
        ELSIF v_end_dt < p_effective_dt THEN
                v_effective_dt := v_end_dt;
        ELSE
                v_effective_dt := TRUNC(p_effective_dt);
        END IF;
        -- Get the HECS payment option matching the effective date.
        -- IGS_GE_NOTE, later entries may exist.
        OPEN c_scho(
                v_effective_dt,
                p_person_id,
                p_course_cd);
        FETCH c_scho INTO v_hecs_payment_option;
        IF c_scho%NOTFOUND THEN
                CLOSE c_scho;
                RETURN NULL;
        END IF;
        CLOSE c_scho;
        RETURN v_hecs_payment_option;
END;
END finp_get_hecs_pymnt_optn;

--
FUNCTION finp_get_tuition_fee(
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN NUMBER AS
/******************************************************************
  Change History
  Who                 When                 What
  uudayapr         12-12-2003       bug#3080983 made the modification to v_loc_ass_amt
                                    declartion as number instead
                                    IGS_FI_FEE_ASS_DEBT_V.local_assessment_amount%TYPE
                                    and the Cursor c_local_ass_amt to point to the table
                                    IGS_FI_FEE_AS instead IGS_FI_FEE_ASS_DEBT_V view.
                                    Modified teh cst_tuition instialization to TUTNFEE
                                    instead of TUITION .

  schodava         21-Jan-2002         Enh # 2187247
                                   SFCR021 - LCI-FCI Relation
******************************************************************/

        cst_tuition                VARCHAR2(7) := 'TUTNFEE';
        v_loc_ass_amt                NUMBER;
        v_fee_cal_type                        igs_ca_inst.cal_type%TYPE;
        v_fee_ci_sequence_number        igs_ca_inst.sequence_number%TYPE;
        v_message_name                        fnd_new_messages.message_name%TYPE;

        CURSOR c_local_ass_amt(cp_fee_cal_type IN igs_ca_inst.cal_type%TYPE,
                               cp_fee_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE) IS
          SELECT SUM(fadv.transaction_amount/fadv.exchange_rate)  local_assessment_amount
                  FROM    IGS_FI_FEE_TYPE                ft,
                          IGS_FI_FEE_AS                  fadv
                  WHERE  ft.s_fee_type                  = cst_tuition
                  AND    fadv.person_id                  = p_person_id
                  AND    ((fadv.course_cd                  = p_course_cd ) OR (fadv.course_cd IS NULL AND  p_course_cd IS NULL))
                  AND    fadv.FEE_TYPE                  = ft.FEE_TYPE
                  AND    fadv.fee_cal_type              = cp_fee_cal_type
                  AND    fadv.fee_ci_sequence_number    = cp_fee_ci_sequence_number
                  AND    fadv.logical_delete_dt is NULL;
BEGIN
        -- This module determines the tuition fee (DEETYA Element 391).
        -- If a tuition fee is not charged, or the student is in a place
        -- fully-funded by an employer, then a 0 value is returned.
        -- This routine has been developed for use by the statistics
        -- sub-system (STAP_INS_GOVT_SNPSHT).
        -- It will need to be re-written when the finance sub-system
        -- is developed.  It will require a look up on the IGS_FI_FEE_AS
        -- table tuition fee not charged or the student is in a place fully-
        -- funded by an employer.
        -- Get the total assessed for fee category fee liability assessments
        -- associated with a TUITION fee with respect to the load calendar.

        -- Enh # 2187247
        -- Derive the related Fee Calendar Instance for the passed Load
        -- Calendar Instance
        IF igs_fi_gen_001.finp_get_lfci_reln(p_load_cal_type,
                                          p_load_ci_sequence_number,
                                          'LOAD',
                                          v_fee_cal_type,
                                          v_fee_ci_sequence_number,
                                          v_message_name) = TRUE THEN
          OPEN c_local_ass_amt(v_fee_cal_type,
                        v_fee_ci_sequence_number);
          FETCH c_local_ass_amt INTO v_loc_ass_amt;
          IF (c_local_ass_amt%FOUND) THEN
                IF v_loc_ass_amt IS NOT NULL THEN
                        CLOSE c_local_ass_amt;
                        RETURN v_loc_ass_amt;
                ELSE
                        CLOSE c_local_ass_amt;
                        RETURN 0;
                END IF;
          ELSE
                CLOSE c_local_ass_amt;
                RETURN 0;
          END IF;
        ELSE
          -- Enh # 2187247
          -- The LCI cannot be determined
          v_loc_ass_amt := 0;
        END IF;
        RETURN v_loc_ass_amt;

END finp_get_tuition_fee;

FUNCTION finp_get_lfci_reln(
  /******************************************************************
  Created By        : schodava
  Date Created By   : 18-Jan-2002
  Purpose           : This function is used to identify the LCI in the
                      case when FCI is passed and vice versa.
                      Enh # 2187247
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
  ******************************************************************/
  p_cal_type                        IN igs_ca_inst.cal_type%TYPE,
  p_ci_sequence_number                IN igs_ca_inst.sequence_number%TYPE,
  p_cal_category                IN igs_ca_type.s_cal_cat%TYPE,
  p_ret_cal_type                OUT NOCOPY igs_ca_inst.cal_type%TYPE,
  p_ret_ci_sequence_number        OUT NOCOPY igs_ca_inst.sequence_number%TYPE,
  p_message_name                OUT NOCOPY FND_NEW_MESSAGES.MESSAGE_NAME%TYPE)
  RETURN BOOLEAN AS
      -- To derive the subordinate Load Calendar Instance uniquely linked
      -- to the passed superior Fee calendar Instance

      CURSOR  c_cal_inst_rel IS
      SELECT  sub_cal_type,
              sub_ci_sequence_number,
              sup_cal_type,
              sup_ci_sequence_number
      FROM    igs_ca_inst_rel cir,
              igs_ca_type ct1,
              igs_ca_type ct2
      WHERE   cir.sub_cal_type = ct1.cal_type
              AND cir.sup_cal_type = ct2.cal_type
              AND ct1.s_cal_cat IN ('LOAD','FEE')
              AND ct2.s_cal_cat IN ('LOAD','FEE')
              AND ((sub_cal_type = p_cal_type
              AND sub_ci_sequence_number = p_ci_sequence_number)
              OR  (sup_cal_type = p_cal_type
              AND sup_ci_sequence_number = p_ci_sequence_number));

  BEGIN

    IF p_cal_category NOT IN ('FEE','LOAD') THEN
      p_message_name := 'IGS_AD_INVALID_PARAM_COMB';
      RETURN FALSE;
    END IF;

    FOR l_c_cal_inst_rel IN c_cal_inst_rel LOOP
      IF p_cal_category = 'FEE' AND p_ci_sequence_number <> l_c_cal_inst_rel.sub_ci_sequence_number THEN
        p_ret_cal_type                        := l_c_cal_inst_rel.sub_cal_type;
        p_ret_ci_sequence_number        := l_c_cal_inst_rel.sub_ci_sequence_number;
        p_message_name := NULL;
        RETURN TRUE;
      ELSIF p_cal_category = 'LOAD' AND p_ci_sequence_number <> l_c_cal_inst_rel.sup_ci_sequence_number THEN
        p_ret_cal_type                        := l_c_cal_inst_rel.sup_cal_type;
        p_ret_ci_sequence_number        := l_c_cal_inst_rel.sup_ci_sequence_number;
        p_message_name := NULL;
        RETURN TRUE;
      END IF;
    END LOOP;
    p_message_name := 'IGS_FI_NO_RELN_EXISTS';
    RETURN FALSE;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_cal_inst_rel%ISOPEN THEN
        CLOSE c_cal_inst_rel;
      END IF;
      p_message_name := 'IGS_GE_UNHANDLED_EXCEPTION';
      RAISE;
  END finp_get_lfci_reln;

  FUNCTION finp_chk_lfci_reln(
  /******************************************************************
  Created By        : schodava
  Date Created By   : 18-Jan-2002
  Purpose           : This function is used to check if there exists
                      a relation between the passed LCI/FCI with
                      any FCI/LCI
                      (Enh # 2187247)
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
  ******************************************************************/
  p_cal_type                IN        igs_ca_inst.cal_type%TYPE,
  p_ci_sequence_number        IN        igs_ca_inst.sequence_number%TYPE,
  p_cal_category        IN        igs_ca_type.s_cal_cat%TYPE)
  RETURN VARCHAR2 AS

  l_cal_type                igs_ca_inst.cal_type%TYPE;
  l_ci_sequence_number        igs_ca_inst.sequence_number%TYPE;
  l_message_name        FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;

  BEGIN
    IF igs_fi_gen_001.FINP_GET_LFCI_RELN(
       p_cal_type,
       p_ci_sequence_number,
       p_cal_category,
       l_cal_type,
       l_ci_sequence_number,
       l_message_name) THEN
      RETURN 'TRUE';
    ELSE
      RETURN 'FALSE';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
  END finp_chk_lfci_reln;

FUNCTION finp_get_planned_credits_ind(
  p_message_name   OUT NOCOPY fnd_new_messages.message_name%TYPE)

  RETURN VARCHAR2 AS
  /******************************************************************
  Created By        : SYkrishn
  Date Created By   : 02-APR-2002
  Purpose           : This function is used to derive the value of Planned_credits_ind
                      from the table IGS_FI_CONTROL- Return N if Null
                      Enh # 2293676
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
  ******************************************************************/

--Cursor to get the planned credits indicator
    CURSOR  c_pln_credits_ind IS
      SELECT  planned_credits_ind
      FROM    igs_fi_control;

   l_v_pln_credits_ind igs_fi_control_all.planned_credits_ind%TYPE;

  BEGIN
    OPEN c_pln_credits_ind;
    FETCH c_pln_credits_ind INTO l_v_pln_credits_ind;

  --IF no record found then return appropriate error
    IF c_pln_credits_ind%NOTFOUND THEN
        p_message_name := 'IGS_FI_NO_PC_SETUP';
      ELSE
        p_message_name := NULL;
    END IF;
    CLOSE c_pln_credits_ind;
    RETURN NVL(l_v_pln_credits_ind,'N');
  EXCEPTION
    WHEN OTHERS THEN
      p_message_name := 'IGS_GE_UNHANDLED_EXCEPTION';
      RAISE;
  END finp_get_planned_credits_ind;

  FUNCTION finp_get_total_planned_credits(

  p_person_id     IN igs_fi_parties_v.person_id%TYPE,
  p_start_date    IN DATE,
  p_end_date      IN DATE,
  p_message_name  OUT NOCOPY fnd_new_messages.message_name%TYPE)

  RETURN NUMBER AS
  /******************************************************************
  Created By        : SYkrishn
  Date Created By   : 02-APR-2002
  Purpose           : This function is used to sum up all the planned credits in FA based on the parameters input
                      Enh # 2293676
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
  vvutukur 15-Jul-2003 Enh#3038511.FICR106 Build. Modified cursors c_sum_pln_bw_dates,c_sum_pln_till_date
                       to exclude the planned credits for which the Award Year status is not OPEN.
  sarakshi 23-sep-2002 Enh#2564643,removed the reference of subaccount and all its usage in this function
  ******************************************************************/
   CURSOR  c_person_id IS
    SELECT  person_id
    FROM    igs_fi_parties_v
    WHERE   person_id = p_person_id;


   CURSOR c_sum_pln_bw_dates IS
     SELECT
        SUM(disb.disb_net_amt )
     FROM
        igf_aw_awd_disb disb,
        igf_aw_award   awd,
        igf_aw_fund_mast fmast,
        igf_ap_fa_base_rec base,
        igf_ap_batch_aw_map bm
     WHERE  disb.award_id = awd.award_id
     AND    awd.fund_id = fmast.fund_id
     AND    awd.base_id = base.base_id
     AND    fmast.ci_cal_type = bm.ci_cal_type
     AND    fmast.ci_sequence_number = bm.ci_sequence_number
     AND    awd.award_status ='ACCEPTED'
     AND    disb.trans_type   = 'P'
     AND    disb.show_on_bill   = 'Y'
     AND    base.person_id = p_person_id
     AND    TRUNC(disb.disb_date) BETWEEN TRUNC(p_start_date) and TRUNC(p_end_date)
     AND    bm.award_year_status_code = 'O';

   CURSOR c_sum_pln_till_date IS
     SELECT
        SUM(disb.disb_net_amt )
     FROM
        igf_aw_awd_disb disb,
        igf_aw_award   awd,
        igf_aw_fund_mast fmast,
        igf_ap_fa_base_rec base,
        igf_ap_batch_aw_map bm
     WHERE  disb.award_id = awd.award_id
     AND    awd.fund_id = fmast.fund_id
     AND    awd.base_id = base.base_id
     AND    fmast.ci_cal_type = bm.ci_cal_type
     AND    fmast.ci_sequence_number = bm.ci_sequence_number
     AND    awd.award_status ='ACCEPTED'
     AND    disb.trans_type   = 'P'
     AND    disb.show_on_bill   = 'Y'
     AND    base.person_id = p_person_id
     AND    TRUNC(disb.disb_date) <= TRUNC(p_end_date)
     AND    bm.award_year_status_code = 'O';

   l_n_person_id igs_fi_parties_v.person_id%TYPE;
   l_n_sum_pln_credits igf_aw_awd_disb.disb_net_amt%TYPE;

  BEGIN

    IF (p_person_id IS NULL OR p_end_date IS NULL)  THEN
          p_message_name := 'IGS_GE_INSUFFICIENT_PARAMETER';
          RETURN 0;
    END IF;


    IF TRUNC(p_end_date) > TRUNC(sysdate) THEN
        p_message_name := 'IGS_EN_ENDDT_LE_CURR_DT';
        RETURN 0;
    END IF;

    IF p_start_date IS NOT NULL THEN
        IF TRUNC(p_start_date) > TRUNC(p_end_date) THEN
          p_message_name := 'IGS_FI_END_DT_LESS_THAN_ST_DT';
          RETURN 0;
        END IF;
    END IF;

    OPEN c_person_id;
    FETCH c_person_id INTO l_n_person_id;
      IF c_person_id%NOTFOUND THEN
          p_message_name := 'IGS_AD_INVALID_PERSON';
          CLOSE c_person_id;
          RETURN 0;
      END IF;
    CLOSE c_person_id;


    IF p_start_date IS NULL THEN
       OPEN  c_sum_pln_till_date;
       FETCH c_sum_pln_till_date INTO l_n_sum_pln_credits;
       CLOSE c_sum_pln_till_date;
    ELSE
       OPEN  c_sum_pln_bw_dates;
       FETCH c_sum_pln_bw_dates INTO l_n_sum_pln_credits;
       CLOSE c_sum_pln_bw_dates;
    END IF;

    RETURN NVL(l_n_sum_pln_credits,0);

  EXCEPTION
    WHEN OTHERS THEN
      p_message_name := 'IGS_GE_UNHANDLED_EXCEPTION';
      RAISE;
  END finp_get_total_planned_credits;

END igs_fi_gen_001;

/
