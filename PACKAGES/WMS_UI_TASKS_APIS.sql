--------------------------------------------------------
--  DDL for Package WMS_UI_TASKS_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_UI_TASKS_APIS" AUTHID CURRENT_USER AS
/* $Header: WMSTKUIS.pls 115.1 2003/08/15 17:03:29 kajain noship $*/

-- Added two new global variables to store the values for the po, WMS and inv
-- patch LEVEL.
-- Since we are hard prereqing PO ARU we do not need to check if PO.J is
-- installed. However, since all the code already is using it all we need
-- to do is assign it the value of g_inv_patch_level since if inv.J or
-- higher is installed, it will imply the PO.J functionality exists.
g_po_patch_level NUMBER := inv_control.Get_Current_Release_Level;
g_inv_patch_level NUMBER := inv_control.Get_Current_Release_Level;
g_wms_patch_level NUMBER := wms_control.Get_Current_Release_Level;

g_patchset_j NUMBER := 110510;
g_patchset_j_po NUMBER := 110510;

PROCEDURE init_ui_startup_values(x_return_status        OUT NOCOPY VARCHAR2,
				 x_msg_data             OUT NOCOPY VARCHAR2,
				 x_inv_patch_level      OUT NOCOPY NUMBER,
				 x_po_patch_level       OUT NOCOPY NUMBER,
				 x_wms_patch_level      OUT NOCOPY NUMBER);


END WMS_UI_TASKS_APIS;

 

/
