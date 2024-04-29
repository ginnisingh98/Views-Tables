--------------------------------------------------------
--  DDL for Package Body PA_XLA_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_XLA_UPGRADE" AS
/* $Header: PACOXLUB.pls 120.26.12010000.3 2008/12/26 07:17:16 srathi ship $ */

PROCEDURE UPGRADE_COST_XCHARGE (p_table_owner	IN VARCHAR2,
				p_script_name	IN VARCHAR2,
				p_worker_id	IN NUMBER,
				p_num_workers	IN NUMBER,
				p_batch_size	IN NUMBER,
				p_min_eiid	IN NUMBER,
				p_max_eiid	IN NUMBER,
				p_upg_batch_id	IN NUMBER,
				p_mode		IN VARCHAR2,
				p_cost_cross	IN VARCHAR2)
IS

-----------------------------------------------------
-- Ad parallelization variables
-----------------------------------------------------
l_table_name		varchar2(30) := 'PA_EXPENDITURE_ITEMS_ALL';
l_rows_processed	number;
l_start_eiid		number;
l_end_eiid		number;
l_any_rows_to_process	boolean;
-----------------------------------------------------

l_pa_app_id	number	:= 275;
l_user		number	:= 2; --Bug 6319424: Commented '-2005'
l_request_id	number	:= null;
l_date		date	:= sysdate;

BEGIN

ad_parallel_updates_pkg.initialize_id_range(
	ad_parallel_updates_pkg.ID_RANGE_SUB_RANGE,
	p_table_owner,
	l_table_name,
	p_script_name,
	'EXPENDITURE_ITEM_ID',
	p_worker_id,
	p_num_workers,
	p_batch_size,
	0,
	null,
	p_min_eiid,
	p_max_eiid);


ad_parallel_updates_pkg.get_id_range(
	l_start_eiid,
	l_end_eiid,
	l_any_rows_to_process,
	p_batch_size,
	TRUE);


WHILE ( l_any_rows_to_process = TRUE ) LOOP

	l_rows_processed := 0;

