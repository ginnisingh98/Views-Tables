--------------------------------------------------------
--  DDL for Package OZF_FUND_ALLOCATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_FUND_ALLOCATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvalcs.pls 115.5 2004/01/28 14:39:31 kdass noship $*/

g_max_end_level CONSTANT NUMBER := 99999;
/*  due to round up problems, sometimes validation fails although the difference is tiny tiny.
    so any difference less than g_max_ignorable_amount is ignored
 */
g_max_ignorable_amount   CONSTANT  NUMBER := 0.0000000000000000000000000000001;

TYPE fact_table_type IS TABLE OF ozf_actmetricfact_Pvt.act_metric_fact_rec_type INDEX BY BINARY_INTEGER;
TYPE factid_type IS RECORD (
     fact_id            NUMBER,
     fact_obj_ver       NUMBER,
     approve_recommend  VARCHAR2(1)      -- Y: approve recommended amount, N: approve request amount
);
TYPE factid_table_type IS TABLE OF factid_type INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- FUNCTION
--   get_max_end_level
--
-- PURPOSE
--    returns g_max_end_level
--    called by BudgetTopbotAdmEO.java
-- HISTORY
--    01/28/04  kdass  Created.
-- PARAMETERS
--
---------------------------------------------------------------------
FUNCTION get_max_end_level RETURN NUMBER;

---------------------------------------------------------------------
-- PROCEDURE
--   get_prior_year_sales
--
-- PURPOSE
--    public api to get prior year's total sales amount for one territory node
--    called by compute_worksheet and UI worksheet page
--
-- HISTORY
--    10/16/02  yzhao  Created.
--    14/07/03  nkumar  Modified.
--
-- PARAMETERS
---------------------------------------------------------------------

