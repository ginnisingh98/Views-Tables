--------------------------------------------------------
--  DDL for Package CN_MULTI_RATE_SCHEDULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_MULTI_RATE_SCHEDULES_PUB" AUTHID CURRENT_USER AS
/*$Header: cnprschs.pls 120.2 2005/11/07 16:55:34 jxsingh noship $*/
/*#
 * This package is used to perform the following procedures related to rate tables.
 * Create Schedule
 * Update Schedule
 * Delete Schedule
 * Create Dimension Assign
 * Update Dimension Assign
 * Delete Dimension Assign
 * Update Rate
 * Create Dimension
 * Update Dimension
 * Delete Dimension
 * Create Tier
 * Update Tier
 * Delete Tier
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Rate Tables Public Application Program Interface
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

-- This is the record type for rate dimension assignments.  Each contains
-- a rate schedule name and rate dimension name (they have to be unique),
-- a sequence number, and the object version number (for locking)
TYPE dim_assign_rec_type IS RECORD
  (rate_schedule_name    CN_RATE_SCHEDULES.NAME%TYPE,
   rate_dim_name         CN_RATE_DIMENSIONS.NAME%TYPE,
   rate_dim_sequence     CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE,
   object_version_number CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE);

TYPE dim_assign_tbl_type IS TABLE OF dim_assign_rec_type INDEX BY BINARY_INTEGER;

-- Each rate tier has type=AMOUNT, PERCENT, EXPRESSION, or STRING.
-- If type is AMOUNT,     select the minimum and maximum value for value1 and value2,
-- If type is PERCENT,    select the minimum and maximum percent for value1 and value2,
-- If type is EXPRESSION, select expressions for minimum and maximum values by their
--                        name for value1 and value2
-- If type is STRING,     select the string value for value1 (leave value2 blank).
TYPE rate_tier_rec_type IS RECORD
  (tier_sequence         CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   value1                VARCHAR2(80),
   value2                VARCHAR2(80),
   object_version_number CN_RATE_DIM_TIERS.OBJECT_VERSION_NUMBER%TYPE);

TYPE rate_tier_tbl_type IS TABLE OF rate_tier_rec_type INDEX BY BINARY_INTEGER;

TYPE tier_coordinates_tbl IS TABLE OF NUMBER           INDEX BY BINARY_INTEGER;

-- Default empty tables
g_miss_dim_assign_tbl dim_assign_tbl_type;
g_miss_rate_tier_tbl  rate_tier_tbl_type;

-- Create rate schedule and schedule dimensions
-- Select a name, a commission unit code (AMOUNT or PERCENT), and a table of rate
-- dimensions.  For each dimension assignment, select a rate dimension by its name
-- and a sequence number (counting up, starting from one).  Leave the rate schedule name
-- and object_version_number blank.  This API creates the rate schedule, assigns the
-- dimensions, and creates the appropriate set of tiers. The original object_version_number
-- is zero.  When tiers are first created their commission amounts are null.
-- They can be set using the Update_Tier API.

/*#
 * This procedure creates a rate schedule with the given specifications. It also lets the user to assign rate dimensions at the same time.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_name                 Rate schedule name
 * @param p_commission_unit_code Commission unit (AMOUNT or PERCENT)
 * @param p_dims_tbl             Dimension assignment table (default empty table)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Rate Schedule

 */

PROCEDURE Create_Schedule
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE,
   p_dims_tbl                   IN      dim_assign_tbl_type := g_miss_dim_assign_tbl,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE := NULL,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Update rate schedule and schedule dimensions
-- Identify the rate schedule to pass by its original name, select a new name,
-- commission_unit_code and dimension assignment table as in the create API.
-- If the dimension assignment table is empty or not passed in, only the name and
-- commission_unit_code will be updated and the tiers are not affected.  Otherwise,
-- the table is rebuilt according to the new set of dimension assignments and the
-- tiers are re-created (resetting the commission amounts).  If all the validations
-- pass, the rate schedule is updated and its object version number is incremented.

/*#
 * This procedure creates a rate schedule with the given specifications. It also lets the user to assign rate dimensions at the same time.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_original_name         Original rate schedule name
 * @param p_new_name              New name (leave off if no change)
 * @param p_commission_unit_code  Commission unit (AMOUNT or PERCENT)
 * @param p_object_version_number Object version
 * @param p_dims_tbl              Dimension assignment table (default empty table)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Rate Schedule
 */

PROCEDURE Update_Schedule
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_original_name              IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_new_name                   IN      CN_RATE_SCHEDULES.NAME%TYPE :=
                                        cn_api.g_miss_char,
   p_commission_unit_code       IN      CN_RATE_SCHEDULES.COMMISSION_UNIT_CODE%TYPE :=
                                        cn_api.g_miss_char,
   p_object_version_number      IN OUT NOCOPY     CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE,
   p_dims_tbl                   IN      dim_assign_tbl_type := g_miss_dim_assign_tbl,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_SCHEDULES.ORG_ID%TYPE,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Delete rate schedule, dimension assignments, and rate tiers.
