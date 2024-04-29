--------------------------------------------------------
--  DDL for Package ITA_BIZ_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITA_BIZ_EVENTS_PVT" AUTHID CURRENT_USER as
/*$Header: itapbevs.pls 120.0 2005/05/31 16:38:13 appldev noship $*/


procedure GENERATE_ITEM_KEY(
  X_NEXT_VALUE in out nocopy VARCHAR2);


function RAISE_CHANGE_EVENT(
  P_APPLICATION_ID VARCHAR2,
  P_TABLE_NAME VARCHAR2,
  P_ROW_ID VARCHAR2)
return VARCHAR2;


end ITA_BIZ_EVENTS_PVT;

 

/
