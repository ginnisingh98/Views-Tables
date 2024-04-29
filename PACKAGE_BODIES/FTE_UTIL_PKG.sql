--------------------------------------------------------
--  DDL for Package Body FTE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_UTIL_PKG" AS
/* $Header: FTEUTILB.pls 120.8 2005/08/02 00:12:27 pkaliyam ship $ */

  --
  -- Package FTE_UTIL_PKG
  --
  --

  g_debug_set            BOOLEAN := TRUE;
  g_debug_on             BOOLEAN := TRUE;
  g_user_debug        BOOLEAN;
  G_PKG_NAME    CONSTANT        VARCHAR2(50) := 'FTE_UTIL_PKG';

  TYPE VARCHAR2_TAB IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

  concat_segments    varchar2_tab;
  catg_ids           varchar2_tab;
  segment_code       varchar2_tab;
  segment_val        varchar2_tab;
  segment_cc         varchar2_tab;
  l_delimiter        varchar2(3);

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
  FUNCTION Tokenize_String (p_string     IN    VARCHAR2,
                            p_delim      IN    VARCHAR2) RETURN STRINGARRAY IS

  l_tokens                   STRINGARRAY := STRINGARRAY();
  l_token                    VARCHAR2(4000);
  l_start_index              NUMBER := 1;
  l_end_index                NUMBER := 1;
  l_count                    NUMBER := 0;
  l_delim_count              NUMBER := 1;

  BEGIN
    l_delim_count := length(p_delim);
    WHILE l_end_index <> 0  LOOP
      l_end_index := INSTR(p_string, p_delim, l_start_index);
      l_count := l_count + 1;
      IF (l_end_index = 0) THEN
        --no more tokens after this one
        l_token := SUBSTR(p_string, l_start_index);
      ELSE
        l_token := SUBSTR(p_string, l_start_index,
                          l_end_index - l_start_index);
      END IF;
      l_start_index := l_end_index + l_delim_count;
      l_tokens.extend;
      l_tokens(l_count) := l_token;
    END LOOP;
    RETURN l_tokens;
  END TOKENIZE_STRING;


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
  FUNCTION Get_Msg (p_name         IN    VARCHAR2,
                    p_tokens       IN    STRINGARRAY DEFAULT NULL,
                    p_values       IN    STRINGARRAY DEFAULT NULL)
   RETURN VARCHAR2 IS

  l_msg       varchar2(5000);

  BEGIN

    IF (p_name IS NULL) THEN
      Fnd_File.Put_Line(Fnd_File.Log, 'Fte_Util_Pkg => Programmer Error: Message Name NULL');
      RETURN NULL;
    END IF;

    IF (p_tokens.EXISTS(1) AND p_values.EXISTS(1)
        AND p_tokens.COUNT = p_values.COUNT ) THEN
      Fnd_Message.Set_Name('APPLICATION' => 'FTE',
                           'NAME' => p_name);

      FOR i IN 1..p_tokens.COUNT LOOP
        Fnd_Message.Set_Token(token => p_tokens(i), value => p_values(i));
      END LOOP;

      l_msg := Fnd_Message.Get;
    ELSE
      l_msg := Fnd_Message.Get_String('APPIN'  => 'FTE',
	                              'NAMEIN' => p_name);
    END IF;

    return l_msg;

  EXCEPTION
    WHEN OTHERS THEN
      Fnd_File.Put_Line(Fnd_File.Log, 'UNEXP. ERROR IN FTE_UTIL_PKG.Get_Msg: ' || sqlerrm);
      RAISE;
  END Get_Msg;

  -----------------------------------------------------------------
  -- FUNCTION : Canonicalize_Number
  --
  -- Parameters :
  -- IN:
  --  1. p_number             NUMBER            REQUIRED
  ------------------------------------------------------------------
  FUNCTION Canonicalize_Number (p_number    IN    NUMBER)
   RETURN NUMBER IS
  BEGIN
    return
      fnd_number.canonical_to_number(fnd_number.number_to_canonical(p_number));
  END;

  -----------------------------------------------------------------------------
  -- FUNCTION  GET_CARRIER_ID
  --
  -- Purpose  Get Carrier Id From Carrier Name
  --
  -- IN Parameters:
  --  	1. p_carrier_name:	carrier name
  -----------------------------------------------------------------------------
  FUNCTION GET_CARRIER_ID(p_carrier_name    IN      VARCHAR2) RETURN NUMBER IS

  l_carrier_id    	NUMBER := NULL;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.GET_CARRIER_ID';

  BEGIN
    SELECT hz.PARTY_ID  INTO l_carrier_id
      FROM   HZ_PARTIES hz, WSH_CARRIERS ca
      WHERE  hz.party_name = p_carrier_name
        AND    hz.party_id   = ca.carrier_id;

    RETURN l_carrier_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN -1;
    WHEN OTHERS THEN
      WRITE_OUTFILE(p_module_name => l_module_name,
                    p_msg   	  => sqlerrm,
                    p_category    => 'O');
      RETURN -2;
  END GET_CARRIER_ID;

