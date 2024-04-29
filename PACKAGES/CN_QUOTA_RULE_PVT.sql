--------------------------------------------------------
--  DDL for Package CN_QUOTA_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_RULE_PVT" AUTHID CURRENT_USER AS
   /*$Header: cnvqtrls.pls 120.1 2005/07/11 20:01:06 appldev ship $*/

   -- quota rule
   TYPE quota_rule_rec_type IS RECORD (
      org_id                        NUMBER := NULL,
      quota_rule_id                 NUMBER := NULL,
      plan_element_name             cn_quotas.NAME%TYPE := NULL,
      revenue_class_name            cn_revenue_classes.NAME%TYPE := NULL,
      revenue_class_id              NUMBER := NULL,
      quota_id                      NUMBER := NULL,
      description                   cn_quota_rules.description%TYPE := NULL,
      target                        cn_quota_rules.target%TYPE := NULL,
      payment_amount                cn_quota_rules.payment_amount%TYPE := NULL,
      performance_goal              cn_quota_rules.performance_goal%TYPE := NULL,
      object_version_number         cn_quota_rules.object_version_number%TYPE := NULL
   );

   TYPE quota_rule_tbl_type IS TABLE OF quota_rule_rec_type
      INDEX BY BINARY_INTEGER;

-- Global variable that represent missing values.
   g_quota_rule_rec              quota_rule_rec_type;
   g_quota_rule_rec_tb           quota_rule_tbl_type;

-- Start of comments
--      API name        : validate_quota_rule
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
--                        p_quota_rule         IN quota_rule_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE validate_quota_rule (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_action                   IN       VARCHAR2,
      p_quota_rule               IN OUT NOCOPY quota_rule_rec_type,
      p_old_quota_rule           IN       quota_rule_rec_type := g_quota_rule_rec,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--    API name        : Create_Quota_Rule
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
--                      p_quota_rule         IN  quota_rule_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_quota_rule_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE create_quota_rule (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule               IN OUT NOCOPY quota_rule_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--    API name        : Create_Quota_Rules
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
--                      p_revenue_class_rec_tbl         IN  quota_rule_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_quota_rule_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments

   PROCEDURE create_quota_rules (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type := cn_plan_element_pub.g_miss_revenue_class_rec_tbl,
      p_rev_uplift_rec_tbl       IN       cn_plan_element_pub.rev_uplift_rec_tbl_type := cn_plan_element_pub.g_miss_rev_uplift_rec_tbl,
      p_trx_factor_rec_tbl       IN       cn_plan_element_pub.trx_factor_rec_tbl_type := cn_plan_element_pub.g_miss_trx_factor_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   ) ;

-- Start of comments
--      API name        : Update_Quota_Rule
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
--                        p_quota_rule         IN quota_rule_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_quota_rule (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule               IN OUT NOCOPY quota_rule_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Update_Quota_Rules
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
--                        p_quota_rule         IN quota_rule_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_quota_rules (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type := cn_plan_element_pub.g_miss_revenue_class_rec_tbl,
      p_trx_factor_rec_tbl       IN       cn_plan_element_pub.trx_factor_rec_tbl_type := cn_plan_element_pub.g_miss_trx_factor_rec_tbl,
      x_loading_status           OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Delete_Quota_Rule
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
--                        p_quota_rule       IN quota_rule_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_quota_rule (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule               IN OUT NOCOPY quota_rule_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Delete_Quota_Rules
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
--                        p_revenue_class_rec_tbl       IN cn_plan_element_pub.revenue_class_rec_tbl_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_quota_rules (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   ) ;

END cn_quota_rule_pvt;

 

/
