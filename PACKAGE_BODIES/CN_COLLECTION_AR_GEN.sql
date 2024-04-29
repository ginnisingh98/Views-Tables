--------------------------------------------------------
--  DDL for Package Body CN_COLLECTION_AR_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLLECTION_AR_GEN" AS
-- $Header: cnargenb.pls 120.5 2005/10/18 01:23:33 apink noship $

--------------------------------------------------------+
-- Public procedures
--------------------------------------------------------+

-- Procedure Name
--   insert_trx
-- Purpose
--   This procedure inserts into the CN_TRX headers table
-- History
--   11-17-93	Devesh Khatu	Created
--   08-01-95	Amy Erickson	Updated

g_cn_apply_non_rev_split	VARCHAR2(1);
l_org_id  NUMBER;

  PROCEDURE insert_trx (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code		IN OUT NOCOPY	cn_utils.code_type,
	x_org_id IN NUMBER) IS

    x_module_type		cn_modules.module_type%TYPE;
    i				INTEGER;

    -- This cursor fetches source and destination column names
    -- required to insert into the trx headers table.
    -- This is done by joining cn_obj_columns_v with cn_column_maps.
    -- It is assumed that each column map has a single level foreign key
    -- map associated with it.


    CURSOR header_direct_maps IS
      SELECT LOWER(destcol.name) dest_column,
             cm.expression expression
	 FROM cn_table_maps tm,
           cn_column_maps cm,
	      cn_objects destcol
      WHERE tm.mapping_type = 'INV1'
            AND cm.table_map_id = tm.table_map_id
	       AND cm.expression IS NOT NULL
	       AND cm.destination_column_id = destcol.object_id
	       AND lower(destcol.NAME) <> 'sold_to_customer_id'
	       -- Added Last Where Clause For Bug Fix 3681852 Hithanki
	       -- Added for MOAC by Ashley
	       AND tm.org_id = x_org_id
	       AND cm.org_id = tm.org_id
	       AND destcol.org_id = cm.org_id
      ORDER BY destcol.name;

  BEGIN

	l_org_id := x_org_id;
  	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** INSERT CN_TRX ********-- ');
	cn_utils.unset_org_id();

    cn_debug.print_msg('insert_trx>>', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_trx>>');

    SELECT module_type	--AE 11-16-95
    INTO x_module_type
    FROM cn_modules
    WHERE module_id = x_module_id
	--Added for MOAC by Ashley
	AND org_id = x_org_id;

    cn_debug.print_msg('insert_trx: x_module_id = ' || x_module_id, 1);

    -- Generate the insert statement
    cn_debug.print_msg('insert_trx: Generating INSERT statement. ', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_trx: Generating INSERT statement. ');

 	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appindcr(code, 'cn_message_pkg.debug('''|| procedure_name || ': Inserting into CN_TRX.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, '''|| procedure_name || ': Inserting into CN_TRX.'');');
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'INSERT INTO cn_trx(');
    cn_utils.indent(code, 1);

    -- First fill in some standard fields such as
    -- status, collection_run_id in the headers table
    cn_utils.appindcr(code, 'trx_id,');
	-- Added For MOAC by Ashley
    cn_utils.appindcr(code, 'org_id,');
    cn_utils.appindcr(code, 'not_trx_id,');
    cn_utils.appindcr(code, 'batch_id,');
    cn_utils.appindcr(code, 'transfer_batch_id,');
    cn_utils.appindcr(code, 'status,');
    cn_utils.appindcr(code, 'trx_type,');             --AE 11-16-95
    cn_utils.appindcr(code, 'event_id,');
    cn_utils.appindcr(code, 'notified_date,');
    cn_utils.appindcr(code, 'processed_date,');
    cn_utils.appindcr(code, 'collection_run_id,');


    IF (x_event_id = cn_global.inv_event_id)  THEN
      -- Populate the mapping-driven columns
      FOR h IN header_direct_maps LOOP
        cn_utils.appindcr(code, h.dest_column || ',');
      END LOOP;

        cn_utils.appindcr(code, 'sold_to_customer_id,'); -- Added For Bug Fix 3681852 Hithanki

      cn_utils.strip_prev(code, 1);   --AE 08-24-95  remove trailing comma
      cn_utils.appindcr(code, ')');
      cn_utils.unindent(code, 1);

    ELSIF ((x_event_id = cn_global.pmt_event_id)  OR
	   (x_event_id = cn_global.cbk_event_id)  OR
	   (x_event_id = cn_global.wo_event_id))  THEN

      cn_utils.appindcr(code, 'gl_posted_date,');
      cn_utils.appindcr(code, 'gl_date,');
      cn_utils.appindcr(code, 'prorated_amount,');
      cn_utils.appindcr(code, 'line_amount_applied,');
      cn_utils.appindcr(code, 'spare_column1,');
      cn_utils.appindcr(code, 'source_trx_id,');
      cn_utils.appindcr(code, 'source_payment_schedule_id,');
      cn_utils.appindcr(code, 'due_date ');
      cn_utils.appindcr(code, ')');
      cn_utils.unindent(code, 1);
    END IF;

    cn_utils.appindcr(code, 'SELECT');
    cn_utils.indent(code, 1);
    cn_utils.appindcr(code, 'cn_trx_s.NEXTVAL,');
    --Added for MOAC by Ashley
    cn_utils.appindcr(code, 'cnt.org_id,');
    cn_utils.appindcr(code, 'cnt.not_trx_id,');
    cn_utils.appindcr(code, 'cnt.batch_id,');
    cn_utils.appindcr(code, 'FLOOR(cn_trx_s.CURRVAL/cn_global.xfer_batch_size),');
    cn_utils.appindcr(code, '''COL'',');
    cn_utils.appindcr(code, '''' || x_module_type || ''',');    --AE 11-16-95
    cn_utils.appindcr(code, 'cnt.event_id,');                   --AE 01-16-96
    cn_utils.appindcr(code, 'cnt.notified_date,');
    cn_utils.appindcr(code, 'cnt.processed_date,');             --AE 01-05-96
    cn_utils.appindcr(code, 'x_proc_audit_id,');


    IF (x_event_id = cn_global.inv_event_id)  THEN
      -- Select the mapping-driven columns.
      FOR h IN header_direct_maps LOOP
	   cn_utils.appindcr(code, h.expression || ',');
      END LOOP;

      cn_utils.appindcr(code, 'NVL(rct.sold_to_customer_id,rct.bill_to_customer_id),');
      ---- Added For Bug Fix 3681852 Hithanki

      cn_utils.strip_prev(code, 1);    --AE 08-24-95  remove trailing comma
      cn_utils.appendcr(code);
      cn_utils.unindent(code, 1);

    ELSIF (x_event_id = cn_global.pmt_event_id)  THEN
      cn_utils.appindcr(code, 'ara.gl_posted_date,');
      cn_utils.appindcr(code, 'ara.gl_date,');
      cn_utils.appindcr(code, 'ara.line_applied,');
      cn_utils.appindcr(code, 'ara.line_applied,');
      cn_utils.appindcr(code, 'ara.receivable_application_id,');
      cn_utils.appindcr(code, 'ara.applied_customer_trx_id,');
      cn_utils.appindcr(code, 'ara.applied_payment_schedule_id,');
      cn_utils.appindcr(code, 'NULL ');
      cn_utils.appendcr(code);
      cn_utils.unindent(code, 1);

    ELSIF (x_event_id = cn_global.wo_event_id)	THEN
      cn_utils.appindcr(code, 'aa.gl_posted_date,');
      cn_utils.appindcr(code, 'aa.gl_date,');
      cn_utils.appindcr(code, 'NVL(aa.line_adjusted, 0),');   --AE 02-05-96
      cn_utils.appindcr(code, 'NVL(aa.line_adjusted, 0),');   --AE 02-05-96
      cn_utils.appindcr(code, 'aa.adjustment_id,');
      cn_utils.appindcr(code, 'aa.customer_trx_id,');
      cn_utils.appindcr(code, 'aa.payment_schedule_id,');
      cn_utils.appindcr(code, 'NULL ');
      cn_utils.appendcr(code);
      cn_utils.unindent(code, 1);

    ELSIF (x_event_id = cn_global.cbk_event_id)  THEN
      cn_utils.appindcr(code, 'NULL,');
      cn_utils.appindcr(code, 'NULL,');
      cn_utils.appindcr(code, 'aps.amount_line_items_remaining,');
      cn_utils.appindcr(code, 'NULL,');
      cn_utils.appindcr(code, 'NULL,');
      cn_utils.appindcr(code, 'aps.customer_trx_id,');
      cn_utils.appindcr(code, 'aps.payment_schedule_id,');
      cn_utils.appindcr(code, 'aps.due_date ');
      cn_utils.appendcr(code);
      cn_utils.unindent(code, 1);
    END IF;

    -- generate the from statements
    IF (x_event_id = cn_global.inv_event_id)  THEN
      cn_utils.appindcr(code, ' FROM cn_not_trx cnt, ra_customer_trx rct');
      cn_utils.appindcr(code, 'WHERE cnt.source_trx_id = rct.customer_trx_id');
      -- Added for MOAC by Ashley
      cn_utils.appindcr(code, 'AND cnt.org_id = '||x_org_id);
      cn_utils.appindcr(code, 'AND rct.org_id = cnt.org_id');


    ELSIF (x_event_id = cn_global.pmt_event_id)  THEN
      cn_utils.appindcr(code, ' FROM cn_not_trx cnt, ar_receivable_applications ara');
      cn_utils.appindcr(code, 'WHERE cnt.source_trx_id = ara.receivable_application_id');

	  --Added For MOAC By Ashley
      cn_utils.appindcr(code, 'AND cnt.org_id = '||x_org_id);
      cn_utils.appindcr(code, 'AND ara.org_id = cnt.org_id');

      cn_utils.appindcr(code, '  AND NOT EXISTS (');
      cn_utils.appindcr(code, '      SELECT trx_id');
      cn_utils.appindcr(code, '        FROM cn_trx ct');
      cn_utils.appindcr(code, '       WHERE ct.source_payment_schedule_id = ara.applied_payment_schedule_id');
      --Added For MOAC By Ashley
      cn_utils.appindcr(code, '       AND ct.org_id = '||x_org_id);
      cn_utils.appindcr(code, '         AND ct.trx_type = ''CBK'')');

    ELSIF (x_event_id = cn_global.wo_event_id)	THEN
      cn_utils.appindcr(code, ' FROM cn_not_trx cnt, ar_adjustments aa');
      cn_utils.appindcr(code, 'WHERE cnt.source_trx_id = aa.adjustment_id');
	  --Added For MOAC By Ashley
      cn_utils.appindcr(code, 'AND cnt.org_id = '||x_org_id);
      cn_utils.appindcr(code, 'AND aa.org_id = cnt.org_id');

    ELSIF (x_event_id = cn_global.cbk_event_id)  THEN
      cn_utils.appindcr(code, ' FROM cn_not_trx cnt, ar_payment_schedules aps');
      cn_utils.appindcr(code, 'WHERE cnt.source_trx_id = aps.payment_schedule_id');
	  --Added For MOAC By Ashley
      cn_utils.appindcr(code, 'AND cnt.org_id = '||x_org_id);
      cn_utils.appindcr(code, 'AND aps.org_id = cnt.org_id');

      cn_utils.appindcr(code, '  AND NOT EXISTS (');
      cn_utils.appindcr(code, '      SELECT trx_id');
      cn_utils.appindcr(code, '        FROM cn_trx ct');
      cn_utils.appindcr(code, '       WHERE ct.source_payment_schedule_id = aps.payment_schedule_id');
      --Added For MOAC By Ashley
      cn_utils.appindcr(code, '       AND ct.org_id = '||x_org_id);

      cn_utils.appindcr(code, '         AND ct.trx_type = ''CBK'')');
    END IF;

    cn_utils.appindcr(code, '  AND cnt.event_id = ' || x_event_id);
    cn_utils.appindcr(code, '  AND cnt.collected_flag = ''N''');
    cn_utils.appindcr(code, '  AND cnt.batch_id = x_batch_id;');
    cn_utils.appendcr(code);

    -- Generate code to update the trx_count variable
    cn_utils.appindcr(code, 'trx_count := SQL%ROWCOUNT;');
    cn_utils.appendcr(code);
    cn_utils.appendcr(code);

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- AE 03-01-96	 If event_type = Payments do Givebacks at the same time.
    IF (x_event_id = cn_global.pmt_event_id)  THEN

    cn_utils.appindcr(code, 'INSERT INTO cn_trx(');
    cn_utils.indent(code, 1);

    -- First fill in some standard fields such as
    -- status, collection_run_id in the headers table
    cn_utils.appindcr(code, 'trx_id,');
    --Added For MOAC by Ashley
    cn_utils.appindcr(code, 'org_id,');
    cn_utils.appindcr(code, 'not_trx_id,');
    cn_utils.appindcr(code, 'batch_id,');
    cn_utils.appindcr(code, 'transfer_batch_id,');
    cn_utils.appindcr(code, 'status,');
    cn_utils.appindcr(code, 'trx_type,');             --AE 11-16-95
    cn_utils.appindcr(code, 'event_id,');
    cn_utils.appindcr(code, 'notified_date,');
    cn_utils.appindcr(code, 'processed_date,');
    cn_utils.appindcr(code, 'collection_run_id,');

    cn_utils.appindcr(code, 'gl_posted_date,');
    cn_utils.appindcr(code, 'gl_date,');
    cn_utils.appindcr(code, 'prorated_amount,');
    cn_utils.appindcr(code, 'line_amount_applied,');
    cn_utils.appindcr(code, 'spare_column1,');
    cn_utils.appindcr(code, 'source_trx_id,');
    cn_utils.appindcr(code, 'source_payment_schedule_id,');
    cn_utils.appindcr(code, 'due_date ');
    cn_utils.appindcr(code, ')');
    cn_utils.unindent(code, 1);

    cn_utils.appindcr(code, 'SELECT');
    cn_utils.indent(code, 1);
    cn_utils.appindcr(code, 'cn_trx_s.NEXTVAL,');
    --Added for MOAC by Ashley
    cn_utils.appindcr(code, 'cnt.org_id,');
    cn_utils.appindcr(code, 'cnt.not_trx_id,');
    cn_utils.appindcr(code, 'cnt.batch_id,');
    cn_utils.appindcr(code, 'FLOOR(cn_trx_s.CURRVAL/cn_global.xfer_batch_size),');
    cn_utils.appindcr(code, '''COL'',');
    cn_utils.appindcr(code, '''GBK'',');
    cn_utils.appindcr(code, 'cn_global.gbk_event_id,');
    cn_utils.appindcr(code, 'cnt.notified_date,');
    cn_utils.appindcr(code, 'cnt.processed_date,');
    cn_utils.appindcr(code, 'x_proc_audit_id,');

    cn_utils.appindcr(code, 'ara.gl_posted_date,');
    cn_utils.appindcr(code, 'ara.gl_date,');
    cn_utils.appindcr(code, 'ara.line_applied,');
    cn_utils.appindcr(code, 'ara.line_applied,');
    cn_utils.appindcr(code, 'ara.receivable_application_id,');
    cn_utils.appindcr(code, 'ara.applied_customer_trx_id,');
    cn_utils.appindcr(code, 'ara.applied_payment_schedule_id,');
    cn_utils.appindcr(code, 'NULL ');
    cn_utils.appendcr(code);
    cn_utils.unindent(code, 1);

  -- generate the from statements
    cn_utils.appindcr(code, ' FROM cn_not_trx cnt, ar_receivable_applications ara');
    cn_utils.appindcr(code, 'WHERE cnt.source_trx_id = ara.receivable_application_id');
    --Added For MOAC By Ashley
    cn_utils.appindcr(code, 'AND cnt.org_id = '||x_org_id);
    cn_utils.appindcr(code, 'AND ara.org_id = cnt.org_id');

    cn_utils.appindcr(code, '  AND EXISTS (');
    cn_utils.appindcr(code, '      SELECT trx_id');
    cn_utils.appindcr(code, '        FROM cn_trx ct');
    cn_utils.appindcr(code, '       WHERE ct.source_payment_schedule_id = ara.applied_payment_schedule_id');
    --Added for MOAC by Ashley
    cn_utils.appindcr(code, '       AND ct.org_id = '||x_org_id);

    cn_utils.appindcr(code, '       AND ct.trx_type = ''CBK'')');

    cn_utils.appindcr(code, '  AND cnt.event_id = ' || x_event_id);
    cn_utils.appindcr(code, '  AND cnt.collected_flag = ''N''');
    cn_utils.appindcr(code, '  AND cnt.batch_id = x_batch_id;');
    cn_utils.appendcr(code);

    -- Generate code to update the trx_count variable
    cn_utils.appindcr(code, 'trx_count := trx_count + SQL%ROWCOUNT;');
    cn_utils.appendcr(code);
    cn_utils.appendcr(code);
   END IF;   -- (x_event_id = cn_global.pmt_event_id)
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	cn_utils.unset_org_id();
    cn_debug.print_msg('insert_trx: Generated INSERT statement.', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_trx: Generated INSERT statement.');

	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Inserted '' || trx_count || '' records into cn_trx.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log,''' || procedure_name || ': Inserted '' || trx_count || '' records into cn_trx.'');');
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updating collected_flag in CN_NOT_TRX .'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log,''' || procedure_name || ': Updating collected_flag in CN_NOT_TRX .'');');
    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'UPDATE cn_not_trx cnt');
    cn_utils.appindcr(code, '   SET collected_flag = ''Y''');
    cn_utils.appindcr(code, ' WHERE cnt.event_id = ' || x_event_id);
    --Added for MOAC by Ashley
    cn_utils.appindcr(code, ' AND cnt.org_id = ' || x_org_id);

    cn_utils.appindcr(code, '   AND cnt.collected_flag = ''N''');
    cn_utils.appindcr(code, '   AND cnt.batch_id = x_batch_id;');
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updated collected_flag in cn_not_trx.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log,''' || procedure_name || ': Updated collected_flag in cn_not_trx.'');');
    cn_utils.appendcr(code);
	cn_utils.unset_org_id();

    cn_debug.print_msg('insert_trx<<', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_trx<<');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('insert_trx: in exception handler for NO_DATA_FOUND', 1);
      fnd_file.put_line(fnd_file.Log, 'insert_trx: in exception handler for NO_DATA_FOUND');
      RETURN;
  END insert_trx;



-- Procedure Name
--   update_trx
-- Purpose
--   This procedure updates the CN_TRX headers table
-- History
--   17-NOV-93		Devesh Khatu		Created

  PROCEDURE update_trx (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code		IN OUT NOCOPY	cn_utils.code_type,
	x_org_id IN NUMBER) IS



    CURSOR header_direct_maps IS
      SELECT LOWER(destcol.name) dest_column,
             cm.expression expression
	 FROM cn_table_maps tm,
           cn_column_maps cm,
	      cn_objects destcol
      WHERE tm.mapping_type = 'INV1'
            AND cm.table_map_id = tm.table_map_id
	       AND cm.expression IS NOT NULL
	       AND cm.destination_column_id = destcol.object_id
	       -- Added for MOAC by Ashley
	       AND tm.org_id = x_org_id
	       AND cm.org_id = tm.org_id
	       AND destcol.org_id = cm.org_id
      ORDER BY destcol.name;


  BEGIN
    l_org_id := x_org_id;
  	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** UPDATE CN_TRX ********-- ');
	cn_utils.unset_org_id();

    cn_debug.print_msg('update_trx>>', 1);
    fnd_file.put_line(fnd_file.Log, 'update_trx>>');
      -- Initialize value of table_map_id
      -- Note: This assumes that there is exactly one header table in the
      -- repository

    cn_debug.print_msg('update_trx: x_module_id = ' || x_module_id, 1);


    -- Generate the update statement
    cn_debug.print_msg('update_trx: Generating UPDATE statement. ', 1);
    fnd_file.put_line(fnd_file.Log, 'update_trx: Generating UPDATE statement. ');

	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updating CN_TRX .'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Updating CN_TRX .'');');
    cn_utils.appendcr(code);


    IF (x_event_id = cn_global.inv_event_id)  THEN

      -- update trx_type for Invoices and Credit Memos.     --AE 01-26-96
      -- Note:	Sort out the Credit Memos from the Invoices.
      -- Up to this point, the ct.trx_type = INV for both.
      cn_utils.appindcr(code, 'UPDATE cn_trx ct');
      cn_utils.appindcr(code, '   SET trx_type = (');
      cn_utils.appindcr(code, '       SELECT rctt.type');
      cn_utils.appindcr(code, '       FROM ra_cust_trx_types rctt');
      cn_utils.appindcr(code, '       WHERE rctt.cust_trx_type_id = ct.trx_type_id ');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, '       AND rctt.org_id = '||x_org_id||') ');
      cn_utils.appindcr(code, ' WHERE ct.collection_run_id = x_proc_audit_id ');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, ' AND ct.org_id = '||x_org_id||' ;');
      cn_utils.appendcr(code);


      -- update rollup date for Invoices.		    --AE 01-26-96
      cn_utils.appindcr(code, 'UPDATE cn_trx ct');
      cn_utils.appindcr(code, '   SET rollup_date = NVL(date_ordered, trx_date)');
      cn_utils.appindcr(code, ' WHERE ct.collection_run_id = x_proc_audit_id ');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, ' AND ct.org_id = '||x_org_id);
      cn_utils.appindcr(code, ' AND ct.trx_type IN (''INV'',''DM''); ');
      cn_utils.appendcr(code);

      -- update rollup date for Credit Memos.
      cn_utils.appindcr(code, 'UPDATE cn_trx ct');
      cn_utils.appindcr(code, '   SET rollup_date = (');
      cn_utils.appindcr(code, '        SELECT rct.trx_date');
      cn_utils.appindcr(code, '        FROM ra_customer_trx rct');
      cn_utils.appindcr(code, '        WHERE rct.customer_trx_id = ct.source_parent_trx_id ');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, '        AND rct.org_id = '||x_org_id||') ');

      cn_utils.appindcr(code, ' WHERE ct.collection_run_id = x_proc_audit_id ');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, ' AND ct.org_id = '||x_org_id );
      cn_utils.appindcr(code, ' AND ct.trx_type = ''CM'' ');
      cn_utils.appindcr(code, ' AND ct.source_parent_trx_id IS NOT NULL; ');
      cn_utils.appendcr(code);

    END IF;   -- for  cn_global.inv_event_id  compare


    -- Update the columns whose mappings have been defined for invoices
    -- For all event types other than Invoices.
    IF (x_event_id <> cn_global.inv_event_id)  THEN

      cn_utils.appindcr(code, 'UPDATE cn_trx ct');
      cn_utils.appindcr(code, '   SET');

      -- Update the custom-columns. This needs to be done by joining to other
      -- tables, by using information in the foreign key maps table.
      cn_utils.indent(code, 1);
	 cn_utils.appindcr(code, '(');
      FOR i IN header_direct_maps LOOP
        cn_utils.appindcr(code, i.dest_column || ',');
      END LOOP;
      cn_utils.strip_prev(code, 1);  --AE 08-24-95 remove trailing comma or '('

      cn_utils.appindcr(code, ') = (');
      cn_utils.unindent(code, 2);
      cn_utils.appindcr(code, 'SELECT');
      cn_utils.indent(code, 2);

      FOR i IN header_direct_maps LOOP
	   cn_utils.appindcr(code, i.expression || ',');
      END LOOP;
      cn_utils.unindent(code, 1);
      IF (SQL%FOUND) THEN
        cn_utils.strip_prev(code, 1);	--AE 08-24-95  remove trailing comma
      END IF;

      cn_utils.appendcr(code);
      cn_utils.appindcr(code, '  FROM ra_customer_trx rct');
      cn_utils.appindcr(code, ' WHERE rct.customer_trx_id = ct.source_trx_id');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, ' AND rct.org_id = '||x_org_id||'),');

      cn_utils.strip_prev(code, 1);	 --AE 08-24-95	remove trailing comma
      cn_utils.appendcr(code);

      cn_utils.unindent(code, 1);
      cn_utils.appindcr(code, 'WHERE ct.collection_run_id = x_proc_audit_id');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, 'AND ct.org_id = '||x_org_id||';');

      cn_utils.appendcr(code);

    END IF;	-- for cn_global compare


    -- Generate code to update the trx_update_count variable
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'trx_update_count := SQL%ROWCOUNT;');
    cn_utils.unset_org_id();
    cn_debug.print_msg('update_trx: Generated UPDATE statement.', 1);
    fnd_file.put_line(fnd_file.Log, 'update_trx: Generated UPDATE statement.');
    cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updated '' || trx_update_count || '' cn_trx.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log,''' || procedure_name || ': Updated '' || trx_update_count || '' cn_trx.'');');
    cn_utils.appendcr(code);
	cn_utils.unset_org_id();
    cn_debug.print_msg('update_trx<<', 1);
    fnd_file.put_line(fnd_file.Log, 'update_trx<<');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('update_trx: in exception handler for NO_DATA_FOUND', 1);
      fnd_file.put_line(fnd_file.Log, 'update_trx: in exception handler for NO_DATA_FOUND');
      RETURN;
  END update_trx;


-- Procedure Name
--   insert_lines
-- Purpose
--   Generates code to insert into the CN_TRX_LINES table
-- History
--   17-NOV-93		Devesh Khatu		Created

  PROCEDURE insert_lines (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code	IN OUT NOCOPY		cn_utils.code_type,
	x_org_id IN NUMBER) IS


    -- Declare cursor for inserting into the trx lines table
    CURSOR lines_direct_maps IS
      SELECT LOWER(destcol.name) dest_column,
             cm.expression expression
	 FROM cn_table_maps tm,
           cn_column_maps cm,
	      cn_objects destcol
      WHERE tm.mapping_type = 'INV2'
            AND cm.table_map_id = tm.table_map_id
	       AND cm.expression IS NOT NULL
	       AND cm.destination_column_id = destcol.object_id
	       -- Added for MOAC by Ashley
	       AND tm.org_id = x_org_id
	       AND cm.org_id = tm.org_id
	       AND destcol.org_id = cm.org_id
      ORDER BY destcol.name;

  BEGIN
	l_org_id := x_org_id;
	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** INSERT CN_TRX_LINES *********-- ');

    cn_debug.print_msg('insert_lines>>', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_lines>>');
    cn_debug.print_msg('insert_lines: x_module_id = ' || x_module_id, 1);

    -- Generate the INSERT statement
    cn_debug.print_msg('insert_lines: Generating INSERT statement.', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_lines: Generating INSERT statement.');

    cn_utils.set_org_id(p_org_id => l_org_id);

    cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Inserting into CN_TRX_LINES .'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log,''' || procedure_name || ': Inserting into CN_TRX_LINES .'');');
    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'INSERT INTO cn_trx_lines(');
    cn_utils.indent(code, 1);
    -- Insert fixed columns first
    cn_utils.appindcr(code, 'trx_line_id,');
    --Added for MOAC by Ashley
    cn_utils.appindcr(code, 'org_id,');

    cn_utils.appindcr(code, 'trx_id,');
    cn_utils.appindcr(code, 'event_id,');
    cn_utils.appindcr(code, 'collection_run_id,');

    -- Insert custom columns using  lines_direct_maps  cursor
    FOR l IN lines_direct_maps LOOP
      cn_utils.appindcr(code, l.dest_column || ',');
    END LOOP;

    cn_utils.strip_prev(code, 1);    --AE 08-24-95  remove trailing comma
    cn_utils.appindcr(code, ')');
    cn_utils.unindent(code, 1);

    -- Generate the SELECT clause required for the insert statement
    cn_utils.appindcr(code, 'SELECT');
    cn_utils.indent(code, 1);
    -- Select fixed columns
    cn_utils.appindcr(code, 'cn_trx_lines_s.NEXTVAL,');
    --Added for MOAC by Ashley
    cn_utils.appindcr(code, 'ct.org_id,');

    cn_utils.appindcr(code, 'ct.trx_id,');
    cn_utils.appindcr(code, 'ct.event_id,');
    cn_utils.appindcr(code, 'x_proc_audit_id,');


    -- Select other columns using the lines_direct_maps cursors. Note that
    -- we fetch the records in the cursor in the same order as before due to
    -- the order by column_id in the cursor where clause.
    FOR l IN lines_direct_maps LOOP
      cn_utils.appindcr(code, l.expression || ',');
    END LOOP;

    cn_utils.strip_prev(code, 1);	--AE 08-24-95  remove trailing comma
    cn_utils.appendcr(code);
    cn_utils.unindent(code, 1);

    -- Generate the FROM and WHERE clauses
    cn_utils.appindcr(code, ' FROM cn_trx ct, ra_customer_trx_lines rctl');

    cn_utils.appindcr(code, 'WHERE ct.source_trx_id = rctl.customer_trx_id');
    cn_utils.appindcr(code, '  AND ct.collection_run_id = x_proc_audit_id ');
    --Added for MOAC by Ashley
    cn_utils.appindcr(code, '  AND ct.org_id = '||x_org_id);
    cn_utils.appindcr(code, '  AND rctl.org_id = ct.org_id ');

    cn_utils.appindcr(code, '  AND rctl.line_type = ''LINE'';');

    -- Generate code to update the trx_line_count variable
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'trx_line_count := SQL%ROWCOUNT;');
    cn_debug.print_msg('insert_lines: Generated INSERT statement.', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_lines: Generated INSERT statement.');
      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Inserted '' || trx_line_count || '' records into cn_trx_lines.'');');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log,''' || procedure_name || ': Inserted '' || trx_line_count || '' records into cn_trx_lines.'');');
    cn_utils.appendcr(code);

    cn_debug.print_msg('insert_lines<<', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_lines<<');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('insert_lines: in exception handler for NO_DATA_FOUND', 1);
      fnd_file.put_line(fnd_file.Log, 'insert_lines: in exception handler for NO_DATA_FOUND');
      RETURN;
  END insert_lines;



-- Procedure Name
--   update_lines
-- Purpose
--   Generates code to update the CN_TRX_LINES table
-- History
--   17-NOV-93		Devesh Khatu		Created

  PROCEDURE update_lines (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code	IN OUT NOCOPY	cn_utils.code_type,
	x_org_id IN NUMBER) IS


  BEGIN
    l_org_id := x_org_id;
  	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** UPDATE CN_TRX_LINES ********-- ');

    cn_debug.print_msg('update_lines>>', 1);
    fnd_file.put_line(fnd_file.Log, 'update_lines>>');
    cn_debug.print_msg('update_lines: x_module_id = ' || x_module_id, 1);


    -- Generate the UPDATE statement
    cn_debug.print_msg('update_lines: Generating UPDATE statement.', 1);
    fnd_file.put_line(fnd_file.Log, 'update_lines: Generating UPDATE statement.');

    cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updating CN_TRX_LINES .'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Updating CN_TRX_LINES .'');');
    cn_utils.appendcr(code);

    IF x_event_id <> cn_global.inv_event_id THEN

      cn_utils.appindcr(code, 'UPDATE cn_trx_lines ctl');
      cn_utils.appindcr(code, '  SET');
      cn_utils.indent(code, 1);
	 cn_utils.appindcr(code, '(revenue_amount, extended_amount) = (');
	 cn_utils.appindcr(code, '  SELECT ');
	 cn_utils.appindcr(code, '      DECODE(ct.invoice_total, 0, 0, (ct.prorated_amount/ct.invoice_total) * ctl.revenue_amount),');
	 cn_utils.appindcr(code, '      DECODE(ct.invoice_total, 0, 0, (ct.prorated_amount/ct.invoice_total) * ctl.extended_amount)');
	 cn_utils.appindcr(code, '    FROM cn_trx ct');
	 cn_utils.appindcr(code, '   WHERE ctl.trx_id = ct.trx_id');
	 --Added for MOAC by Ashley
	 cn_utils.appindcr(code, '   AND ct.org_id = '||x_org_id||')');

      cn_utils.appendcr(code);
      cn_utils.unindent(code, 1);
      cn_utils.appindcr(code, 'WHERE ctl.collection_run_id = x_proc_audit_id');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, 'AND ctl.org_id = '||x_org_id||';');

      cn_utils.appendcr(code);

      END IF;		--AE 08-21-95  end of empty cursor check.


      -- Generate code to update the trx_line_update_count variable
      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'trx_line_update_count := SQL%ROWCOUNT;');
      cn_debug.print_msg('update_lines: Generated UPDATE statement.', 1);
      fnd_file.put_line(fnd_file.Log, 'update_lines: Generated UPDATE statement.');
      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updated '' || trx_line_update_count || '' cn_trx_lines.'');');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Updated '' || trx_line_update_count || '' cn_trx_lines.'');');
      cn_utils.appendcr(code);

    cn_debug.print_msg('update_lines<<', 1);
    fnd_file.put_line(fnd_file.Log, 'update_lines<<');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('update_lines: in exception handler for NO_DATA_FOUND', 1);
      fnd_file.put_line(fnd_file.Log, 'update_lines: in exception handler for NO_DATA_FOUND');
      RETURN;
  END update_lines;



