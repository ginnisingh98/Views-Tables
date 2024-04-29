--------------------------------------------------------
--  DDL for Package GML_VALIDATEDERIVE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_VALIDATEDERIVE_GRP" AUTHID CURRENT_USER AS
/* $Header: GMLGVSQS.pls 115.1 2003/09/25 21:10:26 pbamb noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation
 |                          Redwood Shores, CA, USA
 |                            All rights reserved.
 +==========================================================================+
 | FILE NAME
 |    GMLGVSQS.pls
 |
 | PACKAGE NAME
 |    GML_ValidateDerive_GRP
 |
 | TYPE
 |   Group
 |
 | DESCRIPTION
 |   This package contains the group API used to validate or derive Secondary
 |   Attributes for the Change PO API and
 |   Receiving Open Interface.
 |
 | CONTENTS
 |   Secondary_Qty
 |   Input variables:
 |      p_item_no         : Item Number
 |      p_unit_of_measure : Transaction Unit of measure of Item
 |      p_quantity        : Transaction Quantity
 |      p_lot_id          : Lot Id. Change PO API will always pass as NULL.
 |      p_secondary_unit_of_measure: Secondary Unit Of Measure of Item
 |      p_secondary_quantity: Transaction Secondary Quantity
 |      p_validate_ind    : Change PO API will pass N,
 |                          Receiving transaction processor passes Y.
 | HISTORY
 |   Created - Preetam Bamb
 +==========================================================================+
*/

/* Procedure Declaration */

PROCEDURE Secondary_Qty
( p_api_version          	IN      	NUMBER
, p_init_msg_list        	IN      	VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validate_ind		IN		VARCHAR2
, p_item_no			IN		VARCHAR2
, p_unit_of_measure 		IN		VARCHAR2
, p_quantity			IN 		NUMBER
, p_lot_id			IN   		NUMBER   DEFAULT 0
, p_secondary_unit_of_measure 	IN OUT NOCOPY 	VARCHAR2
, p_secondary_quantity   	IN OUT NOCOPY	NUMBER
, x_return_status        	OUT NOCOPY    	VARCHAR2
, x_msg_count            	OUT NOCOPY     	NUMBER
, x_msg_data             	OUT NOCOPY     	VARCHAR2
);


END GML_ValidateDerive_GRP;

 

/
