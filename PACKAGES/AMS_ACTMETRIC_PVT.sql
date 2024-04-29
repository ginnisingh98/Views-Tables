--------------------------------------------------------
--  DDL for Package AMS_ACTMETRIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTMETRIC_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvamts.pls 120.1 2005/12/16 16:22:29 dmvincen noship $ */

--
-- Start of comments.
--
-- NAME
--   Ams_ActMetrics_Pvt  11.5.6
--
-- PURPOSE
--   This package is a private package used for defining constants, records,
--   types and procedures for activity metrics API.
--
--   Procedures:
--   Create_ActMetric
--   Update_ActMetric
--   Lock_ActMetric
--   Delete_ActMetric
--   Validate_ActMetric
--   Complete_ActMetric_Rec
--   check_forecasted_cost
--   Get_Object_Info
--   Init_ActMetric_Rec
--   Get_Results
--   Convert_Currency
--   Convert_Currency2
--   Convert_Currency_Vector
--   Convert_Currency_Object
--   delete_act_metrics
-- NOTES
--
--
-- HISTORY
-- 06/26/1999  choang     Created.
-- 10/13/1999  ptendulk   Modified According to new standards.
-- 01/18/2000  bgeorge    Reviewed code, added new columns to the rec type,
--                        removed isseeded function from the spec
-- 04/17/2000  tdonohoe   Added new columns to the act_metric_rec_type to
--                        support hierarchy traversal.
-- 09/14/2000  sveerave@us Added check_forecasted_cost to check exceeding of
--                         forecasted cost
-- 10/11/2000  SVEERAVE@us added Init_ActMetric_Rec to initialize the record
--                         for update
-- 02/12/2001  dmvincen    Made Make_ActMetric_Dirty public for BUG#1603925.
-- 03/21/2001  huli       added the "description" and "act_metric_date" fields
-- 05/02/2001  dmvincen   Added Invalidate_Rollup. BUG#1753241.
-- 05/07/2001  huili      Added "depend_act_metric" field for act_metric_rec_type
-- 05/17/2001  dmvincen   Patch for 11.5.4.11 without variable metrics,
--                        description or transaction date (act_metric_date).
-- 05/23/2001  dmvincen   Added desc, trans date and variable metrics 11.5.5.
-- 08/21/2001  dmvincen   Exposed procedure Get_Trans_curr_code.
--                        Exposed procedure Convert_Currency.
--                        Exposed procedure Convert_Currency2.
-- 09/10/2001  huili      Added code to check status for all business objects.
-- 09/21/2001  huili      Added the "Get_Object_Info" module.
-- 11/27/2001  dmvincen   Added Get_Results for results cue card support.
-- 12/05/2001  DMVINCEN   Added Convert_Currency_Vector and
--                        Convert_Currency_Object for chart support.
-- 03/08/2002  DMVINCEN   Added function_used_by_id, arc_function_used_by.
-- 10/21/2002  YZHAO      11.5.9 add new columns for budget allocation
-- 17-Sep-2003 sunkumar Object level locking introduced
-- 10/02/2003  dmvincen   Added forecasted_variable_value.
-- 30-jan-2004 choang   bug 3410962: ALIST integration for deleting lists in
--                      a target group.
-- 20-Apr-2004 dmvincen  Added convert_to_trans_value for graph support.
-- 12/16/2005  dmvincen     BUG4868582: Expose Freeze status for UI.

-- Begin section added by choang - 05/26/1999
--
-- Start AMS_ACT_METRICS_ALL
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
       forecasted_variable_value        NUMBER,
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
       ex_start_node                    VARCHAR2(1)
       /* 05/15/2002 yzhao: add ends */
);

TYPE currency_table IS TABLE OF NUMBER;

--
-- End AMS_ACT_METRICS_ALL
--
--
-- End of section added by choang.
--
--
-- End of comments.
--

-- Start of comments
-- API Name       Have_Published
-- Type           Public
-- Pre-reqs       None.
-- Function       Check the status for a business object
-- Parameters
--    IN          p_obj_type            IN VARCHAR2     Required
--                p_obj_id              IN NUMBER       Required
--    OUT         x_flag                OUT VARCHAR2
-- Version        Current version: 1.0
-- End of comments

PROCEDURE Have_Published (
   p_obj_type     IN  VARCHAR2,
   p_obj_id       IN NUMBER,
   x_flag         OUT NOCOPY VARCHAR2
);

-- Start of comments
-- API Name       Get_Object_Info
-- Type           Public
-- Pre-reqs       None.
-- Function       Get object information
-- Parameters
--    IN          p_obj_type            IN VARCHAR2     Required
--                p_obj_id              IN NUMBER       Required
--    OUT         x_flag                OUT VARCHAR2
-- Version        Current version: 1.0
-- End of comments