-- Procedure Name
--   insert_sales_lines
-- Purpose
--   Generates code to insert into the CN_TRX_SALES_LINES table
-- History
--   17-NOV-93		Devesh Khatu		Created

  PROCEDURE insert_sales_lines (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code	IN OUT NOCOPY		cn_utils.code_type,
	x_org_id IN NUMBER) IS


    -- Declare cursor for inserting into the sales_lines table
    CURSOR sales_lines_direct_maps IS
      SELECT LOWER(destcol.name) dest_column,
             cm.expression expression
	 FROM cn_table_maps tm,
           cn_column_maps cm,
	      cn_objects destcol
      WHERE tm.mapping_type = 'INV3'
            AND cm.table_map_id = tm.table_map_id
	        AND cm.expression IS NOT NULL
	        AND cm.destination_column_id = destcol.object_id
	       -- Added for MOAC by Ashley
	        AND tm.org_id = x_org_id
	        AND cm.org_id = tm.org_id
	        AND destcol.org_id = cm.org_id

            AND destcol.name <> 'QUANTITY'         -- Fix bug 2809039
      ORDER BY destcol.name;

  BEGIN
  	l_org_id := x_org_id;
  	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** INSERT CN_TRX_SALES_LINES ********-- ');

    cn_debug.print_msg('insert_sales_lines>>', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_sales_lines>>');
      -- Initialize value of table_map_id, etc.
      -- Assumption: there is exactly 1 table at the sales credit level
      -- in each repository.

    cn_debug.print_msg('insert_sales_lines: x_module_id = ' || x_module_id, 1);
    cn_debug.print_msg('insert_sales_lines: Updating object dependencies and module object maps.', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_sales_lines: Updating object dependencies and module object maps.');

    -- Generate the insert clause
    cn_debug.print_msg('insert_sales_lines: Generating INSERT statement.', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_sales_lines: Generating INSERT statement.');

	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Inserting into CN_TRX_SALES_LINES .'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Inserting into CN_TRX_SALES_LINES .'');');
    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'INSERT INTO cn_trx_sales_lines (');
    cn_utils.indent(code, 1);
    -- Insert fixed columns first
    cn_utils.appindcr(code, 'trx_sales_line_id,');
    cn_utils.appindcr(code, 'sales_line_batch_id,');
    --Added for MOAC by Ashley
    cn_utils.appindcr(code, 'org_id,');
    cn_utils.appindcr(code, 'trx_line_id,');
    cn_utils.appindcr(code, 'trx_id,');
    cn_utils.appindcr(code, 'event_id,');
    cn_utils.appindcr(code, 'collection_run_id,');
    IF (x_event_id = cn_global.ram_event_id) THEN
       cn_utils.appindcr(code, 'adj_collection_run_id,');
       cn_utils.appindcr(code, 'created_by,');
       cn_utils.appindcr(code, 'creation_date,');
       cn_utils.appindcr(code, 'last_updated_by,');
       cn_utils.appindcr(code, 'last_update_date,');
       cn_utils.appindcr(code, 'last_update_login,');
    END IF;

    -- Insert custom columns using  sales_lines_direct_maps  cursor
    FOR s IN sales_lines_direct_maps LOOP
      cn_utils.appindcr(code, s.dest_column || ',');
    END LOOP;

    cn_utils.appindcr(code, 'quantity,');

    cn_utils.strip_prev(code, 1);    --AE 08-24-95  remove trailing comma
    cn_utils.appindcr(code, ')');
    cn_utils.unindent(code, 1);

    -- Generate the SELECT clause for the insert statement
    cn_utils.appindcr(code, 'SELECT');
    cn_utils.indent(code, 1);

    -- Select fixed columns
    cn_utils.appindcr(code, 'cn_trx_sales_lines_s.NEXTVAL,');
    cn_utils.appindcr(code, 'FLOOR(cn_trx_sales_lines_s.CURRVAL/cn_global.cls_batch_size),');
    --Added for MOAC by Ashley
    cn_utils.appindcr(code, 'ctl.org_id,');
    cn_utils.appindcr(code, 'ctl.trx_line_id,');
    cn_utils.appindcr(code, 'ctl.trx_id,');
    cn_utils.appindcr(code, 'ctl.event_id,');
    IF (x_event_id = cn_global.ram_event_id) THEN
       cn_utils.appindcr(code, 'null,');
       cn_utils.appindcr(code, 'x_proc_audit_id,');
       cn_utils.appindcr(code, 'x_created_by,');
       cn_utils.appindcr(code, 'x_creation_date,');
       cn_utils.appindcr(code, 'x_last_updated_by,');
       cn_utils.appindcr(code, 'x_last_update_date,');
       cn_utils.appindcr(code, 'x_last_update_login,');
    ELSE
       cn_utils.appindcr(code, 'x_proc_audit_id,');
    END IF;


    -- Select custom columns using  sales_lines_direct_maps  cursor.
    -- we fetch the records in the cursor in the same order as before due to
    -- the order by column_id in the cursor where clause.
    FOR s IN sales_lines_direct_maps LOOP
      cn_utils.appindcr(code, s.expression || ',');
    END LOOP;

    -- Fix bug 2809039
    --Added for R12 release
    g_cn_apply_non_rev_split := CN_SYSTEM_PARAMETERS.value('CN_NON_REVENUE_SPLIT',x_org_id);

    IF (g_cn_apply_non_rev_split = 'N') THEN
	cn_utils.appindcr(code, 'NVL(ctl.quantity, 0) * NVL(rctls.revenue_percent_split, 0)/100 ,');
    ELSE
        cn_utils.appindcr(code, '(NVL(ctl.quantity, 0) * NVL(rctls.revenue_percent_split, 0)/100) + (NVL(ctl.quantity, 0) * NVL(rctls.non_revenue_percent_split, 0)/100) ,');
    END IF;

    cn_utils.strip_prev(code, 1);	--AE 08-24-95  remove trailing comma
    cn_utils.appendcr(code);
    cn_utils.unindent(code, 1);

-- Generate FROM and WHERE clauses
    IF (x_event_id = cn_global.ram_event_id) THEN
        cn_utils.appindcr(code, ' FROM cn_trx_lines ctl, ra_cust_trx_line_salesreps rctls ');
        cn_utils.appindcr(code, 'WHERE ctl.source_trx_id = rctls.customer_trx_id ');
        --cn_utils.appindcr(code, '  AND rctls.revenue_adjustment_id is NOT NULL'); -- Added Bug : 3331479
    	-- Commented By Hithanki QA Bug 4234180
        cn_utils.appindcr(code, '  AND ctl.source_trx_line_id = rctls.customer_trx_line_id ');
        cn_utils.appindcr(code, '  AND ctl.adj_collection_run_id = x_proc_audit_id ');
        cn_utils.appindcr(code, '  AND ctl.adjusted_flag  = ''Y'' ');
        cn_utils.appindcr(code, '  AND ctl.negated_flag   = ''Y'' ');
        cn_utils.appindcr(code, '  AND ctl.collected_flag = ''N'' ');
        cn_utils.appindcr(code, '  AND ctl.event_id = cn_global.inv_event_id ');
        cn_utils.appindcr(code, '  AND ctl.adj_batch_id = x_adj_batch_id ');
        --Added for MOAC by Ashley
        cn_utils.appindcr(code, '  AND ctl.org_id = '||x_org_id );
        cn_utils.appindcr(code, '  AND rctls.org_id = ctl.org_id ');

        cn_utils.appindcr(code, '  AND ((x_ram_negate_profile = ''Y'') OR');
        cn_utils.appindcr(code, '       (x_ram_negate_profile = ''N'' AND');
        cn_utils.appindcr(code, '        NOT EXISTS ');
        cn_utils.appindcr(code, '        (SELECT 1 ');
        cn_utils.appindcr(code, '           FROM cn_trx_sales_lines ctsl ');
        cn_utils.appindcr(code, '           WHERE ctsl.source_trx_sales_line_id = rctls.cust_trx_line_salesrep_id');
	    --cn_utils.appindcr(code, '           AND  ctsl.adj_collection_run_id is NOT NULL'); -- Added Bug : 3331479
	    cn_utils.appindcr(code, '           AND  ctsl.event_id = cn_global.inv_event_id');    -- Added Bug : 3331479
	    --Added for MOAC by Ashley
	    cn_utils.appindcr(code, '           AND  ctsl.org_id = '||x_org_id||')');
        cn_utils.appindcr(code, '        )');
        cn_utils.appindcr(code, '       );');
   ELSIF (x_event_id = cn_global.inv_event_id) THEN
       cn_utils.appindcr(code, ' FROM cn_trx_lines ctl, ra_cust_trx_line_salesreps rctls');
       cn_utils.appindcr(code, 'WHERE ctl.source_trx_id = rctls.customer_trx_id');
       cn_utils.appindcr(code, '  AND ctl.source_trx_line_id = rctls.customer_trx_line_id');
       cn_utils.appindcr(code, '  AND ctl.collection_run_id = x_proc_audit_id');
       --Added for MOAC by Ashley
       cn_utils.appindcr(code, '  AND ctl.org_id = '||x_org_id);
       cn_utils.appindcr(code, '  AND rctls.org_id = ctl.org_id;');

   ELSIF (x_event_id = cn_global.pmt_event_id) THEN
	cn_utils.appindcr(code, ' FROM cn_trx_lines ctl, ra_cust_trx_line_salesreps rctls');
	cn_utils.appindcr(code, 'WHERE ctl.source_trx_id = rctls.customer_trx_id');
	cn_utils.appindcr(code, '  AND ctl.source_trx_line_id = rctls.customer_trx_line_id');
	cn_utils.appindcr(code, '  AND ctl.collection_run_id = x_proc_audit_id');
	--cn_utils.appindcr(code, '  AND rctls.revenue_adjustment_id is null');
	cn_utils.appindcr(code, '  AND (ctl.event_id = cn_global.gbk_event_id');
	--Added for MOAC by Ashley
    cn_utils.appindcr(code, '  AND ctl.org_id = '||x_org_id);
    cn_utils.appindcr(code, '  AND rctls.org_id = ctl.org_id');

	cn_utils.appindcr(code, '  AND EXISTS');
	cn_utils.appindcr(code, '      (select 1');
	cn_utils.appindcr(code, '      from  cn_trx_sales_lines rctls_in');
	cn_utils.appindcr(code, '      where rctls_in.source_trx_sales_line_id = rctls.cust_trx_line_salesrep_id');
	cn_utils.appindcr(code, '      and  rctls_in.event_id = cn_global.cbk_event_id');
	--Added for MOAC by Ashley
	cn_utils.appindcr(code, '      and  rctls_in.org_id = '||x_org_id||')');

	cn_utils.appindcr(code, '  OR (ctl.event_id = cn_global.pmt_event_id and rctls.revenue_adjustment_id is null));');
   ELSE
	cn_utils.appindcr(code, ' FROM cn_trx_lines ctl, ra_cust_trx_line_salesreps rctls');
	cn_utils.appindcr(code, 'WHERE ctl.source_trx_id = rctls.customer_trx_id');
	cn_utils.appindcr(code, '  AND ctl.source_trx_line_id = rctls.customer_trx_line_id');
	--Added for MOAC by Ashley
	cn_utils.appindcr(code, '  AND ctl.org_id = '||x_org_id);
	cn_utils.appindcr(code, '  AND rctls.org_id = ctl.org_id');

	cn_utils.appindcr(code, '  AND ctl.collection_run_id = x_proc_audit_id;');
	--cn_utils.appindcr(code, '  AND rctls.revenue_adjustment_id is null;');
  /*ELSE
       cn_utils.appindcr(code, ' FROM cn_trx_lines ctl, ra_cust_trx_line_salesreps rctls');
       cn_utils.appindcr(code, 'WHERE ctl.source_trx_id = rctls.customer_trx_id');
       cn_utils.appindcr(code, '  AND ctl.source_trx_line_id = rctls.customer_trx_line_id');
       cn_utils.appindcr(code, '  AND ctl.collection_run_id = x_proc_audit_id');
       --cn_utils.appindcr(code, '  AND rctls.revenue_adjustment_id is null;');
       cn_utils.appindcr(code, '  AND (ctl.event_id <> cn_global.pmt_event_id ');
       cn_utils.appindcr(code, '  AND EXISTS');
       cn_utils.appindcr(code, '  (SELECT 1');
       cn_utils.appindcr(code, '  FROM cn_trx_sales_lines rctls_in');
       cn_utils.appindcr(code, '  WHERE rctls_in.source_trx_sales_line_id = rctls.cust_trx_line_salesrep_id');
       cn_utils.appindcr(code, '  AND rctls_in.event_id = cn_global.inv_event_id)');
       cn_utils.appindcr(code, '  OR (ctl.event_id = cn_global.pmt_event_id AND');
       cn_utils.appindcr(code, '  rctls.revenue_adjustment_id IS NULL))');
       cn_utils.appindcr(code, '  AND rctls.salesrep_id <> 0;');  */
    END IF; --IF (x_event_id = cn_global.ram_event_id)

    -- Update trx_sales_line_count variable
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'trx_sales_line_count := SQL%ROWCOUNT;');
    cn_debug.print_msg('insert_sales_lines: Generated INSERT statement.', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_sales_lines: Generated INSERT statement.');
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Inserted '' || trx_sales_line_count || '' records into cn_trx_sales_lines.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Inserted '' || trx_sales_line_count || '' records into cn_trx_sales_lines.'');');
    cn_utils.appendcr(code);

    cn_debug.print_msg('insert_sales_lines<<', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_sales_lines<<');

    IF (x_event_id = cn_global.ram_event_id) THEN
        cn_utils.appindcr(code, 'UPDATE cn_trx_lines');
        cn_utils.appindcr(code, '   SET collected_flag = ''Y''');
        cn_utils.appindcr(code, ' WHERE adjusted_flag  = ''Y'' ');
        --Added for MOAC by Ashley
        cn_utils.appindcr(code, '   AND org_id = '||x_org_id);
        cn_utils.appindcr(code, '   AND negated_flag   = ''Y'' ');
        cn_utils.appindcr(code, '   AND collected_flag = ''N'' ');
        cn_utils.appindcr(code, '   AND event_id = cn_global.inv_event_id ');
        cn_utils.appindcr(code, '   AND adj_batch_id = x_adj_batch_id;');
        cn_utils.appendcr(code);
        cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updated collected_flag in cn_trx_lines.'');');
        cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Updated collected_flag in cn_trx_lines.'');');
    END IF; --IF (x_event_id = cn_global.ram_event_id)

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('insert_sales_lines: in exception handler for NO_DATA_FOUND', 1);
      fnd_file.put_line(fnd_file.Log, 'insert_sales_lines: in exception handler for NO_DATA_FOUND');
      RETURN;
  END insert_sales_lines;



