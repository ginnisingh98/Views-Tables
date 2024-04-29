--------------------------------------------------------
--  DDL for Package CN_MULTI_RATE_SCHEDULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_MULTI_RATE_SCHEDULES_PVT" AUTHID CURRENT_USER AS
/*$Header: cnvrschs.pls 120.10 2007/03/27 15:12:10 kkanyara ship $*/

TYPE   comm_rec_type IS RECORD (
   p_rate_sequence             CN_RATE_TIERS.RATE_SEQUENCE%TYPE,
   p_commission_amount         CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   p_object_version_number     CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE,
   p_org_id                    CN_RATE_TIERS.ORG_ID%TYPE
);


-- record type of the rate table dimensions
TYPE dim_rec_type IS RECORD
  (rate_sch_dim_id       CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE := NULL,
   rate_dimension_id     CN_RATE_SCH_DIMS.RATE_DIMENSION_ID%TYPE,
   rate_schedule_id      CN_RATE_SCH_DIMS.RATE_SCHEDULE_ID%TYPE,
   rate_dim_sequence     CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE,
   rate_dim_name         CN_RATE_DIMENSIONS.NAME%TYPE,
   number_tier           CN_RATE_DIMENSIONS.NUMBER_TIER%TYPE,
   dim_unit_code         CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE,
   object_version_number CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE);

-- record type of the rate table summary
TYPE rate_table_rec_type IS RECORD
  (rate_schedule_id      CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE,
   name                  CN_RATE_SCHEDULES.NAME%TYPE,
   type                  CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
   number_dim            CN_RATE_SCHEDULES.NUMBER_DIM%TYPE,
   object_version_number CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE);

-- record type of the plan element assignment summary
TYPE plan_elt_rec_type IS RECORD
  (quota_id              CN_RT_QUOTA_ASGNS.QUOTA_ID%TYPE,
   quota_name            CN_QUOTAS.NAME%TYPE,
   incentive_type        CN_LOOKUPS.MEANING%TYPE,
   calc_formula_id       CN_RT_QUOTA_ASGNS.CALC_FORMULA_ID%TYPE,
   formula_name          CN_CALC_FORMULAS.NAME%TYPE,
   start_date            CN_RT_QUOTA_ASGNS.START_DATE%TYPE,
   end_date              CN_RT_QUOTA_ASGNS.END_DATE%TYPE);

-- record type of the formula assignment summary
TYPE formula_rec_type IS RECORD
  (calc_formula_id       CN_RT_FORMULA_ASGNS.CALC_FORMULA_ID%TYPE,
   formula_name          CN_CALC_FORMULAS.NAME%TYPE,
   formula_type          CN_LOOKUPS.MEANING%TYPE,
   start_date            CN_RT_FORMULA_ASGNS.START_DATE%TYPE,
   end_date              CN_RT_FORMULA_ASGNS.END_DATE%TYPE);

TYPE rate_table_tbl_type IS TABLE OF rate_table_rec_type INDEX BY BINARY_INTEGER;
TYPE dims_tbl_type       IS TABLE OF dim_rec_type        INDEX BY BINARY_INTEGER;
TYPE parents_tbl_type    IS TABLE OF VARCHAR2(30)        INDEX BY BINARY_INTEGER;
TYPE num_tbl_type        IS TABLE OF NUMBER              INDEX BY BINARY_INTEGER;
TYPE plan_elt_tbl_type   IS TABLE OF plan_elt_rec_type   INDEX BY BINARY_INTEGER;
TYPE formula_tbl_type    IS TABLE OF formula_rec_type    INDEX BY BINARY_INTEGER;
TYPE comm_tbl_type       IS TABLE OF comm_rec_type       INDEX BY BINARY_INTEGER;

G_MISS_DIMS_TBL dims_tbl_type;

