--------------------------------------------------------
--  DDL for Package Body FV_BE_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_BE_INT_PKG" AS
--$Header: FVBEINTB.pls 120.37.12000000.1 2007/01/18 13:45:25 appldev ship $
	g_module_name VARCHAR2(100);


	parm_source	VARCHAR2(25);
	parm_group_id	NUMBER;
        parm_ledger_id  NUMBER;
	v_error_code	NUMBER;
	v_exists	VARCHAR2(1);
	v_coa_id        NUMBER;
	v_seg_count	NUMBER;

	l_seg_type	VARCHAR2(1);
        l_seg_value	VARCHAR2(30);
	l_error_flag	BOOLEAN := FALSE;

	l_stmt		varchar2(2000);
	retcode		NUMBER;
	errbuf		VARCHAR2(250);

	l_segment_name  fnd_id_flex_segments.application_column_name%TYPE;

	segs_array	 fnd_flex_ext.segmentarray;
	dummy_array	 fnd_flex_ext.segmentarray;
	hdr_segs_array   fnd_flex_ext.segmentarray;
	tmp_hdr_segs_array fnd_flex_ext.segmentarray;

	val_set_id_array fnd_flex_ext.segmentarray;

        g_pub_law_code_flag VARCHAR2(1);
        g_advance_flag      VARCHAR2(1);
        g_transfer_flag     VARCHAR2(1);

        g_advance_type_code fv_lookup_codes.lookup_code%TYPE;

	CURSOR app_col(v_sob_id IN NUMBER) IS
	       	SELECT application_column_name,flex_value_set_id
	       	FROM   fnd_id_flex_segments ffs,
		       gl_ledgers_public_v gsb
	       	WHERE  ffs.application_id = 101
	     	AND    ffs.id_flex_code = 'GL#'
		AND    ffs.id_flex_num = gsb.chart_of_accounts_id
		AND    gsb.ledger_id = v_sob_id
		ORDER BY ffs.segment_num;

	PROCEDURE update_err_code(l_rowid VARCHAR2,
			          l_err_code VARCHAR2,
		     		  l_err_reason VARCHAR2);
	PROCEDURE validate_sob(v_sob_id NUMBER);
	PROCEDURE validate_gl_date(v_gl_date VARCHAR2,
                                   v_set_of_books_id NUMBER,
                                   v_quarter_num OUT NOCOPY NUMBER);
	PROCEDURE validate_budget_level(v_set_of_books_id NUMBER,
				        v_budget_level_id NUMBER);
	PROCEDURE validate_budget_user( p_sob_id NUMBER,
					p_bu_user_id NUMBER);
	PROCEDURE validate_bu_access_level( p_sob_id NUMBER,
					    p_bu_user_id NUMBER,
					    p_budget_level_id NUMBER);
	PROCEDURE validate_fund_value(v_set_of_books_id NUMBER,
			      	      v_fund_value VARCHAR2,
				      v_budget_level_id NUMBER);
	PROCEDURE validate_tsymbol_date(v_set_of_books_id NUMBER,
					v_fund_value VARCHAR2,
					v_gl_date VARCHAR2);
	PROCEDURE validate_trx_type_attribs(v_set_of_books_id NUMBER,
			    	    v_budget_level_id NUMBER,
			    	    v_trx_type VARCHAR2,
						v_sub_type VARCHAR2,
				        v_public_law_code VARCHAR2,
                                v_advance_type VARCHAR2,
                                v_dept_id NUMBER,
                                v_main_account NUMBER);
	PROCEDURE VALIDATE_SUB_TYPE(v_set_of_books_id NUMBER,
			            v_trx_type VARCHAR2,
			            v_budget_level_id NUMBER,
						v_sub_type VARCHAR2);
	PROCEDURE validate_doc_number(v_doc_number VARCHAR2,
			              v_set_of_books_id NUMBER,
			              v_fund_value VARCHAR2,
			              v_budget_level_id NUMBER,
				      v_source VARCHAR2);
	PROCEDURE copy_default_seg_vals(v_set_of_books_id NUMBER,
			                v_fund_value VARCHAR2,
			                v_budget_level_id NUMBER,
				        v_rowid VARCHAR2);
	PROCEDURE concat_segs(l_array fnd_flex_ext.segmentarray,
			      l_sob_id NUMBER, l_bud_segs OUT NOCOPY VARCHAR2);
	PROCEDURE update_cleanup(parm_source IN VARCHAR2,
			 parm_group_id IN NUMBER);
	PROCEDURE update_err_rec(v_rec_number IN NUMBER);
	PROCEDURE reset_control_status;
	PROCEDURE validate_dff
	(
		v_attribute_category fv_be_interface.attribute_category%TYPE,
		v_attribute1  fv_be_interface.attribute1%TYPE,
		v_attribute2  fv_be_interface.attribute2%TYPE,
		v_attribute3  fv_be_interface.attribute3%TYPE,
		v_attribute4  fv_be_interface.attribute4%TYPE,
		v_attribute5  fv_be_interface.attribute5%TYPE,
		v_attribute6  fv_be_interface.attribute6%TYPE,
		v_attribute7  fv_be_interface.attribute7%TYPE,
		v_attribute8  fv_be_interface.attribute8%TYPE,
		v_attribute9  fv_be_interface.attribute9%TYPE,
		v_attribute10 fv_be_interface.attribute10%TYPE,
		v_attribute11 fv_be_interface.attribute11%TYPE,
		v_attribute12 fv_be_interface.attribute12%TYPE,
		v_attribute13 fv_be_interface.attribute13%TYPE,
		v_attribute14 fv_be_interface.attribute14%TYPE,
		v_attribute15 fv_be_interface.attribute15%TYPE,
		v_error_mesg  OUT NOCOPY VARCHAR2
	);

--------------------------------------------------------------------------------
PROCEDURE MAIN(errbuf OUT NOCOPY VARCHAR2,
	       retcode OUT NOCOPY NUMBER,
	       source IN VARCHAR2,
               group_id IN NUMBER,
               validation IN VARCHAR2,
               ledger_id IN NUMBER)
IS

	l_module_name VARCHAR2(200);
	v_status VARCHAR2(25);
	l_bu_group_id NUMBER(15);
        l_application_table_name FND_FLEX_VALIDATION_TABLES.application_table_name%type;
	l_value_column_name FND_FLEX_VALIDATION_TABLES.value_column_name%type;
	l_table_stmt VARCHAR2(1000);
	l_validation_type VARCHAR2(2);

	-- Cursor for selecting records from
	-- fv_be_interface
-- BCPSA-BE Enhancement - Modified the cursor to get the Sub_Type instead of Transaction_Code
	CURSOR int IS
	SELECT rowid, set_of_books_id, gl_date, record_number,
	       budget_level_id, budgeting_segments, fund_value, doc_number,
	       amount, increase_decrease_flag, transaction_type,
	       sub_type, segment1, segment2, segment3, segment4,
	       segment5, segment6, segment7, segment8, segment9, segment10,
               segment11, segment12, segment13, segment14, segment15,
	       segment16, segment17, segment18, segment19, segment20,
	       segment21, segment22, segment23, segment24, segment25,
	       segment26, segment27, segment28, segment29, segment30,
	       attribute1, attribute2, attribute3, attribute4, attribute5,
	       attribute6, attribute7, attribute8, attribute9, attribute10,
	       attribute11, attribute12, attribute13, attribute14, attribute15,
	       source, group_id, corrected_flag, public_law_code, advance_type,
	       dept_id, main_account, transfer_description, attribute_category,
	       budget_user_id
	FROM   fv_be_interface
	WHERE  source = parm_source
	AND    group_id = parm_group_id
        AND    set_of_books_id = parm_ledger_id
	AND    status IN ('NEW','REJECTED','ACCEPTED')
	ORDER BY budget_level_id ;

-- BCPSA-BE Enhancement - Modified the cursor below to pull the information from FV_BE_ACCOUNT_PAIRS
-- instead of GL_USSGL_ACCOUNT_PAIRS table

    CURSOR accounts_cur(p_sub_type IN VARCHAR2) IS
 	SELECT cr_account_segment_value,
               dr_account_segment_value
 	FROM   fv_be_account_pairs acc,
 	       fv_be_trx_sub_types tst
 	WHERE  acc.be_tt_id = tst.be_tt_id
    and    tst.sub_type =p_sub_type
 	AND    chart_of_accounts_id = v_coa_id;

	l_ret_val       VARCHAR2(25);
	l_val_retcode	NUMBER;
	l_val_errbuf	VARCHAR2(250);
	v_delimiter	VARCHAR2(1);
	dtl_index	NUMBER;
	v_rej_rec_count NUMBER;

	v_amount	fv_be_trx_dtls.amount%TYPE;
	v_tt_id		fv_be_transaction_types.be_tt_id%TYPE;
	v_gl_date	fv_be_trx_dtls.gl_date%TYPE;
	v_quarter_num   fv_be_trx_dtls.quarter_num%TYPE;
	v_doc_id	fv_be_trx_hdrs.doc_id%TYPE;
	v_doc_status    fv_be_trx_hdrs.doc_status%TYPE;
	v_int_rev_num   fv_be_trx_hdrs.internal_revision_num%TYPE;
        v_revision_num  fv_be_trx_hdrs.revision_num%TYPE;
	v_bud_segs	fv_be_trx_hdrs.budgeting_segments%TYPE;
	new_doc_id 	fv_be_trx_hdrs.doc_id%TYPE;
	v_ts_id		fv_be_trx_hdrs.treasury_symbol_id%TYPE;
	ins_hdr		BOOLEAN := FALSE;
	v_req_id	NUMBER;

	v_segment1      VARCHAR2(25);
	v_segment2      VARCHAR2(25);
	v_segment3      VARCHAR2(25);
	v_segment4      VARCHAR2(25);
	v_segment5      VARCHAR2(25);
	v_segment6      VARCHAR2(25);
	v_segment7      VARCHAR2(25);
	v_segment8      VARCHAR2(25);
	v_segment9      VARCHAR2(25);
	v_segment10     VARCHAR2(25);
	v_segment11     VARCHAR2(25);
	v_segment12     VARCHAR2(25);
	v_segment13     VARCHAR2(25);
	v_segment14     VARCHAR2(25);
	v_segment15     VARCHAR2(25);
	v_segment16     VARCHAR2(25);
	v_segment17     VARCHAR2(25);
	v_segment18     VARCHAR2(25);
	v_segment19     VARCHAR2(25);
	v_segment20     VARCHAR2(25);
	v_segment21     VARCHAR2(25);
	v_segment22     VARCHAR2(25);
	v_segment23     VARCHAR2(25);
	v_segment24     VARCHAR2(25);
	v_segment25     VARCHAR2(25);
	v_segment26     VARCHAR2(25);
	v_segment27     VARCHAR2(25);
	v_segment28     VARCHAR2(25);
	v_segment29     VARCHAR2(25);
	v_segment30     VARCHAR2(25);

        v_interface_count NUMBER;
	v_user_id	NUMBER;
	v_resp_id	NUMBER;
	v_err_code	BOOLEAN;
	acc_seg_name	VARCHAR2(25);
	v_temp_seg_val	VARCHAR2(25);
	validation_failed	BOOLEAN;
	missing_bud_segs	BOOLEAN;
	v_index		NUMBER;
	v_num_segs	NUMBER;
	v_acc_seg_index	NUMBER;
        v_bal_seg_name  varchar2(25);
  l_dff_error_message VARCHAR2(1024);
	v_source_exists VARCHAR2(10);
