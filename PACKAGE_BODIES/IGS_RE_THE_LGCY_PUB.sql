--------------------------------------------------------
--  DDL for Package Body IGS_RE_THE_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_THE_LGCY_PUB" AS
/* $Header: IGSRE20B.pls 115.9 2002/12/30 09:19:42 nbehera noship $ */

--  Who             When            What
--  (reverse chronological order - newest change first)
--  Nishikant       27DEC2002       Bug#2722106. If all the fields submission_dt,thesis_result_cd,thesis_exam_type
--                                  and thesis_panel_type are having NULL value then dont create the thesis exam record.
--                                  In this case only Thesis Details record will be created of 'PENDING' status.
--                                  If any of these field value is available then proceed to insert the Thesis Exam Record,
--                                  after the bussiness validation and db_cons validations for the the Exam record will be
--                                  done successfully.


-- Global variable which contains the package name.
g_pkg_name CONSTANT VARCHAR2(30):='IGS_RE_THE_LGCY_PUB';

PROCEDURE validate_parameters(
         p_the_dtls_rec IN  the_dtls_rec_type ,
         p_the_status   OUT NOCOPY VARCHAR2) IS
  /*
  ||  Created By : nbehera
  ||  Created On : 14-NOV-2002
  ||  Purpose : This procedure validates all the fields in the parameter p_the_dtls_rec
  ||            which require some validation
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
   l_msg_count  NUMBER := 0;
BEGIN
   p_the_status := 'VALID';
   -- Check for value exists for person number
   IF p_the_dtls_rec.person_number IS NULL THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_EN_PER_NUM_NULL');
         FND_MSG_PUB.ADD;
         p_the_status := 'INVALID';
   END IF;

   -- Check for value exists for Program Code
   IF p_the_dtls_rec.program_cd IS NULL THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_CD_NULL');
         FND_MSG_PUB.ADD;
         p_the_status := 'INVALID';
   END IF;

   -- Check for value exists for title
   IF p_the_dtls_rec.title IS NULL THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_RE_THE_TITLE_NUL');
         FND_MSG_PUB.ADD;
         p_the_status := 'INVALID';
   END IF;

   --check constraint for final_title_ind, it should be 'Y' or 'N'
   IF p_the_dtls_rec.final_title_ind IS NOT NULL THEN
      BEGIN
         igs_re_thesis_pkg.check_constraints('final_title_ind',p_the_dtls_rec.final_title_ind);
      EXCEPTION
         WHEN OTHERS THEN
            l_msg_count := FND_MSG_PUB.COUNT_MSG;
            FND_MSG_PUB.DELETE_MSG (p_msg_index  =>  l_msg_count);
            FND_MESSAGE.SET_NAME('IGS','IGS_RE_FNL_TITLE_INV');
            FND_MSG_PUB.ADD;
            p_the_status := 'INVALID';
      END;
   END IF;

   --Check constraint for the final thesis result code
   IF p_the_dtls_rec.final_thesis_result_cd IS NOT NULL THEN
      BEGIN
         igs_re_thesis_pkg.check_constraints('thesis_result_cd',p_the_dtls_rec.final_thesis_result_cd);
      EXCEPTION
         WHEN OTHERS THEN
            l_msg_count := FND_MSG_PUB.COUNT_MSG;
            FND_MSG_PUB.DELETE_MSG (p_msg_index  =>  l_msg_count);
            FND_MESSAGE.SET_NAME('IGS','IGS_RE_RESULT_CD_INVALID_VAL');
            FND_MSG_PUB.ADD;
            p_the_status := 'INVALID';
      END;
   END IF;

   --Check constraint for thesis exam type
   IF p_the_dtls_rec.thesis_exam_type IS NOT NULL THEN
      BEGIN
         igs_re_thesis_exam_pkg.check_constraints('thesis_exam_type',p_the_dtls_rec.thesis_exam_type);
      EXCEPTION
         WHEN OTHERS THEN
            l_msg_count := FND_MSG_PUB.COUNT_MSG;
            FND_MSG_PUB.DELETE_MSG (p_msg_index  =>  l_msg_count);
            FND_MESSAGE.SET_NAME('IGS','IGS_RE_EXAM_TYP_INVALID_VAL');
            FND_MSG_PUB.ADD;
            p_the_status := 'INVALID';
      END;
   END IF;

   --Check constraint for the Thesis Panel Type parameter
   IF p_the_dtls_rec.thesis_panel_type IS NOT NULL THEN
      BEGIN
         igs_re_thesis_exam_pkg.check_constraints('thesis_panel_type',p_the_dtls_rec.thesis_panel_type);
      EXCEPTION
         WHEN OTHERS THEN
            l_msg_count := FND_MSG_PUB.COUNT_MSG;
            FND_MSG_PUB.DELETE_MSG (p_msg_index  =>  l_msg_count);
            FND_MESSAGE.SET_NAME('IGS','IGS_RE_PNL_TYP_INVALID_VAL');
            FND_MSG_PUB.ADD;
            p_the_status := 'INVALID';
      END;
   END IF;

   --Check Constraint for the thesis result code
   IF p_the_dtls_rec.thesis_result_cd IS NOT NULL THEN
      BEGIN
         igs_re_thesis_exam_pkg.check_constraints('thesis_result_cd',p_the_dtls_rec.thesis_result_cd);
      EXCEPTION
         WHEN OTHERS THEN
            l_msg_count := FND_MSG_PUB.COUNT_MSG;
            FND_MSG_PUB.DELETE_MSG (p_msg_index  =>  l_msg_count);
            FND_MESSAGE.SET_NAME('IGS','IGS_RE_RESULT_CD_INVALID_VAL');
            FND_MSG_PUB.ADD;
            p_the_status := 'INVALID';
      END;
   END IF;

END validate_parameters;

FUNCTION validate_the_db_cons(
        p_person_id          IN  NUMBER ,
        p_ca_sequence_number IN  NUMBER,
        p_the_dtls_rec       IN  the_dtls_rec_type)
RETURN VARCHAR2 IS
  /*
  ||  Created By : nbehera
  ||  Created On : 14-NOV-2002
  ||  Purpose    : This Procedure Checks for all the database constraints required to
  ||               check before insertion of a Thesis Details record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
l_ret_status VARCHAR2(1) := 'S';
BEGIN

   --check for duplicate record in the Thesis table
   IF NOT igs_re_val_the.check_dup_thesis (
                       p_person_id ,
                       p_the_dtls_rec.title,
                       p_ca_sequence_number) THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_RE_THE_DUPLIDATE');
            FND_MSG_PUB.ADD;
            RETURN 'W';
   END IF;

    -- FK check in the Thesis Result table
   IF p_the_dtls_rec.final_thesis_result_cd IS NOT NULL THEN
        IF NOT IGS_RE_THESIS_RESULT_PKG.Get_PK_For_Validation (
                        p_the_dtls_rec.final_thesis_result_cd ) THEN
                  FND_MESSAGE.SET_NAME ('IGS', 'IGS_RE_RESULT_CD_INVALID_VAL');
                  FND_MSG_PUB.ADD;
                  l_ret_status := 'E';
        END IF;
   END IF;
   RETURN l_ret_status;

END validate_the_db_cons;

PROCEDURE validate_the (
        p_person_id          IN  NUMBER ,
        p_ca_sequence_number IN  NUMBER,
        p_the_dtls_rec       IN  the_dtls_rec_type ,
        p_the_status         OUT NOCOPY VARCHAR2 )  IS
  /*
  ||  Created By : nbehera
  ||  Created On : 14-NOV-2002
  ||  Purpose    : This procedure checks all the business validations before
  ||               inserting a Thesis Details Record
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
   l_thesis_status VARCHAR2(15) := NULL;
   l_message       fnd_new_messages.message_name%TYPE;
   l_dummy_bool    BOOLEAN;
BEGIN
   p_the_status := 'VALID';

   --IF Expected Submission Date < Minimum Submission Date  OR Expected Submission Date > Maximum Submission Date
   --then error will be logged.
   l_message := NULL;
   l_dummy_bool := igs_re_val_the.resp_val_the_expct (
                    p_person_id ,
                    p_ca_sequence_number,
                    p_the_dtls_rec.expected_submission_dt,
                    'Y',
                    l_message);
   IF l_message IS NOT NULL THEN
            p_the_status := 'INVALID';
   END IF;

   -- If submission date available and final thesis result code is not available then thesis_status should be 'SUBMITTED'
   -- If submission date available and final thesis result code is available then thesis_status should be 'EXAMINED'
   -- If submission date is not available then thesis_status should be 'PENDING'
   IF p_the_dtls_rec.submission_dt IS NOT NULL THEN
      IF p_the_dtls_rec.final_thesis_result_cd IS NULL THEN
            l_thesis_status := 'SUBMITTED';
      ELSE
            l_thesis_status := 'EXAMINED';
      END IF;
   ELSE
            l_thesis_status := 'PENDING';
   END IF ;

   l_message := NULL;
   -- Embargo details or Embargo Expiry date cannot have value unless the thesis has been SUBMITTED or EXAMINED
   -- If Embargo Expiration Date is available without Embargo Details then log error message.
   l_dummy_bool := igs_re_val_the.resp_val_the_embrg(
                p_the_dtls_rec.embargo_details,
                NULL,
                p_the_dtls_rec.embargo_expiry_dt,
                l_thesis_status,
                'Y',
                l_message);
   IF l_message IS NOT NULL THEN
          p_the_status := 'INVALID';
   END IF;

   --If thesis status is either SUBMITTED or EXAMINED.
   IF l_thesis_status = 'SUBMITTED' OR l_thesis_status = 'EXAMINED' THEN

       l_message := NULL;
       --If final title indicator has not been set and thesis status is either SUBMITTED or EXAMINED
       --then log error message
       l_dummy_bool := igs_re_val_the.resp_val_the_fnl(
                    p_person_id,
                    p_ca_sequence_number,
                    NULL,
                    p_the_dtls_rec.final_title_ind,
                    l_thesis_status,
                    l_message);
       IF l_message IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_RE_CANT_SUBMIT_THESIS');
              FND_MSG_PUB.ADD;
              p_the_status := 'INVALID';
       END IF;

       l_message := NULL;
       -- If final result indicator is not set then log error message
       l_dummy_bool := igs_re_val_the.resp_val_the_thr(
                    p_person_id,
                    p_ca_sequence_number ,
                    NULL,
                    p_the_dtls_rec.final_thesis_result_cd,
                    l_thesis_status,
                    'Y',
                    l_message);
       IF l_message IS NOT NULL THEN
              p_the_status := 'INVALID';
       END IF;

       -- If Thesis result code is not available and the thesis status is EXAMINED then log error message.
       IF p_the_dtls_rec.thesis_result_cd IS NULL AND
          l_thesis_status = 'EXAMINED' THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_RE_CHK_RES_OUTSTAND_EXAM');
              FND_MSG_PUB.ADD;
              p_the_status := 'INVALID';
       END IF;

   -- If thesis status is PENDING.
   ELSE

       l_message := NULL;
       -- If citation Details are available then log error message, since thesis status is not SUBMITTED or EXAMINED
       l_dummy_bool := igs_re_val_the.resp_val_the_ctn(
                    l_thesis_status,
                    p_the_dtls_rec.citation,
                    l_message);
       IF l_message IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_RE_CANT_ENTER_GRAD_CITAT');
              FND_MSG_PUB.ADD;
              p_the_status := 'INVALID';
       END IF;


       l_message := NULL;
       -- If library catalog number or library lodgement date is available then log error message, since thesis status
       -- is not SUBMITTED or EXAMINED
       l_dummy_bool := igs_re_val_the.resp_val_the_lbry(
                    p_person_id,
                    p_ca_sequence_number,
                    NULL,
                    p_the_dtls_rec.library_catalogue_number,
                    p_the_dtls_rec.library_lodgement_dt,
                    l_thesis_status,
                    l_message);
       IF l_message IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_RE_CANT_ENTER_LIBR_DETAIL');
              FND_MSG_PUB.ADD;
              p_the_status := 'INVALID';
       END IF;


       l_message := NULL;
       --If thesis result code is available and thesis status is PENDING then log error message
       --If final result indicator is not set then log error message
       l_dummy_bool := igs_re_val_the.resp_val_the_thr(
                    p_person_id,
                    p_ca_sequence_number ,
                    NULL,
                    p_the_dtls_rec.final_thesis_result_cd,
                    l_thesis_status,
                    'Y',
                    l_message);
       IF l_message IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_RE_CHK_RES_NOT_FINAL_RES');
              FND_MSG_PUB.ADD;
              p_the_status := 'INVALID';
       END IF;
   END IF;

END validate_the;

FUNCTION validate_the_exam_db_cons(
        p_person_id           IN  NUMBER ,
        p_ca_sequence_number  IN  NUMBER,
        p_the_dtls_rec        IN  the_dtls_rec_type )
RETURN VARCHAR2 IS
  /*
  ||  Created By : nbehera
  ||  Created On : 14-NOV-2002
  ||  Purpose    : This Procedure Checks for all the database constraints required to
  ||               check before insertion of a Thesis exam record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
l_ret_status VARCHAR2(1) := 'S';
BEGIN
    --Primary key check in the Thesis Exam table is not required.
    --This check is not required because the sequence number of the thesis record ,
    --which is freshly being picked up from a sequence will be unique.
    --And the sequence number is part of the primary key of the thesis exam table,
    --Then definitely the pk check will not be failed for any thesis exam record.

    --FK check to the table igs_re_ths_exam_type for the field thesis_exam_type
    IF p_the_dtls_rec.thesis_exam_type IS NOT NULL THEN
        IF NOT igs_re_ths_exam_type_pkg.get_pk_for_validation (
                        p_the_dtls_rec.thesis_exam_type) THEN
                  FND_MESSAGE.SET_NAME ('IGS', 'IGS_RE_THE_EXM_TYP_INV');
                  FND_MSG_PUB.ADD;
                  l_ret_status := 'E';
        END IF;
    END IF;

    --FK check to the table igs_re_thesis_result for the field thesis_result_cd
    IF p_the_dtls_rec.thesis_result_cd IS NOT NULL THEN
        IF NOT igs_re_thesis_result_pkg.get_pk_for_validation (
                        p_the_dtls_rec.thesis_result_cd ) THEN
                  FND_MESSAGE.SET_NAME ('IGS', 'IGS_RE_THE_RES_CD_INV');
                  FND_MSG_PUB.ADD;
                  l_ret_status := 'E';
        END IF;
    END IF;

    --FK check to the table igs_re_ths_pnl_type for the field thesis_panel_type
    IF p_the_dtls_rec.thesis_panel_type IS NOT NULL THEN
        IF NOT igs_re_ths_pnl_type_pkg.get_pk_for_validation (
                        p_the_dtls_rec.thesis_panel_type) THEN
                  FND_MESSAGE.SET_NAME ('IGS', 'IGS_RE_THE_PNL_TYP_INV');
                  FND_MSG_PUB.ADD;
                  l_ret_status := 'E';
        END IF;
    END IF;
    RETURN l_ret_status;

END validate_the_exam_db_cons;

PROCEDURE validate_the_exam(
        p_person_id          IN  NUMBER,
        p_ca_sequence_number IN  NUMBER,
        p_the_dtls_rec       IN  the_dtls_rec_type,
        p_exam_status        OUT NOCOPY VARCHAR2 )  IS
  /*
  ||  Created By : nbehera
  ||  Created On : 14-NOV-2002
  ||  Purpose    : This procedure checks all the business validations before
  ||               inserting a Thesis Exam Record
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  Nishikant       30DEC2002       Bug#2722106. A new validation has been put to check for the fields
  ||                                  thesis_exam_type, thesis_panel_type, submission_dt.
  */
   l_thesis_status VARCHAR2(15) := NULL;
   l_message       fnd_new_messages.message_name%TYPE;
   l_dummy_bool    BOOLEAN;
