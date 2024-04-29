--------------------------------------------------------
--  DDL for Package GMO_DISPENSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_DISPENSE_PVT" AUTHID CURRENT_USER AS
/* $Header: GMOVDSPS.pls 120.4.12000000.3 2007/04/17 07:16:20 achawla ship $ */

/* Returns the primary product's item number for the given batch */
FUNCTION GET_PRODUCT_NUMBER(P_BATCH_ID NUMBER) RETURN VARCHAR2;
/* Returns the primary product's item description for the given batch */
FUNCTION GET_PRODUCT_DESCRIPTION(P_BATCH_ID NUMBER) RETURN VARCHAR2;
/* Returns the complete dispense data, used in MaterialListVO view object*/
-- Kiosk : Start
PROCEDURE GET_DISPENSE_DATA (P_RESERVATION_ID NUMBER,
                             P_INVENTORY_ITEM_ID NUMBER,
          	             P_ORGANIZATION_ID NUMBER,
                             P_RECIPE_ID NUMBER ,
          	             P_MATERIAL_DETAILS_ID NUMBER,
                             P_RESERVATION_UOM VARCHAR2,
                             P_RESERVED_QUANTITY NUMBER,
		             P_PLAN_QUANTITY NUMBER,
		             P_PLAN_UOM VARCHAR2,
		             P_LOT_NUMBER VARCHAR2,
                             P_SHOW_IN_TOLERANCE_DATA VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.YES,
		             X_DISPENSE_UOM  OUT NOCOPY VARCHAR2,
		             X_DISPENSE_CONFIG_ID OUT NOCOPY NUMBER,
		             X_RESERVED_QUANTITY OUT NOCOPY NUMBER,
		  	     X_PENDING_DISPENSE_QUANTITY OUT NOCOPY NUMBER,
		  	     X_MAX_ALLOWED_QUANTITY OUT NOCOPY NUMBER,
		  	     X_MIN_ALLOWED_QUANTITY OUT NOCOPY NUMBER,
		  	     X_INSTRUCTION_ENTITY_DEF_KEY OUT NOCOPY VARCHAR2,
		  	     X_PLAN_UOM_CONVERTIBLE OUT NOCOPY VARCHAR2,
		  	     X_RESERVATION_UOM_CONVERTIBLE OUT NOCOPY VARCHAR2,
		  	     X_SECURITY_FLAG OUT NOCOPY VARCHAR2
                            );
 -- Kiosk : End
/* Returns T if dispense is required else F*/
FUNCTION IS_DISPENSE_REQUIRED(P_RESERVATION_ID NUMBER,
                              P_INVENTORY_ITEM_ID NUMBER,
		   	      P_ORGANIZATION_ID   NUMBER,
                              P_RECIPE_ID NUMBER ,
                              P_MATERIAL_DETAILS_ID NUMBER,
                              P_RESERVED_QUANTITY NUMBER,
                              P_RESERVATION_UOM VARCHAR2,
                              P_PLAN_QUANTITY NUMBER,
                              P_PLAN_UOM VARCHAR2,
                              P_LOT_NUMBER VARCHAR2,
                              P_SHOW_IN_TOLERANCE_DATA VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.YES
                             ) RETURN VARCHAR2;
/* Returns Net dispensed quantity for the given Reservation*/
FUNCTION GET_NET_RES_DISPENSED_QTY(P_RESERVATION_ID NUMBER,
                                   P_UOM VARCHAR2) RETURN NUMBER;
/* Returns Net dispensed quantity for the given material line */
FUNCTION GET_NET_MTL_DISPENSED_QTY(P_MATERIAL_DETAIL_ID NUMBER,
                                   P_UOM VARCHAR2) RETURN NUMBER;
/* Returns Net dispensed quantity for the given dispense id */
FUNCTION GET_NET_DISP_DISPENSED_QTY(P_DISPENSE_ID NUMBER) RETURN NUMBER;
/* Returns complete reverse dispense data. Used in DispenseActivityResultVO */
-- Kiosk : Start
PROCEDURE GET_REVERSE_DISPENSE_DATA(P_DISPENSE_ID IN NUMBER,
                                    X_MIN_ALLOWED_QTY OUT NOCOPY NUMBER,
				    X_MAX_ALLOWED_QTY OUT NOCOPY NUMBER,
				    X_CONFIG_ID OUT NOCOPY NUMBER,
				    X_INSTRUCTION_ENTITY_DEF_KEY OUT NOCOPY VARCHAR2,
    		  	     X_SECURITY_FLAG OUT NOCOPY VARCHAR2);