PROCEDURE Get_Object_Info (
   p_obj_type     IN  VARCHAR2,
   p_obj_id       IN NUMBER,
   x_flag         OUT NOCOPY VARCHAR2,
   x_currency     OUT NOCOPY VARCHAR2
);


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
   x_act_metric_rec  IN OUT NOCOPY  ams_actmetric_pvt.Act_metric_rec_type
);

-- Start of comments
-- API Name       Create_ActMetric
-- Type           Private
-- Pre-reqs       None.
-- Function       Creates an association of a metric to a business
--                object by creating a record in AMS_ACT_METRICS_ALL.
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
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,
   --p_commit                     IN  VARCHAR2 := Fnd_Api.G_TRUE,
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
--                object by creating a record in AMS_ACT_METRICS_ALL.
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
-- API Name       Delete_ActMetric
-- Type           Private
-- Pre-reqs       None.
-- Function       Deletes the association of a metric to a business
--                object by creating a record in AMS_ACT_METRICS_ALL.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_arc_act_metric_used_by    IN VARCHAR2  Required
--                p_act_metric_used_by_id     IN NUMBER    Required
--                p_activity_metric_id        IN NUMBER    NULL (never set!)
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Delete_ActMetric (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                   IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_arc_act_metric_used_by   IN  VARCHAR2,
   p_act_metric_used_by_id    IN  NUMBER,
   p_activity_metric_id       IN  NUMBER := NULL,
   p_object_version_number    IN  NUMBER := NULL
);

-- Start of comments
-- API Name       Delete_ActMetric
-- Type           Private
-- Pre-reqs       None.
-- Function       Deletes the association of a metric to a business
--                object by creating a record in AMS_ACT_METRICS_ALL.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_activity_metric_id        IN NUMBER  Required
--                p_object_version_number         IN NUMBER
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Delete_ActMetric (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                   IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_activity_metric_id       IN  NUMBER,
   p_object_version_number    IN  NUMBER
);

-- Start of comments
-- API Name       Lock_ActMetric
-- Type           Private
-- Pre-reqs       None.
-- Function       Lock the given row in AMS_ACT_METRICS_ALL.
-- Parameters
--    IN          p_api_version           IN NUMBER     Required
--                p_init_msg_list         IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_activity_metric_id    IN NUMBER  Required
--                p_object_version_number IN NUMBER      Required
--    OUT         x_return_status         OUT VARCHAR2
--                x_msg_count             OUT NUMBER
--                x_msg_data              OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Lock_ActMetric (
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,

   p_activity_metric_id    IN  NUMBER,
   p_object_version_number IN  NUMBER
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

-- Start of comments
-- API Name       SetCommittedVal
-- Type           Private
-- Pre-reqs       None.
-- Function       Updates the functional committed value of a specific
--                        metric that is associated with the given business
--                        entity.
-- Parameters
--    IN   p_api_version                         IN      NUMBER
--         p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE
--         p_commit                  IN  VARCHAR2 := FND_API.G_FALSE
--         p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
--         p_arc_act_metric_used_by      IN      VARCHAR2  Required
--         p_act_metric_used_by_id       IN      NUMBER  Required
--         p_metric_id                           IN      NUMBER  Required
--         p_func_committed_value        IN      NUMBER  Required
--    OUT  x_return_status               OUT VARCHAR2
--         x_msg_count               OUT NUMBER
--         x_msg_data                OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE SetCommittedVal (
   p_api_version                 IN NUMBER,
   p_init_msg_list               IN VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                      IN VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level            IN NUMBER   := Fnd_Api.G_VALID_LEVEL_FULL,

   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,

   p_arc_act_metric_used_by      IN VARCHAR2,
   p_act_metric_used_by_id       IN NUMBER,
   p_metric_id                   IN NUMBER,
   p_func_committed_value        IN NUMBER
);

-- Start of comments
-- API Name       Default_Func_Currency
-- Type           Private
-- Pre-reqs       None.
-- Function       Returns the functional Currency of the transaction.
--
-- Parameters
--    OUT         Default Functional Currency
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
FUNCTION Default_Func_Currency
RETURN VARCHAR2 ;

-- Start of comments
-- API Name       check_forecasted_cost
-- Type           Private
-- Pre-reqs       None.
-- Function       Checks forecasted amount against object's budget amount,
--                and passes out message in case it is exceeded.
--
-- PARAMETERS
        --p_obj_type    IN      VARCHAR2,
        --p_obj_id      IN      NUMBER,
        --p_category_id IN      NUMBER,
        --p_exceeded    OUT NOCOPY     VARCHAR2,
        --p_message     OUT NOCOPY     VARCHAR2)
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE check_forecasted_cost(p_obj_type      IN      VARCHAR2,
                                p_obj_id        IN      NUMBER,
                                p_category_id   IN      NUMBER,
                                x_exceeded      OUT NOCOPY     VARCHAR2,
                                x_message       OUT NOCOPY     VARCHAR2) ;


