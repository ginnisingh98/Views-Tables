--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_RPT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_RPT_UTIL" AUTHID CURRENT_USER AS
--$Header: JMFUSKRS.pls 120.2 2005/12/07 18:43:38 vchu noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFUSKRS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Specification file of the utility package for      |
--|                        the Charge Based SHIKYU reports.                   |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   27-APR-2005          shu  Created.                                      |
--|   29-NOV-2005          shu  added uom_to_code function .                  |
--+===========================================================================+

  --========================================================================
  -- PROCEDURE : get_item_number              PUBLIC
  -- PARAMETERS: p_organization_id            the organization id
  --           : p_inventory_item_id          the item id
  --           : x_item_number                the return item number
  -- COMMENT   : for getting the item flexfield number
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_item_number
  ( p_organization_id   IN NUMBER
  , p_inventory_item_id IN NUMBER
  , x_item_number       OUT NOCOPY VARCHAR2
  );

  --========================================================================
  -- FUNCTION  : get_item_number              PUBLIC
  -- PARAMETERS: p_organization_id            the organization id
  --           : p_inventory_item_id          the item id
  -- RETURN    : will return the item number
  -- COMMENT   : for getting the item flexfield number
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_item_number
  ( p_organization_id   IN NUMBER
  , p_inventory_item_id IN NUMBER
  )
  RETURN VARCHAR2;

  --========================================================================
  -- FUNCTION  : uom_to_code    PUBLIC
  -- PARAMETERS: p_unit_of_measure  the 25-character unit of measure
  -- RETURN    : will return the 3-character uom code in jmf_shikyu_% tables
  -- COMMENT   : getting the UOM code
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION uom_to_code(p_unit_of_measure IN VARCHAR2) RETURN VARCHAR2;

  --========================================================================
  -- FUNCTION  : get_item_primary_uom_code    PUBLIC
  -- PARAMETERS: p_org_id           the organization id
  --           : p_item_id          the item id
  -- RETURN    : will return the primary uom code
  -- COMMENT   : getting the  primary UOM code
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_item_primary_uom_code
  ( p_org_id  IN NUMBER
  , p_item_id IN NUMBER
  )
  RETURN VARCHAR2;

  --========================================================================
  -- FUNCTION  : get_item_primary_uom_code    PUBLIC
  -- PARAMETERS: p_org_id           the organization id
  --           : p_item_id          the item id
  --           : p_current_uom_Code current uom_code
  -- RETURN    : will return the primary uom code
  -- COMMENT   : getting the  primary UOM code
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_item_primary_uom_code
  ( p_org_id           IN NUMBER
  , p_item_id          IN NUMBER
  , p_current_uom_code IN VARCHAR2
  )
  RETURN VARCHAR2;

  --========================================================================
  -- FUNCTION  : get_item_primary_quantity    PUBLIC
  -- PARAMETERS: p_org_id           the organization id
  --           : p_item_id          the item id
  --           : p_current_uom_Code current uom_code
  --           : p_current_qty      current item quantity
  -- RETURN    : will return the quantity for the item using the primary uom
  -- COMMENT   : getting the item quantity using primary UOM
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_item_primary_quantity
  ( p_org_id           IN NUMBER
  , p_item_id          IN NUMBER
  , p_current_uom_code IN VARCHAR2
  , p_current_qty      IN NUMBER
  )
  RETURN NUMBER;

  --========================================================================
  -- FUNCTION  : po_uom_convert_p    PUBLIC
  -- PARAMETERS: p_from_unit
  --           : p_to_unit
  --           : p_item_id
  -- RETURN    :
  --             Created a function po_uom_convert_p which is pure function to be used in
  --                 the where and select clauses of a SQL
  -- COMMENT   :
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION po_uom_convert_p
  ( p_from_unit IN VARCHAR2
  , p_to_unit   IN VARCHAR2
  , p_item_id   IN NUMBER
  )
  RETURN NUMBER;

  --========================================================================
  -- FUNCTION  : get_min2            PUBLIC
  -- PARAMETERS: p_number1          the number1
  --           : p_number2          the number2
  -- RETURN    : return the less one
  -- COMMENT   : getting the less number
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_min2
  ( p_number1 IN NUMBER
  , p_number2 IN NUMBER
  )
  RETURN NUMBER;

  --========================================================================
  -- FUNCTION  : get_min3            PUBLIC
  -- PARAMETERS: p_number1          the number1
  --           : p_number2          the number2
  --           : p_number3          the number3
  -- RETURN    : return the less one
  -- COMMENT   : getting the less number
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_min3
  ( p_number1 IN NUMBER
  , p_number2 IN NUMBER
  , p_number3 IN NUMBER
  )
  RETURN NUMBER;

  --========================================================================
  -- FUNCTION  : rate_exists             PUBLIC
  -- PARAMETERS: p_from_currency    From currency
  --           : p_to_currency    To currency
  --           : p_conversion_date  Conversion date
  --           : p_conversion_type  Conversion type
  -- RETURN    : return the sonversion rate
  -- COMMENT   : reference to the APPS.GL_CURRENCY_API,
  --             Returns 'Y' if there is a conversion rate between the two currencies
  --             for a given conversion date and conversion type;
  --            'N' otherwise.

  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION rate_exists
  ( p_from_currency   IN VARCHAR2 -- FND_CURRENCIES.currency_code
  , p_to_currency     IN VARCHAR2
  , p_conversion_date IN DATE
  , p_conversion_type IN VARCHAR2 DEFAULT NULL
  )
  RETURN VARCHAR2;

  --========================================================================
  -- FUNCTION  : get_rate            PUBLIC
  -- PARAMETERS: p_from_currency    From currency
  --           : p_to_currency    To currency
  --           : p_conversion_date  Conversion date
  --           : p_conversion_type  Conversion type
  -- RETURN    : return the sonversion rate
  -- COMMENT   : reference to the APPS.GL_CURRENCY_API, to get the currency conversion rate
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_rate
  ( p_from_currency   IN VARCHAR2 -- FND_CURRENCIES.currency_code
  , p_to_currency     IN VARCHAR2
  , p_conversion_date IN DATE
  , p_conversion_type IN VARCHAR2 DEFAULT NULL
  )
  RETURN NUMBER;

  --========================================================================
  -- FUNCTION  : get_rate            PUBLIC
  -- PARAMETERS: p_ledger_id  Set of books id (in R12 set of book will be replaced by ledger)
  --           : p_from_currency    From currency
  --           : p_conversion_date  Conversion date
  --           : p_conversion_type  Conversion type
  -- RETURN    : return the sonversion rate
  -- COMMENT   : reference to the APPS.GL_CURRENCY_API,
  --             Returns the rate between the from currency and the functional
  --             currency of the set of books.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_rate
  ( p_ledger_id       IN NUMBER
  , p_from_currency   IN VARCHAR2 -- FND_CURRENCIES.currency_code
  , p_conversion_date IN DATE
  , p_conversion_type IN VARCHAR2 DEFAULT NULL
  )
  RETURN NUMBER;

  --========================================================================
  -- FUNCTION  : convert_amount             PUBLIC
  -- PARAMETERS: p_from_currency    From currency
  --           : p_to_currency    To currency
  --           : p_conversion_date  Conversion date
  --           : p_conversion_type  Conversion type
  --           : p_amount     Amount to be converted from the from currency
  --                          into the to currency
  -- RETURN    : return the sonversion rate
  -- COMMENT   : reference to the APPS.GL_CURRENCY_API,
  --             Returns the amount converted from the from currency into the
  --             to currency for a given conversion date and conversion type.
  --             The amount returned is rounded to the precision and minimum
  --             account unit of the to currency.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION convert_amount
  ( p_from_currency   IN VARCHAR2 -- FND_CURRENCIES.currency_code
  , p_to_currency     IN VARCHAR2
  , p_conversion_date IN DATE
  , p_conversion_type IN VARCHAR2 DEFAULT NULL
  , p_amount          IN NUMBER
  )
  RETURN NUMBER;

  --========================================================================
  -- FUNCTION  : convert_amount             PUBLIC
  -- PARAMETERS: p_ledger_id        Set of books id (in R12 set of book will be replaced by ledger)
  --           : p_from_currency    From currency
  --           : p_conversion_date  Conversion date
  --           : p_conversion_type  Conversion type
  --           : p_amount     Amount to be converted from the from currency
  --                          into the to currency
  -- RETURN    : return the sonversion rate
  -- COMMENT   : reference to the APPS.GL_CURRENCY_API,
  --             Returns the amount converted from the from currency into the
  --             functional currency of that set of books.  The amount returned is
  --             rounded to the precision and minimum account unit of the to currency.

  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION convert_amount
  ( p_ledger_id       IN NUMBER
  , p_from_currency   IN VARCHAR2 -- FND_CURRENCIES.currency_code
  , p_conversion_date IN DATE
  , p_conversion_type IN VARCHAR2 DEFAULT NULL
  , p_amount          IN NUMBER
  )
  RETURN NUMBER;

  -- moved to JMF_SHIKYU_UTIL by Vincent as it is generic for all SHIKYU
  --========================================================================
  -- PROCEDURE : debug_output    PUBLIC
  -- PARAMETERS: p_output_to            Identifier of where to output to
  --             p_api_name             the called api name
  --             p_message              the message that need to be output
  -- COMMENT   : the debug output, for using in readonly UT environment
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE debug_output
  (
    p_output_to IN VARCHAR2
   ,p_api_name  IN VARCHAR2
   ,p_message   IN VARCHAR2
  );

END JMF_SHIKYU_RPT_UTIL;


 

/
