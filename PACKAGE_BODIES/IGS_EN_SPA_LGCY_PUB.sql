--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPA_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPA_LGCY_PUB" AS
/* $Header: IGSENA2B.pls 120.0 2005/06/03 15:54:41 appldev noship $ */
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose :
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  amuthu          07-JAN-03       Changed the validate_re_db_cons
||  amuthu          07-JAN-03       Changed the validate_sca_db_cons
------------------------------------------------------------------------------*/
g_pkg_name        CONSTANT VARCHAR2(30) := 'IGS_EN_SPA_LGCY_PUB';

FUNCTION validate_parameters(p_sca_re_rec         IN   SCA_RE_REC_TYPE,
                             p_career_flag        IN   VARCHAR2)
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Function validates the student program attempt legacy input parameters.
|   On successful validation it returns true else false.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
RETURN BOOLEAN AS
l_error_flag                 VARCHAR2(1);
l_message_count              NUMBER(5);
BEGIN
     --Set the error flag to N
     l_error_flag  := 'N';

     --Validating the mandatory parameters.
     IF p_sca_re_rec.person_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PER_NUM_NULL');
        FND_MSG_PUB.ADD;
        l_error_flag  := 'Y';
     END IF;

     IF p_sca_re_rec.program_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_CD_NULL');
        FND_MSG_PUB.ADD;
        l_error_flag  := 'Y';
     END IF;

     IF p_sca_re_rec.version_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_VER_NULL');
        FND_MSG_PUB.ADD;
        l_error_flag  := 'Y';
     END IF;

     IF p_sca_re_rec.location_cd  IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_LOC_NULL');
        FND_MSG_PUB.ADD;
        l_error_flag  := 'Y';
     END IF;

     IF p_sca_re_rec.attendance_mode IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_ATT_MOD_NULL');
        FND_MSG_PUB.ADD;
        l_error_flag  := 'Y';
     END IF;

     IF p_sca_re_rec.attendance_type IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_ATT_TYPE_NULL');
        FND_MSG_PUB.ADD;
        l_error_flag  := 'Y';
     END IF;

     -- If any of the Descriptive Flex field columns have value , validate them .
     IF (p_sca_re_rec.attribute_category IS NOT NULL OR p_sca_re_rec.attribute1  IS NOT NULL OR p_sca_re_rec.attribute2  IS NOT NULL OR
         p_sca_re_rec.attribute3  IS NOT NULL OR p_sca_re_rec.attribute4  IS NOT NULL OR p_sca_re_rec.attribute5  IS NOT NULL OR
         p_sca_re_rec.attribute6  IS NOT NULL OR p_sca_re_rec.attribute7  IS NOT NULL OR p_sca_re_rec.attribute8  IS NOT NULL OR
         p_sca_re_rec.attribute9  IS NOT NULL OR p_sca_re_rec.attribute10 IS NOT NULL OR p_sca_re_rec.attribute11 IS NOT NULL OR
         p_sca_re_rec.attribute12 IS NOT NULL OR p_sca_re_rec.attribute13 IS NOT NULL OR p_sca_re_rec.attribute14 IS NOT NULL OR
         p_sca_re_rec.attribute15 IS NOT NULL OR p_sca_re_rec.attribute16 IS NOT NULL OR p_sca_re_rec.attribute17 IS NOT NULL OR
         p_sca_re_rec.attribute18 IS NOT NULL OR p_sca_re_rec.attribute19 IS NOT NULL OR p_sca_re_rec.attribute20 IS NOT NULL )
     THEN
            IF NOT igs_ad_imp_018.validate_desc_flex (
                 p_attribute_category   => p_sca_re_rec.attribute_category ,
                 p_attribute1           => p_sca_re_rec.attribute1   ,
                 p_attribute2           => p_sca_re_rec.attribute2   ,
                 p_attribute3           => p_sca_re_rec.attribute3   ,
                 p_attribute4           => p_sca_re_rec.attribute4   ,
                 p_attribute5           => p_sca_re_rec.attribute5   ,
                 p_attribute6           => p_sca_re_rec.attribute6   ,
                 p_attribute7           => p_sca_re_rec.attribute7   ,
                 p_attribute8           => p_sca_re_rec.attribute8   ,
                 p_attribute9           => p_sca_re_rec.attribute9   ,
                 p_attribute10          => p_sca_re_rec.attribute10  ,
                 p_attribute11          => p_sca_re_rec.attribute11  ,
                 p_attribute12          => p_sca_re_rec.attribute12  ,
                 p_attribute13          => p_sca_re_rec.attribute13  ,
                 p_attribute14          => p_sca_re_rec.attribute14  ,
                 p_attribute15          => p_sca_re_rec.attribute15  ,
                 p_attribute16          => p_sca_re_rec.attribute16  ,
                 p_attribute17          => p_sca_re_rec.attribute17  ,
                 p_attribute18          => p_sca_re_rec.attribute18  ,
                 p_attribute19          => p_sca_re_rec.attribute19  ,
                 p_attribute20          => p_sca_re_rec.attribute20  ,
                 p_desc_flex_name       => 'IGS_EN_STDNT_ATT_FLEX'
                 )  THEN
                        FND_MESSAGE.SET_NAME( 'IGS','IGS_AD_INVALID_DESC_FLEX' );
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
         END IF ;
     END IF;

     --Do check constraints validation.
     IF p_sca_re_rec.program_cd IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'COURSE_CD',
                                                            column_value   => p_sca_re_rec.program_cd);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_CD_UPPCASE');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.cal_type IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'CAL_TYPE',
                                                            column_value   => p_sca_re_rec.cal_type);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_ACAD_CAL_UPPCASE');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.location_cd IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'LOCATION_CD',
                                                            column_value   => p_sca_re_rec.location_cd);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_LOC_CD_UCASE');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.attendance_mode IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'ATTENDANCE_MODE',
                                                            column_value   => p_sca_re_rec.attendance_mode);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_ATT_MODE_UCASE');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.attendance_type IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'ATTENDANCE_TYPE',
                                                            column_value   => p_sca_re_rec.attendance_type);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_ATT_TYPE_UCASE');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.student_confirmed_ind IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'STUDENT_CONFIRMED_IND',
                                                            column_value   => p_sca_re_rec.student_confirmed_ind);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_CONF_IND_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
             END IF;

     IF p_career_flag = 'Y' THEN
             IF p_sca_re_rec.primary_program_type IS NOT NULL THEN
                 BEGIN
                      igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'PRIMARY_PROGRAM_TYPE',
                                                                column_value   => p_sca_re_rec.primary_program_type);
                      EXCEPTION
                        WHEN OTHERS THEN
                                l_message_count := FND_MSG_PUB.COUNT_MSG;
                                FND_MSG_PUB.DELETE_MSG(l_message_count);
                                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_PRI_PRG_INVALID');
                                FND_MSG_PUB.ADD;
                                l_error_flag  := 'Y';
                     END;
             END IF;
             IF p_sca_re_rec.primary_prog_type_source IS NOT NULL THEN
                     BEGIN
                          igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'PRIMARY_PROG_TYPE_SOURCE',
                                                                    column_value   => p_sca_re_rec.primary_prog_type_source);
                     EXCEPTION
                        WHEN OTHERS THEN
                                l_message_count := FND_MSG_PUB.COUNT_MSG;
                                FND_MSG_PUB.DELETE_MSG(l_message_count);
                                FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_SRC_PRI_TYP_INVALID');
                                FND_MSG_PUB.ADD;
                                l_error_flag  := 'Y';
                     END;
             END IF;
     END IF;  --p_career_flag
     IF p_sca_re_rec.key_program IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'KEY_PROGRAM',
                                                            column_value   => p_sca_re_rec.key_program);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_KEY_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.provisional_ind IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'PROVISIONAL_IND',
                                                            column_value   => p_sca_re_rec.provisional_ind);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_PROV_IND_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.discontinuation_reason_cd IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'DISCONTINUATION_REASON_CD',
                                                            column_value   => p_sca_re_rec.discontinuation_reason_cd);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_DIS_REAS_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.funding_source IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'FUNDING_SOURCE',
                                                            column_value   => p_sca_re_rec.funding_source);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_FUND_UPPCASE');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.exam_location_cd IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'EXAM_LOCATION_CD',
                                                        column_value   => p_sca_re_rec.exam_location_cd);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_EXM_LOC_UPPCASE');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.nominated_completion_yr IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'NOMINATED_COMPLETION_YR',
                                                            column_value   => igs_ge_number.to_cann(p_sca_re_rec.nominated_completion_yr));
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_NOM_YR_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.nominated_completion_perd IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'NOMINATED_COMPLETION_PERD',
                                                            column_value   => p_sca_re_rec.nominated_completion_perd);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_NOM_PER_UPPCASE');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.rule_check_ind IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'RULE_CHECK_IND',
                                                            column_value   => p_sca_re_rec.rule_check_ind);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_RUL_IND_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.waive_option_check_ind IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'WAIVE_OPTION_CHECK_IND',
                                                            column_value   => p_sca_re_rec.waive_option_check_ind);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_WAV_IND_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.publish_outcomes_ind IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'PUBLISH_OUTCOMES_IND',
                                                            column_value   => p_sca_re_rec.publish_outcomes_ind);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_PUB_OUT_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.course_rqrmnt_complete_ind IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'COURSE_RQRMNT_COMPLETE_IND',
                                                        column_value   => p_sca_re_rec.course_rqrmnt_complete_ind);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_CRS_RQR_CMP_IND_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.s_completed_source_type IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'S_COMPLETED_SOURCE_TYPE',
                                                        column_value   => p_sca_re_rec.s_completed_source_type);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_SYS_COMP_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.correspondence_cat IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'CORRESPONDENCE_CAT',
                                                        column_value   => p_sca_re_rec.correspondence_cat);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_CORR_CAT_INALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.self_help_group_ind IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'SELF_HELP_GROUP_IND',
                                                            column_value   => p_sca_re_rec.self_help_group_ind);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_HLP_GRP_IND_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.adm_nominated_course_cd IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'ADM_NOMINATED_COURSE_CD',
                                                            column_value   => p_sca_re_rec.adm_nominated_course_cd);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_ADM_NOM_PG_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.manual_ovr_cmpl_dt_ind IS NOT NULL THEN
             BEGIN
                  igs_en_stdnt_ps_att_pkg.check_constraints(column_name    => 'MANUAL_OVR_CMPL_DT_IND',
                                                            column_value   => p_sca_re_rec.manual_ovr_cmpl_dt_ind);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRG_MAN_OVR_IND_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.re_attendance_percentage IS NOT NULL THEN
             BEGIN
                  igs_re_candidature_pkg.check_constraints(column_name    => 'ATTENDANCE_PERCENTAGE',
                                                           column_value   => igs_ge_number.to_cann(p_sca_re_rec.re_attendance_percentage));
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_RE_ATT_PER_INVALID');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF p_sca_re_rec.re_govt_type_of_activity_cd IS NOT NULL THEN
             BEGIN
                  igs_re_candidature_pkg.check_constraints(column_name    => 'GOVT_TYPE_OF_ACTIVITY_CD',
                                                           column_value   => p_sca_re_rec.re_govt_type_of_activity_cd);
             EXCEPTION
                WHEN OTHERS THEN
                        l_message_count := FND_MSG_PUB.COUNT_MSG;
                        FND_MSG_PUB.DELETE_MSG(l_message_count);
                        FND_MESSAGE.SET_NAME('IGS','IGS_RE_GOVT_CD_UPPCASE');
                        FND_MSG_PUB.ADD;
                        l_error_flag  := 'Y';
             END;
     END IF;

     IF l_error_flag  = 'Y' THEN
        RETURN FALSE;
     ELSE
        RETURN TRUE;
     END IF;
