--------------------------------------------------------
--  DDL for Package Body CSTPGLXF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPGLXF" AS
/* $Header: CSTGLXFB.pls 115.6 2004/01/08 22:39:48 rzhu ship $ */

/*============================================================================+
| This procedure is the called by the GL Transfer SRS. It first validates     |
| the input parameters, then calls the common GL transfer API.                |
|============================================================================*/

PROCEDURE  CST_GL_TRANSFER (
			   p_errbuf                      OUT NOCOPY  VARCHAR2,
			   p_retcode                     OUT NOCOPY  NUMBER,
			   p_application_id                   NUMBER,
			   p_user_id                          NUMBER,
			   p_legal_entity		      NUMBER,
			   p_cost_type_id		      NUMBER,
			   p_cost_group_id		      NUMBER,
			   p_period_id			      NUMBER,
			   p_batch_name                       VARCHAR2,
			   p_gl_transfer_mode                 VARCHAR2,
			   p_submit_journal_import            VARCHAR2,
			   p_debug_flag                       VARCHAR2
			   ) IS
  l_sob_list     	XLA_GL_TRANSFER_PKG.T_SOB_LIST := XLA_GL_TRANSFER_PKG.T_SOB_LIST();
  l_ae_category  	XLA_GL_TRANSFER_PKG.T_AE_CATEGORY;
  l_start_date		DATE;
  l_end_date		DATE;
  l_stmt_num		NUMBER;
  l_le_exists		NUMBER;
  l_ct_exists		NUMBER;
  l_cg_exists		NUMBER;
  l_per_exists		NUMBER;
  l_set_of_books_id	NUMBER;
  l_sob_name		VARCHAR2(30);
  l_base_currency_code 	VARCHAR2(10);
  l_request_id   	NUMBER;
  l_err_num		NUMBER;
  l_err_code		VARCHAR2(240);
  l_err_msg		VARCHAR2(240);
  CONC_STATUS		BOOLEAN;
  CST_NO_LE		EXCEPTION;
  CST_NO_CT		EXCEPTION;
  CST_NO_CG		EXCEPTION;
  CST_NO_PER		EXCEPTION;
