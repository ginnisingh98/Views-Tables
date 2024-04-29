--------------------------------------------------------
--  DDL for Package Body IGS_EN_SUSA_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SUSA_LGCY_PUB" AS
/* $Header: IGSENA3B.pls 120.2 2005/10/28 04:18:18 appldev ship $ */



g_pkg_name        CONSTANT VARCHAR2(30) := 'IGS_EN_SUSA_LGCY_PUB';


FUNCTION validate_parameters(p_susa_rec   IN   susa_rec_type)
                             RETURN BOOLEAN AS
/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 11-Nov-2002
||  Purpose : To validate the input parameters
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/

    l_desc_flex_name    CONSTANT VARCHAR2(30) := 'IGS_AS_SU_SETATMPT_FLEX';
    l_valid_params      BOOLEAN := TRUE;
    l_msg_count         NUMBER;
BEGIN

    IF p_susa_rec.person_number IS NULL THEN
        -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PER_NUM_NULL');
        FND_MSG_PUB.ADD;
        l_valid_params := FALSE;
    END IF;

    -- Program code
    IF p_susa_rec.program_cd IS NULL THEN
        -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_CD_NULL');
        FND_MSG_PUB.ADD;
        l_valid_params := FALSE;
    ELSE
        BEGIN
            igs_as_su_setatmpt_pkg.check_constraints (column_name    => 'COURSE_CD',
                                                      column_value   => p_susa_rec.program_cd);
        EXCEPTION
            WHEN OTHERS THEN
                -- Pop and set excep
                l_msg_count := FND_MSG_PUB.COUNT_MSG;
                FND_MSG_PUB.DELETE_MSG (l_msg_count);
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_CD_UCASE');
                FND_MSG_PUB.ADD;
                l_valid_params := FALSE;
        END;
    END IF;

    -- Unit Set code
    IF p_susa_rec.unit_set_cd IS NULL THEN
        -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_UNIT_SET_CD_NULL');
        FND_MSG_PUB.ADD;
        l_valid_params := FALSE;
    ELSE
        BEGIN
            igs_as_su_setatmpt_pkg.check_constraints (column_name    => 'UNIT_SET_CD',
                                                      column_value   => p_susa_rec.unit_set_cd);
        EXCEPTION
            WHEN OTHERS THEN
                -- Pop and set excep
                l_msg_count := FND_MSG_PUB.COUNT_MSG;
                FND_MSG_PUB.DELETE_MSG (l_msg_count);
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_UNIT_SET_CD_UCASE');
                FND_MSG_PUB.ADD;
                l_valid_params := FALSE;
        END;
    END IF;

    -- Unit Set version number
    IF p_susa_rec.us_version_number IS NULL THEN
        -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_US_VER_NUM_NULL');
        FND_MSG_PUB.ADD;
        l_valid_params := FALSE;
    END IF;

    -- Student confirmed ind
    IF p_susa_rec.student_confirmed_ind IS NOT NULL THEN
        BEGIN
            igs_as_su_setatmpt_pkg.check_constraints (column_name    => 'STUDENT_CONFIRMED_IND',
                                                      column_value   => p_susa_rec.student_confirmed_ind);
        EXCEPTION
            WHEN OTHERS THEN
                -- Pop and set excep
                l_msg_count := FND_MSG_PUB.COUNT_MSG;
                FND_MSG_PUB.DELETE_MSG (l_msg_count);
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_STU_CF_IND_INVALID');
                FND_MSG_PUB.ADD;
                l_valid_params := FALSE;
        END;
    END IF;


    -- Parent Unit set code
    IF p_susa_rec.parent_unit_set_cd IS NOT NULL THEN
        BEGIN
            igs_as_su_setatmpt_pkg.check_constraints (column_name    => 'PARENT_UNIT_SET_CD',
                                                      column_value   => p_susa_rec.parent_unit_set_cd);
        EXCEPTION
            WHEN OTHERS THEN
                -- Pop and set excep
                l_msg_count := FND_MSG_PUB.COUNT_MSG;
                FND_MSG_PUB.DELETE_MSG (l_msg_count);
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PARNT_US_CD_UCASE');
                FND_MSG_PUB.ADD;
                l_valid_params := FALSE;
        END;
    END IF;


    -- Primary set ind
    IF p_susa_rec.primary_set_ind IS NOT NULL THEN
        BEGIN
            igs_as_su_setatmpt_pkg.check_constraints (column_name    => 'PRIMARY_SET_IND',
                                                      column_value   => p_susa_rec.primary_set_ind);
        EXCEPTION
            WHEN OTHERS THEN
                -- Pop and set excep
                l_msg_count := FND_MSG_PUB.COUNT_MSG;
                FND_MSG_PUB.DELETE_MSG (l_msg_count);
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRIM_IND_INVALID');
                FND_MSG_PUB.ADD;
                l_valid_params := FALSE;
        END;
    END IF;


    -- Voluntary end ind
    IF p_susa_rec.voluntary_end_ind IS NOT NULL THEN
        BEGIN
            igs_as_su_setatmpt_pkg.check_constraints (column_name    => 'VOLUNTARY_END_IND',
                                                      column_value   => p_susa_rec.voluntary_end_ind);
        EXCEPTION
            WHEN OTHERS THEN
                -- Pop and set excep
                l_msg_count := FND_MSG_PUB.COUNT_MSG;
                FND_MSG_PUB.DELETE_MSG (l_msg_count);
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_VL_END_IND_INVALID');
                FND_MSG_PUB.ADD;
                l_valid_params := FALSE;
        END;
    END IF;


    -- Override title
    IF p_susa_rec.override_title IS NOT NULL THEN
        BEGIN
            igs_as_su_setatmpt_pkg.check_constraints (column_name    => 'OVERRIDE_TITLE',
                                                      column_value   => p_susa_rec.override_title);
        EXCEPTION
            WHEN OTHERS THEN
                -- Pop and set excep
                l_msg_count := FND_MSG_PUB.COUNT_MSG;
                FND_MSG_PUB.DELETE_MSG (l_msg_count);
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_OVRIDE_TITLE_UCASE');
                FND_MSG_PUB.ADD;
                l_valid_params := FALSE;
        END;
    END IF;


    -- Requirements complete ind
    IF p_susa_rec.rqrmnts_complete_ind IS NOT NULL THEN
        BEGIN
            igs_as_su_setatmpt_pkg.check_constraints (column_name    => 'RQRMNTS_COMPLETE_IND',
                                                      column_value   => p_susa_rec.rqrmnts_complete_ind);
        EXCEPTION
            WHEN OTHERS THEN
                -- Pop and set excep
                l_msg_count := FND_MSG_PUB.COUNT_MSG;
                FND_MSG_PUB.DELETE_MSG (l_msg_count);
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_RQRMT_COMP_INVALID');
                FND_MSG_PUB.ADD;
                l_valid_params := FALSE;
        END;
    END IF;


     -- S Completed source type
    IF p_susa_rec.s_completed_source_type IS NOT NULL THEN
        BEGIN
            igs_as_su_setatmpt_pkg.check_constraints (column_name    => 'S_COMPLETED_SOURCE_TYPE',
                                                      column_value   => p_susa_rec.s_completed_source_type);
        EXCEPTION
            WHEN OTHERS THEN
                -- Pop and set excep
                l_msg_count := FND_MSG_PUB.COUNT_MSG;
                FND_MSG_PUB.DELETE_MSG (l_msg_count);
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_SCP_SRCTYP_INVALID');
                FND_MSG_PUB.ADD;
                l_valid_params := FALSE;
        END;
    END IF;


    -- Validate DFF columns
    --
    -- If any of the Descriptive Flex field columns have value , validate them .
    IF (p_susa_rec.attribute_category IS NOT NULL OR p_susa_rec.attribute1  IS NOT NULL OR p_susa_rec.attribute2  IS NOT NULL OR
        p_susa_rec.attribute3  IS NOT NULL OR p_susa_rec.attribute4  IS NOT NULL OR p_susa_rec.attribute5  IS NOT NULL OR
        p_susa_rec.attribute6  IS NOT NULL OR p_susa_rec.attribute7  IS NOT NULL OR p_susa_rec.attribute8  IS NOT NULL OR
        p_susa_rec.attribute9  IS NOT NULL OR p_susa_rec.attribute10 IS NOT NULL OR p_susa_rec.attribute11 IS NOT NULL OR
        p_susa_rec.attribute12 IS NOT NULL OR p_susa_rec.attribute13 IS NOT NULL OR p_susa_rec.attribute14 IS NOT NULL OR
        p_susa_rec.attribute15 IS NOT NULL OR p_susa_rec.attribute16 IS NOT NULL OR p_susa_rec.attribute17 IS NOT NULL OR
        p_susa_rec.attribute18 IS NOT NULL OR p_susa_rec.attribute19 IS NOT NULL OR p_susa_rec.attribute20 IS NOT NULL ) THEN

        IF NOT igs_ad_imp_018.validate_desc_flex (p_attribute_category  =>  p_susa_rec.attribute_category,
                                                  p_attribute1          =>  p_susa_rec.attribute1,
                                                  p_attribute2          =>  p_susa_rec.attribute2,
                                                  p_attribute3          =>  p_susa_rec.attribute3,
                                                  p_attribute4          =>  p_susa_rec.attribute4,
                                                  p_attribute5          =>  p_susa_rec.attribute5,
                                                  p_attribute6          =>  p_susa_rec.attribute6,
                                                  p_attribute7          =>  p_susa_rec.attribute7,
                                                  p_attribute8          =>  p_susa_rec.attribute8,
                                                  p_attribute9          =>  p_susa_rec.attribute9,
                                                  p_attribute10         =>  p_susa_rec.attribute10,
                                                  p_attribute11         =>  p_susa_rec.attribute11,
                                                  p_attribute12         =>  p_susa_rec.attribute12,
                                                  p_attribute13         =>  p_susa_rec.attribute13,
                                                  p_attribute14         =>  p_susa_rec.attribute14,
                                                  p_attribute15         =>  p_susa_rec.attribute15,
                                                  p_attribute16         =>  p_susa_rec.attribute16,
                                                  p_attribute17         =>  p_susa_rec.attribute17,
                                                  p_attribute18         =>  p_susa_rec.attribute18,
                                                  p_attribute19         =>  p_susa_rec.attribute19,
                                                  p_attribute20         =>  p_susa_rec.attribute20,
                                                  p_desc_flex_name      =>  l_desc_flex_name ) THEN
            -- Add excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_AD_INVALID_DESC_FLEX');
            FND_MSG_PUB.ADD;
            l_valid_params := FALSE;
        END IF;
    END IF;


  RETURN l_valid_params;

