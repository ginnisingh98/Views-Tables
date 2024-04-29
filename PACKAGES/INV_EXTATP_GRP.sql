--------------------------------------------------------
--  DDL for Package INV_EXTATP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_EXTATP_GRP" AUTHID CURRENT_USER AS
/* $Header: INVGEAPS.pls 120.2 2005/09/20 14:11:30 ichoudhu ship $ */

--
-- Package
--   INV_EXTATP_GRP
-- Purpose
--   External ATP
-- History
--   09/04/96	mfisher		created
--   07/26/97   nsriniva        added support for APS integration
--

-- Constants for Error Codes
G_ALL_SUCCESS       CONSTANT INTEGER := 0;
G_RETURN_ERROR      CONSTANT INTEGER := 2;
G_INVALID_ACTION    CONSTANT INTEGER := 1;
G_RETURN_WARNING    CONSTANT INTEGER := -1;
G_ATP_REQ_QTY_FAIL  CONSTANT INTEGER := 52;
G_ATP_NO_GROUP_DATE CONSTANT INTEGER := 50;

G_ATP_INQUIRY	  CONSTANT VARCHAR2(20) := 'ATP INQUIRY';
G_DEMAND	  CONSTANT VARCHAR2(20) := 'DEMAND';
G_UNDEMAND	  CONSTANT VARCHAR2(20) := 'UNDEMAND';

TYPE ATP_Group_Rec_Typ is RECORD (
Row_Id				RowId,
Schedule_Group_Id		Number,
ATP_Group_Id			Number,
Ext_ATP_Group_Id		Number,
Action_Code			Number,
Action				Varchar2(20),
Processing_Order		Number,
Item_Id				Number,
Organization_Id			Number,
Organization_Code 		Varchar2(10),
Sales_Order_Number		Varchar2(40),
Sales_Order_Type		Varchar2(40),
OE_Source_Code			Varchar2(40),
Order_Identifier		Varchar2(120),
Order_Type_Id			Number,
Creation_Date			Date,
Customer_Name			Varchar2(50),
Shipment_Schedule_Line_Id	Number,
Line_Number			Number,
Line_Item_Quantity		Number,
User_Delivery			Varchar2(30),
Item_Segment1			Varchar2(40),
Item_Segment2			Varchar2(40),
Item_Segment3			Varchar2(40),
Item_Segment4			Varchar2(40),
Item_Segment5			Varchar2(40),
Item_Segment6			Varchar2(40),
Item_Segment7			Varchar2(40),
Item_Segment8			Varchar2(40),
Item_Segment9			Varchar2(40),
Item_Segment10			Varchar2(40),
Item_Segment11			Varchar2(40),
Item_Segment12			Varchar2(40),
Item_Segment13			Varchar2(40),
Item_Segment14			Varchar2(40),
Item_Segment15			Varchar2(40),
Item_Segment16			Varchar2(40),
Item_Segment17			Varchar2(40),
Item_Segment18			Varchar2(40),
Item_Segment19			Varchar2(40),
Item_Segment20			Varchar2(40),
BOM_Level			Number,
Demand_Type			Number,
BOM_Item_Type			Number,
ATO_Flag			Varchar2(1),
Selling_Price			Number,
Requirement_Date		Date,
Request_Date_ATP_Quantity	Number,
Earliest_ATP_Date		Date,
Earliest_ATP_Date_Quantity	Number,
Request_ATP_Date		Date,
Request_ATP_Date_Quantity	Number,
Group_Available_Date		Date,
Error_Code			Number,
Error_Explanation		Varchar2(240) );

TYPE Bom_Rec_Typ is RECORD (
Row_Id				RowId,
Bill_Sequence_Id		Number,
Item_Id				Number,
Component_Item_Id		Number,
Comp_Item_Segment1		Varchar2(40),
Comp_Item_Segment2		Varchar2(40),
Comp_Item_Segment3		Varchar2(40),
Comp_Item_Segment4		Varchar2(40),
Comp_Item_Segment5		Varchar2(40),
Comp_Item_Segment6		Varchar2(40),
Comp_Item_Segment7		Varchar2(40),
Comp_Item_Segment8		Varchar2(40),
Comp_Item_Segment9		Varchar2(40),
Comp_Item_Segment10		Varchar2(40),
Comp_Item_Segment11		Varchar2(40),
Comp_Item_Segment12		Varchar2(40),
Comp_Item_Segment13		Varchar2(40),
Comp_Item_Segment14		Varchar2(40),
Comp_Item_Segment15		Varchar2(40),
Comp_Item_Segment16		Varchar2(40),
Comp_Item_Segment17		Varchar2(40),
Comp_Item_Segment18		Varchar2(40),
Comp_Item_Segment19		Varchar2(40),
Comp_Item_Segment20		Varchar2(40),
Organization_Id			Number,
Organization_Code 		Varchar2(10),
Component_Quantity		Number);

TYPE Routing_Rec_Typ is RECORD (
Row_Id				RowId,
Routing_Id			Number,
Item_Id				Number,
Component_Item_Id		Number,
Organization_Id			Number,
Organization_Code 		Varchar2(10),
Operation_Code			Varchar2(10),
Operation_Type			Varchar2(10),
Department_Id			Number,
Department_Code			Varchar2(10),
Resource_Id			Number,
Resource_Code			Varchar2(10),
Rate				Number,
Resource_Uom			Varchar2(10));

TYPE ATP_Group_Tab_Typ is TABLE of ATP_Group_Rec_Typ
INDEX BY BINARY_INTEGER ;

TYPE Bom_Tab_Typ is TABLE of Bom_Rec_Typ
INDEX BY BINARY_INTEGER ;

TYPE Routing_Tab_Typ is TABLE of Routing_Rec_Typ
INDEX BY BINARY_INTEGER ;

FUNCTION Call_ATP(	group_id      number,
			insert_flag   number,
			partial_flag  number,
			mrp_status    number,
			schedule_flag number,
			session_id    number,
			err_message   IN OUT NOCOPY varchar2,
			err_translate IN OUT NOCOPY number)
RETURN NUMBER;

END INV_EXTATP_GRP;

 

/
