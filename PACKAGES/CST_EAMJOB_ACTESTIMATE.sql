--------------------------------------------------------
--  DDL for Package CST_EAMJOB_ACTESTIMATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_EAMJOB_ACTESTIMATE" AUTHID CURRENT_USER AS
/* $Header: CSTPJACS.pls 115.0 2002/11/05 23:06:27 awwang noship $ */

/* ============================================================== */
-- FUNCTION
-- Get_eamCostElement()
--
-- DESCRIPTION
-- Function to return the correct eAM cost element, based on
-- the transaction mode and the resource id of a transaction.
--
-- PARAMETERS
-- p_txn_mode (1=material, 2=resource)
-- p_org_id
-- p_resource_id (optional; to be passed only for a resource tranx)
--
/* ================================================================= */

FUNCTION Get_eamCostElement(
          p_txn_mode             IN  NUMBER,
          p_org_id               IN  NUMBER,
          p_resource_id          IN  NUMBER := NULL)
   RETURN number;

TYPE ActivityEstimateRec IS RECORD
(
   record_type       NUMBER,
   organization_id   NUMBER,
   activity_item_id  NUMBER,
   resource_id       NUMBER,
   overhead_id       NUMBER,
   op_seq_num        NUMBER,
   maint_cost_catg   NUMBER,
   eam_cost_element  NUMBER,
   cost_value        NUMBER
);


TYPE ActivityEstimateTable IS TABLE OF ActivityEstimateRec;

---------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Get_DeptCostCatg                                                     --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API returns the cost category of the department                 --

--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    04/17/01     Hemant G       Created                                 --
----------------------------------------------------------------------------
PROCEDURE Get_DeptCostCatg (
                            p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2
                                                  := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2
                                                  := FND_API.G_FALSE,
                            p_validation_level   IN   NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,
                            p_debug              IN   VARCHAR2 := 'N',

                            p_department_id      IN   NUMBER := NULL,
                            p_organization_id    IN   NUMBER := NULL,

                            p_user_id            IN   NUMBER,
                            p_request_id         IN   NUMBER,
                            p_prog_id            IN   NUMBER,
                            p_prog_app_id        IN   NUMBER,
                            p_login_id           IN   NUMBER,

                            x_dept_cost_catg     OUT NOCOPY  NUMBER,
                            x_return_status      OUT NOCOPY  VARCHAR2,
                            x_msg_count          OUT NOCOPY  NUMBER,
                            x_msg_data           OUT NOCOPY  VARCHAR2 );

--------------------------------------------------------------------------n
-- PROCEDURE                                                              --
--   Compute_Activity_Estimate                                            --
--                                                                        --
--                                                                        --

--                                                                        --
-- DESCRIPTION                                                            --
--   This API Computes the estimate for a an asset activity               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    04/17/01     Hemant G       Created                                 --
----------------------------------------------------------------------------
PROCEDURE Compute_Activity_Estimate (
                            p_api_version           IN   NUMBER,
                            p_init_msg_list         IN   VARCHAR2
                                                      := FND_API.G_FALSE,
                            p_commit                IN   VARCHAR2
                                                      := FND_API.G_FALSE,
                            p_validation_level      IN   NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,
                            p_debug                 IN   VARCHAR2 := 'N',

                            p_activity_item_id      IN   NUMBER,
                            p_organization_id       IN   NUMBER,
                            p_alt_bom_designator    IN   VARCHAR2 := NULL,
                            p_alt_rtg_designator    IN   VARCHAR2 := NULL,
                            p_cost_group_id         IN   NUMBER   := NULL,
                            p_effective_datetime    IN   VARCHAR2 :=
 fnd_date.date_to_canonical(SYSDATE),

                            p_user_id               IN   NUMBER,
                            p_request_id            IN   NUMBER,
                            p_prog_id               IN   NUMBER,
                            p_prog_app_id           IN   NUMBER,
                            p_login_id              IN   NUMBER,

                            x_ActivityEstimateTable OUT NOCOPY  ActivityEstimateTable,
                            x_return_status         OUT NOCOPY  VARCHAR2,

                            x_msg_count             OUT NOCOPY  NUMBER,
                            x_msg_data              OUT NOCOPY  VARCHAR2 );



---------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Get_Activity_Estimate                                            --
--                                                                        --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API Computes the estimate for an asset activity                 --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.9                                        --
--                                                                        --
--                                                                        --

--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    08/07/02     Hemant G       Created                                 --
----------------------------------------------------------------------------
PROCEDURE Get_Activity_Estimate (
                            p_api_version           IN   NUMBER,
                            p_init_msg_list         IN   VARCHAR2
                                                      := FND_API.G_FALSE,
                            p_commit                IN   VARCHAR2
                                                      := FND_API.G_FALSE,
                            p_validation_level      IN   NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,
                            p_debug                 IN   VARCHAR2 := 'N',

                            p_activity_item_id      IN   NUMBER,
                            p_organization_id       IN   NUMBER,
                            p_alt_bom_designator    IN   VARCHAR2 := NULL,
                            p_alt_rtg_designator    IN   VARCHAR2 := NULL,
                            p_cost_group_id         IN   NUMBER   := NULL,
                            p_effective_datetime    IN   VARCHAR2 :=
                                                           fnd_date.date_to_canonical(SYSDATE),

                            p_user_id               IN   NUMBER,
                            p_request_id            IN   NUMBER,
                            p_prog_id               IN   NUMBER,
                            p_prog_app_id           IN   NUMBER,
                            p_login_id              IN   NUMBER,

                            x_activity_estimate_record_id    OUT NOCOPY  NUMBER,
                            x_return_status         OUT NOCOPY  VARCHAR2,
                            x_msg_count             OUT NOCOPY  NUMBER,
                            x_msg_data              OUT NOCOPY  VARCHAR2 );


END CST_EAMJOB_ACTESTIMATE;


 

/
