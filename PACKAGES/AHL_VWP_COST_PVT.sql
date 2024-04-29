--------------------------------------------------------
--  DDL for Package AHL_VWP_COST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_COST_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVCSTS.pls 115.3 2003/10/31 22:04:22 yazhou noship $ */
-----------------------------------------------------------
-- PACKAGE
--    AHL_VWP_COST_PVT
--
-- PURPOSE
--    This package specification is a Private API for managing
--    Planning --> Visit Work Package --> Visit or MR or Tasks COSTING
--    which involves integration of Complex Maintainance, Repair
--    and Overhauling (CMRO) with COST MANAGEMENT related
--    procedures in Complex Maintainance, Repair and Overhauling(CMRO)
--
--
--      Calculate_Visit_Cost           (see below for specification)
--      Calculate_MR_Cost              (see below for specification)
--      Calculate_Task_Cost            (see below for specification)
--      Push_MR_Cost_Hierarchy         (see below for specification)
--      Rollup_MR_Cost_Hierarchy       (see below for specification)
--      Calculate_WO_Cost              (see below for specification)
--      Estimate_WO_Cost               (see below for specification)
--      Get_WO_Cost                    (see below for specification)
--      Get_Profit_or_Loss             (see below for specification)
--      Insert_Cst_Wo_Hierarchy        (see below for specification)
--      Create_Wo_Cost_Structure       (see below for specification)
--      Create_Wo_Dependencies         (see below for specification)
--
-- NOTES
--
--
-- HISTORY
-- 28-AUG-2003    SHBHANDA      11.5.10. VWP-Costing Enhancements
-- 09-SEP-2003    SHBHANDA      Added default parameters in Push_MR_Cost_hierarchy
--                              and Rollup_MR_Cost_hierarchy
-- 19-SEP-2003    SHBHANDA      Incorporated APIs
--                                 Insert_Cst_Wo_Hierarchy   -- Srini
--                                 Create_Wo_Cost_Structure  -- Srini
--                                 Create_Wo_Dependencies    -- ShivaK
--------------------------------------------------------------------

---------------------------------------------------------------------
--   Define Record Types for record structures needed by the APIs  --
---------------------------------------------------------------------
TYPE  Cst_Job_Rec_Type IS RECORD(
      GROUP_ID                NUMBER,
      OBJECT_ID               NUMBER,
      OBJECT_TYPE             NUMBER(15),--NULL
      PARENT_OBJECT_ID        NUMBER,
      PARENT_OBJECT_TYPE      NUMBER(15),--NULL
      LEVEL_NUM               NUMBER,
      REQUEST_ID              NUMBER,
      PROGRAM_APPLICATION_ID  NUMBER);

---------------------------------------------------------------------
-- Define Table Type for Records Structures                        --
---------------------------------------------------------------------
--Declare Cost Job table type
TYPE Cst_Job_Tbl IS TABLE OF Cst_Job_Rec_Type
          INDEX BY BINARY_INTEGER;


-------------------------------------------------------------------
--                      Declare Procedures                       --
-------------------------------------------------------------------

--------------------------------------------------------------------
--  Procedure name    : Create_WO_Cost_Structure
--  Type              : Private(Called from AHL_VWP_COST_PRICE_PVT)
--
--  Function          : To create Visits workorder cost hierarchy structure
--                      for master workorder and its associated child workorders
--
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Create WO Cost Structure Parameters:
--       p_visit_id                     IN      NUMBER  Required,
--       x_cost_session_id              OUT     NUMBER
--
--  History  :
--    09/08/2003     SSURAPAN   Initial  Creation
--------------------------------------------------------------------
PROCEDURE Create_Wo_Cost_Structure (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_visit_id               IN            NUMBER,
    x_cost_session_id           OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
  );


--------------------------------------------------------------------
--  Procedure name    : Create_Wo_Dependencies
--  Type              : Private
--
--  Function          : To create Visits Schedulling dependencies structure
--                      for master workorder and its associated child workorders
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Create_Wo_Dependencies Parameters:
--       p_visit_id                     IN      NUMBER  Required,
--       x_MR_session_id                OUT     NUMBER
--
--  Version :
--    09/08/2003     Skalyan   Initial  Creation
--------------------------------------------------------------------
PROCEDURE Create_Wo_Dependencies
(
   p_api_version            IN         NUMBER,
   p_init_msg_list          IN         VARCHAR2  := Fnd_Api.G_FALSE,
   p_commit                 IN         VARCHAR2  := Fnd_Api.G_FALSE,
   p_validation_level       IN         NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
   p_visit_id               IN         NUMBER,
   x_MR_session_id          OUT NOCOPY NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2
);