PROCEDURE get_prior_year_sales(
    p_hierarchy_id       IN       NUMBER
  , p_node_id            IN       NUMBER
  , p_basis_year         IN       NUMBER
  , p_alloc_id           IN       NUMBER
  , x_self_amount        OUT NOCOPY      NUMBER
  , x_rollup_amount      OUT NOCOPY      NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
---   create_alloc_hierarchy
--
-- PURPOSE
--    Create allocation worksheet hierarchy.
--
-- HISTORY
--    05/20/02  yzhao  Created.
--
-- PARAMETERS
---------------------------------------------------------------------
PROCEDURE create_alloc_hierarchy(
    p_api_version        IN       NUMBER   DEFAULT 1.0
  , p_init_msg_list      IN       VARCHAR2 DEFAULT fnd_api.g_false
  , p_commit             IN       VARCHAR2 DEFAULT fnd_api.g_false
  , p_alloc_id           IN       NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
);


----------------------------------------------------------------------------------------
-- This Procedure will publish allocation worksheet                                   --
--   create draft or active child funds for the allocation.                           --
--   child funds inherit parent funds's market and product eligibity if it's active   --
--   send notification to child budget owner                                          --
--   set published flag for the allocation                                            --
---------------------------------PARAMETERS---------------------------------------------
-- p_alloc_id    allocation id in ozf_act_metrics_all table                          --
-- p_alloc_status   allocation status in ozf_act_metric_facts_all table
----------------------------------------------------------------------------------------
Procedure publish_allocation( p_api_version         IN     NUMBER    DEFAULT 1.0
                            , p_init_msg_list       IN     VARCHAR2  DEFAULT FND_API.G_FALSE
                            , p_commit              IN     VARCHAR2  DEFAULT FND_API.G_FALSE
                            , p_validation_level    IN     NUMBER    DEFAULT FND_API.g_valid_level_full
                            , p_alloc_id            IN     NUMBER
                            , p_alloc_status        IN     VARCHAR2
                            , p_alloc_obj_ver       IN     NUMBER
                            , x_return_status       OUT NOCOPY    VARCHAR2
                            , x_msg_count           OUT NOCOPY    NUMBER
                            , x_msg_data            OUT NOCOPY    VARCHAR2
);


----------------------------------------------------------------------------------------
-- This Procedure will validate an allocation worksheet                               --
-- For each node:                                                                     --
--      Sum(this node and its sibling's allocation amount) <= parent allocation amount - holdback amount
--      Sum(child allocation amount) <= this node's allocation amount - holdback amount
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_alloc_id    allocation id in ozf_act_metrics_all table                           --
----------------------------------------------------------------------------------------
Procedure validate_worksheet(p_api_version         IN     NUMBER    DEFAULT 1.0,
                             p_init_msg_list       IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                             p_commit              IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                             p_validation_level    IN     NUMBER    DEFAULT FND_API.g_valid_level_full,
                             p_alloc_id            IN     NUMBER,
                             x_return_status       OUT NOCOPY    VARCHAR2,
                             x_msg_count           OUT NOCOPY    NUMBER,
                             x_msg_data            OUT NOCOPY    VARCHAR2
);


----------------------------------------------------------------------------------------
-- This Procedure will update an allocation worksheet                                 --
--   Public api called by worksheet update and publish button                         --
--   Only called by allocation in 'NEW' OR 'PLANNED' status                           --
--   It first updates fact amount according to the input                              --
--   then if 'cascade' flag is set, cascade changes down the whole hierarchy          --
--   it also update the corresponding allocation budget's original and holdback amount--
--   if base percentage is null in table, set base percentage
--   cascade is allowed for recommended amount change only                            --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_alloc_id    allocation id in ozf_act_metrics_all table                           --
-- p_fact_table  table of fact records to be changed                                  --
--               required fields are: activity_metric_fact_id, object_version_number, --
--                                    recommend_total_amount, recommend_hb_amount,    --
--                                    node_id, level_depth                            --
----------------------------------------------------------------------------------------
Procedure update_worksheet_amount(p_api_version         IN     NUMBER    DEFAULT 1.0,
                           p_init_msg_list       IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                           p_commit              IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                           p_validation_level    IN     NUMBER    DEFAULT FND_API.g_valid_level_full,
                           p_alloc_id            IN     NUMBER,
                           p_alloc_obj_ver       IN     NUMBER,
                           p_cascade_flag        IN     VARCHAR2  DEFAULT 'N',
                           p_fact_table          IN     fact_table_type,
                           x_return_status       OUT NOCOPY    VARCHAR2,
                           x_msg_count           OUT NOCOPY    NUMBER,
                           x_msg_data            OUT NOCOPY    VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
---   update_alloc_status
--
-- PURPOSE
--    Update allocation status
--    public api called by worksheet page update button
--
-- HISTORY
--    09/23/02  yzhao  Created.
--
-- PARAMETERS
---------------------------------------------------------------------
PROCEDURE update_alloc_status(
    p_api_version        IN       NUMBER    DEFAULT 1.0
  , p_init_msg_list      IN       VARCHAR2  DEFAULT FND_API.G_FALSE
  , p_commit             IN       VARCHAR2  DEFAULT FND_API.G_FALSE
  , p_validation_level   IN       NUMBER    DEFAULT FND_API.g_valid_level_full
  , p_alloc_id           IN       NUMBER
  , p_alloc_status       IN       VARCHAR2
  , p_alloc_obj_ver      IN       NUMBER
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
);


----------------------------------------------------------------------------------------
-- This Procedure will approve a published allocation called by bottom-up budgeting   --
--   the approver's fact record must be active to approve its children                --
--   approve all levels below, or next level only                                     --
--   create budget transfer record                                                    --
--   update child node status as 'ACTIVE'                                             --
--   send notification to child budget owner                                          --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_approver_fact_id  the approver's fact id. null means approver is the root budget --
-- p_approve_all_flag  Y - approve all levels below; N - approve the next level only  --
-- p_factid_table      children fact ids to be approved                               --
----------------------------------------------------------------------------------------
Procedure approve_levels(p_api_version         IN     NUMBER     DEFAULT 1.0,
                         p_init_msg_list       IN     VARCHAR2   DEFAULT FND_API.G_FALSE,
                         p_commit              IN     VARCHAR2   DEFAULT FND_API.G_FALSE,
                         p_validation_level    IN     NUMBER     DEFAULT FND_API.g_valid_level_full,
                         p_approver_factid     IN     NUMBER,
                         p_approve_all_flag    IN     VARCHAR2,
                         p_factid_table        IN     factid_table_type,
                         x_return_status       OUT NOCOPY    VARCHAR2,
                         x_msg_count           OUT NOCOPY    NUMBER,
                         x_msg_data            OUT NOCOPY    VARCHAR2
);


----------------------------------------------------------------------------------------
-- This Procedure will submit user's requested total and holdback amount              --
--   only allocation in 'PLANNED' or 'REJECTED' status can user submit request        --
--   update this node allocation status as 'SUBMITTED'                                --
--   send notification to parent budget owner                                         --
--   record justificaiton note if any                                                 --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_fact_id         fact id                                                          --
-- p_fact_obj_ver    fact object version number                                       --
-- p_note            justification note if any                                        --
----------------------------------------------------------------------------------------
Procedure submit_request(p_api_version         IN     NUMBER    DEFAULT 1.0,
                         p_init_msg_list       IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                         p_commit              IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                         p_validation_level    IN     NUMBER    DEFAULT FND_API.g_valid_level_full,
                         p_fact_id             IN     NUMBER,
                         p_fact_obj_ver        IN     NUMBER,
                         p_note                IN     VARCHAR2  DEFAULT NULL,
                         x_return_status       OUT NOCOPY    VARCHAR2,
                         x_msg_count           OUT NOCOPY    NUMBER,
                         x_msg_data            OUT NOCOPY    VARCHAR2
);


----------------------------------------------------------------------------------------
-- This Procedure will reject user's requested total and holdback amount              --
--   only allocation in 'PLANNED' or 'ACTIVE' status can user reject request          --
--   called by top or bottom level user                                               --
--   update the child node allocation status as 'REJECTED'                            --
--   send notification to child budget owners                                         --
----------------------------------------------------------------------------------------
---------------------------------PARAMETERS---------------------------------------------
-- p_rejector_factid    rejector's fact id                                            --
-- p_factid_table       children fact ids to be rejected                              --
----------------------------------------------------------------------------------------
Procedure reject_request(p_api_version         IN     NUMBER    DEFAULT 1.0,
                         p_init_msg_list       IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                         p_commit              IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
                         p_validation_level    IN     NUMBER    DEFAULT FND_API.g_valid_level_full,
                         p_rejector_factid     IN     NUMBER,
                         p_factid_table        IN     factid_table_type,
                         x_return_status       OUT NOCOPY    VARCHAR2,
                         x_msg_count           OUT NOCOPY    NUMBER,
                         x_msg_data            OUT NOCOPY    VARCHAR2
);

END OZF_Fund_allocations_Pvt;

 

/
