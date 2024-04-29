--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FAS" AS
/* $Header: IGSFI23B.pls 120.2 2006/02/23 21:33:05 skharida noship $ */
/* Who                 When                    What
   skharida            09-feb-2006             Bug# 5018036 - SQL Tuning, changed to IGS_LOOKUPS_VAL instead to IGS_LOOKUPS_VIEW.
   uudayapr            07-dec-2004             ENH# 3167098, Modified finp_val_fas_ass_ind.
   shtatiko            24-DEC-2003             Enh# 3167098, Modified finp_val_fas_ass_ind.
   uudayapr            12-dec-2003             Bug#3080983 Modified the cursor c_fadv in the Function
                                               finp_val_fas_balance .
   vvutukur            19-Dec-2002             Bug#2680885. Modified finp_val_fas_balance.
   masehgal            17-Jan-2002             ENH # 2170429
                                               Obsoletion of SPONSOR_CD related Parameters and Check from Function FINP_VAL_FAS_UPD
  schodava         28-NOV-2001         Enh # 2122257 : Implements the CR for 'Fee Category Change'
                 Change in function finp_val_fas_ass_ind
   jbegum              26-Nov-2001             As part of bug #2040038
                                               1)Replaced RAISE NO_DATA_FOUND in code with message IGS_FI_FEE_ASS_DAT
                                               2)In the procedure finp_val_fas_upd TRUNC function was added in the IF condition
                                                 checks being done on effective_dt and transaction_dt
*/
  --
  -- Validate fee assessable indicator value.
  FUNCTION finp_val_fas_ass_ind(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_transaction_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 DEFAULT NULL,
  p_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  uudayapr        07-dec-2004     Enh# 3167098, Modified cursor c_sca_scas and added the logic for deriving the
                                                Load calendar type and sequence number.
  shtatiko        24-DEC-2003     Enh# 3167098, Modified cursor c_sca_scas.
  SCHODAVA    28-NOV-2001     Enh # 2122257
        (SFCR015 : Change In Fee Category)
        Changed the signature of this function.
        Added params fee_cal_type and fee_ci_sequence_number
  (reverse chronological order - newest change first)
  ***************************************************************/
    gv_other_detail    VARCHAR2(255);
  BEGIN  --finp_val_fas_ass_ind
    --validate IGS_FI_FEE_AS.course_cd has a course_attempt_status with a fee_ass_ind
    --of 'Y'
  DECLARE
    v_system_generated_ind  IGS_LOOKUPS_VAL.system_generated_ind%TYPE;
    v_fee_ass_ind    IGS_LOOKUPS_VAL.fee_ass_ind%TYPE;
    v_course_attempt_status  IGS_LOOKUPS_VAL.lookup_code%TYPE;
    -- added this variable for stroing the load calendar derived data.
    l_v_load_cal_type  igs_fi_f_cat_ca_inst.fee_cal_type%TYPE;
    l_n_load_ci_seq_number igs_fi_f_cat_ca_inst.fee_ci_sequence_number%TYPE;
    CURSOR  c_strty IS
      SELECT  strty.system_generated_ind
      FROM  IGS_LOOKUPS_VAL strty
      WHERE  strty.lookup_code = p_transaction_type AND
        strty.lookup_type = 'TRANSACTION_TYPE';

        -- Enh# 3167098, Removed reference to igs_fi_f_cat_cal_rel and igs_fi_stdnt_ps_att_cat_v
        -- Modified The Select  Clause Of The Cursor
  CURSOR c_sca_scas IS
    SELECT scas.fee_ass_ind,
           std.course_attempt_status
    FROM  igs_en_spa_terms   sca,
          igs_en_stdnt_ps_att std,
          igs_lookups_view  scas
    WHERE sca.person_id      = p_person_id
    AND sca.program_cd = p_course_cd
    AND sca.term_cal_type = l_v_load_cal_type
    AND sca.term_sequence_number = l_n_load_ci_seq_number
    AND sca.person_id = std.person_id
    AND sca.program_cd = std.course_cd
    AND ((sca.fee_cat IS NULL AND p_fee_cat IS NULL ) OR ( sca.fee_cat = p_fee_cat))
    AND scas.lookup_type = 'CRS_ATTEMPT_STATUS'
    AND scas.lookup_code =  std.course_attempt_status;

    CURSOR c_scaehv IS
      SELECT  scas.fee_ass_ind,
        scaehv.course_attempt_status
       FROM  IGS_AS_SCAH_EFFECTIVE_H_V   scaehv,
          IGS_LOOKUPS_VIEW  scas
       WHERE
         scaehv.person_id    = p_person_id              AND
        scaehv.course_cd    = p_course_cd              AND
      ((scaehv.fee_cat    IS NULL                AND
      p_fee_cat      IS NULL)              OR
      (scaehv.fee_cat      = p_fee_cat))              AND
      scas.lookup_type    = 'CRS_ATTEMPT_STATUS'            AND
        TRUNC(p_effective_dt)    BETWEEN scaehv.effective_start_dt AND scaehv.effective_end_dt  AND
        scas.lookup_code    = scaehv.course_attempt_status;


  BEGIN
    --Set the default message number
    p_message_name := NULL;
    --Validate parameters (all must have values to proceed with validation)
    IF (p_person_id IS NULL OR
        p_course_cd    IS NULL OR
        p_fee_cat    IS NULL OR
        p_effective_dt    IS NULL OR
        p_transaction_type  IS NULL OR
      p_fee_cal_type    IS NULL OR
      p_fee_ci_sequence_number IS NULL) THEN
      RETURN TRUE;
    END IF;
    OPEN c_strty;
    FETCH c_strty INTO v_system_generated_ind;
    CLOSE c_strty;
    IF (v_system_generated_ind = 'N') THEN
      -- Get student IGS_PS_COURSE attempt detail
      IF TRUNC(p_effective_dt) >= TRUNC(SYSDATE) THEN
      --derive the load calendar from the fee calendar data to be used in
        IF NOT igs_fi_gen_001.finp_get_lfci_reln  ( p_cal_type              => p_fee_cal_type,
                                                  p_ci_sequence_number     => p_fee_ci_sequence_number,
                                                  p_cal_category           => 'FEE',
                                                  p_ret_cal_type           => l_v_load_cal_type,
                                                  p_ret_ci_sequence_number => l_n_load_ci_seq_number,
                                                  p_message_name            =>p_message_name) THEN
          RETURN FALSE;
        END IF;
       -- use current data
        OPEN c_sca_scas;
        FETCH c_sca_scas INTO   v_fee_ass_ind,
              v_course_attempt_status;
        IF (c_sca_scas%NOTFOUND) THEN
          CLOSE c_sca_scas;
          p_message_name := 'IGS_FI_FEE_ASS_DAT';
          RETURN FALSE;
        END IF;
        CLOSE c_sca_scas;
      ELSE -- look back into history
        OPEN c_scaehv;
        FETCH c_scaehv INTO   v_fee_ass_ind,
              v_course_attempt_status;
        IF (c_scaehv%NOTFOUND) THEN
          CLOSE c_scaehv;
          p_message_name := 'IGS_FI_FEE_ASS_DAT';
          RETURN FALSE;
        END IF;
        CLOSE c_scaehv;
      END IF;
      -- Test student IGS_PS_COURSE attempt is fee assessible
      IF v_fee_ass_ind = 'N' THEN
        IF v_course_attempt_status <> 'UNCONFIRM' THEN
          p_message_name := 'IGS_FI_STUD_PRGATTEM_STATUS_Y' ;
          RETURN FALSE;
        ELSE
          p_message_name := 'IGS_FI_STUD_PRGATT_STATUS_Y' ;
          RETURN TRUE;  -- warning only
        END IF;
      END IF;
    END IF;
    RETURN TRUE;
  END;
  END finp_val_fas_ass_ind;
  --
  -- Validate retrospective date of fee assessment period.
  FUNCTION finp_val_fas_retro(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
    gv_other_detail    VARCHAR2(255);
  BEGIN  --finp_val_fas_retro
    --validate the current date against any retrospective assessment period
    --when recording a manual fee assessment.
    --Current date must be <= IGS_FI_F_CAT_FEE_LBL_V.retro_dt (if specified,
    --may be null)
  DECLARE
    v_alias_val  IGS_CA_DA_INST_V.alias_val%TYPE;
    CURSOR c_fcflv IS
      SELECT  daiv.alias_val
       FROM  IGS_FI_F_CAT_FEE_LBL_V fcflv,
        IGS_CA_DA_INST_V daiv
       WHERE
         fcflv.fee_cal_type    = p_fee_cal_type      AND
         fcflv.fee_ci_sequence_number   = p_fee_ci_sequence_number   AND
         fcflv.fee_type       = p_fee_type       AND
         fcflv.fee_cat       = p_fee_cat       AND
         fcflv.retro_dt_alias     = daiv.dt_alias     AND
         fcflv.retro_dai_sequence_number = daiv.sequence_number     AND
         fcflv.fee_cal_type     = daiv.cal_type     AND
         fcflv.fee_ci_sequence_number   = daiv.ci_sequence_number  AND
        daiv.alias_val      < SYSDATE;
  BEGIN
    --Set the default message number
    p_message_name := NULL;
    --Validate parameters
    IF (p_fee_type IS NULL OR
        p_fee_cal_type     IS NULL OR
        p_fee_ci_sequence_number IS NULL OR
        p_fee_cat     IS NULL) THEN
      RETURN TRUE;
    END IF;
    --If a record exists then daiv.alias_val > SYSDATE so set p_message_name
    OPEN c_fcflv;
    FETCH c_fcflv INTO v_alias_val;
    IF (c_fcflv%FOUND) THEN
      p_message_name := 'IGS_FI_RETRO_ASS_DATE';
      CLOSE c_fcflv;
      RETURN FALSE;
    END IF;
    CLOSE c_fcflv;
    RETURN TRUE;
  END;
  END finp_val_fas_retro;
  --
  -- Validate IGS_FI_FEE_AS.SI_FI_S_TRN_TYPE for a manual assessment.
  FUNCTION finp_val_fas_cat(
  p_transaction_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
    gv_other_detail    VARCHAR2(255);
  BEGIN  --finp_val_fas_cat
    --This module validates IGS_FI_FEE_AS.SI_FI_S_TRN_TYPE.
    --SI_FI_S_TRN_TYPE.transaction_cat must equal 'DEBT' and
    --s_tranaction_type.system_generated_ind must equal 'N'
  DECLARE
    v_transaction_cat  IGS_LOOKUPS_VAL.transaction_cat%TYPE;
    v_sys_generated_ind  IGS_LOOKUPS_VAL.system_generated_ind%TYPE;
    CURSOR c_strty IS
      SELECT   strty.transaction_cat,
        strty.system_generated_ind
      FROM  IGS_LOOKUPS_VAL strty
      WHERE  lookup_code = p_transaction_type AND
        lookup_type = 'TRANSACTION_TYPE';
  BEGIN
    --- Set the default message number
    p_message_name := NULL;
    --validate parameter
    IF (p_transaction_type IS NULL) THEN
      RETURN TRUE;
    END IF;
    --Get the system transaction category and system generated indicator
    --values for the tranaction_type. If not 'DEBT' and 'N' respectively,
    --return error.
    OPEN c_strty;
    FETCH c_strty INTO v_transaction_cat,
           v_sys_generated_ind;
    CLOSE c_strty;
    IF (v_transaction_cat <> 'DEBT') THEN
      p_message_name := 'IGS_FI_TRANSTYPE_CAT_DEBT';
      RETURN FALSE;
    END IF;
    IF (v_sys_generated_ind <> 'N') THEN
      p_message_name := 'IGS_FI_TRANSTYPE_SYSIND_N';
      RETURN FALSE;
    END IF;
    RETURN TRUE;
  END;
  END finp_val_fas_cat;
  --
  -- Check if contract fee assessment rate exists for the student.
  FUNCTION finp_val_fas_cntrct(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
    gv_other_detail    VARCHAR2(255);
  BEGIN  --finp_val_fas_cntrct
    --This module validates if the student has a contract fee assessment rate
    --when recording a manual fee assessment. If so issue a warning.
  DECLARE
    v_cfar_rec  CHAR;
    CURSOR c_cfar IS
      SELECT   'X'
      FROM  IGS_FI_FEE_AS_RT cfar
      WHERE  cfar.person_id  = p_person_id  AND
        cfar.course_cd  = p_course_cd  AND
        cfar.fee_type  = p_fee_type  AND
        p_effective_dt  BETWEEN cfar.start_dt AND
           NVL(cfar.end_dt, igs_ge_date.igsdate('9999/01/01'));
  BEGIN
    --- Set the default message number
    p_message_name := NULL;
    --validate parameters
    IF (p_fee_type IS NULL  OR
        p_course_cd  IS NULL  OR
        p_fee_type   IS NULL  OR
        p_effective_dt  IS NULL) THEN
      RETURN TRUE;
    END IF;
    --Determine if a IGS_FI_FEE_AS_RT exists
    OPEN c_cfar;
    FETCH c_cfar INTO v_cfar_rec;
    IF (c_cfar%FOUND) THEN
      p_message_name := 'IGS_FI_STUD_ACTIVE_CONT_FEEAS';
      CLOSE c_cfar;
      RETURN FALSE;
    END IF;
    CLOSE c_cfar;
    RETURN TRUE;
  END;
  END finp_val_fas_cntrct;
  --
  -- Validate that appropriate optional fields are entered for IGS_FI_FEE_AS.
  FUNCTION finp_val_fas_create(
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_cat IN IGS_FI_FEE_CAT_ALL.fee_cat%TYPE ,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
    gv_other_detail    VARCHAR2(255);
  BEGIN  --finp_val_fas_create
    --This module validates IGS_FI_FEE_AS.IGS_FI_FEE_TYPE with the fee category and
    -- IGS_PS_COURSE code.
    --If IGS_FI_FEE_TYPE.s_fee_trigger_cat = 'INSTITUTN',then fee category and
    --course_cd cannot be specified in the IGS_FI_FEE_AS record. Otherwise they
    --must be specified
  DECLARE
    v_fee_trigger_cat  IGS_FI_FEE_TYPE.s_fee_trigger_cat%TYPE;
    CURSOR c_ft IS
      SELECT   ft.s_fee_trigger_cat
      FROM  IGS_FI_FEE_TYPE ft
      WHERE  fee_type = p_fee_type;

    CURSOR c_fee_calc_mthd IS
      SELECT fee_calc_mthd_code
      FROM igs_fi_control;
    l_v_fee_calc_mthd igs_fi_control.fee_calc_mthd_code%TYPE;

  BEGIN
    --- Set the default message number
    p_message_name := NULL;
    --validate parameters
    IF (p_fee_type IS NULL) THEN
      RETURN TRUE;
    END IF;
    --Determine the s_fee_trigger_cat
    OPEN c_ft;
    FETCH c_ft INTO v_fee_trigger_cat;
    IF (c_ft%NOTFOUND) THEN
      CLOSE c_ft;
      p_message_name := 'IGS_FI_FEE_ASS_DAT';
            RETURN FALSE;
    END IF;
    CLOSE c_ft;

    OPEN c_fee_calc_mthd;
    FETCH c_fee_calc_mthd INTO l_v_fee_calc_mthd;
    CLOSE c_fee_calc_mthd;

    -- Enh# 3167098, In case of Primary Career, For Institution fee we store Fee category and Course Code (From Key Program).
    IF (v_fee_trigger_cat = 'INSTITUTN' AND l_v_fee_calc_mthd <> 'PRIMARY_CAREER' AND
        (p_fee_cat IS NOT NULL OR
        p_course_cd IS NOT NULL)) THEN
      p_message_name := 'IGS_FI_PRGCD_CAT_NULL';
      RETURN FALSE;
    END IF;
    IF (v_fee_trigger_cat <> 'INSTITUTN' AND
        (p_fee_cat IS NULL OR
        p_course_cd IS NULL)) THEN
      p_message_name := 'IGS_FI_PRGCD_CAT_INSTITUTN';
      RETURN FALSE;
    END IF;
    RETURN TRUE;
  END;
  END finp_val_fas_create;
  --
  -- Ensure comment is recorded for a manual fee assessment.
  FUNCTION finp_val_fas_com(
  p_transaction_type IN VARCHAR2 ,
  p_comments IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
    gv_other_detail    VARCHAR2(255);
  BEGIN  --finp_val_fas_com
    --This module validates IGS_FI_FEE_AS.comments.
    --IGS_FI_FEE_AS.comments cannot be NULL when a manual fee assessment record is
    --created
  DECLARE
    v_transaction_cat  IGS_LOOKUPS_VAL.transaction_cat%TYPE;
    v_sys_generated_ind  IGS_LOOKUPS_VAL.system_generated_ind%TYPE;
    CURSOR c_strty IS
      SELECT   strty.transaction_cat,
        strty.system_generated_ind
        FROM  IGS_LOOKUPS_VAL strty
      WHERE  lookup_code = p_transaction_type AND
	lookup_type = 'TRANSACTION_TYPE';
  BEGIN
    --- Set the default message number
    p_message_name := NULL;
    --validate parameter
    IF (p_transaction_type IS NULL) THEN
      RETURN TRUE;
    END IF;
    --Get the system transaction category and system generated indicator
    --values for the tranaction_type. If the values indicate a manual entry
    --then verify that comments field is NOT NULL
    OPEN c_strty;
    FETCH c_strty INTO v_transaction_cat,
           v_sys_generated_ind;
    CLOSE c_strty;
    IF (v_transaction_cat = 'DEBT' AND
        v_sys_generated_ind = 'N') THEN
      IF (p_comments IS NULL) THEN
        p_message_name := 'IGS_GE_MANDATORY_FLD';
        RETURN FALSE;
      END IF;
    END IF;
    RETURN TRUE;
  END;
  END finp_val_fas_com;
  --
  -- Validate effective date of fee assessment.
  FUNCTION finp_val_fas_eff_dt(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_s_transaction_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  gv_other_detail    VARCHAR2(255);
  BEGIN  -- finp_val_fas_eff_dt
    -- This module validates the effective_dt when recording a manual fee
    -- assessment, effective_dt must be between IGS_FI_F_CAT_FEE_LBL_V.start_dt
    -- and IGS_FI_F_CAT_FEE_LBL_V.end_dt.
  DECLARE
    v_start_dt    IGS_CA_DA_INST_V.alias_val%TYPE;
    v_end_dt    IGS_CA_DA_INST_V.alias_val%TYPE;
    v_transaction_cat   IGS_LOOKUPS_VAL.transaction_cat%TYPE;
    CURSOR c_daiv_sd IS
      SELECT  daiv.alias_val
      FROM   IGS_FI_F_CAT_FEE_LBL_V  fcflv,
        IGS_CA_DA_INST_V  daiv
      WHERE  fcflv.fee_cal_type    = p_fee_cal_type    AND
        fcflv.fee_ci_sequence_number  = p_fee_ci_sequence_number  AND
        fcflv.fee_type      = p_fee_type      AND
        fcflv.fee_cat    = nvl(p_fee_cat,fcflv.fee_cat)    AND
        fcflv.start_dt_alias    = daiv.dt_alias      AND
        fcflv.start_dai_sequence_number  = daiv.sequence_number    AND
        fcflv.fee_cal_type    = daiv.cal_type      AND
        fcflv.fee_ci_sequence_number  = daiv.ci_sequence_number;
    CURSOR c_daiv_ed IS
      SELECT  daiv.alias_val
      FROM  IGS_FI_F_CAT_FEE_LBL_V  fcflv,
        IGS_CA_DA_INST_V  daiv
      WHERE  fcflv.fee_cal_type    = p_fee_cal_type    AND
        fcflv.fee_ci_sequence_number  = p_fee_ci_sequence_number  AND
        fcflv.fee_type      = p_fee_type      AND
        fcflv.fee_cat    = nvl(p_fee_cat,fcflv.fee_cat)    AND
        fcflv.end_dt_alias    = daiv.dt_alias      AND
        fcflv.end_dai_sequence_number  = daiv.sequence_number    AND
        fcflv.fee_cal_type    = daiv.cal_type      AND
        fcflv.fee_ci_sequence_number  = daiv.ci_sequence_number;
    CURSOR c_strty IS
      SELECT strty.transaction_cat
    FROM  IGS_LOOKUPS_VAL strty
    WHERE  strty.lookup_code = p_s_transaction_type
    AND      strty.lookup_type = 'TRANSACTION_TYPE';

  BEGIN
    --- Set the default message number
    p_message_name := NULL;
    --- Check what transaction_type maps to: DEBT or PAYMENT
    --- Payment is not subject to the validation.
    OPEN c_strty;
    FETCH c_strty INTO v_transaction_cat;
    IF (c_strty%NOTFOUND) THEN
      CLOSE c_strty;
      p_message_name := 'IGS_FI_FEE_ASS_DAT';
      RETURN FALSE;
    END IF;
    CLOSE c_strty;
    IF v_transaction_cat = 'PAYMENT' THEN
      RETURN TRUE;
    END IF;
    --validate parameters
    IF (p_fee_type   IS NULL OR
        p_fee_cal_type     IS NULL OR
        p_fee_ci_sequence_number IS NULL OR
        p_effective_dt     IS NULL) THEN
      RETURN TRUE;
    END IF;

    --Get the start date value of the liability
    OPEN c_daiv_sd;
    FETCH c_daiv_sd INTO v_start_dt;
    IF (c_daiv_sd%NOTFOUND) THEN
      CLOSE c_daiv_sd;
      p_message_name := 'IGS_FI_FEE_ASS_DAT';
      RETURN FALSE;
    END IF;
    CLOSE c_daiv_sd;
    --Get the end date value of the liability
    OPEN c_daiv_ed;
    FETCH c_daiv_ed INTO v_end_dt;
    IF (c_daiv_ed%NOTFOUND) THEN
      CLOSE c_daiv_ed;
      p_message_name := 'IGS_FI_FEE_ASS_DAT';
      RETURN FALSE;
    END IF;
    CLOSE c_daiv_ed;
    --Check that effective date is between the start and end dates
    IF (TRUNC(p_effective_dt) NOT BETWEEN  TRUNC(v_start_dt) AND
              TRUNC(v_end_dt)) THEN
      p_message_name := 'IGS_FI_EFFDT_NOTBE_OUTSIDE';
      RETURN FALSE;
    END IF;
    RETURN TRUE;
  END;
  END finp_val_fas_eff_dt;
  --
  -- Validate effect of transaction amount on student's balance.
  FUNCTION finp_val_fas_balance(
  p_person_id IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_transaction_amount IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
      uudayapr         12-12-2003   bug#3080983 made the modification to v_total_amount_due
                                    declartion as number instead
                                    IGS_FI_FEE_ASS_DEBT_V.local_assessment_amount%TYPE
                                    and the Cursor c_fadv to point to the table
                                    IGS_FI_FEE_AS instead IGS_FI_FEE_ASS_DEBT_V view.

  ||  vvutukur        19-Dec-2002  Bug#2680885.Commented out cursor c_fpv which selects from igs_fi_fee_pay_v, which
  ||                               is to be dropped.Instead, cursor c_fpv is redefined selecting 0 from dual.
  ||                               The datatype for v_total_payments variable is also changed to NUMBER after removing
  ||                               the reference to igs_fi_fee_pay_v.
  ----------------------------------------------------------------------------*/

    gv_other_detail  VARCHAR2(255);

  BEGIN  --finp_val_fas_balance
    --This module validates that the current manual fee assessment will not
    --cause the students balance for the liability to be less than zero
  DECLARE
    v_total_amount_due  NUMBER;
    v_total_payments   NUMBER;
    --Modified the cursor to fetch data from the Base table instead of the view IGS_FI_FEE_ASS_DEBT_V
    CURSOR c_fadv IS
      SELECT  SUM(fadv.transaction_amount)
        FROM   IGS_FI_FEE_AS fadv
        WHERE  fadv.person_id      = p_person_id
        AND    fadv.fee_type      = p_fee_type
        AND    fadv.fee_cal_type    = p_fee_cal_type
        AND    fadv.fee_ci_sequence_number  = p_fee_ci_sequence_number
        AND   ((fadv.fee_cat = p_fee_cat) OR(fadv.fee_cat IS NULL AND p_fee_cat IS NULL))
        AND   ((fadv.course_cd = p_course_cd)  OR (fadv.course_cd IS NULL AND p_course_cd IS NULL))
        AND   fadv.logical_delete_dt IS NULL;

        CURSOR c_fpv IS
          SELECT 0
          FROM   dual;

/*    CURSOR c_fpv IS
      SELECT  SUM(fpv.payment_amount)
      FROM  IGS_FI_FEE_PAY_V  fpv
      WHERE  fpv.person_id      = p_person_id      AND
        fpv.fee_type      = p_fee_type      AND
        fpv.fee_cal_type    = p_fee_cal_type    AND
        fpv.fee_ci_sequence_number  = p_fee_ci_sequence_number  AND
        NVL(fpv.fee_cat, 'NULL')  = NVL(p_fee_cat, 'NULL')  AND
        NVL(fpv.course_cd,'NULL')   = NVL(p_course_cd,'NULL');*/
  BEGIN
    --- Set the default message number
    p_message_name := NULL;
    --validate parameters
    IF (p_person_id IS NULL  OR
        p_fee_type      IS NULL OR
        p_fee_cal_type     IS NULL OR
        p_fee_ci_sequence_number IS NULL) THEN
      RETURN TRUE;
    END IF;
    --Determine the total amount owing
    OPEN c_fadv;
    FETCH c_fadv INTO v_total_amount_due;
    CLOSE c_fadv;
    --Determine the total payments
    OPEN c_fpv;
    FETCH c_fpv INTO v_total_payments;
    CLOSE c_fpv;
    --Check if the amount owing will be less than zero.(subtract the total payments
    --from the total owing to get the current balance).
    IF ((NVL(v_total_amount_due, 0) - NVL(v_total_payments, 0))
      + NVL(p_transaction_amount, 0) < 0) THEN
      p_message_name := 'IGS_FI_STUDBAL_LT_ZERO';
      RETURN FALSE;
    END IF;
    RETURN TRUE;
  END;
  END finp_val_fas_balance;
  --
  -- Validate update to columns in the IGS_FI_FEE_AS table.

-- Change History
-- Who              When           What
-- masehgal         17-Jan-2002    ENH # 2170429
--                                 Obsoletion of SPONSOR_CD related Parameters from Function FINP_VAL_FAS_UPD

  FUNCTION finp_val_fas_upd(
  p_new_person_id  IGS_FI_FEE_AS_ALL.person_id%TYPE ,
  p_old_person_id  IGS_FI_FEE_AS_ALL.person_id%TYPE ,
  p_new_transaction_id  IGS_FI_FEE_AS_ALL.transaction_id%TYPE ,
  p_old_transaction_id  IGS_FI_FEE_AS_ALL.transaction_id%TYPE ,
  p_new_fee_type  IGS_FI_FEE_AS_ALL.fee_type%TYPE ,
  p_old_fee_type  IGS_FI_FEE_AS_ALL.fee_type%TYPE ,
  p_new_fee_cal_type  IGS_FI_FEE_AS_ALL.fee_cal_type%TYPE ,
  p_old_fee_cal_type  IGS_FI_FEE_AS_ALL.fee_cal_type%TYPE ,
  p_new_fee_ci_seq_num  IGS_FI_FEE_AS_ALL.fee_ci_sequence_number%TYPE ,
  p_old_fee_ci_seq_num  IGS_FI_FEE_AS_ALL.fee_ci_sequence_number%TYPE ,
  p_new_fee_cat  IGS_FI_FEE_AS_ALL.fee_cat%TYPE ,
  p_old_fee_cat  IGS_FI_FEE_AS_ALL.fee_cat%TYPE ,
  p_new_transaction_type  IGS_FI_FEE_AS_ALL.s_transaction_type%TYPE ,
  p_old_transaction_type  IGS_FI_FEE_AS_ALL.s_transaction_type%TYPE ,
  p_new_transaction_dt  IGS_FI_FEE_AS_ALL.transaction_dt%TYPE ,
  p_old_transaction_dt  IGS_FI_FEE_AS_ALL.transaction_dt%TYPE ,
  p_new_transaction_amount  IGS_FI_FEE_AS_ALL.transaction_amount%TYPE ,
  p_old_transaction_amount  IGS_FI_FEE_AS_ALL.transaction_amount%TYPE ,
  p_new_currency_cd  IGS_FI_FEE_AS_ALL.currency_cd%TYPE ,
  p_old_currency_cd  IGS_FI_FEE_AS_ALL.currency_cd%TYPE ,
  p_new_exchange_rate  IGS_FI_FEE_AS_ALL.exchange_rate%TYPE ,
  p_old_exchange_rate  IGS_FI_FEE_AS_ALL.exchange_rate%TYPE ,
  p_new_chg_elements  IGS_FI_FEE_AS_ALL.chg_elements%TYPE ,
  p_old_chg_elements  IGS_FI_FEE_AS_ALL.chg_elements%TYPE ,
  p_new_effective_dt  IGS_FI_FEE_AS_ALL.effective_dt%TYPE ,
  p_old_effective_dt  IGS_FI_FEE_AS_ALL.effective_dt%TYPE ,
  p_new_course_cd  IGS_FI_FEE_AS_ALL.course_cd%TYPE ,
  p_old_course_cd  IGS_FI_FEE_AS_ALL.course_cd%TYPE ,
  p_new_notification_dt  IGS_FI_FEE_AS_ALL.notification_dt%TYPE ,
  p_old_notification_dt  IGS_FI_FEE_AS_ALL.notification_dt%TYPE ,
  p_new_logical_delete_dt  IGS_FI_FEE_AS_ALL.logical_delete_dt%TYPE ,
  p_old_logical_delete_dt  IGS_FI_FEE_AS_ALL.logical_delete_dt%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
    gv_other_detail    VARCHAR2(255);
  BEGIN  -- finp_val_fas_upd
    -- This routine validates fields being updated in the IGS_FI_FEE_AS
    -- table may be changed.
  BEGIN
    p_message_name := NULL;
    -- 1. Check for allowable changes

--Change History
--Who          When              What
--masehgal     17-Jan-2002       Obsoletion of SPONSOR_CD related Check from Function FINP_VAL_FAS_UPD

    IF p_new_person_id <> p_old_person_id THEN
      p_message_name := 'IGS_FI_DATA_CANNOT_BE_UPDATED';
      RETURN FALSE;
    END IF;
    IF p_new_transaction_id <> p_old_transaction_id THEN
      p_message_name := 'IGS_FI_DATA_CANNOT_BE_UPDATED';
      RETURN FALSE;
    END IF;
    IF p_new_fee_type <> p_old_fee_type THEN
      p_message_name := 'IGS_FI_DATA_CANNOT_BE_UPDATED';
      RETURN FALSE;
    END IF;
    IF p_new_fee_cal_type <> p_old_fee_cal_type THEN
      p_message_name := 'IGS_FI_DATA_CANNOT_BE_UPDATED';
      RETURN FALSE;
    END IF;
    IF p_new_fee_ci_seq_num <> p_old_fee_ci_seq_num THEN
      p_message_name := 'IGS_FI_DATA_CANNOT_BE_UPDATED';
      RETURN FALSE;
    END IF;
    IF NVL(p_new_fee_cat,'NULL') <> NVL(p_old_fee_cat,'NULL') THEN
      p_message_name := 'IGS_FI_DATA_CANNOT_BE_UPDATED';
      RETURN FALSE;
    END IF;
    IF p_new_transaction_type <> p_old_transaction_type THEN
      p_message_name := 'IGS_FI_DATA_CANNOT_BE_UPDATED';
      RETURN FALSE;
    END IF;
    IF trunc(p_new_transaction_dt) <> trunc(p_old_transaction_dt) THEN
      p_message_name := 'IGS_FI_DATA_CANNOT_BE_UPDATED';
      RETURN FALSE;
    END IF;
    IF p_new_transaction_amount <> p_old_transaction_amount THEN
      p_message_name := 'IGS_FI_DATA_CANNOT_BE_UPDATED';
      RETURN FALSE;
    END IF;
    IF p_new_currency_cd <> p_old_currency_cd THEN
      p_message_name := 'IGS_FI_DATA_CANNOT_BE_UPDATED';
      RETURN FALSE;
    END IF;
    IF NVL(trunc(p_new_effective_dt),igs_ge_date.igsdate('1900/01/01'))
        <> NVL(trunc(p_old_effective_dt),igs_ge_date.igsdate('1900/01/01')) THEN
      p_message_name := 'IGS_FI_DATA_CANNOT_BE_UPDATED';
      RETURN FALSE;
    END IF;
    IF p_new_course_cd <> p_old_course_cd THEN
      p_message_name := 'IGS_FI_DATA_CANNOT_BE_UPDATED';
      RETURN FALSE;
    END IF;
    IF NVL(p_new_logical_delete_dt,igs_ge_date.igsdate('1900/01/01'))
        <> NVL(p_old_logical_delete_dt,igs_ge_date.igsdate('1900/01/01')) AND
        p_old_logical_delete_dt IS NOT NULL THEN
      p_message_name := 'IGS_FI_LOGDEL_DATE_NOT_CLEAR';
      RETURN FALSE;
    END IF;
    -- 2. No error
    RETURN TRUE;
  END;
  END finp_val_fas_upd;
END IGS_FI_VAL_FAS;

/