BEGIN

	l_module_name  := g_module_name || 'MAIN';
	parm_source    := source;
	parm_group_id  := group_id;
        parm_ledger_id := ledger_id;

   -- Update the control table with the
   -- appropriate status
   UPDATE fv_be_interface_control
   SET    status = 'IN PROCESS',
	  date_processed = SYSDATE
   WHERE  source = parm_source
   AND    group_id = parm_group_id
   AND    status IN ('NEW','REJECTED','ACCEPTED');

   COMMIT;

   -- Count number of records in the interface table
   -- for the source and group_id parameter.  If there are no records found
   -- for this source and group_id then error and return
   SELECT count(*)
   INTO   v_interface_count
   FROM   fv_be_interface
   WHERE  source = parm_source
   AND    group_id = parm_group_id
   AND    set_of_books_id = parm_ledger_id
   AND    status IN ('NEW', 'REJECTED','ACCEPTED');

   IF v_interface_count > 0
     THEN
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'THERE ARE '||TO_CHAR(V_INTERFACE_COUNT)||
                                    ' record(s) for Import process');
       END IF;
   END IF;

   IF v_interface_count = 0
    THEN
      errbuf := 'No records found for source: '||parm_source||
	        ' and Group ID: '||parm_group_id||
		' in the interface table!.';
      retcode := -1;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message1_1',errbuf);
      reset_control_status;
      RETURN;
   END IF;


   -- Reset the error_code
   -- and error_reason to null
   UPDATE fv_be_interface
   SET    error_code = NULL,
          error_reason = NULL
   WHERE  source = parm_source
   AND    group_id = parm_group_id
   AND    set_of_books_id = parm_ledger_id;


   FOR int_rec IN int

    -- Two loops are used to skip a record in error
    -- and continue processing the next record
    -- If a value is invalid then
    -- update the current record with appropriate error
    -- code and reason, skip the record in error and
    -- continue processing from the beginning for the
    -- next record
    LOOP -- First
     LOOP -- Second

	-- reset error codes
	v_error_code := 0;
	retcode := NULL;
	errbuf  := NULL;

	-- reset arrays
	segs_array.DELETE;
	val_set_id_array.DELETE;

--------------------------------------------------------------------------------
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'------------------------------------------------');
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'START VALIDATING REC#: '||INT_REC.RECORD_NUMBER);
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING SET OF BOOKS ID: '||
     				int_rec.set_of_books_id);
   END IF;
	validate_sob(int_rec.set_of_books_id);
	IF retcode <> 0 THEN
		ROLLBACK;
		RETURN;
	END IF;
	IF v_error_code <> 0 THEN
	  update_err_code(int_rec.rowid,'EM03',
			         'Invalid Set of Books ID');
	  -- exit second loop to continue processing next
	  -- record
	  EXIT;
	END IF;
--------------------------------------------------------------------------------
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING GL DATE: '||
                                      int_rec.gl_date);
   END IF;
        validate_gl_date(int_rec.gl_date,
                         int_rec.set_of_books_id,
                         v_quarter_num);
        IF retcode <> 0 THEN
                ROLLBACK;
                RETURN;
        END IF;
        IF v_error_code <> 0 THEN
           update_err_code(int_rec.rowid,'EP06', 'Invalid GL Date');
         EXIT;
        END IF;
--------------------------------------------------------------------------------
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING BUDGET LEVEL ID: '||
    				  int_rec.budget_level_id);
   END IF;
	validate_budget_level(int_rec.set_of_books_id,
			      int_rec.budget_level_id);
	IF retcode <> 0 THEN
		ROLLBACK;
		RETURN;
	END IF;
	 IF v_error_code <> 0 THEN
	    update_err_code(int_rec.rowid, 'EM29',
			         'Invalid Budget Level');
	    EXIT;
	 END IF;
-----------------------------------------------------------------------------------------------
	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING BUDGET USER: '||
    					  int_rec.budget_user_id);
	END IF;
	validate_budget_user( int_rec.set_of_books_id,
			      int_rec.budget_user_id);
	IF retcode <> 0 THEN
		ROLLBACK;
		RETURN;
	END IF;
	IF v_error_code <> 0 THEN
		update_err_code(int_rec.rowid, 'EU01',
			         'Invalid Budget User');
		EXIT;
	END IF;
-----------------------------------------------------------------------------------------------
	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING BUDGET USER ACCESS : '||
    					  int_rec.budget_user_id || ' Budget Level Id => ' ||int_rec.budget_level_id );
	END IF;
	validate_bu_access_level( int_rec.set_of_books_id,
			          int_rec.budget_user_id,
				  int_rec.budget_level_id);
	IF retcode <> 0 THEN
		ROLLBACK;
		RETURN;
	END IF;
	IF v_error_code <> 0 THEN
		update_err_code(int_rec.rowid, 'EU02',
			         'Insufficient Access for Budget User');
		EXIT;
	END IF;


--------------------------------------------------------------------------------
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING FUND VALUE: '||
    				  int_rec.fund_value);
   END IF;
	validate_fund_value(int_rec.set_of_books_id,
		            int_rec.fund_value, int_rec.budget_level_id);
	IF retcode <> 0 THEN
		ROLLBACK;
		RETURN;
	END IF;
	 IF v_error_code <> 0 THEN
	    update_err_code(int_rec.rowid, 'EM33',
		'Fund Value not defined in Budget Distributions');
	  EXIT;
	 END IF;
--------------------------------------------------------------------------------
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
     	'Validating Treasury Symbol date for fund value: '||
    				           int_rec.fund_value);
   END IF;
	validate_tsymbol_date(int_rec.set_of_books_id,
			      int_rec.fund_value,
			      int_rec.gl_date);
	IF retcode <> 0 THEN
		ROLLBACK;
		RETURN;
	END IF;
	 IF v_error_code <> 0 THEN
	    update_err_code(int_rec.rowid, 'EM34',
			         'Cancelled or Expired Treasury Symbol');
	  EXIT;
	 END IF;
--------------------------------------------------------------------------------
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING INCREASE/DECREASE FLAG: '||
    		              int_rec.increase_decrease_flag);
   END IF;

        IF nvl(int_rec.increase_decrease_flag,' ') NOT IN ('I','D')
	 THEN
	   update_err_code(int_rec.rowid, 'EM35',
			         'Invalid Increase / Decrease Flag');
	 EXIT;
	END IF;
--------------------------------------------------------------------------------
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING AMOUNT: '||INT_REC.AMOUNT);
   END IF;
	IF int_rec.amount < 0 THEN
	   update_err_code(int_rec.rowid, 'EM36',
		 'Amount must be equal to or greater than zero');
	  EXIT;
	END IF;
--------------------------------------------------------------------------------
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING TRANSACTION TYPE: '||
                                      int_rec.transaction_type);
   END IF;
        validate_trx_type_attribs(int_rec.set_of_books_id,
                                  int_rec.budget_level_id,
                                  int_rec.transaction_type,
						  int_rec.sub_type,
				  int_rec.public_law_code,
				  int_rec.advance_type,
				  int_rec.dept_id,
				  int_rec.main_account);
        IF retcode <> 0 THEN
                ROLLBACK;
                RETURN;
        END IF;
        IF v_error_code = -6 THEN
            update_err_code(int_rec.rowid, 'EM45',
                    'Public Law Code should not be more than 7 characters');
            EXIT;
         ELSIF v_error_code = -7 THEN
            update_err_code(int_rec.rowid, 'EM46',
                                 'Invalid Advance Type');
            EXIT;
         ELSIF v_error_code = -8 THEN
            update_err_code(int_rec.rowid, 'EM47',
                 'Invalid Transfer Dept ID and/or Transfer Main Account');
            EXIT;
         ELSIF v_error_code = -9 THEN
            update_err_code(int_rec.rowid, 'EM28',
                                 'Invalid Transaction Type');
            EXIT;
	ELSIF v_error_code = -10 THEN
            update_err_code(int_rec.rowid, 'EM10',
                                 'Invalid Sub Type');
            EXIT;
        END IF;
--------------------------------------------------------------------------------
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING SUB TYPE: '||
    				  int_rec.sub_type);
   END IF;
	VALIDATE_SUB_TYPE(int_rec.set_of_books_id,
			  int_rec.transaction_type,
		   	  int_rec.budget_level_id,
			  int_rec.sub_type);

	IF retcode <> 0 THEN
		ROLLBACK;
		RETURN;
	END IF;
	 IF v_error_code <> 0 THEN
	    update_err_code(int_rec.rowid, 'EM10',
			         'Invalid Sub Type');
	   EXIT;
	 END IF;
