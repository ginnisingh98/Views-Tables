--------------------------------------------------------
--  DDL for Package WSH_TPA_SELECTOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TPA_SELECTOR_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHTPSLS.pls 115.4 2002/11/12 01:56:36 nparikh ship $ */

--
-- Procedure:	DeliveryTP
-- Parameters:	p_delivery_id		Delivery being processed
--		x_customer_number	Standard TPS function attributes
-- 		x_ship_to_ece_locn_code
--		x_inter_ship_to_ece_locn_code
--		x_bill_to_ece_locn_code
--		x_tp_group_code
--

PROCEDURE DeliveryTP (
	p_delivery_id			IN	NUMBER,
	x_customer_number		OUT NOCOPY 	VARCHAR2,
	x_ship_to_ece_locn_code		OUT NOCOPY 	VARCHAR2,
	x_inter_ship_to_ece_locn_code	OUT NOCOPY 	VARCHAR2,
	x_bill_to_ece_locn_code		OUT NOCOPY 	VARCHAR2,
	x_tp_group_code			OUT NOCOPY 	VARCHAR2);
--<TPA_TPS>

--
-- Procedure:	ContainerTP
-- Parameters:	p_container_instance_id	Container being processed
--		x_customer_number	Standard TPS function attributes
-- 		x_ship_to_ece_locn_code
--		x_inter_ship_to_ece_locn_code
--		x_bill_to_ece_locn_code
--		x_tp_group_code
--

PROCEDURE ContainerTP (
	p_container_instance_id		IN	NUMBER,
	x_customer_number		OUT NOCOPY 	VARCHAR2,
	x_ship_to_ece_locn_code		OUT NOCOPY 	VARCHAR2,
	x_inter_ship_to_ece_locn_code	OUT NOCOPY 	VARCHAR2,
	x_bill_to_ece_locn_code		OUT NOCOPY 	VARCHAR2,
	x_tp_group_code			OUT NOCOPY 	VARCHAR2);
--<TPA_TPS>

--
-- Procedure:	DeliveryDetailTP
-- Parameters:	p_delivery_detail_id	Delivery Detail being processed
--		x_customer_number	Standard TPS function attributes
-- 		x_ship_to_ece_locn_code
--		x_inter_ship_to_ece_locn_code
--		x_bill_to_ece_locn_code
--		x_tp_group_code
--

PROCEDURE DeliveryDetailTP (
	p_delivery_detail_id		IN	NUMBER,
	x_customer_number		OUT NOCOPY 	VARCHAR2,
	x_ship_to_ece_locn_code		OUT NOCOPY 	VARCHAR2,
	x_inter_ship_to_ece_locn_code	OUT NOCOPY 	VARCHAR2,
	x_bill_to_ece_locn_code		OUT NOCOPY 	VARCHAR2,
	x_tp_group_code			OUT NOCOPY 	VARCHAR2);
--<TPA_TPS>

--
-- Procedure:	FreightCostTP
-- Parameters:	p_delivery_id		Delivery being processed
--		p_container_instance_id Container being processed
--		x_customer_number	Standard TPS function attributes
-- 		x_ship_to_ece_locn_code
--		x_inter_ship_to_ece_locn_code
--		x_bill_to_ece_locn_code
--		x_tp_group_code
--

PROCEDURE FreightCostTP (
	p_delivery_id			IN	NUMBER,
	p_container_instance_id	IN	NUMBER,
	x_customer_number		OUT NOCOPY 	VARCHAR2,
	x_ship_to_ece_locn_code		OUT NOCOPY 	VARCHAR2,
	x_inter_ship_to_ece_locn_code	OUT NOCOPY 	VARCHAR2,
	x_bill_to_ece_locn_code		OUT NOCOPY 	VARCHAR2,
	x_tp_group_code			OUT NOCOPY 	VARCHAR2);
--<TPA_TPS>


--
-- Procedure:	DefaultTP
-- Parameters:	p_entity_id		entity id being processed
--		p_entity_type		entity type being processed. right now
--					it supports only 'DELIVERY'
--		x_customer_number	Standard TPS function attributes
-- 		x_ship_to_ece_locn_code
--		x_inter_ship_to_ece_locn_code
--		x_bill_to_ece_locn_code
--		x_tp_group_code
--

PROCEDURE DefaultTP (
	p_entity_id			IN	NUMBER,
	p_entity_type			IN 	VARCHAR2,
	x_customer_number		OUT NOCOPY 	VARCHAR2,
	x_ship_to_ece_locn_code		OUT NOCOPY 	VARCHAR2,
	x_inter_ship_to_ece_locn_code	OUT NOCOPY 	VARCHAR2,
	x_bill_to_ece_locn_code		OUT NOCOPY 	VARCHAR2,
	x_tp_group_code			OUT NOCOPY 	VARCHAR2);
--<TPA_TPS>


END WSH_TPA_SELECTOR_PKG;

 

/
