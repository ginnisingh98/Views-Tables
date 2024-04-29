--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPAT_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPAT_LGCY_PUB" AS
/* $Header: IGSENA9B.pls 120.3 2005/09/23 08:23:23 appldev ship $ */

/*****************************************************************************
 Who     When        What
sgurusam 20-Jun-05   Added PLAN_SHT_STATUS value as 'NONE' in insert the statement
                     of table igs_en_spa_terms
******************************************************************************/

g_pkg_name                      CONSTANT VARCHAR2(30) := 'IGS_EN_SPAT_LGCY_PUB';

FUNCTION validate_parameters(
        p_spat_rec IN spat_rec_type)
RETURN  BOOLEAN AS
/*----------------------------------------------------------------------------
||  Created By : vkarthik
||  Created On : 11-Dec-2003
||  Purpose : validates the spat_int record attributes
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/

l_message_count                 NUMBER(5);
l_ret_status                    BOOLEAN         := TRUE;
l_get_calendar_instance_return  VARCHAR2(10);

BEGIN
        IF p_spat_rec.person_number IS NULL THEN
                l_ret_status := FALSE;
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PER_NUM_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_spat_rec.program_cd IS NULL THEN
                l_ret_status := FALSE;
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_CD_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_spat_rec.program_version IS NULL THEN
                l_ret_status := FALSE;
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_VER_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_spat_rec.location_cd IS NULL THEN
                l_ret_status := FALSE;
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_LOC_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_spat_rec.attendance_mode IS NULL THEN
                l_ret_status := FALSE;
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_ATT_MOD_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_spat_rec.attendance_type IS NULL THEN
                l_ret_status := FALSE;
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_ATT_TYPE_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_spat_rec.key_program_flag IS NULL THEN
                l_ret_status := FALSE;
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_KEY_PROG_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_spat_rec.acad_cal_type IS NULL THEN
                l_ret_status := FALSE;
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_ACAD_CAL_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_spat_rec.term_cal_alternate_cd IS NULL THEN
                l_ret_status := FALSE;
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_TERM_CAL_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF      (p_spat_rec.attribute_category  IS NOT NULL OR
                p_spat_rec.attribute1           IS NOT NULL OR
                p_spat_rec.attribute2           IS NOT NULL OR
                p_spat_rec.attribute3           IS NOT NULL OR
                p_spat_rec.attribute4           IS NOT NULL OR
                p_spat_rec.attribute5           IS NOT NULL OR
                p_spat_rec.attribute6           IS NOT NULL OR
                p_spat_rec.attribute7           IS NOT NULL OR
                p_spat_rec.attribute8           IS NOT NULL OR
                p_spat_rec.attribute9           IS NOT NULL OR
                p_spat_rec.attribute10          IS NOT NULL OR
                p_spat_rec.attribute11          IS NOT NULL OR
                p_spat_rec.attribute12          IS NOT NULL OR
                p_spat_rec.attribute12          IS NOT NULL OR
                p_spat_rec.attribute13          IS NOT NULL OR
                p_spat_rec.attribute14          IS NOT NULL OR
                p_spat_rec.attribute15          IS NOT NULL OR
                p_spat_rec.attribute16          IS NOT NULL OR
                p_spat_rec.attribute17          IS NOT NULL OR
                p_spat_rec.attribute18          IS NOT NULL OR
                p_spat_rec.attribute19          IS NOT NULL OR
                p_spat_rec.attribute20          IS NOT NULL)   THEN
                IF NOT igs_ad_imp_018.validate_desc_flex (
                        p_attribute_category    => p_spat_rec.attribute_category ,
                        p_attribute1            => p_spat_rec.attribute1,
                        p_attribute2            => p_spat_rec.attribute2,
                        p_attribute3            => p_spat_rec.attribute3,
                        p_attribute4            => p_spat_rec.attribute4,
                        p_attribute5            => p_spat_rec.attribute5,
                        p_attribute6            => p_spat_rec.attribute6,
                        p_attribute7            => p_spat_rec.attribute7,
                        p_attribute8            => p_spat_rec.attribute8,
                        p_attribute9            => p_spat_rec.attribute9,
                        p_attribute10           => p_spat_rec.attribute10,
                        p_attribute11           => p_spat_rec.attribute11,
                        p_attribute12           => p_spat_rec.attribute12,
                        p_attribute13           => p_spat_rec.attribute13,
                        p_attribute14           => p_spat_rec.attribute14,
                        p_attribute15           => p_spat_rec.attribute15,
                        p_attribute16           => p_spat_rec.attribute16,
                        p_attribute17           => p_spat_rec.attribute17,
                        p_attribute18           => p_spat_rec.attribute18,
                        p_attribute19           => p_spat_rec.attribute19,
                        p_attribute20           => p_spat_rec.attribute20,
                        p_desc_flex_name        => 'IGS_EN_SPA_TERMS_FLEX') THEN
                                l_ret_status := FALSE;
                                FND_MESSAGE.SET_NAME('IGS','IGS_AD_INVALID_DESC_FLEX');
                                FND_MSG_PUB.ADD;
                END IF;
        END IF;

        IF p_spat_rec.program_cd IS NOT NULL THEN
                BEGIN
                        igs_en_stdnt_ps_att_pkg.check_constraints(
                        column_name             =>      'COURSE_CD',
                        column_value            =>      p_spat_rec.program_cd);
                EXCEPTION
                        WHEN OTHERS THEN
                                l_ret_status := FALSE;
                                l_message_count := FND_MSG_PUB.COUNT_MSG;
                                FND_MSG_PUB.DELETE_MSG(l_message_count);
                                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_CD_UPPCASE');
                                FND_MSG_PUB.ADD;
                END;
        END IF;

        IF p_spat_rec.acad_cal_type IS NOT NULL THEN
                BEGIN
                        igs_en_stdnt_ps_att_pkg.check_constraints(
                        column_name             =>      'CAL_TYPE',
                        column_value            =>      p_spat_rec.acad_cal_type);
                EXCEPTION
                        WHEN OTHERS THEN
                                l_ret_status := FALSE;
                                l_message_count := FND_MSG_PUB.COUNT_MSG;
                                FND_MSG_PUB.DELETE_MSG(l_message_count);
                                FND_MESSAGE.SET_NAME('IGS','IGS_EN_ACAD_CAL_UPPCASE');
                                FND_MSG_PUB.ADD;
                END;
        END IF;

        IF p_spat_rec.location_cd IS NOT NULL THEN
                BEGIN
                        igs_en_stdnt_ps_att_pkg.check_constraints(
                                column_name             =>      'LOCATION_CD',
                                column_value            =>      p_spat_rec.location_cd);
                EXCEPTION
                        WHEN OTHERS THEN
                                l_ret_status := FALSE;
                                l_message_count := FND_MSG_PUB.COUNT_MSG;
                                FND_MSG_PUB.DELETE_MSG(l_message_count);
                                FND_MESSAGE.SET_NAME('IGS','IGS_EN_LOC_CD_UCASE');
                                FND_MSG_PUB.ADD;
                END;
        END IF;

        IF p_spat_rec.attendance_mode IS NOT NULL THEN
                BEGIN
                        igs_en_stdnt_ps_att_pkg.check_constraints (
                                column_name             =>      'ATTENDANCE_MODE',
                                column_value            =>      p_spat_rec.attendance_mode);
                EXCEPTION
                        WHEN OTHERS THEN
                                l_ret_status := FALSE;
                                l_message_count := FND_MSG_PUB.COUNT_MSG;
                                FND_MSG_PUB.DELETE_MSG(l_message_count);
                                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_ATT_MODE_UCASE');
                                FND_MSG_PUB.ADD;
                END;
        END IF;

        IF p_spat_rec.attendance_type IS NOT NULL THEN
                BEGIN
                        igs_en_stdnt_ps_att_pkg.check_constraints(
                                column_name             =>      'ATTENDANCE_TYPE',
                                column_value            =>      p_spat_rec.attendance_type);
                EXCEPTION
                        WHEN OTHERS THEN
                                l_ret_status := FALSE;
                                l_message_count := FND_MSG_PUB.COUNT_MSG;
                                FND_MSG_PUB.DELETE_MSG(l_message_count);
                                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_ATT_TYPE_UCASE');
                                FND_MSG_PUB.ADD;
                END;
        END IF;

        IF p_spat_rec.key_program_flag IS NOT NULL THEN
                BEGIN
                        igs_en_stdnt_ps_att_pkg.check_constraints(
                        column_name             =>      'KEY_PROGRAM',
                        column_value            =>      p_spat_rec.key_program_flag);
                EXCEPTION
                        WHEN OTHERS THEN
                                l_ret_status := FALSE;
                                l_message_count := FND_MSG_PUB.COUNT_MSG;
                                FND_MSG_PUB.DELETE_MSG(l_message_count);
                                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_KEY_INVALID');
                                FND_MSG_PUB.ADD;
                END;
        END IF;
        RETURN l_ret_status;
END validate_parameters;


FUNCTION validate_spat_db_cons (
        p_person_id             IN      NUMBER,
        p_term_cal_type         IN      VARCHAR2,
        p_term_sequence_number  IN      NUMBER,
        p_spat_rec              IN      spat_rec_type)
RETURN VARCHAR2 AS
/*----------------------------------------------------------------------------
||  Created By : vkarthik
||  Created On : 11-Dec-2003
||  Purpose : validates database constraints
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/

l_ret_status                    VARCHAR2(1)     := 'S';
l_get_pk_for_validation_return  BOOLEAN;
l_get_uk_for_validation_return  BOOLEAN;

BEGIN
        l_get_uk_for_validation_return := igs_en_spa_terms_pkg.get_uk_for_validation(
                                                p_person_id,
                                                p_spat_rec.program_cd,
                                                p_term_cal_type,
                                                p_term_sequence_number);
        IF l_get_uk_for_validation_return = TRUE THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_SPAT_EXISTS');
                FND_MSG_PUB.ADD;
                RETURN 'W';
        END IF;

        l_get_pk_for_validation_return := igs_en_stdnt_ps_att_pkg.get_pk_for_validation(
                                                p_person_id,
                                                p_spat_rec.program_cd);
        IF l_get_pk_for_validation_return = FALSE THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_FI_PRSNID_PRGCD_NOT_MATCH');
                FND_MSG_PUB.ADD;
                l_ret_status := 'E';
        END IF;

        IF p_spat_rec.fee_cat IS NOT NULL THEN
                l_get_pk_for_validation_return := igs_fi_fee_cat_pkg.get_pk_for_validation(
                                                        p_spat_rec.fee_cat);
                IF l_get_pk_for_validation_return = FALSE THEN
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_FEE_CAT_NOT_FOUND');
                        FND_MSG_PUB.ADD;
                l_ret_status := 'E';
                END IF;
        END IF;
        RETURN l_ret_status;
END validate_spat_db_cons;


FUNCTION validate_pre_spat(
        p_person_id             IN      NUMBER,
        p_term_cal_type         IN      VARCHAR2,
        p_term_sequence_number  IN      NUMBER,
        p_spat_rec              IN      spat_rec_type)
RETURN BOOLEAN AS
/*----------------------------------------------------------------------------
||  Created By : vkarthik
||  Created On : 11-Dec-2003
||  Purpose : validates business rules
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/

CURSOR c_igs_en_spa_terms_career(
        pc_course_type                  igs_ps_ver.course_type%TYPE,
        pc_person_id                    NUMBER,
        pc_term_cal_type                VARCHAR2,
        pc_term_sequence_number         NUMBER,
        pc_program_cd                   igs_en_spa_terms.program_cd%TYPE)  IS
        SELECT 'X'
        FROM igs_en_spa_terms spa_terms, igs_ps_ver ps_ver
              WHERE
                spa_terms.person_id             =       pc_person_id                 AND
                spa_terms.term_cal_type         =       pc_term_cal_type             AND
                spa_terms.term_sequence_number  =       pc_term_sequence_number      AND
                spa_terms.program_cd            <>      pc_program_cd                AND
                ps_ver.course_type              =       pc_course_type               AND
                spa_terms.program_cd            =       ps_ver.course_cd             AND
                spa_terms.program_version       =       ps_ver.version_number;

CURSOR c_igs_en_spa_terms_normal(
        pc_person_id                    NUMBER,
        pc_term_cal_type                VARCHAR2,
        pc_term_sequence_number         NUMBER,
        pc_program_cd                   igs_en_spa_terms.program_cd%TYPE)  IS
        SELECT 'X'
        FROM igs_en_spa_terms
        WHERE
                person_id                =      pc_person_id                 AND
                term_cal_type            =      pc_term_cal_type             AND
                term_sequence_number     =      pc_term_sequence_number      AND
                program_cd               <>     pc_program_cd                AND
                key_program_flag         =      'Y';

CURSOR c_course_type_p_spat_rec(
        cp_program_cd                   igs_ps_ver.course_cd%TYPE,
        cp_program_version              igs_ps_ver.version_number%TYPE) IS
        SELECT course_type
        FROM igs_ps_ver
        WHERE
                course_cd       = cp_program_cd        AND
                version_number  = cp_program_version;

l_return_value                  BOOLEAN         :=      TRUE;
l_igs_en_spa_terms_career       c_igs_en_spa_terms_career%ROWTYPE;
l_igs_en_spa_terms_normal       c_igs_en_spa_terms_normal%ROWTYPE;
l_course_type_p_spat_rec        igs_ps_ver.course_type%TYPE;
l_career_flag                   VARCHAR2(1);

BEGIN
        OPEN c_course_type_p_spat_rec(p_spat_rec.program_cd, p_spat_rec.program_version);
        FETCH c_course_type_p_spat_rec INTO l_course_type_p_spat_rec;
        CLOSE c_course_type_p_spat_rec;

        l_career_flag   :=   NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'), 'N');

        IF l_career_flag = 'Y' THEN
                OPEN c_igs_en_spa_terms_career(
                                l_course_type_p_spat_rec,
                                p_person_id,
                                p_term_cal_type,
                                p_term_sequence_number,
                                p_spat_rec.program_cd);
                FETCH c_igs_en_spa_terms_career INTO l_igs_en_spa_terms_career;
                IF c_igs_en_spa_terms_career%FOUND THEN
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_SPAT_EXISTS_CAREER');
                        FND_MSG_PUB.ADD;
                        l_return_value := FALSE;
                END IF;
                CLOSE c_igs_en_spa_terms_career;
        END IF;

        -- if the new record is a key program
        IF p_spat_rec.key_program_flag = 'Y' THEN
                -- check if any other key program already exists for the term and person
                OPEN c_igs_en_spa_terms_normal(
                        p_person_id,
                        p_term_cal_type,
                        p_term_sequence_number,
                        p_spat_rec.program_cd);
                FETCH c_igs_en_spa_terms_normal INTO l_igs_en_spa_terms_normal;
                IF c_igs_en_spa_terms_normal%FOUND THEN
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_MORE_KEY_IN_TERM');
                        FND_MSG_PUB.ADD;
                        l_return_value := FALSE;
                END IF;
                CLOSE c_igs_en_spa_terms_normal;
        END IF;
        RETURN l_return_value;
END validate_pre_spat;

PROCEDURE validate_post_spat(
        p_person_id             IN              igs_en_spa_terms.person_id%TYPE,
        p_term_cal_type         IN              igs_en_spa_terms.term_cal_type%TYPE,
        p_term_sequence_number  IN              igs_en_spa_terms.term_sequence_number%TYPE,
        p_class_standing_id     IN              igs_en_spa_terms.class_standing_id%TYPE,
        p_coo_id                IN              igs_en_spa_terms.coo_id%TYPE,
        p_spat_rec              IN              spat_rec_type) AS
/*----------------------------------------------------------------------------
||  Created By : vkarthik
||  Created On : 11-Dec-2003
||  Purpose : procedure takes care of backward gap and forward gap filling
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/

v_term_rec igs_en_spa_terms_api.EN_SPAT_REC_TYPE%TYPE;
BEGIN
        -- fill gaps
        v_term_rec.person_id := p_person_id;
        v_term_rec.program_cd :=  p_spat_rec.program_cd;
        v_term_rec.term_cal_type :=p_term_cal_type;
        v_term_rec.term_sequence_number := p_term_sequence_number;
        v_term_rec.program_version := p_spat_rec.program_version;
        v_term_rec.coo_id :=p_coo_id;
        v_term_rec.acad_cal_type := p_spat_rec.acad_cal_type;
        v_term_rec.key_program_flag :=p_spat_rec.key_program_flag;
        v_term_rec.location_cd :=p_spat_rec.location_cd;
        v_term_rec.attendance_mode :=p_spat_rec.attendance_mode;
        v_term_rec.attendance_type :=p_spat_rec.attendance_type;
        v_term_rec.fee_cat := p_spat_rec.fee_cat;
        v_term_rec.class_standing_id := p_class_standing_id;

        IF p_term_cal_type IS NOT NULL AND p_term_sequence_number IS NOT NULL THEN
                igs_en_spa_terms_api.backward_gap_fill ( v_term_rec);
                igs_en_spa_terms_api.forward_gap_fill ( v_term_rec);
        END IF;

END validate_post_spat;

PROCEDURE create_spa_t (
        p_api_version           IN              NUMBER,
        p_init_msg_list         IN              VARCHAR2,
        p_commit                IN              VARCHAR2,
        p_validation_level      IN              NUMBER,
        p_spat_rec              IN              spat_rec_type,
        x_return_status         OUT     NOCOPY  VARCHAR2,
        x_msg_count             OUT     NOCOPY  NUMBER,
        x_msg_data              OUT     NOCOPY  VARCHAR2 ) AS
/*----------------------------------------------------------------------------
||  Created By : vkarthik
||  Created On : 11-Dec-2003
||  Purpose : public procedure that inserts the records into spat
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/

CURSOR c_igs_en_spa_terms_s IS
                SELECT igs_en_spa_terms_s.NEXTVAL
                        FROM dual;

l_api_name              CONSTANT        VARCHAR2(30)    := 'create_spa_t';
l_api_version           CONSTANT        NUMBER          := 1.0;
l_validation_failed                     BOOLEAN         :=FALSE;
l_get_calendar_instance_return          VARCHAR2(10);
l_validate_db_ret_status                VARCHAR2(1);
l_spa_terms_term_record_id              igs_en_spa_terms.term_record_id%TYPE;
l_request_id                            igs_en_spa_terms.request_id%TYPE;
l_program_application_id                igs_en_spa_terms.program_application_id%TYPE;
l_program_id                            igs_en_spa_terms.program_id%TYPE;
l_program_update_date                   igs_en_spa_terms.program_update_date%TYPE;
l_person_id                             igs_en_spa_terms.person_id%TYPE;
l_term_cal_type                         igs_en_spa_terms.term_cal_type%TYPE;
l_term_sequence_number                  igs_en_spa_terms.term_sequence_number%TYPE;
l_ci_start_dt                           DATE;
l_ci_end_dt                             DATE;
l_class_standing_id                     igs_en_spa_terms.class_standing_id%TYPE;
l_coo_id                                igs_en_spa_terms.coo_id%TYPE;

BEGIN
-- create a save point
SAVEPOINT create_spa_t_svpt;

--check for compatible API call
IF NOT FND_API.COMPATIBLE_API_CALL (
                l_api_version,
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

-- validate parameters
IF NOT validate_parameters(
                p_spat_rec      =>      p_spat_rec) THEN
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_validation_failed := TRUE;
END IF;

-- if no validation has failed then derive person_id, term_cal_type, term_sequence_number
-- class_standing_id, coo_id
IF NOT l_validation_failed THEN
        l_person_id := igs_ge_gen_003.get_person_id(p_spat_rec.person_number);
        IF l_person_id IS NULL THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_PERSON_NUMBER');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
                l_validation_failed := TRUE;
        END IF;

        igs_ge_gen_003.get_calendar_instance(
                p_spat_rec.term_cal_alternate_cd,
                '''LOAD''',
                l_term_cal_type,
                l_term_sequence_number,
                l_ci_start_dt,
                l_ci_end_dt,
                l_get_calendar_instance_return);
        IF l_get_calendar_instance_return = 'INVALID' THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_ALT_CD_NO_TRM_FND');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
                l_validation_failed := TRUE;
        ELSE
                IF l_get_calendar_instance_return = 'MULTIPLE' THEN
                                FND_MESSAGE.SET_NAME('IGS','IGS_EN_MULTI_TRM_CAL_FND');
                                FND_MSG_PUB.ADD;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                l_validation_failed := TRUE;
                END IF;
        END IF;

        IF p_spat_rec.class_standing IS NOT NULL THEN
                l_class_standing_id := igs_en_gen_legacy.get_class_std_id(p_spat_rec.class_standing);
                IF l_class_standing_id IS NULL THEN
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_CLASS_STD_ID_NOT_FOUND');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        l_validation_failed := TRUE;
                END IF;
        END IF;

        l_coo_id   :=   igs_en_gen_legacy.get_coo_id(
                                p_spat_rec.program_cd,
                                p_spat_rec.program_version,
                                p_spat_rec.acad_cal_type,
                                p_spat_rec.location_cd,
                                p_spat_rec.attendance_mode,
                                p_spat_rec.attendance_type);
        IF l_coo_id IS NULL THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PS_OFR_OPT_NOT_FOUND');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
                l_validation_failed := TRUE;
        END IF;
END IF;

-- if no validation failed then check for database constraints
IF NOT l_validation_failed THEN
        l_validate_db_ret_status := validate_spat_db_cons (
                                                l_person_id,
                                                l_term_cal_type,
                                                l_term_sequence_number,
                                                p_spat_rec);
        IF l_validate_db_ret_status = 'W' THEN
                x_return_status := 'W';
                l_validation_failed := TRUE;
        END IF;
        IF l_validate_db_ret_status = 'E' THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                l_validation_failed := TRUE;
        END IF;
END IF;         --end of database constraints validation

-- if no validation failed then check the business rules and forward ripple
IF NOT l_validation_failed THEN
        IF NOT validate_pre_spat (
                                l_person_id,
                                l_term_cal_type,
                                l_term_sequence_number,
                                p_spat_rec) THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                l_validation_failed := TRUE;
        END IF;
END IF;

-- if no validation failed then insert the record into spa terms table
IF NOT l_validation_failed THEN

        --get the nextval from sequence igs_en_spa_terms_s for term_record_id
        OPEN c_igs_en_spa_terms_s;
        FETCH c_igs_en_spa_terms_s INTO l_spa_terms_term_record_id;
        CLOSE c_igs_en_spa_terms_s;

        -- derive the who column values
        l_request_id                    :=      FND_GLOBAL.CONC_REQUEST_ID;
        l_program_id                    :=      FND_GLOBAL.CONC_PROGRAM_ID;
        l_program_application_id        :=      FND_GLOBAL.PROG_APPL_ID;
        IF (l_request_id = -1) THEN
                l_request_id            :=      NULL;
                l_program_id            :=      NULL;
                l_program_application_id:=      NULL;
                l_program_update_date   :=      NULL;
        ELSE
                l_program_update_date   :=      SYSDATE;
        END IF;

        -- insert legacy record into spa_terms
        INSERT INTO igs_en_spa_terms (
                term_record_id,
                person_id,
                program_cd,
                program_version,
                acad_cal_type,
                term_cal_type,
                term_sequence_number,
                key_program_flag,
                location_cd,
                attendance_mode,
                attendance_type,
                fee_cat,
                coo_id,
                class_standing_id,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
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
                attribute20,
                plan_sht_status)
                VALUES (
                        l_spa_terms_term_record_id,
                        l_person_id,
                        p_spat_rec.program_cd,
                        p_spat_rec.program_version,
                        p_spat_rec.acad_cal_type,
                        l_term_cal_type,
                        l_term_sequence_number,
                        p_spat_rec.key_program_flag,
                        p_spat_rec.location_cd,
                        p_spat_rec.attendance_mode,
                        p_spat_rec.attendance_type,
                        p_spat_rec.fee_cat,
                        l_coo_id,
                        l_class_standing_id,
                        NVL(FND_GLOBAL.USER_ID, -1),            -- created_by
                        SYSDATE,                                -- creation_date
                        NVL(FND_GLOBAL.USER_ID,-1),             -- last_updated_by
                        SYSDATE,                                -- last_update_date
                        NVL(FND_GLOBAL.LOGIN_ID, -1),           -- last_update_login
                        l_request_id,                           -- request_id
                        l_program_application_id,               -- program_application_id
                        l_program_id,                           -- program_id
                        l_program_update_date,                  -- program_update_date
                        p_spat_rec.attribute_category,
                        p_spat_rec.attribute1,
                        p_spat_rec.attribute2,
                        p_spat_rec.attribute3,
                        p_spat_rec.attribute4,
                        p_spat_rec.attribute5,
                        p_spat_rec.attribute6,
                        p_spat_rec.attribute7,
                        p_spat_rec.attribute8,
                        p_spat_rec.attribute9,
                        p_spat_rec.attribute10,
                        p_spat_rec.attribute11,
                        p_spat_rec.attribute12,
                        p_spat_rec.attribute13,
                        p_spat_rec.attribute14,
                        p_spat_rec.attribute15,
                        p_spat_rec.attribute16,
                        p_spat_rec.attribute17,
                        p_spat_rec.attribute18,
                        p_spat_rec.attribute19,
                        p_spat_rec.attribute20,
                        'NONE');

        -- forward and backward gap filling
        validate_post_spat(
                p_person_id             =>      l_person_id,
                p_term_cal_type         =>      l_term_cal_type,
                p_term_sequence_number  =>      l_term_sequence_number,
                p_class_standing_id     =>      l_class_standing_id,
                p_coo_id                =>      l_coo_id,
                p_spat_rec              =>      p_spat_rec);

        -- setting the return value to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
ELSE
        ROLLBACK TO create_spa_t_svpt;
END IF;

-- if no validation failed and asked to commit through p_commit
IF NOT l_validation_failed AND FND_API.TO_BOOLEAN(p_commit) THEN
        COMMIT;
END IF;

FND_MSG_PUB.COUNT_AND_GET (
        p_count         =>      x_msg_count,
        p_data          =>      x_msg_data);

RETURN;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_spa_t_svpt;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.COUNT_AND_GET (
                                p_count         =>      x_msg_count,
                                p_data          =>      x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_spa_t_svpt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.COUNT_AND_GET (
                                p_count         =>      x_msg_count,
                                p_data          =>      x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO create_spa_t_svpt;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.ADD_EXC_MSG(
                                g_pkg_name,
                                l_api_name);
                END IF;
                FND_MSG_PUB.COUNT_AND_GET (
                                p_count         =>      x_msg_count,
                                p_data          =>      x_msg_data);

END create_spa_t;

END igs_en_spat_lgcy_pub;

/