--------------------------------------------------------------------------------
   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING DOCUMENT NUMBER: '||
    		               int_rec.doc_number);
   END IF;
	validate_doc_number(int_rec.doc_number,
		            int_rec.set_of_books_id,
		            int_rec.fund_value,
		            int_rec.budget_level_id,
			    int_rec.source);

	IF retcode <> 0 THEN
		ROLLBACK;
		RETURN;
	END IF;
	 IF v_error_code <> 0 THEN
	    IF v_error_code = -8 THEN
	       update_err_code(int_rec.rowid, 'EM39',
			  'Previously existing document with same document
			   number has not been approved');
	      ELSIF
	       v_error_code = -9 THEN
	       update_err_code(int_rec.rowid, 'EM40',
		         'Document Number must be numeric');
	      ELSIF
	       v_error_code = -7 THEN
	       update_err_code(int_rec.rowid, 'EM44',
		'Fund Value is not the same for document number,
		 set of books, source and budget level');
            END IF;
            EXIT;
	 END IF;
--------------------------------------------------------------------------------
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING DFFs');
  END IF;
  IF (validation = 'W') THEN
    validate_dff
    (
      int_rec.attribute_category,
      int_rec.attribute1,
      int_rec.attribute2,
      int_rec.attribute3,
      int_rec.attribute4,
      int_rec.attribute5,
      int_rec.attribute6,
      int_rec.attribute7,
      int_rec.attribute8,
      int_rec.attribute9,
      int_rec.attribute10,
      int_rec.attribute11,
      int_rec.attribute12,
      int_rec.attribute13,
      int_rec.attribute14,
      int_rec.attribute15,
      l_dff_error_message
    );

    IF retcode <> 0 THEN
      ROLLBACK;
      RETURN;
    END IF;
    IF v_error_code <> 0 THEN
	    update_err_code(int_rec.rowid,'ED01', SUBSTR(l_dff_error_message, 1, 255));
      EXIT;
    END IF;
  END IF;

--------------------------------------------------------------------------------
-- load segment table with the segment values
	  segs_array(1)  := int_rec.segment1;
	  segs_array(2)  := int_rec.segment2;
	  segs_array(3)  := int_rec.segment3;
	  segs_array(4)  := int_rec.segment4;
	  segs_array(5)  := int_rec.segment5;
	  segs_array(6)  := int_rec.segment6;
	  segs_array(7)  := int_rec.segment7;
	  segs_array(8)  := int_rec.segment8;
	  segs_array(9)  := int_rec.segment9;
	  segs_array(10) := int_rec.segment10;
	  segs_array(11) := int_rec.segment11;
	  segs_array(12) := int_rec.segment12;
	  segs_array(13) := int_rec.segment13;
	  segs_array(14) := int_rec.segment14;
	  segs_array(15) := int_rec.segment15;
	  segs_array(16) := int_rec.segment16;
	  segs_array(17) := int_rec.segment17;
	  segs_array(18) := int_rec.segment18;
	  segs_array(19) := int_rec.segment19;
	  segs_array(20) := int_rec.segment20;
	  segs_array(21) := int_rec.segment21;
	  segs_array(22) := int_rec.segment22;
	  segs_array(23) := int_rec.segment23;
	  segs_array(24) := int_rec.segment24;
	  segs_array(25) := int_rec.segment25;
	  segs_array(26) := int_rec.segment26;
	  segs_array(27) := int_rec.segment27;
	  segs_array(28) := int_rec.segment28;
	  segs_array(29) := int_rec.segment29;
	  segs_array(30) := int_rec.segment30;

	    -- Replace segment values having segment type 'N' with
            -- default segment values for that budget level
          BEGIN
            FOR app_col_name IN app_col(int_rec.set_of_books_id)
             LOOP
                l_seg_type  := NULL;
                l_seg_value := NULL;

               l_stmt:=
                'SELECT '||app_col_name.application_column_name||'_TYPE,'||
                 app_col_name.application_column_name||
                ' FROM   fv_budget_distribution_dtl
                  WHERE  set_of_books_id = :set_of_books_id
                  AND    budget_level_id = :budget_level_id
                  AND    fund_value = :fund_value ';

                EXECUTE IMMEDIATE l_stmt INTO l_seg_type, l_seg_value
                        USING int_rec.set_of_books_id, int_rec.budget_level_id,
			      int_rec.fund_value ;

		-- R12 - the Segment value 'N' has been replaced with 'D'
                -- Check if the segment type is D, If the segment type is
                -- D, then replace the segment value with the default
                -- segment value
                IF (l_seg_type = 'D')
                 THEN
                  segs_array(substr(app_col_name.application_column_name,8))
                     := l_seg_value;
                END IF;
             END LOOP;
        EXCEPTION
             WHEN NO_DATA_FOUND THEN
                errbuf := 'No Data Found error occurred while copying
                                     default segment values';
                  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message1',errbuf);
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'NO DATA FOUND ERROR OCCURRED
                while copying default segment values');
                retcode := -1;
                reset_control_status;
                ROLLBACK;
                RETURN;
             WHEN OTHERS THEN
                errbuf  := substr(sqlerrm,1,100)||':When others error occurred
                            while copying default segment values';
                  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message2',errbuf);
                  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,SUBSTR(SQLERRM,1,100)||':WHEN OTHERS ERROR
                  occurred while copying default segment values');
                retcode := -1;
                reset_control_status;
                ROLLBACK;
                RETURN;
        END;  -- Copy default values

          -- get chart of accounts id
          SELECT chart_of_accounts_id
          INTO   v_coa_id
          FROM   gl_ledgers_public_v
          WHERE  ledger_id = int_rec.set_of_books_id;

--------------------------------------------------------------------------------
-- Validate mandatory segments. Check if the segment values,
-- for segments which have segment type of Y, are provided
-- in the interface record.

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING MANDATORY SEGMENTS');
  END IF;
	BEGIN
	  FOR app_col_rec IN app_col(int_rec.set_of_books_id)
            LOOP
		-- Load the flex value set id for validating
		-- the segment values
                val_set_id_array(substr(app_col_rec.application_column_name,8))
 				:= app_col_rec.flex_value_set_id;

 	        l_stmt:=
		 'SELECT '||app_col_rec.application_column_name||'_TYPE
	          FROM   fv_budget_distribution_dtl
		  WHERE  set_of_books_id = :set_of_books_id
		   AND    budget_level_id = :budget_level_id
	           AND    fund_value = :fund_value ';

                EXECUTE IMMEDIATE l_stmt INTO l_seg_type
                        USING int_rec.set_of_books_id,
                              int_rec.budget_level_id, int_rec.fund_value;

		l_error_flag := FALSE;
                l_seg_value :=
                 segs_array(substr(app_col_rec.application_column_name,8));

		  -- R12 - the Segment value 'Y' has been replaced with 'E'
	          -- Check if the segment type is E and the segment
		  -- has a value. If the segment type is E and segment
		  -- value is null then update the record as error and
		  -- exit (no need to validate the remaining segments)

		  IF (l_seg_type = 'E' AND l_seg_value IS NULL)
		   THEN
		   update_err_code(int_rec.rowid,'EM31',
		   'There are more segments required for this budget level');
	           -- if any of the segments are in error
		   -- then no need to check for other segments
		     l_error_flag := TRUE;
		   EXIT;
                  END IF;
             END LOOP;
	EXCEPTION WHEN OTHERS THEN
	     errbuf  := 'When others error while validating mandatory segments.'||SQLERRM;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message3',errbuf);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'WHEN OTHERS ERROR WHILE VALIDATING
        mandatory segments');
	     retcode := -1;
	     ROLLBACK;
	     reset_control_status;
	     RETURN;
	END;

	-- if there is an error in any of the segments
	-- then skip the current record and go to next record
	IF l_error_flag
	 THEN EXIT;
	END IF;
-------------------------------------------------------------------------------
-- Validate segment values where the segment type is 'Y' (need not validate
-- segment values where segment type is 'N' since default values are copied
-- which already exist in the fv tables and hence have been validated) i.e.,
-- check whether the values exist in fnd_flex_values before cross validation.
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'VALIDATING SEGMENT VALUES');
    END IF;

        BEGIN
	  FOR app_col_rec IN app_col(int_rec.set_of_books_id)
	  LOOP

		l_seg_type := NULL;

                l_stmt:=
                'SELECT '||app_col_rec.application_column_name||'_TYPE
                 FROM   fv_budget_distribution_dtl
                 WHERE  set_of_books_id = :set_of_books_id
                  AND    budget_level_id = :budget_level_id
                  AND    fund_value = :fund_value ';

                EXECUTE IMMEDIATE l_stmt INTO l_seg_type
                        USING int_rec.set_of_books_id,
			      int_rec.budget_level_id, int_rec.fund_value;

		IF l_seg_type = 'E' THEN


	 			SELECT  validation_type
	 			into l_validation_type
	 			FROM FND_FLEX_VALUE_SETS
	 			WHERE flex_value_set_id=val_set_id_array(substr(app_col_rec.application_column_name,8,2));


    			   IF l_validation_type ='F' THEN
 		  			SELECT
 		  				application_table_name,
  						value_column_name
  	      				INTO  l_application_table_name,l_value_column_name
 		  			FROM FND_FLEX_VALIDATION_TABLES
 		  			WHERE flex_value_set_id=val_set_id_array(substr(app_col_rec.application_column_name,8,2));

  	    				 l_table_stmt := ' SELECT  1  FROM  '||l_application_table_name ||
  	    				 					'  WHERE  ' ||  l_value_column_name ||'  =  :b_seg_value' ;


					EXECUTE IMMEDIATE l_table_stmt INTO v_exists
									USING segs_array(substr(app_col_rec.application_column_name,8,2)) ;

			ELSE

				SELECT 'x'
  		 			INTO  v_exists
   					 FROM  fnd_flex_values
   					 WHERE  flex_value_set_id = val_set_id_array(substr(app_col_rec.application_column_name,8,2))
   					AND    flex_value =  segs_array(substr(app_col_rec.application_column_name,8,2))
 					AND    enabled_flag = 'Y';
    			END IF;


            END IF;
  	  END LOOP;
	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		update_err_code(int_rec.rowid, 'EM37',
			         'Invalid Segment values');
		-- exit second loop to continue processing next
		-- record
	        EXIT;
	    WHEN OTHERS THEN
        errbuf  := 'When others error while validating segment values.'||SQLERRM;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message3_1',errbuf);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'WHEN OTHERS ERROR WHILE VALIDATING
        segment values');
	     retcode := -1;
	     ROLLBACK;
	     reset_control_status;
	     RETURN;
        END;
-------------------------------------------------------------------------------
-- If the budget level is 1 then substitute the accounting segment value with
-- the value derived from gl_ussgl_accounting_pairs, once for debit_segment
-- value and once for credit_segment_value and then submit each for cross
-- validation.
-- If the budget level is not 1 then break up budgeting_segments into an array,
-- validate the segment values if the segment type is 'E' and copy the default
-- segment values into the array if the segment type is 'D'. Then substitute
-- accounting segment with dr_account_segment_value derived from the
-- transaction code. Use this as the header array for checking cross validation.
-- This is being done because the interface record contains the transaction
-- code which will be used for cross validation.
--------------------------------------------------------------------------------
	v_user_id := fnd_global.user_id;
  	v_resp_id := fnd_global.resp_id;

/* this is no longer being used in R12
  	fv_utility.get_context(v_user_id, v_resp_id, 'ACCT_SEGMENT',
                        acc_seg_name, v_err_code, errbuf);
 implementing new r12 call below   */
  fv_utility.get_segment_col_names(v_coa_id, acc_seg_name, v_bal_seg_name,
     v_err_code,errbuf);

  	IF v_err_code THEN
       	 retcode := -1;
      errbuf := 'Error when getting accounting segment';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message4',errbuf);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'ERROR WHEN GETTING ACCOUNTING SEGMENT');
	 ROLLBACK;
	 reset_control_status;
       	 RETURN;
  	END IF;

	-- Initialize the flag being used in the loop below
	validation_failed := FALSE;

	FOR trans_code IN accounts_cur(int_rec.sub_type)
         LOOP
		v_temp_seg_val := NULL;

	  IF int_rec.budget_level_id = 1 THEN
	    FOR i IN 1..2
	     LOOP

		IF i = 1 THEN
		   v_temp_seg_val := trans_code.dr_account_segment_value;
		 ELSE
		   v_temp_seg_val := trans_code.cr_account_segment_value;
		END IF;

		segs_array(substr(acc_seg_name,8,2)) := v_temp_seg_val;

		-- Checking cross-validation
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CHECKING CROSS VALIDATION');
    END IF;
        	FV_BE_UTIL_PKG.check_cross_validation(l_val_errbuf,
		l_val_retcode,v_coa_id, segs_array, segs_array,
		int_rec.budget_level_id, v_tt_id,int_rec.sub_type,
		int_rec.source,  int_rec.increase_decrease_flag);

		-- If a value fails validation then set
		-- validation_failed to true and exit the current
		-- loop
		IF (l_val_retcode = 2)
                 THEN
                  validation_failed := TRUE;
		  EXIT;
		END IF;

             END LOOP;

	  ELSE -- if budget_level_id is not 1

	    BEGIN
		SELECT concatenated_segment_delimiter
        	INTO   v_delimiter
        	FROM   fnd_id_flex_structures ffs,
               	       gl_ledgers_public_v gsb
        	WHERE  application_id      = 101
        	AND    id_flex_code        = 'GL#'
        	AND    ffs.id_flex_num     = gsb.chart_of_accounts_id
        	AND    gsb.ledger_id = int_rec.set_of_books_id;

	       v_num_segs := fnd_flex_ext.breakup_segments(int_rec.budgeting_segments, v_delimiter,
					 tmp_hdr_segs_array);
           FOR I IN 1..30 LOOP
                hdr_segs_array(I) := NULL;
           END LOOP;
           v_index := 0;
           FOR cols_rec IN (SELECT application_column_name
                            FROM fnd_id_flex_segments
                            WHERE id_flex_code = 'GL#'
                              AND id_flex_num = v_coa_id
                            ORDER BY segment_num)
            LOOP
                v_index := v_index + 1;
                hdr_segs_array(substr(rtrim(cols_rec.application_column_name),8)) := tmp_hdr_segs_array(v_index);
            END LOOP;

	    EXCEPTION
	      WHEN NO_DATA_FOUND THEN
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'WHEN NO DATA FOUND EXCEPTION WHILE GETTING
            delimiter');
          errbuf  := 'When no data found while getting delimiter';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message5',errbuf);
                retcode := -1;
                reset_control_status;
                ROLLBACK;
                RETURN;
	      WHEN OTHERS THEN
          errbuf  := 'When others exception while getting delimiter'||SQLERRM;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'WHEN OTHERS EXCEPTION WHILE GETTING
          delimiter');
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message6',errbuf);
                retcode := -1;
                reset_control_status;
                ROLLBACK;
                RETURN;
            END;

		  v_acc_seg_index := 0;
		  v_index := 0;

	    FOR app_col_rec IN app_col(int_rec.set_of_books_id)
	     LOOP

		  l_seg_type := NULL;

                     l_stmt:=
                      'SELECT '||app_col_rec.application_column_name||'_TYPE
                       FROM   fv_budget_distribution_dtl
                        WHERE  set_of_books_id = :set_of_books_id
                        AND    fund_value = :fund_value
                        AND    budget_level_id =
                        (SELECT MAX(budget_level_id)
                        FROM   fv_budget_distribution_dtl
                        WHERE  fund_value      = :fund_value
                        AND    set_of_books_id = :set_of_books_id
                        AND    budget_level_id < :budget_level_id )';

                  EXECUTE IMMEDIATE l_stmt INTO l_seg_type
                        USING int_rec.set_of_books_id, int_rec.fund_value,
			      int_rec.fund_value, int_rec.set_of_books_id,
			      int_rec.budget_level_id ;

		  v_index := v_index + 1;

		  IF acc_seg_name = app_col_rec.application_column_name
		     THEN
			v_acc_seg_index := v_index;
		  END IF;

		  IF l_seg_type = 'E' THEN
			IF hdr_segs_array(substr(rtrim(app_col_rec.application_column_name),8)) IS NULL
			   THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'MISSING BUDGETARY SEGMENT');
            END IF;
			     missing_bud_segs := TRUE;
			     EXIT;
			END IF;
		  END IF;

                 IF l_seg_type = 'D'
		    THEN

                      l_stmt:=
                      'SELECT '||app_col_rec.application_column_name||
                      ' FROM   fv_budget_distribution_dtl
                        WHERE  set_of_books_id = :set_of_books_id
                        AND    fund_value = :fund_value
                        AND    budget_level_id =
                        (SELECT MAX(budget_level_id)
                        FROM   fv_budget_distribution_dtl
                        WHERE  fund_value      = :fund_value
                        AND    set_of_books_id = :set_of_books_id
                        AND    budget_level_id < :budget_level_id )';

                    EXECUTE IMMEDIATE l_stmt INTO hdr_segs_array(substr(rtrim(app_col_rec.application_column_name),8))
                        USING int_rec.set_of_books_id, int_rec.fund_value,
                              int_rec.fund_value, int_rec.set_of_books_id,
                              int_rec.budget_level_id ;

		  END IF;
	    END LOOP; -- app_col_rec

		hdr_segs_array(substr(acc_seg_name,8,2)) :=
		                             trans_code.dr_account_segment_value;

		segs_array(substr(acc_seg_name,8,2)) :=
		                             trans_code.cr_account_segment_value;

                -- Checking cross-validation for budget_level other than 1
        	FV_BE_UTIL_PKG.check_cross_validation(l_val_errbuf,
		l_val_retcode,v_coa_id, segs_array, segs_array,
		int_rec.budget_level_id, v_tt_id,int_rec.sub_type,
		int_rec.source,  int_rec.increase_decrease_flag);

		-- If a
                -- If a value fails validation then set
                -- validation_failed to true and exit the current
                -- loop
                IF (l_val_retcode = 2)
                 THEN
                  validation_failed := TRUE;
                  EXIT;
                END IF;


         END IF; -- if budget_level_id = 1
	END LOOP; -- trans_code

	-- If cross validation failed OR any values missing from budgeting
	-- segments then exit the current record and continue processing the
	-- next record
        IF validation_failed
          THEN
	   update_err_code(int_rec.rowid,'EM43',
		 'Segments failed cross validation');
	   EXIT;
	END IF;

        IF missing_bud_segs
          THEN
           update_err_code(int_rec.rowid,'EM41',
                 'Missing segment value in budgeting segments');
           EXIT;
        END IF;

