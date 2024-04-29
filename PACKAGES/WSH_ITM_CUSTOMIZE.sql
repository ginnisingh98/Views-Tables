--------------------------------------------------------
--  DDL for Package WSH_ITM_CUSTOMIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_CUSTOMIZE" AUTHID CURRENT_USER AS
/* $Header: WSHITCCS.pls 115.1 2003/06/19 00:05:06 sperera noship $ */

        PROCEDURE ALTER_ITEM_SYNC(p_Table  IN OUT  NOCOPY WSH_ITM_QUERY_CUSTOM.g_CondnValTableType);

        PROCEDURE ALTER_PARTY_SYNC(p_Table IN OUT  NOCOPY WSH_ITM_QUERY_CUSTOM.g_CondnValTableType);

        PROCEDURE ALTER_DELIVERY_MARK(
                     p_Table IN OUT NOCOPY WSH_ITM_QUERY_CUSTOM.g_CondnValTableType,
                     x_return_status OUT NOCOPY VARCHAR2);


END;

 

/
