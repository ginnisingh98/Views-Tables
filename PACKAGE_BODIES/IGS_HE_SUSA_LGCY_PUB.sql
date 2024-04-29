--------------------------------------------------------
--  DDL for Package Body IGS_HE_SUSA_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_SUSA_LGCY_PUB" AS
/* $Header: IGSHE23B.pls 120.0 2005/06/01 22:17:57 appldev noship $ */



g_pkg_name        CONSTANT VARCHAR2(30) := 'IGS_HE_SUSA_LGCY_PUB';


FUNCTION validate_parameters(p_hesa_susa_rec   IN   hesa_susa_rec_type)
                                                    RETURN BOOLEAN AS
/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 05-11-2002
||  Purpose : To validate the input parameters
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/

    l_valid_params      BOOLEAN := TRUE;
BEGIN

    -- Mandatory parameter check
    IF p_hesa_susa_rec.person_number IS NULL THEN
        -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PER_NUM_NULL');
        FND_MSG_PUB.ADD;
        l_valid_params := FALSE;
    END IF;

    -- Mandatory parameter check
    IF p_hesa_susa_rec.program_cd IS NULL THEN
        -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_CD_NULL');
        FND_MSG_PUB.ADD;
        l_valid_params := FALSE;
    END IF;

    -- Mandatory parameter check
    IF p_hesa_susa_rec.unit_set_cd IS NULL THEN
        -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_UNIT_SET_MAND');
        FND_MSG_PUB.ADD;
        l_valid_params := FALSE;
    END IF;

  RETURN l_valid_params;

END validate_parameters;



FUNCTION validate_db_cons(p_person_id       IN   NUMBER,
                          p_sequence_number IN   NUMBER,
                          p_hesa_susa_rec   IN   hesa_susa_rec_type
                         ) RETURN VARCHAR2 AS
/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 05-11-2002
||  Purpose : Validates the database constaints ie PK, UK and FK checks
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who         When               What
||  jtmathew    21-Sep-2004        Added validation for new and existing fields
||                                 as described in HEFD350.
------------------------------------------------------------------------------*/

    l_ret_value     VARCHAR2(1) := 'S';


    -- Check if the specified fte_calc_type is a valid value in igs_lookup_values
    -- with type IGS_HE_FTE_CALC_TYPE
    CURSOR c_fte_calc_type IS
    SELECT 'X'
    FROM igs_lookup_values
    WHERE lookup_type = 'IGS_HE_FTE_CALC_TYPE'
    AND lookup_code = p_hesa_susa_rec.fte_calc_type
    AND enabled_flag='Y';
    l_dummy           VARCHAR2(1);