-------------------------------------------------------------------------------
      -- Since no more validations are needed, update
      -- the status of this record to accepted,
      -- exit the loop and go to next rec, if any
	UPDATE fv_be_interface
	SET    status = 'ACCEPTED',
	       processed_flag = 'Y'
	WHERE  rowid = int_rec.rowid ;

	EXIT;

     END LOOP; -- Second
   END LOOP;  -- First

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'****** VALIDATION COMPLETE  ******');
    END IF;
--------------------------------------------------------------------------------
   -- Validation of all records are complete
   -- If any records are rejected, update the control table
   -- and exit, else continue processing

      	v_rej_rec_count := 0;

	SELECT count(*)
	INTO   v_rej_rec_count
	FROM   fv_be_interface
	WHERE  group_id = parm_group_id
	AND    source   = parm_source
        AND    set_of_books_id = parm_ledger_id
	AND    status = 'REJECTED';

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'****** RECORDS REJECTED :'||
      v_rej_rec_count||' ******');
    END IF;

	IF v_rej_rec_count > 0
	  THEN
	  reset_control_status;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SUBMITTING BE TRANSACTIONS IMPORT REPORT');
    END IF;

	 v_req_id := FND_REQUEST.SUBMIT_REQUEST
                    ('FV','FVBEINTR','','',FALSE, parm_ledger_id, parm_source, parm_group_id);

         -- If the request submission fails, then abort process
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'REQEST ID FOR REPORT = '||
      to_char(v_req_id)) ;
    END IF;

  	 IF (v_req_id = 0)
           THEN
           errbuf := 'Unable to submit BE Transactions Import Report';
           retcode := -1;
             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message7',errbuf);
	   ROLLBACK;
	   reset_control_status;
           RETURN;
         END IF;


        END IF;
	-- If all records are accepted then process them
	IF v_rej_rec_count = 0
	 THEN

	 FOR valid_rec IN int
	  LOOP

	   l_stmt         := NULL;
	   l_seg_type     := NULL;
	   v_doc_status   := NULL;
	   v_doc_id       := NULL;
	   v_revision_num := NULL;
	   v_int_rev_num  := NULL;
	   ins_hdr	  := FALSE;

		-- copy interface segment values into the array
		-- for concatenation (to create budgeting segments)
	     	segs_array.DELETE;

	        segs_array(1)  := valid_rec.segment1;
	        segs_array(2)  := valid_rec.segment2;
	  	segs_array(3)  := valid_rec.segment3;
	  	segs_array(4)  := valid_rec.segment4;
	  	segs_array(5)  := valid_rec.segment5;
	  	segs_array(6)  := valid_rec.segment6;
	  	segs_array(7)  := valid_rec.segment7;
	  	segs_array(8)  := valid_rec.segment8;
	  	segs_array(9)  := valid_rec.segment9;
	  	segs_array(10) := valid_rec.segment10;
	  	segs_array(11) := valid_rec.segment11;
	  	segs_array(12) := valid_rec.segment12;
	  	segs_array(13) := valid_rec.segment13;
	  	segs_array(14) := valid_rec.segment14;
	  	segs_array(15) := valid_rec.segment15;
	  	segs_array(16) := valid_rec.segment16;
	  	segs_array(17) := valid_rec.segment17;
	  	segs_array(18) := valid_rec.segment18;
	  	segs_array(19) := valid_rec.segment19;
	  	segs_array(20) := valid_rec.segment20;
	  	segs_array(21) := valid_rec.segment21;
	  	segs_array(22) := valid_rec.segment22;
	  	segs_array(23) := valid_rec.segment23;
	  	segs_array(24) := valid_rec.segment24;
	  	segs_array(25) := valid_rec.segment25;
	  	segs_array(26) := valid_rec.segment26;
	  	segs_array(27) := valid_rec.segment27;
	  	segs_array(28) := valid_rec.segment28;
	  	segs_array(29) := valid_rec.segment29;
	  	segs_array(30) := valid_rec.segment30;
	  begin
	    select 'x' into v_source_exists
             from fv_lookup_codes
            where lookup_type='BE_SOURCE'
            AND lookup_code=valid_rec.source;

         exception
             WHEN NO_DATA_FOUND THEN
             valid_rec.source:= 'OTHER' ;
         end;

	    -- Replace segment values having segment type 'N' with
            -- default segment values for that budget level
          IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'REPLACING SEGMENT VALUES WITH DEFAULT
            segment values before inserting');
          END IF;
          BEGIN
            FOR app_col_name IN app_col(valid_rec.set_of_books_id)
             LOOP
                l_seg_type  := NULL;
                l_seg_value := NULL;

               l_stmt:=
                'SELECT '||app_col_name.application_column_name||'_TYPE,'||
                 app_col_name.application_column_name||
                ' FROM   fv_budget_distribution_dtl
                  WHERE  set_of_books_id = :set_of_books_id
                  AND    budget_level_id = :budget_level_id
                  AND    fund_value = :fund_value ';

                EXECUTE IMMEDIATE l_stmt INTO l_seg_type, l_seg_value
                        USING valid_rec.set_of_books_id,
			      valid_rec.budget_level_id,
			      valid_rec.fund_value ;

                -- Check if the segment type is N. If the segment type is
                -- N, then replace the segment value with the default
                -- segment value

                IF (l_seg_type = 'D')
                 THEN
                  segs_array(substr(app_col_name.application_column_name,8)):= l_seg_value;
                END IF;
             END LOOP;
        EXCEPTION
             WHEN NO_DATA_FOUND THEN
                errbuf := 'No Data Found error occurred while copying default segment values';
                  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message8',errbuf);
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'NO DATA FOUND ERROR OCCURRED
                while copying default segment values');
                retcode := -1;
                reset_control_status;
                ROLLBACK;
                RETURN;

             WHEN OTHERS THEN
                errbuf  := substr(sqlerrm,1,100)||':When others error occurred while copying default segment values';
                  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message9',errbuf);
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,SUBSTR(SQLERRM,1,100)||':WHEN OTHERS ERROR
                occurred while copying default segment values');
                retcode := -1;
                reset_control_status;
                ROLLBACK;
                RETURN;
        END;  -- Copy default values
		-- concatenate segments for budgeting segments
		concat_segs(segs_array, valid_rec.set_of_books_id,
			    v_bud_segs);

	      SELECT be_tt_id,
		     public_law_code_flag,
		     advance_flag,
		     transfer_flag
	      INTO   v_tt_id,
		     g_pub_law_code_flag,
		     g_advance_flag,
		     g_transfer_flag
	      FROM   fv_be_transaction_types
	      WHERE  set_of_books_id = valid_rec.set_of_books_id
	      AND    budget_level_id = valid_rec.budget_level_id
	      AND    apprn_transaction_type = valid_rec.transaction_type;

	    -- check if document number exists
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'CHECKING IF DOC :'||VALID_REC.DOC_NUMBER||
          ' exists for fund '||valid_rec.fund_value||
          ' and budget level id: '||valid_rec.budget_level_id);
      END IF;
	    BEGIN
 	      SELECT internal_revision_num, doc_id, revision_num
	      INTO   v_int_rev_num, v_doc_id, v_revision_num
	      FROM   fv_be_trx_hdrs
	      WHERE  set_of_books_id = valid_rec.set_of_books_id
	      AND    budget_level_id = valid_rec.budget_level_id
	      AND    doc_number      = valid_rec.doc_number
	      AND    source	     = valid_rec.source
              FOR UPDATE OF doc_total;
	    EXCEPTION WHEN NO_DATA_FOUND THEN
	      v_int_rev_num := -9999;
	      ins_hdr := TRUE;
	    END;

	    -- If doc does not exist, it is a new record
	    -- Note: Temporarily set status to IMPORTING
	    -- then update it to IN or RA
	    -- set the internal rev num to -9999 to distinguish
	    -- existing hdr from a new hdr and later update it
	    -- to 0
	    IF ins_hdr THEN

		SELECT fv_be_trx_hdrs_s.nextval
		INTO   new_doc_id
		FROM   DUAL;

		SELECT treasury_symbol_id
		INTO   v_ts_id
		FROM   fv_fund_parameters
		WHERE  fund_value = valid_rec.fund_value
		AND    set_of_books_id = valid_rec.set_of_books_id;

	      IF valid_rec.budget_level_id = 1 THEN
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'INSERTING NEW HEADER RECORD');
         END IF;
		-- Select the budget group id for the User
		BEGIN
			SELECT bu_group_id
				INTO  l_bu_group_id
				FROM  fv_budget_user_dtl
				WHERE set_of_books_id = valid_rec.set_of_books_id
				AND   bu_user_id      = valid_rec.budget_user_id
				AND   valid_rec.budget_level_id BETWEEN bu_access_level_from AND bu_access_level_to;
		EXCEPTION
			WHEN OTHERS THEN
		  		retcode := -1;
		                errbuf := 'Invalid budget user or Access level';
		                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,errbuf);
                    		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'Error in getting the Group ID'
								|| ' for the user user id => '||valid_rec.budget_user_id
								|| ' budget level id  ' || valid_rec.budget_level_id  );
                  		reset_control_status;
		                ROLLBACK;
                		RETURN;
		END;

	        INSERT INTO fv_be_trx_hdrs (
	         budgeting_segments, budget_level_id,
	         doc_id, doc_number, doc_status,
	         doc_total, fund_value, internal_revision_num, revision_num,
	         set_of_books_id,bu_group_id, source, transaction_date,
	         treasury_symbol_id, created_by, creation_date,
		 last_updated_by, last_update_date, last_update_login,
	         segment1, segment2, segment3, segment4,
	         segment5, segment6, segment7, segment8, segment9, segment10,
	         segment11, segment12, segment13, segment14, segment15,
		 segment16, segment17, segment18, segment19, segment20,
		 segment21, segment22, segment23, segment24, segment25,
		 segment26, segment27, segment28, segment29, segment30)
	        VALUES
	         (v_bud_segs, valid_rec.budget_level_id,
                 new_doc_id, valid_rec.doc_number, 'IMPORTING',
	         0, valid_rec.fund_value, -9999, 0,
	         valid_rec.set_of_books_id,l_bu_group_id, valid_rec.source, TRUNC(SYSDATE),
	         v_ts_id, fnd_global.user_id, SYSDATE,
	         fnd_global.user_id, SYSDATE, fnd_global.login_id,
	         segs_array(1), segs_array(2), segs_array(3),
	         segs_array(4), segs_array(5), segs_array(6),
	         segs_array(7), segs_array(8), segs_array(9),
	         segs_array(10), segs_array(11), segs_array(12),
	         segs_array(13), segs_array(14), segs_array(15),
	         segs_array(16), segs_array(17), segs_array(18),
	         segs_array(19), segs_array(20), segs_array(21),
	         segs_array(22), segs_array(23), segs_array(24),
	         segs_array(25), segs_array(26), segs_array(27),
	         segs_array(28), segs_array(29), segs_array(30));

	     ELSE -- if budget level <> 1 copy segments for previous budget
		  -- level from the details table.  Error the process if
		  -- segments not found.

	     -- Breakup the budgeting segments and copy the default segment values
	     -- if segment type is 'N'.  Then concatenate the broken up segments
	     -- with the defalt segment values to form new budgeting_segments
	     -- and insert into the record.
	       v_num_segs := 0;
	       v_index := 0;
	       dummy_array.DELETE;
		v_delimiter := null;

	       SELECT concatenated_segment_delimiter
        	INTO   v_delimiter
        	FROM   fnd_id_flex_structures ffs,
               	       gl_ledgers_public_v gsb
        	WHERE  application_id      = 101
        	AND    id_flex_code        = 'GL#'
        	AND    ffs.id_flex_num     = gsb.chart_of_accounts_id
        	AND    gsb.ledger_id = valid_rec.set_of_books_id;

	       v_num_segs :=
               fnd_flex_ext.breakup_segments(valid_rec.budgeting_segments,
					     v_delimiter, dummy_array);

	       IF v_num_segs = 0
		THEN
		  retcode := -1;
                  errbuf := 'No segments found in budgeting_segments';
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message10',errbuf);
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'NO SEGMENTS FOUND IN BUDGETING SEGMENTS');
                  reset_control_status;
                  ROLLBACK;
                  RETURN;
	       END IF;

               FOR app_col_rec IN app_col(valid_rec.set_of_books_id)
                LOOP

                  l_seg_type := NULL;

                  l_stmt:=
                      'SELECT '||app_col_rec.application_column_name||'_TYPE
                       FROM   fv_budget_distribution_dtl
                        WHERE  set_of_books_id = :set_of_books_id
                        AND    fund_value = :fund_value
                        AND    budget_level_id =
                        (SELECT MAX(budget_level_id)
                        FROM   fv_budget_distribution_dtl
                        WHERE  fund_value      = :fund_value
                        AND    set_of_books_id = :set_of_books_id
                        AND    budget_level_id < :budget_level_id )';

                  EXECUTE IMMEDIATE l_stmt INTO l_seg_type
			  USING valid_rec.set_of_books_id,
			        valid_rec.fund_value,
			        valid_rec.fund_value,
				valid_rec.set_of_books_id,
				valid_rec.budget_level_id ;

		  v_index := v_index + 1;

                 IF l_seg_type = 'D'
                    THEN

                      l_stmt:=
                      'SELECT '||app_col_rec.application_column_name||
                      ' FROM   fv_budget_distribution_dtl
                        WHERE  set_of_books_id = :set_of_books_id
                        AND    fund_value = :fund_value
                        AND    budget_level_id =
			(SELECT MAX(budget_level_id)
                        FROM   fv_budget_distribution_dtl
                        WHERE  fund_value      = :fund_value
                        AND    set_of_books_id = :set_of_books_id
                        AND    budget_level_id < :budget_level_id )';

                    EXECUTE IMMEDIATE l_stmt INTO dummy_array(v_index)
			USING valid_rec.set_of_books_id,
			      valid_rec.fund_value,
			      valid_rec.fund_value,
			      valid_rec.set_of_books_id,
			      valid_rec.budget_level_id ;

                 END IF;
		END LOOP; -- app_col_rec

		-- Concatenate segments in dummy_array
		v_num_segs := 0;

	        v_num_segs := dummy_array.COUNT;

		valid_rec.budgeting_segments :=
		              fnd_flex_ext.concatenate_segments(v_num_segs,
			      dummy_array, v_delimiter);

	     BEGIN
               SELECT fbd.segment1, fbd.segment2, fbd.segment3, fbd.segment4,
                      fbd.segment5, fbd.segment6, fbd.segment7, fbd.segment8,
                      fbd.segment9, fbd.segment10,fbd.segment11,fbd.segment12,
                      fbd.segment13,fbd.segment14,fbd.segment15,fbd.segment16,
                      fbd.segment17,fbd.segment18,fbd.segment19,fbd.segment20,
                      fbd.segment21,fbd.segment22,fbd.segment23,fbd.segment24,
                      fbd.segment25,fbd.segment26,fbd.segment27, fbd.segment28,
                      fbd.segment29, fbd.segment30
               INTO   v_segment1, v_segment2, v_segment3, v_segment4,
                      v_segment5, v_segment6, v_segment7, v_segment8,
                      v_segment9, v_segment10, v_segment11, v_segment12,
                      v_segment13, v_segment14, v_segment15, v_segment16,
                      v_segment17, v_segment18, v_segment19, v_segment20,
                      v_segment21, v_segment22, v_segment23, v_segment24,
                      v_segment25, v_segment26, v_segment27, v_segment28,
                      v_segment29, v_segment30
               FROM   fv_be_trx_hdrs fbh,
                      fv_be_trx_dtls fbd
               WHERE  fbh.fund_value      = valid_rec.fund_value
               AND    fbh.set_of_books_id = valid_rec.set_of_books_id
               AND    fbh.doc_id          = fbd.doc_id
               AND    fbh.set_of_books_id = fbd.set_of_books_id
               AND    fbd.budgeting_segments = valid_rec.budgeting_segments
               AND    rownum < 2
               AND    fbh.budget_level_id =
                       (SELECT MAX(budget_level_id)
                       -- FROM   fv_budget_distribution_dtl
                        FROM   fv_be_trx_dtls
                        WHERE  fund_value      = valid_rec.fund_value
                        AND    set_of_books_id = valid_rec.set_of_books_id
                        AND    budget_level_id < valid_rec.budget_level_id
                        );

             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  retcode := -1;
                  errbuf := 'No records found with the same segments for the previous budget level';
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message11',errbuf);
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'NO RECORDS FOUND WITH THE SAME SEGMENTS
                      for the previous budget level');
