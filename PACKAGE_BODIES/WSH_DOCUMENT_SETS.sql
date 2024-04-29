--------------------------------------------------------
--  DDL for Package Body WSH_DOCUMENT_SETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DOCUMENT_SETS" as
/* $Header: WSHDSPRB.pls 120.9.12010000.5 2010/01/11 13:47:41 gbhargav ship $ */

-- Name
--   Print_Document_Sets
-- Purpose
--   Execute any Delivery-based Document Set by submitting each document
--   to the transaction mananger and printing each report on the pre-customized
--   printer
-- Arguments
--
--   Either the p_report_set_id and one of p_trip_ids, p_stop_ids, and
--   p_delivery_ids in parameters should be used or the
--   p_document_param_info.  The former method is primarily for the
--   Transactions form.
--
--   many - all required parameters for all the documents in the set must be
--   supplied on calling the package (hence the long list). Any parameters that are
--   not supplied will default to the default value as defined in the concurrent
--   program. HOWEVER: if all mandatory parameters are not supplied (either directly
--   to this package, or as default values in the Conc Prog Defn) then the report
--   cannot be submitted.
-- THIS DOES NOT SUPPORT
--   parameter default values (ie those defined in the Con Prg Defn) with sql
--   statements which reference other flex fields or profile values. ie for sql
--   defined default values, this only supports standard sql. (because it takes
--   the sql strings and plugs it into dynamic sql).
--   Likewise, any translation to internal values through table validated value
--   sets must contain standard sql in the where clause of the value set.
--   Unsupported sql defaults will be ignored.
-- IT DOES SUPPORT default values which are constants, profiles or simple sql.
-- Notes
-- USER DEFINED REPORTS
--   if the user defines their own reports they should restrict parameter names
--   to those used in this package. Additional they may use P_TEXT1 - P_TEXT4.

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DOCUMENT_SETS';
--
PROCEDURE Print_Document_Sets
  (p_report_set_id	    IN NUMBER,
   p_organization_id	    IN NUMBER,
   p_trip_ids		    IN WSH_UTIL_CORE.Id_Tab_Type,
   p_stop_ids		    IN WSH_UTIL_CORE.Id_Tab_Type,
   p_delivery_ids	    IN WSH_UTIL_CORE.Id_Tab_Type,
   p_document_param_info    IN WSH_DOCUMENT_SETS.DOCUMENT_SET_TAB_TYPE,
   x_return_status	    IN OUT NOCOPY  VARCHAR2)
  IS

     --
l_debug_on BOOLEAN;
     --
     l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINT_DOCUMENT_SETS';
     --

