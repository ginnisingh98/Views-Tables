--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPAA_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPAA_LGCY_PUB" AS
/* $Header: IGSENA5B.pls 115.5 2003/10/10 09:17:35 nalkumar noship $ */

g_pkg_name CONSTANT VARCHAR2(30):='IGS_EN_SPAA_LGCY_PUB';

FUNCTION validate_parameters ( p_awd_aim_rec IN  awd_aim_rec_type )
RETURN VARCHAR2 AS
  /*
  ||  Created By : nbehera
  ||  Created On : 20NOV2002
  ||  Purpose    : This procedure validates all the fields in the parameter p_the_dtls_rec
  ||               which require one or more validation
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who        When        What
  ||  anilk      07-Oct-2003 changes in awd_aim_rec_type for Program Completion Validation, Bug# 3129913
  ||  (reverse chronological order - newest change first)
  */
l_val_param VARCHAR2(10) := 'VALID';

BEGIN
    -- Check if person_number value is null then log error message
    IF p_awd_aim_rec.person_number IS NULL THEN
         FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_PER_NUM_NULL');
         FND_MSG_PUB.ADD;
         l_val_param := 'INVALID';
    END IF;

    -- Check if program_cd value is null then log error message
    IF p_awd_aim_rec.program_cd IS NULL THEN
         FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_PRGM_CD_NULL');
         FND_MSG_PUB.ADD;
         l_val_param := 'INVALID';
    -- Check if program_cd is not an upper case value then log error message
    ELSIF p_awd_aim_rec.program_cd <> UPPER(p_awd_aim_rec.program_cd) THEN
         FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_PRGM_CD_UCASE');
         FND_MSG_PUB.ADD;
         l_val_param := 'INVALID';
    END IF;

    -- Check if award_cd value is null then log error message
    IF p_awd_aim_rec.award_cd IS NULL THEN
         FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_AWD_CD_NULL');
         FND_MSG_PUB.ADD;
         l_val_param := 'INVALID';
    -- Check if award_cd is not an upper case value then log error message
    ELSIF p_awd_aim_rec.award_cd <> UPPER(p_awd_aim_rec.award_cd) THEN
         FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_AWD_CD_UCASE');
         FND_MSG_PUB.ADD;
         l_val_param := 'INVALID';
    END IF;

    -- Check if start_dt value is null then log error message
    IF p_awd_aim_rec.start_dt IS NULL THEN
         FND_MESSAGE.SET_NAME ('IGS', 'IGS_PS_STARDT_NOT_NULL');
         FND_MSG_PUB.ADD;
         l_val_param := 'INVALID';
    END IF;

    -- Check if complete_ind is available and is not 'Y' or 'N' then log error message
    IF p_awd_aim_rec.complete_ind IS NOT NULL THEN
         IF p_awd_aim_rec.complete_ind NOT IN('Y','N') THEN
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_COMPLT_IND_INVALID');
              FND_MSG_PUB.ADD;
              l_val_param := 'INVALID';
         END IF;
    END IF;

    -- Check if award_mark is available and is in 0-100 range
    IF p_awd_aim_rec.award_mark IS NOT NULL THEN
         IF NOT (p_awd_aim_rec.award_mark >= 0 AND p_awd_aim_rec.award_mark <= 100 ) THEN
              FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_MARK_INV_0_100');
              FND_MSG_PUB.ADD;
              l_val_param := 'INVALID';
         END IF;
    END IF;

    RETURN l_val_param;

END validate_parameters;

FUNCTION validate_db_cons ( p_person_id   IN  NUMBER,
                            p_awd_aim_rec IN  awd_aim_rec_type )