--	                     reset_control_status;
--                        ROLLBACK;
			update_err_rec(valid_rec.record_number);
                        RETURN;
                WHEN OTHERS THEN
                  retcode := -1;
                  errbuf := 'When others error while checking for segments in the previous budget level.'||SQLERRM;
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'message12',errbuf);
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'WHEN OTHERS ERROR WHILE CHECKING FOR
                    segments in the previous budget level');
                        reset_control_status;
                        ROLLBACK;
                        RETURN;
             END;

        BEGIN
                SELECT bu_group_id
                INTO l_bu_group_id
                FROM fv_budget_user_dtl
                WHERE set_of_books_id = valid_rec.set_of_books_id
                AND bu_user_id = valid_rec.budget_user_id
                AND valid_rec.budget_level_id BETWEEN bu_access_level_from and bu_access_level_to;
        EXCEPTION
                WHEN OTHERS THEN
                    retcode := -1;
                    errbuf := 'Invalid budget user or Acecess level';
                    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, errbuf);
                    reset_control_status;
                    RETURN;
        END;

	        INSERT INTO fv_be_trx_hdrs (
	         budgeting_segments, budget_level_id,
	         doc_id, doc_number, doc_status,
	         doc_total, fund_value, internal_revision_num, revision_num,
	         set_of_books_id, bu_group_id,source, transaction_date,
	         treasury_symbol_id, created_by, creation_date,
	         last_updated_by, last_update_date, last_update_login,
	         segment1, segment2, segment3, segment4, segment5,
		 segment6, segment7, segment8, segment9, segment10,
	         segment11, segment12, segment13, segment14, segment15,
		 segment16, segment17, segment18, segment19, segment20,
		 segment21, segment22, segment23, segment24, segment25,
		 segment26, segment27, segment28, segment29, segment30)
	        VALUES
	         (valid_rec.budgeting_segments, valid_rec.budget_level_id,
                 new_doc_id, valid_rec.doc_number, 'IMPORTING',
	         0, valid_rec.fund_value, -9999, 0,
	         valid_rec.set_of_books_id, l_bu_group_id,valid_rec.source, TRUNC(SYSDATE),
	         v_ts_id, fnd_global.user_id, SYSDATE,
	         fnd_global.user_id, SYSDATE, fnd_global.login_id,
	         v_segment1, v_segment2, v_segment3, v_segment4, v_segment5,
		 v_segment6, v_segment7, v_segment8, v_segment9, v_segment10,
		 v_segment11, v_segment12, v_segment13, v_segment14,
		 v_segment15, v_segment16, v_segment17, v_segment18,
	         v_segment19, v_segment20, v_segment21, v_segment22,
		 v_segment23, v_segment24, v_segment25, v_segment26,
		 v_segment27, v_segment28, v_segment29, v_segment30);

	    END IF; -- if budget level = 1

		-- set values for detail record if the doc is new
		   v_doc_id := new_doc_id;
		   v_revision_num := 0;

           END IF; -- ins_hdr

		-- For a new document dtl revision num is 0,
		-- for an existing document it is hdr rev num+1
		IF v_int_rev_num = -9999
                 THEN v_revision_num := 0;
                ELSE
                      v_revision_num := v_revision_num + 1;
		END IF;

		IF g_pub_law_code_flag <> 'Y' THEN
	           valid_rec.public_law_code := NULL;
		END IF;

		IF g_pub_law_code_flag <> 'Y' THEN
	           valid_rec.public_law_code := NULL;
		END IF;

		IF g_advance_flag <> 'Y' THEN
	           valid_rec.advance_type := NULL;
                 ELSE
	           valid_rec.advance_type := g_advance_type_code;
		END IF;

		IF g_transfer_flag <> 'Y' THEN
	           valid_rec.dept_id := NULL;
	           valid_rec.main_account := NULL;
	           valid_rec.transfer_description := NULL;
		END IF;
      validate_gl_date(valid_rec.gl_date,
				 valid_rec.set_of_books_id,
				 v_quarter_num);
      INSERT INTO fv_be_trx_dtls
      (
        amount,
        budgeting_segments,
        doc_id,
        gl_date,
        quarter_num,
        gl_transfer_flag,
        increase_decrease_flag,
        revision_num,
        set_of_books_id,
        sub_type,
        transaction_id,
        transaction_status,
        transaction_type_id,
        source,
        group_id,
        corrected_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        segment1,
        segment2,
        segment3,
        segment4,
        segment5,
        segment6,
        segment7,
        segment8,
        segment9,
        segment10,
        segment11,
        segment12,
        segment13,
        segment14,
        segment15,
        segment16,
        segment17,
        segment18,
        segment19,
        segment20,
        segment21,
        segment22,
        segment23,
        segment24,
        segment25,
        segment26,
        segment27,
        segment28,
        segment29,
        segment30,
        public_law_code,
        advance_type,
        dept_id,
        main_account,
        transfer_description,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15
      )
      VALUES
      (
        valid_rec.amount,
        v_bud_segs,
        v_doc_id,
        valid_rec.gl_date,
        v_quarter_num,
        'N',
        valid_rec.increase_decrease_flag,
        v_revision_num,
        valid_rec.set_of_books_id,
        valid_rec.sub_type,
        fv_be_trx_dtls_s.nextval,
        'IN',
        v_tt_id,
        valid_rec.source,
        valid_rec.group_id,
        valid_rec.corrected_flag,
        fnd_global.user_id,
        SYSDATE,
        fnd_global.user_id,
        SYSDATE,
        fnd_global.login_id,
        segs_array(1),
        segs_array(2),
        segs_array(3),
        segs_array(4),
        segs_array(5),
        segs_array(6),
        segs_array(7),
        segs_array(8),
        segs_array(9),
        segs_array(10),
        segs_array(11),
        segs_array(12),
        segs_array(13),
        segs_array(14),
        segs_array(15),
        segs_array(16),
        segs_array(17),
        segs_array(18),
        segs_array(19),
        segs_array(20),
        segs_array(21),
        segs_array(22),
        segs_array(23),
        segs_array(24),
        segs_array(25),
        segs_array(26),
        segs_array(27),
        segs_array(28),
        segs_array(29),
        segs_array(30),
        valid_rec.public_law_code,
        valid_rec.advance_type,
        valid_rec.dept_id,
        valid_rec.main_account,
        valid_rec.transfer_description,
        valid_rec.attribute_category,
        DECODE(validation, 'N', NULL, valid_rec.attribute1),
        DECODE(validation, 'N', NULL, valid_rec.attribute2),
        DECODE(validation, 'N', NULL, valid_rec.attribute3),
        DECODE(validation, 'N', NULL, valid_rec.attribute4),
        DECODE(validation, 'N', NULL, valid_rec.attribute5),
        DECODE(validation, 'N', NULL, valid_rec.attribute6),
        DECODE(validation, 'N', NULL, valid_rec.attribute7),
        DECODE(validation, 'N', NULL, valid_rec.attribute8),
        DECODE(validation, 'N', NULL, valid_rec.attribute9),
        DECODE(validation, 'N', NULL, valid_rec.attribute10),
        DECODE(validation, 'N', NULL, valid_rec.attribute11),
        DECODE(validation, 'N', NULL, valid_rec.attribute12),
        DECODE(validation, 'N', NULL, valid_rec.attribute13),
        DECODE(validation, 'N', NULL, valid_rec.attribute14),
        DECODE(validation, 'N', NULL, valid_rec.attribute15)
      );

	         SELECT DECODE(valid_rec.increase_decrease_flag,'I',
			    valid_rec.amount, (-1 * valid_rec.amount))
	         INTO v_amount FROM DUAL;

		 -- set the doc status to IMPORTING to identify which
		 -- header records status should be changed to IN
		 UPDATE fv_be_trx_hdrs
		 SET    doc_status = 'IMPORTING',
			doc_total = doc_total + v_amount
		 WHERE  doc_id = v_doc_id;

          END LOOP;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RUNNING UPDATE CLEANUP');
      END IF;
		 update_cleanup(parm_source,parm_group_id);

	         IF retcode <> 0
		  THEN
		   ROLLBACK;
		   reset_control_status;
		   RETURN;
		 END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'SUBMITTING BE TRANSACTIONS IMPORT REPORT');
    END IF;
	 v_req_id := 0;

	 v_req_id := FND_REQUEST.SUBMIT_REQUEST
                    ('FV','FVBEINTR','','',FALSE, parm_ledger_id, parm_source, parm_group_id);

         -- If the request submission fails, then abort process
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'REQEST ID FOR REPORT = '||
          to_char(v_req_id)) ;
      END IF;

  	 IF (v_req_id = 0)
           THEN
           errbuf := 'Unable to submit BE Transactions Import Report';
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message13',errbuf);
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'UNABLE TO SUBMIT BE TRANSACTIONS IMPORT REPORT');
           retcode := -1;
	   ROLLBACK;
	   reset_control_status;
           RETURN;
         END IF;

	END IF; -- v_rej_rec_count=0

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    retcode := -1;
    errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);

