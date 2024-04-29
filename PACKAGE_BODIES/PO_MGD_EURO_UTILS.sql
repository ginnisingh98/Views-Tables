--------------------------------------------------------
--  DDL for Package Body PO_MGD_EURO_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MGD_EURO_UTILS" AS
-- $Header: POXUEURB.pls 115.7 2002/03/29 11:46:31 pkm ship      $
/*+=======================================================================+
--|               Copyright (c) 1999 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    POXUEURB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Utility Package Body                                              |
--|                                                                       |
--| HISTORY                                                               |
--|     30-Dec-1999 rajkrish        Updated                               |
--|     05-Jan-2000 tsimmond        Updated                               |
--|     24-Jan-2000 tsimmond        Updated                               |
--|    11/28/2001 tsimmond  updated, added dbrv and set verify off        |
--|    03/25/2002 tsimmond updated, code removed for patch 'H' remove     |
--+======================================================================*/


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
RETURN NUMBER
IS
BEGIN

  RETURN(0);

END EURO_Conversion_api;



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
RETURN VARCHAR2
IS
BEGIN

  RETURN('Y');

END Encumbrance_check;


END PO_MGD_EURO_UTILS;

/
