--------------------------------------------------------
--  DDL for Package CN_RATE_DIMENSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RATE_DIMENSIONS_PVT" AUTHID CURRENT_USER AS
/*$Header: cnvrdims.pls 120.2 2006/01/18 15:28:23 jxsingh ship $*/

TYPE tier_rec_type IS RECORD
  (rate_dim_tier_id      CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE := NULL,
   minimum_amount        CN_RATE_DIM_TIERS.MINIMUM_AMOUNT%TYPE,
   maximum_amount        CN_RATE_DIM_TIERS.MAXIMUM_AMOUNT%TYPE,
   min_exp_id            CN_RATE_DIM_TIERS.MIN_EXP_ID%TYPE,
   max_exp_id            CN_RATE_DIM_TIERS.MAX_EXP_ID%TYPE,
   string_value          CN_RATE_DIM_TIERS.STRING_VALUE%TYPE,
   tier_sequence         CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   object_version_number CN_RATE_DIM_TIERS.OBJECT_VERSION_NUMBER%TYPE,
   tier_description      VARCHAR2(1000));  -- tier_description is calculated

TYPE tiers_tbl_type              IS TABLE OF tier_rec_type INDEX BY BINARY_INTEGER;
TYPE parent_rate_tables_tbl_type IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;

g_miss_tiers_tbl tiers_tbl_type;

--    Notes           : Create rate dimensions and dimension tiers
--                      1) Validate dimension name (should be unique)
--                      2) Validate dim_unit_code (valid values are AMOUNT,
--                         PERCENT, STRING, EXPRESSION)
--                      3) Validate number_tier which should equal the number of
--                         tiers in p_tiers_tbl if it is not empty
--                      4) Validate dimension tiers (max_amount > min_amount)
PROCEDURE Create_Dimension
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_description                IN      CN_RATE_DIMENSIONS.DESCRIPTION%TYPE := NULL,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE,
   p_number_tier                IN      CN_RATE_DIMENSIONS.NUMBER_TIER%TYPE,
   p_tiers_tbl                  IN      tiers_tbl_type := g_miss_tiers_tbl,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE,   --new
   x_rate_dimension_id          IN OUT NOCOPY     CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE, --changed
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

--    Notes           : Update rate dimensions and dimension tiers
--                      1) Validate dimension name (should be unique)
--                      2) Validate dim_unit_code (valid values are AMOUNT,
--                         PERCENT, STRING, EXPRESSION)
--                      3) Validate number_tier which should equal the number of
--                         tiers in p_tiers_tbl if it is not empty
--                      4) Validate dimension tiers (max_amount > min_amount)
--                      5) Insert new tiers and delete obsolete tiers
--                      6) If this dimension is used in a rate table which is in
--                         turn used in a formula, then dim_unit_code
--                         can not be updated
PROCEDURE Update_Dimension
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_dimension_id          IN      CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE,
   p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_description                IN      CN_RATE_DIMENSIONS.DESCRIPTION%TYPE := NULL,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE,
   p_number_tier                IN      CN_RATE_DIMENSIONS.NUMBER_TIER%TYPE,
   p_tiers_tbl                  IN      tiers_tbl_type := g_miss_tiers_tbl,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE,   --new
   p_object_version_number      IN OUT NOCOPY CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE, --Changed
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

--    Notes           : Delete rate dimensions and dimension tiers
--                      1) If it is used in a rate table, it can not be deleted
PROCEDURE Delete_Dimension
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_dimension_id          IN      CN_RATE_DIMENSIONS.RATE_DIMENSION_ID%TYPE,
   -- R12 MOAC Changes --Start
   p_object_version_number      IN     CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE, --new
   -- R12 MOAC Changes --End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

--      Notes           : Delete dimension tiers
--                        1) If the dimension is used in a rate table, at least one
--                           tier should be left in the rate dimension
--                        2) If it is used in a rate table, delete the corresponding
--                           records in cn_sch_dim_tiers,
--                           cn_srp_rate_assigns, cn_rate_tiers, and cn_rate_dim_tiers
--                        3) update cn_rate_dimensions.number_tier
--                        4) tier_sequence is not adjusted here, users should take
--                           care of the adjustment by calling update_tier
--                        5) the other validations should be done by users also
--                           (like minimum_amount < maximum_amount, etc.)
PROCEDURE delete_tier
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_dim_tier_id           IN      CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE,
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

--      Notes           : Update dimension tiers
PROCEDURE update_tier
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_dim_tier_id           IN      CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE,
   p_rate_dimension_id          IN      CN_RATE_DIM_TIERS.RATE_DIMENSION_ID%TYPE,
   p_dim_unit_code              IN      CN_RATE_DIM_TIERS.DIM_UNIT_CODE%TYPE,
   p_minimum_amount             IN      CN_RATE_DIM_TIERS.MINIMUM_AMOUNT%TYPE := cn_api.g_miss_num,
   p_maximum_amount             IN      CN_RATE_DIM_TIERS.MAXIMUM_AMOUNT%TYPE := cn_api.g_miss_num,
   p_min_exp_id                 IN      CN_RATE_DIM_TIERS.MIN_EXP_ID%TYPE     := cn_api.g_miss_num,
   p_max_exp_id                 IN      CN_RATE_DIM_TIERS.MAX_EXP_ID%TYPE     := cn_api.g_miss_num,
   p_string_value               IN      CN_RATE_DIM_TIERS.STRING_VALUE%TYPE   := cn_api.g_miss_char,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE  := cn_api.g_miss_num,
   -- R12 MOAC Changes --Start
   p_object_version_number      IN OUT NOCOPY CN_RATE_DIM_TIERS.OBJECT_VERSION_NUMBER%TYPE,
   -- R12 MOAC Changes --End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

--      Notes           : Create dimension tiers
--                        1) If it is used in a rate table, update cn_sch_dim_tiers,
--                           cn_srp_rate_assigns, and cn_rate_tiers,
--                           and adjust cn_rate_tiers.rate_sequence
--                        2) update cn_rate_dimensions.number_tier
--                        3) tier_sequence is not adjusted here, users should do it by calling
--                           update_tier
--                        4) minimum_amount < maximum_amount
--                        5) validation of minimum_amount = previous maximum_amount should be
--                           done by users
PROCEDURE create_tier
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_dimension_id          IN      CN_RATE_DIM_TIERS.RATE_DIMENSION_ID%TYPE,
   p_dim_unit_code              IN      CN_RATE_DIM_TIERS.DIM_UNIT_CODE%TYPE,
   p_minimum_amount             IN      CN_RATE_DIM_TIERS.MINIMUM_AMOUNT%TYPE := null,
   p_maximum_amount             IN      CN_RATE_DIM_TIERS.MAXIMUM_AMOUNT%TYPE := null,
   p_min_exp_id                 IN      CN_RATE_DIM_TIERS.MIN_EXP_ID%TYPE     := null,
   p_max_exp_id                 IN      CN_RATE_DIM_TIERS.MAX_EXP_ID%TYPE     := null,
   p_string_value               IN      CN_RATE_DIM_TIERS.STRING_VALUE%TYPE   := null,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE  := null,
   -- R12 MOAC Changes --Start
   p_org_id                     IN      CN_RATE_DIM_TIERS.ORG_ID%TYPE, --new
   x_rate_dim_tier_id           IN OUT NOCOPY     CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE, --changed
   -- R12 MOAC Changes --End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );


END CN_RATE_DIMENSIONS_PVT;

 

/
