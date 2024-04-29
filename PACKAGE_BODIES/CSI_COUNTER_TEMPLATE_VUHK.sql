--------------------------------------------------------
--  DDL for Package Body CSI_COUNTER_TEMPLATE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_COUNTER_TEMPLATE_VUHK" AS
/* $Header: csivhctb.pls 120.3 2005/09/19 13:04:01 epajaril noship $ */

-- --------------------------------------------------------
-- Define global variables
-- --------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSI_COUNTER_TEMPLATE_VUHK';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csivhctb.pls';

--|---------------------------------------------------
--| procedure name: create_counter_group_pre
--| description :   procedure used to
--|                 create counter group
--|---------------------------------------------------

PROCEDURE create_counter_group_pre
 (p_api_version                IN     NUMBER
  ,p_commit                    IN     VARCHAR2
  ,p_init_msg_list             IN     VARCHAR2
  ,p_validation_level          IN     NUMBER
  ,p_counter_groups_rec        IN CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec
  ,p_ctr_item_associations_tbl IN CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
  ,x_return_status             OUT    NOCOPY VARCHAR2
  ,x_msg_count                 OUT    NOCOPY NUMBER
  ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END create_counter_group_pre;



--|---------------------------------------------------
--| procedure name: create_counter_group_post
--| description :   procedure used to
--|                 create counter group
--|---------------------------------------------------

PROCEDURE create_counter_group_post
 (p_api_version                IN     NUMBER
  ,p_commit                    IN     VARCHAR2
  ,p_init_msg_list             IN     VARCHAR2
  ,p_validation_level          IN     NUMBER
  ,p_counter_groups_rec        IN CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec
  ,p_ctr_item_associations_tbl IN CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
  ,x_return_status             OUT    NOCOPY VARCHAR2
  ,x_msg_count                 OUT    NOCOPY NUMBER
  ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END create_counter_group_post;



--|---------------------------------------------------
--| procedure name: create_item_association_pre
--| description :   procedure used to
--|                 create item association to
--|                 counter group or counters
--|---------------------------------------------------

PROCEDURE create_item_association_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_item_associations_rec IN CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END create_item_association_pre;



--|---------------------------------------------------
--| procedure name: create_item_association_post
--| description :   procedure used to
--|                 create item association to
--|                 counter group or counters
--|---------------------------------------------------

PROCEDURE create_item_association_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_item_associations_rec IN CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END create_item_association_post;



--|---------------------------------------------------
--| procedure name: create_counter_template_pre
--| description :   procedure used to
--|                 create counter template
--|---------------------------------------------------

PROCEDURE create_counter_template_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_template_rec      IN CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec
    ,p_ctr_item_associations_tbl IN CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
    ,p_ctr_property_template_tbl IN CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_tbl
    ,p_counter_relationships_tbl IN CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,p_ctr_derived_filters_tbl   IN CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END create_counter_template_pre;



--|---------------------------------------------------
--| procedure name: create_counter_template_post
--| description :   procedure used to
--|                 create counter template
--|---------------------------------------------------

PROCEDURE create_counter_template_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_template_rec      IN CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec
    ,p_ctr_item_associations_tbl IN CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
    ,p_ctr_property_template_tbl IN CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_tbl
    ,p_counter_relationships_tbl IN CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,p_ctr_derived_filters_tbl   IN CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END create_counter_template_post;



--|---------------------------------------------------
--| procedure name: create_ctr_prop_template_pre
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE create_ctr_prop_template_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_property_template_rec IN CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END create_ctr_prop_template_pre;



--|---------------------------------------------------
--| procedure name: create_ctr_prop_template_post
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE create_ctr_prop_template_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_property_template_rec IN CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END create_ctr_prop_template_post;



--|---------------------------------------------------
--| procedure name: create_ctr_relationship_pre
--| description :   procedure used to
--|                 create counter relationship
--|---------------------------------------------------

PROCEDURE create_ctr_relationship_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_relationships_rec IN CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END create_ctr_relationship_pre;



--|---------------------------------------------------
--| procedure name: create_ctr_relationship_post
--| description :   procedure used to
--|                 create counter relationship
--|---------------------------------------------------

PROCEDURE create_ctr_relationship_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_relationships_rec IN CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END create_ctr_relationship_post;



--|---------------------------------------------------
--| procedure name: create_derived_filters_pre
--| description :   procedure used to
--|                 create derived filters
--|---------------------------------------------------

PROCEDURE create_derived_filters_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_derived_filters_tbl	 IN CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END create_derived_filters_pre;



--|---------------------------------------------------
--| procedure name: create_derived_filters_post
--| description :   procedure used to
--|                 create derived filters
--|---------------------------------------------------

PROCEDURE create_derived_filters_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_derived_filters_tbl	 IN CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END create_derived_filters_post;



--|---------------------------------------------------
--| procedure name: update_counter_group_pre
--| description :   procedure used to
--|                 update counter group
--|---------------------------------------------------

PROCEDURE update_counter_group_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_groups_rec        IN CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec
    ,p_ctr_item_associations_tbl IN CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 ) IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END update_counter_group_pre;



--|---------------------------------------------------
--| procedure name: update_counter_group_post
--| description :   procedure used to
--|                 update counter group
--|---------------------------------------------------

PROCEDURE update_counter_group_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_groups_rec        IN CSI_CTR_DATASTRUCTURES_PUB.counter_groups_rec
    ,p_ctr_item_associations_tbl IN CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END update_counter_group_post;



--|---------------------------------------------------
--| procedure name: update_item_association_pre
--| description :   procedure used to
--|                 update item association to
--|                 counter group or counters
--|---------------------------------------------------

PROCEDURE update_item_association_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_item_associations_rec IN CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END update_item_association_pre;



--|---------------------------------------------------
--| procedure name: update_item_association_post
--| description :   procedure used to
--|                 update item association to
--|                 counter group or counters
--|---------------------------------------------------

PROCEDURE update_item_association_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_item_associations_rec IN CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END update_item_association_post;



--|---------------------------------------------------
--| procedure name: update_counter_template_pre
--| description :   procedure used to
--|                 update counter template
--|---------------------------------------------------

PROCEDURE update_counter_template_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_template_rec      IN CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec
    ,p_ctr_item_associations_tbl IN CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
    ,p_ctr_property_template_tbl IN CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_tbl
    ,p_counter_relationships_tbl IN CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,p_ctr_derived_filters_tbl   IN CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END update_counter_template_pre;



--|---------------------------------------------------
--| procedure name: update_counter_template_post
--| description :   procedure used to
--|                 update counter template
--|---------------------------------------------------

PROCEDURE update_counter_template_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_template_rec      IN CSI_CTR_DATASTRUCTURES_PUB.counter_template_rec
    ,p_ctr_item_associations_tbl IN CSI_CTR_DATASTRUCTURES_PUB.ctr_item_associations_tbl
    ,p_ctr_property_template_tbl IN CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_tbl
    ,p_counter_relationships_tbl IN CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_tbl
    ,p_ctr_derived_filters_tbl   IN CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END update_counter_template_post;



--|---------------------------------------------------
--| procedure name: update_ctr_prop_template_pre
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE update_ctr_prop_template_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_property_template_rec IN CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec
    ,x_return_status			 OUT    NOCOPY VARCHAR2
    ,x_msg_count				 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END update_ctr_prop_template_pre;



--|---------------------------------------------------
--| procedure name: update_ctr_prop_template_post
--| description :   procedure used to
--|                 create counter properties
--|---------------------------------------------------

PROCEDURE update_ctr_prop_template_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_property_template_rec IN CSI_CTR_DATASTRUCTURES_PUB.ctr_property_template_rec
    ,x_return_status			 OUT    NOCOPY VARCHAR2
    ,x_msg_count				 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END update_ctr_prop_template_post;



--|---------------------------------------------------
--| procedure name: update_ctr_relationship_pre
--| description :   procedure used to
--|                 update counter relationship
--|---------------------------------------------------

PROCEDURE update_ctr_relationship_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_relationships_rec IN CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END update_ctr_relationship_pre;



--|---------------------------------------------------
--| procedure name: update_ctr_relationship_post
--| description :   procedure used to
--|                 update counter relationship
--|---------------------------------------------------

PROCEDURE update_ctr_relationship_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_counter_relationships_rec IN CSI_CTR_DATASTRUCTURES_PUB.counter_relationships_rec
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END update_ctr_relationship_post;



--|---------------------------------------------------
--| procedure name: update_derived_filters_pre
--| description :   procedure used to
--|                 update derived filters
--|---------------------------------------------------

PROCEDURE update_derived_filters_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_derived_filters_tbl	 IN CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END update_derived_filters_pre;



--|---------------------------------------------------
--| procedure name: update_derived_filters_post
--| description :   procedure used to
--|                 update derived filters
--|---------------------------------------------------

PROCEDURE update_derived_filters_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_derived_filters_tbl	 IN CSI_CTR_DATASTRUCTURES_PUB.ctr_derived_filters_tbl
    ,x_return_status             OUT    NOCOPY VARCHAR2
    ,x_msg_count                 OUT    NOCOPY NUMBER
    ,x_msg_data                  OUT    NOCOPY VARCHAR2
 )	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END update_derived_filters_post;



