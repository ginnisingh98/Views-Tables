--------------------------------------------------------
--  DDL for Package Body JG_ALLOCATE_JOURNALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ALLOCATE_JOURNALS_PKG" AS
  /* $Header: jgzztakb.pls 120.3 2004/02/20 08:53:56 fholst ship $ */

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       prepare_journal_select						|
|  DESCRIPTION								|
|  	Prepare the journal select dynamic SQL				|
|  CALLED BY                                                            |
|       allocate							|
 --------------------------------------------------------------------- */
PROCEDURE prepare_journal_select IS
  l_fiscal_journal_qry 	VARCHAR2(10000) := NULL;
BEGIN
  JG_UTILITY_PKG.log('> JG_ALLOCATE_JOURNALS_PKG.prepare_journal_select');
  --
  -- prepare the query variable
  --
  l_fiscal_journal_qry := JG_ALLOCATE_JOURNALS_PKG.get_dynamic_select_string;
  --
  -- Prepare the main Dynamic SQL statement
  --
  JG_UTILITY_PKG.debug('Initialize dynamic cursor: start');
  JG_UTILITY_PKG.debug(SUBSTR(l_fiscal_journal_qry,1,130));
  JG_UTILITY_PKG.debug(SUBSTR(l_fiscal_journal_qry,
			      INSTR(l_fiscal_journal_qry,'FROM',1),
			      100));
  JG_UTILITY_PKG.debug(SUBSTR(SUBSTR(l_fiscal_journal_qry,
			      INSTR(l_fiscal_journal_qry, 'WHERE', 1),
			      400),1,100));
  JG_UTILITY_PKG.debug(SUBSTR(SUBSTR(l_fiscal_journal_qry,
			      INSTR(l_fiscal_journal_qry, 'WHERE', 1),
			      400),101,200));
  JG_UTILITY_PKG.debug(SUBSTR(SUBSTR(l_fiscal_journal_qry,
			      INSTR(l_fiscal_journal_qry, 'WHERE', 1),
			      400),201,300));
  JG_UTILITY_PKG.debug(SUBSTR(SUBSTR(l_fiscal_journal_qry,
			      INSTR(l_fiscal_journal_qry, 'WHERE', 1),
			      400),301,400));
  JG_UTILITY_PKG.debug(SUBSTR(SUBSTR(l_fiscal_journal_qry,
			      INSTR(l_fiscal_journal_qry, 'WHERE', 1),
			      400),401,500));
  JG_UTILITY_PKG.debug(SUBSTR(SUBSTR(l_fiscal_journal_qry,
			      INSTR(l_fiscal_journal_qry, 'WHERE', 1),
			      400),501,600));
  --
  -- Open the main cursor
  --
  JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, l_fiscal_journal_qry, DBMS_SQL.NATIVE);
  --
  -- Column Definitions listed in dynamic select clause by datatype
  --
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,1,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_batch_id);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,2,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_batch_name, 100);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,3,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_header_id);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,4,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_header_name, 100);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,5,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_code, 15);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,6,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_conversion_type, 30);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,7,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_conversion_date);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,8,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_conversion_rate);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,9,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.encumbrance_type_id);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,10,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.budget_version_id);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,11,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cost_center, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,12,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.account_number, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,13,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment1, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,14 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment2, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,15 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment3, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,16 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment4, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,17 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment5, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,18 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment6, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,19 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment7, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,20 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment8, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,21 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment9, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,22 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment10, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,23 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment11, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,24 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment12, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,25 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment13, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,26 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment14, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,27 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment15, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,28 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment16, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,29 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment17, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,30 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment18, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,31 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment19, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,32 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment20, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,33 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment21, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,34 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment22, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,35 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment23, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,36 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment24, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,37 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment25, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,38 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment26, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,39 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment27, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,40 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment28, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,41 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment29, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,42 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment30, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,43 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_line_num);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,44 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_cr);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,45 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_dr);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,46 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_cr);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,47 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_dr);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,48 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.stat_amount);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,49 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.subledger_doc_sequence_id);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,50 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.subledger_doc_sequence_value);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,51 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute1, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,52 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute2, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,53 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute3, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,54 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute4, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,55 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute5, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,56 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute6, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,57 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute7, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,58 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute8, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,59 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute9, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,60 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute10, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,61 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute11, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,62 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute12, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,63 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute13, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,64 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute14, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,65 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute15, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,66 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute16, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,67 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute17, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,68 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute18, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,69 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute19, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,70 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute20, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,71 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.context, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,72 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.context2, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,73 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.context3, 150);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,74 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.invoice_date);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,75 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.tax_code, 15);
  DBMS_SQL.DEFINE_COLUMN( JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,76 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.invoice_identifier, 20);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,77,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.invoice_amount);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,78,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.ussgl_transaction_code, 30);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,79 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.jgzz_recon_ref, 240);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 80,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.code_combination_id);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,81 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.row_id,50);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,82,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.effective_date);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,83,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.external_reference,80);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,84,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_doc_sequence_name,30);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,85,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_doc_sequence_value);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,86,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.alloc_row_id, 50);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,87,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.period_name, 15);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,88,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_id);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,89,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.account_range_id);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,90,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.offset_account, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,91,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_low, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,92,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_high, 25);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,93,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.partial_allocation, 1);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,94,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_description, 240);
  DBMS_SQL.DEFINE_COLUMN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c,95,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.rule_set_name, 100);
  JG_UTILITY_PKG.log( '< JG_ALLOCATE_JOURNALS_PKG.prepare_journal_select');
END prepare_journal_select;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTOIN                                                   	|
|       get_cc_acc_range_ids						|
|  DESCRIPTION								|
|  	Get Ids of the Cost Center Range and the Account Range for the  |
|       current fiscal journal line. 	     	 	       	   	|
|  CALLED BY                                                            |
|       JG_ALLOCATE_JOURNALS_PKG.allocate				|
|  RETURNS								|
|  	TRUE if journal line STILL does not fall under either a cost    |
|       center range or an account range.   	       	      		|
|	FALSE if we find a combination of cost center range and         |
|       account range that the line falls under.  In this latter case,  |
|       we have found a line that falls under more than one cost        |
|       center range as they are allowed to overlap.  The main dynamic  |
|       query will have found this/these other valid combinations and   |
|       the current invalid combination should be discarded without     |
|       displaying an error message. Remember we ONLY call this         |
|       function if we have an invalid journal line returned without    |
|       a cost center range id or an account range id.                  |
 --------------------------------------------------------------------- */
FUNCTION get_cc_acc_range_ids RETURN BOOLEAN IS
  CURSOR c_range_ids IS
  SELECT ccr.cc_range_id,
  	 acr.account_range_id,
  	 acr.offset_account,
  	 ccr.cc_range_low,
  	 ccr.cc_range_high
  FROM   jg_zz_ta_account_ranges acr,
  	 jg_zz_ta_cc_ranges      ccr
  WHERE  NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cost_center, ccr.cc_range_low)
                                       BETWEEN ccr.cc_range_low AND ccr.cc_range_high
  AND    ccr.rule_set_id = JG_JOURNAL_ALLOCATIONS_PKG.G_rule_set_id
  AND    ccr.cc_range_id = acr.cc_range_id (+)
  AND    JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.account_number
                                       BETWEEN acr.account_range_low (+) AND acr.account_range_high (+)
  ORDER BY acr.offset_account;