BEGIN
   xla_util.enable_debug;

   -------------------------------------------------------------------
   -- Get request ID
   -------------------------------------------------------------------

   l_request_id := FND_GLOBAL.conc_request_id;  -- Populate concurrent Request Id.

   l_request_id := Nvl(l_request_id,-1); --for now


   --------------------------------------------------------------------
   -- Display the Input parameters
   --------------------------------------------------------------------

   fnd_file.put_line(fnd_file.log,'Application ID = '||to_char(p_application_id ));
   fnd_file.put_line(fnd_file.log,'User ID = '||to_char(p_user_id));
   fnd_file.put_line(fnd_file.log,'Legal Entity =  '||to_char(p_legal_entity));
   fnd_file.put_line(fnd_file.log,'Cost Type = '||to_char(p_cost_type_id));
   fnd_file.put_line(fnd_file.log,'Cost Group =  '||to_char(p_cost_group_id));
   fnd_file.put_line(fnd_file.log,'Period = '||to_char(p_period_id));
   fnd_file.put_line(fnd_file.log,'Batch Name = '||p_batch_name );
   fnd_file.put_line(fnd_file.log,'GL Transfer Mode = '||p_gl_transfer_mode);
   fnd_file.put_line(fnd_file.log,'Submit Journal Import = '||p_submit_journal_import);
   fnd_file.put_line(fnd_file.log,'Debug Flag = '||p_debug_flag);

   l_stmt_num := 10;

   -------------------------------------------------------------------
   -- Validate the Legal Entity
   -- the legal entity should
   -- exist in cst_le_cost_types
   -- post_to_gl flag for it should be 'Y'
   -------------------------------------------------------------------

   SELECT
   count(*)
   INTO
   l_le_exists
   FROM
   cst_le_cost_types
   WHERE
   legal_entity = p_legal_entity AND
   post_to_gl ='Y';

   IF (l_le_exists = 0) THEN
     RAISE CST_NO_LE;
   END IF;

   l_stmt_num := 20;

   ------------------------------------------------------------------
   -- Validate the Cost Type
   -- cost type should
   -- exist in cst_le_cost_types
   -- post_to_gl flag for le-ct should be 'Y'
   -- and the cost type should not be disabled
   ------------------------------------------------------------------

   SELECT
   count(*)
   INTO
   l_ct_exists
   FROM
   cst_le_cost_types clct,
   cst_cost_types cct
   WHERE clct.legal_entity = p_legal_entity AND
   clct.cost_type_id = p_cost_type_id AND
   clct.post_to_gl = 'Y' AND
   clct.cost_type_id = cct.cost_type_id AND
   NVL(cct.disable_date, SYSDATE +1) > SYSDATE;

   IF (l_ct_exists = 0) THEN
     RAISE CST_NO_CT;
   END IF;

   l_stmt_num := 30;

   ------------------------------------------------------------------
   -- Validate Cost Group
   -- cost group should
   -- exist in cst_cost_group for the le
   ------------------------------------------------------------------

   SELECT
   count(*)
   INTO
   l_cg_exists
   FROM
   cst_cost_groups ccg
   WHERE legal_entity = p_legal_entity AND
   cost_group_id = p_cost_group_id;

   IF (l_cg_exists = 0) THEN
     RAISE CST_NO_CG;
   END IF;

   l_stmt_num := 40;


   ------------------------------------------------------------------
   -- Validate Period
   -- period should
   -- exist in cst_pac_periods for the le-ct
   -- should be closed
   ------------------------------------------------------------------

   SELECT
   count(*)
   INTO
   l_per_exists
   FROM
   cst_pac_periods
   WHERE open_flag = 'N' AND
   legal_entity = p_legal_entity AND
   cost_type_id = p_cost_type_id AND
   pac_period_id = p_period_id;

   IF (l_per_exists = 0) THEN
     RAISE CST_NO_PER;
   END IF;

   l_stmt_num := 50;


   ----------------------------------------------------------------
   -- Get the set of books info
   ----------------------------------------------------------------

   SELECT
   clct.set_of_books_id,
   glsob.name
   INTO
   l_set_of_books_id,
   l_sob_name
   FROM
   cst_le_cost_types clct,
   gl_sets_of_books glsob
   WHERE
   clct.legal_entity = p_legal_entity AND
   clct.cost_type_id = p_cost_type_id AND
   clct.set_of_books_id = glsob.set_of_books_id;


   l_stmt_num := 60;

   ----------------------------------------------------------------
   -- Get the currency code
   ----------------------------------------------------------------

   SELECT
   currency_code
   INTO
   l_base_currency_code
   FROM
   gl_sets_of_books
   WHERE
   set_of_books_id = l_set_of_books_id;

   l_stmt_num := 70;


   ------------------------------------------------------------------
   -- Get period start and end date
   -- the GL common API takes period start and end dates as input
   -- instead of the period id
   ------------------------------------------------------------------

   SELECT
   period_start_date,
   period_end_date
   INTO
   l_start_date,
   l_end_date
   FROM
   cst_pac_periods
   WHERE
   pac_period_id = p_period_id;


   ---------------------------------------------------------------
   -- Populate the structure to be passed to the common API
   ---------------------------------------------------------------

   l_sob_list.EXTEND;
   l_sob_list(1).sob_id        		:= l_set_of_books_id;
   l_sob_list(1).sob_name       	:= l_sob_name;
   l_sob_list(1).sob_curr_code 		:= l_base_currency_code;

   /* Bug 3233033: change the encum_flag from NULL to 'Y' */
   l_sob_list(1).encum_flag    		:= 'Y';

   l_sob_list(1).legal_entity_id 	:= p_legal_entity;
   l_sob_list(1).cost_type_id   	:= p_cost_type_id;
   l_sob_list(1).cost_group_id 		:= p_cost_group_id;


   --------------------------------------------------------------
   -- Populate the category structure
   -- for Periodic Costing, there is only one row, and the value
   -- is 'A' for 'ALL'
   --------------------------------------------------------------

   l_ae_category(1) := 'A';

   l_stmt_num := 80;


   ----------------------------------------------------------------
   -- Call the common transfer API
   ----------------------------------------------------------------

   fnd_file.put_line(fnd_file.log,'Calling Common Transfer API ...');

   xla_gl_transfer_pkg.xla_gl_transfer(
			 p_application_id         => p_application_id,
			 p_user_id                => p_user_id,
			 p_org_id		  => NULL,
			 p_request_id             => l_request_id,
			 p_program_name           => 'CST1',
			 p_selection_type         => 1,
			 p_sob_list               => l_sob_list,
			 p_batch_name             => p_batch_name,
			 p_source_doc_id          => NULL,
			 p_source_document_table  => NULL,
			 p_start_date             => l_start_date,
			 p_end_date               => l_end_date,
			 p_journal_category       => l_ae_category,
			 p_gl_transfer_mode       => p_gl_transfer_mode,
			 p_submit_journal_import  => p_submit_journal_import,
			 p_summary_journal_entry  => 'N',
			 p_process_days           => NULL,
			 p_batch_desc             => p_legal_entity || ' ' || p_cost_type_id || ' ' || p_cost_group_id || ' ' || p_batch_name,
			 p_je_desc                => p_legal_entity || ' ' || p_cost_type_id || ' ' || p_cost_group_id || ' ' || p_batch_name,
			 p_je_line_desc           => p_legal_entity || ' ' || p_cost_type_id || ' ' || p_cost_group_id || ' ' || p_batch_name,
			 p_debug_flag             => p_debug_flag
					 );

EXCEPTION
   WHEN CST_NO_LE THEN
	l_err_num := 30001;
	l_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_PAC_GL_INVALID_LE');
        l_err_msg := FND_MESSAGE.Get;
  	l_err_msg := 'CSTGLXFB.cst_gl_transfer : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg;
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
   WHEN CST_NO_CT THEN
	l_err_num := 30002;
	l_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_PAC_GL_INVALID_CT');
        l_err_msg := FND_MESSAGE.Get;
  	l_err_msg := 'CSTGLXFB.cst_gl_transfer : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg;
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
   WHEN CST_NO_CG THEN
	l_err_num := 30003;
	l_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_PAC_CG_INVALID');
        l_err_msg := FND_MESSAGE.Get;
  	l_err_msg := 'CSTGLXFB.cst_gl_transfer : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg;
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
   WHEN CST_NO_PER THEN
	l_err_num := 30004;
	l_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_PAC_GL_INVALID_PER');
        l_err_msg := FND_MESSAGE.Get;
  	l_err_msg := 'CSTGLXFB.cst_gl_transfer : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg;
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
   WHEN OTHERS THEN
      l_err_num := 30009;
      l_err_code := SQLCODE;
      l_err_msg :=to_char(l_err_num)||' : '||l_err_code||':'|| SUBSTR('CSTPGLXF.cst_gl_transfer('
                        ||to_char(l_stmt_num)
                        ||'):'
                        ||SQLERRM,1,240);
	CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
	fnd_file.put_line(fnd_file.log,l_err_msg);
END CST_GL_TRANSFER;
END CSTPGLXF;

/
