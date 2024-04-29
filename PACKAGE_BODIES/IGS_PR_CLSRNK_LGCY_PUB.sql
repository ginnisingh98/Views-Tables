--------------------------------------------------------
--  DDL for Package Body IGS_PR_CLSRNK_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_CLSRNK_LGCY_PUB" AS
/* $Header: IGSPPR2B.pls 115.2 2002/11/29 07:51:54 smanglm noship $ */


G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGS_PR_CLSRNK_LGCY_PUB';

PROCEDURE initialise ( p_lgcy_clsrnk_rec IN OUT NOCOPY lgcy_clsrnk_rec_type )
IS
BEGIN
        p_lgcy_clsrnk_rec.person_number           := NULL;
        p_lgcy_clsrnk_rec.program_cd              := NULL;
        p_lgcy_clsrnk_rec.cohort_name             := NULL;
        p_lgcy_clsrnk_rec.calendar_alternate_code := NULL;
        p_lgcy_clsrnk_rec.cohort_rank             := NULL;
        p_lgcy_clsrnk_rec.cohort_override_rank    := NULL;
        p_lgcy_clsrnk_rec.comments                := NULL;
        p_lgcy_clsrnk_rec.as_of_rank_gpa          := NULL;

END initialise;

-- forward declaration of procedure/function used in this package

/*
  validate_parameters function checks all the mandatory parameters
  for the passed record type are not null
*/
FUNCTION validate_parameters
         (
           p_lgcy_clsrnk_rec   IN lgcy_clsrnk_rec_type
         )
RETURN BOOLEAN;

/*
  derive_level_data procedure derives advanced standing unit level data like: -
  1. Derive Person_id from person_number .
  2. Derive cal_type and sequence_number from cal_alt_code
*/

PROCEDURE derive_clsrnk_data
         (
           p_lgcy_clsrnk_rec           IN          lgcy_clsrnk_rec_type,
           p_person_id                 OUT NOCOPY  igs_pe_person.person_id%type,
           p_cal_type                  OUT NOCOPY  igs_ca_inst.cal_type%type,
           p_sequence_number           OUT NOCOPY  igs_ca_inst.sequence_number%type
         );

/*
  validate_db_cons function performs all the data integrity validation
*/
FUNCTION validate_db_cons
         (
           p_person_id          IN  igs_pe_person.person_id%type,
           p_cal_type           IN  igs_ca_inst.cal_type%type,
           p_sequence_number    IN  igs_ca_inst.sequence_number%type,
           p_lgcy_clsrnk_rec    IN  lgcy_clsrnk_rec_type
         )
RETURN VARCHAR2;




