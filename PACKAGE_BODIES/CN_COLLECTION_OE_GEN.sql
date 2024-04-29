--------------------------------------------------------
--  DDL for Package Body CN_COLLECTION_OE_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLLECTION_OE_GEN" AS
-- $Header: cnoegenb.pls 120.3 2007/09/26 19:48:04 apink ship $

--
-- Private package variables
--
  -- a constant which has a null value for passing to the insert_row
  -- procedures of table handler APIs as the primary key value

  null_id	CONSTANT	NUMBER := NULL;

  l_org_id  NUMBER;

---------------- Public Procedures -------------------
--
-- Procedure Name
--   insert_comm_lines_api
-- Purpose
--   This procedure inserts into the CN_COMM_LINES_API table
-- History
--
--
  PROCEDURE insert_comm_lines_api (
	x_table_map_id		IN cn_table_maps.table_map_id%TYPE,
	x_package_id		IN cn_obj_packages_v.package_id%TYPE,
	procedure_name		IN cn_obj_procedures_v.name%TYPE,
	x_module_id			IN cn_modules.module_id%TYPE,
	x_repository_id 	IN cn_repositories.repository_id%TYPE,
	x_event_id			IN cn_events.event_id%TYPE,
	code				IN OUT	NOCOPY	cn_utils.code_type,
	x_org_id 			IN NUMBER)
  IS
  BEGIN
      l_org_id := x_org_id;
      cn_utils.set_org_id(p_org_id => l_org_id);
      cn_utils.appendcr(code);
      cn_utils.appendcr(code, '--******** INSERT CN_COMM_LINES_API *********-- ');
      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Inserting into CN_COMM_LINES_API.'');');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Inserting into CN_COMM_LINES_API.'');');

      cn_utils.appendcr(code);

      -- ++++++++++++++++++++++++++++++ --                                      +
      cn_utils.appindcr(code, '--');
      cn_utils.appindcr(code, '-- Sales credits assigned directly to this Order Line');
      cn_utils.appindcr(code, '--');


      cn_utils.unset_org_id();
 	  cn_collection_custom_gen.insert_comm_lines_api_select(x_table_map_id, code,l_org_id, '');


 	  cn_utils.set_org_id(p_org_id => l_org_id);
      cn_utils.appindcr(code, ' FROM cn_not_trx                 cnt,');
      cn_utils.appindcr(code, '      aso_i_oe_order_headers_v   asoh,');
      cn_utils.appindcr(code, '      aso_i_oe_order_lines_v     asol,');
      cn_utils.appindcr(code, '      aso_i_oe_sales_credits_v   assc');
      cn_utils.appindcr(code, 'WHERE asol.header_id = cnt.source_trx_id');
      cn_utils.appindcr(code, '  AND asol.line_id = cnt.source_trx_line_id');
