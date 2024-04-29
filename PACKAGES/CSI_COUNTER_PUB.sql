--------------------------------------------------------
--  DDL for Package CSI_COUNTER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_COUNTER_PUB" AUTHID CURRENT_USER AS
/* $Header: csipctis.pls 120.3.12010000.1 2008/07/25 08:10:57 appldev ship $ */
/*#
 * This is a public API for managing Counter Instances.
 * It contains routines to Create and Update Counter Instances.
 * @rep:scope public
 * @rep:product CSI
 * @rep:displayname Manage Counter Instances
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CSI_COUNTER
*/

--|---------------------------------------------------
--| procedure name: create_counter
--| description :   procedure used to
--|                 create counter instance
--|---------------------------------------------------
/*#
 * This procedure is used to create Counter Instance.
 * In this procedure, it can also create counter properties, associations, counter relationships, derived filters
 * @param p_api_version Current API version
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_counter_instance_rec Counter Record structure
 * @param P_ctr_properties_tbl Counter Properties Table
 * @param P_counter_relationships_tbl Contains the Counter Relationships Table
 * @param P_ctr_derived_filters_tbl Contains the Counter Derived Filters Table
 * @param P_counter_associations_tbl Contains the Counter Associations Table
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @param x_ctr_id	Counter Id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Counter
 */

PROCEDURE create_counter
 (
     p_api_version	         IN	NUMBER
    ,p_init_msg_list	         IN	VARCHAR2
    ,p_commit		         IN	VARCHAR2
    ,p_validation_level          IN NUMBER
    ,p_counter_instance_rec	 IN out	NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec
    ,P_ctr_properties_tbl        IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,P_counter_relationships_tbl IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,P_ctr_derived_filters_tbl   IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,P_counter_associations_tbl  IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
    ,x_return_status                out NOCOPY VARCHAR2
    ,x_msg_count                    out NOCOPY NUMBER
    ,x_msg_data                     out NOCOPY VARCHAR2
    ,x_ctr_id		            out	NOCOPY NUMBER
 );

--|---------------------------------------------------
--| procedure name: create_ctr_property
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------
/*#
 * This procedure is used to create Counter properties.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param P_ctr_properties_tbl Counter Properties Table
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @param x_ctr_property_id	Counter Property Id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Counter Property
 */

PROCEDURE create_ctr_property
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,P_ctr_properties_tbl        IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,x_ctr_property_id	            OUT NOCOPY NUMBER
 );

--|---------------------------------------------------
--| procedure name: create_ctr_associations
--| description :   procedure used to
--|                 create counter associations
--|---------------------------------------------------
/*#
 * This procedure is used to create Counter Association.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param P_counter_associations_tbl Contains the Counter Associations Table
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @param x_instance_association_id	Instance Association Id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Counter Association
 */

PROCEDURE create_ctr_associations
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,P_counter_associations_tbl  IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,x_instance_association_id      OUT	NOCOPY NUMBER
 );

--|---------------------------------------------------
--| procedure name: create_reading_lock
--| description :   procedure used to
--|                 create reading lock on a counter
--|---------------------------------------------------
/*#
 * This procedure is used to create Counter Reading Lock.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_ctr_reading_lock_rec Counter Reading Lock Record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @param x_reading_lock_id	Counter Reading Lock Id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Counter Reading Lock
 */

PROCEDURE create_reading_lock
 (
     p_api_version          IN     NUMBER
    ,p_commit               IN     VARCHAR2
    ,p_init_msg_list        IN     VARCHAR2
    ,p_validation_level     IN     NUMBER
    ,p_ctr_reading_lock_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_reading_lock_rec
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,x_reading_lock_id         OUT NOCOPY NUMBER
 );

--|---------------------------------------------------
--| procedure name: create_daily_usage
--| description :   procedure used to
--|                 create daily usage
--|---------------------------------------------------
/*#
 * This procedure is used to create Daily Usage Forecast.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_ctr_usage_forecast_rec Daily Usage Forecast Record structure
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @param x_instance_forecast_id	Instance Daiy Usage Forecast Id
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Daily Usage Forecast
 */

PROCEDURE create_daily_usage
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_usage_forecast_rec    IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_usage_forecast_rec
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,x_instance_forecast_id         OUT	NOCOPY NUMBER
 );

--|---------------------------------------------------
--| procedure name: update_counter
--| description :   procedure used to
--|                 update counter
--|---------------------------------------------------
/*#
 * This procedure is used to update Counter Instance.
 * In this procedure, it can also update counter properties, associations,
 * counter relationships, derived filters for a given counter
 * @param p_api_version Current API version
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param p_counter_instance_rec Counter Record structure
 * @param P_ctr_properties_tbl Counter Properties Table
 * @param P_counter_relationships_tbl Contains the Counter Relationships Table
 * @param P_ctr_derived_filters_tbl Contains the Counter Derived Filters Table
 * @param P_counter_associations_tbl Contains the Counter Associations Table
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Counter
 */

PROCEDURE update_counter
 (
     p_api_version	        IN	NUMBER
    ,p_init_msg_list	        IN	VARCHAR2
    ,p_commit		        IN	VARCHAR2
    ,p_validation_level         IN      NUMBER
    ,p_counter_instance_rec	IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec
    ,P_ctr_properties_tbl       IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,P_counter_relationships_tbl IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,P_ctr_derived_filters_tbl  IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,P_counter_associations_tbl IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
    ,x_return_status               out NOCOPY VARCHAR2
    ,x_msg_count                   out NOCOPY NUMBER
    ,x_msg_data                    out NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_ctr_property
--| description :   procedure used to
--|                 update counter properties
--|---------------------------------------------------
/*#
 * This procedure is used to update Counter Property.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param P_ctr_properties_tbl Counter Properties Table
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Counter Property
 */

PROCEDURE update_ctr_property
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,P_ctr_properties_tbl        IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_ctr_associations
--| description :   procedure used to
--|                 update counter associations
--|---------------------------------------------------
/*#
 * This procedure is used to update Counter Association.
 * @param p_api_version Current API version
 * @param p_commit API commits if set to fnd_api.g_true
 * @param p_init_msg_list Initializes the message stack if set to fnd_api.g_true
 * @param p_validation_level API validation level
 * @param P_counter_associations_tbl Contains the Counter Associations Table
 * @param x_return_status API Return Status
 * @param x_msg_count Message count
 * @param x_msg_data Message Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Counter Association
 */

PROCEDURE update_ctr_associations
 (
   p_api_version               IN     NUMBER
  ,p_commit                    IN     VARCHAR2
  ,p_init_msg_list             IN     VARCHAR2
  ,p_validation_level          IN     NUMBER
  ,p_counter_associations_tbl  IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
  ,x_return_status                OUT    NOCOPY VARCHAR2
  ,x_msg_count                    OUT    NOCOPY NUMBER
  ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );


END CSI_COUNTER_PUB;

/