--    Notes           : Create rate schedule and schedule dimensions
--                      1) Validate schedule name (should be unique)
--                      2) Validate commission_unit_code (valid values are AMOUNT, PERCENT)
--                      3) Validate number_dim which should equal the number of dimensions in
--                         p_dims_tbl if it is not empty
PROCEDURE Create_Schedule
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE     ,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
   p_number_dim                 IN      CN_RATE_SCHEDULES.NUMBER_DIM%TYPE,
   p_dims_tbl                   IN      dims_tbl_type := g_miss_dims_tbl,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE,   --new
   x_rate_schedule_id           IN OUT NOCOPY     CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE, --changed
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

--    Notes           : Update rate schedule and schedule dimensions
--                      1) Validate schedule name (should be unique)
--                      2) Validate commission_unit_code (valid values are AMOUNT, PERCENT)
--                      3) Validate number_dim which should equal the number of dimensions in
--                         p_dims_tbl if it is not empty
--                      4) Insert new dimensions and delete obsolete dimensions
--                      5) Update rate tiers also
--                      6) If this rate table is used, then update of dimensions and
--                         commission_unit_code is not allowed
PROCEDURE Update_Schedule
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_id           IN      CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE,
   p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
   p_number_dim                 IN      CN_RATE_SCHEDULES.NUMBER_DIM%TYPE,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE,   --new
   p_object_version_number      IN OUT NOCOPY CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE, -- Changed
   --R12 MOAC Changes--End
   p_dims_tbl                   IN      dims_tbl_type := g_miss_dims_tbl,
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

--    Notes           : Delete rate schedule
--                      1) If it is used, it can not be deleted
--                      2) If it can be deleted, delete corresponding records in
--                         cn_rate_sch_dims and cn_rate_tiers
PROCEDURE Delete_Schedule
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_id           IN      CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE,
   --R12 MOAC Changes--Start
   p_object_version_number      IN      CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE, -- new
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

--      Notes           : Delete schedule dimension
--                        1) If the rate schedule is used, its dimensions can not be deleted
--                        2) delete the corresponding records in cn_rate_sch_dims and cn_rate_tiers
--                        3) update cn_rate_schedules.number_dim if not called from form
--                        4) rate_dim_sequence is not adjusted here, users should take
--                           care of the adjustment by calling update_dimension_assign
PROCEDURE delete_dimension_assign
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_sch_dim_id            IN      CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE,
   p_rate_schedule_id           IN      CN_RATE_SCH_DIMS.RATE_SCHEDULE_ID%TYPE,
   --R12 MOAC Changes--Start
   p_object_version_number      IN      CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE, -- new
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

--      Notes           : Update dimension assignment
--                        1) If the rate table is used, then update is not allowed
--                        2) If it can be updated, update records in cn_rate_sch_dims
--                           and cn_rate_tiers
PROCEDURE update_dimension_assign
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_sch_dim_id            IN      CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE,
   p_rate_schedule_id           IN      CN_RATE_SCH_DIMS.RATE_SCHEDULE_ID%TYPE,
   p_rate_dimension_id          IN      CN_RATE_SCH_DIMS.RATE_DIMENSION_ID%TYPE := cn_api.g_miss_num,
   p_rate_dim_sequence          IN      CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE := cn_api.g_miss_num,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE,   --new
   p_object_version_number      IN OUT NOCOPY CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE, --changed
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

--      Notes           : Create dimension assignment
--                        1) If the rate table is used, new assignment can not be created
--                        2) if the rate table is not used, update and cn_rate_tiers;
--                           and adjust cn_rate_tiers.rate_sequence
--                        3) update cn_rate_schedules.number_dim
--                        4) rate_dim_sequence is not adjusted here, users should do it by
--                           calling update_dimension_assign
PROCEDURE create_dimension_assign
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_id           IN      CN_RATE_SCH_DIMS.RATE_SCHEDULE_ID%TYPE,
   p_rate_dimension_id          IN      CN_RATE_SCH_DIMS.RATE_DIMENSION_ID%TYPE,
   p_rate_dim_sequence          IN      CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE,
   --R12 MOAC Changes--Start
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE,   --new
   x_rate_sch_dim_id            IN OUT NOCOPY     CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE, --changed
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

