--------------------------------------------------------
--  DDL for Package Body CN_SF_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SF_PARAMS_PVT" AS
-- $Header: cnvprmsb.pls 115.3 2002/11/21 21:15:43 hlchen ship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'cn_sf_params_pvt';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvprmsb.pls';


-- Start of comments
--    API name        : Get_SF_Parameters
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--    OUT             : p_sf_repositories_rec   OUT     cn_sf_repositories_rec_type
--                      x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure uses the table handler CN_SF_PARAMS_PKG
--                      to get parameters from CN_SF_REPOSITORIES.
--
-- End of comments

PROCEDURE Get_SF_Parameters
(
   p_api_version             IN     NUMBER,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_sf_param_rec            OUT NOCOPY  cn_sf_repositories_rec_type,
   x_return_status           OUT NOCOPY    VARCHAR2,
   x_msg_count               OUT NOCOPY    NUMBER,
   x_msg_data                OUT NOCOPY    VARCHAR2
) IS

-- local variables
    l_api_name CONSTANT VARCHAR2(30) := 'Insert_SF_Parameters' ;
    l_api_version CONSTANT NUMBER := 1.0 ;
    l_validation_status VARCHAR2(30) ;
    l_return_status VARCHAR2(1);
    l_error_code NUMBER ;

BEGIN
   -- show that the update is starting
   --DBMS_OUTPUT.PUT_LINE('Inserting.....');

   -- start of the API savepoint
   SAVEPOINT Get_SF_Parameters_svp ;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   l_validation_status := 'INVALID';

   -- BEGINING OF API  BODY ----


   -- Beginning of validation code -----

   -- End of validation code -----

   SELECT REPOSITORY_ID,CONTRACT_TITLE ,TERMS_AND_CONDITIONS ,
          CLUB_QUAL_TEXT ,APPROVER_NAME ,APPROVER_TITLE ,
          APPROVER_ORG_NAME ,FILE_ID,FORMU_ACTIVATED_FLAG,
          TRANSACTION_CALENDAR_ID,OBJECT_VERSION_NUMBER
   INTO   p_sf_param_rec.REPOSITORY_ID, p_sf_param_rec.CONTRACT_TITLE ,
          p_sf_param_rec.TERMS_AND_CONDITIONS ,p_sf_param_rec.CLUB_QUAL_TEXT ,
          p_sf_param_rec.APPROVER_NAME , p_sf_param_rec.APPROVER_TITLE ,
          p_sf_param_rec.APPROVER_ORG_NAME , p_sf_param_rec.FILE_ID,
          p_sf_param_rec.FORMU_ACTIVATED_FLAG, p_sf_param_rec.TRANSACTION_CALENDAR_ID,
          p_sf_param_rec.OBJECT_VERSION_NUMBER
   FROM CN_SF_REPOSITORIES;

   --DBMS_OUTPUT.PUT_LINE('Getting complete.');
   -- END OF API BODY ---
   << end_Get_SF_Parameters >>
   NULL;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_SF_Parameters_svp ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_SF_Parameters_svp ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      	(
      	 p_count   =>  x_msg_count ,
      	 p_data    =>  x_msg_data   ,
      	 p_encoded => FND_API.G_FALSE
      	 );

  WHEN OTHERS THEN
      ROLLBACK TO Get_SF_Parameters_svp ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_code := SQLCODE;
      IF l_error_code = -54 THEN
 	   x_return_status := FND_API.G_RET_STS_ERROR ;
   	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_LOCK_FAIL');
	    FND_MSG_PUB.Add;
	   END IF;
       ELSE
	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	   END IF;
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

END Get_SF_Parameters ;



-- Start of comments
--    API name        : Update_SF_Parameters
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_seasonalities_rec_type  IN      seasonalities_rec_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure uses the table handler CN_SEAS_SCHEDULES_PKG
--                      to update rows into CN_SEAS_SCHEDULES after some validations.
--
-- End of comments


