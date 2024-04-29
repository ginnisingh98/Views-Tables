--------------------------------------------------------
--  DDL for Package Body OZF_GL_TRANSFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_GL_TRANSFER_PVT" AS
/* $Header: ozfvgtrb.pls 120.4.12010000.3 2010/03/09 11:13:14 kpatro ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OZF_GL_TRANSFER_PVT';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'ozfgltrb.pls';




-- Function checks if the set of books has any reporting sobs.
-- Returns 'Y' if there are reporting sobs for a primary or secondary sob.
-- This function called from the SRS program definition for
-- Claims Transfer to GL for parameter
-- Transfer Reporting SOBs.

/*
FUNCTION ozf_mc_check (p_psob_id NUMBER)
  RETURN varchar2 IS
     cursor c1 (sob_id number) IS
	SELECT sp.set_of_books_id
          FROM gl_sets_of_books sob,
               ozf_sys_parameters sp
         WHERE sob.set_of_books_id = sp.set_of_books_id
           AND sp.set_of_books_id = nvl(sob_id, sp.set_of_books_id)
           AND sp.set_of_books_id <> -1;

l_org_id        NUMBER(15);
l_mrc_flag      VARCHAR2(1);
l_return_flag   VARCHAR2(1) := 'N';

BEGIN
   l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enhancements
   for rec in c1(p_psob_id) loop
      gl_mc_info.mrc_enabled(rec.set_of_books_id, 682, l_org_id, '',l_mrc_flag);
      if l_mrc_flag = 'Y' then
	 l_return_flag := 'Y';
      end if;
   end loop;

   IF l_return_flag = 'Y' THEN
      return 'Y';
    ELSE
      return NULL;
   END IF;
END ozf_mc_check;

-- Calls common transfer to GL API.
PROCEDURE  OZF_GL_TRANSFER (
 p_errbuf                      OUT NOCOPY  VARCHAR2
,p_retcode                     OUT NOCOPY  NUMBER
,p_selection_type                   NUMBER
,p_set_of_books_id                  NUMBER
,p_include_reporting_sob            VARCHAR2
,p_batch_name                       VARCHAR2
,p_start_date                       VARCHAR2
,p_end_date                         VARCHAR2
,p_accounting_method                VARCHAR2
,p_document_class                   VARCHAR2
,p_journal_category                 VARCHAR2
,p_validate_account                 VARCHAR2
,p_gl_transfer_mode                 VARCHAR2
,p_submit_journal_import            VARCHAR2
,p_summary_journal_entry            VARCHAR2
,p_process_days                     NUMBER
,p_debug_flag                       VARCHAR2
,p_trace_flag                       VARCHAR2 )
IS

l_sob_list   xla_gl_transfer_pkg.t_sob_list := xla_gl_transfer_pkg.t_sob_list();
l_sob_info   gl_mc_info.t_ael_sob_info;

i                       NUMBER := 0;
l_request_id            NUMBER; -- Concurrent Request Id
l_appl_id               NUMBER; -- Application Id.
l_user_id               NUMBER; -- User Id.
l_org_id                NUMBER;
-- Bug 5606829
l_org_code              VARCHAR2(240);
l_curr_calling_sequence VARCHAR2(240);
l_debug_info            VARCHAR2(1000);
l_je_category           xla_gl_transfer_pkg.t_ae_category;
l_start_date            DATE;
l_end_date              DATE;
l_errbuf                VARCHAR2(1000);

l_api_name          CONSTANT VARCHAR2(30) := 'OZF_GL_TRANSFER';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_val_acct          VARCHAR2(30);
l_gl_interface          VARCHAR2(30);
l_submit_journal_import VARCHAR2(30);
l_je_category_name  VARCHAR2(80);

-- Bug 4888509
CURSOR je_name_csr (je_name VARCHAR2) IS
SELECT USER_JE_CATEGORY_NAME FROM gl_je_categories
where JE_CATEGORY_NAME = je_name;

CURSOR lookup_name_csr (lk_type VARCHAR2, lk_code VARCHAR2) IS
SELECT meaning
from fnd_lookups
where  lookup_type = lk_type
and lookup_code = lk_code;

CURSOR submit_jrnl_import_csr (lk_type VARCHAR2, lk_code VARCHAR2) IS
SELECT l.meaning
FROM fnd_lookups l, fnd_product_installations i
WHERE l.lookup_type = lk_type
AND i.application_id = 101
AND (i.status = 'I' or (i.status = 'S' and l.lookup_code = 'N'))
AND l.lookup_code = lk_code;

CURSOR c1 (sob_id NUMBER) IS
SELECT sob.set_of_books_id
,      sob.name
,      sob.currency_code
,      'Accrual' accounting_method
,      'P' sob_type
,      'N' encumbrance_flag
FROM   gl_sets_of_books sob,
       ozf_sys_parameters sp
WHERE  sob.set_of_books_id = sp.set_of_books_id
AND    sp.set_of_books_id = decode(sob_id, -1,sp.set_of_books_id, sob_id)
AND    sp.set_of_books_id <> -1;

BEGIN

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start ='||G_PKG_NAME);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*--------------------------------Transfer To GL Execution Report -----------------------------*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Starts On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'In Parameters : ');

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_selection_type        : '||p_selection_type );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_set_of_books_id       : '||p_set_of_books_id );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_include_reporting_sob : '||p_include_reporting_sob );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_batch_name            : '||p_batch_name );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_start_date            : '||p_start_date );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_end_date              : '||p_end_date );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_accounting_method     : '||p_accounting_method );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_document_class        : '||p_document_class );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_journal_category      : '||p_journal_category );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_validate_account      : '||p_validate_account );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_gl_transfer_mode      : '||p_gl_transfer_mode );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_submit_journal_import : '||p_submit_journal_import );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_summary_journal_entry : '||p_summary_journal_entry );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_process_days          : '||p_process_days );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_debug_flag            : '||p_debug_flag );

   -- Set the start date. Currently utilizing the gl_periods set for
   -- AR applicaiotn.Change to 682 after open/close periods functionality is
   -- provided to Funds and Claims module.

/* Bugfix: 7412302 - Changed start date to G_MISS_DATE in case of NULL.
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Before deriving the start date');

   IF p_start_date is null THEN
      if p_set_of_books_id <> -1 then
         select min(start_date)
         into   l_start_date
         from   gl_period_statuses
         where  application_id = 222
         and    set_of_books_id =  p_set_of_books_id
         and nvl(adjustment_period_flag,'N') = 'N'
         and closing_status IN ( 'O','F');
      else
         select min(start_date)
         into   l_start_date
         from   gl_period_statuses
         where  application_id = 222
         and    set_of_books_id in ( select set_of_books_id
                                     from ozf_sys_parameters
                                     where set_of_books_id <> -1)
 	 and nvl(adjustment_period_flag,'N') = 'N'
         and closing_status IN ( 'O','F');
      end if;
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'After deriving start date '||l_start_date);



   IF p_start_date IS NOT NULL THEN
      l_start_date :=  FND_DATE.CANONICAL_TO_DATE(p_start_date);
   ELSE
      l_start_date :=  FND_API.G_MISS_DATE;
   END IF;

   l_end_date :=  FND_DATE.CANONICAL_TO_DATE(p_end_date);

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'After deriving start date '||l_start_date);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'After converting end date '||l_end_date);

   -- If the Document class is Claims then transfer Claims and Deduction
   -- entries.

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Before deriving the je_category - Document class :  '||p_document_class);

   IF p_document_class IS NOT NULL THEN
      IF nvl(p_document_class,'A') = 'Claims' THEN
         l_je_category(1)  := 'Claims';
         l_je_category(2)  := 'Deductions';
         l_je_category(3)  := 'Settlement';
      ELSIF nvl(p_document_class,'A') = 'Budget' THEN
         l_je_category(1)  := 'Fixed Budgets';
         l_je_category(2)  := 'Accrual Budgets';
      ELSIF nvl(p_document_class,'A') = 'All' THEN
         l_je_category(1)  := 'Claims';
         l_je_category(2)  := 'Deductions';
         l_je_category(3)  := 'Fixed Budgets';
         l_je_category(4)  := 'Accrual Budgets';
         l_je_category(5)  := 'Settlement';
      END IF;
   ELSE -- Called from SRS
      IF p_journal_category = 'A' THEN
         l_je_category(1)  := 'Claims';
         l_je_category(2)  := 'Deductions';
         l_je_category(3)  := 'Fixed Budgets';
         l_je_category(4)  := 'Accrual Budgets';
         l_je_category(5)  := 'Settlement';
      ELSE
         l_je_category(1)  := p_journal_category;
      END IF;
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'After deriving the je_category');

   --Get Profile Information
   l_request_id := FND_GLOBAL.conc_request_id;
   l_appl_id    := FND_GLOBAL.resp_appl_id;
   l_user_id    := FND_GLOBAL.user_id;
   l_org_id     := MO_GLOBAL.GET_CURRENT_ORG_ID();  -- R12 Enhancements

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'After getting user profile from client_info');
   l_debug_info := 'Poplating l_sob_info table';

   FOR  rec IN c1(p_set_of_books_id) LOOP
      i := i+1 ;
      l_sob_info(i).sob_id            := rec.set_of_books_id;
      l_sob_info(i).currency_code     := rec.currency_code;
      l_sob_info(i).accounting_method := rec.accounting_method;
      l_sob_info(i).sob_type          := rec.sob_type;
      l_sob_info(i).encumb_flag       := rec.encumbrance_flag;
      l_sob_info(i).sob_name          := rec.name;
   END LOOP;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'After populating sob_info');

     -- If MRC is Installed
   IF Nvl(p_include_reporting_sob,'N') = 'Y' THEN
      l_debug_info := 'Calling MRC API to get the reporting set of books';
      gl_mc_info.ap_ael_sobs(l_sob_info);
   END IF;


   -- Populate l_sob_list for common transfer API
   l_debug_info := 'Populating l_sob_list table';

   FOR i IN l_sob_info.first..l_sob_info.last LOOP
      l_sob_list.EXTEND;
      l_sob_list(i).sob_id        := l_sob_info(i).sob_id;
      l_sob_list(i).sob_name      := l_sob_info(i).sob_name;
      l_sob_list(i).sob_curr_code := l_sob_info(i).currency_code;
      l_sob_list(i).encum_flag    := l_sob_info(i).encumb_flag;
   END LOOP;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'After populating sob_list');

   -- Get org_code
   l_debug_info := 'Getting Organization Name';

   -- Fix for bug 4888509
   IF l_org_id IS NOT NULL THEN
      l_org_code := mo_global.get_ou_name(l_org_id);
   END IF;

   --Call common transfer API
   l_debug_info :='Calling Common Transfer API';

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Before calling xla_gl_transfer');

   IF p_journal_category IS NOT NULL THEN
      IF p_journal_category = 'A' THEN
         OPEN lookup_name_csr('BOTH_ALL_NONE', p_journal_category);
         FETCH lookup_name_csr INTO l_je_category_name;
         CLOSE lookup_name_csr;
      ELSE
         OPEN je_name_csr(p_journal_category);
         FETCH je_name_csr into l_je_category_name;
         CLOSE je_name_csr;
      END IF;
   END IF;

   IF p_validate_account IS NOT NULL THEN
      OPEN lookup_name_csr('YES_NO', p_validate_account);
      FETCH lookup_name_csr into l_val_acct;
      CLOSE lookup_name_csr;
   END IF;

   IF p_gl_transfer_mode IS NOT NULL THEN
      OPEN lookup_name_csr('XLA_GL_TRANSFER_MODE', p_gl_transfer_mode);
      FETCH lookup_name_csr into l_gl_interface;
      CLOSE lookup_name_csr;
   END IF;

   IF p_submit_journal_import IS NOT NULL THEN
      OPEN submit_jrnl_import_csr('YES_NO', p_submit_journal_import);
      FETCH submit_jrnl_import_csr into l_submit_journal_import;
      CLOSE submit_jrnl_import_csr;
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Set of Books Name            : '||l_sob_info(1).sob_name );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch Name                   : '||p_batch_name );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'From Date                    : '||l_start_date );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'To Date                      : '||l_end_date );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Journal Category             : '||l_je_category_name );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Validate Accounts            : '||l_val_acct );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Transfer to Gl Interface     : '||l_gl_interface );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Submit Journal Import        : '||l_submit_journal_import );

   xla_gl_transfer_pkg.xla_gl_transfer
   (
      p_application_id         => l_appl_id,
      p_user_id                => l_user_id,
      p_request_id             => l_request_id,
      p_org_id                 => l_org_id,
      p_program_name           => 'OZF1',
      p_selection_type         => p_selection_type,
      p_sob_list               => l_sob_list,
      p_batch_name             => p_batch_name,
      p_source_doc_id          => NULL,
      p_source_document_table  => NULL,
      p_start_date             => l_start_date,
      p_end_date               => l_end_date,
      p_journal_category       => l_je_category,
      p_validate_account       => p_validate_account,
      p_gl_transfer_mode       => p_gl_transfer_mode,
      p_submit_journal_import  => p_submit_journal_import,
      p_summary_journal_entry  => p_summary_journal_entry,
      p_process_days           => p_process_days,
      p_batch_desc             => l_org_code || ' ' || p_batch_name,
      p_je_desc                => l_org_code || ' ' || p_batch_name,
      p_je_line_desc           => l_org_code || ' ' || p_batch_name,
      p_debug_flag             => p_debug_flag
   );

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'After calling xla_gl_transfer');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Successful' );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

EXCEPTION
    WHEN OTHERS THEN
       p_errbuf := Sqlerrm;
       p_retcode := 2;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Failure (Error:' ||SQLCODE||SQLERRM || ')');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

       IF (SQLCODE <> -20001) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
         --APP_EXCEPTION.RAISE_EXCEPTION;
          RAISE;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
          --g_error_message := Sqlerrm;
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
END OZF_GL_TRANSFER;
*/