PROCEDURE Sync_rollup_currency
  (p_obj_id                     IN  NUMBER
  ,p_obj_type                   IN  VARCHAR2
  ,x_return_status              OUT NOCOPY VARCHAR2
  ) ;

-- BUG#1603925: Added for Called from
--                               AMS_refreshMetric_PVT.create_refresh_parent_level().
PROCEDURE Make_ActMetric_Dirty (
  p_activity_metric_id IN NUMBER
);

--
-- Start of comments
-- API Name       Invalidate_Rollup
-- Type           Private
-- Pre-reqs       None.
-- Function       Set rollup pointers to null when parent object is changed.
--
-- PARAMETERS
--   p_used_by_type - eg. 'CAMP', 'EVEO', etc.
--   p_used_by_id - The identifier for the object.
-- End of comments
--
PROCEDURE Invalidate_Rollup(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := Fnd_Api.g_false,
   p_commit            IN  VARCHAR2 := Fnd_Api.G_FALSE,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_used_by_type      IN VARCHAR2,
   p_used_by_id        IN NUMBER
);

--
-- Start of comments
-- API Name       Post_Costs
-- Type           Private
-- Pre-reqs       None.
-- Function       Post costs to budget.
--
-- PARAMETERS
--   p_used_by_type - eg. 'CAMP', 'EVEO', etc.
--   p_used_by_id - The identifier for the object.
-- End of comments
--
PROCEDURE Post_Costs (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                     IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER := Fnd_Api.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_obj_type                   IN  VARCHAR2,
   p_obj_id                     IN  NUMBER
);

-- ---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency
-- DESCRIPTION
--    This procedure is copied from GL_CURRENCY_API so that rounding can be
--    controlled.  The functional currency need not be rounded because
--    precision will be lost when converting to other currencies.
--    The displayed currencies must be rounded.
-- NOTE
--    Modified from code done by ptendulk, and choang.
-- HISTORY
-- 09-Aug-2001 dmvincen      Created.
---------------------------------------------------------------------
PROCEDURE Convert_Currency (
   x_return_status      OUT NOCOPY VARCHAR2,
   p_from_currency      IN  VARCHAR2,
   p_to_currency        IN  VARCHAR2,
   p_conv_date          IN  DATE DEFAULT SYSDATE,
   p_from_amount        IN  NUMBER,
   x_to_amount          OUT NOCOPY NUMBER,
   p_round              IN VARCHAR2
);
PROCEDURE Convert_Currency2 (
   x_return_status      OUT NOCOPY VARCHAR2,
   p_from_currency      IN  VARCHAR2,
   p_to_currency        IN  VARCHAR2,
   p_conv_date          IN  DATE DEFAULT SYSDATE,
   p_from_amount        IN  NUMBER,
   x_to_amount          OUT NOCOPY NUMBER,
   p_from_amount2       IN  NUMBER,
   x_to_amount2         OUT NOCOPY NUMBER,
   p_round              IN VARCHAR2
);
PROCEDURE Convert_Currency_Vector (
   x_return_status      OUT NOCOPY VARCHAR2,
   p_from_currency      IN  VARCHAR2,
   p_to_currency        IN  VARCHAR2,
   p_conv_date          IN  DATE DEFAULT SYSDATE,
   p_amounts            IN OUT NOCOPY CURRENCY_TABLE,
   p_round              IN VARCHAR2 DEFAULT FND_API.G_TRUE
);
PROCEDURE Convert_Currency_Object (
   x_return_status      OUT NOCOPY VARCHAR2,
   p_object_id          IN  NUMBER,
   p_object_type        IN  VARCHAR2,
   p_conv_date          IN  DATE DEFAULT SYSDATE,
   p_amounts            IN OUT NOCOPY CURRENCY_TABLE,
   p_round              IN VARCHAR2 DEFAULT FND_API.G_TRUE
);

-- ---------------------------------------------------------------------
-- PROCEDURE
--    Convert_to_trans_value
-- DESCRIPTION
--    Returns the transaction with conversion from the func value.
-- NOTE
--
-- HISTORY
-- 20-Apr-2004 dmvincen Created.
---------------------------------------------------------------------
FUNCTION convert_to_trans_value(
   p_func_value in NUMBER,
   p_object_type in VARCHAR2,
   p_object_id in NUMBER,
   p_display_type in VARCHAR2
   )
return NUMBER;