BEGIN
  JG_UTILITY_PKG.log( '> JG_ALLOCATE_JOURNALS_PKG.get_cc_acc_range_ids');
  OPEN c_range_ids;
  FETCH c_range_ids INTO JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_id,
                         JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.account_range_id,
			 JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.offset_account,
			 JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_low,
			 JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_high;
  IF (JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.offset_account IS NOT NULL) THEN
    CLOSE c_range_ids;
    JG_UTILITY_PKG.log( '< JG_ALLOCATE_JOURNALS_PKG.get_cc_acc_range_ids');
    RETURN FALSE;
  ELSE
    CLOSE c_range_ids;
    JG_UTILITY_PKG.log( '< JG_ALLOCATE_JOURNALS_PKG.get_cc_acc_range_ids');
    RETURN TRUE;
  END IF;
END get_cc_acc_range_ids;


/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       Write_Report_Titles						|
|  DESCRIPTION								|
|  	Write Report Title Lines to Output		        	|
|  CALLED BY                                                            |
|       Allocate							|
 --------------------------------------------------------------------- */
PROCEDURE write_report_titles IS
  l_output1 	VARCHAR2(2000) 	:= NULL;
  l_output2 	VARCHAR2(2000) 	:= NULL;
  l_output3  	VARCHAR2(2000) 	:= NULL;
  l_output310   VARCHAR2(2000)  := NULL;
  l_output4  	VARCHAR2(2000) 	:= NULL;
  l_output5  	VARCHAR2(2000) 	:= NULL;
  l_output6  	VARCHAR2(2000) 	:= NULL;