--------------------------------------------------------------------
--  Procedure name    : Insert_Cst_WO_Hierarchy
--  Type              : Private(Called from Create Wo Cost structure ,
--                      Create MR Cost Structure)
--
--  Function          : To insert Visits cost hierarchy structure and MR Hierarchy structure
--                      into Costing interface table CST_EAM_HIERARCHY_SNAPSHOT
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--
--  Insert Cost Workorder hierarchy Parameters:
--       p_cst_job_tbl                     IN   Cst_job_Tbl  Required
--         Contains Cost Workorder hirerchy details
--       x_session_id                     OUT  NUMBER
--
--  Version :
--    09/08/2003     SSURAPAN   Initial  Creation
--------------------------------------------------------------------
PROCEDURE Insert_Cst_Wo_Hierarchy (
    p_cst_job_tbl            IN          Cst_Job_Tbl,
    p_commit                 IN          VARCHAR2  := Fnd_Api.G_FALSE,
    x_session_id             OUT NOCOPY  NUMBER,
    x_return_status          OUT NOCOPY  VARCHAR2
  );


--------------------------------------------------------------------
--  Procedure name    : Calculate_Visit_Cost
--  Type              : Private
--  Purpose           : Procedure to calculate Visit's Estimated and Actual Costs
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Calculate_Visit_Cost IN Parameters:
--   p_visit_id             IN  NUMBER     Required,
--   p_session_id           IN  NUMBER     Required,
--
--  Calculate_Visit_Cost OUT Parameters:
--   x_actual_cost          OUT  NUMBER     Required,
--   x_estimated_cost       OUT  NUMBER     Required
--
--  Version :
--      Initial Version   1.0
--------------------------------------------------------------------
PROCEDURE Calculate_Visit_Cost(
    p_visit_id	       IN 	            NUMBER,
    p_session_id	   IN 	            NUMBER,

    x_actual_cost	   OUT      NOCOPY	NUMBER,
    x_estimated_cost   OUT      NOCOPY	NUMBER,
    x_return_status	   OUT      NOCOPY	VARCHAR2
);

----------------------------------------------------------------------------
--  Procedure name    : Calculate_MR_Cost
--  Type              : Private
--  Purpose           : Procedure to calculate MR's Estimated and Actual Costs
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Calculate_MR_Cost IN Parameters:
--   p_MR_id                IN  NUMBER     Required,
--   p_session_id           IN  NUMBER     Required,
--
--  Calculate_MR_Cost OUT Parameters:
--   x_actual_cost          OUT  NUMBER     Required,
--   x_estimated_cost       OUT  NUMBER     Required
--
--  Version :
--      Initial Version   1.0
----------------------------------------------------------------------------
PROCEDURE Calculate_MR_Cost (
    p_visit_task_id        IN 	            NUMBER,
    p_session_id	   IN 	            NUMBER,

    x_actual_cost	   OUT	    NOCOPY  NUMBER,
    x_estimated_cost   OUT	    NOCOPY  NUMBER,
    x_return_status	   OUT      NOCOPY  VARCHAR2
);

----------------------------------------------------------------------------
--  Procedure name    : Calculate_Task_Cost
--  Type              : Private
--  Purpose           : Procedure to calculate Task's Estimated and Actual Costs
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Calculate_Task_Cost IN Parameters:
--   p_visit_task_id        IN  NUMBER     Required,
--   p_session_id           IN  NUMBER     Required,
--
--  Calculate_Task_Cost OUT Parameters:
--   x_actual_cost          OUT  NUMBER     Required,
--   x_estimated_cost       OUT  NUMBER     Required
--
--  Version :
--      Initial Version   1.0
----------------------------------------------------------------------------
PROCEDURE Calculate_Task_Cost(
    p_visit_task_id	    IN	            NUMBER,
    p_session_id	    IN              NUMBER,
    x_actual_cost	    OUT  	NOCOPY  NUMBER,
    x_estimated_cost	OUT	    NOCOPY  NUMBER,
    x_return_status	    OUT     NOCOPY  VARCHAR2
);

