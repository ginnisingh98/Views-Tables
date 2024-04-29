--------------------------------------------------------
--  DDL for Package Body JG_CREATE_JOURNALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_CREATE_JOURNALS_PKG" AS
/* $Header: jgzztalb.pls 120.2 2004/02/19 14:49:51 fholst ship $ */

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       zero_fill_segments						|
|  DESCRIPTION								|
|  	Every Accounting Flexfield segment other than the natural       |
|       account and the balancing segment is set to the longest valid   |
|       zero string 		  	     	    			|
|  CALLED BY                                                            |
|       create_journal_allocations					|
 --------------------------------------------------------------------- */
PROCEDURE zero_fill_segments(p_key_segment IN OUT NOCOPY KEY_SEGMENTS_TABLE) IS
BEGIN
  JG_UTILITY_PKG.log( '> JG_CREATE_JOURNALS_PKG.Zero_Fill_Segments');
  FOR j IN 1..JG_JOURNAL_ALLOCATIONS_PKG.G_num_of_segments LOOP
    JG_UTILITY_PKG.debug( 'segmt posn = '||to_char(j));
    JG_UTILITY_PKG.debug( 'ZF: segmt col name = '||JG_JOURNAL_ALLOCATIONS_PKG.G_zero_fill_arr(j).segment_col_name);
    JG_UTILITY_PKG.debug( 'ZF: segmt zero string = '||JG_JOURNAL_ALLOCATIONS_PKG.G_zero_fill_arr(j).zero_string);
    IF (JG_JOURNAL_ALLOCATIONS_PKG.G_zero_fill_arr(j).segment_col_name IS NOT NULL) THEN
      p_key_segment(TO_NUMBER(SUBSTR(JG_JOURNAL_ALLOCATIONS_PKG.G_zero_fill_arr(j).segment_col_name, 8)))
	      	      := JG_JOURNAL_ALLOCATIONS_PKG.G_zero_fill_arr(j).zero_string;
    END IF;
  END LOOP;
  JG_UTILITY_PKG.log( '> JG_CREATE_JOURNALS_PKG.Zero_Fill_Segments');
END zero_fill_segments;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|       insert_gl_interface						|
|  DESCRIPTION								|
|  	Insert analytical account journal lines into the GL_INTERFACE	|
|	table. 			  		  			|
|  CALLED BY                                                            |
|       Create_Journal_Allocations					|
|  RETURNS								|
|  	TRUE if row successfully created.			        |
 --------------------------------------------------------------------- */
FUNCTION insert_gl_interface(	lp_entered_dr            IN NUMBER,
				lp_entered_cr            IN NUMBER,
				lp_accounted_dr          IN NUMBER,
				lp_accounted_cr          IN NUMBER,
				lp_offset_group_bool	 IN BOOLEAN) RETURN BOOLEAN IS
BEGIN
  JG_UTILITY_PKG.log('> JG_CREATE_JOURNALS_PKG.insert_gl_interface');

IF NOT lp_offset_group_bool THEN

  INSERT INTO gl_interface (	STATUS,
				LEDGER_ID,  -- GC Ledger Architecture change
				ACCOUNTING_DATE,
				CURRENCY_CODE,
				USER_CURRENCY_CONVERSION_TYPE,
				CURRENCY_CONVERSION_DATE,
				CURRENCY_CONVERSION_RATE,
				DATE_CREATED,
				CREATED_BY,
				ACTUAL_FLAG,
				USER_JE_CATEGORY_NAME,
				USER_JE_SOURCE_NAME,
				ENCUMBRANCE_TYPE_ID,
				BUDGET_VERSION_ID,
				SEGMENT1,
				SEGMENT2,
				SEGMENT3,
				SEGMENT4,
				SEGMENT5,
				SEGMENT6,
				SEGMENT7,
				SEGMENT8,
				SEGMENT9,
				SEGMENT10,
				SEGMENT11,
				SEGMENT12,
				SEGMENT13,
				SEGMENT14,
				SEGMENT15,
				SEGMENT16,
				SEGMENT17,
				SEGMENT18,
				SEGMENT19,
				SEGMENT20,
				SEGMENT21,
				SEGMENT22,
				SEGMENT23,
				SEGMENT24,
				SEGMENT25,
				SEGMENT26,
				SEGMENT27,
				SEGMENT28,
				SEGMENT29,
				SEGMENT30,
				ENTERED_DR,
				ENTERED_CR,
				ACCOUNTED_DR,
				ACCOUNTED_CR,
				REFERENCE1, 	-- Batch Name
				REFERENCE2,	-- Batch Description
				REFERENCE4, 	-- Header Name
				REFERENCE5,	-- Header Description
				REFERENCE6,	-- Header Reference
				REFERENCE10, 	-- Line Description
				REFERENCE21, 	-- GL_JE_LINES.reference_1
				REFERENCE22, 	-- GL_JE_LINES.reference_2
				STAT_AMOUNT,
				SUBLEDGER_DOC_SEQUENCE_ID,
				SUBLEDGER_DOC_SEQUENCE_VALUE,
				ATTRIBUTE1,
				ATTRIBUTE2,
				ATTRIBUTE3,
				ATTRIBUTE4,
				ATTRIBUTE5,
				ATTRIBUTE6,
				ATTRIBUTE7,
				ATTRIBUTE8,
				ATTRIBUTE9,
				ATTRIBUTE10,
				ATTRIBUTE11,
				ATTRIBUTE12,
				ATTRIBUTE13,
				ATTRIBUTE14,
				ATTRIBUTE15,
				ATTRIBUTE16,
				ATTRIBUTE17,
				ATTRIBUTE18,
				ATTRIBUTE19,
				ATTRIBUTE20,
				CONTEXT,
				CONTEXT2,
				INVOICE_DATE,
				TAX_CODE,
				INVOICE_IDENTIFIER,
				INVOICE_AMOUNT,
				CONTEXT3,
				USSGL_TRANSACTION_CODE,
				JGZZ_RECON_REF,
				PERIOD_NAME)
  VALUES
