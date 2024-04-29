--------------------------------------------------------
--  DDL for Package CSM_MTL_ITEM_LOC_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_MTL_ITEM_LOC_EVENT_PKG" AUTHID CURRENT_USER  AS
/* $Header: csmemils.pls 120.1 2005/07/25 00:11:43 trajasek noship $*/

PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2);

END CSM_MTL_ITEM_LOC_EVENT_PKG;

 

/