END validate_parameters;


FUNCTION validate_sca_db_cons(p_person_id          IN   IGS_PE_PERSON.PERSON_ID%TYPE,
                              p_sca_re_rec         IN   SCA_RE_REC_TYPE)
RETURN VARCHAR2 AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Function validates student program attempt table constraints.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  amuthu          07-JAN-03       Added the validation for Nominated Completion Period
||                                  and correspondence category
------------------------------------------------------------------------------*/
l_result_flag       VARCHAR2(1);
BEGIN  --validate_sca_db_cons

     l_result_flag := 'S';

     --Check whether student program attemt record is already exist in the database or not.
     --If exist set the warning message and terminate the function
     IF igs_en_stdnt_ps_att_pkg.get_pk_for_validation(x_person_id     =>p_person_id,
                                                      x_course_cd     =>p_sca_re_rec.program_cd) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_EN_PS_ATT_EXISTS');
         FND_MSG_PUB.ADD;
         RETURN 'P';
     ELSE
        --Check whether parent record is exist for the relative child record in student program attempt
        IF ( (p_sca_re_rec.adm_admission_appl_number    IS  NOT NULL) OR
             (p_sca_re_rec.adm_nominated_course_cd      IS  NOT NULL ) OR
             (p_sca_re_rec.adm_sequence_number          IS  NOT NULL)) THEN
                IF NOT igs_ad_ps_appl_inst_pkg.get_pk_for_validation(x_person_id             => p_person_id,
                                                                 x_admission_appl_number => p_sca_re_rec.adm_admission_appl_number,
                                                                 x_nominated_course_cd   => p_sca_re_rec.adm_nominated_course_cd,
                                                                 x_sequence_number       => p_sca_re_rec.adm_sequence_number) THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_EN_ADM_APP_DET_NOT_FOUND');
                   FND_MSG_PUB.ADD;
                   l_result_flag := 'E';
                END IF;
        END IF;
        IF p_sca_re_rec.discontinuation_reason_cd IS NOT NULL THEN
                IF NOT igs_en_dcnt_reasoncd_pkg.get_pk_for_validation(x_dcnt_reason_cd  => p_sca_re_rec.discontinuation_reason_cd) THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_EN_DCNT_REAS_NOT_FOUND');
                   FND_MSG_PUB.ADD;
                   l_result_flag := 'E';
                END IF;
        END IF;
        IF p_sca_re_rec.fee_cat IS NOT NULL THEN
                IF NOT igs_fi_fee_cat_pkg.get_pk_for_validation(x_fee_cat   => p_sca_re_rec.fee_cat) THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_EN_FEE_CAT_NOT_FOUND');
                   FND_MSG_PUB.ADD;
                   l_result_flag := 'E';
                END IF;
        END IF;
        IF p_sca_re_rec.funding_source IS NOT NULL THEN
                IF NOT igs_fi_fund_src_pkg.get_pk_for_validation(x_funding_source   => p_sca_re_rec.funding_source) THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_EN_FUND_SRC_NOT_FOUND');
                   FND_MSG_PUB.ADD;
                   l_result_flag := 'E';
                END IF;
        END IF;
        IF p_sca_re_rec.exam_location_cd IS NOT NULL THEN
                IF NOT igs_ad_location_pkg.get_pk_for_validation(x_location_cd   => p_sca_re_rec.exam_location_cd) THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_EN_EXAM_LOC_NOT_FOUND');
                   FND_MSG_PUB.ADD;
                   l_result_flag := 'E';
                END IF;
        END IF;

        IF p_sca_re_rec.NOMINATED_COMPLETION_PERD IS NOT NULL THEN
                IF NOT igs_en_nom_cmpl_prd_pkg.get_pk_for_validation(x_completion_perd => p_sca_re_rec.NOMINATED_COMPLETION_PERD ) THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_EN_NOM_CMPL_PRD_NOT_FOUND');
                   FND_MSG_PUB.ADD;
                   l_result_flag := 'E';
                END IF;
        END IF;

        IF p_sca_re_rec.CORRESPONDENCE_CAT IS NOT NULL THEN
                IF NOT  IGS_CO_CAT_PKG.get_pk_for_validation(x_correspondence_cat  => p_sca_re_rec.CORRESPONDENCE_CAT ) THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_EN_CO_CAT_NOT_FOUND');
                   FND_MSG_PUB.ADD;
                   l_result_flag := 'E';
                END IF;
        END IF;

        IF p_sca_re_rec.primary_prog_type_source IS NOT NULL THEN
                IF NOT igs_lookups_view_pkg.get_pk_for_validation('IGS_EN_PP_SOURCE',p_sca_re_rec.primary_prog_type_source) THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRI_PRG_TYP_NOT_FOUND');
                   FND_MSG_PUB.ADD;
                   l_result_flag := 'E';
                END IF;
        END IF;
        RETURN l_result_flag;
     END IF;
