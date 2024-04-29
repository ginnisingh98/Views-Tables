--------------------------------------------------------
--  DDL for Package AMS_METRIC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_METRIC_PUB" AUTHID CURRENT_USER AS
/* $Header: amspmtcs.pls 120.1 2005/06/27 05:39:12 appldev ship $ */
/*#
 * This package provides methods to create marketing metrics.  Note:
 * The metric record type is used as an input parameter to create a metric.
 *
 * PACKAGE AMS_METRIC_PVT
 * TYPE metric_rec_type
 * IS RECORD (
 *        metric_id                          NUMBER,
 *        last_update_date                  DATE,
 *        last_updated_by                   NUMBER,
 *        creation_date                     DATE,
 *        created_by                        NUMBER,
 *        last_update_login                 NUMBER,
 *        object_version_number             NUMBER,
 *        application_id                    NUMBER,
 *        arc_metric_used_for_object        VARCHAR2(30),
 *        metric_calculation_type           VARCHAR2(30),
 *        metric_category                   NUMBER,
 *        accrual_type                      VARCHAR2(30),
 *        value_type                        VARCHAR2(30),
 *        sensitive_data_flag               VARCHAR2(1),
 *        enabled_flag                      VARCHAR2(1),
 *        metric_sub_category               NUMBER,
 *        function_name                     VARCHAR2(4000),
 *        metric_parent_id                  NUMBER,
 *        summary_metric_id                 NUMBER,
 *        compute_using_function            VARCHAR2(4000),
 *        default_uom_code                  VARCHAR2(3),
 *        uom_type                          VARCHAR2(10),
 *        formula                           VARCHAR2(4000),
 *        metrics_name                      VARCHAR2(120),
 *        description                       VARCHAR2(4000),
 *        formula_display                   VARCHAR2(4000),
 *        hierarchy_id                      NUMBER,
 *        set_function_name                 VARCHAR2(4000),
 *        display_type                      VARCHAR2(30)
 *     );
 * @rep:scope public
 * @rep:product AMS
 * @rep:displayname Oracle Marketing Metrics Definition Public API
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY AMS_CAMPAIGN
 */

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Metric
--
-- PURPOSE
--    Create a new Metric.
--
-- PARAMETERS
--    p_metric_rec: the new record to be inserted
--    x_metric_id: return the metric_id of the new metrics
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If Metric_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If Metric_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
/*#
 * This procedure creates a marketing metric.  The details of the metric will
 * be passed in the p_metric_rec record.  Check x_return_status output to
 * see if the creation was successful.  If successful an unique identifier
 * for the metric will be passed back to the x_metric_id output parameter.
 * @param p_api_version    This must match the version number of the API.  An
 *                         unxpected error is returned if the calling program
 *                         version number is incompatible with the current API
 *                         version number.
 * @param p_init_msg_list  Flag to indicate if the message stack should be
 *                         initialized.
 * @param p_commit         Flag to indicate if the changes should be committed
 *                         on success.
 * @param p_validation_level Level of validation required.  None: No validation
 *                         will be performed.  Full: Item and record level
 *                         validation will be performed.
 * @param x_return_status  Indicates the return status of the API.  The values
 *                         are one of the following: FND_API.G_RET_SUCCESS:
 *                         Indicates the API call was successful,
 *                         FND_API.G_RET_ERROR: Indicates an error has occured,
 *                         FND_API.G_RET_UNEXPECTED: Indications an unexpected
 *                         error has occured.
 * @param x_msg_count      Count of the number of error messages in the list.
 * @param x_msg_data       Error message returned by the API.  If more than
 *                         one message is returned, this parameter is null and
 *                         messages can be extracted from the message stack.
 * @param p_metric_rec     Record of type AMS_METRIC_PVT.METRIC_REC_TYPE that
 *                         tacks the details of the Metric.
 * @param x_metric_id      Unique identifier for the newly created Metric.
 * @rep:scope public
 * @rep:displayname Create Metrics Definition
 * @rep:lifecycle active
 */
PROCEDURE Create_Metric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_metric_rec        IN  AMS_Metric_PVT.metric_rec_type,
   x_metric_id         OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Delete_Metric
--
-- PURPOSE
--    Delete a Metric.
--
-- PARAMETERS
--    p_metric_id: the Metric_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Delete_Metric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_metric_id         IN  NUMBER,
   p_object_version    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_Metric
--
-- PURPOSE
--    Lock a Metric.
--
-- PARAMETERS
--    p_Metric_id: the Metric_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Lock_Metric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_Metric_id         IN  NUMBER,
   p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_Metric
--
-- PURPOSE
--    Update a Metric.
--
-- PARAMETERS
--    p_Metric_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE Update_Metric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_metric_rec        IN  AMS_Metric_PVT.metric_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Metric
--
-- PURPOSE
--    Validate a Metric record.
--
-- PARAMETERS
--    p_metric_rec: the Metric record to be validated
--
-- NOTES
--    1. p_metric_rec should be the complete metric record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Validate_Metric(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_metric_rec        IN  AMS_Metric_PVT.metric_rec_type
);


END AMS_Metric_PUB;

 

/