BEGIN
   --
   -- Debug Statements
   --
   --
   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   --
   IF l_debug_on IS NULL
   THEN
       l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.push(l_module_name);
       --
       WSH_DEBUG_SV.log(l_module_name,'P_REPORT_SET_ID',P_REPORT_SET_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_TRIP_IDS.COUNT',P_TRIP_IDS.COUNT);
       WSH_DEBUG_SV.log(l_module_name,'P_STOP_IDS.COUNT',P_STOP_IDS.COUNT);
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_IDS.COUNT',P_DELIVERY_IDS.COUNT);

       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.COUNT',P_DOCUMENT_PARAM_INFO.COUNT);
/*
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.report_set_id',P_DOCUMENT_PARAM_INFO.p_report_set_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.request_id',P_DOCUMENT_PARAM_INFO.p_request_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.customer_id',P_DOCUMENT_PARAM_INFO.p_customer_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.item_id',P_DOCUMENT_PARAM_INFO.p_item_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.item_cate_set_id',P_DOCUMENT_PARAM_INFO.p_item_cate_set_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.item_category_id',P_DOCUMENT_PARAM_INFO.p_item_category_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.transaction_type_id',P_DOCUMENT_PARAM_INFO.p_transaction_type_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.header_id_low',P_DOCUMENT_PARAM_INFO.p_header_id_high);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.salesrep_id',P_DOCUMENT_PARAM_INFO.p_salesrep_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.user_id',P_DOCUMENT_PARAM_INFO.p_user_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.territory_name',P_DOCUMENT_PARAM_INFO.p_territory_name);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.organization_id',P_DOCUMENT_PARAM_INFO.p_organization_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.trip_id',P_DOCUMENT_PARAM_INFO.p_trip_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.dleg_id',P_DOCUMENT_PARAM_INFO.p_delivery_leg_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.bol_num',P_DOCUMENT_PARAM_INFO.p_bill_of_lading_number);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.trip_stop_id',P_DOCUMENT_PARAM_INFO.p_trip_stop_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.delivery_id',P_DOCUMENT_PARAM_INFO.p_delivery_id);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.Order_Num_Lo',P_DOCUMENT_PARAM_INFO.p_order_num_l);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.Order_Num_Hi',P_DOCUMENT_PARAM_INFO.p_order_num_h);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.Move_Order_Num_Lo',P_DOCUMENT_PARAM_INFO.p_move_order_l);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_PARAM_INFO.Move_Order_Num_Hi',P_DOCUMENT_PARAM_INFO.p_move_order_h);
*/

       WSH_DEBUG_SV.log(l_module_name,'X_RETURN_STATUS',X_RETURN_STATUS);
   END IF;
   --
   DECLARE
      l_shipping_style VARCHAR2(15);
      l_release_name VARCHAR2(15);
      l_prod_version VARCHAR2(15);
      l_application_id NUMBER;
      l_concurrent_program_name VARCHAR(40);
      l_concurrent_program_id NUMBER;
      l_execution_method_code VARCHAR2(10);
      --l_user_concurrent_program_name  VARCHAR2(200); --Bug 1633386
      l_user_concurrent_program_name fnd_concurrent_programs_vl.user_concurrent_program_name%TYPE;

      l_arg_cnt NUMBER;
      l_request_id NUMBER;
      l_total_docs NUMBER :=0;
      l_submitted_docs NUMBER :=0;

      l_valid_params BOOLEAN := TRUE;
      l_non_default_params BOOLEAN := FALSE;
      l_error_in_a_doc BOOLEAN := FALSE;

      l_cursor NUMBER;
      l_rows NUMBER;
      l_sql_value Varchar2(32767);
      l_stmt_num NUMBER;
      l_status   Varchar2(100);
      l_error_message Varchar2(4000); -- bug 2548069 (frontported): resolve ORA-6502

      l_arg_value	      VARCHAR2(240);
      l_arg_name	      fnd_descr_flex_column_usages.end_user_column_name%type;
      l_arg_required_flag     fnd_descr_flex_column_usages.required_flag%type;
      l_arg_default_value     fnd_descr_flex_column_usages.default_value%type;
      l_arg_default_type      fnd_descr_flex_column_usages.default_type%type;
      l_arg_value_set_id      fnd_descr_flex_column_usages.flex_value_set_id%type;
      l_parameter_name        VARCHAR2(32767);

      No_Org_For_Entity	      EXCEPTION;

      l_req_id_str	      VARCHAR2(2000);
      l_buffer_fill           VARCHAR2(1):='N';

      l_main_conc_request_id NUMBER;

      --- BugFix 3274604 - Start

      cnt				NUMBER;
      l_ledger_id		NUMBER;     --LE Uptake
      x_return_status		VARCHAR2(1);
      x_msg_count			NUMBER;
      x_msg_data			VARCHAR2(255);
      p_location_id1			NUMBER;
      x_document_number		VARCHAR2(255);
      l_return_status		VARCHAR2(1);
      l_num_warning			NUMBER;
      l_num_errors			NUMBER;
      l_delivery_id			NUMBER;
      l_delivery_leg_id		NUMBER;
      l_ship_method_code		VARCHAR2(30);
      l_pickup_location_id		NUMBER;
      l_trip_name			VARCHAR2(30);
      l_bol_count			NUMBER;
      l_document_number		VARCHAR2(255);
      l_msg_count			NUMBER;
      l_msg_data			VARCHAR2(255);
      wsh_create_document_error	EXCEPTION;


      CURSOR  c_get_delivery_info(l_delivery_id IN NUMBER) IS
		  SELECT  del.delivery_id,
			  dlg.delivery_leg_id,
			  wt.ship_method_code,
			  del.initial_pickup_location_id,
			  wt.name
		  FROM    wsh_new_deliveries del,
			  wsh_delivery_legs dlg,
			  wsh_trip_stops st,
			  wsh_trips wt
		  WHERE   del.delivery_id = dlg.delivery_id
		  AND     dlg.pick_up_stop_id = st.stop_id
		  AND     st.trip_id = wt.trip_id
		  AND     del.initial_pickup_location_id = st.stop_location_id
		  AND     del.delivery_id = l_delivery_id;
      --LE Uptake
      CURSOR  c_get_ledger_id(p_delivery_id IN NUMBER) IS
		  SELECT  ood.set_of_books_id
		  FROM    org_organization_definitions ood,
			  wsh_new_deliveries del
		  WHERE   ood.organization_id = del.organization_id
		  AND     del.delivery_id = p_delivery_id;

      CURSOR m_get_ledger_id(p_delivery_id IN NUMBER) IS
		  SELECT hoi.org_information1
		  FROM   hr_organization_information hoi,
			  wsh_new_deliveries wnd
		  WHERE wnd.delivery_id = p_delivery_id
		  AND   hoi.organization_id = wnd.organization_id
		  AND   hoi.org_information_context = 'Accounting Information';

      CURSOR c_get_init_pickup_loc_id(p_delivery_id IN NUMBER) IS
		  SELECT initial_pickup_location_id
		  FROM   WSH_NEW_DELIVERIES
		  WHERE delivery_id = p_delivery_id;

      --- BugFix 3274604 - End

      TYPE arg_table IS TABLE OF VARCHAR(240) INDEX BY BINARY_INTEGER;
      l_argument arg_table;
      l_argument_name  arg_table;
      l_printer_pos  NUMBER ;

      CURSOR c_document_set(p_report_set_id NUMBER) IS
	 SELECT a.application_id,
	   a.application_short_name,
	   f.concurrent_program_id,
	   f.concurrent_program_name,
	   f.user_concurrent_program_name,
	   f.printer_name default_printer_name,
	   f.output_print_style,
	   f.save_output_flag,
	   f.print_flag,
	   f.execution_method_code ,
	   nvl( rs.number_of_copies, 0 )  number_of_copies,
           f.mls_executable_id,
	   f.output_file_type,
	   nvl(rs.template_code,f.template_code) template_code,
           f.nls_compliant
	   FROM fnd_concurrent_programs_vl f,
	   wsh_report_set_lines rs, fnd_application a
	   WHERE rs.report_set_id = p_report_set_id
	   AND   rs.concurrent_program_id = f.concurrent_program_id
	   AND   rs.application_id = f.application_id
	   AND   a.application_id = f.application_id
	   AND   f.enabled_flag = 'Y'
	   ORDER BY rs.program_sequence;

      l_doc_set_params	      wsh_document_sets.document_set_tab_type;

      CURSOR c_document_params(i NUMBER) IS
	SELECT
	  decode(
	    lower(decode(l_execution_method_code, 'P', srw_param, 'K',srw_param, end_user_column_name)),
	    --Bug 6766880 added l_execution_method_code K
	    'p_request_id',		to_char(l_doc_set_params(i).p_request_id), -- bug 1589045
	    'p_customer_id',		to_char(l_doc_set_params(i).p_customer_id),
	    'p_item_id',		to_char(l_doc_set_params(i).p_item_id),
	    'p_item_cate_set_id',	to_char(l_doc_set_params(i).p_item_cate_set_id),
	    'p_item_category_id',	to_char(l_doc_set_params(i).p_item_category_id),
	    'p_transaction_type_id',	to_char(l_doc_set_params(i).p_transaction_type_id),
	    'p_header_id_low',		to_char(l_doc_set_params(i).p_header_id_low),
	    'p_header_id_high',		to_char(l_doc_set_params(i).p_header_id_high),
	    'p_salesrep_id',		to_char(l_doc_set_params(i).p_salesrep_id),
	    'p_user_id',		to_char(l_doc_set_params(i).p_user_id),
	    'p_territory_name',		l_doc_set_params(i).p_territory_name,
	    'p_item_display',		l_doc_set_params(i).p_item_display,
	    'p_item_flex_code',		l_doc_set_params(i).p_item_flex_code,
	    'p_organization_id',	to_char(l_doc_set_params(i).p_organization_id),
	    'p_org_id',	to_char(l_doc_set_params(i).p_organization_id),
	    'p_sort_by',		to_char(l_doc_set_params(i).p_sort_by),
	    'p_show_functional_currency',	l_doc_set_params(i).p_show_functional_currency,
	    'p_ledger_id',	to_char(l_doc_set_params(i).p_ledger_id),  -- LE Uptake
	    'p_order_date_low',		to_char(l_doc_set_params(i).p_order_date_low),
	    'p_order_date_high',	to_char(l_doc_set_params(i).p_order_date_high),
	    'p_delivery_date_low',	to_char(l_doc_set_params(i).p_delivery_date_low),
	    'p_delivery_date_high',	to_char(l_doc_set_params(i).p_delivery_date_high),
	    'p_freight_code',		l_doc_set_params(i).p_freight_code,
	    'p_delivery_id',		to_char(l_doc_set_params(i).p_delivery_id),
	    'p_delivery_id_high',		to_char(l_doc_set_params(i).p_delivery_id_high),
	    'p_delivery_id_low',		to_char(l_doc_set_params(i).p_delivery_id_low),
	    'p_trip_id',		to_char(l_doc_set_params(i).p_trip_id),
	    'p_trip_id_high',		to_char(l_doc_set_params(i).p_trip_id_high),
	    'p_trip_id_low',		to_char(l_doc_set_params(i).p_trip_id_low),
--	    'p_delivery_leg_id',	to_char(l_doc_set_params(i).p_delivery_leg_id),
	    'p_bill_of_lading_number',	to_char(l_doc_set_params(i).p_bill_of_lading_number),
	    'p_trip_stop_id',		to_char(l_doc_set_params(i).p_trip_stop_id),
	    'p_departure_date_low',	to_char(l_doc_set_params(i).p_departure_date_low),
	    'p_departure_date_high',	to_char(l_doc_set_params(i).p_departure_date_high),
	    'p_container_id',		to_char(l_doc_set_params(i).p_container_id),
	    'p_print_cust_item',	l_doc_set_params(i).p_print_cust_item,
	    'p_print_mode',		l_doc_set_params(i).p_print_mode,
	    'p_print_all',		l_doc_set_params(i).p_print_all,
	    'p_sort',			l_doc_set_params(i).p_sort,
	    'p_delivery_date_lo',	to_char(l_doc_set_params(i).p_delivery_date_lo),
	    'p_delivery_date_hi',	to_char(l_doc_set_params(i).p_delivery_date_hi),
	    'p_freight_carrier',	l_doc_set_params(i).p_freight_carrier,
	    'p_quantity_precision',	l_doc_set_params(i).p_quantity_precision,
	    'p_locator_flex_code',	l_doc_set_params(i).p_locator_flex_code,
	    'p_warehouse_id',		to_char(l_doc_set_params(i).p_warehouse_id),
	    'p_pick_slip_num_low',	to_char(l_doc_set_params(i).pick_slip_num_l),
	    'p_pick_slip_num_high',	to_char(l_doc_set_params(i).pick_slip_num_h),
            'p_order_type_id',          to_char(l_doc_set_params(i).p_order_type_id), --Bugfix 3604021
	    'p_order_num_l',		to_char(l_doc_set_params(i).p_order_num_l),
	    'p_order_num_h',		to_char(l_doc_set_params(i).p_order_num_h),
	    'p_order_num_low',		to_char(l_doc_set_params(i).p_order_num_low),
	    'p_order_num_high',		to_char(l_doc_set_params(i).p_order_num_high),
	    --Bug#1577520
	    --'p_move_order_low',		to_char(l_doc_set_params(i).p_move_order_l),
	    --'p_move_order_high',		to_char(l_doc_set_params(i).p_move_order_h),
	    'p_move_order_low',		l_doc_set_params(i).p_move_order_l,
	    'p_move_order_high',		l_doc_set_params(i).p_move_order_h,
	    'p_ship_method_code',	l_doc_set_params(i).p_ship_method_code,
	    'p_customer_name',		l_doc_set_params(i).p_customer_name,
	    'p_pick_status',		l_doc_set_params(i).p_pick_status,
	    'p_detail_date_low',		to_char(l_doc_set_params(i).p_detail_date_l),
	    'p_detail_date_high',		to_char(l_doc_set_params(i).p_detail_date_h),
	    'p_exception_name',		l_doc_set_params(i).p_exception_name,
	    'p_logging_entity',		l_doc_set_params(i).p_logging_entity,
	    'p_location_id',		to_char(l_doc_set_params(i).p_location_id),
	    'p_creation_date_from',	to_char(l_doc_set_params(i).p_creation_date_from),
	    'p_creation_date_to',	to_char(l_doc_set_params(i).p_creation_date_to),
	    'p_last_update_date_from',	to_char(l_doc_set_params(i).p_last_update_date_from),
	    'p_last_update_date_to',	to_char(l_doc_set_params(i).p_last_update_date_to),
	    'p_severity',		l_doc_set_params(i).p_severity,
	    'p_status',			l_doc_set_params(i).p_status,
	    'p_text1',			l_doc_set_params(i).p_text1,
	    'p_text2',			l_doc_set_params(i).p_text2,
	    'p_text3',			l_doc_set_params(i).p_text3,
	    'p_text4',			l_doc_set_params(i).p_text4,
	    'p_currency_code',		l_doc_set_params(i).p_currency_code,
	    'p_printer_name',		l_doc_set_params(i).p_printer_name,
	    'UNSUPPORTED')
	  arg_value,
	  end_user_column_name,
	  required_flag,
	  default_value,
	  default_type,
	  flex_value_set_id,
	  lower(decode(l_execution_method_code, 'P', srw_param,'K',srw_param, end_user_column_name)) parameter_name
	  --Bug 6766880 added l_execution_method_code K
	FROM
	  fnd_descr_flex_column_usages
	WHERE application_id = l_application_id
	  AND descriptive_flexfield_name = '$SRS$.'||l_concurrent_program_name
	  AND enabled_flag = 'Y'
	ORDER BY
	  column_seq_num;

      CURSOR c_value_set_cursor(p_value_set_id IN NUMBER)
	IS
	   SELECT
	     'select ' || id_column_name ||
	     ' from ' || application_table_name,
	     additional_where_clause,
	     ' and ' || value_column_name || '=:value' ||
	     ' and ' || enabled_column_name || '=''Y''' ||
	     ' and nvl(' || start_date_column_name || ',sysdate)<=sysdate' ||
	     ' and nvl(' || end_date_column_name || ',sysdate)>=sysdate'
	     FROM fnd_flex_validation_tables
	     WHERE flex_value_set_id = p_value_set_id
	     AND id_column_name IS NOT NULL;


 	CURSOR c_stop_trip_id_cursor (t_stop_id NUMBER )
 	 IS
 	 	select distinct trip_id from wsh_trip_stops
 	 	where stop_id=t_stop_id;
       -- bug 1633386

      l_select_clause VARCHAR2(250);
      l_where_clause  VARCHAR2(2000);
      l_additional_clause VARCHAR2(250);
      l_value_set_lookup VARCHAR2(2000);

      l_printer_setup  BOOLEAN;
      l_printer_name   VARCHAR2(32767);
      l_organization_id    number ;  -- Bug 3534965(3510460 Frontport)
      l_save_output    BOOLEAN;
      l_printer_level  NUMBER;

      CURSOR c_report_level(p_concurrent_program_id NUMBER, p_application_id NUMBER)
	IS
	   SELECT MAX(level_type_id)
	     FROM wsh_report_printers
	     WHERE concurrent_program_id = p_concurrent_program_id
	     AND application_id = p_application_id
	     AND level_value_id =
	     Decode(level_type_id,
		    10001, 0,
		    10002, fnd_global.resp_appl_id,
		    10003, fnd_global.resp_id,
		    10004, fnd_global.user_id)
	     AND enabled_flag = 'Y';

      CURSOR c_report_printer
	(p_concurrent_program_id NUMBER,
	 p_application_id NUMBER,
	 p_printer_level NUMBER)
	IS
	   SELECT Nvl(l_printer_name, 'No Printer')
	     FROM  wsh_report_printers
	     WHERE concurrent_program_id = p_concurrent_program_id
	     AND application_id = p_application_id
	     AND level_type_id = p_printer_level
	     AND level_value_id =
	     Decode(p_printer_level,
		    10001, 0,
		    10002, fnd_global.resp_appl_id,
		    10003, fnd_global.resp_id,
		    10004, fnd_global.user_id)
	     AND enabled_flag = 'Y';

      no_reportset_to_process EXCEPTION;

      entity_count	      number		    := 0;
      entity_type	      varchar2(20);
      entity_name	      varchar2(100);

      CURSOR Get_Del_Org (v_del_id NUMBER) IS
      SELECT organization_id
      FROM WSH_NEW_DELIVERIES
      WHERE delivery_id = v_del_id;

	 l_copies NUMBER := 0;

	 --bug 1633386

	 l_stop_trip_id_tmp NUMBER :=0;
	 l_delv_trip_id_tmp NUMBER :=0;

	 --bug 1633386

       l_lang_doc_params_info    WSH_DOCUMENT_SETS.document_set_rec_type;
       l_nls_lang                WSH_EXTREPS_MLS_LANG.lang_tab_type;
       l_submitted               BOOLEAN;
       l_nls_count               NUMBER;

       l_template_code	         VARCHAR2(80);
       l_appl_short_name	 VARCHAR2(50);
       l_output_file_type        VARCHAR2(4);
       l_language		 VARCHAR2(2);
       l_territory		 VARCHAR2(2);
       l_ret_status		 BOOLEAN;
       l_print_pdf		 VARCHAR2(1);


    BEGIN

       if (p_trip_ids.count <> 0) then
          entity_count			      := p_trip_ids.count;
          entity_type			      := 'Trip';
       elsif (p_stop_ids.count <> 0) then
          entity_count			      := p_stop_ids.count;
          entity_type			      := 'Stop';
       elsif (p_delivery_ids.count <> 0) then
          entity_count			      := p_delivery_ids.count;
          entity_type			      := 'Delivery';

          --  Fix for Bug:2283001
          l_doc_set_params		      := p_document_param_info;
       else
          l_doc_set_params		      := p_document_param_info;

 	  IF l_doc_set_params(1).p_organization_id IS NULL THEN

             IF p_organization_id IS NULL THEN
                RAISE No_Org_For_Entity;
             ELSE
                l_doc_set_params(1).p_organization_id := p_organization_id;
                l_doc_set_params(1).p_warehouse_id := l_doc_set_params(1).p_organization_id;
             END IF;
          END IF;

          IF l_doc_set_params(1).p_report_set_id IS NULL THEN
             IF p_report_set_id IS NULL THEN
                RAISE No_Reportset_TO_Process;
             ELSE
                l_doc_set_params(1).p_report_set_id := p_report_set_id;
             END IF;
          END IF;

       end if;

       -- bug 1589045
       l_main_conc_request_id  := FND_GLOBAL.CONC_REQUEST_ID;
       if l_main_conc_request_id = -1 then
          l_main_conc_request_id := null;
       end if;

       IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'entity_count is ' || entity_count );
       END IF;
            --
       if (entity_count > 0) then   --{ populate l_doc_set_params with entity information

          for i in 1..entity_count loop

             l_doc_set_params(i).p_report_set_id	  := p_report_set_id;

             if (p_trip_ids.count <> 0) then  -- { populate current entity's info
                l_doc_set_params(i).p_trip_id	   := p_trip_ids(i);
                l_doc_set_params(i).p_trip_id_high := p_trip_ids(i);
                l_doc_set_params(i).p_trip_id_low  := p_trip_ids(i);

                -- setting org to dummy value because the report should be
                -- org independant for trips and stops.

                l_doc_set_params(i).p_warehouse_id := -1;
                l_doc_set_params(i).p_organization_id := -1;


             elsif (p_stop_ids.count <> 0) then

                l_doc_set_params(i).p_trip_stop_id  := p_stop_ids(i);

                -- setting org to dummy value because the report should be
                -- org independent for trips and stops.

                l_doc_set_params(i).p_warehouse_id := -1;
                l_doc_set_params(i).p_organization_id := -1;

             else

                l_doc_set_params(i).p_delivery_id	  := p_delivery_ids(i);
                l_doc_set_params(i).p_delivery_id_high := p_delivery_ids(i);
                l_doc_set_params(i).p_delivery_id_low  := p_delivery_ids(i);

                OPEN Get_Del_Org (p_delivery_ids(i));

                FETCH Get_Del_Org INTO l_doc_set_params(i).p_organization_id;

                IF Get_Del_Org%NOTFOUND THEN
                   CLOSE Get_Del_Org;
                   RAISE No_Org_For_Entity;
                END IF;

                l_doc_set_params(i).p_warehouse_id := l_doc_set_params(i).p_organization_id;

                IF Get_Del_Org%ISOPEN THEN
                   CLOSE Get_Del_Org;
                END IF;

             end if;  --{ populate current entity's info

          end loop;
       end if;   --{ finished populating l_doc_set_params with entity information

       IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'doc set param counts is ' || l_doc_set_params.COUNT);
       END IF;
            --
       FOR i IN 1..l_doc_set_params.COUNT LOOP

         -- bug 1589045
         l_doc_set_params(i).p_request_id  := l_main_conc_request_id;

         if (p_trip_ids.count <> 0) then
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            entity_name			:= WSH_TRIPS_PVT.Get_Name(p_trip_ids(i));
         elsif (p_stop_ids.count <> 0) then
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            entity_name			:= WSH_TRIP_STOPS_PVT.Get_Name(p_stop_ids(i));

	    --bug 1633386
            OPEN c_stop_trip_id_cursor( p_stop_ids(i));
            LOOP
               FETCH c_stop_trip_id_cursor INTO l_stop_trip_id_tmp;
               EXIT WHEN c_stop_trip_id_cursor%NOTFOUND ;
               l_doc_set_params(i).p_trip_id :=  l_stop_trip_id_tmp;
            END LOOP;
            CLOSE   c_stop_trip_id_cursor;

         elsif (p_delivery_ids.count <> 0) then
            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.GET_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            --
            entity_name			:= WSH_NEW_DELIVERIES_PVT.Get_Name(p_delivery_ids(i));

         else
            entity_name			:= 'LINE ';
         end if;

         IF l_doc_set_params(i).p_report_set_id IS NULL THEN
            RAISE no_reportset_to_process;
         END IF;


         FOR document IN c_document_set(l_doc_set_params(i).p_report_set_id) LOOP

            -- Bug 3320252 : initialize l_printer_name everytime in this loop. -- jckwok
            l_printer_name := l_doc_set_params(i).p_printer_name ; -- Choose Printer project
	    l_organization_id :=  l_doc_set_params(i).p_organization_id  ;  -- Bug 3534965(3510460 Frontport)

            l_total_docs := l_total_docs + 1;

            l_user_concurrent_program_name := document.user_concurrent_program_name; --Bug 1633386
            l_concurrent_program_name := document.concurrent_program_name;
            l_application_id          := document.application_id;
            l_execution_method_code   := document.execution_method_code;
	    l_template_code	      := document.template_code;
	    l_appl_short_name	      := document.application_short_name;
	    l_output_file_type        := document.output_file_type;
	    l_concurrent_program_id   := document.concurrent_program_id;




	    if (  document.number_of_copies  = 0 ) then
               --Bug 8870657 : Modifying the nvl condition such that when the profile value for number of copies  is NULL, it would be treated as 0
	       l_copies := to_number(NVL(FND_PROFILE.VALUE('CONC_COPIES'),'0')) ;
            else
	       l_copies := document.number_of_copies ;
            end if ;

            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'Report Set Id is :'||l_doc_set_params(i).p_report_set_id  );
                WSH_DEBUG_SV.logmsg(l_module_name,  'CONC PROGRAM  IS :'||l_concurrent_program_name  );
                WSH_DEBUG_SV.logmsg(l_module_name,  'NUMBER OF COPIES for current doc :'||L_COPIES  );
                WSH_DEBUG_SV.logmsg(l_module_name,  'NUMBER OF COPIES from fnd profile :'|| to_number(NVL(FND_PROFILE.VALUE('CONC_COPIES'),'0'))  );
            END IF;

            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'NUMBER OF COPIES TO BE PRINTED FOR EACH REPORT '||L_COPIES  );
            END IF;
            --

            --
            -- Debug Statements
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,  'PROCESSING DOCUMENT ' || L_CONCURRENT_PROGRAM_NAME  );
            END IF;
            --

            -- Assigning current doc set params to language parameters
            l_lang_doc_params_info := l_doc_set_params(i);

            l_arg_cnt := 0;
            l_valid_params := TRUE;
            l_non_default_params := FALSE;

            OPEN c_document_params(i);

            LOOP

               FETCH c_document_params INTO
		   l_arg_value,
		   l_arg_name,
		   l_arg_required_flag,
		   l_arg_default_value,
		   l_arg_default_type,
		   l_arg_value_set_id,
		   l_parameter_name;

               EXIT WHEN (c_document_params%notfound) OR (NOT l_valid_params);

               l_arg_cnt := l_arg_cnt + 1;

             --Bug 6137146 added condition for Shipping Exception Repor
	     --Bug 8800213  added condition for WSHRDXCP_XML
             IF l_concurrent_program_name IN ('WSHRDXCP','WSHRDXCP_XML') AND L_ARG_NAME = 'Request Id'
                                              AND l_doc_set_params(i).p_request_id IS NULL
                 --Bug:8675825 :Modified the following condition such that Request_id will be set to -99
                 --             only if the report is submitted as part of pick release(online).
                                              AND l_doc_set_params(i).p_move_order_l IS NOT NULL
                                              AND l_doc_set_params(i).p_move_order_h IS NOT NULL THEN
                  L_ARG_VALUE := -99 ;
             END IF ;

               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,  'ARGUMENT NAME ' || L_ARG_NAME  );
               END IF;
               --
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,  'ARGUMENT VALUE ' || L_ARG_VALUE  );
               END IF;
               --
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,  'ARGUMENT REQUIRED ' || L_ARG_REQUIRED_FLAG  );
               END IF;
               --

	       l_argument_name ( l_arg_cnt ) := l_arg_name ;

               IF l_arg_value <> 'UNSUPPORTED' THEN
                  l_argument(l_arg_cnt) := l_arg_value;
               ELSE
                  l_argument(l_arg_cnt) := NULL;
               END IF;
               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,  'ARGUMENT NAME ' || L_ARG_NAME||' VALUE:'||TO_CHAR ( L_ARG_CNT ) ||':'||L_ARGUMENT ( L_ARG_CNT )  );
               END IF;
               --

               IF l_argument(l_arg_cnt) IS NULL THEN
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,  'ARG DEFAULT TYPE ' || L_ARG_DEFAULT_TYPE  );
                  END IF;
                  --
                  IF l_arg_default_type = 'C' THEN    -- Constant
                     l_argument(l_arg_cnt) := l_arg_default_value;
                  ELSIF l_arg_default_type = 'P' THEN  -- Profile
                     l_argument(l_arg_cnt) := fnd_profile.value(l_arg_default_value);
                  ELSIF l_arg_default_type = 'S' THEN   -- Sql
                     -- use dynamic sql to get the default value.
                     -- NOTE not all values will be defined if this references another
                     -- flex field, this will cause an error in which case continue
                     BEGIN
                        BEGIN
                           l_cursor := dbms_sql.open_cursor;
                           dbms_sql.parse(l_cursor, l_arg_default_value, dbms_sql.v7);
                           dbms_sql.define_column(l_cursor, 1, l_sql_value, 100 );
                           l_rows := dbms_sql.execute(l_cursor);
                           l_rows := dbms_sql.fetch_rows(l_cursor);
                           dbms_sql.column_value(l_cursor, 1, l_sql_value);
                           IF dbms_sql.is_open(l_cursor) THEN
                              dbms_sql.close_cursor(l_cursor);
                           END IF;

                           l_argument(l_arg_cnt) := l_sql_value;
                        END;

                        EXCEPTION
                           WHEN OTHERS THEN
                              --NULL;
                              -- Bug 3596524
                              IF dbms_sql.is_open(l_cursor) THEN
                                 dbms_sql.close_cursor(l_cursor);
                              END IF;
                     END;
                  END IF;

                  -- we now have the default value. If this is validated against a table value set
                  -- which select an id_column, then we must convert the user-friendly default
                  -- value to its internal value using the value set.
                  IF l_argument(l_arg_cnt) IS NOT NULL THEN

                     OPEN c_value_set_cursor(l_arg_value_set_id);
                     FETCH c_value_set_cursor INTO l_select_clause, l_where_clause, l_additional_clause;
                        IF (c_value_set_cursor%found) THEN
                           IF Substr(Upper(l_where_clause), 1, 5) = 'WHERE' THEN
                              l_where_clause :=  ' and ' || Substr(l_where_clause, 6);
                           END IF;

                           -- always put where clause at end as it may include an ORDER_BY clause
                           l_value_set_lookup :=
                           l_select_clause || ' where 1=1 ' || l_additional_clause
                           || ' ' || l_where_clause;

                           BEGIN
                              l_cursor := dbms_sql.open_cursor;
                              dbms_sql.parse(l_cursor, l_value_set_lookup, dbms_sql.v7);
                              dbms_sql.bind_variable(l_cursor, ':value', l_argument(l_arg_cnt));
                              dbms_sql.define_column(l_cursor, 1, l_sql_value, 255 );
                              l_rows := dbms_sql.execute(l_cursor);
                              l_rows := dbms_sql.fetch_rows(l_cursor);
                              dbms_sql.column_value(l_cursor, 1, l_sql_value);

                           EXCEPTION
                              WHEN OTHERS THEN
                                 l_sql_value := NULL;
                           END;

                           IF dbms_sql.is_open(l_cursor) THEN
                              dbms_sql.close_cursor(l_cursor);
                           END IF;

                           IF l_sql_value IS NOT NULL THEN
                              l_argument(l_arg_cnt) := l_sql_value;
                           END IF;

                        END IF;

                     CLOSE c_value_set_cursor;
                  END IF;
               ELSE -- if argument value is not null,
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,  'L_PARAMETER_NAME:' || L_PARAMETER_NAME  );
                  END IF;
                  --
                  IF l_parameter_name NOT IN
				    (
				      'p_organization_id',
				      'p_org_id',
				      'p_warehouse_id'
				    )
                  THEN
                     l_non_default_params := TRUE;
                  END IF;
               END IF;

               --
               -- Debug Statements
               --
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,  ' CHECK ARG NAME ' || L_ARG_NAME||' VALUE:'||TO_CHAR ( L_ARG_CNT ) ||':'||L_ARGUMENT ( L_ARG_CNT )  );
               END IF;
               --
               -- if still null and its required then raise appropriate error
               IF (l_argument(l_arg_cnt) IS NULL) AND l_arg_required_flag = 'Y' THEN
                  IF l_arg_value = 'UNSUPPORTED' THEN
                     x_return_status := fnd_api.g_ret_sts_error;
                     fnd_message.set_name('WSH', 'WSH_UNSUPPORTED_ARG');
                     -- bug 2389744
                     fnd_message.set_token('DOCUMENT',l_user_concurrent_program_name);
                     fnd_message.set_token('ARGUMENT',l_arg_name);
                     -- bug 2389744
                     wsh_util_core.add_message(x_return_status);

                  ELSE
                     x_return_status := fnd_api.g_ret_sts_error;
                     fnd_message.set_name('WSH', 'WSH_NULL_ARG_IN_DOC');
                     --bug 1633386
                     fnd_message.set_token('ARGUMENT',l_arg_name);
                     fnd_message.set_token('DOCUMENT',l_user_concurrent_program_name);
                     --bug 1633386
                     wsh_util_core.add_message(x_return_status);

                  END IF;
                     -- set error_flags to stop processing this document
                     l_valid_params := FALSE;
                     l_error_in_a_doc := TRUE;
                     wsh_util_core.PrintMsg('The document ' || l_concurrent_program_name || ' cannot be generated' ||
                                            ' because argument ' || l_arg_name || ' is not supported or has null value');
               END IF;

               IF l_parameter_name IN
				    (
				      'p_organization_id',
				      'p_org_id'
				    )
		      AND l_argument(l_arg_cnt) = -1
               THEN
                  l_argument(l_arg_cnt) := NULL;
               END IF;

            END LOOP; -- c_document_params loop
            CLOSE c_document_params;

            if ( l_valid_params ) then
                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,  'L_VALID_PARAMS IS TRUE'  );
                 END IF;
                 --
            else
                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,  'L_VALID_PARAMS IS FALSE'  );
                 END IF;
                 --
            end if;

            IF l_valid_params
            THEN
               --
               -- If not a single parameter was specified explicitly
               -- or in other words, if all parameters were defaulted
               -- do not submit the document
               --
              if ( l_non_default_params ) then
                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,  'L_NON_DEFAULT_PARAMS IS TRUE'  );
                 END IF;
                 --
              else
                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,  'L_NON_DEFAULT_PARAMS IS FALSE'  );
                 END IF;
                 --
              end if;
               IF NOT(l_non_default_params)
               THEN
                  --
                  -- Debug Statements
                  --
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,  'THE DOCUMENT ' || L_CONCURRENT_PROGRAM_NAME || ' DOES NOT HAVE A PARAM SPECIFIED.'  );
                  END IF;
                  --
                  l_valid_params := FALSE;
                  x_return_status := wsh_util_core.g_ret_sts_warning;
                  fnd_message.set_name('WSH', 'WSH_NO_CRITERIA_FOR_DOC');
                  fnd_message.set_token('DOCUMENT_NAME',l_user_concurrent_program_name);
                  wsh_util_core.add_message(x_return_status);
              END IF;
           END IF;

           IF l_valid_params THEN --{
              -- As per Concurrent Processing reqts, the first unused argument (if < 30)
              -- should be set as chr(0) and remaining as null when submitting PL/SQL programs
              -- as part of Document Sets
              IF l_arg_cnt < 30 THEN
                 l_arg_cnt := l_arg_cnt + 1;
                 l_argument(l_arg_cnt) := chr(0);
              END IF;
              -- loop through the rest of the arguments (upto 30) setting any
              -- remaining ones to null for unassigned.
              WHILE l_arg_cnt < 30 LOOP
                 l_arg_cnt := l_arg_cnt + 1;
                 l_argument(l_arg_cnt) := '';
              END LOOP;

              -- set up the printer

              --
              -- Debug Statements
              --
              IF l_debug_on THEN --{
                  WSH_DEBUG_SV.logmsg(l_module_name,  'THE DOCUMENT ' || L_CONCURRENT_PROGRAM_NAME || ' HAVE A PARAM SPECIFIED.'  );
              END IF; --}
              --

              IF document.print_flag = 'Y' THEN  --{

                                       --
                                       -- Debug Statements
                                       --
                                       IF l_debug_on THEN --{
                                           WSH_DEBUG_SV.logmsg(l_module_name,  'APPLICATION ID: ' || TO_CHAR ( l_application_id ) || ' RESPONSIBILITY ID: ' || TO_CHAR ( FND_GLOBAL.RESP_ID ) || ' USER ID: ' || TO_CHAR ( FND_GLOBAL.USER_ID )  );
                                       END IF; --}
                                       --

                 if ( l_printer_name IS NULL  or l_printer_name = '-1' ) then --{
                    --
                    -- Debug Statements
                    --
                    IF l_debug_on THEN --{
                        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_REPORT_PRINTERS_PVT.GET_PRINTER',WSH_DEBUG_SV.C_PROC_LEVEL);
                    END IF; --}
                    --
                    WSH_REPORT_PRINTERS_PVT.Get_Printer(p_concurrent_program_id => document.concurrent_program_id,
									    p_organization_id       => l_organization_id ,  -- Bug 3534965(3510460 Frontport)
									    p_equipment_type_id     => null,
									    p_equipment_instance    => null,
									    p_user_id               => fnd_global.user_id,
									    p_zone                  => null,
									    p_department_id         => null,
									    p_responsibility_id     => fnd_global.resp_id,
									    p_application_id        => l_application_id ,
									    p_site_id               => 0,
									    x_printer               => l_printer_name,
									    x_api_status            => l_status,
									    x_error_message         => l_error_message);


                     IF l_error_message IS NOT NULL THEN --{
                       IF l_debug_on THEN
                             WSH_DEBUG_SV.logmsg(l_module_name, 'GET_PRINTER: ' || l_error_message);
                       END IF;
                     END IF; --}

                     IF l_printer_name IS NULL OR l_printer_name = 'No Printer' THEN --{
                        l_printer_name := document.default_printer_name;
                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN --{
                            WSH_DEBUG_SV.logmsg(l_module_name,  'PRINTER NAME IS NULL AND THE DEFAULT PRINTER IS '||L_PRINTER_NAME  );
                        END IF; --}
                        --
                     END IF; --}


                     IF document.save_output_flag = 'Y' THEN --{
                        l_save_output := TRUE;
                     ELSE
                        l_save_output := FALSE;
                     END IF; --}

                 END IF ; --} if l_printer_name is null

	         IF ( document.CONCURRENT_PROGRAM_NAME <> 'WSHRDPIK'  or WSH_INV_INTEGRATION_GRP.G_PRINTERTAB.count = 0 ) then --{
                    IF l_debug_on THEN --{
                        WSH_DEBUG_SV.logmsg(l_module_name,  DOCUMENT.CONCURRENT_PROGRAM_NAME || ' and no printers setup ' );
                    END IF; --}
                        --
                        IF l_debug_on THEN --{
                            WSH_DEBUG_SV.logmsg(l_module_name,  l_copies || ' copies  of ' || DOCUMENT.CONCURRENT_PROGRAM_NAME||' WILL BE PRINTED ON PRINTER '||L_PRINTER_NAME  );
                        END IF; --}
                        --
                        l_printer_setup :=
			    fnd_request.set_print_options
			    (l_printer_name, -- This could be null here.
			     document.output_print_style,
			     l_copies,
			     l_save_output,
			     'N');
		       if ( NOT l_printer_setup and l_debug_on ) then  --{
			    WSH_DEBUG_SV.logmsg(l_module_name,  ' Set_Print_Options Returned False !!!!');
                       end if ; --}
		 END IF ; --}
               END IF; --} If document.print_flag = 'Y'

               -- go ahead and submit this document as a request


	       IF ( document.CONCURRENT_PROGRAM_NAME <> 'WSHRDPIK'  or WSH_INV_INTEGRATION_GRP.G_PRINTERTAB.count = 0 ) then  --{

                  -- Getting language if document has MLS function associated with it
                  IF document.mls_executable_id IS NOT NULL THEN
                     l_nls_lang.delete;
                     IF l_debug_on THEN --{
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_EXTREPS_MLS_LANG.Get_NLS_Lang ' );
                     END IF; --}
                     WSH_EXTREPS_MLS_LANG.Get_NLS_Lang (
                                                          p_prog_name      => document.concurrent_program_name,
                                                          p_doc_param_info => l_lang_doc_params_info,
                                                          p_nls_comp       => document.nls_compliant,
                                                          x_nls_lang       => l_nls_lang,
                                                          x_return_status  => x_return_status
                                                       );
                     IF x_return_status IN ( fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_unexp_error ) THEN
                        IF l_debug_on THEN --{
                           WSH_DEBUG_SV.logmsg(l_module_name, 'Error returning from Get_NLS_Lang :'||x_return_status );
                        END IF; --}
                        wsh_util_core.add_message(x_return_status);
                     END IF;
                     IF l_debug_on THEN --{
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Number of NLS languages :'||l_nls_lang.COUNT );
                     END IF; --}
                  END IF;

                  l_submitted := FALSE;
                  l_nls_count := 1;

                  WHILE NOT (l_submitted)
                  LOOP
                    IF l_nls_lang.COUNT <> 0 THEN
                       IF l_nls_count <= l_nls_lang.COUNT THEN
                          /* set the language and territory for this request
                             all individual requests are protected against updates */
                          IF l_debug_on THEN --{
                             WSH_DEBUG_SV.logmsg(l_module_name, 'Setting option for language : '||l_nls_lang(l_nls_count).nls_language);
                          END IF; --}
                          if ( not fnd_request.set_options(
                                                              implicit => 'NO',
                                                              protected => 'YES',
                                                              language  => l_nls_lang(l_nls_count).nls_language,
                                                              territory => l_nls_lang(l_nls_count).nls_territory)) then
                               IF l_debug_on THEN --{
                                  WSH_DEBUG_SV.logmsg(l_module_name, 'fnd_request.set_options returned false');
                               END IF; --}
                               wsh_util_core.add_message(x_return_status);
                               raise no_data_found ;
                          end if;
                       ELSE
                          -- Exit loop since all nls requests are submitted
                          EXIT;
                       END IF;
                    ELSE
                       l_submitted := TRUE;
                    END IF;

	  --- BugFix 3274604 - Start
          --  Following code is added to make sure that packing slip, BOL amd MBOL
	  --  document number are generated before submitting request

		  IF document.concurrent_program_name = 'WSHRDMBL' THEN
		     IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name, 'p_trip_id for Master BOL = ' ||l_argument(1));
		     END IF;
			WSH_MBOLS_PVT.Generate_MBOL(
				     p_trip_id          => l_argument(1),
		  		     x_sequence_number  => l_document_number,
				     x_return_status    => l_return_status );

			WSH_UTIL_CORE.api_post_call(
				     p_return_status    => l_return_status,
		                     x_num_warnings     => l_num_warning,
				     x_num_errors       => l_num_errors,
				     p_raise_error_flag => FALSE );

		  --Bug 3685366 : Added conditon to check bol_error_flag.
		  ELSIF document.concurrent_program_name = 'WSHRDBOL'
                        AND ( nvl(l_doc_set_params(i).bol_error_flag,'N') = 'N') THEN

		       IF l_argument(6) is not null THEN
			  IF l_debug_on THEN
			     WSH_DEBUG_SV.logmsg(l_module_name, 'p_trip_id for BOL = ' ||l_argument(6));
			  END IF;
  			    WSH_MBOLS_PVT.Generate_BOLs(
				     p_trip_id          => l_argument(6),
				     x_return_status    => l_return_status );

			    WSH_UTIL_CORE.api_post_call(
				     p_return_status    => l_return_status,
		                     x_num_warnings     => l_num_warning,
				     x_num_errors       => l_num_errors,
				     p_raise_error_flag => FALSE );
                       ELSIF l_argument(5) is not null THEN

			  OPEN c_get_delivery_info(l_argument(5));
			  LOOP
			    FETCH c_get_delivery_info INTO l_delivery_id,
							   l_delivery_leg_id,
							   l_ship_method_code,
							   l_pickup_location_id,
							   l_trip_name;
			    IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name, 'l_delivery_id for BOL = ' ||l_delivery_id);
				WSH_DEBUG_SV.logmsg(l_module_name, 'l_delivery_leg_id for BOL = ' ||l_delivery_leg_id);
				WSH_DEBUG_SV.logmsg(l_module_name, 'l_ship_method_code for BOL = ' ||l_ship_method_code);
				WSH_DEBUG_SV.logmsg(l_module_name, 'l_pickup_location_id for BOL = ' ||l_pickup_location_id);
				WSH_DEBUG_SV.logmsg(l_module_name, 'l_trip_name for BOL = ' ||l_trip_name);
			    END IF;
			    EXIT WHEN c_get_delivery_info%NOTFOUND;

			    SELECT count(*)
			    INTO   l_bol_count
			    FROM   wsh_document_instances
			    WHERE  entity_name = 'WSH_DELIVERY_LEGS'
			    AND    entity_id   = l_delivery_leg_id
			    AND    status     <> 'CANCELLED';

			    IF l_bol_count = 0 THEN

			      IF l_ship_method_code IS NULL THEN
				FND_MESSAGE.SET_NAME('WSH','WSH_BOL_NULL_SHIP_METHOD_ERROR');
				FND_MESSAGE.SET_TOKEN('TRIP_NAME', l_trip_name);
				x_return_status := wsh_util_core.g_ret_sts_error;
				wsh_util_core.add_message(x_return_status);
				IF l_debug_on THEN
					WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status for BOL = '||x_return_status);
				END IF;
				IF c_get_delivery_info%ISOPEN THEN
				   CLOSE c_get_delivery_info;
				END IF;
				RAISE wsh_create_document_error;
			      END IF;
                -- LE Uptake
			      OPEN c_get_ledger_id(l_delivery_id);
			      FETCH c_get_ledger_id INTO l_ledger_id;
			      IF c_get_ledger_id%NOTFOUND THEN
				 FND_MESSAGE.SET_NAME('WSH','WSH_LEDGER_ID_NOT_FOUND');
				 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				 wsh_util_core.add_message(x_return_status);
				 IF c_get_delivery_info%ISOPEN THEN
  				    CLOSE c_get_delivery_info;
				 END IF;
				 RAISE wsh_create_document_error;
			      END IF;
			      IF c_get_ledger_id%ISOPEN THEN
				CLOSE c_get_ledger_id;
			      END IF;

			      WSH_DOCUMENT_PVT.Create_Document
				( p_api_version            => 1.0
				, p_init_msg_list          => 'F'
				, p_commit                 => NULL
				, p_validation_level       => NULL
				, x_return_status          => l_return_status
				, x_msg_count              => l_msg_count
				, x_msg_data               => l_msg_data
				, p_entity_name            => 'WSH_DELIVERY_LEGS'
				, p_entity_id              => l_delivery_leg_id
				, p_application_id         => 665
				, p_location_id            => l_pickup_location_id
				, p_document_type          => 'BOL'
				, p_document_sub_type      => l_ship_method_code
				, p_ledger_id              => l_ledger_id  -- LE Uptake
				, p_consolidate_option     => 'BOTH'
				, p_manual_sequence_number => 200
				, x_document_number        => l_document_number);

			      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                                IF c_get_delivery_info%ISOPEN THEN
				 CLOSE c_get_delivery_info;
                                END IF;
			  	 RAISE wsh_create_document_error;
			      END IF;
			      --
			    END IF;
			  END LOOP;
			  IF c_get_delivery_info%ISOPEN THEN
			    CLOSE c_get_delivery_info;
			  END IF;
		       END IF;

		  ELSIF document.concurrent_program_name = 'WSHRDPAK' THEN

                       SELECT count(*)
			   into cnt
		           from wsh_document_instances
			   WHERE entity_name = 'WSH_NEW_DELIVERIES'
			   AND   entity_id = l_argument(2)
			   AND   document_type = 'PACK_TYPE';

                       IF cnt = 0 then

		       open  c_get_init_pickup_loc_id(l_argument(2));
		       fetch c_get_init_pickup_loc_id into p_location_id1;
		       IF c_get_init_pickup_loc_id%ISOPEN THEN
		          close c_get_init_pickup_loc_id;
		       END IF;
 			-- LE Uptake
		       open m_get_ledger_id(l_argument(2));
		       fetch m_get_ledger_id INTO l_ledger_id;
		       	  IF l_debug_on THEN
			    WSH_DEBUG_SV.logmsg(l_module_name,'l_ledger_id = '||l_ledger_id);
			  END IF;

			 IF m_get_ledger_id%NOTFOUND THEN
			   FND_MESSAGE.SET_NAME('WSH','WSH_LEDGER_ID_NOT_FOUND');
			   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			   wsh_util_core.add_message(x_return_status);
			   RAISE wsh_create_document_error;
			 END IF;

			 IF m_get_ledger_id%ISOPEN THEN
			  close m_get_ledger_id;
                	 END IF;

			 wsh_document_pvt.create_document (
				  p_api_version            => 1.0
				, p_init_msg_list          => FND_API.G_FALSE -- Bug 5614459
				, p_commit                 => NULL
				, p_validation_level       => NULL
				, x_return_status          => l_return_status
				, x_msg_count              => l_msg_count
				, x_msg_data               => l_msg_data
				, p_entity_name            => 'WSH_NEW_DELIVERIES'
				, p_entity_id              => l_argument(2)
				, p_application_id         => 665
				, p_location_id            => p_location_id1
				, p_document_type          => 'PACK_TYPE'
				, p_document_sub_type      => 'SALES_ORDER'
				, p_ledger_id              => l_ledger_id  -- LE Uptake
				, p_consolidate_option     => 'BOTH'
				, p_manual_sequence_number => 200
				, x_document_number        => l_document_number);

			 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			     RAISE wsh_create_document_error;
			 END IF;

                       END IF;
		  END IF;

       	  --- BugFix 3274604 - End