-- Procedure Name
--   update_sales_lines
-- Purpose
--   Generates code to update the CN_TRX_SALES_LINES table
-- History
--   17-NOV-93		Devesh Khatu		Created

  PROCEDURE update_sales_lines (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code	IN OUT NOCOPY		cn_utils.code_type,
	x_org_id IN NUMBER) IS



  BEGIN
  	l_org_id := x_org_id;
  	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** UPDATE CN_TRX_SALES_LINES ********-- ');

    cn_debug.print_msg('update_sales_lines>>', 1);
    fnd_file.put_line(fnd_file.Log, 'update_sales_lines>>');
    cn_debug.print_msg('update_sales_lines: x_module_id = ' || x_module_id, 1);

    cn_debug.print_msg('update_sales_lines: Generating UPDATE statement.', 1);
    fnd_file.put_line(fnd_file.Log, 'update_sales_lines: Generating UPDATE statement.');

	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updating CN_TRX_SALES_LINES .'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Updating CN_TRX_SALES_LINES .'');');
    cn_utils.appendcr(code);

    -- Generate the UPDATE statement
    cn_utils.appindcr(code, 'UPDATE cn_trx_sales_lines ctsl');
    cn_utils.appindcr(code, '   SET');
    cn_utils.indent(code, 1);

    -- Prorate Amount, Revenue_amount_split and Non_revenue_amount_split
    -- columns for all trx types except invoices.
    IF ((x_event_id <> cn_global.inv_event_id) and
        (x_event_id <> cn_global.ram_event_id))  THEN
      cn_utils.appindcr(code, '(amount, revenue_amount_split, non_revenue_amount_split) = (');
      cn_utils.appindcr(code, '  SELECT ');
      cn_utils.appindcr(code, '      DECODE(ct.invoice_total, 0, 0, (ct.prorated_amount/ct.invoice_total) * ctsl.amount),');
      cn_utils.appindcr(code, '      DECODE(ct.invoice_total, 0, 0, (ct.prorated_amount/ct.invoice_total) * ctsl.revenue_amount_split),');
      cn_utils.appindcr(code, '      DECODE(ct.invoice_total, 0, 0, (ct.prorated_amount/ct.invoice_total) * ctsl.non_revenue_amount_split)');
      cn_utils.appindcr(code, '    FROM cn_trx ct');
      cn_utils.appindcr(code, '   WHERE ct.trx_id = ctsl.trx_id');
      --Added by Ashley for MOAC
      cn_utils.appindcr(code, '   AND ct.org_id = '||x_org_id||'),');

      cn_utils.appendcr(code);
    END IF;

    cn_utils.appindcr(code, '(processed_date, rollup_date) = (');
    cn_utils.appindcr(code, '  SELECT ct.processed_date, ct.rollup_date');
    cn_utils.appindcr(code, '    FROM cn_trx ct');
    cn_utils.appindcr(code, '   WHERE ct.trx_id = ctsl.trx_id');
    --Added by Ashley for MOAC
    cn_utils.appindcr(code, '   AND ct.org_id = '||x_org_id||'),');

    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'processed_period_id = (');
    cn_utils.appindcr(code, '  SELECT cp.period_id');
    cn_utils.appindcr(code, '    FROM cn_trx ct, cn_acc_period_statuses_v cp');
    cn_utils.appindcr(code, '   WHERE ct.trx_id = ctsl.trx_id');
    cn_utils.appindcr(code, '     AND ct.processed_date BETWEEN cp.start_date AND cp.end_date');
    --Added for MOAC by Ashley
    cn_utils.appindcr(code, '     AND ct.org_id = '||x_org_id);
    cn_utils.appindcr(code, '     AND cp.org_id = ct.org_id),');

    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'rollup_period_id = (');
    cn_utils.appindcr(code, '  SELECT cp.period_id');
    cn_utils.appindcr(code, '    FROM cn_trx ct, cn_acc_period_statuses_v cp');
    cn_utils.appindcr(code, '   WHERE ct.trx_id = ctsl.trx_id');
    cn_utils.appindcr(code, '     AND ct.rollup_date BETWEEN cp.start_date AND cp.end_date');
    --Added for MOAC by Ashley
    cn_utils.appindcr(code, '     AND ct.org_id = '||x_org_id);
    cn_utils.appindcr(code, '     AND cp.org_id = ct.org_id)');

    cn_utils.appendcr(code);
    cn_utils.unindent(code, 1);

    IF (x_event_id = cn_global.ram_event_id) THEN
      cn_utils.appindcr(code, 'WHERE ctsl.adj_collection_run_id = x_proc_audit_id');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, 'AND ctsl.org_id = '||x_org_id||';');
    ELSE
      cn_utils.appindcr(code, 'WHERE ctsl.collection_run_id = x_proc_audit_id');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, 'AND ctsl.org_id = '||x_org_id||';');
    END IF;

      -- For clawbacks only, negate the amounts
    IF (x_event_id = cn_global.cbk_event_id)	THEN
	 cn_utils.appindcr(code, 'UPDATE cn_trx_sales_lines ctsl');
	 cn_utils.appindcr(code, '   SET');
	 cn_utils.indent(code, 1);
	 cn_utils.appindcr(code, 'amount = amount * -1,');
	 cn_utils.appindcr(code, 'revenue_amount_split = revenue_amount_split * -1,');
	 cn_utils.appindcr(code, 'non_revenue_amount_split = non_revenue_amount_split * -1');
	 cn_utils.unindent(code, 1);
	 cn_utils.appindcr(code, 'WHERE ctsl.collection_run_id = x_proc_audit_id');
	 --Added for MAOC By Ashley
	 cn_utils.appindcr(code, 'AND ctsl.org_id = '||x_org_id||';');
    END IF;


    -- Update trx_sales_line_update_count variable
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'trx_sales_line_update_count := SQL%ROWCOUNT;');
    cn_debug.print_msg('update_sales_lines: Generated UPDATE statement.', 1);
    fnd_file.put_line(fnd_file.Log, 'update_sales_lines: Generated UPDATE statement.');
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updated '' || trx_sales_line_update_count || '' records in cn_trx_sales_lines.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Updated '' || trx_sales_line_update_count || '' records in cn_trx_sales_lines.'');');
    cn_utils.appendcr(code);

    cn_debug.print_msg('update_sales_lines<<', 1);
    fnd_file.put_line(fnd_file.Log, 'update_sales_lines<<');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('update_sales_lines: in exception handler for NO_DATA_FOUND', 1);
      fnd_file.put_line(fnd_file.Log, 'update_sales_lines: in exception handler for NO_DATA_FOUND');
      RETURN;
  END update_sales_lines;



