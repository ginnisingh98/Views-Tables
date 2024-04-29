--------------------------------------------------------
--  DDL for Package XDP_OA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_OA_UTIL" AUTHID CURRENT_USER AS
/* $Header: XDPOAUTS.pls 120.1 2005/06/22 06:41:49 appldev ship $ */

-- PL/SQL Specification
-- Datastructure Definitions


 -- API specifications

-- Start of comments
--	API name 	: Add_WI_toLine
--	Type		: Public
--	Function	: Add a workitem to an order line.
--	Pre-reqs	: None.
--  @return    The runtime ID of the work item instance
--
--	Version	: Current version	11.5
--	Notes	:
--   This function will add a workitem to
--   an order line. It will also create the
--   workitem parameter list in the database
--   base on the order line information.
--   The workitem_instance_id will return at
--   the end of the function call.
-- End of comments
 Function Add_WI_toLine(
	p_line_item_id IN NUMBER,
	p_workitem_name IN VARCHAR2,
	p_workitem_version IN VARCHAR2 DEFAULT NULL,
	p_provisioning_date IN Date default NULL,
	p_priority IN number Default 100,
	p_provisioning_seq IN Number Default 0,
	p_due_date IN Date Default NULL,
	p_customer_required_date IN DATE Default NULL,
	p_oa_added_flag  IN VARCHAR2 DEFAULT 'Y')
   RETURN NUMBER;

-- Start of comments
--	API name 	: Add_WI_toLine
--	Type		: Public
--	Function	: Overload function. Add a workitem to an order line.
--	Pre-reqs	: None.
--  @return    The runtime ID of the work item instance
--
--	Version	: Current version	11.5
--	Notes	:
--   Overload function.
--   This function will add a workitem to
--   an order line. It will also create the
--   workitem parameter list in the database
--   base on the order line information.
--   The workitem_instance_id will return at
--   the end of the function call.
-- End of comments
 Function Add_WI_toLine(
	p_line_item_id IN NUMBER,
	p_workitem_id IN Number,
	p_provisioning_date IN Date Default NULL,
	p_priority IN number Default 100,
	p_provisioning_seq IN Number Default 0,
	p_due_date IN Date Default NULL,
	p_customer_required_date IN DATE Default NULL,
	p_oa_added_flag  IN VARCHAR2 DEFAULT 'Y')
   RETURN NUMBER;

-- Start of comments
--	API name 	: Add_WI_toLine
--	Type		: Public
--	Function	: Overload function. Add a workitem to an order line.
--	Pre-reqs	: None.
--  @return    The runtime ID of the work item instance
--
--	Version	: Current version	11.5
--	Notes	:
--   Overload function.
--   This function will add a workitem to
--   an order line. It will also create the
--   workitem parameter list in the database
--   base on the order line information.
--   The workitem_instance_id will return at
--   the end of the function call.It will also call user
--   defined validation procedure dynamically.
-- End of comments
--
 Function Add_WI_toLine(
	p_line_item_id IN NUMBER,
	p_workitem_id IN Number,
	p_provisioning_date IN Date Default NULL,
	p_priority IN number Default 100,
	p_provisioning_seq IN Number Default 0,
	p_due_date IN Date Default NULL,
	p_customer_required_date IN DATE Default NULL,
	p_oa_added_flag  IN VARCHAR2 DEFAULT 'Y',
        x_error_code      OUT NOCOPY NUMBER,
        x_error_message   OUT NOCOPY VARCHAR2)
   RETURN NUMBER;

-- Start of comments
--	API name 	: Add_WI_toLine
--	Type		: Public
--	Function	: Overload function. Add a workitem to an order line.
--	Pre-reqs	: None.
--  @return    The runtime ID of the work item instance
--
--	Version	: Current version	11.5
--	Notes	:
--   Overload function.
--   This function will add a workitem to
--   an order line. It will also create the
--   workitem parameter list in the database
--   base on the order line information.
--   The workitem_instance_id will return at
--   the end of the function call.It will also call user
--   defined validation procedure dynamically.
-- End of comments
--
 Function Add_WI_toLine(
	p_line_item_id IN NUMBER,
	p_workitem_name IN VARCHAR2,
	p_workitem_version IN VARCHAR2 DEFAULT NULL,
	p_provisioning_date IN Date default NULL,
	p_priority IN number Default 100,
	p_provisioning_seq IN Number Default 0,
	p_due_date IN Date Default NULL,
	p_customer_required_date IN DATE Default NULL,
	p_oa_added_flag  IN VARCHAR2 DEFAULT 'Y',
        x_error_code     OUT NOCOPY NUMBER,
        x_error_message   OUT NOCOPY VARCHAR2)
   RETURN NUMBER;

-- Procedure to dynamically execute Validation procedure
--
 PROCEDURE Validate_Workitem(
            p_order_id     IN NUMBER
           ,p_line_item_id  IN NUMBER
           ,p_wi_instance_id IN NUMBER
           ,p_procedure_name IN VARCHAR2
           ,x_error_code OUT NOCOPY NUMBER
           ,x_error_message OUT NOCOPY VARCHAR2);