/* First fetch all the CDLs and CCDLs to be upgraded into a global temp table.

   First insert is for Debit records and Second insert is for Credit records.

   Position is used to derive the ae_line_num later and maintain its
   integrity within a (ae header + expenditure_item_id + cdl_line_num) combination.
   It is also used to identify the Dr and Cr record.

   Order_Line_Num is used to ensure creation of one entity per expenditure item id.

   The check for system_linkage_function is required since cdl batch_name not null is not a
   sufficient criteria to identify all the valid CDLs as ER will also have not null batch name.

   We need to use the ROW_NUMBER only since we are getting data from both CDL and
   CCDL table which can result into the same cdl_line_num for a given expenditure_item_id */


	INSERT WHEN cdl_line_type in ('R', 'D', 'BL', 'PC')
	THEN INTO PA_XLA_UPG_LINES_GT
	(legal_entity_id,
	 ledger_id,
	 org_id,
	 expenditure_item_id,
	 cdl_line_num,
	 cdl_line_type,
	 grouped_line_type,
	 gl_date,
	 gl_period_name,
	 batch_name,
	 code_combination_id,
	 acct_raw_cost,
	 denom_raw_cost,
	 denom_currency_code,
	 tp_amt_type_code,
	 je_category,
	 event_type_code,
	 event_class_code,
	 order_line_num,
	 position,
	 REFERENCE_2,
	 REFERENCE_3
	 )
	VALUES
	(legal_entity_id,
	 ledger_id,
	 org_id,
	 expenditure_item_id,
	 cdl_line_num,
	 cdl_line_type,
	 grouped_line_type,
	 gl_date,
	 gl_period_name,
	 batch_name,
	 dr_code_combination_id,
	 acct_raw_cost,
	 denom_raw_cost,
	 denom_currency_code,
	 tp_amt_type_code,
	 je_category,
	 event_type_code,
	 event_class_code,
	 order_line_num,
	 1,
	 DR_REFERENCE_2,
	 DR_REFERENCE_3
	 )
	WHEN cdl_line_type in ('R', 'C', 'BL', 'PC')
	THEN INTO PA_XLA_UPG_LINES_GT
	(legal_entity_id,
	 ledger_id,
	 org_id,
	 expenditure_item_id,
	 cdl_line_num,
	 cdl_line_type,
	 grouped_line_type,
	 gl_date,
	 gl_period_name,
	 batch_name,
	 code_combination_id,
	 acct_raw_cost,
	 denom_raw_cost,
	 denom_currency_code,
	 tp_amt_type_code,
	 je_category,
	 event_type_code,
	 event_class_code,
	 order_line_num,
	 position,
	 REFERENCE_2,
	 REFERENCE_3
	 )
	VALUES
	(legal_entity_id,
	 ledger_id,
	 org_id,
	 expenditure_item_id,
	 cdl_line_num,
	 cdl_line_type,
	 grouped_line_type,
	 gl_date,
	 gl_period_name,
	 batch_name,
	 cr_code_combination_id,
	 acct_raw_cost,
	 denom_raw_cost,
	 denom_currency_code,
	 tp_amt_type_code,
	 je_category,
	 event_type_code,
	 event_class_code,
	 NULL,
	 2 ,
	 CR_REFERENCE_2,
	 CR_REFERENCE_3
	 )
	SELECT
	 legal_entity_id AS legal_entity_id,
	 ledger_id AS ledger_id,
	 org_id AS org_id,
	 expenditure_item_id AS expenditure_item_id,
	 cdl_line_num AS cdl_line_num,
	 cdl_line_type AS cdl_line_type,
	 grouped_line_type AS grouped_line_type,
	 gl_date AS gl_date,
	 gl_period_name AS gl_period_name,
	 batch_name AS batch_name,
	 dr_code_combination_id AS dr_code_combination_id,
	 cr_code_combination_id AS cr_code_combination_id,
	 acct_raw_cost AS acct_raw_cost,
	 denom_raw_cost AS denom_raw_cost,
	 denom_currency_code AS denom_currency_code,
	 tp_amt_type_code AS tp_amt_type_code,
	 je_category AS je_category,
	 event_type_code AS event_type_code,
	 event_class_code AS event_class_code,
	 ROW_NUMBER() over  (partition by expenditure_item_id
			     order by cdl_line_num) AS order_line_num,
	 DR_REFERENCE_2	As DR_REFERENCE_2,
	 CR_REFERENCE_2	As CR_REFERENCE_2,
	 DR_REFERENCE_3 As DR_REFERENCE_3,
	 CR_REFERENCE_3 As CR_REFERENCE_3
	FROM
	 (
	 select /*+ NO_EXPAND LEADING(CDL,IMP,CTRL) USE_NL(ei,hoi) swap_join_inputs(IMP) swap_join_inputs(CTRL) */
		to_number(hoi.org_information2) legal_entity_id,
		imp.set_of_books_id ledger_id,
		imp.org_id,
		cdl.expenditure_item_id,
		cdl.line_num cdl_line_num,
		cdl.line_type cdl_line_type,
		decode(cdl.line_type, 'R','R','B') grouped_line_type,
		cdl.gl_date,
		cdl.gl_period_name,
		cdl.batch_name,
		cdl.dr_code_combination_id,
		cdl.cr_code_combination_id,
		decode(cdl.line_type, 'C', -1 * cdl.acct_raw_cost,
				      'D', cdl.acct_raw_cost,
				      'R', decode(ei.system_linkage_function, 'BTC', cdl.acct_burdened_cost,
									       cdl.acct_raw_cost)) acct_raw_cost,
		decode(cdl.line_type, 'C', -1 * cdl.denom_raw_cost,
				      'D', cdl.denom_raw_cost,
				      'R', decode(ei.system_linkage_function, 'BTC', cdl.denom_burdened_cost,
									       cdl.denom_raw_cost)) denom_raw_cost,
		cdl.denom_currency_code,
		null tp_amt_type_code,
		decode(cdl.line_type, 'C', 'Total Burdened Cost',
				      'D', 'Total Burdened Cost',
				      'R', decode(ei.system_linkage_function, 'BTC','Burden Cost',
							       'INV','Inventory',
							       'ST','Labor Cost',
							       'OT','Labor Cost',
							       'PJ','Miscellaneous Transaction',
							       'USG','Usage Cost',
							       'WIP','WIP')) je_category,
		decode(cdl.line_type, 'C', 'TOT_BURDENED_COST_DIST',
				      'D', 'TOT_BURDENED_COST_DIST',
				      'R', decode(ei.system_linkage_function, 'BTC','BURDEN_COST_DIST',
							       'INV','INVENTORY_COST_DIST',
							       'ST','LABOR_COST_DIST',
							       'OT','LABOR_COST_DIST',
							       'PJ','MISC_COST_DIST',
							       'USG','USG_COST_DIST',
							       'WIP','WIP_COST_DIST')) || DECODE (ei.adjusted_expenditure_item_id,
												NULL , '' ,
												'_ADJ'
											      )  event_type_code,
		decode(cdl.line_type, 'C', 'TOT_BURDENED_COST',
				      'D', 'TOT_BURDENED_COST',
				      'R', decode(ei.system_linkage_function, 'BTC','BURDEN_COST',
							       'INV','INVENTORY_COST',
							       'ST','LABOR_COST',
							       'OT','LABOR_COST',
							       'PJ','MISC_COST',
							       'USG','USG_COST',
							       'WIP','WIP_COST'))  || DECODE (ei.adjusted_expenditure_item_id,
												NULL , '' ,
												'_ADJ'
											      )  event_class_code,
		 'Cost'					DR_REFERENCE_3,
		 'Liability'				CR_REFERENCE_3,
		 to_char(cdl.dr_code_combination_id)	DR_REFERENCE_2,
		 to_char('-99')				CR_REFERENCE_2
	 FROM PA_COST_DISTRIBUTION_LINES_ALL cdl,
	      PA_EXPENDITURE_ITEMS_ALL ei,
	      PA_IMPLEMENTATIONS_ALL imp,
	      (select ledger_id,min(min_value) min_value, max(max_value) max_value from
		         PA_XLA_UPG_CTRL
          where  reference = 'GL_PERIOD_STATUSES'
		  AND    status = 'P'
		  AND    batch_id = p_upg_batch_id
		  group by ledger_id) ctrl,
	      HR_ORGANIZATION_INFORMATION hoi
	 WHERE cdl.expenditure_item_id between l_start_eiid and l_end_eiid
	 AND cdl.transfer_status_code = 'A'
	 AND cdl.batch_name is not null
	 AND cdl.acct_event_id is null
	 AND cdl.expenditure_item_id = ei.expenditure_item_id
	 AND (cdl.line_type in ('C','D') OR ei.system_linkage_function in ('BTC','INV','ST','PJ','USG','WIP','OT'))
	 AND cdl.org_id = imp.org_id
	 AND cdl.gl_date between to_date(ctrl.min_value,'J') and to_date (ctrl.max_value,'J')
	 AND ctrl.ledger_id = imp.set_of_books_id
	 --AND ctrl.reference = 'GL_PERIOD_STATUSES'
	 --AND ctrl.status = 'P'
	 --AND ctrl.batch_id = p_upg_batch_id
	 AND hoi.organization_id = imp.org_id
	 AND hoi.org_information_context = 'Operating Unit Information'
	 AND NVL(p_cost_cross,'C') = 'C' /* Bug 5408944 */
	 AND (
		(
			cdl.line_type = 'R'
		  and cdl.dr_code_combination_id > 0
		  and cdl.cr_code_combination_id > 0
		)
		OR
		(
			cdl.line_type = 'D'
		  and cdl.dr_code_combination_id > 0
		)
		OR
		(
			cdl.line_type = 'C'
		  and cdl.cr_code_combination_id > 0
		)
	     )
	UNION ALL
	 SELECT	/*+ LEADING(CDL,IMP,CTRL) USE_NL(ei,hoi) swap_join_inputs(IMP) swap_join_inputs(CTRL)  */
		to_number(hoi.org_information2) legal_entity_id,
		imp.set_of_books_id ledger_id,
		imp.org_id,
		cdl.expenditure_item_id,
		cdl.line_num cdl_line_num,
		cdl.line_type cdl_line_type,
		cdl.line_type grouped_line_type,
		cdl.gl_date,
		cdl.gl_period_name,
		cdl.gl_batch_name batch_name,
		cdl.dr_code_combination_id,
		cdl.cr_code_combination_id ,
		cdl.amount acct_raw_cost,
		cdl.denom_transfer_price denom_raw_cost,
		cdl.denom_tp_currency_code denom_currency_code,
		ei.tp_amt_type_code tp_amt_type_code,
		decode(cdl.line_type, 'BL', 'Borrowed and Lent',
				      'PC', 'Prov Cost Reclass') je_category,
		decode(cdl.line_type, 'BL', 'BL_DISTRIBUTION',
				      'PC', 'PRVDR_RECVR_RECLASS') || DECODE (ei.adjusted_expenditure_item_id,
												NULL , '' ,
												'_ADJ'
											      )  event_type_code,
		decode(cdl.line_type, 'BL', 'BORROWED_AND_LENT',
				      'PC', 'PRVDR_RECVR_RECLASS') || DECODE (ei.adjusted_expenditure_item_id,
												NULL , '' ,
												'_ADJ'
											      )   event_class_code,
		'Cross Charge Debit'			DR_REFERENCE_3,
		'Cross Charge Credit'			CR_REFERENCE_3,
		to_char(cdl.dr_code_combination_id)	DR_REFERENCE_2,
		to_char(cdl.cr_code_combination_id)	CR_REFERENCE_2
	 FROM PA_CC_DIST_LINES_ALL cdl,
	      PA_EXPENDITURE_ITEMS_ALL ei,
	      PA_IMPLEMENTATIONS_ALL imp,
	      (select ledger_id,min(min_value) min_value, max(max_value) max_value from
		         PA_XLA_UPG_CTRL
          where  reference = 'GL_PERIOD_STATUSES'
		  AND    status = 'P'
		  AND    batch_id = p_upg_batch_id
		  group by ledger_id) ctrl,
	      HR_ORGANIZATION_INFORMATION hoi
	 WHERE cdl.expenditure_item_id between l_start_eiid and l_end_eiid
	 AND cdl.transfer_status_code = 'A'
	 AND cdl.gl_batch_name is not null
	 AND cdl.acct_event_id is null
	 AND cdl.expenditure_item_id = ei.expenditure_item_id
	 AND cdl.org_id = imp.org_id
	 AND cdl.gl_date between to_date(ctrl.min_value,'J') and to_date (ctrl.max_value,'J')
	 AND ctrl.ledger_id = imp.set_of_books_id
	 --AND ctrl.reference = 'GL_PERIOD_STATUSES'
	 --AND ctrl.status = 'P'
	 --AND ctrl.batch_id = p_upg_batch_id
	 AND hoi.organization_id = imp.org_id
	 AND hoi.org_information_context = 'Operating Unit Information'
	 AND NVL(p_cost_cross,'X') = 'X' /* Bug 5408944 */
	 AND cdl.dr_code_combination_id > 0
	 AND cdl.cr_code_combination_id > 0
	 );

	l_rows_processed := SQL%ROWCOUNT;


	IF nvl(l_rows_processed,0) > 0 THEN


		INSERT ALL INTO XLA_TRANSACTION_ENTITIES_UPG
			(upg_batch_id,
			upg_source_application_id,
			application_id,
			ledger_id,
			legal_entity_id,
			entity_code,
			source_id_int_1,
			security_id_int_1,
			source_application_id,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login,
			entity_id,
			transaction_number)
		    VALUES
			(p_upg_batch_id ,
			l_pa_app_id,
			l_pa_app_id,
			ledger_id,
			legal_entity_id,
			'EXPENDITURES',
			expenditure_item_id,
			org_id ,
			l_pa_app_id,
			l_date,
			l_user,
			l_date,
			l_user,
			l_user,
			XLA_TRANSACTION_ENTITIES_S.nextval,
			expenditure_item_id)
		    INTO PA_XLA_UPG_ENTITIES_GT
		    (
			EXPENDITURE_ITEM_ID,
			ENTITY_ID
		    )
		    VALUES
		    (
			expenditure_item_id ,
			XLA_TRANSACTION_ENTITIES_S.nextval
		    )
		    SELECT
			ledger_id,
			legal_entity_id,
			expenditure_item_id,
			org_id
		    FROM PA_XLA_UPG_LINES_GT lines_gt
		    WHERE order_line_num = 1
		    AND ((p_mode = 'D') OR
		         (p_mode = 'R' AND
			  NOT EXISTS (SELECT null
				      FROM XLA_TRANSACTION_ENTITIES_UPG xla_ent
				      WHERE xla_ent.application_id = l_pa_app_id AND
				      xla_ent.entity_code = 'EXPENDITURES'
				      AND NVL(xla_ent.source_id_int_1,-99) = lines_gt.expenditure_item_id
				      AND xla_ent.ledger_id = lines_gt.ledger_id
				      AND rownum = 1)
			 ));

		  l_rows_processed := SQL%ROWCOUNT/2;


