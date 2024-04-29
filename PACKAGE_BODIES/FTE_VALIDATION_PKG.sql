--------------------------------------------------------
--  DDL for Package Body FTE_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_VALIDATION_PKG" AS
/* $Header: FTEVALDB.pls 120.10.12000000.2 2007/01/20 11:06:41 htnguyen ship $ */
  -- -------------------------------------------------------------------------- --
  --                                                                            --
  -- NAME:        FTE_VALIDATION_PKG                                            --
  -- TYPE:        PACKAGE BODY                                                  --
  -- DESCRIPTION: Contains Rate Chart Validations for Bulk Loader purposes      --
  --                                                                            --
  -- PROCEDURES AND FUNCTIONS:							--
  --		FUNCTIONS:	IS_VALID_PRICELIST				--
  --				GET_COLUMN					--
  --				GET_FREQ_CODE					--
  --				CALCULATE_FREQ_ARRIVAL				--
  --										--
  --		PROCEDURES:	VALIDATE_DATE					--
  --				ADD_ATTRIBUTE					--
  --				VALIDATE_CURRENCY				--
  --				VALIDATE_COLUMNS				--
  --				VALIDATE_CARRIER				--
  --				VALIDATE_LANE_NUMBER				--
  --				VALIDATE_LINE_NUMBER				--
  --				VALIDATE_ACTION					--
  --				VALIDATE_UOM					--
  --				VALIDATE_MODE_OF_TRANS				--
  --				VALIDATE_CARRIER_SERVICE			--
  --				VALIDATE_ZONE					--
  --				VALIDATE_REGION					--
  --				VALIDATE_RATING_ZONE_CHART			--
  --				VALIDATE_RATING_SETUP				--
  --				VALIDATE_ORIGIN					--
  --				VALIDATE_DESTINATION				--
  --				VALIDATE_LANE_RATE_CHART			--
  --				VALIDATE_LANE_COMMODITY				--
  --				VALIDATE_LANE_SERVICE_LEVEL			--
  --				VALIDATE_SERVICE				--
  --				VALIDATE_SERVICE_RATING_SETUP			--
  --				VALIDATE_SCHEDULE				--
  --				VALIDATE_SUBTYPE				--
  --				VALIDATE_SERVICE_LEVEL				--
  --				VALIDATE_RATE_CHART				--
  --				VALIDATE_RATE_LINE				--
  --				VALIDATE_RATE_BREAK				--
  --                                                                            --
  ----------------------------------------------------------------------------- --

  G_PKG_NAME    CONSTANT        VARCHAR2(50) := 'FTE_VALIDATION_PKG';
  G_CURDATE     DATE := sysdate;


  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_DATE
  --
  -- Purpose: validate a date format
  --
  -- IN Parameters
  --    1. p_date:		date to be verified
  --
  -- Out Parameters
  --    1. x_status:	status, -1 when no errors
  --	2. x_error_msg:	error message if any
  -----------------------------------------------------------------------------

  PROCEDURE VALIDATE_DATE(p_date		IN   OUT NOCOPY VARCHAR2,
			  p_line_number		IN   NUMBER,
                          x_status              OUT  NOCOPY  NUMBER,
			  x_error_msg		OUT  NOCOPY  VARCHAR2) IS

  l_module_name      		CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_DATE';

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (p_date IS NOT NULL) THEN
      BEGIN
        p_date := TO_DATE(p_date, FTE_BULKLOAD_PKG.G_DATE_FORMAT);
      EXCEPTION
        WHEN OTHERS THEN
	  BEGIN
	    p_date := TO_DATE(p_date, FTE_BULKLOAD_PKG.G_DATE_FORMAT3);
	  EXCEPTION
	    WHEN OTHERS THEN
              x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name   => 'FTE_CAT_INCORRECT_DATE',
	  			  	          p_tokens => STRINGARRAY('DATE'),
					          p_values => STRINGARRAY(p_date));
              FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		    	 p_msg	  	=> x_error_msg,
                   		    	 p_category	=> 'D',
				    	 p_line_number	=> p_line_number);
              FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
              x_status := 1;
              RETURN;
          END;
      END;

      IF (p_date IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name   => 'FTE_CAT_INCORRECT_DATE',
					    p_tokens => STRINGARRAY('DATE'),
					    p_values => STRINGARRAY(p_date));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
        RETURN;
      END IF;
    END IF;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> sqlerrm,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_DATE;

  -----------------------------------------------------------------------------
  -- PROCEDURE: ADD_ATTRIBUTE
  --
  -- Purpose: Store a pricing attribute in the temporary attribute tables for
  --          later insertion into QP_INTERFACE_PRICING_ATTRIBS.
  --
  -- IN Parameters
  --    1. p_pricing_attribute: The pricing attribute
  --    2. p_attr_value_from: 	The value of the pricing attribute
  --	3. p_attr_value_to:
  --    4. p_line_number: 	The line number for this pricing attribute.
  --	5. p_comp_operator:	comparison operator
  --	6. p_qp_pricing_attrib_tbl:	pl/sql table for pricing attributes
  --
  -- Out Parameters
  --    1. x_status:	status, -1 when no errors
  --	2. x_error_msg:	error message if any
  -----------------------------------------------------------------------------

  PROCEDURE ADD_ATTRIBUTE(p_pricing_attribute   IN   VARCHAR2,
                          p_attr_value_from     IN   VARCHAR2,
                          p_attr_value_to       IN   VARCHAR2,
                          p_line_number         IN   VARCHAR2,
                          p_context             IN   VARCHAR2,
                          p_comp_operator       IN   VARCHAR2,
			  p_qp_pricing_attrib_tbl	IN OUT	NOCOPY FTE_RATE_CHART_PKG.qp_pricing_attrib_tbl,
                          x_status              OUT  NOCOPY  NUMBER,
			  x_error_msg		OUT  NOCOPY  VARCHAR2) IS

  l_pricing_attr_datatype      	VARCHAR2(30);
  l_comp_operator              	VARCHAR2(30);
  l_pricing_attribute          	VARCHAR2(50);
  l_pricing_attribute_value    	VARCHAR2(50);
  l_count			NUMBER;
  l_module_name      		CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.ADD_ATTRIBUTE';

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute', p_pricing_attribute);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Value from', p_attr_value_from);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Value to', p_attr_value_to);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line Number', p_line_number);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Context', p_context);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Comparison operator', p_comp_operator);
    END IF;
    x_status                 := -1;

    l_pricing_attr_datatype  := 'C';
    l_comp_operator          := NULL;
    l_pricing_attribute      := p_pricing_attribute;

    IF (p_comp_operator = 'BETWEEN') THEN
      l_pricing_attr_datatype  := 'N';
    END IF;

    -- change PARCEL_MULTIPIECE_FLAG to MULTIPIECE_FLAG
    IF (p_pricing_attribute= 'PARCEL_MULTIPIECE_FLAG') THEN
      l_pricing_attribute := 'MULTIPIECE_FLAG';
    END IF;

    IF (p_pricing_attribute = 'COMMODITY_TYPE') OR (p_pricing_attribute = 'COMMODITY') THEN
      l_pricing_attribute := 'COMMODITY';
    END IF;

    IF (p_pricing_attribute = 'CONTAINER_TYPE' AND FTE_RATE_CHART_PKG.g_chart_type = 'FTE_RATE_CHART') THEN
      l_pricing_attribute := 'CONTAINER_TYPE';
    END IF;

    IF (p_pricing_attribute = 'VEHICLE') THEN
      l_pricing_attr_datatype := 'N';
    END IF;

    IF (p_pricing_attribute = 'ORIGIN_ZONE' OR  p_pricing_attribute = 'DESTINATION_ZONE' OR
      p_pricing_attribute = 'COMMODITY'   OR  p_pricing_attribute = 'TOTAL_SHIPMENT_QUANTITY') THEN
      l_pricing_attr_datatype := 'N';
    END IF;

    IF (p_pricing_attribute = 'SERVICE_LEVEL') THEN
      l_pricing_attribute := 'SERVICE_TYPE';
    END IF;

    IF (p_comp_operator IS NULL) THEN
      IF (p_attr_value_from IS NOT NULL AND p_attr_value_to IS NOT NULL) THEN
        l_comp_operator := 'BETWEEN';
        --assume here that the datatype is a number.
        l_pricing_attr_datatype := 'N';
      ELSIF (p_attr_value_from IS NOT NULL) THEN
        l_comp_operator := '=';
      END IF;
    ELSE
      l_comp_operator := p_comp_operator;
    END IF;

    l_count := p_qp_pricing_attrib_tbl.COUNT+1;

    p_qp_pricing_attrib_tbl(l_count).PROCESS_ID               	:= FTE_RATE_CHART_PKG.G_Process_Id;
    p_qp_pricing_attrib_tbl(l_count).PRODUCT_UOM_CODE         	:= FTE_RATE_CHART_PKG.G_Product_UOM;
    p_qp_pricing_attrib_tbl(l_count).PRICING_ATTRIBUTE_DATATYPE := l_pricing_attr_datatype;
    p_qp_pricing_attrib_tbl(l_count).ATTRIBUTE_GROUPING_NO      := 1;
    p_qp_pricing_attrib_tbl(l_count).LIST_LINE_NO             	:= p_line_number;
    p_qp_pricing_attrib_tbl(l_count).PRICING_ATTRIBUTE        	:= l_pricing_attribute;
    p_qp_pricing_attrib_tbl(l_count).PRICING_ATTR_VALUE_FROM  	:= p_attr_value_from;
    p_qp_pricing_attrib_tbl(l_count).PRICING_ATTR_VALUE_TO    	:= p_attr_value_to;
    p_qp_pricing_attrib_tbl(l_count).COMPARISON_OPERATOR_CODE   := l_comp_operator;

    p_qp_pricing_attrib_tbl(l_count).PROCESS_TYPE             	:= 'SSH';
    p_qp_pricing_attrib_tbl(l_count).INTERFACE_ACTION_CODE      := 'C';
    p_qp_pricing_attrib_tbl(l_count).EXCLUDER_FLAG            	:= 'N';
    p_qp_pricing_attrib_tbl(l_count).PRODUCT_ATTRIBUTE_CONTEXT  := 'ITEM';
    p_qp_pricing_attrib_tbl(l_count).PRODUCT_ATTRIBUTE        	:= 'PRICING_ATTRIBUTE3';
    p_qp_pricing_attrib_tbl(l_count).PRODUCT_ATTR_VALUE       	:= 'ALL';
    p_qp_pricing_attrib_tbl(l_count).PRODUCT_ATTRIBUTE_DATATYPE := 'C';
    p_qp_pricing_attrib_tbl(l_count).PRICING_ATTRIBUTE_CONTEXT  := p_context;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> sqlerrm,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END ADD_ATTRIBUTE;


  -----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_CURRENCY
  --
  -- Purpose: validate and cache the currency
  --
  -- IN Parameters
  --    1. p_currency:	currency or currency code
  --    2. p_line_number: 	The line number for this pricing attribute.
  --
  -- OUT parameters:
  --	1. x_status:	error status, -1 if no errors
  --	2. x_error_msg:	error message if any
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_CURRENCY(p_currency	IN	VARCHAR2,
                              p_carrier_id      IN      NUMBER,
			      p_line_number	IN	NUMBER,
			      x_status		OUT NOCOPY NUMBER,
			      x_error_msg	OUT NOCOPY VARCHAR2) IS
  l_currency_code	VARCHAR2(45);
  l_carrier_currency    VARCHAR2(45);
  l_module_name      	CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_CURRENCY';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Currency', p_currency);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    l_currency_code := FTE_UTIL_PKG.GET_FND_CURRENCY(p_currency, x_status, x_error_msg);

    IF (x_status <> -1 OR l_currency_code IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG ('FTE_CURRENCY_NOT_FOUND');  -- new message
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                                  p_msg         => x_error_msg,
                                  p_category    => 'D',
                                  p_line_number => p_line_number);

      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    IF (p_carrier_id is not NULL) THEN
      BEGIN
       SELECT currency_code INTO l_carrier_currency
       FROM   wsh_carriers
       WHERE  carrier_id = p_carrier_id;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_error_msg := Fte_Util_Pkg.Get_Msg(P_Name => 'FTE_SEL_INVALID_CARRIER');
         FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                                    p_msg         => x_error_msg,
                                    p_category    => 'D',
                                    p_line_number => p_line_number);
         x_status := 2;
         FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
         RETURN;
      END;

      IF ((l_carrier_currency <> p_currency AND l_carrier_currency <> l_currency_code) OR l_carrier_currency IS NULL) THEN
        x_error_msg := Fte_Util_Pkg.Get_Msg(P_Name => 'FTE_INVALID_CARRIER_CURRENCY');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                                    p_msg         => x_error_msg,
                                    p_category    => 'D',
                                    p_line_number => p_line_number);
        x_status := 2;
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        RETURN;
      END IF;
    END IF;
    --cache
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> sqlerrm,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_CURRENCY;


  -----------------------------------------------------------------------------
  -- FUNCTION ISNUM
  --
  -- Purpose: check if input is a number
  --
  -- IN Parameters
  --    1. pstr:	input string
  --
  -- RETURNS
  --  1 if input is a number, 0 if not
  -----------------------------------------------------------------------------
  FUNCTION isNum( pstr in varchar2 ) return number
  is
    x number;
  BEGIN
    x:= pstr;
    return 1;
  EXCEPTION
    WHEN others THEN return 0;
  END isNum;

  -----------------------------------------------------------------------------
  -- FUNCTION GET_FREQ_CODE
  --
  -- Purpose: get the frequency code in varchar2
  --
  -- IN Parameters
  --    1. p_frequency:	frequency string
  --    2. p_line_number: 	The line number for this pricing attribute.
  --
  -- OUT parameters:
  --	1. x_status:	error status, -1 if no errors
  --	2. x_error_msg:	error message if any
  --
  -- RETURN:
  --    the frequncy in numeric display
  -----------------------------------------------------------------------------
  FUNCTION GET_FREQ_CODE(p_frequency	IN	VARCHAR2,
			 p_line_number	IN	NUMBER,
			 x_status    	OUT NOCOPY  NUMBER,
			 x_error_msg 	OUT NOCOPY  VARCHAR2) RETURN VARCHAR2 IS

  l_freq	VARCHAR2(40) := UPPER(p_frequency);
  l_result	VARCHAR2(7);

  l_module_name      	CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.GET_FREQ_CODE';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Frequency', p_frequency);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    IF (INSTR(l_freq, 'SUN') > 0) THEN
      l_result := l_result || '1';
    END IF;

    IF (INSTR(l_freq, 'MON') > 0) THEN
      l_result := l_result || '2';
    END IF;

    IF (INSTR(l_freq, 'TUE') > 0) THEN
      l_result := l_result || '3';
    END IF;

    IF (INSTR(l_freq, 'WED') > 0) THEN
      l_result := l_result || '4';
    END IF;

    IF (INSTR(l_freq, 'THU') > 0) THEN
      l_result := l_result || '5';
    END IF;

    IF (INSTR(l_freq, 'FRI') > 0) THEN
      l_result := l_result || '6';
    END IF;

    IF (INSTR(l_freq, 'SAT') > 0) THEN
      l_result := l_result || '7';
    END IF;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
    RETURN l_result;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN NULL;
  END GET_FREQ_CODE;

  -----------------------------------------------------------------------------
  -- FUNCTION CALCULATE_FREQ_ARRIVAL
  --
  -- Purpose: calculate the frequency arrival date
  --
  -- IN Parameters
  --    1. p_frequency:	frequency string
  --	2. p_ind:	arrival date indicator
  --    3. p_line_number: 	The line number for this pricing attribute.
  --
  -- OUT parameters:
  --	1. x_status:	error status, -1 if no errors
  --	2. x_error_msg:	error message if any
  --
  -- RETURN:
  --    the frequncy arrival date in numeric display
  -----------------------------------------------------------------------------
  FUNCTION CALCULATE_FREQ_ARRIVAL(p_frequency	IN	VARCHAR2,
		 		  p_ind		IN	NUMBER,
				  p_line_number	IN	NUMBER,
				  x_status    	OUT NOCOPY  NUMBER,
				  x_error_msg 	OUT NOCOPY  VARCHAR2) RETURN VARCHAR2 IS
  l_arrival	VARCHAR2(40);
  l_ind		NUMBER;
  l_day		NUMBER;
  l_module_name      	CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.CALCULATE_FREQ_ARRIVAL';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Frequency', p_frequency);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Indicator', p_ind);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    IF (p_ind <> 0) THEN
      l_ind := MOD(p_ind, 7);
    END IF;

    FOR i IN 1..LENGTH(p_frequency) LOOP
      l_day := TO_NUMBER(SUBSTR(p_frequency, i, 1));
      IF (MOD((l_day + l_ind), 7) = 0) THEN
	l_arrival := l_arrival || '7';
      ELSE
	l_arrival := l_arrival || (MOD((l_day + l_ind), 7));
      END IF;
    END LOOP;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
    RETURN l_arrival;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN NULL;
  END CALCULATE_FREQ_ARRIVAL;

  -----------------------------------------------------------------------------
  -- FUNCTION Validate_Rate_Type
  --
  -- Purpose  Set the rate type (operator) at the line level.
  --
  -- IN Parameters
  --    1. p_rate_type:		The rate type to be validated.
  --	2. p_line_number:	line number
  --
  -- OUT Parameters:
  --	1. x_status:	error status, -1 if no errors
  --	2. x_error_msg:	error message if any
  --
  -- RETURN:
  --    the subtype, or null if it doesn't exist.
  -----------------------------------------------------------------------------
  FUNCTION Validate_Rate_Type (p_rate_type     	IN      VARCHAR2,
			       p_line_number	IN	NUMBER,
			       x_status    OUT NOCOPY  NUMBER,
			       x_error_msg OUT NOCOPY	VARCHAR2)
  RETURN VARCHAR2 IS

  l_rate_type   VARCHAR2(100);
  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_RATE_TYPE';

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate type', p_rate_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;
    l_rate_type := UPPER(p_rate_type);

    IF (p_rate_type = 'FIXED') THEN
      l_rate_type := 'BLOCK_PRICE';
    ELSIF (p_rate_type = 'PER_UOM') THEN
      l_rate_type := 'UNIT_PRICE';
    ELSIF (p_rate_type = 'BLOCK_UNIT') THEN
      --block unit always has breaks.
      l_rate_type := 'BREAKUNIT_PRICE';
    ELSIF (p_rate_type NOT IN ('LUMPSUM')) THEN
      x_status := 2;
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_RATE_TYPE_INVALID',
					  p_tokens	=> STRINGARRAY('TYPE'),
					  p_values	=> STRINGARRAY(p_rate_type));

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                   		  p_msg   	=> x_error_msg,
                   		  p_category    => 'D',
				  p_line_number	=> p_line_number);

    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
    return l_rate_type;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN NULL;
  END Validate_Rate_Type;

  -----------------------------------------------------------------------------
  -- FUNCTION Validate_Subtype
  --
  -- Purpose  Ensure that the subtype passed in the rate chart modifier is a valid
  --          subtype.
  --
  -- IN Parameters
  --    1. l_subtype   IN   VARCHAR2 : The subtype to be validated.
  --	2. p_line_number:	line number
  --
  -- OUT Parameters:
  --	1. x_status:	error status, -1 if no errors
  --	2. x_error_msg:	error message if any
  --
  -- RETURN:
  --    the subtype, or null if it doesn't exist.
  -----------------------------------------------------------------------------

  FUNCTION Validate_Subtype(p_subtype   IN    VARCHAR2,
			    p_line_number	IN	NUMBER,
			    x_status    OUT NOCOPY  NUMBER,
			    x_error_msg OUT NOCOPY	VARCHAR2) RETURN VARCHAR2 IS

  l_subtype    VARCHAR2(30);

  l_module_name   CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_SUBTYPE';

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Subtype', p_subtype);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    SELECT name INTO l_subtype
    FROM   wsh_freight_cost_types
    WHERE  freight_cost_type_code = 'FTECHARGE'
    AND    name = upper(p_subtype);

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

    RETURN l_subtype;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN NULL;
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN NULL;
  END Validate_Subtype;

  -----------------------------------------------------------------------------
  -- FUNCTION  Validate_Service_Level
  --
  -- Purpose    Validate that the carrier with id <p_carrier_id> has been set
  --            up to handle the service level <p_service_level>
  --
  -- IN Parameters
  --    1. p_carrier_id:  	The carrier id
  --	2. p_carrier_name:	carrier name
  --    3. p_service_level:	service level to validate
  --	4. p_line_number:	line number
  --
  -- OUT Parameters
  --	1. x_status:	error status, -1 if no errors
  --	2. x_error_msg:	error message if any
  --
  -- Returns:
  -- 	service code
  -----------------------------------------------------------------------------
  FUNCTION Validate_Service_Level (p_carrier_id    	IN  	NUMBER,
                                   p_carrier_name  	IN  	VARCHAR2,
                                   p_service_level 	IN  	VARCHAR2,
                                   p_line_number	IN	NUMBER,
				   x_status        	OUT NOCOPY NUMBER,
                                   x_error_msg     	OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 IS

  l_temp_char    VARCHAR2(256);
  l_service_code VARCHAR2(20);
  l_carrier_id   NUMBER;
  l_carrier_name VARCHAR2(100);
  l_module_name  CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_SERVICE_LEVEL';

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier ID', p_carrier_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier Name', p_carrier_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Service Level', p_service_level);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    IF (p_service_level IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_CAT_NO_SERVICE');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                   		  p_msg  	=> x_error_msg,
                   		  p_category    => 'A',
				  p_line_number	=> p_line_number);
      x_status := 1;
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN NULL;
    END IF;

    l_service_code := FTE_UTIL_PKG.GET_LOOKUP_CODE('WSH_SERVICE_LEVELS', p_service_level);

    IF (l_service_code IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_CAT_SERVICE_UNKNOWN',
                                          P_Tokens => STRINGARRAY('SERVICE_TYPE'),
					  P_values => STRINGARRAY(p_service_level));
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                   		 p_msg	  => x_error_msg,
                   		 p_category    => 'B',
				 p_line_number => p_line_number);
      x_status := 1;
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN NULL;
    END IF;

    IF (p_carrier_id IS NOT NULL) THEN
      l_carrier_id := p_carrier_id;
    ELSIF (p_carrier_name IS NOT NULL) THEN
      l_carrier_id := FTE_UTIL_PKG.Get_Carrier_Id(p_carrier_name => p_carrier_name);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN NULL;
      END IF;
    ELSE
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN l_service_code;
    END IF;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Service Code', l_service_code);
    END IF;

    --Verify that the carrier has the correct service level
    BEGIN
      SELECT service_level INTO l_temp_char
      FROM WSH_CARRIER_SERVICES
      WHERE  carrier_id = l_carrier_id
      AND service_level = l_service_code
      AND enabled_flag = 'Y'
      AND rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	IF (p_carrier_name IS NULL) THEN
	  l_carrier_name := FTE_UTIL_PKG.GET_CARRIER_NAME(p_carrier_id);
  	ELSE
	  l_carrier_name := p_carrier_name;
	END IF;

        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name  	=> 'FTE_CARRIER_SERVICE_INVALID',
				    	     p_tokens	=> STRINGARRAY('SERVICE_LEVEL', 'CARRIER_NAME'),
				    	     p_values	=> STRINGARRAY(p_service_level, l_carrier_name));

        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category    	=> 'D',
				    p_line_number	=> p_line_number);

        x_status := 2;
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        return null;
    END;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
    RETURN l_service_code;

  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN NULL;
  END Validate_Service_Level;


  --------------------------------------------------------------------
  -- PROCEDURE VALIDATE_NAME
  --
  -- Purpose: validate pricing parameter name
  --
  -- IN Parameter:
  --	1. p_type:		'PARAMETER' or others
  --	2. p_lane_function:	pricing lane function
  --	3. p_subtype:		pricing subtype
  --	4. p_name:		pricing parameter name
  --	5. p_line_number:	line number
  --
  -- OUT Parameter:
  --	1. p_deficit_wt:	deficit_wt flag
  --
  -- RETURNS:
  --  parameter id
  --------------------------------------------------------------------

  FUNCTION VALIDATE_NAME(p_type		IN 	VARCHAR2,
			 p_lane_function IN 	VARCHAR2,
			 p_subtype	IN 	VARCHAR2,
			 p_name		IN	VARCHAR2,
                         p_line_number	IN	NUMBER,
			 p_deficit_wt	IN OUT 	NOCOPY BOOLEAN,
			 x_status	OUT NOCOPY NUMBER,
			 x_error_msg	OUT NOCOPY VARCHAR2) RETURN NUMBER IS
  l_result	NUMBER;
  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_NAME';

  CURSOR GET_PARAMETER_ID1 (p_type IN VARCHAR2, p_subtype IN VARCHAR2, p_name IN VARCHAR2, p_lane_function IN VARCHAR2) IS
    SELECT PARAMETER_ID
      FROM FTE_PRC_PARAMETER_DEFAULTS
     WHERE parameter_type = p_type
       AND parameter_sub_type = p_subtype
       AND parameter_name = p_name
       AND lane_function in ('NONE', p_lane_function);

  CURSOR GET_PARAMETER_ID2 (p_type IN VARCHAR2, p_subtype IN VARCHAR2, p_name IN VARCHAR2, p_lane_function IN VARCHAR2) IS
    SELECT PARAMETER_ID
      FROM FTE_PRC_PARAMETER_DEFAULTS
     WHERE parameter_type = p_type
       AND parameter_sub_type = p_subtype
       AND parameter_name = p_name
       AND lane_function = p_lane_function;

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Type', p_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Lane Function', p_lane_function);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Subtype', p_subtype);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Name', p_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
      IF (p_deficit_wt) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Deficit Wt', 'TRUE');
      ELSE
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Deficit Wt', 'FALSE');
      END IF;
    END IF;
    x_status := -1;

    IF (p_type = 'PARAMETER' AND (p_lane_function <> 'NONE')) THEN
      OPEN GET_PARAMETER_ID1(p_type, p_subtype, p_name, p_lane_function);
      FETCH GET_PARAMETER_ID1 INTO l_result;
      CLOSE GET_PARAMETER_ID1;
    ELSE
      OPEN GET_PARAMETER_ID2(p_type, p_subtype, p_name, p_lane_function);
      FETCH GET_PARAMETER_ID2 INTO l_result;
      CLOSE GET_PARAMETER_ID2;
    END IF;

    IF (p_type = 'PARAMETER' AND p_lane_function = 'LTL' AND p_subtype = 'DEFICIT_WT' AND p_name = 'WT_BERAK_POINT') THEN
      p_deficit_wt := true;
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
    RETURN l_result;
  EXCEPTION
    WHEN OTHERS THEN
      IF (GET_PARAMETER_ID1%ISOPEN) THEN
	CLOSE GET_PARAMETER_ID1;
      END IF;
      IF (GET_PARAMETER_ID2%ISOPEN) THEN
	CLOSE GET_PARAMETER_ID2;
      END IF;
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN NULL;
  END VALIDATE_NAME;

  ------------------------------------------------------------------
  -- PROCEDURE VERIFY_LANE_BASIS
  --
  -- Purpose: verify if the lane has basis in lane level
  --
  -- IN parameters:
  --	1. p_lane_id:	lane id
  --	2. p_line_number:	line number
  --
  -- OUT parameters:
  --	1. p_lane_tbl:	pl/sql table for lanes
  --	2. x_status:	error status, -1 if no error
  --	3. x_error_msg: error message if any
  --
  ------------------------------------------------------------------

  PROCEDURE VERIFY_LANE_BASIS(p_lane_id		IN	NUMBER,
			      p_lane_tbl	IN OUT NOCOPY 	FTE_LANE_PKG.lane_tbl,
                              p_line_number	IN	NUMBER,
			      x_status		OUT NOCOPY NUMBER,
			      x_error_msg	OUT NOCOPY VARCHAR2) IS
  l_basis  	VARCHAR2(100);
  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_LANE_BASIS';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Lane ID', p_lane_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    SELECT basis
      INTO l_basis
      FROM fte_lanes
     WHERE lane_id = p_lane_id;

    IF (l_basis IS NULL) THEN
      p_lane_tbl(p_lane_tbl.COUNT).basis_flag := false;
    ELSIF (l_basis = 'CONTAINER_ALL') THEN
      p_lane_tbl(p_lane_tbl.COUNT).container_all_flag := true;
    END IF;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN;
  END VERIFY_LANE_BASIS;

  ------------------------------------------------------------------
  -- FUNCTION VALIDATE_CARRIER_SERVICE
  --
  -- Purpose: validate if the carrier has the service level
  --
  -- IN parameters:
  --	1. p_service_code:	serice code
  --	2. p_lane_id:		lane id
  -- 	3. p_carrier_id:	carrier id
  --	4. p_mode:		mode of transportation
  --	5. p_line_number:	line number
  --
  -- OUT parameters:
  --	1. x_status:	error status, -1 if no error
  --	2. x_error_msg: error message if any
  --
  -- RETURN true if the carrier has the serivce, else false
  ------------------------------------------------------------------

  FUNCTION VALIDATE_CARRIER_SERVICE(p_service_code	IN	VARCHAR2,
				    p_lane_id		IN	NUMBER DEFAULT NULL,
				    p_carrier_id	IN	NUMBER,
				    p_mode		IN	VARCHAR2,
	                            p_line_number	IN	NUMBER,
				    x_status		OUT NOCOPY NUMBER,
				    x_error_msg		OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
  l_result	VARCHAR2(10);
  l_numfetch	NUMBER;
  CURSOR GET_CARRIER_SERVICE (p_carrier_id	IN NUMBER, p_service_code IN VARCHAR2, p_mode IN VARCHAR2) IS
    SELECT 'true'
      FROM wsh_carrier_services s
     WHERE s.carrier_id = p_carrier_id
       AND s.mode_of_transport = p_mode
       AND s.service_level = p_service_code
       AND nvl(s.enabled_flag,'N') = 'Y';

  CURSOR GET_CARRIER_SERVICE2 (p_lane_id	IN NUMBER, p_service_code IN VARCHAR2) IS
    SELECT 'true'
      FROM wsh_carrier_services s, fte_lanes l
     WHERE s.carrier_id = l.carrier_id
       AND s.mode_of_transport=l.mode_of_transportation_code
       AND l.lane_id = p_lane_id
       AND s.service_level = p_service_code
       AND nvl(s.enabled_flag,'N') = 'Y';

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_CARRIER_SERVICE';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Lane ID', p_lane_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier ID', p_carrier_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Service code', p_service_code);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Mode', p_mode);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    IF (p_lane_id IS NULL) THEN
      OPEN GET_CARRIER_SERVICE(p_carrier_id, p_service_code, p_mode);
      FETCH GET_CARRIER_SERVICE INTO l_result;
      l_numfetch := SQL%ROWCOUNT;
      CLOSE GET_CARRIER_SERVICE;
    ELSE
      OPEN GET_CARRIER_SERVICE2(p_lane_id, p_service_code);
      FETCH GET_CARRIER_SERVICE2 INTO l_result;
      l_numfetch := SQL%ROWCOUNT;
      CLOSE GET_CARRIER_SERVICE2;
    END IF;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Result', l_result);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Num Fetch', l_numfetch);
    END IF;


    IF (l_numfetch = 0 OR l_result IS NULL) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN false;
    ELSE
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN true;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (GET_CARRIER_SERVICE%ISOPEN) THEN
	CLOSE GET_CARRIER_SERVICE;
      END IF;
      IF (GET_CARRIER_SERVICE2%ISOPEN) THEN
	CLOSE GET_CARRIER_SERVICE2;
      END IF;

      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN FALSE;
  END VALIDATE_CARRIER_SERVICE;

 ----------------------------------------------------------------------------
  -- FUNCTION IS_VALID_PRICELIST
  --
  -- Purpose: check if the list of pricelist names are valid
  --
  -- IN parameters:
  --	1. p_array:		array of the values for pricelists
  --	2. p_service_count:	number of service columns
  --	3. p_price_prefix:	price prefix for the pricelist
  --	4. p_carrier_id:	carrier id
  --	5. p_line_number:	line number
  --
  -- OUT parameters:
  --	1. x_status:	error status, -1 if no error
  --	2. x_error_msg: error message if any
  --
  -- Returns true/false
  ----------------------------------------------------------------------------
  FUNCTION IS_VALID_PRICELIST(p_array		IN	FTE_PARCEL_LOADER.service_array,
			      p_service_count	IN	NUMBER,
			      p_price_prefix	IN	VARCHAR2,
			      p_carrier_id	IN	NUMBER,
			      p_line_number	IN	NUMBER,
			      x_status		OUT NOCOPY NUMBER,
			      x_error_msg	OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
  l_temp 	VARCHAR2(50) := '%';
  l_result	NUMBER;
  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.IS_VALID_PRICELIST';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Service count', p_service_count);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Price prefix', p_price_prefix);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier ID', p_carrier_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    FOR i IN 1..p_service_count LOOP
      -- Search for Pricelist_id
      IF (p_array(i) IS NOT NULL) THEN
        l_result := FTE_RATE_CHART_PKG.GET_PRICELIST_ID(p_name	=> p_price_prefix || p_array(i),
							p_carrier_id	=> p_carrier_id,
							p_attribute1	=> l_temp);

	IF (l_result = -1) THEN
	  x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_PRICELIST_INVALID',
	 				      p_tokens		=> STRINGARRAY('NAME'),
					      p_values		=> STRINGARRAY(p_price_prefix || p_array(i)));

          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
             			      p_msg	   	=> x_error_msg,
             			      p_category    	=> 'D',
	        		      p_line_number	=> p_line_number);

          x_status := 2;
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          RETURN FALSE;
        END IF;
      END IF;
    END LOOP;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN FALSE;
  END IS_VALID_PRICELIST;

  ----------------------------------------------------------------------------
  -- FUNCTION GET_COLUMN
  --
  -- Purpose: check the stored in static columns
  --
  -- IN parameters:
  --	1. p_type:	type of the block which column is requested
  --
  -- Returns STRINGARRAY of the columns
  ----------------------------------------------------------------------------
  FUNCTION GET_COLUMN (p_type IN VARCHAR2) RETURN STRINGARRAY IS
  BEGIN
    IF (p_type = 'TL_BASE_RATES') THEN
      RETURN TL_BASE_RATES;
    ELSIF (p_type = 'SERVICE') THEN
      RETURN SERVICE;
    ELSIF (p_type = 'SERVICE_RATING_SETUP') THEN
      RETURN SERVICE_RATING_SETUP;
    ELSIF (p_type = 'SCHEDULE') THEN
      RETURN SCHEDULE;
    ELSIF (p_type = 'RATE_CHART') THEN
      RETURN RATE_CHART;
    ELSIF (p_type = 'RATE_LINE') THEN
      RETURN RATE_LINE;
    ELSIF (p_type = 'RATE_BREAK') THEN
      RETURN RATE_BREAK;
    ELSIF (p_type = 'RATING_ATTRIBUTE') THEN
      RETURN RATING_ATTRIBUTE;
    ELSIF (p_type = 'CHARGES_DISCOUNTS') THEN
      RETURN CHARGES_DISCOUNTS;
    ELSIF (p_type = 'CHARGES_DISCOUNTS_LINE') THEN
      RETURN CHARGES_DISCOUNTS_LINE;
    ELSIF (p_type = 'ADJUSTED_RATE_CHART') THEN
      RETURN ADJUSTED_RATE_CHART;
    ELSIF (p_type = 'RATING_ZONE_CHART') THEN
      RETURN RATING_ZONE_CHART;
    ELSIF (p_type = 'RATING_SETUP') THEN
      RETURN RATING_SETUP;
    ELSIF (p_type = 'TL_SERVICES') THEN
      RETURN TL_SERVICES;
    ELSIF (p_type = 'TL_SURCHARGES') THEN
      RETURN TL_SURCHARGES;
    ELSIF (p_type = 'FACILITY_CHARGES') THEN
      RETURN FACILITY_CHARGES;
    ELSIF (p_type = 'REGION') THEN
      RETURN REGION;
    ELSIF (p_type = 'ZONE') THEN
      RETURN ZONE;
    ELSIF (p_type = 'ORIGIN') THEN
      RETURN ORIGIN;
    ELSE
      RETURN NULL;
    END IF;
  END GET_COLUMN;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_COLUMNS
  --
  -- Purpose: check if the columns read is valid
  --
  -- IN parameters:
  --	1. p_keys:	columns STRINGARRAY
  --	2. p_type:	type of the block
  --	3. p_line_number:	line number
  --
  -- OUT parameters:
  --	1. x_status:		status, -1 if no error(1 wrong number, 2 wrong column, 3 no such type)
  --	2. x_error_msg:		error message if status <> -1
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_COLUMNS (p_keys	    IN	FTE_BULKLOAD_PKG.block_header_tbl,
			      p_type	    IN	VARCHAR2,
			      p_line_number IN	NUMBER,
			      x_status	    OUT NOCOPY	NUMBER,
			      x_error_msg   OUT NOCOPY	VARCHAR2) IS

  l_module_name      CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.VALIDATE_COLUMNS';
  l_column	STRINGARRAY := STRINGARRAY();
  l_found 	BOOLEAN := false;
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Type', p_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    l_column  := GET_COLUMN(p_type);

    IF (l_column is NULL) THEN
      x_status := 3;
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_COLUMN_TYPE_INVALID');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                   		  p_msg  	=> x_error_msg,
                   		  p_category    => 'D',
				  p_line_number	=> p_line_number);

      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN;
    END IF;

    FOR i IN 1..l_column.COUNT LOOP
      IF (NOT p_keys.EXISTS(l_column(i))) THEN
	x_status := 2;
	x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_MISSING_COLUMN',
					    p_tokens 	=> STRINGARRAY('COLUMN', 'SECTION'),
        	                            p_values 	=> STRINGARRAY(l_column(i), p_type));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		   p_msg		=> x_error_msg,
                   		   p_category		=> 'D',
				   p_line_number	=> p_line_number);

      ELSE
	FTE_BULKLOAD_PKG.g_block_header_index(p_keys(l_column(i))) := null;
      END IF;
    END LOOP;

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN;
    END IF;

    FOR i IN 1..FTE_BULKLOAD_PKG.g_block_header_index.COUNT LOOP
      IF (FTE_BULKLOAD_PKG.g_block_header_index(i) IS NOT NULL) THEN
	x_status := 2;
	x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_CAT_INVALID_COLUMN',
                                             P_Tokens => STRINGARRAY('COLUMN', 'SECTION'),
                                    	     p_values => STRINGARRAY(l_column(i), p_type));

        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg		=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
      END IF;
    END LOOP;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_COLUMNS;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_CARRIER
  --
  -- Purpose: check if the carrier name is valid
  --
  -- IN parameters:
  --	1. p_carrier_name:	name of the carrier
  --	2. p_line_number:	line number
  --
  -- OUT parameters:
  --	1. p_carrier_id:	id of the carrier associated with carrier name
  --	2. x_status:		status, -1 if no error
  --	3. x_error_msg:		error message if status <> -1
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_CARRIER(p_carrier_name	IN 		VARCHAR2,
			     p_line_number	IN		NUMBER,
			     p_carrier_id	OUT NOCOPY	NUMBER,
			     x_status		OUT NOCOPY 	NUMBER,
			     x_error_msg	OUT NOCOPY	VARCHAR2) IS
  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_CARRIER';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier Name', p_carrier_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    p_carrier_id := -1;
    IF (p_carrier_name IS NOT NULL) THEN
      p_carrier_id := FTE_UTIL_PKG.GET_CARRIER_ID(p_carrier_name);

      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier ID', p_carrier_id);
      END IF;
      IF (p_carrier_id = -1) THEN
	x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name     => 'FTE_CAT_CARRIER_INVALID',
				    	     p_tokens 	=> STRINGARRAY('CARRIER_NAME'),
                                    	     p_values 	=> STRINGARRAY(p_carrier_name));

        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'C',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;

	RETURN;
      END IF;
    ELSE
      x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name     => 'FTE_CAT_CARRIER_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		  p_msg			=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_CARRIER;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_LANE_NUMBER
  --
  -- Purpose: check if the lane number is valid
  --
  -- IN parameters:
  --	1. p_lane_number:	lane number value
  --	2. p_carrier_id:	carrier id
  --	3. p_line_number:	line number
  --
  -- OUT parameters:
  --	1. p_lane_id:		lane id of the lane number if exists in the table
  --	2. x_status:		status, -1 if no error
  --	3. x_error_msg:		error message if status <> -1
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_LANE_NUMBER(p_lane_number	IN 	VARCHAR2,
				 p_carrier_id	IN	NUMBER,
				 p_line_number	IN	NUMBER,
				 p_lane_id	OUT NOCOPY NUMBER,
				 x_status	OUT NOCOPY NUMBER,
				 x_error_msg	OUT NOCOPY VARCHAR2) IS
  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_LANE_NUMBER';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Lane Number', p_lane_number);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier ID', p_carrier_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    IF (p_lane_number IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_LANE_NUMBER_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		  p_msg  		=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    ELSIF (p_carrier_id <> -1) THEN
      -- Search for Lane Number in fte_lanes table
      -- Vijay: added clause to check if laneId is already populated
      p_lane_id := FTE_LANE_PKG.GET_LANE_ID(p_lane_number, p_carrier_id);
      IF (p_lane_id = -1) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_LANE_NUMBER_INVALID',
					    p_tokens 		=> STRINGARRAY('SERVICE_NUMBER'),
                                	    p_values 		=> STRINGARRAY(p_lane_number));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'C',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;
    END IF;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_LANE_NUMBER;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_ACTION
  --
  -- Purpose: check if the action is valid
  --
  -- IN parameters:
  --	1. p_action:		action value
  --	2. p_type:		block type
  --	3. p_line_number:	line number
  --
  -- OUT parameters:
  --	1. x_status:		status, -1 if no error
  --	2. x_error_msg:		error message if status <> -1
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_ACTION(p_action		IN OUT 	NOCOPY VARCHAR2,
			    p_type		IN	VARCHAR2,
			    p_line_number	IN	NUMBER,
			    x_status		OUT NOCOPY NUMBER,
			    x_error_msg		OUT NOCOPY VARCHAR2) IS
  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_ACTION';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', p_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Type', p_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    IF (p_action IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_ACTION_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		  p_msg  		=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    ELSE
      p_action := UPPER(p_action);
      IF (p_type = 'ZONE' AND p_action <> 'ADD') THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_ACTION_INVALID_ZONE',
					    p_tokens 		=> STRINGARRAY('ACTION'),
                	                    p_values 		=> STRINGARRAY(p_action));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

      IF (p_type = 'REGION' AND p_action <> 'ADD') THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_ACTION_INVALID_REGION',
					    p_tokens 		=> STRINGARRAY('ACTION'),
        	                            p_values 		=> STRINGARRAY(p_action));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

      IF (p_type = 'TL_SERVICES' AND p_action = 'SYNC') THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_ACTION_INVALID');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

      IF (p_type IN ('SERVICE_RATING_SETUP', 'TL_SERVICES', 'LANE_SERVICE')
	  AND p_action NOT IN ('SYNC', 'DELETE', 'ADD', 'UPDATE')) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_ACTION_INVALID');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

      IF (p_type = 'SCHEDULE' AND p_action NOT IN ('SYNC', 'DELETE', 'ADD')) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_ACTION_INVALID');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

      IF (p_type = 'LANE_COMMODITY_TYPE' AND p_action NOT IN ('ADD', 'DELETE')) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_COMM_TYPES_INV_ACT');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

      IF (p_type = 'LANE_SERVICE_LEVEL' AND p_action NOT IN ('ADD', 'DELETE')) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_SERV_TYPES_INV_ACT');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

      IF (p_type = 'LANE_RATE_CHART' AND p_action NOT IN ('ADD', 'DELETE')) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_FIELD_RATE_CHART_INV_ACT');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

      IF (p_type = 'RATE_CHART' AND p_action NOT IN ('ADD', 'UPDATE', 'DELETE', 'APPEND')) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_ACTION_INVALID');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

      IF (p_type IN ('RATE_LINE', 'TL_SURCHARGES') AND p_action NOT IN ('ADD', 'UPDATE', 'DELETE')) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_ACTION_INVALID');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

      IF (p_type IN ('RATING_ATTRIBUTE', 'RATE_BREAK') AND p_action NOT IN ('ADD', 'UPDATE')) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_ACTION_INVALID');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

      IF (p_type IN ('ADJUSTED_RATE_CHART', 'QUALIFIER') AND p_action <> 'ADD') THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_ACTION_INVALID');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;
    END IF;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_ACTION;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_UOM
  --
  -- Purpose: check if the uom is valid
  --
  -- IN parameters:
  --	1. p_uom:		uom value
  --	2. p_class:		uom class
  --	3. p_line_number:	line number
  --
  -- OUT parameters:
  --	1. p_uom_code:		the uom code for the uom name
  --	2. x_status:		status, -1 if no error
  --	3. x_error_msg:		error message if status <> -1
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_UOM(p_uom		IN	VARCHAR2,
			 p_class	IN	VARCHAR2,
			 p_line_number	IN	NUMBER,
			 p_uom_code	OUT NOCOPY VARCHAR2,
			 x_status	OUT NOCOPY NUMBER,
			 x_error_msg	OUT NOCOPY VARCHAR2) IS
  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_UOM';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'UOM', p_uom);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Class', p_class);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    p_uom_code := FTE_UTIL_PKG.GET_UOM_CODE(p_uom, p_class);
    IF (p_uom_code IS NULL) THEN
      IF (p_class IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_UOM_INVALID',
					    p_tokens 		=> STRINGARRAY('UOM'),
        	                            p_values 		=> STRINGARRAY(p_uom));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'B',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      ELSIF (p_class = 'Weight') THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_WT_UOM_INVALID',
					    p_tokens 		=> STRINGARRAY('UOM'),
                        	            p_values 		=> STRINGARRAY(p_uom));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      ELSIF (p_class = 'Volume') THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VOL_UOM_INVALID',
					    p_tokens 		=> STRINGARRAY('UOM'),
        	                            p_values 		=> STRINGARRAY(p_uom));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      ELSIF (p_class = 'Length') THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_DIM_UOM_INVALID',
					    p_tokens 		=> STRINGARRAY('UOM'),
        	                            p_values 		=>STRINGARRAY(p_uom));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      ELSIF (p_class = 'Time') THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_UOM_INVALID',
					    p_tokens 		=> STRINGARRAY('UOM'),
        	                            p_values 		=> STRINGARRAY(p_uom));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'B',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;
    END IF;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_UOM;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_MODE_OF_TRANS
  --
  -- Purpose: check if the mode of transportation is valid
  --
  -- IN parameters:
  --	1. p_mode:		mode of transportation value
  --	2. p_line_number:	line number
  --	3. p_carrier_id:	carrier id
  --
  -- OUT parameters:
  --	1. p_mode_code:		the mode of transportation code
  --	2. x_status:		status, -1 if no error
  --	3. x_error_msg:		error message if status <> -1
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_MODE_OF_TRANS(p_mode		IN	VARCHAR2,
			 	   p_line_number	IN	NUMBER,
				   p_carrier_id		IN	NUMBER,
			 	   p_mode_code		OUT NOCOPY VARCHAR2,
			 	   x_status		OUT NOCOPY NUMBER,
			 	   x_error_msg		OUT NOCOPY VARCHAR2) IS

  CURSOR GET_CARRIER_MODE (p_carrier_id IN NUMBER, p_mode IN VARCHAR2) IS
    SELECT mode_of_transport
      FROM wsh_carrier_services
     WHERE carrier_id = p_carrier_id
       AND mode_of_transport = p_mode
       AND nvl(enabled_flag,'N') = 'Y';

  l_mode	VARCHAR2(50);

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_MODE_OF_TRANS';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Mode', p_mode);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier ID', p_carrier_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;
    x_status := -1;

    IF (p_mode IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_MODE_OF_TRANS_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                   		  p_msg  	=> x_error_msg,
                   		  p_category	=> 'A',
				  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    ELSE
      p_mode_code := FTE_UTIL_PKG.GET_LOOKUP_CODE('WSH_MODE_OF_TRANSPORT', p_mode);
      IF (p_mode_code IS NOT NULL) THEN
        OPEN GET_CARRIER_MODE(p_carrier_id, p_mode_code);
	FETCH GET_CARRIER_MODE INTO l_mode;
	CLOSE GET_CARRIER_MODE;
	IF (l_mode IS NOT NULL) THEN
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          RETURN;
	ELSE
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CARRIER_MODE_INVALID',
					      p_tokens		=> STRINGARRAY('MODE'),
					      p_values		=> STRINGARRAY(p_mode));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		      p_msg	  	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;
	END IF;
      ELSE
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_MODE_OF_TRANS_INVALID',
					    p_tokens		=> STRINGARRAY('MODE'),
					    p_values		=> STRINGARRAY(p_mode));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;
    END IF;
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      IF (GET_CARRIER_MODE%ISOPEN) THEN
	CLOSE GET_CARRIER_MODE;
      END IF;
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_MODE_OF_TRANS;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_RATING_ZONE_CHART
  --
  -- Purpose: does validation for one line in rating zone chart block
  --
  -- IN parameters:
  --	1. p_values:	  pl/sql table of the rating zone chart line
  --	2. p_line_number: line number of current line
  --
  -- OUT parameters:
  --	1. p_chart_info: 	a STRINGARRAY that contains name_prefix, mode_of_trans, carrier_name,
  --				carrier_id, price_prefix, view_flag, start_date, and end_date
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_RATING_ZONE_CHART(p_values		IN		FTE_BULKLOAD_PKG.data_values_tbl,
				       p_line_number	IN		NUMBER,
				       p_chart_info	OUT NOCOPY	STRINGARRAY,
				       x_status		OUT NOCOPY	NUMBER,
				       x_error_msg	OUT NOCOPY	VARCHAR2) IS

  l_name_prefix		VARCHAR2(200);
  l_mode_of_trans	VARCHAR2(200);
  l_carrier_name	VARCHAR2(200);
  l_price_prefix	VARCHAR2(200);
  l_view_flag		VARCHAR2(10);
  l_start_date		VARCHAR2(100);
  l_end_date		VARCHAR2(100);
  l_carrier_id		NUMBER := NULL;
  l_mode_code		VARCHAR2(100);

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_RATING_ZONE_CHART';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    l_name_prefix 	:= FTE_UTIL_PKG.GET_DATA('NAME_PREFIX', p_values);
    l_mode_of_trans 	:= FTE_UTIL_PKG.GET_DATA('MODE_OF_TRANSPORTATION', p_values);
    l_carrier_name 	:= FTE_UTIL_PKG.GET_DATA('CARRIER_NAME', p_values);
    l_price_prefix 	:= FTE_UTIL_PKG.GET_DATA('RATE_CHART_PREFIX', p_values);
    l_view_flag   	:= FTE_UTIL_PKG.GET_DATA('RATE_CHART_VIEW_FLAG', p_values);
    l_start_date   	:= FTE_UTIL_PKG.GET_DATA('START_DATE', p_values);
    l_end_date     	:= FTE_UTIL_PKG.GET_DATA('END_DATE', p_values);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Name prefix', l_name_prefix );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Mode of transportation', l_mode_of_trans);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier name', l_carrier_name );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate chart prefix', l_price_prefix );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate chart view flag', l_view_flag );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Start date', l_start_date );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'End date', l_end_date );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    -- carrier name validation
    VALIDATE_CARRIER(p_carrier_name	=> l_carrier_name,
		     p_line_number	=> p_line_number,
		     p_carrier_id	=> l_carrier_id,
		     x_status		=> x_status,
		     x_error_msg	=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    -- Mode of Transportation
    -- modeOfTrans = "Multi-Modal";
    VALIDATE_MODE_OF_TRANS(p_mode	=> l_mode_of_trans,
			   p_line_number	=> p_line_number,
			   p_carrier_id	=> l_carrier_id,
			   p_mode_code	=> l_mode_code,
			   x_status	=> x_status,
			   x_error_msg	=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    IF (l_view_flag IS NULL) THEN
      l_view_flag := 'N';
    ELSIF (l_view_flag NOT IN ('Y', 'N')) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_PRICELIST_VIEW_INVALID',
					  p_tokens	=> STRINGARRAY('FLAG'),
					  p_values	=> STRINGARRAY(l_view_flag));
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                   		  p_msg 	=> x_error_msg,
                   		  p_category	=> 'D',
				  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;

    -- Validation for START_DATE

    VALIDATE_DATE(p_date => l_start_date,
		  p_line_number => p_line_number,
		  x_status => x_status,
		  x_error_msg => x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    -- Validation for END_DATE

    VALIDATE_DATE(p_date => l_end_date,
		  p_line_number => p_line_number,
		  x_status => x_status,
		  x_error_msg => x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    --VALIDATE_EFFECTIVE_DATE

    p_chart_info := STRINGARRAY(l_name_prefix, l_mode_of_trans, '', l_carrier_name,
            			l_price_prefix, l_view_flag, l_carrier_id,
            			l_start_date, l_end_date);
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_RATING_ZONE_CHART;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_RATING_SETUP
  --
  -- Purpose: does validation for one line in rating setup block
  --
  -- IN parameters:
  --	1. p_values:	pl/sql table of rating setup line
  --	2. p_line_number: line number of current line
  --
  -- OUT parameters:
  --	1. p_setup_info:	table of service information
  --	2. p_last_service_type:	last line's service type
  --	3. x_status:		status of the processing, -1 means no error
  --	4. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_RATING_SETUP(p_values		IN		FTE_BULKLOAD_PKG.data_values_tbl,
				  p_line_number		IN		NUMBER,
				  p_setup_info		IN OUT NOCOPY	FTE_BULKLOAD_PKG.array_tbl,
				  p_last_service_type	IN OUT NOCOPY	VARCHAR2,
				  x_status		OUT NOCOPY	NUMBER,
				  x_error_msg		OUT NOCOPY	VARCHAR2) IS

  l_service_type	VARCHAR2(200);
  l_type		VARCHAR2(200);
  l_subtype		VARCHAR2(200);
  l_name		VARCHAR2(200);
  l_value_from		VARCHAR2(200);
  l_value_to		VARCHAR2(200);
  l_uom			VARCHAR2(100);
  l_currency		VARCHAR2(100);
  l_count		NUMBER;
  l_service		VARCHAR2(100);

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_RATING_SETUP';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    l_service_type	:= FTE_UTIL_PKG.GET_DATA('SERVICE_LEVEL', p_values);
    l_type		:= FTE_UTIL_PKG.GET_DATA('TYPE', p_values);
    l_subtype		:= FTE_UTIL_PKG.GET_DATA('SUBTYPE', p_values);
    l_name		:= FTE_UTIL_PKG.GET_DATA('NAME', p_values);
    l_value_from	:= FTE_UTIL_PKG.GET_DATA('VALUE_FROM', p_values);
    l_value_to		:= FTE_UTIL_PKG.GET_DATA('VALUE_TO', p_values);
    l_uom		:= FTE_UTIL_PKG.GET_DATA('UOM', p_values);
    l_currency		:= FTE_UTIL_PKG.GET_DATA('CURRENCY', p_values);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Service Level', l_service_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Type', l_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Subtype', l_subtype);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Name', l_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Value from', l_value_from);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Value to', l_value_to);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Uom', l_uom);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Currency', l_currency);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    l_service := Validate_Service_Level (p_carrier_id		=> NULL,
                            		 p_carrier_name		=> NULL,
                            		 p_service_level 	=> l_service_type,
                            		 p_line_number		=> p_line_number,
                  			 x_status 		=> x_status,
                            		 x_error_msg 		=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    l_count := p_setup_info.COUNT+1;
    IF (p_last_service_type IS NULL OR (p_last_service_type IS NOT NULL AND l_service_type <> p_last_service_type)) THEN
      p_setup_info(l_count) := STRINGARRAY(l_service_type, l_type, l_subtype, l_name,
						      l_value_from, l_value_to, l_uom, l_currency);
    ELSE
      p_setup_info(l_count) := STRINGARRAY('', l_type, l_subtype, l_name,
						      l_value_from, l_value_to, l_uom, l_currency);
    END IF;

    p_last_service_type := l_service_type;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_RATING_SETUP;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_ORIGIN
  --
  -- Purpose: does validation for one line in origin block
  --
  -- IN parameters:
  --	1. p_values:	pl/sql table of origin line
  --	2. p_line_number: line number of current line
  --
  -- OUT parameters:
  --	1. p_origin:		STRINGARRAY of origin_postal, origin_country, origin_state, and origin_city
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_ORIGIN(p_values		IN		FTE_BULKLOAD_PKG.data_values_tbl,
			    p_line_number	IN		NUMBER,
			    p_origin		OUT NOCOPY	STRINGARRAY,
			    x_status		OUT NOCOPY	NUMBER,
			    x_error_msg		OUT NOCOPY	VARCHAR2) IS

  l_origin_postal	VARCHAR2(200);
  l_origin_country	VARCHAR2(200);
  l_origin_state	VARCHAR2(200);
  l_origin_city		VARCHAR2(200);

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_ORIGIN';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    l_origin_postal	:= FTE_UTIL_PKG.GET_DATA('POSTAL_CODE_RANGE', p_values);
    l_origin_country	:= FTE_UTIL_PKG.GET_DATA('COUNTRY', p_values);
    l_origin_state	:= FTE_UTIL_PKG.GET_DATA('STATE', p_values);
    l_origin_city	:= FTE_UTIL_PKG.GET_DATA('CITY', p_values);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Country', l_origin_country);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'State', l_origin_state);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'City', l_origin_city);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Postal', l_origin_postal);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    IF (l_origin_country IS NULL) THEN
      l_origin_country := 'US';
    END IF;

    IF (l_origin_postal IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_POSTAL_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                   		  p_msg  	=> x_error_msg,
                   		  p_category	=> 'A',
				  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;

    p_origin := STRINGARRAY(l_origin_postal, l_origin_country, l_origin_state, l_origin_city);

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_ORIGIN;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_DESTINATION
  --
  -- Purpose: does validation for one line in destination block
  --
  -- IN parameters:
  --	1. p_values:		pl/sql table of destination line
  --	2. p_line_number: 	line number of current line
  --	3. p_price_prefix:	price prefix
  --	4. p_carrier_id:	carrier id
  --	5. p_origin_zone:	pl/sql table of origin zone info
  --	6. p_service_count:	number of service columns
  --	7. p_services:		service column names
  --
  -- OUT parameters:
  --	1. p_dest:		STRINGARRAY of dest_postal, dest_country, dest_state, and dest_city
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_DESTINATION(p_values		IN OUT	NOCOPY	FTE_BULKLOAD_PKG.data_values_tbl,
				 p_line_number		IN		NUMBER,
				 p_price_prefix		IN		VARCHAR2,
				 p_carrier_id		IN		NUMBER,
				 p_origin_zone		IN		FTE_BULKLOAD_PKG.data_values_tbl,
				 p_service_count	IN OUT NOCOPY	NUMBER,
				 p_services		IN OUT NOCOPY	FTE_PARCEL_LOADER.service_array,
				 p_dest			OUT NOCOPY	STRINGARRAY,
				 x_status		OUT NOCOPY	NUMBER,
				 x_error_msg		OUT NOCOPY	VARCHAR2) IS

  l_service_value	VARCHAR2(200);
  l_array		FTE_PARCEL_LOADER.service_array := FTE_PARCEL_LOADER.service_array();
  l_dest_postal		VARCHAR2(200);
  l_dest_country	VARCHAR2(200);
  l_dest_state		VARCHAR2(200);
  l_dest_city		VARCHAR2(200);
  l_result		BOOLEAN := FALSE;

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_DESTINATION';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    --checking the service columns
    --replace invalid PricelistNames with empty string("")
    --UPS has -, [1], [2], [3]
    --Fedex has *, NA
    FOR i IN 1..p_service_count LOOP
      l_service_value := p_values(FTE_BULKLOAD_PKG.g_block_header_index(p_services(i)));
      IF (l_service_value IS NULL OR l_service_value IN ('-', '*', 'NA')
	  OR ((INSTR(l_service_value, '[') > 0) AND (INSTR(l_service_value, ']') > 0)
	  AND (INSTR(l_service_value, ']') > INSTR(l_service_value, '[')))) THEN
        p_values(FTE_BULKLOAD_PKG.g_block_header_index(p_services(i))) := '';
      END IF;
      l_array.EXTEND;
      l_array(i) := l_service_value;
    END LOOP;

    l_result := IS_VALID_PRICELIST(p_array		=> l_array,
			           p_service_count	=> p_service_count,
			           p_price_prefix	=> p_price_prefix,
			           p_carrier_id		=> p_carrier_id,
			           p_line_number	=> p_line_number,
			           x_status		=> x_status,
			           x_error_msg		=> x_error_msg);

    IF (x_status <> -1 OR NOT l_result) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    l_dest_postal	:= FTE_UTIL_PKG.GET_DATA('POSTAL_CODE_RANGE', p_values);
    l_dest_country	:= FTE_UTIL_PKG.GET_DATA('COUNTRY', p_values);
    l_dest_state	:= FTE_UTIL_PKG.GET_DATA('STATE', p_values);
    l_dest_city		:= FTE_UTIL_PKG.GET_DATA('CITY', p_values);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Country', l_dest_country);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'State', l_dest_state);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'City', l_dest_city);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Postal', l_dest_postal);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    IF (l_dest_country IS NULL) THEN
      l_dest_country := p_origin_zone(FTE_VALIDATION_PKG.ZONE(3));
    END IF;

    IF (l_dest_state IS NULL) THEN
      l_dest_state := p_origin_zone(FTE_VALIDATION_PKG.ZONE(4));
    END IF;

    IF (l_dest_city IS NULL) THEN
      l_dest_city := p_origin_zone(FTE_VALIDATION_PKG.ZONE(5));
    END IF;

    IF (l_dest_postal IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_POSTAL_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                   		  p_msg  	=> x_error_msg,
                   		  p_category	=> 'A',
				  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;

    p_dest := STRINGARRAY(l_dest_postal, l_dest_country, l_dest_state, l_dest_city);

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_DESTINATION;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_LANE_RATE_CHART
  --
  -- Purpose: does validation for a rate chart line in service block
  --
  -- IN parameters:
  --	1. p_values:		pl/sql table of lane's rate chart line
  --	2. p_line_number: 	line number of current line
  --	3. p_action:		action value of the line
  --  	4. p_lane_tbl:		pl/sql table for lanes
  --
  -- OUT parameters:
  --	1. p_lane_rate_chart_tbl: pl/sql table for lane rate charts
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_LANE_RATE_CHART(p_values		   IN		FTE_BULKLOAD_PKG.data_values_tbl,
			  	     p_line_number	   IN		NUMBER,
				     p_action		   IN		VARCHAR2,
				     p_lane_tbl		   IN		FTE_LANE_PKG.lane_tbl,
				     p_lane_rate_chart_tbl IN OUT NOCOPY FTE_LANE_PKG.lane_rate_chart_tbl,
				     p_set_error           IN           BOOLEAN DEFAULT TRUE,
				     x_status		   OUT NOCOPY	NUMBER,
				     x_error_msg           OUT NOCOPY	VARCHAR2) IS
  l_rate_chart_name VARCHAR2(200);
  l_rate_chart_info STRINGARRAY := STRINGARRAY();
  l_count	NUMBER;
  l_module_name      CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.VALIDATE_LANE_RATE_CHART';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action     ', p_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Lane ID    ', p_lane_tbl(p_lane_tbl.COUNT).lane_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    IF (NOT p_lane_tbl(p_lane_tbl.COUNT).basis_flag) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LANE_BASIS_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		 p_msg  	=> x_error_msg,
                   		 p_category	=> 'A',
				 p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;

    IF (p_lane_tbl IS NOT NULL) THEN -- if service line is not missing
      IF (p_lane_tbl(p_lane_tbl.COUNT).lane_id <> 0) THEN

        l_rate_chart_name := FTE_UTIL_PKG.GET_DATA('RATE_CHART_NAME', p_values);
	IF (l_rate_chart_name IS NULL) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LANE_RATE_CHART_MISSING');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		     p_msg  		=> x_error_msg,
                   		     p_category		=> 'A',
				     p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
          RETURN;
       	END IF;
        l_rate_chart_info := FTE_RATE_CHART_PKG.GET_RATE_CHART_INFO(p_name		=> l_rate_chart_name,
								    p_carrier_id	=> p_lane_tbl(p_lane_tbl.COUNT).carrier_id,
								    x_status		=> x_status,
								    x_error_msg		=> x_error_msg);
        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	  RETURN;
	END IF;

        IF (l_rate_chart_info IS  NULL) THEN

	  IF ( p_set_error = FALSE) THEN
              x_status := -1;
	      x_error_msg := 'Returning from VALIDATE_RATE_CHART with TRUE';
	      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	      RETURN;
	  END IF;
	  x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_RATE_CHART_UNKNOWN',
					      p_tokens		=> STRINGARRAY('RATE_CHART'),
					      p_values		=> STRINGARRAY(l_rate_chart_name));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		      p_msg	  	=> x_error_msg,
                   		      p_category	=> 'C',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;

        END IF;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      	  FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate chart name', l_rate_chart_name);
      	  FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'List header ID', l_rate_chart_info(1));
    	END IF;

        IF (p_action <> 'DELETE') THEN
	  IF (FTE_LANE_PKG.CHECK_EXISTING_LOAD(p_id	=> p_lane_tbl(p_lane_tbl.COUNT).lane_id,
					       p_table	=> 'FTE_LANE_RATE_CHARTS',
					       p_code 	=> TO_NUMBER(l_rate_chart_info(1)),
					       p_line_number => p_line_number,
					       x_status	=> x_status,
					       x_error_msg => x_error_msg)) THEN
	    IF (x_status <> -1) THEN
              FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  	      RETURN;
	    END IF;
 	    x_status := 2;
	    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LANE_RATE_CHART_EXIST',
						p_tokens => STRINGARRAY('NAME'),
						p_values => STRINGARRAY(l_rate_chart_name));
	    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
				       p_msg		=> x_error_msg,
				       p_category	=> 'D',
				       p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	    RETURN;
	  END IF;

	  IF (FTE_LANE_PKG.VERIFY_OVERLAPPING_DATE(p_name	=> l_rate_chart_name,
					           p_lane_id 	=> p_lane_tbl(p_lane_tbl.COUNT).lane_id,
					           x_status	=> x_status,
					           x_error_msg 	=> x_error_msg)) THEN
  	    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_DATE_OVERLAP',
					        p_tokens	=> STRINGARRAY('RATE_CHART1', 'RATE_CHART2'),
					        p_values	=> STRINGARRAY(l_rate_chart_name, NULL));
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		        p_msg	  	=> x_error_msg,
                   		        p_category	=> 'D',
				        p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
	    RETURN;
	  END IF;
        END IF;

        l_count := p_lane_rate_chart_tbl.COUNT+1;
        p_lane_rate_chart_tbl(l_count).lane_id := p_lane_tbl(p_lane_tbl.COUNT).lane_id;
        p_lane_rate_chart_tbl(l_count).list_header_id := TO_NUMBER(l_rate_chart_info(1));

        IF (l_rate_chart_info(2) IS NOT NULL) THEN
	  BEGIN
	    p_lane_rate_chart_tbl(l_count).start_date_active := TO_DATE(l_rate_chart_info(2), FTE_BULKLOAD_PKG.G_DATE_FORMAT2);
          EXCEPTION
            WHEN OTHERS THEN
	      x_error_msg := sqlerrm;
              FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                  			 p_msg   	=> x_error_msg,
             			      	 p_category    	=> 'O',
	        		    	 p_line_number	=> p_line_number);
              FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
              x_status := 1;
              RETURN;
          END;

	  IF (p_lane_rate_chart_tbl(l_count).start_date_active IS NULL) THEN
  	    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_INCORRECT_DATE',
					        p_tokens		=> STRINGARRAY('DATE'),
					        p_values		=> STRINGARRAY(l_rate_chart_info(2)));
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	 	=> l_module_name,
                     		        p_msg	  		=> x_error_msg,
                   		        p_category		=> 'D',
				        p_line_number		=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
            RETURN;
	  END IF;

          IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
       	    FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Start date', l_rate_chart_info(2));
	  END IF;
    	END IF;

        IF (l_rate_chart_info(3) IS NOT NULL) THEN
	  BEGIN
  	    p_lane_rate_chart_tbl(l_count).end_date_active := TO_DATE(l_rate_chart_info(3), FTE_BULKLOAD_PKG.G_DATE_FORMAT2);
          EXCEPTION
            WHEN OTHERS THEN
	      x_error_msg := sqlerrm;
              FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                  			  p_msg   		=> x_error_msg,
             			      	  p_category    	=> 'O',
	        		    	  p_line_number		=> p_line_number);
              FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
              x_status := 1;
              RETURN;
          END;

	  IF (p_lane_rate_chart_tbl(l_count).end_date_active IS NULL) THEN
  	    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_INCORRECT_DATE',
					        p_tokens		=> STRINGARRAY('DATE'),
					        p_values		=> STRINGARRAY(l_rate_chart_info(3)));
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 		=> l_module_name,
                   		        p_msg	  		=> x_error_msg,
                   		        p_category		=> 'D',
				        p_line_number		=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
            RETURN;
	  END IF;

          IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
       	    FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'End date', l_rate_chart_info(3));
	  END IF;
        END IF;
      END IF;
    ELSE
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_LANE_REF_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                   	          p_msg  	=> x_error_msg,
                   		  p_category	=> 'D',
				  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_LANE_RATE_CHART;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_LANE_COMMODITY
  --
  -- Purpose: does validation for a commodity line in service block
  --
  -- IN parameters:
  --	1. p_values:		pl/sql table of the lane's commodity line
  --	2. p_line_number: 	line number of current line
  --	3. p_type:		type value of the line
  --	4. p_action:		action value of the line
  --  	5. p_lane_tbl:		pl/sql table for lanes
  --
  -- OUT parameters:
  --	1. p_lane_commodity_tbl: pl/sql table for lane commodity
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_LANE_COMMODITY(p_values			IN		FTE_BULKLOAD_PKG.data_values_tbl,
			  	    p_line_number		IN		NUMBER,
				    p_type			IN		VARCHAR2,
				    p_action			IN		VARCHAR2,
				    p_lane_tbl			IN		FTE_LANE_PKG.lane_tbl,
				    p_lane_commodity_tbl 	IN OUT	NOCOPY	FTE_LANE_PKG.lane_commodity_tbl,
				    x_status			OUT NOCOPY	NUMBER,
				    x_error_msg			OUT NOCOPY	VARCHAR2) IS
  l_catg_id	NUMBER := -1;
  l_count	NUMBER;
  l_com_class	VARCHAR2(100);
  l_com_type	VARCHAR2(100);
  l_basis	VARCHAR2(100);
  l_basis_code	VARCHAR2(100);

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_LANE_COMMODITY';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Type', p_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', p_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    l_count := p_lane_commodity_tbl.COUNT+1;

    -- If the lane is deleted, or anything is wrong with the lane
    -- don't do anything with the Commodity...
    -- laneId is set to  0 when it's deleted in deleteLane
    -- laneId is set to -1 when there's any error with the lane
    IF (p_lane_tbl IS NOT NULL) THEN -- if service line is not missing
      IF (p_lane_tbl(p_lane_tbl.COUNT).lane_id <> 0) THEN
        l_com_class := p_lane_tbl(p_lane_tbl.COUNT).comm_fc_class_code;
        l_com_type  := FTE_UTIL_PKG.GET_DATA('COMMODITY_TYPE', p_values);

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
          FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Commodity class', l_com_class);
          FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Commodity type', l_com_type);
        END IF;

        IF (l_com_type IS NULL) THEN
	  x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_COMM_TYPE_MISSING');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		     p_msg		=> x_error_msg,
                   		     p_category		=> 'A',
				     p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;
        END IF;

        IF (l_com_class IS NULL) THEN
	  x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_COMM_CLASS_MISSING');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		     p_msg	  	=> x_error_msg,
                   		     p_category		=> 'A',
				     p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;
       	ELSE
          l_catg_id := FTE_UTIL_PKG.GET_CATG_ID(l_com_class, l_com_type);

          IF (l_catg_id = -1) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_COMMODITY_UNKNOWN',
					        p_tokens	=> STRINGARRAY('COMMODITY'),
				        	p_values	=> STRINGARRAY(l_com_type));
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                  		        p_msg	  	=> x_error_msg,
                   		        p_category	=> 'D',
				        p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
	    RETURN;
          ELSIF (l_catg_id = -2) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_COMMODITY_AMBIG',
					        p_tokens	=> STRINGARRAY('COMMODITY'),
					        p_values	=> STRINGARRAY(l_com_type));
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		        p_msg	  	=> x_error_msg,
                   		        p_category	=> 'D',
				        p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
	    RETURN;
          ELSIF (l_catg_id = -3) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_COMM_MISMATCH',
					        p_tokens	=> STRINGARRAY('COMMODITY'),
					        p_values	=> STRINGARRAY(l_com_type));
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		        p_msg	  	=> x_error_msg,
                   		        p_category	=> 'D',
				        p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
	    RETURN;
          ELSE
  	    IF (p_action = 'ADD') THEN
	      IF (FTE_LANE_PKG.CHECK_EXISTING_LOAD(p_id		=> p_lane_tbl(p_lane_tbl.COUNT).lane_id,
					           p_table	=> 'FTE_LANE_COMMODITIES',
					           p_code 	=> l_catg_id,
					           p_line_number => p_line_number,
					           x_status	=> x_status,
					           x_error_msg 	=> x_error_msg)) THEN
  	        IF (x_status <> -1) THEN
                  FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  	          RETURN;
	        END IF;
 	        x_status := 2;
	        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LANE_COMMODITY_EXIST',
						    p_tokens => STRINGARRAY('NAME'),
						    p_values => STRINGARRAY(l_com_type));
	        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
				           p_msg		=> x_error_msg,
				           p_category		=> 'D',
				           p_line_number	=> p_line_number);
                FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	        RETURN;
	      END IF;
	    END IF;
            p_lane_commodity_tbl(l_count).commodity_catg_id := l_catg_id;
	  END IF;
        END IF;

        -- Validation for BASIS
        l_basis := FTE_UTIL_PKG.GET_DATA('BASIS', p_values);
        IF (l_basis IS NULL OR p_lane_tbl(p_lane_tbl.COUNT).container_all_flag) THEN
          IF (NOT p_lane_tbl(p_lane_tbl.COUNT).basis_flag) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_BASIS_MISSING');
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		       p_msg	  	=> x_error_msg,
                   		       p_category	=> 'A',
				       p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
	    RETURN;
	  END IF;
        ELSE
          l_basis_code := FTE_UTIL_PKG.GET_LOOKUP_CODE('FTE_BASES', l_basis);
          IF (l_basis_code IS NOT NULL) THEN
            p_lane_commodity_tbl(l_count).basis := l_basis_code;
	    p_lane_commodity_tbl(l_count).basis_flag := true;
	  ELSE
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_COMM_BASIS_INVALID',
					        p_tokens	=> STRINGARRAY('BASIS'),
					        p_values	=> STRINGARRAY(l_basis));
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		        p_msg	  	=> x_error_msg,
                   		        p_category	=> 'D',
				        p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
	    RETURN;
	  END IF;
        END IF;

 	p_lane_commodity_tbl(l_count).lane_id := p_lane_tbl(p_lane_tbl.COUNT).lane_id;
	p_lane_commodity_tbl(l_count).lane_commodity_id := FTE_LANE_PKG.GET_NEXT_LANE_COMMODITY_ID;

      END IF;
    ELSE
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_LANE_REF_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                   		  p_msg  	=> x_error_msg,
                   		  p_category	=> 'D',
				  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			 p_msg   	=> x_error_msg,
             			 p_category    => 'O',
	        		 p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_LANE_COMMODITY;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_LANE_SERVICE_LEVEL
  --
  -- Purpose: does validation for a service level line in service block
  --
  -- IN parameters:
  --	1. p_values:		pl/sql table of the lane's service level line
  --	2. p_line_number: 	line number of current line
  --	3. p_type:		type value of the line
  --	4. p_action:		action value of the line
  --  	5. p_lane_tbl:		pl/sql table for lanes
  --
  -- OUT parameters:
  --	1. p_lane_service_tbl: pl/sql table for lane service level
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_LANE_SERVICE_LEVEL(p_values		IN		FTE_BULKLOAD_PKG.data_values_tbl,
			  	    	p_line_number		IN		NUMBER,
				    	p_type			IN		VARCHAR2,
				    	p_action		IN		VARCHAR2,
				    	p_lane_tbl		IN		FTE_LANE_PKG.lane_tbl,
				    	p_lane_service_tbl 	IN OUT NOCOPY	FTE_LANE_PKG.lane_service_tbl,
				    	x_status		OUT NOCOPY	NUMBER,
				    	x_error_msg		OUT NOCOPY	VARCHAR2) IS
  l_service_level	VARCHAR2(100);
  l_service_code	VARCHAR2(100);
  l_count		NUMBER;
  l_carrier_name	VARCHAR2(100);

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_LANE_SERVICE_LEVEL';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Type', p_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', p_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    -- If the lane is deleted, or anything is wrong with the lane
    -- don't do anything with the Types...
    -- laneId is set to  0 when it's deleted in deleteLane
    -- laneId is set to -1 when there's any error with the lane
    IF (p_lane_tbl IS NOT NULL) THEN -- if service line is not missing
      IF (p_lane_tbl(p_lane_tbl.COUNT).lane_id <> 0) THEN

        IF (p_type = 'SERVICE_LEVEL') THEN
          l_service_level := FTE_UTIL_PKG.GET_DATA('SERVICE_LEVEL', p_values);

          IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Service Level', l_service_level);
  	  END IF;
        END IF;

	IF (l_service_level IS NULL) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_NO_SERVICE');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		      p_msg	  	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;
	ELSE
   	  l_service_code := Validate_Service_Level (p_carrier_id	=> p_lane_tbl(p_lane_tbl.COUNT).carrier_id,
                                  		    p_carrier_name  	=> null,
                                  		    p_service_level 	=> l_service_level,
						    p_line_number	=> p_line_number,
				  		    x_status 		=> x_status,
                                    		    x_error_msg  	=> x_error_msg);
     	  IF (x_status <> -1) THEN
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	    RETURN;
	  END IF;

          IF (l_service_code IS NULL) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_SERVICE_UNKNOWN',
					        p_tokens	=> STRINGARRAY('SERVICE'),
					        p_values	=> STRINGARRAY(l_service_level));
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		        p_msg	  	=> x_error_msg,
                   		        p_category	=> 'D',
				        p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
	    RETURN;
	  ELSIF (p_type = 'SERVICE_LEVEL'
		  AND NOT(VALIDATE_CARRIER_SERVICE(p_service_code 	=> l_service_code,
						   p_carrier_id		=> p_lane_tbl(p_lane_tbl.COUNT).carrier_id,
						   p_mode		=> p_lane_tbl(p_lane_tbl.COUNT).mode_of_transportation_code,
						   p_line_number	=> p_line_number,
						   x_status		=> x_status,
						   x_error_msg		=> x_error_msg))) THEN
	    -- checking if the carrier has the service level matching the mode
	    IF (p_lane_tbl(p_lane_tbl.COUNT).mode_of_transportation_code IS NULL
		  AND NOT(VALIDATE_CARRIER_SERVICE(p_service_code 	=> l_service_code,
						   p_lane_id 		=> p_lane_tbl(p_lane_tbl.COUNT).lane_id,
						   p_carrier_id		=> p_lane_tbl(p_lane_tbl.COUNT).carrier_id,
						   p_mode		=> p_lane_tbl(p_lane_tbl.COUNT).mode_of_transportation_code,
						   p_line_number	=> p_line_number,
						   x_status		=> x_status,
						   x_error_msg		=> x_error_msg))) THEN

  	      l_carrier_name := FTE_UTIL_PKG.GET_CARRIER_NAME(p_lane_tbl(p_lane_tbl.COUNT).carrier_id);
              x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CARRIER_SERVICE_INVALID',
					          p_tokens	=> STRINGARRAY('SERVICE_LEVEL', 'CARRIER_NAME'),
					          p_values	=> STRINGARRAY(l_service_level, l_carrier_name));
              FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		         p_msg  	=> x_error_msg,
                   		         p_category	=> 'B',
				         p_line_number	=> p_line_number);
              FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
              x_status := 1;
	      RETURN;
	    END IF;
 	  END IF;
	END IF;

  	IF (p_action = 'ADD') THEN
	  IF (FTE_LANE_PKG.CHECK_EXISTING_LOAD(p_id	=> p_lane_tbl(p_lane_tbl.COUNT).lane_id,
					       p_table	=> 'FTE_LANE_SERVICES',
					       p_code 	=> l_service_code,
					       p_line_number => p_line_number,
					       x_status	=> x_status,
					       x_error_msg 	=> x_error_msg)) THEN
  	    IF (x_status <> -1) THEN
              FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  	      RETURN;
	    END IF;
 	    x_status := 2;
	    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LANE_SERVICE_EXIST',
						p_tokens => STRINGARRAY('NAME'),
						p_values => STRINGARRAY(l_service_level));
	    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
				       p_msg		=> x_error_msg,
				       p_category	=> 'D',
				       p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	    RETURN;
	  END IF;
	END IF;

	l_count := p_lane_service_tbl.COUNT+1;

	p_lane_service_tbl(l_count).service_code := l_service_code;
	p_lane_service_tbl(l_count).lane_id := p_lane_tbl(p_lane_tbl.COUNT).lane_id;
	p_lane_service_tbl(l_count).lane_service_id := FTE_LANE_PKG.GET_NEXT_LANE_SERVICE_ID;

      END IF;
    ELSE
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_LANE_REF_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		  p_msg  		=> x_error_msg,
                   		  p_category		=> 'D',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;

  END VALIDATE_LANE_SERVICE_LEVEL;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_SERVICE
  --
  -- Purpose: does validation for a line in service block
  --
  -- IN parameters:
  --	1. p_values:		pl/sql table of the service line
  --	2. p_line_number: 	line number of current line
  --
  -- OUT parameters:
  --	1. p_type:		type value of the line
  --	2. p_action:		action value of the line
  --	3. p_lane_tbl:		pl/sql table for lane
  --	4. p_lane_rate_chart_tbl: pl/sql table for lane rate chart
  --	5. p_lane_service_tbl:	pl/sql table for lane service
  --	6. p_lane_commodity_tbl: pl/sql table for lane commodity
  --	7. x_status:		status of the processing, -1 means no error
  --	8. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_SERVICE(p_values			IN		FTE_BULKLOAD_PKG.data_values_tbl,
			     p_line_number		IN		NUMBER,
			     p_type			OUT NOCOPY	VARCHAR2,
			     p_action			OUT NOCOPY	VARCHAR2,
			     p_lane_tbl			IN OUT	NOCOPY	FTE_LANE_PKG.lane_tbl,
			     p_lane_rate_chart_tbl 	IN OUT	NOCOPY	FTE_LANE_PKG.lane_rate_chart_tbl,
			     p_lane_service_tbl		IN OUT	NOCOPY	FTE_LANE_PKG.lane_service_tbl,
			     p_lane_commodity_tbl 	IN OUT	NOCOPY	FTE_LANE_PKG.lane_commodity_tbl,
			     x_status			OUT NOCOPY	NUMBER,
			     x_error_msg		OUT NOCOPY	VARCHAR2) IS

  l_effect_date		VARCHAR2(30);
  l_expiry_date		VARCHAR2(30);
  l_distance		VARCHAR2(30);
  l_distance_uom	VARCHAR2(10);
  l_transit		VARCHAR2(30);
  l_transit_uom		VARCHAR2(10);
  l_editable_flag	VARCHAR2(1) := NULL;
  l_mode		VARCHAR2(20);
  l_com_class		VARCHAR2(30);
  l_basis		VARCHAR2(30);
  l_view_flag		VARCHAR2(1);
  l_com_class_code	VARCHAR2(20);
  l_mode_code		VARCHAR2(20);
  l_basis_code		VARCHAR2(20);
  l_distance_uom_code	VARCHAR2(10);
  l_temp_number		VARCHAR2(60);
  l_count		NUMBER := 0;
  l_carrier_id		NUMBER := -1;
  l_rate_chart_id	NUMBER := -1;
  l_old_lane_id		NUMBER := -1;
  l_lane_number		VARCHAR2(200);
  l_carrier_name	VARCHAR2(200);
  l_rate_chart_name	VARCHAR2(200);
  l_transit_time_uom_code VARCHAR2(100);
  l_convert_date	DATE;

  l_region_info		wsh_regions_search_pkg.region_rec;
  l_region_id           wsh_regions.region_id%type;

  l_zone_id             NUMBER;
  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_SERVICE';

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    p_type	:= FTE_UTIL_PKG.GET_DATA('TYPE', p_values);
    p_action	:= FTE_UTIL_PKG.GET_DATA('ACTION', p_values);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Type', p_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', p_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    IF (p_type IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_TYPE_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		 p_msg		=> x_error_msg,
                   		 p_category	=> 'A',
				 p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    ELSE
      p_type := UPPER(p_type);
    END IF;

    IF (p_type NOT IN ('SERVICE', 'COMMODITY_TYPE', 'SERVICE_LEVEL', 'RATE_CHART')) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_LANE_TYPE_UNKNOWN',
                                          P_Tokens => STRINGARRAY('TYPE'),
					  P_values => STRINGARRAY(p_type));
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		 p_msg		=> x_error_msg,
                   		 p_category	=> 'D',
				 p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;

    VALIDATE_ACTION(p_action	=> p_action,
		    p_type	=> 'LANE_'||p_type,
		    p_line_number => p_line_number,
		    x_status	=> x_status,
		    x_error_msg	=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    IF (p_type = 'SERVICE') THEN
      l_count := p_lane_tbl.COUNT+1;
      p_lane_tbl(l_count).action := p_action;

      l_lane_number	:= FTE_UTIL_PKG.GET_DATA('SERVICE_NUMBER', p_values);
      l_carrier_name	:= FTE_UTIL_PKG.GET_DATA('CARRIER_NAME', p_values);
      l_rate_chart_name := FTE_UTIL_PKG.GET_DATA('RATE_CHART_NAME', p_values);
      l_mode       	:= FTE_UTIL_PKG.GET_DATA('MODE_OF_TRANSPORTATION', p_values);
      l_com_class     	:= FTE_UTIL_PKG.GET_DATA('COMMODITY_CLASS', p_values);
      l_basis        	:= FTE_UTIL_PKG.GET_DATA('BASIS', p_values);
      l_view_flag    	:= FTE_UTIL_PKG.GET_DATA('RATE_CHART_VIEW_FLAG', p_values);
      l_distance     	:= FTE_UTIL_PKG.GET_DATA('DISTANCE', p_values);
      l_distance_uom 	:= FTE_UTIL_PKG.GET_DATA('DISTANCE_UOM', p_values);
      l_transit      	:= FTE_UTIL_PKG.GET_DATA('TRANSIT_TIME', p_values);
      l_transit_uom  	:= FTE_UTIL_PKG.GET_DATA('TRANSIT_TIME_UOM', p_values);
      l_effect_date  	:= FTE_UTIL_PKG.GET_DATA('START_DATE', p_values);
      l_expiry_date  	:= FTE_UTIL_PKG.GET_DATA('END_DATE', p_values);
      l_editable_flag 	:= FTE_UTIL_PKG.GET_DATA('EDITABLE_FLAG', p_values);

      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Lane number', l_lane_number);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier name', l_carrier_name);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate chart name', l_rate_chart_name);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Mode of transportation', l_mode);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Commodity class', l_com_class);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Basis', l_basis);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate chart view flag', l_view_flag);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Distance', l_distance);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Distance uom', l_distance_uom);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Transit', l_transit);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Transit UOM', l_transit_uom);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Start date', l_effect_date);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'End date', l_expiry_date);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Editable flag', l_editable_flag);
      END IF;

      -- this boolean variable is true when :
      -- we load a TL_SERVICE and the Rate Chart is already in the system.
      -- In that case, we need to create the Service and we need to create a row into i
      -- FTE_LANE_RATE_CHARTS to attach the Service to the Rate Chart.

      IF (l_carrier_name IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_CAT_CARRIER_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		   p_msg		=> x_error_msg,
                   		   p_category		=> 'A',
				   p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
        RETURN;
      ELSE
        VALIDATE_CARRIER(p_carrier_name	=> l_carrier_name,
	    	         p_line_number	=> p_line_number,
		         p_carrier_id	=> l_carrier_id,
		         x_status	=> x_status,
		         x_error_msg	=> x_error_msg);

        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          RETURN;
        END IF;

        p_lane_tbl(l_count).carrier_id := l_carrier_id;
      END IF;

      IF (l_lane_number IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_CAT_LANE_NUMBER_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		   p_msg		=> x_error_msg,
                   		   p_category		=> 'A',
				   p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
 	RETURN;
      END IF;

      IF (p_action = 'UPDATE') THEN
        IF (l_lane_number IS NULL) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_CAT_LANE_NUMBER_MISSING');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		     p_msg		=> x_error_msg,
                   		     p_category		=> 'A',
				     p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
  	  RETURN;
        ELSE
          l_old_lane_id := FTE_LANE_PKG.GET_LANE_ID(l_lane_number, l_carrier_id);

          IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Old Lane ID', l_old_lane_id);
          END IF;

	  p_lane_tbl(l_count).lane_id := l_old_lane_id;
      	  p_lane_tbl(l_count).lane_number := l_lane_number;
	  IF (l_old_lane_id = -1) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_CAT_LANE_NUMBER_INVALID',
                                                P_Tokens => STRINGARRAY('SERVICE_NUMBER'),
					        P_values => STRINGARRAY(l_lane_number));

            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		       p_msg	 	=> x_error_msg,
                   		       p_category	=> 'C',
				       p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
  	    RETURN;
 	  END IF;
        END IF;
      ELSIF (p_action = 'SYNC') THEN
        -- if laneNumber is not specified, it's assumed to be ADD
        IF (l_lane_number IS NULL) THEN
      	  l_old_lane_id := -1;
	  p_lane_tbl(l_count).lane_id := FTE_LANE_PKG.GET_NEXT_LANE_ID;
        ELSE
          -- To determine if it's ADD or UPDATE
          -- if there's a lane with the given laneNumber and carrirName
          -- oldLaneId is not -1, which means UPDATE
	  l_old_lane_id := FTE_LANE_PKG.GET_LANE_ID(l_lane_number, l_carrier_id);
	  IF (l_old_lane_id = -1) THEN
	    p_lane_tbl(l_count).lane_id := FTE_LANE_PKG.GET_NEXT_LANE_ID;
	  ELSE
	    p_lane_tbl(l_count).lane_id := l_old_lane_id;
	    p_lane_tbl(l_count).action := 'UPDATE';
	  END IF;
 	  p_lane_tbl(l_count).lane_number := l_lane_number;
        END IF;
      ELSIF (p_action = 'DELETE') THEN
        l_old_lane_id := FTE_LANE_PKG.GET_LANE_ID(l_lane_number, l_carrier_id);
        p_lane_tbl(l_count).lane_id := l_old_lane_id;
        IF (l_old_lane_id = -1) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_CAT_LANE_NUMBER_INVALID',
                                              P_Tokens => STRINGARRAY('SERVICE_NUMBER'),
					      P_values => STRINGARRAY(l_lane_number));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		     p_msg	  	=> x_error_msg,
                   		     p_category		=> 'C',
				     p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
  	  RETURN;
        END IF;
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        RETURN;
      ELSIF (p_action = 'ADD') THEN

        IF (-1 <> FTE_LANE_PKG.GET_LANE_ID(l_lane_number, l_carrier_id)) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_CAT_LANE_REF_EXISTS',
                                              P_Tokens => STRINGARRAY('SERVICE_NUMBER'),
					      P_values => STRINGARRAY(l_lane_number));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		     p_msg	  	=> x_error_msg,
                   		     p_category		=> 'D',
				     p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
  	  RETURN;
        ELSE
	  p_lane_tbl(l_count).lane_id := FTE_LANE_PKG.GET_NEXT_LANE_ID;
	  p_lane_tbl(l_count).lane_number := l_lane_number;
        END IF;
      END IF;

      -- validate Origin, Destination, Mode only for ADD
      IF (l_old_lane_id = -1) THEN
        -- set origin and  destination

        l_region_info.city             := FTE_UTIL_PKG.GET_DATA('ORIGIN_CITY', p_values);
        l_region_info.state            := FTE_UTIL_PKG.GET_DATA('ORIGIN_STATE', p_values);
        l_region_info.country          := FTE_UTIL_PKG.GET_DATA('ORIGIN_COUNTRY', p_values);
        l_region_info.postal_code_from := FTE_UTIL_PKG.GET_DATA('ORIGIN_POSTAL_CODE_FROM', p_values);
        l_region_info.postal_code_to   := FTE_UTIL_PKG.GET_DATA('ORIGIN_POSTAL_CODE_TO', p_values);

        l_region_info.zone             := FTE_UTIL_PKG.GET_DATA('ORIGIN_ZONE', p_values);

        IF (l_region_info.country IS NULL) THEN

	  l_zone_id := FTE_REGION_ZONE_LOADER.GET_ZONE_ID(l_region_info.zone);

	  IF (l_zone_id IS NULL OR l_zone_id = -1) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_LANE_ORIGIN_MISSING');

	    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		       p_msg		=> x_error_msg,
                   		       p_category	=> 'A',
				       p_line_number	=> p_line_number);

            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 2;
            RETURN;
	  ELSE
              p_lane_tbl(l_count).origin_id := l_zone_id;
	  END IF;

        ELSE

          l_region_id := FTE_REGION_ZONE_LOADER.GET_REGION_ID(p_region_info => l_region_info);

	  IF (l_region_id IS NULL OR l_region_id = -1) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 		=> 'FTE_CAT_REGION_UNKNOWN',
				        	p_tokens	=> STRINGARRAY('REGION_NAME'),
				        	p_values	=> STRINGARRAY(l_region_info.country ||' '||
								       l_region_info.state ||' '||
								       l_region_info.city));
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		       p_msg		=> x_error_msg,
                   		       p_category	=> 'D',
				       p_line_number	=> p_line_number);

            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 2;
            RETURN;
          END IF;

	  --+
	  -- Inserting the region in wsh_zone_regions
          --+
    	  IF (FTE_REGION_ZONE_LOADER.INSERT_PARTY_REGION(p_region_id        => l_region_id,
				                         p_parent_region_id => l_region_id,
				                         p_supplier_id      => -1,
				                         p_validate_flag    => TRUE,
				                         p_postal_code_from => l_region_info.postal_code_from,
				                         p_postal_code_to   => l_region_info.postal_code_to) = -1) THEN
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 2;
            RETURN;
          END IF;

	  p_lane_tbl(l_count).origin_id := l_region_id;

        END IF;

        l_region_info.city     := FTE_UTIL_PKG.GET_DATA('DESTINATION_CITY', p_values);
        l_region_info.state    := FTE_UTIL_PKG.GET_DATA('DESTINATION_STATE', p_values);
        l_region_info.country  := FTE_UTIL_PKG.GET_DATA('DESTINATION_COUNTRY', p_values);
        l_region_info.postal_code_from := FTE_UTIL_PKG.GET_DATA('DESTINATION_POSTAL_CODE_FROM', p_values);
        l_region_info.postal_code_to   := FTE_UTIL_PKG.GET_DATA('DESTINATION_POSTAL_CODE_TO', p_values);
        l_region_info.zone     := FTE_UTIL_PKG.GET_DATA('DESTINATION_ZONE', p_values);

        IF (l_region_info.country IS NULL) THEN

	  l_zone_id := FTE_REGION_ZONE_LOADER.GET_ZONE_ID(l_region_info.zone);

	  IF (l_zone_id IS NULL OR l_zone_id = -1 ) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name => 'FTE_LANE_DEST_MISSING');

	    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		       p_msg		=> x_error_msg,
                   		       p_category	=> 'A',
				       p_line_number	=> p_line_number);

            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 2;
            RETURN;
	  ELSE
              p_lane_tbl(l_count).destination_id := l_zone_id;
	  END IF;

        ELSE
          l_region_id := FTE_REGION_ZONE_LOADER.GET_REGION_ID(p_region_info => l_region_info);

	  IF (l_region_id IS NULL OR l_region_id = -1) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 		=> 'FTE_CAT_REGION_UNKNOWN',
				        	p_tokens	=> STRINGARRAY('REGION_NAME'),
				        	p_values	=> STRINGARRAY(l_region_info.country ||' '||
								       l_region_info.state ||' '||
								       l_region_info.city));
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		       p_msg	 	=> x_error_msg,
                   		       p_category	=> 'D',
				       p_line_number	=> p_line_number);

            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 2;
            RETURN;
          END IF;

	  --inserting the region in wsh_zone_regions
    	  IF (FTE_REGION_ZONE_LOADER.INSERT_PARTY_REGION(p_region_id        => l_region_id,
				  p_parent_region_id => l_region_id,
				  p_supplier_id      => -1,
				  p_validate_flag    => TRUE,
				  p_postal_code_from => l_region_info.postal_code_from,
				  p_postal_code_to   => l_region_info.postal_code_to) = -1) THEN
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 2;
            RETURN;
          END IF;

	  p_lane_tbl(l_count).destination_id := l_region_id;


        END IF;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
          FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Origin ID', p_lane_tbl(l_count).origin_id);
          FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Destination ID', p_lane_tbl(l_count).destination_id);
	END IF;

        -- Validation for MODE_OF_TRANSPORTATION

        IF (l_mode IS NULL) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_MODE_OF_TRANS_MISSING');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		     p_msg		=> x_error_msg,
                   		     p_category		=> 'A',
				     p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;
        ELSE
          VALIDATE_MODE_OF_TRANS(p_mode 	=> l_mode,
			         p_line_number  => p_line_number,
			         p_carrier_id 	=> l_carrier_id,
			         p_mode_code	=> l_mode_code,
			         x_status	=> x_status,
			         x_error_msg	=> x_error_msg);

	  IF (x_status <> -1) THEN
	    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	    RETURN;
	  END IF;

	  IF (l_mode_code = 'TRUCK') THEN
	    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_SERVICE_NO_TL');
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		       p_msg		=> x_error_msg,
                   		       p_category	=> 'D',
				       p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
	    RETURN;
	  END IF;

  	  p_lane_tbl(l_count).mode_of_transportation_code := l_mode_code;

        END IF;

        -- Validation for DISTANCE and DISTANCE_UOM
        IF (l_distance IS NOT NULL) THEN

          IF (to_number(l_distance) < 0) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_CAT_DISTANCE_NEG');
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		       p_msg		=> x_error_msg,
                   		       p_category	=> 'D',
				       p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
	    RETURN;
	  ELSE
	    p_lane_tbl(l_count).distance := l_distance;
	  END IF;

          -- If distance is a valid number, valid UOM should be specified.
          IF (l_distance_uom IS NULL) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_CAT_UOM_MISSING');
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		       p_msg	  	=> x_error_msg,
                   		       p_category	=> 'A',
				       p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
  	    RETURN;
  	  ELSE
   	    VALIDATE_UOM(p_uom		=> l_distance_uom,
		         p_class	=> 'Length',
		         p_line_number 	=> p_line_number,
		         p_uom_code 	=> l_distance_uom_code,
		         x_status	=> x_status,
		         x_error_msg	=> x_error_msg);
            IF (x_status <> -1) THEN
              FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	      RETURN;
            END IF;
	    p_lane_tbl(l_count).distance_uom := l_distance_uom_code;

   	  END IF;
        END IF;

        -- Validation for TRANSIT_TIME and TRANSIT_TIME_UOM
        IF (l_transit IS NOT NULL) THEN
          IF (to_number(l_transit) < 0) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_CAT_TRANSIT_TIME_NEG');
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		       p_msg	  	=> x_error_msg,
                   		       p_category	=> 'D',
				       p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
  	    RETURN;
  	  ELSE
	    p_lane_tbl(l_count).transit_time := l_transit;
	  END IF;
    	  -- If transit is a valid number, valid UOM should be specified.
          IF (l_transit_uom IS NULL) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_CAT_UOM_MISSING');
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		       p_msg	  	=> x_error_msg,
                   		       p_category	=> 'A',
				       p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
	    RETURN;
	  ELSE
 	    VALIDATE_UOM(p_uom		=> l_transit_uom,
		         p_class	=> 'Time',
		         p_line_number 	=> p_line_number,
		         p_uom_code 	=> l_transit_time_uom_code,
		         x_status	=> x_status,
		         x_error_msg	=> x_error_msg);
            IF (x_status <> -1) THEN
              FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	      RETURN;
            END IF;
	    p_lane_tbl(l_count).transit_time_uom := l_transit_time_uom_code;

	  END IF;
        END IF;
      END IF;

      --if treated as update, set the basisflag to true to avoid error thrown later in DataLoader.java
      IF (l_old_lane_id <> -1) THEN
        p_lane_tbl(l_count).basis_flag := true;
        VERIFY_LANE_BASIS(p_lane_id 	=> l_old_lane_id,
			  p_lane_tbl	=> p_lane_tbl,
			  p_line_number	=> p_line_number,
			  x_status	=> x_status,
			  x_error_msg	=> x_error_msg);
        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	  RETURN;
        END IF;
      END IF;

      -- Validation for BASIS
      IF (l_basis IS NULL) THEN
        IF (NOT p_lane_tbl(l_count).basis_flag OR l_old_lane_id = -1) THEN
	  --if the old lane doesn't have a basis or a new lane, then it's okay to put null
	  p_lane_tbl(l_count).line_number := p_line_number;
        ELSIF (l_old_lane_id <> -1) THEN --if old lane does have basis and this is a update of it, then error
          x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_BASIS_MISSING');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		     p_msg	  	=> x_error_msg,
                   		     p_category		=> 'A',
				     p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
          RETURN;
        END IF;
      ELSE
        l_basis_code := FTE_UTIL_PKG.GET_LOOKUP_CODE('FTE_BASES', l_basis);
        IF (l_basis_code IS NOT NULL) THEN
	  p_lane_tbl(l_count).basis := l_basis_code;
	  p_lane_tbl(l_count).basis_flag := true;
        ELSE
          x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_BASIS_INVALID',
				              p_tokens	=> STRINGARRAY('BASIS'),
				 	      p_values	=> STRINGARRAY(l_basis));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		     p_msg  		=> x_error_msg,
                   		     p_category		=> 'D',
				     p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
  	  RETURN;
        END IF;
      END IF;

      -- added to check if container_all is the basis
      IF (l_basis = 'CONTAINER_ALL') THEN
        p_lane_tbl(l_count).container_all_flag := TRUE;
      END IF;

      -- Validation for COMMODITY_CLASS
      IF (l_com_class IS NULL) THEN
        p_lane_tbl(l_count).comm_fc_class_code := '';
      ELSE
        l_com_class_code := FTE_UTIL_PKG.GET_LOOKUP_CODE('WSH_COMMODITY_CLASSIFICATION', l_com_class);
        IF (l_com_class_code IS NOT NULL) THEN
          p_lane_tbl(l_count).comm_fc_class_code := l_com_class_code;
        ELSE
          x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_COMM_CLASS_INVALID',
				  	      p_tokens	=> STRINGARRAY('COMMODITY_CLASS'),
				  	      p_values	=> STRINGARRAY(l_com_class));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		     p_msg	  	=> x_error_msg,
                   		     p_category		=> 'D',
				     p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
  	  RETURN;
        END IF;
      END IF;

      -- Validation for EFFECTIVE_DATE

      VALIDATE_DATE(p_date => l_effect_date,
 		    p_line_number => p_line_number,
		    x_status => x_status,
		    x_error_msg => x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        RETURN;
      END IF;

      p_lane_tbl(l_count).effective_date := l_effect_date;

      -- Validation for EXPIRY_DATE

      VALIDATE_DATE(p_date => l_expiry_date,
		    p_line_number => p_line_number,
	  	    x_status => x_status,
		    x_error_msg => x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        RETURN;
      END IF;

      p_lane_tbl(l_count).expiry_date := l_expiry_date;

      -- Validation for RATE_CHART_VIEW_FLAG
      IF (l_view_flag IS NULL) THEN
        --default pricelist_view_flag only when we are adding. else leave it as it was.
        IF (p_action = 'ADD') THEN
	  p_lane_tbl(l_count).pricelist_view_flag := 'N';
        END IF;
      ELSIF (l_view_flag = 'Y' OR l_view_flag = 'N') THEN
	p_lane_tbl(l_count).pricelist_view_flag := l_view_flag;
      ELSE
        x_error_msg := FTE_UTIL_PKG.GET_MSG(P_Name 	=> 'FTE_PRICELIST_VIEW_INVALID',
				    	    p_tokens	=> STRINGARRAY('VIEW_FLAG'),
					    p_values	=> STRINGARRAY(l_view_flag));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		   p_msg	  	=> x_error_msg,
                   		   p_category		=> 'D',
				   p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
        RETURN;
      END IF;

      IF (l_old_lane_id = -1) THEN -- add

        IF (l_editable_flag IS NULL) THEN
	  p_lane_tbl(l_count).editable_flag := 'Y';
        ELSE
	  p_lane_tbl(l_count).editable_flag := l_editable_flag;
        END IF;

        IF (l_lane_number IS NULL) THEN
	  l_temp_number := p_lane_tbl(l_count).lane_id || '-' || l_carrier_name;
	  IF (LENGTH(l_temp_number) > 30) THEN
	    l_lane_number := SUBSTR(l_temp_number, 1, 30);
	  ELSE
	    l_lane_number := l_temp_number;
	  END IF;

	  p_lane_tbl(l_count).lane_number := l_lane_number;
        END IF;
      END IF;

    --    VALIDATE_ELEMENTS(LANETABLE, data, encoding, errors);  check length

    ELSIF(p_type = 'RATE_CHART') THEN
	VALIDATE_LANE_RATE_CHART(p_values	=> p_values,
				 p_line_number	=> p_line_number,
				 p_action	=> p_action,
				 p_lane_tbl	=> p_lane_tbl,
				 p_lane_rate_chart_tbl	=> p_lane_rate_chart_tbl,
				 x_status	=> x_status,
				 x_error_msg	=> x_error_msg);
    ELSIF(p_type = 'SERVICE_LEVEL') THEN
	VALIDATE_LANE_SERVICE_LEVEL(p_values		=> p_values,
				    p_line_number	=> p_line_number,
				    p_type		=> p_type,
				    p_action		=> p_action,
				    p_lane_tbl		=> p_lane_tbl,
				    p_lane_service_tbl	=> p_lane_service_tbl,
				    x_status		=> x_status,
				    x_error_msg		=> x_error_msg);
    ELSIF(p_type = 'COMMODITY_TYPE') THEN
	VALIDATE_LANE_COMMODITY(p_values		=> p_values,
				p_line_number		=> p_line_number,
				p_type			=> p_type,
				p_action		=> p_action,
				p_lane_tbl		=> p_lane_tbl,
				p_lane_commodity_tbl	=> p_lane_commodity_tbl,
				x_status		=> x_status,
				x_error_msg		=> x_error_msg);
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
             			 p_msg        	=> x_error_msg,
             			 p_category    	=> 'O',
	        		 p_line_number 	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_SERVICE;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_SERVICE_RATING_SETUP
  --
  -- Purpose: does validation for one line in service rating setup block
  --
  -- IN parameters:
  --	1. p_values:		pl/sql table for the service rating setup line
  --	2. p_line_number: 	line number of current line
  --   	3. p_pre_lane_number:	previous lane's line number
  --
  -- OUT parameters:
  --	1. p_prc_parameter_tbl: pl/sql table for pricing parameter
  --	2. p_deficit_wt:	deficit weight parameter
  --	3. p_lane_function:	lane function
  --	4. p_lane_number:	lane number
  --	5. p_action:		action value of the line
  --	6. x_status:		status of the processing, -1 means no error
  --	7. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_SERVICE_RATING_SETUP(p_values		IN		FTE_BULKLOAD_PKG.data_values_tbl,
					  p_line_number		IN		NUMBER,
					  p_pre_lane_number	IN		VARCHAR2,
					  p_prc_parameter_tbl	IN OUT	NOCOPY	FTE_LANE_PKG.prc_parameter_tbl,
					  p_deficit_wt		IN OUT	NOCOPY	BOOLEAN,
					  p_lane_function	IN OUT	NOCOPY	VARCHAR2,
					  p_lane_number		OUT NOCOPY	VARCHAR2,
					  p_action		OUT NOCOPY	VARCHAR2,
					  x_status		OUT NOCOPY	NUMBER,
					  x_error_msg		OUT NOCOPY	VARCHAR2) IS

  l_old_function 	VARCHAR2(100);
  l_temp		VARCHAR2(100);
  l_carrier_name 	VARCHAR2(200);
  l_type		VARCHAR2(100);
  l_subtype		VARCHAR2(100);
  l_name		VARCHAR2(200);
  l_value_from		VARCHAR2(100);
  l_value_to		VARCHAR2(100);
  l_uom			VARCHAR2(100);
  l_currency		VARCHAR2(100);
  l_carrier_id 		NUMBER := -1;
  l_uom_code		VARCHAR2(100) := '';
  l_parameter_data_type VARCHAR2(100);
  l_data_keys		STRINGARRAY := STRINGARRAY();
  l_data_values		STRINGARRAY := STRINGARRAY();
  l_count		NUMBER;
  l_lane_id		NUMBER := -1;
  l_parameter_id 	NUMBER;
  l_prc_parameter_id 	NUMBER;

  CURSOR GET_PRC_PARAMETER (p_lane_id IN NUMBER, p_parameter_id IN NUMBER) IS
    SELECT PARAMETER_INSTANCE_ID
      FROM FTE_PRC_PARAMETERS
     WHERE lane_id = p_lane_id
       AND parameter_id = p_parameter_id;

  CURSOR GET_PARAMETER_DATATYPE (p_parameter_id IN NUMBER) IS
    SELECT parameter_datatype
      FROM FTE_PRC_PARAMETER_DEFAULTS
     WHERE parameter_id = p_parameter_id;

  CURSOR GET_FUNCTION(p_lane_id IN NUMBER, p_parameter_id NUMBER) IS
    SELECT value_from
      FROM FTE_PRC_PARAMETERS
     WHERE lane_id = p_lane_id
       AND parameter_id = p_parameter_id;

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_SERVICE_RATING_SETUP';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    p_action 		:= FTE_UTIL_PKG.GET_DATA('ACTION', p_values);
    p_lane_number 	:= FTE_UTIL_PKG.GET_DATA('SERVICE_NUMBER', p_values);
    l_carrier_name 	:= FTE_UTIL_PKG.GET_DATA('CARRIER_NAME', p_values);
    l_type 		:= FTE_UTIL_PKG.GET_DATA('TYPE', p_values);
    l_subtype 		:= FTE_UTIL_PKG.GET_DATA('SUBTYPE', p_values);
    l_name 		:= FTE_UTIL_PKG.GET_DATA('NAME', p_values);
    l_value_from 	:= FTE_UTIL_PKG.GET_DATA('VALUE_FROM', p_values);
    l_value_to 		:= FTE_UTIL_PKG.GET_DATA('VALUE_TO', p_values);
    l_uom 		:= FTE_UTIL_PKG.GET_DATA('UOM', p_values);
    l_currency 		:= FTE_UTIL_PKG.GET_DATA('CURRENCY', p_values);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Type', l_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', p_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Pre Lane Number', p_pre_lane_number);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Lane function', p_lane_function);
      IF (p_deficit_wt) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Deficit Wt', 'TRUE');
      ELSE
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Deficit Wt', 'FALSE');
      END IF;
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Lane Number', p_lane_number);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier name', l_carrier_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Subtype', l_subtype);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Name', l_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Value From', l_value_from);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Value To', l_value_to);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'UOM', l_uom);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Currency', l_currency);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    p_deficit_wt := FALSE;

    -- ACTION
    VALIDATE_ACTION(p_action	=> p_action,
		    p_type	=> 'SERVICE_RATING_SETUP',
		    p_line_number => p_line_number,
		    x_status	=> x_status,
		    x_error_msg	=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    -- carrier name validation
    VALIDATE_CARRIER(p_carrier_name	=> l_carrier_name,
		     p_line_number	=> p_line_number,
		     p_carrier_id	=> l_carrier_id,
		     x_status		=> x_status,
		     x_error_msg	=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    -- LANE_NUMBER
    VALIDATE_LANE_NUMBER(p_lane_number	=> p_lane_number,
		  	 p_carrier_id	=> l_carrier_id,
			 p_line_number	=> p_line_number,
			 p_lane_id	=> l_lane_id,
			 x_status	=> x_status,
			 x_error_msg	=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    -- TYPE
    IF (l_type IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_TYPE_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		  p_msg  		=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    ELSE
      l_type := UPPER(l_type);
      IF (l_type NOT IN ('PARAMETER', 'RULE')) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_RATING_TYPE_INVALID');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;
    END IF;

    IF (l_subtype IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_SUBTYPE_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		  p_msg  		=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    ELSE
      l_subtype := UPPER(l_subtype);
    END IF;

    -- NAME
    IF (l_name IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_NAME_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		  p_msg  		=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    ELSE
      l_name := UPPER(l_name);
    END IF;

    -- VALUE
    IF (l_value_from IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_VALUE_FROM_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		  p_msg  		=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;

    IF (l_uom IS NULL) THEN
      l_uom_code := '';
    ELSIF (l_type = 'PARAMETER' AND l_subtype = 'DIM_WT' AND l_name = 'MIN_PACKAGE_VOLUME') THEN
      VALIDATE_UOM(p_uom	=> l_uom,
		   p_class	=> 'Volume',
		   p_line_number => p_line_number,
		   p_uom_code 	=> l_uom_code,
		   x_status	=> x_status,
		   x_error_msg	=> x_error_msg);
      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	RETURN;
      END IF;
    ELSE
      VALIDATE_UOM(p_uom	=> l_uom,
		   p_class	=> 'Weight',
		   p_line_number => p_line_number,
		   p_uom_code 	=> l_uom_code,
		   x_status	=> x_status,
		   x_error_msg	=> x_error_msg);
      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	RETURN;
      END IF;
    END IF;

    IF (l_type = 'PARAMETER' AND l_subtype = 'SERVICE' AND l_name = 'SERVICE_FUNCTION') THEN
      l_subtype := 'LANE';
      l_name := 'LANE_FUNCTION';
    END IF;

    -- validate once more not to throw error with PRICING_OBJECTIVE
    -- from validateName since it's known as RATING_OBJECTIVE to the user
    IF (l_type = 'RULE' AND l_name = 'RATING_OBJECTIVE' AND
        l_subtype IN ('SC_CB', 'SC_WB', 'SC_VB', 'MC_CB', 'MC_WB', 'MC_VB', 'MC_MY', 'MC_MN')) THEN
      l_name := 'PRICING_OBJECTIVE';
    END IF;

    -- First Parameter for New Lane should be LANE/LANE_FUNCTION
    IF (p_lane_number <> nvl(p_pre_lane_number, p_lane_number || p_lane_number)) THEN
      -- First Parameter for New Lane should be LANE/LANE_FUNCTION
      IF (l_type <> 'PARAMETER' OR l_subtype <> 'LANE' OR l_name <> 'LANE_FUNCTION') THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_NAME_FIRST');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      ELSE
        IF (UPPER(l_value_from) NOT IN ('NONE', 'LTL', 'PARCEL', 'FLAT')) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_VALUE_FROM_LANE');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                      		      p_msg	  	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
 	  RETURN;
	ELSE
          p_lane_function := l_value_from;

  	  l_parameter_id := VALIDATE_NAME(p_type		=> l_type,
			 		  p_lane_function 	=> 'NONE',
			 		  p_subtype		=> l_subtype,
			 		  p_name		=> l_name,
                         		  p_line_number		=> p_line_number,
			 		  p_deficit_wt		=> p_deficit_wt,
			 		  x_status		=> x_status,
			 		  x_error_msg		=> x_error_msg);

          IF (x_status <> -1) THEN
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	    RETURN;
          END IF;

	  OPEN GET_FUNCTION(l_lane_id, l_parameter_id);
	  FETCH GET_FUNCTION INTO l_old_function;
	  CLOSE GET_FUNCTION;
          IF (l_old_function IS NOT NULL AND l_old_function <> p_lane_function) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_NO_FUNC_CHANGE');
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                      		        p_msg	  	=> x_error_msg,
                   		        p_category	=> 'D',
				        p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
	    RETURN;
	  END IF;
	END IF;
      END IF;
    ELSE
      IF (l_subtype = 'LANE' AND l_name = 'LANE_FUNCTION') THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_NAME_DUPLICATE');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                      		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;
    END IF;

    l_parameter_id := VALIDATE_NAME(p_type		=> l_type,
			 	    p_lane_function 	=> p_lane_function,
			 	    p_subtype		=> l_subtype,
			 	    p_name		=> l_name,
                         	    p_line_number	=> p_line_number,
			 	    p_deficit_wt	=> p_deficit_wt,
			 	    x_status		=> x_status,
			 	    x_error_msg		=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    OPEN GET_PARAMETER_DATATYPE(l_parameter_id);
    FETCH GET_PARAMETER_DATATYPE INTO l_parameter_data_type;
    CLOSE GET_PARAMETER_DATATYPE;

    IF (l_parameter_id = -1) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_NAME_INVALID');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		 p_msg  	=> x_error_msg,
                   		 p_category	=> 'D',
				 p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    ELSE
      IF (l_name = 'WT_UOM') THEN
        VALIDATE_UOM(p_uom		=> l_value_from,
		     p_class		=> 'Weight',
		     p_line_number 	=> p_line_number,
		     p_uom_code 	=> l_temp,
		     x_status		=> x_status,
		     x_error_msg	=> x_error_msg);
        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	  RETURN;
        END IF;
      ELSIF (l_name = 'VOL_UOM') THEN
 	VALIDATE_UOM(p_uom		=> l_value_from,
		     p_class		=> 'Volume',
		     p_line_number 	=> p_line_number,
		     p_uom_code 	=> l_temp,
		     x_status		=> x_status,
		     x_error_msg	=> x_error_msg);
        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	  RETURN;
        END IF;
      ELSIF (l_name = 'DIM_UOM') THEN
 	VALIDATE_UOM(p_uom		=> l_value_from,
		     p_class		=> 'Length',
		     p_line_number 	=> p_line_number,
		     p_uom_code 	=> l_temp,
		     x_status		=> x_status,
		     x_error_msg	=> x_error_msg);
        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
     	  RETURN;
        END IF;
      ELSIF (l_name = 'GROUPING_LEVEL') THEN
        l_temp := FTE_UTIL_PKG.GET_LOOKUP_CODE('FTE_PRC_GROUPING_LEVEL', l_value_from);
        IF (l_temp IS NULL) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_GROUPING_LEVEL_INVALID',
					      p_tokens		=> STRINGARRAY('VALUE'),
					      p_values		=> STRINGARRAY(l_value_from));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		      p_msg	  	=> x_error_msg,
                   		      p_category	=> 'A',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;
	END IF;
      ELSIF (l_name = 'COMMODITY_AGGREGATION') THEN
        l_temp := FTE_UTIL_PKG.GET_LOOKUP_CODE('FTE_PRC_COMM_AGGREGATION', l_value_from);
        IF (l_temp IS NULL) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_COMM_AGGREGATION_INVALID',
					      p_tokens		=> STRINGARRAY('VALUE'),
					      p_values		=> STRINGARRAY(l_value_from));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		      p_msg	  	=> x_error_msg,
                   		      p_category	=> 'A',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;
	END IF;
      ELSIF (l_name = 'PRICING_OBJECTIVE') THEN
        l_temp := FTE_UTIL_PKG.GET_LOOKUP_CODE('FTE_PRC_PRICING_OBJECTIVE', l_value_from);
        IF (l_temp IS NULL) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_PRICING_OBJECTIVE_INVALID',
					      p_tokens		=> STRINGARRAY('VALUE'),
					      p_values		=> STRINGARRAY(l_value_from));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		      p_msg	  	=> x_error_msg,
                   		      p_category	=> 'A',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;
	END IF;
      END IF;
      IF (l_temp IS NOT NULL) THEN
        l_value_from := l_temp;
      END IF;
    END IF;

    OPEN GET_PRC_PARAMETER(l_lane_id, l_parameter_id);
    FETCH GET_PRC_PARAMETER INTO l_prc_parameter_id;
    CLOSE GET_PRC_PARAMETER;

    l_count := p_prc_parameter_tbl.COUNT+1;

    IF (p_action IN ('SYNC', 'ADD', 'UPDATE')) THEN
      -- Added

      IF (l_parameter_data_type IS NOT NULL AND l_parameter_data_type = 'NUMBER') THEN
        p_prc_parameter_tbl(l_count).value_from := fnd_number.canonical_to_number(l_value_from);
      ELSE
        p_prc_parameter_tbl(l_count).value_from := l_value_from;
      END IF;

      p_prc_parameter_tbl(l_count).value_to := l_value_to;
      p_prc_parameter_tbl(l_count).uom_code := l_uom_code;
      p_prc_parameter_tbl(l_count).currency_code := l_currency;

      -- If it's already defined,
      IF (l_prc_parameter_id <> -1) THEN
        IF (p_action = 'ADD' AND (NOT p_deficit_wt)) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_ADD_ERROR',
					      p_tokens		=> STRINGARRAY(''),
					      p_values		=> STRINGARRAY(p_lane_function||':'||l_type||','||l_subtype||','||l_name));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		      p_msg	  	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
          RETURN;
	END IF;
        p_action := 'UPDATE';
      ELSE
        IF (p_action = 'UPDATE') THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_UPDATE_ERROR',
					      p_tokens		=> STRINGARRAY(''),
					      p_values		=> STRINGARRAY(p_lane_function||':'||l_type||','||l_subtype||','||l_name));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		      p_msg	  	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
          RETURN;
	END IF;
        p_action := 'ADD';
      END IF;

      IF (p_deficit_wt) THEN
        p_action := 'ADD';
      END IF;

    ELSIF (p_action = 'DELETE') THEN
      IF (p_deficit_wt OR l_prc_parameter_id <> -1) THEN
    	p_prc_parameter_tbl(l_count).parameter_instance_id := l_prc_parameter_id;
    	p_prc_parameter_tbl(l_count).lane_id := l_lane_id;
    	p_prc_parameter_tbl(l_count).parameter_id := l_parameter_id;
      ELSE
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_UPDATE_ERROR',
					    p_tokens		=> STRINGARRAY(''),
					    p_values		=> STRINGARRAY(p_lane_function||':'||l_type||','||l_subtype||','||l_name));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;
    END IF;

    IF (p_action = 'ADD') THEN
      l_prc_parameter_id := FTE_LANE_PKG.GET_NEXT_PRC_PARAMETER_ID;
      p_prc_parameter_tbl(l_count).parameter_instance_id := l_prc_parameter_id;
      p_prc_parameter_tbl(l_count).lane_id := l_lane_id;
      p_prc_parameter_tbl(l_count).parameter_id := l_parameter_id;
    ELSIF (p_action = 'UPDATE') THEN
      p_prc_parameter_tbl(l_count).parameter_instance_id := l_prc_parameter_id;
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      IF (GET_PRC_PARAMETER%ISOPEN) THEN
	CLOSE GET_PRC_PARAMETER;
      END IF;
      IF (GET_PARAMETER_DATATYPE%ISOPEN) THEN
	CLOSE GET_PARAMETER_DATATYPE;
      END IF;
      IF (GET_FUNCTION%ISOPEN) THEN
	CLOSE GET_FUNCTION;
      END IF;
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_SERVICE_RATING_SETUP;

  ----------------------------------------------------------------------------
  -- PROCEDURE VALIDATE_SCHEDULE
  --
  -- Purpose: does validation for one line in schedule block
  --
  -- IN parameters:
  --	1. p_values:		pl/sql table for schedule line
  --	2. p_line_number: 	line number of current line
  --
  -- OUT parameters:
  --	1. p_schedule_tbl:	pl/sql table for schedules
  --	2. p_action:		action value of the line
  --	3. x_status:		status of the processing, -1 means no error
  --	4. x_error_msg:		error message if any.
  ----------------------------------------------------------------------------
  PROCEDURE VALIDATE_SCHEDULE(p_values		IN		FTE_BULKLOAD_PKG.data_values_tbl,
			      p_line_number	IN		NUMBER,
			      p_schedule_tbl	IN OUT NOCOPY	FTE_LANE_PKG.schedule_tbl,
			      p_action		OUT NOCOPY	VARCHAR2,
			      x_status		OUT NOCOPY	NUMBER,
			      x_error_msg	OUT NOCOPY	VARCHAR2) IS

  l_indicator_value 	NUMBER := 0;
  l_old_freq_type	VARCHAR2(100);
  l_freq_code		VARCHAR2(100);
  l_freq_arr		VARCHAR2(200);
  l_departure		VARCHAR2(200);
  l_arrival		VARCHAR2(200);
  l_transit_uom_code	VARCHAR2(100);
  l_carrier_name	VARCHAR2(200);
  l_lane_number		VARCHAR2(200);
  l_vessel_type		VARCHAR2(200);
  l_vessel_name		VARCHAR2(200);
  l_arrival_dt		VARCHAR2(200);
  l_arrival_tm		VARCHAR2(200);
  l_departure_dt	VARCHAR2(200);
  l_departure_tm	VARCHAR2(200);
  l_indicator		VARCHAR2(200);
  l_freq_type		VARCHAR2(200);
  l_frequency		VARCHAR2(200);
  l_transit		VARCHAR2(200);
  l_transit_uom		VARCHAR2(200);
  l_port_loading	VARCHAR2(200);
  l_port_discharge	VARCHAR2(200);
  l_start_date		VARCHAR2(200);
  l_end_date		VARCHAR2(200);
  l_count		NUMBER;
  l_carrier_id		NUMBER;
  l_tmp_tm		VARCHAR2(25);
  l_old_schedule_id	NUMBER;
  l_schedule_id		NUMBER;
  l_voyage_number	VARCHAR2(30);
  l_lane_id		NUMBER;

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_SERVICE_RATING_SETUP';
  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    x_status := -1;

    p_action         	:= FTE_UTIL_PKG.GET_DATA('ACTION', p_values);
    l_carrier_name    	:= FTE_UTIL_PKG.GET_DATA('CARRIER_NAME', p_values);
    l_lane_number     	:= FTE_UTIL_PKG.GET_DATA('SERVICE_NUMBER', p_values);
    l_vessel_type     	:= FTE_UTIL_PKG.GET_DATA('VESSEL_TYPE', p_values);
    l_vessel_name     	:= FTE_UTIL_PKG.GET_DATA('VESSEL_NAME', p_values);
    l_voyage_number     := FTE_UTIL_PKG.GET_DATA('VOYAGE_NUMBER', p_values);
    l_departure_dt   	:= FTE_UTIL_PKG.GET_DATA('DEPARTURE_DATE', p_values);
    l_departure_tm   	:= FTE_UTIL_PKG.GET_DATA('DEPARTURE_TIME', p_values);
    l_arrival_dt     	:= FTE_UTIL_PKG.GET_DATA('ARRIVAL_DATE', p_values);
    l_arrival_tm     	:= FTE_UTIL_PKG.GET_DATA('ARRIVAL_TIME', p_values);
    l_indicator      	:= FTE_UTIL_PKG.GET_DATA('ARRIVAL_DATE_INDICATOR', p_values);
    l_freq_type       	:= FTE_UTIL_PKG.GET_DATA('FREQUENCY_TYPE', p_values);
    l_frequency      	:= FTE_UTIL_PKG.GET_DATA('FREQUENCY', p_values);
    l_transit        	:= FTE_UTIL_PKG.GET_DATA('TRANSIT_TIME', p_values);
    l_transit_uom    	:= FTE_UTIL_PKG.GET_DATA('TRANSIT_TIME_UOM', p_values);
    l_port_loading    	:= FTE_UTIL_PKG.GET_DATA('PORT_OF_LOADING', p_values);
    l_port_discharge  	:= FTE_UTIL_PKG.GET_DATA('PORT_OF_DISCHARGE', p_values);
    l_start_date   	:= FTE_UTIL_PKG.GET_DATA('START_DATE', p_values);
    l_end_date 		:= FTE_UTIL_PKG.GET_DATA('END_DATE', p_values);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', p_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Lane Number', l_lane_number);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier name', l_carrier_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Vessel type', l_vessel_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Vessel name', l_vessel_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Voyage number', l_voyage_number);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Departure date', l_departure_dt);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Departure time', l_departure_tm);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Arrival date', l_arrival_dt);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Arrival time', l_arrival_tm);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Arrival date indicator', l_indicator);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Frequency type', l_freq_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Frequency', l_frequency);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Transit time', l_transit);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Transit time UOM', l_transit_uom);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Port of loading', l_port_loading);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Port of discharge', l_port_discharge);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Start date', l_start_date);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'End date', l_end_date);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    l_count := p_schedule_tbl.COUNT+1;
    p_schedule_tbl(l_count).vessel_type := l_vessel_type;
    p_schedule_tbl(l_count).vessel_name := l_vessel_name;
    p_schedule_tbl(l_count).voyage_number := l_voyage_number;
    p_schedule_tbl(l_count).arrival_date_indicator := l_indicator;
    p_schedule_tbl(l_count).transit_time := l_transit;
    p_schedule_tbl(l_count).port_of_loading := l_port_loading;
    p_schedule_tbl(l_count).port_of_discharge := l_port_discharge;

    -- ACTION Validation
    VALIDATE_ACTION(p_action	=> p_action,
		    p_type	=> 'SCHEDULE',
		    p_line_number => p_line_number,
		    x_status	=> x_status,
		    x_error_msg	=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    -- carrier name validation
    VALIDATE_CARRIER(p_carrier_name	=> l_carrier_name,
		     p_line_number	=> p_line_number,
		     p_carrier_id	=> l_carrier_id,
		     x_status		=> x_status,
		     x_error_msg	=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    -- LANE_NUMBER
    VALIDATE_LANE_NUMBER(p_lane_number	=> l_lane_number,
		  	 p_carrier_id	=> l_carrier_id,
			 p_line_number	=> p_line_number,
			 p_lane_id	=> l_lane_id,
			 x_status	=> x_status,
			 x_error_msg	=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    p_schedule_tbl(l_count).lane_number := l_lane_number;

    -- VESSEL_TYPE, VESSEL_NAME, VOYAGE_NUMBER Validation
    IF (l_voyage_number IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VOYAGE_NUMBER_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                   		  p_msg  	=> x_error_msg,
                   		  p_category	=> 'D',
				  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;

    -- ARRIVAL DATE INDICATOR Validation
    -- GLAMI added 11/09/01
    -- remove the leading + sign
    IF (l_indicator IS NOT NULL AND INSTR(l_indicator, '+') = 1) THEN
      l_indicator := SUBSTR(l_indicator, 2, LENGTH(l_indicator)-1);
    END IF;

    IF (l_indicator IS NOT NULL) THEN
      IF (TO_NUMBER(l_indicator) < -1) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_LESS_THAN_MINUSONE');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      ELSE
	IF (ISNUM(l_indicator) = 0) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_NUMBER_INVALID');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		      p_msg	  	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;
	END IF;
        l_indicator_value := TO_NUMBER(l_indicator);
      END IF;
    END IF;

    -- FREQUENCY_TYPE and FREQUENCY Validation
    -- FREQUENCY_TYPE or DEPARTURE_DATE should be specified
    IF (l_freq_type IS NULL AND l_departure_dt IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_NO_DEPARTURE_DATE');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		  p_msg 	 	=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;

    -- FREQUENCY_TYPE or ARRIVAL_DATE should be specified
    IF (l_freq_type IS NULL AND l_arrival_dt IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_NO_ARRIVAL_DATE');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		  p_msg 	 	=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    END IF;

    IF (l_freq_type IS NOT NULL) THEN
      l_old_freq_type := l_freq_type;
      l_freq_type := FTE_UTIL_PKG.GET_LOOKUP_CODE('FTE_FREQUENCY_TYPE', l_old_freq_type);

      IF (l_freq_type IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_UNDEFINED_FREQ_TYPE',
					    p_tokens		=> STRINGARRAY(''),
					    p_values		=> STRINGARRAY(l_old_freq_type));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;

	RETURN;
      ELSE
	p_schedule_tbl(l_count).frequency_type := l_freq_type;

        IF (l_freq_type = 'DAILY') THEN
          p_schedule_tbl(l_count).frequency := NULL;
        ELSIF (l_freq_type = 'WEEKLY') THEN
	  IF (l_frequency IS NULL) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_NO_FREQUENCY');
      	    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
    	 	              		p_msg	 	=> x_error_msg,
                	   		p_category	=> 'A',
					p_line_number	=> p_line_number);
 	    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      	    x_status := 1;
	    RETURN;
	  ELSE
            l_freq_code := GET_FREQ_CODE(p_frequency	=> l_frequency,
					 p_line_number	=> p_line_number,
					 x_status	=> x_status,
					 x_error_msg	=> x_error_msg);
            IF (l_freq_code IS NULL) THEN
              x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_INVALID_FREQUENCY',
						  p_tokens	=> STRINGARRAY('frequency'),
						  p_values	=> STRINGARRAY(l_frequency));
      	      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
    	 	              		  p_msg 	=> x_error_msg,
                	   		  p_category	=> 'D',
					  p_line_number	=> p_line_number);
 	      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      	      x_status := 1;
	      RETURN;
	    ELSE
              p_schedule_tbl(l_count).frequency := TO_NUMBER(l_freq_code);
	      l_freq_arr := CALCULATE_FREQ_ARRIVAL(p_frequency	=> l_freq_code,
						   p_ind	=> l_indicator_value,
						   p_line_number => p_line_number,
						   x_status	=> x_status,
						   x_error_msg	=> x_error_msg);
    	      IF (x_status <> -1) THEN
    	  	FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      		RETURN;
    	      END IF;

	      p_schedule_tbl(l_count).frequency_arrival := l_freq_arr;
	    END IF;
          END IF;
	END IF;

        -- DEPARTURE_TIME is mandatory if FREQUENCY is set
        IF (l_departure_tm IS NULL) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_NO_DEPARTURE_TIME');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		      p_msg	 	=> x_error_msg,
                   		      p_category	=> 'A',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;
        ELSE
          l_departure_tm := TRIM(' ' FROM l_departure_tm);
	  BEGIN
            l_tmp_tm := TO_CHAR(TO_DATE(l_departure_tm, FTE_BULKLOAD_PKG.G_TIME_FORMAT), FTE_BULKLOAD_PKG.G_TIME_FORMAT);
          EXCEPTION
            WHEN OTHERS THEN
	      x_error_msg := sqlerrm;
              FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                 			  p_msg   		=> x_error_msg,
             			          p_category    	=> 'O',
	        		      	  p_line_number		=> p_line_number);
              FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
              x_status := 1;
              RETURN;
          END;

	  IF (l_tmp_tm IS NULL) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_DEPARTURE_TIME_INVALID');
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		        p_msg  		=> x_error_msg,
                   		      	p_category		=> 'D',
				        p_line_number		=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
            RETURN;
	  END IF;
          p_schedule_tbl(l_count).departure_time := l_tmp_tm;
        END IF;

        -- ARRIVAL_TIME is mandatory if FREQUENCY is set
        IF (l_arrival_tm IS NULL) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_NO_ARRIVAL_TIME');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		      p_msg	 	=> x_error_msg,
                   		      p_category	=> 'A',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;
        ELSE
          l_arrival_tm := TRIM(' ' FROM l_arrival_tm);
	  BEGIN
            l_tmp_tm := TO_CHAR(TO_DATE(l_arrival_tm, FTE_BULKLOAD_PKG.G_TIME_FORMAT), FTE_BULKLOAD_PKG.G_TIME_FORMAT);
          EXCEPTION
            WHEN OTHERS THEN
	      x_error_msg := sqlerrm;
              FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                 			  p_msg   		=> x_error_msg,
             			          p_category    	=> 'O',
	        		      	  p_line_number		=> p_line_number);
              FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
              x_status := 1;
              RETURN;
          END;

	  IF (l_tmp_tm IS NULL) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_ARRIVAL_TIME_INVALID');
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                    		        p_msg  		=> x_error_msg,
                   		      	p_category		=> 'D',
				      	p_line_number		=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 1;
            RETURN;
	  END IF;

          p_schedule_tbl(l_count).arrival_time := l_tmp_tm;
      	END IF;
      END IF;
    END IF;

    -- DATE Type Validation

    -- DEPARTURE_DATE Validation
    IF (l_departure_dt IS NOT NULL) THEN
      IF (l_departure_tm IS NULL) THEN
        l_departure := l_departure_dt;
      ELSE
        l_departure := l_departure_dt || ' ' || l_departure_tm;
      END IF;

      BEGIN
        p_schedule_tbl(l_count).departure_date := TO_DATE(TRIM(' ' FROM l_departure), FTE_BULKLOAD_PKG.G_DATE_FORMAT);
      EXCEPTION
        WHEN OTHERS THEN
          x_error_msg := sqlerrm;
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                		      p_msg   		=> x_error_msg,
             			      p_category    	=> 'O',
	        		      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
          RETURN;
      END;

      IF (p_schedule_tbl(l_count).departure_date IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_INCORRECT_DATE',
					    p_tokens		=> STRINGARRAY('DATE'),
					    p_values		=> STRINGARRAY(l_departure));
      	FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
    	 	              	    p_msg 		=> x_error_msg,
                	  	    p_category		=> 'D',
				    p_line_number	=> p_line_number);
 	FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

    END IF;

    -- ARRIVAL_DATE Validation
    IF (l_arrival_dt IS NOT NULL) THEN
      IF (l_arrival_tm IS NULL) THEN
        l_arrival := l_arrival_dt;
      ELSE
        l_arrival := l_arrival_dt || ' ' || l_arrival_tm;
      END IF;

      BEGIN
        p_schedule_tbl(l_count).arrival_date := TO_DATE(TRIM(' ' FROM l_arrival), FTE_BULKLOAD_PKG.G_DATE_FORMAT);
      EXCEPTION
        WHEN OTHERS THEN
          x_error_msg := sqlerrm;
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                 		      p_msg   		=> x_error_msg,
             			      p_category    	=> 'O',
	        		      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
          RETURN;
      END;

      IF (p_schedule_tbl(l_count).arrival_date IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_INCORRECT_DATE',
 					    p_tokens		=> STRINGARRAY('DATE'),
	 				    p_values		=> STRINGARRAY(l_arrival));
      	FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
    	 	              	    p_msg 		=> x_error_msg,
                	   	    p_category		=> 'D',
				    p_line_number	=> p_line_number);
 	FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;
    END IF;

    -- End - Giacomo added 03/05/2001

    -- EFFECTIVE_DATE Validation

    l_start_date := TRIM(' ' FROM l_start_date);
    VALIDATE_DATE(p_date => l_start_date,
		  p_line_number => p_line_number,
		  x_status => x_status,
		  x_error_msg => x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    p_schedule_tbl(l_count).effective_date := l_start_date;

    -- EXPIRY_DATE Validation

    l_end_date := TRIM(' ' FROM l_end_date);
    VALIDATE_DATE(p_date => l_end_date,
		  p_line_number => p_line_number,
		  x_status => x_status,
		  x_error_msg => x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    p_schedule_tbl(l_count).expiry_date := l_end_date;

    -- Validation for TRANSIT_TIME and TRANSIT_TIME_UOM

    IF (l_transit IS NOT NULL) THEN
      IF (ISNUM(l_indicator) = 0) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_NUMBER_INVALID');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;

      IF (to_number(l_transit) < 0) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_TRANSIT_TIME_NEG');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg 		=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      END IF;
      -- If transit is a valid number, valid UOM should be specified.
      IF (l_transit_uom IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_UOM_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg 		=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 1;
	RETURN;
      ELSE
        l_transit_uom_code := FTE_UTIL_PKG.GET_UOM_CODE(l_transit_uom, 'Time');
        IF (l_transit_uom_code IS NOT NULL) THEN
	  p_schedule_tbl(l_count).transit_time_uom := l_transit_uom_code;
 	ELSE
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_UOM_INVALID',
					      p_tokens		=> STRINGARRAY('UOM'),
					      p_values		=> STRINGARRAY(l_transit_uom));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		      p_msg	 	=> x_error_msg,
                   		      p_category	=> 'B',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 1;
	  RETURN;
	END IF;
      END IF;
    END IF;

    l_old_schedule_id := FTE_LANE_PKG.GET_SCHEDULE(l_lane_id, l_voyage_number);

    IF (l_old_schedule_id = -1 AND (p_action IN ('SYNC', 'ADD'))) THEN

      p_action := 'ADD';
      p_schedule_tbl(l_count).lane_id := l_lane_id;
      l_schedule_id := FTE_LANE_PKG.GET_NEXT_SCHEDULE_ID;
      IF (l_schedule_id <> -1) THEN
        p_schedule_tbl(l_count).schedules_id := l_schedule_id;

--          FTE_CAT_VALIDATION_PKG.VALIDATE_ELEMENTS(SCHEDULETABLE, data, _encoding, errors);
      END IF;
    ELSIF (l_old_schedule_id = -1 AND p_action = 'DELETE') THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_NO_SCHEDULE');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		  p_msg 		=> x_error_msg,
                   		  p_category		=> 'B',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
    ELSIF (l_old_schedule_id <> -1 AND p_action = 'DELETE') THEN
      p_schedule_tbl(l_count).schedules_id := l_old_schedule_id;
      p_schedule_tbl(l_count).lane_id := l_lane_id;
    ELSE
      p_schedule_tbl(l_count).schedules_id := l_old_schedule_id;
      --  schedule already exist
      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Schedule already exist');
      END IF;
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
             			  p_msg   	=> x_error_msg,
             			  p_category    => 'O',
	        		  p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 1;
      RETURN;
  END VALIDATE_SCHEDULE;

  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_RATE_CHART
  --
  -- Purpose: Validate the data corresponding to this Line Header, and
  --          store the data in temporary tables for later insertion into
  --          p_list_header_tbl
  --
  -- IN Parameters
  --    1. p_values: 		pl/sql table for the rate chart line
  --	2. p_line_number:	line number
  --	3. p_validate:		boolean for validating data within VALIDATION procedure, default true
  --	4. p_process_id		process id for the loading, default null and assigned later
  --
  -- Out Parameters
  --    1. p_qp_list_header_tbl: 	pl/sql table for the list header information
  --	2. p_qp_qualifier_tbl:	pl/sql table for the qualifiers
  --	3. p_action:		action of the line
  --	4. p_carrier_id:	carrier id
  --	4. x_status:		status of the processing, -1 means no error
  --	5. x_error_msg:		error message if any.
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_RATE_CHART(p_values     		IN    		FTE_BULKLOAD_PKG.data_values_tbl,
				p_line_number		IN		NUMBER,
				p_validate 		IN 		BOOLEAN DEFAULT TRUE,
				p_process_id 		IN		NUMBER default null,
                                p_qp_list_header_tbl	IN OUT NOCOPY	FTE_RATE_CHART_PKG.qp_list_header_tbl,
				p_qp_qualifier_tbl	IN OUT NOCOPY	FTE_RATE_CHART_PKG.qp_qualifier_tbl,
				p_action		OUT NOCOPY	VARCHAR2,
				p_carrier_id		OUT NOCOPY	NUMBER,
                                x_status     		OUT NOCOPY  	NUMBER,
                                x_error_msg  		OUT NOCOPY  	VARCHAR2) IS

  l_intAction        	VARCHAR2(30);
  l_qualifier_group   	NUMBER;
  l_name              	VARCHAR2(100);
  l_description      	VARCHAR2(100);
  l_start_date        	VARCHAR2(30);
  l_end_date          	VARCHAR2(30);
  l_currency         	VARCHAR2(20);
  l_carrier_currency   	VARCHAR2(100);
  l_carrier_name      	VARCHAR2(100);
  l_list_header_id     	NUMBER;
  l_service_level     	VARCHAR2(50);
  l_attribute1        	VARCHAR2(50);

  l_module_name      	CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_RATE_CHART';

  -- Multiple RC
  l_replaced_rc       	VARCHAR2(60);
  l_old_rc_id         	NUMBER;

  l_temp		VARCHAR2(50);
  l_tokens		STRINGARRAY:=STRINGARRAY();
  l_list_type_code	VARCHAR2(10);
  l_count		NUMBER;
  l_chart_type		VARCHAR2(50) := FTE_RATE_CHART_PKG.g_chart_type;

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    l_list_header_id := -1;
    x_status         := -1;

    l_qualifier_group := 1;

    p_action     	:= FTE_UTIL_PKG.Get_Data('ACTION', p_values);
    l_description   	:= FTE_UTIL_PKG.Get_Data('DESCRIPTION', p_values);
    l_start_date    	:= FTE_UTIL_PKG.Get_Data('START_DATE', p_values);
    l_end_date      	:= FTE_UTIL_PKG.Get_Data('END_DATE', p_values);
    l_currency      	:= FTE_UTIL_PKG.Get_Data('CURRENCY', p_values);
    l_carrier_name  	:= FTE_UTIL_PKG.Get_Data('CARRIER_NAME', p_values);
    l_service_level 	:= FTE_UTIL_PKG.Get_Data('SERVICE_LEVEL', p_values);
    l_attribute1    	:= FTE_UTIL_PKG.Get_Data('ATTRIBUTE1', p_values);
    p_carrier_id	:= FTE_UTIL_PKG.Get_Data('CARRIER_ID', p_values);

    -- Multiple RC
    l_replaced_rc 	:= FTE_UTIL_PKG.Get_Data('REPLACED_RATE_CHART', p_values);

    --find out what type of rate chart it is
    l_chart_type     := NULL;

    l_name := FTE_UTIL_PKG.Get_Data('RATE_CHART_NAME', p_values);
    IF (l_name IS NOT NULL) THEN
      l_chart_type := 'FTE_RATE_CHART';
      l_list_type_code  := 'PRL';
    END IF;

    IF (l_name IS NULL) THEN
      l_name := FTE_UTIL_PKG.Get_Data('LTL_RATE_CHART_NAME', p_values);
      IF (l_name IS NOT NULL) THEN
	l_chart_type := 'FTE_RATE_CHART';
        l_list_type_code := 'PRL';
	FTE_RATE_CHART_PKG.g_is_LTL := TRUE;
      END IF;
    END IF;

    IF (l_name IS NULL) THEN
      l_name  := FTE_UTIL_PKG.Get_Data('CHARGES_DISCOUNTS_NAME', p_values);
      IF (l_name IS NOT NULL) THEN
        l_chart_type := 'FTE_MODIFIER';
        l_list_type_code  := 'SLT';
	l_attribute1 := 'FTE_MODIFIER';

        --Qualifiers added at the header level (e.g. carrier) apply to
        --all the rate charts in this qualifier
        l_qualifier_group := -1;
      END IF;
    END IF;

    IF (l_name IS NULL) THEN
      l_name := FTE_UTIL_PKG.Get_Data('TL_CHART_NAME', p_values);
      IF (l_name IS NOT NULL) THEN
        l_chart_type     := 'TL_RATE_CHART';
        l_list_type_code := 'PRL';
      END IF;
    END IF;

    IF (l_name IS NULL) THEN
      l_name := FTE_UTIL_PKG.Get_Data('TL_MODIFIER_NAME', p_values);
      IF (l_name IS NOT NULL) THEN
        l_chart_type := 'TL_MODIFIER';
        l_list_type_code := 'DLT';
      END IF;
    END IF;

    IF (l_name IS NULL) THEN
      l_name := FTE_UTIL_PKG.Get_Data('FACILITY_RATE_CHART_NAME', p_values);
      IF (l_name IS NOT NULL) THEN
        l_chart_type := 'FAC_RATE_CHART';
        l_list_type_code := 'PRL';
      END IF;
    END IF;

    IF (l_name IS NULL) THEN
      l_name := FTE_UTIL_PKG.Get_Data('TL_FACILITY_MODIFIER_NAME', p_values);
      IF (l_name IS NOT NULL) THEN
        l_chart_type := 'FAC_MODIFIER';
        l_list_type_code := 'DLT';
      END IF;
    END IF;

    IF (l_name IS NULL) THEN
      l_name := FTE_UTIL_PKG.Get_Data('TL_MIN_CHARGE', p_values);
      IF (l_name IS NOT NULL) THEN
        l_chart_type := 'MIN_MODIFIER';
        l_list_type_code := 'DLT';
      END IF;
    END IF;

    --DEBUG MESSAGES
    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', p_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Description', l_description);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Start date', l_start_date);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'End date', l_end_date);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Currency', l_currency);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier name', l_carrier_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Service level', l_service_level);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute1', l_attribute1);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier ID', p_carrier_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Replaced RC', l_replaced_rc);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Name', l_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    VALIDATE_DATE(p_date => l_start_date,
		  p_line_number => p_line_number,
		  x_status => x_status,
		  x_error_msg => x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    VALIDATE_DATE(p_date => l_end_date,
		  p_line_number => p_line_number,
		  x_status => x_status,
		  x_error_msg => x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    IF (p_validate) THEN
      IF (l_name IS NULL OR LENGTH(l_name) = 0 ) THEN
	x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_PRICE_NAME_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		    p_msg		=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      END IF;

      VALIDATE_ACTION(p_action		=> p_action,
		      p_type		=> 'RATE_CHART',
		      p_line_number 	=> p_line_number,
		      x_status		=> x_status,
		      x_error_msg	=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN;
      END IF;

      IF (p_carrier_id IS NULL) THEN
        -- Validation for Carrier Name. Use cached Carrier Id, if same carrier.
        IF (l_carrier_name IS NULL OR LENGTH(l_carrier_name) = 0) THEN
          --Facility Rate Charts and Surcharges Don't need a carrier.
          IF (l_chart_type <> 'FAC_RATE_CHART' and l_chart_type <> 'FAC_MODIFIER') THEN
  	    x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_CARRIER_MISSING');
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		        p_msg 		=> x_error_msg,
                   		        p_category	=> 'A',
				        p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 2;
       	    RETURN;
          END IF;
        ELSE
          VALIDATE_CARRIER(p_carrier_name	=> l_carrier_name,
		           p_line_number	=> p_line_number,
		           p_carrier_id		=> p_carrier_id,
		           x_status		=> x_status,
		           x_error_msg		=> x_error_msg);

          IF (x_status <> -1) THEN
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            RETURN;
          END IF;

        END IF;  --End Validating Carrier.
      END IF;

      l_list_header_id := FTE_RATE_CHART_PKG.Get_Pricelist_Id(p_name      => l_name,
                                             		      p_carrier_id => p_carrier_id,
					     		      p_attribute1 => l_temp);

      -- Validate Price List and  Check if the Pricelist is assigned to any Lane for DELETE
      -- If the pricelist already exists, set status to 999 and return immediately.
      IF (p_action = 'ADD' AND l_list_header_id <> -1) THEN
        x_error_msg := Fte_Util_PKG.Get_Msg(p_name   => 'FTE_PRICELIST_EXIST',
                                             p_tokens => StringArray('NAME'),
                                             p_values => StringArray(l_name));

        IF (l_chart_type <> 'LTL_RATE_CHART') THEN
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		      p_msg		=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);
        END IF;

        x_status := 999;
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN;

      ELSIF (p_action IN ('DELETE', 'UPDATE') AND (l_temp <> l_chart_type OR l_temp IS NULL) AND l_list_header_id <> -1) THEN

--    need messages for these names
        l_tokens.EXTEND;
        l_tokens(l_tokens.COUNT) := l_name;
        l_tokens.EXTEND;
        IF (l_chart_type = 'FTE_RATE_CHART') THEN
          l_tokens(l_tokens.COUNT) := 'Rate Chart';
        ELSIF (l_chart_type = 'TL_RATE_CHART') THEN
          l_tokens(l_tokens.COUNT) := 'TL Rate Chart';
        ELSIF (l_chart_type = 'LTL_RC') THEN
          l_tokens(l_tokens.COUNT) := 'LTL Rate Chart';
        ELSIF (l_chart_type = 'FAC_RATE_CHART') THEN
          l_tokens(l_tokens.COUNT) := 'Facility Rate Chart';
        ELSIF (l_chart_type = 'FTE_MODIFIER') THEN
          l_tokens(l_tokens.COUNT) := 'Charges and Discounts';
        ELSIF (l_chart_type = 'FAC_MODIFIER') THEN
          l_tokens(l_tokens.COUNT) := 'Facility Charges';
        ELSIF (l_chart_type = 'TL_MODIFIER') THEN
          l_tokens(l_tokens.COUNT) := 'Accessorial Charges';
        ELSIF (l_chart_type = 'MIN_MODIFIER') THEN
          l_tokens(l_tokens.COUNT) := 'LTL and/or Parcel Modifier';
        ELSE
          l_tokens(l_tokens.COUNT) := 'Unknown Type Chart';
        END IF;

        l_tokens.EXTEND;
        IF (l_temp = 'FTE_RATE_CHART') THEN
          l_tokens(l_tokens.COUNT) := 'Rate Chart';
        ELSIF (l_temp = 'TL_RATE_CHART') THEN
          l_tokens(l_tokens.COUNT) := 'TL Rate Chart';
        ELSIF (l_temp = 'LTL_RC') THEN
          l_tokens(l_tokens.COUNT) := 'LTL Rate Chart';
        ELSIF (l_temp = 'FAC_RATE_CHART') THEN
          l_tokens(l_tokens.COUNT) := 'Facility Rate Chart';
        ELSIF (l_temp = 'FTE_MODIFIER') THEN
          l_tokens(l_tokens.COUNT) := 'Charges and Discounts';
        ELSIF (l_temp = 'FAC_MODIFIER') THEN
          l_tokens(l_tokens.COUNT) := 'Facility Charges';
        ELSIF (l_temp = 'TL_MODIFIER') THEN
          l_tokens(l_tokens.COUNT) := 'Accessorial Charges';
        ELSIF (l_temp = 'MIN_MODIFIER') THEN
          l_tokens(l_tokens.COUNT) := 'LTL and/or Parcel Modifier';
        ELSE
          l_tokens(l_tokens.COUNT) := 'Unknown Type Chart';
        END IF;

        x_error_msg := Fte_Util_PKG.Get_Msg(p_name   => 'FTE_CAT_DELETE_TYPE_WRONG',
                                             p_tokens => StringArray('NAME', 'TYPE', 'ACTUAL'),
                                             p_values => l_tokens);

        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg		=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);

        x_status := 2;
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN;
      ELSIF (p_action IN ('DELETE', 'UPDATE', 'APPEND') AND l_list_header_id = -1) THEN
        x_error_msg := Fte_Util_PKG.Get_Msg(p_name   => 'FTE_PRICELIST_INVALID',
                                             p_tokens => StringArray('NAME'),
                                             p_values => StringArray(l_name));

        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg		=> x_error_msg,
                   		    p_category		=> 'C',
				    p_line_number	=> p_line_number);

        x_status := 2;
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN;
      END IF;

      IF (l_service_level IS NULL) THEN
        --TL Rate Charts must have a service level attached to the header
        IF (l_chart_type IN ('TL_RATE_CHART', 'TL_MODIFIER', 'MIN_MODIFIER')) THEN
  	  x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_SERVICE_LEVEL_MISSING');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		      p_msg		=> x_error_msg,
                   		      p_category	=> 'A',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
	  RETURN;
        END IF;
      ELSE
        l_service_level := Validate_Service_Level(p_carrier_id    => p_carrier_id,
                                                  p_carrier_name  => NULL,
                                                  p_service_level => l_service_level,
						  p_line_number	  => p_line_number,
						  x_status 	  => x_status,
                                                  x_error_msg     => x_error_msg);

        IF (l_service_level IS NULL OR x_status <> -1) THEN
          FTE_UTIL_PKG.Exit_Debug(l_module_name);
          RETURN;
        END IF;
      END IF;

      --Begin Validate and Cache Currency
      IF (l_chart_type <> 'FAC_MODIFIER' AND p_action <> 'DELETE') THEN
        -- not checking carrier currency anymore
        VALIDATE_CURRENCY(p_currency	=> l_currency,
                          p_carrier_id  => p_carrier_id,
			  p_line_number	=> p_line_number,
			  x_status	=> x_status,
			  x_error_msg	=> x_error_msg);

        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.Exit_Debug(l_module_name);
          RETURN;
        END IF;

      END IF; --End Validate and Cache Currency

      -- Multiple RC
      IF (l_replaced_rc IS NOT NULL AND LENGTH(l_replaced_rc) > 0 ) THEN
        BEGIN
          SELECT list_header_id
          INTO   l_old_rc_id
          FROM   qp_list_headers_tl
          WHERE  name = l_replaced_rc
          AND    language = userenv('LANG');

  	  FTE_RATE_CHART_PKG.LH_NEW_RC(FTE_RATE_CHART_PKG.lh_new_rc.COUNT + 1)         := l_name;
          FTE_RATE_CHART_PKG.LH_REPLACE_RC(FTE_RATE_CHART_PKG.lh_replace_rc.COUNT + 1) := l_old_rc_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_error_msg := Fte_Util_PKG.Get_Msg(p_name   => 'FTE_REPLACE_RC_NOT_FOUND',
                                                 p_tokens => StringArray('RATE_CHART'),
                                                 p_values => STRINGARRAY(l_replaced_rc));
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                    		        p_msg		=> x_error_msg,
                   		        p_category	=> 'D',
				        p_line_number	=> p_line_number);

            x_status := 2;
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
	    RETURN;
          WHEN OTHERS THEN
    	    x_error_msg := sqlerrm;
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
               			        p_msg   	=> x_error_msg,
             			        p_category    	=> 'O',
	        		        p_line_number	=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
            x_status := 2;
	    RETURN;
        END;
      END IF;
    ELSE
      l_list_header_id := TO_NUMBER(FTE_UTIL_PKG.Get_Data('LIST_HEADER_ID', p_values));
    END IF;

    IF (p_process_id is NULL) THEN
      FTE_RATE_CHART_PKG.G_Process_Id := FTE_BULKLOAD_PKG.get_process_id;
    ELSE
      FTE_RATE_CHART_PKG.G_Process_Id := p_process_id;
    END IF;

    IF (p_action = 'DELETE') THEN
      l_count := p_qp_list_header_tbl.COUNT+1;

      p_qp_list_header_tbl(l_count).NAME                  := l_name;
      p_qp_list_header_tbl(l_count).LIST_HEADER_ID        := l_list_header_id;
      p_qp_list_header_tbl(l_count).INTERFACE_ACTION_CODE := 'D';
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    ELSIF (p_action IN ('ADD', 'APPEND','UPDATE')) THEN

      IF (p_action = 'ADD') THEN
        l_intAction := 'C';
      ELSIF (p_action = 'APPEND') THEN
  	l_intAction := 'U';
      ELSE --'UPDATE'
	l_intAction := 'U';
      END IF;

      -- Inserting insertdata into QP_INTERFACE_LIST_HEADERS

      l_count := p_qp_list_header_tbl.COUNT+1;

      p_qp_list_header_tbl(l_count).PROCESS_ID     	    := FTE_RATE_CHART_PKG.G_Process_Id;
      p_qp_list_header_tbl(l_count).INTERFACE_ACTION_CODE       := l_intAction;
      p_qp_list_header_tbl(l_count).START_DATE_ACTIVE     := l_start_date;
      p_qp_list_header_tbl(l_count).LIST_TYPE_CODE        := l_list_type_code;
      p_qp_list_header_tbl(l_count).END_DATE_ACTIVE       := l_end_date;
      p_qp_list_header_tbl(l_count).CURRENCY_CODE         := l_currency;
      p_qp_list_header_tbl(l_count).NAME                  := l_name;
      p_qp_list_header_tbl(l_count).DESCRIPTION           := l_description;
      p_qp_list_header_tbl(l_count).LIST_HEADER_ID        := l_list_header_id;
      p_qp_list_header_tbl(l_count).ATTRIBUTE1            := l_attribute1;

      IF (l_list_header_id = -1) THEN
        l_list_header_id := '';
      END IF;

      IF (p_validate) THEN
        --Insert party qualifier for all rate charts apart for FACILITY
        -- and for MIN_MODIFIER
        IF (p_action = 'ADD'
	    AND l_chart_type NOT IN ('FAC_RATE_CHART', 'FAC_MODIFIER', 'MIN_MODIFIER')) THEN

  	  l_count := p_qp_qualifier_tbl.COUNT+1;

          p_qp_qualifier_tbl(l_count).PROCESS_ID            := FTE_RATE_CHART_PKG.G_Process_Id;
          p_qp_qualifier_tbl(l_count).INTERFACE_ACTION_CODE := l_intAction;
          p_qp_qualifier_tbl(l_count).QUALIFIER_ATTR_VALUE  := p_carrier_id;
          p_qp_qualifier_tbl(l_count).QUALIFIER_GROUPING_NO := l_qualifier_group;
          p_qp_qualifier_tbl(l_count).QUALIFIER_CONTEXT     := 'PARTY';
          p_qp_qualifier_tbl(l_count).QUALIFIER_ATTRIBUTE   := 'SUPPLIER';
        END IF;

        --Insert two additional qualifiers for TL rate charts
        --and modifiers (service type and mode_of_transport)
        IF (p_action = 'ADD' AND l_chart_type IN ('TL_RATE_CHART', 'TL_MODIFIER')) THEN
          --Service_Type
          l_count := p_qp_qualifier_tbl.COUNT+1;

          p_qp_qualifier_tbl(l_count).PROCESS_ID            := FTE_RATE_CHART_PKG.G_Process_Id;
          p_qp_qualifier_tbl(l_count).INTERFACE_ACTION_CODE := l_intAction;
          p_qp_qualifier_tbl(l_count).QUALIFIER_ATTRIBUTE   := 'SERVICE_TYPE';
          p_qp_qualifier_tbl(l_count).QUALIFIER_ATTR_VALUE  := l_service_level;
          p_qp_qualifier_tbl(l_count).QUALIFIER_GROUPING_NO := l_qualifier_group;
          p_qp_qualifier_tbl(l_count).QUALIFIER_CONTEXT     := FTE_RTG_GLOBALS.G_QX_SERVICE_TYPE;

          --Mode_Of_Transport
    	  l_count := p_qp_qualifier_tbl.COUNT+1;

          p_qp_qualifier_tbl(l_count).PROCESS_ID            := FTE_RATE_CHART_PKG.G_Process_Id;
          p_qp_qualifier_tbl(l_count).INTERFACE_ACTION_CODE := l_intAction;
          p_qp_qualifier_tbl(l_count).QUALIFIER_ATTRIBUTE   := 'MODE_OF_TRANSPORTATION';
          p_qp_qualifier_tbl(l_count).QUALIFIER_ATTR_VALUE  := 'TRUCK';
          p_qp_qualifier_tbl(l_count).QUALIFIER_GROUPING_NO := l_qualifier_group;
          p_qp_qualifier_tbl(l_count).QUALIFIER_CONTEXT     := FTE_RTG_GLOBALS.G_QX_MODE_OF_TRANSPORT;
        END IF;
      END IF;
    END IF;

    FTE_RATE_CHART_PKG.g_chart_type := l_chart_type;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
               			  p_msg   		=> x_error_msg,
             			  p_category    	=> 'O',
	        		  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
  END VALIDATE_RATE_CHART;

  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_RATE_LINE
  --
  -- Purpose: Validate the data corresponding to this Rate Chart Line, and
  --          store the data in temporary tables for later insertion into
  --          QP_INTERFACE_LIST_LINES and QP_INTERFACE_LIST_PRICING_ATTRIBS.
  --
  -- IN Parameters
  --    1. p_values: 		pl/sql table for the rate line line
  --	2. p_line_number:	line number
  --	3. p_validate:		boolean for validating data within VALIDATION procedure, default true
  --
  -- Out Parameters
  --    1. p_qp_list_line_tbl: 	pl/sql table for the list line information
  --	2. p_qp_pricing_attrib_tbl:	pl/sql table for the attributes
  --	3. x_status:		status of the processing, -1 means no error
  --	4. x_error_msg:		error message if any.
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_RATE_LINE(p_values     		IN    		FTE_BULKLOAD_PKG.data_values_tbl,
			       p_line_number		IN		NUMBER,
			       p_validate 		IN 		BOOLEAN DEFAULT TRUE,
                               p_qp_list_line_tbl	IN OUT	NOCOPY FTE_RATE_CHART_PKG.qp_list_line_tbl,
			       p_qp_pricing_attrib_tbl	IN OUT	NOCOPY FTE_RATE_CHART_PKG.qp_pricing_attrib_tbl,
	                       x_status     		OUT NOCOPY  	NUMBER,
                               x_error_msg  		OUT NOCOPY  	VARCHAR2) IS

  l_intAction           VARCHAR2(30);
  l_description         VARCHAR2(100);
  l_action          	VARCHAR2(20);
  l_linenum             VARCHAR2(20);
  l_operamt             VARCHAR2(20);
  l_uom                 VARCHAR2(20);
  l_uom_code            VARCHAR2(20);
  l_break_type          VARCHAR2(20);
  l_volume_type         VARCHAR2(20);
  l_rate_type           VARCHAR2(20);
  l_item                VARCHAR2(20);
  l_group               NUMBER;
  l_list_header_id      NUMBER;
  l_precedence          NUMBER;
  l_product_attribute   VARCHAR2(100);
  l_list_type_code      VARCHAR2(3);
  l_operator            VARCHAR2(30);
  l_pricing_attribute   VARCHAR2(50);
  l_prc_attr_datatype   VARCHAR2(3);
  l_context             VARCHAR2(50);
  l_comp_operator       VARCHAR2(30);
  l_attr_value_from     VARCHAR2(50);
  l_attr_value_to       VARCHAR2(50);
  l_mod_level_code      VARCHAR2(30);
  l_formula_id          NUMBER;
  l_start_date		VARCHAR2(50);
  l_end_date		VARCHAR2(50);

  --modifier stuff
  l_phase               NUMBER;
  l_qual_ind            NUMBER;
  l_dscvalue_amt        VARCHAR2(30);
  l_dsclumpsum_amt      VARCHAR2(30);
  l_dscprcnt_amt        VARCHAR2(30);
  l_type                VARCHAR2(30);
  l_subtype             VARCHAR2(30);

  l_attribute1          VARCHAR2(100);
  l_chart_type		VARCHAR2(50) := FTE_RATE_CHART_PKG.g_chart_type;
  l_module_name         CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_RATE_LINE';
  l_count		NUMBER;

  BEGIN
    FTE_UTIL_PKG.ENTER_Debug(l_module_name);

    --reset the upper value used for parcel LTL breaks.
    FTE_RATE_CHART_PKG.G_previous_upper := 0;

    l_list_header_id    := -1;
    x_status     := -1;

    l_group             := 1;
    l_product_attribute := null;
    l_item := 'ALL';
    l_prc_attr_datatype := 'C';

    l_action            := FTE_UTIL_PKG.GET_DATA('ACTION', p_values);
    l_linenum           := FTE_UTIL_PKG.GET_DATA('LINE_NUMBER', p_values);
    l_description       := FTE_UTIL_PKG.GET_DATA('DESCRIPTION', p_values);
    l_operamt           := FTE_UTIL_PKG.GET_DATA('RATE', p_values);
    l_uom               := FTE_UTIL_PKG.GET_DATA('UOM', p_values);
    l_precedence        := FTE_UTIL_PKG.GET_DATA('PRECEDENCE', p_values);
    l_break_type        := FTE_UTIL_PKG.GET_DATA('RATE_BREAK_TYPE', p_values);
    l_volume_type       := FTE_UTIL_PKG.GET_DATA('VOLUME_TYPE', p_values);
    l_rate_type         := FTE_UTIL_PKG.GET_DATA('RATE_TYPE', p_values);
    l_pricing_attribute := FTE_UTIL_PKG.GET_DATA('ATTRIBUTE', p_values);
    l_attr_value_from   := FTE_UTIL_PKG.GET_DATA('ATTRIBUTE_VALUE', p_values);
    l_attr_value_to     := FTE_UTIL_PKG.GET_DATA('ATTRIBUTE_VALUE_TO', p_values);
    l_context           := FTE_UTIL_PKG.GET_DATA('CONTEXT', p_values);
    l_comp_operator     := FTE_UTIL_PKG.GET_DATA('COMPARISON_OPERATOR', p_values);
    l_type              := FTE_UTIL_PKG.GET_DATA('TYPE', p_values);
    l_subtype           := FTE_UTIL_PKG.GET_DATA('SUBTYPE', p_values);
    l_formula_id        := FTE_UTIL_PKG.GET_DATA('FORMULA_ID', p_values);
    l_start_date        := FTE_UTIL_PKG.GET_DATA('START_DATE_ACTIVE', p_values);
    l_end_date          := FTE_UTIL_PKG.GET_DATA('END_DATE_ACTIVE', p_values);

    --FTE_RATE_CHART
    IF (l_chart_type = 'FTE_RATE_CHART') THEN
      l_list_type_code := 'PLL';

    --FTE_MODIFIER
    ELSIF (l_chart_type = 'FTE_MODIFIER') THEN
      l_phase := 2;
      l_qual_ind := 5;
      l_dscvalue_amt     := FTE_UTIL_PKG.GET_DATA('RATE_PER_UOM', p_values);
      l_dscprcnt_amt     := FTE_UTIL_PKG.GET_DATA('PERCENTAGE', p_values);
      l_dsclumpsum_amt   := FTE_UTIL_PKG.GET_DATA('FIXED_RATE', p_values);
      l_mod_level_code   := FTE_UTIL_PKG.GET_DATA('MOD_LEVEL_CODE', p_values);
      l_list_type_code   := 'SUR';

    --TL_RATE_CHART
    ELSIF (l_chart_type = 'TL_RATE_CHART') THEN
      l_attribute1      := FTE_UTIL_PKG.GET_DATA('ATTRIBUTE1', p_values);
      l_list_type_code  := 'PLL';

    --TL_MODIFIER
    ELSIF (l_chart_type IN ('TL_MODIFIER', 'MIN_MODIFIER', 'FAC_MODIFIER')) THEN
      l_phase := 2;
      l_qual_ind := 22;
      l_dscvalue_amt      := FTE_UTIL_PKG.GET_DATA('RATE_PER_UOM', p_values);
      l_dscprcnt_amt      := FTE_UTIL_PKG.GET_DATA('PERCENTAGE', p_values);
      l_dsclumpsum_amt    := FTE_UTIL_PKG.GET_DATA('FIXED_RATE', p_values);
      l_mod_level_code    := FTE_UTIL_PKG.GET_DATA('MOD_LEVEL_CODE', p_values);
      l_list_type_code    := 'SUR';

    ELSIF (l_chart_type = 'FAC_RATE_CHART') THEN
      l_list_type_code := 'PLL';

    ELSE

      x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CHART_TYPE_ERROR');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	           		  p_msg   	=> x_error_msg,
	           		  p_category    => 'O');

      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN;
    END IF;

    IF (l_mod_level_code = 'LINEGROUP') THEN
      l_phase := 3;
    ELSE
      l_mod_level_code := 'LINE';
    END IF;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', l_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Description', l_description );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate', l_operamt);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'UOM', l_uom);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Precedence', l_precedence);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate break type', l_break_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Volume type', l_volume_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate type', l_rate_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute', l_pricing_attribute);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute value', l_attr_value_from );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute value to', l_attr_value_to );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Context', l_context);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Comparison operator', l_comp_operator);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Type', l_type );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Subtype', l_subtype );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Formula ID', l_formula_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    l_action := UPPER(l_action);

    IF (NOT p_validate) THEN
      l_operator := l_rate_type;
      l_uom_code := l_uom;
    END IF;

    VALIDATE_DATE(p_date => l_start_date,
		  p_line_number => p_line_number,
		  x_status => x_status,
		  x_error_msg => x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    VALIDATE_DATE(p_date => l_end_date,
		  p_line_number => p_line_number,
		  x_status => x_status,
		  x_error_msg => x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      RETURN;
    END IF;

    IF (p_validate) THEN
      VALIDATE_ACTION(p_action		=> l_action,
	  	      p_type		=> 'RATE_LINE',
		      p_line_number 	=> p_line_number,
		      x_status		=> x_status,
		      x_error_msg	=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN;
      END IF;

      IF (l_linenum IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_LINE_NUMBER_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg		=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      ELSIF (isNum(l_linenum) = 0) THEN
        x_error_msg := Fte_Util_PKG.Get_Msg(p_name   => 'FTE_CAT_NUMBER_INVALID', -- need change
                                             p_tokens => STRINGARRAY('NUMBER'),
                                             p_values => STRINGARRAY(l_linenum));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                   		    p_msg	  => x_error_msg,
                   		    p_category	  => 'D',
				    p_line_number => p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      END IF;
    END IF;

    FTE_RATE_CHART_PKG.G_line_number    := l_linenum;

    IF (l_precedence IS NULL) THEN
      l_precedence := 220;
    END IF;

    IF (p_validate) THEN
      IF (l_uom IS NULL) THEN
        --The UOM is not mandatory for Modifiers, even for RATE_PER_UOM.
        --If the UOM is not specified, the UOM of the rate line will be used.
        IF (l_chart_type NOT IN ('FTE_MODIFIER', 'TL_MODIFIER',
                                 'MIN_MODIFIER', 'FAC_MODIFIER')) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_UOM_MISSING');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		      p_msg 		=> x_error_msg,
                   		      p_category	=> 'A',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
	  RETURN;
        END IF;
      ELSE
        VALIDATE_UOM(p_uom		=> l_uom,
		     p_class		=> NULL,
		     p_line_number 	=> p_line_number,
		     p_uom_code 	=> l_uom_code,
		     x_status		=> x_status,
		     x_error_msg	=> x_error_msg);

        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	  RETURN;
        END IF;

      END IF;

      IF (LENGTH(l_break_type) > 0) THEN
        l_break_type := UPPER(l_break_type);
        IF (NOT( l_break_type = 'POINT' OR  l_break_type = 'RANGE' )) THEN
          x_error_msg := Fte_Util_PKG.Get_Msg(p_name   => 'FTE_BREAK_TYPE_INVALID',
                                               p_tokens => STRINGARRAY('BREAK_TYPE'),
                                               p_values => STRINGARRAY(l_break_type));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		      p_msg	 	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
	  RETURN;
        END IF;
      END IF;

      -- if it's has no rate or break type, throw error.
      IF (l_chart_type = 'FTE_RATE_CHART' AND l_operamt IS NULL AND l_break_type IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_RATE_AND_BREAK');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                     		    p_msg 		=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;

      END IF;

      -- if both rate and break type not null, error also
      IF (l_chart_type = 'FTE_RATE_CHART' AND l_operamt IS NOT NULL AND l_break_type IS NOT NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_RATE_AND_BREAK');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		    p_msg 		=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      END IF;

      IF (LENGTH(l_volume_type) > 0) THEN
        l_volume_type := UPPER(l_volume_type);
        IF (NOT  (l_volume_type = 'QUANTITY' OR l_volume_type = 'TOTAL_QUANTITY') ) THEN
          x_error_msg := Fte_Util_PKG.Get_Msg(p_name   => 'FTE_VOLUME_TYPE_INVALID',
                                               p_tokens => STRINGARRAY('VOLUME_TYPE'),
                                               p_values => STRINGARRAY(l_volume_type));

          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		      p_msg 		=> x_error_msg,
                   		      p_category		=> 'D',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
	  RETURN;
--            x_error_msg := 'VOLUME_TYPE (' || l_volume_type || ') FOR LINE ' || l_linenum || ' INVALID';
        END IF;
      END IF;

      -- if it's a standard line and don't have rate type, throw error.
      IF (l_chart_type = 'FTE_RATE_CHART' AND l_operamt IS NOT NULL AND l_rate_type IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_RATE_TYPE_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		    p_msg 		=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      END IF;

      l_rate_type := Validate_Rate_Type(p_rate_type  	=> l_rate_type,
				        p_line_number   => p_line_number,
				        x_status     	=> x_status,
				        x_error_msg  	=> x_error_msg);
      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        return;
      ELSE
        l_operator := l_rate_type;
      END IF;
    END IF;


    --Validate Modifier Specific Attributes
    IF (l_chart_type IN ('FTE_MODIFIER', 'TL_MODIFIER', 'MIN_MODIFIER')) THEN
      --validate the type
      IF (l_type = 'ACCESSORIAL_SURCHARGE') THEN
        IF (l_subtype IS NOT NULL AND LENGTH(l_subtype) > 0) THEN
          IF (l_chart_type NOT IN ('TL_MODIFIER', 'MIN_MODIFIER', 'FAC_MODIFIER')) THEN
            l_subtype := validate_subtype(p_subtype 	=> l_subtype,
					  p_line_number	=> p_line_number,
					  x_status	=> x_status,
					  x_error_msg	=> x_error_msg);
	    IF (x_status <> -1) THEN
              FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
              RETURN;
	    END IF;
          END IF;
        ELSE
          x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_SUBTYPE_MISSING');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name		=> l_module_name,
                   		      p_msg	 		=> x_error_msg,
                   		      p_category		=> 'A',
				      p_line_number		=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
          RETURN;
        END IF;

        IF (l_subtype IS NULL) THEN
	  l_subtype := FTE_UTIL_PKG.GET_DATA('SUBTYPE', p_values);
          x_error_msg := Fte_Util_PKG.Get_Msg(p_name   => 'FTE_SUBTYPE_INVALID',
                                               p_tokens => STRINGARRAY('SUBTYPE'),
                                               p_values => STRINGARRAY(l_subtype));

          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		      p_msg	 	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
	  RETURN;
        END IF;

      ELSIF (l_type = 'DISCOUNT') THEN
        l_list_type_code := 'DIS';
      ELSE
        x_error_msg := Fte_Util_PKG.Get_Msg(p_name   => 'FTE_MOD_TYPE_INVALID',
                                             p_tokens => STRINGARRAY('TYPE'),
                                             p_values => STRINGARRAY(l_type));

        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		    p_msg 		=> x_error_msg,
                 		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
	RETURN;
      END IF;

      --validate the discount amounts and percentages and set the operator
      IF (l_dscvalue_amt IS NOT NULL AND LENGTH(l_dscvalue_amt) > 0) THEN
        l_operator := 'AMT';
        l_operamt := l_dscvalue_amt;
      ELSIF (l_dscprcnt_amt IS NOT NULL AND LENGTH(l_dscprcnt_amt) > 0) THEN
        l_operator := '%';
        l_operamt := l_dscprcnt_amt;
      ELSIF (l_dsclumpsum_amt IS NOT NULL AND LENGTH(l_dsclumpsum_amt) > 0) THEN
        l_operator := 'LUMPSUM';
        l_operamt := l_dsclumpsum_amt;
      ELSIF (l_chart_type = 'FTE_MODIFIER') THEN
        --FTE_MODIFIERS don't have breaks, so one of these values must be specified.
        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_MOD_RATE_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                     		    p_msg		=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
	RETURN;
      END IF;
    END IF;  --end validation of specific Attributes.

    FTE_RATE_CHART_PKG.G_Prc_Brk_Type      := l_break_type;
    FTE_RATE_CHART_PKG.G_Prc_Rate_Type     := l_rate_type;
    FTE_RATE_CHART_PKG.G_Prc_Vol_Type      := l_volume_type;
    FTE_RATE_CHART_PKG.G_Prc_Line_Desc     := l_description;
    FTE_RATE_CHART_PKG.G_Product_UOM       := l_uom_code;

    --Save the current line number, so we can associate with breaks, if there are any.
    FTE_RATE_CHART_PKG.G_Prc_Brk_Hdr_Index := l_linenum;

    IF (l_action IN ('ADD', 'UPDATE')) THEN
      -- Insert into QP_INTERFACE_LIST_LINES
      l_count := p_qp_list_line_tbl.COUNT+1;

      --MODIFIERS NEED THE BREAK TYPE ON THE LINE, BUT RATE CHARTS DON'T
      IF (l_chart_type IN ('FTE_RATE_CHART', 'FAC_RATE_CHART')) THEN
        l_break_type := NULL;
      END IF;

      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Chart Type', l_chart_type);
      END IF;

      p_qp_list_line_tbl(l_count).PROCESS_ID             := FTE_RATE_CHART_PKG.G_Process_Id;
      p_qp_list_line_tbl(l_count).OPERAND                := fnd_number.canonical_to_number(l_operamt);
      p_qp_list_line_tbl(l_count).COMMENTS               := l_description;
      p_qp_list_line_tbl(l_count).LIST_LINE_NO           := l_linenum;
      p_qp_list_line_tbl(l_count).PROCESS_TYPE           := 'SSH';
      p_qp_list_line_tbl(l_count).INTERFACE_ACTION_CODE  := 'C';
      p_qp_list_line_tbl(l_count).LIST_LINE_TYPE_CODE    := l_list_type_code;
      p_qp_list_line_tbl(l_count).AUTOMATIC_FLAG         := 'Y';
      p_qp_list_line_tbl(l_count).ACCRUAL_FLAG           := 'N';
      p_qp_list_line_tbl(l_count).OVERRIDE_FLAG          := 'N';
      p_qp_list_line_tbl(l_count).MODIFIER_LEVEL_CODE    := l_mod_level_code;
      p_qp_list_line_tbl(l_count).ARITHMETIC_OPERATOR    := l_operator;
      p_qp_list_line_tbl(l_count).PRICE_BREAK_TYPE_CODE  := l_break_type;
      p_qp_list_line_tbl(l_count).PRICE_BREAK_HEADER_INDEX := NULL;
      p_qp_list_line_tbl(l_count).ATTRIBUTE2             := NULL;
      p_qp_list_line_tbl(l_count).RLTD_MODIFIER_GRP_TYPE := NULL;
      p_qp_list_line_tbl(l_count).RLTD_MODIFIER_GRP_NO   := NULL;
      p_qp_list_line_tbl(l_count).PRIMARY_UOM_FLAG       := NULL;
      p_qp_list_line_tbl(l_count).PRODUCT_PRECEDENCE     := l_precedence;
      p_qp_list_line_tbl(l_count).PRICING_GROUP_SEQUENCE := NULL;
      p_qp_list_line_tbl(l_count).PRICING_PHASE_ID       := l_phase;
      p_qp_list_line_tbl(l_count).QUALIFICATION_IND      := l_qual_ind;
      p_qp_list_line_tbl(l_count).CHARGE_TYPE_CODE       := l_type;
      p_qp_list_line_tbl(l_count).CHARGE_SUBTYPE_CODE    := l_subtype;
      p_qp_list_line_tbl(l_count).ATTRIBUTE1             := l_attribute1;
      p_qp_list_line_tbl(l_count).PRICE_BY_FORMULA_ID    := l_formula_id;
      p_qp_list_line_tbl(l_count).START_DATE_ACTIVE	 := l_start_date;
      p_qp_list_line_tbl(l_count).END_DATE_ACTIVE	 := l_end_date;

      --Save the current index into p_qp_list_line_tbl, so we can
      --update list_type_code to 'PBH' in case of breaks.
      FTE_RATE_CHART_PKG.G_Cur_Line_Index := l_count;

      IF (l_chart_type = 'FTE_RATE_CHART') THEN
        --rate chart
        p_qp_list_line_tbl(l_count).PRIMARY_UOM_FLAG     := 'Y';

      ELSIF (l_chart_type = 'FTE_MODIFIER') THEN
        --modifiers
        p_qp_list_line_tbl(l_count).PRICING_GROUP_SEQUENCE   := l_group;

      ELSIF (l_chart_type = 'TL_RATE_CHART') THEN
        --tl rate chart
        p_qp_list_line_tbl(l_count).PRIMARY_UOM_FLAG       := 'Y';

      ELSIF (l_chart_type IN ('TL_MODIFIER', 'MIN_MODIFIER')) THEN
        --tl rate chart
        p_qp_list_line_tbl(l_count).PRIMARY_UOM_FLAG       := 'Y';

      ELSIF (l_chart_type = 'FAC_RATE_CHART') THEN
        --Facility rate chart
        p_qp_list_line_tbl(l_count).PRIMARY_UOM_FLAG       := 'Y';

      ELSIF (l_chart_type NOT IN ('FAC_MODIFIER')) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CHART_TYPE_ERROR');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	           		    p_msg   	  => x_error_msg,
	           		    p_category    => 'O');
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
	x_status := 2;
	RETURN;
      END IF;

      IF (l_attr_value_from IS NOT NULL AND l_attr_value_to IS NOT NULL) THEN
        IF (l_comp_operator IS NOT NULL) THEN
          l_comp_operator := 'BETWEEN';
        END IF;
        l_prc_attr_datatype := 'N';
      ELSIF (l_attr_value_from IS NOT NULL) THEN
        IF (l_comp_operator IS NOT NULL) THEN
          l_comp_operator := '=';
        END IF;
      END IF;

      --insert into QP_INTERFACE_PRICING_ATTRIBS
      l_product_attribute := 'PRICING_ATTRIBUTE3';

      l_count := p_qp_pricing_attrib_tbl.COUNT+1;
      p_qp_pricing_attrib_tbl(l_count).PROCESS_ID              := FTE_RATE_CHART_PKG.G_Process_Id;
      p_qp_pricing_attrib_tbl(l_count).PRODUCT_ATTRIBUTE       := l_product_attribute;
      p_qp_pricing_attrib_tbl(l_count).PRODUCT_ATTR_VALUE      := l_item;
      p_qp_pricing_attrib_tbl(l_count).PRODUCT_UOM_CODE        := l_uom_code;
      p_qp_pricing_attrib_tbl(l_count).ATTRIBUTE_GROUPING_NO   := l_group;
      p_qp_pricing_attrib_tbl(l_count).LIST_LINE_NO            := l_linenum;
      p_qp_pricing_attrib_tbl(l_count).PROCESS_TYPE            := 'SSH';
      p_qp_pricing_attrib_tbl(l_count).INTERFACE_ACTION_CODE   := 'C';
      p_qp_pricing_attrib_tbl(l_count).EXCLUDER_FLAG           := 'N';
      p_qp_pricing_attrib_tbl(l_count).PRODUCT_ATTRIBUTE_CONTEXT := 'ITEM';
      p_qp_pricing_attrib_tbl(l_count).PRODUCT_ATTRIBUTE_DATATYPE := 'C';
      p_qp_pricing_attrib_tbl(l_count).PRICING_ATTRIBUTE_DATATYPE := l_prc_attr_datatype;
      p_qp_pricing_attrib_tbl(l_count).COMPARISON_OPERATOR_CODE   := l_comp_operator;
      p_qp_pricing_attrib_tbl(l_count).PRICING_ATTRIBUTE_CONTEXT  := l_context;
      p_qp_pricing_attrib_tbl(l_count).PRICING_ATTRIBUTE       := l_pricing_attribute;
      p_qp_pricing_attrib_tbl(l_count).PRICING_ATTR_VALUE_FROM := l_attr_value_from;
      p_qp_pricing_attrib_tbl(l_count).PRICING_ATTR_VALUE_TO   := l_attr_value_to;

    END IF;

    FTE_RATE_CHART_PKG.g_chart_type := l_chart_type;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
               			 p_msg   	=> x_error_msg,
             			 p_category    	=> 'O',
	        		 p_line_number	=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
  END VALIDATE_RATE_LINE;

  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_RATE_BREAK
  --
  -- Purpose: Validate the data corresponding to this price break, and store
  --          the data in temporary tables for later insertion into
  --          QP_INTERFACE_LIST_LINES and QP_INTERFACE_PRICING_ATTRIBS.
  --
  -- IN Parameters
  --    1. p_values: 		pl/sql table for the rate break line
  --	2. p_line_number:	line number
  --	3. p_validate:		boolean for validating data within VALIDATION procedure, default true
  --
  -- Out Parameters
  --    1. p_qp_list_line_tbl: 	pl/sql table for the list line information
  --	2. p_qp_pricing_attrib_tbl:	pl/sql table for the attributes
  --	3. x_status:		status of the processing, -1 means no error
  --	4. x_error_msg:		error message if any.
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_RATE_BREAK(p_values     		IN    		FTE_BULKLOAD_PKG.data_values_tbl,
				p_line_number		IN		NUMBER,
				p_validate 		IN 		BOOLEAN DEFAULT TRUE,
                                p_qp_list_line_tbl	IN OUT	NOCOPY  FTE_RATE_CHART_PKG.qp_list_line_tbl,
				p_qp_pricing_attrib_tbl	IN OUT	NOCOPY  FTE_RATE_CHART_PKG.qp_pricing_attrib_tbl,
	                        x_status     		OUT NOCOPY  	NUMBER,
                                x_error_msg  		OUT NOCOPY  	VARCHAR2) IS

  l_group               NUMBER;
  l_phase               NUMBER;
  l_precedence          NUMBER;
  l_prcbrk_linenum      NUMBER;
  l_product_attribute   VARCHAR2(50);
  l_pricing_attribute   VARCHAR2(50);
  l_item                VARCHAR2(30);
  l_attribute2          VARCHAR2(30);  -- used to save the fixed price
  l_operator            VARCHAR2(30);
  l_action           	VARCHAR2(20);
  l_linenum             VARCHAR2(20);

  l_attribute1          VARCHAR2(50);
  l_attr_value_from     NUMBER;
  l_attr_value_to       NUMBER;
  l_context             VARCHAR2(50);
  l_comp_operator       VARCHAR2(30);
  l_break_price         NUMBER;
  l_low_val             NUMBER;
  l_lower               NUMBER;
  l_upper               NUMBER;
  l_tmp_d               NUMBER;

  l_brk_hdr_stored      BOOLEAN;
  l_brk_hdr_updated     BOOLEAN;
  l_count               NUMBER;
  l_type                VARCHAR2(50);
  l_rate_type           VARCHAR2(50);
  l_subtype             VARCHAR2(50);
  l_break_type_code     VARCHAR2(30);
  l_mod_level_code      VARCHAR2(30);
  l_formula_id          NUMBER;

  -- Variables used for error messages
  l_tokens              STRINGARRAY;
  l_values              STRINGARRAY;
  l_chart_type		VARCHAR2(50) := FTE_RATE_CHART_PKG.g_chart_type;

  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_RATE_BREAK';

  BEGIN
    x_status := -1;
    FTE_UTIL_PKG.ENTER_Debug(l_module_name);

    l_precedence        := 220;
    l_prcbrk_linenum    := 0;
    l_product_attribute := null;
    l_item              := 'ALL';
    l_attribute2        := '';
    x_status            := -1;
    l_break_type_code   := 'PLL';

    l_action            := FTE_UTIL_PKG.GET_DATA('ACTION', p_values);
    l_linenum           := FTE_UTIL_PKG.GET_DATA('LINE_NUMBER', p_values);
    l_attr_value_from   := Fnd_Number.Canonical_To_Number(FTE_UTIL_PKG.GET_DATA('LOWER_LIMIT', p_values));
    l_attr_value_to     := Fnd_Number.Canonical_To_Number(FTE_UTIL_PKG.GET_DATA('UPPER_LIMIT', p_values));
    l_break_price       := Fnd_Number.Canonical_To_Number(FTE_UTIL_PKG.GET_DATA('RATE', p_values));
    l_rate_type         := FTE_UTIL_PKG.GET_DATA('RATE_TYPE', p_values);
    l_pricing_attribute := FTE_UTIL_PKG.GET_DATA('ATTRIBUTE', p_values);
    l_context           := FTE_UTIL_PKG.GET_DATA('CONTEXT', p_values);
    l_formula_id        := FTE_UTIL_PKG.GET_DATA('FORMULA_ID', p_values);

    IF (l_chart_type  IN ('TL_MODIFIER', 'MIN_MODIFIER', 'FAC_MODIFIER')) THEN
      l_phase := 2;
      l_group := 22;
      l_mod_level_code  := FTE_UTIL_PKG.GET_DATA('MOD_LEVEL_CODE', p_values);
      l_subtype         := FTE_UTIL_PKG.GET_DATA('SUBTYPE', p_values);
      l_type            := FTE_UTIL_PKG.GET_DATA('TYPE', p_values);
      l_break_type_code := 'SUR';
    END IF;

    IF (l_mod_level_code = 'LINEGROUP') THEN
      l_phase := 3;
    ELSE
      l_mod_level_code := 'LINE';
    END IF;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', l_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate type', l_rate_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute', l_pricing_attribute);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute value', l_attr_value_from );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute value to', l_attr_value_to );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate', l_break_price );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Context', l_context);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Formula ID', l_formula_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    IF (p_validate) THEN
      IF (l_linenum IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_LINE_NUMBER_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                     		    p_msg		=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      ELSIF (isNum(l_linenum) = 0) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_NUMBER_INVALID');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg		=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      END IF;
    END IF;

    --Inherit line level rate type if not specified at the break level.
    IF (l_rate_type IS NULL) THEN
      l_rate_type := FTE_RATE_CHART_PKG.G_Prc_Rate_Type;

      -- if both line rate type and break line rate type are null, then error
      IF (l_rate_type IS NULL) THEN
        x_error_msg := Fte_Util_PKG.Get_Msg(p_name   => 'FTE_RATE_TYPE_INVALID',
                                            p_tokens => STRINGARRAY('RATE_TYPE'),
                                            p_values => STRINGARRAY(l_rate_type));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		   p_msg		=> x_error_msg,
                   		   p_category		=> 'D',
				   p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
	RETURN;
      END IF;
    ELSE
      IF (p_validate) THEN
        l_rate_type := Validate_Rate_Type(p_rate_type  => l_rate_type,
					  p_line_number	 => l_linenum,
					  x_status     => x_status,
					  x_error_msg  => x_error_msg);

        IF (x_status <> -1) THEN
	  FTE_UTIL_PKG.Exit_Debug(l_module_name);
	  return;
        END IF;
      END IF;
    END IF;

    l_operator := l_rate_type;

    IF (p_validate) THEN
      VALIDATE_ACTION(p_action		=> l_action,
		      p_type		=> 'RATE_BREAK',
		      p_line_number 	=> p_line_number,
		      x_status		=> x_status,
		      x_error_msg	=> x_error_msg);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        return;
      END IF;

      IF (l_attr_value_to IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_UPPER_LIMIT_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg	  	=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      ELSE
        IF (l_attr_value_from IS NULL) THEN
          -- set break_from
          IF (FTE_RATE_CHART_PKG.G_previous_upper = 0 OR FTE_RATE_CHART_PKG.G_previous_upper IS NULL) THEN
            l_attr_value_from := 0;  --continuous break start with 0
          ELSE
            l_low_val    := FTE_RATE_CHART_PKG.G_previous_upper;
            l_attr_value_from := l_low_val;
          END IF;
        END IF;
        -- check if UPPER_LIMIT is greater than or equal to LOWER_LIMIT
        l_lower := l_attr_value_from;
        l_upper := l_attr_value_to;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
          FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute Value From', l_attr_value_from);
          FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute Value To', l_attr_value_to);
  	END IF;

        IF (l_lower > l_upper) THEN
          x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_BREAKS_BAD_LIMITS');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		      p_msg		=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
          RETURN;
        END IF;

        l_tmp_d  := l_attr_value_to;
        FTE_RATE_CHART_PKG.G_previous_upper := l_tmp_d;
      END IF;

      IF (l_break_price IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_RATE_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                     		    p_msg 		=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      END IF;

      IF (FTE_RATE_CHART_PKG.G_Prc_Brk_Type IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_RATE_BREAK_TYPE_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg		=> x_error_msg,
                     		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      END IF;

      IF (FTE_RATE_CHART_PKG.G_Prc_Vol_Type IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_VOLUME_TYPE_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg		=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      END IF;
    END IF;

    IF (l_context IS NULL) THEN
      l_context := 'VOLUME';
    END IF;

    IF (FTE_RATE_CHART_PKG.G_IS_LTL) THEN
      l_attribute2  := l_break_price*100;
    END IF;

    IF (l_action IN ('ADD', 'UPDATE')) THEN

      --Update this break's header line with the code 'PBH'
      l_count := p_qp_list_line_tbl.COUNT;

      p_qp_list_line_tbl(FTE_RATE_CHART_PKG.g_cur_line_index).LIST_LINE_TYPE_CODE := 'PBH';
      p_qp_list_line_tbl(FTE_RATE_CHART_PKG.g_cur_line_index).PRICE_BREAK_TYPE_CODE := FTE_RATE_CHART_PKG.g_prc_brk_type;

      l_count := p_qp_list_line_tbl.COUNT+1;

      p_qp_list_line_tbl(l_count).PROCESS_ID           := FTE_RATE_CHART_PKG.G_Process_Id;
      p_qp_list_line_tbl(l_count).OPERAND              := l_break_price;

      p_qp_list_line_tbl(l_count).PRICE_BREAK_TYPE_CODE := FTE_RATE_CHART_PKG.G_Prc_Brk_Type;
      p_qp_list_line_tbl(l_count).PRODUCT_PRECEDENCE   := l_precedence;
      p_qp_list_line_tbl(l_count).COMMENTS             := FTE_RATE_CHART_PKG.G_Prc_Line_Desc;
      p_qp_list_line_tbl(l_count).LIST_LINE_NO         := l_linenum;
      p_qp_list_line_tbl(l_count).PRICE_BREAK_HEADER_INDEX := FTE_RATE_CHART_PKG.G_Prc_Brk_Hdr_Index;
      p_qp_list_line_tbl(l_count).RLTD_MODIFIER_GRP_NO := FTE_RATE_CHART_PKG.G_Mod_Grp;
      p_qp_list_line_tbl(l_count).ATTRIBUTE2           := l_attribute2;
      p_qp_list_line_tbl(l_count).ARITHMETIC_OPERATOR  := l_operator;

      p_qp_list_line_tbl(l_count).PROCESS_TYPE         := 'SSH';
      p_qp_list_line_tbl(l_count).INTERFACE_ACTION_CODE := 'C';
      p_qp_list_line_tbl(l_count).LIST_LINE_TYPE_CODE  := l_break_type_code;
      p_qp_list_line_tbl(l_count).AUTOMATIC_FLAG       := 'Y';
      p_qp_list_line_tbl(l_count).OVERRIDE_FLAG        := 'N';
      p_qp_list_line_tbl(l_count).ACCRUAL_FLAG         := 'N';
      p_qp_list_line_tbl(l_count).MODIFIER_LEVEL_CODE  := l_mod_level_code;

      p_qp_list_line_tbl(l_count).PRICING_GROUP_SEQUENCE := l_group;
      p_qp_list_line_tbl(l_count).PRICING_PHASE_ID     := l_phase;
      p_qp_list_line_tbl(l_count).QUALIFICATION_IND    := NULL;
      p_qp_list_line_tbl(l_count).CHARGE_TYPE_CODE     := l_type;
      p_qp_list_line_tbl(l_count).CHARGE_SUBTYPE_CODE  := l_subtype;
      p_qp_list_line_tbl(l_count).ATTRIBUTE1           := l_attribute1;
      p_qp_list_line_tbl(l_count).PRICE_BY_FORMULA_ID  := l_formula_id;

      p_qp_list_line_tbl(l_count).RLTD_MODIFIER_GRP_TYPE := 'PRICE BREAK';
      p_qp_list_line_tbl(l_count).PRIMARY_UOM_FLAG     := NULL;

      FTE_RATE_CHART_PKG.G_Mod_Grp := FTE_RATE_CHART_PKG.G_Mod_Grp + 1;

      l_product_attribute := 'PRICING_ATTRIBUTE3';

      IF (l_pricing_attribute IS NULL) THEN
        IF (FTE_RATE_CHART_PKG.G_Prc_Vol_Type = 'QUANTITY') THEN
          l_pricing_attribute := 'ITEM_QUANTITY';
        ELSIF (FTE_RATE_CHART_PKG.G_Prc_Vol_Type = 'TOTAL_QUANTITY') THEN
          l_pricing_attribute := 'TOTAL_ITEM_QUANTITY';
        END IF;
      END IF;

      IF (l_attr_value_from IS NOT NULL AND
          l_attr_value_to IS NOT NULL) THEN
        l_comp_operator := 'BETWEEN';
      ELSIF (l_attr_value_from IS NOT NULL) THEN
        l_comp_operator := '=';
      END IF;

      l_group := 1;

      l_count := p_qp_pricing_attrib_tbl.COUNT+1;

      p_qp_pricing_attrib_tbl(l_count).PROCESS_ID                  := FTE_RATE_CHART_PKG.G_Process_Id;
      p_qp_pricing_attrib_tbl(l_count).PRODUCT_ATTRIBUTE           := l_product_attribute;
      p_qp_pricing_attrib_tbl(l_count).PRODUCT_ATTR_VALUE          := l_item;
      p_qp_pricing_attrib_tbl(l_count).PRODUCT_UOM_CODE            := FTE_RATE_CHART_PKG.G_Product_UOM;
      p_qp_pricing_attrib_tbl(l_count).PRICING_ATTRIBUTE           := l_pricing_attribute;
      p_qp_pricing_attrib_tbl(l_count).PRICING_ATTR_VALUE_FROM     := fnd_number.number_to_canonical(l_attr_value_from);
      p_qp_pricing_attrib_tbl(l_count).PRICING_ATTR_VALUE_TO       := fnd_number.number_to_canonical(l_attr_value_to);
      p_qp_pricing_attrib_tbl(l_count).ATTRIBUTE_GROUPING_NO       := l_group;
      p_qp_pricing_attrib_tbl(l_count).LIST_LINE_NO                := l_linenum;

      p_qp_pricing_attrib_tbl(l_count).PROCESS_TYPE                := 'SSH';
      p_qp_pricing_attrib_tbl(l_count).INTERFACE_ACTION_CODE       := 'C';
      p_qp_pricing_attrib_tbl(l_count).EXCLUDER_FLAG               := 'N';
      p_qp_pricing_attrib_tbl(l_count).PRODUCT_ATTRIBUTE_CONTEXT   := 'ITEM';
      p_qp_pricing_attrib_tbl(l_count).PRODUCT_ATTRIBUTE_DATATYPE  := 'C';
      p_qp_pricing_attrib_tbl(l_count).PRICING_ATTRIBUTE_DATATYPE  := 'N';
      p_qp_pricing_attrib_tbl(l_count).PRICING_ATTRIBUTE_CONTEXT   := l_context;
      p_qp_pricing_attrib_tbl(l_count).COMPARISON_OPERATOR_CODE    := l_comp_operator;

    END IF;

    FTE_RATE_CHART_PKG.g_chart_type := l_chart_type;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
               			  p_msg   		=> x_error_msg,
             			  p_category    	=> 'O',
	        		  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
  END VALIDATE_RATE_BREAK;

  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_RATING_ATTRIBUTE
  --
  -- Purpose: Validate the data corresponding to this pricing attribute, and
  --          store the data in temporary tables for later insertion into
  --          QP_INTERFACE_PRICING_ATTRIBS.
  --
  -- IN Parameters
  --    1. p_values: 		pl/sql table for rating attribute line
  --	2. p_line_number:	line number
  --
  -- Out Parameters
  --	1. p_qp_pricing_attrib_tbl:	pl/sql table for the attributes
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_RATING_ATTRIBUTE(p_values     	IN    		FTE_BULKLOAD_PKG.data_values_tbl,
				      p_line_number	IN		NUMBER,
				      p_qp_pricing_attrib_tbl	IN OUT	NOCOPY FTE_RATE_CHART_PKG.qp_pricing_attrib_tbl,
	                      	      x_status     	OUT NOCOPY  	NUMBER,
                                      x_error_msg  	OUT NOCOPY  	VARCHAR2) IS

  l_intAction       VARCHAR2(30);

  l_description     VARCHAR2(100);
  l_carrier_code    VARCHAR2(100);
  l_carrier_name    VARCHAR2(100);
  l_list_header_id  NUMBER;
  l_comp_operator   VARCHAR2(30);

  l_delimiter                 VARCHAR2(30);
  l_action         	      VARCHAR2(20);
  l_linenum                   VARCHAR2(20);
  l_pricing_attribute         VARCHAR2(50);
  l_pricing_attr_value_from   VARCHAR2(50);
  l_pricing_attr_value_to     VARCHAR2(50);
  l_region_id                 NUMBER;
  l_context                   VARCHAR2(30) := 'LOGISTICS';

  l_catg_id             NUMBER;
  l_attr_code           VARCHAR2(50);

  l_zone_id             NUMBER;
  l_chart_type		VARCHAR2(50) := FTE_RATE_CHART_PKG.g_chart_type;

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_RATING_ATTRIBUTE';

  BEGIN
    FTE_UTIL_PKG.ENTER_Debug(l_module_name);

    l_list_header_id := -1;
    x_status         := -1;

    l_action                  := FTE_UTIL_PKG.GET_DATA('ACTION', p_values);
    l_linenum                 := FTE_UTIL_PKG.GET_DATA('LINE_NUMBER', p_values);
    l_pricing_attribute       := FTE_UTIL_PKG.GET_DATA('ATTRIBUTE', p_values);
    l_pricing_attr_value_from := FTE_UTIL_PKG.GET_DATA('ATTRIBUTE_VALUE', p_values);
    l_pricing_attr_value_to   := FTE_UTIL_PKG.GET_DATA('ATTRIBUTE_VALUE_TO', p_values);
    l_context                 := FTE_UTIL_PKG.GET_DATA('CONTEXT', p_values);
    l_comp_operator           := FTE_UTIL_PKG.GET_DATA('COMPARISON_OPERATOR', p_values);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', l_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute', l_pricing_attribute);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute value', l_pricing_attr_value_from );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute value to', l_pricing_attr_value_to );
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Context', l_context);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Comparison operator', l_comp_operator);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    l_region_id := -1;

    VALIDATE_ACTION(p_action		=> l_action,
		    p_type		=> 'RATING_ATTRIBUTE',
		    p_line_number 	=> p_line_number,
		    x_status		=> x_status,
		    x_error_msg		=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      return;
    END IF;

    IF (l_linenum IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_LINE_NUMBER_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name		=> l_module_name,
                   		  p_msg 		=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN;
    ELSIF (isNum(l_linenum) = 0) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_NUMBER_INVALID');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		  p_msg  		=> x_error_msg,
                   		  p_category		=> 'D',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN;
    END IF;

    IF (l_context IS NULL) THEN
      l_context := 'LOGISTICS';
    END IF;

    IF (l_pricing_attribute IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_ATTRIBUTE_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name		=> l_module_name,
                   		  p_msg 		=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN;
    ELSIF l_pricing_attribute NOT IN ('COMMODITY'           ,'COMMODITY_TYPE',
			              'CONTAINER_TYPE',
                                      'SERVICE_LEVEL'       ,'HAZARD_CODE',
                                      'TL_RATE_BASIS'       ,'TL_DISTANCE_TYPE',
                                      'TL_RATE_TYPE'        ,'TL_EQUIPMENT_TYPE',
                                      'ITEM_QUANTITY'       ,'ITEM_AMOUNT',
                                      'TL_NUM_STOPS'        ,'TL_VEHICLE_TYPE',
                                      'TL_DEADHEAD_RT_VAR',  'TL_WEEKEND_LAYOVER_MILEAGE',
                                      'TL_PICKUP_WT'        ,'TL_PICKUP_VOL',
                                      'TL_PICKUP_PALLET'    ,'TL_PICKUP_CONTAINER',
                                      'TL_DROPOFF_WT'       ,'TL_DROPOFF_VOL',
                                      'TL_DROPOFF_PALLET'   ,'TL_DROPOFF_CONTAINER',
                                      'TL_HANDLING_VOL'     ,'TL_HANDLING_WT',
                                      'TL_STOP_UNLOADING_ACT', 'TL_STOP_LOADING_ACT',
                                      'TL_HANDLING_ACT',
                                      'FAC_PICKUP_WT'        ,'FAC_PICKUP_VOL',
                                      'FAC_PICKUP_PALLET'    ,'FAC_PICKUP_CONTAINER',
                                      'FAC_DROPOFF_WT'       ,'FAC_DROPOFF_VOL',
                                      'FAC_DROPOFF_PALLET'   ,'FAC_DROPOFF_CONTAINER',
                                      'FAC_HANDLING_VOL'     ,'FAC_HANDLING_WT',
                                      'FAC_HANDLING_CONTAINER', 'FAC_HANDLING_PALLET',
                                      'TL_NUM_WEEKDAY_LAYOVERS' ,'TL_CHARGED_OUT_RT_DISTANCE',
                                      'TL_CM_DISCOUNT_FLG', 'LOADING_PROTOCOL',
                                      'FREIGHT_CLASS'       ,'PARCEL_MULTIPIECE_FLAG',
                                      'ORIGIN_CITY'         ,'ORIGIN_STATE',
                                      'ORIGIN_COUNTRY'      ,'ORIGIN_POSTAL_CODE_FROM',
                                      'ORIGIN_ZONE'         ,'ORIGIN_POSTAL_CODE_TO',
                                      'ORIGIN_ZONE_ID'      ,'DESTINATION_ZONE_ID',
                                      'DESTINATION_COUNTRY' ,'DESTINATION_STATE',
                                      'DESTINATION_CITY'    ,'DESTINATION_POSTAL_CODE_FROM',
                                      'DESTINATION_ZONE'    ,'DESTINATION_POSTAL_CODE_TO') THEN

      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_ATTRIBUTE_INVALID');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name		=> l_module_name,
                   		  p_msg 		=> x_error_msg,
                   		  p_category		=> 'D',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN;
    ELSIF (l_pricing_attr_value_from IS NULL) THEN
      --'tl_modifiers' have several attributes that don't require values.
      IF (l_chart_type NOT IN ('TL_MODIFIER', 'FAC_MODIFIER', 'MIN_MODIFIER')) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_ATTR_VALUE_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		  p_msg 		=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      END IF;
    END IF;

    --In the case of Origins and Destinations, we have to make sure we have all the information
    --for the origin or destination before we insert the origin/destination ID into the table.
    --Therefore we have to store each line with [ORIGIN/DESTINATION]_[COUNTRY/STATE/CITY] in
    --G_region_info until we are sure we have all the information.
    IF (SUBSTR(l_pricing_attribute, 1, 6) = 'ORIGIN' AND
      l_pricing_attribute NOT IN ('ORIGIN_ZONE', 'ORIGIN_ZONE_ID')) THEN --(1)

      IF (FTE_RATE_CHART_PKG.g_region_flag IS NULL) THEN
        FTE_RATE_CHART_PKG.Reset_Region_Info;
      ELSIF (FTE_RATE_CHART_PKG.g_region_flag = 'DESTINATION' OR FTE_RATE_CHART_PKG.g_region_linenum <> l_linenum) THEN
        l_region_id := FTE_REGION_ZONE_LOADER.GET_REGION_ID(p_region_info	=> FTE_RATE_CHART_PKG.G_region_info);

        IF (l_region_id IS NOT NULL OR l_region_id <> -1) THEN
          ADD_ATTRIBUTE(p_pricing_attribute  => FTE_RATE_CHART_PKG.g_region_flag||'_ZONE',
                        p_attr_value_from    => l_region_id,
                        p_attr_value_to      => NULL,
                        p_line_number        => FTE_RATE_CHART_PKG.g_region_linenum,
                        p_context            => l_context,
                        p_comp_operator      => NULL,
			p_qp_pricing_attrib_tbl => p_qp_pricing_attrib_tbl,
                        x_status             => x_status,
			x_error_msg	     => x_error_msg);
        ELSE
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_REGION_UNKNOWN',
					      p_tokens		=> STRINGARRAY('REGION_NAME'),
					      p_values		=> STRINGARRAY(FTE_RATE_CHART_PKG.g_region_info.country ||' '||
								       FTE_RATE_CHART_PKG.g_region_info.state ||' '||
								       FTE_RATE_CHART_PKG.g_region_info.city));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		      p_msg	 	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);

          FTE_RATE_CHART_PKG.Reset_Region_Info;
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
          RETURN;
        END IF;
        FTE_RATE_CHART_PKG.Reset_Region_Info;
      END IF;

      IF (l_pricing_attribute = 'ORIGIN_COUNTRY') THEN
        FTE_RATE_CHART_PKG.G_region_info.country := l_pricing_attr_value_from;
      ELSIF (l_pricing_attribute = 'ORIGIN_STATE') THEN
        FTE_RATE_CHART_PKG.G_region_info.state := l_pricing_attr_value_from;
      ELSIF (l_pricing_attribute = 'ORIGIN_CITY') THEN
        FTE_RATE_CHART_PKG.G_region_info.city := l_pricing_attr_value_from;
      ELSIF (l_pricing_attribute = 'ORIGIN_POSTAL_CODE_FROM') THEN
        FTE_RATE_CHART_PKG.G_region_info.postal_code_from := l_pricing_attr_value_from;
      ELSIF (l_pricing_attribute = 'ORIGIN_POSTAL_CODE_TO') THEN
        FTE_RATE_CHART_PKG.G_region_info.postal_code_to := l_pricing_attr_value_from;
      END IF;
      FTE_RATE_CHART_PKG.g_region_flag := 'ORIGIN';
      FTE_RATE_CHART_PKG.g_region_linenum := l_linenum;

    ELSIF (substr(l_pricing_attribute,1,11) = 'DESTINATION' AND
      l_pricing_attribute NOT IN ('DESTINATION_ZONE', 'DESTINATION_ZONE_ID')) THEN --(1)

      IF (FTE_RATE_CHART_PKG.g_region_flag IS NULL) THEN  -- start of New DESTINATION
        FTE_RATE_CHART_PKG.Reset_Region_Info;
      ELSIF (FTE_RATE_CHART_PKG.g_region_flag = 'ORIGIN' OR FTE_RATE_CHART_PKG.g_region_linenum <> l_linenum) THEN

	l_region_id := FTE_REGION_ZONE_LOADER.GET_REGION_ID(p_region_info	=> FTE_RATE_CHART_PKG.G_region_info);

        IF (l_region_id IS NOT NULL OR l_region_id <> -1) THEN
          ADD_ATTRIBUTE(p_pricing_attribute  => FTE_RATE_CHART_PKG.g_region_flag||'_ZONE',
                        p_attr_value_from    => l_region_id,
                        p_attr_value_to      => NULL,
                        p_line_number        => FTE_RATE_CHART_PKG.g_region_linenum,
                        p_context            => l_context,
                        p_comp_operator      => NULL,
			p_qp_pricing_attrib_tbl => p_qp_pricing_attrib_tbl,
                        x_status             => x_status,
			x_error_msg	     => x_error_msg);
        ELSE
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_REGION_UNKNOWN',
					      p_tokens		=> STRINGARRAY('REGION_NAME'),
					      p_values		=> STRINGARRAY(FTE_RATE_CHART_PKG.g_region_info.country ||' '||
								       FTE_RATE_CHART_PKG.g_region_info.state ||' '||
								       FTE_RATE_CHART_PKG.g_region_info.city));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		      p_msg	 	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);

          FTE_RATE_CHART_PKG.Reset_Region_Info;
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
          RETURN;
        END IF;
        FTE_RATE_CHART_PKG.Reset_Region_Info;
      END IF;

      IF (l_pricing_attribute = 'DESTINATION_COUNTRY') THEN
        FTE_RATE_CHART_PKG.G_region_info.country := l_pricing_attr_value_from;
      ELSIF (l_pricing_attribute = 'DESTINATION_STATE') THEN
        FTE_RATE_CHART_PKG.G_region_info.state := l_pricing_attr_value_from;
      ELSIF (l_pricing_attribute = 'DESTINATION_CITY') THEN
        FTE_RATE_CHART_PKG.G_region_info.city := l_pricing_attr_value_from;
      ELSIF (l_pricing_attribute = 'DESTINATION_POSTAL_CODE_FROM') THEN
        FTE_RATE_CHART_PKG.G_region_info.postal_code_from := l_pricing_attr_value_from;
      ELSIF (l_pricing_attribute = 'DESTINATION_POSTAL_CODE_TO') THEN
        FTE_RATE_CHART_PKG.G_region_info.postal_code_to := l_pricing_attr_value_from;
      END IF;

      FTE_RATE_CHART_PKG.g_region_flag := 'DESTINATION';
      FTE_RATE_CHART_PKG.g_region_linenum := l_linenum;
      FTE_RATE_CHART_PKG.g_region_context := l_context;
    ELSE --(1)
      IF (l_pricing_attribute IN ('ORIGIN_ZONE', 'DESTINATION_ZONE')) THEN --(2)

        -- get ZONE_ID from ZONE_NAME
        l_zone_id := FTE_REGION_ZONE_LOADER.GET_ZONE_ID(l_pricing_attr_value_from);

        IF (l_zone_id <> -1 OR l_zone_id IS NOT NULL) THEN
          l_pricing_attr_value_from := l_zone_id;
        ELSE
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_ZONE_UNKNOWN',
					      p_tokens		=> STRINGARRAY('ZONE'),
					      p_values		=> STRINGARRAY(l_pricing_attr_value_from));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		      p_msg	 	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);

          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
          RETURN;
        END IF;
      ELSIF (l_pricing_attribute = 'ORIGIN_ZONE_ID') THEN
        l_pricing_attribute := 'ORIGIN_ZONE';
      ELSIF (l_pricing_attribute = 'DESTINATION_ZONE_ID') THEN
        l_pricing_attribute := 'DESTINATION_ZONE';
      ELSIF (l_pricing_attribute = 'TOTAL_SHIPMENT_QUANTITY') THEN
        l_pricing_attr_value_to := '9999999999';
      ELSIF (l_pricing_attribute =  'SERVICE_LEVEL') THEN
        l_attr_code := Validate_Service_Level (p_carrier_id		=> NULL,
                            		       p_carrier_name		=> NULL,
                            		       p_service_level 		=> l_pricing_attr_value_from,
                            		       p_line_number		=> p_line_number,
                  			       x_status 		=> x_status,
                            		       x_error_msg 		=> x_error_msg);

        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          RETURN;
        END IF;

        l_pricing_attribute := 'SERVICE_TYPE';

        IF (l_attr_code IS NOT NULL) THEN
          l_pricing_attr_value_from := l_attr_code;
        END IF;
      ELSIF (l_pricing_attribute =  'CONTAINER_TYPE') THEN --(2)

        l_pricing_attribute := 'CONTAINER_TYPE';
        l_attr_code := FTE_UTIL_PKG.Get_Lookup_Code('CONTAINER_TYPE', l_pricing_attr_value_from);

        IF (l_attr_code IS NOT NULL) THEN
          l_pricing_attr_value_from := l_attr_code;
        ELSE
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_CONTAINER_UNKNOWN',
					      p_tokens		=> STRINGARRAY('CONTAINER'),
					      p_values		=> STRINGARRAY(l_pricing_attr_value_from));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		      p_msg	 	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);

          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
          RETURN;
        END IF;

      ELSIF (SUBSTR(l_pricing_attribute,1,9) =  'COMMODITY') THEN  --(2)
        FTE_UTIL_PKG.GET_CATEGORY_ID(p_commodity_value => l_pricing_attr_value_from,
                          	      x_catg_id         => l_pricing_attr_value_from,
				      x_status		=> x_status,
				      x_error_msg	=> x_error_msg);

        IF (l_pricing_attr_value_from IS NULL) THEN
          l_pricing_attr_value_from := FTE_UTIL_PKG.GET_DATA('ATTRIBUTE_VALUE', p_values);
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_COMMODITY_UNKNOWN',
				      p_tokens		=> STRINGARRAY('COMM'),
				      p_values		=> STRINGARRAY(l_pricing_attr_value_from));
 	  FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		      p_msg	 	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);

          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
          RETURN;
        END IF;
      ELSIF (l_pricing_attribute = 'TL_VEHICLE_TYPE') THEN
        l_pricing_attribute     := 'VEHICLE';
        l_pricing_attr_value_from := FTE_UTIL_PKG.Get_Vehicle_Type(p_vehicle_type => l_pricing_attr_value_from);

        IF (l_pricing_attr_value_from IS NULL) THEN

          l_pricing_attr_value_from := FTE_UTIL_PKG.GET_DATA('ATTRIBUTE_VALUE', p_values);

          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_VEHICLE_NAME_INVALID',
				  	      p_tokens		=> STRINGARRAY('NAME'),
					      p_values		=> STRINGARRAY(l_pricing_attr_value_from));
 	  FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
	                  	      p_msg	   	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);

          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
          RETURN;
        END IF;
      ELSIF (l_pricing_attribute = 'TL_NUM_STOPS') THEN
        l_pricing_attr_value_from := NULL;
      END IF; --end --(2)

      IF (FTE_RATE_CHART_PKG.g_region_flag IS NOT NULL) THEN
        -- Insert previous ORIGIN or DESTINATION Region Attribute
        l_region_id := FTE_REGION_ZONE_LOADER.GET_REGION_ID(p_region_info => FTE_RATE_CHART_PKG.G_region_info);

        IF (l_region_id IS NOT NULL OR l_region_id <> -1) THEN
          ADD_ATTRIBUTE(p_pricing_attribute  => FTE_RATE_CHART_PKG.g_region_flag ||'_ZONE',
                        p_attr_value_from    => l_region_id,
                        p_attr_value_to      => NULL,
                        p_line_number        => FTE_RATE_CHART_PKG.g_region_linenum,
                        p_context            => l_context,
                        p_comp_operator      => NULL,
			p_qp_pricing_attrib_tbl => p_qp_pricing_attrib_tbl,
                        x_status             => x_status,
			x_error_msg	     => x_error_msg);
        ELSE
          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_REGION_UNKNOWN',
					      p_tokens		=> STRINGARRAY('REGION_NAME'),
					      p_values		=> STRINGARRAY(FTE_RATE_CHART_PKG.g_region_info.country ||' '||
								       FTE_RATE_CHART_PKG.g_region_info.state ||' '||
								       FTE_RATE_CHART_PKG.g_region_info.city));
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		      p_msg	 	=> x_error_msg,
                   		      p_category	=> 'D',
				      p_line_number	=> p_line_number);

          FTE_RATE_CHART_PKG.Reset_Region_Info;
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          x_status := 2;
          RETURN;
        END IF;
      END IF;

      -- Insert Current Attribute
      IF (l_linenum <> FTE_RATE_CHART_PKG.g_line_number) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_PRC_ATTR_WRONG_LINE',
					    p_tokens		=> STRINGARRAY('VALUE'),
					    p_values		=> STRINGARRAY(l_pricing_attr_value_from));
 	FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		    p_msg 		=> x_error_msg,
                   		    p_category		=> 'D',
				    p_line_number	=> p_line_number);

        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      END IF;

      ADD_ATTRIBUTE(p_pricing_attribute  => l_pricing_attribute,
                    p_attr_value_from    => l_pricing_attr_value_from,
                    p_attr_value_to      => l_pricing_attr_value_to,
                    p_line_number        => l_linenum,
                    p_context            => l_context,
                    p_comp_operator      => l_comp_operator,
		    p_qp_pricing_attrib_tbl => p_qp_pricing_attrib_tbl,
                    x_status             => x_status,
		    x_error_msg		 => x_error_msg);

      FTE_RATE_CHART_PKG.g_region_flag := NULL;
      FTE_RATE_CHART_PKG.Reset_Region_Info;
    END IF; --end --(1)
    FTE_RATE_CHART_PKG.g_chart_type := l_chart_type;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
               			  p_msg   		=> x_error_msg,
             			  p_category    	=> 'O',
	        		  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
  END VALIDATE_RATING_ATTRIBUTE;

  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_ADJUSTED_RATE_CHART
  --
  -- Purpose: Validate the data corresponding to this Qualifier, and
  --          store the data in temporary tables for later insertion into
  --          QP_INTERFACE_QUALIFIERS.
  --
  -- IN Parameters
  --    1. p_values: 		pl/sql table for adjusted rate chart line
  --	2. p_line_number:	line number
  --	3. p_carrier_id:	carrier id from the header
  --
  -- Out Parameters
  --	1. p_qp_qualifier_tbl:	pl/sql table for the attributes
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_ADJUSTED_RATE_CHART(p_values     	IN    		FTE_BULKLOAD_PKG.data_values_tbl,
					 p_line_number	IN		NUMBER,
					 p_carrier_id	IN		NUMBER,
			       		 p_qp_qualifier_tbl	IN OUT	NOCOPY FTE_RATE_CHART_PKG.qp_qualifier_tbl,
	                       		 x_status     	OUT NOCOPY  	NUMBER,
                               		 x_error_msg  	OUT NOCOPY  	VARCHAR2) IS

  l_action                 VARCHAR2(30);
  l_name                   VARCHAR2(50);
  l_derived_qualifier      VARCHAR2(30);
  l_qualifier_attr         VARCHAR2(30);
  l_qualifier_context      VARCHAR2(30);
  l_qualifier_group        NUMBER;
  l_carrier_id             NUMBER;
  l_list_header_id         NUMBER;
  l_tariff		   VARCHAR2(60);
  l_list_header_ids	   Wsh_Util_Core.Id_Tab_Type;
  l_valid_carrier	   BOOLEAN;
  l_module_name   CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_ADJUSTED_RATE_CHART';
  l_temp		   VARCHAR2(50);
  l_count		   NUMBER;
  l_chart_type		   VARCHAR2(50) := FTE_RATE_CHART_PKG.g_chart_type;

  BEGIN
    FTE_UTIL_PKG.ENTER_Debug(l_module_name);
    x_status           := -1;
    l_qualifier_group  := 1;

    l_action := FTE_UTIL_PKG.GET_DATA('ACTION', p_values);
    l_name   := FTE_UTIL_PKG.GET_DATA('RATE_CHART_NAME', p_values);
    l_tariff := FTE_UTIL_PKG.GET_DATA('TARIFF_NAME', p_values);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', l_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate Chart name', l_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Tariff Name', l_tariff);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    VALIDATE_ACTION(p_action		=> l_action,
		    p_type		=> 'ADJUSTED_RATE_CHART',
		    p_line_number 	=> p_line_number,
		    x_status		=> x_status,
		    x_error_msg		=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      return;
    END IF;

    IF (l_name IS NOT NULL AND l_tariff IS NOT NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_BOTH_RC_TARIFF');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name		=> l_module_name,
                   		  p_msg 		=> x_error_msg,
                   		  p_category		=> 'D',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN;

    ELSIF (l_name IS NULL AND l_tariff IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_NEITHER_RC_TARIFF');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name		=> l_module_name,
                   		  p_msg 		=> x_error_msg,
                   		  p_category		=> 'D',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN;
    END IF;

    --Facility Modifiers don't need a carrier.
    IF (l_chart_type <> 'FAC_MODIFIER') THEN
      l_carrier_id := p_carrier_id;
      IF (l_carrier_id IS NULL) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_CARRIER_MISSING');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		    p_msg 		=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
      END IF;
    END IF;

    IF (l_chart_type IN ('FTE_MODIFIER', 'FAC_MODIFIER')) THEN
      l_derived_qualifier    := 'PRICE_LIST';
      l_qualifier_attr       := 'PRICE_LIST';
      l_qualifier_context    := 'MODLIST';
    END IF;

    IF (l_name IS NOT NULL) THEN
      l_list_header_id := FTE_RATE_CHART_PKG.Get_Pricelist_Id(p_name 	   => l_name,
                                               		      p_carrier_id => l_carrier_id,
					       		      p_attribute1 => l_temp);

      IF (l_list_header_id = -1) THEN
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_PRICELIST_INVALID',
					    p_tokens		=> STRINGARRAY('NAME'),
					    p_values		=> STRINGARRAY(l_name));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                   		    p_msg 		=> x_error_msg,
                   		    p_category		=> 'C',
				    p_line_number	=> p_line_number);

        x_status := 2;
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN;

      ELSE
	l_list_header_ids(1) := l_list_header_id;
      END IF;

    ELSE --l_tariff IS NOT NULL
