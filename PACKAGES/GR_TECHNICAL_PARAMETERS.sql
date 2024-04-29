--------------------------------------------------------
--  DDL for Package GR_TECHNICAL_PARAMETERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_TECHNICAL_PARAMETERS" AUTHID CURRENT_USER AS
/*$Header: GRPTECHS.pls 120.1 2005/07/08 14:20:32 methomas noship $*/

/* Global alpha variable definitions */

G_PKG_NAME		CONSTANT VARCHAR2(255) := 'GR_TECHNICAL_PARAMETERS';

PROCEDURE Get_Tech_Parm_Data
				(p_commit IN VARCHAR2,
				 p_api_version IN NUMBER,
				 p_organization_id IN NUMBER,
				 p_property_id IN VARCHAR2,
				 p_inventory_item_id IN NUMBER,
				 p_label_code IN VARCHAR2,
				 x_value OUT NOCOPY VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_data OUT NOCOPY VARCHAR2);

END GR_TECHNICAL_PARAMETERS;

 

/