/* One event and one header needs to be created per pair of C and D lines.
   But this same event and header needs to be used while creating ae lines using both C and D lines.

   Since there is no database link available between a C and corresponding D line,
   its better to group by to ensure the data model consistency.

   Since we have to group, gl_date is also included in the grouping criteria to be consistent with the
   regular flow where one event is raised per expenditrue_item_id/line_type(R/C+D/BL/PC)/gl_date combination

   Xla_transaction_entities has a non unique index N1 on columns(application_id,ledger_id,entity_code,source_id..)*/

		INSERT ALL INTO XLA_EVENTS
		      (upg_batch_id,
		       upg_source_application_id,
		       application_id,
		       event_type_code,
		       event_number,
		       event_status_code,
		       process_status_code,
		       on_hold_flag,
		       event_date,
		       creation_date,
		       created_by,
		       last_update_date,
		       last_updated_by,
		       last_update_login,
		       program_update_date,
		       program_id,
		       program_application_id,
		       request_id,
		       entity_id,
		       event_id,
		       transaction_date)
		    VALUES
		      (p_upg_batch_id,
		       l_pa_app_id,
		       l_pa_app_id,
		       event_type_code,
		       xla_events_s.nextval,
		       'P',		--event status
		       'P',		--process status
		       'N',
		       gl_date,		--event date
		       l_date,
		       l_user,
		       l_date,
		       l_user,
		       l_user,
		       l_date,
		       l_user,
		       l_pa_app_id,
		       l_request_id,
		       entity_id,
		       xla_events_s.nextval,
		       gl_date
		      )
		   INTO XLA_AE_HEADERS
		     (upg_batch_id,
		      upg_source_application_id,
		      application_id,
		      amb_context_code,
		      entity_id,
		      event_id,
		      event_type_code,
		      ae_header_id,
		      ledger_id,
		      accounting_date,
		      period_name,
		      balance_type_code,
		      je_category_name,
		      gl_transfer_status_code,
		      accounting_entry_status_code,
		      accounting_entry_type_code,
		      creation_date,
		      created_by,
		      last_update_date,
		      last_updated_by,
		      last_update_login,
		      program_update_date,
		      program_id,
		      program_application_id,
		      request_id)
		     VALUES
		     (p_upg_batch_id,
		      l_pa_app_id,
		      l_pa_app_id,
		      'DEFAULT',
		      entity_id,
		      xla_events_s.nextval,
		      event_type_code,
		      xla_ae_headers_s.nextval,
		      ledger_id,
		      gl_date,
		      gl_period_name,
		      'A',                     --balance type Actual
		      je_category,
		      'Y',                     --gl transfer status
		      'F',                     --acct entry status code final
		      'STANDARD',
		      l_date,
		      l_user,
		      l_date,
		      l_user,
		      l_user,
		      l_date,
		      l_user,
		      l_pa_app_id,
		      l_request_id
		      )
		      INTO PA_XLA_UPG_EVENTS_GT
		      (expenditure_item_id,
		       event_id,
		       grouped_line_type,
		       event_date,
		       header_id
		      )
		      VALUES
		      (expenditure_item_id,
		       xla_events_s.nextval,
		       grouped_line_type,
		       gl_date,
		       xla_ae_headers_s.nextval
		      )
		      SELECT  /*+  USE_NL(ent_gt lines_gt) INDEX(lines_gt, PA_XLA_UPG_LINES_GT_N1) */
		              lines_gt.expenditure_item_id,
			      ent_gt.entity_id,
			      lines_gt.grouped_line_type,
			      lines_gt.gl_date,
			      lines_gt.gl_period_name ,
			      lines_gt.ledger_id,
			      lines_gt.legal_entity_id,
			      lines_gt.je_category,
			      lines_gt.event_type_code
		      FROM PA_XLA_UPG_LINES_GT lines_gt,
			   PA_XLA_UPG_ENTITIES_GT ent_gt
		      WHERE lines_gt.expenditure_item_id = ent_gt.expenditure_item_id
		      GROUP BY lines_gt.expenditure_item_id,
			      ent_gt.entity_id,
			      lines_gt.grouped_line_type,
			      lines_gt.gl_date,
			      lines_gt.gl_period_name ,
			      lines_gt.ledger_id,
			      lines_gt.legal_entity_id,
			      lines_gt.je_category,
			      lines_gt.event_type_code ;


	/* For the join with gl_import_references, cr_code_combination_id on R or C lines is not used since for these
	   lines credit side we do not populate ccid on gl interface table (since we group by cr ccid to create batch
	   name) while on debit side there can be multiple records with same batch names but different debit ccids.

	   gl_import_references has a non-unique index N3 on columns (reference_6, reference_2, reference_3)

	   It would be ok to use RANK here instead of ROW_NUMBER since separate headers are created for CDLs and CCDLs

	   The Cr and Dr amounts are altered assuming Switch Dr/CR to be 'Yes' on the JLT  */

		   INSERT ALL INTO XLA_AE_LINES
		      (upg_batch_id,
		       ae_header_id,
		       ae_line_num,
		       application_id,
		       code_combination_id,
		       gl_transfer_mode_code,
		       accounted_dr,
		       accounted_cr,
		       currency_code,
		       entered_dr,
		       entered_cr,
		       description,
		       accounting_class_code,
		       creation_date,
		       created_by,
		       last_update_date,
		       last_updated_by,
		       last_update_login,
		       program_update_date,
		       program_id,
		       program_application_id,
		       request_id,
		       gain_or_loss_flag,
		       accounting_date,
		       ledger_id
		      )
		  VALUES
		   (   p_upg_batch_id,
		       header_id,
		       ae_line_num,
		       l_pa_app_id,
		       code_combination_id,
		       'D',                             --gl transfer mode Summary or detail
		       acct_dr,
		       acct_cr,
		       currency_code,
		       entered_dr,
		       entered_cr,
		       '',                             --description TBD
		       acct_class,
		       l_date,
		       l_user,
		       l_date,
		       l_user,
		       l_user,
		       l_date,
		       l_user,
		       l_pa_app_id,
		       l_request_id,
		       'N',
		       gl_date,
		       ledger_id)
		   INTO XLA_DISTRIBUTION_LINKS
		      (application_id,
		       event_id,
		       ae_header_id,
		       ae_line_num,
		       source_distribution_type,
		       source_distribution_id_num_1,
		       source_distribution_id_num_2,
		       merge_duplicate_code,
		       event_type_code,
		       event_class_code,
		       upg_batch_id,
		       ref_ae_header_id,
		       temp_line_num,
		       unrounded_accounted_dr,
		       unrounded_accounted_cr,
		       unrounded_entered_dr,
		       unrounded_entered_cr)
		    VALUES
		      (l_pa_app_id,
		       event_id,
		       header_id,
		       ae_line_num,
		       cdl_line_type,
		       expenditure_item_id,
		       cdl_line_num,
		       'N',
		       event_type_code,
		       event_class_code,
		       p_upg_batch_id,
		       header_id,
		       ae_line_num,
		       acct_dr,
		       acct_cr,
		       entered_dr,
		       entered_cr)
		   INTO PA_REV_AE_LINES_TMP
		      (ae_header_id,
		       ae_line_num,
		       gl_batch_name,
		       code_combination_id,
		       dist_type)
		   VALUES
		      (header_id,
		       ae_line_num,
		       batch_name,
		       reference_2,
		       reference_3)
		SELECT
		       header_id AS header_id,
		       event_id AS event_id,
		       code_combination_id AS code_combination_id,
		       acct_class AS acct_class,
		       acct_dr AS acct_dr,
		       acct_cr AS acct_cr,
		       entered_dr AS entered_dr,
		       entered_cr AS entered_cr,
		       currency_code AS currency_code,
		       event_type_code AS event_type_code,
		       event_class_code AS event_class_code,
		       expenditure_item_id AS expenditure_item_id,
		       cdl_line_num AS cdl_line_num,
		       cdl_line_type AS cdl_line_type,
		       batch_name AS batch_name,
		       reference_2 AS reference_2,
		       reference_3 AS reference_3,
		       ledger_id AS ledger_id,
		       gl_date AS gl_date,
		       RANK() OVER (PARTITION BY header_id
				    ORDER BY expenditure_item_id, cdl_line_num, position) AS ae_line_num
		FROM
		(select /*+ USE_NL (event_gt lines_gt imp) INDEX(lines_gt, PA_XLA_UPG_LINES_GT_N1)
				INDEX(imp, GL_IMPORT_REFERENCES_N3) */
			lines_gt.position,
			event_gt.header_id header_id,
			event_gt.event_id event_id,
			lines_gt.code_combination_id,
			decode(lines_gt.position,
				1, decode(lines_gt.cdl_line_type,
					  'PC', 'RECLASS_DESTINATION',
					  'BL', decode(lines_gt.tp_amt_type_code,
							'REVENUE_TRANSFER', 'RECEIVER_REVENUE',
									    'RECEIVER_COST'),
					  'COST'),
				2, decode(lines_gt.cdl_line_type,
					  'PC', 'RECLASS_SOURCE',
					  'BL', decode(lines_gt.tp_amt_type_code,
							'REVENUE_TRANSFER', 'PROVIDER_REVENUE',
									    'PROVIDER_COST'),
					  'COST_CLEARING')
				) acct_class,
			decode(position, 1, decode(sign(lines_gt.acct_raw_cost),  1, lines_gt.acct_raw_cost, 0, 0, NULL),
					 2, decode(sign(lines_gt.acct_raw_cost), -1, -1*lines_gt.acct_raw_cost, 0, NULL, NULL)) acct_dr,
			decode(position, 1, decode(sign(lines_gt.acct_raw_cost), -1, -1*lines_gt.acct_raw_cost, 0, NULL, NULL),
					 2, decode(sign(lines_gt.acct_raw_cost),  1, 1*lines_gt.acct_raw_cost, 0, 0 , NULL)) acct_cr,
			decode(position, 1, decode(sign(lines_gt.denom_raw_cost), 1, lines_gt.denom_raw_cost, 0, 0 , NULL),
					 2,decode(sign(lines_gt.denom_raw_cost),-1,-1*lines_gt.denom_raw_cost,0, NULL ,NULL)) entered_dr,
			decode(position, 1, decode(sign(lines_gt.denom_raw_cost),-1, -1*lines_gt.denom_raw_cost, 0, NULL ,NULL),
					 2,decode(sign(lines_gt.denom_raw_cost), 1,1*lines_gt.denom_raw_cost,0, 0 ,NULL)) entered_cr,
			lines_gt.denom_currency_code currency_code,
			lines_gt.event_type_code event_type_code,
			lines_gt.event_class_code,
			lines_gt.expenditure_item_id expenditure_item_id,
			lines_gt.cdl_line_num,
			lines_gt.cdl_line_type,
			lines_gt.batch_name,
			lines_gt.reference_2,
			lines_gt.reference_3,
			lines_gt.ledger_id,
			lines_gt.gl_date
		from PA_XLA_UPG_LINES_GT lines_gt,
		     PA_XLA_UPG_EVENTS_GT event_gt
		where event_gt.expenditure_item_id = lines_gt.expenditure_item_id
		and event_gt.event_date = lines_gt.gl_date
		and event_gt.grouped_line_type = lines_gt.grouped_line_type
		);


		/* Now stamp back the event id on the cdl and ccdl tables. */


		UPDATE /*+ INDEX(cdl, PA_COST_DISTRIBUTION_LINES_U1) */
			pa_cost_distribution_lines_all cdl
		SET cdl.acct_event_id = (select /*+ INDEX(event_gt, PA_XLA_UPG_EVENTS_GT_N1) */
		                               event_gt.event_id from PA_XLA_UPG_EVENTS_GT event_gt
					       where cdl.expenditure_item_id = event_gt.expenditure_item_id
					       and cdl.gl_date = event_gt.event_date
					       and decode(cdl.line_type, 'R', 'R', 'B' ) = event_gt.grouped_line_type
					       and rownum = 1)
	        WHERE cdl.expenditure_item_id between l_start_eiid and l_end_eiid
	         and  cdl.line_type in ( 'R','C','D')
                 and  cdl.acct_event_id is null
		 and  exists ( select /*+ INDEX(lines_gt, PA_XLA_UPG_LINES_GT_N1) */
		                      1
                                 from PA_XLA_UPG_LINES_GT lines_gt
                                where lines_gt.expenditure_item_id = cdl.expenditure_item_id
                                  and lines_gt.cdl_line_num        = cdl.line_num);



		UPDATE /*+ INDEX(cdl, PA_CC_DIST_LINES_U2) */
			PA_CC_DIST_LINES_ALL cdl
		SET cdl.acct_event_id = (select /*+ INDEX(event_gt, PA_XLA_UPG_EVENTS_GT_N1) */
					    event_gt.event_id from PA_XLA_UPG_EVENTS_GT event_gt
					 where cdl.expenditure_item_id = event_gt.expenditure_item_id
					 and cdl.gl_date = event_gt.event_date
					 and cdl.line_type = event_gt.grouped_line_type
					 and rownum = 1)
		WHERE cdl.expenditure_item_id between l_start_eiid and l_end_eiid
		  and cdl.line_type in ('BL','PC')
		  and cdl.acct_event_id is null
		  and exists ( select  /*+ INDEX(lines_gt, PA_XLA_UPG_LINES_GT_N1) */
		                    1
                                 from PA_XLA_UPG_LINES_GT lines_gt
                                where lines_gt.expenditure_item_id = cdl.expenditure_item_id
                                  and lines_gt.cdl_line_num        = cdl.line_num);


		/* Stamp the gl_sl_link_id on xla_ae_lines to establish the link between GL and SLA

		   This is done in a separate update (and not combined with the insert on xla_ae_lines
		   since there are known issues of data corruption in the link with gl_import_references
		   using the gl_batch_name and this corruption should not prevent the data upgrade to SLA.

		   Even if any data corrutpion is encountered, the upgrade is continued as the only loss
		   is the lack of link between GL and SLA, which is simlar to the link not being there in
		   11i between GL and PA due to the above data corruption */


		BEGIN

			UPDATE XLA_AE_LINES xal
			SET gl_sl_link_id = (SELECT /*+ INDEX(tmp, PA_REV_AE_LINES_TMP_U1) */
						  gl_sl_link_id
					     FROM GL_IMPORT_REFERENCES imp,
						  PA_REV_AE_LINES_TMP tmp
					     WHERE xal.ae_header_id = tmp.ae_header_id
					     AND xal.ae_line_num = tmp.ae_line_num
					     AND tmp.gl_batch_name = imp.reference_6
					     AND tmp.code_combination_id = nvl(imp.reference_2,-99)
					     AND tmp.dist_type = imp.reference_3
					     AND ROWNUM = 1)
			WHERE application_id = l_pa_app_id
			AND upg_batch_id = p_upg_batch_id
			AND gl_sl_link_id is null
			AND EXISTS ( SELECT /*+ INDEX(tmp1, PA_REV_AE_LINES_TMP_U1) */ 1
				     FROM PA_REV_AE_LINES_TMP tmp1
				     WHERE xal.ae_header_id   = tmp1.ae_header_id
				     AND xal.ae_line_num    = tmp1.ae_line_num);

		EXCEPTION
		WHEN OTHERS THEN
			null;
		END;



	 END IF;  /* l_rows_processed */


	ad_parallel_updates_pkg.processed_id_range(
			       l_rows_processed,
			       l_end_eiid);

	COMMIT;

	ad_parallel_updates_pkg.get_id_range(
			       l_start_eiid,
			       l_end_eiid,
			       l_any_rows_to_process,
			       p_batch_size,
			       FALSE);

