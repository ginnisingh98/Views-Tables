--------------------------------------------------------
--  DDL for Package AHL_UC_INSTANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_INSTANCE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUCIS.pls 120.3.12010000.4 2008/11/20 11:42:13 sathapli ship $ */

-- Define Record Type for AHL Unit Configuration Header Record --
TYPE uc_header_rec_type IS RECORD (
    uc_header_id                  NUMBER,
    uc_name	                  VARCHAR2(80),
    mc_header_id    	          NUMBER,
    mc_name                       VARCHAR2(80),
    mc_revision                   VARCHAR2(30),
    parent_uc_header_id           NUMBER,
    unit_config_status_code	  VARCHAR2(30),
    active_uc_status_code	  VARCHAR2(30),
    instance_id	                  NUMBER,
    instance_number               VARCHAR2(30),
    active_start_date             DATE,
    active_end_date	          DATE,
    object_version_number         NUMBER, --refers ovn of unit config header record
    attribute_category      	  VARCHAR2(30),
    attribute1              	  VARCHAR2(150),
    attribute2              	  VARCHAR2(150),
    attribute3              	  VARCHAR2(150),
    attribute4              	  VARCHAR2(150),
    attribute5              	  VARCHAR2(150),
    attribute6              	  VARCHAR2(150),
    attribute7                    VARCHAR2(150),
    attribute8                    VARCHAR2(150),
    attribute9                    VARCHAR2(150),
    attribute10                   VARCHAR2(150),
    attribute11                   VARCHAR2(150),
    attribute12                   VARCHAR2(150),
    attribute13                   VARCHAR2(150),
    attribute14                   VARCHAR2(150),
    attribute15                   VARCHAR2(150));

-- Define Record Type for CSI Item Instance Record --
-- SATHAPLI::FP ER 6453212, 11-Nov-2008, add flexfield segments to the record type
TYPE uc_instance_rec_type IS RECORD (
    inventory_item_id	       NUMBER,
    inventory_org_id           NUMBER,
    inventory_org_code         VARCHAR2(3),
    -- Changed by jaramana on 16-APR-2008 for bug 6977832
    -- mtl_system_items_kfv.concatenated_segments%TYPE will make the size of this column
    -- dependent on the definition of the view mtl_system_items_kfv.
    -- So, hardcode this to a large value of 240 instead so that Rosetta also will declare
    -- these as VARCHAR2(300) instead of VARCHAR2(100).
    item_number                VARCHAR2(240),
    instance_id                NUMBER,
    instance_number            VARCHAR2(30),
    serial_number	       VARCHAR2(30),
    sn_tag_code                VARCHAR2(30),
    sn_tag_meaning             VARCHAR2(80),
    lot_number                 MTL_LOT_NUMBERS.LOT_NUMBER%TYPE,
    quantity                   NUMBER,
    uom_code                   VARCHAR2(3),
    revision                   VARCHAR2(3),
    mfg_date                   DATE,
    install_date               DATE,
    relationship_id            NUMBER, --refers to relationship_id in ahl_mc_relationships
    object_version_number      NUMBER, --refers to ovn of csi item instance
    context                    VARCHAR2(30),
    attribute1                 VARCHAR2(240),
    attribute2                 VARCHAR2(240),
    attribute3                 VARCHAR2(240),
    attribute4                 VARCHAR2(240),
    attribute5                 VARCHAR2(240),
    attribute6                 VARCHAR2(240),
    attribute7                 VARCHAR2(240),
    attribute8                 VARCHAR2(240),
    attribute9                 VARCHAR2(240),
    attribute10                VARCHAR2(240),
    attribute11                VARCHAR2(240),
    attribute12                VARCHAR2(240),
    attribute13                VARCHAR2(240),
    attribute14                VARCHAR2(240),
    attribute15                VARCHAR2(240),
    attribute16                VARCHAR2(240),
    attribute17                VARCHAR2(240),
    attribute18                VARCHAR2(240),
    attribute19                VARCHAR2(240),
    attribute20                VARCHAR2(240),
    attribute21                VARCHAR2(240),
    attribute22                VARCHAR2(240),
    attribute23                VARCHAR2(240),
    attribute24                VARCHAR2(240),
    attribute25                VARCHAR2(240),
    attribute26                VARCHAR2(240),
    attribute27                VARCHAR2(240),
    attribute28                VARCHAR2(240),
    attribute29                VARCHAR2(240),
    attribute30                VARCHAR2(240));

