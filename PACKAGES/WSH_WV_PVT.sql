--------------------------------------------------------
--  DDL for Package WSH_WV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_WV_PVT" AUTHID CURRENT_USER as
/*      $Header: WSHUTWVS.pls 115.6 99/07/16 08:24:20 porting ship $ */

--           WSH_WV_PVT
-- Purpose
--    Weight/Volume API for Departure Planning Workbench and Ship Confirm
-- History
--    12-AUG-1996 wrudge Created
--

PROCEDURE departure_weight_volume(
                source            IN     VARCHAR2,
                departure_id      IN     NUMBER,
                organization_id   IN     NUMBER,
                wv_flag           IN     VARCHAR2,
                update_flag       IN     VARCHAR2,
                menu_flag         IN     VARCHAR2,
		dpw_pack_flag	  IN	 VARCHAR2,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_weight_uom IN     VARCHAR2,
                net_weight        IN OUT NUMBER,
                tare_weight       IN OUT NUMBER,
                master_volume_uom IN     VARCHAR2,
                volume            IN OUT NUMBER,
                status            IN OUT NUMBER);

PROCEDURE dep_weight_volume(
                source            IN     VARCHAR2,
                departure_id      IN     NUMBER,
                organization_id   IN     NUMBER,
                wv_flag           IN     VARCHAR2,
                update_flag       IN     VARCHAR2,
                menu_flag         IN     VARCHAR2,
		dpw_pack_flag	  IN	 VARCHAR2,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_weight_uom IN     VARCHAR2,
                net_weight        IN OUT NUMBER,
                tare_weight       IN OUT NUMBER,
                master_volume_uom IN     VARCHAR2,
                volume            IN OUT NUMBER,
                status            IN OUT NUMBER);

PROCEDURE dep_loose_weight_volume(
		source		  IN	 VARCHAR2,
                departure_id      IN     NUMBER,
                organization_id   IN     NUMBER,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_weight_uom IN     VARCHAR2,
                weight            IN OUT NUMBER,
                master_volume_uom IN     VARCHAR2,
                volume            IN OUT NUMBER,
                status            IN OUT NUMBER);

PROCEDURE dep_fill_percentage(
                departure_id      IN     NUMBER,
                organization_id   IN     NUMBER,
                vehicle_id        IN     NUMBER,
		vehicle_max_weight IN    NUMBER,
		gross_weight	  IN     NUMBER,
		vehicle_max_volume IN    NUMBER,
		volume		  IN	 NUMBER,
		vehicle_min_fill  IN	 NUMBER,
                actual_fill       IN OUT NUMBER,
                status            IN OUT NUMBER);

PROCEDURE del_weight_volume(
                source            IN     VARCHAR2,
                del_id            IN     NUMBER,
                organization_id   IN     NUMBER,
                update_flag       IN     VARCHAR2,
		menu_flag	  IN	 VARCHAR2,
		dpw_pack_flag	  IN	 VARCHAR2,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_weight_uom IN     VARCHAR2,
                gross_weight      IN OUT NUMBER,
                master_volume_uom IN     VARCHAR2,
                volume            IN OUT NUMBER,
                status            IN OUT NUMBER);

PROCEDURE del_volume(
		source		  IN	 VARCHAR2,
                delivery_id       IN     NUMBER,
                organization_id   IN     NUMBER,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_uom        IN     VARCHAR2,
                volume            IN OUT NUMBER,
                status            IN OUT NUMBER);

PROCEDURE del_weight(
                source            IN     VARCHAR2,
                delivery_id       IN     NUMBER,
                organization_id   IN     NUMBER,
                menu_flag         IN     VARCHAR2,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_uom        IN     VARCHAR2,
                gross_weight      IN OUT NUMBER,
                status            IN OUT NUMBER);

FUNCTION validate_packed_qty(
                delivery_id       IN     NUMBER,
		pack_mode	  IN     VARCHAR2 DEFAULT 'ALL',
                status            IN OUT NUMBER)
RETURN BOOLEAN;

FUNCTION containers_load_check(
                delivery_id       IN     NUMBER,
		pack_mode	  IN     VARCHAR2 DEFAULT 'ALL',
                status            IN OUT NUMBER)
RETURN BOOLEAN;

FUNCTION containers_weight_check(
                delivery_id       IN     NUMBER,
                organization_id   IN     NUMBER,
                status            IN OUT NUMBER)
RETURN BOOLEAN;

PROCEDURE containers_weight(
                delivery_id       IN     NUMBER,
                organization_id   IN     NUMBER,
                sequence_number   IN     NUMBER,
                menu_flag         IN     VARCHAR2,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_uom        IN     VARCHAR2,
                weight            IN OUT NUMBER,
                status            IN OUT NUMBER);

PROCEDURE unpacked_items_weight(
                delivery_id       IN     NUMBER,
                organization_id   IN     NUMBER,
                x_sc_wv_mode      IN     VARCHAR2 DEFAULT 'ALL',
                master_uom        IN     VARCHAR2,
                weight            IN OUT NUMBER,
                status            IN OUT NUMBER);

PROCEDURE del_autopack(
                del_id      	 IN     NUMBER,
		organization_id  IN	NUMBER,
                status           IN OUT NUMBER);

PROCEDURE del_packcont(
		del_id		IN	NUMBER,
		organization_id	IN	NUMBER,
		cont_item_id	IN	NUMBER,
		raw_qty		IN	NUMBER,
		min_fill	IN	NUMBER,	-- range 0.00-1.00 (not 0-100)
		parent_seq	IN	NUMBER,
		load_seq_number	IN	NUMBER,
		weight_uom_code	IN	VARCHAR2,
                status		IN OUT	NUMBER);

FUNCTION order_net_weight_in_delivery(
		order_number	IN	NUMBER,
		order_type_id	IN	NUMBER,
		delivery_id	IN	NUMBER,
		weight_uom	IN	VARCHAR2)
RETURN NUMBER;

FUNCTION convert_uom(from_uom IN VARCHAR2,
                       to_uom IN VARCHAR2,
                     quantity IN NUMBER,
                      item_id IN NUMBER DEFAULT NULL)
RETURN NUMBER;
  pragma restrict_references (convert_uom, WNDS);

END WSH_WV_PVT;

 

/