-- Procedure Name
--   update_invoice_total
-- Purpose
--   Updates the invoice_total column in the trx headers table
-- History
--   15-JUN-93		Devesh Khatu		Created

  PROCEDURE update_invoice_total (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	code	IN OUT NOCOPY		cn_utils.code_type,
	x_org_id IN NUMBER) IS


  BEGIN
  	l_org_id := x_org_id;
  	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** UPDATE INVOICE TOTAL ********-- ');

      -- Generate the update statement for updating invoice_total.
      -- This could not be done when we updated cn_trx earlier since we had not
      -- collected lines then
      cn_debug.print_msg('update_invoice_total: Generating UPDATE statement.', 1);
      fnd_file.put_line(fnd_file.Log, 'update_invoice_total: Generating UPDATE statement.');

	  cn_utils.set_org_id(p_org_id => l_org_id);
      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updating CN_TRX invoice_total.'');');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Updating CN_TRX invoice_total.'');');
      cn_utils.appindcr(code, '-- This could not be done when we updated cn_trx earlier ');
      cn_utils.appindcr(code, '-- since we had not collected lines then');
      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'UPDATE cn_trx ct');
      cn_utils.appindcr(code, '   SET invoice_total  = (');
      cn_utils.appindcr(code, '         SELECT SUM(ctl.extended_amount)');
      cn_utils.appindcr(code, '           FROM cn_trx_lines ctl');
      cn_utils.appindcr(code, '          WHERE ctl.trx_id = ct.trx_id');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, '          AND ctl.org_id = '||x_org_id||')');

      cn_utils.appindcr(code, ' WHERE ct.collection_run_id = x_proc_audit_id');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, ' AND ct.org_id = '||x_org_id||';');

      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Updated cn_trx invoice_total.'');');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Updated cn_trx invoice_total.'');');
      cn_utils.appendcr(code);
      cn_debug.print_msg('update_invoice_total: Generated UPDATE statement.', 1);
      fnd_file.put_line(fnd_file.Log, 'update_invoice_total: Generated UPDATE statement.');

  END update_invoice_total;