END LOOP ;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END UPGRADE_COST_XCHARGE;

------------------------------------------------------------------------------------------------------

PROCEDURE UPGRADE_MC_COST_XCHARGE(      p_table_owner	IN VARCHAR2,
					p_script_name	IN VARCHAR2,
					p_worker_id	IN NUMBER,
					p_num_workers	IN NUMBER,
					p_batch_size	IN NUMBER,
					p_min_eiid	IN NUMBER,
					p_max_eiid	IN NUMBER,
					p_upg_batch_id	IN NUMBER,
					p_mode		IN VARCHAR2,
					p_cost_cross	IN VARCHAR2)

IS

-----------------------------------------------------
-- Ad parallelization variables
-----------------------------------------------------
l_table_name		varchar2(30) := 'PA_EXPENDITURE_ITEMS_ALL';
l_rows_processed	number;
l_start_eiid		number;
l_end_eiid		number;
l_any_rows_to_process	boolean;
-----------------------------------------------------

l_pa_app_id number := 275;
l_user number := 2; --Bug 6319424: Commented '-2005'
l_request_id number := null;
l_date date := sysdate;

BEGIN

ad_parallel_updates_pkg.initialize_id_range(
           ad_parallel_updates_pkg.ID_RANGE_SUB_RANGE,
           p_table_owner,
           l_table_name,
           p_script_name,
	   'EXPENDITURE_ITEM_ID',
           p_worker_id,
           p_num_workers,
           p_batch_size,
	   0,
	   null,
	   p_min_eiid,
	   p_max_eiid);


