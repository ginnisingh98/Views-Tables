--------------------------------------------------------
--  DDL for Package QP_MGD_EURO_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MGD_EURO_UTILS" AUTHID CURRENT_USER AS
/* $Header: QPXUEURS.pls 120.0 2005/06/02 00:59:50 appldev noship $ */
---+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    ONTUEURS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Utility Package                                                   |
--|                                                                       |
--| HISTORY                                                               |
--|     03-May-2000        Created                                        |
--|     22-Aug-2000        Updated                                        |
--|     03-APR-2002  tsimmond   removed Convert_pl_Miss_to_null,          |
--|                             Convert_formula_Miss_to_null,             |
--|                             Convert_mod_Miss_to_null.                 |
--|                             EBS program is decomissioned              |
--+======================================================================


G_ORDER_NUMBER   NUMBER;
G_DB_UPDATE_FLAG VARCHAR2(1);

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
) RETURN NUMBER ;


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
) RETURN VARCHAR2 ;


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
);



--========================================================================
-- PROCEDURE : GET_Euro_Formula_ID PUBLIC

-- COMMENT   : Returns the corresponding Euro Formula ID from the
--             mirror table.
--
--=======================================================================
FUNCTION GET_Euro_Formula_ID
( p_price_formula_id IN NUMBER )
RETURN NUMBER
;


--========================================================================
-- PROCEDURE : get_euro_list_header_id PUBLIC

-- COMMENT   : Returns the corresponding Euro List header ID
--              from the mirror table
--
--=======================================================================
FUNCTION get_euro_list_header_id
( p_list_header_id IN NUMBER )
RETURN NUMBER
;


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
;


--========================================================================
-- PROCEDURE : get_euro_list_line_id PUBLIC

-- COMMENT   : Returns the corresponding Euro List Line ID
--              from the mirror table
--
--=======================================================================
FUNCTION get_euro_list_line_id
(p_list_line_id IN NUMBER )
RETURN NUMBER
;

END QP_MGD_EURO_UTILS;

 

/
