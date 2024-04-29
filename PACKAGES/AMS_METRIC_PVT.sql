--------------------------------------------------------
--  DDL for Package AMS_METRIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_METRIC_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvmtcs.pls 120.1 2005/08/24 23:08:59 dmvincen noship $ */

--
-- Start of comments.
--
-- NAME
--   ams_metrics_pvt
--
-- PURPOSE
--   This package is a private package used for defining constants, records,
--   types and procedures for metrics API.
--
--   Procedures:
--   Create_Metric
--   Update_Metric
--   Lock_Metric
--   Delete_Metric
--   Validate_Metric
--
-- NOTES
--
--
-- HISTORY
-- 05/26/1999  choang    Created.
-- 06/07/1999  choang    Moved validate rec types from global package to module specs.
-- 06/14/1999  choang    Updated with changed columns and character case standards.
-- 07/05/1999  choang    Added vertical rollup engine.
-- 07/19/1999  choang    Added specifications for GetMetricVal, GetMetCatVal and SetCommittedVal.
-- 09/01/1999  choang    Made the following specs public: Validate_Metric_Items, IsSeeded,
--                       Validate_Metric_Child per request of ptendulk.
-- 10/11/1999  ptendulk  Modified According to new Standards, Also seperated Refresh Engine from
--           table Handlers
-- 01/18/2000  bgeorge   Reviewed code, made UOM non-required, removed function ISSEEDED
--                       from the specs
-- 17-Apr-2000 tdonohoe@us  Added columns to metric_rec_type to support 11.5.2 release.
-- 04-MAY-2000 khung     Remove number fixed width in metric_rec_type, where causing problem when
--                       using Rosetta.
-- 27-Dec-2001 dmvincen  complete_metric_rec need not be exposed.
-- 02-Dec-2002 dmvincen  Added NOCOPY.
-- 29-Aug-2003 dmvincen  Adding display type field.
-- 29-Aug-2003 dmvincen  Formula metric support.
-- Begin section added by choang - 05/26/1999
--
-- Start AMS_METRICS_ALL_VL
--
TYPE metric_rec_type
IS RECORD (
          metric_id                          NUMBER
          ,last_update_date                  DATE
          ,last_updated_by                   NUMBER
          ,creation_date                     DATE
          ,created_by                        NUMBER
          ,last_update_login                 NUMBER
          ,object_version_number             NUMBER
          ,application_id                   NUMBER
          ,arc_metric_used_for_object        VARCHAR2(30)
          ,metric_calculation_type           VARCHAR2(30)
          ,metric_category                   NUMBER
          ,accrual_type                      VARCHAR2(30)
          ,value_type                        VARCHAR2(30)
          ,sensitive_data_flag               VARCHAR2(1)
          ,enabled_flag                      VARCHAR2(1)
          ,metric_sub_category               NUMBER
          ,function_name                     VARCHAR2(4000)
          ,metric_parent_id                  NUMBER
          ,summary_metric_id                 NUMBER
          ,compute_using_function            VARCHAR2(4000)
          ,default_uom_code                  VARCHAR2(3)
          ,uom_type                          VARCHAR2(10)
          ,formula                           VARCHAR2(4000)
          ,metrics_name                      VARCHAR2(120)
          ,description                       VARCHAR2(4000)
          ,formula_display                   VARCHAR2(4000)
          ,hierarchy_id                      NUMBER
          ,set_function_name                 VARCHAR2(4000)
          ,display_type                      VARCHAR2(30)
          ,target_type                       VARCHAR2(30)
          ,denorm_code                       VARCHAR2(30));
--
-- End AMS_METRICS_ALL_VL
--
--
-- End of section added by choang.
--
--
-- End of comments.
--

-- Start of comments
-- API Name       Create_Metric
-- Type           Private
-- Pre-reqs       None.
-- Function       Creates a metric in AMS_METRICS_ALL_B given the
--                record for the metrics.
-- Parameters
--    IN          p_api_version                 IN NUMBER     Required
--                p_init_msg_list               IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                      IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level            IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_metric_rec                 IN metric_rec_type  Required
--    OUT         x_return_status               OUT VARCHAR2
--                x_msg_count                   OUT NUMBER
--                x_msg_data                    OUT VARCHAR2
--                x_metrics_id                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Create_Metric (
   p_api_version                IN    NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_metric_rec                IN  metric_rec_type,
   x_metric_id                  OUT NOCOPY NUMBER
);

