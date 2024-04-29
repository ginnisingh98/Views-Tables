--------------------------------------------------------
--  DDL for Package CSM_CSI_ITEM_ATTR_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_CSI_ITEM_ATTR_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeiats.pls 120.1 2005/07/25 00:08:30 trajasek noship $*/
PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2);

END CSM_CSI_ITEM_ATTR_EVENT_PKG; -- Package spec of CSM_CSI_ITEM_ATTR_EVENT_PKG

 

/
