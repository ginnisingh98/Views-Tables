--------------------------------------------------------
--  DDL for Package MRP_EXPL_STD_MANDATORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_EXPL_STD_MANDATORY" AUTHID CURRENT_USER AS
/* $Header: MRPDSODS.pls 115.10 2003/06/19 18:22:21 pshah noship $ */

        G_MRP_DEBUG   VARCHAR2(1) := FND_PROFILE.Value('MRP_DEBUG');

	TYPE number_arr IS TABLE OF number;
	TYPE char3_arr IS TABLE OF varchar2(3);
	TYPE char30_arr IS TABLE OF varchar2(30);
	TYPE date_arr IS TABLE OF date;

	TYPE GET_OE_Rec_Typ is RECORD (
		Inventory_Item_Id               number_arr := number_arr(),
		Source_Organization_Id          number_arr := number_arr(),
		Organization_Id 		number_arr := number_arr(),
		Identifier                      number_arr := number_arr(),
		Demand_Source_Header_Id		number_arr := number_arr(),
		Quantity_Ordered                number_arr := number_arr(),
		Quantity_UOM                    char3_arr := char3_arr(),
		Requested_Ship_Date             date_arr := date_arr(),
		Demand_Class                    char30_arr := char30_arr(),
		mfg_lead_time                   number_arr := number_arr(),
		ITEM_TYPE_CODE                  char30_arr := char30_arr()
				     );

  FUNCTION Explode_ATO_SM_COMPS(p_lrn IN NUMBER) RETURN INTEGER;

  PROCEDURE LOG_ERROR(  pBUFF                   IN  VARCHAR2);

END MRP_EXPL_STD_MANDATORY;

 

/
