--------------------------------------------------------
--  DDL for Package OZF_ACTMETRIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ACTMETRIC_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvamts.pls 115.1 2003/10/07 18:44:02 yzhao noship $ */

--
-- Start of comments.
--
-- NAME
--   Ozf_ActMetrics_Pvt  11.5.6
--
-- PURPOSE
--   This package is a private package used for defining constants, records,
--   types and procedures for activity metrics API.
--
--   Procedures:
--   Create_ActMetric
--   Update_ActMetric
--   Validate_ActMetric
--   Complete_ActMetric_Rec
--   Init_ActMetric_Rec
-- NOTES
--
--
-- HISTORY
-- 10/07/2002   KDASS/YZHAO      migrate to ozf from ams_actmetrics_all

-- Begin section added by choang - 05/26/1999
--
-- Start OZF_ACT_METRICS_ALL
--
TYPE act_metric_rec_type
IS RECORD (
       activity_metric_id               NUMBER,
       last_update_date                 DATE,
       last_updated_by                  NUMBER,
       creation_date                    DATE,
       created_by                       NUMBER,
       last_update_login                NUMBER,
       object_version_number            NUMBER,
       act_metric_used_by_id            NUMBER,
       arc_act_metric_used_by           VARCHAR2(30),
       purchase_req_raised_flag         VARCHAR2(1),
       application_id                   NUMBER,
       sensitive_data_flag              VARCHAR2(1),
       budget_id                        NUMBER,
       metric_id                        NUMBER,
       transaction_currency_code        VARCHAR2(15),
       trans_forecasted_value           NUMBER,
       trans_committed_value            NUMBER,
       trans_actual_value               NUMBER,
       functional_currency_code         VARCHAR2(15),
       func_forecasted_value            NUMBER,
       dirty_flag                       VARCHAR2(1),
       func_committed_value             NUMBER,
       func_actual_value                NUMBER,
       last_calculated_date             DATE,
       variable_value                   NUMBER,
       computed_using_function_value    NUMBER,
       metric_uom_code                  VARCHAR2(3),
       org_id                           NUMBER,
       difference_since_last_calc       NUMBER,
       activity_metric_origin_id        NUMBER,
       arc_activity_metric_origin       VARCHAR2(30),
       days_since_last_refresh          NUMBER,
       scenario_id                      NUMBER,
       SUMMARIZE_TO_METRIC              NUMBER,
       ROLLUP_TO_METRIC                 NUMBER,
       hierarchy_id                     NUMBER,
         start_node                  NUMBER,
         from_level                  NUMBER,
         to_level                    NUMBER,
         from_date                   DATE,
         TO_DATE                     DATE,
         amount1                     NUMBER,
         amount2                     NUMBER,
         amount3                     NUMBER,
         percent1                    NUMBER,
         percent2                    NUMBER,
         percent3                    NUMBER,
         published_flag              VARCHAR2(1),
         pre_function_name           VARCHAR2(4000),
         post_function_name          VARCHAR2(4000),
       attribute_category               VARCHAR2(30),
       attribute1                       VARCHAR2(150),
       attribute2                       VARCHAR2(150),
       attribute3                       VARCHAR2(150),
       attribute4                       VARCHAR2(150),
       attribute5                       VARCHAR2(150),
       attribute6                       VARCHAR2(150),
       attribute7                       VARCHAR2(150),
       attribute8                       VARCHAR2(150),
       attribute9                       VARCHAR2(150),
       attribute10                      VARCHAR2(150),
       attribute11                      VARCHAR2(150),
       attribute12                      VARCHAR2(150),
       attribute13                      VARCHAR2(150),
       attribute14                      VARCHAR2(150),
       attribute15                      VARCHAR2(150),
       description                      VARCHAR2(4000),
       act_metric_date                  DATE,
       depend_act_metric                NUMBER,
       FUNCTION_USED_BY_ID              NUMBER,
       ARC_FUNCTION_USED_BY             VARCHAR2(30),
       /* 05/15/2002 yzhao: add 6 new columns for top-down bottom-up budgeting */
       hierarchy_type                   VARCHAR2(30),
       status_code                      VARCHAR2(30),
       method_code                      VARCHAR2(30),
       action_code                      VARCHAR2(30),
       basis_year                       NUMBER,
       ex_start_node                    VARCHAR2(1),
       /* 05/15/2002 yzhao: add ends */
       -- kdass added
       product_spread_time_id		NUMBER,
       start_period_name		VARCHAR2(30),
       end_period_name			VARCHAR2(30)
);