---------------------------------------------------------------------
-- PROCEDURE
--    CreateAccounting
--
-- PURPOSE
-- It will trigger the SLA Create Accounting Program
--
-- NOTES
--
-- HISTORY
-- 09-Mar-2010       KPATRO  Created   ER#9382547 ChRM-SLA Uptake
---------------------------------------------------------------------


PROCEDURE CreateAccounting(
                  errbuf          OUT NOCOPY VARCHAR2,
		  retcode         OUT NOCOPY NUMBER,
		  p_org_id                     IN NUMBER,
		  p_source_application_id      IN NUMBER,
		  p_application_id             IN NUMBER,
		  p_dummy                      IN VARCHAR2,
		  p_ledger_id                  IN NUMBER,
		  P_PROCESS_CATEGORY_CODE      IN VARCHAR2,
		  P_END_DATE                   IN VARCHAR2,
		  P_CREATE_ACCOUNTING_FLAG     IN VARCHAR2,
		  P_DUMMY_PARAM_1              IN VARCHAR2,
		  P_ACCOUNTING_MODE            IN VARCHAR2,
		  P_DUMMY_PARAM_2              IN VARCHAR2,
		  P_ERRORS_ONLY_FLAG           IN VARCHAR2,
		  P_REPORT_STYLE               IN VARCHAR2,
		  P_TRANSFER_TO_GL_FLAG        IN VARCHAR2,
		  P_DUMMY_PARAM_3              IN VARCHAR2,
		  P_POST_IN_GL_FLAG            IN VARCHAR2,
		  P_GL_BATCH_NAME              IN VARCHAR2,
		  P_MIN_PRECISION              IN NUMBER,
		  P_INCLUDE_ZERO_AMOUNT_LINES  IN VARCHAR2,
		  P_REQUEST_ID                 IN NUMBER,
		  P_ENTITY_ID                  IN NUMBER,
		  P_SOURCE_APPLICATION_NAME    IN VARCHAR2,
		  P_APPLICATION_NAME           IN VARCHAR2,
		  P_LEDGER_NAME                IN VARCHAR2,
		  P_PROCESS_CATEGORY_NAME      IN VARCHAR2,
		  P_CREATE_ACCOUNTING          IN VARCHAR2,
		  P_ACCOUNTING_MODE_NAME       IN VARCHAR2,
		  P_ERRORS_ONLY                IN VARCHAR2,
		  P_ACCOUNTING_REPORT_LEVEL    IN VARCHAR2,
		  P_TRANSFER_TO_GL             IN VARCHAR2,
		  P_POST_IN_GL                 IN VARCHAR2,
		  P_INCLUDE_ZERO_AMT_LINES     IN VARCHAR2,
		  P_VALUATION_METHOD_CODE      IN VARCHAR2,
		  P_SECURITY_INT_1             IN NUMBER,
		  P_SECURITY_INT_2             IN NUMBER,
		  P_SECURITY_INT_3             IN NUMBER,
		  P_SECURITY_CHAR_1            IN VARCHAR2,
		  P_SECURITY_CHAR_2            IN VARCHAR2,
		  P_SECURITY_CHAR_3            IN VARCHAR2,
		  P_CONC_REQUEST_ID            IN NUMBER,
		  P_INCLUDE_USER_TRX_ID_FLAG   IN VARCHAR2,
		  P_INCLUDE_USER_TRX_IDENTIFIERS IN VARCHAR2,
		  P_DebugFlag                  IN VARCHAR2,
		  P_USER_ID                    IN NUMBER
	)