-- Identify the rate schedule to be deleted by its name.
/*#
 * This procedure deletes a rate schedule.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_name Rate Schedule Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Rate Schedule
 */

PROCEDURE Delete_Schedule
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_RATE_SCHEDULES.NAME%TYPE,
   -- Start - R12 MOAC Changes
   p_object_version_number      IN      CN_RATE_SCHEDULES.OBJECT_VERSION_NUMBER%TYPE, -- new
   -- End  - R12 MOAC Changes
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Assign a rate dimension to an existing rate schedule.  Identify the rate schedule
-- and its dimension by name.  Also give the sequence number indicating where you want
-- to insert the dimension.  If a dimension is inserted in the middle, all the existing
-- dimension assignments with equal or higher sequence number are pushed up by one sequence
-- number.

/*#
 * This procedure assigns a new rate dimension to the given rate schedule.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_rate_schedule_name  Rate schedule name
 * @param p_rate_dimension_name Rate dimension name
 * @param p_rate_dim_sequence   Rate dimension sequence
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Assign Rate Dimension to a rate schedule
 */

PROCEDURE Create_Dimension_Assign
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_rate_dimension_name        IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_rate_dim_sequence          IN      CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE := NULL,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Update a rate dimension to an existing rate schedule.  Pass in the rate schedule name
-- according to which rate schedule you wish to update, and pass in the original and
-- new dimension name according to the dimension you wish to reassign.  Finally pass in the
-- rate dimension sequence number and object_version_number.  If you do not pass in the
-- rate dimension sequence, the new dimension takes the same sequence number.

/*#
 * This procedure updates a given rate dimension assignment.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_rate_schedule_name  Rate schedule name
 * @param p_orig_rate_dim_name  Original rate dimension
 * @param p_new_rate_dim_name   New rate dimension (if changing)
 * @param p_rate_dim_sequence   Rate dimension sequence
 * @param p_object_version_number Object version
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update assignment of rate dimension to rate schedule
 */

PROCEDURE Update_Dimension_Assign
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_orig_rate_dim_name         IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_new_rate_dim_name          IN      CN_RATE_DIMENSIONS.NAME%TYPE := cn_api.g_miss_char,
   p_rate_dim_sequence          IN      CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE :=
                                        cn_api.g_miss_num,
   p_object_version_number      IN OUT NOCOPY     CN_RATE_SCH_DIMS.OBJECT_VERSION_NUMBER%TYPE,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Delete a rate dimension assignment by identifying the rate schedule and rate dimension
-- name.

/*#
 * This procedure deletes a rate dimension assignment.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_rate_schedule_name  Rate schedule name
 * @param p_rate_dimension_name New rate dimension (if changing)
 * @rep:lifecycle active
 * @rep:displayname Delete rate dimension assignment to rate schedule
 */

PROCEDURE Delete_Dimension_Assign
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_rate_dimension_name        IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   -- Start - R12 MOAC Changes
   p_object_version_number      IN      CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE, -- new
   -- End  - R12 MOAC Changes
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Update an individual rate tier by identifying the rate schedule and the set of
-- sequence numbers.  The number of values in the rate dimension tier sequence table
-- should correspond to the number of dimensions and the values should be in the
-- same order as the dimensions.

/*#
 * This procedure updates a commission rate in the given rate schedule.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_rate_schedule_name  Rate schedule name
 * @param p_tier_coordinates_tbl Coordinates of rate tier
 * @param p_commission_amount Commission amount
 * @param p_object_version_number Object version
 * @rep:lifecycle active
 * @rep:displayname Delete rate dimension assignment to rate schedule
 */


PROCEDURE Update_Rate
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_rate_schedule_name         IN      CN_RATE_SCHEDULES.NAME%TYPE,
   p_tier_coordinates_tbl       IN      tier_coordinates_tbl,
   p_commission_amount          IN      CN_RATE_TIERS.COMMISSION_AMOUNT%TYPE,
   p_object_version_number      IN OUT NOCOPY     CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_TIERS.ORG_ID%TYPE,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Create a dimension
-- Choose a name, description, a unit code (AMOUNT, PERCENT, EXPRESSION or STRING), and a set
-- of tiers.  For each tier, populate value1 and value2 (except for STRING which only uses
-- value1).

/*#
 * This procedure creates a new rate dimension.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_name  Rate schedule name
 * @param p_description Description
 * @param p_dim_unit_code Dimension unit (AMOUNT of PERCENT)
 * @param p_tiers_tbl Contents of rate tiers (default empty table)
 * @rep:lifecycle active
 * @rep:displayname Create a rate dimension
 */

