--------------------------------------------------------
--  DDL for Package Body IGS_AV_VAL_ASU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_VAL_ASU" AS
/* $Header: IGSAV04B.pls 120.4 2006/03/27 01:33:39 shimitta ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed
  --msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed
  -- To validate the advanced standing basis IGS_OR_INSTITUTION code.
  --
  -- skoppula   15-SEP-2001     Enhancement Bug for Academic Records Maintenance DLD
  -- To change the credit_percentage logic to include advance standing credit points
  --
  -- nalkumar    11-Sep-2001    Added Parameter 'p_adv_stnd_trans' in advp_val_as_dates, advp_val_expiry_dt
  --        advp_val_status_dts functions.
  --                            These changes has been done as per the Career Impact DLD.
  --                            Bug# 2027984.
  --nalkumar    05-June-2002    Replaced the referances of the igs_av_stnd_unit/unit_lvl.(PREV_UNIT_CD and TEST_DETAILS_ID) columns
  --                            to igs_av_stnd_unit/unit_lvl.(unit_details_id and tst_rslt_dtls_id) columns. This is as per Bug# 2401170
  --
  --nalkumar      09-Sept-2002  Removed the references to the 'igs_av_stnd_conf_all.adv_stnd_cutoff_dt_alias' coulmn.
  --                            This column has been obsoleted as part of the Bug# 2446569.
  --                            Modified the 'advp_get_ua_del_alwd' function and removed the validations related to the obsoleted column.
  --kdande        16-Oct-2002   Bug# 2627933. Changed the data type to column%TYPE to avoid value error.
  --                            And added check to see that the total approved exemption is < 999.999.
  --svenkata      27-Nov-02     The routine 'adv_Credit_pts' has been modified to check the value of the fetched parameter l_adv_credits.s_adv_stnd_granting_status
  --                            instead of the IN parameter , which is incorrect.
  -- kdande   08-Oct-03 Bug# 3154803; Changed the select to handle NULL values
  --
  -- nalkumar 10-Dec-2003       Bug# 3270446 RECR50 Build; Obsoleted the IGS_AV_STND_UNIT.CREDIT_PERCENTAGE column.
  -- lkaki    05-Apr-2005       Bug# 4135171 The check for looking whether the computed value of 'v_total_exmptn_perc_grntd' is
  --                            changed to include values beyond 999.
  -- swaghmar 25-Nov-2005	Bug# 4754378 Modified the cursor C_ADV_CP_PER
  -- shimitta 07-Mar-2006       BUg# 5068233
  -------------------------------------------------------------------------------------------
  --
  -- Validate the exemption institution code
  --
  FUNCTION advp_val_asu_inst (
    p_exempt_inst                  IN     VARCHAR2,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN
    DECLARE
      CURSOR c_adv_stnd_exempt_inst_v (
        cp_exempt_inst                        igs_av_adv_standing.exemption_institution_cd%TYPE
      ) IS
	SELECT ihp.oss_org_unit_cd exemption_institution_cd
	  FROM igs_pe_hz_parties ihp
	WHERE ihp.inst_org_ind = 'I'
	AND ihp.oss_org_unit_cd = cp_exempt_inst
	UNION ALL
	SELECT lk.lookup_code exemption_institution_cd
	FROM igs_lookup_values lk
	WHERE lk.lookup_type = 'OR_INSTITUTION_ADVSTEX'
	 AND lk.enabled_flag = 'Y'
	 AND lk.lookup_code = cp_exempt_inst;
    BEGIN
      -- Validate that exemption_institution_cd (IGS_AV_STND_UNIT or IGS_AV_STND_UNIT_LVL
      -- ) is valid.
      -- The status is not considered, as it is allowable to select an inactive
      -- IGS_OR_INSTITUTION for advanced standing basis details.

      p_message_name := NULL;

      -- Validate input parameters.
      IF (p_exempt_inst IS NULL) THEN
        RETURN TRUE;
      END IF;

      --  Validate that exemption IGS_OR_INSTITUTION is valid.
      FOR v_adv_stnd_exempt_inst_rec IN c_adv_stnd_exempt_inst_v (p_exempt_inst) LOOP
        RETURN TRUE;
      END LOOP;

      p_message_name := 'IGS_GE_INVALID_VALUE';
      RETURN FALSE;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token ('NAME', 'IGS_AV_VAL_ASU.ADVP_VAL_ASU_INST');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
    END;
  END advp_val_asu_inst;
  --
  -- To validate the granting of advanced standing (form level only)
  -- shimitta 07-Mar-2006       BUg# 5068233
  FUNCTION advp_val_as_frm_grnt (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_s_adv_stnd_granting_status   IN     VARCHAR2,
    p_message_name                 OUT NOCOPY VARCHAR2
  )
    RETURN BOOLEAN IS
  BEGIN
    DECLARE
      CURSOR c_course_details (
        cp_person_id                          igs_en_stdnt_ps_att.person_id%TYPE,
        cp_course_cd                          igs_en_stdnt_ps_att.course_cd%TYPE
      ) IS
        SELECT sca.version_number,
               sca.course_attempt_status
        FROM   igs_en_stdnt_ps_att sca
        WHERE  sca.person_id = cp_person_id
        AND    sca.course_cd = cp_course_cd;

      v_other_detail          VARCHAR2 (255);
      v_version_number        igs_en_stdnt_ps_att.version_number%TYPE;
      v_course_attempt_status igs_en_stdnt_ps_att.course_attempt_status%TYPE;
    BEGIN
      -- This function validates that an advanced standing
      -- IGS_PS_UNIT can be granted.
      -- IGS_GE_NOTE : this does not include IGS_PE_PERSON encumbrance
      -- checks and IGS_PS_COURSE version advanced standing limit
      -- checks.
      -- This checks the IGS_AV_STND_UNIT.adv_stnd_granting
      -- status maps to APPROVED, the IGS_EN_STDNT_PS_ATT
      -- exists and has an attempt status of enrolled, inactive or
      -- intermit and the IGS_EN_STDNT_PS_ATT version matches
      -- the advanced standing approved.
      -- set the default message number
      p_message_name := NULL;

      -- validate the input parameters
      IF (p_person_id IS NULL
          OR p_course_cd IS NULL
          OR p_version_number IS NULL
          OR p_s_adv_stnd_granting_status IS NULL
         ) THEN
        p_message_name := 'IGS_AV_INSUFFICIENT_INFO';
        RETURN FALSE;
      END IF;

      -- validate that the current advanced standing
      -- status is approved
      IF (p_s_adv_stnd_granting_status <> 'APPROVED') THEN
        p_message_name := 'IGS_AV_GRANTED_CURSTATUS_APPR';
        RETURN FALSE;
      END IF;

      -- validate that a IGS_EN_STDNT_PS_ATT exists,
      -- whether it is the correct version and has a
      -- IGS_PS_COURSE attempt status of 'ENROLLED','INACTIVE' or
      -- 'INTERMIT'
      OPEN c_course_details (p_person_id, p_course_cd);
      FETCH c_course_details INTO v_version_number,
                                  v_course_attempt_status;

      -- check if a record was found or not
      IF (c_course_details%NOTFOUND) THEN
        CLOSE c_course_details;
        p_message_name := 'IGS_AV_GRANTED_STUDPRG_EXISTS';
        RETURN FALSE;
      ELSE
        CLOSE c_course_details;

        -- check if the versions are the same,
        -- which they must be
        IF (v_version_number <> p_version_number) THEN
          p_message_name := 'IGS_AV_GRANTED_STUD_PRGVER';
          RETURN FALSE;
        END IF;

        -- check the IGS_PS_COURSE attempt status,
        -- which must be enrolled
        IF (v_course_attempt_status IN('UNCONFIRM', 'LAPSED', 'DELETED')) THEN
          p_message_name := 'IGS_AV_GRANTED_STUD_ENR';
          RETURN FALSE;
        ELSIF (v_course_attempt_status = 'INTERMIT') THEN
          p_message_name := 'IGS_AV_NOTGRANT_ON_INTERMISSI';
          RETURN FALSE;
        END IF;
      END IF;

      -- set the default return type
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token ('NAME', 'IGS_AV_VAL_ASU.ADVP_VAL_AS_FRM_GRNT');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
    END;
  END advp_val_as_frm_grnt;
  --
  -- To validate the various dates of advanced standing units or levels.
  --
  FUNCTION advp_val_as_dates (
    p_advanced_standing_dt         IN     DATE,
    p_date_type                    IN     VARCHAR2,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_adv_stnd_trans               IN     VARCHAR2
  ) -- This parameter has been added for Career Impact DLD.
    RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN
    -- advp_val_as_dates
      -- Validate that IGS_AV_ADV_STANDING related dates are not
      -- greater than the current date.
    DECLARE
      v_ret_val BOOLEAN := TRUE;
    BEGIN
      p_message_name := NULL;

      IF (p_advanced_standing_dt IS NULL
          OR p_date_type IS NULL
         ) THEN
        RETURN TRUE;
      END IF;

      IF  (p_advanced_standing_dt > SYSDATE)
          AND p_adv_stnd_trans = 'N' THEN
        IF (p_date_type = 'APPROVED') THEN
          p_message_name := 'IGS_AV_APRVDT_LE_CURDT';
          v_ret_val := FALSE;
        ELSIF (p_date_type = 'GRANTED') THEN
          p_message_name := 'IGS_AV_GRANTDT_LE_CURDT';
          v_ret_val := FALSE;
        ELSIF (p_date_type = 'CANCELLED') THEN
          p_message_name := 'IGS_AV_CANCELDT_LE_CURDT';
          v_ret_val := FALSE;
        ELSIF (p_date_type = 'REVOKED') THEN
          p_message_name := 'IGS_AV_REVOKED_LE_CURDT';
          v_ret_val := FALSE;
        ELSE
          -- by default return TRUE
          NULL;
        END IF;
      END IF;

      RETURN v_ret_val;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AV_VAL_ASU.ADVP_VAL_AS_DATES');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END advp_val_as_dates;
  --
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  --
  -- To validate the status dates of advanced standing units or levels.
  --
  FUNCTION advp_val_status_dts (
    p_granting_status              IN     VARCHAR2,
    p_related_dt                   IN     DATE,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_adv_stnd_trans               IN     VARCHAR2
  ) -- This parameter has been added for Career Impact DLD.
    RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- advp_val_status_dts
    -- Validate that if s_adv_stnd_granting_status is specified,
    -- then its correspondeing date is also specified.
    DECLARE
      v_ret_val BOOLEAN := TRUE;
    BEGIN
      p_message_name := NULL;

      IF (p_granting_status IS NULL) THEN
        RETURN TRUE;
      END IF;

      -- validate that related_dt is not null
      IF  (p_related_dt IS NULL)
          AND p_adv_stnd_trans = 'N' THEN
        p_message_name := 'IGS_AV_ASSODT_SET_GRANT_ST';
        v_ret_val := FALSE;
      END IF;

      RETURN v_ret_val;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AV_VAL_ASU.ADVP_VAL_STATUS_DTS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END advp_val_status_dts;
  --
  -- Validate the AS recognition type closed indicator.
  --
  FUNCTION advp_val_asrt_closed (
    p_recognition_type             IN     VARCHAR2,
    p_message_name                 OUT NOCOPY VARCHAR2
  )
    RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- check if the s_adv_stnd_recognition_type is closed
    DECLARE
      v_closed_ind CHAR;

      CURSOR c_get_closed_ind (
        cp_recognition_type                   igs_lookups_view.lookup_code%TYPE
      ) IS
        SELECT closed_ind
        FROM   igs_lookups_view
        WHERE  lookup_type = 'ADV_STND_RECOGNITION_TYPE'
        AND    lookup_code = p_recognition_type;
    BEGIN
      p_message_name := NULL;

      -- Validate input parameters
      IF (p_recognition_type IS NULL) THEN
        RETURN TRUE;
      END IF;

      -- Validate if the advanced standing recognition type is closed
      OPEN c_get_closed_ind (p_recognition_type);
      FETCH c_get_closed_ind INTO v_closed_ind;

      IF (c_get_closed_ind%NOTFOUND) THEN
        CLOSE c_get_closed_ind;
        RETURN TRUE;
      END IF;

      CLOSE c_get_closed_ind;

      IF (v_closed_ind = 'Y') THEN
        p_message_name := 'IGS_AV_RECOGNITION_TYPE_CLOSE';
        RETURN FALSE;
      END IF;

      RETURN TRUE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AV_VAL_ASU.ADVP_VAL_ASRT_CLOSED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END advp_val_asrt_closed;
  --
  -- To validate the approved date of advanced standing units or levels.
  --
  FUNCTION advp_val_as_aprvd_dt (
    p_approved_dt                  IN     DATE,
    p_related_dt                   IN     DATE,
    p_message_name                 OUT NOCOPY VARCHAR2
  )
    RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- advp_val_as_aprvd_dt
    -- Validate that approved_dt(adv-stnd_unit OR IGS_AV_STND_UNIT_LVL) is not
    -- less than the granted_dt, cancelled_dt OR revoked_dt for the same record
    DECLARE
      v_ret_val BOOLEAN := TRUE;
    BEGIN
      p_message_name := NULL;

      -- validate input parameter
      IF (p_approved_dt IS NULL
          OR p_related_dt IS NULL
         ) THEN
        RETURN TRUE;
      END IF;

      -- Validate that related_dt is greater than or equal to the approved_dt
      IF (p_related_dt < p_approved_dt) THEN
        p_message_name := 'IGS_AV_DTASSO_LE_APPRVDT';
        v_ret_val := FALSE;
      END IF;

      RETURN v_ret_val;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AV_VAL_ASU.ADVP_VAL_AS_APRVD_DT');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END advp_val_as_aprvd_dt;
  --
  -- To validate the approved date of advanced standing units or levels.
  --
  FUNCTION advp_val_approved_dt (
    p_approved_dt                  IN     DATE,
    p_expiry_dt                    IN     DATE,
    p_message_name                 OUT NOCOPY VARCHAR2
  )
    RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- Validate that IGS_AV_STND_UNIT.approved_dt is less
    -- than or equal to IGS_AV_STND_UNIT.expiry_dt
    DECLARE
    BEGIN
      p_message_name := NULL;

      -- Validate input parameters
      IF (p_approved_dt IS NULL
          OR p_expiry_dt IS NULL
         ) THEN
        RETURN TRUE;
      END IF;

      -- Validate that approved_dt is less than or equal to expiry_dt
      IF (TRUNC (p_approved_dt) > TRUNC (p_expiry_dt)) THEN
        p_message_name := 'IGS_AV_APRVDT_NOT_GT_EXPDT';
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AV_VAL_ASU.ADVP_VAL_APPROVED_DT');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END advp_val_approved_dt;
  --
  -- To validate the expiry date of advanced standing units or levels.
  --
  FUNCTION advp_val_expiry_dt (
    p_expiry_dt                    IN     DATE,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_adv_stnd_trans               IN     VARCHAR2
  ) -- This parameter has been added for Career Impact DLD.
    RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- Validate that IGS_AV_STND_UNIT.expiry_dt
    -- is greater than the current date
    DECLARE
    BEGIN
      p_message_name := NULL;

      -- Validate input parameters
      IF (p_expiry_dt IS NULL) THEN
        RETURN TRUE;
      END IF;

      -- Validate that expiry_dt is greater than the current date
      IF  (TRUNC (p_expiry_dt) <= TRUNC (SYSDATE))
          AND p_adv_stnd_trans = 'N' THEN
        p_message_name := 'IGS_AV_EXPDT_GT_CURDT';
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AV_VAL_ASU.ADVP_VAL_EXPIRY_DT');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END advp_val_expiry_dt;
  --
  -- To validate the credit percentage of advanced standing units.
  --
  FUNCTION advp_val_credit_perc (
    p_percentage                   IN     NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  )
    RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- advp_val_credit_perc
    -- Validate that the credit spcified for an advanced standing
    -- IGS_PS_UNIT is either: a multiple of 5, equal to 33 or equal to 66
    DECLARE
      v_ret_val BOOLEAN := TRUE;
    BEGIN
      p_message_name := NULL;

      IF (p_percentage = 33
          OR p_percentage = 66
          OR p_percentage MOD 5 = 0
         ) THEN
        p_message_name := NULL;
        v_ret_val := TRUE;
      ELSE
        p_message_name := 'IGS_AV_CREDITPRC_33_66_MULT5';
        v_ret_val := FALSE;
      END IF;

      RETURN v_ret_val;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AV_VAL_ASU.ADVP_VAL_CREDIT_PERC');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END advp_val_credit_perc;
  --
  -- To validate internal/external advanced standing IGS_PS_COURSE limits.
  --


 FUNCTION advp_val_as_totals (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_include_approved             IN     BOOLEAN,
    p_asu_unit_cd                  IN     VARCHAR2,
    p_asu_version_number           IN     NUMBER,
    p_asu_advstnd_granting_status  IN     VARCHAR2,
    p_asul_unit_level              IN     VARCHAR2,
    p_asul_exmptn_institution_cd   IN     VARCHAR2,
    p_asul_advstnd_granting_status IN     VARCHAR2,
    p_total_exmptn_approved        OUT NOCOPY NUMBER,
    p_total_exmptn_granted         OUT NOCOPY NUMBER,
    p_total_exmptn_perc_grntd      OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_unit_details_id              IN     NUMBER,
    p_tst_rslt_dtls_id             IN     NUMBER,
    p_asu_exmptn_institution_cd    IN     VARCHAR2
  )
    RETURN BOOLEAN IS
  BEGIN
    DECLARE
      cst_approved      CONSTANT VARCHAR2 (10) := 'APPROVED';
      cst_granted       CONSTANT VARCHAR2 (10) := 'GRANTED';
      cst_cancelled     CONSTANT VARCHAR2 (10) := 'CANCELLED';
      cst_revoked       CONSTANT VARCHAR2 (10) := 'REVOKED';
      cst_expired       CONSTANT VARCHAR2 (10) := 'EXPIRED';
      cst_credit        CONSTANT VARCHAR2 (10) := 'CREDIT';
      cst_not_instn     CONSTANT VARCHAR2 (10) := 'NOT INSTN';
      cst_unknown       CONSTANT VARCHAR2 (10) := 'UNKNOWN';
      --
      -- Cursor to get the Advanced Standing Limits from the Course Version setup
      -- kdande; 07-Oct-2003; Bug# 3154803; Changed the select to handle NULL values
      --
      CURSOR c_course_version_details (
        cp_course_cd                          igs_ps_ver.course_cd%TYPE,
        cp_version_number                     igs_ps_ver.version_number%TYPE
      ) IS
        SELECT NVL (cv.external_adv_stnd_limit, 0) external_adv_stnd_limit,
               NVL (cv.internal_adv_stnd_limit, 0) internal_adv_stnd_limit,
               NVL (cv.credit_points_required, 0) credit_points_required
        FROM   igs_ps_ver cv
        WHERE  cv.course_cd = cp_course_cd
        AND    cv.version_number = cp_version_number;

      CURSOR c_local_inst_ind (cp_ins_cd igs_or_institution.institution_cd%TYPE) IS
        SELECT ins.local_institution_ind
        FROM   igs_or_institution ins
        WHERE  ins.institution_cd = cp_ins_cd;

      CURSOR c_adv_stnd_unit_details (
        cp_person_id                          igs_av_stnd_unit.person_id%TYPE,
        cp_course_cd                          igs_av_stnd_unit.as_course_cd%TYPE,
        cp_version_number                     igs_av_stnd_unit.as_version_number%TYPE
	) IS
        SELECT /* asu.credit_percentage, */
               asu.exemption_institution_cd,
               asu.s_adv_stnd_granting_status,
               asu.unit_cd,
               asu.version_number,
               -- asu.prev_unit_cd,
               asu.unit_details_id,
               -- asu.test_segment_id
               asu.tst_rslt_dtls_id
        FROM   igs_av_stnd_unit asu
        WHERE  asu.person_id = cp_person_id
        AND    asu.as_course_cd = cp_course_cd
        AND    asu.as_version_number = cp_version_number
    	AND    asu.s_adv_stnd_granting_status IN (cst_approved, cst_granted)
        AND    asu.s_adv_stnd_recognition_type = cst_credit;


     CURSOR c_adv_stnd_unit_level (
        cp_person_id                          igs_av_stnd_unit_lvl.person_id%TYPE,
        cp_course_cd                          igs_av_stnd_unit_lvl.as_course_cd%TYPE,
        cp_version_num                        igs_av_stnd_unit_lvl.as_version_number%TYPE
	) IS
        SELECT NVL (asul.credit_points, 0) credit_points,
               asul.exemption_institution_cd,
               asul.unit_level,
               asul.s_adv_stnd_granting_status
        FROM   igs_av_stnd_unit_lvl asul
        WHERE  asul.person_id = cp_person_id
        AND    asul.as_course_cd = cp_course_cd
        AND    asul.as_version_number = cp_version_num
	AND    asul.s_adv_stnd_granting_status IN (cst_approved, cst_granted);

      v_other_detail             VARCHAR2 (255);
      v_adv_stnd_granting_status igs_av_stnd_unit.s_adv_stnd_granting_status%TYPE;
      v_ext_adv_stnd_limit       igs_ps_ver.external_adv_stnd_limit%TYPE;
      v_int_adv_stnd_limit       igs_ps_ver.internal_adv_stnd_limit%TYPE;
      v_credit_points_reqd       igs_ps_ver.credit_points_required%TYPE;
      v_local_inst_ind           igs_or_institution.institution_cd%TYPE;
      v_external_adv_stnd_total  NUMBER;
      v_internal_adv_stnd_total  NUMBER;
      -- 16-Oct-2002; kdande; Bug# 2627933
      -- Changed the data type to column%TYPE to avoid value error.
      v_total_exmptn_approved    igs_av_adv_standing_all.total_exmptn_approved%TYPE;
      v_total_exmptn_granted     igs_av_adv_standing_all.total_exmptn_granted%TYPE;
      v_total_exmptn_perc_grntd  igs_av_adv_standing_all.total_exmptn_perc_grntd%TYPE;
      v_add_in_totals            BOOLEAN;
      v_adv_stnd                 c_adv_stnd_unit_details%ROWTYPE;
      v_credits                  NUMBER;
      v_inst_credits             NUMBER;
    BEGIN
      -- This function validates that the advanced standing
      -- approved/granted has not exceeded the advanced
      -- standing limits of the IGS_PS_COURSE version.  It returns
      -- advanced standing exemption totals.
      -- initialise counts
      v_external_adv_stnd_total := 0;
      v_internal_adv_stnd_total := 0;
      v_total_exmptn_approved := 0;
      v_total_exmptn_granted := 0;
      v_total_exmptn_perc_grntd := 0;

      -- validate the input parameters
      IF (p_person_id IS NULL
          OR p_course_cd IS NULL
          OR p_version_number IS NULL
         ) THEN
        p_total_exmptn_approved := v_total_exmptn_approved;
        p_total_exmptn_granted := v_total_exmptn_granted;
        p_total_exmptn_perc_grntd := v_total_exmptn_perc_grntd;
        p_message_name := 'IGS_AV_INSUFFICIENT_INFO_VER';
        RETURN FALSE;
      END IF;

      IF (p_asu_unit_cd IS NOT NULL) THEN
        IF (p_asu_version_number IS NULL
            OR p_asu_advstnd_granting_status IS NULL
           ) THEN
          p_total_exmptn_approved := v_total_exmptn_approved;
          p_total_exmptn_granted := v_total_exmptn_granted;
          p_total_exmptn_perc_grntd := v_total_exmptn_perc_grntd;
          p_message_name := 'IGS_AV_INSUFFICIENT_INFO_VER';
          RETURN FALSE;
        END IF;
      END IF;

      -- added as part of academic records maintenance DLD ;
      -- If unit is not null abd both unit_details_id and tst_rslt_dtls_id are null then returns false
      IF  p_asu_unit_cd IS NOT NULL
          AND (p_unit_details_id IS NULL
               AND p_tst_rslt_dtls_id IS NULL
              ) THEN
        p_total_exmptn_approved := v_total_exmptn_approved;
        p_total_exmptn_granted := v_total_exmptn_granted;
        p_total_exmptn_perc_grntd := v_total_exmptn_perc_grntd;
        p_message_name := 'IGS_AV_INSUFFICIENT_INFO_VER';
        RETURN FALSE;
      END IF;

      -- added as part of academic records maintenance DLD ;
      -- If both unit_details_id and tst_rslt_dtls_id are not null then returns false
      IF  p_unit_details_id IS NOT NULL
          AND p_tst_rslt_dtls_id IS NOT NULL THEN
        p_total_exmptn_approved := v_total_exmptn_approved;
        p_total_exmptn_granted := v_total_exmptn_granted;
        p_total_exmptn_perc_grntd := v_total_exmptn_perc_grntd;
        p_message_name := 'IGS_AV_INSUFFICIENT_INFO_VER';
        RETURN FALSE;
      END IF;

      IF (p_asul_unit_level IS NOT NULL) THEN
        IF (p_asul_exmptn_institution_cd IS NULL
            OR p_asul_advstnd_granting_status IS NULL
           ) THEN
          p_total_exmptn_approved := v_total_exmptn_approved;
          p_total_exmptn_granted := v_total_exmptn_granted;
          p_total_exmptn_perc_grntd := v_total_exmptn_perc_grntd;
          p_message_name := 'IGS_AV_INSUFFICIENT_INFO_VER';
          RETURN FALSE;
        END IF;
      END IF;

      -- get the IGS_PS_VER advanced
      -- standing limits
      OPEN c_course_version_details (p_course_cd, p_version_number);
      FETCH c_course_version_details INTO v_ext_adv_stnd_limit,
                                          v_int_adv_stnd_limit,
                                          v_credit_points_reqd;

      IF (c_course_version_details%NOTFOUND) THEN
        -- invalid parameters entered
        CLOSE c_course_version_details;
        p_total_exmptn_approved := v_total_exmptn_approved;
        p_total_exmptn_granted := v_total_exmptn_granted;
        p_total_exmptn_perc_grntd := v_total_exmptn_perc_grntd;
        p_message_name := 'IGS_AV_INSUFFICIENT_INFO_VER';
        RETURN FALSE;
      END IF;

      CLOSE c_course_version_details;

      FOR v_adv_stnd IN c_adv_stnd_unit_details (
                          p_person_id,
                          p_course_cd,
                          p_version_number
			  ) LOOP
        v_add_in_totals := TRUE;
        v_adv_stnd_granting_status := v_adv_stnd.s_adv_stnd_granting_status;

        IF (p_asu_unit_cd IS NOT NULL) THEN
          -- check the status of p_asu_unit_cd
          IF (p_asu_unit_cd = v_adv_stnd.unit_cd
              AND p_asu_version_number = v_adv_stnd.version_number
             ) THEN
            IF (p_asu_advstnd_granting_status IN
                                       (cst_cancelled, cst_revoked, cst_expired)
               ) THEN
              -- do not include in counts
              -- continue processing
              v_add_in_totals := FALSE;
            ELSE
              v_adv_stnd_granting_status := p_asu_advstnd_granting_status;
            END IF;
          END IF;
        END IF;

        advp_get_adv_credit_pts (
          p_person_id,
          p_course_cd,
          p_version_number,
          v_adv_stnd_granting_status,
          v_adv_stnd.unit_cd,
          v_adv_stnd.version_number,
  --                                        v_adv_stnd.prev_unit_cd,
  --                                        v_adv_stnd.test_segment_id,
          v_adv_stnd.unit_details_id,
          v_adv_stnd.tst_rslt_dtls_id,
          v_credits,
	  v_inst_credits,
	  p_asu_exmptn_institution_cd
        );
        v_credits := NVL (v_credits, 0);
        v_inst_credits := NVL(v_inst_credits,0);
        -- To handle null values

        IF (v_add_in_totals = TRUE) THEN
          -- add to exemption totals
          -- only include total exempt IGS_PS_UNITs
          IF (v_adv_stnd_granting_status = cst_approved) THEN
            -- add achieveable_credit_points to v_total_exmptn_approved

            v_total_exmptn_approved := v_total_exmptn_approved + v_inst_credits;
          ELSE
            -- add achieveable_credit_points to v_total_exmptn_granted
            v_total_exmptn_granted := v_total_exmptn_granted + v_inst_credits;
          END IF;
            -- add to totals for validation
          IF  NOT p_include_approved
              AND (v_adv_stnd_granting_status = cst_approved) THEN
            -- don't include in totals
            NULL;
          ELSE
            IF (v_adv_stnd.exemption_institution_cd IN
                                                    (cst_not_instn, cst_unknown)
               ) THEN
              -- add to external totals
              v_external_adv_stnd_total := v_external_adv_stnd_total + v_credits;
            ELSE
              -- selecting the IGS_OR_INSTITUTION.local_institution_cd
              OPEN c_local_inst_ind (v_adv_stnd.exemption_institution_cd);
              FETCH c_local_inst_ind INTO v_local_inst_ind;

              -- not in IGS_OR_INSTITUTION table, so add to external totals
              IF (c_local_inst_ind%NOTFOUND) THEN
                v_external_adv_stnd_total :=
                                            v_external_adv_stnd_total + v_credits;
                CLOSE c_local_inst_ind;
              ELSE
                CLOSE c_local_inst_ind;

                IF (v_local_inst_ind = 'Y') THEN
                  -- add to internal totals
                  v_internal_adv_stnd_total :=
                                            v_internal_adv_stnd_total + v_credits;
                ELSE
                  -- add to external totals
                  v_external_adv_stnd_total :=
                                            v_external_adv_stnd_total + v_credits;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
         END LOOP;


        --CLOSE v_av_cp_cur;
        -- select IGS_AV_STND_UNIT_LVL for parameters
        -- to add to existing totals

      FOR v_unit_level IN c_adv_stnd_unit_level (
                            p_person_id,
                            p_course_cd,
                            p_version_number
			              ) LOOP
        v_add_in_totals := TRUE;
        v_adv_stnd_granting_status := v_unit_level.s_adv_stnd_granting_status;

        IF (p_asul_unit_level IS NOT NULL) THEN
          -- check the status of p_asul_unit_cd
          IF (p_asul_unit_level = v_unit_level.unit_level
              AND p_asul_exmptn_institution_cd =
                                            v_unit_level.exemption_institution_cd
             ) THEN
            IF (p_asul_advstnd_granting_status IN
                                       (cst_cancelled, cst_revoked, cst_expired)
               ) THEN
              -- do not include in counts
              -- continue processing
              v_add_in_totals := FALSE;
            ELSE
              v_adv_stnd_granting_status := p_asul_advstnd_granting_status;
            END IF;
          END IF;
        END IF;

        IF (v_add_in_totals = TRUE) THEN
          -- add to exemption totals
          IF (v_adv_stnd_granting_status = cst_approved) THEN
                              -- 16-Oct-2002; kdande; Bug# 2627933
                              -- Added check to see that the total approved exemption is < 999.999
            -- Start of fix for Bug# 2627933
            IF ((v_total_exmptn_approved + v_unit_level.credit_points) > 999.999) THEN
              fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
              igs_ge_msg_stack.ADD;
              app_exception.raise_exception;
            ELSIF (p_asul_exmptn_institution_cd IS NOT NULL) AND
         (v_unit_level.exemption_institution_cd = p_asul_exmptn_institution_cd) THEN
              v_total_exmptn_approved :=
                             v_total_exmptn_approved + v_unit_level.credit_points;
            END IF;

          -- End of fix for Bug# 2627933
          ELSE
          IF(p_asul_exmptn_institution_cd IS NOT NULL) AND
         (v_unit_level.exemption_institution_cd = p_asul_exmptn_institution_cd) THEN
            v_total_exmptn_granted :=
                              v_total_exmptn_granted + v_unit_level.credit_points;
          END IF;
          END IF;

         -- add to totals for validation
          IF  NOT p_include_approved
              AND (v_adv_stnd_granting_status = cst_approved) THEN
            -- don't include the totals
            NULL;
          ELSE
            IF (v_unit_level.exemption_institution_cd IN
                                                    (cst_not_instn, cst_unknown)
               ) THEN
              -- add to the external totals
              v_external_adv_stnd_total :=
                           v_external_adv_stnd_total + v_unit_level.credit_points;
            ELSE
              -- selecting the IGS_OR_INSTITUTION.local_institution_cd
              OPEN c_local_inst_ind (v_unit_level.exemption_institution_cd);
              FETCH c_local_inst_ind INTO v_local_inst_ind;

              -- not in IGS_OR_INSTITUTION table, so add to external totals
              IF (c_local_inst_ind%NOTFOUND) THEN
                v_external_adv_stnd_total :=
                           v_external_adv_stnd_total + v_unit_level.credit_points;
                CLOSE c_local_inst_ind;
              ELSE
                CLOSE c_local_inst_ind;

                IF (v_local_inst_ind = 'Y') THEN
                  -- add to internal totals
                  v_internal_adv_stnd_total :=
                           v_internal_adv_stnd_total + v_unit_level.credit_points;
                ELSE
                  -- add to external totals
                  v_external_adv_stnd_total :=
                           v_external_adv_stnd_total + v_unit_level.credit_points;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
      END LOOP;

      -- after processing all records
      -- set v_total_exmptn_perc_grnted to 0
      -- if v_total_exmptn_granted or
      -- v_credit_points_reqd is = 0, as
      -- a division would produce an error
      -- if trying to divide by 0
      IF (v_total_exmptn_granted = 0
          OR v_credit_points_reqd = 0
         ) THEN
        v_total_exmptn_perc_grntd := 0;
      ELSE
        -- determine IGS_PS_COURSE percentage covered by
        -- advanced standing granted
        -- can perform the division, as values are not 0
       IF (((v_total_exmptn_granted/v_credit_points_reqd)*100) > 100) THEN
            v_total_exmptn_perc_grntd := 100;
       ELSE
            v_total_exmptn_perc_grntd:=((v_total_exmptn_granted/v_credit_points_reqd)*100) ;
       END IF;
      END IF;

      -- Check if granted total exceeds credit points
      -- required for the IGS_PS_COURSE version.
      -- Also check if the granted plus approved total exceeds the
      -- credit points required for the IGS_PS_COURSE version.
      IF NOT p_include_approved THEN
        IF (v_total_exmptn_granted > v_credit_points_reqd) THEN
          IF (p_asul_advstnd_granting_status = cst_granted
              OR p_asu_advstnd_granting_status = cst_granted
             ) THEN
            p_total_exmptn_approved := v_total_exmptn_approved;
            p_total_exmptn_granted := v_total_exmptn_granted;
            p_total_exmptn_perc_grntd := v_total_exmptn_perc_grntd;
            p_message_name := 'IGS_AV_MINIMUM_CREDIT_POINTS';
          --  RETURN FALSE;
          END IF;
        END IF;
      ELSE
        IF ((v_total_exmptn_approved + v_total_exmptn_granted) >
                                                             v_credit_points_reqd
           ) THEN
          IF (p_asul_advstnd_granting_status = cst_approved
              OR p_asu_advstnd_granting_status = cst_approved
             ) THEN
            p_total_exmptn_approved := v_total_exmptn_approved;
            p_total_exmptn_granted := v_total_exmptn_granted;
            p_total_exmptn_perc_grntd := v_total_exmptn_perc_grntd;
            p_message_name := 'IGS_AV_MINIMUM_CREDIT_POINTS';
          --  RETURN FALSE;
          END IF;
        END IF;
      END IF;

      -- check if totals exceed limits
      -- external totals
      IF (v_external_adv_stnd_total > v_ext_adv_stnd_limit) THEN
        -- external limit exceeded
        p_total_exmptn_approved := v_total_exmptn_approved;
        p_total_exmptn_granted := v_total_exmptn_granted;
        p_total_exmptn_perc_grntd := v_total_exmptn_perc_grntd;
        p_message_name := 'IGS_AV_EXCEEDS_PRGVER_EXT_LMT';
        RETURN FALSE;
      END IF;

      -- internal totals
      IF (v_internal_adv_stnd_total > v_int_adv_stnd_limit) THEN
        -- internal limit exceeded
        p_total_exmptn_approved := v_total_exmptn_approved;
        p_total_exmptn_granted := v_total_exmptn_granted;
        p_total_exmptn_perc_grntd := v_total_exmptn_perc_grntd;
        p_message_name := 'IGS_AV_EXCEEDS_PRGVER_INT_LMT';
        RETURN FALSE;
      END IF;

      -- return totals
      p_total_exmptn_approved := v_total_exmptn_approved;
      p_total_exmptn_granted := v_total_exmptn_granted;
      p_total_exmptn_perc_grntd := v_total_exmptn_perc_grntd;
        --  p_message_name := null;
        -- fnd_file.put_line(fnd_file.log,'returning true');
      --dbms_output.put_line('exemption approved '||to_char(v_total_exmptn_approved));
      --dbms_output.put_line('exemption granted '||to_char(v_total_exmptn_granted));
      --dbms_output.put_line('exemption perc granted '||to_char(v_total_exmptn_perc_grntd));
      RETURN TRUE;
      fnd_file.put_line (fnd_file.LOG, 'returned');
    EXCEPTION
      WHEN OTHERS THEN
            /*Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
                Fnd_Message.Set_Token('NAME','IGS_AV_VAL_ASU.ADVP_VAL_AS_TOTALS');
                Igs_Ge_Msg_Stack.Add;*/
        --dbms_output.put_line('igsavo4b '||sqlerrm);
        app_exception.raise_exception;
    END;
  END advp_val_as_totals;
   --
  -- To get whether delete of student IGS_PS_UNIT attempt is allowed.
  --
  FUNCTION advp_get_ua_del_alwd (
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_effective_dt                 IN     DATE
  )
    RETURN BOOLEAN IS
  BEGIN
    DECLARE
      CURSOR c_daiv (
        cp_cal_type                           igs_ca_inst.cal_type%TYPE,
        cp_ci_seq_num                         igs_ca_inst.sequence_number%TYPE
      ) IS
        SELECT daiv.alias_val
        FROM   igs_ca_da_inst_v daiv,
               igs_ge_s_gen_cal_con sgcc
        WHERE  daiv.cal_type = cp_cal_type
        AND    daiv.ci_sequence_number = cp_ci_seq_num
        AND    daiv.dt_alias = sgcc.census_dt_alias
        AND    sgcc.s_control_num = 1;
    BEGIN
      -- This module checks whether it is possible, as
      -- at the effective date, to delete student IGS_PS_UNIT
      -- attempts in the nominated teaching period
      -- calendar instance, as a result of advanced
      -- standing granting
      -- if p_effective_dt is greater than the census
      -- date, then do not allow deletion
      FOR v_daiv IN c_daiv (p_cal_type, p_ci_sequence_number) LOOP
        IF (p_effective_dt > v_daiv.alias_val) THEN
          RETURN FALSE;
        END IF;
      END LOOP;

      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token ('NAME', 'IGS_AV_VAL_ASU.ADVP_GET_UA_DEL_ALWD');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
    END;
  END advp_get_ua_del_alwd;
  --
  -- To validate the granting of advanced standing.
  -- shimitta 07-Mar-2006       BUg# 5068233
  FUNCTION advp_val_as_grant (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_s_adv_stnd_granting_status   IN     VARCHAR2,
    p_message_name                 OUT NOCOPY VARCHAR2
  )
    RETURN BOOLEAN IS
  BEGIN
    DECLARE
      CURSOR c_course_details (
        cp_person_id                          igs_en_stdnt_ps_att.person_id%TYPE,
        cp_course_cd                          igs_en_stdnt_ps_att.course_cd%TYPE
      ) IS
        SELECT sca.version_number,
               sca.course_attempt_status
        FROM   igs_en_stdnt_ps_att sca
        WHERE  sca.person_id = cp_person_id
        AND    sca.course_cd = cp_course_cd;

      v_other_detail          VARCHAR2 (255);
      v_version_number        igs_en_stdnt_ps_att.version_number%TYPE;
      v_course_attempt_status igs_en_stdnt_ps_att.course_attempt_status%TYPE;
    BEGIN
      -- This function validates that an advanced standing
      -- IGS_PS_UNIT can be granted.
      -- IGS_GE_NOTE : this does not include IGS_PE_PERSON encumbrance
      -- checks and IGS_PS_COURSE version advanced standing limit
      -- checks.
      -- This checks the IGS_AV_STND_UNIT.adv_stnd_granting
      -- status maps to APPROVED, the IGS_EN_STDNT_PS_ATT
      -- exists and has an attempt status of enrolled and
      -- the IGS_EN_STDNT_PS_ATT version matches the
      -- advanced standing approved.
      -- set the default message number
      p_message_name := NULL;

      -- validate the input parameters
      IF (p_person_id IS NULL
          OR p_course_cd IS NULL
          OR p_version_number IS NULL
          OR p_s_adv_stnd_granting_status IS NULL
         ) THEN
        p_message_name := 'IGS_AV_INSUFFICIENT_INFO';
        RETURN FALSE;
      END IF;

      -- validate that the current advanced standing
      -- status is approved
      IF (p_s_adv_stnd_granting_status <> 'APPROVED') THEN
        p_message_name := 'IGS_AV_GRANTED_CURSTATUS_APPR';
        RETURN FALSE;
      END IF;

      -- validate that a IGS_EN_STDNT_PS_ATT exists,
      -- whether it is the correct version and has a
      -- IGS_PS_COURSE attempt status of 'ENROLLED'
      OPEN c_course_details (p_person_id, p_course_cd);
      FETCH c_course_details INTO v_version_number,
                                  v_course_attempt_status;

      -- check if a record was found or not
      IF (c_course_details%NOTFOUND) THEN
        CLOSE c_course_details;
        p_message_name := 'IGS_AV_GRANTED_STUDPRG_EXISTS';
        RETURN FALSE;
      ELSE
        CLOSE c_course_details;

        -- check if the versions are the same,
        -- which they must be
        IF (v_version_number <> p_version_number) THEN
          p_message_name := 'IGS_AV_GRANTED_STUD_PRGVER';
          RETURN FALSE;
        END IF;

        -- check the IGS_PS_COURSE attempt status,
        -- which must be enrolled
        IF (v_course_attempt_status IN('UNCONFIRM', 'LAPSED', 'DELETED')) THEN
          p_message_name := 'IGS_AV_GRANTED_STUD_ENR';
          RETURN FALSE;
        ELSIF (v_course_attempt_status = 'INTERMIT') THEN
          p_message_name := 'IGS_AV_NOTGRANT_ON_INTERMISSI';
          RETURN FALSE;
        END IF;
      END IF;

      -- set the default return type
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token ('NAME', 'IGS_AV_VAL_ASU.ADVP_VAL_AS_GRANT');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
    END;
  END advp_val_as_grant;
  --
  -- This procdure passes back advance standing credit points
  -- Intorduced as part of Academic Records Maintenance DLD
  -- MODIFIED BY	DATE		DESCRIPTION
  -- swaghmar		09-Dec-2005	Bug# 4869528

  PROCEDURE advp_get_adv_credit_pts (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_s_adv_stnd_granting_status   IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_unit_version                 IN     NUMBER,
  --  p_previous_unit IN VARCHAR2,
  --  p_test_segment IN VARCHAR2,
    p_unit_details_id              IN     NUMBER,
    p_tst_rslt_dtls_id             IN     NUMBER,
    p_credit_points                OUT NOCOPY NUMBER,
    p_inst_credit_points           OUT NOCOPY NUMBER,
    p_exemption_institution_cd     IN     VARCHAR2
  ) AS
    CURSOR c_adv_pre_unit IS
      SELECT asu.achievable_credit_points advance_standing_cp,
             asu.exemption_institution_cd,
             /* asu.credit_percentage, */
             NVL (puv.achievable_credit_points, puv.enrolled_credit_points) enrolled_cp
      FROM   igs_av_stnd_unit asu,
             igs_ps_unit_ver puv
      WHERE  asu.person_id = p_person_id
  AND        asu.as_course_cd = p_course_cd
  AND        asu.as_version_number = p_version_number
  AND        asu.unit_cd = p_unit_cd
  AND        asu.version_number = p_unit_version
  AND
  --**            asu.prev_unit_cd                = p_previous_unit AND
             asu.unit_details_id = p_unit_details_id
  AND        asu.s_adv_stnd_granting_status IN ('APPROVED', 'GRANTED')
  AND        asu.s_adv_stnd_recognition_type = 'CREDIT'
  AND        puv.unit_cd = asu.unit_cd
  AND        puv.version_number = asu.version_number;

    CURSOR c_adv_test IS
      SELECT asu.achievable_credit_points advance_standing_cp,
             asu.exemption_institution_cd,
             /* asu.credit_percentage, */
             NVL (puv.achievable_credit_points, puv.enrolled_credit_points) enrolled_cp
      FROM   igs_av_stnd_unit asu,
             igs_ps_unit_ver puv
      WHERE  asu.person_id = p_person_id
  AND        asu.as_course_cd = p_course_cd
  AND        asu.as_version_number = p_version_number
  AND        asu.unit_cd = p_unit_cd
  AND        asu.version_number = p_unit_version
  AND
  --            asu.test_Segment_id             = p_test_segment AND
             asu.tst_rslt_dtls_id = p_tst_rslt_dtls_id
  AND        asu.s_adv_stnd_granting_status IN ('APPROVED', 'GRANTED')
  AND        asu.s_adv_stnd_recognition_type = 'CREDIT'
  AND        puv.unit_cd = asu.unit_cd
  AND        puv.version_number = asu.version_number;

    l_adv_preunit c_adv_pre_unit%ROWTYPE;
    l_adv_test    c_adv_test%ROWTYPE;
  BEGIN
    IF p_unit_details_id IS NOT NULL THEN
      -- if previous unit cd is not null then : 1. Checks whether credit points or credit
      -- percentage is null.If credit points is not null then
      -- selects achievable credit points from igs_av_stnd_unit table.If credit percentage
      -- equals 100 then selects achievable credit points from  igs_ps_unit_ver table.

      OPEN c_adv_pre_unit;
      FETCH c_adv_pre_unit INTO l_adv_preunit;

      IF l_adv_preunit.advance_standing_cp IS NOT NULL THEN
      IF (p_exemption_institution_cd IS NOT NULL) AND
         (l_adv_preunit.exemption_institution_cd = p_exemption_institution_cd) THEN
         p_inst_credit_points :=l_adv_preunit.advance_standing_cp;
         END IF;
        p_credit_points := l_adv_preunit.advance_standing_cp;
      /* ELSIF  l_adv_preunit.advance_standing_cp IS NULL
             AND l_adv_preunit.credit_percentage = 100 THEN
          p_credit_points := l_adv_preunit.enrolled_cp; */ --Obsoleted credit_percentage column as part of RECR50 Build.
      END IF;

      CLOSE c_adv_pre_unit;
    ELSIF p_tst_rslt_dtls_id IS NOT NULL THEN
      -- if test segment is not null then : 1. Checks whether credit points or credit
      -- percentage is null.If credit points is not null then
      -- selects achievable credit points from igs_av_stnd_unit table.If credit percentage
      -- equals 100 then selects achievable credit points from  igs_ps_unit_ver table.

      OPEN c_adv_test;
      FETCH c_adv_test INTO l_adv_test;

      IF l_adv_test.advance_standing_cp IS NOT NULL THEN
      IF (p_exemption_institution_cd IS NOT NULL) AND
         (l_adv_test.exemption_institution_cd = p_exemption_institution_cd) THEN
         p_inst_credit_points :=l_adv_test.advance_standing_cp;
         END IF;
        p_credit_points := l_adv_test.advance_standing_cp;
      /* ELSIF  l_adv_test.advance_standing_cp IS NULL
             AND l_adv_test.credit_percentage = 100 THEN
           p_credit_points := l_adv_test.enrolled_cp; */ --Obsoleted credit_percentage column as part of RECR50 Build.
      END IF;
    END IF;
  END advp_get_adv_credit_pts;
  --
  -- Function to return whether advance standing is granted for a student
  --
  FUNCTION granted_adv_standing (
    p_person_id                    IN     NUMBER,
    p_asu_course_cd                IN     VARCHAR2,
    p_asu_version_number           IN     NUMBER,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_s_adv_stnd_granting_status   IN     VARCHAR2,
    p_effective_dt                 IN     DATE
  )
    RETURN VARCHAR2 AS
    CURSOR c_enrolled_cp IS
      SELECT NVL (achievable_credit_points, enrolled_credit_points) enrolled_cp
      FROM   igs_ps_unit_ver
      WHERE  unit_cd = p_unit_cd
  AND        (version_number = p_version_number
              OR p_version_number IS NULL
             );

    CURSOR c_adv_cp_sum IS
      SELECT DECODE (
               p_s_adv_stnd_granting_status,
               s_adv_stnd_granting_status, NVL (asu.achievable_credit_points, 0),
               'BOTH', NVL (asu.achievable_credit_points, 0),
               0
             ) advance_standing_credits,
             asu.unit_cd,
             asu.version_number,
             s_adv_stnd_granting_status
      FROM   igs_av_stnd_unit asu
      WHERE  asu.person_id = p_person_id
  AND        asu.as_course_cd = p_asu_course_cd
  AND        asu.as_version_number = p_asu_version_number
  AND        asu.unit_cd = p_unit_cd
  AND        (asu.version_number = p_version_number
              OR p_version_number IS NULL
             )
  AND        asu.s_adv_stnd_granting_status IN ('GRANTED', 'APPROVED')
  AND        asu.s_adv_stnd_recognition_type = 'CREDIT'
  AND        (p_effective_dt IS NULL
              OR asu.granted_dt <= TRUNC (p_effective_dt)
             );

    CURSOR c_adv_cp_per IS
      SELECT s_adv_stnd_granting_status
      FROM   igs_av_stnd_unit asu
      WHERE  asu.person_id = p_person_id
             AND asu.as_course_cd = p_asu_course_cd
             AND as_version_number = p_asu_version_number
             AND asu.unit_cd = p_unit_cd
             AND (asu.version_number = p_version_number
                  OR p_version_number IS NULL
                 )
             AND asu.s_adv_stnd_granting_status IN ('GRANTED', 'APPROVED')
             AND asu.s_adv_stnd_recognition_type = 'CREDIT'
             AND (p_effective_dt IS NULL
	          OR asu.granted_dt <= TRUNC (p_effective_dt));

    l_adv_credits     c_adv_cp_sum%ROWTYPE;
    l_adv_per_credits c_adv_cp_per%ROWTYPE;
    l_enrolled_cp     NUMBER;
    l_chk_exists      NUMBER                 := 0;
    l_credits         NUMBER                 := 0;
    l_appr_credits    NUMBER                 := 0;
    l_grant_credits   NUMBER                 := 0;
    l_gr_exists       BOOLEAN                := FALSE;
    l_appr_exists     BOOLEAN                := FALSE;
  BEGIN
    OPEN c_enrolled_cp;
    FETCH c_enrolled_cp INTO l_enrolled_cp;
    CLOSE c_enrolled_cp;
    OPEN c_adv_cp_sum;

    LOOP
      FETCH c_adv_cp_sum INTO l_adv_credits;
      EXIT WHEN c_adv_cp_sum%NOTFOUND;
      l_chk_exists := l_chk_exists + 1;
      l_credits := l_credits + NVL (l_adv_credits.advance_standing_credits, 0);

      IF l_adv_credits.s_adv_stnd_granting_status = 'APPROVED' THEN
        l_appr_credits :=
                  l_appr_credits + NVL (
                                     l_adv_credits.advance_standing_credits,
                                     0
                                   );
        l_appr_exists := TRUE;
      ELSIF p_s_adv_stnd_granting_status = 'GRANTED' THEN
        l_grant_credits :=
                 l_grant_credits + NVL (
                                     l_adv_credits.advance_standing_credits,
                                     0
                                   );
        l_gr_exists := TRUE;
      END IF;
    END LOOP;

    CLOSE c_adv_cp_sum;

    IF l_chk_exists = 0 THEN
      RETURN 'FALSE';
    ELSIF l_credits >= l_enrolled_cp THEN
      RETURN 'TRUE';
    ELSE
      OPEN c_adv_cp_per;
      FETCH c_adv_cp_per INTO l_adv_per_credits;

      IF c_adv_cp_per%NOTFOUND THEN
        CLOSE c_adv_cp_per;
        RETURN 'FALSE';
      ELSIF (p_s_adv_stnd_granting_status =
                                      l_adv_per_credits.s_adv_stnd_granting_status
            )
            OR (p_s_adv_stnd_granting_status = 'BOTH') THEN
        CLOSE c_adv_cp_per;
        RETURN 'TRUE';
      ELSE
        CLOSE c_adv_cp_per;
        RETURN 'FALSE';
      END IF;
    END IF;
  END granted_adv_standing;
  --
  --
  --
  FUNCTION adv_credit_pts (
    p_person_id                    IN     NUMBER,
    p_asu_course_cd                IN     VARCHAR2,
    p_asu_version_number           IN     NUMBER,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_s_adv_stnd_granting_status   IN     VARCHAR2,
    p_effective_dt                 IN     DATE,
    p_cr_points                    OUT NOCOPY NUMBER,
    p_adv_grant_status             OUT NOCOPY VARCHAR2,
    p_msg                          OUT NOCOPY VARCHAR2
  )
    RETURN BOOLEAN IS
    CURSOR c_enrolled_cp IS
      SELECT NVL (achievable_credit_points, enrolled_credit_points) enrolled_cp
      FROM   igs_ps_unit_ver
      WHERE  unit_cd = p_unit_cd
  AND        (version_number = p_version_number
              OR p_version_number IS NULL
             );

    CURSOR c_adv_cp_sum IS
      SELECT DECODE (
               p_s_adv_stnd_granting_status,
               s_adv_stnd_granting_status, NVL (asu.achievable_credit_points, 0),
               'BOTH', NVL (asu.achievable_credit_points, 0),
               0
             ) advance_standing_credits,
             asu.unit_cd,
             asu.version_number,
             s_adv_stnd_granting_status
      FROM   igs_av_stnd_unit asu
      WHERE  asu.person_id = p_person_id
  AND        asu.as_course_cd = p_asu_course_cd
  AND        asu.as_version_number = p_asu_version_number
  AND        asu.unit_cd = p_unit_cd
  AND        (asu.version_number = p_version_number
              OR p_version_number IS NULL
             )
  AND        asu.s_adv_stnd_granting_status IN ('GRANTED', 'APPROVED')
  AND        asu.s_adv_stnd_recognition_type = 'CREDIT'
  AND        (p_effective_dt IS NULL
              OR asu.granted_dt <= TRUNC (p_effective_dt)
             );

    CURSOR c_adv_cp_per IS
      SELECT s_adv_stnd_granting_status
      FROM   igs_av_stnd_unit asu
      WHERE  asu.person_id = p_person_id
             AND asu.as_course_cd = p_asu_course_cd
             AND as_version_number = p_asu_version_number
             AND asu.unit_cd = p_unit_cd
             AND (asu.version_number = p_version_number
                  OR p_version_number IS NULL
                 )
             AND asu.s_adv_stnd_granting_status IN ('GRANTED', 'APPROVED')
             AND asu.s_adv_stnd_recognition_type = 'CREDIT'
             AND p_effective_dt IS NULL
  OR         asu.granted_dt <= TRUNC (p_effective_dt)
             /* AND credit_percentage = 100 */;

    l_adv_credits     c_adv_cp_sum%ROWTYPE;
    l_adv_per_credits c_adv_cp_per%ROWTYPE;
    l_enrolled_cp     NUMBER;
    l_chk_exists      NUMBER                 := 0;
    l_credits         NUMBER                 := 0;
    l_appr_credits    NUMBER                 := 0;
    l_grant_credits   NUMBER                 := 0;
    l_gr_exists       BOOLEAN                := FALSE;
    l_appr_exists     BOOLEAN                := FALSE;
  BEGIN
    OPEN c_enrolled_cp;
    FETCH c_enrolled_cp INTO l_enrolled_cp;
    CLOSE c_enrolled_cp;
    OPEN c_adv_cp_sum;

    LOOP
      FETCH c_adv_cp_sum INTO l_adv_credits;
      EXIT WHEN c_adv_cp_sum%NOTFOUND;
      l_chk_exists := l_chk_exists + 1;
      l_credits := l_credits + NVL (l_adv_credits.advance_standing_credits, 0);

      IF l_adv_credits.s_adv_stnd_granting_status = 'APPROVED' THEN
        l_appr_credits :=
                  l_appr_credits + NVL (
                                     l_adv_credits.advance_standing_credits,
                                     0
                                   );
        l_appr_exists := TRUE;
      ELSIF l_adv_credits.s_adv_stnd_granting_status = 'GRANTED' THEN
        l_grant_credits :=
                 l_grant_credits + NVL (
                                     l_adv_credits.advance_standing_credits,
                                     0
                                   );
        l_gr_exists := TRUE;
      END IF;
    END LOOP;

    CLOSE c_adv_cp_sum;

    IF l_chk_exists = 0 THEN
      p_cr_points := 0;
      p_msg := 'IGS_AV_NO_PERSON_UNITS';
      RETURN FALSE;
    ELSIF l_credits >= l_enrolled_cp THEN
      p_cr_points := l_credits;

      IF  l_appr_exists
          AND l_gr_exists THEN
        p_adv_grant_status := 'BOTH';
      ELSIF l_appr_exists THEN
        p_adv_grant_status := 'APPROVED';
      ELSIF l_gr_exists THEN
        p_adv_grant_status := 'GRANTED';
      END IF;

      RETURN TRUE;
    ELSE
      OPEN c_adv_cp_per;
      FETCH c_adv_cp_per INTO l_adv_per_credits;

      IF c_adv_cp_per%NOTFOUND THEN
        CLOSE c_adv_cp_per;
        p_cr_points := l_credits; -- if there are no records with 100% then assign credits to calculated credits
        RETURN FALSE;
      ELSIF (p_s_adv_stnd_granting_status =
                                      l_adv_per_credits.s_adv_stnd_granting_status
            )
            OR (p_s_adv_stnd_granting_status = 'BOTH') THEN
        p_cr_points := l_enrolled_cp;

        IF l_adv_per_credits.s_adv_stnd_granting_status = 'APPROVED' THEN
          p_adv_grant_status := 'APPROVED';
        ELSIF l_adv_per_credits.s_adv_stnd_granting_status = 'GRANTED' THEN
          p_adv_grant_status := 'GRANTED';
        END IF;

        CLOSE c_adv_cp_per;
        RETURN TRUE;
      ELSE
        p_cr_points := l_credits; -- if there are no records with 100% then assign credits to calculated credits
        CLOSE c_adv_cp_per;
        RETURN FALSE;
      END IF;
    END IF;
  END adv_credit_pts;
END igs_av_val_asu;

/