PROCEDURE Update_SF_Parameters
(
   p_api_version             IN     NUMBER,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_sf_repositories_rec     IN  cn_sf_repositories_rec_type,
   x_return_status           OUT NOCOPY    VARCHAR2,
   x_msg_count               OUT NOCOPY    NUMBER,
   x_msg_data                OUT NOCOPY    VARCHAR2
) IS

-- local variables
    l_api_name CONSTANT VARCHAR2(30) := 'Update_Repository' ;
    l_api_version CONSTANT NUMBER := 1.0 ;
    l_error_code NUMBER ;
    l_rec cn_sf_repositories_rec_type ;
    l_validation_status VARCHAR2(30) ;
    l_return_status VARCHAR2(1);
    l_count NUMBER ;

BEGIN
   -- show that the update is starting
   --DBMS_OUTPUT.PUT_LINE('Update in progress');

   -- start of the API savepoint
   SAVEPOINT Update_SF_Parameters_svp ;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   l_validation_status := 'INVALID';
/*
   SELECT Count(*)
   INTO l_count
   FROM CN_SF_REPOSITORIES ;

  IF l_count > 0 THEN
     FND_MESSAGE.SET_NAME ('CN' , 'CN_RECORD_CHANGED');
	 FND_MSG_PUB.Add;
     RAISE fnd_api.g_exc_error ;
   END IF;
 */
   -- BEGINING OF API  BODY ----


   -- Beginning of validation code -----

   -- End of validation code -----

   CN_SF_PARAMS_pkg.update_row
    (
        P_REPOSITORY_ID          =>  p_sf_repositories_rec.REPOSITORY_ID,
        P_CONTRACT_TITLE         =>  p_sf_repositories_rec.CONTRACT_TITLE,
        P_TERMS_AND_CONDITIONS   =>  p_sf_repositories_rec.TERMS_AND_CONDITIONS,
        P_CLUB_QUAL_TEXT         =>  p_sf_repositories_rec.CLUB_QUAL_TEXT,
        P_APPROVER_NAME          =>  p_sf_repositories_rec.APPROVER_NAME,
        P_APPROVER_TITLE         =>  p_sf_repositories_rec.APPROVER_TITLE,
        P_APPROVER_ORG_NAME      =>  p_sf_repositories_rec.APPROVER_ORG_NAME,
        P_FILE_ID                =>  p_sf_repositories_rec.FILE_ID,
        P_FORMU_ACTIVATED_FLAG   =>  p_sf_repositories_rec.FORMU_ACTIVATED_FLAG,
        P_TRANSACTION_CALENDAR_ID => p_sf_repositories_rec.TRANSACTION_CALENDAR_ID,
        P_OBJECT_VERSION_NUMBER => p_sf_repositories_rec.OBJECT_VERSION_NUMBER
    );


   --DBMS_OUTPUT.PUT_LINE('Update complete.');
   -- END OF API BODY ---
   << end_Update_SF_Parameters >>
   NULL;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_SF_Parameters_svp ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_SF_Parameters_svp ;
      --DBMS_OUTPUT.PUT_LINE('Update Error : Unexpected ');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      	(
      	 p_count   =>  x_msg_count ,
      	 p_data    =>  x_msg_data   ,
      	 p_encoded => FND_API.G_FALSE
      	 );

  WHEN OTHERS THEN
      ROLLBACK TO Update_SF_Parameters_svp ;
      --DBMS_OUTPUT.PUT_LINE('Update Error : Unexpected Others.');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      l_error_code := SQLCODE;
      IF l_error_code = -54 THEN
 	   x_return_status := FND_API.G_RET_STS_ERROR ;
   	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_LOCK_FAIL');
	    FND_MSG_PUB.Add;
	   END IF;
       ELSE
	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	   END IF;
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

END Update_SF_Parameters ;