END validate_sca_db_cons;

FUNCTION validate_sca(p_person_id          IN igs_pe_person.person_id%TYPE,
                      p_course_att_status  IN igs_en_stdnt_ps_att_all.course_attempt_status%TYPE,
                      p_course_type        IN igs_ps_ver_all.course_type%TYPE,
                      p_career_flag        IN VARCHAR2,
                      p_sca_re_rec         IN SCA_RE_REC_TYPE)
RETURN BOOLEAN AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Function validates Student program attempt's business validations
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  kkillams        31-12-2002      Bypass the val_sca_primary_pg function call if
||                                  program attempt status is UNCONFIRM w.r.t. bug 2721076
------------------------------------------------------------------------------*/
l_validation_success         BOOLEAN;
l_message                    VARCHAR2(200);
l_boolean                    BOOLEAN;
l_start                      NUMBER(4);
l_end                        NUMBER(4);
BEGIN  --validate_sca
     l_validation_success := TRUE;

     --Validates the person types for this student program attempt
     IF NOT igs_en_gen_legacy.val_sca_per_type(p_person_id             => p_person_id,
                                               p_course_cd             => p_sca_re_rec.program_cd,
                                               p_course_attempt_status => p_course_att_status) THEN
         l_validation_success := FALSE;
     END IF;
     IF NOT igs_en_gen_legacy.val_sca_start_dt(p_student_confirmed_ind => p_sca_re_rec.student_confirmed_ind,
                                               p_commencement_dt       => p_sca_re_rec.commencement_dt) THEN
         l_validation_success := FALSE;
         FND_MESSAGE.SET_NAME('IGS','IGS_EN_SCA_COMM_DT_INVALID');
         FND_MSG_PUB.ADD;
     END IF;

     --Validates the discontinuation of student program attempt.
     IF (p_sca_re_rec.discontinued_dt IS NOT NULL OR p_sca_re_rec.discontinuation_reason_cd IS NOT NULL) THEN
             l_message := NULL;
             l_boolean := NULL;
             l_boolean:=igs_en_val_sca.enrp_val_sca_discont(p_person_id                  => p_person_id,
                                                            p_course_cd                  => p_sca_re_rec.program_cd,
                                                            p_version_number             => p_sca_re_rec.version_number,
                                                            p_course_attempt_status      => p_course_att_status,
                                                            p_discontinuation_reason_cd  => p_sca_re_rec.discontinuation_reason_cd,
                                                            p_discontinued_dt            => p_sca_re_rec.discontinued_dt,
                                                            p_commencement_dt            => p_sca_re_rec.commencement_dt,
                                                            p_message_name               => l_message,
                                                            p_legacy                     => 'Y');
             IF l_message IS NOT NULL THEN
                 l_validation_success := FALSE;
             END IF;
     END IF;

     --Validating the lapse date aganist program attempt status.
     IF p_sca_re_rec.lapsed_dt IS NOT NULL THEN
             l_message := NULL;
             l_boolean := NULL;
             l_boolean:=igs_en_val_sca.enrp_val_sca_lapse (p_course_attempt_status => p_course_att_status,
                                                           p_lapse_dt              => p_sca_re_rec.lapsed_dt,
                                                           p_message_name          => l_message,
                                                           p_legacy                => 'Y');

             IF l_message IS NOT NULL THEN
                 l_validation_success := FALSE;
             END IF;
     END IF;
     IF p_sca_re_rec.discontinued_dt IS NOT NULL THEN
             IF NOT igs_en_gen_legacy.val_sca_disc_date(p_discontinued_dt => p_sca_re_rec.discontinued_dt) THEN
                 l_validation_success := FALSE;
                 FND_MESSAGE.SET_NAME('IGS','IGS_EN_SCA_DISC_DT_NOT_FUTURE');
                 FND_MSG_PUB.ADD;
             END IF;
     END IF;

     IF NOT igs_en_gen_legacy.val_sca_comp_flag(p_course_attempt_status       => p_course_att_status,
                                                p_course_rqrmnt_complete_ind  => p_sca_re_rec.course_rqrmnt_complete_ind) THEN
         l_validation_success := FALSE;
         FND_MESSAGE.SET_NAME('IGS','IGS_PR_CANNOT_SET_COMPL_IND');
         FND_MSG_PUB.ADD;
     END IF;

     --Validating the Discountinue date aganist Requirement completion indicatory.
     IF p_sca_re_rec.discontinued_dt IS NOT NULL AND p_sca_re_rec.course_rqrmnt_complete_ind IS NOT NULL THEN
             IF  p_sca_re_rec.course_rqrmnt_complete_ind ='Y' THEN
                 l_validation_success := FALSE;
                 FND_MESSAGE.SET_NAME('IGS','IGS_EN_ONLY_SPA_ST_ENROLLED');
                 FND_MSG_PUB.ADD;
             END IF;
     END IF;

     --Validating requirement completion date aganist commencement date.
     IF p_sca_re_rec.course_rqrmnts_complete_dt IS NOT NULL THEN
             l_message := NULL;
             l_boolean := NULL;
             l_boolean:=igs_pr_val_sca.prgp_val_sca_cmpl_dt(p_person_id                  => p_person_id,
                                                            p_course_cd                  => p_sca_re_rec.program_cd,
                                                            p_commencement_dt            => p_sca_re_rec.commencement_dt,
                                                            p_course_rqrmnts_complete_dt => p_sca_re_rec.course_rqrmnts_complete_dt,
                                                            p_message_name               => l_message,
                                                            p_legacy                     => 'Y');
             IF l_message IS NOT NULL THEN
                 l_validation_success := FALSE;
                 IF INSTR(l_message,'*') = 0 THEN
                    FND_MESSAGE.SET_NAME('IGS',l_message);
                    FND_MSG_PUB.ADD;
                 ELSE
                    l_start := 1;
                    LOOP
                        l_end:= INSTR(l_message,'*',l_start);
                        IF l_end = 0 THEN
                             FND_MESSAGE.SET_NAME('IGS',SUBSTR(l_message,l_start,LENGTH(l_message)-l_start+1));
                             FND_MSG_PUB.ADD;
                             EXIT;
                        ELSE
                             FND_MESSAGE.SET_NAME('IGS',SUBSTR(l_message,l_start,l_end-l_start));
                             FND_MSG_PUB.ADD;
                        END IF;
                        l_start :=l_end +1;
                    END LOOP;
                 END IF;
             END IF;
     END IF;

     l_message := NULL;
     IF NOT igs_en_gen_legacy.val_sca_reqcmpl_dt(p_course_rqrmnt_comp_ind => p_sca_re_rec.course_rqrmnt_complete_ind,
                                                 p_course_rqrmnts_comp_dt => p_sca_re_rec.course_rqrmnts_complete_dt,
                                                 p_message_name           => l_message) THEN
         l_validation_success := FALSE;
         FND_MESSAGE.SET_NAME('IGS',l_message);
         FND_MSG_PUB.ADD;
     END IF;

     --In career mode, validating the primary program of the student program attempt.
     IF (p_career_flag = 'Y') AND (p_course_att_status <> 'UNCONFIRM') THEN
             IF NOT igs_en_gen_legacy.val_sca_primary_pg(p_person_id          =>p_person_id,
                                                         p_primary_prog_type  =>p_sca_re_rec.primary_program_type,
                                                         P_course_type        =>p_course_type) THEN
                 l_validation_success := FALSE;
             END IF;
     END IF;
     IF NOT igs_en_gen_legacy.val_sca_key_prg(p_person_id          => p_person_id,
                                              p_course_cd          => p_sca_re_rec.program_cd,
                                              p_key_program        => p_sca_re_rec.key_program,
                                              p_primary_prg_type   => p_sca_re_rec.primary_program_type,
                                              p_course_attempt_st  => p_course_att_status,
                                              p_career_flag        => p_career_flag) THEN
         l_validation_success := FALSE;
     END IF;
     RETURN l_validation_success;