-- Start of comments
--	API name 	: Set_Order_Relationships
--	Type		: Public
--	Function	: Set Order Realtionships
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
--  The p_order_relationship argument take the
--  following enumerated Constant value:
--  XDP_TYPES.IS_PREREQUISITE_OF
--		Related order will not get executed
--		until the current order is completed.
--		If the current order is canceled, the
--		related order will also be canceled.
--  XDP_TYPES.COMES_BEFORE
--		Related order will not get executed
--		until the current order is completed
--		or the current order is canceled.
--  XDP_TYPES.COMES_AFTER
--		Current order will not get executed
--		until the related order is
--		completed or the related order is
--		canceled.
--  XDP_TYPES.IS_CHILD_OF
--		Current order is the child order of
--		the related order.
--
-- End of comments
 Procedure Set_Order_Relationships(
	p_curr_sdp_order_id in NUMBER,
	p_related_sdp_order_id IN NUMBER,
      p_order_relationship  IN BINARY_INTEGER,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2);

-- Start of comments
--	API name 	: Set_Workitem_Relationships
--	Type		: Public
--	Function	: Set Workitem Realtionships.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
--  The p_wi_relationship argument take the
--  following enumerated Constant value:
--  XDP_TYPES.MERGED_INTO
--		Related workitem is merged into the
--		current workitem.  If the current
--		workitem is completed, then the
--		related workitem is completed.
-- End of comments
 Procedure Set_Workitem_Relationships(
	p_curr_wi_instance_id in NUMBER,
	p_related_wi_instance_id IN NUMBER,
      p_wi_relationship  IN BINARY_INTEGER,
	return_code OUT NOCOPY number,
	error_description OUT NOCOPY varchar2);


-- Start of comments
--	API name 	: Get_Order_Header
--	Type		: Public
--	Function	: Get the order header information for a giving order
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
FUNCTION Get_Order_Header(p_sdp_order_id IN NUMBER)
  return XDP_TYPES.ORDER_HEADER;


-- Start of comments
--	API name 	: Get_Order_Lines
--	Type		: Public
--	Function	: Get all the line items for a given order.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
FUNCTION Get_Order_Lines( p_sdp_order_id IN NUMBER)
  return XDP_TYPES.ORDER_LINE_LIST;

-- Start of comments
--	API name 	: Get_LineRec
--	Type		: Public
--	Function	: Get the line item record
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
FUNCTION Get_LineRec( p_line_item_id IN NUMBER)
  return XDP_TYPES.LINE_ITEM;

-- Start of comments
--	API name 	: Get_WorkitemRec
--	Type		: Public
--	Function	: Get the work item record
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
FUNCTION Get_WorkitemRec( p_wi_instance_id IN NUMBER)
  return XDP_TYPES.workitem_rec ;

-- Start of comments
--	API name 	: Get_Order_Workitems
--	Type		: Public
--	Function	: Get all the work items for a given order.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
-- End of comments
FUNCTION Get_Order_Workitems( p_sdp_order_id IN NUMBER)
  return XDP_TYPES.Workitem_List;

-- Start of comments
--	API name 	: Find_Orders
--	Type		: Public
--	Function	: Find orders which meets the user defined searching criteria.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
--  Find orders which meets the user defined searching
--  criteria.  The user can use Most of the commands which are allowed
--  in the SQL where clause such as Like, = , substr,etc.., in their
--  searching criteria.  The User should use the following Macros to
--  refer to the order information:
--  $ORDER.<Order Header Record Attribute Name>$
--  $LINE.<Line item record attribute>$
--
--  For example, if the user wants to find the orders which have
--  status of 'IN PROGRESS' and contains a line item of
--  'JD_CALLERID', he/she can specify the search criteria as:
--
--  declare
--    lv_where varchar2(8000);
--    lv_list XDP_TYPES.ORDER_HEADER_LIST;
--    lv_ret number;
--    lv_str varchar2(800);
--  begin
--
--   lv_where := 'UPPER($ORDER.ORDER_STATUS$) = ''IN PROGRESS'' and '||
--      '$LINE.LINE_ITEM_NAME$ = ''JD_CALLERID''';
--
--   XDP_OA_UTIL.Find_Orders(
--     p_where => lv_where,
--     p_order_list => lv_list,
--     return_code => lv_ret,
--     error_description => lv_str);
--  END;
--
--    The user must omit the key word WHERE in the argument p_where.
--	  In additon, the user should examine the count of out variable
--	  p_order_list to see if there is any match found.
-- End of comments
PROCEDURE Find_Orders(
   p_where IN OUT NOCOPY Varchar2,
   p_order_list OUT NOCOPY XDP_TYPES.ORDER_HEADER_LIST,
   return_code  OUT NOCOPY number,
   error_description OUT NOCOPY varchar2);

