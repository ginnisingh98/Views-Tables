--------------------------------------------------------
--  DDL for Package Body IGS_EN_SUA_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SUA_LGCY_PUB" AS
/* $Header: IGSENA4B.pls 120.15 2006/08/11 09:35:31 smaddali ship $ */


    g_pkg_name              CONSTANT VARCHAR2(30) := 'IGS_EN_SUA_LGCY_PUB';
    g_sua_status            VARCHAR2(10) := 'VALID';
    g_wlst_pri_pref_exists  BOOLEAN :=FALSE;

PROCEDURE validate_parameters(p_sua_dtls_rec   IN   sua_dtls_rec_type) AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : This routine validates the parameters that are being passed to the insert API.
                    It Checks for Mandatory Parameters and Check constraints. While making a call to the
                    Check_constraints routine of the TBH , it is possible to encounter an Exception if the
                    validation fails.So, calls to check_constraint routines are handled gracefully within
                    blocks.If an error is encountered , the Check_cons routine adds the generic message
                    IGS_GE_INVALID_VALUE to the stack , and then raises the Exception. So , in the Insert
                    API Exception section, generic message 'IGS_GE_INVALID_VALUE' is deleted from the Stack
                    and a more specific message is added , if required.
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
------------------------------------------------------------------*/

    -- Cursor to fetch parameter for querying label GRADE
    CURSOR get_grade IS
    SELECT message_text
    FROM fnd_new_messages
    WHERE message_name = 'IGS_EN_GRADE' ;

    -- Declare local variables and initialise parameters.
    l_msg_count         NUMBER ;
    l_msg_data          VARCHAR2(2000);
    l_grade_msg     FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;

BEGIN

    -- Person Number is Mandatory
    IF p_sua_dtls_rec.person_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PER_NUM_NULL');
        FND_MSG_PUB.Add;
        g_sua_status := 'INVALID';
    END IF;

    -- Program Code is Mandatory
    IF p_sua_dtls_rec.program_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_CD_NULL');
        FND_MSG_PUB.Add;
        g_sua_status := 'INVALID';
    END IF;

    -- Unit Code is Mandatory
    IF p_sua_dtls_rec.unit_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_UNITCD_SPECIFIED');
        FND_MSG_PUB.Add;
        g_sua_status := 'INVALID';
    END IF;

    -- Calendar Alternate Code is Mandatory
    IF p_sua_dtls_rec.teach_calendar_alternate_code IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_CAL_TYP_NULL');
        FND_MSG_PUB.Add;
        g_sua_status := 'INVALID';
    END IF;

    -- Location Code is Mandatory
    IF p_sua_dtls_rec.location_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_LOC_CD_NULL');
        FND_MSG_PUB.Add;
        g_sua_status := 'INVALID';
    END IF;

    -- Unit Class is Mandatory
    IF p_sua_dtls_rec.unit_class IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_UNT_CLS_NULL');
        FND_MSG_PUB.Add;
        g_sua_status := 'INVALID';
    END IF;

       -- added by vijrajag for bug # 4235458
       -- cannot override credit points when unit is audited
    IF p_sua_dtls_rec.no_assessment_ind = 'Y' THEN
            IF p_sua_dtls_rec.override_enrolled_cp IS NOT NULL OR
               p_sua_dtls_rec.override_achievable_cp IS NOT NULL THEN
                    FND_MESSAGE.SET_NAME('IGS','IGS_EN_AUDIT_NO_OVR_CP');
                    FND_MSG_PUB.ADD;
                    g_sua_status := 'INVALID';
            END IF;
    END IF;

    -- If Program Code is specified , it should be in Upper Case.
    IF p_sua_dtls_rec.program_cd IS NOT NULL THEN
        BEGIN
                igs_en_su_attempt_pkg.check_constraints(
                    column_name  => 'COURSE_CD' ,
                    column_value => p_sua_dtls_rec.program_cd );

        EXCEPTION
            WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                        p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_PRGM_CD_UCASE');
                FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
        END;
    END IF;

    -- If Unit Code is specified , it should be in Upper Case.
    IF p_sua_dtls_rec.unit_cd IS NOT NULL THEN
        BEGIN
                igs_en_su_attempt_pkg.check_constraints(
                        column_name  => 'UNIT_CD' ,
                        column_value => p_sua_dtls_rec.unit_cd );
        EXCEPTION
            WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                            p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_UNT_CD_UCASE');
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
        END;
    END IF;

    -- If Location Code is specified , it should be in Upper Case.
    IF p_sua_dtls_rec.location_cd IS NOT NULL THEN
        BEGIN
                igs_en_su_attempt_pkg.check_constraints(
                column_name  => 'LOCATION_CD' ,
                column_value => p_sua_dtls_rec.location_cd );
        EXCEPTION
            WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                        p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_LOC_CD_UCASE');
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
        END;
    END IF;

    -- If Unit class is specified , it should be in Upper Case.
    IF p_sua_dtls_rec.unit_class IS NOT NULL THEN
        BEGIN
                igs_en_su_attempt_pkg.check_constraints(
                        column_name  => 'UNIT_CLASS' ,
                        column_value => p_sua_dtls_rec.unit_class );
        EXCEPTION
                WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                        p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_UNT_CLS_UCASE');
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
        END;
    END IF;

    IF p_sua_dtls_rec.dropped_ind IS NOT NULL AND p_sua_dtls_rec.dropped_ind NOT IN ('Y' , 'N') THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_DROP_IND_INV');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
    END IF ;

    -- If Discontinuation Reason Code is specified , it should be in Upper Case.
    IF p_sua_dtls_rec.dcnt_reason_cd IS NOT NULL THEN
        BEGIN
                igs_en_su_attempt_pkg.check_constraints(
                        column_name  => 'DCNT_REASON_CD' ,
                        column_value => p_sua_dtls_rec.dcnt_reason_cd );
        EXCEPTION
            WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                            p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_DISC_RSN_INV');
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
        END;
    END IF;

    -- If Assesment Indicator is specified , Permitted values are 'Y' or 'N'.
    IF p_sua_dtls_rec.no_assessment_ind IS NOT NULL THEN
        BEGIN
                igs_en_su_attempt_pkg.check_constraints(
                    column_name  => 'NO_ASSESSMENT_IND' ,
                    column_value => p_sua_dtls_rec.no_assessment_ind );
        EXCEPTION
            WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                    p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_NO_ASSMNT_INV');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
        END;
    END IF;

    -- If Override Enrolled Credit Points are specified, it must be between 0 and 999.999.
    IF p_sua_dtls_rec.override_enrolled_cp IS NOT NULL THEN
        BEGIN

                igs_en_su_attempt_pkg.check_constraints(
                                column_name  => 'OVERRIDE_ENROLLED_CP'  ,
                                column_value => igs_ge_number.to_cann(p_sua_dtls_rec.override_enrolled_cp ));
        EXCEPTION
                WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                    p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_OVR_ENR_CP_INV' );
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
        END;
    END IF;

    -- If Override Enrolled Achievable Points are specified, it must be between 0 and 999.999.
    IF p_sua_dtls_rec.override_achievable_cp IS NOT NULL THEN
        BEGIN
                igs_en_su_attempt_pkg.check_constraints(
                                        column_name  => 'OVERRIDE_ACHIEVABLE_CP'  ,
                                        column_value => igs_ge_number.to_cann(p_sua_dtls_rec.override_achievable_cp ));

        EXCEPTION
            WHEN OTHERS THEN
            FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                        p_data  => l_msg_data);
            FND_MSG_PUB.DELETE_MSG(l_msg_count);
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_OVR_ACH_CP_INV');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
        END;
    END IF;

    -- If Grading Schema Code is specified , it should be in Upper Case.
    IF p_sua_dtls_rec.grading_schema_code IS NOT NULL THEN
        BEGIN

                igs_as_su_stmptout_pkg.check_constraints(
                                column_name  => 'GRADING_SCHEMA_CD'  ,
                                column_value => p_sua_dtls_rec.grading_schema_code );
        EXCEPTION
                WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                        p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_GRD_SCH');
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
        END;
    END IF;


    -- If Student Career Transcript is specified , Permitted values are 'Y' or 'N'.
    IF p_sua_dtls_rec.student_career_transcript IS NOT NULL AND p_sua_dtls_rec.student_career_transcript NOT IN ('Y' , 'N') THEN
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_CAR_TRNSCPT_INV');
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
    END IF ;

    -- If Student Career statistics is specified , Permitted values are 'Y' or 'N'.
    IF p_sua_dtls_rec.student_career_statistics IS NOT NULL AND p_sua_dtls_rec.student_career_statistics NOT IN ('Y' , 'N') THEN
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_CAR_STATS_INV');
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
    END IF ;

    -- If Transfer Program Code is specified , it should be in Upper Case.
    IF p_sua_dtls_rec.transfer_program_cd IS NOT NULL THEN
        BEGIN
                        igs_ps_stdnt_trn_pkg.check_constraints(
                                        column_name  =>  'TRANSFER_COURSE_CD' ,
                                        column_value => p_sua_dtls_rec.transfer_program_cd);
            EXCEPTION
                        WHEN OTHERS THEN
                        FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                                            p_data  => l_msg_data);
                        FND_MSG_PUB.DELETE_MSG(l_msg_count);
                        FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_PRGM_CD_UCASE');
                        FND_MSG_PUB.ADD;
                        g_sua_status := 'INVALID';
            END;
    END IF;

    -- If Marks is specified, it must be between 0 and 999.999.
    IF p_sua_dtls_rec.mark IS NOT NULL THEN
            BEGIN
                        igs_as_su_stmptout_pkg.check_constraints(
                                        column_name  =>  'MARK'  ,
                                        column_value => igs_ge_number.to_cann(p_sua_dtls_rec.mark ));
            EXCEPTION
                        WHEN OTHERS THEN
                        FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                                            p_data  => l_msg_data);
                        FND_MSG_PUB.DELETE_MSG(l_msg_count);
                        FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_MARK_INV');
                        FND_MSG_PUB.ADD;
                        g_sua_status := 'INVALID';
            END;
    END IF;

    -- If Grade is specified , it should be in Upper Case.
    IF p_sua_dtls_rec.grade IS NOT NULL AND p_sua_dtls_rec.grade  <> UPPER(p_sua_dtls_rec.grade) THEN
                OPEN get_grade;
                FETCH get_grade INTO l_grade_msg;
                CLOSE get_grade ;

                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_INV' );
                FND_MESSAGE.SET_TOKEN('PARAM',l_grade_msg );
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
    END IF;

    --
    -- If any of the Descriptive Flex field columns have value , validate them .
    IF (p_sua_dtls_rec.attribute_category IS NOT NULL OR p_sua_dtls_rec.attribute1  IS NOT NULL OR p_sua_dtls_rec.attribute2  IS NOT NULL OR
        p_sua_dtls_rec.attribute3  IS NOT NULL OR p_sua_dtls_rec.attribute4  IS NOT NULL OR p_sua_dtls_rec.attribute5  IS NOT NULL OR
        p_sua_dtls_rec.attribute6  IS NOT NULL OR p_sua_dtls_rec.attribute7  IS NOT NULL OR p_sua_dtls_rec.attribute8  IS NOT NULL OR
        p_sua_dtls_rec.attribute9  IS NOT NULL OR p_sua_dtls_rec.attribute10 IS NOT NULL OR p_sua_dtls_rec.attribute11 IS NOT NULL OR
        p_sua_dtls_rec.attribute12 IS NOT NULL OR p_sua_dtls_rec.attribute13 IS NOT NULL OR p_sua_dtls_rec.attribute14 IS NOT NULL OR
        p_sua_dtls_rec.attribute15 IS NOT NULL OR p_sua_dtls_rec.attribute16 IS NOT NULL OR p_sua_dtls_rec.attribute17 IS NOT NULL OR
        p_sua_dtls_rec.attribute18 IS NOT NULL OR p_sua_dtls_rec.attribute19 IS NOT NULL OR p_sua_dtls_rec.attribute20 IS NOT NULL )
    THEN
            IF NOT igs_ad_imp_018.validate_desc_flex (
                p_attribute_category    => p_sua_dtls_rec.attribute_category ,
                p_attribute1            => p_sua_dtls_rec.attribute1   ,
                p_attribute2            => p_sua_dtls_rec.attribute2   ,
                p_attribute3            => p_sua_dtls_rec.attribute3   ,
                p_attribute4            => p_sua_dtls_rec.attribute4   ,
                p_attribute5            => p_sua_dtls_rec.attribute5   ,
                p_attribute6            => p_sua_dtls_rec.attribute6   ,
                p_attribute7            => p_sua_dtls_rec.attribute7   ,
                p_attribute8            => p_sua_dtls_rec.attribute8   ,
                p_attribute9            => p_sua_dtls_rec.attribute9   ,
                p_attribute10           => p_sua_dtls_rec.attribute10  ,
                p_attribute11           => p_sua_dtls_rec.attribute11  ,
                p_attribute12           => p_sua_dtls_rec.attribute12  ,
                p_attribute13           => p_sua_dtls_rec.attribute13  ,
                p_attribute14           => p_sua_dtls_rec.attribute14  ,
                p_attribute15           => p_sua_dtls_rec.attribute15  ,
                p_attribute16           => p_sua_dtls_rec.attribute16  ,
                p_attribute17           => p_sua_dtls_rec.attribute17  ,
                p_attribute18           => p_sua_dtls_rec.attribute18  ,
                p_attribute19           => p_sua_dtls_rec.attribute19  ,
                p_attribute20           => p_sua_dtls_rec.attribute20  ,
                p_desc_flex_name        => 'IGS_EN_SU_ATMPT_FLEX'
                )  THEN
                                FND_MESSAGE.SET_NAME( 'IGS','IGS_AD_INVALID_DESC_FLEX' );
                                FND_MSG_PUB.ADD;
                                g_sua_status := 'INVALID';
        END IF ;
    END IF;

    -- If Outcome Grading Schema Code is specified , it should be in Upper Case.
    IF p_sua_dtls_rec.outcome_grading_schema_code IS NOT NULL THEN
            BEGIN
                        igs_as_su_stmptout_pkg.check_constraints(
                                        column_name  => 'GRADING_SCHEMA_CD' ,
                                        column_value => p_sua_dtls_rec.outcome_grading_schema_code );
            EXCEPTION
                        WHEN OTHERS THEN
                            FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                                                p_data  => l_msg_data);
                            FND_MSG_PUB.DELETE_MSG(l_msg_count);
                            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_GRD_SCH');
                            FND_MSG_PUB.ADD;
                            g_sua_status := 'INVALID';
            END;
    END IF;

  RETURN ;