IS

l_reqid			   NUMBER;

BEGIN

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start ='||G_PKG_NAME);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*--------------------------------Create Accounting Report -----------------------------*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Starts On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------*');

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'In Parameters : ');

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_ledger_name            : '||p_ledger_name );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_end_date        : '||p_end_date );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_transfer_to_gl_flag       : '||p_transfer_to_gl_flag );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_gl_batch_name : '||p_gl_batch_name );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_transfer_to_gl            : '||p_transfer_to_gl );
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_post_in_gl              : '||p_post_in_gl );


   l_reqid := fnd_request.submit_request('XLA',
     				         'XLAACCPB',
					 '',
   					 '',
					 FALSE,
					 p_source_application_id,
					 p_application_id,
					 p_dummy,
					 p_ledger_id,
                                         p_process_category_code,
					 p_end_date,
					 p_create_accounting_flag,
					 p_dummy_param_1,
					 p_accounting_mode,
					 p_dummy_param_2,
					 p_errors_only_flag,
					 p_report_style,
					 p_transfer_to_gl_flag,
					 p_dummy_param_3,
					 p_post_in_gl_flag,
					 p_gl_batch_name,
					 p_min_precision,
					 p_include_zero_amount_lines,
					 p_request_id,
					 p_entity_id,
					 p_source_application_name,
					 p_application_name,
					 p_ledger_name,
					 p_process_category_name,
					 p_create_accounting,
					 p_accounting_mode_name,
					 p_errors_only,
					 p_accounting_report_level,
					 p_transfer_to_gl,
					 p_post_in_gl,
					 p_include_zero_amt_lines,
					 p_valuation_method_code,
					 p_security_int_1,
					 p_security_int_2,
					 p_security_int_3,
					 p_security_char_1,
					 p_security_char_2,
					 p_security_char_3,
					 p_conc_request_id,
					 p_include_user_trx_id_flag,
					 p_include_user_trx_identifiers,
					 p_debugflag,
					 p_user_id
		     );

		IF l_reqid=0 THEN
			FND_FILE.PUT_LINE(fnd_file.log,'Could not launch Create Accounting Request');
			retcode:=1;
		END IF;


IF retcode<>1 THEN
retcode:=0;
END IF;
COMMIT;

 FND_FILE.PUT_LINE(FND_FILE.LOG, 'After calling SLA Accounting Program');
 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Successful' );
 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    retcode:=2;
    ROLLBACK TO CREATE_Accounting;
    errbuf:= FND_API.G_RET_STS_ERROR;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Expected Error: '||SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Failure (Error:' ||SQLCODE||SQLERRM || ')');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    retcode:=2;
    ROLLBACK TO CREATE_Accounting;
    errbuf:= FND_API.G_RET_STS_UNEXP_ERROR;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'UnExpected Error: '||SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Failure (Error:' ||SQLCODE||SQLERRM || ')');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
WHEN OTHERS THEN
    retcode:=2;
    ROLLBACK TO CREATE_Accounting;
    errbuf:= FND_API.G_RET_STS_UNEXP_ERROR;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Failure (Error:' ||SQLCODE||SQLERRM || ')');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

END CreateAccounting;



END OZF_GL_TRANSFER_PVT;

/
