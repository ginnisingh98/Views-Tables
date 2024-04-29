--------------------------------------------------------
--  DDL for Package Body WSH_TPA_SELECTOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TPA_SELECTOR_PKG" AS
/* $Header: WSHTPSLB.pls 120.0 2005/05/26 18:02:23 appldev noship $ */


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
	x_tp_group_code			OUT NOCOPY 	VARCHAR2) IS

CURSOR Get_First_Line IS
SELECT delivery_detail_id
FROM wsh_delivery_assignments_v
WHERE delivery_id = p_delivery_id
AND rownum < 2;

l_del_detail_id 	NUMBER;

BEGIN

  IF p_delivery_id IS NULL THEN
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;
  END IF;

  OPEN Get_First_Line;

  FETCH Get_First_Line INTO l_del_detail_id;

  IF Get_First_Line%NOTFOUND OR l_del_detail_id IS NULL THEN
	CLOSE Get_First_Line;
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;
  END IF;

  IF Get_First_Line%ISOPEN THEN
	CLOSE Get_First_Line;
  END IF;

  WSH_TPA_SELECTOR_PKG.DeliveryDetailTP (
  			l_del_detail_id,
			x_customer_number,
			x_ship_to_ece_locn_code,
			x_inter_ship_to_ece_locn_code,
			x_bill_to_ece_locn_code,
			x_tp_group_code);

  return;

EXCEPTION

  WHEN OTHERS THEN
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;

END DeliveryTP;


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
	x_tp_group_code			OUT NOCOPY 	VARCHAR2) IS


CURSOR Get_First_Line IS
SELECT delivery_detail_id
FROM wsh_delivery_assignments_v
WHERE parent_delivery_detail_id = p_container_instance_id
AND rownum < 2;

l_del_detail_id 	NUMBER;

BEGIN

  IF p_container_instance_id IS NULL THEN
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;
  END IF;

  OPEN Get_First_Line;

  FETCH Get_First_Line INTO l_del_detail_id;

  IF Get_First_Line%NOTFOUND OR l_del_detail_id IS NULL THEN
	CLOSE Get_First_Line;
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;
  END IF;

  IF Get_First_Line%ISOPEN THEN
	CLOSE Get_First_Line;
  END IF;

  WSH_TPA_SELECTOR_PKG.DeliveryDetailTP (
  			p_container_instance_id,
			x_customer_number,
			x_ship_to_ece_locn_code,
			x_inter_ship_to_ece_locn_code,
			x_bill_to_ece_locn_code,
			x_tp_group_code);

  return;

EXCEPTION

  WHEN OTHERS THEN
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;

END ContainerTP;


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
	x_tp_group_code			OUT NOCOPY 	VARCHAR2) IS


CURSOR Get_Line_Info (v_line_id NUMBER) IS
SELECT ship_to_org_id, invoice_to_org_id, intmed_ship_to_org_id
FROM OE_ORDER_LINES_ALL
WHERE line_id = v_line_id;

CURSOR Get_Detail_Info IS
SELECT source_line_id, customer_id
FROM WSH_DELIVERY_DETAILS
WHERE delivery_detail_id = p_delivery_detail_id
AND source_code = 'OE';

CURSOR Get_Ece_Loc_Code (v_site_use_id NUMBER) IS-- TCA View Removal starts
SELECT Acct_site.Ece_tp_location_code,
	   Acct_site.Tp_header_id /* TP_HEADER_ID */
FROM hz_cust_acct_sites_all acct_site ,
	hz_cust_site_uses_all site_uses
WHERE site_uses.site_use_id = v_site_use_id AND
	  acct_site.cust_acct_site_id/*address-id*/ = site_uses.cust_acct_site_id; -- TCA View Removal ends



CURSOR Get_Tp_Code (v_tp_hdr_id NUMBER) IS -- TCA View Removal starts
SELECT etg.tp_group_code
FROM ece_tp_group etg,
     ece_tp_headers eth,
     hz_cust_acct_sites_all acct_site
WHERE acct_site.tp_header_id = v_tp_hdr_id
  AND acct_site.tp_header_id = eth.tp_header_id
  AND eth.tp_group_id = etg.tp_group_id;		-- -- TCA View Removal ends



CURSOR Get_Cust_Number (v_cust_id NUMBER) IS   -- TCA View Removal starts
SELECT account_number /* customer number */
FROM  hz_cust_accounts
WHERE cust_account_id /*customer_id*/ = v_cust_id; -- TCA View Removal ends


l_src_line_id 			NUMBER;
l_cust_id			NUMBER;

l_ship_to_org_id		NUMBER;
l_inter_ship_to_org_id		NUMBER;
l_bill_to_org_id		NUMBER;

l_ship_to_ece_locn_code		VARCHAR2(40);
l_bill_to_ece_locn_code		VARCHAR2(40);
l_inter_to_ece_locn_code	VARCHAR2(40);

l_ece_tp_loc_code		VARCHAR2(40);

l_tp_header_id			NUMBER;
l_tp_group_code			VARCHAR2(35);

l_cust_number			VARCHAR2(30);