ad_parallel_updates_pkg.get_id_range(
           l_start_eiid,
           l_end_eiid,
           l_any_rows_to_process,
           p_batch_size,
           TRUE);


WHILE ( l_any_rows_to_process = TRUE ) LOOP

	l_rows_processed := 0;


	INSERT WHEN cdl_line_type in ('R', 'D', 'BL', 'PC')
	THEN INTO PA_XLA_UPG_LINES_GT
	(legal_entity_id,
	 ledger_id,
	 org_id,
	 expenditure_item_id,
	 cdl_line_num,
	 cdl_line_type,
	 grouped_line_type,
	 gl_date,
	 gl_period_name,
	 batch_name,
	 code_combination_id,
	 acct_raw_cost,
	 denom_raw_cost,
	 denom_currency_code,
	 conversion_date,
	 conversion_rate,
	 conversion_type,
	 tp_amt_type_code,
	 je_category,
	 event_type_code,
	 event_class_code,
	 entity_id,
	 event_id,
	 position,
	 REFERENCE_2,
	 REFERENCE_3
	 )
	VALUES
	(legal_entity_id,
	 ledger_id,
	 org_id,
	 expenditure_item_id,
	 cdl_line_num,
	 cdl_line_type,
	 grouped_line_type,
	 gl_date,
	 gl_period_name,
	 batch_name,
	 dr_code_combination_id,
	 acct_raw_cost,
	 denom_raw_cost,
	 denom_currency_code,
	 conversion_date,
	 conversion_rate,
	 conversion_type,
	 tp_amt_type_code,
	 je_category,
	 event_type_code,
	 event_class_code,
	 entity_id,
	 event_id,
	 1,
	 DR_REFERENCE_2,
	 DR_REFERENCE_3
	 )
	 WHEN cdl_line_type in ('R', 'C', 'BL', 'PC')
	 THEN INTO PA_XLA_UPG_LINES_GT
	(legal_entity_id,
	 ledger_id,
	 org_id,
	 expenditure_item_id,
	 cdl_line_num,
	 cdl_line_type,
	 grouped_line_type,
	 gl_date,
	 gl_period_name,
	 batch_name,
	 code_combination_id,
	 acct_raw_cost,
	 denom_raw_cost,
	 denom_currency_code,
	 conversion_date,
	 conversion_rate,
	 conversion_type,
	 tp_amt_type_code,
	 je_category,
	 event_type_code,
	 event_class_code,
	 entity_id,
	 event_id,
	 position,
	 REFERENCE_2,
	 REFERENCE_3
	 )
	VALUES
	(legal_entity_id,
	 ledger_id,
	 org_id,
	 expenditure_item_id,
	 cdl_line_num,
	 cdl_line_type,
	 grouped_line_type,
	 gl_date,
	 gl_period_name,
	 batch_name,
	 cr_code_combination_id,
	 acct_raw_cost,
	 denom_raw_cost,
	 denom_currency_code,
	 conversion_date,
	 conversion_rate,
	 conversion_type,
	 tp_amt_type_code,
	 je_category,
	 event_type_code,
	 event_class_code,
	 entity_id,
	 event_id,
	 2,
	 CR_REFERENCE_2,
	 CR_REFERENCE_3
	 )
	 SELECT /*+ USE_NL (cdl mc ei)  INDEX(cdl, PA_COST_DISTRIBUTION_LINES_U1)
		INDEX( mc, PA_MC_COST_DIST_LINES_ALL_U1) INDEX(ei, PA_EXPENDITURE_ITEMS_PK) */
		to_number(hoi.org_information2) legal_entity_id,
		mc.set_of_books_id ledger_id,
		imp.org_id,
		mc.expenditure_item_id,
		mc.line_num cdl_line_num,
		mc.line_type cdl_line_type,
		decode(mc.line_type, 'R','R','B') grouped_line_type,
		cdl.gl_date,
		cdl.gl_period_name,
		mc.batch_name,
		cdl.dr_code_combination_id dr_code_combination_id,
		cdl.cr_code_combination_id cr_code_combination_id,
		decode(mc.line_type, 'C', -1 * mc.amount,
				     'D', mc.amount,
				     'R', decode(ei.system_linkage_function, 'BTC', mc.burdened_cost,
									      mc.amount)) acct_raw_cost,
		decode(cdl.line_type, 'C', -1 * cdl.denom_raw_cost,
				      'D', cdl.denom_raw_cost,
				      'R', decode(ei.system_linkage_function, 'BTC', cdl.denom_burdened_cost,
									       cdl.denom_raw_cost)) denom_raw_cost,
		cdl.denom_currency_code,
		mc.conversion_date conversion_date,
		mc.exchange_rate conversion_rate,
		mc.rate_type conversion_type,
		null tp_amt_type_code,
		decode(mc.line_type,  'C', 'Total Burdened Cost',
				      'D', 'Total Burdened Cost',
				      'R', decode(evt.event_type_code, 'BURDEN_COST_DIST','Burden Cost',
								       'BURDEN_COST_DIST_ADJ','Burden Cost',
								       'INVENTORY_COST_DIST','Inventory',
								       'INVENTORY_COST_DIST_ADJ','Inventory',
								       'LABOR_COST_DIST','Labor Cost',
								       'LABOR_COST_DIST_ADJ','Labor Cost',
								       'MISC_COST_DIST','Miscellaneous Transaction',
								       'MISC_COST_DIST_ADJ','Miscellaneous Transaction',
								       'USG_COST_DIST','Usage Cost',
								       'USG_COST_DIST_ADJ','Usage Cost',
								       'WIP_COST_DIST','WIP',
								       'WIP_COST_DIST_ADJ','WIP'
								       )
								       ) je_category,
		evt.event_type_code,
		decode(cdl.line_type, 'C', 'TOT_BURDENED_COST',
				      'D', 'TOT_BURDENED_COST',
				      'R', decode(evt.event_type_code, 'BURDEN_COST_DIST','BURDEN_COST',
								      'BURDEN_COST_DIST_ADJ','BURDEN_COST_ADJ',
							       'INVENTORY_COST_DIST','INVENTORY_COST',
							       'INVENTORY_COST_DIST_ADJ','INVENTORY_COST_ADJ',
							       'LABOR_COST_DIST','LABOR_COST',
							       'LABOR_COST_DIST_ADJ','LABOR_COST_ADJ',
							       'MISC_COST_DIST','MISC_COST',
							       'MISC_COST_DIST_ADJ','MISC_COST_ADJ',
							       'USG_COST_DIST','USG_COST',
							       'USG_COST_DIST_ADJ','USG_COST_ADJ',
							       'WIP_COST_DIST','WIP_COST',
							       'WIP_COST_DIST_ADJ','WIP_COST_ADJ'
							       )) event_class_code,
		evt.entity_id,
		evt.event_id,
		'Cost'					DR_REFERENCE_3,
		'Liability'				CR_REFERENCE_3,
		to_char(cdl.dr_code_combination_id)	DR_REFERENCE_2,
		to_char('-99')				CR_REFERENCE_2
	from PA_MC_COST_DIST_LINES_ALL mc,
	     PA_COST_DISTRIBUTION_LINES_ALL cdl,
	     PA_EXPENDITURE_ITEMS_ALL ei,
	     PA_IMPLEMENTATIONS_ALL imp,
	     XLA_EVENTS evt,
	     HR_ORGANIZATION_INFORMATION hoi
	where mc.expenditure_item_id = cdl.expenditure_item_id
	and mc.line_num = cdl.line_num
	and mc.xla_migrated_flag is null
