--------------------------------------------------------
--  DDL for Package CAC_AVLBLTY_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_AVLBLTY_EVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: caccabes.pls 120.1 2005/07/02 02:17:35 appldev noship $ */


/*******************************************************************************
** Private APIs
*******************************************************************************/


PROCEDURE RAISE_CREATE_SCHEDULE
/*******************************************************************************
**
** RAISE_CREATE_SCHEDULE
**
**   Raise business event
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
);


PROCEDURE RAISE_UPDATE_SCHEDULE
/*******************************************************************************
**
** RAISE_UPDATE_SCHEDULE
**
**   Raise business event
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
);


PROCEDURE RAISE_DELETE_SCHEDULE
/*******************************************************************************
**
** RAISE_DELETE_SCHEDULE
**
**   Raise business event
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
);


PROCEDURE RAISE_ADD_RESOURCE
/*******************************************************************************
**
** RAISE_ADD_RESOURCE
**
**   Raise business event
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
, p_Object_Type          IN     VARCHAR2
, p_Object_Id            IN     NUMBER
, p_Object_Start_Date    IN     DATE
, p_Object_End_Date      IN     DATE
);


PROCEDURE RAISE_UPDATE_RESOURCE
/*******************************************************************************
**
** RAISE_UPDATE_RESOURCE
**
**   Raise business event
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
, p_Object_Type          IN     VARCHAR2
, p_Object_Id            IN     NUMBER
, p_Object_Start_Date    IN     DATE
, p_Object_End_Date      IN     DATE
);


PROCEDURE RAISE_REMOVE_RESOURCE
/*******************************************************************************
**
** RAISE_REMOVE_RESOURCE
**
**   Raise business event
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
, p_Object_Type          IN     VARCHAR2
, p_Object_Id            IN     NUMBER
, p_Object_Start_Date    IN     DATE
, p_Object_End_Date      IN     DATE
);


END CAC_AVLBLTY_EVENTS_PVT;

 

/