END validate_sca;

FUNCTION validate_re_db_cons(p_person_id          IN   IGS_PE_PERSON.PERSON_ID%TYPE,
                             p_sca_re_rec         IN   SCA_RE_REC_TYPE)
RETURN VARCHAR2 AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Function validates Research candidature table constraints.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  amuthu          07-JAN-03       Changed the message IGS_EN_DCNT_REAS_NOT_FOUND
||                                  to IGS_RE_GOV_ACT_CD_NOT_FOUND govt activity
||                                  code validation
------------------------------------------------------------------------------*/
l_result_flag       VARCHAR2(1);
l_count            NUMBER(3);
BEGIN  --validate_re_db_cons
      l_result_flag := 'S';
       --Check whether research candidature record is already exist in the database or not.
       --If exist set the warning message and terminate the function
        BEGIN
            igs_re_candidature_pkg.get_fk_igs_en_stdnt_ps_att(x_person_id     =>p_person_id,
                                                              x_course_cd     =>p_sca_re_rec.program_cd);
        EXCEPTION
            WHEN OTHERS THEN
                    l_count :=FND_MSG_PUB.COUNT_MSG;
                    FND_MSG_PUB.DELETE_MSG(l_count);
                    FND_MESSAGE.SET_NAME('IGS','IGS_RE_CAND_EXIST');
                    FND_MSG_PUB.ADD;
                    RETURN 'P';
        END;
        --Check whether parent record is exist for the relative child record in student program attempt
        IF ( (p_sca_re_rec.adm_admission_appl_number    IS  NOT NULL) OR
             (p_sca_re_rec.adm_nominated_course_cd      IS  NOT NULL ) OR
             (p_sca_re_rec.adm_sequence_number          IS  NOT NULL)) THEN
                IF NOT igs_ad_ps_appl_inst_pkg.get_pk_for_validation(x_person_id             => p_person_id,
                                                                 x_admission_appl_number => p_sca_re_rec.adm_admission_appl_number,
                                                                 x_nominated_course_cd   => p_sca_re_rec.adm_nominated_course_cd,
                                                                 x_sequence_number       => p_sca_re_rec.adm_sequence_number) THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_EN_ADM_APP_DET_NOT_FOUND');
                   FND_MSG_PUB.ADD;
                   l_result_flag := 'E';
                END IF;
        END IF;
        IF p_sca_re_rec.re_govt_type_of_activity_cd IS NOT NULL THEN
                IF NOT igs_re_gv_toa_cls_cd_pkg.get_pk_for_validation(x_govt_toa_class_cd      => p_sca_re_rec.re_govt_type_of_activity_cd) THEN
                   FND_MESSAGE.SET_NAME('IGS','IGS_RE_GOV_ACT_CD_NOT_FOUND');
                   FND_MSG_PUB.ADD;
                   l_result_flag := 'E';
                END IF;
        END IF;
        RETURN l_result_flag;