BEGIN
  JG_UTILITY_PKG.log( '> JG_ALLOCATE_JOURNALS_PKG.write_report_titles');
  IF (JG_JOURNAL_ALLOCATIONS_PKG.G_unalloc_request_id IS NULL) THEN
    FND_MESSAGE.set_name(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_JGZZTAJA_REPORT_TITLE1');
    FND_MESSAGE.set_token('SOB_NAME', RPAD(JG_JOURNAL_ALLOCATIONS_PKG.G_set_of_books_name, 67));
    -- Bug 876171: The following line is too long for a row of length 180 characters
    -- FND_MESSAGE.set_token('DATE_TIME', LPAD(fnd_date.date_to_charDT(SYSDATE), 90));
    FND_MESSAGE.set_token('DATE_TIME', LPAD(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'), 76));
    l_output1 := FND_MESSAGE.get;
    FND_MESSAGE.set_name(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_JGZZTAJA_REPORT_TITLE2');
    FND_MESSAGE.set_token('CONC_REQUEST_ID', TO_CHAR(JG_JOURNAL_ALLOCATIONS_PKG.G_request_id));
    l_output2 := FND_MESSAGE.get;
    l_output3 := JG_JOURNAL_ALLOCATIONS_PKG.G_period_name;
    l_output310 := JG_JOURNAL_ALLOCATIONS_PKG.G_currency_code;
    FND_MESSAGE.SET_NAME (JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name ,'JG_ZZ_JGZZTAJA_ERR_HEADING2');
    l_output4 := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME (JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name ,'JG_ZZ_JGZZTAJA_ERR_HEADING3');
    l_output5 := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME (JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name ,'JG_ZZ_JGZZTAJA_ERR_HEADING1');
    l_output6 := FND_MESSAGE.GET;
  ELSE
    FND_MESSAGE.set_name(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_JGZZTAJA_U_REPORT_TITLE1');
    FND_MESSAGE.set_token('DATE_TIME', fnd_date.date_to_charDT(SYSDATE));
    l_output1 := FND_MESSAGE.get;
    FND_MESSAGE.set_name(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_JGZZTAJA_REPORT_TITLE2');
    FND_MESSAGE.set_token('CONC_REQUEST_ID', TO_CHAR(JG_JOURNAL_ALLOCATIONS_PKG.G_request_id));
    l_output2 := FND_MESSAGE.get;
    FND_MESSAGE.SET_NAME (JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name ,'JG_ZZ_JGZZTAJA_UNALLOC_HDING2');
    l_output4 := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME (JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name ,'JG_ZZ_JGZZTAJA_UNALLOC_HDING3');
    l_output5 := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME (JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name ,'JG_ZZ_JGZZTAJA_UNALLOC_HDING1');
    l_output6 := FND_MESSAGE.GET;
  END IF;
  JG_UTILITY_PKG.out(l_output1);
  JG_UTILITY_PKG.out(l_output2);
  JG_UTILITY_PKG.out(l_output3);
  JG_UTILITY_PKG.out(l_output310);
  --FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  JG_UTILITY_PKG.out(l_output4);
  FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  JG_UTILITY_PKG.out(l_output5);
  JG_UTILITY_PKG.out(l_output6);
  JG_UTILITY_PKG.log( '< JG_ALLOCATE_JOURNALS_PKG.write_report_titles');
END write_report_titles;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       Write_Report_Headings						|
|  DESCRIPTION								|
|  	Write Report Headings to the Output File			|
|  CALLED BY                                                            |
|       Create_Journal							|
 --------------------------------------------------------------------- */
PROCEDURE write_report_headings IS
  l_line_output1 VARCHAR2(2000) := NULL;
  l_line_output2 VARCHAR2(2000) := NULL;
  l_line_output3 VARCHAR2(2000) := NULL;
BEGIN
  JG_UTILITY_PKG.log('> JG_ALLOCATE_JOURNALS_PKG.write_report_headings');
  FND_MESSAGE.SET_NAME (JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name ,'JG_ZZ_JGZZTAJA_HEADING1');
  l_line_output1 := FND_MESSAGE.GET;
  FND_MESSAGE.SET_NAME (JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name ,'JG_ZZ_JGZZTAJA_HEADING2');
  l_line_output2 := FND_MESSAGE.GET;
  FND_MESSAGE.SET_NAME (JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name ,'JG_ZZ_JGZZTAJA_HEADING3');
  l_line_output3 := FND_MESSAGE.GET;
  FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 2);
  JG_UTILITY_PKG.out(l_line_output1);
  FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  JG_UTILITY_PKG.out(l_line_output2);
  JG_UTILITY_PKG.out(l_line_output3);
  JG_UTILITY_PKG.log('< JG_ALLOCATE_JOURNALS_PKG.write_report_headings');
END Write_Report_Headings;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       write_allocated_lines_output					|
|  DESCRIPTION								|
|  	Write Allocated line Details to the Output File			|
|  CALLED BY                                                            |
|       Create_Journal_Allocations					|
 --------------------------------------------------------------------- */
PROCEDURE write_allocated_lines_output (lp_total_fiscal_accted_cr_amt 	IN NUMBER,
					lp_total_fiscal_accted_dr_amt 	IN NUMBER) IS
  l_acct_seg_string   		VARCHAR2(2000);
  l_destn_acct_seg_string 	VARCHAR2(2000);
  l_delimiter		    	VARCHAR2(100);
  l_acct_posn_start   		NUMBER;
  l_acct_posn_end     		NUMBER;
  l_previous_rec_id		VARCHAR2(1000) := '#####################';
  l_total_message		VARCHAR2(100);
  l_total_separator		VARCHAR2(300) := NULL;
  l_cc_range_separator		VARCHAR2(200) := NULL;
  l_range_offset_remark		VARCHAR2(50) := NULL;
  -- Bug 876171: Add the variable
  l_no_data_message             VARCHAR2(50);
BEGIN

  JG_UTILITY_PKG.log('> JG_ALLOCATE_JOURNALS_PKG.write_allocated_lines_output');

  --
  -- For each allocated row
  --
  FOR i IN 1..JG_CREATE_JOURNALS_PKG.i LOOP

    --
    -- Retrieve the full accounting flexfield string based on original journal line
    --
    l_acct_seg_string := FND_FLEX_EXT.get_segs( JG_JOURNAL_ALLOCATIONS_PKG.G_GL_appln_short_name,
				       	        JG_JOURNAL_ALLOCATIONS_PKG.G_GL_acct_flex_code,
					       	JG_JOURNAL_ALLOCATIONS_PKG.G_chart_of_accounts_id,
					     	JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).code_combination_id);
    --
    -- Find out NOCOPY what the segment delimiter is
    --
    l_delimiter := FND_FLEX_EXT.get_delimiter(JG_JOURNAL_ALLOCATIONS_PKG.G_GL_appln_short_name,
 		 			      JG_JOURNAL_ALLOCATIONS_PKG.G_GL_acct_flex_code,
					      JG_JOURNAL_ALLOCATIONS_PKG.G_chart_of_accounts_id);
    l_destn_acct_seg_string := l_acct_seg_string;

    --
    -- Destination flexfield formulated differently if segment method
    -- is zero-filled or for offset line grouped by account range
    --
    IF JG_JOURNAL_ALLOCATIONS_PKG.G_destn_segment_method = 'ZF' OR
                    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).je_batch_name = 'OFFSET FOR ACCOUNT RANGE' THEN
      --
      -- For each segment
      --
      FOR j IN 1..JG_JOURNAL_ALLOCATIONS_PKG.G_num_of_segments LOOP
          --
          -- Don't zero-fill the natural account or balancing segment
          --
          IF j NOT IN (JG_JOURNAL_ALLOCATIONS_PKG.G_acct_segment_num, JG_JOURNAL_ALLOCATIONS_PKG.G_bal_segment_num) THEN
	    IF j = 1 THEN
	      l_acct_posn_start := 0;
	    ELSE
 	      l_acct_posn_start := INSTR(l_destn_acct_seg_string ,l_delimiter ,1 ,j-1);
	    END IF;
	    IF j = JG_JOURNAL_ALLOCATIONS_PKG.G_num_of_segments THEN
	      l_acct_posn_end := LENGTH(l_destn_acct_seg_string) + 1;
	    ELSE
	      l_acct_posn_end := INSTR(l_destn_acct_seg_string ,l_delimiter ,1 ,j);
	    END IF;
            l_destn_acct_seg_string := SUBSTR(l_destn_acct_seg_string, 1, l_acct_posn_start)||
	    			       JG_JOURNAL_ALLOCATIONS_PKG.G_zero_fill_arr(j).zero_string||
				       SUBSTR(l_destn_acct_seg_string, l_acct_posn_end);
          END IF;
      END LOOP;  -- each segment
    END IF; -- Zero Fill Method
    --
    -- For both the Journal Account and Zero-Filled method, we are
    -- substituting the natural account for the destination account number
    --
    IF JG_JOURNAL_ALLOCATIONS_PKG.G_acct_segment_num = 1 THEN
      l_acct_posn_start := 0;
    ELSE
      l_acct_posn_start := INSTR(l_destn_acct_seg_string ,l_delimiter ,1 ,JG_JOURNAL_ALLOCATIONS_PKG.G_acct_segment_num - 1);
    END IF;
    IF JG_JOURNAL_ALLOCATIONS_PKG.G_acct_segment_num = JG_JOURNAL_ALLOCATIONS_PKG.G_num_of_segments THEN
      l_acct_posn_end := LENGTH(l_destn_acct_seg_string) + 1;
    ELSE
      l_acct_posn_end	 := INSTR(l_destn_acct_seg_string ,l_delimiter ,1 ,JG_JOURNAL_ALLOCATIONS_PKG.G_acct_segment_num);
    END IF;
    l_destn_acct_seg_string := SUBSTR(l_destn_acct_seg_string, 1, l_acct_posn_start)||
    			         JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).destn_account_number||
			         SUBSTR(l_destn_acct_seg_string, l_acct_posn_end);

    -- If the next line is for a new cc range and i<>1, then insert the line separator
    IF i <> 1 THEN
      IF JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).cc_range_id <> JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i-1).cc_range_id THEN
         FND_MESSAGE.set_name(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_JGZZTAJA_CCRNGE_SEPRATOR');
         l_cc_range_separator := FND_MESSAGE.get;
         JG_UTILITY_PKG.out(RPAD(' ', 115)||l_cc_range_separator);
      END IF;
    END IF;

    IF JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).je_batch_name = 'OFFSET FOR ACCOUNT RANGE' THEN
        JG_UTILITY_PKG.out(RPAD(' ', 115)||RPAD(SUBSTR(NVL(l_destn_acct_seg_string, ' '), 1, 34), 34)||' '||
          LPAD(SUBSTR(NVL(TO_CHAR(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).destn_accted_dr,
          JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask), ' '), 1, 15), 15)||' '||
          LPAD(SUBSTR(NVL(TO_CHAR(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).destn_accted_cr,
          JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask), ' '), 1, 15), 15)||' '||JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).remarks);
    ELSIF l_previous_rec_id <>  JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).je_batch_name||
 	 		       JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).je_header_name||
	   		     TO_CHAR(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).je_line_num) THEN
        JG_UTILITY_PKG.out( RPAD(SUBSTR(NVL(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).je_batch_name, ' '), 1, 20), 20)||' '||
          RPAD(SUBSTR(NVL(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).je_header_name, ' '), 1, 19), 19)||' '||
          RPAD(SUBSTR(NVL(l_acct_seg_string, ' '), 1, 35), 35)||' '||
          LPAD(SUBSTR(TO_CHAR(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).je_line_num), 1, 3), 3)||' '||
          LPAD(SUBSTR(NVL(TO_CHAR(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).accounted_dr,
          JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask), ' '), 1, 15), 15)||' '||
          LPAD(SUBSTR(NVL(TO_CHAR(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).accounted_cr,
          JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask), ' '), 1, 15), 15)||'   '||
          RPAD(SUBSTR(NVL(l_destn_acct_seg_string, ' '), 1, 34), 34)||' '||
          LPAD(SUBSTR(NVL(TO_CHAR(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).destn_accted_dr,
          JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask), ' '), 1, 15), 15)||' '||
          LPAD(SUBSTR(NVL(TO_CHAR(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).destn_accted_cr,
          JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask), ' '), 1, 15), 15)||' '||JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).remarks);
    ELSE
        JG_UTILITY_PKG.out(RPAD(' ', 115)|| RPAD(SUBSTR(NVL(l_destn_acct_seg_string, ' '), 1, 34), 34)||' '||
	  LPAD(SUBSTR(NVL(TO_CHAR(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).destn_accted_dr, JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask), ' '), 1, 15), 15)||' '||
	  LPAD(SUBSTR(NVL(TO_CHAR(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).destn_accted_cr, JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask), ' '), 1, 15), 15)||' '||JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).remarks);
    END IF;

    l_previous_rec_id := JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).je_batch_name|| JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).je_header_name|| TO_CHAR(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(i).je_line_num);
  END LOOP;  -- Each row

  -- Output appopriate message if no rows allocated
  IF JG_CREATE_JOURNALS_PKG.i = 0 THEN
  -- Bug 876171: Add a new line before the no-data-found token
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT,1);
    FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_NO_DATA_FOUND');
  -- Bug 876171: Replace the following line with new lines
  -- JG_UTILITY_PKG.out(FND_MESSAGE.GET);
    l_no_data_message := FND_MESSAGE.GET;
    JG_UTILITY_PKG.out(RPAD(' ', 75)||RPAD(l_no_data_message,30)||RPAD(' ', 75));
  ELSE
    --
    -- Print totals
    --
    FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_JGZZTAJA_TOTAL_SEPARATOR');
    l_total_separator := FND_MESSAGE.GET;
    JG_UTILITY_PKG.out(l_total_separator);
    FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_JGZZTAJA_TOTAL');
    l_total_message := FND_MESSAGE.GET;
    JG_UTILITY_PKG.out(RPAD(' ', 41)||RPAD(l_total_message, 40)||
      LPAD(SUBSTR(NVL(TO_CHAR(lp_total_fiscal_accted_dr_amt,
      JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask), ' '), 1, 15), 15)||' '||
      LPAD(SUBSTR(NVL(TO_CHAR(lp_total_fiscal_accted_cr_amt,
      JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask), ' '), 1, 15), 15)||
      LPAD(SUBSTR(NVL(TO_CHAR(JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_dr_amt,
      JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask), ' '), 1, 15), 53)||' '||
      LPAD(SUBSTR(NVL(TO_CHAR(JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_cr_amt,
      JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask), ' '), 1, 15), 15));
    JG_UTILITY_PKG.log('< JG_ALLOCATE_JOURNALS_PKG.write_allocated_lines_output');
  END IF;