-----------------------------------------------------------------------------
  -- FUNCTION  GET_CARRIER_NAME
  --
  -- Purpose  Get Carrier Name From Carrier ID
  --
  -- IN Parameters:
  --  	1. p_carrier_name:	carrier name
  -----------------------------------------------------------------------------
  FUNCTION GET_CARRIER_NAME(p_carrier_id IN NUMBER) RETURN VARCHAR2 IS

  l_carrier_name HZ_PARTIES.PARTY_NAME%TYPE;
  l_module_name CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_CARRIER_NAME';

  BEGIN

    SELECT hz.PARTY_name
    INTO l_carrier_name
    FROM HZ_PARTIES hz
    WHERE hz.party_id = p_carrier_id;

    RETURN l_carrier_name;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      RETURN -1;

    WHEN OTHERS THEN
      WRITE_OUTFILE(p_module_name => l_module_name,
                    p_msg   	  => sqlerrm,
                    p_category    => 'O');
      RETURN -2;
  END GET_CARRIER_NAME;

  -------------------------------------------------------------------------------
  --  FUNCTION GET_LOOKUP_CODE
  --
  --  Purpose:	Get the code from fnd_lookup_values
  --
  --  IN parameter:
  --	1. p_lookup_type:	type of the lookup
  --	2. p_value:		value to lookup
  -------------------------------------------------------------------------------
  FUNCTION GET_LOOKUP_CODE(p_lookup_type IN VARCHAR2,
                           p_value       IN VARCHAR2)  RETURN VARCHAR2 IS

  l_code     	VARCHAR2(100);
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.GET_LOOKUP_CODE';

  BEGIN
    l_code := null;

    -- First check with LOOKUP_CODE
    BEGIN
      SELECT lookup_code  INTO l_code
        FROM   fnd_lookup_values_vl
        WHERE  lookup_type = p_lookup_type
          AND    lookup_code = p_value;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          -- If the given value can't be found as LOOKUP_CODE
          -- try with 'like MEANING%'
          SELECT lookup_code  INTO l_code
            FROM   fnd_lookup_values_vl
            WHERE  lookup_type = p_lookup_type
              AND    meaning like p_value;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        END;
    END;

    RETURN l_code;

  EXCEPTION
    WHEN OTHERS THEN
      WRITE_OUTFILE(p_module_name => l_module_name,
                    p_msg   	  => sqlerrm,
                    p_category    => 'O');

      RETURN NULL;
  END GET_LOOKUP_CODE;

  -------------------------------------------------------------------------------
  -- FUNCTION GET_SHIPPING_UOM_CLASS
  --
  -- Purpose: get the shipping uom class from the class name
  --
  -- IN parameters:
  --	1. p_uom_class:	uom class name
  --
  -- Returns a uom class name corresponding to the input class, NULL if exception raised
  -------------------------------------------------------------------------------
  FUNCTION GET_SHIPPING_UOM_CLASS(p_uom_class	IN 	VARCHAR2) RETURN VARCHAR2 IS
  l_uom_class 	VARCHAR2(20) := '';
  BEGIN
    BEGIN
      SELECT p_uom_class--||'_uom_class'
	INTO l_uom_class
        FROM wsh_shipping_parameters
        WHERE rownum < 2;
    EXCEPTION
      WHEN OTHERS THEN
	RETURN NULL;
    END;
    RETURN l_uom_class;
  END GET_SHIPPING_UOM_CLASS;

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
			p_uom_class	IN	VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS

  l_code 		VARCHAR2(100) := '';
  l_shipping_uom_class 	VARCHAR2(100) := '';
  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.GET_UOM_CODE';

  BEGIN
    IF (p_uom_class IS NULL OR p_uom_class NOT IN ('Weight', 'Volume')) THEN
      BEGIN
        -- First check with UOM_CODE
        SELECT uom_code  INTO l_code
          FROM   mtl_units_of_measure
          WHERE  uom_code  = p_uom;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN
            -- If the given value can't be found as UOM_CODE
            -- try with UNIT_OF_MEASURE
            SELECT uom_code INTO l_code
              FROM   mtl_units_of_measure
              WHERE  unit_of_measure = p_uom;
          EXCEPTION
            WHEN OTHERS THEN
	      RETURN NULL;
          END;
        WHEN OTHERS THEN
	  RETURN NULL;
      END;
    ELSE
      l_shipping_uom_class := GET_SHIPPING_UOM_CLASS(p_uom_class);
      IF (l_shipping_uom_class IS NOT NULL) THEN
        BEGIN
          -- First check with UOM_CODE
          SELECT  uom_code  INTO l_code
            FROM  mtl_units_of_measure
            WHERE uom_code  = p_uom
	      AND uom_class = l_shipping_uom_class;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              -- If the given value can't be found as UOM_CODE
              -- try with UNIT_OF_MEASURE
              SELECT  uom_code INTO l_code
                FROM  mtl_units_of_measure
                WHERE unit_of_measure = p_uom
		  AND uom_class = l_shipping_uom_class;
            EXCEPTION
              WHEN OTHERS THEN
		RETURN NULL;
            END;
          WHEN OTHERS THEN
	    RETURN NULL;
        END;
      ELSE
	RETURN NULL;
      END IF;
    END IF;

    RETURN l_code;
  END GET_UOM_CODE;

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
                    p_values  IN     FTE_BULKLOAD_PKG.data_values_tbl) RETURN VARCHAR2 IS

  l_data         VARCHAR2(50) := NULL;
  l_module_name  CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.GET_DATA';

  BEGIN
    IF (p_values.EXISTS(p_key)) THEN
      RETURN p_values(p_key);
    ELSE
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN SUBSCRIPT_BEYOND_COUNT THEN
      Enter_Debug(l_module_name);
      WRITE_LOGFILE(l_module_name, 'WARNING: Key or Value not found for Tag ' || p_key);
      Exit_Debug(l_module_name);
      RETURN NULL;
    WHEN NO_DATA_FOUND THEN
      ENTER_Debug(l_module_name);
      WRITE_LOGFILE(l_module_name, 'WARNING: No data found for key ' || p_key);
      Exit_Debug(l_module_name);
      RETURN NULL;
    WHEN OTHERS THEN
      WRITE_OUTFILE(p_module_name => l_module_name,
	            p_msg   	  => sqlerrm,
	            p_category    => 'O');

      RETURN NULL;
  END GET_DATA;

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
  FUNCTION Get_Vehicle_Type (p_vehicle_type  IN           VARCHAR2) RETURN VARCHAR2 IS

  l_veh_id           NUMBER := NULL;
  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.GET_VEHICLE_TYPE';

  BEGIN

    BEGIN
      SELECT veh.vehicle_type_id
      INTO  l_veh_id
      FROM  mtl_system_items_kfv mtl, fte_vehicle_types veh
      WHERE mtl.concatenated_segments = p_vehicle_type
      AND   mtl.inventory_item_id = veh.inventory_item_id
      AND   mtl.vehicle_item_flag = 'Y'
      AND   rownum = 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT veh.vehicle_type_id
          INTO  l_veh_id
          FROM  mtl_system_items_kfv mtl, fte_vehicle_types veh
          WHERE to_char(veh.vehicle_type_id) = p_vehicle_type
          AND   mtl.inventory_item_id = veh.inventory_item_id
          AND   mtl.vehicle_item_flag = 'Y'
          AND   rownum = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
	    RETURN null;
        END;
    END;

    return l_veh_id;

  EXCEPTION
    WHEN OTHERS THEN
      ENTER_Debug(l_module_name);
      WRITE_OUTFILE(p_module_name => l_module_name,
                    p_msg   	  => sqlerrm,
                    p_category    => 'O');
      Exit_Debug(l_module_name);
      RETURN NULL;
  END Get_Vehicle_Type;


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
			p_value		IN	VARCHAR2) RETURN NUMBER IS
  l_delimiter	VARCHAR2(5);
  l_id		NUMBER;
  l_class	VARCHAR2(100);
  token_tab              STRINGARRAY;
  l_value 	VARCHAR2(30);
  BEGIN
    BEGIN
      SELECT concatenated_segment_delimiter
        INTO l_delimiter
        FROM fnd_id_flex_structures
       WHERE id_flex_code = 'MCAT'
         AND id_flex_structure_code='WSH_COMMODITY_CODE'
         AND application_id = 401;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