--	and mc.batch_name is not null   ....Commented for bug 7415060
	and mc.transfer_status_code = 'A'
	and mc.expenditure_item_id = ei.expenditure_item_id
	and cdl.acct_event_id = evt.event_id
	and cdl.org_id = imp.org_id
	and hoi.organization_id = imp.org_id
	and hoi.org_information_context = 'Operating Unit Information'
	and cdl.expenditure_item_id between l_start_eiid and l_end_eiid
	AND NVL(p_cost_cross,'C') = 'C' /* Bug 5408944 */
     UNION ALL
	 SELECT /*+ USE_NL (cdl mc ei) INDEX(cdl, PA_CC_DIST_LINES_U2)
		INDEX( mc, PA_MC_CC_DIST_LINES_U2)  INDEX(ei, PA_EXPENDITURE_ITEMS_PK) */
		to_number(hoi.org_information2) legal_entity_id,
		mc.set_of_books_id ledger_id,
		imp.org_id,
		mc.expenditure_item_id,
		mc.line_num cdl_line_num,
		mc.line_type cdl_line_type,
		mc.line_type grouped_line_type,
		cdl.gl_date,
		cdl.gl_period_name,
		mc.gl_batch_name,
		cdl.dr_code_combination_id dr_code_combination_id,
		cdl.cr_code_combination_id cr_code_combination_id,
		mc.amount acct_raw_cost,
		cdl.denom_transfer_price denom_raw_cost,
		cdl.denom_tp_currency_code denom_currency_code,
		mc.acct_tp_rate_date conversion_date,
		mc.acct_tp_exchange_rate conversion_rate,
		mc.acct_tp_rate_type conversion_type,
		ei.tp_amt_type_code,
		decode(mc.line_type,  'BL', 'Borrowed and Lent',
				      'PC', 'Prov Cost Reclass') je_category,
		evt.event_type_code,
		decode(mc.line_type, 'BL', 'BORROWED_AND_LENT',
				     'PC', 'PRVDR_RECVR_RECLASS') event_class_code,
		evt.entity_id,
		evt.event_id,
		'Cross Charge Debit'			DR_REFERENCE_3,
		'Cross Charge Credit'			CR_REFERENCE_3,
		to_char(cdl.dr_code_combination_id)	DR_REFERENCE_2,
		to_char(cdl.cr_code_combination_id)	CR_REFERENCE_2
	from PA_MC_CC_DIST_LINES_ALL mc,
	     PA_CC_DIST_LINES_ALL cdl,
	     PA_EXPENDITURE_ITEMS_ALL ei,
	     PA_IMPLEMENTATIONS_ALL imp,
	     XLA_EVENTS evt,
	     HR_ORGANIZATION_INFORMATION hoi
	where mc.expenditure_item_id = cdl.expenditure_item_id
	and mc.line_num = cdl.line_num
	and mc.xla_migrated_flag is null
	and mc.transfer_status_code = 'A'
