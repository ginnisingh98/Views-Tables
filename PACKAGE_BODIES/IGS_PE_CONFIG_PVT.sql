--------------------------------------------------------
--  DDL for Package Body IGS_PE_CONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_CONFIG_PVT" AS
/* $Header: IGSPE09B.pls 120.3 2005/07/18 08:03:05 appldev ship $ */
/*************************************************************************
   Created By           :   mesriniv
   Date Created By  :   2002/02/03
   Purpose              :   To be used in Self Service Build,to check if
                        student latest info is available in the System

   Known Limitations,Enhancements or Remarks
   ENH Bug No.:
   Bug Desc   :
   Change History   :
   Who          When           What
   pkpatel       25-OCT-2002   Bug No: 2613704
                               Replaced column inst_priority_code_id with inst_priority_cd  in igs_pe_hz_parties_pkg
   pkpatel       2-DEC-2002    Bug No: 2599109
                               Added column birth_city, birth_country in the call to TBH igs_pe_hz_parties_pkg
   pkpatel      25-FEB-2003    Bug 2750800
                               Modified the Cursor cur_term_date in PROCEDURE verify_pe_info for performance tuning
   skpandey     04-JUN-2005    Bug : 4327807
 			       The parameter FELONY_CONVICTED_FLAG is added in update_row procedure of igs_pe_hz_parties_pkg package.
   mmkumar      18-JUL-2005    Party number impact, passed NULL for OSS_ORG_UNIT_CD in call to update_row of IGS_PE_HZ_PARTIES_PKG
   **********************************************************************/

   g_pkg_name   CONSTANT VARCHAR2(30) := 'PE_INFO';

  -- Returns true if the person needs to perform verification, based on user's profile setup

   PROCEDURE verify_pe_info(
                                 p_person_id          IN   NUMBER,
                                 p_api_version        IN   NUMBER  ,
                                 p_init_msg_list      IN   VARCHAR2 ,
                                 p_commit             IN   VARCHAR2 ,
                                 p_validation_level   IN   NUMBER   ,
                                 x_result             OUT NOCOPY  VARCHAR2,
                                 x_return_status      OUT NOCOPY  VARCHAR2,
                                 x_msg_count          OUT NOCOPY  NUMBER,
                                 x_msg_data           OUT NOCOPY  VARCHAR2)
  /*************************************************************************
   Created By        :  mesriniv
   Date Created  :  2002/02/03
   Purpose   :  To check if student has to update the  latest information
                        x_result is an out NOCOPY variable which will indicate whether the information returned is TRUE or FALSE and does
            the information needs to be verified.
            This pe_info_verify was a function and is now made into a procedure and the boolean of the function will
            be taken care in x_result.
            If the x_return is TRUE taht means that the STUDENT needs to verify his information again.
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who          When        What
   ssawhney                 function converted to procedure
   ssawhney     22-AUG-2002 Bug 2524217 : defaults removed in params, p_commit defaulted in spec.
   pkpatel      25-FEB-2003 Bug 2750800 : Modified the Cursor cur_term_date for performance tuning
   gmaheswa     14-Jul-2005 Bug 4327807 : Added logic for Hiding Verification page in self-service.

   **********************************************************************/

AS


--Cursor to fetch the Min Load Calendar Start Date and Max Load Calendar End Date so that the student last verified date
--and also the Load Calendar is ACTIVE and the dates lie between the start and end dates
--can be checked to lie within  the Load Calendar  Dates
CURSOR cur_term_date IS
SELECT MAX(ci.start_dt)
FROM    IGS_CA_INST_ALL ci,
        IGS_CA_TYPE     ct,
        IGS_CA_STAT     ca
WHERE   ci.cal_type = ct.cal_type
AND     ct.s_cal_cat = 'LOAD'
AND     SYSDATE BETWEEN ci.start_dt AND ci.end_dt
AND     ci.cal_status = ca.cal_status
AND     ca.s_cal_status='ACTIVE';



--Cursor to fetch the Latest Verification date for the person
CURSOR cur_verify_time IS
SELECT pe_info_verify_time
                FROM    IGS_PE_HZ_PARTIES
                WHERE party_id = p_person_id;


l_verify_mode                fnd_profile_option_values.profile_option_value%TYPE;
l_term_date                  DATE;
l_verify_time                DATE;

l_api_name          CONSTANT VARCHAR2(30)   := 'PE_INFO';
l_api_version               CONSTANT NUMBER         := 1.0;

 BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT     sp_config;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   -- default the x_result variable to true, so that if error occurs, then aslo the return status is TRUE

   x_result := 'TRUE' ;

   IF  NOT FND_API.Compatible_Api_Call(  l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name) THEN