-- Define Record Type for immediate children of a given UC node --
TYPE uc_child_rec_type IS RECORD (
   node_type                   VARCHAR2(1),
   instance_id                 NUMBER,
   relationship_id             NUMBER,
   leaf_node_flag              VARCHAR2(1),
   with_subunit_flag           VARCHAR2(1));
TYPE uc_child_tbl_type IS TABLE OF uc_child_rec_type INDEX BY BINARY_INTEGER;

-- Define Record Type for all descendants of a given UC root node --
TYPE uc_descendant_rec_type IS RECORD (
   node_type                   VARCHAR2(1),
   instance_id                 NUMBER,
   parent_instance_id          NUMBEr,
   relationship_id             NUMBER,
   parent_rel_id               NUMBER,
   leaf_node_flag              VARCHAR2(1),
   with_submc_flag             VARCHAR2(1));
TYPE uc_descendant_tbl_type IS TABLE OF uc_descendant_rec_type INDEX BY BINARY_INTEGER;

-- Define Record Type for alternate CSI item instances --
TYPE available_instance_rec_type  IS RECORD (
   csi_item_instance_id        NUMBER,
   csi_object_version_number   NUMBER,
   inventory_item_id           NUMBER,
   inventory_org_id            NUMBER,
   organization_code           VARCHAR2(3),
   -- Changed by jaramana on 16-APR-2008 for bug 6977832
   -- Increase this from 40 to 240 so that Rosetta will declare these
   -- as VARCHAR2(300) instead of VARCHAR2(100).
   item_number                 VARCHAR2(240),
   item_description            VARCHAR2(240),
   csi_instance_number         csi_item_instances.instance_number%type,
   serial_number               VARCHAR2(30),
   lot_number                  MTL_LOT_NUMBERS.LOT_NUMBER%TYPE,
   revision                    VARCHAR2(3),
   uom_code                    VARCHAR2(3),
   quantity                    NUMBER,
   priority                    NUMBER,
   install_date                DATE,
   mfg_date                    DATE,
   location_description        VARCHAR2(4000),
   party_type                  VARCHAR2(30),
   owner_id                    NUMBER,
   owner_number                VARCHAR2(360),
   owner_name                  VARCHAR2(360),
   owner_site_id               NUMBER,
   owner_site_number           VARCHAR2(30),
   csi_party_object_version_num NUMBER,
   status                      VARCHAR2(80),
   condition                   VARCHAR2(240),
   uc_header_id                NUMBER,
   uc_name                     VARCHAR2(80),
   uc_status                   VARCHAR2(80),
   mc_header_id                NUMBER,
   mc_name                     VARCHAR2(80),
   mc_revision                 VARCHAR2(30),
   mc_status                   VARCHAR2(80),
   position_ref                VARCHAR2(80),
   wip_entity_name             VARCHAR2(240),
   csi_ii_relationship_ovn     NUMBER, --Added in order for assigning an existing extra sibling
                                        --node to an sibling empty position
   subinventory_code           VARCHAR2(10),
   inventory_locator_id        NUMBER,
   locator_segments            VARCHAR2(204)
);
TYPE available_instance_tbl_type IS TABLE OF available_instance_rec_type INDEX BY BINARY_INTEGER;

-- Start of Comments  --
-- Define Procedure unassociate_instance_pos
-- This API is used to to remove a child instance's position reference but keep
-- the parent-child relationship in a UC tree structure (in other word, to make
-- the child instance as an extra node in the UC).
--
-- Procedure name  : unassociate_instance_pos
-- Type        	: Private
-- Function    	: To remove a child instance's position reference but keep
--                    the parent-child relationship in a UC tree structure.
-- Pre-reqs    	:
--
-- unassociate_instance_pos parameters :
-- p_uc_header_id     IN NUMBER  Required
-- p_instance_id      IN NUMBER  Required
-- p_csi_ii_ovn       IN NUMBER  Required, the origianl object_version_number of the record
--                     in table csi_ii_relationships where p_instance_id is the subject_id
-- p_prod_user_flag   IN VARCHAR2(1)  Required, to indicate whether the user who
--                      triggers this functionality is from Production.
-- Version : Initial Version   1.0
--
-- End of Comments  --
PROCEDURE unassociate_instance_pos (
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_instance_id           IN  NUMBER,
  p_csi_ii_ovn            IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2);

