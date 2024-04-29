--------------------------------------------------------
--  DDL for Package CN_PLAN_ELEMENT_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PLAN_ELEMENT_CUHK" AUTHID CURRENT_USER AS
/* $Header: cncpes.pls 120.1 2005/06/14 19:00:50 appldev  $ */

   -- Start of Comments
-- API name   :  Create_Plan_Element_Pre
-- Type   :  Public.
-- Pre-reqs :  None.
-- Usage  :  User hook before create a plan element
-- Parameters :
-- IN   :  p_api_version            IN NUMBER      Required
--       p_init_msg_list          IN VARCHAR2    Optional
--        Default = FND_API.G_FALSE
--       p_commit             IN VARCHAR2    Optional
--            Default = FND_API.G_FALSE
--       p_validation_level       IN NUMBER      Optional
--            Default = FND_API.G_VALID_LEVEL_FULL
--       p_plan_element_rec       IN OUT         PLAN_ELEMENT_REC_TYPE
--       p_revenue_class_rec_tbl  IN OUT         REVENUE_CLASS_REC_TBL_TYPE
--       p_rev_uplift_rec_tbl     IN OUT         REV_CLASS_REC_TBL_TYPE
--       p_trx_factors_rec_tbl    IN OUT         TRX_FACTORS_REC_TBL
--                 p_rt_quota_asgns_rec_tbl IN OUT         PERIOD_QUOTAS_REC_TBL_TYPE
--                 p_period_quotas_rec_tbl  IN OUT         RT_QUOTA_ASGNS_REC_TBL_TYPE
--
-- OUT    :  x_return_status          OUT            VARCHAR2(1)
--       x_msg_count              OUT            NUMBER
--       x_msg_data             OUT            VARCHAR2(2000)
--       x_status             OUT            VARCHAR2
--
--
-- Version  :  Current version  1.0
--       Initial version  1.0
--
--
-- End of comments
--
   PROCEDURE create_plan_element_pre (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_plan_element_rec         IN OUT NOCOPY cn_plan_element_pub.plan_element_rec_type,
      p_revenue_class_rec_tbl    IN OUT NOCOPY cn_plan_element_pub.revenue_class_rec_tbl_type,
      p_rev_uplift_rec_tbl       IN OUT NOCOPY cn_plan_element_pub.rev_uplift_rec_tbl_type,
      p_trx_factor_rec_tbl       IN OUT NOCOPY cn_plan_element_pub.trx_factor_rec_tbl_type,
      p_period_quotas_rec_tbl    IN OUT NOCOPY cn_plan_element_pub.period_quotas_rec_tbl_type,
      p_rt_quota_asgns_rec_tbl   IN OUT NOCOPY cn_plan_element_pub.rt_quota_asgns_rec_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- Start of Comments
-- API name   :  Create_Plan_Element_Post
-- Type   :  Public.
-- Pre-reqs :  None.
-- Usage  :  User hook after create a plan element
-- Parameters :
-- IN   :  p_api_version            IN NUMBER      Required
--       p_init_msg_list          IN VARCHAR2    Optional
--        Default = FND_API.G_FALSE
--       p_commit             IN VARCHAR2    Optional
--            Default = FND_API.G_FALSE
--       p_validation_level       IN NUMBER      Optional
--            Default = FND_API.G_VALID_LEVEL_FULL
--       p_plan_element_rec       IN             PLAN_ELEMENT_REC_TYPE
--       p_revenue_class_rec_tbl  IN             REVENUE_CLASS_REC_TBL_TYPE
--       p_rev_uplift_rec_tbl     IN             REV_CLASS_REC_TBL_TYPE
--       p_trx_factors_rec_tbl    IN             TRX_FACTORS_REC_TBL
--                 p_rt_quota_asgns_rec_tbl IN             PERIOD_QUOTAS_REC_TBL_TYPE
--                 p_period_quotas_rec_tbl  IN             RT_QUOTA_ASGNS_REC_TBL_TYPE
--
-- OUT    :  x_return_status          OUT            VARCHAR2(1)
--       x_msg_count              OUT            NUMBER
--       x_msg_data             OUT            VARCHAR2(2000)
--       x_status             OUT            VARCHAR2
--
--
-- Version  :  Current version  1.0
--       Initial version  1.0
--
--
-- End of comments
--
   PROCEDURE create_plan_element_post (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_plan_element_rec         IN       cn_plan_element_pub.plan_element_rec_type,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type,
      p_rev_uplift_rec_tbl       IN       cn_plan_element_pub.rev_uplift_rec_tbl_type,
      p_trx_factor_rec_tbl       IN       cn_plan_element_pub.trx_factor_rec_tbl_type,
      p_period_quotas_rec_tbl    IN       cn_plan_element_pub.period_quotas_rec_tbl_type,
      p_rt_quota_asgns_rec_tbl   IN       cn_plan_element_pub.rt_quota_asgns_rec_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- Start of Comments
-- API name   :  Update_Plan_Element_Pre
-- Type   :  Public.
-- Pre-reqs :  None.
-- Usage  :  User Hook before Update a plan element
-- Parameters :
-- IN   :  p_api_version            IN NUMBER      Require
--       p_init_msg_list          IN VARCHAR2    Optional
--        Default = FND_API.G_FALSE
--       p_commit             IN VARCHAR2    Optional
--            Default = FND_API.G_FALSE
--       p_validation_level       IN NUMBER      Optional
--            Default = FND_API.G_VALID_LEVEL_FULL
--                 p_quota_name_old         IN OUT         VARCHAR2
--       p_new_plan_element_rec   IN OUT         PLAN_ELEMENT_REC_TYPE
--       p_revenue_class_rec_tbl  IN OUT         REVENUE_CLASS_REC_TBL_TYPE
--       p_rev_uplift_rec_tbl     IN OUT         REV_CLASS_REC_TBL_TYPE
--       p_trx_factors_rec_tbl    IN OUT         TRX_FACTORS_REC_TBL_TYPE
--                 p_period_quotas_rec_tbl  IN OUT         PERIOD_QUOTAS_REC_TBL_TYPE
--
-- OUT    :  x_return_status          OUT            VARCHAR2
--       x_msg_count              OUT            NUMBER
--       x_msg_data             OUT            VARCHAR2
--       x_status             OUT            VARCHAR2
--
-- Version  :  Current version  1.0
--       Initial version  1.0
--
-- End of comments
   PROCEDURE update_plan_element_pre (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_new_plan_element_rec     IN OUT NOCOPY cn_plan_element_pub.plan_element_rec_type,
      p_quota_name_old           IN OUT NOCOPY VARCHAR2,
      p_revenue_class_rec_tbl    IN OUT NOCOPY cn_plan_element_pub.revenue_class_rec_tbl_type,
      p_rev_uplift_rec_tbl       IN OUT NOCOPY cn_plan_element_pub.rev_uplift_rec_tbl_type,
      p_trx_factor_rec_tbl       IN OUT NOCOPY cn_plan_element_pub.trx_factor_rec_tbl_type,
      p_period_quotas_rec_tbl    IN OUT NOCOPY cn_plan_element_pub.period_quotas_rec_tbl_type,
      p_rt_quota_asgns_rec_tbl   IN OUT NOCOPY cn_plan_element_pub.rt_quota_asgns_rec_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- Start of Comments
-- API name   :  Update_Plan_Element_Post
-- Type   :  Public.
-- Pre-reqs :  None.
-- Usage  :  User Hook after Update a plan element
-- Parameters :
-- IN   :  p_api_version            IN NUMBER      Require
--       p_init_msg_list          IN VARCHAR2    Optional
--        Default = FND_API.G_FALSE
--       p_commit             IN VARCHAR2    Optional
--            Default = FND_API.G_FALSE
--       p_validation_level       IN NUMBER      Optional
--            Default = FND_API.G_VALID_LEVEL_FULL
--                 p_quota_name_old         IN             VARCHAR2
--       p_new_plan_element_rec   IN             PLAN_ELEMENT_REC_TYPE
--       p_revenue_class_rec_tbl  IN             REVENUE_CLASS_REC_TBL_TYPE
--       p_rev_uplift_rec_tbl     IN             REV_CLASS_REC_TBL_TYPE
--       p_trx_factors_rec_tbl    IN             TRX_FACTORS_REC_TBL_TYPE
--                 p_period_quotas_rec_tbl  IN             Optional
--
-- OUT    :  x_return_status          OUT            VARCHAR2
--       x_msg_count              OUT            NUMBER
--       x_msg_data             OUT            VARCHAR2
--       x_status             OUT            VARCHAR2
--
-- Version  :  Current version  1.0
--       Initial version  1.0
--
-- End of comments
   PROCEDURE update_plan_element_post (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_new_plan_element_rec     IN       cn_plan_element_pub.plan_element_rec_type,
      p_quota_name_old           IN       VARCHAR2,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type,
      p_rev_uplift_rec_tbl       IN       cn_plan_element_pub.rev_uplift_rec_tbl_type,
      p_trx_factor_rec_tbl       IN       cn_plan_element_pub.trx_factor_rec_tbl_type,
      p_period_quotas_rec_tbl    IN       cn_plan_element_pub.period_quotas_rec_tbl_type,
      p_rt_quota_asgns_rec_tbl   IN       cn_plan_element_pub.rt_quota_asgns_rec_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- Start of Comments
-- API name   :  Delete_Plan_Element_Pre
-- Type   :  Public.
-- Pre-reqs :  None.
-- Usage  :  User Hook before Delete a plan element
-- Parameters :
-- IN   :  p_api_version            IN  NUMBER      Require
--       p_init_msg_list          IN  VARCHAR2    Optional
--        Default = FND_API.G_FALSE
--       p_commit             IN  VARCHAR2    Optional
--            Default = FND_API.G_FALSE
--       p_validation_level       IN  NUMBER      Optional
--            Default = FND_API.G_VALID_LEVEL_FULL
--       p_quota_name             IN OUT VARCHAR2
--                 p_revenue_class_rec_tbl  IN OUT revenue_class_rec_tbl_type
--             p_rev_uplift_rec_tbl     IN OUT rev_uplift_rec_tbl_type
--             p_rt_quota_asgns_rec_tbl IN OUT rt_quota_asgns_rec_tbl_type
--
-- OUT    :  x_return_status          OUT            VARCHAR2(1)
--       x_msg_count              OUT            NUMBER
--       x_msg_data             OUT            VARCHAR2(2000)
--
-- Version  :  Current version  1.0
--       Initial version  1.0
--
-- End of comments
--
   PROCEDURE delete_plan_element_pre (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN OUT NOCOPY VARCHAR2,
      p_revenue_class_rec_tbl    IN OUT NOCOPY cn_plan_element_pub.revenue_class_rec_tbl_type,
      p_rev_uplift_rec_tbl       IN OUT NOCOPY cn_plan_element_pub.rev_uplift_rec_tbl_type,
      p_rt_quota_asgns_rec_tbl   IN OUT NOCOPY cn_plan_element_pub.rt_quota_asgns_rec_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- Start of Comments
-- API name   :  Delete_Plan_Element_Post
-- Type   :  Public.
-- Pre-reqs :  None.
-- Usage  :  User Hook after Delete a plan element
-- Parameters :
-- IN   :  p_api_version            IN  NUMBER      Require
--       p_init_msg_list          IN  VARCHAR2    Optional
--        Default = FND_API.G_FALSE
--       p_commit             IN  VARCHAR2    Optional
--            Default = FND_API.G_FALSE
--       p_validation_level       IN  NUMBER      Optional
--            Default = FND_API.G_VALID_LEVEL_FULL
--       p_quota_name             IN  VARCHAR2
--                 p_revenue_class_rec_tbl  IN  revenue_class_rec_tbl_type
--             p_rev_uplift_rec_tbl     IN  rev_uplift_rec_tbl_type
--             p_rt_quota_asgns_rec_tbl IN  rt_quota_asgns_rec_tbl_type
--
-- OUT    :  x_return_status          OUT            VARCHAR2(1)
--       x_msg_count              OUT            NUMBER
--       x_msg_data             OUT            VARCHAR2(2000)
--
-- Version  :  Current version  1.0
--       Initial version  1.0
--
-- End of comments
--
   PROCEDURE delete_plan_element_post (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type,
      p_rev_uplift_rec_tbl       IN       cn_plan_element_pub.rev_uplift_rec_tbl_type,
      p_rt_quota_asgns_rec_tbl   IN       cn_plan_element_pub.rt_quota_asgns_rec_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- Start Comments
-- API name    :  Duplicate_Plan_Element_Pre
-- Type        :  Public.
-- Pre-reqs    :  None.
-- Usage       :  User Hook before Duplicate a plan element
-- Parameters  :
-- IN          :  p_api_version       IN NUMBER      Require
--                p_init_msg_list     IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--                p_commit            IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--                p_validation_level  IN NUMBER      Optional
--                Default = FND_API.G_VALID_LEVEL_FULL
--                p_plan_element_name IN OUT         cn_quotas.name%TYPE
--
-- OUT         :  x_return_status     OUT            VARCHAR2(1)
--                x_msg_count         OUT            NUMBER
--                x_msg_data          OUT            VARCHAR2(2000)
--                x_plan_element_name IN OUT         cn_quotas.name%TYPE
--
-- Version     :  Current version   1.0
--                Initial version   1.0
--
-- End of comments
--
   PROCEDURE duplicate_plan_element_pre (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_plan_element_name        IN OUT NOCOPY cn_quotas.NAME%TYPE,
      x_plan_element_name        IN OUT NOCOPY cn_quotas.NAME%TYPE,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- Start Comments
-- API name    :  Duplicate_Plan_Element_Post
-- Type        :  Public.
-- Pre-reqs    :  None.
-- Usage       :  User Hook after Duplicate a plan element
-- Parameters  :
-- IN          :  p_api_version       IN NUMBER      Require
--                p_init_msg_list     IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--                p_commit            IN VARCHAR2    Optional
--                Default = FND_API.G_FALSE
--                p_validation_level  IN NUMBER      Optional
--                Default = FND_API.G_VALID_LEVEL_FULL
--                p_plan_element_name IN             cn_quotas.name%TYPE
--
-- OUT         :  x_return_status     OUT            VARCHAR2(1)
--                x_msg_count         OUT            NUMBER
--                x_msg_data          OUT            VARCHAR2(2000)
--                x_plan_element_name IN OUT         cn_quotas.name%TYPE
--
-- Version     :  Current version   1.0
--                Initial version   1.0
--
-- End of comments
--
   PROCEDURE duplicate_plan_element_post (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_plan_element_name        IN       cn_quotas.NAME%TYPE,
      x_plan_element_name        IN OUT NOCOPY cn_quotas.NAME%TYPE,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- Start of Comments
-- API name   :  Ok_To_Generate_Msg
-- Type   :  Public.
-- Pre-reqs :  None.
-- Usage  :  Judge whether it is ok to generate message or not
-- Parameters :
-- IN   :  p_plan_element_rec       IN             Optional
--       p_revenue_class_rec_tbl  IN             Optional
--       p_rev_uplift_rec_tbl     IN             Optional
--       p_trx_factors_rec_tbl    IN             Optional
--                 p_rt_quota_asgns_rec_tbl IN             Optional
--                 p_period_quotas_rec_tbl  IN             Optional
--                 p_plan_element_name      IN             Optional
--
-- Version  :  Current version  1.0
--       Initial version  1.0
--
--
-- End of comments
--
   FUNCTION ok_to_generate_msg (
      p_plan_element_rec         IN       cn_plan_element_pub.plan_element_rec_type := cn_plan_element_pub.g_miss_plan_element_rec,
      p_revenue_class_rec_tbl    IN       cn_plan_element_pub.revenue_class_rec_tbl_type := cn_plan_element_pub.g_miss_revenue_class_rec_tbl,
      p_rev_uplift_rec_tbl       IN       cn_plan_element_pub.rev_uplift_rec_tbl_type := cn_plan_element_pub.g_miss_rev_uplift_rec_tbl,
      p_trx_factor_rec_tbl       IN       cn_plan_element_pub.trx_factor_rec_tbl_type := cn_plan_element_pub.g_miss_trx_factor_rec_tbl,
      p_period_quotas_rec_tbl    IN       cn_plan_element_pub.period_quotas_rec_tbl_type := cn_plan_element_pub.g_miss_period_quotas_rec_tbl,
      p_rt_quota_asgns_rec_tbl   IN       cn_plan_element_pub.rt_quota_asgns_rec_tbl_type := cn_plan_element_pub.g_miss_rt_quota_asgns_rec_tbl,
      p_plan_element_name        IN       VARCHAR2 := NULL
   )
      RETURN BOOLEAN;
END cn_plan_element_cuhk;
 

/
