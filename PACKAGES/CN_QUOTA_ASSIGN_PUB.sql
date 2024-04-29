--------------------------------------------------------
--  DDL for Package CN_QUOTA_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_ASSIGN_PUB" AUTHID CURRENT_USER AS
  /*$Header: cnpqtass.pls 120.3 2005/11/08 03:23:17 kjayapau noship $*/

TYPE quota_assign_rec_type IS RECORD
  (
    COMP_PLAN_NAME      CN_COMP_PLANS.NAME%TYPE := FND_API.G_MISS_CHAR,
    QUOTA_NAME		CN_QUOTAS.NAME%TYPE := FND_API.G_MISS_CHAR,
    QUOTA_SEQUENCE      CN_QUOTA_ASSIGNS.QUOTA_SEQUENCE%TYPE := FND_API.G_MISS_NUM,
    ORG_ID		CN_QUOTAS.ORG_ID%TYPE,
    OLD_QUOTA_NAME	CN_QUOTAS.NAME%TYPE := FND_API.G_MISS_CHAR
    );

-- Start of comments
--    API name        : Create_Quota_Assign
--    Type            : Public
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
--                      p_quota_assign_rec    IN  quota_assign_rec_type
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count                     OUT     NUMBER
--                      x_msg_data                      OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : None
--
-- End of comments
PROCEDURE Create_Quota_Assign
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level            IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                            ,
  p_quota_assign_rec            IN      quota_assign_rec_type           ,
  x_return_status               OUT NOCOPY    VARCHAR2                        ,
  x_msg_count                   OUT NOCOPY    NUMBER                          ,
  x_msg_data                    OUT NOCOPY    VARCHAR2                        );

-- Start of comments
--      API name      : Update_Quota_Assign
--      Type          : Public
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version       IN NUMBER       Required
--                      p_init_msg_list     IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit            IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level  IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_quota_assign_rec  IN  quota_assign_rec_type
--      OUT           : x_return_status     OUT     VARCHAR2(1)
--                      x_msg_count         OUT     NUMBER
--                      x_msg_data          OUT     VARCHAR2(2000)
--      Version :       Current version       1.0
--                      Initial version       1.0
--
--      Notes         : Note text
--
-- End of comments
PROCEDURE Update_Quota_Assign
  (p_api_version                  IN      NUMBER                          ,
   p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level              IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                              ,
  p_quota_assign_rec              IN      quota_assign_rec_type           ,
  x_return_status                 OUT NOCOPY    VARCHAR2                        ,
  x_msg_count                     OUT NOCOPY    NUMBER                          ,
  x_msg_data                      OUT NOCOPY    VARCHAR2                        );

-- Start of comments
--      API name      : Delete_Quota_Assign
--      Type          : Public
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version       IN NUMBER       Required
--                      p_init_msg_list     IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit            IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level  IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_quota_assign_rec  IN  quota_assign_rec_type
--      OUT           : x_return_status     OUT     VARCHAR2(1)
--                      x_msg_count         OUT     NUMBER
--                      x_msg_data          OUT     VARCHAR2(2000)
--      Version :       Current version       1.0
--                      Initial version       1.0
--
--      Notes         : Note text
--
-- End of comments
PROCEDURE Delete_Quota_Assign
  (p_api_version                  IN      NUMBER                          ,
   p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE     ,
  p_validation_level              IN      NUMBER  :=
  FND_API.G_VALID_LEVEL_FULL                                              ,
  p_quota_assign_rec              IN      quota_assign_rec_type           ,
  x_return_status                 OUT NOCOPY    VARCHAR2                        ,
  x_msg_count                     OUT NOCOPY    NUMBER                          ,
  x_msg_data                      OUT NOCOPY    VARCHAR2                        );

END CN_QUOTA_ASSIGN_PUB;

 

/
