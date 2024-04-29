--------------------------------------------------------
--  DDL for Package CSI_COUNTER_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_COUNTER_VUHK" AUTHID CURRENT_USER AS
/* $Header: csivhcis.pls 120.0 2005/06/10 15:02:36 rktow noship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_COUNTER_VUHK';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csivhcis.pls';

--|---------------------------------------------------
--| procedure name: create_counter_pre
--| description :   procedure used to
--|                 create counter instance
--|---------------------------------------------------

PROCEDURE create_counter_pre
 (
     p_api_version					IN	NUMBER
    ,p_init_msg_list	          	IN	VARCHAR2	:= FND_API.G_FALSE
    ,p_commit		                IN	VARCHAR2	:= FND_API.G_FALSE
    ,p_validation_level				IN NUMBER
    ,p_counter_instance_rec			IN CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec
    ,P_ctr_properties_tbl			IN CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,P_counter_relationships_tbl	IN CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,P_ctr_derived_filters_tbl		IN CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,P_counter_associations_tbl		IN CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
    ,x_return_status				out NOCOPY VARCHAR2
    ,x_msg_count					out NOCOPY NUMBER
    ,x_msg_data						out NOCOPY VARCHAR2
    ,x_ctr_id		                OUT NOCOPY NUMBER
 );



--|---------------------------------------------------
--| procedure name: create_counter_post
--| description :   procedure used to
--|                 create counter instance
--|---------------------------------------------------

PROCEDURE create_counter_post
 (
     p_api_version					IN	NUMBER
    ,p_init_msg_list	          	IN	VARCHAR2	:= FND_API.G_FALSE
    ,p_commit		                IN	VARCHAR2	:= FND_API.G_FALSE
    ,p_validation_level				IN NUMBER
    ,p_counter_instance_rec			IN CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec
    ,P_ctr_properties_tbl			IN CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,P_counter_relationships_tbl	IN CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,P_ctr_derived_filters_tbl		IN CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,P_counter_associations_tbl		IN CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
    ,x_return_status				out NOCOPY VARCHAR2
    ,x_msg_count					out NOCOPY NUMBER
    ,x_msg_data						out NOCOPY VARCHAR2
    ,x_ctr_id		                out nocopy NUMBER
 );



--|---------------------------------------------------
--| procedure name: create_ctr_property_pre
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE create_ctr_property_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,P_ctr_properties_tbl        IN CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
    ,x_ctr_property_id	         OUT	NOCOPY NUMBER
 );



--|---------------------------------------------------
--| procedure name: create_ctr_property_post
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE create_ctr_property_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,P_ctr_properties_tbl        IN CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
    ,x_ctr_property_id	         OUT	NOCOPY NUMBER
 );



--|---------------------------------------------------
--| procedure name: create_ctr_associations_pre
--| description :   procedure used to
--|                 create counter associations
--|---------------------------------------------------

PROCEDURE create_ctr_associations_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,P_counter_associations_tbl	 IN CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
    ,x_instance_association_id   OUT	NOCOPY NUMBER
 );



--|---------------------------------------------------
--| procedure name: create_ctr_associations_post
--| description :   procedure used to
--|                 create counter associations
--|---------------------------------------------------

PROCEDURE create_ctr_associations_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,P_counter_associations_tbl	 IN CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
    ,x_instance_association_id   OUT	NOCOPY NUMBER
 );



--|---------------------------------------------------
--| procedure name: create_reading_lock_pre
--| description :   procedure used to
--|                 create reading lock on a counter
--|---------------------------------------------------

PROCEDURE create_reading_lock_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,p_ctr_reading_lock_rec		 IN CSI_CTR_DATASTRUCTURES_PUB.ctr_reading_lock_rec
    ,x_return_status			 OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
   	,x_reading_lock_id           OUT	NOCOPY NUMBER
 );



--|---------------------------------------------------
--| procedure name: create_reading_lock_post
--| description :   procedure used to
--|                 create reading lock on a counter
--|---------------------------------------------------

PROCEDURE create_reading_lock_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,p_ctr_reading_lock_rec		 IN CSI_CTR_DATASTRUCTURES_PUB.ctr_reading_lock_rec
    ,x_return_status			 OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
   	,x_reading_lock_id           OUT	NOCOPY NUMBER

 );



--|---------------------------------------------------
--| procedure name: create_daily_usage_pre
--| description :   procedure used to
--|                 create daily usage
--|---------------------------------------------------

PROCEDURE create_daily_usage_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,p_ctr_usage_forecast_rec    IN CSI_CTR_DATASTRUCTURES_PUB.ctr_usage_forecast_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
    ,x_instance_forecast_id      OUT	NOCOPY NUMBER

 );



--|---------------------------------------------------
--| procedure name: create_daily_usage_post
--| description :   procedure used to
--|                 create daily usage
--|---------------------------------------------------

PROCEDURE create_daily_usage_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,p_ctr_usage_forecast_rec    IN CSI_CTR_DATASTRUCTURES_PUB.ctr_usage_forecast_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
    ,x_instance_forecast_id      OUT	NOCOPY NUMBER

 );



--|---------------------------------------------------
--| procedure name: update_counter_pre
--| description :   procedure used to
--|                 update counter
--|---------------------------------------------------

PROCEDURE update_counter_pre
 (
     p_api_version	             IN	NUMBER
    ,p_init_msg_list	         IN	VARCHAR2	:= FND_API.G_FALSE
    ,p_commit		             IN	VARCHAR2	:= FND_API.G_FALSE
    ,p_validation_level			 IN NUMBER
    ,p_counter_instance_rec	     IN CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec
    ,P_ctr_properties_tbl        IN CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,P_counter_relationships_tbl IN CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,P_ctr_derived_filters_tbl   IN CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status             out NOCOPY VARCHAR2
    ,x_msg_count                 out NOCOPY NUMBER
    ,x_msg_data                  out NOCOPY VARCHAR2


 );



--|---------------------------------------------------
--| procedure name: update_counter_post
--| description :   procedure used to
--|                 update counter
--|---------------------------------------------------

PROCEDURE update_counter_post
 (
     p_api_version	             IN	NUMBER
    ,p_init_msg_list	         IN	VARCHAR2	:= FND_API.G_FALSE
    ,p_commit		             IN	VARCHAR2	:= FND_API.G_FALSE
    ,p_validation_level			 IN NUMBER
    ,p_counter_instance_rec	     IN CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec
    ,P_ctr_properties_tbl        IN CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,P_counter_relationships_tbl IN CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,P_ctr_derived_filters_tbl   IN CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status             out NOCOPY VARCHAR2
    ,x_msg_count                 out NOCOPY NUMBER
    ,x_msg_data                  out NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_ctr_property_pre
--| description :   procedure used to
--|                 update counter properties
--|---------------------------------------------------

PROCEDURE update_ctr_property_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,P_ctr_properties_tbl        IN CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 );



--|---------------------------------------------------
--| procedure name: update_ctr_property_post
--| description :   procedure used to
--|                 update counter properties
--|---------------------------------------------------

PROCEDURE update_ctr_property_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,P_ctr_properties_tbl        IN CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_ctr_associations_pre
--| description :   procedure used to
--|                 update counter associations
--|---------------------------------------------------

PROCEDURE update_ctr_associations_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,P_counter_associations_tbl  IN CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 );



--|---------------------------------------------------
--| procedure name: update_ctr_associations_post
--| description :   procedure used to
--|                 update counter associations
--|---------------------------------------------------

PROCEDURE update_ctr_associations_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,P_counter_associations_tbl  IN CSI_CTR_DATASTRUCTURES_PUB.counter_associations_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 );



--|---------------------------------------------------
--| procedure name: update_reading_lock_pre
--| description :   procedure used to
--|                 update reading lock on a counter
--|---------------------------------------------------

PROCEDURE update_reading_lock_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,p_ctr_reading_lock_rec		 IN CSI_CTR_DATASTRUCTURES_PUB.ctr_reading_lock_rec
    ,x_return_status			 OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 );



--|---------------------------------------------------
--| procedure name: update_reading_lock_post
--| description :   procedure used to
--|                 update reading lock on a counter
--|---------------------------------------------------

PROCEDURE update_reading_lock_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,p_ctr_reading_lock_rec		 IN CSI_CTR_DATASTRUCTURES_PUB.ctr_reading_lock_rec
    ,x_return_status			 OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 );



--|---------------------------------------------------
--| procedure name: update_daily_usage_pre
--| description :   procedure used to
--|                 update daily usage
--|---------------------------------------------------

PROCEDURE update_daily_usage_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,p_ctr_usage_forecast_rec    IN CSI_CTR_DATASTRUCTURES_PUB.ctr_usage_forecast_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 );



--|---------------------------------------------------
--| procedure name: update_daily_usage_post
--| description :   procedure used to
--|                 update daily usage
--|---------------------------------------------------

PROCEDURE update_daily_usage_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2  := FND_API.G_FALSE
    ,p_init_msg_list             IN     VARCHAR2  := FND_API.G_FALSE
    ,p_validation_level          IN     NUMBER
    ,p_ctr_usage_forecast_rec    IN CSI_CTR_DATASTRUCTURES_PUB.ctr_usage_forecast_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 );

END CSI_COUNTER_VUHK;

 

/