-- Begin of XDO Integration Changes


		l_print_pdf := 'N';
		IF(l_output_file_type = 'XML' ) THEN
		--{
                   IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,  'template' || l_template_code);
                   END IF;
                   --
		   IF (l_template_code is not NULL) then
        	  --{
			IF l_nls_lang.COUNT <> 0 THEN
                                --bugfix 6717642 added function lower
				select lower(iso_language),iso_territory into l_language, l_territory
				from fnd_languages
				where language_code = l_nls_lang(l_nls_count).lang_code;
			ELSE
				select lower(iso_language),iso_territory into l_language, l_territory
				from fnd_languages
				where language_code = userenv('LANG');
			END IF;
                        --
                        IF l_debug_on THEN
			  WSH_DEBUG_SV.logmsg(l_module_name,  ' language ' || l_language );
			  WSH_DEBUG_SV.logmsg(l_module_name,  'territory ' || l_territory);
                        END IF;
                        --
			l_ret_status :=fnd_request.add_layout(l_appl_short_name,
			l_template_code,
			l_language,
			l_territory,
			'PDF');
			IF l_ret_status THEN
				l_print_pdf := 'Y';
			ELSE
				IF l_debug_on THEN
					WSH_DEBUG_SV.logmsg(l_module_name, 'Error returning from fnd_request.add_layout :'||x_return_status);
				END IF;
				wsh_util_core.add_message(x_return_status);
			END IF;
		   --}
		   ELSE
			--{
                        IF l_debug_on THEN
			  WSH_DEBUG_SV.logmsg(l_module_name,  'No template was specified for this report. Hence could not generate the pdf output' );
                        END IF;
                        --
                        --Bug 9255258  continue with report submission.
			/*fnd_message.set_name('WSH', 'WSH_NO_DEFAULT_TEMPLATE');
			fnd_message.set_token('CONC_PROG_NAME', document.user_concurrent_program_name);
			x_return_status := wsh_util_core.g_ret_sts_error;
			wsh_util_core.add_message(x_return_status);*/
			l_print_pdf := 'Y';
		   END IF; --} If template_code is not null
		END IF; --} If l_output_file_type = 'XML'