RETURN VARCHAR2 AS
  /*
  ||  Created By : nbehera
  ||  Created On : 20NOV2002
  ||  Purpose    : This Procedure Checks for all the database constraints required to
  ||               check before insertion of a Award Aims record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  CURSOR cur_awd_grd_sch(
               cp_award_cd igs_ps_awd.award_cd%TYPE,
               cp_grading_schema_cd igs_ps_awd.grading_schema_cd%TYPE,
               cp_gs_version_number igs_ps_awd.gs_version_number%TYPE ) IS
        SELECT 'X'
          FROM igs_ps_awd
         WHERE award_cd = cp_award_cd
	   AND grading_schema_cd = cp_grading_schema_cd
	   AND gs_version_number = cp_gs_version_number;

  l_ret_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_dummy      VARCHAR2(1);

BEGIN

    --Check for duplicate record in the Award Aims Table
    --If record exists then return the return status as 'W' without checking
    --for further FK checks
    IF igs_en_spa_awd_aim_pkg.get_pk_for_validation (
                  x_award_cd     => p_awd_aim_rec.award_cd,
                  x_course_cd    => p_awd_aim_rec.program_cd,
                  x_person_id    => p_person_id ) THEN
         FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_AWD_AIM_EXISTS');
         FND_MSG_PUB.ADD;
         l_ret_status := 'W';
         RETURN l_ret_status;
    END IF;

    -- FK check in the Student Program Attempt table
    IF NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation (
                  x_person_id => p_person_id,
                  x_course_cd => p_awd_aim_rec.program_cd ) THEN
         FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_PRGM_ATT_NOT_EXIST');
         FND_MSG_PUB.ADD;
         l_ret_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- FK check in the Award Code table
    IF NOT igs_ps_awd_pkg.get_pk_for_validation (
                  x_award_cd => p_awd_aim_rec.award_cd ) THEN
         FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_AWD_NOT_EXIST');
         FND_MSG_PUB.ADD;
         l_ret_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- Check if grading schema matches one stored at the award
    IF p_awd_aim_rec.grading_schema_cd  IS NOT NULL AND
       p_awd_aim_rec.gs_version_number  IS NOT NULL THEN
           OPEN cur_awd_grd_sch(
                   p_awd_aim_rec.award_cd,
                   p_awd_aim_rec.grading_schema_cd,
                   p_awd_aim_rec.gs_version_number);
           FETCH cur_awd_grd_sch INTO l_dummy;
           IF (cur_awd_grd_sch%NOTFOUND) THEN
               FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_AWD_GRD_SCH_NO_MTCH');
               FND_MSG_PUB.ADD;
               l_ret_status := FND_API.G_RET_STS_ERROR;
           END IF;
    END IF;

    -- Check if award_grade belongs to grading schema
    IF p_awd_aim_rec.award_grade IS NOT NULL THEN
       IF p_awd_aim_rec.grading_schema_cd  IS NOT NULL AND
          p_awd_aim_rec.gs_version_number  IS NOT NULL THEN
              IF NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (
                   x_grading_schema_cd => p_awd_aim_rec.grading_schema_cd,
                   x_version_number    => p_awd_aim_rec.gs_version_number,
                   x_grade             => p_awd_aim_rec.award_grade  )
              THEN
                  FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_GRD_NOT_IN_SCHEMA');
                  FND_MSG_PUB.ADD;
                  l_ret_status := FND_API.G_RET_STS_ERROR;
              END IF;
       ELSE
           FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_GRD_NOT_IN_SCHEMA');
           FND_MSG_PUB.ADD;
           l_ret_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;

    RETURN l_ret_status;

END validate_db_cons;

FUNCTION validate_stu_awd_aim ( p_person_id   IN  NUMBER,
                                p_awd_aim_rec IN  awd_aim_rec_type )
RETURN VARCHAR2 AS
  /*
  ||  Created By : nbehera
  ||  Created On : 20NOV2002
  ||  Purpose    : This procedure checks all the business validations before
  ||               inserting a Award Aims record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
l_val_awd_aim  VARCHAR2(10) := 'VALID';
l_message      fnd_new_messages.message_name%TYPE;

BEGIN
    --If Start Date and End Date is having value then call the below function to
    --Check if Start Date is less than or equal to End Date. If not then log error message.
    IF p_awd_aim_rec.start_dt IS NOT NULL AND p_awd_aim_rec.end_dt IS NOT NULL THEN
         IF NOT igs_ad_val_edtl.genp_val_strt_end_dt (
                         p_start_dt      => p_awd_aim_rec.start_dt,
                         p_end_dt        => p_awd_aim_rec.end_dt,
                         p_message_name  => l_message) THEN
              FND_MESSAGE.SET_NAME ('IGS', l_message);
              FND_MSG_PUB.ADD;
              l_val_awd_aim := 'INVALID';
         END IF;
    END IF;

    --Call the below function to check whether the Award code is offered within the enrolled
    --program version. If not then log error message.
    IF NOT igs_en_gen_legacy.validate_awd_offer_pgm (
                        p_person_id    => p_person_id,
                        p_program_cd   => p_awd_aim_rec.program_cd,
                        p_award_cd     => p_awd_aim_rec.award_cd) THEN
         FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_AWD_AVAIL_STU_PGM');
         FND_MSG_PUB.ADD;
         l_val_awd_aim := 'INVALID';
    END IF;

    RETURN l_val_awd_aim;

END validate_stu_awd_aim;

PROCEDURE create_student_awd_aim
(       p_api_version       IN   NUMBER,
        p_init_msg_list     IN   VARCHAR2,
        p_commit            IN   VARCHAR2,
        p_validation_level  IN   NUMBER ,
        p_awd_aim_rec       IN   awd_aim_rec_type,
        x_return_status     OUT  NOCOPY VARCHAR2,
        x_msg_count         OUT  NOCOPY NUMBER,
        x_msg_data          OUT  NOCOPY VARCHAR2 ) IS
  /*
  ||  Created By : nbehera
  ||  Created On : 20NOV2002
  ||  Purpose    : This procedure inserts records into the Award Aims table after
  ||               checking all the validations sequencially as below:
  ||               1. Validation of the parameters.
  ||               2. Deriving values for other parameters
  ||               3. Checking DB Constraints
  ||               4. Checking for other validations
  ||               5. Inserting the record into the table
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

l_api_name      CONSTANT VARCHAR2(30) := 'create_student_awd_aim';
l_api_version   CONSTANT NUMBER := 1.0;
l_stdnt_awd_aim_status   VARCHAR2(10) := 'VALID';
l_person_id              igs_re_thesis.person_id%TYPE := NULL;
l_last_update_date       igs_en_spa_awd_aim.creation_date%TYPE;
l_last_updated_by        igs_en_spa_awd_aim.last_updated_by%TYPE;
l_last_update_login      igs_en_spa_awd_aim.last_update_login%TYPE;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   awd_aim_pub;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.COMPATIBLE_API_CALL (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
         FND_MSG_PUB.INITIALIZE;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /****** Validating all the parameters available ******/
    l_stdnt_awd_aim_status := validate_parameters ( p_awd_aim_rec => p_awd_aim_rec );

    /****** Deriving values for the parameters ******/
    IF l_stdnt_awd_aim_status <> 'INVALID' THEN
        -- Calling the function to get the person_id
        l_person_id := igs_ge_gen_003.get_person_id( p_person_number => p_awd_aim_rec.person_number);
        -- If person id value returned is NULL then log error message.
        IF l_person_id IS NULL THEN
             FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
             FND_MSG_PUB.ADD;
             l_stdnt_awd_aim_status := 'INVALID';
        END IF;
    END IF;

    /****** Check for the Database Constraints for the Award Aims record ******/
    IF l_stdnt_awd_aim_status <> 'INVALID' THEN
         x_return_status := validate_db_cons (
                                p_person_id   => l_person_id ,
                                p_awd_aim_rec => p_awd_aim_rec );
         IF x_return_status <> 'S' THEN
	      l_stdnt_awd_aim_status := 'INVALID';
	 END IF;
    END IF;

    /****** Check the Validation for the Award Aims record ******/
    IF l_stdnt_awd_aim_status <> 'INVALID' THEN
         l_stdnt_awd_aim_status := validate_stu_awd_aim (
                                       p_person_id   => l_person_id,
                                       p_awd_aim_rec => p_awd_aim_rec);
    END IF;

    /****** Insert data into Award Aims table ******/
    IF l_stdnt_awd_aim_status <> 'INVALID' THEN
         --Deriving values for the WHO Columns
         l_last_update_date := SYSDATE;

         l_last_updated_by := FND_GLOBAL.USER_ID;
         IF l_last_updated_by IS NULL THEN
              l_last_updated_by := -1;
         END IF;

         l_last_update_login := FND_GLOBAL.LOGIN_ID;
         IF l_last_update_login IS NULL THEN
              l_last_update_login := -1;
         END IF;

         --insert data into Thesis Details table
         INSERT INTO igs_en_spa_awd_aim (
              person_id,
              course_cd,
              award_cd,
              start_dt,
              end_dt,
              complete_ind,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
	      conferral_date,
              award_mark       ,
              award_grade      ,
              grading_schema_cd,
              gs_version_number )
         VALUES (
              l_person_id,
              p_awd_aim_rec.program_cd,
              p_awd_aim_rec.award_cd,
              TRUNC(p_awd_aim_rec.start_dt),
              p_awd_aim_rec.end_dt,
              NVL( p_awd_aim_rec.complete_ind, 'N' ),
              l_last_updated_by,
              l_last_update_date,
              l_last_updated_by,
              l_last_update_date,
              l_last_update_login,
              p_awd_aim_rec.conferral_dt,
              p_awd_aim_rec.award_mark,
              p_awd_aim_rec.award_grade,
              p_awd_aim_rec.grading_schema_cd,
              p_awd_aim_rec.gs_version_number );
    END IF;

    --If l_stdnt_awd_aim_status is INVALID and x_return_status is not 'W' then
    --make it to 'E' and rollback if any transaction has happened and not commited.
    --If l_stdnt_awd_aim_status is VALID then x_return_status is 'S'.
    IF l_stdnt_awd_aim_status = 'INVALID' THEN
         IF x_return_status <> 'W' THEN
              x_return_status := FND_API.G_RET_STS_ERROR ;
         END IF;
         ROLLBACK TO awd_aim_pub;
    ELSIF l_stdnt_awd_aim_status = 'VALID' THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS ;
         -- Standard check of p_commit.
         IF FND_API.TO_BOOLEAN( p_commit ) THEN
             COMMIT WORK;
         END IF;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.COUNT_AND_GET ( p_count => x_msg_count,
                                p_data  => x_msg_data  );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK TO awd_aim_pub;
           x_return_status := FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.COUNT_AND_GET ( p_count => x_msg_count,
                                       p_data  => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO awd_aim_pub;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.COUNT_AND_GET ( p_count => x_msg_count,
                                       p_data  => x_msg_data );
    WHEN OTHERS THEN
           ROLLBACK TO awd_aim_pub;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name,
                                          l_api_name );
           END IF;
           FND_MSG_PUB.COUNT_AND_GET ( p_count => x_msg_count ,
                                       p_data  => x_msg_data );
END create_student_awd_aim;

END igs_en_spaa_lgcy_pub;

/