--            addError(FIELD_COMMODITY,"FTE_CAT_COMM_DELIMITER_ERROR", DataLoader.CATEGORY_B);
            return -1;
    END;

    -- Validate against Commodify Class in the lane

    IF (INSTR(p_value, l_delimiter) <= 0) THEN
      l_class := p_value;
    ELSE
      l_class := SUBSTR(p_value, 1, (INSTR(p_value, l_delimiter)-1));
    END IF;

    IF (l_class <> p_com_class) THEN
      RETURN -3;
    END IF;

    token_tab := TOKENIZE_STRING(p_value, l_delimiter);

    IF (token_tab.COUNT = 1) THEN
      l_value := token_tab(1);
    ELSIF (token_tab.COUNT > 1) THEN
      l_value := token_tab(1) || l_delimiter || token_tab(2);
    END IF;

    BEGIN
      SELECT category_id
        INTO l_id
        FROM mtl_categories_kfv c, mtl_category_sets s
       WHERE s.structure_id = c.structure_id
         AND s.category_set_name = 'WSH_COMMODITY_CODE'
         AND c.concatenated_segments like l_value||'%'
	 AND rownum = 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	RETURN -1;
    END;
    RETURN l_id;
  END GET_CATG_ID;

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
                             x_error_msg         OUT NOCOPY VARCHAR2) IS

  i                      NUMBER;
  token_tab              STRINGARRAY;
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.GET_CATEGORY_ID';

  CURSOR get_freight_classes IS
  SELECT c.category_id, c.concatenated_segments, c.segment1, c.segment2, c.segment3
  FROM   mtl_categories_kfv c, mtl_category_sets s
  WHERE  s.structure_id       = c.structure_id
  AND    s.category_set_name  = 'WSH_COMMODITY_CODE';

  CURSOR get_delimiter IS
  SELECT concatenated_segment_delimiter
  FROM   fnd_id_flex_structures
  WHERE  id_flex_code           = 'MCAT'
  AND    id_flex_structure_code ='WSH_COMMODITY_CODE'
  AND    application_id         = 401;

  BEGIN
    x_catg_id := NULL;
    x_status := -1;

    IF (concat_segments IS NULL OR concat_segments.COUNT = 0) THEN

      Enter_Debug(l_module_name);

      OPEN get_delimiter;
      FETCH get_delimiter INTO l_delimiter;

      IF get_delimiter%NOTFOUND OR length(l_delimiter) = 0 THEN
        x_catg_id := NULL;
        CLOSE get_delimiter;
	x_error_msg := GET_MSG(p_name => 'FTE_DELIMITER_NOT_FOUND');
	WRITE_OUTFILE(p_module_name => l_module_name,
	              p_msg         => x_error_msg,
	              p_category    => 'B');

	Exit_Debug(l_module_name);
        return;
      END IF;
      CLOSE get_delimiter;

      OPEN GET_FREIGHT_CLASSES;
      FETCH GET_FREIGHT_CLASSES BULK COLLECT INTO catg_ids, concat_segments, segment_code,
                                                    segment_val, segment_cc;

      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
        WRITE_LOGFILE(l_module_name, 'Fetched ' || catg_ids.COUNT || ' commodities');
      END IF;

      close get_freight_classes;
      Exit_Debug(l_module_name);
    END IF;

    token_tab := TOKENIZE_STRING(p_commodity_value, l_delimiter);

    IF (token_tab.count = 1) THEN  --ASSUME USER PASSED IN ONLY THE VALUE.
      FOR i in 1..concat_segments.COUNT LOOP
        IF (segment_val(i) = p_commodity_value) THEN
          x_catg_id := catg_ids(i);
          x_class_code := segment_code(i);
          return;
        END IF;
      END LOOP;
    ELSIF (token_tab.count > 1) THEN
      FOR i in 1..concat_segments.COUNT LOOP
        IF (segment_code(i) = token_tab(1) AND segment_val(i) = token_tab(2)) THEN
          x_catg_id := catg_ids(i);
          x_class_code := segment_code(i);
          return;
        END IF;
      END LOOP;
    END IF;

    Enter_Debug(l_module_name);
    x_status := 2;

    x_error_msg := GET_MSG(p_name => 'FTE_CAT_COMMODITY_UNKNOWN',
		  	   p_tokens	=> STRINGARRAY('COMMODITY'),
		  	   p_values	=> STRINGARRAY(p_commodity_value));

    WRITE_OUTFILE(p_module_name => l_module_name,
                  p_msg   	=> x_error_msg,
                  p_category    => 'D');

    Exit_Debug(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      IF (get_freight_classes%ISOPEN) THEN
	CLOSE get_freight_classes;
      END IF;
      IF (get_delimiter%ISOPEN) THEN
	CLOSE get_delimiter;
      END IF;
      WRITE_OUTFILE(p_module_name => l_module_name,
                    p_msg   	  => sqlerrm,
             	    p_category    => 'O');
      RETURN;
  END GET_CATEGORY_ID;

  -----------------------------------------------------------------------------
  -- PROCEDURE    GET_CATEGORY_ID
  --
  -- Purpose
  --  Overloaded version of the function GET_CATEGORY_ID. See above.
  -----------------------------------------------------------------------------

  PROCEDURE GET_CATEGORY_ID (p_commodity_value   IN  VARCHAR2,
                             x_catg_id           OUT NOCOPY NUMBER,
                             x_status            OUT NOCOPY NUMBER,
                             x_error_msg         OUT NOCOPY VARCHAR2) IS

  x_class_code    VARCHAR2(40);
  l_module_name   CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.GET_CATEGORY_ID';
  BEGIN
    GET_CATEGORY_ID(p_commodity_value => p_commodity_value,
                    x_catg_id         => x_catg_id,
                    x_class_code      => x_class_code,
                    x_status          => x_status,
                    x_error_msg       => x_error_msg);

  EXCEPTION
    WHEN OTHERS THEN
      WRITE_OUTFILE(p_module_name => l_module_name,
            	    p_msg   	  => sqlerrm,
            	    p_category    => 'O');
      RETURN;
  END GET_CATEGORY_ID;

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
                                  x_status    OUT NOCOPY   NUMBER) RETURN VARCHAR2 IS

    l_currency     VARCHAR2(45);

    l_module_name  CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_FND_CURRENCY';

   BEGIN
     FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);
     x_status := -1;

     BEGIN
      --try the currency code.
      SELECT currency_code INTO l_currency
      FROM   fnd_currencies
      WHERE  currency_code = p_currency
	AND  enabled_flag = 'Y'
    	AND  currency_flag = 'Y'
    	AND  nvl(start_date_active, sysdate) <= sysdate
	AND  nvl(end_date_active, sysdate) >= sysdate
        AND  rownum = 1;

     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          --try the currency name.
          SELECT currency_code INTO l_currency
          FROM   fnd_currencies_vl
          WHERE  name = p_currency
	    AND  enabled_flag = 'Y'
	    AND  currency_flag = 'Y'
	    AND  nvl(start_date_active, sysdate) <= sysdate
	    AND  nvl(end_date_active, sysdate) >= sysdate
            AND  rownum = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           x_error_msg := Get_Msg(P_Name => 'FTE_INVALID_CARRIER_CURRENCY');
	   WRITE_OUTFILE(p_module_name => l_module_name,
	            	 p_msg	       => x_error_msg,
  	            	 p_category    => 'D');

           x_status := 2;
        END;
     END;
     FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
     RETURN l_currency;

  EXCEPTION
   WHEN OTHERS THEN
     WRITE_OUTFILE(p_module_name => l_module_name,
                   p_msg   	 => sqlerrm,
                   p_category    => 'O');
     FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
     RETURN NULL;
  END GET_Fnd_Currency;

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
  FUNCTION Get_Category_message(p_category IN VARCHAR2)
  RETURN VARCHAR2 IS
  l_category_msg     VARCHAR2(1000);
  l_module_name       CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.Get_Category_message';
  BEGIN

    IF (UPPER(p_category) = 'A') THEN
      l_category_msg := GET_MSG('FTE_LOADER_CATEGORY_A');
    ELSIF (UPPER(p_category) = 'B') THEN
      l_category_msg := GET_MSG('FTE_LOADER_CATEGORY_B');
    ELSIF (UPPER(p_category) = 'C') THEN
      l_category_msg := GET_MSG('FTE_LOADER_CATEGORY_C');
    ELSIF (UPPER(p_category) = 'D') THEN
      l_category_msg := GET_MSG('FTE_LOADER_CATEGORY_D');
    ELSIF (UPPER(p_category) = 'E') THEN
      l_category_msg := GET_MSG('FTE_LOADER_CATEGORY_E');
    ELSIF (UPPER(p_category) = 'F') THEN
      l_category_msg := GET_MSG('FTE_LOADER_CATEGORY_F');
    ELSIF (UPPER(p_category) = 'O') THEN
      l_category_msg := GET_MSG('FTE_LOADER_CATEGORY_O');
    ELSE
      Write_LogFile(l_module_name, 'Programmer Error: Invalid Message Category - ' || p_category);
      RETURN NULL;
    END IF;

    RETURN l_category_msg;

  END Get_Category_message;

  -------------------------------------------------------------------------------------
  -- PROCEDURE  Init_Debug
  --
  -- Purpose:  This procedure turns the debug on depending on the value p_user_debug.
  --           and starts the WSH debugger.
  --
  -- IN Parameters:
  --	1. p_user_debug: user debug flag
  -------------------------------------------------------------------------------------

  PROCEDURE Init_Debug(p_user_debug NUMBER) IS
  BEGIN

    IF (p_user_debug = 1) THEN
      FTE_BULKLOAD_PKG.g_debug_on := TRUE;
      WSH_UTIL_CORE.Set_Log_Level(p_log_level => 1);
      -- NEED TO SET QP debug.
    END IF;

  END Init_Debug;

  -----------------------------------------------------------------------------
  -- PROCEDURE  Enter_Debug
  --
  -- Purpose:  Enter the debug for current procedure/function in wsh debug file
  --
  -- IN Parameters:
  --	1. p_module_name:	module name to enter
  --
  -----------------------------------------------------------------------------

  PROCEDURE Enter_Debug(p_module_name  IN  VARCHAR2) IS
  BEGIN
    WSH_DEBUG_SV.push(p_module_name);
  END Enter_Debug;

  -----------------------------------------------------------------------------
  -- PROCEDURE  Exit_Debug
  --
  -- Purpose:  Exit the debug for current procedure/function in wsh debug file
  --
  -- IN Parameters:
  --	1. p_module_name:	module name to exit
  --
  -----------------------------------------------------------------------------

  PROCEDURE Exit_Debug(p_module_name  IN  VARCHAR2) IS

  BEGIN
    WSH_DEBUG_SV.pop(p_module_name);
  END Exit_Debug;


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
                          p_line_number IN	NUMBER DEFAULT NULL)  IS

  BEGIN

    WRITE_LOGFILE(p_module_name => p_module_name,
		  p_message	=> p_msg);

    IF (p_category IS NOT NULL) THEN
        Fnd_File.Put_Line(Fnd_File.Output, Get_Category_message(p_category));
    END IF;

    IF (p_line_number IS NOT NULL) THEN
      -- make 'Line No.' a message
      Fnd_File.Put_Line(Fnd_File.Output, 'Line No. ' || p_line_number || ' : ' || p_msg);
    ELSE
      Fnd_File.Put_Line(Fnd_File.Output, p_msg);
    END IF;

  END Write_OutFile;

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
                          p_line_number  IN  NUMBER DEFAULT NULL)  IS
  l_message VARCHAR2(2000);

  BEGIN

    l_message  := GET_MSG(p_name	=> p_msg_name,
			  p_tokens	=> p_tokens,
			  p_values	=> p_values);

    WRITE_LOGFILE(p_module_name => p_module_name,
		  p_message	=> l_message);

    IF (p_category IS NOT NULL) THEN
        Fnd_File.Put_Line(Fnd_File.Output, Get_Category_message(p_category));
    END IF;
    IF (p_line_number IS NOT NULL) THEN
