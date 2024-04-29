--------------------------------------------------------
--  DDL for Package AMS_ACTMETRIC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTMETRIC_PUB" AUTHID CURRENT_USER AS
/* $Header: amspamts.pls 120.1 2005/06/27 05:39:01 appldev ship $ */
/*#
 * This package provides methods to create, update, or delete marketing
 * activity metrics.
 *
 * Note: The activity metrics record type is used as an input parameter for
 * create and update methods.
 *
 * PACKAGE AMS_ACTMETRIC_PVT
 * TYPE act_metric_rec_type is RECORD (
 *  activity_metric_id            NUMBER,
 *  last_update_date              DATE,
 *  last_updated_by               NUMBER,
 *  creation_date                 DATE,
 *  created_by                    NUMBER,
 *  last_update_login             NUMBER,
 *  object_version_number         NUMBER,
 *  act_metric_used_by_id         NUMBER,
 *  arc_act_metric_used_by        VARCHAR2(30),
 *  purchase_req_raised_flag      VARCHAR2(1),
 *  application_id                NUMBER,
 *  sensitive_data_flag           VARCHAR2(1),
 *  budget_id                     NUMBER,
 *  metric_id                     NUMBER,
 *  transaction_currency_code     VARCHAR2(15),
 *  trans_forecasted_value        NUMBER,
 *  trans_committed_value         NUMBER,
 *  trans_actual_value            NUMBER,
 *  functional_currency_code      VARCHAR2(15),
 *  func_forecasted_value         NUMBER,
 *  dirty_flag                    VARCHAR2(1),
 *  func_committed_value          NUMBER,
 *  func_actual_value             NUMBER,
 *  last_calculated_date          DATE,
 *  variable_value                NUMBER,
 *  forecasted_variable_value     NUMBER,
 *  computed_using_function_value NUMBER,
 *  metric_uom_code               VARCHAR2(3),
 *  org_id                        NUMBER,
 *  difference_since_last_calc    NUMBER,
 *  activity_metric_origin_id     NUMBER,
 *  arc_activity_metric_origin    VARCHAR2(30),
 *  days_since_last_refresh       NUMBER,
 *  scenario_id                   NUMBER,
 *  SUMMARIZE_TO_METRIC           NUMBER,
 *  ROLLUP_TO_METRIC              NUMBER,
 *  hierarchy_id                  NUMBER,
 *  start_node                    NUMBER,
 *  from_level                    NUMBER,
 *  to_level                      NUMBER,
 *  from_date                     DATE,
 *  TO_DATE                       DATE,
 *  amount1                       NUMBER,
 *  amount2                       NUMBER,
 *  amount3                       NUMBER,
 *  percent1                      NUMBER,
 *  percent2                      NUMBER,
 *  percent3                      NUMBER,
 *  published_flag                VARCHAR2(1),
 *  pre_function_name             VARCHAR2(4000),
 *  post_function_name            VARCHAR2(4000),
 *  attribute_category            VARCHAR2(30),
 *  attribute1                    VARCHAR2(150),
 *  attribute2                    VARCHAR2(150),
 *  attribute3                    VARCHAR2(150),
 *  attribute4                    VARCHAR2(150),
 *  attribute5                    VARCHAR2(150),
 *  attribute6                    VARCHAR2(150),
 *  attribute7                    VARCHAR2(150),
 *  attribute8                    VARCHAR2(150),
 *  attribute9                    VARCHAR2(150),
 *  attribute10                   VARCHAR2(150),
 *  attribute11                   VARCHAR2(150),
 *  attribute12                   VARCHAR2(150),
 *  attribute13                   VARCHAR2(150),
 *  attribute14                   VARCHAR2(150),
 *  attribute15                   VARCHAR2(150),
 *  description                   VARCHAR2(4000),
 *  act_metric_date               DATE,
 *  depend_act_metric             NUMBER,
 *  FUNCTION_USED_BY_ID           NUMBER,
 *  ARC_FUNCTION_USED_BY          VARCHAR2(30),
 *  hierarchy_type                VARCHAR2(30),
 *  status_code                   VARCHAR2(30),
 *  method_code                   VARCHAR2(30),
 *  action_code                   VARCHAR2(30),
 *  basis_year                    NUMBER,
 *  ex_start_node                 VARCHAR2(1)
 *   );
 *
 * @rep:scope public
 * @rep:product AMS
 * @rep:displayname Oracle Marketing Activity Metrics Public API
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY AMS_CAMPAIGN
 */

---------------------------------------------------------------------
-- PROCEDURE
--    Create_ActMetric
--
-- PURPOSE
--    Create a new Activity Metric.
--
-- PARAMETERS
--    p_act_metric_rec: the new record to be inserted
--    x_activity_metric_id: return the activity_metric_id of the
--                      new Activity Metrics
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If Activity_Metric_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If Activity_Metric_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
/*#
 * This procedure creates a marketing activity metric.  Details of the
 * activity metric are passed as p_act_metric_rec record type.  Check
 * the x_return_status output to see if the creation was successful.  If
 * successful, a unique identifier for the activity metric will be passed
 * back to the x_activity_metric_id output parameter.
 * @param p_api_version   This must match the version number of the API.  An
 *                        unexpected error is returned if the calling program
 *                        version number is incompatible with the current API
 *                        version number.
 * @param p_init_msg_list Flag to indicate if the message stack should be
 *                        initialized.
 * @param p_commit        Flag to indicate if changes should be commited on
 *                        success.
 * @param p_validation_level Level of validation required.  None: No
 *                        validation will be performed.  Full: Item and record
 *                        level validation will be performed.
 * @param x_return_status Indicates the return status of the API.  The values
 *                        are one of the following: FND_API.G_RET_SUCCESS:
 *                        Indicates the API call was successful,
 *                        FND_API.G_RET_ERROR: indicates an error has occured,
 *                        FND_API.G_RET_UNEXPECTED: indicates an unexpected
 *                        error has occurred.
 * @param x_msg_count     Count of the number of error messages in the list.
 * @param x_msg_data      Error messages returned by the API.  If more than
 *                        one message is returned, this parameter is null and
 *                        messages can be extracted from the message stack.
 * @param p_act_metric_rec Record of type AMS_ACTMETRIC_PVT.ACT_METRIC_REC_TYPE
 *                        that takes the details for the Activity Metric.
 * @param x_activity_metric_id Unique identifier for the newly created
 *                        Activity Metric.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Activity Metric
 */