PROCEDURE Create_Dimension
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_description                IN      CN_RATE_DIMENSIONS.DESCRIPTION%TYPE := NULL,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE,
   p_tiers_tbl                  IN      rate_tier_tbl_type := g_miss_rate_tier_tbl,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE := NULL,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Update a dimension
-- Identify the dimension to be updated by its original name.  Select the new name,
-- description, unit code and tiers table.  If unit code and tiers table are not passed in,
-- only the name and description are updated.
/*#
 * This procedure updates a given rate dimension.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_original_name  Original rate dimension name
 * @param p_new_name       New rate dimension name
 * @param p_description    Description
 * @param p_dim_unit_code  Dimension unit (AMOUNT of PERCENT)
 * @param p_tiers_tbl      Rate tiers (default empty table)
 * @param p_object_version_number Object version
 * @rep:lifecycle active
 * @rep:displayname Update a rate dimension
 */

PROCEDURE Update_Dimension
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_original_name              IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_new_name                   IN      CN_RATE_DIMENSIONS.NAME%TYPE :=
                                        cn_api.g_miss_char,
   p_description                IN      CN_RATE_DIMENSIONS.DESCRIPTION%TYPE :=
                                        cn_api.g_miss_char,
   p_dim_unit_code              IN      CN_RATE_DIMENSIONS.DIM_UNIT_CODE%TYPE :=
                                        cn_api.g_miss_char,
   p_tiers_tbl                  IN      rate_tier_tbl_type :=
                                        g_miss_rate_tier_tbl,
   p_object_version_number      IN OUT NOCOPY     CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_DIMENSIONS.ORG_ID%TYPE,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Delete a dimension
-- Pass in the name of dimension to be deleted.

/*#
 * This procedure deletes a rate dimension.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_name  Rate dimension name
 * @rep:lifecycle active
 * @rep:displayname Delete a rate dimension
 */

PROCEDURE Delete_Dimension
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   -- Start - R12 MOAC Changes
   p_object_version_number      IN      CN_RATE_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE, -- new
   -- End  - R12 MOAC Changes
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Create a tier for a dimension
-- Pass in the dimension name and value1 and value2 (if the type of the
-- specified dimension is STRING, value2 is not used... just pass in null).
-- Also pass in the tier sequence number.  All existing tiers with equal or higher
-- sequence numbers get pushed up by one.
/*#
 * This procedure adds a new tier to a given dimension.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_dimension_name   Rate dimension name
 * @param p_value1  Lower tier value
 * @param p_value2  Upper tier value (ignored for string based dimensions)
 * @param p_tier_sequence  Rate tier sequence
 * @rep:lifecycle active
 * @rep:displayname Add a new tier to existing dimension
 */

PROCEDURE Create_Tier
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dimension_name             IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_value1                     IN      VARCHAR2,
   p_value2                     IN      VARCHAR2,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_TIERS.ORG_ID%TYPE := NULL,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Update a tier for a dimension
-- Pass in the dimension name and sequence number to uniquely identify the tier.
-- Indicate the new minimum and maximum values as p_value1 and p_value2 (STRING
-- value tiers don't use p_value2).

/*#
 * This procedure updates a tier assigned to a dimension.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_dimension_name   Rate dimension name
 * @param p_tier_sequence  Rate tier sequence
 * @param p_value1  Lower tier value
 * @param p_value2  Upper tier value (ignored for string based dimensions)
 * @param p_object_version_number Object version
 * @rep:lifecycle active
 * @rep:displayname Update a tier to assigned to a rate dimension
 */

PROCEDURE Update_Tier
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dimension_name             IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   p_value1                     IN      VARCHAR2,
   p_value2                     IN      VARCHAR2,
   p_object_version_number      IN OUT NOCOPY     CN_RATE_DIM_TIERS.OBJECT_VERSION_NUMBER%TYPE,
   -- Start - MOAC Change
   p_org_id                     IN      CN_RATE_TIERS.ORG_ID%TYPE,
   -- End  - MOAC Change
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Delete a tier for a dimension
-- Pass in the dimension name and sequence number to uniquely identify the tier.

/*#
 * This procedure removes a rate tier from a given dimension.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F)
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_dimension_name   Rate dimension name
 * @param p_tier_sequence  Rate tier sequence
 * @rep:lifecycle active
 * @rep:displayname Delete a tier to assigned to a rate dimension
 */

PROCEDURE Delete_Tier
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dimension_name             IN      CN_RATE_DIMENSIONS.NAME%TYPE,
   p_tier_sequence              IN      CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
   -- Start - R12 MOAC Changes
   p_object_version_number      IN      CN_RATE_TIERS.OBJECT_VERSION_NUMBER%TYPE, -- new
   -- End  - R12 MOAC Changes
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

END CN_MULTI_RATE_SCHEDULES_PUB;

 

/