-- End of XDO Integration Changes
		IF ((l_output_file_type <> 'XML') OR
		     (l_output_file_type = 'XML' and l_print_pdf = 'Y')) THEN
		    l_request_id := fnd_request.submit_request
                     (document.application_short_name,
                      document.concurrent_program_name,
                      '',
                      '',
                      FALSE,
                      l_argument(1), l_argument(2), l_argument(3), l_argument(4), l_argument(5),
                      l_argument(6), l_argument(7), l_argument(8), l_argument(9), l_argument(10),
                      l_argument(11),l_argument(12),l_argument(13),l_argument(14),l_argument(15),
                      l_argument(16),l_argument(17),l_argument(18),l_argument(19),l_argument(20),
                      l_argument(21),l_argument(22),l_argument(23),l_argument(24),l_argument(25),
                      l_argument(26),l_argument(27),l_argument(28),l_argument(29),l_argument(30),
                      '','','','','','','','','','',
                      '','','','','','','','','','',
                      '','','','','','','','','','',
                      '','','','','','','','','','',
                      '','','','','','','','','','',
                      '','','','','','','','','','',
                      '','','','','','','','','','');


                      --
                      -- Debug Statements
                      --
                    IF l_debug_on THEN --{
                        WSH_DEBUG_SV.logmsg(l_module_name,  'SUBMITTED '|| DOCUMENT.CONCURRENT_PROGRAM_NAME||' WITH REQUEST_ID:'||TO_CHAR ( L_REQUEST_ID )  );
                    END IF; --}
                    --
                    -- increase the counter if successful
                    IF l_request_id > 0 THEN --{

                       l_submitted_docs := l_submitted_docs + 1;

                       --
                       -- Debug Statements
                       --
                       IF l_debug_on THEN --{
                           WSH_DEBUG_SV.logmsg(l_module_name,  'REQUEST ID ' || TO_CHAR ( L_REQUEST_ID )  );
                       END IF; --}
                       --

                       if (entity_count > 0) then --{

                          IF l_submitted_docs = 1 THEN --{
                             l_req_id_str := to_char(l_request_id);
                          ELSE
                          --Bug#5188945: Restricting the string of request ids to 1975 characters length only
                              IF (l_buffer_fill = 'N' ) THEN
                              --{
                                  l_req_id_str := l_req_id_str || ', ' || to_char(l_request_id);
                                  IF LENGTH(l_req_id_str) > 1975 THEN
                                  --{
                                     l_req_id_str := SUBSTR(l_req_id_str,1,INSTR(l_req_id_str,',',-1,1)) || '...';
                                     l_buffer_fill := 'Y';
                                  --}
                                  END IF;
                              --}
                              END IF;
                          --}
                          END IF; --}

                       end if;  --}

                    ELSE

                       if (entity_count > 0) then --{

                          declare
                             msg_buffer   varchar2(2000);
                          begin

                             msg_buffer := fnd_message.get;

                             FND_MESSAGE.SET_NAME('WSH', 'WSH_PRINT_DOC_SET_FAILED');
                             FND_MESSAGE.SET_TOKEN('RELEASE_TYPE', entity_type);
                             FND_MESSAGE.SET_TOKEN('NAME', entity_name);
                             FND_MESSAGE.SET_TOKEN('UNDERLYING_ERROR', msg_buffer);

                             wsh_util_core.add_message(x_return_status);

                          end;
                       end if;--}

                    END IF; --} if request_id > 0

		    END IF ; --} if outfile_file_type <> 'XML' or l_print_pdf = 'Y'
                    l_nls_count := l_nls_count + 1;

                  END LOOP; -- end of l_submitted loop

                ELSE   -- It is WSHRDPIK and G_PRINTERTAB has been populated
                  IF l_debug_on THEN --{
                          WSH_DEBUG_SV.logmsg(l_module_name, 'WSHRDPIK and number of printers is ' || WSH_INV_INTEGRATION_GRP.G_PRINTERTAB.count   );
                  END IF; --}
                  --
		  -- Find position of 'Printer Name' in the arguments

		  l_printer_pos := -1 ;
		  for j in 1..l_argument_name.count loop
                        IF l_debug_on THEN --{
                             WSH_DEBUG_SV.logmsg(l_module_name, 'Argument name  ' || l_argument_name (j) );
                        END IF; --}
                            --
			if l_argument_name(j) = 'Printer Name' then
			    l_printer_pos := j;
                            IF l_debug_on THEN --{
                                WSH_DEBUG_SV.logmsg(l_module_name, 'Found printer name at pos ' || j  );
                            END IF; --}
                            --
			    exit ;
                        end if ;
                  end loop ;


		 -- FOR i in 1..WSH_INV_INTEGRATION_GRP.G_PRINTERTAB.count  LOOP

		    -- l_argument(l_printer_pos) := WSH_INV_INTEGRATION_GRP.G_PRINTERTAB(i);
         l_argument(l_printer_pos) := p_document_param_info(1).p_printer_name;

                     IF l_debug_on THEN --{
		         WSH_DEBUG_SV.logmsg(l_module_name,  'Setting  '|| document.concurrent_program_name || ' with ' || l_copies || ' copies on printer ' || p_document_param_info(1).p_printer_name );
                     --
                     END IF; --}

                     l_printer_setup :=
			    fnd_request.set_print_options
			    (printer        => p_document_param_info(1).p_printer_name,
			     style          => document.output_print_style,
			     copies         => l_copies,
			     save_output    => l_save_output,
			     print_together => 'N');

                     if ( NOT l_printer_setup and l_debug_on ) then  --{
			    WSH_DEBUG_SV.logmsg(l_module_name,  'For Printer ' || p_document_param_info(1).p_printer_name || ',  Set_Print_Options Returned False for WSHRDPIK!!!!');
                     end if ; --}

                     -- Getting language if document has MLS function associated with it
                     IF document.mls_executable_id IS NOT NULL THEN
                        l_nls_lang.delete;
                        IF l_debug_on THEN --{
                           WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_EXTREPS_MLS_LANG.Get_NLS_Lang ' );
                        END IF; --}
                        WSH_EXTREPS_MLS_LANG.Get_NLS_Lang (
                                                             p_prog_name      => document.concurrent_program_name,
                                                             p_doc_param_info => l_lang_doc_params_info,
                                                             p_nls_comp       => document.nls_compliant,
                                                             x_nls_lang       => l_nls_lang,
                                                             x_return_status  => x_return_status
                                                          );
                        IF x_return_status IN ( fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_unexp_error ) THEN
                           IF l_debug_on THEN --{
                              WSH_DEBUG_SV.logmsg(l_module_name, 'Error returning from Get_NLS_Lang :'||x_return_status
);
                           END IF; --}
                           wsh_util_core.add_message(x_return_status);
                        END IF;
                        IF l_debug_on THEN --{
                           WSH_DEBUG_SV.logmsg(l_module_name, 'Number of NLS languages :'||l_nls_lang.COUNT );
                        END IF; --}
                     END IF;

                     l_submitted := FALSE;
                     l_nls_count := 1;



                     l_submitted := FALSE;
                     l_nls_count := 1;

                     WHILE NOT (l_submitted)
                     LOOP
                       IF l_nls_lang.COUNT <> 0 THEN
                          IF l_nls_count <= l_nls_lang.COUNT THEN
                             /* set the language and territory for this request
                                all individual requests are protected against updates */
                             IF l_debug_on THEN --{
                                WSH_DEBUG_SV.logmsg(l_module_name, 'Setting option for language : '||l_nls_lang(l_nls_count).nls_language);
                             END IF; --}
                             if ( not fnd_request.set_options(
                                                                 implicit => 'NO',
                                                                 protected => 'YES',
                                                                 language  => l_nls_lang(l_nls_count).nls_language,
                                                                 territory => l_nls_lang(l_nls_count).nls_territory)) then
                                  IF l_debug_on THEN --{
                                     WSH_DEBUG_SV.logmsg(l_module_name, 'fnd_request.set_options returned false');
                                  END IF; --}
                                  wsh_util_core.add_message(x_return_status);
                                  raise no_data_found ;
                             end if;
                          ELSE
                             -- Exit loop since all nls requests are submitted
                             EXIT;
                          END IF;
                       ELSE
                          l_submitted := TRUE;
                       END IF;