BEGIN

    -- Primary Key validations
    -- Check if the HESA Unit Set Attempt exist
    IF igs_he_en_susa_pkg.get_uk_for_validation (x_person_id           => p_person_id,
                                                 x_course_cd           => p_hesa_susa_rec.program_cd,
                                                 x_unit_set_cd         => p_hesa_susa_rec.unit_set_cd,
                                                 x_sequence_number     => p_sequence_number
                                                ) THEN
    -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_SUSA_DTLS_EXIST');
        FND_MSG_PUB.ADD;
      RETURN 'W';
    END IF;

    -- Foreign Key validations -----------------------------
    -- Check if the Unit Set Attempt exists
        IF NOT igs_as_su_setatmpt_pkg.get_pk_for_validation (x_person_id         => p_person_id,
                                                         x_course_cd         => p_hesa_susa_rec.program_cd,
                                                         x_unit_set_cd       => p_hesa_susa_rec.unit_set_cd,
                                                         x_sequence_number   => p_sequence_number
                                                        ) THEN
        -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_SUSA_REC_NEX');
        FND_MSG_PUB.ADD;
        l_ret_value := 'E';
    END IF;

    -- Check if the New HE Entrant exists
    IF p_hesa_susa_rec.new_he_entrant_cd IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_HEENT',
                                                             x_value        => p_hesa_susa_rec.new_he_entrant_cd
                                                            ) THEN
            -- Add excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_NEW_HE_ENTRN_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Term Time Accommodation exists
    IF p_hesa_susa_rec.term_time_accom IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_TTA',
                                                             x_value        => p_hesa_susa_rec.term_time_accom
                                                            ) THEN
            -- Add excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_TRM_ACCOMNEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Disability Allowance exists
    IF p_hesa_susa_rec.disability_allow IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_DIS_ALLOW',
                                                             x_value        => p_hesa_susa_rec.disability_allow
                                                            ) THEN
            -- Add excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_DISB_ALLW_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Additional Support Band exists
    IF p_hesa_susa_rec.additional_sup_band IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_SUP_BAND',
                                                             x_value        => p_hesa_susa_rec.additional_sup_band
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_ADD_SUP_BAND_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the SLDD discrete prov exists
    IF p_hesa_susa_rec.sldd_discrete_prov IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_ST13',
                                                             x_value        => p_hesa_susa_rec.sldd_discrete_prov
                                                            ) THEN
            -- Add excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_SLDD_DISCR_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Study Mode exists
    IF p_hesa_susa_rec.study_mode IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_MODE_TYPE',
                                                             x_value        => p_hesa_susa_rec.study_mode
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_STUDY_MODE_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Study Location exists
    IF p_hesa_susa_rec.study_location IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_LOCSDY',
                                                             x_value        => p_hesa_susa_rec.study_location
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_STUDY_LOC_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Franchising Activity exists
    IF p_hesa_susa_rec.franchising_activity IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_FRAN_ACT',
                                                             x_value        => p_hesa_susa_rec.franchising_activity
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_FRANCH_ACT_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Completion Status exists
    IF p_hesa_susa_rec.completion_status IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_CSTAT',
                                                             x_value        => p_hesa_susa_rec.completion_status
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_COMP_STATUS_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Good Standing Marker exists
    IF p_hesa_susa_rec.good_stand_marker IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_PROGRESS',
                                                             x_value        => p_hesa_susa_rec.good_stand_marker
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_GOOD_STAND_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Complete PYR Study exists
    IF p_hesa_susa_rec.complete_pyr_study_cd IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_FUNDCOMP',
                                                             x_value        => p_hesa_susa_rec.complete_pyr_study_cd
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_COMP_PYR_STUDY_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Fundability Code exists
    IF p_hesa_susa_rec.fundability_code IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_FUND_CODE',
                                                             x_value        => p_hesa_susa_rec.fundability_code
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_FUNDB_CODE_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Fee Eligibility exists
    IF p_hesa_susa_rec.fee_eligibility IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_FEEELIG',
                                                             x_value        => p_hesa_susa_rec.fee_eligibility
                                                            )  THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_FEE_ELGBL_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Fee Band exists
    IF p_hesa_susa_rec.fee_band IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_FEEBAND',
                                                             x_value        => p_hesa_susa_rec.fee_band
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_FEE_BAND_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Non Payment Reason exists
    IF p_hesa_susa_rec.non_payment_reason IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_NONPAY',
                                                             x_value        => p_hesa_susa_rec.non_payment_reason
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_NOPAY_REASON_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Student Fee exists
    IF p_hesa_susa_rec.student_fee IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_MSTUFEE',
                                                             x_value        => p_hesa_susa_rec.student_fee
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_STUD_FEE_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Type of Program Year exists
    IF p_hesa_susa_rec.type_of_year IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_TYPEYR',
                                                             x_value        => p_hesa_susa_rec.type_of_year
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_TYPE_OF_YEAR_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Eligibility for Enhanced Funding Indicator exists
    IF p_hesa_susa_rec.enh_fund_elig_cd IS NOT NULL THEN
        IF NOT igs_he_code_values_pkg.get_pk_for_validation (x_code_type    => 'OSS_ELIGENFD',
                                                             x_value        => p_hesa_susa_rec.enh_fund_elig_cd
                                                            ) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_ELIG_ENH_FUND_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Credit Level Achieved 1 exists
    IF p_hesa_susa_rec.credit_level_achieved1 IS NOT NULL THEN
        IF NOT igs_ps_unit_level_pkg.get_pk_for_validation (x_unit_level => p_hesa_susa_rec.credit_level_achieved1) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_CR_LEVEL_ACHD1_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Credit Level Achieved 2 exists
    IF p_hesa_susa_rec.credit_level_achieved2 IS NOT NULL THEN
        IF NOT igs_ps_unit_level_pkg.get_pk_for_validation (x_unit_level => p_hesa_susa_rec.credit_level_achieved2) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_CR_LEVEL_ACHD2_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Credit Level Achieved 3 exists
    IF p_hesa_susa_rec.credit_level_achieved3 IS NOT NULL THEN
        IF NOT igs_ps_unit_level_pkg.get_pk_for_validation (x_unit_level => p_hesa_susa_rec.credit_level_achieved3) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_CR_LEVEL_ACHD3_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Credit Level Achieved 4 exists
    IF p_hesa_susa_rec.credit_level_achieved4 IS NOT NULL THEN
        IF NOT igs_ps_unit_level_pkg.get_pk_for_validation (x_unit_level => p_hesa_susa_rec.credit_level_achieved4) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_CR_LEVEL_ACHD4_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Credit Level 1 exists
    IF p_hesa_susa_rec.credit_level1 IS NOT NULL THEN
        IF NOT igs_ps_unit_level_pkg.get_pk_for_validation (x_unit_level => p_hesa_susa_rec.credit_level1) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_CREDIT_LEVEL1_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Credit Level 2 exists
    IF p_hesa_susa_rec.credit_level2 IS NOT NULL THEN
        IF NOT igs_ps_unit_level_pkg.get_pk_for_validation (x_unit_level => p_hesa_susa_rec.credit_level2) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_CREDIT_LEVEL2_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Credit Level 3 exists
    IF p_hesa_susa_rec.credit_level3 IS NOT NULL THEN
        IF NOT igs_ps_unit_level_pkg.get_pk_for_validation (x_unit_level => p_hesa_susa_rec.credit_level3) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_CREDIT_LEVEL3_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Credit Level 4 exists
    IF p_hesa_susa_rec.credit_level4 IS NOT NULL THEN
        IF NOT igs_ps_unit_level_pkg.get_pk_for_validation (x_unit_level => p_hesa_susa_rec.credit_level4) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_CREDIT_LEVEL4_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- bug #3547382
    -- Check whether the Credit Value Year of Program 1 field
    -- is within range 0 to 999 (inclusive)
    IF p_hesa_susa_rec.credit_value_yop1 IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.credit_value_yop1 between 0 and 999 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_CV_YOP1_RANGE_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- bug #3547382
    -- Check whether the Credit Value Year of Program 2 field
    -- is within range 0 to 999 (inclusive)
    IF p_hesa_susa_rec.credit_value_yop2 IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.credit_value_yop2 between 0 and 999 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_CV_YOP2_RANGE_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- Check whether the Credit Value Year of Program 3 field
    -- is within range 0 to 999 (inclusive)
    IF p_hesa_susa_rec.credit_value_yop3 IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.credit_value_yop3 between 0 and 999 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_CV_YOP3_RANGE_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- Check whether the Credit Value Year of Program 4 field
    -- is within range 0 to 999 (inclusive)
    IF p_hesa_susa_rec.credit_value_yop4 IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.credit_value_yop4 between 0 and 999 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_CV_YOP4_RANGE_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- Check whether the Year Of Student field is within range 0 to 39 (inclusive)
    IF p_hesa_susa_rec.year_stu IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.year_stu between 0 and 39 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_YEAR_STU_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- bug #3547394
    -- Check whether the Number of Credit Points obtained 1 field
    -- is within range 0 to 999 (inclusive)
    IF p_hesa_susa_rec.credit_pt_achieved1 IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.credit_pt_achieved1 between 0 and 999 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_CP_ACH1_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- bug #3547394
    -- Check whether the Number of Credit Points obtained 2 field
    -- is within range 0 to 999 (inclusive)
    IF p_hesa_susa_rec.credit_pt_achieved2 IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.credit_pt_achieved2 between 0 and 999 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_CP_ACH2_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- Check whether the Number of Credit Points obtained 3 field
    -- is within range 0 to 999 (inclusive)
    IF p_hesa_susa_rec.credit_pt_achieved3 IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.credit_pt_achieved3 between 0 and 999 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_CP_ACH3_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- Check whether the Number of Credit Points obtained 4 field
    -- is within range 0 to 999 (inclusive)
    IF p_hesa_susa_rec.credit_pt_achieved4 IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.credit_pt_achieved4 between 0 and 999 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_CP_ACH4_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- bug #3547402
    -- Check whether the Proportion not taught by institution field
    -- is within the range 0 to 100 (inclusive)
    IF p_hesa_susa_rec.pro_not_taught IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.pro_not_taught between 0 and 100 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_PRO_NOT_TAUGHT_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- bug #3547402
    -- Check whether the FTE Intensity field is within range 0 to 300 (inclusive)
    IF p_hesa_susa_rec.fte_intensity IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.fte_intensity between 0 and 300 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_FTE_INTENSITY_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- bug #3547416
    -- Check whether the FTE Calculation type is a valid value from IGS Lookups with type
    -- IGS_HE_FTE_CALC_TYPE
    IF p_hesa_susa_rec.fte_calc_type IS NOT NULL THEN
       OPEN c_fte_calc_type;
       FETCH c_fte_calc_type INTO l_dummy;
       IF c_fte_calc_type%NOTFOUND THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_FTE_CTYPE_RANGE_NEX');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
       CLOSE c_fte_calc_type;
    END IF;

    -- bug #3547420
    -- Check whether the FTE Intensity field is within range 0 to 300 (inclusive)
    IF p_hesa_susa_rec.fte_perc_override IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.fte_perc_override between 0 and 300 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_FTE_PERC_OVR_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- Check whether the Additional Support Cost field is within range 0 to 999999 (inclusive)
    IF p_hesa_susa_rec.additional_sup_cost IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.additional_sup_cost between 0 and 999999 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_ADD_SUPP_COST_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- Check whether the Disadvantage Uplift Factor field is within
    -- range 0.0000 to 9.9999 (inclusive)
    IF p_hesa_susa_rec.disadv_uplift_factor IS NOT NULL THEN
       IF NOT p_hesa_susa_rec.disadv_uplift_factor between 0.0000 and 9.9999 THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_HE_DIS_UPLIFT_FTR_INVALID');
             FND_MSG_PUB.ADD;
             l_ret_value := 'E';
       END IF;
    END IF;

    -- Check if the Grading Schema Grade exists
    IF p_hesa_susa_rec.grad_sch_grade IS NOT NULL THEN
        IF NOT igs_en_hesa_pkg.check_grading_sch_grade (p_person_id        => p_person_id,
                                                        p_program_cd       => p_hesa_susa_rec.program_cd,
                                                        p_unit_set_cd      => p_hesa_susa_rec.unit_set_cd,
                                                        p_grad_sch_grade   => p_hesa_susa_rec.grad_sch_grade) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_GRD_SCH_GRADE_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Teaching Institution 1 exists
    IF p_hesa_susa_rec.teaching_inst1 IS NOT NULL THEN
        IF NOT igs_en_hesa_pkg.check_teach_inst (p_teaching_inst => p_hesa_susa_rec.teaching_inst1) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_TCH_INST1_POSTSEC_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    -- Check if the Teaching Institution 2 exists
    IF p_hesa_susa_rec.teaching_inst2 IS NOT NULL THEN
        IF NOT igs_en_hesa_pkg.check_teach_inst (p_teaching_inst => p_hesa_susa_rec.teaching_inst2) THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_TCH_INST2_POSTSEC_NEX');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;

    RETURN l_ret_value;

