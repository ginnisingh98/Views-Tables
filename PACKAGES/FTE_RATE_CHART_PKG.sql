--------------------------------------------------------
--  DDL for Package FTE_RATE_CHART_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_RATE_CHART_PKG" AUTHID CURRENT_USER AS
/* $Header: FTERCPKS.pls 120.3 2005/07/21 14:13:29 jishen noship $ */

  TYPE qp_list_header_rec IS RECORD (
       PROCESS_ID		qp_interface_list_headers.process_id%TYPE,
       INTERFACE_ACTION_CODE	qp_interface_list_headers.interface_action_code%TYPE,
       LIST_TYPE_CODE		qp_interface_list_headers.list_type_code%TYPE,
       START_DATE_ACTIVE	qp_interface_list_headers.start_date_active%TYPE,
       END_DATE_ACTIVE		qp_interface_list_headers.end_date_active%TYPE,
       CURRENCY_CODE		qp_interface_list_headers.currency_code%TYPE,
       NAME			qp_interface_list_headers.name%TYPE,
       DESCRIPTION		qp_interface_list_headers.description%TYPE,
       LIST_HEADER_ID		qp_interface_list_headers.list_header_id%TYPE,
       ATTRIBUTE1		qp_interface_list_headers.attribute1%TYPE);

  TYPE qp_list_header_tbl IS TABLE OF
       qp_list_header_rec
       INDEX BY BINARY_INTEGER;

  TYPE qp_list_line_rec IS RECORD (
       PROCESS_ID			qp_interface_list_lines.process_id%TYPE,
       OPERAND				qp_interface_list_lines.operand%TYPE,
       COMMENTS				qp_interface_list_lines.comments%TYPE,
       LIST_LINE_NO			qp_interface_list_lines.list_line_no%TYPE,
       PRIMARY_UOM_FLAG			qp_interface_list_lines.primary_uom_flag%TYPE,
       PROCESS_TYPE			qp_interface_list_lines.process_type%TYPE,
       INTERFACE_ACTION_CODE		qp_interface_list_lines.interface_action_code%TYPE,
       LIST_LINE_TYPE_CODE		qp_interface_list_lines.list_line_type_code%TYPE,
       AUTOMATIC_FLAG			qp_interface_list_lines.automatic_flag%TYPE,
       OVERRIDE_FLAG			qp_interface_list_lines.override_flag%TYPE,
       MODIFIER_LEVEL_CODE		qp_interface_list_lines.modifier_level_code%TYPE,
       ARITHMETIC_OPERATOR		qp_interface_list_lines.arithmetic_operator%TYPE,
       ACCRUAL_FLAG			qp_interface_list_lines.accrual_flag%TYPE,
       PRICE_BREAK_TYPE_CODE		qp_interface_list_lines.price_break_type_code%TYPE,
       PRODUCT_PRECEDENCE		qp_interface_list_lines.product_precedence%TYPE,
       PRICE_BREAK_HEADER_INDEX		qp_interface_list_lines.price_break_header_index%TYPE,
       RLTD_MODIFIER_GRP_NO		qp_interface_list_lines.rltd_modifier_grp_no%TYPE,
       PRICE_BY_FORMULA_ID		qp_interface_list_lines.price_by_formula_id%TYPE,
       ATTRIBUTE1			qp_interface_list_lines.attribute1%TYPE,
       ATTRIBUTE2			qp_interface_list_lines.attribute2%TYPE,
       RLTD_MODIFIER_GRP_TYPE		qp_interface_list_lines.rltd_modifier_grp_type%TYPE,
       PRICING_GROUP_SEQUENCE		qp_interface_list_lines.pricing_group_sequence%TYPE,
       PRICING_PHASE_ID			qp_interface_list_lines.pricing_phase_id%TYPE,
       QUALIFICATION_IND		qp_interface_list_lines.qualification_ind%TYPE,
       CHARGE_TYPE_CODE			qp_interface_list_lines.charge_type_code%TYPE,
       CHARGE_SUBTYPE_CODE		qp_interface_list_lines.charge_subtype_code%TYPE,
       START_DATE_ACTIVE		qp_interface_list_lines.start_date_active%TYPE,
       END_DATE_ACTIVE			qp_interface_list_lines.end_date_active%TYPE);

  TYPE qp_list_line_tbl IS TABLE OF
       qp_list_line_rec
       INDEX BY BINARY_INTEGER;

  TYPE qp_pricing_attrib_rec IS RECORD (
       PROCESS_ID			qp_interface_pricing_attribs.process_id%TYPE,
       PROCESS_TYPE			qp_interface_pricing_attribs.process_type%TYPE,
       INTERFACE_ACTION_CODE		qp_interface_pricing_attribs.interface_action_code%TYPE,
       EXCLUDER_FLAG			qp_interface_pricing_attribs.excluder_flag%TYPE,
       PRODUCT_ATTRIBUTE_CONTEXT	qp_interface_pricing_attribs.product_attribute_context%TYPE,
       PRODUCT_ATTRIBUTE		qp_interface_pricing_attribs.product_attribute%TYPE,
       PRODUCT_ATTR_VALUE		qp_interface_pricing_attribs.product_attr_value%TYPE,
       PRODUCT_UOM_CODE			qp_interface_pricing_attribs.product_uom_code%TYPE,
       PRODUCT_ATTRIBUTE_DATATYPE	qp_interface_pricing_attribs.product_attribute_datatype%TYPE,
       PRICING_ATTRIBUTE_DATATYPE	qp_interface_pricing_attribs.pricing_attribute_datatype%TYPE,
       PRICING_ATTRIBUTE_CONTEXT	qp_interface_pricing_attribs.pricing_attribute_context%TYPE,
       PRICING_ATTRIBUTE		qp_interface_pricing_attribs.pricing_attribute%TYPE,
       PRICING_ATTR_VALUE_FROM		qp_interface_pricing_attribs.pricing_attr_value_from%TYPE,
       PRICING_ATTR_VALUE_TO		qp_interface_pricing_attribs.pricing_attr_value_to%TYPE,
       ATTRIBUTE_GROUPING_NO		qp_interface_pricing_attribs.attribute_grouping_no%TYPE,
       COMPARISON_OPERATOR_CODE		qp_interface_pricing_attribs.comparison_operator_code%TYPE,
       LIST_LINE_NO			qp_interface_pricing_attribs.list_line_no%TYPE);

  TYPE qp_pricing_attrib_tbl IS TABLE OF
       qp_pricing_attrib_rec
       INDEX BY BINARY_INTEGER;

  TYPE qp_qualifier_rec IS RECORD (
       PROCESS_ID		qp_interface_qualifiers.process_id%TYPE,
       INTERFACE_ACTION_CODE	qp_interface_qualifiers.interface_action_code%TYPE,
       QUALIFIER_ATTR_VALUE	qp_interface_qualifiers.qualifier_attr_value%TYPE,
       QUALIFIER_GROUPING_NO	qp_interface_qualifiers.qualifier_grouping_no%TYPE,
       PROCESS_TYPE		qp_interface_qualifiers.process_type%TYPE,
       EXCLUDER_FLAG		qp_interface_qualifiers.excluder_flag%TYPE,
       COMPARISON_OPERATOR_CODE	qp_interface_qualifiers.comparison_operator_code%TYPE,
       QUALIFIER_CONTEXT	qp_interface_qualifiers.qualifier_context%TYPE,
       QUALIFIER_ATTRIBUTE	qp_interface_qualifiers.qualifier_attribute%TYPE);

  TYPE qp_qualifier_tbl IS TABLE OF
       qp_qualifier_rec
       INDEX BY BINARY_INTEGER;

  g_is_ltl      	 BOOLEAN := false;

  TYPE VARCHAR2_TAB IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
  TYPE NUMBER_TAB IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE LH_CURRENCY_CODE_TAB IS TABLE OF QP_INTERFACE_LIST_HEADERS.CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE LH_NAME_TAB IS TABLE OF QP_INTERFACE_LIST_HEADERS.NAME%TYPE INDEX BY BINARY_INTEGER;

 -- GLOBAL VARIABLES FOR Rate Chart HEADER

  G_Chart_Type           	VARCHAR2(50);
  G_prc_brk_hdr_count           NUMBER := 0;
  G_brk_hdr_updt_cnt            NUMBER := 0;


  G_line_desc                   VARCHAR2(200);
  G_previous_upper              NUMBER := 0;
  G_qualifier_count           	NUMBER  := 0;
  g_qualifier_group           	NUMBER := 0;


 -- GLOBAL VARIABLES   FROM LIST_LINES
  G_Is_Load_Pricelist           BOOLEAN;
  G_Process_Id                  NUMBER;

  G_item                        VARCHAR2(20);
  G_listHeaderId                NUMBER;
  G_listLineId                  NUMBER;
  G_Prc_Brk_Linenum             NUMBER;
  G_Prc_Brk_Hdr_Index           NUMBER;
  G_Mod_Grp                     NUMBER := 1;

  G_Prc_Brk_Type                VARCHAR2(20);
  G_Prc_Rate_Type               VARCHAR2(20);
  G_Prc_Vol_Type                VARCHAR2(20);
  G_Prc_Line_Desc               VARCHAR2(200);
  G_Product_UOM                 VARCHAR2(20);
  G_Cur_Line_Index              NUMBER;


  -- G_region_info   region_rec;
  G_region_info           	wsh_regions_search_pkg.region_rec;
  G_line_number          	NUMBER;
  G_region_flag           	VARCHAR2(20); --remember what the current region is
  G_region_linenum        	NUMBER := NULL;
  G_region_context        	VARCHAR2(30);

  LH_NEW_RC   VARCHAR2_TAB;
  LH_REPLACE_RC   NUMBER_TAB;

  -------------------------------------------------------------------------------
  --
  --   Reset_Price_Values. Resets GLOBAL Variables
  --
  -------------------------------------------------------------------------------
  PROCEDURE  Reset_Price_Values;

  -------------------------------------------------------------------------------
  --
  --   Reset_Region_Info. Resets GLOBAL record for Region. It is used by
  --                      Origin and Destination attributes
  -------------------------------------------------------------------------------
  PROCEDURE  Reset_REGION_INFO;

  -------------------------------------------------------------------------------
  --
  --   Reset_All. Resets All GLOBAL Variables
  --
  -------------------------------------------------------------------------------
  PROCEDURE  Reset_ALL;

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
  FUNCTION Get_Pricelist_Id (p_name       IN  VARCHAR2,
                             p_carrier_id  IN  NUMBER,
			     p_attribute1 OUT NOCOPY VARCHAR2) RETURN NUMBER;


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
  --    The pricelist Id, or -1 if the pricelist doesn't exist
  -----------------------------------------------------------------------------
  FUNCTION GET_RATE_CHART_INFO(p_name		IN	VARCHAR2,
			       p_carrier_id	IN	NUMBER,
			       x_status		OUT NOCOPY NUMBER,
			       x_error_msg	OUT NOCOPY VARCHAR2) RETURN STRINGARRAY;

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
  PROCEDURE INSERT_QP_INTERFACE_TABLES(p_qp_list_header_tbl	IN OUT NOCOPY	qp_list_header_tbl,
				       p_qp_list_line_tbl	IN OUT NOCOPY	qp_list_line_tbl,
				       p_qp_qualifier_tbl	IN OUT NOCOPY	qp_qualifier_tbl,
				       p_qp_pricing_attrib_tbl	IN OUT NOCOPY	qp_pricing_attrib_tbl,
				       p_qp_call		IN 	BOOLEAN DEFAULT TRUE,
				       x_status			OUT NOCOPY NUMBER,
				       x_error_msg		OUT NOCOPY VARCHAR2);

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
                           x_error_msg 		OUT  NOCOPY VARCHAR2);

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
  FUNCTION GET_ASSOC_MODIFIERS(p_list_header_id    IN     NUMBER,
                               p_pricelist_name  IN  VARCHAR2)
    RETURN STRINGARRAY;

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
  RETURN STRINGARRAY;

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
			x_error_msg	OUT NOCOPY VARCHAR2);
END FTE_RATE_CHART_PKG;

 

/
