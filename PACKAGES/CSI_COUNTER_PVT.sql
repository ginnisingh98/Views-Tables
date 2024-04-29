--------------------------------------------------------
--  DDL for Package CSI_COUNTER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_COUNTER_PVT" AUTHID CURRENT_USER AS
/* $Header: csivctis.pls 120.1.12010000.2 2008/10/31 21:03:29 rsinn ship $ */


--|---------------------------------------------------
--| procedure name: create_counter
--| description :   procedure used to
--|                 create counter instance
--|---------------------------------------------------

PROCEDURE create_counter
 (
     p_api_version	           IN  NUMBER
    ,p_init_msg_list	           IN  VARCHAR2
    ,p_commit		           IN  VARCHAR2
    ,p_validation_level	           IN  VARCHAR2
    ,p_counter_instance_rec	   IN  out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec
    ,x_return_status               OUT NOCOPY VARCHAR2
    ,x_msg_count                   OUT NOCOPY NUMBER
    ,x_msg_data                    OUT NOCOPY VARCHAR2
    ,x_ctr_id		           OUT NOCOPY NUMBER
 );


--|---------------------------------------------------
--| procedure name: create_ctr_property
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE create_ctr_property
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_properties_rec	 IN out	NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Ctr_Properties_Rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
    ,x_ctr_property_id	         OUT	NOCOPY NUMBER
 );

--|---------------------------------------------------
--| procedure name: create_ctr_associations
--| description :   procedure used to
--|                 create counter associations
--|---------------------------------------------------

PROCEDURE create_ctr_associations
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,P_counter_associations_rec  IN out	NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_associations_rec
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

PROCEDURE create_reading_lock
 (
     p_api_version           IN     NUMBER
    ,p_commit                IN     VARCHAR2
    ,p_init_msg_list         IN     VARCHAR2
    ,p_validation_level      IN     NUMBER
    ,p_ctr_reading_lock_rec  IN out	NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_reading_lock_rec
    ,x_return_status           OUT    NOCOPY VARCHAR2
    ,x_msg_count               OUT    NOCOPY NUMBER
    ,x_msg_data                OUT    NOCOPY VARCHAR2
   	,x_reading_lock_id         OUT	NOCOPY NUMBER
 );

--|---------------------------------------------------
--| procedure name: create_daily_usage
--| description :   procedure used to
--|                 create daily usage
--|---------------------------------------------------

PROCEDURE create_daily_usage
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_usage_forecast_rec    IN out	NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_usage_forecast_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
    ,x_instance_forecast_id         OUT	NOCOPY NUMBER
 );

 --|---------------------------------------------------
--| procedure name: update_counter
--| description :   procedure used to
--|                 create counter instance
--|---------------------------------------------------

PROCEDURE update_counter
 (
     p_api_version	          IN	NUMBER
    ,p_init_msg_list	          IN	VARCHAR2
    ,p_commit		          IN	VARCHAR2
    ,p_validation_level	          IN	VARCHAR2
    ,p_counter_instance_rec	  IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Counter_instance_rec
    ,x_return_status               OUT NOCOPY VARCHAR2
    ,x_msg_count                   OUT NOCOPY NUMBER
    ,x_msg_data                    OUT NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_ctr_property
--| description :   procedure used to
--|                 update counter properties
--|---------------------------------------------------

PROCEDURE update_ctr_property
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,P_ctr_properties_rec        IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.Ctr_properties_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_ctr_associations
--| description :   procedure used to
--|                 update counter associations
--|---------------------------------------------------

PROCEDURE update_ctr_associations
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,P_counter_associations_rec IN out NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_associations_rec
    ,x_return_status               OUT    NOCOPY VARCHAR2
    ,x_msg_count                   OUT    NOCOPY NUMBER
    ,x_msg_data                    OUT    NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_ctr_val_max_seq_no
--| description :   procedure used to update
--|                 the ctr_val_max_seq_no for
--|                 a particular counter
--|---------------------------------------------------

PROCEDURE update_ctr_val_max_seq_no
 (
     p_api_version             IN     NUMBER
    ,p_commit                  IN     VARCHAR2
    ,p_init_msg_list           IN     VARCHAR2
    ,p_validation_level        IN     NUMBER
    ,p_counter_id              IN     NUMBER
    ,px_ctr_val_max_seq_no     IN OUT NOCOPY NUMBER
    ,x_return_status           OUT    NOCOPY VARCHAR2
    ,x_msg_count               OUT    NOCOPY NUMBER
    ,x_msg_data                OUT    NOCOPY VARCHAR2
 );

END CSI_COUNTER_PVT;

/
