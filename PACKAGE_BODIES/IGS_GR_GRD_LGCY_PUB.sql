--------------------------------------------------------
--  DDL for Package Body IGS_GR_GRD_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_GRD_LGCY_PUB" AS
/* $Header: IGSPGR1B.pls 115.8 2003/10/10 09:20:45 anilk noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IGS_PR_GRD_LGCY_PUB';

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              IGS_PR_GRD_LGCY_PUB                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Creates advanced standing unit level                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_api_version                                          |
 |                    p_init_msg_list                                        |
 |                    p_commit                                               |
 |                    p_validation_level                                     |
 | 		      p_lgcy_grd_rec                                         |
 |					                                     |
 |                                                                           |
 |              OUT:							     |
 |                    x_return_status                                        |
 |                    x_msg_count                                            |
 |                    x_msg_data                                             |
 |                                                                           |
 |          IN/ OUT:                                                         |
 |                    p_lgcy_grd_rec                                         |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | Manu Srinivasan 11-Nov-02 Created                                         |
 | Kalyan Dande    03-Jan-03 Changed create_graduand message name to         |
 |                           IGS_AV_UNHANDLED_ERROR                          |
 +===========================================================================*/


FUNCTION VALIDATE_PARAMETERS(p_lgcy_grd_rec          IN OUT NOCOPY lgcy_grd_rec_type) RETURN BOOLEAN;

FUNCTION DERIVE_GRADUAND_DATA( p_lgcy_grd_rec        IN OUT NOCOPY lgcy_grd_rec_type,
                               p_person_id              OUT NOCOPY IGS_PE_PERSON.PERSON_ID%TYPE,
                               p_cal_type               OUT NOCOPY IGS_CA_INST.CAL_TYPE%TYPE,
                               p_sequence_number        OUT NOCOPY IGS_CA_INST.SEQUENCE_NUMBER%TYPE,
                               p_proxy_award_person_id  OUT NOCOPY IGS_PE_PERSON.PERSON_ID%TYPE,
                               p_proxy_award_ind        OUT NOCOPY IGS_GR_GRADUAND_ALL.PROXY_AWARD_IND%TYPE
			      )
RETURN BOOLEAN;

FUNCTION VALIDATE_GRAD_DB_CONS ( p_person_id         IN	IGS_PE_PERSON.PERSON_ID%TYPE,
                                 p_cal_type          IN IGS_CA_INST.CAL_TYPE%TYPE,
                                 p_sequence_number   IN IGS_CA_INST.SEQUENCE_NUMBER%TYPE,
				 p_lgcy_grd_rec      IN OUT NOCOPY lgcy_grd_rec_type
				)
RETURN VARCHAR2;



FUNCTION VALIDATE_GRADUANDS(	p_lgcy_grd_rec            IN OUT NOCOPY lgcy_grd_rec_type,
                                P_person_id		  IN  IGS_PE_PERSON.PERSON_ID%TYPE,
                                P_cal_type		  IN  IGS_CA_INST.CAL_TYPE%TYPE,
                                P_sequence_number	  IN  IGS_CA_INST. SEQUENCE_NUMBER%TYPE,
                                P_proxy_award_person_id	  IN  IGS_PE_PERSON.PERSON_ID%TYPE,
                                P_proxy_award_ind	  IN  IGS_GR_GRADUAND_ALL. PROXY_AWARD_IND%TYPE

) RETURN BOOLEAN;
FUNCTION VALIDATE_POST_GRADUAND(
        p_lgcy_grd_rec      IN OUT NOCOPY lgcy_grd_rec_type,
	P_person_id	    IN  IGS_PE_PERSON.PERSON_ID%TYPE,
	P_cal_type	    IN  IGS_CA_INST.CAL_TYPE%TYPE,
	P_sequence_number   IN  IGS_CA_INST. SEQUENCE_NUMBER%TYPE
)RETURN BOOLEAN;


PROCEDURE create_graduand(
                       p_api_version         IN  NUMBER,
                       p_init_msg_list       IN  VARCHAR2 ,
                       p_commit              IN  VARCHAR2 ,
                       p_validation_level    IN  NUMBER   ,
                       p_lgcy_grd_rec        IN  OUT NOCOPY lgcy_grd_rec_type,
                       x_return_status       OUT NOCOPY VARCHAR2,
                       x_msg_count           OUT NOCOPY NUMBER,
                       x_msg_data            OUT NOCOPY VARCHAR2)
  IS

