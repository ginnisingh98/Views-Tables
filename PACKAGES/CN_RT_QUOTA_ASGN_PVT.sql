--------------------------------------------------------
--  DDL for Package CN_RT_QUOTA_ASGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RT_QUOTA_ASGN_PVT" AUTHID CURRENT_USER AS
   /*$Header: cnvrtqas.pls 120.1 2005/07/11 20:01:43 appldev ship $*/
   TYPE calc_formulas_rec_type IS RECORD (
      NAME                          cn_calc_formulas.NAME%TYPE := NULL,
      calc_formula_id               NUMBER := NULL
   );

   TYPE calc_formulas_tbl_type IS TABLE OF calc_formulas_rec_type
      INDEX BY BINARY_INTEGER;

   -- rt quota asgn
   TYPE rt_quota_asgn_rec_type IS RECORD (
      NAME                          cn_rate_schedules.NAME%TYPE := NULL,
      org_id                        NUMBER := NULL,
      rt_quota_asgn_id              NUMBER := NULL,
      quota_id                      NUMBER := NULL,
      start_date                    DATE := NULL,
      end_date                      DATE := NULL,
      rate_schedule_id              NUMBER := NULL,
      calc_formula_id               NUMBER := NULL,
      calc_formula_name             cn_calc_formulas.NAME%TYPE := NULL,
      attribute_category            cn_rt_quota_asgns.attribute_category%TYPE := NULL,
      attribute1                    cn_rt_quota_asgns.attribute1%TYPE := NULL,
      attribute2                    cn_rt_quota_asgns.attribute2%TYPE := NULL,
      attribute3                    cn_rt_quota_asgns.attribute3%TYPE := NULL,
      attribute4                    cn_rt_quota_asgns.attribute4%TYPE := NULL,
      attribute5                    cn_rt_quota_asgns.attribute5%TYPE := NULL,
      attribute6                    cn_rt_quota_asgns.attribute6%TYPE := NULL,
      attribute7                    cn_rt_quota_asgns.attribute7%TYPE := NULL,
      attribute8                    cn_rt_quota_asgns.attribute8%TYPE := NULL,
      attribute9                    cn_rt_quota_asgns.attribute9%TYPE := NULL,
      attribute10                   cn_rt_quota_asgns.attribute10%TYPE := NULL,
      attribute11                   cn_rt_quota_asgns.attribute11%TYPE := NULL,
      attribute12                   cn_rt_quota_asgns.attribute12%TYPE := NULL,
      attribute13                   cn_rt_quota_asgns.attribute13%TYPE := NULL,
      attribute14                   cn_rt_quota_asgns.attribute14%TYPE := NULL,
      attribute15                   cn_rt_quota_asgns.attribute15%TYPE := NULL,
      object_version_number         cn_rt_quota_asgns.object_version_number%TYPE := NULL,
      created_by                    cn_rt_quota_asgns.created_by%TYPE := NULL,
      creation_date                 cn_rt_quota_asgns.creation_date%TYPE := NULL,
      last_update_login             cn_rt_quota_asgns.last_update_login%TYPE := NULL,
      last_update_date              cn_rt_quota_asgns.last_update_date%TYPE := NULL,
      last_updated_by               cn_rt_quota_asgns.last_updated_by%TYPE := NULL
   );

   TYPE rt_quota_asgn_tbl_type IS TABLE OF rt_quota_asgn_rec_type
      INDEX BY BINARY_INTEGER;

-- Global variable that represent missing values.
   g_miss_rt_quota_asgn_rec      rt_quota_asgn_rec_type;
   g_miss_rt_quota_asgn_rec_tb   rt_quota_asgn_tbl_type;

-- Start of comments
--    API name        : Create_Rt_Quota_Asgn
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
--                      p_rt_quota_asgn     IN  rt_quota_asgn_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_rt_quota_asgn_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE create_rate_table_assignment (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_rt_quota_asgn            IN OUT NOCOPY rt_quota_asgn_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Update_Rt_Quota_Asgn
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
--                        p_rt_quota_asgn         IN rt_quota_asgn_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_rate_table_assignment (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_rt_quota_asgn            IN OUT NOCOPY rt_quota_asgn_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Delete_Rt_Quota_Asgn
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
--                        p_rt_quota_asgn         IN quota_asgn_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_rate_table_assignment (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_rt_quota_asgn            IN OUT NOCOPY rt_quota_asgn_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : get_formula_rate_tables
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
--                        p_quota_id      IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_rt_quota_asgn     OUT     rt_quota_asgn_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE get_formula_rate_tables (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_type                     IN       VARCHAR2 := 'FORMULA',
      p_quota_id                 IN       NUMBER,
      p_calc_formula_id          IN       NUMBER,
      x_calc_formulas            OUT NOCOPY calc_formulas_tbl_type,
      x_rate_tables              OUT NOCOPY rt_quota_asgn_tbl_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : get_formula_rate_tables
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
--                        p_quota_id      IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_rt_quota_asgn     OUT     rt_quota_asgn_tbl_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE validate_rate_table_assignment (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_action                   IN       VARCHAR2,
      p_rt_quota_asgn            IN OUT NOCOPY rt_quota_asgn_rec_type,
      p_old_rt_quota_asgn        IN       rt_quota_asgn_rec_type := g_miss_rt_quota_asgn_rec,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );
END cn_rt_quota_asgn_pvt;

 

/
