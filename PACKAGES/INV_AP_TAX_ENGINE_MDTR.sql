--------------------------------------------------------
--  DDL for Package INV_AP_TAX_ENGINE_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_AP_TAX_ENGINE_MDTR" AUTHID CURRENT_USER AS
-- $Header: INVMTAXS.pls 120.1 2005/06/28 12:04:27 pseshadr noship $ --
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVMTAXS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Consignment Dependency wrapper API                                |
--| HISTORY                                                               |
--|     12/01/2002 pseshadr       Created                                 |
--|     12/01/2002 dherring       Created                                 |
--+========================================================================

--===================
-- PROCEDURES AND FUNCTIONS
--===================


--========================================================================
-- PROCEDURE  : Calculate_Tax         PUBLIC
-- COMMENT   :  Returns status from eBtax after tax calculation
--========================================================================

PROCEDURE Calculate_Tax
(  x_return_status OUT NOCOPY VARCHAR2
,  x_msg_count     OUT NOCOPY VARCHAR2
,  x_msg_data      OUT NOCOPY VARCHAR2
);


END INV_AP_TAX_ENGINE_MDTR;

 

/
