--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPI_RCOND_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPI_RCOND_LGCY_PUB" AS
/* $Header: IGSENB5B.pls 120.0 2006/04/10 04:23:36 bdeviset noship $ */
/*-------------------------------------------------------------------------------------------
   Created by  : Basanth Devisetty, Oracle Student Systems Oracle IDC
   Purpose     : This package is used to validate the passed parameters of student
                 intermission return condition and insert the records.

  --Change History:
  --Who         When            What

---------------------------------------------------------------------------------------------*/

  g_pkg_name    CONSTANT VARCHAR2(30) := 'IGS_EN_SPI_RCOND_LGCY_PUB';

  FUNCTION validate_parameters(p_person_id      IN hz_parties.party_id%TYPE ,
                               p_intm_rcond_rec IN en_spi_rcond_rec_type)
   RETURN VARCHAR2 AS

   /**********************************************************************************************
   Created By       : bdeviset
   Date Created By  : 14-Mar-2005
   Purpose          : This function is used to validate the passed parameters
   Known limitations,enhancements,remarks:
   Change History
   Who     When       What
  ***********************************************************************************************/

    l_ret_val       VARCHAR2(1);

  BEGIN
    l_ret_val := 'S';

    -- Make sure the program code is in uppercase. If not throw Error
    IF p_intm_rcond_rec.program_cd <> UPPER(p_intm_rcond_rec.program_cd) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_PRGM_CD_UCASE');
      FND_MSG_PUB.ADD;
      l_ret_val := 'E';
    END IF;

    -- Ensure return condition is in uppercase. Otherwise throw Error
    IF p_intm_rcond_rec.return_condition <> UPPER(p_intm_rcond_rec.return_condition) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_INTM_RCOND_UCASE');
      FND_MSG_PUB.ADD;
      l_ret_val := 'E';
    END IF;


    RETURN l_ret_val;

  END validate_parameters;

  FUNCTION validate_db_cons ( p_person_id      IN hz_parties.party_id%TYPE ,
                              p_intm_rcond_rec IN en_spi_rcond_rec_type)
                              RETURN VARCHAR2 AS
   /**********************************************************************************************
   Created By       : bdeviset
   Date Created By  : 14-Mar-2005
   Purpose          : This function is used to validate database constraints
   Known limitations,enhancements,remarks:
   Change History
   Who     When       What
  ***********************************************************************************************/

    CURSOR chk_rcond_status IS
      SELECT 'x'
      FROM igs_lookup_values
      WHERE lookup_type = 'IGS_EN_INTM_RCOND_STS'
      AND lookup_Code = p_intm_rcond_rec.status_code;

    CURSOR chk_intermission (cp_person_id hz_parties.party_id%TYPE) IS
      SELECT cond_return_flag
      FROM igs_en_stdnt_ps_intm
      WHERE person_id = cp_person_id
      AND course_cd = p_intm_rcond_rec.program_cd
      AND start_dt = p_intm_rcond_rec.start_dt
      AND logical_delete_date = to_date('31-12-4712','DD-MM-YYYY');

    l_dummy VARCHAR2(1);
    l_ret_val VARCHAR2(1);


  BEGIN

    -- Ensure the return condition is valid by checking the intermission
    -- conditions. If not throw Error
    IF NOT igs_en_intm_rconds_pkg.get_pk_for_validation(x_return_condition => p_intm_rcond_rec.return_condition) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_SPI_INV_RCOND');
      FND_MSG_PUB.ADD;
      l_ret_val := 'E';
    END IF;

        -- Check whether the student intermission return condition already exists
    IF igs_en_spi_rconds_pkg.get_pk_for_validation (
                                  x_person_id           => p_person_id,
                                  x_course_cd           => p_intm_rcond_rec.program_cd,
                                  x_start_dt            => p_intm_rcond_rec.start_dt,
                                  x_logical_delete_date => to_date('31-12-4712','DD-MM-YYYY'),
                                  x_return_condition    => p_intm_rcond_rec.return_condition) THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_STU_INTM_RCOND_EXISTS');
      FND_MSG_PUB.ADD;
      l_ret_val := 'W';
    END IF;

    -- Ensure the return condition status is valid.
    -- Use lookup Type IGS_EN_INTM_RCOND_STS to determine the valid statuses
    OPEN chk_rcond_status;
    FETCH chk_rcond_status INTO l_dummy;
    IF chk_rcond_status%NOTFOUND THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_RCOND_INV_STS');
      FND_MSG_PUB.ADD;
      l_ret_val := 'E';
    END IF;
    CLOSE chk_rcond_status;

    ------ Validate parent record existence and return cond ind-------
    l_dummy := NULL;
    OPEN chk_intermission(p_person_id);
    FETCH chk_intermission INTO l_dummy;
    CLOSE chk_intermission;

    IF l_dummy IS NULL THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_STU_INTM_NOT_EXISTS');
      FND_MSG_PUB.ADD;
      l_ret_val := 'E';
    ELSIF l_dummy = 'N' THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_NOT_VLD_RCOND');
      FND_MSG_PUB.ADD;
      l_ret_val := 'E';
    END IF;

    RETURN l_ret_val;


  END validate_db_cons;


  PROCEDURE create_student_intm_rcond
                    ( p_api_version	      IN	NUMBER,
                      p_init_msg_list	    IN	VARCHAR2,
                      p_commit	          IN	VARCHAR2,
                      p_validation_level	IN	NUMBER,
                      p_intm_rcond_rec	  IN	en_spi_rcond_rec_type,
                      x_return_status	    OUT	NOCOPY VARCHAR2,
                      x_msg_count	        OUT	NOCOPY NUMBER,
                      x_msg_data	        OUT	NOCOPY VARCHAR2) AS

   /**********************************************************************************************
    Created By       : bdeviset
    Date Created By  : 14-Mar-2005
    Purpose          : Main API for importing student intermission Return Condition.
                       Created for Intermission Authorization to Return Build Bug# 5083465
    Known limitations,enhancements,remarks:
    Change History
    Who     When       What
   ***********************************************************************************************/

  l_rowid                       ROWID;
  l_course_attempt_status       igs_en_stdnt_ps_att.course_attempt_status%TYPE;
  l_person_id                   hz_parties.party_id%TYPE;
  l_sca_rec                     igs_en_stdnt_ps_att%ROWTYPE;
  l_insert_flag                 BOOLEAN;
  l_creation_date               igs_en_stdnt_ps_intm.creation_date%TYPE;
  l_last_update_date            igs_en_stdnt_ps_intm.last_update_date%TYPE;
  l_created_by                  igs_en_stdnt_ps_intm.created_by%TYPE;
  l_last_updated_by             igs_en_stdnt_ps_intm.last_updated_by%TYPE;
  l_last_update_login           igs_en_stdnt_ps_intm.last_update_login%TYPE;
  l_api_name                    CONSTANT    VARCHAR2(30) := 'create_student_intm_rcond';
  l_api_version                 CONSTANT    NUMBER       := 1.0;
  l_approver_id                 hz_parties.party_id%TYPE;
  l_ret_val                     VARCHAR2(1);

  CURSOR c_crs_status (cp_person_id igs_en_stdnt_ps_att.person_id%TYPE) IS
    SELECT course_attempt_status
    FROM igs_en_stdnt_ps_att
    WHERE person_id = cp_person_id
    AND course_cd = p_intm_rcond_rec.program_cd;

  BEGIN

    SAVEPOINT create_en_spi_rcond_pub;
    -- initialze the insert flag for inserting student intermission
    -- return condition to true
    l_insert_flag := TRUE;

    -- Check if the api version and the parameter p_api_version are compatible. If not raise and FND unexpected error.
    IF NOT FND_API.COMPATIBLE_API_CALL( p_current_version_number => l_api_version,
                                        p_caller_version_number  => p_api_version,
                                        p_api_name               => l_api_name,
                                        p_pkg_name               => 'IGS_EN_SPI_RCOND_LGCY_PUB')
    THEN

      l_insert_flag := FALSE;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 		END IF;

    -- initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- If parameter p_init_msg_list is passed as TRUE, then initialize the message list
    IF FND_API.TO_BOOLEAN (p_init_msg_list) THEN
      FND_MSG_PUB.INITIALIZE;
    END IF;


    -- Ensure Person Number is valid.  Otherwise throw Error
    l_person_id := NULL;
    l_person_id := Igs_Ge_Gen_003.get_person_id(p_intm_rcond_rec.person_number);
    IF l_person_id IS NULL THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
      FND_MSG_PUB.ADD;
      l_insert_flag := FALSE;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- If Approver Number is provided then ensure that it is valid.
    -- Otherwise throw Error
    IF p_intm_rcond_rec.approver_number IS NOT NULL THEN
      l_approver_id := NULL;
      l_approver_id := Igs_Ge_Gen_003.get_person_id(p_intm_rcond_rec.approver_number);
      IF l_approver_id IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_NO_APPROV_PERSON');
        FND_MSG_PUB.ADD;
        l_insert_flag := FALSE;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

     END IF;



    IF l_insert_flag THEN
      -- validate the parameters passed
      IF validate_parameters(l_person_id,p_intm_rcond_rec) = 'E' THEN
        l_insert_flag := FALSE;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    OPEN c_crs_status ( l_person_id);
    FETCH c_crs_status INTO l_course_attempt_status;
    CLOSE c_crs_status;

    IF l_insert_flag THEN
      l_ret_val := validate_db_cons( l_person_id, p_intm_rcond_rec);
       IF l_ret_val = 'E' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_insert_flag := FALSE;
       ELSIF l_ret_val = 'W' THEN
          x_return_status := 'W';
          l_insert_flag := FALSE;
       END IF;
    END IF;

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

          -- insert the student intermission return cond record
          INSERT INTO igs_en_spi_rconds (
                                          person_id,
                                          course_cd,
                                          start_dt,
                                          logical_delete_date,
                                          return_condition,
                                          status_code,
                                          approved_dt,
                                          approved_by,
                                          created_by,
                                          creation_date,
                                          last_updated_by,
                                          last_update_date,
                                          last_update_login
                                        )
                                VALUES (
                                        l_person_id,
                                        p_intm_rcond_rec.program_cd,
                                        p_intm_rcond_rec.start_dt,
                                        to_date('31-12-4712','DD-MM-YYYY'),
                                        p_intm_rcond_rec.return_condition,
                                        p_intm_rcond_rec.status_code,
                                        p_intm_rcond_rec.approved_dt,
                                        l_approver_id,
                                        l_created_by,
                                        l_creation_date,
                                        l_last_updated_by,
                                        l_last_update_date,
                                        l_last_update_login
                                      );

          IF l_course_attempt_status <> 'INTERMIT' AND p_intm_rcond_rec.status_code IN ('PENDING','FAILED') THEN

              -- call the api to know whether program attempt status has changed
              -- if so update the spa table with new status
              IF igs_en_gen_legacy.check_sca_status_upd (
                                                          p_person_id               => l_person_id,
                                                          p_program_cd              =>  p_intm_rcond_rec.program_cd,
                                                          p_called_from             =>  'SPI',
                                                          p_course_attempt_status   => l_course_attempt_status
                                                          ) THEN
                  UPDATE igs_en_stdnt_ps_att_all SET course_attempt_status = 'INTERMIT'
                  WHERE person_id = l_person_id
                  AND course_cd = p_intm_rcond_rec.program_cd;

              END IF;-- IF igs_en_gen_legacy.check_sca_status_upd

          END IF; -- IF l_course_attempt_status <> 'INTERMIT' AND p_intm_rcond_rec.status_code IN ('PENDING','FAILED')

    ELSE

      ROLLBACK TO create_en_spi_rcond_pub;

    END IF; -- IF l_insert_flag

    -- Commit the record which is inserted in the table.
    IF (FND_API.TO_BOOLEAN(p_commit) AND l_insert_flag ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.COUNT_AND_GET( p_count   => x_msg_count,
                              p_data    => x_msg_data);

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO create_en_spi_rcond_pub;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                  p_data           => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO create_en_spi_rcond_pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                  p_data           => x_msg_data);

    WHEN OTHERS THEN
       ROLLBACK TO create_en_spi_rcond_pub;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name,
                                  l_api_name);
       END IF;
       FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                  p_data           => x_msg_data);

  END create_student_intm_rcond;


END igs_en_spi_rcond_lgcy_pub;

/