END; -- Main
--------------------------------------------------------------------------------
-- Procedures being used by the above code
--------------------------------------------------------------------------------
-- Procedure to update error records in the
-- fv_be_interface table
PROCEDURE update_err_code(l_rowid VARCHAR2, l_err_code VARCHAR2,
		          l_err_reason VARCHAR2) IS
  	l_module_name VARCHAR2(200);
	BEGIN
		l_module_name := g_module_name || 'update_err_code';
		UPDATE fv_be_interface
		SET    error_code = l_err_code,
		       error_reason = l_err_reason,
		       status = 'REJECTED',
		       processed_flag = 'Y'
		WHERE  rowid = l_rowid;
EXCEPTION
  WHEN OTHERS THEN
   errbuf := SQLERRM;
   retcode := -1;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);

	END update_err_code;
--------------------------------------------------------------------------------
-- Procedure to validate set of books id
PROCEDURE validate_sob(v_sob_id NUMBER) IS
	l_module_name VARCHAR2(200);
	BEGIN
		l_module_name := g_module_name || 'validate_sob';
          	SELECT 'x'
		INTO   v_exists
                FROM   gl_ledgers_public_v
                WHERE  ledger_id = v_sob_id;
          EXCEPTION
		WHEN NO_DATA_FOUND THEN
		  v_error_code := -9;
		WHEN OTHERS THEN
		  retcode := -1;
		  errbuf := 'When others error while validating set of books id.'||SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'WHEN OTHERS ERROR WHILE VALIDATING
        set of books id');
		  reset_control_status;
	END validate_sob;
--------------------------------------------------------------------------------
-- Procedure to validate period name
PROCEDURE validate_gl_date(v_gl_date VARCHAR2,
                           v_set_of_books_id NUMBER,
                           v_quarter_num OUT NOCOPY NUMBER) IS
	l_module_name VARCHAR2(200);
        BEGIN
		l_module_name := g_module_name || 'validate_gl_date';
                v_quarter_num := NULL;
                SELECT quarter_num
                INTO   v_quarter_num
                FROM   gl_period_statuses
                WHERE  v_gl_date BETWEEN start_date AND end_date
                AND    set_of_books_id = v_set_of_books_id
		AND    closing_status IN ('O','F')
	        AND    adjustment_period_flag = 'N'
                AND    application_id = 101;
          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  v_error_code := -9;
                WHEN OTHERS THEN
                  retcode := -1;
                  errbuf := 'When others error while validating period name.'||SQLERRM;
                  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
                  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'WHEN OTHERS ERROR WHILE VALIDATING
                      period name');
                  reset_control_status;
END validate_gl_date;
--------------------------------------------------------------------------------
-- Procedure to validate budget level
PROCEDURE validate_budget_level(v_set_of_books_id NUMBER,
				v_budget_level_id NUMBER) IS
	l_module_name VARCHAR2(200);
       BEGIN
		l_module_name := g_module_name || 'validate_budget_level';
		SELECT 'x'
	       	INTO   v_exists
    	       	FROM   fv_budget_levels
     	       	WHERE  budget_level_id = v_budget_level_id
    	       	AND    set_of_books_id = v_set_of_books_id;
        EXCEPTION
		WHEN NO_DATA_FOUND THEN
		  v_error_code := -9;
		WHEN OTHERS THEN
      retcode := -1;
      errbuf := 'When others error while validating budget level.'||SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'WHEN OTHERS ERROR WHILE VALIDATING
        budget level');
      reset_control_status;
      END validate_budget_level;
---------------------------------------------------------------------------------
-- Validate budget User
PROCEDURE validate_budget_user( p_sob_id    	  NUMBER,
				p_bu_user_id 	  NUMBER) IS
	l_count NUMBER;
	l_module_name VARCHAR2(200);

BEGIN
	l_module_name := g_module_name || 'validate_budget_user';
	SELECT COUNT(*)
		INTO l_count
		FROM  fv_budget_user_dtl
		WHERE set_of_books_id = p_sob_id
		AND   bu_user_id      = p_bu_user_id;
	IF l_count = 0 THEN
		v_error_code := -10;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
      		retcode := -1;
	        errbuf := 'When others error while validating budget User.'||SQLERRM;
      		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
      		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'WHEN OTHERS ERROR WHILE VALIDATING
        			budget User user ID =>'|| p_bu_user_id);
                reset_control_status;

END;---------------------------------------------------------------------------------
-- Validate budget User
PROCEDURE validate_bu_access_level(  p_sob_id    	  NUMBER,
			             p_bu_user_id 	  NUMBER,
	 			     p_budget_level_id NUMBER) IS
	l_update_flag VARCHAR2(1);
	l_module_name VARCHAR2(200);

BEGIN
	l_module_name := g_module_name || 'validate_bu_access_level';
	SELECT NVL(bu_update_flag,'N')
		INTO  l_update_flag
		FROM  fv_budget_user_dtl
		WHERE set_of_books_id = p_sob_id
		AND   bu_user_id      = p_bu_user_id
		AND   p_budget_level_id BETWEEN bu_access_level_from AND bu_access_level_to;
	IF l_update_flag  ='N' THEN
		v_error_code := -11;
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 v_error_code := -11;
	WHEN OTHERS THEN
      		retcode := -1;
	        errbuf := 'When others error while validating budget User.'||SQLERRM;
      		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
      		FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'WHEN OTHERS ERROR WHILE VALIDATING
        			budget User Access Level bu_user_id  =>'|| p_bu_user_id
				|| ' Budget_level_id => ' || p_budget_level_id);
                reset_control_status;

END;

--------------------------------------------------------------------------------
-- Procedure to validate fund value
PROCEDURE validate_fund_value(v_set_of_books_id NUMBER,
			      v_fund_value VARCHAR2,
			      v_budget_level_id NUMBER) IS
	l_module_name VARCHAR2(200);
       BEGIN
		l_module_name := g_module_name || 'validate_fund_value';
		SELECT 'x'
		INTO v_exists
 		       FROM   fv_budget_distribution_dtl fbd
 		       WHERE  fbd.set_of_books_id = v_set_of_books_id
 		       AND    fbd.fund_value      = v_fund_value
		       AND    fbd.budget_level_id = v_budget_level_id;
        EXCEPTION
		WHEN NO_DATA_FOUND THEN
		  v_error_code := -9;
		WHEN OTHERS THEN
		  retcode := -1;
      errbuf := 'When others error while validating fund value.'||SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'WHEN OTHERS ERROR WHILE VALIDATING
          fund value');
      reset_control_status;
      END validate_fund_value;