-- Begin of XDO Integration Changes

		l_print_pdf := 'N';
		IF (l_output_file_type = 'XML' ) then
		--{
                        IF l_debug_on THEN
	        	 WSH_DEBUG_SV.logmsg(l_module_name,  'template' || l_template_code);
                        END IF;
                        --
			IF (l_template_code is not NULL) then
			--{
				   IF l_nls_lang.COUNT <> 0 THEN
                                       --bugfix 6717642 added function lower
					select lower(iso_language),iso_territory into l_language, l_territory
					from fnd_languages
					where language_code = l_nls_lang(l_nls_count).lang_code;
				   ELSE
					select lower(iso_language),iso_territory into l_language, l_territory
					from fnd_languages
					where language_code = userenv('LANG');
				   END IF;
                                   --
                                   IF l_debug_on THEN
				     WSH_DEBUG_SV.logmsg(l_module_name,  ' language' || l_language );
				     WSH_DEBUG_SV.logmsg(l_module_name,  'territory' || l_territory);
                                   END IF;
                                   --
				   l_ret_status :=fnd_request.add_layout
					    (l_appl_short_name,
  					     l_template_code,
					     l_language,
					     l_territory,
					     'PDF');
				   IF l_ret_status THEN
					l_print_pdf := 'Y';
				   ELSE
					IF l_debug_on THEN
						WSH_DEBUG_SV.logmsg(l_module_name, 'Error returning from fnd_request.add_layout :'||x_return_status);
					END IF;
					wsh_util_core.add_message(x_return_status);
				   END IF;
			--}
			ELSE
                                IF l_debug_on THEN
				  WSH_DEBUG_SV.logmsg(l_module_name,  'No template was specified for this report. Hence could not generate the pdf output' );
                                END IF;
                                --Bug 9255258  continue with report submission.
				/*fnd_message.set_name('WSH', 'WSH_NO_DEFAULT_TEMPLATE');
				fnd_message.set_token('CONC_PROG_NAME', document.concurrent_program_name);
				x_return_status := wsh_util_core.g_ret_sts_error;
				wsh_util_core.add_message(x_return_status);*/
				l_print_pdf := 'Y';
			END IF; --} l_template_code is not null
		END IF; --} l_output_file_type = 'XML'