-- make 'Line No.' a message
      Fnd_File.Put_Line(Fnd_File.Output, 'Line No. ' || p_line_number || ' : ' || l_message);
    ELSE
      Fnd_File.Put_Line(Fnd_File.Output, l_message);
    END IF;

  END Write_OutFile;

  -------------------------------------------------------------------------------------
  -- PROCEDURE  Write_LogFile
  --
  -- Purpose:  Logging a message.
  --
  -- IN Parameters:
  --  	1. p_module_name	the module messages were logged at
  --	    2. p_message		the message to be logged.
  -------------------------------------------------------------------------------------

  PROCEDURE Write_LogFile(p_module_name  IN VARCHAR2,
                          p_message      IN VARCHAR2)  IS

  BEGIN
    WSH_DEBUG_SV.LogMsg(p_module_name, p_message);
  END Write_LogFile;

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
  PROCEDURE Write_LogFile(p_module_name  IN   VARCHAR2,
                          p_attribute    IN   VARCHAR2,
                          p_value        IN   VARCHAR2) IS
  BEGIN
    WSH_DEBUG_SV.Log(x_Module   =>   p_module_name,
                     x_Text     =>   p_attribute,
                     x_Value    =>   p_value);

  END Write_LogFile;

END FTE_UTIL_PKG;

/