-- Procedure Name
--   insert_comm_lines
-- Purpose
--   Generates code to insert into the CN_COMM_LINES_API table
-- History
--   08-29-95		Amy Erickson		Created

  PROCEDURE insert_comm_lines (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	x_module_id		cn_modules.module_id%TYPE,
	x_event_id		cn_events.event_id%TYPE,
	code	IN OUT NOCOPY		cn_utils.code_type,
	x_org_id IN NUMBER) IS

    x_row_count NUMBER := 0;
    x_rct_alias 		cn_obj_tables_v.alias%TYPE;
    x_rctl_alias 		cn_obj_tables_v.alias%TYPE;
    x_rctls_alias 		cn_obj_tables_v.alias%TYPE;
    x_cnt_alias 		cn_obj_tables_v.alias%TYPE;


    -- Cursor which finds all user-defined direct mappings for
    -- receivables. These are actually implemented as a post-insert
    -- update operation

    CURSOR header_direct_maps IS
      SELECT LOWER(destcol.name) dest_column,
	        ccm.expression
	 FROM cn_column_maps ccm,
		 cn_table_maps tm,
	      cn_objects destcol
      WHERE tm.mapping_type = 'AR'
		  AND ccm.table_map_id = tm.table_map_id
		  AND (ccm.column_map_id > 0     -- New mappings to Attribute columns
			  OR ccm.modified = 'Y')    -- User has modified a seeded mapping
	       AND ccm.expression IS NOT NULL
	       AND ccm.calc_ext_table_id IS NULL  -- Not a foreign-key indirect mapping
	       AND ccm.update_clause IS NULL      -- Not a free-form indirect mapping
	       AND destcol.object_id = ccm.destination_column_id
	       AND destcol.table_id = -1008       -- cn_comm_lines_api (exclude any old mappings to cn_trx etc.)
	       -- Added for MOAC by Ashley
	        AND tm.org_id = x_org_id
	        AND ccm.org_id = tm.org_id
	        AND destcol.org_id = ccm.org_id
      ORDER BY destcol.name;

  BEGIN
  	l_org_id := x_org_id;
  	cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** INSERT CN_COMM_LINES_API ********-- ');

    cn_debug.print_msg('insert_comm_lines_api>>', 1);
    fnd_file.put_line(fnd_file.Log, 'insert_comm_lines_api>>');

      -- Generate the insert statement.

      cn_debug.print_msg('insert_sales_lines: Generating INSERT statement.', 1);
      fnd_file.put_line(fnd_file.Log, 'insert_sales_lines: Generating INSERT statement.');

	  cn_utils.set_org_id(p_org_id => l_org_id);
      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Inserting into CN_COMM_LINES_API .'');');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Inserting into CN_COMM_LINES_API .'');');
      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'INSERT INTO  cn_comm_lines_api (');
      cn_utils.indent(code, 1);
      cn_utils.appindcr(code, 'comm_lines_api_id,');
      cn_utils.appindcr(code, 'conc_batch_id,');        --AE 01-18-96
      cn_utils.appindcr(code, 'process_batch_id,');     --AE 01-18-96
      cn_utils.appindcr(code, 'trx_type,');
      cn_utils.appindcr(code, 'exchange_rate,');               --AE 02-15-96
      cn_utils.appindcr(code, 'transaction_currency_code,');   --AE 02-23-96
      cn_utils.appindcr(code, 'transaction_amount,');
      cn_utils.appindcr(code, 'salesrep_id,');
      cn_utils.appindcr(code, 'revenue_class_id,');
      cn_utils.appindcr(code, 'processed_date,');
      cn_utils.appindcr(code, 'processed_period_id,');
      cn_utils.appindcr(code, 'rollup_date,');
