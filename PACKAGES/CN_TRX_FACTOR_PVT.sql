--------------------------------------------------------
--  DDL for Package CN_TRX_FACTOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TRX_FACTOR_PVT" AUTHID CURRENT_USER AS
   /*$Header: cnvtxfts.pls 120.1 2005/07/11 20:35:03 appldev ship $*/

   -- trx factor
   TYPE trx_factor_rec_type IS RECORD (
      trx_factor_id                 NUMBER := NULL,
      revenue_class_id              NUMBER := NULL,
      quota_id                      NUMBER := NULL,
      quota_rule_id                 NUMBER := NULL,
      event_factor                  cn_trx_factors.event_factor%TYPE := NULL,
      trx_type                      cn_trx_factors.trx_type%TYPE := NULL,
      object_version_number         cn_trx_factors.object_version_number%TYPE := NULL,
      org_id                        cn_trx_factors.org_id%TYPE := NULL
   );

   TYPE trx_factor_tbl_type IS TABLE OF trx_factor_rec_type
      INDEX BY BINARY_INTEGER;

-- Global variable that represent missing values.
   g_miss_trx_factor_rec         trx_factor_rec_type;
   g_miss_trx_factor_rec_tb      trx_factor_tbl_type;

-- Start of comments
--    API name        : Validate_Trx_Factor
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
--                      p_trx_factor        IN  trx_factor_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_trx_factor_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE validate_trx_factor (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_action                   IN       VARCHAR2,
      p_trx_factor               IN OUT NOCOPY trx_factor_rec_type,
      p_old_trx_factor           IN       trx_factor_rec_type := g_miss_trx_factor_rec,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--    API name        : Create_Trx_Factor
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
--                      p_trx_factor        IN  trx_factor_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_trx_factor_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
   PROCEDURE create_trx_factor (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_trx_factor               IN OUT NOCOPY trx_factor_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Update_Trx_Factor
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
--                        p_trx_factor         IN trx_factor_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE update_trx_factor (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_trx_factor               IN OUT NOCOPY trx_factor_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Delete_Trx_Factor
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
--                        p_trx_factor       IN trx_factor_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE delete_trx_factor (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_trx_factor               IN OUT NOCOPY trx_factor_rec_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

-- Start of comments
--      API name        : Get_Trx_Factor
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
--                        p_quota_rule_id     IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_trx_factor         OUT     trx_factor_rec_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
   PROCEDURE get_trx_factor (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_quota_rule_id            IN       NUMBER,
      x_trx_factor               OUT NOCOPY trx_factor_tbl_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

   -- Start of comments
   --    API name        : update_trx_factors
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
   --                      p_trx_factor        IN  trx_factor_rec_type
   --    OUT             : x_return_status       OUT     VARCHAR2(1)
   --                      x_msg_count           OUT     NUMBER
   --                      x_msg_data            OUT     VARCHAR2(2000)
   --                      x_trx_factor_id        OUT     NUMBER
   --    Version :         Current version       1.0
   --    Notes           : Note text
   --
   -- End of comments
   PROCEDURE update_trx_factors (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      p_org_id                   IN       NUMBER,
      p_quota_name               IN       VARCHAR2,
      p_revenue_class_name       IN       VARCHAR2 := NULL,
      p_trx_factor_rec_tbl       IN       cn_plan_element_pub.trx_factor_rec_tbl_type,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_loading_status           OUT NOCOPY VARCHAR2
   );
END cn_trx_factor_pvt;

 

/