--check these procedures in LTL
      l_valid_carrier := FTE_LTL_LOADER.Verify_Tariff_Carrier(l_tariff, l_carrier_id, x_error_msg);
      IF (l_valid_carrier) THEN
	l_list_header_ids := FTE_LTL_LOADER.Get_Tariff_Ratecharts(p_tariff_name => l_tariff,
			                                          x_error_msg => x_error_msg);
      ELSE
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_TARIFF_NOT_ASSOC',
					    p_tokens		=> STRINGARRAY('TARIFF', 'CARRIER'),
					    p_values		=> STRINGARRAY(l_tariff, FTE_UTIL_PKG.GET_CARRIER_NAME(l_carrier_id)));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
                   		    p_msg 		=> x_error_msg,
                   		    p_category		=> 'A',
				    p_line_number	=> p_line_number);
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
        x_status := 2;
        RETURN;
--          x_error_msg := 'Carrier specified does not associated with the Tariff ' || l_tariff;
      END IF;
    END IF;

    IF (l_list_header_ids IS NULL OR l_list_header_ids.COUNT <= 0) THEN
--error?
      x_status := 2;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name        => l_module_name,
                                    p_msg               => x_error_msg,
                                    p_category          => 'A',
                                    p_line_number       => p_line_number);

      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      return;
    END IF;

    -- -------------------------------------------------------------
    -- Add the qualifier
    -- -------------------------------------------------------------

    IF (l_action = 'ADD'
        AND l_chart_type in ('FTE_MODIFIER', 'FAC_MODIFIER')) THEN
      FOR i IN 1..l_list_header_ids.COUNT LOOP
        --Store the Qualifier
        FTE_RATE_CHART_PKG.g_qualifier_group := FTE_RATE_CHART_PKG.g_qualifier_group + 1;

	l_count := p_qp_qualifier_tbl.COUNT+1;

        p_qp_qualifier_tbl(l_count).PROCESS_ID            := FTE_RATE_CHART_PKG.G_Process_Id;
        p_qp_qualifier_tbl(l_count).INTERFACE_ACTION_CODE       := 'C';
        p_qp_qualifier_tbl(l_count).QUALIFIER_CONTEXT     := l_qualifier_context;
        p_qp_qualifier_tbl(l_count).QUALIFIER_ATTRIBUTE        := l_qualifier_attr;
        p_qp_qualifier_tbl(l_count).QUALIFIER_ATTR_VALUE  := l_list_header_ids(i);
        p_qp_qualifier_tbl(l_count).QUALIFIER_GROUPING_NO := FTE_RATE_CHART_PKG.g_qualifier_group;
      END LOOP;
    END IF;

    FTE_RATE_CHART_PKG.g_chart_type := l_chart_type;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
               			  p_msg   		=> x_error_msg,
             			  p_category    	=> 'O',
	        		  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
  END VALIDATE_ADJUSTED_RATE_CHART;


  -----------------------------------------------------------------------------
  -- PROCEDURE: VALIDATE_QUALIFIER
  --
  -- Purpose: Add a qualifier to the qp_interface_qualifiers table for the
  --          a rate chart.
  --
  -- IN Parameters
  --    1. p_values: 		pl/sql table for the qualifier line
  --	2. p_line_number:	line number
  --
  -- Out Parameters
  --	1. p_qp_qualifier_tbl:	pl/sql table for the attributes
  --	2. x_status:		status of the processing, -1 means no error
  --	3. x_error_msg:		error message if any.
  -----------------------------------------------------------------------------
  PROCEDURE VALIDATE_QUALIFIER(p_values     	IN    		FTE_BULKLOAD_PKG.data_values_tbl,
			       p_line_number	IN		NUMBER,
			       p_qp_qualifier_tbl	IN OUT	NOCOPY FTE_RATE_CHART_PKG.qp_qualifier_tbl,
	                       x_status     	OUT NOCOPY  	NUMBER,
                               x_error_msg  	OUT NOCOPY  	VARCHAR2) IS

  l_action            VARCHAR2(30);
  l_qual_attr         VARCHAR2(30);
  l_qual_context      VARCHAR2(30);
  l_qual_attr_value   VARCHAR2(30);
  l_qual_group        NUMBER;
  l_process_id        NUMBER;
  l_list_header_id    NUMBER;

  l_module_name   CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.VALIDATE_QUALIFIER';
  l_count		NUMBER;

  BEGIN
    FTE_UTIL_PKG.ENTER_Debug(l_module_name);
    x_status           := -1;

    l_action          := FTE_UTIL_PKG.GET_DATA('ACTION'          , p_values);
    l_process_id      := FTE_UTIL_PKG.GET_DATA('PROCESS_ID'      , p_values);
    l_qual_attr       := FTE_UTIL_PKG.GET_DATA('ATTRIBUTE'       , p_values);
    l_qual_attr_value := FTE_UTIL_PKG.GET_DATA('VALUE'           , p_values);
    l_qual_context    := FTE_UTIL_PKG.GET_DATA('CONTEXT'         , p_values);
    l_qual_group      := FTE_UTIL_PKG.GET_DATA('GROUP'           , p_values);

    IF (l_qual_group IS NULL) THEN
      l_qual_group := 1;
    END IF;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', l_action);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Process ID', l_process_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute', l_qual_attr);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute Value', l_qual_attr_value);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Context', l_qual_context);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Group', l_qual_group);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Line number', p_line_number);
    END IF;

    VALIDATE_ACTION(p_action		=> l_action,
		    p_type		=> 'QUALIFIER',
		    p_line_number 	=> p_line_number,
		    x_status		=> x_status,
		    x_error_msg		=> x_error_msg);

    IF (x_status <> -1) THEN
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      return;
    END IF;

    IF (l_qual_context IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_QUAL_CONTEXT_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name		=> l_module_name,
                   		  p_msg 		=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN;
    END IF;

    IF (l_qual_attr IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_QUAL_ATTR_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name		=> l_module_name,
                   		  p_msg 		=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN;
    END IF;

    IF (l_qual_attr_value IS NULL) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_QUAL_ATTR_VALUE_MISSING');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name		=> l_module_name,
                   		  p_msg			=> x_error_msg,
                   		  p_category		=> 'A',
				  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
      RETURN;
    END IF;

    l_count := p_qp_qualifier_tbl.COUNT+1;

    p_qp_qualifier_tbl(l_count).PROCESS_ID            := l_process_id;
    p_qp_qualifier_tbl(l_count).INTERFACE_ACTION_CODE := 'C';
    p_qp_qualifier_tbl(l_count).QUALIFIER_ATTRIBUTE   := l_qual_attr;
    p_qp_qualifier_tbl(l_count).QUALIFIER_ATTR_VALUE  := l_qual_attr_value;
    p_qp_qualifier_tbl(l_count).QUALIFIER_CONTEXT     := l_qual_context;
    p_qp_qualifier_tbl(l_count).QUALIFIER_GROUPING_NO := l_qual_group;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
               			  p_msg   		=> x_error_msg,
             			  p_category    	=> 'O',
	        		  p_line_number		=> p_line_number);
      FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
      x_status := 2;
  END VALIDATE_QUALIFIER;


    ----------------------------------------------------------------------------
    -- PROCEDURE: VALIDATE_TL_SERVICE
    --
    -- Purpose: does validation for a line in tl service block
    --
    -- IN parameters:
    --  1. FTE_UTIL_PKG.GET_DATA:        FTE_BULKLOAD_PKG.data_values_tbl
    --  2. p_line_number: line number of current line
    --
    -- OUT parameters:
    --  1. p_type:      type value of the line
    --  2. p_action:        action value of the line
    --  3. x_status:        status of the processing, -1 means no error
    --  4. x_error_msg:     error message if any.
    ----------------------------------------------------------------------------
    PROCEDURE VALIDATE_TL_SERVICE(p_values              IN          FTE_BULKLOAD_PKG.data_values_tbl,
                                  p_line_number         IN          NUMBER,
                                  p_type                OUT NOCOPY  VARCHAR2,
                                  p_action              OUT NOCOPY  VARCHAR2,
                                  p_lane_tbl            IN  OUT NOCOPY    FTE_LANE_PKG.lane_tbl,
                                  p_lane_service_tbl    IN  OUT NOCOPY    FTE_LANE_PKG.lane_service_tbl,
                                  p_lane_rate_chart_tbl IN  OUT NOCOPY    FTE_LANE_PKG.lane_rate_chart_tbl,
                                  x_status              OUT NOCOPY  NUMBER,
                                  x_error_msg           OUT NOCOPY  VARCHAR2) IS

    l_effect_date       VARCHAR2(30);
    l_expiry_date       VARCHAR2(30);
    l_temp_number       VARCHAR2(60);
    l_count             NUMBER := 0;
    l_carrier_id        NUMBER := -1;
    l_rate_chart_id     NUMBER := -1;
    l_old_lane_id       NUMBER := -1;
    l_lane_number       VARCHAR2(200);
    l_carrier_name      VARCHAR2(200);
    l_rate_chart_name   VARCHAR2(200);
    l_editable_flag     VARCHAR2(1) := 'Y';
    l_service_level     VARCHAR2(50);
    l_convert_date      DATE;
    l_region_info       WSH_REGIONS_SEARCH_PKG.REGION_REC;
    l_mode_code         VARCHAR2(20);
    l_mode              CONSTANT VARCHAR2(20) := 'TRUCK';
    l_rate_chart_view_flag    VARCHAR2(1) := 'Y';

    l_lane_id           NUMBER;
    l_apply_hold        BOOLEAN;

    l_zone_id           NUMBER;

    l_lane_rate_chart_data     FTE_BULKLOAD_PKG.data_values_tbl;
    l_lane_service_level_data  FTE_BULKLOAD_PKG.data_values_tbl;

    l_region_id         WSH_REGIONS.REGION_ID%TYPE;

    g_debug_on BOOLEAN := TRUE;

    l_module_name CONSTANT VARCHAR2(60) := 'FTE.PLSQL.' || g_pkg_name || '.VALIDATE_TL_SERVICE';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        p_action := FTE_UTIL_PKG.GET_DATA('ACTION',p_values);

        IF (g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_action', p_action);
        END IF;

        VALIDATE_ACTION(p_action      => p_action,
                        p_type        => 'TL_SERVICE',
                        p_line_number => p_line_number,
                        x_status      => x_status,
                        x_error_msg   => x_error_msg);

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        l_count := p_lane_tbl.COUNT + 1;
        p_lane_tbl(l_count).action := p_action;

        l_lane_number     := FTE_UTIL_PKG.GET_DATA('SERVICE_NUMBER',p_values);
        l_carrier_name    := FTE_UTIL_PKG.GET_DATA('CARRIER_NAME',p_values);
        l_rate_chart_name := FTE_UTIL_PKG.GET_DATA('RATE_CHART_NAME',p_values);
        l_effect_date     := FTE_UTIL_PKG.GET_DATA('SERVICE_START_DATE',p_values);
        l_expiry_date     := FTE_UTIL_PKG.GET_DATA('SERVICE_END_DATE',p_values);
        l_service_level   := FTE_UTIL_PKG.GET_DATA('SERVICE_LEVEL',p_values);

        IF (g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_lane_number    ', l_lane_number);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_carrier_name   ', l_carrier_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_rate_chart_name', l_rate_chart_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_effect_date    ', l_effect_date);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_expiry_date    ', l_expiry_date);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_service_level  ', l_service_level);
        END IF;

        VALIDATE_CARRIER(p_carrier_name => l_carrier_name,
                         p_line_number  => p_line_number,
                         p_carrier_id   => l_carrier_id,
                         x_status       => x_status,
                         x_error_msg    => x_error_msg);

	IF (g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_carrier_id', l_carrier_id);
        END IF;

	IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        --+
	-- Store the carrier id
        --+
        p_lane_tbl(l_count).carrier_id := l_carrier_id;

        IF (l_lane_number IS NULL) THEN
            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_LANE_NUMBER_MISSING');
	    FTE_UTIL_PKG.Write_OutFile(p_msg  => x_error_msg,
                                        p_category  => 'A',
                                        p_module_name => l_module_name,
                                        p_line_number => p_line_number);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;

	ELSE
	    --+
            -- Get the lane id.
            -- Lane ID is -1 if this is new service, a +ve number otherwise.
            --+
	    l_old_lane_id := FTE_LANE_PKG.GET_LANE_ID(l_lane_number, l_carrier_id);

	    IF(g_debug_on) THEN
	        FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_old_lane_id ',l_old_lane_id);
            END IF;

	END IF;

	IF (p_action = 'UPDATE') THEN

                IF (l_old_lane_id = -1) THEN
	            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_LANE_NUMBER_INVALID');
                    FTE_UTIL_PKG.Write_OutFile(p_msg     => x_error_msg,
                                                p_category     => 'A',
                                                p_module_name  => l_module_name,
                                                p_line_number  => p_line_number);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

		p_lane_tbl(l_count).lane_id := l_old_lane_id;
		p_lane_tbl(l_count).lane_number := l_lane_number;

        ELSIF (p_action = 'DELETE') THEN

            IF (l_old_lane_id = -1) THEN
	        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_LANE_NUMBER_INVALID');
                FTE_UTIL_PKG.Write_OutFile(p_msg  => x_error_msg,
                                            p_category  => 'C',
                                            p_module_name => l_module_name,
                                            p_line_number => p_line_number); -- TODO add tokens
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            p_lane_tbl(l_count).lane_id := l_old_lane_id;
	    FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;

        ELSIF (p_action = 'ADD') THEN

            IF (l_old_lane_id <> -1) THEN
                x_status := 2;
	        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_LANE_REF_EXISTS');
                FTE_UTIL_PKG.Write_OutFile(p_msg    => x_error_msg,
                                            p_category    => 'D',
                                            p_module_name => l_module_name,
                                            p_line_number => p_line_number); -- TODO add tokens SERVICE_NUMBER
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;

            ELSE
                --+
                -- Get a new Lane Id from the suquence "fte_lanes_s" for the new lane
                --+
	        p_lane_tbl(l_count).lane_id     := FTE_LANE_PKG.GET_NEXT_LANE_ID;
                p_lane_tbl(l_count).lane_number := l_lane_number;

            END IF;

            --+
            -- validate Origin, Destination, Mode only for ADD
            --+

	    --+
            -- set origin and  destination
            --+

            l_region_info.city     := FTE_UTIL_PKG.GET_DATA('ORIGIN_CITY',p_values);
            l_region_info.state    := FTE_UTIL_PKG.GET_DATA('ORIGIN_STATE',p_values);
            l_region_info.country  := FTE_UTIL_PKG.GET_DATA('ORIGIN_COUNTRY',p_values);
            l_region_info.postal_code_from := FTE_UTIL_PKG.GET_DATA('ORIGIN_POSTAL_CODE_FROM',p_values);
            l_region_info.postal_code_to   := FTE_UTIL_PKG.GET_DATA('ORIGIN_POSTAL_CODE_TO',p_values);
            l_region_info.zone     := FTE_UTIL_PKG.GET_DATA('ORIGIN_ZONE',p_values);

            IF (l_region_info.country IS NULL AND l_region_info.zone IS NOT NULL) THEN

                l_zone_id := FTE_REGION_ZONE_LOADER.GET_ZONE_ID(l_region_info.zone);

		IF (l_zone_id <> -1 OR l_zone_id IS NOT NULL) THEN
                    p_lane_tbl(l_count).origin_id := l_zone_id;
		ELSE
		   x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LANE_ORIGIN_MISSING');

	           FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                         		      p_msg		=> x_error_msg,
                   		              p_category	=> 'A',
				              p_line_number	=> p_line_number);

                   FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
                   x_status := 2;
                   RETURN;
                END IF;

            ELSIF (l_region_info.country IS NOT NULL) THEN

	       l_region_id := FTE_REGION_ZONE_LOADER.GET_REGION_ID(p_region_info  => l_region_info);

	       IF (l_region_id IS NULL OR l_region_id = -1) THEN
  	          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_REGION_UNKNOWN',
						      p_tokens	=> STRINGARRAY('REGION_NAME'),
						      p_values	=> STRINGARRAY(l_region_info.country ||' '||
								       l_region_info.state ||' '||
								       l_region_info.city));
		  FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
					      p_msg	 	=> x_error_msg,
					      p_category	=> 'D',
					      p_line_number	=> p_line_number);

		  FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
		  x_status := 2;
		  RETURN;
               END IF;

  	       --inserting the region in wsh_zone_regions
    	       IF (FTE_REGION_ZONE_LOADER.INSERT_PARTY_REGION(p_region_id        => l_region_id,
				  p_parent_region_id => l_region_id,
				  p_supplier_id      => -1,
				  p_validate_flag    => TRUE,
				  p_postal_code_from => l_region_info.postal_code_from,
				  p_postal_code_to   => l_region_info.postal_code_to) = -1) THEN
                 FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
                 x_status := 2;
                 RETURN;
               END IF;

               p_lane_tbl(l_count).origin_id := l_region_id;

	    ELSE
	        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LOAD_ORIGIN_MISSING');
	        FTE_UTIL_PKG.Write_OutFile(p_msg    => x_error_msg,
                                            p_category    => 'D',
                                            p_module_name => l_module_name,
                                            p_line_number => p_line_number); -- TODO add tokens
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;

            END IF;

            l_region_info.city     := FTE_UTIL_PKG.GET_DATA('DESTINATION_CITY',p_values);
            l_region_info.state    := FTE_UTIL_PKG.GET_DATA('DESTINATION_STATE',p_values);
            l_region_info.country  := FTE_UTIL_PKG.GET_DATA('DESTINATION_COUNTRY',p_values);
            l_region_info.postal_code_from := FTE_UTIL_PKG.GET_DATA('DESTINATION_POSTAL_CODE_FROM',p_values);
            l_region_info.postal_code_to   := FTE_UTIL_PKG.GET_DATA('DESTINATION_POSTAL_CODE_TO',p_values);
            l_region_info.zone     := FTE_UTIL_PKG.GET_DATA('DESTINATION_ZONE',p_values);

            IF (l_region_info.country IS NULL AND l_region_info.zone IS NOT NULL) THEN

                l_zone_id := FTE_REGION_ZONE_LOADER.GET_ZONE_ID(l_region_info.zone);

	        IF (l_zone_id <> -1 OR l_zone_id IS NOT NULL) THEN
                    p_lane_tbl(l_count).destination_id := l_zone_id;
		ELSE
		   x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LANE_ORIGIN_MISSING');

	           FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                         		      p_msg		=> x_error_msg,
                   		              p_category	=> 'A',
				              p_line_number	=> p_line_number);

                   FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
                   x_status := 2;
                   RETURN;
                END IF;

            ELSIF (l_region_info.country IS NOT NULL) THEN

	        l_region_id := FTE_REGION_ZONE_LOADER.GET_REGION_ID(p_region_info  => l_region_info);

		IF (l_region_id IS NULL OR l_region_id = -1) THEN
  	          x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_REGION_UNKNOWN',
						      p_tokens	=> STRINGARRAY('REGION_NAME'),
						      p_values	=> STRINGARRAY(l_region_info.country ||' '||
								       l_region_info.state ||' '||
								       l_region_info.city));
		  FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name	=> l_module_name,
					      p_msg	 	=> x_error_msg,
					      p_category	=> 'D',
					      p_line_number	=> p_line_number);

		  FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
		  x_status := 2;
		  RETURN;
                END IF;

  	       --inserting the region in wsh_zone_regions
    	       IF (FTE_REGION_ZONE_LOADER.INSERT_PARTY_REGION(p_region_id        => l_region_id,
				  p_parent_region_id => l_region_id,
				  p_supplier_id      => -1,
				  p_validate_flag    => TRUE,
				  p_postal_code_from => l_region_info.postal_code_from,
				  p_postal_code_to   => l_region_info.postal_code_to) = -1) THEN
                 FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
                 x_status := 2;
                 RETURN;
               END IF;

                p_lane_tbl(l_count).destination_id := l_region_id;

	    ELSE
  	        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LOAD_DESTINATION_MISSING');
	        FTE_UTIL_PKG.Write_OutFile(p_msg    => x_error_msg,
                                            p_category    => 'D',
                                            p_module_name => l_module_name,
                                            p_line_number => p_line_number); -- TODO add tokens
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;

            END IF;

            IF (g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'origin ID     ',p_lane_tbl(l_count).origin_id);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'destination ID',  p_lane_tbl(l_count).destination_id);
            END IF;

            VALIDATE_MODE_OF_TRANS(p_mode         => l_mode,
                                   p_line_number  => p_line_number,
                                   p_carrier_id   => l_carrier_id,
                                   p_mode_code    => l_mode_code,
                                   x_status       => x_status,
                                   x_error_msg    => x_error_msg);

            IF(x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            p_lane_tbl(l_count).mode_of_transportation_code := l_mode_code;

        END IF;

        --+
        -- Validation for EFFECTIVE_DATE
        --+

        VALIDATE_DATE(p_date => l_effect_date,
		      p_line_number => p_line_number,
		      x_status => x_status,
		      x_error_msg => x_error_msg);

        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          RETURN;
        END IF;

 	p_lane_tbl(l_count).effective_date := l_effect_date;

        -- Validation for EXPIRY_DATE

        VALIDATE_DATE(p_date => l_expiry_date,
		      p_line_number => p_line_number,
		      x_status => x_status,
		      x_error_msg => x_error_msg);

        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          RETURN;
        END IF;

        p_lane_tbl(l_count).expiry_date := l_expiry_date;

        IF (l_rate_chart_view_flag IS NOT NULL) THEN
            p_lane_tbl(l_count).pricelist_view_flag := l_rate_chart_view_flag;
        END IF;

        IF (p_action = 'ADD')  THEN  -- ADD

            IF(l_editable_flag IS NULL) THEN
                p_lane_tbl(l_count).editable_flag := 'Y';
	    ELSE
 	        p_lane_tbl(l_count).editable_flag := l_editable_flag;
            END IF;

	    --+
            -- DO WE NEED TO SET THESE FALGS. ASK PM.
	    -- p_lane_tbl(l_count).owner_id := -1;
	    -- p_lane_tbl(l_count).SCHEDULES_FLAG := 'N'
	    -- p_lane_tbl(l_count).COMMODITY_DETAIL_FLAG := 'N';
	    -- p_lane_tbl(l_count).SERVICE_DETAIL_FLAG := 'N';
            --+

	   IF (l_rate_chart_name IS NULL) THEN
    	       x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LOAD_RC_NAME_MISSING');
	       FTE_UTIL_PKG.WRITE_OUTFILE(p_msg  	 => x_error_msg,
                    		           p_category	 => 'C',
					   p_module_name => l_module_name,
				           p_line_number => p_line_number);
               FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
               x_status := 1;
	       RETURN;

	   END IF;

	   l_lane_rate_chart_data('ACTION') := 'ADD';
           l_lane_rate_chart_data('RATE_CHART_NAME') := l_rate_chart_name;

           --+
           -- Though we know p_action has the value 'ADD' at this point,
           -- I have put the literal 'ADD' for readability.
           --+
           VALIDATE_LANE_RATE_CHART(p_values              => l_lane_rate_chart_data,
                                    p_line_number         => p_line_number,
                                    p_action              => 'ADD',
                                    p_lane_tbl            => p_lane_tbl,
                                    p_lane_rate_chart_tbl => p_lane_rate_chart_tbl,
			            p_set_error           => FALSE,
                                    x_status              => x_status,
                                    x_error_msg           => x_error_msg);

	   IF (x_status <> -1) THEN

	       IF (g_debug_on) THEN
		   FTE_UTIL_PKG.Write_LogFile(l_module_name, 'VALIDATE_LANE_RATE_CHART returned with status',x_status);
	       END IF;

               FTE_UTIL_PKG.Exit_Debug(l_module_name);
	       RETURN;

	   ELSE
	       p_lane_tbl(l_count).LANE_TYPE := 'HOLD_' || l_rate_chart_name;
	   END IF;

           l_lane_service_level_data('ACTION') := 'ADD';
           l_lane_service_level_data('TYPE') := 'SERVICE_LEVEL';
           l_lane_service_level_data('SERVICE_LEVEL') := l_service_level;

           VALIDATE_LANE_SERVICE_LEVEL(p_values          => l_lane_service_level_data,
                                       p_line_number     => p_line_number,
                                       p_type            => 'SERVICE_LEVEL',
                                       p_action          => 'ADD',
                                       p_lane_tbl        => p_lane_tbl,
                                       p_lane_service_tbl=> p_lane_service_tbl,
                                       x_status          => x_status,
                                       x_error_msg       => x_error_msg);
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := sqlerrm;
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
               			  p_msg   		=> x_error_msg,
             			  p_category    	=> 'O',
	        		  p_line_number		=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

    END VALIDATE_TL_SERVICE;

    --_______________________________________________________________________________________--
    --
    -- PROCEDURE VALIDATE_ZONE
    --
    -- Purpose: does validation for one line in zone block
    --
    -- IN parameters:
    --  1. p_columns:   STRINGARRAY of the column names
    --  2. p_values:    STRINGARRAY of the line values
    --  3. p_line_number: line number of current line
    --  4. p_region_type: region type for the zone (10, 11 etc)
    --
    -- OUT parameters:
    --  1. p_action:    action value of the line
    --  2. p_zone_name: zone name value of the line
    --  3. p_country:   country value of the line
    --  4. p_zone_id:   zone id, not -1 if zone exists
    --  5. p_region_rec: record to store region info
    --  6. p_region_id: region id, not -1 if already exists
    --  7. x_status:    status of the processing, -1 means no error
    --  8. x_error_msg: error message if any.
    --_______________________________________________________________________________________--

    PROCEDURE VALIDATE_ZONE(p_values            IN          FTE_BULKLOAD_PKG.data_values_tbl,
                            p_line_number       IN          NUMBER,
                            p_region_type       IN          VARCHAR2,
                            p_action            OUT NOCOPY  VARCHAR2,
                            p_zone_name         OUT NOCOPY  VARCHAR2,
                            p_country           OUT NOCOPY  VARCHAR2,
                            p_zone_id           OUT NOCOPY  NUMBER,
                            p_region_rec        OUT NOCOPY  WSH_REGIONS_SEARCH_PKG.region_rec,
                            p_region_id         OUT NOCOPY  NUMBER,
                            x_status            OUT NOCOPY  NUMBER,
                            x_error_msg         OUT NOCOPY  VARCHAR2) IS

    l_module_name       CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.VALIDATE_ZONE';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        p_action    := p_values('ACTION');
        p_zone_name := p_values('ZONE_NAME');
        p_country   := p_values('COUNTRY');

        IF (g_debug_on) THEN
          FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Action', p_action);
          FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Zone Name', p_zone_name);
          FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Country', p_country);
        END IF;

        IF (p_region_type IS NOT NULL AND p_region_type = '10') THEN

            VALIDATE_ACTION(p_action        => p_action,
                            p_type          => 'ZONE',
                            p_line_number   => p_line_number,
                            x_status        => x_status,
                            x_error_msg     => x_error_msg);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            IF (p_zone_name IS NULL) THEN
                FTE_UTIL_PKG.Write_OutFile('FTE_CAT_ZONE_NAME_MISSING', 'A', p_line_number);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            IF (p_country IS NULL) THEN
                FTE_UTIL_PKG.Write_OutFile('FTE_CAT_COUNTRY_REQUIRED', 'A', p_line_number);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

        END IF;

        p_zone_id := FTE_REGION_ZONE_LOADER.GET_ZONE_ID(p_zone_name);

        --+
        -- Zone without any region is not allowed
        -- So, create the Zone only when the region is valid
        --+
        p_region_rec.region_id        := -1;
        p_region_rec.zone_level       := -1;
        p_region_rec.country          := p_values('COUNTRY');
        p_region_rec.state            := p_values('STATE');
        p_region_rec.city             := p_values('CITY');
        p_region_rec.postal_code_from := p_values('POSTAL_CODE_FROM');
        p_region_rec.postal_code_to   := p_values('POSTAL_CODE_TO');

        p_region_id := FTE_REGION_ZONE_LOADER.GET_REGION_ID(p_region_rec, 'Y');

        --+
        -- No such region, cannot add zone
        --+
        IF (p_region_id IS NULL OR p_region_id = -1) THEN
	    x_status := 2;
  	    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name   => 'FTE_CAT_REGION_UNKNOWN',
					        p_tokens => STRINGARRAY('REGION_NAME'),
					        p_values => STRINGARRAY(p_region_rec.country ||' '||
								        p_region_rec.state ||' '||
								        p_region_rec.city));
            FTE_UTIL_PKG.Write_OutFile(p_module_name 	=> l_module_name,
				       p_msg		=> x_error_msg,
				       p_category	=> 'C',
				       p_line_number	=> p_line_number);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := sqlerrm;
            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
               			  p_msg   		=> x_error_msg,
             			  p_category    	=> 'O',
	        		  p_line_number		=> p_line_number);
            FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);

    END VALIDATE_ZONE;

END FTE_VALIDATION_PKG;

/