-- if the versions of the API and the version passed are different then raise then
-- unexpected error message
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF FND_API.to_Boolean (p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

    -- API body

        --Profile is taken as Every Time Student Logs on to the SS Page
         l_verify_mode := NVL(FND_PROFILE.VALUE('IGS_PE_VERIFY_MODE'), 'E');

        IF l_verify_mode = 'E' THEN
          x_result :='TRUE';
          RETURN;
	ELSIF l_verify_mode = 'N' THEN
          -- When the profile IGS: Student Information Verify Mode / IGS_PE_VERIFY_MODE is set as No Student Verification / N,
	  -- then when navigated through the OSS Student Self-Service responsibility the Student Home page should open up directly
	  -- instead of the Student Verify My Information page.
	  x_result := 'FALSE';
	  RETURN;
        END IF;

    --If the Profile is set for Term Calendar Date or Time Difference
    --We need to get the Latest date when the STudent has verified the
    --information


        OPEN cur_verify_time;
        FETCH cur_verify_time into l_verify_time;

        CLOSE cur_verify_time;
        IF l_verify_time IS NULL THEN
             x_result :='TRUE';
         RETURN;
        END IF;

        --Profile is set for Difference Between the Sysdate and the Last Verified Date
        IF l_verify_mode = 'D' THEN


             IF (TRUNC(SYSDATE) - TRUNC(l_verify_time)) >=
                TO_NUMBER(NVL(FND_PROFILE.VALUE('IGS_PE_VERIFY_INT'), '0')) THEN

                x_result :='TRUE';
            RETURN;
             ELSE
                 x_result :='FALSE';
             RETURN;
             END IF;
        END IF;

    --Profile is set for Term Calendar check with the Last Time the Student has
    --verified the Information.
    --If the Verification date does not lie within the Term calendar then
    --Student Needs to Update the Latest Info
    --Else its not required

        IF l_verify_mode = 'T' THEN

              OPEN cur_term_date;
              FETCH cur_term_date INTO l_term_date;
              CLOSE cur_term_date;

    -- if the cursor does not retrieve any value then return TRUE

          IF l_term_date IS NULL THEN
               x_result :='TRUE';
               RETURN;
          END IF;

              IF (l_verify_time < l_term_date ) THEN
                   x_result :='TRUE';
               RETURN;
              ELSE
                x_result :='FALSE';
                RETURN;
              END IF;
        END IF;

        -- If everything is ok re
        x_result :='TRUE';
    RETURN;

   -- End of API body.


 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO sp_config;
      x_result :='TRUE';
      x_return_status := NVL(FND_API.G_RET_STS_ERROR,'E');


      FND_MSG_PUB.Count_And_Get (
                 --    p_encoded => FND_API.G_FALSE,
                     p_count => x_msg_count,
                                 p_data  => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO sp_config;
      x_result :='TRUE';
      x_return_status := NVL(FND_API.G_RET_STS_UNEXP_ERROR,'U');

      FND_MSG_PUB.Count_And_Get (
               --       p_encoded => FND_API.G_FALSE,
                      p_count => x_msg_count,
                                  p_data  => x_msg_data );

   WHEN OTHERS THEN

      ROLLBACK TO sp_config;
      x_result :='TRUE';
      x_return_status := NVL(FND_API.G_RET_STS_UNEXP_ERROR,'U');
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
                FND_MSG_PUB.Add_Exc_Msg    (G_PKG_NAME , l_api_name );
      END IF;


    --  FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
    --  FND_MESSAGE.SET_TOKEN('NAME','VERIFY_PE_INFO: '||SQLERRM);
    --  FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
                --p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

 END verify_pe_info ;



PROCEDURE set_pe_info_verify_time(
                                 p_person_id          IN   NUMBER,
                 p_api_version        IN   NUMBER  ,
                                 p_init_msg_list      IN   VARCHAR2 ,
                                 p_commit             IN   VARCHAR2 ,
                                 p_validation_level   IN   NUMBER   ,
                                 x_return_status      OUT NOCOPY  VARCHAR2,
                                 x_msg_count          OUT NOCOPY  NUMBER,
                                 x_msg_data           OUT NOCOPY  VARCHAR2
                                 )
 /*************************************************************************
   Created By        :  mesriniv
   Date Created  :  2002/02/03
   Purpose         :    To Update the Last Verified Date as
                      SYSDATE whenever Student Updates his/her latest info
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who          When        What
   ssawhney                            API standards implementation
   ssawhney      22aug2002      Bug 2524217 : defaults removed in params, p_commit defaulted in spec.
   pkpatel       25-OCT-2002    Bug No: 2613704
                                Replaced column inst_priority_code_id with inst_priority_cd  in igs_pe_hz_parties_pkg
   pkpatel       2-DEC-2002     Bug No: 2599109
                                Added column birth_city, birth_country in the call to TBH igs_pe_hz_parties_pkg

   **********************************************************************/
AS


        --Cursor to fetch the Person ID from HZ Parties to update the Latest Verification Date
        CURSOR cur_get_person IS
        SELECT rowid,hz.*
        FROM   igs_pe_hz_parties hz
        WHERE  hz.party_id =p_person_id
        FOR UPDATE OF hz.party_id NOWAIT;

        l_cur_person  cur_get_person%ROWTYPE;

l_api_name          CONSTANT VARCHAR2(30)   := 'PE_INFO';
l_api_version               CONSTANT NUMBER         := 1.0;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     sp_verify;

   IF  NOT FND_API.Compatible_Api_Call(  l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name) THEN

-- if the versions of the API and the version passed are different then raise then
-- unexpected error message
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  x_return_status := FND_API.G_RET_STS_SUCCESS;

--Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;


    --Call the HZ Parties Table Handler to Update the Verify Date
        OPEN cur_get_person;
        FETCH cur_get_person INTO l_cur_person;
        IF  cur_get_person%FOUND THEN


        igs_pe_hz_parties_pkg.update_row(
                          x_rowid                     =>l_cur_person.rowid,
                          x_party_id                  =>l_cur_person.party_id,
                          x_deceased_ind              =>l_cur_person.deceased_ind,
                          x_archive_exclusion_ind     =>l_cur_person.archive_exclusion_ind,
                          x_archive_dt                =>l_cur_person.archive_dt,
                          x_purge_exclusion_ind       =>l_cur_person.purge_exclusion_ind,
                          x_purge_dt                  =>l_cur_person.purge_dt,
                          x_oracle_username           =>l_cur_person.oracle_username,
                          x_proof_of_ins              =>l_cur_person.proof_of_ins,
                          x_proof_of_immu             =>l_cur_person.proof_of_immu,
                          x_level_of_qual             =>l_cur_person.level_of_qual ,
                          x_military_service_reg      =>l_cur_person.military_service_reg ,
                          x_veteran                   =>l_cur_person.veteran      ,
                          x_institution_cd            =>l_cur_person.institution_cd,
                          x_oi_local_institution_ind  =>l_cur_person.oi_local_institution_ind ,
                          x_oi_os_ind                 =>l_cur_person.oi_os_ind   ,
                          x_oi_govt_institution_cd    =>l_cur_person.oi_govt_institution_cd ,
                          x_oi_inst_control_type      =>l_cur_person.oi_inst_control_type,
                          x_oi_institution_type       =>l_cur_person.oi_institution_type ,
                          x_oi_institution_status     =>l_cur_person.oi_institution_status ,
                          x_ou_start_dt               =>l_cur_person.ou_start_dt   ,
                          x_ou_end_dt                 =>l_cur_person.ou_end_dt  ,
                          x_ou_member_type            =>l_cur_person.ou_member_type ,
                          x_ou_org_status             =>l_cur_person.ou_org_status ,
                          x_ou_org_type               =>l_cur_person.ou_org_type  ,
                          x_inst_org_ind              =>l_cur_person.inst_org_ind  ,
                          x_inst_priority_cd          =>l_cur_person.inst_priority_cd ,
                          x_inst_eps_code             =>l_cur_person.inst_eps_code   ,
                          x_inst_phone_country_code   =>l_cur_person.inst_phone_country_code ,
                          x_inst_phone_area_code      =>l_cur_person.inst_phone_area_code,
                          x_inst_phone_number         =>l_cur_person.inst_phone_number ,
                          x_adv_studies_classes       =>l_cur_person.adv_studies_classes  ,
                          x_honors_classes            =>l_cur_person.honors_classes   ,
                          x_class_size                =>l_cur_person.class_size  ,
                          x_sec_school_location_id    =>l_cur_person.sec_school_location_id  ,
                          x_percent_plan_higher_edu   =>l_cur_person.percent_plan_higher_edu ,
                          x_fund_authorization        =>l_cur_person.fund_authorization ,
                          x_pe_info_verify_time       =>TRUNC(SYSDATE) ,
                          x_birth_city                =>l_cur_person.birth_city ,
                          x_birth_country             =>l_cur_person.birth_country ,
			  x_oss_org_unit_cd           => NULL,
			  x_felony_convicted_flag     =>l_cur_person.felony_convicted_flag ,
                          x_mode                      =>'R'
                        );
      END IF;
            CLOSE cur_get_person;



  -- End of Updation.

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

     ROLLBACK TO sp_verify;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (--p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     ROLLBACK TO sp_verify;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get ( --p_encoded => FND_API.G_FALSE,
                         p_count => x_msg_count,
                                 p_data  => x_msg_data );

  WHEN OTHERS THEN

     ROLLBACK TO sp_verify;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
                FND_MSG_PUB.Add_Exc_Msg    (G_PKG_NAME , l_api_name );
      END IF;
      FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('NAME',' SET_PE_INFO_VERIFY_TIME: '||SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(--p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END  set_pe_info_verify_time;


END igs_pe_config_pvt;

/
