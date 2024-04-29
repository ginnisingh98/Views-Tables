--------------------------------------------------------
--  DDL for Package MST_SNAPSHOT_TASK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_SNAPSHOT_TASK_UTIL" AUTHID CURRENT_USER AS
/* $Header: MSTSNTUS.pls 115.5 2004/06/25 17:23:40 qlu noship $ */



V_DEBUG				BOOLEAN;
NULL_VALUE NUMBER := -23453;
NULL_CHAR_VALUE VARCHAR2(10)   := '-23453';

Procedure LOG_MESSAGE( pBUFF  IN  VARCHAR2);

Procedure Get_Phase_Status_Code(p_rqst_id IN NUMBER, p_phase_code OUT NOCOPY VARCHAR2,
                                                     p_status_code OUT NOCOPY VARCHAR2);


Function getCalendar(lLocationId in number,lCalendarType in VARCHAR2 )
 return Varchar2;

Function getDeliveryId (ldeliveryId in number,
                      lNullNumber in number) return number;
Function getCMVehicleType (lMoveId in number)  return NUMBER;

Function GET_DEL_OSP_FLAG(ldelivery_id in NUMBER) return varchar2;

END MST_SNAPSHOT_TASK_UTIL;

 

/
