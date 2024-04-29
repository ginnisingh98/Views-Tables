--------------------------------------------------------
--  DDL for Package AHL_UC_INSTANCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_INSTANCE_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPUCIS.pls 120.0.12010000.2 2008/11/20 11:37:53 sathapli ship $ */
/*#
 * This package provides the APIs for processing the node instance in a Unit Configuration.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Unit Configuration Node
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_UNIT_CONFIG
 */


-- Start of Comments  --
-- Define Procedure unassociate_instance_pos
-- This API is used to to nullify a child instance's position reference but keep
-- the parent-child relationship in a UC tree structure (in other word, to make
-- the child instance as an extra node in the UC).
--
-- Procedure name: unassociate_instance
-- Type:           Private
-- Function:       To nullify a child instance's position reference but keep
--                 the parent-child relationship in a UC tree structure.
-- Pre-reqs:
--
-- unassociate_instance parameters:
-- p_uc_header_id    IN NUMBER  Required
-- p_instance_id     IN NUMBER  Required
-- p_csi_ii_ovn      IN NUMBER  Required, the origianl object_version_number of the record
--                   in table csi_ii_relationships where p_instance_id is the subject_id
-- p_prod_user_flag  IN VARCHAR2(1)  Required, to indicate whether the user who
--                    triggers this functionality is from Production.
-- Version: Initial Version   1.0
--
-- End of Comments  --
/*#
 * This API is used to nullify a child instance's position reference,
 * but keep the parent-child relationship in a UC tree structure.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @param p_uc_header_id Unit Configuration Header ID
 * @param p_uc_name Unit Configuration Name
 * @param p_instance_id Instance ID
 * @param p_instance_num Instance Number
 * @param p_prod_user_flag Flag to identify whether the invoker is from Production
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Unassociate Instance Position Reference
 */
PROCEDURE unassociate_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER := NULL,
  p_uc_name               IN  VARCHAR2,
  p_instance_id           IN  NUMBER := NULL,
  p_instance_num          IN  VARCHAR2,
  p_prod_user_flag        IN  VARCHAR2);

-- Start of Comments  --
-- Define Procedure remove_instance
-- This API is used to to remove(uninstall) an instance (leaf, branch node or
-- sub-unit) from a UC node. After uninstallation, this instance is available to be
-- reinstalled in another appropriate position.
--
-- Procedure name: remove_instance
-- Type:           Public
-- Function:       To remove(uninstall) an instance (leaf, branch node or
--                 sub-unit) from a UC node..
-- Pre-reqs:
--
-- remove_instance parameters:
-- p_uc_header_id    IN NUMBER  Required
-- p_instance_id     In NUMBER  Required
-- p_prod_user_flag  IN VARCHAR2(1)  Required, to indicate whether the user who
--                   triggers this functionality is from Production.
-- Version: Initial Version   1.0
--
-- End of Comments  --
/*#
 * This API is used to remove(uninstall) an instance from an Unit Config node.
 * The instance can be leaf, branch node or sub-unit.
 * After uninstallation this instance is available to be reinstalled in another
 * appropriate position.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @param p_uc_header_id Unit Configuration Header ID
 * @param p_uc_name Unit Configuration Name
 * @param p_instance_id Instance ID
 * @param p_instance_num Instance Number
 * @param p_prod_user_flag Flag to identify whether the invoker is from Production
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Remove Instance from UC Node
 */
PROCEDURE remove_instance (
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER := NULL,
  p_uc_name               IN  VARCHAR2,
  p_instance_id           IN  NUMBER := NULL,
  p_instance_num          IN  VARCHAR2,
  p_prod_user_flag        IN  VARCHAR2);

-- Start of Comments  --
-- Define Procedure update_instance
-- This API is used to update an instance's (top node or non top node) attributes
-- (serial Number, serial_number_tag, lot_number, revision, mfg_date and etc.)
--
-- Procedure name: update_instance
-- Type:           Public
-- Function:       To update some attributes of an instance (top or non-top node) installed
--                 in a Unit Configuration.
-- Pre-reqs:
--
-- update_instance parameters:
--   p_uc_header_id     IN NUMBER  Required
--   p_instance_id      In NUMBER  Required
--   p_prod_user_flag   IN VARCHAR2(1)  Required, to indicate whether the user who
--                      triggers this functionality is from Production.
--  Version: Initial Version   1.0
--
--  End of Comments  --
/*#
 * This API is used to update attributes of an instance.
 * The instance can be a top node or a non-top node.
 * The attributes that can be updated are serial number,serial_number_tag,
 * lot_number,revision,mfg_date etc
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @param p_uc_header_id Unit Configuration Header ID
 * @param p_uc_name Unit Configuration Name
 * @param p_uc_instance_rec Unit Config instance record of type ahl_uc_instance_pvt.uc_instance_rec_type
 * @param p_prod_user_flag Flag to identify whether the invoker is from Production
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Instance Attributes
 */