--      cn_utils.appindcr(code, '  AND asol.header_id = asoh.header_id');
--      cn_utils.appindcr(code, '  AND assc.line_id = asol.line_id');
      cn_utils.appindcr(code, '  AND asoh.header_id = cnt.source_trx_id');
      cn_utils.appindcr(code, '  AND assc.line_id = cnt.source_trx_line_id');
      cn_utils.appindcr(code, '  AND cnt.event_id = ' || x_event_id);
      cn_utils.appindcr(code, '  AND cnt.collected_flag = ''N''');
      cn_utils.appindcr(code, '  AND cnt.batch_id = x_batch_id');
      cn_utils.appindcr(code, '  AND cnt.org_id = '||l_org_id);
      cn_utils.appindcr(code, '  AND asoh.org_id = cnt.org_id');
      cn_utils.appindcr(code, '  AND asol.org_id = asoh.org_id;');

      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'comm_lines_api_count := SQL%ROWCOUNT;');
      cn_utils.appendcr(code);

      cn_utils.appindcr(code, '--');
      cn_utils.appindcr(code, '-- No direct sales credits for this line, but there are some');
      cn_utils.appindcr(code, '-- but there are some at the Model level, which is identified');
      cn_utils.appindcr(code, '-- using the top_model_line_id');
      cn_utils.appindcr(code, '--');
	  cn_utils.unset_org_id();
	  --dbms_output.put_line('--- Ashley Pink Test 1');
	 cn_collection_custom_gen.insert_comm_lines_api_select(x_table_map_id, code,l_org_id, '');

	  cn_utils.set_org_id(p_org_id => l_org_id);
      cn_utils.appindcr(code, ' FROM aso_i_oe_sales_credits_v  assc,');
      cn_utils.appindcr(code, '      aso_i_oe_order_lines_v    p,');
      cn_utils.appindcr(code, '      aso_i_oe_order_lines_v    asol,');
      cn_utils.appindcr(code, '      cn_not_trx                cnt,');
      cn_utils.appindcr(code, '      aso_i_oe_order_headers_v  asoh');
      cn_utils.appindcr(code, 'WHERE asoh.header_id = cnt.source_trx_id' );
      cn_utils.appindcr(code, '  AND asol.line_id = cnt.source_trx_line_id');
      cn_utils.appindcr(code, '  AND asol.header_id = asoh.header_id');
      cn_utils.appindcr(code, '  AND p.line_id = asol.top_model_line_id');
      cn_utils.appindcr(code, '  AND assc.line_id = p.line_id');
      cn_utils.appindcr(code, '  AND asol.line_id NOT IN (');
      cn_utils.appindcr(code, '           SELECT line_id');
      cn_utils.appindcr(code, '             FROM aso_i_oe_sales_credits_v ssc');
      cn_utils.appindcr(code, '            WHERE ssc.header_id = asol.header_id');
      cn_utils.appindcr(code, '              AND ssc.line_id IS NOT NULL)');
      cn_utils.appindcr(code, '  AND cnt.event_id = ' || x_event_id);
      cn_utils.appindcr(code, '  AND cnt.collected_flag = ''N''');
      cn_utils.appindcr(code, '  AND cnt.batch_id = x_batch_id;');

      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'comm_lines_api_count := comm_lines_api_count + SQL%ROWCOUNT;');

      cn_utils.appendcr(code);

      cn_utils.appindcr(code, '--');
      cn_utils.appindcr(code, '-- No direct sales credits for this line,');
      cn_utils.appindcr(code, '-- but this is a Service Line and there are some at its parent,');
      cn_utils.appindcr(code, '-- which is identified using the service_reference_line_id');

      cn_utils.appindcr(code, '--');
      cn_utils.unset_org_id();
	   --dbms_output.put_line('--- Ashley Pink Test 2');
	  cn_collection_custom_gen.insert_comm_lines_api_select(x_table_map_id, code,l_org_id,'');

	  cn_utils.set_org_id(p_org_id => l_org_id);
      cn_utils.appindcr(code, ' FROM aso_i_oe_sales_credits_v  assc,');
      cn_utils.appindcr(code, '      aso_i_oe_order_lines_v    sp,');
      cn_utils.appindcr(code, '      aso_i_oe_order_lines_v    asol,');
      cn_utils.appindcr(code, '      cn_not_trx                cnt,');
      cn_utils.appindcr(code, '      aso_i_oe_order_headers_v  asoh');
      cn_utils.appindcr(code, 'WHERE asoh.header_id = cnt.source_trx_id' );
      cn_utils.appindcr(code, '  AND asol.line_id = cnt.source_trx_line_id');
      cn_utils.appindcr(code, '  AND asol.header_id = asoh.header_id');
      cn_utils.appindcr(code, '  AND sp.line_id = asol.service_reference_line_id');
      cn_utils.appindcr(code, '  AND assc.line_id = sp.line_id');
      cn_utils.appindcr(code, '  AND asol.line_id NOT IN (');
      cn_utils.appindcr(code, '           SELECT line_id');
      cn_utils.appindcr(code, '             FROM aso_i_oe_sales_credits_v ssc');
      cn_utils.appindcr(code, '            WHERE ssc.header_id = asol.header_id');
      cn_utils.appindcr(code, '              AND ssc.line_id IS NOT NULL)');
      cn_utils.appindcr(code, '  AND cnt.event_id = ' || x_event_id);
      cn_utils.appindcr(code, '  AND cnt.collected_flag = ''N''');
      cn_utils.appindcr(code, '  AND cnt.batch_id = x_batch_id;');

      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'comm_lines_api_count := comm_lines_api_count + SQL%ROWCOUNT;');

      cn_utils.appendcr(code);

      cn_utils.appindcr(code, '--');
      cn_utils.appindcr(code, '-- This is a Top Level line with no direct sales credits.');
      cn_utils.appindcr(code, '-- Use the credits which are attached at the Order Header level');
      cn_utils.appindcr(code, '--');
	  cn_utils.unset_org_id();
	--dbms_output.put_line('--- Ashley Pink Test 3');
	  cn_collection_custom_gen.insert_comm_lines_api_select(x_table_map_id, code,l_org_id,'');

	  cn_utils.set_org_id(p_org_id => l_org_id);
      cn_utils.appindcr(code, ' FROM aso_i_oe_order_lines_v    asol,');
      cn_utils.appindcr(code, '      aso_i_oe_sales_credits_v  assc,');
      cn_utils.appindcr(code, '      aso_i_oe_order_headers_v  asoh,');
      cn_utils.appindcr(code, '      cn_not_trx                cnt');
      cn_utils.appindcr(code, 'WHERE asoh.header_id = cnt.source_trx_id');
      cn_utils.appindcr(code, '  AND asol.line_id = cnt.source_trx_line_id');
      cn_utils.appindcr(code, '  AND asol.header_id = asoh.header_id' );
      cn_utils.appindcr(code, '  AND assc.header_id = asoh.header_id');
      cn_utils.appindcr(code, '  AND (asol.top_model_line_id IS NULL OR');
      cn_utils.appindcr(code, '       asol.top_model_line_id = asol.line_id)');
      cn_utils.appindcr(code, '  AND asol.service_reference_line_id IS NULL');
      cn_utils.appindcr(code, '  AND asol.line_id NOT IN (');
      cn_utils.appindcr(code, '           SELECT line_id');
      cn_utils.appindcr(code, '             FROM aso_i_oe_sales_credits_v ssc');
      cn_utils.appindcr(code, '            WHERE ssc.header_id = asol.header_id');
      cn_utils.appindcr(code, '              AND ssc.line_id IS NOT NULL)');
      cn_utils.appindcr(code, '  AND assc.line_id IS NULL');
      cn_utils.appindcr(code, '  AND cnt.event_id = ' || x_event_id);
      cn_utils.appindcr(code, '  AND cnt.collected_flag = ''N''');
      cn_utils.appindcr(code, '  AND cnt.batch_id = x_batch_id;');

      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'comm_lines_api_count := comm_lines_api_count + SQL%ROWCOUNT;');

      cn_utils.appendcr(code);


      cn_utils.appindcr(code, '--');
      cn_utils.appindcr(code, '-- This is a Child or Service line with');
      cn_utils.appindcr(code, '-- no direct sales credits. The Parent line also');
      cn_utils.appindcr(code, '-- has no direct sales credits. Use the credits');
      cn_utils.appindcr(code, '-- which are attached at the Order Header level');

      cn_utils.appindcr(code, '--');
	  cn_utils.unset_org_id();
	    --dbms_output.put_line('--- Ashley Pink Test 4');
	  cn_collection_custom_gen.insert_comm_lines_api_select(x_table_map_id, code,l_org_id,'');

	  cn_utils.set_org_id(p_org_id => l_org_id);
      cn_utils.appindcr(code, ' FROM aso_i_oe_order_lines_v    asol,');
      cn_utils.appindcr(code, '      aso_i_oe_order_lines_v    pl,');
      cn_utils.appindcr(code, '      aso_i_oe_sales_credits_v  assc,');
      cn_utils.appindcr(code, '      aso_i_oe_order_headers_v  asoh,');
      cn_utils.appindcr(code, '      cn_not_trx        cnt');
      cn_utils.appindcr(code, 'WHERE asoh.header_id = cnt.source_trx_id');
      cn_utils.appindcr(code, '  AND asol.line_id = cnt.source_trx_line_id');
      cn_utils.appindcr(code, '  AND asol.header_id = asoh.header_id');
      cn_utils.appindcr(code, '  AND asol.line_id NOT IN (');
      cn_utils.appindcr(code, '           SELECT line_id');
      cn_utils.appindcr(code, '             FROM aso_i_oe_sales_credits_v ssc');
      cn_utils.appindcr(code, '            WHERE ssc.header_id = asol.header_id');
      cn_utils.appindcr(code, '              AND ssc.line_id IS NOT NULL)');
      cn_utils.appindcr(code, '  AND ( ( pl.line_id = asol.top_model_line_id AND');
      cn_utils.appindcr(code, '          asol.line_id <> asol.top_model_line_id)');
      cn_utils.appindcr(code, '        OR');
      cn_utils.appindcr(code, '        ( pl.line_id = asol.service_reference_line_id AND');
      cn_utils.appindcr(code, '          asol.top_model_line_id IS NULL))');
      cn_utils.appindcr(code, '  AND pl.line_id NOT IN (');
      cn_utils.appindcr(code, '           SELECT line_id');
      cn_utils.appindcr(code, '             FROM aso_i_oe_sales_credits_v ssc');
      cn_utils.appindcr(code, '            WHERE ssc.header_id = pl.header_id');
      cn_utils.appindcr(code, '              AND ssc.line_id IS NOT NULL)');
      cn_utils.appindcr(code, '  AND assc.line_id IS NULL');
      cn_utils.appindcr(code, '-- Get credits from header of parent line. NOTE: a Service');
      cn_utils.appindcr(code, '-- parent may belong to a different order.');
      cn_utils.appindcr(code, '  AND assc.header_id = pl.header_id');
      cn_utils.appindcr(code, '  AND cnt.event_id = ' || x_event_id);
      cn_utils.appindcr(code, '  AND cnt.collected_flag = ''N''');
      cn_utils.appindcr(code, '  AND cnt.batch_id = x_batch_id;');

      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'comm_lines_api_count := comm_lines_api_count + SQL%ROWCOUNT;');

      cn_utils.appendcr(code);

      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ':Inserted '' || comm_lines_api_count || '' line records into CN_COMM_LINES_API.'');');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ':Inserted '' || comm_lines_api_count || '' line records into CN_COMM_LINES_API.'');');

      cn_utils.appendcr(code);
      cn_utils.appendcr(code);

      -- Update the collected_flag in CN_NOT_TRX
      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updating collected_flag in CN_NOT_TRX .'');');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Updating collected_flag in CN_NOT_TRX .'');');

      cn_utils.appendcr(code);

      cn_utils.appindcr(code, 'UPDATE cn_not_trx cnt');
      cn_utils.appindcr(code, '   SET collected_flag = ''Y''');
      cn_utils.appindcr(code, ' WHERE cnt.event_id = ' || x_event_id);
      cn_utils.appindcr(code, '   AND cnt.collected_flag = ''N''');
      cn_utils.appindcr(code, '   AND cnt.batch_id = x_batch_id');
      cn_utils.appindcr(code, '   AND cnt.org_id = '||l_org_id||' ;');
      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updated collected_flag in cn_not_trx.'');');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Updated collected_flag in cn_not_trx.'');');

      cn_utils.appendcr(code);
      cn_utils.unset_org_id();
	  --dbms_output.put_line('--- Ashley Pink Test End oe gen');
  EXCEPTION
    WHEN NO_DATA_FOUND
	THEN
      cn_debug.print_msg('insert_lines: in exception handler for NO_DATA_FOUND',1);
    	fnd_file.put_line(fnd_file.Log, 'insert_lines: in exception handler for NO_DATA_FOUND');
      RETURN;
  END insert_comm_lines_api;

END cn_collection_oe_gen;

/
