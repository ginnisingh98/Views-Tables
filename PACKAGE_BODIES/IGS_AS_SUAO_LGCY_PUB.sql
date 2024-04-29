--------------------------------------------------------
--  DDL for Package Body IGS_AS_SUAO_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SUAO_LGCY_PUB" AS
/* $Header: IGSPAS1B.pls 120.0 2005/07/05 12:03:21 appldev noship $ */

/***********************************************************************************************
 ||
 ||Created By:        Arun Iyer
 ||
 ||Date Created By:   20-11-2002
 ||
 ||Purpose:       This package creates a student Assessment unit outcome record.
 ||
 ||
 ||Known limitations,enhancements,remarks:
 ||
 ||Change History
 ||
 ||Who        When             What
 ||knaraset   14-May-2003      Modified the context of sua and suao to have location_cd and Unit_class or uoo_id,
 ||                            as part of MUS build bug 2829262
 ||Aiyer      09-Jan-2003      Modified the function Validate_Unit_Outcome for the fix of
 ||                            the bug 2741946.
 ||Aiyer      02-Jan-2003      Modified Function Validte_Parameters for the bug #2732559.
 ||ijeddy     12-Apr-2005      Bug 4079384. set release_date to outcome_dt if finalised_outcome_ind = 'Y'
 ||                                and outcome_dt is not null.
************************************************************************************************/


G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGS_AS_SUAO_LGCY_PUB';

-- forward declaration of procedure/function used in this package

/*
  validate_parameters function checks all the mandatory parameters
  for the passed record type are not null
*/

  FUNCTION validate_parameters ( p_lgcy_suo_rec   IN	LGCY_SUO_REC_TYPE )
  RETURN BOOLEAN ;



/*
 Function Derive_unit_outcome_data - Derives the value for the following parameters: -
  1. Person_id from person_number
  2. Calendar type, calendar sequence number, calendar Start and End date  from calendar alternate code
  3. Derive the unit attempt status for the student unit attempt
  4. Translated Grading schema code, Translated version number, Translated grade and Translated date
  5. Derive the grading schems code and version number from the grade.
  6. Derive the incomplete grading schema code and incomplete version number if they have not been specified.
*/

  FUNCTION derive_unit_outcome_data (
                                     p_lgcy_suo_rec                 IN OUT NOCOPY  LGCY_SUO_REC_TYPE                                        ,
                                     p_person_id                    IN OUT NOCOPY  IGS_PE_PERSON.PERSON_ID%TYPE                             ,
                                     p_cal_type		            IN OUT NOCOPY  IGS_CA_INST.CAL_TYPE%TYPE                                ,
                                     p_sequence_number	            IN OUT NOCOPY  IGS_CA_INST.SEQUENCE_NUMBER%TYPE                         ,
                                     p_start_dt		            OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.CI_START_DT%TYPE                  ,
                                     p_end_dt		            OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.CI_END_DT%TYPE                    ,
				     p_unit_attempt_status          OUT    NOCOPY  IGS_EN_SU_ATTEMPT_ALL.UNIT_ATTEMPT_STATUS%TYPE           ,
                                     p_translated_grading_schema_cd OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_GRADING_SCHEMA_CD%TYPE ,
                                     p_translated_version_number    OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_VERSION_NUMBER%TYPE    ,
                                     p_translated_grade		    OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_GRADE%TYPE             ,
                                     p_translated_dt		    OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_DT%TYPE		    ,
                                     p_number_of_times		    OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.NUMBER_TIMES_KEYED%TYPE,
                                     p_uoo_id                       OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.UOO_ID%TYPE,
                                     p_release_date                 OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.RELEASE_DATE%TYPE
				   )
  RETURN BOOLEAN;



/*
  Function validate_suao_db_cons -
  Performs all data integrity validations on the table igs_as_su_stmptout_all
  It is called from the procedure create_unit_outcome.
*/
 FUNCTION validate_suao_db_cons (
                                     p_person_id                    IN         IGS_PE_PERSON.PERSON_ID%TYPE                              ,
				     p_lgcy_suo_rec                 IN         LGCY_SUO_REC_TYPE                                         ,
				     p_cal_type                     IN         IGS_CA_INST.CAL_TYPE%TYPE                                 ,
				     p_sequence_number              IN         IGS_CA_INST.SEQUENCE_NUMBER%TYPE                          ,
				     p_translated_version_number    IN         IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_VERSION_NUMBER%TYPE     ,
				     x_return_status                OUT NOCOPY VARCHAR2,
                     p_uoo_id                       IN         IGS_AS_SU_STMPTOUT_ALL.UOO_ID%TYPE
				)
 RETURN BOOLEAN;


/*
  Procedure validate_unit_outcome -
  Validates all the business validations before importing a record in the table IGS_AS_SU_STMPT_OUT_ALL.
  Called from the procedure create_unit_outcome
*/

FUNCTION validate_unit_outcome (
                                  p_lgcy_suo_rec         LGCY_SUO_REC_TYPE                               ,
				  p_unit_attempt_status  IGS_EN_SU_ATTEMPT_ALL.UNIT_ATTEMPT_STATUS%TYPE
			       )

RETURN BOOLEAN ;



/*
  Procedure create_post_unit_outcome -
  Performs all the post insert operations on the table IGS_AS_SU_STMPTOUT_ALL.
  Called from the procedure create_unit_outcome
*/

PROCEDURE create_post_unit_outcome (
                                    p_person_id            IGS_PE_PERSON.PERSON_ID%TYPE                       ,
				    p_cal_type             IGS_CA_INST.CAL_TYPE%TYPE                          ,
				    p_sequence_number      IGS_CA_INST.SEQUENCE_NUMBER%TYPE                   ,
                                    p_unit_attempt_status  IGS_EN_SU_ATTEMPT_ALL.UNIT_ATTEMPT_STATUS%TYPE     ,
                                    p_lgcy_suo_rec         LGCY_SUO_REC_TYPE
                               );



PROCEDURE gen_log_info (p_msg IN VARCHAR2)
AS
  /***********************************************************************************************
   Created By:        Arun Iyer

   Date Created By:   19-11-2002

   Purpose:     This procedure is mainly used for debugging purposes.
                Debug messages can be put in the code at various places to check the various
		loops in the code.

   Known limitations,enhancements,remarks:

   Change History

   Who        When        What
  ********************************************************************************************** */

  -- Variable Declarations.

BEGIN
  null;
END gen_log_info;


PROCEDURE initialise ( p_lgcy_suo_rec IN OUT NOCOPY LGCY_SUO_REC_TYPE )
 /************************************************************************************************************************
  ||Created By : Aiyer
  ||Date Created on : 2002/11/26
  ||Purpose :  This procedure initialises the record type fields to null
  ||
  ||
  ||Know limitations, enhancements or remarks
  ||Change History
  ||Who             When            What
  ||(reverse chronological order - newest change first)
 *************************************************************************************************************************/
IS
BEGIN

      p_lgcy_suo_rec.person_number                   := NULL;
      p_lgcy_suo_rec.program_cd                      := NULL;
      p_lgcy_suo_rec.unit_cd                         := NULL;
      p_lgcy_suo_rec.teach_cal_alt_code              := NULL;
      p_lgcy_suo_rec.outcome_dt                      := NULL;
      p_lgcy_suo_rec.grading_schema_cd               := NULL;
      p_lgcy_suo_rec.version_number                  := NULL;
      p_lgcy_suo_rec.grade                           := NULL;
      p_lgcy_suo_rec.s_grade_creation_method_type    := NULL;
      p_lgcy_suo_rec.finalised_outcome_ind           := NULL;
      p_lgcy_suo_rec.mark                            := NULL;
      p_lgcy_suo_rec.incomp_deadline_date            := NULL;
      p_lgcy_suo_rec.incomp_grading_schema_cd        := NULL;
      p_lgcy_suo_rec.incomp_version_number           := NULL;
      p_lgcy_suo_rec.incomp_default_grade            := NULL;
      p_lgcy_suo_rec.incomp_default_mark             := NULL;
      p_lgcy_suo_rec.comments                        := NULL;
      p_lgcy_suo_rec.grading_period_cd               := NULL;
      p_lgcy_suo_rec.attribute_category              := NULL;
      p_lgcy_suo_rec.attribute1                      := NULL;
      p_lgcy_suo_rec.attribute2                      := NULL;
      p_lgcy_suo_rec.attribute3                      := NULL;
      p_lgcy_suo_rec.attribute4                      := NULL;
      p_lgcy_suo_rec.attribute5                      := NULL;
      p_lgcy_suo_rec.attribute6                      := NULL;
      p_lgcy_suo_rec.attribute7                      := NULL;
      p_lgcy_suo_rec.attribute8                      := NULL;
      p_lgcy_suo_rec.attribute9                      := NULL;
      p_lgcy_suo_rec.attribute10                     := NULL;
      p_lgcy_suo_rec.attribute11                     := NULL;
      p_lgcy_suo_rec.attribute12                     := NULL;
      p_lgcy_suo_rec.attribute13                     := NULL;
      p_lgcy_suo_rec.attribute14                     := NULL;
      p_lgcy_suo_rec.attribute15                     := NULL;
      p_lgcy_suo_rec.attribute16                     := NULL;
      p_lgcy_suo_rec.attribute17                     := NULL;
      p_lgcy_suo_rec.attribute18                     := NULL;
      p_lgcy_suo_rec.attribute19                     := NULL;
      p_lgcy_suo_rec.attribute20                     := NULL;
      p_lgcy_suo_rec.location_cd                     := NULL;
      p_lgcy_suo_rec.unit_class                      := NULL;

END initialise;