PROCEDURE Create_Estimation_Method_pre
(
    p_api_version                IN		NUMBER
    ,p_init_msg_list             IN     VARCHAR2
    ,p_commit                    IN     VARCHAR2
    ,p_validation_level          IN     VARCHAR2
    ,x_return_status             OUT	NOCOPY     VARCHAR2
    ,x_msg_count                 OUT	NOCOPY     NUMBER
    ,x_msg_data                  OUT	NOCOPY     VARCHAR2
    ,p_ctr_estimation_rec        IN OUT NOCOPY    CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec
)	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END Create_Estimation_Method_pre;



PROCEDURE Create_Estimation_Method_post
(
    p_api_version                IN		NUMBER
    ,p_init_msg_list             IN     VARCHAR2
    ,p_commit                    IN     VARCHAR2
    ,p_validation_level          IN     VARCHAR2
    ,x_return_status             OUT	NOCOPY     VARCHAR2
    ,x_msg_count                 OUT	NOCOPY     NUMBER
    ,x_msg_data                  OUT	NOCOPY     VARCHAR2
    ,p_ctr_estimation_rec        IN OUT NOCOPY    CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec
)	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END Create_Estimation_Method_post;



PROCEDURE Update_Estimation_Method_pre
(
    p_api_version                IN      NUMBER
    ,p_init_msg_list             IN      VARCHAR2
    ,p_commit                    IN      VARCHAR2
    ,p_validation_level          IN      VARCHAR2
    ,x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                 OUT NOCOPY  NUMBER
    ,x_msg_data                  OUT NOCOPY  VARCHAR2
    ,p_ctr_estimation_rec        IN OUT NOCOPY    CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec
)	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END Update_Estimation_Method_pre;



