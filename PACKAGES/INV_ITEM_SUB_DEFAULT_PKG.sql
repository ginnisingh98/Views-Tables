--------------------------------------------------------
--  DDL for Package INV_ITEM_SUB_DEFAULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_SUB_DEFAULT_PKG" AUTHID CURRENT_USER AS
/* $Header: INVISDPS.pls 115.3 2002/12/01 02:37:06 rbande noship $ */
   PROCEDURE INSERT_UPD_ITEM_SUB_DEFAULTS (
     x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
   , p_organization_id       IN  NUMBER
   , p_inventory_item_id     IN  NUMBER
   , p_subinventory_code     IN  VARCHAR2
   , p_default_type          IN  NUMBER
   , p_creation_date         IN  DATE
   , p_created_by            IN  NUMBER
   , p_last_update_date      IN  DATE
   , p_last_updated_by       IN  NUMBER
   , p_process_code          IN  VARCHAR2
   , p_commit                IN  VARCHAR2 DEFAULT fnd_api.g_false);
END INV_ITEM_SUB_DEFAULT_PKG;

 

/
