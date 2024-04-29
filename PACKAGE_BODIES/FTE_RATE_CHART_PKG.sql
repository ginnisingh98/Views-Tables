--------------------------------------------------------
--  DDL for Package Body FTE_RATE_CHART_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_RATE_CHART_PKG" AS
/* $Header: FTERCPKB.pls 120.9 2005/08/19 00:14:48 pkaliyam noship $ */
  ------------------------------------------------------------------------- --
  --                                                                        --
  -- NAME:        FTE_RATE_CHART_PKG                                        --
  -- TYPE:        PACKAGE BODY                                              --
  -- FUNCTIONS:		CHECK_FACILITIES				    --
  --			GET_PRICELIST_ID				    --
  --			GET_RATE_CHART_INFO				    --
  --			GET_ASSOC_MODIFIERS				    --
  --			GET_ASSOC_PRICELISTS				    --
  -- PROCEDURES:	Reset_Region_Info 				    --
  --			RESET_PRICE_VALUES				    --
  --			RESET_ALL					    --
  --			DELETE_FROM_QP					    --
  --			REPLACE_RATE_CHART				    --
  --		 	INSERT_QP_INTERFACE_TABLES			    --
  --			QP_API_CALL					    --
  --                                                                        --
  ------------------------------------------------------------------------- --

  G_PKG_NAME         CONSTANT  VARCHAR2(50) := 'FTE_RATE_CHART_PKG';

  TYPE LH_INT_ACTION_CODE_TAB IS TABLE OF QP_INTERFACE_LIST_HEADERS.INTERFACE_ACTION_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LH_LIST_TYPE_CODE_TAB IS TABLE OF QP_INTERFACE_LIST_HEADERS.LIST_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LH_START_DATE_ACTIVE_TAB IS TABLE OF QP_INTERFACE_LIST_HEADERS.START_DATE_ACTIVE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LH_END_DATE_ACTIVE_TAB IS TABLE OF QP_INTERFACE_LIST_HEADERS.END_DATE_ACTIVE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LH_DESCRIPTION_TAB IS TABLE OF QP_INTERFACE_LIST_HEADERS.DESCRIPTION%TYPE INDEX BY BINARY_INTEGER;
  TYPE LH_CREATION_DATE_TAB IS TABLE OF QP_INTERFACE_LIST_HEADERS.CREATION_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LH_LAST_UPDATE_DATE_TAB IS TABLE OF QP_INTERFACE_LIST_HEADERS.LAST_UPDATE_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LH_ATTRIBUTE1_TAB IS TABLE OF QP_INTERFACE_LIST_HEADERS.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;

 -- GLOBAL VARIABLES FOR QUALIFIERS
  TYPE QL_INT_ACTION_CODE_TAB IS TABLE OF QP_INTERFACE_QUALIFIERS.INTERFACE_ACTION_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE QL_QUALIFIER_ATTR_VALUE_TAB IS TABLE OF QP_INTERFACE_QUALIFIERS.QUALIFIER_ATTR_VALUE%TYPE INDEX BY BINARY_INTEGER;
  TYPE QL_QUALIFIER_ATTR_TAB IS TABLE OF QP_INTERFACE_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE INDEX BY BINARY_INTEGER;
  TYPE QL_QUALIFIER_CONTEXT_TAB IS TABLE OF QP_INTERFACE_QUALIFIERS.QUALIFIER_CONTEXT%TYPE INDEX BY BINARY_INTEGER;

  TYPE LL_OPERAND_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.OPERAND%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_COMMENTS_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.COMMENTS%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_PRIMARY_UOM_FLAG_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.PRIMARY_UOM_FLAG%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_PROCESS_TYPE_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.PROCESS_TYPE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_INT_ACTION_CODE_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.INTERFACE_ACTION_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_LIST_LINE_TYPE_CODE_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.LIST_LINE_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_AUTOMATIC_FLAG_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.AUTOMATIC_FLAG%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_OVERRIDE_FLAG_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.OVERRIDE_FLAG%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_MOD_LEVEL_CODE_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.MODIFIER_LEVEL_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_ARITHMETIC_OPERATOR_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.ARITHMETIC_OPERATOR%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_ACCRUAL_FLAG_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.ACCRUAL_FLAG%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_PRC_BRK_TYPE_CODE_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.PRICE_BREAK_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_PRODUCT_PRECEDENCE_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.PRODUCT_PRECEDENCE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_ATTRIBUTE1_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_ATTRIBUTE2_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.ATTRIBUTE2%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_RLTD_MOD_GRP_TYPE_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.RLTD_MODIFIER_GRP_TYPE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_CHARGE_TYPE_CODE_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.CHARGE_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_CHARGE_SUBTYPE_CODE_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.CHARGE_SUBTYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_START_DATE_ACTIVE_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.START_DATE_ACTIVE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LL_END_DATE_ACTIVE_TAB IS TABLE OF QP_INTERFACE_LIST_LINES.END_DATE_ACTIVE%TYPE INDEX BY BINARY_INTEGER;

 -- GLOBAL VARIABLES FROM ATTRIBUTE
  TYPE AT_PROCESS_TYPE_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.PROCESS_TYPE%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_INT_ACTION_CODE_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.INTERFACE_ACTION_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_EXCLUDER_FLAG_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.EXCLUDER_FLAG%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_PRODUCT_ATTR_CONTEXT_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.PRODUCT_ATTRIBUTE_CONTEXT%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_PRODUCT_ATTR_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.PRODUCT_ATTRIBUTE%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_PRODUCT_ATTR_VALUE_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.PRODUCT_ATTR_VALUE%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_PRODUCT_UOM_CODE_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.PRODUCT_UOM_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_PRODUCT_ATTR_DATATYPE_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.PRODUCT_ATTRIBUTE_DATATYPE%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_PRICING_ATTR_DATATYPE_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.PRICING_ATTRIBUTE_DATATYPE%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_PRICING_ATTR_CONTEXT_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.PRICING_ATTRIBUTE_CONTEXT%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_PRICING_ATTR_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.PRICING_ATTRIBUTE%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_COMP_OPERATOR_CODE_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.COMPARISON_OPERATOR_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_PRICING_ATTR_VALUE_FROM_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.PRICING_ATTR_VALUE_FROM%TYPE INDEX BY BINARY_INTEGER;
  TYPE AT_PRICING_ATTR_VALUE_TO_TAB IS TABLE OF QP_INTERFACE_PRICING_ATTRIBS.PRICING_ATTR_VALUE_TO%TYPE INDEX BY BINARY_INTEGER;

  -------------------------------------------------------------------------------
  --
  --   Reset_Region_Info. Resets GLOBAL record for Region. It is used by
  --                      Origin and Destination attributes
  -------------------------------------------------------------------------------
  PROCEDURE Reset_Region_Info IS
    l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.RESET_REGION_INFO';
  BEGIN
    G_region_info.region_id           := -1;
    G_region_info.region_type         := '';
    G_region_info.country             := '';
    G_region_info.country_region      := '';
    G_region_info.state               := '';
    G_region_info.city                := '';
    G_region_info.postal_code_from    := '';
    G_region_info.postal_code_to      := '';
    G_region_info.zone                := '';
    G_region_info.zone_level          := -1;
    G_region_info.country_code        := '';
    G_region_info.country_region_code := '';
    G_region_info.state_code          := '';
    G_region_info.city_code           := '';

    g_region_flag := NULL;
    g_region_linenum := NULL;

  EXCEPTION WHEN OTHERS THEN
    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
             			p_msg   	=> sqlerrm,
             			p_category    	=> 'O');

    RAISE;
  END Reset_Region_Info;


  -------------------------------------------------------------------------------
  --
  --   Reset_Price_Values. Resets GLOBAL Variables
  --
  -------------------------------------------------------------------------------
  PROCEDURE  Reset_Price_Values IS

  BEGIN
    G_Product_UOM        := null;
    G_item               := null;
    G_Process_Id         := 0;
    G_listHeaderId       := 0;
    G_listLineId         := 0;
    G_Prc_Brk_Linenum    := 0;
    G_Prc_Brk_Hdr_Index  := 0;
    G_Cur_Line_Index     := 0;
    G_Mod_Grp            := 1;
    G_previous_upper     := 0;
    LH_REPLACE_RC.DELETE;
    LH_NEW_RC.DELETE;
  END Reset_Price_Values;

  -------------------------------------------------------------------------------
  --
  --   Reset_All. Resets All GLOBAL Variables
  --
  -------------------------------------------------------------------------------
  PROCEDURE Reset_All IS
  BEGIN
    G_line_number             := NULL;
    G_region_linenum          := NULL;
    G_region_flag             := NULL;
    Reset_Region_info;
    Reset_Price_Values;
  END RESET_ALL;

  -------------------------------------------------------------------------------
  --
  --   Check_Facilities: Returns -1 if there are no Facilities attached to the
  --                     rate chart, 2 otherwise.
  -------------------------------------------------------------------------------
  FUNCTION Check_Facilities(p_pricelist_id   	IN   NUMBER,
			    x_status  		OUT NOCOPY NUMBER,
                            x_error_msg  	OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  CURSOR facility_codes IS
  SELECT facility_code FROM fte_location_parameters
  WHERE  modifier_list = p_pricelist_id;

  l_faccodes       STRINGARRAY;
  i                NUMBER;

  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.CHECK_FACILITIES';

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'List Header ID', p_pricelist_id);
    END IF;

    x_status := -1;

    OPEN facility_codes;
    FETCH facility_codes BULK COLLECT INTO l_faccodes;
    i := facility_codes%ROWCOUNT;
    CLOSE facility_codes;

    IF ( i > 0 ) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_RC_ASSIGNED_TO_FC');
      FOR j IN 1..l_faccodes.COUNT LOOP
        x_error_msg := x_error_msg || ' '||
			FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_FACILITY_CODE',
					     p_tokens => STRINGARRAY('CODE'),
					     p_values => STRINGARRAY(l_faccodes(j)));
      END LOOP;
      x_status := 2;

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	         		 p_msg   	=> x_error_msg,
	         		 p_category    => 'F');

    END IF;

    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
    RETURN x_status;

  EXCEPTION WHEN OTHERS THEN
    IF (facility_codes%ISOPEN) THEN
      CLOSE facility_codes;
    END IF;
    x_error_msg := sqlerrm;
    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
                	       p_msg   	=> x_error_msg,
                	       p_category    	=> 'O');
    FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
    x_status := 1;
    RETURN x_status;
  END Check_Facilities;

  -----------------------------------------------------------------------------
  -- FUNCTION  Get_Pricelist_Id
  --
  -- Purpose
  --    Get the pricelist_id of pricelist, or -1 if the pricelist doesn't exist
  --
  -- IN Parameters
  --    1. p_name:      The name of the pricelist.
  --    2. p_carrier_id: The carrier Id of the pricelist
  -- RETURNS:
  --    The pricelist Id, or -1 if the pricelist doesn't exist
  -----------------------------------------------------------------------------
  FUNCTION Get_Pricelist_Id (p_name       	IN  VARCHAR2,
                             p_carrier_id  	IN  NUMBER,
			     p_attribute1 	OUT NOCOPY VARCHAR2) RETURN NUMBER IS

  l_list_header_id   	NUMBER := -1;
  l_attribute1		VARCHAR2(50);
  l_module_name  CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.GET_PRICELIST_ID';

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate Chart Name', p_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier ID', p_carrier_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Attribute1', p_attribute1);
    END IF;

    IF (p_carrier_id IS NULL) THEN
      SELECT l.list_header_id, nvl(b.attribute1, 'FTE_RATE_CHART')
      INTO l_list_header_id, l_attribute1
      FROM   qp_list_headers_tl l, qp_list_headers_b b
      WHERE  l.list_header_id = b.list_header_id
      AND    l.name = p_name
      AND    l.language = userenv('LANG');
    ELSE
      SELECT l.list_header_id, nvl(b.attribute1, 'FTE_RATE_CHART')
      INTO l_list_header_id, l_attribute1
      FROM   qp_list_headers_tl l, qp_list_headers_b b, qp_qualifiers q
      WHERE  l.list_header_id     = b.list_header_id
      AND    l.name               = p_name
      AND    l.list_header_id     = q.list_header_id
      AND    q.qualifier_context    = 'PARTY'
      AND    q.qualifier_attribute  = 'QUALIFIER_ATTRIBUTE1'
      AND    q.qualifier_attr_value = Fnd_Number.Number_To_Canonical(p_Carrier_Id)
      AND    l.language = userenv('LANG');
    END IF;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);

    p_attribute1 := l_attribute1;

    RETURN l_list_header_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --no rate chart with this 'rate chart name' and carrier found.
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN -1;
    WHEN OTHERS THEN
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
              			 p_msg   	=> sqlerrm,
              			 p_category    => 'O');

      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RAISE;
  END Get_Pricelist_Id;

  -----------------------------------------------------------------------------
  -- FUNCTION  GET_RATE_CHART_INFO
  --
  -- Purpose: get the rate chart list header id, start date, and end date using the name and carrier id
  --
  -- IN Parameters
  --    1. p_name:      The name of the pricelist.
  --    2. p_carrier_id: The carrier Id of the pricelist
  --
  -- OUT Parameters:
  --	1. x_status: 	status, -1 if no error
  --	2. x_error_msg:	error message if any
  -- RETURNS:
  --    The pricelist Id, or -1 if the pricelist doesn't exist, -2 if error
  -----------------------------------------------------------------------------

  FUNCTION GET_RATE_CHART_INFO(p_name	    IN	VARCHAR2,
			       p_carrier_id IN	NUMBER,
			       x_status	    OUT NOCOPY NUMBER,
			       x_error_msg  OUT NOCOPY VARCHAR2) RETURN STRINGARRAY IS

  l_result	        STRINGARRAY;
  l_list_header_id	qp_list_headers_b.list_header_id%TYPE;
  l_name		qp_list_headers_tl.name%TYPE;
  l_start_date		VARCHAR2(50);
  l_end_date		VARCHAR2(50);
  l_module_name  CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.GET_RATE_CHART_INFO';

  CURSOR GET_CHART_INFO(p_name	IN	VARCHAR2, p_carrier_id	IN	NUMBER) IS
    SELECT l.list_header_id, ltl.name, to_char(l.start_date_active,'YYYY-MM-DD'), to_char(l.end_date_active,'YYYY-MM-DD')
      FROM qp_list_headers_b l, qp_qualifiers q, qp_list_headers_tl ltl
     WHERE ltl.name = p_name
       AND l.list_header_id=q.list_header_id
       AND ltl.list_header_id = l.list_header_id
       AND q.qualifier_context = 'PARTY'
       AND q.qualifier_attr_value = TO_CHAR(p_carrier_id)
       AND ltl.language = userenv('LANG');

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate Chart Name', p_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Carrier ID', p_carrier_id);
    END IF;

    x_status := -1;

    OPEN GET_CHART_INFO(p_name, p_carrier_id);
    FETCH GET_CHART_INFO INTO l_list_header_id, l_name, l_start_date, l_end_date;

    IF (GET_CHART_INFO%ROWCOUNT > 0) THEN
       l_result := STRINGARRAY(l_list_header_id, l_start_date, l_end_date);
    END IF;

    CLOSE GET_CHART_INFO;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'List header ID', l_list_header_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Start date    ', l_start_date);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'End date      ', l_end_date);
    END IF;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
    RETURN l_result;

  EXCEPTION
    WHEN OTHERS THEN
      IF (GET_CHART_INFO%ISOPEN) THEN
        CLOSE GET_CHART_INFO;
      END IF;
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
              			 p_msg   	=> x_error_msg,
		                 p_category    => 'O');

      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      x_status := 1;
      RETURN NULL;
  END GET_RATE_CHART_INFO;

  -------------------------------------------------------------------------------
  -- PROCEDURE DELETE_FROM_QP
  --
  -- Purpose: delete from the qp table
  --
  -- IN parameters:
  --	1. p_list_header_id:	list header id
  --	2. p_name:		name associated with list header id
  --	3. p_action:		delete or update
  --	4. p_line_number:	line number
  --	5. p_delete_qualifier:	boolean for deleting qualifier when updating, default true
  --
  -- OUT parameters:
  --	1. x_status:	status, -1 if no error
  --	2. x_error_msg:	error message if any
  -------------------------------------------------------------------------------
  PROCEDURE DELETE_FROM_QP(p_list_header_id 	IN     	NUMBER,
                           p_name 		IN     	VARCHAR2,
			   p_action		IN	VARCHAR2,
			   p_line_number	IN	NUMBER,
			   p_delete_qualifier	IN	BOOLEAN DEFAULT TRUE,
                           x_status    		OUT  NOCOPY NUMBER,
                           x_error_msg 		OUT  NOCOPY VARCHAR2) IS

  l_list_header_id   	NUMBER;
  l_module_name      	CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.DELETE_FROM_QP';
  l_attribute1		VARCHAR2(50);
  l_tokens		STRINGARRAY := STRINGARRAY();

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'List header ID', p_list_header_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate Chart Name', p_name);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Action', p_action);
    END IF;

    x_status := -1;

    IF (p_list_header_id IS NULL OR p_list_header_id = -1) THEN
      l_list_header_id := Get_Pricelist_Id(p_name	=> p_name,
					   p_carrier_id	=> NULL,
					   p_attribute1	=> l_attribute1);
      IF (l_list_header_id = -1) THEN
	x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_PRICELIST_INVALID',
					    p_tokens => STRINGARRAY('NAME'),
					    p_values => STRINGARRAY(p_name));

        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
	         		   p_msg		=> x_error_msg,
	         		   p_category    	=> 'C',
				   p_line_number	=> p_line_number);

	x_status := 2;
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN;
      END IF;

      IF (l_attribute1 <> g_chart_type OR l_attribute1 IS NULL) THEN
	l_tokens.EXTEND;
	l_tokens(l_tokens.COUNT) := p_name;
	l_tokens.EXTEND;
	IF (g_chart_type = 'FTE_RATE_CHART') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_RATE_CHART');
	ELSIF (g_chart_type = 'TL_RATE_CHART') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_TL_RATE_CHART');
	ELSIF (g_chart_type = 'LTL_RC') THEN
          l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_LTL_RATE_CHART');
	ELSIF (g_chart_type = 'FAC_RATE_CHART') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_FAC_RATE_CHART');
	ELSIF (g_chart_type = 'FTE_MODIFIER') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_CHARGES_DISCOUNTS');
	ELSIF (g_chart_type = 'FAC_MODIFIER') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_FAC_CHARGES');
	ELSIF (g_chart_type = 'TL_MODIFIER') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_TL_ACCESSORIALS');
	ELSIF (g_chart_type = 'MIN_MODIFIER') THEN
	  l_tokens(l_tokens.COUNT) := 'LTL and/or Parcel Modifier';
	ELSE
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_UNKNOWN_CHART');
	END IF;

	l_tokens.EXTEND;
	IF (l_attribute1 = 'FTE_RATE_CHART') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_RATE_CHART');
	ELSIF (l_attribute1 = 'TL_RATE_CHART') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_TL_RATE_CHART');
	ELSIF (l_attribute1 = 'LTL_RC') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_LTL_RATE_CHART');
	ELSIF (l_attribute1 = 'FAC_RATE_CHART') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_FAC_RATE_CHART');
	ELSIF (l_attribute1 = 'FTE_MODIFIER') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_CHARGES_DISCOUNTS');
	ELSIF (l_attribute1 = 'FAC_MODIFIER') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_FAC_CHARGES');
	ELSIF (l_attribute1 = 'TL_MODIFIER') THEN
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_TL_ACCESSORIALS');
	ELSIF (l_attribute1 = 'MIN_MODIFIER') THEN
	  l_tokens(l_tokens.COUNT) := 'LTL and/or Parcel Modifier';
	ELSE
	  l_tokens(l_tokens.COUNT) := FTE_UTIL_PKG.GET_MSG('FTE_UNKNOWN_CHART');
	END IF;

	x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name 	=> 'FTE_CAT_DELETE_TYPE_WRONG',
				    	    p_tokens 	=> STRINGARRAY('NAME', 'TYPE', 'ACTUAL'),
				    	    p_values 	=> l_tokens);

        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
				   p_msg		=> x_error_msg,
			           p_category    	=> 'D',
				   p_line_number	=> p_line_number);

	x_status := 2;
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
	RETURN;
      END IF;

    ELSE
      l_list_header_id := p_list_header_id;
    END IF;

    IF (l_list_header_id = -1) THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_PRICELIST_INVALID',
					  p_tokens => STRINGARRAY('NAME'),
					  p_values => STRINGARRAY(p_name));

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
				 p_msg		=> x_error_msg,
			         p_category    	=> 'C',
				 p_line_number	=> p_line_number);

      x_status := 2;
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN;
    ELSIF (p_action = 'DELETE') THEN
      IF (g_chart_type = 'FAC_MODIFIER') THEN
        x_status := Check_Facilities(l_list_header_id, x_status, x_error_msg);
      ELSIF (NOT g_is_ltl) THEN
        --For LTL Lanes, we want to delete the rate chart even if it is assigned
        --to Lanes. We later obsolete these lanes.
        FTE_LANE_PKG.Check_Lanes(p_pricelist_id	=> l_list_header_id,
				 x_status	=> x_status,
				 x_error_msg	=> x_error_msg);

        IF (x_status <> -1) THEN
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
          RETURN;
        END IF;

      END IF;
    END IF;

    IF (x_status = -1) THEN
      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Deleting data for Pricelist ID ' || l_list_header_id);
      END IF;

      DELETE FROM qp_pricing_attributes
      WHERE list_header_id = l_list_header_id;

      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Deleted ' || sql%rowcount || ' attributes.');
      END IF;

      delete from qp_rltd_modifiers
      where  from_rltd_modifier_id in (select list_line_id
                                       from qp_list_lines
                                       where list_header_id = l_list_header_id);

      delete from qp_list_lines
      where  list_header_id  = l_list_header_id;

      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Deleted ' || sql%rowcount || ' List Lines.');
      END IF;

      --Note: For TL Rate Charts and Modifiers, we keep all the qualifiers.
      IF (p_action  = 'UPDATE' AND g_chart_type IN ('FTE_MODIFIER') AND p_delete_qualifier) THEN
        delete from qp_qualifiers
        where  list_header_id = l_list_header_id
        and    qualifier_context <> 'PARTY';

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
          FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Deleted ' || sql%rowcount || ' qualifiers.');
        END IF;
      END IF;

      -- UPDATE doesn't delete from Headers and Qualifiers
      IF (p_action = 'DELETE') THEN
        delete from qp_qualifiers
        where  list_header_id  = l_list_header_id;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
          FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Deleted ' || sql%rowcount || ' qualifiers.');
        END IF;

        delete from qp_list_headers_b
        where  list_header_id  =l_list_header_id;

        delete from qp_list_headers_tl
        where  list_header_id  = l_list_header_id;

        --For Facility Modifiers, delete stuff from fte_prc_parameters
        IF (g_chart_type = 'FAC_MODIFIER') THEN
          DELETE FROM fte_prc_parameters
          WHERE list_header_id = l_list_header_id
          AND parameter_id in (57, 58, 59, 60);

          IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Deleted ' || sql%rowcount || ' prc_parameters.');
          END IF;

        END IF;
      END IF;
    END IF;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  EXCEPTION WHEN OTHERS THEN
    x_error_msg := sqlerrm;
    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
               		       p_msg   		=> x_error_msg,
               		       p_category    	=> 'O',
			       p_line_number	=> p_line_number);
    x_status := 1;
    FTE_UTIL_PKG.Exit_Debug(l_module_name);
    RETURN;
  END DELETE_FROM_QP;

  -----------------------------------------------------------------------------
  -- PROCEDURE     Replace_Rate_Chart
  --
  -- Purpose: This procedure osolete the old rate chart setting the expiry_date
  --          of the Old Rate Chart as the (effective_date -1) of the new Rate Chart.
  --          Also, it creates a new entry into FTE_LANE_RATE_CHARTS with the info
  --          related to the new Rate Chart
  --
  --
  -- IN Parameters
  --    1. p_old_rate_chart_id   : Rate Chart that has to be replaced.
  --    2. p_new_rate_chart_name : Name of the New Rate Chart
  --
  -- Out Parameters
  --    1. x_status:
  -----------------------------------------------------------------------------
  PROCEDURE Replace_Rate_Chart (p_old_id      IN  NUMBER,
                                p_new_name    IN  VARCHAR2,
                                x_status      OUT NOCOPY VARCHAR2,
				x_error_msg   OUT NOCOPY VARCHAR2) IS

  l_new_start_date   DATE;
  l_new_end_date     DATE;
  l_new_id       NUMBER;
  l_old_start_date   DATE;
  l_old_end_date     DATE;
  l_lane_rate_chart_tbl	FTE_LANE_PKG.lane_rate_chart_tbl;
  l_lane_tbl	FTE_LANE_PKG.lane_tbl;
  l_lane_commodity_tbl	FTE_LANE_PKG.lane_commodity_tbl;
  l_lane_service_tbl	FTE_LANE_PKG.lane_service_tbl;

  CURSOR updated_lanes IS
    select lane_id
    from fte_lane_rate_charts
    where list_header_id = p_old_id;

  l_lane_id   NUMBER;
  l_debug_count number;

  l_overlap boolean;

  l_module_name   CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.REPLACE_RATE_CHART';

  BEGIN

    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Old Rate Chart Id', p_old_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'New Name', p_new_name);
    END IF;
    x_status := -1;

    BEGIN
      SELECT hb.list_header_id, hb.start_date_active, hb.end_date_active
      INTO   l_new_id, l_new_start_date, l_new_end_date
      FROM   qp_list_headers_b hb, qp_list_headers_tl tl
      WHERE  hb.list_header_id = tl.list_header_id
      AND    tl.name = p_new_name
      AND    tl.language = userenv('LANG');

    EXCEPTION
      WHEN OTHERS THEN
	x_error_msg := sqlerrm;
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
               			   p_msg   	 => x_error_msg,
               			   p_category    => 'O');

        x_status := 2;
    	FTE_UTIL_PKG.Exit_Debug(l_module_name);
      	RETURN;
    END;

    OPEN updated_lanes;
    LOOP
      FETCH updated_lanes INTO l_lane_id;
      EXIT WHEN updated_lanes%NOTFOUND;

      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Update Lane ' || l_lane_id || ' with new rate chart id ' || l_new_id);
      END IF;

      -- Update FTE_LANE_RATE_CHARTS
      UPDATE fte_lane_rate_charts
      SET    end_date_active = LEAST(end_date_active, l_new_start_date-0.00001),
  	     LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	     LAST_UPDATE_DATE = sysdate,
	     LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
      WHERE  list_header_id = p_old_id
      AND    lane_id = l_lane_id;

      -- Update QP_LIST_HEADERS_B
      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Update expiry date of old rate chart');
      END IF;

      UPDATE qp_list_headers_b
      SET    end_date_active = LEAST(end_date_active, l_new_start_date-0.00001),
  	     LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
	     LAST_UPDATE_DATE = sysdate,
	     LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
      WHERE  list_header_id = p_old_id;


      -- I have to check if the new Rate Chart has date overlapping
      -- with the existing rate charts attached to the same lane.
      l_overlap := FTE_LANE_PKG.VERIFY_OVERLAPPING_DATE(p_name	=> p_new_name,
						      	p_lane_id => l_lane_id,
							x_status => x_status,
							x_error_msg => x_error_msg);
      IF (l_overlap) THEN
        --x_error_msg := 'Rate Chart cannot be replace since the new one overlaps the existing ones';
	x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_RC_REPLACE_OVERLAP');
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                		   p_msg	 => x_error_msg,
                		   p_category    => 'D');

        x_status := 2;
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        return;
      END IF;

      l_lane_rate_chart_tbl(1).lane_id := l_lane_id;
      l_lane_rate_chart_tbl(1).list_header_id := l_new_id;
      l_lane_rate_chart_tbl(1).start_date_active := l_new_start_date;
      l_lane_rate_chart_tbl(1).end_date_active := l_new_end_date;

      FTE_LANE_PKG.INSERT_LANE_TABLES(p_lane_tbl	=> l_lane_tbl,
				      p_lane_rate_chart_tbl	=> l_lane_rate_chart_tbl,
				      p_lane_commodity_tbl	=> l_lane_commodity_tbl,
				      p_lane_service_tbl	=> l_lane_service_tbl,
			 	      x_status		=> x_status,
				      x_error_msg	=> x_error_msg);

    END LOOP;
    CLOSE updated_lanes;
    FTE_UTIL_PKG.Exit_Debug(l_module_name);

  EXCEPTION
    WHEN OTHERS THEN
      IF (updated_lanes%ISOPEN) THEN
	CLOSE updated_lanes;
      END IF;
      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
               			 p_msg   	=> x_error_msg,
               			 p_category    	=> 'O');

      x_status := 2;
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN;
  END Replace_Rate_Chart;

  -----------------------------------------------------------------------------
  -- PROCEDURE: INSERT_QP_INTERFACE_TABLES
  --
  -- Purpose: Transfer pricelist data from the temporary tables in memory into
  --          QP_INTERFACE_LIST_HEADERS, QP_INTERFACE_LIST_LINES,
  --          QP_INTERFACE_QUALIFIERS and QP_INTERFACE_PRICING_ATTRIBS.
  --          If input parameter 'p_job_id' IS NOT NULL, then the QP api
  --          QP_PRL_LOADER_PUB(...) is also used to load the rate chart for
  --          that particular job id. Otherwise, the data might correspond to
  --          several rate charts, and the QP loading is done elsewhere for all
  --          the corresponding job ids.
  --
  -- IN Parameters
  --	1. p_qp_list_header_tbl:	list header pl/sql table.
  --	2. p_qp_list_line_tbl:		list line pl/sql table.
  --	3. p_qp_qualifier_tbl:		qualifier pl/sql table.
  --	4. p_qp_pricing_attrib_tbl:	pricing attributes pl/sql table.
  --
  -- Out Parameters
  --    1. x_status: -1 if successful, 2 otherwise.
  --	2. x_error_msg: error msg if any
  -----------------------------------------------------------------------------

  PROCEDURE INSERT_QP_INTERFACE_TABLES(p_qp_list_header_tbl	IN OUT NOCOPY qp_list_header_tbl,
				       p_qp_list_line_tbl	IN OUT NOCOPY	qp_list_line_tbl,
				       p_qp_qualifier_tbl	IN OUT NOCOPY	qp_qualifier_tbl,
				       p_qp_pricing_attrib_tbl	IN OUT NOCOPY	qp_pricing_attrib_tbl,
				       p_qp_call		IN 	BOOLEAN DEFAULT TRUE,
				       x_status			OUT NOCOPY NUMBER,
				       x_error_msg		OUT NOCOPY VARCHAR2) IS

  l_status      VARCHAR2(10);
  l_sql_errors  VARCHAR2(8000);
  l_region_id   NUMBER;
  l_region_result	wsh_regions_search_pkg.region_rec;
  cnt           NUMBER;

  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.INSERT_QP_INTERFACE_TABLES';

  LH_PROCESS_ID                 NUMBER_TAB;
  LH_INT_ACTION_CODE            LH_INT_ACTION_CODE_TAB;
  LH_LIST_TYPE_CODE             LH_LIST_TYPE_CODE_TAB;
  LH_START_DATE_ACTIVE          LH_START_DATE_ACTIVE_TAB;
  LH_END_DATE_ACTIVE            LH_END_DATE_ACTIVE_TAB;
  LH_CURRENCY_CODE              LH_CURRENCY_CODE_TAB;
  LH_NAME                       LH_NAME_TAB;
  LH_DESCRIPTION                LH_DESCRIPTION_TAB;
  LH_LIST_HEADER_ID             NUMBER_TAB;
  LH_CREATION_DATE              LH_CREATION_DATE_TAB;
  LH_LAST_UPDATE_DATE           LH_LAST_UPDATE_DATE_TAB;
  LH_ATTRIBUTE1                 LH_ATTRIBUTE1_TAB;
  LH_CURRENCY_HEADER_ID		NUMBER_TAB;

  QL_PROCESS_ID               	NUMBER_TAB;
  QL_INT_ACTION_CODE          	QL_INT_ACTION_CODE_TAB;
  QL_QUALIFIER_ATTR_VALUE     	QL_QUALIFIER_ATTR_VALUE_TAB;
  QL_QUALIFIER_GROUPING_NO    	NUMBER_TAB;
  QL_QUALIFIER_CONTEXT        	QL_QUALIFIER_CONTEXT_TAB;
  QL_QUALIFIER_ATTR           	QL_QUALIFIER_ATTR_TAB;

  LL_PROCESS_ID                 NUMBER_TAB;
  LL_OPERAND                    LL_OPERAND_TAB;
  LL_COMMENTS                   LL_COMMENTS_TAB;
  LL_LIST_LINE_NO               NUMBER_TAB;
  LL_PRIMARY_UOM_FLAG           LL_PRIMARY_UOM_FLAG_TAB;
  LL_PROCESS_TYPE               LL_PROCESS_TYPE_TAB;
  LL_INT_ACTION_CODE            LL_INT_ACTION_CODE_TAB;
  LL_LIST_LINE_TYPE_CODE        LL_LIST_LINE_TYPE_CODE_TAB;
  LL_AUTOMATIC_FLAG             LL_AUTOMATIC_FLAG_TAB;
  LL_OVERRIDE_FLAG              LL_OVERRIDE_FLAG_TAB;
  LL_MOD_LEVEL_CODE             LL_MOD_LEVEL_CODE_TAB;
  LL_ARITHMETIC_OPERATOR        LL_ARITHMETIC_OPERATOR_TAB;
  LL_ACCRUAL_FLAG               LL_ACCRUAL_FLAG_TAB;
  LL_PRC_BRK_TYPE_CODE          LL_PRC_BRK_TYPE_CODE_TAB;
  LL_PRODUCT_PRECEDENCE         LL_PRODUCT_PRECEDENCE_TAB;
  LL_PRC_BRK_HDR_IDX            NUMBER_TAB;
  LL_RLTD_MOD_GRP_NO            NUMBER_TAB;
  LL_ATTRIBUTE1                 LL_ATTRIBUTE1_TAB;
  LL_ATTRIBUTE2                 LL_ATTRIBUTE2_TAB;
  LL_RLTD_MOD_GRP_TYPE          LL_RLTD_MOD_GRP_TYPE_TAB;
  LL_PRICING_GRP_SEQUENCE       NUMBER_TAB;
  LL_PRICING_PHASE_ID           NUMBER_TAB;
  LL_QUALIFICATION_IND          NUMBER_TAB;
  LL_CHARGE_TYPE_CODE           LL_CHARGE_TYPE_CODE_TAB;
  LL_CHARGE_SUBTYPE_CODE        LL_CHARGE_SUBTYPE_CODE_TAB;
  LL_FORMULA_ID                 NUMBER_TAB;
  LL_START_DATE_ACTIVE		LL_START_DATE_ACTIVE_TAB;
  LL_END_DATE_ACTIVE		LL_END_DATE_ACTIVE_TAB;

  AT_PROCESS_ID                 NUMBER_TAB;
  AT_PROCESS_TYPE               AT_PROCESS_TYPE_TAB;
  AT_INT_ACTION_CODE            AT_INT_ACTION_CODE_TAB;
  AT_EXCLUDER_FLAG              AT_EXCLUDER_FLAG_TAB;
  AT_PRODUCT_ATTR_CONTEXT       AT_PRODUCT_ATTR_CONTEXT_TAB;
  AT_PRODUCT_ATTRIBUTE          AT_PRODUCT_ATTR_TAB;
  AT_PRODUCT_ATTR_VALUE         AT_PRODUCT_ATTR_VALUE_TAB;
  AT_PRODUCT_UOM_CODE           AT_PRODUCT_UOM_CODE_TAB;
  AT_PRODUCT_ATTR_DATATYPE      AT_PRODUCT_ATTR_DATATYPE_TAB;
  AT_PRICING_ATTR_DATATYPE      AT_PRICING_ATTR_DATATYPE_TAB;
  AT_PRICING_ATTR_CONTEXT       AT_PRICING_ATTR_CONTEXT_TAB;
  AT_PRICING_ATTRIBUTE          AT_PRICING_ATTR_TAB;
  AT_PRICING_ATTR_VALUE_FROM    AT_PRICING_ATTR_VALUE_FROM_TAB;
  AT_PRICING_ATTR_VALUE_TO      AT_PRICING_ATTR_VALUE_TO_TAB;
  AT_ATTR_GROUPING_NO           NUMBER_TAB;
  AT_COMP_OPERATOR_CODE         AT_COMP_OPERATOR_CODE_TAB;
  AT_LIST_LINE_NO               NUMBER_TAB;
  l_count			NUMBER;

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of rate chart header', p_qp_list_header_tbl.COUNT);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of rate chart line', p_qp_list_line_tbl.COUNT);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of qualifier', p_qp_qualifier_tbl.COUNT);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of pricing attribute', p_qp_pricing_attrib_tbl.COUNT);
    END IF;
    x_status := -1;

    IF (p_qp_list_header_tbl.COUNT > 0) THEN
      G_PROCESS_ID := p_qp_list_header_tbl(p_qp_list_header_tbl.FIRST).process_id;

      l_count := 1;
      FOR i IN p_qp_list_header_tbl.FIRST..p_qp_list_header_tbl.LAST LOOP
        IF (p_qp_list_header_tbl(i).interface_action_code <> 'D') THEN
        --  for ADD and UPDATE
        --INSERT LIST HEADERS
    	  LH_PROCESS_ID(l_count) 	:= p_qp_list_header_tbl(i).process_id;
  	  LH_INT_ACTION_CODE(l_count)	:= p_qp_list_header_tbl(i).interface_action_code;
  	  LH_LIST_TYPE_CODE(l_count)	:= p_qp_list_header_tbl(i).list_type_code;
  	  LH_START_DATE_ACTIVE(l_count)	:= p_qp_list_header_tbl(i).start_date_active;
  	  LH_END_DATE_ACTIVE(l_count)	:= p_qp_list_header_tbl(i).end_date_active;
  	  LH_CURRENCY_CODE(l_count)	:= p_qp_list_header_tbl(i).currency_code;
  	  LH_NAME(l_count)		:= p_qp_list_header_tbl(i).name;
 	  LH_DESCRIPTION(l_count)	:= p_qp_list_header_tbl(i).description;
  	  LH_LIST_HEADER_ID(l_count)	:= p_qp_list_header_tbl(i).list_header_id;
  	  LH_ATTRIBUTE1(l_count)	:= p_qp_list_header_tbl(i).attribute1;
	  l_count := l_count + 1;
        END IF;
      END LOOP;

      BEGIN
        FORALL cnt IN 1..l_count-1
          INSERT INTO QP_INTERFACE_LIST_HEADERS ( PROCESS_ID,
                                                  INTERFACE_ACTION_CODE,
                                                  LIST_TYPE_CODE,
                                                  START_DATE_ACTIVE,
                                                  END_DATE_ACTIVE,
                                                  CURRENCY_CODE,
                                                  NAME,
                                                  DESCRIPTION,
                                                  LIST_HEADER_ID,
                                                  ATTRIBUTE1,
                                                  PROCESS_TYPE,
                                                  AUTOMATIC_FLAG,
                                                  SOURCE_SYSTEM_CODE,
                                                  ACTIVE_FLAG,
                                                  LANGUAGE,
                                                  SOURCE_LANG,
                                                  CREATION_DATE,
                                                  LAST_UPDATE_DATE,
                                                  CREATED_BY,
                                                  LAST_UPDATED_BY,
                                                  LAST_UPDATE_LOGIN)
                                          VALUES(
                                                  LH_PROCESS_ID(cnt),
                                                  LH_INT_ACTION_CODE(cnt),
                                                  LH_LIST_TYPE_CODE(cnt),
                                                  LH_START_DATE_ACTIVE(cnt),
                                                  LH_END_DATE_ACTIVE(cnt),
                                                  LH_CURRENCY_CODE(cnt),
                                                  LH_NAME(cnt),
                                                  LH_DESCRIPTION(cnt),
                                                  LH_LIST_HEADER_ID(cnt),
                                                  LH_ATTRIBUTE1(cnt),
                                                  'SSH',
                                                  'Y',
                                                  'FTE',
                                                  'Y',
                                                  'US',
                                                  'US',
                                                  sysdate,
                                                  sysdate,
                                                  FND_GLOBAL.USER_ID,
                                                  FND_GLOBAL.USER_ID,
                                                  FND_GLOBAL.USER_ID);

      EXCEPTION
        WHEN OTHERS THEN
	  x_error_msg := sqlerrm;
	  FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, '[Inserting rate chart header]');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		     p_msg   	   => x_error_msg,
	               		     p_category    => 'O');

          x_status := 1;
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  	  p_qp_list_header_tbl.DELETE;
  	  p_qp_list_line_tbl.DELETE;
  	  p_qp_qualifier_tbl.DELETE;
  	  p_qp_pricing_attrib_tbl.DELETE;
          RETURN;
      END; --FINISH INSERTING LIST HEADERS
    END IF;

    IF (p_qp_qualifier_tbl.COUNT > 0) THEN
      FOR i IN p_qp_qualifier_tbl.FIRST..p_qp_qualifier_tbl.LAST LOOP
        QL_PROCESS_ID(i)		:= p_qp_qualifier_tbl(i).process_id;
        QL_INT_ACTION_CODE(i)		:= p_qp_qualifier_tbl(i).interface_action_code;
        QL_QUALIFIER_ATTR_VALUE(i)	:= p_qp_qualifier_tbl(i).qualifier_attr_value;
        QL_QUALIFIER_GROUPING_NO(i)	:= p_qp_qualifier_tbl(i).qualifier_grouping_no;
        QL_QUALIFIER_CONTEXT(i)		:= p_qp_qualifier_tbl(i).qualifier_context;
        QL_QUALIFIER_ATTR(i)		:= p_qp_qualifier_tbl(i).qualifier_attribute;
      END LOOP;

      --INSERT QUALIFIERS
      BEGIN
        FORALL cnt IN p_qp_qualifier_tbl.FIRST..p_qp_qualifier_tbl.LAST
          INSERT INTO QP_INTERFACE_QUALIFIERS( PROCESS_ID,
                                               INTERFACE_ACTION_CODE,
                                               QUALIFIER_ATTR_VALUE,
                                               QUALIFIER_GROUPING_NO,
                                               PROCESS_TYPE,
                                               EXCLUDER_FLAG,
                                               COMPARISON_OPERATOR_CODE,
                                               QUALIFIER_CONTEXT,
                                               QUALIFIER_ATTRIBUTE,
                                               CREATION_DATE,
                                               LAST_UPDATE_DATE,
                                               CREATED_BY,
                                               LAST_UPDATED_BY,
                                               LAST_UPDATE_LOGIN)
                                        VALUES(
                                               QL_PROCESS_ID(cnt),
                                               QL_INT_ACTION_CODE(cnt),
                                               QL_QUALIFIER_ATTR_VALUE(cnt),
                                               QL_QUALIFIER_GROUPING_NO(cnt),
                                               'SSH',
                                               'N',
                                               '=',
                                               QL_QUALIFIER_CONTEXT(cnt),
                                               QL_QUALIFIER_ATTR(cnt),
                                               sysdate,
                                               sysdate,
                                               FND_GLOBAL.USER_ID,
                                               FND_GLOBAL.USER_ID,
                                               FND_GLOBAL.USER_ID);
      EXCEPTION
        WHEN OTHERS THEN
	  x_error_msg := sqlerrm;
	  FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, '[Inserting qualifier]');
          FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	                 	     p_msg   	   => x_error_msg,
	               		     p_category    => 'O');

          x_status := 1;
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  	  p_qp_list_header_tbl.DELETE;
  	  p_qp_list_line_tbl.DELETE;
  	  p_qp_qualifier_tbl.DELETE;
  	  p_qp_pricing_attrib_tbl.DELETE;
          RETURN;
      END; --FINISH INSERTING QUALIFIERS
    END IF;

    IF (p_qp_list_line_tbl.COUNT > 0) THEN
      FOR i IN p_qp_list_line_tbl.FIRST..p_qp_list_line_tbl.LAST LOOP
        LL_PROCESS_ID(i)		:= p_qp_list_line_tbl(i).process_id;
        LL_OPERAND(i)			:= p_qp_list_line_tbl(i).operand;
        LL_COMMENTS(i)			:= p_qp_list_line_tbl(i).comments;
        LL_LIST_LINE_NO(i)		:= p_qp_list_line_tbl(i).list_line_no;
        LL_PRIMARY_UOM_FLAG(i)		:= p_qp_list_line_tbl(i).primary_uom_flag;
        LL_PROCESS_TYPE(i)		:= p_qp_list_line_tbl(i).process_type;
        LL_INT_ACTION_CODE(i)		:= p_qp_list_line_tbl(i).interface_action_code;
        LL_LIST_LINE_TYPE_CODE(i)	:= p_qp_list_line_tbl(i).list_line_type_code;
        LL_AUTOMATIC_FLAG(i)		:= p_qp_list_line_tbl(i).automatic_flag;
        LL_OVERRIDE_FLAG(i)		:= p_qp_list_line_tbl(i).override_flag;
        LL_MOD_LEVEL_CODE(i)		:= p_qp_list_line_tbl(i).modifier_level_code;
        LL_ARITHMETIC_OPERATOR(i)	:= p_qp_list_line_tbl(i).arithmetic_operator;
        LL_ACCRUAL_FLAG(i)		:= p_qp_list_line_tbl(i).accrual_flag;
        LL_PRC_BRK_TYPE_CODE(i)		:= p_qp_list_line_tbl(i).price_break_type_code;
        LL_PRODUCT_PRECEDENCE(i)	:= p_qp_list_line_tbl(i).product_precedence;
        LL_PRC_BRK_HDR_IDX(i)		:= p_qp_list_line_tbl(i).price_break_header_index;
        LL_RLTD_MOD_GRP_NO(i)		:= p_qp_list_line_tbl(i).rltd_modifier_grp_no;
        LL_ATTRIBUTE1(i)		:= p_qp_list_line_tbl(i).attribute1;
        LL_ATTRIBUTE2(i)		:= p_qp_list_line_tbl(i).attribute2;
        LL_RLTD_MOD_GRP_TYPE(i)		:= p_qp_list_line_tbl(i).rltd_modifier_grp_type;
        LL_PRICING_GRP_SEQUENCE(i)	:= p_qp_list_line_tbl(i).pricing_group_sequence;
        LL_PRICING_PHASE_ID(i)		:= p_qp_list_line_tbl(i).pricing_phase_id;
        LL_QUALIFICATION_IND(i)		:= p_qp_list_line_tbl(i).qualification_ind;
        LL_CHARGE_TYPE_CODE(i)		:= p_qp_list_line_tbl(i).charge_type_code;
        LL_CHARGE_SUBTYPE_CODE(i)	:= p_qp_list_line_tbl(i).charge_subtype_code;
        LL_FORMULA_ID(i)         	:= p_qp_list_line_tbl(i).price_by_formula_id;
	LL_START_DATE_ACTIVE(i)		:= p_qp_list_line_tbl(i).start_date_active;
	LL_END_DATE_ACTIVE(i)		:= p_qp_list_line_tbl(i).end_date_active;
      END LOOP;

      --INSERT LINES AND BREAKS
      BEGIN
        FORALL cnt IN p_qp_list_line_tbl.FIRST..p_qp_list_line_tbl.LAST
          INSERT INTO QP_INTERFACE_LIST_LINES( PROCESS_ID,
                                               OPERAND,
                                               COMMENTS,
                                               LIST_LINE_NO,
                                               PRIMARY_UOM_FLAG,
                                               PROCESS_TYPE,
                                               INTERFACE_ACTION_CODE,
                                               LIST_LINE_TYPE_CODE,
                                               AUTOMATIC_FLAG,
                                               OVERRIDE_FLAG,
                                               MODIFIER_LEVEL_CODE,
                                               ARITHMETIC_OPERATOR,
                                               ACCRUAL_FLAG,
                                               PRICE_BREAK_TYPE_CODE,
                                               PRODUCT_PRECEDENCE,
                                               PRICE_BREAK_HEADER_INDEX,
                                               RLTD_MODIFIER_GRP_NO,
                                               PRICE_BY_FORMULA_ID,
                                               ATTRIBUTE1,
                                               ATTRIBUTE2,
                                               RLTD_MODIFIER_GRP_TYPE,
                                               PRICING_GROUP_SEQUENCE,
                                               PRICING_PHASE_ID,
                                               QUALIFICATION_IND,
                                               CHARGE_TYPE_CODE,
                                               CHARGE_SUBTYPE_CODE,
					       START_DATE_ACTIVE,
					       END_DATE_ACTIVE,
                                               CREATION_DATE,
                                               LAST_UPDATE_DATE,
                                               CREATED_BY,
                                               LAST_UPDATED_BY,
                                               LAST_UPDATE_LOGIN)
                                       VALUES(
                                               LL_PROCESS_ID(cnt),
                                               LL_OPERAND(cnt),
                                               LL_COMMENTS(cnt),
                                               LL_LIST_LINE_NO(cnt),
                                               LL_PRIMARY_UOM_FLAG(cnt),
                                               LL_PROCESS_TYPE(cnt),
                                               LL_INT_ACTION_CODE(cnt),
                                               LL_LIST_LINE_TYPE_CODE(cnt),
                                               LL_AUTOMATIC_FLAG(cnt),
                                               LL_OVERRIDE_FLAG(cnt),
                                               LL_MOD_LEVEL_CODE(cnt),
                                               LL_ARITHMETIC_OPERATOR(cnt),
                                               LL_ACCRUAL_FLAG(cnt),
                                               LL_PRC_BRK_TYPE_CODE(cnt),
                                               LL_PRODUCT_PRECEDENCE(cnt),
                                               LL_PRC_BRK_HDR_IDX(cnt),
                                               LL_RLTD_MOD_GRP_NO(cnt),
                                               LL_FORMULA_ID(cnt),
                                               LL_ATTRIBUTE1(cnt),
                                               LL_ATTRIBUTE2(cnt),
                                               LL_RLTD_MOD_GRP_TYPE(cnt),
                                               LL_PRICING_GRP_SEQUENCE(cnt),
                                               LL_PRICING_PHASE_ID(cnt),
                                               LL_QUALIFICATION_IND(cnt),
                                               LL_CHARGE_TYPE_CODE(cnt),
                                               LL_CHARGE_SUBTYPE_CODE(cnt),
					       LL_START_DATE_ACTIVE(cnt),
					       LL_END_DATE_ACTIVE(cnt),
				  	       sysdate,
					       sysdate,
                                               FND_GLOBAL.USER_ID,
                                               FND_GLOBAL.USER_ID,
                                               FND_GLOBAL.USER_ID);
      EXCEPTION
        WHEN OTHERS THEN
	  x_error_msg := sqlerrm;
	  FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, '[Inserting rate chart lines]');
 	  FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
  	               		     p_msg   	   => x_error_msg,
	               		     p_category    => 'O');

          x_status := 1;
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  	  p_qp_list_header_tbl.DELETE;
  	  p_qp_list_line_tbl.DELETE;
  	  p_qp_qualifier_tbl.DELETE;
  	  p_qp_pricing_attrib_tbl.DELETE;
          RETURN;
      END; --FINISH INSERTING LIST_LINES
    END IF;

    --INSERT PRICING ATTRIBUTES
    --Insert any trailing region at the end of the pricelist.
    IF (g_region_flag IS NOT NULL AND g_process_id IS NOT NULL) THEN
      l_region_id := FTE_REGION_ZONE_LOADER.Get_Region_ID(p_region_info	=> G_region_info);

      IF (x_status <> -1) THEN
        FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  	p_qp_list_header_tbl.DELETE;
  	p_qp_list_line_tbl.DELETE;
  	p_qp_qualifier_tbl.DELETE;
  	p_qp_pricing_attrib_tbl.DELETE;
        RETURN;
      END IF;

      IF (l_region_id <> -1) THEN
        FTE_VALIDATION_PKG.ADD_Attribute(p_pricing_attribute  => (g_region_flag || '_ZONE'),
                                         p_attr_value_from    => l_region_id,
                                         p_attr_value_to      => NULL,
                                         p_line_number        => G_region_linenum,
                            		 p_context            => g_region_context,
                                	 p_comp_operator      => NULL,
			  		 p_qp_pricing_attrib_tbl => p_qp_pricing_attrib_tbl,
                             		 x_status             => x_status,
					 x_error_msg	      => x_error_msg);
      ELSE
        x_status := 2;
        x_error_msg := Fte_Util_PKG.Get_Msg(p_name 	=> 'FTE_CAT_REGION_UNKNOWN',
					    p_tokens	=> STRINGARRAY('NAME'),
			 	    	    p_values	=> STRINGARRAY(g_region_flag));

	FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,  --check
		         	   p_msg    	 => x_error_msg,
		         	   p_category    => 'D');

        reset_region_info;
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
  	p_qp_list_header_tbl.DELETE;
  	p_qp_list_line_tbl.DELETE;
  	p_qp_qualifier_tbl.DELETE;
  	p_qp_pricing_attrib_tbl.DELETE;
        return;
      END IF;
    END IF;

    IF (p_qp_pricing_attrib_tbl.COUNT > 0) THEN
      FOR i IN p_qp_pricing_attrib_tbl.FIRST..p_qp_pricing_attrib_tbl.LAST LOOP
        AT_PROCESS_ID(i)		:= p_qp_pricing_attrib_tbl(i).process_id;
        AT_PROCESS_TYPE(i)		:= p_qp_pricing_attrib_tbl(i).process_type;
        AT_INT_ACTION_CODE(i)		:= p_qp_pricing_attrib_tbl(i).interface_action_code;
        AT_EXCLUDER_FLAG(i)		:= p_qp_pricing_attrib_tbl(i).excluder_flag;
        AT_PRODUCT_ATTR_CONTEXT(i)	:= p_qp_pricing_attrib_tbl(i).product_attribute_context;
        AT_PRODUCT_ATTRIBUTE(i)		:= p_qp_pricing_attrib_tbl(i).product_attribute;
        AT_PRODUCT_ATTR_VALUE(i)	:= p_qp_pricing_attrib_tbl(i).product_attr_value;
        AT_PRODUCT_UOM_CODE(i)		:= p_qp_pricing_attrib_tbl(i).product_uom_code;
        AT_PRODUCT_ATTR_DATATYPE(i)	:= p_qp_pricing_attrib_tbl(i).product_attribute_datatype;
        AT_PRICING_ATTR_DATATYPE(i)	:= p_qp_pricing_attrib_tbl(i).pricing_attribute_datatype;
        AT_PRICING_ATTR_CONTEXT(i)	:= p_qp_pricing_attrib_tbl(i).pricing_attribute_context;
        AT_PRICING_ATTRIBUTE(i)		:= p_qp_pricing_attrib_tbl(i).pricing_attribute;
        AT_PRICING_ATTR_VALUE_FROM(i)	:= p_qp_pricing_attrib_tbl(i).pricing_attr_value_from;
        AT_PRICING_ATTR_VALUE_TO(i)	:= p_qp_pricing_attrib_tbl(i).pricing_attr_value_to;
        AT_ATTR_GROUPING_NO(i)		:= p_qp_pricing_attrib_tbl(i).attribute_grouping_no;
        AT_COMP_OPERATOR_CODE(i)	:= p_qp_pricing_attrib_tbl(i).comparison_operator_code;
        AT_LIST_LINE_NO(i)		:= p_qp_pricing_attrib_tbl(i).list_line_no;
      END LOOP;

      BEGIN
        FORALL cnt IN p_qp_pricing_attrib_tbl.FIRST..p_qp_pricing_attrib_tbl.LAST
          INSERT INTO QP_INTERFACE_PRICING_ATTRIBS(PROCESS_ID,
                                                   PROCESS_TYPE,
                                                   INTERFACE_ACTION_CODE,
                                                   EXCLUDER_FLAG,
                                                   PRODUCT_ATTRIBUTE_CONTEXT,
                                                   PRODUCT_ATTRIBUTE,
                                                   PRODUCT_ATTR_VALUE,
                                                   PRODUCT_UOM_CODE,
                                                   PRODUCT_ATTRIBUTE_DATATYPE,
                                                   PRICING_ATTRIBUTE_DATATYPE,
                                                   PRICING_ATTRIBUTE_CONTEXT,
                                                   PRICING_ATTRIBUTE,
                                                   PRICING_ATTR_VALUE_FROM,
                                                   PRICING_ATTR_VALUE_TO,
                                                   ATTRIBUTE_GROUPING_NO,
                                                   COMPARISON_OPERATOR_CODE,
                                                   LIST_LINE_NO,
                                                   CREATION_DATE,
                                                   LAST_UPDATE_DATE,
                                                   CREATED_BY,
                                                   LAST_UPDATED_BY,
                                                   LAST_UPDATE_LOGIN)
                                           VALUES(
                                                   AT_PROCESS_ID(cnt),
                                                   AT_PROCESS_TYPE(cnt),
                                                   AT_INT_ACTION_CODE(cnt),
                                                   AT_EXCLUDER_FLAG(cnt),
                                                   AT_PRODUCT_ATTR_CONTEXT(cnt),
                                                   AT_PRODUCT_ATTRIBUTE(cnt),
                                                   AT_PRODUCT_ATTR_VALUE(cnt),
                                                   AT_PRODUCT_UOM_CODE(cnt),
                                                   AT_PRODUCT_ATTR_DATATYPE(cnt),
                                                   AT_PRICING_ATTR_DATATYPE(cnt),
                                                   AT_PRICING_ATTR_CONTEXT(cnt),
                                                   AT_PRICING_ATTRIBUTE(cnt),
                                                   AT_PRICING_ATTR_VALUE_FROM(cnt),
                                                   AT_PRICING_ATTR_VALUE_TO(cnt),
                                                   AT_ATTR_GROUPING_NO(cnt),
                                                   AT_COMP_OPERATOR_CODE(cnt),
                                                   AT_LIST_LINE_NO(cnt),
                                                   sysdate,
                                                   sysdate,
                                                   FND_GLOBAL.USER_ID,
                                                   FND_GLOBAL.USER_ID,
                                                   FND_GLOBAL.USER_ID);

      EXCEPTION
        WHEN OTHERS THEN
	  x_error_msg := sqlerrm;
	  FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, '[Inserting attributes]');
  	  FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	               		     p_msg   	   => x_error_msg,
	              		     p_category    => 'O');
          x_status := 1;
          FTE_UTIL_PKG.EXIT_DEBUG(l_module_name);
  	  p_qp_list_header_tbl.DELETE;
  	  p_qp_list_line_tbl.DELETE;
  	  p_qp_qualifier_tbl.DELETE;
  	  p_qp_pricing_attrib_tbl.DELETE;
          RETURN;
      END; --FINISH INSERTING PRICING_ATTRIBS
    END IF;

    -- temp fix for facility call with only qualifier
    IF (p_qp_list_header_tbl.COUNT = 0) THEN
      g_process_id := p_qp_qualifier_tbl(p_qp_qualifier_tbl.FIRST).process_id;
    END IF;

    IF (G_PROCESS_ID IS NOT NULL AND p_qp_call) THEN
      QP_API_CALL(p_chart_type 	=> g_chart_type,
	 	  p_process_id	=> g_process_id,
		  p_name 	=> LH_NAME,
		  p_currency  	=> LH_CURRENCY_CODE,
		  x_status	=> x_status,
		  x_error_msg 	=> x_error_msg);

      IF (x_status <> -1) THEN
    	p_qp_list_header_tbl.DELETE;
    	p_qp_list_line_tbl.DELETE;
    	p_qp_qualifier_tbl.DELETE;
    	p_qp_pricing_attrib_tbl.DELETE;
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        return;
      END IF;
        --+
        -- For Generating Output file
        --+
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
			           p_msg_name	 => 'FTE_RATECHARTS_LOADED',
			           p_category	 => NULL);

        FOR i in LH_NAME.FIRST..LH_NAME.LAST LOOP

            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
		                       p_msg	     => LH_NAME(i),
			               p_category    => NULL);
        END LOOP;

    END IF; --if job_id is not null

    Reset_All; --Reset all global variables

    p_qp_list_header_tbl.DELETE;
    p_qp_list_line_tbl.DELETE;
    p_qp_qualifier_tbl.DELETE;
    p_qp_pricing_attrib_tbl.DELETE;
    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  EXCEPTION WHEN OTHERS THEN