END validate_db_cons;



FUNCTION validate_hesa_susa (p_us_version_number    IN   NUMBER,
                             p_hesa_susa_rec        IN   hesa_susa_rec_type
                             ) RETURN BOOLEAN AS
l_br_val_failed BOOLEAN := FALSE;
/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 05-11-2002
||  Purpose : Perform business validations for the HESA Student Unit Set Attempt
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
BEGIN

    -- Validating whether the unit set category is of type Pre-enrollment
    IF 'PRENRL_YR' <> igs_en_hesa_pkg.get_unit_set_cat (p_unit_set_cd          => p_hesa_susa_rec.unit_set_cd,
                                                        p_us_version_number    => p_us_version_number) THEN
        -- ADD excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_HE_SUSA_PRE_YEAR_US');
        FND_MSG_PUB.ADD;
      l_br_val_failed := TRUE;
    END IF;

   -- Check whether any validation failed, if yes then return FALSE otherwise return TRUE
   IF l_br_val_failed THEN
     RETURN FALSE;
   ELSE
     RETURN TRUE;
   END IF;

END validate_hesa_susa;


PROCEDURE create_hesa_susa (p_api_version           IN   NUMBER,
                            p_init_msg_list         IN   VARCHAR2,
                            p_commit                IN   VARCHAR2,
                            p_validation_level      IN   NUMBER,
                            p_hesa_susa_rec         IN   hesa_susa_rec_type,
                            x_return_status         OUT  NOCOPY VARCHAR2,
                            x_msg_count             OUT  NOCOPY NUMBER,
                            x_msg_data              OUT  NOCOPY VARCHAR2) AS

