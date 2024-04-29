--------------------------------------------------------
--  DDL for Package CSI_COUNTER_TEMPLATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_COUNTER_TEMPLATE_PUB" AUTHID CURRENT_USER AS
/* $Header: csipctts.pls 120.3.12010000.1 2008/07/25 08:11:02 appldev ship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_COUNTER_TEMPLATE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csipctts.pls';

TYPE ctr_template_autoinst_rec IS RECORD
 (COUNTER_ID                           NUMBER
 ,GROUP_ID                             NUMBER
 );
TYPE ctr_template_autoinst_tbl IS TABLE OF ctr_template_autoinst_rec INDEX BY BINARY_INTEGER;

TYPE counter_autoinstantiate_rec IS RECORD
 (COUNTER_ID                           NUMBER
 ,GROUP_ID                             NUMBER
 );
TYPE counter_autoinstantiate_tbl IS TABLE OF counter_autoinstantiate_rec INDEX BY BINARY_INTEGER;

--|---------------------------------------------------
--| procedure name: create_counter_group
--| description :   procedure used to
--|                 create counter group
--|---------------------------------------------------


PROCEDURE create_counter_group
 (p_api_version               IN     NUMBER
  ,p_commit                    IN     VARCHAR2
  ,p_init_msg_list             IN     VARCHAR2
  ,p_validation_level          IN     NUMBER
  ,p_counter_groups_rec        IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec
  ,p_ctr_item_associations_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
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
    ,p_ctr_item_associations_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
    ,p_ctr_property_template_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_tbl
    ,p_counter_relationships_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,p_ctr_derived_filters_tbl   IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
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
    ,p_ctr_item_associations_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
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
    ,p_ctr_item_associations_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
    ,p_ctr_property_template_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_tbl
    ,p_counter_relationships_tbl IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,p_ctr_derived_filters_tbl   IN OUT NOCOPY CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
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
    ,p_ctr_estimation_rec        IN  OUT NOCOPY    CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec
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
    ,p_ctr_estimation_rec        IN  OUT NOCOPY  CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec
);

PROCEDURE AutoInstantiate_Counters
(
    p_api_version		IN	NUMBER
    ,p_init_msg_list		IN	VARCHAR2
    ,p_commit			IN	VARCHAR2
    ,x_return_status	 	    OUT NOCOPY	VARCHAR2
    ,x_msg_count		    OUT NOCOPY	NUMBER
    ,x_msg_data			    OUT NOCOPY	VARCHAR2
    ,p_source_object_id_template  IN	NUMBER
    ,p_source_object_id_instance  IN	NUMBER
    ,x_ctr_id_template	          IN OUT NOCOPY	ctr_template_autoinst_tbl
    ,x_ctr_id_instance	          IN OUT NOCOPY	counter_autoinstantiate_tbl
    ,x_ctr_grp_id_template        IN OUT NOCOPY  NUMBER
    ,x_ctr_grp_id_instance        IN OUT NOCOPY  NUMBER
    ,p_organization_id            IN      NUMBER
);

PROCEDURE Instantiate_Grp_Counters
(
   p_api_version		IN	NUMBER
   ,p_init_msg_list		IN	VARCHAR2
   ,p_commit			IN	VARCHAR2
   ,x_return_status		OUT NOCOPY VARCHAR2
   ,x_msg_count		        OUT NOCOPY NUMBER
   ,x_msg_data		        OUT NOCOPY VARCHAR2
   ,p_group_id_template        	IN	NUMBER
   ,p_source_object_code_instance IN    VARCHAR2
   ,p_source_object_id_instance   IN	NUMBER
   ,x_ctr_grp_id_instance	  OUT NOCOPY	NUMBER
   ,p_maint_org_id                IN    NUMBER
   ,p_primary_failure_flag        IN    VARCHAR2
);

PROCEDURE Instantiate_Counters
(
   p_api_version		IN	NUMBER
   ,p_init_msg_list		IN	VARCHAR2
   ,p_commit			IN	VARCHAR2
   ,x_return_status		    OUT NOCOPY	VARCHAR2
   ,x_msg_count		    OUT NOCOPY	NUMBER
   ,x_msg_data			    OUT NOCOPY	VARCHAR2
   ,p_counter_id_template         IN	NUMBER
   ,p_source_object_code_instance IN    VARCHAR2
   ,p_source_object_id_instance   IN	NUMBER
   ,x_ctr_id_template	    OUT NOCOPY	NUMBER
   ,x_ctr_id_instance	    OUT NOCOPY	NUMBER
);

--|---------------------------------------------------
--| procedure name: create_item_association
--| description :   procedure used to
--|                 create item association to
--|                 counter group or counters
--|---------------------------------------------------

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

END CSI_COUNTER_TEMPLATE_PUB;

/
