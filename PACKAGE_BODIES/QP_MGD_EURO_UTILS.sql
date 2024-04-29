--------------------------------------------------------
--  DDL for Package Body QP_MGD_EURO_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MGD_EURO_UTILS" AS
/* $Header: QPXUEURB.pls 120.0 2005/06/02 00:14:55 appldev noship $ */
---+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    ONTUEURB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Utility Package Body                                              |
--|                                                                       |
--| HISTORY                                                               |
--|     01-May-2000             Created                                   |
--|     01-sep-2000             Updated                                   |
--|     03-APR-2002  tsimmond   removed code                              |
--+======================================================================

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'QP_MGD_EURO_UTILS';

--========================================================================
-- FUNCTION : EURO_Conversion_Api      PUBLIC
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
) RETURN NUMBER
IS
BEGIN

  RETURN(0);

  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END EURO_Conversion_api;


--========================================================================
-- FUNCTION : EURO_Conversion_api_canonical  PUBLIC
-- PARAMETERS: p_from_currency
---            p_to_currency
---            p_conversion_type
---            p_conversion_date
---            p_amount
--
-- COMMENT   : This procedure is used for the EURO conversion of amounts
--             stored as VARCHAR2 Attribute values
--
--========================================================================
FUNCTION EURO_Conversion_api_canonical
( p_from_currency   IN VARCHAR2
, p_to_currency     IN VARCHAR2
, p_conversion_type IN VARCHAR2
, p_conversion_date IN DATE
, p_amount          IN VARCHAR2 := NULL
) RETURN VARCHAR2
IS
BEGIN

  RETURN(' ');

  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END EURO_Conversion_api_canonical;


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

  RETURN(' ');

  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END Encumbrance_check;


--========================================================================
-- PROCEDURE : Print_Error_Messages PUBLIC
-- PARAMETERS:
--
-- COMMENT   : Returns the messages in OE Stack
--
--=======================================================================
PROCEDURE Print_Error_Messages
( p_application_short_name IN VARCHAR2
, p_msg_count              IN NUMBER
)
IS
BEGIN

  NULL;

  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END Print_Error_Messages;



--========================================================================
-- PROCEDURE : GET_Euro_Formula_ID PUBLIC

-- COMMENT   : Returns the corresponding Euro Formula ID from the
--             mirror table.
--
--=======================================================================
FUNCTION GET_Euro_Formula_ID
( p_price_formula_id IN NUMBER )
RETURN NUMBER
IS
BEGIN

  RETURN(0);

  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END GET_Euro_Formula_ID;


--========================================================================
-- PROCEDURE : get_euro_list_header_id PUBLIC

-- COMMENT   : Returns the corresponding Euro List header ID
--              from the mirror table
--
--=======================================================================
FUNCTION get_euro_list_header_id
( p_list_header_id IN NUMBER )
RETURN NUMBER
IS
BEGIN

  RETURN(0);

  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END get_euro_list_header_id;


--========================================================================
-- PROCEDURE : get_name          PUBLIC

-- COMMENT   : Returns the name basd on the source language
--
--=======================================================================
FUNCTION get_name
( p_list_header_id   IN NUMBER
, p_price_formula_id IN NUMBER
, p_language         IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN

  RETURN(' ');

  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END get_name;


--========================================================================
-- PROCEDURE : get_euro_list_line_id PUBLIC

-- COMMENT   : Returns the corresponding Euro List Line ID
--              from the mirror table
--
--=======================================================================
FUNCTION get_euro_list_line_id
(p_list_line_id IN NUMBER )
RETURN NUMBER
IS
BEGIN

  RETURN(0);

  ---code is removed, since Euro Customer Conversion program
  ---is decomissioned

END get_euro_list_line_id;


END QP_MGD_EURO_UTILS;

/