END validate_parameters;

PROCEDURE validate_db_cons( p_person_id             IN   NUMBER,
                            p_unit_version_number   IN   NUMBER,
                            p_uoo_id                IN   NUMBER ,
                            p_cal_type              IN   VARCHAR2 ,
                            p_ci_sequence_number    IN   NUMBER,
                            p_sua_dtls_rec          IN   sua_dtls_rec_type ) AS
/*-----------------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : This routine validates the DB constraints for the parameters. In cases where the parameters
                    are not Mandatory , a check is made to check if Atleast one column of the composite FK has
                    value. Incases when validations are done for Madatory columns , the above check is not done.
                    Failure of PK validation alone should return warning. In this case, processing should stop,
                    and a status of warning is return to the calling procedure. All other validations are done in
                    one shot.
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
knaraset 19-Jun-2003 Added unique key validation igs_en_su_attempt_pkg.Get_Uk_For_Validation, as part of bug 2956146
kkillams 29-04-2003  Impacted object, due to change in the signature of the igs_en_su_attempt_pkg.get_pk_for_validation function
                     w.r.t. bug number 2829262
rvangala 02-OCT-2003 Added validation to check value of core_indicator, added as part of Prevent Dropping Core Units. Enh Bug# 3052432
amuthu   29-JUL-2004 Added validation for Administrative unit status, to call
                     the IGS_AD_ADM_UNIT_STAT_PKG.Get_PK_For_Validation, to
                     prevent invalid values from getting saved
-----------------------------------------------------------------------------*/
l_indicator BOOLEAN := false;
BEGIN
   -- Primary Key validation
   IF igs_en_su_attempt_pkg.get_pk_for_validation (
                                                   p_person_id ,
                                                   p_sua_dtls_rec.program_cd,
                                                   p_uoo_id) THEN
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_UNT_ATMPT_EXTS');
                FND_MSG_PUB.ADD;
                g_sua_status := 'WARNING';
                RETURN;
   END IF ;
   -- Unique Key validation
   IF igs_en_su_attempt_pkg.Get_Uk_For_Validation (
                                                   x_person_id => p_person_id ,
                                                   x_course_cd => p_sua_dtls_rec.program_cd,
                                                   x_unit_cd => p_sua_dtls_rec.unit_cd,
                                                   x_cal_type => p_cal_type,
                                                   x_ci_sequence_number => p_ci_sequence_number,
                                                   x_location_cd => p_sua_dtls_rec.location_cd,
                                                   x_unit_class => p_sua_dtls_rec.unit_class,
						   x_version_number => p_unit_version_number) THEN
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_UNT_ATMPT_EXTS');
                FND_MSG_PUB.ADD;
                g_sua_status := 'WARNING';
                RETURN;
   END IF ;

   -- Foreign Key Validation - Administrative unit status
    IF (p_sua_dtls_rec.administrative_unit_status IS NOT NULL) THEN
      IF NOT IGS_AD_ADM_UNIT_STAT_PKG.Get_PK_For_Validation(
               p_sua_dtls_rec.administrative_unit_status,NULL) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_EN_AUS_INVALID');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
      END IF;
    END IF;


   -- Foreign Key Validation - Grading Schema Code and version Number
   IF (p_sua_dtls_rec.gs_version_number  IS NOT NULL OR p_sua_dtls_rec.grading_schema_code IS NOT NULL) THEN
        IF NOT igs_as_grd_schema_pkg.get_pk_for_validation (
        x_grading_schema_cd    =>  p_sua_dtls_rec.grading_schema_code,
        x_version_number       =>  p_sua_dtls_rec.gs_version_number) THEN

                    FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_GRD_SCH' );
                    FND_MSG_PUB.ADD;
                    g_sua_status := 'INVALID';
        END IF;
   END IF;

   -- Foreign Key Validation - Check if Location Code exists.
   IF NOT igs_ad_location_pkg.get_pk_for_validation ( x_location_cd => p_sua_dtls_rec.location_cd) THEN
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_LOC_CD_INV' );
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
   END IF;

  -- Foreign Key Validation - Check if Student Program Attempt exists.
  IF NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation (
        x_person_id     =>  p_person_id,
        x_course_cd     =>  p_sua_dtls_rec.program_cd) THEN

                    FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_FI_PRSNID_PRGCD_NOT_MATCH');
                    FND_MSG_PUB.ADD;
                    g_sua_status := 'INVALID';
  END IF ;

  -- Foreign Key Validation - Check if Unit Code / Version exists.
  IF NOT igs_ps_unit_ver_pkg.get_pk_for_validation (
        x_unit_cd              => p_sua_dtls_rec.unit_cd,
        x_version_number       => NVL ( p_sua_dtls_rec.version_number,p_unit_version_number))   THEN

                    FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_PS_UNITCODE_UNITVER_NE');
                    FND_MSG_PUB.ADD;
                    g_sua_status := 'INVALID';
  END IF;

  -- Foreign Key Validation - Check if Unit Code exists.
  IF NOT igs_ps_unit_pkg.get_pk_for_validation ( x_unit_cd => p_sua_dtls_rec.unit_cd)THEN
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_IN_INVALID_UNIT_CODE');
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
  END IF;

  -- Foreign Key Validation - Check if Unit is being Offered.
  IF NOT igs_ps_unit_ofr_opt_pkg.get_pk_for_validation (
        x_unit_cd              =>   p_sua_dtls_rec.unit_cd,
        x_version_number       =>       NVL ( p_sua_dtls_rec.version_number,p_unit_version_number),
        x_cal_type             =>       p_cal_type,
        x_ci_sequence_number   =>   p_ci_sequence_number,
        x_location_cd          =>   p_sua_dtls_rec.location_cd,
        x_unit_class           =>   p_sua_dtls_rec.unit_class) THEN

                    FND_MESSAGE.SET_NAME( 'IGS' ,       'IGS_AS_UNITCD_LOC_UC_INVALID');
                    FND_MSG_PUB.ADD;
                    g_sua_status := 'INVALID';
  END IF;

  --Foreign Key validation - Check if Discontinuation Reason Code exists.
  IF p_sua_dtls_rec.dcnt_reason_cd IS NOT NULL THEN
        IF NOT igs_en_dcnt_reasoncd_pkg.get_pk_for_validation ( x_dcnt_reason_cd => p_sua_dtls_rec.dcnt_reason_cd )THEN
                FND_MESSAGE.SET_NAME( 'IGS' ,   'IGS_EN_DISC_REASON_CD_INV' );
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
        END IF;
  END IF;


  -- core_indicator validation - Check if value of core indicator is valid, added by rvangala as part of Prevent Dropping Core Units. Enh Bug# 3052432
  IF p_sua_dtls_rec.core_indicator IS NOT NULL THEN
    l_indicator := IGS_LOOKUPS_VIEW_PKG.GET_PK_FOR_VALIDATION('IGS_PS_CORE_IND',p_sua_dtls_rec.core_indicator);
    IF l_indicator=FALSE THEN
         FND_MESSAGE.SET_NAME( 'IGS' ,   'IGS_EN_CORE_IND_INVALID' );
         FND_MSG_PUB.ADD;
         g_sua_status := 'INVALID';
    END IF;
  END IF;
END validate_db_cons;

PROCEDURE validate_pre_sua( p_person_id          IN NUMBER,
                            p_sua_dtls_rec       IN sua_dtls_rec_type ,
                            p_version_number     IN NUMBER ,
                            p_cal_type           IN VARCHAR2 ,
                            p_ci_sequence_number IN NUMBER,
                            p_uoo_id             IN IGS_EN_SU_ATTEMPT.UOO_ID%TYPE
                            ) AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : This routine is private API. The insert API makes a call to this routine to validate
                    SUA details regarding Unit and Program Transfer. If the validations are successful ,
                    SUA AND SPA Transfer Details are created in the respectively tables. NOte that SPA
                    transfer details can already exist in the table if a Transferred Unit Attempt has
                    already been import for another SUA.
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
svenkata 2-JAN-03    The values of WHO columns was being set inside the block for Student Program Transfer.Moved the code
                     to the main block-Bug# 2732542
kkillams 29-04-2003  Modified the get_sua_trn cursor due to change in the pk of student unit attempt w.r.t. bug number 2829262
------------------------------------------------------------------*/
--
-- cursor to determine if Student Program Attempt Transfer details already exist .
CURSOR get_sca_trn IS
SELECT 'x'
FROM igs_ps_stdnt_trn
WHERE person_id = p_person_id AND
course_cd= p_sua_dtls_rec.program_cd AND
transfer_course_cd = p_sua_dtls_rec.transfer_program_cd AND
TRUNC(transfer_dt) = TRUNC( p_sua_dtls_rec.transfer_dt);

--
-- CURSOR to check if the SUA Transfer record  already exists
CURSOR get_sua_trn IS
SELECT 'x'
FROM igs_ps_stdnt_unt_trn
WHERE person_id         = p_person_id AND
course_cd               = p_sua_dtls_rec.program_cd AND
transfer_course_cd      = p_sua_dtls_rec.transfer_program_cd AND
transfer_dt             = p_sua_dtls_rec.transfer_dt AND
uoo_id                  = p_uoo_id;


l_creation_date         igs_ps_stdnt_trn.creation_date%TYPE;
l_last_update_date      igs_ps_stdnt_trn.last_update_date%TYPE;
l_created_by            igs_ps_stdnt_trn.created_by%TYPE;
l_last_updated_by       igs_ps_stdnt_trn.last_updated_by%TYPE;
l_last_update_login     igs_ps_stdnt_trn.last_update_login%TYPE;
l_dummy                 VARCHAR2(1) := NULL;

BEGIN

-- Insert SPA Transfer details
        OPEN get_sca_trn;
    FETCH get_sca_trn INTO l_dummy;

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

    IF get_sca_trn%NOTFOUND THEN

        BEGIN
            INSERT INTO IGS_PS_STDNT_TRN (
              PERSON_ID,
              COURSE_CD,
              TRANSFER_COURSE_CD,
              TRANSFER_DT,
              COMMENTS,
              STATUS_DATE,
              STATUS_FLAG,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN
            ) VALUES (
              p_person_id,
              p_sua_dtls_rec.program_cd ,
              p_sua_dtls_rec.transfer_program_cd,
              p_sua_dtls_rec.transfer_dt,
              NULL ,
              p_sua_dtls_rec.transfer_dt,
              'T',
              l_last_update_date,
              l_last_updated_by,
              l_last_update_date,
              l_last_updated_by,
              l_last_update_login
            );
        EXCEPTION
          WHEN OTHERS THEN
            IF (get_sca_trn%ISOPEN) THEN
                   CLOSE get_sca_trn;
            END IF;

            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_STDNT_SPA_TRN_INCOMPL' );
            FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
            RAISE ;
        END;
    END IF ;
    CLOSE get_sca_trn;

        OPEN get_sua_trn;
    FETCH get_sua_trn INTO l_dummy;
    IF get_sua_trn%NOTFOUND THEN

        BEGIN
          INSERT INTO igs_ps_stdnt_unt_trn (
            PERSON_ID,
            COURSE_CD,
            TRANSFER_COURSE_CD,
            TRANSFER_DT,
            UOO_ID,
            UNIT_CD,
            CAL_TYPE,
            CI_SEQUENCE_NUMBER,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
          ) values (
              p_person_id,
              p_sua_dtls_rec.program_cd ,
              p_sua_dtls_rec.transfer_program_cd,
              p_sua_dtls_rec.transfer_dt,
              p_uoo_id,
              p_sua_dtls_rec.unit_cd,
              p_cal_type ,
              p_ci_Sequence_number,
              l_last_update_date,
              l_last_updated_by,
              l_last_update_date,
              l_last_updated_by,
              l_last_update_login
          );

        EXCEPTION
          WHEN OTHERS THEN
            IF (get_sua_trn%ISOPEN) THEN
                   CLOSE get_sua_trn;
            END IF;

            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_STDNT_SUA_TRN_INCOMPL' );
            FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
            RAISE ;
        END;

    ELSE
        FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_STDNT_SUA_TRN_INCOMPL' );
        FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
    END IF ;

    CLOSE get_sua_trn;

END validate_pre_sua;

PROCEDURE  validate_post_sua (p_person_id          IN NUMBER,
                       p_version_number     IN NUMBER,
                       p_sua_dtls_rec       IN sua_dtls_rec_type,
                       p_cal_type           IN VARCHAR2,
                       p_ci_sequence_number IN NUMBER,
                       p_ci_end_dt          IN DATE,
                       p_ci_start_dt        IN DATE,
                       p_unit_attempt_status IN VARCHAR2,
                       p_uoo_id              IN NUMBER,
                       p_administrative_unit_status IN VARCHAR2,
                       p_career_centric       IN VARCHAR2 ,
                       p_primary_program_type IN VARCHAR2 ,
                       p_administrative_pri   IN NUMBER
                      ) AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : This routine is private to the API. There is a call to this routine from the insert
                    API to carry out all validations after inserting Student Unit Attempt Details .This
                    routine does the following :
                    1. If DISCONTINUED_DT is not null then insert corresponding discontinuation grade
                        into IGS_AS_SU_STMPTOUT_ALL
                    2. Increment Unit section actual enrollment .
                    3. Insert Student Unit Attempt Outcome details
                    4. Re-derive the Program Attempt status. Update the SPA record with the new status.
