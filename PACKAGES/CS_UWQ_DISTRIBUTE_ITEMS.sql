--------------------------------------------------------
--  DDL for Package CS_UWQ_DISTRIBUTE_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_UWQ_DISTRIBUTE_ITEMS" AUTHID CURRENT_USER AS
/* $Header: csvsrwds.pls 120.2 2006/08/22 00:01:16 nveerara noship $ */

/*****************************************
This procdeure is going to be called by UWQ's distribute_function()
to update owner of Service Request in CS when the WI is assigned
to an individual owner
*******************************************/

  PROCEDURE Distribute_ServiceRequests
		(P_RESOURCE_ID		IN NUMBER,
		P_LANGUAGE		IN VARCHAR2,
		P_SOURCE_LANG		IN VARCHAR2,
		P_NUM_OF_ITEMS		IN NUMBER,
		P_DIST_BUS_RULES	IN SYSTEM.DIST_BUS_RULES_NST,
		P_WS_INPUT_DATA		IN OUT NOCOPY SYSTEM.WR_ITEM_DATA_NST,
		X_MSG_COUNT		OUT NOCOPY NUMBER,
		X_MSG_DATA		OUT NOCOPY VARCHAR2,
		X_RETURN_STATUS		OUT NOCOPY VARCHAR2);

  PROCEDURE SYNC_SR_TASKS(
                P_TASKS_DATA    IN              SYSTEM.WR_TASKS_DATA_NST,
                P_DEF_WR_DATA   IN              SYSTEM.DEF_WR_DATA_NST,
                X_MSG_COUNT     OUT NOCOPY      NUMBER,
                X_MSG_DATA      OUT NOCOPY      VARCHAR2,
                X_RETURN_STATUS OUT NOCOPY      VARCHAR2);


  PROCEDURE SYNC_SR_TASKS(
                P_PROCESSING_SET_ID IN              NUMBER DEFAULT NULL,
                X_MSG_COUNT         OUT NOCOPY      NUMBER,
                X_MSG_DATA          OUT NOCOPY      VARCHAR2,
                X_RETURN_STATUS     OUT NOCOPY      VARCHAR2);


  PROCEDURE DISTRIBUTE_SRTASKS
		(P_RESOURCE_ID		IN NUMBER,
		P_LANGUAGE		IN VARCHAR2,
		P_SOURCE_LANG		IN VARCHAR2,
		P_NUM_OF_ITEMS		IN NUMBER,
		P_DIST_BUS_RULES	IN SYSTEM.DIST_BUS_RULES_NST,
		P_WS_INPUT_DATA		IN OUT NOCOPY SYSTEM.WR_ITEM_DATA_NST,
		X_MSG_COUNT		OUT NOCOPY NUMBER,
		X_MSG_DATA		OUT NOCOPY VARCHAR2,
		X_RETURN_STATUS		OUT NOCOPY VARCHAR2);


END CS_UWQ_DISTRIBUTE_ITEMS;

 

/