--------------------------------------------------------------------------------
-- Procedure to validate treasury symbol expiry/cancellation date
PROCEDURE validate_tsymbol_date(v_set_of_books_id NUMBER,
				v_fund_value VARCHAR2,
				v_gl_date VARCHAR2) IS
		l_module_name VARCHAR2(200);
		l_expire_date  DATE;
		l_cancel_date  DATE;
		l_tsid	       NUMBER;
		l_gl_date      DATE;
		wrong_date     EXCEPTION;
       BEGIN
		l_module_name := g_module_name || 'validate_tsymbol_date';

              	SELECT fts.expiration_date, fts.cancellation_date,
		       fts.treasury_symbol_id
		INTO   l_expire_date, l_cancel_date, l_tsid
              	FROM   fv_treasury_symbols fts,
		       fv_budget_distribution_hdr fbh
		WHERE  fts.treasury_symbol_id = fbh.treasury_symbol_id
		AND    fts.set_of_books_id    = fbh.set_of_books_id
		AND    fbh.fund_value         = v_fund_value
		AND    fbh.set_of_books_id    = v_set_of_books_id;

		IF (nvl(l_expire_date,v_gl_date)
			< v_gl_date OR
		    nvl(l_cancel_date,v_gl_date)
			< v_gl_date)
		  THEN RAISE wrong_date;
		END IF;
        EXCEPTION
		WHEN WRONG_DATE THEN
		  v_error_code := -9;
		WHEN OTHERS THEN
		  retcode := -1;
      errbuf := SUBSTR(SQLERRM,1,100)||' :When others error while validating expire/cancel date for treasury symbol';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,SUBSTR(SQLERRM,1,100)||' :WHEN OTHERS ERROR
          while validating expire/cancel date for treasury symbol');
	    	  reset_control_status;
      END validate_tsymbol_date;
--------------------------------------------------------------------------------
-- Procedure to validate transaction type and its attributes
PROCEDURE validate_trx_type_attribs(v_set_of_books_id NUMBER,
                            v_budget_level_id NUMBER,
                            v_trx_type VARCHAR2,
                            v_sub_type VARCHAR2,
			    v_public_law_code VARCHAR2,
			    v_advance_type VARCHAR2,
			    v_dept_id NUMBER,
			    v_main_account NUMBER) IS
	l_module_name VARCHAR2(200);
	g_sub_type_flag varchar2(1);
        BEGIN
		l_module_name := g_module_name || 'validate_trx_type_attribs';

                g_pub_law_code_flag := NULL;
                g_advance_flag      := NULL;
                g_transfer_flag     := NULL;

                g_advance_type_code     := NULL;


                SELECT public_law_code_flag, advance_flag,
		       transfer_flag, sub_type_flag
                INTO   g_pub_law_code_flag, g_advance_flag,
		       g_transfer_flag,g_sub_type_flag
                FROM   fv_be_transaction_types
                WHERE  set_of_books_id = v_set_of_books_id
                AND    budget_level_id = v_budget_level_id
                AND    apprn_transaction_type = v_trx_type;

                IF (g_pub_law_code_flag = 'Y') AND (v_public_law_code IS NULL OR LENGTH(v_public_law_code) > 7)
		   THEN v_error_code := -6;
  		     RETURN;
	        END IF;
		IF g_sub_type_flag = 'Y' and v_sub_type is null  THEN
			v_error_code := -10;
		        RETURN;
		END IF;
                IF g_advance_flag = 'Y'
                   THEN
		     BEGIN
		        SELECT lookup_code
		        INTO   g_advance_type_code
		        FROM   fv_lookup_codes
		        WHERE  lookup_type = 'ADVANCE_FLAG'
		        AND    description = v_advance_type;
		      EXCEPTION WHEN NO_DATA_FOUND THEN
			v_error_code := -7;
		        RETURN;
		     END;
		END IF;

                IF (g_transfer_flag = 'Y' AND (v_dept_id IS NULL OR
                        v_main_account IS NULL))
                   THEN v_error_code := -8;
	        END IF;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  v_error_code := -9;
                WHEN OTHERS THEN
                  retcode := -1;
                  errbuf := 'When others error while validating Transaction Type.'||SQLERRM;
                  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
                  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'WHEN OTHERS ERROR WHILE VALIDATING
                      Transaction Type');
                  reset_control_status;
       END validate_trx_type_attribs;
--------------------------------------------------------------------------------
-- Check for default transaction code in fv_be_transaction_types
-- If default transaction code is not equal to the trx code
-- then check the transaction code for that transaction type
-- in fv_be_trx_codes.  If the transaction code does not exist
-- in fv_be_trx_codes then the record is in error
PROCEDURE VALIDATE_SUB_TYPE(v_set_of_books_id NUMBER,
			    v_trx_type VARCHAR2,
			    v_budget_level_id NUMBER,
				v_sub_type VARCHAR2) IS
		l_module_name VARCHAR2(200);
		l_be_tt_id	NUMBER;
		l_update_flag	VARCHAR2(1);
		l_subtype_flag  VARCHAR2(1);
       	BEGIN
		l_module_name := g_module_name || 'VALIDATE_SUB_TYPE';

		SELECT  sub_type_flag
       		 INTO   l_subtype_flag
       		 FROM   fv_be_transaction_types
        	WHERE  set_of_books_id = v_set_of_books_id
        	AND    budget_level_id = v_budget_level_id
        	AND    apprn_transaction_type = v_trx_type;



          IF (l_subtype_flag ='Y' ) or (V_SUB_TYPE is not null) THEN

                SELECT 'X'
			INTO   v_exists
		FROM   FV_BE_TRANSACTION_TYPES T, FV_BE_TRX_SUB_TYPES S
		WHERE  T.BE_TT_ID = S.BE_TT_ID
			AND    T.BUDGET_LEVEL_ID = V_BUDGET_LEVEL_ID
			AND    T.APPRN_TRANSACTION_TYPE = V_TRX_TYPE
			AND    S.SUB_TYPE = V_SUB_TYPE;
	ELSE
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Sub Type flag is set to No');
		END IF;
	EXCEPTION
		-- If Sub-Type does not exist
		  WHEN NO_DATA_FOUND THEN
  			v_error_code := -9;
		  WHEN OTHERS THEN
			  retcode := -1;
			  errbuf := 'When others error while validating Sub Type.'||SQLERRM;
			  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',errbuf);
			  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'WHEN OTHERS ERROR WHILE
	                validating Sub-Type');
		  reset_control_status;
END VALIDATE_SUB_TYPE;
--------------------------------------------------------------------------------
-- Procedure to validate document number
PROCEDURE validate_doc_number(v_doc_number VARCHAR2,
			      v_set_of_books_id NUMBER,
			      v_fund_value VARCHAR2,
			      v_budget_level_id NUMBER,
			      v_source VARCHAR2) IS

		l_module_name VARCHAR2(200);
		l_doc_status      VARCHAR2(25);
		l_revision_num    NUMBER;
		l_doc_id	  NUMBER;
		l_doc_entry	  VARCHAR2(1);
		l_doc_type	  VARCHAR2(1);
		l_doc_number	  NUMBER;
		l_fund_value	  fv_fund_parameters.fund_value%TYPE;
	BEGIN
		l_module_name := g_module_name || 'validate_doc_number';
		SELECT doc_status, revision_num, doc_id, fund_value
		INTO   l_doc_status, l_revision_num, l_doc_id, l_fund_value
		FROM   fv_be_trx_hdrs
		WHERE  set_of_books_id = v_set_of_books_id
		AND    budget_level_id = v_budget_level_id
		AND    doc_number      = v_doc_number
		AND    source	       = v_source;

	      -- Check if the fund_value is the same for the above combination
	      -- if not, reject the record
	      IF v_fund_value = l_fund_value THEN
		-- Check if document has been approved
		IF l_doc_status NOT IN ('AR','IMPORTING') THEN
		   v_error_code := -8;
		   RETURN;
		END IF;
	       ELSE
	        v_error_code := -7;
	        RETURN;
              END IF;

	 EXCEPTION
		-- If doc number is not found, then validate the
		-- new doc number
		WHEN NO_DATA_FOUND THEN
	          BEGIN
			SELECT doc_num_entry, doc_num_type
			INTO   l_doc_entry, l_doc_type
			FROM   fv_budget_levels
			WHERE  set_of_books_id = v_set_of_books_id
			AND    budget_level_id = v_budget_level_id;
			-- Check if document entry is automatic
			-- or manual. If it is automatic or is (manual and
			-- numeric), then check
			-- whether interface doc number is numeric.
			-- If it is not numeric then raise error
			IF (l_doc_entry = 'A') OR
			      (l_doc_entry = 'M' AND l_doc_type = 'N')
			 THEN
			   SELECT to_number(v_doc_number)
			   INTO l_doc_number
			   FROM DUAL;
			END IF;
		   EXCEPTION
			WHEN INVALID_NUMBER THEN
			   v_error_code := -9;
			WHEN OTHERS THEN
        retcode := -1;
        errbuf := 'When others error while validating Document Number.'||SQLERRM;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',errbuf);
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'WHEN OTHERS ERROR WHILE
            validating Document Number');
        reset_control_status;
		   END;
	        WHEN OTHERS THEN
            retcode := -1;
            errbuf := 'When others error while validating Document Number.'||SQLERRM;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'WHEN OTHERS ERROR WHILE
              validating Document Number');
            reset_control_status;
   	END validate_doc_number;
--------------------------------------------------------------------------------
-- Procedure to validate DFF
PROCEDURE validate_dff
(
  v_attribute_category fv_be_interface.attribute_category%TYPE,
  v_attribute1  fv_be_interface.attribute1%TYPE,
  v_attribute2  fv_be_interface.attribute2%TYPE,
  v_attribute3  fv_be_interface.attribute3%TYPE,
  v_attribute4  fv_be_interface.attribute4%TYPE,
  v_attribute5  fv_be_interface.attribute5%TYPE,
  v_attribute6  fv_be_interface.attribute6%TYPE,
  v_attribute7  fv_be_interface.attribute7%TYPE,
  v_attribute8  fv_be_interface.attribute8%TYPE,
  v_attribute9  fv_be_interface.attribute9%TYPE,
  v_attribute10 fv_be_interface.attribute10%TYPE,
  v_attribute11 fv_be_interface.attribute11%TYPE,
  v_attribute12 fv_be_interface.attribute12%TYPE,
  v_attribute13 fv_be_interface.attribute13%TYPE,
  v_attribute14 fv_be_interface.attribute14%TYPE,
  v_attribute15 fv_be_interface.attribute15%TYPE,
  v_error_mesg  OUT NOCOPY VARCHAR2
) IS

  l_module_name VARCHAR2(200);
  l_validation_result BOOLEAN;
