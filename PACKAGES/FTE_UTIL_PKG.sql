--------------------------------------------------------
--  DDL for Package FTE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEUTILS.pls 120.1 2005/06/28 03:19:08 appldev ship $ */


  ----------------------------------------------------------------
  -- FUNCTION : Tokenize_String
  --
  -- Parameters :
  -- IN:
  --  1. p_string            VARCHAR2          REQUIRED
  --                         The string to be tokenized.
  --  2. p_delim             VARCHAR2          REQUIRED
  --                         The delimiter, or token.
  -- RETURN: A Stringarray containing the tokens of the string.
  ----------------------------------------------------------------
  FUNCTION TOKENIZE_STRING (p_string   IN   VARCHAR2,
			    p_delim    IN   VARCHAR2) RETURN STRINGARRAY;

  ------------------------------------------------------------
  --FUNCTION : Get_Msg
  --
  -- Parameters :
  -- IN:
  --  1. p_name        VARCHAR2       REQUIRED
  --  2. p_tokens      STRINGARRAY    NOT REQUIRED.
  --                   The tokens for the message.
  --  3. p_values      STRINGARRAY    NOT REQUIRED.
  --                   The token values.  Required if p_tokens is passed.
  --
  -- RETURN  The token-substituted message text
  -------------------------------------------------------------
  FUNCTION GET_MSG (p_name         IN    VARCHAR2,
		    p_tokens       IN    STRINGARRAY default NULL,
		    p_values       IN    STRINGARRAY default NULL) RETURN VARCHAR2;

  -----------------------------------------------------------------
  -- FUNCTION : Canonicalize_Number
  --
  -- Parameters :
  -- IN:
  --  1. p_number             NUMBER            REQUIRED
  ------------------------------------------------------------------
  FUNCTION Canonicalize_Number (p_number    IN    NUMBER)
      RETURN NUMBER;

  -----------------------------------------------------------------------------
  -- FUNCTION  GET_CARRIER_ID
  --
  -- Purpose  Get Carrier Id From Carrier Name
  --
  -- IN Parameters:
  --  	1. p_carrier_name:	carrier name
  -----------------------------------------------------------------------------
  FUNCTION GET_CARRIER_ID(p_carrier_name    IN      VARCHAR2) RETURN NUMBER;

  -------------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- FUNCTION  GET_CARRIER_NAME
  --
  -- Purpose  Get Carrier Name From Carrier ID
  --
  -- IN Parameters:
  --  	1. p_carrier_name:	carrier name
  -----------------------------------------------------------------------------
  FUNCTION GET_CARRIER_NAME(p_carrier_id IN NUMBER) RETURN VARCHAR2;

  --  FUNCTION GET_LOOKUP_CODE
  --
  --  Purpose:	Get the code from fnd_lookup_values
  --
  --  IN parameter:
  --	1. p_lookup_type:	type of the lookup
  --	2. p_value:		value to lookup
  -------------------------------------------------------------------------------
  FUNCTION GET_LOOKUP_CODE(p_lookup_type IN VARCHAR2,
                           p_value       IN VARCHAR2)  RETURN VARCHAR2;

  -------------------------------------------------------------------------------
  -- FUNCTION GET_UOM_CODE
  --
  -- Purpose: get the uom code from uom name and class
  --
  -- IN parameters:
  --	1. p_uom:	uom name
  --	2. p_uom_class: class name (only applies to weight and volumn)
  --
  -- Returns a Uom_Code searching into mtl_units_of_measure
  --                 using first uom_code then unit_of_measure
  -------------------------------------------------------------------------------
  FUNCTION GET_UOM_CODE(p_uom		IN	VARCHAR2,
			p_uom_class	IN	VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  -----------------------------------------------------------------------------
  -- FUNCTION  GET_DATA
  --
  -- Purpose  Given two String arrays representing key/value pairs, and a 'key',
  --          it returns the corresponding 'value'.
  --
  -- IN Parameters
  --    1. p_key: The 'key' whose corresponding value is required
  --    2. p_keys: An array of keys.
  --    3. p_values : An array of values.
  --
  -- RETURN: The corresponding 'value' of the input parameter 'p_key', or NULL
  --         if 'p_key' is not in the array of keys.
  -----------------------------------------------------------------------------
  FUNCTION GET_DATA(p_key     IN     VARCHAR2,
                    p_values  IN     FTE_BULKLOAD_PKG.data_values_tbl) RETURN VARCHAR2;


  -----------------------------------------------------------------------------
  -- FUNCTION Get_Vehicle_Type
  --
  -- Purpose  Get the vehicle ID Given the vehicle type or id
  --
  -- IN Parameters
  --    1. l_vehicle_type   IN   VARCHAR2 : The vehicle type to be validated.
  --
  -- RETURN:
  --    the vehicle ID, or null if it doesn't exist.
  -----------------------------------------------------------------------------
  FUNCTION Get_Vehicle_Type (p_vehicle_type  IN           VARCHAR2) RETURN VARCHAR2;

  -----------------------------------------------------------------------------
  -- PROCEDURE     GET_CATEGORY_ID
  --
  -- Purpose
  --    Return the category ID of the freight class represented in
  --    the string 'p_commodity_value'.  Caches the values of all commodities
  --    the first time it is called, for greater efficiency.
  --
  -- IN Parameters
  --    1. p_commodity_value: Three different (but equivalent) configurations of
  --       the commodity will all evaluate to the same value. E.g. '500', 'FC.500'
  --       and 'FC.500.US' are all acceptable inputs, and will return the same
  --       category ID.
  --
  -- Out Parameters
  --    1. x_catg_id: The category ID of the input.
  --    2. x_class_code: The class_code of the input. (e.g. FC)
  -----------------------------------------------------------------------------
  PROCEDURE GET_CATEGORY_ID (p_commodity_value   IN  VARCHAR2,
                             x_catg_id           OUT NOCOPY NUMBER,
                             x_class_code        OUT NOCOPY VARCHAR2,
                             x_status            OUT NOCOPY NUMBER,
                             x_error_msg         OUT NOCOPY VARCHAR2);

  -----------------------------------------------------------------------------
  -- PROCEDURE    GET_CATEGORY_ID
  --
  -- Purpose
  --  Overloaded version of the function GET_CATEGORY_ID. See above.
  -----------------------------------------------------------------------------
  PROCEDURE GET_CATEGORY_ID (p_commodity_value   IN  VARCHAR2,
                             x_catg_id           OUT NOCOPY NUMBER,
                             x_status            OUT NOCOPY NUMBER,
                             x_error_msg         OUT NOCOPY VARCHAR2);

  -----------------------------------------------------------------------------
  -- FUNCTION GET_CATG_ID
  --
  -- Purpose  Get the category ID using the commodity value
  --
  -- IN Parameters
  --    1. p_com_class:	commodity class
  --	2. p_value:	commodity value
  --
  -- RETURN:
  --    the category id for the commodity, -1 if not found
  -----------------------------------------------------------------------------
  FUNCTION GET_CATG_ID (p_com_class	IN	VARCHAR2,
			p_value		IN	VARCHAR2) RETURN NUMBER;

  -----------------------------------------------------------------------------
  -- PROCEDURE  GET_Fnd_Currency
  --
  -- Purpose  Validate a currency against Fnd_Currencies.
  --
  -- Parameters
  --   p_currency : The currency name to be validated.
  --
  -- RETURN       : The currency, if the currency is valid. NULL if the currency
  --                is not valid.
  -----------------------------------------------------------------------------
  FUNCTION GET_Fnd_Currency (p_currency      IN       VARCHAR2,
                                  x_error_msg OUT NOCOPY   VARCHAR2,
                                  x_status    OUT NOCOPY   NUMBER) RETURN VARCHAR2;

  -------------------------------------------------------------------------------------
  -- PROCEDURE  Write_LogFile
  --
  -- Purpose:  Logging a message with an attribute and value (ie. carrier_id = 100)
  --
  -- IN Parameters:
  --  	1. p_module_name	the module messages were logged at
  --	2. p_attribute		the attribute displayed
  --	3. p_value		    the value of the attribute
  -------------------------------------------------------------------------------------
  PROCEDURE WRITE_LOGFILE(p_module_name  IN   VARCHAR2,
                          p_attribute    IN   VARCHAR2,
                          p_value        IN   VARCHAR2);

  -------------------------------------------------------------------------------------
  -- PROCEDURE  Write_LogFile
  --
  -- Purpose:  Logging a message.
  --
  -- IN Parameters:
  --  	1. p_module_name	the module messages were logged at
  --	    2. p_message		the message to be logged.
  -------------------------------------------------------------------------------------
  PROCEDURE WRITE_LOGFILE(p_module_name  IN VARCHAR2,
                          p_message      IN VARCHAR2);

  -------------------------------------------------------------------------------------
  -- PROCEDURE  Write_OutFile
  --
  -- Purpose:  Writing a message in the concurrent output file(without tokens).
  --
  -- IN Parameters:
  --  	1. p_msg	    the message (i.e. sqlerrm)
  --	2. p_module_name    procedure name
  --    3. p_category       category the p_msg_name belongs to.
  --    4. p_line_number    the line number where the error occurs.
  -------------------------------------------------------------------------------------

  PROCEDURE Write_OutFile(p_msg     	IN	VARCHAR2,
			  p_module_name IN	VARCHAR2,
                          p_category    IN	VARCHAR2,
                          p_line_number IN	NUMBER DEFAULT NULL);

  -------------------------------------------------------------------------------------
  -- PROCEDURE  Write_OutFile
  --
  -- Purpose:  Writing a message with tokens in the concurrent output file.
  --
  -- IN Parameters:
  --  	1. p_msg_name	    the message name. e.g, 'FTE_CAT_ACTION_INVALID'
  --	2. p_tokens		    the tokens the message text of p_msg_name has.
  --	3. p_values		    the values for the p_tokens.
  --	4. p_module_name:	module where error occured
  --    4. p_category       category the p_msg_name belongs to.
  --    5. p_line_number    the line number where the error occurs.
  -------------------------------------------------------------------------------------
  PROCEDURE Write_OutFile(p_msg_name     IN  VARCHAR2,
                          p_tokens       IN  STRINGARRAY DEFAULT NULL,
                          p_values       IN  STRINGARRAY DEFAULT NULL,
			  p_module_name	 IN  VARCHAR2,
                          p_category     IN  VARCHAR2,
                          p_line_number  IN  NUMBER DEFAULT NULL) ;

  -----------------------------------------------------------------------------
  -- PROCEDURE  Exit_Debug
  --
  -- Purpose:  Exit the debug for current procedure/function in wsh debug file
  --
  -- IN Parameters:
  --	1. p_module_name:	module name to exit
  --
  -----------------------------------------------------------------------------
  PROCEDURE EXIT_DEBUG(p_module_name  IN  VARCHAR2);

  -----------------------------------------------------------------------------
  -- PROCEDURE  Enter_Debug
  --
  -- Purpose:  Enter the debug for current procedure/function in wsh debug file
  --
  -- IN Parameters:
  --	1. p_module_name:	module name to enter
  --
  -----------------------------------------------------------------------------
  PROCEDURE ENTER_DEBUG(p_module_name  IN  VARCHAR2);

  -------------------------------------------------------------------------------------
  -- PROCEDURE  Init_Debug
  --
  -- Purpose:  This procedure turns the debug on depending on the value p_user_debug.
  --           and starts the WSH debugger.
  --
  -- IN Parameters:
  --	1. p_user_debug: user debug flag
  -------------------------------------------------------------------------------------
  PROCEDURE INIT_DEBUG(p_user_debug NUMBER);

  ------------------------------------------------------------
  -- FUNCTION GET_CATEGORY_MESSAGE
  --
  -- Purpose: get the category message for error
  --
  -- IN parameters:
  --	1. p_category:	the category letter
  --
  -- Return category message
  ------------------------------------------------------------
  FUNCTION GET_CATEGORY_MESSAGE(p_category IN VARCHAR2) RETURN VARCHAR2;

END FTE_UTIL_PKG;

 

/