PROCEDURE Update_Estimation_Method_post
(
    p_api_version                IN      NUMBER
    ,p_init_msg_list             IN      VARCHAR2
    ,p_commit                    IN      VARCHAR2
    ,p_validation_level          IN      VARCHAR2
    ,x_return_status             OUT NOCOPY  VARCHAR2
    ,x_msg_count                 OUT NOCOPY  NUMBER
    ,x_msg_data                  OUT NOCOPY  VARCHAR2
    ,p_ctr_estimation_rec        IN OUT NOCOPY    CSI_CTR_DATASTRUCTURES_PUB.ctr_estimation_methods_rec
)	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END Update_Estimation_Method_post;



PROCEDURE AutoInstantiate_Counters_pre
(
    p_api_version		  IN	NUMBER
    ,p_init_msg_list	          IN	VARCHAR2
    ,p_commit			  IN	VARCHAR2
    ,x_return_status	 	  OUT NOCOPY	VARCHAR2
    ,x_msg_count		  OUT NOCOPY	NUMBER
    ,x_msg_data			  OUT NOCOPY	VARCHAR2
    ,p_source_object_id_template  IN	NUMBER
    ,p_source_object_id_instance  IN	NUMBER
    ,x_ctr_id_template            IN    CSI_COUNTER_TEMPLATE_PUB.ctr_template_autoinst_tbl
    ,x_ctr_id_instance            IN    CSI_COUNTER_TEMPLATE_PUB.counter_autoinstantiate_tbl
    ,x_ctr_grp_id_template        IN    NUMBER
    ,x_ctr_grp_id_instance        IN    NUMBER
    ,p_organization_id		  IN    NUMBER
)	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END AutoInstantiate_Counters_pre;