--	and mc.gl_batch_name is not null   ....Commented for bug 7415060
	and mc.expenditure_item_id = ei.expenditure_item_id
	and cdl.acct_event_id = evt.event_id
	and cdl.org_id = imp.org_id
	and hoi.organization_id = imp.org_id
	and hoi.org_information_context = 'Operating Unit Information'
	and cdl.expenditure_item_id between l_start_eiid and l_end_eiid
	AND NVL(p_cost_cross,'X') = 'X' /* Bug 5408944 */;

	l_rows_processed := SQL%ROWCOUNT;

	IF nvl(l_rows_processed,0) > 0 THEN


		INSERT ALL INTO XLA_AE_HEADERS
		     (upg_batch_id,
		      upg_source_application_id,
		      application_id,
		      amb_context_code,
		      entity_id,
		      event_id,
		      event_type_code,
		      ae_header_id,
		      ledger_id,
		      accounting_date,
		      period_name,
		      balance_type_code,
		      je_category_name,
		      gl_transfer_status_code,
		      accounting_entry_status_code,
		      accounting_entry_type_code,
		      creation_date,
		      created_by,
		      last_update_date,
		      last_updated_by,
		      last_update_login,
		      program_update_date,
		      program_id,
		      program_application_id,
		      request_id)
		     VALUES
		     (p_upg_batch_id,
		      l_pa_app_id,
		      l_pa_app_id,
		      'DEFAULT',
		      entity_id,
		      event_id,
		      event_type_code,
		      xla_ae_headers_s.nextval,
		      ledger_id,
		      gl_date,
		      gl_period_name,
		      'A',                     --balance type Actual
		      je_category,
		      'Y',                     --gl transfer status
		      'F',                     --acct entry status code final
		      'STANDARD',
		      l_date,
		      l_user,
		      l_date,
		      l_user,
		      l_user,
		      l_date,
		      l_user,
		      l_pa_app_id,
		      l_request_id
		      )
		      INTO PA_XLA_UPG_EVENTS_GT
		      (expenditure_item_id,
		       event_id,
		       grouped_line_type,
		       event_date,
		       header_id,
		       entity_id,
		       ledger_id
		      )
		      VALUES
		      (expenditure_item_id,
		       event_id,
		       grouped_line_type,
		       gl_date,
		       xla_ae_headers_s.nextval,
		       entity_id,
		       ledger_id
		      )
		      select  lines_gt.event_id,
			      lines_gt.ledger_id,
			      lines_gt.expenditure_item_id,
			      lines_gt.entity_id,
			      lines_gt.grouped_line_type,
			      lines_gt.gl_date,
			      lines_gt.gl_period_name ,
			      lines_gt.legal_entity_id,
			      lines_gt.je_category,
			      lines_gt.event_type_code
			  from PA_XLA_UPG_LINES_GT lines_gt
			  group by lines_gt.event_id,
			      lines_gt.ledger_id,
			      lines_gt.expenditure_item_id,
			      lines_gt.entity_id,
			      lines_gt.grouped_line_type,
			      lines_gt.gl_date,
			      lines_gt.gl_period_name ,
			      lines_gt.legal_entity_id,
			      lines_gt.je_category,
			      lines_gt.event_type_code;


		   INSERT ALL INTO XLA_AE_LINES
		      (upg_batch_id,
		       ae_header_id,
		       ae_line_num,
		       application_id,
		       code_combination_id,
		       gl_transfer_mode_code,
		       accounted_dr,
		       accounted_cr,
		       currency_code,
		       currency_conversion_date,
		       currency_conversion_rate,
		       currency_conversion_type,
		       gl_sl_link_table,
		       entered_dr,
		       entered_cr,
		       description,
		       accounting_class_code,
		       creation_date,
		       created_by,
		       last_update_date,
		       last_updated_by,
		       last_update_login,
		       program_update_date,
		       program_id,
		       program_application_id,
		       request_id,
		       gain_or_loss_flag,
		       accounting_date,
		       ledger_id
		      )
		  VALUES
		   (   p_upg_batch_id,
		       header_id,
		       ae_line_num,
		       l_pa_app_id,
		       code_combination_id,
		       'D',
		       acct_dr,
		       acct_cr,
		       currency_code,
		       conversion_date,
		       conversion_rate,
		       conversion_type,
		       'XLAJEL',
		       entered_dr,
		       entered_cr,
		       '',                             --description TBD
		       acct_class,
		       l_date,
		       l_user,
		       l_date,
		       l_user,
		       l_user,
		       l_date,
		       l_user,
		       l_pa_app_id,
		       l_request_id,
		       'N',
		       gl_date,
		       ledger_id)
		   INTO XLA_DISTRIBUTION_LINKS
		      (application_id,
		       event_id,
		       ae_header_id,
		       ae_line_num,
		       source_distribution_type,
		       source_distribution_id_num_1,
		       source_distribution_id_num_2,
		       merge_duplicate_code,
		       event_type_code,
		       event_class_code,
		       upg_batch_id,
		       ref_ae_header_id,
		       temp_line_num,
		       unrounded_accounted_dr,
		       unrounded_accounted_cr,
		       unrounded_entered_dr,
		       unrounded_entered_cr)
		    VALUES
		      (l_pa_app_id,
		       event_id,
		       header_id,
		       ae_line_num,
		       cdl_line_type,
		       expenditure_item_id,
		       cdl_line_num,
		       'N',
		       event_type_code,
		       event_class_code,
		       p_upg_batch_id,
		       header_id,
		       ae_line_num,
		       acct_dr,
		       acct_cr,
		       entered_dr,
		       entered_cr)
		   INTO PA_REV_AE_LINES_TMP
		      (ae_header_id,
		       ae_line_num,
		       gl_batch_name,
		       code_combination_id,
		       dist_type)
		   VALUES
		      (header_id,
		       ae_line_num,
		       batch_name,
		       reference_2,
		       reference_3)
		SELECT
		       header_id AS header_id,
		       event_id AS event_id,
		       code_combination_id AS code_combination_id,
		       acct_class AS acct_class,
		       acct_dr AS acct_dr,
		       acct_cr AS acct_cr,
		       entered_dr AS entered_dr,
		       entered_cr AS entered_cr,
		       currency_code AS currency_code,
		       conversion_date AS conversion_date,
		       conversion_rate AS conversion_rate,
		       conversion_type AS conversion_type,
		       event_type_code AS event_type_code,
		       event_class_code AS event_class_code,
		       expenditure_item_id AS expenditure_item_id,
		       cdl_line_num AS cdl_line_num,
		       cdl_line_type AS cdl_line_type,
		       batch_name AS batch_name,
		       reference_2 AS reference_2,
		       reference_3 AS reference_3,
		       ledger_id AS ledger_id,
		       gl_date AS gl_date,
		       RANK() OVER (PARTITION BY header_id
				    ORDER BY expenditure_item_id, cdl_line_num, position) AS ae_line_num
		FROM
		(select /*+ USE_NL (event_gt lines_gt imp)
			INDEX(lines_gt, PA_XLA_UPG_LINES_GT_N1) INDEX(imp, GL_IMPORT_REFERENCES_N3) */
			lines_gt.position,
			event_gt.header_id,
			event_gt.event_id,
			lines_gt.code_combination_id,
			decode(lines_gt.position,
				1, decode(lines_gt.cdl_line_type,
					  'PC', 'RECLASS_DESTINATION',
					  'BL', decode(lines_gt.tp_amt_type_code,
							'REVENUE_TRANSFER', 'RECEIVER_REVENUE',
									    'RECEIVER_COST'),
					  'COST'),
				2, decode(lines_gt.cdl_line_type,
					  'PC', 'RECLASS_SOURCE',
					  'BL', decode(lines_gt.tp_amt_type_code,
							'REVENUE_TRANSFER', 'PROVIDER_REVENUE',
									    'PROVIDER_COST'),
					  'COST_CLEARING')
				) acct_class,
			decode(position, 1, decode(sign(lines_gt.acct_raw_cost),  1, lines_gt.acct_raw_cost, 0 , 0 , NULL),
					 2, decode(sign(lines_gt.acct_raw_cost), -1, -1*lines_gt.acct_raw_cost, 0, NULL , NULL)) acct_dr,
			decode(position, 1, decode(sign(lines_gt.acct_raw_cost), -1, -1*lines_gt.acct_raw_cost, 0, NULL, NULL),
					 2, decode(sign(lines_gt.acct_raw_cost),  1, 1*lines_gt.acct_raw_cost, 0, 0 , NULL)) acct_cr,
			decode(position, 1, decode(sign(lines_gt.denom_raw_cost),  1, lines_gt.denom_raw_cost,0, 0, NULL),
					 2,decode(sign(lines_gt.denom_raw_cost),-1,-1*lines_gt.denom_raw_cost, 0, NULL, NULL)) entered_dr,
			decode(position, 1, decode(sign(lines_gt.denom_raw_cost), -1, -1*lines_gt.denom_raw_cost, 0, NULL, NULL),
					 2,decode(sign(lines_gt.denom_raw_cost),1,1*lines_gt.denom_raw_cost,0, 0, NULL)) entered_cr,
			lines_gt.denom_currency_code currency_code,
		        lines_gt.conversion_date,
		        lines_gt.conversion_rate,
		        lines_gt.conversion_type,
			lines_gt.event_type_code event_type_code,
			lines_gt.event_class_code,
			lines_gt.expenditure_item_id expenditure_item_id,
			lines_gt.cdl_line_num,
			lines_gt.cdl_line_type,
			lines_gt.batch_name,
			lines_gt.reference_2,
			lines_gt.reference_3,
			lines_gt.ledger_id,
			lines_gt.gl_date
		from PA_XLA_UPG_LINES_GT lines_gt,
		     PA_XLA_UPG_EVENTS_GT event_gt
		where event_gt.expenditure_item_id = lines_gt.expenditure_item_id
		and event_gt.event_date = lines_gt.gl_date
		and event_gt.ledger_id = lines_gt.ledger_id /* Added for bug 4919145 */
		and event_gt.grouped_line_type = lines_gt.grouped_line_type
		);


		UPDATE /*+ INDEX( mc, PA_MC_COST_DIST_LINES_ALL_U1) */
			pa_mc_cost_dist_lines_all mc
		SET mc.xla_migrated_flag = 'Y'
		WHERE mc.expenditure_item_id between l_start_eiid and l_end_eiid
		  and mc.line_type in ('R','C','D')
		  and exists ( select /*+ INDEX(lines_gt, PA_XLA_UPG_LINES_GT_N1) */
				      1
                                 from PA_XLA_UPG_LINES_GT lines_gt
                                where lines_gt.expenditure_item_id = mc.expenditure_item_id
                                  and lines_gt.cdl_line_num        = mc.line_num);


		UPDATE /*+ INDEX( mc, PA_MC_CC_DIST_LINES_U2) */
			pa_mc_cc_dist_lines_all mc
		SET mc.xla_migrated_flag = 'Y'
		WHERE mc.expenditure_item_id between l_start_eiid and l_end_eiid
		  and mc.line_type in ('BL','PC')
		  and exists ( select /*+ INDEX(lines_gt, PA_XLA_UPG_LINES_GT_N1) */
				      1
                                 from PA_XLA_UPG_LINES_GT lines_gt
                                where lines_gt.expenditure_item_id = mc.expenditure_item_id
                                  and lines_gt.cdl_line_num        = mc.line_num);


		BEGIN

			UPDATE XLA_AE_LINES xal
			SET gl_sl_link_id = (SELECT /*+ INDEX(tmp, PA_REV_AE_LINES_TMP_U1) */
						  gl_sl_link_id
					     FROM GL_IMPORT_REFERENCES imp,
						  PA_REV_AE_LINES_TMP tmp
					     WHERE xal.ae_header_id = tmp.ae_header_id
					     AND xal.ae_line_num = tmp.ae_line_num
					     AND tmp.gl_batch_name = imp.reference_6
					     AND tmp.code_combination_id = nvl(imp.reference_2,-99)
					     AND tmp.dist_type = imp.reference_3
					     AND ROWNUM = 1)
			WHERE application_id = l_pa_app_id
			AND upg_batch_id = p_upg_batch_id
			AND gl_sl_link_id is null
			AND EXISTS ( SELECT /*+ INDEX(tmp1, PA_REV_AE_LINES_TMP_U1) */ 1
				     FROM PA_REV_AE_LINES_TMP tmp1
				     WHERE xal.ae_header_id   = tmp1.ae_header_id
				     AND xal.ae_line_num    = tmp1.ae_line_num);

		EXCEPTION
		WHEN OTHERS THEN
			null;
		END;

	 END IF;  /* If any rows to be processed */


	ad_parallel_updates_pkg.processed_id_range(
			       l_rows_processed,
			       l_end_eiid);

	COMMIT;

	ad_parallel_updates_pkg.get_id_range(
			       l_start_eiid,
			       l_end_eiid,
			       l_any_rows_to_process,
			       p_batch_size,
			       FALSE);

END LOOP;



EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END UPGRADE_MC_COST_XCHARGE;

------------------------------------------------------------------------------------------------------

PROCEDURE POPULATE_CTRL_TABLE (p_batch_id	IN  NUMBER,
			       x_mrc_enabled	OUT NOCOPY VARCHAR2)
IS

	CURSOR c_date_range is
	SELECT ledger_id,  to_char(min(start_date),'J') min_date, to_char(max(end_date),'J') max_date
	FROM gl_period_statuses
	WHERE application_id = 275
	AND migration_status_code = 'P'
	GROUP BY ledger_id;

	l_start_date    date	DEFAULT NULL;
	l_end_date      date	DEFAULT NULL;
	l_jeh_min_id	number	DEFAULT NULL;
	l_jeh_max_id	number	DEFAULT NULL;
	l_cdl_min_eiid  number	DEFAULT NULL;
	l_cdl_max_eiid  number	DEFAULT NULL;
	l_ccd_min_eiid  number	DEFAULT NULL;
	l_ccd_max_eiid  number	DEFAULT NULL;
	l_min_eiid      number  DEFAULT NULL;
	l_max_eiid      number  DEFAULT NULL;
	l_cnt           number  DEFAULT NULL;

	l_cost_cross NUMBER := 0;

BEGIN