END write_allocated_lines_output;


/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|       Get_Dynamic_Select_String				        |
|  DESCRIPTION								|
|  	Substitutes in variable strings into overall SELECT string	|
|  CALLED BY                                                            |
|       Create_Journal_Allocations					|
|  RETURNS								|
|  	SELECT string							|
 --------------------------------------------------------------------- */
FUNCTION get_dynamic_select_string RETURN VARCHAR2 IS
  l_sob_where			VARCHAR2(200) := NULL;
  l_period_name_where	 	VARCHAR2(200) := NULL;
  l_currency_code_where	 	VARCHAR2(200) := NULL;
  l_bal_seg_where	 	VARCHAR2(200) := NULL;
  l_bal_type_where	 	VARCHAR2(200) := NULL;
  l_budenc_where	 	VARCHAR2(200) := NULL;
  l_allocate_where		VARCHAR2(200) := NULL;
  l_hint_clause			VARCHAR2(200) := NULL;
  l_cc_range_where		VARCHAR2(200) := NULL;
  l_acct_range_where            VARCHAR2(200) := NULL;
  l_inline_view_clause		VARCHAR2(1000) := NULL;
  l_non_view_columns            VARCHAR2(500) := NULL;
  l_rule_sets_clause		VARCHAR2(200) := NULL;
  l_rule_set_where		VARCHAR2(200) := NULL;
  l_account_type_where          VARCHAR2(200) := NULL;
  l_order_clause		VARCHAR2(200) := NULL;