BEGIN
   p_exam_status := 'VALID';

   --The following check added added as part of the Bug#2722106
   --If THESIS_EXAM_TYPE is available , THESIS_PANEL_TYPE should also be available for the Thesis Exam Details record.
   --Simm. if THESIS_PANEL_TYPE is available, THESIS_PANEL_TYPE should also be available.
   --If SUBMISSION_DATE is available then both of THESIS_EXAM_TYPE and THESIS_PANEL_TYPE should also be available.
   IF ( p_the_dtls_rec.thesis_exam_type  IS NULL  AND
        p_the_dtls_rec.thesis_panel_type IS NOT NULL ) OR
      ( p_the_dtls_rec.thesis_panel_type IS NULL  AND
        p_the_dtls_rec.thesis_exam_type  IS NOT NULL ) OR
      ( p_the_dtls_rec.submission_dt     IS NOT NULL AND
        p_the_dtls_rec.thesis_exam_type  IS NULL ) THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_EN_INCOMP_THE_EXAM_DTLS');
            FND_MSG_PUB.ADD;
            p_exam_status := 'INVALID';
   END IF;

   l_message := NULL;
   -- The below validations are being taken care in the following function call
   -- If final title indicator is 'N' and submission date is available then log error message.
   -- If Principal supervisor is not available and submission date is available then log error message.
   -- If Govt type of activity code has not been set and submission date is available then log error message.
   -- If submission date is prior to course attempt commencement date then log error message.
   l_dummy_bool := igs_re_val_tex.resp_val_tex_sbmsn(
                    p_person_id,
                    p_ca_sequence_number,
                    NULL,
                    NULL,-- pass NULL for creation_dt
                    p_the_dtls_rec.thesis_result_cd,
                    p_the_dtls_rec.submission_dt,
                    'Y',
                    p_the_dtls_rec.final_title_ind,-- new parameter added
                    l_message);
    IF l_message IS NOT NULL THEN
         p_exam_status := 'INVALID';
    END IF;

