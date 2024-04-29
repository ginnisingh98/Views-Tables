--------------------------------------------------------
--  DDL for Package CN_QUOTA_RULE_UPLIFTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_RULE_UPLIFTS_GRP" AUTHID CURRENT_USER AS
/* $Header: cnxgqrus.pls 120.2 2005/09/09 17:57:56 sbadami ship $ */
   TYPE uplift_date_seq_rec_type IS RECORD (
      start_date                    cn_quota_rule_uplifts.start_date%TYPE := NULL,
      start_date_old                cn_quota_rule_uplifts.start_date%TYPE := NULL,
      end_date                      cn_quota_rule_uplifts.end_date%TYPE := NULL,
      end_date_old                  cn_quota_rule_uplifts.end_date%TYPE := NULL,
      quota_rule_id                 cn_quota_rule_uplifts.quota_rule_id%TYPE := NULL,
      quota_rule_uplift_id          cn_quota_rule_uplifts.quota_rule_uplift_id%TYPE := NULL
   );

--
-- User Defined Quota Rules Record Table Type
--
   TYPE uplift_date_seq_rec_tbl_type IS TABLE OF uplift_date_seq_rec_type
      INDEX BY BINARY_INTEGER;

   g_miss_uplift_date_seq_rec_tbl uplift_date_seq_rec_tbl_type;

-- API name    : Create_Quota_Rule_uplifts
-- Type  : Group.
-- Pre-reqs : None.
-- Usage : Used to create entry into cn_quota_rule_uplifts
--
-- Desc  group package can be called from any where from the oracle apps
--            currenly it is called from oracle forms and the public package
--            Plan Element public package
-- Parameters  :
-- IN    :  p_api_version       IN  NUMBER      Required
--          p_init_msg_list     IN  VARCHAR2    Optional
--             Default = FND_API.G_FALSE
--          p_commit           IN VARCHAR2    Optional
--              Default = FND_API.G_FALSE
--          p_validation_level  IN  NUMBER      Optional
--              Default = FND_API.G_VALID_LEVEL_FULL
-- OUT      :  x_return_status     OUT VARCHAR2(1)
--          x_msg_count    OUT   NUMBER
--          x_msg_data           OUT   VARCHAR2(2000)
-- OUT      :  x_loading_status    OUT VARCHAR2(50)
--                 Detailed error code returned from procedure.
-- IN    :  p_quota_name         IN       Required
-- IN    :  p_rev_uplift_rec_tbl   IN        Optional
--       cn_plan_element_pub.g_miss_rev_uplift_rec_tbl

   -- Version  : Current version 1.0
--      Initial version    1.0
--
-- Notes : Note text
--
-- End of comments
   PROCEDURE create_quota_rule_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_rev_uplift_rec_tbl       IN OUT NOCOPY cn_quota_rule_uplift_pvt.quota_rule_uplift_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- API name    : Update_Quota_Rule_uplifts
-- Type     : Group.
-- Pre-reqs : None.
-- Usage : Used to update the cn_quota_rule_uplifts
--
-- Desc
--
-- Parameters  :
-- IN    :  p_api_version       IN  NUMBER      Required
--          p_init_msg_list     IN  VARCHAR2    Optional
--             Default = FND_API.G_FALSE
--          p_commit           IN VARCHAR2    Optional
--              Default = FND_API.G_FALSE
--          p_validation_level  IN  NUMBER      Optional
--              Default = FND_API.G_VALID_LEVEL_FULL
-- OUT      :  x_return_status     OUT VARCHAR2(1)
--          x_msg_count    OUT   NUMBER
--          x_msg_data            OUT  VARCHAR2(2000)
-- OUT      :  x_loading_status     OUT VARCHAR2(50)
--                 Detailed error code returned from procedure.
-- IN    :  p_quota_name          IN         Required
-- IN    :  p_rev_uplift_rec_tbl  IN         Optional
--       cn_plan_element_pub.g_miss_rev_uplift_rec_tbl

   -- Version  : Current version 1.0
--      Initial version    1.0
--
-- Notes : Note text
--
-- End of comments
   PROCEDURE update_quota_rule_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_rev_uplift_rec_tbl       IN OUT NOCOPY cn_quota_rule_uplift_pvt.quota_rule_uplift_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   );

-- API name    : Delete_Quota_Rule_uplifts
-- Type     : Group.
-- Pre-reqs : None.
-- Usage : Used to delete a record from cn_quota_rule_uplifts
--
-- Desc
--
-- Parameters  :
-- IN    :  p_api_version       IN  NUMBER      Required
--          p_init_msg_list     IN  VARCHAR2    Optional
--             Default = FND_API.G_FALSE
--          p_commit           IN VARCHAR2    Optional
--              Default = FND_API.G_FALSE
--          p_validation_level  IN  NUMBER      Optional
--              Default = FND_API.G_VALID_LEVEL_FULL
-- OUT      :  x_return_status     OUT VARCHAR2(1)
--          x_msg_count    OUT   NUMBER
--          x_msg_data            OUT  VARCHAR2(2000)
-- OUT      :  x_loading_status     OUT VARCHAR2(50)
--                 Detailed error code returned from procedure.
-- IN    :  p_quota_name          IN         Required
-- IN    :  p_rev_uplift_rec_tbl  IN         Optional
--       cn_plan_element_pub.g_miss_rev_uplift_rec_tbl

   -- Version  : Current version 1.0
--      Initial version    1.0
--
-- Notes : Note text
--
-- End of comments
   PROCEDURE delete_quota_rule_uplift (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_quota_name               IN       VARCHAR2,
      p_rev_uplift_rec_tbl       IN OUT NOCOPY cn_quota_rule_uplift_pvt.quota_rule_uplift_tbl_type,
      x_loading_status           OUT NOCOPY VARCHAR2
   );
END cn_quota_rule_uplifts_grp;
 

/