BEGIN
  JG_UTILITY_PKG.log( '> JG_ALLOCATE_JOURNALS_PKG.get_dynamic_select_string');
  --
  -- Allocation
  --
  IF (JG_JOURNAL_ALLOCATIONS_PKG.G_unalloc_request_id IS NULL) THEN
    --
    -- Set of Books ID
    -- GC Ledger Architecture change:
    l_sob_where := 'AND jlv.ledger_id  = '||TO_CHAR(JG_JOURNAL_ALLOCATIONS_PKG.G_set_of_books_id)||' ';
    JG_UTILITY_PKG.debug('l_sob_where = ' || l_sob_where);
    --
    -- Period Name
    --
    IF JG_JOURNAL_ALLOCATIONS_PKG.G_period_name IS NOT NULL THEN
      l_period_name_where := 'AND jlv.period_name = '''||JG_JOURNAL_ALLOCATIONS_PKG.G_period_name||''' ';
      JG_UTILITY_PKG.debug('l_period_name_where = ' || l_period_name_where);
    END IF;
    --
    -- Currency Code
    --
    IF JG_JOURNAL_ALLOCATIONS_PKG.G_currency_code IS NOT NULL THEN
      l_currency_code_where := 'AND jlv.currency_code = '''||JG_JOURNAL_ALLOCATIONS_PKG.G_currency_code||''' ';
      JG_UTILITY_PKG.debug('l_currency_code_where = ' ||l_currency_code_where);
    END IF;
    --
    -- Balancing Segment Where
    --
    IF (JG_JOURNAL_ALLOCATIONS_PKG.G_balance_segment_value IS NOT NULL) THEN
      l_bal_seg_where :=  'AND ' || JG_JOURNAL_ALLOCATIONS_PKG.G_acct_flex_segmt_arr(JG_JOURNAL_ALLOCATIONS_PKG.G_bal_segment_num).segment_col_name ||
                          ' = '''||JG_JOURNAL_ALLOCATIONS_PKG.G_balance_segment_value||'''';
      JG_UTILITY_PKG.debug('l_bal_seg_where = ' ||l_bal_seg_where);
    END IF;
    --
    -- Balance Type and budget version id OR encumbrance type id
    --
    l_bal_type_where := ' AND jlv.actual_flag = '''||JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type||''' ';
    JG_UTILITY_PKG.debug('l_bal_type_where = ' || l_bal_type_where);

    IF (JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type = 'B') THEN
      l_budenc_where := ' AND jlv.budget_version_id = '|| TO_CHAR(JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type_id)||' ';
      JG_UTILITY_PKG.debug('l_budenc_where = ' || l_budenc_where);
    ELSIF (JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type = 'E') THEN
      l_budenc_where := ' AND jlv.encumbrance_type_id = '||
                                  TO_CHAR(JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type_id)||' ';
      JG_UTILITY_PKG.debug('l_budenc_where = ' || l_budenc_where);
    END IF;
    l_allocate_where := ' AND jlv.status||'''' = ''P'' AND jlv.request_id IS NULL ';
    JG_UTILITY_PKG.debug('l_allocate_where = '|| l_allocate_where);

    l_inline_view_clause := '(SELECT ccr.cc_range_id          '||
                            ',       ccr.cc_range_low         '||
       			    ',       ccr.cc_range_high        '||
			    ',       ccr.description	      '||
                            ',       acr.account_range_id     '||
                            ',       acr.account_range_low    '||
                            ',       acr.account_range_high   '||
                            ',       acr.offset_account       '||
       			    'FROM    jg_zz_ta_account_ranges acr       '||
                            ',       jg_zz_ta_cc_ranges ccr            '||
                            'WHERE   ccr.cc_range_id = acr.cc_range_id '||
                            'AND     ccr.rule_set_id = '||TO_CHAR(JG_JOURNAL_ALLOCATIONS_PKG.G_rule_set_id)||') ranges, ';

    l_non_view_columns :=   ',      ranges.cc_range_id		  '||
		 	    ',	    ranges.account_range_id       '||
		            ',	    ranges.offset_account	  '||
	                    ',      ranges.cc_range_low           '||
			    ',      ranges.cc_range_high          '||
			    ',      rs.partial_allocation     '||
			    ',      ranges.description cc_range_description '||
			    ',	    rs.name rule_set_name ';

    l_rule_sets_clause :=   '       jg_zz_ta_rule_sets rs,            ';

    l_rule_set_where   :=   ' AND rs.rule_set_id = '||TO_CHAR(JG_JOURNAL_ALLOCATIONS_PKG.G_rule_set_id)||' ' ;

    IF (JG_JOURNAL_ALLOCATIONS_PKG.G_cc_segment_num IS NOT NULL) THEN
      IF (JG_JOURNAL_ALLOCATIONS_PKG.G_acct_flex_segmt_arr(JG_JOURNAL_ALLOCATIONS_PKG.G_cc_segment_num).segment_vset_fmt_type <> 'N') THEN
        l_cc_range_where := 'jlv.'||JG_JOURNAL_ALLOCATIONS_PKG.G_acct_flex_segmt_arr(JG_JOURNAL_ALLOCATIONS_PKG.G_cc_segment_num).segment_col_name||
	                    '       BETWEEN ranges.cc_range_low (+) AND ranges.cc_range_high (+) ';
      ELSE
        l_cc_range_where := 'jlv.'||JG_JOURNAL_ALLOCATIONS_PKG.G_acct_flex_segmt_arr(JG_JOURNAL_ALLOCATIONS_PKG.G_cc_segment_num).segment_col_name||
	                      '       BETWEEN TO_NUMBER(ranges.cc_range_low) (+) AND TO_NUMBER(ranges.cc_range_high) (+) ';
      END IF;
    ELSE
      l_cc_range_where := '1 = 1 ';
    END IF;
    JG_UTILITY_PKG.debug('l_cc_range_where = '|| l_cc_range_where);

    IF JG_JOURNAL_ALLOCATIONS_PKG.G_acct_flex_segmt_arr(JG_JOURNAL_ALLOCATIONS_PKG.G_acct_segment_num).segment_vset_fmt_type <> 'N' THEN
       l_acct_range_where := ' AND   jlv.'||JG_JOURNAL_ALLOCATIONS_PKG.G_acct_flex_segmt_arr(JG_JOURNAL_ALLOCATIONS_PKG.G_acct_segment_num).segment_col_name||
	 		     '       BETWEEN ranges.account_range_low (+) AND ranges.account_range_high (+) ';
    ELSE
       l_acct_range_where := ' AND   jlv.'||JG_JOURNAL_ALLOCATIONS_PKG.G_acct_flex_segmt_arr(JG_JOURNAL_ALLOCATIONS_PKG.G_acct_segment_num).segment_col_name||
 		     '       BETWEEN TO_NUMBER(ranges.account_range_low) (+) AND TO_NUMBER(ranges.account_range_high) (+) ';
    END IF;

    l_account_type_where := ' AND NVL(rs.account_type, jlv.account_type) = jlv.account_type ';
    l_order_clause := ' ORDER BY jlv.currency_code, ranges.cc_range_id, ranges.account_range_id';
  --
  -- Unallocate
  --
  ELSE
    l_cc_range_where := '1 = 1 ';
    l_non_view_columns :=   ',      NULL	  '||
		 	    ',	    NULL          '||
		            ',	    NULL	  '||
	                    ',      NULL          '||
			    ',      NULL          '||
			    ',      NULL          '||
			    ',      NULL          '||
			    ',	    NULL	  ';
    l_hint_clause := '/*+ INDEX(jlv JG_ZZ_TA_ALLOCATED_LINES_N1) */';
    l_allocate_where := ' AND jlv.request_id = '|| TO_CHAR(JG_JOURNAL_ALLOCATIONS_PKG.G_unalloc_request_id) || ' ';
    JG_UTILITY_PKG.debug('l_allocate_where = '|| l_allocate_where);
  END IF;
  JG_UTILITY_PKG.log( '< JG_ALLOCATE_JOURNALS_PKG.get_dynamic_select_string');
  RETURN 		 		 'SELECT '||l_hint_clause||' jlv.je_batch_id  '||
					 ',      jlv.je_batch_name	  	  '||
					 ',      jlv.je_header_id		  '||
 					 ',      jlv.je_header_name		  '||
 					 ',      jlv.currency_code		  '||
 					 ',      jlv.currency_conversion_type	  '||
 					 ',      jlv.currency_conversion_date	  '||
 					 ',      jlv.currency_conversion_rate	  '||
 					 ',      jlv.encumbrance_type_id	  '||
 					 ',      jlv.budget_version_id		  '||
					  JG_JOURNAL_ALLOCATIONS_PKG.G_cc_seg_num_string||
					  JG_JOURNAL_ALLOCATIONS_PKG.G_acc_seg_num_string||
					 ',	 jlv.segment1			  '||
					 ',	 jlv.segment2			  '||
					 ',	 jlv.segment3			  '||
					 ',	 jlv.segment4			  '||
					 ',	 jlv.segment5			  '||
					 ',	 jlv.segment6			  '||
					 ',	 jlv.segment7			  '||
					 ',	 jlv.segment8			  '||
					 ',	 jlv.segment9			  '||
					 ',	 jlv.segment10			  '||
					 ',	 jlv.segment11			  '||
					 ',	 jlv.segment12			  '||
					 ',	 jlv.segment13			  '||
					 ',	 jlv.segment14			  '||
					 ',	 jlv.segment15			  '||
					 ',	 jlv.segment16			  '||
					 ',	 jlv.segment17			  '||
					 ',	 jlv.segment18	  	  	  '||
					 ',	 jlv.segment19	  	  	  '||
					 ',	 jlv.segment20	  	  	  '||
					 ',	 jlv.segment21	  	  	  '||
					 ',	 jlv.segment22	  	  	  '||
					 ',	 jlv.segment23	  	  	  '||
					 ',	 jlv.segment24	  	  	  '||
					 ',	 jlv.segment25	  	  	  '||
					 ',	 jlv.segment26	  	  	  '||
					 ',	 jlv.segment27	  	  	  '||
					 ',	 jlv.segment28	  	  	  '||
					 ',	 jlv.segment29	  	  	  '||
					 ',	 jlv.segment30	  	  	  '||
 					 ',      jlv.je_line_num		  '||
 					 ',      jlv.accounted_cr		  '||
 					 ',      jlv.accounted_dr		  '||
 					 ',      jlv.entered_cr			  '||
 					 ',      jlv.entered_dr			  '||
 					 ',      jlv.stat_amount		  '||
 					 ',      jlv.subledger_doc_sequence_id 	  '||
 					 ',      jlv.subledger_doc_sequence_value '||
 					 ',      jlv.attribute1			  '||
 					 ',      jlv.attribute2			  '||
 					 ',      jlv.attribute3			  '||
 					 ',      jlv.attribute4			  '||
 					 ',      jlv.attribute5			  '||
 					 ',      jlv.attribute6			  '||
 					 ',      jlv.attribute7			  '||
 					 ',      jlv.attribute8			  '||
 					 ',      jlv.attribute9			  '||
 					 ',      jlv.attribute10		  '||
 					 ',      jlv.attribute11		  '||
 					 ',      jlv.attribute12		  '||
 					 ',      jlv.attribute13		  '||
 					 ',      jlv.attribute14		  '||
 					 ',      jlv.attribute15		  '||
 					 ',      jlv.attribute16		  '||
 					 ',      jlv.attribute17		  '||
 					 ',      jlv.attribute18		  '||
 					 ',      jlv.attribute19		  '||
 					 ',      jlv.attribute20		  '||
 					 ',      jlv.context			  '||
 					 ',      jlv.context2			  '||
 					 ',      jlv.context3			  '||
 					 ',      jlv.invoice_date		  '||
 					 ',      jlv.tax_code			  '||
 					 ',      jlv.invoice_identifier		  '||
 					 ',      jlv.invoice_amount		  '||
 					 ',      jlv.ussgl_transaction_code	  '||
 					 ',      jlv.jgzz_recon_ref		  '||
					 ',	 jlv.code_combination_id	  '||
					 ',	 jlv.row_id			  '||
					 ',	 jlv.effective_date		  '||
					 ',	 jlv.external_reference		  '||
					 ',	 jlv.je_doc_sequence_name	  '||
					 ',	 jlv.je_doc_sequence_value	  '||
					 ',	 jlv.alloc_row_id		  '||
					 ',	 jlv.period_name		  '||
					 l_non_view_columns||
					 'FROM   '||l_inline_view_clause||
					            l_rule_sets_clause||
					 '       jg_zz_ta_je_lines_v jlv          '||
 					 'WHERE  '||l_cc_range_where               ||
					 l_acct_range_where			   ||
					 l_rule_set_where			   ||
					 l_account_type_where			   ||
  					 l_sob_where				   ||
					 l_period_name_where			   ||
					 l_currency_code_where			   ||
					 l_bal_seg_where			   ||
					 l_bal_type_where			   ||
					 l_budenc_where			   	   ||
					 l_allocate_where		      	   ||
 					 l_order_clause;