-- Start of Comments  --
-- Define Procedure remove_instance
-- This API is used to to remove to remove an instance (leaf, branch node or
-- sub-unit) from a UC node.
--
-- Procedure name  : remove_instance
-- Type        	: Private
-- Function    	: To remove an instance (leaf, branch node or
--                sub-unit) from a UC node..
-- Pre-reqs    	:
--
-- remove_instance parameters :
-- p_uc_header_id     IN NUMBER  Required
-- p_instance_id      In NUMBER  Required
-- p_prod_user_flag   IN VARCHAR2(1)  Required, to indicate whether the user who
--                      triggers this functionality is from Production.
-- Version : Initial Version   1.0
--
-- End of Comments  --
PROCEDURE remove_instance (
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_instance_id           IN  NUMBER,
  p_csi_ii_ovn            IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2);

-- Start of Comments  --
-- Define Procedure update_instance_attr
-- This API is used to update an instance's (top node or non top node) attributes
-- (serial Number, serial_number_tag, lot_number, revision, mfg_date and etc.)
--
-- Procedure name  : update_instance_attr
-- Type        	: Private
-- Function    	: To remove an instance (leaf, branch node or
--                sub-unit) from a UC node.
-- Pre-reqs    	:
--
-- update_instance_attr parameters :
--   p_uc_header_id     IN NUMBER  Required
--   p_instance_id      In NUMBER  Required
--   p_prod_user_flag   IN VARCHAR2(1)  Required, to indicate whether the user who
--                      triggers this functionality is from Production.
--  Version : Initial Version   1.0
--
--  End of Comments  --
PROCEDURE update_instance_attr(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_uc_instance_rec       IN  uc_instance_rec_type,
  p_prod_user_flag        IN  VARCHAR2);

-- Start of Comments  --
-- Define procedure install_new_instance
-- This API is used to create a new instance in csi_item_instances and assign it
-- to a UC node.
--
-- Procedure name: install_new_instance
-- Type: Private
-- Function: To create a new instance in csi_item_instances and assign it
--           to a UC node.
-- Pre-reqs:
--
-- install_new_instance parameters:
--   p_uc_header_id       IN NUMBER  Required
--   p_parent_instance_id IN NUMBER  Required, indicates the parent instance_id
--   p_x_uc_instance_rec  In OUT uc_instance_rec_type  Required
--   p_x_sub_uc_rec       IN OUT uc_header_rec_type
--                        to store the sub UC header information if also creating a
--                        sub UC simultaneously
--   p_uc_relationship_rec IN uc_relationship_rec_type
--                        to store the relationship between the parent and the child
--                        instance
--   p_prod_user_flag   IN VARCHAR2(1)  Required, to indicate whether the user who
--                      triggers this functionality is from Production.
--  Version : Initial Version   1.0
--
--  End of Comments  --
PROCEDURE install_new_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_parent_instance_id    IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2,
  p_x_uc_instance_rec     IN OUT NOCOPY uc_instance_rec_type,
  p_x_sub_uc_rec          IN OUT NOCOPY uc_header_rec_type,
  x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type);

-- Start of Comments  --
-- Define procedure install_existing_instance
-- This API is used to assign an existing instance to a UC node.
--
-- Procedure name  : install_existing_instance
-- Type        	: Private
-- Function    	: To assign an existing instance in csi_item_instances to a UC node.
-- Pre-reqs    	:
--
-- install_existing_instance parameters :
--   p_uc_header_id     IN NUMBER  Required
--   p_parent_instance_id IN NUMBER  Required, indicates the parent instance_id
--   p_uc_instance_rec  IN uc_instance_rec_type Required
--                        to store the existing instance to be installed
--   p_prod_user_flag   IN VARCHAR2(1)  Required, to indicate whether the user who
--                      triggers this functionality is from Production.
-- Version : Initial Version   1.0
--
-- End of Comments  --
PROCEDURE install_existing_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_parent_instance_id    IN  NUMBER,
  p_instance_id           IN  NUMBER,
  p_instance_number       IN  csi_item_instances.instance_number%TYPE := NULL,
  p_relationship_id       IN  NUMBER,
  p_csi_ii_ovn            IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2,
  x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type);

