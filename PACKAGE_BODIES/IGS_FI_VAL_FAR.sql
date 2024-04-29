--------------------------------------------------------
--  DDL for Package Body IGS_FI_VAL_FAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_VAL_FAR" AS
/* $Header: IGSFI22B.pls 120.2 2005/08/29 02:36:37 appldev ship $ */

--Who          When         What
--gurprsin    29-Aug-2005   Bug #4564002, modified cursor c_far.
-- svuppala   03-Jun-2005   Enh# 3442712 - Modified finp_val_far_unique
--pathipat     10-Sep-2003  Enh 3108052 - Add Unit Sets to Rate Table
--                          Modified finp_val_far_unique() - Added 2 new params
-- vvutukur    29-Nov-2002  Enh#2564986.Obsoleted function FINP_VAL_FAR_CUR.
-- npalanis    23-OCT-2002  Bug : 2608360
--                          p_residency_status_id column is changed to p_residency_status_cd of
--                          datatype varchar2.
--
--
-- npalanis   23-OCT-2002     Bug : 2547368
--                            Defaulting arguments in funtion and procedure definitions removed
-- bug id : 1956374
-- sjadhav , 28-aug-2001
-- removed FUNCTION enrp_val_att_closed
--

  -- Validate fee assessment rate can be created for the relation type.
  FUNCTION finp_val_far_create(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN -- finp_val_far_create
        -- Validate if IGS_FI_FEE_AS_RATE records can be created.
        -- When defined at FTCI level, they cannot also be
        -- defined at FCFL level and vice-versa.
  DECLARE
        CURSOR c_far (
                cp_s_relation_type              IGS_FI_FEE_AS_RATE.s_relation_type%TYPE) IS
                SELECT  'x'
                FROM    IGS_FI_FEE_AS_RATE
                WHERE   fee_type                = p_fee_type AND
                        fee_cal_type            = p_fee_cal_type AND
                        fee_ci_sequence_number  = p_fee_ci_sequence_number AND
                        s_relation_type         = cp_s_relation_type AND
                        logical_delete_dt       IS NULL;
        v_fcfl_exists           VARCHAR2(1);
        v_ftci_exists           VARCHAR2(1);
  BEGIN
        -- Set the default message number
        p_message_name := Null;
        -- 1. Check Parameters
        IF p_fee_type IS NULL OR
                        p_fee_cal_type IS NULL OR
                        p_fee_ci_sequence_number IS NULL OR
                        p_s_relation_type IS NULL THEN
                RETURN TRUE;
        END IF;
        -- 2. If p_s_relation_type = 'FCFL', check if any IGS_FI_FEE_AS_RATE records
        -- have been defined at the FTCI level.  If so, return error.
        IF p_s_relation_type = 'FCFL' THEN
                OPEN c_far(
                        'FTCI');
                FETCH c_far INTO v_ftci_exists;
                IF c_far%FOUND THEN
                        CLOSE c_far;
                        p_message_name := 'IGS_FI_ASSRATES_NOT_DEFINED';
                        RETURN FALSE;
                END IF;
                CLOSE c_far;
        END IF;
        -- 3. If p_s_relation_type = 'FTCI', check if any IGS_FI_FEE_AS_RATE records
        -- have been defined at the FCFL level.  If so, return error.
        IF p_s_relation_type = 'FTCI' THEN
                OPEN c_far(
                        'FCFL');
                FETCH c_far INTO v_fcfl_exists;
                IF c_far%FOUND THEN
                        CLOSE c_far;
                        p_message_name := 'IGS_FI_ASSRATES_NOT_DFNED_FEE';
                        RETURN FALSE;
                END IF;
                CLOSE c_far;
        END IF;
        RETURN TRUE;
  END;
  END finp_val_far_create;
  --
  -- Validate IGS_PS_COURSE location code.
  FUNCTION crsp_val_loc_cd(
  p_location_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        v_location_closed_ind   IGS_AD_LOCATION.closed_ind%TYPE;
        v_location_type         IGS_AD_LOCATION.location_type%TYPE;
        v_s_location_type       IGS_AD_LOCATION_TYPE.s_location_type%TYPE;
        CURSOR  c_location_cd(
                        cp_location_cd          IGS_AD_LOCATION.location_cd%TYPE) IS
                SELECT  IGS_AD_LOCATION.closed_ind,
                        location_type
                FROM    IGS_AD_LOCATION
                WHERE   location_cd = cp_location_cd;
        CURSOR  c_location_type(
                        cp_location_type        IGS_AD_LOCATION_TYPE.location_type%TYPE) IS
                SELECT  s_location_type
                FROM    IGS_AD_LOCATION_TYPE
                WHERE   location_type = cp_location_type;
        v_other_detail  VARCHAR2(255);
  BEGIN
        -- This module based on the parameter performs validations
        -- for for the location code within the CS and P subsystem
        p_message_name := Null;
        v_location_closed_ind := NULL;
        -- Test the value of closed indicator
        OPEN  c_location_cd(
                        p_location_cd);
        FETCH c_location_cd INTO v_location_closed_ind,
                                 v_location_type;
                CLOSE c_location_cd;
        IF (v_location_closed_ind IS NULL) THEN
                RETURN TRUE;
        ELSE
                IF(v_location_closed_ind = 'Y') THEN
                        p_message_name := 'IGS_PS_LOC_CODE_CLOSED';
                        RETURN FALSE;
                END IF;
        END IF;
        -- Test the value of system location type
        OPEN  c_location_type(
                        v_location_type);
        FETCH c_location_type INTO v_s_location_type;
                CLOSE c_location_type;
        IF (NVL(v_s_location_type,'NULL') <> 'CAMPUS') THEN
                p_message_name := 'IGS_PS_LOC_NOT_TYPE_CAMPUS';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
  END crsp_val_loc_cd;
  --
  -- Ensure govt_hecs_payment_option is specified.
  FUNCTION finp_val_far_rqrd(
  p_fee_type IN VARCHAR2 ,
  p_govt_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN -- finp_val_far_rqrd
        -- Validate if IGS_FI_FEE_TYPE.s_fee_type = 'HECS' or 'TUITION',
        -- then IGS_FI_FEE_AS_RATE.govt_hecs_payment_option must be entered.
  DECLARE
        v_dummy         VARCHAR2(1);
        CURSOR c_ft IS
                SELECT  'x'
                FROM    IGS_FI_FEE_TYPE ft
                WHERE   ft.fee_type     = p_fee_type AND
                        ft.s_fee_type   IN ('HECS','TUITION');
  BEGIN
        -- Set the default message number
        p_message_name := Null;
        -- 1. Check parameters :
        IF (p_fee_type IS NULL) THEN
                Return TRUE;
        END IF;
        -- 2. Determine the IGS_FI_FEE_TYPE.s_fee_type value.
        OPEN c_ft;
        FETCH c_ft INTO v_dummy;
        IF  c_ft%FOUND THEN   --govt_hecs_payment_option must exist
                IF (p_govt_hecs_payment_option IS NULL) THEN
                        CLOSE c_ft;
                        -- Government HECS Payment option must be specified for this Fee Type.
                        p_message_name := 'IGS_FI_GOVT_HECS_PYMNT';
                        RETURN FALSE;
                END IF;
        END IF;
        CLOSE c_ft;
        -- 3. Return no error:
        RETURN TRUE;
  EXCEPTION
        WHEN OTHERS THEN
                IF c_ft%ISOPEN THEN
                        CLOSE c_ft;
                END IF;
                RAISE;
  END;
  END finp_val_far_rqrd;
  --
  -- Validate fee assessment rate is unqiue.
  FUNCTION finp_val_far_unique(
  p_fee_type                   IN VARCHAR2 ,
  p_fee_cal_type               IN VARCHAR2 ,
  p_fee_ci_sequence_number     IN NUMBER ,
  p_s_relation_type            IN VARCHAR2 ,
  p_rate_number                IN NUMBER ,
  p_fee_cat                    IN VARCHAR2 ,
  p_location_cd                IN VARCHAR2 ,
  p_attendance_type            IN VARCHAR2 ,
  p_attendance_mode            IN VARCHAR2 ,
  p_govt_hecs_payment_option   IN VARCHAR2 ,
  p_govt_hecs_cntrbtn_band     IN NUMBER ,
  p_chg_rate                   IN NUMBER ,
  p_unit_class                 IN VARCHAR2,
  p_residency_status_cd        IN VARCHAR2 ,
  p_course_cd                  IN VARCHAR2 ,
  p_version_number             IN NUMBER ,
  p_org_party_id               IN NUMBER ,
  p_class_standing             IN VARCHAR2 ,
  p_message_name               OUT NOCOPY VARCHAR2 ,
  p_unit_set_cd                IN VARCHAR2,
  p_us_version_number          IN NUMBER,
  p_unit_cd                   IN VARCHAR2 ,
  p_unit_version_number       IN NUMBER   ,
  p_unit_level                IN VARCHAR2 ,
  p_unit_type_id              IN NUMBER   ,
  p_unit_mode                 IN VARCHAR2
  )  RETURN BOOLEAN AS
  /*****************************************************************************/
  --Change History
  --Who          When         What
  --gurprsin     29-Aug-2005  Bug #4564002, modified cursor c_far
  --pathipat     10-Sep-2003  Enh 3108052 - Add Unit Sets to Rate Table
  --                          Modified finp_val_far_unique() - Added 2 new params
  --                          Modified cursor c_far
  /*****************************************************************************/
        gv_other_detail         VARCHAR2(255);
  BEGIN -- finp_val_far_unique
        -- Validate if IGS_FI_FEE_AS_RATE.location_cd, IGS_FI_FEE_AS_RATE.attendance_type,
        -- IGS_FI_FEE_AS_RATE.attendance_mode, IGS_FI_FEE_AS_RATE.govt_hecs_payment_option
        -- and IGS_FI_FEE_AS_RATE.govt_hecs_cntrbtn_band form a unique combination.
        -- Required as all five fields are optional.
   DECLARE
        v_dummy         VARCHAR2(1);
        CURSOR c_far IS
                SELECT 'x'
                FROM    igs_fi_fee_as_rate      far
                WHERE   far.fee_type                             = p_fee_type
                AND     far.fee_cal_type                         = p_fee_cal_type
                AND     far.fee_ci_sequence_number               = p_fee_ci_sequence_number
                AND     far.s_relation_type                      = p_s_relation_type
                AND     far.rate_number                          <> NVL(p_rate_number,0)
                AND     NVL(far.fee_cat,'NULL')                  = NVL(p_fee_cat,'NULL')
                AND     NVL(far.location_cd,'NULL')              = NVL(p_location_cd,'NULL')
                AND     NVL(far.attendance_type,'NULL')          = NVL(p_attendance_type,'NULL')
                AND     NVL(far.attendance_mode,'NULL')          = NVL(p_attendance_mode,'NULL')
                AND     NVL(far.govt_hecs_payment_option,'NULL') = NVL(p_govt_hecs_payment_option,'NULL')
                AND     NVL(far.govt_hecs_cntrbtn_band,0)        = NVL(p_govt_hecs_cntrbtn_band,0)
                AND     NVL(far.chg_rate,0)                      = NVL(p_chg_rate,0)
              --  AND     NVL(far.unit_class,'NULL')               = NVL(p_unit_class,'NULL')
                AND     far.logical_delete_dt IS NULL
                AND     NVL(far.residency_status_cd,0)           = NVL(p_residency_status_cd,0)
                AND     NVL(far.course_cd,'NULL')                = NVL(p_course_cd,'NULL')
                AND     NVL(far.version_number,0)                = NVL(p_version_number,0)
                AND     NVL(far.org_party_id,0)                  = NVL(p_org_party_id,0)
                --Bug #4564002, passed p_class_standing instead of class_standing
                AND     NVL(far.class_standing,'NULL')           = NVL(p_class_standing,'NULL')
                AND     NVL(far.unit_set_cd,'NULL')              = NVL(p_unit_set_cd,'NULL')
                AND     NVL(far.us_version_number,0)             = NVL(p_us_version_number,0)
                AND     NVL(FAR.UNIT_TYPE_ID,0)                  = NVL(P_UNIT_TYPE_ID,0)
                AND    (( FAR.UNIT_CLASS = P_UNIT_CLASS) OR (FAR.UNIT_CLASS IS NULL AND P_UNIT_CLASS IS NULL))
                AND    ((FAR.UNIT_MODE = P_UNIT_MODE) OR (FAR.UNIT_MODE IS NULL AND P_UNIT_MODE IS NULL))
                AND    ((FAR.UNIT_CD = P_UNIT_CD) OR (FAR.UNIT_CD IS NULL AND P_UNIT_CD IS NULL))
                AND     NVL(FAR.UNIT_VERSION_NUMBER,0)           = NVL(P_UNIT_VERSION_NUMBER,0)
                AND    ((FAR.UNIT_LEVEL = P_UNIT_LEVEL) OR (FAR.UNIT_LEVEL IS NULL AND P_UNIT_LEVEL IS NULL))
                ;

   BEGIN
        -- Set the default message number
        p_message_name := Null;
        -- 1. Check parameters :
        IF (p_fee_type IS NULL                           OR
                        p_fee_cal_type IS NULL           OR
                        p_fee_ci_sequence_number IS NULL OR
                        p_s_relation_type IS NULL) THEN
                RETURN TRUE;
        END IF;
        -- 2. Validate that the current record is unique.
        -- Note : rate_number may be passed as a null value if the current
        -- record has not been committed.
        OPEN c_far;
        FETCH c_far INTO v_dummy;
        IF c_far%FOUND THEN  --duplicate condition
                CLOSE c_far;
                p_message_name := 'IGS_GE_RECORD_ALREADY_EXISTS';
                RETURN FALSE;
        END IF;
        CLOSE c_far;
        -- 3. Return no error:
        RETURN TRUE;
   EXCEPTION
        WHEN OTHERS THEN
                IF c_far%ISOPEN THEN
                        CLOSE c_far;
                END IF;
                RAISE;
   END;
 END finp_val_far_unique;

  --
  -- Validate fee assessment rate order of precednce.
  FUNCTION finp_val_far_order(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_rate_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_govt_hecs_payment_option IN VARCHAR2 ,
  p_govt_hecs_cntrbtn_band IN NUMBER ,
  p_order_of_precedence IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail                 VARCHAR2(255);
  BEGIN         -- finp_val_far_order
        -- Validate IGS_FI_FEE_AS_RATE.order_of_precedence exists when one or more of
        -- IGS_FI_FEE_AS_RATE.attendance_type, IGS_FI_FEE_AS_RATE.attendance_mode or
        -- IGS_FI_FEE_AS_RATE.location_cd are specified, resulting in a non-mutually
        -- exclusive fee assessment rate.
        -- The mutually exclusive combinations are :
        -- only location code is defined across all related rates
        -- only attendance type is defined across all related rates
        -- only attendance mode is defined across all related rates
        -- only location code and attendance type are defined across all related
        -- rates
        -- location code, attendance type and attendance mode are defined across
        -- all related rates
        -- only location code and attendance mode are defined across all related
        -- rates
        -- only attendance type and attendance mode are defined across all
        -- related rates
        -- All other combinations may result in non-mutually exclusive fee assessment
        -- rates, so an order_of_precedence value is required.
  DECLARE
        cst_prorata                     CONSTANT VARCHAR2(8) := 'PRO RATA';
        v_far_1_rec_found               BOOLEAN         :=  FALSE;
        v_far_2_rec_found               BOOLEAN         := FALSE;
        v_far_3_rec_found               BOOLEAN         := FALSE;
        v_far_4_rec_found               BOOLEAN         := FALSE;
        v_far_5_rec_found               BOOLEAN         := FALSE;
        v_far_6_rec_found               BOOLEAN         := FALSE;
        v_far_7_rec_found               BOOLEAN         := FALSE;
        v_far_8_rec_found               BOOLEAN         := FALSE;
        v_far_9_rec_found               BOOLEAN         := FALSE;
        CURSOR c_far_1 (
                        cp_fee_type                     IGS_FI_FEE_AS_RATE.fee_type%TYPE,
                        cp_fee_cal_type                 IGS_FI_FEE_AS_RATE.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number       IGS_FI_FEE_AS_RATE.fee_ci_sequence_number%TYPE,
                        cp_s_relation_type              IGS_FI_FEE_AS_RATE.s_relation_type%TYPE,
                        cp_rate_number                  IGS_FI_FEE_AS_RATE.rate_number%TYPE,
                        cp_fee_cat                      IGS_FI_FEE_AS_RATE.fee_cat%TYPE) IS
                SELECT  far.order_of_precedence
                FROM    IGS_FI_FEE_AS_RATE                      far
                WHERE   far.fee_type                    = cp_fee_type AND
                        far.fee_cal_type                = cp_fee_cal_type AND
                        far.fee_ci_sequence_number      = cp_fee_ci_sequence_number AND
                        far.s_relation_type             = cp_s_relation_type AND
                        far.rate_number                 <> cp_rate_number AND
                        far.logical_delete_dt           IS NULL AND
                        NVL(far.fee_cat,'NULL')         = NVL(cp_fee_cat,'NULL') AND
                        ((far.location_cd               IS NULL) OR
                         (far.attendance_mode           IS NOT NULL OR far.attendance_type IS NOT NULL));
        CURSOR c_far_2 (
                        cp_fee_type                     IGS_FI_FEE_AS_RATE.fee_type%TYPE,
                        cp_fee_cal_type                 IGS_FI_FEE_AS_RATE.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number       IGS_FI_FEE_AS_RATE.fee_ci_sequence_number%TYPE,
                        cp_s_relation_type              IGS_FI_FEE_AS_RATE.s_relation_type%TYPE,
                        cp_rate_number                  IGS_FI_FEE_AS_RATE.rate_number%TYPE,
                        cp_fee_cat                      IGS_FI_FEE_AS_RATE.fee_cat%TYPE) IS
                SELECT  far.order_of_precedence
                FROM    IGS_FI_FEE_AS_RATE                      far
                WHERE   far.fee_type                    = cp_fee_type AND
                        far.fee_cal_type                = cp_fee_cal_type AND
                        far.fee_ci_sequence_number      = cp_fee_ci_sequence_number AND
                        far.s_relation_type             = cp_s_relation_type AND
                        far.rate_number                 <> cp_rate_number AND
                        far.logical_delete_dt           IS NULL AND
                        NVL(far.fee_cat,'NULL')         = NVL(cp_fee_cat,'NULL') AND
                        ((far.location_cd               IS NULL OR far.attendance_mode IS NULL) OR
                         (far.attendance_type IS NOT NULL));
        CURSOR c_far_3 (
                        cp_fee_type                     IGS_FI_FEE_AS_RATE.fee_type%TYPE,
                        cp_fee_cal_type                 IGS_FI_FEE_AS_RATE.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number       IGS_FI_FEE_AS_RATE.fee_ci_sequence_number%TYPE,
                        cp_s_relation_type              IGS_FI_FEE_AS_RATE.s_relation_type%TYPE,
                        cp_rate_number                  IGS_FI_FEE_AS_RATE.rate_number%TYPE,
                        cp_fee_cat                      IGS_FI_FEE_AS_RATE.fee_cat%TYPE) IS
                SELECT  far.order_of_precedence
                FROM    IGS_FI_FEE_AS_RATE                      far
                WHERE   far.fee_type                    = cp_fee_type AND
                        far.fee_cal_type                = cp_fee_cal_type AND
                        far.fee_ci_sequence_number      = cp_fee_ci_sequence_number AND
                        far.s_relation_type             = cp_s_relation_type AND
                        far.rate_number                 <> cp_rate_number AND
                        far.logical_delete_dt           IS NULL AND
                        NVL(far.fee_cat,'NULL')         = NVL(cp_fee_cat,'NULL') AND
                        ((far.location_cd               IS NULL OR far.attendance_type IS NULL) OR
                         (far.attendance_mode IS NOT NULL));
        CURSOR c_far_4 (
                        cp_fee_type                     IGS_FI_FEE_AS_RATE.fee_type%TYPE,
                        cp_fee_cal_type                 IGS_FI_FEE_AS_RATE.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number       IGS_FI_FEE_AS_RATE.fee_ci_sequence_number%TYPE,
                        cp_s_relation_type              IGS_FI_FEE_AS_RATE.s_relation_type%TYPE,
                        cp_rate_number                  IGS_FI_FEE_AS_RATE.rate_number%TYPE,
                        cp_fee_cat                      IGS_FI_FEE_AS_RATE.fee_cat%TYPE) IS
                SELECT  far.order_of_precedence
                FROM    IGS_FI_FEE_AS_RATE                      far
                WHERE   far.fee_type                    = cp_fee_type AND
                        far.fee_cal_type                = cp_fee_cal_type AND
                        far.fee_ci_sequence_number      = cp_fee_ci_sequence_number AND
                        far.s_relation_type             = cp_s_relation_type AND
                        far.rate_number                 <> cp_rate_number AND
                        far.logical_delete_dt           IS NULL AND
                        NVL(far.fee_cat,'NULL')         = NVL(cp_fee_cat,'NULL') AND
                        ((far.location_cd               IS NULL OR
                          far.attendance_mode           IS NULL) OR
                         (far.attendance_type           IS NULL));
        CURSOR c_far_5 (
                        cp_fee_type                     IGS_FI_FEE_AS_RATE.fee_type%TYPE,
                        cp_fee_cal_type                 IGS_FI_FEE_AS_RATE.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number       IGS_FI_FEE_AS_RATE.fee_ci_sequence_number%TYPE,
                        cp_s_relation_type              IGS_FI_FEE_AS_RATE.s_relation_type%TYPE,
                        cp_rate_number                  IGS_FI_FEE_AS_RATE.rate_number%TYPE,
                        cp_fee_cat                      IGS_FI_FEE_AS_RATE.fee_cat%TYPE) IS
                SELECT  far.order_of_precedence
                FROM    IGS_FI_FEE_AS_RATE                      far
                WHERE   far.fee_type                    = cp_fee_type AND
                        far.fee_cal_type                = cp_fee_cal_type AND
                        far.fee_ci_sequence_number      = cp_fee_ci_sequence_number AND
                        far.s_relation_type             = cp_s_relation_type AND
                        far.rate_number                 <> cp_rate_number AND
                        far.logical_delete_dt           IS NULL AND
                        NVL(far.fee_cat,'NULL')         = NVL(cp_fee_cat,'NULL') AND
                        ((far.attendance_type           IS NULL) OR
                         (far.location_cd               IS NOT NULL OR far.attendance_mode IS NOT NULL));
        CURSOR c_far_6 (
                        cp_fee_type                     IGS_FI_FEE_AS_RATE.fee_type%TYPE,
                        cp_fee_cal_type                 IGS_FI_FEE_AS_RATE.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number       IGS_FI_FEE_AS_RATE.fee_ci_sequence_number%TYPE,
                        cp_s_relation_type              IGS_FI_FEE_AS_RATE.s_relation_type%TYPE,
                        cp_rate_number                  IGS_FI_FEE_AS_RATE.rate_number%TYPE,
                        cp_fee_cat                      IGS_FI_FEE_AS_RATE.fee_cat%TYPE) IS
                SELECT  far.order_of_precedence
                FROM    IGS_FI_FEE_AS_RATE                      far
                WHERE   far.fee_type                    = cp_fee_type AND
                        far.fee_cal_type                = cp_fee_cal_type AND
                        far.fee_ci_sequence_number      = cp_fee_ci_sequence_number AND
                        far.s_relation_type             = cp_s_relation_type AND
                        far.rate_number                 <> cp_rate_number AND
                        far.logical_delete_dt           IS NULL AND
                        NVL(far.fee_cat,'NULL')         = NVL(cp_fee_cat,'NULL') AND
                        ((far.attendance_mode           IS NULL OR far.attendance_type IS NULL) OR
                         (far.location_cd IS NOT NULL));
        CURSOR c_far_7 (
                        cp_fee_type                     IGS_FI_FEE_AS_RATE.fee_type%TYPE,
                        cp_fee_cal_type                 IGS_FI_FEE_AS_RATE.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number       IGS_FI_FEE_AS_RATE.fee_ci_sequence_number%TYPE,
                        cp_s_relation_type              IGS_FI_FEE_AS_RATE.s_relation_type%TYPE,
                        cp_rate_number                  IGS_FI_FEE_AS_RATE.rate_number%TYPE,
                        cp_fee_cat                      IGS_FI_FEE_AS_RATE.fee_cat%TYPE) IS
                SELECT  far.order_of_precedence
                FROM    IGS_FI_FEE_AS_RATE                      far
                WHERE   far.fee_type                    = cp_fee_type AND
                        far.fee_cal_type                = cp_fee_cal_type AND
                        far.fee_ci_sequence_number      = cp_fee_ci_sequence_number AND
                        far.s_relation_type             = cp_s_relation_type AND
                        far.rate_number                 <> cp_rate_number AND
                        far.logical_delete_dt           IS NULL AND
                        NVL(far.fee_cat,'NULL')         = NVL(cp_fee_cat,'NULL') AND
                        ((far.attendance_mode           IS NULL) OR
                         (far.location_cd               IS NOT NULL OR far.attendance_type IS NOT NULL));
        CURSOR c_far_8 (
                        cp_fee_type                     IGS_FI_FEE_AS_RATE.fee_type%TYPE,
                        cp_fee_cal_type                 IGS_FI_FEE_AS_RATE.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number       IGS_FI_FEE_AS_RATE.fee_ci_sequence_number%TYPE,
                        cp_s_relation_type              IGS_FI_FEE_AS_RATE.s_relation_type%TYPE,
                        cp_rate_number                  IGS_FI_FEE_AS_RATE.rate_number%TYPE,
                        cp_fee_cat                      IGS_FI_FEE_AS_RATE.fee_cat%TYPE,
                        cp_order_of_precedence          IGS_FI_FEE_AS_RATE.order_of_precedence%TYPE) IS
                SELECT  far.order_of_precedence
                FROM    IGS_FI_FEE_AS_RATE                      far
                WHERE   far.fee_type                    = cp_fee_type AND
                        far.fee_cal_type                = cp_fee_cal_type AND
                        far.fee_ci_sequence_number      = cp_fee_ci_sequence_number AND
                        far.s_relation_type             = cp_s_relation_type AND
                        far.rate_number                 <> cp_rate_number AND
                        far.logical_delete_dt           IS NULL AND
                        NVL(far.fee_cat,'NULL')         = NVL(cp_fee_cat,'NULL') AND
                        far.order_of_precedence         = cp_order_of_precedence;
        CURSOR c_far_9 (
                        cp_fee_type                     IGS_FI_FEE_AS_RATE.fee_type%TYPE,
                        cp_fee_cal_type                 IGS_FI_FEE_AS_RATE.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number       IGS_FI_FEE_AS_RATE.fee_ci_sequence_number%TYPE,
                        cp_s_relation_type              IGS_FI_FEE_AS_RATE.s_relation_type%TYPE,
                        cp_rate_number                  IGS_FI_FEE_AS_RATE.rate_number%TYPE,
                        cp_fee_cat                      IGS_FI_FEE_AS_RATE.fee_cat%TYPE,
                        cp_location_cd  IGS_FI_FEE_AS_RATE.location_cd%TYPE,
                        cp_attendance_mode      IGS_FI_FEE_AS_RATE.attendance_mode%TYPE,
                        cp_attendance_type      IGS_FI_FEE_AS_RATE.attendance_type%TYPE,
                        cp_govt_hecs_payment_option IGS_FI_FEE_AS_RATE.govt_hecs_payment_option%TYPE,
                        cp_govt_hecs_cntrbtn_band IGS_FI_FEE_AS_RATE.govt_hecs_cntrbtn_band%TYPE) IS
                SELECT  far.order_of_precedence
                FROM    IGS_FI_FEE_AS_RATE                      far
                WHERE   far.fee_type                    = cp_fee_type AND
                        far.fee_cal_type                        = cp_fee_cal_type AND
                        far.fee_ci_sequence_number      = cp_fee_ci_sequence_number AND
                        far.s_relation_type                     = cp_s_relation_type AND
                        far.rate_number                 <> cp_rate_number AND
                        far.logical_delete_dt           IS NULL AND
                        NVL(far.fee_cat,'NULL')         = NVL(cp_fee_cat,'NULL') AND
                        NVL(far.location_cd,'NULL')             = NVL(cp_location_cd,'NULL') AND
                        NVL(far.attendance_mode,'NULL') = NVL(cp_attendance_mode,'NULL') AND
                        NVL(far.attendance_type,'NULL') = NVL(cp_attendance_type,'NULL') AND
                        NVL(far.govt_hecs_payment_option,'X') =
                                                NVL(cp_govt_hecs_payment_option,'X') AND
                        NVL(far.govt_hecs_cntrbtn_band,0)       = nvl(cp_govt_hecs_cntrbtn_band,0);
  BEGIN
        p_message_name := Null;
        -- Check parameters
        IF(p_fee_type IS NULL OR
                        p_fee_cal_type IS NULL OR
                        p_fee_ci_sequence_number IS NULL OR
                        p_s_relation_type IS NULL OR
                        p_rate_number IS NULL) THEN
                Return TRUE;
        END IF;
        -- Validate that order_of_precedence is specified if required
        -- (ie. if varying combinations of location_cd, attendance_type and
        -- attendance_mode have been specified).
        IF(p_order_of_precedence IS NULL) THEN
                IF(p_location_cd IS NOT NULL) THEN
                        IF(p_attendance_type IS NULL) THEN
                                IF(p_attendance_mode IS NULL) then
                                        -- Check that other records only have location_cd specified.
                                        -- If not, an order of precedence value is required.
                                        FOR v_far_1_rec IN c_far_1(
                                                                p_fee_type,
                                                                p_fee_cal_type,
                                                                p_fee_ci_sequence_number,
                                                                p_s_relation_type,
                                                                p_rate_number,
                                                                p_fee_cat) LOOP
                                                v_far_1_rec_found := TRUE;
                                        END LOOP;
                                ELSE -- p_attendance_mode IS NOT NULL
                                        -- Check location and mode.
                                        -- Check that other records only have location_cd and attendance_mode
                                        -- specified. If not, an order of precedence value is required.
                                        FOR v_far_2_rec IN c_far_2(
                                                                p_fee_type,
                                                                p_fee_cal_type,
                                                                p_fee_ci_sequence_number,
                                                                p_s_relation_type,
                                                                p_rate_number,
                                                                p_fee_cat) LOOP
                                                v_far_2_rec_found := TRUE;
                                        END LOOP;
                                END IF;
                        ELSE -- p_attendance_type IS NOT NULL
                                IF(p_attendance_mode IS NULL) THEN
                                        -- Check location and type.
                                        -- Check that other records only have location_cd and attendance_type
                                        -- specified.  If not, an order of precedence value is required.
                                        FOR v_far_3_rec IN c_far_3(
                                                                p_fee_type,
                                                                p_fee_cal_type,
                                                                p_fee_ci_sequence_number,
                                                                p_s_relation_type,
                                                                p_rate_number,
                                                                p_fee_cat) LOOP
                                                v_far_3_rec_found := TRUE;
                                        END LOOP;
                                ELSE -- p_attendance_mode IS NOT NULL
                                        -- Check_loc_type_and_mode.
                                        -- Check that other records all have location_cd, attendance_type
                                        -- and attendance_mode specified.  If not, an order of precedence value
                                        -- is required.
                                        FOR v_far_4_rec IN c_far_4(
                                                                p_fee_type,
                                                                p_fee_cal_type,
                                                                p_fee_ci_sequence_number,
                                                                p_s_relation_type,
                                                                p_rate_number,
                                                                p_fee_cat) LOOP
                                                v_far_4_rec_found := TRUE;
                                        END LOOP;
                                END IF;
                        END IF;
                ELSE -- p_location_cd IS NULL
                        IF(p_attendance_type IS NOT NULL) THEN
                                IF(p_attendance_mode IS NULL) THEN
                                        -- Check_type.
                                        -- Check that other records only have attendance_type specified.
                                        -- If not, an order of precedence value is required.
                                        FOR v_far_5_rec IN c_far_5(
                                                                p_fee_type,
                                                                p_fee_cal_type,
                                                                p_fee_ci_sequence_number,
                                                                p_s_relation_type,
                                                                p_rate_number,
                                                                p_fee_cat) LOOP
                                                v_far_5_rec_found := TRUE;
                                        END LOOP;
                                ELSE -- p_attendance_mode IS NOT NULL
                                        -- Check_type_and_mode.
                                        -- Check that other records only have attendance_type and attendance_mode
                                        -- specified.  If not, an order of precedence value is required.
                                        FOR v_far_6_rec IN c_far_6(
                                                                p_fee_type,
                                                                p_fee_cal_type,
                                                                p_fee_ci_sequence_number,
                                                                p_s_relation_type,
                                                                p_rate_number,
                                                                p_fee_cat) LOOP
                                                v_far_6_rec_found := TRUE;
                                        END LOOP;
                                END IF;
                        ELSE -- p_attendance_type IS NULL
                        IF(p_attendance_mode IS NOT NULL) THEN
                                -- Check_mode.
                                -- Check that other records only have attendance_mode specified.
                                -- If not, an order of precedence value is required.
                                FOR v_far_7_rec IN c_far_7(
                                                        p_fee_type,
                                                        p_fee_cal_type,
                                                        p_fee_ci_sequence_number,
                                                        p_s_relation_type,
                                                        p_rate_number,
                                                        p_fee_cat) LOOP
                                        v_far_7_rec_found := TRUE;
                                END LOOP;
                        END IF;
                        END IF;
                END IF;
                -- Now validate if order of precedence is required for cases where identical
                -- records exist, except for the charge rate values.
                FOR v_far_9_rec IN c_far_9(
                                        p_fee_type,
                                        p_fee_cal_type,
                                        p_fee_ci_sequence_number,
                                        p_s_relation_type,
                                        p_rate_number,
                                        p_fee_cat,
                                        p_location_cd,
                                        p_attendance_mode,
                                        p_attendance_type,
                                        p_govt_hecs_payment_option,
                                        p_govt_hecs_cntrbtn_band) LOOP
                        v_far_9_rec_found := TRUE;
                END LOOP;
        ELSE -- p_order_of_precedence IS NOT NULL
                -- Check_order_uniqueness.
                -- As the order_of_precedence has been specified,
                -- validate that it is unique from other order_of_precedence
                -- values for matching IGS_FI_FEE_AS_RATE records of the same FTCI/FCFL parent.
                FOR v_far_8_rec IN c_far_8(
                                        p_fee_type,
                                        p_fee_cal_type,
                                        p_fee_ci_sequence_number,
                                        p_s_relation_type,
                                        p_rate_number,
                                        p_fee_cat,
                                        p_order_of_precedence) LOOP
                        v_far_8_rec_found := TRUE;
                END LOOP;
        END IF;
        IF(v_far_1_rec_found = TRUE OR
                        v_far_2_rec_found = TRUE OR
                        v_far_3_rec_found = TRUE OR
                        v_far_4_rec_found = TRUE OR
                        v_far_5_rec_found = TRUE OR
                        v_far_6_rec_found = TRUE OR
                        v_far_7_rec_found = TRUE) THEN
                p_message_name := 'IGS_FI_ORDER_OF_PREC_SPECIFY';
                RETURN FALSE;
        END IF;
        IF (v_far_9_rec_found = TRUE) THEN
                p_message_name := 'IGS_FI_ORDEROF_PREC_SPECIFY';
                RETURN FALSE;
        END IF;
        IF(v_far_8_rec_found = TRUE) THEN
                p_message_name := 'IGS_FI_ORDER_OF_PREC_CONFLICT';
                RETURN FALSE;
        END IF;
        RETURN TRUE;
  END;
  END finp_val_far_order;
  --
  -- Ensure fee assessment rate fields can be populated.
  FUNCTION finp_val_far_defntn(
  p_fee_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_govt_hecs_payment_option IN VARCHAR2 ,
  p_govt_hecs_cntrbtn_band IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN -- finp_val_far_defntn
        -- Validate if IGS_FI_FEE_AS_RATE.location_cd, IGS_FI_FEE_AS_RATE.attendance_type,
        -- IGS_FI_FEE_AS_RATE.attendance_mode, IGS_FI_FEE_AS_RATE.govt_hecs_payment_option
        -- and IGS_FI_FEE_AS_RATE.govt_hecs_cntrbtn_band are allowed to be specified
        -- or not, depending on fee_type value.
  DECLARE
        cst_other               CONSTANT VARCHAR2(10) := 'OTHER';
        cst_tutnfee             CONSTANT VARCHAR2(10) := 'TUTNFEE';
        cst_hecs                CONSTANT VARCHAR2(10) := 'HECS';
        cst_tuition     CONSTANT VARCHAR2(10) := 'TUITION';
        CURSOR c_ft(
                        cp_fee_type             IGS_FI_FEE_AS_RATE.fee_type%TYPE) IS
                SELECT  s_fee_type
                FROM    IGS_FI_FEE_TYPE
                WHERE   fee_type = cp_fee_type;
        v_ft_rec                c_ft%ROWTYPE;
  BEGIN
        -- Set the default message number
        p_message_name := Null;
        -- Check parameters
        IF p_fee_type IS NULL OR
                        (p_location_cd IS NULL AND
                        p_attendance_type  IS NULL AND
                        p_attendance_mode IS NULL AND
                        p_govt_hecs_payment_option IS NULL AND
                        p_govt_hecs_cntrbtn_band IS NULL) THEN
                RETURN TRUE;
        END IF;
        -- Cursor handling
        OPEN c_ft (p_fee_type);
        FETCH c_ft INTO v_ft_rec;
        IF c_ft%NOTFOUND THEN
                CLOSE c_ft;
                RETURN TRUE;
        END IF;
        CLOSE c_ft;
        -- Validate the IGS_FI_FEE_TYPE to see if it is permissible for particular values to
        -- be specified.
        -- ? When IGS_FI_FEE_TYPE.s_fee_type = ?OTHER?, govt_hecs_payment_option and
        --      govt_hecs_cntrbtn_band cannot be specified.
        -- ? When IGS_FI_FEE_TYPE.s_fee_type = ?HECS?, location_cd, attendance_type and
        --      attendance_mode cannot be specified.
        -- ? When IGS_FI_FEE_TYPE.s_fee_type = ?TUITION?, govt_hecs_cntrbtn_band
        --      cannot be specified.
        IF v_ft_rec.s_fee_type in ( cst_other,cst_tutnfee) THEN
                IF p_govt_hecs_payment_option IS NOT NULL THEN
                        p_message_name := 'IGS_FI_GOVTHECS_PYMTOP_OTHER';
                        RETURN FALSE;
                ELSIF p_govt_hecs_cntrbtn_band IS NOT NULL THEN
                        p_message_name := 'IGS_FI_GOVTHECS_BAND_OTHER';
                        RETURN FALSE;
                END IF;
        ELSIF v_ft_rec.s_fee_type = cst_hecs THEN
                IF p_location_cd IS NOT NULL THEN
                        p_message_name := 'IGS_FI_LOCATION_NOTBE_HECS';
                        RETURN FALSE;
                ELSIF p_attendance_type  IS NOT NULL THEN
                        p_message_name := 'IGS_FI_ATTTYPE_FEETYPE_HECS';
                        RETURN FALSE;
                ELSIF p_attendance_mode IS NOT NULL THEN
                        p_message_name := 'IGS_FI_ATTMODE_FEETYPE_HECS';
                        RETURN FALSE;
                END IF;
        ELSIF v_ft_rec.s_fee_type = cst_tuition THEN
                IF p_govt_hecs_cntrbtn_band IS NOT NULL THEN
                        p_message_name := 'IGS_FI_GOVTHECS_BAND_OTHER';
                        RETURN FALSE;
                END IF;
        END IF;
        -- Return the default value
        RETURN TRUE;
  END;
  END finp_val_far_defntn;
  --
  -- Validate the attendance mode closed indicator.
  FUNCTION enrp_val_am_closed(
  p_attend_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        v_other_detail          VARCHAR2(255);
        v_closed_ind            CHAR;
        CURSOR c_attend_mode IS
                SELECT  closed_ind
                FROM    IGS_EN_ATD_MODE
                WHERE   attendance_mode = p_attend_mode;
  BEGIN
        -- Check if the attendance_mode is closed
        p_message_name := Null;
        OPEN c_attend_mode;
        FETCH c_attend_mode INTO v_closed_ind;
        IF (c_attend_mode%NOTFOUND) THEN
                CLOSE c_attend_mode;
                RETURN TRUE;
        END IF;
        IF (v_closed_ind = 'Y') THEN
                p_message_name := 'IGS_PS_ATTEND_MODE_CLOSED';
                CLOSE c_attend_mode;
                RETURN FALSE;
        END IF;
        -- record is not closed
        CLOSE c_attend_mode;
        RETURN TRUE;
  END;
  END enrp_val_am_closed;
  --
  -- Validate if IGS_FI_GOVT_HEC_CNTB.govt_hecs_contrbn_band is closed.
  FUNCTION finp_val_ghc_closed(
  p_govt_hecs_cntrbtn_band IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN -- finp_val_ghc_closed
        -- Validate if IGS_FI_GOVT_HEC_CNTB.govt_hecs_cntrbtn_band is closed.
  DECLARE
        CURSOR c_ghc(
                cp_govt_hecs_cntrbtn_band
                        IGS_FI_GOVT_HEC_CNTB.govt_hecs_cntrbtn_band%TYPE) IS
                SELECT  closed_ind
                FROM    IGS_FI_GOVT_HEC_CNTB
                WHERE   govt_hecs_cntrbtn_band = cp_govt_hecs_cntrbtn_band;
        v_ghc_rec                       c_ghc%ROWTYPE;
        cst_yes                 CONSTANT CHAR := 'Y';
  BEGIN
        -- Set the default message number
        p_message_name := Null;
        -- Cursor handling
        OPEN c_ghc(p_govt_hecs_cntrbtn_band);
        FETCH c_ghc INTO v_ghc_rec;
        IF c_ghc%NOTFOUND THEN
                CLOSE c_ghc;
                RETURN TRUE;
        END IF;
        CLOSE c_ghc;
        IF v_ghc_rec.closed_ind = cst_yes THEN
                p_message_name := 'IGS_FI_GOVTHECS_CONTRIB_CLS';
                RETURN FALSE;
        END IF;
        -- Return the default value
        RETURN TRUE;
  END;
  END finp_val_ghc_closed;

  --
  -- Validate the unit_class closed indicator.
/******************************************************************

Created By:         Lakshmi.Priyadharshini

Date Created By:    08-09-2000

Purpose To Calculate Fee at Unit Class level.

Known limitations,enhancements,remarks:

Change History

Who     When       What

******************************************************************/

  FUNCTION unit_class_closed(
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
        v_other_detail          VARCHAR2(255);
        v_closed_ind            CHAR;
        CURSOR c_unit_class IS
          SELECT  closed_ind
          FROM    IGS_AS_UNIT_CLASS
          WHERE   unit_class = p_unit_class;
  BEGIN
        -- Check if the unit_class is closed
        p_message_name := Null;
        OPEN c_unit_class;
        FETCH c_unit_class INTO v_closed_ind;
        IF (c_unit_class%NOTFOUND) THEN
          CLOSE c_unit_class;
          RETURN TRUE;
        END IF;
        IF (v_closed_ind = 'Y') THEN
          p_message_name := 'IGS_FI_UNIT_CLASS_CLOSED';
          CLOSE c_unit_class;
          RETURN FALSE;
        END IF;
        -- record is not closed
        CLOSE c_unit_class;
        RETURN TRUE;
  END;
  END unit_class_closed;
  --
  -- Validate if IGS_FI_GOV_HEC_PA_OP.govt_hecs_payment_opt is closed.
  FUNCTION finp_val_ghpo_closed(
  p_govt_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN -- finp_val_ghpo_closed
        -- Validate if IGS_FI_GOV_HEC_PA_OP.govt_hecs_payment_option is closed.
  DECLARE
        CURSOR c_ghpo(
                        cp_govt_hecs_payment_option
                        IGS_FI_GOV_HEC_PA_OP.govt_hecs_payment_option%TYPE) IS
                SELECT  closed_ind
                FROM    IGS_FI_GOV_HEC_PA_OP
                WHERE   govt_hecs_payment_option = cp_govt_hecs_payment_option;
        v_ghpo_rec              c_ghpo%ROWTYPE;
        cst_yes                 CONSTANT CHAR := 'Y';
  BEGIN
        -- Set the default message number
        p_message_name := Null;
        -- Cursor handling
        OPEN c_ghpo(p_govt_hecs_payment_option);
        FETCH c_ghpo INTO v_ghpo_rec;
        IF c_ghpo%NOTFOUND THEN
                CLOSE c_ghpo;
                RETURN TRUE;
        END IF;
        CLOSE c_ghpo;
        IF v_ghpo_rec.closed_ind = cst_yes THEN
                p_message_name := 'IGS_EN_GOVT_HECS_PAY_OPT_CLOS';
                RETURN FALSE;
        END IF;
        -- Return the default value
        RETURN TRUE;
  END;
  END finp_val_ghpo_closed;
  --
  -- Ensure fee assessment rate can be created.
  FUNCTION finp_val_far_ins(
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN -- finp_val_far_ins
        -- Validate IGS_FI_FEE_AS_RATE.fee_type.  If IGS_FI_FEE_TYPE.s_fee_trigger_cat = ?INSTITUTN?
        -- or IGS_FI_FEE_TYPE.s_fee_type = ?HECS?, then assessment rates can only be defined
        -- against fee_type_cal_instances.
  DECLARE
        CURSOR c_ft(
                        cp_fee_type             IGS_FI_FEE_TYPE.fee_type%TYPE) IS
                SELECT  s_fee_trigger_cat,
                        s_fee_type
                FROM    IGS_FI_FEE_TYPE
                WHERE   fee_type = cp_fee_type;
        v_ft_rec                        c_ft%ROWTYPE;
        cst_institutn                   CONSTANT VARCHAR2(10) := 'INSTITUTN';
        cst_hecs                        CONSTANT VARCHAR2(5) := 'HECS';
  BEGIN
        -- Set the default message number
        p_message_name := Null;
        -- Check parameters
        IF p_fee_type IS NULL THEN
                RETURN TRUE;
        END IF;
        -- Get the system fee trigger category of the fee_type.
        OPEN c_ft (p_fee_type);
        FETCH c_ft INTO v_ft_rec;
        IF c_ft%NOTFOUND THEN
                CLOSE c_ft;
                RETURN TRUE;
        END IF;
        CLOSE c_ft;
        IF v_ft_rec.s_fee_trigger_cat = cst_institutn THEN
                p_message_name := 'IGS_FI_ASSRATE_ND_INSTITUTN';
                RETURN FALSE;
        END IF;
        IF v_ft_rec.s_fee_type = cst_hecs THEN
                p_message_name := 'IGS_FI_ASSRATE_ND_HECS';
                RETURN FALSE;
        END IF;
        -- Return the default value
        RETURN TRUE;
  END;
  END finp_val_far_ins;
  --

  --
  -- Ensure fee ass rate relations are valid.
  FUNCTION finp_val_far_rltn(
  p_s_relation_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
        gv_other_detail         VARCHAR2(255);
  BEGIN -- finp_val_far_relation
        -- Validate IGS_FI_FEE_AS_RATE.fee_cat is only specified for the appropriate
        -- IGS_FI_FEE_AS_RATE.s_relation_type
  DECLARE
  BEGIN
        --- Set the default message number
        p_message_name := Null;
        -- Validate parameter values
        IF p_s_relation_type IS NULL THEN
                RETURN TRUE;
        ELSIF p_s_relation_type NOT IN('FTCI','FCFL') THEN
                p_message_name := 'IGS_FI_FINP_VAL_FAR_RLTN_CALL';
                RETURN FALSE;
        END IF;
        -- Validate that for relation type FTCI, fee_cat is NULL
        IF p_s_relation_type = 'FTCI' THEN
                IF p_fee_cat IS NULL THEN
                        RETURN TRUE;
                ELSE
                        p_message_name := 'IGS_FI_FEECAT_NULL_FEEASSRATE';
                        RETURN FALSE;
                END IF;
        END IF;
        -- Validate that for relation type 'FCFL', fee_cat is NOT NULL
        IF p_s_relation_type = 'FCFL' THEN
                IF p_fee_cat IS NOT NULL THEN
                        RETURN TRUE;
                ELSE
                        p_message_name := 'IGS_FI_FEECAT_SPECIFY_FEEASS';
                        RETURN FALSE;
                END IF;
        END IF;
        RETURN TRUE;
  END;
  END finp_val_far_rltn;

END IGS_FI_VAL_FAR;

/