END get_dynamic_select_string;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|       Record_Locked							|
|  DESCRIPTION								|
|  	Determines whether current row returned by cursor is locked by	|
|	another process.   	       		   	     	    	|
|  CALLED BY                                                            |
|       JG_ALLOCATE_JOURNALS_PKG.allocate				|
|  RETURNS								|
|  	TRUE if record locked, FALSE otherwise				|
 --------------------------------------------------------------------- */
FUNCTION record_locked RETURN BOOLEAN IS
l_header_id	 gl_je_lines.je_header_id%TYPE;
BEGIN
  JG_UTILITY_PKG.log( '> JG_ALLOCATE_JOURNALS_PKG.record_locked');
  JG_UTILITY_PKG.debug('rowid = '||CHARTOROWID(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.row_id));

  SELECT je_header_id
  INTO   l_header_id
  FROM   gl_je_lines
  WHERE  rowid = CHARTOROWID(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.row_id)
  FOR UPDATE OF je_header_id NOWAIT;

  JG_UTILITY_PKG.log( '< JG_ALLOCATE_JOURNALS_PKG.record_locked');
  RETURN FALSE;
EXCEPTION
  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
    JG_UTILITY_PKG.debug( 'Record is Locked');
    RETURN TRUE;
  WHEN OTHERS THEN
    JG_UTILITY_PKG.debug( 'OTHERS Failure '||TO_CHAR(SQLCODE)||': '||SQLERRM);
    RAISE;
END record_locked;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|       Valid_Journal							|
|  DESCRIPTION								|
|  	Validates Current Journal to check for row locking, line falls  |
|       within a cost center and account range, and valid allocation    |
|       percentage rule lines have been defined.    	  		|
|  CALLED BY                                                            |
|       JG_ALLOCATE_JOURNALS_PKG.allocate				|
|  RETURNS								|
|  	TRUE if line valid, FALSE otherwise and error message code      |
|       returned in parameter	  	    	      	      		|
 --------------------------------------------------------------------- */
