--------------------------------------------------------
--  DDL for Package ONT_UPGRADE_EXCEPTION_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_UPGRADE_EXCEPTION_REPORT" AUTHID CURRENT_USER As
/* $Header: OEXNUPUS.pls 120.0 2005/05/31 22:51:04 appldev noship $ */
function BASE_LINE_NUMBER(
   P_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID              IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID           IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                         IN NUMBER DEFAULT NULL
                            )
     return NUMBER;

pragma restrict_references( BASE_LINE_NUMBER, WNDS, WNPS);

function SHIPMENT_SCHEDULE_NUMBER(
   P_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID              IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID           IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                         IN NUMBER DEFAULT NULL
                            )
     return NUMBER;

pragma restrict_references( SHIPMENT_SCHEDULE_NUMBER, WNDS, WNPS);


 function OPTION_LINE_NUMBER(
   P_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID              IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID           IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                         IN NUMBER DEFAULT NULL
                          )
   return NUMBER;

pragma restrict_references( OPTION_LINE_NUMBER, WNDS, WNPS);

end ONT_UPGRADE_EXCEPTION_REPORT;

 

/