--      cn_utils.appindcr(code, 'rollup_period_id,'); No longer needed - dmaskell 26-Nov-99
      cn_utils.appindcr(code, 'source_doc_id,');
      cn_utils.appindcr(code, 'source_doc_type,');
      cn_utils.appindcr(code, 'revenue_type,');
      cn_utils.appindcr(code, 'trx_id,');
      cn_utils.appindcr(code, 'trx_line_id,');
      cn_utils.appindcr(code, 'trx_sales_line_id,');
      cn_utils.appindcr(code, 'source_trx_number,');
      cn_utils.appindcr(code, 'source_trx_id,');
      cn_utils.appindcr(code, 'source_trx_line_id,');
      cn_utils.appindcr(code, 'source_trx_sales_line_id,');
      cn_utils.appindcr(code, 'line_number,');
      cn_utils.appindcr(code, 'quantity,');
      cn_utils.appindcr(code, 'customer_id,');
      cn_utils.appindcr(code, 'inventory_item_id,');
      cn_utils.appindcr(code, 'order_number,');
      cn_utils.appindcr(code, 'booked_date,');
      cn_utils.appindcr(code, 'invoice_number,');
      cn_utils.appindcr(code, 'invoice_date,');
      cn_utils.appindcr(code, 'split_pct,');
      cn_utils.appindcr(code, 'created_by,');
      cn_utils.appindcr(code, 'creation_date,');
      cn_utils.appindcr(code, 'last_updated_by,');
      cn_utils.appindcr(code, 'last_update_date,');
      cn_utils.appindcr(code, 'last_update_login,');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, 'org_id,');

      cn_utils.strip_prev(code, 1);	-- remove trailing comma
      cn_utils.appindcr(code, ')');
      cn_utils.unindent(code, 1);


      -- Generate the SELECT clause for the insert statement

      IF (x_event_id = cn_global.ram_event_id) THEN
          cn_utils.appindcr(code, 'SELECT /*+ ordered index(CTSL CN_TRX_SALES_LINES_N3) index(CTL CN_TRX_LINES_N4) */');
      ELSE
         cn_utils.appindcr(code, 'SELECT /*+ ordered index(CTSL CN_TRX_SALES_LINES_N2) index(CTL CN_TRX_LINES_N3) */');
      END IF;

      cn_utils.indent(code, 1);

      cn_utils.appindcr(code, 'cn_comm_lines_api_s.NEXTVAL,');
      cn_utils.appindcr(code, 'x_conc_program_id,');        --AE 01-18-96
      cn_utils.appindcr(code, 'x_proc_audit_id,');          --AE 01-18-96
      cn_utils.appindcr(code, 'ct.trx_type,');
      cn_utils.appindcr(code, 'ct.exchange_rate,');             --AE 02-15-96
      cn_utils.appindcr(code, 'ct.transaction_currency_code,'); --AE 02-23-96
      cn_utils.appindcr(code, 'ctsl.amount,');
      cn_utils.appindcr(code, 'ctsl.salesrep_id,');
      cn_utils.appindcr(code, 'ctsl.revenue_class_id,');
      cn_utils.appindcr(code, 'ctsl.processed_date,');
      cn_utils.appindcr(code, 'ctsl.processed_period_id,');
      cn_utils.appindcr(code, 'ctsl.rollup_date,');
