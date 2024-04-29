--------------------------------------------------------
--  DDL for Package EAM_REBUILDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_REBUILDS_PVT" AUTHID CURRENT_USER AS
  /* $Header: EAMWERBS.pls 115.0 2002/11/28 02:49:33 dgupta noship $*/

  VALIDATE_GENERAL  CONSTANT NUMBER  := 1;
  VALIDATE_ISSUE    CONSTANT NUMBER  := 2;
  VALIDATE_REMOVE   CONSTANT NUMBER  := 3;

/* Author: dgupta
Used for validating rebuildables. Can operate in different validation modes. VALIDATE_REMOVE: rebuild being replaced/taken out of the hierarchy
VALIDATE_ISSUE: rebuild being issued to eam work order
VALIDATE_GENERAL: rebuild being used in a rebuildable work order.

Note that wip_entity_id is mandatory if the mode is VALIDATE_REMOVE. This API
outputs meaningful messages when validation fails explicitly telling what is
wrong. Primarily used by self service "Enter Rebuilds" page but can be used at
other places as well. The behavior the rebuild item and rebuild activity
parameters is such that either the "id" or the "name" can be given.
We look first into the id fields, then the name field if the id field is null.
If the name is supplied, the id is returned back as a out parameter.
Self service currently uses the id out parameter and only
supplies the name component.
*/

PROCEDURE validate_rebuild(
  p_init_msg_list         IN            VARCHAR2 := FND_API.G_FALSE,
  p_validate_mode         IN            NUMBER,
  p_organization_id       IN            NUMBER,
  p_wip_entity_id         IN            NUMBER := null,
  p_rebuild_item_id       IN OUT NOCOPY NUMBER,
  p_rebuild_item_name     IN            VARCHAR2,
  p_rebuild_serial_number IN            VARCHAR2,
  p_rebuild_activity_id   IN OUT NOCOPY NUMBER,
  p_rebuild_activity_name IN            VARCHAR2,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
);

END EAM_REBUILDS_PVT;

 

/