--------------------------------------------------------------------------------------------------
-- For each ledger min and max gl dates are stored in the control table so as to avoid joining
-- with gl_period_statuses table in the main upgrade
---------------------------------------------------------------------------------------------------

	INSERT INTO pa_xla_upg_ctrl (REFERENCE, MIN_VALUE, MAX_VALUE,
					LEDGER_ID, BATCH_ID, STATUS)
	SELECT 'GL_PERIOD_STATUSES', to_char(min(start_date),'J') , to_char(max(end_date),'J') , ledger_id, p_batch_id, 'P'
	FROM gl_period_statuses
	WHERE application_id = 275
	AND migration_status_code = 'P'
	AND exists (select 1 from pa_implementations_all where set_of_books_id
	            = ledger_id and SAME_PA_GL_PERIOD = 'N')
	GROUP BY ledger_id;

	INSERT INTO pa_xla_upg_ctrl (REFERENCE, MIN_VALUE, MAX_VALUE,
					LEDGER_ID, BATCH_ID, STATUS)
	SELECT 'GL_PERIOD_STATUSES', to_char(min(start_date),'J') , to_char(max(end_date),'J') , ledger_id, p_batch_id, 'P'
	FROM gl_period_statuses
	WHERE application_id = 8721
	AND migration_status_code = 'P'
	AND exists (select 1 from pa_implementations_all where set_of_books_id
	            = ledger_id and SAME_PA_GL_PERIOD = 'Y')
	GROUP BY ledger_id;

	select min(to_date(min_value,'J') ) , max(to_date(max_value,'J') )
	  into l_start_date, l_end_date
	 from pa_xla_upg_ctrl
	 where batch_id = p_batch_id
	   and reference = 'GL_PERIOD_STATUSES';




 /*Bug 49435531 */
        INSERT INTO PA_PRIM_REP_LEGER_tmp (prim_ledger_id,
                                           denorm_ledger_id,
                                           period_name,
                                           batch_id)
                             SELECT   distinct per1.ledger_id,
                                      per1.ledger_id,
                                      per1.period_name,
                                      p_batch_id
                               FROM  gl_period_statuses per,
                                     gl_period_statuses per1
                              WHERE  per.application_id in(275,8721)
                                AND  per.migration_status_code ='P'
                                AND  per1.application_id =101
                                AND  per1.ledger_id      = per.ledger_id
                                AND  (per1.start_date between per.start_date and per.end_date OR
                                      per1.end_date  between per.start_date and per.end_date)
				AND  EXISTS ( Select null
				                from pa_implementations_all
					       where set_of_books_id = per.ledger_id
						   and (((per.application_id = 275 and
						             SAME_PA_GL_PERIOD = 'N')
						         or (per.application_id = 8721 and
						             SAME_PA_GL_PERIOD = 'Y')
									 )
						        ));


        INSERT INTO PA_PRIM_REP_LEGER_tmp (prim_ledger_id,
                                           denorm_ledger_id,
                                           period_name,
                                           batch_id)
                             SELECT   distinct per.prim_ledger_id,
                                      mc.reporting_set_of_books_id,
                                      per.period_name,
                                      p_batch_id
                               FROM  PA_PRIM_REP_LEGER_tmp per,
                                     gl_mc_reporting_options_11i mc,
				     pa_implementations_all imp
             WHERE  per.prim_ledger_id      = mc.primary_set_of_books_id
                                AND  mc.application_id       in( 275,8721)
				AND  imp.org_id              = mc.org_id;



---------------------------------------------------------------------------------------------------
-- Min and max header ids are stored in the control table to drive the gl_import_references upgrade
---------------------------------------------------------------------------------------------------
/* Removed as currently we are using ID_RANGE_SCAN_EQUI_ROWSETS instead of rowid
	BEGIN
		Select min(je_header_id), max(je_header_id)
		into l_jeh_min_id, l_jeh_max_id
		from gl_je_headers hd,
                     PA_PRIM_REP_LEGER_tmp per
               where hd.LEDGER_ID     = per.denorm_ledger_id
                 and  hd.PERIOD_NAME  = per.PERIOD_NAME
                 and  hd.je_source    = 'Project Accounting'
		 and per.batch_id = p_batch_id;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		l_jeh_min_id := 0;
		l_jeh_max_id := 0;
	END;*/

      l_jeh_min_id  := null;
      l_jeh_max_id  := null;

	INSERT INTO pa_xla_upg_ctrl (REFERENCE, MIN_VALUE, MAX_VALUE, LEDGER_ID, BATCH_ID, STATUS)
	VALUES ('GL_JE_HEADERS', l_jeh_min_id, l_jeh_max_id, '', p_batch_id, 'P');

---------------------------------------------------------------------------------------------------
-- Min and max expenditure item ids are stored in the control table to drive the cost and cross
-- charge upgrade
---------------------------------------------------------------------------------------------------

	l_cost_cross := 0;

	SELECT /*+ parallel(cdl) */  nvl(min(expenditure_item_id),0), nvl(max(expenditure_item_id),0)
	INTO l_cdl_min_eiid, l_cdl_max_eiid
	FROM pa_cost_distribution_lines_all cdl
	WHERE gl_date between l_start_date and l_end_date
	AND transfer_status_code = 'A'
	AND acct_event_id is null
	AND batch_name is not null;

	If l_cdl_min_eiid = 0 and l_cdl_max_eiid = 0 then
		l_cost_cross := 3; -- Only Cross Charge Is there
	End If;

	SELECT /*+ parallel(ccdl) */ nvl(min(expenditure_item_id),0), nvl(max(expenditure_item_id),0)
	INTO l_ccd_min_eiid, l_ccd_max_eiid
	FROM pa_cc_dist_lines_all ccdl
	WHERE gl_date between l_start_date and l_end_date
	AND transfer_status_code = 'A'
	AND acct_event_id is null
	AND gl_batch_name is not null;

	If l_ccd_min_eiid = 0 and l_ccd_max_eiid = 0 then
		if l_cost_cross = 3 then
			l_cost_cross := 1; -- Neither Cost nor Cross Charge is there
		Else
			l_cost_cross := 2; -- Only cost is there
		End If;
	End If;

	/* bug 5408944
		l_cost_cross		Meaning
		------------------      ---------
		0                       Both Cost and Cross charge
		1                       Neither Cost nor Cross Charge is there
		2                       Only Cost is there
		3                       Only Cross Charge is there

	*/

	INSERT INTO pa_xla_upg_ctrl (REFERENCE, MIN_VALUE, MAX_VALUE, LEDGER_ID, BATCH_ID, STATUS)
	VALUES ('COST_CROSS_FLAG', l_cost_cross, l_cost_cross, '', p_batch_id, 'P');


	l_min_eiid := 0;

	if l_cdl_min_eiid > 0 then
		l_min_eiid := l_cdl_min_eiid;
	end if;

	if l_ccd_min_eiid > 0  then
           if l_min_eiid = 0 then
              l_min_eiid := l_ccd_min_eiid;
           else
                if l_ccd_min_eiid < l_min_eiid then
  		  l_min_eiid := l_ccd_min_eiid;
                end if;
           end if;
	end if;


	l_max_eiid := 0;

	if l_cdl_max_eiid > 0 then
		l_max_eiid := l_cdl_max_eiid;
	end if;

	if l_ccd_max_eiid > 0  then
                if l_ccd_max_eiid > l_max_eiid then
		   l_max_eiid := l_ccd_max_eiid;
                end if;
	end if;


	INSERT INTO pa_xla_upg_ctrl (REFERENCE, MIN_VALUE, MAX_VALUE, LEDGER_ID, BATCH_ID, STATUS)
	VALUES ('PA_EXPENDITURE_ITEMS_ALL', l_min_eiid, l_max_eiid, '', p_batch_id, 'P');



---------------------------------------------------------------------------------------------------
-- If mrc is enabled, a record is inserted in the control table to drive mrc upgrade
---------------------------------------------------------------------------------------------------

	BEGIN
		SELECT count(*)
		INTO l_cnt
		FROM gl_mc_reporting_options_11i
		WHERE application_id in ( 275, 8721)
		AND enabled_flag = 'Y';
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		l_cnt := 0;
	END;

	IF l_cnt > 0
	THEN
		INSERT INTO pa_xla_upg_ctrl (REFERENCE, MIN_VALUE, MAX_VALUE, LEDGER_ID, BATCH_ID, STATUS)
		VALUES ('MRC', l_min_eiid, l_max_eiid, '', p_batch_id, 'P');

		x_mrc_enabled := 'Y';
	ELSE
		x_mrc_enabled := 'N';
	END IF;

EXCEPTION
  WHEN OTHERS THEN
     RAISE;

END POPULATE_CTRL_TABLE;

END PA_XLA_UPGRADE;

/
