--------------------------------------------------------
--  DDL for Package CN_QUOTA_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_ASSIGN_PVT" AUTHID CURRENT_USER AS
  /*$Header: cnvpnags.pls 120.5 2006/05/11 06:02:29 kjayapau ship $*/

-- quota assign
TYPE quota_assign_rec_type IS RECORD
  (
    QUOTA_ASSIGN_ID     CN_QUOTA_ASSIGNS.QUOTA_ASSIGN_ID%TYPE := CN_API.G_MISS_ID,
    QUOTA_ID		CN_QUOTA_ASSIGNS.QUOTA_ID%TYPE := CN_API.G_MISS_ID,
    COMP_PLAN_ID        CN_QUOTA_ASSIGNS.COMP_PLAN_ID%TYPE := CN_API.G_MISS_ID,
    NAME		CN_QUOTAS.NAME%TYPE := FND_API.G_MISS_CHAR,
    DESCRIPTION 	CN_QUOTAS.DESCRIPTION%TYPE := FND_API.G_MISS_CHAR,
    START_DATE		CN_QUOTAS.START_DATE%TYPE := FND_API.G_MISS_DATE,
    END_DATE		CN_QUOTAS.END_DATE%TYPE := FND_API.G_MISS_DATE,
    QUOTA_SEQUENCE      CN_QUOTA_ASSIGNS.QUOTA_SEQUENCE%TYPE := FND_API.G_MISS_NUM,
    OBJECT_VERSION_NUMBER   CN_QUOTA_ASSIGNS.OBJECT_VERSION_NUMBER%TYPE := NULL,
    ORG_ID CN_QUOTA_ASSIGNS.ORG_ID%TYPE := NULL,
    IDQ_FLAG varchar(10) := NULL
    ) ;

TYPE quota_assign_tbl_type IS
   TABLE OF quota_assign_rec_type INDEX BY BINARY_INTEGER ;

-- Global variable that represent missing values.

G_MISS_QUOTA_ASSIGN_REC  quota_assign_rec_type;
G_MISS_QUOTA_ASSIGN_REC_TB  quota_assign_tbl_type;


-- Start of comments
--    API name        : Create_Quota_Assign
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
--                      p_quota_assign	      IN  quota_assign_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
PROCEDURE Create_Quota_Assign
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_quota_assign               IN OUT NOCOPY     quota_assign_rec_type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Start of comments
--      API name        : Update_Quota_Assign
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_quota_assign         IN quota_assign_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Update_Quota_Assign
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_quota_assign                IN OUT NOCOPY  quota_assign_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2 );

-- Start of comments
--      API name        : Delete_Quota_Assign
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_quota_assign       IN quota_assign_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Delete_Quota_Assign
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_quota_assign                IN      quota_assign_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);


-- Start of comments
--      API name        : Get_Quota_Assign
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_comp_plan_id      IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_quota_assign      OUT     quota_assign_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Quota_Assign
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_comp_plan_id                IN      NUMBER,
   x_quota_assign                OUT NOCOPY     quota_assign_tbl_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);


END CN_QUOTA_ASSIGN_PVT;

 

/