--    IF (GET_CURRENCY_HEADER_ID%ISOPEN) THEN
--      CLOSE GET_CURRENCY_HEADER_ID;
--    END IF;
    x_error_msg := sqlerrm;
    x_status := 2;
    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
              		       p_msg         => x_error_msg,
              		       p_category    => 'O');

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
    p_qp_list_header_tbl.DELETE;
    p_qp_list_line_tbl.DELETE;
    p_qp_qualifier_tbl.DELETE;
    p_qp_pricing_attrib_tbl.DELETE;
    RETURN;
  END INSERT_QP_INTERFACE_TABLES;

  -----------------------------------------------------------------------------
  -- FUNCTION   Get_Assoc_Modifiers
  --
  -- Purpose  Get the list of modifiers associated with the rate chart
  --          using either the rate chart's name or List Header ID.
  --
  -- IN Parameters
  --  1. p_list_header_id:
  --  2. p_pricelist_name:
  --
  -- RETURN
  --  1. STRINGARRAY: A list of associated modifier IDs.
  -----------------------------------------------------------------------------
  FUNCTION Get_Assoc_Modifiers(p_list_header_id    IN     NUMBER,
                               p_pricelist_name  IN  VARCHAR2)
    RETURN STRINGARRAY IS

  l_mod_ids  STRINGARRAY;
  l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.GET_ASSOC_MODIFIERS';

  CURSOR Get_Modifiers_With_Name IS
    SELECT modc.list_header_id
    FROM   qp_list_headers_tl rc, qp_list_headers_b b,
           qp_list_headers_tl modc, qp_list_headers_b b2,
           qp_qualifiers   mod_qual
    WHERE  rc.list_header_id = b.list_header_id
    AND    modc.list_header_id = b2.list_header_id
    AND    mod_qual.qualifier_context = 'MODLIST'
    AND    mod_qual.qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'
    AND    to_number(mod_qual.qualifier_attr_value) = rc.list_header_id
    AND    mod_qual.list_header_id = modc.list_header_id
    AND    rc.name = p_pricelist_name
    AND    rc.language = userenv('LANG')
    AND    modc.language = userenv('LANG')
    ORDER BY rc.creation_date DESC;

  CURSOR Get_Modifiers_With_ID IS
    SELECT modc.list_header_id
    FROM   qp_list_headers_tl rc, qp_list_headers_b b,
           qp_list_headers_tl modc, qp_list_headers_b b2,
           qp_qualifiers mod_qual
    WHERE  rc.list_header_id = b.list_header_id
    AND    modc.list_header_id = b2.list_header_id
    AND    mod_qual.qualifier_context = 'MODLIST'
    AND    mod_qual.qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'
    AND    to_number(mod_qual.qualifier_attr_value) = rc.list_header_id
    AND    mod_qual.list_header_id = modc.list_header_id
    AND    rc.list_header_id = p_list_header_id
    AND    rc.language = userenv('LANG')
    AND    modc.language = userenv('LANG')
    ORDER BY rc.creation_date DESC;

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'List Header ID', p_list_header_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Rate Chart Name', p_pricelist_name);
    END IF;

    IF (p_list_header_id IS NOT NULL) THEN
      OPEN Get_Modifiers_With_ID;
      FETCH Get_Modifiers_With_ID BULK COLLECT INTO l_mod_ids;
      CLOSE Get_Modifiers_With_ID;
    ELSIF (p_pricelist_name IS NOT NULL) THEN
      OPEN Get_Modifiers_With_Name;
      FETCH Get_Modifiers_With_Name BULK COLLECT INTO l_mod_ids;
      CLOSE Get_Modifiers_With_Name;
    END IF;
    FTE_UTIL_PKG.Exit_Debug(l_module_name);
    return l_mod_ids;
  EXCEPTION WHEN OTHERS THEN
    IF (Get_Modifiers_With_Name%ISOPEN) THEN
      CLOSE Get_Modifiers_With_Name;
    END IF;
    IF (Get_Modifiers_With_ID%ISOPEN) THEN
      CLOSE Get_Modifiers_With_ID;
    END IF;
    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name   => l_module_name,
             			p_msg   	=> sqlerrm,
             			p_category      => 'O');

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
    RAISE;
  END Get_Assoc_Modifiers;

  -----------------------------------------------------------------------------
  -- FUNCTION   GET_ASSOC_PRICELISTS
  --
  -- Purpose  Get the list of pricelists associated with the modifier using
  --          either the rate chart's name or List Header ID.
  --
  -- IN Parameters
  --  1. p_list_header_id:
  --  2. p_modifier_name:
  --
  -- RETURN
  --  1. STRINGARRAY: A list of associated pricelist IDs.
  -----------------------------------------------------------------------------
  FUNCTION GET_ASSOC_PRICELISTS (p_list_header_id  IN     NUMBER,
                                 p_modifier_name   IN     VARCHAR2)
  RETURN STRINGARRAY IS

   l_mod_ids  STRINGARRAY;
   l_module_name      CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.GET_ASSOC_PRICELISTS';

   CURSOR Get_Pricelists_With_Name IS
     SELECT rc.list_header_id
     FROM   qp_list_headers_tl rc, qp_list_headers_b b,
            qp_list_headers_tl modc, qp_list_headers_b b2,
            qp_qualifiers   mod_qual
     WHERE  rc.list_header_id = b.list_header_id
     AND    modc.list_header_id = b2.list_header_id
     AND    mod_qual.qualifier_context = 'MODLIST'
     AND    mod_qual.qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'
     AND    to_number(mod_qual.qualifier_attr_value) = rc.list_header_id
     AND    mod_qual.list_header_id = modc.list_header_id
     AND    modc.name = p_modifier_name
     AND    rc.language = userenv('LANG')
     AND    modc.language = userenv('LANG')
     ORDER BY rc.creation_date DESC;

   CURSOR Get_Pricelists_With_ID IS
     SELECT rc.list_header_id
     FROM   qp_list_headers_tl rc, qp_list_headers_b b,
            qp_list_headers_tl modc, qp_list_headers_b b2,
            qp_qualifiers   mod_qual
     WHERE  rc.list_header_id = b.list_header_id
     AND    modc.list_header_id = b2.list_header_id
     AND    mod_qual.qualifier_context = 'MODLIST'
     AND    mod_qual.qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'
     AND    to_number(mod_qual.qualifier_attr_value) = rc.list_header_id
     AND    mod_qual.list_header_id = modc.list_header_id
     AND    modc.name = p_modifier_name
     AND    rc.language = userenv('LANG')
     AND    modc.language = userenv('LANG')
     ORDER BY rc.creation_date DESC;


   BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'List Header ID', p_list_header_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Modifier Name', p_modifier_name);
    END IF;

    IF (p_list_header_id IS NOT NULL) THEN
      OPEN Get_Pricelists_With_ID;
      FETCH Get_Pricelists_With_ID BULK COLLECT INTO l_mod_ids;
      CLOSE Get_Pricelists_With_ID;
    ELSIF (p_modifier_name IS NOT NULL) THEN
      OPEN Get_Pricelists_With_Name;
      FETCH Get_Pricelists_With_Name BULK COLLECT INTO l_mod_ids;
      CLOSE Get_Pricelists_With_Name;
    END IF;

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
    return L_MOD_IDS;
  EXCEPTION WHEN OTHERS THEN
    IF (Get_Pricelists_With_Name%ISOPEN) THEN
      CLOSE Get_Pricelists_With_Name;
    END IF;
    IF (Get_Pricelists_With_ID%ISOPEN) THEN
      CLOSE Get_Pricelists_With_ID;
    END IF;
    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name   => l_module_name,
             			p_msg   	=> sqlerrm,
             			p_category      => 'O');

    FTE_UTIL_PKG.Exit_Debug(l_module_name);
    RAISE;
  END GET_ASSOC_PRICELISTS;


  -----------------------------------------------------------------------------
  -- PROCEDURE QP_API_CALL
  --
  -- Purpose  Call the qp api for loading pricelist and modlist
  --
  -- IN Parameters
  --  1. p_chart_type:	type of the load, pricelist or modlist
  --  2. p_process_id:  process id to load
  --  3. p_name:	name of the chart
  --  4. p_currency:	currency of the chart
  --
  -- OUT paramters
  --  1. x_status: 	status, -1 for no error
  --  2. x_error_msg:	error message if any.
  -----------------------------------------------------------------------------

  PROCEDURE QP_API_CALL(p_chart_type	IN VARCHAR2,
			p_process_id	IN NUMBER,
			p_name		IN  LH_NAME_TAB,
			p_currency	IN  LH_CURRENCY_CODE_TAB,
			x_status	OUT NOCOPY NUMBER,
			x_error_msg	OUT NOCOPY VARCHAR2) IS
  l_status      VARCHAR2(10);
  l_sql_errors  VARCHAR2(8000);
  l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.QP_API_CALL';

  l_list_header_ids 		STRINGARRAY := STRINGARRAY();
  l_return_status               VARCHAR2(1);
  x_msg_count                   number;
  x_msg_data                    Varchar2(2000);
  x_msg_index                   number;

  l_CURR_LISTS_rec             QP_Currency_PUB.Curr_Lists_Rec_Type;
  l_CURR_LISTS_val_rec         QP_Currency_PUB.Curr_Lists_Val_Rec_Type;
  l_CURR_DETAILS_tbl           QP_Currency_PUB.Curr_Details_Tbl_Type;
  l_CURR_DETAILS_val_tbl       QP_Currency_PUB.Curr_Details_Val_Tbl_Type;

  l_currency_header_id		NUMBER;
  l_result			VARCHAR2(10);

  CURSOR GET_CURRENCY_HEADER_ID(p_list_header_id IN NUMBER) IS
    SELECT currency_header_id
      FROM qp_list_headers
     WHERE list_header_id = p_list_header_id;

  CURSOR CONVERSION_EXIST(p_currency_header_id IN NUMBER, p_currency IN VARCHAR2) IS
    SELECT 'TRUE'
      FROM qp_currency_details
     WHERE currency_header_id = p_currency_header_id
       AND to_currency_code = p_currency;

  CURSOR GET_MOD_PRICELIST(p_name IN VARCHAR2) IS
    SELECT to_char(b.list_header_id)
      FROM qp_list_headers_tl lh,
      	   qp_list_headers_b b,
      	   qp_qualifiers qc,
      	   qp_qualifiers qs,
      	   qp_qualifiers qm,
	   qp_list_headers_tl modlh,
	   qp_qualifiers modqs,
	   qp_qualifiers modqc
     WHERE modlh.name = p_name AND
	   modlh.list_header_id = modqs.list_header_id AND
	   modqc.list_header_id = modlh.list_header_id AND
	   modqs.qualifier_attribute  = 'QUALIFIER_ATTRIBUTE10' AND
	   modqs.qualifier_context    = 'LOGISTICS' AND
	   modqc.qualifier_attribute  = 'QUALIFIER_ATTRIBUTE1' AND
      	   modqc.qualifier_context    = 'PARTY' AND
      	   lh.list_header_id       = b.list_header_id AND
      	   qc.qualifier_attribute  = 'QUALIFIER_ATTRIBUTE1' AND
      	   qc.qualifier_context    = 'PARTY' AND
      	   qc.qualifier_attr_value = modqc.qualifier_attr_value AND
      	   qc.list_header_id       = lh.list_header_id AND
      	   qs.qualifier_attribute  = 'QUALIFIER_ATTRIBUTE10' AND
      	   qs.qualifier_context    = 'LOGISTICS' AND
      	   qs.qualifier_attr_value = modqs.qualifier_attr_value AND
      	   qs.list_header_id       = qc.list_header_id AND
      	   qm.qualifier_attribute  = 'QUALIFIER_ATTRIBUTE7' AND
      	   qm.qualifier_context    = 'LOGISTICS' AND
      	   qm.qualifier_attr_value = 'TRUCK' AND
      	   qm.list_header_id       = qc.list_header_id AND
	   b.attribute1 = 'TL_RATE_CHART' AND
     	   lh.language             = userenv('LANG');

  BEGIN
    FTE_UTIL_PKG.ENTER_DEBUG(l_module_name);

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Type of Chart', p_chart_type);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Process ID', p_process_id);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of Chart Name', p_name.COUNT);
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Number of Currency', p_currency.COUNT);
    END IF;
    x_status := -1;

    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Calling QP_PRL_LOADER_PUB.Load_Price_List');
    END IF;

    FND_PROFILE.PUT('QP_PRICING_TRANSACTION_ENTITY', 'LOGSTX');
    FND_PROFILE.PUT('QP_SOURCE_SYSTEM_CODE', 'FTE');

    IF (p_chart_type LIKE '%RATE_CHART%') THEN
      QP_PRL_LOADER_PUB.Load_Price_List(p_process_id    => p_process_id,
                                        p_req_type_code => 'FTE',
                                        x_status        => l_status,
                                        x_errors        => l_sql_errors);

    ELSIF (p_chart_type LIKE '%MODIFIER%') THEN
      QP_MOD_LOADER_PUB.Load_Mod_List(p_process_id    => p_process_id,
                                      p_req_type_code => 'FTE',
                                      x_status        => l_status,
                                      x_errors        => l_sql_errors);

    ELSE
      x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CHART_TYPE_NULL');
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	                	 p_msg	   => x_error_msg,
	                	 p_category    => 'O');

      x_status := 2;
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
      RETURN;

    END IF;

    --check for errors
    IF (l_status <> 'COMPLETED') THEN
      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name 	=> 'FTE_QP_ERROR',
				    	  p_tokens	=> STRINGARRAY('STATUS', 'ERROR'),
					  p_values	=> STRINGARRAY(l_status, substr(l_sql_errors, 0, 700)));

      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
	                	 p_msg	 => x_error_msg,
	                	 p_category    => 'O');

      x_status := 2;
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
    ELSE

      --For Parcel Rate Charts. Assumes that there is only one rate
      --chart in the spread sheet. **
      IF (LH_REPLACE_RC.COUNT > 0) THEN
        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
          FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'REPLACING RATE CHART ');
        END IF;

        Replace_Rate_Chart(p_old_id => LH_REPLACE_RC(1),
			   p_new_name => LH_NEW_RC(1),
			   x_status => x_status,
			   x_error_msg => x_error_msg);

	IF (x_status <> -1) THEN
	  FTE_UTIL_PKG.Exit_Debug(l_module_name);
	  RETURN;
	END IF;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
          FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, LH_REPLACE_RC(1) || ' => ' || LH_NEW_RC(1));
        END IF;
      END IF;
    END IF;

    IF (p_chart_type LIKE '%MODIFIER%') THEN
      -- find out the type of modifier and the currency list header
      FOR j IN p_name.FIRST..p_name.LAST LOOP
	IF (p_chart_type = 'TL_MODIFIER') THEN
	  OPEN GET_MOD_PRICELIST(p_name => p_name(j));
	  FETCH GET_MOD_PRICELIST BULK COLLECT INTO l_list_header_ids;
	  CLOSE GET_MOD_PRICELIST;
        ELSE
          l_list_header_ids := GET_ASSOC_PRICELISTS (p_list_header_id  => NULL,
                               			     p_modifier_name   => p_name(j));
   	END IF;

        IF (l_list_header_ids IS NOT NULL AND l_list_header_ids.COUNT > 0) THEN
          FOR i IN l_list_header_ids.FIRST..l_list_header_ids.LAST LOOP
	    OPEN GET_CURRENCY_HEADER_ID(l_list_header_ids(i));
	    FETCH GET_CURRENCY_HEADER_ID INTO l_currency_header_id;
	    CLOSE GET_CURRENCY_HEADER_ID;

  	    IF (l_currency_header_id IS NULL) THEN
	      x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_MULTI_CURR_DISABLED');
	      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
				         p_msg		=> x_error_msg,
				         p_category	=> 'B');
	      x_status := 2;
	      FTE_UTIL_PKG.Exit_Debug(l_module_name);
	      RETURN;
  	    END IF;

	    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
	      FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Currency Header Id', l_currency_header_id);
	    END IF;

	    OPEN CONVERSION_EXIST(l_currency_header_id, p_currency(j));
	    FETCH CONVERSION_EXIST INTO l_result;
	    CLOSE CONVERSION_EXIST;

  	    IF (l_result IS NULL) THEN --no conversion
	      l_CURR_LISTS_rec.currency_header_id	:= l_currency_header_id;
	      l_CURR_LISTS_rec.operation                := QP_GLOBALS.G_OPR_UPDATE;

 	      -- Create Multi-Currency Details for Currency

	      l_CURR_DETAILS_tbl(1).to_currency_code := p_currency(j);
	      l_CURR_DETAILS_tbl(1).conversion_type := 'Corporate';
	      l_CURR_DETAILS_tbl(1).conversion_date_type := 'PRICING_EFFECTIVITY_DATE';
	      l_CURR_DETAILS_tbl(1).operation := QP_GLOBALS.G_OPR_CREATE;
	      l_CURR_DETAILS_tbl(1).selling_rounding_factor := -2;

  	      -- Call the Multi-Currency Conversion Public API to create the header and lines
  	      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
	        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Calling Process Currency');
	        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Currency', p_currency(j));
	      END IF;

	      QP_Currency_PUB.Process_Currency( p_api_version_number => 1.0
					      , x_return_status  => l_return_status
					      , x_msg_count      =>x_msg_count
					      , x_msg_data       =>x_msg_data
					      , p_CURR_LISTS_rec           => l_CURR_LISTS_rec
					      , p_CURR_LISTS_val_rec       => l_CURR_LISTS_val_rec
					      , p_CURR_DETAILS_tbl         => l_CURR_DETAILS_tbl
					      , p_CURR_DETAILS_val_tbl	 => l_CURR_DETAILS_val_tbl
					      , x_CURR_LISTS_rec           => l_CURR_LISTS_rec
					      , x_CURR_LISTS_val_rec       => l_CURR_LISTS_val_rec
					      , x_CURR_DETAILS_tbl         => l_CURR_DETAILS_tbl
					      , x_CURR_DETAILS_val_tbl     => l_CURR_DETAILS_val_tbl
					      );


              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		x_status := 2;
		x_error_msg := x_msg_data;
		FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
					   p_msg	 => x_error_msg,
					   p_category	 => 'O');
	        FTE_UTIL_PKG.Exit_Debug(l_module_name);
		RETURN;
              END IF;

  	      IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
	        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'Process Currency successfully');
	      END IF;

	    END IF;
          END LOOP;
	END IF;
      END LOOP;
    END IF;


    FTE_UTIL_PKG.Exit_Debug(l_module_name);
  EXCEPTION
    WHEN OTHERS THEN
      IF (GET_CURRENCY_HEADER_ID%ISOPEN) THEN
	CLOSE GET_CURRENCY_HEADER_ID;
      END IF;

      IF (CONVERSION_EXIST%ISOPEN) THEN
	CLOSE CONVERSION_EXIST;
      END IF;

      IF (GET_MOD_PRICELIST%ISOPEN) THEN
	CLOSE GET_MOD_PRICELIST;
      END IF;

      x_error_msg := sqlerrm;
      FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name 	=> l_module_name,
	            		 p_msg   	=> x_error_msg,
	               		 p_category    	=> 'O');

      x_status := 2;
      FTE_UTIL_PKG.Exit_Debug(l_module_name);
  END QP_API_CALL;

END FTE_RATE_CHART_PKG;

/