-- Start of comments
-- API Name       Update_Metric
-- Type           Private
-- Pre-reqs       None.
-- Function       Updates a metric in AMS_METRICS_ALL_B given the
--                record for the metrics.
-- Parameters
--    IN          p_api_version                 IN NUMBER     Required
--                p_init_msg_list               IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                      IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level            IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_metric_rec                 IN metric_rec_type  Required
--    OUT         x_return_status               OUT VARCHAR2
--                x_msg_count                   OUT NUMBER
--                x_msg_data                    OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Update_Metric (
   p_api_version                IN    NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_metric_rec                 IN    metric_rec_type
);

-- Start of comments
-- API Name       Delete_Metric
-- Type           Private
-- Pre-reqs       None.
-- Function       Deletes a metric in AMS_METRICS_ALL_B given the
--                key identifier for the metric.
-- Parameters
--    IN          p_api_version              IN NUMBER     Required
--                p_init_msg_list            IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                   IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_metric_id               IN NUMBER  Required
--                p_object_version_number  IN number
--    OUT         x_return_status            OUT VARCHAR2
--                x_msg_count                OUT NUMBER
--                x_msg_data                 OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Delete_Metric (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_metric_id                IN  NUMBER,
   p_object_version_number    IN  NUMBER
);

-- Start of comments
-- API Name       Lock_Metric
-- Type           Private
-- Pre-reqs       None.
-- Function       Perform a row lock of the metrics identified in the
--                given row.
-- Parameters
--    IN          p_api_version            IN NUMBER     Required
--                p_init_msg_list          IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                 IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_metric_id           IN NUMBER  Required
--              p_object_version_number IN NUMBER
--    OUT         x_return_status          OUT VARCHAR2
--                x_msg_count              OUT NUMBER
--                x_msg_data               OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Lock_Metric (
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,

   p_metric_id             IN  NUMBER,
   p_object_version_number IN  NUMBER
);

-- Start of comments
-- API Name       Validate_Metric
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Metric
-- Parameters
--    IN          p_api_version            IN NUMBER     Required
--                p_init_msg_list          IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                 IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level       IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_metric_rec            IN metric_rec_type  Required
--    OUT         x_return_status          OUT VARCHAR2
--                x_msg_count              OUT NUMBER
--                x_msg_data               OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Validate_Metric (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_metric_rec                IN  metric_rec_type
);


-- Start of comments
-- API Name       Validate_Metric_Items
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Metric Items
-- Parameters
--    IN          p_metric_rec            IN metric_rec_type  Required
--                p_validate_mode          IN VARCHAR2
--    OUT         x_return_status          OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Validate_Metric_items(
   p_metric_rec        IN  metric_rec_type,
   p_validation_mode   IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status     OUT NOCOPY VARCHAR2
) ;

-- Start of comments
-- API Name       Validate_Metric_Record
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Metric Records
-- Parameters
--    IN          p_metric_rec            IN metric_rec_type  Required
--                p_complete_rec          IN metric_rec_type  Required
--    OUT         x_return_status          OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Validate_Metric_Record(
   p_metric_rec       IN  metric_rec_type,
   p_complete_rec     IN  metric_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
) ;


-- Start of comments
-- API Name       Validate_Metric_Child
-- Type           Private
-- Pre-reqs       None.
-- Function       Perform child entity validation for metrics
-- Parameters
--    IN          p_metrics_id            IN NUMBER  Required
--    OUT         x_return_status          OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Validate_Metric_Child (
   p_metric_id                       IN  NUMBER,
   x_return_status                    OUT NOCOPY VARCHAR2
);

-- Start of comments
-- API Name       Complete_Metric_Rec
-- Type           Private
-- Pre-reqs       None.
-- Function       This Process returns the details for the metric ID if
--               Not passed.
-- Parameters
--    IN          p_metric_rec            IN metric_rec_type  Required
--    OUT         x_complete_rec          OUT metric_rec_type
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
-- PROCEDURE Complete_Metric_Rec(
--    p_metric_rec      IN  metric_rec_type,
--    x_complete_rec    OUT metric_rec_type
-- );

END Ams_Metric_Pvt;

 

/
