--------------------------------------------------------
--  DDL for Package OEXVWLIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OEXVWLIN" AUTHID CURRENT_USER AS
/* $Header: OEXVWLNS.pls 115.3 99/10/19 17:29:50 porting ship  $ */

 function LINE_TOTAL (
   ORDER_ROWID  	    IN VARCHAR2
 , ORDER_LINE_ID            IN NUMBER DEFAULT NULL
 , LINE_TYPE_CODE           IN VARCHAR2
 , ITEM_TYPE_CODE           IN VARCHAR2
 , SERVICE_DURATION         IN NUMBER
 , SERVICEABLE_FLAG         IN VARCHAR2
 , ORDERED_QTY              IN NUMBER
 , CANCELLED_QTY            IN NUMBER
 , SELLING_PRICE            IN NUMBER
    	    	      )
   return NUMBER;

 function SCHEDULE_STATUS(
   ORDER_LINE_ID           IN NUMBER DEFAULT NULL
                              )
   return VARCHAR2;

 function RESERVED_QUANTITY(
   ORDER_LINE_ID           IN NUMBER DEFAULT NULL
                              )
   return NUMBER;

 function HOLD(
   ORDER_LINE_ID           IN NUMBER DEFAULT NULL
,  ORDER_HEADER_ID         IN NUMBER DEFAULT NULL
                              )
   return varchar2;

 function SHIPMENT_NUMBER(
   ORDER_LINE_ID                       IN NUMBER DEFAULT NULL
,  ORDER_PARENT_LINE_ID                IN NUMBER DEFAULT NULL
,  ORDER_SHIP_SCHEDULE_LINE_ID         IN NUMBER DEFAULT NULL
,  ORDER_LINE_NUMBER                   IN NUMBER DEFAULT NULL
                          )
   return NUMBER;

 function LINE_NUMBER(
   ORDER_LINE_ID                       IN NUMBER DEFAULT NULL
,  ORDER_SHIP_SCHEDULE_LINE_ID         IN NUMBER DEFAULT NULL
,  ORDER_PARENT_LINE_ID                IN NUMBER DEFAULT NULL
,  ORDER_LINE_NUMBER                   IN NUMBER DEFAULT NULL
                          )
   return NUMBER;


 function ITEM_CONC_SEG(
   ITEM_ID                            IN NUMBER DEFAULT NULL
,  ORG_ID                             IN NUMBER DEFAULT NULL
                          )
   return VARCHAR2;

 function ORDER_TYPE(
   ID                                 IN NUMBER DEFAULT NULL
                          )
   return VARCHAR2;


 pragma restrict_references(LINE_TOTAL, WNDS, WNPS);
 pragma restrict_references( SCHEDULE_STATUS, WNDS);  -- ,WNPS);
 pragma restrict_references( RESERVED_QUANTITY, WNDS, WNPS);
 pragma restrict_references( HOLD, WNDS, WNPS);
 pragma restrict_references( SHIPMENT_NUMBER, WNDS, WNPS);
 pragma restrict_references( LINE_NUMBER, WNDS, WNPS);
 pragma restrict_references( ITEM_CONC_SEG, WNDS, WNPS);
 pragma restrict_references( ORDER_TYPE, WNDS, WNPS);

END OEXVWLIN;

 

/
