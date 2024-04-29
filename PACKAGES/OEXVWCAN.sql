--------------------------------------------------------
--  DDL for Package OEXVWCAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OEXVWCAN" AUTHID CURRENT_USER AS
/* $Header: OEXVWCNS.pls 115.2 99/07/16 08:17:11 porting shi $ */

 function SHIPMENT_SCHEDULE_NUMBER(
   P_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID              IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID           IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                         IN NUMBER DEFAULT NULL
                          )
   return NUMBER;

 function BASE_LINE_NUMBER(
   P_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID              IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID           IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                         IN NUMBER DEFAULT NULL
                          )
   return NUMBER;


 function OPTION_LINE_NUMBER(
   P_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID              IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID           IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                         IN NUMBER DEFAULT NULL
                          )
   return NUMBER;


 function SUBTREE_EXISTS(
   V_LINE_ID				IN NUMBER
,  V_REAL_PARENT_LINE_ID		IN NUMBER
                          )
   return VARCHAR2;

 function IN_CONFIGURATION(
   V_PARENT_LINE_ID			IN NUMBER
,  V_ITEM_TYPE_CODE			IN VARCHAR2
,  V_SERVICE_PARENT_LINE_ID		IN NUMBER
                          )
   return VARCHAR2;

 function OPEN_PICKING_SLIPS(
   V_LINE_ID                            IN NUMBER
,  V_REAL_PARENT_LINE_ID                IN NUMBER
,  V_COMPONENT_CODE			IN VARCHAR2
                          )
   return VARCHAR2;

 function PRICE_ADJUST_EXISTS(
   V_HEADER_ID                          IN NUMBER
,  V_LINE_ID  			        IN NUMBER
                          )
   return VARCHAR2;


 function TOP_BILL_SEQUENCE_ID(
   V_LINE_ID	                       IN NUMBER DEFAULT NULL
,  V_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
                          )
   return NUMBER;

 function SECURITY_OBJECT(
   V_PARENT_LINE_ID			IN NUMBER
,  V_SHIPMENT_SCHEDULE_LINE_ID          IN NUMBER
,  V_SERVICE_PARENT_LINE_ID             IN NUMBER
,  V_LINE_TYPE_CODE		        IN VARCHAR2
                          )
   return VARCHAR2;


 pragma restrict_references( SHIPMENT_SCHEDULE_NUMBER, WNDS, WNPS);
 pragma restrict_references( BASE_LINE_NUMBER, WNDS, WNPS);
 pragma restrict_references( OPTION_LINE_NUMBER, WNDS, WNPS);
 pragma restrict_references( SUBTREE_EXISTS, WNDS, WNPS);
 pragma restrict_references( IN_CONFIGURATION, WNDS, WNPS);
 pragma restrict_references( OPEN_PICKING_SLIPS, WNDS, WNPS);
 pragma restrict_references( PRICE_ADJUST_EXISTS, WNDS, WNPS);
 pragma restrict_references( TOP_BILL_SEQUENCE_ID, WNDS, WNPS);
 pragma restrict_references( SECURITY_OBJECT, WNDS, WNPS);


END OEXVWCAN;

 

/