Known limitations,
enhancements,
remarks           :
Change History
Who      When           What
svenkata 18-Nov-2002    Bug# 2715256- Adminisntrative Unit Status was passed incorrectly to the routine
                        igs_en_gen_010.enrp_ins_suao_discon.Added NVL clause.
svenkata 18-Nov-2002    Bug# 2715240 - The value of the column MARK was not passed correctly to the API call
                        of Student Unit Attempt Outcome.
svenkata 30-Dec-2002    Mirroring of all secondary Program Attempts if status of Primary Program Attempt
|                       is changed.Bug# 2728047.
kkillams 27-Mar-03      Modified usec_cur Cursor, replaced * with enrollment_actual and waitlist_actual
                        w.r.t. bug 2749648
kkillams    25-04-2003  Impacted object, due to change in the signature of the igs_en_gen_010.enrp_ins_suao_discon function
                        w.r.t. bug number 2829262
rvivekan  11-July -2003 Added INVALID and UNCONFIRM to scenarios for enrollment_actual increment Bug 3036949
ptandon   23-Sep-2003   Passed the value of fields LOCATION_CD and UNIT_CLASS in l_suao_rec parameter in call to procedure
                        igs_as_suao_lgcy_pub.create_unit_outcome. Bug# 3149520.
ptandon   24-Sep-2003   In call to igs_en_gen_legacy.get_course_att_status, the value of parameter p_discontinued_dt
                        was being incorrectly passed as p_sua_dtls_rec.discontinued_dt. Replaced it by value of
                        discontinued_dt fetched from get_spa cursor. Bug# 3152211.
ptandon   02-Dec-2003   Inserted call to the Term Records Legacy API as per Term Records Fee Calc build. Bug# 2829263.
------------------------------------------------------------------*/
  --
  -- Cursor to get the Enrollment Actual for a Unit section.
  CURSOR usec_upd_enr_act  IS
  SELECT ROWID,uoo.enrollment_actual, uoo.waitlist_actual
  FROM   igs_ps_unit_ofr_opt uoo
  WHERE uoo_id = p_uoo_id
  FOR UPDATE NOWAIT;

  --
  -- Cursor to fetch Student Program Details .
  CURSOR get_spa IS
  SELECT ROWID , spa.*
  FROM igs_en_stdnt_ps_att spa
  WHERE spa.person_id = p_person_id AND
  spa.course_cd = p_sua_dtls_rec.program_cd
  FOR UPDATE NOWAIT;

  --
  -- Cursor to get the Course Type of the Primary Program
  CURSOR get_course_type IS
  SELECT sca.course_type
  FROM igs_en_sca_v sca
  WHERE sca.person_id  =  p_person_id AND
  sca.course_cd = p_sua_dtls_rec.program_cd ;

  --
  -- Cursor to fetch all the secondary Programs in a career for the given Primary Program
  CURSOR get_spa_sec_prgm (p_course_type IN VARCHAR2 ) IS
  SELECT spa.ROWID
  FROM igs_en_stdnt_ps_att spa  , igs_en_sca_v sca
  WHERE spa.person_id = p_person_id AND
  spa.person_id = sca.person_id AND
  sca.course_cd = spa.course_cd AND
  sca.course_type = p_course_type AND
  spa.primary_program_type = 'SECONDARY' AND
  spa.course_attempt_status NOT IN ('UNCONFIRM' , 'DISCONTIN' , 'COMPLETED')
  FOR UPDATE NOWAIT ;

  l_suao_rec igs_as_suao_lgcy_pub.lgcy_suo_rec_type;
  l_course_type igs_en_sca_v.course_type%TYPE DEFAULT NULL ;
  l_spa_row get_spa%ROWTYPE;
  l_spa_row_sec get_spa_sec_prgm %ROWTYPE;

  l_usec_row usec_upd_enr_act%ROWTYPE;
  l_message_name VARCHAR2(60) := NULL ;
  l_waitlist_actual igs_ps_unit_ofr_opt.waitlist_actual%TYPE := 0 ;
  l_enrollment_actual igs_ps_unit_ofr_opt.enrollment_actual%TYPE:= 0 ;

  l_return_status  VARCHAR2(1) := NULL ;
  l_msg_count     NUMBER := 0;
  l_msg_data      VARCHAR2(2000) := NULL ;
  l_course_attempt_status_after igs_en_stdnt_ps_att.course_attempt_status%TYPE := NULL ;
  l_last_dt_of_att  igs_en_stdnt_ps_att.last_date_of_attendance%TYPE := NULL ;

BEGIN

IF p_unit_attempt_status ='WAITLISTED' THEN
  IF g_wlst_pri_pref_exists=TRUE THEN
    igs_en_wlst_gen_proc.enrp_wlst_assign_pos(p_person_id   => p_person_id,
                                           p_program_cd  => p_sua_dtls_rec.program_cd,
                                           p_uoo_id      => p_uoo_id);

  ELSE
    igs_en_wlst_gen_proc.enrp_wlst_dt_reseq (p_person_id   => p_person_id,
                                         p_program_cd  => p_sua_dtls_rec.program_cd,
                                         p_uoo_id      => p_uoo_id,
                                         p_cur_position=> p_administrative_pri);
  END IF;
END IF;
--
--  A. If discontinued date is set , corresponding discontinuation grade is inserted into IGS_AS_SU_STMPTOUT_ALL
IF p_sua_dtls_rec.discontinued_dt IS NOT NULL THEN

        IF NOT igs_en_gen_010.enrp_ins_suao_discon(
          p_person_id                   => p_person_id           ,
          p_course_cd                   => p_sua_dtls_rec.program_cd ,
          p_unit_cd                     => p_sua_dtls_rec.unit_cd ,
          p_cal_type                    => p_cal_type ,
          p_ci_sequence_number          => p_ci_sequence_number ,
          p_ci_start_dt                 => p_ci_start_dt ,
          p_ci_end_dt                   => p_ci_end_dt ,
          p_discontinued_dt             => p_sua_dtls_rec.discontinued_dt ,
          p_administrative_unit_status  => NVL( p_sua_dtls_rec.administrative_unit_status , p_administrative_unit_status),
          p_message_name                => l_message_name,
          p_uoo_id                      => p_uoo_id) AND l_message_name IS NOT NULL THEN
            FND_MESSAGE.SET_NAME( 'IGS' , l_message_name );
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';

        END IF;

END IF ;

--
-- B. Increment Unit section actual enrollment and waitlist actual.
OPEN usec_upd_enr_act ;
FETCH usec_upd_enr_act INTO l_usec_row;

IF usec_upd_enr_act%FOUND THEN
    CLOSE usec_upd_enr_act;
    IF  p_unit_attempt_status IN ( 'ENROLLED' ,'COMPLETED','INVALID','UNCONFIRM') THEN

        -- Increment the Total enrollment actual count by 1.
        l_enrollment_actual := NVL(l_usec_row.ENROLLMENT_ACTUAL,0)+1;

        BEGIN
            UPDATE igs_ps_unit_ofr_opt_all SET enrollment_actual = l_enrollment_actual  WHERE ROWID = l_usec_row.ROWID;

        EXCEPTION
            WHEN OTHERS THEN
                IF (usec_upd_enr_act%ISOPEN) THEN
                    CLOSE usec_upd_enr_act;
                END IF ;
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_SUA_ACTUAL_ENR_UD_ERR' );
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
                RAISE ;
        END ;

    ELSIF p_unit_attempt_status = 'WAITLISTED' THEN

        -- Increment the Total waitlist actual count by 1.
        l_waitlist_actual := NVL(l_usec_row.WAITLIST_ACTUAL,0)+1;

        BEGIN
            UPDATE igs_ps_unit_ofr_opt_all SET waitlist_actual = l_waitlist_actual WHERE ROWID = l_usec_row.ROWID ;

        EXCEPTION
            WHEN OTHERS THEN
                IF (usec_upd_enr_act%ISOPEN) THEN
                    CLOSE usec_upd_enr_act;
                END IF ;
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_SUA_WAITLIST_UPD_ERR' );
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
                RAISE ;
        END ;
    END IF ;
ELSE
    CLOSE usec_upd_enr_act;
END IF ;
--
-- C.Insert Student Unit Attempt Outcome details
-- This has be done when SUAO API is complete , or atleast when signature is available.
--
IF  p_sua_dtls_rec.outcome_dt IS NOT NULL THEN

    l_suao_rec.person_number        := p_sua_dtls_rec.person_number ;
    l_suao_rec.program_cd           := p_sua_dtls_rec.program_cd   ;
    l_suao_rec.unit_cd              := p_sua_dtls_rec.unit_cd   ;
    l_suao_rec.teach_cal_alt_code   := p_sua_dtls_rec.teach_calendar_alternate_code ;
    l_suao_rec.outcome_dt           := p_sua_dtls_rec.outcome_dt ;
    l_suao_rec.grading_schema_cd    := p_sua_dtls_rec.outcome_grading_schema_code ;
    l_suao_rec.version_number       := p_sua_dtls_rec.outcome_gs_version_number;
    l_suao_rec.grading_period_cd    := 'FINAL';
    l_suao_rec.incomp_deadline_date := p_sua_dtls_rec.incomp_deadline_date  ;
    l_suao_rec.incomp_default_grade := p_sua_dtls_rec.incomp_default_grade ;
    l_suao_rec.grade                := p_sua_dtls_rec.grade ;
    l_suao_rec.mark                 := p_sua_dtls_rec.mark ;
    l_suao_rec.incomp_default_mark  := p_sua_dtls_rec.incomp_default_mark ;
    l_suao_rec.location_cd          := p_sua_dtls_rec.location_cd   ;
    l_suao_rec.unit_class           := p_sua_dtls_rec.unit_class   ;

    igs_as_suao_lgcy_pub.create_unit_outcome
          (
               p_api_version                 => 1,
               p_init_msg_list               => FND_API.G_FALSE                   ,
               p_commit                      => FND_API.G_FALSE             ,
               p_validation_level            => FND_API.G_VALID_LEVEL_FULL          ,
               p_lgcy_suo_rec                => l_suao_rec ,
               x_return_status               => l_return_status ,
               x_msg_count                   => l_msg_count ,
               x_msg_data                    => l_msg_data );

           IF l_return_status IN ('E' , 'U' , 'W' ) THEN
                g_sua_status := 'INVALID';
           END IF ;
END IF;

-- The the system is in Career Centric mode, get the course_type of the Program.
IF p_career_centric = 'Y' THEN
    OPEN get_course_type ;
    FETCH get_course_type INTO l_course_type;
    CLOSE get_course_type;
END IF;

OPEN get_spa ;
FETCH get_spa INTO l_spa_row ;

-- D. Update Student Program Attempt
IF get_spa%FOUND THEN
    CLOSE get_spa  ;
    IF p_sua_dtls_rec.discontinued_dt IS NOT NULL THEN
        igs_en_gen_legacy.get_last_dt_of_att (
            x_person_id         => p_person_id ,
            x_course_cd         => p_sua_dtls_rec.program_cd ,
            x_last_date_of_attendance => l_last_dt_of_att ) ;
    END IF;


    l_course_attempt_status_after := igs_en_gen_legacy.get_course_att_status(
        p_person_id                     => p_person_id                     ,
        p_course_cd                     => p_sua_dtls_rec.program_cd ,
        p_student_confirmed_ind         => l_spa_row.student_confirmed_ind  ,
        p_discontinued_dt               => l_spa_row.discontinued_dt ,
        p_lapsed_dt                     => l_spa_row.lapsed_dt ,
        p_course_rqrmnt_complete_ind    => l_spa_row.course_rqrmnt_complete_ind ,
        p_primary_pg_type               => p_primary_program_type ,
        p_primary_prog_type_source      => l_spa_row.primary_program_type ,
        p_course_type                   => l_course_type  ,
        p_career_flag                   => p_career_centric )  ;


    IF l_spa_row.course_attempt_status <>   l_course_attempt_status_after THEN

            -- If the course attempt status changes as a result of the Unit Import , Update the Course Attempt Status .
            BEGIN
                IF l_last_dt_of_att IS NOT NULL THEN
                    UPDATE IGS_EN_STDNT_PS_ATT_ALL SET COURSE_ATTEMPT_STATUS = l_course_attempt_status_after ,
                    LAST_DATE_OF_ATTENDANCE = l_last_dt_of_att WHERE ROWID = l_spa_row.ROWID;
                ELSE
                    UPDATE IGS_EN_STDNT_PS_ATT_ALL SET COURSE_ATTEMPT_STATUS = l_course_attempt_status_after WHERE ROWID = l_spa_row.ROWID;
                END IF;

                -- If the Primary Program Status is updated, mirror all the secondary Programs with the same status as the primary program.
                IF l_spa_row.primary_program_type = 'PRIMARY' THEN
                    FOR get_spa_sec_prgm_rec IN get_spa_sec_prgm(l_course_type)
                    LOOP
                        UPDATE IGS_EN_STDNT_PS_ATT_ALL SET COURSE_ATTEMPT_STATUS = l_course_attempt_status_after WHERE ROWID = get_spa_sec_prgm_rec.ROWID ;
                    END LOOP;
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    IF (get_spa%ISOPEN) THEN
                        CLOSE get_spa;
                    END IF;
                    FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_SPA_STAT_INCOMPL' );
                    FND_MSG_PUB.ADD;
                    g_sua_status := 'INVALID';
                    RAISE ;
            END ;
    END IF ;
ELSE
    CLOSE get_spa ;
END IF ;

END  validate_post_sua ;

PROCEDURE validate_sua(p_person_id          IN NUMBER,
                       p_version_number     IN NUMBER,
                       p_sua_dtls_rec       IN sua_dtls_rec_type,
                       p_cal_type           IN VARCHAR2,
                       p_ci_sequence_number IN NUMBER,
                       p_ci_end_dt          IN DATE,
                       p_ci_start_dt        IN DATE,
                       p_unit_attempt_status IN VARCHAR2,
                       p_uoo_id             IN NUMBER ,
                       p_career_model_enabled IN VARCHAR2 ,
                       p_administrative_unit_status IN VARCHAR2,
                       p_no_assessment_ind  IN VARCHAR2 ,
                       p_primary_program_type OUT NOCOPY VARCHAR2 ,
                       p_sup_unit_cd        OUT NOCOPY VARCHAR2 ,
                       p_sup_unit_version_number OUT NOCOPY NUMBER
                      ) AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : This routine is private to the API. There is a call to this routine from the insert
                    API to carry out all validations before inserting Student Unit Attempt Details .
