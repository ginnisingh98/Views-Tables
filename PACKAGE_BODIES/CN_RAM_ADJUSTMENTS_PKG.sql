--------------------------------------------------------
--  DDL for Package Body CN_RAM_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RAM_ADJUSTMENTS_PKG" AS
	-- $Header: cnvramb.pls 120.12 2008/03/18 19:35:47 fmburu ship $


	  PROCEDURE identify (
		x_start_period	cn_periods.period_id%TYPE,
		x_end_period	cn_periods.period_id%TYPE,
		debug_pipe	VARCHAR2 DEFAULT NULL,
		debug_level	NUMBER	 DEFAULT NULL,
	    x_org_id NUMBER ) IS


	    --   Join cn_not_trx and ar_revenue_adjustments to get the customer_trx_id
	    --   of the transactions (header level) which have been RAM-adjusted after
	    --   last collection run within the interested period.

	    --   Note : the application_date and last_collected_date used in the where
	    --   clause contain timestamp. Do not use 'trunc' so that the same adjustment
	    --   won't be handled again when run RAM Collection again on the same day.

	    --	 Note : the "within interested period" condition has been changed to use
	    --   the period when the adjustments was made, not the original transaction
	    --   processed date (GL date). This is the requirement changed on 05/08/2002

	    CURSOR adj_cursor(p_start_date DATE, p_end_date DATE) IS
	    select distinct
		   cnt.not_trx_id,
		   ara.customer_trx_id,
		   ara.from_cust_trx_line_id,
		   ara.from_inventory_item_id,
		   ara.from_category_id,
		   ara.line_selection_mode
	    from cn_not_trx cnt, ar_revenue_adjustments ara
	    where
	    nvl(cnt.last_collected_date, cnt.notified_date) <= ara.application_date and
	    cnt.collected_flag = 'Y' and                                -- has been collected before
	    cnt.source_doc_type = 'AR' and                              -- AR collection
	    cnt.event_id = cn_global.inv_event_id and                   -- INV/CM/DM collection
	    cnt.source_trx_id = ara.customer_trx_id
	--  cnt.processed_date between p_start_date and p_end_date  -- within interested period
	    AND cnt.org_id = x_org_id   -- MOAC Changes made by Ashley
	    AND ara.org_id = cnt.org_id -- MOAC Changes made by Ashley
	    AND trunc(ara.application_date) between p_start_date and p_end_date    -- within interested period
	    order by ara.customer_trx_id, line_selection_mode;

	    x_trx_identified_count      NUMBER := 0;
	    x_proc_audit_id             NUMBER;
	    x_start_date	        DATE;
	    x_end_date		        DATE;
	    x_rowid		        ROWID;
	    x_last_A_customer_trx_id    NUMBER;
	    l_sys_batch_size NUMBER;

	    CURSOR batch_size IS SELECT system_batch_size FROM cn_repositories WHERE org_id = x_org_id;


	  BEGIN
	    IF (debug_pipe IS NOT NULL) THEN
	       cn_debug.init_pipe(debug_pipe, debug_level);
	    END IF;
	    cn_debug.print_msg('>>identify RAM adjustments', 1);
	    cn_message_pkg.debug('identify RAM adjustments>>');
	    fnd_file.put_line(fnd_file.Log, 'identify RAM adjustments>>');

	    x_proc_audit_id := NULL;	-- Will get a value in the call below
	    cn_process_audits_pkg.insert_row(x_rowid, x_proc_audit_id, NULL,'RAMADJ', 'Identify RAM adjustments', NULL, NULL, NULL, NULL, NULL, SYSDATE, NULL, x_org_id);

	    cn_periods_api.set_dates(x_start_period,
				     x_end_period,
				     x_org_id,
				     x_start_date,
				     x_end_date);

	    cn_message_pkg.debug('identify RAM adjustments: identifing adjustments for transactions from '||x_start_date ||' to '||x_end_date ||'.');
	    fnd_file.put_line(fnd_file.Log, 'identify RAM adjustments: identifing adjustments for transactions from '||x_start_date ||' to '||x_end_date ||'.');

	    OPEN batch_size;
	    FETCH batch_size INTO l_sys_batch_size;
	    CLOSE batch_size;


	    --  For each adjustments (distinct on Not_trx_id, Header_id, Line_id, Item_id,
	    --  Category_id, and mode), which has been identified in ar_revenue_adjustments
	    --  table, figure out the trx_line_id of the corresponding transaction lines
	    --  that got adjusted and set the flags.

	    FOR adj IN adj_cursor(x_start_date, x_end_date) LOOP

		x_trx_identified_count := x_trx_identified_count + 1;

		-- line_selection_mode = ('A','C','I','S')

		-- line_selection_mode = 'A' (All lines)
		-- Adjustment was applied to all lines of the transactions.
		if (adj.line_selection_mode = 'A') then

		    update cn_trx_lines
		       set adjusted_flag  = 'Y',
			   negated_flag   = 'N',
			   collected_flag = 'N',
			   adj_batch_id = FLOOR(x_trx_identified_count/l_sys_batch_size)
		     where trx_line_id in (
			     select ctl.trx_line_id
			     from cn_not_trx cnt, cn_trx ct, cn_trx_lines ctl
			     where cnt.not_trx_id = adj.not_trx_id and
				   ct.not_trx_id = cnt.not_trx_id and
				   ctl.trx_id = ct.trx_id and
				   cnt.source_trx_id = adj.customer_trx_id and
				   ct.source_trx_id = cnt.source_trx_id
				   AND cnt.org_id = x_org_id    -- MOAC Changes made by Ashley
				   AND ct.org_id = cnt.org_id -- MOAC Changes made by Ashley
				   AND ctl.org_id = ct.org_id -- MOAC Changes made by Ashley
				   )
			     AND org_id = x_org_id; -- MOAC Changes made by Ashley

		     x_last_A_customer_trx_id := adj.customer_trx_id;

		else -- line_select_mode = 'C', 'I', or 'S'

		    if (adj.customer_trx_id = x_last_A_customer_trx_id) then
		       -- no need to handle S I C cases if A (all lines)
		       -- for the same customer_trx_id has been done before.
		       null;
		    else

		       -- line_selection_mode = 'S' (Specific line)
		       -- Adjustment was applied to a specific line only.
		       if (adj.line_selection_mode = 'S') then

			     update cn_trx_lines
				set adjusted_flag  = 'Y',
				    negated_flag   = 'N',
				    collected_flag = 'N',
				    adj_batch_id = FLOOR(x_trx_identified_count/l_sys_batch_size)
			     where  trx_line_id in (
					 select ctl.trx_line_id
					 from cn_not_trx cnt, cn_trx ct, cn_trx_lines ctl
					 where cnt.not_trx_id = adj.not_trx_id and
					       ct.not_trx_id = cnt.not_trx_id and
					       ctl.trx_id = ct.trx_id and
					       cnt.source_trx_id = adj.customer_trx_id and
					       ct.source_trx_id = cnt.source_trx_id and
					       ctl.source_trx_line_id = adj.from_cust_trx_line_id
					       AND cnt.org_id = x_org_id    -- MOAC Changes made by Ashley
					       AND ct.org_id = cnt.org_id -- MOAC Changes made by Ashley
					       AND ctl.org_id = ct.org_id -- MOAC Changes made by Ashley

					  )
			    AND org_id = x_org_id;  -- MOAC Changes made by Ashley
		       end if;


		       -- line_selection_mode = 'I' (Inventory item)
		       -- Adjustment was applied to all lines with a specific inventory item.
		       if (adj.line_selection_mode = 'I') then

			     update cn_trx_lines
				set adjusted_flag  = 'Y',
				    negated_flag   = 'N',
				    collected_flag = 'N',
				    adj_batch_id = FLOOR(x_trx_identified_count/l_sys_batch_size)
			     where  trx_line_id in (
					 select ctl.trx_line_id
					 from cn_not_trx cnt, cn_trx ct, cn_trx_lines ctl
					 where cnt.not_trx_id = adj.not_trx_id and
					       ct.not_trx_id = cnt.not_trx_id and
					       ctl.trx_id = ct.trx_id and
					       cnt.source_trx_id = adj.customer_trx_id and
					       ct.source_trx_id = cnt.source_trx_id and
					       ctl.inventory_id = adj.from_inventory_item_id
					       AND cnt.org_id = x_org_id    -- MOAC Changes made by Ashley
					       AND ct.org_id = cnt.org_id -- MOAC Changes made by Ashley
					       AND ctl.org_id = ct.org_id -- MOAC Changes made by Ashley

					  )
			    AND org_id = x_org_id;  -- MOAC Changes made by Ashley
		       end if;




		       -- line_selection_mode = 'C' (item Category)
		       -- Adjustment was applied to all lines with items that belong to a certain category.
		       if (adj.line_selection_mode = 'C') THEN
			     --
			     -- rewrite the update statement for performance issue
			     --
			     --old statement
			     update cn_trx_lines
				set adjusted_flag  = 'Y',
				    negated_flag   = 'N',
				    collected_flag = 'N',
				    adj_batch_id = FLOOR(x_trx_identified_count/l_sys_batch_size)
			     where  trx_line_id in (
					 select ctl.trx_line_id
					 from cn_not_trx cnt, cn_trx ct, cn_trx_lines ctl,
					      (select rctl.customer_trx_line_id
					       from ra_customer_trx_lines rctl
					       where rctl.customer_trx_id = adj.customer_trx_id and
						     exists
						     (select 1
						      from mtl_item_categories mic
						      where mic.category_id = adj.from_category_id and
							    mic.inventory_item_id = rctl.inventory_item_id)
					       ) r
					 where cnt.not_trx_id = adj.not_trx_id and
					       ct.not_trx_id = cnt.not_trx_id and
					       ctl.trx_id = ct.trx_id and
					       cnt.source_trx_id = adj.customer_trx_id and
					       ct.source_trx_id = adj.customer_trx_id and
					       ctl.source_trx_line_id = r.customer_trx_line_id
					       AND cnt.org_id = x_org_id    -- MOAC Changes made by Ashley
					       AND ct.org_id = cnt.org_id -- MOAC Changes made by Ashley
					       AND ctl.org_id = ct.org_id -- MOAC Changes made by Ashley
					 )
			    AND org_id = x_org_id;

			   /*  -- new statement
			     update cn_trx_lines
				set adjusted_flag  = 'Y',
				    negated_flag   = 'N',
				    collected_flag = 'N',
				    adj_batch_id = FLOOR(x_trx_identified_count/l_sys_batch_size)
			     where  trx_line_id in (
					 select ctl.trx_line_id
					 from cn_not_trx cnt, cn_trx ct, cn_trx_lines ctl,
					      mtl_item_categories mic
					 where cnt.not_trx_id = adj.not_trx_id and
					       ct.not_trx_id = cnt.not_trx_id and
					       ctl.trx_id = ct.trx_id and
					       cnt.source_trx_id = adj.customer_trx_id and
					       ct.source_trx_id = cnt.source_trx_id and
					       ctl.inventory_id = mic.inventory_item_id and
					       nvl(ctl.org_id,-99) = nvl(mic.organization_id,-99) and
					       mic.category_id = adj.from_category_id
					       AND cnt.org_id = x_org_id    -- MOAC Changes made by Ashley
					       AND ct.org_id = cnt.org_id -- MOAC Changes made by Ashley
					       AND ctl.org_id = ct.org_id -- MOAC Changes made by Ashley
					 )
			    AND org_id = x_org_id; */ -- MOAC Changes made by Ashley
		       end if;

		    end if; -- end if (adj.customer_trx_id = x_last_A_customer_trx_id)
		end if; -- end if adj.line_selection_mode = 'A'


		-- Update cn_not_trx.last_collected_date
		update cn_not_trx
		set last_collected_date = SYSDATE
		where not_trx_id = adj.not_trx_id
		AND org_id = x_org_id;  --MOAC Changes made by Ashley

	    END LOOP; -- end FOR adj IN adj_cursor LOOP

	    cn_process_audits_pkg.update_row(x_proc_audit_id, NULL, SYSDATE, 0,
	      'identify RAM adjustments: completed. ' || x_trx_identified_count || ' transactions identified.');

	    IF  ( x_trx_identified_count = 0 ) THEN
	      cn_message_pkg.debug('identify RAM adjustments: no RAM adjustments was found.');
	      fnd_file.put_line(fnd_file.Log, 'identify RAM adjustments: no RAM adjustments was found.');
	    END IF;

	    COMMIT; -- commit after identify process

	    cn_message_pkg.debug('identify RAM adjustments: identify process completed. ' || x_trx_identified_count || ' transactions identified.');
	    fnd_file.put_line(fnd_file.Log, 'identify RAM adjustments: identify process completed. ' || x_trx_identified_count || ' transactions identified.');

	    cn_debug.print_msg('<<identify RAM adjustments', 1);
	    cn_message_pkg.debug('identify RAM adjustments<<');
	    fnd_file.put_line(fnd_file.Log, 'identify RAM adjustments<<');



	  EXCEPTION
	    WHEN OTHERS THEN ROLLBACK;

	    cn_message_pkg.debug('identify RAM adjustments: in exception handler');
	    fnd_file.put_line(fnd_file.Log, 'identify RAM adjustments: in exception handler');

	    cn_message_pkg.debug(SQLCODE||' '||SQLERRM);
	    fnd_file.put_line(fnd_file.Log, SQLCODE||' '||SQLERRM);

	    cn_debug.print_msg('identify RAM adjustments: in exception handler', 1);
	    cn_process_audits_pkg.update_row(X_proc_audit_id, NULL, SYSDATE, SQLCODE,
	      SQLERRM);

	    app_exception.raise_exception;

	  END identify;





	  PROCEDURE negate (
		debug_pipe	VARCHAR2 DEFAULT NULL,
		debug_level	NUMBER	 DEFAULT NULL ,
	    x_org_id NUMBER  ) IS

	    -- Get affected trx_line_id
	    CURSOR neg_trx_line_cursor IS
	    select ctl.trx_line_id
	    from cn_trx_lines ctl
	    where ctl.adjusted_flag  = 'Y' and
		  ctl.negated_flag   = 'N' and
		  ctl.collected_flag = 'N' and
		  ctl.event_id = cn_global.inv_event_id
		  AND org_id = x_org_id;

	    -- Get affected comm_lines_api_id
	    CURSOR neg_api_cursor(p_trx_line_id number) IS
	    select api.comm_lines_api_id
	    from cn_comm_lines_api api
	    where api.trx_line_id = p_trx_line_id and
		  api.source_doc_type = 'AR'
		  AND org_id = x_org_id;

	    x_api_negated_count    NUMBER := 0;
	    x_proc_audit_id        NUMBER;
	    x_rowid		   ROWID;
	    l_adjusted_by          NUMBER := fnd_global.user_id;
	    l_adjust_comments      VARCHAR2(2000) := 'Negated by Revenue Adjustments Collection - Request ID = ' || fnd_global.conc_request_id;

	  BEGIN
	    IF (debug_pipe IS NOT NULL) THEN
	      cn_debug.init_pipe(debug_pipe, debug_level);
	    END IF;
	    cn_debug.print_msg('>>negate process', 1);
	    cn_message_pkg.debug('negate process>>');
	    fnd_file.put_line(fnd_file.Log, 'negate process>>');

	    x_proc_audit_id := NULL;	-- Will get a value in the call below
	    cn_process_audits_pkg.insert_row(x_rowid, x_proc_audit_id, NULL,'RAMADJ', 'negate process', NULL, NULL, NULL, NULL, NULL, SYSDATE, NULL, x_org_id);

	    FOR nt IN neg_trx_line_cursor LOOP

		FOR na IN neg_api_cursor(nt.trx_line_id) LOOP

		    x_api_negated_count := x_api_negated_count + 1;

		    -- Negate records in API or Header table
		    cn_adjustments_pkg.api_negate_record(
				    x_comm_lines_api_id    => na.comm_lines_api_id,
					x_adjusted_by	   => l_adjusted_by,
					x_adjust_comments  => l_adjust_comments);

		END LOOP;

		-- Set flags in cn_trx_lines
		update cn_trx_lines
		set negated_flag   = 'Y'
		where  trx_line_id = nt.trx_line_id
		AND org_id = x_org_id;

		-- Flag status now should be
		-- adjusted_flag  = 'Y'
		-- negated_flag   = 'Y'
		-- collected_flag = 'N'

	    END LOOP;

	    cn_process_audits_pkg.update_row(x_proc_audit_id, NULL, SYSDATE, 0,
	      'negate process: completed. ' || x_api_negated_count || ' OIC transactions negated.');

	    IF  ( x_api_negated_count = 0 ) THEN
	      cn_message_pkg.debug('negate process: No OIC transaction was negated.');
	      fnd_file.put_line(fnd_file.Log, 'negate process: No OIC transaction was negated.');
	    END IF;

	    -- COMMIT; commit will be called when the re-collection is done.

	    cn_message_pkg.debug('negate process: negate process completed. ' || x_api_negated_count || ' OIC transactions negated.');
	    fnd_file.put_line(fnd_file.Log, 'negate process: negate process completed. ' || x_api_negated_count || ' OIC transactions negated.');

	    cn_debug.print_msg('<<negate process', 1);
	    cn_message_pkg.debug('negate process<<');
	    fnd_file.put_line(fnd_file.Log, 'negate process<<');


	  EXCEPTION
	    WHEN OTHERS THEN ROLLBACK;

	    cn_message_pkg.debug('negate process: in exception handler');
	    fnd_file.put_line(fnd_file.Log, 'negate process: in exception handler');

	    cn_message_pkg.debug(SQLCODE||' '||SQLERRM);
	    fnd_file.put_line(fnd_file.Log, SQLCODE||' '||SQLERRM);

	    cn_debug.print_msg('negate process: in exception handler', 1);
	    cn_process_audits_pkg.update_row(X_proc_audit_id, NULL, SYSDATE, SQLCODE,
	      SQLERRM);

	    app_exception.raise_exception;

	  END negate;


	END cn_ram_adjustments_pkg;

/
