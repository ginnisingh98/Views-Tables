--------------------------------------------------------
--  DDL for Package CN_PRD_QUOTA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PRD_QUOTA_PVT" AUTHID CURRENT_USER AS
   /*$Header: cnvpedqs.pls 120.2 2005/07/20 19:08:48 fmburu ship $*/

   -- period quota
   TYPE prd_quota_rec_type IS RECORD (
      period_quota_id               NUMBER := NULL,
      period_id                     NUMBER := NULL,
      period_name                   cn_period_statuses.period_name%TYPE := NULL,
      quota_id                      NUMBER := NULL,
      period_target                 NUMBER := NULL,
      itd_target                    NUMBER := NULL,
      period_payment                NUMBER := NULL,
      itd_payment                   NUMBER := NULL,
      quarter_num                   NUMBER := NULL,
      period_year                   NUMBER := NULL,
      org_id                        NUMBER := NULL,
      performance_goal              NUMBER := NULL,
      performance_goal_itd          NUMBER := NULL,
      period_target_tot             NUMBER := NULL,
      period_payment_tot            NUMBER := NULL,
      performance_goal_tot          NUMBER := NULL,
      period_target_pct             NUMBER := NULL,
      period_payment_pct            NUMBER := NULL,
      performance_goal_pct          NUMBER := NULL,
      created_by                    cn_period_quotas.created_by%TYPE := NULL,
      creation_date                 cn_period_quotas.creation_date%TYPE := NULL,
      last_update_login             cn_period_quotas.last_update_login%TYPE := NULL,
      last_update_date              cn_period_quotas.last_update_date%TYPE := NULL,
      last_updated_by               cn_period_quotas.last_updated_by%TYPE := NULL,
      object_version_number         cn_period_quotas.object_version_number%TYPE := NULL
   );

   TYPE prd_quota_tbl_type IS TABLE OF prd_quota_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE prd_quota_q_rec_type IS RECORD (
      quota_id                      NUMBER := NULL,
      period_target                 NUMBER := NULL,
      period_payment                NUMBER := NULL,
      quarter_num                   NUMBER := NULL,
      period_year                   NUMBER := NULL,
      performance_goal              NUMBER := NULL,
      period_target_tot             NUMBER := NULL,
      period_payment_tot            NUMBER := NULL,
      performance_goal_tot          NUMBER := NULL,
      period_target_pct             NUMBER := NULL,
      period_payment_pct            NUMBER := NULL,
      performance_goal_pct          NUMBER := NULL
   );

   TYPE prd_quota_q_tbl_type IS TABLE OF prd_quota_q_rec_type
      INDEX BY BINARY_INTEGER;

   TYPE prd_quota_year_rec_type IS RECORD (
      quota_id                      NUMBER := NULL,
      period_target                 NUMBER := NULL,
      period_payment                NUMBER := NULL,
      performance_goal              NUMBER := NULL,
      period_year                   NUMBER := NULL,
      period_target_tot             NUMBER := NULL,
      period_payment_tot            NUMBER := NULL,
      performance_goal_tot          NUMBER := NULL,
      period_target_pct             NUMBER := NULL,
      period_payment_pct            NUMBER := NULL,
      performance_goal_pct          NUMBER := NULL
   );

   TYPE prd_quota_year_tbl_type IS TABLE OF prd_quota_year_rec_type
      INDEX BY BINARY_INTEGER;

-- Global variable that represent missing values.
   g_miss_prd_quota_rec          prd_quota_rec_type;
   g_miss_prd_quota_rec_tb       prd_quota_tbl_type;
   g_miss_prd_quota_q_rec        prd_quota_q_rec_type;
   g_miss_prd_quota_q_rec_tb     prd_quota_q_tbl_type;
   g_miss_prd_quota_year_rec     prd_quota_year_rec_type;
   g_miss_prd_quota_year_rec_tb  prd_quota_year_tbl_type;

-- Start of comments
--      API name        : Update_PRD_QUOTA
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
--                        p_prd_quota         IN prd_quota_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_period_quota (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_prd_quota                IN OUT NOCOPY prd_quota_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

END cn_prd_quota_pvt;

 

/