Known limitations,
enhancements,
remarks           :
Change History
Who         When           What
sarakshi  13-Jul-2004   Bug#3729462, Added predicate DELETE_FLAG='N' to the cursor c_get_wlst_alwd_oopt  .
svenkata  30-Dec-2002   Error message was displayed twice.The message_name returned was compared against NULL incorrectly
                        after call to routine igs_en_val_sua.enrp_val_discont_aus. Bug#2727931
pradhakr   20-Jan-2003  Added a parameter no_assessment_ind to the procedue call IGS_EN_VAL_SUA.enrp_val_sua_ovrd_cp
                        as part of ENCR26 build.
ptandon    17-Oct-2003  Added two OUT parameters p_sup_unit_cd and p_sup_unit_version_number and modified the code to add
                        the validation for the superior-subordinate as part of Placements build. Enh Bug# 3052438.
rvivekan   17-nov-2003  Bug3264064. Changed the datatype of variables holding the concatenated administrative unit status list
                        to varchar(2000)
vkarthik   10-dec-2003  Bug3140571. Added a cursor to pick up version for the given person and course and another to get
                        max_wlst_per_stud given the course and version.  Made use of these cursors to include program level
                        EN waitlist
bdeviset   27-oct-2004  Bug#3972537.The call igs_en_val_sua.enrp_val_sua_intrmt is not made if unit_attempt_status is
                        either dropped or discontinued.

bdeviset   16-NOV-2004  Bug#4000939.Added a check  to see if the load calendar (corresponding to the teaching calendar) end date
                        is greater than the commencement date of the program attempt for ENROLLED,DISCONTIN,WAITLIST and INVALID.
ckasu      30-DEC-2004  modified code inorder to consider Term Records while getting primary program type as a part of bug#4095276
ckasu      20-JUL-2006  modified b=y ckasu as a part of bug #4642089 inorder to validate whethet Subtitle updation is allowed or not
------------------------------------------------------------------*/
--
-- Cursor to check if the auditable_ind is available at the unit section level.
CURSOR get_audit_usec IS
SELECT NVL(auditable_ind, 'N')
FROM igs_ps_unit_ofr_opt
WHERE uoo_id = p_uoo_id;