-- Start of comments
--    API name        : Insert_SF_Parameters
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_sf_repositories_rec  IN      cn_sf_repositories_rec_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--    Version :         Current version       1.0
--
--
--
--    Notes           : This procedure uses the table handler CN_SF_PARAMS_PKG
--                      to insert a row into CN_SF_REPOSITORIES after some validations.
--
-- End of comments

PROCEDURE Insert_SF_Parameters
(
   p_api_version             IN     NUMBER,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_sf_repositories_rec     IN  cn_sf_repositories_rec_type,
   x_return_status           OUT NOCOPY    VARCHAR2,
   x_msg_count               OUT NOCOPY    NUMBER,
   x_msg_data                OUT NOCOPY    VARCHAR2
) IS

-- local variables
    l_api_name CONSTANT VARCHAR2(30) := 'Insert_SF_Parameters' ;
    l_api_version CONSTANT NUMBER := 1.0 ;
    l_validation_status VARCHAR2(30) ;
    l_return_status VARCHAR2(1);
    l_error_code NUMBER ;
    l_count NUMBER ;
BEGIN
   -- show that the update is starting
   --DBMS_OUTPUT.PUT_LINE('Inserting.....');

   -- start of the API savepoint
   SAVEPOINT Insert_SF_Parameters_svp ;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   l_validation_status := 'INVALID';

   -- BEGINING OF API  BODY ----


   -- Beginning of validation code -----
   SELECT Count(*)
   INTO l_count
   FROM CN_SF_REPOSITORIES ;

   IF l_count > 0 THEN
     FND_MESSAGE.SET_NAME ('CN' , 'CN_SF_RECORD_EXISTS');
	 FND_MSG_PUB.Add;
     RAISE fnd_api.g_exc_error ;
   END IF;


   -- End of validation code -----

   CN_SF_PARAMS_pkg.insert_row
    (
        P_REPOSITORY_ID          =>  p_sf_repositories_rec.REPOSITORY_ID,
        P_CONTRACT_TITLE         =>  p_sf_repositories_rec.CONTRACT_TITLE,
        P_TERMS_AND_CONDITIONS   =>  p_sf_repositories_rec.TERMS_AND_CONDITIONS,
        P_CLUB_QUAL_TEXT         =>  p_sf_repositories_rec.CLUB_QUAL_TEXT,
        P_APPROVER_NAME          =>  p_sf_repositories_rec.APPROVER_NAME,
        P_APPROVER_TITLE         =>  p_sf_repositories_rec.APPROVER_TITLE,
        P_APPROVER_ORG_NAME      =>  p_sf_repositories_rec.APPROVER_ORG_NAME,
        P_FILE_ID                =>  p_sf_repositories_rec.FILE_ID,
        P_FORMU_ACTIVATED_FLAG   =>  p_sf_repositories_rec.FORMU_ACTIVATED_FLAG,
        P_TRANSACTION_CALENDAR_ID => p_sf_repositories_rec.TRANSACTION_CALENDAR_ID
    );


   --DBMS_OUTPUT.PUT_LINE('Insert complete.');
   -- END OF API BODY ---
   << end_Insert_SF_Parameters >>
   NULL;

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Insert_SF_Parameters_svp ;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Insert_SF_Parameters_svp ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      	(
      	 p_count   =>  x_msg_count ,
      	 p_data    =>  x_msg_data   ,
      	 p_encoded => FND_API.G_FALSE
      	 );

  WHEN OTHERS THEN
      ROLLBACK TO Insert_SF_Parameters_svp ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_code := SQLCODE;
      IF l_error_code = -54 THEN
 	   x_return_status := FND_API.G_RET_STS_ERROR ;
   	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_LOCK_FAIL');
	    FND_MSG_PUB.Add;
	   END IF;
       ELSE
	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	   END IF;
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

END Insert_SF_Parameters ;


END CN_SF_PARAMS_PVT;

/
