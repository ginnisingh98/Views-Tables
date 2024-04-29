--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPI_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPI_LGCY_PUB" AS
/* $Header: IGSENA6B.pls 120.1 2006/04/13 01:56:53 smaddali noship $ */

/*------------------------------------------------------------------------------+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA       |
 |                            All rights reserved.                              |
 +==============================================================================+
 |                                                                              |
 | DESCRIPTION                                                                  |
 |      PL/SQL body for package: igs_en_spi_lgcy_pub                            |
 |                                                                              |
 | NOTES : Student Intermission Legacy API. This API imports legacy Students    |
 |         intermission records into OSS tables. Created as part of Enrollment  |
 |         Legacy build. Bug# 2661533                                           |
 |                                                                              |
 | HISTORY                                                                      |
 | Who      When           What                                                 |
 |                                                                              |
 *==============================================================================*/

  g_pkg_name CONSTANT VARCHAR2(30) := 'IGS_EN_SPI_LGCY_PUB';

  FUNCTION validate_parameter (
    p_intermiss_rec    IN     en_spi_rec_type
  ) RETURN BOOLEAN AS

 /**********************************************************************************************
   Created By       : pradhakr
   Date Created By  : 21-Nov-2002
   Purpose          : This function is used to validate the passed parameters.
   Known limitations,enhancements,remarks:
   Change History
   Who     When       What
  ***********************************************************************************************/
    l_valid_params BOOLEAN := TRUE;
    l_msg_count    NUMBER;
    l_msg_data     VARCHAR2(2000);
    l_desc_flex_name   CONSTANT  VARCHAR2(30) := 'IGS_EN_STDNT_INTM_FLEX';

  BEGIN

    -- Check whether the person number is null or not.
    IF p_intermiss_rec.person_number IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_EN_PER_NUM_NULL');
       FND_MSG_PUB.ADD;
       l_valid_params := FALSE;
    END IF;

    -- Check whether the program code is null or not.
    IF p_intermiss_rec.program_cd IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_CD_NULL');
       FND_MSG_PUB.ADD;
       l_valid_params := FALSE;
    ELSE
      BEGIN
        igs_en_stdnt_ps_intm_pkg.check_constraints ('COURSE_CD', p_intermiss_rec.program_cd);
      EXCEPTION
        WHEN OTHERS THEN
           FND_MSG_PUB.COUNT_AND_GET( p_count          => l_msg_count,
                                      p_data           => l_msg_data);

           -- Delete the message 'IGS_GE_INVALID_VALUE'
           FND_MSG_PUB.DELETE_MSG (l_msg_count);

           -- set the customized message
           FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_CD_UCASE');
           FND_MSG_PUB.ADD;
           l_valid_params := FALSE;
       END;
    END IF;

    -- Check whether start date is null or not
    IF p_intermiss_rec.start_dt IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_PS_STARDT_NOT_NULL');
       FND_MSG_PUB.ADD;
       l_valid_params := FALSE;
    END IF;

    -- Check whether end date is null or not
    IF p_intermiss_rec.end_dt IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_EN_END_DT_CANT_NULL');
       FND_MSG_PUB.ADD;
       l_valid_params := FALSE;
    END IF;

    -- Check whether voluntary_ind is having any other value other than 'Y'/'N'
    IF p_intermiss_rec.voluntary_ind IS NOT NULL THEN
       BEGIN
         igs_en_stdnt_ps_intm_pkg.check_constraints ('VOLUNTARY_IND', p_intermiss_rec.voluntary_ind);
       EXCEPTION
         WHEN OTHERS THEN
           FND_MSG_PUB.COUNT_AND_GET( p_count          => l_msg_count,
                                      p_data           => l_msg_data);

           FND_MSG_PUB.DELETE_MSG (l_msg_count);
           FND_MESSAGE.SET_NAME('IGS','IGS_EN_VOL_IND_INVALID');
           FND_MSG_PUB.ADD;
           l_valid_params := FALSE;
       END;
    END IF;

    -- Check whether Intermission type is upper case or not.
    IF p_intermiss_rec.intermission_type IS NOT NULL THEN
       IF p_intermiss_rec.intermission_type <> UPPER(p_intermiss_rec.intermission_type) then
          FND_MESSAGE.SET_NAME('IGS','IGS_EN_INTM_TYPE_UCASE');
          FND_MSG_PUB.ADD;
          l_valid_params := FALSE;
       END IF;
    END IF;

      -- Check whether approved field is having any other value other than 'Y'/'N'
    IF p_intermiss_rec.approved IS NOT NULL THEN
       BEGIN
         igs_en_stdnt_ps_intm_pkg.check_constraints ('APPROVED', p_intermiss_rec.approved);
       EXCEPTION
         WHEN OTHERS THEN
           FND_MSG_PUB.COUNT_AND_GET( p_count          => l_msg_count,
                                      p_data           => l_msg_data);

           FND_MSG_PUB.DELETE_MSG (l_msg_count);
           FND_MESSAGE.SET_NAME('IGS','IGS_EN_APPROVED_INVALID');
           FND_MSG_PUB.ADD;
           l_valid_params := FALSE;
       END;
    END IF;


    -- Check whether institution name is upper case or not.
    IF p_intermiss_rec.institution_name IS NOT NULL THEN
       IF p_intermiss_rec.institution_name <> UPPER(p_intermiss_rec.institution_name) then
          FND_MESSAGE.SET_NAME('IGS','IGS_EN_INSTIT_NAME_UCASE');
          FND_MSG_PUB.ADD;
          l_valid_params := FALSE;
       END IF;
    END IF;

    IF p_intermiss_rec.COND_RETURN_FLAG IS NOT NULL THEN
	IF p_intermiss_rec.COND_RETURN_FLAG NOT IN ('Y','N') THEN
	  FND_MESSAGE.SET_NAME('IGS','IGS_EN_RCOND_INV');
          FND_MSG_PUB.ADD;
          l_valid_params := FALSE;
	END IF;
    END IF;


    --
    -- If any of the Descriptive Flex field columns have value, then validate them .
    IF (p_intermiss_rec.attribute_category IS NOT NULL OR p_intermiss_rec.attribute1  IS NOT NULL OR p_intermiss_rec.attribute2  IS NOT NULL OR
        p_intermiss_rec.attribute3  IS NOT NULL OR p_intermiss_rec.attribute4  IS NOT NULL OR p_intermiss_rec.attribute5  IS NOT NULL OR
        p_intermiss_rec.attribute6  IS NOT NULL OR p_intermiss_rec.attribute7  IS NOT NULL OR p_intermiss_rec.attribute8  IS NOT NULL OR
        p_intermiss_rec.attribute9  IS NOT NULL OR p_intermiss_rec.attribute10 IS NOT NULL OR p_intermiss_rec.attribute11 IS NOT NULL OR
        p_intermiss_rec.attribute12 IS NOT NULL OR p_intermiss_rec.attribute13 IS NOT NULL OR p_intermiss_rec.attribute14 IS NOT NULL OR
        p_intermiss_rec.attribute15 IS NOT NULL OR p_intermiss_rec.attribute16 IS NOT NULL OR p_intermiss_rec.attribute17 IS NOT NULL OR
        p_intermiss_rec.attribute18 IS NOT NULL OR p_intermiss_rec.attribute19 IS NOT NULL OR p_intermiss_rec.attribute20 IS NOT NULL )
    THEN

       -- call to validate descriptive flexfield values
       IF  NOT  igs_ad_imp_018.validate_desc_flex ( p_attribute_category     =>      p_intermiss_rec.attribute_category,
                                                    p_attribute1             =>      p_intermiss_rec.attribute1,
                                                    p_attribute2             =>      p_intermiss_rec.attribute2,
                                                    p_attribute3             =>      p_intermiss_rec.attribute3,
                                                    p_attribute4             =>      p_intermiss_rec.attribute4,
                                                    p_attribute5             =>      p_intermiss_rec.attribute5,
                                                    p_attribute6             =>      p_intermiss_rec.attribute6,
                                                    p_attribute7             =>      p_intermiss_rec.attribute7,
                                                    p_attribute8             =>      p_intermiss_rec.attribute8,
                                                    p_attribute9             =>      p_intermiss_rec.attribute9,
                                                    p_attribute10            =>      p_intermiss_rec.attribute10,
                                                    p_attribute11            =>      p_intermiss_rec.attribute11,
                                                    p_attribute12            =>      p_intermiss_rec.attribute12,
                                                    p_attribute13            =>      p_intermiss_rec.attribute13,
                                                    p_attribute14            =>      p_intermiss_rec.attribute14,
                                                    p_attribute15            =>      p_intermiss_rec.attribute15,
                                                    p_attribute16            =>      p_intermiss_rec.attribute16,
                                                    p_attribute17            =>      p_intermiss_rec.attribute17,
                                                    p_attribute18            =>      p_intermiss_rec.attribute18,
                                                    p_attribute19            =>      p_intermiss_rec.attribute19,
                                                    p_attribute20            =>      p_intermiss_rec.attribute20,
                                                    p_desc_flex_name         =>      l_desc_flex_name ) THEN

         FND_MESSAGE.SET_NAME('IGS','IGS_AD_INVALID_DESC_FLEX');
         FND_MSG_PUB.ADD;
         l_valid_params := FALSE;
      END IF;
    END IF;

    RETURN l_valid_params;

  END validate_parameter;

  FUNCTION validate_db_cons (
    p_person_id        IN    igs_en_stdnt_ps_intm.person_id%TYPE,
    p_intermiss_rec    IN    en_spi_rec_type
  ) RETURN VARCHAR2 AS

  /**********************************************************************************************
   Created By       : pradhakr
   Date Created By  : 21-Nov-2002
   Purpose          : Function to check the database constraints
   Known limitations,enhancements,remarks:
   Change History
   Who     When       What
   bdeviset 13-SEP-2004   Bug no 3885804.Added parameter logical_delete_date in the call
                          igs_en_stdnt_ps_intm_pkg.get_pk_for_validation.
  ***********************************************************************************************/

    l_valid_db_constr   BOOLEAN := TRUE;
    l_logical_delete_date igs_en_stdnt_ps_intm.logical_delete_date%TYPE;

  BEGIN

     -- Check for primary Key validation. If validation fails, stop the processing and return back
     -- to the calling procedure.
     l_logical_delete_date := to_date('31-12-4712','DD-MM-YYYY');
     IF igs_en_stdnt_ps_intm_pkg.get_pk_for_validation ( p_person_id, p_intermiss_rec.program_cd, p_intermiss_rec.start_dt,l_logical_delete_date) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_STU_INTM_EXISTS');
        FND_MSG_PUB.ADD;
	RETURN 'W';
     END IF;


     -- Check for Student Program Attempt existance
     IF NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation ( p_person_id, p_intermiss_rec.program_cd ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_ATT_NOT_EXIST');
        FND_MSG_PUB.ADD;
        l_valid_db_constr := FALSE;
     END IF;

     -- Check for intermission type existance
     IF p_intermiss_rec.intermission_type IS NOT NULL THEN
        IF NOT igs_en_intm_types_pkg.get_uk_for_validation ( p_intermiss_rec.intermission_type ) THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_EN_INTM_TYP_NOT_EXIST');
           FND_MSG_PUB.ADD;
           l_valid_db_constr := FALSE;
        END IF;
     END IF;

     -- Check for institution existance
     IF p_intermiss_rec.institution_name  IS NOT NULL THEN
       IF NOT igs_en_gen_legacy.check_institution ( p_intermiss_rec.institution_name ) THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_EN_INST_NOT_EXIST');
          FND_MSG_PUB.ADD;
          l_valid_db_constr := FALSE;
       END IF;
     END IF;

     -- If any of the validation fails, return Error status else return Success.
     IF l_valid_db_constr = FALSE THEN
       RETURN 'E';
     ELSE
       RETURN 'S';
     END IF;

  END validate_db_cons;


 FUNCTION validate_stu_intm (
   p_person_id       IN    igs_en_stdnt_ps_intm.person_id%TYPE,
   p_intermiss_rec   IN    en_spi_rec_type,
   p_approver_id     IN    igs_en_stdnt_ps_intm.approver_id%TYPE
  ) RETURN BOOLEAN AS

  /**********************************************************************************************
   Created By       : pradhakr
   Date Created By  : 21-Nov-2002
   Purpose          : Function to validate the business rules
   Known limitations,enhancements,remarks:
   Change History
   Who     When       What
  ***********************************************************************************************/

    l_validation_success BOOLEAN := TRUE;
    p_message_name       fnd_new_messages.message_name%TYPE;
    l_result BOOLEAN;

  BEGIN

    -- Check whether the Start Date is less than or equal to End Date.
    IF (p_intermiss_rec.start_dt IS NOT NULL) AND (p_intermiss_rec.end_dt IS NOT NULL) THEN
       IF NOT igs_ad_val_edtl.genp_val_strt_end_dt ( p_intermiss_rec.start_dt, p_intermiss_rec.end_dt, p_message_name ) THEN
          FND_MESSAGE.SET_NAME('IGS',p_message_name);
          FND_MSG_PUB.ADD;
          l_validation_success := FALSE;
       END IF;
    END IF;

    -- Validate the overlap of student course intermission records
    IF NOT igs_en_val_sci.enrp_val_sci_ovrlp ( p_person_id, p_intermiss_rec.program_cd, p_intermiss_rec.start_dt,
			                       p_intermiss_rec.end_dt, p_message_name ) THEN
       FND_MESSAGE.SET_NAME('IGS',p_message_name);
       FND_MSG_PUB.ADD;
       l_validation_success := FALSE;
    END IF;

    -- Validate whether Period of intermission overlaps enrolled/completed
    -- unit attempt teaching period census dates.
    IF NOT igs_en_gen_legacy.validate_intm_ua_ovrlp ( p_person_id, p_intermiss_rec.program_cd, p_intermiss_rec.start_dt,
				                    p_intermiss_rec.end_dt ) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_EN_INTM_CANT_OVRLP_UA');
       FND_MSG_PUB.ADD;
       l_validation_success := FALSE;
    END IF;

    -- Validate whether approval is required for the intermission type.
    IF p_intermiss_rec.intermission_type IS NOT NULL THEN

       l_result := igs_en_gen_legacy.check_approv_reqd (p_intermiss_rec.intermission_type);

       IF (l_result = FALSE) AND (p_intermiss_rec.approver_person_number IS NOT NULL) THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_EN_NOT_SET_APPROV_DET');
          FND_MSG_PUB.ADD;
          l_validation_success := FALSE;
       END IF;

    END IF;

    -- Check whether Approving person is a staff member or not.
    IF p_intermiss_rec.approver_person_number IS NOT NULL THEN

       IF NOT igs_ad_val_acai.genp_val_staff_prsn (p_approver_id, p_message_name) THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_EN_APPROV_PERS_STAFF');
          FND_MSG_PUB.ADD;
          l_validation_success := FALSE;
       END IF;

       -- Check whether Approving person is same as the student being approved.
       IF p_intermiss_rec.approver_person_number = p_intermiss_rec.person_number THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_EN_APPROV_CANT_STU');
          FND_MSG_PUB.ADD;
          l_validation_success := FALSE;
       END IF;

    END IF;

    -- Check whether student is studying in another institution or not.
    IF (p_intermiss_rec.institution_name IS NOT NULL) OR (p_intermiss_rec.max_terms IS NOT NULL) OR
       (p_intermiss_rec.max_credit_pts  IS NOT NULL) THEN

       IF p_intermiss_rec.intermission_type IS NOT NULL THEN

          IF NOT igs_en_gen_legacy.check_study_antr_instu ( p_intermiss_rec.intermission_type ) THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_EN_CANT_SET_INSTI_DET');
             FND_MSG_PUB.ADD;
             l_validation_success := FALSE;
           END IF;

       END IF;

    END IF;

    RETURN l_validation_success;

  END validate_stu_intm;


  PROCEDURE create_student_intm
  (
    p_api_version             IN           NUMBER,
    p_init_msg_list           IN           VARCHAR2 ,
    p_commit                  IN           VARCHAR2 ,
    p_validation_level        IN           NUMBER   ,
    p_intermiss_rec           IN           en_spi_rec_type,
    x_return_status           OUT  NOCOPY  VARCHAR2,
    x_msg_count               OUT  NOCOPY  NUMBER,
    x_msg_data                OUT  NOCOPY  VARCHAR2
  ) AS
   /**********************************************************************************************
    Created By       : pradhakr
    Date Created By  : 21-Nov-2002
    Purpose          : Main API for student intermission.
    Known limitations,enhancements,remarks:
    Change History
    Who     When       What
   ***********************************************************************************************/

   l_person_id                  igs_en_stdnt_ps_intm.person_id%TYPE;
   l_approver_person_id         igs_en_stdnt_ps_intm.approver_id%TYPE;
   p_course_attempt_status      igs_en_stdnt_ps_att_all.course_attempt_status%TYPE;
   l_insert_flag                BOOLEAN := TRUE;
   l_ret_val                    VARCHAR2(1);
   l_api_name                   CONSTANT    VARCHAR2(30) := 'create_student_intm';
   l_api_version                CONSTANT    NUMBER       := 1.0;
   l_creation_date              igs_en_stdnt_ps_intm.creation_date%TYPE;
   l_last_update_date           igs_en_stdnt_ps_intm.last_update_date%TYPE;
   l_created_by                 igs_en_stdnt_ps_intm.created_by%TYPE;
   l_last_updated_by            igs_en_stdnt_ps_intm.last_updated_by%TYPE;
   l_last_update_login          igs_en_stdnt_ps_intm.last_update_login%TYPE;
   l_institution_name           igs_en_stdnt_ps_intm.institution_name%TYPE;
   l_max_credit_pts             igs_en_stdnt_ps_intm.max_credit_pts%TYPE;
   l_max_terms                  igs_en_stdnt_ps_intm.max_terms%TYPE;
   l_anticipated_credit_points  igs_en_stdnt_ps_intm.anticipated_credit_points%TYPE;
   l_logical_delete_date        igs_en_stdnt_ps_intm.logical_delete_date%TYPE;
   l_cond_return_flag           igs_en_stdnt_ps_intm.cond_return_flag%TYPE;
   BEGIN

     SAVEPOINT create_en_spi_pub;

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

    -- Validate the parameters
    IF NOT validate_parameter(p_intermiss_rec) THEN
       l_insert_flag := FALSE;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

   IF p_intermiss_rec.COND_RETURN_FLAG IS NULL THEN
            l_cond_return_flag:= 'N';
   ELSE
         l_cond_return_flag:= p_intermiss_rec.cond_return_flag;
   END IF;


    IF l_insert_flag = TRUE THEN
       -- Derive the values for further processing.
       -- Get the person id for the passed person number.
       l_person_id := Igs_Ge_Gen_003.get_person_id (p_intermiss_rec.person_number);
       IF l_person_id IS NULL THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_PERSON_NUMBER');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_insert_flag := FALSE;
       END IF;
    END IF;


    IF l_insert_flag = TRUE THEN
       -- Get the approver person id for the approver.
       IF p_intermiss_rec.approver_person_number IS NOT NULL THEN
          l_approver_person_id := Igs_Ge_Gen_003.get_person_id (p_intermiss_rec.approver_person_number);
          IF l_approver_person_id IS NULL THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_EN_NO_APPROV_PERSON');
             FND_MSG_PUB.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
             l_insert_flag := FALSE;
          END IF;
       END IF;
    END IF;

    -- If all the validations are passed then check for DB constraints. It either returns Warning or Error.
    IF l_insert_flag = TRUE THEN
       l_ret_val := validate_db_cons ( l_person_id, p_intermiss_rec);
       IF l_ret_val = 'E' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_insert_flag := FALSE;
       ELSIF l_ret_val = 'W' THEN
          x_return_status := 'W';
          l_insert_flag := FALSE;
       END IF;
    END IF;

    -- Check for the business rules.
    IF l_insert_flag = TRUE THEN
       IF NOT validate_stu_intm (l_person_id, p_intermiss_rec, l_approver_person_id) THEN
          l_insert_flag := FALSE;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;


    -- Check whether approval is required for the intermission type
    IF l_insert_flag = TRUE THEN
       IF NOT igs_en_gen_legacy.check_approv_reqd (p_intermiss_rec.intermission_type) THEN
          l_approver_person_id := NULL;
       END IF;
    END IF;

    -- Check whether student is studying in another instiution or not. If yes, use the
    -- institution related details else pass null to all institution details
    IF l_insert_flag = TRUE THEN
       IF igs_en_gen_legacy.check_study_antr_instu (p_intermiss_rec.intermission_type) THEN
          l_institution_name	:= p_intermiss_rec.institution_name;
          l_max_credit_pts	:= p_intermiss_rec.max_credit_pts;
          l_max_terms		:= p_intermiss_rec.max_terms;
          l_anticipated_credit_points := p_intermiss_rec.anticipated_credit_points;
       ELSE
	  l_institution_name	:= NULL;
	  l_max_credit_pts	:= NULL;
	  l_max_terms		:= NULL;
	  l_anticipated_credit_points := NULL;
       END IF;
    END IF;


    -- If all the above validations are passed then insert the record into OSS intermission table.
    IF l_insert_flag = TRUE THEN

         -- Populating who columns
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

         l_logical_delete_date := to_date('31-12-4712','DD-MM-YYYY');

	 INSERT INTO igs_en_stdnt_ps_intm (
              person_id,
              course_cd,
              start_dt,
      	      logical_delete_date,
              end_dt,
              voluntary_ind,
              comments,
              intermission_type,
              approved,
              institution_name,
              max_credit_pts,
              max_terms,
              anticipated_credit_points,
              approver_id,
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
	      cond_return_flag
          )VALUES(
              l_person_id,
              p_intermiss_rec.program_cd,
              p_intermiss_rec.start_dt,
	      l_logical_delete_date,
              p_intermiss_rec.end_dt,
              NVL(p_intermiss_rec.voluntary_ind,'N'),
              p_intermiss_rec.comments,
              p_intermiss_rec.intermission_type,
              NVL(p_intermiss_rec.approved,'N'),
	      l_institution_name,
              l_max_credit_pts,
              l_max_terms,
              l_anticipated_credit_points,
              l_approver_person_id,
              p_intermiss_rec.attribute_category,
              p_intermiss_rec.attribute1,
              p_intermiss_rec.attribute2,
              p_intermiss_rec.attribute3,
              p_intermiss_rec.attribute4,
              p_intermiss_rec.attribute5,
              p_intermiss_rec.attribute6,
              p_intermiss_rec.attribute7,
              p_intermiss_rec.attribute8,
              p_intermiss_rec.attribute9,
              p_intermiss_rec.attribute10,
              p_intermiss_rec.attribute11,
              p_intermiss_rec.attribute12,
              p_intermiss_rec.attribute13,
              p_intermiss_rec.attribute14,
              p_intermiss_rec.attribute15,
              p_intermiss_rec.attribute16,
              p_intermiss_rec.attribute17,
              p_intermiss_rec.attribute18,
              p_intermiss_rec.attribute19,
              p_intermiss_rec.attribute20,
              l_created_by,
              l_creation_date,
              l_last_updated_by,
              l_last_update_date,
              l_last_update_login,
              l_cond_return_flag
            );

         -- Check whether program attempt status need to be updated or not.
	 -- If needed update it with INTERMIT status.
         IF igs_en_gen_legacy.check_sca_status_upd ( l_person_id, p_intermiss_rec.program_cd, 'SPI', p_course_attempt_status ) THEN
            UPDATE igs_en_stdnt_ps_att_all SET course_attempt_status = 'INTERMIT'
            WHERE person_id = l_person_id
            AND course_cd = p_intermiss_rec.program_cd;
         END IF;
     ELSE
       ROLLBACK TO create_en_spi_pub;
     END IF;

     -- Commit the record which is inserted in the table.
     IF (FND_API.TO_BOOLEAN(p_commit) AND l_insert_flag ) THEN
        COMMIT WORK;
     END IF;

     FND_MSG_PUB.COUNT_AND_GET( p_count   => x_msg_count,
                                p_data    => x_msg_data);


   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO create_en_spi_pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                  p_data           => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO create_en_spi_pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                  p_data           => x_msg_data);

    WHEN OTHERS THEN
       ROLLBACK TO create_en_spi_pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,
                                  l_api_name);
       END IF;
       FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                  p_data           => x_msg_data);

  END create_student_intm;

END igs_en_spi_lgcy_pub;

/