END validate_parameters;



FUNCTION validate_db_cons(p_person_id           IN   igs_as_su_setatmpt.person_id%TYPE,
                          p_parent_seq_number   IN   igs_as_su_setatmpt.parent_sequence_number%TYPE,
                          p_susa_rec            IN   susa_rec_type
                         ) RETURN VARCHAR2 AS
/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 11-Nov-2002
||  Purpose : Validates the database constaints ie PK, UK and FK checks
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/

    l_ret_value     VARCHAR2(1) := 'S';
BEGIN

    -- Check for duplicate student unit set attempt
    IF igs_en_gen_legacy.check_dup_susa (p_person_id		    => p_person_id,
                                         p_program_cd	        => p_susa_rec.program_cd,
                                         p_unit_set_cd          => p_susa_rec.unit_set_cd,
                                         p_us_version_number    => p_susa_rec.us_version_number,
                                         p_selection_dt	        => p_susa_rec.selection_dt) THEN
        -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_STU_USA_EXIST');
        FND_MSG_PUB.ADD;
       RETURN 'W';
    END IF;


    -- Program Attempt existence
    IF NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation(x_person_id => p_person_id,
                                                         x_course_cd => p_susa_rec.program_cd
                                                        ) THEN
        -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_ATT_NOT_EXIST');
        FND_MSG_PUB.ADD;
        l_ret_value := 'E';
    END IF;


    -- Parent Unit Set Attempt existence
    IF p_susa_rec.parent_unit_set_cd IS NOT NULL THEN
        IF NOT igs_as_su_setatmpt_pkg.get_pk_for_validation (x_person_id        => p_person_id,
                                                             x_course_cd        => p_susa_rec.program_cd,
                                                             x_unit_set_cd      => p_susa_rec.parent_unit_set_cd,
                                                             x_sequence_number  => p_parent_seq_number
                                                            ) THEN
            -- Add excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_EN_NO_PAR_UNIT_SET_CD');
            FND_MSG_PUB.ADD;
            l_ret_value := 'E';
        END IF;
    END IF;


    -- Unit Set existence
    IF NOT igs_en_unit_set_pkg.get_pk_for_validation (x_unit_set_cd    => p_susa_rec.unit_set_cd,
                                                      x_version_number => p_susa_rec.us_version_number
                                                     ) THEN
        -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_UNIT_SET_NOT_EXIST');
        FND_MSG_PUB.ADD;
        l_ret_value := 'E';
    END IF;

   RETURN l_ret_value;

