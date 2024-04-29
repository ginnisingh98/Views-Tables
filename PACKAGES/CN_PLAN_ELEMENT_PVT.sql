--------------------------------------------------------
--  DDL for Package CN_PLAN_ELEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PLAN_ELEMENT_PVT" AUTHID CURRENT_USER AS
   /*$Header: cnvpes.pls 120.2.12000000.2 2007/10/08 18:25:54 rnagired ship $*/

   -- plan element
   TYPE plan_element_rec_type IS RECORD (
      quota_id                      NUMBER := NULL,
      NAME                          cn_quotas.NAME%TYPE := NULL,
      description                   cn_quotas.description%TYPE := NULL,
      quota_type_code               cn_quotas.quota_type_code%TYPE := NULL,
      target                        cn_quotas.target%TYPE := NULL,
      payment_amount                cn_quotas.payment_amount%TYPE := NULL,
      performance_goal              cn_quotas.performance_goal%TYPE := NULL,
      incentive_type_code           cn_quotas.incentive_type_code%TYPE := NULL,
      start_date                    cn_quotas.start_date%TYPE := NULL,
      end_date                      cn_quotas.end_date%TYPE := NULL,
      credit_type_id                NUMBER := NULL,
      interval_type_id              NUMBER := NULL,
      calc_formula_id               NUMBER := NULL,
      liability_account_id          NUMBER := NULL,
      expense_account_id            NUMBER := NULL,
      --clku
      liability_account_cc          VARCHAR (4000) := NULL,
      expense_account_cc            VARCHAR (4000) := NULL,
      vesting_flag                  cn_quotas.vesting_flag%TYPE := NULL,
      quota_group_code              cn_quotas.quota_group_code%TYPE := NULL,
      --clku, PAYMENT ENHANCEMENT
      payment_group_code            cn_quotas.payment_group_code%TYPE := NULL,
      --clku-n-
      attribute_category            cn_quotas.attribute_category%TYPE := NULL,
      attribute1                    cn_quotas.attribute1%TYPE := NULL,
      attribute2                    cn_quotas.attribute2%TYPE := NULL,
      attribute3                    cn_quotas.attribute3%TYPE := NULL,
      attribute4                    cn_quotas.attribute4%TYPE := NULL,
      attribute5                    cn_quotas.attribute5%TYPE := NULL,
      attribute6                    cn_quotas.attribute6%TYPE := NULL,
      attribute7                    cn_quotas.attribute7%TYPE := NULL,
      attribute8                    cn_quotas.attribute8%TYPE := NULL,
      attribute9                    cn_quotas.attribute9%TYPE := NULL,
      attribute10                   cn_quotas.attribute10%TYPE := NULL,
      attribute11                   cn_quotas.attribute11%TYPE := NULL,
      attribute12                   cn_quotas.attribute12%TYPE := NULL,
      attribute13                   cn_quotas.attribute13%TYPE := NULL,
      attribute14                   cn_quotas.attribute14%TYPE := NULL,
      attribute15                   cn_quotas.attribute15%TYPE := NULL,
      --clku-n-
      addup_from_rev_class_flag     cn_quotas.addup_from_rev_class_flag%TYPE := NULL,
      payee_assign_flag             cn_quotas.payee_assign_flag%TYPE := NULL,
      package_name                  cn_quotas.package_name%TYPE := NULL,
      object_version_number         cn_quotas.object_version_number%TYPE := NULL,
      -- r12
      org_id                        cn_quotas.org_id%TYPE := NULL,
      indirect_credit_code          cn_quotas.indirect_credit%TYPE := NULL,
      quota_status                  cn_quotas.quota_status%TYPE := NULL,
      call_type                     VARCHAR2 (30) := NULL,
      sreps_enddated_flag          cn_quotas.salesreps_enddated_flag%TYPE := NULL
   );

   TYPE plan_element_tbl_type IS TABLE OF plan_element_rec_type
      INDEX BY BINARY_INTEGER;

   -- Global variable that represent missing values.
   g_miss_plan_element_rec       plan_element_rec_type;
   g_miss_rt_quota_asgns_rec_tbl cn_plan_element_pub.rt_quota_asgns_rec_tbl_type;
   g_miss_period_quotas_rec_tbl  cn_plan_element_pub.period_quotas_rec_tbl_type;
   g_new_status                  VARCHAR2 (10) := 'NEW';
   g_updated_status              VARCHAR2 (10) := 'UPDATED';
   g_complete_status             VARCHAR2 (10) := 'COMPLETE';
   g_public_api                  VARCHAR2 (10) := 'PUBLIC_API' ;

-- Start of comments
--    API name        : is_valid_org
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      : Checks that the org_id is valid and consistent with the plan
--                      element's org id.
--    Notes           : Note text
--
-- End of comments
   FUNCTION is_valid_org (
      p_org_id                            NUMBER,
      p_quota_id                          NUMBER := NULL
   )
      RETURN BOOLEAN;

-- Start of comments
--    API name        : Create_Plan_Element
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
--                      p_plan_element        IN  plan_element_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_plan_element_id     OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE create_plan_element (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_plan_element             IN OUT NOCOPY plan_element_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Update_Plan_Element
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
--                        p_plan_element      IN plan_element_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_plan_element (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_plan_element             IN OUT NOCOPY plan_element_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Delete_Plan_Element
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
--                        p_plan_element       IN plan_element_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_plan_element (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_plan_element             IN OUT NOCOPY plan_element_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Duplicate_Plan_Element
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
   PROCEDURE duplicate_plan_element (
      p_api_version              IN       NUMBER := cn_api.g_miss_num,
      p_init_msg_list            IN       VARCHAR2 := cn_api.g_false,
      p_commit                   IN       VARCHAR2 := cn_api.g_false,
      p_validation_level         IN       NUMBER := cn_api.g_valid_level_full,
      p_quota_id                 IN       cn_quotas.quota_id%TYPE := NULL,
      x_plan_element             OUT NOCOPY plan_element_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Validate_Plan_Element
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
--                        p_plan_element       IN plan_element_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE validate_plan_element (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_action                   IN       VARCHAR2,
      p_plan_element             IN OUT NOCOPY plan_element_rec_type,
      p_old_plan_element         IN       plan_element_rec_type := NULL,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Validate_Plan_Element
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
--                        p_comp_plan_id      IN  NUMBER
--                        p_quota_id          IN  NUMBER
--                        x_status_code       OUT     VARCHAR2(30)
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE validate_plan_element (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_comp_plan_id             IN       NUMBER := NULL,
      p_quota_id                 IN       NUMBER,
      x_status_code              OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );
END cn_plan_element_pvt;

 

/