BEGIN

 IF p_delivery_detail_id IS NULL THEN
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;
 END IF;


 OPEN Get_Detail_Info;

 FETCH Get_Detail_Info INTO
  l_src_line_id,
  l_cust_id;

 IF Get_Detail_Info%NOTFOUND OR l_src_line_id IS NULL THEN
	CLOSE Get_Detail_Info;
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;
 END IF;

 IF Get_Detail_Info%ISOPEN THEN
	CLOSE Get_Detail_Info;
 END IF;

 IF l_cust_id IS NOT NULL THEN

 	OPEN Get_Cust_Number (l_cust_id);

	FETCH Get_Cust_Number INTO l_cust_number;

	IF Get_Cust_Number%NOTFOUND THEN
		CLOSE Get_Cust_Number;
		l_cust_number := NULL;
	END IF;

	IF Get_Cust_Number%ISOPEN THEN
		CLOSE Get_Cust_Number;
	END IF;
 ELSE
	l_cust_number := NULL;
 END IF;

 x_customer_number := l_cust_number;

 OPEN Get_Line_Info (l_src_line_id);

 FETCH Get_Line_Info INTO
	l_ship_to_org_id,
	l_bill_to_org_id,
	l_inter_ship_to_org_id;

 IF Get_Line_Info%NOTFOUND THEN
	CLOSE Get_Line_Info;
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;
 END IF;

 IF Get_Line_Info%ISOPEN THEN
	CLOSE Get_Line_Info;
 END IF;

 IF l_ship_to_org_id IS NOT NULL THEN

	OPEN Get_Ece_Loc_Code (l_ship_to_org_id);

	FETCH Get_Ece_Loc_Code INTO
		l_ece_tp_loc_code,
		l_tp_header_id;

	IF Get_Ece_Loc_Code%NOTFOUND THEN
		CLOSE Get_Ece_Loc_Code;
		x_ship_to_ece_locn_code := NULL;
		x_tp_group_code := NULL;
	ELSE

		IF l_tp_header_id IS NOT NULL THEN

			OPEN Get_Tp_Code (l_tp_header_id);

			FETCH Get_Tp_Code INTO l_tp_group_code;

			IF Get_Tp_Code%NOTFOUND THEN
				CLOSE Get_Tp_Code;
				x_tp_group_code := NULL;
			END IF;

			IF Get_Tp_Code%ISOPEN THEN
				CLOSE Get_Tp_Code;
			END IF;
		ELSE
			x_tp_group_code := NULL;
		END IF;

	END IF;

 ELSE
	x_ship_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
 END IF;

 IF l_bill_to_org_id IS NOT NULL THEN

	OPEN Get_Ece_Loc_Code (l_bill_to_org_id);

	FETCH Get_Ece_Loc_Code INTO
		l_ece_tp_loc_code,
		l_tp_header_id;

	IF Get_Ece_Loc_Code%NOTFOUND THEN
		CLOSE Get_Ece_Loc_Code;
		x_bill_to_ece_locn_code := NULL;
	ELSE

		x_bill_to_ece_locn_code := l_ece_tp_loc_code;

	END IF;

 ELSE
	x_bill_to_ece_locn_code := NULL;
 END IF;

 IF l_inter_ship_to_org_id IS NOT NULL THEN

	OPEN Get_Ece_Loc_Code (l_inter_ship_to_org_id);

	FETCH Get_Ece_Loc_Code INTO
		l_ece_tp_loc_code,
		l_tp_header_id;

	IF Get_Ece_Loc_Code%NOTFOUND THEN
		CLOSE Get_Ece_Loc_Code;
		x_inter_ship_to_ece_locn_code := NULL;
	ELSE

		x_inter_ship_to_ece_locn_code := l_ece_tp_loc_code;

	END IF;

 ELSE
	x_inter_ship_to_ece_locn_code := NULL;
 END IF;

EXCEPTION

  WHEN OTHERS THEN
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;

END DeliveryDetailTP;


--
-- Procedure:	FreightCostTP
-- Parameters:	p_delivery_id		Delivery being processed
--		p_container_instance_id Conatiner being processed
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
	x_tp_group_code			OUT NOCOPY 	VARCHAR2) IS

BEGIN

  IF p_delivery_id IS NULL AND p_container_instance_id IS NULL THEN
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;
  END IF;

  IF p_delivery_id IS NOT NULL THEN

	WSH_TPA_SELECTOR_PKG.DeliveryTP (
  			p_delivery_id,
			x_customer_number,
			x_ship_to_ece_locn_code,
			x_inter_ship_to_ece_locn_code,
			x_bill_to_ece_locn_code,
			x_tp_group_code);
	return;

  ELSIF p_container_instance_id IS NOT NULL THEN

  	WSH_TPA_SELECTOR_PKG.ContainerTP (
  			p_container_instance_id,
			x_customer_number,
			x_ship_to_ece_locn_code,
			x_inter_ship_to_ece_locn_code,
			x_bill_to_ece_locn_code,
			x_tp_group_code);

	return;

  ELSE
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;

END FreightCostTP;



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
	x_tp_group_code			OUT NOCOPY 	VARCHAR2) IS

BEGIN

  IF p_entity_type = 'DELIVERY' THEN
  	IF p_entity_id IS NOT NULL THEN

		WSH_TPA_SELECTOR_PKG.DeliveryTP (
  				p_entity_id,
				x_customer_number,
				x_ship_to_ece_locn_code,
				x_inter_ship_to_ece_locn_code,
				x_bill_to_ece_locn_code,
				x_tp_group_code);
		return;

	ELSE
		x_customer_number := NULL;
		x_ship_to_ece_locn_code := NULL;
		x_inter_ship_to_ece_locn_code := NULL;
		x_bill_to_ece_locn_code := NULL;
		x_tp_group_code := NULL;
		return;
	END IF;
  ELSE
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
	x_customer_number := NULL;
	x_ship_to_ece_locn_code := NULL;
	x_inter_ship_to_ece_locn_code := NULL;
	x_bill_to_ece_locn_code := NULL;
	x_tp_group_code := NULL;
	return;

END DefaultTP;


END WSH_TPA_SELECTOR_PKG;

/
