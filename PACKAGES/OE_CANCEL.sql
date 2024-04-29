--------------------------------------------------------
--  DDL for Package OE_CANCEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CANCEL" AUTHID CURRENT_USER AS
/* $Header: OECANCLS.pls 115.1 99/07/16 08:10:34 porting shi $ */

procedure CHECK_ORDER_CANCELLABLE(
   V_HEADER_ID                    IN NUMBER
,  V_ORDER_CATEGORY               IN VARCHAR2
,  V_PRINT_ERR_MSG                IN NUMBER
,  V_RESULT			  OUT NUMBER
                          );

procedure UPDATE_HEADER_INFO(
        V_HEADER_ID             IN NUMBER
,       V_ORDER_CATEGORY        IN VARCHAR2
,       V_CANCEL_COMMENT        IN LONG
,       V_CANCEL_CODE           IN VARCHAR2
,       V_LAST_UPDATED_BY       IN NUMBER
,       V_LAST_UPDATE_LOGIN     IN NUMBER
,       V_SOURCE_CODE           IN VARCHAR2
,       V_PRINT_ERR_MSG         IN NUMBER
,       V_RESULT                OUT NUMBER);


procedure CHECK_SERVICE(
   V_LINE_ID                      IN NUMBER
,  V_REAL_PARENT_LINE_ID          IN NUMBER
,  V_COMPONENT_CODE		  IN VARCHAR2
,  V_ITEM_TYPE_CODE               IN VARCHAR2
,  V_SUBTREE_EXISTS		  IN NUMBER
,  V_PRINT_ERR_MSG                IN NUMBER
,  V_RESULT                       OUT NUMBER
                          );

procedure CHECK_IF_CONFIG(
   V_LOOP_LINE_ID               IN NUMBER
,  V_RESULT			OUT NUMBER
                          );


procedure CALCULATE_RMA_QTY(
   V_LINE_ID                    IN NUMBER
,  V_S29                        IN NUMBER
,  V_ORDER_QTY 			IN NUMBER
,  V_CANCELLED_QTY		IN NUMBER
,  V_RECEIVED_QTY               OUT NUMBER
,  V_ALLOWABLE_CANCEL_QTY       OUT NUMBER
,  V_PRINT_ERR_MSG              IN NUMBER
,  V_RESULT			OUT NUMBER
                          );


procedure SET_SERVICE_QTY(
   V_LINE_ID                    IN NUMBER
,  V_ALLOWABLE_CANCEL_QTY       OUT NUMBER
,  V_RESULT			OUT NUMBER
                          );



procedure NONCONFIG_QTY(
   V_LOOP_LINE_ID               IN NUMBER
,  V_LOOP_RATIO_DEN		IN NUMBER
,  V_LOOP_RATIO_NUM		IN NUMBER
,  V_S2				IN NUMBER
,  V_NONCONFIG_QTY		OUT NUMBER
,  V_RESULT			OUT NUMBER
                          );

procedure INCLUDE_QTY(
   V_LOOP_LINE_ID               IN NUMBER
,  V_TOTAL_QTY_FINAL            IN NUMBER
,  V_LOOP_RATIO_DEN		IN NUMBER
,  V_LOOP_RATIO_NUM		IN NUMBER
,  V_S2				IN NUMBER
,  V_INCLUDE_QTY                OUT NUMBER
,  V_RESULT                     OUT NUMBER
                          );


procedure CONFIG_QTY(
   V_ATO_LOOP_LINE_ID           IN NUMBER
,  V_LOOP_LINE_ID               IN NUMBER
,  V_LOOP_RATIO_DEN		IN NUMBER
,  V_LOOP_RATIO_NUM		IN NUMBER
,  V_S2				IN NUMBER
,  V_CONFIG_QTY 		OUT NUMBER
,  V_RESULT			OUT NUMBER
                          );

procedure UPDATE_LINE_INFO(
   V_LINE_ID                    IN NUMBER
,  V_REQUESTED_CANCEL_QTY       IN NUMBER
,  V_CANCEL_COMMENT             IN LONG
,  V_CANCEL_CODE                IN VARCHAR2
,  V_FULL                       IN NUMBER
,  V_OPTION_FLAG                IN NUMBER
,  V_PARENT_LINE_ID             IN NUMBER
,  V_LINE_TYPE_CODE             IN VARCHAR2
,  V_SHIPMENT_SCHEDULE_LINE_ID  IN NUMBER
,  V_SUBTREE_EXISTS             IN NUMBER
,  V_COMPONENT_CODE             IN VARCHAR2
,  V_REAL_PARENT_LINE_ID        IN NUMBER
,  V_LAST_UPDATED_BY            IN NUMBER
,  V_LAST_UPDATE_LOGIN          IN NUMBER
,  V_STATUS                     IN VARCHAR2
,  V_RESULT			OUT NUMBER
                          );

procedure UPDATE_MODEL_INFO(
   V_LINE_ID                    IN NUMBER
,  V_REQUESTED_CANCEL_QTY       IN NUMBER
,  V_CANCEL_COMMENT             IN LONG
,  V_CANCEL_CODE                IN VARCHAR2
,  V_STATUS			IN VARCHAR2
,  V_LAST_UPDATED_BY		IN NUMBER
,  V_LAST_UPDATE_LOGIN		IN NUMBER
,  V_HEADER_ID                  IN NUMBER
,  V_FULL                       IN NUMBER
,  V_RESULT			OUT NUMBER
                          );

procedure LOAD_BOM(
   V_SO_ORGANIZATION_ID         IN NUMBER
,  V_TOP_INVENTORY_ITEM_ID	IN NUMBER
,  V_TOP_COMPONENT_CODE		IN VARCHAR2
,  V_CREATION_DATE_TIME		IN VARCHAR2
,  V_LAST_UPDATED_BY            IN NUMBER
,  V_RESULT			OUT NUMBER
                          );



procedure CHECK_MODEL_RATIOS(
   V_LINE_ID			IN NUMBER
,  V_REQUESTED_CANCEL_QTY       IN NUMBER
,  V_LINE_TYPE_CODE		IN VARCHAR2
,  V_OPTION_FLAG		IN NUMBER
,  V_LINK_TO_LINE_ID		IN NUMBER
,  V_ORDER_QTY			IN NUMBER
,  V_CANCELLED_QTY		IN NUMBER
,  V_FULL			IN NUMBER
,  V_ATO_FLAG			IN NUMBER
,  V_SO_ORGANIZATION_ID         IN NUMBER
,  V_TOP_BILL_SEQUENCE_ID	IN NUMBER
,  V_PARENT_COMPONENT_SEQUENCE_ID IN NUMBER
,  V_COMPONENT_SEQUENCE_ID      IN NUMBER
,  V_TOP_INVENTORY_ITEM_ID	IN NUMBER
,  V_TOP_COMPONENT_CODE		IN VARCHAR2
,  V_CREATION_DATE_TIME		IN VARCHAR2
,  V_LAST_UPDATED_BY            IN NUMBER
,  V_RESULT			OUT NUMBER
                          );

END OE_CANCEL;

 

/