/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 05-11-2002
||  Purpose : To create a HESA Student Unit Set Attempt
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  jtmathew    21-Sep-2004      Modified INSERT statement to accommodate the new
||                               fields described in HEFD350.
------------------------------------------------------------------------------*/

    l_api_name              CONSTANT    VARCHAR2(30) := 'create_hesa_susa';
    l_api_version           CONSTANT    NUMBER       := 1.0;

    l_insert_flag           BOOLEAN := TRUE;
    l_ret_val               VARCHAR2(1) := NULL;

    l_person_id             igs_he_en_susa.person_id%TYPE;
    l_sequence_number       igs_he_en_susa.sequence_number%TYPE;
    l_us_version_number     igs_he_en_susa.us_version_number%TYPE;
    l_hesa_en_susa_id       igs_he_en_susa.hesa_en_susa_id%TYPE;

    l_creation_date         igs_he_en_susa.creation_date%TYPE;
    l_last_update_date      igs_he_en_susa.last_update_date%TYPE;
    l_created_by            igs_he_en_susa.created_by%TYPE;
    l_last_updated_by       igs_he_en_susa.last_updated_by%TYPE;
    l_last_update_login     igs_he_en_susa.last_update_login%TYPE;

BEGIN

    -- Create a savepoint
    SAVEPOINT    create_hesa_susa_pub;

    -- Check for the Compatible API call
    IF NOT FND_API.COMPATIBLE_API_CALL(  l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         g_pkg_name) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If the calling program has passed the parameter for initializing the message list
    IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
    END IF;

    -- Set the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Check whether the country profile value is GB
    IF NVL(FND_PROFILE.VALUE('OSS_COUNTRY_CODE'),'NONE') <> 'GB' THEN
        FND_MESSAGE.SET_NAME ('IGS','IGS_UC_HE_NOT_ENABLED');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_insert_flag := FALSE;
    END IF;


    -- // Validate input paramaters ---------
    IF l_insert_flag THEN
        IF NOT validate_parameters(p_hesa_susa_rec) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_insert_flag := FALSE;
        END IF;
    END IF;


    -- Derivations ----------------------------------

    -- Person ID
    IF l_insert_flag THEN
        l_person_id := igs_ge_gen_003.get_person_id (p_person_number => p_hesa_susa_rec.person_number);

        IF l_person_id IS NULL THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_PERSON_NUMBER');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_insert_flag := FALSE;
        END IF;
    END IF;

    -- Sequence number and unit set version number
    IF l_insert_flag THEN
        igs_ge_gen_003.get_susa_sequence_num (p_person_id         => l_person_id,
                                              p_program_cd        => p_hesa_susa_rec.program_cd,
                                              p_unit_set_cd       => p_hesa_susa_rec.unit_set_cd,
                                              p_us_version_number => l_us_version_number,
                                              p_sequence_number   => l_sequence_number);

        IF l_us_version_number IS NULL OR l_sequence_number IS NULL THEN
            -- ADD excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_HE_SUSA_REC_NEX');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_insert_flag := FALSE;
        END IF;
    END IF;


    -- Validate database constraints
    IF l_insert_flag THEN
        l_ret_val := validate_db_cons(p_person_id       => l_person_id,
                                      p_sequence_number => l_sequence_number,
                                      p_hesa_susa_rec   => p_hesa_susa_rec);

        IF l_ret_val = 'E' THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_insert_flag := FALSE;
        ELSIF l_ret_val = 'W' THEN
            x_return_status := 'W';
            l_insert_flag := FALSE;
        END IF;
    END IF;


    -- Business validation
    IF l_insert_flag THEN
        IF NOT validate_hesa_susa (p_us_version_number  => l_us_version_number,
                                   p_hesa_susa_rec      => p_hesa_susa_rec) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_insert_flag := FALSE;
        END IF;
    END IF;



    -- Perform direct insert on IGS_HE_EN_SUSA
    IF l_insert_flag THEN

        l_creation_date := SYSDATE;
        l_created_by := FND_GLOBAL.USER_ID;

        l_last_update_date := SYSDATE;
        l_last_updated_by := FND_GLOBAL.USER_ID;
        l_last_update_login :=FND_GLOBAL.LOGIN_ID;

        IF l_created_by IS NULL THEN
            l_created_by := -1;
        END IF;

        IF l_last_updated_by IS NULL THEN
            l_last_updated_by := -1;
        END IF;

        IF l_last_update_login IS NULL THEN
            l_last_update_login := -1;
        END IF;

        -- Derive HESA_EN_SUSA_ID from sequence
        SELECT    igs_he_en_susa_s.NEXTVAL
        INTO      l_hesa_en_susa_id
        FROM      dual;


            INSERT INTO igs_he_en_susa (
            hesa_en_susa_id,
            person_id,
            course_cd,
            unit_set_cd,
            us_version_number,
            sequence_number,
            new_he_entrant_cd,
            term_time_accom,
            disability_allow,
            additional_sup_band,
            sldd_discrete_prov,
            study_mode,
            study_location,
            fte_perc_override,
            franchising_activity,
            completion_status,
            good_stand_marker,
            complete_pyr_study_cd,
            credit_value_yop1,
            credit_value_yop2,
            credit_value_yop3,
            credit_value_yop4,
            credit_level_achieved1,
            credit_level_achieved2,
            credit_level_achieved3,
            credit_level_achieved4,
            credit_pt_achieved1,
            credit_pt_achieved2,
            credit_pt_achieved3,
            credit_pt_achieved4,
            credit_level1,
            credit_level2,
            credit_level3,
            credit_level4,
            grad_sch_grade,
            mark,
            teaching_inst1,
            teaching_inst2,
            pro_not_taught,
            fundability_code,
            fee_eligibility,
            fee_band,
            non_payment_reason,
            student_fee,
            fte_intensity,
            calculated_fte,
            fte_calc_type,
            type_of_year,
            year_stu,
            enh_fund_elig_cd,
            additional_sup_cost,
            disadv_uplift_factor,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login)
            VALUES (
            l_hesa_en_susa_id,
            l_person_id,
            p_hesa_susa_rec.program_cd,
            p_hesa_susa_rec.unit_set_cd,
            l_us_version_number,
            l_sequence_number,
            p_hesa_susa_rec.new_he_entrant_cd,
            p_hesa_susa_rec.term_time_accom,
            p_hesa_susa_rec.disability_allow,
            p_hesa_susa_rec.additional_sup_band,
            p_hesa_susa_rec.sldd_discrete_prov,
            p_hesa_susa_rec.study_mode,
            p_hesa_susa_rec.study_location,
            p_hesa_susa_rec.fte_perc_override,
            p_hesa_susa_rec.franchising_activity,
            p_hesa_susa_rec.completion_status,
            p_hesa_susa_rec.good_stand_marker,
            p_hesa_susa_rec.complete_pyr_study_cd,
            p_hesa_susa_rec.credit_value_yop1,
            p_hesa_susa_rec.credit_value_yop2,
            p_hesa_susa_rec.credit_value_yop3,
            p_hesa_susa_rec.credit_value_yop4,
            p_hesa_susa_rec.credit_level_achieved1,
            p_hesa_susa_rec.credit_level_achieved2,
            p_hesa_susa_rec.credit_level_achieved3,
            p_hesa_susa_rec.credit_level_achieved4,
            p_hesa_susa_rec.credit_pt_achieved1,
            p_hesa_susa_rec.credit_pt_achieved2,
            p_hesa_susa_rec.credit_pt_achieved3,
            p_hesa_susa_rec.credit_pt_achieved4,
            p_hesa_susa_rec.credit_level1,
            p_hesa_susa_rec.credit_level2,
            p_hesa_susa_rec.credit_level3,
            p_hesa_susa_rec.credit_level4,
            p_hesa_susa_rec.grad_sch_grade,
            p_hesa_susa_rec.mark,
            p_hesa_susa_rec.teaching_inst1,
            p_hesa_susa_rec.teaching_inst2,
            p_hesa_susa_rec.pro_not_taught,
            p_hesa_susa_rec.fundability_code,
            p_hesa_susa_rec.fee_eligibility,
            p_hesa_susa_rec.fee_band,
            p_hesa_susa_rec.non_payment_reason,
            p_hesa_susa_rec.student_fee,
            p_hesa_susa_rec.fte_intensity,
            p_hesa_susa_rec.calculated_fte,
            p_hesa_susa_rec.fte_calc_type,
            p_hesa_susa_rec.type_of_year,
            p_hesa_susa_rec.year_stu,
            p_hesa_susa_rec.enh_fund_elig_cd,
            p_hesa_susa_rec.additional_sup_cost,
            p_hesa_susa_rec.disadv_uplift_factor,
            l_creation_date,
            l_created_by,
            l_last_update_date,
            l_last_updated_by,
            l_last_update_login);

    ELSE
        ROLLBACK TO create_hesa_susa_pub;
    END IF;



    -- If the calling program has passed the parameter for committing the data and there
    -- have been no errors in calling the balances process, then commit the work
    IF ( (FND_API.TO_BOOLEAN(p_commit)) AND (l_insert_flag) ) THEN
      COMMIT WORK;
    END IF;


    FND_MSG_PUB.COUNT_AND_GET( p_count   => x_msg_count,
                               p_data    => x_msg_data);


    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO create_hesa_susa_pub;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO create_hesa_susa_pub;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO create_hesa_susa_pub;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,
                                    l_api_name);
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);


END create_hesa_susa;



END igs_he_susa_lgcy_pub;

/
