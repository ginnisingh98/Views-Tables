--------------------------------------------------------
--  DDL for Package WSH_EXTERNAL_INTERFACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_EXTERNAL_INTERFACE_SV" AUTHID CURRENT_USER AS
/* $Header: WSHEXINS.pls 120.1.12010000.1 2008/07/29 06:03:44 appldev ship $ */

C_SDEBUG  CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL1;
C_DEBUG   CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL2;


FUNCTION Get_Warehouse_Type ( p_organization_id   IN   NUMBER,
                              p_event_key         IN   VARCHAR2 DEFAULT NULL,
                              x_return_status     OUT NOCOPY   VARCHAR2,
			      p_delivery_id	  IN   NUMBER DEFAULT NULL,
			      p_delivery_detail_id IN  NUMBER DEFAULT NULL ,
                              p_carrier_id       IN   NUMBER DEFAULT NULL,
                              p_ship_method_code  IN VARCHAR2 DEFAULT NULL,
                              p_msg_display        IN  VARCHAR2 DEFAULT 'Y'
			    ) RETURN VARCHAR2;

PROCEDURE Raise_Event ( p_txn_hist_record   IN     WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type,
                        p_cbod_status       IN     VARCHAR2,
                        x_return_status     IN OUT NOCOPY  VARCHAR2
		      );

PROCEDURE Validate_Item ( p_concatenated_segments IN VARCHAR2,
			  p_organization_id IN NUMBER,
			  x_inventory_item_id OUT NOCOPY  VARCHAR2,
			  x_return_status OUT NOCOPY  VARCHAR2
			);
PROCEDURE Validate_Ship_To ( p_customer_name IN VARCHAR2,
			     p_location IN VARCHAR2,
			     x_customer_id OUT NOCOPY  NUMBER,
			     x_location_id OUT NOCOPY  NUMBER,
			     x_return_status OUT NOCOPY  VARCHAR2,
			     p_site_use_code IN VARCHAR2 DEFAULT 'SHIP_TO',
			     x_site_use_id OUT NOCOPY  NUMBER,
                             p_org_id      IN NUMBER DEFAULT NULL
			   );
END WSH_EXTERNAL_INTERFACE_SV;

/
