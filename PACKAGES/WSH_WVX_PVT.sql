--------------------------------------------------------
--  DDL for Package WSH_WVX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_WVX_PVT" AUTHID CURRENT_USER as
/* $Header: WSHUTWXS.pls 115.10 99/08/11 19:23:12 porting ship $ */

--           WSH_WVX_PVT
-- Purpose
--    Extension of Weight/Volume API (WSH_WV_PVT)
-- History
--    06-JAN-1998 wrudge Created
--

FUNCTION x_order_net_wt_in_delivery(
		order_number	IN	NUMBER,
		order_type_id	IN	NUMBER,
		delivery_id	IN	NUMBER,
		weight_uom	IN	VARCHAR2)
RETURN NUMBER;


PROCEDURE ato_weight_volume(
		source		IN	VARCHAR2,
		ato_line_id	IN	NUMBER,
		quantity	IN	NUMBER,
		weight_uom	IN	VARCHAR2,
		weight		OUT	NUMBER,
		volume_uom	IN	VARCHAR2,
		volume		OUT	NUMBER,
		status		IN OUT	NUMBER);


FUNCTION x_containers_load_check(
                delivery_id       IN     NUMBER,
		pack_mode	  IN     VARCHAR2 DEFAULT 'ALL',
                status            IN OUT NUMBER)
RETURN BOOLEAN;

PROCEDURE container_net_volume(
                delivery_id       IN     NUMBER,
                organization_id   IN     NUMBER,
                container_id      IN     NUMBER,
                sequence_number   IN     NUMBER,
                master_uom        IN     VARCHAR2,
	        pack_mode         IN     VARCHAR2,
                volume            OUT    NUMBER);

PROCEDURE container_fill_percent(
                delivery_id       IN     NUMBER,
                organization_id   IN     NUMBER,
                container_id      IN     NUMBER,
                container_item_id IN     NUMBER,
                sequence_number   IN     NUMBER,
                container_qty     IN     NUMBER,
	        pack_mode         IN     VARCHAR2,
                fill_percent      OUT    NUMBER);

PROCEDURE set_messages(message_string IN     VARCHAR2,
                       message_count  IN OUT NUMBER,
                       message_text1  IN OUT VARCHAR2,
                       message_text2  IN OUT VARCHAR2,
                       message_text3  IN OUT VARCHAR2,
                       message_text4  IN OUT VARCHAR2);

PROCEDURE containers_net_weight(X_container_id    IN     NUMBER,
                                X_organization_id IN     NUMBER,
                                X_pack_mode       IN     VARCHAR2,
                                X_master_uom      IN     VARCHAR2,
                                X_net_weight      IN OUT NUMBER);

PROCEDURE containers_tare_weight(X_container_id    IN     NUMBER,
                                 X_master_uom      IN     VARCHAR2,
                                 X_tare_weight     IN OUT NUMBER,
				 x_org_id          IN     NUMBER);

PROCEDURE containers_tare_weight_self(
   X_container_id IN     NUMBER,
   X_org_id       IN     NUMBER,
   X_master_uom   IN     VARCHAR2,
   X_tare_weight  IN OUT NUMBER);

PROCEDURE del_containers_tare_weight(
   X_del_id       IN     NUMBER,
   X_org_id       IN     NUMBER,
   X_master_uom   IN     VARCHAR2,
   X_tare_weight  IN OUT NUMBER);

PROCEDURE auto_calc_cont(x_del_id IN NUMBER,
			 x_org_id IN NUMBER,
			 x_pack_mode IN VARCHAR2,
			 x_fill_base IN VARCHAR2);


END WSH_WVX_PVT;

 

/
