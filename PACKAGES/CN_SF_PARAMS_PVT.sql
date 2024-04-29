--------------------------------------------------------
--  DDL for Package CN_SF_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SF_PARAMS_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvprmss.pls 115.3 2002/11/21 21:15:46 hlchen ship $

TYPE cn_sf_repositories_rec_type IS RECORD
(
      REPOSITORY_ID           cn_sf_repositories.REPOSITORY_ID%TYPE := NULL,
      CONTRACT_TITLE          cn_sf_repositories.CONTRACT_TITLE%TYPE := FND_API.G_MISS_CHAR,
      TERMS_AND_CONDITIONS    cn_sf_repositories.TERMS_AND_CONDITIONS%TYPE := FND_API.G_MISS_CHAR,
      CLUB_QUAL_TEXT          cn_sf_repositories.CLUB_QUAL_TEXT%TYPE := FND_API.G_MISS_CHAR,
      APPROVER_NAME           cn_sf_repositories.APPROVER_NAME%TYPE := FND_API.G_MISS_CHAR,
      APPROVER_TITLE          cn_sf_repositories.APPROVER_TITLE%TYPE := FND_API.G_MISS_CHAR,
      APPROVER_ORG_NAME       cn_sf_repositories.APPROVER_ORG_NAME%TYPE := FND_API.G_MISS_CHAR,
      FILE_ID                 cn_sf_repositories.FILE_ID%TYPE := NULL,
      FORMU_ACTIVATED_FLAG    cn_sf_repositories.FORMU_ACTIVATED_FLAG%TYPE := FND_API.G_MISS_CHAR,
      TRANSACTION_CALENDAR_ID cn_sf_repositories.TRANSACTION_CALENDAR_ID%TYPE := NULL,
      OBJECT_VERSION_NUMBER   cn_sf_repositories.OBJECT_VERSION_NUMBER%TYPE:= FND_API.G_MISS_NUM
 ) ;

TYPE sf_repositories_tbl_type IS TABLE OF cn_sf_repositories_rec_type INDEX BY BINARY_INTEGER;


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
) ;

-- Start of comments
--    API name        : Update_Repositories
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
--                      to update rows into CN_SF_REPOSITORIES after some validations.
--
-- End of comments

PROCEDURE Update_SF_Parameters
(
   p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_sf_repositories_rec     IN  cn_sf_repositories_rec_type,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
);

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
--                      to update rows into CN_SF_REPOSITORIES after some validations.
--
-- End of comments

PROCEDURE Insert_SF_Parameters
(
   p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_sf_repositories_rec     IN  cn_sf_repositories_rec_type,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2
) ;


END CN_SF_PARAMS_PVT;

 

/