( 				'NEW',
				JG_JOURNAL_ALLOCATIONS_PKG.G_destn_set_of_books_id,
				JG_JOURNAL_ALLOCATIONS_PKG.G_GL_end_date,
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type,'E',
                                     JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_code,
										'A',
					    JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency),
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type,'E',
                                     JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_conversion_type,
										'A',
                                     DECODE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_code,
					    JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency,
				       JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_conversion_type,
				       JG_JOURNAL_ALLOCATIONS_PKG.G_translated_user)),
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type,'E',
                                     JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_conversion_date,
										'A',
                                     DECODE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_code,
					    JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency,
				       JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_conversion_date,
				       sysdate)),
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type,'E',
                                     JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_conversion_rate,
										'A',
                                     DECODE(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_code,
					    JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency,
				       JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_conversion_rate,
				       1)),
				SYSDATE,
				JG_JOURNAL_ALLOCATIONS_PKG.G_user_id,
				JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type,
				JG_JOURNAL_ALLOCATIONS_PKG.G_user_je_category_name,
				JG_JOURNAL_ALLOCATIONS_PKG.G_user_je_source_name,
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type,'E',
						JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type_id),
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type,'B',
						JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type_id),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 1 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 2 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 3 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 4 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 5 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 6 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 7 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 8 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 9 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 10 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 11 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 12 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 13 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 14 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 15 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 16 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 17 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 18 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 19 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 20 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 21 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 22 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 23 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 24 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 25 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 26 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 27 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 28 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 29 ),
				JG_CREATE_JOURNALS_PKG.G_key_segment( 30 ),
				lp_entered_dr,
				lp_entered_cr,
				lp_accounted_dr,
				lp_accounted_cr,
			        JG_CREATE_JOURNALS_PKG.G_Batch_Name, -- Reference1
			        JG_CREATE_JOURNALS_PKG.G_Batch_Name, -- Reference2
	  		        JG_CREATE_JOURNALS_PKG.G_Journal_Name, -- Reference4
			        JG_CREATE_JOURNALS_PKG.G_Journal_Description, -- Reference5
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.external_reference,-- Reference6
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_header_name ||
				  DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type, 'A',
				  '/' ||JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_doc_sequence_name || '/' ||
				  JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_doc_sequence_value || '/' ||
				  JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_line_num, NULL), -- Reference 10
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_header_id,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_line_num,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.stat_amount,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.subledger_doc_sequence_id,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.subledger_doc_sequence_value,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute1,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute2,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute3,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute4,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute5,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute6,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute7,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute8,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute9,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute10,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute11,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute12,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute13,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute14,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute15,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute16,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute17,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute18,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute19,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.attribute20,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.context,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.context2,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.invoice_date,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.tax_code,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.invoice_identifier,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.invoice_amount,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.context3,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.ussgl_transaction_code,
				JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.jgzz_recon_ref,
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type, 'B',
				  JG_JOURNAL_ALLOCATIONS_PKG.G_destn_period_name, NULL));

ELSE -- Inserting line for an offset group total


  INSERT INTO gl_interface (	STATUS,
				LEDGER_ID, -- GC Ledger Architecture change
				ACCOUNTING_DATE,
				CURRENCY_CODE,
				USER_CURRENCY_CONVERSION_TYPE,
				CURRENCY_CONVERSION_DATE,
				CURRENCY_CONVERSION_RATE,
				DATE_CREATED,
				CREATED_BY,
				ACTUAL_FLAG,
				USER_JE_CATEGORY_NAME,
				USER_JE_SOURCE_NAME,
				ENCUMBRANCE_TYPE_ID,
				BUDGET_VERSION_ID,
				SEGMENT1,
				SEGMENT2,
				SEGMENT3,
				SEGMENT4,
				SEGMENT5,
				SEGMENT6,
				SEGMENT7,
				SEGMENT8,
				SEGMENT9,
				SEGMENT10,
				SEGMENT11,
				SEGMENT12,
				SEGMENT13,
				SEGMENT14,
				SEGMENT15,
				SEGMENT16,
				SEGMENT17,
				SEGMENT18,
				SEGMENT19,
				SEGMENT20,
				SEGMENT21,
				SEGMENT22,
				SEGMENT23,
				SEGMENT24,
				SEGMENT25,
				SEGMENT26,
				SEGMENT27,
				SEGMENT28,
				SEGMENT29,
				SEGMENT30,
				ENTERED_DR,
				ENTERED_CR,
				ACCOUNTED_DR,
				ACCOUNTED_CR,
				REFERENCE1, 	-- Batch Name
				REFERENCE2,	-- Batch Description
				REFERENCE4, 	-- Header Name
				REFERENCE5,	-- Header Description
				REFERENCE6,	-- Header Reference
				REFERENCE10, 	-- Line Description
				REFERENCE21, 	-- GL_JE_LINES.reference_1
				REFERENCE22, 	-- GL_JE_LINES.reference_2
				STAT_AMOUNT,
				SUBLEDGER_DOC_SEQUENCE_ID,
				SUBLEDGER_DOC_SEQUENCE_VALUE,
				ATTRIBUTE1,
				ATTRIBUTE2,
				ATTRIBUTE3,
				ATTRIBUTE4,
				ATTRIBUTE5,
				ATTRIBUTE6,
				ATTRIBUTE7,
				ATTRIBUTE8,
				ATTRIBUTE9,
				ATTRIBUTE10,
				ATTRIBUTE11,
				ATTRIBUTE12,
				ATTRIBUTE13,
				ATTRIBUTE14,
				ATTRIBUTE15,
				ATTRIBUTE16,
				ATTRIBUTE17,
				ATTRIBUTE18,
				ATTRIBUTE19,
				ATTRIBUTE20,
				CONTEXT,
				CONTEXT2,
				INVOICE_DATE,
				TAX_CODE,
				INVOICE_IDENTIFIER,
				INVOICE_AMOUNT,
				CONTEXT3,
				USSGL_TRANSACTION_CODE,
				JGZZ_RECON_REF,
				PERIOD_NAME)
  VALUES
