--------------------------------------------------------
--  DDL for Package CN_PLAN_TEXTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PLAN_TEXTS_PVT" AUTHID CURRENT_USER AS
/* $Header: cnvspts.pls 115.9 2002/11/21 21:18:55 hlchen ship $ */

TYPE plan_text_rec_type IS RECORD
  (
    PLAN_TEXT_ID        NUMBER             := NULL,
    ROLE_ID             NUMBER             := NULL,
    SEQUENCE_ID         NUMBER             := NULL,
    QUOTA_CATEGORY_ID   NUMBER             := NULL,
    TEXT_TYPE		CN_PLAN_TEXTS.TEXT_TYPE%TYPE := NULL,
    TEXT                CN_PLAN_TEXTS.TEXT%TYPE      := NULL,
    TEXT2		CN_PLAN_TEXTS.TEXT2%TYPE     := NULL,
    OBJECT_VERSION_NUMBER NUMBER	   := NULL,
    ROLE_MODEL_ID       NUMBER             := NULL
    );

TYPE plan_text_tbl_type IS
   TABLE OF plan_text_rec_type INDEX BY BINARY_INTEGER;


TYPE quota_cate_rec_type IS RECORD
  (
    QUOTA_CATE_ID       NUMBER             := NULL,
    QUOTA_NAME          VARCHAR2(80)       := NULL
  );

TYPE quota_cate_tbl_type IS
   TABLE OF quota_cate_rec_type INDEX BY BINARY_INTEGER;

-- Global variable that represent missing values.

G_MISS_PLAN_TEXT_REC  plan_text_rec_type;
G_MISS_PLAN_TEXT_TBL  plan_text_tbl_type;
G_MISS_QUOTA_CATE_REC  quota_cate_rec_type;
G_MISS_QUOTA_CATE_TBL  quota_cate_tbl_type;


-- Start of comments
--    API name        : Create_Plan_Text
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
--                      p_plan_text           IN  plan_text_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
PROCEDURE Create_Plan_Text
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_plan_text                  IN      plan_text_rec_type,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);



-- Start of comments
--      API name        : Update_Plan_Text
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
--                        p_plan_text         IN plan_text_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Update_Plan_Text
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_plan_text                   IN      plan_text_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2 );



-- Start of comments
--      API name        : Delete_Plan_Text
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
--                        p_plan_text         IN plan_text_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Delete_Plan_Text
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_plan_text                   IN      plan_text_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);



-- Start of comments
--      API name        : Get_Plan_Texts
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
--                        p_role_id           IN NUMBER
--                        p_role_model_id     IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_plan_texts        OUT     plan_text_tbl_type
--                        x_updatable         OUT     VARCHAR2(1)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Plan_Texts
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_role_id                     IN      NUMBER,
   p_role_model_id               IN      NUMBER,
   x_plan_texts                  OUT NOCOPY     plan_text_tbl_type,
   x_updatable                   OUT NOCOPY     VARCHAR2,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);


-- Start of comments
--      API name        : Get_Fixed_Quota_Cates
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
--                        p_role_id           IN NUMBER
--                        p_role_model_id     IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_quota_cates       OUT     quota_cate_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Fixed_Quota_Cates (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_role_id                     IN      NUMBER,
  p_role_model_id               IN      NUMBER,
  x_quota_cates                 OUT NOCOPY     quota_cate_tbl_type,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2);


-- Start of comments
--      API name        : Get_Var_Quota_Cates
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
--                        p_role_id           IN NUMBER
--                        p_role_model_id     IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_quota_cates       OUT     quota_cate_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Var_Quota_Cates (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_role_id                     IN      NUMBER,
  p_role_model_id               IN      NUMBER,
  x_quota_cates                 OUT NOCOPY     quota_cate_tbl_type,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2);

-- Start of comments
--      API name        : Get_Quota_Cates
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
--                        p_role_id           IN NUMBER
--                        p_role_model_id     IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_quota_cates       OUT     quota_cate_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Quota_Cates (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_role_id                     IN      NUMBER,
  p_role_model_id               IN      NUMBER,
  p_quota_cate_type             IN      VARCHAR2,
  x_quota_cates                 OUT NOCOPY     quota_cate_tbl_type,
  x_return_status               OUT NOCOPY     VARCHAR2,
  x_msg_count                   OUT NOCOPY     NUMBER,
  x_msg_data                    OUT NOCOPY     VARCHAR2);


-- Start of comments
--      API name        : Get_Role_Name
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
--                        p_role_id           IN NUMBER
--                        p_role_model_id     IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_role_name         OUT     VARCHAR2(80)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Role_Name
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_role_id                     IN      NUMBER,
   p_role_model_id               IN      NUMBER,
   x_role_name                   OUT NOCOPY     VARCHAR2,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);


-- Start of comments
--      API name        : Get_Plan_Text
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              :
--                        p_role_id           IN NUMBER Required
--                        p_text_type         IN VARCHAR2 Optional
--                        p_role_model_id     IN NUMBER Optional
--                        p_quota_category_id IN NUMBER Optional
--      Version :         Current version     1.0
--      Notes           : Returns the value of the plan text else null.
--
-- End of comments
  FUNCTION Get_Text (
     p_role_id            IN NUMBER,
     p_text_type          IN VARCHAR2,
     p_quota_category_id  IN NUMBER := NULL,
     p_role_model_id      IN NUMBER := NULL)
  RETURN VARCHAR2 ;



END CN_PLAN_TEXTS_PVT;

 

/