-- End of XDO Integration Changes

		IF ((l_output_file_type <> 'XML') OR
		     (l_output_file_type = 'XML' and l_print_pdf = 'Y')) THEN
                       l_request_id := fnd_request.submit_request
                        (document.application_short_name,
                         document.concurrent_program_name,
                         '',
                         '',
                         FALSE,
                         l_argument(1), l_argument(2), l_argument(3), l_argument(4), l_argument(5),
                         l_argument(6), l_argument(7), l_argument(8), l_argument(9), l_argument(10),
                         l_argument(11),l_argument(12),l_argument(13),l_argument(14),l_argument(15),
                         l_argument(16),l_argument(17),l_argument(18),l_argument(19),l_argument(20),
                         l_argument(21),l_argument(22),l_argument(23),l_argument(24),l_argument(25),
                         l_argument(26),l_argument(27),l_argument(28),l_argument(29),l_argument(30),
                         '','','','','','','','','','',
                         '','','','','','','','','','',
                         '','','','','','','','','','',
                         '','','','','','','','','','',
                         '','','','','','','','','','',
                         '','','','','','','','','','',
                         '','','','','','','','','','');

                        --
                        -- Debug Statements
                        --
                        IF l_debug_on THEN --{
                            WSH_DEBUG_SV.logmsg(l_module_name,  'SUBMITTED '|| DOCUMENT.CONCURRENT_PROGRAM_NAME||' WITH
REQUEST_ID:'||TO_CHAR ( L_REQUEST_ID )  );
                        END IF; --}
                        --
                        -- increase the counter if successful
                        IF l_request_id > 0 THEN --{

                           l_submitted_docs := l_submitted_docs + 1;

                           --
                           -- Debug Statements
                           --
                           IF l_debug_on THEN --{
                               WSH_DEBUG_SV.logmsg(l_module_name,  'REQUEST ID ' || TO_CHAR ( L_REQUEST_ID )  );
                           END IF; --}
                           --

                           if (entity_count > 0) then --{

                              IF l_submitted_docs = 1 THEN --{
                                 l_req_id_str := to_char(l_request_id);
                              ELSE
                              --Bug#5188945: Restricting the string of request ids to 1975 characters length only
                                IF (l_buffer_fill = 'N' ) THEN
                                --{
                                    l_req_id_str := l_req_id_str || ', ' || to_char(l_request_id);
                                    IF LENGTH(l_req_id_str) >1975 THEN
                                    --{
                                         l_req_id_str := SUBSTR(l_req_id_str,1,INSTR(l_req_id_str,',',-1,1)) || '...';
                                         l_buffer_fill := 'Y';
                                    --}
                                    END IF;
                                --}
                                END IF;
                              --}

                              END IF; --}

                           end if;  --}

                        ELSE

                           if (entity_count > 0) then --{

                              declare
                                 msg_buffer       varchar2(2000);
                              begin

                                 msg_buffer := fnd_message.get;

                                 FND_MESSAGE.SET_NAME('WSH', 'WSH_PRINT_DOC_SET_FAILED');
                                 FND_MESSAGE.SET_TOKEN('RELEASE_TYPE', entity_type);
                                 FND_MESSAGE.SET_TOKEN('NAME', entity_name);
                                 FND_MESSAGE.SET_TOKEN('UNDERLYING_ERROR', msg_buffer);

                                 wsh_util_core.add_message(x_return_status);

                              end;
                           end if;--}

                        END IF; --} if request_id > 0
			END IF; --} if output_file_type <> 'XML' or l_print_pdf = 'Y'

                        l_nls_count := l_nls_count + 1;

                     END LOOP; -- end of l_submitted loop