PROCEDURE update_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER := NULL,
  p_uc_name               IN  VARCHAR2,
  p_uc_instance_rec       IN  ahl_uc_instance_pvt.uc_instance_rec_type,
  p_prod_user_flag        IN  VARCHAR2);

-- Start of Comments  --
-- Define procedure create_install_instance
-- This API is used to create a new instance in csi_item_instances and assign it
-- to a UC node.
--
-- Procedure name: create_install_instance
-- Type:           Public
-- Function:       To create a new instance in csi_item_instances and assign it
--                 to a UC node.
-- Pre-reqs:
--
-- create_install_instance parameters:
--   p_uc_header_id       IN NUMBER, required
--   p_parent_instance_id IN NUMBER, required, indicates the parent instance_id
--   p_x_uc_instance_rec  In OUT uc_instance_rec_type, required, indicates the new
--                        instance to be created and installed.
--   p_x_sub_uc_rec       IN OUT uc_header_rec_type
--                        to store the sub UC header information if also creating a
--                        sub UC simultaneously
--   x_warning_msg_tbl    OUT ahl_uc_validation_pub.error_tbl_type
--                        to store the warning message after instance installation and
--                        calling validation API
--   p_prod_user_flag     IN VARCHAR2(1)  Required, to indicate whether the user who
--                        triggers this functionality is from Production.
--  Version: Initial Version   1.0
--
--  End of Comments  --
/*#
 * This API is used to Create a new instance and assign it to a UC node.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @param p_uc_header_id Unit Configuration Header ID
 * @param p_uc_name Unit Configuration Name
 * @param p_parent_instance_id indicates the parent instance_id
 * @param p_parent_instance_num indicates the parent instance number
 * @param p_prod_user_flag Flag to identify whether the invoker is from Production
 * @param p_x_uc_instance_rec indicates the new instance to be created and installed of type uc_instance_rec_type
 * @param p_x_sub_uc_rec to store the sub UC header information if also creating a sub UC simultaneously
 * @param x_warning_msg_tbl to store the warning message after instance installation and calling validation API
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Install Instance
 */
PROCEDURE create_install_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER := NULL,
  p_uc_name               IN  VARCHAR2,
  p_parent_instance_id    IN  NUMBER := NULL,
  p_parent_instance_num   IN  VARCHAR2,
  p_prod_user_flag        IN  VARCHAR2,
  p_x_uc_instance_rec     IN OUT NOCOPY ahl_uc_instance_pvt.uc_instance_rec_type,
  p_x_sub_uc_rec          IN OUT NOCOPY ahl_uc_instance_pvt.uc_header_rec_type,
  x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type);

-- Start of Comments  --
-- Define procedure install_instance
-- This API is used to assign an existing instance to a UC node.
--
-- Procedure name: install_instance
-- Type:           Public
-- Function:       To assign an existing instance in csi_item_instances to a UC node.
-- Pre-reqs:
--
-- install_instance parameters:
--   p_uc_header_id       IN NUMBER, required
--   p_parent_instance_id IN NUMBER, required, indicates the parent instance_id
--   p_instance_id        IN NUMBER, required, indicates the instance to be installed
--   p_instance_number    IN csi_item_instances.instance_number%TYPE := NULL,
--   p_relationship_id    IN NUMBER, required, indicates the position to be installed.
--   x_warning_msg_tbl    OUT ahl_uc_validation_pub.error_tbl_type
--                        to store the warning message after instance installation and
--                        calling validation API
--   p_prod_user_flag     IN VARCHAR2(1)  Required, to indicate whether the user who
--                        triggers this functionality is from Production.
-- Version: Initial Version   1.0
--
-- End of Comments  --
/*#
 * This API is used to assign an existing instance to a UC node
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @param p_uc_header_id Unit Configuration Header ID
 * @param p_uc_name Unit Configuration Name
 * @param p_parent_instance_id indicates the parent instance_id
 * @param p_parent_instance_num indicates the parent instance number
 * @param p_instance_id indicates the instance to be installed
 * @param p_instance_num csi_item_instances.instance_number%TYPE := NULL
 * @param p_relationship_id indicates the position to be installed
 * @param p_prod_user_flag indicate whether the user who triggers this functionality is from Production.
 * @param x_warning_msg_tbl to store the warning message after instance installation and calling validation API
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Assign Instance To UC Node
 */
