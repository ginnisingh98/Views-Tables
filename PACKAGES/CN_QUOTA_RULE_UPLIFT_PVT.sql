--------------------------------------------------------
--  DDL for Package CN_QUOTA_RULE_UPLIFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_RULE_UPLIFT_PVT" AUTHID CURRENT_USER AS
   /*$Header: cnvrluts.pls 120.2 2005/08/05 00:34:14 fmburu ship $*/

   -- quota rule uplift
   TYPE quota_rule_uplift_rec_type IS RECORD (
      org_id                        NUMBER := NULL,
      quota_rule_uplift_id          NUMBER := NULL,
      quota_rule_id                 NUMBER := NULL,
      start_date                    DATE := NULL,
      end_date                      DATE := NULL,
      payment_factor                NUMBER := NULL,
      quota_factor                  NUMBER := NULL,
      object_version_number         cn_quota_rule_uplifts.object_version_number%TYPE := NULL,
      rev_class_name                cn_quota_rules.NAME%TYPE := NULL,
      rev_class_name_old            cn_quota_rules.NAME%TYPE := NULL,
      start_date_old                cn_quota_rule_uplifts.start_date%TYPE := NULL,
      end_date_old                  cn_quota_rule_uplifts.end_date%TYPE := NULL
   );


   TYPE quota_rule_uplift_tbl_type IS TABLE OF quota_rule_uplift_rec_type
      INDEX BY BINARY_INTEGER;

-- Global variable that represent missing values.
   g_miss_quota_uplift_rec       quota_rule_uplift_rec_type;
   g_miss_quota_uplift_rec_tb    quota_rule_uplift_tbl_type;

-- Start of comments
--      API name        : Delete_Quota_Rule_Uplift
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
--                        p_quota_rule_uplift IN quota_rule_uplift_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE validate_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_action                   IN       VARCHAR2,
      p_quota_rule_uplift        IN OUT NOCOPY quota_rule_uplift_rec_type,
      p_old_quota_rule_uplift    IN       quota_rule_uplift_rec_type := g_miss_quota_uplift_rec,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--    API name        : Create_Quota_Rule_Uplift
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
--                      p_quota_rule_uplift   IN  quota_rule_uplift_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_quota_rule_uplift_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE create_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule_uplift        IN OUT NOCOPY quota_rule_uplift_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Update_Quota_Rule_Uplift
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
--                        p_quota_rule_uplift IN quota_rule_uplift_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule_uplift        IN OUT NOCOPY quota_rule_uplift_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Delete_Quota_Rule_Uplift
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
--                        p_quota_rule_uplift IN quota_rule_uplift_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule_uplift        IN OUT NOCOPY quota_rule_uplift_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

END cn_quota_rule_uplift_pvt;

 

/
