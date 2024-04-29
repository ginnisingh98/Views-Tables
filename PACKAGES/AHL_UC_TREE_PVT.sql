--------------------------------------------------------
--  DDL for Package AHL_UC_TREE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UC_TREE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUCTS.pls 120.0.12010000.2 2008/11/06 10:54:59 sathapli ship $ */

-- Define Record Type and Table Type for immediate children of a given UC node
/*
TYPE uc_child_rec_type IS RECORD(
   node_type                   VARCHAR2(1),
   instance_id                 NUMBER,
   relationship_id             NUMBER,
   leaf_node_flag              VARCHAR2(1),
   has_subconfig_flag          VARCHAR2(1));
TYPE uc_child_tbl_type IS TABLE OF uc_child_rec_type INDEX BY BINARY_INTEGER;
*/
-- Define Record Type and Table Type for all descendants of a given UC root node
TYPE uc_descendant_rec_type IS RECORD(
   node_type                   VARCHAR2(1),
   instance_id                 NUMBER,
   parent_instance_id          NUMBER,
   part_info                   VARCHAR2(80),
   relationship_id             NUMBER,
   parent_rel_id               NUMBER,
   position_reference          FND_LOOKUPS.meaning%TYPE,
   position_necessity          FND_LOOKUPS.meaning%TYPE,
   leaf_node_flag              VARCHAR2(1),
   has_subconfig_flag          VARCHAR2(1),
   -- SATHAPLI::Enigma code changes, 26-Aug-2008
   ata_code                    AHL_MC_RELATIONSHIPS.ATA_CODE%TYPE);
TYPE uc_descendant_tbl_type IS TABLE OF uc_descendant_rec_type INDEX BY BINARY_INTEGER;

-- Start of Comments  --
-- Define procedure get_immediate_children
-- This API is used to draw the UC tree. For a given node, it will list all of its
-- immediate children nodes.
--
-- Procedure name  : get_immediate_children
-- Type        	: Private
-- Function    	: To replace an old instance a new one in a UC tree.
-- Pre-reqs    	:
--
-- get_immediate_children parameters :
--   p_uc_child_rec     IN uc_child_rec_type  Required
--   x_uc_child_tbl     OUT uc_child_tbl_type Required
--                      p_uc_child_rec.leaf_node_flag and
--                      p_uc_child_rec.has_subconfig_flag can be null
--  Version : Initial Version   1.0
--
--  End of Comments  --
/*
PROCEDURE get_immediate_children(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  --p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_parent_rec         IN  uc_child_rec_type,
  x_uc_child_tbl          OUT NOCOPY uc_child_tbl_type);
*/
-- Start of Comments  --
-- Define procedure get_immediate_children
-- This API is used to draw the UC tree. For a given uc root node, it will list all of its
-- descendant nodes.
--
-- Procedure name  : get_whole_uc_tree
-- Type        	: Private
-- Function    	: To replace an old instance a new one in a UC tree.
-- Pre-reqs    	:
--
-- get_whole_uc_tree parameters :
--   p_uc_header_id      IN NUMBER  Required
--   x_uc_descendant_tbl OUT uc_descendant_tbl_type Required
-- Version : Initial Version   1.0
--
--  End of Comments  --
PROCEDURE get_whole_uc_tree(
  p_api_version           IN  NUMBER := 1.0,
  p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
  --p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  x_uc_descendant_tbl     OUT NOCOPY uc_descendant_tbl_type);

-- Start of Comments  --
-- Define Procedure migrate_uc_tree --
-- This API is used to migrate a UC tree to a new MC revision or copy
--
-- Procedure name  : migrate_uc_tree
-- Type        	: Private
-- Function    	: To migrate an existing UC tree to a new MC revision or copy.
-- Pre-reqs    	:
--
-- migrate_uc_tree parameters :
--   p_uc_header_id     IN NUMBER  Required
--                      Indicates the UC to be migrated
--   p_mc_header_id     IN NUMBER  Required
--                      Indicates the new MC to which the UC will be migrated
--
--  Version : Initial Version   1.0
--
--  End of Comments  --
PROCEDURE migrate_uc_tree(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_uc_header_id          IN  NUMBER,
  p_mc_header_id          IN  NUMBER);

-- Start of Comments  --
-- Define Procedure remap_uc_subtree --
-- This API is used to remap a UC subtree (not a sub-unit) to a MC branch. It is called
-- by ahl_uc_instnace_pvt.install_existing_instance.
--
-- Procedure name  : remap_uc_subtree
-- Type        	: Private
-- Function    	: To remap a UC subtree (not a sub-unit) to a MC branch.
-- Pre-reqs    	:
--
-- remap_uc_subtree parameters :
--   p_instance_id      IN NUMBER  Required
--                      Indicates the instance id of the UC subtree top node.
--   p_relationship_id  IN NUMBER  Required
--                      Indicates position id of the MC branch top node.
--
--  Version : Initial Version   1.0
--
--  End of Comments  --
PROCEDURE remap_uc_subtree(
  p_api_version           IN  NUMBER,
  p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
  p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
  p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_instance_id           IN  NUMBER,
  p_relationship_id       IN  NUMBER);

END AHL_UC_TREE_PVT; -- Package spec

/
