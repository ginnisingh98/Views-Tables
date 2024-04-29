--------------------------------------------------------
--  DDL for Package Body WMS_UI_TASKS_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_UI_TASKS_APIS" AS
  /* $Header: WMSTKUIB.pls 115.0 2003/07/17 02:15:19 kajain noship $*/

PROCEDURE init_ui_startup_values(x_return_status        OUT NOCOPY VARCHAR2,
				 x_msg_data             OUT NOCOPY VARCHAR2,
				 x_inv_patch_level      OUT NOCOPY NUMBER,
				 x_po_patch_level       OUT NOCOPY NUMBER,
				 x_wms_patch_level      OUT NOCOPY NUMBER)
  IS
BEGIN
   x_return_status  := fnd_api.g_ret_sts_success;
   x_msg_data := '';
   x_inv_patch_level := WMS_UI_TASKS_APIS.g_inv_patch_level;
   x_po_patch_level := WMS_UI_TASKS_APIS.g_po_patch_level;
   x_wms_patch_level := WMS_UI_TASKS_APIS.g_wms_patch_level;
END init_ui_startup_values;

END;
--END wms_ui_tasks_apis;

/
