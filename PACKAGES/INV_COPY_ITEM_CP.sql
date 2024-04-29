--------------------------------------------------------
--  DDL for Package INV_COPY_ITEM_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_COPY_ITEM_CP" AUTHID CURRENT_USER AS
/*  $Header: INVITCPS.pls 120.0 2005/07/18 09:59:15 shpandey noship $ */
--+=======================================================================+
--|               Copyright (c) 2001 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVITCPS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|                                                                       |
--|                                                                       |
--| HISTORY                                                               |
--|     17-Jan-2005 shpandey   Created                                    |
--+=======================================================================+

-- Return values for RETCODE parameter (standard for concurrent programs):

PROCEDURE  Copy_Org_Items
(x_return_message     OUT   NOCOPY VARCHAR2
,x_return_status      OUT   NOCOPY VARCHAR2
,p_source_org_id       IN    NUMBER
,p_target_org_id       IN    NUMBER
,p_validate            IN    VARCHAR2
);
END INV_COPY_ITEM_CP;

 

/