-- Kiosk : End
/* Returns the material dispense data for group APIs. See group API
 * comments for more details */
PROCEDURE GET_MATERIAL_DISPENSE_DATA(p_material_detail_id IN NUMBER,
                                     x_dispense_data OUT NOCOPY GME_COMMON_PVT.reservations_tab);
/* Returns the last dispense ID for the given reservation */
FUNCTION GET_LATEST_DISPENSE_ID (p_batch_id IN NUMBER) RETURN NUMBER;
/* Return the last reverse dispense ID for the given dispense */
FUNCTION GET_LATEST_REVERSE_DISPENSE_ID (p_dispense_id IN NUMBER) RETURN NUMBER;
/* Calles label print API to create label context and retrn label print request
 * ID */
FUNCTION GET_LABEL_REQUEST_ID (p_entity_id NUMBER,
                               p_context_param_names FND_TABLE_OF_VARCHAR2_255,
                               p_context_param_values FND_TABLE_OF_VARCHAR2_255,
                               p_label_string VARCHAR2,
                               p_entity_type VARCHAR2) RETURN NUMBER;
/* Return T if auto lable print is enabled */
FUNCTION IS_AUTO_PRINT_ENABLED RETURN VARCHAR2;
/* Returns the pending dispense quantity for the reservation*/
FUNCTION GET_PENDING_DISPENSE_QTY(P_RESERVATION_ID NUMBER,
                                  P_INVENTORY_ITEM_ID NUMBER,
          	                  P_ORGANIZATION_ID NUMBER,
                                  P_RECIPE_ID NUMBER ,
          	                  P_MATERIAL_DETAILS_ID NUMBER,
                                  P_RESERVATION_UOM VARCHAR2,
                                  P_RESERVED_QUANTITY NUMBER,
		                  P_PLAN_QUANTITY NUMBER,
		                  P_PLAN_UOM VARCHAR2,
		                  P_LOT_NUMBER VARCHAR2) RETURN NUMBER;
-- Start of comments
-- API name             : GET_TRANSACTION_XML
-- Type                 : Private Procedure
-- Function             : This procedure performs the follwing operations:
--                        1. It obtains the process instruction details identified by the instruction process ID
--                           in XML FORMAT.
--                        2. If P_CURRENT_XML (which is the current transaction XML) is not null then it is merged with the XML data
--                           fetched in the previous step.
--                        3. The merged XML is encapsulated in the root node <ERecord> with UTF-8 encoding.
-- Pre-reqs             : None
--
-- IN                   : P_INSTRUCTION_PROCESS_ID - The instruction process ID that identifies the process instruction details.
--                        P_CURRENT_XML            - The current transaction XML.
--                        X_OUTPUT_XML             - The final merged XML containing all the transaction data.
--
-- RETURN               : The display name of the item identified by the item ID.
--End of comments
PROCEDURE GET_TRANSACTION_XML(P_INSTRUCTION_PROCESS_ID IN  NUMBER,
                              P_CURRENT_XML            IN  CLOB,
			      X_OUTPUT_XML             OUT NOCOPY CLOB);
-- Returns Total Reverse Dispensed Quantity for a given Dispense ID.
FUNCTION GET_NET_REVERSE_DISPENSED_QTY(P_DISPENSE_ID IN NUMBER) RETURN NUMBER;
-- Returns Total Material Loss Quantity for a given Dispense ID.
FUNCTION GET_NET_MATERIAL_LOSS(P_DISPENSE_ID IN NUMBER) RETURN NUMBER;
Function isDispenseOccuredAtDispBooth(disp_booth_id number) return varchar2;
Function isDispenseOccuredAtDispArea(disp_area_id number) return varchar2;


END GMO_DISPENSE_PVT;

 

/