PROCEDURE AutoInstantiate_Counters_post
(
    p_api_version		  IN	NUMBER
    ,p_init_msg_list		  IN	VARCHAR2
    ,p_commit			  IN	VARCHAR2
    ,x_return_status	          OUT NOCOPY	VARCHAR2
    ,x_msg_count		  OUT NOCOPY	NUMBER
    ,x_msg_data			  OUT NOCOPY	VARCHAR2
    ,p_source_object_id_template  IN	NUMBER
    ,p_source_object_id_instance  IN	NUMBER
    ,x_ctr_id_template            IN    CSI_COUNTER_TEMPLATE_PUB.ctr_template_autoinst_tbl
    ,x_ctr_id_instance            IN    CSI_COUNTER_TEMPLATE_PUB.counter_autoinstantiate_tbl
    ,x_ctr_grp_id_template        IN    NUMBER
    ,x_ctr_grp_id_instance        IN    NUMBER
    ,p_organization_id		  IN    NUMBER
)	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END AutoInstantiate_Counters_post;



PROCEDURE Instantiate_Counters_pre
(
    p_api_version			IN	NUMBER
    ,p_init_msg_list			IN	VARCHAR2
    ,p_commit				IN	VARCHAR2
    ,x_return_status		        OUT NOCOPY	VARCHAR2
    ,x_msg_count			OUT NOCOPY	NUMBER
    ,x_msg_data				OUT NOCOPY	VARCHAR2
    ,p_counter_id_template      	IN	NUMBER
    ,p_source_object_code_instance	IN      VARCHAR2
    ,p_source_object_id_instance	IN	NUMBER
    ,x_ctr_id_template			OUT NOCOPY	NUMBER
    ,x_ctr_id_instance			OUT NOCOPY	NUMBER
)	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END Instantiate_Counters_pre;



PROCEDURE Instantiate_Counters_post
(
    p_api_version			IN	NUMBER
    ,p_init_msg_list			IN	VARCHAR2
    ,p_commit				IN	VARCHAR2
    ,x_return_status			OUT NOCOPY	VARCHAR2
    ,x_msg_count			OUT NOCOPY	NUMBER
    ,x_msg_data				OUT NOCOPY	VARCHAR2
    ,p_counter_id_template      	IN	NUMBER
    ,p_source_object_code_instance	IN      VARCHAR2
    ,p_source_object_id_instance	IN	NUMBER
    ,x_ctr_id_template		OUT NOCOPY	NUMBER
    ,x_ctr_id_instance		OUT NOCOPY	NUMBER
)	IS
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
END Instantiate_Counters_post;

PROCEDURE delete_item_association_pre
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_associations_id       IN     NUMBER
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 ) IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
END delete_item_association_pre;

PROCEDURE delete_item_association_post
 (
     p_api_version               IN     NUMBER
    ,p_commit                    IN     VARCHAR2
    ,p_init_msg_list             IN     VARCHAR2
    ,p_validation_level          IN     NUMBER
    ,p_ctr_associations_id       IN     NUMBER
    ,x_return_status                OUT    NOCOPY VARCHAR2
    ,x_msg_count                    OUT    NOCOPY NUMBER
    ,x_msg_data                     OUT    NOCOPY VARCHAR2
 ) IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
END delete_item_association_post;

END CSI_COUNTER_TEMPLATE_VUHK;

/
