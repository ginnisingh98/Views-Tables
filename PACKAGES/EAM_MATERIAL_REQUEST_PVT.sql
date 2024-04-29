--------------------------------------------------------
--  DDL for Package EAM_MATERIAL_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_MATERIAL_REQUEST_PVT" AUTHID CURRENT_USER AS
  /* $Header: EAMWEMRS.pls 120.1 2007/12/12 02:27:15 mashah ship $*/

/* Author: dgupta
A wrapper to the WIP picking API. This API works at the component level.
Note that messaging is enhanced. If the WIP API errors out, we try to determine
the problem here and give a more meaningful error message.
*/

PROCEDURE allocate(
  p_api_version           IN            NUMBER   := 1.0,
  p_init_msg_list         IN            VARCHAR2 := fnd_api.g_false,
  p_commit                IN            VARCHAR2 := fnd_api.g_false,
  p_validation_level      IN            NUMBER   := fnd_api.g_valid_level_full,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  x_request_number        OUT NOCOPY    VARCHAR2,
  p_wip_entity_type       IN            NUMBER,
  p_organization_id       IN            NUMBER,
  p_wip_entity_id         IN            NUMBER,
  p_operation_seq_num     IN            NUMBER,
  p_inventory_item_id     IN            NUMBER,
  p_project_id            IN            NUMBER   := null,
  p_task_id               IN            NUMBER   := null,
  p_requested_quantity    IN            NUMBER   := null,
  p_source_subinventory   IN            VARCHAR2 := null,
  p_source_locator        IN            NUMBER := null,
  p_lot_number            IN            VARCHAR2 := null,
  p_fm_serial             IN            VARCHAR2 := null,
  p_to_serial             IN            VARCHAR2 := null
);

END EAM_MATERIAL_REQUEST_PVT;

/