----------------------------------------------------------------------------
--  Procedure name    : Calculate_Node_Cost
--  Type              : Private
--  Purpose           : Procedure to calculate Cost Structure Node's Estimated and Actual Costs
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Calculate_Task_Cost IN Parameters:
--   p_visit_task_id        IN  NUMBER     Required,
--   p_session_id           IN  NUMBER     Required,
--
--  Calculate_Task_Cost OUT Parameters:
--   x_actual_cost          OUT  NUMBER     Required,
--   x_estimated_cost       OUT  NUMBER     Required
--
--  Version :
--      Initial Version   1.0
----------------------------------------------------------------------------
PROCEDURE Calculate_Node_Cost(
    p_visit_task_id	    IN	            NUMBER,
    p_session_id	    IN              NUMBER,
    x_actual_cost	    OUT  	NOCOPY  NUMBER,
    x_estimated_cost	OUT	    NOCOPY  NUMBER,
    x_return_status	    OUT     NOCOPY  VARCHAR2
);

-----------------------------------------------------------------------------
--  Procedure name    : Push_MR_Cost_Hierarchy
--  Type              : Private
--  Purpose           : Procedure to push Visit Schedulling dependencies
--                      structure and visit cost hierarchy structure
--                      hierarchies to production for costing purpose
--  Parameters  :
--
--  Standard IN Parameters :
--   p_api_version          IN     NUMBER    Required,
--   p_init_msg_list        IN     VARCHAR2  Required,
--   p_commit               IN     VARCHAR2  Required,
--   p_validation_level     IN     NUMBER    Required,
--
--  Standard OUT Parameters :
--   x_return_status        OUT    VARCHAR2   Required,
--
--  Push_MR_Cost_Hierarchy IN Parameters:
--   p_visit_id             IN     NUMBER     Required,
--
--  Push_MR_Cost_Hierarchy OUT Parameters:
--   x_cost_session_id      OUT    NUMBER     Required,
--   x_mr_session_id        OUT    NUMBER     Required
--
--  Version :
--      Initial Version   1.0
----------------------------------------------------------------------------
PROCEDURE Push_MR_Cost_Hierarchy(
    p_api_version            IN              NUMBER    := 1.0,
    p_init_msg_list          IN              VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN              VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN              NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_visit_id        	     IN	             NUMBER,

    x_cost_session_id	     OUT	    NOCOPY  NUMBER,
    x_MR_session_id	         OUT        NOCOPY	 NUMBER,
    x_return_status	         OUT        NOCOPY	 VARCHAR2
);



-----------------------------------------------------------------------------
--  Procedure name    : Rollup_MR_Cost_Hierarchy
--  Type              : Private
--  Purpose           : Procedure to push visit MR structure and visit cost
--                      hierarchies to production for costing purpose
--  Parameters  :
--  Standard IN Parameters :
--   p_api_version          IN     NUMBER    Required,
--   p_init_msg_list        IN     VARCHAR2  Required,
--   p_commit               IN     VARCHAR2  Required,
--   p_validation_level     IN     NUMBER    Required,
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Push_MR_Cost_Hierarchy IN OUT Parameters:
--   p_x_MR_session_Id        IN  OUT NUMBER     Required,
--   p_x_cost_session_Id      IN  OUT NUMBER     Required
--
--  Version :
--      Initial Version   1.0
----------------------------------------------------------------------------
PROCEDURE Rollup_MR_Cost_Hierarchy(
    p_api_version            IN                NUMBER    := 1.0,
    p_init_msg_list          IN                VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN                VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN                NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_visit_id               IN                NUMBER,
    p_MR_session_Id	         IN                NUMBER,
    p_cost_session_id	     IN                NUMBER,
    x_return_status	         OUT   NOCOPY      VARCHAR2
);



