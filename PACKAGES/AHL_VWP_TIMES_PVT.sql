--------------------------------------------------------
--  DDL for Package AHL_VWP_TIMES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_TIMES_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVTMSS.pls 120.2.12010000.2 2009/05/05 14:20:35 skpathak ship $ */

-------------------------------------------------------------------
--  Procedure name    : Calculate_Task_Times
--  Type              : Private
--  Function          : Derive the start and end times/hours of tasks
--                      and the end_date_time of the visit
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status       OUT     VARCHAR2     Required
--      x_msg_count           OUT     NUMBER       Required
--      x_msg_data            OUT     VARCHAR2     Required
--
--  Derive_Visit_Task_Times Parameters:
--      p_visit_id            IN      NUMBER       Required
--         The id of the visit whose associated tasks' start and end times or hours
--         need to be derived
--  Version :
--      Initial Version   1.0
--
-------------------------------------------------------------------
PROCEDURE Calculate_Task_Times
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level      IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2,
    p_visit_id              IN            NUMBER);

-------------------------------------------------------------------
--  Procedure name    : Calculate_Task_Times_For_Dept
--  Type              : Private
--  Function          : Recalculate all Visits for Dept for Task Times
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status       OUT     VARCHAR2     Required
--      x_msg_count           OUT     NUMBER       Required
--      x_msg_data            OUT     VARCHAR2     Required
--
--  Derive_Visit_Task_Times Parameters:
--      p_dept_id            IN      NUMBER       Required
--         The dept id which need to have all its visits recalculated.
--     Need to be called from concurrent program due to performance issues.
--
-------------------------------------------------------------------
PROCEDURE Calculate_Task_Times_For_Dept
(
    p_api_version          IN            NUMBER,
    p_init_msg_list        IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit               IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level     IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_msg_count            OUT NOCOPY    NUMBER,
    x_msg_data             OUT NOCOPY    VARCHAR2,
    p_dept_id              IN            NUMBER);

--------------------------------------------------------------------
--  Procedure name    : Adjust_task_times
--  Type              : Private
--  Purpose           : Adjusts tasks times and all dependent task times
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required,
--
--  Validate_bef_Times_Derive IN Parameters :
--  p_task_id             IN  NUMBER     Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
-- SKPATHAK :: Bug 8343599 :: 14-APR-2009
-- Added the optional in param p_task_start_date
PROCEDURE Adjust_Task_Times
(
    p_api_version           IN          NUMBER,
    p_init_msg_list         IN          VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                IN          VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level      IN          NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,
    p_task_id               IN          NUMBER,
    p_reset_sysdate_flag    IN          VARCHAR2 := FND_API.G_FALSE,
    p_task_start_date       IN          DATE     := NULL);

--------------------------------------------------------------------
--  Function name    : Get_Visit_Start_Time
--  Type             : Public
--  Purpose          : Fetches Master Work Order Actual Start Date if the
--                     Visit is Closed, else returns the Visit Start Date.
--  Parameters  :
--        p_visit_id   Visit ID to fetch the data
--
--------------------------------------------------------------------
function Get_Visit_Start_Time(
      p_visit_id   IN   NUMBER
  )
RETURN DATE;

--------------------------------------------------------------------
--  Function name    : Get_Visit_End_Time
--  Type             : Public
--  Purpose          : To RETURN the End Date for the visit.
--                     For Unit Affectivity API it returns
--                      Master Work Order Actual End Date when visit is Closed
--                      and NVL(Visit Close Date,Max(Task End Times))
--                     For VWP it returns
--                      Max(Task End Times) when Visit is in Planning
--                      Max(Max(WO Released Job Completion Date),Max(Task End Times))

--  Parameters  :
--       p_visit_id    Visit ID to fetch the data
--       p_use_actual  This is a boolean value equal to FND_API.G_TRUE or FND_API.G_FALSE
--
--------------------------------------------------------------------
function Get_Visit_End_Time(
     p_visit_id    IN NUMBER,
     p_use_actuals IN VARCHAR2 := FND_API.G_TRUE
 )
RETURN DATE;

-----------------------------------------------------------
--Convert date+duration and department into end date/time
---------------------------------------------------------
FUNCTION Compute_Date(
  p_start_date date,
  p_dept_id number,
  p_duration number  := 0)
RETURN DATE;

--------------------------------------------------------------------
--  Function name    : Get_task_duration
--  Type             : Public
--  Purpose          : To return the total duration of the task
--                     based on the resource requirements.
--  Parameters  :
--       p_vst_task_qty   : Visit task quantity
--       p_route_id       : Route id
--
--  06/Jul/2007       Initial Version Sowmya B6182718
--
--  For Internal use only. The function is used in visit task time
--  calculation.
--------------------------------------------------------------------

Function Get_task_duration(
     p_vst_task_qty   IN   NUMBER,
     p_route_id       IN   NUMBER
 )
RETURN NUMBER;

END AHL_VWP_TIMES_PVT;

/
