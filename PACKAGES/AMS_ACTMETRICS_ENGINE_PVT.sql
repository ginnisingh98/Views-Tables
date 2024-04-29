--------------------------------------------------------
--  DDL for Package AMS_ACTMETRICS_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTMETRICS_ENGINE_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvmrns.pls 115.30 2003/11/04 23:59:00 asaha ship $ */

--
-- Start of comments.
--
-- NAME
--   AMS_ActMetrics_Engine_PVT
--
-- PURPOSE
--   This package contains modules for the concurrent program to refresh
--   activity metric values.

--
--   Procedures:
--   Build_Refresh_Act_Metrics
--   Check_Create_Rollup_Parents

--
-- NOTES
--
--
-- HISTORY
-- 26/03/2001    huili        Created
-- 21-May-2001   huili        Fix bugs for calculation for 11.5.4.07
-- 05-June-2001  huili        Add type definition for type
--                            "act_met_ref_rec_type"
-- 15-Jan-2002   huili        Added the "p_update_history" to the
--                            "Refresh_Act_Metrics_Engine" module.
-- 22-Aug-2003   dmvincen     Exposed APIs Run_functions, Update_Variable,
--                            and Update_formulas.
--
-- End of comments.
--

-- Start of comments
-- API Name       Run_Functions
-- Type           Public
-- Pre-reqs       None.
-- Function       Calculate metrics for changed values.
--
-- Parameters
--    IN          p_commit := FND_API.G_TRUE
--    OUT         x_errbuf             VARCHAR2
--                x_retcode            NUMBER
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
/*PROCEDURE Run_Functions
        (x_errbuf   OUT NOCOPY   VARCHAR2,
         x_retcode  OUT NOCOPY   NUMBER,
         p_commit   IN      VARCHAR2 := Fnd_Api.G_TRUE
);
*/
-- Start of comments
-- API Name       Refresh_Act_Metrics_Engine
-- Type           Public
-- Pre-reqs       None.
-- Function       Calculate metrics for changed values.
--
-- Parameters
--    IN          p_commit := FND_API.G_TRUE
--                                              p_run_functions := FND_API.G_TRUE
--    OUT         x_errbuf             VARCHAR2
--                x_retcode            NUMBER
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Refresh_Act_Metrics_Engine
          (x_errbuf        OUT NOCOPY    VARCHAR2,
           x_retcode       OUT NOCOPY    NUMBER,
           p_commit        IN     VARCHAR2 := Fnd_Api.G_TRUE,
           p_run_functions IN     VARCHAR2 := Fnd_Api.G_TRUE,
			  p_update_history IN    VARCHAR2 := Fnd_Api.G_FALSE
);

PROCEDURE Refresh_Act_Metrics_Engine
          (p_api_version           IN     NUMBER,
           p_init_msg_list         IN     VARCHAR2 := Fnd_Api.G_TRUE,
           p_commit                IN     VARCHAR2 := Fnd_Api.G_TRUE,
           x_return_status         IN OUT NOCOPY   VARCHAR2,
           x_msg_count             IN OUT NOCOPY   NUMBER,
           x_msg_data              IN OUT NOCOPY   VARCHAR2,
           p_arc_act_metric_used_by IN varchar2,
           p_act_metric_used_by_id IN number,
           p_run_functions         IN     VARCHAR2 := Fnd_Api.G_TRUE,
           p_update_history        IN    VARCHAR2 := Fnd_Api.G_FALSE
);

--
-- NAME
--    Exec_Function
--
-- PURPOSE
--    Executes a given function. Return the value calculated from the
--    given function if any.
--
-- NOTES
--    Use Native Dynamic SQL (8i feature) for executing the function.
--
-- HISTORY
-- 07/05/1999     choang            Created.
-- 08/29/2001     huili             Added non-parameter call for execution of
--                                  stored procedures. Expose to spec.
--
FUNCTION Exec_Function (
   p_activity_metric_id       IN NUMBER := NULL,
   p_function_name            IN VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2,
   p_arc_act_metric_used_by   IN varchar2 := NULL,
   p_act_metric_used_by_id    IN number := NULL
)RETURN NUMBER;

--
-- NAME
--    Update_history
--
-- PURPOSE
--    Updates AMS_ACT_METRIC_HST table against the current state.
--    Exposed for testing only.
--
-- NOTES
--
-- HISTORY
PROCEDURE Update_history(p_commit IN VARCHAR2);

-------------------------------------------------------------------------------
-- NAME
--    Run_Functions
-- PURPOSE
--    External API to run all the function with in a single object.
-- HISTORY
-- 22-Aug_2003 dmvincen Created.
-------------------------------------------------------------------------------
PROCEDURE Run_Functions (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_arc_act_metric_used_by     IN VARCHAR2,
   p_act_metric_used_by_id      IN NUMBER
);

-------------------------------------------------------------------------------
-- NAME
--    Update_Variable
-- PURPOSE
--    External API to calculate variable metrics with in a single object.
-- HISTORY
-- 22-Aug_2003 dmvincen Created.
-------------------------------------------------------------------------------
PROCEDURE Update_Variable (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_arc_act_metric_used_by     IN VARCHAR2,
   p_act_metric_used_by_id      IN NUMBER
);

-------------------------------------------------------------------------------
-- NAME
--    Update_formulas
-- PURPOSE
--    External API to calculate Formula metrics with in a single object.
-- HISTORY
-- 22-Aug_2003 dmvincen Created.
-------------------------------------------------------------------------------
PROCEDURE Update_formulas (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_arc_act_metric_used_by     IN VARCHAR2,
   p_act_metric_used_by_id      IN NUMBER
);

-- For testing not intended for public access.
--PROCEDURE test_get_object_list(p_output out nocopy varchar2);

--========================================================================
-- PROCEDURE
--    populate_all
-- Purpose
--    1. populates metrics all denorm table
--    2. refreshes yearly,weekly,monthly and quarterly materialized views
-- HISTORY
--    15-Oct-2003   asaha    Created.
--
--========================================================================
PROCEDURE populate_metrics_denorm(
                errbuf            OUT NOCOPY    VARCHAR2,
                retcode           OUT NOCOPY    NUMBER,
                p_run_incremental IN     VARCHAR2 := Fnd_Api.G_TRUE
);


END Ams_Actmetrics_Engine_Pvt;

 

/