FUNCTION Valid_Journal(p_err_msg_code IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

BEGIN

  IF (JG_ALLOCATE_JOURNALS_PKG.Record_Locked) THEN
     JG_UTILITY_PKG.debug('Record Locked Processing');
     p_err_msg_code := 'JG_ZZ_RECORD_LOCKED';
     RETURN FALSE;
  --
  -- Allocation mode
  --
  ELSIF (JG_JOURNAL_ALLOCATIONS_PKG.G_unalloc_request_id IS NULL) THEN
     --
     -- Check that cost_center exists within a defined cost center range
     --
     IF JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_id IS NULL THEN
        --
        -- Repopulate range ids in G_journal_qry_rec, because the cc_range_id
	-- may have been null because the account_range_id was null (see dynamic select)
	-- and we need to return a specific message as to why the journal line failed
        --
	IF (NOT JG_ALLOCATE_JOURNALS_PKG.get_cc_acc_range_ids) THEN
	   -- return false, but no error message to be displayed, just continue processing
	   p_err_msg_code := NULL;
	   RETURN FALSE;
	END IF;
        --
	-- Recheck
        --
        IF JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_id IS NULL THEN
  	    p_err_msg_code := 'JG_ZZ_MISSING_COST_CENTER_RULE';
            RETURN FALSE;
	END IF;
     END IF;  -- cc range id check
     --
     -- Check that account_number exists within a defined account number range
     --
     IF JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.account_range_id IS NULL THEN
        p_err_msg_code := 'JG_ZZ_MISSING_ACC_NUMBER_RULE';
        RETURN FALSE;
     END IF;  -- account range id check

  END IF;

  RETURN TRUE;

END Valid_Journal;

/* ------------------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                             |
|       allocate								|
|  DESCRIPTION								        |
|	Allocates the Journals							|
|	Pseudocode:   								|
|	Write Report Titles to Output file					|
|	FOR each source journal line LOOP					|
|	    Validate line: record not locked and line falls under a valid 	|
|	        combination of cost center range and account number range.	|
|           IF in allocation mode THEN	   	     	     	    		|
|	       call JG_CREATE_JOURNAL_PKG.create_journal			|
|	       Insert the journal line into the allocated lines table to show   |
|	          that the line has been successfully allocated	      	 	|
|	    ELSIF in unallocation mode THEN	      				|
|	       Delete journal line from allocated lines table to show that the  |
|	          line has been unallocated	  	      	      	   	|
|	    END IF     	   							|
|	END LOOP 		     						|
|	IF in allocation mode THEN						|
|	    IF last journal line processed had an offset account defined at the |
|	         account range level THEN      	  	 	 	    	|
|	       Add offset allocation line to array	 	 	    	|
|	       Insert allocation line in GL_INTERFACE				|
|	    END IF    		      	 					|
|	    Write Details of Allocated Lines to Output File from array		|
|	END IF	  	     	       	     	       				|
|	    									|
|  CALLED BY 									|
|	JG_JOURNAL_ALLOCATION_PKG.main						|
--------------------------------------------------------------------------------*/
PROCEDURE allocate IS
  l_dummy_int			INTEGER;
  l_total_fiscal_accted_cr_amt 	NUMBER := 0;
  l_total_fiscal_accted_dr_amt 	NUMBER := 0;
  x_rowid			ROWID;
  l_ext_precision		NUMBER;
  l_min_acct_unit		NUMBER;
  l_err_msg_code		VARCHAR2(100) := NULL;
  l_first_valid_row		BOOLEAN := TRUE;
  l_is_valid_row		BOOLEAN;
-- Bug 876171: Add more variables for token printout
  l_fail_ndf_flag               NUMBER := 0;
  l_unal_ndf_flag               NUMBER := 0;
  l_no_data_found_message       VARCHAR2(50);
  l_eof_message                 VARCHAR2(50);
BEGIN
  JG_UTILITY_PKG.log( '> JG_ALLOCATE_JOURNALS_PKG.allocate');
  --
  -- Prepare the execution report Title and Error Headings;
  -- for unallocation, the same column headings are used with different titles.
  --
  JG_ALLOCATE_JOURNALS_PKG.write_report_titles;
  --
  -- Prepare the main SQL statement, the dynamic parts
  --
  JG_ALLOCATE_JOURNALS_PKG.prepare_journal_select;

  JG_UTILITY_PKG.debug( 'Execute Journal Select');

  l_dummy_int := DBMS_SQL.EXECUTE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c);

  JG_UTILITY_PKG.debug(TO_CHAR(SYSDATE, 'HH24:MI:SS'));
  -- Loop for each row
  WHILE DBMS_SQL.FETCH_ROWS(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c) > 0 LOOP
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 1 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_batch_id);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 2 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_batch_name);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 3 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_header_id);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 4 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_header_name);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 5 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_code);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 6 ,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_conversion_type);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 7,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_conversion_date);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 8,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_conversion_rate);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 9,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.encumbrance_type_id);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 10,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.budget_version_id);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 11,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cost_center);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 12,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.account_number);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 13,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment1);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 14,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment2);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 15,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment3);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 16,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment4);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 17,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment5);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 18,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment6);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 19,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment7);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 20,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment8);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 21,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment9);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 22,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment10);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 23,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment11);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 24,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment12);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 25,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment13);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 26,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment14);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 27,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment15);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 28,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment16);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 29,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment17);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 30,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment18);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 31,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment19);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 32,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment20);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 33,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment21);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 34,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment22);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 35,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment23);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 36,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment24);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 37,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment25);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 38,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment26);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 39,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment27);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 40,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment28);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 41,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment29);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 42,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment30);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 43,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_line_num);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 44,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_cr);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 45,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_dr);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 46,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_cr);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 47,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_dr);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 48,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.stat_amount);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 49,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.subledger_doc_sequence_id);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 50,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.subledger_doc_sequence_value);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 51,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute1);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 52,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute2);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 53,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute3);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 54,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute4);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 55,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute5);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 56,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute6);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 57,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute7);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 58,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute8);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 59,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute9);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 60,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute10);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 61,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute11);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 62,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute12);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 63,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute13);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 64,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute14);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 65,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute15);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 66,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute16);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 67,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute17);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 68,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute18);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 69,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute19);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 70,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute20);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 71,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.context);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 72,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.context2);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 73,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.context3);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 74,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.invoice_date);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 75,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.tax_code);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 76,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.invoice_identifier);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 77,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.invoice_amount);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 78,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.ussgl_transaction_code);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 79,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.jgzz_recon_ref);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 80,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.code_combination_id);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 81,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.row_id);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 82,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.effective_date);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 83,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.external_reference);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 84,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_doc_sequence_name);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 85,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_doc_sequence_value);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 86,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.alloc_row_id);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 87,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.period_name);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 88,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_id);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 89,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.account_range_id);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 90,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.offset_account);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 91,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_low);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 92,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_high);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 93,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.partial_allocation);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 94,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_description);
    DBMS_SQL.COLUMN_VALUE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c, 95,
		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.rule_set_name);
    JG_UTILITY_PKG.debug('Dynamic cursor column assignments: finished');
    JG_UTILITY_PKG.debug('cost_center = '||JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cost_center);
    JG_UTILITY_PKG.debug('cc_id = '||
                to_char(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.code_combination_id));

    --
    --  Get Entered Currency Format Mask and the currency's precision for reporting and calculating any rounding errors
    --
    -- Bug 2638803, changed format mask length from 15 to 18
    JG_ALLOCATE_JOURNALS_PKG.G_currency_format_mask :=
	 FND_CURRENCY.GET_FORMAT_MASK(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_code,18);
    JG_UTILITY_PKG.debug( 'curr format mask = '||JG_ALLOCATE_JOURNALS_PKG.G_currency_format_mask);
    FND_CURRENCY.GET_INFO(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_code,
     	  		  JG_ALLOCATE_JOURNALS_PKG.G_currency_precision,
    			  l_ext_precision,
			  l_min_acct_unit);
    JG_UTILITY_PKG.debug( 'curr precision = '||JG_ALLOCATE_JOURNALS_PKG.G_currency_precision);


    -- ********************* VALIDATION ***************************************
    -- In the validation, the following things are checked:
    -- 1. Locking:  Make sure that the Journal Entry Line is not locked
    -- 2. Cost Center Range: Make sure JE line falls into a cost center range
    -- 3. Account Range: Make sure JE line falls into an account number range
    l_is_valid_row := Valid_Journal(l_err_msg_code);

    IF NOT l_is_valid_row AND l_err_msg_code IS NOT NULL THEN

       JG_UTILITY_PKG.debug('Invalid Journal Line found');
       IF (JG_JOURNAL_ALLOCATIONS_PKG.G_Error_Handling <> 'I') THEN
          JG_JOURNAL_ALLOCATIONS_PKG.G_retcode := '1';
          FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name,l_err_msg_code);
	  JG_CREATE_JOURNALS_PKG.write_error_to_output;

          -- Bug 876171: Set up l_fail_ndf_flag for no-data-found token
          l_fail_ndf_flag :=1;

          IF (JG_JOURNAL_ALLOCATIONS_PKG.G_Error_Handling = 'E') THEN
	     RAISE APP_EXCEPTION.application_exception;
	  END IF;
       END IF;

    -- N.B. there are some cases where we have an invalid row that we do not want to report as an
    -- error, instead it should just be skipped.  Hence, we check it is a valid row below.
    ELSIF l_is_valid_row THEN

       --
       -- Allocation Mode
       --
       IF (JG_JOURNAL_ALLOCATIONS_PKG.G_unalloc_request_id IS NULL) THEN

          --
          -- Initialize account_range_id and cc_range_id of the last journal record to the
          -- current record returned.
          -- Used in checking whether to create an offset account line first time round
          --
          IF l_first_valid_row THEN
             JG_UTILITY_PKG.debug('First Valid Row Initialization');
             JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.offset_account := NULL;
             JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.account_range_id :=
	         JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.account_range_id;
             JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.currency_code :=
                JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_code;
	     JG_CREATE_JOURNALS_PKG.G_Batch_Name := TO_CHAR(JG_JOURNAL_ALLOCATIONS_PKG.G_Request_Id)||' '||
			 			    JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.rule_set_name||' '||
						    JG_JOURNAL_ALLOCATIONS_PKG.G_period_name;
             l_first_valid_row := FALSE;
          END IF;

          --
          -- After validating the ranges, we have all the necessary information to do the next step...
          -- Insert the allocations
          --
          JG_CREATE_JOURNALS_PKG.create_journal;

          --
          -- Cumulative totals for report output (fiscal account)
          --
          l_total_fiscal_accted_cr_amt := l_total_fiscal_accted_cr_amt +
			    NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_cr, 0);
          l_total_fiscal_accted_dr_amt := l_total_fiscal_accted_dr_amt +
			    NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_dr, 0);

          JG_UTILITY_PKG.debug('fiscal accted cr running total = '||to_char(l_total_fiscal_accted_cr_amt));
          JG_UTILITY_PKG.debug('fiscal accted dr running total = '||to_char(l_total_fiscal_accted_dr_amt));

          --
          -- Insert line to show the journal has been allocated
          --
          IF (JG_JOURNAL_ALLOCATIONS_PKG.G_validate_only = 'N') THEN
            JG_ZZ_TA_ALLOCATED_LINES_PKG.insert_row(
	      x_rowid,
	      JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_batch_id,
	      JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_header_id,
	      JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_line_num,
	      SYSDATE,
	      JG_JOURNAL_ALLOCATIONS_PKG.G_user_id,
	      JG_JOURNAL_ALLOCATIONS_PKG.G_user_id,
	      SYSDATE,
	      JG_JOURNAL_ALLOCATIONS_PKG.G_login_id,
	      JG_JOURNAL_ALLOCATIONS_PKG.G_request_id,
	      JG_JOURNAL_ALLOCATIONS_PKG.G_progr_appl_id,
	      JG_JOURNAL_ALLOCATIONS_PKG.G_conc_progr_id,
	      SYSDATE);
          END IF;
          --
          -- Unallocation Mode
          --
       ELSE
          JG_UTILITY_PKG.log('> JG_ZZ_TA_ALLOCATED_LINES_PKG.delete_row');
          JG_ZZ_TA_ALLOCATED_LINES_PKG.delete_row(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.alloc_row_id);
          JG_UTILITY_PKG.log('< JG_ZZ_TA_ALLOCATED_LINES_PKG.delete_row');
          --
          -- Write Unallocated Fiscal Journal Line to the Output File
          --
          JG_CREATE_JOURNALS_PKG.write_error_to_output;

          -- Bug 876171: Set up l_unal_ndf_flag
          l_unal_ndf_flag := 1;

       END IF;  -- Allocation Mode check
       --
       -- Store this journal record as the last record fetched
       --
       JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec;
    END IF;  -- Valid Journal?
  END LOOP; -- Journals

  JG_UTILITY_PKG.debug('End of Journal Lines Loop');
  JG_UTILITY_PKG.debug(TO_CHAR(SYSDATE, 'HH24:MI:SS'));

  DBMS_SQL.CLOSE_CURSOR(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c);

  -- Bug 876171: Add new lines to print no-data-found token
  IF (JG_JOURNAL_ALLOCATIONS_PKG.G_unalloc_request_id IS NULL) THEN
     IF l_fail_ndf_flag = 0 THEN
     FND_FILE.NEW_LINE(FND_FILE.OUTPUT,1);
     FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_NO_DATA_FOUND');
     l_no_data_found_message := FND_MESSAGE.GET;
     JG_UTILITY_PKG.out(RPAD(' ',75)||RPAD(l_no_data_found_message,30)||RPAD(' ',75));
     END IF;
  ELSE
     IF l_unal_ndf_flag = 0 THEN
     FND_FILE.NEW_LINE(FND_FILE.OUTPUT,1);
     FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_NO_DATA_FOUND');
     l_no_data_found_message := FND_MESSAGE.GET;
     JG_UTILITY_PKG.out(RPAD(' ',45)||RPAD(l_no_data_found_message,30)||RPAD(' ',105));
     END IF;
  END IF;

  IF (JG_JOURNAL_ALLOCATIONS_PKG.G_unalloc_request_id IS NULL) THEN
     --
     -- If the last row returned had an offset account at the account range level, we need
     -- to create its corresponding offset line.
     --
     JG_UTILITY_PKG.debug('Last offset account was '||JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.offset_account);
     IF JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.offset_account IS NOT NULL THEN
        JG_CREATE_JOURNALS_PKG.Create_Offset_For_Acct_Range;
     END IF;

     --
     -- For Allocation, after allocating, the allocated lines are printed to the report
     --
     JG_ALLOCATE_JOURNALS_PKG.Write_Report_Headings;
     JG_UTILITY_PKG.debug('Write Rep Headings: End');
     JG_ALLOCATE_JOURNALS_PKG.write_allocated_lines_output(l_total_fiscal_accted_cr_amt,
			    				   l_total_fiscal_accted_dr_amt);
  END IF;

  -- Bug 876171: Add the following output lines for end-of-report token
  IF (JG_JOURNAL_ALLOCATIONS_PKG.G_unalloc_request_id IS NULL) THEN
     IF JG_CREATE_JOURNALS_PKG.i > 0 OR l_fail_ndf_flag > 0 THEN
     FND_FILE.NEW_LINE(FND_FILE.OUTPUT,1);
     FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_END_OF_REPORT');
     l_eof_message := FND_MESSAGE.GET;
     JG_UTILITY_PKG.out(RPAD(' ',75)||RPAD(l_eof_message,30)||RPAD(' ', 75));
     END IF;
  ELSE
     IF l_unal_ndf_flag > 0 THEN
     FND_FILE.NEW_LINE(FND_FILE.OUTPUT,1);
     FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_END_OF_REPORT');
     l_eof_message := FND_MESSAGE.GET;
     JG_UTILITY_PKG.out(RPAD(' ',45)||RPAD(l_eof_message,30)||RPAD(' ', 105));
     END IF;
  END IF;

  JG_UTILITY_PKG.log( '< JG_ALLOCATE_JOURNALS_PKG.allocate');
EXCEPTION
  WHEN OTHERS THEN
    JG_UTILITY_PKG.log( '< JG_ALLOCATE_JOURNALS_PKG.allocate');
    IF (DBMS_SQL.IS_OPEN(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c)) THEN
      DBMS_SQL.CLOSE_CURSOR(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_c);
    END IF;
    RAISE;
END allocate;

END JG_ALLOCATE_JOURNALS_PKG;

/