--                  END LOOP ;  -- Loop on G_PRINTERTAB

                END IF;  --} if condition on WSHRDPIK and WSH_INV_INTEGRATION_GRP.G_PRINTERTAB

             END IF; --} If valid_params


          END LOOP; -- c_document_set loop


          IF ( l_total_docs = 0 ) THEN --{
	     -- successfully looped through all documents but didnt submit any
	     -- probably because there werent any in the set (but may have had problems
	     -- in fnd_request function

	     x_return_status := fnd_api.g_ret_sts_error;
	     fnd_message.set_name('WSH','WSH_NO_DOCS');
	     wsh_util_core.add_message(x_return_status);

	  ELSE
	     -- everthing worked: any documents not submitted resulted
	     -- from problem in fnd_request
	     x_return_status := fnd_api.g_ret_sts_success;
			   --
			   -- Debug Statements
			   --
			   IF l_debug_on THEN
			       WSH_DEBUG_SV.logmsg(l_module_name,  'SUBMITTED ' || TO_CHAR ( L_SUBMITTED_DOCS ) || ' OUT OF ' || TO_CHAR ( L_TOTAL_DOCS )  );
			   END IF;
			   --

	     fnd_message.set_name('WSH', 'WSH_DOCS_SUBMITTED');
	     fnd_message.set_token('SUBMITTED_DOCS', l_submitted_docs);
	     fnd_message.set_token('TOTAL_DOCS', l_total_docs);
	     fnd_message.set_token('REQ_IDS', l_req_id_str);
	     wsh_util_core.add_message(x_return_status);
	  END IF; --}

       END LOOP; -- for loop

  EXCEPTION
    WHEN no_reportset_to_process THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'NO REPORTS TO PROCESS'  );
      END IF;
      --
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WSH','WSH_NO_REPORT_TO_PROCESS');
      wsh_util_core.add_message(x_return_status);

    WHEN No_Org_For_Entity THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,  'NO ORGANIZATION FOUND FOR ENTITY'  );
      END IF;
      --
      x_return_status := wsh_util_core.g_ret_sts_error;
      fnd_message.set_name('WSH','WSH_NO_ENTITY_ORG');
      wsh_util_core.add_message(x_return_status);

    WHEN wsh_create_document_error THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	--      FND_MESSAGE.SET_NAME('WSH', 'WSH_BOL_CREATE_DOCUMENT_ERROR');
	--      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

		--
		-- Debug Statements
		--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CREATE_DOCUMENT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CREATE_DOCUMENT_ERROR');
	END IF;
    WHEN OTHERS THEN
      wsh_util_core.default_handler('WSH_UTIL_CORE.PRINT_DOCUMENT_SETS');
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
END print_document_sets;

END WSH_DOCUMENT_SETS;


/
