--------------------------------------------------------
--  DDL for Package WSH_SC_DELIVERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SC_DELIVERY_PVT" AUTHID CURRENT_USER as
/* $Header: WSHSDELS.pls 115.4 99/07/16 08:21:13 porting ship $ */

--Package Name	WSH_SC_DELIVERY_PVT

--Purpose
--	This package performs all the server side processing
--	required for the different delivery actions like close,
--	pack, unpack, backorder.

--History
--	Version 1.0	01/29/97	Raghu Manjunath
--

-- flag to indicate if edi is installed or not
-- valid values: 'U' - undefined
--               'N' - not installed
--               'Y' - installed
edi_installed_flag      VARCHAR2(1) := 'U';

--	Function Name	: 	Close_Delivery

--	Purpose		:
--	To process Ship_all and Ship_entered actions on a Delivery

--	Parameters	:
--	1. Del_Id 	  IN NUMBER
--	   - delivery id we are working with
--	2. Action_Code  IN 	VARCHAR2
--	   -ALL for Ship All
--	   -ENTERED for Ship Entered
--	3. default_fcc
--         - Default Freight Carrier Code for AutoCreate Departure purpose
--	4. default_bol
--	   - Default Bill Of Lading for AutoCreate Departure purpose
-- 	5. default_actual_date
-- 	   - Default actual departure date for AutoCreate Departure purpose

--	Return Value 	: 	BOOLEAN
--
FUNCTION Close_Delivery(Del_Id          	IN	NUMBER,
			Action_Code		IN	VARCHAR2,
			default_fcc		IN	VARCHAR2,
			default_bol		IN	VARCHAR2,
			p_vehicle_item_id	IN	NUMBER DEFAULT NULL,
			p_vehicle_number	IN	VARCHAR2 DEFAULT NULL,
			p_seal_code		IN	VARCHAR2 DEFAULT NULL,
			p_volume_uom		IN	VARCHAR2 DEFAULT NULL,
			p_volume_total		IN	NUMBER DEFAULT NULL,
			p_weight_uom		IN	VARCHAR2 DEFAULT NULL,
			p_gross_wt		IN	NUMBER DEFAULT NULL,
			p_tare_wt		IN	NUMBER DEFAULT NULL,
			p_pack_instr		IN	VARCHAR2 DEFAULT NULL,
			default_actual_date	IN	DATE DEFAULT SYSDATE)
RETURN BOOLEAN;

-- The message will be returned to show to user in parameter x_return_msg
FUNCTION Print_Shipping_Doc_Set( x_del_id	IN NUMBER,
				 x_doc_set_id	IN NUMBER,
				 x_return_msg	OUT VARCHAR2 )
RETURN BOOLEAN;


--	Function Name	: 	Backorder_Delivery

--	Purpose		:
--	To process Backorder_all action on a Delivery

--	Parameters	:
--	1. Del_Id 	IN 	NUMBER
--	   - delivery id we are working with

--	Return Value 	: 	BOOLEAN
--
FUNCTION Backorder_Delivery (	Del_Id 		IN	NUMBER)
RETURN BOOLEAN;


--	Function Name	: 	Unpack_Delivery

--	Purpose		:
--	To process the unpacking action on a Delivery

--	Parameters	:
--	1. Del_Id 	IN 	NUMBER
--	   - delivery id we are working with
--	2. Source_Code 	IN 	VARCHAR2

--	Return Value 	: 	BOOLEAN
--
FUNCTION Unpack_Delivery (Del_Id IN NUMBER) RETURN BOOLEAN;

--	Procedure Name	: 	Update_Del_Status

--	Purpose		:
--	Updates the status code on a delivery to the required value

--	Parameters	:
--	1. Del_Id IN NUMBER
--	   - delivery id we are working with
--	2. Del_Status_Code
--	   - status to which we want the delivery to be updated
PROCEDURE Update_Del_Status (	Del_Id 		IN 	NUMBER,
				Del_Status_Code IN 	VARCHAR2);

--	Procedure Name	: 	Insert_Ph_Row

--	Purpose		:
--	Inserts a New Picking Header record in so_picking_headers

--	Parameters	:
--	1. Ph_Id 	IN 	NUMBER
--	   - Picking Header record from which the new picking header
--	     record is to be created
--	2. New_Ph_Id 	IN 	NUMBER
--	   - Picking Header Id for the New picking header record
PROCEDURE Insert_Ph_Row (	Ph_Id 		IN	NUMBER,
			 	New_Ph_Id 	IN	NUMBER);

--	Procedure Name	: 	Insert_Pl_Row

--	Purpose		:
--	Inserts a new picking line record in so_picking_lines_all

--	Parameters	:
--	1. Pl_Id	IN 	NUMBER
--	   - picking line record from which the new picking line
--	     record is created
--	2. New_Pl_Id 	IN 	NUMBER
--	   - picking line id for the new picking line record
--	3. New_Ph_Id 	IN 	NUMBER
--	   - Picking Header Id for the New picking header record
PROCEDURE Insert_Pl_Row (	Pl_Id 		IN	NUMBER,
			 	New_Pl_Id 	IN	NUMBER,
			 	New_Ph_Id 	IN	NUMBER);

--	Procedure Name	: 	Split_Picking_Headers

--	Purpose		:
--	Splits Picking Headers and associated Picking Lines if
--	necessary while closing a delivery.

--	Parameters	:
--	1. Del_Id IN NUMBER
--	   - delivery id we are working with
PROCEDURE Split_Picking_Headers (Del_Id 	IN	NUMBER);


--      Function Name   :       Auto_Create_Departure

--      Purpose         :
--      To Create a departure and assign it to a delivery if the
--      delivery is not already associated with a departure

--      Parameters      :
--      All the parameters refer to the values on the delivery
--      for which we are creating the departure
--      1. Org_Id               IN      Number
--      2. Freight_Carrier      IN      Varchar2
--      3. Weight_UOM           IN      Varchar2
--      4. Volume_UOM           IN      Varchar2
--      5. Weight_of_Delivery   IN      Number
--      6. Volume_of_Delivery   IN      Number

--      Return Value    :       Number - the departure id of the created
--                              departure
--
FUNCTION Auto_Create_Departure (
	Org_Id			IN	Number,
	Freight_Carrier		IN	Varchar2,
	Weight_UOM		IN	Varchar2,
	Volume_UOM		IN	Varchar2,
	Weight_of_Delivery	IN	Number,
	p_tare_wt		IN	Number,
	Volume_of_Delivery	IN	Number,
	p_vehicle_item_id	IN	Number,
	p_vehicle_number	IN	Varchar2,
	p_seal_code		IN	Varchar2,
	p_pack_instr		IN	Varchar2,
	bol			IN	VARCHAR2,
	actual_date		IN	DATE DEFAULT SYSDATE,
	dep_name		IN 	VARCHAR2 DEFAULT NULL)
RETURN NUMBER;

--      Function Name   :       Delete_Container_Contents

--      Purpose         :

--      Parameters      :	X_Contaier_Id IN  Number

--      Return Value    :       Boolean

FUNCTION Delete_Container_Contents( x_container_id      IN NUMBER)
RETURN BOOLEAN;

END WSH_SC_DELIVERY_PVT;

 

/