-- ---------------------------------------------------------------------
-- PROCEDURE
--    Get_Trans_curr_code
-- DESCRIPTION
--    Returns the transaction currency code for the given object.
-- NOTE
--
-- HISTORY
-- 09-Aug-2001 dmvincen      Created.
---------------------------------------------------------------------
PROCEDURE Get_Trans_curr_code
  (p_obj_id                     IN  NUMBER
  ,p_obj_type                   IN  VARCHAR2
  ,x_trans_curr_code            OUT NOCOPY VARCHAR2
  );

-- Record for results cue card detail.
TYPE result_record IS RECORD
(
   slice_date DATE,
   currency_code VARCHAR2(15),
   forecasted_value NUMBER,
   actual_value NUMBER
);

-- Table for results cue card detail.
TYPE result_table IS TABLE OF result_record;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Results
-- DESCRIPTION
--    Return the results for results cue card.
--    Output only.  No updates.
-- NOTE
-- HISTORY
-- 27-NOV-2001 dmvincen      Created.
---------------------------------------------------------------------
PROCEDURE GET_RESULTS(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_metric_id IN NUMBER,
   p_object_type IN VARCHAR2,
   p_object_id IN NUMBER,
   p_value_type IN VARCHAR2,
   p_from_date IN DATE,
   p_to_date IN DATE,
   p_increment IN NUMBER,
   p_interval_unit IN VARCHAR2,
   x_result_table OUT NOCOPY result_table
);





--======================================================================
-- procedure
--    copy_act_metrics
--
-- PURPOSE
--    Created to copy activity metrics
--
-- HISTORY
--    13-may-2003 sunkumar created
--    17-jul-2003 sunkumar bug# 3050304 (default value of p_commit should match in package and body)
--======================================================================


procedure copy_act_metrics (
   p_api_version            IN   NUMBER,
   p_init_msg_list          IN   VARCHAR2     := FND_API.G_FALSE,
   p_commit                 IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level       IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,
   p_source_object_type     IN   VARCHAR2,
   p_source_object_id       IN   NUMBER,
   p_target_object_id       IN   NUMBER,
   x_return_status          OUT NOCOPY  VARCHAR2,
   x_msg_count              OUT NOCOPY  NUMBER,
   x_msg_data               OUT NOCOPY  VARCHAR2
);

--======================================================================
-- procedure
--    validate_objects
--
-- PURPOSE
--    Created to validate the values while copying activity metrics
--
-- HISTORY
--    13-may-2003 sunkumar created
--======================================================================

procedure validate_objects(
p_api_version                IN   NUMBER,
p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,
p_source_object_type         IN   VARCHAR2,
p_source_object_id           IN   NUMBER,
p_target_object_id           IN   NUMBER,
x_return_status              OUT NOCOPY  VARCHAR2,
x_msg_count                  OUT NOCOPY  NUMBER,
x_msg_data                   OUT NOCOPY  VARCHAR2
);


FUNCTION Lock_Object(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_arc_act_metric_used_by     IN VARCHAR2,
   p_act_metric_used_by_id      IN NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2)
return varchar2;


--
-- PROCEDURE
--    delete_actmetrics_assoc
--
-- DESCRIPTION
--    Delete all activity metrics associated to the given object.
--
-- REQUIREMENT
--    bug 3410962: ALIST integration for deleting lists from target group
--
-- HISTORY
-- 30-Jan-2004 choang   Created.
--
PROCEDURE delete_actmetrics_assoc (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
   p_commit          IN VARCHAR2 := FND_API.G_FALSE,
   p_object_type     IN VARCHAR2,
   p_object_id       IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2
);

--
-- FUNCTION
--   CAN_POST_TO_BUDGET
--
-- DESCRIPTION
--   Determine if the object has an approved budget and the correct status
--   for posting costs to budgets.
--
--  REQUIREMENT
--   BUG 4868582: Post to budget only with actual values entered.
--
--  RETURN
--    VARCHAR2 - TRUE, FALSE
-- HISTORY
--   15-Dec-2005 dmvincen  Created.
FUNCTION CAN_POST_TO_BUDGET(p_object_type IN VARCHAR2, p_object_id IN NUMBER)
RETURN VARCHAR2
;

--
-- FUNCTION
--   IS_FROZEN
--
-- DESCRIPTION
--   Determine if the object is frozen by the status.
--
-- RETURN
--   VARCHAR2 - TRUE, FALSE
--
--  REQUIREMENT
--   BUG 4865673: Post to budget only with actual values entered.
--
-- HISTORY
--   15-Dec-2005 dmvincen  Created.
FUNCTION Check_Freeze_Status (
   p_object_type     IN  VARCHAR2,
   p_object_id       IN  NUMBER,
   p_operation_mode  IN  VARCHAR2)  -- 'C','U','D' for Create, Update, or Delete
RETURN VARCHAR2
;

END Ams_Actmetric_Pvt;

 

/