--cn_utils.appindcr(code, 'ctsl.rollup_period_id,'); --no longer needed - dmaskell 26-Nov-99
      cn_utils.appindcr(code, 'ctsl.source_trx_sales_line_id,');
      cn_utils.appindcr(code, '''AR'',');
      cn_utils.appindcr(code, 'DECODE(ctsl.revenue_amount_percent, 0, DECODE(ctsl.non_revenue_amount_percent, 0, NULL, ''NONREVENUE''), DECODE(ctsl.non_revenue_amount_percent, 0, ''REVENUE'', NULL)),');
      cn_utils.appindcr(code, 'ct.trx_id,');
      cn_utils.appindcr(code, 'ctl.trx_line_id,');
      cn_utils.appindcr(code, 'ctsl.trx_sales_line_id,');
      cn_utils.appindcr(code, 'ct.source_trx_number,');
      cn_utils.appindcr(code, 'ct.source_trx_id,');
      cn_utils.appindcr(code, 'ctl.source_trx_line_id,');
      cn_utils.appindcr(code, 'ctsl.source_trx_sales_line_id,');
      cn_utils.appindcr(code, 'ctl.line_number,');
      cn_utils.appindcr(code, 'ctsl.quantity,');
      cn_utils.appindcr(code, 'ct.sold_to_customer_id,');
      cn_utils.appindcr(code, 'ctl.inventory_id,');
      cn_utils.appindcr(code, 'null,');
      cn_utils.appindcr(code, 'null,');
      cn_utils.appindcr(code, 'ct.source_trx_number,');
      cn_utils.appindcr(code, 'ct.trx_date,');
      cn_utils.appindcr(code, 'DECODE(ctsl.revenue_amount_percent, 0, ctsl.non_revenue_amount_percent, ctsl.revenue_amount_percent),');
      cn_utils.appindcr(code, 'x_created_by,');
      cn_utils.appindcr(code, 'x_creation_date,');
      cn_utils.appindcr(code, 'x_last_updated_by,');
      cn_utils.appindcr(code, 'x_last_update_date,');
      cn_utils.appindcr(code, 'x_last_update_login,');
      --Added for MOAC by Ashley
      cn_utils.appindcr(code, 'ct.org_id,');

      cn_utils.strip_prev(code, 1);	-- remove trailing comma
      cn_utils.appendcr(code);
      cn_utils.unindent(code, 1);

      -- Generate FROM clause
      cn_utils.appindcr(code, ' FROM cn_trx_sales_lines  ctsl,');
      cn_utils.appindcr(code, '      cn_trx_lines  ctl,');
      cn_utils.appindcr(code, '      cn_trx  ct');

      -- Generate WHERE clause
      IF (x_event_id = cn_global.ram_event_id) THEN
        cn_utils.appindcr(code, 'WHERE ct.trx_id = ctsl.trx_id' );
        cn_utils.appindcr(code, '  AND ctl.trx_line_id = ctsl.trx_line_id' );
        cn_utils.appindcr(code, '  AND ct.adj_collection_run_id = x_proc_audit_id' );
        cn_utils.appindcr(code, '  AND ctl.adj_collection_run_id = x_proc_audit_id' );
        cn_utils.appindcr(code, '  AND ctsl.adj_collection_run_id = x_proc_audit_id' );
       --Added for MOAC by Ashley
        cn_utils.appindcr(code, '  AND ct.org_id = '||x_org_id);
        cn_utils.appindcr(code, '  AND ctl.org_id = ct.org_id' );
        cn_utils.appindcr(code, '  AND ctsl.org_id = ctl.org_id;' );

      ELSE
        cn_utils.appindcr(code, 'WHERE ct.trx_id = ctsl.trx_id' );
        cn_utils.appindcr(code, '  AND ctl.trx_line_id = ctsl.trx_line_id');
        cn_utils.appindcr(code, '  AND ct.collection_run_id = x_proc_audit_id');
        cn_utils.appindcr(code, '  AND ctl.collection_run_id = x_proc_audit_id');
        cn_utils.appindcr(code, '  AND ctsl.collection_run_id = x_proc_audit_id');
       --Added for MOAC by Ashley
        cn_utils.appindcr(code, '  AND ct.org_id = '||x_org_id);
        cn_utils.appindcr(code, '  AND ctl.org_id = ct.org_id' );
        cn_utils.appindcr(code, '  AND ctsl.org_id = ctl.org_id;');
      END IF;

      cn_utils.appendcr(code);

      -- Update comm_lines_api_count variable
      cn_utils.appendcr(code);
      cn_utils.appindcr(code, 'comm_lines_api_count := SQL%ROWCOUNT;');

      cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': Inserted '' || comm_lines_api_count || '' records into CN_COMM_LINES_API.'');');
      cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': Inserted '' || comm_lines_api_count || '' records into CN_COMM_LINES_API.'');');
      cn_utils.appendcr(code);


      -- Update columns populated by user-defined DIRECT mappings. We do this with a query
	 -- which joins the cn_comm_lines_api table row back to the AR direct tables
	 -- (ra_customer_trx etc.)

      cn_utils.appindcr(code, '--*** Update columns populated by user-defined DIRECT mappings');

	 -- Check first for empty cursor

	 x_row_count := 0;
      FOR i IN header_direct_maps LOOP
	     x_row_count := SQL%ROWCOUNT;
		IF x_row_count > 0 THEN EXIT;
		END IF;
      END LOOP;

	 IF x_row_count > 0 THEN  --cursor was not empty

	     -- Get aliases of join tables

	     SELECT LOWER(NVL(alias,name)) INTO x_cnt_alias
		 	FROM cn_obj_tables_v
			WHERE name = 'CN_NOT_TRX' AND org_id = x_org_id; --Added for MOAC by Ashley

		 SELECT LOWER(NVL(alias,name)) INTO x_rct_alias
		 	FROM cn_obj_tables_v
		 	WHERE name = 'RA_CUSTOMER_TRX' AND org_id = x_org_id; --Added for MOAC by Ashley

	     SELECT LOWER(NVL(alias,name)) INTO x_rctl_alias
		 	FROM cn_obj_tables_v
		 	WHERE name = 'RA_CUSTOMER_TRX_LINES' AND org_id = x_org_id; --Added for MOAC by Ashley

	     SELECT LOWER(NVL(alias,name)) INTO x_rctls_alias
		 	FROM cn_obj_tables_v
		 	WHERE name = 'RA_CUST_TRX_LINE_SALESREPS' AND org_id = x_org_id; --Added for MOAC by Ashley

          cn_utils.appindcr(code, 'UPDATE cn_comm_lines_api api');
          cn_utils.appindcr(code, 'SET');
          cn_utils.indent(code, 1);
	     cn_utils.appindcr(code, '(');
	     cn_utils.appindcr(code, '--*** Direct Mapping Destination Columns');
          FOR i IN header_direct_maps LOOP
	         cn_utils.appindcr(code, i.dest_column || ',');
          END LOOP;
          cn_utils.strip_prev(code, 1);  -- remove trailing comma

	     cn_utils.appindcr(code, ') = (');
	     cn_utils.indent(code, 1);
	     cn_utils.appindcr(code, 'SELECT');
	     cn_utils.indent(code, 1);

	     cn_utils.appindcr(code, '--*** Direct Mapping Source Expressions');
          FOR i IN header_direct_maps LOOP
	         cn_utils.appindcr(code, i.expression || ',');
          END LOOP;
          cn_utils.unindent(code, 1);
	     cn_utils.strip_prev(code, 1);	-- remove trailing comma

          cn_utils.appendcr(code);
          cn_utils.appindcr(code, 'FROM ra_customer_trx ' || x_rct_alias || ',');
          cn_utils.appindcr(code, '     ra_customer_trx_lines ' || x_rctl_alias || ',');
          cn_utils.appindcr(code, '     ra_cust_trx_line_salesreps ' || x_rctls_alias);
          cn_utils.appindcr(code, 'WHERE '||x_rct_alias||'.customer_trx_id = api.source_trx_id');
          cn_utils.appindcr(code, '      AND '||x_rctls_alias||'.cust_trx_line_salesrep_id = api.source_doc_id');
          cn_utils.appindcr(code, '      AND '||x_rctl_alias||'.customer_trx_line_id = '||x_rctls_alias||'.customer_trx_line_id');
          --Added for MOAC by Ashley
          cn_utils.appindcr(code, '      AND '||x_rct_alias||'.org_id = '||x_org_id);
          cn_utils.appindcr(code, '      AND '||x_rctl_alias||'.org_id = '||x_rct_alias||'.org_id');
          cn_utils.appindcr(code, '      AND '||x_rctls_alias||'.org_id = '||x_rctl_alias||'.org_id)');

          cn_utils.appendcr(code);

          cn_utils.unindent(code, 3);
          cn_utils.appindcr(code, 'WHERE api.process_batch_id = x_proc_audit_id');
          --Added by Ashley for MOAC
          cn_utils.appindcr(code, 'AND api.org_id = '||x_org_id||';');

          cn_utils.appendcr(code);
          cn_utils.appindcr(code, 'comm_lines_api_update_count := SQL%ROWCOUNT;');

          cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || ': For user DIRECT mappings, updated '' || comm_lines_api_update_count || '' records in CN_COMM_LINES_API.'');');
          cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''' || procedure_name || ': For user DIRECT mappings, updated '' || comm_lines_api_update_count || '' records in CN_COMM_LINES_API.'');');
          cn_utils.appendcr(code);
      END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('insert_comm_lines: in exception handler for NO_DATA_FOUND', 1);
      fnd_file.put_line(fnd_file.Log, 'insert_comm_lines: in exception handler for NO_DATA_FOUND');
      RETURN;
  END insert_comm_lines;

END cn_collection_ar_gen;


/