( 				'NEW',
				JG_JOURNAL_ALLOCATIONS_PKG.G_destn_set_of_books_id,
				JG_JOURNAL_ALLOCATIONS_PKG.G_GL_end_date,
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type,'E',
                                     JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.currency_code,
										'A',
					    JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency),
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type,'E',
                                     JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.currency_conversion_type,
										'A',
                                     DECODE(JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.currency_code,
					    JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency,
				       JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.currency_conversion_type,
				       JG_JOURNAL_ALLOCATIONS_PKG.G_translated_user)),
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type,'E',
                                     JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.currency_conversion_date,
										'A',
                                     DECODE(JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.currency_code,
					    JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency,
				       JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.currency_conversion_date,
				       SYSDATE)),
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type,'E',
                                     JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.currency_conversion_rate,
										'A',
                                     DECODE(JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.currency_code,
					    JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency,
				       JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.currency_conversion_rate,
				       1)),
				SYSDATE,
				JG_JOURNAL_ALLOCATIONS_PKG.G_user_id,
				JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type,
				JG_JOURNAL_ALLOCATIONS_PKG.G_user_je_category_name,
				JG_JOURNAL_ALLOCATIONS_PKG.G_user_je_source_name,
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type,'E',
						JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type_id),
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type,'B',
						JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type_id),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 1 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 2 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 3 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 4 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 5 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 6 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 7 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 8 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 9 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 10 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 11 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 12 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 13 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 14 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 15 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 16 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 17 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 18 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 19 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 20 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 21 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 22 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 23 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 24 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 25 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 26 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 27 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 28 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 29 ),
				JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment( 30 ),
				lp_entered_dr,
				lp_entered_cr,
				lp_accounted_dr,
				lp_accounted_cr,
			        JG_CREATE_JOURNALS_PKG.G_Batch_Name, -- Reference1
			        JG_CREATE_JOURNALS_PKG.G_Batch_Name, -- Reference2
	  		        JG_CREATE_JOURNALS_PKG.G_Journal_Name, -- Reference4
			        JG_CREATE_JOURNALS_PKG.G_Journal_Description, -- Reference5
				NULL,-- Reference6
				NULL, -- Reference 10
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				DECODE(JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type, 'B',
				  JG_JOURNAL_ALLOCATIONS_PKG.G_destn_period_name, NULL));

END IF;

  JG_UTILITY_PKG.log('< JG_CREATE_JOURNALS_PKG.insert_gl_interface');
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    JG_UTILITY_PKG.log('< JG_CREATE_JOURNALS_PKG.insert_gl_interface');
    JG_UTILITY_PKG.log(sqlerrm);
    RETURN FALSE;
END insert_gl_interface;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       Create_Offset_For_Acct_Range				        |
|  DESCRIPTION								|
|  	Creates an offset line in GL_Interface for the account range    |
|       total.	   	       	  	       	       	       		|
|  CALLED BY                                                            |
|       Create_Journal_Allocations					|
 --------------------------------------------------------------------- */
PROCEDURE create_offset_for_acct_range IS
  l_net_total_accted_offset_amt	 NUMBER := 0;
  l_net_dr_accted_offset_total 	 NUMBER := 0;
  l_net_cr_accted_offset_total 	 NUMBER := 0;
  l_net_total_entered_offset_amt NUMBER := 0;
  l_net_dr_entered_offset_total  NUMBER := 0;
  l_net_cr_entered_offset_total  NUMBER := 0;
  l_range_offset_remark          VARCHAR2(240) := NULL;