PROCEDURE Create_ActMetric(
   p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2  := FND_API.g_false,
   p_commit                  IN  VARCHAR2  := FND_API.g_false,
   p_validation_level        IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,

   p_act_metric_rec        IN  AMS_ActMetric_PVT.act_metric_rec_type,
   x_activity_metric_id    OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_ActMetric
--
-- PURPOSE
--    Delete a ActMetric.
--
-- PARAMETERS
--    p_acticity_metric_id: the Activity_Metric_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
/*#
 * This procedure deletes a marketing activity metric.  The activity metric
 * is identified by the parameter p_activity_metric_id.  The object version
 * number must match the current value within the database for this activity
 * metric or an error is returned.  Check the x_return_status output to see
 * if the deletion was successful.
 * @param p_api_version   This must match the version number of the API.  An
 *                        unexpected error is returned if the calling program
 *                        version number is incompatible with the current API
 *                        version number.
 * @param p_init_msg_list Flag to indicate if the message stack should be
 *                        initialized.
 * @param p_commit        Flag to indicate if changes should be commited on
 *                        success.
 * @param x_return_status Indicates the return status of the API.  The values
 *                        are one of the following: FND_API.G_RET_SUCCESS:
 *                        Indicates the API call was successful,
 *                        FND_API.G_RET_ERROR: indicates an error has occured,
 *                        FND_API.G_RET_UNEXPECTED: indicates an unexpected
 *                        error has occurred.
 * @param x_msg_count     Count of the number of error messages in the list.
 * @param x_msg_data      Error messages returned by the API.  If more than
 *                        one message is returned, this parameter is null and
 *                        messages can be extracted from the message stack.
 * @param p_activity_metric_id Unique id of activity metric to delete.
 * @param p_object_version Current object version number.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Activity Metric
 */
PROCEDURE Delete_ActMetric(
   p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.g_false,
   p_commit                  IN  VARCHAR2 := FND_API.g_false,

   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,

   p_activity_metric_id    IN  NUMBER,
   p_object_version        IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_ActMetric
--
-- PURPOSE
--    Lock a Activity Metric.
--
-- PARAMETERS
--    p_activity_Metric_id: the Activity_Metric_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_ActMetric(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.g_false,

   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,

   p_activity_metric_id  IN  NUMBER,
   p_object_version        IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_ActMetric
--
-- PURPOSE
--    Update a Activity Metric.
--
-- PARAMETERS
--    p_ActMetric_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
/*#
 * This procedure updates a marketing activity metric.  Details of the
 * activity metric are passed as p_act_metric_rec record type.  Check
 * the x_return_status output to see if the update was successful.  The record
 * requires the Activity_metric_id and the current object_version_number
 * to be filled in.  Other fields are optional, but must be set to
 * FND_API.G_MISS_... if they are not to be changed.
 * @param p_api_version   This must match the version number of the API.  An
 *                        unexpected error is returned if the calling program
 *                        version number is incompatible with the current API
 *                        version number.
 * @param p_init_msg_list Flag to indicate if the message stack should be
 *                        initialized.
 * @param p_commit        Flag to indicate if changes should be commited on
 *                        success.
 * @param p_validation_level Level of validation required.  None: No validation
 *                        will be performed.  Full: Item and record level
 *                        validation will be performed.
 * @param x_return_status Indicates the return status of the API.  The values
 *                        are one of the following: FND_API.G_RET_SUCCESS:
 *                        Indicates the API call was successful,
 *                        FND_API.G_RET_ERROR: indicates an error has occured,
 *                        FND_API.G_RET_UNEXPECTED: indicates an unexpected
 *                        error has occurred.
 * @param x_msg_count     Count of the number of error messages in the list.
 * @param x_msg_data      Error messages returned by the API.  If more than one
 *                        message is returned, this parameter is null and
 *                        messages can be extracted from the message stack.
 * @param p_act_metric_rec Record of type AMS_ACTMETRIC_PVT.ACT_METRIC_REC_TYPE
 *                        that takes the details for the Activity Metric.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Activity Metric
 */
PROCEDURE Update_ActMetric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_act_metric_rec    IN  AMS_ActMetric_PVT.act_metric_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_ActMetric
--
-- PURPOSE
--    Validate a Activity Metric record.
--
-- PARAMETERS
--    p_act_metric_rec: the Activity Metric record to be validated
--
-- NOTES
--    1. p_act_metric_rec should be the complete metric record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Validate_ActMetric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_act_metric_rec    IN  AMS_ActMetric_PVT.act_metric_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Invalidate_Rollup
--
-- PURPOSE
--    Invalidate to rollup pointers.
--
-- PARAMETERS
--    p_act_metric_rec: the Activity Metric record to be validated
--
-- NOTES
--    1. p_act_metric_rec should be the complete metric record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Invalidate_Rollup(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_used_by_type      IN VARCHAR2,
   p_used_by_id        IN NUMBER
);


END AMS_ActMetric_PUB;

 

/