PROCEDURE create_unit_outcome
            (p_api_version                 IN  NUMBER,
	     p_init_msg_list               IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	     p_commit                      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	     p_validation_level            IN  VARCHAR2 DEFAULT FND_API.G_VALID_LEVEL_FULL,
	     p_lgcy_suo_rec                IN  LGCY_SUO_REC_TYPE,
	     x_return_status               OUT NOCOPY VARCHAR2,
	     x_msg_count                   OUT NOCOPY NUMBER,
	     x_msg_data                    OUT NOCOPY VARCHAR2
	    )
 /************************************************************************************************************************
  ||Created By : Aiyer
  ||Date Created on : 2002/11/26
  ||Purpose :  The procedure create_unit_outcome creates a student unit outcome record in the table IGS_AS_SU_STMPT_OUT_ALL
  ||           after doing the following validations :-
  ||           1. Validate the parameters passed to the api                      -- call function validate_parameters
  ||           2. Derive all the necessary values from the values passed         -- call function derive_unit_outcome_data
  ||           3. Validate all the database constraints                          -- call function validate_suao_db_cons
  ||           4. Validate all the business validations                          -- call function validate_unit_outcome
  ||           5. Insert data into table IGS_AS_SU_STMPTOUT_ALL                  -- direct DML operation in this procedure
  ||           6. Perform post insert operations on table IGS_AS_SU_STMPTOUT_ALL -- call procedure create_post_unit_outcome
  ||Know limitations, enhancements or remarks
  ||Change History
  ||Who             When            What
  ||(reverse chronological order - newest change first)
 *************************************************************************************************************************/
   IS
    l_api_name		            CONSTANT  VARCHAR2(30)               := 'create_unit_outcome' ;
    l_api_version 		    CONSTANT  NUMBER                     := 1.0                   ;
    l_person_id                     IGS_PE_PERSON.PERSON_ID%TYPE                                  ;
    l_cal_type		            IGS_CA_INST.CAL_TYPE%TYPE                                     ;
    l_sequence_number	            IGS_CA_INST.SEQUENCE_NUMBER%TYPE                              ;
    l_start_dt		            IGS_AS_SU_STMPTOUT_ALL.CI_START_DT%TYPE                       ;
    l_end_dt		            IGS_AS_SU_STMPTOUT_ALL.CI_END_DT%TYPE                         ;
    l_unit_attempt_status           IGS_EN_SU_ATTEMPT_ALL.UNIT_ATTEMPT_STATUS%TYPE                ;
    l_translated_grading_schema_cd  IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_GRADING_SCHEMA_CD%TYPE      ;
    l_translated_version_number     IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_VERSION_NUMBER%TYPE         ;
    l_translated_grade		    IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_GRADE%TYPE                  ;
    l_translated_dt		    IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_DT%TYPE		          ;
    l_number_of_times		    IGS_AS_SU_STMPTOUT_ALL.NUMBER_TIMES_KEYED%TYPE	          ;
    l_lgcy_suo_rec                  LGCY_SUO_REC_TYPE                                             ;
    l_uoo_id                        IGS_AS_SU_STMPTOUT_ALL.UOO_ID%TYPE;
    l_release_date                  IGS_AS_SU_STMPTOUT_ALL.RELEASE_DATE%TYPE;
    duplicate_record_exists         EXCEPTION;
  BEGIN
  --Standard start of API savepoint
        SAVEPOINT create_unit_outcome;

  --Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call(
					l_api_version,
					p_api_version,
					l_api_name,
					G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

  --Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

  --Initialize API return status to success.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

      /*
          Assigning values to the the record type variable l_lgcy_suo_rec_type from p_lgcy_suo_rec_type
      */

      l_lgcy_suo_rec.person_number                   :=  p_lgcy_suo_rec.person_number                           ;
      l_lgcy_suo_rec.program_cd                      :=  UPPER(p_lgcy_suo_rec.program_cd)                  	;
      l_lgcy_suo_rec.unit_cd                         :=  UPPER(p_lgcy_suo_rec.unit_cd)                     	;
      l_lgcy_suo_rec.teach_cal_alt_code              :=  UPPER(p_lgcy_suo_rec.teach_cal_alt_code)          	;
      l_lgcy_suo_rec.outcome_dt                      :=  p_lgcy_suo_rec.outcome_dt                         	;
      l_lgcy_suo_rec.grading_schema_cd               :=  UPPER(p_lgcy_suo_rec.grading_schema_cd)           	;
      l_lgcy_suo_rec.version_number                  :=  p_lgcy_suo_rec.version_number                    	;
      l_lgcy_suo_rec.grade                           :=  UPPER(p_lgcy_suo_rec.grade)                       	;
      l_lgcy_suo_rec.s_grade_creation_method_type    :=  UPPER(p_lgcy_suo_rec.s_grade_creation_method_type)     ;
      l_lgcy_suo_rec.finalised_outcome_ind           :=  UPPER(p_lgcy_suo_rec.finalised_outcome_ind)            ;
      l_lgcy_suo_rec.mark                            :=  p_lgcy_suo_rec.mark                               	;
      l_lgcy_suo_rec.incomp_deadline_date            :=  p_lgcy_suo_rec.incomp_deadline_date               	;
      l_lgcy_suo_rec.incomp_grading_schema_cd        :=  UPPER(p_lgcy_suo_rec.incomp_grading_schema_cd)      	;
      l_lgcy_suo_rec.incomp_version_number           :=  p_lgcy_suo_rec.incomp_version_number                	;
      l_lgcy_suo_rec.incomp_default_grade            :=  UPPER(p_lgcy_suo_rec.incomp_default_grade)          	;
      l_lgcy_suo_rec.incomp_default_mark             :=  p_lgcy_suo_rec.incomp_default_mark                  	;
      l_lgcy_suo_rec.comments                        :=  p_lgcy_suo_rec.comments                             	;
      l_lgcy_suo_rec.grading_period_cd               :=  UPPER(p_lgcy_suo_rec.grading_period_cd)             	;
      l_lgcy_suo_rec.attribute_category              :=  p_lgcy_suo_rec.attribute_category                   	;
      l_lgcy_suo_rec.attribute1                      :=  p_lgcy_suo_rec.attribute1                           	;
      l_lgcy_suo_rec.attribute2                      :=  p_lgcy_suo_rec.attribute2                           	;
      l_lgcy_suo_rec.attribute3                      :=  p_lgcy_suo_rec.attribute3                           	;
      l_lgcy_suo_rec.attribute4                      :=  p_lgcy_suo_rec.attribute4                           	;
      l_lgcy_suo_rec.attribute5                      :=  p_lgcy_suo_rec.attribute5                           	;
      l_lgcy_suo_rec.attribute6                      :=  p_lgcy_suo_rec.attribute6                           	;
      l_lgcy_suo_rec.attribute7                      :=  p_lgcy_suo_rec.attribute7                           	;
      l_lgcy_suo_rec.attribute8                      :=  p_lgcy_suo_rec.attribute8                           	;
      l_lgcy_suo_rec.attribute9                      :=  p_lgcy_suo_rec.attribute9                           	;
      l_lgcy_suo_rec.attribute10                     :=  p_lgcy_suo_rec.attribute10                          	;
      l_lgcy_suo_rec.attribute11                     :=  p_lgcy_suo_rec.attribute11                          	;
      l_lgcy_suo_rec.attribute12                     :=  p_lgcy_suo_rec.attribute12                          	;
      l_lgcy_suo_rec.attribute13                     :=  p_lgcy_suo_rec.attribute13                          	;
      l_lgcy_suo_rec.attribute14                     :=  p_lgcy_suo_rec.attribute14                          	;
      l_lgcy_suo_rec.attribute15                     :=  p_lgcy_suo_rec.attribute15                          	;
      l_lgcy_suo_rec.attribute16                     :=  p_lgcy_suo_rec.attribute16                          	;
      l_lgcy_suo_rec.attribute17                     :=  p_lgcy_suo_rec.attribute17                          	;
      l_lgcy_suo_rec.attribute18                     :=  p_lgcy_suo_rec.attribute18                          	;
      l_lgcy_suo_rec.attribute19                     :=  p_lgcy_suo_rec.attribute19                         	;
      l_lgcy_suo_rec.attribute20                     :=  p_lgcy_suo_rec.attribute20                         	;
      l_lgcy_suo_rec.location_cd                     :=  p_lgcy_suo_rec.location_cd                     	;
      l_lgcy_suo_rec.unit_class                      :=  p_lgcy_suo_rec.unit_class                     	    ;

  gen_log_info ('START OF FUNCTION CREATE UNIT OUTCOME');

/*************************************** Validation 1 ******************************************/

/*
   Validate all the paramters passed to this api
*/

  gen_log_info('Start of create_unit_outcome.validation 1');

  IF NOT VALIDATE_PARAMETERS( p_lgcy_suo_rec => l_lgcy_suo_rec ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  gen_log_info('End  of create_unit_outcome.validation 1');

/*************************************** Validation 2 ******************************************/

/*
  Derive all the necessary columns eruiqred while importing a ercord in the table igs_as_su_stmptout_all
*/
 gen_log_info('Start of create_unit_outcome.validation 2');

 IF NOT derive_unit_outcome_data (
                                     p_lgcy_suo_rec                 => l_lgcy_suo_rec                    ,
                                     p_person_id                    => l_person_id                       ,
                                     p_cal_type		            => l_cal_type		         ,
                                     p_sequence_number	            => l_sequence_number	         ,
                                     p_start_dt		            => l_start_dt		         ,
                                     p_end_dt		            => l_end_dt		                 ,
				     p_unit_attempt_status          => l_unit_attempt_status             ,
                                     p_translated_grading_schema_cd => l_translated_grading_schema_cd    ,
                                     p_translated_version_number    => l_translated_version_number       ,
                                     p_translated_grade		    => l_translated_grade		 ,
                                     p_translated_dt		    => l_translated_dt		         ,
                                     p_number_of_times		    => l_number_of_times,
                                     p_uoo_id                       => l_uoo_id,
                                     p_release_date                 => l_release_date
				   )
  THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  gen_log_info('End  of create_unit_outcome.validation 2');

/*************************************** Validation 3 ******************************************/
/*
   Validate the data integrity rules on the table igs_as_stmptout_all before importing records.
*/

  gen_log_info('Start of create_unit_outcome.validation 3');

  IF  NOT validate_suao_db_cons (
                                     p_person_id                    => l_person_id                    	,
				     p_lgcy_suo_rec                 => l_lgcy_suo_rec                 	,
				     p_cal_type                     => l_cal_type                     	,
				     p_sequence_number              => l_sequence_number              	,
				     p_translated_version_number    => l_translated_version_number    	,
				     x_return_status                => x_return_status,
                     p_uoo_id                       => l_uoo_id
				)
   THEN
     IF x_return_status = 'W' THEN
        RAISE duplicate_record_exists;
     ELSE
        RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  gen_log_info('End  of create_unit_outcome.validation 3');

/*************************************** Validation 4 ******************************************/
/*
   Validate the business rules on the table igs_as_stmptout_all before inporting records
*/

  gen_log_info('Start of create_unit_outcome.validation 4');

  IF NOT validate_unit_outcome (
                                 p_lgcy_suo_rec        => l_lgcy_suo_rec      ,
                                 p_unit_attempt_status => l_unit_attempt_status
			       ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  gen_log_info('End  of create_unit_outcome.validation 4');

/*************************************** Validation 5 ******************************************/
/*

  Insert a record in the table igs_as_su_stmptout_all

*/

  gen_log_info('Start of create_unit_outcome.validation 5');

  INSERT INTO IGS_AS_SU_STMPTOUT_ALL
  (
    PERSON_ID                           ,
    COURSE_CD                     	,
    UNIT_CD                       	,
    CAL_TYPE                      	,
    CI_SEQUENCE_NUMBER            	,
    CI_START_DT                   	,
    CI_END_DT                     	,
    OUTCOME_DT                    	,
    GRADING_SCHEMA_CD             	,
    VERSION_NUMBER                	,
    GRADE                         	,
    S_GRADE_CREATION_METHOD_TYPE  	,
    FINALISED_OUTCOME_IND         	,
    MARK                          	,
    NUMBER_TIMES_KEYED            	,
    TRANSLATED_GRADING_SCHEMA_CD  	,
    TRANSLATED_VERSION_NUMBER     	,
    TRANSLATED_GRADE              	,
    TRANSLATED_DT                 	,
    CREATED_BY                    	,
    CREATION_DATE                 	,
    LAST_UPDATED_BY               	,
    LAST_UPDATE_DATE              	,
    LAST_UPDATE_LOGIN             	,
    REQUEST_ID                    	,
    PROGRAM_APPLICATION_ID        	,
    PROGRAM_ID                    	,
    PROGRAM_UPDATE_DATE           	,
    ORG_ID                        	,
    GRADING_PERIOD_CD             	,
    ATTRIBUTE_CATEGORY            	,
    ATTRIBUTE1                    	,
    ATTRIBUTE2                    	,
    ATTRIBUTE3                    	,
    ATTRIBUTE4                    	,
    ATTRIBUTE5                    	,
    ATTRIBUTE6                    	,
    ATTRIBUTE7                    	,
    ATTRIBUTE8                    	,
    ATTRIBUTE9                    	,
    ATTRIBUTE10                   	,
    ATTRIBUTE11                   	,
    ATTRIBUTE12                   	,
    ATTRIBUTE13                   	,
    ATTRIBUTE14                   	,
    ATTRIBUTE15                         ,
    ATTRIBUTE16                   	,
    ATTRIBUTE17                   	,
    ATTRIBUTE18                   	,
    ATTRIBUTE19                   	,
    ATTRIBUTE20                   	,
    INCOMP_DEADLINE_DATE          	,
    INCOMP_GRADING_SCHEMA_CD      	,
    INCOMP_VERSION_NUMBER         	,
    INCOMP_DEFAULT_GRADE          	,
    INCOMP_DEFAULT_MARK           	,
    COMMENTS,
    UOO_ID,
    RELEASE_DATE
)
VALUES
(
    l_person_id                                                               ,
    l_lgcy_suo_rec.program_cd	                                              ,
    l_lgcy_suo_rec.unit_cd					              ,
    l_cal_type							              ,
    l_sequence_number							      ,
    l_start_dt								      ,
    l_end_dt								      ,
    l_lgcy_suo_rec.outcome_dt					              ,
    l_lgcy_suo_rec.grading_schema_cd				              ,
    l_lgcy_suo_rec.version_number					      ,
    l_lgcy_suo_rec.grade						      ,
    l_lgcy_suo_rec.s_grade_creation_method_type			              ,
    l_lgcy_suo_rec.finalised_outcome_ind				      ,
    l_lgcy_suo_rec.mark						              ,
    l_number_of_times							      ,
    l_translated_grading_schema_cd				              ,
    l_translated_version_number						      ,
    l_translated_grade					                      ,
    l_translated_dt							      ,
    nvl(fnd_global.user_id,-1)						      ,
    SYSDATE								      ,
    NVL(fnd_global.user_id,-1)						      ,
    sysdate								      ,
    NVL(fnd_global.login_id,-1)						      ,
    DECODE(fnd_global.conc_request_id,-1,null,fnd_global.conc_request_id)     ,
    DECODE(fnd_global.conc_request_id,-1,null,fnd_global.prog_appl_id)	      ,
    DECODE(fnd_global.conc_request_id,-1,null,fnd_global.conc_program_id)     ,
    DECODE(fnd_global.conc_request_id,-1,null,sysdate)			      ,
    igs_ge_gen_003.get_org_id						      ,
    l_lgcy_suo_rec.grading_period_cd                                          ,
    l_lgcy_suo_rec.attribute_category				              ,
    l_lgcy_suo_rec.attribute1					              ,
    l_lgcy_suo_rec.attribute2					              ,
    l_lgcy_suo_rec.attribute3					              ,
    l_lgcy_suo_rec.attribute4					              ,
    l_lgcy_suo_rec.attribute5					              ,
    l_lgcy_suo_rec.attribute6					              ,
    l_lgcy_suo_rec.attribute7					              ,
    l_lgcy_suo_rec.attribute8					              ,
    l_lgcy_suo_rec.attribute9					              ,
    l_lgcy_suo_rec.attribute10					              ,
    l_lgcy_suo_rec.attribute11					              ,
    l_lgcy_suo_rec.attribute12					              ,
    l_lgcy_suo_rec.attribute13					              ,
    l_lgcy_suo_rec.attribute14					              ,
    l_lgcy_suo_rec.attribute15					              ,
    l_lgcy_suo_rec.attribute16					              ,
    l_lgcy_suo_rec.attribute17					              ,
    l_lgcy_suo_rec.attribute18					              ,
    l_lgcy_suo_rec.attribute19					              ,
    l_lgcy_suo_rec.attribute20					              ,
    l_lgcy_suo_rec.incomp_deadline_date				              ,
    l_lgcy_suo_rec.incomp_grading_schema_cd			              ,
    l_lgcy_suo_rec.incomp_version_number			              ,
    l_lgcy_suo_rec.incomp_default_grade				              ,
    l_lgcy_suo_rec.incomp_default_mark				              ,
    l_lgcy_suo_rec.comments,
    l_uoo_id,
    l_release_date
);

   gen_log_info('End  of create_unit_outcome.validation 5');

/*************************************** Validation 6 ******************************************/

/*
   Perform Post insert activities on the table igs_as_su_stmptout_all
*/
  gen_log_info('Start of create_unit_outcome.validation 6');

 create_post_unit_outcome (
                               p_person_id            => l_person_id               ,
                               p_cal_type             => l_cal_type                ,
                               p_sequence_number      => l_sequence_number         ,
                               p_unit_attempt_status  => l_unit_attempt_status     ,
                               p_lgcy_suo_rec         => l_lgcy_suo_rec
                            );

  gen_log_info('End  of create_unit_outcome.validation 6');


/*==================== End Of Code ===================================*/

  --Standard check of p_commit.
  IF FND_API.to_Boolean(p_commit) AND x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     commit;
  END IF;

  gen_log_info('END  OF FUNCTION CREATE_UNIT_OUTCOME.VALIDATION');

  RETURN ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_unit_outcome;
	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                    p_count => x_msg_count,
                                    p_data  => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_unit_outcome;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                    p_count => x_msg_count,
                                    p_data  => x_msg_data
				 );
     WHEN DUPLICATE_RECORD_EXISTS THEN
        ROLLBACK TO create_unit_outcome;
        x_return_status := 'W';
        FND_MSG_PUB.Count_And_Get(
                                    p_count => x_msg_count,
                                    p_data  => x_msg_data
				 );

     WHEN OTHERS THEN
       ROLLBACK TO create_unit_outcome;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_UNHANDLED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

  END create_unit_outcome;

  FUNCTION validate_parameters ( p_lgcy_suo_rec   IN	LGCY_SUO_REC_TYPE )
  RETURN BOOLEAN

  /************************************************************************************************************************
   ||Created By : Aiyer
   ||Date Created on : 2002/11/26
   ||
   ||Purpose :  The function validate_parameters validates the parameters passed to the api.
   ||           It is called by the procedure create_unit_outcome.
   ||
   ||Know limitations, enhancements or remarks
   ||Change History
   ||Who             When            What
   ||(reverse chronological order - newest change first)
   ||Aiyer          02-Jan-2003      Validation 10 modified for the bug #2732559.
   ||                                Modified where clause to remove check for check for result_type = 'INCOMP'
  *************************************************************************************************************************/

  IS
  l_return_status BOOLEAN := TRUE;
  BEGIN

     gen_log_info('START OF FUNCTION VALIDATE_PARAMETERS');

    /*************************************** Validation 1 ******************************************/

     gen_log_info('Start of validate_parameters.Validation 1');

    IF p_lgcy_suo_rec.person_number IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_PER_NUM_NULL');
       FND_MSG_PUB.ADD;
       l_return_status := FALSE;
    END IF;

     gen_log_info('End of validate_parameters.Validation 1');

    /*************************************** Validation 2 ******************************************/

    gen_log_info('Start of validate_parameters.Validation 2');

    IF p_lgcy_suo_rec.program_cd IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_PRGM_CD_NULL');
       FND_MSG_PUB.ADD;
       l_return_status := FALSE;
    END IF;

     gen_log_info('End of validate_parameters.Validation 2');

    /*************************************** Validation 3 ******************************************/
     gen_log_info('Start of validate_parameters.Validation 3');
    IF p_lgcy_suo_rec.unit_cd IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_UNIT_CD_NULL');
       FND_MSG_PUB.ADD;
       l_return_status := FALSE;
    END IF;
     gen_log_info('End of validate_parameters.Validation 3');
    /*************************************** Validation 4 ******************************************/
     gen_log_info('Start of validate_parameters.Validation 4');
    IF p_lgcy_suo_rec.teach_cal_alt_code IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_TCAL_ALTCD_NULL');
       FND_MSG_PUB.ADD;
       l_return_status := FALSE;
    END IF;
     gen_log_info('End of validate_parameters.Validation 4');
    /*************************************** Validation 5 ******************************************/
     gen_log_info('Start of validate_parameters.Validation 5');
    IF p_lgcy_suo_rec.outcome_dt IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_OTCM_DT_NULL');
       FND_MSG_PUB.ADD;
       l_return_status := FALSE;
    END IF;
     gen_log_info('End of validate_parameters.Validation 5');

    /*************************************** Validation 6 ******************************************/

     gen_log_info('Start of validate_parameters.Validation 6');
    IF p_lgcy_suo_rec.grade IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_GRADE_NULL');
       FND_MSG_PUB.ADD;
       l_return_status := FALSE;
    END IF;
     gen_log_info('End of validate_parameters.Validation 6');

    /*************************************** Validation 7 ******************************************/

     gen_log_info('Start of validate_parameters.Validation 7');
    IF p_lgcy_suo_rec.grading_period_cd IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_GRAD_PRD_NULL');
       FND_MSG_PUB.ADD;
       l_return_status := FALSE;
    END IF;
     gen_log_info('End of validate_parameters.Validation 7');

    /*************************************** Validation 8 ******************************************/

     /*
       A not null value for both grading schema and version number should exist or both should be null.
     */
      gen_log_info('Start of validate_parameters.Validation 8');

      IF p_lgcy_suo_rec.grading_schema_cd IS NOT NULL AND p_lgcy_suo_rec.version_number IS NULL THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_GRDVER_NULL_NOTNULL');
         FND_MSG_PUB.ADD;
         l_return_status := FALSE;
      ELSIF p_lgcy_suo_rec.grading_schema_cd IS NULL AND p_lgcy_suo_rec.version_number IS NOT NULL THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_GRDVER_NULL_NOTNULL');
         FND_MSG_PUB.ADD;
         l_return_status := FALSE;
      END IF;
     gen_log_info('End of validate_parameters.Validation 7');

    /*************************************** Validation 9 ******************************************/

     gen_log_info('Start of validate_parameters.Validation 9');

    /*
      1. If an incomplete grading schema code is not null then the incomplete grading schema version number should be between
         1 and 999 and should have a valid setup in table igs_as_grd_schema
      2. ELSE if a incomp version number is not null then the incomp grading schema also needs to be not null
    */

    DECLARE
    -- Check that a valid value for incomplete_grading_schema_cd and incomp_version_number already exists
    CURSOR cur_incomp_grd_sch_exists
    IS
    SELECT
            'X'
    FROM
            igs_as_grd_schema
    WHERE
            grading_schema_cd =  p_lgcy_suo_rec.incomp_grading_schema_cd AND
            version_number    =  p_lgcy_suo_rec.incomp_version_number;

    l_exists VARCHAR2(1);

    BEGIN
      IF p_lgcy_suo_rec.incomp_grading_schema_cd IS NOT NULL THEN

         IF NVL(p_lgcy_suo_rec.incomp_version_number,0) NOT BETWEEN 1 and 999 THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_INCMP_VERNUM_BET_0_999');
         FND_MSG_PUB.ADD;
         l_return_status := FALSE;
         END IF;

         /*
	   check if a valid value for both incomplete grading schema and incomplete grading schema version number exists in the set up
	   table igs_as_grd_schema.
	   IF not then raise an error message.
	 */
         OPEN  cur_incomp_grd_sch_exists;
	 FETCH cur_incomp_grd_sch_exists INTO l_exists;
	 IF cur_incomp_grd_sch_exists%NOTFOUND THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_INCMP_GRDVER_BOTNULL');
           FND_MSG_PUB.ADD;
           l_return_status := FALSE;
         END IF;
         CLOSE cur_incomp_grd_sch_exists;


      ELSIF p_lgcy_suo_rec.incomp_grading_schema_cd IS NULL AND p_lgcy_suo_rec.incomp_version_number IS NOT NULL THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_INCMP_GRDVER_BOTNULL');
         FND_MSG_PUB.ADD;
         l_return_status := FALSE;
      END IF;
    END;

     gen_log_info('End of validate_parameters.Validation 9');
    /*************************************** Validation 10 ******************************************/

     gen_log_info('Start of validate_parameters.Validation 10');

    /*
       1. If the incomplete default grade is not null then the incomp_grading_schema_cd and incomp_version_number
          also needs to be not null.
       2. If the incomplete default grade is not null then it should be defined within the incomplete
          grading schema cd/version number
    */

    IF p_lgcy_suo_rec.incomp_default_grade IS NOT NULL THEN
       -- Incomplete default grade is not null
       IF p_lgcy_suo_rec.incomp_grading_schema_cd IS NULL OR p_lgcy_suo_rec.incomp_version_number IS NULL THEN
         -- incomplete grading schema code or incomplete version has be sent to the API as null.
	 -- set an error message to stack
         FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_INCMP_GRADE_NOT_EXIST');
         FND_MSG_PUB.ADD;
         l_return_status := FALSE;
       ELSE
         -- incomplete grading schema code and incomplete version both are not nulls
         DECLARE
	   -- check whether the incomplete default grade lies within an incomplete grading schema /incomplete version number
	   /* Code modified for the bug 2732559. The Default grade need not be  of Result Type 'Incomplete' */
           CURSOR cur_incomp_grade_exists
	   IS
	   SELECT
	          'X'
           FROM
                  igs_as_grd_sch_grade ggs
	   WHERE
                  grading_schema_cd = p_lgcy_suo_rec.incomp_grading_schema_cd  AND
                  version_number    = p_lgcy_suo_rec.incomp_version_number     AND
	          grade             = p_lgcy_suo_rec.incomp_default_grade;

           l_exists VARCHAR2(1);
	 BEGIN
            OPEN  cur_incomp_grade_exists;
	    FETCH cur_incomp_grade_exists INTO l_exists;
	    IF cur_incomp_grade_exists%NOTFOUND THEN

	       /* set an error message as the incomplete default grade has not been defined  for the incomplete
	          grading schema code/incomplete version number combination
               */

               FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_INVALID_INCMP_GRADE');
               FND_MSG_PUB.ADD;
               l_return_status := FALSE;
	    END IF;
            CLOSE cur_incomp_grade_exists;
	 END;
       END IF;
    END IF;

     gen_log_info('End of validate_parameters.Validation 10');

    /*************************************** Validation 11 ******************************************/

     /*
       1. Incomplete grading schema and incomplete default grade cannot be null when a incomplete default mark
          has been specified.
       2. Incomplete default mark should lie within the range of marks for the given incomplete grading schemas code ,
          incomplete_version number and incomplete default grade.
     */

    gen_log_info('Start of validate_parameters.Validation 11');

    IF p_lgcy_suo_rec.incomp_default_mark IS NOT NULL THEN
       -- Incomplete defalut mark is not null
       IF p_lgcy_suo_rec.incomp_grading_schema_cd IS NULL OR p_lgcy_suo_rec.incomp_default_grade IS NULL THEN
         -- incomplete grading schema code or incomplete default grade has been sent to the APi as null.
	 -- set an error message to stack
         FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_INCMP_MARK_NOT_EXIST');
         FND_MSG_PUB.ADD;
         l_return_status := FALSE;
       ELSE
         -- incomplete grading schema code and incomplete default grade both are not nulls
         DECLARE
	    -- check whether the incomplete default mark lies between the lower and upper mark ranges for a
	    -- incomplete grading schema ,incomplete version number and incomplete default grade.
           CURSOR cur_chk_mark_range_valid
	   IS
	   SELECT
	          'X'
           FROM
                  igs_as_grd_sch_grade ggs
	   WHERE
                  grading_schema_cd = p_lgcy_suo_rec.incomp_grading_schema_cd  AND
                  version_number    = p_lgcy_suo_rec.incomp_version_number     AND
	          grade             = p_lgcy_suo_rec.incomp_default_grade      AND
		  p_lgcy_suo_rec.incomp_default_mark                           BETWEEN
		  NVL(LOWER_MARK_RANGE,p_lgcy_suo_rec.incomp_default_mark)     AND
                  NVL(UPPER_MARK_RANGE,p_lgcy_suo_rec.incomp_default_mark) ;

           l_exists VARCHAR2(1);
	 BEGIN
           OPEN  cur_chk_mark_range_valid;
	   FETCH cur_chk_mark_range_valid INTO l_exists;
           IF cur_chk_mark_range_valid%NOTFOUND THEN

	       /* set an error message as the incomplete default mark does not lie within the lower and upper mark ranges for
	          the passed incomplete grading schema code, incomplete version number and incomplete default grade combination.
               */

               FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_INVALID_INCMP_MARK');
               FND_MSG_PUB.ADD;
               l_return_status := FALSE;

	   END IF;
	   CLOSE cur_chk_mark_range_valid;
	 END;
       END IF;
    END IF;


     gen_log_info('End of validate_parameters.Validation 11');

    /*************************************** Validation 11 ******************************************/

     gen_log_info('Start of validate_parameters.Validation 12');

    /*
      Validate that parameter p_lgcy_suo_rec.grading_period_cd cannot have any other values except 'MIDTERM' or 'FINAL'
    */
    IF p_lgcy_suo_rec.grading_period_cd <> 'MIDTERM' AND p_lgcy_suo_rec.grading_period_cd <> 'FINAL' THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_GRD_PRD_INVALID');
       FND_MSG_PUB.ADD;
       l_return_status := FALSE;
    END IF;

    gen_log_info('End of validate_parameters.Validation 12');

    /*************************************** Validation 13 ******************************************/

    gen_log_info('Start of validate_parameters.Validation 13');
    /*
      Validate the flex definition
    */

    --
    -- If any of the Descriptive Flex field columns have value, validate them .
    -- Added to fix Bug#
    IF (p_lgcy_suo_rec.attribute_category IS NOT NULL OR p_lgcy_suo_rec.attribute1  IS NOT NULL OR p_lgcy_suo_rec.attribute2  IS NOT NULL OR
        p_lgcy_suo_rec.attribute3  IS NOT NULL OR p_lgcy_suo_rec.attribute4  IS NOT NULL OR p_lgcy_suo_rec.attribute5  IS NOT NULL OR
        p_lgcy_suo_rec.attribute6  IS NOT NULL OR p_lgcy_suo_rec.attribute7  IS NOT NULL OR p_lgcy_suo_rec.attribute8  IS NOT NULL OR
        p_lgcy_suo_rec.attribute9  IS NOT NULL OR p_lgcy_suo_rec.attribute10 IS NOT NULL OR p_lgcy_suo_rec.attribute11 IS NOT NULL OR
        p_lgcy_suo_rec.attribute12 IS NOT NULL OR p_lgcy_suo_rec.attribute13 IS NOT NULL OR p_lgcy_suo_rec.attribute14 IS NOT NULL OR
        p_lgcy_suo_rec.attribute15 IS NOT NULL OR p_lgcy_suo_rec.attribute16 IS NOT NULL OR p_lgcy_suo_rec.attribute17 IS NOT NULL OR
        p_lgcy_suo_rec.attribute18 IS NOT NULL OR p_lgcy_suo_rec.attribute19 IS NOT NULL OR p_lgcy_suo_rec.attribute20 IS NOT NULL ) THEN
      IF NOT IGS_AD_IMP_018.validate_desc_flex(
        p_attribute_category => p_lgcy_suo_rec.attribute_category,
        p_attribute1         => p_lgcy_suo_rec.attribute1        ,
        p_attribute2         => p_lgcy_suo_rec.attribute2        ,
        p_attribute3         => p_lgcy_suo_rec.attribute3        ,
        p_attribute4         => p_lgcy_suo_rec.attribute4        ,
        p_attribute5         => p_lgcy_suo_rec.attribute5        ,
        p_attribute6         => p_lgcy_suo_rec.attribute6        ,
        p_attribute7         => p_lgcy_suo_rec.attribute7        ,
        p_attribute8         => p_lgcy_suo_rec.attribute8        ,
        p_attribute9         => p_lgcy_suo_rec.attribute9        ,
        p_attribute10        => p_lgcy_suo_rec.attribute10       ,
        p_attribute11        => p_lgcy_suo_rec.attribute11       ,
        p_attribute12        => p_lgcy_suo_rec.attribute12       ,
        p_attribute13        => p_lgcy_suo_rec.attribute13       ,
        p_attribute14        => p_lgcy_suo_rec.attribute14       ,
        p_attribute15        => p_lgcy_suo_rec.attribute15       ,
        p_attribute16        => p_lgcy_suo_rec.attribute16       ,
        p_attribute17        => p_lgcy_suo_rec.attribute17       ,
        p_attribute18        => p_lgcy_suo_rec.attribute18       ,
        p_attribute19        => p_lgcy_suo_rec.attribute19       ,
        p_attribute20        => p_lgcy_suo_rec.attribute20       ,
        p_desc_flex_name     => 'IGS_AS_SU_STMPTOUT_FLEX') THEN
        l_return_status := FALSE;
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_INVALID_DESC_FLEX');
        FND_MSG_PUB.ADD;
      END IF;
    END IF;

    gen_log_info('End of validate_parameters.Validation 13');
    gen_log_info('END OF FUNCTION VALIDATE_PARAMETERS');
    return (l_return_status) ;
  END validate_parameters;


  FUNCTION derive_unit_outcome_data (
                                     p_lgcy_suo_rec                 IN OUT NOCOPY  LGCY_SUO_REC_TYPE                                        ,
                                     p_person_id                    IN OUT NOCOPY  IGS_PE_PERSON.PERSON_ID%TYPE                             ,
                                     p_cal_type		            IN OUT NOCOPY  IGS_CA_INST.CAL_TYPE%TYPE                                ,
                                     p_sequence_number	            IN OUT NOCOPY  IGS_CA_INST.SEQUENCE_NUMBER%TYPE                         ,
                                     p_start_dt		            OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.CI_START_DT%TYPE                  ,
                                     p_end_dt		            OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.CI_END_DT%TYPE                    ,
				     p_unit_attempt_status          OUT    NOCOPY  IGS_EN_SU_ATTEMPT_ALL.UNIT_ATTEMPT_STATUS%TYPE           ,
                                     p_translated_grading_schema_cd OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_GRADING_SCHEMA_CD%TYPE ,
                                     p_translated_version_number    OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_VERSION_NUMBER%TYPE    ,
                                     p_translated_grade		    OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_GRADE%TYPE             ,
                                     p_translated_dt		    OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_DT%TYPE		    ,
                                     p_number_of_times		    OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.NUMBER_TIMES_KEYED%TYPE,
                                     p_uoo_id                       OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.UOO_ID%TYPE,
                                     p_release_date                 OUT    NOCOPY  IGS_AS_SU_STMPTOUT_ALL.RELEASE_DATE%TYPE
				   )
  RETURN BOOLEAN
 /*************************************************************************************************************************
  ||Created By : Aiyer
  || Date Created on : 2002/11/20
  || Purpose :  The function derive_unit_outcome_data derives the value for the following parameters: -
  ||             1. Person_id from person_number
  ||             2. Calendar type, calendar sequence number, calendar Start and End date  from calendar alternate code
  ||	         3. Derive the unit attempt status for the student unit attempt
  ||             4. Translated Grading schema code, Translated version number, Translated grade and Translated date
  ||             5. Derive the grading schems code and version number from the grade.
  ||             6. Derive the incomplete grading schema code and incomplete version number if they have not been specified.
  ||             7. Derive the release_date: If finalised_outcome_ind and outcome_dt is not null then release_date = outcome_dt
  ||                    else its NULL
  ||           It is called by the procedure create_unit_outcome
  ||  Know limitations, enhancements or remarks
  ||  Change History
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
 ****************************************************************************************************************************/

  IS
  l_return_status    BOOLEAN DEFAULT TRUE;
  l_temp_status      VARCHAR2(20);
  BEGIN

     gen_log_info('START OF FUNCTION DERIVE_UNIT_OUTCOME_DATA');

    /*************************************** Validation 1 ******************************************/
     gen_log_info('Start of Validation 1');

     /*
        Derive the person_id out the person_number
     */

     p_person_id := IGS_GE_GEN_003.GET_PERSON_ID(p_lgcy_suo_rec.person_number);
     gen_log_info ('person_id : '||p_person_id);
     IF p_person_id IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
        FND_MSG_PUB.ADD;
        l_return_status := FALSE;
     END IF;

     gen_log_info('End of Validation 1');

    /************************************** Validation 2 *******************************************/
     gen_log_info('Start of Validation 2');

     /*
        Derive the cal_type and sequence_number, start_dt and end_dt from the alternate code
     */

     IGS_GE_GEN_003.GET_CALENDAR_INSTANCE
                      (
                        p_alternate_cd       => p_lgcy_suo_rec.teach_cal_alt_code,
                        p_s_cal_category     => '''TEACHING''',
                        p_cal_type           => p_cal_type,
                        p_ci_sequence_number => p_sequence_number,
                        p_start_dt           => p_start_dt,
                        p_end_dt             => p_end_dt,
                        p_return_status      => l_temp_status
                      );

       gen_log_info('cal type, sequence number,start_dt,end dt : '||p_cal_type||p_sequence_number||p_start_dt||p_end_dt);

       IF p_cal_type  IS NULL OR p_sequence_number IS NULL OR p_start_dt IS NULL  THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_INVALID_CAL_ALT_CODE');
          FND_MSG_PUB.ADD;
          l_return_status := FALSE;
       END IF;

     gen_log_info('End of Validation 2');

    /************************************** Validation 3 *******************************************/
     gen_log_info('Start of Validation 3');

    /*
      Derive the value for the out parameter p_unit_attempt_status
    */

    DECLARE
      CURSOR cur_get_unit_attempt_status
      IS
      SELECT
	    unit_attempt_status,
        uoo_id
      FROM
            igs_en_su_attempt_all su
      WHERE
            su.person_id          = p_person_id
      AND   su.course_cd          = p_lgcy_suo_rec.program_cd
      AND   su.unit_cd            = p_lgcy_suo_rec.unit_cd
      AND   su.cal_type           = p_cal_type
      AND   su.ci_sequence_number = p_sequence_number
      AND   su.location_cd        = p_lgcy_suo_rec.location_cd
      AND   su.unit_class         = p_lgcy_suo_rec.unit_class;

    BEGIN
       OPEN  cur_get_unit_attempt_status;
       FETCH cur_get_unit_attempt_status INTO p_unit_attempt_status,p_uoo_id;
       CLOSE cur_get_unit_attempt_status;
    END ;

     gen_log_info('End of Validation 3');


    /************************************** Validation 4 *******************************************/
     gen_log_info('Start of Validation 4');

     /*
       Derive the grading schema code and version number if these have been passed to this API as null as follows:
	 1.  IF  a record with a default grading schema code exists at the unit section level then: -
	       Validate that the grade passed to this API falls under this default grading schema (set up at the unit section level).
	            IF   such a record exists then default the value for the grading schema code and grading schema version number
		         in the record type to this grading schema code and version number and go to validation 4.
                    ELSE the situation indicates an invalid legacy grade entry,
		         set the error message IGS_AS_INVALID_GRADE to stack and go to validation 4,

	 2.  ELSIF a record with a default grading schema is set up at the unit level then: -
	         Validate that the grade passed to this API falls under this default grading schema (set up at the unit level).
	            IF   such a record exists then default the value for the grading schema code and grading schema version number
		         in the record type to this grading schema code and version number and go to validation 4.
                    ELSE the situation indicates an invalid legacy grade entry,
		         set the error message IGS_AS_INVALID_GRADE to stack and go to validation 4,

	 3. ELSE no set up for grading schema code has been done at both the unit and unit section level then set the error
	        message IGS_AS_GRDSCH_SETUP_NOT_EXIST to stack and go to validation 4.
     */

     IF p_lgcy_suo_rec.grading_schema_cd IS NULL OR p_lgcy_suo_rec.version_number IS NULL THEN

        DECLARE
          -- get the default grading schema cd and version number from the unit section level and the corresponding grade
          CURSOR cur_get_grd_schm_usec_lvl
	  IS
	  SELECT
	         ugs.grading_schema_code     ,
		 ugs.grd_schm_version_number
          FROM   igs_ps_usec_grd_schm    ugs ,
                 igs_en_su_attempt_all   en
          WHERE
                 ugs.default_flag          = 'Y'                           AND
       		     ugs.uoo_id                = en.uoo_id                     AND
                 en.person_id              = p_person_id                   AND
                 en.course_cd              = p_lgcy_suo_rec.program_cd     AND
                 en.unit_cd                = p_lgcy_suo_rec.unit_cd        AND
                 en.cal_type               = p_cal_type                    AND
                 en.ci_sequence_number     = p_sequence_number             AND
                 en.location_cd           =  p_lgcy_suo_rec.location_cd    AND
                 en.unit_class            =  p_lgcy_suo_rec.unit_class;


         -- get the default grading schema cd and version number from the unit level and the corresponding grade
         CURSOR cur_get_grd_schm_unit_lvl
	 IS
	 SELECT
	         ugs.grading_schema_code       ,
		 ugs.grd_schm_version_number
         FROM
                igs_ps_unit_grd_schm    ugs ,
		igs_en_su_attempt_all   en
	 WHERE
		ugs.default_flag          = 'Y'                        AND
		ugs.unit_code             = en.unit_cd                 AND
		ugs.unit_version_number   = en.version_number          AND
                en.person_id              = p_person_id                AND
                en.course_cd              = p_lgcy_suo_rec.program_cd  AND
                en.unit_cd                = p_lgcy_suo_rec.unit_cd     AND
                en.cal_type               = p_cal_type                 AND
                en.ci_sequence_number     = p_sequence_number   AND
                en.location_cd           =  p_lgcy_suo_rec.location_cd    AND
                en.unit_class            =  p_lgcy_suo_rec.unit_class;


          -- get the grade for the corresponding grading schem /version number at unitsection/unit level
         CURSOR  cur_get_grade (
	                          cp_grading_schema_cd IGS_AS_GRD_SCH_GRADE.GRADING_SCHEMA_CD%TYPE ,
	                          cp_version_number    IGS_AS_GRD_SCH_GRADE.VERSION_NUMBER%TYPE    ,
				  cp_grade             IGS_AS_GRD_SCH_GRADE.GRADE%TYPE
			       )
	 IS
	 SELECT
	         'X'
	 FROM
	         igs_as_grd_sch_grade
         WHERE
	         grading_schema_cd  =  cp_grading_schema_cd          AND
                 version_number     =  cp_version_number             AND
		 grade              =  cp_grade;

          rec_get_grd_schm_usec_lvl  CUR_GET_GRD_SCHM_USEC_LVL%ROWTYPE;
          rec_get_grd_schm_unit_lvl  CUR_GET_GRD_SCHM_UNIT_LVL%ROWTYPE;
	  l_exists                   VARCHAR2(1)                      ;

	BEGIN
          OPEN  cur_get_grd_schm_usec_lvl;
	  FETCH cur_get_grd_schm_usec_lvl INTO rec_get_grd_schm_usec_lvl;

	  IF cur_get_grd_schm_usec_lvl%FOUND THEN
             --A record with a default grading schema code exists at the unit section level


	     -- check whether the grade passed to this API matches with the grade for the default grading schema
	     -- set up at the unit section level.
	     OPEN  cur_get_grade ( cp_grading_schema_cd => rec_get_grd_schm_usec_lvl.grading_schema_code     ,
                                   cp_version_number    => rec_get_grd_schm_usec_lvl.grd_schm_version_number ,
				   cp_grade             => p_lgcy_suo_rec.grade
				 );
             FETCH cur_get_grade INTO l_exists;

             IF cur_get_grade%NOTFOUND THEN
	        -- Situation indicates an invalid legacy grade entry
		-- set the error message IGS_AS_INVALID_GRADE to stack and go to validation 4
                FND_MESSAGE.SET_NAME ('IGS','IGS_AS_INVALID_GRADE');
                FND_MSG_PUB.ADD;
                l_return_status := FALSE;
	     ELSE
	          -- both the grades are equal.
		  -- Default the record type grading schema code and version number to the grading schema and version number
		  -- at the unit section level
		  p_lgcy_suo_rec.grading_schema_cd := rec_get_grd_schm_usec_lvl.grading_schema_code     ;
                  p_lgcy_suo_rec.version_number    := rec_get_grd_schm_usec_lvl.grd_schm_version_number ;
 	     END IF;

             CLOSE cur_get_grade;

          ELSE
 	     -- A record with a default grading schema does not exist at the unit Section level
             OPEN  cur_get_grd_schm_unit_lvl;
             FETCH cur_get_grd_schm_unit_lvl INTO rec_get_grd_schm_unit_lvl;

             --check whether such a setup exists at the unit level.
	     IF cur_get_grd_schm_unit_lvl%FOUND THEN
                -- A record with a default grading schema code exists at the unit level
                -- check whether the grade passed to this API matches with the grade for the default grading schema
                -- set up at the unit level.
                OPEN cur_get_grade (
                                      cp_grading_schema_cd => rec_get_grd_schm_unit_lvl.grading_schema_code     ,
                                      cp_version_number    => rec_get_grd_schm_unit_lvl.grd_schm_version_number ,
		                      cp_grade             => p_lgcy_suo_rec.grade
				    );
                FETCH cur_get_grade INTO l_exists;

                IF cur_get_grade%NOTFOUND THEN
                   -- Situation indicates an invalid legacy grade entry
                   -- set the error message IGS_AS_INVALID_GRADE to stack and go to validation 4
                   FND_MESSAGE.SET_NAME ('IGS','IGS_AS_INVALID_GRADE');
                   FND_MSG_PUB.ADD;
                   l_return_status := FALSE;
	        ELSE
                   -- both the grades are equal.
                   -- Default the record type grading schema code and version number to the grading schema and version number
                   -- at the unit section level
                   p_lgcy_suo_rec.grading_schema_cd := rec_get_grd_schm_unit_lvl.grading_schema_code     ;
                   p_lgcy_suo_rec.version_number    := rec_get_grd_schm_unit_lvl.grd_schm_version_number ;
		END IF;

                CLOSE cur_get_grade;
             ELSE
                --A Grading schema setup does not exist at the unit section level and the unit level
	        FND_MESSAGE.SET_NAME ('IGS','IGS_AS_GRDSCH_SETUP_NOT_EXIST');
	        FND_MSG_PUB.ADD;
                l_return_status := FALSE;
             END IF;
             CLOSE cur_get_grd_schm_unit_lvl;
          END IF;
	  CLOSE cur_get_grd_schm_usec_lvl;

	END; -- end of local block.

     END IF;

     gen_log_info('End of Validation 4');

    /************************************** Validation 4 *******************************************/
     gen_log_info('Start of Validation 5');

     IF p_lgcy_suo_rec.s_grade_creation_method_type IS NULL THEN
        -- set the value of grade creation method type to 'CONVERSION' in case it is passed as null to create_unit_outcome
        p_lgcy_suo_rec.s_grade_creation_method_type := 'CONVERSION';
     END IF;
     gen_log_info('End of Validation 5');

    /************************************** Validation 6 *******************************************/
     gen_log_info('Start of Validation 6');

     IF p_lgcy_suo_rec.finalised_outcome_ind IS NULL THEN
        -- set the value of finalised outcome Indicator to 'Y' in case it is passed as null to create_unit_outcome
        p_lgcy_suo_rec.finalised_outcome_ind := 'Y';
     END IF;

     gen_log_info('End of Validation 6');

    /************************************** Validation 7*******************************************/
     gen_log_info('Start of Validation 7');

      /*
        The incomp_grading schema/version only need to be defaulted ( if these are passed with null values to the api )
	if a grade with a result type of incomplete grade has been specified, for the grading_schema and version
	number otherwise these would remain null.
      */
        IF p_lgcy_suo_rec.incomp_grading_schema_cd IS NULL OR p_lgcy_suo_rec.incomp_version_number IS NULL THEN

           DECLARE
             CURSOR cur_incomp_grade_exists
	     IS
	     SELECT
	            'X'
             FROM
                    igs_as_grd_sch_grade ggs
	     WHERE
                    grading_schema_cd = p_lgcy_suo_rec.grading_schema_cd  AND
                    version_number    = p_lgcy_suo_rec.version_number     AND
                    s_result_type     = 'INCOMP';

             lv_exists  VARCHAR2(1);
	   BEGIN
	     OPEN   cur_incomp_grade_exists;
	     FETCH  cur_incomp_grade_exists INTO lv_exists;
	     IF cur_incomp_grade_exists%FOUND THEN
	        -- If an incomplete grade exists then default the incomplete grading schema code and version number
		-- to the grading schema code and version number of the record type passed
		-- ELSE they would remain as NULLS
	        p_lgcy_suo_rec.incomp_grading_schema_cd :=  p_lgcy_suo_rec.grading_schema_cd  ;
		p_lgcy_suo_rec.incomp_version_number    :=  p_lgcy_suo_rec.version_number     ;
	     END IF;
	     CLOSE  cur_incomp_grade_exists;

	   END;

	END IF;

     gen_log_info('End of Validation 7');

    /************************************** Validation 8*******************************************/
     gen_log_info('Start of Validation 8');

     /*
        Set the value for the out parameter p_number_of_times to 1.
     */

      p_number_of_times := 1;

     gen_log_info('End of Validation 8');
    /************************************** Validation 9*******************************************/
     gen_log_info('Start of Validation 9');

    /*
       If the record parameter Finalised_Outcome_Ind is set to 'Y' then derive the value for p_translated_grading_schema_cd,
       p_translated_version_number, p_translated_grade, p_translated_dt from the fields person_id, program_cd,
       unit_cd, cal_type, sequence_number, grading_schema_cd, version_number, grade and mark.
    */

    IF p_lgcy_suo_rec.finalised_outcome_ind = 'Y'  THEN
       DECLARE
         -- If the grading schema precedence number is set to N at the unit section level then
         -- retrieve the grading schema code and version number set at the program offering pattern level
         -- for the corresponding student unit attempt.
         CURSOR cur_cop (
                          cp_acad_cal_type          IGS_PS_OFR_PAT.CAL_TYPE%TYPE         ,
                          cp_acad_ci_seq_num        IGS_PS_OFR_PAT.CI_SEQUENCE_NUMBER%TYPE
		        )
         IS
         SELECT
                 cop.grading_schema_cd,
                 cop.gs_version_number
         FROM
                 igs_en_su_attempt        sua,
                 igs_en_stdnt_ps_att      sca,
                 igs_ps_unit_ofr_opt      uoo,
                 igs_ps_ofr_pat           cop
         WHERE
                 sua.person_id                     = p_person_id
         AND     sua.course_cd                     = p_lgcy_suo_rec.program_cd
         AND     sua.unit_cd                       = p_lgcy_suo_rec.unit_cd
         AND     sua.cal_type                      = p_cal_type
         AND     sua.ci_sequence_number            = p_sequence_number
         AND     sua.location_cd                   =  p_lgcy_suo_rec.location_cd
         AND     sua.unit_class                    =  p_lgcy_suo_rec.unit_class
         AND     uoo.uoo_id                        = sua.uoo_id
         AND     uoo.grading_schema_prcdnce_ind    = 'N'
         AND     sca.person_id                     = sua.person_id
         AND     sca.course_cd                     = sua.course_cd
         AND     cop.coo_id                        = sca.coo_id
         AND     cop.cal_type                      = cp_acad_cal_type
         AND     cop.ci_sequence_number            = cp_acad_ci_seq_num
         AND     cop.grading_schema_cd            is not null
         AND     cop.gs_version_number            is not null;

       -- get the to grade for the grading schema and to grading schema (set at the unit section/unit
       -- level and the program offering pattern level.
       CURSOR cur_gsgt(
                        cp_grading_schema_cd        IGS_PS_OFR_PAT.GRADING_SCHEMA_CD%TYPE,
                        cp_gs_ver_num               IGS_PS_OFR_PAT.GS_VERSION_NUMBER%TYPE
    		     )
       IS
       SELECT
               gsgt.to_grade
       FROM
                 igs_as_grd_sch_trn        gsgt
       WHERE
               gsgt.grading_schema_cd              = p_lgcy_suo_rec.grading_schema_cd
       AND     gsgt.version_number                 = p_lgcy_suo_rec.version_number
       AND     gsgt.grade                          = p_lgcy_suo_rec.grade
       AND     gsgt.to_grading_schema_cd           = cp_grading_schema_cd
       AND     gsgt.to_version_number              = cp_gs_ver_num;

       rec_cur_cop                     CUR_COP%ROWTYPE                      ;
       l_grade                         IGS_AS_GRD_SCH_TRN.TO_GRADE%TYPE     ;
       l_alt_code                      IGS_CA_INST.ALTERNATE_CODE%TYPE      ;
       l_acad_cal_type                 IGS_CA_INST.CAL_TYPE%TYPE            ;
       l_acad_ci_sequence_number       IGS_CA_INST.SEQUENCE_NUMBER%TYPE     ;
       l_acad_ci_start_dt              IGS_CA_INST.START_DT%TYPE            ;
       l_acad_ci_end_dt                IGS_CA_INST.END_DT%TYPE              ;
       l_message_name                  VARCHAR2(1000)                       ;

    BEGIN

       l_alt_code :=  IGS_EN_GEN_002.enrp_get_acad_alt_cd (
                                                             P_CAL_TYPE                => p_cal_type                 ,
                                                             P_CI_SEQUENCE_NUMBER      => p_sequence_number          ,
                                                             P_ACAD_CAL_TYPE           => l_acad_cal_type            ,
                                                             P_ACAD_CI_SEQUENCE_NUMBER => l_acad_ci_sequence_number  ,
                                                             P_ACAD_CI_START_DT        => l_acad_ci_start_dt         ,
                                                             P_ACAD_CI_END_DT          => l_acad_ci_end_dt           ,
                                                             P_MESSAGE_NAME            => l_message_name
  				                       );

       IF l_message_name IS NOT NULL THEN
          FND_MESSAGE.SET_NAME('IGS', l_message_name);
          FND_MSG_PUB.ADD;
          l_return_status := FALSE;
       ELSE
          OPEN cur_cop(
                       l_acad_cal_type           ,
                       l_acad_ci_sequence_number
	            );
          FETCH cur_cop INTO rec_cur_cop;

          IF cur_cop%FOUND THEN
             --Validate that their exists a grade mapping.
             OPEN cur_gsgt(
                            rec_cur_cop.grading_schema_cd,
                            rec_cur_cop.gs_version_number
                           );
             FETCH cur_gsgt INTO l_grade;
             IF cur_gsgt%FOUND THEN
               -- Set the fields to the new translation.
               p_translated_grading_schema_cd := rec_cur_cop.grading_schema_cd ;
               p_translated_version_number    := rec_cur_cop.gs_version_number ;
               p_translated_grade             := l_grade                       ;
	       p_translated_dt                := SYSDATE                       ;
             END IF; -- end of innermost if
             CLOSE cur_gsgt;
          END IF; -- end of outer if
          CLOSE cur_cop;
        END IF; -- end of outermost if
      END ;
    END IF;
    gen_log_info('End of Validation 9');
    /************************************** Validation 10*******************************************/
    gen_log_info('Start of Validation 10');
     IF p_lgcy_suo_rec.finalised_outcome_ind = 'Y' AND p_lgcy_suo_rec.outcome_dt IS NOT NULL THEN
        p_release_date := p_lgcy_suo_rec.outcome_dt;
     ELSE
        p_release_date := NULL;
     END IF;
    gen_log_info('End of Validation 10');

    return l_return_status;

    gen_log_info('END OF FUNCTION DERIVE_UNIT_OUTCOME_DATA');

  END derive_unit_outcome_data;

 FUNCTION validate_suao_db_cons (
                                     p_person_id                    IN         IGS_PE_PERSON.PERSON_ID%TYPE                              ,
				     p_lgcy_suo_rec                 IN         LGCY_SUO_REC_TYPE                                         ,
				     p_cal_type                     IN         IGS_CA_INST.CAL_TYPE%TYPE                                 ,
				     p_sequence_number              IN         IGS_CA_INST.SEQUENCE_NUMBER%TYPE                          ,
				     p_translated_version_number    IN         IGS_AS_SU_STMPTOUT_ALL.TRANSLATED_VERSION_NUMBER%TYPE     ,
				     x_return_status                OUT NOCOPY VARCHAR2,
                     p_uoo_id                       IN         IGS_AS_SU_STMPTOUT_ALL.UOO_ID%TYPE
				)
 RETURN BOOLEAN

 /******************************************************************************************************
  ||Created By : Aiyer
  ||Date Created on : 2002/11/20
  ||Purpose :  This function performs all data integrity validations on the table igs_as_su_stmptout_all
  ||           It is called from the procedure create_unit_outcome.
  ||Know limitations, enhancements or remarks
  ||Change History
  ||Who             When            What
  ||(reverse chronological order - newest change first)
  *******************************************************************************************************/

  IS
  l_return_status    BOOLEAN DEFAULT TRUE;

 BEGIN

   -- Initialise X_return_status to 'S' i.e success.
   x_return_status := 'S';

    /*************************************** Validation 1 ******************************************/
     gen_log_info('Start of Validation 1');
     /*
       Validate that the primary key does not already exist.
       if exists then give warning and return
     */
       IF  Igs_as_su_stmptout_pkg.get_pk_for_validation (
                                                              X_PERSON_ID                =>  p_person_id                        ,
                                                              X_COURSE_CD                =>  p_lgcy_suo_rec.program_cd          ,
                                                              X_UOO_ID                  =>   p_uoo_id                     ,
                                                              X_OUTCOME_DT               =>  p_lgcy_suo_rec.outcome_dt	        ,
                                                              X_GRADING_PERIOD_CD        =>  p_lgcy_suo_rec.grading_period_cd
	  				                ) THEN
          /*
            Primary key already exists.
            Set an warning message to stack and set x_return_status to 'W'
	    and return FALSE
          */

          FND_MESSAGE.SET_NAME ('IGS','IGS_AS_UTOTCM_ALREADY_EXISTS');
	  FND_MSG_PUB.ADD;
	  x_return_status := 'W';
	  l_return_status := FALSE;
	  RETURN l_return_status;
        END IF;

     gen_log_info('End of Validation 1');


    /*************************************** Validation 2 ******************************************/
     gen_log_info('Start of Validation 2');
     /*
        Check whether foreign key with table igs_en_su_attempt_all exists.
     */

     IF NOT igs_en_su_attempt_pkg.get_pk_for_validation (
                                                           X_PERSON_ID               =>  p_person_id                  ,
                                                           X_COURSE_CD               =>  p_lgcy_suo_rec.program_cd    ,
                                                           X_UOO_ID                 =>   p_uoo_id
						    )
     THEN
          /*
            Foreign key with the table igs_en_su_attempt_all does not exists.
            Set an error message to stack and set x_return_status to 'E' and proceed
	    to the next step
          */

          FND_MESSAGE.SET_NAME ('IGS','IGS_AS_STD_ENRL_NOT_EXISTS');
	  FND_MSG_PUB.ADD;
	  x_return_status := 'E';
	  l_return_status := FALSE;
      END IF;

     gen_log_info('End of Validation 2');

    /*************************************** Validation 3 ******************************************/
     gen_log_info('Start of Validation 3');

     /*
        Check whether foreign key with table igs_as_grd_sch_grade exists.
     */

     IF NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (
                                                             X_GRADING_SCHEMA_CD    =>  p_lgcy_suo_rec.grading_schema_cd    ,
                                                             X_VERSION_NUMBER       =>  p_lgcy_suo_rec.version_number       ,
                                                             X_GRADE                =>  p_lgcy_suo_rec.grade
							   )
     THEN
          /*
            Foreign key with the table igs_as_grd_sch_grade does not exists.
            Set an error message to stack and set x_return_status to 'E' and proceed
	    to the next step
          */

          FND_MESSAGE.SET_NAME ('IGS','IGS_AS_GRD_SCH_NOT_EXISTS');
	  FND_MSG_PUB.ADD;
	  x_return_status := 'E';
	  l_return_status := FALSE;

     END IF;

     gen_log_info('End of Validation 3');

    /*************************************** Validation 4 ******************************************/

     gen_log_info('Start of Validation 4');
     /*
        Validate that the parameter s_grade_creation_method_type should have one of the following values as
	CONVERSION', 'KEYED','UPLOAD'.
     */
      IF p_lgcy_suo_rec.s_grade_creation_method_type <> 'CONVERSION' AND
         p_lgcy_suo_rec.s_grade_creation_method_type <> 'KEYED'      AND
	 p_lgcy_suo_rec.s_grade_creation_method_type <> 'UPLOAD'
      THEN
          FND_MESSAGE.SET_NAME ('IGS','IGS_AS_GRD_CRTMTH_INVALID');
	  FND_MSG_PUB.ADD;
	  x_return_status := 'E';
	  l_return_status := FALSE;
      END IF;

     gen_log_info('End of Validation 4');

    /*************************************** Validation 5 ******************************************/

     gen_log_info('Start of Validation 5');
     /*
        Check that Version Number should be between 0 and 999.
     */
     DECLARE
     l_msg_count  NUMBER        ;

     BEGIN
     /*
        Call the function igs_as_su_stmptout_pkg.check_constraint to check for the version number between 0 and 999
        this function raises an exception if it finds an invalid value.
        trap this exception in the when others block of the exception handler , remove the invalid_value message added by this function
        and add the customised message.
     */

     igs_as_su_stmptout_pkg.check_constraints ( column_name   => 'VERSION_NUMBER'                 ,
                                                column_value  => p_lgcy_suo_rec.version_number
					      );

     EXCEPTION
       WHEN OTHERS THEN
         l_msg_count := FND_MSG_PUB.COUNT_MSG;
         -- Delete the message 'IGS_GE_INVALID_VALUE'
         FND_MSG_PUB.DELETE_MSG (l_msg_count);
         -- set the customized message
         FND_MESSAGE.Set_Name('IGS','IGS_AS_GRD_VERSION_BET_0_999');
         FND_MSG_PUB.Add;
         x_return_status := 'E';
         l_return_status := FALSE;
     END ;
     gen_log_info('End of Validation 5');

    /*************************************** Validation 6 ******************************************/
     gen_log_info('Start of Validation 6');
    /*
      Check Mark between 0 to 999
     */
     DECLARE
     l_msg_count  NUMBER        ;

     BEGIN
       /*
          Call the function igs_as_su_stmptout_pkg.check_constraint to check for the mark is between 0 and 999.
          This function raises an exception if it finds an invalid value.
          Trap this exception in the when others block of the exception handler , remove the invalid_value message added by this function
          and add the customised message.
       */

       igs_as_su_stmptout_pkg.check_constraints ( column_name   => 'MARK'                 ,
                                                  column_value  => p_lgcy_suo_rec.mark
					        );

     EXCEPTION
       WHEN OTHERS THEN
         l_msg_count := FND_MSG_PUB.COUNT_MSG;
         -- Delete the message 'IGS_GE_INVALID_VALUE'
         FND_MSG_PUB.DELETE_MSG (l_msg_count);
         -- set the customized message
         FND_MESSAGE.Set_Name('IGS','IGS_EN_MARK_INV');
         FND_MSG_PUB.Add;
         x_return_status := 'E';
         l_return_status := FALSE;
     END ;

     gen_log_info('End of Validation 6');

    /*************************************** Validation 7 ******************************************/
     gen_log_info('Start of Validation 7');

     /*
        Check that FINALISED_OUTCOME_IND can have values only as 'Y' or 'N'.
     */
     DECLARE
     l_msg_count  NUMBER        ;

     BEGIN
     /*
        Call the function igs_as_su_stmptout_pkg.check_constraint to check that the FINALISED_OUTCOME_IND can have values only as
	'Y' or 'N'.
        This function raises an exception if it finds an invalid value.
        Trap this exception in the when others block of the exception handler , remove the invalid_value message added by this function
        and add the customised message.
     */

     igs_as_su_stmptout_pkg.check_constraints ( column_name   => 'FINALISED_OUTCOME_IND'                 ,
                                                column_value  => p_lgcy_suo_rec.finalised_outcome_ind
					      );

     EXCEPTION
       WHEN OTHERS THEN
         l_msg_count := FND_MSG_PUB.COUNT_MSG;
         -- Delete the message 'IGS_GE_INVALID_VALUE'
         FND_MSG_PUB.DELETE_MSG (l_msg_count);
         -- set the customized message
         FND_MESSAGE.Set_Name('IGS','IGS_AS_FNL_OTCN_IND_Y_N');
         FND_MSG_PUB.Add;
         x_return_status := 'E';
	 l_return_status := FALSE;
     END ;

     gen_log_info('End of Validation 7');

    /*************************************** Validation 8 ******************************************/
     gen_log_info('Start of Validation 8');
    /*
        Check that ci_sequence_number can have values only between 0 and 999999
     */
     DECLARE
     l_msg_count  NUMBER        ;

     BEGIN
     /*
        Call the function igs_as_su_stmptout_pkg.check_constraint to check that ci_sequence_number
	can have values only between 0 and 999999.
        This function raises an exception if it finds an invalid value.
        Trap this exception in the when others block of the exception handler , remove the invalid_value message added by this function
        and add the customised message.
     */

     igs_as_su_stmptout_pkg.check_constraints ( column_name   => 'CI_SEQUENCE_NUMBER'                 ,
                                                column_value  => p_sequence_number
					      );

     EXCEPTION
       WHEN OTHERS THEN
         l_msg_count := FND_MSG_PUB.COUNT_MSG;
         -- Delete the message 'IGS_GE_INVALID_VALUE'
         FND_MSG_PUB.DELETE_MSG (l_msg_count);
         -- set the customized message
         FND_MESSAGE.Set_Name('IGS','IGS_AS_SEQ_NUM_BET_0_999999');
         FND_MSG_PUB.Add;
         x_return_status := 'E';
	 l_return_status := FALSE;
     END ;

     gen_log_info('End of Validation 8');

    /*************************************** Validation 9 ******************************************/
     gen_log_info('Start of Validation 9');
     /*
       Check that the translated_version_number can have values only between 0 and 999
     */
     DECLARE
     l_msg_count  NUMBER        ;

     BEGIN
       /*
         Call the function igs_as_su_stmptout_pkg.check_constraint to check that the translated_version_number can
	 have values only between 0 and 999.
         This function raises an exception if it finds an invalid value.
         Trap this exception in the when others block of the exception handler , remove the invalid_value message added by this function
         and add the customised message.
       */

       igs_as_su_stmptout_pkg.check_constraints ( column_name   => 'TRANSLATED_VERSION_NUMBER' ,
                                                  column_value  =>  p_translated_version_number
					        );

     EXCEPTION
       WHEN OTHERS THEN
         l_msg_count := FND_MSG_PUB.COUNT_MSG;
         -- Delete the message 'IGS_GE_INVALID_VALUE'
         FND_MSG_PUB.DELETE_MSG (l_msg_count);

         -- set the customized message
         FND_MESSAGE.Set_Name('IGS','IGS_AS_TRN_VERSION_BET_0_999');
         FND_MSG_PUB.Add;
         x_return_status := 'E';
	 l_return_status := FALSE;
     END ;

     gen_log_info('End of Validation 9');

     gen_log_info('End of function validate_suao_db_cons');

     return ( l_return_status );

  END validate_suao_db_cons;

FUNCTION validate_unit_outcome (
                                  p_lgcy_suo_rec         LGCY_SUO_REC_TYPE                               ,
				  p_unit_attempt_status  IGS_EN_SU_ATTEMPT_ALL.UNIT_ATTEMPT_STATUS%TYPE
			       )

/************************************************************************************************************************
  ||Created By : Aiyer
  ||Date Created on : 2002/11/26
  ||Purpose :  The function validate_unit_outcome validates all the business validations before entering a record in the
  ||           table IGS_AS_SU_STMPT_OUT_ALL.
  ||           Called from the procedure create_unit_outcome
  ||Know limitations, enhancements or remarks
  ||Change History
  ||Who             When            What
  ||(reverse chronological order - newest change first)
  ||Aiyer           09-Jan-2003    Code fix for the bug 2741946.
  ||                               Removed the check to validate mark against grade and grading schema.
 *************************************************************************************************************************/
RETURN BOOLEAN

IS
  l_return_status BOOLEAN DEFAULT TRUE;
BEGIN

  gen_log_info (p_msg => ' Start of function validate_unit_outcome function ');

  /************************* Validation 1 ********************************/
  /*
    IF unit attempt_status (derived in derive_unit_outcome_data function) is niether 'ENROLLED' nor 'COMPLETED'
    then do not allow student unit attempt outcome to be graded.
    set an error message to stack
  */

  gen_log_info (p_msg => ' Start of validation 1 ');

  -- Check whether unit_attempt_status is niether in ENROLLED nor COMPLETED.

  IF p_unit_attempt_status <> 'ENROLLED' AND p_unit_attempt_status <> 'COMPLETED' THEN
     -- Validation unsuccessful as the unit_attempt_status is not in  ENROLLED or COMPLETED.
     -- set an error message to stack and return FALSE.
     FND_MESSAGE.SET_NAME('IGS', 'IGS_AS_CANT_GRD_UNT_INV_STAT');
     FND_MSG_PUB.ADD;
     l_return_status := FALSE;
  END IF;

  gen_log_info (p_msg => ' End of validation 1 ');

-- Return TRUE , Validation  successful

 gen_log_info (p_msg => ' End of function validate_unit_outcome function ');

 return l_return_status;

END validate_unit_outcome;

PROCEDURE create_post_unit_outcome (
                                    p_person_id            IGS_PE_PERSON.PERSON_ID%TYPE                       ,
				    p_cal_type             IGS_CA_INST.CAL_TYPE%TYPE                          ,
				    p_sequence_number      IGS_CA_INST.SEQUENCE_NUMBER%TYPE                   ,
                                    p_unit_attempt_status  IGS_EN_SU_ATTEMPT_ALL.UNIT_ATTEMPT_STATUS%TYPE     ,
                                    p_lgcy_suo_rec         LGCY_SUO_REC_TYPE
                               )
/************************************************************************************************************************
  ||Created By : Aiyer
  ||Date Created on : 2002/11/26
  ||Purpose :  The procedure create_post_unit_outcome performs post insert operations on the table IGS_AS_SU_STMPTOUT_ALL
  ||           Called from the procedure create_unit_outcome
  ||
  ||Know limitations, enhancements or remarks
  ||Change History
  ||Who             When            What
  ||(reverse chronological order - newest change first)
 *************************************************************************************************************************/

IS

BEGIN

  gen_log_info('Start of PROCEDURE CREATE_POST_UNIT_OUTCOME');

  /*************************************** Validation 1 ******************************************/

  gen_log_info('Start of Create_post_unit_outcome.Validation 1');

  IF p_lgcy_suo_rec.finalised_outcome_ind = 'Y' AND p_unit_attempt_status = 'ENROLLED' THEN

    -- update the table igs_en_su_attempt_all to the unit_attempt_status of 'COMPLETED'
    UPDATE
           IGS_EN_SU_ATTEMPT_ALL su
    SET
           unit_attempt_status = 'COMPLETED'
    WHERE
           su.person_id          = p_person_id
    AND    su.course_cd          = p_lgcy_suo_rec.program_cd
    AND    su.unit_cd            = p_lgcy_suo_rec.unit_cd
    AND    su.cal_type           = p_cal_type
    AND    su.ci_sequence_number = p_sequence_number
    AND    su.location_cd        = p_lgcy_suo_rec.location_cd
    AND    su.unit_class         = p_lgcy_suo_rec.unit_class;

  END IF;

  gen_log_info('End of create_post_unit_outcome.validation 1');

  gen_log_info('END of PROCEDURE CREATE_POST_UNIT_OUTCOME');

  return;

END create_post_unit_outcome;


END igs_as_suao_lgcy_pub;

/
