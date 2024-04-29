--------------------------------------------------------
--  DDL for Package Body CN_ROLLOVER_QUOTA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ROLLOVER_QUOTA_PVT" AS
  /*$Header: cnvrqb.pls 120.0 2005/06/06 17:55:09 appldev noship $*/

G_PKG_NAME                  CONSTANT VARCHAR2(30):='CN_ROLLOVER_QUOTA_PVT';
-- Start of comments
--    API name        : Create_Rollover_Quota
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
-- End of comments
PROCEDURE Create_Rollover_Quota
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_rollover_quota               IN      rollover_quota_rec_type,
   x_rollover_quota_id            OUT NOCOPY    NUMBER,
   x_return_status              OUT   NOCOPY  VARCHAR2,
   x_msg_count                  OUT   NOCOPY  NUMBER,
   x_msg_data                   OUT   NOCOPY  VARCHAR2
 ) IS



  BEGIN
  null;
END Create_Rollover_Quota;


-- Start of comments
--      API name        : Update_Rollover_Quota
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
--                        p_rollover_quota         IN rollover_quota_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Update_Rollover_Quota
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_rollover_quota                IN      rollover_quota_rec_type,
   x_return_status               OUT NOCOPY    VARCHAR2,
   x_msg_count                   OUT NOCOPY    NUMBER,
   x_msg_data                    OUT NOCOPY    VARCHAR2
 ) IS

  BEGIN
  null;
END Update_Rollover_Quota;



-- Start of comments
--      API name        : Delete_Rollover_Quota
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
--                        p_rollover_quota      IN rollover_quota_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Delete_Rollover_Quota
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_rollover_quota                IN      rollover_quota_rec_type,
   x_return_status               OUT NOCOPY    VARCHAR2,
   x_msg_count                   OUT NOCOPY    NUMBER,
   x_msg_data                    OUT NOCOPY    VARCHAR2
 ) IS
     BEGIN
  null;
END Delete_Rollover_Quota;




END CN_ROLLOVER_QUOTA_PVT;

/
