--------------------------------------------------------
--  DDL for Package OE_CANSRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CANSRV" AUTHID CURRENT_USER AS
/* $Header: OECANSVS.pls 115.2 99/07/16 08:10:40 porting shi $ */

procedure CHECK_LINE_INTERFACED(
   V_LINE_ID                      IN NUMBER
,  V_RESULT			  OUT NUMBER
                          );


procedure CHECK_ORDER_INT_RECS_EXIST(
   V_LINE_ID                      IN NUMBER
,  V_CONCURRENT_PROCESS_ID	  IN OUT NUMBER
,  V_RESULT			  OUT NUMBER
                          );


procedure CHECK_ORDER_INT_NOT_IN_PROG(
   V_LINE_ID                      IN NUMBER
,  V_PRINT_ERR_MSG		  IN NUMBER
,  V_CONCURRENT_PROCESS_ID	  IN OUT NUMBER
,  V_RESULT			  OUT NUMBER
                          );


procedure MAKE_DELETE_INT_RECS(
   V_LINE_ID                      IN NUMBER
,  V_CUSTOMER_PRODUCT_ID	  IN NUMBER
,  V_CP_SERVICE_ID		  IN NUMBER
,  V_LAST_UPDATED_BY		  IN NUMBER
,  V_SERVICE_MASS_TXN_TEMP_ID	  IN NUMBER
,  V_RESULT			  OUT NUMBER
                          );


procedure CANCEL_SERVICE_CHILDREN(
   V_LINE_ID			  IN NUMBER
,  V_HEADER_ID                    IN NUMBER
,  V_CANCEL_CODE                  IN VARCHAR2
,  V_CANCEL_COMMENT               IN LONG
,  V_FULL                         IN NUMBER
,  V_STATUS			  IN VARCHAR2
,  V_REQUESTED_CANCEL_QTY         IN NUMBER
,  V_CUSTOMER_PRODUCT_ID          IN NUMBER
,  V_CP_SERVICE_ID                IN NUMBER
,  V_LAST_UPDATED_BY              IN NUMBER
,  V_LAST_UPDATE_LOGIN            IN NUMBER
,  V_SERVICE_MASS_TXN_TEMP_ID     IN NUMBER
,  V_PRINT_ERR_MSG                IN NUMBER
,  V_CONCURRENT_PROCESS_ID        IN OUT NUMBER
,  V_RESULT                       OUT NUMBER
			 );


procedure CANCEL_LINE(
   V_LINE_ID			  IN NUMBER
,  V_REQUESTED_CANCEL_QTY	  IN NUMBER
,  V_ORDERED_QUANTITY		  IN NUMBER
,  V_RECEIVED_QUANTITY		  IN NUMBER
,  V_S29			  IN NUMBER
,  V_SOURCE_CODE		  IN VARCHAR2
,  V_LINE_TYPE_CODE		  IN VARCHAR2
,  V_HEADER_ID			  IN NUMBER
,  V_CANCEL_CODE		  IN VARCHAR2
,  V_CANCEL_COMMENT               IN LONG
,  V_LAST_UPDATED_BY		  IN NUMBER
,  V_LAST_UPDATE_LOGIN            IN NUMBER
,  V_FULL		          IN NUMBER
,  V_STATUS                       IN VARCHAR2
,  V_RESULT                       OUT NUMBER
			 );


procedure CANCEL_SERVICE(
   V_LINE_ID			  IN NUMBER
,  V_REQUESTED_CANCEL_QTY	  IN NUMBER
,  V_ORDERED_QUANTITY             IN NUMBER
,  V_RECEIVED_QUANTITY            IN NUMBER
,  V_S29                          IN NUMBER
,  V_HEADER_ID                    IN NUMBER
,  V_CANCEL_CODE                  IN VARCHAR2
,  V_CANCEL_COMMENT               IN LONG
,  V_LAST_UPDATE_LOGIN            IN NUMBER
,  V_FULL                         IN NUMBER
,  V_STATUS                       IN VARCHAR2
,  V_CUSTOMER_PRODUCT_ID          IN NUMBER
,  V_CP_SERVICE_ID                IN NUMBER
,  V_LAST_UPDATED_BY              IN NUMBER
,  V_SERVICE_MASS_TXN_TEMP_ID     IN NUMBER
,  V_SOURCE_CODE		  IN VARCHAR2
,  V_LINE_TYPE_CODE		  IN VARCHAR2
,  V_PRINT_ERR_MSG                IN NUMBER
,  V_CONCURRENT_PROCESS_ID        IN OUT NUMBER
,  V_RESULT                       OUT NUMBER
			 );


procedure HISTORY(
   V_LINE_ID                      IN NUMBER
,  V_ITEM		          OUT VARCHAR2
,  V_BASE_LINE_NUMBER	          OUT NUMBER
,  V_SHIPMENT_SCHEDULE_NUMBER     OUT NUMBER
,  V_OPTION_LINE_NUMBER		  OUT NUMBER
                          );


procedure HOLDS(
   V_HEADER_ID                    IN NUMBER
,  V_LOGIN_ID		          IN NUMBER
,  V_USER_ID     	          IN NUMBER
                          );


procedure ALL_HOLDS(
   V_HEADER_ID                    IN NUMBER
,  V_LOGIN_ID		          IN NUMBER
,  V_USER_ID     	          IN NUMBER
                          );


END OE_CANSRV;

 

/
