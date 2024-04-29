--------------------------------------------------------
--  DDL for Package PO_MGD_EURO_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_MGD_EURO_UTILS" AUTHID CURRENT_USER AS
-- $Header: POXUEURS.pls 115.5 2002/02/18 17:48:07 pkm ship    $
/*+=======================================================================+
--|               Copyright (c) 1999 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    POXUEURS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Utility Package                                                   |
--|                                                                       |
--| HISTORY                                                               |
--|     30-Dec-1999 rajkrish        Updated                               |
--|     05-Jan-2000 tsimmond        Updated                               |
--|    11/28/2001 tsimmond  updated, added dbrv and set verify off        |
--+======================================================================*/



G_PO_NUMBER   NUMBER;
--========================================================================
-- FUNCTION :  EURO_Conversion_Api      PUBLIC
-- PARAMETERS: p_from_currency
---            p_to_currency
---            p_conversion_type
---            p_conversion_date
---            p_amount
--
-- COMMENT   : This procedure is used for the EURO conversion of amounts
--             The GL_API is invoked for the purpose
--
--========================================================================
FUNCTION EURO_Conversion_api
( p_from_currency     IN VARCHAR2
, p_to_currency       IN VARCHAR2
, p_conversion_type   IN VARCHAR2
, p_conversion_date   IN DATE
, p_amount            IN NUMBER := NULL
)
RETURN NUMBER ;



--========================================================================
-- FUNCTION :  Encumbrance_Check      PUBLIC
-- PARAMETERS: p_org_id
--
-- COMMENTS:   This function is checking if Encumbrance Flag is ON.
--             It returns Y, if Encumbrance is ON and N if it's OFF
--
--========================================================================
FUNCTION Encumbrance_check
( p_org_id IN NUMBER
)
RETURN VARCHAR2;


END PO_MGD_EURO_UTILS;

 

/