-- Start of comments
--	API name 	: FIND_LINES
--	Type		: Public
--	Function	: Find line items in an order which meets the searching criteria.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
--  Find line item in a given order which meets the user defined searching
--  criteria.  The user can use most of the commands which are allowed
--  in the SQL where clause such as Like, = , substr,etc.., in their
--  searching criteria.  The User should use the following Macros to
--  refer to the order information:
--  $LINE.<Line item record attribute>$
--  $LINE_PARAM.<Line parameter name>$
--
--  For example, if the user wants to find out in order 720 if there
--  is any line item which has parameter ACTIE_FLAG of value like
--  'TES%' and parameter ENDING_NUMBER of value like 'TES%', he/she
--  can specify the search criteria as:
--
--  declare
--    lv_where varchar2(8000);
--    lv_list XDP_TYPES.ORDER_LINE_LIST;
--    lv_ret number;
--    lv_str varchar2(800);
--    lv_index number;
--  begin
--
--   lv_where := 'UPPER($LINE_PARAM.ACTIVE_FLAG$) like ''TES%'' and '||
--     'UPPER($LINE_PARAM.ENDING_NUMBER$) like ''TES%''';
--
--   XDP_OA_UTIL.Find_Lines(
--      p_sdp_order_id => 720,
--      p_where => lv_where,
--      p_order_line_list => lv_list,
--      return_code => lv_ret,
--      error_description => lv_str);
-- END;
--
--    The user must omit the key word WHERE in the argument p_where.
--	  In additon, the user should examine the count of out variable
--	  p_order_line_list to see if there is any match found.
--
-- End of comments
PROCEDURE Find_Lines(
   p_sdp_order_id IN NUMBER,
   p_where IN OUT NOCOPY Varchar2,
   p_order_line_list OUT NOCOPY XDP_TYPES.ORDER_LINE_LIST,
   return_code  OUT NOCOPY number,
   error_description OUT NOCOPY varchar2);

-- Start of comments
--	API name 	: Find_Workitems
--	Type		: Public
--	Function	: Find Work items in an order which meets the searching criteria.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
--  Find Work item in a given order which meets the user defined searching
--  criteria.  The user can use most of the commands which are allowed
--  in the SQL where clause such as Like, = , substr,etc.., in their
--  searching criteria.  The User should use the following Macros to
--  refer to the order information:
--  $WORKITEM.<Workitem record attribute>$
--  $WI_PARAM.<Workitem parameter name>$
--
--  For example if the user wants to find out if there is any workitem
--  in order 299 with workitem name of 'JD_WORKITEM', and workitem
--  parameter ENDING_NUMBER of value '5', and workitem parameter
--  MESSAGE_VERSION of value '1.0', he/she can specify the search
--  criteria as:
--
--  declare
--    lv_where varchar2(8000);
--    lv_list XDP_TYPES.WORKITEM_LIST;
--    lv_ret number;
--    lv_str varchar2(800);
--    lv_index number;
--  begin
--
--    lv_where := 'UPPER($WI_PARAM.ENDING_NUMBER$) = ''5'' and '||
--             'UPPER($WI_PARAM.MESSAGE_VERSION$) = ''1.0''' ||
--             ' and $WORKITEM.WORKITEM_NAME$ = ''JD_WORKITEM''';
--
--    XDP_OA_UTIL.Find_Workitems(
--       p_sdp_order_id => 299,
--       p_where => lv_where,
--       p_workitem_list => lv_list,
--       return_code => lv_ret,
--       error_description => lv_str);
--
--  end;
--
--  Note: The user must omit the key word WHERE in the argument p_where.
--	  In additon, the user should examine the count of out variable
--	  p_order_line_list to see if there is any match found.
--
-- End of comments
PROCEDURE Find_Workitems(
   p_sdp_order_id IN NUMBER,
   p_where IN OUT NOCOPY Varchar2,
   p_workitem_list OUT NOCOPY XDP_TYPES.Workitem_LIST,
   return_code  OUT NOCOPY number,
   error_description OUT NOCOPY varchar2);

-- Start of comments
--	API name 	: COPY_LINE
--	Type		: Public
--	Function	: Copy an existing line item to a order_line_list.
--	Pre-reqs	: None.
--
--	Version	: Current version	11.5
--	Notes	:
--  This API allows user to copy an existing line item to a
--  order_line_list. The user may choose the copy method to be either
--  APPEND_TO OR OVERRIDE.  The copy result will be returned to the user
--  in out argument p_order_line_list and p_line_parameter_list.
-- End of comments
 PROCEDURE Copy_Line(
	p_src_sdp_order_id IN 	NUMBER,
	p_src_line_item_id IN 	NUMBER,
	p_copy_mode	IN 	BINARY_INTEGER default XDP_TYPES.APPEND_TO,
	p_order_line_list  	IN OUT NOCOPY XDP_TYPES.ORDER_LINE_LIST,
	p_line_parameter_list 	IN OUT NOCOPY XDP_TYPES.LINE_PARAM_LIST,
	return_code 		OUT NOCOPY NUMBER,
	error_description 	OUT NOCOPY VARCHAR2);

--
-- Global variables declared to capture the value of Workitem Name.
--
g_Workitem_Name  VARCHAR2(200):=NULL;

END XDP_OA_UTIL;

 

/