-- Start of Comments  --
-- Define procedure swap_instances
-- This API is used by Production user to make parts change: replace an old instance
-- with a new one in a UC tree.
--
-- Procedure name  : swap_instance
-- Type        	: Private
-- Function    	: To replace an old instance a new one in a UC tree.
-- Pre-reqs    	:
--
-- swap_instances parameters :
--   p_uc_header_id     IN NUMBER  Required, UC header identifier
--   p_parent_instance_id IN NUMBER  Required, parent instance_id of the instanceto be replaced
--   p_old_instance_id  IN NUMBER  Required, the instance to be replaced
--   p_new_instance_rec IN uc_instance_rec_type Required, the new instance to replace the old instance
--   p_prod_user_flag   IN VARCHAR2(1)  Required, to indicate whether the user who
--                      triggers this functionality is from Production.
-- Version : Initial Version   1.0
--
-- End of Comments  --
PROCEDURE swap_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_parent_instance_id    IN  NUMBER,
  p_old_instance_id       IN  NUMBER,
  p_new_instance_id       IN  NUMBER,
  p_new_instance_number   IN  csi_item_instances.instance_number%TYPE := NULL,
  p_relationship_id       IN  NUMBER,
  p_csi_ii_ovn            IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2,
  x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type);

-- Start of Comments  --
-- Define procedure get_available_instances
-- This API is used to get all the alternate instances for a given node in a UC tree.
--
-- Procedure name  : get_available_instances
-- Type        	: Private
-- Function    	:  get all the alternate instances for a given node in a UC tree.
-- Pre-reqs    	:
--
-- get_available_instances parameters :
--   p_relationship_id  IN NUMBER  Required, to indicate the MC position.
--   x_csi_instance_tbl OUT csi_instance_tbl_type Required, to store all the alternate
--                     instances which could be installed in position p_relationship_id.
-- Version : Initial Version   1.0
--
--  End of Comments  --
PROCEDURE get_available_instances(
  p_api_version            IN  NUMBER := 1.0,
  p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
  --p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2,
  p_parent_instance_id     IN  NUMBER, --in order to include the extra siblings
  p_relationship_id        IN  NUMBER,
  p_item_number            IN  VARCHAR2 :='%',
  p_serial_number          IN  VARCHAR2 :='%',
  p_instance_number        IN  VARCHAR2 :='%',
  p_workorder_id           IN  NUMBER := NULL, --required by Part Changes
  p_start_row_index        IN  NUMBER,
  p_max_rows               IN  NUMBER,
  x_available_instance_tbl OUT NOCOPY available_instance_tbl_type,
  x_tbl_count              OUT NOCOPY NUMBER);

  --****************************************************************************
   -- Procedure for getting all instances that are available in sub inventory and
   -- available for installation at a particular UC position.
   -- Balaji added for OGMA issue # 86
   --****************************************************************************
   PROCEDURE Get_Avail_Subinv_Instances(
     p_api_version            IN  NUMBER := 1.0,
     p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level       IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
     p_relationship_id        IN  NUMBER,
     p_item_number            IN  VARCHAR2 :='%',
     p_serial_number          IN  VARCHAR2 :='%',
     p_instance_number        IN  VARCHAR2 :='%',
     p_workorder_id           IN  NUMBER := NULL, --required by Part Changes
     p_start_row_index        IN  NUMBER,
     p_max_rows               IN  NUMBER,
     x_avail_subinv_instance_tbl OUT NOCOPY available_instance_tbl_type
   );

-- Start of Comments  --
-- Define procedure create_unassigned_instance.
-- This API is used to create a new instance in csi_item_instances and assign it
-- to the UC root node as extra node.
--
-- Procedure name: create_unassigned_instance
-- Type          : Private
-- Function      : To create a new instance in csi_item_instances and assign it
--                 to the UC root node as extra node.
-- Pre-reqs:
--
-- create_unassigned_instance parameters:
--   p_uc_header_id       IN     NUMBER                Required
--   p_x_uc_instance_rec  IN OUT uc_instance_rec_type  Required
--
--  Version : Initial Version   1.0
--
--
--  18-Nov-2008    SATHAPLI    FP ER 6504147 - Created new API create_unassigned_instance.
--
--  End of Comments  --
PROCEDURE create_unassigned_instance(
    p_api_version           IN            NUMBER   := 1.0,
    p_init_msg_list         IN            VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2,
    p_uc_header_id          IN            NUMBER,
    p_x_uc_instance_rec     IN OUT NOCOPY uc_instance_rec_type);

END AHL_UC_INSTANCE_PVT; -- Package spec

/