CURSOR c_get_wlst_alwd_usec (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
SELECT NVL(waitlist_allowed,'N') waitlist_allowed,NVL(max_students_per_waitlist,9999) max_students_per_waitlist
FROM igs_ps_usec_lim_wlst
WHERE cp_uoo_id=uoo_id;


CURSOR c_get_wlst_alwd_oopt (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
SELECT NVL(uop.waitlist_allowed,'N') waitlist_allowed ,NVL(uop.max_students_per_waitlist,9999) max_students_per_waitlist
FROM igs_ps_unit_ofr_pat uop,
     igs_ps_unit_ofr_opt uoo
WHERE uop.unit_cd=uoo.unit_cd
AND   uop.version_number=uoo.version_number
AND   uop.cal_type=uoo.cal_type
AND uop.ci_sequence_number=uoo.ci_sequence_number
AND uoo.uoo_id=cp_uoo_id
AND uop.delete_flag='N';



CURSOR c_get_wlst_actual_usec (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
SELECT waitlist_actual
FROM igs_ps_unit_ofr_opt
WHERE uoo_id=p_uoo_id;

-- cursor to get version number for person and course
CURSOR c_get_prog_ver(cp_person_id    igs_en_stdnt_ps_att.person_id%TYPE,
                      cp_course_cd    igs_en_stdnt_ps_att.course_cd%TYPE) IS
SELECT version_number
FROM igs_en_stdnt_ps_att
WHERE
        person_id       =       cp_person_id    AND
        course_cd       =       cp_course_cd;

-- cursor to get program level max_wlst_per_stud for a course and version
CURSOR c_max_wlst_stud_ps(cp_course_cd        igs_ps_ver.course_cd%TYPE,
                          cp_version_number   igs_ps_ver.version_number%TYPE) IS
SELECT max_wlst_per_stud
FROM igs_ps_ver
WHERE
        course_cd       =       cp_course_cd    AND
        version_number  =       cp_version_number;

CURSOR c_get_max_wlst_per_stud IS
SELECT NVL(max_waitlists_student_num,9999) max_waitlists
FROM IGS_EN_INST_WL_STPS;

CURSOR c_get_wlst_suas (cp_person_id igs_en_su_attempt.person_id%TYPE,
                        cp_load_cal_type igs_en_su_attempt.cal_type%TYPE,
                        cp_load_ci_sequence_number igs_en_su_attempt.ci_sequence_number%TYPE) IS
SELECT COUNT(ROWID) waitlists
FROM igs_en_su_attempt
WHERE person_id = cp_person_id AND
unit_attempt_status ='WAITLISTED' AND
(cal_type,ci_sequence_number) IN
    (SELECT teach_cal_type,teach_ci_sequence_number
     FROM igs_ca_load_to_teach_v
     WHERE load_cal_type = cp_load_cal_type AND
     load_ci_sequence_number = cp_load_ci_sequence_number);

--
-- Cursor to get the Discontinued Date of the Program Attempt
CURSOR get_prgm_discd_dt IS
SELECT discontinued_dt
FROM igs_en_Stdnt_ps_att
WHERE course_cd = p_sua_dtls_rec.program_cd
AND person_id = p_person_id;

--
-- Cursor to determine if the unit section is superior or subordinate
--
CURSOR c_get_usec_relation(cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
SELECT NVL(RELATION_TYPE,'NONE')
FROM igs_ps_unit_ofr_opt
WHERE uoo_id = cp_uoo_id;

--
-- Cursor to get superior unit section details
--
CURSOR c_get_superior_usec(cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
SELECT unit_cd,version_number
FROM igs_ps_unit_ofr_opt
WHERE uoo_id = (SELECT sup_uoo_id
                FROM igs_ps_unit_ofr_opt
                WHERE uoo_id = cp_uoo_id);

-- Cursor to select the Term Calendar associated with a Teaching Calendar.
CURSOR c_get_term_cal(cp_cal_type igs_ca_inst.cal_type%TYPE,
                        cp_sequence_number igs_ca_inst.sequence_number%TYPE) IS
SELECT load_cal_type, load_ci_sequence_number,load_end_dt
FROM IGS_CA_TEACH_TO_LOAD_V
WHERE teach_cal_type = cp_cal_type
AND teach_ci_sequence_number = cp_sequence_number
ORDER BY LOAD_START_DT asc;

-- added by ckasu as a part of bug# 4642089
CURSOR c_sua_chg_alwd IS
SELECT NVL(subtitle_modifiable_flag,'N')
FROM igs_ps_usec_ref
WHERE uoo_id      = p_uoo_id;

l_sua_chg_alwd igs_ps_usec_ref.subtitle_modifiable_flag%TYPE;
l_auditable_ind igs_ps_unit_ver.auditable_ind%TYPE := NULL ;
l_version_number igs_as_grd_sch_grade.version_number%TYPE := 0 ;
l_program_attempt_status igs_en_stdnt_ps_att.course_attempt_status%TYPE ;
l_prgm_discontinued_dt igs_en_stdnt_ps_att.discontinued_dt%TYPE := NULL ;

l_src_program_typ igs_en_sca_v.course_type%TYPE ;
l_destn_program_typ igs_en_sca_v.course_type%TYPE ;
l_person_id igs_pe_person.person_id%TYPE;
l_discontin_dt igs_en_stdnt_ps_att.discontinued_dt%TYPE;

l_unit_attempt_status igs_en_su_attempt.unit_attempt_status%TYPE := NULL ;
l_count NUMBER := 0 ;
l_message_name VARCHAR2(60) := NULL ;
l_message_token VARCHAR2(2000) := NULL ;

l_boolean BOOLEAN := TRUE;
l_legacy VARCHAR2(1) ;
l_commencement_dt igs_en_stdnt_ps_att.commencement_dt%TYPE;
l_prgm_ver igs_en_stdnt_ps_att.version_number%TYPE;

l_msg_count             NUMBER ;
l_msg_data              VARCHAR2(2000);
l_wlst_alwd             c_get_wlst_alwd_usec%ROWTYPE;
l_wlst_actual           NUMBER;
l_wlst_suas             NUMBER;
l_max_wlst_per_stud     NUMBER;
l_prog_version_spat     igs_en_stdnt_ps_att.version_number%TYPE;

l_relation_type igs_ps_unit_ofr_opt.relation_type%TYPE;
l_get_superior_usec_rec c_get_superior_usec%ROWTYPE;
l_sup_sub_status igs_en_su_attempt.unit_attempt_status%TYPE;
l_term_cal_dtls     c_get_term_cal%ROWTYPE;


BEGIN
    --added due to gscc warning
    l_legacy := 'Y';

    -- get version number for the course of a given person
    OPEN c_get_prog_ver(p_person_id, p_sua_dtls_rec.program_cd);
    FETCH c_get_prog_ver INTO l_prog_version_spat;
    CLOSE c_get_prog_ver;

    -- If imported sua is WAITLISTED, check whether waitlist is allowed and check that student is not crossing limit.
    IF  p_unit_attempt_status='WAITLISTED' THEN
      OPEN c_get_wlst_alwd_usec(p_uoo_id);
      FETCH c_get_wlst_alwd_usec INTO l_wlst_alwd;
      IF c_get_wlst_alwd_usec%NOTFOUND THEN
        OPEN c_get_wlst_alwd_oopt(p_uoo_id);
        FETCH c_get_wlst_alwd_oopt INTO l_wlst_alwd;
        CLOSE c_get_wlst_alwd_oopt;
      END IF;
      CLOSE c_get_wlst_alwd_usec;

      IF l_wlst_alwd.waitlist_allowed='N' THEN
        FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_WLST_NOT_ALWD' );
        FND_MSG_PUB.ADD;
        g_sua_status := 'INVALID';
      END IF;

      OPEN c_get_wlst_actual_usec(p_uoo_id);
      FETCH c_get_wlst_actual_usec INTO l_wlst_actual;
      CLOSE c_get_wlst_actual_usec;

      IF l_wlst_actual>=l_wlst_alwd.max_students_per_waitlist THEN
        FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_MAX_WAIT_REACH' );
        FND_MSG_PUB.ADD;
        g_sua_status := 'INVALID';
      END IF;

      -- get program level max_wlst_per_stud for the program in context
      OPEN c_max_wlst_stud_ps(p_sua_dtls_rec.program_cd, l_prog_version_spat);
      FETCH c_max_wlst_stud_ps INTO l_max_wlst_per_stud;
      CLOSE c_max_wlst_stud_ps;

      -- when program level max_wlst_per_stud is not defined, proceed to insitute level max_wlst_per_stud
      IF l_max_wlst_per_stud IS NULL THEN
        OPEN c_get_max_wlst_per_stud;
        FETCH c_get_max_wlst_per_stud INTO l_max_wlst_per_stud;
        CLOSE c_get_max_wlst_per_stud;
      END IF;

      --check if the sua violates the maximum waitlists per student
      OPEN c_get_wlst_suas (p_person_id,p_cal_type, p_ci_sequence_number); --cursor returns 'Y' if validation succeeds, null otherwise
      FETCH c_get_wlst_suas INTO l_wlst_suas;
      CLOSE c_get_wlst_suas;
      IF l_max_wlst_per_stud<=NVL(l_wlst_suas,0) THEN
        FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_MAX_WLST_STUD_RCH' );
        FND_MSG_PUB.ADD;
        g_sua_status := 'INVALID';
      END IF;
    END IF;

    -- Get the term calendar associated with the teaching calendar.
    OPEN c_get_term_cal(p_cal_type,p_ci_sequence_number);
    FETCH c_get_term_cal INTO l_term_cal_dtls;
    CLOSE c_get_term_cal;


    --  1. Derive Program Attempt Details
    l_program_attempt_status := igs_en_gen_legacy.validate_prgm_att_stat (
            p_person_id     => p_person_id ,
            p_course_cd     => p_sua_dtls_rec.program_cd ,
            p_discontin_dt  => l_discontin_dt ,
            p_program_type  => l_src_program_typ ,
            p_commencement_dt => l_commencement_dt ,
            p_version_number => l_prgm_ver ) ;
            p_primary_program_type := l_src_program_typ;

    -- added by ckasu as a part of bug #4095276
    --
    l_src_program_typ := igs_en_spa_terms_api.get_spat_primary_prg(p_person_id,p_sua_dtls_rec.program_cd,l_term_cal_dtls.load_cal_type,l_term_cal_dtls.load_ci_sequence_number);

    -- end of code added by ckasu as a part of bug #4095276

    --
    -- 2.       The Unit version that the student is trying to enroll in must not be planned.
    -- 3.       Unit section must have offered flag set.
    l_boolean := igs_en_val_sua.enrp_val_sua_uoo(
            p_unit_cd               => p_sua_dtls_rec.unit_cd ,
            p_version_number        => NVL( p_sua_dtls_rec.version_number , p_version_number  ) ,
            p_cal_type              => p_cal_type ,
            p_ci_sequence_number    => p_ci_sequence_number ,
            p_location_cd           => p_sua_dtls_rec.location_cd ,
            p_unit_class            => p_sua_dtls_rec.unit_class,
            p_message_name          => l_message_name ,
             p_legacy               => 'Y' ) ;

    IF l_message_name IS NOT NULL THEN
                g_sua_status := 'INVALID';
    END IF ;

    --
    -- Validate Program Attempt Status .
    -- 4.       If enrolled date is set, program attempt must be confirmed. Value of NULL is being passed for Commencement Date
    -- as the validation pertaining to that should be skipped in the routine enrp_val_sua_enr_dt.
    IF NOT igs_en_val_sua.enrp_val_sua_enr_dt (
        p_person_id             => p_person_id ,
        p_course_cd             => p_sua_dtls_rec.program_cd,
        p_enrolled_dt           => NVL( p_sua_dtls_rec.enrolled_dt , NULL) ,
        p_unit_attempt_status   => p_unit_attempt_status ,
        p_ci_end_dt             => p_ci_end_dt ,
        p_commencement_dt       => NULL ,
        p_message_name          => l_message_name ,
        p_legacy                => 'Y' )
        THEN

        g_sua_status := 'INVALID';

    END IF;

    --
    -- Validate Intermission Periods
    -- 5. Cannot enroll in teaching period within period of intermission (defined as intermission dates overlapping census date(s))
    BEGIN

	IF p_unit_attempt_status <> 'DISCONTIN' AND p_unit_attempt_status <> 'DROPPED' THEN

		IF NOT igs_en_val_sua.enrp_val_sua_intrmt (
		    p_person_id             => p_person_id ,
		    p_course_cd             => p_sua_dtls_rec.program_cd,
		    p_cal_type              => p_cal_type ,
		    p_ci_sequence_number    => p_ci_sequence_number ,
		    p_message_name          =>  l_message_name ) THEN

			FND_MESSAGE.SET_NAME( 'IGS' , l_message_name );
			    FND_MSG_PUB.ADD;
			    g_sua_status := 'INVALID';
		END IF ;

	END IF;

    EXCEPTION
        WHEN OTHERS THEN
                FND_MSG_PUB.COUNT_AND_GET ( p_count => l_msg_count ,
                                                        p_data  => l_msg_data);
                FND_MSG_PUB.DELETE_MSG(l_msg_count);
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_ST_CANT_DETR_CENSUS_DA');
                FND_MSG_PUB.ADD;
                g_sua_status := 'INVALID';
    END ;

    --
    -- Validate Unit version Repeatable
    -- 6.       Unit version cannot be enrolled if unit version is not repeatable and advanced standing has been already granted for the unit.
    BEGIN
        IF NOT igs_en_val_sua.enrp_val_sua_advstnd (
            p_person_id             => p_person_id ,
            p_course_cd             => p_sua_dtls_rec.program_cd,
            p_crs_version_number    => l_prgm_ver           ,
            p_unit_cd               => p_sua_dtls_rec.unit_cd ,
            p_un_version_number     => NVL( p_sua_dtls_rec.version_number , p_version_number  ) ,
            p_message_name          => l_message_name ,
             p_legacy               => 'Y' )
            THEN

                FND_MESSAGE.SET_NAME( 'IGS' , l_message_name );
                    FND_MSG_PUB.ADD;
                    g_sua_status := 'INVALID';
            END IF;
        EXCEPTION
        WHEN OTHERS THEN
                FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_AV_MAPADV_SUA_CANNOT_DTRM' );
                    FND_MSG_PUB.ADD;
                    g_sua_status := 'INVALID';
        END ;

    BEGIN

      -- Determine if the unit section is superior or subordinate.
      OPEN c_get_usec_relation(p_uoo_id);
      FETCH c_get_usec_relation INTO l_relation_type;
      CLOSE c_get_usec_relation;

      IF l_relation_type = 'SUBORDINATE' THEN

         -- If the unit section is SUBORDINATE, check whether the superior unit attempt exists.
         IF igs_en_sua_api.enr_sua_sup_sub_val(p_person_id              =>  p_person_id,
                                               p_course_cd              =>  p_sua_dtls_rec.program_cd,
                                               p_uoo_id                 =>  p_uoo_id,
                                               p_unit_attempt_status    =>  p_unit_attempt_status,
                                               p_sup_sub_status         =>  l_sup_sub_status)
         THEN

           -- If superior unit attempt exists, fetch the superior unit code and unit version number
           OPEN c_get_superior_usec(p_uoo_id);
           FETCH c_get_superior_usec INTO l_get_superior_usec_rec;
           CLOSE c_get_superior_usec;

           p_sup_unit_cd := l_get_superior_usec_rec.unit_cd;
           p_sup_unit_version_number := l_get_superior_usec_rec.version_number;

         ELSE

           FND_MESSAGE.SET_NAME('IGS','IGS_EN_LGCY_NO_SUPER');
           FND_MSG_PUB.ADD;
           g_sua_status := 'INVALID';

         END IF;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_SUA_API.ENR_SUA_SUP_SUB_VAL');
        g_sua_status := 'INVALID';

    END;

    --
    -- Validate subtitle titles
    -- 7.Alternative title is only permitted if unit version title override indicator is set.
    -- modified by ckasu as a part of bug #4642089 inorder to validate whethet Subtitle updation
    -- is allowed or not
    IF p_sua_dtls_rec.subtitle IS NOT NULL THEN

                OPEN c_sua_chg_alwd;
                FETCH c_sua_chg_alwd INTO l_sua_chg_alwd;
                CLOSE c_sua_chg_alwd;

                 IF l_sua_chg_alwd = 'N' THEN
                      FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_FAIL_SUA_SUBTIT_NOT_AWD' );
                      FND_MSG_PUB.ADD;
                      g_sua_status := 'INVALID';
                 END IF;

    END IF;

    --
    -- Verify unit version points override indicator
    -- 8.       Override achievable or enrolled credit points are only permitted if unit version points override indicator is set
    -- 9.       Override achievable CP must be within limits set by unit version/section min, max and increment values
    -- 10.      Override enrolled CP must be within limits set by unit version/section min, max and increment values

        BEGIN
            IF NOT igs_en_val_sua.enrp_val_sua_ovrd_cp  (
            p_unit_cd                => p_sua_dtls_rec.unit_cd ,
            p_version_number         => NVL( p_sua_dtls_rec.version_number , p_version_number ) ,
            p_override_enrolled_cp   => p_sua_dtls_rec.override_enrolled_cp             ,
            p_override_achievable_cp => p_sua_dtls_rec.override_achievable_cp           ,
            p_override_eftsu         => NULL ,
            p_message_name           => l_message_name ,
            p_uoo_id                 => p_uoo_id,
            p_no_assessment_ind      => p_no_assessment_ind
            )THEN
                FND_MESSAGE.SET_NAME( 'IGS' , l_message_name );
                    FND_MSG_PUB.ADD;
                    g_sua_status := 'INVALID';
        END IF;
        EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                    FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SUA.enrp_val_sua_ovrd_cp');
            g_sua_status := 'INVALID';
        END;

    --
    -- Validate Grading schema / version:
    -- 11.      Grading Schema Code/Version must be valid within the enrolling unit section/version
        IF p_sua_dtls_rec.grading_schema_code  IS NOT NULL AND p_sua_dtls_rec.gs_version_number IS NOT NULL THEN

            IF NOT igs_en_gen_legacy.validate_grad_sch_cd_ver (
            p_uoo_id                => p_uoo_id ,
            p_unit_cd               => p_sua_dtls_rec.unit_cd ,
                        p_Version_number        => NVL( p_sua_dtls_rec.version_number , p_version_number ) ,
                        p_Grading_schema_code   => p_sua_dtls_rec.grading_schema_code,
            p_Gs_Version_number     => p_sua_dtls_rec.gs_version_number ,
            p_message_name          => l_message_name ) THEN

                FND_MESSAGE.SET_NAME( 'IGS' , l_message_name );
                    FND_MSG_PUB.ADD;
                    g_sua_status := 'INVALID';
            END IF;

        END IF;

    --
    -- Validate Program Attempt Status :
    -- 12.      If enrolled date is set, then program attempt status cannot be Unconfirmed.
        IF p_sua_dtls_rec.enrolled_dt IS NOT NULL THEN
                IF l_program_attempt_status = 'UNCONFIRM' THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_ENRDT_NOT_ENTERED_SPA' );
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
            END IF ;
        END IF;

    --
    -- 13.      Enrolled unit attempts cannot be added within a discontinued or completed program.
        IF l_program_attempt_status in ('DISCONTIN', 'COMPLETED') and p_unit_attempt_status = 'ENROLLED' THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_SUA_SPA_MISMTCH');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
        END IF;

    --
    -- Validate DISCONTINUED Program Attempt Status :
    -- 14.      If program attempt is discontinued, then the teaching period start date cannot be after the discontinued date of the program.
        IF l_program_attempt_status = 'DISCONTIN' AND p_ci_start_dt > TRUNC(p_sua_dtls_rec.discontinued_dt) THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_TCH_PRD_AFT_DIS');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
        END IF;

    --
    -- Validate Primary Program Type :
    -- 15.      If career centric, and program is a secondary (ie. non-primary) program then Enrolled units cannot be attached.
    IF p_career_model_enabled = 'Y' AND l_src_program_typ = 'SECONDARY' AND p_unit_attempt_status = 'ENROLLED' THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_ENR_UNT_SEC_PRGM');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
        END IF ;

    --
    -- Validate Enrolled Date :
    -- 16.      If unit attempt is not duplicate, then the enrolled date cannot be prior to the program commencement (start) date.
    IF p_unit_attempt_status <> 'DUPLICATE'   AND p_sua_dtls_rec.enrolled_dt  IS NOT NULL AND TRUNC(p_sua_dtls_rec.enrolled_dt) < l_commencement_dt THEN
        FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_SUA_BF_STAMPT' );
        FND_MSG_PUB.ADD;
        g_sua_status := 'INVALID';
    END IF ;

    -- check to see if the load calendar (corresponding to the teaching calendar) end date is greater than the
    -- commencement date of the program attempt for ENROLLED, DISCONTIN, WAITLISTED and INVALID.
    IF p_unit_attempt_status IN ('ENROLLED','DISCONTIN','WAITLISTED','INVALID') THEN
        IF l_term_cal_dtls.load_end_dt    <  l_commencement_dt THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_SUA_BF_STAMPT' );
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
        END IF;
    END IF;


    --
    -- Validate Research Units
    -- 17.      Research unit must have teaching period covered by research supervision.
    -- 18.      Must have research candidature to enroll in research unit
        l_boolean := igs_en_val_sua.resp_val_sua_cnfrm (
            p_person_id             => p_person_id ,
            p_course_cd             => p_sua_dtls_rec.program_cd,
            p_unit_cd               => p_sua_dtls_rec.unit_cd ,
            p_version_number        => NVL( p_sua_dtls_rec.version_number , p_version_number ) ,
            p_cal_type              => p_cal_type ,
            p_ci_sequence_number    => p_ci_sequence_number,
            p_message_name          => l_message_name ,
             p_legacy               => 'Y' ) ;
        IF l_message_name  IS NOT  NULL THEN
                g_sua_status := 'INVALID';
        END IF ;

    --
    -- Validations for Dropped / Discontinuation Units :
        IF (p_sua_dtls_rec.dcnt_reason_cd IS NOT NULL OR p_sua_dtls_rec.discontinued_dt IS NOT NULL OR
        p_sua_dtls_rec.administrative_unit_status IS NOT NULL OR p_sua_dtls_rec.dropped_ind IS NOT NULL) THEN

        -- Validate Dropped / Discontinuation Date
        -- 19.  Discontinued date cannot be a future date.
        -- 20.  Discontinued date cannot be prior to unit attempt enrolled date.
        -- 21.  Discontinued date must be set if administrative unit status is set.
            l_boolean := igs_en_val_sua.enrp_val_sua_discont(
            p_person_id             => p_person_id ,
            p_course_cd             => p_sua_dtls_rec.program_cd,
            p_unit_cd               => p_sua_dtls_rec.unit_cd ,
            p_version_number        => NVL( p_sua_dtls_rec.version_number , p_version_number ) ,
            p_ci_start_dt           => p_ci_start_dt ,
            p_enrolled_dt           => p_sua_dtls_rec.enrolled_dt,
            p_administrative_unit_status => NVL( p_sua_dtls_rec.administrative_unit_status , p_administrative_unit_status),
            p_unit_attempt_status   => p_unit_attempt_status ,
            p_discontinued_dt       => p_sua_dtls_rec.discontinued_dt,
            p_message_name          => l_message_name ,
            p_legacy                => 'Y' ) ;
            IF l_message_name IS NOT NULL THEN

                g_sua_status := 'INVALID';
            END IF;

        --
        -- 22.  Administrative unit status can only be set if discontinued date is set.
        -- 23.  Administrative unit status must be set if discontinued date is set.
        -- 24.  If administrative unit status is set, then must be able to determine applicable grade from setup.
                l_boolean := igs_en_val_sua.enrp_val_discont_aus(
                        p_administrative_unit_status    => NVL( p_sua_dtls_rec.administrative_unit_status , p_administrative_unit_status),
                        p_discontinued_dt               => p_sua_dtls_rec.discontinued_dt ,
                        p_cal_type                      => p_cal_type                      ,
                        p_ci_sequence_number            => p_ci_sequence_number            ,
                        p_message_name                  => l_message_name ,
                        p_uoo_id                        => p_uoo_id ,
                        p_message_token                 => l_message_token ,
                        p_legacy                        => 'Y' );
            IF l_message_name IS NOT NULL THEN
                g_sua_status := 'INVALID';
                END IF ;

        -- Validate Discontinuation Reason Code :
        -- 25.  Discontinuation reason code must match a row with the unit flag set
        IF p_sua_dtls_rec.dcnt_reason_cd IS NOT NULL THEN
            IF NOT igs_en_gen_legacy.validate_disc_rsn_cd (p_discontinuation_reason_cd => p_sua_dtls_rec.dcnt_reason_cd) THEN
                g_sua_status := 'INVALID';
            END IF ;
        END IF;

        --
        -- 26.  Discontinuation reason code can only be set when discontinued date is set
        IF p_sua_dtls_rec.dcnt_reason_cd IS NOT NULL AND p_sua_dtls_rec.discontinued_dt IS NULL THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_DISC_RSN_CD_INV');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
            END IF ;

        -- Validate Dropped Indicator :
        -- 27.  If dropped indicator is set then enrolled date must be set
            IF p_sua_dtls_rec.dropped_ind = 'Y' AND p_sua_dtls_rec.enrolled_dt IS NULL THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_SUA_ENR_DT_NT_SET');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
            END IF ;

        -- 28.  If dropped indicator is set then discontinued date must not be set
            IF p_sua_dtls_rec.dropped_ind = 'Y' AND p_sua_dtls_rec.discontinued_dt IS NOT NULL THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_SUA_DRP_DISN_INV');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
            END IF ;

        END IF ;

    -- Validate Transfer Program Code 29-30
    -- 29.      Transfer program code cannot be the same as the program of the unit attempt being imported.

        IF p_sua_dtls_rec.transfer_program_cd IS NOT NULL THEN
            IF p_sua_dtls_rec.transfer_program_cd = p_sua_dtls_rec.program_cd THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_TOPRG_TRNS_FROM_PRG');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
            END IF;
        END IF ;

    -- 30.      If Transfer Date is specified , Transfer Program Code should be specified and vice versa.
        IF (p_sua_dtls_rec.transfer_program_cd IS NOT NULL AND p_sua_dtls_rec.transfer_dt is NULL )
        OR (p_sua_dtls_rec.transfer_program_cd IS NULL AND p_sua_dtls_rec.transfer_dt IS NOT NULL ) THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_TRN_DTLS_INCOMPL');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
        END IF ;

    -- Validate unit to be transferred
    -- 31.      If any of the transfer columns are specified, then another unit attempt must exist with matching person id,
    -- transfer program code, unit code, teaching alternate code (resolved to calendar type and sequence number),
    -- location code and unit class.

    IF (p_sua_dtls_rec.transfer_program_cd IS NOT NULL OR p_sua_dtls_rec.transfer_dt IS NOT NULL )  THEN

        IF NOT igs_en_gen_legacy.validate_trn_unit (
                 p_person_id             =>  p_person_id ,
                 p_program_cd            =>  p_sua_dtls_rec.transfer_program_cd ,
                 p_cal_type              =>  p_cal_type              ,
                 p_ci_sequence_number    =>  p_ci_sequence_number  ,
                 p_unit_cd               =>  p_sua_dtls_rec.unit_cd             ,
                 p_location_cd           =>  p_sua_dtls_rec.location_cd         ,
                 P_unit_class            =>  p_sua_dtls_rec.unit_class          ,
                 p_unit_attempt_status   =>  l_unit_attempt_status   ) THEN
                    g_sua_status := 'INVALID';
        END IF;

        --
        -- Validate Discontinuation reason code of Program
        -- If unit transfer, and source program attempt is discontinued then it must have a reason code of type 'TRANSFER'

        IF NOT igs_en_gen_legacy.validate_transfer (
                        p_person_id             => p_person_id ,
                        p_transfer_program_cd   =>  p_sua_dtls_rec.transfer_program_cd  ) THEN
                        g_sua_status := 'INVALID';
        END IF;

    END IF ;

    -- Validate Transfer Date
        IF p_sua_dtls_rec.transfer_dt IS NOT NULL AND ( p_sua_dtls_rec.enrolled_dt IS NOT NULL OR p_sua_dtls_rec.discontinued_dt IS NOT NULL OR
            p_sua_dtls_rec.administrative_unit_status IS NOT NULL OR p_sua_dtls_rec.dcnt_reason_cd IS NOT NULL OR
            p_sua_dtls_rec.no_assessment_ind IS NOT NULL OR p_sua_dtls_rec.override_enrolled_cp IS NOT NULL OR
        p_sua_dtls_rec.override_achievable_cp IS NOT NULL OR p_sua_dtls_rec.grading_schema_code IS NOT NULL OR
        p_sua_dtls_rec.gs_version_number IS NOT NULL OR p_sua_dtls_rec.subtitle IS NOT NULL OR
            p_sua_dtls_rec.outcome_dt IS NOT NULL OR p_sua_dtls_rec.mark IS NOT NULL OR p_sua_dtls_rec.grade IS NOT NULL ) THEN
                    FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_TRNSFR_DT_SET');
                    FND_MSG_PUB.ADD;
                    g_sua_status := 'INVALID';
        END IF ;

    -- Validate Grade /Mark
    --38.       Grade can only be set when outcome date is set, and visa versa.
        IF p_sua_dtls_rec.outcome_dt IS NULL AND p_sua_dtls_rec.grade IS NOT NULL THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_OTCME_DT_REQD');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
            END IF ;

            IF p_sua_dtls_rec.outcome_dt IS NOT NULL AND p_sua_dtls_rec.grade IS NULL THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_OTCME_DT_NT_SET');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
            END IF ;

        -- 39.  Mark can only be set when outcome date is set.
            IF p_sua_dtls_rec.outcome_dt IS NULL AND p_sua_dtls_rec.mark IS NOT NULL THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_OTCME_DT_REQD');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
            END IF ;

        -- 40.If grade set and outcome grading schema code and version are not set, then grade must exist in the unit section default grading schema.
            IF p_sua_dtls_rec.grade IS NOT NULL AND (p_sua_dtls_rec.outcome_grading_schema_code IS NULL
            AND p_sua_dtls_rec.outcome_gs_version_number IS NULL ) THEN
                IF NOT igs_en_gen_legacy.validate_grading_schm (
                                p_grade                       => p_sua_dtls_rec.grade ,
                                p_uoo_id                      => p_uoo_id ,
                                p_unit_cd                     => p_sua_dtls_rec.unit_cd ,
                                p_version_number              => NVL( p_sua_dtls_rec.version_number , p_version_number ) )THEN
                                    g_sua_status := 'INVALID';
                END IF;
            END IF ;

    -- Validate outcome Date
    -- 41.      If outcome date set, then enrolled date must be set and discontinued must not be set.
        IF (p_sua_dtls_rec.outcome_dt IS NOT NULL AND p_sua_dtls_rec.enrolled_dt IS NULL ) OR
        (p_sua_dtls_rec.outcome_dt IS NOT NULL AND p_sua_dtls_rec.discontinued_dt IS NOT NULL) THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_OUTCME_DT_NREQD');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
        END IF ;

    -- 42.If adding completed unit attempt to a discontinued program attempt, the outcome date cannot be after the discontinuation date.
    IF l_program_attempt_status = 'DISCONTIN' AND p_sua_dtls_rec.outcome_dt  IS NOT NULL THEN

        OPEN get_prgm_discd_dt;
        FETCH get_prgm_discd_dt INTO l_prgm_discontinued_dt;
        CLOSE get_prgm_discd_dt ;

        IF  p_sua_dtls_rec.outcome_dt > l_prgm_discontinued_dt THEN
            FND_MESSAGE.SET_NAME( 'IGS' ,'IGS_EN_TRNSFER_INV');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
                END IF ;
        END IF ;

    -- Validate waitlist Date
    -- 43.      If waitlist date is set, then enrolled date and discontinued date must not be set.
    IF  p_sua_dtls_rec.waitlisted_dt IS NOT NULL AND ( p_sua_dtls_rec.discontinued_dt IS NOT NULL OR p_sua_dtls_rec.enrolled_dt IS NOT NULL ) THEN
            FND_MESSAGE.SET_NAME( 'IGS', 'IGS_EN_ENR_CNT_WAITLST' );
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
        END IF ;

    --
    -- Validate Auditable
    IF NVL( p_sua_dtls_rec.no_assessment_ind , p_no_assessment_ind ) = 'Y' THEN
    --check if auditable flag is set at Unit section level .

            OPEN get_audit_usec;
            FETCH get_audit_usec INTO l_auditable_ind ;
            CLOSE get_audit_usec ;

            IF l_auditable_ind <> 'Y' THEN
                    --check if auditable flag is set at Unit level .
            FND_MESSAGE.SET_NAME( 'IGS', 'IGS_EN_NO_ASS_IND_INV');
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
            END IF ;
        END IF ;

     l_message_name := NULL;
     IF NOT igs_en_elgbl_unit.eval_award_prog_only(
                     p_person_id                    => p_person_id,
                     p_person_type                  => NULL,
                     p_load_cal_type                => l_term_cal_dtls.load_cal_type,
                     p_load_sequence_number         => l_term_cal_dtls.load_ci_sequence_number,
                     p_uoo_id                       => p_uoo_id,
                     p_course_cd                    => p_sua_dtls_rec.program_cd,
                     p_course_version               => l_prog_version_spat,
                     p_message                      => l_message_name,
                     p_calling_obj                  => 'JOB'
       ) THEN

       IF l_message_name IS NOT NULL THEN
            FND_MESSAGE.SET_NAME( 'IGS', l_message_name);
            FND_MSG_PUB.ADD;
            g_sua_status := 'INVALID';
       END IF;

     END IF;

END validate_sua ;

PROCEDURE create_sua (      p_api_version           IN   NUMBER,
                            p_init_msg_list         IN   VARCHAR2 ,
                            p_commit                IN   VARCHAR2 ,
                            p_validation_level      IN   NUMBER  ,
                            p_sua_dtls_rec          IN   sua_dtls_rec_type ,
                            x_return_status         OUT  NOCOPY VARCHAR2,
                            x_msg_count             OUT  NOCOPY NUMBER,
                            x_msg_data              OUT  NOCOPY VARCHAR2)
 AS
/*------------------------------------------------------------------
Created By        : SVENKATA
Date Created By   : 12-NOV-02
Purpose           : This routine is public in the API. The user makes a call to this routine to import
                    Legacy Data onto OSS Tables. The routine validates data passed to it and inserts them
                    into the corresponding OSS tables.
Known limitations,
enhancements,
remarks           :
Change History
Who      When        What
svenkata 16-dec-02   Bug # 2708674 - columns No assessment indicator , student career transcript and student
                     career statistics not defaulted.
svenkata 30-Dec-02   Derived the Status of the Unit as COMPLETED if Grade is mentioned.Bug# 2727922
kkillams 29-04-2003  Impacted object, due to change in the signature of the igs_en_gen_007.enrp_get_sua_status function
                     w.r.t. bug number 2829262
rvangala 01-OCT-2003 Added core_indicator value in the INSERT statements, added as part of Prevent Dropping Core Units. Enh Bug# 3052432
ptandon  17-OCT-2003 Modified call to validate_sua to take into consideration two new OUT parameters p_sup_unit_cd and
                     p_sup_unit_version_number and pass these values in the insert statements for IGS_EN_SU_ATTEMPT_ALL as part
                     of Placements build. Enh Bug# 3052438.
------------------------------------------------------------------*/

    --
    -- Cursor to get transfer Details
        CURSOR get_sua_trn (p_uoo_id IN NUMBER , p_person_id IN NUMBER , p_transfer_program_cd IN VARCHAR2 , P_unit_cd IN VARCHAR2 ) IS
        SELECT enrolled_dt, discontinued_dt, administrative_unit_status, dcnt_reason_cd,
    no_assessment_ind, override_enrolled_cp, override_achievable_cp,
    grading_schema_code, gs_version_number, subtitle, attribute_category ,
    attribute1  , attribute2  , attribute3  , attribute4  , attribute5  , attribute6,
    attribute7  , attribute8  , attribute9  , attribute10 , attribute11 , attribute12 ,
    attribute13 , attribute14 , attribute15 , attribute16 , attribute17  , attribute18 ,
    attribute19 , attribute20,upd_audit_flag,ss_source_ind
        FROM igs_en_su_attempt sua
        WHERE sua.person_id = p_person_id AND
    sua.course_cd = p_transfer_program_cd AND
    sua.unit_cd = p_unit_cd AND
    sua.uoo_id = p_uoo_id;


    CURSOR c_lock_parent_usec (cp_uoo_id IN NUMBER) IS
    SELECT uoo_id
    FROM igs_ps_unit_ofr_opt
    WHERE uoo_id=cp_uoo_id
    FOR UPDATE;

    CURSOR c_admin_pri (cp_uoo_id igs_en_su_attempt.uoo_id%TYPE,cp_waitlist_dt DATE) IS
    SELECT NVL(MAX(administrative_priority),0)+1
    FROM igs_en_su_attempt
    WHERE uoo_id=cp_uoo_id
    AND waitlist_dt<=cp_waitlist_dt
    AND unit_attempt_status='WAITLISTED';


    TYPE sua_trnsfr_rec_tbl IS TABLE OF  get_sua_trn%ROWTYPE INDEX BY BINARY_INTEGER ;
    sua_trnsfr_rec sua_trnsfr_rec_tbl;

    l_api_name              CONSTANT    VARCHAR2(30) := 'create_sua';
    l_api_version           CONSTANT    NUMBER       := 1.0;
    l_insert_flag           BOOLEAN := TRUE;

    l_primary_program_type igs_en_sca_v.course_type%TYPE ;
    l_person_id igs_pe_person.person_id%TYPE;
    l_adm_unit_status_ret igs_en_su_attempt.administrative_unit_Status %TYPE;
    l_adm_unit_status VARCHAR2(2000);
    l_alias_val igs_ca_da_inst.absolute_val%TYPE  ;

    l_org_unit_cd igs_or_unit.org_unit_cd%TYPE;
    l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE;
    l_cal_type igs_en_su_attempt.cal_type%TYPE;
    l_ci_sequence_number igs_en_su_attempt.ci_Sequence_number%TYPE;
    l_ci_start_dt igs_ca_inst.start_dt%TYPE;

    l_ci_end_dt igs_ca_inst.end_dt%TYPE;
    l_version_number igs_en_su_attempt.version_number%TYPE;
    l_unit_attempt_status igs_en_su_attempt.unit_attempt_status%TYPE;
    l_program_attempt_status igs_en_Stdnt_ps_Att.course_attempt_status%TYPE;
    l_career_model_enabled VARCHAR2(1);
    l_return_status VARCHAR2(30);

    l_cart_status VARCHAR2(1);

    l_count NUMBER := 0;
    l_first_char NUMBER := 0;
    l_current_string VARCHAR2(300) := NULL;
    l_msg_count         NUMBER ;
    l_msg_data          VARCHAR2(2000);

    l_creation_date         igs_en_su_attempt.creation_date%TYPE;
    l_last_update_date      igs_en_su_attempt.last_update_date%TYPE;
    l_created_by            igs_en_su_attempt.created_by%TYPE;
    l_last_updated_by       igs_en_su_attempt.last_updated_by%TYPE;
    l_last_update_login     igs_en_su_attempt.last_update_login%TYPE;
    l_request_id            igs_en_su_attempt.request_id%TYPE;
    l_program_id            igs_en_su_attempt.program_id%TYPE;
    l_program_application_id igs_en_su_attempt.program_application_id%TYPE;
    l_program_update_date   igs_en_su_attempt.program_update_date%TYPE;
    l_no_assessment_ind     igs_en_su_attempt.no_assessment_ind%TYPE;
    l_student_career_transcript     igs_en_su_attempt.student_career_transcript%TYPE;
    l_student_career_statistics     igs_en_su_attempt.student_career_statistics%TYPE;
    l_pref_weight                   NUMBER;
    l_pri_weight                    NUMBER;
    l_wlst_position                 NUMBER;

    l_sup_unit_cd                   igs_ps_unit_ofr_opt.unit_cd%TYPE;
    l_sup_unit_version_number       igs_ps_unit_ofr_opt.version_number%TYPE;
    cst_duplicate           CONSTANT IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'DUPLICATE';
    l_stat_sua_status               igs_en_su_attempt.unit_attempt_status%TYPE;
    l_override_enrollment_cp        igs_en_su_attempt.override_enrolled_cp%TYPE;
    l_override_achievable_cp        igs_en_su_attempt.override_achievable_cp%TYPE;
    --
    -- The architecture of the Insert API is briefly described below. The validatins are done in the order mentioned below.
    -- 1. The routine validate_parameters is invoked to validate all params for Mandatory/check constraints
    -- 2. All required parameters are derived .
    -- 3. The DB constraints are validated by making a call to validate_db_cons.
    -- 4. Validate all Business rules by making a call to validate_sua.
    -- 5. If transfer Details are applicable, validate and Insert Iransfer Details.
    -- 6. Insert Student Unit Attempt Details.If transfer is applicable, insert values derived from source Unit Attempt.
    -- 7. Call post validation routines.This routine takes care of the following :
    -- Increment Unit section actual enrollment .
    -- Insert Student Unit Attempt Outcome details
    -- Re-derive the Program Attempt status. Update the SPA record with the new status.
    -- NOte : If an exception is encountered during any operation , the database is rolled back to a consistent
    -- state. A status of Unexpected error is returned to the calling Program . The Exception is not propogated to
    -- the calling routine.
    --

BEGIN

    -- Create a savepoint
    SAVEPOINT    CREATE_SUA_PUB;

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
    g_sua_status := 'VALID';

    --
    -- Derive default values if value is NULL
    IF p_sua_dtls_rec.no_assessment_ind  IS NULL THEN
        l_no_assessment_ind  := 'N';
    ELSE
        l_no_assessment_ind  := p_sua_dtls_rec.no_assessment_ind;
    END IF ;

    IF p_sua_dtls_rec.student_career_transcript IS NULL THEN
        l_student_career_transcript := 'Y';
    END IF ;

    IF p_sua_dtls_rec.student_career_statistics IS NULL THEN
        l_student_career_statistics := 'Y' ;
    END IF ;

    -- added by vijrajag for bug # 4235458
    IF l_no_assessment_ind = 'Y' THEN

            l_override_enrollment_cp := 0;
            l_override_achievable_cp  := 0;
    ELSE
           l_override_enrollment_cp := NVL(IGS_EN_GEN_015.enrp_get_appr_cr_pt(l_person_id,l_uoo_id),
                                            p_sua_dtls_rec.override_enrolled_cp);
           l_override_achievable_cp  := NVL(IGS_EN_GEN_015.enrp_get_appr_cr_pt(l_person_id,l_uoo_id),
                                            p_sua_dtls_rec.override_achievable_cp);
    END IF;

    -- 1.Validate Parameters
    validate_parameters(p_sua_dtls_rec => p_sua_dtls_rec);

    -- 2.Derive all required parameters
    IF g_sua_status <>  'INVALID' THEN

      -- Derive Person ID
      l_person_id := igs_ge_gen_003.get_person_id ( p_person_number => p_sua_dtls_rec.person_number) ;
      IF l_person_id IS NULL THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_GE_INVALID_PERSON_NUMBER');
                    FND_MSG_PUB.ADD;
                        g_sua_status := 'INVALID';
            END IF;

      -- Derive Calendar Details.
      igs_ge_gen_003.get_calendar_instance(
            p_alternate_cd    => p_sua_dtls_rec.teach_calendar_alternate_code ,
            p_s_cal_category  => '''TEACHING''',
            p_cal_type        => l_cal_type ,
            p_ci_sequence_number => l_ci_sequence_number ,
            p_start_dt        => l_ci_start_dt ,
            p_end_dt          => l_ci_end_dt ,
            p_return_status   => l_return_status );

        IF l_return_status = 'INVALID' THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_ALT_CD_NO_CAL_FND ');
            FND_MSG_PUB.ADD;
                        g_sua_status := 'INVALID';
            ELSIF l_return_status =  'MULTIPLE' THEN
            FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_MULTI_TCH_CAL_FND');
            FND_MSG_PUB.ADD;
                        g_sua_status := 'INVALID';
            END IF ;

      -- Derive Unit version if parameter is NULL.
      IF p_sua_dtls_rec.version_number IS NULL THEN
        IF NOT igs_en_gen_legacy.get_unit_ver (
                p_cal_type          =>  l_cal_type ,
                p_ci_sequence_number => l_ci_sequence_number ,
                p_unit_cd           =>  p_sua_dtls_rec.unit_cd ,
                p_location_cd       =>  p_sua_dtls_rec.location_cd ,
                P_unit_class        =>  p_sua_dtls_rec.unit_class ,
                p_version_number    =>  l_version_number )  THEN

                        g_sua_status := 'INVALID';
        END IF;

      END IF;

    -- Derive uoo_id
    IF NOT igs_en_gen_legacy.get_uoo_id (
                p_cal_type              =>  l_cal_type ,
                p_ci_sequence_number     => l_ci_sequence_number ,
                p_unit_cd               =>  p_sua_dtls_rec.unit_cd ,
                p_location_cd           =>  p_sua_dtls_rec.location_cd ,
                P_unit_class            =>  p_sua_dtls_rec.unit_class ,
                p_version_number        =>  NVL ( p_sua_dtls_rec.version_number,l_version_number) ,
                p_uoo_id                =>  l_uoo_id                ,
                p_owner_org_unit_cd     =>  l_org_unit_cd ) THEN

                g_sua_status := 'INVALID';
    END IF ;


      --Derive Unit Attempt Status
      IF p_sua_dtls_rec.dropped_ind = 'Y' THEN
          l_unit_attempt_status := 'DROPPED';
      ELSIF p_sua_dtls_rec.grade IS NOT NULL THEN
          l_unit_attempt_status := 'COMPLETED';
      ELSE
            -- IF p_sua_dtls_rec.transfer_dt IS NOT NULL OR p_sua_dtls_rec.outcome_dt IS NOT NULL OR THEN
            -- The Unit Attempt Status is passed as 'LEGACY' to the routine 'cos if NULL is passed , it tries to query the
            -- Unit Attempt Status that exists in the system , which is not valid for Legacy.
            l_unit_attempt_status := igs_en_gen_007.enrp_get_sua_status(
                                      p_person_id             => l_person_id ,
                                      p_course_cd             => p_sua_dtls_rec.program_cd ,
                                      p_unit_cd               => p_sua_dtls_rec.unit_cd,
                                      p_version_number        => NVL(p_sua_dtls_rec.version_number,l_version_number) ,
                                      p_cal_type              => l_cal_type,
                                      p_ci_sequence_number    => l_ci_sequence_number ,
                                      p_unit_attempt_status   => 'LEGACY',
                                      p_enrolled_dt           => p_sua_dtls_rec.enrolled_dt,
                                      p_rule_waived_dt        => NULL,
                                      p_discontinued_dt       => p_sua_dtls_rec.discontinued_dt,
                                      p_waitlisted_dt         => p_sua_dtls_rec.waitlisted_dt,
                                      p_uoo_id                => l_uoo_id);
      END IF;

      -- Derive Transfer Details of Transfer Date is mentioned
      IF p_sua_dtls_rec.transfer_dt IS NOT NULL THEN

          OPEN get_sua_trn (l_uoo_id , l_person_id ,p_sua_dtls_rec.transfer_program_cd ,p_sua_dtls_rec.unit_cd  ) ;
          FETCH get_sua_trn INTO sua_trnsfr_rec(1) ;
          IF get_sua_trn%NOTFOUND THEN
              FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_TRNSFR_UNT_NT_FND');
              FND_MSG_PUB.ADD;
              g_sua_status := 'INVALID';
          END IF ;
          CLOSE get_sua_trn ;

      END IF;

      -- Derive Administrative Unit Status
      IF p_sua_dtls_rec.discontinued_dt IS NOT NULL AND p_sua_dtls_rec.administrative_unit_status IS NULL THEN
                 l_adm_unit_status_ret := igs_en_gen_008.enrp_get_uddc_aus  (
                            p_discontinued_dt => p_sua_dtls_rec.discontinued_dt ,
                                    p_cal_type => l_cal_type,
                                    p_ci_sequence_number => l_ci_sequence_number,
                                    p_admin_unit_status_str => l_adm_unit_status,
                                    p_alias_val => l_alias_val,
                                    p_uoo_id => l_uoo_id);

    --
        -- The logic below should be incorporated to ensure that an error message is returned when multiple administrative_unit_status
        -- is returned by the routine enrp_get_uddc_aus.

                  IF l_adm_unit_status_ret IS NULL THEN

                      l_adm_unit_status_ret := NULL;
                      l_first_char := 1;
                      LOOP

                            -- exit when the end of the string is reached
                                    EXIT WHEN l_first_char >= LENGTH(l_adm_unit_status);

                            -- put 10 characters at a a time into a string for comparison
                                    l_current_string := (SUBSTR(l_adm_unit_status, l_first_char, 10));
                        --1.Don't do anything if the string is null

                                    IF (l_current_string IS NULL) THEN
                                            EXIT;
                                    ELSE
                                        IF l_adm_unit_status_ret IS NULL THEN
                                            l_adm_unit_status_ret := RTRIM(RPAD(l_current_string,10,' '));
                                        ELSE
                                    l_adm_unit_status_ret := l_adm_unit_status_ret||','||RTRIM(RPAD(l_current_string,10,' '));
                                        END IF;
                                        l_first_char := l_first_char + 11;
                                    END IF;

                      END LOOP;
                      FND_MESSAGE.SET_NAME( 'IGS' , 'IGS_EN_ADM_UNT_STAT_INV');
                      FND_MSG_PUB.ADD;
                      g_sua_status := 'INVALID';

                  END IF;
           END IF;

        -- Derive the Value of Profile for Career model Enabled.
        IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') =  'Y' THEN
            l_career_model_enabled := 'Y';
            ELSE
                        l_career_model_enabled := 'N';
        END IF;

  END IF; -- End Derivations.

  IF g_sua_status <> 'INVALID' THEN

    -- 3. The DB constraints are validated by making a call to validate_db_cons.
    validate_db_cons (  p_person_id                     => l_person_id ,
                        p_unit_version_number   => l_version_number ,
                        p_uoo_id                        => l_uoo_id ,
                        p_cal_type                      => l_cal_type ,
                        p_ci_sequence_number    => l_ci_Sequence_number ,
                        p_sua_dtls_rec          => p_sua_dtls_rec ) ;

  END IF;

  IF g_sua_status NOT IN ( 'INVALID' , 'WARNING' ) THEN

        -- 4. Validate all Business rules by making a call to validate_sua.

        validate_sua(  p_person_id              => l_person_id ,
                       p_version_number         => l_version_number ,
                       p_sua_dtls_rec           => p_sua_dtls_rec ,
                       p_cal_type               => l_cal_type ,
                       p_ci_sequence_number     => l_ci_Sequence_number ,
                       p_ci_end_dt              => l_ci_end_dt ,
                       p_ci_start_dt            => l_ci_start_dt ,
                       p_unit_attempt_status    => l_unit_attempt_status    ,
                       p_uoo_id                 => l_uoo_id                 ,
                       p_career_model_enabled   => l_career_model_enabled ,
                       p_administrative_unit_status     => l_adm_unit_status_ret,
                       p_no_assessment_ind      => l_no_assessment_ind  ,
                       p_primary_program_type  => l_primary_program_type ,
                       p_sup_unit_cd             => l_sup_unit_cd ,
                       p_sup_unit_version_number => l_sup_unit_version_number
                      ) ;
  END IF ;

  IF g_sua_status NOT IN ( 'INVALID' , 'WARNING' ) AND p_sua_dtls_rec.transfer_dt IS NOT NULL THEN
        validate_pre_sua(   p_person_id             => l_person_id ,
                            p_sua_dtls_rec          => p_sua_dtls_rec ,
                            p_version_number        => l_version_number,
                            p_cal_type              => l_cal_type ,
                            p_ci_sequence_number    => l_ci_Sequence_number,
                            p_uoo_id                => l_uoo_id);

        IF g_sua_status <> 'INVALID'  THEN
            --
            -- Re-derive the Unit Attempt status
            -- The Unit Attempt Status is passed as 'LEGACY' to the routine 'cos if NULL is passed , it tries to query the
            -- Unit Attempt Status that exists in the system , which is not valid for Legacy.
            l_unit_attempt_status := igs_en_gen_007.enrp_get_sua_status(
               p_person_id             => l_person_id ,
               p_course_cd             => p_sua_dtls_rec.program_cd ,
               p_unit_cd               => p_sua_dtls_rec.unit_cd,
               p_version_number        => NVL ( p_sua_dtls_rec.version_number,l_version_number) ,
               p_cal_type              => l_cal_type,
               p_ci_sequence_number    => l_ci_sequence_number ,
               p_unit_attempt_status   => 'LEGACY' ,
               p_enrolled_dt           => sua_trnsfr_rec(1).enrolled_dt,
               p_rule_waived_dt        => NULL,
               p_discontinued_dt       => sua_trnsfr_rec(1).discontinued_dt,
               p_waitlisted_dt         => p_sua_dtls_rec.waitlisted_dt,
               p_uoo_id                => l_uoo_id) ;
        END IF ;

  END IF;

  IF g_sua_status NOT IN ( 'INVALID' , 'WARNING' ) THEN

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

       l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
       l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
       l_program_application_id := FND_GLOBAL.PROG_APPL_ID;

       IF (l_request_id = -1) THEN
            l_request_id := NULL;
            l_program_id := NULL;
            l_program_application_id := NULL;
            l_program_update_date := NULL;
       ELSE
            l_program_update_date := SYSDATE;
       END IF;


       l_pri_weight:=NULL;
       l_pref_weight:=NULL;
       l_wlst_position:=NULL;
       g_wlst_pri_pref_exists:=FALSE;
       IF l_unit_attempt_status='WAITLISTED' THEN
       igs_en_wlst_gen_proc.enrp_wlst_pri_pref_calc( p_person_id         => l_person_id,
                                                      p_program_cd       => p_sua_dtls_rec.program_cd,
                                                      p_uoo_id           => l_uoo_id,
                                                      p_priority_weight  => l_pri_weight,
                                                      p_preference_weight=> l_pref_weight);



         IF l_pri_weight IS NOT NULL AND l_pref_weight IS NOT NULL THEN
           g_wlst_pri_pref_exists:=TRUE;
         ELSE
           OPEN c_lock_parent_usec(l_uoo_id);
           CLOSE c_lock_parent_usec;
           OPEN c_admin_pri (l_uoo_id,p_sua_dtls_rec.waitlisted_dt);
           FETCH c_admin_pri INTO l_wlst_position;
           CLOSE c_admin_pri;
         END IF;
       END IF;

       IF l_unit_attempt_status = 'UNCONFIRM' then
          l_cart_status := 'J';
      ELSE
          l_cart_status := 'N' ;

       END IF ;

       --
       -- If transfer is not applicable, insert values passed to the API . derived from source Unit Attempt.
       IF  p_sua_dtls_rec.transfer_dt IS NULL THEN

            INSERT INTO IGS_EN_SU_ATTEMPT_ALL (
             person_id,
             course_cd,
             unit_cd,
             version_number,
             cal_type,
             ci_sequence_number,
             location_cd,
             unit_class,
             ci_start_dt,
             ci_end_dt,
             uoo_id,
             enrolled_dt,
             unit_attempt_status,
             administrative_unit_status,
             discontinued_dt,
             rule_waived_dt,
             rule_waived_person_id,
             no_assessment_ind,
             sup_unit_cd,
             sup_version_number,
             exam_location_cd,
             alternative_title,
             override_enrolled_cp,
             override_eftsu,
             override_achievable_cp,
             override_outcome_due_dt,
             override_credit_reason,
             administrative_priority,
             waitlist_dt,
             dcnt_reason_cd,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login,
             request_id,
             program_id,
             program_application_id,
             program_update_date,
             org_id,
             gs_version_number,
             enr_method_type  ,
             failed_unit_rule ,
             cart             ,
             rsv_seat_ext_id   ,
             org_unit_cd      ,
             grading_schema_code ,
             subtitle,
             session_id,
             deg_aud_detail_id,
             student_career_transcript,
             student_career_statistics,
             waitlist_manual_ind ,
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
             wlst_priority_weight_num,
             wlst_preference_weight_num,
             --added by rvangala 01-OCT-2003. Enh Bug# 3052432
             core_indicator_code,
	     upd_audit_flag,
	     ss_source_ind)
             VALUES (
             l_person_id,
             p_sua_dtls_rec.program_cd,
             p_sua_dtls_rec.unit_cd,
             NVL ( p_sua_dtls_rec.version_number , l_version_number),
             l_cal_type,
             l_ci_sequence_number,
             p_sua_dtls_rec.location_cd,
             p_sua_dtls_rec.unit_class,
             l_ci_start_dt,
             l_ci_end_dt,
             l_uoo_id,
             p_sua_dtls_rec.enrolled_dt,
             l_unit_attempt_status,
             NVL ( p_sua_dtls_rec.administrative_unit_status , l_adm_unit_status_ret),
             p_sua_dtls_rec.discontinued_dt,
             NULL ,
             NULL ,
             NVL( p_sua_dtls_rec.no_assessment_ind , l_no_assessment_ind ),
             l_sup_unit_cd ,
             l_sup_unit_version_number ,
             NULL ,
             NULL ,
             l_override_enrollment_cp,
             NULL ,
             l_override_achievable_cp,
             NULL ,
             NULL ,
             l_wlst_position,
             p_sua_dtls_rec.waitlisted_dt,
             p_sua_dtls_rec.dcnt_reason_cd,
             l_last_update_date,
             l_last_updated_by,
             l_last_update_date,
             l_last_updated_by,
             l_last_update_login,
             l_request_id,
             l_program_id,
             l_program_application_id,
             l_program_update_date,
             NULL ,
             p_sua_dtls_rec.gs_version_number ,
             NULL ,
             NULL ,
             l_cart_status ,
             NULL ,
             l_org_unit_cd ,
             p_sua_dtls_rec.grading_schema_code,
             p_sua_dtls_rec.subtitle,
             NULL ,
             NULL ,
             NVL( p_sua_dtls_rec.student_career_transcript , l_student_career_transcript  ),
             NVL( p_sua_dtls_rec.student_career_statistics, l_student_career_statistics  ),
             NULL ,
             p_sua_dtls_rec.attribute_category,
             p_sua_dtls_rec.attribute1,
             p_sua_dtls_rec.attribute2,
             p_sua_dtls_rec.attribute3,
             p_sua_dtls_rec.attribute4,
             p_sua_dtls_rec.attribute5,
             p_sua_dtls_rec.attribute6,
             p_sua_dtls_rec.attribute7,
             p_sua_dtls_rec.attribute8,
             p_sua_dtls_rec.attribute9,
             p_sua_dtls_rec.attribute10,
             p_sua_dtls_rec.attribute11,
             p_sua_dtls_rec.attribute12,
             p_sua_dtls_rec.attribute13,
             p_sua_dtls_rec.attribute14,
             p_sua_dtls_rec.attribute15,
             p_sua_dtls_rec.attribute16,
             p_sua_dtls_rec.attribute17,
             p_sua_dtls_rec.attribute18,
             p_sua_dtls_rec.attribute19,
             p_sua_dtls_rec.attribute20,
             l_pri_weight,
             l_pref_weight,
             --added by rvangala 01-OCT-2003. Enh Bug# 3052432
             p_sua_dtls_rec.core_indicator,
	     'N',
	     'A'
             );
	     l_stat_sua_status := l_unit_attempt_status;
        ELSE
               -- If transfer is applicable, insert values derived from source Unit Attempt.
            INSERT INTO IGS_EN_SU_ATTEMPT_ALL (
             person_id,
             course_cd,
             unit_cd,
             version_number,
             cal_type,
             ci_sequence_number,
             location_cd,
             unit_class,
             ci_start_dt,
             ci_end_dt,
             uoo_id,
             enrolled_dt,
             unit_attempt_status,
             administrative_unit_status,
             discontinued_dt,
             rule_waived_dt,
             rule_waived_person_id,
             no_assessment_ind,
             sup_unit_cd,
             sup_version_number,
             exam_location_cd,
             alternative_title,
             override_enrolled_cp,
             override_eftsu,
             override_achievable_cp,
             override_outcome_due_dt,
             override_credit_reason,
             administrative_priority,
             waitlist_dt,
             dcnt_reason_cd,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login,
             request_id,
             program_id,
             program_application_id,
             program_update_date,
             org_id,
             gs_version_number,
             enr_method_type  ,
             failed_unit_rule ,
             cart             ,
             rsv_seat_ext_id   ,
             org_unit_cd      ,
             grading_schema_code ,
             subtitle,
             session_id,
             deg_aud_detail_id,
             student_career_transcript,
             student_career_statistics,
             waitlist_manual_ind ,
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
             wlst_priority_weight_num,
             wlst_preference_weight_num,
             --added by rvangala 01-OCT-2003. Enh Bug# 3052432
             core_indicator_code,
	     upd_audit_flag,
	     ss_source_ind)
             VALUES (
             l_person_id,
             p_sua_dtls_rec.program_cd,
             p_sua_dtls_rec.unit_cd,
             NVL ( p_sua_dtls_rec.version_number , l_version_number),
             l_cal_type,
             l_ci_sequence_number,
             p_sua_dtls_rec.location_cd,
             p_sua_dtls_rec.unit_class,
             l_ci_start_dt,
             l_ci_end_dt,
             l_uoo_id,
             sua_trnsfr_rec(1).enrolled_dt,
             cst_duplicate ,
             NULL ,
             NULL ,
             NULL ,
             NULL ,
             NVL( p_sua_dtls_rec.no_assessment_ind , l_no_assessment_ind ),
             l_sup_unit_cd ,
             l_sup_unit_version_number ,
             NULL ,
             NULL ,
              NVL(IGS_EN_GEN_015.enrp_get_appr_cr_pt(l_person_id,l_uoo_id),sua_trnsfr_rec(1).override_enrolled_cp),
             NULL ,
              NVL(IGS_EN_GEN_015.enrp_get_appr_cr_pt(l_person_id,l_uoo_id),sua_trnsfr_rec(1).override_achievable_cp),
             NULL ,
             NULL ,
             l_wlst_position,
             p_sua_dtls_rec.waitlisted_dt,
             NULL ,
             l_last_update_date,
             l_last_updated_by,
             l_last_update_date,
             l_last_updated_by,
             l_last_update_login,
             l_request_id,
             l_program_id,
             l_program_application_id,
             l_program_update_date,
             NULL ,
             sua_trnsfr_rec(1).gs_version_number ,
             NULL ,
             NULL ,
             l_cart_status ,
             NULL ,
             l_org_unit_cd ,
             sua_trnsfr_rec(1).grading_schema_code,
             sua_trnsfr_rec(1).subtitle,
             NULL ,
             NULL ,
             NVL( p_sua_dtls_rec.student_career_transcript , l_student_career_transcript  ),
             NVL( p_sua_dtls_rec.student_career_statistics, l_student_career_statistics  ),
             NULL ,
             sua_trnsfr_rec(1).attribute_category,
             sua_trnsfr_rec(1).attribute1,
             sua_trnsfr_rec(1).attribute2,
             sua_trnsfr_rec(1).attribute3,
             sua_trnsfr_rec(1).attribute4,
             sua_trnsfr_rec(1).attribute5,
             sua_trnsfr_rec(1).attribute6,
             sua_trnsfr_rec(1).attribute7,
             sua_trnsfr_rec(1).attribute8,
             sua_trnsfr_rec(1).attribute9,
             sua_trnsfr_rec(1).attribute10,
             sua_trnsfr_rec(1).attribute11,
             sua_trnsfr_rec(1).attribute12,
             sua_trnsfr_rec(1).attribute13,
             sua_trnsfr_rec(1).attribute14,
             sua_trnsfr_rec(1).attribute15,
             sua_trnsfr_rec(1).attribute16,
             sua_trnsfr_rec(1).attribute17,
             sua_trnsfr_rec(1).attribute18,
             sua_trnsfr_rec(1).attribute19,
             sua_trnsfr_rec(1).attribute20,
             l_pri_weight,
             l_pref_weight,
             --added by rvangala 01-OCT-2003. Enh Bug# 3052432
             p_sua_dtls_rec.core_indicator,
	     'N',
	     'A');

	     l_stat_sua_status := cst_duplicate;
        END IF ;

        igs_en_gen_003.UPD_MAT_MRADM_CAT_TERMS(
                p_person_id           => l_person_id,
                p_program_cd          => p_sua_dtls_rec.program_cd,
                p_unit_attempt_status => l_stat_sua_status,
                p_teach_cal_type      => l_cal_type,
                p_teach_ci_seq_num    => l_ci_sequence_number);

        validate_post_sua (p_person_id          => l_person_id ,
                       p_version_number         => NVL ( p_sua_dtls_rec.version_number , l_version_number),
                       p_sua_dtls_rec           => p_sua_dtls_rec           ,
                       p_cal_type               => l_cal_type               ,
                       p_ci_sequence_number     => l_ci_sequence_number     ,
                       p_ci_end_dt              => l_ci_end_dt              ,
                       p_ci_start_dt            => l_ci_start_dt            ,
                       p_unit_attempt_status    => l_unit_attempt_status    ,
                       p_uoo_id                 => l_uoo_id                 ,
                       p_administrative_unit_status => l_adm_unit_status_ret ,
                       p_career_centric         => l_career_model_enabled ,
                       p_primary_program_type   => l_primary_program_type ,
                       p_administrative_pri     => l_wlst_position
                      ) ;
  ELSE
          ROLLBACK TO CREATE_SUA_PUB;
  END IF;

    --
    -- If the calling program has passed the parameter for committing the data and there
    -- have been no errors in calling the balances process, then commit the work
    IF ( (FND_API.To_Boolean(p_commit)) AND (g_sua_status = 'VALID') ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.COUNT_AND_GET( p_count   => x_msg_count,
                               p_data    => x_msg_data);

    --
    -- Retutn Status to the calling program
    IF g_sua_status = 'INVALID' THEN
        ROLLBACK TO CREATE_SUA_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
    ELSIF g_sua_status = 'WARNING' THEN
        ROLLBACK TO CREATE_SUA_PUB;
        x_return_status := 'W';
    END IF ;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO CREATE_SUA_PUB;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO CREATE_SUA_PUB;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO CREATE_SUA_PUB;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,
                                    l_api_name);
          END IF;
          FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                     p_data           => x_msg_data);


END create_sua ;

END igs_en_sua_lgcy_pub ;

/