--
-- End OZF_ACT_METRICS_ALL
--
--
-- End of section added by choang.
--
--
-- End of comments.
--

-- Start of comments
-- NAME
--    Init_ActMetric_Rec
--
-- PURPOSE
--    This Procedure will initialize the Record for Activity Metric.
--    It will be called before call to Update Activity Metric
--
-- NOTES
--
-- HISTORY
-- 10/11/2000   SVEERAVE         Created.
--
-- End of comments

PROCEDURE Init_ActMetric_Rec(
   x_act_metric_rec  IN OUT NOCOPY  ozf_actmetric_pvt.Act_metric_rec_type
);

-- Start of comments
-- API Name       Create_ActMetric
-- Type           Private
-- Pre-reqs       None.
-- Function       Creates an association of a metric to a business
--                object by creating a record in OZF_ACT_METRICS_ALL.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level          IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_act_metric_rec           IN act_metric_rec_type  Required
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Create_ActMetric (
   p_api_version                IN      NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   --p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_TRUE,
	p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_rec             IN  act_metric_rec_type,
   x_activity_metric_id         OUT NOCOPY NUMBER
);

-- Start of comments
-- API Name       Update_ActMetric
-- Type           Private
-- Pre-reqs       None.
-- Function       Updates the association of a metric to a business
--                object by creating a record in OZF_ACT_METRICS_ALL.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level          IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_act_metric_rec           IN act_metric_rec_type Required
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Update_ActMetric (
   p_api_version                IN      NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_rec             IN      act_metric_rec_type
);

-- Start of comments
-- API Name       Validate_ActMetric
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate items in metrics associated with business
--                objects.
-- Parameters
--    IN          p_api_version           IN NUMBER     Required
--                p_init_msg_list         IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level      IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_act_metric_rec        IN act_metric_rec_type  Required
--    OUT         x_return_status         OUT VARCHAR2
--                x_msg_count             OUT NUMBER
--                x_msg_data              OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Validate_ActMetric (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_rec            IN  act_metric_rec_type
);


-- Start of comments
-- API Name       Validate_ActMetric_Items
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Activity Metric Items
-- Parameters
--    IN          p_act_metric_rec         IN act_metric_rec_type  Required
--                p_validate_mode                  IN VARCHAR2
--    OUT         x_return_status          OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Validate_ActMetric_items(
   p_act_metric_rec    IN  act_metric_rec_type,
   p_validation_mode   IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
   x_return_status     OUT NOCOPY VARCHAR2
) ;

-- Start of comments
-- API Name       Validate_ActMetric_Record
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Activity Metric Records
-- Parameters
--    IN          p_act_metric_rec        IN act_metric_rec_type  Required
--                p_complete_rec          IN act_metric_rec_type  Required
--    OUT         x_return_status         OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Validate_ActMetric_record(
   p_act_metric_rec   IN  act_metric_rec_type,
   p_complete_rec     IN  act_metric_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
) ;


-- Start of comments
-- API Name       Complete_ActMetric_Rec
-- Type           Private
-- Pre-reqs       None.
-- Function       This Process returns the details for the Activity metric ID if
--                Not passed.
-- Parameters
--    IN          p_act_metric_rec         IN act_metric_rec_type  Required
--    OUT         x_complete_rec           OUT act_metric_rec_type
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Complete_ActMetric_Rec(
   p_act_metric_rec      IN  act_metric_rec_type,
   x_complete_rec        IN OUT NOCOPY act_metric_rec_type
);


END ozf_actmetric_pvt;

 

/
