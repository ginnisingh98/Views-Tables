--------------------------------------------------------
--  DDL for Package CSI_COUNTER_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_COUNTER_TEMPLATE_PVT" AUTHID CURRENT_USER AS
/* $Header: csivctts.pls 120.7.12010000.1 2008/07/25 08:15:32 appldev ship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

-- G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_COUNTER_TEMPLATE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csivctts.pls';

PROCEDURE validate_counter_group
(
   p_name               VARCHAR2,
   p_template_flag      VARCHAR2
);

PROCEDURE validate_start_date
(
   p_start_date   DATE
);

PROCEDURE validate_inventory_item
(
   p_inventory_item_id NUMBER
);

PROCEDURE validate_lookups
(
   p_lookup_type   VARCHAR2
   ,p_lookup_code  VARCHAR2
);

PROCEDURE Validate_Data_Type
(
   p_property_data_type	IN	VARCHAR2,
   p_default_value		IN	VARCHAR2,
   p_minimum_value		IN	VARCHAR2,
   p_maximum_value		IN	VARCHAR2
);

PROCEDURE validate_uom
(
   p_uom_code varchar2
);

PROCEDURE validate_ctr_relationship
(
   p_counter_id   IN NUMBER,
   x_direction   OUT NOCOPY VARCHAR2,
   x_start_date  OUT NOCOPY DATE,
   x_end_date    OUT NOCOPY DATE
);

PROCEDURE Validate_Counter
(
   p_group_id                 NUMBER
   ,p_name                    VARCHAR2
   ,p_counter_type            VARCHAR2
   ,p_uom_code                VARCHAR2
   ,p_usage_item_id           NUMBER
   ,p_reading_type            NUMBER
   ,p_direction               VARCHAR2
   ,p_estimation_id           NUMBER
   ,p_derive_function         VARCHAR2
   ,p_formula_text            VARCHAR2
   ,p_derive_counter_id       NUMBER
   ,p_filter_type             VARCHAR2
   ,p_filter_reading_count    NUMBER
   ,p_filter_time_uom         VARCHAR2
   ,p_automatic_rollover      VARCHAR2
   ,p_rollover_last_reading   NUMBER
   ,p_rollover_first_reading  NUMBER
   ,p_tolerance_plus          NUMBER
   ,p_tolerance_minus         NUMBER
   ,p_used_in_scheduling      VARCHAR2
   ,p_initial_reading         NUMBER
   ,p_default_usage_rate      NUMBER
   ,p_use_past_reading        NUMBER
   ,p_counter_id              NUMBER
   ,p_start_date_active       DATE
   ,p_end_date_active         DATE
   ,p_update_flag             VARCHAR2
);


--|---------------------------------------------------
--| procedure name: create_counter_group
--| description :   procedure used to
--|                 create counter group
--|---------------------------------------------------

PROCEDURE create_counter_group
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_groups_rec        IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );


--|---------------------------------------------------
--| procedure name: create_item_association
--| description :   procedure used to
--|                 create item association to
--|                 counter group or counters
--|---------------------------------------------------

PROCEDURE create_item_association
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_item_associations_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: create_counter_template
--| description :   procedure used to
--|                 create counter template
--|---------------------------------------------------

PROCEDURE create_counter_template
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_template_rec      IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: create_ctr_property_template
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE create_ctr_property_template
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_property_template_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );


--|---------------------------------------------------
--| procedure name: create_counter_relationship
--| description :   procedure used to
--|                 create counter relationship
--|---------------------------------------------------

PROCEDURE create_counter_relationship
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_relationships_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: create_derived_filters
--| description :   procedure used to
--|                 create derived filters
--|---------------------------------------------------

PROCEDURE create_derived_filters
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_derived_filters_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_counter_group
--| description :   procedure used to
--|                 update counter group
--|---------------------------------------------------

PROCEDURE update_counter_group
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_groups_rec        IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_item_association
--| description :   procedure used to
--|                 update item association to
--|                 counter group or counters
--|---------------------------------------------------

PROCEDURE update_item_association
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_item_associations_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_counter_template
--| description :   procedure used to
--|                 update counter template
--|---------------------------------------------------

PROCEDURE update_counter_template
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_template_rec      IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_ctr_property_template
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE update_ctr_property_template
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_property_template_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_counter_relationship
--| description :   procedure used to
--|                 update counter relationship
--|---------------------------------------------------

PROCEDURE update_counter_relationship
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_relationships_rec IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );

--|---------------------------------------------------
--| procedure name: update_derived_filters
--| description :   procedure used to
--|                 update derived filters
--|---------------------------------------------------

PROCEDURE update_derived_filters
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_derived_filters_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 );


PROCEDURE Create_Estimation_Method
(
    p_api_version                IN      NUMBER
    ,p_init_msg_list             IN      VARCHAR2
    ,p_commit                    IN      VARCHAR2
    ,p_validation_level          IN      NUMBER
    ,x_return_status                 OUT NOCOPY     VARCHAR2
    ,x_msg_count                     OUT NOCOPY     NUMBER
    ,x_msg_data                      OUT NOCOPY     VARCHAR2
    ,p_ctr_estimation_rec        IN      CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec
);

PROCEDURE Update_Estimation_Method
(
    p_api_version                IN      NUMBER
    ,p_init_msg_list             IN      VARCHAR2
    ,p_commit                    IN      VARCHAR2
    ,p_validation_level          IN      NUMBER
    ,x_return_status                 OUT NOCOPY  VARCHAR2
    ,x_msg_count                     OUT NOCOPY  NUMBER
    ,x_msg_data                      OUT NOCOPY  VARCHAR2
    ,p_ctr_estimation_rec        IN      CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec
);

PROCEDURE Instantiate_Counters
(
    p_api_version		   IN	NUMBER
    ,p_init_msg_list		   IN	VARCHAR2
    ,p_commit			   IN	VARCHAR2
    ,x_return_status		    OUT NOCOPY	VARCHAR2
    ,x_msg_count		    OUT NOCOPY	NUMBER
    ,x_msg_data			    OUT NOCOPY	VARCHAR2
    ,p_counter_id_template         IN	NUMBER
    ,p_source_object_code_instance IN      VARCHAR2
    ,p_source_object_id_instance   IN	NUMBER
    ,x_ctr_id_template	           OUT NOCOPY	NUMBER
    ,x_ctr_id_instance	           OUT NOCOPY	NUMBER
    ,p_maint_org_id                IN   NUMBER
    ,p_primary_failure_flag        IN   VARCHAR2
);

PROCEDURE Instantiate_Grp_Counters
(
    p_api_version		   IN	NUMBER
    ,p_init_msg_list		   IN	VARCHAR2
    ,p_commit			   IN	VARCHAR2
    ,x_return_status		    OUT NOCOPY	VARCHAR2
    ,x_msg_count		    OUT NOCOPY	NUMBER
    ,x_msg_data			    OUT NOCOPY	VARCHAR2
    ,p_group_id_template           IN	NUMBER
    ,p_source_object_code_instance IN   VARCHAR2
    ,p_source_object_id_instance   IN	NUMBER
    ,x_ctr_grp_id_instance	   OUT NOCOPY	NUMBER
    ,p_maint_org_id                IN   NUMBER
    ,p_primary_failure_flag        IN   VARCHAR2
);

PROCEDURE delete_item_association
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_associations_id       IN     NUMBER
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
);

END CSI_COUNTER_TEMPLATE_PVT;

/