BEGIN
  JG_UTILITY_PKG.log('> JG_CREATE_JOURNALS_PKG.create_offset_for_acct_range');
  --
  -- Need to zero-fill segments for offset group insert other than the balancing segment and natural account
  -- Use separate array to store zeros as Zero-Fill method may not have been chosen for journal allocation.
  --
  JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment := JG_CREATE_JOURNALS_PKG.G_key_segment;
  JG_CREATE_JOURNALS_PKG.zero_fill_segments(JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment);
  JG_CREATE_JOURNALS_PKG.G_offset_grp_key_segment(JG_JOURNAL_ALLOCATIONS_PKG.G_acct_key_element) :=
 	                    JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.offset_account;
  --
  -- Calculate net totals
  --
  l_net_total_accted_offset_amt := NVL(JG_CREATE_JOURNALS_PKG.G_total_offset_accted_cr_amt, 0) -
			           NVL(JG_CREATE_JOURNALS_PKG.G_total_offset_accted_dr_amt, 0);
  l_net_total_entered_offset_amt := NVL(JG_CREATE_JOURNALS_PKG.G_total_offset_entered_cr_amt, 0) -
			           NVL(JG_CREATE_JOURNALS_PKG.G_total_offset_entered_dr_amt, 0);

  -- Don't create offset line if net total is zero
  IF l_net_total_accted_offset_amt <> 0 THEN

     --
     -- Calculate credit and debit amounts
     --
     IF SIGN(l_net_total_accted_offset_amt) = '-1' THEN
        l_net_dr_accted_offset_total  := ABS(l_net_total_accted_offset_amt);
        l_net_cr_accted_offset_total := NULL;
        IF JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type = 'E' THEN
           l_net_dr_entered_offset_total  := ABS(l_net_total_entered_offset_amt);
           l_net_cr_entered_offset_total := NULL;
        ELSE
           l_net_dr_entered_offset_total  := ABS(l_net_total_accted_offset_amt);
           l_net_cr_entered_offset_total := NULL;
        END IF;
     ELSE
        l_net_dr_accted_offset_total  := NULL;
        l_net_cr_accted_offset_total := ABS(l_net_total_accted_offset_amt);
        IF JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type = 'E' THEN
          l_net_dr_entered_offset_total  := NULL;
          l_net_cr_entered_offset_total := ABS(l_net_total_entered_offset_amt);
        ELSE
          l_net_dr_entered_offset_total  := NULL;
          l_net_cr_entered_offset_total := ABS(l_net_total_accted_offset_amt);
        END IF;
     END IF;

     IF (JG_JOURNAL_ALLOCATIONS_PKG.G_validate_only = 'N') THEN
       --
       -- Insert for offset account (one line that is the net of the credits and debits)
       --
       IF NOT JG_CREATE_JOURNALS_PKG.insert_gl_interface(l_net_dr_entered_offset_total,
       	      	  	 	      	   	         l_net_cr_entered_offset_total,
						         l_net_dr_accted_offset_total,
				  		         l_net_cr_accted_offset_total,
						         TRUE) THEN
          FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name , 'JG_ZZ_GL_INTERFACE_INSERT');
          JG_CREATE_JOURNALS_PKG.write_error_to_output;
          RAISE APP_EXCEPTION.application_exception;
       END IF;
     END IF;
     --
     -- populate array for reporting allocated lines at end of program
     -- for offset account: one line for the net credits/debits total
     --
     -- increment array counter
     JG_CREATE_JOURNALS_PKG.i := JG_CREATE_JOURNALS_PKG.i + 1;

     JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).je_batch_name  := 'OFFSET FOR ACCOUNT RANGE';
     JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).je_header_name := NULL;
     JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).je_line_num    := NULL;
     --
     -- Use the code combination id of the last row to build the output accounting flexfield of the offset line
     --
     JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).code_combination_id
				:= JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.code_combination_id;
     JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).cc_range_id
				:= JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.cc_range_id;
     FND_MESSAGE.SET_NAME (JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name ,'JG_ZZ_JGZZTAJA_RANGE_OFFSET');
     l_range_offset_remark := substr(FND_MESSAGE.GET,1,240);
     JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).remarks := l_range_offset_remark;
     JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).accounted_cr   := NULL;
     JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).accounted_dr   := NULL;
     JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_account_number :=
  				JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.offset_account;
     JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_accted_cr := l_net_cr_accted_offset_total;
     JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_accted_dr := l_net_dr_accted_offset_total;
     --
     -- Cumulative totals for report output (allocated accts)
     --
     JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_cr_amt
				:= JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_cr_amt + NVL(l_net_cr_accted_offset_total, 0);
     JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_dr_amt
				:= JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_dr_amt + NVL(l_net_dr_accted_offset_total, 0);

  END IF;  -- End of net 0 check

  --
  -- Reinitialize offset totals
  --
  JG_CREATE_JOURNALS_PKG.G_total_offset_accted_cr_amt := 0;
  JG_CREATE_JOURNALS_PKG.G_total_offset_accted_dr_amt := 0;
  JG_CREATE_JOURNALS_PKG.G_total_offset_entered_cr_amt := 0;
  JG_CREATE_JOURNALS_PKG.G_total_offset_entered_dr_amt := 0;
  JG_UTILITY_PKG.log('< JG_CREATE_JOURNALS_PKG.create_offset_for_acct_range');
END create_offset_for_acct_range;

/* ---------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                     |
|       Write_Error_to_Output						|
|  DESCRIPTION								|
|  	Write Error Line to the Output File; Also used for outputting 	|
|       unallocated fiscal journals    	     	       	   		|
|  CALLED BY                                                            |
|       Create_Journal_Allocations					|
 --------------------------------------------------------------------- */
PROCEDURE write_error_to_output IS
  l_acct_segments	VARCHAR2(2000);
  l_error_message	VARCHAR2(2000) := NULL;
BEGIN
  JG_UTILITY_PKG.log( '> JG_CREATE_JOURNALS_PKG.write_error_to_output');
  --
  -- Construct accounting flexfield segments string
  --
  l_acct_segments := fnd_flex_ext.get_segs(JG_JOURNAL_ALLOCATIONS_PKG.G_GL_appln_short_name,
					   JG_JOURNAL_ALLOCATIONS_PKG.G_GL_acct_flex_code,
					   JG_JOURNAL_ALLOCATIONS_PKG.G_chart_of_accounts_id,
					   JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.code_combination_id);

  JG_UTILITY_PKG.debug('acct string = '||l_acct_segments);

  --
  --  Get the latest message from the stack for error reporting
  --
  IF JG_JOURNAL_ALLOCATIONS_PKG.G_unalloc_request_id IS NULL THEN  -- Error Reporting
     l_error_message := FND_MESSAGE.GET;
     JG_JOURNAL_ALLOCATIONS_PKG.G_errbuf := l_error_message;
     JG_UTILITY_PKG.out(
     RPAD(SUBSTR(NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_batch_name, ' '), 1, 20), 20)||' '||
     RPAD(SUBSTR(NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_header_name, ' '), 1, 19), 19)||' '||
     RPAD(SUBSTR(NVL(l_acct_segments, ' '), 1, 35), 35)||' '||
     LPAD(SUBSTR(NVL(TO_CHAR(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_line_num), ' '), 1, 3), 3)||' '||
     LPAD(SUBSTR(NVL(TO_CHAR(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_dr,
                           JG_ALLOCATE_JOURNALS_PKG.G_currency_format_mask), ' ') ,1,15), 15)||' '||
     LPAD(SUBSTR(NVL(TO_CHAR(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_cr,
                           JG_ALLOCATE_JOURNALS_PKG.G_currency_format_mask), ' ') ,1,15),15)||'   '||l_error_message);
  ELSE -- Unallocation Reporting
     JG_UTILITY_PKG.out(
     RPAD(SUBSTR(NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_batch_name, ' '), 1, 20), 20)||' '||
     RPAD(SUBSTR(NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_header_name, ' '), 1, 19), 19)||' '||
     RPAD(SUBSTR(NVL(l_acct_segments, ' '), 1, 35), 35)||' '||
     LPAD(SUBSTR(NVL(TO_CHAR(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_line_num), ' '), 1, 3), 3)||' '||
     LPAD(SUBSTR(NVL(TO_CHAR(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_dr,
                           JG_ALLOCATE_JOURNALS_PKG.G_currency_format_mask), ' ') ,1,15), 15)||' '||
     LPAD(SUBSTR(NVL(TO_CHAR(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_cr,
                           JG_ALLOCATE_JOURNALS_PKG.G_currency_format_mask), ' ') ,1,15),15));
  END IF;
  JG_UTILITY_PKG.log('< JG_CREATE_JOURNALS_PKG.write_error_to_output');