END validate_db_cons;



FUNCTION validate_unit_set_atmpt (p_person_id           IN   igs_as_su_setatmpt.person_id%TYPE,
                                  p_sequence_number     IN   igs_as_su_setatmpt.sequence_number%TYPE,
                                  p_parent_seq_number   IN   igs_as_su_setatmpt.parent_sequence_number%TYPE,
                                  p_auth_person_id      IN   igs_as_su_setatmpt.authorised_person_id%TYPE,
                                  p_susa_rec            IN   susa_rec_type
                                 ) RETURN BOOLEAN AS
/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 05-11-2002
||  Purpose : Perform business validations for the EN Student Unit Set Attempt
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  bdeviset       29-JUL-2004      Added parameters p_end_dt,p_sequence_number
||                                  for call to Function igs_en_gen_legacy.check_usa_overlap
||                                  as it is modified for bug 3149133
------------------------------------------------------------------------------*/

    l_validation_success    BOOLEAN     := TRUE;
    l_ret_val               BOOLEAN;
    l_message_name          VARCHAR2(2000) := NULL;
    l_legacy                CONSTANT    VARCHAR2(1) := 'Y';
BEGIN

    -- 1. Check whether Unit set is offered within the students program offering option
    -- 2. Check whether a unit set attempt is being created against a unit set, which has
    -- already been completed by the student in the same program.
    l_ret_val := igs_en_val_susa.enrp_val_susa_ins (p_person_id         => p_person_id,
                                                    p_course_cd         => p_susa_rec.program_cd,
                                                    p_unit_set_cd       => p_susa_rec.unit_set_cd,
                                                    p_sequence_number   => p_sequence_number,
                                                    p_us_version_number => p_susa_rec.us_version_number,
                                                    p_message_name      => l_message_name,
                                                    p_legacy            => l_legacy);
    IF l_message_name IS NOT NULL THEN
        l_validation_success := FALSE;
        l_message_name := NULL;
    END IF;


    -- 1. Check if the authorized date is set, then the authorized person must also be set (and visa versa).
    -- 2. The authorized date/person can only be set if the unit set is being ended, or if the
    -- unit set version is flagged as requiring authorization to enroll.
    l_ret_val := igs_en_val_susa.enrp_val_susa_auth (p_unit_set_cd          => p_susa_rec.unit_set_cd,
                                                     p_us_version_number    => p_susa_rec.us_version_number,
                                                     p_end_dt               => p_susa_rec.end_dt,
                                                     p_authorised_person_id => p_auth_person_id,
                                                     p_authorised_on        => p_susa_rec.authorised_on,
                                                     p_message_name         => l_message_name,
                                                     p_legacy               => l_legacy);

    IF l_message_name IS NOT NULL THEN
        l_validation_success := FALSE;
        l_message_name := NULL;
    END IF;


    -- Check that when unit set requires authorisation then the authorised fields must be set
    IF NOT igs_en_val_susa.enrp_val_susa_us_ath (p_unit_set_cd          => p_susa_rec.unit_set_cd,
                                                 p_version_number       => p_susa_rec.us_version_number,
                                                 p_authorised_person_id => p_auth_person_id,
                                                 p_authorised_on        => p_susa_rec.authorised_on,
                                                 p_message_name         => l_message_name) THEN

        FND_MESSAGE.SET_NAME('IGS',l_message_name);
        FND_MSG_PUB.ADD;
        l_validation_success := FALSE;
        l_message_name := NULL;
    END IF;


    -- 1. If requirements complete date is set then complete flag must also be set and vice-versa.
    -- 2. The completion flag/date can only be set if the unit set attempt has been confirmed
    l_ret_val := igs_en_val_susa.enrp_val_susa_cmplt (p_rqrmnts_complete_dt   => p_susa_rec.rqrmnts_complete_dt,
                                                      p_rqrmnts_complete_ind  => NVL(p_susa_rec.rqrmnts_complete_ind,'N'),
                                                      p_student_confirmed_ind => p_susa_rec.student_confirmed_ind,
                                                      p_message_name          => l_message_name,
                                                      p_legacy                => l_legacy);

    IF l_message_name IS NOT NULL THEN
        l_validation_success := FALSE;
        l_message_name := NULL;
    END IF;


    -- Check that completed source type can only be set if completion date and indicator are set
    IF NOT igs_en_val_susa.enrp_val_susa_scst (p_rqrmnts_complete_dt      => p_susa_rec.rqrmnts_complete_dt,
                                               p_rqrmnts_complete_ind     => NVL(p_susa_rec.rqrmnts_complete_ind,'N'),
                                               p_s_completed_source_type  => p_susa_rec.s_completed_source_type,
                                               p_message_name             => l_message_name) THEN

        FND_MESSAGE.SET_NAME('IGS',l_message_name);
        FND_MSG_PUB.ADD;
        l_validation_success := FALSE;
        l_message_name := NULL;
    END IF;


    -- Check whether the selection date is set if the student confirmed indicator is set and visa versa
    l_ret_val := igs_en_val_susa.enrp_val_susa_sci_sd (p_student_confirmed_ind => NVL(p_susa_rec.student_confirmed_ind,'N'),
                                                       p_selection_dt          => p_susa_rec.selection_dt,
                                                       p_message_name          => l_message_name,
                                                       p_legacy                => l_legacy);

    IF l_message_name IS NOT NULL THEN
        l_validation_success := FALSE;
        l_message_name := NULL;
    END IF;


    -- Check that voluntary end indicator can only be set when end date is set
    IF NOT igs_en_val_susa.enrp_val_susa_end_vi (p_voluntary_end_ind => p_susa_rec.voluntary_end_ind,
                                                 p_end_dt            => p_susa_rec.end_dt,
                                                 p_message_name      => l_message_name) THEN

        FND_MESSAGE.SET_NAME('IGS',l_message_name);
        FND_MSG_PUB.ADD;
        l_validation_success := FALSE;
        l_message_name := NULL;
    END IF;


    IF p_susa_rec.parent_unit_set_cd IS NOT NULL THEN

        -- 1. If the unit set is specified as a subordinate within the unit set relationships, then it must be a child attempt.
        -- 2. If the attempt is a child attempt, then the parent set must be valid within the unit set relationships setup
        l_ret_val := igs_en_val_susa.enrp_val_susa_cousr (p_person_id              => p_person_id,
                                                          p_course_cd              => p_susa_rec.program_cd,
                                                          p_unit_set_cd            => p_susa_rec.unit_set_cd,
                                                          p_us_version_number      => p_susa_rec.us_version_number,
                                                          p_parent_unit_set_cd     => p_susa_rec.parent_unit_set_cd,
                                                          p_parent_sequence_number => p_parent_seq_number,
                                                          p_message_type           => 'E',
                                                          p_message_name           => l_message_name,
                                                          p_legacy                 => l_legacy);
        IF l_message_name IS NOT NULL THEN
            l_validation_success := FALSE;
            l_message_name := NULL;
        END IF;
    END IF;


    IF p_susa_rec.parent_unit_set_cd IS NOT NULL THEN

        -- 1. If the unit set attempt is a direct parent of itself.
        -- 2. Whether the unit set attempt is an indirect parent of itself.
        -- 3. The Parent must be within the same program attempt, and must not be ended.
        -- 4. Cannot have a confirmed parent if the attempt is not also confirmed
        l_ret_val := igs_en_val_susa.enrp_val_susa_parent (p_person_id              => p_person_id,
                                                           p_course_cd              => p_susa_rec.program_cd,
                                                           p_unit_set_cd            => p_susa_rec.unit_set_cd,
                                                           p_sequence_number        => p_sequence_number,
                                                           p_parent_unit_set_cd     => p_susa_rec.parent_unit_set_cd,
                                                           p_parent_sequence_number => p_parent_seq_number,
                                                           p_student_confirmed_ind  => p_susa_rec.student_confirmed_ind,
                                                           p_message_name           => l_message_name,
                                                           p_legacy                 => l_legacy);
        IF l_message_name IS NOT NULL THEN
            l_validation_success := FALSE;
            l_message_name := NULL;
        END IF;
    END IF;


    -- 1. If end date is being set and the unit set was part of the admissions offer, then authorisation fields must be set.
    -- 2. Cannot have two active attempts of the same unit set within a single program attempt.
    -- 3. The end date must be set if the parent unit set is ended
    l_ret_val := igs_en_val_susa.enrp_val_susa_end_dt (p_person_id              => p_person_id,
                                                       p_course_cd              => p_susa_rec.program_cd,
                                                       p_unit_set_cd            => p_susa_rec.unit_set_cd,
                                                       p_sequence_number        => p_sequence_number,
                                                       p_us_version_number      => p_susa_rec.us_version_number,
                                                       p_end_dt                 => p_susa_rec.end_dt,
                                                       p_authorised_person_id   => p_auth_person_id,
                                                       p_authorised_on          => p_susa_rec.authorised_on,
                                                       p_parent_unit_set_cd     => p_susa_rec.parent_unit_set_cd,
                                                       p_parent_sequence_number => p_parent_seq_number,
                                                       p_message_type           => 'E',
                                                       p_message_name           => l_message_name,
                                                       p_legacy                 => l_legacy);

    IF l_message_name IS NOT NULL THEN
        l_validation_success := FALSE;
        l_message_name := NULL;
    END IF;


    -- 1. The confirmed indicator cannot be unset if the end date is set
    -- 2. The confirmed indicator cannot be unset if the completed date is set
    -- 3. The confirmed indicator cannot be set if the program attempt status is unconfirmed
    -- 4. The confirmed indicator cannot be set when parent is unconfirmed
    l_ret_val := igs_en_val_susa.enrp_val_susa_sci (p_person_id              => p_person_id,
                                                    p_course_cd              => p_susa_rec.program_cd,
                                                    p_unit_set_cd            => p_susa_rec.unit_set_cd,
                                                    p_sequence_number        => p_sequence_number,
                                                    p_us_version_number      => p_susa_rec.us_version_number,
                                                    p_parent_unit_set_cd     => p_susa_rec.parent_unit_set_cd,
                                                    p_parent_sequence_number => p_parent_seq_number,
                                                    p_student_confirmed_ind  => p_susa_rec.student_confirmed_ind,
                                                    p_selection_dt           => p_susa_rec.selection_dt,
                                                    p_end_dt                 => p_susa_rec.end_dt,
                                                    p_rqrmnts_complete_ind   => p_susa_rec.rqrmnts_complete_ind,
                                                    p_message_name           => l_message_name,
                                                    p_legacy                 => l_legacy);


    IF l_message_name IS NOT NULL THEN
        l_validation_success := FALSE;
        l_message_name := NULL;
    END IF;


    -- Check that an administrative unit cannot be set to be a primary one
    l_ret_val := igs_en_val_susa.enrp_val_susa_prmry (p_person_id         => p_person_id,
                                                      p_course_cd         => p_susa_rec.program_cd,
                                                      p_unit_set_cd       => p_susa_rec.unit_set_cd,
                                                      p_us_version_number => p_susa_rec.us_version_number,
                                                      p_primary_set_ind   => p_susa_rec.primary_set_ind,
                                                      p_message_name      => l_message_name,
                                                      p_legacy            => l_legacy);

    IF l_message_name IS NOT NULL THEN
        l_validation_success := FALSE;
        l_message_name := NULL;
    END IF;

    -- Check the condition that unit sets with category of 'pre-enrollment year' cannot be
    -- inserted unless profile option is set
    IF NOT igs_en_gen_legacy.check_pre_enroll_prof (p_unit_set_cd       => p_susa_rec.unit_set_cd,
                                                    p_us_version_number => p_susa_rec.us_version_number) THEN

        -- Add excep to stack
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_CANT_ADD_PRENRL_US');
        FND_MSG_PUB.ADD;
        l_validation_success := FALSE;
    END IF;


    IF p_susa_rec.selection_dt IS NOT NULL THEN

        -- Check the condition that unit sets with category of 'pre-enrollment year' cannot
        -- overlap selection/completion dates
        l_message_name := NULL;
        IF NOT igs_en_gen_legacy.check_usa_overlap (p_person_id		        => p_person_id,
                                                    p_program_cd	        => p_susa_rec.program_cd,
                                                    p_selection_dt	        => p_susa_rec.selection_dt,
                                                    p_rqrmnts_complete_dt	=> p_susa_rec.rqrmnts_complete_dt,
						    p_end_dt                    => p_susa_rec.end_dt,
						    p_sequence_number           => p_sequence_number,
                                                    p_unit_set_cd               => p_susa_rec.unit_set_cd,
                                                    p_us_version_number         => p_susa_rec.us_version_number,
                                                    p_message_name              => l_message_name) THEN
            -- Add excep to stack
            FND_MESSAGE.SET_NAME('IGS',l_message_name);
            FND_MSG_PUB.ADD;
            l_validation_success := FALSE;
        END IF;
    END IF;

   RETURN l_validation_success;

