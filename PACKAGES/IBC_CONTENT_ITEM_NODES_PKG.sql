--------------------------------------------------------
--  DDL for Package IBC_CONTENT_ITEM_NODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CONTENT_ITEM_NODES_PKG" AUTHID CURRENT_USER AS
/* $Header: ibctcins.pls 115.4 2002/11/17 16:04:56 srrangar ship $*/

-- Purpose: Table Handler for Ibc_Content_Item_Nodes table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for FND_API.G_MISS_XXX

PROCEDURE INSERT_ROW (
 x_rowid                           OUT NOCOPY VARCHAR2
,px_content_item_node_id           IN OUT NOCOPY NUMBER
,p_content_item_id                 IN NUMBER
,p_directory_node_id               IN NUMBER
,p_object_version_number           IN NUMBER
,p_creation_date                   IN DATE          DEFAULT NULL
,p_created_by                      IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
);

PROCEDURE LOCK_ROW (
  p_content_item_node_id IN NUMBER,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_DIRECTORY_NODE_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER
);

PROCEDURE UPDATE_ROW (
 p_content_item_node_id            IN NUMBER
,p_content_item_id                 IN NUMBER        DEFAULT NULL
,p_directory_node_id               IN NUMBER        DEFAULT NULL
,p_last_updated_by                 IN NUMBER        DEFAULT NULL
,p_last_update_date                IN DATE          DEFAULT NULL
,p_last_update_login               IN NUMBER        DEFAULT NULL
,p_object_version_number           IN NUMBER        DEFAULT NULL
);

PROCEDURE DELETE_ROW (
    p_content_item_node_id IN NUMBER
);

END Ibc_Content_Item_Nodes_Pkg;

 

/