END write_error_to_output;

/* ------------------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                             |
|       create_journal 								|
|  DESCRIPTION								        |
|	Allocates the Journals							|
|       Pseudocode:   								|
|	FOR each journal line LOOP						|
|	    (create_journal starts here)					|
|	    IF current line falls under a different account range than previous |
|	       AND previous had an offset acct defined at the acct range level THEN |
|	       create account range level offset allocation line  		|
|	    END IF    	      	    	  	 	    			|
|	    FOR account range rule line LOOP					|
|	    	Check if current allocation line has max percentage so far	|
|		Add allocation line to array for later reporting and inserting  |
|		IF offset account is defined against the rule line THEN		|
|		   Add offset allocation line to array	      	   		|
|		END IF								|
|	    END LOOP	      	   						|
|	    Compare original entered/accounted amounts with total of allocated  |
|	       amounts and calculate any rounding errors.   	     		|
|	    Add rounding errors to amounts of allocation line and offset line   |
|	       with the max percentage in the array	      	  	 	|
|	    Insert source journal allocation lines into GL_INTERFACE from array |
|	    (create_journal ends here)						|
|	END journal line LOOP	 						|
|  CALLED BY 									|
|	JG_ALLOCATE_JOURNALS_PKG.allocate					|
--------------------------------------------------------------------------------*/
PROCEDURE create_journal IS
  --
  -- Rule Line cursor
  --
  CURSOR 		c_rule_line IS
  SELECT 		natural_account		 NATURAL_ACCOUNT,
			allocation_percent	 ALLOCATION_PERCENT,
	   		offset_account		 OFFSET_ACCOUNT,
			rule_line_id		 RULE_LINE_ID
  FROM   		jg_zz_ta_rule_lines
  WHERE  		account_range_id = JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.account_range_id;

  l_accted_credit_amount	 GL_JE_LINES.entered_dr%TYPE:= 0;
  l_accted_debit_amount		 GL_JE_LINES.entered_dr%TYPE:= 0;
  l_entered_credit_amount	 GL_JE_LINES.entered_dr%TYPE:= 0;
  l_entered_debit_amount	 GL_JE_LINES.entered_dr%TYPE:= 0;
  l_cc_range_code		 VARCHAR2(100) := NULL;
  l_first_alloc_for_jrnal        NUMBER;
  l_max_prc_alloc_for_jrnal      NUMBER := 0;
  l_is_max_prc_alloc_line	 BOOLEAN := FALSE;
  l_max_prc_alloc_line_for_jrnal NUMBER := NULL;
  l_max_prc_offst_line_for_jrnal NUMBER := NULL;
  l_rounded_accted_cr_sum	 NUMBER := 0;
  l_rounded_accted_dr_sum	 NUMBER := 0;
  l_rounded_entered_cr_sum	 NUMBER := 0;
  l_rounded_entered_dr_sum	 NUMBER := 0;