/****************************************************************************************************************
  ||  Created By : msrinivi
  ||  Created On : 11-Nov-2002
  ||  Purpose    : For legacy graduand API
  ||
  ||  This process is called when graduation legacy data needs
  ||  to be put into OSS tables
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/

  l_api_name		CONSTANT VARCHAR2(30) := 'create_graduand';
  l_api_version 	CONSTANT  NUMBER      := 1.0;

  --Local params
  l_person_id              IGS_PE_PERSON.PERSON_ID%TYPE;
  l_cal_type               IGS_CA_INST.CAL_TYPE%TYPE;
  l_sequence_number        IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
  l_proxy_award_person_id  IGS_PE_PERSON.PERSON_ID%TYPE;
  l_proxy_award_ind        IGS_GR_GRADUAND_ALL.PROXY_AWARD_IND%TYPE;

  l_return_value VARCHAR2(1);

 WARN_TYPE_ERR EXCEPTION;

  BEGIN
  --Standard start of API savepoint
        SAVEPOINT create_graduand;

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

  --THE CODE LOGIC STARTS HERE

  --Validate the params passed to this API
    IF NOT validate_parameters(p_lgcy_grd_rec) THEN
        x_return_status  := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  --End of Validate the params passed to this API

  --Derive Graduand data
    IF NOT derive_graduand_data( p_lgcy_grd_rec          => p_lgcy_grd_rec,
                                 p_person_id             => l_person_id,
                                 p_cal_type              => l_cal_type,
                                 p_sequence_number       => l_sequence_number,
                                 p_proxy_award_person_id => l_proxy_award_person_id,
                                 p_proxy_award_ind       => l_proxy_award_ind
	      ) THEN
      x_return_status  := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  --End of Derive Graduand data

  --CALL VALIDATE_GRAD_DB_CONS
    l_return_value := VALIDATE_GRAD_DB_CONS ( p_person_id    => l_person_id,
                                              p_lgcy_grd_rec => p_lgcy_grd_rec,
                                              p_cal_type     =>  l_cal_type,
                                              p_sequence_number=>l_sequence_number
                      			    );
    IF l_return_value  = 'E' THEN
      x_return_status  := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_value = 'W' THEN
      RAISE WARN_TYPE_ERR; --Error handling Goes here
    END IF;
  --END OF VALIDATE_GRAD_DB_CONS

  --Call to validate_graduand
    IF NOT VALIDATE_GRADUANDS( p_lgcy_grd_rec         => p_lgcy_grd_rec,
			      P_person_id	      => l_person_id,
			      P_cal_type	      => l_cal_type,
			      P_sequence_number	      => l_sequence_number,
			      P_proxy_award_person_id => l_proxy_award_person_id,
			      P_proxy_award_ind	      => l_proxy_award_ind         ) THEN
            RAISE FND_API.G_EXC_ERROR; --Error handling Goes here
    END IF;
  --End of Call to validate_graduand
  --Call RAW insert into the table
     INSERT INTO igs_gr_graduand
                               (
                                 PERSON_ID,
                                 CREATE_DT,
                                 GRD_CAL_TYPE,
                                 GRD_CI_SEQUENCE_NUMBER,
                                 COURSE_CD,
                                 AWARD_COURSE_CD,
                                 AWARD_CRS_VERSION_NUMBER,
                                 AWARD_CD,
                                 GRADUAND_STATUS,
                                 GRADUAND_APPR_STATUS,
                                 S_GRADUAND_TYPE,
                                 GRADUATION_NAME,
                                 PROXY_AWARD_IND,
                                 PROXY_AWARD_PERSON_ID,
                                 PREVIOUS_QUALIFICATIONS,
                                 CONVOCATION_MEMBERSHIP_IND,
                                 SUR_FOR_COURSE_CD,
                                 SUR_FOR_CRS_VERSION_NUMBER,
                                 SUR_FOR_AWARD_CD,
                                 COMMENTS,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_LOGIN,
                                 REQUEST_ID,
                                 PROGRAM_ID,
                                 PROGRAM_APPLICATION_ID,
                                 PROGRAM_UPDATE_DATE,
                                 ORG_ID,
                                 ATTRIBUTE_CATEGORY,
                                 ATTRIBUTE1,
                                 ATTRIBUTE2,
                                 ATTRIBUTE3,
                                 ATTRIBUTE4,
                                 ATTRIBUTE5,
                                 ATTRIBUTE6,
                                 ATTRIBUTE7,
                                 ATTRIBUTE8,
                                 ATTRIBUTE9,
                                 ATTRIBUTE10,
                                 ATTRIBUTE11,
                                 ATTRIBUTE12,
                                 ATTRIBUTE13,
                                 ATTRIBUTE14,
                                 ATTRIBUTE15,
                                 ATTRIBUTE16,
                                 ATTRIBUTE17,
                                 ATTRIBUTE18,
                                 ATTRIBUTE19,
				 ATTRIBUTE20
                                )
     VALUES
     (

                                 L_PERSON_ID,
                                 p_lgcy_grd_rec.CREATE_DT,
                                 l_cal_type          ,
                                 l_sequence_number   ,
                                 UPPER(p_lgcy_grd_rec.program_cd),
                                 UPPER(p_lgcy_grd_rec.award_program_cd),
                                 p_lgcy_grd_rec.AWARD_prog_VERSION_NUMBER,
                                 UPPER(p_lgcy_grd_rec.award_cd),
                                 p_lgcy_grd_rec.GRADUAND_STATUS,
                                 p_lgcy_grd_rec.GRADUAND_APPR_STATUS,
                                 UPPER(p_lgcy_grd_rec.s_graduand_type),
                                 p_lgcy_grd_rec.GRADUATION_NAME,
                                 l_proxy_award_ind,
                                 l_proxy_award_person_id,
                                 p_lgcy_grd_rec.PREVIOUS_QUALIFICATIONS,
                                 p_lgcy_grd_rec.CONVOCATION_MEMBERSHIP_IND,
                                 UPPER(p_lgcy_grd_rec.sur_for_program_cd),
                                 p_lgcy_grd_rec.SUR_FOR_prog_VERSION_NUMBER,
                                 UPPER(p_lgcy_grd_rec.sur_for_award_cd),
                                 p_lgcy_grd_rec.COMMENTS,
                                 SYSDATE ,--p_lgcy_grd_rec.CREATION_DATE,
                                 NVL(FND_GLOBAL.USER_ID,-1),--p_lgcy_grd_rec.CREATED_BY,
                                 SYSDATE,--p_lgcy_grd_rec.LAST_UPDATE_DATE,
                                 NVL(FND_GLOBAL.USER_ID,-1),--p_lgcy_grd_rec.LAST_UPDATED_BY,
                                 NVL(FND_GLOBAL.LOGIN_ID,-1),--p_lgcy_grd_rec.LAST_UPDATE_LOGIN,
                                 NULL,--p_lgcy_grd_rec.REQUEST_ID,
                                 NULL,--p_lgcy_grd_rec.PROGRAM_ID,
                                 NULL,--p_lgcy_grd_rec.PROGRAM_APPLICATION_ID,
                                 NULL,--p_lgcy_grd_rec.PROGRAM_UPDATE_DATE,
                                 NULL,--p_lgcy_grd_rec.ORG_ID,
                                 p_lgcy_grd_rec.ATTRIBUTE_CATEGORY,
                                 p_lgcy_grd_rec.ATTRIBUTE1,
                                 p_lgcy_grd_rec.ATTRIBUTE2,
                                 p_lgcy_grd_rec.ATTRIBUTE3,
                                 p_lgcy_grd_rec.ATTRIBUTE4,
                                 p_lgcy_grd_rec.ATTRIBUTE5,
                                 p_lgcy_grd_rec.ATTRIBUTE6,
                                 p_lgcy_grd_rec.ATTRIBUTE7,
                                 p_lgcy_grd_rec.ATTRIBUTE8,
                                 p_lgcy_grd_rec.ATTRIBUTE9,
                                 p_lgcy_grd_rec.ATTRIBUTE10,
                                 p_lgcy_grd_rec.ATTRIBUTE11,
                                 p_lgcy_grd_rec.ATTRIBUTE12,
                                 p_lgcy_grd_rec.ATTRIBUTE13,
                                 p_lgcy_grd_rec.ATTRIBUTE14,
                                 p_lgcy_grd_rec.ATTRIBUTE15,
                                 p_lgcy_grd_rec.ATTRIBUTE16,
                                 p_lgcy_grd_rec.ATTRIBUTE17,
                                 p_lgcy_grd_rec.ATTRIBUTE18,
                                 p_lgcy_grd_rec.ATTRIBUTE19,
                                 p_lgcy_grd_rec.ATTRIBUTE20
				 );

  --Insert done into table, so call VALIDATE_POST_GRADUAND
    IF NOT VALIDATE_POST_GRADUAND(
                                  p_lgcy_grd_rec     =>  p_lgcy_grd_rec,
                                  P_person_id	     =>	 l_person_id,
                                  P_cal_type	     =>	 l_cal_type,
                                  P_sequence_number  =>	 l_sequence_number
    ) THEN
            RAISE WARN_TYPE_ERR; --Error handling Goes here
    END IF;
  --End of call to VALIDATE_POST_GRADUAND

  --THE CODE LOGIC ENDS   HERE

  --Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                commit;
        END IF;

    FND_MSG_PUB.Count_And_Get(
      p_count => x_MSG_COUNT,
      p_data  => X_MSG_DATA);


  EXCEPTION
       WHEN WARN_TYPE_ERR THEN
       		ROLLBACK TO create_graduand;
	        x_return_status := 'W';
                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN FND_API.G_EXC_ERROR THEN
       		ROLLBACK TO create_graduand;
	        x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO create_graduand;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
		ROLLBACK TO create_graduand;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('IGS', 'IGS_AV_UNHANDLED_ERROR');
                FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END create_graduand ;



FUNCTION validate_parameters
(
  p_lgcy_grd_rec IN OUT NOCOPY lgcy_grd_rec_type
) RETURN  BOOLEAN

/****************************************************************************************************************
  ||  Created By : msrinivi
  ||  Created On : 11-Nov-2002
  ||  Purpose    : Valdiates if all the mandatory for this API has been passed
  ||               If not, add the msgs to the stack and return false
  ||  This process is called when graduation legacy data needs
  ||  to be put into OSS tables
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/
IS

  l_return_value BOOLEAN := FND_API.TO_BOOLEAN(FND_API.G_TRUE);

BEGIN

  --Convert all the values that must be uppercase into uppercase forcibly
  p_lgcy_grd_rec.program_cd                :=  UPPER(p_lgcy_grd_rec.program_cd);
  p_lgcy_grd_rec.award_program_cd          :=  UPPER(p_lgcy_grd_rec.award_program_cd);
  p_lgcy_grd_rec.award_cd                  :=  UPPER(p_lgcy_grd_rec.award_cd);
  p_lgcy_grd_rec.s_graduand_type           :=  UPPER(p_lgcy_grd_rec.s_graduand_type);
  p_lgcy_grd_rec.sur_for_program_cd        :=  UPPER(p_lgcy_grd_rec.sur_for_program_cd);
  p_lgcy_grd_rec.sur_for_award_cd          :=  UPPER(p_lgcy_grd_rec.sur_for_award_cd);
  p_lgcy_grd_rec.grd_cal_alt_code          :=  UPPER(p_lgcy_grd_rec.grd_cal_alt_code);

  IF p_lgcy_grd_rec.person_number IS NULL THEN
    l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_EN_PER_NUM_NULL');
    FND_MSG_PUB.ADD;
  END IF;

  IF p_lgcy_grd_rec.create_dt    IS  NULL THEN
    l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_CREATE_DT_NOT_NULL');
    FND_MSG_PUB.ADD;
  END IF;

  IF p_lgcy_grd_rec.GRD_CAL_ALT_CODE IS  NULL THEN
    l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_CALALTCD_NOT_NULL');
    FND_MSG_PUB.ADD;
  END IF;


  IF p_lgcy_grd_rec.AWARD_CD IS  NULL THEN
    l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_AWARD_CD_NOT_NULL');
    FND_MSG_PUB.ADD;
  END IF;

  IF p_lgcy_grd_rec.GRADUAND_STATUS IS  NULL THEN
    l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_GRADSTAT_NOT_NULL');
    FND_MSG_PUB.ADD;
  END IF;

  IF p_lgcy_grd_rec.GRADUAND_APPR_STATUS IS  NULL THEN
    l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_GRD_APPRSTAT_NOT_NULL');
    FND_MSG_PUB.ADD;
  END IF;

  --If the Award_program_code record type parameter is not NULL
  --then Award_program_version_number should be >=1 and <= 999
  IF    p_lgcy_grd_rec.AWARD_PROGRAM_CD           IS NOT NULL
    AND
        (
          p_lgcy_grd_rec.AWARD_PROG_VERSION_NUMBER  IS NULL OR
          NVL(p_lgcy_grd_rec.AWARD_PROG_VERSION_NUMBER,-1)  < 1 OR
          NVL(p_lgcy_grd_rec.AWARD_PROG_VERSION_NUMBER,-1)> 999
         )
  THEN
    l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
  FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_AWD_PRGVER_BET_1_999');
  FND_MSG_PUB.ADD;
  END IF;

  --If the record parameter SUR_FOR_PROGRAM_CD is Not Null
  --then SUR_FOR_PROG_VERSION_NUMBER should have a value >= 1 and <= 999
  IF    p_lgcy_grd_rec.sur_for_program_cd           IS NOT NULL
    AND
        (
          p_lgcy_grd_rec.SUR_FOR_PROG_VERSION_NUMBER   IS NULL OR
          NVL(p_lgcy_grd_rec.SUR_FOR_PROG_VERSION_NUMBER ,-1)  < 1 OR
          NVL(p_lgcy_grd_rec.SUR_FOR_PROG_VERSION_NUMBER ,-1)> 999
         )
  THEN
    l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_SUR_PRGVER_BET_1_999');
    FND_MSG_PUB.ADD;
  END IF;

  --If the record parameter SUR_FOR_PROGRAM_CD is Not Null
  --then the record parameter SUR_FOR_AWARD_CD should have a not null value
  --for SUR_FOR_AWARD CODE specified
  IF    p_lgcy_grd_rec.sur_for_program_cd           IS NOT NULL
    AND
        (
          p_lgcy_grd_rec.SUR_FOR_AWARD_CD IS NULL
         )
  THEN
    l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_SUR_AWDCD_NOT_NULL');
    FND_MSG_PUB.ADD;
  END IF;

  --Validate the flex definition
  IF NOT IGS_AD_IMP_018.validate_desc_flex(
  				p_ATTRIBUTE_CATEGORY => p_lgcy_grd_rec.ATTRIBUTE_CATEGORY,
				p_attribute1         => p_lgcy_grd_rec.ATTRIBUTE1        ,
				p_attribute2         => p_lgcy_grd_rec.ATTRIBUTE2        ,
				p_attribute3         => p_lgcy_grd_rec.ATTRIBUTE3        ,
				p_attribute4         => p_lgcy_grd_rec.ATTRIBUTE4        ,
				p_attribute5         => p_lgcy_grd_rec.ATTRIBUTE5        ,
				p_attribute6         => p_lgcy_grd_rec.ATTRIBUTE6        ,
				p_attribute7         => p_lgcy_grd_rec.ATTRIBUTE7        ,
				p_attribute8         => p_lgcy_grd_rec.ATTRIBUTE8        ,
				p_attribute9         => p_lgcy_grd_rec.ATTRIBUTE9        ,
				p_ATTRIBUTE10        => p_lgcy_grd_rec.ATTRIBUTE10       ,
				p_ATTRIBUTE11        => p_lgcy_grd_rec.ATTRIBUTE11       ,
				p_ATTRIBUTE12        => p_lgcy_grd_rec.ATTRIBUTE12       ,
				p_ATTRIBUTE13        => p_lgcy_grd_rec.ATTRIBUTE13       ,
				p_ATTRIBUTE14        => p_lgcy_grd_rec.ATTRIBUTE14       ,
				p_ATTRIBUTE15        => p_lgcy_grd_rec.ATTRIBUTE15       ,
				p_ATTRIBUTE16        => p_lgcy_grd_rec.ATTRIBUTE16       ,
				p_ATTRIBUTE17        => p_lgcy_grd_rec.ATTRIBUTE17       ,
				p_ATTRIBUTE18        => p_lgcy_grd_rec.ATTRIBUTE18       ,
				p_ATTRIBUTE19        => p_lgcy_grd_rec.ATTRIBUTE19       ,
				p_ATTRIBUTE20        => p_lgcy_grd_rec.ATTRIBUTE20       ,
				p_desc_flex_name     => 'IGS_GR_GRADUAND_FLEX'         ) THEN
    l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_INVALID_DESC_FLEX');
    FND_MSG_PUB.ADD;
  END IF;

  RETURN l_return_value ;

END validate_parameters;

FUNCTION derive_graduand_data( p_lgcy_grd_rec        IN OUT NOCOPY lgcy_grd_rec_type,
                               p_person_id              OUT NOCOPY IGS_PE_PERSON.PERSON_ID%TYPE,
                               p_cal_type               OUT NOCOPY IGS_CA_INST.CAL_TYPE%TYPE,
                               p_sequence_number        OUT NOCOPY IGS_CA_INST.SEQUENCE_NUMBER%TYPE,
                               p_proxy_award_person_id  OUT NOCOPY IGS_PE_PERSON.PERSON_ID%TYPE,
                               p_proxy_award_ind        OUT NOCOPY IGS_GR_GRADUAND_ALL.PROXY_AWARD_IND%TYPE
			      )RETURN  BOOLEAN

/****************************************************************************************************************
  ||  Created By : msrinivi
  ||  Created On : 11-Nov-2002
  ||  Purpose    : Derives graduand data
  ||               If error occurs, add the msgs to the stack and return false
  ||               Called by create_graduand
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/
IS

  l_return_value BOOLEAN := FND_API.TO_BOOLEAN(FND_API.G_TRUE);
  l_message VARCHAR2(2000);
  l_start_dt DATE ;
  l_end_dt DATE ;
BEGIN

  p_person_id := igs_ge_gen_003.get_person_id(p_lgcy_grd_rec.person_number);

  --Get person id
  IF p_person_id IS NULL THEN
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_INVALID_PERSON_NUMBER');
    FND_MSG_PUB.ADD;
    l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
    RETURN l_return_value;
  END IF;
  --End of Get person id

  --Get calendar info
  igs_ge_gen_003.get_calendar_instance(p_lgcy_grd_rec.GRD_CAL_ALT_CODE,NULL,p_cal_type, p_sequence_number, l_start_dt, l_end_dt, l_message) ;

  IF p_cal_type IS NULL OR p_sequence_number IS NULL THEN
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AV_INVALID_CAL_ALT_CODE');
    FND_MSG_PUB.ADD;
    l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
    RETURN l_return_value;
  END IF;
  --End of Get calendar info

  --Derive proxy award person number if corrs. person number is passed
  IF p_lgcy_grd_rec.proxy_award_person_number IS NOT NULL THEN -- Proxy person number is passed, get corrs. person id
    p_proxy_award_person_id := Igs_Ge_Gen_003.Get_Person_id (p_lgcy_grd_rec.proxy_award_person_number) ;

    IF  p_proxy_award_person_id IS NULL THEN -- Wrong proxy person number is passed
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_INVALID_PRXYPERS_NUM');
        FND_MSG_PUB.ADD;
        l_return_value := FND_API.TO_BOOLEAN(FND_API.G_FALSE);
        RETURN l_return_value;
    ELSE
      -- Correct proxy person number is passed, so set the ind to Y
      p_proxy_award_ind := 'Y';
    END IF;

  ELSE
      -- No proxy person number is passed, so set the ind to N
      p_proxy_award_ind := 'N';
  END IF;
  --End of Derive proxy award person number if corrs. person number is passed

  --Default the value of the record parameter S_GRADUAND_TYPE to 'UNKNOWN' in case it has a value of NULL.
    IF p_lgcy_grd_rec.S_GRADUAND_TYPE IS NULL THEN
      p_lgcy_grd_rec.S_GRADUAND_TYPE := 'UNKNOWN';
    END IF;
  --End of Default the value of the record parameter S_GRADUAND_TYPE to 'UNKNOWN' in case it has a value of NULL.

--If the record type parameter has GRADUAND_NAME as null then default the GRADUAND_NAME
    IF p_lgcy_grd_rec.GRADUATION_NAME IS NULL THEN
      p_lgcy_grd_rec.GRADUATION_NAME  := IGS_GR_GEN_001.GRDP_GET_GRAD_NAME(p_person_id);
    END IF;
--End of If the record type parameter has GRADUAND_NAME as null then default the GRADUAND_NAME

--Default the value of the record parameter CONVOCATION_MEMBERSHIP_IND  to 'N' if it has a  null value passed.
    IF p_lgcy_grd_rec.CONVOCATION_MEMBERSHIP_IND IS NULL THEN
      p_lgcy_grd_rec.CONVOCATION_MEMBERSHIP_IND := 'N';
    END IF;
--End of Default the value of the record parameter CONVOCATION_MEMBERSHIP_IND  to 'N' if it has a  null value passed.

  RETURN l_return_value;

END derive_graduand_data;


FUNCTION VALIDATE_GRAD_DB_CONS ( p_person_id         IN	IGS_PE_PERSON.PERSON_ID%TYPE,
                                 p_cal_type          IN IGS_CA_INST.CAL_TYPE%TYPE,
                                 p_sequence_number   IN IGS_CA_INST.SEQUENCE_NUMBER%TYPE,
				 p_lgcy_grd_rec      IN OUT NOCOPY lgcy_grd_rec_type
				)
RETURN VARCHAR2
/****************************************************************************************************************
  ||  Created By : msrinivi
  ||  Created On : 11-Nov-2002
  ||  Purpose    : Validate db constraints
  ||               If error occurs, add the msgs to the stack and return false
  ||               Called by create_graduand
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/
IS

  --Initialize API return status to success.
  l_return_value VARCHAR2(10) := FND_API.G_RET_STS_SUCCESS;

BEGIN
  -- Check for record existance
  IF Igs_Gr_Graduand_Pkg.Get_Pk_For_Validation(X_PERSON_ID    => p_person_id,
                                                   X_CREATE_DT    => p_lgcy_grd_rec.create_dt) THEN
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_GRAD_PK_ALREADY_EXISTS');
    FND_MSG_PUB.ADD;
    l_return_value := 'W'; -- Error out
    RETURN l_return_value;
  END IF;
  -- End of check for record existance

  -- Check for Unique key
  IF Igs_Gr_Graduand_Pkg.get_uk_for_validation(
                                                    X_PERSON_ID                    => p_person_id,
                                                    X_CREATE_DT                    => p_lgcy_grd_rec.create_dt,
                                                    X_AWARD_COURSE_CD              => p_lgcy_grd_rec.award_program_cd,
                                                    X_AWARD_CRS_VERSION_NUMBER     => p_lgcy_grd_rec.award_prog_version_number,
                                                    X_AWARD_CD                     => p_lgcy_grd_rec.award_cd
                                                   )
  THEN
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_GRAD_UK_ALREADY_EXISTS');
    FND_MSG_PUB.ADD;
    l_return_value := 'W';  -- Error out
    RETURN l_return_value;
  END IF;
  -- End of Check for Unique key check

  -- Foreign key validation with the table IGS_PS_AWD_PKG Column Award_Cd
  IF NOT IGS_PS_AWD_PKG.Get_PK_For_Validation(X_AWARD_CD =>  p_lgcy_grd_rec.award_cd)
  THEN
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_AWDCD_FK_NOT_EXISTS');
    FND_MSG_PUB.ADD;
    l_return_value := 'E'; --Continue
  END IF;
  -- End of Foreign key validation with the table IGS_PS_AWD_PKG Column Award_Cd

  -- Foreign key validation with the table IGS_PS_AWARD_PKG Columns award_course_cd, award_crs_version_number and  Award_Cd
    IF p_lgcy_grd_rec.AWARD_PROGRAM_CD           IS NOT NULL AND
       p_lgcy_grd_rec.AWARD_PROG_VERSION_NUMBER  IS NOT NULL AND
       p_lgcy_grd_rec.AWARD_CD               IS NOT NULL AND
       NOT IGS_PS_AWARD_PKG.Get_PK_For_Validation(X_COURSE_CD         => p_lgcy_grd_rec.AWARD_PROGRAM_CD          ,
                                                  X_VERSION_NUMBER    => p_lgcy_grd_rec.AWARD_PROG_VERSION_NUMBER ,
					          X_AWARD_CD          => p_lgcy_grd_rec.AWARD_CD )
    THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_AWDDET_FK_NOT_EXISTS');
      FND_MSG_PUB.ADD;
      l_return_value := 'E';--Continue
    END IF;
  -- End of Foreign key validation with the table IGS_PS_AWARD_PKG Columns award_course_cd, award_crs_version_number and  Award_Cd

  --Foreign key validation with the table IGS_GR_CRMN_ROUND_PKG column grd_cal_type and grd_ci_sequence_number
  IF NOT IGS_GR_CRMN_ROUND_PKG.Get_PK_For_Validation(
                                                      X_GRD_CAL_TYPE                 => p_cal_type ,
                                                      X_GRD_CI_SEQUENCE_NUMBER       =>	p_sequence_number
                                                     )
  THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_CRMRND_FK_NOT_EXISTS');
      FND_MSG_PUB.ADD;
      l_return_value := 'E';--Continue
  END IF;
  --End of Foreign key validation with the table IGS_GR_CRMN_ROUND_PKG column grd_cal_type and grd_ci_sequence_number

  --7Foreign key validation with the table IGS_GR_APRV_STAT_PKG column graduand_appr_status
IF NOT   IGS_GR_APRV_STAT_PKG.Get_PK_For_Validation(X_GRADUAND_APPR_STATUS         => p_lgcy_grd_rec.GRADUAND_APPR_STATUS)
THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_APRSTAT_FK_NOT_EXISTS');
      FND_MSG_PUB.ADD;
      l_return_value := 'E';--Continue
END IF;
  --7End of Foreign key validation with the table IGS_GR_APRV_STAT_PKG column graduand_appr_status

--Foreign key validation with the table IGS_GR_STAT_PKG column graduand_status
IF NOT   IGS_GR_STAT_PKG.Get_PK_For_Validation(X_GRADUAND_STATUS   => p_lgcy_grd_rec.GRADUAND_STATUS)
THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_GRDSTAT_FK_NOT_EXISTS');
      FND_MSG_PUB.ADD;
      l_return_value := 'E';--Continue
END IF;
--End of Foreign key validation with the table IGS_GR_STAT_PKG column graduand_status

--Foreign key validation with the table IGS_EN_STDNT_PS_ATT_PKG column person_id and course_cd
IF p_person_id IS NOT NULL AND
   p_lgcy_grd_rec.program_cd IS NOT NULL AND
   NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation(X_PERSON_ID => p_person_id,
                                                     X_COURSE_CD => p_lgcy_grd_rec.program_cd)
THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_STPRATPT_FK_NOT_EXISTS');
      FND_MSG_PUB.ADD;
      l_return_value := 'E';--Continue
END IF;
--End of Foreign key validation with the table IGS_EN_STDNT_PS_ATT_PKG column person_id and course_cd


--Foreign key validation with the table IGS_PS_AWARD_PKG column sur_for_course_cd, sur_for_crs_version_number and sur_for_award_cd
IF p_lgcy_grd_rec.sur_for_program_cd   IS NOT NULL AND
   p_lgcy_grd_rec.sur_for_prog_version_number    IS NOT NULL AND
   p_lgcy_grd_rec.sur_for_award_cd   IS NOT NULL AND
   NOT IGS_PS_AWARD_PKG.Get_PK_For_Validation (X_COURSE_CD                    => p_lgcy_grd_rec.sur_for_program_cd   ,
                                               X_VERSION_NUMBER               => p_lgcy_grd_rec.sur_for_prog_version_number    ,
                                               X_AWARD_CD                     => p_lgcy_grd_rec.sur_for_award_cd)
THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_SURCRSCD_FK_NOT_EXISTS');
      FND_MSG_PUB.ADD;
      l_return_value := 'E';--Continue
END IF;
--End of Foreign key validation with the table IGS_PS_AWARD_PKG column sur_for_course_cd, sur_for_crs_version_number and sur_for_award_cd

  IF p_lgcy_grd_rec.CONVOCATION_MEMBERSHIP_IND NOT IN('Y','N') THEN
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_CONV_MEM_IND_Y_N');
    FND_MSG_PUB.ADD;
    l_return_value := 'E';--Continue
  END IF;

--S_GRADUAND_TYPE should not have any other value except for Attending , Inabsentia , Articulate , Deferred , Unknown , Declined:
  IF p_lgcy_grd_rec.S_GRADUAND_TYPE NOT IN  ( 'ATTENDING' , 'INABSENTIA' , 'ARTICULATE' , 'DEFERRED' , 'UNKNOWN' , 'DECLINED' ) THEN
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_SGRADTYP_INVALID_VAL');
    FND_MSG_PUB.ADD;
    l_return_value := 'E';--Continue
  END IF;
--End of S_GRADUAND_TYPE should not have any other value except for Attending , Inabsentia , Articulate , Deferred , Unknown , Declined:

RETURN l_return_value;

END VALIDATE_GRAD_DB_CONS;

FUNCTION VALIDATE_GRADUANDS(	p_lgcy_grd_rec            IN OUT NOCOPY lgcy_grd_rec_type,
                                P_person_id		  IN  IGS_PE_PERSON.PERSON_ID%TYPE,
                                P_cal_type		  IN  IGS_CA_INST.CAL_TYPE%TYPE,
                                P_sequence_number	  IN  IGS_CA_INST. SEQUENCE_NUMBER%TYPE,
                                P_proxy_award_person_id	  IN  IGS_PE_PERSON.PERSON_ID%TYPE,
                                P_proxy_award_ind	  IN  IGS_GR_GRADUAND_ALL. PROXY_AWARD_IND%TYPE

) RETURN BOOLEAN

/****************************************************************************************************************
  ||  Created By : msrinivi
  ||  Created On : 11-Nov-2002
  ||  Purpose    : This function validates all the business rules before
  ||               inserting a record in the table IGS_GR_GRADUAND_ALL
  ||
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/
IS

  --Initialize API return status to true
  l_return_value BOOLEAN := FND_API.TO_BOOLEAN(FND_API.G_TRUE);

--Cursor to fetch the award type
CURSOR c_awd_type(p_award_cd igs_ps_awd.award_cd%TYPE) IS
  SELECT S_AWARD_TYPE
  FROM   igs_ps_awd
  WHERE  award_cd = p_award_cd;

CURSOR c_gst IS
  SELECT	gst.s_graduand_status
  FROM	IGS_GR_STAT gst
  WHERE	gst.graduand_status = p_lgcy_grd_rec.graduand_status;

CURSOR c_gas IS
  SELECT	gas.s_graduand_appr_status
  FROM	IGS_GR_APRV_STAT gas
  WHERE	gas.graduand_appr_status = p_lgcy_grd_rec.graduand_appr_status;

CURSOR c_sca IS
  SELECT	sca.version_number,
  sca.course_rqrmnt_complete_ind
  FROM	IGS_EN_STDNT_PS_ATT	sca
  WHERE	sca.person_id	= P_person_id AND
  sca.course_cd	= p_lgcy_grd_rec.program_cd;

CURSOR	c_scaae
  (cp_sca_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE) IS
    SELECT	'x'
    FROM	IGS_PS_STDNT_APV_ALT	scaae
    WHERE	scaae.person_id			= p_person_id AND
                scaae.course_cd			= p_lgcy_grd_rec.program_cd AND
  		scaae.version_number		= cp_sca_version_number AND
  		scaae.exit_course_cd		= p_lgcy_grd_rec.award_program_cd AND
  		scaae.exit_version_number	= p_lgcy_grd_rec.award_prog_version_number AND
  		scaae.rqrmnts_complete_ind	= 'Y';

CURSOR c_sur_sca IS
  SELECT	'x'
  FROM	IGS_EN_STDNT_PS_ATT	sca
  WHERE	sca.person_id = p_person_id AND
  sca.course_cd = p_lgcy_grd_rec.sur_for_program_cd AND
  sca.version_number = p_lgcy_grd_rec.sur_for_prog_version_number;

CURSOR c_stu_grad_status IS
SELECT S_GRADUAND_STATUS
FROM   IGS_GR_STAT
WHERE  GRADUAND_STATUS = p_lgcy_grd_rec.graduand_status;


l_s_award_type igs_ps_awd.S_AWARD_TYPE%TYPE;
v_gst_s_graduand_status		IGS_GR_STAT.s_graduand_status%TYPE;
v_gas_s_graduand_appr_status	IGS_GR_APRV_STAT.s_graduand_appr_status%TYPE;
v_sca_version_number	IGS_EN_STDNT_PS_ATT.version_number%TYPE;
v_sca_crs_rqrmnt_ind	IGS_EN_STDNT_PS_ATT.course_rqrmnt_complete_ind%TYPE;
v_scaae_exists	VARCHAR2(1);
v_sca_exists			CHAR(1);

cst_attending	CONSTANT IGS_GR_GRADUAND.s_graduand_type%TYPE := 'ATTENDING';
cst_graduated	CONSTANT VARCHAR2(9) := 'GRADUATED';
cst_surrender	CONSTANT VARCHAR2(9) := 'SURRENDER';
cst_approved	CONSTANT VARCHAR2(8) := 'APPROVED';

l_start_dt DATE;
l_end_dt   DATE;
l_message fnd_new_messages.message_name%TYPE;
l_stu_grad_status igs_gr_stat.s_graduand_status%TYPE;


BEGIN
--1 to 7 Validates GRADUAND required details.
l_message := NULL;
IF NOT IGS_GR_VAL_GR.grdp_val_gr_rqrd(
  p_course_cd                 => p_lgcy_grd_rec.program_cd,
  p_graduand_status           => p_lgcy_grd_rec.graduand_status,
  p_s_graduand_type           => p_lgcy_grd_rec.s_graduand_type,
  p_award_course_cd           => p_lgcy_grd_rec.award_program_cd,
  p_award_crs_version_number  => p_lgcy_grd_rec.award_prog_version_number ,
  p_award_cd                  => p_lgcy_grd_rec.award_cd ,
  p_sur_for_course_cd         => p_lgcy_grd_rec.sur_for_program_cd ,
  p_sur_for_crs_version_number=> p_lgcy_grd_rec.sur_for_program_cd ,
  p_sur_for_award_cd          => p_lgcy_grd_rec.sur_for_award_cd,
  p_message_name              => l_message )THEN

    FND_MESSAGE.SET_NAME ('IGS', l_message);
    FND_MSG_PUB.ADD;
    l_return_value :=  FND_API.TO_BOOLEAN(FND_API.G_FALSE); --Continue

END IF;
--End of 1-7 Validate that the surrendering for program award can only be specified when surrendering or articulating an award

-- Validate that if the Proxy award person number is passed then
-- the proxy award person number must be a different person from that of the graduand.
  IF p_lgcy_grd_rec.proxy_award_person_number IS NOT NULL AND
     p_lgcy_grd_rec.proxy_award_person_number = p_lgcy_grd_rec.person_number THEN
    FND_MESSAGE.SET_NAME ('IGS', 'IGS_GR_PRXY_AWD_MUST_BE_DIFF');
    FND_MSG_PUB.ADD;
    l_return_value :=  FND_API.TO_BOOLEAN(FND_API.G_FALSE); --Continue
  END IF;
-- End of Validate that if the Proxy award person number is passed
-- then the proxy award person number must be a different person from that of the graduand.

--Validate that the Graduand cannot be graduated unless the graduand approval status has a system value of "APPROVED
  OPEN c_gst;
  FETCH c_gst INTO v_gst_s_graduand_status;
  CLOSE c_gst;

  OPEN c_gas;
  FETCH c_gas INTO v_gas_s_graduand_appr_status;
  CLOSE c_gas;

  IF v_gst_s_graduand_status IN (cst_graduated,cst_surrender) THEN
    IF v_gas_s_graduand_appr_status <> cst_approved THEN
      FND_MESSAGE.SET_NAME ('IGS','IGS_GR_MUST_HAVE_VALUE_APPROV');
      FND_MSG_PUB.ADD;
      l_return_value :=  FND_API.TO_BOOLEAN(FND_API.G_FALSE); --Continue
    END IF;
  END IF;
--End of Validate that the Graduand cannot be graduated unless the graduand approval status has a system value of "APPROVED

--11 Validate that if the program award code and program award version number is the same as the program code and version number then validate
  IF p_lgcy_grd_rec.program_cd IS NOT NULL AND NOT IGS_GR_VAL_GR.grdp_val_aw_eligible(
                                             p_person_id                => p_person_id,
                                             p_course_cd                => p_lgcy_grd_rec.program_cd,
                                             p_award_course_cd          => p_lgcy_grd_rec.award_program_cd               ,
                                             p_award_crs_version_number => p_lgcy_grd_rec.award_prog_version_number     ,
                                             p_award_cd                 => p_lgcy_grd_rec.award_cd,
                                             p_message_name             => l_message)  THEN

    FND_MESSAGE.SET_NAME ('IGS',l_message);
    FND_MSG_PUB.ADD;
    l_return_value :=  FND_API.TO_BOOLEAN(FND_API.G_FALSE); --Continue
  END IF;
--11 End of Validate that if the program award code and program award version number is the same as the program code and version number then validate

--12 Validate that the students are allowed to graduate from the specified program
IF NOT IGS_GR_VAL_GR.grdp_val_gr_sca(p_person_id    => p_person_id,
				     p_course_cd    => p_lgcy_grd_rec.program_cd,
				     p_message_name => l_message) THEN
  FND_MESSAGE.SET_NAME ('IGS',l_message);
  FND_MSG_PUB.ADD;
  l_return_value :=  FND_API.TO_BOOLEAN(FND_API.G_FALSE); --Continue
END IF;
--End of Validate that the students are allowed to graduate from the specified program

--13, 14 ,15 Validate that the award must be of system award type PROGRAM, HON,
--No check for special award type
IF p_lgcy_grd_rec.program_cd IS NULL THEN
  l_s_award_type := 'HONORARY';
ELSE
  l_s_award_type := 'COURSE';
END IF;

IF NOT IGS_GR_VAL_AWC.grdp_val_award_type(p_award_cd     => p_lgcy_grd_rec.award_cd,
					  p_s_award_type => l_s_award_type,
					  p_message_name => l_message) THEN
  FND_MESSAGE.SET_NAME ('IGS',l_message);
  FND_MSG_PUB.ADD;
  l_return_value :=  FND_API.TO_BOOLEAN(FND_API.G_FALSE); --Continue
END IF;
--End of 13, 14 ,15 Validate that the award must be of system award type PROGRAM, HON

--16 Validate that the graduand record program award is an award for the student program attempt or an alternative exit
IF NOT IGS_GR_VAL_GR.grdp_val_gr_caw
(
  p_person_id                => p_person_id,
  p_course_cd  	             => p_lgcy_grd_rec.program_cd,
  p_award_course_cd          => p_lgcy_grd_rec.award_program_cd,
  p_award_crs_version_number => p_lgcy_grd_rec.award_prog_version_number,
  p_award_cd  		     => p_lgcy_grd_rec.award_cd,
  p_message_name 	     => l_message
)THEN
  FND_MESSAGE.SET_NAME ('IGS',l_message);
  FND_MSG_PUB.ADD;
  l_return_value :=  FND_API.TO_BOOLEAN(FND_API.G_FALSE); --Continue
END IF;
--End of 16 Validate that the graduand record program award is an award for the student program attempt or an alternative exit

--17,18 Validate that a student cannot articulate or surrender a graduand record for the same program.
IF NOT IGS_GR_VAL_GR.GRDP_VAL_GR_SUR_CAW(
                                        p_person_id               => p_person_id                               ,
                                        p_course_cd               => p_lgcy_grd_rec.program_cd                 ,
                                        p_graduand_status         => p_lgcy_grd_rec.graduand_status            ,
                                        p_sur_for_course_cd       => p_lgcy_grd_rec.sur_for_program_cd         ,
                                        p_sur_for_crs_version_num => p_lgcy_grd_rec.sur_for_prog_version_number,
                                        p_sur_for_award_cd        => p_lgcy_grd_rec.sur_for_award_cd           ,
                                        p_message_name            => l_message) THEN

    FND_MESSAGE.SET_NAME ('IGS',l_message);
    FND_MSG_PUB.ADD;
    l_return_value :=  FND_API.TO_BOOLEAN(FND_API.G_FALSE); --Continue
END IF;
--end of 17, 18

--20
  IF p_lgcy_grd_rec.s_graduand_type  = 'ATTENDING' AND p_lgcy_grd_rec.proxy_award_person_number IS NOT NULL THEN
    FND_MESSAGE.SET_NAME ('IGS','IGS_GR_PROXY_NOT_ALLOW');
    FND_MSG_PUB.ADD;
    l_return_value :=  FND_API.TO_BOOLEAN(FND_API.G_FALSE); --Continue
  END IF;
--End of 20

RETURN l_return_value ;

END VALIDATE_GRADUANDS;


FUNCTION VALIDATE_POST_GRADUAND(
        p_lgcy_grd_rec      IN OUT NOCOPY lgcy_grd_rec_type,
	P_person_id	    IN  IGS_PE_PERSON.PERSON_ID%TYPE,
	P_cal_type	    IN  IGS_CA_INST.CAL_TYPE%TYPE,
	P_sequence_number   IN  IGS_CA_INST. SEQUENCE_NUMBER%TYPE
)RETURN BOOLEAN

/****************************************************************************************************************
  ||  Created By : msrinivi
  ||  Created On : 11-Nov-2002
  ||  Purpose    : This function validates all the business rules after
  ||               inserting a record in the table IGS_GR_GRADUAND
  ||
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/
IS

--Initialize API return status to true
l_return_value BOOLEAN := FND_API.TO_BOOLEAN(FND_API.G_TRUE);
l_message fnd_new_messages.message_name%TYPE;


BEGIN

IF NOT igs_gr_val_gr.grdp_val_gr_unique(
                   p_person_id               => p_person_id,
                   p_create_dt               => p_lgcy_grd_rec.create_dt,
                   p_grd_cal_type            => p_cal_type,
                   p_grd_ci_sequence_num     => p_sequence_number,
                   p_award_course_cd         => p_lgcy_grd_rec.award_program_cd,
                   p_award_crs_version_number=> p_lgcy_grd_rec.award_prog_version_number,
                   p_award_cd                => p_lgcy_grd_rec.award_cd,
                   p_message_name            => l_message ) THEN
    FND_MESSAGE.SET_NAME ('IGS','IGS_GR_GRAD_CR_DT_FAIL');
    FND_MSG_PUB.ADD;
    l_return_value :=  FND_API.TO_BOOLEAN(FND_API.G_FALSE);
END IF;

  RETURN l_return_value;

END VALIDATE_POST_GRADUAND;

END IGS_GR_GRD_LGCY_PUB;

/