/*===================================================================+
 | PROCEDURE                                                         |
 |              create_class_rank                                    |
 |                                                                   |
 | DESCRIPTION                                                       |
 |              Creates Class Rank                                   |
 |                                                                   |
 | SCOPE - PUBLIC                                                    |
 |                                                                   |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                           |
 |                                                                   |
 | ARGUMENTS  : IN:                                                  |
 |                    p_api_version                                  |
 |                    p_init_msg_list                                |
 |                    p_commit                                       |
 |                    p_lgcy_clsrnk_rec                              |
 |              OUT:                                                 |
 |                    x_return_status                                |
 |                    x_msg_count                                    |
 |                    x_msg_data                                     |
 |          IN/ OUT:                                                 |
 |                                                                   |
 | RETURNS    : NONE                                                 |
 |                                                                   |
 | NOTES                                                             |
 |                                                                   |
 | MODIFICATION HISTORY                                              |
 |    smanglm   11-11-2002  Created                                  |
 +===================================================================*/


  PROCEDURE create_class_rank
            (p_api_version                 IN NUMBER,
	     p_init_msg_list               IN VARCHAR2 ,
	     p_commit                      IN VARCHAR2 ,
	     p_validation_level            IN VARCHAR2 ,
	     p_lgcy_clsrnk_rec             IN lgcy_clsrnk_rec_type,
	     x_return_status               OUT NOCOPY VARCHAR2,
	     x_msg_count                   OUT NOCOPY NUMBER,
	     x_msg_data                    OUT NOCOPY VARCHAR2
	    )
  IS
        l_api_name              CONSTANT VARCHAR2(30)  := 'create_class_rank';
        l_api_version           CONSTANT  NUMBER       := 1.0;

        -- variables declared to fetch data from derive_clsrnk_data
        l_person_id                 igs_pe_person.person_id%type;
        l_cal_type                  igs_ca_inst.cal_type%type;
        l_sequence_number           igs_ca_inst.sequence_number%type;

	l_return      VARCHAR2(1) ;

  BEGIN  -- main begin
  --Standard start of API savepoint
        SAVEPOINT create_class_rank;

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


  -- main code logic begins
        /*
          validate the parameters
        */
        IF NOT validate_parameters
                   (
		      p_lgcy_clsrnk_rec => p_lgcy_clsrnk_rec
		   ) THEN
	    RAISE FND_API.G_EXC_ERROR;
        END IF;
        /*
          derive the necessary data,
	  if this proc raised any error, exception
	  will be handled in the exception block directly
	  i.e. it will not proceed beyond derive_clsrnk_data
        */
        derive_clsrnk_data
                 (
                   p_lgcy_clsrnk_rec           => p_lgcy_clsrnk_rec,
                   p_person_id                 => l_person_id,
                   p_cal_type                  => l_cal_type,
                   p_sequence_number           => l_sequence_number
                 );
        /*
          validate db constraints
        */
        l_return := validate_db_cons
                 (
                   p_person_id          => l_person_id,
                   p_cal_type           => l_cal_type,
                   p_sequence_number    => l_sequence_number,
                   p_lgcy_clsrnk_rec    => p_lgcy_clsrnk_rec
                 );
        IF l_return = 'S' THEN
           /*
	      insert into igs_pr_cohinst_rank
	   */
           INSERT INTO IGS_PR_COHINST_RANK (
			PERSON_ID              ,
			COURSE_CD              ,
			COHORT_NAME            ,
			LOAD_CAL_TYPE          ,
			LOAD_CI_SEQUENCE_NUMBER,
			AS_OF_RANK_GPA         ,
			COHORT_RANK            ,
			COHORT_OVERRIDE_RANK   ,
			COMMENTS               ,
			CREATED_BY             ,
			CREATION_DATE          ,
			LAST_UPDATED_BY        ,
			LAST_UPDATE_DATE       ,
			LAST_UPDATE_LOGIN      ,
			REQUEST_ID             ,
			PROGRAM_APPLICATION_ID ,
			PROGRAM_ID             ,
			PROGRAM_UPDATE_DATE )
			VALUES (
                        l_person_id,
			p_lgcy_clsrnk_rec.program_cd,
			p_lgcy_clsrnk_rec.cohort_name,
			l_cal_type,
			l_sequence_number,
                        p_lgcy_clsrnk_rec.as_of_rank_gpa,
			p_lgcy_clsrnk_rec.cohort_rank,
			p_lgcy_clsrnk_rec.cohort_override_rank,
			p_lgcy_clsrnk_rec.comments,
			NVL(FND_GLOBAL.USER_ID,-1),
                        SYSDATE,
			NVL(FND_GLOBAL.USER_ID,-1),
			SYSDATE,
			NVL(FND_GLOBAL.LOGIN_ID,-1),
			DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
			DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
			DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
			DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE)
			);
	ELSE
	   x_return_status := l_return;
	END IF;
  --Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) AND l_return = 'S' THEN
                commit;
        END IF;

  --Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data  => x_msg_data);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_class_rank;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_class_rank;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
                ROLLBACK TO create_class_rank;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_UNHANDLED_ERROR');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

  END create_class_rank;


  FUNCTION validate_parameters
         (
           p_lgcy_clsrnk_rec   IN lgcy_clsrnk_rec_type
         )
  RETURN BOOLEAN
  /*************************************************************
  Created By : smanglm
  Date Created on : 2002/11/13
  Purpose : validate_parameters function checks all the mandatory
            parameters for the passed record type are not null
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  IS
     x_return_status  BOOLEAN;
  BEGIN
     x_return_status := TRUE;

     IF p_lgcy_clsrnk_rec.person_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_PER_NUM_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_clsrnk_rec.program_cd IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_PRGM_CD_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_clsrnk_rec.calendar_alternate_code IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_PR_CAL_ALT_CD_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_clsrnk_rec.cohort_rank IS NULL OR p_lgcy_clsrnk_rec.cohort_rank <=0 THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_PR_RANK_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_clsrnk_rec.cohort_name IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_PR_CHRT_NAME_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_clsrnk_rec.as_of_rank_gpa IS NULL OR p_lgcy_clsrnk_rec.as_of_rank_gpa < 0 THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_PR_GPA_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     IF p_lgcy_clsrnk_rec.cohort_override_rank IS NOT NULL AND
        p_lgcy_clsrnk_rec.cohort_override_rank <= 0 THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_PR_RANK_NULL');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;

     /*
        return the value of x_return_status
     */
     return x_return_status;
  END validate_parameters;


  PROCEDURE derive_clsrnk_data
         (
           p_lgcy_clsrnk_rec           IN          lgcy_clsrnk_rec_type,
           p_person_id                 OUT NOCOPY  igs_pe_person.person_id%type,
           p_cal_type                  OUT NOCOPY  igs_ca_inst.cal_type%type,
           p_sequence_number           OUT NOCOPY  igs_ca_inst.sequence_number%type
         )
   IS
   /*************************************************************
   Created By : smanglm
   Date Created on : 2002/11/13
   Purpose :
            derive_clsrnk_data procedure derives data like: -
            1. Derive Person_id from person_number .
            2. Derive cal_type and sequence_number from cal_alt_code
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
   ***************************************************************/
     x_return_status BOOLEAN;
   BEGIN
     x_return_status := TRUE;
     /*
        get person_id
     */
     p_person_id := IGS_GE_GEN_003.GET_PERSON_ID(p_lgcy_clsrnk_rec.person_number);
     IF p_person_id IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
        FND_MSG_PUB.ADD;
        x_return_status := FALSE;
     END IF;
     /*
        get cal_type and sequence_number
     */
     DECLARE
        l_start_dt       igs_ca_inst.start_dt%TYPE;
        l_end_dt         igs_ca_inst.end_dt%TYPE;
        l_return_status  VARCHAR2(2000);
     BEGIN
       IGS_GE_GEN_003.GET_CALENDAR_INSTANCE
                      (
                        P_ALTERNATE_CD       => p_lgcy_clsrnk_rec.calendar_alternate_code,
                        P_S_CAL_CATEGORY     => NULL,
                        P_CAL_TYPE           => p_cal_type,
                        P_CI_SEQUENCE_NUMBER => p_sequence_number,
                        P_START_DT           => l_start_dt,
                        P_END_DT             => l_end_dt,
                        P_RETURN_STATUS      => l_return_status
                      );
       IF l_return_status = 'INVALID' THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_PR_NO_ALT_CODE');
          FND_MSG_PUB.ADD;
          x_return_status := FALSE;
       ELSIF l_return_status = 'MULTIPLE' THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_PR_MULTI_ALT_CODE');
          FND_MSG_PUB.ADD;
          x_return_status := FALSE;
       END IF;
     END;

     IF NOT x_return_status THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

  END derive_clsrnk_data;

  FUNCTION validate_db_cons
         (
           p_person_id          IN  igs_pe_person.person_id%type,
           p_cal_type           IN  igs_ca_inst.cal_type%type,
           p_sequence_number    IN  igs_ca_inst.sequence_number%type,
           p_lgcy_clsrnk_rec    IN  lgcy_clsrnk_rec_type
         )
  RETURN VARCHAR2
  /*************************************************************
  Created By : smanglm
  Date Created on : 2002/11/13
  Purpose : validate_db_cons function performs
            all the data integrity validation
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  IS
     x_return_status  VARCHAR2(1);
  BEGIN
     x_return_status := 'S';
     /*
       check whether cohort inst exists or not
     */
     IF NOT IGS_PR_COHORT_INST_PKG.GET_PK_FOR_VALIDATION
                       (
                         x_cohort_name             => p_lgcy_clsrnk_rec.cohort_name,
                         x_load_cal_type           => p_cal_type,
                         x_load_ci_sequence_number => p_sequence_number
                       ) THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_PR_COHINST_NOT_EXIST');
          FND_MSG_PUB.ADD;
          x_return_status := 'E';
     END IF;
     /*
       check whether program attempt exists or not
     */
     IF NOT IGS_EN_STDNT_PS_ATT_PKG.GET_PK_FOR_VALIDATION
                       (
                         x_person_id             => p_person_id,
                         x_course_cd             => p_lgcy_clsrnk_rec.program_cd
                       ) THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_PRGM_ATT_NOT_EXIST');
          FND_MSG_PUB.ADD;
          x_return_status := 'E';
     END IF;
     /*
        Check if the student already has already been ranked for the cohort instance.
	If yes,  then set the message IGS_PR_RANK_EXIST into message stack and return
	from the function with return value 'W', as the record already exists in
	the system, so no need to do other validations
     */
     IF IGS_PR_COHINST_RANK_PKG.GET_PK_FOR_VALIDATION
             (
               x_person_id               => p_person_id,
	       x_course_cd               => p_lgcy_clsrnk_rec.program_cd,
	       x_cohort_name             => p_lgcy_clsrnk_rec.cohort_name,
	       x_load_cal_type           => p_cal_type,
	       x_load_ci_sequence_number => p_sequence_number
	     ) THEN
          FND_MESSAGE.SET_NAME('IGS', 'IGS_PR_RANK_EXIST');
          FND_MSG_PUB.ADD;
          x_return_status := 'W';
     END IF;

     return x_return_status;
  END validate_db_cons;

END igs_pr_clsrnk_lgcy_pub;

/