END validate_the_exam;

PROCEDURE create_the
(       p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2,
        p_commit                IN      VARCHAR2,
        p_validation_level      IN      NUMBER,
        p_the_dtls_rec          IN      the_dtls_rec_type ,
        x_return_status         OUT     NOCOPY VARCHAR2,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2 ) IS
  /*
  ||  Created By : nbehera
  ||  Created On : 14-NOV-2002
  ||  Purpose    : This procedure inserts records into the Thesis Details table and
  ||               Thesis Exam table after checking all the validations.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  Nishikant       27DEC2002       Bug#2722106. If any of the fields thesis_exam_type, thesis_panel_type
  ||                                  submission_dt, thesis_result_cd having NOT NULL value then proceed to insert the
  ||                                  EXAM Record after all the bussiness validations are done successfully.
  ||                                  Otherwise Insert only the Thesis Details Record, skip the Thesis Exam record.
  */

CURSOR c_the_seq_num IS
SELECT IGS_RE_THESIS_SEQ_NUM_S.NEXTVAL
FROM DUAL;
l_the_seq_num        igs_re_thesis_all.sequence_number%TYPE;

l_api_name           CONSTANT VARCHAR2(30) := 'Thesis Details';
l_api_version        CONSTANT NUMBER := 1.0;
l_the_exam_status    VARCHAR2(15) := 'VALID';
l_person_id          igs_re_thesis.person_id%TYPE := NULL;
l_ca_sequence_number igs_re_candidature_all.sequence_number%TYPE;
l_creation_dt        igs_re_thesis_exam.creation_dt%TYPE := SYSDATE;
l_last_update_date   igs_re_thesis_all.creation_date%TYPE;
l_last_updated_by    igs_re_thesis_all.last_updated_by%TYPE;
l_last_update_login  igs_re_thesis_all.last_update_login%TYPE;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT  THEDET_PUB;

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
  validate_parameters( p_the_dtls_rec,
                       l_the_exam_status  );

  /****** Deriving values for the parameters ******/
  IF l_the_exam_status <> 'INVALID' THEN
      -- Calling the function to get the person_id
      l_person_id := igs_ge_gen_003.get_person_id( p_the_dtls_rec.person_number);
      IF l_person_id IS NULL THEN
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
          FND_MSG_PUB.ADD;
          l_the_exam_status := 'INVALID';
      END IF;

      -- Calling the function to get the value for ca_sequence_number
      IF NOT igs_re_val_the.get_candidacy_dtls(
                         l_person_id,
                         p_the_dtls_rec.program_cd,
                         l_ca_sequence_number) THEN
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_RE_CANT_LOCATE_CAND_DET');
          FND_MSG_PUB.ADD;
          l_the_exam_status := 'INVALID';
      END IF;
  END IF;

  /****** Check for the Database constraints for the thesis details record ******/
  IF l_the_exam_status <> 'INVALID' THEN
      x_return_status:= validate_the_db_cons(
          l_person_id,
          l_ca_sequence_number,
          p_the_dtls_rec);
      IF x_return_status <> 'S' THEN
          l_the_exam_status := 'INVALID';
      END IF;
  END IF;

  /****** Check the bussiness validation for the thesis details record ******/
  IF l_the_exam_status <> 'INVALID' THEN
      validate_the (
          l_person_id,
          l_ca_sequence_number ,
          p_the_dtls_rec,
          l_the_exam_status);
  END IF;

  /****** Insert data into Thesis Details and Thesis Exam table ******/
  IF l_the_exam_status <> 'INVALID' THEN --1st level IF clause starts here

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

      -- Getting the sequence number from the sequence for the field sequence_number
      OPEN c_the_seq_num;
      FETCH c_the_seq_num INTO l_the_seq_num;
      CLOSE c_the_seq_num;

      BEGIN
        --insert data into Thesis Details table
        INSERT INTO igs_re_thesis_all (
          PERSON_ID,
          CA_SEQUENCE_NUMBER,
          SEQUENCE_NUMBER,
          TITLE,
          FINAL_TITLE_IND,
          SHORT_TITLE,
          ABBREVIATED_TITLE,
          THESIS_RESULT_CD,
          EXPECTED_SUBMISSION_DT,
          LIBRARY_LODGEMENT_DT,
          LIBRARY_CATALOGUE_NUMBER,
          EMBARGO_EXPIRY_DT,
          THESIS_FORMAT,
          LOGICAL_DELETE_DT,
          EMBARGO_DETAILS,
          THESIS_TOPIC,
          CITATION,
          COMMENTS,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          ORG_ID )
        VALUES (
          l_person_id,
          l_ca_sequence_number,
          l_the_seq_num,
          p_the_dtls_rec.title,
          NVL(p_the_dtls_rec.final_title_ind,'N'),
          p_the_dtls_rec.short_title,
          p_the_dtls_rec.abbreviated_title,
          p_the_dtls_rec.final_thesis_result_cd,
          p_the_dtls_rec.expected_submission_dt,
          p_the_dtls_rec.library_lodgement_dt,
          p_the_dtls_rec.library_catalogue_number,
          p_the_dtls_rec.embargo_expiry_dt,
          p_the_dtls_rec.thesis_format,
          NULL,
          p_the_dtls_rec.embargo_details,
          p_the_dtls_rec.thesis_topic,
          p_the_dtls_rec.citation,
          p_the_dtls_rec.comments,
          l_last_update_date,
          l_last_updated_by,
          l_last_update_date,
          l_last_updated_by,
          l_last_update_login,
          igs_ge_gen_003.get_org_id);
      END;

      --Condition added as part of the Bug#2722106.
      --If all of the fields submission_dt,thesis_result_cd, thesis_exam_type and thesis_panel_type are having NULL value
      --then dont create the thesis exam record. In this case only Thesis Details record will be created of 'PENDING' status.
      --If any of these field value is available then proceed to insert the Thesis Exam Record, after the
      --bussiness validation and db_cons validations for the the Exam record will be over successfully.
      IF p_the_dtls_rec.submission_dt     IS NOT NULL OR
         p_the_dtls_rec.thesis_exam_type  IS NOT NULL OR
         p_the_dtls_rec.thesis_panel_type IS NOT NULL OR
         p_the_dtls_rec.thesis_result_cd  IS NOT NULL THEN  --2nd level IF clause starts here

           /****** Check for the Database constraints for the Thesis Exam record ******/
           x_return_status:= validate_the_exam_db_cons(
                                               l_person_id,
                                               l_ca_sequence_number,
                                               p_the_dtls_rec);
           IF x_return_status <> 'S' THEN
               l_the_exam_status := 'INVALID';
           END IF;

           /****** Check the bussiness validation for the Thesis Exam record ******/
           IF l_the_exam_status <> 'INVALID' THEN
               validate_the_exam(
                   l_person_id,
                   l_ca_sequence_number,
                   p_the_dtls_rec,
                   l_the_exam_status);
           END IF;

           IF l_the_exam_status <> 'INVALID' THEN  --3rd level IF clause starts here
                 BEGIN
                       --insert data into thesis exam table
                       INSERT INTO igs_re_thesis_exam (
                         PERSON_ID,
                         CA_SEQUENCE_NUMBER,
                         THE_SEQUENCE_NUMBER,
                         CREATION_DT,
                         SUBMISSION_DT,
                         THESIS_EXAM_TYPE,
                         THESIS_PANEL_TYPE,
                         TRACKING_ID,
                         THESIS_RESULT_CD,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_LOGIN )
                       VALUES (
                         l_person_id,
                         l_ca_sequence_number,
                         l_the_seq_num,
                         l_creation_dt,
                         p_the_dtls_rec.submission_dt,
                         p_the_dtls_rec.thesis_exam_type,
                         p_the_dtls_rec.thesis_panel_type,
                         NULL, --tracking_id
                         p_the_dtls_rec.thesis_result_cd,
                         l_last_update_date,
                         l_last_updated_by,
                         l_last_update_date,
                         l_last_updated_by,
                         l_last_update_login);
                 END;
           END IF; --3rd level IF clause ends here
      END IF; --2nd level IF clause ends here
  END IF; --1st level IF clause ends here

  IF l_the_exam_status = 'INVALID' THEN
       IF x_return_status <> 'W' THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
       END IF;
       ROLLBACK TO THEDET_PUB;
  ELSIF l_the_exam_status = 'VALID' THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS ;
       -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit ) THEN
              COMMIT WORK;
       END IF;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (
                p_count => x_msg_count,
                p_data  => x_msg_data  );

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO THEDET_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data  );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO THEDET_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data  );

        WHEN OTHERS THEN
                ROLLBACK TO THEDET_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (g_pkg_name,
                         l_api_name );
                END IF;
                FND_MSG_PUB.Count_And_Get (
                        p_count => x_msg_count,
                        p_data  => x_msg_data );
END create_the;

END igs_re_the_lgcy_pub;

/