END validate_re_db_cons;
FUNCTION validate_re (p_person_id          IN igs_pe_person.person_id%TYPE,
                      p_sca_re_rec         IN SCA_RE_REC_TYPE)
RETURN BOOLEAN AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose : Function validates research candidature business validations
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
------------------------------------------------------------------------------*/
l_validation_success         BOOLEAN;
l_message_name               VARCHAR2(100);
l_boolean                    BOOLEAN;
BEGIN --validate_re

     l_validation_success := TRUE;

     l_message_name := NULL;
     l_boolean:= NULL;
     l_boolean := igs_re_val_ca.resp_val_ca_minsbmsn(p_person_id                  => p_person_id,
                                                     p_sca_course_cd              => p_sca_re_rec.program_cd,
                                                     p_acai_admission_appl_number => p_sca_re_rec.adm_admission_appl_number,
                                                     p_acai_nominated_course_cd   => p_sca_re_rec.adm_nominated_course_cd,
                                                     p_acai_sequence_number       => p_sca_re_rec.adm_sequence_number,
                                                     p_min_submission_dt          => p_sca_re_rec.re_min_submission_dt,
                                                     p_max_submission_dt          => p_sca_re_rec.re_max_submission_dt,
                                                     p_attendance_percentage      => p_sca_re_rec.re_attendance_percentage,
                                                     p_commencement_dt            => NULL,
                                                     p_message_name               => l_message_name,
                                                     p_legacy                     => 'Y');
     IF l_message_name IS NOT NULL THEN
        l_validation_success := FALSE;
     END IF;

     l_message_name := NULL;
     l_boolean:= NULL;
     l_boolean := igs_re_val_ca.resp_val_ca_maxsbmsn(p_person_id                  => p_person_id,
                                                     p_sca_course_cd              => p_sca_re_rec.program_cd,
                                                     p_acai_admission_appl_number => p_sca_re_rec.adm_admission_appl_number,
                                                     p_acai_nominated_course_cd   => p_sca_re_rec.adm_nominated_course_cd,
                                                     p_acai_sequence_number       => p_sca_re_rec.adm_sequence_number,
                                                     p_min_submission_dt          => p_sca_re_rec.re_min_submission_dt,
                                                     p_max_submission_dt          => p_sca_re_rec.re_max_submission_dt,
                                                     p_attendance_percentage      => p_sca_re_rec.re_attendance_percentage,
                                                     p_commencement_dt            => NULL,
                                                     p_message_name               => l_message_name,
                                                     p_legacy                     => 'Y');
     IF l_message_name IS NOT NULL THEN
        l_validation_success := FALSE;
     END IF;

     l_message_name := NULL;
     l_boolean:= NULL;
     l_boolean := igs_re_val_ca.resp_val_ca_topic (p_person_id                  => p_person_id,
                                                   p_sca_course_cd              => p_sca_re_rec.program_cd,
                                                   p_acai_admission_appl_number => p_sca_re_rec.adm_admission_appl_number,
                                                   p_acai_nominated_course_cd   => p_sca_re_rec.adm_nominated_course_cd,
                                                   p_acai_sequence_number       => p_sca_re_rec.adm_sequence_number,
                                                   p_research_topic             => p_sca_re_rec.re_research_topic,
                                                   p_message_name               => l_message_name,
                                                   p_legacy                     => 'Y');
     IF l_message_name IS NOT NULL THEN
        l_validation_success := FALSE;
     END IF;

     RETURN l_validation_success;
END validate_re;

PROCEDURE create_spa(
                      p_api_version        IN          NUMBER,
                      p_init_msg_list      IN          VARCHAR2,
                      p_commit             IN          VARCHAR2,
                      p_validation_level   IN          NUMBER,
                      p_sca_re_rec         IN          SCA_RE_REC_TYPE,
                      x_return_status      OUT NOCOPY  VARCHAR2,
                      x_msg_count          OUT NOCOPY  NUMBER,
                      x_msg_data           OUT NOCOPY  VARCHAR2) AS
/*----------------------------------------------------------------------------
||  Created By : kkillams
||  Created On : 08-11-2002
||  Purpose :
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  kkillams        13-12-2002      Added if clause to check catalog_cal_alternate_code value
||                                  before calling the igs_ge_gen_003.get_calendar_instance procedure
||                                  w.r.t. bug 2708628.
||  kkillams        19-12-2002      Added new validation before processing the candidature record,
||                                  which checks the context program is a research program or not and
||                                  any research interface columns having values or not w.r.t. bug 2715207.
||  kkillams        27-12-2002      Modified default setting of KEY PROGRAM attribute,
||                                  if key program is null then set the key program to 'N'
||                                  w.r.t. bug no: 2708532.
|| bdeviset         16-DEC-2004     Passing the value of future dated transfer flag as 'N' when
||                                  the IGS_EN_STDNT_PS_ATT.INSERT_ROW is called.Bug# 4071165
------------------------------------------------------------------------------*/

l_api_name                CONSTANT    VARCHAR2(30) := 'create_spa';
l_api_version             CONSTANT    NUMBER       := 1.0;

--Cursor to get the research details for a program type
CURSOR cur_re_prg(p_prg_type igs_ps_type.course_type%TYPE) IS
SELECT research_type_ind FROM igs_ps_type
                         WHERE course_type = p_prg_type;
--Cursor is to get the sequence number for the candidature.
CURSOR cur_re_seq IS SELECT igs_re_candidature_seq_num_s.NEXTVAL FROM DUAL;

--local variables for flags
l_err_derive_flag         VARCHAR2(1);
l_execution_flag1         VARCHAR2(1);
l_execution_flag2         VARCHAR2(1);
l_err_flag                VARCHAR2(1);

--local variable to hold derived values.
l_career_flag             VARCHAR2(1);
l_person_id               igs_pe_person.person_id%TYPE;
l_course_type             igs_ps_ver_all.course_type%TYPE;
l_coo_id                  igs_ps_ofr_opt_all.coo_id%TYPE;
l_course_att_status       igs_en_stdnt_ps_att_all.course_attempt_status%TYPE;
l_igs_pr_class_std_id     igs_en_stdnt_ps_att_all.igs_pr_class_std_id%TYPE;
l_catalog_cal_type        igs_en_stdnt_ps_att_all.catalog_cal_type%TYPE;
l_catalog_seq_num         igs_en_stdnt_ps_att_all.catalog_seq_num%TYPE;
l_dropped_by              igs_en_stdnt_ps_att_all.dropped_by%TYPE;
l_catalog_start_dt        DATE;
l_catalog_end_dt          DATE;
l_sequence_number         igs_re_candidature_all.sequence_number%TYPE;
l_status                  VARCHAR2(20);
l_sca_re_rec              SCA_RE_REC_TYPE;
l_request_id              igs_en_stdnt_ps_att_all.request_id%TYPE;
l_program_id              igs_en_stdnt_ps_att_all.program_id%TYPE;
l_program_application_id  igs_en_stdnt_ps_att_all.program_application_id%TYPE;
l_program_update_date     igs_en_stdnt_ps_att_all.program_update_date%TYPE;
l_research_type_ind       igs_ps_type.research_type_ind%TYPE;