-----------------------------------------------------------------------------
--  Procedure name    : Calculate_WO_Cost
--  Type              : Private
--  Purpose           : Procedure to push visit MR structure and visit cost
--                      hierarchies to production for costing purpose
--  Parameters  :
--  Standard IN Parameters :
--   p_api_version          IN     NUMBER    Required,
--   p_init_msg_list        IN     VARCHAR2  Required,
--   p_commit               IN     VARCHAR2  Required,
--   p_validation_level     IN     NUMBER    Required,
--
--  Standard OUT Parameters :
--   x_return_status        OUT    VARCHAR2  Required,
--
--  Calculate_WO_Cost IN OUT Parameters:
--   p_x_cost_price_rec      IN OUT NUMBER   Required
--
--  Version :
--      Initial Version   1.0
----------------------------------------------------------------------------
PROCEDURE Calculate_WO_Cost(
    p_api_version            IN             NUMBER    := 1.0,
    p_init_msg_list          IN             VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN             VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN             NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,

    p_x_cost_price_rec       IN OUT  NOCOPY AHL_VWP_VISIT_CST_PR_PVT.Cost_price_rec_type,
    x_return_status	         OUT     NOCOPY	VARCHAR2);


-----------------------------------------------------------------------------
--  Procedure name    : Estimate_WO_Cost
--  Type              : Private
--  Purpose           : Procedure to push visit MR structure and visit cost
--                      hierarchies to production for costing purpose
--  Parameters  :
--  Standard IN Parameters :
--   p_api_version          IN     NUMBER    Required,
--   p_init_msg_list        IN     VARCHAR2  Required,
--   p_commit               IN     VARCHAR2  Required,
--   p_validation_level     IN     NUMBER    Required,
--
--  Standard OUT Parameters :
--   x_return_status        OUT    VARCHAR2  Required,
--
--  Estimate_WO_Cost IN OUT Parameters:
--   p_x_cost_price_rec      IN OUT NUMBER   Required
--
--  Version :
--      Initial Version   1.0
----------------------------------------------------------------------------
PROCEDURE Estimate_WO_Cost(
    p_api_version            IN             NUMBER    := 1.0,
    p_init_msg_list          IN             VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                 IN             VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level       IN             NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,

    p_x_cost_price_rec       IN OUT  NOCOPY AHL_VWP_VISIT_CST_PR_PVT.Cost_price_rec_type,
    x_return_status	         OUT     NOCOPY	VARCHAR2);



-----------------------------------------------------------------------------
--  Procedure name    : Get_WO_Cost
--  Type              : Private
--  Purpose           : Procedure to push visit MR structure and visit cost
--                      hierarchies to production for costing purpose
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Get_WO_Cost IN Parameters:
--   p_Sesssion_Id          IN      NUMBER     Required,
--   p_Id                   IN      NUMBER     Required,
--
--  Get_WO_Cost OUT Parameters:
--   x_actual_cost          OUT     NUMBER     Required,
--   x_estimated_cost       OUT     NUMBER     Required
--
--  Version :
--      Initial Version   1.0
----------------------------------------------------------------------------
PROCEDURE Get_WO_Cost(
    p_Session_Id        IN	            NUMBER,
    p_Id	            IN	            NUMBER,
    p_program_id        IN	            NUMBER,

    x_actual_cost	    OUT 	NOCOPY  NUMBER,
    x_estimated_cost    OUT 	NOCOPY  NUMBER,
    x_return_status	    OUT     NOCOPY	VARCHAR2
);


-----------------------------------------------------------------------------
--  Procedure name    : Get_Profit_or_Loss
--  Type              : Private
--  Purpose           : Procedure to get and calculate visit/MR/task
--                      estimated and actual profit or loss
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required
--
--  Get_Profit_or_Loss IN Parameters:
--   p_actual_price          IN  NUMBER     Required,
--   p_estimated_price       IN  NUMBER     Required,
--   p_actual_cost           IN  NUMBER     Required,
--   p_estimated_cost        IN  NUMBER     Required,
--
--  Get_Profit_or_Loss OUT Parameters:
--   x_actual_profit         IN  NUMBER     Required,
--   x_estimated_profit      IN  NUMBER     Required
--
--  Version :
--      Initial Version   1.0
----------------------------------------------------------------------------
PROCEDURE Get_Profit_or_Loss(
    p_actual_price      IN              NUMBER,
    p_estimated_price   IN              NUMBER,
    p_actual_cost	    IN              NUMBER,
    p_estimated_cost    IN              NUMBER,

    x_actual_profit	    OUT     NOCOPY  NUMBER,
    x_estimated_profit  OUT     NOCOPY  NUMBER,
    x_return_status	    OUT     NOCOPY	VARCHAR2
);


END AHL_VWP_COST_PVT; -- End of Package Specification

 

/
