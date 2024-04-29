--------------------------------------------------------
--  DDL for Package CN_MULTI_RATE_SCHEDULES_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_MULTI_RATE_SCHEDULES_CUHK" AUTHID CURRENT_USER AS
/*$Header: cncrschs.pls 120.1 2005/06/27 19:28:19 appldev ship $*/

-- Create rate schedule and schedule dimensions
-- Select a name, a commission unit code (AMOUNT or PERCENT), and a table of rate
-- dimensions.  For each dimension assignment, select a rate dimension by its name
-- and a sequence number (counting up, starting from one).  Leave the rate schedule name
-- and object_version_number blank.  This API creates the rate schedule, assigns the
-- dimensions, and creates the appropriate set of tiers. The original object_version_number
-- is zero.  When tiers are first created their commission amounts are null.
-- They can be set using the Update_Tier API.
PROCEDURE Create_Schedule_Pre
  (p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
   p_dims_tbl                   IN      CN_MULTI_RATE_SCHEDULES_PUB.dim_assign_tbl_type :=
                                        CN_MULTI_RATE_SCHEDULES_PUB.g_miss_dim_assign_tbl,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Create_Schedule_Post
  (p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
   p_dims_tbl                   IN      CN_MULTI_RATE_SCHEDULES_PUB.dim_assign_tbl_type :=
                                        CN_MULTI_RATE_SCHEDULES_PUB.g_miss_dim_assign_tbl,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

-- Update rate schedule and schedule dimensions
-- Identify the rate schedule to pass by its original name, select a new name,
-- commission_unit_code and dimension assignment table as in the create API.
-- If the dimension assignment table is empty or not passed in, only the name and
-- commission_unit_code will be updated and the tiers are not affected.  Otherwise,
-- the table is rebuilt according to the new set of dimension assignments and the
-- tiers are re-created (resetting the commission amounts).  If all the validations
-- pass, the rate schedule is updated and its object version number is incremented.
PROCEDURE Update_Schedule_Pre
  (p_original_name              IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_new_name                   IN      CN_RATE_SCHEDULES.NAME%TYPE :=
                                        cn_api.g_miss_char,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE :=
                                        cn_api.g_miss_char,
   p_object_version_number      IN      CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE,
   p_dims_tbl                   IN      CN_MULTI_RATE_SCHEDULES_PUB.dim_assign_tbl_type :=
                                        CN_MULTI_RATE_SCHEDULES_PUB.g_miss_dim_assign_tbl,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Update_Schedule_Post
  (p_original_name              IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_new_name                   IN      CN_RATE_SCHEDULES.NAME%TYPE :=
                                        cn_api.g_miss_char,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE :=
                                        cn_api.g_miss_char,
   p_object_version_number      IN      CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE,
   p_dims_tbl                   IN      CN_MULTI_RATE_SCHEDULES_PUB.dim_assign_tbl_type :=
                                        CN_MULTI_RATE_SCHEDULES_PUB.g_miss_dim_assign_tbl,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

-- Delete rate schedule, dimension assignments, and rate tiers.
-- Identify the rate schedule to be deleted by its name.
PROCEDURE Delete_Schedule_Pre
  (p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Delete_Schedule_Post
  (p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

-- Assign a rate dimension to an existing rate schedule.  Identify the rate schedule
-- and its dimension by name.  Also give the sequence number indicating where you want
-- to insert the dimension.  If a dimension is inserted in the middle, all the existing
-- dimension assignments with equal or higher sequence number are pushed up by one sequence
-- number.
PROCEDURE Create_Dimension_Assign_Pre
  (p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_rate_dimension_name        IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_rate_dim_sequence          IN      CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Create_Dimension_Assign_Post
  (p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_rate_dimension_name        IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_rate_dim_sequence          IN      CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

-- Update a rate dimension to an existing rate schedule.  Pass in the rate schedule name
-- according to which rate schedule you wish to update, and pass in the original and
-- new dimension name according to the dimension you wish to reassign.  Finally pass in the
-- rate dimension sequence number and object_version_number.  If you do not pass in the
-- rate dimension sequence, the new dimension takes the same sequence number.
PROCEDURE Update_Dimension_Assign_Pre
  (p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_orig_rate_dim_name         IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_new_rate_dim_name          IN      CN_RATE_DIMENSIONS.NAME%TYPE := cn_api.g_miss_char,
   p_rate_dim_sequence          IN      CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE :=
                                        cn_api.g_miss_num,
   p_object_version_number      IN      CN_RATE_SCH_DIMS.OBJECT_VERSION_NUMBER%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Update_Dimension_Assign_Post
  (p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_orig_rate_dim_name         IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_new_rate_dim_name          IN      CN_RATE_DIMENSIONS.NAME%TYPE := cn_api.g_miss_char,
   p_rate_dim_sequence          IN      CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE :=
                                        cn_api.g_miss_num,
   p_object_version_number      IN      CN_RATE_SCH_DIMS.OBJECT_VERSION_NUMBER%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

-- Delete a rate dimension assignment by identifying the rate schedule and rate dimension
-- name.
PROCEDURE Delete_Dimension_Assign_Pre
  (p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_rate_dimension_name        IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Delete_Dimension_Assign_Post
  (p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_rate_dimension_name        IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

-- Update an individual rate tier by identifying the rate schedule and the set of
-- sequence numbers.  The number of values in the rate dimension tier sequence table
-- should correspond to the number of dimensions and the values should be in the
-- same order as the dimensions.
PROCEDURE Update_Rate_Pre
  (p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_tier_coordinates_tbl       IN      CN_MULTI_RATE_SCHEDULES_PUB.tier_coordinates_tbl,
   p_commission_amount          IN      CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   p_object_version_number      IN      CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Update_Rate_Post
  (p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_tier_coordinates_tbl       IN      CN_MULTI_RATE_SCHEDULES_PUB.tier_coordinates_tbl,
   p_commission_amount          IN      CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   p_object_version_number      IN      CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

-- Create a dimension
-- Choose a name, description, a unit code (AMOUNT, PERCENT, EXPRESSION or STRING), and a set
-- of tiers.  For each tier, populate value1 and value2 (except for STRING which only uses
-- value1).
PROCEDURE Create_Dimension_Pre
  (p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_description                IN      CN_RATE_DIMENSIONS.DESCRIPTION%TYPE := NULL,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE,
   p_tiers_tbl                  IN      CN_MULTI_RATE_SCHEDULES_PUB.rate_tier_tbl_type :=
                                        CN_MULTI_RATE_SCHEDULES_PUB.g_miss_rate_tier_tbl,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Create_Dimension_Post
  (p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_description                IN      CN_RATE_DIMENSIONS.DESCRIPTION%TYPE := NULL,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE,
   p_tiers_tbl                  IN      CN_MULTI_RATE_SCHEDULES_PUB.rate_tier_tbl_type :=
                                        CN_MULTI_RATE_SCHEDULES_PUB.g_miss_rate_tier_tbl,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

-- Update a dimension
-- Identify the dimension to be updated by its original name.  Select the new name,
-- description, unit code and tiers table.  If unit code and tiers table are not passed in,
-- only the name and description are updated.
PROCEDURE Update_Dimension_Pre
  (p_original_name              IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_new_name                   IN      CN_RATE_DIMENSIONS.NAME%TYPE :=
                                        cn_api.g_miss_char,
   p_description                IN      CN_RATE_DIMENSIONS.DESCRIPTION%TYPE :=
                                        cn_api.g_miss_char,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE :=
                                        cn_api.g_miss_char,
   p_tiers_tbl                  IN      CN_MULTI_RATE_SCHEDULES_PUB.rate_tier_tbl_type :=
                                        CN_MULTI_RATE_SCHEDULES_PUB.g_miss_rate_tier_tbl,
   p_object_version_number      IN      CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Update_Dimension_Post
  (p_original_name              IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_new_name                   IN      CN_RATE_DIMENSIONS.NAME%TYPE :=
                                        cn_api.g_miss_char,
   p_description                IN      CN_RATE_DIMENSIONS.DESCRIPTION%TYPE :=
                                        cn_api.g_miss_char,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE :=
                                        cn_api.g_miss_char,
   p_tiers_tbl                  IN      CN_MULTI_RATE_SCHEDULES_PUB.rate_tier_tbl_type :=
                                        CN_MULTI_RATE_SCHEDULES_PUB.g_miss_rate_tier_tbl,
   p_object_version_number      IN      CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

-- Delete a dimension
-- Pass in the name of dimension to be deleted.
PROCEDURE Delete_Dimension_Pre
  (p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Delete_Dimension_Post
  (p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

-- Create a tier for a dimension
-- Pass in the dimension name and value1 and value2 (if the type of the
-- specified dimension is STRING, value2 is not used... just pass in null).
-- Also pass in the tier sequence number.  All existing tiers with equal or higher
-- sequence numbers get pushed up by one.
PROCEDURE Create_Tier_Pre
  (p_dimension_name             IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_value1                     IN      VARCHAR2,
   p_value2                     IN      VARCHAR2,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Create_Tier_Post
  (p_dimension_name             IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_value1                     IN      VARCHAR2,
   p_value2                     IN      VARCHAR2,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

-- Update a tier for a dimension
-- Pass in the dimension name and sequence number to uniquely identify the tier.
-- Indicate the new minimum and maximum values as p_value1 and p_value2 (STRING
-- value tiers don't use p_value2).
PROCEDURE Update_Tier_Pre
  (p_dimension_name             IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   p_value1                     IN      VARCHAR2,
   p_value2                     IN      VARCHAR2,
   p_object_version_number      IN      CN_RATE_DIM_TIERS.OBJECT_VERSION_NUMBER%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Update_Tier_Post
  (p_dimension_name             IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   p_value1                     IN      VARCHAR2,
   p_value2                     IN      VARCHAR2,
   p_object_version_number      IN      CN_RATE_DIM_TIERS.OBJECT_VERSION_NUMBER%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

-- Delete a tier for a dimension
-- Pass in the dimension name and sequence number to uniquely identify the tier.
PROCEDURE Delete_Tier_Pre
  (p_dimension_name             IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   x_return_status              OUT NOCOPY    VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);
PROCEDURE Delete_Tier_Post
  (p_dimension_name             IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY    NUMBER,
   x_msg_data                   OUT NOCOPY    VARCHAR2);

END CN_MULTI_RATE_SCHEDULES_CUHK;

 

/