-- procedure to create rate tiers upon insert of rate dimension assignment or dimension tiers.
PROCEDURE create_rate_tiers
  (p_rate_schedule_id                   CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
   p_rate_dim_sequence                  CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE := NULL,
   p_tier_sequence                      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE    := NULL,
   p_num_tiers                          NUMBER := 1,
   --R12 MOAC Changes--Start
   p_org_id                         IN  CN_RATE_TIERS.ORG_ID%TYPE);
   --R12 MOAC Changes--End

-- procedure to delete rate tiers upon delete of rate dimension assignment or dimension tiers.
PROCEDURE delete_rate_tiers
  (p_rate_schedule_id                   CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
   p_rate_dim_sequence                  CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE,
   p_tier_sequence                      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE := NULL,
   p_num_tiers                          NUMBER := 1);

-- procedure to update a rate
PROCEDURE update_rate
  (p_rate_schedule_id           IN      CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
   p_rate_sequence              IN      CN_RATE_TIERS.RATE_SEQUENCE%TYPE,
   p_commission_amount          IN      CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   --R12 MOAC Changes--Start
   p_object_version_number      IN OUT NOCOPY CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE, --changed
   p_org_id                     IN      CN_RATE_TIERS.ORG_ID%TYPE --new
   --R12 MOAC Changes--End
   );

PROCEDURE update_srp_rate
  (p_srp_quota_assign_id        IN      CN_SRP_QUOTA_ASSIGNS.SRP_QUOTA_ASSIGN_ID%TYPE,
   p_rt_quota_asgn_id           IN      CN_SRP_RATE_ASSIGNS.RT_QUOTA_ASGN_ID%TYPE,
   p_rate_sequence              IN      CN_RATE_TIERS.RATE_SEQUENCE%TYPE,
   p_commission_amount          IN      CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   p_object_version_number      IN OUT NOCOPY CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE, -- changed
   --R12 MOAC Changes--Start
   p_org_id                             CN_RATE_TIERS.ORG_ID%TYPE, --new
   --R12 MOAC Changes--End
         x_return_status      OUT NOCOPY      VARCHAR2,
      x_loading_status     OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2

   );

-- utility function to get the rate_tier_id and commission amount when given the tier combination
PROCEDURE get_rate_tier_info
  (p_rate_schedule_id           IN      CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
   p_rate_dim_tier_id_tbl       IN      num_tbl_type                     ,
   x_rate_tier_id               OUT NOCOPY     CN_RATE_TIERS.RATE_TIER_ID%TYPE  ,
   x_rate_sequence              OUT NOCOPY     CN_RATE_TIERS.RATE_SEQUENCE%TYPE ,
   x_commission_amount          OUT NOCOPY     CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   x_object_version_number      OUT NOCOPY     CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE);

PROCEDURE  update_comm_rate
          (p_rate_schedule_id   IN  CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,
           x_result_tbl         IN  comm_tbl_type,
           --R12 MOAC Changes--Start
           p_org_id             IN  CN_RATE_TIERS.ORG_ID%TYPE --new
           --R12 MOAC Changes--End
           );

PROCEDURE duplicate_rate_Schedule
 (p_api_version                IN      NUMBER                          ,
  p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN      VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_name                       IN  OUT NOCOPY  CN_RATE_SCHEDULES.NAME%TYPE ,
  p_org_id                     IN     CN_RATE_SCHEDULES.ORG_ID%TYPE,   --new
     --R12 MOAC Changes--End
  p_rate_schedule_id           IN  OUT  NOCOPY CN_RATE_SCHEDULES.RATE_SCHEDULE_ID%TYPE, --changed
  p_number_dim                 IN      CN_RATE_SCHEDULES.NUMBER_DIM%TYPE,
  p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
  x_return_status              OUT NOCOPY     VARCHAR2,
  x_msg_count                  OUT NOCOPY     NUMBER,
  x_msg_data                   OUT NOCOPY     VARCHAR2

  );


FUNCTION  get_sequence(x_schedule_id CN_RATE_TIERS.RATE_SCHEDULE_ID%TYPE,sbuf varchar2)
  RETURN Number;
END CN_MULTI_RATE_SCHEDULES_PVT;

/