END validate_unit_set_atmpt;



PROCEDURE create_unit_set_atmpt (p_api_version           IN   NUMBER,
                                 p_init_msg_list         IN   VARCHAR2,
                                 p_commit                IN   VARCHAR2,
                                 p_validation_level      IN   NUMBER,
                                 p_susa_rec              IN   susa_rec_type,
                                 x_return_status         OUT  NOCOPY VARCHAR2,
                                 x_msg_count             OUT  NOCOPY NUMBER,
                                 x_msg_data              OUT  NOCOPY VARCHAR2) AS

/*----------------------------------------------------------------------------
||  Created By : prraj
||  Created On : 05-11-2002
||  Purpose : To create a EN Student Unit Set Attempt
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
    ctyagi      16-March-2005 truncate the time component for the date field
                              for bug 4207943
------------------------------------------------------------------------------*/

    -- Cursor to fetch the sequence number
    CURSOR c_susa_seq IS
    SELECT
        igs_as_su_setatmpt_seq_num_s.NEXTVAL
    FROM dual;

    l_api_name              CONSTANT    VARCHAR2(30) := 'create_unit_set_atmpt';
    l_api_version           CONSTANT    NUMBER       := 1.0;

    l_insert_flag           BOOLEAN := TRUE;
    l_ret_val               VARCHAR2(1) := NULL;

    l_person_id             igs_as_su_setatmpt.person_id%TYPE;
    l_auth_person_id        igs_as_su_setatmpt.authorised_person_id%TYPE;
    l_parent_seq_number     igs_as_su_setatmpt.parent_sequence_number%TYPE;
    l_us_version_number     igs_as_su_setatmpt.us_version_number%TYPE;
    l_seqval                igs_as_su_setatmpt.sequence_number%TYPE;
    l_cal_type              igs_as_su_setatmpt.catalog_cal_type%TYPE;
    l_ci_sequence_number    igs_as_su_setatmpt.catalog_seq_num%TYPE;
    l_cal_start_dt          igs_ca_inst.start_dt%TYPE;
    l_cal_end_dt            igs_ca_inst.end_dt%TYPE;
    l_cal_return_status     VARCHAR2(20);

    l_creation_date         igs_as_su_setatmpt.creation_date%TYPE;
    l_last_update_date      igs_as_su_setatmpt.last_update_date%TYPE;
    l_created_by            igs_as_su_setatmpt.created_by%TYPE;
    l_last_updated_by       igs_as_su_setatmpt.last_updated_by%TYPE;
    l_last_update_login     igs_as_su_setatmpt.last_update_login%TYPE;

    l_request_id            igs_as_su_setatmpt.request_id%TYPE;
    l_program_appl_id       igs_as_su_setatmpt.program_application_id%TYPE;
    l_program_id            igs_as_su_setatmpt.program_id%TYPE;
    l_program_update_date   igs_as_su_setatmpt.program_update_date%TYPE;