PROCEDURE install_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER := NULL,
  p_uc_name               IN  VARCHAR2,
  p_parent_instance_id    IN  NUMBER := NULL,
  p_parent_instance_num   IN  VARCHAR2,
  p_instance_id           IN  NUMBER := NULL,
  p_instance_num          IN  VARCHAR2,
  p_relationship_id       IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2,
  x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type);

-- Start of Comments  --
-- Define procedure swap_instances
-- This API is used by Production user to make parts change: replace an old instance
-- with a new one in a UC tree.
--
-- Procedure name: swap_instance
-- Type:           Private
-- Function:       To replace an old instance with a new one in a UC tree.
-- Pre-reqs:
--
-- swap_instances parameters:
--   p_uc_header_id        IN NUMBER, required, UC header identifier
--   p_parent_instance_id  IN NUMBER, required, parent instance_id of the instance to be replaced
--   p_old_instance_id     IN NUMBER, required, the instance to be replaced
--   p_new_instance_id     IN NUMBER, required, the new instance to replace the old instance
--   p_new_instance_number IN csi_item_instances.instance_number%TYPE := NULL,
--   p_relationship_id     IN NUMBER, required, indicates the position to be installed.
--   x_warning_msg_tbl     OUT ahl_uc_validation_pub.error_tbl_type
--                         to store the warning message after instance installation and
--                         calling validation API
--   p_prod_user_flag      IN VARCHAR2(1)  Required, to indicate whether the user who
--                         triggers this functionality is from Production.
-- Version: Initial Version   1.0
--
-- End of Comments  --
/*#
 * This API is used by production user to replace an old instance with new one in a UC Tree.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @param p_uc_header_id Unit Configuration Header ID
 * @param p_uc_name Unit Configuration Name
 * @param p_parent_instance_id parent instance_id of the instance to be replaced
 * @param p_parent_instance_num indicates the parent instance number
 * @param p_old_instance_id the instance to be replaced
 * @param p_old_instance_num instance number of the old instance
 * @param p_new_instance_id the new instance to replace the old instance
 * @param p_new_instance_num instance number of the new instance
 * @param p_relationship_id indicates the position to be installed
 * @param p_prod_user_flag to indicate whether the user who triggers this functionality is from Production
 * @param x_warning_msg_tbl to store the warning message after instance installation and  calling validation APIahl_uc_validation_pub.error_tbl_type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Swap Instance in UC Tree
 */
PROCEDURE swap_instance(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER := NULL,
  p_uc_name               IN  VARCHAR2,
  p_parent_instance_id    IN  NUMBER := NULL,
  p_parent_instance_num   IN  VARCHAR2,
  p_old_instance_id       IN  NUMBER := NULL,
  p_old_instance_num      IN  VARCHAR2,
  p_new_instance_id       IN  NUMBER := NULL,
  p_new_instance_num      IN  VARCHAR2,
  p_relationship_id       IN  NUMBER,
  p_prod_user_flag        IN  VARCHAR2,
  x_warning_msg_tbl       OUT NOCOPY ahl_uc_validation_pub.error_tbl_type);

-- Start of Comments  --
-- Define procedure create_unassigned_instance.
-- This API is used to create a new instance in csi_item_instances as an extra
-- instance attached to the root node.
--
-- Procedure name: create_unassigned_instance
-- Type:           Public
-- Function:       To create a new instance in csi_item_instances as an extra
--                 instance attached to the root node.
-- Pre-reqs:
--
-- create_unassigned_instance parameters:
--   p_uc_header_id       IN NUMBER, required
--   p_x_uc_instance_rec  In OUT uc_instance_rec_type, required, indicates the new
--                        instance to be created
--
--  Version: Initial Version   1.0
--
--  18-Nov-2008    SATHAPLI    FP ER 6504147 - Created procedure create_unassigned_instance.
--
--  End of Comments  --
/*#
 * This API is used to Create a new instance as an extra instance attached to the root.
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @param p_uc_header_id Unit Configuration Header ID
 * @param p_uc_name Unit Configuration Name
 * @param p_x_uc_instance_rec indicates the new instance to be created
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Unassigned Instance
 */
PROCEDURE create_unassigned_instance(
    p_api_version           IN            NUMBER   := 1.0,
    p_init_msg_list         IN            VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN            VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2,
    p_uc_header_id          IN            NUMBER,
    p_uc_name               IN            VARCHAR2,
    p_x_uc_instance_rec     IN OUT NOCOPY ahl_uc_instance_pvt.uc_instance_rec_type);

END AHL_UC_INSTANCE_PUB; -- Package spec

/