BEGIN
  JG_UTILITY_PKG.log('> JG_CREATE_JOURNALS_PKG.create_journal');
  --
  -- Only create offset row if latest fiscal journal line falls into a different account range than the last line.
  -- We are inserting an offset line for all lines under the same account range up to the last journal record.
  -- Separate offset range also created if the currency has changed, journal import implicitly creates a separate
  -- journal header per currency if the entered amounts are in different currencies.
  --
  JG_UTILITY_PKG.debug( ' current acct range id = '||to_char(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.account_range_id));
  JG_UTILITY_PKG.debug( ' last acct range id = '||to_char(JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.account_range_id));
  JG_UTILITY_PKG.debug( ' last offset account = '||JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.offset_account);
  IF JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.offset_account IS NOT NULL AND
	  ((JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.account_range_id <>
	   JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.account_range_id)  OR
	   ((JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.l_je_lines_v_rec.currency_code <>
	   JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.currency_code) AND JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type = 'E')) THEN
    JG_UTILITY_PKG.debug( ' creating offset line for acct range ');
    JG_CREATE_JOURNALS_PKG.create_offset_for_acct_range;
  END IF;


  IF (JG_JOURNAL_ALLOCATIONS_PKG.G_Destn_Cost_Center_Grouping = 'Y') THEN
    --
    -- Set the Journal Header Name to include Cost Center Range Description; supply the cc range id if the description is null
    --
    l_cc_range_code := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_low||' - '||JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_high;
    JG_CREATE_JOURNALS_PKG.G_Journal_Name := NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_description,
    					               TO_CHAR(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_id));
    JG_CREATE_JOURNALS_PKG.G_Journal_Description := NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_description||' '||l_cc_range_code,
    					               l_cc_range_code);
    JG_UTILITY_PKG.debug('Journal Header = ' || JG_CREATE_JOURNALS_PKG.G_Journal_Name);
  END IF;


  IF (JG_JOURNAL_ALLOCATIONS_PKG.G_validate_only = 'N') THEN
    --
    -- Build destination  account
    --
    JG_CREATE_JOURNALS_PKG.G_key_segment( 1 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment1;
    JG_CREATE_JOURNALS_PKG.G_key_segment( 2 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment2;
    JG_CREATE_JOURNALS_PKG.G_key_segment( 3 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment3;
    JG_CREATE_JOURNALS_PKG.G_key_segment( 4 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment4;
    JG_CREATE_JOURNALS_PKG.G_key_segment( 5 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment5;
    JG_CREATE_JOURNALS_PKG.G_key_segment( 6 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment6;
    JG_CREATE_JOURNALS_PKG.G_key_segment( 7 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment7;
    JG_CREATE_JOURNALS_PKG.G_key_segment( 8 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment8;
    JG_CREATE_JOURNALS_PKG.G_key_segment( 9 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment9;
    JG_CREATE_JOURNALS_PKG.G_key_segment(10 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment10;
    JG_CREATE_JOURNALS_PKG.G_key_segment(11 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment11;
    JG_CREATE_JOURNALS_PKG.G_key_segment(12 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment12;
    JG_CREATE_JOURNALS_PKG.G_key_segment(13 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment13;
    JG_CREATE_JOURNALS_PKG.G_key_segment(14 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment14;
    JG_CREATE_JOURNALS_PKG.G_key_segment(15 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment15;
    JG_CREATE_JOURNALS_PKG.G_key_segment(16 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment16;
    JG_CREATE_JOURNALS_PKG.G_key_segment(17 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment17;
    JG_CREATE_JOURNALS_PKG.G_key_segment(18 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment18;
    JG_CREATE_JOURNALS_PKG.G_key_segment(19 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment19;
    JG_CREATE_JOURNALS_PKG.G_key_segment(20 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment20;
    JG_CREATE_JOURNALS_PKG.G_key_segment(21 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment21;
    JG_CREATE_JOURNALS_PKG.G_key_segment(22 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment22;
    JG_CREATE_JOURNALS_PKG.G_key_segment(23 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment23;
    JG_CREATE_JOURNALS_PKG.G_key_segment(24 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment24;
    JG_CREATE_JOURNALS_PKG.G_key_segment(25 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment25;
    JG_CREATE_JOURNALS_PKG.G_key_segment(26 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment26;
    JG_CREATE_JOURNALS_PKG.G_key_segment(27 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment27;
    JG_CREATE_JOURNALS_PKG.G_key_segment(28 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment28;
    JG_CREATE_JOURNALS_PKG.G_key_segment(29 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment28;
    JG_CREATE_JOURNALS_PKG.G_key_segment(30 ) := JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.segment30;

    --
    -- Zero-Fill some of the segments if Zero-Fill method was chosen
    --
    IF JG_JOURNAL_ALLOCATIONS_PKG.G_destn_segment_method = 'ZF' THEN
        zero_fill_segments(JG_CREATE_JOURNALS_PKG.G_key_segment);
    END IF;
  END IF; -- Validate_Only check
  --
  -- Store a pointer to the first entry in the allocation lines array for this journal line
  --
  l_first_alloc_for_jrnal := JG_CREATE_JOURNALS_PKG.i + 1;
  --
  -- loop for each destination account number and allocation
  --
  JG_UTILITY_PKG.debug(TO_CHAR(SYSDATE, 'HH24:MI:SS'));
  FOR c_rule_line_rec IN c_rule_line LOOP
    JG_UTILITY_PKG.debug( 'inner loop: start');
    --
    -- Calculate allocated account amounts based on the parameter amount_type and the precision of the currency,
    -- any rounding errors are dealt with later down in the code once all rule lines for the journal have been fetched.
    --
    l_accted_credit_amount  := ROUND(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_cr *
		(c_rule_line_rec.allocation_percent / 100), JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_precision);
    l_accted_debit_amount   := ROUND(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_dr *
		(c_rule_line_rec.allocation_percent / 100), JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_precision);
    --
    -- Entered Amount Type: set to entered amounts to accounted amounts if Amount Type parameter is 'Accounted'
    --
    IF (JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type = 'E') THEN
      l_entered_credit_amount := ROUND(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_cr *
				(c_rule_line_rec.allocation_percent / 100), JG_ALLOCATE_JOURNALS_PKG.G_currency_precision);
      l_entered_debit_amount  := ROUND(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_dr *
			   	(c_rule_line_rec.allocation_percent / 100), JG_ALLOCATE_JOURNALS_PKG.G_currency_precision);
    ELSE
      l_entered_credit_amount := l_accted_credit_amount;
      l_entered_debit_amount  := l_accted_debit_amount;
    END IF;
    --
    -- Store running totals of rounded allocation amounts to compare against the original journal amount and
    -- determine any rounding error
    --
    l_rounded_accted_cr_sum := l_rounded_accted_cr_sum + NVL(l_accted_credit_amount, 0);
    l_rounded_accted_dr_sum := l_rounded_accted_dr_sum + NVL(l_accted_debit_amount, 0);
    l_rounded_entered_cr_sum := l_rounded_entered_cr_sum + NVL(l_entered_credit_amount, 0);
    l_rounded_entered_dr_sum := l_rounded_entered_dr_sum + NVL(l_entered_debit_amount, 0);
    JG_CREATE_JOURNALS_PKG.i := JG_CREATE_JOURNALS_PKG.i + 1;
    --
    -- Check if current allocation percentage is greater than any of previous percentages
    -- for journal line.  Any rounding error is applied to the line with the greatest allocation percentage.
    --
    IF NVL(l_max_prc_alloc_for_jrnal, 0) < c_rule_line_rec.allocation_percent AND
         JG_ALLOCATE_JOURNALS_PKG.G_jrnl_total_allocn_percent = 100 THEN
      l_is_max_prc_alloc_line := TRUE;
      l_max_prc_alloc_for_jrnal := c_rule_line_rec.allocation_percent;
      l_max_prc_alloc_line_for_jrnal := JG_CREATE_JOURNALS_PKG.i;
    END IF;
    --
    -- Populate allocated lines table for reporting and later gl_interface insertion
    --
    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).je_batch_name
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_batch_name;
    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).je_header_name
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_header_name;
    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).je_line_num
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_line_num;
    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).code_combination_id
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.code_combination_id;
    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).cc_range_id
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_id;
    IF JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_id <> NVL(JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.cc_range_id, -99)
       							     AND l_first_alloc_for_jrnal = JG_CREATE_JOURNALS_PKG.i THEN
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).remarks :=
       		JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_low||' - '||JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_high;
    END IF;
    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).accounted_cr
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_cr;
    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).accounted_dr
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_dr;
    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_account_number
		:= c_rule_line_rec.natural_account;
    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_accted_cr := l_accted_credit_amount;
    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_accted_dr := l_accted_debit_amount;
    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_entered_cr := l_entered_credit_amount;
    JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_entered_dr := l_entered_debit_amount;
    JG_UTILITY_PKG.debug('Loop number = '||to_char(JG_CREATE_JOURNALS_PKG.i)||'  '|| 'je_line_num = '||to_char(alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).je_line_num));

    JG_UTILITY_PKG.debug( 'batch_name = '|| JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_batch_name);
    JG_UTILITY_PKG.debug('header_name = '|| JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_header_name);
    JG_UTILITY_PKG.debug('accounted_cr = '|| to_char(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_cr));
    JG_UTILITY_PKG.debug('accounted_dr = '|| to_char(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_dr));
    --
    -- inserting an offset line for just the current journal record if the account range level offset account is null.
    --
    IF JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.offset_account IS NULL THEN
      --
      -- increment array counter
      --
      JG_CREATE_JOURNALS_PKG.i := JG_CREATE_JOURNALS_PKG.i + 1;
      --
      -- populate array for reporting allocated lines at end of program
      -- for offset account: switch credits and debits for destination amounts
      --
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).je_batch_name
   		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_batch_name;
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).je_header_name
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_header_name;
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).je_line_num
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.je_line_num;
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).code_combination_id
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.code_combination_id;
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).cc_range_id
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.cc_range_id;
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).accounted_cr
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_cr;
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).accounted_dr
		:= JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_dr;
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_account_number
		:= c_rule_line_rec.offset_account;
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_accted_cr := l_accted_debit_amount;
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_accted_dr := l_accted_credit_amount;
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_entered_cr := l_entered_debit_amount;
      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).destn_entered_dr := l_entered_credit_amount;
      --
      -- If have max percentage allocation line so far, then set the offset line array number aswell
      --
      IF l_is_max_prc_alloc_line THEN
        l_max_prc_offst_line_for_jrnal := JG_CREATE_JOURNALS_PKG.i;
      END IF;
    END IF;  -- Is the account range level offset null?
    l_is_max_prc_alloc_line := FALSE;
    JG_UTILITY_PKG.debug('Loop number = '||to_char(JG_CREATE_JOURNALS_PKG.i)||'  '|| 'je_line_num = '||to_char(alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).je_line_num));
  END LOOP;
  JG_UTILITY_PKG.debug(TO_CHAR(SYSDATE, 'HH24:MI:SS'));
  --
  -- Update entered and accounted amounts of max perc line with any rounding error total
  --
  IF JG_CREATE_JOURNALS_PKG.i >= l_first_alloc_for_jrnal THEN
    --
    -- Adjust calculated amounts with any rounding error difference if the line
    -- is the maximum percentage line chosen and it is a full allocation of 100 percent
    --
    JG_UTILITY_PKG.debug( 'Perform rounding errors calculations');
    IF NVL(l_rounded_accted_cr_sum, 0) <>
		NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_cr, 0) THEN
      IF l_max_prc_alloc_line_for_jrnal IS NOT NULL THEN
        JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_alloc_line_for_jrnal).destn_accted_cr :=
              JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_alloc_line_for_jrnal).destn_accted_cr +
	      (NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_cr, 0) - NVL(l_rounded_accted_cr_sum, 0));
      END IF;
      IF l_max_prc_offst_line_for_jrnal IS NOT NULL THEN
           JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_offst_line_for_jrnal).destn_accted_dr :=
              JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_offst_line_for_jrnal).destn_accted_dr +
	      (NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_cr, 0) - NVL(l_rounded_accted_cr_sum, 0));
      END IF;
    END IF;
    IF NVL(l_rounded_accted_dr_sum, 0) <>
		NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_dr, 0) THEN
      IF l_max_prc_alloc_line_for_jrnal IS NOT NULL THEN
           JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_alloc_line_for_jrnal).destn_accted_dr :=
              JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_alloc_line_for_jrnal).destn_accted_dr +
	      (NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_dr, 0) - NVL(l_rounded_accted_dr_sum, 0));
      END IF;
      IF l_max_prc_offst_line_for_jrnal IS NOT NULL THEN
        JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_offst_line_for_jrnal).destn_accted_cr :=
              JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_offst_line_for_jrnal).destn_accted_cr +
	      (NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.accounted_dr, 0) - NVL(l_rounded_accted_dr_sum, 0));
      END IF;
    END IF;
    IF (JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type = 'E') THEN
      IF NVL(l_rounded_entered_cr_sum, 0) <>
		NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_cr, 0) THEN
        IF l_max_prc_alloc_line_for_jrnal IS NOT NULL THEN
          JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_alloc_line_for_jrnal).destn_entered_cr :=
                JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_alloc_line_for_jrnal).destn_entered_cr +
	        (NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_cr, 0) - NVL(l_rounded_entered_cr_sum, 0));
        END IF;
        IF l_max_prc_offst_line_for_jrnal IS NOT NULL THEN
             JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_offst_line_for_jrnal).destn_entered_dr :=
                JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_offst_line_for_jrnal).destn_entered_dr +
	        (NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_cr, 0) - NVL(l_rounded_entered_cr_sum, 0));
        END IF;
      END IF;
      IF NVL(l_rounded_entered_dr_sum, 0) <>
		NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_dr, 0) THEN
        IF l_max_prc_alloc_line_for_jrnal IS NOT NULL THEN
             JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_alloc_line_for_jrnal).destn_entered_dr :=
                JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_alloc_line_for_jrnal).destn_entered_dr +
	        (NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_dr, 0) - NVL(l_rounded_entered_dr_sum, 0));
        END IF;
        IF l_max_prc_offst_line_for_jrnal IS NOT NULL THEN
             JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_offst_line_for_jrnal).destn_entered_cr :=
                JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_offst_line_for_jrnal).destn_entered_cr +
	        (NVL(JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.l_je_lines_v_rec.entered_dr, 0) - NVL(l_rounded_entered_dr_sum, 0));
        END IF;
      END IF;
    ELSE
      IF l_max_prc_alloc_line_for_jrnal IS NOT NULL THEN
        JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_alloc_line_for_jrnal).destn_entered_cr :=
  	             JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_alloc_line_for_jrnal).destn_accted_cr;
	JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_alloc_line_for_jrnal).destn_entered_dr :=
  	             JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_alloc_line_for_jrnal).destn_accted_dr;
      END IF;
      IF l_max_prc_offst_line_for_jrnal IS NOT NULL THEN
        JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_offst_line_for_jrnal).destn_entered_cr :=
  	             JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_offst_line_for_jrnal).destn_accted_cr;
	JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_offst_line_for_jrnal).destn_entered_dr :=
  	             JG_CREATE_JOURNALS_PKG.alloc_lines_arr(l_max_prc_offst_line_for_jrnal).destn_accted_dr;
      END IF;
    END IF;  -- Amount_Type Check
    --
    -- Loop for all allocation lines to insert into GL Interface
    -- Only if at least one allocation line has been found
    --
    FOR j IN l_first_alloc_for_jrnal .. JG_CREATE_JOURNALS_PKG.i LOOP
      --
      -- Cumulative totals for report output (allocated accts)
      --
      JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_cr_amt
 		  := JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_cr_amt + NVL(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(j).destn_accted_cr, 0);
           JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_dr_amt
		  := JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_dr_amt + NVL(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(j).destn_accted_dr, 0);
       JG_UTILITY_PKG.debug('total_alloc_accted_cr_amt = '|| to_char(JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_cr_amt));
       JG_UTILITY_PKG.debug('total_alloc_accted_dr_amt = '|| to_char(JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_dr_amt));
       IF JG_JOURNAL_ALLOCATIONS_PKG.G_validate_only = 'N' THEN
         JG_UTILITY_PKG.debug( 'Inserting Allocated Journal Line number '||to_char(j));
         JG_CREATE_JOURNALS_PKG.G_key_segment( JG_JOURNAL_ALLOCATIONS_PKG.G_acct_key_element ) :=
	 		        JG_CREATE_JOURNALS_PKG.alloc_lines_arr(j).destn_account_number;
         IF NOT JG_CREATE_JOURNALS_PKG.insert_gl_interface
	    		     (JG_CREATE_JOURNALS_PKG.alloc_lines_arr(j).destn_entered_dr,
	  		      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(j).destn_entered_cr,
			      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(j).destn_accted_dr,
	  		      JG_CREATE_JOURNALS_PKG.alloc_lines_arr(j).destn_accted_cr,
 			      FALSE) THEN
	   FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name , 'JG_ZZ_GL_INTERFACE_INSERT');
	   JG_CREATE_JOURNALS_PKG.write_error_to_output;
	   RAISE APP_EXCEPTION.application_exception;
         END IF;
       END IF; -- Validate_Only?

       --
       -- We also require running totals for the offset range line if an offset account has been
       -- defined at the account range level.  If offset acct is at the account range level for the current
       -- line, then no offsets have been entered at the rule line level, this means that this current array loop
       -- will only contained allocated lines, no offsets.  Hence, the below running totals will be correctly summed
       -- (inclusive of any rounding corrections).
       --
       IF (JG_ALLOCATE_JOURNALS_PKG.G_journal_qry_rec.offset_account IS NOT NULL) THEN
          JG_CREATE_JOURNALS_PKG.G_total_offset_accted_cr_amt := JG_CREATE_JOURNALS_PKG.G_total_offset_accted_cr_amt +
   				NVL(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(j).destn_accted_dr, 0);
          JG_CREATE_JOURNALS_PKG.G_total_offset_accted_dr_amt := JG_CREATE_JOURNALS_PKG.G_total_offset_accted_dr_amt +
    				NVL(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(j).destn_accted_cr, 0);
          JG_CREATE_JOURNALS_PKG.G_total_offset_entered_cr_amt := JG_CREATE_JOURNALS_PKG.G_total_offset_entered_cr_amt +
   				NVL(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(j).destn_entered_dr, 0);
          JG_CREATE_JOURNALS_PKG.G_total_offset_entered_dr_amt := JG_CREATE_JOURNALS_PKG.G_total_offset_entered_dr_amt +
    				NVL(JG_CREATE_JOURNALS_PKG.alloc_lines_arr(j).destn_entered_cr, 0);
          JG_UTILITY_PKG.debug( 'cumulative offset accted dr amt = '||to_char(JG_CREATE_JOURNALS_PKG.G_total_offset_accted_dr_amt));
          JG_UTILITY_PKG.debug( 'cumulative offset accted cr amt = '||to_char(JG_CREATE_JOURNALS_PKG.G_total_offset_accted_cr_amt));
      END IF;
    END LOOP;
  END IF; -- Have lines to allocate?
  JG_UTILITY_PKG.debug('code_comb_id = '|| to_char(alloc_lines_arr(JG_CREATE_JOURNALS_PKG.i).code_combination_id));
  JG_UTILITY_PKG.log('< JG_CREATE_JOURNALS_PKG.create_journal');
END create_journal;

END JG_CREATE_JOURNALS_PKG;

/