BEGIN

    -- Create a savepoint
    SAVEPOINT    create_susa_pub;

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



    -- Validate input paramaters ---------

    IF NOT validate_parameters(p_susa_rec   => p_susa_rec) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_insert_flag := FALSE;
    END IF;


    -- Derivations ----------------------------------

    -- Person ID
    IF l_insert_flag THEN
        l_person_id := igs_ge_gen_003.get_person_id (p_person_number => p_susa_rec.person_number);

        IF l_person_id IS NULL THEN
            -- Add excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_PERSON_NUMBER');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_insert_flag := FALSE;
        END IF;
    END IF;


    -- Parent sequence number
    IF l_insert_flag THEN
        IF p_susa_rec.parent_unit_set_cd IS NOT NULL THEN
            igs_ge_gen_003.get_susa_sequence_num (p_person_id         => l_person_id,
                                                  p_program_cd        => p_susa_rec.program_cd,
                                                  p_unit_set_cd       => p_susa_rec.parent_unit_set_cd,
                                                  p_us_version_number => l_us_version_number,
                                                  p_sequence_number   => l_parent_seq_number);

            IF l_us_version_number IS NULL OR l_parent_seq_number IS NULL THEN
                -- Add excep to stack
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_NO_PAR_UNIT_SET_CD');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
                l_insert_flag := FALSE;
            END IF;
        END IF;
    END IF;


    -- Catalog Cal type and sequence number
    IF p_susa_rec.catalog_cal_alternate_code IS NOT NULL THEN
        igs_ge_gen_003.get_calendar_instance (p_alternate_cd       => p_susa_rec.catalog_cal_alternate_code,
                                              p_s_cal_category     => '''LOAD'',''ACADEMIC''',
                                              p_cal_type           => l_cal_type,
                                              p_ci_sequence_number => l_ci_sequence_number,
                                              p_start_dt           => l_cal_start_dt,
                                              p_end_dt             => l_cal_end_dt,
                                              p_return_status      => l_cal_return_status);

        IF l_cal_return_status = 'INVALID' THEN
            -- Add excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_EN_NO_ACAD_TERM_CAL');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_insert_flag := FALSE;
        ELSIF l_cal_return_status = 'MULTIPLE' THEN
            -- Add excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_EN_MORE_CAL_FOUND');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_insert_flag := FALSE;
        END IF;
    END IF;


    -- Authorisor person id
    IF p_susa_rec.authorised_person_number IS NOT NULL THEN
        l_auth_person_id := igs_ge_gen_003.get_person_id (p_person_number => p_susa_rec.authorised_person_number);

        IF l_auth_person_id IS NULL THEN
            -- Add excep to stack
            FND_MESSAGE.SET_NAME('IGS','IGS_EN_AUTH_PERS_NOTEXIST');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_insert_flag := FALSE;
        END IF;
    END IF;


    -- Validate database constraints
    IF l_insert_flag THEN
        l_ret_val := validate_db_cons (p_person_id           => l_person_id,
                                       p_parent_seq_number   => l_parent_seq_number,
                                       p_susa_rec            => p_susa_rec);

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
        -- Unit Set attempt is not yet created, hence passing zero
        -- for sequence number
        IF NOT validate_unit_set_atmpt (p_person_id           => l_person_id,
                                        p_sequence_number     => 0,
                                        p_parent_seq_number   => l_parent_seq_number,
                                        p_auth_person_id      => l_auth_person_id,
                                        p_susa_rec            => p_susa_rec) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_insert_flag := FALSE;
        END IF;
    END IF;


    -- Perform direct insert on IGS_AS_SU_SETATMPT
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

        -- Concurrent manager columns
        l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
        l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
        l_program_appl_id := FND_GLOBAL.PROG_APPL_ID;

        IF (l_request_id = -1) THEN
            l_request_id := NULL;
            l_program_id := NULL;
            l_program_appl_id := NULL;
            l_program_update_date := NULL;
        ELSE
            l_program_update_date := SYSDATE;
        END IF;

       -- Sequence number
        OPEN c_susa_seq;
            FETCH c_susa_seq INTO l_seqval;
        CLOSE c_susa_seq;


            INSERT INTO igs_as_su_setatmpt (
            person_id,
            course_cd,
            unit_set_cd,
            us_version_number,
            sequence_number,
            selection_dt,
            student_confirmed_ind,
            end_dt,
            parent_unit_set_cd,
            parent_sequence_number,
            primary_set_ind,
            voluntary_end_ind,
            authorised_person_id,
            authorised_on,
            override_title,
            rqrmnts_complete_ind,
            rqrmnts_complete_dt,
            s_completed_source_type,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            catalog_cal_type,
            catalog_seq_num,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            attribute16,
            attribute17,
            attribute18,
            attribute19,
            attribute20)
            VALUES (
            l_person_id,
            p_susa_rec.program_cd,
            p_susa_rec.unit_set_cd,
            p_susa_rec.us_version_number,
            l_seqval,
            trunc(p_susa_rec.selection_dt),
            NVL(p_susa_rec.student_confirmed_ind,'N'),
            trunc(p_susa_rec.end_dt),
            p_susa_rec.parent_unit_set_cd,
            l_parent_seq_number,
            NVL(p_susa_rec.primary_set_ind,'N'),
            NVL(p_susa_rec.voluntary_end_ind,'N'),
            l_auth_person_id,
            p_susa_rec.authorised_on,
            p_susa_rec.override_title,
            NVL(p_susa_rec.rqrmnts_complete_ind,'N'),
            trunc(p_susa_rec.rqrmnts_complete_dt),
            p_susa_rec.s_completed_source_type,
            l_created_by,
            l_creation_date,
            l_last_updated_by,
            l_last_update_date,
            l_last_update_login,
            l_request_id,
            l_program_appl_id,
            l_program_id,
            l_program_update_date,
            l_cal_type,
            l_ci_sequence_number,
            p_susa_rec.attribute_category,
            p_susa_rec.attribute1,
            p_susa_rec.attribute2,
            p_susa_rec.attribute3,
            p_susa_rec.attribute4,
            p_susa_rec.attribute5,
            p_susa_rec.attribute6,
            p_susa_rec.attribute7,
            p_susa_rec.attribute8,
            p_susa_rec.attribute9,
            p_susa_rec.attribute10,
            p_susa_rec.attribute11,
            p_susa_rec.attribute12,
            p_susa_rec.attribute13,
            p_susa_rec.attribute14,
            p_susa_rec.attribute15,
            p_susa_rec.attribute16,
            p_susa_rec.attribute17,
            p_susa_rec.attribute18,
            p_susa_rec.attribute19,
            p_susa_rec.attribute20);

    ELSE
        ROLLBACK TO create_susa_pub;
    END IF;



    -- If the calling program has passed the parameter for committing the data and there
    -- have been no validation failures, then commit the work
    IF ( (FND_API.TO_BOOLEAN(p_commit)) AND (l_insert_flag) ) THEN
      COMMIT WORK;
    END IF;


    FND_MSG_PUB.COUNT_AND_GET( p_count   => x_msg_count,
                               p_data    => x_msg_data);


    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO create_susa_pub;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO create_susa_pub;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO create_susa_pub;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,
                                    l_api_name);
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);


END create_unit_set_atmpt;



END igs_en_susa_lgcy_pub;

/
