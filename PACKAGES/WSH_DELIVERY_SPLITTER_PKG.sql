--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_SPLITTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_SPLITTER_PKG" AUTHID CURRENT_USER as
/* $Header: WSHDESPS.pls 120.1.12000000.1 2007/01/25 16:15:20 amohamme noship $ */

--OTM R12
PROCEDURE Delivery_Splitter
(p_delivery_tab		IN         WSH_ENTITY_INFO_TAB,
 p_autosplit_flag	IN         VARCHAR2             DEFAULT NULL,
 x_accepted_del_id	OUT NOCOPY WSH_OTM_ID_TAB,
 x_rejected_del_id	OUT NOCOPY WSH_OTM_ID_TAB,
 x_return_status	OUT NOCOPY VARCHAR2);

END WSH_DELIVERY_SPLITTER_PKG;

 

/