BEGIN
  l_module_name := g_module_name || 'validate_dff';
  v_error_code := 0;

  fnd_flex_descval.clear_column_values;
  fnd_flex_descval.set_context_value (v_attribute_category);
  fnd_flex_descval.set_column_value ('ATTRIBUTE1', v_attribute1);
  fnd_flex_descval.set_column_value ('ATTRIBUTE2', v_attribute2);
  fnd_flex_descval.set_column_value ('ATTRIBUTE3', v_attribute3);
  fnd_flex_descval.set_column_value ('ATTRIBUTE4', v_attribute4);
  fnd_flex_descval.set_column_value ('ATTRIBUTE5', v_attribute5);
  fnd_flex_descval.set_column_value ('ATTRIBUTE6', v_attribute6);
  fnd_flex_descval.set_column_value ('ATTRIBUTE7', v_attribute7);
  fnd_flex_descval.set_column_value ('ATTRIBUTE8', v_attribute8);
  fnd_flex_descval.set_column_value ('ATTRIBUTE9', v_attribute9);
  fnd_flex_descval.set_column_value ('ATTRIBUTE10', v_attribute10);
  fnd_flex_descval.set_column_value ('ATTRIBUTE11', v_attribute11);
  fnd_flex_descval.set_column_value ('ATTRIBUTE12', v_attribute12);
  fnd_flex_descval.set_column_value ('ATTRIBUTE13', v_attribute13);
  fnd_flex_descval.set_column_value ('ATTRIBUTE14', v_attribute14);
  fnd_flex_descval.set_column_value ('ATTRIBUTE15', v_attribute15);


  l_validation_result := fnd_flex_descval.validate_desccols
  (
    appl_short_name 	=> 'FV',
    desc_flex_name	  => 'FV_BE_TRX_DTLS_DESC'
  );

  IF (NOT l_validation_result) THEN
    v_error_mesg := fnd_flex_descval.error_message;
    v_error_code := -9;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    retcode := -1;
    errbuf := 'When others error while validating DFF.'||SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,errbuf);
    reset_control_status;
END validate_dff;
--------------------------------------------------------------------------------
-- Procedure to copy default segment values
PROCEDURE copy_default_seg_vals(v_set_of_books_id NUMBER,
			        v_fund_value VARCHAR2,
			        v_budget_level_id NUMBER,
				v_rowid VARCHAR2) IS

		l_module_name VARCHAR2(200);
		lv_stmt			VARCHAR2(1000);
		lv_seg_type		VARCHAR2(1);
		lv_seg_value		VARCHAR2(25);

	BEGIN
		l_module_name := g_module_name || 'copy_default_seg_vals';
	    FOR app_col_name IN app_col(v_set_of_books_id)
	     LOOP

               lv_stmt:=
                'SELECT '||app_col_name.application_column_name||'_TYPE,'||
	         app_col_name.application_column_name||
                ' FROM   fv_budget_distribution_dtl
                  WHERE  set_of_books_id = :set_of_books_id
                  AND    budget_level_id = :budget_level_id
                  AND    fund_value = :fund_value ';

                EXECUTE IMMEDIATE lv_stmt INTO lv_seg_type, lv_seg_value
		        USING v_set_of_books_id, v_budget_level_id,
			      v_fund_value ;

                -- Check if the segment type is D. If the segment type is
	        -- D, then update the current row with the default segment value

	        lv_stmt := NULL;

                IF lv_seg_type = 'D' THEN
	          lv_stmt :=
	           'UPDATE fv_be_interface
	            SET '||app_col_name.application_column_name||
	           ' = '||''''||lv_seg_value||''''||
	           ' WHERE rowid = :rowid ';


                EXECUTE IMMEDIATE lv_stmt USING v_rowid ;

                END IF;
             END LOOP;
        EXCEPTION
	     WHEN NO_DATA_FOUND THEN
          errbuf := 'No Data Found error while copying default segment values';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.no_data',errbuf);
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'NO DATA FOUND ERROR WHILE COPYING
            default segment values');
          retcode := -1;
          reset_control_status;
	     WHEN OTHERS THEN
          errbuf  := substr(sqlerrm,1,100)||':When others error while copying default segment values';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,SUBSTR(SQLERRM,1,100)||':WHEN OTHERS ERROR
                       while copying default segment values');
          retcode := -1;
          reset_control_status;
	END copy_default_seg_vals;
--------------------------------------------------------------------------------
-- Procedure to concatenate segments
PROCEDURE concat_segs(l_array fnd_flex_ext.segmentarray, l_sob_id NUMBER,
		      l_bud_segs OUT NOCOPY VARCHAR2) IS
	l_module_name VARCHAR2(200);
	l_temp_string VARCHAR2(2000);
	l_count NUMBER;
	l_delmtr VARCHAR2(1);

   BEGIN
	l_module_name := g_module_name || 'concat_segs';
	SELECT concatenated_segment_delimiter
        INTO   l_delmtr
        FROM   fnd_id_flex_structures ffs,
	       gl_ledgers_public_v gsb
        WHERE  application_id      = 101
        AND    id_flex_code        = 'GL#'
	AND    ffs.id_flex_num     = gsb.chart_of_accounts_id
	AND    gsb.ledger_id = l_sob_id;

     l_count    := 0;
     l_bud_segs := NULL;

      FOR app_col_rec IN app_col(l_sob_id)
	LOOP
	 IF l_count = 0 THEN
	     l_temp_string :=
                   l_array(substr(app_col_rec.application_column_name,8));
          ELSE
	     l_temp_string :=
             l_delmtr||l_array(substr(app_col_rec.application_column_name,8));
	 END IF;
    	  l_bud_segs := l_bud_segs||l_temp_string;
 	  l_count := 2;
	END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        errbuf  := 'When no data found error while concatenating segments';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.no_data',errbuf);
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'WHEN NO DATA FOUND ERROR WHILE CONCATENATING
        segments');
        retcode := -1;
        reset_control_status;
      WHEN OTHERS THEN
         errbuf := SQLERRM;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
        retcode := -1;
   END concat_segs;
--------------------------------------------------------------------------------
-- Procedure to update revision_num, doc_status
-- and move records to the interface history table once all
-- the records have been successfully validated
PROCEDURE update_cleanup(parm_source IN VARCHAR2,
			 parm_group_id IN NUMBER) IS

	l_module_name VARCHAR2(200);
	l_prof_val VARCHAR2(1);

	BEGIN
		l_module_name := g_module_name || 'update_cleanup';
		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'UPDATING REV NUM IN HEADERS');
		END IF;
		 UPDATE fv_be_trx_hdrs fbh
		 SET    revision_num =
		       (SELECT MAX(revision_num)
			FROM   fv_be_trx_dtls fbd
		        WHERE  fbh.doc_id = fbd.doc_id)
		 WHERE    fbh.doc_status = 'IMPORTING';

		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'UPDATING DOC STATUS IN HEADERS
    		 for existing recs');
		END IF;
		 UPDATE fv_be_trx_hdrs
		 SET    doc_status = 'RA'
		 WHERE  doc_status = 'IMPORTING'
		 AND    internal_revision_num <> -9999;

		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'UPDATING DOC STATUS, REV NUM IN
    		headers for new recs');
		END IF;
		 UPDATE fv_be_trx_hdrs
		 SET    doc_status = 'IN',
			internal_revision_num = 0
		 WHERE  doc_status = 'IMPORTING'
		 AND    internal_revision_num = -9999;

		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'UPDATING STATUS IN CONTROL TABLE');
		END IF;
		 UPDATE fv_be_interface_control
		 SET    status = 'IMPORTED'
		 WHERE  source = parm_source
		 AND    group_id = parm_group_id;

		 l_prof_val := FND_PROFILE.VALUE('FV_ARCH_BE_INT_RECS');

		 IF l_prof_val = 'Y'
		  THEN
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'INSERTING INTO HISTORY TABLE');
       END IF;

		   INSERT INTO fv_be_interface_history
	           (record_number, set_of_books_id, source, group_id, error_code,
		    error_reason, budget_level_id,
		    budgeting_segments, transaction_type, sub_type,
		    fund_value, period_name, segment1, segment2, segment3,
		    segment4, segment5, segment6, segment7, segment8, segment9,
		    segment10, segment11, segment12, segment13, segment14,
		    segment15, segment16, segment17, segment18, segment19,
		    segment20, segment21, segment22, segment23, segment24,
		    segment25, segment26, segment27, segment28, segment29,
		    segment30, increase_decrease_flag, amount, doc_number,
		    attribute1, attribute2, attribute3, attribute4, attribute5,
	       	    attribute6, attribute7, attribute8, attribute9, attribute10,
		    attribute11, attribute12, attribute13, attribute14,
		    attribute15, attribute_category, processed_flag, status,
		    date_created, created_by, corrected_flag, last_update_date,
		    last_updated_by, public_law_code, advance_type, dept_id,
 		    main_account, transfer_description,budget_user_id,
                    gl_date)
		   SELECT
		    record_number, set_of_books_id, source, group_id, error_code,
		    error_reason, budget_level_id,
		    budgeting_segments, transaction_type, sub_type,
		    fund_value, period_name, segment1, segment2, segment3,
		    segment4, segment5, segment6, segment7, segment8, segment9,
		    segment10, segment11, segment12, segment13, segment14,
		    segment15, segment16, segment17, segment18, segment19,
		    segment20, segment21, segment22, segment23, segment24,
		    segment25, segment26, segment27, segment28, segment29,
		    segment30, increase_decrease_flag, amount, doc_number,
		    attribute1, attribute2, attribute3, attribute4, attribute5,
	       	    attribute6, attribute7, attribute8, attribute9, attribute10,
		    attribute11, attribute12, attribute13, attribute14,
		    attribute15, attribute_category, processed_flag, status,
		    date_created, created_by, corrected_flag, sysdate,
		    fnd_global.user_id, public_law_code, advance_type,
		    dept_id, main_account, transfer_description,budget_user_id,
                    gl_date
		   FROM   fv_be_interface
		   WHERE  source = parm_source
		   AND    group_id = parm_group_id
                   AND    set_of_books_id = parm_ledger_id
		   AND    status = 'ACCEPTED'
		   AND    processed_flag = 'Y';
		 END IF;

		IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'DELETING FROM BE_INTERFACE');
		END IF;
		 DELETE FROM fv_be_interface
	   	 WHERE  source = parm_source
		 AND    group_id = parm_group_id
                 AND    set_of_books_id = parm_ledger_id
		 AND    status = 'ACCEPTED'
		 AND    processed_flag = 'Y';
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
    retcode := -1;
    errbuf := 'When no data found error in update_cleanup';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.no_data',errbuf);
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,'WHEN NO DATA FOUND ERROR IN UPDATE_CLEANUP');
    reset_control_status;
	WHEN OTHERS THEN
    retcode := -1;
    errbuf := 'When others error in update_cleanup.'||SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name,'WHEN OTHERS ERROR IN UPDATE_CLEANUP');
    reset_control_status;
	END update_cleanup;
--------------------------------------------------------------------------------
PROCEDURE update_err_rec(v_rec_number IN NUMBER) IS
	l_module_name VARCHAR2(200);
BEGIN
	l_module_name := g_module_name || 'update_err_rec';

	UPDATE fv_be_interface
--        SET    status = 'REJECTED',
        SET    status = 'ACCEPTED',
	       error_code = 'EM42',
               error_reason = 'Budgeting Segments do not exist for
				previous budget level'
	WHERE  record_number = v_rec_number;

	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
    retcode := -1;
    errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RAISE;
END update_err_rec;
--------------------------------------------------------------------------------
-- This procedure resets the status in the control table
-- whenever there is a when-others error and processing
-- cannot continue
PROCEDURE reset_control_status IS
	l_module_name VARCHAR2(200);
	PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
		l_module_name := g_module_name || 'reset_control_status';
	 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'RESETTING STATUS IN THE CONTROL TABLE');
	 END IF;
         UPDATE fv_be_interface_control
   	 SET    status = 'REJECTED'
   	 WHERE  source = parm_source
   	 AND    group_id = parm_group_id;
         COMMIT;
EXCEPTION
	WHEN OTHERS THEN
    retcode := -1;
    errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
    RAISE;
END reset_control_status;
--------------------------------------------------------------------------------
BEGIN
  --GSCC File.Sql.35 fix
  g_module_name := 'fv.plsql.FV_BE_INT_PKG.';
END fv_be_int_pkg;

/