BEGIN  --Begin of create_spa

    --Save point for whole procedure.
    SAVEPOINT create_spa;

    -- Check for the Compatible API call
    IF NOT FND_API.COMPATIBLE_API_CALL(  l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         g_pkg_name) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If the calling program has passed the parameter for initializing the message list
    IF FND_API.TO_BOOLEAN(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

     --Assign the parameter record type to local record type.
     l_sca_re_rec  := p_sca_re_rec;

     -- Set the return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     --Derive the concurrent program who column values.
     l_request_id := fnd_global.conc_request_id;
     l_program_id := fnd_global.conc_program_id;
     l_program_application_id := fnd_global.prog_appl_id;
     IF (l_request_id = -1) THEN
        l_request_id := NULL;
        l_program_id := NULL;
        l_program_application_id := NULL;
        l_program_update_date := NULL;
     ELSE
        l_PROGRAM_UPDATE_DATE := SYSDATE;
     END IF;

     --Set the default values if no value is passed.
     IF  l_sca_re_rec.student_confirmed_ind IS NULL THEN
          l_sca_re_rec.student_confirmed_ind := 'Y';
     END IF;
     IF  l_sca_re_rec.key_program IS NULL THEN
         l_sca_re_rec.key_program:='N';
     END IF;
     IF  l_sca_re_rec.provisional_ind IS NULL THEN
         l_sca_re_rec.provisional_ind:='N';
     END IF;
     IF  l_sca_re_rec.rule_check_ind IS NULL THEN
         l_sca_re_rec.rule_check_ind:='Y';
     END IF;
     IF  l_sca_re_rec.waive_option_check_ind IS NULL THEN
         l_sca_re_rec.waive_option_check_ind := 'N';
     END IF;
     IF  l_sca_re_rec.publish_outcomes_ind IS NULL THEN
         l_sca_re_rec.publish_outcomes_ind:= 'Y';
     END IF;
     IF  l_sca_re_rec.course_rqrmnt_complete_ind IS NULL THEN
         l_sca_re_rec.course_rqrmnt_complete_ind:= 'N';
     END IF;
     IF  l_sca_re_rec.advanced_standing_ind IS NULL THEN
         l_sca_re_rec.advanced_standing_ind:= 'N';
     END IF;
     IF  l_sca_re_rec.self_help_group_ind IS NULL THEN
         l_sca_re_rec.self_help_group_ind := 'N';
     END IF;
     IF  l_sca_re_rec.manual_ovr_cmpl_dt_ind IS NULL THEN
         l_sca_re_rec.manual_ovr_cmpl_dt_ind:= 'N';
     END IF;

     --Check career model flag is checked or not.
     l_career_flag:= NVL(fnd_profile.value('CAREER_MODEL_ENABLED'),'N');

     --Set the error flag.
     l_err_flag := 'N';

     --Validate parameter function is to validate the function input parameters.
     IF NOT validate_parameters(l_sca_re_rec,l_career_flag) THEN
        l_err_flag := 'Y';
     END IF;


     IF l_err_flag <> 'Y' THEN
         ---Derive the required values, to do futher validations.
         --deriving the person identifier value.
         l_person_id :=igs_ge_gen_003.get_person_id(l_sca_re_rec.person_number);
         IF l_person_id IS NULL THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_PERSON_NUMBER');
            FND_MSG_PUB.ADD;
            l_err_flag := 'Y';
         END IF;

         --deriving the course type.
         l_course_type:=igs_en_gen_legacy.get_sca_prog_type(l_sca_re_rec.program_cd,l_sca_re_rec.version_number);
         IF l_course_type IS NULL THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_EN_PROG_TYPE_NOT_FOUND');
            FND_MSG_PUB.ADD;
            l_err_flag := 'Y';
         END IF;

         --deriving the program offering option identifier.
         l_coo_id:=igs_en_gen_legacy.get_coo_id(p_course_cd       =>l_sca_re_rec.program_cd,
                                                p_version_number  =>l_sca_re_rec.version_number,
                                                p_cal_type        =>l_sca_re_rec.cal_type,
                                                p_location_cd     =>l_sca_re_rec.location_cd,
                                                p_attendance_mode =>l_sca_re_rec.attendance_mode,
                                                p_attendance_type =>l_sca_re_rec.attendance_type);
         IF l_coo_id IS NULL THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_EN_PS_OFR_OPT_NOT_FOUND');
            FND_MSG_PUB.ADD;
            l_err_flag := 'Y';
         END IF;

         --deriving the program attempt status for the current student program attempt.
         l_course_att_status:=igs_en_gen_legacy.get_course_att_status(p_person_id                     =>l_person_id,
                                                                      p_course_cd                     =>l_sca_re_rec.program_cd,
                                                                      p_student_confirmed_ind         =>l_sca_re_rec.student_confirmed_ind,
                                                                      p_discontinued_dt               =>l_sca_re_rec.discontinued_dt,
                                                                      p_lapsed_dt                     =>l_sca_re_rec.lapsed_dt,
                                                                      p_course_rqrmnt_complete_ind    =>l_sca_re_rec.course_rqrmnt_complete_ind,
                                                                      p_primary_pg_type               =>l_sca_re_rec.primary_program_type,
                                                                      p_primary_prog_type_source      =>l_sca_re_rec.primary_prog_type_source,
                                                                      p_course_type                   =>l_course_type,
                                                                      p_career_flag                   =>l_career_flag);
         IF l_course_att_status IS NULL THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_EN_COURSE_ATT_NOT_FOUND');
            FND_MSG_PUB.ADD;
            l_err_flag := 'Y';
         END IF;
         --deriving the class standing identifier.
         IF l_sca_re_rec.class_standing_override IS NOT NULL THEN
                 l_igs_pr_class_std_id:=igs_en_gen_legacy.get_class_std_id(p_class_standing        =>l_sca_re_rec.class_standing_override );
                 IF l_igs_pr_class_std_id IS NULL THEN
                    FND_MESSAGE.SET_NAME('IGS','IGS_EN_CLASS_STD_ID_NOT_FOUND');
                     FND_MSG_PUB.ADD;
                    l_err_flag := 'Y';
                 END IF;
         END IF;

         --deriving the staff person to populate the dropped column.
         l_dropped_by:=igs_en_gen_legacy.get_sca_dropped_by();
         IF l_dropped_by IS NULL THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_EN_DROPPED_BY_NOT_FOUND');
            FND_MSG_PUB.ADD;
         END IF;
         IF l_sca_re_rec.catalog_cal_alternate_code IS NOT NULL THEN
                 --deriving the catalog calendar details for a given catalog alternate code.
                 igs_ge_gen_003.get_calendar_instance(p_alternate_cd        =>l_sca_re_rec.catalog_cal_alternate_code,
                                                      p_s_cal_category      =>'''LOAD'',''ACADEMIC''',
                                                      p_cal_type            =>l_catalog_cal_type,
                                                      p_ci_sequence_number  =>l_catalog_seq_num,
                                                      p_start_dt            =>l_catalog_start_dt,
                                                      p_end_dt              =>l_catalog_end_dt,
                                                      p_return_status       =>l_status);
                 IF l_status = 'MULTIPLE' THEN
                    FND_MESSAGE.SET_NAME('IGS','IGS_EN_MORE_CAL_FOUND');
                    FND_MSG_PUB.ADD;
                    l_err_flag := 'Y';
                 ELSIF l_status = 'INVALID' THEN
                    FND_MESSAGE.SET_NAME('IGS','IGS_EN_NO_ACAD_TERM_CAL');
                    FND_MSG_PUB.ADD;
                    l_err_flag := 'Y';
                END IF;
         END IF;
     END IF; --l_err_flag

     --If no error found in the above validation then only do further validation else terminate process.
     IF l_err_flag <> 'Y' THEN
             l_execution_flag1 := NULL;
             l_execution_flag2 := NULL;
             --Validates the student program attempt database constarits.
             --Function will returns S,E,P
             l_execution_flag1:=validate_sca_db_cons (p_person_id      => l_person_id,
                                                      p_sca_re_rec     => l_sca_re_rec);
             --If all validation passed then call the validate_sca which will validates the all business rules
             IF l_execution_flag1 = 'S' THEN
                IF NOT validate_sca(p_person_id         => l_person_id,
                                    p_course_att_status => l_course_att_status,
                                    p_course_type       => l_course_type,
                                    p_career_flag       => l_career_flag,
                                    p_sca_re_rec        => l_sca_re_rec) THEN
                   l_execution_flag1 := 'E';
                END IF;
             END IF;

             --Inserting the Student program attempt
             IF l_execution_flag1 ='S' THEN
              --Note:Following columns are not populating as they are obsoleted in the data model
              --     derived_att_mode, derived_att_type, logical_delete_dt, derived_completion_yr,
              --     derived_completiod_perd, override_time_limitation
              --     progression_status and last_date_of_attendance column would be derived while improting the unit atttempt details.
                 INSERT INTO igs_en_stdnt_ps_att_all(
                                                     person_id,
                                                     course_cd,
                                                     version_number,
                                                     cal_type,
                                                     location_cd,
                                                     attendance_mode,
                                                     attendance_type,
                                                     coo_id,
                                                     student_confirmed_ind,
                                                     commencement_dt,
                                                     course_attempt_status,
                                                     progression_status,
                                                     derived_att_type,
                                                     derived_att_mode,
                                                     provisional_ind,
                                                     discontinued_dt,
                                                     discontinuation_reason_cd,
                                                     lapsed_dt,
                                                     funding_source,
                                                     exam_location_cd,
                                                     derived_completion_yr,
                                                     derived_completion_perd,
                                                     nominated_completion_yr,
                                                     nominated_completion_perd,
                                                     rule_check_ind,
                                                     waive_option_check_ind,
                                                     last_rule_check_dt,
                                                     publish_outcomes_ind,
                                                     course_rqrmnt_complete_ind,
                                                     course_rqrmnts_complete_dt,
                                                     s_completed_source_type,
                                                     override_time_limitation,
                                                     advanced_standing_ind,
                                                     fee_cat,
                                                     correspondence_cat,
                                                     self_help_group_ind,
                                                     logical_delete_dt,
                                                     adm_admission_appl_number,
                                                     adm_nominated_course_cd,
                                                     adm_sequence_number,
                                                     igs_pr_class_std_id,
                                                     last_date_of_attendance,
                                                     dropped_by,
                                                     primary_program_type,
                                                     primary_prog_type_source,
                                                     catalog_cal_type,
                                                     catalog_seq_num,
                                                     key_program,
                                                     override_cmpl_dt,
                                                     manual_ovr_cmpl_dt_ind,
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
                                                     created_by,
                                                     creation_date,
                                                     last_updated_by,
                                                     last_update_date,
                                                     last_update_login,
                                                     request_id,
                                                     program_application_id,
                                                     program_id,
                                                     program_update_date,
                                                     org_id,
                                                     future_dated_trans_flag)
                                                     VALUES (        l_person_id,
                                                                     l_sca_re_rec.program_cd,
                                                                     l_sca_re_rec.version_number,
                                                                     l_sca_re_rec.cal_type,
                                                                     l_sca_re_rec.location_cd,
                                                                     l_sca_re_rec.attendance_mode,
                                                                     l_sca_re_rec.attendance_type,
                                                                     l_coo_id,
                                                                     l_sca_re_rec.student_confirmed_ind,
                                                                     l_sca_re_rec.commencement_dt,
                                                                     l_course_att_status,
                                                                     NULL,
                                                                     NULL,
                                                                     NULL,
                                                                     l_sca_re_rec.provisional_ind,
                                                                     l_sca_re_rec.discontinued_dt,
                                                                     l_sca_re_rec.discontinuation_reason_cd,
                                                                     l_sca_re_rec.lapsed_dt,
                                                                     l_sca_re_rec.funding_source,
                                                                     l_sca_re_rec.exam_location_cd,
                                                                     NULL,
                                                                     NULL,
                                                                     l_sca_re_rec.nominated_completion_yr,
                                                                     l_sca_re_rec.nominated_completion_perd,
                                                                     l_sca_re_rec.rule_check_ind,
                                                                     l_sca_re_rec.waive_option_check_ind,
                                                                     l_sca_re_rec.last_rule_check_dt,
                                                                     l_sca_re_rec.publish_outcomes_ind,
                                                                     l_sca_re_rec.course_rqrmnt_complete_ind,
                                                                     l_sca_re_rec.course_rqrmnts_complete_dt,
                                                                     l_sca_re_rec.s_completed_source_type,
                                                                     NULL,
                                                                     l_sca_re_rec.advanced_standing_ind,
                                                                     l_sca_re_rec.fee_cat,
                                                                     l_sca_re_rec.correspondence_cat,
                                                                     l_sca_re_rec.self_help_group_ind,
                                                                     NULL,
                                                                     l_sca_re_rec.adm_admission_appl_number,
                                                                     l_sca_re_rec.adm_nominated_course_cd,
                                                                     l_sca_re_rec.adm_sequence_number,
                                                                     l_igs_pr_class_std_id,
                                                                     NULL,
                                                                     l_dropped_by,
                                                                     l_sca_re_rec.primary_program_type,
                                                                     l_sca_re_rec.primary_prog_type_source,
                                                                     l_catalog_cal_type,
                                                                     l_catalog_seq_num,
                                                                     l_sca_re_rec.key_program,
                                                                     l_sca_re_rec.override_cmpl_dt,
                                                                     l_sca_re_rec.manual_ovr_cmpl_dt_ind,
                                                                     l_sca_re_rec.attribute_category,
                                                                     l_sca_re_rec.attribute1,
                                                                     l_sca_re_rec.attribute2,
                                                                     l_sca_re_rec.attribute3,
                                                                     l_sca_re_rec.attribute4,
                                                                     l_sca_re_rec.attribute5,
                                                                     l_sca_re_rec.attribute6,
                                                                     l_sca_re_rec.attribute7,
                                                                     l_sca_re_rec.attribute8,
                                                                     l_sca_re_rec.attribute9,
                                                                     l_sca_re_rec.attribute10,
                                                                     l_sca_re_rec.attribute11,
                                                                     l_sca_re_rec.attribute12,
                                                                     l_sca_re_rec.attribute13,
                                                                     l_sca_re_rec.attribute14,
                                                                     l_sca_re_rec.attribute15,
                                                                     l_sca_re_rec.attribute16,
                                                                     l_sca_re_rec.attribute17,
                                                                     l_sca_re_rec.attribute18,
                                                                     l_sca_re_rec.attribute19,
                                                                     l_sca_re_rec.attribute20,
                                                                     NVL(FND_GLOBAL.USER_ID,-1),
                                                                     SYSDATE,
                                                                     NVL(FND_GLOBAL.USER_ID,-1),
                                                                     SYSDATE,
                                                                     NVL(FND_GLOBAL.LOGIN_ID,-1),
                                                                     l_request_id,
                                                                     l_program_application_id,
                                                                     l_program_id,
                                                                     l_program_update_date,
                                                                     igs_ge_gen_003.get_org_id,
                                                                     'N');
             END IF;  ---l_execution_flag1 ='S'
             --Check the context program is type research candidature.
             l_research_type_ind := 'N';
             OPEN cur_re_prg(l_course_type);
             FETCH cur_re_prg INTO l_research_type_ind;
             CLOSE cur_re_prg;

             IF l_execution_flag1 IN ('S','P') AND
                ((l_sca_re_rec.re_attendance_percentage IS NOT NULL) OR (l_sca_re_rec.re_govt_type_of_activity_cd IS NOT NULL) OR
                  (l_sca_re_rec.re_max_submission_dt IS NOT NULL) OR (l_sca_re_rec.re_min_submission_dt IS NOT NULL) OR
                  (l_sca_re_rec.re_research_topic IS NOT NULL) OR (l_sca_re_rec.re_industry_links IS NOT NULL) OR (l_research_type_ind = 'Y')
                 ) THEN
                     --Validates the student program attempt database constarits.
                     l_execution_flag2:=validate_re_db_cons (p_person_id      => l_person_id,
                                                             p_sca_re_rec     => l_sca_re_rec);
                     IF l_execution_flag2 = 'S' THEN
                        IF NOT validate_re(p_person_id         => l_person_id,
                                           p_sca_re_rec        => l_sca_re_rec) THEN
                           l_execution_flag2 := 'E';
                        END IF;
                     END IF; --l_execution_flag2 ='S'
                     --Inserting the Research Candidature.
                     IF l_execution_flag2 ='S' THEN
                        --Get the sequence number for research candidature.
                        l_sequence_number:= NULL;
                        OPEN cur_re_seq;
                        FETCH cur_re_seq INTO l_sequence_number;
                        CLOSE cur_re_seq;
                        INSERT INTO igs_re_candidature_all(person_id,
                                                           sequence_number,
                                                           sca_course_cd,
                                                           acai_admission_appl_number,
                                                           acai_nominated_course_cd,
                                                           acai_sequence_number,
                                                           attendance_percentage,
                                                           govt_type_of_activity_cd,
                                                           max_submission_dt,
                                                           min_submission_dt,
                                                           research_topic,
                                                           industry_links,
                                                           created_by,
                                                           creation_date,
                                                           last_updated_by,
                                                           last_update_date,
                                                           last_update_login,
                                                           request_id,
                                                           program_application_id,
                                                           program_id,
                                                           program_update_date,
                                                           org_id) VALUES(
                                                                          l_person_id,
                                                                          l_sequence_number,
                                                                          l_sca_re_rec.program_cd,
                                                                          l_sca_re_rec.adm_admission_appl_number,
                                                                          l_sca_re_rec.adm_nominated_course_cd,
                                                                          l_sca_re_rec.adm_sequence_number,
                                                                          l_sca_re_rec.re_attendance_percentage,
                                                                          l_sca_re_rec.re_govt_type_of_activity_cd,
                                                                          l_sca_re_rec.re_max_submission_dt,
                                                                          l_sca_re_rec.re_min_submission_dt,
                                                                          l_sca_re_rec.re_research_topic,
                                                                          l_sca_re_rec.re_industry_links,
                                                                          NVL(FND_GLOBAL.USER_ID,-1),
                                                                          SYSDATE,
                                                                          NVL(FND_GLOBAL.USER_ID,-1),
                                                                          SYSDATE,
                                                                          NVL(FND_GLOBAL.LOGIN_ID,-1),
                                                                          l_request_id,
                                                                          l_program_application_id,
                                                                          l_program_id,
                                                                          l_program_update_date,
                                                                          igs_ge_gen_003.get_org_id);
                END IF; --l_execution_flag2 ='S'
             END IF;  --l_execution_flag1 IN ('S','P')
     END IF;  ---l_err_flag <> 'Y'
     IF ((l_err_flag ='Y') OR
           (l_execution_flag1 ='E') OR
           (l_execution_flag2 ='E')) THEN
           ROLLBACK TO create_spa;
           x_return_status := FND_API.G_RET_STS_ERROR;
     ELSIF ((l_execution_flag1 = 'P') AND (l_execution_flag2 IS NULL)) OR
           ((l_execution_flag1 = 'P') AND (l_execution_flag2 ='P')) THEN
              x_return_status := 'W';
     ELSE
           IF FND_API.TO_BOOLEAN(p_commit) THEN
                    COMMIT WORK;
           END IF;
           x_return_status := FND_API.G_RET_STS_SUCCESS;
     END IF;
     FND_MSG_PUB.COUNT_AND_GET( p_count   => x_msg_count,
                                p_data    => x_msg_data);
  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO create_spa;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO create_spa;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO create_spa;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.ADD_Exc_Msg(g_pkg_name,
                                    l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count          => x_msg_count,
                                     p_data           => x_msg_data);
END create_spa;
END igs_en_spa_lgcy_pub;

/
